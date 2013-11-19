

dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl
dnl
dnl AM_FERRIS_INTERNAL_TRYLINK( CFLAGS, LIBS, HEADERS, BODY, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
dnl Used internally to try to link to a library using C++ application
dnl using the CFLAGS and LIBS. 
dnl
AC_DEFUN([AM_FERRIS_INTERNAL_TRYLINK],
[dnl
dnl
	AC_LANG([C++])
	CPPFLAGS_cache=$CPPFLAGS
	CPPFLAGS=" $CPPFLAGS $1 "
	LIBS_cache=$LIBS
	LIBS=" $LIBS $2 "

	AC_LINK_IFELSE(
		[AC_LANG_PROGRAM([[$3]],
		[[$4]])],
	       	[trylink_passed=yes ],
	       	[trylink_passed=no] )

	LIBS=$LIBS_cache
	CPPFLAGS=$CPPFLAGS_cache
	AC_LANG([C])

	if test x"$trylink_passed" = xyes; then
	     ifelse([$5], , :, [$5])     
	else
	     ifelse([$6], , :, [$6])     
	fi
])



dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

dnl
dnl
dnl AM_FERRIS_INTERNAL_TRYRUN( CFLAGS, LIBS, HEADERS, BODY, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
dnl Used internally to try to link to a library using C++ application
dnl using the CFLAGS and LIBS. 
dnl
AC_DEFUN([AM_FERRIS_INTERNAL_TRYRUN],
[dnl
dnl
	AC_LANG([C++])
	CPPFLAGS_cache=$CPPFLAGS
	CPPFLAGS=" $CPPFLAGS $1 "
	LIBS_cache=$LIBS
	LIBS=" $LIBS $2 "

	AC_RUN_IFELSE(
		[AC_LANG_SOURCE([[
		$3
		int main( int argc, char** argv ) {
			$4
			return 0; }
		]])],
	       	[trylink_passed=yes ],
	       	[trylink_passed=no] )

	LIBS=$LIBS_cache
	CPPFLAGS=$CPPFLAGS_cache
	AC_LANG([C])

	if test x"$trylink_passed" = xyes; then
	     ifelse([$5], , :, [$5])     
	else
	     ifelse([$6], , :, [$6])     
	fi
])


dnl #####################################################################
dnl #####################################################################
dnl #####################################################################
dnl #####################################################################

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
LIBS_cache=$LIBS
AC_LANG([C++])
have_package=no

# try to hit it directly.
if test x"$have_package" = xno; then
	LIBFUSELAGE_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBFUSELAGE_CFLAGS $LIBFUSELAGE_CXXFLAGS "
	LIBFUSELAGE_LIBS=" $STLPORT_LIBS $LDFLAGS -lfuselagefs "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBFUSELAGE_CFLAGS], [$LIBFUSELAGE_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

# try /usr/local/lib
if test x"$have_package" = xno; then
	LIBFUSELAGE_CFLAGS=" $STLPORT_CFLAGS $CXXFLAGS $LIBFUSELAGE_CFLAGS $LIBFUSELAGE_CXXFLAGS -I/usr/local/include "
	LIBFUSELAGE_LIBS=" $STLPORT_LIBS $LDFLAGS -L/usr/local/lib -lfuselagefs "
	AM_FERRIS_INTERNAL_TRYLINK( [$LIBFUSELAGE_CFLAGS], [$LIBFUSELAGE_LIBS], 
				[ $INCLUDES ], [$PROGRAM],
				[have_package=yes], [have_package=no] )
fi

AC_LANG([C])
LIBS=$LIBS_cache
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
LIBS_cache=$LIBS
AC_LANG([C++])
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

AC_LANG([C])
LIBS=$LIBS_cache
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

