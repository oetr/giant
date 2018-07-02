//  Simple Operating system for Smart cards
//  Copyright (C) 2002  Matthias Bruestle <m@mbsks.franken.de>
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#ifndef SosseIO
#define SosseIO

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
 
/** receives a single byte from the I/O pin (Assembler function)

 Assembler routine that samples the I/O pin for received communication bits.

 \param[out] return  received byte from the I/O pin
 */
unsigned char recbytet0(
    void);

/** sends a single byte via the I/O pin (Assembler function)

 Assembler routine that sets the I/O pin for communication bits corresponding
 to the negotiated protocol.

 \param[in] single parameter is send vie I/O pin
 */
void sendbytet0(
    unsigned char);

/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
