.ONESHELL:

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m

SUCCESS = \033[0;32m [SUCCESS]:
WARNING = \033[1;33m [WARNING]:
ERROR = \033[0;31m [ERROR]:
INFO = \033[1;37m [INFO]:
HINT = \033[3;37m

NC = \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Alias
PROJECT_NAME := {{ cookiecutter.project_slug }}


# Remove temporary files and caches
.PHONY: clean
clean:
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@find . -type f -name "*.pyd" -delete 2>/dev/null || true
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".coverage" -exec rm -rf {} + 2>/dev/null || true
	@rm -rf build/ 2>/dev/null || true
	@rm -rf dist/ 2>/dev/null || true
	@rm -rf .tox/ 2>/dev/null || true
	@rm -rf htmlcov/ 2>/dev/null || true
	@echo "${INFO} Cleaned up compiled files for $(PROJECT_NAME)${NC}"


# Install development dependencies and setup virtual environment
.PHONY: setup
setup:
	@echo "${INFO} Setting up $(PROJECT_NAME) development environment...${NC}"
	@pip install --upgrade pip
	@pip install --upgrade pip-tools
	@pip-compile
	@pip-sync requirements/requirements.txt
	@pip install -e .
	@echo "${SUCCESS} $(PROJECT_NAME) development environment ready!${NC}"


# Display help
.PHONY: help
help:
	@echo "============================================================================"
	@echo "                         ${GREEN}$(PROJECT_NAME) Makefile${NC}"
	@echo "============================================================================"
	@echo ""
	@echo "${YELLOW}Development Setup:${NC}"
	@echo "  ${GREEN}make ${YELLOW}setup${NC}               - Setup development environment"
	@echo ""
	@echo "${YELLOW}Utilities:${NC}"
	@echo "  ${GREEN}make ${YELLOW}clean${NC}             - Clean up compiled files"
