QUESTA_HOME ?= /data1/intelFPGA_pro/23.1/questa_fse
VLIB        = $(QUESTA_HOME)/bin/vlib
VMAP        = $(QUESTA_HOME)/bin/vmap
VCOM        = $(QUESTA_HOME)/bin/vcom
VLOG        = $(QUESTA_HOME)/bin/vlog
VSIM        = $(QUESTA_HOME)/bin/vsim
VCOVER      = $(QUESTA_HOME)/bin/vcover
LMUTIL      = $(QUESTA_HOME)/linux_x86_64/lmutil

QUESTA_LICENSE := $(QUESTA_HOME)/LR-287689_License.dat
ETH_LIC_SERVER := 8161@lic-mentor.ethz.ch
SIM_LIB_DIR    := /data1/intelFPGA_pro/23.1/quartus/eda/sim_lib

export LM_LICENSE_FILE   := $(ETH_LIC_SERVER):$(QUESTA_LICENSE)
export MGLS_LICENSE_FILE := $(LM_LICENSE_FILE)

UVM_DIR       := $(abspath .)
IP_SRC        := $(abspath ../..)
WORK_DIR      = $(UVM_DIR)/work_$(RTL_VARIANT)
BUILD_DIR     = $(WORK_DIR)/build
LPM_DIR       = $(WORK_DIR)/lpm
LOG_DIR       := $(UVM_DIR)/logs
COV_DIR       = $(UVM_DIR)/cov_$(RTL_VARIANT)
UVM_HOME      ?= $(abspath $(QUESTA_HOME)/verilog_src/uvm-1.2)
UVM_SRC       := $(UVM_HOME)/src
UVM_DPI_SO    := $(firstword $(wildcard $(QUESTA_HOME)/uvm-1.2/linux_x86_64/uvm_dpi.so $(QUESTA_HOME)/verilog_src/uvm-1.2/linux_x86_64/uvm_dpi.so))
UVM_DPI_LIB   := $(basename $(UVM_DPI_SO))
DPI_CPP       ?= /usr/bin/gcc

RTL_VARIANT ?= after
TEST        ?= COMBO_MTSP_001_terminate_contract_test
CASE_ID     ?=
BUCKET_FRAME_TEST ?= COMBO_MTSP_001_terminate_contract_test
ALL_BUCKETS_FRAME_TEST ?= COMBO_MTSP_001_terminate_contract_test
SEED        ?= 1
VERBOSITY   ?= UVM_MEDIUM
TB_TOP      := tb_top
VCOM_COV    ?= -cover bcesft
VLOG_COV    ?= +cover=bcesft

RTL_SRC = $(if $(filter before,$(RTL_VARIANT)),$(BUILD_DIR)/mts_processor.vhd,$(IP_SRC)/mts_processor.vhd)
RUN_ID  = $(if $(CASE_ID),$(CASE_ID),$(TEST))

UVM_SRCS = \
	$(UVM_DIR)/mtsp_if.sv \
	$(UVM_DIR)/mtsp_cases.svh \
	$(UVM_DIR)/mtsp_env_pkg.sv \
	$(UVM_DIR)/tb_top.sv

.PHONY: license_check compile run run_sim run_isolated run_bucket_frame run_all_buckets_frame cov_report_case cov_merge cov_report_total run_before_expected_fail run_after prove_delta clean

license_check:
	@echo "═══ Checking Mentor floating license at $(ETH_LIC_SERVER) ═══"
	@$(LMUTIL) lmstat -f mtiverification -c $(ETH_LIC_SERVER) >/dev/null 2>&1 || \
	  { echo "ERROR: mtiverification feature not visible via $(ETH_LIC_SERVER)"; exit 1; }

compile: license_check $(WORK_DIR)/.compiled

$(WORK_DIR)/.compiled: $(IP_SRC)/dual_port_rom.v $(IP_SRC)/dual_port_rom_init.txt $(IP_SRC)/mts_processor.vhd $(UVM_SRCS)
	@echo "═══ Compiling mts_processor UVM bench ($(RTL_VARIANT)) ═══"
	@rm -rf $(WORK_DIR)
	@mkdir -p $(WORK_DIR) $(BUILD_DIR) $(LPM_DIR) $(LOG_DIR) $(COV_DIR)
	@if [ "$(RTL_VARIANT)" = "before" ]; then \
	  git -C $(IP_SRC) show HEAD:mts_processor.vhd > $(BUILD_DIR)/mts_processor.vhd; \
	fi
	@cp $(IP_SRC)/dual_port_rom_init.txt $(WORK_DIR)/
	@$(VLIB) $(WORK_DIR)/work
	@$(VLIB) $(LPM_DIR)
	@cd $(WORK_DIR) && $(VMAP) -c > /dev/null
	@cd $(WORK_DIR) && $(VMAP) -modelsimini modelsim.ini work $(WORK_DIR)/work > /dev/null
	@cd $(WORK_DIR) && $(VMAP) -modelsimini modelsim.ini lpm $(LPM_DIR) > /dev/null
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini modelsim.ini -work lpm $(SIM_LIB_DIR)/220pack.vhd
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini modelsim.ini -work lpm $(SIM_LIB_DIR)/220model.vhd
	@cd $(WORK_DIR) && $(VLOG) -modelsimini modelsim.ini -work work $(VLOG_COV) $(IP_SRC)/dual_port_rom.v
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini modelsim.ini -work work $(RTL_SRC)
	@cd $(WORK_DIR) && $(VLOG) -modelsimini modelsim.ini -work work $(VLOG_COV) -sv $(UVM_DIR)/mtsp_if.sv
	@cd $(WORK_DIR) && $(VLOG) -modelsimini modelsim.ini -work work -mfcu \
	  $(VLOG_COV) +incdir+$(UVM_SRC) +incdir+$(UVM_DIR) -sv \
	  $(UVM_SRC)/uvm_pkg.sv \
	  $(UVM_DIR)/mtsp_env_pkg.sv \
	  $(UVM_DIR)/tb_top.sv
	@touch $@

