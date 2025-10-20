UNIT PreserveA5;

INTERFACE

{$PRAGMAC align_array_members on }
{$PRAGMAC align power }
{$PRAGMAC options align= power }
{$PRAGMAC function_align 16}
{$ALIGN PowerPC}

	uses
		MacTypes, Files;

	const
		XParamBlockRecExtra = 4;
		
	type
		XParamBlockRec = record
				completion : UniversalProcPtr;
				pb : ParamBlockRec;
			end;
		XParmBlkPtr = ^XParamBlockRec;

	var
		gPreCompletionProc:UniversalProcPtr;
	
	procedure StartupPreserveA5;
	function SetPreservedA5 : Ptr;
	procedure RestoreA5(olda5 : Ptr);

IMPLEMENTATION

{$PRAGMAC align_array_members on }
{$PRAGMAC align power }
{$PRAGMAC options align= power }
{$PRAGMAC function_align 16}
{$ALIGN PowerPC}

	uses
		MyCallProc, MyStartup;
		
{$IFC GENERATINGPOWERPC}

	procedure SetupPreserveA5;
	begin
	end;
	
	function SetPreservedA5 : Ptr;
	begin
		SetPreservedA5 := NIL;
	end;
	
	procedure RestoreA5(olda5 : Ptr);
	begin
{$unused(olda5)}
	end;

	procedure PreCompletion(pbp: ParmBlkPtr);
		var
			prp: XParmBlkPtr;
	begin
		prp := XParmBlkPtr(ord(pbp) - XParamBlockRecExtra);
		{CallIOCompletionProc(pbp, prp^.completion);}
		InvokeIOCompletionUPP(pbp, @prp^.completion);
	end;
	
{$ELSEC}

	procedure PreCompletion;     external;
	procedure SetupPreserveA5;     external;
	
{$ENDC}

	function InitPreserveA5(var msg: SInt16) : OSStatus;
	begin {$UNUSED msg}
	  (*
{$unused(msg)}
		gPreCompletionProc := NewIOCompletionUPP(PreCompletion);
		SetupPreserveA5;
		*)
		InitPreserveA5 := noErr;
		
	end;
	
	procedure StartupPreserveA5;
	begin
		SetStartup(InitPreserveA5, NIL, 0, NIL);
	end;
	
end.