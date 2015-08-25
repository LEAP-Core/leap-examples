// Verilog wrapper for the HLS core

module hls_core_verilog_wrapper
#(
    parameter AP0_DATA_WIDTH = 32,
    parameter AP0_ADDR_WIDTH = 32
)
(
    input   ap_clk,
    input   ap_rst_n,
    input   ap_start,
    output  ap_done,
    output  ap_idle,
    output  ap_ready,
    input   mem0_req_full_n,
    input   mem0_rsp_empty_n,
    output  mem0_req_write,
    output  mem0_req_din,
    output  [AP0_ADDR_WIDTH-1:0] mem0_address,
    output  [AP0_ADDR_WIDTH-1:0] mem0_size,
    input   [AP0_DATA_WIDTH-1:0] mem0_datain,
    output  [AP0_DATA_WIDTH-1:0] mem0_dataout
);


    // ap_bus wires
    wire                        mem0_rsp_read;

    hls_ap_bus_test hls_top (
        .ap_clk (ap_clk),
        .ap_rst_n (ap_rst_n),
        .ap_start (ap_start),
        .ap_done (ap_done),
        .ap_idle (ap_idle),
        .ap_ready (ap_ready),
        .mem0_req_din (mem0_req_din),
        .mem0_req_full_n (mem0_req_full_n),
        .mem0_req_write (mem0_req_write),
        .mem0_rsp_empty_n (mem0_rsp_empty_n),
        .mem0_rsp_read (mem0_rsp_read), //not used
        .mem0_address (mem0_address),
        .mem0_datain (mem0_datain),
        .mem0_dataout (mem0_dataout),
        .mem0_size (mem0_size)
    );

endmodule
