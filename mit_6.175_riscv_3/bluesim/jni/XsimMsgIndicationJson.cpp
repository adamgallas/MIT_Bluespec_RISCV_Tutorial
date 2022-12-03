#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int XsimMsgIndicationJson_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data )
{
    Json::Value request;
    request.append(Json::Value("msgSource"));
    request.append((Json::UInt64)portal);
    request.append((Json::UInt64)data);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_XsimMsgIndication_msgSource);
    return 0;
};

XsimMsgIndicationCb XsimMsgIndicationJsonProxyReq = {
    portal_disconnect,
    XsimMsgIndicationJson_msgSource,
};
XsimMsgIndicationCb *pXsimMsgIndicationJsonProxyReq = &XsimMsgIndicationJsonProxyReq;
const char * XsimMsgIndicationJson_methodSignatures()
{
    return "{\"msgSource\": [\"long\", \"long\"]}";
}

int XsimMsgIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    XsimMsgIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_XsimMsgIndication_msgSource: {
        ((XsimMsgIndicationCb *)p->cb)->msgSource(p, tempdata.msgSource.portal, tempdata.msgSource.data);
      } break;
    default:
        PORTAL_PRINTF("XsimMsgIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("XsimMsgIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
