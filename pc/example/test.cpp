/*!
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
!*/

#include <sstream>
#include <utility>
#include <iomanip>
#include <fstream>

#include <plot/trace_display_window_manager.h>
#include <dbgstream.h>
#include <keyboard.h>
#include <fault_fpga_spartan6.h>
#include <pic_programmer.h>
#include <dac.h>
#include <smartcard.h>
#include <adc.h>
#include <rfid.h>
#include <ddr.h>


// send PPS (write MSByte first), select T = 1
// 0xff 0x02 0xff ^ 0x02
// 10101010 10000001 00000000
// NAD PCB LEN CLA INS P1 P2 LC 16ByteAes LE EDC
/*const uint8_t aes_len = 4 + 1 + 16 + 1;
uint8_t test_apdu_aes[] = { 0x00, 0x00, len, 0x80, 0x40, 0x00, 0x00, 0x10,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x10, 0x00
};*/

/*
	Addieren
	/send 804000000301[X][Y]01   X mal Y auf ein (anfangs leeres) Register draufaddieren
		Beispiele
		804000000301[01][03]01  ergebnis = 0x03 (0+3)
		804000000301[02][03]01  ergebnis = 0x06 (0+3+3)
		804000000301[03][03]01  ergebnis = 0x09 (0+3+3+3)

	MULTIPLIZIEREN
	/send 804000000302[X][Y]01   X mal Y miteinander multiplizieren lassen (nur ein Limb!)
		Beispiele
		804000000302[01][02]01 ergebnis = 0x04 (2*2)
		804000000302[02][02]01 ergebnis = 0x08 (2*2*2)
		804000000302[03][02]01 ergebnis = 0x10 (2*2*2*2)

	/send 804000000203[X]01 // Sub(x)
		Beispiele
		804000000203[00]01  ergebnis = 0x63
		804000000203[01]01  ergebnis = 0x7C

*/
/*const uint8_t len = 4 + 1 + 3 + 1;
uint8_t test_apdu[] = { 0x00, 0x00, len, 0x80, 0x40, 0x00, 0x00, 0x03,
	0x02, 0x2, 0x3, 
	0x01, 0x00
};*/

/*const uint8_t len = 4 + 1 + 2 + 1;
uint8_t test_apdu[] = { 0x00, 0x00, len, 0x80, 0x40, 0x00, 0x00, 0x02,
	0x03, 0x00,  
	0x01, 0x00
};

uint8_t edc = 0;
for(unsigned int i = 0; i < sizeof(test_apdu)-1; i++) {
	edc ^= test_apdu[i];
}

test_apdu[sizeof(test_apdu)-1] = edc;*/

/*const uint8_t len = 4 + 1 + 8 + 1;
uint8_t test_apdu[] = {
	0x00, 0xA4, 0x04, 0x00, 0x08,
	0xA0, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00
};*/

/*uint8_t test_apdu_S3CC9P9[] = {
        0x80, 0x50, 0x00, 0x00, 0x08, 
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    };*/
	
/*
Versorgungsspannung: 5 V
T=0-Protokoll

Kommandos zum Chip:

einmalig:
reset:
send: 00 7C 88 02 01
send: 01
send: 00 7C 88 00 01
send: 00
send: 00 7C 88 01 01
send: 00
reset:
send: 00 53 02 01 02  (keine Daten)

Mess-Schleife:
send: 00 53 02 01 02   (keine Daten)

Der Störpuls sollte 6.5 ms nach der fallenden Flanke des Kommandos erfolgen.
Parameter:
Spannung: -5,0 V
Pulsbreite: ca. 420 ns - 500 ns
Pulsflanken: 15 ns
*/

