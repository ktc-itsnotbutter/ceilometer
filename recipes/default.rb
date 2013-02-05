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
execute "apt-get" do
  command "apt-get install -y python-setuptools python-all-dev libxslt1-dev libvirt0"
  cwd '/'
  user 'root'
end

execute "easy_install" do
  command "easy_install -U pecan"
  cwd '/'
  user 'root'
end

# source download 
execute "git" do
  #command "echo #{node['ceilometer_dir']} >> test_file"
  command "git clone https://github.com/openstack/ceilometer #{node['ceilometer_dir']}"
  cwd "/"
  user "#{node['user']}"
  not_if do File.exists?("#{node['ceilometer_dir']}") end
end

# install
execute "python" do
  #command "pwd >> #{node['ceilometer_dir']}/test_file2"
  #command "echo '#{node['ceilometer_dir']} -> going toward 'whoami >> test_file"
  command "cd #{node['ceilometer_dir']};sudo python setup.py install"
  cwd #{node['ceilometer_dir']}
  user "root"
end

# create config directory
directory "#{node['ceilometer_conf_dir']}" do
   owner "#{node['user']}"
   group "#{node['group']}"
   mode  0755
   action :create
end

# create log directory
directory "#{node['ceilometer_log_dir']}" do
   owner "#{node['user']}"
   group "#{node['group']}"
   mode  0755
   action :create
end

selected_module = data_bag_item('ceilometer','install_module')
install_module = selected_module['module']
#install_host = select_module['account']

#template "#{node['env']}/openrc" do
#  source "openrc.erb"
#  owner  "#{node['user']}"
#  group  "#{node['group']}"
#  mode   0644
#end

#user "#{node['user']}" do
#  home "/home"
#  shell "#{node['env']}/openrc"
#  system true
#end

execute "echo" do
  command "echo 'install_start:module:#{install_module}('`/bin/date`')' >> #{node['install_record']}"
  cwd "#{node['ceilometer_log_dir']}"
  user "root"
end

ENV['OS_TENANT_NAME']="#{node['os_tenant_name']}"
ENV['OS_USERNAME']="#{node['os_username']}"
ENV['OS_PASSWORD']="#{node['os_password']}"
ENV['OS_AUTH_URL']="#{node['os_auth_url']}"


file "#{node['ceilometer_conf']}" do
  owner "#{node['user']}"
  group "#{node['group']}"
  mode 0644
  action :delete
end

file "#{node['ceilometer_conf']}" do
  owner "#{node['user']}"
  group "#{node['group']}"
  mode 0644
  action :create
end

bash "make ceilometer conf" do
  user "#{node['user']}"
  cwd  "#{node['ceilometer_conf_dir']}"
  code <<-EOH
    echo '\[DEFAULT\]' >> #{node['ceilometer_conf']}
    echo 'rpc_backend = ceilometer.openstack.common.rpc.impl_kombu' >> #{node['ceilometer_conf']}
    echo 'rabbit_max_retries=0' >> #{node['ceilometer_conf']}
    echo 'rabbit_retry_interval=0' >> #{node['ceilometer_conf']}
    grep -v -e format_string -e DEFAULT -e impl_kombu #{node['nova_conf']} >> #{node['ceilometer_conf']}
  EOH
end

case install_module
when "collector"

  execute "keystone" do
    command "keystone role-create --name=ResellerAdmin"
