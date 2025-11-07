unit basicstring;

interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils,
  basictypes,
  basicmemory;


// Basic string types
  type
     String255     =  ShortString;
     Str255        =  ShortString;
     String255Ptr  =  ^String255;
     String255Hdl  =  ^String255Ptr;
     SetOfChar     =  set of char;

     LongString =
       record
         debutLigne : String255;
         finLigne   : String255;
         complete   : boolean;
       end;
     LongStringPtr = ^LongString;


// Function types for strings
  type
     StringProc                 = procedure(var s : String255; var result : SInt32);
     MessageDisplayerProc       = procedure(msg : String255);
     MessageAndNumDisplayerProc = procedure(msg : String255; num : SInt32);

// Copy string from str255 to String255, and reverse
function MyStr255ToString( const s : Str255 ) : String255;
function Str255ToString( const s : Str255 ) : String255;
function StringToStr255( const s : String255 ) : Str255;

// Access the length of a string
function LENGTH_OF_STRING(s : String255)  : SInt64;
function LENGTH_OF_STRING(s : AnsiString) : SInt64;

// Set the length of a string
procedure SET_LENGTH_OF_STRING(var s : String255 ; len : SInt64);
procedure SET_LENGTH_OF_STRING(var s : AnsiString ; len : SInt64);

// Extract substrings
function TPCopy(source : String255; start, count : SInt32) : String255;
procedure KeepPrefix(var s : String255; len : SInt32);
procedure KeepSuffix(var s : String255; len : SInt32);
function Split(s : String255; sub : char; var left, right : String255) : boolean;                 // split by char
function Split(s : String255; const sub : String255; var left, right : String255) : boolean;      // split by string
function SplitRight(s : String255; sub : char; var left, right : String255) : boolean;            // split right by char
function SplitRight(s : String255; const sub : String255; var left, right : String255) : boolean; // split right by string

// Replace patterns in string
function ReplaceStringOnce(const s, pattern, replacement : String255) : String255;
function ReplaceStringAll(const s, pattern, replacement : String255) : String255;
function ReplaceVariable(const s, pattern, replacement : String255) : String255;
function ReplaceParameters(s, p0, p1, p2, p3 : String255) : String255;

// String transformations
function StripDiacritics(const source : AnsiString) : AnsiString;
function StripDiacritics(const source : String255) : String255;
procedure StripHTMLAccents(var s : String255);
function LowerCase(const s : String255; keepAccents : boolean) : String255;
function UpperCase(const s : String255; keepAccents : boolean) : String255;
function LowerCase(ch : char) : char;
function UpperCase(ch : char) : char;
function MirrorString(const s : String255) : String255;

// Test characters and strings
function IsDigit(ch : char) : boolean;
function IsLower(ch : char) : boolean;
function IsUpper(ch : char) : boolean;
function IsAlpha(ch : char) : boolean;
function NoCaseEquals(s1, s2 : String255) : boolean;
function NoCasePos(s1, s2 : String255) : SInt16;
function PosRight(sub : char; const s : String255) : SInt16;
function PosRight(const sub, s : String255) : SInt16;

// Basic parser
procedure Parse(s : String255; var lexem, tail : String255);
procedure Parse3(s : String255; var s1, s2, s3, tail : String255);
procedure Parse4(s : String255; var s1, s2, s3, s4, tail : String255);
procedure Parse5(s : String255; var s1, s2, s3, s4, s5, tail : String255);
procedure Parse6(s : String255; var s1, s2, s3, s4, s5, s6, tail : String255);
procedure ParseWithQuoteProtection(s : String255; var lexem, tail : String255);
function  ParseBuffer(buffer : Ptr; bufferLength, from : SInt32; var lastRead : SInt32) : String255;

// Setting the delimiters for our parser
procedure SetParserDelimiters(parsingCaracters : SetOfChar);
function  GetParserDelimiters : SetOfChar;
procedure SetParserProtectionWithQuotes(flag : boolean);
function  GetParserProtectionWithQuotes() : boolean;



// Hamming distance
function PseudoHammingDistance(const s1, s2 : String255) : SInt32;

// Transforming an integer into hexadecimal
function Hexa(num : UInt64) : String255;
function Hexa(num : SInt64) : String255;
function Hexa(num : UInt32) : String255;
function Hexa(num : SInt32) : String255;
function Hexa(num : UInt16) : String255;
function Hexa(num : SInt16) : String255;
function Hexa(num : UInt8 ) : String255;
function Hexa(num : SInt8 ) : String255;
function HexaWithoutDollar(num : UInt64) : String255;
function HexaWithoutDollar(num : SInt64) : String255;
function HexaWithoutDollar(num : UInt32) : String255;
function HexaWithoutDollar(num : SInt32) : String255;
function HexaWithoutDollar(num : UInt16) : String255;
function HexaWithoutDollar(num : SInt16) : String255;
function HexaWithoutDollar(num : UInt8 ) : String255;
function HexaWithoutDollar(num : SInt8 ) : String255;

// Convert from hexadecimal to integer
function HexToInt(const s : String255) : UInt64;

// Convert string <--> integer
procedure StrToInt32(const s : String255; var value : SInt32);
function StrToInt32(const s : String255) : SInt32;
function IntToStrWithPadding(n, digits : SInt32; formatChar : char) : String255;


