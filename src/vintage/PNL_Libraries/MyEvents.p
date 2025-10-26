UNIT MyEvents;

INTERFACE







 uses
     Events , UnitDefCassio;

	function EventHasOptionKey( const er : EventRecord ) : Boolean;
	function EventHasCommandKey( const er : EventRecord ) : Boolean;
	function EventHasControlKey( const er : EventRecord ) : Boolean;
	function EventHasShiftKey( const er : EventRecord ) : Boolean;
	function EventChar( const er : EventRecord ) : char;
	function EventCharCode( const er : EventRecord ) : SInt16;
	function EventKeyCode( const er : EventRecord ) : SInt16;
	function EventIsSuspendResume( const er : EventRecord ) : Boolean;
	function EventHasResume( const er : EventRecord ) : Boolean;
	function EventIsMouseMoved( const er : EventRecord ) : Boolean;
	function EventHasActivate( const er : EventRecord ) : Boolean;
	function EventIsKeyDown( const er : EventRecord ) : Boolean;
	function EventHasOK( const er : EventRecord ) : Boolean;
	function EventHasCancel( const er : EventRecord ) : Boolean;
	function EventHasDiscard( const er : EventRecord ) : Boolean;

IMPLEMENTATION



{$definec ORD4_FOR_MY_EVENTS(n) (n)}



	uses
		 MyTypes;

	function EventHasOptionKey( const er : EventRecord ) : Boolean;
	begin
		EventHasOptionKey := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), optionKey) <> 0;
	end;

	function EventHasCommandKey( const er : EventRecord ) : Boolean;
	begin
		EventHasCommandKey := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), cmdKey) <> 0;
	end;

	function EventHasControlKey( const er : EventRecord ) : Boolean;
	begin
		EventHasControlKey := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), controlKey) <> 0;
	end;

	function EventHasShiftKey( const er : EventRecord ) : Boolean;
	begin
		EventHasShiftKey := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), shiftKey) <> 0;
	end;

	function EventChar( const er : EventRecord ) : char;
	begin
		EventChar := Chr(BAND(SInt32(ORD4_FOR_MY_EVENTS(er.message)), charCodeMask));
	end;

	function EventCharCode( const er : EventRecord ) : SInt16;
	begin
		EventCharCode := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.message)), charCodeMask);
	end;

	function EventKeyCode( const er : EventRecord ) : SInt16;
	begin
		EventKeyCode := BSR(BAND(SInt32(ORD4_FOR_MY_EVENTS(er.message)), keyCodeMask),8);
	end;

	function EventIsSuspendResume( const er : EventRecord ) : Boolean;
	begin
		EventIsSuspendResume := BAND(BSL(SInt32(ORD4_FOR_MY_EVENTS(er.message)), 8), $00FF) = kSuspendResumeMessage;
	end;

	function EventHasResume( const er : EventRecord ) : Boolean;
	begin
		EventHasResume := BAND(SInt32(ORD4_FOR_MY_EVENTS(er.message)), kResumeMask) <> 0;
	end;

	function EventIsMouseMoved( const er : EventRecord ) : Boolean;
	begin
		EventIsMouseMoved := BAND(BSL(SInt32(ORD4_FOR_MY_EVENTS(er.message)), 8), $00FF) = kMouseMovedMessage;
	end;

	function EventHasActivate( const er : EventRecord ) : Boolean;
	begin
		EventHasActivate := odd(er.modifiers);
	end;

	function EventIsKeyDown( const er : EventRecord ) : Boolean;
	begin
		EventIsKeyDown := (er.what = keyDown) or (er.what = autoKey);
	end;

	function EventHasOK( const er : EventRecord ) : Boolean;
		var
			ch : char;
	begin
		ch := EventChar( er );
		EventHasOK := (ch = cr) or (ch = enter);
	end;

	function EventHasCancel( const er : EventRecord ) : Boolean;
		var
			ch : char;
	begin
		ch := EventChar( er );
		EventHasCancel := ((ch = '.') and EventHasCommandKey( er )) or (ch = esc);
	end;

	function EventHasDiscard( const er : EventRecord ) : Boolean;
		var
			ch : char;
	begin
		ch := EventChar( er );
		EventHasDiscard := (ch = 'd') and EventHasCommandKey( er );
	end;

end.
