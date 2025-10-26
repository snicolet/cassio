unit basicmath;

interface

uses

{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils,
  basictypes,
  basicstring;


// Bitwise functions

function BAND(i, j : UInt64) : UInt64;
function BAND(i, j : SInt64) : SInt64;
function BAND(i, j : UInt32) : UInt32;
function BAND(i, j : SInt32) : SInt32;
function BAND(i, j : UInt16) : UInt16;
function BAND(i, j : SInt16) : SInt16;
function BAND(i, j : UInt8)  : UInt8;
function BAND(i, j : SInt8)  : SInt8;

function BOR(i, j : UInt64) : UInt64;
function BOR(i, j : SInt64) : SInt64;
function BOR(i, j : UInt32) : UInt32;
function BOR(i, j : SInt32) : SInt32;
function BOR(i, j : UInt16) : UInt16;
function BOR(i, j : SInt16) : SInt16;
function BOR(i, j : UInt8)  : UInt8;
function BOR(i, j : SInt8)  : SInt8;

function BXOR(i, j : UInt64) : UInt64;
function BXOR(i, j : SInt64) : SInt64;
function BXOR(i, j : UInt32) : UInt32;
function BXOR(i, j : SInt32) : SInt32;
function BXOR(i, j : UInt16) : UInt16;
function BXOR(i, j : SInt16) : SInt16;
function BXOR(i, j : UInt8)  : UInt8;
function BXOR(i, j : SInt8)  : SInt8;

function BSR(i : UInt64; n : integer) : UInt64;
function BSR(i : SInt64; n : integer) : SInt64;
function BSR(i : UInt32; n : integer) : UInt32;
function BSR(i : SInt32; n : integer) : SInt32;
function BSR(i : UInt16; n : integer) : UInt16;
function BSR(i : SInt16; n : integer) : SInt16;
function BSR(i : UInt8 ; n : integer) : UInt8;
function BSR(i : SInt8 ; n : integer) : SInt8;

function BSL(i : UInt64; n : integer) : UInt64;
function BSL(i : SInt64; n : integer) : SInt64;
function BSL(i : UInt32; n : integer) : UInt32;
function BSL(i : SInt32; n : integer) : SInt32;
function BSL(i : UInt16; n : integer) : UInt16;
function BSL(i : SInt16; n : integer) : SInt16;
function BSL(i : UInt8 ; n : integer) : UInt8;
function BSL(i : SInt8 ; n : integer) : SInt8;

function BNOT(i : UInt64) : UInt64;
function BNOT(i : SInt64) : SInt64;
function BNOT(i : UInt32) : UInt32;
function BNOT(i : SInt32) : SInt32;
function BNOT(i : UInt16) : UInt16;
function BNOT(i : SInt16) : SInt16;
function BNOT(i : UInt8)  : UInt8;
function BNOT(i : SInt8)  : SInt8;

function BTST(i : UInt64; n : integer) : boolean;
function BTST(i : SInt64; n : integer) : boolean;
function BTST(i : UInt32; n : integer) : boolean;
function BTST(i : SInt32; n : integer) : boolean;
function BTST(i : UInt16; n : integer) : boolean;
function BTST(i : SInt16; n : integer) : boolean;
function BTST(i : UInt8 ; n : integer) : boolean;
function BTST(i : SInt8 ; n : integer) : boolean;

procedure BSET(var i : UInt64; n : integer);
procedure BSET(var i : SInt64; n : integer);
procedure BSET(var i : UInt32; n : integer);
procedure BSET(var i : SInt32; n : integer);
procedure BSET(var i : UInt16; n : integer);
procedure BSET(var i : SInt16; n : integer);
procedure BSET(var i : UInt8 ; n : integer);
procedure BSET(var i : SInt8 ; n : integer);

procedure BCLR(var i : UInt64; n : integer);
procedure BCLR(var i : SInt64; n : integer);
procedure BCLR(var i : UInt32; n : integer);
procedure BCLR(var i : SInt32; n : integer);
procedure BCLR(var i : UInt16; n : integer);
procedure BCLR(var i : SInt16; n : integer);
procedure BCLR(var i : UInt8 ; n : integer);
procedure BCLR(var i : SInt8 ; n : integer);




implementation


// Bitwise functions

function BAND(i, j : UInt64) : UInt64;
begin
  result := i and j;
end;

function BAND(i, j : SInt64) : SInt64;
begin
  result := i and j;
end;

function BAND(i, j : UInt32) : UInt32;
begin
  result := i and j;
end;

function BAND(i, j : SInt32) : SInt32;
begin
  result := i and j;
end;

function BAND(i, j : UInt16) : UInt16;
begin
  result := i and j;
end;

function BAND(i, j : SInt16) : SInt16;
begin
  result := i and j;
end;

function BAND(i, j : UInt8) : UInt8;
begin
  result := i and j;
end;

function BAND(i, j : SInt8) : SInt8;
begin
  result := i and j;
end;


function BOR(i, j : UInt64) : UInt64;
begin
  result := i or j;
end;

function BOR(i, j : SInt64) : SInt64;
begin
  result := i or j;
end;

function BOR(i, j : UInt32) : UInt32;
begin
  result := i or j;
end;

function BOR(i, j : SInt32) : SInt32;
begin
  result := i or j;
end;

function BOR(i, j : UInt16) : UInt16;
begin
  result := i or j;
end;

function BOR(i, j : SInt16) : SInt16;
begin
  result := i or j;
end;

function BOR(i, j : UInt8) : UInt8;
begin
  result := i or j;
end;

function BOR(i, j : SInt8) : SInt8;
begin
  result := i or j;
end;

function BXOR(i, j : UInt64) : UInt64;
begin
  result :=  i xor j;
end;

function BXOR(i, j : SInt64) : SInt64;
begin
  result :=  i xor j;
end;

function BXOR(i, j : UInt32) : UInt32;
begin
  result :=  i xor j;
end;

function BXOR(i, j : SInt32) : SInt32;
begin
  result :=  i xor j;
end;

function BXOR(i, j : UInt16) : UInt16;
begin
  result :=  i xor j;
end;

function BXOR(i, j : SInt16) : SInt16;
begin
  result :=  i xor j;
end;

function BXOR(i, j : UInt8) : UInt8;
begin
  result :=  i xor j;
end;

function BXOR(i, j : SInt8) : SInt8;
begin
  result :=  i xor j;
end;

function BSR(i : UInt64; n : integer) : UInt64;
begin
  result := i shr n;
end;

function BSR(i : SInt64; n : integer) : SInt64;
begin
  result := i shr n;
end;

function BSR(i : UInt32; n : integer) : UInt32;
begin
  result := i shr n;
end;

function BSR(i : SInt32; n : integer) : SInt32;
begin
  result := i shr n;
end;

function BSR(i : UInt16; n : integer) : UInt16;
begin
  result := i shr n;
end;

function BSR(i : SInt16; n : integer) : SInt16;
begin
  result := i shr n;
end;

function BSR(i : UInt8; n : integer) : UInt8;
begin
  result := i shr n;
end;

function BSR(i : SInt8; n : integer) : SInt8;
begin
  result := i shr n;
end;

function BSL(i : UInt64; n : integer) : UInt64;
begin
  result := i shl n;
end;

function BSL(i : SInt64; n : integer) : SInt64;
begin
  result := i shl n;
end;

function BSL(i : UInt32; n : integer) : UInt32;
begin
  result := i shl n;
end;

function BSL(i : SInt32; n : integer) : SInt32;
begin
  result := i shl n;
end;

function BSL(i : UInt16; n : integer) : UInt16;
begin
  result := i shl n;
end;

function BSL(i : SInt16; n : integer) : SInt16;
begin
  result := i shl n;
end;

function BSL(i : UInt8; n : integer) : UInt8;
begin
  result := i shl n;
end;

function BSL(i : SInt8; n : integer) : SInt8;
begin
  result := i shl n;
end;

function BNOT(i : UInt64) : UInt64;
begin
  result := not(i);
end;

function BNOT(i : SInt64) : SInt64;
begin
  result := not(i);
end;

function BNOT(i : UInt32) : UInt32;
begin
  result := not(i);
end;

function BNOT(i : SInt32) : SInt32;
begin
  result := not(i);
end;

function BNOT(i : UInt16) : UInt16;
begin
  result := not(i);
end;

function BNOT(i : SInt16) : SInt16;
begin
  result := not(i);
end;

function BNOT(i : UInt8) : UInt8;
begin
  result := not(i);
end;

function BNOT(i : SInt8) : SInt8;
begin
  result := not(i);
end;

function BTST(i : UInt64; n : integer) : boolean;
var one : UInt64;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : SInt64; n : integer) : boolean;
var one : SInt64;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : SInt32; n : integer) : boolean;
var one : SInt32;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : UInt32; n : integer) : boolean;
var one : UInt32;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : UInt16; n : integer) : boolean;
var one : UInt16;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : SInt16; n : integer) : boolean;
var one : SInt16;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : SInt8; n : integer) : boolean;
var one : SInt8;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

