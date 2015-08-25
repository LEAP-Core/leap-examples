// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2015.1
// Copyright (C) 2015 Xilinx Inc. All rights reserved.
//
// ===========================================================


(* CORE_GENERATION_INFO="hls_ap_bus_test,hls_ip_2015_1,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7vx485tffg1761-2,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=8.750000,HLS_SYN_LAT=1238,HLS_SYN_TPT=none,HLS_SYN_MEM=1,HLS_SYN_DSP=0,HLS_SYN_FF=234,HLS_SYN_LUT=318}" *)

module hls_ap_bus_test (
        ap_clk,
        ap_rst_n,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        mem0_req_din,
        mem0_req_full_n,
        mem0_req_write,
        mem0_rsp_empty_n,
        mem0_rsp_read,
        mem0_address,
        mem0_datain,
        mem0_dataout,
        mem0_size
);

parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 5'b00000;
parameter    ap_ST_st2_fsm_1 = 5'b1;
parameter    ap_ST_st3_fsm_2 = 5'b10;
parameter    ap_ST_pp0_stg0_fsm_3 = 5'b11;
parameter    ap_ST_st7_fsm_4 = 5'b100;
parameter    ap_ST_st8_fsm_5 = 5'b101;
parameter    ap_ST_st9_fsm_6 = 5'b110;
parameter    ap_ST_st10_fsm_7 = 5'b111;
parameter    ap_ST_st11_fsm_8 = 5'b1000;
parameter    ap_ST_st12_fsm_9 = 5'b1001;
parameter    ap_ST_st13_fsm_10 = 5'b1010;
parameter    ap_ST_st14_fsm_11 = 5'b1011;
parameter    ap_ST_st15_fsm_12 = 5'b1100;
parameter    ap_ST_pp1_stg0_fsm_13 = 5'b1101;
parameter    ap_ST_st19_fsm_14 = 5'b1110;
parameter    ap_ST_pp2_stg0_fsm_15 = 5'b1111;
parameter    ap_ST_st23_fsm_16 = 5'b10000;
parameter    ap_const_lv1_0 = 1'b0;
parameter    ap_const_lv8_0 = 8'b00000000;
parameter    ap_const_lv6_0 = 6'b000000;
parameter    ap_const_lv8_1 = 8'b1;
parameter    ap_const_lv64_20 = 64'b100000;
parameter    ap_const_lv32_0 = 32'b00000000000000000000000000000000;
parameter    ap_const_lv32_20 = 32'b100000;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_const_lv32_7 = 32'b111;
parameter    ap_const_lv6_20 = 6'b100000;
parameter    ap_const_lv6_1 = 6'b1;
parameter    ap_const_lv8_20 = 8'b100000;
parameter    ap_const_lv8_80 = 8'b10000000;
parameter    ap_const_lv7_7F = 7'b1111111;
parameter    ap_true = 1'b1;

