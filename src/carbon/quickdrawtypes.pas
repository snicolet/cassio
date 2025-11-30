unit quickdrawtypes;

// quickdrawtypes.pas
// Unit declaring all the types used in QuickDraw and Carbon toolbox.

interface

uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  Classes,
  SysUtils,
  BasicTypes;


type
  Point = record
            h : SInt32;
            v : SInt32;
          end;

  Rect = record
            top    : SInt32;
            left   : SInt32;
            bottom : SInt32;
            right  : SInt32;
         end;

  WindowPtrPtr = ^WindowPtr;
  WindowPtr = record
                name : AnsiString;
              end;

  DialogPtr = WindowPtr;

  GrafPtr = WindowPtr;
  
  PixMap = record
             name : AnsiString;
           end;
  
  

implementation

begin
end.





