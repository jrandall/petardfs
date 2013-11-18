dnl @synopsis AC_PATH_GENERIC(LIBRARY [, MINIMUM-VERSION [, ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl
dnl Runs a LIBRARY-config script and defines LIBRARY_CFLAGS and LIBRARY_LIBS
dnl
dnl The script must support `--cflags' and `--libs' args.
dnl If MINIMUM-VERSION is specified, the script must also support the
dnl `--version' arg.
dnl If the `--with-library-[exec-]prefix' arguments to ./configure are given,
dnl it must also support `--prefix' and `--exec-prefix'.
dnl (In other words, it must be like gtk-config.)
dnl
dnl For example:
dnl
dnl    AC_PATH_GENERIC(Foo, 1.0.0)
dnl
dnl would run `foo-config --version' and check that it is at least 1.0.0
dnl
dnl If so, the following would then be defined:
dnl
dnl    FOO_CFLAGS to `foo-config --cflags`
dnl    FOO_LIBS   to `foo-config --libs`
dnl
dnl At present there is no support for additional "MODULES" (see AM_PATH_GTK)
dnl (shamelessly stolen from gtk.m4 and then hacked around a fair amount)
dnl
dnl @author Angus Lees <gusl@cse.unsw.edu.au>
dnl @version $Id: ferrismacros.m4,v 1.6 2007/01/22 21:30:40 ben Exp $

AC_DEFUN([AC_PATH_GENERIC],
[dnl
dnl we're going to need uppercase, lowercase and user-friendly versions of the
dnl string `LIBRARY'
pushdef([UP], translit([$1], [a-z], [A-Z]))dnl
pushdef([DOWN], translit([$1], [A-Z], [a-z]))dnl

dnl
dnl Get the cflags and libraries from the LIBRARY-config script
dnl
AC_ARG_WITH(DOWN-prefix,[  --with-]DOWN[-prefix=PFX       Prefix where $1 is installed (optional)],
        DOWN[]_config_prefix="$withval", DOWN[]_config_prefix="")
AC_ARG_WITH(DOWN-exec-prefix,[  --with-]DOWN[-exec-prefix=PFX Exec prefix where $1 is installed (optional)],
        DOWN[]_config_exec_prefix="$withval", DOWN[]_config_exec_prefix="")

  if test x$DOWN[]_config_exec_prefix != x ; then
     DOWN[]_config_args="$DOWN[]_config_args --exec-prefix=$DOWN[]_config_exec_prefix"
     if test x${UP[]_CONFIG+set} != xset ; then
       UP[]_CONFIG=$DOWN[]_config_exec_prefix/bin/DOWN-config
     fi
  fi
  if test x$DOWN[]_config_prefix != x ; then
     DOWN[]_config_args="$DOWN[]_config_args --prefix=$DOWN[]_config_prefix"
     if test x${UP[]_CONFIG+set} != xset ; then
       UP[]_CONFIG=$DOWN[]_config_prefix/bin/DOWN-config
     fi
  fi

  AC_PATH_PROG(UP[]_CONFIG, DOWN-config, no)
  ifelse([$2], ,
     AC_MSG_CHECKING(for $1),
     AC_MSG_CHECKING(for $1 - version >= $2)
  )
  no_[]DOWN=""
  if test "$UP[]_CONFIG" = "no" ; then
     no_[]DOWN=yes
  else
     UP[]_CFLAGS="`$UP[]_CONFIG $DOWN[]_config_args --cflags`"
     UP[]_LIBS="`$UP[]_CONFIG $DOWN[]_config_args --libs`"
     ifelse([$2], , ,[
        DOWN[]_config_major_version=`$UP[]_CONFIG $DOWN[]_config_args \
         --version | sed 's/[[^0-9]]*\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
        DOWN[]_config_minor_version=`$UP[]_CONFIG $DOWN[]_config_args \
         --version | sed 's/[[^0-9]]*\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
        DOWN[]_config_micro_version=`$UP[]_CONFIG $DOWN[]_config_args \
         --version | sed 's/[[^0-9]]*\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`
        DOWN[]_wanted_major_version="regexp($2, [\<\([0-9]*\)], [\1])"
        DOWN[]_wanted_minor_version="regexp($2, [\<\([0-9]*\)\.\([0-9]*\)], [\2])"
        DOWN[]_wanted_micro_version="regexp($2, [\<\([0-9]*\).\([0-9]*\).\([0-9]*\)], [\3])"

        # Compare wanted version to what config script returned.
        # If I knew what library was being run, i'd probably also compile
        # a test program at this point (which also extracted and tested
        # the version in some library-specific way)
        if test "$DOWN[]_config_major_version" -lt \
                        "$DOWN[]_wanted_major_version" \
          -o \( "$DOWN[]_config_major_version" -eq \
                        "$DOWN[]_wanted_major_version" \
            -a "$DOWN[]_config_minor_version" -lt \
                        "$DOWN[]_wanted_minor_version" \) \
          -o \( "$DOWN[]_config_major_version" -eq \
                        "$DOWN[]_wanted_major_version" \
            -a "$DOWN[]_config_minor_version" -eq \
                        "$DOWN[]_wanted_minor_version" \
            -a "$DOWN[]_config_micro_version" -lt \
                        "$DOWN[]_wanted_micro_version" \) ; then
          # older version found
          no_[]DOWN=yes
          echo -n "*** An old version of $1 "
          echo -n "($DOWN[]_config_major_version"
          echo -n ".$DOWN[]_config_minor_version"
          echo    ".$DOWN[]_config_micro_version) was found."
          echo -n "*** You need a version of $1 newer than "
          echo -n "$DOWN[]_wanted_major_version"
          echo -n ".$DOWN[]_wanted_minor_version"
          echo    ".$DOWN[]_wanted_micro_version."
          echo "***"
          echo "*** If you have already installed a sufficiently new version, this error"
          echo "*** probably means that the wrong copy of the DOWN-config shell script is"
          echo "*** being found. The easiest way to fix this is to remove the old version"
          echo "*** of $1, but you can also set the UP[]_CONFIG environment to point to the"
          echo "*** correct copy of DOWN-config. (In this case, you will have to"
          echo "*** modify your LD_LIBRARY_PATH environment variable, or edit /etc/ld.so.conf"
          echo "*** so that the correct libraries are found at run-time)"
        fi
     ])
  fi
  if test "x$no_[]DOWN" = x ; then
     AC_MSG_RESULT(yes)
     ifelse([$3], , :, [$3])
  else
     AC_MSG_RESULT(no)
     if test "$UP[]_CONFIG" = "no" ; then
       echo "*** The DOWN-config script installed by $1 could not be found"
       echo "*** If $1 was installed in PREFIX, make sure PREFIX/bin is in"
       echo "*** your path, or set the UP[]_CONFIG environment variable to the"
       echo "*** full path to DOWN-config."
     fi
     UP[]_CFLAGS=""
     UP[]_LIBS=""
     ifelse([$4], , :, [$4])
  fi
  AC_SUBST(UP[]_CFLAGS)
  AC_SUBST(UP[]_LIBS)

  popdef([UP])
  popdef([DOWN])
])

################################################################################
################################################################################
################################################################################

#
# Common macros used by many configure.in scripts in the ferris suite.
#

dnl Force the use of libtool and AC_TRY_LINK!
dnl http://www.mail-archive.com/libtool@gnu.org/msg01271.html
AC_DEFUN([AM_FERRIS_LIBTOOL_TRYLINK],
[dnl
dnl
	am_ferris_libtool_trylink_pass=no
	save_CXX=$CXX
	CXX="${SHELL-/bin/sh} ./libtool  --tag=CXX --mode=link $CXX"
	AC_TRY_LINK( [$1], [$2], 
		[ am_ferris_libtool_trylink_pass=yes; ], [ am_ferris_libtool_trylink_pass=no; ] )
	CXX=$save_CXX

	if test x"$am_ferris_libtool_trylink_pass" = xyes; then
		# success
		ifelse([$3], , :, [$3])
	else
		ifelse([$4], , 	[], [$4])     
	fi
])

###############################################################################
###############################################################################
###############################################################################
# Test for stlport 4.5
###############################################################################

dnl
dnl
dnl See AM_FERRIS_STLPORT() for the macro you want to call externally.
dnl
dnl

STLPORT_IO64_CFLAGS=" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 "

dnl
dnl
dnl AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
dnl Used internally to try to link an STLPort using C++ application
dnl using the STLPORT_CFLAGS and STLPORT_LIBS. 
dnl STLPORT_IOSIZE will be set to either 32 or 64 depending on what 
dnl width of IO the found STLPort supports and STLPORT_CFLAGS may be adjusted
dnl for 64 bit building.
dnl 
dnl the STLPORT_CFLAGS etc are all cleared after a failed test.
dnl
AC_DEFUN([AM_FERRIS_STLPORT_INTERNAL_TRYLINK],
[dnl
dnl
	AC_LANG_CPLUSPLUS
	CXXFLAGS_cache=$CXXFLAGS
	CXXFLAGS=" $CXXFLAGS $STLPORT_CFLAGS "
	LDFLAGS_cache=$LDFLAGS
	LDFLAGS=" $LDFLAGS $STLPORT_LIBS "

	AC_TRY_LINK([
		#include <hash_map>
		],
		[
		std::hash_map<int,int> hm;
		hm[5] = 6;
		],
	       	[ferris_stlport_internal_trylink=yes; STLPORT_IOSIZE=32 ],
	       	[ferris_stlport_internal_trylink=no] )

	LDFLAGS=$LDFLAGS_cache
	CXXFLAGS=$CXXFLAGS_cache
	AC_LANG_C

	if test x"$ferris_stlport_internal_trylink" = xno; then
		AC_LANG_CPLUSPLUS
		CXXFLAGS_cache=$CXXFLAGS
		CXXFLAGS=" $CXXFLAGS $STLPORT_IO64_CFLAGS $STLPORT_CFLAGS "
		LDFLAGS_cache=$LDFLAGS
		LDFLAGS=" $LDFLAGS $STLPORT_LIBS "

		AC_TRY_LINK([
			#include <hash_map>
			],
			[
			std::hash_map<int,int> hm;
			hm[5] = 6;
			],
		       	[ferris_stlport_internal_trylink=yes; STLPORT_IOSIZE=64 ],
	       		[ferris_stlport_internal_trylink=no] )

		LDFLAGS=$LDFLAGS_cache
		CXXFLAGS=$CXXFLAGS_cache
		AC_LANG_C
	fi

	if test x"$ferris_stlport_internal_trylink" = xyes; then
	     ifelse([$1], , :, [$1])     
	else
	     ifelse([$2], , :, [$2])     
		if test x"$have_stlport" = xno; then
			STLPORT_CFLAGS=""
			STLPORT_LDFLAGS=""
	 		STLPORT_LIB=""
			STLPORT_LIBS=""
		fi
	fi
])

dnl AM_FERRIS_STLPORT([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate STLPort for installation. 
dnl ie. default is to REQUIRE STLPort MINIMUM-VERSION or stop running.
dnl
dnl MINIMUM-VERSION must be a three part value, like 4.5.0
dnl
dnl Test for STLPort, and define STLPORT_CFLAGS, STLPORT_LIBS and STLPORT_IOSIZE
dnl other side effects include
dnl AM_CONDITIONAL( HAVE_STLPORT, 1 or 0 )
dnl AC_SUBST( STLPORT_CFLAGS )
dnl AC_SUBST( STLPORT_LIBS )
dnl 
dnl if( success ) 
dnl    AC_DEFINE( HAVE_STLPORT )
dnl    AC_DEFINE( STLPORT_IOSIZE )
dnl
AC_DEFUN([AM_FERRIS_STLPORT],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl

stlport_required_version=$1
have_stlport=no

AC_ARG_WITH(stlport,
        [  --with-stlport=DIR          use stlport 4.5+ install rooted at <DIR>],
        [STLPORT_CFLAGS=" -I$withval/stlport "
	 STLPORT_LDFLAGS=" -L$withval/lib "
 	 STLPORT_LIB=" -lstlport_gcc -lpthread "
	 STLPORT_LIBS=" -L$withval/lib ${STLPORT_LIB} "
	 stlport_try_trivial_compile=yes
        ])
if test x"$stlport_try_trivial_compile" = xyes; then
	AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [have_stlport=yes], [have_stlport=no]  )
fi

if test x"$have_stlport" = xno; then

	package=stlport
	version=4.5.3
	PKG_CHECK_MODULES(STLPORT, $package >= $version, [ have_stlport=yes ], [foo=1] )
fi

if test x"$have_stlport" = xno; then

	package=stlport
	version=5.0
	PKG_CHECK_MODULES(STLPORT, $package >= $version, [ have_stlport=yes ], [foo=1] )
fi

if test x"$have_stlport" = xno; then

	AC_LANG_CPLUSPLUS
	STLPORT_IO64_CFLAGS=" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 "

	AC_CHECK_PROG( have_stlportcfg, stlport-config, yes, no )
	
	if test "$have_stlportcfg" = yes; then

#		AC_PATH_GENERIC( STLPORT, 4.5, [ have_stlport=yes ], [foo=2] )
		stlport_installed_version=`stlport-config --version`

		# Calculate the available version number
		[f_tmp=( `echo $stlport_installed_version | sed 's/[^0-9]\+/ /g'` )]
		[f_tmp=$(( 1000000 * ${f_tmp[0]:-0} + 1000 * ${f_tmp[1]:-0} + ${f_tmp[2]:-0} ))]

		[freq_version=( `echo $stlport_required_version | sed 's/[^0-9]\+/ /g'` )]
		[freq_version=$(( 1000000 * ${freq_version[0]:-0} + 1000 * ${freq_version[1]:-0} + ${freq_version[2]:-0} ))]

		if test $freq_version -gt $f_tmp ; then
			AC_MSG_WARN([STLPort version $1 is required, you have $stlport_installed_version])
		else
			have_stlport=yes
			STLPORT_LIBS=" `stlport-config --libs` -lpthread "
			STLPORT_CFLAGS=" `stlport-config --cflags` "
			AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [have_stlport=yes], [have_stlport=no]  )
		fi
	fi
fi

if test x"$have_stlport" = xno; then
	STLPORT_CFLAGS=" -I/usr/local/STLport-4.5/stlport "
	STLPORT_LIB=" -lstlport_gcc -lpthread "
	STLPORT_LIBS=" -L/usr/local/STLport-4.5/lib ${STLPORT_LIB} "

	AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [have_stlport=yes], [have_stlport=no]  )
fi

if test x"$have_stlport" = xno; then
	STLPORT_CFLAGS=" -I/usr/local/include/stlport "
	STLPORT_LIB=" -lstlport_gcc -lpthread "
	STLPORT_LIBS=" -L/usr/local/lib ${STLPORT_LIB} "

	AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [have_stlport=yes], [have_stlport=no]  )
fi

if test x"$have_stlport" = xno; then
	STLPORT_CFLAGS=" -I/usr/include/stlport "
	STLPORT_LIB=" -lstlport_gcc -lpthread "
	STLPORT_LIBS=" -L/usr/lib ${STLPORT_LIB} "

	AM_FERRIS_STLPORT_INTERNAL_TRYLINK( [have_stlport=yes], [have_stlport=no]  )
fi

dnl
dnl just make sure of the assertion that we have a valid STLPort
dnl
if test x"$have_stlport" = xyes; then

	AM_FERRIS_STLPORT_INTERNAL_TRYLINK( 
	[
		AC_DEFINE( HAVE_STLPORT, 1, [Is STLPort 4.5+ installed] )
		AC_DEFINE( STLPORT_IOSIZE, 1, [Width of seekable units in iostreams] )

		echo "Found an STLport that meets required needs..."
		echo "  STLPORT_CFLAGS: $STLPORT_CFLAGS "
		echo "  STLPORT_LIBS:   $STLPORT_LIBS "

		# success
		ifelse([$2], , :, [$2])
	], 
	[
		# fail
		ifelse([$3], , 
		[
			echo ""
			echo "STLPort $version can not be detected on your system. "
			echo ""
			echo "Please make sure that STLPort with IOStreams"
			echo "support is available on your machine before "
			echo "trying again. "
			echo ""
			echo "get it from the URLs below"
			echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
			echo "  http://www.stlport.com/download.html"
			AC_MSG_ERROR([Fatal Error: no STLPort $version or later found.])	
		], 
	[$3])     
	] )
else
	ifelse([$3], , 
	[
echo "cflags:$STLPORT_CFLAGS"
echo "ldflags:$STLPORT_LDFLAGS"
echo "libs:$STLPORT_LIBS"
		echo ""
		echo "STLPort $version can not be detected on your system. "
		echo ""
		echo "Please make sure that STLPort with IOStreams"
		echo "support is available on your machine before "
		echo "trying again. "
		echo ""
		echo "get it from the URLs below"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		echo "  http://www.stlport.com/download.html"
		AC_MSG_ERROR([Fatal Error: no STLPort $version or later found.])	
	], 
	[$3])     
fi

AC_SUBST( STLPORT_CFLAGS )
AC_SUBST( STLPORT_LDFLAGS )
AC_SUBST( STLPORT_LIBS )
AC_SUBST( STLPORT_LIB )
AM_CONDITIONAL(HAVE_STLPORT, test x"$have_stlport" = xyes)

AC_LANG_C
])


