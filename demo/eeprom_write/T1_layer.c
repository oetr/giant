/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*! 
    \file        T1_layer.c

    \brief       Implementation of T1 protocol functionality of the OS

    \author      TE

    \version     1.0

    \date        20-Nov-2007

*/
/***************************************************************************/


/***************************************************************************
 * 1. INCLUDES                                                             *  
 ***************************************************************************/
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "T1_layer.h"
#include "SosseIO.h"

/***************************************************************************
 * 2. DEFINES                                                              *
 ***************************************************************************/

 /***************************************************************************
 * 3. DEFINITIONS                                                          *
 ***************************************************************************/

/***************************************************************************
 * 4. CONSTANTS                                                            *
 ***************************************************************************/

 /* ATR consisting of:   TS    T0   TA1   TB1   TD1   TA2   TD2   TA3  TB3     T1...Tn  */
const unsigned char ATR[20] = { 0x3B, 0xBB, 0x11, 0x00, 0x91, 0x81, 0x31, 0x46, 0x15, 0x2A, 0x53, 0x6D, 0x34, 0x72, 0x74, 0x43, 0x34, 0x72, 0x64, 0x2A};





/***************************************************************************
 * 5. IMPLEMENTATION OF FUNCTIONS                                          *
 ***************************************************************************/



/*
** transmit_ATR transmits the ATR using the SOSSE sendbyte routine
*/
void transmit_ATR (void)
{
  unsigned char pos, TCK;

  TCK = 0;

  /* calculate TCK */
  for (pos = 1; pos < 20; pos++) {
    TCK ^= ATR[pos];
  }

  /* send ATR */
  for (pos = 0; pos < 20; pos++) {
    sendbytet0 (ATR[pos]);
  }

  sendbytet0 (TCK);

}

/*
** receive_APDU processes the incoming bytes corresponding to the 
** T=1 protocol
*/
unsigned char receive_APDU (command_APDU * received_APDU)
{
  /* init vars */
  unsigned char EDC, EDC_IN, NAD, PCB, LEN;
  int cnt;
  unsigned char APDU_buffer[INPUT_BUFFER_SIZE];

  EDC = 0;

  NAD = recbytet0 ();
  PCB = recbytet0 ();
  LEN = recbytet0 ();

  for (cnt = 0; cnt < LEN; cnt++) {
    APDU_buffer[cnt] = recbytet0 ();
  }
  EDC_IN = recbytet0 ();

  (*received_APDU).NAD = NAD;    /* Network address */
  EDC = EDC ^ NAD;
  (*received_APDU).PCB = PCB;    /* protocol byte */
  EDC = EDC ^ PCB;
  (*received_APDU).LEN = LEN;    /* length */
  EDC = EDC ^ LEN;

  for (cnt = 0; cnt < LEN; cnt++) {
    EDC = EDC ^ APDU_buffer[cnt];
  }

  /* extract APDU */
  (*received_APDU).CLA = APDU_buffer[0];
  (*received_APDU).INS = APDU_buffer[1];
  (*received_APDU).P1 = APDU_buffer[2];
  (*received_APDU).P2 = APDU_buffer[3];
  if ((*received_APDU).LEN == 5) {
    (*received_APDU).LE = APDU_buffer[4];    /* ISO7816 case 2 */
  }
  else if ((*received_APDU).LEN > 5) {
    (*received_APDU).LC = APDU_buffer[4];    /* ISO7816 case 3 or 4 */
    for (cnt = 0; cnt < (*received_APDU).LC; cnt++){
      (*received_APDU).data_field[cnt] = APDU_buffer[5 + cnt];
    }
    if ((*received_APDU).LEN > ((*received_APDU).LC + 5)){
      (*received_APDU).LE = APDU_buffer[(*received_APDU).LEN - 1];    /* ISO7816 case 4 */
    }
  }
  if (EDC != EDC_IN) {
    return ERROR;
  }
  else {
    return OK;
  }
}


/*
** send_APDU transmits the generated response APDU bytewise corresponding 
** to the T=1 protocol
*/
void
send_APDU (response_APDU * send_APDU)
{
  /* init vars */
  unsigned char EDC, cnt;
  unsigned char APDU_buffer[INPUT_BUFFER_SIZE];


  /* process and transmit response APDU */
  if ((*send_APDU).PCB > 127) {    /* R- or S-Block */
    EDC = 0;
    APDU_buffer[0] = (*send_APDU).NAD;    /* Network address */
    EDC = EDC ^ (*send_APDU).NAD;
    APDU_buffer[1] = (*send_APDU).PCB;    /* protocol byte */
    EDC = EDC ^ (*send_APDU).PCB;
    APDU_buffer[2] = (*send_APDU).LEN;    /* length */
    EDC = EDC ^ (*send_APDU).LEN;
    APDU_buffer[3] = (*send_APDU).data_field[0];
    EDC = EDC ^ (*send_APDU).data_field[0];
    APDU_buffer[4] = EDC;
    for (cnt = 0; cnt < 5; cnt++) {
      sendbytet0 (APDU_buffer[cnt]);
    }

  }
  else {                        /* I-Block */

    EDC = 0;
    APDU_buffer[0] = (*send_APDU).NAD;    /* Network address */
    EDC = EDC ^ (*send_APDU).NAD;
    APDU_buffer[1] = (*send_APDU).PCB;    /* protocol byte */
    EDC = EDC ^ (*send_APDU).PCB;
    APDU_buffer[2] = (*send_APDU).LEN;    /* length */
    EDC = EDC ^ (*send_APDU).LEN;

    for (cnt = 0; cnt < (*send_APDU).LE; cnt++) {
      APDU_buffer[3 + cnt] = (*send_APDU).data_field[cnt];
      EDC = EDC ^ (*send_APDU).data_field[cnt];
    }
    APDU_buffer[3 + cnt] = (*send_APDU).SW1;    /* status word */
    EDC = EDC ^ (*send_APDU).SW1;
    APDU_buffer[4 + cnt] = (*send_APDU).SW2;
    EDC = EDC ^ (*send_APDU).SW2;
    APDU_buffer[5 + cnt] = EDC;

    for (cnt = 0; cnt < ((*send_APDU).LEN + 4); cnt++)
      sendbytet0 (APDU_buffer[cnt]);
  }
}

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
