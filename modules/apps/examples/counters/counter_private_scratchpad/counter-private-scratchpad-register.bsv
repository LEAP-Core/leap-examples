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

/* Filename        : counter-private-scratchpad-register.bsv
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
 */

import List   :: *;
import Vector :: *;

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

/* Type        : STATE
 * Description : The STATE type is used to track the state of the counter
 *               module.
 */
typedef enum
{
    STATE_initialize,
    STATE_count,
    STATE_memory_read_request,
    STATE_memory_read_response,
    STATE_finish,
    STATE_exit
}
STATE
    deriving (Bits, Eq);

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

    // Allocate local registers to maintain module state and count.
    Reg #(STATE)      state <- mkReg(STATE_initialize);
    Reg #(Bit #(32))  count <- mkReg(0);

    // Allocate a local register to store read response from the external memory interface.
    // Use a Maybe type to tag valid and invalid data.
    Reg #(Maybe #(DATA_T))       readResponse <- mkReg(tagged Invalid);

    // Allocate 16 x 32-bit memory elements.
    MEMORY_IFC#(ADDR_T, DATA_T)  memory       <- mkScratchpad(`VDEV_SCRATCH_COUNT, defaultValue);

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
        count <= count + 1;                 // Increment the count.
        memory.write(1, count);             // Write the count to external memory.
        readResponse  <= tagged Invalid;    // Invalidate the memory read response.
        state <= STATE_memory_read_request; // Perform a state transition to the memory read request state.
    endrule : rule_count

    /* Rule        : rule_memory_read_request
     * Description : Issue a memory read request.
     */
    rule rule_memory_read_request ( state == STATE_memory_read_request );
        memory.readReq(1);                   // Issue a memory read request.
        state <= STATE_memory_read_response; // Perform a state transition to the memory read response state.
    endrule : rule_memory_read_request

    /* Rule        : rule_memory_read_response
     * Description : Wait for a memory read response.
     *               Check if the count has reached 10 and finish counting if yes, else continue counting.
     */
    rule rule_memory_read_response ( state == STATE_memory_read_response );
        let data      <- memory.readRsp();               // Obtain the memory read response.
        readResponse  <= tagged Valid data;              // Store the memory read response data.
        stdio.printf(msgCount, list1(zeroExtend(data))); // Display valid memory read responses.
        if ( data == 10 ) begin
            state     <= STATE_finish; // Perform a state transition to the finish state if the count has reached 10.
        end
        else begin
            state     <= STATE_count;  // Perform a state transition to the count state, to keep counting.
        end
    endrule : rule_memory_read_response

    /* Rule        : rule_finish
     * Description : Finish execution.
     */
    rule rule_finish ( state == STATE_finish );
        linkStarterFinishRun.send(0);  // Send an indication that the hardware counter has finished execution.
        state <= STATE_exit;           // Perform a state transition to the exit state.
    endrule : rule_finish

endmodule
