include ../../../scripts/questa_one.mk

SIM_LIB_DIR    := /data1/intelFPGA_pro/23.1/quartus/eda/sim_lib

UVM_DIR       := $(abspath .)
IP_SRC        := $(abspath ../..)
WORK_DIR      = $(UVM_DIR)/work_$(RTL_VARIANT)
BUILD_DIR     = $(WORK_DIR)/build
LPM_DIR       = $(WORK_DIR)/lpm
LOG_DIR       := $(UVM_DIR)/logs
COV_DIR       = $(UVM_DIR)/cov_$(RTL_VARIANT)
MODELSIM_INI  := modelsim.ini
UVM_HOME      ?= $(QUESTA_UVM_HOME)
UVM_SRC       := $(UVM_HOME)/src
UVM_DPI_SO    := $(QUESTA_UVM_DPI_SO)
UVM_DPI_LIB   := $(basename $(UVM_DPI_SO))
DPI_CPP       ?= /usr/bin/gcc

RTL_VARIANT ?= after
TEST        ?= COMBO_MTSP_001_terminate_contract_test
CASE_ID     ?=
FRAME_KIND  ?= isolated
FRAME_BUCKET ?= BASIC
BUCKET_FRAME_TEST ?= mtsp_continuous_frame_test
ALL_BUCKETS_FRAME_TEST ?= mtsp_continuous_frame_test
SEED        ?= 1
VERBOSITY   ?= UVM_MEDIUM
TB_TOP      := tb_top
VCOM_COV    ?= -cover bcesft
VLOG_COV    ?= +cover=bcesft
DEBUG_PATH_REQUIRED ?= 1
RESET_EXPECTED_LATENCY ?= 2000
EXPECTED_BANK_OFFSET ?= 0
DUT_GENERIC_ARGS ?=
CASE_VSIM_GENERIC_ARGS :=

