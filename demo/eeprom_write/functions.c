/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*!
    \file        functions.c

    \brief       Functions provided by the OS

    \author      TE

    \version     1.0

    \date        28-May-2008

*/
/***************************************************************************/


/***************************************************************************
 * 1. INCLUDES                                                             *
 ***************************************************************************/
#include "functions.h"
#include "CRYPTO.h"

/***************************************************************************
 * 2. DEFINES                                                              *
 ***************************************************************************/

 /***************************************************************************
 * 3. DEFINITIONS                                                          *
 ***************************************************************************/


/* global vars */
static unsigned char response[16];  /* 128 bits of input    */
static unsigned char key[168];  /* 8 bytes of s-box key and 160 bytes of round keys */
static unsigned char memory[512];  /* 512 bytes of free memory      */



/***************************************************************************
 * 4. CONSTANTS                                                            *
 ***************************************************************************/

/***************************************************************************
 * 5. IMPLEMENTATION OF FUNCTIONS                                          *
 ***************************************************************************/

/*
**  do_CRYPTO_encrypt performs CRYPTO encryption on an 16 byte input block
*/
void do_CRYPTO_encrypt (command_APDU * com_APDU, response_APDU * resp_APDU)
{

  /* key must be set when this function is called for the first time */
  unsigned char ind, answerLength;  /* 1 register is sufficient */
  unsigned char CRYPTO_key_buffer[16];  /* buffer for CRYPTO */


  if ((*com_APDU).LC != 0x10) {  /* expected: 16 Data */

    /* Wrong length, send error code */
    (*resp_APDU).LEN = 2;    /* overall length of APDU   */
    (*resp_APDU).LE = 0;    /* user data length of APDU(for internal use only) */
    (*resp_APDU).SW1 = 0x64;  /* SW1 and SW2 of message (error code) */
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  /* ELSE: */

  /*read data  */
  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }



  /*encode data(response) with key(key) */
  CRYPTO_enc (response, key, memory);

  /*write data to resp_APDU */
  for (ind = 0; ind < 16; ind++) {
    (*resp_APDU).data_field[ind] = response[ind];
  }

  /* check expected answer length */
  if ((*com_APDU).LE <= 0x10) {
    answerLength = (*com_APDU).LE;
  }
  else {
    answerLength = 0x10;    /* maximum is 16 */
  }

  // send Ack
  (*resp_APDU).LEN = answerLength + 2;  /* response length +Ack */
  (*resp_APDU).LE = answerLength;  /* answer length is set by client */
  (*resp_APDU).SW1 = 0x90;    /* Ack: task accomplished */
  (*resp_APDU).SW2 = 0x00;

}

/***************************************************************************/

/*
**  do_CRYPTO_decrypt performs CRYPTO encryption on an 16 byte input block
*/
void do_CRYPTO_decrypt (command_APDU * com_APDU, response_APDU * resp_APDU)
{

  /* key must be set when this function is called for the first time */
  unsigned char ind, answerLength;  /* 1 register is sufficient */
  unsigned char CRYPTO_key_buffer[16];  /* buffer for CRYPTO */




  if ((*com_APDU).LC != 0x10) {  /* expected: 16 Data */

    /* Wrong length, send error code */
    (*resp_APDU).LEN = 2;    /* overall length of APDU   */
    (*resp_APDU).LE = 0;    /* user data length of APDU(for internal use only) */
    (*resp_APDU).SW1 = 0x64;  /* SW1 and SW2 of message (error code) */
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  /* ELSE: */

  /*read data  */
  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }



  /*decode data(response) with key(key) */
  CRYPTO_dec (response, key, memory);

  /*write data to resp_APDU */
  for (ind = 0; ind < 16; ind++) {
    (*resp_APDU).data_field[ind] = response[ind];
  }

  /* check expected answer length */
  if ((*com_APDU).LE <= 0x10) {
    answerLength = (*com_APDU).LE;
  }
  else {
    answerLength = 0x10;    /* maximum is 16 */
  }

  // send Ack
  (*resp_APDU).LEN = answerLength + 2;  /* response length +Ack */
  (*resp_APDU).LE = answerLength;  /* answer length is set by client */
  (*resp_APDU).SW1 = 0x90;    /* Ack: task accomplished */
  (*resp_APDU).SW2 = 0x00;

}

/***************************************************************************/



/*
** do_set_key sets key to the transmitted value
*/
void do_set_key (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  unsigned char ind;      /* 1 register is sufficient */

  if ((*com_APDU).LC != 0x10) {  /* expected: 16 Data */

    /** Wrong length, send error code */
    (*resp_APDU).LEN = 2;    /* overall legth of APDU    */
    (*resp_APDU).LE = 0;    /* user data length of APDU(for internal use only) */
    (*resp_APDU).SW1 = 0x64;  /* SW1 and SW2 of message (error code) */
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  /* ELSE:  */

  /*read key  */
  for (ind = 0; ind < 16; ind++) {
    response[ind] = (*com_APDU).data_field[ind];
  }



  /* schedule key */
  schedule_key (response, key, memory);


  /** send Ack */
  (*resp_APDU).LEN = 2;
  (*resp_APDU).LE = 0;      /* needed by the sending routine (answer length) */
  (*resp_APDU).SW1 = 0x90;    /* Ack: task accomplished */
  (*resp_APDU).SW2 = 0x00;
}

/***************************************************************************/

/*
** do_eeprom_write Write 1 byte to an EEPROM address
*/
void do_eeprom_write (command_APDU * com_APDU, response_APDU * resp_APDU)
{
  if ((*com_APDU).LC != 0x03) {  /* expected: 2 Byte (1 address, 1 data, 1 byte random delay) */

    /** Wrong length, send error code */
    (*resp_APDU).LEN = 2;    /* overall legth of APDU    */
    (*resp_APDU).LE = 0;    /* user data length of APDU(for internal use only) */
    (*resp_APDU).SW1 = 0x64;  /* SW1 and SW2 of message (error code) */
    (*resp_APDU).SW2 = 0x00;
    return;
  }

  /* ELSE:  */

  /* Get APDU data */
  uint8_t addr = (*com_APDU).data_field[0];
  uint8_t val = (*com_APDU).data_field[1];
  uint8_t delay = (*com_APDU).data_field[2];

  /* randomize timing */ 
  uint8_t i = 0;
  for(i = 0; i < delay; i++)
  {
	// delay by 3*8 clk cylces
	_delay_loop_1(8);
  }
  
  /* Store value before write */
  (*resp_APDU).data_field[0] = eeprom_read_byte((uint8_t*)addr);
  
  /* Write */
  eeprom_write_byte((uint8_t*)addr, val);

  /* Store value after write */
  (*resp_APDU).data_field[1] = eeprom_read_byte((uint8_t*)addr);

  /** send Ack */
  (*resp_APDU).LEN = 2 + 2;
  (*resp_APDU).LE = 2;      /* needed by the sending routine (answer length) */
  (*resp_APDU).SW1 = 0x90;    /* Ack: task accomplished */
  (*resp_APDU).SW2 = 0x00;
}

/***************************************************************************/

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
        case 0x02:
          do_set_key (com_APDU, resp_APDU);
          break;
        case 0x40:
          do_CRYPTO_encrypt (com_APDU, resp_APDU);
          break;
        case 0x42:
          do_CRYPTO_decrypt (com_APDU, resp_APDU);
          break;
		case 0x04:
			do_eeprom_write (com_APDU, resp_APDU);
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
