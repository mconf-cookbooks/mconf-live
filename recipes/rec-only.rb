#
# Cookbook Name:: mconf-live
# Recipe:: rec-only
# Author:: Felipe Cecagno (<felipe@mconf.org>)
#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

include_recipe "bigbluebutton::pre-install"

node['mconf']['recording_server']['apt_packages'].each do |pkg|
  package pkg do
    options "-o Dpkg::Options::='--force-confnew'"
    action :upgrade
  end
end

ruby_block "upgrade dependencies recursively" do
  block do
    bbb_repo = node['bbb']['bigbluebutton']['repo_url']
    # load packages installed by the bigbluebutton repository
    bbb_packages = get_installed_bigbluebutton_packages(bbb_repo)
    # load all packages installed
    all_packages = get_installed_packages()
    upgrade_list = []
    # set the versions available on the repository - the exact versions are going to be installed
    bbb_packages.each do |pkg, version|
      if all_packages.include? pkg
        upgrade_list << "#{pkg}=#{version}"
      end
    end

    # dependencies aren't upgraded by default, so we need a specific procedure for that
    reset_auto = []
    if node['bbb']['bigbluebutton']['upgrade_dependencies']
      bbb_package_name = node['bbb']['bigbluebutton']['package_name']
      # load all dependencies of the bigbluebutton package
      bbb_deps = get_bigbluebutton_dependencies(bbb_package_name)
      
      # load the upgrades available, and insert to the upgrade_list the dependencies that we need to update
      command = "apt-get --dry-run --show-upgraded upgrade"
      to_upgrade = `#{command}`.split("\n").select { |l| l.start_with? "Conf" }.collect { |l| l.split()[1] }
      upgrade_list += (bbb_deps.keys - bbb_packages.keys) & to_upgrade
      upgrade_list << "libreoffice"

      # get the list of packages marked as automatically installed, so we can upgrade and reset the mark later
      reset_auto = bbb_deps.select { |key, value| value == :auto }.keys & to_upgrade
    end

    # check if any package will be upgraded, so we need to restart the service
    command = "apt-get --dry-run --show-upgraded install #{upgrade_list.join(' ')}"
    to_upgrade = `#{command}`.split("\n").select { |l| l.start_with? "Inst" }.collect { |l| l.split()[1] }
    restart_required = ! to_upgrade.empty?

    # run the upgrade
    command = "DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::='--force-confnew' -y --force-yes install #{upgrade_list.join(' ')}"
    Chef::Log.info "Running: #{command}"
    system(command)
    upgrade_status = $?

    if ! reset_auto.empty?
      # reset the automatically installed mark in the packages
      command = "apt-mark auto #{reset_auto.join(' ')}"
      Chef::Log.info "Running: #{command}"
      system(command)
      status = $?
      Chef::Log.error "Couldn't reset properly the list of automatically installed packages" if ! status.success?
    end

    # even if the upgrade fails, we reset the automatically installed mark BEFORE raising an exception
    raise "Couldn't upgrade the dependencies recursively" if ! upgrade_status.success?
  end
  action :run
end

service "tomcat7" do
  supports :status => true, :restart => true
  action [:disable, :stop]
end

service "nginx"

template "/etc/nginx/sites-available/bigbluebutton" do
  source "bigbluebutton.nginx.erb"
  mode "0644"
  variables(
    lazy {{
      :domain => node['ipaddress']
    }}
  )
  notifies :restart, "service[nginx]", :immediately
end

link '/etc/nginx/sites-enabled/bigbluebutton' do
  to '/etc/nginx/sites-available/bigbluebutton'
  notifies :restart, "service[nginx]", :immediately
end

ruby_block "update recordings definition" do
  block do
    filename = '/usr/local/bigbluebutton/core/scripts/bigbluebutton.yml'
    config = YAML.load_file(filename)
    config['playback_protocol'] = node['bbb']['ssl']['enabled'] ? "https" : "http"
    config['playback_host'] = node['bbb']['ip']
    File.open(filename,'w') do |h|
       h.write config.to_yaml
    end
  end
end
