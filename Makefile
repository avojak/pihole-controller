# SPDX-FileCopyrightText: 2024 Andrew Vojak
# SPDX-License-Identifier: GPL-3.0-or-later

SHELL := /bin/bash

APP_ID := com.avojak.piholecontroller.Devel

FLATHUB_FLATPAK_REMOTE_URL  := https://flathub.org/repo/flathub.flatpakrepo
FLATHUB_FLATPAK_REMOTE_NAME := flathub
# GNOME_NIGHTLY_FLATPAK_REMOTE_URL  := https://nightly.gnome.org/gnome-nightly.flatpakrepo
# GNOME_NIGHTLY_FLATPAK_REMOTE_NAME := gnome-nightly
FLATPAK_PLATFORM_VERSION    := 46

BUILD_DIR        := build
NINJA_BUILD_FILE := $(BUILD_DIR)/build.ninja

FLATPAK_BUILDER_FLAGS := --user --install --force-clean
ifdef OFFLINE_BUILD
FLATPAK_BUILDER_FLAGS += --disable-download
endif

# Check for executables which are assumed to already be present on the system
EXECUTABLES = flatpak flatpak-builder
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

.DEFAULT_GOAL := flatpak

.PHONY: init
init:
	flatpak remote-add --if-not-exists --user $(FLATHUB_FLATPAK_REMOTE_NAME) $(FLATHUB_FLATPAK_REMOTE_URL)
	flatpak install -y --user $(FLATHUB_FLATPAK_REMOTE_NAME) org.gnome.Platform//$(FLATPAK_PLATFORM_VERSION)
	flatpak install -y --user $(FLATHUB_FLATPAK_REMOTE_NAME) org.gnome.Sdk//$(FLATPAK_PLATFORM_VERSION)

.PHONY: flatpak
flatpak:
	flatpak-builder build flatpak/com.avojak.piholecontroller.yml $(FLATPAK_BUILDER_FLAGS)

.PHONY: lint
lint:
	io.elementary.vala-lint ./src

$(NINJA_BUILD_FILE):
	meson build --prefix=/user

.PHONY: translations
translations: $(NINJA_BUILD_FILE)
	ninja -C build $(APP_ID)-pot
	ninja -C build $(APP_ID)-update-po

.PHONY: run
run:
	flatpak run $(FLATPAK_RUN_ARGS) --env=G_MESSAGES_DEBUG=$(APP_ID) $(APP_ID)

.PHONY: inspect
inspect:
	$(MAKE) FLATPAK_RUN_ARGS="--command=sh --devel" run

.PHONY: debug
debug:
	$(MAKE) FLATPAK_RUN_ARGS="--env=GTK_DEBUG=interactive" run

.PHONY: check-reset
check-reset:
	@echo -n "Are you sure you want to reset all settings? [y/N] " && read ans && [ $${ans:-N} = y ]

.PHONY: reset
reset: check-reset
	@echo resetting
	flatpak run --command=gsettings $(APP_ID) reset-recursively $(APP_ID)
	rm -rf ~/.var/app/$(APP_ID)/data