interface ConnectalProcIndication;
	method Action sendMessage(Bit#(18) mess);
	method Action wroteWord(Bit#(32) data);
endinterface
interface ConnectalProcRequest;
   method Action hostToCpu(Bit#(32) startpc);
endinterface

interface ConnectalMemoryInitialization;
  method Action done();
  method Action request(Bit#(32) addr, Bit#(32) data);
endinterface


