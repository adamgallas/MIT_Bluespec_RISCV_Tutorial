package XsimMsgRequest;

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
} MsgSink_Message deriving (Bits);

typedef struct {
    Bit#(32) portal;
    SpecialTypeForSendingFd data;
} MsgSinkFd_Message deriving (Bits);

// exposed wrapper portal interface
interface XsimMsgRequestInputPipes;
    interface PipeOut#(MsgSink_Message) msgSink_PipeOut;
    interface PipeOut#(MsgSinkFd_Message) msgSinkFd_PipeOut;

endinterface
typedef PipePortal#(2, 0, SlaveDataBusWidth) XsimMsgRequestPortalInput;
interface XsimMsgRequestInput;
    interface XsimMsgRequestPortalInput portalIfc;
    interface XsimMsgRequestInputPipes pipes;
endinterface
interface XsimMsgRequestWrapperPortal;
    interface XsimMsgRequestPortalInput portalIfc;
endinterface
// exposed wrapper MemPortal interface
interface XsimMsgRequestWrapper;
    interface StdPortal portalIfc;
endinterface

instance Connectable#(XsimMsgRequestInputPipes,XsimMsgRequest);
   module mkConnection#(XsimMsgRequestInputPipes pipes, XsimMsgRequest ifc)(Empty);

    rule handle_msgSink_request;
        let request <- toGet(pipes.msgSink_PipeOut).get();
        ifc.msgSink(request.portal, request.data);
    endrule

    rule handle_msgSinkFd_request;
        let request <- toGet(pipes.msgSinkFd_PipeOut).get();
        ifc.msgSinkFd(request.portal, request.data);
    endrule

   endmodule
endinstance