input   ap_clk;
input   ap_rst_n;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
output   mem0_req_din;
input   mem0_req_full_n;
output   mem0_req_write;
input   mem0_rsp_empty_n;
output   mem0_rsp_read;
output  [31:0] mem0_address;
input  [31:0] mem0_datain;
output  [31:0] mem0_dataout;
output  [31:0] mem0_size;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg mem0_req_din;
reg mem0_req_write;
reg mem0_rsp_read;
reg[31:0] mem0_address;
reg[31:0] mem0_dataout;
reg[31:0] mem0_size;
reg    ap_rst_n_inv;
reg   [4:0] ap_CS_fsm = 5'b00000;
reg   [5:0] indvar_reg_162;
reg   [5:0] indvar8_reg_185;
reg   [5:0] ap_reg_ppstg_indvar8_reg_185_pp1_it1;
reg    ap_reg_ppiten_pp1_it0 = 1'b0;
reg   [0:0] exitcond2_reg_467;
reg    ap_sig_bdd_61;
reg    ap_reg_ppiten_pp1_it1 = 1'b0;
reg    ap_reg_ppiten_pp1_it2 = 1'b0;
reg   [5:0] indvar1_reg_197;
wire   [31:0] buf_q0;
reg   [31:0] reg_209;
reg    ap_reg_ppiten_pp0_it0 = 1'b0;
reg    ap_reg_ppiten_pp0_it1 = 1'b0;
reg   [0:0] exitcond4_reg_409;
reg   [0:0] ap_reg_ppstg_exitcond4_reg_409_pp0_it1;
reg    ap_sig_bdd_83;
reg    ap_reg_ppiten_pp0_it2 = 1'b0;
reg    ap_reg_ppiten_pp2_it0 = 1'b0;
reg    ap_reg_ppiten_pp2_it1 = 1'b0;
reg   [0:0] exitcond3_reg_481;
reg   [0:0] ap_reg_ppstg_exitcond3_reg_481_pp2_it1;
reg    ap_sig_bdd_98;
reg    ap_reg_ppiten_pp2_it2 = 1'b0;
reg   [31:0] reg_214;
wire   [0:0] exitcond1_fu_231_p2;
wire   [5:0] k_1_fu_237_p2;
reg   [31:0] mem0_addr_2_reg_404;
wire   [0:0] exitcond4_fu_269_p2;
wire   [5:0] indvar_next_fu_275_p2;
wire   [0:0] is_0iter_fu_286_p2;
reg   [0:0] is_0iter_reg_423;
reg   [0:0] ap_reg_ppstg_is_0iter_reg_423_pp0_it1;
wire   [7:0] i_2_fu_292_p2;
wire   [6:0] tmp_4_fu_308_p2;
reg   [6:0] tmp_4_reg_435;
wire   [0:0] exitcond_fu_298_p2;
reg   [31:0] mem0_addr_reg_440;
wire   [7:0] i_1_fu_335_p2;
reg   [7:0] i_1_reg_452;
reg   [31:0] data_1_reg_457;
wire   [31:0] result_fu_341_p2;
reg   [31:0] result_reg_462;
wire   [0:0] exitcond2_fu_346_p2;
reg   [0:0] ap_reg_ppstg_exitcond2_reg_467_pp1_it1;
wire   [5:0] indvar_next9_fu_352_p2;
reg   [5:0] indvar_next9_reg_471;
wire   [31:0] mem0_addr_3_fu_363_p2;
reg   [31:0] mem0_addr_3_reg_476;
wire   [0:0] exitcond3_fu_369_p2;
wire   [5:0] indvar_next1_fu_375_p2;
wire   [0:0] is_0iter4_fu_386_p2;
reg   [0:0] is_0iter4_reg_495;
reg   [0:0] ap_reg_ppstg_is_0iter4_reg_495_pp2_it1;
reg   [4:0] buf_address0;
reg    buf_ce0;
reg    buf_we0;
reg   [31:0] buf_d0;
reg   [7:0] i_reg_139;
reg   [5:0] k_reg_151;
wire   [0:0] tmp_fu_219_p3;
reg   [7:0] i1_reg_173;
reg   [5:0] indvar8_phi_fu_189_p4;
wire   [63:0] tmp_2_fu_254_p1;
wire   [63:0] tmp_9_fu_281_p1;
wire   [63:0] tmp_3_fu_358_p1;
wire   [63:0] tmp_7_fu_381_p1;
wire   [63:0] tmp_10_fu_259_p1;
wire   [63:0] tmp_5_fu_314_p1;
wire   [63:0] tmp_6_fu_324_p1;
wire   [31:0] tmp_1_cast_fu_249_p1;
wire   [7:0] k_cast8_fu_227_p1;
wire   [7:0] tmp_1_fu_243_p2;
wire   [6:0] tmp_8_fu_304_p1;
reg   [4:0] ap_NS_fsm;


hls_ap_bus_test_buf #(
    .DataWidth( 32 ),
    .AddressRange( 32 ),
    .AddressWidth( 5 ))
buf_U(
    .clk( ap_clk ),
    .reset( ap_rst_n_inv ),
    .address0( buf_address0 ),
    .ce0( buf_ce0 ),
    .we0( buf_we0 ),
    .d0( buf_d0 ),
    .q0( buf_q0 )
);



/// the current state (ap_CS_fsm) of the state machine. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst_n_inv == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

/// ap_reg_ppiten_pp0_it0 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it0
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp0_it0 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == exitcond4_fu_269_p2))) begin
            ap_reg_ppiten_pp0_it0 <= ap_const_logic_0;
        end else if (((ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond1_fu_231_p2))) begin
            ap_reg_ppiten_pp0_it0 <= ap_const_logic_1;
        end
    end
end

