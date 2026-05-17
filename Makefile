STOW_PACKAGES := opencode

.PHONY: install uninstall status restow check help

check:
	@command -v stow >/dev/null 2>&1 || (echo "stow not installed" && exit 1)
	@test -d opencode || (echo "opencode package not found" && exit 1)
	@echo "Setup verified"

install: check
	@stow -t ~ $(STOW_PACKAGES)
	@echo "Installed: $(STOW_PACKAGES)"

uninstall:
	@stow -D $(STOW_PACKAGES)
	@echo "Uninstalled: $(STOW_PACKAGES)"

restow: uninstall install
	@echo "Restowed: $(STOW_PACKAGES)"

status:
	@echo "Package: $(STOW_PACKAGES)"
	@echo "Target: ~"
	@echo ""
	@echo "Symlinks:"
	@find opencode -type f | while read f; do \
		dst="$${f#opencode/}"; \
		if [ -L "$$HOME/$$dst" ]; then \
			echo "  -> $$dst"; \
		else \
			echo "  !! $$dst (not linked)"; \
		fi; \
	done

help:
	@echo "ai-toolbox stow commands:"
	@echo "  make install    - symlink local items to ~"
	@echo "  make uninstall  - remove symlinks"
	@echo "  make restow     - refresh symlinks"
	@echo "  make status     - show symlink status"