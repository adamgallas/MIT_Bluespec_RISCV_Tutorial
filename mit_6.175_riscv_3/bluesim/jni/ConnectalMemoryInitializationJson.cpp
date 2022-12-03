#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int ConnectalMemoryInitializationJson_done ( struct PortalInternal *p )
{
    Json::Value request;
    request.append(Json::Value("done"));
    

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_ConnectalMemoryInitialization_done);
    return 0;
};

int ConnectalMemoryInitializationJson_request ( struct PortalInternal *p, const uint32_t addr, const uint32_t data )
{
    Json::Value request;
    request.append(Json::Value("request"));
    request.append((Json::UInt64)addr);
    request.append((Json::UInt64)data);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_ConnectalMemoryInitialization_request);
    return 0;
};

ConnectalMemoryInitializationCb ConnectalMemoryInitializationJsonProxyReq = {
    portal_disconnect,
    ConnectalMemoryInitializationJson_done,
    ConnectalMemoryInitializationJson_request,
};
ConnectalMemoryInitializationCb *pConnectalMemoryInitializationJsonProxyReq = &ConnectalMemoryInitializationJsonProxyReq;
const char * ConnectalMemoryInitializationJson_methodSignatures()
{
    return "{\"done\": [], \"request\": [\"long\", \"long\"]}";
}

int ConnectalMemoryInitializationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalMemoryInitializationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_ConnectalMemoryInitialization_done: {
        ((ConnectalMemoryInitializationCb *)p->cb)->done(p);
      } break;
    case CHAN_NUM_ConnectalMemoryInitialization_request: {
        ((ConnectalMemoryInitializationCb *)p->cb)->request(p, tempdata.request.addr, tempdata.request.data);
      } break;
    default:
        PORTAL_PRINTF("ConnectalMemoryInitializationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalMemoryInitializationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
