name "ceilometer-default-role"
description "ceilometer default role"

default_attributes(
  {"ceilometer" => {
    #"auth_uri" => "http://14.63.205.38:5000/v2.0",
    #"os_username" => "admin",
    #"tenant_name" => "admin",
    #"os_password" => "password",
    #"sql_connection" => "mysql://nova:password@14.63.205.38/nova",
    "database_connection" => "mongodb://localhost:27017/ceilometer",
    #"rabbit_ip" => "14.63.205.38",
    "rabbit_password" => "password",
    "auth_protocol" => "http"
  }}
)
