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

#ifndef __fault_fpga_spartan6__
#define __fault_fpga_spartan6__

#include <util.h>
#include <usb.h>
#include <value_locked.h>
#include <dbg.h>

/**
 * @brief Fault injection VHDL control class for Spartan6
 *
 * Control class for fault FPGA for Spartan6
 */
class fault_fpga_spartan6
{
private:
	/**
	 * Class constructor
	 * @param _f_clk Clock frequency of FPGA
	 */
	fault_fpga_spartan6(const double _f_clk = 100e6);
	
	/**
	 * Copy constructor
	 * @param _f_clk Clock frequency of FPGA
	 */
	fault_fpga_spartan6(const fault_fpga_spartan6&) { };

	/**
	 * Destructor
	 */
	virtual ~fault_fpga_spartan6();
	
	/**
	 * Instance for singleton
	 */
	static value_locked<fault_fpga_spartan6*> inst;
public:
	/**
	 * Get singleton instance
	 */
	 static fault_fpga_spartan6* instance();
	 
	 /**
	  * Cleanup singleton instance
	  */
	static void destroy();
	
	/**
	 * Data buffer type
	 */
	typedef std::vector<uint8_t> buffer_t;

	/**
	 * Open connection
	 * @param name Device name to open
	 * @return true on success, else false
	 * @note Call init_defaults afterwards to set configuration to defaults
	 */
	bool open(const std::string& name);

	/**
	 * Close connection
	 */
	void close();

	/**
	 * Init FPGA config registers
	 * @return true on success, else false
	 */
	bool init_defaults();

	/**
	 * FPGA commands
	 */
	enum {
		FPGA_READ_REGISTER = 0x01,
		FPGA_WRITE_REGISTER = 0x02,
		FPGA_RESET = 0x03
	};
	
	/**
	 * FPGA registers
	 */
	enum {
		// R only
		SC_STATUS = 3,
		SC_DATA_OUT = 4,
		PIC_DATA_OUT_L = 5,
		PIC_DATA_OUT_H = 6,
		FI_STATUS = 7,
		FI_DATA_OUT = 8,
		SC_DATA_OUT_COUNT = 9,
		SC_DATA_IN_COUNT = 10,
		DDR_DMA_IN_L = 11,
		THRESHOLD_STATUS = 12,
		MILLER_STATUS = 16,
		DDR_SINGLE_READ = 17,
		DDR_STATUS = 18,
		DDR_DMA_IN_H = 19,
		// R/W
		SC_CONTROL = 34,
		SC_DATA_IN = 35,
		PIC_CONTROL = 36,
		PIC_COMMAND = 37,
		PIC_DATA_IN_L = 38,
		PIC_DATA_IN_H = 39,
		DAC_V_LOW = 40,
		DAC_V_HIGH = 41,
		FI_CONTROL = 42,
		FI_DATA_IN = 43,
		FI_ADDR_L = 44,
		FI_ADDR_H = 45,
		DAC_V_OFF = 46,
		FI_TRIGGER_CONTROL = 47,
		DAC_CONTROL = 48,
		THRESHOLD_CONTROL = 49,
		MILLER_DATA_IN = 53,
		MILLER_OMIT_COUNT = 54,
		MILLER_CONTROL = 55,
		DDR_CONTROL = 56,
		DDR_SINGLE_WRITE = 57,
		DDR_ADDRESS = 58,
		DDR_DATA_COUNT = 59,
		DETECTOR_PATTERN = 60,
		THRESHOLD_VALUE = 61,
		DETECTOR_DEBUG = 62,
		DETECTOR_PATTERN_SAMPLE_COUNT = 63,
	};
	
	/** 
	 * DDR control register bits
	 */
	enum {
		DDR_CONTROL_WRITE_COMMIT = 0,
		DDR_CONTROL_READ_COMMIT = 1,
		DDR_CONTROL_SLAVE_FIFO_START = 2,
		DDR_CONTROL_RESET = 3,
		DDR_CONTROL_DMA_SOFTWARE_WRITE_START = 4,
		DDR_CONTROL_DMA_IN_SEL0 = 5,
		DDR_CONTROL_DMA_IN_SEL1 = 6
	};
	
	/** 
	 * DDR status register bits
	 */
	enum {
		DDR_STATUS_DMA = 6
	};
	
	/** 
	 * Smartcard control register bits
	 */
	enum {
		SC_CONTROL_POWER = 0,
		SC_CONTROL_TRANSMIT = 1
	};
	
	/** 
	 * Smartcard status register bits
	 */
	enum {
		SC_STATUS_POWERED = 0,
		SC_STATUS_POWERING_UP = 1,
		SC_STATUS_TRANSMITTING = 2,
		SC_STATUS_WAITING = 3,
		SC_STATUS_DECODING = 4
	};
	
	/** 
	 * PIC programmer control register bits
	 */
	enum {
		PIC_CONTROL_HAS_DATA = 0,
		PIC_CONTROL_GET_RESPONSE = 1,
		PIC_CONTROL_TRANSMIT = 2,
		PIC_CONTROL_PROG_STARTSTOP = 3,
		PIC_CONTROL_START_AND_TRANSMIT = 4
	};
	
	/** 
	 * DAC control register bits
	 */
	enum {
		DAC_ENABLE = 0,
		DAC_TEST_MODE = 1,
		DAC_RFID_MODE = 2
	};
	
	/** 
	 * ADC control register bits
	 */
	enum {
		THRESHOLD_CONTROL_ARM = 0,
		THRESHOLD_CONTROL_COARSE_TRIGGER_EN = 1,
		THRESHOLD_CONTROL_SOFTWARE_TRIGGER = 2,
	};
	
