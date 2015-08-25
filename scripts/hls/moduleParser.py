import re

debug = False
    
def getAxiSubports():
    axi_subports = [    "AWADDR", "AWREADY", "AWVALID", "AWID", "AWLEN", "AWSIZE", "AWBURST", "AWLOCK", 
                        "AWCACHE", "AWPROT", "AWQOS", "AWREGION", "AWUSER", "WVALID", "WREADY", "WDATA", 
                        "WSTRB", "WLAST", "WID", "WUSER", "ARVALID", "ARREADY", "ARADDR", "ARID", "ARLEN", 
                        "ARSIZE", "ARBURST", "ARLOCK", "ARCACHE", "ARPROT", "ARQOS", "ARREGION", "ARUSER", 
                        "RVALID", "RREADY", "RDATA", "RLAST", "RID", "RUSER", "RRESP", "BVALID", "BREADY", 
                        "BRESP", "BID", "BUSER" ]   
    return axi_subports

def getApBusSubports():
    apbus_subports = [ "REQ_DIN", "REQ_FULL_N", "REQ_WRITE", "RSP_EMPTY_N", "RSP_READ", 
                       "ADDRESS", "DATAIN", "DATAOUT", "SIZE" ]
    return apbus_subports

def getApInFifoSubports():
    ap_in_fifo_subports = [ "DOUT", "EMPTY_N", "READ" ] 
    return ap_in_fifo_subports

def getApOutFifoSubports():
    ap_out_fifo_subports = [ "DIN", "FULL_N", "WRITE" ]
    return ap_out_fifo_subports

def applyParameter(formula, parameterInfo):
    if (formula): 
        f = str(formula)
        f = f.strip()
        if not (re.search('[A-Za-z]+', formula, re.I)):
            return eval(formula)
        else:
            new_formula = formula
            while (re.search('[A-Za-z]+', new_formula, re.I)):
                s0 = re.search('([^A-Za-z]*)([A-Za-z]+[A-Za-z_0-9]*)(.*)', new_formula, re.I)
                new_formula = str(s0.group(1)) + str(parameterInfo[str(s0.group(2))]) + str(s0.group(3))
            return eval(new_formula)
    else:
        return formula

def extractBusPorts (busPorts, busSubports, portInfo, parameterInfo, fileContents):
    for eachPort in busPorts : 
        portInfo[eachPort] = {}
        for eachSubport in busSubports : 
            portInfo[eachPort][eachSubport] = {}
            matchResult = re.match('.*?(input|output)\s*(\[([A-Za-z_0-9\/\*+\- ]*):([A-Za-z_0-9\/\*+\- ]*)\])?\s*({0}_{1})'.format(eachPort, eachSubport), fileContents.group(3), re.S|re.I)
            if matchResult:
                portInfo[eachPort][eachSubport]['name'] = matchResult.group(5)
                portInfo[eachPort][eachSubport]['dir'] = matchResult.group(1)
                portInfo[eachPort][eachSubport]['msb'] = applyParameter(matchResult.group(3), parameterInfo)
                portInfo[eachPort][eachSubport]['lsb'] = applyParameter(matchResult.group(4), parameterInfo)
                portInfo[eachPort][eachSubport]['bitrange'] = ""
                bitrange = None
                
                if (matchResult.group(2)) and portInfo[eachPort][eachSubport]['msb'] != portInfo[eachPort][eachSubport]['lsb']:
                    bitrange =  "[{0}:{1}]".format(portInfo[eachPort][eachSubport]['msb'], portInfo[eachPort][eachSubport]['lsb'])
                    portInfo[eachPort][eachSubport]['bitrange'] = bitrange

                if debug:
                    print "Port info for {0} and {1} is name: {2}, direction: {3}, bitrange: {4}".format(eachPort, eachSubport, matchResult.group(5), matchResult.group(1), bitrange)
            else: 
                portInfo[eachPort][eachSubport]['name'] = None
                portInfo[eachPort][eachSubport]['dir'] = None
                portInfo[eachPort][eachSubport]['msb'] = None
                portInfo[eachPort][eachSubport]['lsb'] = None
                portInfo[eachPort][eachSubport]['bitrange'] = None

def getApBusAddrSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['apBusPorts']['list']:
        if portInfo[eachPort]['ADDRESS']['msb'] == portInfo[eachPort]['ADDRESS']['lsb']:
            sizes.append(1)
        else:
            sizes.append(portInfo[eachPort]['ADDRESS']['msb']-portInfo[eachPort]['ADDRESS']['lsb']+1)
    return sizes

def getApBusDataSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['apBusPorts']['list']:
        if portInfo[eachPort]['DATAIN']['msb'] == portInfo[eachPort]['DATAIN']['lsb']:
            sizes.append(1)
        else: 
            sizes.append(portInfo[eachPort]['DATAIN']['msb']-portInfo[eachPort]['DATAIN']['lsb']+1)
    return sizes

def getApInFifoDataSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['apInFifoPorts']['list']:
        if portInfo[eachPort]['DOUT']['msb'] == portInfo[eachPort]['DOUT']['lsb']:
            sizes.append(1)
        else: 
            sizes.append(portInfo[eachPort]['DOUT']['msb']-portInfo[eachPort]['DOUT']['lsb']+1)
    return sizes

def getApOutFifoDataSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['apOutFifoPorts']['list']:
        if portInfo[eachPort]['DIN']['msb'] == portInfo[eachPort]['DIN']['lsb']:
            sizes.append(1)
        else: 
            sizes.append(portInfo[eachPort]['DIN']['msb']-portInfo[eachPort]['DIN']['lsb']+1)
    return sizes

def getAxiBusAddrSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['axiPorts']['list']:
        if portInfo[eachPort]['AWADDR']['msb'] == portInfo[eachPort]['AWADDR']['lsb']:
            sizes.append(1)
        else:
            sizes.append(portInfo[eachPort]['AWADDR']['msb']-portInfo[eachPort]['AWADDR']['lsb']+1)
    return sizes

def getAxiBusDataSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['axiPorts']['list']:
        if portInfo[eachPort]['WDATA']['msb'] == portInfo[eachPort]['WDATA']['lsb']:
            sizes.append(1)
        else:
            sizes.append(portInfo[eachPort]['WDATA']['msb']-portInfo[eachPort]['WDATA']['lsb']+1)
    return sizes

def getAxiBusIdSize (moduleInfo):
    portInfo = moduleInfo['ports']
    sizes = []
    for eachPort in moduleInfo['axiPorts']['list']:
        if portInfo[eachPort]['AWID']['msb'] == portInfo[eachPort]['AWID']['lsb']:
            sizes.append(1)
        else:
            sizes.append(portInfo[eachPort]['AWID']['msb']-portInfo[eachPort]['AWID']['lsb']+1)
    return sizes

