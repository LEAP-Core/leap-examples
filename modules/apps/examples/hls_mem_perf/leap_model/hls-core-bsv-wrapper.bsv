import Vector::*;

// Internal Verilog HLS-core interface
interface HLS_CORE_INTERNAL_IFC#(numeric type t_AP0_ADDR_SZ,
                                 numeric type t_AP0_DATA_SZ,
                                 numeric type t_AP_IN_FIFO0_DATA_SZ,
                                 numeric type t_AP_OUT_FIFO0_DATA_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core apBus port(s)
    method Action mem0VReqNotFull();
    method Action mem0VReadRsp( Bit#(t_AP0_DATA_SZ) resp);
    method Bit#(t_AP0_ADDR_SZ) mem0VReqAddr();
    method Bit#(t_AP0_ADDR_SZ) mem0VReqSize();
    method Bit#(t_AP0_DATA_SZ) mem0VWriteData();
    method Bool mem0VWriteReqEn();
    // hls core input ap_fifo port(s)
    method Action instVInputMsg (Bit#(t_AP_IN_FIFO0_DATA_SZ) msg);
    method Bool instVMsgReceived();
    // hls core output ap_fifo port(s)
    method Action resultNotFull();
    method Bit#(t_AP_OUT_FIFO0_DATA_SZ) resultOutputMsg();
endinterface

//
// mkHlsCoreInternal --
//     Wrapper for the Verilog HLS core.
//
import "BVI" hls_core_verilog_wrapper = module mkHlsCoreInternal
    // interface:
    (HLS_CORE_INTERNAL_IFC#(t_AP0_ADDR_SZ,
                            t_AP0_DATA_SZ,
                            t_AP_IN_FIFO0_DATA_SZ,
                            t_AP_OUT_FIFO0_DATA_SZ));

    // verilog parameters
    parameter AP0_DATA_WIDTH = valueOf(t_AP0_DATA_SZ);
    parameter AP0_ADDR_WIDTH = valueOf(t_AP0_ADDR_SZ);
    parameter AP_IN_FIFO0_DATA_WIDTH = valueOf(t_AP_IN_FIFO0_DATA_SZ);
    parameter AP_OUT_FIFO0_DATA_WIDTH = valueOf(t_AP_OUT_FIFO0_DATA_SZ);

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
    method mem0VReqNotFull() enable(mem0_V_req_full_n);
    method mem0VReadRsp(mem0_V_datain) enable(mem0_V_rsp_empty_n);
    method mem0_V_address mem0VReqAddr() ready(mem0_V_req_write);
    method mem0_V_size mem0VReqSize() ready(mem0_V_req_write);
    method mem0_V_dataout mem0VWriteData() ready(mem0_V_req_write);
    method mem0_V_req_din mem0VWriteReqEn() ready(mem0_V_req_write);
    // ap input fifo methods
    method instVInputMsg(inst_V_dout) enable(inst_V_empty_n);
    method inst_V_read instVMsgReceived();
    // ap output fifo methods
    method resultNotFull() enable(result_full_n);
    method result_din resultOutputMsg() ready(result_write);

    //scheduling
    schedule start C start;
    schedule (isIdle, isDone, isReady) CF (isIdle, isDone, isReady);
    schedule start CF (isIdle, isDone, isReady);

    schedule (start, isIdle, isDone, isReady) CF (mem0VReqNotFull, mem0VReadRsp, mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn);
    schedule (start, isIdle, isDone, isReady) CF (instVInputMsg, instVMsgReceived);
    schedule (start, isIdle, isDone, isReady) CF (resultOutputMsg, resultNotFull);
    schedule (mem0VReqNotFull, mem0VReadRsp, mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn) CF (instVInputMsg, instVMsgReceived);
    schedule (mem0VReqNotFull, mem0VReadRsp, mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn) CF (resultOutputMsg, resultNotFull);
    schedule (instVInputMsg, instVMsgReceived) CF (resultOutputMsg, resultNotFull);

    schedule mem0VReqNotFull C mem0VReqNotFull;
    schedule mem0VReqNotFull CF (mem0VReadRsp, mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn);
    schedule mem0VReadRsp C mem0VReadRsp;
    schedule mem0VReadRsp CF (mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn);
    schedule (mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn) CF (mem0VReqAddr, mem0VReqSize, mem0VWriteData, mem0VWriteReqEn);

    schedule instVInputMsg C instVInputMsg;
    schedule instVMsgReceived CF (instVInputMsg, instVMsgReceived);
    schedule resultNotFull C resultNotFull;
    schedule resultOutputMsg CF (resultNotFull, resultOutputMsg);

endmodule

// HLS-core with memory bus interface
interface HLS_CORE_WITH_MEM_BUS_IFC#(numeric type t_AP0_ADDR_SZ,
                                     numeric type t_AP0_DATA_SZ,
                                     numeric type t_AP_IN_FIFO0_DATA_SZ,
                                     numeric type t_AP_OUT_FIFO0_DATA_SZ);
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    // hls core ap bus port(s)
    interface HLS_AP_BUS_IFC#(t_AP0_ADDR_SZ, t_AP0_DATA_SZ) apPort0;
    // hls core input ap fifo port(s)
    interface HLS_AP_IN_FIFO_IFC#(t_AP_IN_FIFO0_DATA_SZ) apInFifoPort0;
    // hls core output ap fifo port(s)
    interface HLS_AP_OUT_FIFO_IFC#(t_AP_OUT_FIFO0_DATA_SZ) apOutFifoPort0;
