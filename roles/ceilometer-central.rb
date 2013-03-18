name "ceilometer-central"
description "ceilometer central role"
run_list(
  "recipe[ceilometer]",
  "role[ceilometer-default-role]"
)

default_attributes(
  {"ceilometer_module" => {
    "module" => "central"
  }})

