UNIT UnitTroisiemeDimension;


INTERFACE







 USES UnitDefCassio;


procedure InitUnitTroisiemeDimension;
procedure LibereMemoireUnitTroisiemeDimension;


function EnVieille3D : boolean;
function EnJolie3D : boolean;
function CassioEstEn3D : boolean;
procedure SetEnVieille3D(flag : boolean);
function Calculs3DMocheSontFaits : boolean;
procedure SetCalculs3DMocheSontFaits(flag : boolean);
function NomTexture3D : String255;


function GetBoundingRect3D(whichSquare : SInt16) : rect;
function GetRect3DDessus(whichSquare : SInt16) : rect;
function GetRect3DDessous(whichSquare : SInt16) : rect;
function GetOthellier3DVistaBuffer : rect;
function GetRectEscargot : rect;
function GetRectEscargotGlobal : rect;

procedure SetBoundingRect3D(whichSquare : SInt16; whichRect : rect);
procedure SetRect3DDessus(whichSquare : SInt16; whichRect : rect);
procedure SetRect3DDessous(whichSquare : SInt16; whichRect : rect);
procedure SetOthellier3DVistaBuffer(whichRect : rect);
procedure SetRectEscargot(whichRect : rect);

procedure CalculerRect3D(square : SInt16);
function GetRectAreteVisiblePion3DPourPionDelta(x,QuelGenreDeMarque : SInt16) : rect;
function GetRectPionDessous3DPourPionDelta(x,QuelGenreDeMarque : SInt16) : rect;
procedure CalculateRectEscargotGlobal;

procedure DessinePlateau3D(avecDessinFondNoir : boolean);
procedure DessineDessusPion3D(x,coul : SInt16);
procedure DessinePion3D(x,coul : SInt16);
procedure Dessine3D(const position : plateauOthello; avecBruitage : boolean);
procedure DetermineParRecoupement(i,j,k : SInt16);

procedure SetPositionDemandeCoup3D;
procedure SetPositionScore3D;
procedure SetPositionMeilleureSuite3D;
procedure GetPositionCorrecteNumeroDuCoup3D(square : SInt16; var result : Point);

function  PtInPlateau3D(loc : Point; var caseCliquee : SInt16) : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitCurseur, UnitGeometrie, UnitCassioSounds, UnitBufferedPICT, UnitStrategie, UnitServicesMemoire
    , Unit3DPovRayPicts, UnitCarbonisation, MyMathUtils, MyFonts, UnitCalculCouleurCassio, UnitRapport, UnitGeometrie, UnitPositionEtTrait
     ;
{$ELSEC}
    ;
    {$I prelink/TroisiemeDimension.lk}
{$ENDC}


{END_USE_CLAUSE}











type
     Tableintersection3D = array[0..8,0..8] of point;
     Tableintersection3DPtr =  ^Tableintersection3D;
     Tableintersection3DHdl =  ^Tableintersection3DPtr;
     TableRect3D = array[11..88] of rect;
     TableRect3DPtr =  ^TableRect3D;
     TableRect3DHdl =  ^TableRect3DPtr;


var Y3D,x3Dbas,x3DHaut,x3DGauche,x3DDroite : array[0..8] of SInt32;
    intersection3D : Tableintersection3DHdl;
    rect3DDessus,rect3DDessous : TableRect3DHdl;
    boundingRect3D : TableRect3DHdl;
    plat3Deffectif : plateauOthello;
    vistaBufferRect : rect;
    escargotRect : rect;
    escargotGlobalRect : rect;

    enVieille3DMoche : boolean;
    calculs3Dfaits : boolean;



procedure SetPositionsTextesWindowPlateau;     external;
procedure SetOthellierEstSale(square : SInt16; flag : boolean);     external;


procedure InitUnitTroisiemeDimension;
begin
  intersection3D := NIL;
  rect3DDessus := NIL;
  rect3DDessous := NIL;
  boundingRect3D := NIL;

  intersection3D := Tableintersection3DHdl(AllocateMemoryHdl(sizeof(Tableintersection3D)));
  rect3DDessus := TableRect3DHdl(AllocateMemoryHdl(sizeof(TableRect3D)));
  rect3DDessous := TableRect3DHdl(AllocateMemoryHdl(sizeof(TableRect3D)));
  boundingRect3D := TableRect3DHdl(AllocateMemoryHdl(sizeof(TableRect3D)));


  MemoryFillChar(@plat3Deffectif,sizeof(plat3Deffectif),chr(pionVide));
end;