dnl AM_FERRIS_STLPORT_OPTIONAL([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to just inform the user that gcc's std/stl are being used.
dnl
dnl MINIMUM-VERSION must be a three part value, like 4.5.0
dnl
dnl Test for STLPort, and define STLPORT_CFLAGS, STLPORT_LIBS and STLPORT_IOSIZE
dnl other side effects include
dnl AM_CONDITIONAL( HAVE_STLPORT, 1 or 0 )
dnl AC_SUBST( STLPORT_CFLAGS )
dnl AC_SUBST( STLPORT_LIBS )
dnl 
dnl if( success ) 
dnl    AC_DEFINE( HAVE_STLPORT )
dnl    AC_DEFINE( STLPORT_IOSIZE )
dnl
AC_DEFUN([AM_FERRIS_STLPORT_OPTIONAL],
[dnl 
dnl

stlport_required_version=$1
have_stlport=no

attempt_to_use_stlport=yes
AC_ARG_ENABLE(stlport,
[--disable-stlport            Don't use STLport even if it is detected],
[
  if test x$enableval = xyes; then
	attempt_to_use_stlport=yes
  else
	attempt_to_use_stlport=no
  fi
])

echo "attempt_to_use_stlport:${attempt_to_use_stlport}"

if test x"$attempt_to_use_stlport" = xyes; then
	version=${stlport_required_version}
	AM_FERRIS_STLPORT( $version, 
	[
		IOSIZE=STLPORT_IOSIZE
		AC_SUBST(IOSIZE)
	],
	[
		echo "No STLport found, attempting to use your compilers std and STL."
	] )
fi

HAVE_STLPORT=y
AM_CONDITIONAL(HAVE_STLPORT, test x"$have_stlport" = xyes)
])


dnl ################################################################################
dnl ################################################################################
dnl ################################################################################
dnl ################################################################################



dnl AM_FERRIS_FERRIS([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libferris for installation. 
dnl ie. default is to REQUIRE libferris MINIMUM-VERSION or stop running.
dnl
dnl FERRIS_CFLAGS and FERRIS_LIBS are set and AC_SUBST()ed when library is found.
dnl LIBFERRIS_CFLAGS and LIBFERRIS_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_FERRIS],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
have_package=no
required_version=$1

package=ferris
version=$required_version
PKG_CHECK_MODULES(FERRIS, $package >= $version,
[
	AC_DEFINE( HAVE_FERRIS, 1, [Have libferris installed] )
	have_package=yes

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
  		echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "this should be on the freshrpms.net website"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AM_CONDITIONAL(HAVE_FERRIS, test x"$have_package" = xyes)
AC_SUBST(FERRIS_CFLAGS)
AC_SUBST(FERRIS_LIBS)
LIBFERRIS_CFLAGS="$FERRIS_CFLAGS"
LIBFERRIS_LIBS="$FERRIS_LIBS"
AC_SUBST(LIBFERRIS_CFLAGS)
AC_SUBST(LIBFERRIS_LIBS)
])


dnl AM_FERRIS_FERRISUI([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libferris for installation. 
dnl ie. default is to REQUIRE libferris MINIMUM-VERSION or stop running.
dnl
dnl FERRISUI_CFLAGS and FERRISUI_LIBS are set and AC_SUBST()ed when library is found.
dnl LIBFERRISUI_CFLAGS and LIBFERRISUI_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_FERRISUI],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
have_package=no
required_version=$1

package=ferrisui
version=$required_version
PKG_CHECK_MODULES(FERRISUI, $package >= $version,
[
	AC_DEFINE( HAVE_FERRISUI, 1, [have libferrisui installed] )
	have_package=yes

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
  		echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "this should be on the freshrpms.net website"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AM_CONDITIONAL(HAVE_FERRISUI, test x"$have_package" = xyes)
AC_SUBST(FERRISUI_CFLAGS)
AC_SUBST(FERRISUI_LIBS)
LIBFERRISUI_CFLAGS="$FERRISUI_CFLAGS"
LIBFERRISUI_LIBS="$FERRISUI_LIBS"
AC_SUBST(LIBFERRISUI_CFLAGS)
AC_SUBST(LIBFERRISUI_LIBS)
])


dnl AM_FERRIS_SIGC([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate sigc++ for installation. 
dnl ie. default is to REQUIRE sigc++ MINIMUM-VERSION or stop running.
dnl
dnl SIGC_CFLAGS and SIGC_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_SIGC],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
have_package=no
sigc_required_version=$1

AC_ARG_WITH(sigcxx-2x,
AC_HELP_STRING([--with-sigcxx-2x=no],[use sigc++ 2.x, --with-sigcxx-2x=yes enables]),
[  ac_use_sigcxx_2=$withval
], ac_use_sigcxx_2="no"
)

package=sigc++-1.2
if test x"$ac_use_sigcxx_2" = xyes; then
	package=sigc++-2.0
fi
version=$sigc_required_version
PKG_CHECK_MODULES(SIGC, $package >= $version,
[
	AC_DEFINE( HAVE_SIGC, 1, [Is sigc++ installed] )

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
  		echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "this should be on the freshrpms.net website"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])

AC_SUBST(SIGC_CFLAGS)
AC_SUBST(SIGC_LIBS)
])


dnl AM_FERRIS_LOKI([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate ferrisloki for installation. 
dnl ie. default is to REQUIRE ferrisloki MINIMUM-VERSION or stop running.
dnl
dnl LOKI_CFLAGS and LOKI_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_LOKI],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
required_version=$1

package=ferrisloki
version=$required_version
PKG_CHECK_MODULES(LOKI, $package >= $version, 
[
	AC_DEFINE( HAVE_LOKI, 1, [is the libferrisloki library installed] )

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AC_SUBST(LOKI_CFLAGS)
AC_SUBST(LOKI_LIBS)
])


dnl AM_FERRIS_STREAMS([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate ferrisstreams for installation. 
dnl ie. default is to REQUIRE ferrisstreams MINIMUM-VERSION or stop running.
dnl
dnl STREAMS_CFLAGS and STREAMS_LIBS are set and AC_SUBST()ed when library is found.
dnl FSTREAM_CFLAGS and FSTREAM_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_STREAMS],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
required_version=$1

package=ferrisstreams
version=$required_version
PKG_CHECK_MODULES(STREAMS, $package >= $version, 
[
	AC_DEFINE( HAVE_STREAMS, 1, [Is libferrisstreams installed] )

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AC_SUBST(STREAMS_CFLAGS)
AC_SUBST(STREAMS_LIBS)

FSTREAM_CFLAGS=$STREAMS_CFLAGS
FSTREAM_LIBS=$STREAMS_LIBS
AC_SUBST(FSTREAM_CFLAGS)
AC_SUBST(FSTREAM_LIBS)
])


dnl AM_FERRIS_STLDB4([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate stldb4 for installation. 
dnl ie. default is to REQUIRE stldb4 MINIMUM-VERSION or stop running.
dnl
dnl STLDB4_CFLAGS and STLDB4_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_STLDB4],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
required_version=$1

package=stldb4
version=$required_version
PKG_CHECK_MODULES(STLDB4, $package >= $version, 
[
	AC_DEFINE( HAVE_STLDB4, 1, [have libstldb4] )

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AC_SUBST(STLDB4_CFLAGS)
AC_SUBST(STLDB4_LIBS)
])


dnl AM_FERRIS_FAMPP2([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate fampp2 for installation. 
dnl ie. default is to REQUIRE fampp2 MINIMUM-VERSION or stop running.
dnl
dnl FAMPP2_CFLAGS and FAMPP2_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_FAMPP2],
[dnl 
dnl Get the cflags and libraries from pkg-config or x-config
dnl
required_version=$1

package=fampp2
version=$required_version
AC_PATH_GENERIC(FAMPP2, $version, 
[
	AC_DEFINE( HAVE_FAMPP2, 1, [Is fampp2 installed] )

	# success
	ifelse([$2], , :, [$2])
],
[
	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	])
AC_SUBST(FAMPP2_CFLAGS)
AC_SUBST(FAMPP2_LIBS)
])


dnl
dnl
dnl AM_FERRIS_INTERNAL_TRYLINK( CFLAGS, LIBS, HEADERS, BODY, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
dnl Used internally to try to link to a library using C++ application
dnl using the CFLAGS and LIBS. 
dnl
AC_DEFUN([AM_FERRIS_INTERNAL_TRYLINK],
[dnl
dnl
	AC_LANG_CPLUSPLUS
	CXXFLAGS_cache=$CXXFLAGS
	CXXFLAGS=" $CXXFLAGS $1 "
	LDFLAGS_cache=$LDFLAGS
	LDFLAGS=" $LDFLAGS $2 "

	AC_TRY_LINK([
		$3
		],
		[
		$4
		],
	       	[trylink_passed=yes ],
	       	[trylink_passed=no] )

	LDFLAGS=$LDFLAGS_cache
	CXXFLAGS=$CXXFLAGS_cache
	AC_LANG_C

	if test x"$trylink_passed" = xyes; then
	     ifelse([$5], , :, [$5])     
	else
	     ifelse([$6], , :, [$6])     
	fi
])

dnl
dnl
dnl AM_FERRIS_INTERNAL_TRYRUN( CFLAGS, LIBS, HEADERS, BODY, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
dnl Used internally to try to link to a library using C++ application
dnl using the CFLAGS and LIBS. 
dnl
AC_DEFUN([AM_FERRIS_INTERNAL_TRYRUN],
[dnl
dnl
	AC_LANG_CPLUSPLUS
	CXXFLAGS_cache=$CXXFLAGS
	CXXFLAGS=" $CXXFLAGS $1 "
	LDFLAGS_cache=$LDFLAGS
	LDFLAGS=" $LDFLAGS $2 "

	AC_TRY_RUN([
		$3
		
		int main( int argc, char** argv ) {
			$4
			return 0; }
		],
	       	[trylink_passed=yes ],
	       	[trylink_passed=no] )

	LDFLAGS=$LDFLAGS_cache
	CXXFLAGS=$CXXFLAGS_cache
	AC_LANG_C

	if test x"$trylink_passed" = xyes; then
	     ifelse([$5], , :, [$5])     
	else
	     ifelse([$6], , :, [$6])     
	fi
])


dnl AM_FERRIS_XERCESC([EXACT-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate xerces-c for installation. 
dnl ie. default is to REQUIRE xerces-c EXACT-VERSION or stop running.
dnl
dnl XERCESC_CFLAGS and XERCESC_LIBS are set and AC_SUBST()ed when library is found.
dnl XML4C_CFLAGS   and XML4C_LIBS   are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_XML4C) and AC_DEFINE(HAVE_XERCESC)
dnl
AC_DEFUN([AM_FERRIS_XERCESC],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
have_package=no
required_version=$1
have_xml4c=no

package=xerces-c
version=$required_version
PKG_CHECK_MODULES(XERCESC, $package = $version, [ have_package=yes ], [ have_package=no ] )
dnl if test x"$have_package" = xno; then
dnl 	AC_PATH_GENERIC(XERCES-C, $version, [ have_package=yes ], [ have_package=no ] )
dnl fi

INCLUDES="$(cat <<-HEREDOC
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/util/XMLString.hpp>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/util/XercesVersion.hpp>
#include <iostream.h> 
XERCES_CPP_NAMESPACE_USE
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
    // Initialize the XML4C2 system.
    try
    {
        XMLPlatformUtils::Initialize();
    }

    catch(const XMLException& toCatch)
    {
        char *pMsg = XMLString::transcode(toCatch.getMessage());
        cerr << "Error during Xerces-c Initialization.\n"
             << "  Exception message:"
             << pMsg;
        XMLString::release(&pMsg);
        return 1;
    }

    
    if( XERCES_VERSION_MAJOR != 2 && XERCES_VERSION_MINOR != 2 )
    {
        return 1;
    }
HEREDOC
)"

if test x"$have_package" = xno; then
AC_ARG_WITH(xercesc,
        [  --with-xercesc=DIR          use xercesc $version install rooted at <DIR>],
        [XERCESC_CFLAGS=" -I$withval/xercesc "
	 XERCESC_LIBS=" -L$withval/lib -lxerces-c " 
	 AM_FERRIS_INTERNAL_TRYRUN( [$XERCESC_CFLAGS], [$XERCESC_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_package=yes], [have_package=no] )
	])
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	XERCESC_CFLAGS=" -I/usr/include/xercesc "
	XERCESC_LIBS=" -L/usr/lib -lxerces-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XERCESC_CFLAGS], [$XERCESC_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi
# try to hit it directly.
if test x"$have_package" = xno; then
	XERCESC_CFLAGS=" -I/usr/local/include/xercesc "
	XERCESC_LIBS=" -L/usr/local/lib -lxerces-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XERCESC_CFLAGS], [$XERCESC_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi


if test x"$have_package" = xyes; then
	have_xml4c=yes
	AC_DEFINE( HAVE_XERCESC, 1, [Is Xerces-C installed])
	AC_DEFINE( HAVE_XML4C, 1, [Is Xerces-C installed])

	echo "Found an xerces-c that meets required needs..."
	echo "  XERCESC_CFLAGS: $XERCESC_CFLAGS "
	echo "  XERCESC_LIBS:   $XERCESC_LIBS "

	# success
	ifelse([$2], , :, [$2])
else
	ifelse([$3], , 
	[
		have_xml4c=no
		echo ""
		echo "explicit version ($version) of $package required. "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi

AC_SUBST(XERCESC_CFLAGS)
AC_SUBST(XERCESC_LIBS)

AM_CONDITIONAL(HAVE_XML4C, test x"$have_xml4c" = xyes)
XML4C_CFLAGS=$XERCESC_CFLAGS
XML4C_LIBS=$XERCESC_LIBS
AC_SUBST(XML4C_CFLAGS)
AC_SUBST(XML4C_LIBS)

])


dnl AM_FERRIS_XALAN([EXACT-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate xerces-c for installation. 
dnl ie. default is to REQUIRE xerces-c EXACT-VERSION or stop running.
dnl
dnl XALAN_CFLAGS and XALAN_LIBS are set and AC_SUBST()ed when library is found.
dnl XML4C_CFLAGS   and XML4C_LIBS   are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_XML4C) and AC_DEFINE(HAVE_XALAN)
dnl
AC_DEFUN([AM_FERRIS_XALAN],
[dnl 
dnl Get the cflags and libraries from pkg-config, stlport-config or attempt to
dnl detect the STLPort on the users system.
dnl
required_version=$1
have_xalan=no

package=xalan-c
version=$required_version

PKG_CHECK_MODULES(XALAN, $package >= $version, [ have_xalan=yes ],  [ have_xalan=no ] )

INCLUDES="$(cat <<-HEREDOC
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/util/XMLString.hpp>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/util/XercesVersion.hpp>
#include <Include/XalanVersion.hpp>
#include <iostream.h> 
XERCES_CPP_NAMESPACE_USE
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
    // Initialize the XML4C2 system.
    try
    {
        XMLPlatformUtils::Initialize();
    }

    catch(const XMLException& toCatch)
    {
        char *pMsg = XMLString::transcode(toCatch.getMessage());
        cerr << "Error during Xerces-c Initialization.\n"
             << "  Exception message:"
             << pMsg;
        XMLString::release(&pMsg);
        return 1;
    }

    
    if( XALAN_VERSION_MAJOR != 1 && XALAN_VERSION_MINOR != 5 )
    {
        return 1;
    }
HEREDOC
)"


if test x"$have_xalan" = xno; then
AC_ARG_WITH(xalan,
        [  --with-xalan=DIR          use xalan $version install rooted at <DIR>],
        [XALAN_CFLAGS=" $XERCESC_CFLAGS -I$withval/xalan-c1.8 "
	 XALAN_LIBS=" $XERCESC_LIBS -L$withval/lib -lxalan-c1_8_0 " 
	 AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_xalan=yes], [have_xalan=no] )
	])
fi

# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/include/xalan-c1.8 "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/lib -lxalan-c1_8_0 "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi
# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/local/include/xalan-c1.8 "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lxalan-c1_8_0 "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi
# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/include/xalan-c "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/lib -lxalan-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi
# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/local/include/xalan-c "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lxalan-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi
# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/include/xalanc "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/lib -lxalan-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi
# try to hit it directly.
if test x"$have_xalan" = xno; then
	XALAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/local/include/xalanc "
	XALAN_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lxalan-c "
	AM_FERRIS_INTERNAL_TRYRUN( [$XALAN_CFLAGS], [$XALAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_xalan=yes], [have_xalan=no] )
fi


if test x"$have_xalan" = xyes; then

	have_xalan=yes
	AC_DEFINE( HAVE_XALAN, 1, [Is Xalan-C installed] )

	echo "Found an xalan-c that meets required needs..."
	echo "  XALAN_CFLAGS: $XALAN_CFLAGS "
	echo "  XALAN_LIBS:   $XALAN_LIBS "

	# success
	ifelse([$2], , :, [$2])

else
	ifelse([$3], , 
	[
		echo ""
		echo "version ($version) or later of $package required. "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi


AM_CONDITIONAL(HAVE_XALAN, test x"$have_xalan" = xyes)
AC_SUBST(XALAN_CFLAGS)
AC_SUBST(XALAN_LIBS)

])


dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################


dnl AM_FERRIS_DTL([EXACT-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to put a message for the user to see that
dnl this module was not found and thus code written for it is not being compiled in.
dnl
dnl DTL_CFLAGS and DTL_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_DTL) and AM_CONDITIONAL(HAVE_DTL)
dnl
AC_DEFUN([AM_FERRIS_DTL],
[{
dnl

required_version=$1
have_dtl=no
package=dtl
version=$required_version

AC_ARG_ENABLE(dtl,
  [AS_HELP_STRING([--enable-dtl],
                  [enable dtl support (default=auto)])],[],[enable_dtl=check])
if test x$enable_dtl != xno; then

	PKG_CHECK_MODULES(DTL, $package >= $version, [ have_dtl=yes ],  [ have_dtl=no ] )

fi


if test x"$have_dtl" = xyes; then

	have_dtl=yes
	AC_DEFINE( HAVE_DTL, 1, [Is DTL installed] )

	echo "Found a DTL ODBC library that meets required needs..."
	echo "  DTL_CFLAGS: $DTL_CFLAGS "
	echo "  DTL_LIBS:   $DTL_LIBS "

	# success
	ifelse([$2], , :, [$2])

else
	ifelse([$3], , 
	[
	echo "Support for DTL version ($version) not being built... "
	], 
	[$3])     
fi

AM_CONDITIONAL(HAVE_DTL, test x"$have_dtl" = xyes)
AC_SUBST(DTL_CFLAGS)
AC_SUBST(DTL_LIBS)
}])

dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################


AC_DEFUN([AM_FERRIS_BOOST_INTERNAL_TRYLINK],
[dnl 
dnl
	AC_LANG_CPLUSPLUS
	CXXFLAGS_cache=$CXXFLAGS
	CXXFLAGS=" $CXXFLAGS $STLPORT_CFLAGS $BOOST_CFLAGS "
	LDFLAGS_cache=$LDFLAGS
	LDFLAGS=" $LDFLAGS $STLPORT_LIBS $BOOST_LIBS "

	AM_FERRIS_LIBTOOL_TRYLINK([

		#include <fstream>

		#include <boost/spirit.hpp>
		using namespace boost::spirit;

		#include <boost/spirit.hpp>
		using namespace boost;

		#include <boost/archive/text_oarchive.hpp>
		#include <boost/archive/text_iarchive.hpp>
		#include <boost/archive/binary_oarchive.hpp>
		#include <boost/archive/binary_iarchive.hpp>
		#include <boost/serialization/list.hpp>
		#include <boost/serialization/set.hpp>
		#include <boost/serialization/map.hpp>
		],
		[
		rule<>  r = real_p >> *(ch_p(',') >> real_p);

	            std::ifstream ifs( "/tmp/doesnt-matter-no-exist" );
        	    boost::archive::binary_iarchive archive( ifs );

		],
	       	[ have_boost=yes; ],
	       	[ have_boost=no; ] )

	LDFLAGS=$LDFLAGS_cache
	CXXFLAGS=$CXXFLAGS_cache
	AC_LANG_C
])

dnl AM_FERRIS_BOOST([MIN-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to put a message for the user to see that
dnl this module was not found and thus code written for it is not being compiled in.
dnl
dnl BOOST_CFLAGS and BOOST_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_BOOST) and AM_CONDITIONAL(HAVE_BOOST)
dnl
AC_DEFUN([AM_FERRIS_BOOST],
[dnl 
dnl
required_version=$1
have_boost=no

package=boost
version=$required_version

AC_LANG_CPLUSPLUS

BOOST_CFLAGS=""
BOOST_LIBS=" -lboost_wserialization -lboost_serialization -lboost_regex "
AM_FERRIS_BOOST_INTERNAL_TRYLINK

if test x"$have_boost" = xno; then
	BOOST_CFLAGS=" -I/usr/local/include "
	BOOST_LIBS=" -L/usr/local/lib -lboost_wserialization -lboost_serialization -lboost_regex "
	AM_FERRIS_BOOST_INTERNAL_TRYLINK
fi

if test x"$have_boost" = xno; then
	if test "x$HAVE_STLPORT"="xy"; then
		BOOST_CFLAGS=" $STLPORT_CFLAGS "
		BOOST_LIBS=" $STLPORT_LIBS -lboost_wserialization-gcc-p  -lboost_serialization-gcc-p "
		AM_FERRIS_BOOST_INTERNAL_TRYLINK
	fi
fi

if test x"$have_boost" = xyes; then

	have_boost=yes
	AC_DEFINE( HAVE_BOOST, 1,[is the boost library installed] )

	echo "Found a BOOST library that meets required needs..."
	echo "  BOOST_CFLAGS : $BOOST_CFLAGS "
	echo "  BOOST_LIBS   : $BOOST_LIBS "

	# success
	ifelse([$2], , :, [$2])

else
	ifelse([$3], , 
	[
	echo "Support for BOOST version ($version) not being built... "
	], 
	[$3])     
fi

AC_LANG_C
AM_CONDITIONAL(HAVE_BOOST, test x"$have_boost" = xyes)
AC_SUBST(BOOST_CFLAGS)
AC_SUBST(BOOST_LIBS)
])


dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################

dnl 1.2.x test
dnl AM_FERRIS_PATHAN([VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libpathan for installation. 
dnl ie. default is to REQUIRE atleast libpathan VERSION or stop running.
dnl
dnl PATHAN_CFLAGS and PATHAN_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_PATHAN)
dnl
AC_DEFUN([AM_FERRIS_PATHAN],
[dnl 
dnl
have_package=no
required_version=$1
have_pathan=no

package=pathan
version=$required_version
dnl PKG_CHECK_MODULES(PATHAN, $package = $version, [ have_package=yes ], [ have_package=no ] )
dnl if test x"$have_package" = xno; then
dnl 	AC_PATH_GENERIC(PATHAN, $version, [ have_package=yes ], [ have_package=no ] )
dnl fi

INCLUDES="$(cat <<-HEREDOC
#include <iostream>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/parsers/XercesDOMParser.hpp>
#include <xercesc/util/PlatformUtils.hpp>
#include <pathan/Pathan.hpp>
#include <pathan/XPathEvaluator.hpp>
XERCES_CPP_NAMESPACE_USE
using namespace std;
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
  // Standard Xerces-C initalisation code

  try {
    XERCES_CPP_NAMESPACE_QUALIFIER XMLPlatformUtils::Initialize();
  }
  catch(const XERCES_CPP_NAMESPACE_QUALIFIER XMLException& toCatch) {
    cerr << "Error during Xerces-c Initialization.\n"
	 << "Exception message:"
	 << XERCES_CPP_NAMESPACE_QUALIFIER XMLString::transcode(toCatch.getMessage()) << endl;
    return 1;
  }

  XERCES_CPP_NAMESPACE_QUALIFIER XercesDOMParser *xmlParser = new XERCES_CPP_NAMESPACE_QUALIFIER XercesDOMParser();

  //Parse data.xml into a DOM tree

  xmlParser->setDoNamespaces(true);
  xmlParser->parse("data.xml");

  // Retreive the parsed document

  const XERCES_CPP_NAMESPACE_QUALIFIER DOMDocument *document = xmlParser->getDocument();
  XERCES_CPP_NAMESPACE_QUALIFIER DOMNode *documentElement = document->getDocumentElement();

  // Create an XPathEvaluator class

  // This class is used as a factory for creating XPathExpression and
  // XPathNSResolver (it is rarely used for evaluation in the latest
  // spec [31/10/2001], however, and is somewhat misnamed)

  XPathEvaluator *evaluator = XPathEvaluator::createEvaluator();
HEREDOC
)"


if test x"$have_package" = xno; then
AC_ARG_WITH(pathan,
        [  --with-pathan=DIR          use pathan $version install rooted at <DIR>],
        [PATHAN_CFLAGS=" $XERCESC_CFLAGS -I$withval/pathan "
	 PATHAN_LIBS=" $XERCESC_LIBS -L$withval/lib -lpathan " 
	 AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN_CFLAGS], [$PATHAN_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_package=yes], [have_package=no] )
	])
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	PATHAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/include/pathan "
	PATHAN_LIBS=" $XERCESC_LIBS -L/usr/lib -lpathan "
	AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN_CFLAGS], [$PATHAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi
# try to hit it directly.
if test x"$have_package" = xno; then
	PATHAN_CFLAGS=" $XERCESC_CFLAGS -I/usr/local/include/pathan "
	PATHAN_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lpathan "
	AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN_CFLAGS], [$PATHAN_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi


if test x"$have_package" = xyes; then
	have_pathan=yes
	AC_DEFINE( HAVE_PATHAN,1,[is libpathan installed] )

	echo "Found an pathan that meets required needs..."
	echo "  PATHAN_CFLAGS: $PATHAN_CFLAGS "
	echo "  PATHAN_LIBS:   $PATHAN_LIBS "

	# success
	ifelse([$2], , :, [$2])
else
	PATHAN_CFLAGS=
	PATHAN_LIBS=
	ifelse([$3], , 
	[
		have_pathan=no
		echo ""
		echo "version ($version) or later of $package required. "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi

AC_SUBST(PATHAN_CFLAGS)
AC_SUBST(PATHAN_LIBS)

AM_CONDITIONAL(HAVE_PATHAN, test x"$have_pathan" = xyes)

])

dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################

dnl 2.0.x test
dnl AM_FERRIS_PATHAN2([VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libpathan for installation. 
dnl ie. default is to REQUIRE atleast libpathan VERSION or stop running.
dnl
dnl PATHAN2_CFLAGS and PATHAN2_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_PATHAN2)
dnl
AC_DEFUN([AM_FERRIS_PATHAN2],
[dnl 
dnl
have_package=no
required_version=$1
have_pathan2=no

package=pathan2
version=$required_version
dnl PKG_CHECK_MODULES(PATHAN2, $package = $version, [ have_package=yes ], [ have_package=no ] )
dnl if test x"$have_package" = xno; then
dnl 	AC_PATH_GENERIC(PATHAN2, $version, [ have_package=yes ], [ have_package=no ] )
dnl fi

INCLUDES="$(cat <<-HEREDOC
#include <iostream>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/parsers/XercesDOMParser.hpp>
#include <xercesc/util/PlatformUtils.hpp>
#include <pathan/Pathan.hpp>
#include <pathan/PathanEngine.hpp>
#include <include/pathan/internal/dom-extensions/PathanExpressionImpl.hpp>
XERCES_CPP_NAMESPACE_USE
using namespace std;
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
  // Standard Xerces-C initalisation code

  try {
    XERCES_CPP_NAMESPACE_QUALIFIER XMLPlatformUtils::Initialize();
  }
  catch(const XERCES_CPP_NAMESPACE_QUALIFIER XMLException& toCatch) {
    cerr << "Error during Xerces-c Initialization.\n"
	 << "Exception message:"
	 << XERCES_CPP_NAMESPACE_QUALIFIER XMLString::transcode(toCatch.getMessage()) << endl;
    return 1;
  }

  XERCES_CPP_NAMESPACE_QUALIFIER XercesDOMParser *xmlParser = new XERCES_CPP_NAMESPACE_QUALIFIER XercesDOMParser();

  //Parse data.xml into a DOM tree

  xmlParser->setDoNamespaces(true);
  xmlParser->parse("data.xml");

  // Retreive the parsed document

  const XERCES_CPP_NAMESPACE_QUALIFIER DOMDocument *document = xmlParser->getDocument();
  XERCES_CPP_NAMESPACE_QUALIFIER DOMNode *documentElement = document->getDocumentElement();

  // Create an XPathEvaluator class

  // This class is used as a factory for creating XPathExpression and
  // XPathNSResolver (it is rarely used for evaluation in the latest
  // spec [31/10/2001], however, and is somewhat misnamed)

  XPath2MemoryManager* mm = PathanEngine::createMemoryManager();
  PathanNSResolver* res = PathanEngine::createNSResolver( documentElement, mm );

HEREDOC
)"

AC_ARG_WITH(pathan2-source,
        [  --with-pathan2-source=DIR          use pathan2 source code tree $version rooted at <DIR>],
        [PATHAN2_SOURCEDIR_CFLAGS=" -I$withval "
	 PATHAN2_SOURCEDIR="$withval" 
	])


if test x"$have_package" = xno; then
AC_ARG_WITH(pathan2,
        [  --with-pathan2=DIR          use pathan2 $version install rooted at <DIR>],
        [PATHAN2_CFLAGS=" $XERCESC_CFLAGS $PATHAN2_SOURCEDIR_CFLAGS -I$withval/pathan "
	 PATHAN2_LIBS=" $XERCESC_LIBS -L$withval/lib -lpathan " 
	 AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN2_CFLAGS], [$PATHAN2_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_package=yes], [have_package=no] )
	])
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	PATHAN2_CFLAGS=" $XERCESC_CFLAGS $PATHAN2_SOURCEDIR_CFLAGS -I/usr/include/pathan "
	PATHAN2_LIBS=" $XERCESC_LIBS -L/usr/lib -lpathan "
	AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN2_CFLAGS], [$PATHAN2_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi
# try to hit it directly.
if test x"$have_package" = xno; then
	PATHAN2_CFLAGS=" $XERCESC_CFLAGS $PATHAN2_SOURCEDIR_CFLAGS -I/usr/local/include/pathan "
	PATHAN2_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lpathan "
	AM_FERRIS_INTERNAL_TRYLINK( [$PATHAN2_CFLAGS], [$PATHAN2_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi


if test x"$have_package" = xyes; then
	have_pathan2=yes
	AC_DEFINE( HAVE_PATHAN2,1,[is libpathan installed] )

	echo "Found a pathan2 that meets required needs..."
	echo "  PATHAN2_CFLAGS: $PATHAN2_CFLAGS "
	echo "  PATHAN2_LIBS:   $PATHAN2_LIBS "

	# success
	ifelse([$2], , :, [$2])
else
	PATHAN2_CFLAGS=
	PATHAN2_LIBS=
	ifelse([$3], , 
	[
		have_pathan2=no
		echo ""
		echo "version ($version) or later of $package required. "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi

AC_SUBST(PATHAN2_CFLAGS)
AC_SUBST(PATHAN2_LIBS)

AM_CONDITIONAL(HAVE_PATHAN2, test x"$have_pathan2" = xyes)

])

dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################

dnl AM_FERRIS_XQILLA([VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libxqilla for installation. 
dnl ie. default is to REQUIRE atleast libxqilla VERSION or stop running.
dnl
dnl XQILLA_CFLAGS and XQILLA_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_XQILLA)
dnl
AC_DEFUN([AM_FERRIS_XQILLA],
[dnl 
dnl
have_package=no
required_version=$1
have_xqilla=no

package=xqilla
version=$required_version
dnl PKG_CHECK_MODULES(XQILLA, $package = $version, [ have_package=yes ], [ have_package=no ] )
dnl if test x"$have_package" = xno; then
dnl 	AC_PATH_GENERIC(XQILLA, $version, [ have_package=yes ], [ have_package=no ] )
dnl fi

INCLUDES="$(cat <<-HEREDOC
#include <iostream>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/framework/StdOutFormatTarget.hpp>
#include <xqilla/xqilla-dom3.hpp>

XERCES_CPP_NAMESPACE_USE;
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC

    // Initialise Xerces-C and XQilla using XQillaPlatformUtils
    XQillaPlatformUtils::initialize();

HEREDOC
)"

AC_ARG_WITH(xqilla-source,
        [  --with-xqilla-source=DIR          use xqilla source code tree $version rooted at <DIR>],
        [XQILLA_SOURCEDIR_CFLAGS=" -I$withval "
	 XQILLA_SOURCEDIR="$withval" 
	])


if test x"$have_package" = xno; then
AC_ARG_WITH(xqilla,
        [  --with-xqilla=DIR          use xqilla $version install rooted at <DIR>],
        [XQILLA_CFLAGS=" $XERCESC_CFLAGS $XQILLA_SOURCEDIR_CFLAGS -I$withval/xqilla "
	 XQILLA_LIBS=" $XERCESC_LIBS -L$withval/lib -lxqilla " 
	 AM_FERRIS_INTERNAL_TRYLINK( [$XQILLA_CFLAGS], [$XQILLA_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_package=yes], [have_package=no] )
	])
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	XQILLA_CFLAGS=" $XERCESC_CFLAGS $XQILLA_SOURCEDIR_CFLAGS -I/usr/include/xqilla "
	XQILLA_LIBS=" $XERCESC_LIBS -L/usr/lib -lxqilla "
	AM_FERRIS_INTERNAL_TRYLINK( [$XQILLA_CFLAGS], [$XQILLA_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi
# try to hit it directly.
if test x"$have_package" = xno; then
	XQILLA_CFLAGS=" $XERCESC_CFLAGS $XQILLA_SOURCEDIR_CFLAGS -I/usr/local/include/xqilla "
	XQILLA_LIBS=" $XERCESC_LIBS -L/usr/local/lib -lxqilla "
	AM_FERRIS_INTERNAL_TRYLINK( [$XQILLA_CFLAGS], [$XQILLA_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi


if test x"$have_package" = xyes; then
	have_xqilla=yes
	AC_DEFINE( HAVE_XQILLA,1,[is libxqilla installed] )

	echo "Found a xqilla that meets required needs..."
	echo "  XQILLA_CFLAGS: $XQILLA_CFLAGS "
	echo "  XQILLA_LIBS:   $XQILLA_LIBS "

	# success
	ifelse([$2], , :, [$2])
else
	XQILLA_CFLAGS=
	XQILLA_LIBS=
	ifelse([$3], , 
	[
		have_xqilla=no
		echo ""
		echo "version ($version) or later of $package required. "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi

AC_SUBST(XQILLA_CFLAGS)
AC_SUBST(XQILLA_LIBS)

AM_CONDITIONAL(HAVE_XQILLA, test x"$have_xqilla" = xyes)

])


dnl ######################################################################
dnl ######################################################################
dnl ######################################################################
dnl ######################################################################

dnl AM_FERRIS_SOCKETPP([VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to just print a didn't find optional pkg msg.
dnl
dnl SOCKETPP_CFLAGS and SOCKETPP_LIBS are set and AC_SUBST()ed when library is found.
dnl AC_DEFINE(HAVE_SOCKETPP)
dnl AM_CONDITIONAL(HAVE_SOCKETPP
dnl
AC_DEFUN([AM_FERRIS_SOCKETPP],
[dnl 
dnl
have_package=no
required_version=$1
have_socketpp=no

package=socketpp
version=$required_version
dnl PKG_CHECK_MODULES(SOCKETPP, $package = $version, [ have_package=yes ], [ have_package=no ] )
dnl if test x"$have_package" = xno; then
dnl 	AC_PATH_GENERIC(SOCKETPP, $version, [ have_package=yes ], [ have_package=no ] )
dnl fi

INCLUDES="$(cat <<-HEREDOC
#include <socket++/sockinet.h>
#include <socket++/sockstream.h>
#include <socket++/sockunix.h>
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
    iosockinet* sock_ss = 0;
    sock_ss = new iosockinet( sockbuf::sock_stream );
    (*sock_ss)->connect( "localhost", 80 );
HEREDOC
)"


if test x"$have_package" = xno; then
AC_ARG_WITH(socketpp,
        [  --with-socketpp=DIR          use socketpp $version install rooted at <DIR>],
        [SOCKETPP_CFLAGS="  -I$withval/include "
	 SOCKETPP_LIBS="  -L$withval/lib -lsocket++ " 
	 AM_FERRIS_INTERNAL_TRYLINK( [$SOCKETPP_CFLAGS], [$SOCKETPP_LIBS], 
					[ $INCLUDES ], [$PROGRAM],
					[have_package=yes], [have_package=no] )
	])
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	SOCKETPP_CFLAGS="  -I/usr/include "
	SOCKETPP_LIBS="  -L/usr/lib -lsocket++ "
	AM_FERRIS_INTERNAL_TRYLINK( [$SOCKETPP_CFLAGS], [$SOCKETPP_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi
# try to hit it directly.
if test x"$have_package" = xno; then
	SOCKETPP_CFLAGS="  -I/usr/local/include "
	SOCKETPP_LIBS="  -L/usr/local/lib -lsocket++ "
	AM_FERRIS_INTERNAL_TRYLINK( [$SOCKETPP_CFLAGS], [$SOCKETPP_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi


if test x"$have_package" = xyes; then
	have_socketpp=yes
	AC_DEFINE( HAVE_SOCKETPP, 1, [Is socket++ installed] )

	echo "Found a socketpp that meets required needs..."
	echo "  SOCKETPP_CFLAGS: $SOCKETPP_CFLAGS "
	echo "  SOCKETPP_LIBS:   $SOCKETPP_LIBS "

	# success
	ifelse([$2], , :, [$2])
else
	ifelse([$3], , 
	[
		have_socketpp=no
		echo "[optional] Didn't find a socketpp that meets required needs..."
dnl 		echo ""
dnl 		echo "version ($version) or later of $package required. "
dnl 		echo ""
dnl 		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
fi

AC_SUBST(SOCKETPP_CFLAGS)
AC_SUBST(SOCKETPP_LIBS)

AM_CONDITIONAL(HAVE_SOCKETPP, test x"$have_socketpp" = xyes)

])



dnl
dnl ************************************************************
dnl 
dnl KDE detection
dnl 
dnl ************************************************************
dnl

dnl    This file is part of the KDE libraries/packages
dnl    Copyright (C) 1997 Janos Farkas (chexum@shadow.banki.hu)
dnl              (C) 1997,98,99 Stephan Kulow (coolo@kde.org)

dnl    This file is free software; you can redistribute it and/or
dnl    modify it under the terms of the GNU Library General Public
dnl    License as published by the Free Software Foundation; either
dnl    version 2 of the License, or (at your option) any later version.

dnl    This library is distributed in the hope that it will be useful,
dnl    but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl    Library General Public License for more details.

dnl    You should have received a copy of the GNU Library General Public License
dnl    along with this library; see the file COPYING.LIB.  If not, write to
dnl    the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
dnl    Boston, MA 02111-1307, USA.

dnl IMPORTANT NOTE:
dnl Please do not modify this file unless you expect your modifications to be
dnl carried into every other module in the repository. 
dnl
dnl Single-module modifications are best placed in configure.in for kdelibs
dnl and kdebase or configure.in.in if present.

# KDE_PATH_X_DIRECT
dnl Internal subroutine of AC_PATH_X.
dnl Set ac_x_includes and/or ac_x_libraries.
AC_DEFUN([KDE_PATH_X_DIRECT],
[
AC_REQUIRE([KDE_CHECK_LIB64])

if test "$ac_x_includes" = NO; then
  # Guess where to find include files, by looking for this one X11 .h file.
  test -z "$x_direct_test_include" && x_direct_test_include=X11/Intrinsic.h

  # First, try using that file with no special directory specified.
AC_TRY_CPP([#include <$x_direct_test_include>],
[# We can compile using X headers with no special include directory.
ac_x_includes=],
[# Look for the header file in a standard set of common directories.
# Check X11 before X11Rn because it is often a symlink to the current release.
  for ac_dir in               \
    /usr/X11/include          \
    /usr/X11R6/include        \
    /usr/X11R5/include        \
    /usr/X11R4/include        \
                              \
    /usr/include/X11          \
    /usr/include/X11R6        \
    /usr/include/X11R5        \
    /usr/include/X11R4        \
                              \
    /usr/local/X11/include    \
    /usr/local/X11R6/include  \
    /usr/local/X11R5/include  \
    /usr/local/X11R4/include  \
                              \
    /usr/local/include/X11    \
    /usr/local/include/X11R6  \
    /usr/local/include/X11R5  \
    /usr/local/include/X11R4  \
                              \
    /usr/X386/include         \
    /usr/x386/include         \
    /usr/XFree86/include/X11  \
                              \
    /usr/include              \
    /usr/local/include        \
    /usr/unsupported/include  \
    /usr/athena/include       \
    /usr/local/x11r5/include  \
    /usr/lpp/Xamples/include  \
                              \
    /usr/openwin/include      \
    /usr/openwin/share/include \
    ; \
  do
    if test -r "$ac_dir/$x_direct_test_include"; then
      ac_x_includes=$ac_dir
      break
    fi
  done])
fi # $ac_x_includes = NO

if test "$ac_x_libraries" = NO; then
  # Check for the libraries.

  test -z "$x_direct_test_library" && x_direct_test_library=Xt
  test -z "$x_direct_test_function" && x_direct_test_function=XtMalloc

  # See if we find them without any special options.
  # Don't add to $LIBS permanently.
  ac_save_LIBS="$LIBS"
  LIBS="-l$x_direct_test_library $LIBS"
AC_TRY_LINK(, [${x_direct_test_function}()],
[LIBS="$ac_save_LIBS"
# We can link X programs with no special library path.
ac_x_libraries=],
[LIBS="$ac_save_LIBS"
# First see if replacing the include by lib works.
# Check X11 before X11Rn because it is often a symlink to the current release.
for ac_dir in `echo "$ac_x_includes" | sed s/include/lib${kdelibsuff}/` \
    /usr/X11/lib${kdelibsuff}           \
    /usr/X11R6/lib${kdelibsuff}         \
    /usr/X11R5/lib${kdelibsuff}         \
    /usr/X11R4/lib${kdelibsuff}         \
                                        \
    /usr/lib${kdelibsuff}/X11           \
    /usr/lib${kdelibsuff}/X11R6         \
    /usr/lib${kdelibsuff}/X11R5         \
    /usr/lib${kdelibsuff}/X11R4         \
                                        \
    /usr/local/X11/lib${kdelibsuff}     \
    /usr/local/X11R6/lib${kdelibsuff}   \
    /usr/local/X11R5/lib${kdelibsuff}   \
    /usr/local/X11R4/lib${kdelibsuff}   \
                                        \
    /usr/local/lib${kdelibsuff}/X11     \
    /usr/local/lib${kdelibsuff}/X11R6   \
    /usr/local/lib${kdelibsuff}/X11R5   \
    /usr/local/lib${kdelibsuff}/X11R4   \
                                        \
    /usr/X386/lib${kdelibsuff}          \
    /usr/x386/lib${kdelibsuff}          \
    /usr/XFree86/lib${kdelibsuff}/X11   \
                                        \
    /usr/lib${kdelibsuff}               \
    /usr/local/lib${kdelibsuff}         \
    /usr/unsupported/lib${kdelibsuff}   \
    /usr/athena/lib${kdelibsuff}        \
    /usr/local/x11r5/lib${kdelibsuff}   \
    /usr/lpp/Xamples/lib${kdelibsuff}   \
    /lib/usr/lib${kdelibsuff}/X11       \
                                        \
    /usr/openwin/lib${kdelibsuff}       \
    /usr/openwin/share/lib${kdelibsuff} \
    ; \
do
dnl Don't even attempt the hair of trying to link an X program!
  for ac_extension in a so sl; do
    if test -r $ac_dir/lib${x_direct_test_library}.$ac_extension; then
      ac_x_libraries=$ac_dir
      break 2
    fi
  done
done])
fi # $ac_x_libraries = NO
])


dnl ------------------------------------------------------------------------
dnl Find a file (or one of more files in a list of dirs)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_FIND_FILE],
[
$3=NO
for i in $2;
do
  for j in $1;
  do
    echo "configure: __oline__: $i/$j" >&AC_FD_CC
    if test -r "$i/$j"; then
      echo "taking that" >&AC_FD_CC
      $3=$i
      break 2
    fi
  done
done
])

dnl KDE_FIND_PATH(program-name, variable-name, list-of-dirs,
dnl	if-not-found, test-parameter, prepend-path)
dnl
dnl Look for program-name in list-of-dirs+$PATH.
dnl If prepend-path is set, look in $PATH+list-of-dirs instead.
dnl If found, $variable-name is set. If not, if-not-found is evaluated.
dnl test-parameter: if set, the program is executed with this arg,
dnl                 and only a successful exit code is required.
AC_DEFUN([KDE_FIND_PATH],
[
   AC_MSG_CHECKING([for $1])
   if test -n "$$2"; then
        kde_cv_path="$$2";
   else
        kde_cache=`echo $1 | sed 'y%./+-%__p_%'`

        AC_CACHE_VAL(kde_cv_path_$kde_cache,
        [
        kde_cv_path="NONE"
	kde_save_IFS=$IFS
	IFS=':'
	dirs=""
	for dir in $PATH; do
	  dirs="$dirs $dir"
	done
	if test -z "$6"; then  dnl Append dirs in PATH (default)
	  dirs="$3 $dirs"
        else  dnl Prepend dirs in PATH (if 6th arg is set)
	  dirs="$dirs $3"
	fi
	IFS=$kde_save_IFS

        for dir in $dirs; do
	  if test -x "$dir/$1"; then
	    if test -n "$5"
	    then
              evalstr="$dir/$1 $5 2>&1 "
	      if eval $evalstr; then
                kde_cv_path="$dir/$1"
                break
	      fi
            else
		kde_cv_path="$dir/$1"
                break
	    fi
          fi
        done

        eval "kde_cv_path_$kde_cache=$kde_cv_path"

        ])

      eval "kde_cv_path=\"`echo '$kde_cv_path_'$kde_cache`\""

   fi

   if test -z "$kde_cv_path" || test "$kde_cv_path" = NONE; then
      AC_MSG_RESULT(not found)
      $4
   else
      AC_MSG_RESULT($kde_cv_path)
      $2=$kde_cv_path

   fi
])

AC_DEFUN([KDE_MOC_ERROR_MESSAGE],
[
    AC_MSG_ERROR([No Qt meta object compiler (moc) found!
Please check whether you installed Qt correctly.
You need to have a running moc binary.
configure tried to run $ac_cv_path_moc and the test didn't
succeed. If configure shouldn't have tried this one, set
the environment variable MOC to the right one before running
configure.
])
])

AC_DEFUN([KDE_UIC_ERROR_MESSAGE],
[
    AC_MSG_WARN([No Qt ui compiler (uic) found!
Please check whether you installed Qt correctly.
You need to have a running uic binary.
configure tried to run $ac_cv_path_uic and the test didn't
succeed. If configure shouldn't have tried this one, set
the environment variable UIC to the right one before running
configure.
])
])


AC_DEFUN([KDE_CHECK_UIC_FLAG],
[
    AC_MSG_CHECKING([whether uic supports -$1 ])
    kde_cache=`echo $1 | sed 'y% .=/+-%____p_%'`
    AC_CACHE_VAL(kde_cv_prog_uic_$kde_cache,
    [
        cat >conftest.ui <<EOT
        <!DOCTYPE UI><UI version="3" stdsetdef="1"></UI>
EOT
        ac_uic_testrun="$UIC_PATH -$1 $2 conftest.ui >/dev/null"
        if AC_TRY_EVAL(ac_uic_testrun); then
            eval "kde_cv_prog_uic_$kde_cache=yes"
        else
            eval "kde_cv_prog_uic_$kde_cache=no"
        fi
        rm -f conftest*
    ])

    if eval "test \"`echo '$kde_cv_prog_uic_'$kde_cache`\" = yes"; then
        AC_MSG_RESULT([yes])
        :
        $3
    else
        AC_MSG_RESULT([no])
        :
        $4
    fi
])


dnl ------------------------------------------------------------------------
dnl Find the meta object compiler and the ui compiler in the PATH,
dnl in $QTDIR/bin, and some more usual places
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_PATH_QT_MOC_UIC],
[
   AC_REQUIRE([KDE_CHECK_PERL])
   qt_bindirs=""
   for dir in $kde_qt_dirs; do
      qt_bindirs="$qt_bindirs $dir/bin $dir/src/moc"
   done
   qt_bindirs="$qt_bindirs /usr/bin /usr/X11R6/bin /usr/local/qt/bin"
   if test ! "$ac_qt_bindir" = "NO"; then
      qt_bindirs="$ac_qt_bindir $qt_bindirs"
   fi

   KDE_FIND_PATH(moc, MOC, [$qt_bindirs], [KDE_MOC_ERROR_MESSAGE])
   if test -z "$UIC_NOT_NEEDED"; then
     KDE_FIND_PATH(uic, UIC_PATH, [$qt_bindirs], [UIC_PATH=""])
     if test -z "$UIC_PATH" ; then
       KDE_UIC_ERROR_MESSAGE
       exit 1
     else
       UIC=$UIC_PATH

       if test $kde_qtver = 3; then
         KDE_CHECK_UIC_FLAG(L,[/nonexistent],ac_uic_supports_libpath=yes,ac_uic_supports_libpath=no)
         KDE_CHECK_UIC_FLAG(nounload,,ac_uic_supports_nounload=yes,ac_uic_supports_nounload=no)

         if test x$ac_uic_supports_libpath = xyes; then
             UIC="$UIC -L \$(kde_widgetdir)"
         fi
         if test x$ac_uic_supports_nounload = xyes; then
             UIC="$UIC -nounload"
         fi
       fi
     fi
   else
     UIC="echo uic not available: "
   fi

   AC_SUBST(MOC)
   AC_SUBST(UIC)

   UIC_TR="i18n"
   if test $kde_qtver = 3; then
     UIC_TR="tr2i18n"
   fi

   AC_SUBST(UIC_TR)
])

AC_DEFUN([KDE_1_CHECK_PATHS],
[
  KDE_1_CHECK_PATH_HEADERS

  KDE_TEST_RPATH=

  if test -n "$USE_RPATH"; then

     if test -n "$kde_libraries"; then
       KDE_TEST_RPATH="-R $kde_libraries"
     fi

     if test -n "$qt_libraries"; then
       KDE_TEST_RPATH="$KDE_TEST_RPATH -R $qt_libraries"
     fi

     if test -n "$x_libraries"; then
       KDE_TEST_RPATH="$KDE_TEST_RPATH -R $x_libraries"
     fi

     KDE_TEST_RPATH="$KDE_TEST_RPATH $KDE_EXTRA_RPATH"
  fi

AC_MSG_CHECKING([for KDE libraries installed])
ac_link='$LIBTOOL_SHELL --silent --mode=link ${CXX-g++} -o conftest $CXXFLAGS $all_includes $CPPFLAGS $LDFLAGS $all_libraries conftest.$ac_ext $LIBS -lkdecore $LIBQT $KDE_TEST_RPATH 1>&5'

if AC_TRY_EVAL(ac_link) && test -s conftest; then
  AC_MSG_RESULT(yes)
else
  AC_MSG_ERROR([your system fails at linking a small KDE application!
Check, if your compiler is installed correctly and if you have used the
same compiler to compile Qt and kdelibs as you did use now.
For more details about this problem, look at the end of config.log.])
fi

if eval `KDEDIR= ./conftest 2>&5`; then
  kde_result=done
else
  kde_result=problems
fi

KDEDIR= ./conftest 2> /dev/null >&5 # make an echo for config.log
kde_have_all_paths=yes

KDE_SET_PATHS($kde_result)

])

AC_DEFUN([KDE_SET_PATHS],
[
  kde_cv_all_paths="kde_have_all_paths=\"yes\" \
	kde_htmldir=\"$kde_htmldir\" \
	kde_appsdir=\"$kde_appsdir\" \
	kde_icondir=\"$kde_icondir\" \
	kde_sounddir=\"$kde_sounddir\" \
	kde_datadir=\"$kde_datadir\" \
	kde_locale=\"$kde_locale\" \
	kde_cgidir=\"$kde_cgidir\" \
	kde_confdir=\"$kde_confdir\" \
	kde_kcfgdir=\"$kde_kcfgdir\" \
	kde_mimedir=\"$kde_mimedir\" \
	kde_toolbardir=\"$kde_toolbardir\" \
	kde_wallpaperdir=\"$kde_wallpaperdir\" \
	kde_templatesdir=\"$kde_templatesdir\" \
	kde_bindir=\"$kde_bindir\" \
	kde_servicesdir=\"$kde_servicesdir\" \
	kde_servicetypesdir=\"$kde_servicetypesdir\" \
	kde_moduledir=\"$kde_moduledir\" \
	kde_styledir=\"$kde_styledir\" \
	kde_widgetdir=\"$kde_widgetdir\" \
	xdg_appsdir=\"$xdg_appsdir\" \
	xdg_menudir=\"$xdg_menudir\" \
	xdg_directorydir=\"$xdg_directorydir\" \
	kde_result=$1"
])

AC_DEFUN([KDE_SET_DEFAULT_PATHS],
[
if test "$1" = "default"; then

  if test -z "$kde_htmldir"; then
    kde_htmldir='\${datadir}/doc/HTML'
  fi
  if test -z "$kde_appsdir"; then
    kde_appsdir='\${datadir}/applnk'
  fi
  if test -z "$kde_icondir"; then
    kde_icondir='\${datadir}/icons'
  fi
  if test -z "$kde_sounddir"; then
    kde_sounddir='\${datadir}/sounds'
  fi
  if test -z "$kde_datadir"; then
    kde_datadir='\${datadir}/apps'
  fi
  if test -z "$kde_locale"; then
    kde_locale='\${datadir}/locale'
  fi
  if test -z "$kde_cgidir"; then
    kde_cgidir='\${exec_prefix}/cgi-bin'
  fi
  if test -z "$kde_confdir"; then
    kde_confdir='\${datadir}/config'
  fi
  if test -z "$kde_kcfgdir"; then
    kde_kcfgdir='\${datadir}/config.kcfg'
  fi
  if test -z "$kde_mimedir"; then
    kde_mimedir='\${datadir}/mimelnk'
  fi
  if test -z "$kde_toolbardir"; then
    kde_toolbardir='\${datadir}/toolbar'
  fi
  if test -z "$kde_wallpaperdir"; then
    kde_wallpaperdir='\${datadir}/wallpapers'
  fi
  if test -z "$kde_templatesdir"; then
    kde_templatesdir='\${datadir}/templates'
  fi
  if test -z "$kde_bindir"; then
    kde_bindir='\${exec_prefix}/bin'
  fi
  if test -z "$kde_servicesdir"; then
    kde_servicesdir='\${datadir}/services'
  fi
  if test -z "$kde_servicetypesdir"; then
    kde_servicetypesdir='\${datadir}/servicetypes'
  fi
  if test -z "$kde_moduledir"; then
    if test "$kde_qtver" = "2"; then
      kde_moduledir='\${libdir}/kde2'
    else
      kde_moduledir='\${libdir}/kde3'
    fi
  fi
  if test -z "$kde_styledir"; then
    kde_styledir='\${libdir}/kde3/plugins/styles'
  fi
  if test -z "$kde_widgetdir"; then
    kde_widgetdir='\${libdir}/kde3/plugins/designer'
  fi
  if test -z "$xdg_appsdir"; then
    xdg_appsdir='\${datadir}/applications/kde'
  fi
  if test -z "$xdg_menudir"; then
    xdg_menudir='\${sysconfdir}/xdg/menus'
  fi
  if test -z "$xdg_directorydir"; then
    xdg_directorydir='\${datadir}/desktop-directories'
  fi

  KDE_SET_PATHS(defaults)

else

  if test $kde_qtver = 1; then
     AC_MSG_RESULT([compiling])
     KDE_1_CHECK_PATHS
  else
     AC_MSG_ERROR([path checking not yet supported for KDE 2])
  fi

fi
])

AC_DEFUN([KDE_CHECK_PATHS_FOR_COMPLETENESS],
[ if test -z "$kde_htmldir" || test -z "$kde_appsdir" ||
   test -z "$kde_icondir" || test -z "$kde_sounddir" ||
   test -z "$kde_datadir" || test -z "$kde_locale"  ||
   test -z "$kde_cgidir"  || test -z "$kde_confdir" ||
   test -z "$kde_kcfgdir" ||
   test -z "$kde_mimedir" || test -z "$kde_toolbardir" ||
   test -z "$kde_wallpaperdir" || test -z "$kde_templatesdir" ||
   test -z "$kde_bindir" || test -z "$kde_servicesdir" ||
   test -z "$kde_servicetypesdir" || test -z "$kde_moduledir" ||
   test -z "$kde_styledir" || test -z "kde_widgetdir" ||
   test -z "$xdg_appsdir" || test -z "$xdg_menudir" || test -z "$xdg_directorydir" ||
   test "x$kde_have_all_paths" != "xyes"; then
     kde_have_all_paths=no
  fi
])

AC_DEFUN([KDE_MISSING_PROG_ERROR],
[
    AC_MSG_ERROR([The important program $1 was not found!
Please check whether you installed KDE correctly.
])
])

AC_DEFUN([KDE_MISSING_ARTS_ERROR],
[
    AC_MSG_ERROR([The important program $1 was not found!
Please check whether you installed aRts correctly or use
--without-arts to compile without aRts support (this will remove functionality).
])
])

AC_DEFUN([KDE_SET_DEFAULT_BINDIRS],
[
    kde_default_bindirs="/usr/bin /usr/local/bin /opt/local/bin /usr/X11R6/bin /opt/kde/bin /opt/kde3/bin /usr/kde/bin /usr/local/kde/bin"
    test -n "$KDEDIR" && kde_default_bindirs="$KDEDIR/bin $kde_default_bindirs"
    if test -n "$KDEDIRS"; then
       kde_save_IFS=$IFS
       IFS=:
       for dir in $KDEDIRS; do
            kde_default_bindirs="$dir/bin $kde_default_bindirs "
       done
       IFS=$kde_save_IFS
    fi
])

AC_DEFUN([KDE_SUBST_PROGRAMS],
[
    AC_ARG_WITH(arts,
        AC_HELP_STRING([--without-arts],[build without aRts [default=no]]),
        [build_arts=$withval],
        [build_arts=yes]
    )
    AM_CONDITIONAL(include_ARTS, test "$build_arts" '!=' "no")
    if test "$build_arts" = "no"; then
        AC_DEFINE(WITHOUT_ARTS, 1, [Defined if compiling without arts])
    fi

        KDE_SET_DEFAULT_BINDIRS
        kde_default_bindirs="$exec_prefix/bin $prefix/bin $kde_libs_prefix/bin $kde_default_bindirs"
        KDE_FIND_PATH(dcopidl, DCOPIDL, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(dcopidl)])
        KDE_FIND_PATH(dcopidl2cpp, DCOPIDL2CPP, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(dcopidl2cpp)])
        if test "$build_arts" '!=' "no"; then
          KDE_FIND_PATH(mcopidl, MCOPIDL, [$kde_default_bindirs], [KDE_MISSING_ARTS_ERROR(mcopidl)])
          KDE_FIND_PATH(artsc-config, ARTSCCONFIG, [$kde_default_bindirs], [KDE_MISSING_ARTS_ERROR(artsc-config)])
        fi
        KDE_FIND_PATH(meinproc, MEINPROC, [$kde_default_bindirs])

        kde32ornewer=1
        if test -n "$kde_qtver" && test "$kde_qtver" -lt 3; then
            kde32ornewer=
        else
            if test "$kde_qtver" = "3" && test "$kde_qtsubver" -le 1; then
                kde32ornewer=
            fi
        fi

        if test -n "$kde32ornewer"; then
            KDE_FIND_PATH(kconfig_compiler, KCONFIG_COMPILER, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(kconfig_compiler)])
            KDE_FIND_PATH(dcopidlng, DCOPIDLNG, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(dcopidlng)])
        fi
        KDE_FIND_PATH(xmllint, XMLLINT, [${prefix}/bin ${exec_prefix}/bin], [XMLLINT=""])

        if test -n "$MEINPROC" && test ! "$MEINPROC" = "compiled"; then  
 	    kde_sharedirs="/usr/share/kde /usr/local/share /usr/share /opt/kde3/share /opt/kde/share $prefix/share"
            test -n "$KDEDIR" && kde_sharedirs="$KDEDIR/share $kde_sharedirs"
            AC_FIND_FILE(apps/ksgmltools2/customization/kde-chunk.xsl, $kde_sharedirs, KDE_XSL_STYLESHEET)
	    if test "$KDE_XSL_STYLESHEET" = "NO"; then
		KDE_XSL_STYLESHEET=""
	    else
                KDE_XSL_STYLESHEET="$KDE_XSL_STYLESHEET/apps/ksgmltools2/customization/kde-chunk.xsl"
	    fi
        fi

        DCOP_DEPENDENCIES='$(DCOPIDL)'
        if test -n "$kde32ornewer"; then
            KCFG_DEPENDENCIES='$(KCONFIG_COMPILER)'
            DCOP_DEPENDENCIES='$(DCOPIDL) $(DCOPIDLNG)'
            AC_SUBST(KCONFIG_COMPILER)
            AC_SUBST(KCFG_DEPENDENCIES)
            AC_SUBST(DCOPIDLNG)
        fi
        AC_SUBST(DCOPIDL)
        AC_SUBST(DCOPIDL2CPP)
        AC_SUBST(DCOP_DEPENDENCIES)
        AC_SUBST(MCOPIDL)
        AC_SUBST(ARTSCCONFIG)
	AC_SUBST(MEINPROC)
 	AC_SUBST(KDE_XSL_STYLESHEET)
	AC_SUBST(XMLLINT)
])dnl

AC_DEFUN([AC_CREATE_KFSSTND],
[
AC_REQUIRE([AC_CHECK_RPATH])

AC_MSG_CHECKING([for KDE paths])
kde_result=""
kde_cached_paths=yes
AC_CACHE_VAL(kde_cv_all_paths,
[
  KDE_SET_DEFAULT_PATHS($1)
  kde_cached_paths=no
])
eval "$kde_cv_all_paths"
KDE_CHECK_PATHS_FOR_COMPLETENESS
if test "$kde_have_all_paths" = "no" && test "$kde_cached_paths" = "yes"; then
  # wrong values were cached, may be, we can set better ones
  kde_result=
  kde_htmldir= kde_appsdir= kde_icondir= kde_sounddir=
  kde_datadir= kde_locale=  kde_cgidir=  kde_confdir= kde_kcfgdir=
  kde_mimedir= kde_toolbardir= kde_wallpaperdir= kde_templatesdir=
  kde_bindir= kde_servicesdir= kde_servicetypesdir= kde_moduledir=
  kde_have_all_paths=
  kde_styledir=
  kde_widgetdir=
  xdg_appsdir = xdg_menudir= xdg_directorydir= 
  KDE_SET_DEFAULT_PATHS($1)
  eval "$kde_cv_all_paths"
  KDE_CHECK_PATHS_FOR_COMPLETENESS
  kde_result="$kde_result (cache overridden)"
fi
if test "$kde_have_all_paths" = "no"; then
  AC_MSG_ERROR([configure could not run a little KDE program to test the environment.
Since it had compiled and linked before, it must be a strange problem on your system.
Look at config.log for details. If you are not able to fix this, look at
http://www.kde.org/faq/installation.html or any www.kde.org mirror.
(If you're using an egcs version on Linux, you may update binutils!)
])
else
  rm -f conftest*
  AC_MSG_RESULT($kde_result)
fi

bindir=$kde_bindir

KDE_SUBST_PROGRAMS

])

AC_DEFUN([AC_SUBST_KFSSTND],
[
AC_SUBST(kde_htmldir)
AC_SUBST(kde_appsdir)
AC_SUBST(kde_icondir)
AC_SUBST(kde_sounddir)
AC_SUBST(kde_datadir)
AC_SUBST(kde_locale)
AC_SUBST(kde_confdir)
AC_SUBST(kde_kcfgdir)
AC_SUBST(kde_mimedir)
AC_SUBST(kde_wallpaperdir)
AC_SUBST(kde_bindir)
dnl X Desktop Group standards
AC_SUBST(xdg_appsdir)
AC_SUBST(xdg_menudir)
AC_SUBST(xdg_directorydir)
dnl for KDE 2
AC_SUBST(kde_templatesdir)
AC_SUBST(kde_servicesdir)
AC_SUBST(kde_servicetypesdir)
AC_SUBST(kde_moduledir)
AC_SUBST(kdeinitdir, '$(kde_moduledir)')
AC_SUBST(kde_styledir)
AC_SUBST(kde_widgetdir)
if test "$kde_qtver" = 1; then
  kde_minidir="$kde_icondir/mini"
else
# for KDE 1 - this breaks KDE2 apps using minidir, but
# that's the plan ;-/
  kde_minidir="/dev/null"
fi
dnl AC_SUBST(kde_minidir)
dnl AC_SUBST(kde_cgidir)
dnl AC_SUBST(kde_toolbardir)
])

AC_DEFUN([KDE_MISC_TESTS],
[
   dnl Checks for libraries.
   AC_CHECK_LIB(util, main, [LIBUTIL="-lutil"]) dnl for *BSD 
   AC_SUBST(LIBUTIL)
   AC_CHECK_LIB(compat, main, [LIBCOMPAT="-lcompat"]) dnl for *BSD
   AC_SUBST(LIBCOMPAT)
   kde_have_crypt=
   AC_CHECK_LIB(crypt, crypt, [LIBCRYPT="-lcrypt"; kde_have_crypt=yes],
      AC_CHECK_LIB(c, crypt, [kde_have_crypt=yes], [
        AC_MSG_WARN([you have no crypt in either libcrypt or libc.
You should install libcrypt from another source or configure with PAM
support])
	kde_have_crypt=no
      ]))
   AC_SUBST(LIBCRYPT)
   if test $kde_have_crypt = yes; then
      AC_DEFINE_UNQUOTED(HAVE_CRYPT, 1, [Defines if your system has the crypt function])
   fi
   AC_CHECK_SOCKLEN_T
   AC_CHECK_LIB(dnet, dnet_ntoa, [X_EXTRA_LIBS="$X_EXTRA_LIBS -ldnet"])
   if test $ac_cv_lib_dnet_dnet_ntoa = no; then
      AC_CHECK_LIB(dnet_stub, dnet_ntoa,
        [X_EXTRA_LIBS="$X_EXTRA_LIBS -ldnet_stub"])
   fi
   AC_CHECK_FUNC(inet_ntoa)
   if test $ac_cv_func_inet_ntoa = no; then
     AC_CHECK_LIB(nsl, inet_ntoa, X_EXTRA_LIBS="$X_EXTRA_LIBS -lnsl")
   fi
   AC_CHECK_FUNC(connect)
   if test $ac_cv_func_connect = no; then
      AC_CHECK_LIB(socket, connect, X_EXTRA_LIBS="-lsocket $X_EXTRA_LIBS", ,
        $X_EXTRA_LIBS)
   fi

   AC_CHECK_FUNC(remove)
   if test $ac_cv_func_remove = no; then
      AC_CHECK_LIB(posix, remove, X_EXTRA_LIBS="$X_EXTRA_LIBS -lposix")
   fi

   # BSDI BSD/OS 2.1 needs -lipc for XOpenDisplay.
   AC_CHECK_FUNC(shmat, ,
     AC_CHECK_LIB(ipc, shmat, X_EXTRA_LIBS="$X_EXTRA_LIBS -lipc"))
   
   # more headers that need to be explicitly included on darwin
   AC_CHECK_HEADERS(sys/types.h stdint.h)

   # sys/bitypes.h is needed for uint32_t and friends on Tru64
   AC_CHECK_HEADERS(sys/bitypes.h)

   # darwin requires a poll emulation library
   AC_CHECK_LIB(poll, poll, LIB_POLL="-lpoll")

   # CoreAudio framework
   AC_CHECK_HEADER(CoreAudio/CoreAudio.h, [
     AC_DEFINE(HAVE_COREAUDIO, 1, [Define if you have the CoreAudio API])
     FRAMEWORK_COREAUDIO="-Xlinker -framework -Xlinker CoreAudio"
   ])

   AC_CHECK_RES_INIT
   AC_SUBST(LIB_POLL)
   AC_SUBST(FRAMEWORK_COREAUDIO)
   LIBSOCKET="$X_EXTRA_LIBS"
   AC_SUBST(LIBSOCKET)
   AC_SUBST(X_EXTRA_LIBS)
   AC_CHECK_LIB(ucb, killpg, [LIBUCB="-lucb"]) dnl for Solaris2.4
   AC_SUBST(LIBUCB)

   case $host in  dnl this *is* LynxOS specific
   *-*-lynxos* )
        AC_MSG_CHECKING([LynxOS header file wrappers])
        [CFLAGS="$CFLAGS -D__NO_INCLUDE_WARN__"]
        AC_MSG_RESULT(disabled)
        AC_CHECK_LIB(bsd, gethostbyname, [LIBSOCKET="-lbsd"]) dnl for LynxOS
         ;;
    esac

   KDE_CHECK_TYPES
   KDE_CHECK_LIBDL
   KDE_CHECK_STRLCPY

# darwin needs this to initialize the environment
AC_CHECK_HEADERS(crt_externs.h)
AC_CHECK_FUNC(_NSGetEnviron, [AC_DEFINE(HAVE_NSGETENVIRON, 1, [Define if your system needs _NSGetEnviron to set up the environment])])
 
AH_VERBATIM(_DARWIN_ENVIRON,
[
#if defined(HAVE_NSGETENVIRON) && defined(HAVE_CRT_EXTERNS_H)
# include <sys/time.h>
# include <crt_externs.h>
# define environ (*_NSGetEnviron())
#endif
])

AH_VERBATIM(_AIX_STRINGS_H_BZERO,
[
/*
 * AIX defines FD_SET in terms of bzero, but fails to include <strings.h>
 * that defines bzero.
 */

#if defined(_AIX)
#include <strings.h>
#endif
])

AC_CHECK_FUNCS([vsnprintf snprintf])

AH_VERBATIM(_TRU64,[
/*
 * On HP-UX, the declaration of vsnprintf() is needed every time !
 */

#if !defined(HAVE_VSNPRINTF) || defined(hpux)
#if __STDC__
#include <stdarg.h>
#include <stdlib.h>
#else
#include <varargs.h>
#endif
#ifdef __cplusplus
extern "C"
#endif
int vsnprintf(char *str, size_t n, char const *fmt, va_list ap);
#ifdef __cplusplus
extern "C"
#endif
int snprintf(char *str, size_t n, char const *fmt, ...);
#endif
])

])

dnl ------------------------------------------------------------------------
dnl Find the header files and libraries for X-Windows. Extended the
dnl macro AC_PATH_X
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([K_PATH_X],
[
AC_REQUIRE([KDE_MISC_TESTS])dnl
AC_REQUIRE([KDE_CHECK_LIB64])

AC_ARG_ENABLE(
  embedded,
  AC_HELP_STRING([--enable-embedded],[link to Qt-embedded, don't use X]),
  kde_use_qt_emb=$enableval,
  kde_use_qt_emb=no
)

AC_ARG_ENABLE(
  qtopia,
  AC_HELP_STRING([--enable-qtopia],[link to Qt-embedded, link to the Qtopia Environment]),
  kde_use_qt_emb_palm=$enableval,
  kde_use_qt_emb_palm=no
)

AC_ARG_ENABLE(
  mac,
  AC_HELP_STRING([--enable-mac],[link to Qt/Mac (don't use X)]),
  kde_use_qt_mac=$enableval,
  kde_use_qt_mac=no
)

if test "$kde_use_qt_emb" = "no" && test "$kde_use_qt_mac" = "no"; then

AC_MSG_CHECKING(for X)

AC_CACHE_VAL(kde_cv_have_x,
[# One or both of the vars are not set, and there is no cached value.
if test "{$x_includes+set}" = set || test "$x_includes" = NONE; then
   kde_x_includes=NO
else
   kde_x_includes=$x_includes
fi
if test "{$x_libraries+set}" = set || test "$x_libraries" = NONE; then
   kde_x_libraries=NO
else
   kde_x_libraries=$x_libraries
fi

# below we use the standard autoconf calls
ac_x_libraries=$kde_x_libraries
ac_x_includes=$kde_x_includes

KDE_PATH_X_DIRECT
dnl AC_PATH_X_XMKMF picks /usr/lib as the path for the X libraries.
dnl Unfortunately, if compiling with the N32 ABI, this is not the correct
dnl location. The correct location is /usr/lib32 or an undefined value
dnl (the linker is smart enough to pick the correct default library).
dnl Things work just fine if you use just AC_PATH_X_DIRECT.
dnl Solaris has a similar problem. AC_PATH_X_XMKMF forces x_includes to
dnl /usr/openwin/include, which doesn't work. /usr/include does work, so
dnl x_includes should be left alone.
case "$host" in
mips-sgi-irix6*)
  ;;
*-*-solaris*)
  ;;
*)
  _AC_PATH_X_XMKMF
  if test -z "$ac_x_includes"; then
    ac_x_includes="."
  fi
  if test -z "$ac_x_libraries"; then
    ac_x_libraries="/usr/lib${kdelibsuff}"
  fi
esac
#from now on we use our own again

# when the user already gave --x-includes, we ignore
# what the standard autoconf macros told us.
if test "$kde_x_includes" = NO; then
  kde_x_includes=$ac_x_includes
fi

# for --x-libraries too
if test "$kde_x_libraries" = NO; then
  kde_x_libraries=$ac_x_libraries
fi

if test "$kde_x_includes" = NO; then
  AC_MSG_ERROR([Can't find X includes. Please check your installation and add the correct paths!])
fi

if test "$kde_x_libraries" = NO; then
  AC_MSG_ERROR([Can't find X libraries. Please check your installation and add the correct paths!])
fi

# Record where we found X for the cache.
kde_cv_have_x="have_x=yes \
         kde_x_includes=$kde_x_includes kde_x_libraries=$kde_x_libraries"
])dnl

eval "$kde_cv_have_x"

if test "$have_x" != yes; then
  AC_MSG_RESULT($have_x)
  no_x=yes
else
  AC_MSG_RESULT([libraries $kde_x_libraries, headers $kde_x_includes])
fi

if test -z "$kde_x_includes" || test "x$kde_x_includes" = xNONE; then
  X_INCLUDES=""
  x_includes="."; dnl better than nothing :-
 else
  x_includes=$kde_x_includes
  X_INCLUDES="-I$x_includes"
fi

if test -z "$kde_x_libraries" || test "x$kde_x_libraries" = xNONE; then
  X_LDFLAGS=""
  x_libraries="/usr/lib"; dnl better than nothing :-
 else
  x_libraries=$kde_x_libraries
  X_LDFLAGS="-L$x_libraries"
fi
all_includes="$X_INCLUDES"
all_libraries="$X_LDFLAGS"

# Check for libraries that X11R6 Xt/Xaw programs need.
ac_save_LDFLAGS="$LDFLAGS"
LDFLAGS="$LDFLAGS $X_LDFLAGS"
# SM needs ICE to (dynamically) link under SunOS 4.x (so we have to
# check for ICE first), but we must link in the order -lSM -lICE or
# we get undefined symbols.  So assume we have SM if we have ICE.
# These have to be linked with before -lX11, unlike the other
# libraries we check for below, so use a different variable.
#  --interran@uluru.Stanford.EDU, kb@cs.umb.edu.
AC_CHECK_LIB(ICE, IceConnectionNumber,
  [LIBSM="-lSM -lICE"], , $X_EXTRA_LIBS)
LDFLAGS="$ac_save_LDFLAGS"

LIB_X11='-lX11 $(LIBSOCKET)'

AC_MSG_CHECKING(for libXext)
AC_CACHE_VAL(kde_cv_have_libXext,
[
kde_ldflags_safe="$LDFLAGS"
kde_libs_safe="$LIBS"

LDFLAGS="$LDFLAGS $X_LDFLAGS $USER_LDFLAGS"
LIBS="-lXext -lX11 $LIBSOCKET"

AC_TRY_LINK([
#include <stdio.h>
#ifdef STDC_HEADERS
# include <stdlib.h>
#endif
],
[
printf("hello Xext\n");
],
kde_cv_have_libXext=yes,
kde_cv_have_libXext=no
)

LDFLAGS=$kde_ldflags_safe
LIBS=$kde_libs_safe
])

AC_MSG_RESULT($kde_cv_have_libXext)

if test "$kde_cv_have_libXext" = "no"; then
  AC_MSG_ERROR([We need a working libXext to proceed. Since configure
can't find it itself, we stop here assuming that make wouldn't find
them either.])
fi

LIB_XEXT="-lXext"
QTE_NORTTI=""

elif test "$kde_use_qt_emb" = "yes"; then
  dnl We're using QT Embedded
  CPPFLAGS=-DQWS
  CXXFLAGS="$CXXFLAGS -fno-rtti"
  QTE_NORTTI="-fno-rtti -DQWS"
  X_PRE_LIBS=""
  LIB_X11=""
  LIB_XEXT=""
  LIB_XRENDER=""
  LIBSM=""
  X_INCLUDES=""
  X_LDFLAGS=""
  x_includes=""
  x_libraries=""
elif test "$kde_use_qt_mac" = "yes"; then
  dnl We're using QT/Mac (I use QT_MAC so that qglobal.h doesn't *have* to
  dnl be included to get the information) --Sam
  CXXFLAGS="$CXXFLAGS -DQT_MAC -no-cpp-precomp"
  CFLAGS="$CFLAGS -DQT_MAC -no-cpp-precomp"
  X_PRE_LIBS=""
  LIB_X11=""
  LIB_XEXT=""
  LIB_XRENDER=""
  LIBSM=""
  X_INCLUDES=""
  X_LDFLAGS=""
  x_includes=""
  x_libraries=""
fi
AC_SUBST(X_PRE_LIBS)
AC_SUBST(LIB_X11)
AC_SUBST(LIB_XRENDER)
AC_SUBST(LIBSM)
AC_SUBST(X_INCLUDES)
AC_SUBST(X_LDFLAGS)
AC_SUBST(x_includes)
AC_SUBST(x_libraries)
AC_SUBST(QTE_NORTTI)
AC_SUBST(LIB_XEXT)

])

AC_DEFUN([KDE_PRINT_QT_PROGRAM],
[
AC_REQUIRE([KDE_USE_QT])
cat > conftest.$ac_ext <<EOF
#include "confdefs.h"
#include <qglobal.h>
#include <qapplication.h>
EOF
if test "$kde_qtver" = "2"; then
cat >> conftest.$ac_ext <<EOF
#include <qevent.h>
#include <qstring.h>
#include <qstyle.h>
EOF

if test $kde_qtsubver -gt 0; then
cat >> conftest.$ac_ext <<EOF
#if QT_VERSION < 210
#error 1
#endif
EOF
fi
fi

if test "$kde_qtver" = "3"; then
cat >> conftest.$ac_ext <<EOF
#include <qcursor.h>
#include <qstylefactory.h>
#include <private/qucomextra_p.h>
EOF
fi

echo "#if ! ($kde_qt_verstring)" >> conftest.$ac_ext
cat >> conftest.$ac_ext <<EOF
#error 1
#endif

int main() {
EOF
if test "$kde_qtver" = "2"; then
cat >> conftest.$ac_ext <<EOF
    QStringList *t = new QStringList();
    Q_UNUSED(t);
EOF
if test $kde_qtsubver -gt 0; then
cat >> conftest.$ac_ext <<EOF
    QString s;
    s.setLatin1("Elvis is alive", 14);
EOF
fi
fi
if test "$kde_qtver" = "3"; then
cat >> conftest.$ac_ext <<EOF
    (void)QStyleFactory::create(QString::null);
    QCursor c(Qt::WhatsThisCursor);
EOF
fi
cat >> conftest.$ac_ext <<EOF
    return 0;
}
EOF
])

AC_DEFUN([KDE_USE_QT],
[
if test -z "$1"; then
  # Current default Qt version: 3.3
  kde_qtver=3
  kde_qtsubver=3
else
  kde_qtsubver=`echo "$1" | sed -e 's#[0-9][0-9]*\.\([0-9][0-9]*\).*#\1#'`
  # following is the check if subversion isnt found in passed argument
  if test "$kde_qtsubver" = "$1"; then
    kde_qtsubver=1
  fi
  kde_qtver=`echo "$1" | sed -e 's#^\([0-9][0-9]*\)\..*#\1#'`
  if test "$kde_qtver" = "1"; then
    kde_qtsubver=42
  fi
fi

if test -z "$2"; then
  if test "$kde_qtver" = "2"; then
    if test $kde_qtsubver -gt 0; then
      kde_qt_minversion=">= Qt 2.2.2"
    else
      kde_qt_minversion=">= Qt 2.0.2"
    fi
  fi
  if test "$kde_qtver" = "3"; then
    if test $kde_qtsubver -gt 0; then
	 if test $kde_qtsubver -gt 1; then
	    if test $kde_qtsubver -gt 2; then
		kde_qt_minversion=">= Qt 3.3"
	    else
	        kde_qt_minversion=">= Qt 3.2"
	    fi
	 else
            kde_qt_minversion=">= Qt 3.1 (20021021)"
         fi
    else
      kde_qt_minversion=">= Qt 3.0"
    fi
  fi
  if test "$kde_qtver" = "1"; then
    kde_qt_minversion=">= 1.42 and < 2.0"
  fi
else
   kde_qt_minversion="$2"
fi

if test -z "$3"; then
   if test $kde_qtver = 3; then
     if test $kde_qtsubver -gt 0; then
       kde_qt_verstring="QT_VERSION >= 0x03@VER@00"
       qtsubver=`echo "00$kde_qtsubver" | sed -e 's,.*\(..\)$,\1,'`
       kde_qt_verstring=`echo $kde_qt_verstring | sed -e "s,@VER@,$qtsubver,"`
     else
       kde_qt_verstring="QT_VERSION >= 300"
     fi
   fi
   if test $kde_qtver = 2; then
     if test $kde_qtsubver -gt 0; then
       kde_qt_verstring="QT_VERSION >= 222"
     else
       kde_qt_verstring="QT_VERSION >= 200"
     fi
   fi
   if test $kde_qtver = 1; then
    kde_qt_verstring="QT_VERSION >= 142 && QT_VERSION < 200"
   fi
else
   kde_qt_verstring="$3"
fi

if test $kde_qtver = 3; then
  kde_qt_dirs="$QTDIR /usr/lib/qt3 /usr/lib/qt /usr/share/qt3"
fi
if test $kde_qtver = 2; then
   kde_qt_dirs="$QTDIR /usr/lib/qt2 /usr/lib/qt"
fi
if test $kde_qtver = 1; then
   kde_qt_dirs="$QTDIR /usr/lib/qt"
fi
])

AC_DEFUN([KDE_CHECK_QT_DIRECT],
[
AC_REQUIRE([KDE_USE_QT])
AC_MSG_CHECKING([if Qt compiles without flags])
AC_CACHE_VAL(kde_cv_qt_direct,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
ac_LD_LIBRARY_PATH_safe=$LD_LIBRARY_PATH
ac_LIBRARY_PATH="$LIBRARY_PATH"
ac_cxxflags_safe="$CXXFLAGS"
ac_ldflags_safe="$LDFLAGS"
ac_libs_safe="$LIBS"

CXXFLAGS="$CXXFLAGS -I$qt_includes"
LDFLAGS="$LDFLAGS $X_LDFLAGS"
if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIBS="$LIBQT -lXext -lX11 $LIBSOCKET"
else
LIBS="$LIBQT $LIBSOCKET"
fi
LD_LIBRARY_PATH=
export LD_LIBRARY_PATH
LIBRARY_PATH=
export LIBRARY_PATH

KDE_PRINT_QT_PROGRAM

if AC_TRY_EVAL(ac_link) && test -s conftest; then
  kde_cv_qt_direct="yes"
else
  kde_cv_qt_direct="no"
  echo "configure: failed program was:" >&AC_FD_CC
  cat conftest.$ac_ext >&AC_FD_CC
fi

rm -f conftest*
CXXFLAGS="$ac_cxxflags_safe"
LDFLAGS="$ac_ldflags_safe"
LIBS="$ac_libs_safe"

LD_LIBRARY_PATH="$ac_LD_LIBRARY_PATH_safe"
export LD_LIBRARY_PATH
LIBRARY_PATH="$ac_LIBRARY_PATH"
export LIBRARY_PATH
AC_LANG_RESTORE
])

if test "$kde_cv_qt_direct" = "yes"; then
  AC_MSG_RESULT(yes)
  $1
else
  AC_MSG_RESULT(no)
  $2
fi
])

dnl ------------------------------------------------------------------------
dnl Try to find the Qt headers and libraries.
dnl $(QT_LDFLAGS) will be -Lqtliblocation (if needed)
dnl and $(QT_INCLUDES) will be -Iqthdrlocation (if needed)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_PATH_QT_1_3],
[
AC_REQUIRE([K_PATH_X])
AC_REQUIRE([KDE_USE_QT])
AC_REQUIRE([KDE_CHECK_LIB64])

dnl ------------------------------------------------------------------------
dnl Add configure flag to enable linking to MT version of Qt library.
dnl ------------------------------------------------------------------------

AC_ARG_ENABLE(
  mt,
  AC_HELP_STRING([--disable-mt],[link to non-threaded Qt (deprecated)]),
  kde_use_qt_mt=$enableval,
  [
    if test $kde_qtver = 3; then
      kde_use_qt_mt=yes
    else
      kde_use_qt_mt=no
    fi
  ]
)

USING_QT_MT=""

dnl ------------------------------------------------------------------------
dnl If we not get --disable-qt-mt then adjust some vars for the host.
dnl ------------------------------------------------------------------------

KDE_MT_LDFLAGS=
KDE_MT_LIBS=
if test "x$kde_use_qt_mt" = "xyes"; then
  KDE_CHECK_THREADING
  if test "x$kde_use_threading" = "xyes"; then
    CPPFLAGS="$USE_THREADS -DQT_THREAD_SUPPORT $CPPFLAGS"
    KDE_MT_LDFLAGS="$USE_THREADS"
    KDE_MT_LIBS="$LIBPTHREAD"
  else
    kde_use_qt_mt=no
  fi
fi
AC_SUBST(KDE_MT_LDFLAGS)
AC_SUBST(KDE_MT_LIBS)

kde_qt_was_given=yes

dnl ------------------------------------------------------------------------
dnl If we haven't been told how to link to Qt, we work it out for ourselves.
dnl ------------------------------------------------------------------------
if test -z "$LIBQT_GLOB"; then
  if test "x$kde_use_qt_emb" = "xyes"; then
    LIBQT_GLOB="libqte.*"
  else
    LIBQT_GLOB="libqt.*"
  fi
fi

if test -z "$LIBQT"; then
dnl ------------------------------------------------------------
dnl If we got --enable-embedded then adjust the Qt library name.
dnl ------------------------------------------------------------
  if test "x$kde_use_qt_emb" = "xyes"; then
    qtlib="qte"
  else
    qtlib="qt"
  fi

  kde_int_qt="-l$qtlib"
else
  kde_int_qt="$LIBQT"
  kde_lib_qt_set=yes
fi

if test -z "$LIBQPE"; then
dnl ------------------------------------------------------------
dnl If we got --enable-palmtop then add -lqpe to the link line
dnl ------------------------------------------------------------
  if test "x$kde_use_qt_emb" = "xyes"; then
    if test "x$kde_use_qt_emb_palm" = "xyes"; then
      LIB_QPE="-lqpe"
    else
      LIB_QPE=""
    fi
  else
    LIB_QPE=""
  fi
fi

dnl ------------------------------------------------------------------------
dnl If we got --enable-qt-mt then adjust the Qt library name for the host.
dnl ------------------------------------------------------------------------

if test "x$kde_use_qt_mt" = "xyes"; then
  if test -z "$LIBQT"; then
    LIBQT="-l$qtlib-mt"
    kde_int_qt="-l$qtlib-mt"
  else
    LIBQT="$qtlib-mt"
    kde_int_qt="$qtlib-mt"
  fi
  LIBQT_GLOB="lib$qtlib-mt.*"
  USING_QT_MT="using -mt"
else
  LIBQT="-l$qtlib"
fi

if test $kde_qtver != 1; then

  AC_REQUIRE([AC_FIND_PNG])
  AC_REQUIRE([AC_FIND_JPEG])
  LIBQT="$LIBQT $LIBPNG $LIBJPEG"
fi

if test $kde_qtver = 3; then
  AC_REQUIRE([KDE_CHECK_LIBDL])
  LIBQT="$LIBQT $LIBDL"
fi

AC_MSG_CHECKING([for Qt])

if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIBQT="$LIBQT $X_PRE_LIBS -lXext -lX11 $LIBSM $LIBSOCKET"
fi
ac_qt_includes=NO ac_qt_libraries=NO ac_qt_bindir=NO
qt_libraries=""
qt_includes=""
AC_ARG_WITH(qt-dir,
    AC_HELP_STRING([--with-qt-dir=DIR],[where the root of Qt is installed ]),
    [  ac_qt_includes="$withval"/include
       ac_qt_libraries="$withval"/lib${kdelibsuff}
       ac_qt_bindir="$withval"/bin
    ])

AC_ARG_WITH(qt-includes,
    AC_HELP_STRING([--with-qt-includes=DIR],[where the Qt includes are. ]),
    [
       ac_qt_includes="$withval"
    ])

kde_qt_libs_given=no

AC_ARG_WITH(qt-libraries,
    AC_HELP_STRING([--with-qt-libraries=DIR],[where the Qt library is installed.]),
    [  ac_qt_libraries="$withval"
       kde_qt_libs_given=yes
    ])

AC_CACHE_VAL(ac_cv_have_qt,
[#try to guess Qt locations

qt_incdirs=""
for dir in $kde_qt_dirs; do
   qt_incdirs="$qt_incdirs $dir/include $dir"
done
qt_incdirs="$QTINC $qt_incdirs /usr/local/qt/include /usr/include/qt /usr/include /usr/X11R6/include/X11/qt /usr/X11R6/include/qt /usr/X11R6/include/qt2 /usr/include/qt3 $x_includes"
if test ! "$ac_qt_includes" = "NO"; then
   qt_incdirs="$ac_qt_includes $qt_incdirs"
fi

if test "$kde_qtver" != "1"; then
  kde_qt_header=qstyle.h
else
  kde_qt_header=qglobal.h
fi

AC_FIND_FILE($kde_qt_header, $qt_incdirs, qt_incdir)
ac_qt_includes="$qt_incdir"

qt_libdirs=""
for dir in $kde_qt_dirs; do
   qt_libdirs="$qt_libdirs $dir/lib${kdelibsuff} $dir"
done
qt_libdirs="$QTLIB $qt_libdirs /usr/X11R6/lib /usr/lib /usr/local/qt/lib $x_libraries"
if test ! "$ac_qt_libraries" = "NO"; then
  qt_libdir=$ac_qt_libraries
else
  qt_libdirs="$ac_qt_libraries $qt_libdirs"
  # if the Qt was given, the chance is too big that libqt.* doesn't exist
  qt_libdir=NONE
  for dir in $qt_libdirs; do
    try="ls -1 $dir/${LIBQT_GLOB}"
    if test -n "`$try 2> /dev/null`"; then qt_libdir=$dir; break; else echo "tried $dir" >&AC_FD_CC ; fi
  done
fi
for a in $qt_libdir/lib`echo ${kde_int_qt} | sed 's,^-l,,'`_incremental.*; do
  if test -e "$a"; then
    LIBQT="$LIBQT ${kde_int_qt}_incremental"
    break
  fi
done

ac_qt_libraries="$qt_libdir"

AC_LANG_SAVE
AC_LANG_CPLUSPLUS

ac_cxxflags_safe="$CXXFLAGS"
ac_ldflags_safe="$LDFLAGS"
ac_libs_safe="$LIBS"

CXXFLAGS="$CXXFLAGS -I$qt_incdir $all_includes"
LDFLAGS="$LDFLAGS -L$qt_libdir $all_libraries $USER_LDFLAGS $KDE_MT_LDFLAGS"
LIBS="$LIBS $LIBQT $KDE_MT_LIBS"

KDE_PRINT_QT_PROGRAM

if AC_TRY_EVAL(ac_link) && test -s conftest; then
  rm -f conftest*
else
  echo "configure: failed program was:" >&AC_FD_CC
  cat conftest.$ac_ext >&AC_FD_CC
  ac_qt_libraries="NO"
fi
rm -f conftest*
CXXFLAGS="$ac_cxxflags_safe"
LDFLAGS="$ac_ldflags_safe"
LIBS="$ac_libs_safe"

AC_LANG_RESTORE
if test "$ac_qt_includes" = NO || test "$ac_qt_libraries" = NO; then
  ac_cv_have_qt="have_qt=no"
  ac_qt_notfound=""
  missing_qt_mt=""
  if test "$ac_qt_includes" = NO; then
    if test "$ac_qt_libraries" = NO; then
      ac_qt_notfound="(headers and libraries)";
    else
      ac_qt_notfound="(headers)";
    fi
  else
    if test "x$kde_use_qt_mt" = "xyes"; then
       missing_qt_mt="
Make sure that you have compiled Qt with thread support!"
       ac_qt_notfound="(library $qtlib-mt)";
    else
       ac_qt_notfound="(library $qtlib)";
    fi
  fi

  AC_MSG_ERROR([Qt ($kde_qt_minversion) $ac_qt_notfound not found. Please check your installation!
For more details about this problem, look at the end of config.log.$missing_qt_mt])
else
  have_qt="yes"
fi
])

eval "$ac_cv_have_qt"

if test "$have_qt" != yes; then
  AC_MSG_RESULT([$have_qt]);
else
  ac_cv_have_qt="have_qt=yes \
    ac_qt_includes=$ac_qt_includes ac_qt_libraries=$ac_qt_libraries"
  AC_MSG_RESULT([libraries $ac_qt_libraries, headers $ac_qt_includes $USING_QT_MT])

  qt_libraries="$ac_qt_libraries"
  qt_includes="$ac_qt_includes"
fi

if test ! "$kde_qt_libs_given" = "yes" && test ! "$kde_qtver" = 3; then
     KDE_CHECK_QT_DIRECT(qt_libraries= ,[])
fi

AC_SUBST(qt_libraries)
AC_SUBST(qt_includes)

if test "$qt_includes" = "$x_includes" || test -z "$qt_includes"; then
 QT_INCLUDES=""
else
 QT_INCLUDES="-I$qt_includes"
 all_includes="$QT_INCLUDES $all_includes"
fi

if test "$qt_libraries" = "$x_libraries" || test -z "$qt_libraries"; then
 QT_LDFLAGS=""
else
 QT_LDFLAGS="-L$qt_libraries"
 all_libraries="$all_libraries $QT_LDFLAGS"
fi
test -z "$KDE_MT_LDFLAGS" || all_libraries="$all_libraries $KDE_MT_LDFLAGS"

AC_SUBST(QT_INCLUDES)
AC_SUBST(QT_LDFLAGS)
AC_PATH_QT_MOC_UIC

KDE_CHECK_QT_JPEG

if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIB_QT="$kde_int_qt $LIBJPEG_QT "'$(LIBZ) $(LIBPNG) -lXext $(LIB_X11) $(LIBSM)'
else
LIB_QT="$kde_int_qt $LIBJPEG_QT "'$(LIBZ) $(LIBPNG)'
fi
test -z "$KDE_MT_LIBS" || LIB_QT="$LIB_QT $KDE_MT_LIBS"
for a in $qt_libdir/lib`echo ${kde_int_qt} | sed 's,^-l,,'`_incremental.*; do
  if test -e "$a"; then
     LIB_QT="$LIB_QT ${kde_int_qt}_incremental"
     break
  fi
done

AC_SUBST(LIB_QT)
AC_SUBST(LIB_QPE)

AC_SUBST(kde_qtver)
])

AC_DEFUN([AC_PATH_QT],
[
AC_PATH_QT_1_3
])

AC_DEFUN([KDE_CHECK_UIC_PLUGINS],
[
AC_REQUIRE([AC_PATH_QT_MOC_UIC])

if test x$ac_uic_supports_libpath = xyes; then

AC_MSG_CHECKING([if UIC has KDE plugins available])
AC_CACHE_VAL(kde_cv_uic_plugins,
[
cat > actest.ui << EOF
<!DOCTYPE UI><UI version="3.0" stdsetdef="1">
<class>NewConnectionDialog</class>
<widget class="QDialog">
   <widget class="KLineEdit">
        <property name="name">
           <cstring>testInput</cstring>
        </property>
   </widget>
</widget>
</UI>
EOF
       


kde_cv_uic_plugins=no
kde_line="$UIC_PATH -L $kde_widgetdir"
if test x$ac_uic_supports_nounload = xyes; then
   kde_line="$kde_line -nounload"
fi
kde_line="$kde_line -impl actest.h actest.ui > actest.cpp"
if AC_TRY_EVAL(kde_line); then
	# if you're trying to debug this check and think it's incorrect,
	# better check your installation. The check _is_ correct - your
	# installation is not.
	if test -f actest.cpp && grep klineedit actest.cpp > /dev/null; then
		kde_cv_uic_plugins=yes
	fi
fi
rm -f actest.ui actest.cpp
])

AC_MSG_RESULT([$kde_cv_uic_plugins])
if test "$kde_cv_uic_plugins" != yes; then
	AC_MSG_ERROR([you need to install kdelibs first.])
fi
fi
])

AC_DEFUN([KDE_CHECK_FINAL],
[
  AC_ARG_ENABLE(final,
	AC_HELP_STRING([--enable-final],
		       [build size optimized apps (experimental - needs lots of memory)]),
	kde_use_final=$enableval, kde_use_final=no)

  if test "x$kde_use_final" = "xyes"; then
      KDE_USE_FINAL_TRUE=""
      KDE_USE_FINAL_FALSE="#"
   else
      KDE_USE_FINAL_TRUE="#"
      KDE_USE_FINAL_FALSE=""
  fi
  AC_SUBST(KDE_USE_FINAL_TRUE)
  AC_SUBST(KDE_USE_FINAL_FALSE)
])

AC_DEFUN([KDE_CHECK_CLOSURE],
[
  AC_ARG_ENABLE(closure,
		AC_HELP_STRING([--enable-closure],[delay template instantiation]),
  	kde_use_closure=$enableval, kde_use_closure=no)

  KDE_NO_UNDEFINED=""
  if test "x$kde_use_closure" = "xyes"; then
       KDE_USE_CLOSURE_TRUE=""
       KDE_USE_CLOSURE_FALSE="#"
#       CXXFLAGS="$CXXFLAGS $REPO"
  else
       KDE_USE_CLOSURE_TRUE="#"
       KDE_USE_CLOSURE_FALSE=""
       KDE_NO_UNDEFINED=""
       case $host in 
         *-*-linux-gnu)
           KDE_CHECK_COMPILER_FLAG([Wl,--no-undefined],
                [KDE_CHECK_COMPILER_FLAG([Wl,--allow-shlib-undefined],
		[KDE_NO_UNDEFINED="-Wl,--no-undefined -Wl,--allow-shlib-undefined"],
		[KDE_NO_UNDEFINED=""])],
	    [KDE_NO_UNDEFINED=""])
           ;;
       esac
  fi
  AC_SUBST(KDE_USE_CLOSURE_TRUE)
  AC_SUBST(KDE_USE_CLOSURE_FALSE)
  AC_SUBST(KDE_NO_UNDEFINED)
])

AC_DEFUN([KDE_CHECK_NMCHECK],
[
  AC_ARG_ENABLE(nmcheck,AC_HELP_STRING([--enable-nmcheck],[enable automatic namespace cleanness check]),
	kde_use_nmcheck=$enableval, kde_use_nmcheck=no)

  if test "$kde_use_nmcheck" = "yes"; then
      KDE_USE_NMCHECK_TRUE=""
      KDE_USE_NMCHECK_FALSE="#"
   else
      KDE_USE_NMCHECK_TRUE="#"
      KDE_USE_NMCHECK_FALSE=""
  fi
  AC_SUBST(KDE_USE_NMCHECK_TRUE)
  AC_SUBST(KDE_USE_NMCHECK_FALSE)
])

AC_DEFUN([KDE_EXPAND_MAKEVAR], [
savex=$exec_prefix
test "x$exec_prefix" = xNONE && exec_prefix=$prefix
tmp=$$2
while $1=`eval echo "$tmp"`; test "x$$1" != "x$tmp"; do tmp=$$1; done
exec_prefix=$savex
])

dnl ------------------------------------------------------------------------
dnl Now, the same with KDE
dnl $(KDE_LDFLAGS) will be the kdeliblocation (if needed)
dnl and $(kde_includes) will be the kdehdrlocation (if needed)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_BASE_PATH_KDE],
[
AC_REQUIRE([KDE_CHECK_STL])
AC_REQUIRE([AC_PATH_QT])dnl
AC_REQUIRE([KDE_CHECK_LIB64])

AC_CHECK_RPATH
AC_MSG_CHECKING([for KDE])

if test "${prefix}" != NONE; then
  kde_includes=${includedir}
  KDE_EXPAND_MAKEVAR(ac_kde_includes, includedir)

  kde_libraries=${libdir}
  KDE_EXPAND_MAKEVAR(ac_kde_libraries, libdir)

else
  ac_kde_includes=
  ac_kde_libraries=
  kde_libraries=""
  kde_includes=""
fi

AC_CACHE_VAL(ac_cv_have_kde,
[#try to guess kde locations

if test "$kde_qtver" = 1; then
  kde_check_header="ksock.h"
  kde_check_lib="libkdecore.la"
else
  kde_check_header="ksharedptr.h"
  kde_check_lib="libkio.la"
fi

if test -z "$1"; then

kde_incdirs="$kde_libs_prefix/include /usr/lib/kde/include /usr/local/kde/include /usr/local/include /usr/kde/include /usr/include/kde /usr/include /opt/kde3/include /opt/kde/include $x_includes $qt_includes"
test -n "$KDEDIR" && kde_incdirs="$KDEDIR/include $KDEDIR/include/kde $KDEDIR $kde_incdirs"
kde_incdirs="$ac_kde_includes $kde_incdirs"
AC_FIND_FILE($kde_check_header, $kde_incdirs, kde_incdir)
ac_kde_includes="$kde_incdir"

if test -n "$ac_kde_includes" && test ! -r "$ac_kde_includes/$kde_check_header"; then
  AC_MSG_ERROR([
in the prefix, you've chosen, are no KDE headers installed. This will fail.
So, check this please and use another prefix!])
fi

kde_libdirs="$kde_libs_prefix/lib${kdelibsuff} /usr/lib/kde/lib${kdelibsuff} /usr/local/kde/lib${kdelibsuff} /usr/kde/lib${kdelibsuff} /usr/lib${kdelibsuff}/kde /usr/lib${kdelibsuff}/kde3 /usr/lib${kdelibsuff} /usr/X11R6/lib${kdelibsuff} /usr/local/lib${kdelibsuff} /opt/kde3/lib${kdelibsuff} /opt/kde/lib${kdelibsuff} /usr/X11R6/kde/lib${kdelibsuff}"
test -n "$KDEDIR" && kde_libdirs="$KDEDIR/lib${kdelibsuff} $KDEDIR $kde_libdirs"
kde_libdirs="$ac_kde_libraries $libdir $kde_libdirs"
AC_FIND_FILE($kde_check_lib, $kde_libdirs, kde_libdir)
ac_kde_libraries="$kde_libdir"

kde_widgetdir=NO
dnl this might be somewhere else
AC_FIND_FILE("kde3/plugins/designer/kdewidgets.la", $kde_libdirs, kde_widgetdir)

if test -n "$ac_kde_libraries" && test ! -r "$ac_kde_libraries/$kde_check_lib"; then
AC_MSG_ERROR([
in the prefix, you've chosen, are no KDE libraries installed. This will fail.
So, check this please and use another prefix!])
fi

if test -n "$kde_widgetdir" && test ! -r "$kde_widgetdir/kde3/plugins/designer/kdewidgets.la"; then
AC_MSG_ERROR([
I can't find the designer plugins. These are required and should have been installed
by kdelibs])
fi

if test -n "$kde_widgetdir"; then
    kde_widgetdir="$kde_widgetdir/kde3/plugins/designer"
fi


if test "$ac_kde_includes" = NO || test "$ac_kde_libraries" = NO || test "$kde_widgetdir" = NO; then
  ac_cv_have_kde="have_kde=no"
else
  ac_cv_have_kde="have_kde=yes \
    ac_kde_includes=$ac_kde_includes ac_kde_libraries=$ac_kde_libraries"
fi

else dnl test -z $1, e.g. from kdelibs

  ac_cv_have_kde="have_kde=no"

fi
])dnl

eval "$ac_cv_have_kde"

if test "$have_kde" != "yes"; then
 if test "${prefix}" = NONE; then
  ac_kde_prefix="$ac_default_prefix"
 else
  ac_kde_prefix="$prefix"
 fi
 if test "$exec_prefix" = NONE; then
  ac_kde_exec_prefix="$ac_kde_prefix"
  AC_MSG_RESULT([will be installed in $ac_kde_prefix])
 else
  ac_kde_exec_prefix="$exec_prefix"
  AC_MSG_RESULT([will be installed in $ac_kde_prefix and $ac_kde_exec_prefix])
 fi

 kde_libraries="${libdir}"
 kde_includes="${includedir}"

else
  ac_cv_have_kde="have_kde=yes \
    ac_kde_includes=$ac_kde_includes ac_kde_libraries=$ac_kde_libraries"
  AC_MSG_RESULT([libraries $ac_kde_libraries, headers $ac_kde_includes])

  kde_libraries="$ac_kde_libraries"
  kde_includes="$ac_kde_includes"
fi
AC_SUBST(kde_libraries)
AC_SUBST(kde_includes)

if test "$kde_includes" = "$x_includes" || test "$kde_includes" = "$qt_includes"  || test "$kde_includes" = "/usr/include"; then
 KDE_INCLUDES=""
else
 KDE_INCLUDES="-I$kde_includes"
 all_includes="$KDE_INCLUDES $all_includes"
fi

KDE_DEFAULT_CXXFLAGS="-DQT_CLEAN_NAMESPACE -DQT_NO_ASCII_CAST -DQT_NO_STL -DQT_NO_COMPAT -DQT_NO_TRANSLATION"
 
KDE_LDFLAGS="-L$kde_libraries"
if test ! "$kde_libraries" = "$x_libraries" && test ! "$kde_libraries" = "$qt_libraries" ; then 
 all_libraries="$all_libraries $KDE_LDFLAGS"
fi

AC_SUBST(KDE_LDFLAGS)
AC_SUBST(KDE_INCLUDES)

AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])

all_libraries="$all_libraries $USER_LDFLAGS"
all_includes="$all_includes $USER_INCLUDES"
AC_SUBST(all_includes)
AC_SUBST(all_libraries)

if test -z "$1"; then
KDE_CHECK_UIC_PLUGINS
fi

ac_kde_libraries="$kde_libdir"

AC_SUBST(AUTODIRS)


])

AC_DEFUN([KDE_CHECK_EXTRA_LIBS],
[
AC_MSG_CHECKING(for extra includes)
AC_ARG_WITH(extra-includes,AC_HELP_STRING([--with-extra-includes=DIR],[adds non standard include paths]),
  kde_use_extra_includes="$withval",
  kde_use_extra_includes=NONE
)
kde_extra_includes=
if test -n "$kde_use_extra_includes" && \
   test "$kde_use_extra_includes" != "NONE"; then

   ac_save_ifs=$IFS
   IFS=':'
   for dir in $kde_use_extra_includes; do
     kde_extra_includes="$kde_extra_includes $dir"
     USER_INCLUDES="$USER_INCLUDES -I$dir"
   done
   IFS=$ac_save_ifs
   kde_use_extra_includes="added"
else
   kde_use_extra_includes="no"
fi
AC_SUBST(USER_INCLUDES)

AC_MSG_RESULT($kde_use_extra_includes)

kde_extra_libs=
AC_MSG_CHECKING(for extra libs)
AC_ARG_WITH(extra-libs,AC_HELP_STRING([--with-extra-libs=DIR],[adds non standard library paths]),
  kde_use_extra_libs=$withval,
  kde_use_extra_libs=NONE
)
if test -n "$kde_use_extra_libs" && \
   test "$kde_use_extra_libs" != "NONE"; then

   ac_save_ifs=$IFS
   IFS=':'
   for dir in $kde_use_extra_libs; do
     kde_extra_libs="$kde_extra_libs $dir"
     KDE_EXTRA_RPATH="$KDE_EXTRA_RPATH -R $dir"
     USER_LDFLAGS="$USER_LDFLAGS -L$dir"
   done
   IFS=$ac_save_ifs
   kde_use_extra_libs="added"
else
   kde_use_extra_libs="no"
fi

AC_SUBST(USER_LDFLAGS)

AC_MSG_RESULT($kde_use_extra_libs)

])

AC_DEFUN([KDE_1_CHECK_PATH_HEADERS],
[
    AC_MSG_CHECKING([for KDE headers installed])
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
cat > conftest.$ac_ext <<EOF
#ifdef STDC_HEADERS
# include <stdlib.h>
#endif
#include <stdio.h>
#include "confdefs.h"
#include <kapp.h>

int main() {
    printf("kde_htmldir=\\"%s\\"\n", KApplication::kde_htmldir().data());
    printf("kde_appsdir=\\"%s\\"\n", KApplication::kde_appsdir().data());
    printf("kde_icondir=\\"%s\\"\n", KApplication::kde_icondir().data());
    printf("kde_sounddir=\\"%s\\"\n", KApplication::kde_sounddir().data());
    printf("kde_datadir=\\"%s\\"\n", KApplication::kde_datadir().data());
    printf("kde_locale=\\"%s\\"\n", KApplication::kde_localedir().data());
    printf("kde_cgidir=\\"%s\\"\n", KApplication::kde_cgidir().data());
    printf("kde_confdir=\\"%s\\"\n", KApplication::kde_configdir().data());
    printf("kde_mimedir=\\"%s\\"\n", KApplication::kde_mimedir().data());
    printf("kde_toolbardir=\\"%s\\"\n", KApplication::kde_toolbardir().data());
    printf("kde_wallpaperdir=\\"%s\\"\n",
	KApplication::kde_wallpaperdir().data());
    printf("kde_bindir=\\"%s\\"\n", KApplication::kde_bindir().data());
    printf("kde_partsdir=\\"%s\\"\n", KApplication::kde_partsdir().data());
    printf("kde_servicesdir=\\"/tmp/dummy\\"\n");
    printf("kde_servicetypesdir=\\"/tmp/dummy\\"\n");
    printf("kde_moduledir=\\"/tmp/dummy\\"\n");
    printf("kde_styledir=\\"/tmp/dummy\\"\n");
    printf("kde_widgetdir=\\"/tmp/dummy\\"\n");
    printf("xdg_appsdir=\\"/tmp/dummy\\"\n");
    printf("xdg_menudir=\\"/tmp/dummy\\"\n");
    printf("xdg_directorydir=\\"/tmp/dummy\\"\n");
    printf("kde_kcfgdir=\\"/tmp/dummy\\"\n");
    return 0;
    }
EOF

 ac_save_CPPFLAGS=$CPPFLAGS
 CPPFLAGS="$all_includes $CPPFLAGS"
 if AC_TRY_EVAL(ac_compile); then
   AC_MSG_RESULT(yes)
 else
   AC_MSG_ERROR([your system is not able to compile a small KDE application!
Check, if you installed the KDE header files correctly.
For more details about this problem, look at the end of config.log.])
  fi
  CPPFLAGS=$ac_save_CPPFLAGS

  AC_LANG_RESTORE
])

AC_DEFUN([KDE_CHECK_KDEQTADDON],
[
AC_MSG_CHECKING(for kde-qt-addon)
AC_CACHE_VAL(kde_cv_have_kdeqtaddon,
[
 kde_ldflags_safe="$LDFLAGS"
 kde_libs_safe="$LIBS"
 kde_cxxflags_safe="$CXXFLAGS"

 LIBS="-lkde-qt-addon $LIBQT $LIBS"
 CXXFLAGS="$CXXFLAGS -I$prefix/include -I$prefix/include/kde $all_includes"
 LDFLAGS="$LDFLAGS $all_libraries $USER_LDFLAGS"

 AC_TRY_LINK([
   #include <qdom.h>
 ],
 [
   QDomDocument doc;
 ],
  kde_cv_have_kdeqtaddon=yes,
  kde_cv_have_kdeqtaddon=no
 )

 LDFLAGS=$kde_ldflags_safe
 LIBS=$kde_libs_safe
 CXXFLAGS=$kde_cxxflags_safe
])

AC_MSG_RESULT($kde_cv_have_kdeqtaddon)

if test "$kde_cv_have_kdeqtaddon" = "no"; then
  AC_MSG_ERROR([Can't find libkde-qt-addon. You need to install it first.
It is a separate package (and CVS module) named kde-qt-addon.])
fi
])

AC_DEFUN([KDE_CREATE_LIBS_ALIASES],
[
   AC_REQUIRE([KDE_MISC_TESTS])
   AC_REQUIRE([KDE_CHECK_LIBDL])
   AC_REQUIRE([K_PATH_X])

if test $kde_qtver = 3; then
   AC_SUBST(LIB_KDECORE, "-lkdecore")
   AC_SUBST(LIB_KDEUI, "-lkdeui")
   AC_SUBST(LIB_KIO, "-lkio")
   AC_SUBST(LIB_SMB, "-lsmb")
   AC_SUBST(LIB_KAB, "-lkab")
   AC_SUBST(LIB_KABC, "-lkabc")
   AC_SUBST(LIB_KHTML, "-lkhtml")
   AC_SUBST(LIB_KSPELL, "-lkspell")
   AC_SUBST(LIB_KPARTS, "-lkparts")
   AC_SUBST(LIB_KDEPRINT, "-lkdeprint")
   AC_SUBST(LIB_KUTILS, "-lkutils")
   AC_SUBST(LIB_KDEPIM, "-lkdepim")
# these are for backward compatibility
   AC_SUBST(LIB_KSYCOCA, "-lkio")
   AC_SUBST(LIB_KFILE, "-lkio")
elif test $kde_qtver = 2; then
   AC_SUBST(LIB_KDECORE, "-lkdecore")
   AC_SUBST(LIB_KDEUI, "-lkdeui")
   AC_SUBST(LIB_KIO, "-lkio")
   AC_SUBST(LIB_KSYCOCA, "-lksycoca")
   AC_SUBST(LIB_SMB, "-lsmb")
   AC_SUBST(LIB_KFILE, "-lkfile")
   AC_SUBST(LIB_KAB, "-lkab")
   AC_SUBST(LIB_KHTML, "-lkhtml")
   AC_SUBST(LIB_KSPELL, "-lkspell")
   AC_SUBST(LIB_KPARTS, "-lkparts")
   AC_SUBST(LIB_KDEPRINT, "-lkdeprint")
else
   AC_SUBST(LIB_KDECORE, "-lkdecore -lXext $(LIB_QT)")
   AC_SUBST(LIB_KDEUI, "-lkdeui $(LIB_KDECORE)")
   AC_SUBST(LIB_KFM, "-lkfm $(LIB_KDECORE)")
   AC_SUBST(LIB_KFILE, "-lkfile $(LIB_KFM) $(LIB_KDEUI)")
   AC_SUBST(LIB_KAB, "-lkab $(LIB_KIMGIO) $(LIB_KDECORE)")
fi
])

AC_DEFUN([AC_PATH_KDE],
[
  AC_BASE_PATH_KDE
  AC_ARG_ENABLE(path-check,AC_HELP_STRING([--disable-path-check],[don't try to find out, where to install]),
  [
  if test "$enableval" = "no";
    then ac_use_path_checking="default"
    else ac_use_path_checking=""
  fi
  ],
  [
  if test "$kde_qtver" = 1;
    then ac_use_path_checking=""
    else ac_use_path_checking="default"
  fi
  ]
  )

  AC_CREATE_KFSSTND($ac_use_path_checking)

  AC_SUBST_KFSSTND
  KDE_CREATE_LIBS_ALIASES
])

dnl KDE_CHECK_FUNC_EXT(<func>, [headers], [sample-use], [C prototype], [autoheader define], [call if found])
AC_DEFUN([KDE_CHECK_FUNC_EXT],
[
AC_MSG_CHECKING(for $1)
AC_CACHE_VAL(kde_cv_func_$1,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
save_CXXFLAGS="$CXXFLAGS"
kde_safe_LIBS="$LIBS"
LIBS="$LIBS $X_EXTRA_LIBS"
if test "$GXX" = "yes"; then
CXXFLAGS="$CXXFLAGS -pedantic-errors"
fi
AC_TRY_COMPILE([
$2
],
[
$3
],
kde_cv_func_$1=yes,
kde_cv_func_$1=no)
CXXFLAGS="$save_CXXFLAGS"
LIBS="$kde_safe_LIBS"
AC_LANG_RESTORE
])

AC_MSG_RESULT($kde_cv_func_$1)

AC_MSG_CHECKING([if $1 needs custom prototype])
AC_CACHE_VAL(kde_cv_proto_$1,
[
if test "x$kde_cv_func_$1" = xyes; then
  kde_cv_proto_$1=no
else
  case "$1" in
	setenv|unsetenv|usleep|random|srandom|seteuid|mkstemps|mkstemp|revoke|vsnprintf|strlcpy|strlcat)
		kde_cv_proto_$1="yes - in libkdefakes"
		;;
	*)
		kde_cv_proto_$1=unknown
		;;
  esac
fi

if test "x$kde_cv_proto_$1" = xunknown; then

AC_LANG_SAVE
AC_LANG_CPLUSPLUS
  kde_safe_libs=$LIBS
  LIBS="$LIBS $X_EXTRA_LIBS"
  AC_TRY_LINK([
$2

extern "C" $4;
],
[
$3
],
[ kde_cv_func_$1=yes
  kde_cv_proto_$1=yes ],
  [kde_cv_proto_$1="$1 unavailable"]
)
LIBS=$kde_safe_libs
AC_LANG_RESTORE
fi
])
AC_MSG_RESULT($kde_cv_proto_$1)

if test "x$kde_cv_func_$1" = xyes; then
  AC_DEFINE(HAVE_$5, 1, [Define if you have $1])
  $6
fi
if test "x$kde_cv_proto_$1" = xno; then
  AC_DEFINE(HAVE_$5_PROTO, 1,
  [Define if you have the $1 prototype])
fi

AH_VERBATIM([_HAVE_$5_PROTO],
[
#if !defined(HAVE_$5_PROTO)
#ifdef __cplusplus
extern "C" {
#endif
$4;
#ifdef __cplusplus
}
#endif
#endif
])
])

AC_DEFUN([AC_CHECK_SETENV],
[
	KDE_CHECK_FUNC_EXT(setenv, [
#include <stdlib.h>
], 
		[setenv("VAR", "VALUE", 1);],
	        [int setenv (const char *, const char *, int)],
		[SETENV])
])

AC_DEFUN([AC_CHECK_UNSETENV],
[
	KDE_CHECK_FUNC_EXT(unsetenv, [
#include <stdlib.h>
], 
		[unsetenv("VAR");],
	        [void unsetenv (const char *)],
		[UNSETENV])
])

AC_DEFUN([AC_CHECK_GETDOMAINNAME],
[
	KDE_CHECK_FUNC_EXT(getdomainname, [
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
], 
		[
char buffer[200];
getdomainname(buffer, 200);
], 	
	        [#include <sys/types.h>
		int getdomainname (char *, size_t)],
		[GETDOMAINNAME])
])

AC_DEFUN([AC_CHECK_GETHOSTNAME],
[
	KDE_CHECK_FUNC_EXT(gethostname, [
#include <stdlib.h>
#include <unistd.h>
], 
		[
char buffer[200];
gethostname(buffer, 200);
], 	
	        [int gethostname (char *, unsigned int)],
		[GETHOSTNAME])
])

AC_DEFUN([AC_CHECK_USLEEP],
[
	KDE_CHECK_FUNC_EXT(usleep, [
#include <unistd.h>
], 
		[
usleep(200);
], 	
	        [int usleep (unsigned int)],
		[USLEEP])
])


AC_DEFUN([AC_CHECK_RANDOM],
[
	KDE_CHECK_FUNC_EXT(random, [
#include <stdlib.h>
], 
		[
random();
], 	
	        [long int random(void)],
		[RANDOM])

	KDE_CHECK_FUNC_EXT(srandom, [
#include <stdlib.h>
], 
		[
srandom(27);
], 	
	        [void srandom(unsigned int)],
		[SRANDOM])

])

AC_DEFUN([AC_CHECK_INITGROUPS],
[
	KDE_CHECK_FUNC_EXT(initgroups, [
#include <sys/types.h>
#include <unistd.h>
#include <grp.h>
],
	[
char buffer[200];
initgroups(buffer, 27);
],
	[int initgroups(const char *, gid_t)],
	[INITGROUPS])
])

AC_DEFUN([AC_CHECK_MKSTEMPS],
[
	KDE_CHECK_FUNC_EXT(mkstemps, [
#include <stdlib.h>
#include <unistd.h>
],
	[
mkstemps("/tmp/aaaXXXXXX", 6);
],
	[int mkstemps(char *, int)],
	[MKSTEMPS])
])

AC_DEFUN([AC_CHECK_MKDTEMP],
[
	KDE_CHECK_FUNC_EXT(mkdtemp, [
#include <stdlib.h>
#include <unistd.h>
],
	[
mkdtemp("/tmp/aaaXXXXXX");
],
	[char *mkdtemp(char *)],
	[MKDTEMP])
])


AC_DEFUN([AC_CHECK_RES_INIT],
[
  AC_MSG_CHECKING([if res_init needs -lresolv])
  kde_libs_safe="$LIBS"
  LIBS="$LIBS $X_EXTRA_LIBS -lresolv"
  AC_TRY_LINK(
    [
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
    ],
    [
      res_init(); 
    ],
    [
      LIBRESOLV="-lresolv"
      AC_MSG_RESULT(yes)
      AC_DEFINE(HAVE_RES_INIT, 1, [Define if you have the res_init function])
    ],
    [ AC_MSG_RESULT(no) ]
  )
  LIBS=$kde_libs_safe
  AC_SUBST(LIBRESOLV)

  KDE_CHECK_FUNC_EXT(res_init,
    [
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
    ],
    [res_init()],
    [int res_init(void)],
    [RES_INIT])
])

AC_DEFUN([AC_CHECK_STRLCPY],
[
	KDE_CHECK_FUNC_EXT(strlcpy, [
#include <string.h>
],
[ char buf[20];
  strlcpy(buf, "KDE function test", sizeof(buf));
],
 	[unsigned long strlcpy(char*, const char*, unsigned long)],
	[STRLCPY])
])

AC_DEFUN([AC_CHECK_STRLCAT],
[
	KDE_CHECK_FUNC_EXT(strlcat, [
#include <string.h>
],
[ char buf[20];
  buf[0]='\0';
  strlcat(buf, "KDE function test", sizeof(buf));
],
 	[unsigned long strlcat(char*, const char*, unsigned long)],
	[STRLCAT])
])

AC_DEFUN([AC_CHECK_RES_QUERY],
[
	KDE_CHECK_FUNC_EXT(res_query, [
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
#include <netdb.h>
],
[
res_query(NULL, 0, 0, NULL, 0);
],
	[int res_query(const char *, int, int, unsigned char *, int)],
	[RES_QUERY])
])

AC_DEFUN([AC_CHECK_DN_SKIPNAME],
[
	KDE_CHECK_FUNC_EXT(dn_skipname, [
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/nameser.h>
#include <resolv.h>
],
[
dn_skipname (NULL, NULL);
],
	[int dn_skipname (unsigned char *, unsigned char *)],
	[DN_SKIPNAME])
])


AC_DEFUN([AC_FIND_GIF],
   [AC_MSG_CHECKING([for giflib])
AC_CACHE_VAL(ac_cv_lib_gif,
[ac_save_LIBS="$LIBS"
if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIBS="$all_libraries -lgif -lX11 $LIBSOCKET"
else
LIBS="$all_libraries -lgif"
fi
AC_TRY_LINK(dnl
[
#ifdef __cplusplus
extern "C" {
#endif
int GifLastError(void);
#ifdef __cplusplus
}
#endif
/* We use char because int might match the return type of a gcc2
    builtin and then its argument prototype would still apply.  */
],
            [return GifLastError();],
            eval "ac_cv_lib_gif=yes",
            eval "ac_cv_lib_gif=no")
LIBS="$ac_save_LIBS"
])dnl
if eval "test \"`echo $ac_cv_lib_gif`\" = yes"; then
  AC_MSG_RESULT(yes)
  AC_DEFINE_UNQUOTED(HAVE_LIBGIF, 1, [Define if you have libgif])
else
  AC_MSG_ERROR(You need giflib30. Please install the kdesupport package)
fi
])

AC_DEFUN([KDE_FIND_JPEG_HELPER],
[
AC_MSG_CHECKING([for libjpeg$2])
AC_CACHE_VAL(ac_cv_lib_jpeg_$1,
[
ac_save_LIBS="$LIBS"
LIBS="$all_libraries $USER_LDFLAGS -ljpeg$2 -lm"
ac_save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $all_includes $USER_INCLUDES"
AC_TRY_LINK(
[/* Override any gcc2 internal prototype to avoid an error.  */
struct jpeg_decompress_struct;
typedef struct jpeg_decompress_struct * j_decompress_ptr;
typedef int size_t;
#ifdef __cplusplus
extern "C" {
#endif
    void jpeg_CreateDecompress(j_decompress_ptr cinfo,
                                    int version, size_t structsize);
#ifdef __cplusplus
}
#endif
/* We use char because int might match the return type of a gcc2
    builtin and then its argument prototype would still apply.  */
],
            [jpeg_CreateDecompress(0L, 0, 0);],
            eval "ac_cv_lib_jpeg_$1=-ljpeg$2",
            eval "ac_cv_lib_jpeg_$1=no")
LIBS="$ac_save_LIBS"
CFLAGS="$ac_save_CFLAGS"
])

if eval "test ! \"`echo $ac_cv_lib_jpeg_$1`\" = no"; then
  LIBJPEG="$ac_cv_lib_jpeg_$1"
  AC_MSG_RESULT($ac_cv_lib_jpeg_$1)
else
  AC_MSG_RESULT(no)
  $3
fi

])

AC_DEFUN([AC_FIND_JPEG],
[
dnl first look for libraries
KDE_FIND_JPEG_HELPER(6b, 6b,
   KDE_FIND_JPEG_HELPER(normal, [],
    [
       LIBJPEG=
    ]
   )
)

dnl then search the headers (can't use simply AC_TRY_xxx, as jpeglib.h
dnl requires system dependent includes loaded before it)
jpeg_incdirs="$includedir /usr/include /usr/local/include $kde_extra_includes"
AC_FIND_FILE(jpeglib.h, $jpeg_incdirs, jpeg_incdir)
test "x$jpeg_incdir" = xNO && jpeg_incdir=

dnl if headers _and_ libraries are missing, this is no error, and we
dnl continue with a warning (the user will get no jpeg support in khtml)
dnl if only one is missing, it means a configuration error, but we still
dnl only warn
if test -n "$jpeg_incdir" && test -n "$LIBJPEG" ; then
  AC_DEFINE_UNQUOTED(HAVE_LIBJPEG, 1, [Define if you have libjpeg])
else
  if test -n "$jpeg_incdir" || test -n "$LIBJPEG" ; then
    AC_MSG_WARN([
There is an installation error in jpeg support. You seem to have only one
of either the headers _or_ the libraries installed. You may need to either
provide correct --with-extra-... options, or the development package of
libjpeg6b. You can get a source package of libjpeg from http://www.ijg.org/
Disabling JPEG support.
])
  else
    AC_MSG_WARN([libjpeg not found. disable JPEG support.])
  fi
  jpeg_incdir=
  LIBJPEG=
fi

AC_SUBST(LIBJPEG)
AH_VERBATIM(_AC_CHECK_JPEG,
[/*
 * jpeg.h needs HAVE_BOOLEAN, when the system uses boolean in system
 * headers and I'm too lazy to write a configure test as long as only
 * unixware is related
 */
#ifdef _UNIXWARE
#define HAVE_BOOLEAN
#endif
])
])

AC_DEFUN([KDE_CHECK_QT_JPEG],
[
if test -n "$LIBJPEG"; then
AC_MSG_CHECKING([if Qt needs $LIBJPEG])
AC_CACHE_VAL(kde_cv_qt_jpeg,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
ac_save_LIBS="$LIBS"
LIBS="$all_libraries $USER_LDFLAGS $LIBQT"
LIBS=`echo $LIBS | sed "s/$LIBJPEG//"`
ac_save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="$CXXFLAGS $all_includes $USER_INCLUDES"
AC_TRY_LINK(
[#include <qapplication.h>],
            [
            int argc;
            char** argv;
            QApplication app(argc, argv);],
            eval "kde_cv_qt_jpeg=no",
            eval "kde_cv_qt_jpeg=yes")
LIBS="$ac_save_LIBS"
CXXFLAGS="$ac_save_CXXFLAGS"
AC_LANG_RESTORE
fi
])

if eval "test ! \"`echo $kde_cv_qt_jpeg`\" = no"; then
  AC_MSG_RESULT(yes)
  LIBJPEG_QT='$(LIBJPEG)'
else
  AC_MSG_RESULT(no)
  LIBJPEG_QT=
fi

])

AC_DEFUN([AC_FIND_ZLIB],
[
AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])
AC_MSG_CHECKING([for libz])
AC_CACHE_VAL(ac_cv_lib_z,
[
kde_save_LIBS="$LIBS"
LIBS="$all_libraries $USER_LDFLAGS -lz $LIBSOCKET"
kde_save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $all_includes $USER_INCLUDES"
AC_TRY_LINK(dnl
[
#include<zlib.h>
],
[
  char buf[42];
  gzFile f = (gzFile) 0;
  /* this would segfault.. but we only link, don't run */
  (void) gzgets(f, buf, sizeof(buf));

  return (zlibVersion() == ZLIB_VERSION); 
],
            eval "ac_cv_lib_z='-lz'",
            eval "ac_cv_lib_z=no")
LIBS="$kde_save_LIBS"
CFLAGS="$kde_save_CFLAGS"
])dnl
if test ! "$ac_cv_lib_z" = no; then
  AC_DEFINE_UNQUOTED(HAVE_LIBZ, 1, [Define if you have libz])
  LIBZ="$ac_cv_lib_z"
  AC_MSG_RESULT($ac_cv_lib_z)
else
  AC_MSG_ERROR(not found. 
          Possibly configure picks up an outdated version
          installed by XFree86. Remove it from your system.

          Check your installation and look into config.log)
  LIBZ=""
fi
AC_SUBST(LIBZ)
])

AC_DEFUN([KDE_TRY_TIFFLIB],
[
AC_MSG_CHECKING([for libtiff $1])

AC_CACHE_VAL(kde_cv_libtiff_$1,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
kde_save_LIBS="$LIBS"
if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIBS="$all_libraries $USER_LDFLAGS -l$1 $LIBJPEG $LIBZ -lX11 $LIBSOCKET -lm"
else
LIBS="$all_libraries $USER_LDFLAGS -l$1 $LIBJPEG $LIBZ -lm"
fi
kde_save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="$CXXFLAGS $all_includes $USER_INCLUDES"

AC_TRY_LINK(dnl
[
#include<tiffio.h>
],
    [return (TIFFOpen( "", "r") == 0); ],
[
    kde_cv_libtiff_$1="-l$1 $LIBJPEG $LIBZ"
], [
    kde_cv_libtiff_$1=no
])

LIBS="$kde_save_LIBS"
CXXFLAGS="$kde_save_CXXFLAGS"
AC_LANG_RESTORE
])

if test "$kde_cv_libtiff_$1" = "no"; then
    AC_MSG_RESULT(no)
    LIBTIFF=""
    $3
else
    LIBTIFF="$kde_cv_libtiff_$1"
    AC_MSG_RESULT(yes)
    AC_DEFINE_UNQUOTED(HAVE_LIBTIFF, 1, [Define if you have libtiff])
    $2
fi

])

AC_DEFUN([AC_FIND_TIFF],
[
AC_REQUIRE([K_PATH_X])
AC_REQUIRE([AC_FIND_ZLIB])
AC_REQUIRE([AC_FIND_JPEG])
AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])

KDE_TRY_TIFFLIB(tiff, [],
   KDE_TRY_TIFFLIB(tiff34))

AC_SUBST(LIBTIFF)
])


AC_DEFUN([AC_FIND_PNG],
[
AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])
AC_REQUIRE([AC_FIND_ZLIB])
AC_MSG_CHECKING([for libpng])
AC_CACHE_VAL(ac_cv_lib_png,
[
kde_save_LIBS="$LIBS"
if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
LIBS="$LIBS $all_libraries $USER_LDFLAGS -lpng $LIBZ -lm -lX11 $LIBSOCKET"
else
LIBS="$LIBS $all_libraries $USER_LDFLAGS -lpng $LIBZ -lm"
fi
kde_save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $all_includes $USER_INCLUDES"

AC_TRY_LINK(dnl
    [
    #include<png.h>
    ],
    [
    png_structp png_ptr = png_create_read_struct(  /* image ptr */
		PNG_LIBPNG_VER_STRING, 0, 0, 0 );
    return( png_ptr != 0 );
    ],
    eval "ac_cv_lib_png='-lpng $LIBZ -lm'",
    eval "ac_cv_lib_png=no"
)
LIBS="$kde_save_LIBS"
CFLAGS="$kde_save_CFLAGS"
])dnl
if eval "test ! \"`echo $ac_cv_lib_png`\" = no"; then
  AC_DEFINE_UNQUOTED(HAVE_LIBPNG, 1, [Define if you have libpng])
  LIBPNG="$ac_cv_lib_png"
  AC_SUBST(LIBPNG)
  AC_MSG_RESULT($ac_cv_lib_png)
else
  AC_MSG_RESULT(no)
  LIBPNG=""
  AC_SUBST(LIBPNG)
fi
])


AC_DEFUN([AC_FIND_JASPER],
[
AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])
AC_REQUIRE([AC_FIND_JPEG])
AC_MSG_CHECKING([for jasper])
AC_CACHE_VAL(ac_cv_jasper,
[
kde_save_LIBS="$LIBS"
LIBS="$LIBS $all_libraries $USER_LDFLAGS -ljasper $LIBJPEG -lm"
kde_save_CFLAGS="$CFLAGS"
CFLAGS="$CFLAGS $all_includes $USER_INCLUDES"

AC_TRY_LINK(dnl
    [
    #include<jasper/jasper.h>
    ],
    [
    return( jas_init() );
    ],
    eval "ac_cv_jasper='-ljasper $LIBJPEG -lm'",
    eval "ac_cv_jasper=no"
)
LIBS="$kde_save_LIBS"
CFLAGS="$kde_save_CFLAGS"
])dnl
if eval "test ! \"`echo $ac_cv_jasper`\" = no"; then
  AC_DEFINE_UNQUOTED(HAVE_JASPER, 1, [Define if you have jasper])
  LIB_JASPER="$ac_cv_jasper"
  AC_MSG_RESULT($ac_cv_jasper)
else
  AC_MSG_RESULT(no)
  LIB_JASPER=""
fi
AC_SUBST(LIB_JASPER)
])

AC_DEFUN([AC_CHECK_BOOL],
[
  AC_DEFINE_UNQUOTED(HAVE_BOOL, 1, [You _must_ have bool])
])

AC_DEFUN([AC_CHECK_GNU_EXTENSIONS],
[
AC_MSG_CHECKING(if you need GNU extensions)
AC_CACHE_VAL(ac_cv_gnu_extensions,
[
cat > conftest.c << EOF
#include <features.h>

#ifdef __GNU_LIBRARY__
yes
#endif
EOF

if (eval "$ac_cpp conftest.c") 2>&5 |
  egrep "yes" >/dev/null 2>&1; then
  rm -rf conftest*
  ac_cv_gnu_extensions=yes
else
  ac_cv_gnu_extensions=no
fi
])

AC_MSG_RESULT($ac_cv_gnu_extensions)
if test "$ac_cv_gnu_extensions" = "yes"; then
  AC_DEFINE_UNQUOTED(_GNU_SOURCE, 1, [Define if you need to use the GNU extensions])
fi
])

AC_DEFUN([KDE_CHECK_COMPILER_FLAG],
[
AC_MSG_CHECKING([whether $CXX supports -$1])
kde_cache=`echo $1 | sed 'y% .=/+-,%____p__%'`
AC_CACHE_VAL(kde_cv_prog_cxx_$kde_cache,
[
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  save_CXXFLAGS="$CXXFLAGS"
  CXXFLAGS="$CXXFLAGS -$1"
  AC_TRY_LINK([],[ return 0; ], [eval "kde_cv_prog_cxx_$kde_cache=yes"], [])
  CXXFLAGS="$save_CXXFLAGS"
  AC_LANG_RESTORE
])
if eval "test \"`echo '$kde_cv_prog_cxx_'$kde_cache`\" = yes"; then
 AC_MSG_RESULT(yes)
 :
 $2
else
 AC_MSG_RESULT(no)
 :
 $3
fi
])

AC_DEFUN([KDE_CHECK_C_COMPILER_FLAG],
[
AC_MSG_CHECKING([whether $CC supports -$1])
kde_cache=`echo $1 | sed 'y% .=/+-,%____p__%'`
AC_CACHE_VAL(kde_cv_prog_cc_$kde_cache,
[
  AC_LANG_SAVE
  AC_LANG_C
  save_CFLAGS="$CFLAGS"
  CFLAGS="$CFLAGS -$1"
  AC_TRY_LINK([],[ return 0; ], [eval "kde_cv_prog_cc_$kde_cache=yes"], [])
  CFLAGS="$save_CFLAGS"
  AC_LANG_RESTORE
])
if eval "test \"`echo '$kde_cv_prog_cc_'$kde_cache`\" = yes"; then
 AC_MSG_RESULT(yes)
 :
 $2
else
 AC_MSG_RESULT(no)
 :
 $3
fi
])


dnl AC_REMOVE_FORBIDDEN removes forbidden arguments from variables
dnl use: AC_REMOVE_FORBIDDEN(CC, [-forbid -bad-option whatever])
dnl it's all white-space separated
AC_DEFUN([AC_REMOVE_FORBIDDEN],
[ __val=$$1
  __forbid=" $2 "
  if test -n "$__val"; then
    __new=""
    ac_save_IFS=$IFS
    IFS=" 	"
    for i in $__val; do
      case "$__forbid" in
        *" $i "*) AC_MSG_WARN([found forbidden $i in $1, removing it]) ;;
	*) # Careful to not add spaces, where there were none, because otherwise
	   # libtool gets confused, if we change e.g. CXX
	   if test -z "$__new" ; then __new=$i ; else __new="$__new $i" ; fi ;;
      esac
    done
    IFS=$ac_save_IFS
    $1=$__new
  fi
])

dnl AC_VALIDIFY_CXXFLAGS checks for forbidden flags the user may have given
AC_DEFUN([AC_VALIDIFY_CXXFLAGS],
[dnl
if test "x$kde_use_qt_emb" != "xyes"; then
 AC_REMOVE_FORBIDDEN(CXX, [-fno-rtti -rpath])
 AC_REMOVE_FORBIDDEN(CXXFLAGS, [-fno-rtti -rpath])
else
 AC_REMOVE_FORBIDDEN(CXX, [-rpath])
 AC_REMOVE_FORBIDDEN(CXXFLAGS, [-rpath])
fi
])

AC_DEFUN([AC_CHECK_COMPILERS],
[
  AC_ARG_ENABLE(debug,
	        AC_HELP_STRING([--enable-debug=ARG],[enables debug symbols (yes|no|full) [default=no]]),
  [
    case $enableval in
      yes)
        kde_use_debug_code="yes"
        kde_use_debug_define=no
        ;;
      full)
        kde_use_debug_code="full"
        kde_use_debug_define=no
        ;;
      *)
        kde_use_debug_code="no"
        kde_use_debug_define=yes
        ;;
    esac
  ], 
    [kde_use_debug_code="no"
      kde_use_debug_define=no
  ])

  dnl Just for configure --help
  AC_ARG_ENABLE(dummyoption,
	        AC_HELP_STRING([--disable-debug],
	  		       [disables debug output and debug symbols [default=no]]),
		[],[])

  AC_ARG_ENABLE(strict,
		AC_HELP_STRING([--enable-strict],
			      [compiles with strict compiler options (may not work!)]),
   [
    if test $enableval = "no"; then
         kde_use_strict_options="no"
       else
         kde_use_strict_options="yes"
    fi
   ], [kde_use_strict_options="no"])

  AC_ARG_ENABLE(warnings,AC_HELP_STRING([--disable-warnings],[disables compilation with -Wall and similiar]),
   [
    if test $enableval = "no"; then
         kde_use_warnings="no"
       else
         kde_use_warnings="yes"
    fi
   ], [kde_use_warnings="yes"])

  dnl enable warnings for debug build
  if test "$kde_use_debug_code" != "no"; then
    kde_use_warnings=yes
  fi

  AC_ARG_ENABLE(profile,AC_HELP_STRING([--enable-profile],[creates profiling infos [default=no]]),
    [kde_use_profiling=$enableval],
    [kde_use_profiling="no"]
  )

  dnl this prevents stupid AC_PROG_CC to add "-g" to the default CFLAGS
  CFLAGS=" $CFLAGS"

  AC_PROG_CC 

  AC_PROG_CPP

  if test "$GCC" = "yes"; then
    if test "$kde_use_debug_code" != "no"; then
      if test $kde_use_debug_code = "full"; then
        CFLAGS="-g3 -fno-inline $CFLAGS"
      else
        CFLAGS="-g -O2 $CFLAGS"
      fi
    else
      CFLAGS="-O2 $CFLAGS"
    fi
  fi

  if test "$kde_use_debug_define" = "yes"; then
    CFLAGS="-DNDEBUG $CFLAGS"
  fi


  case "$host" in
  *-*-sysv4.2uw*) CFLAGS="-D_UNIXWARE $CFLAGS";;
  *-*-sysv5uw7*) CFLAGS="-D_UNIXWARE7 $CFLAGS";;
  esac

  if test -z "$LDFLAGS" && test "$kde_use_debug_code" = "no" && test "$GCC" = "yes"; then
     LDFLAGS=""
  fi

  CXXFLAGS=" $CXXFLAGS"

  AC_PROG_CXX

  if test "$GXX" = "yes" || test "$CXX" = "KCC"; then
    if test "$kde_use_debug_code" != "no"; then
      if test "$CXX" = "KCC"; then
        CXXFLAGS="+K0 -Wall -pedantic -W -Wpointer-arith -Wwrite-strings $CXXFLAGS"
      else
        if test "$kde_use_debug_code" = "full"; then
          CXXFLAGS="-g3 -fno-inline $CXXFLAGS"
        else
          CXXFLAGS="-g -O2 $CXXFLAGS"
        fi
      fi
      KDE_CHECK_COMPILER_FLAG(fno-builtin,[CXXFLAGS="-fno-builtin $CXXFLAGS"])

      dnl convenience compiler flags
      KDE_CHECK_COMPILER_FLAG(Woverloaded-virtual, [WOVERLOADED_VIRTUAL="-Woverloaded-virtual"], [WOVERLOADED_VRITUAL=""])
      AC_SUBST(WOVERLOADED_VIRTUAL)
    else
      if test "$CXX" = "KCC"; then
        CXXFLAGS="+K3 $CXXFLAGS"
      else
        CXXFLAGS="-O2 $CXXFLAGS"
      fi  
    fi
  fi

  if test "$kde_use_debug_define" = "yes"; then
    CXXFLAGS="-DNDEBUG -DNO_DEBUG $CXXFLAGS"
  fi  

  if test "$kde_use_profiling" = "yes"; then
    KDE_CHECK_COMPILER_FLAG(pg,
    [
      CFLAGS="-pg $CFLAGS"
      CXXFLAGS="-pg $CXXFLAGS"
    ])
  fi

  if test "$kde_use_warnings" = "yes"; then
      if test "$GCC" = "yes"; then
        CXXFLAGS="-Wall -W -Wpointer-arith -Wwrite-strings $CXXFLAGS"
        case $host in
          *-*-linux-gnu)	
            CFLAGS="-ansi -W -Wall -Wchar-subscripts -Wshadow -Wpointer-arith -Wmissing-prototypes -Wwrite-strings -D_XOPEN_SOURCE=500 -D_BSD_SOURCE $CFLAGS"
            CXXFLAGS="-ansi -D_XOPEN_SOURCE=500 -D_BSD_SOURCE -Wcast-align -Wconversion -Wchar-subscripts $CXXFLAGS"
            KDE_CHECK_COMPILER_FLAG(Wmissing-format-attribute, [CXXFLAGS="$CXXFLAGS -Wformat-security -Wmissing-format-attribute"])
            KDE_CHECK_C_COMPILER_FLAG(Wmissing-format-attribute, [CFLAGS="$CFLAGS -Wformat-security -Wmissing-format-attribute"])
          ;;
        esac
        KDE_CHECK_COMPILER_FLAG(Wundef,[CXXFLAGS="-Wundef $CXXFLAGS"])
        KDE_CHECK_COMPILER_FLAG(Wno-long-long,[CXXFLAGS="-Wno-long-long $CXXFLAGS"])
        KDE_CHECK_COMPILER_FLAG(Wnon-virtual-dtor,[CXXFLAGS="-Wnon-virtual-dtor $CXXFLAGS"])
     fi
  fi

  if test "$GXX" = "yes" && test "$kde_use_strict_options" = "yes"; then
    CXXFLAGS="-Wcast-qual -Wshadow -Wcast-align $CXXFLAGS"
  fi
    
  if test "$GXX" = "yes"; then
    KDE_CHECK_COMPILER_FLAG(fno-exceptions,[CXXFLAGS="$CXXFLAGS -fno-exceptions"])
    KDE_CHECK_COMPILER_FLAG(fno-check-new, [CXXFLAGS="$CXXFLAGS -fno-check-new"])
    KDE_CHECK_COMPILER_FLAG(fno-common, [CXXFLAGS="$CXXFLAGS -fno-common"])
    KDE_CHECK_COMPILER_FLAG(fexceptions, [USE_EXCEPTIONS="-fexceptions"], USE_EXCEPTIONS=	)
    ENABLE_PERMISSIVE_FLAG="-fpermissive"
  fi
  if test "$CXX" = "KCC"; then
    dnl unfortunately we currently cannot disable exception support in KCC
    dnl because doing so is binary incompatible and Qt by default links with exceptions :-(
    dnl KDE_CHECK_COMPILER_FLAG(-no_exceptions,[CXXFLAGS="$CXXFLAGS --no_exceptions"])
    dnl KDE_CHECK_COMPILER_FLAG(-exceptions, [USE_EXCEPTIONS="--exceptions"], USE_EXCEPTIONS=	)

    AC_ARG_ENABLE(pch,
	AC_HELP_STRING([--enable-pch],
		       [enables precompiled header support (currently only KCC) [default=no]]),
    [
      kde_use_pch=$enableval
    ],[kde_use_pch=no])
 
    if test "$kde_use_pch" = "yes"; then
      dnl TODO: support --pch-dir!
      KDE_CHECK_COMPILER_FLAG(-pch,[CXXFLAGS="$CXXFLAGS --pch"])
      dnl the below works (but the dir must exist), but it's
      dnl useless for a whole package.
      dnl The are precompiled headers for each source file, so when compiling
      dnl from scratch, it doesn't make a difference, and they take up
      dnl around ~5Mb _per_ sourcefile.
      dnl KDE_CHECK_COMPILER_FLAG(-pch_dir /tmp,
      dnl   [CXXFLAGS="$CXXFLAGS --pch_dir `pwd`/pcheaders"])
    fi
    dnl this flag controls inlining. by default KCC inlines in optimisation mode
    dnl all implementations that are defined inside the class {} declaration. 
    dnl because of templates-compatibility with broken gcc compilers, this
    dnl can cause excessive inlining. This flag limits it to a sane level
    KDE_CHECK_COMPILER_FLAG(-inline_keyword_space_time=6,[CXXFLAGS="$CXXFLAGS --inline_keyword_space_time=6"])
    KDE_CHECK_COMPILER_FLAG(-inline_auto_space_time=2,[CXXFLAGS="$CXXFLAGS --inline_auto_space_time=2"])
    KDE_CHECK_COMPILER_FLAG(-inline_implicit_space_time=2.0,[CXXFLAGS="$CXXFLAGS --inline_implicit_space_time=2.0"])
    KDE_CHECK_COMPILER_FLAG(-inline_generated_space_time=2.0,[CXXFLAGS="$CXXFLAGS --inline_generated_space_time=2.0"])
    dnl Some source files are shared between multiple executables
    dnl (or libraries) and some of those need template instantiations.
    dnl In that case KCC needs to compile those sources with
    dnl --one_instantiation_per_object.  To make it easy for us we compile
    dnl _all_ objects with that flag (--one_per is a shorthand).
    KDE_CHECK_COMPILER_FLAG(-one_per, [CXXFLAGS="$CXXFLAGS --one_per"])
  fi
  AC_SUBST(USE_EXCEPTIONS)
  dnl obsolete macro - provided to keep things going
  USE_RTTI=
  AC_SUBST(USE_RTTI)

  case "$host" in
      *-*-irix*)  test "$GXX" = yes && CXXFLAGS="-D_LANGUAGE_C_PLUS_PLUS -D__LANGUAGE_C_PLUS_PLUS $CXXFLAGS" ;;
      *-*-sysv4.2uw*) CXXFLAGS="-D_UNIXWARE $CXXFLAGS";;
      *-*-sysv5uw7*) CXXFLAGS="-D_UNIXWARE7 $CXXFLAGS";;
      *-*-solaris*) 
        if test "$GXX" = yes; then
          libstdcpp=`$CXX -print-file-name=libstdc++.so`
          if test ! -f $libstdcpp; then
             AC_MSG_ERROR([You've compiled gcc without --enable-shared. This doesn't work with KDE. Please recompile gcc with --enable-shared to receive a libstdc++.so])
          fi
        fi
        ;;
  esac

  AC_VALIDIFY_CXXFLAGS

  AC_PROG_CXXCPP

  if test "$GCC" = yes; then
     NOOPT_CFLAGS=-O0
  fi
  KDE_CHECK_COMPILER_FLAG(O0,[NOOPT_CXXFLAGS=-O0])

  AC_SUBST(NOOPT_CXXFLAGS)
  AC_SUBST(NOOPT_CFLAGS)
  AC_SUBST(ENABLE_PERMISSIVE_FLAG)

  KDE_CHECK_FINAL
  KDE_CHECK_CLOSURE
  KDE_CHECK_NMCHECK

  ifdef([AM_DEPENDENCIES], AC_REQUIRE([KDE_ADD_DEPENDENCIES]), [])
])

