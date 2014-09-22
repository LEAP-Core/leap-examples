// The MIT License (MIT)
//
// Copyright (c) 2014 Elvis Dowson.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/* Filename        : counter-private-register.bsv
 * Description     : This is a simple HW/SW hybrid application that implements
 *                   a counter in hardware, using a private hardware register,
 *                   and uses the the streams device to display the count and
 *                   status messages from both HW and SW.
 */

import List   :: *;
import Vector :: *;

`include "awb/provides/virtual_platform.bsh"
`include "awb/provides/virtual_devices.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"

////////////////////////////////////////////////////////////////////////////////
/// Types
////////////////////////////////////////////////////////////////////////////////

/* Type        : STATE
 * Description : The STATE type is used to track the state of the counter
 *               module.
 */
typedef enum
{
    STATE_initialize,
    STATE_count,
    STATE_finish,
    STATE_exit
}
STATE
    deriving (Bits, Eq);

////////////////////////////////////////////////////////////////////////////////
/// Modules
////////////////////////////////////////////////////////////////////////////////

module [CONNECTED_MODULE] mkConnectedApplication ();

    ///////////////////////////////////////////////////////////////////////////
    // Design elements
    ///////////////////////////////////////////////////////////////////////////

    // Indications that are sent and received from the hardware counter module:
    // - linkStarterStartRun is an indication that is sent to this module to start running.
    // - linkStarterFinishRun  is an indication that is sent from this module, to indicate that it has finished running.
    Connection_Receive#(Bool) linkStarterStartRun <- mkConnectionRecv("vdev_starter_start_run");
    Connection_Send#(Bit#(8)) linkStarterFinishRun <- mkConnectionSend("vdev_starter_finish_run");

    // Declare output device for debug messages.
    STDIO#(Bit#(32)) stdio <- mkStdIO();

    // Declare strings for debug messages.
    let msgInitialize <- getGlobalStringUID("HW: Initializing hardware counter, using a private register\n");
    let msgCount      <- getGlobalStringUID("HW: Count =  %0d\n");

    // Allocate local registers to maintain module state and count.
    Reg #(STATE)      state <- mkReg(STATE_initialize);
    Reg #(Bit #(32))  count <- mkReg(0);

    ///////////////////////////////////////////////////////////////////////////
    // Behaviour
    ///////////////////////////////////////////////////////////////////////////

    /* Rule        : rule_initialize
     * Description : Initialize the hardware counter.
     */
    rule rule_initialize ( state == STATE_initialize );
        linkStarterStartRun.deq();              // Wait for an indication to start running the hardware counter.
        stdio.printf(msgInitialize, List::nil); // Display hardware counter module initialization message.
        state <= STATE_count;                   // Perform a state transition to the count state.
    endrule : rule_initialize

    /* Rule        : rule_count
     * Description : Increment the count, upto 10.
     */
    rule rule_count ( state == STATE_count && count <= 10 );
        count <= count + 1;                               // Increment the count.
        stdio.printf(msgCount, list1(zeroExtend(count))); // Display the count.
    endrule : rule_count

    /* Rule        : rule_finish
     * Description : Finish execution.
     */
    rule rule_finish ( state == STATE_count && count > 10 );
        linkStarterFinishRun.send(0); // Send an indication that the hardware counter has finished execution.
        state <= STATE_finish;        // Perform a state transition to the finish state.
    endrule : rule_finish

    /* Rule        : rule_exit
     * Description : Exit.
     */
    rule rule_exit ( state == STATE_finish );
        state <= STATE_exit;          // Perform a state transition to the exit state.
    endrule : rule_exit

endmodule