{ Creation et/ou initialisation d'une LongString }
procedure InitLongString(var ligne : LongString);
function MakeLongString(const s : String255) : LongString;
function CopyLongString(const ligne : LongString) : LongString;
procedure NormaliserLongString(var ligne : LongString);


{ Acces à une LongString : recherche, comparaison, extraction d'une sous-chaine, etc... }
function LengthOfLongString(const ligne : LongString) : SInt32;
function LongStringIsEmpty(const ligne : LongString) : boolean;
function SameLongString(const ligne1, ligne2 : LongString) : boolean;
function LongStringBeginsWith(const s : String255; const ligne : LongString) : boolean;
function FindStringInLongString(const s : String255; const ligne : LongString) : SInt32;
function LeftOfLongString(const ligne : LongString; len : SInt32) : LongString;


{ Concatenation sur une LongString }
procedure AppendToLongString(var ligne : LongString; const s : String255);
procedure AppendCharToLongString(var ligne : LongString; c : char);
procedure AppendToLeftOfLongString(const s : String255; var ligne : LongString);


{ Conversion de LongString }
procedure LongStringToBuffer(var ligne : LongString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);
procedure BufferToLongString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : LongString);


{ Ecriture d'une LongString dans le rapport }
procedure WriteLongStringDansRapport(const ligne : LongString);
procedure WritelnLongStringDansRapport(const ligne : LongString);


// A function similar to a macro to be used to warn that a feature is not implemented yet
procedure TODO(s : String255);




implementation

uses math,
     BasicMath,
     BasicTerminal;


var protect_parser_with_quotes : boolean;
    parser_delimiters : SetOfChar;
    parser_delimiters_as_booleans : array[0..255] of boolean;


// Copy string from str255 to String255, and reverse

function MyStr255ToString( const s : Str255 ) : String255;
begin
  MyStr255ToString := s
end;

function Str255ToString( const s : Str255 ) : String255;
begin
  Str255ToString := s
end;

function StringToStr255( const s : String255 ) : Str255;
begin
  StringToStr255 := s
end;


// CharToString() : transforming a char into a string. The advantage of using this
// function is to catch differences for some characters which are 1 byte long
// in  GNUPascal and 3 bytes in FreePascal, for instance CharToString('√') and
// CharToString('◊') do not compile.

function CharToString(c : char) : String255;
begin
  CharToString := c;
end;


// LENGTH_OF_STRING : access the length of a string

function LENGTH_OF_STRING(s : String255) : SInt64;
begin
   LENGTH_OF_STRING := Length(s);
end;

function LENGTH_OF_STRING(s : AnsiString) : SInt64;
begin
   LENGTH_OF_STRING := Length(s);
end;


// SET_LENGTH_OF_STRING() : set the length of a string

procedure SET_LENGTH_OF_STRING(var s : String255 ; len : SInt64);
begin
   SetLength(s, len);
end;

procedure SET_LENGTH_OF_STRING(var s : AnsiString ; len : SInt64);
begin
   SetLength(s, len);
end;


// TPCopy() : copy substring from a string. This function, which we used
// in GNU Pascal, gives the same result than FreePascal copy(), except for
// start <= 0. Once we have inspected our code to ensure than we always call
// TPCopy() with start >= 1, we should use copy() instead.
function TPCopy(source : String255; start, count : SInt32) : String255;
var res : String255;
begin

  if (start < 1) then
    begin
      // writeln('WARNING : TPCopy called with start = ', start);
      count := count - (1 - start);
      start := 1;
    end;

  if start + count > LENGTH_OF_STRING(source) then
    count := LENGTH_OF_STRING(source) - start + 1;

  if count < 0 then
    count := 0;

  SET_LENGTH_OF_STRING(res, count);
  if (count > 0) then
     MoveMemory(@source[start], @res[1], count);

  TPCopy := res;
end;


// ReplaceStringOnce() : return a copy of 's' where the leftmost occurence
// of 'pattern' is replaced by 'replacement'.
function ReplaceStringOnce(const s, pattern, replacement : String255) : String255;
var positionSubstring : SInt32;
    res : String255;
begin
  positionSubstring := Pos(pattern,s);
  if (positionSubstring > 0)
     then
       begin
         res := s;
         Delete(res, positionSubstring, LENGTH_OF_STRING(pattern));
         Insert(replacement, res, positionSubstring);
         ReplaceStringOnce := res;
       end
     else
       ReplaceStringOnce := s;
end;


// ReplaceStringAll() : return a copy of 's' where all occurences of 'pattern'
// are replaced by 'replacement'.
function ReplaceStringAll(const s, pattern, replacement : String255) : String255;
begin
  ReplaceStringAll := StringReplace(s, pattern, replacement, [rfReplaceAll]);
end;


function ReplaceVariable(const s, pattern, replacement : String255) : String255;
var positionSubstring,posDeuxPoint : SInt32;
    posCrochetOuvrant,posCrochetFermant : SInt32;
    longueurDuFormat,depart,fin : SInt32;
    resultat,tail,insertion : String255;
begin

  positionSubstring := Pos(pattern,s);

  if (positionSubstring > 0)
     then
       begin
         (*
            on cherche si le pattern est en fait une
            variable de la forme $VARIABLE[deb..fin]
         *)
         tail := TPCopy(s,positionSubstring,255);
         posCrochetOuvrant := Pos('[',tail);
         posCrochetFermant := Pos(']',tail);

         if (tail[1] = '$') and
            (posCrochetOuvrant > 0) and
            (posCrochetFermant > posCrochetOuvrant)
           then
             begin
               longueurDuFormat := posCrochetFermant - posCrochetOuvrant + 1;
               tail  := TPCopy(tail,posCrochetOuvrant+1,longueurDuFormat-2);

               depart := 1;
               fin    := 255;

               posDeuxPoint := Pos('..',tail);
               if (posDeuxPoint >= 2)
                 then depart := StrToInt32(LeftStr(tail,posDeuxPoint - 1));
               if (posDeuxPoint <= LENGTH_OF_STRING(tail) - 2)
                 then fin    := StrToInt32(TPCopy(tail,posDeuxPoint + 2,255));

               insertion := TPCopy(replacement,depart,fin - depart + 1);
             end
           else
             begin
               longueurDuFormat := 0;
               insertion := replacement;
             end;

         resultat := s;
         Delete(resultat,positionSubstring,LENGTH_OF_STRING(pattern)+longueurDuFormat);
         Insert(insertion,resultat,positionSubstring);
         ReplaceVariable := resultat;
       end
     else
       ReplaceVariable := s;
end;

// ReplaceParameters() replace the occurrences of ^0, ^1, ^2, ^3 in s by p0, p1, p2, p3.
function ReplaceParameters(s, p0, p1, p2, p3 : String255) : String255;
begin
  s := ReplaceStringAll(s, '^0', p0);
  s := ReplaceStringAll(s, '^1', p1);
  s := ReplaceStringAll(s, '^2', p2);
  s := ReplaceStringAll(s, '^3', p3);
  Result := s;
end;


// StripDiacritics() : remove accents and diacritics from a string.
// This is the version for AnsiString.
function StripDiacritics(const source : AnsiString) : AnsiString;
var
  K, L : TBytes;
  theUnicodeString : UnicodeString;
  c : char;
  i, len : SInt64;
  res : AnsiString;
begin
  res := '';

  theUnicodeString := UTF8Decode(source);
  for i := 1 to length(theUnicodeString) do
    begin
       K := TEncoding.Unicode.GetBytes(theUnicodeString[i]);
       L := TEncoding.Convert(TEncoding.Unicode, TEncoding.ASCII, K);
       len := length(L);
       if (len = 2) or (len = 3)
         then
           res := res + char(L[1])
         else
           begin
             c := char(L[0]);
             if c <> '?'
                then res := res + c
                else res := res + AnsiString(theUnicodeString[i]);
           end;

       // writeln(i, '   ', theUnicodeString[i], '  ',length(K), '  ', length(L) , '  ', c , '   ', result);
    end;

  Result := res;
end;


// StripDiacritics() : remove accents and diacritics from a string.
// This is the version for String255.
function StripDiacritics(const source : String255) : String255;
var s : AnsiString;
begin
  s := source;
  Result := StripDiacritics(s);
end;


// StripHTMLAccents() : remove some HTML entities from a string
procedure StripHTMLAccents(var s : String255);
var changed : boolean;
begin
  //writeln(s);
  while (Pos('&', s ) > 0) and (Pos( ';', s ) > 0) do
    begin
      //writeln(s);

      changed := false;

      if Pos('&nbsp;',   s) > 0 then begin s := ReplaceStringOnce(s, '&nbsp;'   , ' ' ); changed := true; end;

      if Pos('&aelig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&aelig;'  , 'ae'); changed := true; end;
      if Pos('&AElig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&AElig;'  , 'AE'); changed := true; end;
      if Pos('&oelig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&oelig;'  , 'oe'); changed := true; end;
      if Pos('&OElig;',  s) > 0 then begin s := ReplaceStringOnce(s, '&OElig;'  , 'OE'); changed := true; end;

      if Pos('&Agrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Agrave;' , 'A' ); changed := true; end;
      if Pos('&Auml;' ,  s) > 0 then begin s := ReplaceStringOnce(s, '&Auml;'   , 'A' ); changed := true; end;
      if Pos('&Acirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Acirc;'  , 'A' ); changed := true; end;
      if Pos('&Aacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Aacute;' , 'A' ); changed := true; end;

      if Pos('&Egrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Egrave;' , 'E' ); changed := true; end;
      if Pos('&Euml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Euml;'   , 'E' ); changed := true; end;
      if Pos('&Ecirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ecirc;'  , 'E' ); changed := true; end;
      if Pos('&Eacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Eacute;' , 'E' ); changed := true; end;

      if Pos('&Icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Icirc;'  , 'I' ); changed := true; end;
      if Pos('&Igrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Igrave;' , 'I' ); changed := true; end;
      if Pos('&Iacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Iacute;' , 'I' ); changed := true; end;
      if Pos('&Iulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Iulm;'   , 'I' ); changed := true; end;

      if Pos('&Ocirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ocirc;'  , 'O' ); changed := true; end;
      if Pos('&Ograve;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ograve;' , 'O' ); changed := true; end;
      if Pos('&Oacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Oacute;' , 'O' ); changed := true; end;
      if Pos('&Oulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Oulm;'   , 'O' ); changed := true; end;

      if Pos('&Ucirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ucirc;'  , 'U' ); changed := true; end;
      if Pos('&Ugrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ugrave;' , 'U' ); changed := true; end;
      if Pos('&Uacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Uacute;' , 'U' ); changed := true; end;
      if Pos('&Uulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Uulm;'   , 'U' ); changed := true; end;

      if Pos('&Ycirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Ycirc;'  , 'Y' ); changed := true; end;
      if Pos('&Ygrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ygrave;' , 'Y' ); changed := true; end;
      if Pos('&Yacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&Yacute;' , 'Y' ); changed := true; end;
      if Pos('&Yulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&Yulm;'   , 'Y' ); changed := true; end;

      if Pos('&Icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&Icirc;'  , 'I' ); changed := true; end;

      if Pos('&Ntilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ntilde;' , 'N' ); changed := true; end;
      if Pos('&ntilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&ntilde;' , 'n' ); changed := true; end;
      if Pos('&Atilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Atilde;' , 'A' ); changed := true; end;
      if Pos('&atilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&atilde;' , 'a' ); changed := true; end;
      if Pos('&Etilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Etilde;' , 'E' ); changed := true; end;
      if Pos('&etilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&etilde;' , 'e' ); changed := true; end;
      if Pos('&Itilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Itilde;' , 'I' ); changed := true; end;
      if Pos('&itilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&itilde;' , 'i' ); changed := true; end;
      if Pos('&Otilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Otilde;' , 'O' ); changed := true; end;
      if Pos('&otilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&otilde;' , 'o' ); changed := true; end;
      if Pos('&Utilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Utilde;' , 'U' ); changed := true; end;
      if Pos('&utilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&utilde;' , 'u' ); changed := true; end;
      if Pos('&Ytilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ytilde;' , 'Y' ); changed := true; end;
      if Pos('&ytilde;', s) > 0 then begin s := ReplaceStringOnce(s, '&ytilde;' , 'y' ); changed := true; end;

      if Pos('&copy;',   s) > 0 then begin s := ReplaceStringOnce(s, '&copy;'   , ''  ); changed := true; end;
      if Pos('&reg;',    s) > 0 then begin s := ReplaceStringOnce(s, '&reg;'    , ''  ); changed := true; end;

      if Pos('&agrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&agrave;' , 'a' ); changed := true; end;
      if Pos('&aacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&aacute;' , 'a' ); changed := true; end;
      if Pos('&acirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&acirc;'  , 'a' ); changed := true; end;
      if Pos('&auml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&auml;'   , 'a' ); changed := true; end;

      if Pos('&egrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&egrave;' , 'e' ); changed := true; end;
      if Pos('&eacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&eacute;' , 'e' ); changed := true; end;
      if Pos('&ecirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ecirc;'  , 'e' ); changed := true; end;
      if Pos('&euml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&euml;'   , 'e' ); changed := true; end;

      if Pos('&iuml;',   s) > 0 then begin s := ReplaceStringOnce(s, '&iuml;'   , 'i' ); changed := true; end;
      if Pos('&icirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&icirc;'  , 'i' ); changed := true; end;
      if Pos('&igrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&igrave;' , 'i' ); changed := true; end;
      if Pos('&iacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&iacute;' , 'i' ); changed := true; end;

      if Pos('&ocirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ocirc;'  , 'o' ); changed := true; end;
      if Pos('&ograve;', s) > 0 then begin s := ReplaceStringOnce(s, '&ograve;' , 'o' ); changed := true; end;
      if Pos('&oacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&oacute;' , 'o' ); changed := true; end;
      if Pos('&oulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&oulm;'   , 'o' ); changed := true; end;

      if Pos('&ugrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&ugrave;' , 'u' ); changed := true; end;
      if Pos('&uacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&uacute;' , 'u' ); changed := true; end;
      if Pos('&uuml;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&uuml;'   , 'u' ); changed := true; end;
      if Pos('&ucirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ucirc;'  , 'u' ); changed := true; end;

      if Pos('&ycirc;',  s) > 0 then begin s := ReplaceStringOnce(s, '&ycirc;'  , 'y' ); changed := true; end;
      if Pos('&ygrave;', s) > 0 then begin s := ReplaceStringOnce(s, '&ygrave;' , 'y' ); changed := true; end;
      if Pos('&yacute;', s) > 0 then begin s := ReplaceStringOnce(s, '&yacute;' , 'y' ); changed := true; end;
      if Pos('&yulm;',   s) > 0 then begin s := ReplaceStringOnce(s, '&yulm;'   , 'y' ); changed := true; end;

      if Pos('&ccedil;', s) > 0 then begin s := ReplaceStringOnce(s, '&ccedil;' , 'c' ); changed := true; end;
      if Pos('&Ccedil;', s) > 0 then begin s := ReplaceStringOnce(s, '&Ccedil;' , 'C' ); changed := true; end;
      if Pos('&szlig;' , s) > 0 then begin s := ReplaceStringOnce(s, '&szlig;'  , 'ss'); changed := true; end;

      if Pos('&Oslash;', s) > 0 then begin s := ReplaceStringOnce(s, '&Oslash;' , 'O' ); changed := true; end;
      if Pos('&oslash;', s) > 0 then begin s := ReplaceStringOnce(s, '&oslash;' , 'o' ); changed := true; end;

      if Pos('&Aring;' , s) > 0 then begin s := ReplaceStringOnce(s, '&Aring;'  , 'A' ); changed := true; end;
      if Pos('&aring;' , s) > 0 then begin s := ReplaceStringOnce(s, '&aring;'  , 'a' ); changed := true; end;

      if Pos('&#321;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&#321;'   , 'L' ); changed := true; end;  { for Polish }
      if Pos('&#322;'  , s) > 0 then begin s := ReplaceStringOnce(s, '&#322;'   , 'l' ); changed := true; end;  { for Polish }

      //writeln(s);

      if not(changed) then exit;
    end;
end;


// LowerCase() : lower case version of s, with flag to keep accents or not
function LowerCase(const s : String255; keepAccents : boolean) : String255;
begin
  if keepAccents
    then Result := sysutils.LowerCase(s)
    else Result := sysutils.LowerCase(StripDiacritics(s));
end;


// UpperCase() : lower case version of s, with flag to keep accents or not
function UpperCase(const s : String255; keepAccents : boolean) : String255;
begin
  if keepAccents
    then Result := sysutils.UpperCase(s)
    else Result := sysutils.UpperCase(StripDiacritics(s));
end;


// LowerCase() returns the lowercase version of a alphabetic character.
// Note : use  sysutils.LowerCase() to transform strings.
function LowerCase(ch : char ) : char;
begin
   if ('A' <= ch) and (ch <= 'Z') then ch := chr(ord(ch) + $20);
   result := ch;
end;


// UpperCase() returns the uppercase version of a alphabetic character.
// Note : use  sysutils.UpperCase() to transform strings.
function UpperCase(ch : char) : char;
begin
   if ('a' <= ch) and (ch <= 'z') then ch := chr(ord(ch) - $20);
   result := ch;
end;


// MirrorString(s) calculate the reversed string of s
function MirrorString(const s : String255) : String255;
var i,longueur : SInt32;
    s1 : String255;
begin
  s1 := '';
  longueur := LENGTH_OF_STRING(s);
  for i := longueur downto 1 do s1 := s1 + s[i];
  MirrorString := s1;
end;


// KeepPrefix(s, n) transforms the string s to only keep the first n characters
procedure KeepPrefix (var s : String255; len : SInt32);
begin
	s := TPCopy(s, 1, len);
end;


// KeepSuffix(s, n) transforms the string s to only keep the last n characters
procedure KeepSuffix(var s : String255; len : SInt32);
var p : SInt32;
begin
	p := LENGTH_OF_STRING(s) - len;
	if p < 1 then p := 1;
	s := TPCopy(s, p, 255);
end;


// Split() splits the string s at the character sub
function Split(s : String255; sub : char; var left, right : String255) : boolean;
var p : SInt16;
begin
	p := Pos(sub, s);
	if p > 0
	  then
	    begin
		  left := TPCopy(s, 1, p - 1);
		  right := TPCopy(s, p + 1, 255);
	    end
	  else
	    begin
	      left := s;
	      right := '';
	    end;
	Result := p > 0;
end;


// Split() splits the string s at substring sub
function Split(s : String255; const sub : String255; var left, right : String255) : boolean;
var p : SInt16;
begin
	p := Pos(sub, s);
	if p > 0 then
	  begin
		left := TPCopy(s, 1, p - 1);
		right := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
	  end
	else
	  begin
	    left := s;
	    right := '';
	  end;
	Result := p > 0;
end;


// Split() splits the string s at character sub, scanning from the end of the string
function SplitRight(s : String255; sub : char; var left, right : String255) : boolean;
var p : SInt16;
begin
	p := PosRight(sub, s);
	if p > 0 then
	  begin
		left := TPCopy(s, 1, p - 1);
		right := TPCopy(s, p + 1, 255);
	  end
	else
	  begin
	    left := '';
	    right := s;
	  end;
	Result := p > 0;
end;


// Split() splits the string s at substring sub, scanning from the end of the string
function SplitRight(s : String255; const sub : String255; var left, right : String255) : boolean;
var p : SInt16;
begin
	p := PosRight(sub, s);
	if p > 0 then
	  begin
		left := TPCopy(s, 1, p - 1);
		right := TPCopy(s, p + LENGTH_OF_STRING(sub), 255);
	  end
	else
	  begin
	    left := '';
	    right := s;
	  end;
	Result := p > 0;
end;


// IsDigit() tests if the given character is a digit
function IsDigit(ch : char) : boolean;
begin
	IsDigit := ('0' <= ch) and (ch <= '9');
end;


// IsLower() tests if the given character is a lowercase letter
function IsLower(ch : char) : boolean;
begin
	IsLower := ('a' <= ch) and (ch <= 'z');
end;


// IsLower() tests if the given character is a uppercase letter
function IsUpper(ch : char) : boolean;
begin
	IsUpper := ('A' <= ch) and (ch <= 'Z');
end;


// IsAlpha() tests if the given character is a letter in the alphabet
function IsAlpha(ch : char) : boolean;
begin
	IsAlpha := (('a' <= ch) and (ch <= 'z')) or (('A' <= ch) and (ch <= 'Z'));
end;


// NoCaseEquals() : equality for strings but without upper/lower sensitivity
function NoCaseEquals( s1, s2 : String255 ) : boolean;
begin
    NoCaseEquals := (sysutils.UpperCase(s1) = sysutils.UpperCase(s2));
end;


// NoCaseEquals() : like Pos() but without upper/lower sensitivity
function NoCasePos(s1, s2 : String255) : SInt16;
begin
    NoCasePos := Pos(sysutils.UpperCase(s1), sysutils.UpperCase(s2))
end;


// PosRight() returns the position of the last occurence of sub in s
function PosRight(sub : char; const s : String255) : SInt16;
var p : SInt16;
begin
    p := LENGTH_OF_STRING(s);
	while p > 0 do
	  begin
		if s[p] = sub then break;
		Dec(p);
	  end;
	Result := p;
end;


// PosRight() returns the position of the last occurence of sub in s
function PosRight(const sub, s : String255) : SInt16;
var p, q : SInt16;
begin
	p := Pos(sub, s);
	if p > 0 then
	  begin
		q := LENGTH_OF_STRING(s) - LENGTH_OF_STRING(sub) + 1;
		while q > p do
		  begin
			if TPCopy(s, q, LENGTH_OF_STRING(sub)) = sub
			    then p := q
				else q := q - 1;
		  end;
	  end;
	Result := p;
end;




// Parse() parses the string s and split s between lexem and tail when it finds
// the first delimiter in s. The delimiter characters are by default space and
// tab, but can be changed with the function  SetParserDelimiters() below.
// 
// Examples :
//    Parse('I love Sarah'     , a, b)   ->   a = 'I'          b = 'love Sarah'
//    Parse('  I    love Sarah', a, b)   ->   a = 'I'          b = 'love Sarah'
//    Parse('IloveSarah'       , a, b)   ->   a = 'IloveSarah' b = ''
//    Parse('  IloveSarah'     , a, b)   ->   a = 'IloveSarah' b = ''
//    Parse('IloveSarah  '     , a, b)   ->   a = 'IloveSarah' b = ''

procedure Parse(s : String255; var lexem, tail : String255);
var n,len : SInt16;
begin
  lexem := '';
  tail := '';
  len := LENGTH_OF_STRING(s);
  if len > 0 then
    begin
      n := 1;
      while (n <= len) and (parser_delimiters_as_booleans[ord(s[n])]) do n := n + 1;  {on saute les espaces en tete de s}
      if (n <= len) then
        begin
          if protect_parser_with_quotes and (s[n] = '"')
            then
              begin
                n := n + 1;
                while (n <= len) and (s[n] <> '"') do   {on va jusqu'au prochain quote}
                  begin
                    lexem := Concat(lexem,s[n]);
                    n := n + 1;
                  end;
                if (s[n] = '"') and (n <= len) then n := n + 1; {on saute le quote fermant}
              end
            else
              while (n <= len) and (not(parser_delimiters_as_booleans[ord(s[n])])) do {on va jusqu'au prochain espace}
                begin
                  lexem := Concat(lexem,s[n]);
                  n := n + 1;
                end;
          while (n <= len) and (parser_delimiters_as_booleans[ord(s[n])]) do n := n + 1; {on saute les espaces en tete du tail}
          if (n <= len) then tail := TPCopy(s,n,len - n + 1);
        end;
    end;
end;


// Parse2() is like Parse(), but find two lexems
procedure Parse2(s : String255; var s1, s2, tail : String255);
begin
  Parse(s,s1,tail);
  Parse(tail,s2,tail);
end;


// Parse3() is like Parse(), but find three lexems
procedure Parse3(s : String255; var s1, s2, s3, tail : String255);
begin
  Parse(s,s1,tail);
  Parse(tail,s2,tail);
  Parse(tail,s3,tail);
end;


// Parse4() is like Parse(), but find four lexems
procedure Parse4(s : String255; var s1, s2, s3, s4, tail : String255);
begin
  Parse(s,s1,tail);
  Parse(tail,s2,tail);
  Parse(tail,s3,tail);
  Parse(tail,s4,tail);
end;


// Parse5() is like Parse(), but find five lexems
procedure Parse5(s : String255; var s1, s2, s3, s4, s5, tail : String255);
begin
  Parse(s,s1,tail);
  Parse(tail,s2,tail);
  Parse(tail,s3,tail);
  Parse(tail,s4,tail);
  Parse(tail,s5,tail);
end;


// Parse6() is like Parse(), but find six lexems
procedure Parse6(s : String255; var s1, s2, s3, s4, s5, s6, tail : String255);
begin
  Parse(s,s1,tail);
  Parse(tail,s2,tail);
  Parse(tail,s3,tail);
  Parse(tail,s4,tail);
  Parse(tail,s5,tail);
  Parse(tail,s6,tail);
end;


// ParseWithQuoteProtection() is like Parse(), but does not count the 
// delimiters characters as delimiters if they are inside a string
// protected by double quotes (").
// Examples :
//    ParseWithQuoteProtection('"I love" Sarah' , a, b)   ->   a = 'I love'  b = 'Sarah'
//    ParseWithQuoteProtection('"I love"Sarah'  , a, b)   ->   a = 'I love'  b = 'Sarah'

procedure ParseWithQuoteProtection(s : String255; var lexem, tail : String255);
var old : boolean;
begin
  old := GetParserProtectionWithQuotes();
  SetParserProtectionWithQuotes(true);
  Parse(s, lexem, tail);
  SetParserProtectionWithQuotes(old);
end;


// ParseBuffer() is like Parse(), but for a buffer of characters in memory.
//
// The function returns the first lexem found (or '' if no lexem was found).
// The scan starts at index 'from' in the buffer (zero based), and the
// lastRead parameter is set on output to the index of the last character
// examined in the buffer during the scan.

function ParseBuffer(buffer : Ptr; bufferLength, from : SInt32; var lastRead : SInt32) : String255;
var n : SInt32;
    text : PackedArrayOfCharPtr;
begin

  result := '';
  lastRead := from - 1;

  if (buffer <> NIL) and (bufferLength > 0) then
    begin
	  text := PackedArrayOfCharPtr(buffer);

	  if (from < 0) then from := 0;
	  if (from > bufferLength - 1) then from := bufferLength - 1;

	  n := from;
		
      while (n < bufferLength) and (parser_delimiters_as_booleans[ord(text^[n])]) do n := n + 1;  {on saute les espaces en lexem }
      if (n < bufferLength) then
        begin
          if protect_parser_with_quotes and (text^[n] = '"')
            then
              begin
                n := n + 1;
                while (n < bufferLength) and (text^[n] <> '"') do   {on va jusqu'au prochain quote}
                  begin
                    result := Concat(result, text^[n]);
                    n := n + 1;
                  end;
                if (text^[n] = '"') and (n < bufferLength) then n := n + 1; {on saute le quote fermant}
              end
            else
              while (n < bufferLength) and (not(parser_delimiters_as_booleans[ord(text^[n])])) do {on va jusqu'au prochain espace}
                begin
                  result := Concat(result,text^[n]);
                  n := n + 1;
                end;
        end;
						
		  lastRead := (n - 1);
	  end;
	
	ParseBuffer := result;
end;


// SetParserDelimiters() : change the delimiters characters used by the parser
procedure SetParserDelimiters(parsingCaracters : SetOfChar);
var i : SInt32;
begin
  parser_delimiters := parsingCaracters;
  for i := 0 to 255 do
    parser_delimiters_as_booleans[i] := (chr(i) in parser_delimiters);
end;


// GetParserDelimiters() : get the current delimiters characters used by the parser
function GetParserDelimiters : SetOfChar;
begin
  GetParserDelimiters := parser_delimiters;
end;


// SetParserProtectionWithQuotes() : set the flag telling the parser to protect with quotes
procedure SetParserProtectionWithQuotes(flag : boolean);
begin
  protect_parser_with_quotes := flag;
end;


// GetParserProtectionWithQuotes() : get the value of that flag
function GetParserProtectionWithQuotes : boolean;
begin
  GetParserProtectionWithQuotes := protect_parser_with_quotes;
end;


// PseudoHammingDistance() returns the Hamming distance between s1 and s2
function PseudoHammingDistance(const s1, s2 : String255) : SInt32;
var  count1, count2 : array[0..255] of SInt32;
     k, dist : SInt32;
begin
  for k := 0 to 255 do
    begin
      count1[k] := 0;
      count2[k] := 0;
    end;

  for k := 1 to LENGTH_OF_STRING(s1) do inc(count1[ord(s1[k])]);
  for k := 1 to LENGTH_OF_STRING(s2) do inc(count2[ord(s2[k])]);

  dist := 0;
  for k := 0 to 255 do
    dist := dist + abs(count1[k] - count2[k]);

  PseudoHammingDistance := dist;
end;


// Hexa(n) returns a string representing the number n in hexadecimal.
// The resulting string starts with a dollar character '$'.
function Hexa(num : UInt64) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : SInt64) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : UInt32) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : SInt32) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : UInt16) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : SInt16) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : UInt8) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;

