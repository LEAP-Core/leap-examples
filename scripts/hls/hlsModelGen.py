import os
import argparse
import sys
import fileinput
import re
import inspect
import glob
import shutil
import math

import moduleParser
import hlsWrapperGen
import topAwbGen

def createDirs(root, relPath):
    relpath_list = relPath.split(os.sep)
    top = root
    for dirName in relpath_list:
        path = os.path.join (top, dirName)
        if not os.path.exists(path):
            # print ('mkdir %s' %path)
            os.makedirs(path)
        top = path

def createSymlink (srcDir, destDir, fileName):
    src_dir_rel = os.path.relpath(srcDir, destDir)
    if not os.path.exists(os.path.join(destDir, fileName)):
        os.symlink(os.path.join(src_dir_rel, fileName), os.path.join(destDir, fileName))

def removeTimescale(file):
    for line in fileinput.input(file, inplace=True):
        s0 = re.search( r'timescale', line, re.M|re.I)
        if s0:
            continue
        print line.rstrip()

def copyVerilog(projPath, verilogDir):
    if not os.path.exists(projPath):
        print "Hls project \"" + os.path.basename(projPath) + "\" not found"
        sys.exit()
    else: 
        print "copy generated verilog files from hls project folder: " + projPath
        files = glob.glob(os.path.join(projPath, "solution1/syn/verilog/*.v"))
        for f in files: 
            print "copying file " + f
            shutil.copy2(f, verilogDir)
            # remove timescale
            removeTimescale(os.path.join(verilogDir, os.path.basename(f)))

def genVerilog(topModuleName, hlsSrcDir, testbenchDir, hlsProjDir, verilogDir):
    
    scriptDir = os.path.abspath(os.path.split(inspect.getfile( inspect.currentframe() ))[0])

    srcDir = os.path.relpath(os.path.abspath(hlsSrcDir), os.path.abspath(hlsProjDir))
    tbDir = os.path.relpath(os.path.abspath(testbenchDir), os.path.abspath(hlsProjDir))
    vDir = os.path.relpath(os.path.abspath(verilogDir), os.path.abspath(hlsProjDir))

    # run tcl to generate verilog files
    os.environ["HLS_MODULE_NAME"] = topModuleName
    os.environ["HLS_PROJ_NAME"] = topModuleName + "_proj"
    os.environ["HLS_SRC_DIR"] = srcDir
    os.environ["HLS_TEST_BENCH_DIR"] = tbDir

    baseDir = os.getcwd()
    os.chdir(hlsProjDir)

    os.system("vivado_hls -f " + scriptDir + "/run_hls.tcl")

    del os.environ["HLS_MODULE_NAME"]
    del os.environ["HLS_PROJ_NAME"]
    del os.environ["HLS_SRC_DIR"]
    del os.environ["HLS_TEST_BENCH_DIR"]

    os.chdir(baseDir)
   
    # copy generated verilog files from hls project folder
    projPath = os.path.join(hlsProjDir, topModuleName) + "_proj"
    copyVerilog(projPath, verilogDir)

def leapWrapperGen(moduleInfo, leapDir):
    leapDir = os.path.relpath(os.path.abspath(leapDir), os.path.abspath('.'))
    
    # generate verilog wrapper
    verilogWrapperFile = open(os.path.join(leapDir, "hls_core_verilog_wrapper.v"), 'w')
    hlsWrapperGen.genVerilogWrapper(moduleInfo, verilogWrapperFile)    
    verilogWrapperFile.close()

    # generate bluespec wrapper
    bluespecWrapperFile = open(os.path.join(leapDir, "hls-core-bsv-wrapper.bsv"), 'w');
    hlsWrapperGen.genBluespecInternalWrapper(moduleInfo, bluespecWrapperFile)
    hlsWrapperGen.genBluespecWrapper(moduleInfo, bluespecWrapperFile)
    bluespecWrapperFile.close()

    # copy leap base files
    leapBaseDir = os.path.join(os.path.realpath(os.path.abspath(os.path.split(inspect.getfile( inspect.currentframe() ))[0])), "../../modules/leap_base/")
    files = glob.glob(leapBaseDir + "/*.bsv")
    files += glob.glob(leapBaseDir + "/*.v")
    files += glob.glob(leapBaseDir + "/*.dic")
    for f in files:
        shutil.copy2(f, leapDir)

