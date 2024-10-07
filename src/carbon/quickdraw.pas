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

// Initialisation and termination
procedure InitQuickDraw(var carbon : Task);
procedure ReleaseQuickDraw;


// Time function
function Milliseconds() : QWord;
function Tickcount() : QWord;


implementation

var start         : QWord;      // milliseconds at the start of the program
    quickDrawTask : Task;       // communication task
    
    
// Initialisation
procedure InitQuickDraw(var carbon : Task);
begin
    carbon.process := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	CreateConnectedTask(carbon, @EchoTaskInterpretor, nil);
	quickDrawTask := carbon;
end;

// Termination
procedure ReleaseQuickDraw;
begin
    FreeConnectedTask(quickDrawTask);
end;

// Returns the number of milliseconds since the start of the program
function Milliseconds() : QWord;
begin
   result := GetTickCount64() - start;
end;

// Returns the number of ticks (1/60 of second) since the start of the program
function Tickcount() : QWord;
begin
   result := Milliseconds() * 60 div 1000;
end;


begin
  start := GetTickCount64();
end.