function Hexa(num : SInt8) : String255;
begin
  Result := '$' + HexaWithoutDollar(num);
end;


// HexaWithoutDollar(n) returns a string representing the number n in
// hexadecimal, without the initial dollar character '$'.
function HexaWithoutDollar(num : UInt64) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : UInt64;
    s : String255;
begin
  s := '';
  for i := 1 to 16 do
    begin
      v := BAND(BSR(num,(16-i)*4),UInt64($0F));
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : SInt64) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : SInt64;
    s : String255;
begin
  s := '';
  for i := 1 to 16 do
    begin
      v := BAND(BSR(UInt64(num),(16-i)*4),UInt64($0F));
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : UInt32) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : UInt32;
    s : String255;
begin
  s := '';
  for i := 1 to 8 do
    begin
      v := BAND(BSR(num,(8-i)*4),$0F);
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : SInt32) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : SInt32;
    s : String255;
begin
  s := '';
  for i := 1 to 8 do
    begin
      v := BAND(BSR(UInt32(num),(8-i)*4),UInt32($0F));
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : UInt16) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : UInt16;
    s : String255;
begin
  s := '';
  for i := 1 to 4 do
    begin
      v := BAND(BSR(num,(4-i)*4),$0F);
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : SInt16) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : SInt16;
    s : String255;
