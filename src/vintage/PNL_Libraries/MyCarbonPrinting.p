UNIT MyCarbonPrinting;


{This file was found on Pascal Central. Many thanks to the author! }

INTERFACE








USES
	MacTypes,   PMDefinitions, StringTypes;
	
	

function InitializePrintingSupport : OSErr;
function HandlePageSetup : boolean;
function HandlePrintWindow(var printSettings : PMPrintSettings; jobTitle : String255) : boolean;
function ReadyPrinting(var printSettings : PMPrintSettings) : Rect;
procedure ReadyPrintingNoPageOpen(var printSettings : PMPrintSettings);
function PrintingOpenNextPage : Rect;
function PrintingClosePage : boolean;
function PrintingCloseDocument : boolean;


var
	g_PrintSession  : PMPrintSession;
  g_PageFormat    : PMPageFormat;
  g_PrintSettings : PMPrintSettings;


IMPLEMENTATION






USES UnitCarbonisation,CFBase,CFString,PMCore, PMApplication,
	Events, MacWindows, Dialogs, Fonts, QuickDraw,
	Devices, TextEdit,    MacMemory,  Scrap, ToolUtils,
	OSUtils,   Menus,  Lists, Processes,
	Resources, TextUtils, Controls,  Files,
	Script, Sound, Icons, ColorPicker, Folders,
	ControlDefinitions, GestaltEqu, MyTypes;



function InitializePrintingSupport : OSErr;
var
	iErr : OSErr;
begin
	iErr := PMCreateSession(g_PrintSession);
	iErr := PMCreatePageFormat(g_PageFormat);
 	if (iErr = noErr)
		then iErr := PMSessionDefaultPageFormat(g_PrintSession, g_PageFormat);
		
  iErr := PMCreatePrintSettings(g_PrintSettings);
  if (iErr = noErr)
    then iErr := PMSessionDefaultPrintSettings(g_PrintSession,g_PrintSettings);

	InitializePrintingSupport := iErr;
end;  { InitializePrintingSupport }



function HandlePageSetup : boolean;
var
	accepted : boolean;
	iErr : OSErr;
begin
	iErr := PMSessionPageSetupDialog(g_PrintSession, g_PageFormat, accepted);
	HandlePageSetup :=  accepted;
end;  { HandlePageSetup }




function HandlePrintWindow(var printSettings : PMPrintSettings; jobTitle : String255) : boolean;
var
	returnValue : boolean;
	iErr : OSErr;
	windowTitleRef : CFStringRef;
begin
	HandlePrintWindow := false;
	returnValue := false;
	printSettings := NIL;
	iErr := PMCreatePrintSettings(printSettings);
	if (iErr = 0)
		then iErr := PMSessionDefaultPrintSettings(g_PrintSession, printSettings);
	if (iErr <> 0)
		then begin
			Exit(HandlePrintWindow);
		end;
	returnValue := true;
	windowTitleRef := CFStringCreateWithPascalString(NIL, StringToStr255(jobTitle), kCFStringEncodingMacRoman);
	iErr := PMSetJobNameCFString(printSettings, windowTitleRef);
	CFRelease(CFTypeRef(windowTitleRef));
	iErr := PMSessionPrintDialog (g_PrintSession, printSettings, g_PageFormat, returnValue);
	HandlePrintWindow := returnValue;
end;  { HandlePrintWindow }



{ Opens the print job and page, sets the port correctly, returns the page rect }
function ReadyPrinting(var printSettings : PMPrintSettings) : Rect;
var
	iErr : OSErr;
	pageRect : Rect;
	myPMRect : PMRect;
	string1 : String255;
	printingContext : ptr;
	kPMGraphicsContextQuickdrawString : CFStringRef;
begin
	string1 := 'com.apple.graphicscontext.quickdraw';
	kPMGraphicsContextQuickdrawString := CFStringCreateWithPascalString(NIL, StringToStr255(string1), kCFStringEncodingMacRoman);
 	iErr := PMSessionBeginDocument (g_PrintSession, printSettings, g_PageFormat);
 	myPMRect.top := 0;
 	myPMRect.left := 0;
 	myPMRect.bottom := 200;
 	myPMRect.right := 200;
  iErr := PMSessionBeginPage(g_PrintSession, g_PageFormat, @myPMRect);
 	iErr := PMSessionGetGraphicsContext(g_PrintSession, kPMGraphicsContextQuickdrawString, printingContext);
	CFRelease(CFTypeRef(kPMGraphicsContextQuickdrawString));

  SetPort(GrafPtr(printingContext));
  pageRect := MyGetPortBounds(CGrafPtr(printingContext));

  ReadyPrinting := pageRect;
end;  { ReadyPrinting }




{ This opens the print job without opening a page }
procedure ReadyPrintingNoPageOpen(var printSettings : PMPrintSettings);
var
	iErr : OSErr;
	string1 : String255;
	kPMGraphicsContextQuickdrawString : CFStringRef;
begin
	string1 := 'com.apple.graphicscontext.quickdraw';
	kPMGraphicsContextQuickdrawString := CFStringCreateWithPascalString(NIL, StringToStr255(string1), kCFStringEncodingMacRoman);
 	iErr := PMSessionBeginDocument (g_PrintSession, printSettings, g_PageFormat);
end;  { ReadyPrintingNoPageOpen }




{ Opens a new page, then returns the drawing rect }
function PrintingOpenNextPage : Rect;
var
	iErr : OSErr;
	pageRect : Rect;
	myPMRect : PMRect;
	string1 : String255;
	printingContext : ptr;
	kPMGraphicsContextQuickdrawString : CFStringRef;
begin
	string1 := 'com.apple.graphicscontext.quickdraw';
	kPMGraphicsContextQuickdrawString := CFStringCreateWithPascalString(NIL, StringToStr255(string1), kCFStringEncodingMacRoman);
	myPMRect.top := 0;
	myPMRect.left := 0;
	myPMRect.bottom := 200;
	myPMRect.right := 200;
	iErr := PMSessionBeginPage(g_PrintSession, g_PageFormat, @myPMRect);
	iErr := PMSessionGetGraphicsContext(g_PrintSession, kPMGraphicsContextQuickdrawString, printingContext);
	CFRelease(CFTypeRef(kPMGraphicsContextQuickdrawString));

	SetPort(GrafPtr(printingContext));
	pageRect := MyGetPortBounds(CGrafPtr(printingContext));
	
	PrintingOpenNextPage := pageRect;
end;  { PrintingOpenNextPage }





function PrintingClosePage : boolean;
var
	iErr : OSErr;
begin
	iErr := PMSessionEndPage(g_PrintSession);
	PrintingClosePage := (iErr = noErr);
end;  { PrintingClosePage }





function PrintingCloseDocument : boolean;
var
	iErr : OSErr;
begin
 	iErr := PMSessionEndDocument(g_PrintSession);
	PrintingCloseDocument := (iErr = noErr);
end;  { PrintingCloseDocument }




end.  { MyCarbonPrinting }