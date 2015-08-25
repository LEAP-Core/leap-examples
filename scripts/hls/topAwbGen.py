import re
import os
import glob

def awbFileGen(modelName, moduleInfo, addrSize, dataSize, leapDir, inFileHandle, outFileHandle):
    
    apNum = len(moduleInfo['apBusPorts']['list'])
    axiNum = len(moduleInfo['axiPorts']['list'])
    apAddrSize = moduleInfo['apBusPorts']['addrSize']
    apDataSize = moduleInfo['apBusPorts']['dataSize']
    axiAddrSize = moduleInfo['axiPorts']['addrSize']
    axiDataSize = moduleInfo['axiPorts']['dataSize']
    axiIdSize = moduleInfo['axiPorts']['idSize']
    apInFifoDataSize = moduleInfo['apInFifoPorts']['dataSize']
    apOutFifoDataSize = moduleInfo['apOutFifoPorts']['dataSize']

    testName = modelName

    assert len(apAddrSize) == apNum
    assert len(axiAddrSize) == axiNum

    num = apNum + axiNum
    vFiles = glob.glob(leapDir + "/*.v")
    bsvFiles = glob.glob(leapDir + "/*.bsv")
    dicFiles = glob.glob(leapDir + "/*.dic")

    parameterLines = ""

    for line in inFileHandle:
        s0 = re.search( r'%param --global (\S*)(\s+)(\d+)(.*)', line, re.M|re.I)

        if s0:  
            if s0.group(1) == "MEMORY_ADDR_BITS" and addrSize != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(addrSize) + s0.group(4) + "\n"
            elif s0.group(1) == "TEST_DATA_BITS" and dataSize != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(dataSize) + s0.group(4) + "\n"
            elif s0.group(1) == "MEM_TEST_MEMORY_PORT_NUM" and num != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(num) + s0.group(4) + "\n"
            elif s0.group(1) == "MEM_TEST_MULTI_PORT_MEM_ENABLE" and num != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(int(num>1)) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AP_BUS_NUM" and apNum != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(apNum) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AP_BUS_ADDR_BITS" and len(apAddrSize) != 0:
                for i in range(apNum): 
                    parameterLines += "%param --global HLS_AP_BUS" + str(i) + "_ADDR_BITS" + " " * (len(s0.group(2))-1) + str(apAddrSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AP_BUS_DATA_BITS" and len(apDataSize) != 0:
                for i in range(apNum): 
                    parameterLines += "%param --global HLS_AP_BUS" + str(i) + "_DATA_BITS" + " " * (len(s0.group(2))-1) + str(apDataSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AXI_BUS_NUM" and axiNum != 0:
                parameterLines += "%param --global " + s0.group(1) + s0.group(2) + str(axiNum) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AXI_BUS_ADDR_BITS" and len(axiAddrSize) != 0:
                for i in range(axiNum): 
                    parameterLines += "%param --global HLS_AXI_BUS" + str(i) + "_ADDR_BITS" + " " * (len(s0.group(2))-1) + str(axiAddrSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AXI_BUS_DATA_BITS" and len(axiDataSize) != 0:
                for i in range(axiNum): 
                    parameterLines += "%param --global HLS_AXI_BUS" + str(i) + "_DATA_BITS" + " " * (len(s0.group(2))-1) + str(axiDataSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AXI_BUS_ID_BITS" and len(axiIdSize) != 0:
                for i in range(axiNum): 
                    parameterLines += "%param --global HLS_AXI_BUS" + str(i) + "_ID_BITS" + " " * (len(s0.group(2))-1) + str(axiIdSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AP_IN_FIFO_DATA_BITS" and len(apInFifoDataSize) != 0:
                for i in range(len(apInFifoDataSize)): 
                    parameterLines += "%param --global HLS_AP_IN_FIFO" + str(i) + "_DATA_BITS" + " " * (len(s0.group(2))-1) + str(apInFifoDataSize[i]) + s0.group(4) + "\n"
            elif s0.group(1) == "HLS_AP_OUT_FIFO_DATA_BITS" and len(apOutFifoDataSize) != 0:
                for i in range(len(apOutFifoDataSize)): 
                    parameterLines += "%param --global HLS_AP_OUT_FIFO" + str(i) + "_DATA_BITS" + " " * (len(s0.group(2))-1) + str(apOutFifoDataSize[i]) + s0.group(4) + "\n"
            else:
                parameterLines += line
        elif re.search( r'%param --dynamic .*', line, re.M|re.I):
            parameterLines += line

    testName = testName.replace('-', ' ')
    testName = testName.replace('_', ' ')
    testName = testName.upper()
    outFileHandle.write("%name " + testName + " generated AWB\n")
    outFileHandle.write("%desc " + testName + " generated AWB\n\n")
    outFileHandle.write("%attributes hls_mem_test test\n\n")
    outFileHandle.write("%provides hardware_system\n\n")
    
    outFileHandle.write("\n")

    for f in bsvFiles:
        outFileHandle.write("%sources -t BSV     -v PUBLIC " + os.path.basename(f) + "\n")
    for f in vFiles:
        outFileHandle.write("%sources -t VERILOG -v PUBLIC " + os.path.basename(f) + "\n")
    for f in dicFiles:
        outFileHandle.write("%sources -t DICT    -v PUBLIC " + os.path.basename(f) + "\n")
    
    outFileHandle.write("\n")
    outFileHandle.write(parameterLines)
    outFileHandle.write("\n")
    outFileHandle.write("\n%param SYNTH_BOUNDARY mkSystem \"name of synthesis boundary\"\n\n")

