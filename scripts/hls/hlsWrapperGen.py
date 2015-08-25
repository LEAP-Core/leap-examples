
def printVerilogParameters(fileHandle, busType, busList, portInfo, prefix, isFirst):
    if len(busList) > 0:
        for idx, val in enumerate(portInfo['dataSize']):
            if idx > 0 or not isFirst:
                fileHandle.write(",\n")
            fileHandle.write("    parameter " + prefix + str(idx) + "_DATA_WIDTH = " + str(val))
            if busType == "ap_bus" or busType == "axi_bus": 
                fileHandle.write(",\n" + "    parameter " + prefix + str(idx) + "_ADDR_WIDTH = " + str(portInfo['addrSize'][idx]))
            if busType == "axi_bus":
                fileHandle.write(",\n" + "    parameter " + prefix + str(idx) + "_ID_WIDTH = " + str(portInfo['idSize'][idx]))

def genVerilogWrapper(moduleInfo, fileHandle):
    apBusList = moduleInfo['apBusPorts']['list']  
    axiBusList = moduleInfo['axiPorts']['list']
    apInFifoList = moduleInfo['apInFifoPorts']['list']
    apOutFifoList = moduleInfo['apOutFifoPorts']['list']

    axiBusWstrbSize = [ x/8 for x in moduleInfo['axiPorts']['dataSize'] ]
    fileHandle.write("// Verilog wrapper for the HLS core\n\nmodule hls_core_verilog_wrapper\n")
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("#(\n")
        printVerilogParameters(fileHandle, "ap_bus", apBusList, moduleInfo['apBusPorts'], "AP", True)
        printVerilogParameters(fileHandle, "axi_bus", axiBusList, moduleInfo['axiPorts'], "AXI", len(apBusList) == 0)
        printVerilogParameters(fileHandle, "ap_in_fifo", apInFifoList, moduleInfo['apInFifoPorts'], "AP_IN_FIFO", len(apBusList) + len(axiBusList) == 0)
        printVerilogParameters(fileHandle, "ap_out_fifo", apOutFifoList, moduleInfo['apOutFifoPorts'], "AP_OUT_FIFO", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0)
        fileHandle.write("\n)\n(\n")
    else:
        fileHandle.write("(\n")

    fileHandle.write("    input   ap_clk,\n")
    fileHandle.write("    input   ap_rst_n,\n")
    fileHandle.write("    input   ap_start,\n")
    fileHandle.write("    output  ap_done,\n")
    fileHandle.write("    output  ap_idle,\n")
    
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("    output  ap_ready,\n")
    else:
        fileHandle.write("    output  ap_ready\n);\n\n")

    if len(apBusList) > 0:
        for i, m in enumerate(apBusList):  
            fileHandle.write("    input   " + m + "_req_full_n,\n")
            fileHandle.write("    input   " + m + "_rsp_empty_n,\n")
            fileHandle.write("    output  " + m + "_req_write,\n")
            fileHandle.write("    output  " + m + "_req_din,\n")
            fileHandle.write("    output  [AP" + str(i) + "_ADDR_WIDTH-1:0] " + m + "_address,\n")
            fileHandle.write("    output  [AP" + str(i) + "_ADDR_WIDTH-1:0] " + m + "_size,\n")
            fileHandle.write("    input   [AP" + str(i) + "_DATA_WIDTH-1:0] " + m + "_datain,\n")
            if i == (len(apBusList)-1) and len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0: 
                fileHandle.write("    output  [AP" + str(i) + "_DATA_WIDTH-1:0] " + m + "_dataout\n);\n\n")
            else:
                fileHandle.write("    output  [AP" + str(i) + "_DATA_WIDTH-1:0] " + m + "_dataout,\n")
    if len(axiBusList) > 0:
        for i, m in enumerate(axiBusList):  
            fileHandle.write("    output  " + m + "_AWVALID,\n")
            fileHandle.write("    input   " + m + "_AWREADY,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_ADDR_WIDTH-1:0] " + m + "_AWADDR,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_ID_WIDTH-1:0]   " + m + "_AWID,\n")
            fileHandle.write("    output  [7:0]  " + m + "_AWLEN,\n")
            fileHandle.write("    output  [2:0]  " + m + "_AWSIZE,\n")
            fileHandle.write("    output  [1:0]  " + m + "_AWBURST,\n")
            fileHandle.write("    output  " + m + "_WVALID,\n")
            fileHandle.write("    input   " + m + "_WREADY,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_DATA_WIDTH-1:0] " + m + "_WDATA,\n")
            fileHandle.write("    output  [" + str(axiBusWstrbSize[i]-1) + ":0]  " + m + "_WSTRB,\n")
            fileHandle.write("    output  " + m + "_WLAST,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_ID_WIDTH-1:0]   " + m + "_WID,\n")
            fileHandle.write("    output  " + m + "_ARVALID,\n")
            fileHandle.write("    input   " + m + "_ARREADY,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_ADDR_WIDTH-1:0] " + m + "_ARADDR,\n")
            fileHandle.write("    output  [AXI" + str(i) + "_ID_WIDTH-1:0]   " + m + "_ARID,\n")
            fileHandle.write("    output  [7:0]  " + m + "_ARLEN,\n")
            fileHandle.write("    output  [2:0]  " + m + "_ARSIZE,\n")
            fileHandle.write("    output  [1:0]  " + m + "_ARBURST,\n")
            fileHandle.write("    input   " + m + "_RVALID,\n")
            fileHandle.write("    output  " + m + "_RREADY,\n")
            fileHandle.write("    input   [AXI" + str(i) + "_DATA_WIDTH-1:0] " + m + "_RDATA,\n")
            fileHandle.write("    input   " + m + "_RLAST,\n")
            fileHandle.write("    input   [AXI" + str(i) + "_ID_WIDTH-1:0]  " + m + "_RID,\n")
            fileHandle.write("    input   [1:0]  " + m + "_RRESP,\n")
            fileHandle.write("    input   " + m + "_BVALID,\n")
            fileHandle.write("    output  " + m + "_BREADY,\n")
            fileHandle.write("    input   [1:0]  " + m + "_BRESP,\n")
            if i == (len(axiBusList)-1) and len(apInFifoList) + len(apOutFifoList) == 0: 
                fileHandle.write("    input   [AXI" + str(i) + "_ID_WIDTH-1:0]  " + m + "_BID\n);\n\n")
            else: 
                fileHandle.write("    input   [AXI" + str(i) + "_ID_WIDTH-1:0]  " + m + "_BID,\n")
    if len(apInFifoList) > 0:
        for i, m in enumerate(apInFifoList):  
            fileHandle.write("    input   [AP_IN_FIFO" + str(i) + "_DATA_WIDTH-1:0] " + m + "_dout,\n")
            fileHandle.write("    input   " + m + "_empty_n,\n")
            if i == (len(apInFifoList)-1) and len(apOutFifoList) == 0: 
                fileHandle.write("    output  " + m + "_read\n);\n\n")
            else:
                fileHandle.write("    output  " + m + "_read,\n")
    if len(apOutFifoList) > 0:
        for i, m in enumerate(apOutFifoList):  
            fileHandle.write("    output  [AP_OUT_FIFO" + str(i) + "_DATA_WIDTH-1:0] " + m + "_din,\n")
            fileHandle.write("    input   " + m + "_full_n,\n")
            if i == (len(apOutFifoList)-1): 
                fileHandle.write("    output  " + m + "_write\n);\n\n")
            else:
                fileHandle.write("    output  " + m + "_write,\n")
    
    # ap bus wires
    ap_bus_subports = moduleInfo['apBusPorts']['subports']
    if len(apBusList) > 0:
        fileHandle.write("\n    // ap_bus wires\n")
        for i, m in enumerate(apBusList):  
            fileHandle.write("    wire                        " + m + "_rsp_read;\n") 
    
    # ap input fifo wires
    ap_in_fifo_subports = moduleInfo['apInFifoPorts']['subports']
    
    # ap output fifo wires
    ap_out_fifo_subports = moduleInfo['apOutFifoPorts']['subports']

    # axi bus wires
    axi_unused_subports = [ "AWLOCK", "AWCACHE", "AWPROT", "AWREGION", "AWUSER", 
                            "ARLOCK", "ARCACHE", "ARPROT", "ARQOS", "ARREGION", "ARUSER" ]
    axi_subports = moduleInfo['axiPorts']['subports']
    
    if len(axiBusList) > 0:
        fileHandle.write("\n    // axi4 bus wires\n")
        for m in axiBusList:
            for p in axi_unused_subports:
                if moduleInfo['ports'][m][p]['name']:
                    if len(moduleInfo['ports'][m][p]['bitrange']) == 0:
                        fileHandle.write("    wire        " + m + "_" + p + ";\n")
                    else:
                        fileHandle.write("    wire  " + moduleInfo['ports'][m][p]['bitrange'] + " " + m + "_" + p + ";\n")
            
    fileHandle.write("\n")
    fileHandle.write("    " + moduleInfo['name'] + " hls_top (\n")
    fileHandle.write("        ." + moduleInfo['ports']['controlPort']['clk']['name'] + " (ap_clk),\n")
    fileHandle.write("        ." + moduleInfo['ports']['controlPort']['(reset|rst)']['name'] + " (ap_rst_n),\n")
    if moduleInfo['ports']['controlPort']['start']['name']:
        fileHandle.write("        ." + moduleInfo['ports']['controlPort']['start']['name'] + " (ap_start),\n")
    if moduleInfo['ports']['controlPort']['done']['name']:
        fileHandle.write("        ." + moduleInfo['ports']['controlPort']['done']['name'] + " (ap_done),\n")
    if moduleInfo['ports']['controlPort']['idle']['name']:
        fileHandle.write("        ." + moduleInfo['ports']['controlPort']['idle']['name'] + " (ap_idle),\n")
    if moduleInfo['ports']['controlPort']['ap_ready']['name']:
        fileHandle.write("        ." + moduleInfo['ports']['controlPort']['ap_ready']['name'] + " (ap_ready),\n")

    if len(apBusList) > 0:
        for i, m in enumerate(apBusList): 
            ap_bus_ports_names = []
            ap_bus_ports = []
            for p in ap_bus_subports:
                if moduleInfo['ports'][m][p]['name']:
                    ap_bus_ports_names.append(moduleInfo['ports'][m][p]['name'])
                    ap_bus_ports.append(p)
            for j, p in enumerate(ap_bus_ports):
                if j == (len(ap_bus_ports) - 1):
                    continue
                elif p == "RSP_READ":
        	        fileHandle.write("        ." + ap_bus_ports_names[j] + " (" + m + "_" + p.lower() + "), //not used\n")
                else:
        	        fileHandle.write("        ." + ap_bus_ports_names[j] + " (" + m + "_" + p.lower() + "),\n")
            
            if i == (len(apBusList)-1) and len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0: 
                fileHandle.write("        ." + ap_bus_ports_names[len(ap_bus_ports)-1] + " (" + m + "_" + ap_bus_ports[len(ap_bus_ports)-1].lower() + ")\n    );\n\nendmodule\n")
            else:
        	    fileHandle.write("        ." + ap_bus_ports_names[len(ap_bus_ports)-1] + " (" + m + "_" + ap_bus_ports[len(ap_bus_ports)-1].lower() + "),\n")
    
    if len(axiBusList) > 0:
        for i, m in enumerate(axiBusList):
            axi_bus_ports_names = []
            axi_bus_ports = []
            for p in axi_subports:
                if moduleInfo['ports'][m][p]['name']:
                    axi_bus_ports_names.append(moduleInfo['ports'][m][p]['name'])
                    axi_bus_ports.append(p)
            for j, p in enumerate(axi_bus_ports):
                if j == (len(axi_bus_ports) - 1):
                    continue
                elif p in axi_unused_subports: 
        	        fileHandle.write("        ." + axi_bus_ports_names[j] + " (" + m + "_" + p + "), //not used\n")
                else:
        	        fileHandle.write("        ." + axi_bus_ports_names[j] + " (" + m + "_" + p + "),\n")

            if i == (len(axiBusList)-1) and len(apInFifoList) + len(apOutFifoList) == 0: 
	            fileHandle.write("        ." + axi_bus_ports_names[len(axi_bus_ports)-1] + " (1'b0) //not used\n    );\n\nendmodule\n")
            else:
	            fileHandle.write("        ." + axi_bus_ports_names[len(axi_bus_ports)-1] + " (1'b0), //not used\n")
    
    if len(apInFifoList) > 0:
        for i, m in enumerate(apInFifoList):
            ap_in_fifo_ports_names = []
            ap_in_fifo_ports = []
            for p in ap_in_fifo_subports:
                if moduleInfo['ports'][m][p]['name']:
                    ap_in_fifo_ports_names.append(moduleInfo['ports'][m][p]['name'])
                    ap_in_fifo_ports.append(p)
            for j, p in enumerate(ap_in_fifo_ports):
                if j == (len(ap_in_fifo_ports) - 1):
                    continue
                else:
        	        fileHandle.write("        ." + ap_in_fifo_ports_names[j] + " (" + m + "_" + p.lower() + "),\n")

            if i == (len(apInFifoList)-1) and len(apOutFifoList) == 0: 
        	    fileHandle.write("        ." + ap_in_fifo_ports_names[len(ap_in_fifo_ports)-1] + " (" + m + "_" + ap_in_fifo_ports[len(ap_in_fifo_ports)-1].lower() + ")\n    );\n\nendmodule\n")
            else:
        	    fileHandle.write("        ." + ap_in_fifo_ports_names[len(ap_in_fifo_ports)-1] + " (" + m + "_" + ap_in_fifo_ports[len(ap_in_fifo_ports)-1].lower() + "),\n")
    
    if len(apOutFifoList) > 0:
        for i, m in enumerate(apOutFifoList):
            ap_out_fifo_ports_names = []
            ap_out_fifo_ports = []
            for p in ap_out_fifo_subports:
                if moduleInfo['ports'][m][p]['name']:
                    ap_out_fifo_ports_names.append(moduleInfo['ports'][m][p]['name'])
                    ap_out_fifo_ports.append(p)
            for j, p in enumerate(ap_out_fifo_ports):
                if j == (len(ap_out_fifo_ports) - 1):
                    continue
                else:
        	        fileHandle.write("        ." + ap_out_fifo_ports_names[j] + " (" + m + "_" + p.lower() + "),\n")

            if i == (len(apOutFifoList)-1): 
        	    fileHandle.write("        ." + ap_out_fifo_ports_names[len(ap_out_fifo_ports)-1] + " (" + m + "_" + ap_out_fifo_ports[len(ap_out_fifo_ports)-1].lower() + ")\n    );\n\nendmodule\n")
            else:
        	    fileHandle.write("        ." + ap_out_fifo_ports_names[len(ap_out_fifo_ports)-1] + " (" + m + "_" + ap_out_fifo_ports[len(ap_out_fifo_ports)-1].lower() + "),\n")

