NODE ?= node
TEMPLATE_COMPILER ?= $(NODE) ./tools/tc.js
MOD_COMPILER ?= ./tools/modc

define uirules

build/$(1)/app/%.js: $1/app/%.hbs ./tools/tc.js config.mk mk/uiapp.mk
	mkdir -p '$$(@D)'
	$$(TEMPLATE_COMPILER) '$$<' > '$$@'

build/$1/app/%.js: $1/app/%.js ./tools/modc config.mk mk/uiapp.mk
	mkdir -p '$$(@D)'
	$$(MOD_COMPILER) '$$<' > '$$@'

.PRECIOUS: build/$1/app/%.js

.PHONY: $(1)_all
$(1)_all: html/$(1)/app.js html/$(1)/app.css
CLEAN += html/$(1)/app.js html/$(1)/app.css

endef

$(info $(foreach i,$(patsubst %/app,%,$(wildcard */app)),$(call uirules,$i)))
$(eval $(foreach i,$(patsubst %/app,%,$(wildcard */app)),$(call uirules,$i)))

ui_src=$(shell [ -e '$1' ] && find '$1' -type f -name '*.$2')
ui_hbs=$(patsubst %.hbs,build/%.js,$(call ui_src,$1/app,hbs))
ui_mods=$(foreach i,$(call ui_src,$1/app,js),build/$i)
ui_js=$(call ui_src,$1/js,js)

common_hbs=$(call ui_hbs,common)
common_mods=$(call ui_mods,common)
common_js=$(call ui_js,common)

html/%/app.js: \
		$(common_js) $$(call ui_js) \
		$(common_mods) $$(call ui_mods,%) \
    $(common_hbs) $$(call ui_hbs,%)
	mkdir -p '$(@D)'
	for i in $(filter %.js,$^) ; do \
	  echo "// $$i"; \
	  cat "$$i" ; \
	done > '$@'

tools/modc: LIBS=-lev
tools/modc: tools/modc.o 

CLEAN += tools/modc
