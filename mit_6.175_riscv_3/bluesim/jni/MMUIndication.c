#include "GeneratedTypes.h"

int MMUIndication_idResponse ( struct PortalInternal *p, const uint32_t sglId )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMUIndication_idResponse, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMUIndication_idResponse, "MMUIndication_idResponse")) return 1;
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMUIndication_idResponse << 16) | 2, -1);
    return 0;
};

int MMUIndication_configResp ( struct PortalInternal *p, const uint32_t sglId )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMUIndication_configResp, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMUIndication_configResp, "MMUIndication_configResp")) return 1;
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMUIndication_configResp << 16) | 2, -1);
    return 0;
};

int MMUIndication_error ( struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMUIndication_error, 7);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMUIndication_error, "MMUIndication_error")) return 1;
    p->transport->write(p, &temp_working_addr, code);
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->write(p, &temp_working_addr, (offset>>32));
    p->transport->write(p, &temp_working_addr, offset);
    p->transport->write(p, &temp_working_addr, (extra>>32));
    p->transport->write(p, &temp_working_addr, extra);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMUIndication_error << 16) | 7, -1);
    return 0;
};

MMUIndicationCb MMUIndicationProxyReq = {
    portal_disconnect,
    MMUIndication_idResponse,
    MMUIndication_configResp,
    MMUIndication_error,
};
MMUIndicationCb *pMMUIndicationProxyReq = &MMUIndicationProxyReq;

const uint32_t MMUIndication_reqinfo = 0x3001c;
const char * MMUIndication_methodSignatures()
{
    return "{\"idResponse\": [\"long\"], \"configResp\": [\"long\"], \"error\": [\"long\", \"long\", \"long\", \"long\"]}";
}

int MMUIndication_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MMUIndicationData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MMUIndication_idResponse: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.idResponse.sglId = (uint32_t)(((tmp)&0xfffffffful));
        ((MMUIndicationCb *)p->cb)->idResponse(p, tempdata.idResponse.sglId);
      } break;
    case CHAN_NUM_MMUIndication_configResp: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.configResp.sglId = (uint32_t)(((tmp)&0xfffffffful));
        ((MMUIndicationCb *)p->cb)->configResp(p, tempdata.configResp.sglId);
      } break;
    case CHAN_NUM_MMUIndication_error: {
        p->transport->recv(p, temp_working_addr, 6, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.code = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.sglId = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.offset = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.offset |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.extra = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.error.extra |= (uint64_t)(((tmp)&0xfffffffful));
        ((MMUIndicationCb *)p->cb)->error(p, tempdata.error.code, tempdata.error.sglId, tempdata.error.offset, tempdata.error.extra);
      } break;
    default:
        PORTAL_PRINTF("MMUIndication_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MMUIndication_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
