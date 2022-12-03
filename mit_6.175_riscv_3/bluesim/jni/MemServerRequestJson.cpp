#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int MemServerRequestJson_addrTrans ( struct PortalInternal *p, const uint32_t sglId, const uint32_t offset )
{
    Json::Value request;
    request.append(Json::Value("addrTrans"));
    request.append((Json::UInt64)sglId);
    request.append((Json::UInt64)offset);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerRequest_addrTrans);
    return 0;
};

int MemServerRequestJson_setTileState ( struct PortalInternal *p, const TileControl tc )
{
    Json::Value request;
    request.append(Json::Value("setTileState"));
    Json::Value _tcValue;
    _tcValue["__type__"]="TileControl";
    _tcValue["tile"] = (Json::UInt64)tc.tile;
    _tcValue["state"] = (int)tc.state;
    request.append(_tcValue);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerRequest_setTileState);
    return 0;
};

int MemServerRequestJson_stateDbg ( struct PortalInternal *p, const ChannelType rc )
{
    Json::Value request;
    request.append(Json::Value("stateDbg"));
    request.append((int)rc);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerRequest_stateDbg);
    return 0;
};

int MemServerRequestJson_memoryTraffic ( struct PortalInternal *p, const ChannelType rc )
{
    Json::Value request;
    request.append(Json::Value("memoryTraffic"));
    request.append((int)rc);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_MemServerRequest_memoryTraffic);
    return 0;
};

MemServerRequestCb MemServerRequestJsonProxyReq = {
    portal_disconnect,
    MemServerRequestJson_addrTrans,
    MemServerRequestJson_setTileState,
    MemServerRequestJson_stateDbg,
    MemServerRequestJson_memoryTraffic,
};
MemServerRequestCb *pMemServerRequestJsonProxyReq = &MemServerRequestJsonProxyReq;
const char * MemServerRequestJson_methodSignatures()
{
    return "{\"addrTrans\": [\"long\", \"long\"], \"setTileState\": [\"long\"], \"stateDbg\": [\"long\"], \"memoryTraffic\": [\"long\"]}";
}

int MemServerRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MemServerRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_MemServerRequest_addrTrans: {
        ((MemServerRequestCb *)p->cb)->addrTrans(p, tempdata.addrTrans.sglId, tempdata.addrTrans.offset);
      } break;
    case CHAN_NUM_MemServerRequest_setTileState: {
        ((MemServerRequestCb *)p->cb)->setTileState(p, tempdata.setTileState.tc);
      } break;
    case CHAN_NUM_MemServerRequest_stateDbg: {
        ((MemServerRequestCb *)p->cb)->stateDbg(p, tempdata.stateDbg.rc);
      } break;
    case CHAN_NUM_MemServerRequest_memoryTraffic: {
        ((MemServerRequestCb *)p->cb)->memoryTraffic(p, tempdata.memoryTraffic.rc);
      } break;
    default:
        PORTAL_PRINTF("MemServerRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MemServerRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
