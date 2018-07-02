//******************************************************************
/*

  Schreiben Sie Ihren CRYPTO Assembler Quelltext in diese Datei!
  
  Setzen Sie den Quelltext der CRYPTO Verschlüsselung hinter die Sprungmarke 'CRYPTO_enc'
  und den Quelltext der Entschlüsselung hinter die Sprungmarke 'CRYPTO_dec'.
  Den beiden Funktionen wird jeweils ein 16-Bit Zeiger auf den 128-Bit Klar- bzw. Geheimtext,
  ein zweiter 16-Bit Zeiger auf den 128-Bit CRYPTO Rundenschlüssel sowie ein dritter Zeiger auf
  512 freie Bytes im SRAM übergeben.
  Achten Sie darauf, daß das Ergebnis der Ver- bzw. Entschlüsselung in den Array
  geschrieben wird, auf den der erSTe Zeiger zeigt.

  WICHTIG: Der 1. Zeiger wird in dem Registerpaar r24(lo),r25(hi), der 2. Zeiger in dem
           RegiSTerpaar in dem Registerpaar r22(lo),r23(hi) und der dritte Zeiger in dem
           Paar r20(lo),r21(hi) übergeben. Siehe die AVR Libc Konventionen
           unter http://savannah.nongnu.org/download/avr-libc/doc/avr-libc-user-manual/ !
           
  Beachten Sie die unterschiedlichen Assembler Konventionen (gcc AVR Assembler <-> AVR Studio 4 Assembler)
  
  AVR Studio 4                       gcc AVR Assembler
  .asm (Datei)                       .S (Datei)
  .def (Direktive)                   .set (Direktive)
  .db                                .byte
  .org                               .balign
  hi                                 hi8
  lo                                 lo8

*/
//******************************************************************


.set xl,26
.set xh,27
.set yl,28
.set yh,29
.set zl,30
.set zh,31
.set sph,0x3e
.set spl,0x3d
.set ramend,0x45f

.set XL,26
.set XH,27
.set YL,28
.set YH,29
.set ZL,30
.set ZH,31

Sbox:

	ldi	ZL,lo8(SboxTable)	 
	ldi	ZH,hi8(SboxTable)	; Initialize Z-pointer to the SboxTable

	add	ZL,r17
	clr	r17
	adc ZH,r17 	; add r17 as input of the Sbox to the table pointer

	lpm r17, Z 	; Load Sbox output to r17

	ret

SboxTable:

.word 0x7c63
.word 0x7b77
.word 0x6bf2
.word 0xc56f
.word 0x0130
.word 0x2b67
.word 0xd7fe
.word 0x76ab
.word 0x82ca
.word 0x7dc9
.word 0x59fa
.word 0xf047
.word 0xd4ad
.word 0xafa2
.word 0xa49c
.word 0xc072
.word 0xfdb7
.word 0x2693
.word 0x3f36
.word 0xccf7
.word 0xa534
.word 0xf1e5
.word 0xd871
.word 0x1531
.word 0xc704
.word 0xc323
.word 0x9618
.word 0x9a05
.word 0x1207
.word 0xe280
.word 0x27eb
.word 0x75b2
.word 0x8309
.word 0x1a2c
.word 0x6e1b
.word 0xa05a
.word 0x3b52
.word 0xb3d6
.word 0xe329
.word 0x842f
.word 0xd153
.word 0xed00
.word 0xfc20
.word 0x5bb1
.word 0xcb6a
.word 0x39be
.word 0x4c4a
.word 0xcf58
.word 0xefd0
.word 0xfbaa
.word 0x4d43
.word 0x8533
.word 0xf945
.word 0x7f02
.word 0x3c50
.word 0xa89f
.word 0xa351
.word 0x8f40
.word 0x9d92
.word 0xf538
.word 0xb6bc
.word 0x21da
.word 0xff10
.word 0xd2f3
.word 0x0ccd
.word 0xec13
.word 0x975f
.word 0x1744
.word 0xa7c4
.word 0x3d7e
.word 0x5d64
.word 0x7319
.word 0x8160
.word 0xdc4f
.word 0x2a22
.word 0x8890
.word 0xee46
.word 0x14b8
.word 0x5ede
.word 0xdb0b
.word 0x32e0
.word 0x0a3a
.word 0x0649
.word 0x5c24
.word 0xd3c2
.word 0x62ac
.word 0x9591
.word 0x79e4
.word 0xc8e7
.word 0x6d37
.word 0xd58d
.word 0xa94e
.word 0x566c
.word 0xeaf4
.word 0x7a65
.word 0x08ae
.word 0x78ba
.word 0x2e25
.word 0xa61c
.word 0xc6b4
.word 0xdde8
.word 0x1f74
.word 0xbd4b
.word 0x8a8b
.word 0x3e70
.word 0x66b5
.word 0x0348
.word 0x0ef6
.word 0x3561
.word 0xb957
.word 0xc186
.word 0x9e1d
.word 0xf8e1
.word 0x1198
.word 0xd969
.word 0x948e
.word 0x1e9b
.word 0xe987
.word 0x55ce
.word 0xdf28
.word 0xa18c
.word 0x0d89
.word 0xe6bf
.word 0x6842
.word 0x9941
.word 0x0f2d
.word 0x54b0
.word 0x16bb

