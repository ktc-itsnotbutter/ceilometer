name "ceilometer-collector"
description "ceilometer collector role"
run_list(
  "recipe[ceilometer]",
  "role[ceilometer-default-role]"
)

default_attributes(
  {"ceilometer_module" => {
    "module" => "collector"
  }})

