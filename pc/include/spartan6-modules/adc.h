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

#ifndef __adc_h__
#define __adc_h__

// C includes

// C++ includes
#include <vector>
#include <utility>

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>

// Forward declarations

/**
 * @brief ADC controller for Spartan6
 */
class adc
{
	public:
		/**
		 * Constructor
		 */
		adc();
		
		/**
		 * Destructor
		 */
		virtual ~adc();
		
		/**
		 * Get status
		 * @return 8-bit status word
		 */
		uint8_t getStatus();
		
		/**
		 * Set pattern detector threshold
		 * @param t 16-bit threshold
		 * @return true on success, else false
		 */
		bool setDetectorThreshold(const uint16_t t);
		
		/**
		 * Arm ADC recording
		 * @return true on success, else false
		 */
		bool arm();
		
		/**
		 * Force trigger from software
		 * @return true on success, else false
		 */
		bool softwareTrigger();
		
		/**
		 * ADC trigger armed?
		 * @return true if ADC trigger armed
		 */
		bool isArmed();

		/**
		 * En/Disable coarse triggering on fi_trigger
		 * @param s State of coarse triggering, true to enable
		 * @return true on success, else false
		 */
		bool setCoarseTrigger(const bool s);
		
		/**
		 * Set pattern detector pattern
		 * @param p Pattern of 64 uint8_t samples
		 * @return true on success, else false
		 */
		bool setDetectorPattern(const std::vector<uint8_t>& p);

		
	protected:
	private:		
};
 
#endif
