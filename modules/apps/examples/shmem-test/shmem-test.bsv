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

`include "asim/provides/virtual_platform.bsh"
`include "asim/provides/virtual_devices.bsh"
`include "asim/provides/physical_platform.bsh"
`include "asim/provides/low_level_platform_interface.bsh"
`include "asim/provides/shared_memory.bsh"

`include "asim/rrr/service_ids.bsh"
`include "asim/rrr/server_stub_SHMEM_TEST.bsh"

// types

typedef enum 
{
    STATE_idle, 
    STATE_OneWay
} 
STATE deriving(Bits,Eq);

typedef Bit#(64) PAYLOAD;

// mkSystem

module mkApplication#(VIRTUAL_PLATFORM vp)();
    
    // instantiate the virtual devices I need
    SHARED_MEMORY sharedMemory = vp.virtualDevices.sharedMemory;

    // instantiate stubs
    ServerStub_SHMEM_TEST serverStub <- mkServerStub_SHMEM_TEST(vp.llpint.rrrServer);
    
    // counters
    Reg#(SHARED_MEMORY_DATA) curTick     <- mkReg(0);
    Reg#(SHARED_MEMORY_DATA) timer       <- mkReg(0);
    Reg#(SHARED_MEMORY_BURST_LENGTH) burstLength <- mkReg(0);

    SHARED_MEMORY_DATA cycles = curTick - timer;

    // test payload
    PAYLOAD payload = '1;
    
    // state
    Reg#(STATE) state <- mkReg(STATE_idle);
    
    // count FPGA cycles
    rule tick (True);
        
        if (curTick == '1)
        begin
            curTick <= 0;
        end
        else
        begin
            curTick <= curTick + 1;
        end
        
    endrule
    
    //
    // FPGA -> Host one-way test
    //
    
    rule start_oneway_test (state == STATE_idle);
        
        let burst_length <- serverStub.acceptRequest_OneWayTest();
        
        // start the clock (only for the first request) and let it rip
        if (timer == 0)
        begin
            timer <= curTick;
        end
        
        burstLength <= unpack(burst_length);
        state       <= STATE_OneWay;
        
        sharedMemory.writeBurstReq(0, burst_length);
        
    endrule
    
    rule cont_oneway_test (state == STATE_OneWay && burstLength != 0);
    
        sharedMemory.writeBurstData(cycles);
        burstLength <= burstLength - 1;

    endrule
    
    rule end_oneway_test (state == STATE_OneWay && burstLength == 0);
        
        serverStub.sendResponse_OneWayTest(pack(cycles));
        state <= STATE_idle;
        
    endrule
    
endmodule
