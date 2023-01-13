import Vector::*;
import Ehr::*;
import ProcTypes::*;

interface Scoreboard#(numeric type size);
    method Action insert(Maybe#(RIndx) dst);
    method Action remove(Maybe#(RIndx) dst);
    method Bool search1(Maybe#(RIndx) src1);
    method Bool search2(Maybe#(RIndx) src2);
endinterface



// remove < {search1, search2, search3} < insert < clear

// search < insert
// search > remove
// insert > remove
// (* synthesize *)
module mkBypassingScoreboard(Scoreboard#(size));

   Vector#(32, Ehr#(2,Bit#(TLog#(TAdd#(size,1))))) r <- replicateM(mkEhr(0));

   method Action insert(Maybe#(RIndx) dst);
       if ( dst matches tagged Valid .src &&& src != 0)
           r[src][1] <= r[src][1] + 1;
   endmethod

   method Action remove(Maybe#(RIndx) dst);
       if ( dst matches tagged Valid .src &&& src != 0)
           r[src][0] <= r[src][0] - 1;
   endmethod
 
   method Bool search1(Maybe#(RIndx) src1);
       return src1 matches tagged Valid .src &&& src != 0 ? r[src][1] > 0 : False;
       //return isValid(dst) && fromMaybe(0, dst) != 0  ? ((r[fromMaybe(?, dst)])[1] > 0) : False;
   endmethod
   method Bool search2(Maybe#(RIndx) src2);
       return src2 matches tagged Valid .src &&& src != 0 ? r[src][1] > 0 : False;
       // return isValid(dst) && fromMaybe(0, dst) != 0 ? ((r[fromMaybe(?, dst)])[1] > 0) : False;
   endmethod

endmodule


// search < insert
// search < remove
// insert < remove
// (* synthesize *)
module mkScoreboard(Scoreboard#(size));

   Vector#(32, Ehr#(3,Bit#(TLog#(TAdd#(size,1))))) r <- replicateM(mkEhr(0));

   method Action insert(Maybe#(RIndx) dst);
       if ( dst matches tagged Valid .src &&& src != 0) begin
           // $display("sb.insert(%h)", src);
           r[src][0] <= r[src][0] + 1;
       end
    // if ( isValid(dst) )
    //     (r[fromMaybe(?, dst)])[0] <= (r[fromMaybe(?, dst)])[0] + 1;
   endmethod

   method Action remove(Maybe#(RIndx) dst);
       if ( dst matches tagged Valid .src &&& src != 0) begin
           // $display("sb.remove(%h)", src);
           r[src][1] <= r[src][1] - 1;
       end

       // if ( isValid(dst) )
       //     (r[fromMaybe(?, dst)])[1] <= (r[fromMaybe(?, dst)])[1] - 1;
   endmethod
 
   method Bool search1(Maybe#(RIndx) src1);
       return src1 matches tagged Valid .src &&& src != 0 ? r[src][0] > 0 : False;
       // return isValid(dst) && fromMaybe(0, dst) != 0 ? ((r[fromMaybe(?, dst)])[0] > 0): False;
   endmethod
    
   method Bool search2(Maybe#(RIndx) src2);
       return src2 matches tagged Valid .src &&& src != 0 ? r[src][0] > 0 : False;
       // return isValid(dst) && fromMaybe(0, dst) != 0 ? ((r[fromMaybe(?, dst)])[0] > 0): False;
   endmethod

endmodule