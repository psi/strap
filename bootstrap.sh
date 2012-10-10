#!/bin/bash
COOKBOOKS_URL="http://dl.dropbox.com/u/211124/cookbooks.tgz"

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

# Set hostname
sudo scutil --set HostName ${STRAP_HOSTNAME}.local
sudo scutil --set ComputerName ${STRAP_HOSTNAME}
sudo scutil --set LocalHostName ${STRAP_HOSTNAME}

# Update OS X
sudo softwareupdate -i -a

# Install chef
curl -L http://www.opscode.com/chef/install.sh | sudo bash

# Configure chef
mkdir -p ${HOME}/.chef/{roles,cookbooks,checksum,cache,cache/checksums}

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
sudo chown -R `whoami`:staff /usr/local

# Run chef
chef-solo -c ~/.chef/solo.rb -r ${COOKBOOKS_URL} -o "role[workstation]"
