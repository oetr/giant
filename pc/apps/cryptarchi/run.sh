#!/bin/sh

ZTEX_SDK="../../uc/ztex/java/FWLoader"

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
    echo "${ZTEX_SDK}/FWLoader -c -f -uu $FIRMWARE -uf $FPGA_BS"
	${ZTEX_SDK}/FWLoader -c -f -uu $FIRMWARE -uf $FPGA_BS
fi

echo ""
echo "./test $@"
echo ""
./test $@