procedure LibereMemoireUnitTroisiemeDimension;
begin
  if intersection3D <> NIL then DisposeMemoryHdl(Handle(intersection3D));
  if rect3DDessus <> NIL then DisposeMemoryHdl(Handle(rect3DDessus));
  if rect3DDessous <> NIL then DisposeMemoryHdl(Handle(rect3DDessous));
  if boundingRect3D <> NIL then DisposeMemoryHdl(Handle(boundingRect3D));

  intersection3D := NIL;
  rect3DDessus := NIL;
  rect3DDessous := NIL;
  boundingRect3D := NIL;
end;


procedure SetEnVieille3D(flag : boolean);
begin
  enVieille3DMoche := flag;
end;

function EnVieille3D : boolean;
begin
  EnVieille3D := enVieille3DMoche and not(gCouleurOthellier.estPovRayEn3D);
end;

function EnJolie3D : boolean;
begin
  EnJolie3D := gCouleurOthellier.estPovRayEn3D;
end;

function CassioEstEn3D : boolean;
begin
  CassioEstEn3D := (enVieille3DMoche or gCouleurOthellier.estPovRayEn3D);
end;

function Calculs3DMocheSontFaits : boolean;
begin
  Calculs3DMocheSontFaits := calculs3Dfaits;
end;

procedure SetCalculs3DMocheSontFaits(flag : boolean);
begin
  calculs3Dfaits := flag;
end;

function NomTexture3D : String255;
begin
  NomTexture3D := 'blah';
  NomTexture3D := gCouleurOthellier.nomFichierTexture;
end;


function GetBoundingRect3D(whichSquare : SInt16) : rect;
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (boundingRect3D <> NIL)
    then GetBoundingRect3D := boundingRect3D^^[whichSquare]
    else GetBoundingRect3D := MakeRect(0,0,0,0);
end;

function GetRect3DDessus(whichSquare : SInt16) : rect;
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (rect3DDessus <> NIL)
    then GetRect3DDessus := rect3DDessus^^[whichSquare]
    else GetRect3DDessus := MakeRect(0,0,0,0);
end;

function GetRect3DDessous(whichSquare : SInt16) : rect;
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (rect3DDessous <> NIL)
    then GetRect3DDessous := rect3DDessous^^[whichSquare]
    else GetRect3DDessous := MakeRect(0,0,0,0);
end;

function GetOthellier3DVistaBuffer : rect;
begin
  GetOthellier3DVistaBuffer := vistaBufferRect;
end;


function GetRectEscargot : rect;
begin
  GetRectEscargot := escargotRect;
end;

function GetRectEscargotGlobal : rect;
begin
  GetRectEscargotGlobal := escargotGlobalRect;
end;

procedure SetBoundingRect3D(whichSquare : SInt16; whichRect : rect);
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (boundingRect3D <> NIL)
    then boundingRect3D^^[whichSquare] := whichRect;
end;

procedure SetRect3DDessus(whichSquare : SInt16; whichRect : rect);
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (rect3DDessus <> NIL)
    then rect3DDessus^^[whichSquare] := whichRect;
end;

procedure SetRect3DDessous(whichSquare : SInt16; whichRect : rect);
begin
  if (whichSquare >= 11) and (whichSquare <= 88) and (rect3DDessous <> NIL)
    then rect3DDessous^^[whichSquare] := whichRect;
end;

procedure SetOthellier3DVistaBuffer(whichRect : rect);
begin
  vistaBufferRect := whichRect;
end;

procedure SetRectEscargot(whichRect : rect);
begin
  escargotRect := whichRect;

  {
  WritelnNumDansRapport('escargotRect.left = ',escargotRect.left);
  WritelnNumDansRapport('escargotRect.top = ',escargotRect.top);
  WritelnNumDansRapport('escargotRect.right = ',escargotRect.right);
  WritelnNumDansRapport('escargotRect.bottom = ',escargotRect.bottom);
  }

  CalculateRectEscargotGlobal;
end;


procedure CalculateRectEscargotGlobal;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      escargotGlobalRect := escargotRect;
      LocalToGlobalRect(escargotGlobalRect);
      SetPort(oldPort);
    end;

  {
  WritelnNumDansRapport('escargotGlobalRect.left = ',escargotGlobalRect.left);
  WritelnNumDansRapport('escargotGlobalRect.top = ',escargotGlobalRect.top);
  WritelnNumDansRapport('escargotGlobalRect.right = ',escargotGlobalRect.right);
  WritelnNumDansRapport('escargotGlobalRect.bottom = ',escargotGlobalRect.bottom);
  }

end;

