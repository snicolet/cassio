UNIT BasicHashing;


INTERFACE


USES basictypes, basicstring;


// Polymorphic hashing function
function GenericHash(data : Ptr; tailleData : SInt32) : SInt32;

// Hashing function specialized for strings.
function HashString(const s : String255) : SInt32;
function HashString2(const s : String255) : SInt32;
function HashString63Bits(const s : String255) : UInt64;

// Counting and optionally hashing lexems
function CountAndHashLexems(const s : String255; table : LongintArrayPtr) : SInt32;

// InitBasicHashing() : init the BasicHashing library
procedure InitBasicHashing;



IMPLEMENTATION

USES basicmath;



type PackedMemory = packed array[0..0] of UInt8;
     PackedMemoryPtr = ^PackedMemory;
const initialisation_done : boolean = false;
var XORValues : array[0..255,0..3] of SInt32;


// InitBasicHashing() : initializations of the BasicHashing library
procedure InitBasicHashing;
var i,j : SInt16;
    aux : SInt32;
begin
  SetRandomSeed(1234);

  for j := 0 to 3 do
    for i := 0 to 255 do
      begin
        aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        if aux = 0 then aux := Random32();
        XORValues[i,j] := aux;
      end;
  initialisation_done := true;
end;


// GenericHash() : La fonction polymorphe de hachage

function GenericHash(data : Ptr; tailleData : SInt32) : SInt32;
type FourBytesRec = packed array[0..3] of UInt8;
     FourBytesPtr = ^FourBytesRec;
var aux, i : SInt32;
    memoryBuffer : PackedMemoryPtr;
    myFourBytes : FourBytesPtr;
begin
  if not(initialisation_done) then
    begin
      (* Writeln('Calling InitBasicHashing for you : you should do it yourself !'); *)
      InitBasicHashing;
    end;

  memoryBuffer := PackedMemoryPtr(data);
  aux := 1013904223; (* See Numerical Recipes in C, 2nd Edition, p.284 *)
  for i := 0 to tailleData-1 do
    begin
      (* Writeln('aux = ',aux); *)

      (* 1664525 = nb impair pas trop pres d'une puissance de deux.
         See Numerical Recipes in C, 2nd Edition, p.284 *)
      aux := aux * 1664525 + memoryBuffer^[i];

      (* Writeln(chr(memoryBuffer^[i]),memoryBuffer^[i]); *)
    end;

  (* Writeln('');
     Writeln('aux = ',aux);  *)

  myFourBytes := FourBytesPtr(@aux);

  (*
  Writeln('aux[0] = ',myFourBytes^[0]);
  Writeln('aux[1] = ',myFourBytes^[1]);
  Writeln('aux[2] = ',myFourBytes^[2]);
  Writeln('aux[3] = ',myFourBytes^[3]);
  *)

// This code for little-endian processors (like Intel...)
  result := BXOR( (XORValues[myFourBytes^[0],0]), (XORValues[myFourBytes^[1],1]));
  result := BXOR(result, (XORValues[myFourBytes^[2],2]));
  result := BXOR(result, (XORValues[myFourBytes^[3],3]));

// This code for big-endian processors (like Motorola...)
// result := BXOR( (XORValues[myFourBytes^[0],3]), (XORValues[myFourBytes^[1],2]));
// result := BXOR(result, (XORValues[myFourBytes^[2],1]));
// result := BXOR(result, (XORValues[myFourBytes^[3],0]));

  GenericHash := result;
end;




// HashString() is our hash function for strings using Jenkins algorithm.
// One advantage of using Jenkins algorithm is that it is easily portable 
// in other languages. For sources, see :
//      https://en.wikipedia.org/wiki/Jenkins_hash_function
//      http://www.burtleburtle.net/bob/hash/doobs.html

function HashString(const s : String255) : SInt32;
var hash : UInt32;        // unsigned 32 bits integer
    i,taille : SInt32;    // signed 32 bits integer
begin
  hash := 0;
  taille := LENGTH_OF_STRING(s);

  for i := 1 to taille do
    begin
      hash := hash + ord(s[i]);          // ord(s[i]) is the ascii value of the the i-th character in s
      hash := hash + (hash shl 10);
      hash := hash XOR (hash shr 6);
    end;
  hash := hash + (hash shl 3);
  hash := hash XOR (hash shr 11);
  hash := hash + (hash shl 15);

  HashString := SInt32(hash);
end;



// HashString63Bits() : hash of a string, giving a 63 bit UInt64.

// This version of HashString63Bits is for little-indian processors (like Intel...)
function HashString63Bits(const s : String255) : UInt64;
var hi,lo : UInt64;
begin
  hi := HashString(s) and $7FFFFFFF;
  lo := HashString('t' + s);
  HashString63Bits := (hi shl 32) + lo;
end;

// This version of HashString63Bits is for big-endian processors (like Motorola...)
// function HashString63Bits(const s : String255) : UInt64;
// var result : UInt64;
// begin
//   with result do
//     begin
//       hi := HashString(s) and $7FFFFFFF;
//       lo := HashString('t' + s);
//     end;
//   HashString63Bits := result;
// end;



// HashString2() is a weaker hash function for strings, using GenericHash()

function HashString2(const s : String255) : SInt32;
begin
  HashString2 := GenericHash(@s[1],LENGTH_OF_STRING(s));
end;



// La fonction CountAndHashLexems() renvoie le nombre de lexemes de la
// chaine et optionnellement dans table, les hash des differents lexemes.
// Les lexemes calcules sont renvoyes dans table^[1]...table^[nbLexemes] .
// On peut passer NIL dans table pour n'avoir que le nombre de lexemes.
// S'il est non nul, le pointeur table doit pointer vers un tableau d'au
// moins 200 entiers de 32 bits.

function CountAndHashLexems(const s : String255; table : LongintArrayPtr) : SInt32;
var nbLexemes, counter : SInt32;
    lexeme, reste : String255;
begin
  reste := s;
  nbLexemes := 0;
  counter := 0;

  repeat
    Parse(reste, lexeme, reste);
    if (lexeme <> '') then
      begin
        inc(nbLexemes);
        if (table <> NIL) then table^[nbLexemes] := HashString(lexeme);
      end;
    inc(counter);
  until (reste = '') or (nbLexemes >= 200) or (counter > 255);

  CountAndHashLexems := nbLexemes;
end;

// Testing the unit
procedure TestUnitBasicHashing;
begin
   writeln();
   writeln('Testing our implementation of the Jenkins hash function... ');
   writeln('$ca2e9442 should equal ', hexa(HashString('a')));
   writeln('$519e91f5 should equal ', hexa(HashString('The quick brown fox jumps over the lazy dog')));
end;


BEGIN
   InitBasicHashing();  // always call this there !
   
   
   // TestUnitBasicHashing(); 
END.











