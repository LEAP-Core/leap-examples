############################################################
## Change these for different applications
HLS_MODULE_NAME="hls_ap_bus_test"
LEAP_MODEL_NAME="hls-ap-bus-test"
############################################################

# The real address/data sizes required for leap scratchpads, 
# it can be smaller than the memory bus sizes
# If the values are set to 0, the wrapper script would
# extract size information from the memory buses
LEAP_MEM_ADDR_SIZE="0"
LEAP_MEM_DATA_SIZE="0"

HLS_SRC_DIR="./hls_src/c_src/design"
HLS_TEST_BENCH_DIR="./hls_src/c_src/test_bench"
HLS_PROJ_DIR="./hls_src"
GEN_VERILOG_DIR="./hls_src/generated_verilog"
LEAP_MODEL_DIR="./leap_model"

