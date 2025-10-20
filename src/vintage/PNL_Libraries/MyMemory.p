UNIT MyMemory;

INTERFACE







 uses
     UnitDefCassio;



{ WARNING: MTrash et al only do anything in debugging mode! }

{$ifc not do_debug}
{$definec MTrash(p,s)}
{$definec MTrashPtr(p)}
{$definec MTrashHandle(h)}
{$elsec}
{$definec MTrash(p,s) MFill(p,s,trash_byte)}
{$definec MTrashPtr(p) MFill(p,GetPtrSize(p),trash_byte)}
{$definec MTrashHandle(h) MFill(h^,GetHandleSize(h),trash_byte)}
{$endc}

	function MNewPtr ( var p : UnivPtr; size: SInt32 ) : OSErr;
	function MNewHandle ( var data : UnivHandle; size: SInt32 ) : OSErr;
	function MSetPtrSize ( p : UnivPtr; size: SInt32 ) : OSErr;
	function MSetHandleSize ( data : UnivHandle; size: SInt32 ) : OSErr;
	function MGrowHandleSize ( data : UnivHandle; size: SInt32 ) : OSErr;
	procedure MShrinkHandleSize( data : UnivHandle; size: SInt32 );
	procedure MDisposePtr ( var p : UnivPtr );
	procedure MDisposeHandle ( var data : UnivHandle );
	function MMungerInsert( data : Handle; offset: SInt32; ptr2: UnivPtr; len2: SInt32 ) : OSErr;
	procedure MMungerDelete( data : Handle; offset: SInt32; len1: SInt32 );
	procedure MZero ( p : UnivPtr; size: SInt32 );
	procedure MFill ( p : UnivPtr; size: SInt32; val : SInt16 );
	procedure MFillLong ( p : UnivPtr; size: SInt32; val : SInt32 );
{ Ptr and size must be long alligned }
	procedure LockHigh ( data : UnivHandle );
	procedure HLockState ( data : Handle; var state: SInt8 );
	procedure HUnlockState ( data : Handle; var state: SInt8 );

	function CheckPointer ( p : Ptr ) : boolean;
	function CheckPtr ( p : Ptr ) : boolean;
	function CheckHandle ( data : Handle ) : boolean;

