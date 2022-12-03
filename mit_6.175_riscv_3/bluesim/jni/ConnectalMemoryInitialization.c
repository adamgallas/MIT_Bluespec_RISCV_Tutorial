#include "GeneratedTypes.h"

int ConnectalMemoryInitialization_done ( struct PortalInternal *p )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_ConnectalMemoryInitialization_done, 1);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_ConnectalMemoryInitialization_done, "ConnectalMemoryInitialization_done")) return 1;
    p->transport->write(p, &temp_working_addr, 0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_ConnectalMemoryInitialization_done << 16) | 1, -1);
    return 0;
};

int ConnectalMemoryInitialization_request ( struct PortalInternal *p, const uint32_t addr, const uint32_t data )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_ConnectalMemoryInitialization_request, 3);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_ConnectalMemoryInitialization_request, "ConnectalMemoryInitialization_request")) return 1;
    p->transport->write(p, &temp_working_addr, addr);
    p->transport->write(p, &temp_working_addr, data);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_ConnectalMemoryInitialization_request << 16) | 3, -1);
    return 0;
};

ConnectalMemoryInitializationCb ConnectalMemoryInitializationProxyReq = {
    portal_disconnect,
    ConnectalMemoryInitialization_done,
    ConnectalMemoryInitialization_request,
};
ConnectalMemoryInitializationCb *pConnectalMemoryInitializationProxyReq = &ConnectalMemoryInitializationProxyReq;

const uint32_t ConnectalMemoryInitialization_reqinfo = 0x2000c;
const char * ConnectalMemoryInitialization_methodSignatures()
{
    return "{\"done\": [], \"request\": [\"long\", \"long\"]}";
}

int ConnectalMemoryInitialization_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalMemoryInitializationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_ConnectalMemoryInitialization_done: {
        p->transport->recv(p, temp_working_addr, 0, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        ((ConnectalMemoryInitializationCb *)p->cb)->done(p);
      } break;
    case CHAN_NUM_ConnectalMemoryInitialization_request: {
        p->transport->recv(p, temp_working_addr, 2, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.request.addr = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.request.data = (uint32_t)(((tmp)&0xfffffffful));
        ((ConnectalMemoryInitializationCb *)p->cb)->request(p, tempdata.request.addr, tempdata.request.data);
      } break;
    default:
        PORTAL_PRINTF("ConnectalMemoryInitialization_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalMemoryInitialization_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
