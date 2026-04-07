#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SIM_DIR="${SCRIPT_DIR}/sim_work"
QUESTA_BIN="/data1/intelFPGA_pro/23.1/questa_fse/bin"
QUESTA_LICENSE="/data1/intelFPGA_pro/23.1/questa_fse/LR-287689_License.dat"
ETH_LIC_SERVER="8161@lic-mentor.ethz.ch"
SIM_LIB_DIR="/data1/intelFPGA_pro/23.1/quartus/eda/sim_lib"

if [[ -f "${QUESTA_LICENSE}" ]]; then
    export LM_LICENSE_FILE="${QUESTA_LICENSE}:${ETH_LIC_SERVER}"
else
    export LM_LICENSE_FILE="${ETH_LIC_SERVER}"
fi

rm -rf "${SIM_DIR}"
mkdir -p "${SIM_DIR}"
cd "${SIM_DIR}"

"${QUESTA_BIN}/vlib" work
"${QUESTA_BIN}/vlib" lpm
"${QUESTA_BIN}/vmap" lpm lpm

"${QUESTA_BIN}/vcom" -2008 -work lpm "${SIM_LIB_DIR}/220pack.vhd"
"${QUESTA_BIN}/vcom" -2008 -work lpm "${SIM_LIB_DIR}/220model.vhd"
"${QUESTA_BIN}/vlog" -work work "${IP_DIR}/dual_port_rom.v"
"${QUESTA_BIN}/vcom" -2008 -work work "${IP_DIR}/mts_processor.vhd"
"${QUESTA_BIN}/vcom" -2008 -work work "${SCRIPT_DIR}/mts_processor_tb.vhd"

cp "${IP_DIR}/dual_port_rom_init.txt" "${SIM_DIR}/dual_port_rom_init.txt"

set +e
"${QUESTA_BIN}/vsim" -c -L lpm work.mts_processor_tb -do "run -all; quit -f" | tee "${SIM_DIR}/vsim.log"
vsim_rc=${PIPESTATUS[0]}
set -e

if grep -q "mts_processor_tb PASSED" "${SIM_DIR}/vsim.log"; then
    exit 0
fi

exit "${vsim_rc}"
