JQUERY_VER    := 2.2.4

JQUERY_URL := https://code.jquery.com/jquery-$(JQUERY_VER).js

html/vendor/jquery.js: mk/jquery.mk config.mk
		mkdir -p '$(@D)'
		wget -O '$@' '$(JQUERY_URL)'
		touch '$@'

all: html/vendor/jquery.js
