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
string, err = cidr.to_str(struct[, flags])
```

Takes in a CIDR structure, and generates up a human-readable string describing the netblock. In case of failures, returns `nil` and a string describing the error.

#### Flags

An optional second argument accepts flags that can be used to control the string output format. Constants for each flag are available under `cidr.flags`. Multiple flags can be combined as a bitmask. The available flags are:

- `NOFLAGS`: A stand-in for when you just want the default output
- `NOCOMPACT`: Don't do ::-style IPv6 compaction
- `VERBOSE`: Show leading 0's in octets [v6 only]
- `USEV6`: Use IPv4-mapped address form for IPv4 addresses (::ffff:a.b.c.d)
- `USEV4COMPAT`: Use IPv4-compat form (::a.b.c.d) instead of IPv4-mapped form (only meaningful in combination with CIDR_USEV6)
- `NETMASK`: Return a netmask in standard form after the slash, instead of the prefix length. Note that the form of the netmask can thus be altered by the various flags that alter how the address is displayed.
- `ONLYADDR`: Show only the address, without the prefix/netmask
- `ONLYPFLEN`: Show only the prefix length (or netmask, when combined with CIDR_NETMASK), without the address.
- `WILDCARD`: Show a Cisco-style wildcard mask instead of the netmask (only meaningful in combination with CIDR_NETMASK)
- `FORCEV6`: Forces treating the CIDR as an IPv6 address, no matter what it really is. This doesn't do any conversion or translation; just treats the raw data as if it were IPv6.
- `FORCEV4`: Forces treating the CIDR as an IPv4 address, no matter what it really is. This doesn't do any conversion or translation; just treats the raw data as if it were IPv4.
- `REVERSE`: Generates a .in-addr.arpa or .ip6.arpa-style PTR record name for the given block. Note that this always treats it solely as an address; the netmask is ignored. See some notes in cidr_from_str() for details of the asymmetric treatment of this form of address representation relating to the netmask.

Examples:

```lua
local cidr = require "libcidr-ffi"
local bit = require "bit"

cidr.to_str(cidr.from_str("127.0.0.1"))
-- "127.0.0.1/32"

cidr.to_str(cidr.from_str("127.0.0.1"), cidr.flags.ONLYADDR)
-- "127.0.0.1"

cidr.to_str(cidr.from_str("127.0.0.1"), cidr.flags.USEV6)
-- "::ffff:127.0.0.1/128"

cidr.to_str(cidr.from_str("127.0.0.1"), bit.bor(cidr.flags.ONLYADDR, cidr.flags.USEV6))
-- "::ffff:127.0.0.1"

cidr.to_str(cidr.from_str("2001:db8::2:1"))
-- "2001:db8::2:1/128"

cidr.to_str(cidr.from_str("2001:db8::2:1"), cidr.flags.VERBOSE)
-- "2001:0db8::0002:0001/128"
```

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

### Release Process

To release a new version to LuaRocks and OPM:

- Ensure `CHANGELOG.md` is up to date.
- Update the `_VERSION` in `lib/libcidr-ffi.lua`.
- Update the `version` in `dist.ini`.
- Move the rockspec file to the new version number (`git mv libcidr-ffi-X.X.X-1.rockspec libcidr-ffi-X.X.X-1.rockspec`), and update the `version` and `tag` variables in the rockspec file.
- Commit and tag the release (`git tag -a vX.X.X -m "Tagging vX.X.X" && git push origin vX.X.X`).
- Run `make release VERSION=X.X.X`.
