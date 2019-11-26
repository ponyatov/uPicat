
CWD    = $(CURDIR)
MODULE = $(notdir $(CWD))

PY  = $(CWD)/bin/python3
PIP = $(CWD)/bin/pip3
PI  = $(CWD)/Picat/picat

install: doc
	sudo apt install -u `cat apt.txt`
	$(PIP) install -U pip
	$(PIP) install -U flask ply graphviz
	$(MAKE) requirements.txt

.PHONY: install requirements.txt

requirements.txt:
	$(PIP) freeze | grep -v 0.0.0 > $@

doc: doc/book.pdf doc/manual.pdf
doc/book.pdf:
	wget -c -O $@ http://picat-lang.org/picatbook2015/constraint_solving_and_planning_with_picat.pdf
doc/manual.pdf:
	wget -c -O $@ http://picat-lang.org/download/picat_guide.pdf

MERGE  = Makefile README.md .gitignore
MERGE += $(MODULE).py $(MODULE).ini requirements.txt apt.txt
MERGE += doc

merge:
	git checkout master
	git checkout shadow -- $(MERGE)

NOW = $(shell date +%d%m%y)
REL = $(shell git rev-parse --short=4 HEAD)

release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
	git checkout shadow
