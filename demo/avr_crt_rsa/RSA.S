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

.set XL,26
.set XH,27
.set YL,28
.set YH,29
.set ZL,30
.set ZH,31
.set TEMP , 16

/* Register setinitions */

.set OPLENGTH , 5 			; RSA parameters length in byte
.set NULL , 23					; 0x00 Register used for several comparisons and carry addition
.set DIGITPOINTER , 22 		; Used for iteration over exponent bits
.set LIMBPOINTER , 21			; Used for iteration over exponent bytes
.set CURRENTEXPONENTLIMB , 20	; Stores the current exponent byte in exponentiation.
.set MULCOUNTER1 , 19			; Iteration variable
.set MULCOUNTER2 , 18			; Iteration variable
.set TMP2 , 17					; Used for temporary storage
.set TMP, 16					; Used for temporary storage
.set OPL1, 15					; Stores the length of an operand used by a few functions
.set OPL2, 14					; Stores the length of an operand used by a few functions
.set MY2, 13					; Pointers to adresses in memory
.set MY1, 12					; |
.set MESSAGE2 , 11				; |
.set MESSAGE1 , 10				; |
.set MODULUS2 , 9				; |
.set MODULUS1 , 8				; |
.set EXPONENT2 ,7				; |
.set EXPONENT1 , 6				; -