#--os-username #{node['os_username']} --os-tenanat-name #{node['os_tenant_name']} --os-password #{node['os_password']} --os-auth-url #{node['os_auth_url']}"
    cwd "/"
    user "#{node['user']}"
    #environment ({'OS_TENANT_NAME' => "#{node['os_tenant_name']}"})
    #environment ({'OS_USERNAME' => "#{node['os_username']}"})
    #environment ({'OS_PASSWORD' => "#{node['os_password']}"})
    #environment ({'OS_AUTH_URL' => "#{node['os_auth_url']}"})
    #action :nothing
    not_if "keystone role-list | grep 'ResellerAdmin'"
  end

  execute "keystone" do
    command "keystone user-role-add --tenant_id `keystone tenant-list | grep ' #{node['os_tenant_name']} ' | awk '{print $2}'` --user_id `keystone user-list | grep ' #{node['os_username']} ' | awk '{print $2}'` --role_id `keystone role-list | grep ' #{node['os_tenant_name']} ' | awk '{print $2}'`"
    cwd "/"
    user "#{node['user']}"
    #environment ({'OS_TENANT_NAME' => "#{node['os_tenant_name']}"})
    #environment ({'OS_USERNAME' => "#{node['os_username']}"})
    #environment ({'OS_PASSWORD' => "#{node['os_password']}"})
    #environment ({'OS_AUTH_URL' => "#{node['os_auth_url']}"})
    #action :nothing
    not_if "keystone user-role-list | grep ' #{node['os_tenant_name']} '"
  end

  
  if node['use_swift'] == 'yes'
    directory "#{node['swift_conf_dir']}" do
      owner "openstack"
      group "root"
      mode  0755
      action :create
    end

    bash "make ceilometer conf" do
      user "#{node['user']}"
      cwd  "#{node['ceilometer_conf_dir']}"
      code <<-EOH
        echo '[filter:ceilometer]' >> #{node['swift_conf']}
        echo 'use = egg:ceilometer#swift' >> #{node['swift_conf']}
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

  execute "apt-get" do
    command "apt-get install -y mongodb"
    cwd '/'
    user "root"
  end

  bash "make ceilometer conf" do
    user "#{node['user']}"
    cwd  "#{node['ceilometer_conf_dir']}"
    code <<-EOH
      echo '[keystone_authtoken]' >> #{node['ceilometer_conf']}
      echo 'signing_dir = #{node['ceilometer_log_dir']}' >> #{node['ceilometer_conf']}
      echo 'admin_tenant_name =#{node['os_tenant_name']}' >> #{node['ceilometer_conf']}
      echo 'admin_password = #{node['os_password']}' >> #{node['ceilometer_conf']}
      echo 'admin_user =#{node['os_username']}' >> #{node['ceilometer_conf']}
      echo 'auth_protocol =http' >> #{node['ceilometer_conf']} 
    EOH
  end


when "compute-agent"

 
when "central-agent"

  bash "make ceilometer conf" do
    user "#{node['user']}"
    cwd  "#{node['ceilometer_conf_dir']}"
    code <<-EOH
      echo '# nova-compute configuration for ceilometer' >> #{node['nova_conf']}
      echo 'instance_usage_audit=True' >> #{node['nova_conf']}
      echo 'instance_usage_audit_period=hour' >> #{node['nova_conf']}
      echo 'notification_driver=nova.openstack.common.notifier.rabbit_notifier' >> #{node['nova_conf']}
      echo 'notification_driver=ceilometer.compute.nova_notifier' >> #{node['nova_conf']} 
      
    EOH
  end

when "api-server"

else

  execute "echo" do
    command "echo '====>> not selected(#{install_module})' >> result.txt"
    cwd "#{node['ceilometer_conf_dir']}"
    user "#{node['user']}"
  end
end

# copy policy file
#execute "cp" do
#   command "cp #{node['ceilometer_conf_dir']}/etc/ceilometer/policy.json #{node['ceilometer_conf_dir']}"
#   cwd "#{node['ceilometer_conf_dir']}"
#   user "root"
#end

# run modules
case install_module
when "collector"
  execute "python" do
    command "/usr/bin/python #{node['ceilometer_dir']}/bin/ceilometer-collector --config-file #{node['ceilometer_conf']} &"
    cwd "#{node['ceilometer_dir']}"
    user "root"
  end
when "compute-agent"
  execute "python" do
    command "/usr/bin/python #{node['ceilometer_dir']}/bin/ceilometer-agent-compute --config-file #{node['ceilometer_conf']} &"
    cwd "#{node['ceilometer_dir']}"
    user "root"
  end
when "central-agent"
  execute "python" do
    command "/usr/bin/python #{node['ceilometer_dir']}/bin/ceilometer-agent-central --config-file #{node['ceilometer_conf']} &"
    cwd "#{node['ceilometer_dir']}"
    user "root"
    #action :nothing
  end
when "api-server"
  execute "python" do
    command "/usr/bin/python #{node['ceilometer_dir']}/bin/ceilometer-api -d -v --log-dir=#{node['ceilometer_log_dir']} --config-file #{node['ceilometer_conf']} &"
    cwd "#{node['ceilometer_dir']}"
    user "root"
  end
else

  execute "echo" do
    command "echo 'not chosen any module. check knife data bag setting.' >> #{node['install_record']}"
    cwd "#{node['ceilometer_log_dir']}"
    user "root"
  end
end

execute "echo" do
  command "echo 'install_complete:module:#{install_module}('`/bin/date`')' >> #{node['install_record']}"
  cwd "#{node['ceilometer_log_dir']}"
  user "root"
end


