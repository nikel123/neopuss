SASSC ?= sassc
SASSC_FLAGS ?= -I vendor/foundation-sites/scss/ -I common/css

%/css/app.scss: SASSC_FLAGS += -I %/css
html/%/app.css: %/css/app.scss config.mk mk/scss.mk
	$(SASSC) $(SASSC_FLAGS) '$<' > '$@'
