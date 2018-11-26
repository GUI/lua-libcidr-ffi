.PHONY: all lint test install-test-deps install-deps-apt install-deps-source-yum install-deps-source release

all:

lint:
	luacheck .

test: lint
	luarocks make --local libcidr-ffi-git-1.rockspec
	busted spec --shuffle

install-test-deps:
	luarocks install busted 2.0.rc13-0
	luarocks install luacheck 0.22.1-1

install-deps-apt:
	apt-get update
	apt-get -y install libcidr-dev

install-deps-source-yum:
	yum -y install gcc

install-deps-source:
	$(eval tmpdir := $(shell mktemp -d))
	cd "$(tmpdir)" && curl -OL "https://www.over-yonder.net/~fullermd/projects/libcidr/libcidr-1.2.3.tar.xz"
	cd "$(tmpdir)" && tar -xvf libcidr-1.2.3.tar.xz
	cd "$(tmpdir)/libcidr-1.2.3" && make
	cd "$(tmpdir)/libcidr-1.2.3" && make install
	rm -rf "$(tmpdir)"

release:
	# Ensure the version number has been updated.
	grep -q -F 'VERSION = "${VERSION}"' lib/libcidr-ffi.lua
	# Ensure the OPM version number has been updated.
	grep -q -F 'version = ${VERSION}' dist.ini
	# Ensure the rockspec has been renamed and updated.
	grep -q -F 'version = "${VERSION}-1"' "libcidr-ffi-${VERSION}-1.rockspec"
	grep -q -F 'tag = "v${VERSION}"' "libcidr-ffi-${VERSION}-1.rockspec"
	# Ensure the CHANGELOG has been updated.
	grep -q -F '## ${VERSION} -' CHANGELOG.md
	# Make sure tests pass.
	docker-compose run --rm -v "${PWD}:/app" app make test
	# Check for remote tag.
	git ls-remote -t | grep -F "refs/tags/v${VERSION}^{}"
	# Verify LuaRock and OPM can be built locally.
	docker-compose run --rm -v "${PWD}:/app" app luarocks pack "libcidr-ffi-${VERSION}-1.rockspec"
	docker-compose run --rm -v "${HOME}/.opmrc:/root/.opmrc" -v "${PWD}:/app" app opm build
	# Upload to LuaRocks and OPM.
	docker-compose run --rm -v "${HOME}/.luarocks/upload_config.lua:/root/.luarocks/upload_config.lua" -v "${PWD}:/app" app luarocks upload "libcidr-ffi-${VERSION}-1.rockspec"
	docker-compose run --rm -v "${HOME}/.opmrc:/root/.opmrc" -v "${PWD}:/app" app opm upload
