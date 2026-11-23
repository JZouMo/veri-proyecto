# CPU equivalence expressed as two FPV comparison assertions.
set_app_var fml_mode_on true
set_fml_appmode FPV

# Resolve sources from this script, independent of the run directory.
set src_dir [file dirname [file normalize [info script]]]
set sources [list \
    [file join $src_dir alu.sv] \
    [file join $src_dir cpu.sv] \
    [file join $src_dir cpu_behavioral.sv] \
    [file join $src_dir cpu_tb_top.sv]]

read_file -sva -format sverilog -top cpu_tb_top -vcs $sources

create_clock -period 10 clk
create_reset -sense high rst

# Guide addition: explicitly establish and save the reset state.
sim_run -stable
sim_save_reset

check_fv
report_fv