endinterface

//
// mkMultiMemPortHlsCore --
//     Wrapper for the mkHlsCoreInternal module.
//
module [CONNECTED_MODULE] mkMultiMemPortHlsCore
    // interface:
    (HLS_CORE_WITH_MEM_BUS_IFC#(t_AP0_ADDR_SZ,
                                t_AP0_DATA_SZ,
                                t_AP_IN_FIFO0_DATA_SZ,
                                t_AP_OUT_FIFO0_DATA_SZ));

    HLS_CORE_INTERNAL_IFC#(t_AP0_ADDR_SZ,
                           t_AP0_DATA_SZ,
                           t_AP_IN_FIFO0_DATA_SZ,
                           t_AP_OUT_FIFO0_DATA_SZ) core <- mkHlsCoreInternal;

    interface apPort0 =
        interface HLS_AP_BUS_IFC#(t_AP0_ADDR_SZ, t_AP0_DATA_SZ);
            method Action reqNotFull();
                core.mem0VReqNotFull();
            endmethod
            method Action readRsp(Bit#(t_AP0_DATA_SZ) resp);
                core.mem0VReadRsp(resp);
            endmethod
            method Bit#(t_AP0_ADDR_SZ) reqAddr() = core.mem0VReqAddr();
            method Bit#(t_AP0_ADDR_SZ) reqSize() = core.mem0VReqSize();
            method Bit#(t_AP0_DATA_SZ) writeData() = core.mem0VWriteData();
            method Bool writeReqEn() = core.mem0VWriteReqEn();
        endinterface;

    interface apInFifoPort0 =
        interface HLS_AP_IN_FIFO_IFC#(t_AP_IN_FIFO0_DATA_SZ);
            method Action inputMsg(Bit#(t_AP_IN_FIFO0_DATA_SZ) msg);
                core.instVInputMsg(msg);
            endmethod
            method Bool msgReceived() = core.instVMsgReceived();
        endinterface;

    interface apOutFifoPort0 =
        interface HLS_AP_OUT_FIFO_IFC#(t_AP_OUT_FIFO0_DATA_SZ);
            method Action notFull();
                core.resultNotFull();
            endmethod
            method Bit#(t_AP_OUT_FIFO0_DATA_SZ) outputMsg() = core.resultOutputMsg();
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
                               `HLS_AP_BUS0_DATA_BITS,
                               `HLS_AP_IN_FIFO0_DATA_BITS,
                               `HLS_AP_OUT_FIFO0_DATA_BITS) core <- mkMultiMemPortHlsCore;

    Reg#(Bool) verboseMode <- mkReg(False);

    mkHlsApBusMemConnection(mems[0], core.apPort0, memDataSz, verboseMode, debugLog, 0);
    mkHlsApInFifoConnection(core.apInFifoPort0, "inst_V", debugLog);
    mkHlsApOutFifoConnection(core.apOutFifoPort0, "result", debugLog);

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
