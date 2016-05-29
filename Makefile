all:
.SUFFIXES:
.SECONDEXPANSION:
.DELETE_ON_ERROR:
.ONESHELL:

include mk/*.mk
include config.mk

all: adminui_all
