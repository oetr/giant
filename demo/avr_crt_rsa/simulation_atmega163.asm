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

.def XL=r26
.def XH=r27
.def YL=r28
.def YH=r29
.def ZL=r30
.def ZH=r31

/* Register setinitions */

.def OPLENGTH = r5 			; RSA parameters length in byte
.def NULL = r23					; 0x00 Register used for several comparisons and carry addition
.def DIGITPOINTER = r22 		; Used for iteration over exponent bits
.def LIMBPOINTER = r21			; Used for iteration over exponent bytes
.def CURRENTEXPONENTLIMB = r20	; Stores the current exponent byte in exponentiation.
.def MULCOUNTER1 = r19			; Iteration variable
.def MULCOUNTER2 = r18			; Iteration variable
.def TMP2 = r17					; Used for temporary storage
.def TMP= r16					; Used for temporary storage
.def OPL1= r15					; Stores the length of an operand used by a few functions
.def OPL2= r14					; Stores the length of an operand used by a few functions
.def MY2= r13					; Pointers to adresses in memory
.def MY1= r12					; |
.def MESSAGE2 = r11				; |
.def MESSAGE1 = r10				; |
.def MODULUS2 = r9				; |
.def MODULUS1 = r8				; |
.def EXPONENT2 = r7				; |
.def EXPONENT1 = r6				; -

.equ sph = 0x3e
.equ spl = 0x3d
.equ ramend = 0x45f


LDI TMP ,HIGH (RAMEND) 
OUT SPH , TMP 
LDI TMP ,LOW (RAMEND) 
OUT SPL , TMP 


LDI R25, 0x00  // Zeiger auf den Schlüssel im Registerpaar (r24 (lo),r25 (hi)) [bzw auf enc]
LDI R24, 0x60  // legen wir auf 0x0060 bis 0x006F in den Speicher (16 Byte)

LDI R23, 0x00  // Zeiger auf den 176 Byte Rundenschlüsselspeicher im Registerpaar (r22 (lo),r23 (hi))
LDI R22, 0x70  // legen wir auf 0x0070 bis 0x011F in den Speicher (176 Byte)

LDI R21, 0x01  // Zeiger auf den 500 Byte freien SRAM im Registerpaar (r20 (lo),r21 (hi))
LDI R20, 0x20  // ab 0x0120

LDI TMP, 0x08
MOV OPLENGTH, TMP


RJMP computeResult

/************************************************************************
 *
 *  TESTBENCH
 *
 ************************************************************************/

Resetmemory:

   LDI R16, 0x01
   MOV R0, R16

   LDI R16, 0xFF
   LDI	ZH, 0x00
   LDI	ZL, 0x60
   Loopit1:
		ST Z+, R0
		DEC R16    
		CPI R16, 0x00
   BRNE Loopit1

   LDI R16, 0xFF
   LDI	ZH, 0x01
   LDI	ZL, 0x5E
   Loopit2:
		ST Z+, R0
		DEC R16    
		CPI R16, 0x00
   BRNE Loopit2

   LDI R16, 0xFF
   LDI	ZH, 0x02
   LDI	ZL, 0x54
   Loopit3:
		ST Z+, R0
		DEC R16    
		CPI R16, 0x00
   BRNE Loopit3

   LDI R16, 0xFF
   LDI	ZH, 0x03
   LDI	ZL, 0x52
   Loopit4:
		ST Z+, R0
		DEC R16    
		CPI R16, 0x00
   BRNE Loopit4

CLR R0

