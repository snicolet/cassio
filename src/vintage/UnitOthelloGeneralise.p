UNIT UnitOthelloGeneralise;



INTERFACE







 USES UnitDefCassio;





function MakeBigOthelloRec(theSize : Point; var plateau : BigOthellier; trait : SInt16) : BigOthelloRec;
function PositionInitialeBigOthello(sizeH,sizeV : SInt16) : BigOthelloRec;
function PositionVideBigOthello(sizeH,sizeV : SInt16) : BigOthelloRec;
function PositionCouranteEnBigOthello : BigOthelloRec;
function SameBigOthelloRec(const pos1,pos2 : BigOthelloRec) : boolean;
function BigOthelloEstVide(const position : BigOthelloRec) : boolean;

function NbPionsDeCetteCouleurCeBigOthello(couleur : SInt16; var position : BigOthelloRec) : SInt16;
function NbCasesVidesDansCeBigOthello(var position : BigOthelloRec) : SInt16;

function PeutJouerIciBigOthello(var position : BigOthelloRec; squareX,squareY : SInt16) : boolean;
function DoitPasserBigOthello(var position : BigOthelloRec) : boolean;
function UpdateBigOthello(var position : BigOthelloRec; whichMoveX,whichMoveY : SInt16) : boolean;
function RetournePionsBigOthello(var position : BigOthelloRec; whichMoveX,whichMoveY : SInt16) : SInt16;

{conversions}
function BigOthelloEnChaine(var position : BigOthelloRec) : String255;
function BigOthelloEnPositionEtTrait(var position : BigOthelloRec) : PositionEtTraitRec;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, UnitServicesMemoire, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/OthelloGeneralise.lk}
{$ENDC}


{END_USE_CLAUSE}














function NumberOfFlipsThisDirection(couleur : SInt16; var plateau : BigOthellier; squareX,squareY : SInt16; dx,dy : SInt16) : SInt16;
var adversaire,n : SInt32;
begin
  NumberOfFlipsThisDirection := 0;

  if (squareX >= 1) and (squareX <= kSizeOthellierMax) and
     (squareY >= 1) and (squareY <= kSizeOthellierMax) then
    begin
		  adversaire := -couleur;
		  if (plateau[squareX,squareY] = pionVide) then
		    begin
		      n := 0;
		      squareX := squareX + dx;
		      squareY := squareY + dy;
		      if (squareX >= 1) and (squareX <= kSizeOthellierMax) and
		         (squareY >= 1) and (squareY <= kSizeOthellierMax) and
		         (plateau[squareX,squareY] = adversaire) then
		        begin
					    repeat
					      inc(n);
					      squareX := squareX + dx;
					      squareY := squareY + dy;
					    until (plateau[squareX,squareY] <> adversaire);
					    if (plateau[squareX,squareY] = couleur) then
					      NumberOfFlipsThisDirection := n;
					  end;
		    end;
		end;
end;


procedure DoFlipDiscsThisDirection(var plateau : BigOthellier; squareX,squareY : SInt16; dx,dy : SInt16; nbOfDiscs : SInt16);
var n : SInt32;
begin
  for n := 1 to nbOfDiscs do
    begin
      squareX := squareX + dx;
      squareY := squareY + dy;
      if (squareX >= 1) and (squareX <= kSizeOthellierMax) and
         (squareY >= 1) and (squareY <= kSizeOthellierMax) then
         plateau[squareX,squareY] := -plateau[squareX,squareY];
    end;
end;


function DoFlips(var position : BigOthelloRec; squareX,squareY : SInt16) : SInt16;
var total,n : SInt32;

  procedure TryFlippingThisDirection(dx,dy : SInt16);
  begin
    with position do
	    begin
	      n := NumberOfFlipsThisDirection(trait,plateau,squareX,squareY,dx,dy);
	      if n > 0 then
	        begin
	          total := total + n;
	          DoFlipDiscsThisDirection(plateau,squareX,squareY,dx,dy,n);
	        end;
	    end;
  end;

begin
  total := 0;
  if (squareX >= 1) and (squareX <= kSizeOthellierMax) and
     (squareY >= 1) and (squareY <= kSizeOthellierMax) and
     (position.plateau[squareX,squareY] = pionVide) then
    begin
		  TryFlippingThisDirection(-1,0);
		  TryFlippingThisDirection(-1,-1);
		  TryFlippingThisDirection(0,-1);
		  TryFlippingThisDirection(1,-1);
		  TryFlippingThisDirection(1,0);
		  TryFlippingThisDirection(1,1);
		  TryFlippingThisDirection(0,1);
		  TryFlippingThisDirection(-1,1);
		  if (total > 0) then
		    position.plateau[squareX,squareY] := position.trait;
		end;
  DoFlips := total;
end;


function PeutJouerIciBigOthello(var position : BigOthelloRec; squareX,squareY : SInt16) : boolean;

 procedure TryFlippingThisDirection(dx,dy : SInt16);
  var n : SInt16;
  begin
    with position do
	    begin
	      n := NumberOfFlipsThisDirection(trait,plateau,squareX,squareY,dx,dy);
	      if n > 0 then
	        begin
	          PeutJouerIciBigOthello := true;
	          exit(PeutJouerIciBigOthello);
	        end;
	    end;
  end;

