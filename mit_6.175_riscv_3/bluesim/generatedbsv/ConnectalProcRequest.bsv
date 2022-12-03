package ConnectalProcRequest;

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
    Bit#(32) startpc;
} HostToCpu_Message deriving (Bits);

// exposed wrapper portal interface
interface ConnectalProcRequestInputPipes;
    interface PipeOut#(HostToCpu_Message) hostToCpu_PipeOut;

endinterface
typedef PipePortal#(1, 0, SlaveDataBusWidth) ConnectalProcRequestPortalInput;
interface ConnectalProcRequestInput;
    interface ConnectalProcRequestPortalInput portalIfc;
    interface ConnectalProcRequestInputPipes pipes;
endinterface
interface ConnectalProcRequestWrapperPortal;
    interface ConnectalProcRequestPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface ConnectalProcRequestWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(ConnectalProcRequestInputPipes,ConnectalProcRequest);
   module mkConnection#(ConnectalProcRequestInputPipes pipes, ConnectalProcRequest ifc)(Empty);

    rule handle_hostToCpu_request;
        let request <- toGet(pipes.hostToCpu_PipeOut).get();
        ifc.hostToCpu(request.startpc);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkConnectalProcRequestInput(ConnectalProcRequestInput);
    Vector#(1, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,HostToCpu_Message) hostToCpu_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = hostToCpu_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(HostToCpu_Message)));
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
    interface ConnectalProcRequestInputPipes pipes;
        interface hostToCpu_PipeOut = hostToCpu_requestAdapter.out;
    endinterface
endmodule

module mkConnectalProcRequestWrapperPortal#(ConnectalProcRequest ifc)(ConnectalProcRequestWrapperPortal);
    let dut <- mkConnectalProcRequestInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface ConnectalProcRequestWrapperMemPortalPipes;
    interface ConnectalProcRequestInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkConnectalProcRequestWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(ConnectalProcRequestWrapperMemPortalPipes);

  let dut <- mkConnectalProcRequestInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface ConnectalProcRequestInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkConnectalProcRequestWrapper#(idType id, ConnectalProcRequest ifc)(ConnectalProcRequestWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkConnectalProcRequestWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 1, SlaveDataBusWidth) ConnectalProcRequestPortalOutput;
interface ConnectalProcRequestOutput;
    interface ConnectalProcRequestPortalOutput portalIfc;
    interface Ifc::ConnectalProcRequest ifc;
endinterface
interface ConnectalProcRequestProxy;
    interface StdPortal portalIfc;
    interface Ifc::ConnectalProcRequest ifc;
endinterface

interface ConnectalProcRequestOutputPipeMethods;
    interface PipeIn#(HostToCpu_Message) hostToCpu;

endinterface

interface ConnectalProcRequestOutputPipes;
    interface ConnectalProcRequestOutputPipeMethods methods;
    interface ConnectalProcRequestPortalOutput portalIfc;
endinterface

function Bit#(16) getConnectalProcRequestMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(HostToCpu_Message)));
    endcase
endfunction

(* synthesize *)
module mkConnectalProcRequestOutputPipes(ConnectalProcRequestOutputPipes);
    Vector#(1, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,HostToCpu_Message) hostToCpu_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = hostToCpu_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface ConnectalProcRequestOutputPipeMethods methods;
    interface hostToCpu = hostToCpu_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getConnectalProcRequestMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkConnectalProcRequestOutput(ConnectalProcRequestOutput);
    let indicationPipes <- mkConnectalProcRequestOutputPipes;
    interface Ifc::ConnectalProcRequest ifc;

    method Action hostToCpu(Bit#(32) startpc);
        indicationPipes.methods.hostToCpu.enq(HostToCpu_Message {startpc: startpc});
        //$display("indicationMethod 'hostToCpu' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(ConnectalProcRequestOutput);
   function Bit#(16) portalMessageSize(ConnectalProcRequestOutput p, Bit#(16) methodNumber);
      return getConnectalProcRequestMessageSize(methodNumber);
   endfunction
endinstance


interface ConnectalProcRequestInverse;
    method ActionValue#(HostToCpu_Message) hostToCpu;

endinterface

interface ConnectalProcRequestInverter;
    interface Ifc::ConnectalProcRequest ifc;
    interface ConnectalProcRequestInverse inverseIfc;
endinterface

instance Connectable#(ConnectalProcRequestInverse, ConnectalProcRequestOutputPipeMethods);
   module mkConnection#(ConnectalProcRequestInverse in, ConnectalProcRequestOutputPipeMethods out)(Empty);
    mkConnection(in.hostToCpu, out.hostToCpu);

   endmodule
endinstance

(* synthesize *)
module mkConnectalProcRequestInverter(ConnectalProcRequestInverter);
    FIFOF#(HostToCpu_Message) fifo_hostToCpu <- mkFIFOF();

    interface Ifc::ConnectalProcRequest ifc;

    method Action hostToCpu(Bit#(32) startpc);
        fifo_hostToCpu.enq(HostToCpu_Message {startpc: startpc});
    endmethod
    endinterface
    interface ConnectalProcRequestInverse inverseIfc;

    method ActionValue#(HostToCpu_Message) hostToCpu;
        fifo_hostToCpu.deq;
        return fifo_hostToCpu.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkConnectalProcRequestInverterV(ConnectalProcRequestInverter);
    PutInverter#(HostToCpu_Message) inv_hostToCpu <- mkPutInverter();

    interface Ifc::ConnectalProcRequest ifc;

    method Action hostToCpu(Bit#(32) startpc);
        inv_hostToCpu.mod.put(HostToCpu_Message {startpc: startpc});
    endmethod
    endinterface
    interface ConnectalProcRequestInverse inverseIfc;

    method ActionValue#(HostToCpu_Message) hostToCpu;
        let v <- inv_hostToCpu.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkConnectalProcRequestProxySynth#(Bit#(SlaveDataBusWidth) id)(ConnectalProcRequestProxy);
  let dut <- mkConnectalProcRequestOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface Ifc::ConnectalProcRequest ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkConnectalProcRequestProxy#(idType id)(ConnectalProcRequestProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkConnectalProcRequestProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: ConnectalProcRequest
