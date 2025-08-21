#!/bin/bash

set -e

# ----------------------------------------
# Local Variables
# ----------------------------------------
FEATURE_DIR="/usr/local/share/riso-bootstrap"
PROJECT_NAME="cookiecutter-django-package"
GITHUB_USERNAME="riso-tech"

# Files to import from riso-bootstrap feature
IMPORT_FILES=(
    "$FEATURE_DIR/utils/layer-0/logger.sh:Logger utilities"
    "$FEATURE_DIR/utils/layer-0/package-manager.sh:Package manager utilities"
)

# Calculate total steps
BASE_STEPS=(
    "install_system_packages"
    "setup_python_environment"
    "setup_database_clients"
    "setup_cypress_dependencies"
    "configure_development_environment"
    "project_specific_setup"
)
TOTAL_STEPS=${#BASE_STEPS[@]}

# ----------------------------------------
# Import Utility Functions
# ----------------------------------------
import_utility_files() {
    local -n files_array=$1

    for file_info in "${files_array[@]}"; do
        local file_path="${file_info%:*}"
        local file_desc="${file_info#*:}"

        if [ -f "$file_path" ]; then
            # shellcheck source=/dev/null disable=SC1091
            source "${file_path}"
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
        PYENV_CONFIG='
# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi
'
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
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
        log_success "pyenv environment loaded"
    else
        log_error "pyenv not found in PATH after installation"
        return 1
    fi

    # Install Python LTS version and set as global
    log_info "Installing Python LTS version..."
    PYTHON_LTS_VERSION="3.12.7"  # Current Python LTS version

    # Check if Python version is already installed
    if ! pyenv versions | grep -q "$PYTHON_LTS_VERSION"; then
        log_info "Installing Python $PYTHON_LTS_VERSION (this may take a few minutes)..."
        if pyenv install "$PYTHON_LTS_VERSION"; then
            log_success "Python $PYTHON_LTS_VERSION installed successfully"
        else
            log_error "Failed to install Python $PYTHON_LTS_VERSION"
            return 1
        fi
    else
        log_notice "Python $PYTHON_LTS_VERSION already installed"
    fi

    # Set Python LTS as global version
    log_info "Setting Python $PYTHON_LTS_VERSION as global..."
    if pyenv global "$PYTHON_LTS_VERSION"; then
        pyenv rehash

        # Verify the global version was set correctly
        CURRENT_GLOBAL=$(pyenv global)
        if [[ "$CURRENT_GLOBAL" == "$PYTHON_LTS_VERSION" ]]; then
            log_success "Python global version set to: $CURRENT_GLOBAL"
        else
            log_error "Failed to set Python $PYTHON_LTS_VERSION as global (current: $CURRENT_GLOBAL)"
            return 1
        fi
    else
        log_error "Failed to set global Python version"
        return 1
    fi

    # Verify Python is accessible
    if command -v python &> /dev/null; then
        CURRENT_PYTHON=$(python --version 2>&1 | cut -d' ' -f2)
        log_info "Python version in use: $CURRENT_PYTHON"
    else
        log_error "Python command not available after setting global version"
        return 1
    fi

    # Install cookiecutter using global Python's pip
    log_info "Installing cookiecutter..."
    if ! command -v cookiecutter &> /dev/null && ! python -m cookiecutter --version &> /dev/null 2>&1; then
        log_info "Upgrading pip..."
        if python -m pip install --upgrade pip; then
            log_success "pip upgraded successfully"
        else
            log_warning "Failed to upgrade pip, continuing with existing version"
        fi

        log_info "Installing cookiecutter package..."
        if python -m pip install cookiecutter; then
            # Refresh PATH to pick up newly installed executables
            hash -r
            pyenv rehash

            # Verify cookiecutter installation - try both direct command and python module
            if command -v cookiecutter &> /dev/null; then
                COOKIECUTTER_VERSION=$(cookiecutter --version 2>&1 | cut -d' ' -f2)
                log_success "cookiecutter $COOKIECUTTER_VERSION installed successfully (command available)"
            elif python -m cookiecutter --version &> /dev/null 2>&1; then
                COOKIECUTTER_VERSION=$(python -m cookiecutter --version 2>&1 | cut -d' ' -f2)
                log_success "cookiecutter $COOKIECUTTER_VERSION installed successfully (available as Python module)"
            else
                log_error "cookiecutter installation verification failed"
                return 1
            fi
        else
            log_error "Failed to install cookiecutter"
            return 1
        fi
    else
        if command -v cookiecutter &> /dev/null; then
            COOKIECUTTER_VERSION=$(cookiecutter --version 2>&1 | cut -d' ' -f2)
            log_notice "cookiecutter $COOKIECUTTER_VERSION already installed (command available)"
        else
            COOKIECUTTER_VERSION=$(python -m cookiecutter --version 2>&1 | cut -d' ' -f2)
            log_notice "cookiecutter $COOKIECUTTER_VERSION already installed (available as Python module)"
        fi
    fi

    # Install UV package manager for Python
    log_info "Installing UV package manager..."
    if ! command -v uv &> /dev/null; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        log_success "UV package manager installed"
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
    set_workflow_context "Cookiecutter Django Package Post-Create Setup"
    log_workflow_start "Cookiecutter Django Package Post-Create Setup"

    local current_step=0

    # Step 1: Install system packages
    log_step_start "Install system packages" $((++current_step)) "$TOTAL_STEPS"
    install_system_packages $current_step
    log_step_end_with_timing "System packages installation" "success"

    # Step 2: Setup Python environment
    log_step_start "Setup Python environment" $((++current_step)) "$TOTAL_STEPS"
    setup_python_environment $current_step
    log_step_end_with_timing "Python environment setup" "success"

    # Cleanup
    cleanup

    log_workflow_end "Cookiecutter Django Package Post-Create Setup" "success"

    display_bold_message "Post-create setup completed successfully!"
}

main "$@"
