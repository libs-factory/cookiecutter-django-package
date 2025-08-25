import tempfile
from unittest import TestCase

from django.core.management import call_command
from django.test import override_settings


class TestCollectStatic(TestCase):
    """
    Test manage.py collectstatic --noinput --link

    with different versions of STATICFILES_STORAGE.
    """

    def test_collect_static(self):
        for storage in [
            "django.contrib.staticfiles.storage.StaticFilesStorage",
            "django.contrib.staticfiles.storage.ManifestStaticFilesStorage",
        ]:
            with override_settings(
                STORAGES={
                    "default": {
                        "BACKEND": "django.core.files.storage.FileSystemStorage",
                    },
                    "staticfiles": {
                        "BACKEND": storage,
                    },
                },
                STATIC_ROOT=tempfile.mkdtemp(),
            ):
                call_command("collectstatic", "--noinput", "--link")
