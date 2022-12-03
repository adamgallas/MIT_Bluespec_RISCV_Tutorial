package XsimMsgIndication;

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
import XsimIF::*;
import GetPut::*;
import Vector::*;




typedef struct {
    Bit#(32) portal;
    Bit#(32) data;
} MsgSource_Message deriving (Bits);

// exposed wrapper portal interface
interface XsimMsgIndicationInputPipes;
    interface PipeOut#(MsgSource_Message) msgSource_PipeOut;

endinterface
typedef PipePortal#(1, 0, SlaveDataBusWidth) XsimMsgIndicationPortalInput;
interface XsimMsgIndicationInput;
    interface XsimMsgIndicationPortalInput portalIfc;
    interface XsimMsgIndicationInputPipes pipes;
endinterface
interface XsimMsgIndicationWrapperPortal;
    interface XsimMsgIndicationPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface XsimMsgIndicationWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(XsimMsgIndicationInputPipes,XsimMsgIndication);
   module mkConnection#(XsimMsgIndicationInputPipes pipes, XsimMsgIndication ifc)(Empty);

    rule handle_msgSource_request;
        let request <- toGet(pipes.msgSource_PipeOut).get();
        ifc.msgSource(request.portal, request.data);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkXsimMsgIndicationInput(XsimMsgIndicationInput);
    Vector#(1, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,MsgSource_Message) msgSource_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = msgSource_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(MsgSource_Message)));
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
    interface XsimMsgIndicationInputPipes pipes;
        interface msgSource_PipeOut = msgSource_requestAdapter.out;
    endinterface
endmodule

module mkXsimMsgIndicationWrapperPortal#(XsimMsgIndication ifc)(XsimMsgIndicationWrapperPortal);
    let dut <- mkXsimMsgIndicationInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface XsimMsgIndicationWrapperMemPortalPipes;
    interface XsimMsgIndicationInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkXsimMsgIndicationWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(XsimMsgIndicationWrapperMemPortalPipes);

  let dut <- mkXsimMsgIndicationInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface XsimMsgIndicationInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkXsimMsgIndicationWrapper#(idType id, XsimMsgIndication ifc)(XsimMsgIndicationWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkXsimMsgIndicationWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 1, SlaveDataBusWidth) XsimMsgIndicationPortalOutput;
interface XsimMsgIndicationOutput;
    interface XsimMsgIndicationPortalOutput portalIfc;
    interface XsimIF::XsimMsgIndication ifc;
endinterface
interface XsimMsgIndicationProxy;
    interface StdPortal portalIfc;
    interface XsimIF::XsimMsgIndication ifc;
endinterface

interface XsimMsgIndicationOutputPipeMethods;
    interface PipeIn#(MsgSource_Message) msgSource;

endinterface

interface XsimMsgIndicationOutputPipes;
    interface XsimMsgIndicationOutputPipeMethods methods;
    interface XsimMsgIndicationPortalOutput portalIfc;
endinterface

function Bit#(16) getXsimMsgIndicationMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(MsgSource_Message)));
    endcase
endfunction

(* synthesize *)
module mkXsimMsgIndicationOutputPipes(XsimMsgIndicationOutputPipes);
    Vector#(1, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,MsgSource_Message) msgSource_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = msgSource_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface XsimMsgIndicationOutputPipeMethods methods;
    interface msgSource = msgSource_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getXsimMsgIndicationMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkXsimMsgIndicationOutput(XsimMsgIndicationOutput);
    let indicationPipes <- mkXsimMsgIndicationOutputPipes;
    interface XsimIF::XsimMsgIndication ifc;

    method Action msgSource(Bit#(32) portal, Bit#(32) data);
        indicationPipes.methods.msgSource.enq(MsgSource_Message {portal: portal, data: data});
        //$display("indicationMethod 'msgSource' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(XsimMsgIndicationOutput);
   function Bit#(16) portalMessageSize(XsimMsgIndicationOutput p, Bit#(16) methodNumber);
      return getXsimMsgIndicationMessageSize(methodNumber);
   endfunction
endinstance


interface XsimMsgIndicationInverse;
    method ActionValue#(MsgSource_Message) msgSource;

endinterface

interface XsimMsgIndicationInverter;
    interface XsimIF::XsimMsgIndication ifc;
    interface XsimMsgIndicationInverse inverseIfc;
endinterface

instance Connectable#(XsimMsgIndicationInverse, XsimMsgIndicationOutputPipeMethods);
   module mkConnection#(XsimMsgIndicationInverse in, XsimMsgIndicationOutputPipeMethods out)(Empty);
    mkConnection(in.msgSource, out.msgSource);

   endmodule
endinstance

(* synthesize *)
module mkXsimMsgIndicationInverter(XsimMsgIndicationInverter);
    FIFOF#(MsgSource_Message) fifo_msgSource <- mkFIFOF();

    interface XsimIF::XsimMsgIndication ifc;

    method Action msgSource(Bit#(32) portal, Bit#(32) data);
        fifo_msgSource.enq(MsgSource_Message {portal: portal, data: data});
    endmethod
    endinterface
    interface XsimMsgIndicationInverse inverseIfc;

    method ActionValue#(MsgSource_Message) msgSource;
        fifo_msgSource.deq;
        return fifo_msgSource.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkXsimMsgIndicationInverterV(XsimMsgIndicationInverter);
    PutInverter#(MsgSource_Message) inv_msgSource <- mkPutInverter();

    interface XsimIF::XsimMsgIndication ifc;

    method Action msgSource(Bit#(32) portal, Bit#(32) data);
        inv_msgSource.mod.put(MsgSource_Message {portal: portal, data: data});
    endmethod
    endinterface
    interface XsimMsgIndicationInverse inverseIfc;

    method ActionValue#(MsgSource_Message) msgSource;
        let v <- inv_msgSource.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkXsimMsgIndicationProxySynth#(Bit#(SlaveDataBusWidth) id)(XsimMsgIndicationProxy);
  let dut <- mkXsimMsgIndicationOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface XsimIF::XsimMsgIndication ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkXsimMsgIndicationProxy#(idType id)(XsimMsgIndicationProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkXsimMsgIndicationProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: XsimMsgIndication
