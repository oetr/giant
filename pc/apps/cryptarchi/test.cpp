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
#include <cmath>
#include <algorithm>

#include <dbgstream.h>
#include <fault_fpga_spartan6.h>
#include <dac.h>
#include <smartcard.h>
#include <keyboard.h>

static void smartcard_reset_init(smartcard& sc, dac& vfi) 
{
	// reset, get ATR
	vfi.setEnabled(false);
	usleep(500e3);
	vfi.setEnabled(true);
	byte_buffer_t atr = sc.resetAndGetAtr();
		
	//dbg::out(dbg::info) << "ATR: ";
	//util::hexdump(dbg::out(dbg::info), atr);
	//dbg::out(dbg::info) << std::endl;
}

static void smartcard_test_nofault(fault_fpga_spartan6* fpga) 
{
	// setup vfi
	dac vfi;
	vfi.setEnabled(true);
	
	// smartcard interface
	smartcard sc;
	
	// keyboard
	keyboard* kb = keyboard::instance();
	
	// Voltages
	const double v_step = 12.0/256.0;
	const double v_normal = 4.2;
	const uint8_t v_dd = static_cast<uint8_t>(-v_normal/v_step + 128.0);
	vfi.setLowVoltage(v_dd);
	vfi.setHighVoltage(v_dd);
	vfi.setOffVoltage(128);
	
	// trigger
	// trigger (use pin)
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_EXT1, true);

	// get status
	uint8_t status = sc.getStatus();
	dbg::out(dbg::info) << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;

	// reset & initialize
	smartcard_reset_init(sc, vfi);

	bool run = true;
	for(unsigned int i = 0; run; i++)
	{
		byte_buffer_t data;
		data.resize(16, 0);
		
		for(unsigned int i = 0; i < 16; i++)
		{
			data[i] = rand() & 0xff;
		}
	
		byte_buffer_t test_apdu = smartcard::makeT1Apdu(0x80, 0x40, 0x0, 0x0,
			data, 16);
			
		vfi.clearPulses();
		vfi.addPulse(30, 10);
		vfi.arm();
			
		dbg::out(dbg::info) << "Enc: ";
		util::hexdump(dbg::out(dbg::info), data);
		dbg::out(dbg::info) << std::endl;
		
		byte_buffer_t rx = sc.handleRxTx(test_apdu, 1000);
		int rx_size = rx.size();
		
		dbg::out(dbg::info) << "RX(" << rx_size << "): ";
		util::hexdump(dbg::out(dbg::info), rx);
		dbg::out(dbg::info) << std::endl;
		
		if(kb->kbhit())
		{
			char press = kb->get();
			run = false;
		}
	}
	
	dbg::out(dbg::info) << "[Any key to quit]" << std::endl;;
	while(!kb->kbhit())
	{
		usleep(1e3);
	}
	char press = kb->get();
	kb->release();
}

