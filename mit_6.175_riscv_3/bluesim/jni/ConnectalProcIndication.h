#include "GeneratedTypes.h"
#ifndef _CONNECTALPROCINDICATION_H_
#define _CONNECTALPROCINDICATION_H_
#include "portal.h"

class ConnectalProcIndicationProxy : public Portal {
    ConnectalProcIndicationCb *cb;
public:
    ConnectalProcIndicationProxy(int id, int tile = DEFAULT_TILE, ConnectalProcIndicationCb *cbarg = &ConnectalProcIndicationProxyReq, int bufsize = ConnectalProcIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    ConnectalProcIndicationProxy(int id, PortalTransportFunctions *transport, void *param, ConnectalProcIndicationCb *cbarg = &ConnectalProcIndicationProxyReq, int bufsize = ConnectalProcIndication_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    ConnectalProcIndicationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, ConnectalProcIndication_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&ConnectalProcIndicationProxyReq) {};
    int sendMessage ( const uint32_t mess ) { return cb->sendMessage (&pint, mess); };
    int wroteWord ( const uint32_t data ) { return cb->wroteWord (&pint, data); };
};

extern ConnectalProcIndicationCb ConnectalProcIndication_cbTable;
class ConnectalProcIndicationWrapper : public Portal {
public:
    ConnectalProcIndicationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = ConnectalProcIndication_handleMessage, int bufsize = ConnectalProcIndication_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&ConnectalProcIndication_cbTable, this, poller) {
    };
    ConnectalProcIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = ConnectalProcIndication_handleMessage, int bufsize = ConnectalProcIndication_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&ConnectalProcIndication_cbTable, transport, param, this, poller) {
    };
    ConnectalProcIndicationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, ConnectalProcIndication_reqinfo, ConnectalProcIndication_handleMessage, (void *)&ConnectalProcIndication_cbTable, this, poller) {
    };
    ConnectalProcIndicationWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, ConnectalProcIndication_reqinfo, ConnectalProcIndication_handleMessage, (void *)&ConnectalProcIndication_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("ConnectalProcIndicationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void sendMessage ( const uint32_t mess ) = 0;
    virtual void wroteWord ( const uint32_t data ) = 0;
};
#endif // _CONNECTALPROCINDICATION_H_
