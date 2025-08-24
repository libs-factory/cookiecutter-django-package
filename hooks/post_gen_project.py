#!/usr/bin/env python
"""Post-generation hook for cookiecutter."""

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

    def log_notice(self, message):
        """Log notice message."""
        self._print(f"ℹ️  NOTICE: {message}", self.BLUE)

    def log_header(self, header):
        """Log header with icon."""
        self._print(f"\n🎯 {header}", self.BLUE + self.BOLD)

    def log_section(self, section):
        """Log section header."""
        self._print(section, self.CYAN)

    def log_subsection(self, subsection):
        """Log subsection header."""
        self._print(f"\n  {subsection}", self.CYAN + self.BOLD)

    def log_section_info(self, info):
        """Log section information."""
        self._print(f"    {info}", None)

    def log_step(self, step, total, message):
        """Log step with progress."""
        self._print(f"  [{step}/{total}] {message}", self.BLUE)

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


def display_project_info():
    """Display project information."""
    project_name = "{{ cookiecutter.project_name }}"
    project_slug = "{{ cookiecutter.project_slug }}"
    app_slug = "{{ cookiecutter.app_slug }}"
    author_name = "{{ cookiecutter.author_name }}"
    author_email = "{{ cookiecutter.author_email }}"
    description = "{{ cookiecutter.description }}"

    logger.log_section("\n📦 Project Information")
    logger.log_subsection("Package Details")
    logger.log_section_info(f"Project Name: {project_name}")
    logger.log_section_info(f"Project Slug: {project_slug}")
    logger.log_section_info(f"App Slug: {app_slug}")

    logger.log_subsection("Author Details")
    logger.log_section_info(f"Author: {author_name}")
    logger.log_section_info(f"Email: {author_email}")

    logger.log_subsection("Description")
    logger.log_section_info(description)


def display_next_steps():
    """Display next steps for the user."""
    logger.log_notice("Remember to initialize a git repository if you haven't already!")


@logger.workflow("Post-Generation Setup")
def main():
    """Run post-generation setup."""
    display_project_info()
    display_next_steps()

    logger.log_success("Happy coding! 🚀")


if __name__ == "__main__":
    main()