.set sph,0x3e
.set spl,0x3d
.set ramend,0x45f	
	
	RESETMEMORY:
		PUSH ZL
		PUSH ZH
	
		LDI ZL, lo8(crtResult3)
		LDI ZH, hi8(crtResult3)
		LDI TMP2, 0x0F
		deleteSRAM1:
			ST Z+, NULL
			DEC TMP2    
			CPI TMP2, 0x00
		BRNE deleteSRAM1
	
		POP ZH 
		POP ZL
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

				LDI YL, lo8(message)
				LDI YH, hi8(message)

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
			    /* set exponent */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19
				
				//CALL RESETMEMORY ; einmalig den RAM reinigen	

				; wo ich reinschreiben möchte
				LDI YL, lo8(exponent)
				LDI YH, hi8(exponent)

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

				LDI YL, lo8(modulus)
				LDI YH, hi8(modulus)

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

				LDI YL, lo8(p)
				LDI YH, hi8(p)

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

				LDI YL, lo8(q)
				LDI YH, hi8(q)

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

				LDI YL, lo8(pSub1)
				LDI YH, hi8(pSub1)

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

				LDI YL, lo8(qSub1)
				LDI YH, hi8(qSub1)

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

				LDI YL, lo8(pInv)
				LDI YH, hi8(pInv)

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

				LDI YL, lo8(qInv)
				LDI YH, hi8(qInv)

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

				LDI YL, lo8(myModulus)
				LDI YH, hi8(myModulus)

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

				LDI YL, lo8(myP)
				LDI YH, hi8(myP)

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

				LDI YL, lo8(myQ)
				LDI YH, hi8(myQ)

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

				LDI YL, lo8(myPSub1)
				LDI YH, hi8(myPSub1)

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

				LDI YL, lo8(myQSub1)
				LDI YH, hi8(myQSub1)

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

				LDI YL, lo8(message)
				LDI YH, hi8(message)
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

				LDI YL, lo8(exponent)
				LDI YH, hi8(exponent)
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

				LDI YL, lo8(modulus)
				LDI YH, hi8(modulus)
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

				LDI YL, lo8(p)
				LDI YH, hi8(p)
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

				LDI YL, lo8(q)
				LDI YH, hi8(q)
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

				LDI YL, lo8(pSub1)
				LDI YH, hi8(pSub1)
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

				LDI YL, lo8(qSub1)
				LDI YH, hi8(qSub1)
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

				LDI YL, lo8(pInv)
				LDI YH, hi8(pInv)
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

				LDI YL, lo8(qInv)
				LDI YH, hi8(qInv)
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

				LDI YL, lo8(myModulus)
				LDI YH, hi8(myModulus)
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

				LDI YL, lo8(myP)
				LDI YH, hi8(myP)
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

				LDI YL, lo8(myQ)
				LDI YH, hi8(myQ)
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

				LDI YL, lo8(myPSub1)
				LDI YH, hi8(myPSub1)
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
		
		getModResult:
				/* Read getModResult */
				PUSH R19
				PUSH TMP
				PUSH TMP2
				CLR R19

				PUSH YL
				PUSH YH
				
				LDI YL, lo8(crtResult3)
				LDI YH, hi8(crtResult3)
	
				LDI TMP, 0x0F  ; Eigene Laenge
				MOV XL, R24 ; korrigiere Zeiger, gibt leider kein POST-decrement
				MOV XH, R25
				getModResultLoop:			
					/* Read byte */
					LD TMP2, Y+
					/* Store byte */
					ST X+, TMP2
					DEC TMP
				CP TMP, R19
				BRNE getModResultLoop
				
				POP YH
				POP YL
				
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

				LDI YL, lo8(myQSub1)
				LDI YH, hi8(myQSub1)
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
					LDI YL, lo8(sqmResult)
					LDI YH, hi8(sqmResult)
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
				
						LDI YL, lo8(modResult)
						LDI YH, hi8(modResult)
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
					LDI XL, lo8(mulResult)
					LDI XH, hi8(mulResult)
					LDI ZL, lo8(sqmResult)
					LDI ZH, hi8(sqmResult)
					LDI YL, lo8(sqmResult)
					LDI YH, hi8(sqmResult)
					MOV OPL1, OPLENGTH
					MOV OPL2, OPLENGTH
					RCALL longMul

					/* Reduce */
					LDI XL, lo8(mulResult)
					LDI XH, hi8(mulResult)
					MOV YL, MODULUS2
					MOV YH, MODULUS1
					MOV ZL, MY2
					MOV ZH, MY1
					RCALL modRed

					/* Copy result of multiplication to "result" for next multiplication/squaring */
					LDI YL, lo8(sqmResult)
					LDI YH, hi8(sqmResult)
					LDI ZL, lo8(modResult)
					LDI ZH, hi8(modResult)
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
					LDI XL, lo8(sqmOperand)
					LDI XH, hi8(sqmOperand)
					MOV TMP, OPLENGTH
					copyResultLoop2:
						LD TMP2, Z+
						ST X+, TMP2
						DEC TMP
					BRNE copyResultLoop2

					/* Multiply "result" and "operand" */	
					LDI XL, lo8(mulResult)
					LDI XH, hi8(mulResult)
					LDI YL, lo8(sqmResult)
					LDI YH, hi8(sqmResult)
					LDI ZL, lo8(sqmOperand)
					LDI ZH, hi8(sqmOperand)
					MOV OPL1, OPLENGTH
					MOV OPL2, OPLENGTH					
					RCALL longMul

					/* Reduce */
					LDI XL, lo8(mulResult)
					LDI XH, hi8(mulResult)
					MOV YL, MODULUS2
					MOV YH, MODULUS1
					MOV ZL, MY2
					MOV ZH, MY1
					RCALL modRed

					/* Copy result of multiplication to "result" for next multiplication/squaring */
					LDI YL, lo8(sqmResult)
					LDI YH, hi8(sqmResult)
					LDI XL, lo8(modResult)
					LDI XH, hi8(modResult)
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
					LDI XL, lo8(modTmp2)
					LDI XH, hi8(modTmp2)
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
					LDI XL, lo8(modTmp)
					LDI XH, hi8(modTmp)
					MOV TMP, OPLENGTH
					ST X+, NULL
					copyModulusLoop:
						LD TMP2, Z+
						ST X+, TMP2
						DEC TMP
					BRNE copyModulusLoop
					/* Initialize pointers */
					LDI XL, lo8(modResult)
					LDI XH, hi8(modResult)
					LDI YL, lo8(modTmp2)
					LDI YH, hi8(modTmp2)
					LDI ZL, lo8(modTmp)
					LDI ZH, hi8(modTmp)
					ADIW ZL, 1
					/* Determine operand lengths */	
					ADD OPL1, OPL2		
					DEC OPL1
					SUB OPL1, OPLENGTH
					MOV OPL2, OPLENGTH
					/* Calculate r2 */
					RCALL longMul


					/* Initialize pointers */
					LDI XL, lo8(modResult)
					LDI XH, hi8(modResult)
					POP YH
					POP YL
					LDI ZL, lo8(modResult)
					LDI ZH, hi8(modResult)

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
						LDI YL, lo8(modTmp)
						LDI YH, hi8(modTmp)
						LDI ZL, lo8(modResult)
						LDI ZH, hi8(modResult)

						MOV OPL1, OPLENGTH
						INC OPL1


						RCALL longSameOrHigher

						BRSH endModRed

						/* Initialize pointers */
						LDI XL, lo8(modResult)
						LDI XH, hi8(modResult)
						LDI YL, lo8(modResult)
						LDI YH, hi8(modResult)
						LDI ZL, lo8(modTmp)
						LDI ZH, hi8(modTmp)

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

				SBI 0x17, 5
				SBI 0x17, 7
				SBI 0x18, 5
				SBI 0x18, 7
		
				LDI R18, 0x08
				MOV OPLENGTH, R18
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
				LDI XL, lo8(message)
				LDI XH, hi8(message)
				LDI YL, lo8(p)
				LDI YH, hi8(p)
				LDI ZL, lo8(myP)
				LDI ZH, hi8(myP)
				/* Calculate xp */
				RCALL modRed

				
				
				/*****************
				 * yp = xp^e mod p
				 *****************/
				/* copy xp to crtTMP */
				LDI YL, lo8(modResult)
				LDI YH, hi8(modResult)
				ADIW YL, 1
				LDI ZL, lo8(crtTMP)
				LDI ZH, hi8(crtTMP)
				MOV TMP, OPLENGTH
				copyXpLoop:
					LD R18, Y+
					ST Z+, R18
					DEC TMP
				BRNE copyXpLoop

					/* Reduce exponent */
					LDI XL, lo8(exponent)
					LDI XH, hi8(exponent)
					LDI YL, lo8(pSub1)
					LDI YH, hi8(pSub1)
					LDI ZL, lo8(myPSub1)
					LDI ZH, hi8(myPSub1)
					RCALL modRed

					
					
					/* Copy reduced exponent to "sqmExponent" */
					LDI YL, lo8(sqmExponent)
					LDI YH, hi8(sqmExponent)
					LDI ZL, lo8(modResult)
					LDI ZH, hi8(modResult)
					ADIW ZL, 1
					MOV TMP, OPLENGTH
					copyExponentModPLoop:
						LD TMP2, Z+
						ST Y+, TMP2
						DEC TMP
					BRNE copyExponentModPLoop

				/* Let MESSAGE point to xp */
				LDI TMP, lo8(crtTMP)
				MOV MESSAGE2, TMP
				LDI TMP, hi8(crtTMP)
				MOV MESSAGE1, TMP
				/* Let EXPONENT point to exponent */
				LDI TMP, lo8(sqmExponent)
				MOV EXPONENT2, TMP
				LDI TMP, hi8(sqmExponent)
				MOV EXPONENT1, TMP
				/* Let MY point to myP */
				LDI TMP, lo8(myP)
				MOV MY2, TMP
				LDI TMP, hi8(myP)
				MOV MY1, TMP
				/* let MODULUS point to p */
				LDI TMP, lo8(p)
				MOV MODULUS2, TMP
				LDI TMP, hi8(p)
				MOV MODULUS1, TMP
				/* Initialize operands length */
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				/* calculate xp^e mod p */
				RCALL squareAndMultiply
				/* copy result to crtYp */
				LDI YL, lo8(crtYp)
				LDI YH, hi8(crtYp)
				LDI ZL, lo8(sqmResult)
				LDI ZH, hi8(sqmResult)
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
				LDI XL, lo8(message)
				LDI XH, hi8(message)
				LDI YL, lo8(q)
				LDI YH, hi8(q)
				LDI ZL, lo8(myQ)
				LDI ZH, hi8(myQ)
				/* Calculate xq */
				RCALL modRed

				
				
				/**************
				 * yq = xq^e mod q
				 **************/
				/* copy xq to crtTMP */
				LDI YL, lo8(modResult)
				LDI YH, hi8(modResult)
				ADIW YL, 1
				LDI ZL, lo8(crtTMP)
				LDI ZH, hi8(crtTMP)
				MOV TMP, OPLENGTH
				copyXqLoop:
					LD R18, Y+
					ST Z+, R18
					DEC TMP
				BRNE copyXqLoop


					/* Reduce exponent */
					LDI XL, lo8(exponent)
					LDI XH, hi8(exponent)
					LDI YL, lo8(qSub1)
					LDI YH, hi8(qSub1)
					LDI ZL, lo8(myQSub1)
					LDI ZH, hi8(myQSub1)
					RCALL modRed

					/* Copy reduced exponent to "sqmExponent" */
					LDI YL, lo8(sqmExponent)
					LDI YH, hi8(sqmExponent)
					LDI ZL, lo8(modResult)
					LDI ZH, hi8(modResult)
					ADIW ZL, 1
					MOV TMP, OPLENGTH
					copyExponentModQLoop:
						LD TMP2, Z+
						ST Y+, TMP2
						DEC TMP
					BRNE copyExponentModQLoop


				/* Let MESSAGE point to xq */
				LDI TMP, lo8(crtTMP)
				MOV MESSAGE2, TMP
				LDI TMP, hi8(crtTMP)
				MOV MESSAGE1, TMP
				/* Let EXPONENT point to exponent */
				LDI TMP, lo8(sqmExponent)
				MOV EXPONENT2, TMP
				LDI TMP, hi8(sqmExponent)
				MOV EXPONENT1, TMP
				/* Let MY point to myQ */
				LDI TMP, lo8(myQ)
				MOV MY2, TMP
				LDI TMP, hi8(myQ)
				MOV MY1, TMP
				/* let MODULUS point to q */
				LDI TMP, lo8(q)
				MOV MODULUS2, TMP
				LDI TMP, hi8(q)
				MOV MODULUS1, TMP
				/* Initialize operands length */
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				/* calculate xp^e mod p */
				RCALL squareAndMultiply
				/* copy result to crtYp */
				LDI YL, lo8(crtYq)
				LDI YH, hi8(crtYq)
				LDI ZL, lo8(sqmResult)
				LDI ZH, hi8(sqmResult)
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

				LDI XL, lo8(crtTMP2)
				LDI XH, hi8(crtTMP2)
				LDI YL, lo8(q)
				LDI YH, hi8(q)
				LDI ZL, lo8(crtYp)
				LDI ZH, hi8(crtYp)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				RCALL longMul

		
				LDI XL, lo8(crtResult1)
				LDI XH, hi8(crtResult1)
				LDI YL, lo8(qInv)
				LDI YH, hi8(qInv)
				LDI ZL, lo8(crtTMP2)
				LDI ZH, hi8(crtTMP2)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				ADD OPL2, OPLENGTH
				RCALL longMul



				/*********************
				 * Multiplication 2
				 * yq * My * Cq
				 *********************/

				LDI XL, lo8(crtTMP2)
				LDI XH, hi8(crtTMP2)
				LDI YL, lo8(p)
				LDI YH, hi8(p)
				LDI ZL, lo8(crtYq)
				LDI ZH, hi8(crtYq)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				RCALL longMul
				


				LDI XL, lo8(crtResult2)
				LDI XH, hi8(crtResult2)
				LDI YL, lo8(pInv)
				LDI YH, hi8(pInv)
				LDI ZL, lo8(crtTMP2)
				LDI ZH, hi8(crtTMP2)
				MOV OPL1, OPLENGTH
				MOV OPL2, OPLENGTH
				ADD OPL2, OPLENGTH
				RCALL longMul

				CALL RESETMEMORY
				
				/*****************************
				 * Add results
				 * y' = yp * Mp * Cp + yq * Mq * Cq 
				 *****************************/
				LDI XL, lo8(crtResult3)
				LDI XH, hi8(crtResult3)
				ADD XL, OPLENGTH
				ADC XH, NULL
				LDI YL, lo8(crtResult1)
				LDI YH, hi8(crtResult1)
				LDI ZL, lo8(crtResult2)
				LDI ZH, hi8(crtResult2)
				LDI TMP, 3
				MUL OPLENGTH, TMP
				MOV OPL1, R0
				RCALL longADD

				/****************** 
				 * Reduce result 
				 * y = y' mod m
				 ******************/
				LDI XL, lo8(crtResult3)
				LDI XH, hi8(crtResult3)
				LDI YL, lo8(modulus)
				LDI YH, hi8(modulus)
				LDI ZL, lo8(myModulus)
				LDI ZH, hi8(myModulus)
				ADD OPLENGTH, OPLENGTH
				RCALL modRed

				CBI 0x18, 5
				CBI 0x18, 7
				
				RET
		
		getLen:
				/* Read getLen */
				MOV XL, R24
				MOV XH, R25
				ST X, OPLENGTH
		RET