// exposed wrapper Portal implementation
(* synthesize *)
module mkXsimMsgRequestInput(XsimMsgRequestInput);
    Vector#(2, PipeIn#(Bit#(SlaveDataBusWidth))) requestPipeIn;

    AdapterFromBus#(SlaveDataBusWidth,MsgSink_Message) msgSink_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[0] = msgSink_requestAdapter.in;

    AdapterFromBus#(SlaveDataBusWidth,MsgSinkFd_Message) msgSinkFd_requestAdapter <- mkAdapterFromBus();
    requestPipeIn[1] = msgSinkFd_requestAdapter.in;

    interface PipePortal portalIfc;
        interface PortalSize messageSize;
        method Bit#(16) size(Bit#(16) methodNumber);
            case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(MsgSink_Message)));
            1: return fromInteger(valueOf(SizeOf#(MsgSinkFd_Message)));
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
    interface XsimMsgRequestInputPipes pipes;
        interface msgSink_PipeOut = msgSink_requestAdapter.out;
        interface msgSinkFd_PipeOut = msgSinkFd_requestAdapter.out;
    endinterface
endmodule

module mkXsimMsgRequestWrapperPortal#(XsimMsgRequest ifc)(XsimMsgRequestWrapperPortal);
    let dut <- mkXsimMsgRequestInput;
    mkConnection(dut.pipes, ifc);
    interface PipePortal portalIfc = dut.portalIfc;
endmodule

interface XsimMsgRequestWrapperMemPortalPipes;
    interface XsimMsgRequestInputPipes pipes;
    interface MemPortal#(12,32) portalIfc;
endinterface

(* synthesize *)
module mkXsimMsgRequestWrapperMemPortalPipes#(Bit#(SlaveDataBusWidth) id)(XsimMsgRequestWrapperMemPortalPipes);

  let dut <- mkXsimMsgRequestInput;
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxIn(ctrlPort.memSlave,dut.portalIfc.requests);
  interface XsimMsgRequestInputPipes pipes = dut.pipes;
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
endmodule

// exposed wrapper MemPortal implementation
module mkXsimMsgRequestWrapper#(idType id, XsimMsgRequest ifc)(XsimMsgRequestWrapper)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
  let dut <- mkXsimMsgRequestWrapperMemPortalPipes(zeroExtend(pack(id)));
  mkConnection(dut.pipes, ifc);
  interface MemPortal portalIfc = dut.portalIfc;
endmodule

// exposed proxy interface
typedef PipePortal#(0, 2, SlaveDataBusWidth) XsimMsgRequestPortalOutput;
interface XsimMsgRequestOutput;
    interface XsimMsgRequestPortalOutput portalIfc;
    interface XsimIF::XsimMsgRequest ifc;
endinterface
interface XsimMsgRequestProxy;
    interface StdPortal portalIfc;
    interface XsimIF::XsimMsgRequest ifc;
endinterface

interface XsimMsgRequestOutputPipeMethods;
    interface PipeIn#(MsgSink_Message) msgSink;
    interface PipeIn#(MsgSinkFd_Message) msgSinkFd;

endinterface

interface XsimMsgRequestOutputPipes;
    interface XsimMsgRequestOutputPipeMethods methods;
    interface XsimMsgRequestPortalOutput portalIfc;
endinterface

function Bit#(16) getXsimMsgRequestMessageSize(Bit#(16) methodNumber);
    case (methodNumber)
            0: return fromInteger(valueOf(SizeOf#(MsgSink_Message)));
            1: return fromInteger(valueOf(SizeOf#(MsgSinkFd_Message)));
    endcase
endfunction

(* synthesize *)
module mkXsimMsgRequestOutputPipes(XsimMsgRequestOutputPipes);
    Vector#(2, PipeOut#(Bit#(SlaveDataBusWidth))) indicationPipes;

    AdapterToBus#(SlaveDataBusWidth,MsgSink_Message) msgSink_responseAdapter <- mkAdapterToBus();
    indicationPipes[0] = msgSink_responseAdapter.out;

    AdapterToBus#(SlaveDataBusWidth,MsgSinkFd_Message) msgSinkFd_responseAdapter <- mkAdapterToBus();
    indicationPipes[1] = msgSinkFd_responseAdapter.out;

    PortalInterrupt#(SlaveDataBusWidth) intrInst <- mkPortalInterrupt(indicationPipes);
    interface XsimMsgRequestOutputPipeMethods methods;
    interface msgSink = msgSink_responseAdapter.in;
    interface msgSinkFd = msgSinkFd_responseAdapter.in;

    endinterface
    interface PipePortal portalIfc;
        interface PortalSize messageSize;
            method size = getXsimMsgRequestMessageSize;
        endinterface
        interface Vector requests = nil;
        interface Vector indications = indicationPipes;
        interface PortalInterrupt intr = intrInst;
    endinterface
endmodule

(* synthesize *)
module mkXsimMsgRequestOutput(XsimMsgRequestOutput);
    let indicationPipes <- mkXsimMsgRequestOutputPipes;
    interface XsimIF::XsimMsgRequest ifc;

    method Action msgSink(Bit#(32) portal, Bit#(32) data);
        indicationPipes.methods.msgSink.enq(MsgSink_Message {portal: portal, data: data});
        //$display("indicationMethod 'msgSink' invoked");
    endmethod
    method Action msgSinkFd(Bit#(32) portal, SpecialTypeForSendingFd data);
        indicationPipes.methods.msgSinkFd.enq(MsgSinkFd_Message {portal: portal, data: data});
        //$display("indicationMethod 'msgSinkFd' invoked");
    endmethod
    endinterface
    interface PipePortal portalIfc = indicationPipes.portalIfc;
endmodule
instance PortalMessageSize#(XsimMsgRequestOutput);
   function Bit#(16) portalMessageSize(XsimMsgRequestOutput p, Bit#(16) methodNumber);
      return getXsimMsgRequestMessageSize(methodNumber);
   endfunction
endinstance


interface XsimMsgRequestInverse;
    method ActionValue#(MsgSink_Message) msgSink;
    method ActionValue#(MsgSinkFd_Message) msgSinkFd;

endinterface

interface XsimMsgRequestInverter;
    interface XsimIF::XsimMsgRequest ifc;
    interface XsimMsgRequestInverse inverseIfc;
endinterface

instance Connectable#(XsimMsgRequestInverse, XsimMsgRequestOutputPipeMethods);
   module mkConnection#(XsimMsgRequestInverse in, XsimMsgRequestOutputPipeMethods out)(Empty);
    mkConnection(in.msgSink, out.msgSink);
    mkConnection(in.msgSinkFd, out.msgSinkFd);

   endmodule
endinstance

(* synthesize *)
module mkXsimMsgRequestInverter(XsimMsgRequestInverter);
    FIFOF#(MsgSink_Message) fifo_msgSink <- mkFIFOF();
    FIFOF#(MsgSinkFd_Message) fifo_msgSinkFd <- mkFIFOF();

    interface XsimIF::XsimMsgRequest ifc;

    method Action msgSink(Bit#(32) portal, Bit#(32) data);
        fifo_msgSink.enq(MsgSink_Message {portal: portal, data: data});
    endmethod
    method Action msgSinkFd(Bit#(32) portal, SpecialTypeForSendingFd data);
        fifo_msgSinkFd.enq(MsgSinkFd_Message {portal: portal, data: data});
    endmethod
    endinterface
    interface XsimMsgRequestInverse inverseIfc;

    method ActionValue#(MsgSink_Message) msgSink;
        fifo_msgSink.deq;
        return fifo_msgSink.first;
    endmethod
    method ActionValue#(MsgSinkFd_Message) msgSinkFd;
        fifo_msgSinkFd.deq;
        return fifo_msgSinkFd.first;
    endmethod
    endinterface
endmodule

(* synthesize *)
module mkXsimMsgRequestInverterV(XsimMsgRequestInverter);
    PutInverter#(MsgSink_Message) inv_msgSink <- mkPutInverter();
    PutInverter#(MsgSinkFd_Message) inv_msgSinkFd <- mkPutInverter();

    interface XsimIF::XsimMsgRequest ifc;

    method Action msgSink(Bit#(32) portal, Bit#(32) data);
        inv_msgSink.mod.put(MsgSink_Message {portal: portal, data: data});
    endmethod
    method Action msgSinkFd(Bit#(32) portal, SpecialTypeForSendingFd data);
        inv_msgSinkFd.mod.put(MsgSinkFd_Message {portal: portal, data: data});
    endmethod
    endinterface
    interface XsimMsgRequestInverse inverseIfc;

    method ActionValue#(MsgSink_Message) msgSink;
        let v <- inv_msgSink.inverse.get;
        return v;
    endmethod
    method ActionValue#(MsgSinkFd_Message) msgSinkFd;
        let v <- inv_msgSinkFd.inverse.get;
        return v;
    endmethod
    endinterface
endmodule

// synthesizeable proxy MemPortal
(* synthesize *)
module mkXsimMsgRequestProxySynth#(Bit#(SlaveDataBusWidth) id)(XsimMsgRequestProxy);
  let dut <- mkXsimMsgRequestOutput();
  PortalCtrlMemSlave#(SlaveControlAddrWidth,SlaveDataBusWidth) ctrlPort <- mkPortalCtrlMemSlave(id, dut.portalIfc.intr);
  let memslave  <- mkMemMethodMuxOut(ctrlPort.memSlave,dut.portalIfc.indications);
  interface MemPortal portalIfc = (interface MemPortal;
      interface PhysMemSlave slave = memslave;
      interface ReadOnly interrupt = ctrlPort.interrupt;
      interface WriteOnly num_portals = ctrlPort.num_portals;
    endinterface);
  interface XsimIF::XsimMsgRequest ifc = dut.ifc;
endmodule

// exposed proxy MemPortal
module mkXsimMsgRequestProxy#(idType id)(XsimMsgRequestProxy)
   provisos (Bits#(idType, a__),
	     Add#(b__, a__, SlaveDataBusWidth));
   let rv <- mkXsimMsgRequestProxySynth(extend(pack(id)));
   return rv;
endmodule
endpackage: XsimMsgRequest
