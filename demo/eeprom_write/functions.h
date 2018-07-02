/***************************************************************************
 *                                                                         *
 * Praktikum Embedded Smartcard Microcontrollers                           *
 *                                                                         *
 ***************************************************************************/

/***************************************************************************/
/*!
    \file        functions.h

    \brief       Implemented functions of the OS

    \author      TE

    \version     1.0

    \date        28-May-2008

*/
/***************************************************************************/

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


/** Encrypts one CRYPTO block in ECB mode.

 The key must be initialized prior to calling this function.
 The answer length depends on the LE byte of the command.

 \param[in] com_APDU pointer to received command APDU containing the plaintext and the expected answer length
 \param[out] resp_APDU pointer to new response APDU to which the expected number of ciphertext bytes is written
 */
void do_CRYPTO_encrypt(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Decrypts one CRYPTO block in ECB mode.

 The key must be initialized prior to calling this function.
 The answer length depends on the LE byte of the command.

 \param[in] com_APDU pointer to received command APDU containing the ciphertext and the expected answer length
 \param[out] resp_APDU pointer to new response APDU to which the expected number of plaintext bytes is written
 */
void do_CRYPTO_decrypt(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Sets the key for the CRYPTO encryption.

 The key must be initialized prior to calling the do_CRYPTO_encrypt function.

 \param[in] com_APDU pointer to received command APDU containing the key
 \param[out] resp_APDU pointer to new response APDU which only consists of an error code (trailer)
 */
void do_set_key(
    command_APDU * com_APDU,
    response_APDU * resp_APDU);

/** Writes one data byte to an EEPROM location

 \param[in] com_APDU pointer to received command APDU containing the write command
 \param[out] resp_APDU pointer to new response APDU which only consists of an error code (trailer)
 */
void do_eeprom_write(
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