procedure DetermineParRecoupement(i,j,k : SInt16);
var x,y : SInt32;
begin
  Intersection(x3Dgauche[i],y3D[i],x3Ddroite[j],y3D[j],x3Dgauche[j],y3D[j],x3Ddroite[i],y3D[i],x,y);
  y3D[k] := y;
  Intersection(1,y3D[k],300,y3D[k],x3Dgauche[i],y3D[i],x3Dgauche[j],Y3D[j],X3Dgauche[k],y);
  Intersection(1,y3D[k],300,y3D[k],x3Ddroite[i],y3D[i],x3Ddroite[j],Y3D[j],X3Ddroite[k],y);
end;



procedure CalculerRect3D(square : SInt16);
var a,b,c,d,X,Y : SInt32;
    x1,x2,y1,y2,x3,x4,y3,y4 : SInt32;
    unRect : rect;
    larg,haut : SInt32;
begin
  X := platMod10[square];
  Y := platDiv10[square];
  x1 := (x3Dbas[X-1]+x3Dbas[X]) div 2;
  x2 := (x3Dhaut[X-1]+x3Dhaut[X]) div 2;
  y1 := y3D[8];
  y2 := y3D[0];
  x3 := 1;
  y3 := (y3D[Y-1]+y3D[Y]) div 2;
  x4 := 300;
  y4 := y3;



  Intersection(x1,y1,x2,y2,x3,y3,x4,y4,a,b);
  Intersection(1,b,300,b,x3Dbas[X],y3D[8],x3Dhaut[X],y3D[0],c,d);

  haut := b-y3D[Y-1];
  larg := Abs(a-c)-2;
  a := a+1;
  SetRect(unRect,a-larg,b-haut,a+larg,b+haut);

  if (X = 6) and (Y = 3) then InsetRect(unRect,1,0);
  if (Y = 1) and (X = 6) then InsetRect(unRect,1,0);
  SetRect3DDessous(square,unRect);

  OffsetRect(unRect,0,-4);
  if Y = 1 then OffsetRect(rect3Ddessous^^[square],0,-1);
  if Y > 6 then OffsetRect(unRect,0,-1);
  SetRect3DDessus(square,unRect);


end;


procedure SetValeurs3DParDefaut(var xbasDeb,xhautDeb,xBasFin,xHautFin,ybas,yhaut,Xcentre : SInt32);
begin
  xbasDeb := 8;
  xhautDeb := 83;
  Xcentre := 228;
  xbasFin := 2*Xcentre-xbasDeb;
  xhautFin := 2*Xcentre-xhautDeb;
  ybas := 261;
  yHaut := 40;
end;


procedure DoCalculs3D(xbasDeb,xhautDeb,xBasFin,xHautFin,ybas,yhaut : SInt32);
var a,b : SInt32;
    dxHaut,dxBas,x1Ext,x2Ext : double;
    i,j : SInt16;
    x1,x2,y1,y2,x3,x4,y3,y4 : SInt32;
  begin
    if not(gPendantLesInitialisationsDeCassio) then
      begin
        watch := GetCursor(watchcursor);
        SafeSetCursor(watch);
      end;

    dxBas := (xBasFin-XbasDeb)/8;
    dxHaut := (XHautFin-XhautDeb)/8;
    x1Ext := XbasDeb;
    x2Ext := XhautDeb;
    x3DBas[0] := MyTrunc(x1Ext+0.5);
    x3DHaut[0] := MyTrunc(x2Ext+0.5);
    for i := 1 to 8 do
      begin
        x1Ext := x1Ext+dxBas;
        x2Ext := x2Ext+dxHaut;
        x3DBas[i] := MyTrunc(x1Ext+0.5);
        x3DHaut[i] := MyTrunc(x2Ext+0.5);
      end;
    X3Dgauche[0] := XhautDeb;
    X3Dgauche[8] := XbasDeb;
    X3Ddroite[0] := Xhautfin;
    X3Ddroite[8] := XbasFin;
    y3D[0] := yHaut;
    y3D[8] := ybas;
    DetermineParRecoupement(0,8,4);
    DetermineParRecoupement(4,8,6);
    DetermineParRecoupement(4,6,5);
    DetermineParRecoupement(6,8,7);
    DetermineParRecoupement(0,4,2);
    DetermineParRecoupement(0,2,1);
    DetermineParRecoupement(2,4,3);
    for i := 1 to 8 do
    for j := 1 to 8 do
      CalculerRect3D(i+10*j);

    for i := 0 to 8 do
    for j := 0 to 8 do
      begin
        x1 := x3Dbas[i];
        x2 := x3Dhaut[i];
        y1 := y3D[8];
        y2 := y3D[0];
        x3 := 1;
        y3 := y3D[j];
        x4 := 300;
        y4 := y3;
        Intersection(x1,y1,x2,y2,x3,y3,x4,y4,a,b);
        intersection3D^^[i,j].h := a;
        intersection3D^^[i,j].v := b;
      end;

    SetOthellier3DVistaBuffer(MakeRect(x3Dgauche[8]-1,y3D[0]-15,x3Ddroite[8],y3D[8]+15));

    SetCalculs3DMocheSontFaits(true);
    InitCursor;
    RemettreLeCurseurNormalDeCassio;
    SetPositionsTextesWindowPlateau;
  end;

