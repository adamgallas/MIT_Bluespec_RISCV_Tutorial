package ConnectalProcIndication;

import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Connectable::*;
import Clocks::*;
import FloatingPoint::*;
import Adapter::*;
import Leds::*;
import Vector::*;
import SpecialFIFOs::*;
import ConnectalConfig::*;
import ConnectalMemory::*;
import Portal::*;
import CtrlMux::*;
import ConnectalMemTypes::*;
import Pipe::*;
import HostInterface::*;
import LinkerLib::*;
import Ifc::*;
import GetPut::*;
import Vector::*;




typedef struct {
    Bit#(18) mess;
} SendMessage_Message deriving (Bits);

typedef struct {
    Bit#(32) data;
} WroteWord_Message deriving (Bits);

// exposed wrapper portal interface
interface ConnectalProcIndicationInputPipes;
    interface PipeOut#(SendMessage_Message) sendMessage_PipeOut;
    interface PipeOut#(WroteWord_Message) wroteWord_PipeOut;

endinterface
typedef PipePortal#(2, 0, SlaveDataBusWidth) ConnectalProcIndicationPortalInput;
interface ConnectalProcIndicationInput;
    interface ConnectalProcIndicationPortalInput portalIfc;
    interface ConnectalProcIndicationInputPipes pipes;
