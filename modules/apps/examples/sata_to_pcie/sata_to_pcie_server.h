#ifndef _SATATOPCIERRR_
#define _SATATOPCIERRR_

#include <stdio.h>
#include <sys/time.h>

#include "asim/provides/low_level_platform_interface.h"
#include "asim/provides/rrr.h"
#include "asim/provides/hybrid_application.h"

typedef class SATATOPCIERRR_SERVER_CLASS* SATATOPCIERRR_SERVER;
class SATATOPCIERRR_SERVER_CLASS: public RRR_SERVER_CLASS,
                                  public PLATFORMS_MODULE_CLASS
{
  private:
    // self-instantiation
    static SATATOPCIERRR_SERVER_CLASS instance;
    // server stub
    RRR_SERVER_STUB serverStub;

  public:
    SATATOPCIERRR_SERVER_CLASS();
    ~SATATOPCIERRR_SERVER_CLASS();

    // static methods
    static SATATOPCIERRR_SERVER GetInstance() { return &instance; }

    // required RRR methods
    void Init(PLATFORMS_MODULE);
    void Uninit();
    void Cleanup();
    bool Poll();

    //
    // RRR service methods
    //

    void SataData(UINT32 sataData);
};



// include server stub
#include "asim/rrr/server_stub_SATATOPCIERRR.h"

#endif

