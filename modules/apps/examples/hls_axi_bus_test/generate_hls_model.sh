#!/bin/bash

PYTHON_SCRIPT="../../../../scripts/hls/hlsModelGen.py"

NUKE_MODEL=false
BUILD_HLS_MODEL=false
BUILD_LEAP_MODEL=false
BUILD_ALL=false

printUsage() { 
    echo "Usage: generate_hls_model.sh [options]";
    echo "       -c, --clean           Clean generated project and files ";
    echo "       -v, --gen-verilog     Run vivado_hls to generate verilog files";
    echo "       -l, --gen-leap-model  Generate wrappers and leap model";
    echo "       -a, --all             Default: Run the entire flow (clean, gen-verilog, gen-leap-model)";
}

if [ $# -eq 0 ]; then
    printUsage
    exit 1
fi

for i in "$@"
do
    case $i in
        -c|--clean)
        NUKE_MODEL=true
        ;;
        -v|--gen-verilog)
        BUILD_HLS_MODEL=true
        ;;
        -l|--gen-leap-model)
        BUILD_LEAP_MODEL=true
        ;;
        -a|--all)
        BUILD_ALL=true
        ;;
        *)
        printUsage
        exit 1
        ;;
    esac
done

exe() { echo "$@" ; "$@" ; }
#exe() { echo "$@" ; }

source ./hls_model_config.sh

if [ $NUKE_MODEL == true ] || [ $BUILD_ALL == true ]; then
    echo -e "\nClean model..."
    for filename in ${GEN_VERILOG_DIR}/*; do
        exe rm -f $filename
    done
    exe rm -rf ${HLS_PROJ_DIR}/${HLS_MODULE_NAME}_proj
    exe rm -rf ${LEAP_MODEL_DIR}
fi

if [ $BUILD_HLS_MODEL == true ] || [ $BUILD_ALL == true ]; then
    echo -e "\nRun HLS to generate verilog files..."
    exe python ${PYTHON_SCRIPT} ${HLS_MODULE_NAME} ${HLS_SRC_DIR} ${HLS_TEST_BENCH_DIR} ${HLS_PROJ_DIR} ${GEN_VERILOG_DIR} ${LEAP_MODEL_DIR} --genVerilog
fi

if [ $BUILD_LEAP_MODEL == true ] || [ $BUILD_ALL == true ]; then
    echo -e "\nGenerate wrappers and leap model..."
    exe python ${PYTHON_SCRIPT} ${HLS_MODULE_NAME} ${HLS_SRC_DIR} ${HLS_TEST_BENCH_DIR} ${HLS_PROJ_DIR} ${GEN_VERILOG_DIR} ${LEAP_MODEL_DIR} --genModel --modelName ${LEAP_MODEL_NAME} --memAddr ${LEAP_MEM_ADDR_SIZE} --memData ${LEAP_MEM_DATA_SIZE}
fi

