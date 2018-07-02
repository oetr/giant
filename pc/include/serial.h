/*!
   This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
   
   Visit www.sourceforge.net/projects/giant/
   
   Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#ifndef __serial__
#define __serial__

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/termios.h>
#include <sys/poll.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <inttypes.h>

#include <iostream>
#include <iomanip>
#include <string>
#include <vector>

#include <dbgstream.h>
#include <util.h>

/**
 * @brief Serial port helper
 * Helper class to support serial port i/o under cygwin/linux
 */
class serial
{
public:
	/**
	 * Class constructor
	 */
	serial();

	/**
	 * Destructor
	 */
	virtual ~serial();
	
	/**
	 * Data buffer type
	 */
	typedef std::vector<uint8_t> buffer_t;

	/**
	 * Open connection
	 * @param path Path to serial port (/dev/comX under cygwin)
	 * @param rate Baudrate, use constants from termbits.h (B9600 etc.)
	 * @return true on success, else false
	 */
	bool open(const std::string& path, const tcflag_t rate);

	/**
	 * Close connection
	 */
	void close();
	
	/**
	 * Connection state
	 * @return true if connection established
	 */
	const bool& isConnected() const {
		return connected;
	}
	
	
	/**
	  * Write data to serial port
	  * @param frame Raw binary data to send
	  */
	void write(const buffer_t& frame);

	/**
	 * Blocking read with timeout
	 * @param result Reference to result storage
	 * @param timeout_ms Timeout in ms
	 * @return Number of bytes read, or -1 on error or timeout
	 */
	int read(buffer_t& result, const unsigned int timeout_ms);
	
protected:
	/**
	 * Connection state
	 */
	bool connected;

	/**
	 * File handle
	 */
	int tty_fd;
private:
};
#endif // __serial__
