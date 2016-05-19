%.page.hbs: build/%.page.js tools/tc.js
	mkdir -p '$(@D)'
	$(NODE) tools/tc.js '$<' > '$@'
