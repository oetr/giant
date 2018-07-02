/*!
   This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
   
   Visit www.sourceforge.net/projects/giant/
   
   Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
   
   This program uses the ZTEX-SDK, available under the GNU General Public 
   License version 3. The SDK is included with this source code. 
   Copyright (C) 2009-2011 ZTEX e.K.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#ifndef[id4D1DC777_3B81_4CE6_A28C2D5428C25DAB]
#define[id4D1DC777_3B81_4CE6_A28C2D5428C25DAB]

/**
 * Set bit $1 in $0
 */
#define[SET_BIT(][,$1)][$0 |= (1 << ($1))];

/**
 * Clear bit $1 in $0
 */
#define[CLEAR_BIT(][,$1)][$0 &= ~(1 << ($1))];

/**
 * Get bit $1 in $0
 */
#define[GET_BIT(][,$1)][((($0) >> ($1)) & 1)];



/**
 * Generate rising edge on bit on $0
 */
#define[GEN_RISING_EDGE(][)][$0 = 0;
SYNCDELAY;
$0 = 1;
SYNCDELAY;
$0 = 0;
SYNCDELAY];

#endif // header
