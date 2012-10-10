name "workstation"
description "it's a workstation"
run_list ["recipe[xcode_command_line_tools]", "recipe[homebrew]"]
