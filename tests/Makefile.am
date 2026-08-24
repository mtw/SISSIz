TESTS = \
    calibration.sh \
    composition.sh \
    seed.sh \
    output.sh \
    terminate.sh \
    arguments.sh \
    ambiguous.sh \
    formats.sh \
    nossr.sh

TEST_EXTENSIONS = .sh
SH_LOG_COMPILER = $(SHELL)

AM_TESTS_ENVIRONMENT = \
    srcdir='$(srcdir)'; export srcdir; \
    top_builddir='$(abs_top_builddir)'; export top_builddir;

EXTRA_DIST = \
    common.sh \
    $(TESTS) \
    data/multi.aln \
    data/multi.maf \
    data/pair.aln \
    data/skewed.aln \
    data/degenerate.aln \
    data/ambiguous.aln
