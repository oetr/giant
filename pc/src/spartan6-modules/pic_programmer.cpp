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

#include <pic_programmer.h>

pic_programmer::pic_programmer() : pic_powered(false), pic_addr(0), pic_in_config(false)
{

}

pic_programmer::~pic_programmer()
{

}

void pic_programmer::setPower(const bool on)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// Only switch if new state
	if(isPicPowered() != on)
	{
		// power PIC
		fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
		fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_PROG_STARTSTOP);
		fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
		
		// update state
		pic_powered = on;
		
		pic_addr = 0;
		pic_in_config = false;
	}
	else 
	{
		dbg::out(dbg::warning) << "setPower() has no effect" << std::endl;
	}
}

void pic_programmer::reset()
{
	// off/on if on
	if(isPicPowered()) 
	{
		setPower(false);
		setPower(true);
	}
	// turn on if off
	else 
	{
		setPower(true);
	}
}

uint16_t pic_programmer::readMemory(const bool static_timing)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered() && !static_timing) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return 0;
	}
	else if(isPicPowered() && static_timing) 
	{
		dbg::out(dbg::warning) << "PIC is powered and static timing selected." << std::endl;
		return 0;
	}
	
	// xx000100
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x04);

	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_GET_RESPONSE);
	
	if(static_timing) 
	{
		fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_START_AND_TRANSMIT) |
			(1 << fault_fpga_spartan6::PIC_CONTROL_GET_RESPONSE));
			
		pic_powered = true;
	}
	else 
	{
		fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT) | 
			(1 << fault_fpga_spartan6::PIC_CONTROL_GET_RESPONSE));
	}
	
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_GET_RESPONSE);
	
	// read data
	uint8_t i1 = fpga->readRegister(fault_fpga_spartan6::PIC_DATA_OUT_L);
	uint8_t i2 = fpga->readRegister(fault_fpga_spartan6::PIC_DATA_OUT_H);
	
	return (static_cast<uint16_t>(i2) << 8) | i1;
}

void pic_programmer::writeMemory(const uint16_t word)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	
	if(isInConfigMemory())
	{
		dbg::out(dbg::warning) << "PIC in config mode." << std::endl;
		return;
	}
	
	// load data for program memory
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x02);
		
	// set data
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_L, (word << 1) & 0xff);
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_H, (word >> 7) & 0x7f);
	
	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT) | 
			(1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);

	// begin programming (internally timed)
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x08);

	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	
	// wait Tprog1
	usleep(10e3);
}

void pic_programmer::writePrepareMemory(const uint16_t word)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	
	if(isInConfigMemory())
	{
		dbg::out(dbg::warning) << "PIC in config mode." << std::endl;
		return;
	}
	
	// load data for program memory
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x02);
		
	// set data
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_L, (word << 1) & 0xff);
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_H, (word >> 7) & 0x7f);
	
	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT) | 
			(1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
}

void pic_programmer::writeProgramMemory(const bool static_timing)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered() && !static_timing) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	else if(isPicPowered() && static_timing) 
	{
		dbg::out(dbg::warning) << "PIC is powered and static timing selected." << std::endl;
		return;
	}
	
	if(isInConfigMemory())
	{
		dbg::out(dbg::warning) << "PIC in config mode." << std::endl;
		return;
	}
	
	// begin programming (internally timed)
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x08);

	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	
	// wait Tprog1
	usleep(10e3);
}

void pic_programmer::writeConfigMemory(const uint16_t word, const unsigned int addr)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	
	// Go to config mode
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x00);
		
	// set data
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_L, (word << 1) & 0xff);
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_H, (word >> 7) & 0x7f);

	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT) | 
		(1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	
	pic_in_config = true;
	
	// go to addr
	for(unsigned int i = 0; i < addr; i++) {
		nextMemoryAddress();
	}
	
	// begin programming (internally timed)
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x08);

	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	
	// wait Tprog1
	usleep(10e3);
	
}	
	
void pic_programmer::nextMemoryAddress()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	
	// Next address
	// xx000110
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x06);
	
	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);

	pic_addr++;
}

void pic_programmer::bulkErase()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}

	// xx000000
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x09);
	
	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 0);
	
	// wait TERA
	usleep(10e3);
	
	return;
}

void pic_programmer::useConfigMemory()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(!isPicPowered()) 
	{
		dbg::out(dbg::warning) << "PIC is not powered." << std::endl;
		return;
	}
	
	// xx000000
	fpga->writeRegister(fault_fpga_spartan6::PIC_COMMAND, 0x00);
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_L, 0xfe);
	fpga->writeRegister(fault_fpga_spartan6::PIC_DATA_IN_H, 0x7f);
	
	// start sending
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, (1 << fault_fpga_spartan6::PIC_CONTROL_TRANSMIT) | 
		(1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA));
	fpga->writeRegister(fault_fpga_spartan6::PIC_CONTROL, 1 << fault_fpga_spartan6::PIC_CONTROL_HAS_DATA);
	
	pic_in_config = true;
}
