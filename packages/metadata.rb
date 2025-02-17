name              "packages"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Helper library to determine whether distribution-only packages are installed"
version           "0.7"

attribute "packages",
  :display_name => "Packages",
  :description => "Hash of Packages attributes",
  :type => "hash"

attribute "packages/dist_only",
  :display_name => "Packages Distribution Only?",
  :description => "Set to only use distribution-provided packages",
  :default => "false"

