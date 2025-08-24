#!/bin/bash

set -e

# ----------------------------------------
# Local Variables
# ----------------------------------------
FEATURE_DIR="/usr/local/share/riso-bootstrap"
PROJECT_NAME="{{cookiecutter.project_name}}"
PYTHON_VERSION="{{cookiecutter.python_version}}"

# Files to import from riso-bootstrap feature
IMPORT_FILES=(
    "$FEATURE_DIR/utils/layer-0/logger.sh:Logger utilities"
)

# Calculate total steps
BASE_STEPS=(
    "install_system_packages"
    "setup_python_environment"
)
TOTAL_STEPS={% raw %}${#BASE_STEPS[@]}{% endraw %}

# ----------------------------------------
# Import Utility Functions
# ----------------------------------------
import_utility_files() {
    local -n files_array=$1

    for file_info in {% raw %}"${files_array[@]}"{% endraw %}; do
        local file_path={% raw %}"${file_info%:*}"{% endraw %}
        local file_desc={% raw %}"${file_info#*:}"{% endraw %}

        if [ -f "$file_path" ]; then
            # shellcheck source=/dev/null disable=SC1091
            source {% raw %}"${file_path}"{% endraw %}
            log_debug "Imported: $file_desc from $file_path"
        else
            echo "Warning: Could not find $file_desc at $file_path" >&2
        fi
    done

    return 0
}

# Import utilities from riso-bootstrap
import_utility_files IMPORT_FILES

# ----------------------------------------
# Installation Functions
# ----------------------------------------

install_system_packages() {
    local step_id=$1
    set_step_context "install_system_packages"

    log_group_start "System Package Installation"

    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update

    # Development Tools (only missing ones)
    log_info "Installing development tools..."
    sudo apt-get install -y --no-install-recommends \
        cmake \
        pkg-config

    # Code Quality Tools
    log_info "Installing code quality tools..."
    sudo apt-get install -y --no-install-recommends \
        shellcheck

    # Network Tools (only missing ones)
    log_info "Installing network utilities..."
    sudo apt-get install -y --no-install-recommends \
        iputils-ping \
        dnsutils

    # Modern CLI Tools (only missing ones)
    log_info "Installing modern CLI tools..."
    sudo apt-get install -y --no-install-recommends \
        ripgrep \
        fd-find \
        fzf

    log_group_end "System Package Installation"
    log_success "System packages installed successfully"
}

setup_python_environment() {
    local step_id=$1
    set_step_context "setup_python_environment"

    log_group_start "Python Development Environment"

    # Python Runtime and Development Packages
    log_info "Installing Python runtime and development packages..."
    sudo apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev

    # Python Build Dependencies
    log_info "Installing Python build dependencies..."
    sudo apt-get install -y --no-install-recommends \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncursesw5-dev \
        tk-dev \
        libxml2-dev \
        libffi-dev \
        liblzma-dev

    # Install pyenv for Python version management
    log_info "Installing pyenv..."
    if ! command -v pyenv &> /dev/null; then
        curl https://pyenv.run | bash

        # Add pyenv to shell profiles
        PYENV_CONFIG='{% raw %}
# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
{% endraw %}'
        echo "$PYENV_CONFIG" >> ~/.bashrc

        # Add to .zshrc if it exists
        if [ -f ~/.zshrc ]; then
            echo "$PYENV_CONFIG" >> ~/.zshrc
        fi

        log_success "pyenv installed and configured"
    else
        log_notice "pyenv already installed"
    fi

    # Load pyenv in current shell
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    # Verify pyenv is available
    if command -v pyenv &> /dev/null; then
        eval "{% raw %}$(pyenv init -){% endraw %}"
        eval "{% raw %}$(pyenv virtualenv-init -){% endraw %}"
        log_success "pyenv environment loaded"
    else
        log_error "pyenv not found in PATH after installation"
        return 1
    fi

    # Install Python version for Django development
    log_info "Installing Python for Django development..."

    # Check if Python version is already installed
    if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
        log_info "Installing Python $PYTHON_VERSION (this may take a few minutes)..."
        if pyenv install "$PYTHON_VERSION"; then
            log_success "Python $PYTHON_VERSION installed successfully"
        else
            log_error "Failed to install Python $PYTHON_VERSION"
            return 1
        fi
    else
        log_notice "Python $PYTHON_VERSION already installed"
    fi

    # Create project-specific virtual environment
    log_info "Creating virtual environment for Django package..."
    PROJECT_VENV="{{cookiecutter.project_slug}}-venv"

    if ! pyenv versions | grep -q "$PROJECT_VENV"; then
        if pyenv virtualenv "$PYTHON_VERSION" "$PROJECT_VENV"; then
            log_success "Virtual environment $PROJECT_VENV created"
        else
            log_error "Failed to create virtual environment"
            return 1
        fi
    else
        log_notice "Virtual environment $PROJECT_VENV already exists"
    fi

    # Set local Python version for this project
    if pyenv local "$PROJECT_VENV"; then
        pyenv rehash
        log_success "Local Python environment set to: $PROJECT_VENV"
    else
        log_error "Failed to set local Python environment"
        return 1
    fi

    # Verify Python is accessible
    if command -v python &> /dev/null; then
        CURRENT_PYTHON={% raw %}$(python --version 2>&1 | cut -d' ' -f2){% endraw %}
        log_info "Python version in use: $CURRENT_PYTHON"
    else
        log_error "Python command not available after setting global version"
        return 1
    fi

    # Upgrade pip for project development
    log_info "Upgrading pip..."
    if python -m pip install --upgrade pip; then
        log_success "pip upgraded successfully"
    else
        log_warning "Failed to upgrade pip, continuing with existing version"
    fi

    # Install UV package manager for Django package development
    log_info "Installing UV package manager..."
    if ! command -v uv &> /dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        log_success "UV package manager installed for fast Django package dependency management"
    else
        log_notice "UV package manager already available"
    fi

    log_group_end "Python Development Environment"
    log_success "Python environment setup completed"
}

cleanup() {
    log_group_start "Cleanup"

    log_info "Cleaning up package cache..."
    sudo apt-get clean
    sudo rm -rf /var/lib/apt/lists/*

    log_group_end "Cleanup"
    log_success "Cleanup completed"
}

# ----------------------------------------
# Main Execution
# ----------------------------------------
main() {
    set_workflow_context "{{cookiecutter.project_name}} Development Environment Setup"
    log_workflow_start "{{cookiecutter.project_name}} Development Environment Setup"

    local current_step=0

    # Step 1: Install system packages
    log_step_start "Install system packages" {% raw %}$((++current_step)){% endraw %} "$TOTAL_STEPS"
    install_system_packages $current_step
    log_step_end_with_timing "System packages installation" "success"

    # Step 2: Setup Python environment
    log_step_start "Setup Python environment" {% raw %}$((++current_step)){% endraw %} "$TOTAL_STEPS"
    setup_python_environment $current_step
    log_step_end_with_timing "Python environment setup" "success"

    # Cleanup
    cleanup

    log_workflow_end "{{cookiecutter.project_name}} Development Environment Setup" "success"

    display_bold_message "{{cookiecutter.project_name}} development environment ready!"
}

main "$@"