.global	doRSA
.type	doRSA,@function
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
			
	CLR NULL		
			
	MOV XL, R24
	MOV XH, R25
	// Lese über gesetzten Pointer das Byte in das Register temp=R16 ein
	// Dieses Byte entscheidet welche Funktion angewählt wird
	LD R16, X

	
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

.DATA



crtTMP: .byte 1
crtTMPno1: .byte 1
crtTMPno2: .byte 1
crtTMPno3: .byte 1
crtTMPno4: .byte 1
crtTMPno5: .byte 1
crtTMPno6: .byte 1
crtTMPno7: .byte 1

crtTMP2: .byte 1
crtTMP2no1: .byte 1
crtTMP2no2: .byte 1
crtTMP2no3: .byte 1
crtTMP2no4: .byte 1
crtTMP2no5: .byte 1
crtTMP2no6: .byte 1
crtTMP2no7: .byte 1

crtResult1: .byte 1
crtResult1no1: .byte 1
crtResult1no2: .byte 1
crtResult1no3: .byte 1
crtResult1no4: .byte 1
crtResult1no5: .byte 1
crtResult1no6: .byte 1
crtResult1no7: .byte 1
crtResult1no8: .byte 1
crtResult1no9: .byte 1
crtResult1no10: .byte 1
crtResult1no11: .byte 1
crtResult1no12: .byte 1
crtResult1no13: .byte 1
crtResult1no14: .byte 1
crtResult1no15: .byte 1