ifeq ($(CASE_ID),STD_MTS_111_compile_rtl_default_div_pipeline)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=4
endif
ifeq ($(CASE_ID),STD_MTS_112_compile_packaged_div_pipeline)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=2
endif
ifeq ($(CASE_ID),STD_MTS_113_single_enabled_channel_window)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=0 -g/tb_top/dut/ENABLED_CHANNEL_HI=0
endif
ifeq ($(CASE_ID),STD_MTS_114_upper_enabled_window)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=2 -g/tb_top/dut/ENABLED_CHANNEL_HI=3
endif
ifeq ($(CASE_ID),STD_MTS_115_remapped_hiterr_bit)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/HITERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),STD_MTS_116_remapped_crcerr_still_inert)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/CRCERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),STD_MTS_117_remapped_frame_corrupt_still_inert)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/FRAME_CORRPT_BIT_LOC=1
endif
ifeq ($(CASE_ID),STD_MTS_118_changed_latency_generic_at_power_on)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/MUTRIG_BUFFER_EXPECTED_LATENCY_8N=128
RESET_EXPECTED_LATENCY := 128
endif
ifeq ($(CASE_ID),STD_MTS_119_bank_string_is_debug_only)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/BANK=DOWN
EXPECTED_BANK_OFFSET := 4
endif
ifeq ($(CASE_ID),STD_MTS_120_debug_zero_is_functionally_equivalent)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DEBUG=0
endif
ifeq ($(CASE_ID),STD_MTS_106_total_counter_hi_rollover)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DV_COUNTER_SEED_ENABLE=1
endif
ifeq ($(CASE_ID),CORNER_MTS_018_counter_read_on_low_word_rollover)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DV_COUNTER_SEED_ENABLE=1
endif
ifeq ($(CASE_ID),CORNER_MTS_063_first_hit_disabled_channel_no_sop)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=1 -g/tb_top/dut/ENABLED_CHANNEL_HI=3
endif
ifeq ($(CASE_ID),NEG_MTS_063_sop_on_disabled_channel)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=1 -g/tb_top/dut/ENABLED_CHANNEL_HI=3
endif
ifeq ($(CASE_ID),CORNER_MTS_091_single_channel_window_index0)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=0 -g/tb_top/dut/ENABLED_CHANNEL_HI=0
endif
ifeq ($(CASE_ID),CORNER_MTS_092_single_channel_window_index3)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=3 -g/tb_top/dut/ENABLED_CHANNEL_HI=3
endif
ifeq ($(CASE_ID),CORNER_MTS_093_middle_window_indexing)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=1 -g/tb_top/dut/ENABLED_CHANNEL_HI=2
endif
ifeq ($(CASE_ID),CORNER_MTS_094_packaged_div_pipeline_delay)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=2
endif
ifeq ($(CASE_ID),CORNER_MTS_095_rtl_div_pipeline_delay)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=4
endif
ifeq ($(CASE_ID),CORNER_MTS_096_zero_default_latency_generic)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/MUTRIG_BUFFER_EXPECTED_LATENCY_8N=0
RESET_EXPECTED_LATENCY := 0
endif
ifeq ($(CASE_ID),CORNER_MTS_097_one_tick_default_latency_generic)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/MUTRIG_BUFFER_EXPECTED_LATENCY_8N=1
RESET_EXPECTED_LATENCY := 1
endif
ifeq ($(CASE_ID),CORNER_MTS_098_remapped_hiterr_to_bit2)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/HITERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),CORNER_MTS_099_frame_corrupt_bit_still_inert)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/FRAME_CORRPT_BIT_LOC=2
endif
ifeq ($(CASE_ID),CORNER_MTS_100_padding_eop_wait_still_inert)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/PADDING_EOP_WAIT_CYCLE=1
endif
ifeq ($(CASE_ID),STRESS_MTS_081_div_pipeline_two_under_load)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=2
endif
ifeq ($(CASE_ID),STRESS_MTS_082_div_pipeline_four_under_load)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=4
endif
ifeq ($(CASE_ID),STRESS_MTS_083_single_enabled_channel_soak)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=0 -g/tb_top/dut/ENABLED_CHANNEL_HI=0
endif
ifeq ($(CASE_ID),STRESS_MTS_084_two_enabled_channels_soak)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=1 -g/tb_top/dut/ENABLED_CHANNEL_HI=2
endif
ifeq ($(CASE_ID),STRESS_MTS_086_remapped_hiterr_soak)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/HITERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),STRESS_MTS_087_custom_default_latency_soak)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/MUTRIG_BUFFER_EXPECTED_LATENCY_8N=128
RESET_EXPECTED_LATENCY := 128
endif
ifeq ($(CASE_ID),STRESS_MTS_088_debug_zero_soak)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DEBUG=0
endif
ifeq ($(CASE_ID),STRESS_MTS_089_bank_up_vs_down_compare)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/BANK=DOWN
EXPECTED_BANK_OFFSET := 4
endif
ifeq ($(CASE_ID),STRESS_MTS_090_inert_parameter_sweep_compare)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/PADDING_EOP_WAIT_CYCLE=1 -g/tb_top/dut/CRCERR_BIT_LOC=2 -g/tb_top/dut/FRAME_CORRPT_BIT_LOC=1
endif
ifeq ($(CASE_ID),STRESS_MTS_106_smoke_vectors_div_pipeline_two)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=2
endif
ifeq ($(CASE_ID),STRESS_MTS_107_smoke_vectors_div_pipeline_four)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=4
endif
ifeq ($(CASE_ID),NEG_MTS_081_pipeline_two_math_regression)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/LPM_DIV_PIPELINE=2
endif
ifeq ($(CASE_ID),NEG_MTS_082_remapped_hiterr_not_honored)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/HITERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),NEG_MTS_083_default_latency_generic_not_reflected)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/MUTRIG_BUFFER_EXPECTED_LATENCY_8N=128
RESET_EXPECTED_LATENCY := 128
endif
ifeq ($(CASE_ID),NEG_MTS_084_debug_zero_changes_functionality)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DEBUG=0
endif
ifeq ($(CASE_ID),NEG_MTS_085_bank_string_changes_functionality)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/BANK=DOWN
EXPECTED_BANK_OFFSET := 4
endif
ifeq ($(CASE_ID),NEG_MTS_086_padding_eop_wait_changes_behavior_today)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/PADDING_EOP_WAIT_CYCLE=1
endif
ifeq ($(CASE_ID),NEG_MTS_087_crcerr_bit_changes_behavior_today)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/CRCERR_BIT_LOC=2
endif
ifeq ($(CASE_ID),NEG_MTS_088_frame_corrupt_bit_changes_behavior_today)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/FRAME_CORRPT_BIT_LOC=1
endif
ifeq ($(CASE_ID),NEG_MTS_089_invalid_enabled_window_compile_guard)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=1 -g/tb_top/dut/ENABLED_CHANNEL_HI=2
endif
ifeq ($(CASE_ID),NEG_MTS_090_out_of_range_enabled_values)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/ENABLED_CHANNEL_LO=3 -g/tb_top/dut/ENABLED_CHANNEL_HI=3
endif
ifeq ($(CASE_ID),NEG_MTS_105_hi_lo_counter_snapshot_incoherent)
CASE_VSIM_GENERIC_ARGS += -g/tb_top/dut/DV_COUNTER_SEED_ENABLE=1
endif

RTL_SRC = $(if $(filter before,$(RTL_VARIANT)),$(BUILD_DIR)/mts_processor.vhd,$(IP_SRC)/mts_processor.vhd)
RUN_ID_BASE = $(if $(CASE_ID),$(CASE_ID),$(TEST))
RUN_ID ?= $(RUN_ID_BASE)

