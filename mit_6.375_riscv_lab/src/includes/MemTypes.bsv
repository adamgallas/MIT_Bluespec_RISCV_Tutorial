
import GetPut::*;
import Memory::*;
import Types::*;
import Vector::*;

typedef Data MemResp;

typedef enum{Ld, St} MemOp deriving(Eq, Bits, FShow);
typedef struct{
    MemOp op;
    Addr  addr;
    Data  data;
} MemReq deriving(Eq, Bits, FShow);

typedef 16 NumTokens;
typedef Bit#(TLog#(NumTokens)) Token;

typedef 16 LoadBufferSz;
typedef Bit#(TLog#(LoadBufferSz)) LoadBufferIndex;

typedef struct {
    Addr addr;
    Data data;
} MemInitLoad deriving(Eq, Bits, FShow);

typedef union tagged {
    MemInitLoad InitLoad;
    void InitDone;
} MemInit deriving(Eq, Bits, FShow);

interface MemInitIfc;
    interface Put#(MemInit) request;
    method Bool done();
endinterface

typedef 24 DDR3AddrSize;
typedef Bit#(DDR3AddrSize) DDR3Addr;
typedef 512 DDR3DataSize;
typedef Bit#(DDR3DataSize) DDR3Data;
typedef TDiv#(DDR3DataSize, 8) DDR3DataBytes;
typedef Bit#(DDR3DataBytes) DDR3ByteEn;
typedef TDiv#(DDR3DataSize, WordSz) DDR3DataWords;


// typedef struct {
//     Bool        write;
//     Bit#(64)    byteen;
//     Bit#(24)    address;
//     Bit#(512)   data;
// } DDR3_Req deriving (Bits, Eq);
typedef MemoryRequest#(DDR3AddrSize, DDR3DataSize) DDR3_Req;

// typedef struct {
//     Bit#(512)   data;
// } DDR3_Resp deriving (Bits, Eq);
typedef MemoryResponse#(DDR3DataSize) DDR3_Resp;

// interface DDR3_Client;
//     interface Get#( DDR3_Req )  request;
//     interface Put#( DDR3_Resp ) response;
// endinterface;
typedef MemoryClient#(DDR3AddrSize, DDR3DataSize) DDR3_Client;



typedef struct {
    DDR3Addr addr;
    DDR3Data data;
} WideMemInitLoad deriving(Eq, Bits, FShow);

typedef union tagged {
    WideMemInitLoad InitLoad;
    void InitDone;
} WideMemInit deriving(Eq, Bits, FShow);

interface WideMemInitIfc;
    interface Put#(WideMemInit) request;
    method Bool done();
endinterface

typedef 16 CacheLineWords; // to match DDR3 width
typedef TMul#(CacheLineWords, 4) CacheLineBytes;
typedef Vector#(CacheLineWords, Word) CacheLine;
typedef Bit#( TLog#(CacheLineWords) ) CacheWordSelect;
typedef CacheLine WideMemResp;

// Wide memory interface
// This is defined here since it depends on the CacheLine type
typedef struct{
    Bit#(CacheLineWords) write_en;  // Word write enable
    Word                 addr;
    CacheLine            data;      // Vector#(CacheLineWords, Word)
} WideMemReq deriving(Eq,Bits);

interface WideMem;
    method Action req(WideMemReq r);
    method ActionValue#(CacheLine) resp;
endinterface