begin
  s := '';
  for i := 1 to 4 do
    begin
      v := BAND(BSR(UInt16(num),(4-i)*4),UInt16($0F));
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : UInt8) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : UInt8;
    s : String255;
begin
  s := '';
  for i := 1 to 2 do
    begin
      v := BAND(BSR(num,(2-i)*4),$0F);
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;


function HexaWithoutDollar(num : SInt8) : String255;
const digits = '0123456789abcdef';
var i : integer;
    v : SInt8;
    s : String255;
begin
  s := '';
  for i := 1 to 2 do
    begin
      v := BAND(BSR(UInt8(num),(2-i)*4),UInt8($0F));
      s := Concat(s, digits[v+1]);
    end;
  Result := s;
end;




// HexToInt(s) converts the hexadecimal string s to an unsigned 64 bit integer
function HexToInt(const s : String255) : UInt64;
var i, numDigits, v : UInt64;
begin
  result := 0;
  numDigits := 0;
  i := LENGTH_OF_STRING(s);
  while (i > 0) do
     begin
        case s[i] of
            'A'..'Z': v := ord(s[i]) - 55;
		    'a'..'z': v := ord(s[i]) - 87;
		    '0'..'9': v := ord(s[i]) - 48;
	    end;
		
		if (numDigits <= 15) then
		  result := result + BSL(v, 4 * numDigits);
		
		inc(numDigits);
		dec(i);
    end;
  HexToInt := result;
