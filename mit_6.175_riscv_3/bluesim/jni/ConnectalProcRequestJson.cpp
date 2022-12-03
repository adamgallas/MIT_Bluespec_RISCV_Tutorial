#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int ConnectalProcRequestJson_hostToCpu ( struct PortalInternal *p, const uint32_t startpc )
{
    Json::Value request;
    request.append(Json::Value("hostToCpu"));
    request.append((Json::UInt64)startpc);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_ConnectalProcRequest_hostToCpu);
    return 0;
};

ConnectalProcRequestCb ConnectalProcRequestJsonProxyReq = {
    portal_disconnect,
    ConnectalProcRequestJson_hostToCpu,
};
ConnectalProcRequestCb *pConnectalProcRequestJsonProxyReq = &ConnectalProcRequestJsonProxyReq;
const char * ConnectalProcRequestJson_methodSignatures()
{
    return "{\"hostToCpu\": [\"long\"]}";
}

int ConnectalProcRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalProcRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_ConnectalProcRequest_hostToCpu: {
        ((ConnectalProcRequestCb *)p->cb)->hostToCpu(p, tempdata.hostToCpu.startpc);
      } break;
    default:
        PORTAL_PRINTF("ConnectalProcRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalProcRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
