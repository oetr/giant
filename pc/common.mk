# DSP
COMMON_SOURCES += $(COMMON_DIR)/src/dsp.cpp 
COMMON_SOURCES += $(COMMON_DIR)/src/fft.cpp 
COMMON_SOURCES += $(COMMON_DIR)/src/fir_filter.cpp 

# FPGA
COMMON_SOURCES += $(COMMON_DIR)/src/fault_fpga_spartan6.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/pic_programmer.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/dac.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/adc.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/smartcard.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/rfid.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/spartan6-modules/ddr.cpp

# Common
COMMON_SOURCES += $(COMMON_DIR)/src/dbgstream.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/keyboard.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/serial.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/memmap.cpp
COMMON_SOURCES += $(COMMON_DIR)/src/dbg.cpp

CFLAGS += -DFORCE_32 -DDBG_ENABLED
DLLS = 

INCLUDEDIRS += -I$(COMMON_DIR)/include/
INCLUDEDIRS += -I$(COMMON_DIR)/include/spartan6-modules/