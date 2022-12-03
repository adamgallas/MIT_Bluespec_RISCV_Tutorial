#include "GeneratedTypes.h"

int MMURequest_sglist ( struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMURequest_sglist, 6);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMURequest_sglist, "MMURequest_sglist")) return 1;
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->write(p, &temp_working_addr, sglIndex);
    p->transport->write(p, &temp_working_addr, (addr>>32));
    p->transport->write(p, &temp_working_addr, addr);
    p->transport->write(p, &temp_working_addr, len);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMURequest_sglist << 16) | 6, -1);
    return 0;
};

int MMURequest_region ( struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMURequest_region, 14);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMURequest_region, "MMURequest_region")) return 1;
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->write(p, &temp_working_addr, (barr12>>32));
    p->transport->write(p, &temp_working_addr, barr12);
    p->transport->write(p, &temp_working_addr, index12);
    p->transport->write(p, &temp_working_addr, (barr8>>32));
    p->transport->write(p, &temp_working_addr, barr8);
    p->transport->write(p, &temp_working_addr, index8);
    p->transport->write(p, &temp_working_addr, (barr4>>32));
    p->transport->write(p, &temp_working_addr, barr4);
    p->transport->write(p, &temp_working_addr, index4);
    p->transport->write(p, &temp_working_addr, (barr0>>32));
    p->transport->write(p, &temp_working_addr, barr0);
    p->transport->write(p, &temp_working_addr, index0);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMURequest_region << 16) | 14, -1);
    return 0;
};

int MMURequest_idRequest ( struct PortalInternal *p, const SpecialTypeForSendingFd fd )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMURequest_idRequest, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMURequest_idRequest, "MMURequest_idRequest")) return 1;
    p->transport->writefd(p, &temp_working_addr, fd);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMURequest_idRequest << 16) | 2, fd);
    return 0;
};

int MMURequest_idReturn ( struct PortalInternal *p, const uint32_t sglId )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMURequest_idReturn, 2);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMURequest_idReturn, "MMURequest_idReturn")) return 1;
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMURequest_idReturn << 16) | 2, -1);
    return 0;
};

int MMURequest_setInterface ( struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId )
{
    volatile unsigned int* temp_working_addr_start = p->transport->mapchannelReq(p, CHAN_NUM_MMURequest_setInterface, 3);
    volatile unsigned int* temp_working_addr = temp_working_addr_start;
    if (p->transport->busywait(p, CHAN_NUM_MMURequest_setInterface, "MMURequest_setInterface")) return 1;
    p->transport->write(p, &temp_working_addr, interfaceId);
    p->transport->write(p, &temp_working_addr, sglId);
    p->transport->send(p, temp_working_addr_start, (CHAN_NUM_MMURequest_setInterface << 16) | 3, -1);
    return 0;
};

MMURequestCb MMURequestProxyReq = {
    portal_disconnect,
    MMURequest_sglist,
    MMURequest_region,
    MMURequest_idRequest,
    MMURequest_idReturn,
    MMURequest_setInterface,
};
MMURequestCb *pMMURequestProxyReq = &MMURequestProxyReq;

const uint32_t MMURequest_reqinfo = 0x50038;
const char * MMURequest_methodSignatures()
{
    return "{\"sglist\": [\"long\", \"long\", \"long\", \"long\"], \"region\": [\"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\", \"long\"], \"idRequest\": [\"long\"], \"idReturn\": [\"long\"], \"setInterface\": [\"long\", \"long\"]}";
}

int MMURequest_handleMessage(struct PortalInternal *p, unsigned int channel, int messageFd)
{
    static int runaway = 0;
    int   tmp __attribute__ ((unused));
    int tmpfd __attribute__ ((unused));
    MMURequestData tempdata __attribute__ ((unused));
    memset(&tempdata, 0, sizeof(tempdata));
    volatile unsigned int* temp_working_addr = p->transport->mapchannelInd(p, channel);
    switch (channel) {
    case CHAN_NUM_MMURequest_sglist: {
        p->transport->recv(p, temp_working_addr, 5, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sglist.sglId = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sglist.sglIndex = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sglist.addr = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sglist.addr |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.sglist.len = (uint32_t)(((tmp)&0xfffffffful));
        ((MMURequestCb *)p->cb)->sglist(p, tempdata.sglist.sglId, tempdata.sglist.sglIndex, tempdata.sglist.addr, tempdata.sglist.len);
      } break;
    case CHAN_NUM_MMURequest_region: {
        p->transport->recv(p, temp_working_addr, 13, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.sglId = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr12 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr12 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.index12 = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr8 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr8 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.index8 = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr4 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr4 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.index4 = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr0 = (uint64_t)(((uint64_t)(((tmp)&0xfffffffful))<<32));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.barr0 |= (uint64_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.region.index0 = (uint32_t)(((tmp)&0xfffffffful));
        ((MMURequestCb *)p->cb)->region(p, tempdata.region.sglId, tempdata.region.barr12, tempdata.region.index12, tempdata.region.barr8, tempdata.region.index8, tempdata.region.barr4, tempdata.region.index4, tempdata.region.barr0, tempdata.region.index0);
      } break;
    case CHAN_NUM_MMURequest_idRequest: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.idRequest.fd = messageFd;
        ((MMURequestCb *)p->cb)->idRequest(p, tempdata.idRequest.fd);
      } break;
    case CHAN_NUM_MMURequest_idReturn: {
        p->transport->recv(p, temp_working_addr, 1, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.idReturn.sglId = (uint32_t)(((tmp)&0xfffffffful));
        ((MMURequestCb *)p->cb)->idReturn(p, tempdata.idReturn.sglId);
      } break;
    case CHAN_NUM_MMURequest_setInterface: {
        p->transport->recv(p, temp_working_addr, 2, &tmpfd);
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.setInterface.interfaceId = (uint32_t)(((tmp)&0xfffffffful));
        tmp = p->transport->read(p, &temp_working_addr);
        tempdata.setInterface.sglId = (uint32_t)(((tmp)&0xfffffffful));
        ((MMURequestCb *)p->cb)->setInterface(p, tempdata.setInterface.interfaceId, tempdata.setInterface.sglId);
      } break;
    default:
        PORTAL_PRINTF("MMURequest_handleMessage: unknown channel 0x%x\n", channel);
        if (runaway++ > 10) {
            PORTAL_PRINTF("MMURequest_handleMessage: too many bogus indications, exiting\n");
#ifndef __KERNEL__
            exit(-1);
#endif
        }
        return 0;
    }
    return 0;
}
