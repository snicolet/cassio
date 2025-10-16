unit basicstring;

interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  SysUtils;
  
  type
     String255 = ShortString;
     str255 = ShortString;

// Copy string from str255 to String255, and reverse
function MyStr255ToString( const s : Str255 ) : String255;
function Str255ToString( const s : Str255 ) : String255;
function StringToStr255( const s : String255 ) : Str255;

// Access the length of a string
function LENGTH_OF_STRING(s : String255)  : Int64;
function LENGTH_OF_STRING(s : ansistring) : Int64;

// Set the length of a string
procedure SET_LENGTH_OF_STRING(var s : String255 ; len : Int64);
procedure SET_LENGTH_OF_STRING(var s : ansistring ; len : Int64);

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


// StringOf() : transforming a char into a string. The advantage of using this 
// function is to catch differences for some characters which are 1 byte long 
// in  GNUPascal and 3 bytes in FreePascal, for instance StringOf('√') and
// StringOf('◊') do not compile.

function StringOf(c : char) : String255;
begin
  StringOf := c;
end;


// Access the length of a string

function LENGTH_OF_STRING(s : String255) : Int64;
begin
   LENGTH_OF_STRING := Length(s);
end;

function LENGTH_OF_STRING(s : ansistring) : Int64;
begin
   LENGTH_OF_STRING := Length(s);
end;


// Set the length of a string

procedure SET_LENGTH_OF_STRING(var s : String255 ; len : Int64);
begin
   SetLength(s, len);
end;

procedure SET_LENGTH_OF_STRING(var s : ansistring ; len : Int64);
begin
   SetLength(s, len);
end;


// testBasicString() : testing various functions of the BasiString unit

procedure testBasicString();
var  s : string255;
     c : char;
     k : int64;
begin
   s := 'hello';
   
   writeln(s, LENGTH_OF_STRING(s));
   SET_LENGTH_OF_STRING(s, 20);
   writeln(s, LENGTH_OF_STRING(s));
   
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));
   
   c := 'a';
   s := s + StringOf(c);
   
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));

   s := '√';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));
   
   s := '◊';
   writeln(s, LENGTH_OF_STRING(s));
   for k := 1 to LENGTH_OF_STRING(s) do
      writeln(k, '  =>  ', s[k], ' , ', ord(s[k]));
end;


begin
   testBasicString
end.
