static void smartcard_test(fault_fpga_spartan6* fpga) 
{
	// setup vfi
	dac vfi;
	vfi.setEnabled(true);
	
	// smartcard interface
	smartcard sc;
	
	const double v_step = 12.0/256.0;
	//const uint8_t v_dd = static_cast<uint8_t>(5.0/v_step + 128.0);
	const uint8_t v_dd = static_cast<uint8_t>(-3.3/v_step + 128.0);
	//const uint8_t v_fault =  static_cast<uint8_t>(-5.0/v_step + 128.0);
	const uint8_t v_fault =  static_cast<uint8_t>(-2/v_step + 128.0);
	
	dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
		static_cast<unsigned int>(v_fault) << std::endl;
	
	vfi.setHighVoltage(v_fault);
	vfi.setLowVoltage(v_dd);
	vfi.setOffVoltage(128);
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_SC_SENT, true);

	// get status
	uint8_t status = sc.getStatus();
	dbg::out(dbg::info) << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;

	// reset, get ATR
	byte_buffer_t atr = sc.resetAndGetAtr();
	
	// Expected ATR for AVR funcard (21 byte)
	// 3b bb 11 00 91 81 31 46 15 65 73 54 61 72 67 65 74 20 76 31 98
	
	dbg::out(dbg::info) << "ATR: ";
	util::hexdump(dbg::out(dbg::info), atr);
	dbg::out(dbg::info) << std::endl;
	
	
	
	const uint8_t aes_len = 4 + 1 + 16 + 1;
	uint8_t test_apdu_aes[] = { 
		0x00, 0x00, aes_len, 0x80, 0x40, 0x00, 0x00, 0x10,
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
		0x10, 0x00
	};
	
	uint8_t edc = 0;
	for(unsigned int i = 0; i < sizeof(test_apdu_aes)-1; i++) {
		edc ^= test_apdu_aes[i];
	}

	test_apdu_aes[sizeof(test_apdu_aes)-1] = edc;
	
	byte_buffer_t test_apdu(test_apdu_aes, test_apdu_aes + sizeof(test_apdu_aes));

	double offset = 3e6;
	while(1)
	{
		vfi.clearPulses();
		vfi.addPulse(offset, 100);
		offset += 50;
		vfi.arm();
		
		util::hexdump(dbg::out(dbg::info), test_apdu);
		dbg::out(dbg::info) << std::endl;

		dbg::out(dbg::info) << "RX (" << sc.getRxPending() << "): ";
		//byte_buffer_t rx = sc.handleT0Command(test_apdu);
		byte_buffer_t rx = sc.handleRxTx(test_apdu, 1);
		util::hexdump(dbg::out(dbg::info), rx);
		dbg::out(dbg::info) << std::endl;
		
		usleep(1e6);
	}
}

static void generic_test(fault_fpga_spartan6* fpga) 
{
	// get status
	for(unsigned int i = 32; i < 50; i++) 
	{
		uint8_t reg = fpga->readRegister(i);
		dbg::out(dbg::info) << util::u8bs(reg) << std::endl;
		fpga->writeRegister(i, i-32);
	}
	
	dbg::out(dbg::info) << "---" << std::endl;
	
	for(unsigned int i = 32; i < 50; i++) 
	{
		uint8_t reg = fpga->readRegister(i);
		dbg::out(dbg::info) << util::u8bs(reg) << std::endl;
		fpga->writeRegister(i, i+206);
	}
	
	dbg::out(dbg::info) << "---" << std::endl;
	
	for(unsigned int i = 32; i < 55; i++) 
	{
		uint8_t reg = fpga->readRegister(i);
		dbg::out(dbg::info) << util::u8bs(reg) << std::endl;
	}
}

static void vfi_test() 
{
	dac vfi;
	
	vfi.setEnabled(true);
	vfi.setTestModeEnabled(false);
	vfi.setRfidModeEnabled(false);
	
	const double v_step = 12.0/256.0;
	const uint8_t v_dd = static_cast<uint8_t>(5.0/v_step + 128.0);
	const uint8_t v_fault =  static_cast<uint8_t>(-5.0/v_step + 128.0);
	
	dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
		static_cast<unsigned int>(v_fault) << std::endl;
	
	vfi.setHighVoltage(0);
	vfi.setLowVoltage(255);
	vfi.setOffVoltage(128);

	unsigned int w = 10;
	while(1)
	{
		vfi.clearPulses();
		vfi.addPulse(100, w);
		w+= 10;
		vfi.arm();
		vfi.softwareTrigger();
		usleep(.5e6);
	}
	// arm DAC before issueing read command
	//fi.arm();
}

