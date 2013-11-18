# Copyright (C) 2005 BenM <monkeyiq@sf.net>
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

EXTRA_DIST= 

AM_CPPFLAGS =                                           \
	@FUSE_CFLAGS@	                                \
	-I. 						\
	-I$(srcdir) -I$(top_srcdir) 			\
	-I$(top_builddir)				\
        -I$(includedir)                                 \
	@XML4C_CFLAGS@                                  \
	@LIBFUSELAGE_CFLAGS@                            \
	@LIBPOPT_CFLAGS@                                \
	-I/usr/local/include                            

bin_PROGRAMS = petardfs

petardfs_SOURCES = petardfs.cpp
petardfs_CPPFLAGS = -DFUSE_USE_VERSION=25 $(FUSE_CFLAGS)
petardfs_LDADD = $(FUSE_LIBS) @XML4C_LIBS@  @LIBFUSELAGE_LIBS@ @LIBPOPT_LIBS@

