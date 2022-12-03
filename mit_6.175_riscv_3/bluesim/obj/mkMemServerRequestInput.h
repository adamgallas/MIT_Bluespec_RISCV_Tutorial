/*
 * Generated by Bluespec Compiler, version 2022.01 (build 066c7a8)
 * 
 * On Fri Dec  2 22:41:44 PST 2022
 * 
 */

/* Generation options: */
#ifndef __mkMemServerRequestInput_h__
#define __mkMemServerRequestInput_h__

#include "bluesim_types.h"
#include "bs_module.h"
#include "bluesim_primitives.h"
#include "bs_vcd.h"


/* Class declaration for the mkMemServerRequestInput module */
class MOD_mkMemServerRequestInput : public Module {
 
 /* Clock handles */
 private:
  tClock __clk_handle_0;
 
 /* Clock gate handles */
 public:
  tUInt8 *clk_gate[0];
 
 /* Instantiation parameters */
 public:
 
 /* Module state */
 public:
  MOD_Reg<tUInt8> INST_addrTrans_requestAdapter_count;
  MOD_Reg<tUInt64> INST_addrTrans_requestAdapter_fbnbuff;
  MOD_Fifo<tUInt64> INST_addrTrans_requestAdapter_fifo;
  MOD_Reg<tUInt32> INST_memoryTraffic_requestAdapter_fbnbuff;
  MOD_Fifo<tUInt8> INST_memoryTraffic_requestAdapter_fifo;
  MOD_Reg<tUInt32> INST_setTileState_requestAdapter_fbnbuff;
  MOD_Fifo<tUInt8> INST_setTileState_requestAdapter_fifo;
  MOD_Reg<tUInt32> INST_stateDbg_requestAdapter_fbnbuff;
  MOD_Fifo<tUInt8> INST_stateDbg_requestAdapter_fifo;
 
 /* Constructor */
 public:
  MOD_mkMemServerRequestInput(tSimStateHdl simHdl, char const *name, Module *parent);
 
 /* Symbol init methods */
 private:
  void init_symbols_0();
 
 /* Reset signal definitions */
 private:
  tUInt8 PORT_RST_N;
 
 /* Port definitions */
 public:
 
 /* Publicly accessible definitions */
 public:
  tUInt8 DEF_memoryTraffic_requestAdapter_fifo_i_notEmpty____d31;
  tUInt8 DEF_stateDbg_requestAdapter_fifo_i_notEmpty____d30;
  tUInt8 DEF_setTileState_requestAdapter_fifo_i_notEmpty____d29;
  tUInt8 DEF_addrTrans_requestAdapter_fifo_i_notEmpty____d28;
  tUInt8 DEF_memoryTraffic_requestAdapter_fifo_notFull____d26;
  tUInt8 DEF_stateDbg_requestAdapter_fifo_notFull____d23;
  tUInt8 DEF_setTileState_requestAdapter_fifo_notFull____d20;
  tUInt8 DEF_addrTrans_requestAdapter_fifo_notFull____d15;
  tUInt8 DEF_addrTrans_requestAdapter_count__h992;
  tUInt8 DEF_NOT_addrTrans_requestAdapter_count_1___d12;
 
 /* Local definitions */
 private:
 
 /* Rules */
 public:
 
