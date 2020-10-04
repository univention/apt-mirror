VERSION := 0.5.4
DIST := apt-mirror CHANGELOG LICENSE Makefile mirror.list postmirror.sh README.md test.pl .perltidyrc
BASE_PATH := /var/spool/apt-mirror
PREFIX ?= /usr/local

all:

test:
	./test.pl

dist: apt-mirror-$(VERSION).tar.xz

install:
	install -m 755 -D apt-mirror $(DESTDIR)$(PREFIX)/bin/apt-mirror
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man1/
	pod2man apt-mirror > $(DESTDIR)$(PREFIX)/share/man/man1/apt-mirror.1
	if test ! -f $(DESTDIR)/etc/apt/mirror.list; then install -m 644 -D mirror.list $(DESTDIR)/etc/apt/mirror.list; fi
	mkdir -p $(DESTDIR)$(BASE_PATH)/mirror
	mkdir -p $(DESTDIR)$(BASE_PATH)/skel
	mkdir -p $(DESTDIR)$(BASE_PATH)/var

%.tar.bz2: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | bzip2 -cz9 > $@

%.tar.gz: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | gzip -cn9 > $@

%.tar.xz: $(DIST)
	tar -c --exclude-vcs --transform="s@^@$*/@" $^ | xz -cz9 > $@

clean:
	rm -f *.tar.*

.PHONY: all test clean dist install
