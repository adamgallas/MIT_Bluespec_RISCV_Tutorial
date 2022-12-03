#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MMURequestJson_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len )
{
    Json::Value request;
    request.append(Json::Value("sglist"));
    request.append((Json::UInt64)sglId);
    request.append((Json::UInt64)sglIndex);
    request.append((Json::UInt64)addr);
    request.append((Json::UInt64)len);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMURequest_sglist);
    return 0;
};

int MMURequestJson_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 )
{
    Json::Value request;
    request.append(Json::Value("region"));
    request.append((Json::UInt64)sglId);
    request.append((Json::UInt64)barr12);
    request.append((Json::UInt64)index12);
    request.append((Json::UInt64)barr8);
    request.append((Json::UInt64)index8);
    request.append((Json::UInt64)barr4);
    request.append((Json::UInt64)index4);
    request.append((Json::UInt64)barr0);
    request.append((Json::UInt64)index0);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMURequest_region);
    return 0;
};

int MMURequestJson_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd )
{
    Json::Value request;
    request.append(Json::Value("idRequest"));
    request.append((Json::UInt64)fd);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMURequest_idRequest);
    return 0;
};

int MMURequestJson_idReturn ( struct PortalInternal *p, const uint32_t sglId )
{
    Json::Value request;
    request.append(Json::Value("idReturn"));
    request.append((Json::UInt64)sglId);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMURequest_idReturn);
    return 0;
};

int MMURequestJson_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId )
{
    Json::Value request;
    request.append(Json::Value("setInterface"));
    request.append((Json::UInt64)interfaceId);
    request.append((Json::UInt64)sglId);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MMURequest_setInterface);
    return 0;
};

MMURequestCb MMURequestJsonProxyReq = {
    portal_disconnect,
    MMURequestJson_sglist,
    MMURequestJson_region,
    MMURequestJson_idRequest,
    MMURequestJson_idReturn,
    MMURequestJson_setInterface,
};
MMURequestCb *pMMURequestJsonProxyReq = &MMURequestJsonProxyReq;
const char * MMURequestJson_methodSignatures()
{
    return "{\"sglist\": [\"long\", \"long\", \"long\", \"long\"], \"region\": [\"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\"], \"idRequest\": [\"long\"], \"idReturn\": [\"long\"], \"setInterface\": [\"long\", \"long\"]}";
}

int MMURequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MMURequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MMURequest_sglist: {
        ((MMURequestCb *)p->cb)->sglist(p, tempdata.sglist.sglId, tempdata.sglist.sglIndex, tempdata.sglist.addr, tempdata.sglist.len);
      } break;
    case CHAN_NUM_MMURequest_region: {
        ((MMURequestCb *)p->cb)->region(p, tempdata.region.sglId, tempdata.region.barr12, tempdata.region.index12, tempdata.region.barr8, tempdata.region.index8, tempdata.region.barr4, tempdata.region.index4, tempdata.region.barr0, tempdata.region.index0);
      } break;
    case CHAN_NUM_MMURequest_idRequest: {
        ((MMURequestCb *)p->cb)->idRequest(p, tempdata.idRequest.fd);
      } break;
    case CHAN_NUM_MMURequest_idReturn: {
        ((MMURequestCb *)p->cb)->idReturn(p, tempdata.idReturn.sglId);
      } break;
    case CHAN_NUM_MMURequest_setInterface: {
        ((MMURequestCb *)p->cb)->setInterface(p, tempdata.setInterface.interfaceId, tempdata.setInterface.sglId);
      } break;
    default:
        PORTAL_PRINTF("MMURequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MMURequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
