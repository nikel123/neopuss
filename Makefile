all:

include mk/*.mk
include config.mk

all: adminui

adminui: $(call ui,adminui)
