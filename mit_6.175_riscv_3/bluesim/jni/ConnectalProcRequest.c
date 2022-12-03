#include "GeneratedTypes.h"

int ConnectalProcRequest_hostToCpu ( struct PortalInternal *p, const uint32_t startpc )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_ConnectalProcRequest_hostToCpu, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_ConnectalProcRequest_hostToCpu, "ConnectalProcRequest_hostToCpu")) return 1;
    p->transport->write(p, &temp_working_addr, startpc);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_ConnectalProcRequest_hostToCpu << 16) | 2, -1);
    return 0;
};

ConnectalProcRequestCb ConnectalProcRequestProxyReq = {
    portal_disconnect,
    ConnectalProcRequest_hostToCpu,
};
ConnectalProcRequestCb *pConnectalProcRequestProxyReq = &ConnectalProcRequestProxyReq;

const uint32_t ConnectalProcRequest_reqinfo = 0x10008;
const char * ConnectalProcRequest_methodSignatures()
{
    return "{\"hostToCpu\": [\"long\"]}";
}

int ConnectalProcRequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    ConnectalProcRequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_ConnectalProcRequest_hostToCpu: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.hostToCpu.startpc = (uint32_t)(((tmp)&0xfffffffful));
        ((ConnectalProcRequestCb *)p->cb)->hostToCpu(p, tempdata.hostToCpu.startpc);
      } break;
    default:
        PORTAL_PRINTF("ConnectalProcRequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("ConnectalProcRequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
