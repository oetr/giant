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

#ifndef OS_functions
#define OS_functions

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

void do_APDUexchange(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);


/** Internal OS routine for calling the implemented functions

 The command handler checks the class (CLA) byte and finds and calls the corresponding function
 for the instruction (INS) byte. If one of the parameters is wrong or not set, it returns an APDU
 with the appropiate error code

 \param[in] com_APDU pointer to received command APDU to be processed
 \param[out] resp_APDU pointer to response APDU with processed data or appropiate error code
 */
void command_Handler(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
