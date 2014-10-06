
`include "soft_connections.bsh"
`include "front_panel.bsh"
`include "awb/provides/librl_bsv_base.bsh"

import Multiplier::*;

module [CONNECTED_MODULE] mkSystem ();

    // Instantiate interface to the front_panel device.
    Connection_Send#(FRONTP_MASKED_LEDS)    link_leds     <- mkConnection_Send("fpga_leds");
    Connection_Receive#(FRONTP_SWITCHES)    link_switches <- mkConnection_Receive("fpga_switches");
    Connection_Receive#(FRONTP_BUTTON_INFO) link_buttons  <- mkConnection_Receive("fpga_buttons");

    /* state */
    Multiplier      mult        <- mkMultiplier();

    Reg#(Bit#(32))  result      <- mkReg(0);
    Reg#(Bit#(16))  state       <- mkReg(0);
    Reg#(Bit#(32))  in1         <- mkReg(0);
    Reg#(Bit#(32))  in2         <- mkReg(0);
    Reg#(Bit#(1))   go          <- mkReg(0);

    /* rules */
    rule latchSwitches(True);
        FRONTP_SWITCHES sw = link_switches.receive();
        FRONTP_BUTTON_INFO btns = link_buttons.receive();
        link_switches.deq();
        link_buttons.deq();

        Bit#(4) switchVector = resize(pack(sw));
        Bit#(5) buttonVector = resize(pack(btns));

        in1 <= zeroExtend(switchVector[1:0]);
        in2 <= zeroExtend(switchVector[3:2]);

        go  <= buttonVector[2];
    endrule: latchSwitches

    rule init(state == 0 && go == 1);
        mult.load(in1, in2);
        mult.start();
        state <= 1;
    endrule: init

    rule waitForResult(state == 1 && mult.isResultReady() == True);
        result <= mult.getResult();
        state <= 2;
    endrule: waitForResult

    rule outputResult(state == 2);
        link_leds.send(FRONTP_MASKED_LEDS{ state: resize(result), mask: ~0 });
        state <= 3;
    endrule: outputResult

    rule reset(state == 3 && go == 0);
        state <= 0;
    endrule

endmodule
