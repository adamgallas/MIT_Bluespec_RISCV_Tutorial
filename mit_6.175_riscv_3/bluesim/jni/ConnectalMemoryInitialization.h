#include "GeneratedTypes.h"
#ifndef _CONNECTALMEMORYINITIALIZATION_H_
#define _CONNECTALMEMORYINITIALIZATION_H_
#include "portal.h"

class ConnectalMemoryInitializationProxy : public Portal {
    ConnectalMemoryInitializationCb *cb;
public:
    ConnectalMemoryInitializationProxy(int id, int tile = DEFAULT_TILE, ConnectalMemoryInitializationCb *cbarg = &ConnectalMemoryInitializationProxyReq, int bufsize = ConnectalMemoryInitialization_reqinfo, PortalPoller *poller = 0) :
        Portal(id, tile, bufsize, NULL, NULL, this, poller), cb(cbarg) {};
    ConnectalMemoryInitializationProxy(int id, PortalTransportFunctions *transport, void *param, ConnectalMemoryInitializationCb *cbarg = &ConnectalMemoryInitializationProxyReq, int bufsize = ConnectalMemoryInitialization_reqinfo, PortalPoller *poller = 0) :
        Portal(id, DEFAULT_TILE, bufsize, NULL, NULL, transport, param, this, poller), cb(cbarg) {};
    ConnectalMemoryInitializationProxy(int id, PortalPoller *poller) :
        Portal(id, DEFAULT_TILE, ConnectalMemoryInitialization_reqinfo, NULL, NULL, NULL, NULL, this, poller), cb(&ConnectalMemoryInitializationProxyReq) {};
    int done (  ) { return cb->done (&pint); };
    int request ( const uint32_t addr, const uint32_t data ) { return cb->request (&pint, addr, data); };
};

extern ConnectalMemoryInitializationCb ConnectalMemoryInitialization_cbTable;
class ConnectalMemoryInitializationWrapper : public Portal {
public:
    ConnectalMemoryInitializationWrapper(int id, int tile = DEFAULT_TILE, PORTAL_INDFUNC cba = ConnectalMemoryInitialization_handleMessage, int bufsize = ConnectalMemoryInitialization_reqinfo, PortalPoller *poller = 0) :
           Portal(id, tile, bufsize, cba, (void *)&ConnectalMemoryInitialization_cbTable, this, poller) {
    };
    ConnectalMemoryInitializationWrapper(int id, PortalTransportFunctions *transport, void *param, PORTAL_INDFUNC cba = ConnectalMemoryInitialization_handleMessage, int bufsize = ConnectalMemoryInitialization_reqinfo, PortalPoller *poller=0):
           Portal(id, DEFAULT_TILE, bufsize, cba, (void *)&ConnectalMemoryInitialization_cbTable, transport, param, this, poller) {
    };
    ConnectalMemoryInitializationWrapper(int id, PortalPoller *poller) :
           Portal(id, DEFAULT_TILE, ConnectalMemoryInitialization_reqinfo, ConnectalMemoryInitialization_handleMessage, (void *)&ConnectalMemoryInitialization_cbTable, this, poller) {
    };
    ConnectalMemoryInitializationWrapper(int id, PortalTransportFunctions *transport, void *param, PortalPoller *poller):
           Portal(id, DEFAULT_TILE, ConnectalMemoryInitialization_reqinfo, ConnectalMemoryInitialization_handleMessage, (void *)&ConnectalMemoryInitialization_cbTable, transport, param, this, poller) {
    };
    virtual void disconnect(void) {
        printf("ConnectalMemoryInitializationWrapper.disconnect called %d\n", pint.client_fd_number);
    };
    virtual void done (  ) = 0;
    virtual void request ( const uint32_t addr, const uint32_t data ) = 0;
};
#endif // _CONNECTALMEMORYINITIALIZATION_H_
