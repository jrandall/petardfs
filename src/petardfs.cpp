/******************************************************************************
*******************************************************************************
*******************************************************************************

    petardfs
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

#define __USE_GNU

#include <fuselagefs/fuselagefs.hh>
using namespace Fuselage;
using namespace Fuselage::Helpers;



#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <fcntl.h>

#include <sys/time.h>
#include <sys/types.h>
#include <sys/xattr.h>

#include <vector>
#include <string>
#include <list>
#include <iterator>
#include <set>
using namespace std;


/////////////////////////////////////////////////////////////////
// Hanlding XML config file.
#include <xercesc/sax/InputSource.hpp>
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/util/XMLString.hpp>
#include <xercesc/util/XMLString.hpp>
#include <xercesc/parsers/XercesDOMParser.hpp>
#include <xercesc/dom/DOM.hpp>
#include <xercesc/framework/LocalFileInputSource.hpp>
using namespace XERCES_CPP_NAMESPACE;
//XML string class
class XStr
{
public :
    XStr(const char* const toTranscode)
    {
        // Call the private transcoding method
        fUnicodeForm = XMLString::transcode(toTranscode);
    }

    ~XStr()
    {
        XMLString::release(&fUnicodeForm);
    }

    const XMLCh* unicodeForm() const
    {
        return fUnicodeForm;
    }

private :
    XMLCh*   fUnicodeForm;
};
#define X(str) XStr(str).unicodeForm()

std::string tostr( const XMLCh* xc )
    {
        if( !xc )
            return "";
        
        char* native_cstr = XMLString::transcode( xc );
        string ret = native_cstr;
        XMLString::release( &native_cstr );
        return ret;
    }

DOMElement* getChildElement( DOMNode* node, const std::string& name )
{
    DOMNodeList* nl = node->getChildNodes();
    for( int i=0; i < nl->getLength(); ++i )
    {
        DOMNode* n = nl->item( i );
        if( n->getNodeType() == DOMNode::ELEMENT_NODE )
        {
            DOMElement* child = (DOMElement*)n;
            if( tostr(child->getNodeName()) == name )
            {
                return child;
            }
        }
    }
    return 0;
}

typedef std::list< DOMNode* > domnode_list_t;
domnode_list_t& getChildren( domnode_list_t& nl, DOMElement* element )
        {
            for( DOMNode* child = element->getFirstChild();
                 child != 0; child = child->getNextSibling())
            {
                nl.push_back( child );
            }
            return nl;
        }

    string getAttribute( DOMElement* e, const XMLCh* kx )
    {
        const XMLCh* vx = e->getAttribute( kx );
        string ret = tostr(vx);
        return ret;
    }

    void setAttribute( DOMElement* e, const std::string& k, const std::string& v )
    {
        e->setAttribute( X(k.c_str()), X(v.c_str()) );
    }

    void ensureAttribute( DOMDocument* dom,
                          DOMElement* e, const std::string& k, const std::string& v )
    {
        if( !e->hasAttribute( X( k.c_str() ) ) )
            dom->createAttribute( X(k.c_str()) );
        
        setAttribute( e, k, v );
    }

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

const string PROGRAM_NAME = "petardfs";

void usage(poptContext optCon, int exitcode, char *error, char *addl)
{
    poptPrintUsage(optCon, stderr, 0);
    if (error) fprintf(stderr, "%s: %s0", error, addl);
    exit(exitcode);
}
int exit_status = 0;

const char*  CMDLINE_OPTION_XMLErrorDefinitionPath_CSTR = 0;
//unsigned int CMDLINE_OPTION_checkIfHasSubDirectories = 1;



/********************************************************************************/
/********************************************************************************/
/********************************************************************************/

DOMDocument* theErrorDOM = 0;


