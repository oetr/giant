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

#ifndef __keyboard__
#define __keyboard__

// C includes
#include <cstdio>
#include <cstdlib>
#include <ctype.h>
#include <sys/time.h>
#include <unistd.h>
#include <termios.h>

#ifndef STDIN_FILENO
#define STDIN_FILENO 0
#endif

/**
 * @brief Non-blocking keyboard access
 * @note Follows singleton pattern
 */
class keyboard {

	static keyboard* ms_instance;

private:
	keyboard(const keyboard& rhs);
	keyboard& operator=(const keyboard& rhs);

public:
	static keyboard* instance();
	static void release();
	
	char get();
	bool kbhit();

private:
	keyboard();
	~keyboard();
	
	struct termios tty_old;
	
	struct termios tty_set_raw();
	void tty_restore(struct termios oldstuff);

};
#endif // __keyboard__
