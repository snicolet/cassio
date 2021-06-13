unit connect;

interface

uses Process;


type

   // Type for callback function
   Interpretor = procedure(var line : ansistring);

   // A task is a TProcess with some extra fields
   Task = record
              process             : TProcess;
              lastStringReceived  : ansistring;
              callBack            : Interpretor;
           end;

   // Creation and destructions of a Task
   function CreateConnectedTask(var theTask : Task; callBack : Interpretor) : boolean;
   procedure FreeConnectedTask(var theTask : Task);

   // Non-blocking read and write on the Task pipes
   procedure WriteTaskInput(var theTask : Task; const theStr: ansistring);
   function ReadTaskOutput(var theTask : Task) : ansistring;

   // An example of dummy callback function
   procedure DummyTaskInterpretor(var line : ansistring);


implementation

uses
  SysUtils, Classes;


// CreateConnectedTask() : creation of a task. The task.process field must contains
// the name and the arguments of the process to launch, and we must provide a callback
// function that will be called for each line we read later on the task pipe.

function CreateConnectedTask(var theTask : Task; callBack : Interpretor) : boolean;
begin
  result := FALSE;
   theTask.lastStringReceived := '';
  theTask.callBack           := callBack;
   theTask.process.Options    := [poUsePipes, poStdErrToOutput, poNoConsole];
  theTask.process.Execute;
   result := TRUE;
end;


// FreeConnectedTask() : terminates the process of the task.

procedure FreeConnectedTask(var theTask : Task);
begin
  if theTask.process.Running then
    theTask.process.Terminate(0);
end;


// DummyTaskInterpretor() : an example of callback function for a task.
// This one only writes the line on the console.

procedure DummyTaskInterpretor(var line : ansistring);
begin
  if (line <> '')
	then writeln(line);
end;


// ReadTaskOutput() : non-blocking read of the Task standard output.
// This function should be called every millisecond or so from the main loop
// of your program. It reads the task output from its pipe, cut it into text
// lines and calls the callback function for each line found in the buffer.
// Note that the callback may be called several times for each ReadTaskOutput()
// call, if several lines are found in the buffer.

function ReadTaskOutput(var theTask : Task) : ansistring;
var
  NoMoreOutput: boolean;

  procedure DoStuffForTask(var theTask : Task);
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
    DoStuffForTask(theTask);
  until NoMoreOutput;
end;


// WriteTaskInput() : non-blocking write on the Task standard input.
// This function send the given string to the remote process, followed
// by a carriage return (#10) to separate a new line.

procedure WriteTaskInput(var theTask : Task; const theStr : ansistring);
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