AC_DEFUN([KDE_ADD_DEPENDENCIES],
[
   [A]M_DEPENDENCIES(CC)
   [A]M_DEPENDENCIES(CXX)
])

dnl just a wrapper to clean up configure.in
AC_DEFUN([KDE_PROG_LIBTOOL],
[
AC_REQUIRE([AC_CHECK_COMPILERS])
AC_REQUIRE([AC_ENABLE_SHARED])
AC_REQUIRE([AC_ENABLE_STATIC])

AC_REQUIRE([AC_LIBTOOL_DLOPEN])
AC_REQUIRE([KDE_CHECK_LIB64])

AC_OBJEXT
AC_EXEEXT

AC_PROG_LIBTOOL
AC_LIBTOOL_CXX

LIBTOOL_SHELL="/bin/sh ./libtool"
#  LIBTOOL="$LIBTOOL --silent"
KDE_PLUGIN="-avoid-version -module -no-undefined \$(KDE_NO_UNDEFINED) \$(KDE_RPATH) \$(KDE_MT_LDFLAGS)"
AC_SUBST(KDE_PLUGIN)

# we patch configure quite some so we better keep that consistent for incremental runs 
AC_SUBST(AUTOCONF,'$(SHELL) $(top_srcdir)/admin/cvs.sh configure || touch configure')
])