def modifyBusName(name):
    new_name = ""
    for i, n in enumerate(name.split('_')):
        if i == 0:
            new_name += n.lower()
        else:
            new_name += n.lower().capitalize()
    return new_name

def printBsvWrapperParameters(fileHandle, header, tail, spaceNum, busType, busList, prefix, suffix, isFirst, isLast):
    if len(busList) > 0:
        for i in range(len(busList)): 
            if i == 0 and isFirst:
                if busType == "ap_bus" or busType == "axi_bus":
                    fileHandle.write(header + prefix + str(i) + "_ADDR_" + suffix + ",\n")
                    if i == (len(busList) - 1) and isLast: 
                        if busType == "ap_bus":  
                            fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + tail)
                        else: 
                            fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + ",\n")
                            fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ID_" + suffix + tail)
                    else: 
                        fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + ",\n")
                        if busType == "axi_bus": 
                            fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ID_" + suffix + ",\n")
                elif i == (len(busList) - 1) and isLast: 
                    fileHandle.write(header + "t_" + prefix + str(i) + "_DATA_" + suffix + tail)
                else:
                    fileHandle.write(header + "t_" + prefix + str(i) + "_DATA_" + suffix + ",\n")
            elif i == (len(busList) - 1) and isLast:
                if busType == "axi_bus":
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ADDR_" + suffix + ",\n")
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + ",\n")
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ID_" + suffix + tail)
                else:
                    if busType == "ap_bus":
                        fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ADDR_" + suffix + ",\n")
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + tail)
            else: 
                if busType == "ap_bus" or busType == "axi_bus":
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ADDR_" + suffix + ",\n")
                fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_DATA_" + suffix + ",\n")
                if busType == "axi_bus":
                    fileHandle.write(" "*spaceNum + header + prefix + str(i) + "_ID_" + suffix + ",\n")

