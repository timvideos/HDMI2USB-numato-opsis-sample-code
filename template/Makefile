
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
	-filter "../ise/iseconfig/filter.filter" \
	-ifn "../ise/opsis.xst" \
	-ofn "opsis.syr" \
        $(COLORTOOLCMD)
	
tran:
	@echo "========================================================="
	@echo "                        Translate                        "
	@echo "========================================================="	
	cd $(BUILD_DIR); \
	ngdbuild \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-dd _ngo \
	-sd ../ipcore_dir \
	-nt timestamp \
	-uc ../opsis.ucf \
	-p $(PART) opsis.ngc opsis.ngd \
        $(COLORTOOLCMD)

map:
	@echo "========================================================="
	@echo "                          Map                            "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	map \
	-filter "../ise/iseconfig/filter.filter" \
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
	-o opsis_map.ncd opsis.ngd opsis.pcf \
        $(COLORTOOLCMD)

par:
	@echo "========================================================="
	@echo "                     Place & Route                       "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	par \
	-filter "../ise/iseconfig/filter.filter" -w \
	-intstyle $(INTSTYLE) \
	-ol high \
	-xe n \
	-mt off opsis_map.ncd opsis.ncd opsis.pcf \
        $(COLORTOOLCMD)

trce:
	@echo "========================================================="
	@echo "                        Trace                            "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	trce \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-v 3 \
	-s 3 \
	-n 3 \
	-fastpaths \
	-xml opsis.twx opsis.ncd \
	-o opsis.twr opsis.pcf \
        $(COLORTOOLCMD)

bit:
	@echo "========================================================="
	@echo "                        Bitgen                           "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	bitgen \
	-filter "../ise/iseconfig/filter.filter" \
	-intstyle $(INTSTYLE) \
	-f ../ise/opsis.ut opsis.ncd \
        $(COLORTOOLCMD)

xsvf:
	@echo "========================================================="
	@echo "                        xsvf file                        "
	@echo "========================================================="
	cd $(BUILD_DIR); \
	impact -batch ../ise/create-xsvf.batch \
        $(COLORTOOLCMD)

clean:
	rm -R $(BUILD_DIR) || true