crtResult2: .byte 1
crtResult2no1: .byte 1
crtResult2no2: .byte 1
crtResult2no3: .byte 1
crtResult2no4: .byte 1
crtResult2no5: .byte 1
crtResult2no6: .byte 1
crtResult2no7: .byte 1
crtResult2no8: .byte 1
crtResult2no9: .byte 1
crtResult2no10: .byte 1
crtResult2no11: .byte 1
crtResult2no12: .byte 1
crtResult2no13: .byte 1
crtResult2no14: .byte 1
crtResult2no15: .byte 1

crtResult3: .byte 1
crtResult3no1: .byte 1
crtResult3no2: .byte 1
crtResult3no3: .byte 1
crtResult3no4: .byte 1
crtResult3no5: .byte 1
crtResult3no6: .byte 1
crtResult3no7: .byte 1
crtResult3no8: .byte 1
crtResult3no9: .byte 1
crtResult3no10: .byte 1
crtResult3no11: .byte 1
crtResult3no12: .byte 1
crtResult3no13: .byte 1
crtResult3no14: .byte 1
crtResult3no15: .byte 1

crtYp: .byte 1
crtYpno1: .byte 1
crtYpno2: .byte 1
crtYpno3: .byte 1

crtYq: .byte 1
crtYqno1: .byte 1
crtYqno2: .byte 1
crtYqno3: .byte 1

