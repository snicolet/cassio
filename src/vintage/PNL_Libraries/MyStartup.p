UNIT MyStartup;

INTERFACE







	uses
		MacTypes;
	
	var
		current_time: SInt32;
		
	type
		StartupMessages = (SMT_None, SMT_Startup, SMT_Generic, SMT_NeedsSystem7, SMT_FailedToInitTCP, SMT_Rest);
		StartupInitProc = function(var msg: SInt16) : OSStatus;
		StartupIdleProc = procedure;
		StartupFinishProc = procedure;
		
	procedure InitStartup;
	procedure SetStartup(init: StartupInitProc; idle: StartupIdleProc; idle_period: SInt32; finish: StartupFinishProc);
	function Startup(var msg: SInt16) : OSStatus;
	procedure IdleStartup;
	procedure FinishStartup;
	procedure FireAtIdle(idle: StartupIdleProc);
	
IMPLEMENTATION







	uses
		MacMemory, Events, MyMemory, OSUtils;
	
	type
		EntryRecord = record
			init: StartupInitProc;
			idle: StartupIdleProc;
			idle_period: SInt32;
			next_idle: SInt32;
			finish: StartupFinishProc;
		end;
		EntryArray = array[1..10000] of EntryRecord;
		EntryPtr = ^EntryArray;
		EntryHandle = ^EntryPtr;

	const
		idles_max = 100;
		
	var
		idles: array[1..idles_max] of StartupIdleProc;
		max_idles: SInt32;
		startup_error: OSStatus;
		entries: EntryHandle;
		entries_count: SInt32;
	
	procedure FireAtIdle(idle: StartupIdleProc);
		var
			i : SInt32;
			found: Boolean;
			hack: StartupIdleProc;
	begin
		found := false;
		for i := 1 to idles_max do begin
			hack := idles[i];
			if hack = NIL then begin
				idles[i] := idle;
				if i > max_idles then begin
					max_idles := i;
				end;
				found := true;
				leave;
			end;
		end;
		if not found then begin
			idle;
		end;
	end;
	
	procedure SetStartup(init: StartupInitProc; idle: StartupIdleProc; idle_period: SInt32; finish: StartupFinishProc);
		var
			found: Boolean;
			entry: EntryRecord;
			i : SInt32;
	begin
		if (startup_error = noErr) and (entries = NIL) then begin
			startup_error := MNewHandle(UnivHandle(entries), 0);
		end;
		if startup_error = noErr then begin
			found := false;
			for i := 1 to entries_count do begin
				if (entries^^[i].init = init) and (entries^^[i].idle = idle) and (entries^^[i].idle_period = idle_period) and (entries^^[i].finish = finish) then begin
					found := true;
					leave;
				end;
			end;
			if not found then begin
				entry.init := init;
				entry.idle := idle;
				entry.idle_period := idle_period;
				entry.next_idle := TickCount;
				entry.finish := finish;
				startup_error := PtrAndHand(@entry, Handle(entries), SizeOf(entry));
				if startup_error = noErr then begin
					Inc(entries_count);
				end;
			end;
		end;
	end;
	
	procedure IdleStartup;
		var
			i : SInt32;
			tmp_hack: StartupIdleProc;
	begin
		current_time := TickCount;
		for i := 1 to entries_count do begin
			tmp_hack := entries^^[i].idle;
			if (tmp_hack <> NIL) and (current_time >= entries^^[i].next_idle) then begin
				entries^^[i].next_idle := current_time + entries^^[i].idle_period;
				tmp_hack;
			end;
		end;
		for i := 1 to max_idles do begin
			tmp_hack := idles[i];
			if (tmp_hack<> NIL) then begin
				tmp_hack;
				idles[i] := NIL;
			end;
		end;
	end;
	
	procedure InitStartup;
		var
			i : SInt32;
	begin
		entries := NIL;
		entries_count := 0;
		startup_error := noErr;
		max_idles := 0;
		for i := 1 to idles_max do begin
			idles[i] := NIL;
		end;
	end;
	
	function Startup(var msg: SInt16) : OSStatus;
		var
			i : SInt32;
			tmp_hack: StartupFinishProc;
			tmp_hack_init: StartupInitProc;
	begin
		msg := ord(SMT_Startup);
		i := 0;
		while (startup_error = noErr) and (i < entries_count) do begin
			i := i + 1;
			tmp_hack_init := entries^^[i].init;
			if tmp_hack_init <> NIL then begin
				msg := ord(SMT_Generic);
				startup_error := tmp_hack_init(msg);
			end;
		end;
		if startup_error <> noErr then begin
			i := i - 1;
			while i > 0 do begin
				tmp_hack := entries^^[i].finish;
				if tmp_hack <> NIL then begin
					tmp_hack;
				end;
				i := i - 1;
			end;
			MDisposeHandle(UnivHandle(entries));
			entries_count := 0;
		end;
		if startup_error = noErr then begin
			msg := ord(SMT_None);
		end;
		Startup := startup_error;
	end;
	
	procedure FinishStartup;
		var
			i : SInt32;
			tmp_hack: StartupFinishProc;
	begin
		if entries <> NIL then begin
			i := entries_count;
			while i > 0 do begin
				tmp_hack := entries^^[i].finish;
				if tmp_hack <> NIL then begin
					tmp_hack;
				end;
				i := i - 1;
			end;
			MDisposeHandle(UnivHandle(entries));
			entries_count := 0;
		end;
	end;

end.
