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
/** 
The Java API of the <a href="http://www.ztex.de/firmware-kit/index.e.html">ZTEX SDK</a>.
<p>
This API implements access to all ZTEX FPGA Board specific functions from host side. It uses <a href="http://usb4java.org">usb4java</a>, a Java wrapper
for libusb 1.0. 
<p>
<h2>Features</h2>
The main features are:
<ul>
    <li> Platform independent host software. It is possible to pack all necessary files (JNI libraries, firmware, bitstream) into
	 one single jar archive which runs on all supported OS 
    <li> Firmware upload directly to the EZ-USB FX2 and FX3 Microcontrollers
    <li> Firmware upload to non-volatile memory (EEPROM or Flash)
    <li> Bitstream upload directly to the FPGA
    <li> Bitstream upload to Flash memory
    <li> Access to various kinds of non-volatile memory (EEPROM, SPI-Flash, SD-cards)
    <li> Configuration memory (MAC-EEPROM) support
    <li> <a href="http://www.ztex.de/firmware-kit/default.e.html">Default Interface</a> support
	<ul>
	    <li> Multiple communication interfaces: high speed, low speed, GPIO's, reset signal
	    <li> Compatibility allows board independent host software
	</ul>
    </li>
    <li>Licensed as Open Source under GPLv3</li>
</ul>    

<p>
<h2>Communication with the FPGA Board</h2>
Firmware built using the <a href="http://www.ztex.de/firmware-kit/index.e.html">ZTEX SDK</a> supports an additional descriptor, the ZTEX descriptor 1. This descriptor 
identifies the device and firmware, provides compatibility information (e.g. to avoid that a device is loaded with the wrong firmware)
and specifies the communication protocol. A description of the descriptor is given in {@link ztex.ZtexDevice1}.
<p>
The communication protocol defines how the functions provided by the firmware (see main features above)
can be accessed. Currently there is only one protocol implemented, the so called interface 1. 
A description of the interface is given in {@link ztex.Ztex1v1}.
<p>
The most important classes for the interaction with the EZ-USB device / firmware are
<p>
<table bgcolor="#404040" cellspacing=1 cellpadding=4>
  <tr>
     <td bgcolor="#ffffff" valign="top">{@link ztex.ZtexDevice1}</td>
     <td bgcolor="#ffffff" valign="top">Represents an EZ-USB device that supports ZTEX descriptor 1. These devices can be found using {@link ztex.ZtexScanBus1}. </td>
  </tr>
  <tr>
     <td bgcolor="#ffffff" valign="top">{@link ztex.Ztex1}</td>
     <td bgcolor="#ffffff" valign="top">Implementation of interface-independent part of the communication protocol, e.g. uploading the firmware to the EZ-USB and renumeration management.</td>
  </tr>
  <tr>
     <td bgcolor="#ffffff" valign="top">{@link ztex.Ztex1v1}</td>
     <td bgcolor="#ffffff" valign="top">Implementation of the Interface 1, i.e. the interface dependent part of the communication protocol.</td>
  </tr>
</table>

<p>
<h2>SDK overview</h2>
The following diagram gives an overview about the components of the <a href="http://www.ztex.de/firmware-kit/index.e.html">ZTEX SDK</a>.
<p>
<img src="../../imgs/ztex_firmware_kit-diagram2.png" width="800" height="430" alt="SDK for ZTEX FPGA Boards">
<p>
Java host software built with the SDK usually consists in a single jar archive which contains 
<ul>
    <li> all necessary Java bytecode </li>
    <li> the libusb-1.0 JNI wrapper libraries for Linux/X86 (32 and 64 Bit), Linux/ARM (32 Bit), Windows/X86 (32 and 64 Bit) and OSX/X86 (32 and 64 Bit) </li>
    <li> optional: the firmware for the EZ-USB device </li>
    <li> Bitstream for the FPGA </li>
</ul>
This single jar archive runs on all supported operating systems.
<p>
On Linux this jar archive has no additional software requirements. The usb4java/libusb-1.0 library communicates directly with the EZ-USB device using kernel routines.
<p>
On Windows a libusb-1.0 driver must be installed and assigned to the device, see the <a href="http://wiki.ztex.de/doku.php?id=en:software:tutorial_example">Tutorial on the Wiki</a>.
The usb4java library communicates with the EZ-USB device using that driver.

<h2>Related Resources</h2>
Additional information can be found at 
<ul> 
  <li> <a href="http://www.ztex.de/firmware-kit/index.e.html">ZTEX SDK</a>
  <li> <a href="http://wiki.ztex.de/">ZTEX Wiki</a>
</ul>
*/

package ztex;