/*%
   ZTEX Firmware Kit for EZ-USB FX2 Microcontrollers
   Copyright (C) 2009-2017 ZTEX GmbH.
   http://www.ztex.de
   
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this file,
   You can obtain one at http://mozilla.org/MPL/2.0/.

   Alternatively, the contents of this file may be used under the terms
   of the GNU General Public License Version 3, as described below:

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
%*/

/* 
   EZ-USB Autovectors
*/

#ifndef[EZINTAVECS_H]
#define[EZINTAVECS_H]

#include[ztex-utils.h]

struct INTVEC {
    BYTE op;
    BYTE addrH;
    BYTE addrL;
};

#define[INTVECS;][DEFINE_INTVEC(0x0003,INT0VEC_IE0);
DEFINE_INTVEC(0x000b,INT1VEC_T0);
DEFINE_INTVEC(0x0013,INT2VEC_IE1);
DEFINE_INTVEC(0x001b,INT3VEC_T1);
DEFINE_INTVEC(0x0023,INT4VEC_USART0);
DEFINE_INTVEC(0x002b,INT5VEC_T2);
DEFINE_INTVEC(0x0033,INT6VEC_RESUME);
DEFINE_INTVEC(0x003b,INT7VEC_USART1);
DEFINE_INTVEC(0x0043,INT8VEC_USB);
DEFINE_INTVEC(0x004b,INT9VEC_I2C);
DEFINE_INTVEC(0x0053,INT10VEC_GPIF);
DEFINE_INTVEC(0x005b,INT11VEC_IE5);
DEFINE_INTVEC(0x0063,INT12VEC_IE6);
DEFINE_INTVEC(0x0100,INTVEC_SUDAV);
DEFINE_INTVEC(0x0104,INTVEC_SOF);
DEFINE_INTVEC(0x0108,INTVEC_SUTOK);
DEFINE_INTVEC(0x010C,INTVEC_SUSPEND);
DEFINE_INTVEC(0x0110,INTVEC_USBRESET);
DEFINE_INTVEC(0x0114,INTVEC_HISPEED);
DEFINE_INTVEC(0x0118,INTVEC_EP0ACK);
DEFINE_INTVEC(0x0120,INTVEC_EP0IN);
DEFINE_INTVEC(0x0124,INTVEC_EP0OUT);
DEFINE_INTVEC(0x0128,INTVEC_EP1IN);
DEFINE_INTVEC(0x012C,INTVEC_EP1OUT);
DEFINE_INTVEC(0x0130,INTVEC_EP2);
DEFINE_INTVEC(0x0134,INTVEC_EP4);
DEFINE_INTVEC(0x0138,INTVEC_EP6);
DEFINE_INTVEC(0x013C,INTVEC_EP8);
DEFINE_INTVEC(0x0140,INTVEC_IBN);
DEFINE_INTVEC(0x0148,INTVEC_EP0PING);
DEFINE_INTVEC(0x014C,INTVEC_EP1PING);
DEFINE_INTVEC(0x0150,INTVEC_EP2PING);
DEFINE_INTVEC(0x0154,INTVEC_EP4PING);
DEFINE_INTVEC(0x0158,INTVEC_EP6PING);
DEFINE_INTVEC(0x015C,INTVEC_EP8PING);
DEFINE_INTVEC(0x0160,INTVEC_ERRLIMIT);
DEFINE_INTVEC(0x0170,INTVEC_EP2ISOERR);
DEFINE_INTVEC(0x0174,INTVEC_EP4ISOERR);
DEFINE_INTVEC(0x0178,INTVEC_EP6ISOERR);
DEFINE_INTVEC(0x017C,INTVEC_EP8ISOERR);
DEFINE_INTVEC(0x0180,INTVEC_EP2PF);
DEFINE_INTVEC(0x0184,INTVEC_EP4PF);
DEFINE_INTVEC(0x0188,INTVEC_EP6PF);
DEFINE_INTVEC(0x018C,INTVEC_EP8PF);
DEFINE_INTVEC(0x0190,INTVEC_EP2EF);
DEFINE_INTVEC(0x0194,INTVEC_EP4EF);
DEFINE_INTVEC(0x0198,INTVEC_EP6EF);
DEFINE_INTVEC(0x019C,INTVEC_EP8EF);
DEFINE_INTVEC(0x01A0,INTVEC_EP2FF);
DEFINE_INTVEC(0x01A8,INTVEC_EP6FF);
DEFINE_INTVEC(0x01AC,INTVEC_EP8FF);
DEFINE_INTVEC(0x01B0,INTVEC_GPIFDONE);
DEFINE_INTVEC(0x01B4,INTVEC_GPIFWF);]

#define[DEFINE_INTVEC(][,$1);][__xdata __at $0 struct INTVEC $1;]
INTVECS;
#udefine[DEFINE_INTVEC(]

void abscode_intvec()// _naked
{
#define[DEFINE_INTVEC(][,$1);][    .org $0
	reti]
    __asm
    .area ABSCODE (ABS,CODE)
    .org 0x0000
ENTRY:
	ljmp #0x0200
INTVECS;
    .org 0x01b8
INTVEC_DUMMY:
        reti
    .area CSEG    (CODE)
    __endasm;    
}    

#udefine[INTVECS;]
#udefine[DEFINE_INTVEC(]


/* Init an interrupt vector */
#define[INIT_INTERRUPT_VECTOR(][,$1);][{
    $0.op=0x02;
    $0.addrH=((unsigned short)(&$1)) >> 8;
    $0.addrL=(unsigned short)(&$1);
}]


/* Enable USB autovectors */
#define[ENABLE_AVUSB;][{
    INT8VEC_USB.op=0x02;
    INT8VEC_USB.addrH = 0x01;
    INT8VEC_USB.addrL = 0xb8;
    INTSETUP |= 8;
}]


/* Disable USB autovectors */
#define[DISABLE_AVUSB;][INTSETUP &= ~8;]


/* Enable GPIF autovectors */
#define[ENABLE_AVGPIF;][{
    INT10VEC_GPIF.op=0x02;
    INT10VEC_GPIF.addrH = 0x01;
    INT10VEC_GPIF.addrL = 0xb8;
    INTSETUP |= 3;
}]


/* Disable GPIF autovectors */
#define[DISABLE_AVPGIF;][INTSETUP &= ~3;]


#endif   /* INTAVECS_H */
