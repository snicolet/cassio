unit quickdrawcommunications;


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


// Communication task to connect to the GUI server
var gCarbonTask  : Task;                


// Starting/stopping the GUI server
procedure StartQuickdrawServer(var carbon : Task);
procedure StopQuickdrawServer;


// Communications with the GUI server
procedure LogDebugInfo(info : AnsiString);
function SendCommand(command : AnsiString ; calc : Calculator ; data : Pointer) : SInt64;
procedure WaitFunctionReturn(command : AnsiString; calc : Calculator ; result : Pointer);


// Interpret answers from the GUI server
procedure InterpretAnswer(var line : AnsiString);
procedure SINT64__(var line : AnsiString; value : Pointer);
procedure SINT32__(var line : AnsiString; value : Pointer);
procedure SINT16__(var line : AnsiString; value : Pointer);
procedure BOOL__(var line : AnsiString; value : Pointer);
procedure POINT__(var line : AnsiString; value : Pointer);
procedure STRING__(var line : AnsiString; value : Pointer);

  

implementation


uses QuickDraw;


// QDValueRec is a record to store a polymorphic quickdraw value.
// It is basically a wrapper around a pointer to a normal type along with 
// a type information.
type
  QDValueRec =
    record
      status : SInt64;
      value : Pointer;
    end;
  QDValue = ^QDValueRec;


// Some constants to type the QDValues
const
  NONE     = 0;
  kSINT64  = 1;
  kSINT32  = 2;
  kSINT16  = 3;
  kBOOLEAN = 4;
  kPOINT   = 5;
  kRECT    = 6;
  kSTRING  = 7;
  

// QuickdrawCalculator is a record with an interpretor for the textual answer
// from the server and a pointer which can store the Pascal constructed value.
type
  QuickdrawCalculator =
    record
      calc : Calculator;
      data : Pointer;
    end;


// TAnswers is an object to handle the textual answers from the GUI server.
// It contains an internal list of pairs (currently 2048), where each pair
// of the list has an ID and a callback to process the future textual answer
// from the GUI server.
type
  TAnswers =
    object
       public
         constructor Init();
         destructor  Done();
         procedure Clear(index : SInt64);
         procedure AddHandler(messageID : SInt64; handler : QuickdrawCalculator);
         function GetHandler(index : SInt64) : QuickdrawCalculator;
         function FindQuestion(messageID : SInt64; var indexFound : SInt64) : boolean;

       private
         const SIZE = 2048;
         var lastIndexFound : SInt64;
             cells : array[0 .. SIZE-1] of
                       record
                          messageID : SInt64;
                          handler   : QuickdrawCalculator;
                       end;
    end;


var commandCounter : SInt64 = 100000;     // a strictly increasing counter
    quickDrawAnswers : TAnswers;          // our global TAnswers object
    


// CreateQDValue() : create a polymorphic quickdraw value. The returned value 
// is initialized to NONE by default, but we can change it afterwards by 
// changing the status field.
function CreateQDValue(value : Pointer = nil) : QDValueRec;
begin
    result.status := NONE;
    result.value  := value;
end;


// LogDebugInfo() : A logger with time stamp

procedure LogDebugInfo(info : AnsiString);
var stamp  : AnsiString;
    m, e : SInt64;
begin
    // exit();   // uncomment this line to disable logging

    m := Milliseconds();
    e := m mod 1000;

    stamp := IntToStr(m div 1000) + '.';
    if (e < 10)  then stamp := stamp + '00' else
    if (e < 100) then stamp := stamp + '0';
    stamp := stamp + IntToStr(e);

    system.writeln(stamp + 's | ' + info);
end;


// SendCommand() : send a message to the GUI task, and returns the messageID
// of that message in the quickDrawAnswers array.
                   
function SendCommand(command : AnsiString ; calc : Calculator ; data : Pointer) : SInt64;
var s : AnsiString;
    theHandler : QuickdrawCalculator;
begin
    commandCounter := commandCounter + 1;

    Result := commandCounter;
    s := 'CARBON-PROTOCOL ' + '{' + IntToStr(Result) + '} ' + command;

    LogDebugInfo('[Cassio] >> ' + s);

    theHandler.calc := calc;
    theHandler.data := data;
    quickDrawAnswers.AddHandler(Result, theHandler);

    WriteTaskInput(gCarbonTask, s);
end;


// InterpretAnswer() : callback function for our Quickdraw task

procedure InterpretAnswer(var line : AnsiString);
var parts: TStringArray;
    index : SInt64;
    messageID : AnsiString;
    handler : QuickdrawCalculator;
    myFunction : Calculator;
    myData : Pointer;
