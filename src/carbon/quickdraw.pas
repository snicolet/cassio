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
  BasicCharSet;

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
procedure SendCommand(command : AnsiString ; calc : Calculator ; data : Pointer);
procedure InterpretAnswer(var line : AnsiString);

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


var start          : SInt64;              // milliseconds at the start of the program
    quickDrawTask  : Task;               // communication task to connect to the GUI server
    commandCounter : SInt64 = 100000;     // a strictly increasing counter

    getMouseData :
        record
           mouseLoc : Point ;            // mouse position
           when     : SInt64 ;            // date in milliseconds
        end;

    getOpenFileDialogData :
        record
           filePath : AnsiString;
        end;


// QuickdrawCalculator is a record with an interpretor for the textual answer
// from the server and a pointer which can store the Pascal constructed data.
type
  QuickdrawCalculator =
    record
      calc : Calculator;
      data : Pointer;
    end;

type
  QDValueRec =
    record
      status : SInt64;
      data : Pointer;
    end;
  QDValue = ^QDValueRec;
  
const
  NONE     = 0;
  kSINT64  = 1;
  kBOOLEAN = 2;
  kPOINT   = 3;


// TAnswers is an object to handle the textual answers from the GUI server
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

var quickDrawAnswers : TAnswers;



// CreateQDValue() : create a polymorphic quickdraw value, which is basically
// a wrapper around a pointer to a normal type along with a type information.
// The returned value is initialized to NONE by default, but we can change
// it afterwards by changing the status field.
function CreateQDValue(data : Pointer = nil) : QDValueRec;
begin
    result.status := NONE;
    result.data   := data;
end;


// InitQuickDraw() : Initialisation of the Quickdraw unit

procedure InitQuickDraw(var carbon : Task);
begin
    RandomizeTimer;
    quickDrawAnswers.Init();

    carbon.process            := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	CreateConnectedTask(carbon, @InterpretAnswer, nil);
	
	quickDrawTask             := carbon;
end;



// ReleaseQuickDraw() : Termination of the Quickdraw unit

procedure ReleaseQuickDraw;
begin
    SendCommand('quit', NIL, NIL);
    sleep(1000);
    FreeConnectedTask(quickDrawTask);
    quickDrawAnswers.Done();
end;



////// Communications with the GUI task   /////


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


// LogDebugInfo() : A logger with time stamp

procedure LogDebugInfo(info : AnsiString);
var stamp  : AnsiString;
    m, e : SInt64;
begin
    // exit();
    
    m := Milliseconds();
    e := m mod 1000;

    stamp := IntToStr(m div 1000) + '.';
    if (e < 10)  then stamp := stamp + '00' else
    if (e < 100) then stamp := stamp + '0';
    stamp := stamp + IntToStr(e);

    system.writeln(stamp + 's | ' + info);
end;


// SendCommand() : send a message to the GUI task

procedure SendCommand(command : AnsiString ; calc : Calculator ; data : Pointer);
var s : AnsiString;
    theHandler : QuickdrawCalculator;
begin
    commandCounter := commandCounter + 1;
    s := 'CARBON-PROTOCOL ' + '{' + IntToStr(commandCounter) + '} ' + command;

    LogDebugInfo('[Cassio] >> ' + s);

    theHandler.calc := calc;
    theHandler.data := data;
    quickDrawAnswers.AddHandler(commandCounter, theHandler);

    WriteTaskInput(quickDrawTask, s);
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



// SINT64__() : interpret a line from the server as a SInt64 integer.
//              The parameter data must be a QDValue.

procedure SINT64__(var line : AnsiString; data : Pointer);
var parts : TStringArray;
    n : SInt64;
    p : QDValue;
begin
    parts := line.Split(' ', '"', '"', 4, TStringSplitOptions.ExcludeEmpty);
    n := strToInt64(parts[3]);

    p := QDValue(data);
    p^.status := kSINT64;
    MoveMemory(@n, p^.data, sizeof(SInt64));
end;


// POINT__() : interpret a line from the server as Point.
//             The parameter data must be a QDValue.

procedure POINT__(var line : AnsiString; data : Pointer);
var parts : TStringArray;
    where : Point;
    p     : QDValue;
begin
    parts := line.Split(' ', '"', '"', 5, TStringSplitOptions.ExcludeEmpty);
    where.h := strToInt64(parts[3]);
    where.v := strToInt64(parts[4]);

    p := QDValue(data);
    p^.status := kPOINT;
    MoveMemory(@where, p^.data, sizeof(Point));
end;


// WaitFunctionReturn() : sends a command to the server and waits for the 
// answer for a period of 50ms (using a buzy loop). If an answer has been
// received and interpreted by the callback calculator "calc" during these
// 50ms, the procedure returns immediately, and the returned value is set
// in "result" pointer. If no answer has been received, then "result" is
// unmodified.

procedure WaitFunctionReturn(command : AnsiString; calc : Calculator ; result : Pointer);
var val : QDValueRec;
    start : SInt64;
begin
    // This sets val.status to NONE
    val := CreateQDValue(result);
    
    // Send the command to the server  
    SendCommand(command, calc, @val);
    start := Milliseconds();

    // Buzy waiting loop
    while (val.status = NONE) and (Milliseconds() - start < 50) do
        ReadTaskOutput(quickDrawTask);
end;


// QDRandom() : a stupid function which sends a random64 value to the server
// with the 'echo' command, and return that random value using using the usual
// integer interpretation of the server answer... This is only useful to test
// the speed of the server communications.
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


// Constructor for the TAnswers object
constructor TAnswers.Init();
var k : integer;
begin
    lastIndexFound := 0;
    for k := 0 to SIZE - 1 do
       Clear(k);
end;


// Destructor for the TAnswers object
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


// Initialization of the QuickDraw.pas unit
procedure SetUpQuickDrawUnit;
begin
  start := GetTickCount64();

  getMouseData.mouseLoc.h := 0;
  getMouseData.mouseLoc.v := 0;
  getMouseData.when       := -1000;
end;



begin
  // Always init the library !
  SetUpQuickDrawUnit;

end.