end;


// StrToInt32() : convert from string to 32 bits integer
procedure StrToInt32(const s : String255; var value : SInt32);
begin
  Try
    value := StrToInt(Trim(s));
  except
    On E : EConvertError do
      value := -1;
  end;
end;


// StrToInt32() : convert from string to 32 bits integer
function StrToInt32(const s : String255) : SInt32;
var n : SInt32;
begin
  StrToInt32(s, n);
  Result := n;
end;


// IntToStrWithPadding(n, digits, c) convert n to a string, padding
// on the left with the character c if necessary.
function IntToStrWithPadding(n, digits : SInt32; formatChar : char) : String255;
var i : SInt32;
	s : String255;
begin
	s := IntToStr(n);
	for i := 1 to (digits - LENGTH_OF_STRING(s)) do
	  s := formatChar + s;
	IntToStrWithPadding := s;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   InitLongString() permet d'initialiser d'une chaine à la chaine vide.      *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitLongString(var ligne : LongString);
begin
  with ligne do
    begin
      debutLigne := '';
      finLigne   := '';
      complete   := false;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   MakeLongString() : fabrication d'une LongString a partir d'une chaine     *
 *   standard Pascal.                                                          *
 *                                                                             *
 *******************************************************************************
 *)
function MakeLongString(const s : String255) : LongString;
begin
  with result do
    begin
      debutLigne := s;
      finLigne   := '';
      complete   := false;
    end;
  MakeLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   CopyLongString() : copie d'une chaine. Pour une implémentation simple     *
 *   comme actuellement, il est plus elegant d'utiliser une simple affectation *
 *   dest := source                                                            *
 *                                                                             *
 *******************************************************************************
 *)