AC_DEFUN([KDE_CHECK_LIB64],
[
    kdelibsuff=no
    AC_ARG_ENABLE(libsuffix,
        AC_HELP_STRING([--enable-libsuffix],
            [/lib directory suffix (64,32,none[=default])]),
            kdelibsuff=$enableval)
    # TODO: add an auto case that compiles a little C app to check
    # where the glibc is
    if test "$kdelibsuff" = "no"; then
       kdelibsuff=
    fi
    if test -z "$kdelibsuff"; then
        AC_MSG_RESULT([not using lib directory suffix])
        AC_DEFINE(KDELIBSUFF, [""], Suffix for lib directories)
    else
        if test "$libdir" = '${exec_prefix}/lib'; then
            libdir="$libdir${kdelibsuff}"
            AC_SUBST([libdir], ["$libdir"])  dnl ugly hack for lib64 platforms
        fi
        AC_DEFINE_UNQUOTED(KDELIBSUFF, ["${kdelibsuff}"], Suffix for lib directories)
        AC_MSG_RESULT([using lib directory suffix $kdelibsuff])
    fi
])

AC_DEFUN([KDE_CHECK_TYPES],
[  AC_CHECK_SIZEOF(int, 4)dnl
   AC_CHECK_SIZEOF(short)dnl
  AC_CHECK_SIZEOF(long, 4)dnl
  AC_CHECK_SIZEOF(char *, 4)dnl
])dnl