begin
    if (line <> '') then
    begin
        if pos('[server] ', line) > 0
        then
            LogDebugInfo(line)
        else
            LogDebugInfo('[Cassio] << ' + line);

	    // Parse the line to see if is a CARBON-PROTOCOL answer
	    // Format of an answer is:
	    //      {ID} command => value1 [value2] [value3]...
	    parts := line.Split(' ', '"', '"', 3, TStringSplitOptions.ExcludeEmpty);

	    if (length(parts) >= 3) and (parts[2] = '=>') then
	    begin
	        messageID := parts[0];

	        if (length(messageID) >= 3) and
	           (messageID[1] = '{') and
	           (messageID[length(messageID)] = '}') then
	           begin

	              messageID := copy(messageID, 2, length(messageID) - 2);

	              if (quickDrawAnswers.FindQuestion(strToInt64(messageID), index)) then
	              begin
	                  handler := quickDrawAnswers.GetHandler(index);
	                  quickDrawAnswers.Clear(index);

	                  myFunction := handler.calc;
	                  myData     := handler.data;
	                  if (myFunction <> nil) then
	                      myFunction(line, myData);
	              end;
	           end;
	    end;
  end;
end;


// SINT64__() : interpret a line from the server as a SInt64 integer.
//              The parameter value must be a QDValue.

procedure SINT64__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    n : SInt64;
    p : QDValue;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    n := strToInt64(parts[3]);

    p := QDValue(value);
    p^.status := kSINT64;
    MoveMemory(@n, p^.value, sizeof(SInt64));
end;



// SINT32__() : interpret a line from the server as a SInt32 integer.
//              The parameter value must be a QDValue.

procedure SINT32__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    n : SInt32;
    p : QDValue;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    n := strToInt32(parts[3]);

    p := QDValue(value);
    p^.status := kSINT32;
    MoveMemory(@n, p^.value, sizeof(SInt32));
end;


// SINT16__() : interpret a line from the server as a SInt16 integer.
//              The parameter value must be a QDValue.

procedure SINT16__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    n : SInt16;
    p : QDValue;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    n := strToInt32(parts[3]);

    p := QDValue(value);
    p^.status := kSINT16;
    MoveMemory(@n, p^.value, sizeof(SInt16));
end;



// BOOL__() : interpret a line from the server as a Boolean.
//              The parameter value must be a QDValue.

procedure BOOL__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    s : AnsiString;
    b : boolean;
    p : QDValue;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    s := sysutils.LowerCase(Trim(parts[3]));

    if (s = '0') or (s = 'false') or (s = 'no')
       then b := false
       else b := true;

    p := QDValue(value);
    p^.status := kBOOLEAN;
    MoveMemory(@b, p^.value, sizeof(boolean));
end;

        

// POINT__() : interpret a line from the server as Point.
//             The parameter value must be a QDValue.

procedure POINT__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    where : Point;
    p     : QDValue;
begin
    parts := line.Split(' ', '"', '"', 5, TStringSplitOptions.ExcludeEmpty);

    where.h := strToInt64(parts[3]);
    where.v := strToInt64(parts[4]);

    p := QDValue(value);
    p^.status := kPOINT;
    MoveMemory(@where, p^.value, sizeof(Point));
end;



// RECT__() : interpret a line from the server as Rect.
//            The parameter value must be a QDValue.

procedure RECT__(var line : AnsiString; value : Pointer);
var parts : TStringArray;
    r     : Rect;
    p     : QDValue;
begin
    parts := line.Split(' ', '"', '"', 7, TStringSplitOptions.ExcludeEmpty);

    r.top    := strToInt64(parts[3]);
    r.left   := strToInt64(parts[4]);
    r.bottom := strToInt64(parts[5]);
    r.right  := strToInt64(parts[6]);

    p := QDValue(value);
    p^.status := kRECT;
    MoveMemory(@r, p^.value, sizeof(Rect));
end;



// STRING__() : interpret a line from the server as AnsiString.
//              The parameter value must be a QDValue.

procedure STRING__(var line : AnsiString; value : Pointer);
var left, right, s : AnsiString;
    p : QDValue;
    p1 : PString;  // Pointer to an AnsiString
begin
    Split(line, ' => ', left, right);
    s := right;

    p := QDValue(value);
    p^.status := kSTRING;
    p1 := PString(p^.value);
    p1^ := s;
end;



