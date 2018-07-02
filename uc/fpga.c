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

// uC -> FPGA data
#define[UC2FPGA_DATA][IOC]
#define[OE_UC2FPGA_DATA][OEC]


// adress valid pin
/*#define[_AV][0]
// write enable (UC2FPGA_DATA is written to currently addressed register)
#define[_WE][1]
// read enable (FPGA2UC_DATA will hold data from currently addressed register)
#define[_RE][2]
// FIFO in write enable (write data to FPGA)
#define[_IN_WE][3]
// FIFO in write data pin (write data to FPGA)
#define[_IN_PIN][4]
// FIFO out read enable (read data from FPGA)
#define[_OUT_RE][5]
// FIFO out read data pin (read data from FPGA)
#define[_OUT_PIN][6]*/

// FIFO in write enable (write data to FPGA)
#define[_IN_WE][0]
// FIFO in write data pin (write data to FPGA)
#define[_IN_PIN][1]
// FIFO out read enable (read data from FPGA)
#define[_OUT_RE][2]
// FIFO out read data pin (read data from FPGA)
#define[_OUT_PIN][3]


static void fpga_init()
{
	// init input from FPGA
	// init output to FPGA
	OE_UC2FPGA_DATA = (1 << _OUT_RE) | (1 << _IN_WE) | (1 << _IN_PIN);
		
	SYNCDELAY;
	SYNCDELAY;
	
	return;
}

static void fpga_fifo_in_write(unsigned char value)
{
	unsigned char i;
	
	// clock out, msb first
	for(i = 0; i < 8; i++) 
	{
		UC2FPGA_DATA_IN_PIN = (value >> 7) & 0x1;
		value <<= 1;
		
		GEN_RISING_EDGE(UC2FPGA_DATA_IN_WE);
	}
	
}

static unsigned char fpga_fifo_out_read()
{
	unsigned char i, result = 0;
	
	// clock in, msb first
	for(i = 0; i < 8; i++) 
	{
		GEN_RISING_EDGE(UC2FPGA_DATA_OUT_RE);
		
		result <<= 1;
		result |= (UC2FPGA_DATA_OUT_PIN);
	}
	
	return result;
}

void fpga_write_register(const unsigned char addr, const unsigned char value) 
{
	// output write command & address
	fpga_fifo_in_write((addr << 1) | 1);
	
	// output data byte to write
	fpga_fifo_in_write(value);
	
	return;
}

static unsigned char fpga_read_register(const unsigned char addr) 
{
	unsigned char result;
	
	// output read command & address
	fpga_fifo_in_write((addr << 1) | 0);

	result = fpga_fifo_out_read();
	
	return result;
}
