#
# Cookbook Name:: ceilometer_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# install collector

Chef::Log.info "ceilometer-collector install start"

if node['ceilometer']['use_swift'] == 'yes'
  directory "#{node['ceilometer']['swift_conf_dir']}" do
    owner "openstack"
    group "root"
    mode  0755
    action :create
  end

  bash "make_ceilometer_conf" do
    user "#{node['ceilometer']['user']}"
    cwd  "#{node['ceilometer']['swift_conf_dir']}"
    code <<-EOH
      if [ `grep "filter:ceilometer" #{node['ceilometer']['swift_conf']}` = "" ];then
        echo '[filter:ceilometer]' >> #{node['ceilometer']['swift_conf']}
        echo 'use = egg:ceilometer#swift' >> #{node['ceilometer']['swift_conf']}
      fi
    EOH
  end
end

# mongodb default directory
directory "/data" do
  owner "mongodb"
  group "mongodb"
  mode  0755
  action :create
end

directory "/data/db" do
  owner "mongodb"
  group "mongodb"
  mode  0755
  action :create
end

package "mongodb" do
  action :install
  only_if { platform_family?("ubuntu")}
end

bash "collector_last_progress" do
  user "root" 
  code <<-EOH 
    sed -i 's/bind_ip = 127.0.0.1/bind_ip = 0.0.0.0/g' /etc/mongodb.conf
    restart mongodb
    sleep 1
    /usr/bin/python /usr/local/bin/ceilometer-collector --config-file #{node['ceilometer']['ceilometer_conf']} &
  EOH
end

#/usr/bin/python /usr/local/bin/ceilometer-collector --config-file #{node['ceilometer']['ceilometer_conf']} 

#execute "ceilometer-collector" do
#  user "root"
#  cwd  "/"
#  command "/usr/bin/python /usr/local/bin/ceilometer-collector --config-file #{node['ceilometer']['ceilometer_conf']}"
#  action :run
#end

#service "ceilometer-collector" do
#  service_name "ceilometer-collector"
#  start_command "/usr/bin/python /usr/local/bin/ceilometer-collector --config-file #{node['ceilometer']['ceilometer_conf']} &"  
#  action :start
#end

Chef::Log.info "ceilometer-collector install complete"
