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

`include "awb/provides/virtual_platform.bsh"
`include "awb/provides/virtual_devices.bsh"
`include "awb/provides/physical_platform.bsh"
`include "awb/provides/low_level_platform_interface.bsh"
`include "awb/provides/librl_bsv_storage.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/umf.bsh"
`include "awb/provides/dynamic_parameters_service.bsh"
`include "awb/dict/PARAMS_CONNECTED_APPLICATION.bsh"

import FIFOF::*;

typedef enum {
  RW,
  R_ONLY,
  W_ONLY
} Experiment deriving (Bits, Eq);

module [CONNECTED_MODULE] mkConnectedApplication (Empty);
    
    // counters
    Reg#(Experiment) experiment         <- mkReg(RW);
    Reg#(Bit#(64)) curTick              <- mkReg(0);
    Reg#(Bit#(32)) chunkCount           <- mkReg(0);
    
    Connection_Receive#(UMF_CHUNK) valueIn <- mkConnection_Receive("CPUTOFPGA");
    Connection_Send#(UMF_CHUNK) valueOut <- mkConnection_Send("FPGATOCPU");    

    FIFOF#(UMF_CHUNK) store <- mkSizedBRAMFIFOF(8192);

    PARAMETER_NODE paramNode  <- mkDynamicParameterNode();
    Param#(32) totalChunks <- mkDynamicParameter(`PARAMS_CONNECTED_APPLICATION_TOTAL_CHUNKS, paramNode);

    rule tickUp;
        curTick <= curTick + 1;
    endrule

    rule mirrorToHost (experiment == RW);

        if(`VERBOSE == 1)
        begin
            $display("Mirror to Host : %h", valueIn.receive);
        end

        valueIn.deq;
        store.enq(zeroExtend(curTick));
        
        if(truncate(valueIn.receive) != chunkCount)
        begin
            $display("Error unexpected incoming value");
            $finish;
        end

        if(chunkCount + 1 == totalChunks) 
        begin
            chunkCount <= 0;
            experiment <= W_ONLY;
        end
        else
        begin
            chunkCount <= chunkCount + 1;
        end
    endrule

    rule drainStore;
        valueOut.send(store.first);
        store.deq;
    endrule

    rule fillHost (experiment == W_ONLY && !store.notEmpty && valueIn.notEmpty);
        valueOut.send(zeroExtend(curTick));
        if(chunkCount + 1 == totalChunks) 
        begin
            chunkCount <= 0;
            experiment <= R_ONLY;
            valueIn.deq();
        end
        else
        begin
            chunkCount <= chunkCount + 1;
        end
    endrule

    rule drainHost (experiment == R_ONLY);
        valueIn.deq();

        if(`VERBOSE == 1)
        begin
            $display("Received Chunk %d", valueIn.receive);
        end

        if(truncate(valueIn.receive) != chunkCount)
        begin
            $display("Error unexpected incoming value");
            $finish;
        end

        if(chunkCount + 1 == totalChunks) 
        begin
            chunkCount <= 0;
            experiment <= RW;
            valueOut.send(zeroExtend(curTick));
        end
        else
        begin
            if(chunkCount == 0)
            begin
                valueOut.send(zeroExtend(curTick));
            end
            chunkCount <= chunkCount + 1;
        end
    endrule

endmodule