function BTST(i : UInt8; n : integer) : boolean;
var one : UInt8;
begin
  one := 1;
  result := (((i shr n) and one) = one);
end;

procedure BSET(var i : UInt64; n : integer);
var one : UInt64;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : SInt64; n : integer);
var one : SInt64;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : UInt32; n : integer);
var one : UInt32;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : SInt32; n : integer);
var one : SInt32;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : UInt16; n : integer);
var one : UInt16;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : SInt16; n : integer);
var one : SInt16;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : UInt8; n : integer);
var one : UInt8;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BSET(var i : SInt8; n : integer);
var one : SInt8;
begin
  one := 1;
  i := (i or (one shl n));
end;

procedure BCLR(var i : UInt64; n : integer);
var one : UInt64;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : SInt64; n : integer);
var one : SInt64;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : UInt32; n : integer);
var one : UInt32;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : SInt32; n : integer);
var one : SInt32;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : UInt16; n : integer);
var one : UInt16;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : SInt16; n : integer);
var one : SInt16;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : UInt8; n : integer);
var one : UInt8;
begin
  one := 1;
  i := (i and not(one shl n));
end;

procedure BCLR(var i : SInt8; n : integer);
var one : SInt8;
begin
  one := 1;
  i := (i and not(one shl n));
end;

