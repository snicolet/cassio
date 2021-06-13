unit connect;

interface

uses Process;


type
   
   Interpretor = procedure(line : ansistring);  { type for callback function }
   
   Task = record
              process             : TProcess;
              lastStringReceived  : ansistring;
              callBack            : Interpretor;
           end;
           

     
function CreateConnectedProcess(var theTask : Task; callBack : Interpretor) : boolean;
procedure FreeConnectedProcess(var theTask : Task);
procedure WriteProcessInput(var theTask : Task; const theStr: ansistring);
function ReadProcessOutput(var theTask : Task) : ansistring;
procedure InterpretProcessOutput(line : ansistring);

implementation

uses
  SysUtils, Classes;

function CreateConnectedProcess(var theTask : Task; callBack : Interpretor) : boolean;
begin
  result := FALSE;
  
  theTask.lastStringReceived := '';
  theTask.callBack           := callBack;
  
  theTask.process.Options    := [poUsePipes, poStdErrToOutput, poNoConsole];
  theTask.process.Execute;
  
  result := TRUE;
end;

procedure FreeConnectedProcess(var theTask : Task);
begin
  if theTask.process.Running then
    theTask.process.Terminate(0);
end;


procedure InterpretProcessOutput(line : ansistring);
begin
  if (line <> '')
	then writeln(line);
end;


function ReadProcessOutput(var theTask : Task) : ansistring;
var
  NoMoreOutput: boolean;

  procedure DoStuffForProcess(var theTask : Task);
  const
    BUFFER_SIZE = 1024 * 256;
  var
    Buffer         : packed array[0 .. (BUFFER_SIZE + 100)] of char;
    BytesAvailable : DWord;
    BytesRead      : LongInt;
    bulkSize       : Longint;
    c              : char;
    i              : Longint;
  begin
    if theTask.process.Running then
    begin
      BytesAvailable := theTask.process.Output.NumBytesAvailable;
      BytesRead      := 0;
      
      while BytesAvailable > 0 do
      begin
      
        bulkSize := BytesAvailable;
        if (bulkSize > BUFFER_SIZE) then
           bulkSize := BUFFER_SIZE;
        
        BytesRead := theTask.process.Output.Read(Buffer[0], bulkSize);
        
        // Writeln('[DEBUG Cassio] < BytesRead = ', BytesRead);
        
        for i := 0 to BytesRead-1 do
        begin
           result := result + Buffer[i];
           c := Buffer[i];
           if (c = #10) then
             begin
                if theTask.lastStringReceived <> '' then
                  begin
                    theTask.callback(theTask.lastStringReceived);
                    theTask.lastStringReceived := '';
                  end;
             end
           else
             begin
                if c <> chr(0)
                   then theTask.lastStringReceived := theTask.lastStringReceived + c;
             end
        end;
        
        BytesAvailable := theTask.process.Output.NumBytesAvailable;
        NoMoreOutput := FALSE;
      end;
    end;
  end;
  
begin
  result := '';
  repeat
    NoMoreOutput := TRUE;
    DoStuffForProcess(theTask);
  until NoMoreOutput;
end;



procedure WriteProcessInput(var theTask : Task; const theStr : ansistring);
var
  s : ansistring;
begin
  if theTask.process.Running then
  begin
    s := theStr + #10;
    theTask.process.Input.Write(s[1], Length(s));
  end;
end;

end.


