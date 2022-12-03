#include "GeneratedTypes.h"
#ifndef _CONNECTALPROCREQUEST_H_
#define _CONNECTALPROCREQUEST_H_
#include "portal.h"

class ConnectalProcRequestProxy : public Portal {
    ConnectalProcRequestCb *cb;
public:
    ConnectalProcRequestProxy(int id, int tile = DEFAULT_TILE, ConnectalProcRequestCb *cbarg = &ConnectalProcRequestProxyReq, int bufsize = ConnectalProcRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    ConnectalProcRequestProxy(int id, PortalTransportFunctions *transport, void *param, ConnectalProcRequestCb *cbarg = &ConnectalProcRequestProxyReq, int bufsize = ConnectalProcRequest_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    ConnectalProcRequestProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, ConnectalProcRequest_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&ConnectalProcRequestProxyReq) {};
    int hostToCpu ( const uint32_t startpc ) { return cb->hostToCpu (&pint, startpc); };
};

extern ConnectalProcRequestCb ConnectalProcRequest_cbTable;
class ConnectalProcRequestWrapper : public Portal {
public:
    ConnectalProcRequestWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = ConnectalProcRequest_handleMessage, int bufsize = ConnectalProcRequest_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&ConnectalProcRequest_cbTable, this, poller) {
    };
    ConnectalProcRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = ConnectalProcRequest_handleMessage, int bufsize = ConnectalProcRequest_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&ConnectalProcRequest_cbTable, transport, param, this, poller) {
    };
    ConnectalProcRequestWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, ConnectalProcRequest_reqinfo, ConnectalProcRequest_handleMessage, (void *)&ConnectalProcRequest_cbTable, this, poller) {
    };
    ConnectalProcRequestWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, ConnectalProcRequest_reqinfo, ConnectalProcRequest_handleMessage, (void *)&ConnectalProcRequest_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("ConnectalProcRequestWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void hostToCpu ( const uint32_t startpc ) = 0;
};
#endif // _CONNECTALPROCREQUEST_H_
