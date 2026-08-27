# Fast functional tests, run by "make check".
TESTS = \
    calibration.sh \
    composition.sh \
    seed.sh \
    output.sh \
    terminate.sh \
    arguments.sh \
    malformed.sh \
    options.sh \
    ambiguous.sh \
    formats.sh \
    nossr.sh \
    sanitize.sh \
    valgrind.sh

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
    $(TESTS) \
    $(STATS_TESTS) \
    data/multi.aln \
    data/multi.maf \
    data/pair.aln \
    data/skewed.aln \
    data/degenerate.aln \
    data/ambiguous.aln \
    data/atrich.aln
