UNIT UnitProgressBar;


INTERFACE





 USES UnitDefCassio;





procedure InitUnitProgressBar;
procedure InitProgressIndicator(whichWindow : WindowRef; r : rect; maximum : SInt32; PourKaleidoscope : boolean);
procedure SetProgress(absoluteAmount : SInt32);
procedure DrawProgressBar;
function SetProgressDelta(delta : SInt32) : boolean;
procedure UpdateProgressBar;
procedure DrawEmptyProgressBar;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitCarbonisation ;
{$ELSEC}
    ;
    {$I prelink/ProgressBar.lk}
{$ENDC}


{END_USE_CLAUSE}










var  ProgressWindow : WindowRef;
     progressRect : rect;
     ProgressMax : SInt32;
     ProgressCurrent : SInt32;
     ProgressLastCurrent : SInt32;
     ProgressLastBorder : SInt16;

var kBlackRGB,kWhiteRGB,kDarkGreyRGB : RGBColor;
    ProgressUsesColor : boolean;



procedure InitUnitProgressBar;
begin
  kSteelBlueRGB.red := $CCCC;
  kSteelBlueRGB.green := $CCCC;
  kSteelBlueRGB.blue := $FFFF;
end;

procedure SetFrameColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kBlackRGB);
        RGBBackColor(kWhiteRGB);
      end
    else
      PenPat(blackPattern);
end;

procedure SetDoneColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kDarkGreyRGB);
        RGBBackColor(kWhiteRGB);
      end
    else
      PenPat(blackPattern);
end;


procedure SetToBeDoneColor;
begin
  if ProgressUsesColor
    then
      begin
        RGBForeColor(kSteelBlueRGB);
        RGBBackColor(kBlackRGB);
      end
    else
      PenPat(whitePattern);
end;


procedure InitProgressIndicator(whichWindow : WindowRef; r : rect; maximum : SInt32; PourKaleidoscope : boolean);
begin
  ProgressWindow := whichWindow;
  progressRect := r;
  if PourKaleidoscope then progressRect.bottom := progressRect.top+12;
  ProgressMax := maximum;
  ProgressCurrent := 0;
  ProgressLastCurrent := 0;
  ProgressLastBorder := 0;

  kBlackRGB.red := $0000;           kBlackRGB.green := $0000;            kBlackRGB.blue := $0000;
  kWhiteRGB.red := $FFFF;           kWhiteRGB.green := $FFFF;            kWhiteRGB.blue := $FFFF;
  kDarkGreyRGB.red := $4000;        kDarkGreyRGB.green := $4000;         kDarkGreyRGB.blue := $4000;
  kSteelBlueRGB.red := $CCCC;       kSteelBlueRGB.green := $CCCC;        kSteelBlueRGB.blue := $FFFF;

  ProgressUsesColor := true;

  DrawEmptyProgressBar;
end;


procedure SetProgress(absoluteAmount : SInt32);
begin
  ProgressCurrent := absoluteAmount;
  DrawProgressBar;
end;

function SetProgressDelta(delta : SInt32) : boolean;
begin
  ProgressCurrent := ProgressCurrent+delta;
  DrawProgressBar;
  SetProgressDelta := (ProgressCurrent >= ProgressMax);
end;


procedure DrawProgressBar;
var border,rectWidth : SInt32;
begin
  if (ProgressWindow <> NIL) &
     (ProgressLastCurrent <> ProgressCurrent) &
     (ProgressCurrent <= ProgressMax) then
    begin
      ProgressLastCurrent := ProgressCurrent;
      rectWidth := progressRect.right-progressRect.left-2;
      border := progressRect.left+1+(rectwidth*ProgressCurrent) div ProgressMax;
      if ProgressLastBorder <> border then
        begin
          ProgressLastBorder := border;
          UpdateProgressBar;
        end;
    end;
end;


procedure UpdateProgressBar;
var oldport : grafPtr;
    oldForeColor,oldBackColor : RGBColor;
    doneRect,toBeDoneRect : rect;
begin
  if (ProgressWindow <> NIL) then
    begin
      doneRect := progressRect;
      InsetRect(doneRect,1,1);
      toBeDoneRect := doneRect;
      donerect.right := ProgressLastBorder;
      if donerect.left < donerect.right-10 then donerect.left := donerect.right-10;
      toBeDoneRect.left := ProgressLastBorder;

      GetPort(oldport);
      SetPortByWindow(ProgressWindow);
      GetForeColor(oldForeColor);
      GetBackColor(oldBackColor);
      PenNormal;

      SetFrameColor;
      FrameRect(progressRect);


      if ProgressUsesColor
        then
          begin
            SetDoneColor;
            PaintRect(doneRect);

            {SetToBeDoneColor;
            PaintRect(toBeDoneRect);
            }
          end
        else
          begin
            SetDoneColor;
            FillRect(doneRect,darkGrayPattern);
          { SetToBeDoneColor;
            FillRect(doneRect,lightGrayPattern);}
          end;

      FlushWindow(ProgressWindow);

      RGBForeColor(oldForeColor);
      RGBBackColor(oldBackColor);
      SetPort(oldport);
    end;
end;

procedure DrawEmptyProgressBar;
var oldport : grafPtr;
    oldForeColor,oldBackColor : RGBColor;
    toBeDoneRect : rect;
begin
  if (ProgressWindow <> NIL) then
    begin
      toBeDoneRect := progressRect;
      InsetRect(toBeDoneRect,1,1);

      GetPort(oldport);
      SetPortByWindow(ProgressWindow);
      GetForeColor(oldForeColor);
      GetBackColor(oldBackColor);
      PenNormal;

      SetFrameColor;
      FrameRect(progressRect);

      if ProgressUsesColor
        then
          begin
            SetToBeDoneColor;
            PaintRect(toBeDoneRect);
          end
        else
          begin
            SetToBeDoneColor;
            FillRect(toBeDoneRect,lightGrayPattern);
          end;

      FlushWindow(ProgressWindow);


      RGBForeColor(oldForeColor);
      RGBBackColor(oldBackColor);
      SetPort(oldport);
    end;
end;



end.
