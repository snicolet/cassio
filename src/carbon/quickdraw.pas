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

// File dialogs
function OpenFileDialog(prompt, directory, filter : AnsiString) : AnsiString;

// Ressources
function ReadStringFromRessource(stringListID, index : SInt16) : String255;

// Alerts
procedure AlerteDouble(texte,explication : String255);

// Misc
function QDRandom() : SInt64;


IMPLEMENTATION


uses quickdrawcommunications;



var start          : SInt64;              // milliseconds at the start of the program
    getMouseData :
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

    getMouseData.mouseLoc.h := 0;
    getMouseData.mouseLoc.v := 0;
    getMouseData.when       := -1000;
    
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
    getMouseData.mouseLoc.h := strToInt64(parts[3]);
    getMouseData.mouseLoc.v := strToInt64(parts[4]);
end;


// GetMouse() : return the position of the mouse in global coordinates of the main screen

function GetMouse() : Point;
begin
    if (Milliseconds() - getMouseData.when >= 30) then
    begin
        getMouseData.when := Milliseconds();
        SendCommand('get-mouse', @InterpretGetMouseAnswer, NIL);
    end;

   result := getMouseData.mouseLoc;
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
      ReadTaskOutput(quickDrawTask);
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



// GetMouse2() : return the position of the mouse. This is a buzy waiting
// function which takes about 0.13 millisecond to answer.

function GetMouse2() : Point;
begin
    result.h := -1;
    result.v := -1;
    WaitFunctionReturn('get-mouse', @POINT__, @result);
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





