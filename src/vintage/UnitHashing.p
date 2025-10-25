UNIT UnitHashing;



{ Fonction generique de hachage }

INTERFACE







 USES UnitDefCassio;


procedure InitUnitHashing;

{La fonction polymorphe de hachage}
function GenericHash(data : Ptr; tailleData : SInt32) : SInt32;

{fonctions de hachage specialisees}
function HashString(const s : String255) : SInt32;
function HashString2(const s : String255) : SInt32;
function HashString63Bits(const s : String255) : UInt64;

// La fonction HashLexemes() suivante renvoie le nombre de lexemes de la
// chaine et (facultativement) dans table, les hash des differents lexemes.
// On peut passer NIL dans table pour n'avoir que le nombre de lexemes.
// S'il est non nul, le pointeur table doit pointer vers un tableau d'au
// moins 200 entiers de 32 bits.
function HashLexemes(const s : String255; table : LongintArrayPtr) : SInt32;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    MyStrings, MyMathUtils, UnitServicesMemoire ;
{$ELSEC}
    {$I prelink/Hashing.lk}
{$ENDC}


{END_USE_CLAUSE}











type PackedMemory = packed array[0..0] of UInt8;
     PackedMemoryPtr = ^PackedMemory;

const initialisation_done : boolean = false;

var XORValues : array[0..255,0..3] of SInt32;

procedure InitUnitHashing;
var i,j : SInt16;
    aux : SInt32;
begin
  {RandomizeTimer;}
  SetQDGlobalsRandomSeed(1000);

  for j := 0 to 3 do
    for i := 0 to 255 do
      begin
        aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        if aux = 0 then aux := RandomLongint;
        XORValues[i,j] := aux;
      end;
  initialisation_done := true;
end;

function GenericHash(data : Ptr; tailleData : SInt32) : SInt32;
type FourBytesRec = packed array[0..3] of UInt8;
     FourBytesPtr = ^FourBytesRec;
var aux,result,i : SInt32;
    memoryBuffer : PackedMemoryPtr;
    myFourBytes : FourBytesPtr;
begin
  if not(initialisation_done) then
    begin
      (* Writeln('Calling InitUnitHashing for you : you should do it yourself !'); *)
      InitUnitHashing;
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

  {$R-}

{$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }

  result := BXOr( (XORValues[myFourBytes^[0],0]), (XORValues[myFourBytes^[1],1]));
  result := BXOr(result, (XORValues[myFourBytes^[2],2]));
  result := BXOr(result, (XORValues[myFourBytes^[3],3]));

{$ELSEC }

  result := BXOr( (XORValues[myFourBytes^[0],3]), (XORValues[myFourBytes^[1],2]));
  result := BXOr(result, (XORValues[myFourBytes^[2],1]));
  result := BXOr(result, (XORValues[myFourBytes^[3],0]));

{$ENDC }

  GenericHash := result;
end;




// Hash function using Jenkins algorithm, see :
//    http://en.wikipedia.org/wiki/Hash_table
//    http://www.burtleburtle.net/bob/hash/doobs.html
//
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



function HashString2(const s : String255) : SInt32;
begin
  HashString2 := GenericHash(@s[1],LENGTH_OF_STRING(s));
end;


// HashString63Bits() : hash of a string, giving a 63 bit UInt64

 {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
function HashString63Bits(const s : String255) : UInt64;
var hi,lo : UInt64;
begin
  hi := HashString(s) and $7FFFFFFF;
  lo := HashString('t' + s);
  HashString63Bits := (hi shl 32) + lo;
end;
{$ELSEC}
function HashString63Bits(const s : String255) : UInt64;
var result : UInt64;
begin
  with result do
    begin
      hi := HashString(s) and $7FFFFFFF;
      lo := HashString('t' + s);
    end;
  HashString63Bits := result;
end;
{$ENDC}

// La fonction HashLexemes() suivante renvoie le nombre de lexemes de la
// chaine et optionnellement dans table, les hash des differents lexemes.
// Les lexemes calcules sont renvoyes dans table^[1]...table^[nbLexemes] .
// On peut passer NIL dans table pour n'avoir que le nombre de lexemes.
// S'il est non nul, le pointeur table doit pointer vers un tableau d'au
// moins 200 entiers de 32 bits.
function HashLexemes(const s : String255; table : LongintArrayPtr) : SInt32;
var nbLexemes, compteurBoucle : SInt32;
    lexeme, reste : String255;
begin

  (*
  if (table <> NIL) then
    for k := 0 to 100 do table^[k] := -55555555;
  *)

  reste := s;
  nbLexemes := 0;
  compteurBoucle := 0;

  repeat
    Parser(reste, lexeme, reste);
    if (lexeme <> '') and (table <> NIL) then
      begin
        inc(nbLexemes);
        table^[nbLexemes] := HashString(lexeme);
      end;
    inc(compteurBoucle);
  until (reste = '') or (nbLexemes >= 200) or (compteurBoucle > 255);

  HashLexemes := nbLexemes;
end;


END.











