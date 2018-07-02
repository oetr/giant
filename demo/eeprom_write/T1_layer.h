/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*! 
    \file        T1_layer.h

    \brief       T1 protocol functionality of the OS

    \author      TE

    \version     1.0

    \date        20-Nov-2007

*/
/***************************************************************************/

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
