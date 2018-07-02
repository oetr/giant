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

#include "fault_fpga_spartan6.h"

value_locked<fault_fpga_spartan6*> fault_fpga_spartan6::inst = 0;

fault_fpga_spartan6::fault_fpga_spartan6(const double _f_clk) : device(0), handle(0), f_clk(_f_clk), connected(false)
{
}

fault_fpga_spartan6::~fault_fpga_spartan6()
{
	close();
}

fault_fpga_spartan6* fault_fpga_spartan6::instance()
{
	if (!inst.get()) {
		inst.set(new fault_fpga_spartan6());
	}
	
	return inst.get();
}

void fault_fpga_spartan6::destroy()
{
	if (inst.get()) {
		delete inst.get();
	}
	inst.set(0);
}


void fault_fpga_spartan6::close()
{
	if(isConnected()) {
		usb_release_interface(handle, 0);
		usb_close(handle);
	}
}


uint8_t fault_fpga_spartan6::readRegister(const uint8_t reg)
{
	if(reg >= FPGA_REG_READ_BEGIN && reg < FPGA_REG_READ_BEGIN + FPGA_REG_READ_COUNT) {
		buffer_t cmd;
		cmd.push_back(FPGA_READ_REGISTER);
		cmd.push_back(reg);
		
		// Send request and check for error
		if(send_raw_command(cmd) < 0) {
			return 0;
		}
		
		// Get response, decode and check for errors
		buffer_t response;
		if(read_result(response) < 0) {
			return 0;
		}
		
		if(response.size() == 2 && response[0] == FPGA_SUCCESS) {
			return response[1];
		}
		else {
			dbg::out(dbg::error) << "fault_fpga_spartan6::readRegister(): Unexpected response: ";
			hexdump(dbg::out(dbg::error), response);
			dbg::out(dbg::error) << std::endl;
			return 0;
		}
	}
	else {
		dbg::out(dbg::error) << "fault_fpga_spartan6::readRegister(): Register " << static_cast<unsigned int>(reg) << " not readable" << std::endl;
		return 0;
	}
}
	
bool fault_fpga_spartan6::writeRegister(const uint8_t reg, const uint8_t value)
{
	if(reg >= FPGA_REG_WRITE_BEGIN && reg < FPGA_REG_WRITE_BEGIN + FPGA_REG_WRITE_COUNT) {
		buffer_t cmd;
		cmd.push_back(FPGA_WRITE_REGISTER);
		cmd.push_back(reg);
		cmd.push_back(value);
		
		// Send request and check for error
		if(send_raw_command(cmd) < 0) {
			return 0;
		}
		
		// Get response, decode and check for errors
		buffer_t response;
		if(read_result(response) < 0) {
			return 0;
		}
		
		if(response.size() == 1 && response[0] == FPGA_SUCCESS) {
			return true;
		}
		else {
			dbg::out(dbg::error) << "fault_fpga_spartan6::writeRegister(): Unexpected response: ";
			hexdump(dbg::out(dbg::error), response);
			dbg::out(dbg::error) << std::endl;
			return false;
		}
	}
	else {
		dbg::out(dbg::error) << "fault_fpga_spartan6::writeRegister(): Register " << static_cast<unsigned int>(reg) << " not writable" << std::endl;
		return false;
	}
}

bool fault_fpga_spartan6::risingEdgeRegister(const uint8_t reg, const unsigned int bit)
{
	if(bit < 8)
	{
		uint8_t current_state = readRegister(reg);
		
		// set bit to 0
		current_state &= ~(1 << bit);
		if(!writeRegister(reg, current_state))
		{
			return false;
		}
		
		// set bit to 1
		current_state |= (1 << bit);
		if(!writeRegister(reg, current_state))
		{
			return false;
		}
		
		// set bit to 0
		current_state &= ~(1 << bit);
		if(!writeRegister(reg, current_state))
		{
			return false;
		}
		
		return true;
	}
	else {
		dbg::out(dbg::error) << "fault_fpga_spartan6::risingEdgeRegister(): Bit " << std::dec << bit << " out of range" << std::endl;
		return false;
	}
}

bool fault_fpga_spartan6::setBitRegister(const uint8_t reg, 
	const unsigned int bit, const bool v)
{
	if(bit < 8)
	{
		uint8_t current_state = readRegister(reg);
		
		// clear bit
		if(!v)
		{
			current_state &= ~(1 << bit);
			if(!writeRegister(reg, current_state))
			{
				return false;
			}
		}		
		// set bit
		else
		{
			current_state |= (1 << bit);
			if(!writeRegister(reg, current_state))
			{
				return false;
			}
		}
		
		return true;
	}
	else {
		dbg::out(dbg::error) << "fault_fpga_spartan6::setBitRegister(): Bit " << std::dec << bit << " out of range" << std::endl;
		return false;
	}
}

bool fault_fpga_spartan6::resetFpga()
{	
	buffer_t cmd;
	cmd.push_back(FPGA_RESET);

	// Send request and check for error
	if(send_raw_command(cmd) < 0) {
		return 0;
	}
	
	// Get response, decode and check for errors
	buffer_t response;
	if(read_result(response) < 0) {
		return 0;
	}
	
	if(response.size() == 1 && response[0] == FPGA_SUCCESS) {
		return true;
	}
	else {
		dbg::out(dbg::error) << "fault_fpga_spartan6::resetFpga(): Unexpected response: ";
		hexdump(dbg::out(dbg::error), response);
		dbg::out(dbg::error) << std::endl;
		return false;
	}
}

