UNIT UnitOffScreenGraphics;


INTERFACE







 USES QDOffScreen , UnitDefCassio;


 (* Handles the creation of an offscreen pixmap.  Depth is assumed to be that of the…
   current gDevice.  If the allocation fails (low memory, etc.) we quit to Finder. *)


procedure CreateOffScreenPixMap(var theRect : rect; var offScreenGWorld : CGrafPtr);
procedure KillOffscreenPixMap(var wasPort : CGrafPtr; killColorTable : boolean);

function CreateTempOffScreenWorld(var theRect : rect; var offScreenGWorld : GWorldPtr) : OSErr;
procedure KillTempOffscreenWorld(var offScreenGWorld : GWorldPtr);

procedure DumpWorkToScreen(sourceRect,targetRect : rect; offScreenWork,targetWindow : CGrafPtr);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    Timer, MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitCarbonisation, UnitSound, MyQuickDraw ;
{$ELSEC}
    ;
    {$I prelink/OffScreenGraphics.lk}
{$ENDC}


{END_USE_CLAUSE}



var gThisGDevice : GDHandle	;


procedure CreateOffScreenPixMap(var theRect : rect; var offScreenGWorld : CGrafPtr);
var
  oldDevice : GDHandle;
  oldWindowPortPtr : CGrafPtr;
  quickDrawErr : QDErr;
  GWorldPixMapHdl : PixMapHandle;
  lockPixResult : boolean;
begin

  GetGWorld(oldWindowPortPtr, oldDevice);

  quickDrawErr := NewGWorld(offScreenGWorld, 0, theRect, NIL, NIL, 0 );

  if ((offScreenGWorld = NIL) | (quickDrawErr <> noErr)) then
    begin
      KillTempOffscreenWorld(offScreenGWorld);
      exit(CreateOffScreenPixMap);
    end;

  SetGWorld(offScreenGWorld, NIL);
  GWorldPixMapHdl := GetGWorldPixMap(offScreenGWorld);
  lockPixResult := LockPixels(GWorldPixMapHdl);
  if not (lockPixResult) then
    begin
      KillTempOffscreenWorld(offScreenGWorld);
      SetGWorld(oldWindowPortPtr, oldDevice);
      exit(CreateOffScreenPixMap);
    end;

  MyEraseRect(MyGetPortBounds(offScreenGWorld));
  MyEraseRectWithColor(MyGetPortBounds(offScreenGWorld),OrangeCmd,blackPattern,'');

  SetGWorld(oldWindowPortPtr, oldDevice);

end;


{
procedure CreateOffScreenPixMap(var theRect : rect; var offScreen : CGrafPtr);
var
	thisColorTable : CTabHandle;
	oldDevice : GDHandle;
	newCGrafPtr : CGrafPtr;
	theseBits : Ptr;
	sizeOfOff, offRowBytes : SInt32;
	theErr : OSErr;
	thisDepth : SInt16;
	oldPort : grafPtr;
begin
  GetPort(oldPort);
	gThisGDevice := GetMainDevice;
	oldDevice := GetGDevice;
	SetGDevice(gThisGDevice);
	newCGrafPtr := NIL;
	newCGrafPtr := CGrafPtr(AllocateMemoryPtrClear(sizeof(CGrafPort)));
	if (newCGrafPtr <> NIL) then
	begin
		OpenCPort(newCGrafPtr);
		thisDepth := newCGrafPtr^.portPixMap^^.pixelSize;
		offRowBytes := ((SInt32(thisDepth)*SInt32(theRect.right - theRect.left)+15) DIV 16)*2;
		sizeOfOff := SInt32(theRect.bottom - theRect.top) * offRowBytes;
		OffsetRect(theRect, -theRect.left, -theRect.top);
		theseBits := AllocateMemoryPtr(sizeOfOff);
		if (theseBits <> NIL) then
		begin
			newCGrafPtr^.portPixMap^^.baseAddr := theseBits;
			newCGrafPtr^.portPixMap^^.rowBytes := SInt16(offRowBytes) + $8000;
			newCGrafPtr^.portPixMap^^.bounds := theRect;
			thisColorTable := gThisGDevice^^.gdPMap^^.pmTable;
			theErr := HandToHand(Handle(thisColorTable));
			newCGrafPtr^.portPixMap^^.pmTable := thisColorTable;
			ClipRect(theRect);
			RectRgn(newCGrafPtr^.visRgn, theRect);
			ForeColor(blackColor);
			BackColor(whiteColor);
			MyEraseRect(theRect);
		end
		else
		begin
			CloseCPort(newCGrafPtr);
			DisposeMemoryPtr(Ptr(newCGrafPtr));
			newCGrafPtr := NIL;
			WritelnDansRapport('theseBits = NIL dans CreateOffScreenPixMap !!');
		end
	end
	else
		begin
		  WritelnDansRapport('newCGrafPtr = NIL dans CreateOffScreenPixMap !!');
		end;

	offScreen := newCGrafPtr;
	SetGDevice(oldDevice);
	SetPort(oldPort);
end;
}

