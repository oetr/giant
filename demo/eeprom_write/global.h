/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*! 
    \file        global.h

    \brief       globally defined vars and functions of the OS

    \author      TE

    \version     1.0

    \date        20-Nov-2007

*/
/***************************************************************************/

#ifndef _Global
#define _Global


/***************************************************************************
 * 1. INCLUDES                                                             *  
 ***************************************************************************/
#include <avr/eeprom.h>
#include <avr/io.h>
#include <util/delay.h>
#include <util/delay_basic.h>
#include <stdint.h>
#include <stdlib.h>

/***************************************************************************
 * 2. DEFINES                                                              *
 ***************************************************************************/

/* TRUE / FALSE / NULL */
#ifndef TRUE
#define TRUE            1
#endif

#ifndef FALSE
#define FALSE           0
#endif

#ifndef NULL
#define NULL            0
#endif

/* Return codes */
#define OK            1
#define ERROR        -1

 /*Maximmum Bytes reserved in the input Buffer */
#define INPUT_BUFFER_SIZE 70

/* Definition of APDUs */
typedef struct
{
  unsigned char NAD;
  unsigned char PCB;
  unsigned char LEN;
  unsigned char CLA;
  unsigned char INS;
  unsigned char P1;
  unsigned char P2;
  unsigned char LC;
  unsigned char LE;
  unsigned char data_field[INPUT_BUFFER_SIZE - 9];

}
command_APDU;

typedef struct
{
  unsigned char NAD;
  unsigned char PCB;
  unsigned char LEN;
  unsigned char SW1;
  unsigned char SW2;
  unsigned char LE;
  unsigned char data_field[32];

}
response_APDU;



/***************************************************************************
 * 3. DECLARATIONS                                                         *
 ***************************************************************************/

/***************************************************************************
 * 4. CONSTANTS                                                            *
 ***************************************************************************/

/***************************************************************************
 * 5. FUNCTION PROTOTYPES                                                  *
 ***************************************************************************/

/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
