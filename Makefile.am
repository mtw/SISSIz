SUBDIRS=librna sissiz levmar phyml src examples tests

# Rebuild in a scratch tree with the sanitizers on and run the suite there,
# so the normal build in this directory is left alone.
ASAN_CFLAGS = -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer
ASAN_LDFLAGS = -fsanitize=address,undefined

check-asan:
	rm -rf asan-build $(distdir)
	$(MAKE) $(AM_MAKEFLAGS) distdir
	mkdir asan-build
	cd asan-build && ../$(distdir)/configure \
	    CFLAGS="$(ASAN_CFLAGS) $(CFLAGS)" LDFLAGS="$(ASAN_LDFLAGS) $(LDFLAGS)" >/dev/null
	cd asan-build && $(MAKE) $(AM_MAKEFLAGS)
	cd asan-build && $(MAKE) $(AM_MAKEFLAGS) check
	rm -rf asan-build $(distdir)

check-stats:
	cd tests && $(MAKE) $(AM_MAKEFLAGS) check-stats

.PHONY: check-asan check-stats

docu_DATA = INSTALL README AUTHORS COPYING TODO 
 
EXTRA_DIST = INSTALL README AUTHORS COPYING TODO 

docudir = $(pkgdatadir)
