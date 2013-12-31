/*****************************************************************************
 * litest.bsv
 *
 * Copyright (C) 2013 Intel Corporation
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

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