static void rfid_test() 
{
	dac vfi;
	rfid reader;
	
	vfi.setEnabled(true);
	vfi.setTestModeEnabled(false);
	vfi.setRfidModeEnabled(true);
	
	const double v_step = 12.0/256.0;
	const uint8_t v_dd = static_cast<uint8_t>(5.0/v_step + 128.0);
	const uint8_t v_fault =  static_cast<uint8_t>(-5.0/v_step + 128.0);
	
	dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
		static_cast<unsigned int>(v_fault) << std::endl;
	
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_RFID, true);
	vfi.setHighVoltage(255);
	vfi.setLowVoltage(0);
	vfi.setOffVoltage(128);

	for(double w = 100;; w+=2000)
	{
		vfi.clearPulses();
		//vfi.addPulse(100e3, 100);
		//vfi.arm();
		
		dbg::out(dbg::info) << "w = " << w << ", Status (before): ";
		dbg::out(dbg::info) << util::u8bs(reader.getStatus()) << std::endl;
		
		reader.transmitShortFrame(0x26); 
		
		dbg::out(dbg::info) << "Status (after): ";
		dbg::out(dbg::info) << util::u8bs(reader.getStatus()) << std::endl;
		
		usleep(.5e6);
		vfi.setEnabled(false);
		
		usleep(.5e6);
		vfi.setEnabled(true);
	}

}

static void rfid_test(fault_fpga_spartan6* fpga) 
{
	dac vfi;
	rfid reader;
	
	vfi.setEnabled(true);
	vfi.setTestModeEnabled(false);
	vfi.setRfidModeEnabled(true);
	
	const double v_step = 12.0/256.0;
	const uint8_t v_dd = static_cast<uint8_t>(5.0/v_step + 128.0);
	const uint8_t v_fault =  static_cast<uint8_t>(-5.0/v_step + 128.0);
	
	dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
		static_cast<unsigned int>(v_fault) << std::endl;
	
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_RFID, true);
	vfi.setHighVoltage(255);
	vfi.setLowVoltage(0);
	vfi.setOffVoltage(128);

	
	for(uint8_t i = 0;;i+=4)
	{
		vfi.clearPulses();
		/*vfi.addPulse(100e3, 10000);
		vfi.arm();
		
		vfi.setHighVoltage(i);*/
		
		dbg::out(dbg::info) << "Status (before): ";
		dbg::out(dbg::info) << util::u8bs(reader.getStatus()) << std::endl;
		
		reader.transmitShortFrame(0x26); 
		
		dbg::out(dbg::info) << "Status (after): ";
		dbg::out(dbg::info) << util::u8bs(reader.getStatus()) << std::endl;

		
		/*usleep(.5e6);
		vfi.setEnabled(false);
		
		usleep(.5e6);
		vfi.setEnabled(true);*/
	}
}

