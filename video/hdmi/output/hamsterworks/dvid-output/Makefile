
# We use the special PIPESTATUS which is bash only below.
SHELL := /bin/bash

COLORTOOL=color-xilinx-ise
COLORS := $(shell echo yes | $(COLORTOOL) 2>/dev/null)
ifdef COLORS
COLORTOOLCMD = | $(COLORTOOL); (exit $${PIPESTATUS[0]})
else
COLORTOOLCMD =
endif

INTSTYLE = ise
# INTSTYLE = silent

# build directory for temp files
BUILD_DIR = build 

# Top Level
all: syn tran map par trce bit

PART=xc6slx45t-fgg484-3

syn:
	@echo "========================================================="
	@echo "                       Synthesizing                      "
	@echo "========================================================="
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR); \
	xst \
	-intstyle $(INTSTYLE) \
	-ifn "../dvid_output.xst" \
	-ofn "dvid_output.syr" \
        $(COLORTOOLCMD)
	
tran:
	@echo "========================================================="
	@echo "                        Translate                        "
	@echo "========================================================="	
	cd $(BUILD_DIR); \
	ngdbuild \
	-intstyle $(INTSTYLE) \
	-dd _ngo \
	-sd ../ipcore_dir \
	-nt timestamp \
	-uc ../constraints/opsis.ucf \
	-p $(PART) dvid_output.ngc dvid_output.ngd \
        $(COLORTOOLCMD)

map:
	@echo "========================================================="
	@echo "                          Map                            "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	map \
	-intstyle $(INTSTYLE) \
	-p $(PART) \
	-w -logic_opt off \
	-ol high \
	-xe n \
	-t 1 \
	-xt 0 \
	-register_duplication off \
	-r 4 \
	-global_opt off \
	-mt off -ir off \
	-pr b -lc off \
	-power off \
	-o dvid_output_map.ncd dvid_output.ngd dvid_output.pcf \
        $(COLORTOOLCMD)

par:
	@echo "========================================================="
	@echo "                     Place & Route                       "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	par \
	-intstyle $(INTSTYLE) \
	-ol high \
	-xe n \
	-mt off dvid_output_map.ncd dvid_output.ncd dvid_output.pcf \
        $(COLORTOOLCMD)

trce:
	@echo "========================================================="
	@echo "                        Trace                            "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	trce \
	-intstyle $(INTSTYLE) \
	-v 3 \
	-s 3 \
	-n 3 \
	-fastpaths \
	-xml dvid_output.twx dvid_output.ncd \
	-o dvid_output.twr dvid_output.pcf \
        $(COLORTOOLCMD)

bit:
	@echo "========================================================="
	@echo "                        Bitgen                           "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	bitgen \
	-intstyle $(INTSTYLE) \
	-f ../dvid_output.ut dvid_output.ncd \
        $(COLORTOOLCMD)

clean:
	rm -R $(BUILD_DIR) || true

