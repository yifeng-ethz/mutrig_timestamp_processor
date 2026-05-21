include ../../scripts/questa_one.mk

SIM_LIB_DIR    := /data1/intelFPGA_pro/23.1/quartus/eda/sim_lib

IP_SRC = $(realpath ..)
WORK   = work_mts_processor

.PHONY: license_check compile run_math run_term run_rearm run_all clean

license_check:
	@echo "═══ Checking Mentor floating license at $(QUESTA_LICENSE_SERVER) ═══"
	@$(LMUTIL) lmstat -f mtiverification -c $(QUESTA_LICENSE_SERVER) >/dev/null 2>&1 || \
	  { echo "ERROR: mtiverification feature not visible via $(QUESTA_LICENSE_SERVER)"; exit 1; }

compile: license_check $(WORK)/_vmake

$(WORK)/_vmake: $(IP_SRC)/dual_port_rom.v \
                $(IP_SRC)/mts_processor.vhd \
                mts_processor_tb.vhd \
                mts_processor_terminating_tb.vhd \
                mts_processor_rearm_tb.vhd
	rm -rf $(WORK)
	$(VLIB) $(WORK)
	$(VLIB) lpm
	$(VMAP) lpm lpm
	$(VMAP) $(WORK) $(WORK)
	$(VCOM) -2008 -work lpm $(SIM_LIB_DIR)/220pack.vhd
	$(VCOM) -2008 -work lpm $(SIM_LIB_DIR)/220model.vhd
	$(VLOG) -work $(WORK) $(IP_SRC)/dual_port_rom.v
	$(VCOM) -2008 -work $(WORK) $(IP_SRC)/mts_processor.vhd
	$(VCOM) -2008 -work $(WORK) mts_processor_tb.vhd
	$(VCOM) -2008 -work $(WORK) mts_processor_terminating_tb.vhd
	$(VCOM) -2008 -work $(WORK) mts_processor_rearm_tb.vhd
	cp $(IP_SRC)/dual_port_rom_init.txt .
	@touch $@

run_math: compile
	$(VSIM) -c -L lpm -do "run -all; quit -f" -work $(WORK) mts_processor_tb

run_term: compile
	$(VSIM) -c -L lpm -do "run -all; quit -f" -work $(WORK) mts_processor_terminating_tb

# Re-arm regression for BUG-021-R: a 2nd RUN_PREPARE while in RESET must not deadlock.
run_rearm: compile
	$(VSIM) -c -L lpm -do "run -all; quit -f" -work $(WORK) mts_processor_rearm_tb

run_all: run_math run_term run_rearm

clean:
	rm -rf $(WORK) lpm transcript vsim.wlf dual_port_rom_init.txt
