#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <iomanip>

#include "asim/syntax.h"
#include "asim/rrr/service_ids.h"
#include "asim/provides/connected_application.h"

using namespace std;

// ===== service instantiation =====
RRRTEST_SERVER_CLASS RRRTEST_SERVER_CLASS::instance;

// constructor
RRRTEST_SERVER_CLASS::RRRTEST_SERVER_CLASS()
{
    // instantiate stub
    serverStub = new RRRTEST_SERVER_STUB_CLASS(this);
}

// destructor
RRRTEST_SERVER_CLASS::~RRRTEST_SERVER_CLASS()
{
    Cleanup();
}

// init
void
RRRTEST_SERVER_CLASS::Init(PLATFORMS_MODULE p)
{
    PLATFORMS_MODULE_CLASS::Init(p);
}

// uninit
void
RRRTEST_SERVER_CLASS::Uninit()
{
    Cleanup();
    PLATFORMS_MODULE_CLASS::Uninit();
}

// cleanup
void
RRRTEST_SERVER_CLASS::Cleanup()
{
    delete serverStub;
}

//
// RRR service methods
//

// F2HOneWayMsg
void
RRRTEST_SERVER_CLASS::F2HOneWayMsg1(
    UINT64 payload)
{
    VERIFY(MatchPayload(payload, 1),
           "F2HOneWayMsg1 unexpected payload: " << payload);
    pidx += 1;
}

void
RRRTEST_SERVER_CLASS::F2HOneWayMsg8(
    UINT64 payload0,
    UINT64 payload1,
    UINT64 payload2,
    UINT64 payload3,
    UINT64 payload4,
    UINT64 payload5,
    UINT64 payload6,
    UINT64 payload7)
{
    VERIFY(MatchPayload(payload0, 1) &&
           MatchPayload(payload1, 2) &&
           MatchPayload(payload2, 3) &&
           MatchPayload(payload3, 4) &&
           MatchPayload(payload4, 5) &&
           MatchPayload(payload5, 6) &&
           MatchPayload(payload6, 7) &&
           MatchPayload(payload7, 8),
           "F2HOneWayMsg8: Unexpected payload");
                     
    pidx += 1;
}

void
RRRTEST_SERVER_CLASS::F2HOneWayMsg16(
    UINT64 payload0,
    UINT64 payload1,
    UINT64 payload2,
    UINT64 payload3,
    UINT64 payload4,
    UINT64 payload5,
    UINT64 payload6,
    UINT64 payload7,
    UINT64 payload8,
    UINT64 payload9,
    UINT64 payload10,
    UINT64 payload11,
    UINT64 payload12,
    UINT64 payload13,
    UINT64 payload14,
    UINT64 payload15)
{
    VERIFY(MatchPayload(payload0, 1) &&
           MatchPayload(payload1, 2) &&
           MatchPayload(payload2, 3) &&
           MatchPayload(payload3, 4) &&
           MatchPayload(payload4, 5) &&
           MatchPayload(payload5, 6) &&
           MatchPayload(payload6, 7) &&
           MatchPayload(payload7, 8) &&
           MatchPayload(payload8, 9) &&
           MatchPayload(payload9, 10) &&
           MatchPayload(payload10, 11) &&
           MatchPayload(payload11, 12) &&
           MatchPayload(payload12, 13) &&
           MatchPayload(payload13, 14) &&
           MatchPayload(payload14, 15) &&
           MatchPayload(payload15, 16),
           "F2HOneWayMsg16: Unexpected payload");

    pidx += 1;
}


