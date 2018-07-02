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

#include[ztex-conf.h]
#include[ztex-utils.h]

// configure endpoints 2 and 4, both belong to interface 0 (in/out are from the point of view of the host)
EP_CONFIG(2,0,BULK,IN,512,2);
EP_CONFIG(4,0,BULK,OUT,512,2);

// configure endpoint 6 for FIFO mode (double = 2, quad = 4 buffered)
EP_CONFIG(6,0,BULK,IN,1024,2);

// select ZTEX USB FPGA Module 1.11 as target (required for FPGA configuration)
IDENTITY_UFM_1_11(10.12.0.0,0);

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["FaultInjectionFPGA"]

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
	//OED = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5);
	OEC = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5);
	OEA |= 1;
	IOA0 = 0;
	
	//IFCONFIG = bmBIT7| bmBIT6 | bmBIT3; // clk enable, fifo disabled
	//SYNCDELAY;
	
	IFCONFIG = bmBIT7 | bmBIT6 | bmBIT5 | bmBIT1 | bmBIT0; // clk enable, internal 48 MHz, fifo mode
	SYNCDELAY;
	
	REVCTL = 0x00; // REVCTL.0 and REVCTL.1 set to 1
	SYNCDELAY;
	SYNCDELAY;	
	
	EP6BCL = 0x80;	// skip package, (re)arm EP6
	SYNCDELAY;
	
	EP6BCL = 0x80;	// skip package, (re)arm EP6
	FIFORESET = 0x80; // activate NAK-ALL to avoid race conditions
	SYNCDELAY;
	
	EP6FIFOCFG = 0x00; //switching to manual mode
	SYNCDELAY;
	FIFORESET = 0x06; // Reset FIFO 6
	SYNCDELAY;
	
	EP6FIFOCFG = bmBIT3 | bmBIT2 | bmBIT0; // EP6 is AUTOOUT=0, AUTOIN=1, ZEROLEN=1, WORDWIDE=1
	SYNCDELAY;
	FIFORESET = 0x00; //Release NAKALL
	SYNCDELAY;
]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

// common includes & macros
#include[common.h]

// include I/O helper functions
#include[io.c]

// include helper functions for FPGA <-> uC
#include[fpga.c]

// include uC <-> FPGA DDR helper functions
#include[ddr.c]

#define[IO_BUFFER_SIZE][8];

//command codes
#define[OK_SUCCESS][0x00];
#define[ERROR_GENERAL][0xe0];
#define[ERROR_INSUFFICIENT_LEN][0xe1];
#define[ERROR_UNKNOWN_COMMAND][0xe2];


/**
 * Handle an I/O buffer, may destroy the buffer if needed
 * @param buffer Pointer to received buffer
 * @param length Number of valid bytes in buffer
 * @param max_buffer_size Number of bytes in buffer that may be used
 */
static void handle_buffer(unsigned char* buffer, const WORD length,
	const WORD max_buffer_size) 
{
	if(length > 0 && max_buffer_size >= 2) 
	{
		switch(buffer[0])
		{
			// read register
			case 0x01:
				if(length == 2) {
					buffer[0] = OK_SUCCESS;
					buffer[1] = fpga_read_register(buffer[1]);
					io_write(buffer, 2);
				}
				else {
					buffer[0] = ERROR_INSUFFICIENT_LEN;
					io_write(buffer, 1);
				}
			break;
			
			// write register
			case 0x02:
				if(length == 3) {
					fpga_write_register(buffer[1], buffer[2]);
					
					buffer[0] = OK_SUCCESS;
					io_write(buffer, 1);
				}
				else {
					buffer[0] = ERROR_INSUFFICIENT_LEN;
					io_write(buffer, 1);
				}
			break;
			
			// reset FPGA
			case 0x03:
				if(length == 1) {
					// reset
					IOA0 = 1;
					
					// wait 100 us
					uwait(10);
					
					// release
					IOA0 = 0;
					
					buffer[0] = OK_SUCCESS;
					io_write(buffer, 1);
				}
				else {
					buffer[0] = ERROR_INSUFFICIENT_LEN;
					io_write(buffer, 1);
				}
			break;
			
			default:
				// send "Unknown command" error message
				buffer[1] = buffer[0];
				buffer[0] = ERROR_UNKNOWN_COMMAND;
				io_write(buffer, 2);
			break;
		}
	}
	else {
		// notify host of error (insufficient length)
		unsigned char buffer_local = ERROR_INSUFFICIENT_LEN;
		io_write(&buffer_local, 1);
	}
}

void main(void)	
{
	WORD size = 0;
	WORD i = 0;
	
	unsigned char buffer[IO_BUFFER_SIZE];
	
	// init everything
	init_USB();
	
	io_init();
	ddr_fifo_endpoint_init();
	
	while (1) 
	{
		// EP4 is not empty (host -> device)
		if (io_bytes_available()) 
		{
			// read data
			size = io_read(buffer, IO_BUFFER_SIZE);
			SYNCDELAY;
			
			// handle buffer
			handle_buffer(buffer, size, IO_BUFFER_SIZE);
		}
	}
}
