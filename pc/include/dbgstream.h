/**
 * @file dbgstream.h
 * @short Debug stream objects
 * 
 * The following text and the ideas from it are from Dietmar Kuehl.
 * <!! Copyright (C) 1997 Dietmar Kuehl >
 * <!! Universitaet Konstanz, Germany, Lehrstuhl fuer praktische >
 * <!! Informatik I >
 * I'm not sure if the assertion is correct with "modern" Std C++ libraries,
 * but It's a simple thing to keep in the code ;-)

 * -----------------------------------------------------------------------------
 * To get the order of construction and destruction straight I use a
 * technique presented to me by Ron Klatchko (ron@crl.com): It would
 * be cleaner to construct the 'streambuf' before the 'ostream is
 * constructed (and destruction correspondingly in the reverse order)
 * but bases are constructed prior to members. Thus, Ron came up with
 * the idea to use a private base class, becoming the left most base
 * class, containing the corresponding member: This yields the desired
 * order of construction. I called this technique "Ron's Member".
 */
 
#ifndef _H_DBGSTREAM_
#define _H_DBGSTREAM_

#include <iostream>
#include <string>
//#include <curses.h>

/**
 * @brief Base class for type wrapping
 */
template <class T>
struct PBase
{
	T sbuf;
	PBase() { }
};

/**
 * @brief Debug output stream
 * 
 * The dbgbuf class is used by the dbgstream class to manage output
 * to OutpuDebugString() and to a 'tee' stream.  The 'tee' stream can
 * be any std::ostream object.  It's important to note that a pointer
 * to the tee ostream is kept inside this object, so it should not
 * be deleted until the dbgbuf object is no longer in use. (the dbgbuf
 * object does not try to copy the ostream object).
 * 
 * Messages are sent to the debugger and the tee stream when a newline
 * character is seen.  Any leftover characters in the buffer will be output
 * when the object is destroyed.
 * 
 * This class is not normally used by itself, it is usually attached to
 * a dbgstream object.
 */
class dbgbuf : public std::streambuf 
{
	private:
		std::string msg;	///< buffer for current log message
		std::ostream *tee;	///< if != 0, send output here, also.

		/// internal function used to direct output to syslog and (optionally)
		/// to the tee stream.
		void flushMsg();

	public:
		/// constructor.
		dbgbuf() : tee(0) { };

		/// Destructor.  No magic here.
		~dbgbuf();

		/// Set a stream to be used as an additional output.  Messages are
		/// directed to this stream as well as to syslog().
		std::ostream *setTee(std::ostream *_tee);

	protected:

		/// streambuf implementation.
		virtual int overflow(int ch);

	private:
		dbgbuf(dbgbuf const &);                // disallow copy construction
		void operator= (dbgbuf const &);          // disallow copy assignment
};

/**
 * @brief Debug stream
 */
class dbgstream :
	private PBase<dbgbuf>,
	public std::basic_ostream<char,std::char_traits<char> >
{
	public:
		/// Constructor.
		explicit dbgstream() :
			std::basic_ostream<char,std::char_traits<char> > (&sbuf)
			{ }

		/// set tee object.  Reflects to underlying stream buffer object.
		std::ostream *setTee(std::ostream *_tee) {
			return sbuf.setTee(_tee);
		}
};

/**
 * Debug stream object
 */
extern dbgstream cdbg;

/**
 * Log stream object
 */
extern dbgstream clog;

/**
 * Error stream object
 */
extern dbgstream cerror;

#endif /* _H_DBGSTREAM_ */