static void ddr_test() 
{
	// DDR control object
	ddr ram;
	
	// list of random memory blocks with random values
	const unsigned int block_count = 2;
	const unsigned int block_size = 512;
	// Memory size in 32 bit words
	const unsigned int mem_size = (1 << 26)/4;
	
	std::vector< std::vector<uint32_t> > blocks;
	blocks.resize(block_count);
	std::vector<uint32_t> addresses;
	addresses.resize(block_count);
	
	srand(time(0));
	for(unsigned int i = 0; i < block_count; i++)
	{
		do {
			addresses[i] = rand() % mem_size;
		} while(addresses[i] + block_size >= mem_size);
		
		blocks[i].resize(block_size);
		
		// write
		for(uint32_t a = 0; a < block_size; a++)
		{
			blocks[i][a] = rand();
			ram.writeSingleWord(addresses[i] + a, blocks[i][a]);
		}
		
		dbg::out(dbg::info) << "-> Block " << std::dec << i << ", addr = "
			<< util::u32hs(addresses[i]) << std::endl;
	}
	
	// read back and compare
	for(unsigned int i = 0; i < block_count; i++)
	{
	
		dbg::out(dbg::info) << "<- Block " << std::dec << i << ", addr = "
			<< util::u32hs(addresses[i]) << std::endl;
			
		ddr::buffer_t block = ram.readBurst(addresses[i], block_size);
		util::hexdump(dbg::out(dbg::info), block, 4, addresses[i]);
		dbg::out(dbg::info) << std::endl;
		
		// read block
		for(uint32_t a = 0; a < block_size; a++)
		{
			uint32_t data = ram.readSingleWord(a + addresses[i]);
			
			// check data words
			if(data != blocks[i][a] || block[a] != blocks[i][a]) 
			{
				dbg::out(dbg::info) << "! Block " << std::dec << i << ", addr = "
					<< util::u32hs(a + addresses[i]) << ": Read " 
					<< util::u32hs(data) << " and " << util::u32hs(block[a]) 
					<< " (FIFO), wrote " << util::u32hs(blocks[i][a]) << std::endl;
			}
		}
	}
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
	
	
	// Read back (burst)
	ddr::buffer_t data = ram.readBurst(16, 6*1024);
	dbg::out(dbg::info) << std::endl;
	dbg::out(dbg::info) << "-- RX: " << std::dec << data.size() << " byte" << std::endl;
	dbg::out(dbg::info) << std::endl;
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
	
	dbg::out(dbg::info) << "=== Benchmark" << std::endl;
	
	const unsigned int buf_count = 10;
	const unsigned int buf_size = 1 << 24;;
	const unsigned int buf_size_mb = (buf_size*4)/(1 << 20);
	
	double total_time = 0;
	for(unsigned int buf = 0; buf < buf_count; buf++)
	{
		dbg::out(dbg::info) << "." << std::endl;
		double begin = util::get_timer();
		ddr::buffer_t data = ram.readBurst(0, buf_size); //addresses[buf % block_count]
		double end = util::get_timer();
		
		/*if(buf == 0)
		{
			util::hexdump(dbg::out(dbg::info), data, 4, addresses[buf]);
			dbg::out(dbg::info) << std::endl;
		}*/
		
		total_time += end - begin;
	}
	
	dbg::out(dbg::info) << std::endl << "-- " << std::dec << buf_count << " buffers, " << buf_size 
		<< " 32-bit word each = " << buf_size_mb << " MB"<< std::endl;
		
	const double throughput = (static_cast<double>(buf_size_mb)*buf_count)/total_time;
	
	dbg::out(dbg::info) << std::endl << "-- " << throughput << " MB/s, total "
		<< total_time << " s" << std::endl;
}

/*uint16_t pattern[64] = {
	136, 185, 140, 217, 229, 181, 209, 169, 189, 153, 165, 156, 160, 157, 
	113, 169, 177, 157, 169, 148, 161, 144, 148, 141, 153, 144, 145, 245, 
	196, 193, 216, 176, 181, 156, 181, 165, 152, 121, 144, 173, 149, 161, 
	176, 149, 172, 144, 157, 148, 145, 144, 145, 188, 148, 184, 197, 169, 
	168, 153, 168, 144, 156, 141, 149, 149
};*/

// Pattern for EEPROM write begin
/*static uint8_t pattern[64] = {
	93, 129, 100, 188, 176, 105, 141, 81, 80, 69, 77, 85, 84, 57, 105, 161, 133, 128, 144, 92, 
	109, 81, 88, 117, 85, 101, 97, 253, 125, 133, 169, 100, 120, 57, 81, 89, 61, 101, 77, 148, 
	65, 148, 153, 100, 129, 97, 105, 81, 80, 105, 100, 117, 97, 197, 185, 117, 177, 69, 104, 57, 
	49, 64, 72, 52
};*/

const unsigned int pattern_len = 41;
static uint8_t pattern[41] = {
	88, 77, 81, 76, 72, 85, 85, 224, 93, 125, 137, 73, 89, 53, 52, 57, 69, 77, 
	64, 112, 49, 120, 137, 85, 113, 68, 77, 72, 73, 81, 76, 104, 80, 168, 144, 
	93, 137, 40, 72, 36, 45
};