RET


 ; load testvectors to sram
	LOADTESTBENCH:

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

	 CLR R0

	   RET

	
	
			/*
			* setter
			*/
		setMessage:
		
				/* set message */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(message)
				LDI YH, high(message)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmessageLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmessageLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setExponent:
				// call ResetMemory
		
			    /* set exponent */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				; wo ich reinschreiben möchte
				LDI YL, low(exponent)
				LDI YH, high(exponent)

				; aktuelle APDU
				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setexponentLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setexponentLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setModulus:
				/* set modulus */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(modulus)
				LDI YH, high(modulus)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmodulusLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmodulusLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setP:
				/* set p */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(p)
				LDI YH, high(p)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setpLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setpLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setQ:
				/* set q */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(q)
				LDI YH, high(q)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setqLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setqLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setpSub1:
				/* set pSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(pSub1)
				LDI YH, high(pSub1)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setpSub1Loop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setpSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		setqSub1:
				/* set qSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(qSub1)
				LDI YH, high(qSub1)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setqSub1Loop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setqSub1Loop	
				POP TMP2
				POP TMP
				POP R19
		RET
		setpInv:
				/* set pInv */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(pInv)
				LDI YH, high(pInv)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setpInvLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setpInvLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setqInv:
				/* set qInv */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(qInv)
				LDI YH, high(qInv)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setqInvLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setqInvLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setmyModulus:
				/* set myModulus */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myModulus)
				LDI YH, high(myModulus)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmyModulusLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmyModulusLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setmyP:
				/* set myP */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myP)
				LDI YH, high(myP)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmyPLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmyPLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setmyQ:
				/* set myQ */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myQ)
				LDI YH, high(myQ)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmyQLoop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmyQLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		setmyPSub1:
				/* set myPSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myPSub1)
				LDI YH, high(myPSub1)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmyPSub1Loop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmyPSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		setmyQsub1:
				/* set myPSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myQSub1)
				LDI YH, high(myQSub1)

				MOV XL, R24
				MOV XH, R25

				LD TMP, X+ // Funktionsauwahlbyte
				LD TMP, X+ // OPLänge 
				setmyQSub1Loop:			
					/* set byte */
					ld TMP2, X+
					/* Store byte */
					ST Y+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE setmyQSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		setLen:
			    PUSH TMP
				/* set setLen */
				MOV XL, R24
				MOV XH, R25

				LD OPLENGTH, X+ // Funktionsauwahlbyte
				LD OPLENGTH, X // OPLänge 		
				POP TMP
		RET
		
		/*
		* getter
		*/
		getMessage:
				/* Read message */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(message)
				LDI YH, high(message)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmessageLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmessageLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getExponent:
			/* Read exponent */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(exponent)
				LDI YH, high(exponent)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getexponentLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
					CP TMP, R19
				BRNE getexponentLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getModulus:
				/* Read modulus */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(modulus)
				LDI YH, high(modulus)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmodulusLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmodulusLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getP:
				/* Read p */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(p)
				LDI YH, high(p)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getpLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getpLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getQ:
				/* Read q */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(q)
				LDI YH, high(q)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getqLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getqLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getpSub1:
				/* Read pSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(pSub1)
				LDI YH, high(pSub1)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getpSub1Loop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getpSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		getqSub1:
				/* Read qSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(qSub1)
				LDI YH, high(qSub1)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getqSub1Loop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getqSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		getpInv:
				/* Read pInv */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(pInv)
				LDI YH, high(pInv)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getpInvLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getpInvLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getqInv:
				/* Read qInv */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(qInv)
				LDI YH, high(qInv)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getqInvLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getqInvLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getmyModulus:
				/* Read myModulus */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myModulus)
				LDI YH, high(myModulus)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmyModulusLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmyModulusLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getmyP:
				/* Read myP */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myP)
				LDI YH, high(myP)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmyPLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmyPLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getmyQ:
				/* Read myQ */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myQ)
				LDI YH, high(myQ)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmyQLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmyQLoop
				POP TMP2
				POP TMP
				POP R19
		RET
		getmyPSub1:
				/* Read myPSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myPSub1)
				LDI YH, high(myPSub1)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmyPSub1Loop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmyPSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		getmyQsub1:
				/* Read myQSub1 */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				LDI YL, low(myQSub1)
				LDI YH, high(myQSub1)
				MOV XL, R24
				MOV XH, R25
				
				LD TMP, X+ ; Fkt. Auswahl Byte			
				LD TMP, X  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getmyQSub1Loop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getmyQSub1Loop
				POP TMP2
				POP TMP
				POP R19
		RET
		
			/************************************************************************
			 *
			 * Needed functions for signature computation
			 * - squareAndMultiply + 2 additional functions sqmSquare, sqmMultiply
			 * - longMul
			 * - modRed
			 * - longADD
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
					LDI YL, low(sqmResult)
					LDI YH, high(sqmResult)
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

				receiveResult: NOP
						/* ReceiveResult */
						PUSH R19
						PUSH TMP
						PUSH TMP2
						CLR R19
				
						LDI YL, low(modResult)
						LDI YH, high(modResult)
						MOV XL, R24
						MOV XH, R25
						
						LD TMP, X+ ; Fkt. Auswahl Byte			
						LD TMP, X  ; Eigene Laenge
						MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
						MOV XH, R25
						receiveResultLoop:			
							/* Read byte */
							LD TMP2, Y+
							/* Store byte */
							ST X+, TMP2
							DEC TMP
						CP TMP, R19
						BRNE receiveResultLoop
						POP TMP2
						POP TMP
						POP R19
				RET

				/**
				 * Used by squareAndMultiply function to square and reduce current value in the algorithm
				 */
				sqmSquare:

					/* Square "result" */
					LDI XL, low(mulResult)
					LDI XH, high(mulResult)
					LDI ZL, low(sqmResult)
					LDI ZH, high(sqmResult)
					LDI YL, low(sqmResult)
					LDI YH, high(sqmResult)
					MOV OPL1, OPLENGTH
					MOV OPL2, OPLENGTH
					RCALL longMul

					/* Reduce */
					LDI XL, low(mulResult)
					LDI XH, high(mulResult)
					MOV YL, MODULUS2
					MOV YH, MODULUS1
					MOV ZL, MY2
					MOV ZH, MY1
					RCALL modRed

					/* Copy result of multiplication to "result" for next multiplication/squaring */
					LDI YL, low(sqmResult)
					LDI YH, high(sqmResult)
					LDI ZL, low(modResult)
					LDI ZH, high(modResult)
					ADIW ZL, 1
					MOV TMP, OPLENGTH

					;Trigger

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
					LDI XL, low(sqmOperand)
					LDI XH, high(sqmOperand)
					MOV TMP, OPLENGTH
					copyResultLoop2:
						LD TMP2, Z+
						ST X+, TMP2
						DEC TMP
					BRNE copyResultLoop2

					/* Multiply "result" and "operand" */	
					LDI XL, low(mulResult)
					LDI XH, high(mulResult)
					LDI YL, low(sqmResult)
					LDI YH, high(sqmResult)
					LDI ZL, low(sqmOperand)
					LDI ZH, high(sqmOperand)
					MOV OPL1, OPLENGTH
					MOV OPL2, OPLENGTH					
					RCALL longMul

					/* Reduce */
					LDI XL, low(mulResult)
					LDI XH, high(mulResult)
					MOV YL, MODULUS2
					MOV YH, MODULUS1
					MOV ZL, MY2
					MOV ZH, MY1
					RCALL modRed

					/* Copy result of multiplication to "result" for next multiplication/squaring */
					LDI YL, low(sqmResult)
					LDI YH, high(sqmResult)
					LDI XL, low(modResult)
					LDI XH, high(modResult)
					ADIW XL, 1
					MOV TMP, OPLENGTH

					;Trigger

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
					SBIW XL, 1

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
							SBIW YL, 1
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

							SBIW XL, 1


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

					SBIW ZL, 1
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
					LDI XL, low(modTmp2)
					LDI XH, high(modTmp2)
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
					LDI XL, low(modTmp)
					LDI XH, high(modTmp)
					MOV TMP, OPLENGTH
					ST X+, NULL
					copyModulusLoop:
						LD TMP2, Z+
						ST X+, TMP2
						DEC TMP
					BRNE copyModulusLoop
					/* Initialize pointers */
					LDI XL, low(modResult)
					LDI XH, high(modResult)
					LDI YL, low(modTmp2)
					LDI YH, high(modTmp2)
					LDI ZL, low(modTmp)
					LDI ZH, high(modTmp)
					ADIW ZL, 1
					/* Determine operand lengths */	
					ADD OPL1, OPL2		
					DEC OPL1
					SUB OPL1, OPLENGTH
					MOV OPL2, OPLENGTH
					/* Calculate r2 */
					RCALL longMul


					/* Initialize pointers */
					LDI XL, low(modResult)
					LDI XH, high(modResult)
					POP YH
					POP YL
					LDI ZL, low(modResult)
					LDI ZH, high(modResult)

					ADD YL, OPLENGTH
					ADC YH, NULL
					SBIW YL, 1

					ADD ZL, OPLENGTH
					ADC ZH, NULL
					ADD ZL, OPLENGTH
					ADC ZH, NULL
					SBIW ZL, 1

					/* Determine operand lengths */
					MOV OPL1, OPLENGTH
					INC OPL1

					/* calculate r = r1 - r2 */
					RCALL longSub

					startModRedWhileLoop:
						LDI YL, low(modTmp)
						LDI YH, high(modTmp)
						LDI ZL, low(modResult)
						LDI ZH, high(modResult)

						MOV OPL1, OPLENGTH
						INC OPL1


						RCALL longSameOrHigher

						BRSH endModRed

						/* Initialize pointers */
						LDI XL, low(modResult)
						LDI XH, high(modResult)
						LDI YL, low(modResult)
						LDI YH, high(modResult)
						LDI ZL, low(modTmp)
						LDI ZH, high(modTmp)

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
				longADD:
					
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
			
		computeResult:
				call ResetMemory
				call LOADTESTBENCH
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
				LDI XL, low(message)
				LDI XH, high(message)
				LDI YL, low(p)
				LDI YH, high(p)
				LDI ZL, low(myP)
				LDI ZH, high(myP)
				/* Calculate xp */
				RCALL modRed

				// RET
				
				/*****************
				 * yp = xp^e mod p
				 *****************/
				/* copy xp to crtTMP */
				LDI YL, low(modResult)
				LDI YH, high(modResult)
				ADIW YL, 1
				LDI ZL, low(crtTMP)
				LDI ZH, high(crtTMP)
				MOV TMP, OPLENGTH
				copyXpLoop:
					LD R18, Y+
					ST Z+, R18
					DEC TMP
				BRNE copyXpLoop

					/* Reduce exponent */
					LDI XL, low(exponent)
					LDI XH, high(exponent)
					LDI YL, low(pSub1)
					LDI YH, high(pSub1)
					LDI ZL, low(myPSub1)
					LDI ZH, high(myPSub1)
					RCALL modRed

					/* Copy reduced exponent to "sqmExponent" */
					LDI YL, low(sqmExponent)
					LDI YH, high(sqmExponent)
					LDI ZL, low(modResult)
					LDI ZH, high(modResult)
					ADIW ZL, 1
					MOV TMP, OPLENGTH
					copyExponentModPLoop:
						LD TMP2, Z+
						ST Y+, TMP2
						DEC TMP
					BRNE copyExponentModPLoop

				/* Let MESSAGE point to xp */
				LDI TMP, low(crtTMP)
				MOV MESSAGE2, TMP
				LDI TMP, high(crtTMP)
				MOV MESSAGE1, TMP
				/* Let EXPONENT point to exponent */
				LDI TMP, low(sqmExponent)
				MOV EXPONENT2, TMP
				LDI TMP, high(sqmExponent)
				MOV EXPONENT1, TMP
				/* Let MY point to myP */
				LDI TMP, low(myP)
				MOV MY2, TMP
				LDI TMP, high(myP)
				MOV MY1, TMP
				/* let MODULUS point to p */
				LDI TMP, low(p)
				MOV MODULUS2, TMP
				LDI TMP, high(p)
				MOV MODULUS1, TMP
				/* Initialize operands length */
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				/* calculate xp^e mod p */
				RCALL squareAndMultiply
				/* copy result to crtYp */
				LDI YL, low(crtYp)
				LDI YH, high(crtYp)
				LDI ZL, low(sqmResult)
				LDI ZH, high(sqmResult)
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
				LDI XL, low(message)
				LDI XH, high(message)
				LDI YL, low(q)
				LDI YH, high(q)
				LDI ZL, low(myQ)
				LDI ZH, high(myQ)
				/* Calculate xq */
				RCALL modRed

				
				/**************
				 * yq = xq^e mod q
				 **************/
				/* copy xq to crtTMP */
				LDI YL, low(modResult)
				LDI YH, high(modResult)
				ADIW YL, 1
				LDI ZL, low(crtTMP)
				LDI ZH, high(crtTMP)
				MOV TMP, OPLENGTH
				copyXqLoop:
					LD R18, Y+
					ST Z+, R18
					DEC TMP
				BRNE copyXqLoop


					/* Reduce exponent */
					LDI XL, low(exponent)
					LDI XH, high(exponent)
					LDI YL, low(qSub1)
					LDI YH, high(qSub1)
					LDI ZL, low(myQSub1)
					LDI ZH, high(myQSub1)
					RCALL modRed

					/* Copy reduced exponent to "sqmExponent" */
					LDI YL, low(sqmExponent)
					LDI YH, high(sqmExponent)
					LDI ZL, low(modResult)
					LDI ZH, high(modResult)
					ADIW ZL, 1
					MOV TMP, OPLENGTH
					copyExponentModQLoop:
						LD TMP2, Z+
						ST Y+, TMP2
						DEC TMP
					BRNE copyExponentModQLoop


				/* Let MESSAGE point to xq */
				LDI TMP, low(crtTMP)
				MOV MESSAGE2, TMP
				LDI TMP, high(crtTMP)
				MOV MESSAGE1, TMP
				/* Let EXPONENT point to exponent */
				LDI TMP, low(sqmExponent)
				MOV EXPONENT2, TMP
				LDI TMP, high(sqmExponent)
				MOV EXPONENT1, TMP
				/* Let MY point to myQ */
				LDI TMP, low(myQ)
				MOV MY2, TMP
				LDI TMP, high(myQ)
				MOV MY1, TMP
				/* let MODULUS point to q */
				LDI TMP, low(q)
				MOV MODULUS2, TMP
				LDI TMP, high(q)
				MOV MODULUS1, TMP
				/* Initialize operands length */
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				/* calculate xp^e mod p */
				RCALL squareAndMultiply
				/* copy result to crtYp */
				LDI YL, low(crtYq)
				LDI YH, high(crtYq)
				LDI ZL, low(sqmResult)
				LDI ZH, high(sqmResult)
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

				LDI XL, low(crtTMP2)
				LDI XH, high(crtTMP2)
				LDI YL, low(q)
				LDI YH, high(q)
				LDI ZL, low(crtYp)
				LDI ZH, high(crtYp)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				RCALL longMul

				LDI XL, low(crtResult1)
				LDI XH, high(crtResult1)
				LDI YL, low(qInv)
				LDI YH, high(qInv)
				LDI ZL, low(crtTMP2)
				LDI ZH, high(crtTMP2)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				ADD OPL2, OPLENGTH
				RCALL longMul



				/*********************
				 * Multiplication 2
				 * yq * My * Cq
				 *********************/

				LDI XL, low(crtTMP2)
				LDI XH, high(crtTMP2)
				LDI YL, low(p)
				LDI YH, high(p)
				LDI ZL, low(crtYq)
				LDI ZH, high(crtYq)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				RCALL longMul

				LDI XL, low(crtResult2)
				LDI XH, high(crtResult2)
				LDI YL, low(pInv)
				LDI YH, high(pInv)
				LDI ZL, low(crtTMP2)
				LDI ZH, high(crtTMP2)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				ADD OPL2, OPLENGTH
				RCALL longMul


				
				/*****************************
				 * Add results
				 * y' = yp * Mp * Cp + yq * Mq * Cq 
				 *****************************/
				LDI XL, low(crtResult3)
				LDI XH, high(crtResult3)
				ADD XL, OPLENGTH
				ADC XH, NULL
				LDI YL, low(crtResult1)
				LDI YH, high(crtResult1)
				LDI ZL, low(crtResult2)
				LDI ZH, high(crtResult2)
				LDI TMP, 3
				MUL OPLENGTH, TMP
				MOV OPL1, R0
				RCALL longADD


				/****************** 
				 * Reduce result 
				 * y = y' mod m
				 ******************/
				LDI XL, low(crtResult3)
				LDI XH, high(crtResult3)
				LDI YL, low(modulus)
				LDI YH, high(modulus)
				LDI ZL, low(myModulus)
				LDI ZH, high(myModulus)
				ADD OPLENGTH, OPLENGTH
				RCALL modRed

				nop
				nop
				nop
				/******************
				 * Send signature
				 ******************/
				;CALL initUart
				;LDI ZL, low(modResult)
				;LDI ZH, high(modResult)
				;ADIW ZL, 1
				;MOV TMP, OPLENGTH
				;CALL sendBytes

				/* Jump to start */
				;JMP initializeRsaParameters
				RET
		
		getLen:
				/* Read getLen */
				MOV XL, R24
				MOV XH, R25
				ST X, OPLENGTH
		RET