void
RRRTEST_SERVER_CLASS::F2HOneWayMsg32(
    UINT64 payload0,
    UINT64 payload1,
    UINT64 payload2,
    UINT64 payload3,
    UINT64 payload4,
    UINT64 payload5,
    UINT64 payload6,
    UINT64 payload7,
    UINT64 payload8,
    UINT64 payload9,
    UINT64 payload10,
    UINT64 payload11,
    UINT64 payload12,
    UINT64 payload13,
    UINT64 payload14,
    UINT64 payload15,
    UINT64 payload16,
    UINT64 payload17,
    UINT64 payload18,
    UINT64 payload19,
    UINT64 payload20,
    UINT64 payload21,
    UINT64 payload22,
    UINT64 payload23,
    UINT64 payload24,
    UINT64 payload25,
    UINT64 payload26,
    UINT64 payload27,
    UINT64 payload28,
    UINT64 payload29,
    UINT64 payload30,
    UINT64 payload31)
{

    VERIFY(MatchPayload(payload0, 1) &&
           MatchPayload(payload1, 2) &&
           MatchPayload(payload2, 3) &&
           MatchPayload(payload3, 4) &&
           MatchPayload(payload4, 5) &&
           MatchPayload(payload5, 6) &&
           MatchPayload(payload6, 7) &&
           MatchPayload(payload7, 8) &&
           MatchPayload(payload8, 9) &&
           MatchPayload(payload9, 10) &&
           MatchPayload(payload10, 11) &&
           MatchPayload(payload11, 12) &&
           MatchPayload(payload12, 13) &&
           MatchPayload(payload13, 14) &&
           MatchPayload(payload14, 15) &&
           MatchPayload(payload15, 16) &&
           MatchPayload(payload16, 17) &&
           MatchPayload(payload17, 18) &&
           MatchPayload(payload18, 19) &&
           MatchPayload(payload19, 20) &&
           MatchPayload(payload20, 21) &&
           MatchPayload(payload21, 22) &&
           MatchPayload(payload22, 23) &&
           MatchPayload(payload23, 24) &&
           MatchPayload(payload24, 25) &&
           MatchPayload(payload25, 26) &&
           MatchPayload(payload26, 27) &&
           MatchPayload(payload27, 28) &&
           MatchPayload(payload28, 29) &&
           MatchPayload(payload29, 30) &&
           MatchPayload(payload30, 31) &&
           MatchPayload(payload31, 32),
           "F2HOneWayMsg32: Unexpected payload");

    pidx += 1;
}


// F2HTwoWayMsg
UINT64
RRRTEST_SERVER_CLASS::F2HTwoWayMsg1(
    UINT64 payload)
{

    VERIFY(MatchPayload(payload, 1),
           "F2HOneWayMsg1 unexpected payload: " << payload);

    pidx += 1;

    // return the bitwise-inverted payload
    return ~payload;
}


OUT_TYPE_F2HTwoWayMsg16
RRRTEST_SERVER_CLASS::F2HTwoWayMsg16(
    UINT64 payload0,
    UINT64 payload1,
    UINT64 payload2,
    UINT64 payload3,
    UINT64 payload4,
    UINT64 payload5,
    UINT64 payload6,
    UINT64 payload7,
    UINT64 payload8,
    UINT64 payload9,
    UINT64 payload10,
    UINT64 payload11,
    UINT64 payload12,
    UINT64 payload13,
    UINT64 payload14,
    UINT64 payload15)
{
    VERIFY(MatchPayload(payload0, 1) &&
           MatchPayload(payload1, 2) &&
           MatchPayload(payload2, 3) &&
           MatchPayload(payload3, 4) &&
           MatchPayload(payload4, 5) &&
           MatchPayload(payload5, 6) &&
           MatchPayload(payload6, 7) &&
           MatchPayload(payload7, 8) &&
           MatchPayload(payload8, 9) &&
           MatchPayload(payload9, 10) &&
           MatchPayload(payload10, 11) &&
           MatchPayload(payload11, 12) &&
           MatchPayload(payload12, 13) &&
           MatchPayload(payload13, 14) &&
           MatchPayload(payload14, 15) &&
           MatchPayload(payload15, 16),
           "F2HTwoWayMsg16: Unexpected payload");

    OUT_TYPE_F2HTwoWayMsg16 r;
    r.return0 = payload0;
    r.return1 = payload1;
    r.return2 = payload2;
    r.return3 = payload3;
    r.return4 = payload4;
    r.return5 = payload5;
    r.return6 = payload6;
    r.return7 = payload7;
    r.return8 = payload8;
    r.return9 = payload9;
    r.return10 = payload10;
    r.return11 = payload11;
    r.return12 = payload12;
    r.return13 = payload13;
    r.return14 = payload14;
    r.return15 = payload15;
    pidx += 1;
}
