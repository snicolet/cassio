UNIT MyQuickDraw;



INTERFACE


 USES UnitDefCassio , QuickDraw , Controls;






  procedure InitUnitMacExtras(debugageUnit : boolean);
	procedure InitMacintoshManagers;

	function MyNewCWindow( wStorage: UnivPtr; const boundsRect : Rect; const title: String255; visible: Boolean; procID: SInt16; behind: WindowRef; goAwayFlag: Boolean; refCon: SInt32 ): WindowRef;
	function GetWindowSize(window : WindowPtr) : Point;
	function WindowsHaveThickBorders(var epaisseurBorduresFenetres : SInt16) : boolean;
	{procedure ClipWindowStructFromWMPort(window : WindowPtr);}



  procedure SafeSetCursor(myCursor : CursHandle);
  function RegionEstVide(whichRegion : RgnHandle) : boolean;
  function SameRect(rect1,rect2 : rect) : boolean;
	procedure InvalidateWindow(whichWindow : WindowPtr);
	procedure GetPortSize(var width, height : SInt16);


	procedure CalculateControlRects(whichWindow : WindowPtr; var hbarrect, vbarrect, gbrect : rect);
	function TextHeight(wptr : WindowPtr) : SInt16;
	procedure CenterString(h, v, w : SInt16; s : String255);

	procedure DrawStringPourGNUPascal(const s : String255);
	function StringWidthPourGNUPascal(const s : String255): SInt16;


  procedure MyEraseRect(const (*var*) r : Rect);
  procedure MyEraseRectWithColor(const (*var*) r : Rect; couleurCmd : SInt32; whichPattern : pattern; fonctionAppelante : String255);
  procedure MyEraseRectWithRGBColor(const (*var*) r : Rect; couleur : RGBColor);


(* 	procedure PlotSmallIcon(r : Rect; hdl : Handle; index : SInt16); *)
(* procedure Plot16ColorSmallIcon(r : rect; h : UnivHandle); *)


	function ProfondeurMainDevice : SInt16;
	function EstUnAscenseurAvecDoubleScroll(theScroller : ControlHandle; var contourAscenseurRect, regionGriseeRect : rect; var estHorizontal : boolean) : boolean;
	function SmartScrollEstInstalle(theScroller : ControlHandle; var proportion : fixed) : boolean;


  procedure WriteNumAt(s : String255; num : SInt32; h,v : SInt32);
  procedure WriteStringAndNumEnSeparantLesMilliersAt(s : String255; num : SInt32; h,v : SInt32);
  procedure WriteStringAndBigNumEnSeparantLesMilliersAt(s : String255; milliards,num : SInt32; h,v : SInt32);
  procedure WriteStringAt(s : String255; h,v : SInt32);
  procedure WriteStringAtWithoutErase(s : String255; h,v : SInt32);
  procedure WriteReelAt(unreel : double_t; h,v : SInt32);
  procedure WriteStringAndReelAt(s : String255; unreel : double_t; h,v : SInt32);
  procedure WriteStringAndBoolAt(s : String255; bool : boolean; h,v : SInt32);


  function MyGetPicture(picID: SInt16) : PicHandle;
  function GetPicFrameOfPicture(thePict : PicHandle) : Rect;


IMPLEMENTATION


USES MyFonts,MacWindows,UnitCarbonisation,MyStrings,UnitOth0,UnitRapport,MyMathUtils;

