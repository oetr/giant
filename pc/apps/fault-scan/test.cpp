#include <vector>

#include <dbgstream.h>
#include <keyboard.h>
#include <dac.h>
#include <smartcard.h>

#define CLK_PERIOD_NS 250
//#define OFFSET_MIN 2900 * CLK_PERIOD_NS
//#define OFFSET_MIN 3082 * CLK_PERIOD_NS
#define OFFSET_MIN 0 * CLK_PERIOD_NS
#define OFFSET_MAX 6010000
#define OFFSET_STEPS CLK_PERIOD_NS / 5 // = 50 ns 

static void smartcard_test(fault_fpga_spartan6* fpga) {
    // setup vfi
    dac vfi;
    vfi.setEnabled(true);
	
    // smartcard interface
    smartcard sc;
	
    // keyboard
    keyboard* kb = keyboard::instance();

    // settings
    const double v_step = 12.0/256.0;
    const double v_normal = 4.2;
    double v_faultinj = 2.4;
    int pulse_width = 250;

    setbuf(stdout, NULL); // buffer bei stdout auschalten
    
    // Voltages
    const uint8_t v_dd = static_cast<uint8_t>(-v_normal/v_step + 128.0);
    uint8_t v_fault    = static_cast<uint8_t>(-v_faultinj/v_step + 128.0);
    vfi.setLowVoltage(v_dd);
    vfi.setHighVoltage(v_fault);
    vfi.setOffVoltage(128);

    // trigger (use pin)
    vfi.setTriggerEnableState(fault_fpga_spartan6::FI_TRIGGER_CONTROL_EXT1, true);
    // get status
    uint8_t status = sc.getStatus();
    std::cout << "Status_initial: " << util::u8bs(status & 0x3f) << std::endl;


    // get ATR
    byte_buffer_t atr = sc.resetAndGetAtr();
    std::cout << "ATR: ";
    util::hexdump(std::cout, atr);
    std::cout << std::endl;

    byte_buffer_t rx;
    unsigned int rx_size;
    bool run = true;

    // set a fixed key, plaintext, and ciphertext
    const byte_buffer_t key = {0x2b,0x7e,0x15,0x16, 0x28,0xae,0xd2,0xa6,
			       0xab,0xf7,0x15,0x88, 0x09,0xcf,0x4f,0x3c};
    const byte_buffer_t pt  = {0x32,0x43,0xf6,0xa8, 0x88,0x5a,0x30,0x8d,
			       0x31,0x31,0x98,0xa2, 0xe0,0x37,0x07,0x34};
    const byte_buffer_t ct  = {0x39,0x25,0x84,0x1d, 0x02,0xdc,0x09,0xfb,
			       0xdc,0x11,0x85,0x97, 0x19,0x6a,0x0b,0x32};

    // generate APDUs the second byte of APDU (0x02 and 0x40) will be interpreted 
    // on the smartcard as "set key" and "encrypt", respectively
    const byte_buffer_t set_key_apdu = sc.makeT1Apdu(0x80, 0x02, 0x00, 0x00, key, 0x10); 
    const byte_buffer_t encrypt_apdu = sc.makeT1Apdu(0x80, 0x40, 0x00, 0x00, pt,  0x10);


    // print header explaining the printed data
    printf("\n");
    printf("******************************** DATA FORMAT *********************************\n");
    printf("Offset in nanoseconds, clock cycles after trigger, received ciphertext, status\n");
    printf("******************************************************************************\n\n");
    
    
    for (int pulse_offset = OFFSET_MIN; pulse_offset <= OFFSET_MAX; pulse_offset += OFFSET_STEPS) {
	if(!run)
	    break;
	// check if keyboard is hit
	if(kb->kbhit()) {
	    puts("Breche Test ab");
	    kb->get();
	    run = false;
	    break;
	}

	// generate pulse
	vfi.clearPulses();
	vfi.addPulse(pulse_offset, pulse_width);
	vfi.arm();


	printf("%u (ns), ", pulse_offset);
	printf("%.1f (ccs), ", pulse_offset*1.0/CLK_PERIOD_NS);
	
					
	sc.resetAndGetAtr();
	sc.handleRxTx(set_key_apdu, 1000);
	rx = sc.handleRxTx(encrypt_apdu, 1000);
	rx_size = rx.size();
	// rx_size should be 16 bytes data + 6 bytes whatever
	if (rx_size != 22) { // program crash
	    printf("                                                     CRASH, %3d byte", rx_size);
	    if (rx_size != 1)
		printf ("s");
	    printf(" received");
	} else {
	    // i mit 4 initialisiert, damit nur die Info zurueckgeliefert wird
	    // hinten werden 2 abgeschnitten, damit das OK (90 00) nicht gedruckt wird
	    short n_correct_bytes = 0;
	    std::vector<int> wrong_bytes;
	    for(unsigned int i = 4; i < rx_size-2; i++) {
		if (rx[i] == ct[i-4]) {
		    n_correct_bytes++;
		} else {
		    wrong_bytes.push_back(i-4);
		}
	    }
	    if (n_correct_bytes != 16) { // FI successful
		for (unsigned int i = 0; i < 16; i++) {
		    printf("%02x", rx[i+4]);
		    if (i == 15) {
			printf("      %2d byte", 16-n_correct_bytes);
			if (16-n_correct_bytes != 1)
			    printf ("s");
			else
			    printf(" ");
			
			printf(" wrong");

			// print which bytes are wrong whe we have errors in 4 bytes
			if (wrong_bytes.size() == 4) {
			    printf (": [");
			    for (unsigned int i = 0; i < wrong_bytes.size(); i++) {
				printf ("%2d", wrong_bytes[i]);
				if (i < wrong_bytes.size()-1) {
				    printf (", ");
				}
			    }
			    printf ("]");
			}
		    }
		    else
			printf(",");
		}
	    } else { // FI unsuccessful
		for (unsigned int i = 0; i < 16; i++) {
		    printf("%02x", rx[i+4]);
		    if (i == 15) {
			printf("      OK");
		    }
		    else
			printf(",");
		}
	    }
	}
	printf("\n");
    }
}


int main(int argc, char *argv[]) {
    // init singleton instance
    fault_fpga_spartan6* fpga = fault_fpga_spartan6::instance();
    if(!fpga->open("FaultInjectionFPGA")) {
     	std::cout << "Could not open the fault injection FPGA" << std::endl;
	return -1;
    }

    fpga->resetFpga(); // the FPGA does not always start without a reset

    // call test function
    smartcard_test(fpga);

    // cleanup
    fpga->close();
    fault_fpga_spartan6::destroy();

    return 0;
}
