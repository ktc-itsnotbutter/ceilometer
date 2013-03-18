name "ceilometer-compute"
description "ceilometer compute role"
run_list(
  "recipe[ceilometer]",
  "role[ceilometer-default-role]"
)

default_attributes(
  {"ceilometer_module" => {
    "module" => "compute"
  }})