def getModuleInfoFromFile(filename):
    moduleInfo = {}

    wrapper = open(filename)

    if debug:
        print "File opened for parsing %r" % wrapper

    fileContents = re.match('.*\n\s*module\s*([A-Za-z_0-9]*).*?\((.*?)\)\;(.*)', wrapper.read(), re.S|re.I)
    wrapper.close()

    moduleInfo['name'] = fileContents.group(1)

    # if debug: 
    #     print "Module name: {0}".format(moduleInfo['name'])

    #     print "*************** Intermediate Result ************"
    #     print "Group 2: "
    #     print fileContents.group(2)
    #     print "Group 3: "
    #     print fileContents.group(3)
    #     print "***********************************************"

    # extract parameters
    parameterInfo = {}
    lines = fileContents.group(3).split('\n')
    
    for line in lines:
        matchResult = re.match('\s*parameter\s*([A-Za-z_0-9]+?)\s*=\s*([A-Za-z_0-9+\-\*\/\(\) ]+)\s*;', line, re.I)
        if matchResult:
            value = applyParameter(matchResult.group(2), parameterInfo)
            parameterInfo[matchResult.group(1)] = value
            print "Find parameter {0}: {1}".format(matchResult.group(1), value)

    portInfo = {} 

    # extract control ports
    controlSubport = [ "clk", "(reset|rst)", "idle", "ap_ready", "done", "start" ]

    portInfo['controlPort'] = {}
    for eachSubport in controlSubport:
        portInfo['controlPort'][eachSubport] = {}
        matchResult = re.match('.*?(input|output)\s*([A-Za-z_0-9]*{0}[A-Za-z_0-9]*)'.format(eachSubport), fileContents.group(3), re.S|re.I)
        if matchResult:
            portInfo['controlPort'][eachSubport]['name'] = matchResult.group(2)
            portInfo['controlPort'][eachSubport]['dir'] = matchResult.group(1)
            if debug:
                print "Port info for {0} is name: {1}, direction: {2}".format(eachSubport, matchResult.group(2), matchResult.group(1))
        else:
            portInfo['controlPort'][eachSubport]['name'] = None
            portInfo['controlPort'][eachSubport]['dir'] = None

    # extract axi ports
    axiSubports = getAxiSubports()
    axiPorts = re.findall('.*?([A-Za-z_0-9]*)_{0}.*?'.format("AWADDR"), fileContents.group(2), re.S|re.I)
    if debug: 
        print "AXI ports found: {0}".format(axiPorts)
    extractBusPorts(axiPorts, axiSubports, portInfo, parameterInfo, fileContents)
    
    # extract apbus ports
    apBusSubports = getApBusSubports()
    apBusPorts = re.findall('.*?([A-Za-z_0-9]*)_{0}.*?'.format("ADDRESS"), fileContents.group(2), re.S|re.I)
    if debug: 
        print "AP_BUS ports found: {0}".format(apBusPorts)
    extractBusPorts(apBusPorts, apBusSubports, portInfo, parameterInfo, fileContents)

    # extract apfifo ports
    apInFifoSubports = getApInFifoSubports()
    apInFifoPorts = re.findall('.*?([A-Za-z_0-9]*)_{0}.*?'.format("DOUT"), fileContents.group(2), re.S|re.I)
    if debug: 
        print "Ap_In_FIFO ports found: {0}".format(apInFifoPorts)
    extractBusPorts(apInFifoPorts, apInFifoSubports, portInfo, parameterInfo, fileContents)

    apOutFifoSubports = getApOutFifoSubports()
    apOutFifoPorts = re.findall('.*?([A-Za-z_0-9]*)_{0}.*?'.format("DIN"), fileContents.group(2), re.S|re.I)
    # remove false detection
    apOutFifoPorts = [ x for x in apOutFifoPorts if x.lower() not in [y.lower()+"_req" for y in apBusPorts]]
    if debug: 
        print "Ap_Out_FIFO ports found: {0}".format(apOutFifoPorts)
    extractBusPorts(apOutFifoPorts, apOutFifoSubports, portInfo, parameterInfo, fileContents)

    moduleInfo['ports'] = portInfo
    moduleInfo['axiPorts'] = {}
    moduleInfo['axiPorts']['list'] = axiPorts
    moduleInfo['axiPorts']['subports'] = getAxiSubports()
    moduleInfo['axiPorts']['addrSize'] = getAxiBusAddrSize(moduleInfo)
    moduleInfo['axiPorts']['dataSize'] = getAxiBusDataSize(moduleInfo)
    moduleInfo['axiPorts']['idSize'] = getAxiBusIdSize(moduleInfo)
    moduleInfo['apBusPorts'] = {}
    moduleInfo['apBusPorts']['list'] = apBusPorts
    moduleInfo['apBusPorts']['subports'] = getApBusSubports()
    moduleInfo['apBusPorts']['addrSize'] = getApBusAddrSize(moduleInfo)
    moduleInfo['apBusPorts']['dataSize'] = getApBusDataSize(moduleInfo)
    moduleInfo['apInFifoPorts'] = {}
    moduleInfo['apInFifoPorts']['list'] = apInFifoPorts
    moduleInfo['apInFifoPorts']['subports'] = getApInFifoSubports()
    moduleInfo['apInFifoPorts']['dataSize'] = getApInFifoDataSize(moduleInfo)
    moduleInfo['apOutFifoPorts'] = {}
    moduleInfo['apOutFifoPorts']['list'] = apOutFifoPorts
    moduleInfo['apOutFifoPorts']['subports'] = getApOutFifoSubports()
    moduleInfo['apOutFifoPorts']['dataSize'] = getApOutFifoDataSize(moduleInfo)

    return moduleInfo

