name "workstation"
description "it's a workstation"

run_list [
  "recipe[xcode_command_line_tools]",
  "recipe[homebrew]",
  "recipe[ruby]"
]

override_attributes(
  "xquartz" => {
    "url" => "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.2.dmg"
  }
)
