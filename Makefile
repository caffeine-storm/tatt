all: readme.html

readme.html: README.md
	md2html $^ > $@

.PHONY: reinstall
reinstall:
	cabal install --overwrite-policy=always

.PHONY: test
test:
	cabal test
