SUBDIRS=librna sissiz levmar phyml src examples tests

# Sanitizer build in a scratch tree, leaving the normal build here alone.
# Leak checking is off: the allocations held until exit are noise.
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

# Scratch tree with debug info, run through valgrind.  Accepted leaks are
# listed in tests/valgrind.supp.
check-valgrind:
	rm -rf valgrind-build $(distdir)
	$(MAKE) $(AM_MAKEFLAGS) distdir
	mkdir valgrind-build
	cd valgrind-build && ../$(distdir)/configure CFLAGS="-O1 -g $(CFLAGS)" >/dev/null
	cd valgrind-build && $(MAKE) $(AM_MAKEFLAGS)
	cd valgrind-build && SISSIZ_VALGRIND=1 $(MAKE) $(AM_MAKEFLAGS) check
	rm -rf valgrind-build $(distdir)

check-stats:
	cd tests && $(MAKE) $(AM_MAKEFLAGS) check-stats

.PHONY: check-asan check-valgrind check-stats

docu_DATA = INSTALL README AUTHORS COPYING TODO ChangeLog.md
 
EXTRA_DIST = INSTALL README AUTHORS COPYING TODO ChangeLog.md

docudir = $(pkgdatadir)
