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

  // special type for private names of quickdraw objects
  privateRef = AnsiString;


  // Point
  Point = record
            h : SInt32;
            v : SInt32;
          end;

  // Rect
  Rect = record
            top    : SInt32;
            left   : SInt32;
            bottom : SInt32;
            right  : SInt32;
         end;


  // Windows, dialogs, grafport, etc
  WindowPtr    = record name : privateRef; end;  // private
  WindowPtrPtr = ^WindowPtr;
  WindowRef    = WindowPtr;
  DialogPtr    = WindowPtr;
  DialogRef    = DialogPtr;
  GrafPtr      = WindowPtr;
  CGrafPtr     = WindowPtr;


  // Pixmap
  PixMap       = record name : privateRef; end; // private

  

implementation

begin
end.





