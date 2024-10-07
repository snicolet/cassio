unit quickdraw;


interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  Classes,
  SysUtils,
  Process,
  Connect;
  
type
  Point = record
            h : Integer;
            v : Integer;
          end;

// Initialisation and termination
procedure InitQuickDraw(var carbon : Task);
procedure ReleaseQuickDraw;

// Communications with the GUI task
procedure LogDebugInfo(info : AnsiString);
procedure SendCommand(command : AnsiString);
procedure InterpretAnswer(var line : AnsiString);

// Time functions
function Milliseconds() : QWord;
function Tickcount() : QWord;

// Mouse 
function GetMouse() : Point;


implementation

var start          : QWord;      // milliseconds at the start of the program
    quickDrawTask  : Task;       // communication task
    mouseLoc       : Point;      // mouse position
    commandCounter : QWord;      // a strictly increasing counter


// InitQuickDraw() : Initialisation of the Quickdraw unit

procedure InitQuickDraw(var carbon : Task);
begin
    carbon.process := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	CreateConnectedTask(carbon, @InterpretAnswer, nil);
	quickDrawTask := carbon;
end;



// ReleaseQuickDraw() : Termination of the Quickdraw unit

procedure ReleaseQuickDraw;
begin
    FreeConnectedTask(quickDrawTask);
end;



////// Communications with the GUI task   /////


// LogDebugInfo() : A logger with time stamp

procedure LogDebugInfo(info : AnsiString);
begin
  writeln(IntToStr(Milliseconds) + 'ms .. ' + info);
end;



// SendCommand() : send a message to the GUI task

procedure SendCommand(command : AnsiString);
var s : AnsiString;
begin
  commandCounter := commandCounter + 1;
  s := 'CARBON-PROTOCOL ' + '{' + IntToStr(commandCounter) + '} ' + command;
  
  LogDebugInfo('[Cassio]   > ' + s);
  WriteTaskInput(quickDrawTask, s);
end;


// InterpretAnswer() : callback function for our Quickdraw task

procedure InterpretAnswer(var line : AnsiString);
begin
  if (line <> '') then
  begin
     LogDebugInfo(line);
	 //writeln(line);
  end;
end;



// Milliseconds() : get the number of milliseconds since the start of the program

function Milliseconds() : QWord;
begin
   result := GetTickCount64() - start;
end;



// Tickcount() : get the number of ticks (1/60 of second) since the start of the program

function Tickcount() : QWord;
begin
   result := Milliseconds() * 60 div 1000;
end;


// GetMouse() : return the position of the mouse in global coordinates of the main screen

function GetMouse() : Point;
var s : AnsiString;
begin
   s := 'get-mouse';
   SendCommand(s);
   result := mouseLoc;
end;




begin
  start := GetTickCount64();
  commandCounter := 0;
  mouseLoc.h     := -1000;
  mouseLoc.v     := -1000;
end.





