all: readme.html

readme.html: README.md
	md2html $^ > $@

.PHONY: test
test:
	cabal test
