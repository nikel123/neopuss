NORMALIZE_VER := 4.1.1
NORMALIZE_URL := https://necolas.github.io/normalize.css/$(NORMALIZE_VER)/normalize.css

html/vendor/normalize.css: mk/normalize.mk config.mk
	mkdir -p '$(@D)'
	wget -O '$@' '$(NORMALIZE_URL)'
	touch '$@'

all: html/vendor/normalize.css
