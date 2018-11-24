# lua-libcidr-ffi

[![Circle CI](https://circleci.com/gh/GUI/lua-libcidr-ffi.svg?style=svg)](https://circleci.com/gh/GUI/lua-libcidr-ffi)

LuaJIT FFI bindings to [libcidr](http://www.over-yonder.net/~fullermd/projects/libcidr). Provides CIDR calculations for IPv4 and IPv6.

## Installation

To use lua-libcidr-ffi, [libcidr](#dependencies) must first be installed on your system. You can then install lua-libcidr-ffi via LuaRocks or OPM:

Via [LuaRocks](https://luarocks.org):

```sh
luarocks install libcidr-ffi
```

Or via [OPM](https://opm.openresty.org):

```sh
opm get GUI/lua-libcidr-ffi
```

### Dependencies

[libcidr](http://www.over-yonder.net/~fullermd/projects/libcidr) must be installed on your system. It can be installed via system packages (if available) or manually built from source:

**Packages:** If binary packages are available for your distribution (available on Ubuntu 18.04 Bionic and newer or Debian 10 Buster and newer):

```sh
apt-get install libcidr-dev
```

**Source:** For other distributions where binary packages are not available, libcidr can be installed from source:

```sh
curl -OL "https://www.over-yonder.net/~fullermd/projects/libcidr/libcidr-1.2.3.tar.xz"
tar -xf libcidr-1.2.3.tar.xz
cd libcidr-1.2.3
make
sudo make install
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

## Troubleshooting

### LuaRocks Installation: Could not find library

When performing the `luarocks install libcidr-ffi` command, if you receive an error indicating the libcidr library could not be found (`Could not find library file for CIDR`), then you can manually specify the location of the lib directory that contains the `libcidr.so` file by using the `CIDR_LIBDIR` argument. For example, if the library is installed in `/usr/local/lib/libcidr.so`:

```sh
luarocks install libcidr-ffi CIDR_LIBDIR=/usr/local/lib
```

### Runtime: Could not find library

When requiring the `libcidr-ffi` module in your Lua code, if you receive an error indicating the libcidr library could not be found (`libcidr.so: cannot open shared object file: No such file or directory`), then you can manually specify the location of the lib directory that contains the `libcidr.so` file by using the `LD_LIBRARY_PATH` environment variable. For example, if the library is installed in `/usr/local/lib/libcidr.so`:


```sh
export LD_LIBRARY_PATH=/usr/local/lib
luajit -e 'require "libcidr-ffi"'
```

## Development

After checking out the repo, Docker can be used to run the test suite:

```sh
docker-compose run --rm app make test
```
