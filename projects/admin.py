# projects/admin.py

from django.contrib import admin
from django.apps import apps

apps.all_models["projects"]

admin.site.register(apps.all_models["projects"].values())
