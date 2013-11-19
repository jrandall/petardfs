# Copyright (C) 2006 Ben Martin <monkeyiq@users.sourceforge.net>
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

AC_INIT([petardfs],
        [0.0.2],
        [Ben Martin monkeyiq@users.sourceforge.net],
        [petardfs])
AC_PREREQ([2.69])

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

AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([macros])
AC_CANONICAL_SYSTEM
AC_USE_SYSTEM_EXTENSIONS

LT_INIT([disable-static])
LT_PREREQ([2.4.2])

AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([1.14 tar-ustar dist-bzip2])

		       
AC_PROG_CC   
AC_PROG_CPP
AC_AIX
AC_ISC_POSIX
AC_MINIX
AC_HEADER_STDC

AC_PROG_CXX
AC_PROG_CXXCPP

AC_SYS_LARGEFILE

PKG_CHECK_MODULES([FUSE], [fuse >= 2.2] )
AC_SUBST([FUSE_CFLAGS])
AC_SUBST([FUSE_LIBS])

AM_FERRIS_XERCESC( 2.8.0 )
AM_FERRIS_FUSELAGE( 0.0.2 )
AM_FERRIS_POPT( 1.0.0 )

AC_OUTPUT([
   Makefile
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