/// ap_reg_ppiten_pp0_it1 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it1
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp0_it1 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & (ap_const_lv1_0 == exitcond4_fu_269_p2))) begin
            ap_reg_ppiten_pp0_it1 <= ap_const_logic_1;
        end else if ((((ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond1_fu_231_p2)) | ((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == exitcond4_fu_269_p2)))) begin
            ap_reg_ppiten_pp0_it1 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp0_it2 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp0_it2
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp0_it2 <= ap_const_logic_0;
    end else begin
        if (~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) begin
            ap_reg_ppiten_pp0_it2 <= ap_reg_ppiten_pp0_it1;
        end else if (((ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond1_fu_231_p2))) begin
            ap_reg_ppiten_pp0_it2 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp1_it0 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp1_it0
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp1_it0 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_lv1_0 == exitcond2_fu_346_p2))) begin
            ap_reg_ppiten_pp1_it0 <= ap_const_logic_0;
        end else if ((ap_ST_st15_fsm_12 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp1_it0 <= ap_const_logic_1;
        end
    end
end

/// ap_reg_ppiten_pp1_it1 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp1_it1
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp1_it1 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & (ap_const_lv1_0 == exitcond2_fu_346_p2))) begin
            ap_reg_ppiten_pp1_it1 <= ap_const_logic_1;
        end else if (((ap_ST_st15_fsm_12 == ap_CS_fsm) | ((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_lv1_0 == exitcond2_fu_346_p2)))) begin
            ap_reg_ppiten_pp1_it1 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp1_it2 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp1_it2
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp1_it2 <= ap_const_logic_0;
    end else begin
        if (~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))) begin
            ap_reg_ppiten_pp1_it2 <= ap_reg_ppiten_pp1_it1;
        end else if ((ap_ST_st15_fsm_12 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp1_it2 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp2_it0 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp2_it0
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp2_it0 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == exitcond3_fu_369_p2))) begin
            ap_reg_ppiten_pp2_it0 <= ap_const_logic_0;
        end else if ((ap_ST_st19_fsm_14 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp2_it0 <= ap_const_logic_1;
        end
    end
end

/// ap_reg_ppiten_pp2_it1 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp2_it1
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp2_it1 <= ap_const_logic_0;
    end else begin
        if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & (ap_const_lv1_0 == exitcond3_fu_369_p2))) begin
            ap_reg_ppiten_pp2_it1 <= ap_const_logic_1;
        end else if (((ap_ST_st19_fsm_14 == ap_CS_fsm) | ((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == exitcond3_fu_369_p2)))) begin
            ap_reg_ppiten_pp2_it1 <= ap_const_logic_0;
        end
    end
end

/// ap_reg_ppiten_pp2_it2 assign process. ///
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp2_it2
    if (ap_rst_n_inv == 1'b1) begin
        ap_reg_ppiten_pp2_it2 <= ap_const_logic_0;
    end else begin
        if (~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))) begin
            ap_reg_ppiten_pp2_it2 <= ap_reg_ppiten_pp2_it1;
        end else if ((ap_ST_st19_fsm_14 == ap_CS_fsm)) begin
            ap_reg_ppiten_pp2_it2 <= ap_const_logic_0;
        end
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st2_fsm_1 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_fu_219_p3))) begin
        i1_reg_173 <= ap_const_lv8_1;
    end else if (((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0))) begin
        i1_reg_173 <= i_1_reg_452;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st7_fsm_4 == ap_CS_fsm)) begin
        i_reg_139 <= i_2_fu_292_p2;
    end else if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(ap_start == ap_const_logic_0))) begin
        i_reg_139 <= ap_const_lv8_0;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st19_fsm_14 == ap_CS_fsm)) begin
        indvar1_reg_197 <= ap_const_lv6_0;
    end else if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it0) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & (ap_const_lv1_0 == exitcond3_fu_369_p2))) begin
        indvar1_reg_197 <= indvar_next1_fu_375_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st15_fsm_12 == ap_CS_fsm)) begin
        indvar8_reg_185 <= ap_const_lv6_0;
    end else if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & (exitcond2_reg_467 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        indvar8_reg_185 <= indvar_next9_reg_471;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond1_fu_231_p2))) begin
        indvar_reg_162 <= ap_const_lv6_0;
    end else if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & (ap_const_lv1_0 == exitcond4_fu_269_p2))) begin
        indvar_reg_162 <= indvar_next_fu_275_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st2_fsm_1 == ap_CS_fsm) & (ap_const_lv1_0 == tmp_fu_219_p3))) begin
        k_reg_151 <= ap_const_lv6_0;
    end else if (((ap_ST_st3_fsm_2 == ap_CS_fsm) & (ap_const_lv1_0 == exitcond1_fu_231_p2))) begin
        k_reg_151 <= k_1_fu_237_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        ap_reg_ppstg_exitcond2_reg_467_pp1_it1 <= exitcond2_reg_467;
        ap_reg_ppstg_indvar8_reg_185_pp1_it1 <= indvar8_reg_185;
        exitcond2_reg_467 <= exitcond2_fu_346_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)))) begin
        ap_reg_ppstg_exitcond3_reg_481_pp2_it1 <= exitcond3_reg_481;
        ap_reg_ppstg_is_0iter4_reg_495_pp2_it1 <= is_0iter4_reg_495;
        exitcond3_reg_481 <= exitcond3_fu_369_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)))) begin
        ap_reg_ppstg_exitcond4_reg_409_pp0_it1 <= exitcond4_reg_409;
        ap_reg_ppstg_is_0iter_reg_423_pp0_it1 <= is_0iter_reg_423;
        exitcond4_reg_409 <= exitcond4_fu_269_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((~(mem0_rsp_empty_n == ap_const_logic_0) & (ap_ST_st12_fsm_9 == ap_CS_fsm))) begin
        data_1_reg_457 <= mem0_datain;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st10_fsm_7 == ap_CS_fsm)) begin
        i_1_reg_452 <= i_1_fu_335_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it0) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        indvar_next9_reg_471 <= indvar_next9_fu_352_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & (ap_const_lv1_0 == exitcond3_fu_369_p2))) begin
        is_0iter4_reg_495 <= is_0iter4_fu_386_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & (ap_const_lv1_0 == exitcond4_fu_269_p2))) begin
        is_0iter_reg_423 <= is_0iter_fu_286_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond1_fu_231_p2))) begin
        mem0_addr_2_reg_404[7 : 0] <= tmp_10_fu_259_p1[7 : 0];
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st9_fsm_6 == ap_CS_fsm)) begin
        mem0_addr_reg_440[6 : 0] <= tmp_5_fu_314_p1[6 : 0];
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) | ((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))))) begin
        reg_209 <= buf_q0;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((((ap_ST_st11_fsm_8 == ap_CS_fsm) & ~(mem0_rsp_empty_n == ap_const_logic_0)) | ((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & (exitcond2_reg_467 == ap_const_lv1_0) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))))) begin
        reg_214 <= mem0_datain;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if ((ap_ST_st13_fsm_10 == ap_CS_fsm)) begin
        result_reg_462 <= result_fu_341_p2;
    end
