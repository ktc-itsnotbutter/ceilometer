#
# Cookbook Name:: ceilometer_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#if platform_family?('ubuntu')


# copy policy file
#execute "cp" do
#   command "cp #{node['ceilometer_conf_dir']}/etc/ceilometer/policy.json #{node['ceilometer_conf_dir']}"
#   cwd "#{node['ceilometer_conf_dir']}"
#   user "root"
#end

# run modules

bash "api_last_progress" do
  user "root" 
  code <<-EOH 
    python /usr/local/bin/ceilometer-api --config-file #{node['ceilometer']['ceilometer_conf']} &
  EOH
end

Chef::Log.info "ceilometer-api install complete"

