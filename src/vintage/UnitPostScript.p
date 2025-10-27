UNIT UnitPostScript;

{cf http://developer.apple.com/techpubs/mac/QuickDraw/QuickDraw-469.html}



INTERFACE







 USES UnitDefCassio , FixMath;


{PicComments.p}
const
  {values for picture comments}
  TextBegin         = 150;
  TextEnd           = 151;
  StringBegin       = 152;
  StringEnd         = 153;
  TextCenter        = 154;
  LineLayoutOff     = 155;
  LineLayoutOn      = 156;
  ClientLineLayout  = 157;   {considered to be of limited usefulness}
  PolyBegin         = 160;
  PolyEnd           = 161;
  PolyIgnore        = 163;
  PolySmooth        = 164;
  PolyClose         = 165;
  DashedLine        = 180;
  DashedStop        = 181;
  SetLineWidth      = 182;
  PostScriptBegin   = 190;
  PostScriptEnd     = 191;
  PostScriptHandle  = 192;
  PostScriptFile    = 193;   {considered to be of limited usefulness}
  TextIsPostScript  = 194;   {considered to be of limited usefulness}
  ResourcePS        = 195;   {considered to be of limited usefulness}
  PSBeginNoSave     = 196;   {dangerous to use with LaserWriter 8.0}
  SetGrayLevel      = 197;   {this comment now obsolete}
  RotateBegin       = 200;
  RotateEnd         = 201;
  RotateCenter      = 202;
  {values for the tJus field of the TTxtPicRec record}
  tJusNone          = 0;
  tJusLeft          = 1;
  tJusCenter        = 2;
  tJusRight         = 3;
  tJusFull          = 4;
  {values for the tFlip field of the TTxtPicRec record}
  tFlipNone         = 0;
  tFlipHorizontal   = 1;
  tFlipVertical     = 2;

(* type
  double = double;
*)

type
  TTxtPicHdl = ^TTxtPicPtr;
  TTxtPicPtr = ^TTxtPicRec;
  TTxtPicRec =
    packed record
     tJus:          UInt8;       {justification for line layout of text}
     tFlip :         UInt8;       {horizontal or vertical flipping}
     tAngle:        SInt16;    {0..360 degrees clockwise rotation }
                                { in SInt16 format}
     tLine:         UInt8;       {reserved}
     tCmnt:         UInt8;       {reserved}
     tAngleFixed:   UInt8;       {0..360 degrees clockwise rotation in }
                                { fixed-number format}
    end;

  TRotationHdl = ^TRotationPtr;
  TRotationPtr = ^TRotationRec;
  TRotationRec =
    record
     rFlip :         SInt16;    {horizontal/vertical flipping}
     rAngle:        SInt16;    {0..360 degrees clockwise rotation }
                                { in SInt16 format}
     rAngleFixed:   Fixed;      {0..360 degrees clockwise rotation in }
                                { fixed-number format}
    end;

  TCenterHdl = ^TCenterPtr;
  TCenterPtr = ^TCenterRec;
  TCenterRec =
    record
     y :    Fixed;   {vertical offset from current pen location}
     x :    Fixed;   {horizontal offset from current pen location}
    end;

  TPolyVerbHdl = ^TPolyVerbPtr;
  TPolyVerbPtr = ^TPolyVerbRec;
  TPolyVerbRec =
    packed record
     f7, f6, f5, f4, f3:  boolean; {reserved; set to 0}
     fPolyClose:          boolean; {TRUE is same as PolyClose }
                                   { picture comment}
     fPolyFill :           boolean; {TRUE means fill polygon}
     fPolyFrame:          boolean; {TRUE means frame polygon}
    end;

  TDashedLineHdl = ^TDashedLinePtr;
  TDashedLinePtr = ^TDashedLineRec;
  TDashedLineRec =
    packed record
     offset:     SInt8;    {offset into pattern for first dash}
     centered:   SInt8;    {reserved; set to 0}
     intervals:  array[0..5] of SInt8;{points for drawing and not drawing dashes}
    end;

  TLineWidthHdl = ^TLineWidthPtr;
  TLineWidthPtr = ^TLineWidth;
  TLineWidth = Point;  {v = numerator, h = denominator}



procedure InitUnitPostscript;
procedure BeginPostScript;
procedure EndPostScript;
procedure MyFlushGrafPortState;
procedure MyFlushPostScriptState;
procedure SendPostscript(s : String255);
procedure DoPostScriptLine(s : String255);
procedure SetLineWidthPostscript(numerateur,denominateur : SInt16);
procedure MySetNewLineWidth(oldWidth,newWidth: TLineWidth);
procedure MyDrawXString(s : String255; ctr : Point; just, flip : SInt16; rot: Fixed);
procedure DrawTranslatedString(s : String255; decX,decY : double);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickDraw, fp, Sound, ToolUtils, QuickdrawText
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitDiagramFforum, MyStrings
    , UnitCarbonisation, UnitServicesMemoire, MyMathUtils, MyAssertions ;
{$ELSEC}
    ;
    {$I prelink/PostScript.lk}
{$ENDC}


{END_USE_CLAUSE}












var gLastNumerateurDansSetLineWidth : SInt16;
    gLastDenominateurDansSetLineWidth : SInt16;


procedure InitUnitPostscript;
begin
  gLastNumerateurDansSetLineWidth := 1;
  gLastDenominateurDansSetLineWidth := 1;
end;


procedure BeginPostScript;
begin
  PicComment(PostScriptBegin,0,NIL);
end;

procedure EndPostScript;
begin
  PicComment(PostScriptEnd,0,NIL);
end;



procedure MyFlushGrafPortState;
var
  penInfo: PenState;
begin
  GetPenState(penInfo);   {save pen size}
  PenSize(0,0);           {make it invisible}
  Moveto(-3200,-3200);    {move the pen way off the page in }
                          { case the printer driver draws a dot }
                          { even with a pen size of (0,0)}
  Line(0,0);              {go through QDProcs.lineProc}
                          {next, restore pen size}
  PenSize(penInfo.pnSize.h, penInfo.pnSize.v);
end;


procedure MyFlushPostScriptState;
begin
  PicComment(PostScriptBegin, 0, NIL);
  PicComment(PostScriptEnd, 0, NIL);
end;



procedure SendPostscript(s : String255);
var PostScriptParcel : handle;
begin
  s := Concat(s,chr(13));  {add a carriage return}
  PostScriptParcel := AllocateMemoryHdl(LENGTH_OF_STRING(s));
  MoveMemory(MAKE_MEMORY_POINTER(POINTER_VALUE(@s[1])),PostScriptParcel^,LENGTH_OF_STRING(s));
  PicComment(PostScriptHandle,LENGTH_OF_STRING(s),PostScriptParcel);
  DisposeMemoryHdl(PostScriptParcel);
end;

procedure DoPostScriptLine(s : String255);
begin
  SendPostscript(s);
end;



{Listing B-10 Using the SetLineWidth picture comment}
procedure MySetNewLineWidth(oldWidth,newWidth : TLineWidth);
var
  tempWidthH : TLineWidthHdl;
begin
  tempWidthH := TLineWidthHdl(AllocateMemoryHdl(SizeOf(TLineWidth)));
  tempWidthH^^.v := oldWidth.h;
  tempWidthH^^.h := oldWidth.v;
  PicComment(SetLineWidth, SizeOf(TLineWidth), Handle(tempWidthH));
  tempWidthH^^ := newWidth;
  PicComment(SetLineWidth, SizeOf(TLineWidth), Handle(tempWidthH));
  DisposeMemoryHdl(Handle(tempWidthH));
end;


{cf note technique n¡175}
procedure SetLineWidthPostscript(numerateur,denominateur : SInt16);
const SetLineWidth = 182;
type linefactorhandle = ^linefactorPtr;
     linefactorPtr =  ^linefactor;
     linefactor = record
                  num,denom : SInt16;
                end;
var lfh : linefactorhandle;
    kind : SInt16;
    taille : SInt16;
begin
  lfh := linefactorHandle(AllocateMemoryHdl(sizeof(linefactor)));

  if DoitGenererPostScriptCompatibleXPress and
    (gLastNumerateurDansSetLineWidth <> 0) and (gLastDenominateurDansSetLineWidth <> 0) then
    begin  {on multiplie la taille du crayon par l'inverse pour revenir ˆ (1,1) }

      {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL}
      SWAP_INTEGER( @gLastNumerateurDansSetLineWidth);
      SWAP_INTEGER( @gLastDenominateurDansSetLineWidth);
      {$ENDC}

      lfh^^.num := gLastDenominateurDansSetLineWidth;
      lfh^^.denom := gLastNumerateurDansSetLineWidth;

      kind := SetLineWidth;
      taille := sizeof(linefactor);
      PicComment(kind,taille,Handle(lfh));

      {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL}
      SWAP_INTEGER( @gLastNumerateurDansSetLineWidth);
      SWAP_INTEGER( @gLastDenominateurDansSetLineWidth);
      {$ENDC}

    end;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL}
  SWAP_INTEGER( @numerateur);
  SWAP_INTEGER( @denominateur);
  {$ENDC}

  lfh^^.num := numerateur;
  lfh^^.denom := denominateur;


  kind := SetLineWidth;
  taille := sizeof(linefactor);
  PicComment(kind,taille,Handle(lfh));


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL}
  SWAP_INTEGER( @numerateur);
  SWAP_INTEGER( @denominateur);
  {$ENDC}

  DisposeMemoryHdl(Handle(lfh));


  gLastNumerateurDansSetLineWidth := numerateur;
  gLastDenominateurDansSetLineWidth := denominateur;
