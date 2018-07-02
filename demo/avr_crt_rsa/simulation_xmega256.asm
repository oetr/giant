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

/**************************************************************
 *
 * Flexible CRT-RSA Signature Calculation
 * Author: Stephen Markhoff
 *
 **************************************************************/


	.INCLUDE "ATxmega256A3def.inc"


	/* Register definitions */

	.DEF OPLENGTH = R25 			; RSA parameters length in byte
	.DEF NULL = R23					; 0x00 Register used for several comparisons and carry addition
	.DEF DIGITPOINTER = R22 		; Used for iteration over exponent bits
	.DEF LIMBPOINTER = R21			; Used for iteration over exponent bytes
	.DEF CURRENTEXPONENTLIMB = R20	; Stores the current exponent byte in exponentiation.
	.DEF MULCOUNTER1 = R19			; Iteration variable
	.DEF MULCOUNTER2 = R18			; Iteration variable
	.DEF TMP2 = R17					; Used for temporary storage
	.DEF TMP = R16					; Used for temporary storage
	.DEF OPL1 = R15					; Stores the length of an operand used by a few functions
	.DEF OPL2 = R14					; Stores the length of an operand used by a few functions
	.DEF MY2 = R13					; Pointers to adresses in memory
	.DEF MY1 = R12					; |
	.DEF MESSAGE2 = R11				; |
	.DEF MESSAGE1 = R10				; |
	.DEF MODULUS2 = R9				; |
	.DEF MODULUS1 = R8				; |
	.DEF EXPONENT2 = R7				; |
	.DEF EXPONENT1 = R6				; -


	RJMP init

/**************************************
 *
 * Macros for Fault Injection Trigger
 *
 **************************************/

	.MACRO Trigger
		PUSH TMP
		LDI tmp,PIN7_bm
		STS PORTA_OUTSET,tmp
		LDI tmp,PIN7_bm
		STS PORTA_OUTCLR,tmp
		POP TMP
	.ENDMACRO

	.MACRO TriggerON
		PUSH TMP
		LDI tmp,PIN7_bm
		STS PORTA_OUTSET,tmp
		POP TMP
	.ENDMACRO

	.MACRO TriggerOFF
		PUSH TMP
		LDI tmp,PIN7_bm
		STS PORTA_OUTCLR,tmp
		POP TMP
	.ENDMACRO



/************************************************************************
 *
 *  Initialize RSA Parameters
 *
 ************************************************************************/

	 init:

	/* STACK POINTER INITIALISIEREN */
	/* siehe im I/O view, dass High, Low Teil korrekt sind */
	.equ SPH = 0x3E
	.equ SPL = 0x3D
	LDI R16,HIGH (RAMEND) 
	OUT SPH, R16 
	LDI R16,LOW (RAMEND) 
	OUT SPL, R16 

	.equ PIN7_bm = 0x80
	CLR NULL	


	;CALL initUART
	initializeRsaParameters:

	;set triggerports to out
	ldi tmp, 0xe0
	sts PORTA_DIRSET,tmp
	TriggerOFF
		
	LDI ZL, $00
	LDI ZH, $20
	deleteSRAM:
		ST Z+, NULL
		CPI ZH, $5F
		BRNE deleteSRAM
		CPI ZL, $FF		
	BRNE deleteSRAM

