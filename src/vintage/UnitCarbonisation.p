UNIT UnitCarbonisation;


INTERFACE


{$ifc not defined REDEFINIR_ACCESSEURS }
{$definec REDEFINIR_ACCESSEURS false}
{$endc}

{$ifc not defined ACCESSOR_CALLS_ARE_FUNCTIONS }
{$definec ACCESSOR_CALLS_ARE_FUNCTIONS false}
{$endc}



 USES Menus , Scrap , UnitDefCassio , Events , OSUtils , MacMemory , QuickDraw , QuickdrawText ,
     Resources , MacWindows , Fonts , GestaltEqu , TextUtils , ToolUtils ,
     Files , Aliases , AppleEvents , Controls , ControlDefinitions , Dialogs ,
     TextEdit , Sound , ConditionalMacros , MacHelp;


{Menus}
procedure MyCheckItem(theMenu : MenuRef; item: SInt16; checked: BOOLEAN);
procedure MyDisableItem(theMenu : MenuRef; item: MenuItemIndex);
procedure MyEnableItem(theMenu : MenuRef; item: MenuItemIndex);
function  MyCountMenuItems(theMenu : MenuRef) : UInt16;

{Scrap}
function GetScrapFlavors(var count : UInt32; var flavors : String255) : OSStatus;
function GetScrapSize(flavor : ScrapFlavorType) : SInt32;
function MyGetScrap(destination: Handle; flavorType : ScrapFlavorType; VAR offset : SInt32) : SInt32;
function MyZeroScrap : OSStatus;
function MyPutScrap(sourceBufferByteCount : SInt32; flavorType: ScrapFlavorType; sourceBuffer: UnivPtr) : OSStatus;


{Some of the following stuff comes from the "CarbonStuff.p" unit
 on Pascal Central. Many thanks to the (unkown) author! }


function HiWord(x : SInt32) : SInt16;
function LoWord(x : SInt32) : SInt16;




procedure InvalRect(r : rect);
procedure InvalRgn(r : RgnHandle);
procedure ValidRect(r : rect);
procedure ValidRgn(r : RgnHandle);




function qdThePort : CGrafPtr;
procedure FlushWindow(theWindow : WindowRef);





function MyIsControlVisible(inControl : ControlRef) : BOOLEAN;
function MyValidWindowRect(window : WindowRef; {CONST}VAR bounds: Rect) : OSStatus;
function MyGetRegionRect(theRegion : RgnHandle) : rect;
function MyGetNextWindow(theWindow : WindowRef) : WindowRef;
function MyGetRootControl(theWindow : WindowRef) : ControlRef;
function GetWindowStructRect(theWindow : WindowRef) : rect;
function GetWindowContentRect(theWindow : WindowRef) : rect;
function GetWindowVisibleRegion(theWindow : WindowRef; visible : RgnHandle) : RgnHandle;

procedure GetDialogTextSelection(dlg : DialogPtr; var selStart,selEnd : SInt16);
function MyGetPortBounds(port: CGrafPtr) : Rect;
function QDGetPortBound : rect;

function GetScreenBounds : rect;
function GetWindowPortRect(window : WindowPtr) : rect;
function GetDialogPortRect(dialog : DialogPtr) : rect;
procedure SetPortByWindow(window : WindowPtr);
procedure SetPortByDialog(dialog : DialogPtr);

{TextEdit protection}
function TEGetTextLength(text : TEHandle) : SInt32;
function TEGetViewRect(text : TEHandle) : rect;
function TEGetDestRect(text : TEHandle) : rect;
procedure TESetViewRect(text : TEHandle; theRect : rect);
procedure TESetDestRect(text : TEHandle; theRect : rect);



procedure IUDatePString(dateTime: SInt32; longFlag: ByteParameter; VAR result : Str255; intlHandle : Handle);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}















Uses
	Devices, DateTimeUtils;


