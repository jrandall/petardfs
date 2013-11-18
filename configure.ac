# Copyright (C) 2006 Ben Martin <monkeyiq@users.sourceforge.net>
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

AC_PREREQ(2.53)
AC_INIT([petardfs],
        [0.0.2],
        [Ben Martin monkeyiq@users.sourceforge.net],
        [petardfs])

PACKAGE=$PACKAGE_NAME
VERSION=$PACKAGE_VERSION
PETARDFS_VERSION=$VERSION
PETARDFS_FULLV=$VERSION
PETARDFS_MAJOR=`echo $VERSION | sed 's/^\([[0-9]]\)*\..*/\1/g'`
PETARDFS_MINOR=$(echo $VERSION | sed 's/^[[0-9]]*\.\([[0-9]]\)*\..*/\1/g')
PETARDFS_BETA=$(echo $VERSION | sed 's/^[[0-9]]*\.[[0-9]]*\.\([[0-9]]*\).*/\1/g')

AC_SUBST(PETARDFS_MAJOR)
AC_SUBST(PETARDFS_MINOR)
AC_SUBST(PETARDFS_BETA)
AC_SUBST(PETARDFS_FULLV)
AC_SUBST(PETARDFS_VERSION)

AC_CONFIG_AUX_DIR(config)
AC_CANONICAL_SYSTEM
AM_CONFIG_HEADER(config.h)
AM_INIT_AUTOMAKE([1.9 tar-ustar dist-bzip2])


LF_CONFIGURE_CC
LF_CONFIGURE_CXX
LF_SET_WARNINGS


AC_SYS_LARGEFILE
AC_DISABLE_STATIC
AM_PROG_LIBTOOL

PKG_CHECK_MODULES(FUSE, fuse >= 2.2 )
AC_SUBST(FUSE_CFLAGS)
AC_SUBST(FUSE_LIBS)

AM_FERRIS_XERCESC( 2.7.0 )
AM_FERRIS_FUSELAGE( 0.0.2 )
AM_FERRIS_POPT( 1.0.0 )

AC_OUTPUT([
   Makefile
   README
   petardfs.spec
   doc/Makefile
   m4/Makefile
   src/Makefile
   testsuite/Makefile
   testsuite/config/Makefile
   testsuite/petardfs.test/Makefile
   testsuite/sampledata/Makefile
   testsuite/expected_output/Makefile
])

