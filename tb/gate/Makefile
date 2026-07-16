include ../../../scripts/questa_one.mk

Q18_SIMLIB ?= /data1/intelFPGA/18.1/quartus/eda/sim_lib
QUARTUS_EDA ?= /data1/intelFPGA/18.1/quartus/bin/quartus_eda

IP_ROOT      := $(abspath ../..)
GATE_DIR     := $(abspath .)
SYN_DIR      := $(IP_ROOT)/syn/quartus
NETLIST_DIR  := $(SYN_DIR)/gate_sim
NETLIST_V    := $(NETLIST_DIR)/mts_processor_syn.vo
FIT_SUMMARY  := $(SYN_DIR)/output_files/mts_processor_syn.fit.summary
TB_SRC       := $(GATE_DIR)/mts_processor_gate_smoke_tb.sv
RTL_WORK     := $(GATE_DIR)/work_rtl
GATE_WORK    := $(GATE_DIR)/work_gate
LOG_DIR      := $(GATE_DIR)/logs
MODELSIM_INI := modelsim.ini
TB_TOP       := mts_processor_gate_smoke_tb
INIT_FILE    := $(IP_ROOT)/dual_port_rom_init.txt

RTL_VHDL_SRCS := \
  $(IP_ROOT)/mts_processor.vhd \
  $(SYN_DIR)/mts_processor_syn_top.vhd

FIT_INPUTS := \
  $(IP_ROOT)/mts_processor.vhd \
  $(IP_ROOT)/dual_port_rom.v \
  $(INIT_FILE) \
  $(SYN_DIR)/mts_processor_syn_top.vhd \
  $(SYN_DIR)/mts_processor_syn.qsf \
  $(SYN_DIR)/mts_processor_syn.sdc

.PHONY: rtl_compile run_rtl gate_netlist gate_compile run_gate compare clean

rtl_compile: $(RTL_WORK)/_vmake

$(RTL_WORK)/_vmake: $(RTL_VHDL_SRCS) $(IP_ROOT)/dual_port_rom.v $(INIT_FILE) $(TB_SRC)
	@echo "=== Compiling MTS external-port RTL signature smoke ==="
	@rm -rf $(RTL_WORK)
	@mkdir -p $(RTL_WORK) $(LOG_DIR)
	@cp $(QSIM_INI) $(RTL_WORK)/$(MODELSIM_INI)
	@chmod u+w $(RTL_WORK)/$(MODELSIM_INI)
	@cp $(INIT_FILE) $(RTL_WORK)/dual_port_rom_init.txt
	@cd $(RTL_WORK) && $(VLIB) work
	@cd $(RTL_WORK) && $(VLIB) lpm
	@cd $(RTL_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) work work > /dev/null
	@cd $(RTL_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) lpm lpm > /dev/null
	@cd $(RTL_WORK) && $(VCOM) -2008 -modelsimini $(MODELSIM_INI) -work lpm $(Q18_SIMLIB)/220pack.vhd
	@cd $(RTL_WORK) && $(VCOM) -2008 -modelsimini $(MODELSIM_INI) -work lpm $(Q18_SIMLIB)/220model.vhd
	@cd $(RTL_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work work $(IP_ROOT)/dual_port_rom.v
	@set -e; for source in $(RTL_VHDL_SRCS); do \
	  cd $(RTL_WORK) && $(VCOM) -2008 -modelsimini $(MODELSIM_INI) -work work "$$source"; \
	done
	@cd $(RTL_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -sv -work work $(TB_SRC)
	@touch $@

run_rtl: rtl_compile
	@echo "=== Running MTS external-port RTL signature smoke ==="
	@cd $(RTL_WORK) && $(VSIM) -modelsimini $(MODELSIM_INI) -c -work work -t ps \
	  -L lpm -suppress 19 -suppress 3009 -suppress 3473 -voptargs=+acc \
	  $(TB_TOP) \
	  -do "quietly set NumericStdNoWarnings 1; quietly set StdArithNoWarnings 1; run -all; quit -f" \
	  | tee $(LOG_DIR)/rtl_smoke.log
	@if grep -qE '\*\* Fatal:|\*\* Error:' $(LOG_DIR)/rtl_smoke.log; then \
	  echo "FAIL: MTS RTL signature smoke"; exit 1; \
	elif ! grep -q '\*\*\* TEST PASSED \*\*\*' $(LOG_DIR)/rtl_smoke.log; then \
	  echo "FAIL: MTS RTL signature smoke did not print its pass marker"; exit 1; \
	else \
	  echo "PASS: MTS RTL signature smoke"; \
	fi

# Quartus 18.1 emits a zero-delay functional Verilog model for Arria V. The
# timestamp guards prevent exporting a netlist from stale fit artifacts.
$(NETLIST_V): $(FIT_SUMMARY) $(FIT_INPUTS)
	@set -e; for source in $(FIT_INPUTS); do \
	  if [ "$$source" -nt "$(FIT_SUMMARY)" ]; then \
	    echo "ERROR: stale MTS fit; $$source is newer than $(FIT_SUMMARY)"; \
	    exit 1; \
	  fi; \
	done
	@echo "=== Exporting Quartus 18.1 Arria-V functional netlist ==="
	@cd $(SYN_DIR) && $(QUARTUS_EDA) \
	  mts_processor_syn -c mts_processor_syn \
	  --simulation --tool=modelsim --format=verilog \
	  --output_directory=gate_sim --gen_script=gate_level
	@test -f $(NETLIST_V)

gate_netlist: $(NETLIST_V)

gate_compile: $(GATE_WORK)/_vmake

$(GATE_WORK)/_vmake: $(NETLIST_V) $(TB_SRC) $(INIT_FILE)
	@echo "=== Compiling MTS Quartus functional-netlist signature smoke ==="
	@rm -rf $(GATE_WORK)
	@mkdir -p $(GATE_WORK)/verilog_libs $(LOG_DIR)
	@cp $(QSIM_INI) $(GATE_WORK)/$(MODELSIM_INI)
	@chmod u+w $(GATE_WORK)/$(MODELSIM_INI)
	@cp $(INIT_FILE) $(GATE_WORK)/dual_port_rom_init.txt
	@cd $(GATE_WORK) && $(VLIB) work
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) work work > /dev/null
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/altera_lnsim_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) altera_lnsim_ver verilog_libs/altera_lnsim_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -sv -work altera_lnsim_ver $(Q18_SIMLIB)/altera_lnsim.sv
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/altera_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) altera_ver verilog_libs/altera_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work altera_ver $(Q18_SIMLIB)/altera_primitives.v
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/lpm_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) lpm_ver verilog_libs/lpm_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work lpm_ver $(Q18_SIMLIB)/220model.v
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/sgate_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) sgate_ver verilog_libs/sgate_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work sgate_ver $(Q18_SIMLIB)/sgate.v
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/altera_mf_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) altera_mf_ver verilog_libs/altera_mf_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work altera_mf_ver $(Q18_SIMLIB)/altera_mf.v
	@cd $(GATE_WORK) && $(VLIB) verilog_libs/arriav_ver > /dev/null
	@cd $(GATE_WORK) && $(VMAP) -modelsimini $(MODELSIM_INI) arriav_ver verilog_libs/arriav_ver > /dev/null
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work arriav_ver $(Q18_SIMLIB)/mentor/arriav_atoms_ncrypt.v
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work arriav_ver $(Q18_SIMLIB)/mentor/arriav_hmi_atoms_ncrypt.v
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work arriav_ver $(Q18_SIMLIB)/arriav_atoms.v
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -work work +incdir+$(NETLIST_DIR) $(NETLIST_V)
	@cd $(GATE_WORK) && $(VLOG) -modelsimini $(MODELSIM_INI) -sv -work work $(TB_SRC)
	@touch $@

