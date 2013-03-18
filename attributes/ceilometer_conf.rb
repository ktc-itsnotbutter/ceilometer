# user group to be used for install
default['ceilometer']['user']                 = "root"
default['ceilometer']['group']                = "root"

# swift setting
default['ceilometer']['swift_conf_dir']       = "/etc/swift"
default['ceilometer']['swift_conf']           = "/etc/swift/proxy-server.conf"
default['ceilometer']['use_swift']            = "yes"

# environment setting
default['ceilometer']['os_username']          = "admin"
default['ceilometer']['os_tenant_name']       = "admin"
default['ceilometer']['os_password']          = "password"
default['ceilometer']['os_auth_url']          = "http://14.63.205.39:5000/v2.0"

# nova setting
default['ceilometer']['nova_dir']             = "/opt/nova"
default['ceilometer']['nova_conf_dir']        = "/etc/nova"
default['ceilometer']['nova_conf']            = "/etc/nova/nova.conf"

# keystone setting
default['ceilometer']['keystone_dir']         = "/opt/keystone"
default['ceilometer']['keystone_conf_dir']    = "/etc/keystone"
default['ceilometer']['keystone_conf']        = "/etc/keystone/keystone.conf"

# mysql setting : mysql://nova:password@14.63.205.38/nova
default['ceilometer']['mysql_db']['nova_user']= "nova"
default['ceilometer']['mysql_db']['nova_database_name'] = "nova"
default['ceilometer']['mysql_db']['password'] = "password"

default['ceilometer']['mysql_db']['keystone_user']= "keystone"
default['ceilometer']['mysql_db']['keystone_database_name'] = "keystone"
default['ceilometer']['mysql_db']['password'] = "password"


# mongodb setting: mongodb://127.0.0.1:27017/ceilometer
default['ceilometer']['mongo_db']['dbs_name'] = "ceilometer"
default['ceilometer']['mongo_db']['user']     = nil
default['ceilometer']['mongo_db']['password'] = nil
default['ceilometer']['mongo_db']['scheme']   = "mongodb"

