// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------

`default_nettype none

module sd_ctrl_fifo(
  input wire rst,
  input wire wr_clk,
  input wire rd_clk,
  input wire [39:0]din,
  input wire wr_en,
  input wire rd_en,
  output wire [39:0]dout,
  output wire full,
  output wire empty);

  genvar r;
  
  wire [4:0] empty_byte, full_byte;
  wire [119:0] dum; // To prevent warnings
  
  assign full = |full_byte;
  assign empty = |empty_byte;
  
  generate for (r = 0; r < 5; r=r+1)
     FIFO18E1 #(
                .ALMOST_EMPTY_OFFSET(13'h0080),    // Sets the almost empty threshold
                .ALMOST_FULL_OFFSET(13'h0080),     // Sets almost full threshold
                .DATA_WIDTH(9),                    // Sets data width to 4-36
                .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
                .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
                .FIFO_MODE("FIFO18"),              // Sets mode to FIFO18 or FIFO18_36
                .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
                .INIT(36'h000000000),              // Initial values on output port
                .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
                .SRVAL(36'h000000000)              // Set/Reset value for output port
                )
      FIFO18E1_inst_18 (
                        // Read Data: 32-bit (each) output: Read output data
                        .DO({dum[r*24 +: 24],dout[r*8 +: 8]}), // 32-bit output: Data output
                        .DOP(),                    // 4-bit output: Parity data output
                        // Status: 1-bit (each) output: Flags and other FIFO status outputs
                        .ALMOSTEMPTY(),            // 1-bit output: Almost empty flag
                        .ALMOSTFULL(),             // 1-bit output: Almost full flag
                        .EMPTY(empty_byte[r]),     // 1-bit output: Empty flag
                        .FULL(full_byte[r]),       // 1-bit output: Full flag
                        .RDCOUNT(),                // 12-bit output: Read count
                        .RDERR(),                  // 1-bit output: Read error
                        .WRCOUNT(),                // 12-bit output: Write count
                        .WRERR(),                  // 1-bit output: Write error
                        // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
                        .RDCLK(rd_clk),            // 1-bit input: Read clock
                        .RDEN(rd_en),              // 1-bit input: Read enable
                        .REGCE(1'b1),              // 1-bit input: Clock enable
                        .RST(rst),                 // 1-bit input: Asynchronous Reset
                        .RSTREG(1'b0),             // 1-bit input: Output register set/reset
                        // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
                        .WRCLK(wr_clk),            // 1-bit input: Write clock
                        .WREN(wr_en),              // 1-bit input: Write enable
                        // Write Data: 32-bit (each) input: Write input data
                        .DI({24'b0,din[r*8 +: 8]}),// 32-bit input: Data input
                        .DIP(1'b0)                 // 4-bit input: Parity input
                        );

   endgenerate

endmodule