run_gate: gate_compile
	@echo "=== Running MTS Quartus functional-netlist signature smoke ==="
	@cd $(GATE_WORK) && $(VSIM) -modelsimini $(MODELSIM_INI) -c -work work -t ps \
	  -L altera_lnsim_ver -L altera_ver -L lpm_ver -L sgate_ver \
	  -L altera_mf_ver -L arriav_ver \
	  -suppress 19 -suppress 3009 -suppress 3473 -voptargs=+acc \
	  $(TB_TOP) \
	  -do "quietly set NumericStdNoWarnings 1; quietly set StdArithNoWarnings 1; run -all; quit -f" \
	  | tee $(LOG_DIR)/gate_smoke.log
	@if grep -qE '\*\* Fatal:|\*\* Error:' $(LOG_DIR)/gate_smoke.log; then \
	  echo "FAIL: MTS gate signature smoke"; exit 1; \
	elif ! grep -q '\*\*\* TEST PASSED \*\*\*' $(LOG_DIR)/gate_smoke.log; then \
	  echo "FAIL: MTS gate signature smoke did not print its pass marker"; exit 1; \
	else \
	  echo "PASS: MTS gate signature smoke"; \
	fi

compare: run_rtl run_gate
	@rtl_sig=$$(sed -n 's/^# \{0,1\}MTS_GATE_SMOKE_SIGNATURE=//p' $(LOG_DIR)/rtl_smoke.log | tail -n1); \
	gate_sig=$$(sed -n 's/^# \{0,1\}MTS_GATE_SMOKE_SIGNATURE=//p' $(LOG_DIR)/gate_smoke.log | tail -n1); \
	if [ -z "$$rtl_sig" ] || [ -z "$$gate_sig" ]; then \
	  echo "FAIL: missing MTS RTL/gate signature"; exit 1; \
	fi; \
	if [ "$$rtl_sig" != "$$gate_sig" ]; then \
	  echo "FAIL: MTS RTL/gate signature mismatch (rtl=$$rtl_sig gate=$$gate_sig)"; exit 1; \
	fi; \
	echo "PASS: matching MTS signature $$gate_sig"

clean:
	rm -rf $(RTL_WORK) $(GATE_WORK) $(LOG_DIR) transcript vsim.wlf modelsim.ini
