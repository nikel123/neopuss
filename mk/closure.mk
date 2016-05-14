vendor/closure-compiler/build/compiler.jar:
	cd vendor/closure-compiler && ant

.PHONY: closure-update
closure-update:
	cd vendor/closure-compiler && git fetch && git checkout origin/master && ant
