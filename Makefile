STOW_PACKAGES := opencode codex
TARGET := $(HOME)/.config/opencode
CODEX_TARGET := $(HOME)/.codex

.PHONY: install uninstall status restow check help

check:
	@command -v stow >/dev/null 2>&1 || (echo "stow not installed" && exit 1)
	@test -d opencode || (echo "opencode package not found" && exit 1)
	@test -d codex || (echo "codex package not found" && exit 1)
	@echo "Setup verified"

install: check
	@stow -t $(TARGET) opencode
	@stow -t $(CODEX_TARGET) codex
	@echo "Installed: opencode -> $(TARGET)"
	@echo "Installed: codex -> $(CODEX_TARGET)"

install-opencode:
	@stow -t $(TARGET) opencode
	@echo "Installed: opencode -> $(TARGET)"

install-codex:
	@stow -t $(CODEX_TARGET) codex
	@echo "Installed: codex -> $(CODEX_TARGET)"

uninstall:
	@stow -t $(TARGET) -D opencode
	@stow -t $(CODEX_TARGET) -D codex
	@echo "Uninstalled: opencode"
	@echo "Uninstalled: codex"

uninstall-opencode:
	@stow -t $(TARGET) -D opencode
	@echo "Uninstalled: opencode"

uninstall-codex:
	@stow -t $(CODEX_TARGET) -D codex
	@echo "Uninstalled: codex"

restow: uninstall install
	@echo "Restowed: opencode, codex"

restow-opencode: uninstall-opencode install-opencode
	@echo "Restowed: opencode"

restow-codex: uninstall-codex install-codex
	@echo "Restowed: codex"

status:
	@echo "=== OpenCode ==="
	@echo "Package: opencode"
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
	@echo ""
	@echo "=== Codex ==="
	@echo "Package: codex"
	@echo "Target: $(CODEX_TARGET)"
	@echo ""
	@echo "Symlinks:"
	@find codex -type d | while read d; do \
		dst="$${d#codex/}"; \
		if [ -L "$(CODEX_TARGET)/$$dst" ]; then \
			echo "  -> $$dst"; \
		elif [ -e "$(CODEX_TARGET)/$$dst" ]; then \
			echo "  ++ $$dst (real dir)"; \
		else \
			echo "  !! $$dst (not linked)"; \
		fi; \
	done

status-opencode:
	@echo "=== OpenCode ==="
	@echo "Package: opencode"
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

status-codex:
	@echo "=== Codex ==="
	@echo "Package: codex"
	@echo "Target: $(CODEX_TARGET)"
	@echo ""
	@echo "Symlinks:"
	@find codex -type d | while read d; do \
		dst="$${d#codex/}"; \
		if [ -L "$(CODEX_TARGET)/$$dst" ]; then \
			echo "  -> $$dst"; \
		elif [ -e "$(CODEX_TARGET)/$$dst" ]; then \
			echo "  ++ $$dst (real dir)"; \
		else \
			echo "  !! $$dst (not linked)"; \
		fi; \
	done

help:
	@echo "ai-toolbox stow commands:"
	@echo "  make install        - symlink opencode + codex to ~"
	@echo "  make install-opencode  - symlink opencode to ~/.config/opencode"
	@echo "  make install-codex     - symlink codex to ~/.codex"
	@echo "  make uninstall      - remove all symlinks"
	@echo "  make uninstall-opencode - remove opencode symlinks"
	@echo "  make uninstall-codex   - remove codex symlinks"
	@echo "  make restow         - refresh all symlinks"
	@echo "  make restow-opencode   - refresh opencode symlinks"
	@echo "  make restow-codex      - refresh codex symlinks"
	@echo "  make status         - show status for opencode + codex"
	@echo "  make status-opencode   - show opencode symlink status"
	@echo "  make status-codex      - show codex symlink status"
	@echo "  make check          - verify stow + packages"