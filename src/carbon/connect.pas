unit connect;

interface

uses Process;

function CreateConnectedProcess(task : TProcess) : boolean;
procedure FreeConnectedProcess(task : TProcess);
function ReadProcessOutput(task : TProcess) : ansistring;
procedure WriteProcessInput(task : TProcess; const AStr: ansistring);

implementation

uses
  SysUtils, Classes;


function ReadProcessOutput(task : TProcess) : ansistring;
var
  NoMoreOutput: boolean;

  procedure DoStuffForProcess(AProcess: TProcess);
  const
    BUFFER_SIZE = 1024 * 128;
  var
    Buffer              : packed array[0 .. (BUFFER_SIZE + 100)] of char;
    BytesAvailable      : DWord;
    BytesRead           : LongInt;
    numberOfBytesToRead : Longint;
    i                   : longint;
  begin
    if AProcess.Running then
    begin
      BytesAvailable := AProcess.Output.NumBytesAvailable;
      BytesRead      := 0;
      
      while BytesAvailable > 0 do
      begin
        numberOfBytesToRead := BytesAvailable;
        if (numberOfBytesToRead > BUFFER_SIZE) then
           numberOfBytesToRead := BUFFER_SIZE;
        
        BytesRead := AProcess.Output.Read(Buffer[0], BytesAvailable);
        
        Writeln('[DEBUG Cassio] < BytesRead = ', BytesRead);
        
        for i := 0 to BytesRead-1 do
           result := result + Buffer[i];
        
        BytesAvailable := AProcess.Output.NumBytesAvailable;
        NoMoreOutput := FALSE;
      end;
    end;
  end;
  
begin
  result := '';
  repeat
    NoMoreOutput := TRUE;
    DoStuffForProcess(task);
  until NoMoreOutput;
end;

function CreateConnectedProcess(task : TProcess) : boolean;
begin
  result := FALSE;
  task.Options := [poUsePipes, poStdErrToOutput, poNoConsole];
  task.Execute;
  result := TRUE;
end;

procedure FreeConnectedProcess(task : TProcess);
begin
  if task.Running then
    task.Terminate(0);
end;

procedure WriteProcessInput(task : TProcess; const AStr: ansistring);
var
  s: ansistring;
begin
  if task.Running then
  begin
    s := AStr + #10;
    task.Input.Write(s[1], Length(s));
  end;
end;

end.


