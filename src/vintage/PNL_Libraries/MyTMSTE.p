UNIT MyTMSTE;



INTERFACE






 USES TextEdit , TextServices , TSMTE , QuickDraw , UnitDefCassio;


type myTSMTERec = record
                    theText : TEHandle;
                    theWindow : WindowRef;
                    theTSMDoc : TSMDocumentID;
                    theTSMHandle : TSMTERecHandle;
                  end;
     myTSMTEPtr = ^myTSMTERec;
     myTSMTEHandle = ^myTSMTEPtr;

function MyTSMTEGetText(TSMTE : myTSMTEHandle) : TEHandle;
function MyTSMTEGetWindow(TSMTE : myTSMTEHandle) : WindowPtr;
function MyTSMTEGetTSMDoc(TSMTE : myTSMTEHandle)  : TSMDocumentID;
function MyTSMTEGetTSMHandle(TSMTE : myTSMTEHandle)  : TSMTERecHandle;


IMPLEMENTATION







function MyTSMTEGetText(TSMTE : myTSMTEHandle) : TEHandle;
begin
  if TSMTE = NIL
    then MyTSMTEGetText := NIL
    else MyTSMTEGetText := TSMTE^^.theText;
end;


function MyTSMTEGetWindow(TSMTE : myTSMTEHandle) : WindowPtr;
begin
  if TSMTE = NIL
    then MyTSMTEGetWindow := NIL
    else MyTSMTEGetWindow := TSMTE^^.theWindow;
end;


function MyTSMTEGetTSMDoc(TSMTE : myTSMTEHandle) : TSMDocumentID;
begin
  if TSMTE = NIL
    then MyTSMTEGetTSMDoc := NIL
    else MyTSMTEGetTSMDoc := TSMTE^^.theTSMDoc;
end;


function MyTSMTEGetTSMHandle(TSMTE : myTSMTEHandle) : TSMTERecHandle;
begin
  if TSMTE = NIL
    then MyTSMTEGetTSMHandle := NIL
    else MyTSMTEGetTSMHandle := TSMTE^^.theTSMHandle;
end;



END.