static void smartcard_adc_test() 
{
	// Keyboard
	keyboard* kb = keyboard::instance();
	
	// DDR control object
	ddr ram;
	adc scope;
	
	// smartcard interface
	smartcard sc;
	dac vfi;
	
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_SC_SENT, true);

	// reset, get ATR
	byte_buffer_t atr = sc.resetAndGetAtr();
	dbg::out(dbg::info) << "ATR: ";
	util::hexdump(dbg::out(dbg::info), atr);
	dbg::out(dbg::info) << std::endl;
	
	trace_display_window_manager m;
	trace_display_window* w = m.createWindow("Scope", 10, 10, 800, 400);
	w->box().setYRange(256);
	m.start();
	
	// memory size in 32-bit words
	const unsigned int mem_size = (1 << 26)/4;
	const unsigned int adc_value_count = 499968;
	
	uint16_t thresh = 680;
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
	
	std::vector<uint8_t> pattern_v(pattern_len);
	std::copy(pattern, pattern + pattern_len, pattern_v.begin());
	
	scope.setDetectorPattern(pattern_v);
	
	bool run = true;
	uint8_t val = 0;
	while(run)
	{
		// Start DMA write from ADC
		ram.prepareDmaWrite(0, adc_value_count);
		//ram.triggerDmaWrite();

		ram.setDmaInput(ddr::DMA_IN_ADC);
		//ram.setDmaInput(ddr::DMA_IN_DETECTOR);
		scope.setDetectorThreshold(thresh);
		
		dbg::out(dbg::info) << "Threshold: " << std::dec <<
			static_cast<unsigned int>(thresh) << std::endl;
		
		scope.setCoarseTrigger(true);
		scope.arm();
		
		// EEPROM write APDU
		byte_buffer_t eeprom_w;
		eeprom_w.push_back(val);
		eeprom_w.push_back(val ^ 0xff);
		eeprom_w.push_back(rand() & 0xff);
		
		byte_buffer_t test_apdu = sc.makeT1Apdu(0x80, 0x04, 0x00, 0x00, eeprom_w, 2);
		//val++;
	
		dbg::out(dbg::info) << "RX (" << sc.getRxPending() << "): ";
		byte_buffer_t rx = sc.handleRxTx(test_apdu, 500);
		util::hexdump(dbg::out(dbg::info), rx);
		dbg::out(dbg::info) << std::endl;
		
		// check if ADC did trigger
		if(scope.isArmed())
		{
			scope.softwareTrigger();
			dbg::out(dbg::info) << "!! Forced SW trigger" << std::endl;
		}
		
		// wait for DMA to finish
		uint8_t status = 0;
		do 
		{
			status = ram.getStatus();	
		} while (status & (1 << fault_fpga_spartan6::DDR_STATUS_DMA));
		

		// Read back (burst)
		ddr::buffer_t data = ram.readBurst(0, adc_value_count/2);
		//dbg::out(dbg::info) << std::endl;
		//dbg::out(dbg::info) << "-- ADC: " << std::dec << data.size() << " byte" << std::endl;
		//dbg::out(dbg::info) << std::endl;

		
		timeseries_t plot(data.size()*2);
		
		for(unsigned int i = 0; i < data.size(); i++)
		{
			plot[2*i] = (data[i] & 0xffff);
			plot[2*i+1] = ((data[i] & 0xffff0000) >> 16);
			
			//plot[2*i] -= 1 << 13;
			//plot[2*i+1] -= 1 << 13;
		}
			
		w->box().setData(plot);
		
		dbg::out(dbg::info) << "Status: ";
		dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
		
		usleep(100e3);
		
		if(kb->kbhit())
		{
			const char key = kb->get();
			
			if(key == 'q')
			{
				run = false;
			}
			else if(key == 't')
			{
				thresh -= 25;
			}
			
		}
	}
	
	kb->release();
	
	//util::hexdump(dbg::out(dbg::info), data, 4, 0);
	//dbg::out(dbg::info) << std::endl;
}

