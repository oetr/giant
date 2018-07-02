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

#ifndef _Global
#define _Global


/***************************************************************************
 * 1. INCLUDES                                                             *  
 ***************************************************************************/


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
#define INPUT_BUFFER_SIZE 69

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
  unsigned char data_field[INPUT_BUFFER_SIZE - 9];

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
