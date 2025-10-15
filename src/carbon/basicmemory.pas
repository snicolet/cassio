unit basicmemory;

interface

uses 
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
   BasicTypes;


{Allocation de Pointer et de Handle}
function AllocateMemoryPtr(whichSize : SInt32) : Pointer;
function AllocateMemoryHdl(whichSize : SInt32) : Handle;

{Allocation de Pointer et de Handle, les blocs memoires sont remplis de zeros}
function AllocateMemoryPtrClear(whichSize : SInt32) : Pointer;
function AllocateMemoryHdlClear(whichSize : SInt32) : Handle;

{Liberation des blocs memoire; les pointeurs sont remis a NIL ensuite}
procedure DisposeMemoryPtr(var whichPtr : Pointer);
procedure DisposeMemoryHdl(var whichHandle : Handle);

{Remplissage d'un bloc de memoire par un caractere donné}
procedure MemoryFillChar(bufferPtr : Pointer; byteCount: SInt32; caractere : Char);

{Deplacement d'un bloc de memoire}
procedure MoveMemory(sourcePtr, destPtr: Pointer; byteCount: SInt32);

{Egalite de deux blocs memoire}
function EgalitePolymorphe(ptr1, ptr2 : Pointer; tailleDonnees : SInt32) : boolean;

{Fabriquer et defaire des pointeurs}
function MAKE_MEMORY_POINTER(v : SInt64) : Pointer;
function POINTER_VALUE(p : Pointer) : SInt64;
function POINTER_ADD(p : Pointer ; increment : SInt64) : Pointer;


implementation

// AllocateMemoryPtr() : allocate memory, returning a pointer

function AllocateMemoryPtr(whichSize : SInt32) : Pointer;
begin
  AllocateMemoryPtr := GetMem(whichSize);
end;


// AllocateMemoryHdl() : allocate memory, returning a handle

function AllocateMemoryHdl(whichSize : SInt32) : Handle;
var h : Handle;
begin
  new(h);
  GetMem(h^ , whichSize);
  AllocateMemoryHdl := h;
end;


// AllocateMemoryPtrClear() : allocate memory filled with zeros, returning a pointer

function AllocateMemoryPtrClear(whichSize : SInt32) : Pointer;
var p : Pointer;
begin
  p := AllocateMemoryPtr(whichSize);
  MemoryFillChar(p, whichSize, chr(0));
  AllocateMemoryPtrClear := p;
end;


// AllocateMemoryHdlClear() : allocate memory filled with zeros, returning a handle

function AllocateMemoryHdlClear(whichSize : SInt32) : Handle;
var h : Handle;
begin
  h := AllocateMemoryHdl(whichSize);
  MemoryFillChar(h^, whichSize, chr(0));
  AllocateMemoryHdlClear := h;
end;


// DisposeMemoryPtr() : dispose a pointer

procedure DisposeMemoryPtr(var whichPtr : Pointer);
begin
  Freemem(whichPtr);
  whichPtr := NIL;
end;


// DisposeMemoryHandle() : dispose a handle

procedure DisposeMemoryHdl(var whichHandle : Handle);
begin
  Freemem(whichHandle^);
  Dispose(whichHandle);
  whichHandle := NIL;
end;


// MemoryFillChar() : fill memory zone with a character

procedure MemoryFillChar(bufferPtr : Pointer; byteCount: SInt32; caractere : Char);
var theBuffer : PackedArrayOfCharPtr;
begin
  theBuffer := PackedArrayOfCharPtr(bufferPtr);
  FillChar(theBuffer^, byteCount, caractere);
end;


// MoveMemory() : move block of memory

procedure MoveMemory(sourcePtr, destPtr : Pointer; byteCount : SInt32);
begin
  Move(sourcePtr^ , destPtr^ , byteCount);
end;


// EgalitePolymorphe() : test equality of two blocks of memory

function EgalitePolymorphe(ptr1, ptr2 : Pointer; byteCount : SInt32) : boolean;
var
	i : SInt32;
	p1, p2 : PackedArrayOfCharPtr;
begin
  p1 := PackedArrayOfCharPtr(ptr1);
  p2 := PackedArrayOfCharPtr(ptr2);
	for i := 0 to byteCount - 1 do
		if p1^[i] <> p2^[i] then
			begin
				EgalitePolymorphe := false;
				exit(EgalitePolymorphe);
			end;
	EgalitePolymorphe := true;
end;


// MAKE_MEMORY_POINTER() : cast an integer to a pointer

function MAKE_MEMORY_POINTER(v : SInt64) : Pointer;
begin
   MAKE_MEMORY_POINTER := Pointer(v);
end;


// POINTER_VALUE() : cast a pointer to an integer

function POINTER_VALUE(p : Pointer) : SInt64;
begin
   POINTER_VALUE := SInt64(p);
end;


// POINTER_ADD() : add an increment (in bytes) to a pointer

function POINTER_ADD(p : Pointer ; increment : SInt64) : Pointer;
begin
   POINTER_ADD := MAKE_MEMORY_POINTER(POINTER_VALUE(p) + increment);
end;


// testBasicMemory() : testing various functions of the BasicMemory unit

procedure testBasicMemory;
var S1, S2 : string[30];
    theSize, k, v : SInt32;
    m : PackedArrayOfBytePtr;
    p , q : Pointer;
begin
   theSize := sizeof(S1);
   
   Writeln();
   writeln('theSize = ', theSize);
   S1 := 'Hello World ! ';
   S2 := 'Bye, bye    ! ';
   Writeln('S2 = ', S2);
   MoveMemory(@S1, @S2, theSize);
   Writeln('S2 = ', S2);
   Writeln();
    
   m := AllocateMemoryPtrClear(theSize);
   for k := 0 to theSize - 1 do
      Writeln(m^[k]);
   
   MoveMemory(@S2, m, ord(S2[0]));
   for k := 0 to theSize - 1 do
      begin
         v := m^[k];
         Writeln('m^[', k ,'] = ', chr(m^[k]), '  , ' , v );
      end;
  p := m;
  Writeln('at address ', POINTER_VALUE(p), ' , value is ', (bytePtr(p))^);
  for k := 0 to theSize - 1 do
    begin
      q := POINTER_ADD(p, k);
      Writeln('at address ', POINTER_VALUE(q), ' , value is ', (bytePtr(q))^);
    end;
  DisposeMemoryPtr(m);

end;



begin
   testBasicMemory();
end.
















