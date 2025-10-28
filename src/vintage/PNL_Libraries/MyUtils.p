UNIT MyUtils;

INTERFACE



 uses
     Quickdraw , UnitDefCassio , TextUtils , Events , MacWindows , Sound , DateTimeUtils;



	procedure GetIndFont( resid: SInt16; index: SInt16; var font, size : SInt16);
	procedure GetMyFonts(ft : MyFontType; var font, size : SInt16);
	procedure SetMyFont(ft : MyFontType);
	function MyNumToString (n : SInt32) : String255;
	function NumToK(n : SInt32; extra : boolean) : String255;
	function NumToStr (n : SInt32) : String255;
	function UNumToStr( n : SInt32 ) : String255;
	function NN (n : SInt32; len : SInt16) : String255;
	function N2 (n : SInt32) : String255;


	function StrToNum (s : String255) : SInt32;
	procedure DotDotDot (var s : String255; var width: SInt16);
	function CountSICN( typ : OSType; id : SInt16 ) : SInt16;
	(* procedure PlotSICN (typ : OSType; id, index, v, h: SInt16); *)
	function LookupStrH (id : SInt16; match: String255) : String255;
	function LookupStrhNumber (id : SInt16; n : SInt32) : String255;
	function SendCharToIsDialogEvent (const er : EventRecord; cs : CharSet) : boolean;
	function GetVersionFromResFile: SInt32;


	procedure SafeDeviceLoop (drawingRgn : RgnHandle; drawingProc: DeviceLoopDrawingUPP; userData: SInt32; flags: DeviceLoopFlags);
	procedure SafeDeviceLoopRect (drawingRect : Rect; drawingProc: DeviceLoopDrawingUPP; userData: SInt32; flags: DeviceLoopFlags);
{ procedure drawingProc (depth: SInt16; deviceFlags: SInt16; targetDevice: GDHandle; item: SInt32); }
	procedure MakeRGBColor (red, green, blue: UInt16; var col : RGBColor);
	function IsExtension (const name, ext: String255) : boolean;
	function IsPrefix (const name, prefix: String255) : boolean;
{	function TPBTST(value : SInt32; bit : SInt16) : boolean;}
	procedure SetInvertHiliteMode;
	procedure HiliteInvertRect (r : Rect);
	procedure HiliteInvertRgn (r : RgnHandle);

	procedure HaveResources;
	function MapErr( err : OSStatus ) : OSErr;

	procedure AddOSErr( var err : OSErr; err2 : OSErr );
	procedure AddOSStatus( var err : OSStatus; err2 : OSStatus );


	function DateCouranteEnString : String255;
	function DateEnString(const whichDate : DateTimeRec) : String255;

  function BooleanXor(b1, b2 : boolean) : boolean;

	procedure IdentiteSurN(var N : SInt32);
	function FonctionTrue : boolean;
	function FonctionFalse : boolean;
	function MicrosecondesToSecondes(microTicks : UnsignedWide) : double;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    Scrap, QuickdrawText, OSUtils, ToolUtils, Resources, MacMemory, Processes, Folders
    , Fonts
{$IFC NOT(USE_PRELINK)}
    , UnitCarbonisation, MyStrings, MyQuickDraw, MyFonts, SNEvents, MyEvents, MyAssertions
     ;
{$ELSEC}
    ;
    {$I prelink/MyUtils.lk}
{$ENDC}


{END_USE_CLAUSE}






function DateEnString(const whichDate : DateTimeRec) : String255;
var s : String255;
begin
  with whichDate do
    s := NumEnStringAvecFormat(year,   4, '0') +
         NumEnStringAvecFormat(month,  2, '0') +
         NumEnStringAvecFormat(day,    2, '0') +
         NumEnStringAvecFormat(hour,   2, '0') +
         NumEnStringAvecFormat(minute, 2, '0') +
         NumEnStringAvecFormat(second, 2, '0');
  DateEnString := s;
end;


function DateCouranteEnString : String255;
var myDate : DateTimeRec;
begin
  GetTime(myDate);
  DateCouranteEnString := DateEnString(myDate);
end;




function BooleanXor(b1, b2 : boolean) : boolean;
begin
	BooleanXor := (b1 and not(b2)) or (b2 and not(b1));
end;





procedure IdentiteSurN(var N : SInt32);
begin
  {$UNUSED N}
end;

function FonctionTrue : boolean;
begin
	FonctionTrue := true;
end;

function FonctionFalse : boolean;
begin
	FonctionFalse := false;
end;



function MicrosecondesToSecondes(microTicks : UnsignedWide) : double;
var result : double;
begin
  result := 0.0;
  MicrosecondesToSecondes := microTicks.lo*0.000001 + microTicks.hi*4294.967296;
