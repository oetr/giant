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

#include "serial.h"

#if defined(__CYGWIN__) || defined(__MSYS__)
/* Workaround for Cygwin, which is missing cfmakeraw */
static void my_cfmakeraw(struct termios *termios_p)
{
   termios_p->c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
   termios_p->c_oflag &= ~OPOST;
   termios_p->c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
   termios_p->c_cflag &= ~(CSIZE|PARENB|CRTSCTS);
   termios_p->c_cflag |= CS8;
}
#endif /* defined(__CYGWIN__) */

serial::serial() : connected(false), tty_fd(-1)
{
}

serial::~serial()
{
	if(isConnected())
		close();
}

void serial::close()
{
	if(isConnected()) {
		::close(tty_fd);
		tty_fd = -1;
	}
}

bool serial::open(const std::string& path, const tcflag_t rate)
{
	if(isConnected()) {
		cerror << "serial::open(): Device connection already open" << std::endl;
		return false;
	}
	
	if ((tty_fd = ::open(path.c_str(), O_RDWR | O_NOCTTY )) < 0) {
		cerror << "serial::open(): Error while opening '" << path << "', error: " << ::strerror(errno) << std::endl;
		return false;
	}
	
	struct termios portset;
	::tcgetattr(tty_fd, & portset);
	
	#if defined(__CYGWIN__) || defined(__MSYS__)
		::my_cfmakeraw(&portset);
	#else
		::cfmakeraw(&portset);
	#endif
	
	::cfsetospeed(&portset, rate);
	::cfsetispeed(&portset, rate);
	::tcsetattr(tty_fd, TCSANOW, &portset);
	
	(void)tcflush(tty_fd, TCIOFLUSH);
	(void)usleep(200000);
	tcflush(tty_fd, TCIOFLUSH);

	// HACK: disable flow control
	int i = 0;
	i |= TIOCM_DTR;
	if (ioctl(tty_fd, TIOCMBIC, &i) != 0) {
			printf("IOCTL error.\n");
			exit(1);
	}

	i = 0;
	i |= TIOCM_RTS;
	if (ioctl(tty_fd, TIOCMBIC, &i) != 0) {
			printf("IOCTL error.\n");
			exit(2);
	}

	connected = true;
	
	return true;
}

int serial::read(buffer_t& result, const unsigned int timeout_ms)
{
	if(!isConnected()) {
		cerror << "serial::read_(): Device not connected" << std::endl;
		return -1;
	}
	
	result.clear();
	
	int valid = 0;
  
	struct pollfd pfd;
	
	const unsigned int RX_SIZE = 256;
	unsigned char rx_buf[RX_SIZE];

	pfd.fd = tty_fd;
	pfd.events = POLLIN | POLLPRI;

	int n = ::poll(&pfd, 1, timeout_ms);
	memset(rx_buf, 0, RX_SIZE);

	if (n == - 1) {
		cerror << "serial::read(): Error while polling device: " << strerror(errno) << std::endl;
		valid = -1;
	}
	else if ((n > 0) && (pfd.revents & POLLIN)) {
		if ((n = ::read(tty_fd, rx_buf, RX_SIZE-1)) < 0 ) {
			cerror << "serial::read(): Error while reading from device:" << strerror(errno) << std::endl;
			valid = -1;
		}
		else {
			if(n == 0) {
				cdbg << "serial::read(): No data received" << std::endl;
			}
			else {
				for(int i = 0; i < n && i < static_cast<int>(RX_SIZE-1); i++) { 
					result.push_back(rx_buf[i]);
				}
				valid = result.size();
			}
		}
	}
	else {
		cdbg << "serial::read(): Timeout" << std::endl;
		valid = -1;
	}
		
	return valid;
}

void serial::write(const buffer_t& frame)
{
	if(!isConnected()) {
		cerror << "serial::write(): Device not connected" << std::endl;
		return;
	}
	
	uint8_t* tx = new uint8_t[frame.size()+1];
	
	for(unsigned int i = 0; i < frame.size(); i++)
		tx[i] = frame[i];
		
	tx[frame.size()] = 0;
	
	if (::write(tty_fd, tx, frame.size()) < 0) {
		cerror << "serial::write(): Error while writing to device: " << strerror(errno) << std::endl;
	}
	
	delete [] tx;
}



