name "workstation"
description "it's a workstation"

run_list [
  # Stuff to build other stuff
  "recipe[xcode_command_line_tools]",
  "recipe[homebrew]",
  "recipe[gcc42]",
  "recipe[xquartz]",

  # Ruby! Ruby! Ruby!
  "recipe[rvm::user]",

  # StreetEasy: The Musical
  "recipe[apps::streeteasy]"
]

override_attributes(
  "build-essential" => {
    "osx" => {
      "gcc_installer_checksum" => "744fcc34be7da9206adc494d25ecd92bf9d8a4118588cc3e0464788b2a665493"
    }
  },

  "rvm" => {
    "user_installs" => [
      {
        "user"         => "jd",
        "default_ruby" => "",
        "rubies"       => ["1.9.3", "ree"]
      }
    ]
  },

  "xquartz" => {
    "version" => "2.7.4",
    "url" => "http://xquartz.macosforge.org/downloads/SL/XQuartz-2.7.4.dmg",
    "checksum" => "3f7c156fc4b13e3f0d0e44523ef2bd3cf7ea736126616dd2da28abb31840923c"
  },

  "mysql" => {
    "client" => {
      "packages" => ["mysql"]
    },
    "server_root_password" => ""
  }
)
