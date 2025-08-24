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
TMP_DIR := ./.tmp

# ==============================================================================
# HELP & DEFAULT TARGET
# ==============================================================================
.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf "$(BLUE)Cookiecutter Django Package Makefile$(NC)\n\n"
	@printf "$(GREEN)Usage:$(NC)\n"
	@printf "  make [target] [VARIABLE=value ...]\n\n"
	@printf "\n$(GREEN)Mock testing:$(NC)\n"
	@printf "  %-25s %s\n" "mock-basic" "Generate basic mock project"
	@printf "  %-25s %s\n" "mock-all" "Generate all mock projects"
	@printf "  %-25s %s\n" "clean-mock" "Remove all mock projects"
	@printf "\n$(GREEN)Utilities:$(NC)\n"
	@printf "  %-25s %s\n" "clean" "Clean temporary files"
	@printf "  %-25s %s\n" "clean-all" "Clean everything including mock projects"

# ==============================================================================
# TESTING & MOCK PROJECTS
# ==============================================================================

# Each mock target is completely independent - no shared variables or functions
.PHONY: mock-basic
mock-basic: ## Generate basic mock project with minimal features
	@OUTPUT_DIR="$(TMP_DIR)"; \
	PROJECT_NAME="django-basic-package"; \
	PROJECT_SLUG="basic_package"; \
	rm -rf "$$OUTPUT_DIR"; \
	mkdir -p "$$(dirname $$OUTPUT_DIR)"; \
	printf "$(CYAN)Creating basic mock project: $$PROJECT_NAME$(NC)\n"; \
	cookiecutter . \
		--no-input \
		--overwrite-if-exists \
		--output-dir "$$OUTPUT_DIR" \
		project_name="$$PROJECT_NAME" \
		project_slug="$$PROJECT_NAME" \
		app_slug="$$PROJECT_SLUG" \
		description="A basic Django package" \
		author_name="Basic Author" \
		author_email="basic@test.com"; \
	printf "$(GREEN)✓ Basic mock created in $$OUTPUT_DIR/$$PROJECT_NAME$(NC)\n"

.PHONY: mock-all
mock-all: ## Generate all mock projects for comprehensive testing
	@$(MAKE) mock-basic
	@printf "$(GREEN)✓ All mock projects generated!$(NC)\n"

.PHONY: clean-mock
clean-mock: ## Remove all mock projects
	@printf "$(BLUE)Removing mock projects...$(NC)\n"
	@if [ -d "$(TMP_DIR)" ]; then \
		rm -rf $(TMP_DIR)/*; \
		printf "$(GREEN)✓ Mock projects removed!$(NC)\n"; \
	else \
		printf "$(YELLOW)→ No mock projects to remove$(NC)\n"; \
	fi

# ==============================================================================
# UTILITIES
# ==============================================================================
.PHONY: clean
clean: ## Clean all temporary files and caches
	@printf "$(BLUE)Cleaning temporary files...$(NC)\n"
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@printf "$(GREEN)✓ Cleaned!$(NC)\n"

.PHONY: clean-all
clean-all: clean clean-mock ## Clean everything including mock projects
	@printf "$(GREEN)✓ All temporary files and mock projects cleaned!$(NC)\n"
