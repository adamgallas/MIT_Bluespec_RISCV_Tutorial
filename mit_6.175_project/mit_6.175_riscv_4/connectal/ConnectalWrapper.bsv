`include "ConnectalProjectConfig.bsv"

import ProcTypes::*;
import SimMem::*;
import Fifo::*;
import MemUtil::*;
import Ifc::*;
import ProcTypes::*;
import Types::*;
import Ehr::*;
import MemTypes::*;
import Memory::*;
import GetPut::*;
import ClientServer::*;

`ifdef PROC
import Proc::*;
`endif

// Connectal imports
import HostInterface::*;
import Clocks::*;
import Connectable::*;

interface ConnectalWrapper;
   interface ConnectalProcRequest connectProc;
   interface ConnectalMemoryInitialization initProc;
endinterface

module mkConnectalWrapper#(HostInterface host, ConnectalProcIndication ind)(ConnectalWrapper);
    Reg#(Bool) ready <- mkReg(False);
    Reg#(Bool) isResetting <- mkReg(False);
    Reg#(Bit#(2)) resetCnt <- mkReg(0);
    Clock connectal_clk <- exposeCurrentClock;
    MakeResetIfc my_rst <- mkReset(1, True, connectal_clk); // inherits parent's reset (hidden) and introduce extra reset method (OR condition)

    rule clearResetting if (isResetting);
        resetCnt <= resetCnt + 1;
        if (resetCnt == 3) isResetting <= False;
    endrule

    Fifo#(2, DDR3_Req)  ddr3ReqFifo <- mkCFFifo();
    Fifo#(2, DDR3_Resp) ddr3RespFifo <- mkCFFifo();
    DDR3_Client ddrclient = toGPClient( ddr3ReqFifo, ddr3RespFifo );
    mkSimMem(ddrclient);

    Proc riscv_processor <- mkProc(ddr3ReqFifo,ddr3RespFifo, reset_by my_rst.new_rst);

    rule relayMessage;
        let mess <- riscv_processor.cpuToHost();
        ind.sendMessage(pack(mess));	
    endrule

    interface ConnectalProcRequest connectProc;
        method Action hostToCpu(Bit#(32) startpc) if (!isResetting&&ready);
            $display("Received software req to start pc\n");
            $fflush(stdout);
            riscv_processor.hostToCpu(unpack(startpc));
        endmethod
        method Action softReset();
            my_rst.assertReset; // assert my_rst.new_rst signal
            isResetting <= True;
            ready<=True;
        endmethod
    endinterface

    interface ConnectalMemoryInitialization initProc;
        method Action done() if (!isResetting&&ready);
            $display("Done memory initialization");
        endmethod
        method Action request(Bit#(32) addr, Bit#(32) data) if (!isResetting&&ready);
            $display("Request %x %x",addr, data);
            ind.wroteWord(0);
            let res = toDDR3Req(MemReq{op:St, addr:addr , data:data});
            $display("data",fshow(res.data));
            $display("addr",fshow(res.address));
            $display("byteen",fshow(res.byteen));
            $display("writeen",fshow(res.write));
            ddr3ReqFifo.enq(res);
        endmethod 
    endinterface

endmodule