end

/// assign process. ///
always @(posedge ap_clk)
begin
    if (((ap_ST_st8_fsm_5 == ap_CS_fsm) & (ap_const_lv1_0 == exitcond_fu_298_p2))) begin
        tmp_4_reg_435 <= tmp_4_fu_308_p2;
    end
end

/// ap_done assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st23_fsm_16 == ap_CS_fsm)) begin
        ap_done = ap_const_logic_1;
    end else begin
        ap_done = ap_const_logic_0;
    end
end

/// ap_idle assign process. ///
always @ (ap_start or ap_CS_fsm)
begin
    if ((~(ap_const_logic_1 == ap_start) & (ap_ST_st1_fsm_0 == ap_CS_fsm))) begin
        ap_idle = ap_const_logic_1;
    end else begin
        ap_idle = ap_const_logic_0;
    end
end

/// ap_ready assign process. ///
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st23_fsm_16 == ap_CS_fsm)) begin
        ap_ready = ap_const_logic_1;
    end else begin
        ap_ready = ap_const_logic_0;
    end
end

/// buf_address0 assign process. ///
always @ (ap_CS_fsm or ap_reg_ppiten_pp1_it2 or ap_reg_ppiten_pp0_it0 or ap_reg_ppiten_pp2_it0 or tmp_2_fu_254_p1 or tmp_9_fu_281_p1 or tmp_3_fu_358_p1 or tmp_7_fu_381_p1)
begin
    if ((ap_const_logic_1 == ap_reg_ppiten_pp1_it2)) begin
        buf_address0 = tmp_3_fu_358_p1;
    end else if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
        buf_address0 = tmp_2_fu_254_p1;
    end else if (((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it0))) begin
        buf_address0 = tmp_7_fu_381_p1;
    end else if (((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it0))) begin
        buf_address0 = tmp_9_fu_281_p1;
    end else begin
        buf_address0 = 'bx;
    end
end

/// buf_ce0 assign process. ///
always @ (ap_CS_fsm or ap_sig_bdd_61 or ap_reg_ppiten_pp1_it1 or ap_reg_ppiten_pp1_it2 or ap_reg_ppiten_pp0_it0 or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_reg_ppiten_pp2_it0 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2)
begin
    if (((ap_ST_st3_fsm_2 == ap_CS_fsm) | ((ap_ST_pp0_stg0_fsm_3 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) | ((ap_ST_pp2_stg0_fsm_15 == ap_CS_fsm) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it0) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))) | ((ap_const_logic_1 == ap_reg_ppiten_pp1_it2) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))))) begin
        buf_ce0 = ap_const_logic_1;
    end else begin
        buf_ce0 = ap_const_logic_0;
    end
