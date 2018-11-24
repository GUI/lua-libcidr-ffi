.PHONY: lint test install-test-deps

all:

spec/tmp/libcidr-1.2.3/src/libcidr.so:
	rm -rf spec/tmp/libcidr-*
	mkdir -p spec/tmp
	cd spec/tmp && curl -OL "https://www.over-yonder.net/~fullermd/projects/libcidr/libcidr-1.2.3.tar.xz"
	cd spec/tmp && tar -xf libcidr-1.2.3.tar.xz
	cd spec/tmp/libcidr-1.2.3 && make NO_DOCS=1 NO_EXAMPLES=1

lint:
	luacheck .

test: lint spec/tmp/libcidr-1.2.3/src/libcidr.so
	luarocks make --local libcidr-ffi-git-1.rockspec CIDR_LIBDIR=spec/tmp/libcidr-1.2.3/src
	LD_LIBRARY_PATH=spec/tmp/libcidr-1.2.3/src busted spec

install-test-deps:
	luarocks install busted 2.0.rc13-0
	luarocks install luacheck 0.22.1-1