 /* Methods */
 public:
  tUInt32 METH_portalIfc_messageSize_size(tUInt32 ARG_portalIfc_messageSize_size_methodNumber);
  tUInt8 METH_RDY_portalIfc_messageSize_size();
  tUInt8 METH_portalIfc_intr_status();
  tUInt8 METH_RDY_portalIfc_intr_status();
  tUInt32 METH_portalIfc_intr_channel();
  tUInt8 METH_RDY_portalIfc_intr_channel();
  void METH_portalIfc_requests_0_enq(tUInt32 ARG_portalIfc_requests_0_enq_v);
  tUInt8 METH_RDY_portalIfc_requests_0_enq();
  tUInt8 METH_portalIfc_requests_0_notFull();
  tUInt8 METH_RDY_portalIfc_requests_0_notFull();
  void METH_portalIfc_requests_1_enq(tUInt32 ARG_portalIfc_requests_1_enq_v);
  tUInt8 METH_RDY_portalIfc_requests_1_enq();
  tUInt8 METH_portalIfc_requests_1_notFull();
  tUInt8 METH_RDY_portalIfc_requests_1_notFull();
  void METH_portalIfc_requests_2_enq(tUInt32 ARG_portalIfc_requests_2_enq_v);
  tUInt8 METH_RDY_portalIfc_requests_2_enq();
  tUInt8 METH_portalIfc_requests_2_notFull();
  tUInt8 METH_RDY_portalIfc_requests_2_notFull();
  void METH_portalIfc_requests_3_enq(tUInt32 ARG_portalIfc_requests_3_enq_v);
  tUInt8 METH_RDY_portalIfc_requests_3_enq();
  tUInt8 METH_portalIfc_requests_3_notFull();
  tUInt8 METH_RDY_portalIfc_requests_3_notFull();
  tUInt64 METH_pipes_addrTrans_PipeOut_first();
  tUInt8 METH_RDY_pipes_addrTrans_PipeOut_first();
  void METH_pipes_addrTrans_PipeOut_deq();
  tUInt8 METH_RDY_pipes_addrTrans_PipeOut_deq();
  tUInt8 METH_pipes_addrTrans_PipeOut_notEmpty();
  tUInt8 METH_RDY_pipes_addrTrans_PipeOut_notEmpty();
  tUInt8 METH_pipes_setTileState_PipeOut_first();
  tUInt8 METH_RDY_pipes_setTileState_PipeOut_first();
  void METH_pipes_setTileState_PipeOut_deq();
  tUInt8 METH_RDY_pipes_setTileState_PipeOut_deq();
  tUInt8 METH_pipes_setTileState_PipeOut_notEmpty();
  tUInt8 METH_RDY_pipes_setTileState_PipeOut_notEmpty();
  tUInt8 METH_pipes_stateDbg_PipeOut_first();
  tUInt8 METH_RDY_pipes_stateDbg_PipeOut_first();
  void METH_pipes_stateDbg_PipeOut_deq();
  tUInt8 METH_RDY_pipes_stateDbg_PipeOut_deq();
  tUInt8 METH_pipes_stateDbg_PipeOut_notEmpty();
  tUInt8 METH_RDY_pipes_stateDbg_PipeOut_notEmpty();
  tUInt8 METH_pipes_memoryTraffic_PipeOut_first();
  tUInt8 METH_RDY_pipes_memoryTraffic_PipeOut_first();
  void METH_pipes_memoryTraffic_PipeOut_deq();
  tUInt8 METH_RDY_pipes_memoryTraffic_PipeOut_deq();
  tUInt8 METH_pipes_memoryTraffic_PipeOut_notEmpty();
  tUInt8 METH_RDY_pipes_memoryTraffic_PipeOut_notEmpty();
 
 /* Reset routines */
 public:
  void reset_RST_N(tUInt8 ARG_rst_in);
 
 /* Static handles to reset routines */
 public:
 
 /* Pointers to reset fns in parent module for asserting output resets */
 private:
 
 /* Functions for the parent module to register its reset fns */
 public:
 
 /* Functions to set the elaborated clock id */
 public:
  void set_clk_0(char const *s);
 
 /* State dumping routine */
 public:
  void dump_state(unsigned int indent);
 
 /* VCD dumping routines */
 public:
  unsigned int dump_VCD_defs(unsigned int levels);
  void dump_VCD(tVCDDumpType dt, unsigned int levels, MOD_mkMemServerRequestInput &backing);
  void vcd_defs(tVCDDumpType dt, MOD_mkMemServerRequestInput &backing);
  void vcd_prims(tVCDDumpType dt, MOD_mkMemServerRequestInput &backing);
};

#endif /* ifndef __mkMemServerRequestInput_h__ */
