/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*!
    \file        CRYPTO.h

    \brief       Header of Assembler CRYPTO implementation

    \author      TE

    \version     1.0

    \date        13-Nov-2007

*/
/***************************************************************************/

#ifndef CRYPTO
#define CRYPTO

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

/** Encrypts one CRYPTO block in ECB mode (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the plaintext. after the function finishes, it will contain the ciphertext

 The second parameter is used to pass the key.


 \param[in] the first parameter is used to pass the plaintexr to the assembler. It will be overwritten with the ciphertext
 \param[out] the first parameter will contain the ciphertext after the execution of the function
 \param[in] the second parameter is used to pass the scheduled key to the assembler. It will NOT be overwritten
 */
void CRYPTO_enc (
    unsigned char *,
    unsigned char *,
    unsigned char *);

/** Decrypts one CRYPTO block in ECB mode (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the plaintext. after the function finishes, it will contain the ciphertext

 The second parameter is used to pass the key.


 \param[in] the first parameter is used to pass the ciphertext to the assembler. It will be overwritten with the ciphertext
 \param[out] the first parameter will contain the plaintext after the execution of the function
 \param[in] the second parameter is used to pass the scheduled key to the assembler. It will NOT be overwritten
 \param[in] the third parameter is empty SRAM space. It will be overwritten
 */
void CRYPTO_dec (
    unsigned char *,
    unsigned char *,
    unsigned char *);




/** Schedules one CRYPTO S-Box Keys and Round Keys  (Assembler function).

 The first parameter is the state of the assembler routine. When the function is called,
 it must contain the key. after the function finishes, it will contain the key as well

 The second parameter is used to pass the key.


 \param[in] the first parameter is used to pass the key to the assembler. It will NOT be overwritten.
 \param[out] the second parameter will contain the s-box key and round keys after the execution of the function
 \param[in] the third parameter is empty SRAM space. It will be overwritten
 */
void schedule_key (
    unsigned char *,
    unsigned char *,
    unsigned char *);


/***************************************************************************
 * 6. MACRO FUNCTIONS                                                      *
 ***************************************************************************/

/***************************************************************************
 * 7. END                                                                  *
 ***************************************************************************/
#endif
