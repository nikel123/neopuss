build/%.page.js: %.page.hbs tools/tc.js mk/template.mk config.mk
	mkdir -p '$(@D)'
	$(NODE) tools/tc.js '$<' > '$@'
