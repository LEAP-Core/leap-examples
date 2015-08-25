// Verilog wrapper for the HLS core

module hls_core_verilog_wrapper
#(
    parameter AXI0_DATA_WIDTH = 32,
    parameter AXI0_ADDR_WIDTH = 32,
    parameter AXI0_ID_WIDTH = 1
)
(
    input   ap_clk,
    input   ap_rst_n,
    input   ap_start,
    output  ap_done,
    output  ap_idle,
    output  ap_ready,
    output  m_axi_mem0_AWVALID,
    input   m_axi_mem0_AWREADY,
    output  [AXI0_ADDR_WIDTH-1:0] m_axi_mem0_AWADDR,
    output  [AXI0_ID_WIDTH-1:0]   m_axi_mem0_AWID,
    output  [7:0]  m_axi_mem0_AWLEN,
    output  [2:0]  m_axi_mem0_AWSIZE,
    output  [1:0]  m_axi_mem0_AWBURST,
    output  m_axi_mem0_WVALID,
    input   m_axi_mem0_WREADY,
    output  [AXI0_DATA_WIDTH-1:0] m_axi_mem0_WDATA,
    output  [3:0]  m_axi_mem0_WSTRB,
    output  m_axi_mem0_WLAST,
    output  [AXI0_ID_WIDTH-1:0]   m_axi_mem0_WID,
    output  m_axi_mem0_ARVALID,
    input   m_axi_mem0_ARREADY,
    output  [AXI0_ADDR_WIDTH-1:0] m_axi_mem0_ARADDR,
    output  [AXI0_ID_WIDTH-1:0]   m_axi_mem0_ARID,
    output  [7:0]  m_axi_mem0_ARLEN,
    output  [2:0]  m_axi_mem0_ARSIZE,
    output  [1:0]  m_axi_mem0_ARBURST,
    input   m_axi_mem0_RVALID,
    output  m_axi_mem0_RREADY,
    input   [AXI0_DATA_WIDTH-1:0] m_axi_mem0_RDATA,
    input   m_axi_mem0_RLAST,
    input   [AXI0_ID_WIDTH-1:0]  m_axi_mem0_RID,
    input   [1:0]  m_axi_mem0_RRESP,
    input   m_axi_mem0_BVALID,
    output  m_axi_mem0_BREADY,
    input   [1:0]  m_axi_mem0_BRESP,
    input   [AXI0_ID_WIDTH-1:0]  m_axi_mem0_BID
);


    // axi4 bus wires
    wire  [1:0] m_axi_mem0_AWLOCK;
    wire  [3:0] m_axi_mem0_AWCACHE;
    wire  [2:0] m_axi_mem0_AWPROT;
    wire  [3:0] m_axi_mem0_AWREGION;
    wire        m_axi_mem0_AWUSER;
    wire  [1:0] m_axi_mem0_ARLOCK;
    wire  [3:0] m_axi_mem0_ARCACHE;
    wire  [2:0] m_axi_mem0_ARPROT;
    wire  [3:0] m_axi_mem0_ARQOS;
    wire  [3:0] m_axi_mem0_ARREGION;
    wire        m_axi_mem0_ARUSER;

    hls_axi_bus_test hls_top (
        .ap_clk (ap_clk),
        .ap_rst_n (ap_rst_n),
        .ap_start (ap_start),
        .ap_done (ap_done),
        .ap_idle (ap_idle),
        .ap_ready (ap_ready),
        .m_axi_mem0_AWADDR (m_axi_mem0_AWADDR),
        .m_axi_mem0_AWREADY (m_axi_mem0_AWREADY),
        .m_axi_mem0_AWVALID (m_axi_mem0_AWVALID),
        .m_axi_mem0_AWID (m_axi_mem0_AWID),
        .m_axi_mem0_AWLEN (m_axi_mem0_AWLEN),
        .m_axi_mem0_AWSIZE (m_axi_mem0_AWSIZE),
        .m_axi_mem0_AWBURST (m_axi_mem0_AWBURST),
        .m_axi_mem0_AWLOCK (m_axi_mem0_AWLOCK), //not used
        .m_axi_mem0_AWCACHE (m_axi_mem0_AWCACHE), //not used
        .m_axi_mem0_AWPROT (m_axi_mem0_AWPROT), //not used
        .m_axi_mem0_AWQOS (m_axi_mem0_AWQOS),
        .m_axi_mem0_AWREGION (m_axi_mem0_AWREGION), //not used
        .m_axi_mem0_AWUSER (m_axi_mem0_AWUSER), //not used
        .m_axi_mem0_WVALID (m_axi_mem0_WVALID),
        .m_axi_mem0_WREADY (m_axi_mem0_WREADY),
        .m_axi_mem0_WDATA (m_axi_mem0_WDATA),
        .m_axi_mem0_WSTRB (m_axi_mem0_WSTRB),
        .m_axi_mem0_WLAST (m_axi_mem0_WLAST),
        .m_axi_mem0_WID (m_axi_mem0_WID),
        .m_axi_mem0_WUSER (m_axi_mem0_WUSER),
        .m_axi_mem0_ARVALID (m_axi_mem0_ARVALID),
        .m_axi_mem0_ARREADY (m_axi_mem0_ARREADY),
        .m_axi_mem0_ARADDR (m_axi_mem0_ARADDR),
        .m_axi_mem0_ARID (m_axi_mem0_ARID),
        .m_axi_mem0_ARLEN (m_axi_mem0_ARLEN),
        .m_axi_mem0_ARSIZE (m_axi_mem0_ARSIZE),
        .m_axi_mem0_ARBURST (m_axi_mem0_ARBURST),
        .m_axi_mem0_ARLOCK (m_axi_mem0_ARLOCK), //not used
        .m_axi_mem0_ARCACHE (m_axi_mem0_ARCACHE), //not used
        .m_axi_mem0_ARPROT (m_axi_mem0_ARPROT), //not used
        .m_axi_mem0_ARQOS (m_axi_mem0_ARQOS), //not used
        .m_axi_mem0_ARREGION (m_axi_mem0_ARREGION), //not used
        .m_axi_mem0_ARUSER (m_axi_mem0_ARUSER), //not used
        .m_axi_mem0_RVALID (m_axi_mem0_RVALID),
        .m_axi_mem0_RREADY (m_axi_mem0_RREADY),
        .m_axi_mem0_RDATA (m_axi_mem0_RDATA),
        .m_axi_mem0_RLAST (m_axi_mem0_RLAST),
        .m_axi_mem0_RID (m_axi_mem0_RID),
        .m_axi_mem0_RUSER (m_axi_mem0_RUSER),
        .m_axi_mem0_RRESP (m_axi_mem0_RRESP),
        .m_axi_mem0_BVALID (m_axi_mem0_BVALID),
        .m_axi_mem0_BREADY (m_axi_mem0_BREADY),
        .m_axi_mem0_BRESP (m_axi_mem0_BRESP),
        .m_axi_mem0_BID (m_axi_mem0_BID),
        .m_axi_mem0_BUSER (1'b0) //not used
    );

endmodule