def genBluespecInternalWrapper(moduleInfo, fileHandle):
    
    apBusList = moduleInfo['apBusPorts']['list']  
    axiBusList = moduleInfo['axiPorts']['list']
    apInFifoList = moduleInfo['apInFifoPorts']['list']
    apOutFifoList = moduleInfo['apOutFifoPorts']['list']
    
    fileHandle.write("import Vector::*;\n\n")
    fileHandle.write("// Internal Verilog HLS-core interface\n")
    
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("interface HLS_CORE_INTERNAL_IFC#(")
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 33, "ap_bus",  apBusList, "AP", "SZ", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 33, "axi_bus", axiBusList, "AXI", "SZ", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 33, "ap_fifo", apInFifoList, "AP_IN_FIFO", "SZ", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 33, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "SZ", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
    else:
        fileHandle.write("interface HLS_CORE_INTERNAL_IFC;\n")

    fileHandle.write("    // hls core control methods\n")
    fileHandle.write("    method Action start();\n")
    fileHandle.write("    method Bool isIdle();\n")
    fileHandle.write("    method Bool isDone();\n")
    fileHandle.write("    method Bool isReady();\n")
    
    if len(apBusList) > 0:
        fileHandle.write("    // hls core apBus port(s)\n")
        for i, m in enumerate(apBusList):  
            m = modifyBusName(m)
            fileHandle.write("    method Action " + m + "ReqNotFull();\n")
            fileHandle.write("    method Action " + m + "ReadRsp( Bit#(t_AP" + str(i) + "_DATA_SZ) resp);\n")
            fileHandle.write("    method Bit#(t_AP" + str(i) + "_ADDR_SZ) " + m + "ReqAddr();\n")
            fileHandle.write("    method Bit#(t_AP" + str(i) + "_ADDR_SZ) " + m + "ReqSize();\n")
            fileHandle.write("    method Bit#(t_AP" + str(i) + "_DATA_SZ) " + m + "WriteData();\n")
            fileHandle.write("    method Bool " + m + "WriteReqEn();\n")
    if len(axiBusList) > 0:
        fileHandle.write("    // hls core axiBus port(s)\n")
        for i, m in enumerate(axiBusList):
            m = modifyBusName(m)
            fileHandle.write("    // hls core axiBus " + m + " write master \n")
            fileHandle.write("    // Address outputs\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_ID_SZ) " + m + "AwId();\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_ADDR_SZ) " + m + "AwAddr();\n")
            fileHandle.write("    method Bit#(8) " + m + "AwLen();\n")
            fileHandle.write("    method Bit#(3) " + m + "AwSize();\n")
            fileHandle.write("    method AXI4BurstMode " + m + "AwBurst();\n")
            fileHandle.write("    method Bool " + m + "AwValid();\n")
            fileHandle.write("    // Address Inputs\n")
            fileHandle.write("    method Action " + m + "AwReady();\n")
            fileHandle.write("    // Data Outputs\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_ID_SZ) " + m + "WId();\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_DATA_SZ) " + m + "WData();\n")
            fileHandle.write("    method Bit#(TDiv#(t_AXI" + str(i) + "_DATA_SZ,8)) " + m + "WStrb();\n")
            fileHandle.write("    method Bool " + m + "WLast();\n")
            fileHandle.write("    method Bool " + m + "WValid();\n")
            fileHandle.write("    // Data Inputs\n")
            fileHandle.write("    method Action " + m + "WReady();\n")
            fileHandle.write("    // Response Outputs\n")
            fileHandle.write("    method Bool " + m + "BReady();\n")
            fileHandle.write("    // Response Inputs\n")
            fileHandle.write("    method Action " + m + "BId( Bit#(t_AXI" + str(i) + "_ID_SZ) id );\n")
            fileHandle.write("    method Action " + m + "BResp( AXI4Resp resp );\n")
            fileHandle.write("    method Action " + m + "BValid();\n")
            fileHandle.write("    // hls core axiBus " + m + " read master \n")
            fileHandle.write("    // Address outputs\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_ID_SZ) " + m + "ArId();\n")
            fileHandle.write("    method Bit#(t_AXI" + str(i) + "_ADDR_SZ) " + m + "ArAddr();\n")
            fileHandle.write("    method Bit#(8) " + m + "ArLen();\n")
            fileHandle.write("    method Bit#(3) " + m + "ArSize();\n")
            fileHandle.write("    method AXI4BurstMode " + m + "ArBurst();\n")
            fileHandle.write("    method Bool " + m + "ArValid();\n")
            fileHandle.write("    // Address Inputs\n")
            fileHandle.write("    method Action " + m + "ArReady();\n")
            fileHandle.write("    // Response Outputs\n")
            fileHandle.write("    method Bool " + m + "RReady();\n")
            fileHandle.write("    // Response Inputs\n")
            fileHandle.write("    method Action " + m + "RId( Bit#(t_AXI" + str(i) + "_ID_SZ) id );\n")
            fileHandle.write("    method Action " + m + "RData( Bit#(t_AXI" + str(i) + "_DATA_SZ) data );\n")
            fileHandle.write("    method Action " + m + "RResp( AXI4Resp resp );\n")
            fileHandle.write("    method Action " + m + "RLast();\n")
            fileHandle.write("    method Action " + m + "RValid();\n")
    
    if len(apInFifoList) > 0:
        fileHandle.write("    // hls core input ap_fifo port(s)\n")
        for i, m in enumerate(apInFifoList):  
            m = modifyBusName(m)
            fileHandle.write("    method Action " + m + "InputMsg (Bit#(t_AP_IN_FIFO" + str(i) + "_DATA_SZ) msg);\n")
            fileHandle.write("    method Bool " + m + "MsgReceived();\n")
            
    if len(apOutFifoList) > 0:
        fileHandle.write("    // hls core output ap_fifo port(s)\n")
        for i, m in enumerate(apOutFifoList):  
            m = modifyBusName(m)
            fileHandle.write("    method Action " + m + "NotFull();\n")
            fileHandle.write("    method Bit#(t_AP_OUT_FIFO" + str(i) + "_DATA_SZ) " + m + "OutputMsg();\n")

    fileHandle.write("endinterface\n\n")

    fileHandle.write("//\n")
    fileHandle.write("// mkHlsCoreInternal --\n")
    fileHandle.write("//     Wrapper for the Verilog HLS core.\n")
    fileHandle.write("//\n")
    fileHandle.write("import \"BVI\" hls_core_verilog_wrapper = module mkHlsCoreInternal\n")
    fileHandle.write("    // interface:\n")

    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("    (HLS_CORE_INTERNAL_IFC#(")
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 28, "ap_bus",  apBusList, "AP", "SZ", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 28, "axi_bus", axiBusList, "AXI", "SZ", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 28, "ap_fifo", apInFifoList, "AP_IN_FIFO", "SZ", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 28, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "SZ", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
    else:
        fileHandle.write("    (HLS_CORE_INTERNAL_IFC);\n\n")
    
    fileHandle.write("    // verilog parameters\n")
    for i in range(len(apBusList)):
        fileHandle.write("    parameter AP" + str(i) + "_DATA_WIDTH = valueOf(t_AP" + str(i) + "_DATA_SZ);\n")
        fileHandle.write("    parameter AP" + str(i) + "_ADDR_WIDTH = valueOf(t_AP" + str(i) + "_ADDR_SZ);\n")
    for i in range(len(axiBusList)):
        fileHandle.write("    parameter AXI" + str(i) + "_DATA_WIDTH = valueOf(t_AXI" + str(i) + "_DATA_SZ);\n")
        fileHandle.write("    parameter AXI" + str(i) + "_ADDR_WIDTH = valueOf(t_AXI" + str(i) + "_ADDR_SZ);\n")
        fileHandle.write("    parameter AXI" + str(i) + "_ID_WIDTH   = valueOf(t_AXI" + str(i) + "_ID_SZ);\n")
    for i in range(len(apInFifoList)):
        fileHandle.write("    parameter AP_IN_FIFO" + str(i) + "_DATA_WIDTH = valueOf(t_AP_IN_FIFO" + str(i) + "_DATA_SZ);\n")
    for i in range(len(apOutFifoList)):
        fileHandle.write("    parameter AP_OUT_FIFO" + str(i) + "_DATA_WIDTH = valueOf(t_AP_OUT_FIFO" + str(i) + "_DATA_SZ);\n")
    
    fileHandle.write("\n    // clock and reset\n")
    fileHandle.write("    default_clock clk;\n")
    fileHandle.write("    default_reset rst_RST_N;\n\n")
    fileHandle.write("    input_clock clk (ap_clk) <- exposeCurrentClock;\n")
    fileHandle.write("    input_reset rst_RST_N (ap_rst_n) clocked_by(clk) <- exposeCurrentReset;\n\n")

    fileHandle.write("    // methods\n")
    fileHandle.write("    method start() enable(ap_start);\n")
    fileHandle.write("    method ap_idle  isIdle ();\n")
    fileHandle.write("    method ap_ready isReady ();\n")
    fileHandle.write("    method ap_done  isDone ();\n")
    
    methodLists = [["start", "isIdle", "isDone", "isReady"]]
    axiBusMethodLists = []
    nonActionMethodLists = []

    if len(apBusList) > 0:
        fileHandle.write("    // ap bus methods\n")
        for m in apBusList:  
            method_m = modifyBusName(m)
            fileHandle.write("    method " + method_m + "ReqNotFull() enable(" + m + "_req_full_n);\n")
            fileHandle.write("    method " + method_m + "ReadRsp(" + m + "_datain) enable(" + m + "_rsp_empty_n);\n")
            fileHandle.write("    method " + m + "_address " + method_m + "ReqAddr() ready(" + m + "_req_write);\n")
            fileHandle.write("    method " + m + "_size " + method_m + "ReqSize() ready(" + m + "_req_write);\n")
            fileHandle.write("    method " + m + "_dataout " + method_m + "WriteData() ready(" + m + "_req_write);\n")
            fileHandle.write("    method " + m + "_req_din " + method_m + "WriteReqEn() ready(" + m + "_req_write);\n")
            methodLists.append([ method_m + "ReqNotFull", method_m + "ReadRsp", method_m + "ReqAddr", method_m + "ReqSize", method_m + "WriteData", method_m + "WriteReqEn" ])

    if len(axiBusList) > 0:
        fileHandle.write("    // axi bus methods\n")
        for m in axiBusList:
            method_m = modifyBusName(m)
            fileHandle.write("    method " + m + "_AWVALID " + method_m + "AwValid();\n")
            fileHandle.write("    method " + m + "_AWADDR " + method_m + "AwAddr();\n") 
            fileHandle.write("    method " + m + "_AWID " + method_m + "AwId();\n")
            fileHandle.write("    method " + m + "_AWLEN " + method_m + "AwLen();\n")
            fileHandle.write("    method " + m + "_AWSIZE " + method_m + "AwSize();\n")
            fileHandle.write("    method " + m + "_AWBURST " + method_m + "AwBurst();\n")
            fileHandle.write("    method " + method_m + "AwReady() enable(" + m + "_AWREADY);\n")
            
            fileHandle.write("    method " + m + "_WVALID " + method_m + "WValid();\n")
            fileHandle.write("    method " + m + "_WDATA " + method_m + "WData();\n") 
            fileHandle.write("    method " + m + "_WID " + method_m + "WId();\n")
            fileHandle.write("    method " + m + "_WSTRB " + method_m + "WStrb();\n")
            fileHandle.write("    method " + m + "_WLAST " + method_m + "WLast();\n")
            fileHandle.write("    method " + method_m + "WReady() enable(" + m + "_WREADY);\n")
            
            fileHandle.write("    method " + m + "_BREADY " + method_m + "BReady();\n")
            fileHandle.write("    method " + method_m + "BId(" + m + "_BID) enable((*inhigh*) " + m + "EN0);\n")
            fileHandle.write("    method " + method_m + "BResp(" + m + "_BRESP) enable((*inhigh*) " + m + "EN1);\n")
            fileHandle.write("    method " + method_m + "BValid() enable(" + m + "_BVALID);\n")
            axiMethods = [ method_m + "AwValid", method_m + "AwAddr", method_m + "AwId", method_m + "AwLen", method_m + "AwSize",
                           method_m + "AwBurst", method_m + "AwReady", method_m + "WValid", method_m + "WData", method_m + "WId", 
                           method_m + "WStrb", method_m + "WLast", method_m + "WReady", method_m + "BReady", method_m + "BId", 
                           method_m + "BResp", method_m + "BValid" ]
            methodLists.append(axiMethods)
            axiBusMethodLists.append(axiMethods)
            nonActionMethods = [ method_m + "AwValid", method_m + "AwAddr", method_m + "AwId", method_m + "AwLen", method_m + "AwSize", 
                                 method_m + "AwBurst", method_m + "WValid", method_m + "WData", method_m + "WId", method_m + "WStrb", 
                                 method_m + "WLast", method_m + "BReady" ]
            nonActionMethodLists.append(nonActionMethods)

            fileHandle.write("    method " + m + "_ARVALID " + method_m + "ArValid();\n")
            fileHandle.write("    method " + m + "_ARADDR " + method_m + "ArAddr();\n") 
            fileHandle.write("    method " + m + "_ARID " + method_m + "ArId();\n")
            fileHandle.write("    method " + m + "_ARLEN " + method_m + "ArLen();\n")
            fileHandle.write("    method " + m + "_ARSIZE " + method_m + "ArSize();\n")
            fileHandle.write("    method " + m + "_ARBURST " + method_m + "ArBurst();\n")
            fileHandle.write("    method " + method_m + "ArReady() enable(" + m + "_ARREADY);\n")
            
            fileHandle.write("    method " + m + "_RREADY " + method_m + "RReady();\n")
            fileHandle.write("    method " + method_m + "RId(" + m + "_RID) enable((*inhigh*) " + m + "EN2);\n")
            fileHandle.write("    method " + method_m + "RData(" + m + "_RDATA) enable((*inhigh*) " + m + "EN3);\n")
            fileHandle.write("    method " + method_m + "RResp(" + m + "_RRESP) enable((*inhigh*) " + m + "EN4);\n")
            fileHandle.write("    method " + method_m + "RLast() enable(" + m + "_RLAST);\n")
            fileHandle.write("    method " + method_m + "RValid() enable(" + m + "_RVALID);\n")
            axiMethods = [ method_m + "ArValid", method_m + "ArAddr", method_m + "ArId", method_m + "ArLen", method_m + "ArSize", 
                           method_m + "ArBurst", method_m + "ArReady", method_m + "RReady", method_m + "RId", method_m + "RData", 
                           method_m + "RResp", method_m + "RLast", method_m + "RValid" ]
            methodLists.append(axiMethods)
            axiBusMethodLists.append(axiMethods)
            nonActionMethods = [ method_m + "ArValid", method_m + "ArAddr", method_m + "ArId", method_m + "ArLen", method_m + "ArSize", method_m + "ArBurst", method_m + "RReady"]
            nonActionMethodLists.append(nonActionMethods)

    if len(apInFifoList) > 0:
        fileHandle.write("    // ap input fifo methods\n")
        for m in apInFifoList:  
            method_m = modifyBusName(m)
            fileHandle.write("    method " + method_m + "InputMsg(" + m + "_dout) enable(" + m + "_empty_n);\n")
            fileHandle.write("    method " + m + "_read " + method_m + "MsgReceived();\n")
            methodLists.append([ method_m + "InputMsg", method_m + "MsgReceived" ])
    
    if len(apOutFifoList) > 0:
        fileHandle.write("    // ap output fifo methods\n")
        for m in apOutFifoList:  
            method_m = modifyBusName(m)
            fileHandle.write("    method " + method_m + "NotFull() enable(" + m + "_full_n);\n")
            fileHandle.write("    method " + m + "_din " + method_m + "OutputMsg() ready(" + m + "_write);\n")
            methodLists.append([ method_m + "OutputMsg", method_m + "NotFull" ])
    
    fileHandle.write("\n    //scheduling\n")
    fileHandle.write("    schedule start C start;\n")
    fileHandle.write("    schedule (isIdle, isDone, isReady) CF (isIdle, isDone, isReady);\n")
    fileHandle.write("    schedule start CF (isIdle, isDone, isReady);\n\n")

    for k in range(0, len(methodLists)-1):
        for j in range(k+1, len(methodLists)):
            fileHandle.write("    schedule (" + ', '.join(methodLists[k]) + ") CF (" + ', '.join(methodLists[j]) + ");\n")

    fileHandle.write("\n")
   
    for m in apBusList:  
        m = modifyBusName(m)
        fileHandle.write("    schedule " + m + "ReqNotFull C " + m + "ReqNotFull;\n")
        fileHandle.write("    schedule " + m + "ReqNotFull CF (" + m + "ReadRsp, " + m + "ReqAddr, " + m + "ReqSize, " + m + "WriteData, " + m + "WriteReqEn);\n")
        fileHandle.write("    schedule " + m + "ReadRsp C " + m + "ReadRsp;\n")
        fileHandle.write("    schedule " + m + "ReadRsp CF (" + m + "ReqAddr, " + m + "ReqSize, " + m + "WriteData, " + m + "WriteReqEn);\n")
        fileHandle.write("    schedule (" + m + "ReqAddr, " + m + "ReqSize, " + m + "WriteData, " + m + "WriteReqEn) CF (" + m + "ReqAddr, " + m + "ReqSize, " + m + "WriteData, " + m + "WriteReqEn);\n\n")

    for i, m in enumerate(axiBusList):  
        m = modifyBusName(m)
        genActionMethodSchedule( m + "AwReady", axiBusMethodLists[2*i], fileHandle)
        genActionMethodSchedule( m + "WReady", axiBusMethodLists[2*i], fileHandle)
        genActionMethodSchedule( m + "BId", axiBusMethodLists[2*i], fileHandle)
        genActionMethodSchedule( m + "BResp", axiBusMethodLists[2*i], fileHandle)
        genActionMethodSchedule( m + "BValid", axiBusMethodLists[2*i], fileHandle)
        fileHandle.write("    schedule (" + ', '.join(nonActionMethodLists[2*i]) + ") CF (" + ', '.join(nonActionMethodLists[2*i]) + ");\n")
        
        genActionMethodSchedule( m + "ArReady", axiBusMethodLists[2*i+1], fileHandle)
        genActionMethodSchedule( m + "RId", axiBusMethodLists[2*i+1], fileHandle)
        genActionMethodSchedule( m + "RData", axiBusMethodLists[2*i+1], fileHandle)
        genActionMethodSchedule( m + "RResp", axiBusMethodLists[2*i+1], fileHandle)
        genActionMethodSchedule( m + "RLast", axiBusMethodLists[2*i+1], fileHandle)
        genActionMethodSchedule( m + "RValid", axiBusMethodLists[2*i+1], fileHandle)
        fileHandle.write("    schedule (" + ', '.join(nonActionMethodLists[2*i+1]) + ") CF (" + ', '.join(nonActionMethodLists[2*i+1]) + ");\n")

    for m in apInFifoList: 
        m = modifyBusName(m)
        fileHandle.write("    schedule " + m + "InputMsg C " + m + "InputMsg;\n")
        fileHandle.write("    schedule " + m + "MsgReceived CF (" + m + "InputMsg, " + m + "MsgReceived);\n")

    for m in apOutFifoList: 
        m = modifyBusName(m)
        fileHandle.write("    schedule " + m + "NotFull C " + m + "NotFull;\n")
        fileHandle.write("    schedule " + m + "OutputMsg CF (" + m + "NotFull, " + m + "OutputMsg);\n")

    fileHandle.write("\nendmodule\n\n")