procedure MyCheckItem(theMenu : MenuRef; item: SInt16; checked: BOOLEAN);
begin
  CheckMenuItem(theMenu,item,checked);
end;


procedure MyDisableItem(theMenu : MenuRef; item: MenuItemIndex);
begin
  if (theMenu <> NIL)
    then DisableMenuItem(theMenu,item);
end;


procedure MyEnableItem(theMenu : MenuRef; item: MenuItemIndex);
begin
  if (theMenu <> NIL) then
    EnableMenuItem(theMenu,item);
end;

function MyCountMenuItems(theMenu : MenuRef) : UInt16;
begin
  if (theMenu <> NIL)
    then MyCountMenuItems := CountMenuItems(theMenu)
    else MyCountMenuItems := 0;
end;

function FourCharCodeToString(code : FourCharCode) : String255;
var result : String255;
begin
  result := '';

  result := Char(code and 255) + result;
  code := code shr 8;
  result := Char(code and 255) + result;
  code := code shr 8;
  result := Char(code and 255) + result;
  code := code shr 8;
  result :=  Char(code and 255) + result;
  code := code shr 8;

  FourCharCodeToString := result;
end;


function GetScrapFlavors(var count : UInt32; var flavors : String255) : OSStatus;
var scrap : ScrapRef;
    err : OSStatus;
    flavorsArray : array [0..100] of ScrapFlavorInfo;
    i : SInt32;
begin
  flavors := '';
  count := 0;

  err := GetCurrentScrap(scrap);
  if err = NoErr then
    begin
      err := GetScrapFlavorCount(scrap, count);
      if (err = NoErr) and (count > 0) then
        begin
          if (count > 100) then count := 100;
          err := GetScrapFlavorInfoList(scrap, count, @flavorsArray[0]);
          if (err = NoErr) and (count > 0) then
            begin
              for i := 0 to count - 1 do
                begin
                  if (i > 0) then flavors := flavors + ',';

                  flavors := flavors + FourCharCodeToString(flavorsArray[i].flavorType);
                end;
            end;
        end;
    end;

  GetScrapFlavors := err;
end;



function GetScrapSize(flavor : ScrapFlavorType) : SInt32;
var scrap : ScrapRef;
    err : OSStatus;
    flavorFlags: ScrapFlavorFlags;
    byteCount: Size;
begin
  err := GetCurrentScrap(scrap);
  if err = NoErr then
    begin
		  err := GetScrapFlavorFlags(scrap,flavor,flavorFlags);
		  if (err = NoErr) then {Il y a des donnees de type flavorType dans le presse-papier}
		    begin
		      {on recupere la taille}
		      err := GetScrapFlavorSize(scrap,flavor,byteCount);
		    end;
		end;
  {WritelnNumDansRapport('dans GetScrapSize, err = ',err);}
  if (err <> NoErr)
    then GetScrapSize := 0
    else GetScrapSize := byteCount;
end;


{ MyGetScrap :
 MyGetScrap va chercher dans le presse-papier global les donnees de type flavorType,
 et les met dans le handle destination, qui est agrandi si necessaire.
 La fonction renvoie la taille des donnes de type flavorType dans le presse-papier,
 et est  < 0 si en cas d'echec
 }
function MyGetScrap(destination: Handle; flavorType: ScrapFlavorType; VAR offset: SInt32) : SInt32;
var scrap : ScrapRef;
    err : OSStatus;
    flavorFlags : ScrapFlavorFlags;
    byteCount : Size;
    state : SInt8;
