#=======================================================================
# Makefile for Verilog simulation w/ IRUN
#-----------------------------------------------------------------------
#
# This makefile will build a rtl simulator and run various tests to
# verify proper functionality.
#=======================================================================

base_dir = $(abspath ..)
sim_dir = .
export build_dir = $(abspath ./generated-srcs)

include $(base_dir)/Makefrag-vars
include $(base_dir)/Makefrag-verilog
include $(base_dir)/Makefrag-srcs
include $(sim_dir)/Makefrag-sims