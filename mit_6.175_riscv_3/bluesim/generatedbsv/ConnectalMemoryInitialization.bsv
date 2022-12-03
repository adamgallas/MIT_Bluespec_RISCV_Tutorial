package ConnectalMemoryInitialization;

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
    Bit#(32) padding;
} Done_Message deriving (Bits);

typedef struct {
    Bit#(32) addr;
    Bit#(32) data;
} Request_Message deriving (Bits);

// exposed wrapper portal interface
interface ConnectalMemoryInitializationInputPipes;
    interface PipeOut#(Done_Message) done_PipeOut;
    interface PipeOut#(Request_Message) request_PipeOut;

endinterface
typedef PipePortal#(2, 0, SlaveDataBusWidth) ConnectalMemoryInitializationPortalInput;
interface ConnectalMemoryInitializationInput;
    interface ConnectalMemoryInitializationPortalInput portalIfc;
    interface ConnectalMemoryInitializationInputPipes pipes;
endinterface
interface ConnectalMemoryInitializationWrapperPortal;
    interface ConnectalMemoryInitializationPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface ConnectalMemoryInitializationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(ConnectalMemoryInitializationInputPipes,ConnectalMemoryInitialization);
   module mkConnection#(ConnectalMemoryInitializationInputPipes pipes, ConnectalMemoryInitialization ifc)(Empty);

    rule handle_done_request;
        let request <- toGet(pipes.done_PipeOut).get();
        ifc.done();
    endrule

    rule handle_request_request;
        let request <- toGet(pipes.request_PipeOut).get();
        ifc.request(request.addr, request.data);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkConnectalMemoryInitializationInput(ConnectalMemoryInitializationInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,Done_Message) done_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = done_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,Request_Message) request_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = request_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Done_Message)));
            1: return fromInteger(valueOf(SizeOf#(Request_Message)));
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
    interface ConnectalMemoryInitializationInputPipes pipes;
        interface done_PipeOut = done_requestAdapter.out;
        interface request_PipeOut = request_requestAdapter.out;
    endinterface
endmodule

module mkConnectalMemoryInitializationWrapperPortal#(ConnectalMemoryInitialization ifc)(ConnectalMemoryInitializationWrapperPortal);
    let dut <- mkConnectalMemoryInitializationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface ConnectalMemoryInitializationWrapperMemPortalPipes;
    interface ConnectalMemoryInitializationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkConnectalMemoryInitializationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(ConnectalMemoryInitializationWrapperMemPortalPipes);

  let dut <- mkConnectalMemoryInitializationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface ConnectalMemoryInitializationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkConnectalMemoryInitializationWrapper#(idType id, ConnectalMemoryInitialization ifc)(ConnectalMemoryInitializationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkConnectalMemoryInitializationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 2, SlaveDataBusWidth) ConnectalMemoryInitializationPortalOutput;
interface ConnectalMemoryInitializationOutput;
    interface ConnectalMemoryInitializationPortalOutput portalIfc;
    interface Ifc::ConnectalMemoryInitialization ifc;
endinterface
interface ConnectalMemoryInitializationProxy;
    interface StdPortal portalIfc;
    interface Ifc::ConnectalMemoryInitialization ifc;
endinterface

interface ConnectalMemoryInitializationOutputPipeMethods;
    interface PipeIn#(Done_Message) done;
    interface PipeIn#(Request_Message) request;

endinterface

interface ConnectalMemoryInitializationOutputPipes;
    interface ConnectalMemoryInitializationOutputPipeMethods methods;
    interface ConnectalMemoryInitializationPortalOutput portalIfc;
endinterface

function Bit#(16) getConnectalMemoryInitializationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(Done_Message)));
            1: return fromInteger(valueOf(SizeOf#(Request_Message)));
    endcase
endfunction

(* synthesize *)
module mkConnectalMemoryInitializationOutputPipes(ConnectalMemoryInitializationOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,Done_Message) done_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = done_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,Request_Message) request_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = request_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface ConnectalMemoryInitializationOutputPipeMethods methods;
    interface done = done_responseAdapter.in;
    interface request = request_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getConnectalMemoryInitializationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkConnectalMemoryInitializationOutput(ConnectalMemoryInitializationOutput);
    let indicationPipes <- mkConnectalMemoryInitializationOutputPipes;
    interface Ifc::ConnectalMemoryInitialization ifc;

    method Action done();
        indicationPipes.methods.done.enq(Done_Message {padding: 0});
        //$display("indicationMethod 'done' invoked");
    endmethod
    method Action request(Bit#(32) addr, Bit#(32) data);
        indicationPipes.methods.request.enq(Request_Message {addr: addr, data: data});
        //$display("indicationMethod 'request' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(ConnectalMemoryInitializationOutput);
   function Bit#(16) portalMessageSize(ConnectalMemoryInitializationOutput p, Bit#(16) methodNumber);
      return getConnectalMemoryInitializationMessageSize(methodNumber);
   endfunction
endinstance


interface ConnectalMemoryInitializationInverse;
    method ActionValue#(Done_Message) done;
    method ActionValue#(Request_Message) request;

endinterface

interface ConnectalMemoryInitializationInverter;
    interface Ifc::ConnectalMemoryInitialization ifc;
    interface ConnectalMemoryInitializationInverse inverseIfc;
endinterface

instance Connectable#(ConnectalMemoryInitializationInverse, ConnectalMemoryInitializationOutputPipeMethods);
   module mkConnection#(ConnectalMemoryInitializationInverse in, ConnectalMemoryInitializationOutputPipeMethods out)(Empty);
    mkConnection(in.done, out.done);
    mkConnection(in.request, out.request);

   endmodule
endinstance

(* synthesize *)
module mkConnectalMemoryInitializationInverter(ConnectalMemoryInitializationInverter);
    FIFOF#(Done_Message) fifo_done <- mkFIFOF();
    FIFOF#(Request_Message) fifo_request <- mkFIFOF();

    interface Ifc::ConnectalMemoryInitialization ifc;

    method Action done();
        fifo_done.enq(Done_Message {padding: 0});
    endmethod
    method Action request(Bit#(32) addr, Bit#(32) data);
        fifo_request.enq(Request_Message {addr: addr, data: data});
    endmethod
    endinterface
    interface ConnectalMemoryInitializationInverse inverseIfc;

    method ActionValue#(Done_Message) done;
        fifo_done.deq;
        return fifo_done.first;
    endmethod
    method ActionValue#(Request_Message) request;
        fifo_request.deq;
        return fifo_request.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkConnectalMemoryInitializationInverterV(ConnectalMemoryInitializationInverter);
    PutInverter#(Done_Message) inv_done <- mkPutInverter();
    PutInverter#(Request_Message) inv_request <- mkPutInverter();

    interface Ifc::ConnectalMemoryInitialization ifc;

    method Action done();
        inv_done.mod.put(Done_Message {padding: 0});
    endmethod
    method Action request(Bit#(32) addr, Bit#(32) data);
        inv_request.mod.put(Request_Message {addr: addr, data: data});
    endmethod
    endinterface
    interface ConnectalMemoryInitializationInverse inverseIfc;

    method ActionValue#(Done_Message) done;
        let v <- inv_done.inverse.get;
        return v;
    endmethod
    method ActionValue#(Request_Message) request;
        let v <- inv_request.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkConnectalMemoryInitializationProxySynth#(Bit#(SlaveDataBusWidth) id)(ConnectalMemoryInitializationProxy);
  let dut <- mkConnectalMemoryInitializationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Ifc::ConnectalMemoryInitialization ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkConnectalMemoryInitializationProxy#(idType id)(ConnectalMemoryInitializationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkConnectalMemoryInitializationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: ConnectalMemoryInitialization
