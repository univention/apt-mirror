VERSION := 0.5.4
DIST := apt-mirror CHANGELOG LICENSE Makefile mirror.list postmirror.sh README.md test.pl .perltidyrc
BASE_PATH := /var/spool/apt-mirror
PREFIX ?= /usr/local
INSTALL ?= install
INSTALL_DATA ?= $(INSTALL) -m644
INSTALL_PROGRAM ?= $(INSTALL) -m755

all:

test:
	./test.pl

dist: apt-mirror-$(VERSION).tar.xz

install:
	$(INSTALL_PROGRAM) -D apt-mirror $(DESTDIR)$(PREFIX)/bin/apt-mirror
	$(INSTALL) -d $(DESTDIR)$(PREFIX)/share/man/man1/
	pod2man apt-mirror $(DESTDIR)$(PREFIX)/share/man/man1/apt-mirror.1
	test -f $(DESTDIR)/etc/apt/mirror.list || $(INSTALL_DATA) -D mirror.list $(DESTDIR)/etc/apt/mirror.list
	$(INSTALL) -d $(DESTDIR)$(BASE_PATH)/mirror
	$(INSTALL) -d $(DESTDIR)$(BASE_PATH)/skel
	$(INSTALL) -d $(DESTDIR)$(BASE_PATH)/var

%.tar.bz2: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | bzip2 -cz9 > $@

%.tar.gz: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | gzip -cn9 > $@

%.tar.xz: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | xz -cz9 > $@

clean:
	$(RM) *.tar.*

.PHONY: all test clean dist install