;	CALL receiveRsaParameters
	LDI ZL, LOW(exponent)
	LDI ZH, HIGH(exponent)
	LDI R16, 0x15
	ST Z+, R16
	LDI R16, 0x75
	ST Z+, R16
	LDI R16, 0xAD
	ST Z+, R16
	LDI R16, 0x9C
	ST Z+, R16
	LDI R16, 0x07
	ST Z+, R16
	LDI R16, 0xAF
	ST Z+, R16
	LDI R16, 0x59
	ST Z+, R16
	LDI R16, 0xB5
	ST Z+, R16
	LDI ZL, LOW(message)
	LDI ZH, HIGH(message)
	LDI R16, 0x07
	ST Z+, R16
	LDI R16, 0xAF
	ST Z+, R16
	LDI R16, 0x59
	ST Z+, R16
	LDI R16, 0xB5
	ST Z+, R16
	LDI R16, 0x07
	ST Z+, R16
	LDI R16, 0xAF
	ST Z+, R16
	LDI R16, 0x59
	ST Z+, R16
	LDI R16, 0xB5
	ST Z+, R16
	LDI ZL, LOW(modulus)
	LDI ZH, HIGH(modulus)
	LDI R16, 0x0f
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x3c
	ST Z+, R16
	LDI R16, 0x27
	ST Z+, R16
	LDI R16, 0x6b
	ST Z+, R16
	LDI R16, 0x0f
	ST Z+, R16
	LDI R16, 0xd6
	ST Z+, R16
	LDI R16, 0xdd
	ST Z+, R16
	LDI ZL, LOW(p)
	LDI ZH, HIGH(p)
	LDI R16, 0x3b
	ST Z+, R16
	LDI R16, 0x9a
	ST Z+, R16
	LDI R16, 0xca
	ST Z+, R16
	LDI R16, 0x07
	ST Z+, R16
	LDI ZL, LOW(q)
	LDI ZH, HIGH(q)
	LDI R16, 0x40
	ST Z+, R16
	LDI R16, 0x6d
	ST Z+, R16
	LDI R16, 0xae
	ST Z+, R16
	LDI R16, 0xfb
	ST Z+, R16
	LDI ZL, LOW(pSub1)
	LDI ZH, HIGH(pSub1)
	LDI R16, 0x3b
	ST Z+, R16
	LDI R16, 0x9a
	ST Z+, R16
	LDI R16, 0xca
	ST Z+, R16
	LDI R16, 0x06
	ST Z+, R16
	LDI ZL, LOW(qSub1)
	LDI ZH, HIGH(qSub1)
	LDI R16, 0x40
	ST Z+, R16
	LDI R16, 0x6d
	ST Z+, R16
	LDI R16, 0xae
	ST Z+, R16
	LDI R16, 0xfa
	ST Z+, R16
	LDI ZL, LOW(pInv)
	LDI ZH, HIGH(pInv)
	LDI R16, 0x32
	ST Z+, R16
	LDI R16, 0xec
	ST Z+, R16
	LDI R16, 0x62
	ST Z+, R16
	LDI R16, 0x40
	ST Z+, R16
	LDI ZL, LOW(qInv)
	LDI ZH, HIGH(qInv)
	LDI R16, 0x0c
	ST Z+, R16
	LDI R16, 0x7e
	ST Z+, R16
	LDI R16, 0x72
	ST Z+, R16
	LDI R16, 0xfa
	ST Z+, R16
	LDI ZL, LOW(myModulus)
	LDI ZH, HIGH(myModulus)
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x11
	ST Z+, R16
	LDI R16, 0x10
	ST Z+, R16
	LDI R16, 0xcc
	ST Z+, R16
	LDI R16, 0xa1
	ST Z+, R16
	LDI R16, 0x05
	ST Z+, R16
	LDI R16, 0xde
	ST Z+, R16
	LDI R16, 0x04
	ST Z+, R16
	LDI R16, 0x66
	ST Z+, R16
	LDI R16, 0x72
	ST Z+, R16
	LDI ZL, LOW(myP)
	LDI ZH, HIGH(myP)
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x04
	ST Z+, R16
	LDI R16, 0x4b
	ST Z+, R16
	LDI R16, 0x82
	ST Z+, R16
	LDI R16, 0xf9
	ST Z+, R16
	LDI R16, 0x88
	ST Z+, R16
	LDI ZL, LOW(myQ)
	LDI ZH, HIGH(myQ)
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x03
	ST Z+, R16
	LDI R16, 0xf9
	ST Z+, R16
	LDI R16, 0x30
	ST Z+, R16
	LDI R16, 0xbb
	ST Z+, R16
	LDI R16, 0xee
	ST Z+, R16
	LDI ZL, LOW(myPSub1)
	LDI ZH, HIGH(myPSub1)
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x04
	ST Z+, R16
	LDI R16, 0x4b
	ST Z+, R16
	LDI R16, 0x82
	ST Z+, R16
	LDI R16, 0xf9
	ST Z+, R16
	LDI R16, 0x9b
	ST Z+, R16
	LDI ZL, LOW(myQSub1)
	LDI ZH, HIGH(myQSub1)
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x00
	ST Z+, R16
	LDI R16, 0x03
	ST Z+, R16
	LDI R16, 0xf9
	ST Z+, R16
	LDI R16, 0x30
	ST Z+, R16
	LDI R16, 0xbb
	ST Z+, R16
	LDI R16, 0xfd
	ST Z+, R16

	LDI R16, 0x08
	MOV OPLENGTH, R16

	LSR OPLENGTH