static void smartcard_test_toggle_v(fault_fpga_spartan6* fpga) 
{
	
	// SETTINGS
	const double v_step = 12.0/256.0;
	const double v_normal = 4.2;
	const double v_vfi_noeffect = 4.2;
	const double v_vfi_effect = 1.0;
	const double t_offset = 259825;
	const double t_width = 30;
	
	byte_buffer_t data;
	data.resize(16, 0);
	
	for(unsigned int i = 0; i < 16; i++)
	{
		data[i] = i;
	}
	
	byte_buffer_t test_apdu = smartcard::makeT1Apdu(0x80, 0x40, 0x0, 0x0,
		data, 16);
	
	// END SETTINGS
	
	// keyboard
	keyboard* kb = keyboard::instance();
	
	// setup vfi
	dac vfi;
	
	vfi.setEnabled(false);
	usleep(1e6);
	vfi.setEnabled(true);
	
	// smartcard interface
	smartcard sc;

	//dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
	//	static_cast<unsigned int>(v_fault) << std::endl;
	
	// Voltages
	const uint8_t v_dd = static_cast<uint8_t>(-v_normal/v_step + 128.0);
	const uint8_t v_fault_noeffect = static_cast<uint8_t>(-v_vfi_noeffect/v_step + 128.0);
	const uint8_t v_fault_effect = 112;
	
	vfi.setHighVoltage(v_fault_noeffect);
	vfi.setLowVoltage(v_dd);
	vfi.setOffVoltage(128);
	
	// trigger
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_EXT1, true);

	// get status
	uint8_t status = sc.getStatus();
	dbg::out(dbg::info) << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;

	// reset & initialize
	smartcard_reset_init(sc, vfi);

	bool run = true;
	for(unsigned int i = 0; run; i++)
	{
		const double t_offset_i = t_offset;
		const double t_width_i = t_width;
		
		if(i % 2)
		{
			vfi.setHighVoltage(v_fault_effect);
		}
		else
		{
			vfi.setHighVoltage(v_fault_noeffect);
		}
		
		//dbg::out(dbg::info) << std::dec << i << ": t_offset = " << t_offset_i 
		//	<< ", t_width = " << t_width_i << ": ";
		
		smartcard_reset_init(sc, vfi);
		
		vfi.clearPulses();
		vfi.addPulse(t_offset_i, t_width_i);
		vfi.arm();
		
		/*dbg::out(dbg::info) << "TX: ";
		util::hexdump(dbg::out(dbg::info), test_apdu);
		dbg::out(dbg::info) << std::endl;*/
		
		byte_buffer_t rx = sc.handleRxTx(test_apdu, 1000);
		
		dbg::out(dbg::info) << "RX: ";
		util::hexdump(dbg::out(dbg::info), rx);
		dbg::out(dbg::info) << std::endl;
		
		if(kb->kbhit())
		{
			char press = kb->get();
			run = false;
		}
	}
	
	dbg::out(dbg::info) << "[Any key to quit]" << std::endl;;
	while(!kb->kbhit())
	{
		usleep(1e3);
	}
	char press = kb->get();
	kb->release();
}

static void smartcard_test_sweep(fault_fpga_spartan6* fpga) 
{
	
	// SETTINGS
	const double v_step = 12.0/256.0;
	const double v_normal = 4.2;
	const double v_vfi_noeffect = 4.2;
	const double v_vfi_effect = 1.0;
	const double t_offset = 259825;
	
	byte_buffer_t data;
	data.resize(16, 0);
	
	for(unsigned int i = 0; i < 16; i++)
	{
		data[i] = i;
	}
	
	
	byte_buffer_t test_apdu = smartcard::makeT1Apdu(0x80, 0x40, 0x0, 0x0,
		data, 16);
	
	// END SETTINGS
	
	// keyboard
	keyboard* kb = keyboard::instance();
	
	// setup vfi
	dac vfi;
	
	vfi.setEnabled(false);
	usleep(1e6);
	vfi.setEnabled(true);
	
	// smartcard interface
	smartcard sc;

	//dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
	//	static_cast<unsigned int>(v_fault) << std::endl;
	
	// Voltages
	const uint8_t v_dd = static_cast<uint8_t>(-v_normal/v_step + 128.0);
	const uint8_t v_fault_noeffect =  v_dd - 15; //static_cast<uint8_t>(-v_vfi_noeffect/v_step + 128.0);
	const uint8_t v_fault_effect =  112; //static_cast<uint8_t>(-v_vfi_effect/v_step + 128.0);
	
	vfi.setHighVoltage(v_fault_effect);
	vfi.setLowVoltage(v_dd);
	vfi.setOffVoltage(128);
	
	// trigger
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_EXT1, true);

	// get status
	uint8_t status = sc.getStatus();
	dbg::out(dbg::info) << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;

	// reset & initialize
	smartcard_reset_init(sc, vfi);

	bool run = true;
	double t_width = 10;
	while(run)
	{
		
		const double t_offset_i = t_offset;
		const double t_width_i = t_width;
		
		dbg::out(dbg::info) << "w = " << t_width_i << ": ";
		
		vfi.clearPulses();
		vfi.addPulse(t_offset_i, t_width_i);
		vfi.arm();
		
		/*dbg::out(dbg::info) << "TX: ";
		util::hexdump(dbg::out(dbg::info), test_apdu);
		dbg::out(dbg::info) << std::endl;*/
		
		byte_buffer_t rx = sc.handleRxTx(test_apdu);
		
		util::hexdump(dbg::out(dbg::info), rx);
		dbg::out(dbg::info) << std::endl;
		
		usleep(.3e6);
		
		if(kb->kbhit())
		{
			char press = kb->get();
			run = false;
		}
		
		t_width = fmod(t_width, 100.0) + 10;
	}
	
	dbg::out(dbg::info) << "[Any key to quit]" << std::endl;;
	while(!kb->kbhit())
	{
		usleep(1e3);
	}
	char press = kb->get();
	kb->release();
}