dnl Not used - kept for compat only?
AC_DEFUN([KDE_DO_IT_ALL],
[
AC_CANONICAL_SYSTEM
AC_ARG_PROGRAM
AM_INIT_AUTOMAKE($1, $2)
AM_DISABLE_LIBRARIES
AC_PREFIX_DEFAULT(${KDEDIR:-/usr/local/kde})
AC_CHECK_COMPILERS
KDE_PROG_LIBTOOL
AM_KDE_WITH_NLS
AC_PATH_KDE
])

AC_DEFUN([AC_CHECK_RPATH],
[
AC_MSG_CHECKING(for rpath)
AC_ARG_ENABLE(rpath,
      AC_HELP_STRING([--disable-rpath],[do not use the rpath feature of ld]),
      USE_RPATH=$enableval, USE_RPATH=yes)

if test -z "$KDE_RPATH" && test "$USE_RPATH" = "yes"; then

  KDE_RPATH="-R \$(kde_libraries)"

  if test -n "$qt_libraries"; then
    KDE_RPATH="$KDE_RPATH -R \$(qt_libraries)"
  fi
  dnl $x_libraries is set to /usr/lib in case
  if test -n "$X_LDFLAGS"; then
    X_RPATH="-R \$(x_libraries)"
    KDE_RPATH="$KDE_RPATH $X_RPATH"
  fi
  if test -n "$KDE_EXTRA_RPATH"; then
    KDE_RPATH="$KDE_RPATH \$(KDE_EXTRA_RPATH)"
  fi
fi
AC_SUBST(KDE_EXTRA_RPATH)
AC_SUBST(KDE_RPATH)
AC_SUBST(X_RPATH)
AC_MSG_RESULT($USE_RPATH)
])

dnl Check for the type of the third argument of getsockname
AC_DEFUN([AC_CHECK_SOCKLEN_T],
[
   AC_MSG_CHECKING(for socklen_t)
   AC_CACHE_VAL(kde_cv_socklen_t,
   [
      AC_LANG_PUSH(C++)
      kde_cv_socklen_t=no
      AC_TRY_COMPILE([
         #include <sys/types.h>
         #include <sys/socket.h>
      ],
      [
         socklen_t len;
         getpeername(0,0,&len);
      ],
      [
         kde_cv_socklen_t=yes
         kde_cv_socklen_t_equiv=socklen_t
      ])
      AC_LANG_POP(C++)
   ])
   AC_MSG_RESULT($kde_cv_socklen_t)
   if test $kde_cv_socklen_t = no; then
      AC_MSG_CHECKING([for socklen_t equivalent for socket functions])
      AC_CACHE_VAL(kde_cv_socklen_t_equiv,
      [
         kde_cv_socklen_t_equiv=int
         AC_LANG_PUSH(C++)
         for t in int size_t unsigned long "unsigned long"; do
            AC_TRY_COMPILE([
               #include <sys/types.h>
               #include <sys/socket.h>
            ],
            [
               $t len;
               getpeername(0,0,&len);
            ],
            [
               kde_cv_socklen_t_equiv="$t"
               break
            ])
         done
         AC_LANG_POP(C++)
      ])
      AC_MSG_RESULT($kde_cv_socklen_t_equiv)
   fi
   AC_DEFINE_UNQUOTED(kde_socklen_t, $kde_cv_socklen_t_equiv,
                     [type to use in place of socklen_t if not defined])
   AC_DEFINE_UNQUOTED(ksize_t, $kde_cv_socklen_t_equiv,
                     [type to use in place of socklen_t if not defined (deprecated, use kde_socklen_t)])
])