// WaitFunctionReturn() : sends a command to the server and waits for the
// answer for a period of MAX_WAITING milliseconds (using a buzy loop).
// If an answer has been received and interpreted by the callback calculator
// "calc" during this waiting time, the procedure returns immediately, and
// the returned value is set in the "result" pointer. If no answer has been
// received, then "result" is unmodified.

procedure WaitFunctionReturn(command : AnsiString; calc : Calculator ; result : Pointer);
const MAX_WAITING = 50 ; // in milliseconds
var val : QDValueRec;
    start, waiting : SInt64;
    messageID, index : SInt64;
begin
    // This sets val.status to NONE
    val := CreateQDValue(result);

    // Send the command to the server  
    messageID := SendCommand(command, calc, @val);
    start := Milliseconds();
    waiting := 0;

    // Buzy waiting loop
    while (val.status = NONE) and (waiting < MAX_WAITING) do
    begin
        ReadTaskOutput(gCarbonTask);

        waiting := Milliseconds() - start;

        // If the GUI server is either not ready or has crashed, 
        // we better yield some time to the OS.
        if (waiting > 5) then sleep(1);
    end;

    // Clear the answering machine slot if we have run out of time
    if (val.status = NONE) and (quickDrawAnswers.FindQuestion(messageID, index)) then
       quickDrawAnswers.Clear(index);

end;


// TAnswers.Init() : constructor for the TAnswers object

constructor TAnswers.Init();
var k : integer;
begin
    lastIndexFound := 0;
    for k := 0 to SIZE - 1 do
       Clear(k);
end;


// TAnswers.Done() : destructor for the TAnswers object

destructor TAnswers.Done();
begin
end;




// TAnswers.AddHandler() : find an empty cell in the answering machine,
// and install the couple (messageID, messageHandler) in that cell.

procedure TAnswers.AddHandler(messageID : SInt64; handler : QuickdrawCalculator);
var k , t : SInt64;
begin
    for k := 1 to SIZE do
    begin
        t := lastIndexFound + k;
        if (t < 0)     then t := t + SIZE;
        if (t >= SIZE) then t := t - SIZE;

        if (cells[t].messageID < 0) and
           (cells[t].handler.calc = nil) and
           (cells[t].handler.data = nil) then
        begin
           cells[t].messageID  :=  messageID;
           cells[t].handler    :=  handler;
           lastIndexFound      :=  t;
           exit;
        end;
    end;
end;


// TAnswers.GetHandler() : return the handler at the specified cell in
// the answering machine.

function TAnswers.GetHandler(index : SInt64) : QuickdrawCalculator;
begin
    result.calc  := nil;
    result.data  := nil;

    if (index >= 0) and (index < SIZE) then
       result := cells[index].handler;
end;


// TAnswers.Clear() : empty the cell at index in the answering machine

procedure TAnswers.Clear(index : SInt64);
begin
    cells[index].messageID     :=  -1;
    cells[index].handler.calc  :=  nil;
    cells[index].handler.data  :=  nil;
end;


// TAnswers.FindQuestion() : return true if we can find the cell with
// the specified messageID in the answering machine (and its index).

function TAnswers.FindQuestion(messageID : SInt64; var indexFound : SInt64) : boolean;
var k , t : SInt64;
    found : boolean;
begin
    found := false;
    indexFound := -1;

    for k := 0 to (SIZE div 2) do
    begin
        t := lastIndexFound + k;
        if (t < 0)     then t := t + SIZE;
        if (t >= SIZE) then t := t - SIZE;
        if (cells[t].messageID = messageID) then
           begin
               found := true;
               indexFound := t;
               lastIndexFound := t;
               break;
           end;

        t := lastIndexFound - k;
        if (t < 0)     then t := t + SIZE;
        if (t >= SIZE) then t := t - SIZE;
        if (cells[t].messageID = messageID) then
           begin
               found := true;
               indexFound := t;
               lastIndexFound := t;
               break;
           end;
    end;

    result := found;
end;


// StartQuickdrawServer() : Initialisation of the Quickdraw unit

procedure StartQuickdrawServer(var carbon : Task);
begin
    quickDrawAnswers.Init();

    carbon.process            := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	CreateConnectedTask(carbon, @InterpretAnswer, nil);
	
	gCarbonTask               := carbon;
end;



// StopQuickDrawServer() : Termination of the Quickdraw unit

procedure StopQuickDrawServer;
begin
    SendCommand('quit', NIL, NIL);
    sleep(1000);  // one second
    FreeConnectedTask(gCarbonTask);
    
    quickDrawAnswers.Done();
end;

begin
end.






























