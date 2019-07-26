.PHONY: build test clean doc user-install user-uninstall

# Default names for installation directories:
#
tool_dir     = luxtorpeda
tool_dir_dev = luxtorpeda-dev

files = compatibilitytool.vdf \
	toolmanifest.vdf \
	packages.json \
	luxtorpeda \
	LICENSE \
	README.md

ifeq ($(origin XDG_DATA_HOME), undefined)
	data_home := ${HOME}/.local/share
else
	data_home := ${XDG_DATA_HOME}
endif

dev_install_dir = $(data_home)/Steam/compatibilitytools.d/$(tool_dir_dev)


build:
	cargo build

release:
	cargo build --release

lint:
	cargo clippy -- -D warnings

test:
	cargo test

clean:
	cargo clean

doc:
	cargo doc --document-private-items --open

target/debug/%: %
	cp --reflink=auto $< $@

target/release/%: %
	cp --reflink=auto $< $@

$(tool_dir).tar.xz: release \
	            target/release/compatibilitytool.vdf \
	            target/release/toolmanifest.vdf \
	            target/release/packages.json \
	            target/release/LICENSE \
	            target/release/README.md
	mkdir -p $(tool_dir)
	cd target/release && cp --reflink=auto -t ../../$(tool_dir) $(files)
	strip luxtorpeda/luxtorpeda
	tar -cJf $@ $(tool_dir)
	rm -rf $(tool_dir)

user-install: build \
	      target/debug/compatibilitytool.vdf \
	      target/debug/toolmanifest.vdf \
	      target/debug/packages.json \
	      target/debug/LICENSE \
	      target/debug/README.md
	mkdir -p $(dev_install_dir)
	cd target/debug && cp --reflink=auto -t $(dev_install_dir) $(files)

user-uninstall:
	rm -rf $(dev_install_dir)

check-formatting:
	cargo fmt -- --check