begin
  if (squareX >= 1) and (squareX <= kSizeOthellierMax) and
     (squareY >= 1) and (squareY <= kSizeOthellierMax) and
     (position.plateau[squareX,squareY] = pionVide) then
    begin
		  TryFlippingThisDirection(-1,0);
		  TryFlippingThisDirection(-1,-1);
		  TryFlippingThisDirection(0,-1);
		  TryFlippingThisDirection(1,-1);
		  TryFlippingThisDirection(1,0);
		  TryFlippingThisDirection(1,1);
		  TryFlippingThisDirection(0,1);
		  TryFlippingThisDirection(-1,1);
		end;
  PeutJouerIciBigOthello := false;
end;


function DoitPasserBigOthello(var position : BigOthelloRec) : boolean;
var x,y : SInt16;
begin
  for x := 1 to position.size.h do
    for y := 1 to position.size.v do
      if PeutJouerIciBigOthello(position,x,y) then
        begin
          DoitPasserBigOthello := false;
          exit(DoitPasserBigOthello);
        end;
  DoitPasserBigOthello := true;
end;


function MakeBigOthelloRec(theSize : Point; var plateau : BigOthellier; trait : SInt16) : BigOthelloRec;
var aux : BigOthelloRec;
    i,j : SInt16;
begin
  if (theSize.h < 1) or (theSize.v < 1) or (theSize.h > kSizeOthellierMax) or (theSize.v > kSizeOthellierMax)
    then
      begin
        SysBeep(0);
        WritelnDansRapport('ERREUR : taille trop grande ou trop petite dans MakeBigOthelloRec');
      end
    else
      begin
        aux.size := theSize;
			  aux.plateau := plateau;

			  for i := 0 to kSizeOthellierMax+1 do
			    begin
			      aux.plateau[0,i] := PionInterdit;
			      aux.plateau[i,0] := PionInterdit;
			      aux.plateau[kSizeOthellierMax+1,i] := PionInterdit;
			      aux.plateau[i,kSizeOthellierMax+1] := PionInterdit;
			    end;
			  for i := theSize.h + 1 to kSizeOthellierMax + 1 do
			    for j := 0 to kSizeOthellierMax+1 do
			      aux.plateau[i,j] := PionInterdit;
			  for j := theSize.v + 1 to kSizeOthellierMax + 1 do
			    for i := 0 to kSizeOthellierMax+1 do
			      aux.plateau[i,j] := PionInterdit;

			  aux.trait := trait;
			  if DoitPasserBigOthello(aux) then
			    begin
			      aux.trait := -trait;
			      if DoitPasserBigOthello(aux) then
			        aux.trait := pionVide;
			    end;

			  MakeBigOthelloRec := aux;
      end;
end;



function PositionInitialeBigOthello(sizeH,sizeV : SInt16) : BigOthelloRec;
var aux : BigOthellier;
    i,j : SInt16;
    theSize : Point;
begin
  MemoryFillChar(@aux,sizeof(BigOthellier),chr(0));

  theSize.h := sizeH;
  theSize.v := sizeV;

  i := sizeH div 2;
  j := sizeV div 2;
  if (i > 0) and (i <= kSizeOthellierMax) and (j > 0) and (j <= kSizeOthellierMax) then
    begin
		  aux[i,j]     := pionBlanc;
		  aux[i,j+1]   := pionNoir;
		  aux[i+1,j]   := pionNoir;
		  aux[i+1,j+1] := pionBlanc;
		end;

  PositionInitialeBigOthello := MakeBigOthelloRec(theSize,aux,pionNoir);
end;

function PositionVideBigOthello(sizeH,sizeV : SInt16) : BigOthelloRec;
var aux : BigOthellier;
    theSize : Point;
begin
  MemoryFillChar(@aux,sizeof(BigOthellier),chr(0));

  theSize.h := sizeH;
  theSize.v := sizeV;

  PositionVideBigOthello := MakeBigOthelloRec(theSize,aux,pionNoir);
end;


function PositionCouranteEnBigOthello : BigOthelloRec;
var aux : BigOthellier;
    i,j : SInt16;
    theSize : Point;
begin
  theSize.h := 8;
  theSize.v := 8;
  for i := 1 to 8 do
    for j := 1 to 8 do
      aux[i,j] := GetCouleurOfSquareDansJeuCourant(j*10+i);
  PositionCouranteEnBigOthello := MakeBigOthelloRec(theSize,aux,AQuiDeJouer);
end;


