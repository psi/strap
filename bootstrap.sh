#!/bin/bash
COOKBOOKS_URL="http://dl.dropbox.com/u/211124/cookbooks.tgz"
CACHE_ROOT="/Volumes/VMware Shared Folders"
CHEF_BASEDIR="${HOME}/.chef"

# An easy way to prompt for stuff
# Usage: prompt_with_default <prompt text> <default value>
function prompt_with_default() {
  prompt_text=$1
  default_value=$2

  read -p "${prompt_text} [${default_value}] " input_value

  if [ "${input_value}" == "" ]; then
    echo ${default_value}
  else
    echo ${input_value}
  fi
}

cat <<EOF

Welcome to strap!

We're going to need to run some stuff as root, so the first thing we're going
to do is tell sudo not require a password. For that, we're going to need your
password...

EOF

# Configure password-less sudo
sudo sed -i -e 's/%admin	ALL=(ALL) ALL/%admin	ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

if ! sudo -l | grep -q NOPASSWD; then
  echo "Hmm... our attempt to make sudo passwordless seems to have failed :("
  exit 1
fi

cat <<EOF

Now, just a few questions...

EOF

# Prompt for hostname
STRAP_HOSTNAME=$(prompt_with_default "Hostname?" "$(hostname -s)")
STRAP_GH_USER=$(prompt_with_default "GitHub User?" $(whoami))
STRAP_GH_PASSWORD=$(prompt_with_default "GitHub Password?" "")

# Set hostname
sudo scutil --set HostName ${STRAP_HOSTNAME}.local
sudo scutil --set ComputerName ${STRAP_HOSTNAME}
sudo scutil --set LocalHostName ${STRAP_HOSTNAME}

# Generate an SSH key
cat <<EOF

Now we need to generate an SSH key for this machine. To do this you'll need to
enter a passphrase when prompted below...

EOF

ssh-keygen -f ~/.ssh/id_rsa -t rsa

payload="{\"title\":\"strap-$(hostname -s)\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}"
curl -u "${STRAP_GH_USER}:${STRAP_GH_PASSWORD}" -X POST -d "${payload}" https://api.github.com/user/keys

ssh -T git@github.com

# Update OS X
sudo softwareupdate -i -a

# Install chef
curl -L http://www.opscode.com/chef/install.sh | sudo bash
sudo chown -R `whoami`:staff /opt/chef

mkdir -p ${CHEF_BASEDIR}

# If we have cached directories, symlink them in
if [ -d "${CACHE_ROOT}" ]; then
  ln -s "${CACHE_ROOT}/cookbooks" ${CHEF_BASEDIR}/cookbooks
  ln -s "${CACHE_ROOT}/roles" ${CHEF_BASEDIR}/roles
  ln -s "${CACHE_ROOT}/cache" ${CHEF_BASEDIR}/cache
fi

# Configure chef
for dir in roles cookbooks checksum cache cache/checksums; do
  if [ ! -e ${CHEF_BASEDIR}/${dir} ]; then
    mkdir -p ${CHEF_BASEDIR}/${dir}
  fi
done

cat <<EOF > ${HOME}/.chef/solo.rb
base_dir = File.dirname(__FILE__)

log_level    :info
log_location STDOUT

role_path        "#{base_dir}/roles"
cookbook_path    "#{base_dir}/cookbooks"
checksum_path    "#{base_dir}/checksum"
file_cache_path  "#{base_dir}/cache"
file_backup_path "#{base_dir}/backup"

cache_options :path => "#{base_dir}/cache/checksums", :skip_expires => true
EOF

# Pave the way for homebrew
sudo mkdir /usr/local
sudo chown -R `whoami`:staff /usr/local /Library/{Ruby,Perl,Python}

# Run chef
chef-solo -c ~/.chef/solo.rb -o "role[workstation]"