;.global	doRSA
;.type	doRSA,@function
doRSA:
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r26
	push r27
	push r28
	push r29
  	push r30
    push r31
			
	call ResetMemory
	call LOADTESTBENCH

	MOV XL, R24
	MOV XH, R25
	// Lese über gesetzten Pointer das Byte in das Register temp=R16 ein
	// Dieses Byte entscheidet welche Funktion angewählt wird
	LD R16, X
	
	LDI R18, 0x08
	MOV OPLENGTH, R18
		
	// setter Auswahl
		CPI R16,0x00
			BREQ setExponentChoice
		CPI R16,0x01
			BREQ setMessageChoice
		CPI R16,0x02
			BREQ setModulusChoice
		CPI R16,0x03
			BREQ setPChoice
		CPI R16,0x04
			BREQ setQChoice
		CPI R16,0x05
			BREQ setpSub1Choice
		CPI R16,0x06
			BREQ setqSub1Choice
		CPI R16,0x07
			BREQ setpInvChoice
		CPI R16,0x08
			BREQ setqInvChoice
		CPI R16,0x09
			BREQ setmyModulusChoice
		CPI R16,0x10
			BREQ setmyPChoice	
		CPI R16,0x11
			BREQ setmyQChoice
		CPI R16,0x12
			BREQ setmyPSub1Choice
		CPI R16,0x13
			BREQ setmyQsub1Choice
		CPI R16,0x14
			BREQ setLenChoice
			
	RJMP zudenGettern
			// Einmal ausführen
			setExponentChoice:
				CALL setExponent
				RJMP ende	
			setMessageChoice:
				CALL setMessage
				RJMP ende	
			setModulusChoice:
				CALL setModulus
				RJMP ende	
			setPChoice:
				CALL setP
				RJMP ende	
			setQChoice:
				CALL setQ
				RJMP ende	
			setpSub1Choice:
				CALL setpSub1
				RJMP ende	
			setqSub1Choice:
				CALL setqSub1
				RJMP ende	
			setpInvChoice:
				CALL setpInv
				RJMP ende	
			setqInvChoice:
				CALL setqInv
				RJMP ende	
			setmyModulusChoice:
				CALL setmyModulus
				RJMP ende	
			setmyPChoice:
				CALL setmyP
				RJMP ende	
			setmyQChoice:
				CALL setmyQ
				RJMP ende	
			setmyPSub1Choice:
				CALL setmyPSub1
				RJMP ende	
			setmyQsub1Choice:
				CALL setmyQsub1
				RJMP ende	
			setLenChoice:
				CALL setLen
				RJMP ende
	zudenGettern: 
			CPI R16,0xA1
				BREQ getExponentChoice
			CPI R16,0xA2
				BREQ getMessageChoice
			CPI R16,0xA3
				BREQ getModulusChoice
			CPI R16,0xA4
				BREQ getPChoice
			CPI R16,0xA5
				BREQ getQChoice
			CPI R16,0xA6
				BREQ getpSub1Choice
			CPI R16,0xA7
				BREQ getqSub1Choice
			CPI R16,0xA8
				BREQ getpInvChoice
			CPI R16,0xA9
				BREQ getqInvChoice
			CPI R16,0xAA
				BREQ getmyModulusChoice
			CPI R16,0xAB
				BREQ getmyPChoice
			CPI R16,0xAC
				BREQ getmyQChoice
			CPI R16,0xAD
				BREQ getmyPSub1Choice
			CPI R16,0xAE
				BREQ getmyQsub1Choice
			CPI R16,0xAF
				BREQ getLenChoice	
			CPI R16,0xDD
				BREQ computeResultChoice
			CPI R16,0xEE
				BREQ receiveResultChoice	
	
	RJMP ende	
	; getter CALLS	
			getExponentChoice:
				CALL getExponent
				RJMP ende	
			getMessageChoice:
				CALL getMessage
				RJMP ende	
			getModulusChoice:
				CALL getModulus
				RJMP ende	
			getPChoice:
				CALL getP
				RJMP ende	
			getQChoice:
				CALL getQ
				RJMP ende	
			getpSub1Choice:
				CALL getpSub1
				RJMP ende	
			getqSub1Choice:
				CALL getqSub1
				RJMP ende	
			getpInvChoice:
				CALL getpInv
				RJMP ende	
			getqInvChoice:
				CALL getqInv
				RJMP ende	
			getmyModulusChoice:
				CALL getmyModulus
				RJMP ende	
			getmyPChoice:
				CALL getmyP
				RJMP ende	
			getmyQChoice:
				CALL getmyQ
				RJMP ende	
			getmyPSub1Choice:
				CALL getmyPSub1
				RJMP ende	
			getmyQsub1Choice:
				CALL getmyQsub1
				RJMP ende	
			getLenChoice:
				CALL getLen
				RJMP ende
			computeResultChoice:
				call computeResult
				RJMP ende	
			receiveResultChoice:
				call receiveResult
	ende: NOP
	
    pop r31
    pop r30
	pop r29
	pop r28
	pop r27
	pop r26
	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
