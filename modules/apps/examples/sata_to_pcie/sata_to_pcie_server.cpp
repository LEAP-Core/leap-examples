#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <stdio.h>
#include <sys/stat.h>

#include "asim/provides/rrr.h"
#include "asim/rrr/service_ids.h"
#include "asim/provides/hybrid_application.h"

using namespace std;

// ===== service instantiation =====
SATATOPCIERRR_SERVER_CLASS SATATOPCIERRR_SERVER_CLASS::instance;

// constructor
SATATOPCIERRR_SERVER_CLASS::SATATOPCIERRR_SERVER_CLASS()
{
    // instantiate stub
    printf("SATATOPCIERRR init called\n");
    serverStub = new SATATOPCIERRR_SERVER_STUB_CLASS(this);
}

// destructor
SATATOPCIERRR_SERVER_CLASS::~SATATOPCIERRR_SERVER_CLASS()
{
    Cleanup();
}

// init
void
SATATOPCIERRR_SERVER_CLASS::Init(PLATFORMS_MODULE p)
{
   PLATFORMS_MODULE_CLASS::Init(p);
}

// uninit
void
SATATOPCIERRR_SERVER_CLASS::Uninit()
{
    Cleanup();
    PLATFORMS_MODULE_CLASS::Uninit();
}

// cleanup
void
SATATOPCIERRR_SERVER_CLASS::Cleanup()
{
    delete serverStub;
}

// poll
bool
SATATOPCIERRR_SERVER_CLASS::Poll()
{
  return false;
}


// F2HTwoWayMsg
void
SATATOPCIERRR_SERVER_CLASS::SataData(UINT32  sataData)
{
    printf("Received SataData %x\n", sataData);  
}