function CouleurCmdToRGBColor(couleurCmd : SInt16) : RGBColor;     external;



  const
    unit_MacExtras_initialisee : boolean = false;



  var unit_MacExtras_debuggage : boolean;

  procedure InitUnitMacExtras(debugageUnit : boolean);
  begin
    if not(unit_MacExtras_initialisee) then
      begin
        gWindowsHaveThickBorders := WindowsHaveThickBorders(gEpaisseurBorduresFenetres);
        GetClassicalFontsID;

        unit_MacExtras_initialisee := true;
        unit_MacExtras_debuggage := debugageUnit;
      end;
  end;

	procedure InitMacintoshManagers;
	begin
		if (TEFromScrap = noErr) then DoNothing;
		InitCursor;
		FlushEvents(everyEvent - diskEvt, 0);
	end;



  function MyNewCWindow( wStorage: UnivPtr; const boundsRect : Rect; const title: String255; visible: Boolean; procID: SInt16; behind: WindowRef; goAwayFlag: Boolean; refCon: SInt32 ): WindowRef;
  begin
    MyNewCWindow :=  NewCWindow( wStorage, boundsRect, StringToStr255(title), visible, procID, behind, goAwayFlag, refCon );
  end;



	function GetWindowSize(window : WindowPtr) : Point;
	var result : Point;
	begin
	  result.h := -1;
	  result.v := -1;
	  if window <> NIL then
	    with GetWindowPortRect(window) do
	      begin
	        result.h := right - left;
	        result.v := bottom - top;
	      end;
	  GetWindowSize := result;
	end;

	function WindowsHaveThickBorders(var epaisseurBorduresFenetres : SInt16) : boolean;
		var
			structureRect, contentRect : rect;
			aWindow : WindowPtr;
			aRect : rect;
			oldport : GrafPtr;
	begin
		GetPort(oldport);
		SetRect(aRect, 31000, 31000, 31150, 31150);
		aWindow := MyNewCWindow(NIL, aRect, '', true, zoomDocProc, NIL, true, 0);
		structureRect := GetWindowStructRect(aWindow);
		contentRect   := GetWindowContentRect(aWindow);
		DisposeWindow(aWindow);
		SetPort(oldport);
		epaisseurBorduresFenetres := (structureRect.right - structureRect.left) -(contentRect.right - contentRect.left);
		WindowsHaveThickBorders := (epaisseurBorduresFenetres >= 10);
	end;

 (*
	procedure ClipWindowStructFromWMPort(window : WindowPtr);
		var
			oldClipRgn : RgnHandle;
			RegionCouverteParRegion : RgnHandle;
			oldport : GrafPtr;
			windowManagerPort : GrafPtr;
	begin
		GetPort(oldport);
		GetWMgrPort(windowManagerPort);
		SetPort(windowManagerPort);
		oldclipRgn := NewRgn;
		GetClip(oldClipRgn);

		RegionCouverteParRegion := NewRgn;
		(window, RegionCouverteParRegion);
		InvertRgn(RegionCouverteParRegion);
		DisposeRgn(RegionCouverteParRegion);

		DisposeRgn(oldClipRgn);
		SetPort(oldport);
	end;
	*)





procedure SafeSetCursor(myCursor : CursHandle);
var cursorData : Cursor;
begin
  if (myCursor = NIL) or (myCursor^ = NIL)
    then InitCursor
    else
      begin
        cursorData := myCursor^^;
        SetCursor(cursorData);

        if (@myCursor = @watch) then
          begin
          end;
      end;
end;

function RegionEstVide(whichRegion : RgnHandle) : boolean;
begin
  if (whichRegion = NIL)
    then RegionEstVide := true
    else RegionEstVide := EmptyRgn(whichRegion);
end;


function SameRect(rect1,rect2 : rect) : boolean;
begin
  SameRect := (rect1.left   = rect2.left) and
              (rect1.right  = rect2.right) and
              (rect1.top    = rect2.top) and
              (rect1.bottom = rect2.bottom);
end;


procedure InvalidateWindow(whichWindow : WindowPtr);
	var
		oldport : GrafPtr;
begin
	if whichWindow <> NIL then
		begin
			GetPort(oldport);
			SetPortByWindow(whichWindow);
			InvalRect(QDGetPortBound);
			SetPort(oldport);
		end;
end;

procedure GetPortSize(var width, height : SInt16);
begin
	with QDGetPortBound do
		begin
			width := right - left;
			height := bottom - top;
		end;
end;


