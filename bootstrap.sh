#!/bin/bash

# Configure password-less sudo

# Install chef
curl -L http://www.opscode.com/chef/install.sh | sudo bash

# Configure chef
mkdir -p ${HOME}/.chef

cat <<EOF > ${HOME}/.chef/solo.rb
base_dir = File.dirname(__FILE__)

log_level    :info
log_location STDOUT

cookbook_path    "#{base_dir}/cookbooks"
checksum_path    "#{base_dir}/checksum"
file_cache_path  "#{base_dir}/cache"
file_backup_path "#{base_dir}/backup"

cache_options :path => "#{base_dir}/cache/checksums", :skip_expires => true
EOF

# Run chef
chef-solo -c ~/.chef/solo.rb -r http://dl.dropbox.com/u/211124/cookbooks.tgz -o "recipe[xcode_command_line_tools]" -l debug
