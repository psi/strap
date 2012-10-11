name "workstation"
description "it's a workstation"

run_list [
  "recipe[xcode_command_line_tools]",
  "recipe[homebrew]",
  "recipe[ruby]"
]

override_attributes(
  "xquartz" => {
    "version" => "2.7.4",
    "url" => "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg",
    "checksum" => "3f7c156fc4b13e3f0d0e44523ef2bd3cf7ea736126616dd2da28abb31840923c"
  }
)
