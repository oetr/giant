#!/bin/sh

FIRMWARE=$1
shift
FPGA_BS=$1
shift
	
if [ "$FIRMWARE" != "" ] && [ "$FPGA_BS" != "" ] 
then
    if [ ! -f "$FIRMWARE" ] || [ ! -f "$FPGA_BS" ] 
	then
		echo "Usage: ./run.sh [<Firmware file>] [<FPGA bitstream>]"
		exit 1
    fi
	
	echo ""
    echo "../../uc/ztex-sdk-20101006/java/FWLoader -c -f -uu $FIRMWARE -uf $FPGA_BS"
	../../../uc/ztex-sdk-20101006/java/FWLoader -c -f -uu $FIRMWARE -uf $FPGA_BS
fi

echo ""
echo "./test $@"
echo ""
./test $@