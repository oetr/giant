#!/bin/sh

make

cd ../../../uc

if [ "$1" == "-f" ]
then
	make distclean
fi

make

cd ../pc/apps/cryptarchi

# good : ff 00 00 12 66 e9 4b d4 ef 8a 2c 3b 88 4c fa 59 ca 34 2b 2e 90 00 7c
# fault: ff ff 00 12 66 e9 4b d4 ef 8a 2c 3b 88 4c fa 59 ca 34 2b 2e 90 00 7c 
# reset: ff 3b bb 11 00 91 81 31 46 15 65 73 54 61 72 67 65 74 20 76 31 98
#              00 64 91 81 31 46 15 2a 72 53 6d 34 72 74 34 43 
#		 3b bb 11 00 91 81 31 46 15 2a 53 6d 34 72 74 43 34 72 64 2a b5
# res_f: ff ff 3b bb 11 00 91 81 31 46 15 65 73 54 61 72 67 65 74 20 76 31 98 
#        ff e2 00 c8 49 70 3b bb 11 00 91 81 31 46 15 65 73 54 61 72 67 65 74 20 76 31 98 
./run.sh ../../../uc/uc.ihx ../../../fpga/vhdl/ise/main.bit --no-fault
./run.sh ../../../uc/uc.ihx ../../../fpga/vhdl/ise/main.bit --toggle
./run.sh ../../../uc/uc.ihx ../../../fpga/vhdl/ise/main.bit --sweep



#./run.sh ../../../uc/uc.ihx ../../../fpga/vhdl/ise/main.bit --sweep-v

cd ..