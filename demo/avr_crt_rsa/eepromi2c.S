//  Simple Operating system for Smart cards
//  Copyright (C) 2002  Matthias Bruestle <m@mbsks.franken.de>
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

/*#include "config.h"

#if CONF_WITH_I2CEEPROM==1
	.arch ARCH */
DDRB=0x17
EE_SCL=1
EE_SDA=0
PINB=0x16
PORTB=0x18
	.text
	.global xeread, xewrt, Seqxewrt
XEAddr:
	call  XEStrt
	clc
	ldi	   r17,0xA0
	call  XEEOut
//	call  XE0Bit
	call  GetAck
	mov	   r17,r31
	call  XEEOut
//	call  XE0Bit
	call  GetAck
	mov	   r17,r30
	call  XEEOut
//	call  XE0Bit
	call  GetAck
	ret

; address r25:r24 
; result r25(=0):r24
xeread:
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
	push r28
	push r29
    push r30
    push r31

	mov	r31,r25
	mov	r30,r24
; Start
	call	xereadlocal
; Done
	clr	r25
	mov	r24,r2

    pop r31
    pop r30
	pop r29
	pop r28
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
	ret

; address r31:r30 
; result r2 = XE(Z+)
xereadlocal:
	call	XEAddr
	call	XEStrt
	clc
	ldi		r17,0xA1
	call	XEEOut
	call	XE0Bit
	call	XEEIn
	call	XE1Bit
	call	XEStop
	ret



; E2address  r25:r24 
; Memaddress r23:r22
; Len        r21:r20
Seqxewrt:
	push	r2
	push 	r16
	push 	r17
	push 	r28
	push 	r29
    push 	r30
    push 	r31

	call	PB0Out
	call	PB2Out

	mov		r31,r25
	mov		r30,r24	; Copy E2 address in r31:r30

	call 	XEAddr

	mov		r31,r23
	mov		r30,r22	; Copy memory address in r31:r30 (Z reg)

	mov		r29,r21
	mov		r28,r20	; Copy Len in r29:r28 (Y reg)

SeqxewrtLoop:
	
	ld		r17,Z+	; read from memory to r17 and (address++)
	call  	XEEOut
//	call  XE0Bit
	call  GetAck
	
	sbiw	r28,1

	tst		r28	
	brne	SeqxewrtLoop
	tst		r29
	brne	SeqxewrtLoop

SeqxewrtEnd:

	call	XEStop
//	call	XEDly

    pop 	r31
    pop 	r30
	pop 	r29
	pop 	r28
	pop 	r17
	pop 	r16
	pop 	r2
	clr		r1
	ret



; address r25:r24 
; byte r23(=0):r22
xewrt:
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
	push r28
	push r29
    push r30
    push r31

	mov	r31,r25
	mov	r30,r24
; Start
; address r31:r30 
; result XE(Z+) = r22


	call	xereadlocal
	cp		r2,r22
	breq	dontwrite


	call	XEAddr
	mov		r17,r22
	call	XEEOut
	call	XE0Bit
	call	XEStop
	call	XEDly

dontwrite: 
; Done



    pop r31
    pop r30
	pop r29
	pop r28
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
	ret

XEDly:
	ldi	  r25,0x20
	mov	  r1,r25
avr3B9:
	ldi	  r25,0xFF
avr3BA: 
	dec	  r25
	brne  avr3BA
	dec	  r1
	brne  avr3B9
	ret

XEStrt: 
	call	ClrPB0
	call	SetPB2
	call	SetPB0
	call	ClrPB2
	call	ClrPB0
	ret

XEStop: 
	call	ClrPB0
	call	ClrPB2
	call	SetPB0
	call	SetPB2
	call	ClrPB0
	ret

XEEIn:
	clr r2
	ldi r16,0x08
	call	SetPB2
	call	PB2In
avr3CF: 
	call SetPB0
	sbic  PINB,EE_SDA
	jmp  avr3D5
	clc
	rol r2
	jmp	avr3D7
avr3D5: sec
	rol r2
avr3D7: call	ClrPB0
	dec r16
	brne	avr3CF
	call	PB2Out
	ret

XEEOut: 
	ldi	  r16,0x08
	mov	  r2,r17
avr3DE: 
	clc
	rol	  r2
	brlo  avr3E4
	call ClrPB2
	call ClkPls
	jmp  avr3E6
avr3E4: 
	call SetPB2
	call ClkPls
avr3E6: 
	dec	  r16
	brne  avr3DE
	ret


GetAck:
	
	call	SetPB2
	call	PB2In
	call	SetPB0

GetAckLoop:
	sbic  	PINB,EE_SDA
	jmp		GetAckLoop

	call	ClrPB0
	call	ClrPB2
	call	PB2Out

	ret




XE1Bit:
	call	SetPB2
	call	ClkPls
	ret

XE0Bit: 
	call	ClrPB2
	call	ClkPls
	ret

ClkPls: 
	call	SetPB0
	call	ClrPB0
	ret

SetPB2:
	sbi	 PORTB,EE_SDA
	jmp PBExit

ClrPB2:
	cbi	 PORTB,EE_SDA
	jmp PBExit

SetPB0:
	sbi	 PORTB,EE_SCL
	jmp PBExit

ClrPB0: 
	cbi PORTB,EE_SCL
	jmp	PBExit

PB2Out: 
	sbi	 DDRB,EE_SDA
	jmp PBExit

PB2In:
	cbi	 DDRB,EE_SDA
	jmp PBExit


PB0Out: 
	sbi	 DDRB,EE_SCL
	jmp PBExit

PB0In:
	cbi	 DDRB,EE_SCL
	jmp PBExit


PBExit:
	nop
	nop
	nop
	ret
//#endif /* CONF_WITH_I2CEEPROM==1 */

