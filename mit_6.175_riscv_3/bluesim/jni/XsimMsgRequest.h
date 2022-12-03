#include "GeneratedTypes.h"
#ifndef _XSIMMSGREQUEST_H_
#define _XSIMMSGREQUEST_H_
#include "portal.h"

class XsimMsgRequestProxy : public Portal {
    XsimMsgRequestCb *cb;
public:
    XsimMsgRequestProxy(int id, int tile = DEFAULT_TILE, XsimMsgRequestCb *cbarg = &XsimMsgRequestProxyReq, int bufsize = XsimMsgRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    XsimMsgRequestProxy(int id, PortalTransportFunctions *transport, void *param, XsimMsgRequestCb *cbarg = &XsimMsgRequestProxyReq, int bufsize = XsimMsgRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    XsimMsgRequestProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, XsimMsgRequest_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&XsimMsgRequestProxyReq) {};
    int msgSink ( const uint32_t portal, const uint32_t data ) { return cb->msgSink (&pint, portal, data); };
    int msgSinkFd ( const uint32_t portal, const SpecialTypeForSendingFd data ) { return cb->msgSinkFd (&pint, portal, data); };
};

extern XsimMsgRequestCb XsimMsgRequest_cbTable;
class XsimMsgRequestWrapper : public Portal {
public:
    XsimMsgRequestWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = XsimMsgRequest_handleMessage, int bufsize = XsimMsgRequest_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&XsimMsgRequest_cbTable, this, poller) {
    };
    XsimMsgRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = XsimMsgRequest_handleMessage, int bufsize = XsimMsgRequest_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&XsimMsgRequest_cbTable, transport, param, this, poller) {
    };
    XsimMsgRequestWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, XsimMsgRequest_reqinfo, XsimMsgRequest_handleMessage, (void *)&XsimMsgRequest_cbTable, this, poller) {
    };
    XsimMsgRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, XsimMsgRequest_reqinfo, XsimMsgRequest_handleMessage, (void *)&XsimMsgRequest_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("XsimMsgRequestWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void msgSink ( const uint32_t portal, const uint32_t data ) = 0;
    virtual void msgSinkFd ( const uint32_t portal, const SpecialTypeForSendingFd data ) = 0;
};
#endif // _XSIMMSGREQUEST_H_
