# lua-libcidr-ffi

[![Circle CI](https://circleci.com/gh/GUI/lua-libcidr-ffi.svg?style=svg)](https://circleci.com/gh/GUI/lua-libcidr-ffi)

LuaJIT FFI bindings to [libcidr](http://www.over-yonder.net/~fullermd/projects/libcidr). Provides CIDR calculations for IPv4 and IPv6.

## Installation

The [libcidr](http://www.over-yonder.net/~fullermd/projects/libcidr) library must first be installed on your system. Then you can install lua-libcidr-ffi through [LuaRocks](https://luarocks.org):

```sh
$ luarocks install libcidr-ffi
```

## Usage

```lua
local cidr = require "libcidr-ffi"
cidr.contains(cidr.from_str("10.10.10.10/8"), cidr.from_str("10.20.30.40")) -- true
cidr.contains(cidr.from_str("10.10.10.10/16"), cidr.from_str("10.20.30.40")) -- false
cidr.contains(cidr.from_str("2001:db8::/32"), cidr.from_str("2001:db8:1234::1")) -- true
cidr.contains(cidr.from_str("2001:db8::/32"), cidr.from_str("2001:db9:1234::1")) -- false
```

## Functions

For more detailed documentation of function behavior, see [libcidr's own documentation](https://www.over-yonder.net/~fullermd/projects/libcidr/docs/1.2/libcidr-big.html). Currently, only bindings to a few of libcidr's functions are available in this Lua library, but other bindings could easily be added.

### `from_str`

```lua
struct, err = cidr.from_str(string)
```

Takes in a netblock description as a human-readable string, and creates a CIDR structure from it. In case of failures, returns `nil` and a string describing the error.

### `to_str`

```lua
string, err = cidr.to_str(struct)
```

Takes in a CIDR structure, and generates up a human-readable string describing the netblock. In case of failures, returns `nil` and a string describing the error.

### `contains`

```lua
bool = cidr.contains(big, small)
```

This function is passed two CIDR structures describing a pair of netblocks. It then determines if the latter is wholly contained within the former. In case of failures, returns `nil` and a string describing the error.

## Alternatives

- [lua-resty-iputils](https://github.com/hamishforbes/lua-resty-iputils): A pure Lua library for CIDR comparisons in OpenResty. Provides a nice higher-level API with built-in caching. Currently lacks IPv6 support.

## Development

After checking out the repo, Docker can be used to run the test suite:

```sh
docker-compose run --rm app make test
```