bool fault_fpga_spartan6::open(const std::string& name)
{
	dbg::trace trace(DBG_HERE);
	
	if(isConnected()) {
		close();
	}
	
	// libusb init
	usb_init();                                        
    usb_find_busses();
    usb_find_devices();
	
	// find device
	if(!findDevice(name)) 
	{
		dbg::out(dbg::error) << "Could not find device '" << name << "'" << std::endl;
		return false;
	}
	else {
		dbg::out(dbg::info) << "Device found" << std::endl;
	}
	
	// configure & claim
	if (usb_set_configuration(handle, device->config[0].bConfigurationValue) < 0) {
		dbg::out(dbg::error) << "Error configuring: " << getLastError() << std::endl;
		usb_close(handle);
		return false;
    }
	else {
		dbg::out(dbg::info) << "Device configured" << std::endl;
	}
	
    if (usb_claim_interface(handle, 0) < 0) {
		dbg::out(dbg::error) << "Error claiming interface 0: " << getLastError() << std::endl;
		usb_close(handle);
		return false;
    }
	else {
		dbg::out(dbg::info) << "Interface claimed" << std::endl;
	}
	
	connected = true;
	return true;
}

bool fault_fpga_spartan6::findDevice(const std::string& name)
{
	const unsigned int BUFFER_SIZE = 256;
	char buf[BUFFER_SIZE];
	
    struct usb_bus* bus_search;
    struct usb_device* device_search;

    bus_search = ::usb_busses;
	
	// Loop over all busses
    while (bus_search != 0)
    {
		device_search = bus_search->devices;
		
		// Loop over all devices on bus
    	while (device_search != 0)
		{
			// Find EZ-USB
			if ((device_search->descriptor.idVendor == 0x221a) && (device_search->descriptor.idProduct == 0x100)) 
			{
				// Open handle
				handle = usb_open(device_search);
				
				// Get device name
				usb_get_string_simple(handle, device_search->descriptor.iProduct, buf, BUFFER_SIZE);
				std::string dev_name = buf;
				
				// Device with correct name found?
				if (dev_name == name) {
					device = device_search;
					return true;
				}
				
				usb_close(handle);
			}
			device_search = device_search->next;
		}
        bus_search = bus_search->next;
    }
    
	// No device found
	handle = 0;
	device = 0;
	
    return false;

}

int fault_fpga_spartan6::read_result(buffer_t& result, const unsigned int timeout)
{
	// clear first
	result.clear();
	
	const unsigned int BUFFER_SIZE = 256;
	char buf[BUFFER_SIZE];
	
	const int read = usb_bulk_read(handle, 0x82, buf, BUFFER_SIZE, timeout);
	if (read < 0) {
		dbg::out(dbg::error) << "fault_fpga_spartan6::read_result(): Could not write: " << getLastError() << std::endl;
		return -1;
	}
	else {
		// resize & copy
		result.resize(read, 0);
		
		std::copy(buf, buf + read, result.begin());
		
		return result.size();
	}
		
	return -1;
}

int fault_fpga_spartan6::read_result_n(buffer_t& result, const unsigned int n, const unsigned int timeout, const int max_reads)
{
	unsigned int read = 0;
	int attempt = 0;
	
	buffer_t result_tmp;
	
	result.clear();
	result.resize(n, 0);
	
	do {
		const int read_tmp = read_result(result_tmp, timeout);
		
		if(read_tmp > 0) 
		{
			for(int i = 0; i < read_tmp; i++)
				result[read + i] = result_tmp[i];
				
			read += read_tmp;
			attempt++;
		}
	} while (read < n && (attempt <= max_reads || max_reads < 0));
	
	return read;
}

int fault_fpga_spartan6::send_raw_command(const buffer_t& frame, const unsigned int timeout)
{
	// perform bulk write
	if(isConnected()) 
	{
		// convert to array
		char* frame_array = new char[frame.size()];
		
		if(!frame_array) {
			dbg::out(dbg::error) << "fault_fpga_spartan6::send_raw_command(): Could not alloc array" << std::endl;
			return -1;
		}
		
		// copy data
		std::copy(frame.begin(), frame.end(), frame_array);

		// write
		const int written = usb_bulk_write(handle, 0x04, frame_array, frame.size(), timeout);
		
		// cleanup
		delete [] frame_array;
		
		// error handling
		if (written < 0) {
			dbg::out(dbg::error) << "fault_fpga_spartan6::send_raw_command(): Could not write: " << getLastError() << std::endl;
			return -1;
		}
		
		return written;
	}
	else 
	{
		dbg::out(dbg::error) << "fault_fpga_spartan6::send_raw_command(): Not connected" << std::endl;
		return -1;
	}
}

void fault_fpga_spartan6::hexdump(std::ostream& o, const buffer_t& buf)
{
	for(unsigned int i = 0; i < buf.size(); i++) {
		o << "0x" << std::setw(2) << std::setfill('0') << std::hex << static_cast<unsigned int>(buf[i]) << " ";
	}
}

void fault_fpga_spartan6::hexdump(std::ostream& o, const uint8_t* buf, const unsigned int length)
{
	for(unsigned int i = 0; i < length; i++) {
		o << "0x" << std::setw(2) << std::setfill('0') << std::hex << static_cast<unsigned int>(buf[i]) << " ";
	}
}

bool fault_fpga_spartan6::init_defaults()
{
	// write defaults to config memory
	
	
	return true;
}