procedure DessineQuadrillageSurOthellier3D;
var i : SInt16;
begin
  PenPat(blackPattern);
  for i := 1 to 8 do
	  begin
	    Moveto(x3DGauche[i],Y3D[i]);
      Lineto(x3DDroite[i],Y3D[i]);
	    Moveto(x3DBas[i],Y3D[8]);
	    Lineto(x3DHaut[i],Y3D[0]);
	  end;
end;

procedure DessineLignesPerspectiveOthellier3D;
var i : SInt16;
begin
  PenPat(blackPattern);
  for i := 1 to 8 do
	  begin
	    Moveto(x3Dbas[i],Y3D[8]);
	    Lineto(x3Dhaut[i],Y3D[0]);
	  end;
end;


procedure DessinePlateau3D(avecDessinFondNoir : boolean);
var xbasDeb,xhautDeb,xBasFin,xHautFin,ybas,yhaut,Xcentre : SInt32;
    unRect : rect;
    myPoly : PolyHandle;
begin
  if wPlateauPtr <> NIL then
    begin

      if not(EnVieille3D)
        then
          begin
            DessinePositionAvecPovRay3D(MakeOthellierVide)
          end
        else
          begin
            SetValeurs3DParDefaut(xbasDeb,xhautDeb,xBasFin,xHautFin,ybas,yhaut,Xcentre);
				    if not(Calculs3DMocheSontFaits) then
				      DoCalculs3D(xbasDeb,xhautDeb,xBasFin,xHautFin,ybas,yhaut);

		        DetermineOthellierPatSelonCouleur(gCouleurOthellier.menuCmd,gCouleurOthellier.whichPattern);

			      unRect := GetWindowPortRect(wPlateauPtr);
			      PenPat(blackPattern);
			      if avecDessinFondNoir then
			        begin
			          MyEraseRect(unRect);
			          MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
			        end;

			      myPoly := OpenPoly;
			      Moveto(x3Dgauche[8]-1,y3D[8]);
			      Lineto(x3Ddroite[8],y3D[8]);
			      Lineto(x3Ddroite[0],y3D[0]-1);
			      Lineto(x3Dgauche[0]-1,y3D[0]-1);
			      Lineto(x3Dgauche[8]-1,y3D[8]);
			      ClosePoly;
			      ForeColor(gCouleurOthellier.couleurFront);
			      BackColor(gCouleurOthellier.couleurBack);
			      RGBForeColor(gCouleurOthellier.RGB);
			      FillPoly(myPoly,gCouleurOthellier.whichPattern);
			      ForeColor(BlackColor);
			      BackColor(WhiteColor);
			      PenSize(2,2);
			      FramePoly(myPoly);
			      KillPoly(myPoly);
			      PenNormal;

			      SetRect(unRect,xbasDeb,ybas,xbasFin,ybas+15);
			      FillRect(unRect,lightGrayPattern);

			      DessineQuadrillageSurOthellier3D;

			   end;

			MemoryFillChar(@plat3Deffectif,sizeof(plat3Deffectif),chr(pionVide));
    end;

  InvalidateAllCasesDessinEnTraceDeRayon;
end;

function GetRectAreteVisiblePion3DPourPionDelta(x,QuelGenreDeMarque : SInt16) : rect;
var result : rect;
begin
  {$UNUSED QuelGenreDeMarque}
  result := GetRect3DDessus(x);

  if EnVieille3D then
    begin
		  if platDiv10[x] > 4
		    then result.bottom := result.bottom-4
		    else result.bottom := result.bottom-3;
		  result.left := result.left+1;
		  result.right := result.right-1;
		end;

  GetRectAreteVisiblePion3DPourPionDelta := result;
end;

function GetRectPionDessous3DPourPionDelta(x,QuelGenreDeMarque : SInt16) : rect;
var result : rect;
begin
  {$UNUSED QuelGenreDeMarque}
  result := GetRect3DDessous(x);

  if EnVieille3D then
    begin
      if platDiv10[x] = 1 then OffsetRect(result,0,1);
    end;

  GetRectPionDessous3DPourPionDelta := result;
end;

procedure DessineDessusPion3D(x,coul : SInt16);
var unRect : rect;
    pnState : PenState;
