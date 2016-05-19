ui_pages_sources = $(shell find '$(1)' -name '*.page.hbs')
ui2js = $(patsubst %.hbs,build/%.js,$(1))
ui_pages = $(call ui2js,$(call ui_pages_sources,$(1)))

ui = \
  $(call ui_pages,$(1))
