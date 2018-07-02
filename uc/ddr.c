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

static int ddr_fifo_endpoint_enabled = 0;

static void ddr_fifo_endpoint_init() 
{			
	// NAK all FIFOs
	FIFORESET = 0x80; // Reset the FIFO
	SYNCDELAY;
	
	// Flush EP6
	EP6FIFOCFG = 0x00; //switching to manual mode for flush
	SYNCDELAY;
	FIFORESET = 0x86;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;
	
	// Configure EP6
	EP6CFG = 0xEA; // EP6 is DIR=IN, TYPE=BULK, 1024, Double
	SYNCDELAY;
	EP6FIFOCFG = bmBIT3 | bmBIT2 | bmBIT0; // EP6 is AUTOOUT=0, AUTOIN=1, ZEROLEN=1, WORDWIDE=1
	SYNCDELAY;
	FIFORESET = 0x06;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;
	
	// clear stall bits
	EP2FIFOCFG &= ~bmBIT0;
	SYNCDELAY;
	EP4FIFOCFG &= ~bmBIT0;
	SYNCDELAY;
	EP8FIFOCFG &= ~bmBIT0;
	SYNCDELAY;
	
	EP6AUTOINLENH = 0x04; // Auto-commit 1024-byte packets
	SYNCDELAY;
	EP6AUTOINLENL = 0x00;
	SYNCDELAY;
	
	FIFOPINPOLAR = 0xFF; // all pins active-high
	SYNCDELAY; 
	SYNCDELAY; 
	
	EP6FIFOPFH = 0xC1;
	SYNCDELAY;
	EP6FIFOPFL = 0xFF;
	SYNCDELAY;
	
	ddr_fifo_endpoint_enabled = 1;
}
