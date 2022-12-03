#include "GeneratedTypes.h"

#ifndef NO_CPP_PORTAL_CODE
extern const uint32_t ifcNamesNone = IfcNamesNone;
extern const uint32_t platformIfcNames_MemServerRequestS2H = PlatformIfcNames_MemServerRequestS2H;
extern const uint32_t platformIfcNames_MMURequestS2H = PlatformIfcNames_MMURequestS2H;
extern const uint32_t platformIfcNames_MemServerIndicationH2S = PlatformIfcNames_MemServerIndicationH2S;
extern const uint32_t platformIfcNames_MMUIndicationH2S = PlatformIfcNames_MMUIndicationH2S;
extern const uint32_t ifcNames_ConnectalProcIndicationH2S = IfcNames_ConnectalProcIndicationH2S;
extern const uint32_t ifcNames_ConnectalProcRequestS2H = IfcNames_ConnectalProcRequestS2H;
extern const uint32_t ifcNames_ConnectalMemoryInitializationS2H = IfcNames_ConnectalMemoryInitializationS2H;

/************** Start of MemServerRequestWrapper CPP ***********/
#include "MemServerRequest.h"
int MemServerRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerRequestaddrTrans_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t offset ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->addrTrans ( sglId, offset);
    return 0;
};
int MemServerRequestsetTileState_cb (  struct PortalInternal *p, const TileControl tc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->setTileState ( tc);
    return 0;
};
int MemServerRequeststateDbg_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->stateDbg ( rc);
    return 0;
};
int MemServerRequestmemoryTraffic_cb (  struct PortalInternal *p, const ChannelType rc ) {
    (static_cast<MemServerRequestWrapper *>(p->parent))->memoryTraffic ( rc);
    return 0;
};
MemServerRequestCb MemServerRequest_cbTable = {
    MemServerRequestdisconnect_cb,
    MemServerRequestaddrTrans_cb,
    MemServerRequestsetTileState_cb,
    MemServerRequeststateDbg_cb,
    MemServerRequestmemoryTraffic_cb,
};

/************** Start of MMURequestWrapper CPP ***********/
#include "MMURequest.h"
int MMURequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMURequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMURequestsglist_cb (  struct PortalInternal *p, const uint32_t sglId, const uint32_t sglIndex, const uint64_t addr, const uint32_t len ) {
    (static_cast<MMURequestWrapper *>(p->parent))->sglist ( sglId, sglIndex, addr, len);
    return 0;
};
int MMURequestregion_cb (  struct PortalInternal *p, const uint32_t sglId, const uint64_t barr12, const uint32_t index12, const uint64_t barr8, const uint32_t index8, const uint64_t barr4, const uint32_t index4, const uint64_t barr0, const uint32_t index0 ) {
    (static_cast<MMURequestWrapper *>(p->parent))->region ( sglId, barr12, index12, barr8, index8, barr4, index4, barr0, index0);
    return 0;
};
int MMURequestidRequest_cb (  struct PortalInternal *p, const SpecialTypeForSendingFd fd ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idRequest ( fd);
    return 0;
};
int MMURequestidReturn_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->idReturn ( sglId);
    return 0;
};
int MMURequestsetInterface_cb (  struct PortalInternal *p, const uint32_t interfaceId, const uint32_t sglId ) {
    (static_cast<MMURequestWrapper *>(p->parent))->setInterface ( interfaceId, sglId);
    return 0;
};
MMURequestCb MMURequest_cbTable = {
    MMURequestdisconnect_cb,
    MMURequestsglist_cb,
    MMURequestregion_cb,
    MMURequestidRequest_cb,
    MMURequestidReturn_cb,
    MMURequestsetInterface_cb,
};

/************** Start of MemServerIndicationWrapper CPP ***********/
#include "MemServerIndication.h"
int MemServerIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MemServerIndicationaddrResponse_cb (  struct PortalInternal *p, const uint64_t physAddr ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->addrResponse ( physAddr);
    return 0;
};
int MemServerIndicationreportStateDbg_cb (  struct PortalInternal *p, const DmaDbgRec rec ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportStateDbg ( rec);
    return 0;
};
int MemServerIndicationreportMemoryTraffic_cb (  struct PortalInternal *p, const uint64_t words ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->reportMemoryTraffic ( words);
    return 0;
};
int MemServerIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MemServerIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MemServerIndicationCb MemServerIndication_cbTable = {
    MemServerIndicationdisconnect_cb,
    MemServerIndicationaddrResponse_cb,
    MemServerIndicationreportStateDbg_cb,
    MemServerIndicationreportMemoryTraffic_cb,
    MemServerIndicationerror_cb,
};

