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

#ifndef __smartcard_h__
#define __smartcard_h__

// C includes

// C++ includes
#include <vector>
#include <utility>

// Project includes
#include <fault_fpga_spartan6.h>
#include <dbg.h>
#include <util.h>

// Forward declarations

/**
 * @brief smartcard controller for Spartan6
 */
class smartcard
{
	public:
		/**
		 * Constructor
		 */
		smartcard();
		
		/**
		 * Destructor
		 */
		virtual ~smartcard();

		/**
		 * Enable/disable smartcard power
		 * @param on true to switch on, false to switch off
		 */
		void setPower(const bool on);
		
		/**
		 * Reset card, wait for ATR, and get response if any
		 * @return Answer-to-reset
		 */
		byte_buffer_t resetAndGetAtr();
		
		/**
		 * Read data currently in input buffer
		 * @return Data from rx buffer
		 */
		byte_buffer_t readRxData();
		
		/**
		 * Read T = 0 data, i.e., handle 61 xx APDU (GET_RESPONSE)
		 * @param tx Data to send
		 * @return Data received
		 */
		byte_buffer_t handleT0Command(const byte_buffer_t& tx);
		
		/**
		 * Send a command, wait for and read response
		 * @param tx Data to send
		 * @param timeout_attempts Number of attempts to receive data, 
		 *                         each attempt is ~ 1ms, pass 0 for infinite
		 * @return Data received
		 */
		byte_buffer_t handleRxTx(const byte_buffer_t& tx,
			const unsigned int timeout_attempts = 0);
		
		/**
		 * Construct a T=1 apdu
		 * @return Complete ADPU buffer
		 */
		static byte_buffer_t makeT1Apdu(const uint8_t cla, const uint8_t ins,
			const uint8_t p1, const uint8_t p2, const byte_buffer_t& data,
			const uint8_t le);
		
		
		
		/**
		 * Write data to output buffer
		 * @param tx Data to write to tx buffer
		 */
		void writeTxData(const byte_buffer_t& tx);
		
		/**
		 * Transmit data currently in TX buffer
		 */
		void transmitTxData();
		
		/**
		 * Return true if card is not transmitting, waiting, or decoding
		 * @return true if ready, otherwise false
		 */
		const bool isReady();
		
		/**
		 * Is smartcard powered?
		 * @return true if powered, otherwise false
		 */
		const bool getPowered() const
		{
			return powered;
		};
		
		/**
		 * Get number of bytes pending in RX buffer
		 * @return #bytes in RX
		 */
		const unsigned int getRxPending();
		
		/**
		 * Get number of bytes pending in TX buffer
		 * @return #bytes in TX
		 */
		const unsigned int getTxPending();
		
		/**
		 * Get status
		 * @return 8-bit status word
		 */
		uint8_t getStatus();
		
	protected:
	private:		
		/**
		 * Smartcard powered?
		 */
		bool powered;
};
 
#endif