end;




{Listing B-3 Disabling line layout by using the LineLayoutOff and
             StringBegin picture comments}
type XArray = array[1..10] of SInt16;

procedure MyStringReconDemo (x : XArray; y : SInt16);
begin
  PicComment(LineLayoutOff,0,NIL);
  PicComment(StringBegin,0,NIL);
  {position each character of the word 'Test' using }
  { Moveto and DrawChar}
  Moveto(x[1],y); DrawChar('T');
  Moveto(x[2],y); DrawChar('e');
  Moveto(x[3],y); DrawChar('s');
  Moveto(x[4],y); DrawChar('t');
  {reenable the printer driver's line layout routines}
  PicComment(StringEnd,0,NIL);
  PicComment(LineLayoutOn,0,NIL);
end;

{Listing B-4 Displaying rotated text using picture comments}
procedure MyDrawXString(s : String255; ctr : Point; just, flip : SInt16; rot: Fixed);
var
  hT:         TTxtPicHdl;
  hC:         TCenterHdl;
  zeroRect :   Rect;
  pt:         Point;
  oldClip :    RgnHandle;
begin
  GetPen(pt);    {to preserve the pen position}
  hT := TTxtPicHdl(AllocateMemoryHdl(SizeOf(TTxtPicRec)));
  hC := TCenterHdl(AllocateMemoryHdl(SizeOf(TCenterRec)));
  with hT^^ do
  begin
     tJus := just;
     tFlip := flip;
     tAngle := - FixRound(rot); {counterclockwise}
     tLine := 0; {reserved}
     tCmnt := 0; {used internally by the printer driver}
     tAngleFixed := - rot;
  end;
  hC^^.y := Long2Fix(ctr.v);
  hC^^.x := Long2Fix(ctr.h);
  MyFlushPostScriptState; {see Listing B-2 on page B-11}
  PicComment(TextBegin,SizeOf(TTxtPicRec),Handle(hT));
  PicComment(TextCenter,SizeOf(TCenterRec),Handle(hC));
  {graphics state now has rotated/flipped coordinates}
  oldClip := NewRgn;
  GetClip(oldClip);
  SetRect(zeroRect,0,0,0,0);
  ClipRect(zeroRect);  {hides this MyDrawString from }
  MyDrawString(s);       { QuickDraw in the rotated }
                       { environment}
  ClipRect(MyGetRegionRect(oldClip));

  {now the "fallback" bitmap representation}
  {MyQDStringRotation(s, ctr, just, flip, rot);}  {A IMPLEMENTER !!}

  PicComment(TextEnd, 0, NIL);
  {set environment back to the original state}
  DisposeMemoryHdl(Handle(hT));
  DisposeMemoryHdl(Handle(hC));
  Moveto(pt.h, pt.v);  {restore the pen position}
end;



{ Displaying translated text using picture comments }
procedure DrawTranslatedPostScriptString(s : String255; decX,decY : double);
var
  hT:         TTxtPicHdl;
  hC:         TCenterHdl;
  zeroRect :   Rect;
  pt:         Point;
  oldClip :    RgnHandle;
begin
  GetPen(pt);    {to preserve the pen position}
  hT := TTxtPicHdl(AllocateMemoryHdl(SizeOf(TTxtPicRec)));
  hC := TCenterHdl(AllocateMemoryHdl(SizeOf(TCenterRec)));
  with hT^^ do
  begin
     tJus  := tJusLeft;
     tFlip := 0;
     tAngle := 0; {counterclockwise}
     tLine := 0; {reserved}
     tCmnt := 0; {used internally by the printer driver}
     tAngleFixed := Long2Fix(0);
  end;
  hC^^.y := X2Fix(0.0);
  hC^^.x := X2Fix(0.0);


  MyFlushPostScriptState; {see Listing B-2 on page B-11}
  PicComment(TextBegin,SizeOf(TTxtPicRec),Handle(hT));
  PicComment(TextCenter,SizeOf(TCenterRec),Handle(hC));
  {graphics state now has rotated/flipped coordinates}
  oldClip := NewRgn;
  GetClip(oldClip);
  SetRect(zeroRect,0,0,0,0);
  ClipRect(zeroRect);  { hides this MyDrawString from }

  DoPostScriptLine(Concat(ReelEnString(decX),' ',ReelEnString(decY),' translate'));

  MyDrawString(s);       { QuickDraw in the rotated }
                       { environment}
  ClipRect(MyGetRegionRect(oldClip));

  {now the "fallback" bitmap representation}

  {BeginPostScript;
  MyDrawString(s);
  EndPostScript;}
  {MyQDStringRotation(s, ctr, just, flip, rot);}  {A IMPLEMENTER !!}


  PicComment(TextEnd, 0, NIL);
  {set environment back to the original state}
  DisposeMemoryHdl(Handle(hT));
  DisposeMemoryHdl(Handle(hC));

  DoPostScriptLine(Concat(ReelEnString(-decX),' ',ReelEnString(-decY),' translate'));

  Moveto(pt.h, pt.v);  {restore the pen position}
end;


procedure DrawTranslatedString(s : String255; decX,decY : double);
begin
  if false and DoitGenererPostScriptCompatibleXPress
    then
      begin
        MyFlushPostScriptState;
        DoPostScriptLine(Concat(ReelEnString(decX),' ',ReelEnString(decY),' translate'));
        MyFlushPostScriptState;
        MyDrawString(s);
        MyFlushPostScriptState;
        DoPostScriptLine(Concat(ReelEnString(-decX),' ',ReelEnString(-decY),' translate'));
        MyFlushPostScriptState;
      end
    else
      begin
        {La version PostScript...}
         DrawTranslatedPostScriptString(s,decX-10,decY);

        {... et la version quickdraw, que l'on cache a PostScript}


         BeginPostScript;
         Move(RoundToL(decX),RoundToL(decY));
         MyDrawString(s);
         EndPostScript;

      end;
end;


type PointArrayPtr = ^PointArray;
     PointArray = array[0..10] of Point;

procedure MyDefineVertices(var p,q : PointArrayPtr);
const
  cx = 280;   {x coordinate for center point}
  cy = 280;   {y coordinate for center point}
  r0 = 200;   {radius}
  kN = 4;     {number of vertices for PostScript}
  kM = 6;     {number of vertices for QuickDraw approximation}
begin
  {the array p^ contains the control points for the BŽzier curve}
  SetPt(p^[0],cx + r0,cy);
  SetPt(p^[1],cx,cy + r0);
  SetPt(p^[2],cx - r0,cy);
  SetPt(p^[3],cx,cy - r0);
  p^[4] := p^[0];
  {q^ contains the points for a QuickDraw approximation of the curve}
  q^[0] := p^[0];
  SetPt(q^[1],cx,cy + RoundToL(0.7 * (p^[1].v - cy)));
  SetPt(q^[2],(p^[1].h + p^[2].h) DIV 2,
        (p^[1].v + p^[2].v) DIV 2);
  SetPt(q^[3],cx + RoundToL(0.8 * (p^[2].h - cx)),cy);
  SetPt(q^[4],q^[2].h,cy + cy - q^[2].v);
  SetPt(q^[5],q^[1].h,cy + cy - q^[1].v);
  q^[6] := q^[0];
end;


{ Listing B-6 Drawing polygons }
procedure MyPolygonDemo(kN,kM : SInt16);
var
  p, q:                PointArrayPtr;
  aPolyVerbH:          TPolyVerbHdl;
  i :                   SInt16;
  clipRgn, polyRgn :    RgnHandle;
  zeroRect :            Rect;
begin
  p := PointArrayPtr(AllocateMemoryPtr(SizeOf(Point) * (kN + 1)));
  q := PointArrayPtr(AllocateMemoryPtr(SizeOf(Point) * (kM + 1)));
  if (p = NIL) or (q = NIL) then SysBeep(0); {DoErr(kMemError)};
  MyDefineVertices(p,q);
  PenNormal;  {first show the standard QuickDraw polygon}
  Moveto(p^[0].h,p^[0].v);
  for i := 1 to kN do
     Lineto(p^[i].h,p^[i].v);
  PenSize(2,2);  {now show the same polygon "smoothed"}
  PenPat(grayPattern);
  {first, the PostScript representation, clipped from QuickDraw}
  aPolyVerbH  :=
     TPolyVerbHdl(AllocateMemoryHdl(SizeOf(TPolyVerbRec)));
  if aPolyVerbH <>  NIL then
     with aPolyVerbH^^ do
     begin
        fPolyFrame := TRUE;
        fPolyFill := FALSE;
        fPolyClose := FALSE;
        {compare with the result for TRUE!}
        f3 := FALSE;
        f4 := FALSE;
        f5 := FALSE;
        f6 := FALSE;
        f7 := FALSE;
     end;
  Moveto(p^[0].h,p^[0].v);
  PicComment(PolyBegin,0,NIL);
  {picComment(PolyClose,0,NIL); only if }
  { fPolyClose = TRUE, above!}
  PicComment(PolySmooth,SizeOf(TPolyVerbRec),
              Handle(aPolyVerbH));
  clipRgn := NewRgn;
  GetClip(clipRgn);
  ClipRect(zeroRect);
  for i := 1 to kN do
     Lineto(p^[i].h,p^[i].v);
  {next, the QuickDraw approximation of the smoothed }
  { polygon, invisible for PostScript because of PolyIgnore}
  SetClip(clipRgn);
  PicComment(PolyIgnore,0,NIL);
  polyRgn := NewRgn;
  OpenRgn;
  Moveto(q^[0].h,q^[0].v);
  for i := 1 to kM do
     Lineto(q^[i].h,q^[i].v);
  CloseRgn(polyRgn);
  FrameRgn(polyRgn);   {or FillRgn, if fPolyFill above is TRUE}
  PicComment(PolyEnd,0,NIL);
  DisposeMemoryHdl(Handle(aPolyVerbH));
  DisposeRgn(polyRgn);
  DisposeMemoryPtr(Ptr(p));
  DisposeMemoryPtr(Ptr(q));
end;


{Listing B-8 Using the RotateCenter, RotateBegin, and RotateEnd picture comments }
procedure MyPSRotatedRect(r : Rect; offset : Point; angle: SInt16);
{does the rectangle rotation for the PostScript LaserWriter driver}
{uses the RotateCenter, RotateBegin, and RotateEnd picture comments, }
{ and the "magic" pattern mode 23 to hide the drawing from QuickDraw}
const
  magicPen = 23;
var
  rInfo:      TRotationHdl;
  rCenter:    TCenterHdl;
  oldPenMode: SInt16;
begin
  rInfo := TRotationHdl(AllocateMemoryHdl(SizeOf(TRotationRec)));
  rCenter := TCenterHdl(AllocateMemoryHdl(SizeOf(TCenterRec)));
  if (rInfo = NIL) or (rCenter = NIL)
     then MyDebugStr('AllocateMemoryHdl failed');
  with rInfo^^ do
  begin
     rFlip := 0;
     rAngle := - angle;
     rAngleFixed := BitShift(SInt32(rAngle),16);
  end;
  with rCenter^^ do
  begin
     x := Long2Fix(offset.h);
     y := Long2Fix(offset.v);
  end;
  Moveto(r.left,r.top);
  MyFlushGrafPortState;   {see Listing B-1 on page B-10}
  PicComment(RotateCenter,SizeOf(TCenterRec),Handle(rCenter));
  PicComment(RotateBegin,SizeOf(TRotationRec),Handle(rInfo));
  oldPenMode := GetPortPenMode(qdThePort);
  PenMode(magicPen);
  FrameRect(r);
  PenMode(oldPenMode);
  PicComment(RotateEnd,0,NIL);
  DisposeMemoryHdl(Handle(rInfo));
  DisposeMemoryHdl(Handle(rCenter));
end;



{Listing B-7 Using picture comments to rotate graphics}
procedure MyRotateDemo;
const
  angle = 30;
var
  spinRect :   Rect;
  delta:      Point;
begin
  SetRect(spinRect,100,100,300,200);
  with spinRect do SetPt(delta,(right - left) DIV 2,
                        (bottom - top) DIV 2);
  PenSize(2,2);
  PenPat(lightGrayPattern);
  FrameRect(spinRect); {show the unrotated square}
  PenNormal;
  MyPSRotatedRect(spinRect,delta,angle);
  {QuickDraw equivalent of the rotated object, hidden from the PostScript }
  { driver because of PostScriptBegin and PostScriptEnd}
  PicComment(PostScriptBegin, 0, NIL);
  (*  MyQDRotatedRect(spinRect, delta, angle);  *)    {A IMPLEMENTER !!}
  PicComment(PostScriptEnd, 0, NIL);
end;




{Listing B-9 Using the DashedLine picture comment}
procedure DashDemo;
const
  magicPen = 23;
  cx = 280;      {center along x-axis}
  cy = 280;      {center along y-axis}
  r0 = 200;      {radius}
var
  dashHdl :    TDashedLineHdl;
  i :          SInt16;
  a, rad:     double;
begin
  PenSize(2,2);
  {First the PostScript picture comment version. Pattern mode }
  { 23 makes the line drawing invisible to QuickDraw.}
  PenMode(magicPen);
  dashHdl := TDashedLineHdl(AllocateMemoryHdl(SizeOf(TDashedLineRec)));
  if dashHdl <> NIL then
  with dashHdl^^ do
  begin
     offset := 4;       {just for fun}
     centered := 0;     {currently ignored--set to 0}
     intervals[0] := 2; {number of interval specs}
     intervals[1] := 4; {this means 4 points on ...}
     intervals[2] := 6; {... and 6 points off}
     PicComment(DashedLine, SizeOf(TDashedLineRec), Handle(dashHdl));
  end;
  rad := 3.14159 / 180;   {conversion degrees -> radians}
  for i := 0 to 9 do
  begin    {draw some dashed lines}
     a := i * 20 * rad;
     Moveto(cx, cy);
     Line(RoundToL(r0 * cos(a)), - RoundToL(r0 * sin(a)));
  end;
  PicComment(DashedStop, 0, NIL);  {that's enough!}
  DisposeMemoryHdl(Handle(dashHdl));
  PenMode(srcOr);  {no magic any more}
  {Now, the QuickDraw version. The PostScript driver must }
  { ignore it, so enclose it between PostScriptBegin and }
  { PostScriptEnd comments.}
  PicComment(PostScriptBegin, 0, NIL);
  PenSize(2,2);
  for i := 0 to 9 do
  begin
     Moveto(cx,cy);
     (* MyDashedQDLine(RoundToL(r0 * cos(i * 20 * rad)),
                     - RoundToL(r0 * sin(i * 20 * rad)), dashHdl); *)  {A IMPLEMENTER !!}
  end;
  PicComment(PostScriptEnd, 0, NIL);
end;




procedure MyLineWidthDemo;
const
  y0 = 50;    {top left of demo}
  x0 = 50;
  d0 = 440;   {length of horizontal lines}
  e0 = 5;     {distance between lines}
  kN = 5;     {number of lines}
var
  oldWidth,newWidth:   TLineWidth;
  i,y :               SInt16;
begin
  PenNormal;
  y := y0;
  SetPt(oldWidth,1,1);             {initial line width = 1.0}
  for i := 1 to 5 do
  begin
     SetPt(newWidth,4,i);
     {want to set it to i/4 = 0.25, 0.50, 0.75 ...}
     MySetNewLineWidth(oldWidth,newWidth);
     Moveto(x0, y);
     Line(d0, 0);
     y := y + e0;
     oldWidth := newWidth;
  end;
end;



procedure DoPostScriptComments;
begin
  {first, the simple example}
  PicComment(PostScriptBegin,0,NIL);
  DoPostScriptLine('100 100 Moveto 0 100 rlineto 100 0 rlineto ');
  DoPostScriptLine('0 -100 rlineto -100 0 rlineto');
  DoPostScriptLine('stroke');
  Moveto(30,30);
  MyDrawString('This text does not appear on PostScript printers.');
  PicComment(PostScriptEnd,0,NIL);
end;





end.
