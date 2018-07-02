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

#ifndef RSA
#define RSA

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

/** Encrypts one RSA block in ECB mode (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the plaintext. after the function finishes, it will contain the ciphertext

 The second parameter is used to pass the key.


 \param[in] the first parameter is used to pass the plaintexr to the assembler. It will be overwritten with the ciphertext
 \param[out] the first parameter will contain the ciphertext after the execution of the function
 \param[in] the second parameter is used to pass the scheduled key to the assembler. It will NOT be overwritten
 */
void doRSA(unsigned char *);

/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