end

/// buf_d0 assign process. ///
always @ (ap_CS_fsm or ap_reg_ppiten_pp1_it2 or reg_214 or tmp_1_cast_fu_249_p1)
begin
    if ((ap_const_logic_1 == ap_reg_ppiten_pp1_it2)) begin
        buf_d0 = reg_214;
    end else if ((ap_ST_st3_fsm_2 == ap_CS_fsm)) begin
        buf_d0 = tmp_1_cast_fu_249_p1;
    end else begin
        buf_d0 = 'bx;
    end
end

/// buf_we0 assign process. ///
always @ (ap_CS_fsm or ap_sig_bdd_61 or ap_reg_ppiten_pp1_it1 or ap_reg_ppiten_pp1_it2 or exitcond1_fu_231_p2 or ap_reg_ppstg_exitcond2_reg_467_pp1_it1)
begin
    if ((((ap_ST_st3_fsm_2 == ap_CS_fsm) & (ap_const_lv1_0 == exitcond1_fu_231_p2)) | ((ap_const_logic_1 == ap_reg_ppiten_pp1_it2) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & (ap_const_lv1_0 == ap_reg_ppstg_exitcond2_reg_467_pp1_it1)))) begin
        buf_we0 = ap_const_logic_1;
    end else begin
        buf_we0 = ap_const_logic_0;
    end
end

/// indvar8_phi_fu_189_p4 assign process. ///
always @ (ap_CS_fsm or indvar8_reg_185 or exitcond2_reg_467 or ap_reg_ppiten_pp1_it1 or indvar_next9_reg_471)
begin
    if (((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & (exitcond2_reg_467 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))) begin
        indvar8_phi_fu_189_p4 = indvar_next9_reg_471;
    end else begin
        indvar8_phi_fu_189_p4 = indvar8_reg_185;
    end
end

/// mem0_address assign process. ///
always @ (ap_CS_fsm or mem0_req_full_n or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or mem0_addr_2_reg_404 or ap_reg_ppstg_is_0iter_reg_423_pp0_it1 or exitcond_fu_298_p2 or mem0_addr_reg_440 or mem0_addr_3_reg_476 or ap_reg_ppstg_is_0iter4_reg_495_pp2_it1 or tmp_5_fu_314_p1 or tmp_6_fu_324_p1)
begin
    if (((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter4_reg_495_pp2_it1))) begin
        mem0_address = mem0_addr_3_reg_476;
    end else if (((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0))) begin
        mem0_address = mem0_addr_reg_440;
    end else if ((ap_ST_st10_fsm_7 == ap_CS_fsm)) begin
        mem0_address = tmp_6_fu_324_p1;
    end else if ((ap_ST_st9_fsm_6 == ap_CS_fsm)) begin
        mem0_address = tmp_5_fu_314_p1;
    end else if (((ap_ST_st8_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond_fu_298_p2))) begin
        mem0_address = ap_const_lv32_0;
    end else if (((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter_reg_423_pp0_it1))) begin
        mem0_address = mem0_addr_2_reg_404;
    end else begin
        mem0_address = 'bx;
    end
end

/// mem0_dataout assign process. ///
always @ (ap_CS_fsm or mem0_req_full_n or reg_209 or ap_reg_ppstg_exitcond4_reg_409_pp0_it1 or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_reg_ppstg_exitcond3_reg_481_pp2_it1 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or result_reg_462)
begin
    if (((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0))) begin
        mem0_dataout = result_reg_462;
    end else if ((((ap_const_lv1_0 == ap_reg_ppstg_exitcond4_reg_409_pp0_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) | ((ap_const_lv1_0 == ap_reg_ppstg_exitcond3_reg_481_pp2_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))))) begin
        mem0_dataout = reg_209;
    end else begin
        mem0_dataout = 'bx;
    end
end

/// mem0_req_din assign process. ///
always @ (ap_CS_fsm or mem0_req_full_n or ap_reg_ppstg_exitcond4_reg_409_pp0_it1 or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_reg_ppstg_exitcond3_reg_481_pp2_it1 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or ap_reg_ppstg_is_0iter_reg_423_pp0_it1 or exitcond_fu_298_p2 or ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)
begin
    if (((ap_ST_st9_fsm_6 == ap_CS_fsm) | (ap_ST_st10_fsm_7 == ap_CS_fsm) | ((ap_ST_st8_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond_fu_298_p2)))) begin
        mem0_req_din = ap_const_logic_0;
    end else if ((((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0)) | ((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter_reg_423_pp0_it1)) | ((ap_const_lv1_0 == ap_reg_ppstg_exitcond4_reg_409_pp0_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) | ((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)) | ((ap_const_lv1_0 == ap_reg_ppstg_exitcond3_reg_481_pp2_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))))) begin
        mem0_req_din = ap_const_logic_1;
    end else begin
        mem0_req_din = ap_const_logic_0;
    end
end

/// mem0_req_write assign process. ///
always @ (ap_CS_fsm or mem0_req_full_n or ap_reg_ppstg_exitcond4_reg_409_pp0_it1 or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_reg_ppstg_exitcond3_reg_481_pp2_it1 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or ap_reg_ppstg_is_0iter_reg_423_pp0_it1 or exitcond_fu_298_p2 or ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)
begin
    if (((ap_ST_st9_fsm_6 == ap_CS_fsm) | (ap_ST_st10_fsm_7 == ap_CS_fsm) | ((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0)) | ((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter_reg_423_pp0_it1)) | ((ap_const_lv1_0 == ap_reg_ppstg_exitcond4_reg_409_pp0_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2))) | ((ap_ST_st8_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond_fu_298_p2)) | ((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)) | ((ap_const_lv1_0 == ap_reg_ppstg_exitcond3_reg_481_pp2_it1) & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2))))) begin
        mem0_req_write = ap_const_logic_1;
    end else begin
        mem0_req_write = ap_const_logic_0;
    end
