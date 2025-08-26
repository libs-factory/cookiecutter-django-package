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

# Project configuration
PROJECT_NAME := {{cookiecutter.project_slug}}
APP_NAME := {{cookiecutter.app_slug}}

# ==============================================================================
# SETUP & INSTALLATION
# ==============================================================================

# Complete development environment setup
.PHONY: setup
setup:
	@echo "${INFO} Setting up $(PROJECT_NAME) development environment...${NC}"
	@pip install --upgrade pip
	@pip install --upgrade pip-tools
	@pip-compile
	@pip-sync requirements/requirements.txt
	@pip install -e .{% if cookiecutter.use_cypress == "yes" %}
	@echo "${INFO} Setting up E2E testing with Cypress...${NC}"
	@if [ -d "sandbox/tests/e2e" ]; then \
		cd sandbox/tests/e2e && npm install && cd ../../..; \
		echo "${INFO} Installing Cypress binary...${NC}"; \
		cd sandbox/tests/e2e && npx cypress install && cd ../../..; \
		echo "${INFO} Verifying Cypress installation...${NC}"; \
		cd sandbox/tests/e2e && npx cypress verify && cd ../../..; \
		echo "${SUCCESS} Cypress E2E testing ready!${NC}"; \
	fi{% endif %}
	@echo "${SUCCESS} $(PROJECT_NAME) development environment ready!${NC}"

# ==============================================================================
# DJANGO COMMANDS
# ==============================================================================

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

# Django shell with debug mode
.PHONY: run-debug-shell
run-debug-shell:
	@echo "${INFO} Opening Django shell_plus (DEBUG=True)...${NC}"
	@DEBUG=1 python sandbox/manage.py shell_plus --ipython

# Django shell
.PHONY: run-shell
run-shell:
	@echo "${INFO} Opening Django shell...${NC}"
	@python sandbox/manage.py shell

# Create new migrations
.PHONY: makemigrations
makemigrations:
	@echo "${INFO} Creating new migrations...${NC}"
	@python sandbox/manage.py makemigrations

# Apply database migrations
.PHONY: migrate
migrate:
	@echo "${INFO} Applying database migrations...${NC}"
	@python sandbox/manage.py migrate

# Collect static files
.PHONY: collectstatic
collectstatic:
	@echo "${INFO} Collecting static files...${NC}"
	@python sandbox/manage.py collectstatic --noinput
	@echo "${SUCCESS} Static files collected to staticfiles/${NC}"

# Create Django superuser
.PHONY: createsuperuser
createsuperuser:
	@echo "${INFO} Creating Django superuser...${NC}"
	@python sandbox/manage.py createsuperuser

# ==============================================================================
# TESTING
# ==============================================================================

# Run tests with coverage
.PHONY: test
test:
	@echo "${INFO} Running tests with coverage for $(PROJECT_NAME)...${NC}"
	@cd sandbox && \
	DJANGO_SETTINGS_MODULE=config.settings pytest --cov=../$(APP_NAME) --cov-report=html --cov-report=term tests/ && \
	cd ..
	@echo "${SUCCESS} Tests completed!${NC}"

# Run tests with coverage (verbose)
.PHONY: test-verbose
test-verbose:
	@echo "${INFO} Running tests with coverage (verbose) for $(PROJECT_NAME)...${NC}"
	@cd sandbox && \
	DJANGO_SETTINGS_MODULE=config.settings pytest -vv --cov=../$(APP_NAME) --cov-report=html --cov-report=term tests/ && \
	cd ..
	@echo "${SUCCESS} Tests completed!${NC}"

{% if cookiecutter.use_cypress == "yes" %}
# ==============================================================================
# E2E TESTING WITH CYPRESS
# ==============================================================================