RET


.DSEG

crtTMP: .db 1
crtTMPno1: .db 1
crtTMPno2: .db 1
crtTMPno3: .db 1
crtTMPno4: .db 1
crtTMPno5: .db 1
crtTMPno6: .db 1
crtTMPno7: .db 1
crtTMPno8: .db 1
crtTMPno9: .db 1
crtTMPno10: .db 1
crtTMPno11: .db 1
crtTMPno12: .db 1
crtTMPno13: .db 1
crtTMPno14: .db 1
crtTMPno15: .db 1

crtTmp2: .db 1
crtTmp2no1: .db 1
crtTmp2no2: .db 1
crtTmp2no3: .db 1
crtTmp2no4: .db 1
crtTmp2no5: .db 1
crtTmp2no6: .db 1
crtTmp2no7: .db 1
crtTmp2no8: .db 1
crtTmp2no9: .db 1
crtTmp2no10: .db 1
crtTmp2no11: .db 1
crtTmp2no12: .db 1
crtTmp2no13: .db 1
crtTmp2no14: .db 1
crtTmp2no15: .db 1

crtResult1: .db 1
crtResult1no1: .db 1
crtResult1no2: .db 1
crtResult1no3: .db 1
crtResult1no4: .db 1
crtResult1no5: .db 1
crtResult1no6: .db 1
crtResult1no7: .db 1
crtResult1no8: .db 1
crtResult1no9: .db 1
crtResult1no10: .db 1
crtResult1no11: .db 1
crtResult1no12: .db 1
crtResult1no13: .db 1
crtResult1no14: .db 1
crtResult1no15: .db 1
crtResult1no16: .db 1
crtResult1no17: .db 1
crtResult1no18: .db 1
crtResult1no19: .db 1
crtResult1no20: .db 1
crtResult1no21: .db 1
crtResult1no22: .db 1
crtResult1no23: .db 1
crtResult1no24: .db 1
crtResult1no25: .db 1
crtResult1no26: .db 1
crtResult1no27: .db 1
crtResult1no28: .db 1
crtResult1no29: .db 1
crtResult1no30: .db 1
crtResult1no31: .db 1