IMPLEMENTATION







	uses
		MacMemory, TextUtils, MyAssertions;
		{MyLowLevel;}

	const
		trash_byte = $E5; { odd, big, negative, easily recognizable }


	function CheckPointer ( p : Ptr ) : boolean;
	begin
		Assert( p <> NIL );
		CheckPointer := p <> NIL;
	end;

	function CheckPtr ( p : Ptr ) : boolean;
	begin
		Assert( (p <> NIL) & (GetPtrSize( p ) >= 0) & (MemError = noErr) );
		CheckPtr := p <> NIL;
	end;

	function CheckHandle ( data : Handle ) : boolean;
	begin
		Assert( (data <> NIL) & (GetHandleSize( data ) >= 0) & (MemError = noErr) );
		CheckHandle := data <> NIL;
	end;

	function MNewPtr ( var p : UnivPtr; size: SInt32 ) : OSErr;
		var
			err : OSErr;
	begin
		Assert( size >= 0 );
		p := NewPtr(size);
		err := MemError;
		{ a remettre dans CW Pro !!  }
		{if (err = noErr) then begin
			MTrashPtr( p );
		end;}
		MNewPtr := err;
	end;

	function MNewHandle ( var data : UnivHandle; size: SInt32 ) : OSErr;
		var
			err : OSErr;
	begin
		Assert( size >= 0 );
		data := UnivHandle(NewHandle(size));
		err := MemError;
		{ a remettre dans CW Pro !!   }
		{if (err = noErr) then begin
			MTrashHandle( data );
		end;}
		MNewHandle := err;
	end;

	function MSetPtrSize ( p : UnivPtr; size: SInt32 ) : OSErr;
{$ifc do_debug}
		var
			oldsize: SInt32;
{$endc}
	begin
{$ifc do_debug}
		Assert( p <> NIL );
		Assert( size >= 0 );
		oldsize := GetPtrSize( p );
		if oldsize < size then begin
			SetPtrSize( p, size );
			{ a remettre dans CW Pro !!   }
			{if MemError = noErr then begin
				MTrash( AddPtrLong( p, oldsize ), size - oldsize );
			end;}
		end else if oldsize > size then DoNothing;
		{ a remettre dans CW Pro !!   }
		{begin
			MTrash( AddPtrLong( p, size ), oldsize - size );
		end;}
{$endc}
		if CheckPtr( p ) then begin
			SetPtrSize( p, size );
			MSetPtrSize := MemError;
		end else begin
			MSetPtrSize := -1;
		end;
	end;

	function MSetHandleSize ( data : UnivHandle; size: SInt32 ) : OSErr;
{$ifc do_debug}
		var
			oldsize: SInt32;
{$endc}
	begin
{$ifc do_debug}
		Assert( data <> NIL );
		Assert( size >= 0 );
		oldsize := GetHandleSize( Handle(data) );
		Assert( MemError = noErr );
		if oldsize < size then begin
			SetHandleSize( Handle(data), size );
			{ a remettre dans CW Pro !!   }
			{
			if MemError = noErr then begin
				MTrash( AddPtrLong( data^, oldsize ), size - oldsize );
			end;}
		end else if oldsize > size then DoNothing;
		{ a remettre dans CW Pro !!   }
		{begin
			MTrash( AddPtrLong( data^, size ), oldsize - size );
		end;}
{$endc}
		if CheckHandle( Handle(data) ) then begin
			SetHandleSize( Handle(data), size );
			MSetHandleSize := MemError;
		end else begin
			MSetHandleSize := -1;
		end;
	end;

	function MGrowHandleSize ( data : UnivHandle; size: SInt32 ) : OSErr;
{$ifc do_debug}
		var
			oldsize: SInt32;
{$endc}
	begin
{$ifc do_debug}
		Assert( data <> NIL );
		Assert( size >= 0 );
		oldsize := GetHandleSize( Handle(data) );
		Assert( MemError = noErr );
		Assert( size >= oldsize );
{$endc}
		MGrowHandleSize := MSetHandleSize( data, size );
	end;

	procedure MShrinkHandleSize( data : UnivHandle; size: SInt32 );
{$ifc do_debug}
		var
			oldsize: SInt32;
{$endc}
		var
			junk: OSErr;
	begin
{$ifc do_debug}
		Assert( data <> NIL );
		Assert( size >= 0 );
		oldsize := GetHandleSize( Handle(data) );
		Assert( MemError = noErr );
		Assert( size <= oldsize );
{$endc}
		junk := MSetHandleSize( data, size );
		Assert( junk = noErr );
	end;

	procedure MDisposePtr ( var p : UnivPtr );
	begin
		if (p <> NIL) & CheckPtr( p ) then begin
		    { a remettre dans CW Pro !!   }
			{MTrashPtr( p );}
			DisposePtr(p);
			p := NIL;
		end;
	end;

	procedure MDisposeHandle ( var data : UnivHandle );
	begin
		if (data <> NIL) & CheckHandle( Handle(data) ) then begin
		    { a remettre dans CW Pro !!   }
			{MTrashHandle( data );}
			DisposeHandle( Handle(data) );
			data := NIL;
		end;
	end;

	procedure MZero (p : UnivPtr; size: SInt32);
	begin
		MFill( p, size, 0 );
	end;

	procedure MFill (p : UnivPtr; size: SInt32; val : SInt16);
		var
			i : UInt32;
	begin
		Assert( size >= 0 );
		if CheckPointer(p) then begin
			if size > 0 then begin { since i is unsigned, size-1 must be >= 0 }
				for i := 0 to size - 1 do begin
					Ptr(POINTER_VALUE(p)+ i)^ := SInt8(val);
				end;
			end;
		end;
	end;

	procedure MFillLong (p : UnivPtr; size: SInt32; val : SInt32);
{ Ptr and size must be long alligned }
		type
			longPtr = ^SInt32;
		var
			i : SInt32;
	begin
		Assert( (size >= 0) );
		if CheckPointer(p) then begin
			(* Assert( (BAnd(POINTER_VALUE(p), 3) = 0) & (BAnd(size, 3) = 0) ); *)
			i := SInt32(p);
			while size > 3 do begin
				longPtr(i)^ := val;
				i := i + 4;
				size := size - 4;
			end;
		end;
	end;

	procedure LockHigh ( data : UnivHandle );
	begin
		if CheckHandle( Handle(data) ) then begin
			MoveHHi( Handle(data) );
			HLock( Handle(data) );
		end;
	end;

	procedure HLockState ( data : Handle; var state: SInt8 );
	begin
		if CheckHandle( data ) then begin
			state := HGetState(data);
			HLock(data);
		end;
	end;

	procedure HUnlockState ( data : Handle; var state: SInt8 );
	begin
		if CheckHandle( data ) then begin
			state := HGetState(data);
			HUnlock(data);
		end;
	end;

	function MMungerInsert( data : Handle; offset: SInt32; ptr2: UnivPtr; len2: SInt32 ) : OSErr;
		var
			junk_long: SInt32;
	begin
		if CheckHandle( data ) then begin
			Assert( (len2 >= 0) & (0 <= offset) & (offset <= GetHandleSize( data ) ) );
			junk_long := Munger(data, offset, NIL, 0, ptr2, len2);
			MMungerInsert := MemError;
		end else begin
			MMungerInsert := -1;
		end;
	end;

	procedure MMungerDelete(data : Handle; offset: SInt32; len1: SInt32);
		var
			junk_long: SInt32;
	begin
		if CheckHandle( data ) then begin
			Assert( (len1 >= 0) & (0 <= offset) & (offset + len1 <= GetHandleSize( data ) ) );
			junk_long := Munger(data, offset, NIL, len1, @junk_long, 0);
		end;
	end;




end.
