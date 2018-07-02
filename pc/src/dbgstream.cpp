#include "dbgstream.h"

using namespace std;

dbgstream cdbg;
dbgstream clog;
dbgstream cerror;

dbgbuf::~dbgbuf()
{
    flushMsg();
}

void dbgbuf::flushMsg()
{
	if (msg.length() > 0) {
		if (tee) {
			(*tee) << msg << endl << flush;
		}
		
		//printw("DBG: %s\n", msg.c_str());

		msg.erase();
	}
}

std::ostream *dbgbuf::setTee(std::ostream *_tee)
{
    std::ostream *otee = tee; 
    tee = _tee; return otee; 
}

int dbgbuf::overflow(int c)
{
    if (c == '\n') {
		flushMsg();
    } else {
		msg += c;
    }
    return c == -1 ? -1 : ' ';
}
