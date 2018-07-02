/*!
   This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
   
   Visit www.sourceforge.net/projects/giant/
   
   Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
   
   This program uses the ZTEX-SDK, available under the GNU General Public 
   License version 3. The SDK is included with this source code. 
   Copyright (C) 2009-2011 ZTEX e.K.
   http://www.ztex.de

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

static void io_init()
{
	// clear stall flags
	EP2CS &= ~bmBIT0;
	SYNCDELAY; 
	EP4CS &= ~bmBIT0;
	SYNCDELAY;
	EP4BCL = 0x80;
	SYNCDELAY;
	EP4BCL = 0x80;	

	// NAK all
	FIFORESET = 0x80;	// reset FIFO
	SYNCDELAY;
	
	// reset FIFO 2
	FIFORESET = 0x02;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;
}

static unsigned int io_can_write() 
{
	return (!(EP2CS & bmBIT3)) ? 1 : 0;
}

static unsigned int io_write(const unsigned char* buffer, const WORD length)
{
	WORD i = 0;
	
	for(i = 0; i < length && i < 512; i++) {
		EP2FIFOBUF[i] = buffer[i];
	}
	
	EP2BCH = length >> 8;
	SYNCDELAY; 
	// arm EP2
	EP2BCL = length & 255;
	
	return i;
}

static unsigned int io_write_byte(const unsigned char byte) 
{
	return io_write(&byte, 1);
}

static unsigned int io_bytes_available()
{
	 return (!(EP4CS & bmBIT2)) ? 1 : 0; 
}

static WORD io_get_bytes_available()
{
	WORD size = (EP4BCH << 8) | EP4BCL;
	return size;
}

static unsigned int io_read(unsigned char* buffer, const WORD max_length)
{
	WORD size = (EP4BCH << 8) | EP4BCL;
	WORD i = 0;
	
	// read data from queue
	for(i = 0; i < size && i < max_length && i < 512; i++) {
		buffer[i] = EP4FIFOBUF[i];
	}
	
	// rearm EP4
	SYNCDELAY; 
	EP4BCL = 0x80;
	
	return i;
}

static unsigned char io_read_byte()
{
	unsigned char value = 0;
	
	io_read(&value, 1);
	
	return value;
}