class Petardfs
    :
    public Delegatefs
{
    typedef Delegatefs _Base;
    

    DOMElement* getErrorElementForPath_priv( DOMElement* e, const char *path )
        {
            domnode_list_t nl;
            getChildren( nl, e );

            domnode_list_t::iterator ni = nl.begin();
            domnode_list_t::iterator ne = nl.end();

            LOG << "seeking path:" << path << endl;
            for( ; ni!=ne; ++ni )
            {
                if( (*ni)->getNodeType() == DOMNode::ELEMENT_NODE )
                {
                    LOG << "1" << endl;
                    DOMElement* n = (DOMElement*)*ni;
                    LOG << "2 n:" << n << endl;

                    if( n->hasAttribute( X( "path" ) ) )
                    {
                        LOG << "3" << endl;
                        LOG << "testing path:" << getAttribute( n, X("path") ) << endl;
                        if( getAttribute( n, X("path") ) == path )
                        {
                            LOG << "error defined for path:" << path << endl;
                            return n;
                        }
                    }
                }
            }

            return 0;
        }


    DOMElement* getOpCodeElement( const std::string& opcode )
        {
            LOG << "opcode:" << opcode << endl;
            LOG << "doc-element:" << tostr(theErrorDOM->getDocumentElement()->getNodeName()) << endl;
    
            DOMElement* e = theErrorDOM->getDocumentElement();
            if( e = getChildElement( e, "errors" ) )
            {
                LOG << "have e..." << endl;
                if( e = getChildElement( e, opcode ) )
                {
                    LOG << "have opcode:" << opcode << "..." << endl;
                    return e;
                }
            }
            return 0;
        }


    DOMElement* getErrorElementForPath( const std::string& opcode, const char *path )
        {
            LOG << "opcode:" << opcode << endl;
            LOG << "theErrorDOM:" << theErrorDOM << endl;
    
            if( !theErrorDOM )
            {
                return 0;
            }

            static set< string > validOpCodes;
            if( validOpCodes.empty() )
            {
                validOpCodes.insert( "read" );
                validOpCodes.insert( "write" );
                validOpCodes.insert( "fsync" );
                validOpCodes.insert( "mkdir" );
                validOpCodes.insert( "symlink" );
                validOpCodes.insert( "unlink" );
                validOpCodes.insert( "rmdir" );
                validOpCodes.insert( "rename" );
                validOpCodes.insert( "link" );
                validOpCodes.insert( "chmod" );
                validOpCodes.insert( "chown" );
                validOpCodes.insert( "ftruncate" );
                validOpCodes.insert( "utime" );
                validOpCodes.insert( "open" );
            }
    
            if( validOpCodes.count( opcode ) )
            {
                if( DOMElement* e = getOpCodeElement( opcode ) )
                {
                    return getErrorElementForPath_priv( e, path );
                }
                return 0;
            }

            LOG << "Unknown opcode used:" << opcode << endl;
            return 0;
        }

    bool shouldReturnError( DOMElement* e )
        {
            DOMElement* n = e;
            bool ReturnError = true;

            errno = toint( getAttribute( n, X( "error-code" ) ) );

            if( n->hasAttribute( X( "times" ) ) )
            {
                long times = toint(getAttribute( n, X( "times" ) ));
                long timeslooped = 0;
                if( n->hasAttribute( X( "times-looped" ) ) )
                    timeslooped = toint(getAttribute( n, X( "times-looped" ) ));
                ++timeslooped;
                ensureAttribute( theErrorDOM, n, "times-looped", tostr(timeslooped) );

                LOG << "times:" << times << " timeslooped:" << timeslooped << endl;
                if( timeslooped > times )
                {
                    ReturnError = false;
                }
            }

            return ReturnError;
        }


    bool shouldReturnError( DOMElement* e, off_t offset, size_t size )
        {
            domnode_list_t nl;
            getChildren( nl, e );

            LOG << "number of possible errors:" << nl.size() << endl;
            domnode_list_t::iterator ni = nl.begin();
            domnode_list_t::iterator ne = nl.end();

            for( ; ni!=ne; ++ni )
            {
                if( (*ni)->getNodeType() == DOMNode::ELEMENT_NODE )
                {
                    DOMElement* n = (DOMElement*)*ni;
                    if( n->hasAttribute( X( "error-code" ) )
                        && n->hasAttribute( X( "start-offset" ) )
                        && n->hasAttribute( X( "end-offset" ) )
                        )
                    {
                        LOG << "raw interval error code condition candidate..." << endl;
                        LOG << " offset:" << offset << " end:" << (offset+size)
                            << " XML start-offset:" << getAttribute( n, X("start-offset") )
                            << " XML end-offset:" << getAttribute( n, X("end-offset") )
                            << endl;
                    
                        if( offset <= toint( getAttribute( n, X("start-offset") ))
                            && (offset+size) >= toint( getAttribute( n, X("end-offset") ) ) )
                        {
                            bool ReturnError = true;
                        
                            LOG << "Reporting a false read error."
                                << " offset:" << offset << " end:" << (offset+size)
                                << " XML start-offset:" << getAttribute( n, X("start-offset") )
                                << " XML end-offset:" << getAttribute( n, X("end-offset") )
                                << endl;
                            errno = toint( getAttribute( n, X( "error-code" ) ) );

                            if( n->hasAttribute( X( "times" ) ) )
                            {
                                long times = toint(getAttribute( n, X( "times" ) ));
                                long timeslooped = 0;
                                if( n->hasAttribute( X( "times-looped" ) ) )
                                    timeslooped = toint(getAttribute( n, X( "times-looped" ) ));
                                ++timeslooped;
                                ensureAttribute( theErrorDOM, n, "times-looped", tostr(timeslooped) );

                                LOG << "times:" << times << " timeslooped:" << timeslooped << endl;
                                if( timeslooped > times )
                                {
                                    ReturnError = false;
                                }
                            }

                            return ReturnError;
                        }
                    }
                }
            }
            return false;
        }

    
    
public:

    Petardfs()
        {
        }
    
    ~Petardfs()
        {
        }

    virtual int fs_mkdir(const char *path, mode_t mode)
        {
            if( DOMElement* e = getErrorElementForPath( "mkdir", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_mkdir( path, mode );
        }
    
    virtual int fs_symlink(const char *from, const char *to)
        {
            if( DOMElement* e = getErrorElementForPath( "symlink", to ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_symlink(from, to);
        }
    
    virtual int fs_unlink(const char *path)
        {
            if( DOMElement* e = getErrorElementForPath( "unlink", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_unlink( path );
        }
    
    virtual int fs_rmdir(const char *path)
        {
            if( DOMElement* e = getErrorElementForPath( "rmdir", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_rmdir( path );
        }
    
    virtual int fs_rename(const char *from, const char *to)
        {
            if( DOMElement* e = getErrorElementForPath( "rename", to ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_rename(from, to);
        }
    
    virtual int fs_link(const char *from, const char *to)
        {
            if( DOMElement* e = getErrorElementForPath( "link", to ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }

            return _Base::fs_link( from, to );
        }
    
    virtual int fs_chmod(const char *path, mode_t mode)
        {
            if( DOMElement* e = getErrorElementForPath( "chmod", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_chmod( path, mode );
        }
    
    virtual int fs_chown(const char *path, uid_t uid, gid_t gid)
        {
            if( DOMElement* e = getErrorElementForPath( "chown", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_chown( path, uid, gid );
        }
    
    virtual int fs_truncate(const char *path, off_t size)
        {
            if( DOMElement* e = getErrorElementForPath( "ftruncate", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_truncate( path, size );
        }
    
    virtual int fs_ftruncate(const char *path, off_t size, struct fuse_file_info *fi)
        {
            if( DOMElement* e = getErrorElementForPath( "ftruncate", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_ftruncate( path, size, fi );
        }
    
    virtual int fs_utime(const char *path, struct utimbuf *times )
        {
            if( DOMElement* e = getErrorElementForPath( "utime", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_utime( path, times );
        }
    
    virtual int fs_fsync(const char *path, int isdatasync, struct fuse_file_info *fi)
        {
            if( DOMElement* e = getErrorElementForPath( "fsync", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_fsync( path, isdatasync, fi );
        }
    
    virtual int fs_create(const char *path, mode_t mode, struct fuse_file_info *fi)
        {
            if( DOMElement* e = getErrorElementForPath( "open", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_create( path, mode, fi );
        }
    
    virtual int fs_open( const char *path, struct fuse_file_info *fi )
        {
            if( DOMElement* e = getErrorElementForPath( "open", path ) )
            {
                if( shouldReturnError( e ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_open( path, fi );
        }
    
    virtual int fs_read(const char *path, char *buf, size_t size,
                        off_t offset, struct fuse_file_info *fi)
        {
            if( DOMElement* e = getErrorElementForPath( "read", path ) )
            {
                if( shouldReturnError( e, offset, size ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_read( path, buf, size, offset, fi );
            
        }
    
    virtual int fs_write( const char *path, const char *buf, size_t size,
                          off_t offset, struct fuse_file_info *fi)
        {
            if( DOMElement* e = getErrorElementForPath( "write", path ) )
            {
                if( shouldReturnError( e, offset, size ) )
                {
                    return -errno;
                }
            }
            return _Base::fs_write( path, buf, size, offset, fi);
        }
    
    
};





/********************************************************************************/
/********************************************************************************/
/********************************************************************************/

int main(int argc, char *argv[])
{
    const char* X   = 0;
    unsigned long Y = 0;
    unsigned long Verbose           = 0;
    unsigned long ShowHelp          = 0;

    const char* ForceToFileRegex_CSTR = 0;

    Petardfs myfuse;
    
    struct poptOption* fuselage_optionsTable = myfuse.getPopTable();
    struct poptOption optionsTable[] =
        {
            { "verbose", 'v', POPT_ARG_NONE, &Verbose, 0,
              "show what is happening", "" },



            { "error-definitions", 'e',
              POPT_ARG_STRING, &CMDLINE_OPTION_XMLErrorDefinitionPath_CSTR, 0,
              "read synthetic error definitions from this XML file", "" },

            { 0, 0, POPT_ARG_INCLUDE_TABLE, fuselage_optionsTable,
              0, "Fuselage options:", 0 },
            
            POPT_AUTOHELP
            POPT_TABLEEND
        };
    poptContext optCon;

    optCon = poptGetContext(PROGRAM_NAME.c_str(), argc, (const char**)argv, optionsTable, 0);
    poptSetOtherOptionHelp(optCon, "[OPTIONS]* mountpoint");

    /* Now do options processing */
    char c=-1;
    while ((c = poptGetNextOpt(optCon)) >= 0)
    {
    }


    string mountPoint = "";
    while( const char* tCSTR = poptGetArg(optCon) )
    {
        string t = tCSTR;
        cerr << "t:" << t << endl;
        if( mountPoint.empty() )
            mountPoint = t;
    }

    if( mountPoint.empty() )
    {
        cerr << "no mountpoint given" << endl;
        poptPrintHelp(optCon, stderr, 0);
        exit(1);
    }
    
    

    #undef LOG
    #define LOG myfuse.getLogStream() << __PRETTY_FUNCTION__ << " --- " 

    if( !CMDLINE_OPTION_XMLErrorDefinitionPath_CSTR )
    {
        LOG << "Warning, no errors defined, petard filesystem will act exactly like -u" << endl;
        cerr << "Warning, no errors defined, petard filesystem will act exactly like -u" << endl;
    }
    else
    {
        string XMLErrorDefinitionPath = CMDLINE_OPTION_XMLErrorDefinitionPath_CSTR;
        LOG << "Loading error definitions from:" << XMLErrorDefinitionPath << endl;

        XMLPlatformUtils::Initialize();
        XMLFormatter::UnRepFlags gUnRepFlags = XMLFormatter::UnRep_CharRef;
        XercesDOMParser* parser = new XercesDOMParser();
        parser->setLoadExternalDTD( false );
        parser->setValidationScheme( XercesDOMParser::Val_Never );
        parser->setDoNamespaces( 0 );
        parser->setDoSchema( 0 );

        LocalFileInputSource xmlsrc( X(XMLErrorDefinitionPath.c_str()) );
        parser->parse( xmlsrc );


        LOG << "XML configuration. Numbers of errors in the parsing of the XML file:" << parser->getErrorCount() << endl;
        if( parser->getErrorCount() )
        {
            stringstream ss;
            ss << "Errors encountered creating DOM from stream. count:"
               <<  parser->getErrorCount()
               << endl;
            int errorCount   = parser->getErrorCount();
            DOMDocument* doc = parser->adoptDocument();
            cerr << ss.str() << endl;
            return(1);
        }
        
        DOMDocument* dom = parser->adoptDocument();
        
        theErrorDOM = dom;
    }
    

    /****************************************/
    /****************************************/
    /****************************************/

    list<string> fuseArgs;
    fuseArgs.push_back( "petardfs" );

    myfuse.AugmentFUSEArgs( fuseArgs );
    
    fuseArgs.push_back( "-s" );
    fuseArgs.push_back( "-o" );
    fuseArgs.push_back( "nonempty" );
    fuseArgs.push_back( "-o" );
    fuseArgs.push_back( "fsname=petardfs" );
//     fuseArgs.push_back( "-o" );
//     fuseArgs.push_back( "large_read" );

    LOG << "mountPoint:" << mountPoint << endl;
    fuseArgs.push_back( mountPoint );
    
    /****************************************/
    /****************************************/
    /****************************************/

    return myfuse.main( fuseArgs );
}