static void smartcard_single_trace() 
{
	// DDR control object
	ddr ram;
	adc scope;
	
	// smartcard interface
	smartcard sc;
	dac vfi;
	
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_SC_SENT, true);
	//vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_SC_START_SEND, true);

	// reset, get ATR
	byte_buffer_t atr = sc.resetAndGetAtr();
	dbg::out(dbg::info) << "ATR: ";
	util::hexdump(dbg::out(dbg::info), atr);
	dbg::out(dbg::info) << std::endl;

	byte_buffer_t eeprom_w;
	eeprom_w.push_back(0x00);
	eeprom_w.push_back(0xbb);
	
	// Fixed delay here
	// eeprom_w.push_back(16);
	// Random delay
	eeprom_w.push_back(rand());
	
	byte_buffer_t test_apdu = sc.makeT1Apdu(0x80, 0x04, 0x00, 0x00, eeprom_w, 2);
	
	// memory size in 32-bit words
	const unsigned int mem_size = (1 << 26)/4;
	const unsigned int adc_value_count = 499968;
	
	uint16_t thresh = 0xffff;
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
	

	// Start DMA write from ADC
	ram.prepareDmaWrite(0, adc_value_count);

	ram.setDmaInput(ddr::DMA_IN_ADC);

	scope.setDetectorThreshold(thresh);
	scope.setCoarseTrigger(true);
	scope.arm();
	
	dbg::out(dbg::info) << "RX (" << sc.getRxPending() << "): ";
	byte_buffer_t rx = sc.handleRxTx(test_apdu, 500);
	util::hexdump(dbg::out(dbg::info), rx);
	dbg::out(dbg::info) << std::endl;
	
	// check if ADC did trigger
	if(scope.isArmed())
	{
		scope.softwareTrigger();
		dbg::out(dbg::info) << "!! Forced SW trigger" << std::endl;
	}
	
	// wait for DMA to finish
	uint8_t status = 0;
	do 
	{
		status = ram.getStatus();	
	} while (status & (1 << fault_fpga_spartan6::DDR_STATUS_DMA));
	
	// Read back (burst)
	ddr::buffer_t data = ram.readBurst(0, adc_value_count/2);
	
	std::ofstream ofs;
	ofs.open("trace.txt");
	
	timeseries_t plot(data.size()*2);
	for(unsigned int i = 0; i < data.size(); i++)
	{
		plot[2*i] = (data[i] & 0xffff);
		plot[2*i+1] = ((data[i] & 0xffff0000) >> 16);
		
		ofs << std::dec << static_cast<unsigned int>(plot[2*i]) << std::endl;
		ofs << std::dec << static_cast<unsigned int>(plot[2*i+1]) << std::endl;
	}
	
	ofs.close();
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
}

