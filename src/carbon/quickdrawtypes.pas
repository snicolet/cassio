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

  QuickDrawType = (
                   kNONE      ,
                   kSINT64    ,
                   kSINT32    ,
                   kSINT16    ,
                   kBOOLEAN   ,
                   kPOINT     ,
                   kRECT      ,
                   kSTRING    ,  // represents AnsiString
                   kWINDOW
                   );

  // special type for private names of quickdraw objects
  privateRef = AnsiString;

  // Point
  Point = record
            h : SInt32;
            v : SInt32;
          end;
  PointPtr = ^Point;

  // Rect
  Rect = record
            top    : SInt32;
            left   : SInt32;
            bottom : SInt32;
            right  : SInt32;
         end;
  RectPtr = ^Rect;


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