# Install E2E test dependencies (included in 'make setup')
.PHONY: e2e-install
e2e-install:
	@echo "${INFO} Installing E2E test dependencies...${NC}"
	@if [ -d "sandbox/tests/e2e" ]; then \
		cd sandbox/tests/e2e && npm install && cd ../../..; \
		echo "${INFO} Installing Cypress binary...${NC}"; \
		cd sandbox/tests/e2e && npx cypress install && cd ../../..; \
		echo "${INFO} Verifying Cypress installation...${NC}"; \
		cd sandbox/tests/e2e && npx cypress verify && cd ../../..; \
		echo "${SUCCESS} E2E dependencies installed${NC}"; \
	else \
		echo "${ERROR} E2E test directory not found at sandbox/tests/e2e${NC}"; \
		exit 1; \
	fi

# Open Cypress interactive mode
.PHONY: e2e-open
e2e-open:
	@echo "${INFO} Checking Cypress installation...${NC}"
	@if [ ! -d "sandbox/tests/e2e/node_modules" ]; then \
		echo "${WARNING} Cypress not installed. Installing now...${NC}"; \
		$(MAKE) e2e-install; \
	fi
	@echo "${INFO} Starting Django server and opening Cypress...${NC}"
	@python sandbox/manage.py runserver --noreload & \
	SERVER_PID=$$!; \
	sleep 3; \
	(cd sandbox/tests/e2e && npm run cy:open); \
	TEST_EXIT_CODE=$$?; \
	kill $$SERVER_PID 2>/dev/null || true; \
	exit $$TEST_EXIT_CODE

# Run E2E tests headlessly
.PHONY: e2e-run
e2e-run:
	@echo "${INFO} Checking Cypress installation...${NC}"
	@if [ ! -d "sandbox/tests/e2e/node_modules" ]; then \
		echo "${WARNING} Cypress not installed. Installing now...${NC}"; \
		$(MAKE) e2e-install; \
	fi
	@echo "${INFO} Running E2E tests headlessly...${NC}"
	@python sandbox/manage.py runserver --noreload & \
	SERVER_PID=$$!; \
	sleep 3; \
	(cd sandbox/tests/e2e && npm run cy:run); \
	TEST_EXIT_CODE=$$?; \
	kill $$SERVER_PID 2>/dev/null || true; \
	exit $$TEST_EXIT_CODE

# Run E2E tests with browser visible
.PHONY: e2e-watch
e2e-watch:
	@echo "${INFO} Checking Cypress installation...${NC}"
	@if [ ! -d "sandbox/tests/e2e/node_modules" ]; then \
		echo "${WARNING} Cypress not installed. Installing now...${NC}"; \
		$(MAKE) e2e-install; \
	fi
	@echo "${INFO} Running E2E tests with browser...${NC}"
	@python sandbox/manage.py runserver --noreload & \
	SERVER_PID=$$!; \
	sleep 3; \
	(cd sandbox/tests/e2e && npx cypress run --headed); \
	TEST_EXIT_CODE=$$?; \
	kill $$SERVER_PID 2>/dev/null || true; \
	exit $$TEST_EXIT_CODE

# Debug mode with video recording
.PHONY: e2e-debug
e2e-debug:
	@echo "${INFO} Checking Cypress installation...${NC}"
	@if [ ! -d "sandbox/tests/e2e/node_modules" ]; then \
		echo "${WARNING} Cypress not installed. Installing now...${NC}"; \
		$(MAKE) e2e-install; \
	fi
	@if ! which ffmpeg > /dev/null 2>&1; then \
		echo "${WARNING} ffmpeg is not installed. Video recording will not work.${NC}"; \
		echo "${HINT} To install ffmpeg, run: sudo apt-get update && sudo apt-get install -y ffmpeg${NC}"; \
		echo "${INFO} Running tests with screenshots only...${NC}"; \
	else \
		echo "${INFO} Running E2E tests with video recording...${NC}"; \
	fi
	@python sandbox/manage.py runserver --noreload & \
	SERVER_PID=$$!; \
	sleep 3; \
	(cd sandbox/tests/e2e && CYPRESS_video=true npx cypress run); \
	TEST_EXIT_CODE=$$?; \
	kill $$SERVER_PID 2>/dev/null || true; \
	if [ -d "sandbox/tests/e2e/cypress/videos" ] && [ "$$(ls -A sandbox/tests/e2e/cypress/videos 2>/dev/null)" ]; then \
		echo "${SUCCESS} Videos saved in sandbox/tests/e2e/cypress/videos/${NC}"; \
		ls -la sandbox/tests/e2e/cypress/videos/; \
	elif [ -d "sandbox/tests/e2e/cypress/screenshots" ] && [ "$$(ls -A sandbox/tests/e2e/cypress/screenshots 2>/dev/null)" ]; then \
		echo "${INFO} Screenshots saved in sandbox/tests/e2e/cypress/screenshots/${NC}"; \
		ls -la sandbox/tests/e2e/cypress/screenshots/; \
	else \
		echo "${INFO} Tests completed. No media artifacts were generated.${NC}"; \
	fi; \
	exit $$TEST_EXIT_CODE