sqmResult: .byte 1
sqmResultno1: .byte 1
sqmResultno2: .byte 1
sqmResultno3: .byte 1
sqmResultno4: .byte 1
sqmResultno5: .byte 1
sqmResultno6: .byte 1
sqmResultno7: .byte 1

sqmOperand: .byte 1
sqmOperandno1: .byte 1
sqmOperandno2: .byte 1
sqmOperandno3: .byte 1
sqmOperandno4: .byte 1
sqmOperandno5: .byte 1
sqmOperandno6: .byte 1
sqmOperandno7: .byte 1

sqmExponent: .byte 1
sqmExponentno1: .byte 1
sqmExponentno2: .byte 1
sqmExponentno3: .byte 1
sqmExponentno4: .byte 1
sqmExponentno5: .byte 1
sqmExponentno6: .byte 1
sqmExponentno7: .byte 1

mulResult: .byte 1
mulResultno1: .byte 1
mulResultno2: .byte 1
mulResultno3: .byte 1
mulResultno4: .byte 1
mulResultno5: .byte 1
mulResultno6: .byte 1
mulResultno7: .byte 1
mulResultno8: .byte 1
mulResultno9: .byte 1
mulResultno10: .byte 1
mulResultno11: .byte 1
mulResultno12: .byte 1
mulResultno13: .byte 1
mulResultno14: .byte 1
mulResultno15: .byte 1