def awbGen(moduleInfo, leapDir, testName, memAddrSize, memDataSize):
    leapDir = os.path.relpath(os.path.abspath(leapDir), os.path.abspath('.'))
    if memDataSize == 0:
        if (len(moduleInfo['axiPorts']['dataSize']) + len(moduleInfo['apBusPorts']['dataSize'])) > 0:
            memDataSize = max(moduleInfo['axiPorts']['dataSize']+moduleInfo['apBusPorts']['dataSize'])
        else:
            memDataSize = 32
    if memAddrSize == 0:
        if (len(moduleInfo['axiPorts']['addrSize']) + len(moduleInfo['apBusPorts']['addrSize'])) > 0:
            addr_sizes = []
            for i, addr in enumerate(moduleInfo['apBusPorts']['addrSize']):
                data_size = moduleInfo['apBusPorts']['dataSize'][i]
                if data_size > memDataSize:
                    addr_sizes.append(addr + int(math.log((data_size/memDataSize), 2)))
                else:
                    addr_sizes.append(addr - int(math.log((memDataSize/data_size), 2)))
            for addr in moduleInfo['axiPorts']['addrSize']:
                addr_sizes.append(addr - int(math.log((memDataSize/8), 2)))
            memAddrSize = max(addr_sizes)
        else:
            memAddrSize = 32
    
    leapBaseDir = os.path.join(os.path.realpath(os.path.abspath(os.path.split(inspect.getfile( inspect.currentframe() ))[0])), "../..//modules/leap_base/")
    awbBaseFile = open(os.path.join(leapBaseDir, "leap-hls-mem-test-base.awb"), 'r')
    awbFile = open(os.path.join(leapDir, testName + ".awb"), 'w')
    topAwbGen.awbFileGen(testName, moduleInfo, memAddrSize, memDataSize, leapDir, awbBaseFile, awbFile)
    awbBaseFile.close()
    awbFile.close()

def genModel(topModuleName, verilogDir, modelDir, modelName):
    
    # extract generated verilog top module
    # moduleParser.debug = True
    top_module_path = os.path.join(verilogDir, topModuleName) + ".v"
    module_info = moduleParser.getModuleInfoFromFile(top_module_path)
    #print module_info

    # generate wrappers
    leapWrapperGen(module_info, modelDir)

    # link verilog files
    files = glob.glob(verilogDir + "/*.v")
    for f in files:
        createSymlink(verilogDir, modelDir, os.path.basename(f))

    # generate top awb file
    awbGen(module_info, modelDir, modelName, args.memAddr, args.memData)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("topModuleName",   type=str, help="the name of hls top module")
    parser.add_argument("hlsSrcDir",       type=str, help="the directory containing hls c programs")
    parser.add_argument("hlsTestbenchDir", type=str, help="the directory containing hls testbench files")
    parser.add_argument("hlsProjDir",      type=str, help="the directory containing the hls project")
    parser.add_argument("verilogDir",      type=str, help="the directory containing generated verilog files")
    parser.add_argument("leapModelDir",    type=str, help="the output directory for the generated leap model")
    parser.add_argument("--genVerilog",    action='store_true', help="run vivado hls to generate verilog files")
    parser.add_argument("--genModel",      action='store_true', help="generate wrappers and leap model")
    parser.add_argument("--modelName",     type=str, default="leap-hls-mem-test", help="the leap model name")
    parser.add_argument("--memAddr",       type = int, default=0, help="leap memory address bits")
    parser.add_argument("--memData",       type = int, default=0, help="leap memory data bits")
    
    args = parser.parse_args()
    
    if args.genVerilog: 
        genVerilog(args.topModuleName, args.hlsSrcDir, args.hlsTestbenchDir, args.hlsProjDir, args.verilogDir)
    elif len(glob.glob(args.verilogDir + "/*.v")) == 0:
        projPath = os.path.join(args.hlsProjDir, args.topModuleName) + "_proj"
        copyVerilog(projPath, args.verilogDir)
    
    if args.genModel:
        # create an output directory for leap model files and link associate v/vhd files
        createDirs(".", args.leapModelDir)
        genModel(args.topModuleName, args.verilogDir, args.leapModelDir, args.modelName)


