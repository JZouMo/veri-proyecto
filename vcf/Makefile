SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := vc_formal
.PHONY: vc_formal

VCF_ROOT := $(CURDIR)
PROJECT_ROOT := $(abspath $(CURDIR)/..)
RUN ?= baseline_01

vc_formal:
	set -e
	set -o pipefail
	source $(VCF_ROOT)/setup.sh
	mkdir -p $(PROJECT_ROOT)/logs
	mkdir -p $(VCF_ROOT)/runs
	mkdir $(VCF_ROOT)/runs/$(RUN)
	cd $(VCF_ROOT)/runs/$(RUN)
	vcf -verdi -f $(VCF_ROOT)/cpu_vc_formal.tcl 2>&1 | tee $(PROJECT_ROOT)/logs/formal_$(RUN).log