/************************************************************************
 *
 *  Compute CRT-RSA signature
 *
 ************************************************************************/

	
	/**************
	 * xp = x mod p
	 **************/
	/* Initialize pointers to reduce message mod p */
	LDI XL, LOW(message)
	LDI XH, HIGH(message)
	LDI YL, LOW(p)
	LDI YH, HIGH(p)
	LDI ZL, LOW(myP)
	LDI ZH, HIGH(myP)
	/* Calculate xp */
	RCALL modRed

	
	/*****************
	 * yp = xp^e mod p
	 *****************/
	/* copy xp to crtTMP */
	LDI YL, LOW(modResult)
	LDI YH, HIGH(modResult)
	ADIW Y, 1
	LDI ZL, LOW(crtTMP)
	LDI ZH, HIGH(crtTMP)
	MOV TMP, OPLENGTH
	copyXpLoop:
		LD R18, Y+
		ST Z+, R18
		DEC TMP
	BRNE copyXpLoop

		/* Reduce exponent */
		LDI XL, LOW(exponent)
		LDI XH, HIGH(exponent)
		LDI YL, LOW(pSub1)
		LDI YH, HIGH(pSub1)
		LDI ZL, LOW(myPSub1)
		LDI ZH, HIGH(myPSub1)
		RCALL modRed

		/* Copy reduced exponent to "sqmExponent" */
		LDI YL, LOW(sqmExponent)
		LDI YH, HIGH(sqmExponent)
		LDI ZL, LOW(modResult)
		LDI ZH, HIGH(modResult)
		ADIW Z, 1
		MOV TMP, OPLENGTH
		copyExponentModPLoop:
			LD TMP2, Z+
			ST Y+, TMP2
			DEC TMP
		BRNE copyExponentModPLoop

	/* Let MESSAGE point to xp */
	LDI TMP, LOW(crtTMP)
	MOV MESSAGE2, TMP
	LDI TMP, HIGH(crtTMP)
	MOV MESSAGE1, TMP
	/* Let EXPONENT point to exponent */
	LDI TMP, LOW(sqmExponent)
	MOV EXPONENT2, TMP
	LDI TMP, HIGH(sqmExponent)
	MOV EXPONENT1, TMP
	/* Let MY point to myP */
	LDI TMP, LOW(myP)
	MOV MY2, TMP
	LDI TMP, HIGH(myP)
	MOV MY1, TMP
	/* let MODULUS point to p */
	LDI TMP, LOW(p)
	MOV MODULUS2, TMP
	LDI TMP, HIGH(p)
	MOV MODULUS1, TMP
	/* Initialize operands length */
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	/* calculate xp^e mod p */
	RCALL squareAndMultiply
	/* copy result to crtYp */
	LDI YL, LOW(crtYp)
	LDI YH, HIGH(crtYp)
	LDI ZL, LOW(sqmResult)
	LDI ZH, HIGH(sqmResult)
	MOV TMP, OPLENGTH
	copyYpLoop:
		LD TMP2, Z+
		ST Y+, TMP2
		DEC TMP
	BRNE copyYpLoop




	/**************
	 * xq = message mod q
	 **************/

	/* Initialize pointers to reduce message mod p */
	LDI XL, LOW(message)
	LDI XH, HIGH(message)
	LDI YL, LOW(q)
	LDI YH, HIGH(q)
	LDI ZL, LOW(myQ)
	LDI ZH, HIGH(myQ)
	/* Calculate xq */
	RCALL modRed

	
	/**************
	 * yq = xq^e mod q
	 **************/
	/* copy xq to crtTMP */
	LDI YL, LOW(modResult)
	LDI YH, HIGH(modResult)
	ADIW Y, 1
	LDI ZL, LOW(crtTMP)
	LDI ZH, HIGH(crtTMP)
	MOV TMP, OPLENGTH
	copyXqLoop:
		LD R18, Y+
		ST Z+, R18
		DEC TMP
	BRNE copyXqLoop


		/* Reduce exponent */
		LDI XL, LOW(exponent)
		LDI XH, HIGH(exponent)
		LDI YL, LOW(qSub1)
		LDI YH, HIGH(qSub1)
		LDI ZL, LOW(myQSub1)
		LDI ZH, HIGH(myQSub1)
		RCALL modRed

		/* Copy reduced exponent to "sqmExponent" */
		LDI YL, LOW(sqmExponent)
		LDI YH, HIGH(sqmExponent)
		LDI ZL, LOW(modResult)
		LDI ZH, HIGH(modResult)
		ADIW Z, 1
		MOV TMP, OPLENGTH
		copyExponentModQLoop:
			LD TMP2, Z+
			ST Y+, TMP2
			DEC TMP
		BRNE copyExponentModQLoop


	/* Let MESSAGE point to xq */
	LDI TMP, LOW(crtTMP)
	MOV MESSAGE2, TMP
	LDI TMP, HIGH(crtTMP)
	MOV MESSAGE1, TMP
	/* Let EXPONENT point to exponent */
	LDI TMP, LOW(sqmExponent)
	MOV EXPONENT2, TMP
	LDI TMP, HIGH(sqmExponent)
	MOV EXPONENT1, TMP
	/* Let MY point to myQ */
	LDI TMP, LOW(myQ)
	MOV MY2, TMP
	LDI TMP, HIGH(myQ)
	MOV MY1, TMP
	/* let MODULUS point to q */
	LDI TMP, LOW(q)
	MOV MODULUS2, TMP
	LDI TMP, HIGH(q)
	MOV MODULUS1, TMP
	/* Initialize operands length */
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	/* calculate xp^e mod p */
	RCALL squareAndMultiply
	/* copy result to crtYp */
	LDI YL, LOW(crtYq)
	LDI YH, HIGH(crtYq)
	LDI ZL, LOW(sqmResult)
	LDI ZH, HIGH(sqmResult)
	MOV TMP, OPLENGTH
	copyYqLoop:
		LD TMP2, Z+
		ST Y+, TMP2
		DEC TMP
	BRNE copyYqLoop

	
	/*********************
	 * Multiplication 1
	 * yp * Mp * Cp
	 *********************/

	LDI XL, LOW(crtTmp2)
	LDI XH, HIGH(crtTmp2)
	LDI YL, LOW(q)
	LDI YH, HIGH(q)
	LDI ZL, LOW(crtYp)
	LDI ZH, HIGH(crtYp)
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	RCALL longMul

	LDI XL, LOW(crtResult1)
	LDI XH, HIGH(crtResult1)
	LDI YL, LOW(qInv)
	LDI YH, HIGH(qInv)
	LDI ZL, LOW(crtTmp2)
	LDI ZH, HIGH(crtTmp2)
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	ADD OPL2, OPLENGTH
	RCALL longMul



	/*********************
	 * Multiplication 2
	 * yq * My * Cq
	 *********************/

	LDI XL, LOW(crtTmp2)
	LDI XH, HIGH(crtTmp2)
	LDI YL, LOW(p)
	LDI YH, HIGH(p)
	LDI ZL, LOW(crtYq)
	LDI ZH, HIGH(crtYq)
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	RCALL longMul

	LDI XL, LOW(crtResult2)
	LDI XH, HIGH(crtResult2)
	LDI YL, LOW(pInv)
	LDI YH, HIGH(pInv)
	LDI ZL, LOW(crtTmp2)
	LDI ZH, HIGH(crtTmp2)
	MOV OPL1, OPLENGTH
	MOV OPL2, OPLENGTH
	ADD OPL2, OPLENGTH
	RCALL longMul


	
	/*****************************
	 * Add results
	 * y' = yp * Mp * Cp + yq * Mq * Cq 
	 *****************************/
	LDI XL, LOW(crtResult3)
	LDI XH, HIGH(crtResult3)
	ADD XL, OPLENGTH
	ADC XH, NULL
	LDI YL, LOW(crtResult1)
	LDI YH, HIGH(crtResult1)
	LDI ZL, LOW(crtResult2)
	LDI ZH, HIGH(crtResult2)
	LDI TMP, 3
	MUL OPLENGTH, TMP
	MOV OPL1, R0
	RCALL longADD


	/****************** 
	 * Reduce result 
	 * y = y' mod m
	 ******************/
	LDI XL, LOW(crtResult3)
	LDI XH, HIGH(crtResult3)
	LDI YL, LOW(modulus)
	LDI YH, HIGH(modulus)
	LDI ZL, LOW(myModulus)
	LDI ZH, HIGH(myModulus)
	ADD OPLENGTH, OPLENGTH
	RCALL modRed

	/******************
	 * Send signature
	 ******************/
	CALL initUart
	LDI ZL, LOW(modResult)
	LDI ZH, HIGH(modResult)
	ADIW Z, 1
	MOV TMP, OPLENGTH
	CALL sendBytes

	/* Jump to start */
	JMP initializeRsaParameters