;***********************************************
;END of the SBOX
;***********************************************



;***********************************************
;This is the BYTE-SUBSITUTION Layer of the AES.
;***********************************************

;It uses the SBOX function we defined beforehand
;Pointers:
;X -> state adress
;used registers : r16, r17, Z (in sbox function)

SubBytes:

	ldi		r16,0x10		;Again we use r16 as 								
						;decremental counter

SubBytesLoop:

	ld		r17,X		;load state byte (Ai) from the SRAM 
	call	Sbox			;the SBOX function uses r17
	st		X+,r17	;Ci = ByteSub(Ai) will be stored in
					;the same adress as Ai. Hence it 
					;will be clobbered.
	dec	r16
	brne SubBytesLoop

	ret

;***********************************************
;End Sub Bytes 
;***********************************************



;--------------------------------------------------------------------
;begin encrypt
;Zeiger auf den Plaintext im Registerpaar (r24 (lo),r25 (hi))
;Zeiger auf den 168 Byte Rundenschlüsselspeicher im Registerpaar (r22 (lo),r23 (hi))
;Zeiger auf den 512 Byte freien SRAM im Registerpaar (r20 (lo),r21 (hi))

.global	CRYPTO_enc
.type	CRYPTO_enc,@function
CRYPTO_enc:

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

	;set trigger pin
	SBI		0x17,5
	SBI		0x17,7

	SBI		0x18,5
	SBI		0x18,7
		
	mov		XL,r24		;X will store the adress of the
	mov		XH,r25		;plaintext
	
	mov		YL,r22		;Y will store the adress of the
	mov		YH,r23		;roundkeys
	
AddRoundKey:

	ldi	r16,0x10		;Register16 is used as counter here
					;it will be decremented until zero

AddroundKeyLoop:

	ld	r17,X			;load byte of the plaintext
	ld	r18,Y+			;load byte of the roundkey 
						;afterwards increment the adress
	
	eor	r17,r18			;the bytewise key-xor
						;(r17<-r17 XOR r18)

	st	X+,r17			;store result and increment the address
						;the byte of the plaintext will be
						;clobbered in the SRAM

	dec	r16 			;if counter isnt zero -> proceed
	brne AddroundKeyLoop
	
	;clear trigger pin
	CBI		0x18,5
	CBI		0x18,7

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
	clr r1
        ret

;end encrypt


;--------------------------------------------------------------------
;begin Decrypt
;Zeiger auf den Plaintext im Registerpaar (r24 (lo),r25 (hi))
;Zeiger auf den 168 Byte Rundenschlüsselspeicher im Registerpaar (r22 (lo),r23 (hi))
;Zeiger auf den 512 Byte freien SRAM im Registerpaar (r20 (lo),r21 (hi))

.global	CRYPTO_dec
.type	CRYPTO_dec,@function
CRYPTO_dec:

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

	;set trigger pin
	SBI		0x17,5
	SBI		0x17,7

	SBI		0x18,5
	SBI		0x18,7
		
	mov		XL,r24		;X will store the adress of the
	mov		XH,r25		;plaintext
	
	mov		YL,r22		;Y will store the adress of the
	mov		YH,r23		;roundkeys
	
	
; add key with xor
	
dec_AddRoundKey:

	ldi	r16,0x10		;Register16 is used as counter here
					;it will be decremented until zero

dec_AddroundKeyLoop:

	ld	r17,X			;load byte of the plaintext
	ld	r18,Y+			;load byte of the roundkey 
						;afterwards increment the adress
	
	eor	r17,r18			;the bytewise key-xor
						;(r17<-r17 XOR r18)

	st	X+,r17			;store result and increment the address
						;the byte of the plaintext will be
						;clobbered in the SRAM

	dec	r16 			;if counter isnt zero -> proceed
	brne dec_AddroundKeyLoop
	
	mov		XL,r24		;X will store the adress of the
	mov		XH,r25		;plaintext

	call	SubBytes		;Byte Subsitution Layer	
	
	;clear trigger pin
	CBI		0x18,5
	CBI		0x18,7

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
	clr r1
    ret

;end decrypt

;--------------------------------------------------------------------

;--------------------------------------------------------------------
;begin schedule_key
;Zeiger auf den Schlüssel im Registerpaar (r24 (lo),r25 (hi))
;Zeiger auf den 168 Byte Rundenschlüsselspeicher im Registerpaar (r22 (lo),r23 (hi))
;Zeiger auf den 512 Byte freien SRAM im Registerpaar (r20 (lo),r21 (hi))

.global	schedule_key
.type	schedule_key,@function
schedule_key:

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



	; no keyschedule, just copy the key...

	mov		XL,r24		;X is set to point to the beginning
	mov		XH,r25		;of the key

	mov		YL,r22		;Y is set to point to the beginning
	mov		YH,r23		;of the memory to store the roundkey
	
	ldi		r16,0x10	;r16 is used as counter and set to 16

CopyKeyLoop:

	ld		r17,X+		;current keybyte is stored in r17, X points to the next byte
	st		Y+,r17		;the byte is stored in the roundkeystorage

	dec	r16
	brne CopyKeyLoop		;the whole key (16byte) is copied to the roundkeystorage
	
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
	clr r1
    ret

;end schedule_key

;--------------------------------------------------------------------