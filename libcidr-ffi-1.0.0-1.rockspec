package = "libcidr-ffi"
version = "1.0.0-1"
source = {
  url = "git://github.com/GUI/lua-libcidr-ffi.git",
  tag = "v1.0.0"
}
description = {
  summary = "libcidr bindings for Lua",
  detailed = "Perform various CIDR and IP address operations to check IPv4 and IPv6 ranges.",
  homepage = "https://github.com/GUI/lua-libcidr-ffi",
  license = "MIT",
}
external_dependencies = {
  CIDR = {
    library = "cidr",
  },
}
build = {
  type = "builtin",
  modules = {
    ["libcidr-ffi"] = "lib/libcidr-ffi.lua",
  },
}
