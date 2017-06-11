VIVADO ?= vivado
VIVADOFLAGS := \
	-nojournal -mode batch \
	-source script/board.tcl \
	-source script/prologue.tcl

bit := obj/system.bit
$(bit): script/impl.tcl  script/init.tcl
	VSRC_TOP=$(VSRC_TOP) EXTRA_VSRCS="$(EXTRA_VSRCS)" $(VIVADO) $(VIVADOFLAGS) -source script/init.tcl -source script/impl.tcl

.PHONY: bit
bit: $(bit)

vcs := vcs/tb.sh
$(vcs): script/export_sim.tcl  script/init.tcl
	VSRC_TOP=$(VSRC_TOP) EXTRA_VSRCS="$(EXTRA_VSRCS)" $(VIVADO) $(VIVADOFLAGS) -source script/init.tcl -source script/export_sim.tcl
	sed -i -e 's/vlogan_opts="-full64"/vlogan_opts="-kdb -full64 +define+RANDOMIZE_REG_INIT"/' $(vcs)
	sed -i -e 's/vcs_elab_opts="-full64 -debug_pp/vcs_elab_opts="-kdb -lca -full64 -debug_access/' $(vcs)

.PHONY: vcs
vcs: $(vcs)

.PHONY: clean
clean::
	rm -rf -- .Xil .ip_user_files *.os obj src/generated usage_statistics_webtalk.xml usage_statistics_webtalk.html *.log .srcs .cache .cxl.ip synopsys_sim.setup compile_simlib.log
