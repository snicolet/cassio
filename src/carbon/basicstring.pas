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
function LENGTH_OF_STRING(s : ansistring) : SInt64;

// Set the length of a string
procedure SET_LENGTH_OF_STRING(var s : String255 ; len : SInt64);
procedure SET_LENGTH_OF_STRING(var s : ansistring ; len : SInt64);

// Extracting substrings
function TPCopy(source : String255; start, count : SInt32) : String255;

// Transforming strings
function StripDiacritics(const source : String255) : String255;


implementation


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

function LENGTH_OF_STRING(s : ansistring) : SInt64;
begin
   LENGTH_OF_STRING := Length(s);
end;


// SET_LENGTH_OF_STRING() : set the length of a string

procedure SET_LENGTH_OF_STRING(var s : String255 ; len : SInt64);
begin
   SetLength(s, len);
end;

procedure SET_LENGTH_OF_STRING(var s : ansistring ; len : SInt64);
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


// StripDiacritics() : remove accents and diacritics from a string

function StripDiacritics(const source : String255) : String255;
var
  K, L : TBytes;
  theAnsiString : ansistring;
  theUnicodeString : UnicodeString;
  c : char;
  i, len : SInt64;
begin
  theAnsiString := source;
  theUnicodeString := UTF8Decode(theAnsiString);
  
  Result := '';
  for i := 1 to length(theUnicodeString) do
    begin      
       K := TEncoding.Unicode.GetBytes(theUnicodeString[i]);
       L := TEncoding.Convert(TEncoding.Unicode, TEncoding.ASCII, K);
       len := length(L);
       if len = 2
         then
           Result := Result + char(L[1])
         else
           begin
             c := char(L[0]);
             if c <> '?'
                then Result := Result + c
                else Result := Result + theUnicodeString[i];
           end;
           
       // writeln(i, '   ', theUnicodeString[i], '  ',length(K), '  ', length(L) , '  ', c , '   ', result);
    end;

end;


// testBasicString() : testing various functions of the BasicString unit


procedure testBasicString();
var  s, a, b : string255;
     c : char;
     i, j, k : SInt64;
begin

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
    
   a := 'Stéphane NICOLET æœÂê®©†Úºîπô€‡Ò∂ƒﬁÌÏÈ¬µÙ‹≈©◊ß~∞…÷≠çéèàùÒ∑√∆———ß';
   writeln('original string              : ', a);
   b := AnsiUpperCase(a);
   writeln('AnsiUpperCase()              : ', b);
   b := StripDiacritics(a);
   writeln('StripDiacritics()            : ', b);
   b := UpperCase(StripDiacritics(a));
   writeln('UpperCase(StripDiacritics()) : ', b);
   
   
end;


begin
   testBasicString;
end.
























