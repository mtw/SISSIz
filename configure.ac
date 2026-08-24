AC_INIT(SISSIz, 0.1.1, wash@tbi.univie.ac.at, SISSIz)
AM_INIT_AUTOMAKE

AC_PROG_CC

# AC_PROG_CC only supplies its default "-g -O2" when CFLAGS is unset.  A
# CFLAGS inherited from the environment (say a bare -I) would otherwise
# build the whole package unoptimised.
AS_CASE([" $CFLAGS "],
        [*" -O"*], [],
        [CFLAGS="$CFLAGS -O2"])

if test "$GCC" = yes; then
  AC_DEFINE(UNUSED, __attribute__ ((unused)), avoid warning about unused variables)
else
  AC_DEFINE(UNUSED,, only for gcc)
fi
      
AC_SUBST(VERSION)
ISODATE=`date +%Y-%m-%d`
AC_SUBST(ISODATE)


AC_HEADER_STDC
AC_CHECK_HEADERS(malloc.h strings.h unistd.h)
AC_C_CONST
AC_TYPE_SIZE_T
AC_INLINE

AC_CHECK_FUNCS(strdup strstr strchr erand48)

AC_PROG_CXX

AC_PROG_RANLIB

AC_PROG_INSTALL

AC_CONFIG_HEADERS(config.h) 

AC_OUTPUT([Makefile librna/Makefile sissiz/Makefile levmar/Makefile src/Makefile phyml/Makefile examples/Makefile tests/Makefile])


