
CWD    = $(CURDIR)
MODULE = $(notdir $(CWD))

PY  = $(CWD)/bin/python3
PIP = $(CWD)/bin/pip3
PI  = $(CWD)/Picat/picat

server: $(PY) $(MODULE).py $(MODULE).ini
	$^

.PHONY: install update requirements.txt wiki

install: doc $(PI) $(PIP)
$(PIP):
	sudo apt install -u `cat apt.txt`
	git clone -o gh git@github.com:ponyatov/uPicat.wiki.git wiki
	$(MAKE) update

update:
	$(PIP) install -U pip
	$(PIP) install -U -r requirements.txt
	$(MAKE) requirements.txt
	$(MAKE) wiki

wiki:
	cd wiki ; git pull -v

requirements.txt:
	$(PIP) freeze | grep -v 0.0.0 > $@

PI_VER = 27b12
PI_GZ  = picat$(PI_VER)_linux64.tar.gz
PI_SRC = picat$(PI_VER)_src.tar.gz

$(PI): /tmp/$(PI_GZ)
	tar zx < $< && touch $@
/tmp/$(PI_GZ):
	wget -c -O $@ http://picat-lang.org/download/$(PI_GZ)

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
