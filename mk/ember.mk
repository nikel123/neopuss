EMBER_VER    := 2.5.1
EMBER_FLAVOR := debug

EMBER_URL := http://builds.emberjs.com/tags/v$(EMBER_VER)/ember.$(EMBER_FLAVOR).js

vendor/ember.js: ember.mk
	mkdir -p '$(@D)'
	wget -O '$@' '$(EMBER_URL)'