begin
  if EnVieille3D then
    begin
		  case coul of
		    pionBlanc:
		         begin
		           PenSize(1,1);
		           unRect := GetRect3DDessus(x);
		           FillOval(unRect,whitePattern);
		           FrameOval(unRect);
		           InsetRect(unRect,0,1);
		           if platDiv10[x] > 4
		            then OffsetRect(unRect,0,-2)
		            else OffsetRect(unRect,0,-1);
		           GetPenState(pnState);
		           PenPat(grayPattern);
		           FrameArc(unRect,105,150);
		           SetPenState(pnState);
		         end;
		    pionNoir:
		         begin
		           PenSize(1,1);
		           unRect := GetRect3DDessus(x);
		           FillOval(unRect,blackPattern);
		           if (platDiv10[x] = 1)
		            then
		             begin
		              GetPenState(pnState);
		              PenPat(grayPattern);
		              FrameOval(unRect);
		              SetPenState(pnState);
		             end;
		           InsetRect(unRect,0,1);
		           if (platDiv10[x]) > 4
		            then OffsetRect(unRect,0,-2)
		            else OffsetRect(unRect,0,-1);
		           GetPenState(pnState);
		           PenPat(grayPattern);
		           FrameArc(unRect,105,150);
		           SetPenState(pnState);
		         end;
		  end; {case}
		end
  else
    DessinePion3D(x,coul);
end;


procedure DessinePion3D(x,coul : SInt16);
var unRect : rect;
    pnState : PenState;
    myPoly : PolyHandle;
    i,j,a : SInt16;
    a0,b0 : SInt32;
    longueur,hauteur : SInt32;
    oldClipRgn,uneRgn : RgnHandle;

  procedure clipToViewArea(x : SInt16);
     {x est la case ou on veut Dessiner}
    var r : rect;
    begin
      oldclipRgn := NewRgn;
      uneRgn := NewRgn;
      GetClip(oldClipRgn);
      r := QDGetPortBound;
      OpenRgn;
      FrameRect(r);
      if (platDiv10[x] <= 7) then
        if (GetCouleurOfSquareDansJeuCourant(x+10) <> pionVide) then
          FrameOval(GetRect3DDessus(x+10));
      CloseRgn(uneRgn);
      SetClip(uneRgn);
    end;

  procedure DeClipToViewArea;
        (******  toujours faire aller avec clipToViewArea   ****)
    begin
      SetClip(oldClipRgn);
      DisposeRgn(oldclipRgn);
      DisposeRgn(uneRgn);
    end;