crtResult2: .db 1
crtResult2no1: .db 1
crtResult2no2: .db 1
crtResult2no3: .db 1
crtResult2no4: .db 1
crtResult2no5: .db 1
crtResult2no6: .db 1
crtResult2no7: .db 1
crtResult2no8: .db 1
crtResult2no9: .db 1
crtResult2no10: .db 1
crtResult2no11: .db 1
crtResult2no12: .db 1
crtResult2no13: .db 1
crtResult2no14: .db 1
crtResult2no15: .db 1
crtResult2no16: .db 1
crtResult2no17: .db 1
crtResult2no18: .db 1
crtResult2no19: .db 1
crtResult2no20: .db 1
crtResult2no21: .db 1
crtResult2no22: .db 1
crtResult2no23: .db 1
crtResult2no24: .db 1
crtResult2no25: .db 1
crtResult2no26: .db 1
crtResult2no27: .db 1
crtResult2no28: .db 1
crtResult2no29: .db 1
crtResult2no30: .db 1
crtResult2no31: .db 1

crtResult3: .db 1
crtResult3no1: .db 1
crtResult3no2: .db 1
crtResult3no3: .db 1
crtResult3no4: .db 1
crtResult3no5: .db 1
crtResult3no6: .db 1
crtResult3no7: .db 1
crtResult3no8: .db 1
crtResult3no9: .db 1
crtResult3no10: .db 1
crtResult3no11: .db 1
crtResult3no12: .db 1
crtResult3no13: .db 1
crtResult3no14: .db 1
crtResult3no15: .db 1
crtResult3no16: .db 1
crtResult3no17: .db 1
crtResult3no18: .db 1
crtResult3no19: .db 1
crtResult3no20: .db 1
crtResult3no21: .db 1
crtResult3no22: .db 1
crtResult3no23: .db 1
crtResult3no24: .db 1
crtResult3no25: .db 1
crtResult3no26: .db 1
crtResult3no27: .db 1
crtResult3no28: .db 1
crtResult3no29: .db 1
crtResult3no30: .db 1
crtResult3no31: .db 1

