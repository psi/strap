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
  sh "touch cookbooks/.gitkeep"
  sh "tar zcvf /Volumes/Data/Dropbox/Public/cookbooks.tgz ./cookbooks ./roles"
end

VM_NAME="Mac OS X 10.8 64-bit"

def revert_vm(snapshot_name)
  sh "fission snapshot revert '#{VM_NAME}' '#{snapshot_name}'"
end

namespace :vm do
  desc "Rollback VM"
  task :rollback => [:revert_to_last, :start]

  desc "Baseline VM"
  task :baseline => [:revert_to_baseline, :start]

  desc "Revert VM to baseline"
  task :revert_to_baseline do
    revert_vm("strap-baseline")
  end

  desc "Revert VM to last snapshot"
  task :revert_to_last do
    last_snapshot = `fission snapshot list '#{VM_NAME}' | tail -n 1`.chomp
    revert_vm(last_snapshot)
  end

  desc "Take a snapshot of the VM"
  task :snapshot do
    sh "fission snapshot create '#{VM_NAME}' $(date +'%Y%m%d%H%M')"
  end

  desc "Start VM"
  task :start do
    sh "fission start '#{VM_NAME}'"
  end

  desc "Shutdown VM"
  task :shutdown do
    sh "fission stop '#{VM_NAME}'"
  end

  desc "Bootstrap VM"
  task :bootstrap => [:baseline, :bundle_cookbooks] do
    sh "scp bootstrap.sh strap:."
    sh "ssh -t strap 'bash bootstrap.sh'"
  end

  desc "Provision VM"
  task :provision => :bundle_cookbooks do
    sh "ssh -t strap 'chef-solo -c ~/.chef/solo.rb -o \'role[workstation]\''"
  end
end