# Alias for e2e-run
.PHONY: e2e-test
e2e-test: e2e-run{% endif %}

# ==============================================================================
# CLEANUP
# ==============================================================================

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
	@echo "${INFO} Cleaned up compiled files for $(PROJECT_NAME)${NC}"{% if cookiecutter.use_cypress == "yes" %}
	@rm -rf sandbox/tests/e2e/cypress/videos 2>/dev/null || true
	@rm -rf sandbox/tests/e2e/cypress/screenshots 2>/dev/null || true
	@rm -rf sandbox/tests/e2e/cypress/downloads 2>/dev/null || true
	@echo "${INFO} Cleaned up E2E test artifacts${NC}"{% endif %}

# ==============================================================================
# HELP
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
	@echo "  ${GREEN}make ${YELLOW}run-debug-server${NC}     - Run Django development server (DEBUG=True)"
	@echo "  ${GREEN}make ${YELLOW}run-server${NC}            - Run Django server (DEBUG=False)"
	@echo "  ${GREEN}make ${YELLOW}killserver${NC}            - Kill any running Django server processes"
	@echo "  ${GREEN}make ${YELLOW}run-debug-shell${NC}       - Open Django shell_plus (DEBUG=True)"
	@echo "  ${GREEN}make ${YELLOW}run-shell${NC}             - Open Django shell"
	@echo "  ${GREEN}make ${YELLOW}makemigrations${NC}        - Create new migrations"
	@echo "  ${GREEN}make ${YELLOW}migrate${NC}               - Apply database migrations"
	@echo "  ${GREEN}make ${YELLOW}collectstatic${NC}         - Collect static files for production"
	@echo "  ${GREEN}make ${YELLOW}createsuperuser${NC}       - Create Django superuser"
	@echo ""
	@echo "${YELLOW}Testing:${NC}"
	@echo "  ${GREEN}make ${YELLOW}test${NC}                 - Run tests with coverage"
	@echo "  ${GREEN}make ${YELLOW}test-verbose${NC}          - Run tests with coverage (verbose)"{% if cookiecutter.use_cypress == "yes" %}
	@echo ""
	@echo "${YELLOW}E2E Testing:${NC}"
	@echo "  ${GREEN}make ${YELLOW}e2e-install${NC}          - Install E2E test dependencies"
	@echo "  ${GREEN}make ${YELLOW}e2e-open${NC}             - Open Cypress interactive mode"
	@echo "  ${GREEN}make ${YELLOW}e2e-run${NC}              - Run E2E tests headlessly"
	@echo "  ${GREEN}make ${YELLOW}e2e-watch${NC}            - Run E2E tests with browser visible"
	@echo "  ${GREEN}make ${YELLOW}e2e-debug${NC}            - Run tests with video recording"
	@echo "  ${GREEN}make ${YELLOW}e2e-test${NC}             - Alias for e2e-run"{% endif %}
	@echo ""
	@echo "${YELLOW}Utilities:${NC}"
	@echo "  ${GREEN}make ${YELLOW}clean${NC}                - Clean up compiled files"
	@echo "  ${GREEN}make ${YELLOW}help${NC}                 - Display this help message"