procedure CalculateControlRects;
begin
	with GetWindowPortRect(whichWindow) do
		begin

			gbrect.top := bottom - scbarwidth;
			gbrect.left := right - scbarwidth;
			gbrect.bottom := bottom;
			gbrect.right := right;

			hbarrect := gbrect;
			hbarrect.left := left;
			hbarrect.right := gbrect.left;

			vbarrect := gbrect;
			vbarrect.top := top;
			vbarrect.bottom := gbrect.top;

		end;
end;


function TextHeight(wptr : WindowPtr) : SInt16;
	var
		InfosPolice : fontinfo;
		oldport : GrafPtr;
begin
	GetPort(oldport);
	SetPortByWindow(wptr);
	GetFontInfo(InfosPolice);
	with InfosPolice do
		TextHeight := ascent + descent + leading;
	SetPort(oldport);
end;

procedure CenterString(h, v, w : SInt16; s : String255);
begin
	w := w - MyStringWidth(s);
	if w < 0 then
		w := 0;
	Moveto(h + (w div 2), v);
	MyDrawString(s);
end;


procedure DrawStringPourGNUPascal(const s : String255);
var aux : Str255;
begin
  aux := StringToStr255(s);
  DrawString(aux);
end;


function StringWidthPourGNUPascal(const s : String255) : SInt16;
var aux : Str255;
begin
  aux := StringToStr255(s);
  StringWidthPourGNUPascal := StringWidth(aux);
end;


procedure MyEraseRect(const (*var*) r : Rect);
var portRect, myRect : rect;
begin


  myRect := r;

  portRect := QDGetPortBound;

  if myRect.left   < portRect.left    then myRect.left   := portRect.left   ;
  if myRect.top    < portRect.top     then myRect.top    := portRect.top    ;
  if myRect.right  > portRect.right   then myRect.right  := portRect.right  ;
  if myRect.bottom > portRect.bottom  then myRect.bottom := portRect.bottom ;

  EraseRect(myRect);

end;


procedure MyEraseRectWithColor(const (*var*) r : Rect; couleurCmd : SInt32; whichPattern : pattern; fonctionAppelante : String255);
var portRect, myRect : rect;
begin

  Discard6(r, couleurCmd, whichPattern, fonctionAppelante, portRect , myRect);


  (*
  myRect := r;

  portRect := QDGetPortBound;

  if myRect.left   < portRect.left    then myRect.left   := portRect.left   ;
  if myRect.top    < portRect.top     then myRect.top    := portRect.top    ;
  if myRect.right  > portRect.right   then myRect.right  := portRect.right  ;
  if myRect.bottom > portRect.bottom  then myRect.bottom := portRect.bottom ;

  RGBForeColor(CouleurCmdToRGBColor(couleurCmd));
  RGBBackColor(CouleurCmdToRGBColor(BlancCmd));

  FillRect(myRect,whichPattern);

  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
  *)


end;


procedure MyEraseRectWithRGBColor(const (*var*) r : Rect; couleur : RGBColor);
var portRect, myRect : rect;
begin

  myRect := r;

  portRect := QDGetPortBound;

  if myRect.left   < portRect.left    then myRect.left   := portRect.left   ;
  if myRect.top    < portRect.top     then myRect.top    := portRect.top    ;
  if myRect.right  > portRect.right   then myRect.right  := portRect.right  ;
  if myRect.bottom > portRect.bottom  then myRect.bottom := portRect.bottom ;

  RGBForeColor(couleur);
  RGBBackColor(couleur);

  FillRect(myRect,blackPattern);

  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);

end;


(*
{Dessine la petite icone pointee par hdl(16*16*1) en position r.}
{ L'index commence a 0 (s'il est superieur, hdl doit etre une 'SICN'). }
procedure PlotSmallIcon(r : Rect; hdl : Handle; index : SInt16);
	var
		bit : BitMap;
begin
	HLockHi(hdl);
	with bit do
		begin
			SetRect(bounds, 0, 0, 16, 16);
			rowBytes := 2;
			baseAddr := hdl^;
			baseAddr := Ptr(Ord4(baseAddr) +(index * 32));
		end;
	CopyBits(bit, qdThePort^.portBits, bit.bounds, r, qdThePort^.pnMode, NIL);
