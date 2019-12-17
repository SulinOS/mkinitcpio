# Makefile for mkinitcpio

VERSION = $(shell if test -f VERSION; then cat VERSION; else git describe | sed 's/-/./g;s/^v//;'; fi)

DIRS = \
	/usr/bin \
	/etc/mkinitcpio.d \
	/etc/initcpio/hooks \
	/etc/initcpio/install \
	/usr/lib/initcpio/hooks \
	/usr/lib/initcpio/install \
	/usr/lib/kernel/install.d \
	/usr/share/mkinitcpio \
	/usr/lib/tmpfiles.d

BASH_SCRIPTS = \
	mkinitcpio \
	lsinitcpio

all: 

install: all
	install -dm755 $(addprefix $(DESTDIR),$(DIRS))

	sed -e 's|\(^_f_config\)=.*|\1=/etc/mkinitcpio.conf|' \
	    -e 's|\(^_f_functions\)=.*|\1=/usr/lib/initcpio/functions|' \
	    -e 's|\(^_d_hooks\)=.*|\1=/etc/initcpio/hooks:/usr/lib/initcpio/hooks|' \
	    -e 's|\(^_d_install\)=.*|\1=/etc/initcpio/install:/usr/lib/initcpio/install|' \
	    -e 's|\(^_d_presets\)=.*|\1=/etc/mkinitcpio.d|' \
	    -e 's|%VERSION%|$(VERSION)|g' \
	    < mkinitcpio > $(DESTDIR)/usr/bin/mkinitcpio

	sed -e 's|\(^_f_functions\)=.*|\1=/usr/lib/initcpio/functions|' \
	    -e 's|%VERSION%|$(VERSION)|g' \
	    < lsinitcpio > $(DESTDIR)/usr/bin/lsinitcpio

	chmod 755 $(DESTDIR)/usr/bin/lsinitcpio $(DESTDIR)/usr/bin/mkinitcpio

	install -m644 mkinitcpio.conf $(DESTDIR)/etc/mkinitcpio.conf
	install -m755 -t $(DESTDIR)/usr/lib/initcpio init shutdown
	install -m644 -t $(DESTDIR)/usr/lib/initcpio init_functions functions

	cp -at $(DESTDIR)/usr/lib/initcpio hooks install
	install -m644 -t $(DESTDIR)/usr/share/mkinitcpio mkinitcpio.d/*
	install -m644 tmpfiles/mkinitcpio.conf $(DESTDIR)/usr/lib/tmpfiles.d/mkinitcpio.conf

	install -m755 50-mkinitcpio.install $(DESTDIR)/usr/lib/kernel/install.d/50-mkinitcpio.install
check:
	@r=0; for t in test/test_*; do $$t || { echo $$t fail; r=1; }; done; exit $$r
	@r=0; for s in $(BASH_SCRIPTS); do bash -O extglob -n $$s || r=1; done; exit $$r


