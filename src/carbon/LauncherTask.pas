unit LauncherTask;

interface

uses 
   Process;


   
      
   function runTask(processName : string): boolean;


implementation

uses 
   Classes,
   SysUtils;
var
  theProcess : TProcess;

function runTask(processName: string): boolean;
  var 
      output    : AnsiString;
      error     : AnsiString;
      status    : integer;
begin
  writeln('begin runTask() : ' + processName);
  
  result := FALSE;
  theProcess := TProcess.Create(nil);
  theProcess.Options := [poUsePipes, poStdErrToOutput, poNoConsole];
  theProcess.Executable := processName;
  //theProcess.Execute();
  
  theProcess.RunCommandLoop(output, error, status);
  result := TRUE;
  
  writeln('end runTask() : ' + processName);
end;




end.