end;
*)

(*
{dessine la petite icone 16 couleur pointee par hdl(16*16) en position r.}
procedure Plot16ColorSmallIcon(r : rect; h : UnivHandle);
	type
		bmHandle = ^bmPtr;
		bmPtr = ^BitMap;
	var
		pix : PixMapHandle;
		gDevice : GDHandle;
		oldpm : CTabHandle;
begin
	pix := NewPixMap;
	HLock(Handle(pix));
	with pix^^ do
		begin
			baseAddr := h^;
			rowBytes := $8008;  {16*4 = 64 bits = 8 octets}
			SetRect(bounds, 0, 0, 16, 16);
			gDevice := GetGDevice;
			oldPm := pmTable;
			pmTable := gDevice^^.gdPMap^^.pmTable;
		end;
	CopyBits(bmHandle(pix)^^, qdThePort^.portBits, pix^^.bounds, r, qdThePort^.pnMode, NIL);
	pix^^.pmTable := oldpm;
	DisposePixMap(pix);
end;
*)





function ProfondeurMainDevice : SInt16;
	var
		mainDev : GDHandle;
		depth : SInt16;
begin
	mainDev := GetMainDevice;
	depth := mainDev^^.gdPMap^^.pixelSize;
	ProfondeurMainDevice := depth;
end;

function EstUnAscenseurAvecDoubleScroll(theScroller : ControlHandle; var contourAscenseurRect, regionGriseeRect : rect; var estHorizontal : boolean) : boolean;
	var
		testPoint : point;
		oldport : GrafPtr;
		offset : SInt16;
		ignoreRectPtr : RectPtr;
begin
	EstUnAscenseurAvecDoubleScroll := false;

	if (theScroller <> NIL) then
		begin
			GetPort(oldport);
			SetPortByWindow(GetControlOwner(theScroller));
			ignoreRectPtr := GetControlBounds(theScroller,contourAscenseurRect);
			with contourAscenseurRect do
				if right - left > bottom - top then
					begin
						EstHorizontal := true;
						testpoint.v := (contourAscenseurRect.top + contourAscenseurRect.bottom) div 2;
						testpoint.h := contourAscenseurRect.left + 24;
						if testControl(theScroller, testpoint) = kControlDownButtonPart then
							begin
								EstUnAscenseurAvecDoubleScroll := true;
								offset := 32;
							end
						else
							begin
								EstUnAscenseurAvecDoubleScroll := false;
								offset := 16;
							end;
						regionGriseeRect := contourAscenseurRect;
						regionGriseeRect.left := regionGriseeRect.left + offset;
						regionGriseeRect.right := regionGriseeRect.right - offset;
					end
				else
					begin
						EstHorizontal := false;
						testpoint.h := (contourAscenseurRect.left + contourAscenseurRect.right) div 2;
						testpoint.v := contourAscenseurRect.top + 24;
						if testControl(theScroller, testpoint) = kControlDownButtonPart then
							begin
								EstUnAscenseurAvecDoubleScroll := true;
								offset := 32;
							end
						else
							begin
								EstUnAscenseurAvecDoubleScroll := false;
								offset := 16;
							end;
						regionGriseeRect := contourAscenseurRect;
						regionGriseeRect.top := regionGriseeRect.top + offset;
						regionGriseeRect.bottom := regionGriseeRect.bottom - offset;
					end;
			SetPort(oldport);
		end;
end;


function SmartScrollEstInstalle(theScroller : ControlHandle; var proportion : fixed) : boolean;
	var
		propFract : Fract;
begin
  {$UNUSED propFract, theScroller, proportion}
  SmartScrollEstInstalle := false;
end;








function MyMakeRect(left, top, right, bottom : SInt32) : Rect;
	var
		result : Rect;
begin
	SetRect(result, left, top, right, bottom);
	MyMakeRect := result;
end;




procedure WriteNumAt(s : String255; num : SInt32; h,v : SInt32);
var lignerect : rect;
    s1 : String255;
