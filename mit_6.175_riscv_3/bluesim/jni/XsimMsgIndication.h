#include "GeneratedTypes.h"
#ifndef _XSIMMSGINDICATION_H_
#define _XSIMMSGINDICATION_H_
#include "portal.h"

class XsimMsgIndicationProxy : public Portal {
    XsimMsgIndicationCb *cb;
public:
    XsimMsgIndicationProxy(int id, int tile = DEFAULT_TILE, XsimMsgIndicationCb *cbarg = &XsimMsgIndicationProxyReq, int bufsize = XsimMsgIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    XsimMsgIndicationProxy(int id, PortalTransportFunctions *transport, void *param, XsimMsgIndicationCb *cbarg = &XsimMsgIndicationProxyReq, int bufsize = XsimMsgIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    XsimMsgIndicationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, XsimMsgIndication_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&XsimMsgIndicationProxyReq) {};
    int msgSource ( const uint32_t portal, const uint32_t data ) { return cb->msgSource (&pint, portal, data); };
};

extern XsimMsgIndicationCb XsimMsgIndication_cbTable;
class XsimMsgIndicationWrapper : public Portal {
public:
    XsimMsgIndicationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = XsimMsgIndication_handleMessage, int bufsize = XsimMsgIndication_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&XsimMsgIndication_cbTable, this, poller) {
    };
    XsimMsgIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = XsimMsgIndication_handleMessage, int bufsize = XsimMsgIndication_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&XsimMsgIndication_cbTable, transport, param, this, poller) {
    };
    XsimMsgIndicationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, XsimMsgIndication_reqinfo, XsimMsgIndication_handleMessage, (void *)&XsimMsgIndication_cbTable, this, poller) {
    };
    XsimMsgIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, XsimMsgIndication_reqinfo, XsimMsgIndication_handleMessage, (void *)&XsimMsgIndication_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("XsimMsgIndicationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void msgSource ( const uint32_t portal, const uint32_t data ) = 0;
};
#endif // _XSIMMSGINDICATION_H_