/************************************************************************
 *
 * Needed functions for signature computation
 * - squareAndMultiply + 2 additional functions sqmSquare, sqmMultiply
 * - longMul
 * - modRed
 * - longAdd
 * - longSub
 * - longSameOrHigher
 *
 ************************************************************************/


	/**
	 * Binary exponentiation algorithm.
	 * (MESSAGE1, MESSAGE2) should point to MSB of base
	 * (EXPONENT1, EXPONENT2) should point to MSB of exponent
	 * (MODULUS1, MODULUS2) should point to modulus 
	 * (MY1, MY2) should point to my used by modulus
	 * OPL1 should be the length of exponent
	 * OPL2 should be the length of modulus and base
	 */
	squareAndMultiply:		

		/* Initialize result by copying message to result*/
		MOV ZL, MESSAGE2
		MOV ZH, MESSAGE1
		LDI YL, LOW(sqmResult)
		LDI YH, HIGH(sqmResult)
		MOV TMP, OPL2 
		initResultLoop:
			LD TMP2, Z+
			ST Y+, TMP2
			DEC TMP
		BRNE initResultLoop



		/* Initialize Z-pointer to load exponent */
		MOV ZL, EXPONENT2
		MOV ZH, EXPONENT1

		/* Store length of exponent in TMP to use it for iteration */
		MOV TMP, OPL1
		
		/* Initialize DIGITPOINTER and LIMBPOINTER for sqm startup */
		INC TMP ; Increment for loop
		initDigitPointer:
			DEC TMP
			LD CURRENTEXPONENTLIMB, Z+
			CP CURRENTEXPONENTLIMB, NULL
		BREQ initDigitPointer
		PUSH ZH
		PUSH ZL
		MOV LIMBPOINTER, TMP
		LDI DIGITPOINTER, 8		
		initDigitPointerShift:
			DEC DIGITPOINTER
			LSL CURRENTEXPONENTLIMB
		BRCC initDigitPointerShift
		


		RJMP shiftExponentLoop					
		
		loadExponentLoop:

			LDI DIGITPOINTER, 8			
			POP ZL
			POP ZH
			LD CURRENTEXPONENTLIMB, Z+
			PUSH ZH
			PUSH ZL

			shiftExponentLoop:
				
				/* Square */
				RCALL sqmSquare

				/* If current exponent digit=1 then multiply */
				LSL CURRENTEXPONENTLIMB
				BRCC shiftExponentLoopEnd

				/* multiply */
				RCALL sqmMultiply


				shiftExponentLoopEnd:
					DEC DIGITPOINTER
			BRNE shiftExponentLoop

			DEC LIMBPOINTER

		/* If calculation is not finished then repeat step */
		BRNE loadExponentLoop
		
		POP ZL
		POP ZH
		
	RET


	/**
	 * Used by squareAndMultiply function to square and reduce current value in the algorithm
	 */
	sqmSquare:

		/* Square "result" */
		LDI XL, LOW(mulResult)
		LDI XH, HIGH(mulResult)
		LDI ZL, LOW(sqmResult)
		LDI ZH, HIGH(sqmResult)
		LDI YL, LOW(sqmResult)
		LDI YH, HIGH(sqmResult)
		MOV OPL1, OPLENGTH
		MOV OPL2, OPLENGTH
		RCALL longMul

		/* Reduce */
		LDI XL, LOW(mulResult)
		LDI XH, HIGH(mulResult)
		MOV YL, MODULUS2
		MOV YH, MODULUS1
		MOV ZL, MY2
		MOV ZH, MY1
		RCALL modRed

		/* Copy result of multiplication to "result" for next multiplication/squaring */
		LDI YL, LOW(sqmResult)
		LDI YH, HIGH(sqmResult)
		LDI ZL, LOW(modResult)
		LDI ZH, HIGH(modResult)
		ADIW Z, 1
		MOV TMP, OPLENGTH

		Trigger

		copyTmpResultLoop1:
			LD TMP2, Z+
			ST Y+, TMP2
			DEC TMP
		BRNE copyTmpResultLoop1

	RET

	/**
	 * Used by squareAndMultiply function to multiply and reduce current value in the algorithm with message
	 */
	sqmMultiply:
		/* Copy "message" to "operand" */
		MOV ZL, MESSAGE2
		MOV ZH, MESSAGE1
		LDI XL, LOW(sqmOperand)
		LDI XH, HIGH(sqmOperand)
		MOV TMP, OPLENGTH
		copyResultLoop2:
			LD TMP2, Z+
			ST X+, TMP2
			DEC TMP
		BRNE copyResultLoop2

		/* Multiply "result" and "operand" */	
		LDI XL, LOW(mulResult)
		LDI XH, HIGH(mulResult)
		LDI YL, LOW(sqmResult)
		LDI YH, HIGH(sqmResult)
		LDI ZL, LOW(sqmOperand)
		LDI ZH, HIGH(sqmOperand)
		MOV OPL1, OPLENGTH
		MOV OPL2, OPLENGTH					
		RCALL longMul

		/* Reduce */
		LDI XL, LOW(mulResult)
		LDI XH, HIGH(mulResult)
		MOV YL, MODULUS2
		MOV YH, MODULUS1
		MOV ZL, MY2
		MOV ZH, MY1
		RCALL modRed

		/* Copy result of multiplication to "result" for next multiplication/squaring */
		LDI YL, LOW(sqmResult)
		LDI YH, HIGH(sqmResult)
		LDI XL, LOW(modResult)
		LDI XH, HIGH(modResult)
		ADIW X, 1
		MOV TMP, OPLENGTH

		Trigger

		copyTmpResultLoop2:
			LD TMP2, X+
			ST Y+, TMP2
			DEC TMP
		BRNE copyTmpResultLoop2

	RET


	/**
	 * Multiplies two operands
	 * Y should point to MSB of first operand
	 * Z should point to MSB of second operand
	 * The result is stored at adress X
	 * OPL1 should store length of first operand in Byte
	 * OPL2 should store length of second operand in Byte
	 */
	longMul:

		/* Store operand pointer (necessary for iteration) */
		PUSH YH
		PUSH YL

		/* Initialize operand pointer */
		MOV TMP, OPL2
		DEC TMP
		ADD ZL, TMP
		ADC ZH, NULL


		/* Clear tmpResult and initialize tmpResult pointer */
		MOV TMP, OPL1
		clearTmpResult1:
			ST X+, NULL	
			DEC TMP		
		BRNE clearTmpResult1
		MOV TMP, OPL2
		clearTmpResult2:
			ST X+, NULL	
			DEC TMP		
		BRNE clearTmpResult2
		SBIW X, 1

		/* Initialize MULCOUNTER1 for iteration */
		MOV MULCOUNTER1, OPL2

		mulLoop1:

			/* Initialize 2nd operand pointer */
			POP YL
			POP YH
			PUSH YH
			PUSH YL
			MOV TMP, OPL1
			DEC TMP
			ADD YL, TMP
			ADC YH, NULL
			
			MOV MULCOUNTER2, OPL1

			mulLoop2:
				
				/* Multiply current limbs */
				LD R3, Z
				LD R4, Y
				SBIW Y, 1
				MUL R3, R4

				/* Store LSB of the multiplication result */
				LD R3, X
				ADD R3, R0
				ST X, R3

				/* Add carry */
				BRCC skipAddCarry1 ;if carry = 0 then skip carry addition
				PUSH XL
				PUSH XH				
				addCarry1:
					LD R3, -X
					ADC R3, NULL
					ST X, R3
					BRCC endAddCarryLoop1
					DEC TMP
				BRNE addCarry1	
				endAddCarryLoop1:
				POP XH
				POP XL
				skipAddCarry1:

				SBIW X, 1


				/* Store MSB of multiplication */
				LD R3, X
				ADD R3, R1
				ST X, R3


				/* Add carry */
				BRCC skipAddCarry2 ;if carry = 0 then skip carry addition
				PUSH XL
				PUSH XH				
				addCarry2:
					LD R3, -X
					ADC R3, NULL
					ST X, R3
					BRCC endAddCarryLoop2
					DEC TMP
				BRNE addCarry2	
				endAddCarryLoop2:
				POP XH
				POP XL
				skipAddCarry2:

				
				endMulLoop2:
				DEC MULCOUNTER2
			BRNE mulLoop2

		SBIW Z, 1
		MOV TMP, OPL1
		DEC TMP
		ADD XL, TMP
		ADC XH, NULL

		DEC MULCOUNTER1
		BRNE mulLoop1

		/* Pop stored adress from stack, so that correct return adress is used */
		POP YL
		POP YH
		
	RET