end;


	procedure SetInvertHiliteMode;
	var hiliteMode : ByteParameter;
	begin
	  hiliteMode := LMGetHiliteMode;
    BitClr(@hiliteMode,pHiliteBit);
    LMSetHiliteMode(hiliteMode);
	end;

	procedure HiliteInvertRect (r : Rect);
	begin
		SetInvertHiliteMode;
		InvertRect(r);
	end;

	procedure HiliteInvertRgn (r : RgnHandle);
	begin
		SetInvertHiliteMode;
		InvertRgn(r);
	end;
{
	function TPBTST(value : SInt32; bit : SInt16) : boolean;
	begin
		TPbtst := BTST(value, bit);
	end;
}
	procedure GetIndFont( resid: SInt16; index: SInt16; var font, size : SInt16);
		var
			s : String255;
			n : SInt32;
	begin
		s := ReadStringFromRessource( resid, index );
		font := MyGetFontNum( s );
		s := ReadStringFromRessource( resid, index + 1 );
		ChaineToLongint( s, n );
		size := n;
	end;

	procedure GetMyFonts(ft : MyFontType; var font, size : SInt16);
	begin
		GetIndFont( my_font_strh_id, 2*ord(ft) + 1, font, size );
	end;

	procedure SetMyFont(ft : MyFontType);
		var
			font, size : SInt16;
	begin
		GetMyFonts(ft, font, size);
		TextFont(font);
		TextSize(size);
	end;

	function IsExtension (const name, ext: String255) : boolean;
		var
			pn, pe: SInt16;
	begin
		if false then begin
			{IsExtension := IUEqualString(TPCopy(name, LENGTH_OF_STRING(name) - LENGTH_OF_STRING(ext) + 1, 255), ext) = 0;}
			 IsExtension := (TPCopy(name, LENGTH_OF_STRING(name) - LENGTH_OF_STRING(ext) + 1, 255) =  ext);
		end else begin
			IsExtension := false;
			if LENGTH_OF_STRING(name) >= LENGTH_OF_STRING(ext) then begin
				pn := LENGTH_OF_STRING(name) - LENGTH_OF_STRING(ext) + 1;
				pe := 1;
				while pe <= LENGTH_OF_STRING(ext) do begin
					if UpperCase(name[pn]) <> UpperCase(ext[pe]) then begin
						leave;
					end;
					pn := pn + 1;
					pe := pe + 1;
				end;
				IsExtension := pe > LENGTH_OF_STRING(ext);
			end;
		end;
	end;

	function IsPrefix (const name, prefix: String255) : boolean;
	begin
		{IsPrefix := (IUEqualString(TPCopy(name, 1, LENGTH_OF_STRING(prefix)), prefix) = 0;)}
		IsPrefix := (TPCopy(name, 1, LENGTH_OF_STRING(prefix)) = prefix);
	end;

	procedure MakeRGBColor (red, green, blue: UInt16; var col : RGBColor);
	begin
		col.red := red;
		col.green := green;
		col.blue := blue;
	end;

	procedure SafeDeviceLoop (drawingRgn : RgnHandle; drawingProc: DeviceLoopDrawingUPP; userData: SInt32; flags: DeviceLoopFlags);
	begin
		Assert( drawingProc <> NIL );

    DeviceLoop(drawingRgn, drawingProc, userData, flags);

	end;

	procedure SafeDeviceLoopRect (drawingRect : Rect; drawingProc: DeviceLoopDrawingUPP; userData: SInt32; flags: DeviceLoopFlags);
		var
			rgn: RgnHandle;
	begin
		rgn := NewRgn;
		RectRgn(rgn, drawingRect);
		SafeDeviceLoop(rgn, drawingProc, userData, flags);
		DisposeRgn(rgn);
	end;

	function GetVersionFromResFile: SInt32;
		var
			versh: VersRecHndl;
	begin
		GetVersionFromResFile := 0;
		versh := VersRecHndl(Get1Resource(MY_FOUR_CHAR_CODE('vers'), 1));
		if versh <> NIL then begin
			GetVersionFromResFile := SInt32(versh^^.numericVersion);
		end; (* if *)
	end;





	function MyNumToString (n : SInt32) : String255;
		var
			s, t : String255;
	begin
		if Abs(n) < 4096 then begin
			s := IntToStr(n)
		end else if Abs(n) < 4194304 then begin
			s := IntToStr(n div 1024);
			t := ReadStringFromRessource( 935, 2);
			s := Concat(s, t);
		end else begin
			t := ReadStringFromRessource( 935, 3);
			s := IntToStr(n div 1048576);
			s := Concat(s, t);
		end;
		MyNumToString := s;
	end;

	function NumToK(n : SInt32; extra : boolean) : String255;
		const
			K = 1024;
			M = 1048576;
		var
			f : SInt16;
			s, dot : String255;
	begin
		if (n < 1048576) and extra then begin
			n := n*1024;
			extra := false;
		end;
		if (n < K) then begin
			{ extra is false }
			s := IntToStr(n);
		end else begin
			{ n >= K }
			f := ord(extra);
			while n >= M do begin
				f := f + 1;
				n := n div K;
			end;
			{ K <= n < M } { Display n/1024 GetIndStr(935,f+2) }
			s := ReadStringFromRessource( 935, f+2);
			dot := ReadStringFromRessource( 935, 1);
			if n >= 1024000 then begin
				n := n div 1024;
				s := concat(NumToStr(n),s);
			end else if n >= 102400 then begin
				n := n*10 div 1024;
				s := concat(NumToStr(n div 10),dot,NN(n mod 10,1),s);
			end else if n >= 10240 then begin
				n := n*100 div 1024;
				s := concat(NumToStr(n div 100),dot,NN(n mod 100,2),s);
			end else begin
				n := n*1000 div 1024;
				s := concat(NumToStr(n div 1000),dot,NN(n mod 1000,3),s);
			end;
		end;
		NumToK := s;
	end;

	function NumToStr (n : SInt32) : String255;
		var
			s : String255;
	begin
		s := IntToStr(n);
		NumToStr := s;
	end;

	function UNumToStr( n : SInt32 ) : String255;
		var
			s : String255;
	begin
		s := chr(48 + (n mod 10 + 10 + (6 * ord(n < 0))) mod 10);
		n := BAND(BSR(n, 1), $7FFFFFFF) div 5;
		while n <> 0 do begin
			s := concat(chr( n mod 10 + 48 ),s);
			n := n div 10;
		end;
		UNumToStr := s;
	end;

	function NN (n : SInt32; len : SInt16) : String255;
		var
			s : String255;
	begin
		if len > 15 then begin
			len := 15;
		end;
		s := IntToStr(n);
		while LENGTH_OF_STRING(s) < len do begin
			s := concat('0', s);
		end;
		NN := s;
	end;

	function N2 (n : SInt32) : String255;
	begin
		N2 := NN(n, 2);
	end;


	function StrToNum (s : String255) : SInt32;
		var
			n : SInt32;
	begin
		ChaineToLongint(s, n);
		StrToNum := n;
	end;

	procedure DotDotDot (var s : String255; var width: SInt16);
		var
			maxwidth, len : SInt16;
	begin
		maxwidth := width;
		width := MyStringWidth(s);
		if width > maxwidth then begin
			width := width + CharWidth('É');
{$PUSH}
{$R-}
			len := LENGTH_OF_STRING(s);
			while (len > 0) and (width > maxwidth) do begin
				width := width - CharWidth(s[len]);
				len := len - 1;
			end;
			len := len + 1;
			SET_LENGTH_OF_STRING(s,len);
			s[len] := 'É';
{$POP}
		end;
	end;

	function CountSICN( typ : OSType; id : SInt16 ) : SInt16;
		var
			sh: Handle;
	begin
		sh := GetResource( typ, id );
		if sh = NIL then begin
			CountSICN := 0;
		end else begin
			CountSICN := GetHandleSize( sh ) div 32;
		end;
	end;

	(*
	procedure PlotSICN (typ : OSType; id, index, v, h: SInt16);
		var
			sh: Handle;
			bm: BitMap;
			r : Rect;
			gp : GrafPtr;
	begin
		sh := GetResource(typ, id);
		Assert( sh <> NIL );
		if sh <> NIL then begin
			HLock(sh);
			bm.baseAddr := Ptr(SInt32(sh^) + (index - 1) * 32);
			bm.rowBytes := 2;
			SetRect(r, h, v, h + 16, v + 16);
			bm.bounds := r;
			GetPort(gp);
			CopyBits(bm, gp^.portBits, r, r, srcCopy, NIL);
			HUnlock(sh);
			HPurge(sh);
		end;
	end;
	*)

	function LookupStrH (id : SInt16; match: String255) : String255;
		var
			t, s : String255;
			i : SInt16;
	begin
		t := '';
		i := 1;
		repeat
			s := ReadStringFromRessource( id, i);
			if s = match then begin
				t := ReadStringFromRessource( id, i + 1);
				leave;
			end;
			i := i + 2;
		until s = '';
		LookupStrH := t;
	end;

	function LookupStrhNumber (id : SInt16; n : SInt32) : String255;
		var
			s, t : String255;
	begin
		s := IntToStr(n);
		t := LookupStrH(id, s);
		if t = '' then begin
			t := s;
		end;
		LookupStrhNumber := t;
	end;

	function SendCharToIsDialogEvent (const er : EventRecord; cs: CharSet) : boolean;
		var
			ch : char;
	begin
		SendCharToIsDialogEvent := true;
		if EventIsKeyDown( er ) and not EventHasCommandKey( er ) then begin
			ch := EventChar( er );
			if not (ch in (cs + [tab, del, bs])) and DirtyKey(ch) then begin
				SendCharToIsDialogEvent := false;
			end;
		end;
	end;



	procedure HaveResources;
	begin
		if Get1Resource(MY_FOUR_CHAR_CODE('BNDL'), 128) = NIL then begin
			SysBeep(1);
			ExitToShell;
		end;
	end;

	function MapErr( err : OSStatus ) : OSErr;
	begin
		if (err < -32768) or (err > 32767) then begin
			err := -32767;
		end; (* if *)
		MapErr := err;
	end;


	procedure AddOSErr( var err : OSErr; err2 : OSErr );
	begin
		if err = noErr then begin
			err := err2;
		end;
	end;

	procedure AddOSStatus( var err : OSStatus; err2 : OSStatus );
	begin
		if err = noErr then begin
			err := err2;
		end;
	end;

end.
