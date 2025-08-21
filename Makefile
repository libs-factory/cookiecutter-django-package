# Cookiecutter Django Package Makefile
# Manages Cookiecutter Django package development and testing

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Default shell
SHELL := /bin/bash

# Colors for output
BLUE   := \033[0;34m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
NC     := \033[0m

# Directories
SRC_DIR      := src
TEST_DIR     := test
CLAUDE_DIR   := .claude

# ==============================================================================
# HELP & DEFAULT TARGET
# ==============================================================================
.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf "$(BLUE)Cookiecutter Django Package Makefile$(NC)\n\n"
	@printf "$(GREEN)Usage:$(NC)\n"
	@printf "  make [target] [VARIABLE=value ...]\n\n"
	@printf "\n$(GREEN)Utilities:$(NC)\n"
	@printf "  %-25s %s\n" "clean" "Clean temporary files"


# ==============================================================================
# UTILITIES
# ==============================================================================
.PHONY: clean
clean:
	@printf "$(BLUE)Cleaning temporary files...$(NC)\n"
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@printf "$(GREEN)✓ Cleaned!$(NC)\n"
