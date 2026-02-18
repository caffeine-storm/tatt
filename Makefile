all: readme.html

readme.html: README.md
	md2html $^ > $@
