`include "ConnectalProjectConfig.bsv"

import ProcTypes::*;

`ifdef ONECYCLE 
import OneCycle::*;
`endif

`ifdef TWOCYCLE
import TwoCycle::*;
`endif

`ifdef FOURCYCLE
import FourCycle::*;
`endif

`ifdef TWOSTAGE 
import TwoStage::*;
`endif

`ifdef TWOSTAGEEXE
import TwoStageExecuteFirst::*;
`endif

`ifdef TWOSTAGEREDIR
import TwoStageRedir::*;
`endif

`ifdef TWOSTAGEBTB 
import TwoStageBTB::*;
`endif

`ifdef SIXSTAGE 
import SixStage::*;
`endif

`ifdef SIXSTAGEBHT
import SixStageBHT::*;
`endif

`ifdef SIXSTAGERAS
import SixStageRAS::*;
`endif

`ifdef SIXSTAGEBONUS
import SixStageBonus::*;
`endif

import Ifc::*;
import ProcTypes::*;
import Types::*;
import Ehr::*;
import MemTypes::*;
import GetPut::*;

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

    Proc riscv_processor <- mkProc(reset_by my_rst.new_rst);

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
            riscv_processor.iMemInit.request.put(tagged InitDone);
            riscv_processor.dMemInit.request.put(tagged InitDone);
        endmethod
        method Action request(Bit#(32) addr, Bit#(32) data) if (!isResetting&&ready);
            $display("Request %x %x",addr, data);
            ind.wroteWord(0);
            riscv_processor.iMemInit.request.put(tagged InitLoad (MemInitLoad {addr: addr, data: data}));
            riscv_processor.dMemInit.request.put(tagged InitLoad (MemInitLoad {addr: addr, data: data}));
        endmethod 
    endinterface

endmodule
