UNIT UnitGeometrie;


INTERFACE



 USES UnitDefCassio , QuickDraw , fp;





  function  ADroite(x1,y1,x2,y2,xM,yM : SInt32) : boolean;
  procedure Intersection(xA1,yA1,xA2,yA2,XB1,yB1,xB2,YB2 : SInt32; var x,y : SInt32);
  function InterpolerRectangles(rectA,rectB : rect; n,k : SInt32) : rect;
  function SegmentIntersecteRect(M1,M2 : Point; theRect : rect) : boolean;

	function MakeRect(left, top, right, bottom : SInt32) : Rect;
	function MakePoint(h,v : SInt32) : Point;
	function CentreDuRectangle(theRect : rect) : Point;
	procedure LocalToGlobalRect(var myrect : rect);
	procedure GlobalToLocalRect(var myrect : rect);

  function CenterRectInRect(original,bigRect : rect) : rect;
	procedure DragLine(whichWindow : WindowPtr; orientation : SInt16; UtiliseHiliteMode : boolean; minimum, maximum, step : SInt32; var positionSouris, index : SInt32; Action : ProcedureTypeWithLongint);
	procedure DessineLigne(source,dest : Point);
  procedure DessineFleche(source,dest : Point; longueur_max_pointe : double);

	function BoutonAppuye(whichWindow : WindowPtr; Rectangle : rect) : boolean;

	procedure HiliteRect(unRect : rect);
	procedure PondreLaFenetreCommeUneGouttedEau(windowRect : rect; arriveeDeLaFenetre : boolean);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    LowMem, ToolUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, MyMathUtils, UnitCarbonisation, SNEvents, UnitRapport ;
{$ELSEC}
    ;
    {$I prelink/Geometrie.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure HiliteRect(unRect : rect);
  var hiliteMode : ByteParameter;
	begin
	  MyEraseRect(unRect);
	  MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
	  hiliteMode := LMGetHiliteMode;
    BitClr(@hiliteMode,pHiliteBit);
    LMSetHiliteMode(hiliteMode);

		InvertRect(unRect);
	end;


procedure PondreLaFenetreCommeUneGouttedEau(windowRect : rect; arriveeDeLaFenetre : boolean);
	const
		largeurPetitRect = 14;
		hauteurMenuBar = 20;
	var
		menuTinyRect, centralTinyRect : rect;
begin  {$unused arriveeDeLaFenetre, windowRect}
	SetRect(menuTinyRect, 0, 0, 2, 2);
	OffsetRect(menuTinyRect,(GetScreenBounds.right) div 2, hauteurMenuBar);
	centralTinyRect := menuTinyRect;
	OffsetRect(centralTinyRect, 0,(GetScreenBounds.bottom - hauteurMenuBar) div 2);
	InsetRect(centralTinyRect, -(largeurPetitRect div 2), -(largeurPetitRect div 2));

  {
	if arriveeDeLaFenetre then
		begin
			ZoomRect(menuTinyRect, centralTinyRect, klinear, 5, false);
			ZoomRect(centralTinyRect, windowRect, kZoomOut, 5, false);
		end
	else
		begin
			ZoomRect(windowRect, centralTinyRect, kZoomIn, 5, false);
			ZoomRect(centralTinyRect, menuTinyRect, klinear, 5, false);
		end;
  }
end;



{ renvoie true si M est a droite de la droite M1,M2}
function  ADroite(x1,y1,x2,y2,xM,yM : SInt32) : boolean;
var dx,dy : double;
begin
  dx := x1-x2;
  dy := y1-y2;
  ADroite := (xM-x1)*dy-(yM-y1)*dx < 0;
end;


{renvoie dans x,y l'Intersection des droites (A1,A2) et (B1,B2)}
procedure Intersection(xA1,yA1,xA2,yA2,XB1,yB1,xB2,YB2 : SInt32; var x,y : SInt32);
var dxA,dyA,dxB,dyB,A,B,delta : double;
begin
  dxA := xA1-xA2;
  dyA := yA1-yA2;
  dxB := xB1-xB2;
  dyB := yB1-yB2;
  A := xA1*1.0*dyA-yA1*1.0*dxA;
  B := xB1*1.0*dyB-yB1*1.0*dxB;
  delta := -(dyA*dxB-dxA*dyB);
  if delta <> 0.0
    then
      begin
        x := Trunc((dxA*B-dxB*A)*1.0/delta+0.5);
        y := Trunc((dyA*B-dyB*A)*1.0/delta+0.5);
      end
    else  {erreur!!! droites paralleles !!! => on renvoie A1}
      begin
        x := xA1;
        y := yA1;
      end;
end;


{on renvoye A + u(B-A)}
function InterpolerExtended(A,B : double;u : double) : double;
begin
  InterpolerExtended := A + u*(B-A);
end;

{renvoie le k-ieme rectangle d'interpolation entre
  rectA = le 0-ieme rectangle
  rectB = le n-ieme rectangle }
function InterpolerRectangles(rectA,rectB : rect; n,k : SInt32) : rect;
var xMilA,yMilA,xMilB,yMilB,xMilRes,yMilRes : double;
    largA,largB,hautA,hautB,hautRes,largRes : double;
    ratio : double;
    result : rect;
begin

  if n <> 0
    then ratio := (k*1.0)/(n*1.0)
    else ratio := 0;  {erreur !! on va donc renvoyer rectA...}

  xMilA := 0.5 * (rectA.left + rectA.right);
  yMilA := 0.5 * (rectA.top + rectA.bottom);

  xMilB := 0.5 * (rectB.left + rectB.right);
  yMilB := 0.5 * (rectB.top + rectB.bottom);

  xMilRes := InterpolerExtended(xMilA,xMilB,ratio);
  yMilRes := InterpolerExtended(yMilA,yMilB,ratio);

  largA := rectA.right  - rectA.left;
  hautA := rectA.bottom - rectA.top;

  largB := rectB.right  - rectB.left;
  hautB := rectB.bottom - rectB.top;

  largRes := InterpolerExtended(largA,largB,ratio);
  hautRes := InterpolerExtended(hautA,hautB,ratio);

  with result do
    begin
      left    := Trunc(xMilRes - 0.5*largRes + 0.49999);
      right   := Trunc(xMilRes + 0.5*largRes + 0.49999);
      top     := Trunc(yMilRes - 0.5*hautRes + 0.49999);
      bottom  := Trunc(yMilRes + 0.5*hautRes + 0.49999);
    end;

  InterpolerRectangles := result;
end;


{renvoie true si le segment M1-M2 intersecte le rectangle theRect}
function SegmentIntersecteRect(M1,M2 : Point; theRect : rect) : boolean;
var auxRect,inter : rect;
    droite,tousDuMemeCote : boolean;
begin
  InSetRect(theRect,-3,-3);
  if PtInRect(M1,theRect) or PtInRect(M2,theRect) then
    begin
      SegmentIntersecteRect := true;
      exit;
    end;

  {les points M1 et M2 sont en dehors de theRect}
  auxRect := MakeRect(Min(M1.h,M2.h)-1,Min(M1.v,M2.v)-1,Max(M1.h,M2.h)+1,Max(M1.v,M2.v)+1);

  {si les bounding box sont disjointes, pas d'intersection...}
  if not(SectRect(auxRect,theRect,inter)) then
    begin
      SegmentIntersecteRect := false;
      exit;
    end;

  {les quatre angles du rectangle sont-ils du meme cote ?}
  with theRect do
    begin
      tousDuMemeCote := true;
      droite := ADroite(M1.h,M1.v,M2.h,M2.v,left,top);
      tousDuMemeCote := tousDuMemeCote and (droite = ADroite(M1.h,M1.v,M2.h,M2.v,left,bottom));
      tousDuMemeCote := tousDuMemeCote and (droite = ADroite(M1.h,M1.v,M2.h,M2.v,right,bottom));
      tousDuMemeCote := tousDuMemeCote and (droite = ADroite(M1.h,M1.v,M2.h,M2.v,right,top));
    end;

  SegmentIntersecteRect := not(tousDuMemeCote);
end;



function MakeRect(left, top, right, bottom : SInt32) : Rect;
	var
		result : Rect;
begin
	SetRect(result, left, top, right, bottom);
	MakeRect := result;
end;

function MakePoint(h,v : SInt32) : Point;
var result : Point;
begin
  result.h := h;
  result.v := v;
  MakePoint := result;
end;

function CentreDuRectangle(theRect : rect) : Point;
var result : Point;
begin
  result.h := (theRect.left+theRect.right) div 2;
  result.v := (theRect.top+theRect.bottom) div 2;
  CentreDuRectangle := result;
end;


procedure LocalToGlobalRect(var myrect : rect);
begin
	LocalToGlobal(myrect.topLeft);
	LocalToGlobal(myrect.botRight);
end;

procedure GlobalToLocalRect(var myrect : rect);
begin
	GlobalToLocal(myrect.topLeft);
	GlobalToLocal(myrect.botRight);
end;


function CenterRectInRect(original,bigRect : rect) : rect;
var largeur,hauteur : SInt32;
    a,b : SInt32;
begin
  largeur := original.right - original.left;
  hauteur := original.bottom - original.top;

  a := (bigRect.left + bigRect.right  - largeur) div 2;
  b := (bigRect.top  + bigRect.bottom - hauteur) div 2;

  CenterRectInRect := MakeRect(a,b,a+largeur,b+hauteur);
end;


procedure DragLine(whichWindow : WindowPtr; orientation : SInt16; UtiliseHiliteMode : boolean; minimum, maximum, step : SInt32; var positionSouris, index : SInt32; Action : ProcedureTypeWithLongint);
	var
		epaisseur : SInt16;
		mouseLoc : Point;
		DernierePositionDessinee : SInt32;
		DragCursor : CursHandle;
		oldPort : grafPtr;

	procedure DrawLine(position : SInt32);
		var
			unRect : rect;
	begin
	  SetPortByWindow(whichWindow);

		if orientation = kDragVerticalLine then
			SetRect(unRect, position, 0, position + epaisseur, QDGetPortBound.bottom)
		else
			SetRect(unRect, 0, position, QDGetPortBound.right, position + epaisseur);
		if UtiliseHiliteMode then
			HiliteRect(unRect)
		else
			begin
				Moveto(unRect.left, unRect.top);
				Lineto(unRect.right, unRect.bottom);
			end;
		DernierepositionDessinee := position;
	end;

begin
  GetPort(oldPort);

	if (step <= 0) then
		step := 1;
	if (maximum < minimum) then
		maximum := minimum;

	if positionSouris < minimum then
		positionSouris := minimum;
	if positionSouris > maximum then
		positionSouris := maximum;

	index := (positionSouris - minimum) div step;

	if StillDown then
		begin
		  SetPortByWindow(whichWindow);
			if UtiliseHiliteMode then
				epaisseur := 2
			else
				begin
					PenPat(grayPattern);
					PenSize(2, 2);
					PenMode(PatXor);
					epaisseur := 0;
				end;

			if orientation = kDragVerticalLine then
				DragCursor := GetCursor(DragLineVerticalCurseurID)
			else
				DragCursor := GetCursor(DragLineHorizontalCurseurID);
			SafeSetCursor(DragCursor);

			DrawLine(positionSouris);
			ShareTimeWithOtherProcesses(2);    {draw !}

			while Button do
				begin
					GetMouse(mouseLoc);
					if orientation = kDragVerticalLine then
						positionSouris := mouseLoc.h
					else
						positionSouris := mouseLoc.v;
					if positionSouris < minimum then
						positionSouris := minimum;
					if positionSouris > maximum then
						positionSouris := maximum;
					if step < 4 then
						index := (positionSouris - minimum) div step
					else
						index := (positionSouris - minimum +(step div 2)) div step; { +(step div 2) : pour centrer les sauts}
					positionSouris := minimum + index * step;
					if positionSouris > maximum then
						positionSouris := maximum;

					if positionSouris <> DernierePositionDessinee then
						begin
							DrawLine(DernierePositionDessinee);
							DrawLine(positionSouris);
							Action(index);
							ShareTimeWithOtherProcesses(2); {draw !}
						end;
				end;
			DrawLine(dernierePositionDessinee);
			PenNormal;
			InitCursor;
			ShareTimeWithOtherProcesses(2); {draw !}
		end;
  SetPort(oldPort);
end;

procedure DessineLigne(source,dest : Point);
begin
  Moveto(source.h,source.v);
  Lineto(dest.h,dest.v);
end;

procedure DessineFleche(source,dest : Point; longueur_max_pointe : double);
var x,y,theta : double;
    angle_pointe_fleche : double;
    longueur_pointe_fleche : double;
    x0,y0 : SInt32;
begin

  DessineLigne(source,dest);

  x := dest.h - source.h;
  y := dest.v - source.v;

  theta := atan2(y,x);

  angle_pointe_fleche := 0.5;  {0.5 radians}

  longueur_pointe_fleche := 0.25 * sqrt(x*x + y*y);
  if longueur_pointe_fleche > longueur_max_pointe then
    longueur_pointe_fleche := longueur_max_pointe;

  x0 := RoundToL(dest.h - cos(theta + angle_pointe_fleche) * longueur_pointe_fleche);
  y0 := RoundToL(dest.v - sin(theta + angle_pointe_fleche) * longueur_pointe_fleche);
  DessineLigne(MakePoint(x0,y0),dest);

  x0 := RoundToL(dest.h - cos(theta - angle_pointe_fleche) * longueur_pointe_fleche);
  y0 := RoundToL(dest.v - sin(theta - angle_pointe_fleche) * longueur_pointe_fleche);
  DessineLigne(MakePoint(x0,y0),dest);

end;


function BoutonAppuye(whichWindow : WindowPtr; Rectangle : rect) : boolean;
	var
		test : boolean;
		oldPort : GrafPtr;
		mouseLoc : point;
begin
	test := false;
	if Button then
		begin
			GetPort(oldPort);
			SetPortByWindow(whichWindow);
			GetMouse(mouseLoc);
			test := PtInRect(mouseLoc, rectangle);
			SetPort(oldPort);
			ShareTimeWithOtherProcesses(2);
		end;
	BoutonAppuye := test;
end;


END.