function CopyLongString(const ligne : LongString) : LongString;
begin
  with result do
    begin
      debutLigne := ligne.debutLigne;
      finLigne   := ligne.finLigne;
      complete   := ligne.complete;
    end;
  CopyLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SameLongString() : test d'égalite de deux chaines.                        *
 *                                                                             *
 *******************************************************************************
 *)
function SameLongString(const ligne1, ligne2 : LongString) : boolean;
begin
  SameLongString := (LENGTH_OF_STRING(ligne1.debutLigne) = LENGTH_OF_STRING(ligne2.debutLigne)) and
                    (LENGTH_OF_STRING(ligne1.finLigne)   = LENGTH_OF_STRING(ligne2.finLigne)) and
                    (ligne1.debutLigne = ligne2.debutLigne) and
                    (ligne1.finLigne   = ligne2.finLigne);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LengthOfLongString()  renvoie la longueur de la chaine.                   *
 *                                                                             *
 *******************************************************************************
 *)
function LengthOfLongString(const ligne : LongString) : SInt32;
begin
  LengthOfLongString := LENGTH_OF_STRING(ligne.debutLigne) + LENGTH_OF_STRING(ligne.finLigne);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringIsEmpty() permet de tester si une chaine est vide.              *
 *                                                                             *
 *******************************************************************************
 *)
