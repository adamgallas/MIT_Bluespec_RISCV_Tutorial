/*

Copyright (C) 2012 Muralidaran Vijayaraghavan <vmurali@csail.mit.edu>
Edited 2013 by Andy Wright <acwright@mit.edu>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


import Types::*;
import MemTypes::*;
import MemInit::*;
import Fifo::*;
import RegFile::*;
import Vector::*;

interface DelayedMemory;
    method Action req(MemReq r);
    method ActionValue#(MemResp) resp();
    interface MemInitIfc init;
endinterface

module mkDelayedMemory(DelayedMemory);
    Fifo#(2, MemResp)    outFifo <- mkCFFifo();
	//RegFile#(Bit#(16), Data) mem <- mkRegFileFullLoad("mem.vmh");
	//MemInitIfc           memInit <- mkDummyMemInit;

    RegFile#(Bit#(16), Data) mem <- mkRegFileFull();
    MemInitIfc memInit <- mkMemInitRegFile(mem);

    method Action req(MemReq r) if (memInit.done());

        Bit#(16) index = truncate(r.addr>>2);
        let data = mem.sub(index);
        if(r.op==St) begin
            mem.upd(index, r.data);
        end else begin
            outFifo.enq( data );
        end
    endmethod

    method ActionValue#(MemResp) resp() if (memInit.done());
        let data = outFifo.first();
        outFifo.deq();
        return data;
    endmethod

    interface MemInitIfc init = memInit;
endmodule

