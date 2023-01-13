import ProcTypes::*;

`ifdef ONECYCLEEXEP
import OneCycleExep::*;
`endif

import Ifc::*;
import ProcTypes::*;
import Types::*;
import Ehr::*;
import MemTypes::*;
import GetPut::*;

interface ConnectalWrapper;
  interface ConnectalProcRequest connectProc;
  interface ConnectalMemoryInitialization initProc;
endinterface

module [Module] mkConnectalWrapper#(ConnectalProcIndication ind)(ConnectalWrapper);
   Proc m <- mkProc();

   rule relayMessage;
	let mess <- m.cpuToHost();
        ind.sendMessage(pack(mess));	
   endrule
   interface ConnectalProcRequest connectProc;
      method Action hostToCpu(Bit#(32) startpc);
        $display("Received software req to start pc\n");
        $fflush(stdout);
	m.hostToCpu(unpack(startpc));
      endmethod
   endinterface
  interface ConnectalMemoryInitialization initProc;
	method Action done();
		$display("Done memory initialization");
		m.iMemInit.request.put(tagged InitDone);
		m.dMemInit.request.put(tagged InitDone);
	endmethod

	method Action request(Bit#(32) addr, Bit#(32) data);
		$display("Request %x %x",addr, data);
		ind.wroteWord(0);
		m.iMemInit.request.put(tagged InitLoad (MemInitLoad {addr: addr, data: data}));
		m.dMemInit.request.put(tagged InitLoad (MemInitLoad {addr: addr, data: data}));
	endmethod 
  endinterface
endmodule
