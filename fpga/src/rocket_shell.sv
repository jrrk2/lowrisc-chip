// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: Xilinx FPGA top-level
// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

module rocket_shell (
  input logic  clk,
  input logic  rst_n,
  input logic test_en,
  input logic [ariane_soc::NumSources-1:0] irq_sources,
  AXI_BUS.Master dram, iobus,
  output logic ndmreset_n,
  // common part
  input logic  tck ,
  input logic  tms ,
  input logic  trst_n ,
  input logic  tdi ,
  output logic tdo_data ,
  output logic tdo_oe
);
 
   wire CAPTURE, DRCK, RESET, RUNTEST, SEL, SHIFT, TCK, TDI, TMS, UPDATE, TDO, TCK_unbuf, TDO_driven;

   /* This block is just used to feed the JTAG clock into the parts of Rocket that need it */
      
   BSCANE2 #(
      .JTAG_CHAIN(2)  // Value for USER command.
   )
   BSCANE2_inst1 (
      .CAPTURE(CAPTURE), // 1-bit output: CAPTURE output from TAP controller.
      .DRCK(DRCK),       // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
                         // SHIFT are asserted.

      .RESET(RESET),     // 1-bit output: Reset output for TAP controller.
      .RUNTEST(RUNTEST), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
      .SEL(SEL),         // 1-bit output: USER instruction active output.
      .SHIFT(SHIFT),     // 1-bit output: SHIFT output from TAP controller.
      .TCK(TCK_unbuf),   // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
      .TDI(TDI),         // 1-bit output: Test Data Input (TDI) output from TAP controller.
      .TMS(TMS),         // 1-bit output: Test Mode Select output. Fabric connection to TAP.
      .UPDATE(UPDATE),   // 1-bit output: UPDATE output from TAP controller
      .TDO(TDO)          // 1-bit input: Test Data Output (TDO) input for USER function.
   );

   // BUFH: HROW Clock Buffer for a Single Clocking Region
   //       Artix-7
   // Xilinx HDL Language Template, version 2016.1

   BUFH BUFH_inst (
      .O(TCK), // 1-bit output: Clock output
      .I(TCK_unbuf)  // 1-bit input: Clock input
   );

   ExampleRocketSystem Rocket
     (
      .debug_systemjtag_jtag_TCK(TCK),
      .debug_systemjtag_jtag_TMS(TMS),
      .debug_systemjtag_jtag_TDI(TDI),
      .debug_systemjtag_jtag_TDO_data(TDO),
      .debug_systemjtag_jtag_TDO_driven(TDO_driven),
      .debug_systemjtag_reset(RESET),
      .debug_systemjtag_mfr_id(11'h5AA),
      .debug_ndreset(),
      .debug_dmactive(),
      .mem_axi4_0_aw_valid                ( dram.aw_valid                     ),
      .mem_axi4_0_aw_ready                ( dram.aw_ready                     ),
      .mem_axi4_0_aw_bits_id              ( dram.aw_id                        ),
      .mem_axi4_0_aw_bits_addr            ( dram.aw_addr                      ),
      .mem_axi4_0_aw_bits_len             ( dram.aw_len                       ),
      .mem_axi4_0_aw_bits_size            ( dram.aw_size                      ),
      .mem_axi4_0_aw_bits_burst           ( dram.aw_burst                     ),
      .mem_axi4_0_aw_bits_lock            ( dram.aw_lock                      ),
      .mem_axi4_0_aw_bits_cache           ( dram.aw_cache                     ),
      .mem_axi4_0_aw_bits_prot            ( dram.aw_prot                      ),
      .mem_axi4_0_aw_bits_qos             ( dram.aw_qos                       ),
      .mem_axi4_0_w_valid                 ( dram.w_valid                      ),
      .mem_axi4_0_w_ready                 ( dram.w_ready                      ),
      .mem_axi4_0_w_bits_data             ( dram.w_data                       ),
      .mem_axi4_0_w_bits_strb             ( dram.w_strb                       ),
      .mem_axi4_0_w_bits_last             ( dram.w_last                       ),
      .mem_axi4_0_b_valid                 ( dram.b_valid                      ),
      .mem_axi4_0_b_ready                 ( dram.b_ready                      ),
      .mem_axi4_0_b_bits_id               ( dram.b_id                         ),
      .mem_axi4_0_b_bits_resp             ( dram.b_resp                       ),
      .mem_axi4_0_ar_valid                ( dram.ar_valid                     ),
      .mem_axi4_0_ar_ready                ( dram.ar_ready                     ),
      .mem_axi4_0_ar_bits_id              ( dram.ar_id                        ),
      .mem_axi4_0_ar_bits_addr            ( dram.ar_addr                      ),
      .mem_axi4_0_ar_bits_len             ( dram.ar_len                       ),
      .mem_axi4_0_ar_bits_size            ( dram.ar_size                      ),
      .mem_axi4_0_ar_bits_burst           ( dram.ar_burst                     ),
      .mem_axi4_0_ar_bits_lock            ( dram.ar_lock                      ),
      .mem_axi4_0_ar_bits_cache           ( dram.ar_cache                     ),
      .mem_axi4_0_ar_bits_prot            ( dram.ar_prot                      ),
      .mem_axi4_0_ar_bits_qos             ( dram.ar_qos                       ),
      .mem_axi4_0_r_valid                 ( dram.r_valid                      ),
      .mem_axi4_0_r_ready                 ( dram.r_ready                      ),
      .mem_axi4_0_r_bits_id               ( dram.r_id                         ),
      .mem_axi4_0_r_bits_data             ( dram.r_data                       ),
      .mem_axi4_0_r_bits_resp             ( dram.r_resp                       ),
      .mem_axi4_0_r_bits_last             ( dram.r_last                       ),
`ifdef MEM_USER_WIDTH
      .mem_axi4_0_aw_bits_user            ( dram.aw_user                      ),
      .mem_axi4_0_w_bits_user             ( dram.w_user                       ),
      .mem_axi4_0_b_bits_user             ( dram.b_user                       ),
      .mem_axi4_0_ar_bits_user            ( dram.ar_user                      ),
      .mem_axi4_0_r_bits_user             ( dram.r_user                       ),
`endif
      .mmio_axi4_0_aw_valid        ( iobus.aw_valid               ),
      .mmio_axi4_0_aw_ready        ( iobus.aw_ready               ),
      .mmio_axi4_0_aw_bits_id      ( iobus.aw_id                  ),
      .mmio_axi4_0_aw_bits_addr    ( iobus.aw_addr                ),
      .mmio_axi4_0_aw_bits_len     ( iobus.aw_len                 ),
      .mmio_axi4_0_aw_bits_size    ( iobus.aw_size                ),
      .mmio_axi4_0_aw_bits_burst   ( iobus.aw_burst               ),
      .mmio_axi4_0_aw_bits_lock    ( iobus.aw_lock                ),
      .mmio_axi4_0_aw_bits_cache   ( iobus.aw_cache               ),
      .mmio_axi4_0_aw_bits_prot    ( iobus.aw_prot                ),
      .mmio_axi4_0_aw_bits_qos     ( iobus.aw_qos                 ),
      .mmio_axi4_0_w_valid         ( iobus.w_valid                ),
      .mmio_axi4_0_w_ready         ( iobus.w_ready                ),
      .mmio_axi4_0_w_bits_data     ( iobus.w_data                 ),
      .mmio_axi4_0_w_bits_strb     ( iobus.w_strb                 ),
      .mmio_axi4_0_w_bits_last     ( iobus.w_last                 ),
      .mmio_axi4_0_b_valid         ( iobus.b_valid                ),
      .mmio_axi4_0_b_ready         ( iobus.b_ready                ),
      .mmio_axi4_0_b_bits_id       ( iobus.b_id                   ),
      .mmio_axi4_0_b_bits_resp     ( iobus.b_resp                 ),
      .mmio_axi4_0_ar_valid        ( iobus.ar_valid               ),
      .mmio_axi4_0_ar_ready        ( iobus.ar_ready               ),
      .mmio_axi4_0_ar_bits_id      ( iobus.ar_id                  ),
      .mmio_axi4_0_ar_bits_addr    ( iobus.ar_addr                ),
      .mmio_axi4_0_ar_bits_len     ( iobus.ar_len                 ),
      .mmio_axi4_0_ar_bits_size    ( iobus.ar_size                ),
      .mmio_axi4_0_ar_bits_burst   ( iobus.ar_burst               ),
      .mmio_axi4_0_ar_bits_lock    ( iobus.ar_lock                ),
      .mmio_axi4_0_ar_bits_cache   ( iobus.ar_cache               ),
      .mmio_axi4_0_ar_bits_prot    ( iobus.ar_prot                ),
      .mmio_axi4_0_ar_bits_qos     ( iobus.ar_qos                 ),
      .mmio_axi4_0_r_valid         ( iobus.r_valid                ),
      .mmio_axi4_0_r_ready         ( iobus.r_ready                ),
      .mmio_axi4_0_r_bits_id       ( iobus.r_id                   ),
      .mmio_axi4_0_r_bits_data     ( iobus.r_data                 ),
      .mmio_axi4_0_r_bits_resp     ( iobus.r_resp                 ),
      .mmio_axi4_0_r_bits_last     ( iobus.r_last                 ),
`ifdef MMIO_MASTER_USER_WIDTH
      .mmio_axi4_0_aw_bits_user    ( iobus.aw_user                ),
      .mmio_axi4_0_w_bits_user     ( iobus.w_user                 ),
      .mmio_axi4_0_b_bits_user     ( iobus.b_user                 ),
      .mmio_axi4_0_ar_bits_user    ( iobus.ar_user                ),
      .mmio_axi4_0_r_bits_user     ( iobus.r_user                 ),
`endif
      .l2_frontend_bus_axi4_0_aw_valid         ( '0 ),
      .l2_frontend_bus_axi4_0_aw_ready         (    ),
      .l2_frontend_bus_axi4_0_aw_bits_id       ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_addr     ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_len      ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_size     ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_burst    ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_lock     ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_cache    ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_prot     ( '0 ),
      .l2_frontend_bus_axi4_0_aw_bits_qos      ( '0 ),
      .l2_frontend_bus_axi4_0_w_valid          ( '0 ),
      .l2_frontend_bus_axi4_0_w_ready          (    ),
      .l2_frontend_bus_axi4_0_w_bits_data      ( '0 ),
      .l2_frontend_bus_axi4_0_w_bits_strb      ( '0 ),
      .l2_frontend_bus_axi4_0_w_bits_last      ( '0 ),
      .l2_frontend_bus_axi4_0_b_valid          (    ),
      .l2_frontend_bus_axi4_0_b_ready          ( '0 ),
      .l2_frontend_bus_axi4_0_b_bits_id        (    ),
      .l2_frontend_bus_axi4_0_b_bits_resp      (    ),
      .l2_frontend_bus_axi4_0_ar_valid         ( '0 ),
      .l2_frontend_bus_axi4_0_ar_ready         (    ),
      .l2_frontend_bus_axi4_0_ar_bits_id       ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_addr     ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_len      ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_size     ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_burst    ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_lock     ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_cache    ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_prot     ( '0 ),
      .l2_frontend_bus_axi4_0_ar_bits_qos      ( '0 ),
      .l2_frontend_bus_axi4_0_r_valid          (    ),
      .l2_frontend_bus_axi4_0_r_ready          ( '0 ),
      .l2_frontend_bus_axi4_0_r_bits_id        (    ),
      .l2_frontend_bus_axi4_0_r_bits_data      (    ),
      .l2_frontend_bus_axi4_0_r_bits_resp      (    ),
      .l2_frontend_bus_axi4_0_r_bits_last      (    ),
      .interrupts                    ( irq_sources  ),
      .clock                         ( clk          ),
      .reset                         ( !rst_n       )
      );

   assign ndmreset_n = rst_n;
   
endmodule