begin
  s1 := NumEnString(num);
  s := s + s1+'   ';
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;


procedure WriteStringAndNumEnSeparantLesMilliersAt(s : String255; num : SInt32; h,v : SInt32);
var lignerect : rect;
    s1 : String255;
begin
  s1 := NumEnString(num);
  s := s + SeparerLesChiffresParTrois(s1) + '   ';
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;

procedure WriteStringAndBigNumEnSeparantLesMilliersAt(s : String255; milliards,num : SInt32; h,v : SInt32);
var lignerect : rect;
    s1 : String255;
begin
  s1 := BigNumEnString(milliards,num);
  s := s + SeparerLesChiffresParTrois(s1) + '   ';
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;


procedure WriteStringAt(s : String255; h,v : SInt32);
var lignerect : rect;
begin
  s := s + CharToString(' ');
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;


procedure WriteStringAtWithoutErase(s : String255; h,v : SInt32);
  var lignerect : rect;
  begin
    s := s + CharToString(' ');
    SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
    Moveto(h,v);
    MyDrawString(s);
  end;


procedure WriteReelAt(unreel : double_t; h,v : SInt32);
var lignerect : rect;
begin
  SetRect(ligneRect,h,v-9,h+30,v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(ReelEnString(unreel));
end;


procedure WriteStringAndReelAt(s : String255; unreel : double_t; h,v : SInt32);
var lignerect : rect;
begin
  s := s + ReelEnString(unreel)+'   ';
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;

procedure WriteStringAndBoolAt(s : String255; bool : boolean; h,v : SInt32);
var lignerect : rect;
begin
  if bool
    then s := s + ' TRUE   '
    else s := s + ' FALSE  ';
  SetRect(lignerect,h,v-9,h+MyStringWidth(s),v+2);
  MyEraseRect(lignerect);
  MyEraseRectWithColor(ligneRect,MarineCmd,blackPattern,'');
  Moveto(h,v);
  MyDrawString(s);
end;


function GetPicFrameOfPicture(thePict : PicHandle) : Rect;
var frame : Rect;
begin

  if (thePict = NIL) or (thePict^ = NIL)
    then
      begin
        frame.left   := 0;
        frame.top    := 0;
        frame.right  := 0;
        frame.bottom := 0;
      end
    else
      begin

        frame  := thePict^^.picFrame;

        {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
        MY_SWAP_INTEGER( @frame.left);
        MY_SWAP_INTEGER( @frame.top);
        MY_SWAP_INTEGER( @frame.right);
        MY_SWAP_INTEGER( @frame.bottom);
        {$ENDC}
      end;

  GetPicFrameOfPicture := frame;

end;



function MyGetPicture(picID: SInt16) : PicHandle;
var frame : Rect;
    theHandle : PicHandle;
    taille : SInt16;
begin


  theHandle := GetPicture(picID);

  if (theHandle <> NIL) and (theHandle^ <> NIL) then
    begin

      frame  := theHandle^^.picFrame;
      taille := theHandle^^.picSize;

      {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
      MY_SWAP_INTEGER( @taille);
      MY_SWAP_INTEGER( @frame.left);
      MY_SWAP_INTEGER( @frame.top);
      MY_SWAP_INTEGER( @frame.right);
      MY_SWAP_INTEGER( @frame.bottom);
      {$ENDC}

      {
      WritelnNumDansRapport('size = ',taille);
      WritelnNumDansRapport('left = ',frame.left);
      WritelnNumDansRapport('top = ',frame.top);
      WritelnNumDansRapport('right = ',frame.right);
      WritelnNumDansRapport('bottom = ',frame.bottom);

      WritelnStringDansRapport('size = '+hexa(taille));
      WritelnStringDansRapport('left = '+hexa(frame.left));
      WritelnStringDansRapport('top = '+hexa(frame.top));
      WritelnStringDansRapport('right = '+hexa(frame.right));
      WritelnStringDansRapport('bottom = '+hexa(frame.bottom));
      }
    end;

  MyGetPicture := theHandle;
end;



END.










