// A utility function to test booleans shortcuts operators

function id(b : boolean; name : string255) : boolean;
begin
   write(name + ' = ');
   writeln(b);
   
   result := b;
end;


procedure TestBasicMath;
var c1, c2 : boolean;
    aux, neg, inv, add, clr : SInt64;
    ext : UInt64;
    k : integer;
begin

   c1 := true;
   c2 := false;
   if (id(c1, 'c1') and id(c2, 'c2')) then
      writeln('| works : OK');
      
      
  writeln('Verifying BTST BSET BCLR');
  
  for k := 0 to (sizeof(aux) * 8 - 1) do
  begin
     aux := 0;
     BSET(aux, k);
     neg := -aux;
     inv := BNOT(aux);
     add := inv + 1;
     ext := neg;
     clr := aux;
     BCLR(clr, k);
     writeln('k = ',k, ', after BSET(aux , k) :  hexa = ' + Hexa(aux) , ' , dec = ', aux);
     writeln('k = ',k, ', after BNOT(aux)     :  hexa = ' + Hexa(inv) , ' , dec = ', inv);
     writeln('k = ',k, ', after BNOT(aux)+1   :  hexa = ' + Hexa(add) , ' , dec = ', add);
     writeln('k = ',k, ', after negating      :  hexa = ' + Hexa(neg) , ' , dec = ', neg);
     writeln('k = ',k, ', neg ext. to 64 bits :  hexa = ' + Hexa(ext) , ' , dec = ', ext);
     writeln('k = ',k, ', after BCLR(aux , k) :  hexa = ' + Hexa(clr) , ' , dec = ', clr);
     writeln('');
  end;

  writeln('note that X := Y always extends the sign bit of Y into X when Y has a signed integer type');

  writeln('');

end;


begin
    TestBasicMath;
end.


















