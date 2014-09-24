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

/* Filename        : counter-private-scratchpad-register-stmtfsm.bsv
 * Description     : This is a simple HW/SW hybrid application that implements
 *                   a counter in hardware, using a private scratchpad, and uses
 *                   the the streams device to display the count and status
 *                   messages from both HW and SW.
 *
 *                   This example uses a local private hardware register to
 *                   store the count and writes it to a private scratchpad.
 *
 *                   After the count has been written to the private scratchpad,
 *                   it performs a memory read request. It stores the read
 *                   response in another local register and tags it as a valid
 *                   response.
 *
 *                   This example implements the counter module's statemachine
 *                   using the StmtFSM sub-language.
 */

import List    :: *;
import StmtFSM :: *;
import Vector  :: *;

import DefaultValue :: *;

`include "awb/provides/virtual_platform.bsh"
`include "awb/provides/virtual_devices.bsh"
`include "awb/provides/common_services.bsh"
`include "awb/provides/librl_bsv.bsh"

`include "awb/provides/soft_connections.bsh"
`include "awb/provides/soft_services.bsh"
`include "awb/provides/soft_services_lib.bsh"
`include "awb/provides/soft_services_deps.bsh"

`include "awb/provides/scratchpad_memory_service.bsh"

`include "awb/dict/VDEV.bsh"

////////////////////////////////////////////////////////////////////////////////
/// Types
////////////////////////////////////////////////////////////////////////////////

/* Type        : ADDR_T
 * Description : The ADDR_T type is used to define the width of the address bus
 *               for the scratchpad memory interface. The total number of memory
 *               elements or addresses = 2^n.
 */
typedef Bit#(4)  ADDR_T; // 2^4 = 16 memory elements or addresses.

/* Type        : DATA_T
 * Description : The DATA_T type is used to define the width of each memory
 *               element, for the scratchpad memory interface.
 */
typedef Bit#(32) DATA_T;

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
    let msgInitialize <- getGlobalStringUID("HW: Initializing hardware counter, using a private scratchpad.\n");
    let msgCount      <- getGlobalStringUID("HW: Count =  %0d\n");

    // Allocate a local register to store read response from the external memory interface, and initialize it to 0.
    Reg #(DATA_T)                readResponse <- mkReg(0);

    // Allocate 16 x 32-bit memory elements.
    MEMORY_IFC#(ADDR_T, DATA_T)  memory       <- mkScratchpad(`VDEV_SCRATCH_COUNT, defaultValue);

    ///////////////////////////////////////////////////////////////////////////
    // Behaviour
    ///////////////////////////////////////////////////////////////////////////

    /* State       : initialize
     * Description : Behavioural description for initializing the hardware counter.
     */

    /* Statement   : initialize_seq
     * Description : Statements for initializing the hardware counter.
     */
    Stmt initialize_seq =
    seq
        linkStarterStartRun.deq();              // Wait for an indication to start running the hardware counter.
        memory.write(1, 0);                     // Initialize the count to 0, in external memory.
        stdio.printf(msgInitialize, List::nil); // Display hardware counter module initialization message.
    endseq;

    // ========================================================================

    /* State       : memory_read_request
     * Description : Issue a memory read request.
     */

    /* Statement   : memory_read_request_seq
     * Description : Statements for issuing a memory read request.
     */
    Stmt memory_read_request_seq =
    seq
        memory.readReq(1);                      // Issue a memory read request.
    endseq;

    // ========================================================================

    /* State       : count
     * Description : Behavioural description for incrementing the count, upto 10.
     */

    /* Statement   : count_seq
     * Description : Statements for incrementing the count and writing it to external memory.
     */
    Stmt count_seq =
    seq
        memory_read_request_seq;                             // Issue a memory read request. This
                                                             // happens on a separate clock cycle
                                                             // because of the sequential statement.
        action
            let data     <- memory.readRsp();                // Obtain the memory read response.
            readResponse <= data;                            // Store the memory read response data.
            stdio.printf(msgCount, list1(zeroExtend(data))); // Display valid memory read responses.
            data = data + 1;                                 // Increment the count.
            memory.write(1, data);                           // Write the count to external memory.
        endaction
    endseq;

    // ========================================================================

    /* State       : finish
     * Description : Finish execution.
     */

    /* Statement   : finish_seq
     * Description : Statements for finishing execution.
     */
    Stmt finish_seq =
    seq
        linkStarterFinishRun.send(0);  // Send an indication that the hardware counter has finished execution.
    endseq;

    // ========================================================================

    /* Behaviour   : counter_statemachine
     * Description : Behavioural description for the top level statemachine for
     *               the counter module.
     *
     *               In the main while loop check if the count is <=10, then
     *               loop on the count. Continue to perform the steps
     *               sequentially, and then exit.
     */

    /* Statement   : counter_statemachine_seq
     * Description : Statements for the top level statemachine for the counter
     *               module.
     */
    Stmt counter_statemachine_seq =
    seq
        initialize_seq;                // Initialize the module.
        while (readResponse != 10) seq // Increment the count upto 10, by reading
            count_seq;                 // the count value stored in external
        endseq                         // memory and incrementing its count.
        finish_seq;                    // Finish module execution.
    endseq;

    // Instantiate the FSM to sequentially execute counter_statemachine_seq.
    FSM counter_fsm <- mkFSM (counter_statemachine_seq);

    // Rule: Start the counter statemachine.
    rule startFSM (linkStarterStartRun.notEmpty());
        counter_fsm.start;
    endrule

endmodule
