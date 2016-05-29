all:
.SUFFIXES:
.SECONDEXPANSION:

include mk/*.mk
include config.mk

.PHONY: adminui_all
adminui_all: html/adminui/app.js

CLEAN += html/adminui/app.js

all: adminui_all