begin
  if not(EnVieille3D)
    then
      begin
        DessinePionAvecPovRay3D(x,coul);
      end
    else
      begin
			  case coul of
			    pionBlanc:
			         begin
			           PenSize(1,1);
			           FillOval(GetRect3DDessous(x),blackPattern);
			           unRect := GetRect3DDessus(x);
			           FillOval(unRect,whitePattern);
			           FrameOval(unRect);
			           InsetRect(unRect,0,1);
			           if (platDiv10[x] > 4)
			            then OffsetRect(unRect,0,-2)
			            else OffsetRect(unRect,0,-1);
			           GetPenState(pnState);
			           PenPat(grayPattern);
			           FrameArc(unRect,105,150);
			           SetPenState(pnState);
			         end;
			    pionNoir:
			         begin
			           PenSize(1,1);
			           FillOval(GetRect3DDessous(x),whitePattern);
			           FrameOval(GetRect3DDessous(x));
			           unRect := GetRect3DDessus(x);
			           FillOval(unRect,blackPattern);
			           if (platDiv10[x] = 1)
			            then
			             begin
			              GetPenState(pnState);
			              PenPat(grayPattern);
			              FrameArc(unRect,107,-214);
			              SetPenState(pnState);
			             end;
			            InsetRect(unRect,0,1);
			            if (platDiv10[x]) > 4
			            then OffsetRect(unRect,0,-2)
			            else OffsetRect(unRect,0,-1);
			            GetPenState(pnState);
			            PenPat(grayPattern);
			            FrameArc(unRect,105,150);
			            SetPenState(pnState);
			         end;
			    pionVide:
			        begin
			          i := platMod10[x];
			          j := platDiv10[x];
			          myPoly := OpenPoly;
			          a0 := intersection3D^^[i-1,j-1].h;
			          b0 := intersection3D^^[i-1,j-1].v;
			          Moveto(a0,b0);
			          Lineto(intersection3D^^[i,j-1].h,intersection3D^^[i,j-1].v);
			          Lineto(intersection3D^^[i,j].h,intersection3D^^[i,j].v);
			          Lineto(intersection3D^^[i-1,j].h,intersection3D^^[i-1,j].v);
			          Lineto(a0,b0);
			          ClosePoly;
			          ForeColor(gCouleurOthellier.couleurFront);
			          RGBForeColor(gCouleurOthellier.RGB);
			          BackColor(gCouleurOthellier.couleurBack);
			          FillPoly(myPoly,gCouleurOthellier.whichPattern);
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenPat(blackPattern);
			          Moveto(a0,b0);
			          Lineto(intersection3D^^[i,j-1].h,intersection3D^^[i,j-1].v);
			          Moveto(intersection3D^^[i,j].h,intersection3D^^[i,j].v);
			          Lineto(intersection3D^^[i-1,j].h,intersection3D^^[i-1,j].v);
			          Moveto(x3Dbas[i-1],y3D[8]);
				        Lineto(X3Dhaut[i-1],Y3D[0]);
			          Moveto(x3Dbas[i],y3D[8]);
				        Lineto(X3Dhaut[i],Y3D[0]);
			          KillPoly(myPoly);
			          SetOthellierEstSale(x,false);
			        end;

			    pionMontreCoupLegal :
			       begin
			          clipToViewArea(x);
			          unRect := GetRect3DDessous(x);
			          OffsetRect(unRect,0,1);
			          InsetRect(unRect,1,1);
			          if platDiv10[x] = 5 then dec(unRect.bottom); {cinquieme rangee}
			          if gEcranCouleur
			             then
			               begin
			                 if not(gCouleurOthellier.EstTresClaire) or
			                    ((gCouleurOthellier.menuCmd <> BlancCmd) and
			                    (gCouleurOthellier.menuCmd <> JauneCmd) and
			                    (gCouleurOthellier.menuCmd <> BleuPaleCmd) and
			                    (gCouleurOthellier.menuCmd <> JaunePaleCmd))
			                   then
			                     begin
			                       ForeColor(gCouleurOthellier.couleurFront);
			                       BackColor(gCouleurOthellier.couleurBack);
			                       if gCouleurOthellier.estComposee
			                         then FillOval(unRect,blackPattern)
			                         else FillOval(unRect,grayPattern);
			                     end
			                   else
			                     begin
			                       ForeColor(gCouleurOthellier.couleurFront);
			                       BackColor(BlackColor);
			                       FillOval(unRect,grayPattern);
			                     end;
			                 ForeColor(BlackColor);
			                 BackColor(WhiteColor);
			               end
			             else
			               InvertOval(unRect);
			          deClipToViewArea;
			          SetOthellierEstSale(x,true);
			       end;

			    pionSuggestionDeCassio:
			        begin
			          clipToViewArea(x);
			          if gEcranCouleur then
			            begin
			              ForeColor(gCouleurOthellier.couleurFront);
			              if gCouleurOthellier.estTresClaire
			                then BackColor(BlackColor)
			                else
					              if (gCouleurOthellier.menuCmd = VertSapinCmd)     or
					                 (gCouleurOthellier.menuCmd = VertTurquoiseCmd)
					                  then BackColor(WhiteColor)
					                  else BackColor(gCouleurOthellier.couleurBack);
			            end;
			          unRect := GetRect3DDessous(x);
			          if platDiv10[x] = 1 then OffsetRect(unRect,0,1);
			          {InsetRect(unRect,0,1);}
			          inc(unRect.top);
			          inc(unRect.top);
			          dec(unRect.bottom);
			          longueur := unRect.right-unRect.left;
			          hauteur := unRect.bottom-unRect.top;
			          a := 0;
			          for i := 1 to (longueur-hauteur) div 2 do
			            begin
			             inc(a);
			             InsetRect(unRect,1,0);
			             if odd(a)
			                then PenPat(pionInversePat)
			                else PenPat(InversePionInversePat);
			              FrameOval(unRect);
			            end;
			          for i := 1 to hauteur div 2 do
			            begin
			             inc(a);
			             InsetRect(unRect,1,1);
			             if odd(a)
			                then PenPat(pionInversePat)
			                else PenPat(InversePionInversePat);
			              FrameOval(unRect);
			            end;
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenPat(blackPattern);
			          deClipToViewArea;
			          SetOthellierEstSale(x,true);
			        end;


			    effaceCase:
			        begin
			          i := platMod10[x];
			          j := platDiv10[x];
			          myPoly := OpenPoly;
			          a0 := intersection3D^^[i-1,j-1].h + 1;
			          b0 := intersection3D^^[i-1,j-1].v + 1;
			          Moveto(a0,b0);
			          Lineto(intersection3D^^[i,j-1].h -1,intersection3D^^[i,j-1].v +1);
			          Lineto(intersection3D^^[i,j].h -1,intersection3D^^[i,j].v -1);
			          Lineto(intersection3D^^[i-1,j].h +1,intersection3D^^[i-1,j].v -1);
			          Lineto(a0,b0);
			          ClosePoly;
			          clipToViewArea(x);
			          ForeColor(gCouleurOthellier.couleurFront);
			          BackColor(gCouleurOthellier.couleurBack);
			          RGBForeColor(gCouleurOthellier.RGB);
			          FillPoly(myPoly,gCouleurOthellier.whichPattern);
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenPat(blackPattern);
			          Moveto(intersection3D^^[i-1,j-1].h,intersection3D^^[i-1,j-1].v);
			          Lineto(intersection3D^^[i,j-1].h,intersection3D^^[i,j-1].v);
			          Moveto(intersection3D^^[i,j].h,intersection3D^^[i,j].v);
			          Lineto(intersection3D^^[i-1,j].h,intersection3D^^[i-1,j].v);
			          Moveto(x3Dbas[i-1],y3D[8]);
				        Lineto(X3Dhaut[i-1],Y3D[0]);
			          Moveto(x3Dbas[i],y3D[8]);
				        Lineto(X3Dhaut[i],Y3D[0]);
			          KillPoly(myPoly);
			          deClipToViewArea;
			          SetOthellierEstSale(x,false);
			        end;
			   (*
			     pionEntoureCasePourMontrerCoupEnTete:
				      begin
			          i := platMod10[x];
			          j := platDiv10[x];
			          clipToViewArea(x);
			          PenPat(blackPattern);
			          a0 := intersection3D^^[i-1,j-1].h + 1;
			          b0 := intersection3D^^[i-1,j-1].v + 1;
			          Moveto(a0,b0);
			          Lineto(intersection3D^^[i,j-1].h -1,intersection3D^^[i,j-1].v +1);
			          Lineto(intersection3D^^[i,j].h -1,intersection3D^^[i,j].v -1);
			          Lineto(intersection3D^^[i-1,j].h +1,intersection3D^^[i-1,j].v -1);
			          Lineto(a0,b0);
			          deClipToViewArea;
			          SetOthellierEstSale(x,true);
			        end;
			     pionEntoureCasePourEffacerCoupEnTete:
				      begin
			          i := platMod10[x];
			          j := platDiv10[x];
			          clipToViewArea(x);
			          PenPat(gCouleurOthellier.whichPattern);
			          PenSize(1,1);
			          ForeColor(gCouleurOthellier.couleurFront);
			          BackColor(gCouleurOthellier.couleurBack);
			          RGBForeColor(gCouleurOthellier.RGB);
			          a0 := intersection3D^^[i-1,j-1].h + 1;
			          b0 := intersection3D^^[i-1,j-1].v + 1;
			          Moveto(a0,b0);
			          Lineto(intersection3D^^[i,j-1].h -1,intersection3D^^[i,j-1].v +1);
			          Lineto(intersection3D^^[i,j].h -1,intersection3D^^[i,j].v -1);
			          Lineto(intersection3D^^[i-1,j].h +1,intersection3D^^[i-1,j].v -1);
			          Lineto(a0,b0);
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenNormal;
			          PenPat(blackPattern);
			          Moveto(intersection3D^^[i-1,j-1].h,intersection3D^^[i-1,j-1].v);
			          Lineto(intersection3D^^[i,j-1].h,intersection3D^^[i,j-1].v);
			          Moveto(intersection3D^^[i,j].h,intersection3D^^[i,j].v);
			          Lineto(intersection3D^^[i-1,j].h,intersection3D^^[i-1,j].v);
			          Moveto(x3Dbas[i-1],y3D[8]);
				        Lineto(X3Dhaut[i-1],Y3D[0]);
			          Moveto(x3Dbas[i],y3D[8]);
				        Lineto(X3Dhaut[i],Y3D[0]);
			          deClipToViewArea;
			          SetOthellierEstSale(x,true);
			        end;
            *)
			  end;{case}
			end;