crtYp: .db 1
crtYpno1: .db 1
crtYpno2: .db 1
crtYpno3: .db 1
crtYpno4: .db 1
crtYpno5: .db 1
crtYpno6: .db 1
crtYpno7: .db 1

crtYq: .db 1
crtYqno1: .db 1
crtYqno2: .db 1
crtYqno3: .db 1
crtYqno4: .db 1
crtYqno5: .db 1
crtYqno6: .db 1
crtYqno7: .db 1

sqmResult: .db 1
sqmResultno1: .db 1
sqmResultno2: .db 1
sqmResultno3: .db 1
sqmResultno4: .db 1
sqmResultno5: .db 1
sqmResultno6: .db 1
sqmResultno7: .db 1
sqmResultno8: .db 1
sqmResultno9: .db 1
sqmResultno10: .db 1
sqmResultno11: .db 1
sqmResultno12: .db 1
sqmResultno13: .db 1
sqmResultno14: .db 1
sqmResultno15: .db 1

sqmOperand: .db 1
sqmOperandno1: .db 1
sqmOperandno2: .db 1
sqmOperandno3: .db 1
sqmOperandno4: .db 1
sqmOperandno5: .db 1
sqmOperandno6: .db 1
sqmOperandno7: .db 1
sqmOperandno8: .db 1
sqmOperandno9: .db 1
sqmOperandno10: .db 1
sqmOperandno11: .db 1
sqmOperandno12: .db 1
sqmOperandno13: .db 1
sqmOperandno14: .db 1
sqmOperandno15: .db 1

sqmExponent: .db 1
sqmExponentno1: .db 1
sqmExponentno2: .db 1
sqmExponentno3: .db 1
sqmExponentno4: .db 1
sqmExponentno5: .db 1
sqmExponentno6: .db 1
sqmExponentno7: .db 1
sqmExponentno8: .db 1
sqmExponentno9: .db 1
sqmExponentno10: .db 1
sqmExponentno11: .db 1
sqmExponentno12: .db 1
sqmExponentno13: .db 1
sqmExponentno14: .db 1
sqmExponentno15: .db 1

mulResult: .db 1
mulResultno1: .db 1
mulResultno2: .db 1
mulResultno3: .db 1
mulResultno4: .db 1
mulResultno5: .db 1
mulResultno6: .db 1
mulResultno7: .db 1
mulResultno8: .db 1
mulResultno9: .db 1
mulResultno10: .db 1
mulResultno11: .db 1
mulResultno12: .db 1
mulResultno13: .db 1
mulResultno14: .db 1
mulResultno15: .db 1
mulResultno16: .db 1
mulResultno17: .db 1
mulResultno18: .db 1
mulResultno19: .db 1
mulResultno20: .db 1
mulResultno21: .db 1
mulResultno22: .db 1
mulResultno23: .db 1
mulResultno24: .db 1
mulResultno25: .db 1
mulResultno26: .db 1
mulResultno27: .db 1
mulResultno28: .db 1
mulResultno29: .db 1
mulResultno30: .db 1
mulResultno31: .db 1

