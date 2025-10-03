UNIT MyEvents;

INTERFACE







 uses
     Events , UnitDefCassio;

	function EventHasOptionKey( const er : EventRecord ) : Boolean;                                                                                                                    ATTRIBUTE_NAME('EventHasOptionKey')
	function EventHasCommandKey( const er : EventRecord ) : Boolean;                                                                                                                   ATTRIBUTE_NAME('EventHasCommandKey')
	function EventHasControlKey( const er : EventRecord ) : Boolean;                                                                                                                   ATTRIBUTE_NAME('EventHasControlKey')
	function EventHasShiftKey( const er : EventRecord ) : Boolean;                                                                                                                     ATTRIBUTE_NAME('EventHasShiftKey')
	function EventChar( const er : EventRecord ) : char;                                                                                                                               ATTRIBUTE_NAME('EventChar')
	function EventCharCode( const er : EventRecord ) : SInt16;                                                                                                                         ATTRIBUTE_NAME('EventCharCode')
	function EventKeyCode( const er : EventRecord ) : SInt16;                                                                                                                          ATTRIBUTE_NAME('EventKeyCode')
	function EventIsSuspendResume( const er : EventRecord ) : Boolean;                                                                                                                 ATTRIBUTE_NAME('EventIsSuspendResume')
	function EventHasResume( const er : EventRecord ) : Boolean;                                                                                                                       ATTRIBUTE_NAME('EventHasResume')
	function EventIsMouseMoved( const er : EventRecord ) : Boolean;                                                                                                                    ATTRIBUTE_NAME('EventIsMouseMoved')
	function EventHasActivate( const er : EventRecord ) : Boolean;                                                                                                                     ATTRIBUTE_NAME('EventHasActivate')
	function EventIsKeyDown( const er : EventRecord ) : Boolean;                                                                                                                       ATTRIBUTE_NAME('EventIsKeyDown')
	function EventHasOK( const er : EventRecord ) : Boolean;                                                                                                                           ATTRIBUTE_NAME('EventHasOK')
	function EventHasCancel( const er : EventRecord ) : Boolean;                                                                                                                       ATTRIBUTE_NAME('EventHasCancel')
	function EventHasDiscard( const er : EventRecord ) : Boolean;                                                                                                                      ATTRIBUTE_NAME('EventHasDiscard')

IMPLEMENTATION



{$definec ORD4_FOR_MY_EVENTS(n) (n)}



	uses
		 MyTypes;

	function EventHasOptionKey( const er : EventRecord ) : Boolean;
	begin
		EventHasOptionKey := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), optionKey) <> 0;
	end;

	function EventHasCommandKey( const er : EventRecord ) : Boolean;
	begin
		EventHasCommandKey := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), cmdKey) <> 0;
	end;

	function EventHasControlKey( const er : EventRecord ) : Boolean;
	begin
		EventHasControlKey := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), controlKey) <> 0;
	end;

	function EventHasShiftKey( const er : EventRecord ) : Boolean;
	begin
		EventHasShiftKey := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.modifiers)), shiftKey) <> 0;
	end;

	function EventChar( const er : EventRecord ) : char;
	begin
		EventChar := Chr(BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.message)), charCodeMask));
	end;

	function EventCharCode( const er : EventRecord ) : SInt16;
	begin
		EventCharCode := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.message)), charCodeMask);
	end;

	function EventKeyCode( const er : EventRecord ) : SInt16;
	begin
		EventKeyCode := BSr(BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.message)), keyCodeMask),8);
	end;

	function EventIsSuspendResume( const er : EventRecord ) : Boolean;
	begin
		EventIsSuspendResume := BAnd(BSl(SInt32(ORD4_FOR_MY_EVENTS(er.message)), 8), $00FF) = kSuspendResumeMessage;
	end;

	function EventHasResume( const er : EventRecord ) : Boolean;
	begin
		EventHasResume := BAnd(SInt32(ORD4_FOR_MY_EVENTS(er.message)), kResumeMask) <> 0;
	end;

	function EventIsMouseMoved( const er : EventRecord ) : Boolean;
	begin
		EventIsMouseMoved := BAnd(BSl(SInt32(ORD4_FOR_MY_EVENTS(er.message)), 8), $00FF) = kMouseMovedMessage;
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
