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

#include "keyboard.h"

keyboard* keyboard::ms_instance = 0;

keyboard::keyboard()
{
	tty_old = tty_set_raw();
}

keyboard::~keyboard()
{
	tty_restore(tty_old);
}

keyboard* keyboard::instance()
{
	if(ms_instance == 0){
		ms_instance = new keyboard();
	}
	return ms_instance;
}

void keyboard::release()
{
	if(ms_instance){
		delete ms_instance;
	}
	ms_instance = 0;
}

void keyboard::tty_restore(termios oldstuff)
{
	// restore old attributes 
	tcsetattr(STDIN_FILENO, TCSANOW, &oldstuff);
}

termios keyboard::tty_set_raw()
{
	struct termios oldstuff;
    struct termios newstuff;

	// save old attributes
    tcgetattr(STDIN_FILENO, &oldstuff);
    newstuff = oldstuff;
    
	/* 
     * Resetting these flags will set the terminal to raw mode.
     * Note that ctrl-c won't cause program exit, so there
     * is no emergency panic escape. (If your calling program
     * doesn't handle things properly, you will have to kill
     * the process externally.)
     */
    //newstuff.c_lflag &= ~(ICANON | ECHO | IGNBRK);
	newstuff.c_lflag &= ~(ICANON | IGNBRK);

    tcsetattr(STDIN_FILENO, TCSANOW, &newstuff);/* set new attributes  */
    return oldstuff;
}

char keyboard::get()
{
	// Ctrl-D
	const char END_FILE_CHARACTER = 0x04;
	
    char inch;
    int num_chars;

    do {
        num_chars = read(0, &inch, 1);
    } while (num_chars < 1);

    if (inch == END_FILE_CHARACTER) {
        inch = EOF;
    }

    return inch;

}

bool keyboard::kbhit()
{
	// set one microsecond timeout 
    struct timeval tv = {0,0}; 
    fd_set rdfds;
    int retval;

    FD_ZERO(&rdfds);
    FD_SET(STDIN_FILENO, &rdfds);

    if (select(STDIN_FILENO + 1, &rdfds, NULL, NULL, &tv) == -1) {
        perror("select");
        exit(1);
    }
    if (FD_ISSET(STDIN_FILENO, &rdfds)) {
        retval = 1;
    }
    else {
        retval = 0;
    }
	
    return (retval == 1);
}