UVM_SRCS = \
	$(UVM_DIR)/mtsp_if.sv \
	$(UVM_DIR)/mtsp_cases.svh \
	$(UVM_DIR)/mtsp_env_pkg.sv \
	$(UVM_DIR)/tb_top.sv

.PHONY: license_check compile run run_sim run_isolated run_bucket_frame run_all_buckets_frame cov_report_case cov_merge cov_report_total hw_tcl_validate_check run_before_expected_fail run_after prove_delta clean

license_check:
	@echo "═══ Checking Mentor floating license at $(QUESTA_LICENSE_SERVER) ═══"
	@$(LMUTIL) lmstat -f mtiverification -c $(QUESTA_LICENSE_SERVER) >/dev/null 2>&1 || \
	  { echo "ERROR: mtiverification feature not visible via $(QUESTA_LICENSE_SERVER)"; exit 1; }

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
	@cp $(QSIM_INI) $(WORK_DIR)/$(MODELSIM_INI)
	@chmod u+w $(WORK_DIR)/$(MODELSIM_INI)
	@cd $(WORK_DIR) && $(VMAP) -modelsimini $(MODELSIM_INI) work $(WORK_DIR)/work > /dev/null
	@cd $(WORK_DIR) && $(VMAP) -modelsimini $(MODELSIM_INI) lpm $(LPM_DIR) > /dev/null
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini $(MODELSIM_INI) -work lpm $(SIM_LIB_DIR)/220pack.vhd
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini $(MODELSIM_INI) -work lpm $(SIM_LIB_DIR)/220model.vhd
	@cd $(WORK_DIR) && $(VLOG) -modelsimini $(MODELSIM_INI) -work work $(VLOG_COV) $(IP_SRC)/dual_port_rom.v
	@cd $(WORK_DIR) && $(VCOM) -2008 $(VCOM_COV) -modelsimini $(MODELSIM_INI) -work work $(RTL_SRC)
	@cd $(WORK_DIR) && $(VLOG) -modelsimini $(MODELSIM_INI) -work work $(VLOG_COV) -sv $(UVM_DIR)/mtsp_if.sv
	@cd $(WORK_DIR) && $(VLOG) -modelsimini $(MODELSIM_INI) -work work -mfcu \
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
	@cd $(WORK_DIR) && $(VSIM) -modelsimini $(MODELSIM_INI) -c -coverage -L lpm \
	  -dpicpppath $(DPI_CPP) -sv_lib $(UVM_DPI_LIB) \
	  -sv_seed $(SEED) \
	  +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) $(if $(CASE_ID),+MTSP_CASE_ID=$(CASE_ID),) \
	  +MTSP_FRAME_KIND=$(FRAME_KIND) +MTSP_FRAME_BUCKET=$(FRAME_BUCKET) \
	  +MTSP_DEBUG_PATH_REQUIRED=$(DEBUG_PATH_REQUIRED) \
	  +MTSP_EXPECTED_LATENCY_RESET=$(RESET_EXPECTED_LATENCY) \
	  +MTSP_EXPECTED_BANK_OFFSET=$(EXPECTED_BANK_OFFSET) \
	  -suppress 3009 -suppress 3473 -voptargs="+acc" \
	  $(CASE_VSIM_GENERIC_ARGS) $(DUT_GENERIC_ARGS) $(VSIM_GENERIC_ARGS) \
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
	@$(MAKE) -s run RTL_VARIANT=$(RTL_VARIANT) TEST=$(BUCKET_FRAME_TEST) \
	  RUN_ID=mtsp_bucket_frame_$(FRAME_BUCKET) FRAME_KIND=bucket_frame \
	  FRAME_BUCKET=$(FRAME_BUCKET) SEED=$(SEED)

run_all_buckets_frame:
	@$(MAKE) -s run RTL_VARIANT=$(RTL_VARIANT) TEST=$(ALL_BUCKETS_FRAME_TEST) \
	  RUN_ID=mtsp_all_buckets_frame FRAME_KIND=all_buckets_frame \
	  FRAME_BUCKET=ALL SEED=$(SEED)

cov_report_case:
	@$(VCOVER) report -details -code bcesft $(COV_DIR)/$(RUN_ID)_s$(SEED).ucdb | tee $(COV_DIR)/$(RUN_ID)_s$(SEED).txt

cov_merge:
	@rm -f $(COV_DIR)/merged.ucdb
	@$(VCOVER) merge $(COV_DIR)/merged.ucdb $(COV_DIR)/*.ucdb

cov_report_total: cov_merge
	@$(VCOVER) report -details -code bcesft $(COV_DIR)/merged.ucdb | tee $(COV_DIR)/merged.txt

hw_tcl_validate_check:
	@tclsh $(UVM_DIR)/scripts/check_hw_tcl_validation.tcl

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
