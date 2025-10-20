UNIT UnitCampFire;



INTERFACE







 USES Palettes , QDOffScreen;



procedure DoCampFire;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Processes, OSUtils, fp, QuickdrawText, MacMemory, MacWindows, UnitDefCassio
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw
    , UnitRapport, UnitServicesDialogs, UnitCarbonisation, UnitServicesMemoire, MyFonts, SNEvents, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/CampFire.lk}
{$ENDC}


{END_USE_CLAUSE}












{This program is a Pascal port of CAMP FIRE 1.1 by Brian Stone.}
{Ported by Ingemar Ragnemalm 1996.}

{Possible improvements:}
{• Change the calculations to work with 127..-128 rather than 0..255.}
{That would simplify and speed up the code.}
{The BASE# pointers should really be pointers to bytes (Ptr), to avoid the}
{overhead of looking up in arrays. The best solution I can think of is to}
{use *signed* bytes, normal Ptrs, so all calculations are made with the range}
{127..-128 in mind rather than 0..255. Well, let's fix that for another}
{version.}
{• Move as many global variables to be local. (I have moved some.)}
{That makes the code more readable.}



	type
		ByteArr = packed array[0..400000] of UInt8;
		ByteArrPtr = ^ByteArr;
{ Global rectangles.}
	var
		WindowRect, OffscreenRect : Rect;
		gThisGDevice : GDHandle	;
		oldEnglishID : SInt16;

		gOldPalette : PaletteHandle;



{ Graphics world vars, and PixMap stuff.}
		saveWorld : GWorldPtr;
		saveDevice : GDHandle;
		MyWindow : CWindowPtr;
		OffscreenWorldp : GWorldPtr;
		CampFireErr : QDErr;

{ Pix Map stuff}
		OffscreenPixMapH, windowPixMapH : PixMapHandle;
		OffscreenPixMapP, windowPixMapP : PixMapPtr;
		endbyte : Ptr;
		CampFireBase : ByteArrPtr;
		CampFireRowByte, CampFirestart : SInt32;

{ Misc Vars}
		Resx, Resy: SInt32;
		MaxBlockSize: SInt32;
		resfileID: SInt16;

{ Vars used for Frame Rate Calculation}
		StartTime, EndTime, TotalTime: SInt32;
		finalTicks: SInt32;
		Frames: SInt32; {was double}
		FPS: SInt16;


(****************************)

{ Function RangedRdm from THINK Reference.}
	function Rnd (min, max: SInt32) : SInt32;
		var
			qdRdm: SInt32;
			range: SInt32;
(* assume that min is less than max *)
	begin
		qdRdm := (SInt32(Random) and  $0000ffff);		{Avoid negative values while keeping the full range.}
		range := max - min;
		Rnd := (qdRdm * range) div 65536 + min; 	(* now 0 <= t <= range *)
	end; {Rnd}

(********************)


procedure RetablitColorTable;
begin
 	RestoreDeviceClut(NIL);
	PaintBehind(NIL,GetGrayRgn);
	DrawMenuBar;
end; {RetablitColorTable}



procedure CleanUp;
begin
	if OffscreenWorldP <> NIL then
		DisposeMemoryPtr(Ptr(OffscreenWorldP));
	if MyWindow <> NIL then
		DisposeWindow(WindowPtr(MyWindow));

  {
  SysBeep(0);
  AttendFrappeClavier;
  }
  RetablitColorTable;

	{gThisGDevice^^.gdPMap^^.pmTable := DeviceClut;}
end; {CleanUp}

(****************************************)

	procedure Init;
		var
			WindowResX, WindowResY: SInt32;
			i, j : SInt16;
{ Palette and ColorTable stuff}
			CampFireClut: CTabHandle;
			CampFirePal : PaletteHandle;
{ Init the Macintosh environment}
	begin

		oldEnglishID := MyGetFontNum('Old English Text');
    if oldEnglishID < 0 then oldEnglishID := TimesID;

		gThisGDevice := GetMainDevice;
	  SetGDevice(gThisGDevice);
	  {DeviceClut := gThisGDevice^^.gdPMap^^.pmTable;}
	  if FrontWindow <> NIL
	    then gOldPalette := GetPalette(FrontWindow)
	    else gOldPalette := NIL;

	{ Get the window palette from the resource file.}
		CampFirePal := GetNewPalette(128);
	{ Create a color table for the offscreen world.}
		CampFireClut := GetCTable(8);
	{ Give the color table a unique CTseed.}
		CampFireClut^^.ctSeed := GetCTSeed;
	{ Copy the palette into the color table.}
		Palette2CTab(CampFirePal, CampFireClut);

	{ Set Up the Window}
		WindowResX := GetScreenBounds.right;
		WindowResY := GetScreenBounds.bottom;

		SetRect(WindowRect, (WindowResX - Resx) div 2, (WindowResY - Resy) div 2, (WindowResX - Resx) div 2 + Resx, (WindowResY - Resy) div 2 + Resy);
		MyWindow := CWindowPtr(MyNewCWindow(NIL, WindowRect, 'Flame!', TRUE, noGrowDocProc, NIL, FALSE, 0));
		SelectWindow(WindowPtr(MyWindow));
		SetPortByWindow(WindowPtr(MyWindow));
	{ Get the Graphics World and Device associated with the window}
		GetGWorld(saveWorld, saveDevice);
	{ Set a pointer to the windows PixMap}
		windowPixMapH := GetGWorldPixMap(saveWorld);
		HLockHi(Handle(windowPixMapH));
		if LockPixels(windowPixMapH) then DoNothing;
		windowPixMapP := windowPixMapH^;
	{ Set the palette to the window}
		SetPalette(WindowPtr(MyWindow), CampFirePal, true);
		ActivatePalette(WindowPtr(MyWindow));

		{
		windowPixMapH^^.pmTable := gThisGDevice^^.gdPMap^^.pmTable;
		}


	{ Set Up Offscreen GWorld}
		SetRect(OffscreenRect, 0, 0, Resx, Resy);
		CampFireErr := NewGWorld(OffscreenWorldP, 0, OffscreenRect, CampFireClut, NIL, 0);


    AlerteSimple('Pas assez de mémoire pour Campfire !!');


		if CampFireErr <> 0 then
			begin
			  AlerteSimple('Pas assez de mémoire pour Campfire !!');
			  AttendFrappeClavier;
			  ExitToShell;
			end;

		SetGWorld(OffscreenWorldP, NIL);
	{ Set a pointer to the Offscreen World's PixMap}
		OffscreenPixMapH := GetGWorldPixMap(OffscreenWorldP);
		HLockHi(Handle(OffscreenPixMapH));
		if LockPixels(OffscreenPixMapH) then DoNothing;
		OffscreenPixMapP := OffscreenPixMapH^;
	{ Set a pionter to the first byte of the ofscreen PixMap}
		CampFireBase := ByteArrPtr(OffscreenPixMapH^^.baseAddr);
		CampFireRowByte := (OffscreenPixMapH^^.rowBytes and $3fff);





	{ Set every pixle of the offscreen PixMap to colorID 3.}
		for j := 0 to Resy - 1 do
			for i := 0 to Resx - 1 do
				CampFireBase^[CampFireRowByte * j + i] := 3;




	end; {Init}



function GetPointColorInFire(x,y : SInt32) : SInt32;
var theBASE : ByteArrPtr;
begin
  theBASE := @CampFireBase^[CampFireRowByte * y];
  GetPointColorInFire := theBASE^[x];
end;

var seuilAllumage : SInt32;

(*******************************)
procedure WriteTextInFire(const s : String255; x,y : SInt32);
var color : SInt32;
begin
  SetGWorld(OffscreenWorldP, saveDevice);

  color := GetPointColorInFire(x+15,y+3);

  {WritelnNumDansRapport('',color);}


	{
	if (Frames mod 15) = 0 then
	  begin
	    seuilAllumage := seuilAllumage +1;
	    if seuilAllumage > 255 then seuilAllumage := -255;
	  end;

	seuilAllumage := 60;
	}

	if color > 82
	  then
	    begin
	      ForeColor(bluecolor);
				Moveto(x, y);
				TextFont(oldEnglishID);
				TextSize(48);
				MyDrawString(s);
		  end else
	if color > 65
	  then
	    begin
	      ForeColor(yellowcolor);
				Moveto(x, y);
				TextFont(oldEnglishID);
				TextSize(48);
				MyDrawString(s);
		  end else
	if color > 55
	  then
	    begin
	      ForeColor(redcolor);
				Moveto(x, y);
				TextFont(oldEnglishID);
				TextSize(48);
				MyDrawString(s);
		  end;

	{
  ForeColor(RedColor);
	Moveto(10, 30);
	TextFont(GenevaID);
	TextSize(18);
	MyDrawString('  '+NumEnString(color));
	MyDrawString('  '+NumEnString(seuilAllumage));
	}


	ForeColor(BlackColor);
end;


(*******************************)

	procedure CampFireInit;
{ This function draws in the last two rows of the PixMap}
{ with some Random colors to start the flame.}
{ The averaging then takes over and "pulls" these colors}
{ upwards creating the fire effect.}
		var
			blocksize, RndNum: SInt32;
			left, right, halfresx: Real;
			Maxcolor, Mincolor: SInt32;
			tmpBASE2, tmpBASE3, tmpBASE4: Ptr;
			{BASE1,} BASE2, BASE3, BASE4{, BASE5}: ByteArrPtr;
			k : SInt16;
			i : SInt32;
			randomcolor: SInt16;
	begin
{ Initilize the pointers to the last two rows.}
		BASE2 := @CampFireBase^[CampFireRowByte * (Resy - 3)];
		BASE3 := @CampFireBase^[CampFireRowByte * (Resy - 2)];
		BASE4 := @CampFireBase^[CampFireRowByte * (Resy - 1)];
	{ Init the information required to choose the colors. }
		halfresx := Resx / 2;
		Maxcolor := 255;
		Mincolor := 180;

	{ Draw the last two rows}
		RndNum := Rnd(5, 60);
		i := 0;
		while i < Resx do
	{ This IF statement gives the fire a "pointed" look.}
			begin
				if i < halfresx then
		   { We are on the left half of the PixMap}
					begin
						left := (halfresx - (halfresx - i)) / halfresx + 0.5;
						if left > 1 then
							left := 1;
{$PUSH}
{$R-}
						randomcolor := Rnd(MyTrunc(left * Mincolor), MyTrunc(left * Maxcolor));
{$POP}
					end
				else 		   { We are on the right half of the PixMap}
					begin
						right := (halfresx + (halfresx - i)) / halfresx + 0.5;
						if right > 1 then
							right := 1;
{$PUSH}
{$R-}
						randomcolor := Rnd(MyTrunc(right * MinColor), MyTrunc(right * Maxcolor));
{$POP}
					end;

				tmpBASE2 := Ptr(BASE2);
				tmpBASE3 := Ptr(BASE3);
				tmpBASE4 := Ptr(BASE4);
		{ Fill in a randomly sized block of color}
				blocksize := Rnd(1, MaxBlockSize);
				if ((blocksize + i) > Resx) then
					blocksize := Resx - i;
				for k := 0 to blocksize - 1 do
					begin
{$PUSH}
{$R-}
						tmpBASE2^ := randomcolor;
						tmpBASE3^ := randomcolor;
						tmpBASE4^ := randomcolor;
{$POP}
						tmpBASE2 := Ptr(SInt32(tmpBASE2) + 1);
						tmpBASE3 := Ptr(SInt32(tmpBASE3) + 1);
						tmpBASE4 := Ptr(SInt32(tmpBASE4) + 1);
					end;

		{ Increment the PixMap pointers.}
				BASE2 := ByteArrPtr(SInt32(BASE2) + RndNum);
				BASE3 := ByteArrPtr(SInt32(BASE3) + RndNum);
				BASE4 := ByteArrPtr(SInt32(BASE4) + RndNum);

				i := i + RndNum;
			end;
	end; {CampFireInit}

(*********************************)

	procedure BuildFlame;
	{ This function averages each pixel in this manner}
	{ *T*}
	{ *P*  Where pixels marked "P" are averaged together}
	{ PPP  and the result is stored in pixel "T".}

	{ Stagger the starting pixel.}
		var
			averagecolor: SInt16;
			BASE1, BASE2, BASE3, BASE4, BASE5: ByteArrPtr;
	begin
		inc(CampFireStart);
		if CampFireStart = 10 then
			CampFireStart := 0;

	{ Set all pointers to their first pixel}
		BASE1 := @CampFireBase^[CampFireRowByte * 0 + CampFireStart];
		BASE2 := @CampFireBase^[CampFireRowByte * 1 + CampFireStart];
		BASE3 := @CampFireBase^[CampFireRowByte * 2 + CampFireStart];
		BASE4 := @CampFireBase^[CampFireRowByte * 2 - 1 + CampFireStart];
		BASE5 := @CampFireBase^[CampFireRowByte * 2 + 1 + CampFireStart];

		endbyte := @CampFireBase^[CampFireRowByte * (Resy - 3) + Resx];
		while SInt32(BASE1) < SInt32(endbyte) do
		{ Calculate the average color.}
			begin
{Note! I use byte-arrays to access the pixels, but this really needs some}
{optimizing. As it is now, it isn't as fast as the C version. It still is}
{fairly fast, but I think it takes some more to access data byte-wise in}
{Pascal.}
{As a comfort, a 16-bit version wouldn't need any of these workarounds.}
				averagecolor := BSr(BASE2^[0] + BASE3^[0] + BASE4^[0] + BASE5^[0],2) - 5;
		{ Make sure the color's don't go below the lowest color}
				if averagecolor < 3 then
					averagecolor := 3;
		{ Set the color of the target pixel}
{$PUSH}
{$R-}
				BASE1^[0] := averagecolor;
{$POP}
		{ Increment all pointers to the next pixels to be used.}
		{BASE4 = BASE5;}
				BASE1 := ByteArrPtr(SInt32(BASE1) + 10);
				BASE2 := ByteArrPtr(SInt32(BASE2) + 10);
				BASE3 := ByteArrPtr(SInt32(BASE3) + 10);
				BASE4 := ByteArrPtr(SInt32(BASE4) + 10);
				BASE5 := ByteArrPtr(SInt32(BASE5) + 10);
			end;
	end; {BuildFlame}

(********************************)

	procedure CampFire;
	const verticalSpeed = 3;
	var ytext,yRand : SInt16;
{ Draw the base of the Camp Fire}
	begin
		CampFireInit;

	{ Build the flame of the Camp Fire}
		BuildFlame;



	{ Scroll the Camp Fire up a few pixels to help it out.}

		MoveMemory(@CampFireBase^[CampFireRowByte * verticalSpeed], @CampFireBase^[0], CampFireRowByte * (Resy - 1) - CampFireRowByte * verticalSpeed);

  { Write the text in superposition}
    ytext := 230 - ((TickCount div 8) mod 190);
    yRand := 0;
    WriteTextInFire('C',  80, +10 + ytext + Rnd(-yRand,yRand));
    WriteTextInFire('a', 120,   0 + ytext + Rnd(-yRand,yRand));
    WriteTextInFire('s', 150,   0 + ytext + Rnd(-yRand,yRand));
    WriteTextInFire('s', 180,   0 + ytext + Rnd(-yRand,yRand));
    WriteTextInFire('i', 212,   5 + ytext + Rnd(-yRand,yRand));
    WriteTextInFire('o', 238, +10 + ytext + Rnd(-yRand,yRand));

	{Set back the port/device! Otherwise the CopyBits might not work. Actually, it didn't work on my 68k Macs.}
		SetGWorld(saveWorld, saveDevice);

	{ Copy the image to the screen}
	   CopyBits(BitMapPtr(OffscreenPixMapP)^, BitMapPtr(windowPixMapP)^, OffscreenRect, OffscreenRect, srcCopy, NIL);

	end; {CampFire}


(***************************)
(***    Camp Fire        ***)
(***************************)
procedure DoCampFire;
{ Set image resolution}
begin
	Resx := 340;
	Resy := 650;
	MaxBlockSize := Resx div 20 + 5;

	{ Init Application}
	Init;

	{ Init Frame Rate calculations}
	Frames := 0;
	StartTime := TickCount;

	{ Begin Simulation //	}
	while not(Button) do
		begin
			CampFire;
			Frames := Frames + 1;
		end;

	{ Calculate Frame Rate, and display.	}
	SetGWorld(saveWorld, saveDevice);
	EndTime := TickCount;
	TotalTime := (EndTime - StartTime) div 60;
	FPS := Frames div TotalTime;

	(*
	Moveto(10, 50);
	ForeColor(greenColor);

	MyDrawString(CharToString(FPS));
	Delay(90, finalTicks);
	*)

	{ Dont forget to wash behind your ears.}
	CleanUp;
end;


END.
