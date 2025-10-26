UNIT MyLowLevel;

INTERFACE







 uses
     UnitDefCassio;

(* Global Bashing - Get constants from SysEqu.p *)

{$definec GetGlobalB(addr) Ptr(ad)^}
{$definec SetGlobalB(addr, n) Ptr(ad)^ := n}
{$definec GetGlobalW(ad) IntegerPtr(ad)^}
{$definec SetGlobalW(ad, n) IntegerPtr(ad)^ := n}
{$definec GetGlobalL(ad) LongIntPtr(ad)^}
{$definec SetGlobalL(ad, n) LongIntPtr(ad)^ := n}

	function GetGlobalS (ad:  SInt32) : String255;
	procedure SetGlobalS (ad:  SInt32; s : String255);  { only bashes len+1 chars }

{$definec AddPtrLong( p, offset ) Ptr(ord4(p) + offset)}
{$definec OffsetPtr( p, offset ) Ptr(p) := Ptr(ord4(p) + (offset))}
{$definec SubPtrPtr( left, right ) (ord4(left) - ord4(right))}
{$definec GetUnsignedByte( p, offset ) (AddPtrLong(p, offset)^ and $00FF)}
{$definec SetUnsignedByte( p, offset, value ) (AddPtrLong(p, offset)^ := BAND(value, $00FF)}
{$definec CompLS( a1, a2 ) (UInt32(a1) <= UInt32(a2))}
{$definec CompLO( a1, a2 ) (UInt32(a1) < UInt32(a2))}
{$definec CompHS( a1, a2 ) (UInt32(a1) >= UInt32(a2))}
{$definec CompHI( a1, a2 ) (UInt32(a1) > UInt32(a2))}

	procedure BSETW (var l: SInt16; num: SInt16);
	procedure BCLRW (var l: SInt16; num: SInt16);



IMPLEMENTATION







	uses
		MacMemory,UnitServicesMemoire;

	function GetGlobalS (ad:  SInt32) : String255;
		var
			tmp : String255;
	begin
		BlockMoveData(MAKE_MEMORY_POINTER(ad), @tmp, sizeof(tmp));
		GetGlobalS := tmp;
	end; (* GetGlobalB *)

	procedure SetGlobalS (ad:  SInt32; s : String255); (* only bashes}
{len+1 chars *)
	begin
		BlockMoveData(@s, MAKE_MEMORY_POINTER(ad), LENGTH_OF_STRING(s) + 1);
	end; (* GetGlobalB *)

	procedure BSETW (var l: SInt16; num: SInt16);
		var
			ll: SInt32;
	begin
		ll := l;
		BSET(ll, num);
		l := ll;
	end;

	procedure BCLRW (var l: SInt16; num: SInt16);
		var
			ll: SInt32;
	begin
		ll := l;
		BCLR(ll, num);
		l := ll;
	end;

end.
