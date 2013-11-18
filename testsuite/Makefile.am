NULL=
SUBDIRS = \
	config                      \
	petardfs.test               \
	sampledata expected_output  

EXTRA_DIST = 

noinst_PROGRAMS = \
	ut_simpleread                 

INCLUDES =                                              \
	@FUSE_CFLAGS@                                   \
	-I. 						\
	-I$(srcdir) -I$(top_srcdir) -I$(top_srcdir)/src	\
	-I$(top_builddir)				\
        -I$(includedir)                                 \
	@CFLAGS@

ut_simpleread_SOURCES = ut_simpleread.cpp ut_common.hh
ut_simpleread_LDADD   = -lpopt 
ut_simpleread_LDFLAGS = $(GLIB_LIBS) @FUSE_LIBS@

