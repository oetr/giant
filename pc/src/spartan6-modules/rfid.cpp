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

#include <rfid.h>

rfid::rfid()
{
}

rfid::~rfid()
{
}


void rfid::transmitShortFrame(const uint8_t b)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// convert to format for FPGA
	const uint8_t value = (util::bitreverse(b & 0x3f) >> 1);

	fpga->writeRegister(fault_fpga_spartan6::MILLER_DATA_IN, value);
	
	// transmit
	transmit(1);
}

void rfid::transmitRawFrame(const fault_fpga_spartan6::buffer_t b, 
	const unsigned int valid)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// truncate
	const uint8_t valid_int = (valid <= 8) ? valid : 8;
	
	// convert to format for FPGA	
	// add in reverse order, starting with MSB
	// shift last byte right to match total length
	const uint8_t value = (util::bitreverse(b.back()) >> (8 - valid_int));
	fpga->writeRegister(fault_fpga_spartan6::MILLER_DATA_IN, value);
	
	// remaining bytes
	for(int i =  b.size() - 2; i >= 0; i--)
	{
		const uint8_t value = (util::bitreverse(b[i]));

		fpga->writeRegister(fault_fpga_spartan6::MILLER_DATA_IN, value);
	}
	
	
	// transmit
	transmit(8 - valid_int);
}


void rfid::transmit(const uint8_t discard_bits)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::MILLER_OMIT_COUNT, discard_bits);
	
	fpga->risingEdgeRegister(fault_fpga_spartan6::MILLER_CONTROL, 
		fault_fpga_spartan6::MILLER_CONTROL_TRANSMIT);
}
	
uint8_t rfid::getStatus()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->readRegister(fault_fpga_spartan6::MILLER_STATUS);
}