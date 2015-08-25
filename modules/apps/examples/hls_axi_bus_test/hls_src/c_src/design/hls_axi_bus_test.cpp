
#include <string.h>
#include "hls_axi_bus_test.h"

void hls_axi_bus_test(int *mem0)
{
#pragma HLS INTERFACE m_axi port=mem0
	
    int buf[32];
    
	// initialize the external memory (pure writes)
    for (int i=0; i<128; i+=32) 
    {
        for (int k=0; k<32; k++)
        {
            buf[k] = i+k;
        }
        memcpy(mem0+i,buf,32*sizeof(int));
	}

	// reads and writes to memory
	for (int i=1; i<128; i++) 
    {
		int data_0 = mem0[i-1];
        int data_1 = mem0[i];
        int result = data_0 + data_1;
        mem0[i-1] = result;
	}

    // test memcpy read & write
    memcpy(buf,mem0,32*sizeof(int));
    memcpy(mem0+32,buf,32*sizeof(int));
}