procedure KillOffscreenPixMap(var wasPort : CGrafPtr; killColorTable : boolean);
begin {$UNUSED killColorTable}
  KillTempOffscreenWorld(wasPort);
end;

(*
procedure KillOffscreenPixMap(var wasPort : CGrafPtr; killColorTable : boolean);
{var aux : SInt32;
    s : String255;}
begin
  if (wasPort <> NIL) then
    begin
      {aux := GetHandleSize(Handle(wasPort^.portPixMap^^.pmTable));
      NumEnString(aux,s);
      WritelnDansRapport('taille de la table des couleurs = '+s);}

      if killColorTable & (wasPort^.portPixMap^^.pmTable <> NIL) &
         (wasPort^.portPixMap^^.pmTable <> GetGDevice^^.gdPMap^^.pmTable) then
        begin
          DisposeMemoryHdl(Handle(wasPort^.portPixMap^^.pmTable));
          wasPort^.portPixMap^^.pmTable := NIL;
        end;

      if wasPort^.portPixMap^^.baseAddr <> NIL then
        begin
          DisposeMemoryPtr(Ptr(wasPort^.portPixMap^^.baseAddr));
          wasPort^.portPixMap^^.baseAddr := NIL;
        end;

		  CloseCPort(wasPort);
		  DisposeMemoryPtr(Ptr(wasPort));
		  wasPort := NIL;
		end;
end;
*)

function CreateTempOffScreenWorld(var theRect : rect; var offScreenGWorld : GWorldPtr) : OSErr;
var
  oldDevice : GDHandle;
  oldWindowPortPtr : CGrafPtr;
  quickDrawErr : QDErr;
  GWorldPixMapHdl : PixMapHandle;
  lockPixResult : boolean;
  tailleTempDispo,grow : Size;
begin

  GetGWorld(oldWindowPortPtr, oldDevice);

  {compactons la memoire temporaire}
  tailleTempDispo := TempMaxMem(grow);
  {avant de d'essayer de creer notre buffer dedans}
  quickDrawErr := NewGWorld(offScreenGWorld, 0, theRect, NIL, NIL, useTempMem {0});

  if ((offScreenGWorld = NIL) | (quickDrawErr <> noErr)) then
    begin
      KillTempOffscreenWorld(offScreenGWorld);
      if (quickDrawErr <>  noErr)
        then CreateTempOffScreenWorld := quickDrawErr
        else CreateTempOffScreenWorld := -1;
      exit(CreateTempOffScreenWorld);
    end;

  SetGWorld(offScreenGWorld, NIL);
  GWorldPixMapHdl := GetGWorldPixMap(offScreenGWorld);
  lockPixResult := LockPixels(GWorldPixMapHdl);
  if not (lockPixResult) then
    begin
      KillTempOffscreenWorld(offScreenGWorld);
      SetGWorld(oldWindowPortPtr, oldDevice);
      CreateTempOffScreenWorld := -1;
      exit(CreateTempOffScreenWorld);
    end;

  MyEraseRect(MyGetPortBounds(offScreenGWorld));
  MyEraseRectWithColor(MyGetPortBounds(offScreenGWorld),OrangeCmd,blackPattern,'');
  UnlockPixels(GWorldPixMapHdl);

  SetGWorld(oldWindowPortPtr, oldDevice);

  CreateTempOffScreenWorld := NoErr;
end;


procedure KillTempOffscreenWorld(var offScreenGWorld : GWorldPtr);
var GWorldPixMapHdl : PixMapHandle;
begin
  if offScreenGWorld <> NIL then
    begin
		  GWorldPixMapHdl := GetGWorldPixMap(offScreenGWorld);
		  UnlockPixels(GWorldPixMapHdl);
		  DisposeGWorld(offScreenGWorld);
		  offScreenGWorld := NIL;
		end;
end;



procedure DumpWorkToScreen(sourceRect,targetRect : rect; offScreenWork,targetWindow : CGrafPtr);
begin

	CopyBits(GetPortBitMapForCopyBits(OffScreenWork)^ ,
			     GetPortBitMapForCopyBits(targetWindow)^ ,
			     sourceRect, targetRect, {ditherCopy +} srcCopy, NIL);
end;



END.
