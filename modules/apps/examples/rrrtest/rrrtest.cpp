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

//
// @file rrrtest.cpp
// @brief RRR Test System
//
// @author Angshuman Parashar
//

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <iomanip>

#include "asim/syntax.h"
#include "asim/ioformat.h"
#include "asim/rrr/service_ids.h"
#include "asim/provides/connected_application.h"
#include "asim/provides/clocks_device.h"

using namespace std;

// constructor
CONNECTED_APPLICATION_CLASS::CONNECTED_APPLICATION_CLASS(
    VIRTUAL_PLATFORM vp)
{
    // instantiate client stub
    clientStub = new RRRTEST_CLIENT_STUB_CLASS(NULL);
}

// destructor
CONNECTED_APPLICATION_CLASS::~CONNECTED_APPLICATION_CLASS()
{
    delete clientStub;
}

void
CONNECTED_APPLICATION_CLASS::Init()
{
}

// main
void
CONNECTED_APPLICATION_CLASS::Main()
{
    UINT64 cycles;
    UINT64 test_length  = testIterSwitch.Value();
#ifdef MODEL_CLOCK_FREQ
    UINT64 fpga_freq    = MODEL_CLOCK_FREQ;
#elif (defined(MODEL_CLOCK_MULTIPLIER) && defined(MODEL_CLOCK_DIVIDER) && defined(CRYSTAL_CLOCK_FREQ))
    // Assume 50MHz base clock
    UINT64 fpga_freq    = (CRYSTAL_CLOCK_FREQ * MODEL_CLOCK_MULTIPLIER) / MODEL_CLOCK_DIVIDER;
#else
    UINT64 fpga_freq    = 0;
#endif
    UINT64 payload_bytes = 8;    // FIXME: no idea how
    UINT64 header_bytes = UMF_CHUNK_BYTES;

    double datasize = payload_bytes + header_bytes;
    double latency_c = 0;
    double latency = 0;
    double bandwidth = 0;

    // print banner and test parameters
    cout << "\n";
    cout << "Test Parameters\n";
    cout << "---------------\n";
    cout << "Number of Transactions  = " << dec << test_length << endl;
    cout << "FPGA Clock Frequency    = " << fpga_freq << endl;

    cout << endl << "*** Bandwidth includes internal packet headers ***" << endl << endl;

    //
    // perform one-way test with short messages
    //
    cycles = clientStub->F2HOneWayTest(0, test_length);

    // compute results
    latency_c = double(cycles) / test_length;
    if (fpga_freq != 0)
    {
        latency   = latency_c / fpga_freq;
        bandwidth = datasize / latency;
    }
        
    // report results
    cout << "\n";
    cout << "One-Way FPGA->Host Test Results (small messages)\n";
    cout << "--------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Payload Bytes     = " << payload_bytes << endl;
    cout << "Header Bytes      = " << header_bytes << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    //
    // perform one-way test with 64 byte messages
    //
    cycles = clientStub->F2HOneWayTest(1, test_length);

    // compute results
    UINT64 big_payload_bytes = payload_bytes * 8;
    latency_c = double(cycles) / test_length;
    if (fpga_freq != 0)
    {
        latency   = latency_c / fpga_freq;
        bandwidth = (big_payload_bytes + header_bytes) / latency;
    }
        
    // report results
    cout << "\n";
    cout << "One-Way FPGA->Host Test Results (64 byte messages)\n";
    cout << "--------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Payload Bytes     = " << big_payload_bytes << endl;
    cout << "Header Bytes      = " << header_bytes << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    if (longTestsSwitch.Value() != 0)
    {
        //
        // perform one-way test with 128 byte messages
        //
        cycles = clientStub->F2HOneWayTest(2, test_length);

        // compute results
        big_payload_bytes = payload_bytes * 16;
        latency_c = double(cycles) / test_length;
        if (fpga_freq != 0)
        {
            latency   = latency_c / fpga_freq;
            bandwidth = (big_payload_bytes + header_bytes) / latency;
        }
        
        // report results
        cout << "\n";
        cout << "One-Way FPGA->Host Test Results (128 byte messages)\n";
        cout << "--------------------\n";
        cout << "FPGA cycles       = " << cycles << endl;
        cout << "Payload Bytes     = " << big_payload_bytes << endl;
        cout << "Header Bytes      = " << header_bytes << endl;
        cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
             << "                  = " << latency << " usec\n";
        cout << "Average Bandwidth = " << bandwidth << " MB/s\n";


        //
        // perform one-way test with 256 byte messages
        //
        cycles = clientStub->F2HOneWayTest(3, test_length);

        // compute results
        big_payload_bytes = payload_bytes * 32;
        latency_c = double(cycles) / test_length;
        if (fpga_freq != 0)
        {
            latency   = latency_c / fpga_freq;
            bandwidth = (big_payload_bytes + header_bytes) / latency;
        }
        
        // report results
        cout << "\n";
        cout << "One-Way FPGA->Host Test Results (256 byte messages)\n";
        cout << "--------------------\n";
        cout << "FPGA cycles       = " << cycles << endl;
        cout << "Payload Bytes     = " << big_payload_bytes << endl;
        cout << "Header Bytes      = " << header_bytes << endl;
        cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
             << "                  = " << latency << " usec\n";
        cout << "Average Bandwidth = " << bandwidth << " MB/s\n";
    }


    //
    // One way host to FPGA tests.
    //

    //
    // perform one-way test with 64 byte messages
    //
    clientStub->H2FOneWayTest(0, test_length);

    for (UINT64 i = 0; i < test_length; i++)
    {
        clientStub->H2FOneWayMsg8(0, 1, 2, 3, 4, 5, 6, 7);
    }

    OUT_TYPE_H2FOneWayDone r = clientStub->H2FOneWayDone(0);
    cycles = r.cycles;

    // compute results
    big_payload_bytes = payload_bytes * 8;
    latency_c = double(cycles) / test_length;
    if (fpga_freq != 0)
    {
        latency   = latency_c / fpga_freq;
        bandwidth = (big_payload_bytes + header_bytes) / latency;
    }
        
    // report results
    cout << "\n";
    cout << "One-Way Host->FPGA Test Results (64 byte messages)\n";
    cout << "--------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Payload Bytes     = " << big_payload_bytes << endl;
    cout << "Header Bytes      = " << header_bytes << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    if (longTestsSwitch.Value() != 0)
    {
        //
        // perform one-way test with 128 byte messages
        //
        clientStub->H2FOneWayTest(1, test_length);

        for (UINT64 i = 0; i < test_length; i++)
        {
            clientStub->H2FOneWayMsg16(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
        }

        OUT_TYPE_H2FOneWayDone r = clientStub->H2FOneWayDone(0);
        cycles = r.cycles;

        // compute results
        big_payload_bytes = payload_bytes * 16;
        latency_c = double(cycles) / test_length;
        if (fpga_freq != 0)
        {
            latency   = latency_c / fpga_freq;
            bandwidth = (big_payload_bytes + header_bytes) / latency;
        }
        
        // report results
        cout << "\n";
        cout << "One-Way Host->FPGA Test Results (128 byte messages)\n";
        cout << "--------------------\n";
        cout << "FPGA cycles       = " << cycles << endl;
        cout << "Payload Bytes     = " << big_payload_bytes << endl;
        cout << "Header Bytes      = " << header_bytes << endl;
        cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
             << "                  = " << latency << " usec\n";
        cout << "Average Bandwidth = " << bandwidth << " MB/s\n";
    }


    //
    // perform two-way test
    //
    cycles = clientStub->F2HTwoWayTest(0, test_length);

    // compute results
    latency_c = double(cycles) / test_length;
    if (fpga_freq != 0)
    {
        latency   = latency_c / fpga_freq;
        bandwidth = 2 * datasize / latency;
    }
        
    // report results
    cout << "\n";
    cout << "Two-Way Test Results\n";
    cout << "--------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Payload Bytes     = " << payload_bytes << " (each way) " << endl;
    cout << "Header Bytes      = " << header_bytes << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    //
    // perform long two-way test
    //
    if (longTestsSwitch.Value() != 0)
    {
        cycles = clientStub->F2HTwoWayTest(1, test_length);

        // compute results
        big_payload_bytes = payload_bytes * 16;
        latency_c = double(cycles) / test_length;
        if (fpga_freq != 0)
        {
            latency   = latency_c / fpga_freq;
            bandwidth = 2 * (big_payload_bytes + header_bytes) / latency;
        }
        
        // report results
        cout << "\n";
        cout << "Two-Way Test Results (128 byte messages)\n";
        cout << "--------------------\n";
        cout << "FPGA cycles       = " << cycles << endl;
        cout << "Payload Bytes     = " << big_payload_bytes << " (each way) " << endl;
        cout << "Header Bytes      = " << header_bytes << endl;
        cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
             << "                  = " << latency << " usec\n";
        cout << "Average Bandwidth = " << bandwidth << " MB/s\n";
    }

    //
    // perform two-way pipelined test
    //
    cycles = clientStub->F2HTwoWayPipeTest(0, test_length);

    // compute results
    latency_c = double(cycles) / test_length;
    if (fpga_freq != 0)
    {
        latency   = latency_c / fpga_freq;
        bandwidth = 2 * datasize / latency;
    }

    // report results
    cout << "\n";
    cout << "Two-Way Pipelined Test Results\n";
    cout << "------------------------------\n";
    cout << "FPGA cycles       = " << cycles << endl;
    cout << "Payload Bytes     = " << payload_bytes << " (each way) " << endl;
    cout << "Header Bytes      = " << header_bytes << endl;
    cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
         << "                  = " << latency << " usec\n";
    cout << "Average Bandwidth = " << bandwidth << " MB/s\n";

    if (longTestsSwitch.Value() != 0)
    {
        //
        // perform big two-way pipelined test
        //
        cycles = clientStub->F2HTwoWayPipeTest(1, test_length);

        // compute results
        big_payload_bytes = payload_bytes * 16;
        latency_c = double(cycles) / test_length;
        if (fpga_freq != 0)
        {
            latency   = latency_c / fpga_freq;
            bandwidth = 2 * (big_payload_bytes + header_bytes) / latency;
        }

        // report results
        cout << "\n";
        cout << "Two-Way Pipelined Test Results (128 byte messages)\n";
        cout << "------------------------------\n";
        cout << "FPGA cycles       = " << cycles << endl;
        cout << "Payload Bytes     = " << big_payload_bytes << " (each way) " << endl;
        cout << "Header Bytes      = " << header_bytes << endl;
        cout << "Average Latency   = " << latency_c << " FPGA cycles\n" 
             << "                  = " << latency << " usec\n";
        cout << "Average Bandwidth = " << bandwidth << " MB/s\n";
    }

    // done!
    cout << "\n";
    cout << "Tests Complete!\n";

    STARTER_SERVICE_SERVER_CLASS::GetInstance()->End(0);
}