modTmp: .db 1
modTmpno1: .db 1
modTmpno2: .db 1
modTmpno3: .db 1
modTmpno4: .db 1
modTmpno5: .db 1
modTmpno6: .db 1
modTmpno7: .db 1
modTmpno8: .db 1
modTmpno9: .db 1
modTmpno10: .db 1
modTmpno11: .db 1
modTmpno12: .db 1
modTmpno13: .db 1
modTmpno14: .db 1
modTmpno15: .db 1
modTmpno16: .db 1
modTmpno17: .db 1
modTmpno18: .db 1
modTmpno19: .db 1
modTmpno20: .db 1
modTmpno21: .db 1
modTmpno22: .db 1
modTmpno23: .db 1
modTmpno24: .db 1
modTmpno25: .db 1
modTmpno26: .db 1
modTmpno27: .db 1
modTmpno28: .db 1
modTmpno29: .db 1
modTmpno30: .db 1
modTmpno31: .db 1
modTmpno32: .db 1
modTmpno33: .db 1
modTmpno34: .db 1
modTmpno35: .db 1
modTmpno36: .db 1
modTmpno37: .db 1
modTmpno38: .db 1
modTmpno39: .db 1
modTmpno40: .db 1
modTmpno41: .db 1
modTmpno42: .db 1
modTmpno43: .db 1
modTmpno44: .db 1
modTmpno45: .db 1
modTmpno46: .db 1
modTmpno47: .db 1

modTmp2: .db 1
modTmp2no1: .db 1
modTmp2no2: .db 1
modTmp2no3: .db 1
modTmp2no4: .db 1
modTmp2no5: .db 1
modTmp2no6: .db 1
modTmp2no7: .db 1
modTmp2no8: .db 1
modTmp2no9: .db 1
modTmp2no10: .db 1
modTmp2no11: .db 1
modTmp2no12: .db 1
modTmp2no13: .db 1
modTmp2no14: .db 1
modTmp2no15: .db 1
modTmp2no16: .db 1
modTmp2no17: .db 1
modTmp2no18: .db 1
modTmp2no19: .db 1
modTmp2no20: .db 1
modTmp2no21: .db 1
modTmp2no22: .db 1
modTmp2no23: .db 1
modTmp2no24: .db 1
modTmp2no25: .db 1
modTmp2no26: .db 1
modTmp2no27: .db 1
modTmp2no28: .db 1
modTmp2no29: .db 1
modTmp2no30: .db 1
modTmp2no31: .db 1
modTmp2no32: .db 1
modTmp2no33: .db 1
modTmp2no34: .db 1
modTmp2no35: .db 1
modTmp2no36: .db 1
modTmp2no37: .db 1
modTmp2no38: .db 1
modTmp2no39: .db 1
modTmp2no40: .db 1
modTmp2no41: .db 1
modTmp2no42: .db 1
modTmp2no43: .db 1
modTmp2no44: .db 1
modTmp2no45: .db 1
modTmp2no46: .db 1
modTmp2no47: .db 1

modTmp3: .db 1
modTmp3no1: .db 1
modTmp3no2: .db 1
modTmp3no3: .db 1
modTmp3no4: .db 1
modTmp3no5: .db 1
modTmp3no6: .db 1
modTmp3no7: .db 1
modTmp3no8: .db 1
modTmp3no9: .db 1
modTmp3no10: .db 1
modTmp3no11: .db 1
modTmp3no12: .db 1
modTmp3no13: .db 1
modTmp3no14: .db 1
modTmp3no15: .db 1
modTmp3no16: .db 1
modTmp3no17: .db 1
modTmp3no18: .db 1
modTmp3no19: .db 1
modTmp3no20: .db 1
modTmp3no21: .db 1
modTmp3no22: .db 1
modTmp3no23: .db 1
modTmp3no24: .db 1
modTmp3no25: .db 1
modTmp3no26: .db 1
modTmp3no27: .db 1
modTmp3no28: .db 1
modTmp3no29: .db 1
modTmp3no30: .db 1
modTmp3no31: .db 1
modTmp3no32: .db 1
modTmp3no33: .db 1
modTmp3no34: .db 1
modTmp3no35: .db 1
modTmp3no36: .db 1
modTmp3no37: .db 1
modTmp3no38: .db 1
modTmp3no39: .db 1
modTmp3no40: .db 1
modTmp3no41: .db 1
modTmp3no42: .db 1
modTmp3no43: .db 1
modTmp3no44: .db 1
modTmp3no45: .db 1
modTmp3no46: .db 1
modTmp3no47: .db 1

modResult: .db 1
modResultno1: .db 1
modResultno2: .db 1
modResultno3: .db 1
modResultno4: .db 1
modResultno5: .db 1
modResultno6: .db 1
modResultno7: .db 1
modResultno8: .db 1
modResultno9: .db 1
modResultno10: .db 1
modResultno11: .db 1
modResultno12: .db 1
modResultno13: .db 1
modResultno14: .db 1
modResultno15: .db 1
modResultno16: .db 1
modResultno17: .db 1
modResultno18: .db 1
modResultno19: .db 1
modResultno20: .db 1
modResultno21: .db 1
modResultno22: .db 1
modResultno23: .db 1
modResultno24: .db 1
modResultno25: .db 1
modResultno26: .db 1
modResultno27: .db 1
modResultno28: .db 1
modResultno29: .db 1
modResultno30: .db 1
modResultno31: .db 1
modResultno32: .db 1
modResultno33: .db 1
modResultno34: .db 1
modResultno35: .db 1
modResultno36: .db 1
modResultno37: .db 1
modResultno38: .db 1
modResultno39: .db 1
modResultno40: .db 1
modResultno41: .db 1
modResultno42: .db 1
modResultno43: .db 1
modResultno44: .db 1
modResultno45: .db 1
modResultno46: .db 1
modResultno47: .db 1

