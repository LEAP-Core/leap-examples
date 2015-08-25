// Verilog wrapper for the HLS core

module hls_core_verilog_wrapper
#(
    parameter AP0_DATA_WIDTH = 64,
    parameter AP0_ADDR_WIDTH = 32,
    parameter AP_IN_FIFO0_DATA_WIDTH = 104,
    parameter AP_OUT_FIFO0_DATA_WIDTH = 32
)
(
    input   ap_clk,
    input   ap_rst_n,
    input   ap_start,
    output  ap_done,
    output  ap_idle,
    output  ap_ready,
    input   mem0_V_req_full_n,
    input   mem0_V_rsp_empty_n,
    output  mem0_V_req_write,
    output  mem0_V_req_din,
    output  [AP0_ADDR_WIDTH-1:0] mem0_V_address,
    output  [AP0_ADDR_WIDTH-1:0] mem0_V_size,
    input   [AP0_DATA_WIDTH-1:0] mem0_V_datain,
    output  [AP0_DATA_WIDTH-1:0] mem0_V_dataout,
    input   [AP_IN_FIFO0_DATA_WIDTH-1:0] inst_V_dout,
    input   inst_V_empty_n,
    output  inst_V_read,
    output  [AP_OUT_FIFO0_DATA_WIDTH-1:0] result_din,
    input   result_full_n,
    output  result_write
);


    // ap_bus wires
    wire                        mem0_V_rsp_read;

    hls_mem_perf hls_top (
        .ap_clk (ap_clk),
        .ap_rst_n (ap_rst_n),
        .ap_start (ap_start),
        .ap_done (ap_done),
        .ap_idle (ap_idle),
        .ap_ready (ap_ready),
        .mem0_V_req_din (mem0_V_req_din),
        .mem0_V_req_full_n (mem0_V_req_full_n),
        .mem0_V_req_write (mem0_V_req_write),
        .mem0_V_rsp_empty_n (mem0_V_rsp_empty_n),
        .mem0_V_rsp_read (mem0_V_rsp_read), //not used
        .mem0_V_address (mem0_V_address),
        .mem0_V_datain (mem0_V_datain),
        .mem0_V_dataout (mem0_V_dataout),
        .mem0_V_size (mem0_V_size),
        .inst_V_dout (inst_V_dout),
        .inst_V_empty_n (inst_V_empty_n),
        .inst_V_read (inst_V_read),
        .result_din (result_din),
        .result_full_n (result_full_n),
        .result_write (result_write)
    );

endmodule
