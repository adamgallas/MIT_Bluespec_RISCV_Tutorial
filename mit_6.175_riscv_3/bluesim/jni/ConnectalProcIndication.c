#include "GeneratedTypes.h"

int ConnectalProcIndication_sendMessage ( struct PortalInternal *p, const uint32_t mess )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_ConnectalProcIndication_sendMessage, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_ConnectalProcIndication_sendMessage, "ConnectalProcIndication_sendMessage")) return 1;
    p->transport->write(p, &temp_working_addr, mess);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_ConnectalProcIndication_sendMessage << 16) | 2, -1);
    return 0;
};

int ConnectalProcIndication_wroteWord ( struct PortalInternal *p, const uint32_t data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_ConnectalProcIndication_wroteWord, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_ConnectalProcIndication_wroteWord, "ConnectalProcIndication_wroteWord")) return 1;
    p->transport->write(p, &temp_working_addr, data);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_ConnectalProcIndication_wroteWord << 16) | 2, -1);
    return 0;
};

ConnectalProcIndicationCb ConnectalProcIndicationProxyReq = {
    portal_disconnect,
    ConnectalProcIndication_sendMessage,
    ConnectalProcIndication_wroteWord,
};
ConnectalProcIndicationCb *pConnectalProcIndicationProxyReq = &ConnectalProcIndicationProxyReq;

const uint32_t ConnectalProcIndication_reqinfo = 0x20008;
const char * ConnectalProcIndication_methodSignatures()
{
    return "{\"sendMessage\": [\"long\"], \"wroteWord\": [\"long\"]}";
}

int ConnectalProcIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalProcIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_ConnectalProcIndication_sendMessage: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sendMessage.mess = (uint32_t)(((tmp)&0x3fffful));
        ((ConnectalProcIndicationCb *)p->cb)->sendMessage(p, tempdata.sendMessage.mess);
      } break;
    case CHAN_NUM_ConnectalProcIndication_wroteWord: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.wroteWord.data = (uint32_t)(((tmp)&0xfffffffful));
        ((ConnectalProcIndicationCb *)p->cb)->wroteWord(p, tempdata.wroteWord.data);
      } break;
    default:
        PORTAL_PRINTF("ConnectalProcIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalProcIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
