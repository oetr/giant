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

#include <smartcard.h>

smartcard::smartcard() : powered(false)
{
}

smartcard::~smartcard()
{
}

void smartcard::setPower(const bool on)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// only switch power when not already in correct state
	if(on != getPowered())
	{
		// power smartcard
		fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 0);
		fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 
			1 << fault_fpga_spartan6::SC_CONTROL_POWER);
		fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 0);
	}
	
	powered = on;
}

const bool smartcard::isReady()
{
	uint8_t status = getStatus();
	if(
		status & (1 << fault_fpga_spartan6::SC_STATUS_TRANSMITTING) || 
		status & (1 << fault_fpga_spartan6::SC_STATUS_WAITING ) || 
		status & (1 << fault_fpga_spartan6::SC_STATUS_DECODING) 
	)
	{
		return false;
	}
	else 
	{
		return true;
	}
}

byte_buffer_t smartcard::resetAndGetAtr()
{
	// Reset
	setPower(false);
	setPower(true);
	
	// Wait for card becoming ready
	while(!isReady())
	{
		::usleep(1e3);
	}
	
	// read ATR
	byte_buffer_t result = readRxData();
	
	return result;
}

byte_buffer_t smartcard::readRxData()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	byte_buffer_t result;
	const unsigned int count = getRxPending();
	result.resize(count, 0);
	
	for(unsigned int i = 0; i < count; i++) 
	{
		const uint8_t byte = fpga->readRegister(fault_fpga_spartan6::SC_DATA_OUT);
		
		result[result.size() - 1 - i] = util::bitreverse(byte);
	}
	
	
	return result;
}

byte_buffer_t smartcard::handleT0Command(const byte_buffer_t& tx)
{
	bool response_valid = true;
	byte_buffer_t result;

	while(1)
	{
		// transmit
		writeTxData(tx);
		transmitTxData();
		
		// wait for data
		while(!isReady()) 
		{
			//dbg::out(dbg::info) << util::u8bs(getStatus() & 0x3f) << std::endl;
			::usleep(1e3);
		}
		
		//dbg::out(dbg::info) << "Read: " << getRxPending() << std::endl;
		result = readRxData();
		
		//util::hexdump(dbg::out(dbg::info), result);
		//dbg::out(dbg::info) << std::endl;
		
		if(result.size() >= 2 && result[0] == 0x60)
		{
			// re-transmit
			result.clear();
		}
		else if(result.size() >= 2 && result[0] == 0x61)
		{
			const uint8_t count = result[1];
			
			//dbg::out(dbg::info) << "Get: " << static_cast<int>(count) << std::endl;
			
			byte_buffer_t apdu_get_response;
			apdu_get_response.push_back(0x00);
			apdu_get_response.push_back(0xC0);
			apdu_get_response.push_back(0x00);
			apdu_get_response.push_back(0x00);
			apdu_get_response.push_back(count);
			
			// write get response
			writeTxData(apdu_get_response);
			transmitTxData();
			
			// wait for data
			while(!isReady()) 
			{
				::usleep(1e3);
			}
			
			result = readRxData();		
			response_valid = true;
			//dbg::out(dbg::info) << result.size() << std::endl;
			
			return result;
		}
		else
		{
			return result;
		}
		
	} 
	
	return result;
}

byte_buffer_t smartcard::handleRxTx(const byte_buffer_t& tx, 
	const unsigned int timeout_attempts)
{
	byte_buffer_t result;
	
	// transmit
	writeTxData(tx);
	transmitTxData();
	
	// counter for attempts
	unsigned int timeout_count = 0;
	
	// wait for data
	while(!isReady() && (timeout_attempts == 0 || timeout_count < timeout_attempts)) 
	{
		//dbg::out(dbg::info) << util::u8bs(getStatus() & 0x3f) << std::endl;
		::usleep(1e3);
		
		timeout_count++;
	}
	
	//dbg::out(dbg::info) << "Read: " << getRxPending() << std::endl;
	result = readRxData();
	
	return result;
}

void smartcard::writeTxData(const byte_buffer_t& tx)
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	// write (reversed)
	byte_buffer_t::const_reverse_iterator it;
	
	for(it = tx.rbegin(); it != tx.rend(); ++it)
	{
		fpga->writeRegister(fault_fpga_spartan6::SC_DATA_IN, *it);
	}
}

void smartcard::transmitTxData()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 0);
	fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 1 << fault_fpga_spartan6::SC_CONTROL_TRANSMIT);
	fpga->writeRegister(fault_fpga_spartan6::SC_CONTROL, 0);
}

byte_buffer_t smartcard::makeT1Apdu(const uint8_t cla, const uint8_t ins,
	const uint8_t p1, const uint8_t p2, const byte_buffer_t& data,
	const uint8_t le)
{
	byte_buffer_t apdu;
	
	// NAD PCB LEN CLA INS P1 P2 LC 16ByteAes LE EDC
	const uint8_t nad = 0;
	const uint8_t pcb = 0;
	const uint8_t len = 4 + 1 + data.size() + 1;
	const uint8_t lc = data.size();
	
	apdu.push_back(nad);
	apdu.push_back(pcb);
	apdu.push_back(len);
	apdu.push_back(cla);
	apdu.push_back(ins);
	apdu.push_back(p1);
	apdu.push_back(p2);
	apdu.push_back(lc);
	
	apdu.insert(apdu.end(), data.begin(), data.end());
	
	apdu.push_back(le);
	
	uint8_t edc = 0;
	for(unsigned int i = 0; i < apdu.size(); i++) {
		edc ^= apdu[i];
	}
	apdu.push_back(edc);
	
	return apdu;
}

const unsigned int smartcard::getRxPending()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	return fpga->readRegister(fault_fpga_spartan6::SC_DATA_OUT_COUNT);
}

const unsigned int smartcard::getTxPending()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	return fpga->readRegister(fault_fpga_spartan6::SC_DATA_IN_COUNT);
}

uint8_t smartcard::getStatus()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	return fpga->readRegister(fault_fpga_spartan6::SC_STATUS);
}


