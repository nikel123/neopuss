SASSC ?= sassc
SASSC_FLAGS ?= -I vendor/foundation-sites/scss/ -I common/css -m -l

%/css/app.scss: SASSC_FLAGS += -I %/css
html/%/app.css: %/css/app.scss config.mk mk/scss.mk $$(shell find common/css %/css -type f -name '*.scss')
	$(SASSC) $(SASSC_FLAGS) '$<' > '$@'
