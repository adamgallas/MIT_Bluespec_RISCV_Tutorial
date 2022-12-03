#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MMUIndicationJson_idResponse ( struct PortalInternal *p, const uint32_t sglId )
{
    Json::Value request;
    request.append(Json::Value("idResponse"));
    request.append((Json::UInt64)sglId);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMUIndication_idResponse);
    return 0;
};

int MMUIndicationJson_configResp ( struct PortalInternal *p, const uint32_t sglId )
{
    Json::Value request;
    request.append(Json::Value("configResp"));
    request.append((Json::UInt64)sglId);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMUIndication_configResp);
    return 0;
};

int MMUIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra )
{
    Json::Value request;
    request.append(Json::Value("error"));
    request.append((Json::UInt64)code);
    request.append((Json::UInt64)sglId);
    request.append((Json::UInt64)offset);
    request.append((Json::UInt64)extra);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMUIndication_error);
    return 0;
};

MMUIndicationCb MMUIndicationJsonProxyReq = {
    portal_disconnect,
    MMUIndicationJson_idResponse,
    MMUIndicationJson_configResp,
    MMUIndicationJson_error,
};
MMUIndicationCb *pMMUIndicationJsonProxyReq = &MMUIndicationJsonProxyReq;
const char * MMUIndicationJson_methodSignatures()
{
    return "{\"idResponse\": [\"long\"], \"configResp\": [\"long\"], \"error\": [\"long\", \"long\", \"long\", \"long\"]}";
}

int MMUIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MMUIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MMUIndication_idResponse: {
        ((MMUIndicationCb *)p->cb)->idResponse(p, tempdata.idResponse.sglId);
      } break;
    case CHAN_NUM_MMUIndication_configResp: {
        ((MMUIndicationCb *)p->cb)->configResp(p, tempdata.configResp.sglId);
      } break;
    case CHAN_NUM_MMUIndication_error: {
        ((MMUIndicationCb *)p->cb)->error(p, tempdata.error.code, tempdata.error.sglId, tempdata.error.offset, tempdata.error.extra);
      } break;
    default:
        PORTAL_PRINTF("MMUIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MMUIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