dnl This is a merge of some macros out of the gettext aclocal.m4
dnl since we don't need anything, I took the things we need
dnl the copyright for them is:
dnl >
dnl Copyright (C) 1994, 1995, 1996, 1997, 1998 Free Software Foundation, Inc.
dnl This Makefile.in is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY, to the extent permitted by law; without
dnl even the implied warranty of MERCHANTABILITY or FITNESS FOR A
dnl PARTICULAR PURPOSE.
dnl >
dnl for this file it is relicensed under LGPL

AC_DEFUN([AM_KDE_WITH_NLS],
  [
    dnl If we use NLS figure out what method

    AM_PATH_PROG_WITH_TEST_KDE(MSGFMT, msgfmt,
        [test -n "`$ac_dir/$ac_word --version 2>&1 | grep 'GNU gettext'`"], msgfmt)
    AC_PATH_PROG(GMSGFMT, gmsgfmt, $MSGFMT)

     if test -z "`$GMSGFMT --version 2>&1 | grep 'GNU gettext'`"; then
        AC_MSG_RESULT([found msgfmt program is not GNU msgfmt; ignore it])
        GMSGFMT=":"
      fi
      MSGFMT=$GMSGFMT
      AC_SUBST(GMSGFMT)
      AC_SUBST(MSGFMT)

      AM_PATH_PROG_WITH_TEST_KDE(XGETTEXT, xgettext,
	[test -z "`$ac_dir/$ac_word -h 2>&1 | grep '(HELP)'`"], :)

      dnl Test whether we really found GNU xgettext.
      if test "$XGETTEXT" != ":"; then
	dnl If it is no GNU xgettext we define it as : so that the
	dnl Makefiles still can work.
	if $XGETTEXT --omit-header /dev/null 2> /dev/null; then
	  : ;
	else
	  AC_MSG_RESULT(
	    [found xgettext programs is not GNU xgettext; ignore it])
	  XGETTEXT=":"
	fi
      fi
     AC_SUBST(XGETTEXT)

  ])

# Search path for a program which passes the given test.
# Ulrich Drepper <drepper@cygnus.com>, 1996.

# serial 1
# Stephan Kulow: I appended a _KDE against name conflicts

