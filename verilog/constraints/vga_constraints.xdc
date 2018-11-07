## ELC 495/496 - Senior Project
## VGA Constraints

# Clock (100 MHz Oscillator on Board)
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; IO_L12P_T1_MRCC_35 Sch=clk100mhz

# Reset Switch (bottom left switch on board --> should switch to a push button)
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports rst_]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { rst_ }]; IO_L21P_T3_DQS_14 Sch=sw[15]

# Enable Switch (can get rid of this, it's not really needed)
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports enable]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { enable }]; IO_L19N_T3_A09_D25_VREF_14 Sch=sw[14] 

set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { test_mode }]; IO_L24N_T3_RS0_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { btn_r }]; IO_L10N_T1_D15_14 Sch=btnr

## VGA Connections
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {vga_red[0]}]
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { vga_red[0] }]; IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {vga_red[1]}]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[1] }]; IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {vga_red[2]}]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { vga_red[2] }]; IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {vga_red[3]}]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[3] }]; IO_L8P_T1_AD14P_35 Sch=vga_r[3]

set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {vga_green[0]}]
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[0] }]; IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {vga_green[1]}]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { vga_green[1] }]; IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {vga_green[2]}]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[2] }]; IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {vga_green[3]}]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[3] }]; IO_L3P_T0_DQS_AD5P_35 Sch=vga_g[3]

set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[0]}]
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[0] }]; IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[1]}]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[1] }]; IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {vga_blue[2]}]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[2] }]; IO_L6N_T0_VREF_35 Sch=vga_b[2]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {vga_blue[3]}]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[3] }]; IO_L4P_T0_35 Sch=vga_b[3]

set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports vga_h_sync]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { vga_h_sync }]; IO_L4P_T0_15 Sch=vga_hs
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports vga_v_sync]
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { vga_v_sync }]; IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