static void smartcard_test_sweep_v(fault_fpga_spartan6* fpga) 
{
	
	// SETTINGS
	const double v_step = 12.0/256.0;
	const double v_normal = 4.2;
	const double v_vfi_noeffect = 4.2;
	
	byte_buffer_t data;
	data.resize(16, 0);
	
	byte_buffer_t test_apdu = smartcard::makeT1Apdu(0x80, 0x02, 0x0, 0x0,
		data, 16);
	
	for(unsigned int i = 0; i < 16; i++)
	{
		data[i] = i;
	}
	
	byte_buffer_t test_apdu_xor_s = smartcard::makeT1Apdu(0x80, 0x40, 0x0, 0x0,
		data, 16);
	
	// END SETTINGS
	
	// keyboard
	keyboard* kb = keyboard::instance();
	
	// setup vfi
	dac vfi;
	vfi.setEnabled(true);
	
	// smartcard interface
	smartcard sc;
	
	std::ofstream ofs_log;
	ofs_log.open("fault_log.txt");

	//dbg::out(dbg::info) << static_cast<unsigned int>(v_dd) << " - " << 
	//	static_cast<unsigned int>(v_fault) << std::endl;
	
	// Voltages
	const uint8_t v_dd = static_cast<uint8_t>(-v_normal/v_step + 128.0);
	const uint8_t v_fault_noeffect = static_cast<uint8_t>(-v_vfi_noeffect/v_step + 128.0);
	
	vfi.setHighVoltage(v_fault_noeffect);
	vfi.setLowVoltage(v_dd);
	vfi.setOffVoltage(128);
	
	// trigger
	vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_EXT1, true);

	// get status
	uint8_t status = sc.getStatus();
	dbg::out(dbg::info) << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;

	// reset & initialize
	smartcard_reset_init(sc, vfi);

	
	uint8_t rx_correct[] = {
		0xff, 0x00, 0x00, 0x12, 0x66, 0xe9, 0x4b, 0xd4, 0xef, 0x8a, 0x2c, 0x3b,
		0x88, 0x4c, 0xfa, 0x59, 0xca, 0x34, 0x2b, 0x2e, 0x90, 0x00, 0x7c
	};
	
	uint8_t rx_correct_xor_s[] = {
		0x00, 0x00, 0x12, 0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30,
		0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76, 0x90, 0x00, 0x2b
	};
	
	//00 00 12 63 7c 77 7b f2 6b 6f c5 30 01 67 2b fe d7 ab 63 90 00 3e 
	
	uint8_t rx_reset[] = {
		0xff, 0x3b, 0xbb, 0x11, 0x00, 0x91, 0x81, 0x31, 0x46, 0x15, 0x65, 0x73,
		0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x20, 0x76, 0x31, 0x98
	};
	
	uint8_t rx_reset_xor_s[] = {
		0x3b, 0xbb, 0x11, 0x00, 0x91, 0x81, 0x31, 0x46, 0x15, 0x2a, 0x53, 0x6d,
		0x34, 0x72, 0x74, 0x43, 0x34, 0x72, 0x64, 0x2a, 0xb5
	};

	bool run = true;
	const double t_begin = 140e3 + 125; 72200000 + 483e3 + 604875;
	const double t_end = t_begin + 200e3;
	
	
	const double w_begin = 10;
	const double w_end = 50;
	
	const uint8_t v_low = 100;
	const uint8_t v_high = 120;
	
	//for(double t_offset = 4439660; t_offset < 4600000 && run; t_offset += 250)
	for(double t_offset = t_begin; t_offset < t_end && run; t_offset += 50)
	{
		for(double t_width = w_begin; t_width < w_end && run; t_width += 10)
		{
			for(uint8_t v_fault = v_low; v_fault <= v_high && run; v_fault++)
			{
				vfi.setHighVoltage(v_fault);
				const double t_offset_i = t_offset;
				const double t_width_i = t_width;
				
				dbg::out(dbg::info) << t_offset_i << ", " << t_width_i << ", "
					<< std::dec << static_cast<unsigned int>(v_fault) << ", ";
				
				ofs_log << t_offset_i << ", " << t_width_i << ", "
					<< std::dec << static_cast<unsigned int>(v_fault) << ", ";
					
				vfi.clearPulses();
				vfi.addPulse(t_offset_i, t_width_i);
				vfi.arm();

				//byte_buffer_t rx = sc.handleRxTx(test_apdu);
				byte_buffer_t rx = sc.handleRxTx(test_apdu_xor_s, 1000);
				
				//if(!std::equal(rx.begin(), rx.end(), rx_correct))
				if(!std::equal(rx.begin(), rx.end(), rx_correct_xor_s))
				{
					//if(!std::equal(rx.begin(), rx.end(), rx_reset))
					if(!std::equal(rx.begin(), rx.end(), rx_reset_xor_s))
					{
						dbg::out(dbg::info) << "fault: ";
						util::hexdump(dbg::out(dbg::info), rx);
						dbg::out(dbg::info) << std::endl;
						
						ofs_log << "fault: ";
						util::hexdump(ofs_log, rx);
						ofs_log<< std::endl;
					}
					else
					{
						dbg::out(dbg::info) << "reset" << std::endl;
						ofs_log << "reset" << std::endl;
					}
				}	
				else
				{
					dbg::out(dbg::info) << "none" << std::endl;
					ofs_log << "none" << std::endl;
				}
				//usleep(.1e6);
				
				if(kb->kbhit())
				{
					char press = kb->get();
					run = false;
				}
			}
		}	
	}
	
	ofs_log.close();
	
	dbg::out(dbg::info) << "[Any key to quit]" << std::endl;;
	while(!kb->kbhit())
	{
		usleep(1e3);
	}
	char press = kb->get();
	kb->release();
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
	
	
	// get singleton
	fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
	
	//pic_programmer prog;
	
	if(!fpga->open("FaultInjectionFPGA"))
	{
		dbg::out(dbg::error) << "main(): Could not open FPGA" << std::endl;
	}

	if(argc == 2)
	{
		std::string cmd = argv[1];
		
		if(cmd == "--toggle")
		{
			smartcard_test_toggle_v(fpga);
		}
		else if(cmd == "--sweep")
		{
			smartcard_test_sweep(fpga);
		}
		else if(cmd == "--sweep-v")
		{
			smartcard_test_sweep_v(fpga);
		}
		else
		{
			smartcard_test_nofault(fpga);
		}
	}
	else
	{
		smartcard_test_nofault(fpga);
	}
	
	// cleanup
	fpga->close();
	fault_fpga_spartan6::destroy();
   
    return 0;
}