run: compile run_sim

run_sim:
	@echo "=== Running $(RUN_ID) test=$(TEST) variant=$(RTL_VARIANT) seed=$(SEED) ==="
	@mkdir -p $(COV_DIR)
	@rm -f $(COV_DIR)/$(RUN_ID)_s$(SEED).ucdb
	@cd $(WORK_DIR) && $(VSIM) -modelsimini modelsim.ini -c -coverage -L lpm \
	  -dpicpppath $(DPI_CPP) -sv_lib $(UVM_DPI_LIB) \
	  -sv_seed $(SEED) \
	  +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) $(if $(CASE_ID),+MTSP_CASE_ID=$(CASE_ID),) \
	  -suppress 3009 -suppress 3473 -voptargs="+acc" \
	  work.$(TB_TOP) \
	  -do "quietly set NumericStdNoWarnings 1; quietly set StdArithNoWarnings 1; coverage save -onexit $(COV_DIR)/$(RUN_ID)_s$(SEED).ucdb; run -all; quit -f" \
	  | tee $(LOG_DIR)/$(RUN_ID)_$(RTL_VARIANT)_s$(SEED).log
	@if grep -qE '^\# UVM_(FATAL|ERROR) /|^\# \*\* Fatal:|^\# \*\* Error:' $(LOG_DIR)/$(RUN_ID)_$(RTL_VARIANT)_s$(SEED).log; then \
	  echo "FAIL: $(RUN_ID) variant=$(RTL_VARIANT)"; exit 1; \
	elif ! grep -q '\*\*\* TEST PASSED \*\*\*' $(LOG_DIR)/$(RUN_ID)_$(RTL_VARIANT)_s$(SEED).log; then \
	  echo "FAIL: $(RUN_ID) variant=$(RTL_VARIANT)"; exit 1; \
	else \
	  echo "PASS: $(RUN_ID) variant=$(RTL_VARIANT)"; \
	fi

run_isolated:
	@$(MAKE) -s run RTL_VARIANT=$(RTL_VARIANT) TEST=$(TEST) SEED=$(SEED)

run_bucket_frame:
	@$(MAKE) -s run RTL_VARIANT=$(RTL_VARIANT) TEST=$(BUCKET_FRAME_TEST) SEED=$(SEED)

run_all_buckets_frame:
	@$(MAKE) -s run RTL_VARIANT=$(RTL_VARIANT) TEST=$(ALL_BUCKETS_FRAME_TEST) SEED=$(SEED)

cov_report_case:
	@$(VCOVER) report -details -code bcesft $(COV_DIR)/$(RUN_ID)_s$(SEED).ucdb | tee $(COV_DIR)/$(RUN_ID)_s$(SEED).txt

cov_merge:
	@rm -f $(COV_DIR)/merged.ucdb
	@$(VCOVER) merge $(COV_DIR)/merged.ucdb $(COV_DIR)/*.ucdb

cov_report_total: cov_merge
	@$(VCOVER) report -details -code bcesft $(COV_DIR)/merged.ucdb | tee $(COV_DIR)/merged.txt

run_before_expected_fail:
	@if $(MAKE) -s run RTL_VARIANT=before TEST=$(TEST) SEED=$(SEED); then \
	  echo "ERROR: before variant unexpectedly passed"; exit 1; \
	else \
	  echo "Observed expected failure for before variant"; \
	fi

run_after:
	@$(MAKE) -s run RTL_VARIANT=after TEST=$(TEST) SEED=$(SEED)

prove_delta: run_before_expected_fail run_after

clean:
	rm -rf $(UVM_DIR)/work_before $(UVM_DIR)/work_after $(LOG_DIR) $(UVM_DIR)/cov_before $(UVM_DIR)/cov_after transcript vsim.wlf
