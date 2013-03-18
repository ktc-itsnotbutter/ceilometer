#
# Cookbook Name:: ceilometer_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#if platform_family?('ubuntu')

bash "compute_last_progress" do
  user "root" 
  code <<-EOH 
    python /usr/local/bin/ceilometer-agent-compute --config-file #{node['ceilometer']['ceilometer_conf']} &
  EOH
end

Chef::Log.info "ceilometer-agent-compute install complete"
