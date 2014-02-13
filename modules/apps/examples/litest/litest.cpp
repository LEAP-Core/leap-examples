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

#include "awb/provides/connected_application.h"
#include "awb/rrr/service_ids.h"
#include "awb/provides/clocks_device.h"
#include "awb/provides/starter_device.h"
#include "awb/provides/li_base_types.h"
#include "awb/provides/multifpga_switch.h"
#include "awb/provides/umf.h"

using namespace std;

// constructor
CONNECTED_APPLICATION_CLASS::CONNECTED_APPLICATION_CLASS(
    VIRTUAL_PLATFORM vp)
{

}

// destructor
CONNECTED_APPLICATION_CLASS::~CONNECTED_APPLICATION_CLASS()
{

}

void
CONNECTED_APPLICATION_CLASS::Init()
{
}

#ifdef MODEL_CLOCK_FREQ
    UINT64 fpga_freq    = MODEL_CLOCK_FREQ;
#elif (defined(MODEL_CLOCK_MULTIPLIER) && defined(MODEL_CLOCK_DIVIDER) && defined(CRYSTAL_CLOCK_FREQ))
    // Assume 50MHz base clock
    UINT64 fpga_freq    = (CRYSTAL_CLOCK_FREQ * MODEL_CLOCK_MULTIPLIER) / MODEL_CLOCK_DIVIDER;
#else
    UINT64 fpga_freq    = 0;
#endif

void printTime(timespec start, timespec finish)
{

    timespec temp;
    if ((finish.tv_nsec-start.tv_nsec)<0) {
        temp.tv_sec = finish.tv_sec-start.tv_sec-1;
        temp.tv_nsec = 1000000000+finish.tv_nsec-start.tv_nsec;
    } else {
        temp.tv_sec = finish.tv_sec-start.tv_sec;
        temp.tv_nsec = finish.tv_nsec-start.tv_nsec;
    }

    cout << "Software timing:  " << endl;
    cout << "Seconds waiting " << temp.tv_sec << endl;
    cout << "Nanoseconds waiting " << temp.tv_nsec << endl;

    cout << "Got " << TOTAL_CHUNKS << " in  CPUs time Throughput: " << (sizeof(UMF_CHUNK) * TOTAL_CHUNKS)/((float)(temp.tv_sec + ((float) temp.tv_nsec)/1000000000)) << endl;

}

void * READER_THREAD(void *argv)
{
    LI_CHANNEL_RECV_CLASS<UINT128> *input = (LI_CHANNEL_RECV_CLASS<UINT128>*) argv; 

    UINT64 cycleList[TOTAL_CHUNKS];

    UINT128 cyclesBegin; 
    UINT128 cyclesEnd; 
    
    UINT64 chunksReceived = 1;

    input->pop(cyclesBegin);
    cycleList[0] = cyclesBegin;
    
    while (chunksReceived < TOTAL_CHUNKS) 
    {   
        input->pop(cyclesEnd);
        cycleList[chunksReceived] = cyclesEnd;
        chunksReceived++;
        
    }

    cout << "Hardware timing:  " << endl;
    cout << "Got " << TOTAL_CHUNKS << " in " << (float)(cyclesEnd - cyclesBegin) << " FPGA cycles Throughput: " << (sizeof(UMF_CHUNK) * TOTAL_CHUNKS)/((float)(cyclesEnd - cyclesBegin)/((float) fpga_freq))<< endl;

    if(VERBOSE) 
    { 
        for(UINT32 i = 0; i < TOTAL_CHUNKS; i++) 
        {
            cout << "CYCLE:" << i <<  ":" << cycleList[i]<<endl; 
        }
    }

}

// main
void
CONNECTED_APPLICATION_CLASS::Main()
{
    std::string inputName("FPGATOCPU");
    LI_CHANNEL_RECV_CLASS<UINT128> input(inputName);
    std::string outputName("CPUTOFPGA");
    LI_CHANNEL_SEND_CLASS<UINT128> output(outputName);

    FLOWCONTROL_LI_CHANNEL_OUT_CLASS::retryThreshold = 1;

    for(UINT32 runs = 0; runs < 1; runs++)
    {

        // This code can be used to test thresholds for busy waiting on flowcontrol credits.

        if(runs%10 == 0)
	{
            FLOWCONTROL_LI_CHANNEL_OUT_CLASS::retryThreshold *= 10;
  	    cout << "Setting threshold to " << FLOWCONTROL_LI_CHANNEL_OUT_CLASS::retryThreshold << endl;
	}

        //
        // Bi-directional Test
        //

        UINT128 cyclesBegin; 
        UINT128 cyclesEnd; 
	timespec start, finish;

        cout << "Bi-directional Test" << endl;

        pthread_t readerThread;
        // create the reader thread
  
        if (pthread_create(&readerThread,
   	  	           NULL,
		           READER_THREAD,
		           &input))
        {
            perror("pthread_create, READER_THREAD:");
	    exit(1);
        }


	clock_gettime(CLOCK_REALTIME, &start);
        for (UINT128 chunksSent = 0; chunksSent < TOTAL_CHUNKS; chunksSent++) 
        {
            output.push(chunksSent);
        }

        pthread_join(readerThread, NULL);
	clock_gettime(CLOCK_REALTIME, &finish);
        printTime(start, finish);
        //
        // Read-only test
        //

        cout << "Read-only Test" << endl;

        if (pthread_create(&readerThread,
    		           NULL,
		           READER_THREAD,
		           &input))    
        {
            perror("pthread_create, READER_THREAD:");
   	    exit(1);
        }

	clock_gettime(CLOCK_REALTIME, &start);
        output.push(cyclesBegin);

        pthread_join(readerThread, NULL);
	clock_gettime(CLOCK_REALTIME, &finish);
        printTime(start, finish);
 

        //
        // Write-only test
        //

        cout << "Write-only Test" << endl;

	clock_gettime(CLOCK_REALTIME, &start);
        for (UINT128 chunksSent = 0; chunksSent < TOTAL_CHUNKS; chunksSent++) 
        {
            output.push(chunksSent);

            if(VERBOSE)
	    {
                cout << "Sending: " << (UINT64)chunksSent << endl;
	    }
        }

        input.pop(cyclesBegin);
        input.pop(cyclesEnd);
	clock_gettime(CLOCK_REALTIME, &finish);

        cout << "Hardware timing:  " << endl;
        cout << "Got " << TOTAL_CHUNKS << " in " << (float)(cyclesEnd - cyclesBegin) << " FPGA cycles Throughput: " << (sizeof(UMF_CHUNK) * TOTAL_CHUNKS)/((float)(cyclesEnd - cyclesBegin)/((float) fpga_freq))<< endl;

        printTime(start, finish);

    }

    // Tell the starter device that we finished                                                                          
    STARTER_DEVICE_SERVER_CLASS::GetInstance()->End(0);
}
