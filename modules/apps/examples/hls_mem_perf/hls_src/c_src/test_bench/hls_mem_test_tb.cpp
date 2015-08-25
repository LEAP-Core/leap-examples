#include <stdio.h>
#include <stdlib.h>
#include "../design/hls_mem_perf.h"

void setInstruction(InstType &inst, int ws, int d, int iter, ap_uint<8> cmd)
{
    inst.range(103,72) = ws;
    inst.range(71,40) = d;
    inst.range(39,8) = iter; 
    inst.range(7,0) = cmd;
}


int main () 
{
	DataType mem[1024];
    InstType inst[5];
    int result[5];

    setInstruction(inst[0], 16, 2, 10, 0);
    setInstruction(inst[1], 16, 2, 10, 1);
    setInstruction(inst[2], 64, 3, 10, 0);
    setInstruction(inst[3], 64, 3, 10, 1);
    setInstruction(inst[4], 64, 3, 10, 2);
    
    printf("Test start:\n");
    
	hls_mem_perf(mem, inst, result);

    for (int i=0; i<5; i++)
    {
        printf("Test %d: errors: %d\n", i, result[i]);
    }
    
    return 0;
}

