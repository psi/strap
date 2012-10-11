#
# Rakefile for Chef Server Repository
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'chef'
require 'json'

# Load constants from rake config file.
require File.join(File.dirname(__FILE__), 'config', 'rake')

# Detect the version control system and assign to $vcs. Used by the update
# task in chef_repo.rake (below). The install task calls update, so this
# is run whenever the repo is installed.
#
# Comment out these lines to skip the update.

if File.directory?(File.join(TOPDIR, ".svn"))
  $vcs = :svn
elsif File.directory?(File.join(TOPDIR, ".git"))
  $vcs = :git
end

# Load common, useful tasks from Chef.
# rake -T to see the tasks this loads.

load 'chef/tasks/chef_repo.rake'

desc "Bundle a single cookbook for distribution"
task :bundle_cookbook => [ :metadata ]
task :bundle_cookbook, :cookbook do |t, args|
  tarball_name = "#{args.cookbook}.tar.gz"
  temp_dir = File.join(Dir.tmpdir, "chef-upload-cookbooks")
  temp_cookbook_dir = File.join(temp_dir, args.cookbook)
  tarball_dir = File.join(TOPDIR, "pkgs")
  FileUtils.mkdir_p(tarball_dir)
  FileUtils.mkdir(temp_dir)
  FileUtils.mkdir(temp_cookbook_dir)

  child_folders = [ "cookbooks/#{args.cookbook}", "site-cookbooks/#{args.cookbook}" ]
  child_folders.each do |folder|
    file_path = File.join(TOPDIR, folder, ".")
    FileUtils.cp_r(file_path, temp_cookbook_dir) if File.directory?(file_path)
  end

  system("tar", "-C", temp_dir, "-cvzf", File.join(tarball_dir, tarball_name), "./#{args.cookbook}")

  FileUtils.rm_rf temp_dir
end

desc "Bundle cookbooks"
task :bundle_cookbooks do
  sh "berks install --path=cookbooks"
  sh "tar zcvf /Volumes/Data/Dropbox/Public/cookbooks.tgz ./cookbooks ./roles"
  sh "rm -rf ./cookbooks"
end

VMRUN_CMD="'/Applications/VMware\ Fusion.app/Contents/Library/vmrun' -T fusion"
VM_NAME="OS X 10.8"
VMX_FILE="#{ENV['HOME']}/Documents/Virtual Machines.localized/#{VM_NAME}.vmwarevm/#{VM_NAME}.vmx"

namespace :vm do
  desc "Reset VM"
  task :reset => [:stop, :rollback, :start]

  desc "Rollback VM"
  task :rollback do
    sh "#{VMRUN_CMD} revertToSnapshot '#{VMX_FILE}' strap-baseline"
  end

  desc "Start VM"
  task :start do
    sh "#{VMRUN_CMD} start '#{VMX_FILE}'"
  end

  desc "Shutdown VM"
  task :shutdown do
    sh "#{VMRUN_CMD} stop '#{VMX_FILE}'"
  end
end
