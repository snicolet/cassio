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

// Communications with the GUI server
procedure LogDebugInfo(info : AnsiString);
procedure SendCommand(command : AnsiString);
procedure InterpretAnswer(var line : AnsiString);

// Time functions
function Milliseconds() : QWord;
function Tickcount() : QWord;

// Mouse 
function GetMouse() : Point;


implementation


var start          : QWord;              // milliseconds at the start of the program
    quickDrawTask  : Task;               // communication task to connect to the GUI server
    mouseLoc       : Point = (h:0; v:0); // mouse position
    commandCounter : QWord = 1000;       // a strictly increasing counter

// AnsweringMachine is an object to handle the textual answers from the GUI server

type 
  TAnsweringMachine = 
    object
       private 
         const SIZE = 2048;
         var lastIndexFound : Integer;
       public 
         constructor Init();
         destructor  Done();
    end;

var answeringMachine : TAnsweringMachine;
      
constructor TAnsweringMachine.init();
begin
  lastIndexFound := 0;
end;

destructor TAnsweringMachine.Done();
begin
end;




// InitQuickDraw() : Initialisation of the Quickdraw unit

procedure InitQuickDraw(var carbon : Task);
begin
    answeringMachine.Init();
    
    carbon.process            := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	CreateConnectedTask(carbon, @InterpretAnswer, nil);
	
	quickDrawTask             := carbon;
end;



// ReleaseQuickDraw() : Termination of the Quickdraw unit

procedure ReleaseQuickDraw;
begin
    FreeConnectedTask(quickDrawTask);
    
    answeringMachine.Done();
end;



////// Communications with the GUI task   /////


// LogDebugInfo() : A logger with time stamp

procedure LogDebugInfo(info : AnsiString);
var stamp  : AnsiString;
    m, e : QWord;
begin
  m := Milliseconds();
  e := m mod 1000;
  
  stamp := IntToStr(m div 1000) + '.';
  if (e < 10)  then stamp := stamp + '00' else
  if (e < 100) then stamp := stamp + '0';
  stamp := stamp + IntToStr(e);
  
  writeln(stamp + 's | ' + info);
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
end.





