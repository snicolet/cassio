unit basicmath;

interface

uses

{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  BaseUnix,
  SysUtils,
  basictypes,
  basicstring;


// Pseudo-Random Number Generator (xorshift64star)

function Random16() : SInt16;
function Random32() : SInt32;
function Random64() : SInt64;
function RandomFloat() : double;
procedure SetRandomSeed(seed : SInt64);
procedure RandomizeTimer;


// Bitwise functions (with versions for all integer sizes, signed and unsigned)

// Bitwise NOT
function BNOT(i : UInt64) : UInt64;
function BNOT(i : SInt64) : SInt64;
function BNOT(i : UInt32) : UInt32;
function BNOT(i : SInt32) : SInt32;
function BNOT(i : UInt16) : UInt16;
function BNOT(i : SInt16) : SInt16;
function BNOT(i : UInt8)  : UInt8;
function BNOT(i : SInt8)  : SInt8;

// Bitwise AND
function BAND(i, j : UInt64) : UInt64;
function BAND(i, j : SInt64) : SInt64;
function BAND(i, j : UInt32) : UInt32;
function BAND(i, j : SInt32) : SInt32;
function BAND(i, j : UInt16) : UInt16;
function BAND(i, j : SInt16) : SInt16;
function BAND(i, j : UInt8)  : UInt8;
function BAND(i, j : SInt8)  : SInt8;

// Bitwise OR
function BOR(i, j : UInt64) : UInt64;
function BOR(i, j : SInt64) : SInt64;
function BOR(i, j : UInt32) : UInt32;
function BOR(i, j : SInt32) : SInt32;
function BOR(i, j : UInt16) : UInt16;
function BOR(i, j : SInt16) : SInt16;
function BOR(i, j : UInt8)  : UInt8;
function BOR(i, j : SInt8)  : SInt8;

// Bitwise XOR
function BXOR(i, j : UInt64) : UInt64;
function BXOR(i, j : SInt64) : SInt64;
function BXOR(i, j : UInt32) : UInt32;
function BXOR(i, j : SInt32) : SInt32;
function BXOR(i, j : UInt16) : UInt16;
function BXOR(i, j : SInt16) : SInt16;
function BXOR(i, j : UInt8)  : UInt8;
function BXOR(i, j : SInt8)  : SInt8;

// Bit shift right
function BSR(i : UInt64; n : integer) : UInt64;
function BSR(i : SInt64; n : integer) : SInt64;
function BSR(i : UInt32; n : integer) : UInt32;
function BSR(i : SInt32; n : integer) : SInt32;
function BSR(i : UInt16; n : integer) : UInt16;
function BSR(i : SInt16; n : integer) : SInt16;
function BSR(i : UInt8 ; n : integer) : UInt8;
function BSR(i : SInt8 ; n : integer) : SInt8;

// Bit shift left
function BSL(i : UInt64; n : integer) : UInt64;
function BSL(i : SInt64; n : integer) : SInt64;
function BSL(i : UInt32; n : integer) : UInt32;
function BSL(i : SInt32; n : integer) : SInt32;
function BSL(i : UInt16; n : integer) : UInt16;
function BSL(i : SInt16; n : integer) : SInt16;
function BSL(i : UInt8 ; n : integer) : UInt8;
function BSL(i : SInt8 ; n : integer) : SInt8;

// Individual bit testing
function BTST(i : UInt64; n : integer) : boolean;
function BTST(i : SInt64; n : integer) : boolean;
function BTST(i : UInt32; n : integer) : boolean;
function BTST(i : SInt32; n : integer) : boolean;
function BTST(i : UInt16; n : integer) : boolean;
function BTST(i : SInt16; n : integer) : boolean;
function BTST(i : UInt8 ; n : integer) : boolean;
function BTST(i : SInt8 ; n : integer) : boolean;

// Individual bit setting
procedure BSET(var i : UInt64; n : integer);
procedure BSET(var i : SInt64; n : integer);
procedure BSET(var i : UInt32; n : integer);
procedure BSET(var i : SInt32; n : integer);
procedure BSET(var i : UInt16; n : integer);
procedure BSET(var i : SInt16; n : integer);
procedure BSET(var i : UInt8 ; n : integer);
procedure BSET(var i : SInt8 ; n : integer);


// Individual bit clearing
procedure BCLR(var i : UInt64; n : integer);
procedure BCLR(var i : SInt64; n : integer);
procedure BCLR(var i : UInt32; n : integer);
procedure BCLR(var i : SInt32; n : integer);
procedure BCLR(var i : UInt16; n : integer);
procedure BCLR(var i : SInt16; n : integer);
procedure BCLR(var i : UInt8 ; n : integer);
procedure BCLR(var i : SInt8 ; n : integer);


// NewMagicCookie() : a strictly increasing counter.
function NewMagicCookie() : SInt64;



implementation


{$IFDEF UNIX}
  uses unix;
{$ENDIF}

var PRNG : SInt64 = 1000;
var magicCookieSeed : SInt64 = 0;



// Pseudo-Random Number Generator (xorshift64star)
//
// This implementation is based on original code written and dedicated
// to the public domain by Sebastiano Vigna (2014).
// It has the following characteristics:
//    -  Outputs 64-bit numbers
//    -  Passes Dieharder and SmallCrush test batteries
//    -  Does not require warm-up, no zeroland to escape
//    -  Internal state is a single 64-bit integer
//    -  Period is 2^64 - 1
//    -  Speed: 1.60 ns/call (Core i7 @3.40GHz)
// For further analysis see
//       <http://vigna.di.unimi.it/ftp/papers/xorshift.pdf>

// Random64() : 64 bits random integer
function Random64() : SInt64;
begin
    PRNG := BXOR(PRNG, BSR(PRNG, 12));
    PRNG := BXOR(PRNG, BSL(PRNG, 25));
    PRNG := BXOR(PRNG, BSR(PRNG, 27));
    Result := PRNG * 2685821657736338717;
end;

// Random32() : 32 bits random integer
function Random32() : SInt32;
var r : SInt32;
begin
    r := Random64();
    Result := BAND(r, $ffffffff );
end;

// Random16() : 16 bits random integer
function Random16() : SInt16;
var r : SInt16;
begin
    r := Random64();
    Result := BAND(r, $ffff );
end;


// RandomFloat() returns a floating point number in double precision
// in the interval [0..1[
function RandomFloat() : double;
var one, r : UInt64;
begin
    one := 1;
    r := Random64();
    result := double(BSR(r , 11)) / double(BSL(one , 53));
end;


// SetRandomSeed() : initialising the seed of the random generator
procedure SetRandomSeed(seed : SInt64);
begin
    if seed = 0 then seed := 1;
    PRNG := seed;
end;

// RandomizeTimer : this procedure sets the seed with a mix of the current 
// time, the process number, etc. to get more entropy.
procedure RandomizeTimer;
var seed : SInt64;
    {$IFDEF UNIX}
    t : timeval;
    {$ENDIF}
begin
  seed := FpGetpid();                 // process number
  seed := seed + Random64();          // a small random component from current 
  seed := seed + NewMagicCookie();    // increasing counter
  seed := seed + GetTickCount64();    // milliseconds

  {$IFDEF UNIX}
  fpgettimeofday(@t,nil);
  seed := seed + t.tv_usec;           // microseconds
  {$ENDIF}

  seed := seed * 2685821657736338717;

  SetRandomSeed(seed);
end;



// NewMagicCookie() returns a unique and positive value. Period is 2^63.
function NewMagicCookie() : SInt64;
begin
  magicCookieSeed := magicCookieSeed + 1;
  if magicCookieSeed <= 0 then magicCookieSeed := 1;
  Result := magicCookieSeed;
end;


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


// id() is a utility function to test booleans shortcuts operators

function id(b : boolean; name : string255) : boolean;
begin
   write('  ' + name + ' = ');
   write(SInt64(b));
   result := b;
end;


// TestBasicMath() : testing various functions of the BasicMemory unit

procedure TestBasicMath;
var c1, c2 : boolean;
    aux, neg, inv, add, clr : SInt16;  // or any integer type
    ext : UInt64;
    k, r, N, t : SInt64;
    freq : array[0..9] of SInt64;
begin

  writeln('');
  writeln('Verifying boolean shortcuts...');
  for c1 := false to true do
   for c2 := false to true do
     begin
        write(SInt64(c1), ' or ', SInt64(c2), ' ? ');
        if (id(c1, 'c1') or id(c2, 'c2'))
           then writeln(' ==> TRUE')
           else writeln(' ==> FALSE');
     end;
  for c1 := false to true do
   for c2 := false to true do
     begin
        write(SInt64(c1), ' and ', SInt64(c2), ' ? ');
        if (id(c1, 'c1') and id(c2, 'c2'))
           then writeln(' ==> TRUE')
           else writeln(' ==> FALSE');
     end;
     
  writeln('');
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
  
  writeln('generating some pseudo random numbers...');
  RandomizeTimer;
  N := 2000000;
  for k := 0 to 9 do
     freq[k] := 0;
  t := GetTickCount64();  // start timer
  for k := 1 to N do
    begin
      // r := Random64();
      // writeln(Random64());
      r := trunc(10 * RandomFloat());
      freq[r] := freq[r] + 1;
    end;
  t := GetTickCount64() - t;  // stop timer
  for k := 0 to 9 do
     writeln(1.0 * freq[k] / N);
  
  writeln('time = ', t , ' milliseconds for ', N, ' random numbers');
  writeln('time for each randomnumber = ', 1000000.0 * t / N, ' nanoseconds');

end;


begin
    TestBasicMath;
end.


















