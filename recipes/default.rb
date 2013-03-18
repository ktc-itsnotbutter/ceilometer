# Cookbook Name:: ceilometer_test
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#if platform_family?('ubuntu')

# install pythos-setuptools - check if not installed
include_recipe "ceilometer::common"


#selected_module = data_bag_item('ceilometer','install_module')
#install_module = selected_module['module']
install_module = "#{node[:ceilometer_module][:module]}"

Chef::Log.info "ceilometer install start => #{install_module}"

ENV['OS_TENANT_NAME']="#{node[:ceilometer][:tenant_name]}"
ENV['OS_USERNAME']="#{node[:ceilometer][:os_username]}"
ENV['OS_PASSWORD']="#{node[:ceilometer][:os_password]}"
ENV['OS_AUTH_URL']="#{node[:ceilometer][:auth_uri]}"

Chef::Log.info "======= Ceilometer Environment ======"
Chef::Log.info " tenant_name = #{node[:ceilometer][:tenant_name]}"
Chef::Log.info " username    = #{node[:ceilometer][:os_username]}"
Chef::Log.info " password    = #{node[:ceilometer][:os_password]}"
Chef::Log.info " auth_url    = #{node[:ceilometer][:auth_uri]}"

case install_module
when "collector"
  include_recipe "ceilometer::collector"
when "compute"
  include_recipe "ceilometer::compute"
when "central"
  include_recipe "ceilometer::central"
when "api"
  include_recipe "ceilometer::api"
else
  Chef::Log.info "install default package (ceilometer-api)"
  include_recipe "ceilometer::api"
end

Chef::Log.info "ceilometer install complete"



=======
>>>>>>> 51567841cfa2d86ea7c55f6cc7333e4071bbfc05