modTmp: .byte 1
modTmpno1: .byte 1
modTmpno2: .byte 1
modTmpno3: .byte 1
modTmpno4: .byte 1
modTmpno5: .byte 1
modTmpno6: .byte 1
modTmpno7: .byte 1
modTmpno8: .byte 1
modTmpno9: .byte 1
modTmpno10: .byte 1
modTmpno11: .byte 1
modTmpno12: .byte 1
modTmpno13: .byte 1
modTmpno14: .byte 1
modTmpno15: .byte 1
modTmpno16: .byte 1
modTmpno17: .byte 1
modTmpno18: .byte 1
modTmpno19: .byte 1
modTmpno20: .byte 1
modTmpno21: .byte 1
modTmpno22: .byte 1
modTmpno23: .byte 1

modTmp2: .byte 1
modTmp2no1: .byte 1
modTmp2no2: .byte 1
modTmp2no3: .byte 1
modTmp2no4: .byte 1
modTmp2no5: .byte 1
modTmp2no6: .byte 1
modTmp2no7: .byte 1
modTmp2no8: .byte 1
modTmp2no9: .byte 1
modTmp2no10: .byte 1
modTmp2no11: .byte 1
modTmp2no12: .byte 1
modTmp2no13: .byte 1
modTmp2no14: .byte 1
modTmp2no15: .byte 1
modTmp2no16: .byte 1
modTmp2no17: .byte 1
modTmp2no18: .byte 1
modTmp2no19: .byte 1
modTmp2no20: .byte 1
modTmp2no21: .byte 1
modTmp2no22: .byte 1
modTmp2no23: .byte 1

modTmp3: .byte 1
modTmp3no1: .byte 1
modTmp3no2: .byte 1
modTmp3no3: .byte 1
modTmp3no4: .byte 1
modTmp3no5: .byte 1
modTmp3no6: .byte 1
modTmp3no7: .byte 1
modTmp3no8: .byte 1
modTmp3no9: .byte 1
modTmp3no10: .byte 1
modTmp3no11: .byte 1
modTmp3no12: .byte 1
modTmp3no13: .byte 1
modTmp3no14: .byte 1
modTmp3no15: .byte 1
modTmp3no16: .byte 1
modTmp3no17: .byte 1
modTmp3no18: .byte 1
modTmp3no19: .byte 1
modTmp3no20: .byte 1
modTmp3no21: .byte 1
modTmp3no22: .byte 1
modTmp3no23: .byte 1

