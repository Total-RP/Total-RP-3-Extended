# Copyright The Total RP 3 Authors
# SPDX-License-Identifier: Apache-2.0

PYTHON ?= python3
PACKAGER_URL := https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh
SCHEMA_URL := https://raw.githubusercontent.com/Meorawr/wow-ui-schema/main/UI.xsd

CF_PROJECT_ID := 100707
LOCALE_DIR := totalRP3_Extended/Locales

.PHONY: check dist libs translations translations/download translations/upload
.DEFAULT: all
.DELETE_ON_ERROR:
.FORCE:

all: dist

check: .github/scripts/ui.xsd
	pre-commit run --all-files

dist:
	@curl -s $(PACKAGER_URL) | bash -s -- -d -S


.github/scripts/ui.xsd: .FORCE
	curl -s $(SCHEMA_URL) -o $@
