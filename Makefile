PREFIX ?= $(HOME)/.local

.PHONY: install uninstall check package release clean

install:
	./install.sh

uninstall:
	./uninstall.sh

check:
	bash -n bin/hermeskey bin/hermeskey-doctor install.sh uninstall.sh scripts/check.sh scripts/build-release.sh scripts/bootstrap.sh scripts/release.sh
	python3 -m py_compile bin/hermeskey-server.py bin/hermeskey-overlay.py

package:
	./scripts/build-release.sh

release:
	./scripts/release.sh

clean:
	rm -rf dist
