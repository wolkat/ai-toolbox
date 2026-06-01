STOW_PACKAGES := opencode codex copilot
TARGET := $(HOME)/.config/opencode
CODEX_TARGET := $(HOME)/.codex
COPILOT_TARGET := $(HOME)/.copilot

.PHONY: install uninstall status restow check help lint-skill todo-scan track-usage track-kpi verify-plugin

check:
	@command -v stow >/dev/null 2>&1 || (echo "stow not installed" && exit 1)
	@test -d opencode || (echo "opencode package not found" && exit 1)
	@test -d codex || (echo "codex package not found" && exit 1)
	@test -d copilot || (echo "copilot package not found" && exit 1)
	@echo "Setup verified"

install: check
	@stow -t $(TARGET) opencode
	@stow -t $(CODEX_TARGET) codex
	@stow -t $(COPILOT_TARGET) copilot
	@echo "Installed: opencode -> $(TARGET)"
	@echo "Installed: codex -> $(CODEX_TARGET)"
	@echo "Installed: copilot -> $(COPILOT_TARGET)"

install-opencode:
	@stow -t $(TARGET) opencode
	@echo "Installed: opencode -> $(TARGET)"

install-codex:
	@stow -t $(CODEX_TARGET) codex
	@echo "Installed: codex -> $(CODEX_TARGET)"

install-copilot:
	@stow -t $(COPILOT_TARGET) copilot
	@echo "Installed: copilot -> $(COPILOT_TARGET)"

uninstall:
	@stow -t $(TARGET) -D opencode
	@stow -t $(CODEX_TARGET) -D codex
	@stow -t $(COPILOT_TARGET) -D copilot
	@echo "Uninstalled: opencode"
	@echo "Uninstalled: codex"
	@echo "Uninstalled: copilot"

uninstall-opencode:
	@stow -t $(TARGET) -D opencode
	@echo "Uninstalled: opencode"

uninstall-codex:
	@stow -t $(CODEX_TARGET) -D codex
	@echo "Uninstalled: codex"

uninstall-copilot:
	@stow -t $(COPILOT_TARGET) -D copilot
	@echo "Uninstalled: copilot"

restow: uninstall install
	@echo "Restowed: opencode, codex, copilot"

restow-opencode: uninstall-opencode install-opencode
	@echo "Restowed: opencode"

restow-codex: uninstall-codex install-codex
	@echo "Restowed: codex"

restow-copilot: uninstall-copilot install-copilot
	@echo "Restowed: copilot"

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
	@echo ""
	@echo "=== Copilot ==="
	@echo "Package: copilot"
	@echo "Target: $(COPILOT_TARGET)"
	@echo ""
	@echo "Symlinks:"
	@find copilot -type d | while read d; do \
		dst="$${d#copilot/}"; \
		if [ -L "$(COPILOT_TARGET)/$$dst" ]; then \
			echo "  -> $$dst"; \
		elif [ -e "$(COPILOT_TARGET)/$$dst" ]; then \
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

status-copilot:
	@echo "=== Copilot ==="
	@echo "Package: copilot"
	@echo "Target: $(COPILOT_TARGET)"
	@echo ""
	@echo "Symlinks:"
	@find copilot -type d | while read d; do \
		dst="$${d#copilot/}"; \
		if [ -L "$(COPILOT_TARGET)/$$dst" ]; then \
			echo "  -> $$dst"; \
		elif [ -e "$(COPILOT_TARGET)/$$dst" ]; then \
			echo "  ++ $$dst (real dir)"; \
		else \
			echo "  !! $$dst (not linked)"; \
		fi; \
	done

help:
	@echo "ai-toolbox stow commands:"
	@echo "  make install        - symlink opencode + codex + copilot to ~"
	@echo "  make install-opencode  - symlink opencode to ~/.config/opencode"
	@echo "  make install-codex     - symlink codex to ~/.codex"
	@echo "  make uninstall      - remove opencode + codex + copilot symlinks"
	@echo "  make uninstall-opencode - remove opencode symlinks"
	@echo "  make uninstall-codex   - remove codex symlinks"
	@echo "  make restow         - refresh opencode + codex + copilot symlinks"
	@echo "  make restow-opencode   - refresh opencode symlinks"
	@echo "  make restow-codex      - refresh codex symlinks"
	@echo "  make status         - show status for opencode + codex + copilot"
	@echo "  make status-opencode   - show opencode symlink status"
	@echo "  make status-codex      - show codex symlink status"
	@echo "  make check          - verify stow + packages"
	@echo "  make install-copilot   - symlink copilot to ~/.copilot"
	@echo "  make uninstall-copilot - remove copilot symlinks"
	@echo "  make restow-copilot    - refresh copilot symlinks"
	@echo "  make status-copilot    - show copilot symlink status"
	@echo ""
	@echo "script commands:"
	@echo "  make lint-skill     - lint all OpenCode skill markdown files"
	@echo "  make todo-scan      - scan repos for unfinished work"
	@echo "  make track-usage    - survey CLI tool usage from shell history"
	@echo "  make track-kpi      - generate KPI report for skill effectiveness"
	@echo "  make verify-plugin  - validate OpenCode plugin configurations"

lint-skill:
	@bash scripts/lint-skill.sh --all

todo-scan:
	@bash scripts/todo-scan.sh

track-usage:
	@bash scripts/track-tool-usage.sh

track-kpi:
	@bash scripts/track-kpi.sh --report

verify-plugin:
	@bash scripts/verify-plugin.sh