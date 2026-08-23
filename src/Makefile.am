AM_CPPFLAGS = \
    -I$(top_srcdir)/librna \
    -I$(top_srcdir)/sissiz \
    -I$(top_srcdir)/levmar \
    -I$(top_srcdir)

bin_PROGRAMS = SISSIz

SISSIz_SOURCES = \
    SISSIz.c \
    rnaz_utils.c \
    expfit.c \
    bionj_custom.c \
    bionj_custom.h \
    sissiz.h \
    rnaz_utils.h \
    expfit.h \
    cmdline_sissiz.c \
    cmdline_sissiz.h \
    treeML.h \
    treeML.c

# Link the bundled convenience archives by path: a plain -lRNA would be
# satisfied by an installed ViennaRNA in an earlier -L directory.
LDADD = \
    $(top_builddir)/librna/libRNA.a \
    $(top_builddir)/levmar/liblevmar.a \
    $(top_builddir)/sissiz/libSISSI.a \
    $(top_builddir)/phyml/libPHYML.a \
    -lm

