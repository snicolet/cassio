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
function BOR(i, j : UInt64) : UInt64;
function BXOR(i, j : UInt64) : UInt64;
function BSR(i : UInt64; n : integer) : UInt64;
function BSL(i : UInt64; n : integer) : UInt64;
function BTST(i : UInt64; n : integer) : boolean;
procedure BSET(var i : UInt64; n : integer);
procedure BCLR(var i : UInt64; n : integer);
function BNOT(i : UInt64) : UInt64;




implementation


// Bitwise functions

function BAND(i, j : UInt64) : UInt64;
begin
  result := i and j;
end;

function BOR(i, j : UInt64) : UInt64;
begin
  result := i or j;
end;

function BXOR(i, j : UInt64) : UInt64;
begin
  result :=  i xor j;
end;

function BSR(i : UInt64; n : integer) : UInt64;
begin
  result := i shr n;
end;

function BSL(i : UInt64; n : integer) : UInt64;
begin
  result := i shl n;
end;

function BNOT(i : UInt64) : UInt64;
begin
  result := not(i);
end;

function BTST(i : UInt64; n : integer) : boolean;
begin
  result := (((i shr n) and 1) = 1);
end;

procedure BSET(var i : UInt64; n : integer);
begin
  i := (i or (1 shl (n)));
end;

procedure BCLR(var i : UInt64; n : integer);
begin
  i := (i and not(1 shl (n)));
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
begin

   c1 := true;
   c2 := false;
   
   if (id(c1, 'c1') and id(c2, 'c2')) then
      writeln('| marche : OK');
end;


begin
   // TestBasicMath;
end.


















