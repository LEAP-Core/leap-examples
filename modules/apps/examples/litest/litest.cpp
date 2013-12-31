/*****************************************************************************
 * litest.cpp
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
