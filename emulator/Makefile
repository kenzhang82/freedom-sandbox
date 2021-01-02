#=======================================================================
# Makefile for Verilog simulation w/ verilator
#=======================================================================

base_dir  := $(abspath ..)
sim_dir   := .
build_dir := $(base_dir)/generated-srcs
vlted_dir := $(sim_dir)/verilated
export build_dir

include $(base_dir)/Makefrag-vars
include $(base_dir)/Makefrag-verilog
include $(base_dir)/Makefrag-srcs
include $(sim_dir)/Makefrag-verilator
