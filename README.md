petardfs
========

PetardFS - a FUSE filessytem for injecting intentional errors (e.g. for testing)

Originally developed by Ben Martin (http://sourceforge.net/projects/witme/files/petardfs/0.0.2/).

With no configuration petardfs takes a base filesystem and exposes it through FUSE.

An XML configuration file is used to tell petardfs which files to report errors
for and what error code to use. 

For example, foo.txt can have an EIO error at bytes 34 to 37. There is explicit 
support for errors such as EAGAIN and EINTR where petardfs will only report such 
transient errors a nominated number of times, handy for testing applications support 
such IO conditions gracefully.

