STOW_PACKAGES := opencode
TARGET := $(HOME)/.config/opencode

.PHONY: install uninstall status restow check help

check:
	@command -v stow >/dev/null 2>&1 || (echo "stow not installed" && exit 1)
	@test -d opencode || (echo "opencode package not found" && exit 1)
	@echo "Setup verified"

install: check
	@stow -t $(TARGET) $(STOW_PACKAGES)
	@echo "Installed: $(STOW_PACKAGES) -> $(TARGET)"

uninstall:
	@stow -t $(TARGET) -D $(STOW_PACKAGES)
	@echo "Uninstalled: $(STOW_PACKAGES)"

restow: uninstall install
	@echo "Restowed: $(STOW_PACKAGES)"

status:
	@echo "Package: $(STOW_PACKAGES)"
	@echo "Target: $(TARGET)"
	@echo ""
	@echo "Symlinks:"
	@find opencode -type d | while read d; do \
		dst="$${d#opencode/}"; \
		if [ -L "$(TARGET)/$$dst" ]; then \
			echo "  -> $$dst"; \
		elif [ -e "$(TARGET)/$$dst" ]; then \
			echo "  ++ $$dst (real dir)"; \
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