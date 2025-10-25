UNIT MyCStrings;

INTERFACE


	uses
		MacTypes,StringTypes;
		
	procedure CopyC2P (c: Ptr; var s : Str255);
	procedure C2P(p : Ptr);
	procedure CopyP2Cvar (var s : String255; c: Ptr);
	procedure CopyP2C (s : String255; c: Ptr);
	procedure P2C(p : Ptr);
		
		
		
		
IMPLEMENTATION


 USES MacMemory;
		
	procedure CopyC2P (c: Ptr; var s : Str255);
		var
			i,len : SInt16;
			p,q : Ptr;
	begin
		len := 0;
		p := c;
		while (p^ <> 0) and (len<255) do begin
			Inc(len);
			Inc(SInt32(p));
		end;
		q := POINTER_ADD(@s , len);
		Dec(SInt32(p));
		for i := 1 to len do begin
			q^ := p^;
			Dec(SInt32(q));
			Dec(SInt32(p));
		end;
		q^ := len;
	end;

	procedure C2P(p : Ptr);
	begin
		CopyC2P(p,StringPtr(p)^);
	end;
	
	procedure CopyP2Cvar (var s : String255; c: Ptr);
		var
			len : SInt16;
	begin
		len := LENGTH_OF_STRING(s);
		BlockMoveData(@s[1],c,len);
		Ptr(SInt32(c)+len)^ := 0;
	end;
	
	procedure CopyP2C (s : String255; c: Ptr);
	begin
		BlockMoveData(@s[1],c,LENGTH_OF_STRING(s));
		Ptr(SInt32(c)+LENGTH_OF_STRING(s))^ := 0;
	end;
	
	procedure P2C(p : Ptr);
		var
			len : SInt16;
	begin
		len := BAnd(p^,$00FF);
		BlockMoveData(Ptr(SInt32(p)+1),p,len);
		Ptr(SInt32(p)+len)^ := 0;
	end;
		
end.
