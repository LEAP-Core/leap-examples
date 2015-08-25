//
// Copyright (c) 2014, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//



import Vector::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import FIFOLevel::*;

`include "awb/provides/librl_bsv_base.bsh"


interface HLS_CORE_IFC;
    // hls core control methods
    method Action start();
    method Bool isIdle();
    method Bool isDone();
    method Bool isReady();
    method Action setVerboseMode(Bool verbose);
endinterface

interface HLS_AP_BUS_IFC#(numeric type t_ADDR_SZ, numeric type t_DATA_SZ);
    method Action reqNotFull();
    method Action readRsp( Bit#(t_DATA_SZ) resp);
    method Bit#(t_ADDR_SZ) reqAddr();
    method Bit#(t_ADDR_SZ) reqSize();
    method Bit#(t_DATA_SZ) writeData();
    method Bool writeReqEn();
endinterface

interface HLS_AP_IN_FIFO_IFC#(numeric type t_DATA_SZ);
    method Action inputMsg( Bit#(t_DATA_SZ) msg);
    method Bool msgReceived();
endinterface

interface HLS_AP_OUT_FIFO_IFC#(numeric type t_DATA_SZ);
    method Action notFull();
    method Bit#(t_DATA_SZ) outputMsg();
endinterface

//
// Simple AXI4 Bus Protocol Definitions
//

typedef enum {FIXED, INCR, WRAP}  AXI4BurstMode deriving(Bounded, Bits, Eq);
typedef enum {OKAY, EXOKAY, SLVERR, DECERR} AXI4Resp deriving(Bounded, Bits, Eq);

typedef struct 
{
    Bit#(t_ID_SZ)   id;
    Bit#(8)         len;
    Bit#(3)         size;
    AXI4BurstMode   burst;
    Bit#(t_ADDR_SZ) addr;
} 
AXI4_ADDR_CMD#(numeric type t_ID_SZ, numeric type t_ADDR_SZ) 
    deriving(Bits,Eq);

typedef struct 
{
    Bit#(t_ID_SZ)            id;
    Bit#(t_DATA_SZ)          data;
    Bit#(TDiv#(t_DATA_SZ,8)) strb;
    Bool                     last;
} 
AXI4_WRITE_DATA#(numeric type t_ID_SZ, numeric type t_DATA_SZ) 
    deriving(Bits,Eq);

typedef struct 
{
    Bit#(t_ID_SZ)   id;
    Bit#(t_DATA_SZ) data;
    AXI4Resp        resp;
    Bool            last;
} 
AXI4_READ_RESP#(numeric type t_ID_SZ, numeric type t_DATA_SZ) 
    deriving(Bits,Eq);

typedef struct 
{
    Bit#(t_ID_SZ)   id;
    AXI4Resp        resp;
} 
AXI4_WRITE_RESP#(numeric type t_ID_SZ)
    deriving(Bits,Eq);


interface AXI4_READ_MASTER#(numeric type t_ADDR_SZ, numeric type t_DATA_SZ, numeric type t_ID_SZ);
    // Address Outputs
    method Bit#(t_ID_SZ) arId();
    method Bit#(t_ADDR_SZ) arAddr();
    method Bit#(8) arLen();
    method Bit#(3) arSize();
    method AXI4BurstMode arBurst();
    method Bool arValid();
    // Address Inputs
    method Action arReady();
    // Response Outputs
    method Bool rReady();
    // Response Inputs
    method Action rId(Bit#(t_ID_SZ) id);
    method Action rData(Bit#(t_DATA_SZ) data);
    method Action rResp(AXI4Resp resp);
    method Action rLast();
    method Action rValid();
endinterface

interface AXI4_WRITE_MASTER#(numeric type t_ADDR_SZ, numeric type t_DATA_SZ, numeric type t_ID_SZ);
    // Address Outputs
    method Bit#(t_ID_SZ) awId();
    method Bit#(t_ADDR_SZ) awAddr();
    method Bit#(8) awLen();
    method Bit#(3) awSize();
    method AXI4BurstMode awBurst();
    method Bool awValid();
    // Address Inputs
    method Action awReady();
    // Write Data Outputs
    method Bit#(t_ID_SZ) wId();
    method Bit#(t_DATA_SZ) wData();
    method Bit#(TDiv#(t_DATA_SZ, 8)) wStrb();
    method Bool wLast();
    method Bool wValid();
    // Write Data Inputs
    method Action wReady();
    // Response Outputs
    method Bool bReady();
    // Response Inputs
    method Action bId(Bit#(t_ID_SZ) id);
    method Action bResp(AXI4Resp resp);
    method Action bValid();
endinterface

interface HLS_AXI_BUS_IFC#(numeric type t_ADDR_SZ, numeric type t_DATA_SZ, numeric type t_ID_SZ);
    interface AXI4_READ_MASTER#(t_ADDR_SZ, t_DATA_SZ, t_ID_SZ) readPort;
    interface AXI4_WRITE_MASTER#(t_ADDR_SZ, t_DATA_SZ, t_ID_SZ) writePort;
endinterface

//
// Wrap mkMemIfcToPseudoMultiMemSyncWrites to handle the case where there is
// only one reader
//

module mkMemIfcToPseudoMultiMemSyncWritesWrapper#(MEMORY_IFC#(t_ADDR, t_DATA) mem)
    // interface:
    (MEMORY_MULTI_READ_IFC#(n_READERS, t_ADDR, t_DATA))
    provisos (Bits#(t_ADDR, t_ADDR_SZ),
              Bits#(t_DATA, t_DATA_SZ),
              Log#(n_READERS, n_READERS_SZ));

   MEMORY_MULTI_READ_IFC#(n_READERS, t_ADDR, t_DATA) multiMem;
   if (valueOf(n_READERS) == 1)
   begin
       MEMORY_MULTI_READ_IFC#(1, t_ADDR, t_DATA) multiMemWithSingleReader <- mkMemIfcToMultiMemIfc(mem);
       multiMem <- mkMultiMemSingleReaderIfcToMultiMemIfc(multiMemWithSingleReader);
       return multiMem;
   end
   else
   begin
       multiMem <- mkMemIfcToPseudoMultiMemSyncWrites(mem);
       return multiMem;
   end
endmodule

module mkMultiMemSingleReaderIfcToMultiMemIfc#(MEMORY_MULTI_READ_IFC#(1, t_ADDR, t_DATA) mem)
    // interface:
    (MEMORY_MULTI_READ_IFC#(n_READERS, t_ADDR, t_DATA))
    provisos (Bits#(t_ADDR, t_ADDR_SZ),
              Bits#(t_DATA, t_DATA_SZ));

    Vector#(n_READERS, MEMORY_READER_IFC#(t_ADDR, t_DATA)) portsLocal = newVector();
    portsLocal[0] =
        interface MEMORY_READER_IFC#(t_ADDR, t_DATA);
            method Action readReq(t_ADDR addr) = mem.readPorts[0].readReq(addr);

            method ActionValue#(t_DATA) readRsp();
                let v <- mem.readPorts[0].readRsp();
                return v;
            endmethod

            method t_DATA peek() = mem.readPorts[0].peek();
            method Bool notEmpty() = mem.readPorts[0].notEmpty();
            method Bool notFull() = mem.readPorts[0].notFull();
        endinterface;

    interface readPorts = portsLocal;

    method Action write(t_ADDR addr, t_DATA val) = mem.write(addr, val);
    method Bool writeNotFull() = mem.writeNotFull();
endmodule

//
// mkHlsApBusMemConnection --
//     Connect the HLS ap Bus interface with LEAP memory interface.
//
module [CONNECTED_MODULE] mkHlsApBusMemConnection#(MEMORY_IFC#(t_MEM_ADDR, t_MEM_DATA) mem, 
                                                   HLS_AP_BUS_IFC#(t_AP_ADDR_SZ, t_AP_DATA_SZ) bus, 
                                                   NumTypeParam#(t_MEM_DATA_SZ) containerDataSz, 
                                                   Bool verbose, 
                                                   DEBUG_FILE debugLog, 
                                                   Integer busId)
    // interface:
    ()
    provisos (Bits#(t_MEM_ADDR, t_MEM_ADDR_SZ),
              Alias#(Bit#(t_MEM_DATA_SZ), t_MEM_DATA),
              NumAlias#(MEM_PACK_CONTAINER_READ_PORTS#(1, t_AP_DATA_SZ, t_MEM_DATA_SZ), n_MEM_READERS),
              NumAlias#(TSub#(TAdd#(t_MEM_ADDR_SZ, MEM_PACK_SMALLER_OBJ_IDX_SZ#(t_AP_DATA_SZ, t_MEM_DATA_SZ)),
                              MEM_PACK_LARGER_OBJ_IDX_SZ#(t_AP_DATA_SZ, t_MEM_DATA_SZ)), t_USER_ADDR_SZ),
              Alias#(Bit#(t_USER_ADDR_SZ), t_USER_ADDR),
              Alias#(Bit#(t_AP_ADDR_SZ), t_AP_ADDR),
              Alias#(Bit#(t_AP_DATA_SZ), t_AP_DATA));

    FIFOLevelIfc#(Tuple3#(t_USER_ADDR, t_USER_ADDR, Bool), 16) reqQ <- mkFIFOLevel();
    FIFOF#(t_AP_DATA) writeDataQ <- mkSizedFIFOF(8);
    Reg#(Bool) busWriteBurstPending <- mkReg(False);
    Reg#(t_AP_ADDR) burstSize <- mkReg(unpack(0));
    Reg#(t_AP_ADDR) writeDataNum <- mkReg(unpack(0));
    
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
    STDIO#(Bit#(64)) stdio <- mkStdIO();
    let msgRead   <- getGlobalStringUID("apBusMemRead: port=%0d, addr=0x%x\n");
    let msgWrite  <- getGlobalStringUID("apBusMemWrite: port=%0d, addr=0x%x, data=0x%x\n");
`endif

    // get memory request from bus
    rule getReadReq (!bus.writeReqEn);
        reqQ.enq(tuple3(resize(bus.reqAddr), resize(bus.reqSize), False));
        debugLog.record($format("apBusGetReadReq: port=%0d, addr=0x%x, size=0x%x", busId, bus.reqAddr, bus.reqSize));
    endrule
    rule getWriteReq (bus.writeReqEn && !busWriteBurstPending);
        reqQ.enq(tuple3(resize(bus.reqAddr), resize(bus.reqSize), True));
        writeDataQ.enq(bus.writeData);
        debugLog.record($format("apBusGetWriteReq: port=%0d, addr=0x%x, size=0x%x, data=0x%x", busId, bus.reqAddr, bus.reqSize, bus.writeData));
        if (pack(bus.reqSize) > 1)
        begin
            busWriteBurstPending <= True;
            burstSize <= bus.reqSize;
            writeDataNum <= 1;
        end
    endrule
    rule getWriteBurstPendingData (bus.writeReqEn && busWriteBurstPending);
        writeDataQ.enq(bus.writeData);
        debugLog.record($format("apBusGetWriteBurstPending: port=%0d, data=0x%x", busId, bus.writeData));
        if (writeDataNum == (burstSize-1) )
        begin
            busWriteBurstPending <= False;
        end
        else
        begin
            writeDataNum <= writeDataNum+1;
        end
    endrule
    
    (* fire_when_enabled *)
    rule checkReqFull (reqQ.isLessThan(8) && writeDataQ.notFull);
        bus.reqNotFull();
    endrule

    // forward request to memory
    Reg#(Bool) reqPending <- mkReg(False);
    Reg#(t_USER_ADDR) memBurstNum <- mkReg(unpack(0));
   
    //
    // May need additional read port(s) to handle data items 
    // that have different sizes from the underlying scratchpad data size
    //
    // Use mkMemIfcToPseudoMultiMemSyncWrites to create the illusion of 
    // multiple read ports by multiplexing all requests on a single physical 
    // read port.  
    // 
    MEMORY_MULTI_READ_IFC#(n_MEM_READERS, t_MEM_ADDR, t_MEM_DATA) multiPortMem <- 
        mkMemIfcToPseudoMultiMemSyncWritesWrapper(mem);
    // MEMORY_MULTI_READ_IFC#(n_MEM_READERS, t_MEM_ADDR, t_MEM_DATA) multiPortMem;
    // if (valueOf(n_MEM_READERS) == 1) 
    // begin
    //     multiPortMem <- mkMemIfcToMultiMemIfc(mem);
    // end
    // else
    // begin
    //     multiPortMem <- mkMemIfcToPseudoMultiMemSyncWrites(mem);
    // end

    MEMORY_MULTI_READ_IFC#(1, t_USER_ADDR, t_AP_DATA) pack_mem_multi;
    MEMORY_IFC#(t_USER_ADDR, t_AP_DATA) pack_mem;
    if (valueOf(t_USER_ADDR_SZ) == valueOf(t_MEM_ADDR_SZ))
    begin
        // One object per container
        pack_mem_multi <- mkMemPack1To1(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end
    else if (valueOf(t_USER_ADDR_SZ) > valueOf(t_MEM_ADDR_SZ))
    begin
        // Multiple objects per container
        // pack_mem <- mkMultiMemIfcToMemIfc(mkMemPackManyTo1(containerDataSz, multiPortMem));
        pack_mem_multi <- mkMemPackManyTo1(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end
    else
    begin
        // Object bigger than one container.  Use multiple containers for
        // each object.
        // pack_mem <- mkMultiMemIfcToMemIfc(mkMemPack1ToMany(containerDataSz, multiPortMem));
        pack_mem_multi <- mkMemPack1ToMany(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end
    
    rule processNewReadReq (!tpl_3(reqQ.first()) && !reqPending);
        match {.addr, .size, .is_write} = reqQ.first();
        pack_mem.readReq(addr);
        debugLog.record($format("apBusMemRead: port=%0d, addr=0x%x", busId, addr));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdio.printf(msgRead, list2(fromInteger(busId), zeroExtendNP(pack(addr))));
        end
`endif
        if (pack(size) > 1)
        begin
            reqPending <= True;
            memBurstNum <= unpack(1);
        end
        else
        begin
            reqQ.deq();
        end
    endrule
    
    rule processPendingReadReq (!tpl_3(reqQ.first()) && reqPending);
        match {.addr, .size, .is_write} = reqQ.first();
        t_USER_ADDR mem_addr = unpack(pack(addr) + pack(memBurstNum));
        pack_mem.readReq(mem_addr);
        debugLog.record($format("apBusMemBurstRead: port=%0d, addr=0x%x", busId, mem_addr));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdio.printf(msgRead, list2(fromInteger(busId), zeroExtendNP(pack(mem_addr))));
        end
`endif
        if (pack(memBurstNum) == (pack(size)-1) )
        begin
            reqPending <= False;
            reqQ.deq();
        end
        else
        begin
            memBurstNum <= unpack(pack(memBurstNum)+1);
        end
    endrule

    rule processNewWriteReq (tpl_3(reqQ.first()) && !reqPending);
        match {.addr, .size, .is_write} = reqQ.first();
        let data = writeDataQ.first();
        writeDataQ.deq();
        pack_mem.write(addr, data);
        debugLog.record($format("apBusMemWrite: port=%0d, addr=0x%x, data=0x%x", busId, addr, data));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdio.printf(msgWrite, list3(fromInteger(busId), zeroExtendNP(pack(addr)), resize(pack(data))));
        end
`endif
        if (pack(size) > 1)
        begin
            reqPending <= True;
            memBurstNum <= unpack(1);
        end
        else
        begin
            reqQ.deq();
        end
    endrule
    
    rule processPendingWriteReq (tpl_3(reqQ.first()) && reqPending);
        match {.addr, .size, .is_write} = reqQ.first();
        let data = writeDataQ.first();
        writeDataQ.deq();
        t_USER_ADDR mem_addr = unpack(pack(addr) + pack(memBurstNum));
        pack_mem.write(mem_addr, data);
        debugLog.record($format("apBusMemBurstWrite: port=%0d, addr=0x%x, data=0x%x", busId, mem_addr, data));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdio.printf(msgWrite, list3(fromInteger(busId), zeroExtendNP(pack(mem_addr)), resize(pack(data))));
        end
`endif
        if (pack(memBurstNum) == (pack(size)-1) )
        begin
            reqPending <= False;
            reqQ.deq();
        end
        else
        begin
            memBurstNum <= unpack(pack(memBurstNum)+1);
        end
    endrule

    // receive read response from memory and forward it to bus
    rule recvResp (True);
        t_AP_DATA resp <- pack_mem.readRsp();
        bus.readRsp(resp);
        debugLog.record($format("apBusRecvResp: port=%0d, data=0x%x", busId, resp));
    endrule

endmodule

//
// mkHlsAxi4BusMemConnection --
//     Connect the HLS axi4 Bus interface with LEAP memory interface.
//
module [CONNECTED_MODULE] mkHlsAxi4BusMemConnection#(MEMORY_IFC#(t_MEM_ADDR, t_MEM_DATA) mem, 
                                                     HLS_AXI_BUS_IFC#(t_AXI_ADDR_SZ, t_AXI_DATA_SZ, t_AXI_ID_SZ) bus, 
                                                     NumTypeParam#(t_MEM_DATA_SZ) containerDataSz, 
                                                     Bool verbose, 
                                                     DEBUG_FILE debugLog, 
                                                     Integer busId)
    // interface:
    ()
    provisos (Bits#(t_MEM_ADDR, t_MEM_ADDR_SZ),
              Alias#(Bit#(t_MEM_DATA_SZ), t_MEM_DATA), 
              NumAlias#(MEM_PACK_CONTAINER_READ_PORTS#(1, t_AXI_DATA_SZ, t_MEM_DATA_SZ), n_MEM_READERS),
              NumAlias#(TSub#(TAdd#(t_MEM_ADDR_SZ, MEM_PACK_SMALLER_OBJ_IDX_SZ#(t_AXI_DATA_SZ, t_MEM_DATA_SZ)),
                              MEM_PACK_LARGER_OBJ_IDX_SZ#(t_AXI_DATA_SZ, t_MEM_DATA_SZ)), t_USER_ADDR_SZ),
              Alias#(Bit#(t_USER_ADDR_SZ), t_USER_ADDR),
              Alias#(Bit#(t_AXI_ADDR_SZ), t_AXI_ADDR),
              Alias#(Bit#(t_AXI_DATA_SZ), t_AXI_DATA),
              Alias#(Bit#(t_AXI_ID_SZ), t_AXI_ID),
              Alias#(AXI4_ADDR_CMD#(t_AXI_ID_SZ, t_AXI_ADDR_SZ), t_ADDR_CMD), 
              Alias#(AXI4_WRITE_DATA#(t_AXI_ID_SZ, t_AXI_DATA_SZ), t_WRITE_DATA), 
              Alias#(AXI4_READ_RESP#(t_AXI_ID_SZ, t_AXI_DATA_SZ), t_READ_RESP), 
              Alias#(AXI4_WRITE_RESP#(t_AXI_ID_SZ), t_WRITE_RESP));
    
    FIFOF#(t_ADDR_CMD)     readReqQ <- mkSizedFIFOF(4);
    FIFOF#(t_ADDR_CMD)    writeReqQ <- mkSizedFIFOF(4);
    FIFOF#(t_WRITE_DATA) writeDataQ <- mkSizedFIFOF(8);
    FIFOF#(t_READ_RESP)   readRespQ <- mkFIFOF();
    FIFOF#(t_WRITE_RESP) writeRespQ <- mkFIFOF();

`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
    STDIO#(Bit#(64)) stdioForRead  <- mkStdIO();
    STDIO#(Bit#(64)) stdioForWrite <- mkStdIO();
    let msgRead    <- getGlobalStringUID("axiBusMemRead: port=%0d, addr=0x%x\n");
    let msgReadRsp <- getGlobalStringUID("axiBusMemReadRsp: addr=0x%x, data=0x%x\n");
    let msgWrite   <- getGlobalStringUID("axiBusMemWrite: port=%0d, addr=0x%x, data=0x%x\n");
`endif

    // =======================================================================
    //
    // Axi bus to/from req/resp FIFOs
    //
    // =======================================================================
    
    (* fire_when_enabled *)
    rule getReadReq (bus.readPort.arValid && readReqQ.notFull);
        let req = AXI4_ADDR_CMD { id: bus.readPort.arId, len: bus.readPort.arLen, size: bus.readPort.arSize, burst: bus.readPort.arBurst, addr: bus.readPort.arAddr };
        readReqQ.enq(req);
        debugLog.record($format("axiBusGetReadReq: port=%0d, id=%0d, len=%0d, size=%0d, burst=%0d, addr=0x%x", 
                        busId, bus.readPort.arId, bus.readPort.arLen, bus.readPort.arSize, bus.readPort.arBurst, bus.readPort.arAddr));
    endrule
    
    (* fire_when_enabled, no_implicit_conditions *)
    rule readReqReady (readReqQ.notFull);
        bus.readPort.arReady();
    endrule

    (* fire_when_enabled *)
    rule sendReadResp (readRespQ.notEmpty);
        bus.readPort.rValid();
        let r = readRespQ.first();
        bus.readPort.rId(r.id);
        bus.readPort.rData(r.data);
        bus.readPort.rResp(r.resp);
        bus.readPort.rLast();
    endrule
    
    (* fire_when_enabled *)
    rule deqReadResp (bus.readPort.rReady && readRespQ.notEmpty);
        let r = readRespQ.first();
        readRespQ.deq();
        debugLog.record($format("axiBusReadResp: port=%0d, id=%0d, resp=%0d, last=%0d, data=0x%x", 
                        busId, r.id, r.resp, r.last, r.data));
    endrule
    
    (* fire_when_enabled *)
    rule getWriteReq (bus.writePort.awValid && writeReqQ.notFull);
        let req = AXI4_ADDR_CMD { id: bus.writePort.awId, len: bus.writePort.awLen, size: bus.writePort.awSize, burst: bus.writePort.awBurst, addr: bus.writePort.awAddr };
        writeReqQ.enq(req);
        debugLog.record($format("axiBusGetWriteReq: port=%0d, id=%0d, len=%0d, size=%0d, burst=%0d, addr=0x%x", 
                        busId, bus.writePort.awId, bus.writePort.awLen, bus.writePort.awSize, bus.writePort.awBurst, bus.writePort.awAddr));
    endrule
    
    (* fire_when_enabled, no_implicit_conditions *)
    rule writeReqReady (writeReqQ.notFull);
        bus.writePort.awReady();
    endrule

    (* fire_when_enabled *)
    rule getWriteData (bus.writePort.wValid && writeDataQ.notFull);
        let req = AXI4_WRITE_DATA { id: bus.writePort.wId, data: bus.writePort.wData, strb: bus.writePort.wStrb, last: bus.writePort.wLast };
        writeDataQ.enq(req);
        debugLog.record($format("axiBusGetWriteData: port=%0d, id=%0d, data=0x%x, strb=0x%x, last=%0d", 
                        busId, bus.writePort.wId, bus.writePort.wData, bus.writePort.wStrb, bus.writePort.wLast));
    endrule
    
    (* fire_when_enabled, no_implicit_conditions *)
    rule writeDataReady (writeDataQ.notFull);
        bus.writePort.wReady();
    endrule

    (* fire_when_enabled *)
    rule sendWriteResp (writeRespQ.notEmpty);
        bus.writePort.bValid();
        let r = writeRespQ.first();
        bus.writePort.bId(r.id);
        bus.writePort.bResp(r.resp);
    endrule
    
    (* fire_when_enabled *)
    rule deqWriteResp (bus.writePort.bReady && writeRespQ.notEmpty);
        let r = writeRespQ.first();
        writeRespQ.deq();
        debugLog.record($format("axiBusWriteResp: port=%0d, id=%0d, resp=%0d", busId, r.id, r.resp));
    endrule
    
    // =======================================================================
    //
    // Access Memory
    //
    // =======================================================================

    FIFOF#(Bool) memReadReqQ <- mkSizedFIFOF(32);
    Reg#(t_USER_ADDR) readAddr <- mkReg(unpack(0));
    Reg#(Bool) readBurstPending <- mkReg(False);
    Reg#(Bit#(8)) readReqLen <- mkReg(0);

    //
    // May need additional read port(s) to handle data items 
    // that have different sizes from the underlying scratchpad data size
    //
    // Use mkMemIfcToPseudoMultiMemSyncWrites to create the illusion of 
    // multiple read ports by multiplexing all requests on a single physical 
    // read port.  
    // 
    MEMORY_MULTI_READ_IFC#(n_MEM_READERS, t_MEM_ADDR, t_MEM_DATA) multiPortMem <- 
        mkMemIfcToPseudoMultiMemSyncWritesWrapper(mem);
    // MEMORY_MULTI_READ_IFC#(n_MEM_READERS, t_MEM_ADDR, t_MEM_DATA) multiPortMem;
    // if (valueOf(n_MEM_READERS) == 1) 
    // begin
    //     multiPortMem <- mkMemIfcToMultiMemIfc(mem);
    // end
    // else
    // begin
    //     multiPortMem <- mkMemIfcToPseudoMultiMemSyncWrites(mem);
    // end

    MEMORY_MULTI_READ_IFC#(1, t_USER_ADDR, t_AXI_DATA) pack_mem_multi;
    MEMORY_IFC#(t_USER_ADDR, t_AXI_DATA) pack_mem;

    if (valueOf(t_USER_ADDR_SZ) == valueOf(t_MEM_ADDR_SZ))
    begin
        // One object per container
        // pack_mem <- mkMultiMemIfcToMemIfc(mkMemPack1To1(containerDataSz, multiPortMem));
        pack_mem_multi <- mkMemPack1To1(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end
    else if (valueOf(t_USER_ADDR_SZ) > valueOf(t_MEM_ADDR_SZ))
    begin
        // Multiple objects per container
        // pack_mem <- mkMultiMemIfcToMemIfc(mkMemPackManyTo1(containerDataSz, multiPortMem));
        pack_mem_multi <- mkMemPackManyTo1(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end
    else
    begin
        // Object bigger than one container.  Use multiple containers for
        // each object.
        // pack_mem <- mkMultiMemIfcToMemIfc(mkMemPack1ToMany(containerDataSz, multiPortMem));
        pack_mem_multi <- mkMemPack1ToMany(containerDataSz, multiPortMem);
        pack_mem <- mkMultiMemIfcToMemIfc(pack_mem_multi);
    end

`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
    // Create a large FIFO for keeping addresses so that we can have
    // better debug on the request side. 
    FIFOF#(t_USER_ADDR) outstandingAddressBuffer <- mkSizedBRAMFIFOF(512);
`endif

    rule processNewReadReq (!readBurstPending);
        let req = readReqQ.first();
        Bool is_last = True;
        t_USER_ADDR mem_addr = unpack(resize(req.addr >> fromInteger(valueOf(TLog#(TDiv#(t_AXI_DATA_SZ, 8))))));
        if (req.len != 0)
        begin
            readAddr <= mem_addr;    
            readBurstPending <= True;
            is_last = False;
            readReqLen <= 1;
        end
        else
        begin
            readReqQ.deq();
        end
        pack_mem.readReq(mem_addr);
        memReadReqQ.enq(is_last);
        debugLog.record($format("processNewReadReq: port%0d, addr=0x%x, isLast=%s", 
                        busId, mem_addr, is_last? "True" : "False"));

`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        outstandingAddressBuffer.enq(mem_addr);
        if (verbose)
        begin
            stdioForRead.printf(msgRead, list2(fromInteger(busId), zeroExtendNP(pack(mem_addr))));
        end
`endif

    endrule
    
    rule processPendingReadReq (readBurstPending);
        let req = readReqQ.first();
        Bool is_last = True;
        t_USER_ADDR mem_addr = readAddr;
        if (req.burst == INCR)
        begin
            mem_addr = unpack(pack(readAddr) + 1);
        end
        if (req.len != readReqLen)
        begin
            readAddr <= mem_addr;    
            readReqLen <= readReqLen + 1;
            is_last = False;
        end
        else
        begin
            readReqQ.deq();
            readBurstPending <= False;
        end
        pack_mem.readReq(mem_addr);
        memReadReqQ.enq(is_last);
        debugLog.record($format("processPendingReadReq: port%0d, addr=0x%x, isLast=%s", 
                        busId, mem_addr, is_last? "True" : "False"));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        outstandingAddressBuffer.enq(mem_addr);
        if (verbose)
        begin
            stdioForRead.printf(msgRead, list2(fromInteger(busId), zeroExtendNP(pack(mem_addr))));
        end
`endif
    endrule

    rule recvMemResp (True);
        let r <- pack_mem.readRsp();
        let is_last = memReadReqQ.first();
        memReadReqQ.deq();
        readRespQ.enq(AXI4_READ_RESP{ id: 0, data: resize(pack(r)), resp: OKAY, last: is_last });

`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        outstandingAddressBuffer.deq();
        if (verbose)
        begin
            stdioForRead.printf(msgReadRsp, list2(zeroExtendNP(pack(outstandingAddressBuffer.first())), resize(pack(r))));
        end
`endif

        debugLog.record($format("recvMemResp: port%0d, data=0x%x, isLast=%s", 
                        busId, r, is_last? "True" : "False"));
    endrule

    Reg#(t_USER_ADDR) writeAddr <- mkReg(unpack(0));
    Reg#(Bool) writeBurstPending <- mkReg(False);
    Reg#(Bit#(8)) writeReqLen <- mkReg(0);

    rule processNewWriteReq (!writeBurstPending);
        let req = writeReqQ.first();
        let w_data = writeDataQ.first();
        writeDataQ.deq();
        t_USER_ADDR mem_addr = unpack(resize(req.addr >> fromInteger(valueOf(TLog#(TDiv#(t_AXI_DATA_SZ, 8))))));
        if (req.len != 0)
        begin
            writeAddr <= mem_addr;
            writeBurstPending <= True;
            writeReqLen <= 1;
        end
        else
        begin
            writeReqQ.deq();
            writeRespQ.enq(AXI4_WRITE_RESP{ id: 0, resp: OKAY });
            if (!w_data.last)
            begin
                debugLog.record($format("processNewWriteReq: port%0d, ERROR: wLast should be true", busId));
            end
        end
        pack_mem.write(mem_addr, unpack(resize(w_data.data)));
        debugLog.record($format("processNewWriteReq: port%0d, len=%0d, addr=0x%x, data=0x%x, isLast=%s",
                        busId, req.len, mem_addr, w_data.data, w_data.last? "True" : "False"));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdioForWrite.printf(msgWrite, list3(fromInteger(busId), zeroExtendNP(pack(mem_addr)), resize(pack(w_data.data))));
        end
`endif
    endrule
    
    rule processPendingWriteReq (writeBurstPending);
        let req = writeReqQ.first();
        let w_data = writeDataQ.first();
        writeDataQ.deq();
        t_USER_ADDR mem_addr = writeAddr;
        if (req.burst == INCR)
        begin
            mem_addr = unpack(pack(writeAddr) + 1);
        end
        if (req.len != writeReqLen)
        begin
            writeAddr <= mem_addr;    
            writeReqLen <= writeReqLen + 1;
        end
        else
        begin
            writeReqQ.deq();
            writeRespQ.enq(AXI4_WRITE_RESP{ id: 0, resp: OKAY });
            writeBurstPending <= False;
            if (!w_data.last)
            begin
                debugLog.record($format("processPendingWriteReq: port%0d, ERROR: wLast should be true", busId));
            end
        end
        pack_mem.write(mem_addr, unpack(resize(w_data.data)));
        debugLog.record($format("processPendingWriteReq: port%0d, len=%0d, addr=0x%x, data=0x%x, isLast=%s", 
                        busId, req.len, mem_addr, w_data.data, w_data.last? "True" : "False"));
`ifndef MEM_TEST_STDIO_DEBUG_ENABLE_Z
        if (verbose)
        begin
            stdioForWrite.printf(msgWrite, list3(fromInteger(busId), zeroExtendNP(pack(mem_addr)), resize(pack(w_data.data))));
        end
`endif
    endrule

endmodule


//
// mkHlsApInFifoConnection --
//     Wrap HLS input ap fifo interface with an LI channel
//
module [CONNECTED_MODULE] mkHlsApInFifoConnection#(HLS_AP_IN_FIFO_IFC#(t_DATA_SZ) hlsFifo, 
                                                   String fifoName, 
                                                   DEBUG_FILE debugLog) 
    // interface:
    ()
    provisos (Alias#(Bit#(t_DATA_SZ), t_DATA));

    CONNECTION_RECV#(t_DATA) msgQ <- mkConnectionRecv("hls_fifo_" + fifoName);

    rule forwardMsg(msgQ.notEmpty);
        let msg = msgQ.receive();
        hlsFifo.inputMsg(msg);
        debugLog.record($format("forwardMsg: apInFifo: name=%s, msg=0x%x", fifoName, msg)); 
    endrule

    rule dropMsg(hlsFifo.msgReceived());
        msgQ.deq(); 
        debugLog.record($format("msgReceived: apInFifo: name=%s", fifoName)); 
    endrule

endmodule

//
// mkHlsApOutFifoConnection --
//     Wrap HLS output ap fifo interface with an LI channel
//
module [CONNECTED_MODULE] mkHlsApOutFifoConnection#(HLS_AP_OUT_FIFO_IFC#(t_DATA_SZ) hlsFifo, 
                                                    String fifoName, 
                                                    DEBUG_FILE debugLog) 
    // interface:
    ()
    provisos (Alias#(Bit#(t_DATA_SZ), t_DATA));

    CONNECTION_SEND#(t_DATA) msgQ <- mkConnectionSend("hls_fifo_" + fifoName);

    rule checkNotFull(msgQ.notFull);
        hlsFifo.notFull();
    endrule

    rule enqMsg(True);
        let msg = hlsFifo.outputMsg();
        msgQ.send(msg); 
        debugLog.record($format("enqMsg: apOutFifo: name=%s, msg=0x%x", fifoName, msg)); 
    endrule

endmodule