function LongStringIsEmpty(const ligne : LongString) : boolean;
begin
  LongStringIsEmpty := (LengthOfLongString(ligne) <= 0);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   FindStringInLongString() permet de trouver une chaine Pascal dans une     *
 *   LongString. Cette fonction renvoie la position de la chaine trouvee, ou   *
 *   zero si la chaine cherchee n'apparait pas dans la LongString.             *
 *                                                                             *
 *******************************************************************************
 *)
function FindStringInLongString(const s : String255; const ligne : LongString) : SInt32;
var trouve,dec2,len2 : SInt32;
    aux : String255;
begin

  trouve := Pos(s, ligne.debutLigne);

  if (trouve > 0) or (ligne.finLigne = '')
    then
      begin
        FindStringInLongString := trouve;
        exit;
      end
    else
      begin
        len2 := LENGTH_OF_STRING(ligne.finLigne);
        dec2 := LENGTH_OF_STRING(ligne.debutLigne) - len2;

        if (dec2 <= 0) then
          WritelnDansRapport('WARNING : LENGTH_OF_STRING(finLigne) >= LENGTH_OF_STRING(debutLigne) dans FindStringInLongString !');

        aux := RightStr(ligne.debutLigne, dec2) + ligne.finLigne;

        trouve := Pos(s, aux);
        if (trouve > 0)
          then FindStringInLongString := len2 + trouve
          else FindStringInLongString := trouve;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringBeginsWith() permet de tester (de maniere rapide et efficace)   *
 *   si une LongString commence par une chaine Pascal donnee.                  *
 *                                                                             *
 *******************************************************************************
 *)
function LongStringBeginsWith(const s : String255; const ligne : LongString) : boolean;
begin
  if (s = '') or (ligne.debutLigne = '') or (s[1] <> ligne.debutLigne[1]) then
    begin
      LongStringBeginsWith := false;
      exit;
    end;

  LongStringBeginsWith := (Pos(s, ligne.debutLigne) = 1);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   NormaliserLongString() : dans l'implementation actuelle des LongString    *
 *   comme couple de chaines Pascal de 255 caracteres, il faut pour que les    *
 *   algos marchent que la premiere chaine soit pleine (255 caracteres) avant  *
 *   que l'on commence à remplir la seconde. Cette fonction assure que c'est   *
 *   le cas, en deplacant si necessaire des caracteres de la seconde chaine    *
 *   vers la premiere.                                                         *
 *                                                                             *
 *******************************************************************************
 *)
procedure NormaliserLongString(var ligne : LongString);
var len1, len2, nbOctetsDeplaces : SInt32;
begin
  with ligne do
    begin

      len1 := LENGTH_OF_STRING(debutLigne);
      len2 := LENGTH_OF_STRING(finLigne);

      if (len1 < 255) and (len2 > 0) then
        begin
          nbOctetsDeplaces := Min(len2, 255 - len1);

          debutLigne := debutLigne + LeftStr(finLigne, nbOctetsDeplaces);
          finLigne   := RightStr(finLigne, len2 - nbOctetsDeplaces);
        end;


      if (LengthOfLongString(ligne) <> len1 + len2) or
         ((LENGTH_OF_STRING(ligne.debutLigne) < 255) and (LENGTH_OF_STRING(ligne.finLigne) > 0)) then
        begin
          WritelnDansRapport('ASSERT : LongString mal normalisee dans NormaliserLongString !');
          WritelnLongStringDansRapport(ligne);
          exit;
        end;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendToLongString() : concatenation d'une LongString avec une string     *
 *   Pascal.                                                                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToLongString(var ligne : LongString; const s : String255);
var i, len, len2 : SInt32;
begin

  with ligne do
    begin
      if (LENGTH_OF_STRING(debutLigne) < 255) and (LENGTH_OF_STRING(finLigne) > 0)
        then NormaliserLongString(ligne);


      len := LENGTH_OF_STRING(debutLigne);

      if (len = 0)
        then
          debutLigne := s
        else
          begin
            if (len < 255)
              then
                begin
                  len2 := LENGTH_OF_STRING(s);

                  if (len + len2 <= 255)
                    then
                      begin
                        debutLigne := debutLigne + s;
                      end
                    else
                      begin
                        i := 1;
                        while (i <= len2) and ((len + i) <= 255) do
                          begin
                            debutLigne := debutLigne + s[i];
                            i := i + 1;
                          end;
                        while (i <= len2) do
                          begin
                            finLigne := finLigne + s[i];
                            i := i + 1;
                          end;
                      end;
                end
              else
                finLigne := finLigne + s;
         end;

   end; {with}
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendCharToLongString() : ajout d'un caractere à une LongString.         *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendCharToLongString(var ligne : LongString; c : char);
var len : SInt32;
begin

  if (LENGTH_OF_STRING(ligne.debutLigne) < 255) and (LENGTH_OF_STRING(ligne.finLigne) > 0)
    then NormaliserLongString(ligne);

  len := LENGTH_OF_STRING(ligne.debutLigne);
  if len < 255
    then ligne.debutLigne := ligne.debutLigne + c
    else ligne.finLigne   := ligne.finLigne + c;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AppendToLeftOfLongString() : concatenation d'une chaine Pascal avec une   *
 *   LongString. La difference de cette fonction avec AppendToLongString est   *
 *   qu'ici la chaine Pascal est ajoutee a gauche de la LongString.            *
 *                                                                             *
 *******************************************************************************
 *)
procedure AppendToLeftOfLongString(const s : String255; var ligne : LongString);
var aux : LongString;
begin
  if (LENGTH_OF_STRING(s) > 0) then
    with ligne do
      begin
        aux := MakeLongString(s);
      	if (LENGTH_OF_STRING(debutLigne) > 0) then AppendToLongString(aux, debutLigne);
      	if (LENGTH_OF_STRING(finLigne)   > 0) then AppendToLongString(aux, finLigne);
      	ligne := aux;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LongStringToBuffer() permet de transformer une LongString en buffer de    *
 *   caracteres, en placant le premier caractere de la chaine dans buffer[0],  *
 *   etc. La fonction n'alloue pas le buffer : c'est l'appelant qui doit four- *
 *   nir un buffer assez grand. La fonction renvoie aussi, dans le parametre   *
 *   nbOctets, le nombre de caracteres utilises dans le buffer (la longueur de *
 *   la LongString) : les caracteres utiles dans le buffer après la fonction   *
 *   sont donc dans  buffer[0]...buffer[nbOctets - 1] .                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure LongStringToBuffer(var ligne : LongString; buffer : PackedArrayOfCharPtr; var nbOctets : SInt32);
var k : SInt32;
begin
  nbOctets := 0;

  with ligne do
    begin
      for k := 1 to LENGTH_OF_STRING(debutLigne) do
        begin
          buffer^[nbOctets] := debutLigne[k];
          inc(nbOctets);
        end;

      for k := 1 to LENGTH_OF_STRING(finLigne) do
        begin
          buffer^[nbOctets] := finLigne[k];
          inc(nbOctets);
        end;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   BufferToLongString() transforme un buffer de caracteres en LongString.    *
 *                                                                             *
 *******************************************************************************
 *)