endinterface
interface ConnectalProcIndicationWrapperPortal;
    interface ConnectalProcIndicationPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface ConnectalProcIndicationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(ConnectalProcIndicationInputPipes,ConnectalProcIndication);
   module mkConnection#(ConnectalProcIndicationInputPipes pipes, ConnectalProcIndication ifc)(Empty);

    rule handle_sendMessage_request;
        let request <- toGet(pipes.sendMessage_PipeOut).get();
        ifc.sendMessage(request.mess);
    endrule

    rule handle_wroteWord_request;
        let request <- toGet(pipes.wroteWord_PipeOut).get();
        ifc.wroteWord(request.data);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkConnectalProcIndicationInput(ConnectalProcIndicationInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,SendMessage_Message) sendMessage_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = sendMessage_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,WroteWord_Message) wroteWord_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = wroteWord_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(SendMessage_Message)));
            1: return fromInteger(valueOf(SizeOf#(WroteWord_Message)));
            endcase
        endmethod
        endinterface
        interface Vector requests = requestPipeIn;
        interface Vector indications = nil;
        interface PortalInterrupt intr;
           method Bool status();
              return False;
           endmethod
           method Bit#(dataWidth) channel();
              return -1;
           endmethod
        endinterface
    endinterface
    interface ConnectalProcIndicationInputPipes pipes;
        interface sendMessage_PipeOut = sendMessage_requestAdapter.out;
        interface wroteWord_PipeOut = wroteWord_requestAdapter.out;
    endinterface
endmodule

module mkConnectalProcIndicationWrapperPortal#(ConnectalProcIndication ifc)(ConnectalProcIndicationWrapperPortal);
    let dut <- mkConnectalProcIndicationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface ConnectalProcIndicationWrapperMemPortalPipes;
    interface ConnectalProcIndicationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkConnectalProcIndicationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(ConnectalProcIndicationWrapperMemPortalPipes);

  let dut <- mkConnectalProcIndicationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface ConnectalProcIndicationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkConnectalProcIndicationWrapper#(idType id, ConnectalProcIndication ifc)(ConnectalProcIndicationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkConnectalProcIndicationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 2, SlaveDataBusWidth) ConnectalProcIndicationPortalOutput;
interface ConnectalProcIndicationOutput;
    interface ConnectalProcIndicationPortalOutput portalIfc;
    interface Ifc::ConnectalProcIndication ifc;
endinterface
interface ConnectalProcIndicationProxy;
    interface StdPortal portalIfc;
    interface Ifc::ConnectalProcIndication ifc;
endinterface

interface ConnectalProcIndicationOutputPipeMethods;
    interface PipeIn#(SendMessage_Message) sendMessage;
    interface PipeIn#(WroteWord_Message) wroteWord;

endinterface

interface ConnectalProcIndicationOutputPipes;
    interface ConnectalProcIndicationOutputPipeMethods methods;
    interface ConnectalProcIndicationPortalOutput portalIfc;
endinterface

function Bit#(16) getConnectalProcIndicationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(SendMessage_Message)));
            1: return fromInteger(valueOf(SizeOf#(WroteWord_Message)));
    endcase
endfunction

(* synthesize *)
module mkConnectalProcIndicationOutputPipes(ConnectalProcIndicationOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,SendMessage_Message) sendMessage_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = sendMessage_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,WroteWord_Message) wroteWord_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = wroteWord_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface ConnectalProcIndicationOutputPipeMethods methods;
    interface sendMessage = sendMessage_responseAdapter.in;
    interface wroteWord = wroteWord_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getConnectalProcIndicationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkConnectalProcIndicationOutput(ConnectalProcIndicationOutput);
    let indicationPipes <- mkConnectalProcIndicationOutputPipes;
    interface Ifc::ConnectalProcIndication ifc;

    method Action sendMessage(Bit#(18) mess);
        indicationPipes.methods.sendMessage.enq(SendMessage_Message {mess: mess});
        //$display("indicationMethod 'sendMessage' invoked");
    endmethod
    method Action wroteWord(Bit#(32) data);
        indicationPipes.methods.wroteWord.enq(WroteWord_Message {data: data});
        //$display("indicationMethod 'wroteWord' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(ConnectalProcIndicationOutput);
   function Bit#(16) portalMessageSize(ConnectalProcIndicationOutput p, Bit#(16) methodNumber);
      return getConnectalProcIndicationMessageSize(methodNumber);
   endfunction
endinstance


interface ConnectalProcIndicationInverse;
    method ActionValue#(SendMessage_Message) sendMessage;
    method ActionValue#(WroteWord_Message) wroteWord;

endinterface

interface ConnectalProcIndicationInverter;
    interface Ifc::ConnectalProcIndication ifc;
    interface ConnectalProcIndicationInverse inverseIfc;
endinterface

instance Connectable#(ConnectalProcIndicationInverse, ConnectalProcIndicationOutputPipeMethods);
   module mkConnection#(ConnectalProcIndicationInverse in, ConnectalProcIndicationOutputPipeMethods out)(Empty);
    mkConnection(in.sendMessage, out.sendMessage);
    mkConnection(in.wroteWord, out.wroteWord);

   endmodule
endinstance

(* synthesize *)
module mkConnectalProcIndicationInverter(ConnectalProcIndicationInverter);
    FIFOF#(SendMessage_Message) fifo_sendMessage <- mkFIFOF();
    FIFOF#(WroteWord_Message) fifo_wroteWord <- mkFIFOF();

    interface Ifc::ConnectalProcIndication ifc;

    method Action sendMessage(Bit#(18) mess);
        fifo_sendMessage.enq(SendMessage_Message {mess: mess});
    endmethod
    method Action wroteWord(Bit#(32) data);
        fifo_wroteWord.enq(WroteWord_Message {data: data});
    endmethod
    endinterface
    interface ConnectalProcIndicationInverse inverseIfc;

    method ActionValue#(SendMessage_Message) sendMessage;
        fifo_sendMessage.deq;
        return fifo_sendMessage.first;
    endmethod
    method ActionValue#(WroteWord_Message) wroteWord;
        fifo_wroteWord.deq;
        return fifo_wroteWord.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkConnectalProcIndicationInverterV(ConnectalProcIndicationInverter);
    PutInverter#(SendMessage_Message) inv_sendMessage <- mkPutInverter();
    PutInverter#(WroteWord_Message) inv_wroteWord <- mkPutInverter();

    interface Ifc::ConnectalProcIndication ifc;

    method Action sendMessage(Bit#(18) mess);
        inv_sendMessage.mod.put(SendMessage_Message {mess: mess});
    endmethod
    method Action wroteWord(Bit#(32) data);
        inv_wroteWord.mod.put(WroteWord_Message {data: data});
    endmethod
    endinterface
    interface ConnectalProcIndicationInverse inverseIfc;

    method ActionValue#(SendMessage_Message) sendMessage;
        let v <- inv_sendMessage.inverse.get;
        return v;
    endmethod
    method ActionValue#(WroteWord_Message) wroteWord;
        let v <- inv_wroteWord.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkConnectalProcIndicationProxySynth#(Bit#(SlaveDataBusWidth) id)(ConnectalProcIndicationProxy);
  let dut <- mkConnectalProcIndicationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Ifc::ConnectalProcIndication ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkConnectalProcIndicationProxy#(idType id)(ConnectalProcIndicationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkConnectalProcIndicationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: ConnectalProcIndication
