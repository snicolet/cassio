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

// function types for strings
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

// Extracting substrings
function TPCopy(source : String255; start, count : SInt32) : String255;
function SplitAt(s : String255; sub : char; var left, right : String255) : boolean;
function SplitAt(s : String255; const sub : String255; var left, right : String255) : boolean;
function SplitRightAt(s : String255; sub : char; var left, right : String255) : boolean;
function SplitRightAt (s : String255; const sub : String255; var left, right : String255) : boolean;

// Replace pattern in string
function ReplaceStringOnce(const s, pattern, replacement : String255) : String255;
function ReplaceStringAll(const s, pattern, replacement : String255) : String255;

// Transforming strings
function StripDiacritics(const source : AnsiString) : AnsiString;
function StripDiacritics(const source : String255) : String255;
procedure StripHTMLAccents(var s : String255);
function LowerCase(const s : String255; keepAccents : boolean) : String255;
function UpperCase(const s : String255; keepAccents : boolean) : String255;
function LowerCase(ch : char) : char;
function UpperCase(ch : char) : char;

// Testing characters
function IsDigit(ch : char) : boolean;
function IsLower(ch : char) : boolean;
function IsUpper(ch : char) : boolean;
function IsAlpha(ch : char) : boolean;
function NoCaseEquals(s1, s2 : String255) : boolean;
function NoCasePos(s1, s2 : String255) : SInt16;
function PosRight(sub : char; const s : String255) : SInt16;
function PosRight(const sub, s : String255) : SInt16;

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


// HexToInt(s) : conversion hexadecimal to unsigned integer
function HexToInt(const s : String255) : UInt64;



implementation

uses basicmath;


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


// SplitAt() splits the string s at the character sub
function SplitAt (s : String255; sub : char; var left, right : String255) : boolean;
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


// SplitAt() splits the string s at substring sub
function SplitAt (s : String255; const sub : String255; var left, right : String255) : boolean;
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


// SplitAt() splits the string s at character sub, scanning from the end of the string
function SplitRightAt(s : String255; sub : char; var left, right : String255) : boolean;
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


// SplitAt() splits the string s at substring sub, scanning from the end of the string
function SplitRightAt (s : String255; const sub : String255; var left, right : String255) : boolean;
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


end;


procedure replaceFooChar(var s : string255 ; c, rep : char);
var k : integer;
begin
   for k := 1 to LENGTH_OF_STRING(s) do
      if s[k] = c then s[k] := rep;
end;

procedure fooAt(s : string255 ; c : char);
begin
   if c <> 'A' then writeln('fooAt');
end;




var s : string255;
    c : char;
begin

    s := 'toto^0^0^0';
    replaceFooChar(s, 't', 'j');
    s := ReplaceStringAll(s, 'o', '•');
    s := ReplaceStringAll(s, '^0^0', 'blah');
    writeln(s);

    //testBasicString;
end.
























