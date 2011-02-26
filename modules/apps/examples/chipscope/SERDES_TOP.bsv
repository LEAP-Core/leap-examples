import Clocks::*;
import Connectable::*;
import DReg::*;
import FIFO::*;
import LFSR::*;

`include "asim/provides/virtual_platform.bsh"
`include "asim/provides/virtual_devices.bsh"
`include "asim/provides/physical_platform.bsh"
`include "asim/provides/low_level_platform_interface.bsh"
`include "asim/provides/chipscope_device.bsh"
`include "asim/provides/sata_device.bsh"
   
module mkApplication#(VIRTUAL_PLATFORM vp)();
   
   LowLevelPlatformInterface llpi = vp.llpint;
         
   XUPV5_SERDES_BYTE comma  = serdesControl(60);
   XUPV5_SERDES_WORD commas = serdesWord(comma, comma); 
   XUPV5_SERDES_BYTE idle  = serdesControl(0);
   XUPV5_SERDES_WORD idles = serdesWord(idle, idle); 
   XUPV5_SERDES_BYTE eop    = serdesControl(28);
   XUPV5_SERDES_WORD eops   = serdesWord(eop, eop); 
   
   Clock txusrclk  = llpi.physicalDrivers.sataDriver.txusrclk;
   Reset txusrrst  = llpi.physicalDrivers.sataDriver.txusrrst;
   Clock rxusrclk0 = llpi.physicalDrivers.sataDriver.rxusrclk0;
   Reset rxusrrst0 = llpi.physicalDrivers.sataDriver.rxusrrst0;
   Clock rxusrclk1 = llpi.physicalDrivers.sataDriver.rxusrclk1;
   Reset rxusrrst1 = llpi.physicalDrivers.sataDriver.rxusrrst1;

   Reg#(Bit#(48))  rxword0 <- mkDReg(zeroExtend(pack(idles)), reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(Bit#(48))  err0 <- mkReg(0, reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(Bit#(48))  cnt0 <- mkReg(0, reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(Bool)      new_rx_seed0 <- mkReg(True, reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(XUPV5_SERDES_WORD) last_rxword0 <- mkReg(idles, reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(Bit#(48))  rxword1 <- mkDReg(zeroExtend(pack(idles)), reset_by rxusrrst1, clocked_by rxusrclk1);
   Reg#(Bit#(48))  err1 <- mkReg(0, reset_by rxusrrst1, clocked_by rxusrclk1);
   Reg#(Bit#(48))  cnt1 <- mkReg(0, reset_by rxusrrst1, clocked_by rxusrclk1);
   let chipscope <- mkXUPV5_CHIPSCOPES(txusrclk, rxusrclk0, rxusrclk1);      
   
   LFSR#(Bit#(16)) tx_sz   <- mkLFSR_16(reset_by txusrrst, clocked_by txusrclk);
   Reg#(Bit#(10))  tx_cnt  <- mkReg(0, reset_by txusrrst, clocked_by txusrclk);
   LFSR#(Bit#(16)) tx_prbs <- mkLFSR_16(reset_by txusrrst, clocked_by txusrclk);
   LFSR#(Bit#(16)) rx_prbs <- mkLFSR_16(reset_by rxusrrst0, clocked_by rxusrclk0);
   Reg#(Bool)      init    <- mkReg(False, reset_by txusrrst, clocked_by txusrclk);
      
   // txusrclk domain
   rule initialize(!init);
      tx_sz.seed(16'h9a41);
      tx_prbs.seed(16'ha3d7);
      tx_cnt <= 0;
      init <= True;
   endrule

   rule txusrclk_tick (True);
      chipscope.tx_vio0.async_in({chipscope.tx_vio0.async_out[31:1],pack(llpi.physicalDrivers.sataDriver.plllkdet_out)});
      chipscope.tx_vio1.async_in(chipscope.tx_vio1.async_out);
   endrule
   
   rule send_data0 (init);
      if (tx_cnt == 0)
         begin
            tx_cnt <= truncate(tx_sz.value());
            tx_sz.next();
            llpi.physicalDrivers.sataDriver.send0(eops);
         end
      else
         begin
            let prbs_val = tx_prbs.value();
            let serdes_msb = serdesData(prbs_val[15:8]);
            let serdes_lsb = serdesData(prbs_val[7:0]);
            tx_cnt <= tx_cnt - 1;
            llpi.physicalDrivers.sataDriver.send0(serdesWord(serdes_msb,serdes_lsb));
         end
      tx_prbs.next();
   endrule
   
   // rxusrclk0 domain
   rule rxusrclk0_tick (True);
      chipscope.rx_data_ila0.trig_in(rxword0);
      chipscope.rx_err_ila0.trig_in(err0);
      chipscope.rx_cnt_ila0.trig_in(cnt0);
      chipscope.rx_vio0.async_in(chipscope.rx_vio0.async_out);
   endrule
   
   // rxusrclk1 domain
   rule rxusrclk1_tick (True);
      chipscope.rx_data_ila1.trig_in(rxword1);
      chipscope.rx_err_ila1.trig_in(err1);
      chipscope.rx_cnt_ila1.trig_in(cnt1);
      chipscope.rx_vio1.async_in(chipscope.rx_vio1.async_out);
   endrule
   
   // rxusrclk0 domain
   rule getReceiveData0 (True);
      let rxword <- llpi.physicalDrivers.sataDriver.receive0();
      if (rxword.lsb.isK) // assume alwas word aligned, so this word is control
         begin
            if (rxword == eops) // only care if control is eops
               begin
                  new_rx_seed0 <= True;
               end
         end
      else // data word
         begin
            if (new_rx_seed0) 
               begin
                  new_rx_seed0 <= False;
                  rx_prbs.seed({rxword.msb.data,rxword.lsb.data});
               end
            else
               begin
                  rx_prbs.next();
               end
         end
      if (!last_rxword0.lsb.isK) // if last data not control, check
         begin
            let prbs_val = rx_prbs.value();
            let serdes_msb = serdesData(prbs_val[15:8]);
            let serdes_lsb = serdesData(prbs_val[7:0]);
            let check_word = serdesWord(serdes_msb,serdes_lsb);
            if (last_rxword0 != check_word)
               begin
                  err0 <= err0 + 1;
               end
            cnt0 <= cnt0 + 1;
         end
      last_rxword0 <= rxword;
      rxword0 <= zeroExtend(pack(rxword));
   endrule

   // rxusrclk1 domain
   rule getReceiveData1 (True);
      let rxword <- llpi.physicalDrivers.sataDriver.receive1();
      rxword1 <= zeroExtend(pack(rxword));
      cnt1 <= cnt1 + 1;
   endrule
   
endmodule