end

/// mem0_rsp_read assign process. ///
always @ (ap_CS_fsm or mem0_rsp_empty_n or exitcond2_reg_467 or ap_sig_bdd_61 or ap_reg_ppiten_pp1_it1)
begin
    if ((((ap_ST_st11_fsm_8 == ap_CS_fsm) & ~(mem0_rsp_empty_n == ap_const_logic_0)) | (~(mem0_rsp_empty_n == ap_const_logic_0) & (ap_ST_st12_fsm_9 == ap_CS_fsm)) | ((ap_ST_pp1_stg0_fsm_13 == ap_CS_fsm) & (exitcond2_reg_467 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))))) begin
        mem0_rsp_read = ap_const_logic_1;
    end else begin
        mem0_rsp_read = ap_const_logic_0;
    end
end

/// mem0_size assign process. ///
always @ (ap_CS_fsm or mem0_req_full_n or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or ap_reg_ppstg_is_0iter_reg_423_pp0_it1 or exitcond_fu_298_p2 or ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)
begin
    if (((ap_ST_st9_fsm_6 == ap_CS_fsm) | (ap_ST_st10_fsm_7 == ap_CS_fsm) | ((ap_ST_st14_fsm_11 == ap_CS_fsm) & ~(mem0_req_full_n == ap_const_logic_0)))) begin
        mem0_size = ap_const_lv32_1;
    end else if ((((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter_reg_423_pp0_it1)) | ((ap_ST_st8_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == exitcond_fu_298_p2)) | ((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == ap_reg_ppstg_is_0iter4_reg_495_pp2_it1)))) begin
        mem0_size = ap_const_lv32_20;
    end else begin
        mem0_size = 'bx;
    end
