`include "awb/provides/librl_bsv_base.bsh"
`include "soft_connections.bsh"
`include "front_panel.bsh"

// This basic system copies the value provided by the FPGA switches
// to the leds.  

module [CONNECTED_MODULE] mkSystem ();

    // Instantiate interface to the front_panel device.
    Connection_Send#(FRONTP_MASKED_LEDS)    link_leds     <- mkConnection_Send("fpga_leds");
    Connection_Receive#(FRONTP_SWITCHES)    link_switches <- mkConnection_Receive("fpga_switches");

    // Whenever we get an update to the switch devices, update the LEDs
    rule switch_to_led (True);

        // Receive update from switch device
        FRONTP_SWITCHES sw = link_switches.receive();
        link_switches.deq();
        
        Bit#(4) inp = sw[3:0];  // this assumes FRONTP_SWITCHES has at least 4 bits

        // Update the LEDs with the new switch value
        link_leds.send(FRONTP_MASKED_LEDS{ state: truncate(inp), mask: ~0 });
    endrule


endmodule
