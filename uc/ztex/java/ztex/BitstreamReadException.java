/*%
   Java host software API of ZTEX SDK
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

package ztex;

import java.io.*;
/** * 	Signals that an error occurred while attempting to read a bitstream. */
public class BitstreamReadException extends IOException {
/** 
 * Constructs an instance from the given error message.
 * @param msg The error message.
 */
    public BitstreamReadException(String msg) {
	super( "Cannot read bitstream: "+msg );
    }

/** * Constructs an instance using a standard message. */
    public BitstreamReadException() {
	super( "Cannot read bitstream" );
    }
}    