	/** 
	 * ADC status register bits
	 */
	enum {
		THRESHOLD_STATUS_ARMED = 0,
	};
	
	/** 
	 * FI control register bits
	 */
	enum {
		FI_CONTROL_W_EN = 0,
		FI_CONTROL_ARM = 1,
		FI_CONTROL_TRIGGER = 2
	};
	
	/** 
	 * FI trigger control register bits
	 */
	enum {
		FI_TRIGGER_CONTROL_PIC = 0,
		FI_TRIGGER_CONTROL_RFID = 1,
		FI_TRIGGER_CONTROL_EXT1 = 2,
		FI_TRIGGER_CONTROL_ADC = 3,
		FI_TRIGGER_CONTROL_SC_SENT = 4,
		FI_TRIGGER_CONTROL_SC_START_SEND = 5
	};
	
	/** 
	 * FI status register bits
	 */
	enum {
		FI_STATUS_READY = 0,
		FI_STATUS_ARMED = 1
	};
	
	/**
	 * Miller control register bits
	 */
	enum {
		MILLER_CONTROL_TRANSMIT = 0
	};
	
	
	/**
	 * Miller status register bits
	 */
	enum {
		MILLER_STATUS_TRANSMITTING = 0
	};
	
	/**
	 * FPGA result codes
	 */
	enum {
		FPGA_SUCCESS = 0x00,
		FPGA_FAILURE = 0xff
	};
	
	/** 
	 * Begin and number of readable/writable registers
	 */
	enum {
		FPGA_REG_READ_BEGIN = 0,
		FPGA_REG_WRITE_BEGIN = 32,
		FPGA_REG_READ_COUNT = 32+64,
		FPGA_REG_WRITE_COUNT = 64
	};
	
	/** 
	 * Hardware reset of FPGA
	 * @return true on success, else false
	 */
	bool resetFpga();
	
	/** 
	 * Read register of FPGA
	 * @param reg Register index between FPGA_REG_READ_BEGIN and FPGA_REG_READ_BEGIN + FPGA_REG_READ_COUNT - 1
	 * @return Value of register
	 */
	uint8_t readRegister(const uint8_t reg);
	
	/** 
	 * Write register of FPGA
	 * @param reg Register index between FPGA_REG_WRITE_BEGIN and FPGA_REG_WRITE_BEGIN + FPGA_REG_WRITE_COUNT - 1
	 * @param value Value to write
	 * @return true on success, else false
	 */
	bool writeRegister(const uint8_t reg, const uint8_t value);
	
	/** 
	 * Generate rising edge on bit in an register of FPGA
	 * @param reg Register index between FPGA_REG_WRITE_BEGIN and FPGA_REG_WRITE_BEGIN + FPGA_REG_WRITE_COUNT - 1
	 * @param bit Bit to affect
	 * @return true on success, else false
	 */
	bool risingEdgeRegister(const uint8_t reg, const unsigned int bit);
	
	/** 
	 * Set/clear bit in register
	 * @param reg Register index between FPGA_REG_WRITE_BEGIN and FPGA_REG_WRITE_BEGIN + FPGA_REG_WRITE_COUNT - 1
	 * @param bit Bit to affect
	 * @param v Value to set
	 * @return true on success, else false
	 */
	bool setBitRegister(const uint8_t reg, const unsigned int bit, const bool v);
	
	/**
	  * Helper to send raw command
	  * @param frame Raw binary data to send
	  * @param timeout Timeout in ms
	  * @return Number of bytes written, -1 on error
	  */
	int send_raw_command(const buffer_t& frame, const unsigned int timeout = 1000);

	/**
	 * Read response
	 * @param result Reference to result storage
	 * @param timeout Timeout in ms
	 * @return Number of bytes read, or -1 on error
	 */
	int read_result(buffer_t& result, const unsigned int timeout = 1000);

	/**
	 * Read response with N byte
	 * @param result Reference to result storage
	 * @param n Number of bytes expected
	 * @param timeout Timeout in ms (for a single read!)
	 * @param max_reads Maximum number of single read attempts, -1 for infinite attempts
	 * @return Number of bytes read, or -1 on error
	 */
	int read_result_n(buffer_t& result, const unsigned int n, const unsigned int timeout = 200,
		const int max_reads = 200);
	
	/**
	 * Connection state
	 * @return true if connection established
	 */
	const bool& isConnected() const 
	{
		return connected;
	}
	
	/**
	 * Helper to get last libusb error
	 * @return Error string
	 */
	std::string getLastError() const 
	{
		return std::string(usb_strerror());
	};
	
	/**
	  * Dump HEX buffer
	  * @param o Stream to write to
	  * @param buf Buffer to dump
	  */
	void hexdump(std::ostream& o, const buffer_t& buf);

	/**
	  * Dump HEX array
	  * @param o Stream to write to
	  * @param buf Array to dump
	  * @param length Number of bytes to dump
	  */
	void hexdump(std::ostream& o, const uint8_t* buf, const unsigned int length);
	

	const double& getFClk() const {
		return f_clk;
	};
	
	const double getNsToPoint() const {
		return f_clk/1e9;
	};
	
	usb_dev_handle* getUsbHandle() {
		return handle;
	}
	
protected:
	/**
	 * USB device
	 */
	struct usb_device* device;
	
	/**
	 * USB device handle
	 */
	usb_dev_handle* handle;
	
	/**
	 * FPGA clock frequency
	 */
	double f_clk;
	
	/**
	 * Connection state
	 */
	bool connected;
	
	/**
	 * Helper to find device
	 * @param name Device name to open
	 * @return true on success, else false
	 */
	bool findDevice(const std::string& name);

private:
};
#endif // __fault_fpga_spartan6__