static void smartcard_pattern_test() 
{
	// DDR control object
	ddr ram;
	adc scope;
	
	// smartcard interface
	smartcard sc;
	dac vfi;
	
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_SC_SENT, true);
	
	// reset, get ATR
	byte_buffer_t atr = sc.resetAndGetAtr();
	dbg::out(dbg::info) << "ATR: ";
	util::hexdump(dbg::out(dbg::info), atr);
	dbg::out(dbg::info) << std::endl;

	byte_buffer_t eeprom_w;
	eeprom_w.push_back(0x00);
	eeprom_w.push_back(0xbb);
	eeprom_w.push_back(rand() & 0xff);
	//eeprom_w.push_back(250);
	byte_buffer_t test_apdu = sc.makeT1Apdu(0x80, 0x04, 0x00, 0x00, eeprom_w, 2);
	
	// memory size in 32-bit words
	const unsigned int mem_size = (1 << 26)/4;
	const unsigned int adc_value_count = 499968;
	
	uint16_t thresh = 0xffff;
	thresh = 650;
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
	
	// Start DMA write from ADC
	ram.prepareDmaWrite(0, adc_value_count);

	ram.setDmaInput(ddr::DMA_IN_ADC);
	//ram.setDmaInput(ddr::DMA_IN_DETECTOR);

	std::vector<uint8_t> pattern_v(pattern_len);
	std::copy(pattern, pattern + pattern_len, pattern_v.begin());
	
	scope.setDetectorPattern(pattern_v);
	scope.setDetectorThreshold(thresh);
	scope.setCoarseTrigger(true);
	scope.arm();
	
	dbg::out(dbg::info) << "d = " << std::dec << static_cast<unsigned int>(eeprom_w[2]);
	dbg::out(dbg::info) << " - RX (" << sc.getRxPending() << "): ";
	byte_buffer_t rx = sc.handleRxTx(test_apdu, 500);
	util::hexdump(dbg::out(dbg::info), rx);
	dbg::out(dbg::info) << std::endl;
	
	// check if ADC did trigger
	if(scope.isArmed())
	{
		scope.softwareTrigger();
		dbg::out(dbg::info) << "!! Forced SW trigger" << std::endl;
	}
	
	// wait for DMA to finish
	uint8_t status = 0;
	do 
	{
		status = ram.getStatus();	
	} while (status & (1 << fault_fpga_spartan6::DDR_STATUS_DMA));
	
	// Read back (burst)
	ddr::buffer_t data = ram.readBurst(0, adc_value_count/2);
	
	timeseries_t plot(data.size()*2);
	
	
	std::ofstream ofs;
	ofs.open("pattern.txt");
	
	for(unsigned int i = 0; i < data.size(); i++)
	{
		plot[2*i] = (data[i] & 0xffff);
		plot[2*i+1] = ((data[i] & 0xffff0000) >> 16);
		
		ofs << std::dec << static_cast<unsigned int>(plot[2*i]) << std::endl;
		ofs << std::dec << static_cast<unsigned int>(plot[2*i+1]) << std::endl;
	}
	
	ofs.close();
	
	dbg::out(dbg::info) << "Status: ";
	dbg::out(dbg::info) << util::u8bs(ram.getStatus()) << std::endl;
}


/**
 * @warning This code only works if the detector adc input is controlled
 *          via registers, i.e., if
 *            detector_adc_in <= register_file_writable(30);
 *            detector_adc_we <= register_file_w(62);
 *          is set.
 */
static void pattern_detector_test()
{
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	ddr ram;
	adc scope;
	
	// Detector output -> debug register
	ram.setDmaInput(ddr::DMA_IN_DETECTOR);

	std::vector<uint8_t> pattern_v(pattern_len);
	std::copy(pattern, pattern + pattern_len, pattern_v.begin());

	// Set pattern
	scope.setDetectorPattern(pattern_v);

	// Write debug data
	std::vector<uint16_t> d;
	for(unsigned int i = 0; i < 128; i++)
	{
		//fpga->writeRegister(fault_fpga_spartan6::DETECTOR_DEBUG, i & 0xff);
		fpga->writeRegister(fault_fpga_spartan6::DETECTOR_DEBUG, pattern_v[i % 64]);
		
		uint16_t v = fpga->readRegister(fault_fpga_spartan6::DDR_DMA_IN_L);
		v |= (fpga->readRegister(fault_fpga_spartan6::DDR_DMA_IN_H)) << 8;
		
		d.push_back(v);
		
		dbg::out(dbg::info) << static_cast<unsigned int>(v) << " ";
	}
	dbg::out(dbg::info) << std::endl;
}

int main(int argc, char *argv[])
{
	// setup logging & debugging
	clog.setTee(&std::cout);
	cdbg.setTee(&std::cout);
	cerror.setTee(&std::cerr);

	dbg::attach_ostream(dbg::all, cdbg);
	dbg::attach_ostream(dbg::all, dbg::default_source, cdbg);

	dbg::enable(dbg::all, true);
	dbg::enable_level_prefix(true);
	
	// init singleton instance
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();

	if(!fpga->open("FaultInjectionFPGA"))
	{
		dbg::out(dbg::error) << "main(): Could not open FPGA" << std::endl;
	}

	srand(time(0));
	
	//smartcard_test(fpga);
	//generic_test(fpga);
	//vfi_test();
	//rfid_adc_test(fpga);
	//rfid_test();
	//ddr_test();
	//smartcard_single_trace();
	//smartcard_adc_test();
	smartcard_pattern_test();
	//pattern_detector_test();
	
	// cleanup
	fpga->close();
	fault_fpga_spartan6::destroy();
   
    return 0;
}