dnl AM_PATH_PROG_WITH_TEST_KDE(VARIABLE, PROG-TO-CHECK-FOR,
dnl   TEST-PERFORMED-ON-FOUND_PROGRAM [, VALUE-IF-NOT-FOUND [, PATH]])
AC_DEFUN([AM_PATH_PROG_WITH_TEST_KDE],
[# Extract the first word of "$2", so it can be a program name with args.
set dummy $2; ac_word=[$]2
AC_MSG_CHECKING([for $ac_word])
AC_CACHE_VAL(ac_cv_path_$1,
[case "[$]$1" in
  /*)
  ac_cv_path_$1="[$]$1" # Let the user override the test with a path.
  ;;
  *)
  IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS="${IFS}:"
  for ac_dir in ifelse([$5], , $PATH, [$5]); do
    test -z "$ac_dir" && ac_dir=.
    if test -f $ac_dir/$ac_word; then
      if [$3]; then
	ac_cv_path_$1="$ac_dir/$ac_word"
	break
      fi
    fi
  done
  IFS="$ac_save_ifs"
dnl If no 4th arg is given, leave the cache variable unset,
dnl so AC_PATH_PROGS will keep looking.
ifelse([$4], , , [  test -z "[$]ac_cv_path_$1" && ac_cv_path_$1="$4"
])dnl
  ;;
esac])dnl
$1="$ac_cv_path_$1"
if test -n "[$]$1"; then
  AC_MSG_RESULT([$]$1)
else
  AC_MSG_RESULT(no)
fi
AC_SUBST($1)dnl
])


# Check whether LC_MESSAGES is available in <locale.h>.
# Ulrich Drepper <drepper@cygnus.com>, 1995.

# serial 1

AC_DEFUN([AM_LC_MESSAGES],
  [if test $ac_cv_header_locale_h = yes; then
    AC_CACHE_CHECK([for LC_MESSAGES], am_cv_val_LC_MESSAGES,
      [AC_TRY_LINK([#include <locale.h>], [return LC_MESSAGES],
       am_cv_val_LC_MESSAGES=yes, am_cv_val_LC_MESSAGES=no)])
    if test $am_cv_val_LC_MESSAGES = yes; then
      AC_DEFINE(HAVE_LC_MESSAGES, 1, [Define if your locale.h file contains LC_MESSAGES])
    fi
  fi])

dnl From Jim Meyering.
dnl FIXME: migrate into libit.

AC_DEFUN([AM_FUNC_OBSTACK],
[AC_CACHE_CHECK([for obstacks], am_cv_func_obstack,
 [AC_TRY_LINK([#include "obstack.h"],
	      [struct obstack *mem;obstack_free(mem,(char *) 0)],
	      am_cv_func_obstack=yes,
	      am_cv_func_obstack=no)])
 if test $am_cv_func_obstack = yes; then
   AC_DEFINE(HAVE_OBSTACK)
 else
   LIBOBJS="$LIBOBJS obstack.o"
 fi
])

dnl From Jim Meyering.  Use this if you use the GNU error.[ch].
dnl FIXME: Migrate into libit

AC_DEFUN([AM_FUNC_ERROR_AT_LINE],
[AC_CACHE_CHECK([for error_at_line], am_cv_lib_error_at_line,
 [AC_TRY_LINK([],[error_at_line(0, 0, "", 0, "");],
              am_cv_lib_error_at_line=yes,
	      am_cv_lib_error_at_line=no)])
 if test $am_cv_lib_error_at_line = no; then
   LIBOBJS="$LIBOBJS error.o"
 fi
 AC_SUBST(LIBOBJS)dnl
])

# Macro to add for using GNU gettext.
# Ulrich Drepper <drepper@cygnus.com>, 1995.

# serial 1
# Stephan Kulow: I put a KDE in it to avoid name conflicts

AC_DEFUN([AM_KDE_GNU_GETTEXT],
  [AC_REQUIRE([AC_PROG_MAKE_SET])dnl
   AC_REQUIRE([AC_PROG_RANLIB])dnl
   AC_REQUIRE([AC_HEADER_STDC])dnl
   AC_REQUIRE([AC_TYPE_OFF_T])dnl
   AC_REQUIRE([AC_TYPE_SIZE_T])dnl
   AC_REQUIRE([AC_FUNC_ALLOCA])dnl
   AC_REQUIRE([AC_FUNC_MMAP])dnl
   AC_REQUIRE([AM_KDE_WITH_NLS])dnl
   AC_CHECK_HEADERS([limits.h locale.h nl_types.h string.h values.h alloca.h])
   AC_CHECK_FUNCS([getcwd munmap putenv setlocale strchr strcasecmp \
__argz_count __argz_stringify __argz_next])

   AC_MSG_CHECKING(for stpcpy)
   AC_CACHE_VAL(kde_cv_func_stpcpy,
   [
   kde_safe_cxxflags=$CXXFLAGS
   CXXFLAGS="-Werror"
   AC_LANG_SAVE
   AC_LANG_CPLUSPLUS
   AC_TRY_COMPILE([
   #include <string.h>
   ],
   [
   char buffer[200];
   stpcpy(buffer, buffer);
   ],
   kde_cv_func_stpcpy=yes,
   kde_cv_func_stpcpy=no)
   AC_LANG_RESTORE
   CXXFLAGS=$kde_safe_cxxflags
   ])
   AC_MSG_RESULT($kde_cv_func_stpcpy)
   if eval "test \"`echo $kde_cv_func_stpcpy`\" = yes"; then
     AC_DEFINE(HAVE_STPCPY, 1, [Define if you have stpcpy])
   fi

   AM_LC_MESSAGES

   if test "x$CATOBJEXT" != "x"; then
     if test "x$ALL_LINGUAS" = "x"; then
       LINGUAS=
     else
       AC_MSG_CHECKING(for catalogs to be installed)
       NEW_LINGUAS=
       for lang in ${LINGUAS=$ALL_LINGUAS}; do
         case "$ALL_LINGUAS" in
          *$lang*) NEW_LINGUAS="$NEW_LINGUAS $lang" ;;
         esac
       done
       LINGUAS=$NEW_LINGUAS
       AC_MSG_RESULT($LINGUAS)
     fi

     dnl Construct list of names of catalog files to be constructed.
     if test -n "$LINGUAS"; then
       for lang in $LINGUAS; do CATALOGS="$CATALOGS $lang$CATOBJEXT"; done
     fi
   fi

  ])

AC_DEFUN([AC_HAVE_XPM],
 [AC_REQUIRE_CPP()dnl
  AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])

 test -z "$XPM_LDFLAGS" && XPM_LDFLAGS=
 test -z "$XPM_INCLUDE" && XPM_INCLUDE=

 AC_ARG_WITH(xpm,AC_HELP_STRING([--without-xpm],[disable color pixmap XPM tests]),
	xpm_test=$withval, xpm_test="yes")
 if test "x$xpm_test" = xno; then
   ac_cv_have_xpm=no
 else
   AC_MSG_CHECKING(for XPM)
   AC_CACHE_VAL(ac_cv_have_xpm,
   [
    ac_save_ldflags="$LDFLAGS"
    ac_save_cflags="$CFLAGS"
    if test "x$kde_use_qt_emb" != "xyes" && test "x$kde_use_qt_mac" != "xyes"; then
      LDFLAGS="$LDFLAGS $X_LDFLAGS $USER_LDFLAGS $LDFLAGS $XPM_LDFLAGS $all_libraries -lXpm -lX11 -lXext $LIBZ $LIBSOCKET"
    else
      LDFLAGS="$LDFLAGS $X_LDFLAGS $USER_LDFLAGS $LDFLAGS $XPM_LDFLAGS $all_libraries -lXpm $LIBZ $LIBSOCKET"
    fi
    CFLAGS="$CFLAGS $X_INCLUDES $USER_INCLUDES"
    test -n "$XPM_INCLUDE" && CFLAGS="-I$XPM_INCLUDE $CFLAGS"
    AC_TRY_LINK([#include <X11/xpm.h>],[],
	ac_cv_have_xpm="yes",ac_cv_have_xpm="no")
    LDFLAGS="$ac_save_ldflags"
    CFLAGS="$ac_save_cflags"
   ])dnl

  if test "$ac_cv_have_xpm" = no; then
    AC_MSG_RESULT(no)
    XPM_LDFLAGS=""
    XPMINC=""
    $2
  else
    AC_DEFINE(HAVE_XPM, 1, [Define if you have XPM support])
    if test "$XPM_LDFLAGS" = ""; then
       XPMLIB='-lXpm $(LIB_X11)'
    else
       XPMLIB="-L$XPM_LDFLAGS -lXpm "'$(LIB_X11)'
    fi
    if test "$XPM_INCLUDE" = ""; then
       XPMINC=""
    else
       XPMINC="-I$XPM_INCLUDE"
    fi
    AC_MSG_RESULT(yes)
    $1
  fi
 fi
 AC_SUBST(XPMINC)
 AC_SUBST(XPMLIB)
])

AC_DEFUN([AC_HAVE_DPMS],
 [AC_REQUIRE_CPP()dnl
  AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])

 test -z "$DPMS_LDFLAGS" && DPMS_LDFLAGS=
 test -z "$DPMS_INCLUDE" && DPMS_INCLUDE=
 DPMS_LIB=

 AC_ARG_WITH(dpms,AC_HELP_STRING([--without-dpms],[disable DPMS power saving]),
	dpms_test=$withval, dpms_test="yes")
 if test "x$dpms_test" = xno; then
   ac_cv_have_dpms=no
 else
   AC_MSG_CHECKING(for DPMS)
   dnl Note: ac_cv_have_dpms can be no, yes, or -lXdpms.
   dnl 'yes' means DPMS_LIB="", '-lXdpms' means DPMS_LIB="-lXdpms".
   AC_CACHE_VAL(ac_cv_have_dpms,
   [
    if test "x$kde_use_qt_emb" = "xyes" || test "x$kde_use_qt_mac" = "xyes"; then
      AC_MSG_RESULT(no)
      ac_cv_have_dpms="no"
    else
      ac_save_ldflags="$LDFLAGS"
      ac_save_cflags="$CFLAGS"
      ac_save_libs="$LIBS"
      LDFLAGS="$LDFLAGS $DPMS_LDFLAGS $all_libraries -lX11 -lXext $LIBSOCKET"
      CFLAGS="$CFLAGS $X_INCLUDES"
      test -n "$DPMS_INCLUDE" && CFLAGS="-I$DPMS_INCLUDE $CFLAGS"
      AC_TRY_LINK([
	  #include <X11/Xproto.h>
	  #include <X11/X.h>
	  #include <X11/Xlib.h>
	  #include <X11/extensions/dpms.h>
	  int foo_test_dpms()
	  { return DPMSSetTimeouts( 0, 0, 0, 0 ); }],[],
	  ac_cv_have_dpms="yes", [
              LDFLAGS="$ac_save_ldflags"
              CFLAGS="$ac_save_cflags"
              LDFLAGS="$LDFLAGS $DPMS_LDFLAGS $all_libraries -lX11 -lXext $LIBSOCKET"
              LIBS="$LIBS -lXdpms"
              CFLAGS="$CFLAGS $X_INCLUDES"
              test -n "$DPMS_INCLUDE" && CFLAGS="-I$DPMS_INCLUDE $CFLAGS"
              AC_TRY_LINK([
	          #include <X11/Xproto.h>
        	  #include <X11/X.h>
        	  #include <X11/Xlib.h>
        	  #include <X11/extensions/dpms.h>
        	  int foo_test_dpms()
        	  { return DPMSSetTimeouts( 0, 0, 0, 0 ); }],[],
        	  [
                  ac_cv_have_dpms="-lXdpms"
                  ],ac_cv_have_dpms="no")
              ])
      LDFLAGS="$ac_save_ldflags"
      CFLAGS="$ac_save_cflags"
      LIBS="$ac_save_libs"
    fi
   ])dnl

  if test "$ac_cv_have_dpms" = no; then
    AC_MSG_RESULT(no)
    DPMS_LDFLAGS=""
    DPMSINC=""
    $2
  else
    AC_DEFINE(HAVE_DPMS, 1, [Define if you have DPMS support])
    if test "$ac_cv_have_dpms" = "-lXdpms"; then
       DPMS_LIB="-lXdpms"
    fi
    if test "$DPMS_LDFLAGS" = ""; then
       DPMSLIB="$DPMS_LIB "'$(LIB_X11)'
    else
       DPMSLIB="$DPMS_LDFLAGS $DPMS_LIB "'$(LIB_X11)'
    fi
    if test "$DPMS_INCLUDE" = ""; then
       DPMSINC=""
    else
       DPMSINC="-I$DPMS_INCLUDE"
    fi
    AC_MSG_RESULT(yes)
    $1
  fi
 fi
 ac_save_cflags="$CFLAGS"
 CFLAGS="$CFLAGS $X_INCLUDES"
 test -n "$DPMS_INCLUDE" && CFLAGS="-I$DPMS_INCLUDE $CFLAGS"
 AH_TEMPLATE(HAVE_DPMSCAPABLE_PROTO,
   [Define if you have the DPMSCapable prototype in <X11/extensions/dpms.h>])
 AC_CHECK_DECL(DPMSCapable,
   AC_DEFINE(HAVE_DPMSCAPABLE_PROTO),,
   [#include <X11/extensions/dpms.h>])
 AH_TEMPLATE(HAVE_DPMSINFO_PROTO,
   [Define if you have the DPMSInfo prototype in <X11/extensions/dpms.h>])
 AC_CHECK_DECL(DPMSInfo,
   AC_DEFINE(HAVE_DPMSINFO_PROTO),,
   [#include <X11/extensions/dpms.h>])
 CFLAGS="$ac_save_cflags"
 AC_SUBST(DPMSINC)
 AC_SUBST(DPMSLIB)
])

AC_DEFUN([AC_HAVE_GL],
 [AC_REQUIRE_CPP()dnl
  AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])

 test -z "$GL_LDFLAGS" && GL_LDFLAGS=
 test -z "$GL_INCLUDE" && GL_INCLUDE=

 AC_ARG_WITH(gl,AC_HELP_STRING([--without-gl],[disable 3D GL modes]),
	gl_test=$withval, gl_test="yes")
 if test "x$kde_use_qt_emb" = "xyes"; then
   # GL and Qt Embedded is a no-go for now.
   ac_cv_have_gl=no
 elif test "x$gl_test" = xno; then
   ac_cv_have_gl=no
 else
   AC_MSG_CHECKING(for GL)
   AC_CACHE_VAL(ac_cv_have_gl,
   [
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
    ac_save_ldflags="$LDFLAGS"
    ac_save_cxxflags="$CXXFLAGS"
    LDFLAGS="$LDFLAGS $GL_LDFLAGS $X_LDFLAGS $all_libraries -lMesaGL -lMesaGLU"
    test "x$kde_use_qt_mac" != xyes && test "x$kde_use_qt_emb" != xyes && LDFLAGS="$LDFLAGS -lX11"
    LDFLAGS="$LDFLAGS $LIB_XEXT -lm $LIBSOCKET"
    CXXFLAGS="$CFLAGS $X_INCLUDES"
    test -n "$GL_INCLUDE" && CFLAGS="-I$GL_INCLUDE $CFLAGS"
    AC_TRY_LINK([#include <GL/gl.h>
#include <GL/glu.h>
], [],
	ac_cv_have_gl="mesa", ac_cv_have_gl="no")
    if test "x$ac_cv_have_gl" = "xno"; then
      LDFLAGS="$ac_save_ldflags $X_LDFLAGS $GL_LDFLAGS $all_libraries -lGLU -lGL"
      test "x$kde_use_qt_mac" != xyes && test "x$kde_use_qt_emb" != xyes && LDFLAGS="$LDFLAGS -lX11"
      LDFLAGS="$LDFLAGS $LIB_XEXT -lm $LIBSOCKET"
      CXXFLAGS="$ac_save_cflags $X_INCLUDES"
      test -n "$GL_INCLUDE" && CFLAGS="-I$GL_INCLUDE $CFLAGS"
      AC_TRY_LINK([#include <GL/gl.h>
#include <GL/glu.h>
], [],
	  ac_cv_have_gl="yes", ac_cv_have_gl="no")
    fi
    AC_LANG_RESTORE
    LDFLAGS="$ac_save_ldflags"
    CXXFLAGS="$ac_save_cxxflags"
   ])dnl

  if test "$ac_cv_have_gl" = "no"; then
    AC_MSG_RESULT(no)
    GL_LDFLAGS=""
    GLINC=""
    $2
  else
    AC_DEFINE(HAVE_GL, 1, [Defines if you have GL (Mesa, OpenGL, ...)])
    if test "$GL_LDFLAGS" = ""; then
       if test "$ac_cv_have_gl" = "mesa"; then
          GLLIB='-lMesaGLU -lMesaGL $(LIB_X11)'
       else
          GLLIB='-lGLU -lGL $(LIB_X11)'
       fi
    else
       if test "$ac_cv_have_gl" = "mesa"; then
          GLLIB="$GL_LDFLAGS -lMesaGLU -lMesaGL "'$(LIB_X11)'
       else
          GLLIB="$GL_LDFLAGS -lGLU -lGL "'$(LIB_X11)'
       fi
    fi
    if test "$GL_INCLUDE" = ""; then
       GLINC=""
    else
       GLINC="-I$GL_INCLUDE"
    fi
    AC_MSG_RESULT($ac_cv_have_gl)
    $1
  fi
 fi
 AC_SUBST(GLINC)
 AC_SUBST(GLLIB)
])


 dnl shadow password and PAM magic - maintained by ossi@kde.org

AC_DEFUN([KDE_PAM], [
  AC_REQUIRE([KDE_CHECK_LIBDL])

  want_pam=
  AC_ARG_WITH(pam,
    AC_HELP_STRING([--with-pam[=ARG]],[enable support for PAM: ARG=[yes|no|service name]]),
    [ if test "x$withval" = "xyes"; then
        want_pam=yes
        pam_service=kde
      elif test "x$withval" = "xno"; then
        want_pam=no
      else
        want_pam=yes
        pam_service=$withval
      fi
    ], [ pam_service=kde ])

  use_pam=
  PAMLIBS=
  if test "x$want_pam" != xno; then
    AC_CHECK_LIB(pam, pam_start, [
      AC_CHECK_HEADER(security/pam_appl.h,
        [ pam_header=security/pam_appl.h ],
        [ AC_CHECK_HEADER(pam/pam_appl.h,
            [ pam_header=pam/pam_appl.h ],
            [
    AC_MSG_WARN([PAM detected, but no headers found!
Make sure you have the necessary development packages installed.])
            ]
          )
        ]
      )
    ], , $LIBDL)
    if test -z "$pam_header"; then
      if test "x$want_pam" = xyes; then
        AC_MSG_ERROR([--with-pam was specified, but cannot compile with PAM!])
      fi
    else
      AC_DEFINE(HAVE_PAM, 1, [Defines if you have PAM (Pluggable Authentication Modules)])
      PAMLIBS="$PAM_MISC_LIB -lpam $LIBDL"
      use_pam=yes

      dnl darwin claims to be something special
      if test "$pam_header" = "pam/pam_appl.h"; then
        AC_DEFINE(HAVE_PAM_PAM_APPL_H, 1, [Define if your PAM headers are in pam/ instead of security/])
      fi

      dnl test whether struct pam_message is const (Linux) or not (Sun)
      AC_MSG_CHECKING(for const pam_message)
      AC_EGREP_HEADER([struct pam_message], $pam_header,
        [ AC_EGREP_HEADER([const struct pam_message], $pam_header,
                          [AC_MSG_RESULT([const: Linux-type PAM])],
                          [AC_MSG_RESULT([nonconst: Sun-type PAM])
                          AC_DEFINE(PAM_MESSAGE_NONCONST, 1, [Define if your PAM support takes non-const arguments (Solaris)])]
                          )],
        [AC_MSG_RESULT([not found - assume const, Linux-type PAM])])
    fi
  fi

  AC_SUBST(PAMLIBS)
])

dnl DEF_PAM_SERVICE(arg name, full name, define name)
AC_DEFUN([DEF_PAM_SERVICE], [
  AC_ARG_WITH($1-pam,
    AC_HELP_STRING([--with-$1-pam=[val]],[override PAM service from --with-pam for $2]),
    [ if test "x$use_pam" = xyes; then
        $3_PAM_SERVICE=$withval
      else
        AC_MSG_ERROR([Cannot use use --with-$1-pam, as no PAM was detected.
You may want to enforce it by using --with-pam.])
      fi
    ], 
    [ if test "x$use_pam" = xyes; then
        $3_PAM_SERVICE="$pam_service"
      fi
    ])
    if test -n "$$3_PAM_SERVICE"; then
      AC_MSG_RESULT([The PAM service used by $2 will be $$3_PAM_SERVICE])
      AC_DEFINE_UNQUOTED($3_PAM_SERVICE, "$$3_PAM_SERVICE", [The PAM service to be used by $2])
    fi
    AC_SUBST($3_PAM_SERVICE)
])

AC_DEFUN([KDE_SHADOWPASSWD], [
  AC_REQUIRE([KDE_PAM])

  AC_CHECK_LIB(shadow, getspent,
    [ LIBSHADOW="-lshadow"
      ac_use_shadow=yes
    ],
    [ dnl for UnixWare
      AC_CHECK_LIB(gen, getspent, 
        [ LIBGEN="-lgen"
          ac_use_shadow=yes
        ], 
        [ AC_CHECK_FUNC(getspent, 
            [ ac_use_shadow=yes ],
            [ ac_use_shadow=no ])
	])
    ])
  AC_SUBST(LIBSHADOW)
  AC_SUBST(LIBGEN)
  
  AC_MSG_CHECKING([for shadow passwords])

  AC_ARG_WITH(shadow,
    AC_HELP_STRING([--with-shadow],[If you want shadow password support]),
    [ if test "x$withval" != "xno"; then
        use_shadow=yes
      else
        use_shadow=no
      fi
    ], [
      use_shadow="$ac_use_shadow"
    ])

  if test "x$use_shadow" = xyes; then
    AC_MSG_RESULT(yes)
    AC_DEFINE(HAVE_SHADOW, 1, [Define if you use shadow passwords])
  else
    AC_MSG_RESULT(no)
    LIBSHADOW=
    LIBGEN=
  fi

  dnl finally make the relevant binaries setuid root, if we have shadow passwds.
  dnl this still applies, if we could use it indirectly through pam.
  if test "x$use_shadow" = xyes || 
     ( test "x$use_pam" = xyes && test "x$ac_use_shadow" = xyes ); then
      case $host in
      *-*-freebsd* | *-*-netbsd* | *-*-openbsd*)
	SETUIDFLAGS="-m 4755 -o root";;
      *)
	SETUIDFLAGS="-m 4755";;
      esac
  fi
  AC_SUBST(SETUIDFLAGS)

])

AC_DEFUN([KDE_PASSWDLIBS], [
  AC_REQUIRE([KDE_MISC_TESTS]) dnl for LIBCRYPT
  AC_REQUIRE([KDE_PAM])
  AC_REQUIRE([KDE_SHADOWPASSWD])

  if test "x$use_pam" = "xyes"; then 
    PASSWDLIBS="$PAMLIBS"
  else
    PASSWDLIBS="$LIBCRYPT $LIBSHADOW $LIBGEN"
  fi

  dnl FreeBSD uses a shadow-like setup, where /etc/passwd holds the users, but
  dnl /etc/master.passwd holds the actual passwords.  /etc/master.passwd requires
  dnl root to read, so kcheckpass needs to be root (even when using pam, since pam
  dnl may need to read /etc/master.passwd).
  case $host in
  *-*-freebsd*)
    SETUIDFLAGS="-m 4755 -o root"
    ;;
  *)
    ;;
  esac

  AC_SUBST(PASSWDLIBS)
])

AC_DEFUN([KDE_CHECK_LIBDL],
[
AC_CHECK_LIB(dl, dlopen, [
LIBDL="-ldl"
ac_cv_have_dlfcn=yes
])

AC_CHECK_LIB(dld, shl_unload, [
LIBDL="-ldld"
ac_cv_have_shload=yes
])

AC_SUBST(LIBDL)
])

AC_DEFUN([KDE_CHECK_DLOPEN],
[
KDE_CHECK_LIBDL
AC_CHECK_HEADERS(dlfcn.h dl.h)
if test "$ac_cv_header_dlfcn_h" = "no"; then
  ac_cv_have_dlfcn=no
fi

if test "$ac_cv_header_dl_h" = "no"; then
  ac_cv_have_shload=no
fi

dnl XXX why change enable_dlopen? its already set by autoconf's AC_ARG_ENABLE
dnl (MM)
AC_ARG_ENABLE(dlopen,
AC_HELP_STRING([--disable-dlopen],[link statically [default=no]]),
enable_dlopen=$enableval,
enable_dlopen=yes)

# override the user's opinion, if we know it better ;)
if test "$ac_cv_have_dlfcn" = "no" && test "$ac_cv_have_shload" = "no"; then
  enable_dlopen=no
fi

if test "$ac_cv_have_dlfcn" = "yes"; then
  AC_DEFINE_UNQUOTED(HAVE_DLFCN, 1, [Define if you have dlfcn])
fi

if test "$ac_cv_have_shload" = "yes"; then
  AC_DEFINE_UNQUOTED(HAVE_SHLOAD, 1, [Define if you have shload])
fi

if test "$enable_dlopen" = no ; then
  test -n "$1" && eval $1
else
  test -n "$2" && eval $2
fi

])

AC_DEFUN([KDE_CHECK_DYNAMIC_LOADING],
[
KDE_CHECK_DLOPEN(libtool_enable_shared=yes, libtool_enable_static=no)
KDE_PROG_LIBTOOL
AC_MSG_CHECKING([dynamic loading])
eval "`egrep '^build_libtool_libs=' libtool`"
if test "$build_libtool_libs" = "yes" && test "$enable_dlopen" = "yes"; then
  dynamic_loading=yes
  AC_DEFINE_UNQUOTED(HAVE_DYNAMIC_LOADING)
else
  dynamic_loading=no
fi
AC_MSG_RESULT($dynamic_loading)
if test "$dynamic_loading" = "yes"; then
  $1
else
  $2
fi
])

AC_DEFUN([KDE_ADD_INCLUDES],
[
if test -z "$1"; then
  test_include="Pix.h"
else
  test_include="$1"
fi

AC_MSG_CHECKING([for libg++ ($test_include)])

AC_CACHE_VAL(kde_cv_libgpp_includes,
[
kde_cv_libgpp_includes=no

   for ac_dir in               \
                               \
     /usr/include/g++          \
     /usr/include              \
     /usr/unsupported/include  \
     /opt/include              \
     $extra_include            \
     ; \
   do
     if test -r "$ac_dir/$test_include"; then
       kde_cv_libgpp_includes=$ac_dir
       break
     fi
   done
])

AC_MSG_RESULT($kde_cv_libgpp_includes)
if test "$kde_cv_libgpp_includes" != "no"; then
  all_includes="-I$kde_cv_libgpp_includes $all_includes $USER_INCLUDES"
fi
])
])

AC_DEFUN([KDE_CHECK_LIBPTHREAD],
[
  dnl This code is here specifically to handle the
  dnl various flavors of threading library on FreeBSD
  dnl 4-, 5-, and 6-, and the (weird) rules around it.
  dnl There may be an environment PTHREAD_LIBS that 
  dnl specifies what to use; otherwise, search for it.
  dnl -pthread is special cased and unsets LIBPTHREAD
  dnl below if found.
  LIBPTHREAD=""

  if test -n "$PTHREAD_LIBS"; then
    if test "x$PTHREAD_LIBS" = "x-pthread" ; then
      LIBPTHREAD="PTHREAD"
    else
      PTHREAD_LIBS_save="$PTHREAD_LIBS"
      PTHREAD_LIBS=`echo "$PTHREAD_LIBS_save" | sed -e 's,^-l,,g'`
      AC_MSG_CHECKING([for pthread_create in $PTHREAD_LIBS])
      KDE_CHECK_LIB($PTHREAD_LIBS, pthread_create, [
          LIBPTHREAD="$PTHREAD_LIBS_save"])
      PTHREAD_LIBS="$PTHREAD_LIBS_save"
    fi
  fi

  dnl Is this test really needed, in the face of the Tru64 test below?
  if test -z "$LIBPTHREAD"; then
    AC_CHECK_LIB(pthread, pthread_create, [LIBPTHREAD="-lpthread"])
  fi

  dnl This is a special Tru64 check, see BR 76171 issue #18.
  if test -z "$LIBPTHREAD" ; then
    AC_MSG_CHECKING([for pthread_create in -lpthread])
    kde_safe_libs=$LIBS
    LIBS="$LIBS -lpthread"
    AC_TRY_LINK([#include <pthread.h>],[(void)pthread_create(0,0,0,0);],[
        AC_MSG_RESULT(yes)
        LIBPTHREAD="-lpthread"],[
	AC_MSG_RESULT(no)])
    LIBS=$kde_safe_libs
  fi

  dnl Un-special-case for FreeBSD.
  if test "x$LIBPTHREAD" = "xPTHREAD" ; then
    LIBPTHREAD=""
  fi

  AC_SUBST(LIBPTHREAD)
])

AC_DEFUN([KDE_CHECK_PTHREAD_OPTION],
[
      USE_THREADS=""
      if test -z "$LIBPTHREAD"; then
        KDE_CHECK_COMPILER_FLAG(pthread, [USE_THREADS="-D_THREAD_SAFE -pthread"])
      fi

    AH_VERBATIM(__svr_define, [
#if defined(__SVR4) && !defined(__svr4__)
#define __svr4__ 1
#endif
])
    case $host_os in
 	solaris*)
		KDE_CHECK_COMPILER_FLAG(mt, [USE_THREADS="-mt"])
                CPPFLAGS="$CPPFLAGS -D_REENTRANT -D_POSIX_PTHREAD_SEMANTICS -DUSE_SOLARIS -DSVR4"
    		;;
        freebsd*)
                CPPFLAGS="$CPPFLAGS -D_THREAD_SAFE $PTHREAD_CFLAGS"
                ;;
        aix*)
                CPPFLAGS="$CPPFLAGS -D_THREAD_SAFE"
                LIBPTHREAD="$LIBPTHREAD -lc_r"
                ;;
        linux*) CPPFLAGS="$CPPFLAGS -D_REENTRANT"
                if test "$CXX" = "KCC"; then
                  CXXFLAGS="$CXXFLAGS --thread_safe"
		  NOOPT_CXXFLAGS="$NOOPT_CXXFLAGS --thread_safe"
                fi
                ;;
	*)
		;;
    esac
    AC_SUBST(USE_THREADS)
    AC_SUBST(LIBPTHREAD)
])

AC_DEFUN([KDE_CHECK_THREADING],
[
  AC_REQUIRE([KDE_CHECK_LIBPTHREAD])
  AC_REQUIRE([KDE_CHECK_PTHREAD_OPTION])
  dnl default is yes if libpthread is found and no if no libpthread is available
  if test -z "$LIBPTHREAD"; then
    if test -z "$USE_THREADS"; then
      kde_check_threading_default=no
    else
      kde_check_threading_default=yes
    fi
  else
    kde_check_threading_default=yes
  fi
  AC_ARG_ENABLE(threading,AC_HELP_STRING([--disable-threading],[disables threading even if libpthread found]),
   kde_use_threading=$enableval, kde_use_threading=$kde_check_threading_default)
  if test "x$kde_use_threading" = "xyes"; then
    AC_DEFINE(HAVE_LIBPTHREAD, 1, [Define if you have a working libpthread (will enable threaded code)])
  fi
])

AC_DEFUN([KDE_TRY_LINK_PYTHON],
[
if test "$kde_python_link_found" = no; then

if test "$1" = normal; then
  AC_MSG_CHECKING(if a Python application links)
else
  AC_MSG_CHECKING(if Python depends on $2)
fi

AC_CACHE_VAL(kde_cv_try_link_python_$1,
[
kde_save_cflags="$CFLAGS"
CFLAGS="$CFLAGS $PYTHONINC"
kde_save_libs="$LIBS"
LIBS="$LIBS $LIBPYTHON $2 $LIBDL $LIBSOCKET"
kde_save_ldflags="$LDFLAGS"
LDFLAGS="$LDFLAGS $PYTHONLIB"

AC_TRY_LINK(
[
#include <Python.h>
],[
	PySys_SetArgv(1, 0);
],
	[kde_cv_try_link_python_$1=yes],
	[kde_cv_try_link_python_$1=no]
)
CFLAGS="$kde_save_cflags"
LIBS="$kde_save_libs"
LDFLAGS="$kde_save_ldflags"
])

if test "$kde_cv_try_link_python_$1" = "yes"; then
  AC_MSG_RESULT(yes)
  kde_python_link_found=yes
  if test ! "$1" = normal; then
    LIBPYTHON="$LIBPYTHON $2"
  fi
  $3
else
  AC_MSG_RESULT(no)
  $4
fi

fi

])

AC_DEFUN([KDE_CHECK_PYTHON_DIR],
[
AC_MSG_CHECKING([for Python directory])
 
AC_CACHE_VAL(kde_cv_pythondir,
[
  if test -z "$PYTHONDIR"; then
    kde_cv_pythondir=/usr/local
  else
    kde_cv_pythondir="$PYTHONDIR"
  fi
])
 
AC_ARG_WITH(pythondir,
AC_HELP_STRING([--with-pythondir=pythondir],[use python installed in pythondir]),
[
  ac_python_dir=$withval
], ac_python_dir=$kde_cv_pythondir
)
 
AC_MSG_RESULT($ac_python_dir)
])

AC_DEFUN([KDE_CHECK_PYTHON_INTERN],
[
AC_REQUIRE([KDE_CHECK_LIBDL])
AC_REQUIRE([KDE_CHECK_LIBPTHREAD])
AC_REQUIRE([KDE_CHECK_PYTHON_DIR])

if test -z "$1"; then
  version="1.5"
else
  version="$1"
fi

AC_MSG_CHECKING([for Python$version])

python_incdirs="$ac_python_dir/include /usr/include /usr/local/include/ $kde_extra_includes"
AC_FIND_FILE(Python.h, $python_incdirs, python_incdir)
if test ! -r $python_incdir/Python.h; then
  AC_FIND_FILE(python$version/Python.h, $python_incdirs, python_incdir)
  python_incdir=$python_incdir/python$version
  if test ! -r $python_incdir/Python.h; then
    python_incdir=no
  fi
fi

PYTHONINC=-I$python_incdir

python_libdirs="$ac_python_dir/lib$kdelibsuff /usr/lib$kdelibsuff /usr/local /usr/lib$kdelibsuff $kde_extra_libs"
AC_FIND_FILE(libpython$version.so, $python_libdirs, python_libdir)
if test ! -r $python_libdir/libpython$version.so; then
  AC_FIND_FILE(libpython$version.a, $python_libdirs, python_libdir)
  if test ! -r $python_libdir/libpython$version.a; then
    AC_FIND_FILE(python$version/config/libpython$version.a, $python_libdirs, python_libdir)
    python_libdir=$python_libdir/python$version/config
    if test ! -r $python_libdir/libpython$version.a; then
      python_libdir=no
    fi
  fi
fi

PYTHONLIB=-L$python_libdir
kde_orig_LIBPYTHON=$LIBPYTHON
if test -z "$LIBPYTHON"; then
  LIBPYTHON=-lpython$version
fi

AC_FIND_FILE(python$version/copy.py, $python_libdirs, python_moddir)
python_moddir=$python_moddir/python$version
if test ! -r $python_moddir/copy.py; then
  python_moddir=no
fi

PYTHONMODDIR=$python_moddir

AC_MSG_RESULT(header $python_incdir library $python_libdir modules $python_moddir)

if test x$python_incdir = xno ||  test x$python_libdir = xno ||  test x$python_moddir = xno; then
   LIBPYTHON=$kde_orig_LIBPYTHON
   test "x$PYTHONLIB" = "x-Lno" && PYTHONLIB=""
   test "x$PYTHONINC" = "x-Ino" && PYTHONINC=""
   $2
else 
  dnl Note: this test is very weak
  kde_python_link_found=no
  KDE_TRY_LINK_PYTHON(normal)
  KDE_TRY_LINK_PYTHON(m, -lm)
  KDE_TRY_LINK_PYTHON(pthread, $LIBPTHREAD)
  KDE_TRY_LINK_PYTHON(tcl, -ltcl)
  KDE_TRY_LINK_PYTHON(db2, -ldb2)
  KDE_TRY_LINK_PYTHON(m_and_thread, [$LIBPTHREAD -lm])
  KDE_TRY_LINK_PYTHON(m_and_thread_and_util, [$LIBPTHREAD -lm -lutil])
  KDE_TRY_LINK_PYTHON(m_and_thread_and_db3, [$LIBPTHREAD -lm -ldb-3 -lutil])
  KDE_TRY_LINK_PYTHON(pthread_and_db3, [$LIBPTHREAD -ldb-3])
  KDE_TRY_LINK_PYTHON(m_and_thread_and_db, [$LIBPTHREAD -lm -ldb -ltermcap -lutil])
  KDE_TRY_LINK_PYTHON(pthread_and_dl, [$LIBPTHREAD $LIBDL -lutil -lreadline -lncurses -lm])
  KDE_TRY_LINK_PYTHON(pthread_and_panel_curses, [$LIBPTHREAD $LIBDL -lm -lpanel -lcurses])
  KDE_TRY_LINK_PYTHON(m_and_thread_and_db_special, [$LIBPTHREAD -lm -ldb -lutil], [],
	[AC_MSG_WARN([it seems, Python depends on another library.
    Please set LIBPYTHON to '-lpython$version -lotherlib' before calling configure to fix this
    and contact the authors to let them know about this problem])
	])

  LIBPYTHON="$LIBPYTHON $LIBDL $LIBSOCKET"
  AC_SUBST(PYTHONINC)
  AC_SUBST(PYTHONLIB)
  AC_SUBST(LIBPYTHON)
  AC_SUBST(PYTHONMODDIR)
  AC_DEFINE(HAVE_PYTHON, 1, [Define if you have the development files for python])
fi

])


AC_DEFUN([KDE_CHECK_PYTHON],
[
  KDE_CHECK_PYTHON_INTERN("2.3", 
   [KDE_CHECK_PYTHON_INTERN("2.2", 
     [KDE_CHECK_PYTHON_INTERN("2.1", 
       [KDE_CHECK_PYTHON_INTERN("2.0", 
         [KDE_CHECK_PYTHON_INTERN($1, $2) ])
       ])
     ])
   ])
])

AC_DEFUN([KDE_CHECK_STL],
[
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
    ac_save_CXXFLAGS="$CXXFLAGS"
    CXXFLAGS="`echo $CXXFLAGS | sed s/-fno-exceptions//`"

    AC_MSG_CHECKING([if C++ programs can be compiled])
    AC_CACHE_VAL(kde_cv_stl_works,
    [
      AC_TRY_COMPILE([
#include <string>
using namespace std;
],[
  string astring="Hallo Welt.";
  astring.erase(0, 6); // now astring is "Welt"
  return 0;
], kde_cv_stl_works=yes,
   kde_cv_stl_works=no)
])

   AC_MSG_RESULT($kde_cv_stl_works)

   if test "$kde_cv_stl_works" = "yes"; then
     # back compatible
	 AC_DEFINE_UNQUOTED(HAVE_SGI_STL, 1, [Define if you have a STL implementation by SGI])
   else
	 AC_MSG_ERROR([Your Installation isn't able to compile simple C++ programs.
Check config.log for details - if you're using a Linux distribution you might miss
a package named similiar to libstd++-dev.])
   fi

   CXXFLAGS="$ac_save_CXXFLAGS"
   AC_LANG_RESTORE
])

AC_DEFUN([AC_FIND_QIMGIO],
   [AC_REQUIRE([AC_FIND_JPEG])
AC_REQUIRE([KDE_CHECK_EXTRA_LIBS])
AC_MSG_CHECKING([for qimgio])
AC_CACHE_VAL(ac_cv_lib_qimgio,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
ac_save_LIBS="$LIBS"
ac_save_CXXFLAGS="$CXXFLAGS"
LIBS="$all_libraries -lqimgio -lpng -lz $LIBJPEG $LIBQT"
CXXFLAGS="$CXXFLAGS -I$qt_incdir $all_includes"
AC_TRY_RUN(dnl
[
#include <qimageio.h>
#include <qstring.h>
int main() {
		QString t = "hallo";
		t.fill('t');
		qInitImageIO();
}
],
            ac_cv_lib_qimgio=yes,
            ac_cv_lib_qimgio=no,
	    ac_cv_lib_qimgio=no)
LIBS="$ac_save_LIBS"
CXXFLAGS="$ac_save_CXXFLAGS"
AC_LANG_RESTORE
])dnl
if eval "test \"`echo $ac_cv_lib_qimgio`\" = yes"; then
  LIBQIMGIO="-lqimgio -lpng -lz $LIBJPEG"
  AC_MSG_RESULT(yes)
  AC_DEFINE_UNQUOTED(HAVE_QIMGIO, 1, [Define if you have the Qt extension qimgio available])
  AC_SUBST(LIBQIMGIO)
else
  AC_MSG_RESULT(not found)
fi
])

AC_DEFUN([AM_DISABLE_LIBRARIES],
[
    AC_PROVIDE([AM_ENABLE_STATIC])
    AC_PROVIDE([AM_ENABLE_SHARED])
    enable_static=no
    enable_shared=yes
])


AC_DEFUN([AC_CHECK_UTMP_FILE],
[
    AC_MSG_CHECKING([for utmp file])

    AC_CACHE_VAL(kde_cv_utmp_file,
    [
    kde_cv_utmp_file=no

    for ac_file in    \
                      \
	/var/run/utmp \
	/var/adm/utmp \
	/etc/utmp     \
     ; \
    do
     if test -r "$ac_file"; then
       kde_cv_utmp_file=$ac_file
       break
     fi
    done
    ])

    if test "$kde_cv_utmp_file" != "no"; then
	AC_DEFINE_UNQUOTED(UTMP, "$kde_cv_utmp_file", [Define the file for utmp entries])
	$1
	AC_MSG_RESULT($kde_cv_utmp_file)
    else
    	$2
	AC_MSG_RESULT([non found])
    fi
])


AC_DEFUN([KDE_CREATE_SUBDIRSLIST],
[

DO_NOT_COMPILE="$DO_NOT_COMPILE CVS debian bsd-port admin"

if test ! -s $srcdir/subdirs; then
  dnl Note: Makefile.common creates subdirs, so this is just a fallback
  TOPSUBDIRS=""
  files=`cd $srcdir && ls -1`
  dirs=`for i in $files; do if test -d $i; then echo $i; fi; done`
  for i in $dirs; do
    echo $i >> $srcdir/subdirs
  done
fi

ac_topsubdirs=
if test -s $srcdir/inst-apps; then
  ac_topsubdirs="`cat $srcdir/inst-apps`"
elif test -s $srcdir/subdirs; then
  ac_topsubdirs="`cat $srcdir/subdirs`"
fi

for i in $ac_topsubdirs; do
  AC_MSG_CHECKING([if $i should be compiled])
  if test -d $srcdir/$i; then
    install_it="yes"
    for j in $DO_NOT_COMPILE; do
      if test $i = $j; then
        install_it="no"
      fi
    done
  else
    install_it="no"
  fi
  AC_MSG_RESULT($install_it)
  vari=`echo $i | sed -e 's,[[-+.@]],_,g'`
  if test $install_it = "yes"; then
    TOPSUBDIRS="$TOPSUBDIRS $i"
    eval "$vari""_SUBDIR_included=yes"
  else
    eval "$vari""_SUBDIR_included=no"
  fi
done

AC_SUBST(TOPSUBDIRS)
])

AC_DEFUN([KDE_CHECK_NAMESPACES],
[
AC_MSG_CHECKING(whether C++ compiler supports namespaces)
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
AC_TRY_COMPILE([
],
[
namespace Foo {
  extern int i;
  namespace Bar {
    extern int i;
  }
}

int Foo::i = 0;
int Foo::Bar::i = 1;
],[
  AC_MSG_RESULT(yes)
  AC_DEFINE(HAVE_NAMESPACES)
], [
AC_MSG_RESULT(no)
])
AC_LANG_RESTORE
])

dnl ------------------------------------------------------------------------
dnl Check for S_ISSOCK macro. Doesn't exist on Unix SCO. faure@kde.org
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_CHECK_S_ISSOCK],
[
AC_MSG_CHECKING(for S_ISSOCK)
AC_CACHE_VAL(ac_cv_have_s_issock,
[
AC_TRY_LINK(
[
#include <sys/stat.h>
],
[
struct stat buff;
int b = S_ISSOCK( buff.st_mode );
],
ac_cv_have_s_issock=yes,
ac_cv_have_s_issock=no)
])
AC_MSG_RESULT($ac_cv_have_s_issock)
if test "$ac_cv_have_s_issock" = "yes"; then
  AC_DEFINE_UNQUOTED(HAVE_S_ISSOCK, 1, [Define if sys/stat.h declares S_ISSOCK.])
fi

AH_VERBATIM(_ISSOCK,
[
#ifndef HAVE_S_ISSOCK
#define HAVE_S_ISSOCK
#define S_ISSOCK(mode) (1==0)
#endif
])

])

dnl ------------------------------------------------------------------------
dnl Check for MAXPATHLEN macro, defines KDEMAXPATHLEN. faure@kde.org
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([AC_CHECK_KDEMAXPATHLEN],
[
AC_MSG_CHECKING(for MAXPATHLEN)
AC_CACHE_VAL(ac_cv_maxpathlen,
[
cat > conftest.$ac_ext <<EOF
#ifdef STDC_HEADERS
# include <stdlib.h>
#endif
#include <stdio.h>
#include <sys/param.h>
#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif

KDE_HELLO MAXPATHLEN

EOF

ac_try="$ac_cpp conftest.$ac_ext 2>/dev/null | grep '^KDE_HELLO' >conftest.out"

if AC_TRY_EVAL(ac_try) && test -s conftest.out; then
    ac_cv_maxpathlen=`sed 's#KDE_HELLO ##' conftest.out`
else
    ac_cv_maxpathlen=1024
fi

rm conftest.*

])
AC_MSG_RESULT($ac_cv_maxpathlen)
AC_DEFINE_UNQUOTED(KDEMAXPATHLEN,$ac_cv_maxpathlen, [Define a safe value for MAXPATHLEN] )
])

AC_DEFUN([KDE_CHECK_HEADER],
[
   AC_LANG_SAVE
   kde_safe_cppflags=$CPPFLAGS
   CPPFLAGS="$CPPFLAGS $all_includes"
   AC_LANG_CPLUSPLUS
   AC_CHECK_HEADER([$1], [$2], [$3], [$4])
   CPPFLAGS=$kde_safe_cppflags
   AC_LANG_RESTORE
])

AC_DEFUN([KDE_CHECK_HEADERS],
[
   AH_CHECK_HEADERS([$1])
   AC_LANG_SAVE
   kde_safe_cppflags=$CPPFLAGS
   CPPFLAGS="$CPPFLAGS $all_includes"
   AC_LANG_CPLUSPLUS
   AC_CHECK_HEADERS([$1], [$2], [$3], [$4])
   CPPFLAGS=$kde_safe_cppflags
   AC_LANG_RESTORE
])

AC_DEFUN([KDE_FAST_CONFIGURE],
[
  dnl makes configure fast (needs perl)
  AC_ARG_ENABLE(fast-perl, AC_HELP_STRING([--disable-fast-perl],[disable fast Makefile generation (needs perl)]),
      with_fast_perl=$enableval, with_fast_perl=yes)
])

AC_DEFUN([KDE_CONF_FILES],
[
  val=
  if test -f $srcdir/configure.files ; then
    val=`sed -e 's%^%\$(top_srcdir)/%' $srcdir/configure.files`
  fi
  CONF_FILES=
  if test -n "$val" ; then
    for i in $val ; do
      CONF_FILES="$CONF_FILES $i"
    done
  fi
  AC_SUBST(CONF_FILES)
])dnl

dnl This sets the prefix, for arts and kdelibs
dnl Do NOT use in any other module.
dnl It only looks at --prefix, KDEDIR and falls back to /usr/local/kde
AC_DEFUN([KDE_SET_PREFIX_CORE],
[
  unset CDPATH
  dnl make $KDEDIR the default for the installation
  AC_PREFIX_DEFAULT(${KDEDIR:-/usr/local/kde})

  if test "x$prefix" = "xNONE"; then
    prefix=$ac_default_prefix
    ac_configure_args="$ac_configure_args --prefix=$prefix"
  fi
  # And delete superfluous '/' to make compares easier
  prefix=`echo "$prefix" | sed 's,//*,/,g' | sed -e 's,/$,,'`
  exec_prefix=`echo "$exec_prefix" | sed 's,//*,/,g' | sed -e 's,/$,,'`

  kde_libs_prefix='$(prefix)'
  kde_libs_htmldir='$(kde_htmldir)'
  AC_SUBST(kde_libs_prefix)
  AC_SUBST(kde_libs_htmldir)
  KDE_FAST_CONFIGURE
  KDE_CONF_FILES
])


AC_DEFUN([KDE_SET_PREFIX],
[
  unset CDPATH
  dnl We can't give real code to that macro, only a value.
  dnl It only matters for --help, since we set the prefix in this function anyway.
  AC_PREFIX_DEFAULT(${KDEDIR:-the kde prefix})

  KDE_SET_DEFAULT_BINDIRS
  if test "x$prefix" = "xNONE"; then
    dnl no prefix given: look for kde-config in the PATH and deduce the prefix from it
    KDE_FIND_PATH(kde-config, KDECONFIG, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(kde-config)], [], prepend)
  else
    dnl prefix given: look for kde-config, preferrably in prefix, otherwise in PATH
    kde_save_PATH="$PATH"
    PATH="$exec_prefix/bin:$prefix/bin:$PATH"
    KDE_FIND_PATH(kde-config, KDECONFIG, [$kde_default_bindirs], [KDE_MISSING_PROG_ERROR(kde-config)], [], prepend)
    PATH="$kde_save_PATH"
  fi

  kde_libs_prefix=`$KDECONFIG --prefix`
  if test -z "$kde_libs_prefix" || test ! -x "$kde_libs_prefix"; then
       AC_MSG_ERROR([$KDECONFIG --prefix outputed the non existant prefix '$kde_libs_prefix' for kdelibs.
                    This means it has been moved since you installed it.
                    This won't work. Please recompile kdelibs for the new prefix.
                    ])
  fi
  kde_libs_htmldir=`$KDECONFIG --install html --expandvars`

  AC_MSG_CHECKING([where to install])
  if test "x$prefix" = "xNONE"; then
    prefix=$kde_libs_prefix
    AC_MSG_RESULT([$prefix (as returned by kde-config)])
  else
    dnl --prefix was given. Compare prefixes and warn (in configure.in.bot.end) if different
    given_prefix=$prefix
    AC_MSG_RESULT([$prefix (as requested)])
  fi

  # And delete superfluous '/' to make compares easier
  prefix=`echo "$prefix" | sed 's,//*,/,g' | sed -e 's,/$,,'`
  exec_prefix=`echo "$exec_prefix" | sed 's,//*,/,g' | sed -e 's,/$,,'`
  given_prefix=`echo "$given_prefix" | sed 's,//*,/,g' | sed -e 's,/$,,'`

  AC_SUBST(KDECONFIG)
  AC_SUBST(kde_libs_prefix)
  AC_SUBST(kde_libs_htmldir)

  KDE_FAST_CONFIGURE
  KDE_CONF_FILES
])

pushdef([AC_PROG_INSTALL],
[
  dnl our own version, testing for a -p flag
  popdef([AC_PROG_INSTALL])
  dnl as AC_PROG_INSTALL works as it works we first have
  dnl to save if the user didn't specify INSTALL, as the
  dnl autoconf one overwrites INSTALL and we have no chance to find
  dnl out afterwards
  test -n "$INSTALL" && kde_save_INSTALL_given=$INSTALL
  test -n "$INSTALL_PROGRAM" && kde_save_INSTALL_PROGRAM_given=$INSTALL_PROGRAM
  test -n "$INSTALL_SCRIPT" && kde_save_INSTALL_SCRIPT_given=$INSTALL_SCRIPT
  AC_PROG_INSTALL

  if test -z "$kde_save_INSTALL_given" ; then
    # OK, user hasn't given any INSTALL, autoconf found one for us
    # now we test, if it supports the -p flag
    AC_MSG_CHECKING(for -p flag to install)
    rm -f confinst.$$.* > /dev/null 2>&1
    echo "Testtest" > confinst.$$.orig
    ac_res=no
    if ${INSTALL} -p confinst.$$.orig confinst.$$.new > /dev/null 2>&1 ; then
      if test -f confinst.$$.new ; then
        # OK, -p seems to do no harm to install
	INSTALL="${INSTALL} -p"
	ac_res=yes
      fi
    fi
    rm -f confinst.$$.*
    AC_MSG_RESULT($ac_res)
  fi
  dnl the following tries to resolve some signs and wonders coming up
  dnl with different autoconf/automake versions
  dnl e.g.:
  dnl  *automake 1.4 install-strip sets A_M_INSTALL_PROGRAM_FLAGS to -s
  dnl   and has INSTALL_PROGRAM = @INSTALL_PROGRAM@ $(A_M_INSTALL_PROGRAM_FLAGS)
  dnl   it header-vars.am, so there the actual INSTALL_PROGRAM gets the -s
  dnl  *automake 1.4a (and above) use INSTALL_STRIP_FLAG and only has
  dnl   INSTALL_PROGRAM = @INSTALL_PROGRAM@ there, but changes the
  dnl   install-@DIR@PROGRAMS targets to explicitly use that flag
  dnl  *autoconf 2.13 is dumb, and thinks it can use INSTALL_PROGRAM as
  dnl   INSTALL_SCRIPT, which breaks with automake <= 1.4
  dnl  *autoconf >2.13 (since 10.Apr 1999) has not that failure
  dnl  *sometimes KDE does not use the install-@DIR@PROGRAM targets from
  dnl   automake (due to broken Makefile.am or whatever) to install programs,
  dnl   and so does not see the -s flag in automake > 1.4
  dnl to clean up that mess we:
  dnl  +set INSTALL_PROGRAM to use INSTALL_STRIP_FLAG
  dnl   which cleans KDE's program with automake > 1.4;
  dnl  +set INSTALL_SCRIPT to only use INSTALL, to clean up autoconf's problems
  dnl   with automake<=1.4
  dnl  note that dues to this sometimes two '-s' flags are used (if KDE
  dnl   properly uses install-@DIR@PROGRAMS, but I don't care
  dnl
  dnl And to all this comes, that I even can't write in comments variable
  dnl  names used by automake, because it is so stupid to think I wanted to
  dnl  _use_ them, therefor I have written A_M_... instead of AM_
  dnl hmm, I wanted to say something ... ahh yes: Arghhh.

  if test -z "$kde_save_INSTALL_PROGRAM_given" ; then
    INSTALL_PROGRAM='${INSTALL} $(INSTALL_STRIP_FLAG)'
  fi
  if test -z "$kde_save_INSTALL_SCRIPT_given" ; then
    INSTALL_SCRIPT='${INSTALL}'
  fi
])dnl

AC_DEFUN([KDE_LANG_CPLUSPLUS],
[AC_LANG_CPLUSPLUS
ac_link='rm -rf SunWS_cache; ${CXX-g++} -o conftest${ac_exeext} $CXXFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $LIBS 1>&AC_FD_CC'
pushdef([AC_LANG_CPLUSPLUS], [popdef([AC_LANG_CPLUSPLUS]) KDE_LANG_CPLUSPLUS])
])

pushdef([AC_LANG_CPLUSPLUS],
[popdef([AC_LANG_CPLUSPLUS])
KDE_LANG_CPLUSPLUS
])

AC_DEFUN([KDE_CHECK_LONG_LONG],
[
AC_MSG_CHECKING(for long long)
AC_CACHE_VAL(kde_cv_c_long_long,
[
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  AC_TRY_LINK([], [
  long long foo = 0;
  foo = foo+1;
  ],
  kde_cv_c_long_long=yes, kde_cv_c_long_long=no)
  AC_LANG_RESTORE
])
AC_MSG_RESULT($kde_cv_c_long_long)
if test "$kde_cv_c_long_long" = yes; then
   AC_DEFINE(HAVE_LONG_LONG, 1, [Define if you have long long as datatype])
fi
])

AC_DEFUN([KDE_CHECK_LIB],
[
     kde_save_LDFLAGS="$LDFLAGS"
     dnl AC_CHECK_LIB modifies LIBS, so save it here
     kde_save_LIBS="$LIBS"
     LDFLAGS="$LDFLAGS $all_libraries"
     case $host_os in
      aix*) LDFLAGS="-brtl $LDFLAGS"
	test "$GCC" = yes && LDFLAGS="-Wl,$LDFLAGS"
	;;
     esac
     AC_CHECK_LIB($1, $2, $3, $4, $5)
     LDFLAGS="$kde_save_LDFLAGS"
     LIBS="$kde_save_LIBS"
])

AC_DEFUN([KDE_JAVA_PREFIX],
[
	dir=`dirname "$1"`
	base=`basename "$1"`
	list=`ls -1 $dir 2> /dev/null`
	for entry in $list; do 
		if test -d $dir/$entry/bin; then
			case $entry in
			   $base)
				javadirs="$javadirs $dir/$entry/bin"
				;;
			esac
		elif test -d $dir/$entry/jre/bin; then
			case $entry in
			   $base)
				javadirs="$javadirs $dir/$entry/jre/bin"
				;;
			esac
		fi
	done
])

dnl KDE_CHEC_JAVA_DIR(onlyjre)
AC_DEFUN([KDE_CHECK_JAVA_DIR],
[

AC_ARG_WITH(java,
AC_HELP_STRING([--with-java=javadir],[use java installed in javadir, --without-java disables]),
[  ac_java_dir=$withval
], ac_java_dir=""
)

AC_MSG_CHECKING([for Java])

dnl at this point ac_java_dir is either a dir, 'no' to disable, or '' to say look in $PATH
if test "x$ac_java_dir" = "xno"; then
   kde_java_bindir=no
   kde_java_includedir=no
   kde_java_libjvmdir=no
   kde_java_libgcjdir=no
   kde_java_libhpidir=no
else
  if test "x$ac_java_dir" = "x"; then
     
     
      dnl No option set -> collect list of candidate paths
      if test -n "$JAVA_HOME"; then
        KDE_JAVA_PREFIX($JAVA_HOME)
      fi
      KDE_JAVA_PREFIX(/usr/j2se)
      KDE_JAVA_PREFIX(/usr/lib/j2se)
      KDE_JAVA_PREFIX(/usr/j*dk*)
      KDE_JAVA_PREFIX(/usr/lib/j*dk*)
      KDE_JAVA_PREFIX(/opt/j*sdk*)
      KDE_JAVA_PREFIX(/usr/lib/java*)
      KDE_JAVA_PREFIX(/usr/java*)
      KDE_JAVA_PREFIX(/usr/java/j*dk*)
      KDE_JAVA_PREFIX(/usr/java/j*re*)
      KDE_JAVA_PREFIX(/usr/lib/SunJava2*)
      KDE_JAVA_PREFIX(/usr/lib/SunJava*)
      KDE_JAVA_PREFIX(/usr/lib/IBMJava2*)
      KDE_JAVA_PREFIX(/usr/lib/IBMJava*)
      KDE_JAVA_PREFIX(/opt/java*)

      kde_cv_path="NONE"
      kde_save_IFS=$IFS
      IFS=':'
      for dir in $PATH; do
	  if test -d "$dir"; then
	      javadirs="$javadirs $dir"
	  fi
      done
      IFS=$kde_save_IFS
      jredirs=

      dnl Now javadirs contains a list of paths that exist, all ending with bin/
      for dir in $javadirs; do
          dnl Check for the java executable
	  if test -x "$dir/java"; then
	      dnl And also check for a libjvm.so somewhere under there
	      dnl Since we have to go to the parent dir, /usr/bin is excluded, /usr is too big.
              if test "$dir" != "/usr/bin"; then
                  libjvmdir=`find $dir/.. -name libjvm.so | sed 's,libjvm.so,,'|head -n 1`
		  if test ! -f $libjvmdir/libjvm.so; then continue; fi
		  jredirs="$jredirs $dir"
	      fi
	  fi
      done

      dnl Now jredirs contains a reduced list, of paths where both java and ../**/libjvm.so was found
      JAVAC=
      JAVA=
      kde_java_bindir=no
      for dir in $jredirs; do
	  JAVA="$dir/java"
	  kde_java_bindir=$dir
	  if test -x "$dir/javac"; then
		JAVAC="$dir/javac"
                break
	  fi
      done

      if test -n "$JAVAC"; then
          dnl this substitution might not work - well, we test for jni.h below
          kde_java_includedir=`echo $JAVAC | sed -e 's,bin/javac$,include/,'`
      else
          kde_java_includedir=no
      fi
  else
    dnl config option set
    kde_java_bindir=$ac_java_dir/bin
    if test -x $ac_java_dir/bin/java && test ! -x $ac_java_dir/bin/javac; then
	kde_java_includedir=no
    else
        kde_java_includedir=$ac_java_dir/include
    fi
  fi
fi

dnl At this point kde_java_bindir and kde_java_includedir are either set or "no"
if test "x$kde_java_bindir" != "xno"; then

  dnl Look for libjvm.so
  kde_java_libjvmdir=`find $kde_java_bindir/.. -name libjvm.so | sed 's,libjvm.so,,'|head -n 1`
  dnl Look for libgcj.so
  kde_java_libgcjdir=`find $kde_java_bindir/.. -name libgcj.so | sed 's,libgcj.so,,'|head -n 1`
  dnl Look for libhpi.so and avoid green threads
  kde_java_libhpidir=`find $kde_java_bindir/.. -name libhpi.so | grep -v green | sed 's,libhpi.so,,' | head -n 1`

  dnl Now check everything's fine under there
  dnl the include dir is our flag for having the JDK
  if test -d "$kde_java_includedir"; then
    if test ! -x "$kde_java_bindir/javac"; then
      AC_MSG_ERROR([javac not found under $kde_java_bindir - it seems you passed a wrong --with-java.])
    fi
    if test ! -x "$kde_java_bindir/javah"; then
      AC_MSG_ERROR([javah not found under $kde_java_bindir. javac was found though! Use --with-java or --without-java.])
    fi
    if test ! -x "$kde_java_bindir/jar"; then
      AC_MSG_ERROR([jar not found under $kde_java_bindir. javac was found though! Use --with-java or --without-java.])
    fi
    if test ! -r "$kde_java_includedir/jni.h"; then
      AC_MSG_ERROR([jni.h not found under $kde_java_includedir. Use --with-java or --without-java.])
    fi

    jni_includes="-I$kde_java_includedir"
    dnl Strange thing, jni.h requires jni_md.h which is under genunix here..
    dnl and under linux here.. 
    
    dnl not needed for gcj

    if test "x$kde_java_libgcjdir" = "x"; then 
      test -d "$kde_java_includedir/linux" && jni_includes="$jni_includes -I$kde_java_includedir/linux"
      test -d "$kde_java_includedir/solaris" && jni_includes="$jni_includes -I$kde_java_includedir/solaris"
      test -d "$kde_java_includedir/genunix" && jni_includes="$jni_includes -I$kde_java_includedir/genunix"
    fi

  else
    JAVAC=
    jni_includes=
  fi

  if test "x$kde_java_libgcjdir" = "x"; then 
     if test ! -r "$kde_java_libjvmdir/libjvm.so"; then
        AC_MSG_ERROR([libjvm.so not found under $kde_java_libjvmdir. Use --without-java.])
     fi 
  else
     if test ! -r "$kde_java_libgcjdir/libgcj.so"; then
        AC_MSG_ERROR([libgcj.so not found under $kde_java_libgcjdir. Use --without-java.])
     fi 
  fi

  if test ! -x "$kde_java_bindir/java"; then
      AC_MSG_ERROR([java not found under $kde_java_bindir. javac was found though! Use --with-java or --without-java.])
  fi

  dnl not needed for gcj compile

  if test "x$kde_java_libgcjdir" = "x"; then 
      if test ! -r "$kde_java_libhpidir/libhpi.so"; then
        AC_MSG_ERROR([libhpi.so not found under $kde_java_libhpidir. Use --without-java.])
      fi
  fi

  if test -n "$jni_includes"; then
    dnl Check for JNI version
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
    ac_cxxflags_safe="$CXXFLAGS"
    CXXFLAGS="$CXXFLAGS $all_includes $jni_includes"

    AC_TRY_COMPILE([
  #include <jni.h>
	      ],
	      [
  #ifndef JNI_VERSION_1_2
  Syntax Error
  #endif
	      ],[ kde_jni_works=yes ],
	      [ kde_jni_works=no ])

    if test $kde_jni_works = no; then
      AC_MSG_ERROR([Incorrect version of $kde_java_includedir/jni.h.
		    You need to have Java Development Kit (JDK) version 1.2. 

		    Use --with-java to specify another location.
		    Use --without-java to configure without java support.
		    Or download a newer JDK and try again. 
		    See e.g. http://java.sun.com/products/jdk/1.2 ])
    fi

    CXXFLAGS="$ac_cxxflags_safe"    
    AC_LANG_RESTORE

    dnl All tests ok, inform and subst the variables

    JAVAC=$kde_java_bindir/javac
    JAVAH=$kde_java_bindir/javah
    JAR=$kde_java_bindir/jar
    AC_DEFINE_UNQUOTED(PATH_JAVA, "$kde_java_bindir/java", [Define where your java executable is])
    if test "x$kde_java_libgcjdir" = "x"; then 
      JVMLIBS="-L$kde_java_libjvmdir -ljvm -L$kde_java_libhpidir -lhpi"
    else
      JVMLIBS="-L$kde_java_libgcjdir -lgcj"
    fi
    AC_MSG_RESULT([java JDK in $kde_java_bindir])

  else
      AC_DEFINE_UNQUOTED(PATH_JAVA, "$kde_java_bindir/java", [Define where your java executable is])
      AC_MSG_RESULT([java JRE in $kde_java_bindir])
  fi
elif test -d "/Library/Java/Home"; then
  kde_java_bindir="/Library/Java/Home/bin"
  jni_includes="-I/Library/Java/Home/include"

  JAVAC=$kde_java_bindir/javac
  JAVAH=$kde_java_bindir/javah
  JAR=$kde_java_bindir/jar
  JVMLIBS="-Xlinker -framework -Xlinker JavaVM"

  AC_DEFINE_UNQUOTED(PATH_JAVA, "$kde_java_bindir/java", [Define where your java executable is])
  AC_MSG_RESULT([Apple Java Framework])
else
  AC_MSG_RESULT([none found])
fi

AC_SUBST(JAVAC)
AC_SUBST(JAVAH)
AC_SUBST(JAR)
AC_SUBST(JVMLIBS)
AC_SUBST(jni_includes)

# for backward compat
kde_cv_java_includedir=$kde_java_includedir
kde_cv_java_bindir=$kde_java_bindir
])

dnl this is a redefinition of autoconf 2.5x's AC_FOREACH.
dnl When the argument list becomes big, as in KDE for AC_OUTPUT in
dnl big packages, m4_foreach is dog-slow.  So use our own version of
dnl it.  (matz@kde.org)
m4_define([mm_foreach],
[m4_pushdef([$1])_mm_foreach($@)m4_popdef([$1])])
m4_define([mm_car], [[$1]])
m4_define([mm_car2], [[$@]])
m4_define([_mm_foreach],
[m4_if(m4_quote($2), [], [],
       [m4_define([$1], mm_car($2))$3[]_mm_foreach([$1],
                                                   mm_car2(m4_shift($2)),
                                                   [$3])])])
m4_define([AC_FOREACH],
[mm_foreach([$1], m4_split(m4_normalize([$2])), [$3])])

AC_DEFUN([KDE_NEED_FLEX],
[
kde_libs_safe=$LIBS
LIBS="$LIBS $USER_LDFLAGS"
AM_PROG_LEX
LIBS=$kde_libs_safe
if test -z "$LEXLIB"; then
    AC_MSG_ERROR([You need to have flex installed.])
fi
AC_SUBST(LEXLIB)
])

AC_DEFUN([AC_PATH_QTOPIA],
[
  dnl TODO: use AC_CACHE_VAL

  if test -z "$1"; then
    qtopia_minver_maj=1
    qtopia_minver_min=5
    qtopia_minver_pat=0
  else
    qtopia_minver_maj=`echo "$1" | sed -e "s/^\(.*\)\..*\..*$/\1/"`
    qtopia_minver_min=`echo "$1" | sed -e "s/^.*\.\(.*\)\..*$/\1/"`
    qtopia_minver_pat=`echo "$1" | sed -e "s/^.*\..*\.\(.*\)$/\1/"`
  fi

  qtopia_minver="$qtopia_minver_maj$qtopia_minver_min$qtopia_minver_pat"
  qtopia_minverstr="$qtopia_minver_maj.$qtopia_minver_min.$qtopia_minver_pat"

  AC_REQUIRE([AC_PATH_QT])

  AC_MSG_CHECKING([for Qtopia])

  LIB_QTOPIA="-lqpe"
  AC_SUBST(LIB_QTOPIA)

  kde_qtopia_dirs="$QPEDIR /opt/Qtopia"

  ac_qtopia_incdir=NO

  AC_ARG_WITH(qtopia-dir,
              AC_HELP_STRING([--with-qtopia-dir=DIR],[where the root of Qtopia is installed]),
              [  ac_qtopia_incdir="$withval"/include] ) 
  
  qtopia_incdirs=""
  for dir in $kde_qtopia_dirs; do
    qtopia_incdirs="$qtopia_incdirs $dir/include"
  done

  if test ! "$ac_qtopia_incdir" = "NO"; then
    qtopia_incdirs="$ac_qtopia_incdir $qtopia_incdirs"
  fi

  qtopia_incdir=""
  AC_FIND_FILE(qpe/qpeapplication.h, $qtopia_incdirs, qtopia_incdir)
  ac_qtopia_incdir="$qtopia_incdir"

  if test -z "$qtopia_incdir"; then
    AC_MSG_ERROR([Cannot find Qtopia headers. Please check your installation.])
  fi

  qtopia_ver_maj=`cat $qtopia_incdir/qpe/version.h | sed -n -e 's,.*QPE_VERSION "\(.*\)\..*\..*".*,\1,p'`;
  qtopia_ver_min=`cat $qtopia_incdir/qpe/version.h | sed -n -e 's,.*QPE_VERSION ".*\.\(.*\)\..*".*,\1,p'`;
  qtopia_ver_pat=`cat $qtopia_incdir/qpe/version.h | sed -n -e 's,.*QPE_VERSION ".*\..*\.\(.*\)".*,\1,p'`;

  qtopia_ver="$qtopia_ver_maj$qtopia_ver_min$qtopia_ver_pat"
  qtopia_verstr="$qtopia_ver_maj.$qtopia_ver_min.$qtopia_ver_pat"
  if test "$qtopia_ver" -lt "$qtopia_minver"; then
    AC_MSG_ERROR([found Qtopia version $qtopia_verstr but version $qtopia_minverstr
is required.])
  fi

  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS

  ac_cxxflags_safe="$CXXFLAGS"
  ac_ldflags_safe="$LDFLAGS"
  ac_libs_safe="$LIBS"

  CXXFLAGS="$CXXFLAGS -I$qtopia_incdir $all_includes"
  LDFLAGS="$LDFLAGS $QT_LDFLAGS $all_libraries $USER_LDFLAGS $KDE_MT_LDFLAGS"
  LIBS="$LIBS $LIB_QTOPIA $LIBQT"

  cat > conftest.$ac_ext <<EOF
#include "confdefs.h"
#include <qpe/qpeapplication.h>
#include <qpe/version.h>

int main( int argc, char **argv )
{
    QPEApplication app( argc, argv );
    return 0;
}
EOF

  if AC_TRY_EVAL(ac_link) && test -s conftest; then
    rm -f conftest*
  else
    rm -f conftest*
    AC_MSG_ERROR([Cannot link small Qtopia Application. For more details look at
the end of config.log])
  fi

  CXXFLAGS="$ac_cxxflags_safe"
  LDFLAGS="$ac_ldflags_safe"
  LIBS="$ac_libs_safe"

  AC_LANG_RESTORE

  QTOPIA_INCLUDES="-I$qtopia_incdir"
  AC_SUBST(QTOPIA_INCLUDES)

  AC_MSG_RESULT([found version $qtopia_verstr with headers at $qtopia_incdir])
])


AC_DEFUN([KDE_INIT_DOXYGEN],
[
AC_MSG_CHECKING([for Qt docs])
kde_qtdir=
if test "${with_qt_dir+set}" = set; then
  kde_qtdir="$with_qt_dir"
fi

AC_FIND_FILE(qsql.html, [ $kde_qtdir/doc/html $QTDIR/doc/html /usr/share/doc/packages/qt3/html /usr/lib/qt/doc /usr/lib/qt3/doc /usr/lib/qt3/doc/html /usr/doc/qt3/html /usr/doc/qt3 /usr/share/doc/qt3-doc /usr/share/qt3/doc/html /usr/X11R6/share/doc/qt/html ], QTDOCDIR)
AC_MSG_RESULT($QTDOCDIR)

AC_SUBST(QTDOCDIR)

KDE_FIND_PATH(dot, DOT, [], [])
if test -n "$DOT"; then
  KDE_HAVE_DOT="YES"
else
  KDE_HAVE_DOT="NO"
fi
AC_SUBST(KDE_HAVE_DOT)
KDE_FIND_PATH(doxygen, DOXYGEN, [], [])
AC_SUBST(DOXYGEN)

DOXYGEN_PROJECT_NAME="$1"
DOXYGEN_PROJECT_NUMBER="$2"
AC_SUBST(DOXYGEN_PROJECT_NAME)
AC_SUBST(DOXYGEN_PROJECT_NUMBER)

KDE_HAS_DOXYGEN=no
if test -n "$DOXYGEN" && test -x "$DOXYGEN" && test -f $QTDOCDIR/qsql.html; then
  KDE_HAS_DOXYGEN=yes
fi
AC_SUBST(KDE_HAS_DOXYGEN)

])


AC_DEFUN([AC_FIND_BZIP2],
[
AC_MSG_CHECKING([for bzDecompress in libbz2])
AC_CACHE_VAL(ac_cv_lib_bzip2,
[
AC_LANG_SAVE
AC_LANG_CPLUSPLUS
kde_save_LIBS="$LIBS"
LIBS="$all_libraries $USER_LDFLAGS -lbz2 $LIBSOCKET"
kde_save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="$CXXFLAGS $all_includes $USER_INCLUDES"
AC_TRY_LINK(dnl
[
#define BZ_NO_STDIO
#include<bzlib.h>
],
            [ bz_stream s; (void) bzDecompress(&s); ],
            eval "ac_cv_lib_bzip2='-lbz2'",
            eval "ac_cv_lib_bzip2=no")
LIBS="$kde_save_LIBS"
CXXFLAGS="$kde_save_CXXFLAGS"
AC_LANG_RESTORE
])dnl
AC_MSG_RESULT($ac_cv_lib_bzip2)

if test ! "$ac_cv_lib_bzip2" = no; then
  BZIP2DIR=bzip2

  LIBBZ2="$ac_cv_lib_bzip2"
  AC_SUBST(LIBBZ2)

else

   cxx_shared_flag=
   ld_shared_flag=
   KDE_CHECK_COMPILER_FLAG(shared, [
	ld_shared_flag="-shared"
   ])
   KDE_CHECK_COMPILER_FLAG(fPIC, [
        cxx_shared_flag="-fPIC"
   ])

   AC_MSG_CHECKING([for BZ2_bzDecompress in (shared) libbz2])
   AC_CACHE_VAL(ac_cv_lib_bzip2_prefix,
   [
   AC_LANG_SAVE
   AC_LANG_CPLUSPLUS
   kde_save_LIBS="$LIBS"
   LIBS="$all_libraries $USER_LDFLAGS $ld_shared_flag -lbz2 $LIBSOCKET"
   kde_save_CXXFLAGS="$CXXFLAGS"
   CXXFLAGS="$CFLAGS $cxx_shared_flag $all_includes $USER_INCLUDES"

   AC_TRY_LINK(dnl
   [
   #define BZ_NO_STDIO
   #include<bzlib.h>
   ],
               [ bz_stream s; (void) BZ2_bzDecompress(&s); ],
               eval "ac_cv_lib_bzip2_prefix='-lbz2'",
               eval "ac_cv_lib_bzip2_prefix=no")
   LIBS="$kde_save_LIBS"
   CXXFLAGS="$kde_save_CXXFLAGS"
   AC_LANG_RESTORE
   ])dnl

   AC_MSG_RESULT($ac_cv_lib_bzip2_prefix)
   
   if test ! "$ac_cv_lib_bzip2_prefix" = no; then
     BZIP2DIR=bzip2
    
     LIBBZ2="$ac_cv_lib_bzip2_prefix"
     AC_SUBST(LIBBZ2)

     AC_DEFINE(NEED_BZ2_PREFIX, 1, [Define if the libbz2 functions need the BZ2_ prefix])
   dnl else, we just ignore this
   fi

fi
AM_CONDITIONAL(include_BZIP2, test -n "$BZIP2DIR")
])

dnl ------------------------------------------------------------------------
dnl Try to find the SSL headers and libraries.
dnl $(SSL_LDFLAGS) will be -Lsslliblocation (if needed)
dnl and $(SSL_INCLUDES) will be -Isslhdrlocation (if needed)
dnl ------------------------------------------------------------------------
dnl
AC_DEFUN([KDE_CHECK_SSL],
[
LIBSSL="-lssl -lcrypto"
AC_REQUIRE([KDE_CHECK_LIB64])

ac_ssl_includes=NO ac_ssl_libraries=NO
ssl_libraries=""
ssl_includes=""
AC_ARG_WITH(ssl-dir,
    AC_HELP_STRING([--with-ssl-dir=DIR],[where the root of OpenSSL is installed]),
    [  ac_ssl_includes="$withval"/include
       ac_ssl_libraries="$withval"/lib$kdelibsuff
    ])

want_ssl=yes
AC_ARG_WITH(ssl,
    AC_HELP_STRING([--without-ssl],[disable SSL checks]),
    [want_ssl=$withval])

if test $want_ssl = yes; then

AC_MSG_CHECKING(for OpenSSL)

AC_CACHE_VAL(ac_cv_have_ssl,
[#try to guess OpenSSL locations
  
  ssl_incdirs="/usr/include /usr/local/include /usr/ssl/include /usr/local/ssl/include $prefix/include $kde_extra_includes"
  ssl_incdirs="$ac_ssl_includes $ssl_incdirs"
  AC_FIND_FILE(openssl/ssl.h, $ssl_incdirs, ssl_incdir)
  ac_ssl_includes="$ssl_incdir"

  ssl_libdirs="/usr/lib$kdelibsuff /usr/local/lib$kdelibsuff /usr/ssl/lib$kdelibsuff /usr/local/ssl/lib$kdelibsuff $libdir $prefix/lib$kdelibsuff $exec_prefix/lib$kdelibsuff $kde_extra_libs"
  if test ! "$ac_ssl_libraries" = "NO"; then
    ssl_libdirs="$ac_ssl_libraries $ssl_libdirs"
  fi

  test=NONE
  ssl_libdir=NONE
  for dir in $ssl_libdirs; do
    try="ls -1 $dir/libssl*"
    if test=`eval $try 2> /dev/null`; then ssl_libdir=$dir; break; else echo "tried $dir" >&AC_FD_CC ; fi
  done

  ac_ssl_libraries="$ssl_libdir"

  ac_ldflags_safe="$LDFLAGS"
  ac_libs_safe="$LIBS"

  LDFLAGS="$LDFLAGS -L$ssl_libdir $all_libraries"
  LIBS="$LIBS $LIBSSL -lRSAglue -lrsaref"

  AC_TRY_LINK(,void RSAPrivateEncrypt(void);RSAPrivateEncrypt();,
  ac_ssl_rsaref="yes"
  ,
  ac_ssl_rsaref="no"
  )

  LDFLAGS="$ac_ldflags_safe"
  LIBS="$ac_libs_safe"

  if test "$ac_ssl_includes" = NO || test "$ac_ssl_libraries" = NO; then
    have_ssl=no
  else
    have_ssl=yes;
  fi

  ])

  eval "$ac_cv_have_ssl"

  AC_MSG_RESULT([libraries $ac_ssl_libraries, headers $ac_ssl_includes])

  AC_MSG_CHECKING([whether OpenSSL uses rsaref])
  AC_MSG_RESULT($ac_ssl_rsaref)

  AC_MSG_CHECKING([for easter eggs])
  AC_MSG_RESULT([none found])

else
  have_ssl=no
fi

if test "$have_ssl" = yes; then
  AC_MSG_CHECKING(for OpenSSL version)
  dnl Check for SSL version
  AC_CACHE_VAL(ac_cv_ssl_version,
  [

    cat >conftest.$ac_ext <<EOF
#include <openssl/opensslv.h>
#include <stdio.h>
    int main() {
 
#ifndef OPENSSL_VERSION_NUMBER
      printf("ssl_version=\\"error\\"\n");
#else
      if (OPENSSL_VERSION_NUMBER < 0x00906000)
        printf("ssl_version=\\"old\\"\n");
      else
        printf("ssl_version=\\"ok\\"\n");
#endif
     return (0);
    }
EOF

    ac_save_CPPFLAGS=$CPPFLAGS
    if test "$ac_ssl_includes" != "/usr/include"; then
        CPPFLAGS="$CPPFLAGS -I$ac_ssl_includes"
    fi

    if AC_TRY_EVAL(ac_link); then 

      if eval `./conftest 2>&5`; then
        if test $ssl_version = error; then
          AC_MSG_ERROR([$ssl_incdir/openssl/opensslv.h doesn't define OPENSSL_VERSION_NUMBER !])
        else
          if test $ssl_version = old; then
            AC_MSG_WARN([OpenSSL version too old. Upgrade to 0.9.6 at least, see http://www.openssl.org. SSL support disabled.])
            have_ssl=no
          fi
        fi
        ac_cv_ssl_version="ssl_version=$ssl_version"
      else
        AC_MSG_ERROR([Your system couldn't run a small SSL test program.
        Check config.log, and if you can't figure it out, send a mail to 
        David Faure <faure@kde.org>, attaching your config.log])
      fi

    else
      AC_MSG_ERROR([Your system couldn't link a small SSL test program.
      Check config.log, and if you can't figure it out, send a mail to 
      David Faure <faure@kde.org>, attaching your config.log])
    fi 
    CPPFLAGS=$ac_save_CPPFLAGS

  ])

  eval "$ac_cv_ssl_version"
  AC_MSG_RESULT($ssl_version)
fi

if test "$have_ssl" != yes; then
  LIBSSL="";
else
  AC_DEFINE(HAVE_SSL, 1, [If we are going to use OpenSSL])
  ac_cv_have_ssl="have_ssl=yes \
    ac_ssl_includes=$ac_ssl_includes ac_ssl_libraries=$ac_ssl_libraries ac_ssl_rsaref=$ac_ssl_rsaref"
  
  
  ssl_libraries="$ac_ssl_libraries"
  ssl_includes="$ac_ssl_includes"

  if test "$ac_ssl_rsaref" = yes; then
    LIBSSL="-lssl -lcrypto -lRSAglue -lrsaref" 
  fi

  if test $ssl_version = "old"; then
    AC_DEFINE(HAVE_OLD_SSL_API, 1, [Define if you have OpenSSL < 0.9.6])
  fi
fi

SSL_INCLUDES=

if test "$ssl_includes" = "/usr/include"; then
  if test -f /usr/kerberos/include/krb5.h; then
	SSL_INCLUDES="-I/usr/kerberos/include"
  fi
elif test  "$ssl_includes" != "/usr/local/include" && test -n "$ssl_includes"; then
  SSL_INCLUDES="-I$ssl_includes"
fi

if test "$ssl_libraries" = "/usr/lib" || test "$ssl_libraries" = "/usr/local/lib" || test -z "$ssl_libraries" || test "$ssl_libraries" = "NONE"; then
 SSL_LDFLAGS=""
else
 SSL_LDFLAGS="-L$ssl_libraries -R$ssl_libraries"
fi

AC_SUBST(SSL_INCLUDES)
AC_SUBST(SSL_LDFLAGS)
AC_SUBST(LIBSSL)
])

AC_DEFUN([KDE_CHECK_STRLCPY],
[
  AC_REQUIRE([AC_CHECK_STRLCAT])
  AC_REQUIRE([AC_CHECK_STRLCPY])
  AC_CHECK_SIZEOF(size_t)
  AC_CHECK_SIZEOF(unsigned long)

  AC_MSG_CHECKING([sizeof size_t == sizeof unsigned long])
  AC_TRY_COMPILE(,[
    #if SIZEOF_SIZE_T != SIZEOF_UNSIGNED_LONG
       choke me
    #endif
    ],AC_MSG_RESULT([yes]),[
      AC_MSG_RESULT(no)
      AC_MSG_ERROR([
       Apparently on your system our assumption sizeof size_t == sizeof unsigned long 
       does not apply. Please mail kde-devel@kde.org with a description of your system!
      ])
  ])
])

AC_DEFUN([KDE_CHECK_BINUTILS],
[
  AC_MSG_CHECKING([if ld supports unversioned version maps])

  kde_save_LDFLAGS="$LDFLAGS"
  LDFLAGS="$LDFLAGS -Wl,--version-script=conftest.map"
  echo "{ local: extern \"C++\" { foo }; };" > conftest.map
  AC_TRY_LINK([int foo;],
[
#ifdef __INTEL_COMPILER
icc apparently does not support libtools version-info and version-script
at the same time. Dunno where the bug is, but until somebody figured out,
better disable the optional version scripts.
#endif

  foo = 42;
], kde_supports_versionmaps=yes, kde_supports_versionmaps=no)
  LDFLAGS="$kde_save_LDFLAGS"
  rm -f conftest.map
  AM_CONDITIONAL(include_VERSION_SCRIPT, 
    [test "$kde_supports_versionmaps" = "yes" && test "$kde_use_debug_code" = "no"])

  AC_MSG_RESULT($kde_supports_versionmaps)
])

AC_DEFUN([AM_PROG_OBJC],[
AC_CHECK_PROGS(OBJC, gcc, gcc)
test -z "$OBJC" && AC_MSG_ERROR([no acceptable objective-c gcc found in \$PATH])
if test "x${OBJCFLAGS-unset}" = xunset; then
   OBJCFLAGS="-g -O2"
fi
AC_SUBST(OBJCFLAGS)
_AM_IF_OPTION([no-dependencies],, [_AM_DEPENDENCIES(OBJC)])
])

AC_DEFUN([KDE_CHECK_PERL],
[
	KDE_FIND_PATH(perl, PERL, [$bindir $exec_prefix/bin $prefix/bin], [
		    AC_MSG_ERROR([No Perl found in your $PATH.
We need perl to generate some code.])
	])
    AC_SUBST(PERL)
])

AC_DEFUN([KDE_CHECK_LARGEFILE],
[
AC_SYS_LARGEFILE
if test "$ac_cv_sys_file_offset_bits" != no; then
  CPPFLAGS="$CPPFLAGS -D_FILE_OFFSET_BITS=$ac_cv_sys_file_offset_bits"
fi

if test "x$ac_cv_sys_large_files" != "xno"; then
  CPPFLAGS="$CPPFLAGS -D_LARGE_FILES=1"
fi

])


dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl AM_FERRIS_PQXX([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libpqxx for installation. 
dnl ie. default is to REQUIRE pqxx MINIMUM-VERSION or stop running.
dnl
dnl LIBPQXX_CFLAGS and LIBPQXX_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_PQXX],
[dnl 
dnl
required_version=$1

have_libpqxx=no
package=libpqxx
version=$required_version

AC_ARG_ENABLE(pqxx,
  [AS_HELP_STRING([--enable-pqxx],
                  [enable pqxx support (default=auto)])],[],[enable_pqxx=check])

if test x$enable_pqxx != xno; then

	PKG_CHECK_MODULES(LIBPQXX, $package >= $version, [ 
	   have_libpqxx_pkgconfig=yes
	   have_libpqxx=yes 
	])


INCLUDES="$(cat <<-HEREDOC
	#include <stdlib.h>

	#include <pqxx/connection>
	#include <pqxx/tablewriter>
	#include <pqxx/transaction>
	#include <pqxx/nontransaction>
	#include <pqxx/tablereader>
	#include <pqxx/tablewriter>

	using namespace PGSTD;
	using namespace pqxx;

	#include <string>
	using namespace std;
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
	    string constring;
	    connection c( constring );
HEREDOC
)"

CXXFLAGS_cache=$CXXFLAGS
LDFLAGS_cache=$LDFLAGS
AC_LANG_CPLUSPLUS
have_package=no

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBPQXX_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBPQXX_CFLAGS $LIBPQXX_CXXFLAGS "
	LIBPQXX_LIBS=" $STLPORT_LIBS $LDFLAGS $LIBPQXX_LIBS "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBPQXX_CFLAGS], [$LIBPQXX_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBPQXX_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBPQXX_CFLAGS $LIBPQXX_CXXFLAGS -I/usr/include/pqxx "
	LIBPQXX_LIBS=" $STLPORT_LIBS $LDFLAGS $LIBPQXX_LIBS "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBPQXX_CFLAGS], [$LIBPQXX_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBPQXX_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBPQXX_CFLAGS $LIBPQXX_CXXFLAGS -I/usr/local/include/pqxx "
	LIBPQXX_LIBS=" $STLPORT_LIBS $LDFLAGS $LIBPQXX_LIBS -L/usr/local/lib "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBPQXX_CFLAGS], [$LIBPQXX_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

AC_LANG_C
LDFLAGS=$LDFLAGS_cache
CXXFLAGS=$CXXFLAGS_cache

fi

#####################################################


have_libpqxx=no;

if test x"$have_package" = xyes; then
	have_libpqxx=yes;
	AC_DEFINE( HAVE_LIBPQXX, 1, [Is libpqxx installed] )

	# success
	ifelse([$2], , :, [$2])

else
	if test x$have_libpqxx_pkgconfig = xyes; then
		echo "pkg-config could find your libpqxx but can't compile and link against it..." 
	fi

	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://pqxx.tk/"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	LIBPQXX_CFLAGS=" "
	LIBPQXX_LIBS=" "
fi

AM_CONDITIONAL(HAVE_LIBPQXX, test x"$have_libpqxx" = xyes)
AC_SUBST(LIBPQXX_CFLAGS)
AC_SUBST(LIBPQXX_LIBS)
])



dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl AM_FERRIS_KDE([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl a CONDITIONAL FERRIS_HAVE_KDE3 is defined and the shell var have_kde3 is either yes/no on exit
dnl
dnl KDE3_CFLAGS and KDE3_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_KDE],
[dnl 
dnl
required_version=$1
have_kde3=no


AC_ARG_ENABLE(kde-detection,
[--disable-kde-detection            Don't try to find KDE or QT],
[
  if test x$enableval = xyes; then
	attempt_to_find_kde=yes
  else
	attempt_to_find_kde=no
  fi
])




if test x"$attempt_to_find_kde" = xno; then
	FERRIS_HAVE_KDE3=no
	KDE3_CFLAGS=""
	KDE3_LIBS=""
    	AC_MSG_RESULT([compilation of Qt functions disabled])
else
  if test x"$have_tested_for_kde3" = x; then

	AC_LANG_CPLUSPLUS
	AC_ARG_WITH(qt, [  --with-qt               build with Qt utils. [autodetected]],,with_qt=yes)
	if test x$with_qt = xyes ; then

		gw_CHECK_QT
		QT_CFLAGS=" $QT_CXXFLAGS "
		QT_LIBS="   $QT_LDADD "
dnl 		QT_CFLAGS=" `pkg-config --cflags  qt3 ` "
dnl 		QT_LIBS="   `pkg-config --libs    qt3 ` "

		AC_DEFINE(QT_THREAD_SUPPORT)

dnl 		AC_PATH_KDE
dnl 		KDE3_CFLAGS=" $KDE_INCLUDES $QT_CFLAGS "
dnl 		KDE3_LIBS="   $KDE_LDFLAGS $QT_LIBS "

dnl 		AC_PATH_KDE
dnl 		KDE3_CFLAGS=" $KDE_INCLUDES $QT_CFLAGS "
dnl 		KDE3_LIBS=" $KDE_LDFLAGS $QT_LIBS "

		KDE3_INCLUDEDIR="`kde-config --prefix`/include/kde "
		KDE3_LIBDIR="`kde-config --prefix`/lib "
		AC_ARG_WITH(kde-includedir,
	        [  --with-kde-includedir=DIR          root directory containing KDE include files],
	        	[KDE3_INCLUDEDIR=" -I$withval "
		])
		AC_ARG_WITH(kde-libdir,
	        [  --with-kde-libdir=DIR          directory continaing KDE libs],
	        	[KDE3_LIBDIR=" -I$withval "
		])

		KDE3_CFLAGS=" $KDE3_CFLAGS -I$KDE3_INCLUDEDIR $QT_CFLAGS "
		KDE3_LIBS=" $KDE3_LIBS  -L$KDE3_LIBDIR     -lkio -lkdefx -lkdeui -lkdecore -ldl $QT_LIBS "

		CXXFLAGS_cache=$CXXFLAGS
		CXXFLAGS="$CXXFLAGS $KDE3_CFLAGS"
		LDFLAGS_cache=$LDFLAGS
		LDFLAGS="$LDFLAGS $KDE3_LIBS"

		echo "trying to link a KDE3 client..."

		AC_TRY_LINK([
		#include <iostream>
		#include <qapplication.h>
		#include <kmimetype.h>
		#include <kdebug.h>
		#include <kapplication.h>

		using namespace std;
        	],
		[
		KApplication a( false, false );
    
	 	KMimeType::Ptr type = KMimeType::findByURL("/tmp/a.out");
		if (type->name() == KMimeType::defaultMimeType())
	        	cerr << "Could not find out type" << endl;
		else
        		cerr << "Type: " << type->name() << endl;
		a.unlock();
		return 0;
		],
       		[have_kde3=yes], [have_kde3=no])

		LDFLAGS=$LDFLAGS_cache
		CXXFLAGS=$CXXFLAGS_cache

		if test x"$have_kde3" = xyes; then
			echo "Building kde support funtions"
			MIMETYPE_ENGINE_DESC="KDE 3"
			MIMETYPE_ENGINE_CHOSEN=yes
			FERRIS_HAVE_KDE3=yes
			AC_DEFINE(HAVE_KDE3)
			AC_DEFINE(FERRIS_HAVE_KDE3)
		else
			echo "Couldn't link sample KDE3 application, disabling KDE3 support"
			FERRIS_HAVE_KDE3=no
			KDE3_CFLAGS=""
			KDE3_LIBS=""
		fi
	else
		echo "with_qt was not set...with_qt:$with_qt"
		FERRIS_HAVE_KDE3=no
		KDE3_CFLAGS=""
		KDE3_LIBS=""
	    	AC_MSG_RESULT([compilation of Qt functions disabled])
	fi

	AC_LANG_C
	AC_SUBST(KDE3_CFLAGS)
	AC_SUBST(KDE3_LIBS)
  fi
fi

have_tested_for_kde3=yes

AM_CONDITIONAL(FERRIS_HAVE_KDE3, test x"$have_kde3" = xyes)
])


dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl ###############################################################################
dnl ###############################################################################
dnl ###############################################################################
dnl # Test for xmms remote API
dnl ###############################################################################
dnl
dnl AM_FERRIS_XMMS([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to say "xmms not detected..."
dnl LIBXMMS_CFLAGS and LIBXMMS_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_XMMS],
[dnl 
dnl
required_version=$1

have_libxmms=no
package=libxmms
version=$required_version

AC_ARG_ENABLE(xmms,
  [AS_HELP_STRING([--enable-xmms],
                  [enable xmms support (default=auto)])],[],[enable_xmms=check])

if test x$enable_xmms != xno; then

	AC_CHECK_PROG( have_xmms, xmms-config, yes, no )
fi


if test "$have_xmms" = yes; then
	have_libxmms=yes;
	LIBXMMS_LIBS="   `xmms-config --libs` "
	LIBXMMS_CFLAGS=" `xmms-config --cflags` "
	AC_DEFINE(HAVE_XMMS, 1, [have xmms installed])

	# success
	ifelse([$2], , :, [$2])

else
	ifelse([$3], , 
	[
	  	echo "xmms not found..."
	], 
	[$3])     
	LIBXMMS_CFLAGS=" "
	LIBXMMS_LIBS=" "
fi

AM_CONDITIONAL(HAVE_XMMS, test "$have_xmms" = yes)
AC_SUBST(LIBXMMS_LIBS)
AC_SUBST(LIBXMMS_CFLAGS)
])




dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl AM_FERRIS_FUSELAGE([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libfuselage for installation. 
dnl ie. default is to REQUIRE fuselage MINIMUM-VERSION or stop running.
dnl
dnl LIBFUSELAGE_CFLAGS and LIBFUSELAGE_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_FUSELAGE],
[dnl 
dnl
required_version=$1

have_libfuselage=no
package=libfuselage
version=$required_version

dnl AC_ARG_ENABLE(fuselage,
dnl   [AS_HELP_STRING([--enable-fuselage],
dnl                   [enable fuselage support (default=auto)])],[],[enable_fuselage=check])

if test x$enable_fuselage != xno; then

dnl 	PKG_CHECK_MODULES(LIBFUSELAGE, $package >= $version, [ 
dnl 	   have_libfuselage_pkgconfig=yes
dnl 	   have_libfuselage=yes 
dnl 	])


INCLUDES="$(cat <<-HEREDOC
	#include <string>
	using namespace std;
	#include <fuselagefs/fuselagefs.hh>
	using namespace Fuselage;
	using namespace Fuselage::Helpers;
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
	Delegatefs myfuse;
	struct poptOption* fuselage_optionsTable = myfuse.getPopTable();
HEREDOC
)"

CXXFLAGS_cache=$CXXFLAGS
LDFLAGS_cache=$LDFLAGS
AC_LANG_CPLUSPLUS
have_package=no

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBFUSELAGE_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBFUSELAGE_CFLAGS $LIBFUSELAGE_CXXFLAGS "
	LIBFUSELAGE_LIBS=" $STLPORT_LIBS $LDFLAGS -lfuselagefs "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBFUSELAGE_CFLAGS], [$LIBFUSELAGE_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBFUSELAGE_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBFUSELAGE_CFLAGS $LIBFUSELAGE_CXXFLAGS -I/usr/local/include "
	LIBFUSELAGE_LIBS=" $STLPORT_LIBS $LDFLAGS -L/usr/local/lib -lfuselagefs "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBFUSELAGE_CFLAGS], [$LIBFUSELAGE_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

AC_LANG_C
LDFLAGS=$LDFLAGS_cache
CXXFLAGS=$CXXFLAGS_cache

fi

#####################################################


have_libfuselage=no;

if test x"$have_package" = xyes; then
	have_libfuselage=yes;
	AC_DEFINE( HAVE_LIBFUSELAGE, 1, [Is libfuselage installed] )

	# success
	ifelse([$2], , :, [$2])

else
	if test x$have_libfuselage_pkgconfig = xyes; then
		echo "pkg-config could find your libfuselage but can't compile and link against it..." 
	fi

	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		echo "get it from the URL"
		echo "http://sourceforge.net/project/showfiles.php?group_id=16036"
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	LIBFUSELAGE_CFLAGS=" "
	LIBFUSELAGE_LIBS=" "
fi

AM_CONDITIONAL(HAVE_LIBFUSELAGE, test x"$have_libfuselage" = xyes)
AC_SUBST(LIBFUSELAGE_CFLAGS)
AC_SUBST(LIBFUSELAGE_LIBS)
])



dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl AM_FERRIS_POPT([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]]])
dnl
dnl The default ACTION-IF-NOT-FOUND is to AC_MSG_ERROR() with a description of where
dnl to locate libpopt for installation. 
dnl ie. default is to REQUIRE popt MINIMUM-VERSION or stop running.
dnl
dnl LIBPOPT_CFLAGS and LIBPOPT_LIBS are set and AC_SUBST()ed when library is found.
dnl
AC_DEFUN([AM_FERRIS_POPT],
[dnl 
dnl
required_version=$1

have_libpopt=no
package=libpopt
version=$required_version

dnl AC_ARG_ENABLE(popt,
dnl   [AS_HELP_STRING([--enable-popt],
dnl                   [enable popt support (default=auto)])],[],[enable_popt=check])

if test x$enable_popt != xno; then

dnl 	PKG_CHECK_MODULES(LIBPOPT, $package >= $version, [ 
dnl 	   have_libpopt_pkgconfig=yes
dnl 	   have_libpopt=yes 
dnl 	])


INCLUDES="$(cat <<-HEREDOC
	#include <popt.h>
HEREDOC
)"
PROGRAM="$(cat <<-HEREDOC
HEREDOC
)"

CXXFLAGS_cache=$CXXFLAGS
LDFLAGS_cache=$LDFLAGS
AC_LANG_CPLUSPLUS
have_package=no

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBPOPT_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBPOPT_CFLAGS $LIBPOPT_CXXFLAGS "
	LIBPOPT_LIBS=" $STLPORT_LIBS $LDFLAGS -lpopt "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBPOPT_CFLAGS], [$LIBPOPT_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBPOPT_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBPOPT_CFLAGS $LIBPOPT_CXXFLAGS -I/usr/local/include "
	LIBPOPT_LIBS=" $STLPORT_LIBS $LDFLAGS -L/usr/local/lib -lpopt "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBPOPT_CFLAGS], [$LIBPOPT_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

AC_LANG_C
LDFLAGS=$LDFLAGS_cache
CXXFLAGS=$CXXFLAGS_cache

fi

#####################################################


have_libpopt=no;

if test x"$have_package" = xyes; then
	have_libpopt=yes;
	AC_DEFINE( HAVE_LIBPOPT, 1, [Is libpopt installed] )

	# success
	ifelse([$2], , :, [$2])

else
	if test x$have_libpopt_pkgconfig = xyes; then
		echo "pkg-config could find your libpopt but can't compile and link against it..." 
	fi

	ifelse([$3], , 
	[
	  	echo ""
		echo "latest version of $package required. ($version or better) "
		echo ""
		AC_MSG_ERROR([Fatal Error: no correct $package found.])	
	], 
	[$3])     
	LIBPOPT_CFLAGS=" "
	LIBPOPT_LIBS=" "
fi

AM_CONDITIONAL(HAVE_LIBPOPT, test x"$have_libpopt" = xyes)
AC_SUBST(LIBPOPT_CFLAGS)
AC_SUBST(LIBPOPT_LIBS)
])




dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################


