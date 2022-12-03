#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MemServerIndicationJson_addrResponse ( struct PortalInternal *p, const uint64_t physAddr )
{
    Json::Value request;
    request.append(Json::Value("addrResponse"));
    request.append((Json::UInt64)physAddr);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerIndication_addrResponse);
    return 0;
};

int MemServerIndicationJson_reportStateDbg ( struct PortalInternal *p, const DmaDbgRec rec )
{
    Json::Value request;
    request.append(Json::Value("reportStateDbg"));
    Json::Value _recValue;
    _recValue["__type__"]="DmaDbgRec";
    _recValue["x"] = (Json::UInt64)rec.x;
    _recValue["y"] = (Json::UInt64)rec.y;
    _recValue["z"] = (Json::UInt64)rec.z;
    _recValue["w"] = (Json::UInt64)rec.w;
    request.append(_recValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerIndication_reportStateDbg);
    return 0;
};

int MemServerIndicationJson_reportMemoryTraffic ( struct PortalInternal *p, const uint64_t words )
{
    Json::Value request;
    request.append(Json::Value("reportMemoryTraffic"));
    request.append((Json::UInt64)words);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerIndication_reportMemoryTraffic);
    return 0;
};

int MemServerIndicationJson_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra )
{
    Json::Value request;
    request.append(Json::Value("error"));
    request.append((Json::UInt64)code);
    request.append((Json::UInt64)sglId);
    request.append((Json::UInt64)offset);
    request.append((Json::UInt64)extra);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerIndication_error);
    return 0;
};

MemServerIndicationCb MemServerIndicationJsonProxyReq = {
    portal_disconnect,
    MemServerIndicationJson_addrResponse,
    MemServerIndicationJson_reportStateDbg,
    MemServerIndicationJson_reportMemoryTraffic,
    MemServerIndicationJson_error,
};
MemServerIndicationCb *pMemServerIndicationJsonProxyReq = &MemServerIndicationJsonProxyReq;
const char * MemServerIndicationJson_methodSignatures()
{
    return "{\"addrResponse\": [\"long\"], \"reportStateDbg\": [\"long\"], \"reportMemoryTraffic\": [\"long\"], \"error\": [\"long\", \"long\", \"long\", \"long\"]}";
}

int MemServerIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemServerIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MemServerIndication_addrResponse: {
        ((MemServerIndicationCb *)p->cb)->addrResponse(p, tempdata.addrResponse.physAddr);
      } break;
    case CHAN_NUM_MemServerIndication_reportStateDbg: {
        ((MemServerIndicationCb *)p->cb)->reportStateDbg(p, tempdata.reportStateDbg.rec);
      } break;
    case CHAN_NUM_MemServerIndication_reportMemoryTraffic: {
        ((MemServerIndicationCb *)p->cb)->reportMemoryTraffic(p, tempdata.reportMemoryTraffic.words);
      } break;
    case CHAN_NUM_MemServerIndication_error: {
        ((MemServerIndicationCb *)p->cb)->error(p, tempdata.error.code, tempdata.error.sglId, tempdata.error.offset, tempdata.error.extra);
      } break;
    default:
        PORTAL_PRINTF("MemServerIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemServerIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
