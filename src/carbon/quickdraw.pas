UNIT quickdraw;


INTERFACE

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  Classes,
  SysUtils,
  Process,
  Connect,
  BasicTypes,
  BasicMemory,
  BasicString,
  BasicTime,
  BasicMath,
  BasicFiles,
  BasicHashing,
  BasicCharSet,
  QuickDrawTypes;



// Initialisation and termination
procedure InitQuickDraw(var carbon : Task);
procedure ReleaseQuickDraw;

// Time functions
function Milliseconds() : SInt64;
function Tickcount() : SInt64;

// Sound
procedure SysBeep(duration : SInt16);

// Mouse
function GetMouse() : Point;
function GetMouse2() : Point;

// Windows
function MakeWindow() : WindowPtr;
function NewWindow(bounds : Rect; title : String255; visible : boolean; behind: WindowPtr; goAwayFlag : boolean) : WindowPtr;

procedure SetWindowTitle(window : WindowPtr; title : String255);
procedure SetWindowVisibility(window : WindowPtr; visible : boolean);
procedure SetWindowGeometry(window : WindowPtr; where : Point; width, height : SInt32);
function GetWindowTitle(window : WindowPtr) : String255;

procedure SetPort(whichPort : GrafPtr);
procedure GetPort(var whichPort : GrafPtr);


// Window comparisons
operator = (w : WindowPtr; n : NoneType) b : boolean;
operator = (w1, w2 : WindowPtr) b : boolean;

// File dialogs
function OpenFileDialog(prompt, directory, filter : AnsiString) : AnsiString;

// Ressources
function ReadStringFromRessource(stringListID, index : SInt16) : String255;

// Alerts
procedure AlerteDouble(texte,explication : String255);

// Misc
function QDRandom() : SInt64;
function QDEcho(s : AnsiString) : AnsiString;

// Point and Rect
function MakePoint(h,v : SInt32) : Point;
function MakeRect(top, left, bottom, right : SInt32) : Rect;
function PointToStr(loc : Point) : AnsiString;
function RectToStr(r : Rect) : AnsiString;


IMPLEMENTATION


uses quickdrawcommunications;



var start          : SInt64;              // milliseconds at the start of the program
    gMouseData :
        record
           mouseLoc : Point ;            // mouse position
           when     : SInt64 ;           // date in milliseconds
        end;
    getOpenFileDialogData :
        record
           filePath : AnsiString;        // file path
        end;




// InitQuickDraw() : Initialisation of the Quickdraw unit

procedure InitQuickDraw(var carbon : Task);
begin
    StartQuickdrawServer(carbon);

    gMouseData.mouseLoc.h := 0;
    gMouseData.mouseLoc.v := 0;
    gMouseData.when       := -1000;
    
    RandomizeTimer;
end;



// ReleaseQuickDraw() : Termination of the Quickdraw unit

procedure ReleaseQuickDraw;
begin
    StopQuickDrawServer();
end;



// MyUrlEncode() : encode space, quotes and newline caracters in the given string
// into their url-encoding equivalents. Sometimes useful when exchanging strings
// with our server since the protocol is a textual, line by line protocol.

