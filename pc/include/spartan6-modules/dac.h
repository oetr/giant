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

#ifndef __dac_h__
#define __dac_h__

// C includes

// C++ includes
#include <vector>
#include <utility>

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>

// Forward declarations

/**
 * @brief DAC controller for Spartan6
 */
class dac
{
	public:
		/**
		 * Constructor
		 */
		dac();
		
		/**
		 * Destructor
		 */
		virtual ~dac();
		
		/**
		 * Set upper (high) voltage
		 * @param v Value to set
		 */
		void setHighVoltage(const uint8_t v);
		
		/**
		 * Set lower (low) voltage
		 * @param v Value to set
		 */
		void setLowVoltage(const uint8_t v);
		
		/**
		 * Set off (inactive) voltage
		 * @param v Value to set
		 */
		void setOffVoltage(const uint8_t v);
		
		/**
		 * Add a pulse to the list of pulses to generate
		 * @param offset Offset in ns with respect to previous pulse/trigger
		 * @param width Width in ns
		 */
		void addPulse(const double offset, const double width);
		
		/**
		 * Clear pulse memory
		 */
		void clearPulses();
		
		/**
		 * Write 8-bit directly to FI memory
		 * @param addr 14-bit memory address
		 * @param v 8-bit value to write
		 */
		void writeMemory8(const uint16_t addr, const uint8_t v);
		
		/**
		 * Read 8-bit directly from FI memory
		 * @param addr 14-bit memory address to read
		 * @return Value at addr
		 */
		uint8_t readMemory8(const uint16_t addr);
		
		/**
		 * Write 32-bit directly to FI memory
		 * @param addr 12-bit memory address (adressing in 32-bit steps)
		 * @param v 32-bit value to write
		 */
		void writeMemory32(const uint16_t addr, const uint32_t v);
		
		/**
		 * Arm DAC for fault injection
		 */
		void arm();
		
		/**
		 * Force (software) trigger
		 */
		void softwareTrigger();
		
		/**
		 * Get status
		 * @return 8-bit status word
		 */
		uint8_t getStatus();
		
		/**
		 * Enable/disable specific trigger source
		 * @param src Number in trigger control register, e.g., FI_TRIGGER_CONTROL_PIC
		 * @param state true to enable, false to disable source
		 */
		void setTriggerEnableState(const unsigned int src, const bool state);
		
		/**
		 * Set state of DAC
		 * @param on True to enable DAC, otherwise false
		 */
		void setEnabled(const bool on);

		/**
		 * Get state of DAC
		 */
		bool getEnabled();
		
		/**
		 * Set test mode state of DAC
		 * @param on True to enable test mode, otherwise false
		 */
		void setTestModeEnabled(const bool on);
		
		/**
		 * Control RFID mode of DAC
		 * @param on True to enable RFID mode, otherwise false
		 */
		void setRfidModeEnabled(const bool on);
	protected:
	private:		
		/**
		 * Vector of configured pulses
		 */
		std::vector<std::pair<uint32_t, uint32_t> > pulses;
};
 
#endif
