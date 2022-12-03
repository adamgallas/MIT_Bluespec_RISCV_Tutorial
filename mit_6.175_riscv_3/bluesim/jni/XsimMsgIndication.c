#include "GeneratedTypes.h"

int XsimMsgIndication_msgSource ( struct PortalInternal *p, const uint32_t portal, const uint32_t data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_XsimMsgIndication_msgSource, 3);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_XsimMsgIndication_msgSource, "XsimMsgIndication_msgSource")) return 1;
    p->transport->write(p, &temp_working_addr, portal);
    p->transport->write(p, &temp_working_addr, data);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_XsimMsgIndication_msgSource << 16) | 3, -1);
    return 0;
};

XsimMsgIndicationCb XsimMsgIndicationProxyReq = {
    portal_disconnect,
    XsimMsgIndication_msgSource,
};
XsimMsgIndicationCb *pXsimMsgIndicationProxyReq = &XsimMsgIndicationProxyReq;

const uint32_t XsimMsgIndication_reqinfo = 0x1000c;
const char * XsimMsgIndication_methodSignatures()
{
    return "{\"msgSource\": [\"long\", \"long\"]}";
}

int XsimMsgIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    XsimMsgIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_XsimMsgIndication_msgSource: {
        p->transport->recv(p, temp_working_addr, 2, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSource.portal = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSource.data = (uint32_t)(((tmp)&0xfffffffful));
        ((XsimMsgIndicationCb *)p->cb)->msgSource(p, tempdata.msgSource.portal, tempdata.msgSource.data);
      } break;
    default:
        PORTAL_PRINTF("XsimMsgIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("XsimMsgIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
