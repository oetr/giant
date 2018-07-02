#!/bin/sh

make

cd ../../uc

if [ "$1" == "-f" ]
then
	make distclean
fi

make

cd ../pc/example

./run.sh ../../uc/uc.ihx ../../fpga/vhdl/ise/main.bit

cd ..