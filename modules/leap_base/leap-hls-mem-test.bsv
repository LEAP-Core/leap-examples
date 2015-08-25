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
import DefaultValue::*;

`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"

`include "awb/provides/mem_services.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/scratchpad_memory_common.bsh"

`include "awb/dict/VDEV_SCRATCH.bsh"
`include "awb/dict/PARAMS_HARDWARE_SYSTEM.bsh"

typedef Bit#(64) CYCLE_COUNTER;
typedef Bit#(`MEMORY_ADDR_BITS) MEM_ADDRESS;
typedef Bit#(`TEST_DATA_BITS) MEM_DATA;

typedef enum
{
    STATE_INIT,
    STATE_TEST,
    STATE_FIN,
    STATE_EXIT
}
STATE
    deriving (Bits, Eq);

//
// Implement a synchronization performance test
//
module [CONNECTED_MODULE] mkSystem ()
    provisos (Bits#(MEM_ADDRESS, t_MEM_ADDR_SZ),
              Bits#(MEM_DATA, t_MEM_DATA_SZ));

    Connection_Receive#(Bool) linkStarterStartRun <- mkConnectionRecv("vdev_starter_start_run");
    Connection_Send#(Bit#(8)) linkStarterFinishRun <- mkConnectionSend("vdev_starter_finish_run");

    DEBUG_FILE debugLog <- mkDebugFile("leap_hls_mem_test.out");

    // Standard IO
    STDIO#(Bit#(64)) stdio <- mkStdIO();
    // Messages for standard IO
    let msgInit <- getGlobalStringUID("leapHlsMemTest: start\n");
    let msgDone <- getGlobalStringUID("leapHlsMemTest: cycle count: %012d\n");
    
    // Scratchpad memory
    SCRATCHPAD_CONFIG sconf = defaultValue;
    sconf.cacheMode = (`MEM_TEST_PVT_CACHE_ENABLE == 1)? SCRATCHPAD_CACHED : SCRATCHPAD_NO_PVT_CACHE;
    sconf.requestMerging = (`MEM_TEST_REQ_MERGE_ENABLE == 1);
    sconf.debugLogPath = (`MEM_TEST_DEBUG_ENABLE == 1)? tagged Valid "scratchpad_memory_0.out" : tagged Invalid;
    sconf.enableStatistics = (`MEM_TEST_STATS_ENABLE == 1)? tagged Valid "scratchpad_memory_0_" : tagged Invalid;
    
    Vector#(`MEM_TEST_MEMORY_PORT_NUM, MEMORY_IFC#(MEM_ADDRESS, MEM_DATA)) memories = newVector();

`ifdef MEM_TEST_MULTI_PORT_MEM_ENABLE_Z
    if (`MEM_TEST_MEMORY_PORT_NUM != 1)
    begin
        error("MEM_TEST_MULTI_PORT_MEM_ENABLE should be set to 1");
    end
    MEMORY_IFC#(MEM_ADDRESS, MEM_DATA) memory <- mkScratchpad(`VDEV_SCRATCH_MEM_TEST, sconf);
    MEMORY_MULTI_READ_IFC#(1, MEM_ADDRESS, MEM_DATA) multi_reader_mem <- mkMemIfcToMultiMemIfc(memory);
    memories <- mkMultiReadMemIfcToVectorMemIfc(multi_reader_mem);
`else
    MEMORY_MULTI_READ_IFC#(`MEM_TEST_MEMORY_PORT_NUM, MEM_ADDRESS, MEM_DATA) multi_reader_mem <- mkMultiReadScratchpad(`VDEV_SCRATCH_MEM_TEST, sconf);
    memories <- mkMultiReadMemIfcToVectorMemIfc(multi_reader_mem);
`endif
    
    PARAMETER_NODE paramNode <- mkDynamicParameterNode();
    Param#(1) verboseMode <- mkDynamicParameter(`PARAMS_HARDWARE_SYSTEM_MEM_TEST_VERBOSE, paramNode);
    let verbose = verboseMode == 1;

    // HLS core
    NumTypeParam#(t_MEM_DATA_SZ) memDataSz = ?;
    HLS_CORE_IFC hlsCore <- mkHlsCore(memories, memDataSz, debugLog);

    Reg#(STATE) state                 <- mkReg(STATE_INIT);
    Reg#(CYCLE_COUNTER) cycleCnt      <- mkReg(0);
    Reg#(CYCLE_COUNTER) initCycleCnt  <- mkReg(0);
  
    (* fire_when_enabled *)
    rule countCycle(True);
        cycleCnt <= cycleCnt + 1;
    endrule

    rule doInit (state == STATE_INIT);
        linkStarterStartRun.deq();
        stdio.printf(msgInit, List::nil);
        initCycleCnt <= cycleCnt;
        hlsCore.start();
        hlsCore.setVerboseMode(verbose);
        state <= STATE_TEST;
    endrule

    rule waitForDone (state == STATE_TEST && hlsCore.isDone());
        state <= STATE_FIN;
    endrule

    // ====================================================================
    //
    // End of program.
    //
    // ====================================================================

    rule sendDone (state == STATE_FIN);
        stdio.printf(msgDone, list(zeroExtend(cycleCnt-initCycleCnt)));
        linkStarterFinishRun.send(0);
        state <= STATE_EXIT;
    endrule

    rule finished (state == STATE_EXIT);
        noAction;
    endrule

endmodule

