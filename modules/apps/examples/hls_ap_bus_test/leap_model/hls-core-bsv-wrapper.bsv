import Vector::*;

// Internal Verilog HLS-core interface
interface HLS_CORE_INTERNAL_IFC#(numeric type t_AP0_ADDR_SZ,
                                 numeric type t_AP0_DATA_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core apBus port(s)
    method Action mem0ReqNotFull();
    method Action mem0ReadRsp( Bit#(t_AP0_DATA_SZ) resp);
    method Bit#(t_AP0_ADDR_SZ) mem0ReqAddr();
    method Bit#(t_AP0_ADDR_SZ) mem0ReqSize();
    method Bit#(t_AP0_DATA_SZ) mem0WriteData();
    method Bool mem0WriteReqEn();
endinterface

//
// mkHlsCoreInternal --
//     Wrapper for the Verilog HLS core.
//
import "BVI" hls_core_verilog_wrapper = module mkHlsCoreInternal
    // interface:
    (HLS_CORE_INTERNAL_IFC#(t_AP0_ADDR_SZ,
                            t_AP0_DATA_SZ));

    // verilog parameters
    parameter AP0_DATA_WIDTH = valueOf(t_AP0_DATA_SZ);
    parameter AP0_ADDR_WIDTH = valueOf(t_AP0_ADDR_SZ);

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
    // ap bus methods
    method mem0ReqNotFull() enable(mem0_req_full_n);
    method mem0ReadRsp(mem0_datain) enable(mem0_rsp_empty_n);
    method mem0_address mem0ReqAddr() ready(mem0_req_write);
    method mem0_size mem0ReqSize() ready(mem0_req_write);
    method mem0_dataout mem0WriteData() ready(mem0_req_write);
    method mem0_req_din mem0WriteReqEn() ready(mem0_req_write);

    //scheduling
    schedule start C start;
    schedule (isIdle, isDone, isReady) CF (isIdle, isDone, isReady);
    schedule start CF (isIdle, isDone, isReady);

    schedule (start, isIdle, isDone, isReady) CF (mem0ReqNotFull, mem0ReadRsp, mem0ReqAddr, mem0ReqSize, mem0WriteData, mem0WriteReqEn);

    schedule mem0ReqNotFull C mem0ReqNotFull;
    schedule mem0ReqNotFull CF (mem0ReadRsp, mem0ReqAddr, mem0ReqSize, mem0WriteData, mem0WriteReqEn);
    schedule mem0ReadRsp C mem0ReadRsp;
    schedule mem0ReadRsp CF (mem0ReqAddr, mem0ReqSize, mem0WriteData, mem0WriteReqEn);
    schedule (mem0ReqAddr, mem0ReqSize, mem0WriteData, mem0WriteReqEn) CF (mem0ReqAddr, mem0ReqSize, mem0WriteData, mem0WriteReqEn);


endmodule

// HLS-core with memory bus interface
interface HLS_CORE_WITH_MEM_BUS_IFC#(numeric type t_AP0_ADDR_SZ,
                                     numeric type t_AP0_DATA_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core ap bus port(s)
    interface HLS_AP_BUS_IFC#(t_AP0_ADDR_SZ, t_AP0_DATA_SZ) apPort0;
endinterface

//
// mkMultiMemPortHlsCore --
//     Wrapper for the mkHlsCoreInternal module.
//
module [CONNECTED_MODULE] mkMultiMemPortHlsCore
    // interface:
    (HLS_CORE_WITH_MEM_BUS_IFC#(t_AP0_ADDR_SZ,
                                t_AP0_DATA_SZ));

    HLS_CORE_INTERNAL_IFC#(t_AP0_ADDR_SZ,
                           t_AP0_DATA_SZ) core <- mkHlsCoreInternal;

    interface apPort0 =
        interface HLS_AP_BUS_IFC#(t_AP0_ADDR_SZ, t_AP0_DATA_SZ);
            method Action reqNotFull();
                core.mem0ReqNotFull();
            endmethod
            method Action readRsp(Bit#(t_AP0_DATA_SZ) resp);
                core.mem0ReadRsp(resp);
            endmethod
            method Bit#(t_AP0_ADDR_SZ) reqAddr() = core.mem0ReqAddr();
            method Bit#(t_AP0_ADDR_SZ) reqSize() = core.mem0ReqSize();
            method Bit#(t_AP0_DATA_SZ) writeData() = core.mem0WriteData();
            method Bool writeReqEn() = core.mem0WriteReqEn();
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

    HLS_CORE_WITH_MEM_BUS_IFC#(`HLS_AP_BUS0_ADDR_BITS,
                               `HLS_AP_BUS0_DATA_BITS) core <- mkMultiMemPortHlsCore;

    Reg#(Bool) verboseMode <- mkReg(False);

    mkHlsApBusMemConnection(mems[0], core.apPort0, memDataSz, verboseMode, debugLog, 0);

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
