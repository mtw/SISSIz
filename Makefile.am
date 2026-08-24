SUBDIRS=librna sissiz levmar phyml src examples tests

# Rebuild in a scratch tree with the sanitizers on and run the suite there,
# so the normal build in this directory is left alone.  LeakSanitizer is on
# by default on Linux and would flag the one shot allocations SISSIz holds
# until exit; those are noise, not defects.
SANITIZERS = -fsanitize=address,undefined

check-asan:
	rm -rf asan-build $(distdir)
	$(MAKE) $(AM_MAKEFLAGS) distdir
	mkdir asan-build
	cd asan-build && ../$(distdir)/configure \
	    CFLAGS="-O1 -g $(SANITIZERS) -fno-omit-frame-pointer $(CFLAGS)" \
	    LDFLAGS="$(SANITIZERS) $(LDFLAGS)" >/dev/null
	cd asan-build && $(MAKE) $(AM_MAKEFLAGS)
	cd asan-build && ASAN_OPTIONS=detect_leaks=0 $(MAKE) $(AM_MAKEFLAGS) check
	rm -rf asan-build $(distdir)

check-stats:
	cd tests && $(MAKE) $(AM_MAKEFLAGS) check-stats

.PHONY: check-asan check-stats

docu_DATA = INSTALL README AUTHORS COPYING TODO 
 
EXTRA_DIST = INSTALL README AUTHORS COPYING TODO 

docudir = $(pkgdatadir)
