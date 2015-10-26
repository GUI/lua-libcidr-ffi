.PHONY: test

all:

test/tmp/libcidr-1.2.3/src/libcidr.so:
	rm -rf test/tmp/libcidr-*
	mkdir -p test/tmp
	cd test/tmp && curl -OL "https://www.over-yonder.net/~fullermd/projects/libcidr/libcidr-1.2.3.tar.xz"
	cd test/tmp && tar -xf libcidr-1.2.3.tar.xz
	cd test/tmp/libcidr-1.2.3 && make NO_DOCS=1 NO_EXAMPLES=1

test: test/tmp/libcidr-1.2.3/src/libcidr.so
	luarocks make --local libcidr-ffi-git-1.rockspec CIDR_LIBDIR=test/tmp/libcidr-1.2.3/src
	LD_LIBRARY_PATH=test/tmp/libcidr-1.2.3/src busted spec