procedure BufferToLongString(buffer : PackedArrayOfCharPtr; nbOctets : SInt32; var ligne : LongString);
const kTailleMaxOfLongString = 510;
var k, len1, len2 : SInt32;
begin

  with ligne do
    begin

      len1 := 0;
      len2 := 0;

      if (nbOctets > kTailleMaxOfLongString)
        then
          begin
            WritelnDansRapport('ASSERT : (nbOctets > kTailleMaxOfLongString) dans BufferToLongString !!');
          end
        else
          begin
            len1 := Min(nbOctets, 255);
            len2 := nbOctets - len1;

            for k := 1 to len1 do
              debutLigne[k] := buffer^[k - 1];

            for k := 1 to len2 do
              finLigne[k] := buffer^[len1 + k - 1]

          end;

      SET_LENGTH_OF_STRING(debutLigne , len1);
      SET_LENGTH_OF_STRING(finLigne   , len2);

    end;

end;


(*
 *******************************************************************************
 *                                                                             *
 *   LeftOfLongString() permet de tronquer une LongString.                     *
 *                                                                             *
 *******************************************************************************
 *)
function LeftOfLongString(const ligne : LongString; len : SInt32) : LongString;
var aux : SInt32;
begin
  result.debutLigne := '';
  result.finLigne   := '';
  result.complete   := false;

  aux := LENGTH_OF_STRING(ligne.debutLigne);

  if (len <= aux)
    then result.debutLigne := TPCopy(ligne.debutLigne,1,len)
    else
       begin
         result.debutLigne := ligne.debutLigne;
         result.finLigne   := TPCopy(ligne.finLigne,1,len - aux);
       end;

  LeftOfLongString := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   WriteLongStringDansRapport() ecrit une chaine dans le rapport sans        *
 *   ajouter de retour chariot à la fin.                                       *
 *                                                                             *
 *******************************************************************************
 *)
procedure WriteLongStringDansRapport(const ligne : LongString);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(ligne.finLigne);
  if (longueur > 0)
    then
      begin
        WriteDansRapport(ligne.debutLigne);
        WriteDansRapport(ligne.finLigne);
      end
    else
      begin
        WriteDansRapport(ligne.debutLigne);
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   WritelnLongStringDansRapport() ecrit une chaine dans le rapport en        *
 *   ajoutant un retour chariot a la fin.                                      *
 *                                                                             *
 *******************************************************************************
 *)
procedure WritelnLongStringDansRapport(const ligne : LongString);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(ligne.finLigne);
  if (longueur > 0)
    then
      begin
        WriteDansRapport(ligne.debutLigne);
        WriteDansRapport(ligne.finLigne);
        WritelnDansRapport('');
      end
    else
      begin
        WriteDansRapport(ligne.debutLigne);
        WritelnDansRapport('');
      end;
end;



// A function similar to a macro to be used to warn that a feature is not implemented yet
procedure TODO(s : String255);
begin
   writeln('Warning: ' + s + ' is not implemented');
end;


// testBasicString() : testing various functions of the BasicString unit
procedure testBasicString();
var  s, a, b : string255;
     c : char;
     // i, j : SInt64;
     k : SInt64;
     theSet : SetOFChar;
begin
   c := 'z';
   theSet := ['a', 'b'];

   writeln( c in theSet);

   s := 'hello';

   writeln(s, LENGTH_OF_STRING(s));
   SET_LENGTH_OF_STRING(s, 20);
   writeln(s, LENGTH_OF_STRING(s));

   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   c := 'a';
   s := s + CharToString(c);
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '|';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := ':';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '\';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '&';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '•';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '≥';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '»';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '√';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '≠';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '◊';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '…';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '∑';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '—';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '-';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));


   s := '1234567';
   writeln(copy(s, -1, 2));
   writeln(copy(s, 0, 2));
   writeln(copy(s, 1, 2));
   writeln(copy(s, 4, 2));
   writeln(copy(s, 4, 5));
   writeln(copy(s, 4, 8));

   {
   for i := -10 to 300 do
     for j := -10 to 300 do
       begin
         a := copy(s, i, j);
         b := TPcopy(s, i, j);

         if (a <> b) then
            writeln('copy(s,', i,',', j,') = ', a, '   TPcopy(s,', i,',', j,') = ', b);
       end;
    }

   a := 'Stéphane NICOLET æœ´„”’[å»ÛÁØ]°•“‘{¶«¡Çø}ëÂê®©†Úºîπô€‡Ò∂ƒﬁÌÏÈ¬µÙ‹≈◊ß~∞…÷≠çéèàùÒ∑√∆————–ß';

   b := a;
   writeln('original string              : ', b);
   b := AnsiUpperCase(a);
   writeln('AnsiUpperCase()              : ', b);
   b := StripDiacritics(a);
   writeln('StripDiacritics()            : ', b);
   b := sysutils.UpperCase(StripDiacritics(a));
   writeln('UpperCase(StripDiacritics()) : ', b);

   writeln();
   writeln('Testing Parse()...');
   Parse('I love Sarah'     , a, b); writeln('a=',a,'  b=',b);
   Parse('  I    love Sarah', a, b); writeln('a=',a,'  b=',b);
   Parse('IloveSarah'       , a, b); writeln('a=',a,'  b=',b);
   Parse('  IloveSarah'     , a, b); writeln('a=',a,'  b=',b);
   Parse('IloveSarah '      , a, b); writeln('a=',a,'  b=',b);
   ParseWithQuoteProtection('"I love" Sarah' , a, b) ; writeln('a=',a,'  b=',b);
   ParseWithQuoteProtection('"I love"Sarah' , a, b) ; writeln('a=',a,'  b=',b);
   
   writeln();
   writeln('Testing Split()...');
   Split('Cassio:9.0b401', '', a, b);  writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', ':', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', 'c', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', 'C', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', '0', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', '1', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', 'Cassio', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', '9.0', a, b); writeln('a=',a,'  b=',b);
   Split('Cassio:9.0b401', '401', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', '', a, b);  writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', ':', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', 's', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', 'S', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', '1', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', 'Cassio', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', '9.0', a, b); writeln('a=',a,'  b=',b);
   SplitRight('Stéphane:9.0b401', '401', a, b); writeln('a=',a,'  b=',b);

end;


procedure foo(n : SInt32);
begin
   WritelnDansRapport('');
   WritelnNumDansRapport('foo called with value ', n);
end;


begin
   // Always init the basic string unit
   SetParserProtectionWithQuotes(false);
   SetParserDelimiters([' ',tab]);

   // testBasicString;
end.
























