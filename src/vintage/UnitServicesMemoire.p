UNIT  UnitServicesMemoire;


INTERFACE







 USES UnitDefCassio;






{Allocation de Ptr et de Handle}
function AllocateMemoryPtr(whichSize : SInt32) : Ptr;                                                                                                                               ATTRIBUTE_NAME('AllocateMemoryPtr')
function AllocateMemoryHdl(whichSize : SInt32) : handle;                                                                                                                            ATTRIBUTE_NAME('AllocateMemoryHdl')

{Allocation de Ptr et de Handle, les blocs memoires sont remplis de zeros}
function AllocateMemoryPtrClear(whichSize : SInt32) : Ptr;                                                                                                                          ATTRIBUTE_NAME('AllocateMemoryPtrClear')
function AllocateMemoryHdlClear(whichSize : SInt32) : handle;                                                                                                                       ATTRIBUTE_NAME('AllocateMemoryHdlClear')

{Liberation des blocs memoire; les pointeurs sont remis a NIL ensuite}
procedure DisposeMemoryPtr(var whichPtr : Ptr);                                                                                                                                     ATTRIBUTE_NAME('DisposeMemoryPtr')
procedure DisposeMemoryHdl(var whichHandle : handle);                                                                                                                               ATTRIBUTE_NAME('DisposeMemoryHdl')

{Remplissage d'un bloc de memoire par un caractere donné}
procedure MemoryFillChar(bufferPtr : universal UnivPtr; byteCount: SInt32; caractere : char);                                                                                       ATTRIBUTE_NAME('MemoryFillChar')

{Deplacement d'un bloc de memoire}
procedure MoveMemory(sourcePtr,destPtr: Ptr; byteCount: SInt32);                                                                                                                    ATTRIBUTE_NAME('MoveMemory')

{Egalite de deux blocs memoire}
function EgalitePolymorphe(ptr1, ptr2 : Ptr{univ PackedArrayOfCharPtr}; tailleDonnees : SInt32) : boolean;                                                                          ATTRIBUTE_NAME('EgalitePolymorphe')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}















USES
    MacMemory;

{END_USE_CLAUSE}



function AllocateMemoryPtr(whichSize : SInt32) : Ptr;
begin
  AllocateMemoryPtr := NewPtr(whichSize);
end;


function AllocateMemoryHdl(whichSize : SInt32) : handle;
begin
  AllocateMemoryHdl := NewHandle(whichSize);
end;


function AllocateMemoryPtrClear(whichSize : SInt32) : Ptr;
begin
  AllocateMemoryPtrClear := NewPtrClear(whichSize);
end;


function AllocateMemoryHdlClear(whichSize : SInt32) : handle;
begin
  AllocateMemoryHdlClear := NewHandleClear(whichSize);
end;



procedure DisposeMemoryPtr(var whichPtr : Ptr);
begin
  DisposePtr(whichPtr);
  whichPtr := NIL;
end;


procedure DisposeMemoryHdl(var whichHandle : handle);
begin
  DisposeHandle(whichHandle);
  whichHandle := NIL;
end;


procedure MemoryFillChar(bufferPtr : universal UnivPtr; byteCount: SInt32; caractere : char);
var theBuffer : PackedArrayOfCharPtr;
begin
  theBuffer := PackedArrayOfCharPtr(bufferPtr);
	FillChar(theBuffer^, byteCount, caractere);
end;


procedure MoveMemory(sourcePtr,destPtr : Ptr; byteCount : SInt32);
begin
  BlockMoveData(sourcePtr,destPtr,byteCount);
end;



function EgalitePolymorphe(ptr1, ptr2 : Ptr; tailleDonnees : SInt32) : boolean;
	var
		i : SInt32;
		p1, p2 : PackedArrayOfCharPtr;
begin
  p1 := PackedArrayOfCharPtr(ptr1);
  p2 := PackedArrayOfCharPtr(ptr2);
	for i := 0 to tailleDonnees - 1 do
		if p1^[i] <> p2^[i] then
			begin
				EgalitePolymorphe := false;
				exit(EgalitePolymorphe);
			end;
	EgalitePolymorphe := true;
end;

END.

