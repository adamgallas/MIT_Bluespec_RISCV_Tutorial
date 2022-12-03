#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int XsimMsgRequestJson_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data )
{
    Json::Value request;
    request.append(Json::Value("msgSink"));
    request.append((Json::UInt64)portal);
    request.append((Json::UInt64)data);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_XsimMsgRequest_msgSink);
    return 0;
};

int XsimMsgRequestJson_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data )
{
    Json::Value request;
    request.append(Json::Value("msgSinkFd"));
    request.append((Json::UInt64)portal);
    request.append((Json::UInt64)data);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_XsimMsgRequest_msgSinkFd);
    return 0;
};

XsimMsgRequestCb XsimMsgRequestJsonProxyReq = {
    portal_disconnect,
    XsimMsgRequestJson_msgSink,
    XsimMsgRequestJson_msgSinkFd,
};
XsimMsgRequestCb *pXsimMsgRequestJsonProxyReq = &XsimMsgRequestJsonProxyReq;
const char * XsimMsgRequestJson_methodSignatures()
{
    return "{\"msgSink\": [\"long\", \"long\"], \"msgSinkFd\": [\"long\", \"long\"]}";
}

int XsimMsgRequestJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    XsimMsgRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_XsimMsgRequest_msgSink: {
        ((XsimMsgRequestCb *)p->cb)->msgSink(p, tempdata.msgSink.portal, tempdata.msgSink.data);
      } break;
    case CHAN_NUM_XsimMsgRequest_msgSinkFd: {
        ((XsimMsgRequestCb *)p->cb)->msgSinkFd(p, tempdata.msgSinkFd.portal, tempdata.msgSinkFd.data);
      } break;
    default:
        PORTAL_PRINTF("XsimMsgRequestJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("XsimMsgRequestJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
