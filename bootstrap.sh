#!/bin/bash
COOKBOOKS_URL="http://dl.dropbox.com/u/211124/cookbooks.tgz"

# Configure password-less sudo

# Install chef
curl -L http://www.opscode.com/chef/install.sh | sudo bash

# Configure chef
mkdir -p ${HOME}/.chef

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
chef-solo -c ~/.chef/solo.rb -r ${COOKBOOKS_URL} -o "recipe[xcode_command_line_tools],recipe[homebrew]"
