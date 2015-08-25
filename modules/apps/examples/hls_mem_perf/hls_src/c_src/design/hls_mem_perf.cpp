
#include <string.h>
#include "hls_mem_perf.h"


// Simple mixing function to swizzle write values a little bit
DataType addrMix(int addr) { return DataType(addr) + DataType(addr<<3); }

// Hls mem perf top function
void hls_mem_perf(volatile DataType *mem0, volatile InstType *inst, volatile int *result)
{
#pragma HLS INTERFACE ap_bus port=mem0
#pragma HLS INTERFACE ap_fifo port=inst
#pragma HLS INTERFACE ap_fifo port=result

    ap_uint<8> write_command = 0;
    ap_uint<8> read_command = 1;
    ap_uint<8> finish_command = 2;
    bool is_done = false;
    int test = 0;
    InstType cmd;

    while (!is_done)
    {
        cmd = inst[test];
        int addr  = 0;
        int bound  = cmd.range(103,72);
        int stride = cmd.range(71,40);
        int iterations = cmd.range(39,8);
        ap_uint<8> command = cmd.range(7,0);
        int error = 0;

        if (command == write_command)
        {
            for (int iter = 0; iter < iterations; iter++)
            {
                mem0[addr] = addrMix(addr); 
                if ((addr + stride) < (bound * stride))
                {
                    addr = (addr + stride);
                }
                else
                {
                    addr = 0;
                }
            }
            result[test] = error;
        }
        else if (command == read_command)
        {
            for (int iter = 0; iter < iterations; iter++)
            {
                DataType value = mem0[addr]; 
                if (value != addrMix(addr))
                {
                    error++;
                }
                if ((addr + stride) < (bound * stride))
                {
                    addr = (addr + stride);
                }
                else
                {
                    addr = 0;
                }

            }
            result[test] = error;
        }
        else if (command == finish_command)
        {
            is_done = true;
        }
        test++;
    }
}

