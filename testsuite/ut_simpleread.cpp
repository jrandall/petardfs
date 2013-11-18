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

#include "ut_common.hh"

#include <fstream>
using namespace std;

const string PROGRAM_NAME = "ut_simpleread";
const char*  CMDLINE_OPTION_foo_CSTR = "/";
unsigned long Y = 0;
unsigned long ReadStartToEnd = 0;

/********************************************************************************/
/********************************************************************************/
/********************************************************************************/


/********************************************************************************/
/********************************************************************************/
/********************************************************************************/


int main(int argc, char *argv[])
{
    const char*  CMDLINE_OPTION_url_CSTR = 0;
    string url = "";
    
    struct poptOption optionsTable[] =
        {
            { "verbose", 'v', POPT_ARG_NONE, &Verbose, 0,
              "show what is happening", "" },

            { "url", 'u', POPT_ARG_STRING, &CMDLINE_OPTION_url_CSTR, 0,
              "url to read", "" },

            { "read-start-to-end", '1', POPT_ARG_NONE, &ReadStartToEnd, 0,
              "", "" },
            
            POPT_AUTOHELP
            POPT_TABLEEND
        };
    poptContext optCon;

    optCon = poptGetContext(PROGRAM_NAME.c_str(), argc, (const char**)argv, optionsTable, 0);
    poptSetOtherOptionHelp(optCon, "[OPTIONS]*");

    /* Now do options processing */
    char c=-1;
    while ((c = poptGetNextOpt(optCon)) >= 0)
    {
    }

    if( CMDLINE_OPTION_url_CSTR )
    {
        url = CMDLINE_OPTION_url_CSTR;
    }
    
    cout << "url:" << url << endl;
    cout << "File data follows..." << endl;
    try
    {
        if( ReadStartToEnd )
        {
            ifstream iss( url.c_str() );
            std::copy( std::istreambuf_iterator<char>(iss),
                       std::istreambuf_iterator<char>(),
                       std::ostreambuf_iterator<char>(cout) );
            cout << flush;
            if( !iss.eof() )
            {
                E() << " iss is good():"<< iss.good() << endl;
                E() << " iss is eof():"<< iss.eof() << endl;
                E() << " iss is state:"<< iss.rdstate() << endl;
                if ( iss.rdstate() & ifstream::failbit )
                    E() << " iss has fail bit set." << endl;
                if ( iss.rdstate() & ifstream::badbit )
                    E() << " iss has bad bit set." << endl;
                E() << " iss tellg:"<< iss.tellg() << endl;
                E() << "errno:" << errno << endl;
            }

//            E() << (!iss.eof()) << (!iss.good()) << (iss.rdstate() & ifstream::failbit) << ( errno==5 ) << endl;
            if( !iss.eof() && !iss.good() && (iss.rdstate() & ifstream::failbit) && errno==5 )
            {
                E() << "Failed with EIO!" << endl;
            }
            
            
        }
    }
    catch( exception& e )
    {
        E() << "e.what:" << e.what() << endl;
        exit_status = 10;
    }

    myexit();
}
    
