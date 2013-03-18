#
# Cookbook Name:: ceilometer_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#if platform_family?('ubuntu')

# install pythos-setuptools - check if not installed

package "git" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "gcc" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "python-setuptools" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "python-all-dev" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "libxslt1-dev" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "libvirt0" do
  action :install
  only_if { platform_family?("ubuntu")}
end

package "python-pip" do
  action :install
  only_if { platform_family?("ubuntu")}
end

bash "pre-package-install" do
  user "root"
  code <<-EOH
    easy_install pecan

    if [ ! -f #{node['ceilometer']['nova_conf']} ];then 
      rm -rf #{node['ceilometer']['nova_dir']}
      git clone https://github.com/openstack/nova #{node['ceilometer']['nova_dir']}
      cd #{node['ceilometer']['nova_dir']}
      git fetch https://github.com/openstack/nova stable/folsom
      git checkout FETCH_HEAD

      cd #{node['ceilometer']['nova_dir']}/tools;pip install pip-requires
      cd #{node['ceilometer']['nova_dir']};sudo python setup.py install
    fi

    if [ ! -f #{node['ceilometer']['keystone_conf']} ];then
      rm -rf #{node['ceilometer']['keystone_dir']}
      git clone https://github.com/openstack/keystone #{node['ceilometer']['keystone_dir']}
      git fetch https://github.com/openstack/keystone stable/folsom
      git checkout FETCH_HEAD
      cd #{node['ceilometer']['keystone_dir']}/tools;pip install pip-requires
      cd #{node['ceilometer']['keystone_dir']};sudo python setup.py install
    fi 

    if [ "keystone user-role-list | grep ' #{node['os_tenant_name']} '" = "" };then
      keystone role-create --name=ResellerAdmin
      keystone user-role-add --tenant_id `keystone tenant-list | grep ' #{node['os_tenant_name']} ' | awk '{print $2}'` --user_id `keystone user-list | grep ' #{node['os_username']} ' | awk '{print $2}'` --role_id `keystone role-list | grep ' #{node['os_tenant_name']} ' | awk '{print $2}'`
    fi 
  EOH
end

bash "install-ceilometer" do
  user "root"
  code <<-EOH
    rm -rf #{node['ceilometer']['ceilometer_dir']}
    git clone https://github.com/openstack/ceilometer #{node['ceilometer']['ceilometer_dir']}
    cd #{node['ceilometer']['ceilometer_dir']}
    git fetch https://github.com/openstack/ceilometer stable/folsom
    git checkout FETCH_HEAD

    cd #{node['ceilometer']['ceilometer_dir']}/tools;pip install pip-requires
    easy_install prettytable==0.6
    cd #{node['ceilometer']['ceilometer_dir']};sudo python setup.py install
  EOH
end

Chef::Log.info "start to set ceilometer config"

# create config directory
directory "#{node['ceilometer']['ceilometer_conf_dir']}" do
   owner "#{node['ceilometer']['user']}"
   group "#{node['ceilometer']['group']}"
   mode  0755
   action :create
end

directory "#{node['ceilometer']['keystone_conf_dir']}" do
   owner "#{node['ceilometer']['user']}"
   group "#{node['ceilometer']['group']}"
   mode  0755
   action :create
end

# create log directory
directory "#{node['ceilometer']['ceilometer_log_dir']}" do
   owner "#{node['ceilometer']['user']}"
   group "#{node['ceilometer']['group']}"
   mode  0755
   action :create
end

file "#{node['ceilometer']['ceilometer_conf']}" do
  owner "#{node['ceilometer']['user']}"
  group "#{node['ceilometer']['group']}"
  mode 0644
  action :delete
end

file "#{node['ceilometer']['ceilometer_conf']}" do
  owner "#{node['ceilometer']['user']}"
  group "#{node['ceilometer']['group']}"
  mode 0644
  action :create
end

cookbook_file "/etc/ceilometer/policy.json" do
  source "policy.json"
  owner "#{node['ceilometer']["user"]}"
  group "#{node['ceilometer']["group"]}"
  mode "0644"
end

# nova db info
nova_setup_info = get_settings_by_role("nova-setup", "nova")
nova_db_info = get_access_endpoint("mysql-master", "mysql", "db")
nova_db_host = nova_db_info["host"]
nova_db_port = nova_db_info["port"]
nova_db_user = node["ceilometer"]["mysql_db"]["nova_user"]
#nova_db_password = nova_setup_info["db"]["password"]
nova_db_password = "#{node[:ceilometer][:mysql_db][:password]}"
nova_db_name = node["ceilometer"]["mysql_db"]["nova_database_name"]
nova_db_uri = URI::Generic.build({:host => nova_db_host,
                             :port => nova_db_port,
                             :scheme => 'mysql',
                             :userinfo => "#{nova_db_user}:#{nova_db_password}",
                             :path => "/#{nova_db_name}",
                             :query => "charset=utf8"
                            })

rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")
keystone = get_settings_by_role("keystone", "keystone")
ks_admin_endpoint = get_access_endpoint("keystone", "keystone", "admin-api")

template "#{node["ceilometer"]['ceilometer_conf']}" do
  source "ceilometer.conf.erb"
  owner  "root"
  mode   00644
  variables(
    :auth_uri => ks_admin_endpoint["uri"],
    :os_username => keystone["admin_user"],
    :tenant_name => keystone["users"][keystone["admin_user"]]["default_tenant"],
    #:os_password => keystone["users"][keystone["admin_user"]]["password"],
    :os_password => "#{node[:ceilometer][:os_password]}",
    :database_connection => "#{node[:ceilometer][:database_connection]}",
    :sql_connection => nova_db_uri,
    :rabbit_ip => rabbit_info["host"],
    :rabbit_password => "#{node[:ceilometer][:rabbit_password]}",
    :auth_protocol => "#{node[:ceilometer][:auth_protocol]}"
  )
end

template "#{node['ceilometer']['nova_conf']}" do
  source "nova.conf.erb"
  owner  "root"
  mode   00644
  variables(
    :sql_connection => nova_db_uri
  )
end

keystone_db_info = get_access_endpoint("mysql-master", "mysql", "db")
keystone_db_host = keystone_db_info["host"]
#nova_db_host = '14.63.205.39'
keystone_db_port = keystone_db_info["port"]
keystone_db_user = node["ceilometer"]["mysql_db"]["keystone_user"]
#nova_db_password = nova_setup_info["db"]["password"]
keystone_db_password = "#{node[:ceilometer][:mysql_db][:password]}"
keystone_db_name = node["ceilometer"]["mysql_db"]["keystone_database_name"]
keystone_db_uri = URI::Generic.build({:host => keystone_db_host,
                             :port => keystone_db_port,
                             :scheme => 'mysql',
                             :userinfo => "#{keystone_db_user}:#{keystone_db_password}",
                             :path => "/#{keystone_db_name}",
                             :query => "charset=utf8"
                            })

template "#{node['ceilometer']['keystone_conf']}" do
  source "keystone.conf.erb"
  owner  "root"
  mode   00644
  variables(
    :os_password => "#{node[:ceilometer][:os_password]}",
    :sql_connection => keystone_db_uri
  )
end

Chef::Log.info "Common recipe complete"

