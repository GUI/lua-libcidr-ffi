# lua-libcidr-ffi

LuaJIT FFI bindings to [libcidr](http://www.over-yonder.net/~fullermd/projects/libcidr). Provides CIDR calculations for IPv4 and IPv6.

```lua
local cidr = require "libcidr-ffi"
cidr.contains(cidr.from_str("10.10.10.10/8"), cidr.from_str("10.20.30.40")) -- true
cidr.contains(cidr.from_str("10.10.10.10/16"), cidr.from_str("10.20.30.40")) -- false
cidr.contains(cidr.from_str("2001:db8::/32"), cidr.from_str("2001:db8:1234::1")) -- true
cidr.contains(cidr.from_str("2001:db8::/32"), cidr.from_str("2001:db9:1234::1")) -- false
```