function SameBigOthelloRec(const pos1,pos2 : BigOthelloRec) : boolean;
var i,j : SInt16;
begin
  SameBigOthelloRec := false;

  if pos1.size.h <> pos2.size.h then exit(SameBigOthelloRec);
  if pos1.size.v <> pos2.size.v then exit(SameBigOthelloRec);
  if pos1.trait  <> pos2.trait then exit(SameBigOthelloRec);

  for i := 0 to kSizeOthellierMax+1 do
    for j := 0 to kSizeOthellierMax+1 do
      if pos1.plateau[i,j] <> pos2.plateau[i,j] then exit(SameBigOthelloRec);

  SameBigOthelloRec := true;
end;


function BigOthelloEstVide(const position : BigOthelloRec) : boolean;
begin
  BigOthelloEstVide := SameBigOthelloRec(position, PositionVideBigOthello(position.size.h, position.size.v));
end;


function NbPionsDeCetteCouleurCeBigOthello(couleur : SInt16; var position : BigOthelloRec) : SInt16;
var aux,i,j : SInt16;
begin
  aux := 0;
  for i := 1 to kSizeOthellierMax do
    for j := 1 to kSizeOthellierMax do
      if position.plateau[i,j] = couleur then inc(aux);
  NbPionsDeCetteCouleurCeBigOthello := aux;
end;

function NbCasesVidesDansCeBigOthello(var position : BigOthelloRec) : SInt16;
var aux,i,j : SInt16;
begin
  aux := 0;
  for i := 1 to kSizeOthellierMax do
    for j := 1 to kSizeOthellierMax do
      if position.plateau[i,j] = pionVide then inc(aux);
  NbCasesVidesDansCeBigOthello := aux;
end;



function UpdateBigOthello(var position : BigOthelloRec; whichMoveX,whichMoveY : SInt16) : boolean;
var CoupLegal : boolean;
begin
  if (whichMoveX < 1) or (whichMoveX > position.size.h) then
    begin
      UpdateBigOthello := false;
      exit(UpdateBigOthello);
    end;
  if (whichMoveY < 1) or (whichMoveY > position.size.v) then
    begin
      UpdateBigOthello := false;
      exit(UpdateBigOthello);
    end;

  CoupLegal := (position.plateau[whichMoveX,whichMoveY] = pionVide) and
               (DoFlips(position,whichMoveX,whichMoveY) <> 0);
  if not(CoupLegal) then
    begin
      UpdateBigOthello := false;
      exit(UpdateBigOthello);
    end;

  with position do
    begin
      trait := -trait;
      if DoitPasserBigOthello(position) then
        begin
          position.trait := -position.trait;
	        if DoitPasserBigOthello(position)
	          then position.trait := pionVide;  {partie terminee !}
	      end;
    end;

  UpdateBigOthello := true;
end;


function RetournePionsBigOthello(var position : BigOthelloRec; whichMoveX,whichMoveY : SInt16) : SInt16;
var CoupLegal : boolean;
    nbPionsRetournes : SInt16;
begin
  if (whichMoveX < 1) or (whichMoveX > position.size.h) then
    begin
      RetournePionsBigOthello := 0;
      exit(RetournePionsBigOthello);
    end;
  if (whichMoveY < 1) or (whichMoveY > position.size.v) then
    begin
      RetournePionsBigOthello := 0;
      exit(RetournePionsBigOthello);
    end;

  nbPionsRetournes := DoFlips(position,whichMoveX,whichMoveY);
  CoupLegal := (nbPionsRetournes > 0);
  if not(CoupLegal) then
    begin
      RetournePionsBigOthello := 0;
      exit(RetournePionsBigOthello);
    end;

  with position do
    begin
      trait := -trait;
      if DoitPasserBigOthello(position) then
        begin
          position.trait := -position.trait;
	        if DoitPasserBigOthello(position)
	          then position.trait := pionVide;  {partie terminee !}
	      end;
    end;

  RetournePionsBigOthello := nbPionsRetournes;
end;


function BigOthelloEnChaine(var position : BigOthelloRec) : String255;
var i,j,x : SInt16;
    s : String255;
begin
  s := '';
  for j := 1 to position.size.v do
    for i := 1 to position.size.h do
      begin
        x := position.plateau[i,j];
        if x = pionNoir then s := s + 'X' else
	      if x = pionBlanc then s := s + 'O' else
	      if x = pionVide then s := s + '.';
      end;
  BigOthelloEnChaine := s;
end;

function BigOthelloEnPositionEtTrait(var position : BigOthelloRec) : PositionEtTraitRec;
var result : PositionEtTraitRec;
    plateau : plateauOthello;
    i,j,x : SInt16;
begin
  result := MakeEmptyPositionEtTrait;

  if (position.size.v <> 8) or (position.size.h <> 8)
    then
      begin
        WritelnDansRapport('ERREUR : la taile n''est pas 8x8 dans BigOthelloEnPositionEtTrait !!')
      end
    else
      begin
        plateau := result.position;
        for j := 1 to position.size.v do
			    for i := 1 to position.size.h do
			      begin
			        x := position.plateau[i,j];
			        plateau[j*10 + i] := x;
			      end;

			  result := MakePositionEtTrait(plateau,position.trait);
      end;

  BigOthelloEnPositionEtTrait := result;
end;

END.
