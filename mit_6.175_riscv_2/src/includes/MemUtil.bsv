import Types::*;
import ProcTypes::*;
import MemTypes::*;
import CacheTypes::*;
// import Fifo::*;
import FIFO::*;
import FIFOF::*;
import Vector::*;
import Memory::*;
import Fifo::*;

// function WideMemReq lineReqToWideMemReq(LineReq req);
//    return WideMemReq{write_en: (req.op==Ld ? 0: maxBound),
//                      addr: {req.lineAddr,6'b0},
//                      data: req.data};
// endfunction


function Bit#(TMul#(n,4)) wordEnToByteEn( Bit#(n) word_en );
    Bit#(TMul#(n,4)) byte_en;
    for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
        for( Integer j = 0 ; j < 4 ; j = j+1 ) begin
            byte_en[ 4*i + j ] = word_en[i];
        end
    end
    return byte_en;
endfunction

function Bit#(wordSize) selectWord( Bit#(TMul#(numWords,wordSize)) line, Bit#(TLog#(numWords)) sel ) provisos ( Add#( a__, TLog#(numWords), TLog#(TMul#(numWords,wordSize))) );
    Bit#(TLog#(TMul#(numWords,wordSize))) index_offset = zeroExtend(sel) * fromInteger(valueOf(wordSize));
    return line[ index_offset + fromInteger(valueOf(wordSize)-1) : index_offset ];
endfunction

// 0100 -> 01000100
function Bit#(TMul#(wordSize,numWords)) replicateWord( Bit#(wordSize) word ) provisos ( Add#( a__, wordSize, TMul#(wordSize,numWords)) );
    Bit#(TMul#(wordSize,numWords)) x = 0;
    for( Integer i = 0 ; i < valueOf(numWords) ; i = i+1 ) begin
        x[ valueOf(wordSize)*(i+1) - 1 : valueOf(wordSize)*(i) ] = word;
    end
    return x;
endfunction

function WideMemReq toWideMemReq( MemReq req );
    Bit#(CacheLineWords) write_en = 0;
    CacheWordSelect wordsel = truncate( req.addr >> 2 );
    if( req.op == St ) begin
        write_en = 1 << wordsel;
    end
    Word addr = req.addr;
    for( Integer i = 0 ; i < valueOf(TLog#(CacheLineBytes)) ; i = i+1 ) begin
        addr[i] = 0;
    end
    CacheLine data = replicate( req.data );

    return WideMemReq {
                write_en: write_en,
                addr: addr,
                data: data
            };
endfunction

function DDR3_Req toDDR3Req( MemReq req );
    Bool write = (req.op == St);
    CacheWordSelect wordSelect = truncate(req.addr >> 2);
    DDR3ByteEn byteen = wordEnToByteEn( 1 << wordSelect );
	if( req.op == Ld ) begin
		byteen = 0;
	end
    DDR3Addr addr = truncate( req.addr >> valueOf(TLog#(DDR3DataBytes)) );
    DDR3Data data = replicateWord(req.data);
    return DDR3_Req {
                write:      (req.op == St),
                byteen:     byteen,
                address:    addr,
                data:       data
            };
endfunction

module mkWideMemFromDDR3(   Fifo#(2, DDR3_Req) ddr3ReqFifo,
                            Fifo#(2, DDR3_Resp) ddr3RespFifo,
                            WideMem ifc );
    method Action req( WideMemReq x );
        Bool write_en = (x.write_en != 0);
        Bit#(DDR3DataBytes) byte_en = wordEnToByteEn(x.write_en);
		if( write_en == False ) begin
			byte_en = 0;
		end
        // x.addr is byte aligned and ddr3 addresses are aligned to DDR3Data sized blocks
        DDR3Addr addr = truncate(x.addr >> valueOf(TLog#(DDR3DataBytes)));

        DDR3_Req ddr3_req = DDR3_Req {
                                write:      write_en,
                                byteen:     byte_en,
                                address:    addr,
                                data:       pack(x.data)
                            };
        ddr3ReqFifo.enq( ddr3_req );
        $display("mkWideMemFromDDR3::req : wideMemReq.addr = 0x%0x, ddr3Req.address = 0x%0x, ddr3Req.byteen = 0x%0x", x.addr, ddr3_req.address, ddr3_req.byteen);
    endmethod
    method ActionValue#(WideMemResp) resp;
        let x = ddr3RespFifo.first;
        ddr3RespFifo.deq;
        $display("mkWideMemFromDDR3::resp : data = 0x%0x", x.data);
        return unpack(x.data);
    endmethod
endmodule

module mkSplitWideMem(  Bool initDone, WideMem mem,
                        Vector#(n, WideMem) ifc );

     Vector#(n, Fifo#(2, WideMemReq)) reqFifos <- replicateM(mkCFFifo);
     Fifo#(TAdd#(n,1), Bit#(TLog#(n))) reqSource <- mkCFFifo;
     Vector#(n, Fifo#(2, WideMemResp)) respFifos <- replicateM(mkCFFifo);

    rule doDDR3Req(initDone);
        Maybe#(Bit#(TLog#(n))) req_index = tagged Invalid;
        for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
            if( !isValid(req_index) && reqFifos[i].notEmpty ) begin
                req_index = tagged Valid (fromInteger(i));
            end
        end

        if( isValid(req_index) ) begin
            let req = reqFifos[ fromMaybe(?,req_index) ].first;
            reqFifos[ fromMaybe(?,req_index) ].deq();
            $display("split ddr3 request,%d,addr=0x%0x",req_index,req.addr);
            mem.req(req);
            if( req.write_en == 0 ) begin
                // req is a load, so keep track of the source
                reqSource.enq( fromMaybe(?,req_index) );
            end
        end
    endrule

    rule doDDR3Resp(initDone);
        let resp <- mem.resp;

        let source = reqSource.first;
        reqSource.deq;
        $display("split ddr3 response,%d",source);

        respFifos[source].enq( resp );
    endrule

    Vector#(n, WideMem) wideMemIfcs = newVector;
    for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
        wideMemIfcs[i] =
            (interface WideMem;
                method Action req( WideMemReq x );
                    $display("spilit mem %d request, address = 0x%0x, byteen = 0x%0x, data=0x%0x",i,x.addr,x.write_en,x.data);
                    reqFifos[i].enq(x);
                endmethod
                method ActionValue#(WideMemResp) resp;
                    let x = respFifos[i].first;
                    $display("spilit mem %d resp, data=0x%0x",i,x);
                    respFifos[i].deq;
                    return x;
                endmethod
            endinterface);
    end
    return wideMemIfcs;
endmodule