def genActionMethodSchedule(methodName, methodList, fileHandle):
     fileHandle.write("    schedule " + methodName + " C " + methodName + ";\n")
     methodList.remove(methodName)
     fileHandle.write("    schedule " + methodName + " CF (" + ', '.join(methodList) + ");\n")

def genBluespecWrapper(moduleInfo, fileHandle):

    apBusList = moduleInfo['apBusPorts']['list']  
    axiBusList = moduleInfo['axiPorts']['list']
    apInFifoList = moduleInfo['apInFifoPorts']['list']
    apOutFifoList = moduleInfo['apOutFifoPorts']['list']
    
    fileHandle.write("// HLS-core with memory bus interface\n")
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("interface HLS_CORE_WITH_MEM_BUS_IFC#(")
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 37, "ap_bus",  apBusList, "AP", "SZ", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 37, "axi_bus", axiBusList, "AXI", "SZ", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 37, "ap_fifo", apInFifoList, "AP_IN_FIFO", "SZ", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "numeric type t_", ");\n", 37, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "SZ", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
    else:
        fileHandle.write("interface HLS_CORE_WITH_MEM_BUS_IFC;\n")
    
    fileHandle.write("    // hls core control methods\n")
    fileHandle.write("    method Action start();\n")
    fileHandle.write("    method Bool isIdle();\n")
    fileHandle.write("    method Bool isDone();\n")
    fileHandle.write("    method Bool isReady();\n")
    
    if len(apBusList) > 0:
        fileHandle.write("    // hls core ap bus port(s)\n")
        for i in range(len(apBusList)):
            fileHandle.write("    interface HLS_AP_BUS_IFC#(t_AP" + str(i) + "_ADDR_SZ, t_AP" + str(i) + "_DATA_SZ) apPort" + str(i) +";\n")
    if len(axiBusList) > 0:    
        fileHandle.write("    // hls core axi bus port(s)\n")
        for i in range(len(axiBusList)):
            fileHandle.write("    interface HLS_AXI_BUS_IFC#(t_AXI" + str(i) + "_ADDR_SZ, t_AXI" + str(i) + "_DATA_SZ, t_AXI" + str(i) + "_ID_SZ) axiPort" + str(i) + ";\n")
    if len(apInFifoList) > 0:
        fileHandle.write("    // hls core input ap fifo port(s)\n")
        for i in range(len(apInFifoList)):
            fileHandle.write("    interface HLS_AP_IN_FIFO_IFC#(t_AP_IN_FIFO" + str(i) + "_DATA_SZ) apInFifoPort" + str(i) +";\n")
    
    if len(apOutFifoList) > 0:
        fileHandle.write("    // hls core output ap fifo port(s)\n")
        for i in range(len(apOutFifoList)):
            fileHandle.write("    interface HLS_AP_OUT_FIFO_IFC#(t_AP_OUT_FIFO" + str(i) + "_DATA_SZ) apOutFifoPort" + str(i) +";\n")
    
    fileHandle.write("endinterface\n\n")
    
    fileHandle.write("//\n// mkMultiMemPortHlsCore --\n")
    fileHandle.write("//     Wrapper for the mkHlsCoreInternal module.\n//\n")
    fileHandle.write("module [CONNECTED_MODULE] mkMultiMemPortHlsCore\n")
    fileHandle.write("    // interface:\n")
    
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("    (HLS_CORE_WITH_MEM_BUS_IFC#(")
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 32, "ap_bus",  apBusList, "AP", "SZ", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 32, "axi_bus", axiBusList, "AXI", "SZ", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 32, "ap_fifo", apInFifoList, "AP_IN_FIFO", "SZ", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", "));\n\n", 32, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "SZ", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
        fileHandle.write("    HLS_CORE_INTERNAL_IFC#(")
        tail = ") core <- mkHlsCoreInternal;\n\n"
        printBsvWrapperParameters(fileHandle, "t_", tail, 27, "ap_bus",  apBusList, "AP", "SZ", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", tail, 27, "axi_bus", axiBusList, "AXI", "SZ", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", tail, 27, "ap_fifo", apInFifoList, "AP_IN_FIFO", "SZ", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, "t_", tail, 27, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "SZ", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
    else:
        fileHandle.write("    (HLS_CORE_WITH_MEM_BUS_IFC);\n\n")
        fileHandle.write("    HLS_CORE_INTERNAL_IFC core <- mkHlsCoreInternal;\n\n")
    
    for i, m in enumerate(apBusList):
        m = modifyBusName(m)
        fileHandle.write("    interface apPort" + str(i) + " =\n")
        fileHandle.write("        interface HLS_AP_BUS_IFC#(t_AP" + str(i) + "_ADDR_SZ, t_AP" + str(i) + "_DATA_SZ);\n")
        fileHandle.write("            method Action reqNotFull();\n")
        fileHandle.write("                core." + m + "ReqNotFull();\n")
        fileHandle.write("            endmethod\n")
        fileHandle.write("            method Action readRsp(Bit#(t_AP" + str(i) + "_DATA_SZ) resp);\n")
        fileHandle.write("                core." + m + "ReadRsp(resp);\n")
        fileHandle.write("            endmethod\n")
        fileHandle.write("            method Bit#(t_AP" + str(i) + "_ADDR_SZ) reqAddr() = core." + m + "ReqAddr();\n")
        fileHandle.write("            method Bit#(t_AP" + str(i) + "_ADDR_SZ) reqSize() = core." + m + "ReqSize();\n")
        fileHandle.write("            method Bit#(t_AP" + str(i) + "_DATA_SZ) writeData() = core." + m + "WriteData();\n")
        fileHandle.write("            method Bool writeReqEn() = core." + m + "WriteReqEn();\n")
        fileHandle.write("        endinterface;\n\n")

    for i, m in enumerate(axiBusList):  
        m = modifyBusName(m)
        fileHandle.write("    interface axiPort" + str(i) + " =\n")
        fileHandle.write("        interface HLS_AXI_BUS_IFC#(t_AXI" + str(i) + "_ADDR_SZ, t_AXI" + str(i) + "_DATA_SZ, t_AXI" + str(i) + "_ID_SZ);\n")
        fileHandle.write("            interface writePort = interface AXI4_WRITE_MASTER#(t_AXI" + str(i) + "_ADDR_SZ, t_AXI" + str(i) + "_DATA_SZ, t_AXI" + str(i) + "_ID_SZ);\n")
        fileHandle.write("                                      method Bit#(t_AXI" + str(i) + "_ID_SZ) awId() = core." + m + "AwId();\n")
        fileHandle.write("                                      method Bit#(t_AXI" + str(i) + "_ADDR_SZ) awAddr() = core." + m + "AwAddr();\n")
        fileHandle.write("                                      method Bit#(8) awLen() = core." + m + "AwLen();\n")
        fileHandle.write("                                      method Bit#(3) awSize() = core." + m + "AwSize();\n")
        fileHandle.write("                                      method AXI4BurstMode awBurst() = core." + m + "AwBurst();\n")
        fileHandle.write("                                      method Bool awValid() = core." + m + "AwValid();\n")
        fileHandle.write("                                      method Action awReady();\n")
        fileHandle.write("                                          core." + m + "AwReady();\n")
        fileHandle.write("                                      endmethod\n")
        fileHandle.write("                                      method Bit#(t_AXI" + str(i) + "_ID_SZ) wId() = core." + m + "WId();\n")
        fileHandle.write("                                      method Bit#(t_AXI" + str(i) + "_DATA_SZ) wData() = core." + m + "WData();\n")
        fileHandle.write("                                      method Bit#(TDiv#(t_AXI" + str(i) + "_DATA_SZ, 8)) wStrb() = core." + m + "WStrb();\n")
        fileHandle.write("                                      method Bool wLast() = core." + m + "WLast();\n")
        fileHandle.write("                                      method Bool wValid() = core." + m + "WValid();\n")
        fileHandle.write("                                      method Action wReady() = core." + m + "WReady();\n")
        fileHandle.write("                                      method Bool bReady() = core." + m + "BReady();\n")
        fileHandle.write("                                      method Action bId(Bit#(t_AXI" + str(i) + "_ID_SZ) id);\n")
        fileHandle.write("                                          core." + m + "BId(id);\n")
        fileHandle.write("                                      endmethod\n")
        fileHandle.write("                                      method Action bResp(AXI4Resp resp);\n")
        fileHandle.write("                                          core." + m + "BResp(resp);\n")
        fileHandle.write("                                      endmethod\n")
        fileHandle.write("                                      method Action bValid();\n")
        fileHandle.write("                                          core." + m + "BValid();\n")
        fileHandle.write("                                      endmethod\n")
        fileHandle.write("                                  endinterface;\n")
        fileHandle.write("            interface readPort = interface AXI4_READ_MASTER#(t_AXI" + str(i) + "_ADDR_SZ, t_AXI" + str(i) + "_DATA_SZ, t_AXI" + str(i) + "_ID_SZ);\n")
        fileHandle.write("                                     method Bit#(t_AXI" + str(i) + "_ID_SZ) arId() = core." + m + "ArId();\n")
        fileHandle.write("                                     method Bit#(t_AXI" + str(i) + "_ADDR_SZ) arAddr() = core." + m + "ArAddr();\n")
        fileHandle.write("                                     method Bit#(8) arLen() = core." + m + "ArLen();\n")
        fileHandle.write("                                     method Bit#(3) arSize() = core." + m + "ArSize();\n")
        fileHandle.write("                                     method AXI4BurstMode arBurst() = core." + m + "ArBurst();\n")
        fileHandle.write("                                     method Bool arValid() = core." + m + "ArValid();\n")
        fileHandle.write("                                     method Action arReady();\n")
        fileHandle.write("                                         core." + m + "ArReady();\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                     method Bool rReady() = core." + m + "RReady();\n")
        fileHandle.write("                                     method Action rId(Bit#(t_AXI" + str(i) + "_ID_SZ) id);\n")
        fileHandle.write("                                         core." + m + "RId(id);\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                     method Action rData(Bit#(t_AXI" + str(i) + "_DATA_SZ) data);\n")
        fileHandle.write("                                         core." + m + "RData(data);\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                     method Action rResp(AXI4Resp resp);\n")
        fileHandle.write("                                         core." + m + "RResp(resp);\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                     method Action rLast();\n")
        fileHandle.write("                                         core." + m + "RLast();\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                     method Action rValid();\n")
        fileHandle.write("                                         core." + m + "RValid();\n")
        fileHandle.write("                                     endmethod\n")
        fileHandle.write("                                 endinterface;\n")
        fileHandle.write("        endinterface;\n\n")
    
    for i, m in enumerate(apInFifoList):
        m = modifyBusName(m)
        fileHandle.write("    interface apInFifoPort" + str(i) + " =\n")
        fileHandle.write("        interface HLS_AP_IN_FIFO_IFC#(t_AP_IN_FIFO" + str(i) + "_DATA_SZ);\n")
        fileHandle.write("            method Action inputMsg(Bit#(t_AP_IN_FIFO" + str(i) + "_DATA_SZ) msg);\n")
        fileHandle.write("                core." + m + "InputMsg(msg);\n")
        fileHandle.write("            endmethod\n")
        fileHandle.write("            method Bool msgReceived() = core." + m + "MsgReceived();\n")
        fileHandle.write("        endinterface;\n\n")
    
    for i, m in enumerate(apOutFifoList):
        m = modifyBusName(m)
        fileHandle.write("    interface apOutFifoPort" + str(i) + " =\n")
        fileHandle.write("        interface HLS_AP_OUT_FIFO_IFC#(t_AP_OUT_FIFO" + str(i) + "_DATA_SZ);\n")
        fileHandle.write("            method Action notFull();\n")
        fileHandle.write("                core." + m + "NotFull();\n")
        fileHandle.write("            endmethod\n")
        fileHandle.write("            method Bit#(t_AP_OUT_FIFO" + str(i) + "_DATA_SZ) outputMsg() = core." + m + "OutputMsg();\n")
        fileHandle.write("        endinterface;\n\n")

    fileHandle.write("    method Action start();\n        core.start();\n    endmethod\n")
    fileHandle.write("    method Bool isIdle() = core.isIdle();\n")
    fileHandle.write("    method Bool isDone() = core.isDone();\n")
    fileHandle.write("    method Bool isReady() = core.isReady();\n\n")

    fileHandle.write("endmodule\n\n")

    fileHandle.write("//\n\n")
    fileHandle.write("// mkHlsCore --\n")
    fileHandle.write("//     Connect the mkMultiMemPortHlsCore module with LEAP Memory. Memory is \n")
    fileHandle.write("// passed in as an argument.\n")
    fileHandle.write("//\n")
    fileHandle.write("module [CONNECTED_MODULE] mkHlsCore#(Vector#(n_MEMORIES, MEMORY_IFC#(t_MEM_ADDR, t_MEM_DATA)) mems,\n")
    fileHandle.write("                                     NumTypeParam#(t_MEM_DATA_SZ) memDataSz,\n")
    fileHandle.write("                                     DEBUG_FILE debugLog)\n")
    fileHandle.write("    // interface:\n")
    fileHandle.write("    (HLS_CORE_IFC)\n")
    fileHandle.write("    provisos (Bits#(t_MEM_ADDR, t_MEM_ADDR_SZ),\n")
    fileHandle.write("              Alias#(Bit#(t_MEM_DATA_SZ), t_MEM_DATA),\n")
    fileHandle.write("              NumAlias#(`HLS_AP_BUS_NUM, n_AP_BUS),\n")
    fileHandle.write("              NumAlias#(`HLS_AXI_BUS_NUM, n_AXI_BUS),\n")
    fileHandle.write("              Add#(n_AP_BUS, n_AXI_BUS, n_MEMORIES));\n\n")
    
    if len(apBusList) + len(axiBusList) + len(apInFifoList) + len(apOutFifoList) > 0:
        fileHandle.write("    HLS_CORE_WITH_MEM_BUS_IFC#(")
        head = "`HLS_"
        tail = ") core <- mkMultiMemPortHlsCore;\n\n"
        printBsvWrapperParameters(fileHandle, head, tail, 31, "ap_bus",  apBusList, "AP_BUS", "BITS", True, len(axiBusList) + len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, head, tail, 31, "axi_bus", axiBusList, "AXI_BUS", "BITS", len(apBusList) == 0, len(apInFifoList) + len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, head, tail, 31, "ap_fifo", apInFifoList, "AP_IN_FIFO", "BITS", len(apBusList) + len(axiBusList) == 0, len(apOutFifoList) == 0)
        printBsvWrapperParameters(fileHandle, head, tail, 31, "ap_fifo", apOutFifoList, "AP_OUT_FIFO", "BITS", len(apBusList) + len(axiBusList) + len(apInFifoList) == 0, True)
    else:
        fileHandle.write("    HLS_CORE_WITH_MEM_BUS_IFC core <- mkMultiMemPortHlsCore;\n\n")

    fileHandle.write("    Reg#(Bool) verboseMode <- mkReg(False);\n\n")
    
    for i in range(len(apBusList)):
        fileHandle.write("    mkHlsApBusMemConnection(mems[" + str(i) + "], core.apPort" + str(i) + ", memDataSz, verboseMode, debugLog, " + str(i) + ");\n")
    
    for i in range(len(axiBusList)):
        fileHandle.write("    mkHlsAxi4BusMemConnection(mems[" + str(i + len(apBusList)) + "], core.axiPort" + str(i) + ", memDataSz, verboseMode._read(), debugLog, " + str(i + len(apBusList)) + ");\n")

    for i, m in enumerate(apInFifoList):
        fileHandle.write("    mkHlsApInFifoConnection(core.apInFifoPort" + str(i) + ", \"" + m + "\", debugLog);\n")
    
    for i, m in enumerate(apOutFifoList):
        fileHandle.write("    mkHlsApOutFifoConnection(core.apOutFifoPort" + str(i) + ", \"" + m + "\", debugLog);\n")
    
    fileHandle.write("\n    // =======================================================================\n")
    fileHandle.write("    //\n")
    fileHandle.write("    // Methods\n")
    fileHandle.write("    //\n")
    fileHandle.write("    // =======================================================================\n")
    fileHandle.write("    method Action start();\n")
    fileHandle.write("        core.start();\n")
    fileHandle.write("        debugLog.record($format(\"hlsCore: start...\"));\n")
    fileHandle.write("    endmethod\n")
    fileHandle.write("    method Bool isIdle() = core.isIdle();\n")
    fileHandle.write("    method Bool isDone() = core.isDone();\n")
    fileHandle.write("    method Bool isReady() = core.isReady();\n")
    fileHandle.write("    method Action setVerboseMode(Bool verbose);\n")
    fileHandle.write("        verboseMode <= verbose; \n")
    fileHandle.write("    endmethod\n\n")

    fileHandle.write("endmodule\n")