begin {$UNUSED offset}
  err := GetCurrentScrap(scrap);
  if err = NoErr then
    begin
		  err := GetScrapFlavorFlags(scrap,flavorType,flavorFlags);
		  if (err = NoErr) then {Il y a des donnees de type flavorType dans le presse-papier}
		    begin
		      {on recupere la taille}
		      err := GetScrapFlavorSize(scrap,flavorType,byteCount);

		      if (err = NoErr) and (byteCount > 0) then
		        begin
		          {peut-etre faut-il redimensionner le handle de destination}
		          if (byteCount > GetHandleSize(destination)) then
		            begin
		              SetHandleSize(destination, byteCount);
		              err := MemError;
		            end;

		          {on recupere les donnees}
		          if (err = NoErr) then
		            begin
		              state := HGetState(destination);
		              HLock(destination);
		              err := GetScrapFlavorData(scrap,flavorType,byteCount,destination^);
		              HSetState(destination,state);
		            end;
		        end;
		    end;
		end;
  {WritelnNumDansRapport('dans MyGetScrap, err = ',err);}
  if (err <> NoErr)
    then MyGetScrap := -1
    else MyGetScrap := byteCount;
end;


function MyZeroScrap : OSStatus;
begin
  MyZeroScrap := ClearCurrentScrap;
end;


function MyPutScrap(sourceBufferByteCount: SInt32; flavorType: ScrapFlavorType; sourceBuffer: UnivPtr) : OSStatus;
var scrap : ScrapRef;
    err : OSStatus;
begin
  err := GetCurrentScrap(scrap);
  if (err = NoErr) then
    err := PutScrapFlavor(scrap,flavorType,kScrapFlavorMaskNone,sourceBufferByteCount,sourceBuffer);
  {WritelnNumDansRapport('dans MyPutScrap, err = ',err);}
  MyPutScrap := err;
end;




function HiWord(x : SInt32) : SInt16;
begin
	x := BSr(x, 16);
	HiWord := BitAnd(x, $FFFF);
end;

function LoWord(x : SInt32) : SInt16;
begin
	LoWord := BitAnd(x, $FFFF);
end;


procedure InvalRect(r : rect);
var err : OSErr;
begin
	err := InvalWindowRect(GetWindowFromPort(qdThePort),r);
end;

procedure InvalRgn(r : RgnHandle);
var err : OSErr;
begin
	err := InvalWindowRgn(GetWindowFromPort(qdThePort),r);
end;


procedure ValidRect(r : rect);
var err : OSErr;
begin
	err := ValidWindowRect(GetWindowFromPort(qdThePort),r);
end;

procedure ValidRgn(r : RgnHandle);
var err : OSErr;
begin
	err := ValidWindowRgn(GetWindowFromPort(qdThePort),r);
end;




function GetScreenBounds : rect;
var theScreenBits : BitMap;
		ignore : BitMapPtr;
begin
	ignore := GetQDGlobalsScreenBits(theScreenBits);
	GetScreenBounds := theScreenBits.Bounds;
end;


function MyMakeRect(left, top, right, bottom : SInt32) : Rect;
	var
		result : Rect;
begin
	SetRect(result, left, top, right, bottom);
	MyMakeRect := result;
end;


function GetWindowPortRect(window : WindowPtr) : rect;
begin
  if (window = NIL)
    then GetWindowPortRect := MyMakeRect(40,40,40,40)
    else GetWindowPortRect := MyGetPortBounds(GetWindowPort(window));
end;


function GetDialogPortRect(dialog : DialogPtr) : rect;
begin
  GetDialogPortRect := MyGetPortBounds(GetDialogPort(dialog));
end;



function qdThePort : CGrafPtr;
begin
	qdThePort := GetQDGlobalsThePort;
end;


procedure FlushWindow(theWindow : WindowRef);
begin
  if (QDIsPortBuffered(GetWindowPort(theWindow))) then
    QDFlushPortBuffer(GetWindowPort(theWindow), NIL);
end;





function MyIsControlVisible(inControl : ControlRef) : BOOLEAN;
begin
	MyIsControlVisible := IsControlVisible(inControl);
end;

