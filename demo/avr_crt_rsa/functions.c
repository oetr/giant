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


/***************************************************************************
 * 1. INCLUDES                                                             *
 ***************************************************************************/
#include "functions.h"
#include "rsa.h"

/***************************************************************************
 * 2. DEFINES                                                              *
 ***************************************************************************/

 /***************************************************************************
 * 3. DEFINITIONS                                                          *
 ***************************************************************************/


/* global vars */
static unsigned char schnittstellenbytes[60];  /* 128 bits of input    */

/***************************************************************************
 * 4. CONSTANTS                                                            *
 ***************************************************************************/

/***************************************************************************
 * 5. IMPLEMENTATION OF FUNCTIONS                                          *
 ***************************************************************************/

void do_APDUexchange (command_APDU * com_APDU, response_APDU * resp_APDU) {

  unsigned char ind, answerLength;  /* 1 register is sufficient */

  /*read data  */
  for (ind = 0; ind < 60; ind++) {
    schnittstellenbytes[ind] = (*com_APDU).data_field[ind];
  }

  /*encode data(schnittstellenbytes) with key(key) */
  doRSA(schnittstellenbytes);

  /*write data to resp_APDU */
  for (ind = 0; ind < 60; ind++) {
    (*resp_APDU).data_field[ind] = schnittstellenbytes[ind];
  }

  /* check expected answer length */
  if ((*com_APDU).LE <= 0x3C) {
    answerLength = (*com_APDU).LE;
  }
  else {
    answerLength = 0x3C;    /* maximum is 60=0x3C */
  }

  // send Ack
  (*resp_APDU).LEN = answerLength + 2;  /* schnittstellenbytes length +Ack */
  (*resp_APDU).LE = answerLength;  /* answer length is set by client */
  (*resp_APDU).SW1 = 0x90;    /* Ack: task accomplished */
  (*resp_APDU).SW2 = 0x00;

}


/*
** Main command Handler processing incoming APDUs
*/
void command_Handler (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  (*resp_APDU).NAD = (*com_APDU).NAD;
  (*resp_APDU).PCB = (*com_APDU).PCB;

  if ((*com_APDU).PCB == 0xC1) {  /* S-Block Handling */

    (*resp_APDU).NAD = (*com_APDU).NAD;
    (*resp_APDU).PCB = 0xE1;
    (*resp_APDU).LEN = 1;
    (*resp_APDU).data_field[0] = (*com_APDU).CLA;
  }
  else {            /* I-Block Handling */

  switch ((*com_APDU).CLA) {
    case 0x80: {
      switch ((*com_APDU).INS) {
        case 0x40:
          do_APDUexchange (com_APDU, resp_APDU);
          break;
        default:
          (*resp_APDU).LEN = 2;
          (*resp_APDU).LE = 0;
          (*resp_APDU).SW1 = 0x68;  /* instruction not supported */
          (*resp_APDU).SW2 = 0x00;
          break;
        }
      break;
      }
    default:
      {
      (*resp_APDU).LEN = 2;
      (*resp_APDU).LE = 0;
      (*resp_APDU).SW1 = 0x6e;  /* class not supported */
      (*resp_APDU).SW2 = 0x00;
      break;
      }
    }
  }
}

/***************************************************************************
 * 6. END                                                                  *
 ***************************************************************************/
