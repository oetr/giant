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

#ifndef __rfid_h__
#define __rfid_h__

// C includes

// C++ includes
#include <vector>
#include <utility>

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>

// Forward declarations

/**
 * @brief RFID controller for Spartan6
 */
class rfid
{
	public:
		/**
		 * Constructor
		 */
		rfid();
		
		/**
		 * Destructor
		 */
		virtual ~rfid();
		
		/**
		 * Send short frame
		 * @param b Short frame value (7 bit) to send
		 */
		void transmitShortFrame(const uint8_t b);
		
		/**
		 * Transmit a raw frame (as is, including parity)
		 * @param b Frame to send
		 * @param valid Number of valid bits in final byte
		 */
		void transmitRawFrame(const fault_fpga_spartan6::buffer_t b,
			const unsigned int valid);
		
		/**
		 * Transmit a frame, adding the parity bits before
		 * @param b Frame to send
		 */
		void transmitFrameWithParity(const fault_fpga_spartan6::buffer_t b);
		
		/**
		 * Get status
		 * @return 8-bit status word
		 */
		uint8_t getStatus();	
	protected:
		/**
		 * Transmit n Bits from output fifo
		 * @param short_frame Transmit short frame?
		 */
		void transmit(const uint8_t discard_bits = 0);
	private:		
		
};
 
#endif
