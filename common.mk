# See LICENSE for license details.

# Required variables:
# - MODEL
# - PROJECT
# - CONFIG_PROJECT
# - CONFIG
# - BUILD_DIR
# - FPGA_DIR

# Optional variables:
# - EXTRA_FPGA_VSRCS

EXTRA_FPGA_VSRCS ?=

base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
rocketchip_dir := $(base_dir)/rocket-chip
SBT ?= java -jar $(rocketchip_dir)/sbt-launch.jar

# Build firrtl.jar and put it where chisel3 can find it.
FIRRTL_JAR ?= $(rocketchip_dir)/firrtl/utils/bin/firrtl.jar
FIRRTL ?= java -Xmx16G -Xss8M -XX:MaxPermSize=256M -cp $(FIRRTL_JAR) firrtl.Driver

$(FIRRTL_JAR): $(shell find $(rocketchip_dir)/firrtl/src/main/scala -iname "*.scala")
	$(MAKE) -C $(rocketchip_dir)/firrtl SBT="$(SBT)" root_dir=$(rocketchip_dir)/firrtl build-scala
	touch $(FIRRTL_JAR)
	mkdir -p $(rocketchip_dir)/chisel3/lib
	cp -p $(FIRRTL_JAR) $(rocketchip_dir)/chisel3/lib

# Build .fir
firrtl := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).fir
$(firrtl): $(shell find $(base_dir)/src/main/scala -name '*.scala') $(FIRRTL_JAR)
	mkdir -p $(dir $@)
	$(SBT) "run-main rocketchip.Generator $(BUILD_DIR) $(PROJECT) $(MODEL) $(CONFIG_PROJECT) $(CONFIG)"

.PHONY: firrtl
firrtl: $(firrtl)

# Build .v
verilog := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).v
$(verilog): $(firrtl) $(FIRRTL_JAR)
	$(FIRRTL) -i $(firrtl) -o $@ -X verilog

.PHONY: verilog
verilog: $(verilog)

# Build .mcs
mcs := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).mcs
$(mcs): $(verilog)
	VSRC_TOP=$(verilog) EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) mcs
	cp $(FPGA_DIR)/obj/system.mcs $@

.PHONY: mcs
mcs: $(mcs)

# Build .bit
bit := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).bit
$(bit): $(verilog)
	VSRC_TOP=$(verilog) EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) bit
	cp $(FPGA_DIR)/obj/system.bit $@

.PHONY: bit
bit: $(bit)

# Build VCS simulation script
vcs := $(FPGA_DIR)/vcs/tb.sh
$(vcs): $(verilog)
	VSRC_TOP=$(verilog) EXTRA_VSRCS="$(EXTRA_FPGA_VSRCS)" $(MAKE) -C $(FPGA_DIR) vcs

.PHONY: vcs
vcs: $(vcs)

# Clean
.PHONY: clean
clean:
	$(MAKE) -C $(FPGA_DIR) clean
	rm -rf $(BUILD_DIR)
