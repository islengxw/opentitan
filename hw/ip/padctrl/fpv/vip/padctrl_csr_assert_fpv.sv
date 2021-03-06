// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// FPV CSR read and write assertions auto-generated by `reggen` containing data structure
// Do Not Edit directly

`include "prim_assert.sv"

// Block: padctrl
module padctrl_csr_assert_fpv import tlul_pkg::*; (
  input clk_i,
  input rst_ni,

  //tile link ports
  input tl_h2d_t h2d,
  input tl_d2h_t d2h
);

  parameter int DWidth = 32;
  // mask register to convert byte to bit
  logic [DWidth-1:0] a_mask_bit;

  assign a_mask_bit[7:0]   = h2d.a_mask[0] ? '1 : '0;
  assign a_mask_bit[15:8]  = h2d.a_mask[1] ? '1 : '0;
  assign a_mask_bit[23:16] = h2d.a_mask[2] ? '1 : '0;
  assign a_mask_bit[31:24] = h2d.a_mask[3] ? '1 : '0;

  // declare common read and write sequences
  sequence device_wr_S(logic [4:0] addr);
    h2d.a_address == addr && h2d.a_opcode inside {PutFullData, PutPartialData} &&
        h2d.a_valid && h2d.d_ready && !d2h.d_valid;
  endsequence

  // this sequence is used for reg_field which has access w1c or w0c
  // it returns true if the `index` bit of a_data matches `exp_bit`
  // this sequence is under assumption - w1c/w0c will only use one bit per field
  sequence device_wc_S(logic [4:0] addr, bit exp_bit, int index);
    h2d.a_address == addr && h2d.a_opcode inside {PutFullData, PutPartialData} && h2d.a_valid &&
        h2d.d_ready && !d2h.d_valid && ((h2d.a_data[index] & a_mask_bit[index]) == exp_bit);
  endsequence

  sequence device_rd_S(logic [4:0] addr);
    h2d.a_address == addr && h2d.a_opcode inside {Get} && h2d.a_valid && h2d.d_ready &&
        !d2h.d_valid;
  endsequence

  // declare common read and write properties
  property wr_P(bit [4:0] addr, bit [DWidth-1:0] act_data, bit regen,
                bit [DWidth-1:0] mask);
    logic [DWidth-1:0] id, exp_data;
    (device_wr_S(addr), id = h2d.a_source, exp_data = h2d.a_data & a_mask_bit & mask) ##1
        first_match(##[0:$] d2h.d_valid && d2h.d_source == id) |->
        (d2h.d_error || act_data == exp_data || !regen);
  endproperty

  // external reg will use one clk cycle to update act_data from external
  property wr_ext_P(bit [4:0] addr, bit [DWidth-1:0] act_data, bit regen,
                    bit [DWidth-1:0] mask);
    logic [DWidth-1:0] id, exp_data;
    (device_wr_S(addr), id = h2d.a_source, exp_data = h2d.a_data & a_mask_bit & mask) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || $past(act_data) == exp_data || !regen);
  endproperty

  // For W1C or W0C, first scenario: write 1(W1C) or 0(W0C) that clears the value
  property wc0_P(bit [4:0] addr, bit act_data, bit regen, int index, bit clear_bit);
    logic [DWidth-1:0] id;
    (device_wc_S(addr, clear_bit, index), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || act_data == 1'b0 || !regen);
  endproperty

  // For W1C or W0C, second scenario: write 0(W1C) or 1(W0C) that won't clear the value
  property wc1_P(bit [4:0] addr, bit act_data, bit regen, int index, bit clear_bit);
    logic [DWidth-1:0] id;
    (device_wc_S(addr, !clear_bit, index), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || $stable(act_data) || !regen);
  endproperty

  property rd_P(bit [4:0] addr, bit [DWidth-1:0] act_data);
    logic [DWidth-1:0] id, exp_data;
    (device_rd_S(addr), id = h2d.a_source, exp_data = $past(act_data)) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == exp_data);
  endproperty

  property rd_ext_P(bit [4:0] addr, bit [DWidth-1:0] act_data);
    logic [DWidth-1:0] id, exp_data;
    (device_rd_S(addr), id = h2d.a_source, exp_data = act_data) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == exp_data);
  endproperty

  // read a WO register, always return 0
  property r_wo_P(bit [4:0] addr);
    logic [DWidth-1:0] id;
    (device_rd_S(addr), id = h2d.a_source) ##1
        first_match(##[0:$] (d2h.d_valid && d2h.d_source == id)) |->
        (d2h.d_error || d2h.d_data == 0);
  endproperty

  property wr_regen_stable_P(bit regen, bit [DWidth-1:0] exp_data);
    (!regen && $stable(regen)) |-> $stable(exp_data);
  endproperty

// for all the regsters, declare assertion
  // assertions for W0C reg fields:
  `ASSERT(regen_wc0_A, wc0_P(5'h0, i_padctrl.i_reg_top.regen_qs, 1, 0, 0))
  `ASSERT(regen_wc1_A, wc1_P(5'h0, i_padctrl.i_reg_top.regen_qs, 1, 0, 0))
  `ASSERT(regen_rd_A, rd_P(5'h0, i_padctrl.i_reg_top.regen_qs))


  // define local fpv variable for the multi_reg
  logic [31:0] dio_pads_q_fpv;
  for (genvar s = 0; s < 4; s++) begin : gen_dio_pads_q
    assign dio_pads_q_fpv[((s+1)*8-1):s*8] = i_padctrl.reg2hw.dio_pads[s].qe ?
        i_padctrl.reg2hw.dio_pads[s].q : dio_pads_q_fpv[((s+1)*8-1):s*8];
  end
  logic [31:0] dio_pads_d_fpv;
  for (genvar s = 0; s <= 4-1; s++) begin : gen_dio_pads_d
    assign dio_pads_d_fpv[((s+1)*8-1):s*8] = i_padctrl.hw2reg.dio_pads[s].d;
  end

  `ASSERT(dio_pads_wr_A, wr_ext_P(5'h4, dio_pads_q_fpv[31:0], i_padctrl.i_reg_top.regen_qs, 'hffffffff))
  `ASSERT(dio_pads_rd_A, rd_ext_P(5'h4, dio_pads_d_fpv[31:0]))
  `ASSERT(dio_pads_stable_A, wr_regen_stable_P(i_padctrl.i_reg_top.regen_qs, dio_pads_q_fpv[31:0]))

  // define local fpv variable for the multi_reg
  logic [127:0] mio_pads_q_fpv;
  for (genvar s = 0; s < 16; s++) begin : gen_mio_pads_q
    assign mio_pads_q_fpv[((s+1)*8-1):s*8] = i_padctrl.reg2hw.mio_pads[s].qe ?
        i_padctrl.reg2hw.mio_pads[s].q : mio_pads_q_fpv[((s+1)*8-1):s*8];
  end
  logic [127:0] mio_pads_d_fpv;
  for (genvar s = 0; s <= 16-1; s++) begin : gen_mio_pads_d
    assign mio_pads_d_fpv[((s+1)*8-1):s*8] = i_padctrl.hw2reg.mio_pads[s].d;
  end

  `ASSERT(mio_pads0_wr_A, wr_ext_P(5'h8, mio_pads_q_fpv[31:0], i_padctrl.i_reg_top.regen_qs, 'hffffffff))
  `ASSERT(mio_pads0_rd_A, rd_ext_P(5'h8, mio_pads_d_fpv[31:0]))
  `ASSERT(mio_pads0_stable_A, wr_regen_stable_P(i_padctrl.i_reg_top.regen_qs, mio_pads_q_fpv[31:0]))

  `ASSERT(mio_pads1_wr_A, wr_ext_P(5'hc, mio_pads_q_fpv[63:32], i_padctrl.i_reg_top.regen_qs, 'hffffffff))
  `ASSERT(mio_pads1_rd_A, rd_ext_P(5'hc, mio_pads_d_fpv[63:32]))
  `ASSERT(mio_pads1_stable_A, wr_regen_stable_P(i_padctrl.i_reg_top.regen_qs, mio_pads_q_fpv[63:32]))

  `ASSERT(mio_pads2_wr_A, wr_ext_P(5'h10, mio_pads_q_fpv[95:64], i_padctrl.i_reg_top.regen_qs, 'hffffffff))
  `ASSERT(mio_pads2_rd_A, rd_ext_P(5'h10, mio_pads_d_fpv[95:64]))
  `ASSERT(mio_pads2_stable_A, wr_regen_stable_P(i_padctrl.i_reg_top.regen_qs, mio_pads_q_fpv[95:64]))

  `ASSERT(mio_pads3_wr_A, wr_ext_P(5'h14, mio_pads_q_fpv[127:96], i_padctrl.i_reg_top.regen_qs, 'hffffffff))
  `ASSERT(mio_pads3_rd_A, rd_ext_P(5'h14, mio_pads_d_fpv[127:96]))
  `ASSERT(mio_pads3_stable_A, wr_regen_stable_P(i_padctrl.i_reg_top.regen_qs, mio_pads_q_fpv[127:96]))

endmodule
