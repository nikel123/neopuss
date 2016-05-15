EMBER_VER    := 2.5.1
EMBER_FLAVOR := debug

EMBER_URL := http://builds.emberjs.com/tags/v$(EMBER_VER)/ember.$(EMBER_FLAVOR).js

html/vendor/ember.js: mk/ember.mk config.mk
	mkdir -p '$(@D)'
	wget -O '$@' '$(EMBER_URL)'
	touch '$@'

all: html/vendor/ember.js