modResult: .byte 1
modResultno1: .byte 1
modResultno2: .byte 1
modResultno3: .byte 1
modResultno4: .byte 1
modResultno5: .byte 1
modResultno6: .byte 1
modResultno7: .byte 1
modResultno8: .byte 1
modResultno9: .byte 1
modResultno10: .byte 1
modResultno11: .byte 1
modResultno12: .byte 1
modResultno13: .byte 1
modResultno14: .byte 1
modResultno15: .byte 1
modResultno16: .byte 1
modResultno17: .byte 1
modResultno18: .byte 1
modResultno19: .byte 1
modResultno20: .byte 1
modResultno21: .byte 1
modResultno22: .byte 1
modResultno23: .byte 1

exponent: .byte 1
exponentno1: .byte 1
exponentno2: .byte 1
exponentno3: .byte 1
exponentno4: .byte 1
exponentno5: .byte 1
exponentno6: .byte 1
exponentno7: .byte 1

message: .byte 1
messageno1: .byte 1
messageno2: .byte 1
messageno3: .byte 1
messageno4: .byte 1
messageno5: .byte 1
messageno6: .byte 1
messageno7: .byte 1

modulus: .byte 1
modulusno1: .byte 1
modulusno2: .byte 1
modulusno3: .byte 1
modulusno4: .byte 1
modulusno5: .byte 1
modulusno6: .byte 1
modulusno7: .byte 1

p: .byte 1
pno1: .byte 1
pno2: .byte 1
pno3: .byte 1

q: .byte 1
qno1: .byte 1
qno2: .byte 1
qno3: .byte 1

pSub1: .byte 1
pSub1no1: .byte 1
pSub1no2: .byte 1
pSub1no3: .byte 1

qSub1: .byte 1
qSub1no1: .byte 1
qSub1no2: .byte 1
qSub1no3: .byte 1

pInv: .byte 1
pInvno1: .byte 1
pInvno2: .byte 1
pInvno3: .byte 1

qInv: .byte 1
qInvno1: .byte 1
qInvno2: .byte 1
qInvno3: .byte 1

myModulus: .byte 1
myModulusno1: .byte 1
myModulusno2: .byte 1
myModulusno3: .byte 1
myModulusno4: .byte 1
myModulusno5: .byte 1
myModulusno6: .byte 1
myModulusno7: .byte 1
myModulusno8: .byte 1
myModulusno9: .byte 1
myModulusno10: .byte 1
myModulusno11: .byte 1
myModulusno12: .byte 1
myModulusno13: .byte 1
myModulusno14: .byte 1
myModulusno15: .byte 1

myP: .byte 1
myPno1: .byte 1
myPno2: .byte 1
myPno3: .byte 1
myPno4: .byte 1
myPno5: .byte 1
myPno6: .byte 1
myPno7: .byte 1

myQ: .byte 1
myQno1: .byte 1
myQno2: .byte 1
myQno3: .byte 1
myQno4: .byte 1
myQno5: .byte 1
myQno6: .byte 1
myQno7: .byte 1

myPSub1: .byte 1
myPSub1no1: .byte 1
myPSub1no2: .byte 1
myPSub1no3: .byte 1
myPSub1no4: .byte 1
myPSub1no5: .byte 1
myPSub1no6: .byte 1
myPSub1no7: .byte 1

myQSub1: .byte 1
myQSub1no1: .byte 1
myQSub1no2: .byte 1
myQSub1no3: .byte 1
myQSub1no4: .byte 1
myQSub1no5: .byte 1
myQSub1no6: .byte 1
myQSub1no7: .byte 1



