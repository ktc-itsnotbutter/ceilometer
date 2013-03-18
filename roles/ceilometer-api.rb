name "ceilometer-api"
description "ceilometer api role"
run_list(
  "recipe[ceilometer]",
  "role[ceilometer-default-role]"
)

default_attributes(
  {"ceilometer_module" => {
    "module" => "api"
  }})