end;


procedure Dessine3D(const position : plateauOthello; avecBruitage : boolean);
var i,j,t : SInt16;
    unRect : rect;
    compteurSons : SInt16;
begin
  {DessinePlateau3D;}
  for j := 1 to 8 do
  for i := 1 to 8 do
    begin
     t := j*10+i;
     if (position[t] = pionVide) and (plat3DEffectif[t] <> pionVide)
       then
         begin
           if t > 20
             then DessinePion3D(t-10,pionVide)
             else
                begin
                  SetRect(unRect,x3Dhaut[i-1],y3D[0]-5,x3Dhaut[i],y3D[0]+2);
                  FillRect(unRect,blackPattern);
                end;
           plat3DEffectif[t-10] := -position[t-10];
         end;
    end;

  compteurSons := 0;
  if avecBruitage and avecSonPourPosePion and not(enTournoi and (phaseDeLaPartie >= phaseFinale))
    then PlayPosePionSound;

  for j := 1 to 8 do
  for i := 1 to 8 do
    begin
     t := j*10+i;
     {if position[t] <> pionVide then }
     if plat3DEffectif[t] <> position[t] then
      begin
        repeat
          inc(compteurSons);
          if avecBruitage and avecSonPourRetournePion and (compteurSons = 1)
            then PlayRetournementDePionSound;
          plat3DEffectif[t] := position[t];
          DessinePion3D(t,position[t]);
          t := t+10;
        until interdit[t] or (plat3DEffectif[t] = position[t]);
        if not(interdit[t]) and (position[t] <> pionVide) then
          DessineDessusPion3D(t,position[t]);
      end;
    end;

  if EnVieille3D then
    InvalidateAllCasesDessinEnTraceDeRayon;
