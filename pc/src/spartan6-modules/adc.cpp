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

#include <adc.h>

adc::adc()
{
}

adc::~adc()
{
}

bool adc::arm()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->risingEdgeRegister(fault_fpga_spartan6::THRESHOLD_CONTROL, fault_fpga_spartan6::THRESHOLD_CONTROL_ARM);
}

bool adc::softwareTrigger()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->risingEdgeRegister(fault_fpga_spartan6::THRESHOLD_CONTROL, fault_fpga_spartan6::THRESHOLD_CONTROL_SOFTWARE_TRIGGER);
}

bool adc::isArmed()
{
	return (getStatus() & (1 << fault_fpga_spartan6::THRESHOLD_STATUS_ARMED));
}

uint8_t adc::getStatus()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->readRegister(fault_fpga_spartan6::THRESHOLD_STATUS);
}

bool adc::setDetectorThreshold(const uint16_t t)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	bool result = true;
	
	// Set value, MSByte first
	result &= fpga->writeRegister(fault_fpga_spartan6::THRESHOLD_VALUE, (t >> 8) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::THRESHOLD_VALUE, t & 0xff);
	
	return result;
}

bool adc::setCoarseTrigger(const bool s)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->setBitRegister(fault_fpga_spartan6::THRESHOLD_CONTROL, 
		fault_fpga_spartan6::THRESHOLD_CONTROL_COARSE_TRIGGER_EN, s);
}

bool adc::setDetectorPattern(const std::vector<uint8_t>& p)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	if(p.size() > 64)
	{
		dbg::out(dbg::error) << "adc::setDetectorPattern(): Need max. 64-value pattern" << std::endl;
		return false;
	}
	
	if(p.size() < 64)
	{
		dbg::out(dbg::info) << "adc::setDetectorPattern(): Pattern shorter than 64 samples" << std::endl;
	}
	
	// set pattern length
	bool result = true;
	result &= fpga->writeRegister(fault_fpga_spartan6::DETECTOR_PATTERN_SAMPLE_COUNT, p.size());
	
	for(unsigned int i = 0; i < p.size(); i++)
	{
		result &= fpga->writeRegister(fault_fpga_spartan6::DETECTOR_PATTERN, p[i]);
	}
	
	return result;
}