function MyValidWindowRect(window : WindowRef; {CONST}VAR bounds: Rect) : OSStatus;
{ I do it this way to avoid any problems with multiple definition of}
{ ValidWindowRect}
begin
	MyValidWindowRect := ValidWindowRect(window,bounds);
end;

function MyGetRegionRect(theregion : RgnHandle) : rect;
var theRect : rect;
begin
	MyGetRegionRect := GetRegionBounds(theregion,theRect)^;
end;

function MyGetNextWindow(theWindow : WindowRef) : WindowRef;
begin
  MyGetNextWindow := GetNextWindow(theWindow);
end;

function MyGetRootControl(theWindow : WindowRef) : ControlRef;
var outControl : ControlRef;
begin
  if GetRootControl(theWindow, outControl) = NoErr
    then MyGetRootControl := outControl
    else MyGetRootControl := NIL;
end;

function GetWindowStructRect(theWindow : WindowRef) : rect;
var outRect : rect;
begin
  if GetWindowBounds(theWindow, kWindowStructureRgn, outRect) = NoErr
    then GetWindowStructRect := outRect
    else GetWindowStructRect := MyMakeRect(0,0,0,0);
end;


function GetWindowContentRect(theWindow : WindowRef) : rect;
var outRect : rect;
begin
  if GetWindowBounds(theWindow, kWindowContentRgn, outRect) = NoErr
    then GetWindowContentRect := outRect
    else GetWindowContentRect := MyMakeRect(0,0,0,0);
end;

function GetWindowVisibleRegion(theWindow : WindowRef;visible : RgnHandle) : RgnHandle;
begin
  GetWindowVisibleRegion := GetPortVisibleRegion(GetWindowPort(theWindow), visible);
end;



procedure GetDialogTextSelection(dlg : DialogPtr; var selStart,selEnd : SInt16);
var theText : TEHandle;
begin
	theText := GetDialogTextEditHandle(dlg);
	selStart := theText^^.selStart;
	selEnd := theText^^.selEnd;
end;


function MyGetPortBounds(port: CGrafPtr) : Rect;
var arect : rect;
		ignore : RectPtr;
begin
	ignore := GetPortBounds(CGrafPtr(port),arect);
	MyGetPortBounds := arect;
end;

function QDGetPortBound : rect;
begin
  QDGetPortBound := MyGetPortBounds(qdThePort)
end;

procedure SetPortByWindow(window : WindowPtr);
begin
  SetPort(GrafPtr(GetWindowPort(window)));
end;

procedure SetPortByDialog(dialog : DialogPtr);
begin
  SetPort(GrafPtr(GetDialogPort(dialog)));
end;


function MyGetPortBitMapForCopyBits(port: CGrafPtr) : BitMap;
begin
	MyGetPortBitMapForCopyBits := GetPortBitMapForCopyBits(port)^;
end;




procedure IUDatePString(dateTime: SInt32; longFlag: ByteParameter; VAR result : Str255; intlHandle : Handle);
begin
	DateString(dateTime, longFlag, result,intlHandle);
end;


function TEGetTextLength(text : TEHandle) : SInt32;
begin
  if (text = NIL)
    then TEGetTextLength := 0
    else TEGetTextLength := text^^.TELength;
end;

function TEGetViewRect(text : TEHandle) : rect;
begin
  if (text = NIL)
    then TEGetViewRect := MyMakeRect(0,0,-1,-1)
    else TEGetViewRect := text^^.viewRect;
end;

function TEGetDestRect(text : TEHandle) : rect;
begin
  if (text = NIL)
    then TEGetDestRect := MyMakeRect(0,0,-1,-1)
    else TEGetDestRect := text^^.destRect;
end;

procedure TESetViewRect(text : TEHandle; theRect : rect);
begin
  if (text <> NIL)
    then text^^.viewRect := theRect;
end;

procedure TESetDestRect(text : TEHandle; theRect : rect);
begin
  if (text <> NIL)
    then text^^.destRect := theRect;
end;


END.
