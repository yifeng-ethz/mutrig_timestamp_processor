#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SIM_DIR="${SCRIPT_DIR}/sim_work"
SIM_LIB_DIR="/data1/intelFPGA_pro/23.1/quartus/eda/sim_lib"

source "${IP_DIR}/../scripts/questa_one_env.sh"

rm -rf "${SIM_DIR}"
mkdir -p "${SIM_DIR}"
cd "${SIM_DIR}"

"${VLIB}" work
"${VLIB}" lpm
"${VMAP}" lpm lpm

"${VCOM}" -2008 -work lpm "${SIM_LIB_DIR}/220pack.vhd"
"${VCOM}" -2008 -work lpm "${SIM_LIB_DIR}/220model.vhd"
"${VLOG}" -work work "${IP_DIR}/dual_port_rom.v"
"${VCOM}" -2008 -work work "${IP_DIR}/mts_processor.vhd"
"${VCOM}" -2008 -work work "${SCRIPT_DIR}/mts_processor_tb.vhd"

cp "${IP_DIR}/dual_port_rom_init.txt" "${SIM_DIR}/dual_port_rom_init.txt"

set +e
"${VSIM}" -c -L lpm work.mts_processor_tb -do "run -all; quit -f" | tee "${SIM_DIR}/vsim.log"
vsim_rc=${PIPESTATUS[0]}
set -e

if grep -q "mts_processor_tb PASSED" "${SIM_DIR}/vsim.log"; then
    exit 0
fi

exit "${vsim_rc}"