/**
 * Modular reduction (Barrett Algorithm)
 * X should point to MSB of the value that has to be reduced
 * Y should point to MSB of the modulus 
 * Z should point to MSB of the "my" value that belongs to the used modulus
 * Result is stored at adress "modResult" with OPLENGTH + 1 Words
 * OPLENGTH should store the length of the modulus
 * The value that has to be reduced has to be twice as long as the modulus (maybe padding)
 */
	modRed:
		PUSH XL
		PUSH XH

		PUSH YL
		PUSH YH


		/* Initialize pointers */
		MOV YL, XL
		MOV YH, XH
		LDI XL, LOW(modTmp2)
		LDI XH, HIGH(modTmp2)
		/* compute length of q1 */
		MOV OPL1, OPLENGTH
		INC OPL1
		/* compute length of my */
		MOV OPL2, OPLENGTH
		LDI TMP, 2
		MUL OPL2, TMP
		MOV OPL2, R0		
		/* calculate q2 */
		RCALL longMul



		POP ZH
		POP ZL
		LDI XL, LOW(modTmp)
		LDI XH, HIGH(modTmp)
		MOV TMP, OPLENGTH
		ST X+, NULL
		copyModulusLoop:
			LD TMP2, Z+
			ST X+, TMP2
			DEC TMP
		BRNE copyModulusLoop
		/* Initialize pointers */
		LDI XL, LOW(modResult)
		LDI XH, HIGH(modResult)
		LDI YL, LOW(modTmp2)
		LDI YH, HIGH(modTmp2)
		LDI ZL, LOW(modTmp)
		LDI ZH, HIGH(modTmp)
		ADIW Z, 1
		/* Determine operand lengths */	
		ADD OPL1, OPL2		
		DEC OPL1
		SUB OPL1, OPLENGTH
		MOV OPL2, OPLENGTH
		/* Calculate r2 */
		RCALL longMul


		/* Initialize pointers */
		LDI XL, LOW(modResult)
		LDI XH, HIGH(modResult)
		POP YH
		POP YL
		LDI ZL, LOW(modResult)
		LDI ZH, HIGH(modResult)

		ADD YL, OPLENGTH
		ADC YH, NULL
		SBIW Y, 1

		ADD ZL, OPLENGTH
		ADC ZH, NULL
		ADD ZL, OPLENGTH
		ADC ZH, NULL
		SBIW Z, 1

		/* Determine operand lengths */
		MOV OPL1, OPLENGTH
		INC OPL1

		/* calculate r = r1 - r2 */
		RCALL longSub

		startModRedWhileLoop:
			LDI YL, LOW(modTmp)
			LDI YH, HIGH(modTmp)
			LDI ZL, LOW(modResult)
			LDI ZH, HIGH(modResult)

			MOV OPL1, OPLENGTH
			INC OPL1


			RCALL longSameOrHigher

			BRSH endModRed

			/* Initialize pointers */
			LDI XL, LOW(modResult)
			LDI XH, HIGH(modResult)
			LDI YL, LOW(modResult)
			LDI YH, HIGH(modResult)
			LDI ZL, LOW(modTmp)
			LDI ZH, HIGH(modTmp)

			MOV OPL1, OPLENGTH
			INC OPL1

			RCALL longSub			

			RJMP startModRedWhileLoop
		
		endModRed:
		
	RET


	/**
	 * Addition
	 * Y should point to MSB of first operand (SRAM)
	 * Z should point to MSB of second operand (SRAM)
	 * The result is written to adress X (SRAM)
	 * (OPL2, OPL1) determines length of the first (Y) and second (Z) operand, thus the two operands must have the same length
	 */ 
	longAdd:
		
		/* Let pointers point to LSB of their numbers */
		ADD YL, OPL1
		ADC YH, NULL
		ADD ZL, OPL1
		ADC ZH, NULL
		ADD XL, OPL1
		ADC XH, NULL
		MOV TMP, OPL1
		MOV TMP2, OPL2

		/* Addition loop */
		addLoop1:
			LD R3, -Y
			LD R4, -Z
			ADC R3, R4
			ST -X, R3
			DEC TMP
		BRNE addLoop1

		endAdd:

	RET



	/**
	 * Subtraction
	 * Y should point to MSB of minuend (SRAM)
	 * Z should point to MSB of subtrahend (SRAM)
	 * The result is written to adress X (SRAM)
	 * (OPL2, OPL1) determines length of the first (Y) and second (Z) operand, thus the two operands must have the same length
	 */ 
	longSub:
		
		/* Let pointers point to LSB of their numbers */
		ADD YL, OPL1
		ADC YH, NULL
		ADD ZL, OPL1
		ADC ZH, NULL
		ADD XL, OPL1
		ADC XH, NULL
		MOV TMP, OPL1

		/* Subtraction loop */
		subLoop1:
			LD R3, -Y
			LD R4, -Z
			SBC R3, R4
			ST -X, R3
			DEC TMP
		BRNE subLoop1

	RET

	/**
	 * Compares two operands
	 * Requires Y, Z pointer to point to MSB of the two numbers which shall be compared
	 * OPL1 determines length of the two operands
	 * Sets carry if first operand is equal to or higher than the second one
	 */ 
	longSameOrHigher:

		MOV TMP, OPL1
	
		compareLoop2:
			
			LD R3, Y+
			LD R4, Z+
			CP R3, R4
			BRNE endCompare

			DEC TMP
		BRNE compareLoop2

		endCompare:

	RET



