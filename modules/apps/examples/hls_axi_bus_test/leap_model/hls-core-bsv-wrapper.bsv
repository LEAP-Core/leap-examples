import Vector::*;

// Internal Verilog HLS-core interface
interface HLS_CORE_INTERNAL_IFC#(numeric type t_AXI0_ADDR_SZ,
                                 numeric type t_AXI0_DATA_SZ,
                                 numeric type t_AXI0_ID_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core axiBus port(s)
    // hls core axiBus mAxiMem0 write master 
    // Address outputs
    method Bit#(t_AXI0_ID_SZ) mAxiMem0AwId();
    method Bit#(t_AXI0_ADDR_SZ) mAxiMem0AwAddr();
    method Bit#(8) mAxiMem0AwLen();
    method Bit#(3) mAxiMem0AwSize();
    method AXI4BurstMode mAxiMem0AwBurst();
    method Bool mAxiMem0AwValid();
    // Address Inputs
    method Action mAxiMem0AwReady();
    // Data Outputs
    method Bit#(t_AXI0_ID_SZ) mAxiMem0WId();
    method Bit#(t_AXI0_DATA_SZ) mAxiMem0WData();
    method Bit#(TDiv#(t_AXI0_DATA_SZ,8)) mAxiMem0WStrb();
    method Bool mAxiMem0WLast();
    method Bool mAxiMem0WValid();
    // Data Inputs
    method Action mAxiMem0WReady();
    // Response Outputs
    method Bool mAxiMem0BReady();
    // Response Inputs
    method Action mAxiMem0BId( Bit#(t_AXI0_ID_SZ) id );
    method Action mAxiMem0BResp( AXI4Resp resp );
    method Action mAxiMem0BValid();
    // hls core axiBus mAxiMem0 read master 
    // Address outputs
    method Bit#(t_AXI0_ID_SZ) mAxiMem0ArId();
    method Bit#(t_AXI0_ADDR_SZ) mAxiMem0ArAddr();
    method Bit#(8) mAxiMem0ArLen();
    method Bit#(3) mAxiMem0ArSize();
    method AXI4BurstMode mAxiMem0ArBurst();
    method Bool mAxiMem0ArValid();
    // Address Inputs
    method Action mAxiMem0ArReady();
    // Response Outputs
    method Bool mAxiMem0RReady();
    // Response Inputs
    method Action mAxiMem0RId( Bit#(t_AXI0_ID_SZ) id );
    method Action mAxiMem0RData( Bit#(t_AXI0_DATA_SZ) data );
    method Action mAxiMem0RResp( AXI4Resp resp );
    method Action mAxiMem0RLast();
    method Action mAxiMem0RValid();
endinterface

//
// mkHlsCoreInternal --
//     Wrapper for the Verilog HLS core.
//
import "BVI" hls_core_verilog_wrapper = module mkHlsCoreInternal
    // interface:
    (HLS_CORE_INTERNAL_IFC#(t_AXI0_ADDR_SZ,
                            t_AXI0_DATA_SZ,
                            t_AXI0_ID_SZ));

    // verilog parameters
    parameter AXI0_DATA_WIDTH = valueOf(t_AXI0_DATA_SZ);
    parameter AXI0_ADDR_WIDTH = valueOf(t_AXI0_ADDR_SZ);
    parameter AXI0_ID_WIDTH   = valueOf(t_AXI0_ID_SZ);

    // clock and reset
    default_clock clk;
    default_reset rst_RST_N;

    input_clock clk (ap_clk) <- exposeCurrentClock;
    input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;

    // methods
    method start() enable(ap_start);
    method ap_idle  isIdle ();
    method ap_ready isReady ();
    method ap_done  isDone ();
    // axi bus methods
    method m_axi_mem0_AWVALID mAxiMem0AwValid();
    method m_axi_mem0_AWADDR mAxiMem0AwAddr();
    method m_axi_mem0_AWID mAxiMem0AwId();
    method m_axi_mem0_AWLEN mAxiMem0AwLen();
    method m_axi_mem0_AWSIZE mAxiMem0AwSize();
    method m_axi_mem0_AWBURST mAxiMem0AwBurst();
    method mAxiMem0AwReady() enable(m_axi_mem0_AWREADY);
    method m_axi_mem0_WVALID mAxiMem0WValid();
    method m_axi_mem0_WDATA mAxiMem0WData();
    method m_axi_mem0_WID mAxiMem0WId();
    method m_axi_mem0_WSTRB mAxiMem0WStrb();
    method m_axi_mem0_WLAST mAxiMem0WLast();
    method mAxiMem0WReady() enable(m_axi_mem0_WREADY);
    method m_axi_mem0_BREADY mAxiMem0BReady();
    method mAxiMem0BId(m_axi_mem0_BID) enable((*inhigh*) m_axi_mem0EN0);
    method mAxiMem0BResp(m_axi_mem0_BRESP) enable((*inhigh*) m_axi_mem0EN1);
    method mAxiMem0BValid() enable(m_axi_mem0_BVALID);
    method m_axi_mem0_ARVALID mAxiMem0ArValid();
    method m_axi_mem0_ARADDR mAxiMem0ArAddr();
    method m_axi_mem0_ARID mAxiMem0ArId();
    method m_axi_mem0_ARLEN mAxiMem0ArLen();
    method m_axi_mem0_ARSIZE mAxiMem0ArSize();
    method m_axi_mem0_ARBURST mAxiMem0ArBurst();
    method mAxiMem0ArReady() enable(m_axi_mem0_ARREADY);
    method m_axi_mem0_RREADY mAxiMem0RReady();
    method mAxiMem0RId(m_axi_mem0_RID) enable((*inhigh*) m_axi_mem0EN2);
    method mAxiMem0RData(m_axi_mem0_RDATA) enable((*inhigh*) m_axi_mem0EN3);
    method mAxiMem0RResp(m_axi_mem0_RRESP) enable((*inhigh*) m_axi_mem0EN4);
    method mAxiMem0RLast() enable(m_axi_mem0_RLAST);
    method mAxiMem0RValid() enable(m_axi_mem0_RVALID);

    //scheduling
    schedule start C start;
    schedule (isIdle, isDone, isReady) CF (isIdle, isDone, isReady);
    schedule start CF (isIdle, isDone, isReady);

    schedule (start, isIdle, isDone, isReady) CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0AwReady, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0WReady, mAxiMem0BReady, mAxiMem0BId, mAxiMem0BResp, mAxiMem0BValid);
    schedule (start, isIdle, isDone, isReady) CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0ArReady, mAxiMem0RReady, mAxiMem0RId, mAxiMem0RData, mAxiMem0RResp, mAxiMem0RLast, mAxiMem0RValid);
    schedule (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0AwReady, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0WReady, mAxiMem0BReady, mAxiMem0BId, mAxiMem0BResp, mAxiMem0BValid) CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0ArReady, mAxiMem0RReady, mAxiMem0RId, mAxiMem0RData, mAxiMem0RResp, mAxiMem0RLast, mAxiMem0RValid);

    schedule mAxiMem0AwReady C mAxiMem0AwReady;
    schedule mAxiMem0AwReady CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0WReady, mAxiMem0BReady, mAxiMem0BId, mAxiMem0BResp, mAxiMem0BValid);
    schedule mAxiMem0WReady C mAxiMem0WReady;
    schedule mAxiMem0WReady CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady, mAxiMem0BId, mAxiMem0BResp, mAxiMem0BValid);
    schedule mAxiMem0BId C mAxiMem0BId;
    schedule mAxiMem0BId CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady, mAxiMem0BResp, mAxiMem0BValid);
    schedule mAxiMem0BResp C mAxiMem0BResp;
    schedule mAxiMem0BResp CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady, mAxiMem0BValid);
    schedule mAxiMem0BValid C mAxiMem0BValid;
    schedule mAxiMem0BValid CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady);
    schedule (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady) CF (mAxiMem0AwValid, mAxiMem0AwAddr, mAxiMem0AwId, mAxiMem0AwLen, mAxiMem0AwSize, mAxiMem0AwBurst, mAxiMem0WValid, mAxiMem0WData, mAxiMem0WId, mAxiMem0WStrb, mAxiMem0WLast, mAxiMem0BReady);
    schedule mAxiMem0ArReady C mAxiMem0ArReady;
    schedule mAxiMem0ArReady CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady, mAxiMem0RId, mAxiMem0RData, mAxiMem0RResp, mAxiMem0RLast, mAxiMem0RValid);
    schedule mAxiMem0RId C mAxiMem0RId;
    schedule mAxiMem0RId CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady, mAxiMem0RData, mAxiMem0RResp, mAxiMem0RLast, mAxiMem0RValid);
    schedule mAxiMem0RData C mAxiMem0RData;
    schedule mAxiMem0RData CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady, mAxiMem0RResp, mAxiMem0RLast, mAxiMem0RValid);
    schedule mAxiMem0RResp C mAxiMem0RResp;
    schedule mAxiMem0RResp CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady, mAxiMem0RLast, mAxiMem0RValid);
    schedule mAxiMem0RLast C mAxiMem0RLast;
    schedule mAxiMem0RLast CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady, mAxiMem0RValid);
    schedule mAxiMem0RValid C mAxiMem0RValid;
    schedule mAxiMem0RValid CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady);
    schedule (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady) CF (mAxiMem0ArValid, mAxiMem0ArAddr, mAxiMem0ArId, mAxiMem0ArLen, mAxiMem0ArSize, mAxiMem0ArBurst, mAxiMem0RReady);

