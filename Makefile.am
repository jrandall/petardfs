# Copyright (C) 2005 BenM <monkeyiq@sf.net>
#  
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without 
# modifications, as long as this notice is preserved.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

ACLOCAL_AMFLAGS = -I macros
AUTOMAKE_OPTIONS = dist-bzip2 subdir-objects dejagnu
NULL=

EXTRA_DIST = reconf configure petardfs.spec petardfs.spec.in
SUBDIRS = m4 src doc testsuite

RUNTESTDEFAULTFLAGS = \
	--tool petardfs EXBASE=`pwd`/ SDATA=`pwd`/testsuite/sampledata --srcdir $$srcdir/testsuite

