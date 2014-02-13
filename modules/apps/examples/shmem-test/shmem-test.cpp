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

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <iomanip>

#include "asim/rrr/service_ids.h"
#include "asim/provides/bluespec_system.h"
#include "asim/provides/command_switches.h"
#include "asim/ioformat.h"

using namespace std;

// constructor
BLUESPEC_SYSTEM_CLASS::BLUESPEC_SYSTEM_CLASS(
    LLPI llpi):
        PLATFORMS_MODULE_CLASS(NULL),
        sharedMemoryDevice(this, llpi)
{
    // instantiate client stub
    clientStub = new SHMEM_TEST_CLIENT_STUB_CLASS(this);
}

// destructor
BLUESPEC_SYSTEM_CLASS::~BLUESPEC_SYSTEM_CLASS()
{
    delete clientStub;
}

// main
void
BLUESPEC_SYSTEM_CLASS::Main()
{
    UINT64 cycles;
    UINT64 test_length  = 100000; // FIXME: take this from a dynamic parameter
    UINT64 fpga_freq    = 75;    // FIXME: take this from a dynamic parameter
    UINT64 payload_bits = 64;    // FIXME: no idea how
    UINT32 burst_length = 512;

    double datasize = payload_bits / 8;
    double latency_c;
    double latency;
    double bandwidth;

    //
    // setup shared memory
    //
    UINT64* mem = (UINT64 *)sharedMemoryDevice.Allocate();

    // print banner and test parameters
    cout << "\n";
    cout << "Test Parameters\n";
    cout << "---------------\n";
    cout << "Number of Transactions  = " << dec << test_length << endl;
    cout << "Payload Width (in bits) = " << payload_bits << endl;
    cout << "FPGA Clock Frequency    = " << fpga_freq << endl;

    //
    // perform one-way test
    //
    UINT64 last_seen_data = mem[burst_length - 1];

    for (int test = 0; test < test_length; test++)
    {
        cycles = clientStub->OneWayTest(burst_length);

        // sleep(2);

        // wait for memory flag to change
        while (last_seen_data == mem[burst_length - 1]);
        last_seen_data = mem[burst_length - 1];

        /*
        for (int i = 0; i < burst_length; i++)
        {
            cout << hex << mem[i] << dec << endl;
        }
        cout << endl;
        */
        // cout << last_seen_data << endl;
    }

    cycles = last_seen_data;

    // compute results
    latency_c = double(cycles) / test_length;
    latency   = latency_c / fpga_freq;
    bandwidth = (datasize * burst_length) / latency;
        
    // report results
    cout << "\n";
    cout << "One-Way Test Results\n";
    cout << "--------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    // done!
    cout << "\n";
}
