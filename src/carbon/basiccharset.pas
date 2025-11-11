UNIT basiccharset;


INTERFACE

uses basictypes;


TYPE 
   // Our fancy type for set of chars, useful for utf-8
   SetOfChar = 
      record
         touched : set of char;
         elements : string;
      end;

   // type for set of Ascii chars, ie characters c such that ord(c) <= 127
   setOfAsciiChar = set of char;

// Create a set of char from a string in utf8 encoding
function CreateSetOfChar(s : string) : SetOfChar;

// Find a character in a set of char
function FindInCharSet(const theSet : SetOfChar; var s : string; k : integer) : ShortString;
function FindInCharSet(const theSet : SetOfChar; var s : ShortString; k : integer) : ShortString;
function FindInCharSet(const theSet : SetOfChar; buffer : PackedArrayOfCharPtr; bufferLength, k : integer) : ShortString;



IMPLEMENTATION

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils,
  StrUtils;
  
  
// CreateSetOfChar(s) returns a set with the chars of the string s.
// The string s must be encoded as utf-8.
function CreateSetOfChar(s : string) : SetOfChar;
var 
  len : Integer;
  utf8 : String;
  theUnicodeString : UnicodeString;
  K, L : Tbytes;
  i : SInt64;
  A : SetOfChar;
begin
  A.elements := s;
  A.touched  := [];
      
  // Decompose s as utf-8 characters, and put the first byte
  // of each character in A.touched for fast access later.
  
  theUnicodeString := UTF8Decode(s);
  for i := 1 to length(theUnicodeString) do
    begin
      K := TEncoding.Unicode.GetBytes(theUnicodeString[i]);
      L := TEncoding.Convert(TEncoding.Unicode, TEncoding.UTF8, K);
      len := length(L);
           
      SetLength(utf8, len);
      Move(L[0], utf8[1], len);
      if len > 0 then
        Include(A.touched, char(utf8[1]));
    end;

  CreateSetOfChar := A;  
end;


// FindInCharSet(A, s, k) tests if the utf8 character at position k 
// in the ansistring s is found in the set A. This function is fast 
// if s[k] is an ascii character, and reasonably fast otherwise.
//
// Successful search : returns the character found, encoded in utf-8;
// Unsuccessful search : returns the empty string.

function FindInCharSet(const theSet : SetOfChar; var s : string; k : integer) : ShortString;
var c : char;
    n : UInt8;
begin
  Result := '';
  
  if (k < 1) or (k > length(s))
    then exit;
  
  c := s[k];
  if not(c in theSet.touched)
    then exit;

  n := ord(c);
  if (n <= 127) then
    begin
      Result := c;
      exit;
    end;

  with theSet do
    begin
      if ((n and $E0) = $C0) and (Pos(Copy(s, k, 2), elements) > 0)  // encoded in 2 bytes
        then Result := Copy(s, k, 2);  
      if ((n and $F0) = $E0) and (Pos(Copy(s, k, 3), elements) > 0)  // encoded in 3 bytes
        then Result := Copy(s, k, 3);  
      if ((n and $F8) = $F0) and (Pos(Copy(s, k, 4), elements) > 0)  // encoded in 4 bytes
        then Result := Copy(s, k, 4); 
      if ((n and $FC) = $F8) and (Pos(Copy(s, k, 5), elements) > 0)  // encoded in 5 bytes
        then Result := Copy(s, k, 5);
      if ((n and $FE) = $FC) and (Pos(Copy(s, k, 6), elements) > 0)  // encoded in 6 bytes
        then Result := Copy(s, k, 6);
      if ((n and $FF) = $FE) and (Pos(Copy(s, k, 7), elements) > 0)  // encoded in 7 bytes
        then Result := Copy(s, k, 7);
    end;
end;

// FindInCharSet(). Version for shortstring (aka string255)
function FindInCharSet(const theSet : SetOfChar; var s : ShortString; k : integer) : ShortString;
var ansi : string;
begin
  ansi := s;
  Result := FindInCharSet(theSet, ansi, k);
end;

// FindInCharSet(). Version for PackedArrayOfChar
function FindInCharSet(const theSet : SetOfChar; buffer : PackedArrayOfCharPtr; bufferLength, k : integer) : ShortString;
var ansi : string;
    run : integer;
begin
  if (k < 0) or (k >= bufferLength)
    then 
      Result := ''  
    else
      begin
        ansi := '';
        run := 0;
        while (run < 7) and (k + run < bufferLength)  do
          begin
            ansi := concat(ansi, buffer^[k + run]);
            inc(run);
          end;
        Result := FindInCharSet(theSet, ansi, 1);
      end;
end;

// Testing the unit
procedure TestBasicCharSet;
var theSet : SetOfChar;
    s : String;
    k, len : integer;
    buffer : PackedArrayOfCharPtr;
begin
  Writeln('sizeof(theSet) = ', sizeof(theSet));
  Writeln('');
  Writeln('Testing CharSet...');
  
  theSet := CreateSetOfChar('不Stéphane');
  s := '復不Stéphânes';
  
  Writeln('version for string :');
  for k := 1 to length(s) do
     writeln(k, ' -> ', FindInCharSet(theSet, s, k));

  Writeln('version for buffer :');
  buffer := PackedArrayOfCharPtr(@s[1]);
  len := length(s);
  for k := 0 to len-1 do
     writeln(k, ' -> ', FindInCharSet(theSet, buffer, len, k));
  
end;


BEGIN
  // TestBasicCharSet;
END.

