function MyUrlEncode(s : AnsiString) : AnsiString;
begin
    s := StringReplace( s , ' ' , '%20' , [rfReplaceAll] );
    s := StringReplace( s , '"' , '%22' , [rfReplaceAll] );
    s := StringReplace( s , '''', '%27' , [rfReplaceAll] );
    s := StringReplace( s , #10 , '%0A' , [rfReplaceAll] );   // linefeed
    result := s;
end;


// MyUrlDecode() : reverse of MyUrlEncode()

function MyUrlDecode(s : AnsiString) : AnsiString;
begin
    s := StringReplace( s , '%0A' , #10  , [rfReplaceAll] );   // linefeed
    s := StringReplace( s , '%27' , '''' , [rfReplaceAll] );
    s := StringReplace( s , '%22' , '"'  , [rfReplaceAll] );
    s := StringReplace( s , '%20' , ' '  , [rfReplaceAll] );
    result := s;
end;




// Milliseconds() : get the number of milliseconds since the start of the program

function Milliseconds() : SInt64;
begin
   result := GetTickCount64() - start;
end;



// Tickcount() : get the number of ticks (1/60 of second) since the start of the program

function Tickcount() : SInt64;
begin
   result := Milliseconds() * 60 div 1000;
end;


// SysBeep() : play the system beep, if available

procedure SysBeep(duration : SInt16);
begin
   system.writeln('BEEEEEEEEEEEEEP');
   Beep();
end;


// InterpretGetMouseAnswer() : parsing the mouse position from the get-mouse answer

procedure InterpretGetMouseAnswer(var line : AnsiString; value : Pointer);
var parts: TStringArray;
begin
    parts                   := line.Split(' ', '"', '"', 5, TStringSplitOptions.ExcludeEmpty);
    gMouseData.mouseLoc.h := strToInt64(parts[3]);
    gMouseData.mouseLoc.v := strToInt64(parts[4]);
end;


// GetMouse() : return the position of the mouse in global coordinates of the main screen

function GetMouse() : Point;
begin
    if (Milliseconds() - gMouseData.when >= 30) then
    begin
        gMouseData.when := Milliseconds();
        SendCommand('get-mouse', @InterpretGetMouseAnswer, NIL);
    end;

   result := gMouseData.mouseLoc;
end;



// GetMouse2() : return the position of the mouse. This is a buzy waiting
// function which takes about 0.13 millisecond to answer.

function GetMouse2() : Point;
begin
    result.h := -1;
    result.v := -1;
    WaitFunctionReturn('get-mouse', @POINT__, @result);
end;


// MakeWindow() : reserve memory for a new window, initializing it to None

function MakeWindow() : WindowPtr;
begin
    result.name := 'None';
end;


// Operator = to compare a WindowPtr to None

operator = (w : WindowPtr; n : NoneType) b : boolean;
begin
    b := (w.name = '') or (sysutils.UpperCase(w.name) = 'NONE');
end;


// Operator = to compare two WindowPtr

operator = (w1, w2 : WindowPtr) b : boolean;
begin
    b := (w1.name = w2.name);
end;


// NewWindow() : create a new window

function NewWindow(bounds : Rect; title : String255; visible : boolean; behind: WindowPtr; goAwayFlag : boolean) : WindowPtr;
var name : AnsiString;
begin
   result := MakeWindow();

   // creating the window
   name := 'window-' + IntToStr(NewMagicCookie());
   WaitFunctionReturn('new-window name=' + name, @WINDOW__, @result);

   if (result <> None) and (result.name = name) then
   begin
      with bounds do
         SetWindowGeometry(result, MakePoint(left, top), right - left, bottom - top);
      SetWindowTitle(result, title);
      SetWindowVisibility(result, visible);
   end;
end;


// SetWindowTitle() : set the title of a window

procedure SetWindowTitle(window : WindowPtr; title : String255);
var command : AnsiString;
begin
   if window <> None then 
   begin
      command := 'set-window-title name=^0 title=^1';
      command := ReplaceParameters(command, window.name, title);
      SendCommand(command);
   end;
end;


// GetWindowTitle() : get the title of a window

function GetWindowTitle(window : WindowPtr) : String255;
var command, res : AnsiString;
begin
   res := '';
   
   command := 'get-window-title name=' + window.name;
   WaitFunctionReturn(command, @STRING__, @res);

   result := res;
end;


// SetWindowVisibility() : show/hide a window, depending on the visible flag

procedure SetWindowVisibility(window : WindowPtr; visible : boolean);
var command : AnsiString;
begin
   if window <> None then 
   begin
      command := 'set-window-visible name=^0 visible=^1';
      command := ReplaceParameters(command, window.name, BoolToStr(visible));
      SendCommand(command);
      
      if visible then 
      begin
         command := 'show-window name=^0';
         command := ReplaceParameters(command, window.name);
         SendCommand(command);
      end;
   end;
end;


// SetWindowGeometry() : set the geometry of a window

procedure SetWindowGeometry(window : WindowPtr; where : Point; width, height : SInt32);
var command : AnsiString;
begin
   if window <> None then 
   begin
      command := 'set-window-geometry name=^0 left=^1 top=^2 width=^3 height=^4';
      command := ReplaceParameters(command, window.name, 
                                            IntToStr(where.h), 
                                            IntToStr(where.v), 
                                            IntToStr(width),
                                            IntToStr(height));
      SendCommand(command);
   end;
end;


// SetPort() : set the current port to the given GrafPtr

procedure SetPort(whichPort : GrafPtr);
var command : AnsiString;
begin
   if whichPort <> None then
   begin
      command := 'set-port name=^0';
      command := ReplaceParameters(command, whichPort.name);
      SendCommand(command);
   end;
end;


// GetPort() : get the current port inside the given GrafPtr

procedure GetPort(var whichPort : GrafPtr);
begin
   whichPort.name := 'None';
   WaitFunctionReturn('get-port', @WINDOW__, @whichPort);
end;


// Parsing the file path from the open-file-dialog answer

procedure InterpretOpenFileDialog(var line : AnsiString; data : Pointer);
var parts: TStringArray;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    getOpenFileDialogData.filePath := parts[3];
end;


// OpenFileDialog() : opens the system "Open file" dialog, and wait for the
// user to select a file (so this is a blocking call). The function returns
// the path of the file selected by the user, or the empty string if the user
// has canceled the dialog.

function OpenFileDialog(prompt, directory, filter : AnsiString) : AnsiString;
const NONE = 'None Filename $•&%';
var command : AnsiString;
begin
   getOpenFileDialogData.filePath := NONE;

   command := 'open-file-dialog';
   command := command + ' prompt="' + MyUrlEncode(prompt) + '"';
   command := command + ' dir="'    + MyUrlEncode(directory) + '"';
   command := command + ' filter="' + MyUrlEncode(filter) + '"';

   SendCommand(command, @InterpretOpenFileDialog, NIL);

   while (getOpenFileDialogData.filePath = NONE) do
   begin
      ReadTaskOutput(gCarbonTask);
      sleep(1);
   end;

   result := MyUrlDecode(getOpenFileDialogData.filePath);
end;





// QDRandom() : a stupid function which sends a random64 value to the server
// with the 'echo' command, wait for the echoed answer and interprets that 
// answer as an integer! This is only useful to test the speed of the server 
// communications.
// Note : use Random64() instead.

function QDRandom() : SInt64;
var command : AnsiString;
begin
    result := -1;
    
    command := 'echo ' + IntToStr(Random64());
    WaitFunctionReturn(command, @SINT64__ , @result);
end;



// QDEcho() : function which sends a string to the server with the 'echo' 
// command, wait for the echoed answer and interprets that answer as a string!
// This is only useful to test the speed of the server communications.

function QDEcho(s : AnsiString) : AnsiString;
var command : AnsiString;
begin
    result := '';
    
    command := 'echo "' + s + '"';
    WaitFunctionReturn(command, @STRING__ , @result);
end;


// MakePoint() : create a Point

function MakePoint(h,v : SInt32) : Point;
begin
  result.h := h;
  result.v := v;
end;


// MakeRect() : create a Rect

function MakeRect(top, left, bottom, right : SInt32) : Rect;
begin
  result.top    := top;
  result.left   := left;
  result.bottom := bottom;
  result.right  := right;
end;


// PointToStr() : convert from a Point to a string

function PointToStr(loc : Point) : AnsiString;
begin
   Result := IntToStr(loc.h) + ' ' + IntToStr(loc.v);
end;


// RectToStr() : convert from a Rect to a string

function RectToStr(r : Rect) : AnsiString;
begin
   Result := IntToStr(r.top) + ' ' + IntToStr(r.left) + ' ' + IntToStr(r.bottom) + ' ' + IntToStr(r.right);
end;


// AlerteDouble() : display a simple alert with a main text and
// a secondary text explaining the main text.
procedure AlerteDouble(texte, explication : String255);
begin
    TODO({$I %CURRENTROUTINE%});
end;



// ReadStringFromRessource() : returns ressource of type "STR#"
function ReadStringFromRessource(stringListID, index : SInt16) : String255;
//var s : Str255;
begin
  	// s := StringToStr255('');
  	// GetIndString(s, stringListID, index);
  	// ReadStringFromRessource := MyStr255ToString(s);
  	
  	TODO({$I %CURRENTROUTINE%});
  	Result := '';
end;



// Initialization of the unit
begin
    start := GetTickCount64();
end.





