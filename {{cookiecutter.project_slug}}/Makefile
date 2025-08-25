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
PROJECT_NAME := django-basic-package


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


# ==============================================================================
# Django Commands
# ==============================================================================
.PHONY: collectstatic
collectstatic:
	@echo "${INFO} Collecting static files...${NC}"
	@python sandbox/manage.py collectstatic --noinput
	@echo "${SUCCESS} Static files collected to staticfiles/${NC}"

# Django management commands
.PHONY: makemigrations
makemigrations:
	@echo "${INFO} Creating new migrations...${NC}"
	@python sandbox/manage.py makemigrations

.PHONY: migrate
migrate:
	@echo "${INFO} Applying database migrations...${NC}"
	@python sandbox/manage.py migrate

.PHONY: createsuperuser
createsuperuser:
	@echo "${INFO} Creating Django superuser...${NC}"
	@python sandbox/manage.py createsuperuser

# Run Django development server with DEBUG=True
.PHONY: run-debug-server
run-debug-server:
	@echo "${INFO} Starting Django development server (DEBUG=True)...${NC}"
	@DEBUG=1 python sandbox/manage.py runserver

# Run Django server with DEBUG=False (production-like)
.PHONY: run-server
run-server: collectstatic
	@echo "${INFO} Starting Django server (DEBUG=False)...${NC}"
	@echo "${HINT} Static files will be served by WhiteNoise${NC}"
	@python sandbox/manage.py runserver

.PHONY: run-debug-shell
run-debug-shell:
	@echo "${INFO} Opening Django shell_plus...${NC}"
	@DEBUG=1 python sandbox/manage.py shell_plus --ipython

.PHONY: run-shell
run-shell:
	@echo "${INFO} Opening Django shell...${NC}"
	@python sandbox/manage.py shell

# Kill any running Django server processes
.PHONY: killserver
killserver:
	@echo "${INFO} Stopping Django server processes...${NC}"
	@if pgrep -f "manage.py runserver" > /dev/null; then \
		pkill -f "manage.py runserver" && \
		echo "${SUCCESS} Django server stopped${NC}"; \
	else \
		echo "${WARNING} No Django server process found${NC}"; \
	fi
	@# Also kill any orphaned Python processes on port 8000
	@if lsof -Pi :8000 -sTCP:LISTEN -t > /dev/null 2>&1; then \
		lsof -Pi :8000 -sTCP:LISTEN -t | xargs kill -9 2>/dev/null && \
		echo "${SUCCESS} Killed process on port 8000${NC}"; \
	fi


# ==============================================================================
# TESTING & MOCK PROJECTS
# ==============================================================================
# Run tests with coverage
.PHONY: test
test:
	@echo "${INFO} Running tests with coverage for $(PROJECT_NAME)...${NC}"
	@cd sandbox && \
	DJANGO_SETTINGS_MODULE=config.settings pytest --cov=../{{cookiecutter.app_slug}} --cov-report=html --cov-report=term tests/ && \
	cd ..
	@echo "${SUCCESS} Tests completed!${NC}"

# Run tests with coverage (verbose)
.PHONY: test-verbose
test-verbose:
	@echo "${INFO} Running tests with coverage (verbose) for $(PROJECT_NAME)...${NC}"
	@cd sandbox && \
	DJANGO_SETTINGS_MODULE=config.settings pytest -vv --cov=../{{cookiecutter.app_slug}} --cov-report=html --cov-report=term tests/ && \
	cd ..
	@echo "${SUCCESS} Tests completed!${NC}"


# ==============================================================================
# UTILITIES
# ==============================================================================
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
	@echo "${YELLOW}Django Commands:${NC}"
	@echo "  ${GREEN}make ${YELLOW}run-debug-server${NC}      - Run Django development server (DEBUG=True)"
	@echo "  ${GREEN}make ${YELLOW}run-server${NC}         - Run Django server (DEBUG=False)"
	@echo "  ${GREEN}make ${YELLOW}run-debug-shell${NC}              - Open Django shell_plus (IPython) (DEBUG=True)"
	@echo "  ${GREEN}make ${YELLOW}run-shell${NC}              - Open Django shell_plus (IPython) (DEBUG=False)"
	@echo "  ${GREEN}make ${YELLOW}makemigrations${NC}     - Create new migrations"
	@echo "  ${GREEN}make ${YELLOW}migrate${NC}            - Apply database migrations"
	@echo "  ${GREEN}make ${YELLOW}collectstatic${NC}      - Collect static files for production"
	@echo "  ${GREEN}make ${YELLOW}createsuperuser${NC}    - Create Django superuser"
	@echo "  ${GREEN}make ${YELLOW}killserver${NC}         - Kill any running Django server processes"
	@echo ""
	@echo "${YELLOW}Testing:${NC}"
	@echo "  ${GREEN}make ${YELLOW}test${NC}              - Run tests with coverage"
	@echo "  ${GREEN}make ${YELLOW}test-verbose${NC}      - Run tests with coverage (verbose)"
	@echo ""
	@echo "${YELLOW}Utilities:${NC}"
	@echo "  ${GREEN}make ${YELLOW}clean${NC}             - Clean up compiled files"
