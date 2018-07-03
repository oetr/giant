ZTEX_SDK="../../../uc/ztex"
BITSTREAM="../../../fpga/vhdl/ise/main.bit"

echo "${ZTEX_SDK}/java/FWLoader/FWLoader -c -f -uf $BITSTREAM"
      ${ZTEX_SDK}/java/FWLoader/FWLoader -c -f -uf ${BITSTREAM}