endmodule

// HLS-core with memory bus interface
interface HLS_CORE_WITH_MEM_BUS_IFC#(numeric type t_AXI0_ADDR_SZ,
                                     numeric type t_AXI0_DATA_SZ,
                                     numeric type t_AXI0_ID_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core axi bus port(s)
    interface HLS_AXI_BUS_IFC#(t_AXI0_ADDR_SZ, t_AXI0_DATA_SZ, t_AXI0_ID_SZ) axiPort0;
endinterface

//
// mkMultiMemPortHlsCore --
//     Wrapper for the mkHlsCoreInternal module.
//
module [CONNECTED_MODULE] mkMultiMemPortHlsCore
    // interface:
    (HLS_CORE_WITH_MEM_BUS_IFC#(t_AXI0_ADDR_SZ,
                                t_AXI0_DATA_SZ,
                                t_AXI0_ID_SZ));

    HLS_CORE_INTERNAL_IFC#(t_AXI0_ADDR_SZ,
                           t_AXI0_DATA_SZ,
                           t_AXI0_ID_SZ) core <- mkHlsCoreInternal;

    interface axiPort0 =
        interface HLS_AXI_BUS_IFC#(t_AXI0_ADDR_SZ, t_AXI0_DATA_SZ, t_AXI0_ID_SZ);
            interface writePort = interface AXI4_WRITE_MASTER#(t_AXI0_ADDR_SZ, t_AXI0_DATA_SZ, t_AXI0_ID_SZ);
                                      method Bit#(t_AXI0_ID_SZ) awId() = core.mAxiMem0AwId();
                                      method Bit#(t_AXI0_ADDR_SZ) awAddr() = core.mAxiMem0AwAddr();
                                      method Bit#(8) awLen() = core.mAxiMem0AwLen();
                                      method Bit#(3) awSize() = core.mAxiMem0AwSize();
                                      method AXI4BurstMode awBurst() = core.mAxiMem0AwBurst();
                                      method Bool awValid() = core.mAxiMem0AwValid();
                                      method Action awReady();
                                          core.mAxiMem0AwReady();
                                      endmethod
                                      method Bit#(t_AXI0_ID_SZ) wId() = core.mAxiMem0WId();
                                      method Bit#(t_AXI0_DATA_SZ) wData() = core.mAxiMem0WData();
                                      method Bit#(TDiv#(t_AXI0_DATA_SZ, 8)) wStrb() = core.mAxiMem0WStrb();
                                      method Bool wLast() = core.mAxiMem0WLast();
                                      method Bool wValid() = core.mAxiMem0WValid();
                                      method Action wReady() = core.mAxiMem0WReady();
                                      method Bool bReady() = core.mAxiMem0BReady();
                                      method Action bId(Bit#(t_AXI0_ID_SZ) id);
                                          core.mAxiMem0BId(id);
                                      endmethod
                                      method Action bResp(AXI4Resp resp);
                                          core.mAxiMem0BResp(resp);
                                      endmethod
                                      method Action bValid();
                                          core.mAxiMem0BValid();
                                      endmethod
                                  endinterface;
            interface readPort = interface AXI4_READ_MASTER#(t_AXI0_ADDR_SZ, t_AXI0_DATA_SZ, t_AXI0_ID_SZ);
                                     method Bit#(t_AXI0_ID_SZ) arId() = core.mAxiMem0ArId();
                                     method Bit#(t_AXI0_ADDR_SZ) arAddr() = core.mAxiMem0ArAddr();
                                     method Bit#(8) arLen() = core.mAxiMem0ArLen();
                                     method Bit#(3) arSize() = core.mAxiMem0ArSize();
                                     method AXI4BurstMode arBurst() = core.mAxiMem0ArBurst();
                                     method Bool arValid() = core.mAxiMem0ArValid();
                                     method Action arReady();
                                         core.mAxiMem0ArReady();
                                     endmethod
                                     method Bool rReady() = core.mAxiMem0RReady();
                                     method Action rId(Bit#(t_AXI0_ID_SZ) id);
                                         core.mAxiMem0RId(id);
                                     endmethod
                                     method Action rData(Bit#(t_AXI0_DATA_SZ) data);
                                         core.mAxiMem0RData(data);
                                     endmethod
                                     method Action rResp(AXI4Resp resp);
                                         core.mAxiMem0RResp(resp);
                                     endmethod
                                     method Action rLast();
                                         core.mAxiMem0RLast();
                                     endmethod
                                     method Action rValid();
                                         core.mAxiMem0RValid();
                                     endmethod
                                 endinterface;
        endinterface;

    method Action start();
        core.start();
    endmethod
    method Bool isIdle() = core.isIdle();
    method Bool isDone() = core.isDone();
    method Bool isReady() = core.isReady();

endmodule

//

// mkHlsCore --
//     Connect the mkMultiMemPortHlsCore module with LEAP Memory. Memory is 
// passed in as an argument.
//
module [CONNECTED_MODULE] mkHlsCore#(Vector#(n_MEMORIES, MEMORY_IFC#(t_MEM_ADDR, t_MEM_DATA)) mems,
                                     NumTypeParam#(t_MEM_DATA_SZ) memDataSz,
                                     DEBUG_FILE debugLog)
    // interface:
    (HLS_CORE_IFC)
    provisos (Bits#(t_MEM_ADDR, t_MEM_ADDR_SZ),
              Alias#(Bit#(t_MEM_DATA_SZ), t_MEM_DATA),
              NumAlias#(`HLS_AP_BUS_NUM, n_AP_BUS),
              NumAlias#(`HLS_AXI_BUS_NUM, n_AXI_BUS),
              Add#(n_AP_BUS, n_AXI_BUS, n_MEMORIES));

    HLS_CORE_WITH_MEM_BUS_IFC#(`HLS_AXI_BUS0_ADDR_BITS,
                               `HLS_AXI_BUS0_DATA_BITS,
                               `HLS_AXI_BUS0_ID_BITS) core <- mkMultiMemPortHlsCore;

    Reg#(Bool) verboseMode <- mkReg(False);

    mkHlsAxi4BusMemConnection(mems[0], core.axiPort0, memDataSz, verboseMode._read(), debugLog, 0);

    // =======================================================================
    //
    // Methods
    //
    // =======================================================================
    method Action start();
        core.start();
        debugLog.record($format("hlsCore: start..."));
    endmethod
    method Bool isIdle() = core.isIdle();
    method Bool isDone() = core.isDone();
    method Bool isReady() = core.isReady();
    method Action setVerboseMode(Bool verbose);
        verboseMode <= verbose; 
    endmethod

endmodule