end
/// the next state (ap_NS_fsm) of the state machine. ///
always @ (ap_start or ap_CS_fsm or mem0_req_full_n or mem0_rsp_empty_n or ap_reg_ppiten_pp1_it0 or ap_sig_bdd_61 or ap_reg_ppiten_pp1_it1 or ap_reg_ppiten_pp1_it2 or ap_reg_ppiten_pp0_it0 or ap_reg_ppiten_pp0_it1 or ap_sig_bdd_83 or ap_reg_ppiten_pp0_it2 or ap_reg_ppiten_pp2_it0 or ap_reg_ppiten_pp2_it1 or ap_sig_bdd_98 or ap_reg_ppiten_pp2_it2 or exitcond1_fu_231_p2 or exitcond4_fu_269_p2 or exitcond_fu_298_p2 or exitcond2_fu_346_p2 or exitcond3_fu_369_p2 or tmp_fu_219_p3)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 :
        begin
            if (~(ap_start == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_st2_fsm_1 :
        begin
            if (~(ap_const_lv1_0 == tmp_fu_219_p3)) begin
                ap_NS_fsm = ap_ST_st8_fsm_5;
            end else begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end
        end
        ap_ST_st3_fsm_2 :
        begin
            if (~(ap_const_lv1_0 == exitcond1_fu_231_p2)) begin
                ap_NS_fsm = ap_ST_pp0_stg0_fsm_3;
            end else begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end
        end
        ap_ST_pp0_stg0_fsm_3 :
        begin
            if ((~((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1)) & ~((ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == exitcond4_fu_269_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1)))) begin
                ap_NS_fsm = ap_ST_pp0_stg0_fsm_3;
            end else if ((((ap_const_logic_1 == ap_reg_ppiten_pp0_it2) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1)) | ((ap_const_logic_1 == ap_reg_ppiten_pp0_it0) & ~(ap_sig_bdd_83 & (ap_const_logic_1 == ap_reg_ppiten_pp0_it2)) & ~(ap_const_lv1_0 == exitcond4_fu_269_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp0_it1)))) begin
                ap_NS_fsm = ap_ST_st7_fsm_4;
            end else begin
                ap_NS_fsm = ap_ST_pp0_stg0_fsm_3;
            end
        end
        ap_ST_st7_fsm_4 :
        begin
            ap_NS_fsm = ap_ST_st2_fsm_1;
        end
        ap_ST_st8_fsm_5 :
        begin
            if (~(ap_const_lv1_0 == exitcond_fu_298_p2)) begin
                ap_NS_fsm = ap_ST_st15_fsm_12;
            end else begin
                ap_NS_fsm = ap_ST_st9_fsm_6;
            end
        end
        ap_ST_st9_fsm_6 :
        begin
            ap_NS_fsm = ap_ST_st10_fsm_7;
        end
        ap_ST_st10_fsm_7 :
        begin
            ap_NS_fsm = ap_ST_st11_fsm_8;
        end
        ap_ST_st11_fsm_8 :
        begin
            if (~(mem0_rsp_empty_n == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st12_fsm_9;
            end else begin
                ap_NS_fsm = ap_ST_st11_fsm_8;
            end
        end
        ap_ST_st12_fsm_9 :
        begin
            if (~(mem0_rsp_empty_n == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st13_fsm_10;
            end else begin
                ap_NS_fsm = ap_ST_st12_fsm_9;
            end
        end
        ap_ST_st13_fsm_10 :
        begin
            ap_NS_fsm = ap_ST_st14_fsm_11;
        end
        ap_ST_st14_fsm_11 :
        begin
            if (~(mem0_req_full_n == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st8_fsm_5;
            end else begin
                ap_NS_fsm = ap_ST_st14_fsm_11;
            end
        end
        ap_ST_st15_fsm_12 :
        begin
            ap_NS_fsm = ap_ST_pp1_stg0_fsm_13;
        end
        ap_ST_pp1_stg0_fsm_13 :
        begin
            if ((~((ap_const_logic_1 == ap_reg_ppiten_pp1_it2) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~((ap_const_logic_1 == ap_reg_ppiten_pp1_it0) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_lv1_0 == exitcond2_fu_346_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
                ap_NS_fsm = ap_ST_pp1_stg0_fsm_13;
            end else if ((((ap_const_logic_1 == ap_reg_ppiten_pp1_it2) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) | ((ap_const_logic_1 == ap_reg_ppiten_pp1_it0) & ~(ap_sig_bdd_61 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_lv1_0 == exitcond2_fu_346_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
                ap_NS_fsm = ap_ST_st19_fsm_14;
            end else begin
                ap_NS_fsm = ap_ST_pp1_stg0_fsm_13;
            end
        end
        ap_ST_st19_fsm_14 :
        begin
            ap_NS_fsm = ap_ST_pp2_stg0_fsm_15;
        end
        ap_ST_pp2_stg0_fsm_15 :
        begin
            if ((~((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp2_it1)) & ~((ap_const_logic_1 == ap_reg_ppiten_pp2_it0) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == exitcond3_fu_369_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp2_it1)))) begin
                ap_NS_fsm = ap_ST_pp2_stg0_fsm_15;
            end else if ((((ap_const_logic_1 == ap_reg_ppiten_pp2_it2) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp2_it1)) | ((ap_const_logic_1 == ap_reg_ppiten_pp2_it0) & ~(ap_sig_bdd_98 & (ap_const_logic_1 == ap_reg_ppiten_pp2_it2)) & ~(ap_const_lv1_0 == exitcond3_fu_369_p2) & ~(ap_const_logic_1 == ap_reg_ppiten_pp2_it1)))) begin
                ap_NS_fsm = ap_ST_st23_fsm_16;
            end else begin
                ap_NS_fsm = ap_ST_pp2_stg0_fsm_15;
            end
        end
        ap_ST_st23_fsm_16 :
        begin
            ap_NS_fsm = ap_ST_st1_fsm_0;
        end
        default :
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end


/// ap_rst_n_inv assign process. ///
always @ (ap_rst_n)
begin
    ap_rst_n_inv = ~ap_rst_n;
end

/// ap_sig_bdd_61 assign process. ///
always @ (mem0_rsp_empty_n or exitcond2_reg_467)
begin
    ap_sig_bdd_61 = ((mem0_rsp_empty_n == ap_const_logic_0) & (exitcond2_reg_467 == ap_const_lv1_0));
end

/// ap_sig_bdd_83 assign process. ///
always @ (mem0_req_full_n or ap_reg_ppstg_exitcond4_reg_409_pp0_it1)
begin
    ap_sig_bdd_83 = ((mem0_req_full_n == ap_const_logic_0) & (ap_const_lv1_0 == ap_reg_ppstg_exitcond4_reg_409_pp0_it1));
end

/// ap_sig_bdd_98 assign process. ///
always @ (mem0_req_full_n or ap_reg_ppstg_exitcond3_reg_481_pp2_it1)
begin
    ap_sig_bdd_98 = ((mem0_req_full_n == ap_const_logic_0) & (ap_const_lv1_0 == ap_reg_ppstg_exitcond3_reg_481_pp2_it1));
end
assign exitcond1_fu_231_p2 = (k_reg_151 == ap_const_lv6_20? 1'b1: 1'b0);
assign exitcond2_fu_346_p2 = (indvar8_phi_fu_189_p4 == ap_const_lv6_20? 1'b1: 1'b0);
assign exitcond3_fu_369_p2 = (indvar1_reg_197 == ap_const_lv6_20? 1'b1: 1'b0);
assign exitcond4_fu_269_p2 = (indvar_reg_162 == ap_const_lv6_20? 1'b1: 1'b0);
assign exitcond_fu_298_p2 = (i1_reg_173 == ap_const_lv8_80? 1'b1: 1'b0);
assign i_1_fu_335_p2 = (ap_const_lv8_1 + i1_reg_173);
assign i_2_fu_292_p2 = (i_reg_139 + ap_const_lv8_20);
assign indvar_next1_fu_375_p2 = (indvar1_reg_197 + ap_const_lv6_1);
assign indvar_next9_fu_352_p2 = (indvar8_phi_fu_189_p4 + ap_const_lv6_1);
assign indvar_next_fu_275_p2 = (indvar_reg_162 + ap_const_lv6_1);
assign is_0iter4_fu_386_p2 = (indvar1_reg_197 == ap_const_lv6_0? 1'b1: 1'b0);
assign is_0iter_fu_286_p2 = (indvar_reg_162 == ap_const_lv6_0? 1'b1: 1'b0);
assign k_1_fu_237_p2 = (k_reg_151 + ap_const_lv6_1);
assign k_cast8_fu_227_p1 = k_reg_151;
assign mem0_addr_3_fu_363_p2 = ap_const_lv64_20;
assign result_fu_341_p2 = (data_1_reg_457 + reg_214);
assign tmp_10_fu_259_p1 = i_reg_139;
assign tmp_1_cast_fu_249_p1 = tmp_1_fu_243_p2;
assign tmp_1_fu_243_p2 = (i_reg_139 + k_cast8_fu_227_p1);
assign tmp_2_fu_254_p1 = k_reg_151;
assign tmp_3_fu_358_p1 = ap_reg_ppstg_indvar8_reg_185_pp1_it1;
assign tmp_4_fu_308_p2 = ($signed(ap_const_lv7_7F) + $signed(tmp_8_fu_304_p1));
assign tmp_5_fu_314_p1 = tmp_4_reg_435;
assign tmp_6_fu_324_p1 = i1_reg_173;
assign tmp_7_fu_381_p1 = indvar1_reg_197;
assign tmp_8_fu_304_p1 = i1_reg_173[6:0];
assign tmp_9_fu_281_p1 = indvar_reg_162;
assign tmp_fu_219_p3 = i_reg_139[ap_const_lv32_7];
always @ (posedge ap_clk)
begin
    mem0_addr_2_reg_404[31:8] <= 24'b000000000000000000000000;
    mem0_addr_reg_440[31:7] <= 25'b0000000000000000000000000;
    mem0_addr_3_reg_476[31:0] <= 32'b00000000000000000000000000100000;
end



endmodule //hls_ap_bus_test

