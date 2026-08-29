# Fast functional tests, run by "make check".
# Shell tests are distributed as sources; the compiled test is generated.
SHELL_TESTS = \
    calibration.sh \
    composition.sh \
    seed.sh \
    golden.sh \
    output.sh \
    terminate.sh \
    arguments.sh \
    malformed.sh \
    names.sh \
    options.sh \
    ambiguous.sh \
    formats.sh \
    nossr.sh \
    sanitize.sh \
    valgrind.sh

check_PROGRAMS = triplet-map-test
TESTS = $(check_PROGRAMS) $(SHELL_TESTS)
triplet_map_test_SOURCES = triplet-map-test.c
triplet_map_test_CPPFLAGS = -I$(top_srcdir)/sissiz
triplet_map_test_LDADD = $(top_builddir)/sissiz/libSISSI.a

# Slow statistical test, run by "make check-stats" from the top directory.
STATS_TESTS = nulldist.sh

TEST_EXTENSIONS = .sh
SH_LOG_COMPILER = $(SHELL)

AM_TESTS_ENVIRONMENT = \
    srcdir='$(srcdir)'; export srcdir; \
    top_builddir='$(abs_top_builddir)'; export top_builddir;

check-stats:
	@for t in $(STATS_TESTS); do \
	  echo "running $$t (this takes a few minutes)"; \
	  srcdir='$(srcdir)' top_builddir='$(abs_top_builddir)' $(SHELL) $(srcdir)/$$t || exit 1; \
	done
.PHONY: check-stats

EXTRA_DIST = \
    common.sh \
    valgrind.supp \
    $(SHELL_TESTS) \
    $(STATS_TESTS) \
    data/multi.aln \
    data/multi.maf \
    data/pair.aln \
    data/skewed.aln \
    data/degenerate.aln \
    data/ambiguous.aln \
    data/atrich.aln