end;

procedure SetPositionDemandeCoup3D;
begin
  if EnVieille3D
    then
      begin
        PosHDemande := 355;
        PosVDemande := y3D[8]+25;
      end
    else
      begin
        PosHDemande := GetPositionDemandeCoupPovRay3D.h;
        PosVDemande := GetPositionDemandeCoupPovRay3D.v;
      end;
end;

procedure SetPositionScore3D;
var myPoint : Point;
begin
  if EnVieille3D
    then
      begin
			  posHNoirs := 152;
			  posHBlancs := posHNoirs+100;
			  posVNoirs := 20;
			  posVBlancs := 20;
			end
	  else
	    begin
	      myPoint := GetPositionScorePovRay3D(pionNoir);
	      posHNoirs := myPoint.h;
	      posVNoirs := myPoint.v;
	      myPoint := GetPositionScorePovRay3D(pionBlanc);
			  posHBlancs := myPoint.h;
			  posVBlancs := myPoint.v;
	    end;
end;

procedure SetPositionMeilleureSuite3D;
begin
  if EnVieille3D
    then
      begin
			  posHMeilleureSuite := 10;
			  posVMeilleureSuite := y3D[8]+25;
			end
	  else
	    begin
	      posHMeilleureSuite := GetPositionMeilleureSuitePovRay3D.h;
			  posVMeilleureSuite := GetPositionMeilleureSuitePovRay3D.v;
	    end;
end;


procedure GetPositionCorrecteNumeroDuCoup3D(square : SInt16; var result : Point);
var myRect : rect;
begin
  myRect := GetRect3DDessus(square);
  with myRect do
    SetPt(result,(left+right) div 2,(top+bottom-2) div 2-1);
end;


function  PtInPlateau3D(loc : Point; var caseCliquee : SInt16) : boolean;
var Y,X,k : SInt32;
    end1,end2 : boolean;
    myRect : rect;
begin
  PtInPlateau3D := false;
  caseCliquee := 0;

  if EnVieille3D
    then
      begin
        end1 := not(ADroite(x3Ddroite[0],y3D[0],x3Ddroite[8],y3D[8],loc.h,loc.v));
			  end2 := ADroite(x3DGauche[0],y3D[0],x3DGauche[8],y3D[8],loc.h,loc.v);
			  if end1 and end2 and (loc.v >= y3D[0]) and (loc.v <= y3D[8]) then
			    begin
			      PtInPlateau3D := true;
			      X := 1;
			      while ADroite(X3DHaut[X],y3D[0],X3Dbas[X],y3D[8],loc.h,loc.v) do
			        inc(X);
			      Y := 1;
			      while (loc.v >= y3D[Y]) do
			        inc(Y);
			      caseCliquee := X+10*Y;
			   end;
		  end
    else
      begin
        { on cherche dans quelle case on peut avoir cliqué }
        { premiere passe  (k = 0) : les bounding rects normaux }
        { deuxieme passe  (k = 1) : en augmentant un tout petit peu la taille des rectangles }
        { troisième passe (k = 2) : en augmentant encore un peu la taille des rectangles }
        for k := 0 to 2 do
          for x := 1 to 64 do
            begin
              myRect := GetBoundingRect3D(othellier[x]);
              InSetRect(myRect, -k , -k);
              if PtInRect(loc, myRect) then
                begin
                  caseCliquee := othellier[x];
                  PtInPlateau3D := true;
                  exit(PtInPlateau3D);
                end;
            end;
      end;
end;



END.
