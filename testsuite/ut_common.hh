/******************************************************************************
*******************************************************************************
*******************************************************************************

    petardfs test code
    Copyright (C) 2007 Ben Martin

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    For more details see the COPYING file in the root directory of this
    distribution.

    $Id: ferrisfs.cpp,v 1.1 2006/12/10 04:45:50 ben Exp $

*******************************************************************************
*******************************************************************************
******************************************************************************/

#include <popt.h>
#include <errno.h>

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <fstream>
#include <list>
#include <vector>
#include <string>
#include <iterator>
using namespace std;

void usage(poptContext optCon, int exitcode, char *error, char *addl)
{
    poptPrintUsage(optCon, stderr, 0);
    if (error) fprintf(stderr, "%s: %s0", error, addl);
    exit(exitcode);
}
int exit_status = 0;
int errors = 0;
unsigned long Verbose = 0;

ostream& E()
{
    ++errors;
    cerr << "error:";
    return cerr;
}

void
assertcompare( const std::string& emsg,
               const std::string& expected,
               const std::string& actual )
{
    if( expected != actual )
        E() << emsg << endl
            << " expected:" << expected << ":" 
            << " actual:" << actual << ":" << endl;
}


void myexit()
{
    if( !errors )
        cerr << "Success" << endl;
    else
        cerr << "error: error count != 0" << endl;

    exit(exit_status);
}