/****************************
 *
 * UART functions
 *
 ****************************/

	/**
	 *
	 * Initialize UART 
	 * Baudrate: 19200 @ 2 MHz
	 * 8 Bit asynchronous
	 *
	 */
	initUART:
		/* Set TX as output */
		ldi tmp,PIN7_bm
		sts PORTC_DIRSET,tmp
		/* Set RXEN and TXEN bits in the CTRLB Register to enable receive and send data */
		ldi tmp,USART_RXEN_bm|USART_TXEN_bm
		sts USARTC1_CTRLB,tmp
		/* Set 8 Bit asychronus mode */
		ldi tmp,USART_CMODE_ASYNCHRONOUS_gc|USART_PMODE_DISABLED_gc|USART_CHSIZE_8BIT_gc
		sts USARTC1_CTRLC,tmp
		/* Set baudrate */
		ldi tmp,0x92
		sts USARTC1_BAUDCTRLB,tmp
		ldi tmp,0xC1
		sts USARTC1_BAUDCTRLA,tmp
	RET


	/**
	 *
	 * Sends bytes via UART
	 * Requires Z pointer to point to MSB of the value to be sended
	 * TMP determines how many bytes are sended
	 *
	 */
	sendBytes:
		sendSignatureLoop:
			
			/* Wait for previous transmission to be finished */
			uart_transmit_loop:
				lds TMP2,USARTC1_STATUS
				sbrs TMP2, USART_DREIF_bp
			rjmp uart_transmit_loop

			/* Send byte */
			LD TMP2, Z+
			sts USARTC1_DATA,TMP2
			
			DEC TMP
		BRNE sendSignatureLoop
	RET


	/**
	 *
	 * Receives RSA Parameter via UART
	 * 
	 */
	receiveRsaParameters:

		/* Read length */
		uartReceiveOplengthLoop:
			lds tmp,USARTC1_STATUS
			sbrs tmp, USART_RXCIF_bp
		jmp uartReceiveOplengthLoop
		/* Read first byte (OPLENGTH) */
		lds OPLENGTH, USARTC1_DATA

		/* Read exponent */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(exponent)
		LDI ZH, HIGH(exponent)
		getExponentLoop:
			uartReceiveExponentLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveExponentLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getExponentLoop
		
		
		/* Read message */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(message)
		LDI ZH, HIGH(message)
		getMessageLoop:
			uartReceiveMessageLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMessageLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMessageLoop	


		/* Read modulus */		
		MOV TMP, OPLENGTH
		LDI ZL, LOW(modulus)
		LDI ZH, HIGH(modulus)
		getModulusLoop:
			uartReceiveModulusLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveModulusLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getModulusLoop	


		/* Read p */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(p)
		LDI ZH, HIGH(p)
		getPLoop:
			uartReceivePLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceivePLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getPLoop	


		/* Read q */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(q)
		LDI ZH, HIGH(q)
		getQLoop:
			uartReceiveQLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveQLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getQLoop	

		
		/* Read pSub1 */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(pSub1)
		LDI ZH, HIGH(pSub1)
		getPSub1Loop:
			uartReceivePSub1Loop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceivePSub1Loop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getPSub1Loop	


		/* Read qSub1 */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(qSub1)
		LDI ZH, HIGH(qSub1)
		getQSub1Loop:
			uartReceiveQSub1Loop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveQSub1Loop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getQSub1Loop	


		/* Read pInv */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(pInv)
		LDI ZH, HIGH(pInv)
		getPInvLoop:
			uartReceivePInvLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceivePInvLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getPInvLoop	


		/* Read qInv */
		MOV TMP, OPLENGTH
		LSR TMP
		LDI ZL, LOW(qInv)
		LDI ZH, HIGH(qInv)
		getQInvLoop:
			uartReceiveQInvLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveQInvLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getQInvLoop	

		
		/* Read myModulus */
		MOV TMP, OPLENGTH
		LSL TMP
		LDI ZL, LOW(myModulus)
		LDI ZH, HIGH(myModulus)
		getMyModulusLoop:
			uartReceiveMyModulusLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMyModulusLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMyModulusLoop	


		/* Read myP */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(myP)
		LDI ZH, HIGH(myP)
		getMyPLoop:
			uartReceiveMyPLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMyPLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMyPLoop	

		
		/* Read myQ */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(myQ)
		LDI ZH, HIGH(myQ)
		getMyQLoop:
			uartReceiveMyQLoop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMyQLoop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMyQLoop	


		/* Read myPSub1 */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(myPSub1)
		LDI ZH, HIGH(myPSub1)
		getMyPSub1Loop:
			uartReceiveMyPSub1Loop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMyPSub1Loop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMyPSub1Loop	


		/* Read myQSub1 */
		MOV TMP, OPLENGTH
		LDI ZL, LOW(myQSub1)
		LDI ZH, HIGH(myQSub1)
		getMyQSub1Loop:
			uartReceiveMyQSub1Loop:
				lds tmp2,USARTC1_STATUS
				sbrs tmp2, USART_RXCIF_bp
			jmp uartReceiveMyQSub1Loop
			
			/* Read byte */
			lds TMP2, USARTC1_DATA
			/* Store byte */
			ST Z+, TMP2

			DEC TMP
		BRNE getMyQSub1Loop	

	RET





/**********************************************************
 * .
 * Allocate memory in SRAM for calculations and parameters 
 *
 **********************************************************/
; 128 / 16 = 8
; 256 / 16 = 16
; 384 / 16 = 24	
; 64  / 16 = 4
;

	.DSEG
		crtTmp: .Byte 8
		crtTmp2: .Byte 8
		crtResult1: .Byte 16
		crtResult2: .Byte 16
		crtResult3: .Byte 16
		crtYp: .Byte 4
		crtYq: .Byte 4
		sqmResult: .BYTE 8
		sqmOperand: .BYTE 8
		sqmExponent: .BYTE 8
		mulResult: .BYTE 16
		modTmp: .BYTE 24
		modTmp2: .BYTE 24
		modTmp3: .BYTE 24
		modResult: .BYTE 24


		exponent: .Byte 8
		message: .Byte 8
		modulus: .Byte 8
		p: .Byte 4
		q: .Byte 4
		pSub1: .Byte 4
		qSub1: .Byte 4
		pInv: .Byte 4
		qInv: .Byte 4
		myModulus: .Byte 16
		myP: .Byte 8
		myQ: .Byte 8
		myPSub1: .Byte 8
		myQSub1: .Byte 8
