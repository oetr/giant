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

#ifndef __ddr_h__
#define __ddr_h__

// C includes

// C++ includes

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>

// Forward declarations
class processing_chain;

/**
 * @brief DDR access on ZTEX module
 */
class ddr
{
	public:
		/**
		 * Constructor
		 */
		ddr();
		
		/**
		 * Destructor
		 */
		virtual ~ddr();
		
		/**
		 * Data buffer type
		 */
		typedef std::vector<uint32_t> buffer_t;
		
		/**
		 * Read 8-bit status
		 * @return Status byte
		 */
		uint8_t getStatus();
		
		/**
		 * Reset memory controller
		 * @note Does _not_ zero out DDR memory
		 * @return true on success, else false
		 */
		bool reset();
		
		/**
		 * Prepare DMA write
		 * @param addr 32-bit start address
		 * @param amount Number of 16-bit word to write (max. 64 MB)
		 * @return true on success, else false
		 */
		bool prepareDmaWrite(const uint32_t addr, const size_t amount_req);
		
		/**
		 * Software trigger for DMA write
		 * @return true on success, else false
		 */
		bool triggerDmaWrite();
		
		/**
		 * DMA input sources
		 */
		enum {
			DMA_IN_ADC = 0,
			DMA_IN_DETECTOR = 1,
		};
		
		/** 
		 * Set DMA input source
		 * @param s Input source to select
		 * @return true on success, else false
		 */
		bool setDmaInput(const uint8_t s);
		
		/**
		 * Set current memory address
		 * @param addr 32-bit address
		 * @return true on success, else false
		 */
		bool setAddress(const uint32_t addr);
		
		/**
		 * Set current block count (in multiples of 64 32-bit words)
		 * @param count Block count
		 * @return true on success, else false
		 */
		bool setBlockCount(const uint32_t count);
		
		/**
		 * Read one 32-bit word from DDR
		 * @param addr 32-bit address
		 * @return 32-bit memory word
		 */
		uint32_t readSingleWord(const uint32_t addr);
		
		/**
		 * Write one word to PIC program memory
		 * @param addr 32-bit address
		 * @param data 32-bit word to write
		 * @return true on success, else false
		 */
		bool writeSingleWord(const uint32_t addr, const uint32_t data);
		
		/**
		 * Read memory using fast slave FIFO interface
		 * @param addr 32-bit start address
		 * @param amount Number of 32-bit words to read (max. 64 MB)
		 * @return Read data
		 */
		buffer_t readBurst(const uint32_t addr, const size_t amount);
		
	protected:
	private:		
		
};
 
#endif