exponent: .db 1
exponentno1: .db 1
exponentno2: .db 1
exponentno3: .db 1
exponentno4: .db 1
exponentno5: .db 1
exponentno6: .db 1
exponentno7: .db 1
exponentno8: .db 1
exponentno9: .db 1
exponentno10: .db 1
exponentno11: .db 1
exponentno12: .db 1
exponentno13: .db 1
exponentno14: .db 1
exponentno15: .db 1

message: .db 1
messageno1: .db 1
messageno2: .db 1
messageno3: .db 1
messageno4: .db 1
messageno5: .db 1
messageno6: .db 1
messageno7: .db 1
messageno8: .db 1
messageno9: .db 1
messageno10: .db 1
messageno11: .db 1
messageno12: .db 1
messageno13: .db 1
messageno14: .db 1
messageno15: .db 1

modulus: .db 1
modulusno1: .db 1
modulusno2: .db 1
modulusno3: .db 1
modulusno4: .db 1
modulusno5: .db 1
modulusno6: .db 1
modulusno7: .db 1
modulusno8: .db 1
modulusno9: .db 1
modulusno10: .db 1
modulusno11: .db 1
modulusno12: .db 1
modulusno13: .db 1
modulusno14: .db 1
modulusno15: .db 1

p: .db 1
pno1: .db 1
pno2: .db 1
pno3: .db 1
pno4: .db 1
pno5: .db 1
pno6: .db 1
pno7: .db 1

q: .db 1
qno1: .db 1
qno2: .db 1
qno3: .db 1
qno4: .db 1
qno5: .db 1
qno6: .db 1
qno7: .db 1

pSub1: .db 1
pSub1no1: .db 1
pSub1no2: .db 1
pSub1no3: .db 1
pSub1no4: .db 1
pSub1no5: .db 1
pSub1no6: .db 1
pSub1no7: .db 1

qSub1: .db 1
qSub1no1: .db 1
qSub1no2: .db 1
qSub1no3: .db 1
qSub1no4: .db 1
qSub1no5: .db 1
qSub1no6: .db 1
qSub1no7: .db 1

pInv: .db 1
pInvno1: .db 1
pInvno2: .db 1
pInvno3: .db 1
pInvno4: .db 1
pInvno5: .db 1
pInvno6: .db 1
pInvno7: .db 1

qInv: .db 1
qInvno1: .db 1
qInvno2: .db 1
qInvno3: .db 1
qInvno4: .db 1
qInvno5: .db 1
qInvno6: .db 1
qInvno7: .db 1

myModulus: .db 1
myModulusno1: .db 1
myModulusno2: .db 1
myModulusno3: .db 1
myModulusno4: .db 1
myModulusno5: .db 1
myModulusno6: .db 1
myModulusno7: .db 1
myModulusno8: .db 1
myModulusno9: .db 1
myModulusno10: .db 1
myModulusno11: .db 1
myModulusno12: .db 1
myModulusno13: .db 1
myModulusno14: .db 1
myModulusno15: .db 1
myModulusno16: .db 1
myModulusno17: .db 1
myModulusno18: .db 1
myModulusno19: .db 1
myModulusno20: .db 1
myModulusno21: .db 1
myModulusno22: .db 1
myModulusno23: .db 1
myModulusno24: .db 1
myModulusno25: .db 1
myModulusno26: .db 1
myModulusno27: .db 1
myModulusno28: .db 1
myModulusno29: .db 1
myModulusno30: .db 1
myModulusno31: .db 1

myP: .db 1
myPno1: .db 1
myPno2: .db 1
myPno3: .db 1
myPno4: .db 1
myPno5: .db 1
myPno6: .db 1
myPno7: .db 1
myPno8: .db 1
myPno9: .db 1
myPno10: .db 1
myPno11: .db 1
myPno12: .db 1
myPno13: .db 1
myPno14: .db 1
myPno15: .db 1

myQ: .db 1
myQno1: .db 1
myQno2: .db 1
myQno3: .db 1
myQno4: .db 1
myQno5: .db 1
myQno6: .db 1
myQno7: .db 1
myQno8: .db 1
myQno9: .db 1
myQno10: .db 1
myQno11: .db 1
myQno12: .db 1
myQno13: .db 1
myQno14: .db 1
myQno15: .db 1

myPSub1: .db 1
myPSub1no1: .db 1
myPSub1no2: .db 1
myPSub1no3: .db 1
myPSub1no4: .db 1
myPSub1no5: .db 1
myPSub1no6: .db 1
myPSub1no7: .db 1
myPSub1no8: .db 1
myPSub1no9: .db 1
myPSub1no10: .db 1
myPSub1no11: .db 1
myPSub1no12: .db 1
myPSub1no13: .db 1
myPSub1no14: .db 1
myPSub1no15: .db 1

myQSub1: .db 1
myQSub1no1: .db 1
myQSub1no2: .db 1
myQSub1no3: .db 1
myQSub1no4: .db 1
myQSub1no5: .db 1
myQSub1no6: .db 1
myQSub1no7: .db 1
myQSub1no8: .db 1
myQSub1no9: .db 1
myQSub1no10: .db 1
myQSub1no11: .db 1
myQSub1no12: .db 1
myQSub1no13: .db 1
myQSub1no14: .db 1
myQSub1no15: .db 1





	




