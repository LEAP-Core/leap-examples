//
// INTEL CONFIDENTIAL
// Copyright (c) 2008 Intel Corp.  Recipient is granted a non-sublicensable 
// copyright license under Intel copyrights to copy and distribute this code 
// internally only. This code is provided "AS IS" with no support and with no 
// warranties of any kind, including warranties of MERCHANTABILITY,
// FITNESS FOR ANY PARTICULAR PURPOSE or INTELLECTUAL PROPERTY INFRINGEMENT. 
// By making any use of this code, Recipient agrees that no other licenses 
// to any Intel patents, trade secrets, copyrights or other intellectual 
// property rights are granted herein, and no other licenses shall arise by 
// estoppel, implication or by operation of law. Recipient accepts all risks 
// of use.
//

//
// @file rrrtest.bsv
// @brief RRR Test System
//
// @author Angshuman Parashar
//

import Clocks::*;
import FIFO::*;
import FIFOF::*;

`include "asim/provides/virtual_platform.bsh"
`include "asim/provides/virtual_devices.bsh"
`include "asim/provides/physical_platform.bsh"
`include "asim/provides/low_level_platform_interface.bsh"
`include "asim/provides/sata_device.bsh"
`include "asim/provides/librl_bsv_storage.bsh"
`include "asim/provides/librl_bsv_base.bsh"
`include "asim/provides/stream_capture_fifo.bsh"

`include "asim/rrr/service_ids.bsh"
`include "asim/rrr/client_stub_SATATOPCIERRR.bsh"


// types


// mkApplication

module mkApplication#(VIRTUAL_PLATFORM vp)();

    LowLevelPlatformInterface llpi = vp.llpint;
    XUPV5_SERDES_DRIVER       sataDriver = llpi.physicalDrivers.sataDriver;
    Clock rxClk = sataDriver.rxusrclk0;
    Reset rxRst = sataDriver.rxusrrst0;
    Clock txClk = sataDriver.txusrclk;
    Reset txRst = sataDriver.txusrrst;
    
    // instantiate stubs
    ClientStub_SATATOPCIERRR clientStub <- mkClientStub_SATATOPCIERRR(llpi.rrrClient);
    NumTypeParam#(16383) fifo_sz = 0;
   
    FIFO#(XUPV5_SERDES_WORD) serdes_word_fifo <- mkSizedBRAMFIFO(fifo_sz, clocked_by rxClk, reset_by rxRst);
    FIFOF#(XUPV5_SERDES_WORD) stream_fifo <- mkStreamCaptureFIFOF(4096, clocked_by rxClk, reset_by rxRst);
    SyncFIFOIfc#(XUPV5_SERDES_WORD) serdes_word_sync_fifo <- mkSyncFIFOToCC(16,rxClk, rxRst);
    SyncFIFOIfc#(XUPV5_SERDES_WORD) serdes_word_to_tx_fifo <- mkSyncFIFO(16,rxClk, rxRst, txClk);   
    Reg#(Maybe#(XUPV5_SERDES_WORD)) serdes_word_wire <- mkDWire(tagged Invalid, clocked_by rxClk, reset_by rxRst);
   
    rule getSATAData(True);
       let data <- sataDriver.receive0();
       serdes_word_fifo.enq(data);
    endrule
   
    rule crossClockSATAData(True);
      serdes_word_fifo.deq();
      serdes_word_wire <= tagged Valid serdes_word_fifo.first();
      serdes_word_to_tx_fifo.enq(serdes_word_fifo.first());
    endrule
   
    rule enqStreamFIFO(isValid(serdes_word_wire));
       stream_fifo.enq(fromMaybe(?,serdes_word_wire));
    endrule
   
    rule enqSyncFIFO(True);
       stream_fifo.deq();
       serdes_word_sync_fifo.enq(stream_fifo.first());
    endrule
   
    rule sendToSW(True);
       serdes_word_sync_fifo.deq();
       clientStub.makeRequest_SataData(zeroExtend(pack(serdes_word_sync_fifo.first())));        
    endrule
   
    rule loopback(True);
       serdes_word_to_tx_fifo.deq();
       sataDriver.send0(serdes_word_to_tx_fifo.first());        
    endrule
    
endmodule
