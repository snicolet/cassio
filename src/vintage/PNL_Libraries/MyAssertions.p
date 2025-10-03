UNIT MyAssertions;

INTERFACE







 uses
     UnitDefCassio;

{$ifc not defined do_debug}
{$definec do_debug 1}
{$endc}


{$ifc defined __GPC__}


{$elsec}

  {$ifc not do_debug}
  { buggy compiler $ definec Assert(b)}
  { $ definec Assert(b) if false & (b) then begin end else begin end }
  {$definec SafeDebugStr(s)}
  {$elsec}
  { $ definec Assert(b) AssertCode(b)}
  {$definec SafeDebugStr(b) MyDebugStr(s)}
  {$endc}

{$endc}


  procedure Assert(b : boolean);                                                                                                                                                    ATTRIBUTE_NAME('Assert')
	procedure AssertCode (b : boolean);                                                                                                                                                ATTRIBUTE_NAME('AssertCode')
	procedure AssertValidPtr (p : UnivPtr);                                                                                                                                            ATTRIBUTE_NAME('AssertValidPtr')
	procedure AssertValidPtrNil (p : UnivPtr);                                                                                                                                         ATTRIBUTE_NAME('AssertValidPtrNil')
	procedure AssertValidHandle (hhhh : UnivHandle);                                                                                                                                   ATTRIBUTE_NAME('AssertValidHandle')
	procedure AssertValidHandleNil (hhhh : UnivHandle);                                                                                                                                ATTRIBUTE_NAME('AssertValidHandleNil')
  procedure MyDebugStr(const s : String255);                                                                                                                                        ATTRIBUTE_NAME('MyDebugStr')


IMPLEMENTATION



	USES
		MacMemory,UnitServicesMemoire
		;



   procedure Assert(b : boolean);
   begin
     AssertCode(b);
   end;

{$ifc do_debug}
	procedure AssertCode (b : boolean);
	begin
		if not b then begin
			MyDebugStr('Assert Failed; sc; hc');
		end;
	end;

	procedure AssertValidPtr (p : UnivPtr);
	begin
		Assert((p <> NIL) & (not odd(POINTER_VALUE(p))));
	end;

	procedure AssertValidPtrNil (p : UnivPtr);
	begin
		if p <> NIL then begin
			AssertValidPtr(p);
		end;
	end;

	procedure AssertValidHandle (hhhh : UnivHandle);
	begin
		AssertValidPtr(Ptr(hhhh));
		AssertValidPtr(hhhh^);
		Assert(UnivHandle(RecoverHandle(hhhh^)) = hhhh);
	end;

	procedure AssertValidHandleNil (hhhh : UnivHandle);
	begin
		if hhhh <> NIL then begin
			AssertValidHandle(hhhh);
		end;
	end;
{$endc}


procedure MyDebugStr(const s : String255);
begin
  DebugStr(StringToStr255(s));
end;



end.


