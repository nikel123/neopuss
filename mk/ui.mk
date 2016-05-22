ui_pages_sources = $(wildcard $1/**/*.hbs $1/*.hbs)
ui2js = $(patsubst %.page.hbs,build/%.page.js,$1)
ui_pages = $(call ui2js,$(call ui_pages_sources,$1))

html/%/app.js: %/js/*.js $$(call ui_pages,%) config.mk mk/ui.mk
	cat $(filter %.js,$^) > '$@'
	
