#!/usr/bin/env python
"""Pre-generation hook for cookiecutter."""

import sys


# Minimal inline logger for cookiecutter hooks
class MinimalLogger:
    """Lightweight logger for cookiecutter hooks."""

    # ANSI color codes
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[0;33m"
    BLUE = "\033[0;34m"
    CYAN = "\033[0;36m"
    PURPLE = "\033[0;35m"
    BOLD = "\033[1m"
    NC = "\033[0m"  # No Color

    def __init__(self):
        self.current_workflow = None

    def _print(self, message, color=None):
        """Print message with optional color."""
        if color:
            print(f"{color}{message}{self.NC}", file=sys.stderr)
        else:
            print(message, file=sys.stderr)

    def log_info(self, message):
        """Log info message."""
        self._print(f"💡 {message}", self.CYAN)

    def log_success(self, message):
        """Log success message."""
        self._print(f"🎉 {message}", self.GREEN)

    def log_error(self, message):
        """Log error message."""
        self._print(f"💥 {message}", self.RED)

    def log_warning(self, message):
        """Log warning message."""
        self._print(f"🚨 {message}", self.YELLOW)

    def log_phase(self, message):
        """Log phase with separator."""
        separator = "=" * (len(message) + 10)
        self._print(f"\n{separator}", self.PURPLE + self.BOLD)
        self._print(f"     {message}", self.PURPLE + self.BOLD)
        self._print(separator, self.PURPLE + self.BOLD)

    def display_bold_message(self, message):
        """Display bold message."""
        separator = "=" * (len(message) + 10)
        self._print(separator, self.GREEN)
        self._print(f"     {message}", self.GREEN + self.BOLD)
        self._print(separator, self.GREEN)

    def workflow(self, name):
        """Decorator for workflow."""

        def decorator(func):
            def wrapper(*args, **kwargs):
                self.current_workflow = name
                self._print(f"\n🚀 Starting workflow: {name}", self.PURPLE + self.BOLD)
                try:
                    result = func(*args, **kwargs)
                    self._print(
                        f"✅ Workflow completed: {name}", self.GREEN + self.BOLD
                    )
                    return result
                except Exception as e:
                    self._print(f"❌ Workflow failed: {name}", self.RED + self.BOLD)
                    raise e

            return wrapper

        return decorator

    def log_group(self, title):
        """Context manager for grouping logs."""

        class GroupContext:
            def __init__(self, logger, title):
                self.logger = logger
                self.title = title

            def __enter__(self):
                self.logger._print(f"▶ {self.title}", self.logger.CYAN)
                return self

            def __exit__(self, *args):
                self.logger._print(f"◀ End: {self.title}", self.logger.CYAN)

        return GroupContext(self, title)


# Create logger instance
logger = MinimalLogger()


def validate_project_slug():
    """Validate project slug format."""
    project_slug = "{{ cookiecutter.project_slug }}"

    logger.log_info(f"Validating project slug: {project_slug}")

    if project_slug != project_slug.lower():
        logger.log_error(f"Project slug '{project_slug}' should be all lowercase")
        sys.exit(1)

    logger.log_success("Project slug validation passed")


def validate_app_slug():
    """Validate app slug format."""
    app_slug = "{{ cookiecutter.app_slug }}"

    logger.log_info(f"Validating app slug: {app_slug}")

    if hasattr(app_slug, "isidentifier"):
        if not app_slug.isidentifier():
            logger.log_error(f"App slug '{app_slug}' is not a valid Python identifier")
            sys.exit(1)

    if app_slug != app_slug.lower():
        logger.log_error(f"App slug '{app_slug}' should be all lowercase")
        sys.exit(1)

    logger.log_success("App slug validation passed")


def validate_author_name():
    """Validate author name format."""
    author_name = "{{ cookiecutter.author_name }}"

    logger.log_info(f"Validating author name: {author_name}")

    if "\\" in author_name:
        logger.log_error("Don't include backslashes in author name")
        sys.exit(1)

    logger.log_success("Author name validation passed")


@logger.workflow("Pre-Generation Validation")
def main():
    """Run all pre-generation validations."""
    with logger.log_group("Validating Input Parameters"):
        validate_project_slug()
        validate_app_slug()
        validate_author_name()


if __name__ == "__main__":
    main()
