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

#include <ddr.h>

ddr::ddr()
{

}

ddr::~ddr()
{

}

uint8_t ddr::getStatus()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	return fpga->readRegister(fault_fpga_spartan6::DDR_STATUS); 
}

bool ddr::setAddress(const uint32_t addr)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	bool result = true;
	
	// Set address, MSByte first
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_ADDRESS, (addr >> 24) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_ADDRESS, (addr >> 16) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_ADDRESS, (addr >> 8) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_ADDRESS, addr & 0xff);
	
	return result;
}

bool ddr::setBlockCount(const uint32_t count)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	bool result = true;
	
	// Set count, MSByte first
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_DATA_COUNT, (count >> 16) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_DATA_COUNT, (count >> 8) & 0xff);
	result &= fpga->writeRegister(fault_fpga_spartan6::DDR_DATA_COUNT, count & 0xff);
	
	return result;
}

uint32_t ddr::readSingleWord(const uint32_t addr)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// read address
	setAddress(addr);
	
	// Do read commit
	fpga->risingEdgeRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_READ_COMMIT);
		
	uint32_t result = 0;
	
	for(unsigned int i = 0; i < 4; i++)
	{
		result |= (fpga->readRegister(fault_fpga_spartan6::DDR_SINGLE_READ)) << (8*i); 
	}
	
	return result;
}

bool ddr::reset()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// Set and clear reset flag
	bool result = true;
	
	result &= fpga->setBitRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_RESET, true);
		
	result &= fpga->setBitRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_RESET, false);
		
	return result;
}

bool ddr::writeSingleWord(const uint32_t addr, const uint32_t data)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// write address
	setAddress(addr);
	
	// Write 16 byte of data (MSB shift in first)
	for(int i = 3; i >= 0; i--)
	{
		fpga->writeRegister(fault_fpga_spartan6::DDR_SINGLE_WRITE,
			(data >> (8*i)) & 0xff); 
	}
	
	// Do write commit
	return fpga->risingEdgeRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_WRITE_COMMIT);
	
}

ddr::buffer_t ddr::readBurst(const uint32_t addr, const size_t amount_req)
{
	const unsigned int block_size = 64;
	
	size_t amount = amount_req;
	
	if(amount_req % block_size != 0)
	{
		amount = (amount_req/block_size)*block_size;
		dbg::out(dbg::info) << "ddr::readBurst(): Amount truncated to " << 
			std::dec << amount << std::endl;
	}
	
	buffer_t result;
	result.resize(amount, 0);
	
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// Start address
	setAddress(addr);
	
	// Compute and set block count
	const uint32_t blocks = amount/block_size;
	setBlockCount(blocks);
	
	// Trigger FIFO read mode
	fpga->risingEdgeRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_SLAVE_FIFO_START);
		
	// Read data...
	int read_tmp = -1, read_total = 0;
	const unsigned int BUFFER_SIZE = 64*1024;
	const unsigned int BUFFER_SIZE_REAL = BUFFER_SIZE > amount*4 ? amount*4 : BUFFER_SIZE;
	
	char* buf = new char[BUFFER_SIZE_REAL];
	
	do
	{
		read_tmp = usb_bulk_read(fpga->getUsbHandle(), 0x86, buf, BUFFER_SIZE_REAL, 2000);
		if(read_tmp < 0)
		{
			dbg::out(dbg::error) << "ddr::readBurst(): Could not read: " << fpga->getLastError() << std::endl;
		}
		else if(read_tmp % 4)
		{
			dbg::out(dbg::error) << "ddr::readBurst(): read_tmp not /4: " << std::dec << read_tmp << std::endl;
		}
		else
		{
			for(int i = 0; i < read_tmp/4; i++)
			{
				result[i + read_total] = 0;
				result[i + read_total] |= static_cast<uint32_t>(buf[4*i]) & 0x000000ff;
				result[i + read_total] |= (static_cast<uint32_t>(buf[4*i+1]) << 8)  & 0x0000ff00;
				result[i + read_total] |= (static_cast<uint32_t>(buf[4*i+2]) << 16) & 0x00ff0000;
				result[i + read_total] |= (static_cast<uint32_t>(buf[4*i+3]) << 24) & 0xff000000;
			}
			
			read_total += read_tmp/4;
		}
	} while(read_tmp > 0 && read_total < static_cast<int>(amount));	
	
	delete [] buf;
	
	return result;
}

bool ddr::prepareDmaWrite(const uint32_t addr, const size_t amount_req)
{
	bool result = true;
	const unsigned int block_size = 128;
	
	size_t amount = amount_req;
	
	if(amount_req % block_size != 0)
	{
		amount = (amount_req/block_size)*block_size;
		dbg::out(dbg::info) << "ddr::startDmaWrite(): Amount truncated to " << 
			std::dec << amount << std::endl;
	}
	
	// Start address
	result &= setAddress(addr);
	
	// Compute and set block count
	const uint32_t blocks = amount/block_size;
	result &= setBlockCount(blocks);
		
	return result;
}

bool ddr::triggerDmaWrite()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// Trigger DMA write
	return fpga->risingEdgeRegister(fault_fpga_spartan6::DDR_CONTROL,
		fault_fpga_spartan6::DDR_CONTROL_DMA_SOFTWARE_WRITE_START);
}

bool ddr::setDmaInput(const uint8_t s)
{
	bool result = true;
	
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	result &= fpga->setBitRegister(fault_fpga_spartan6::DDR_CONTROL,
			fault_fpga_spartan6::DDR_CONTROL_DMA_IN_SEL0, s & 0x1);
	
	result &= fpga->setBitRegister(fault_fpga_spartan6::DDR_CONTROL,
			fault_fpga_spartan6::DDR_CONTROL_DMA_IN_SEL1, s & 0x2);
			
	return result;
}
