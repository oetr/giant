/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*! 
    \file        SosseIO.h

    \brief       Sosse T=0 I/O routines header file

    \author      TE

    \version     1.0

    \date        13-Nov-2007

*/
/***************************************************************************/
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
