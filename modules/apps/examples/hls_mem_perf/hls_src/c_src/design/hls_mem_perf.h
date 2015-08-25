#ifndef _LEAP_AP_TEST_H_
#define _LEAP_AP_TEST_H_

#include "ap_int.h"

typedef ap_uint<104> InstType;
typedef ap_uint<64>  DataType;

void hls_mem_perf(volatile DataType *mem0, volatile InstType *inst, volatile int *result);

#endif



