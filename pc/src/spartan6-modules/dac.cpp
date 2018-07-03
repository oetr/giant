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

#include <dac.h>

dac::dac()
{
}

dac::~dac()
{
}

void dac::setHighVoltage(const uint8_t v)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_V_HIGH, v);
	
	return;
}

void dac::setLowVoltage(const uint8_t v)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_V_LOW, v);
	
	return;
}

void dac::setOffVoltage(const uint8_t v)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_V_OFF, v);
	
	return;
}

void dac::addPulse(const double offset, const double width)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	uint32_t offset_p = static_cast<uint32_t>(fpga->getNsToPoint() * offset);
	uint32_t width_p = static_cast<uint32_t>(fpga->getNsToPoint() * width);
	
	const uint32_t min_offset = 3;
	const uint32_t min_width = 1;
	
	if(offset_p < min_offset) {
		dbg::out(dbg::warning)  << "Requested delay shorter than minimum, truncating to minimum" << std::endl;
		offset_p = min_offset;
	}
	
	offset_p -= min_offset;
	
	if(width_p < min_width) {
		dbg::out(dbg::warning)  << "Requested width shorter than minimum, truncating to minimum" << std::endl;
		width_p = min_width;
	}
	
	width_p -= min_width;
	
	// add to list
	pulses.push_back(std::make_pair(offset_p, width_p));
	
	// overwrite existing config memory
	uint32_t mem_end = 2*pulses.size() + 2;
	uint32_t fi_config = mem_end << 16 | 0x0;
	writeMemory32(0, fi_config);
	
	// overwrite pulse memory
	for(unsigned int p = 0; p < pulses.size(); p++) 
	{
		// offset
		writeMemory32(p*2+2, pulses[p].first);
		// width
		writeMemory32(p*2+2+1, pulses[p].second);
	}
	
	return;
}

void dac::clearPulses()
{
	// clear list
	pulses.clear();
	
	// overwrite existing config memory
	uint32_t mem_end = 2*pulses.size() + 2;
	uint32_t fi_config = mem_end << 16 | 0x0;
	writeMemory32(0, fi_config);
	
	return;
}

void dac::writeMemory8(const uint16_t addr, const uint8_t v)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// set address
	fpga->writeRegister(fault_fpga_spartan6::FI_ADDR_L, addr & 0xff);
	fpga->writeRegister(fault_fpga_spartan6::FI_ADDR_H, (addr >> 8) & 0x7);
	
	// set data to write
	fpga->writeRegister(fault_fpga_spartan6::FI_DATA_IN, v);
	
	// write data
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 1 << fault_fpga_spartan6::FI_CONTROL_W_EN);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0);
	
	return;
}

uint8_t dac::readMemory8(const uint16_t addr)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::FI_ADDR_L, addr & 0xff);
	fpga->writeRegister(fault_fpga_spartan6::FI_ADDR_H, (addr >> 8) & 0x7);
	
	// get data
	return fpga->readRegister(fault_fpga_spartan6::FI_DATA_OUT);
}

void dac::writeMemory32(const uint16_t addr, const uint32_t v)
{
	//dbg::out(dbg::info)  << std::hex << addr << " <= " << v << std::endl;
	
	for(uint16_t b = 0; b < 4; b++) 
	{
		writeMemory8(4*addr + b, (v >> (8*b)) & 0xff);
	}
	
	return;
}

void dac::arm()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0x00);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 1 << fault_fpga_spartan6::FI_CONTROL_ARM);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0x00);
	
	return;
}

void dac::softwareTrigger()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0x00);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 1 << fault_fpga_spartan6::FI_CONTROL_TRIGGER);
	fpga->writeRegister(fault_fpga_spartan6::FI_CONTROL, 0x00);
	
	return;
}

uint8_t dac::getStatus()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->readRegister(fault_fpga_spartan6::FI_STATUS);
}

void dac::setTriggerEnableState(const unsigned int src, const bool state)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	uint8_t current_state = fpga->readRegister(fault_fpga_spartan6::FI_TRIGGER_CONTROL);
	
	if(state) 
	{
		current_state |= (1 << src);
	}
	else 
	{
		current_state &= ~(1 << src);
	}
	
	fpga->writeRegister(fault_fpga_spartan6::FI_TRIGGER_CONTROL, current_state);
	
	return;
}

void dac::setTestModeEnabled(const bool on)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	uint8_t current_state = fpga->readRegister(fault_fpga_spartan6::DAC_CONTROL);
	
	if(on) 
	{
		current_state |= (1 << fault_fpga_spartan6::DAC_TEST_MODE);
	}
	else 
	{
		current_state &= ~(1 << fault_fpga_spartan6::DAC_TEST_MODE);
	}
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_CONTROL, current_state);
	
	return;
}

void dac::setRfidModeEnabled(const bool on)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	uint8_t current_state = fpga->readRegister(fault_fpga_spartan6::DAC_CONTROL);
	
	if(on) 
	{
		current_state |= (1 << fault_fpga_spartan6::DAC_RFID_MODE);
	}
	else 
	{
		current_state &= ~(1 << fault_fpga_spartan6::DAC_RFID_MODE);
	}
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_CONTROL, current_state);
	
	return;
}

void dac::setEnabled(const bool on)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	uint8_t current_state = fpga->readRegister(fault_fpga_spartan6::DAC_CONTROL);
	
	if(on) 
	{
		current_state |= (1 << fault_fpga_spartan6::DAC_ENABLE);
	}
	else 
	{
		current_state &= ~(1 << fault_fpga_spartan6::DAC_ENABLE);
	}
	
	fpga->writeRegister(fault_fpga_spartan6::DAC_CONTROL, current_state);
	
	return;
}

bool dac::getEnabled()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->readRegister(fault_fpga_spartan6::DAC_CONTROL);
}
