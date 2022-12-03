#include "GeneratedTypes.h"

int XsimMsgRequest_msgSink ( struct PortalInternal *p, const uint32_t portal, const uint32_t data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_XsimMsgRequest_msgSink, 3);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_XsimMsgRequest_msgSink, "XsimMsgRequest_msgSink")) return 1;
    p->transport->write(p, &temp_working_addr, portal);
    p->transport->write(p, &temp_working_addr, data);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_XsimMsgRequest_msgSink << 16) | 3, -1);
    return 0;
};

int XsimMsgRequest_msgSinkFd ( struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_XsimMsgRequest_msgSinkFd, 3);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_XsimMsgRequest_msgSinkFd, "XsimMsgRequest_msgSinkFd")) return 1;
    p->transport->write(p, &temp_working_addr, portal);
    p->transport->writefd(p, &temp_working_addr, data);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_XsimMsgRequest_msgSinkFd << 16) | 3, data);
    return 0;
};

XsimMsgRequestCb XsimMsgRequestProxyReq = {
    portal_disconnect,
    XsimMsgRequest_msgSink,
    XsimMsgRequest_msgSinkFd,
};
XsimMsgRequestCb *pXsimMsgRequestProxyReq = &XsimMsgRequestProxyReq;

const uint32_t XsimMsgRequest_reqinfo = 0x2000c;
const char * XsimMsgRequest_methodSignatures()
{
    return "{\"msgSink\": [\"long\", \"long\"], \"msgSinkFd\": [\"long\", \"long\"]}";
}

int XsimMsgRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    XsimMsgRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_XsimMsgRequest_msgSink: {
        p->transport->recv(p, temp_working_addr, 2, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSink.portal = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSink.data = (uint32_t)(((tmp)&0xfffffffful));
        ((XsimMsgRequestCb *)p->cb)->msgSink(p, tempdata.msgSink.portal, tempdata.msgSink.data);
      } break;
    case CHAN_NUM_XsimMsgRequest_msgSinkFd: {
        p->transport->recv(p, temp_working_addr, 2, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSinkFd.portal = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.msgSinkFd.data = messageFd;
        ((XsimMsgRequestCb *)p->cb)->msgSinkFd(p, tempdata.msgSinkFd.portal, tempdata.msgSinkFd.data);
      } break;
    default:
        PORTAL_PRINTF("XsimMsgRequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("XsimMsgRequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
