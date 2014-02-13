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
import List::*;
import LFSR::*;

`include "awb/provides/virtual_platform.bsh"
`include "awb/provides/virtual_devices.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"

typedef enum 
{
    STATE_start,
    STATE_open_outfile,
    STATE_init_writes,
    STATE_writes,
    STATE_close_outfile,
    STATE_open_infile_req,
    STATE_open_infile_rsp,
    STATE_read_data,
    STATE_sink_reads,
    STATE_close_infile,
    STATE_finish
} 
STATE deriving (Bits, Eq);


module [CONNECTED_MODULE] mkSystem ();

    // Starter connections to receive signal to start and send done signal
    Connection_Receive#(Bool) linkStarterStartRun <- mkConnectionRecv("vdev_starter_start_run");
    Connection_Send#(Bit#(8)) linkStarterFinishRun <- mkConnectionSend("vdev_starter_finish_run");

    // Allocate a StdIO node
    STDIO#(Bit#(32)) stdio <- mkStdIO();

    Reg#(STATE) state <- mkReg(STATE_start);

    // Define some strings
    let startMsg <- getGlobalStringUID("Writing data to %s\n");
    let outfile32 = "outfile32.txt";
    let outFile32Name <- getGlobalStringUID(outfile32);
    let fmode <- getGlobalStringUID("w+");


    //
    // Wait for signal to start and print a message to STDOUT.
    //
    rule start (state == STATE_start);
        linkStarterStartRun.deq();
        stdio.printf(startMsg, list1(outFile32Name));

        state <= STATE_open_outfile;
    endrule


    //
    // Request opening of the output file
    //
    rule openOutfile (state == STATE_open_outfile);
        stdio.fopen_req(outFile32Name, fmode);

        state <= STATE_init_writes;
    endrule


    //
    // Receive output file handle
    //
    Reg#(STDIO_FILE) fHandle <- mkRegU();
    rule initWrites (state == STATE_init_writes);
        let fh <- stdio.fopen_rsp();
        fHandle <= fh;

        state <= STATE_writes;
    endrule


    //
    // Write two lines of numbers to the output file
    //
    let fmt <- getGlobalStringUID("%d %d %d %d\n");
    Reg#(Bit#(1)) writeIdx <- mkReg(0);

    rule doWrites (state == STATE_writes);
        stdio.fprintf(fHandle, fmt, list4(zeroExtend({ writeIdx, 3'b000 }),
                                          zeroExtend({ writeIdx, 3'b001 }),
                                          zeroExtend({ writeIdx, 3'b010 }),
                                          zeroExtend({ writeIdx, 3'b011 })));

        if (writeIdx == 0)
            writeIdx <= 1;
        else
            state <= STATE_close_outfile;
    endrule


    //
    // Close the output file
    //
    rule closeFile (state == STATE_close_outfile);
        stdio.fclose(fHandle);

        state <= STATE_open_infile_req;
    endrule


    //
    // Prepare to read the output file back using a Perl script that converts
    // the numeric strings to binary values, read through a pipe.
    //
    let pipeDataIn <- getGlobalStringUID("perl -e 'while (<STDIN>) { foreach (split) { print pack(\"L\", $_); }}' < " + outfile32);
    rule openInfileReq (state == STATE_open_infile_req);
        stdio.popen_req(pipeDataIn, True);

        state <= STATE_open_infile_rsp;
    endrule


    //
    // Receive the handle to the pipe and print a message that the read
    // phase has started.
    //
    let readMsg <- getGlobalStringUID("Read back file using a pipe...\n");
    let dataMsg <- getGlobalStringUID("%d\n");
    Reg#(STDIO_FILE) pHandle <- mkRegU();

    rule openInfileRsp (state == STATE_open_infile_rsp);
        let ph <- stdio.popen_rsp();
        pHandle <= ph;

        stdio.printf(readMsg, List::nil);

        state <= STATE_read_data;
    endrule


    //
    // Reading requires a couple of rules.  The first simply generates read
    // requests.  The number of outstanding requests is limited by code
    // inside the StdIO node.
    //
    rule readReq (state == STATE_read_data);
        stdio.freadMax_req(pHandle);
    endrule


    //
    // The second read rule receives the data.  It also detects the transition
    // to end of file.
    //
    (* descending_urgency = "readReq, readData" *)
    (* conservative_implicit_conditions *)
    rule readData (state == STATE_read_data);
        let rsp <- stdio.fread_rsp();
        if (rsp matches tagged Valid .v)
        begin
            // Print the value on STDOUT
            stdio.printf(dataMsg, list1(v));
        end
        else
        begin
            // End of file
            state <= STATE_sink_reads;
        end
    endrule


    //
    // The last read rule consumes outstanding requests after end of file is
    // reached.  It continues to sink read requests until the StdIO node
    // indicates no more requests are in flight.
    //
    rule readReqSink (state == STATE_sink_reads);
        if (stdio.fread_numInFlight != 0)
        begin
            let rsp <- stdio.fread_rsp();
        end
        else
        begin
            state <= STATE_close_infile;
        end
    endrule


    rule closeInFile (state == STATE_close_infile);
        stdio.fclose(pHandle);

        linkStarterFinishRun.send(0);
        state <= STATE_finish;
    endrule


    rule finish (state == STATE_finish);
        noAction;
    endrule

endmodule
