#include "GeneratedTypes.h"
#ifdef PORTAL_JSON
#include "jsoncpp/json/json.h"

int ConnectalProcIndicationJson_sendMessage ( struct PortalInternal *p, const uint32_t mess )
{
    Json::Value request;
    request.append(Json::Value("sendMessage"));
    request.append((Json::UInt64)mess);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_ConnectalProcIndication_sendMessage);
    return 0;
};

int ConnectalProcIndicationJson_wroteWord ( struct PortalInternal *p, const uint32_t data )
{
    Json::Value request;
    request.append(Json::Value("wroteWord"));
    request.append((Json::UInt64)data);

    std::string requestjson = Json::FastWriter().write(request);;
    connectalJsonSend(p, requestjson.c_str(), (int)CHAN_NUM_ConnectalProcIndication_wroteWord);
    return 0;
};

ConnectalProcIndicationCb ConnectalProcIndicationJsonProxyReq = {
    portal_disconnect,
    ConnectalProcIndicationJson_sendMessage,
    ConnectalProcIndicationJson_wroteWord,
};
ConnectalProcIndicationCb *pConnectalProcIndicationJsonProxyReq = &ConnectalProcIndicationJsonProxyReq;
const char * ConnectalProcIndicationJson_methodSignatures()
{
    return "{\"sendMessage\": [\"long\"], \"wroteWord\": [\"long\"]}";
}

int ConnectalProcIndicationJson_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalProcIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    Json::Value msg = Json::Value(connectalJsonReceive(p));
    switch (channel) {
    case CHAN_NUM_ConnectalProcIndication_sendMessage: {
        ((ConnectalProcIndicationCb *)p->cb)->sendMessage(p, tempdata.sendMessage.mess);
      } break;
    case CHAN_NUM_ConnectalProcIndication_wroteWord: {
        ((ConnectalProcIndicationCb *)p->cb)->wroteWord(p, tempdata.wroteWord.data);
      } break;
    default:
        PORTAL_PRINTF("ConnectalProcIndicationJson_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalProcIndicationJson_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
#endif /* PORTAL_JSON */
