/*%
   Firmware / Bitstream loader for ZTEX USB-FPGA Modules
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
    Firmware Loader and FPGA Configurator
*/

import java.io.*;
import java.util.*;

import org.usb4java.*;

import ztex.*;

class FWLoader {

// ******* checkSnString *******************************************************
// make sure that snString is 10 chars long
    private static String checkSnString ( String snString ) {
    	if ( snString.length()>10 ) {
    	    snString = snString.substring(0,10);
	    System.err.println( "Serial number too long (max. 10 characters), truncated to `" + snString + "'" );
	}
	while ( snString.length()<10 )
	    snString = '0' + snString;
	return snString;
    }

// ******* main ****************************************************************
    public static void main (String args[]) {

	final String helpMsg = new String (
			"Global parameters:\n"+
			"    -c               Scan for Cypress EZ-USB devices without ZTEX firmware\n"+
			"    -v <VID> <PID>   Scan for devices with given Vendor ID and Product ID\n"+
			"    -vc              Equal to -v 0x4b4 0x8613\n"+
			"    -s <sn string>   Only scan for devices with that serial number\n"+
			"    -d <number>      Device Number (default: 0, use -p to get a list)\n"+
			"    -f               Force uploads\n"+
			"    -p               Print a list of available devices\n"+
			"    -h               This help \n\n"+
			"Ordered parameters:\n"+
			"    -i               Print device info\n"+
			"    -ii              Print device info + capabilities\n"+
			"    -if              Print FPGA state\n"+
			"    -ic              Print configuration data and flash info\n"+
			"    -il              Print log messages of FX3 based FPGA Boards\n"+
			"    -ss <sn string>  Set the serial number, \n"+
			"                     used with -uu or -ue or if configuration data present\n"+
			"    -su <VID> <PID>  Set the USB ID's in configuration memory,\n"+
			"                     0 to load ID's defined by firmware \n"+
			"    -sp <string>     Set the product string in configuration memory, \n"+
			"                     empty string to load firmware default\n"+
			"    -ru              Reset EZ-USB Microcontroller\n"+
			"    -uu <file>       Upload EZ-USB Firmware in ihx or img format to volatile memory\n"+
			"    -bs 0|1|A        Bit swapping for bitstreams: 0: disable, 1: enable, A: automatic detection\n"+
			"    -rf              Reset FPGA\n"+
			"    -uf <bitstream>  Upload bitstream to FPGA\n"+
			"    -sf <number>     Select FPGA (default: 0)\n"+
			"    -re              Reset Firmware in non-volatile memory\n"+
			"    -ue <file>       Upload Firmware in ihx or img format to non-volatile memory\n"+
			"    -rm              Reset bitstream in Flash\n"+
			"    -um <bitstream>  Upload bitstream to Flash\n"+
			"    -uxf <ihx file>  Upload Firmware / data  to ATxmega Flash\n"+
			"    -uxe <ihx file>  Upload data to ATxmega EEPROM\n"+
			"    -rxf <index>     Read ATxmega Fuse\n" +
			"    -wxf <index> <bitmask> <value>  Write ATxmega Fuse\n" +
			"Serial number strings (<sn string>) must be 10 chars long, if shorter they are filled with 0's." );

	if ( ! System.getProperty("os.name").equalsIgnoreCase("linux") ) {
	    Runtime.getRuntime().addShutdownHook(new Thread() {
		public void run() { 
    		    Scanner s=new Scanner(System.in);
    		    System.out.println("Press <enter> to continue ...");
    		    s.nextLine();
		}
	    });	
	}
			
// process global parameters
	try {

	    int usbVendorId = ZtexDevice1.ztexVendorId;
	    int usbProductId = -1;
	    boolean cypress = false;
	    int devNum = 0;
	    boolean forceUpload = false;
	    boolean printBus = false;
	    String snString = null;
	    int bs = -1;
	    
	    if ( args.length == 0 ) {
	    	    System.err.println(helpMsg);
    	    	    System.exit(1);
	    }
	    
	    for (int i=0; i<args.length; i++ ) {
		if ( args[i].equals("-c") ) {
		    cypress = true;
		}
		else if ( args[i].equals("-v") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			usbVendorId = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Vendor ID expected after -v");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			usbProductId = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Product ID expected after -v <VID>");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-vc") ) {
		    usbVendorId = ZtexDevice1.cypressVendorId;
		    usbProductId = ZtexDevice1.cypressProductIdFx2;
		}
		else if ( args[i].equals("-f") ) {
		    forceUpload = true;
		}
		else if ( args[i].equals("-p") ) {
		    printBus = true;
		}
		else if ( args[i].equals("-d") ) {
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			devNum = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Device number expected after -d");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		}
		else if ( args[i].equals("-s") ) {
		    i++;
		    if (i>=args.length) {
			System.err.println("Error: String expected after -s");
			System.err.println(helpMsg);
			System.exit(1);
		    }
    		    snString = checkSnString(args[i]);
		}
		else if ( args[i].equals("-h") ) {
		        System.err.println(helpMsg);
	    	        System.exit(0);
		}
		else if ( args[i].equals("-i") || args[i].equals("-ii") || args[i].equals("-if") || args[i].equals("-ic") || args[i].equals("-il") || args[i].equals("-ru") || args[i].equals("-rf") || args[i].equals("-re") || args[i].equals("-rm") ) {
		}
		else if ( args[i].equals("-uu") || args[i].equals("-uf") || args[i].equals("-sf") || args[i].equals("-ue") || args[i].equals("-um") || args[i].equals("-bs") || args[i].equals("-uxf")  || args[i].equals("-uxe") || args[i].equals("-rxf") || args[i].equals("-ss") || args[i].equals("-sp")) {
		    i+=1;
		}
		else if ( args[i].equals("-su") ) {
		    i+=2;
		}
		else if ( args[i].equals("-wxf") ) {
		    i+=3;
		}
		else {
		    System.err.println("Error: Invalid Parameter: "+args[i]);
		    System.err.println(helpMsg);
		    System.exit(1);
		}
	    }
	    
// Scan the USB. This also creates and initializes a new USB context.
	    ZtexScanBus1 bus = new ZtexScanBus1( usbVendorId, usbProductId, cypress, false, 1, snString);
	    if ( bus.numberOfDevices() <= 0 ) {
		System.err.println("No devices found");
		System.exit(0);
	    }
    	    if ( printBus )
		bus.printBus(System.out);

	    Ztex1v1 ztex = new Ztex1v1 ( bus.device(devNum) );
	    bus.unref();
	    
	    snString = null;
	    for (int i=0; i<args.length; i++ ) {
		if ( args[i].equals("-i") ) {
		    System.out.println( ztex );
		} 
		if ( args[i].equals("-ii") ) {
		    System.out.println( ztex );
		    String str = ztex.capabilityInfo("\n      ");
		    if ( str.equals("") ) {
			System.out.println( "   No capabilities");
		    }	
		    else {
			System.out.println( "   Capabilities:\n      "+str);
		    }
		} 
		if ( args[i].equals("-if") ) {
		    ztex.printFpgaState();
		} 
		if ( args[i].equals("-ic") ) {
		    if ( ztex.config != null ) {
			System.out.println("ZTEX Product: " + ztex.config.getName());
			System.out.println("FPGA: " + ztex.config.getFpga());
			if (ztex.config.getRamSize()>0)  System.out.println("RAM: " + (ztex.config.getRamSize() >> 20) + " MByte " + ztex.config.getRamType());
		    }
		    else {
			System.out.println("(No configuration data found)");
		    }
		    String s = ztex.flashInfo(); if ( s.length()>0 ) System.out.println("Flash: " + s);
		    s = ztex.flash2Info(); if ( s.length()>0 ) System.out.println("2nd Flash: " + s);
		} 
		if ( args[i].equals("-il") ) {
		    try {
		        ztex.debug2PrintNextLogMessages(System.out); 
		        ztex.getUsb3Errors();
		        System.out.println("USB 3.0 send errors: "+ztex.usb3SndErrors + "  receive errors: "+ztex.usb3RcvErrors);
		    }
		    catch ( CapabilityException e ) {
		    }
		}
		else if ( args[i].equals("-ss") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: String expected after -ss");
			System.err.println(helpMsg);
			System.exit(1);
		    }
    		    snString = checkSnString(args[i]);
    		    if ( ztex.config != null ) {
    			ztex.config.setSN(snString);
    		    }
		}
		else if ( args[i].equals("-su") ) {
		    i++;
		    int vid,pid;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			vid = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Vendor ID expected after -su");
			System.err.println(helpMsg);
			System.exit(1);
			vid = -1;
		    }
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
			pid = Integer.decode( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Product ID expected after -su <VID>");
			System.err.println(helpMsg);
			System.exit(1);
			pid = -1;
		    }
		    if ( (vid>=0) && (pid>=0) ) {
		        if ( ztex.config == null ) {
		    	    System.err.println("Warning: can't write USB ID's: no configuration memory present"); 
		        } else {
		    	    ztex.config.setUsbIDs(vid,pid);
		    	}
		    }
		}
		else if ( args[i].equals("-sp") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: String expected after -sp");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    if ( ztex.config == null ) {
		        System.err.println("Warning: can't write prodct string: no configuration memory present"); 
		    } else {
			ztex.config.setProductString(args[i]);
    		    }
		}
		else if ( args[i].equals("-ru") ) {
		    ztex.resetEzUsb();
		} 
		else if ( args[i].equals("-uu") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -uu");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    ZtexImgFile1 imgFile = new ZtexImgFile1( args[i] );
		    if ( snString != null ) 
		        imgFile.setSnString( snString );
		    System.out.println("Firmware upload time: " + ztex.uploadFirmware( imgFile, forceUpload ) + " ms");
		}
		else if ( args[i].equals("-bs") ) {
		    i++;
    	    	    if ( (i>=args.length) || !( args[i].equals("0") || args[i].equals("1") || args[i].equalsIgnoreCase("A") ) ) {
			System.err.println("Error: `0',`1' or `A' expected after -bs");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    if ( args[i].equals("0") ) 
			bs = 0;
		    else if ( args[i].equals("1") ) 
			bs = 1;
		    else bs = -1;
		}
		else if ( args[i].equals("-rf") ) {
		    ztex.resetFpga();
		}
		else if ( args[i].equals("-uf") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -uf");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    System.out.println("FPGA configuration time: " + ztex.configureFpga( args[i], forceUpload, bs ) + " ms");
		} 
		else if ( args[i].equals("-sf") ) {
		    i++;
		    int fn=-1;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			fn = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Number expected after -sf");
			System.err.println(helpMsg);
			System.exit(1);
		    }
    	    	    if ( fn >= 0 ) {
    	    		ztex.selectFpga(fn);
		    }
		} 
		else if ( args[i].equals("-re") ) {
		    ztex.nvDisableFirmware();
		} 
		else if ( args[i].equals("-ue") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -ue");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    ImgFile imgFile;
		    try {
			imgFile = new ZtexImgFile1( args[i] );
			if ( snString != null ) ((ZtexImgFile1)imgFile).setSnString(snString);
		    }
		    catch ( IncompatibleFirmwareException e ) {
			if ( !forceUpload ) throw e;
			imgFile = new ImgFile( args[i] );
		    }
		    System.out.println("Firmware to non-volatile memory upload time: " + ztex.nvUploadFirmware( imgFile, forceUpload ) + " ms");
		}
		else if ( args[i].equals("-rm") ) {
		    System.out.println("First free sector: " + ztex.flashFirstFreeSector() );
		    ztex.flashResetBitstream();
		    System.out.println("First free sector: " + ztex.flashFirstFreeSector() );
		}
		else if ( args[i].equals("-um") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -um");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    System.out.println("First free sector: " + ztex.flashFirstFreeSector() );
		    System.out.println("FPGA configuration time: " + ztex.flashUploadBitstream( args[i], bs ) + " ms");
		    System.out.println("First free sector: " + ztex.flashFirstFreeSector() );
		}
		else if ( args[i].equals("-uxf") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -uxf");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    System.out.println("Firmware to ATxmega Flash upload time: " + ztex.xmegaWriteFirmware( new ImgFile(args[i]) ) + " ms");
		} 
		else if ( args[i].equals("-uxe") ) {
		    i++;
    	    	    if ( i >= args.length ) {
			System.err.println("Error: Filename expected after -uxe");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    System.out.println("Firmware to ATxmega Flash upload time: " + ztex.xmegaWriteEeprom( new ImgFile(args[i]) ) + " ms");
		} 
		else if ( args[i].equals("-rxf") ) {
		    i++;
		    int j = 0;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			j = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Index number expected after -rxf");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    System.out.println("Fuse " + j + ": 0b" + Integer.toBinaryString(256 | ztex.xmegaFuseRead ( j )).substring(1));
		} 
		else if ( args[i].equals("-wxf") ) {
		    i++;
		    int j=0, k=0, l=0;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			j = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Index number expected after -wxf");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			k = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Bitmask expected after -wxf <index>");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    i++;
		    try {
			if (i>=args.length) 
			    throw new Exception();
    			l = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
			System.err.println("Error: Value expected after -wxf <index> <bitmask>");
			System.err.println(helpMsg);
			System.exit(1);
		    }
		    ztex.xmegaFuseWrite( j, (ztex.xmegaFuseRead(j) & ~k) | l );
		} 
	    } 
	    
	    ztex.dispose();

	} 
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	}  
   } 
   
}
