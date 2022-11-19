function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction

function Bit#(2) ha_add(Bit#(1) a,Bit#(1) b);
    Bit#(1) s=a^b;
    Bit#(1) c=a&b;
    return {c,s};
endfunction

function Bit#(2) fa_add(Bit#(1) a,Bit#(1) b,Bit#(1) c);
    Bit#(2) ab=ha_add(a,b);
    Bit#(2) abc=ha_add(ab[0],c);
    Bit#(1) cout=ab[1]|abc[1];
    return {cout,abc[0]};
endfunction

function Bit#(TAdd#(n,1)) addN(Bit#(n) a, Bit#(n) b,Bit#(1) c0);
    Bit#(n) s;
    Bit#(TAdd#(n,1)) c=0;
    c[0]=c0;
    for(Integer i=0;i<valueOf(n);i=i+1) begin
        let cs=fa_add(a[i],b[i],c[i]);
        c[i+1]=cs[1];
        s[i]=cs[0];
    end
    return {c[valueOf(n)],s};
endfunction

function Bit#(TAdd#(n,n)) multiply_by_adding( Bit#(n) a, Bit#(n) b );
    Bit#(n) tp=0;
    Bit#(n) prod=0;
    for(Integer i=0;i<valueOf(n);i=i+1) begin
        Bit#(n) m=(a[i]==0)?0:b;
        Bit#(TAdd#(n,1)) sum=addN(m,tp,0);
        prod[i]=sum[0];
        tp=sum[valueOf(n):1];
    end
    return {tp,prod};
endfunction

interface Multiplier#( numeric type n );
    method Bool start_ready();
    method Action start( Bit#(n) x, Bit#(n) y );
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result;
endinterface

module mkFoldedMultiplier(Multiplier#(n));

    Reg#(Bit#(n)) a <- mkRegU();
    Reg#(Bit#(n)) b <- mkRegU();
    Reg#(Bit#(n)) p <- mkRegU();
    Reg#(Bit#(n)) tp <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mulStep(i<fromInteger(valueOf(n)));
        Bit#(n) m=(a[0]==0)?0:b;
        a<=a>>1;
        let s=addN(m,tp,0);
        Bit#(n) pnew=p>>1;
        pnew[valueOf(TSub#(n,1))]=s[0];
        p<=pnew;
        tp<=s[valueOf(n):1];
        i<=i+1;
    endrule

    method Bool start_ready();
        return i==fromInteger(valueOf(n)+1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        if(i==fromInteger(valueOf(n)+1)) begin
            a<=aIn;
            b<=bIn;
            p<=0;
            tp<=0;
            i<=0;
        end
    endmethod

    method Bool result_ready();
        return i==fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        if(i==fromInteger(valueOf(n))) begin
            i<=i+1;
            return {tp,p};
        end else begin
            return 0;
        end
    endmethod
endmodule

module mkBoothMultiplier(Multiplier#(n));

    Reg#(Int#(TAdd#(n,n))) m <- mkRegU();
    Reg#(Bit#(TAdd#(n,1))) r <- mkRegU();
    Reg#(Int#(TAdd#(n,n))) p <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mulStep(i<fromInteger(valueOf(n)));
        Bit#(2) code = r[1:0];
        r<=r>>1;
        if(code==2'b10) begin
            p<=p-m;
        end else if(code==2'b01) begin
            p<=p+m;
        end
        m<=m<<1;
        i<=i+1;
    endrule

    method Bool start_ready();
        return i==fromInteger(valueOf(n)+1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        if(i==fromInteger(valueOf(n)+1)) begin
            Int#(n) a_int = unpack(aIn);
            Int#(TAdd#(n,n)) a_ext = signExtend(a_int);
            m<=a_ext;
            r<={bIn,0};
            p<=0;
            i<=0;
        end
    endmethod

    method Bool result_ready();
        return i==fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        if(i==fromInteger(valueOf(n))) begin
            i<=i+1;
            return pack(p);
        end else begin
            return 0;
        end
    endmethod
endmodule

module mkBoothMultiplierRadix4(Multiplier#(n));

    Reg#(Int#(TAdd#(n,n))) m <- mkRegU();
    Reg#(Bit#(TAdd#(n,1))) r <- mkRegU();
    Reg#(Int#(TAdd#(n,n))) p <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(TDiv#(n,2))+1) );

    let pPlusm=p+m;
    let pMinusm=p-m;
    let pPlus2m=p+(m<<1);
    let pMinus2m=p-(m<<1);

    rule mulStep(i<fromInteger(valueOf(TDiv#(n,2))));
        Bit#(3) code = r[2:0];
        r<=r>>2;

        if(code==3'b001) begin p<=pPlusm; end
        if(code==3'b010) begin p<=pPlusm; end
        if(code==3'b011) begin p<=pPlus2m; end
        if(code==3'b100) begin p<=pMinus2m; end
        if(code==3'b101) begin p<=pMinusm; end
        if(code==3'b110) begin p<=pMinusm; end

        m<=m<<2;
        i<=i+1;
    endrule

    method Bool start_ready();
        return i==fromInteger(valueOf(TDiv#(n,2))+1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        if(i==fromInteger(valueOf(TDiv#(n,2))+1)) begin
            Int#(n) a_int = unpack(aIn);
            Int#(TAdd#(n,n)) a_ext = signExtend(a_int);
            m<=a_ext;
            r<={bIn,0};
            p<=0;
            i<=0;
        end
    endmethod

    method Bool result_ready();
        return i==fromInteger(valueOf(TDiv#(n,2)));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        if(i==fromInteger(valueOf(TDiv#(n,2)))) begin
            i<=i+1;
            return pack(p);
        end else begin
            return 0;
        end
    endmethod
endmodule