/************** Start of MMUIndicationWrapper CPP ***********/
#include "MMUIndication.h"
int MMUIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int MMUIndicationidResponse_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->idResponse ( sglId);
    return 0;
};
int MMUIndicationconfigResp_cb (  struct PortalInternal *p, const uint32_t sglId ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->configResp ( sglId);
    return 0;
};
int MMUIndicationerror_cb (  struct PortalInternal *p, const uint32_t code, const uint32_t sglId, const uint64_t offset, const uint64_t extra ) {
    (static_cast<MMUIndicationWrapper *>(p->parent))->error ( code, sglId, offset, extra);
    return 0;
};
MMUIndicationCb MMUIndication_cbTable = {
    MMUIndicationdisconnect_cb,
    MMUIndicationidResponse_cb,
    MMUIndicationconfigResp_cb,
    MMUIndicationerror_cb,
};

/************** Start of XsimMsgRequestWrapper CPP ***********/
#include "XsimMsgRequest.h"
int XsimMsgRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int XsimMsgRequestmsgSink_cb (  struct PortalInternal *p, const uint32_t portal, const uint32_t data ) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->msgSink ( portal, data);
    return 0;
};
int XsimMsgRequestmsgSinkFd_cb (  struct PortalInternal *p, const uint32_t portal, const SpecialTypeForSendingFd data ) {
    (static_cast<XsimMsgRequestWrapper *>(p->parent))->msgSinkFd ( portal, data);
    return 0;
};
XsimMsgRequestCb XsimMsgRequest_cbTable = {
    XsimMsgRequestdisconnect_cb,
    XsimMsgRequestmsgSink_cb,
    XsimMsgRequestmsgSinkFd_cb,
};

/************** Start of XsimMsgIndicationWrapper CPP ***********/
#include "XsimMsgIndication.h"
int XsimMsgIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<XsimMsgIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int XsimMsgIndicationmsgSource_cb (  struct PortalInternal *p, const uint32_t portal, const uint32_t data ) {
    (static_cast<XsimMsgIndicationWrapper *>(p->parent))->msgSource ( portal, data);
    return 0;
};
XsimMsgIndicationCb XsimMsgIndication_cbTable = {
    XsimMsgIndicationdisconnect_cb,
    XsimMsgIndicationmsgSource_cb,
};

/************** Start of ConnectalProcRequestWrapper CPP ***********/
#include "ConnectalProcRequest.h"
int ConnectalProcRequestdisconnect_cb (struct PortalInternal *p) {
    (static_cast<ConnectalProcRequestWrapper *>(p->parent))->disconnect();
    return 0;
};
int ConnectalProcRequesthostToCpu_cb (  struct PortalInternal *p, const uint32_t startpc ) {
    (static_cast<ConnectalProcRequestWrapper *>(p->parent))->hostToCpu ( startpc);
    return 0;
};
ConnectalProcRequestCb ConnectalProcRequest_cbTable = {
    ConnectalProcRequestdisconnect_cb,
    ConnectalProcRequesthostToCpu_cb,
};

/************** Start of ConnectalMemoryInitializationWrapper CPP ***********/
#include "ConnectalMemoryInitialization.h"
int ConnectalMemoryInitializationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<ConnectalMemoryInitializationWrapper *>(p->parent))->disconnect();
    return 0;
};
int ConnectalMemoryInitializationdone_cb (  struct PortalInternal *p ) {
    (static_cast<ConnectalMemoryInitializationWrapper *>(p->parent))->done ( );
    return 0;
};
int ConnectalMemoryInitializationrequest_cb (  struct PortalInternal *p, const uint32_t addr, const uint32_t data ) {
    (static_cast<ConnectalMemoryInitializationWrapper *>(p->parent))->request ( addr, data);
    return 0;
};
ConnectalMemoryInitializationCb ConnectalMemoryInitialization_cbTable = {
    ConnectalMemoryInitializationdisconnect_cb,
    ConnectalMemoryInitializationdone_cb,
    ConnectalMemoryInitializationrequest_cb,
};

/************** Start of ConnectalProcIndicationWrapper CPP ***********/
#include "ConnectalProcIndication.h"
int ConnectalProcIndicationdisconnect_cb (struct PortalInternal *p) {
    (static_cast<ConnectalProcIndicationWrapper *>(p->parent))->disconnect();
    return 0;
};
int ConnectalProcIndicationsendMessage_cb (  struct PortalInternal *p, const uint32_t mess ) {
    (static_cast<ConnectalProcIndicationWrapper *>(p->parent))->sendMessage ( mess);
    return 0;
};
int ConnectalProcIndicationwroteWord_cb (  struct PortalInternal *p, const uint32_t data ) {
    (static_cast<ConnectalProcIndicationWrapper *>(p->parent))->wroteWord ( data);
    return 0;
};
ConnectalProcIndicationCb ConnectalProcIndication_cbTable = {
    ConnectalProcIndicationdisconnect_cb,
    ConnectalProcIndicationsendMessage_cb,
    ConnectalProcIndicationwroteWord_cb,
};
#endif //NO_CPP_PORTAL_CODE
