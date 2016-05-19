EMBER_VER    := 2.5.1
EMBER_FLAVOR := debug

EMBER_URL := http://builds.emberjs.com/tags/v$(EMBER_VER)/ember.$(EMBER_FLAVOR).js
EMBER_TEMPLATE_COMPILER_URL := http://builds.emberjs.com/tags/v$(EMBER_VER)/ember-template-compiler.js

html/vendor/ember.js: mk/ember.mk config.mk
	mkdir -p '$(@D)'
	wget -O '$@' '$(EMBER_URL)'
	touch '$@'

vendor/tc.js: mk/ember.mk config.mk
	mkdir -p '$(@D)'
	wget -O '$@' '$(EMBER_TEMPLATE_COMPILER_URL)'
	touch '$@'

all: html/vendor/ember.js vendor/tc.js
