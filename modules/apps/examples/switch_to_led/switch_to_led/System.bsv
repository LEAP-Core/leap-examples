import Counter::*;

`include "soft_connections.bsh"
`include "front_panel.bsh"
`include "awb/provides/librl_bsv_base.bsh"

module [CONNECTED_MODULE] mkSystem ();

    // Instantiate interface to the front_panel device.
    Connection_Send#(FRONTP_MASKED_LEDS)    link_leds     <- mkConnection_Send("fpga_leds");
    Connection_Receive#(FRONTP_SWITCHES)    link_switches <- mkConnection_Receive("fpga_switches");


    Counter         counter <- mkCounter();
    Reg#(Bit#(16))  state   <- mkReg(0);


    rule step0(state == 0);
        // Receive update from switch device
        FRONTP_SWITCHES sw = link_switches.receive();
        link_switches.deq();

        Bit#(8) extended = zeroExtend(sw);
        counter.load(extended);
        state <= 1;
    endrule

    rule step1(state == 1);
        let value = counter.read();

        // Update the LEDs with the new switch value
        link_leds.send(FRONTP_MASKED_LEDS{ state: resize(value), mask: ~0 });
        state <= 2;
    endrule

    rule done(state == 2);
        state <= 0;
    endrule


endmodule
