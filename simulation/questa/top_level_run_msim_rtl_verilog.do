transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG {C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG/spike_encoder.sv}
vlog -sv -work work +incdir+C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG {C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG/lif_neuron_core.sv}
vlog -sv -work work +incdir+C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG {C:/Users/ericw/Documents/eric/snnproject/SNN-on-FPGA-for-ECG/arrhythmias_detection_toplevel.sv}

