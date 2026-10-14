PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check package release clean

install:
	./install.sh

uninstall:
	./uninstall.sh

check:
	./scripts/check.sh

package:
	./scripts/build-release.sh

release:
	./scripts/release.sh

clean:
	rm -rf dist
