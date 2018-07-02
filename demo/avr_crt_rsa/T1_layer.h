/*   
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
*/

#ifndef _T1_layer
#define _T1_layer


/***************************************************************************
 * 1. INCLUDES                                                             *  
 ***************************************************************************/

#include "global.h"

/***************************************************************************
 * 2. DEFINES                                                              *
 ***************************************************************************/

/***************************************************************************
 * 3. DECLARATIONS                                                         *
 ***************************************************************************/

/***************************************************************************
 * 4. CONSTANTS                                                            *
 ***************************************************************************/

/***************************************************************************
 * 5. FUNCTION PROTOTYPES                                                  *
 ***************************************************************************/


/** Transmits the ATR stored in T1_layer.c.
*/
void transmit_ATR(
    void);
    
/** Processes incoming data corresponding to the T=1 protocol

 The function processes all incoming bytes expecting a correct T=1 transmission
 the received data is then passed on tho the main OS routine for further processing.

 
 \param[out] received_APDU pointer to received command APDU 
 */
unsigned char receive_APDU(
    command_APDU * received_APDU);

/** Transmitting response APDUs corresponding to the T=1 protocol

 The function transmits a finished response APDU corresponding to the T=1 protocol

 
 \param[in] send_APDU pointer to response APDU to be transmitted
 */
void send_APDU(
    response_APDU * send_APDU);


/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
