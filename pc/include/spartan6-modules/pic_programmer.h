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

#ifndef __pic_programmer_h__
#define __pic_programmer_h__

// C includes

// C++ includes

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>

// Forward declarations
class processing_chain;

/**
 * @brief PIC programming via Spartan6
 */
class pic_programmer
{
	public:
		/**
		 * Constructor
		 */
		pic_programmer();
		
		/**
		 * Destructor
		 */
		virtual ~pic_programmer();
		
		/**
		 * Check if PIC is turned on
		 * @return true if PIC is powered
		 */
		bool isPicPowered() const {
			return pic_powered;
		};
		
		/**
		 * Check if PIC is currently accessing config memory
		 * @return true if PIC is in config memory space
		 */
		bool isInConfigMemory() const {
			return pic_in_config;
		};
		
		/**
		 * Switch power state of PIC
		 * @param on If true, PIC is powered up, else powered down
		 */
		void setPower(const bool on);
		
		/**
		 * Reset PIC by powering down/up
		 */
		void reset();
		
		/**
		 * Read one word from PIC program/config memory
		 * @param static_timing Power-up PIC before command with static timing
		 * @return 16-bit of program memory (14 LSBits are valid)
		 */
		uint16_t readMemory(const bool static_timing = false);
		
		/**
		 * Write one word to PIC program memory
		 * @param word 16-bit of program memory (14 LSBits are written)
		 */
		void writeMemory(const uint16_t word);
		
		/**
		 * Prepare one word to write
		 * @param word 16-bit of program memory (14 LSBits are written)
		 */
		void writePrepareMemory(const uint16_t word);
		
		/**
		 * Program one prepared word to PIC program memory
		 * @param static_timing Power-up PIC before command with static timing
		 */
		void writeProgramMemory(const bool static_timing = false);
		
		/**
		 * Write one word to PIC config memory
		 * @warning To access the program memory after this call, reset() has to be
		 *          issued before
		 * @param word 16-bit of config memory (14 LSBits are written)
		 * @param addr Address to write to
		 */
		void writeConfigMemory(const uint16_t word, const unsigned int addr);
		
		/** 
		 * Increment current memory address
		 */
		void nextMemoryAddress();
		
		/** 
		 * Bulk erase complete memory
		 */
		void bulkErase();
		
		/**
		 * Helper to select config memory for subsequent calls to
		 * readMemory(), writeMemory() and nextMemoryAddress()
		 */
		void useConfigMemory();
	protected:
	private:		
		/** 
		 * Power state of PIC
		 */
		bool pic_powered;
		
		/**
		 * Current address in PIC memory
		 */
		unsigned int pic_addr;
		
		/**
		 * Currently in config memory?
		 */
		bool pic_in_config;
};
 
#endif
