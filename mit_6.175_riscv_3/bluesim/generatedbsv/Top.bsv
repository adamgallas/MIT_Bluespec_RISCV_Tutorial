
import ConnectalConfig::*;
import Vector::*;
import BuildVector::*;
import Portal::*;
import CnocPortal::*;
import Connectable::*;
import HostInterface::*;
import ConnectalMemTypes::*;
`include "ConnectalProjectConfig.bsv"
import IfcNames::*;
import `PinTypeInclude::*;
import ConnectalProcIndication::*;
import ConnectalWrapper::*;
import ConnectalProcRequest::*;
import ConnectalMemoryInitialization::*;

typedef 2 NumberOfRequests;
typedef 1 NumberOfIndications;

`ifndef IMPORT_HOSTIF
(* synthesize *)
`endif
module mkCnocTop
`ifdef IMPORT_HOSTIF
       #(HostInterface host)
`else
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
       #(Clock derivedClockIn, Reset derivedResetIn)
`else
// otherwise no params
`endif
`endif
       (CnocTop#(NumberOfRequests,NumberOfIndications,PhysAddrWidth,DataBusWidth,`PinType,NumberOfMasters));
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();
`ifdef IMPORT_HOST_CLOCKS // enables synthesis boundary
   HostInterface host = (interface HostInterface;
                           interface Clock derivedClock = derivedClockIn;
                           interface Reset derivedReset = derivedResetIn;
                         endinterface);
`endif
   ConnectalMemoryInitializationInput lConnectalMemoryInitializationInput <- mkConnectalMemoryInitializationInput;
   ConnectalProcIndicationOutput lConnectalProcIndicationOutput <- mkConnectalProcIndicationOutput;
   ConnectalProcRequestInput lConnectalProcRequestInput <- mkConnectalProcRequestInput;

   let lConnectalWrapper <- mkConnectalWrapper(lConnectalProcIndicationOutput.ifc);


   mkConnection(lConnectalMemoryInitializationInput.pipes, lConnectalWrapper.initProc);
   mkConnection(lConnectalProcRequestInput.pipes, lConnectalWrapper.connectProc);

   let lConnectalProcIndicationOutputNoc <- mkPortalMsgIndication(extend(pack(IfcNames_ConnectalProcIndicationH2S)), lConnectalProcIndicationOutput.portalIfc.indications, lConnectalProcIndicationOutput.portalIfc.messageSize);
   let lConnectalProcRequestInputNoc <- mkPortalMsgRequest(extend(pack(IfcNames_ConnectalProcRequestS2H)), lConnectalProcRequestInput.portalIfc.requests);
   let lConnectalMemoryInitializationInputNoc <- mkPortalMsgRequest(extend(pack(IfcNames_ConnectalMemoryInitializationS2H)), lConnectalMemoryInitializationInput.portalIfc.requests);
   Vector#(NumWriteClients,MemWriteClient#(DataBusWidth)) nullWriters = replicate(null_mem_write_client());
   Vector#(NumReadClients,MemReadClient#(DataBusWidth)) nullReaders = replicate(null_mem_read_client());

   interface requests = vec(lConnectalProcRequestInputNoc, lConnectalMemoryInitializationInputNoc);
   interface indications = vec(lConnectalProcIndicationOutputNoc);
   interface readers = take(nullReaders);
   interface writers = take(nullWriters);
`ifdef TOP_SOURCES_PORTAL_CLOCK
   interface portalClockSource = None;
`endif


endmodule : mkCnocTop
export mkCnocTop;
export NumberOfRequests;
export NumberOfIndications;
export `PinTypeInclude::*;
