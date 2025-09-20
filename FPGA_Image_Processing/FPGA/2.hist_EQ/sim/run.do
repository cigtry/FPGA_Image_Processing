file copy -force ../../../../modelsim.ini modelsim.ini

vlib xil_defaultlib
vmap xil_defaultlib xil_defaultlib

vlog -sv -incr -work xil_defaultlib \
"../testbench.sv" \

vlog -incr +cover -work xil_defaultlib \
-f "../design_ver.f" \



# 不使用任何器件库
vsim -voptargs="+acc" -t ps -quiet -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.testbench 

# 使用altera器件库，通过-L添加对应的器件库，例如：
 #vsim -voptargs="+acc" -t ps -quiet -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.testbench 
  #vlog D:/fuxin/8729/Book_VIP-master/2_FPGA_Sim/4.1_Avg_Filter/ip/shift_ram.v
# 使用xilinx器件库，编译glbl.v并通过-L添加对应的器件库，例如：
 # vlog -work xil_defaultlib "../../../glbl.v"
 # vsim -voptargs="+acc" -t ps -coverage -L xil_defaultlib -L blk_mem_gen_v8_4_1 -L axi_mmu_v2_1_15 -L axi_clock_converter_v2_1_16 -L axi_register_slice_v2_1_17 -L axi_crossbar_v2_1_18 -L generic_baseblocks_v2_1_0 -L axi_data_fifo_v2_1_16 -L fifo_generator_v13_2_2 -L axi_infrastructure_v1_1_0 -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.testbench xil_defaultlib.glbl


add wave *
log -r /*
run 20ms
