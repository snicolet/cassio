UNIT UnitPositionEtTrait;



INTERFACE







 USES UnitDefCassio;





{ Fonctions de creation }
function MakePositionEtTrait(var plat : plateauOthello; trait : SInt32) : PositionEtTraitRec;
function MakeEmptyPositionEtTrait : PositionEtTraitRec;
function PositionEtTraitInitiauxStandard : PositionEtTraitRec;
procedure SetTraitOfPosition(var position : PositionEtTraitRec; trait : SInt32);


{ Fonctions d'acces }
function GetTraitOfPosition(var position : PositionEtTraitRec) : SInt32;
function SamePositionEtTrait(var pos1,pos2 : PositionEtTraitRec) : boolean;
function EstLaPositionCourante(var position : PositionEtTraitRec) : boolean;
function EstLaPositionInitialeStandard(var position : PositionEtTraitRec) : boolean;
function EstLaPositionInitialeStandardInversee(var position : PositionEtTraitRec) : boolean;
function NbPionsDeCetteCouleurDansPosition(couleur : SInt32; var position : plateauOthello) : SInt32;
function NbCasesVidesDansPosition(var position : plateauOthello) : SInt32;
function NombresCasesOccupeesDifferentes(p1, p2 : PositionEtTraitRec) : SInt32;
procedure AssertParamsOfPositionEtTrait(var position : PositionEtTraitRec; fonctionAppelante : String255);
function PartieEstFinieApresCeCoupDansPositionEtTrait(const position : PositionEtTraitRec; square : SInt32) : boolean;
function GetListeDesCoupsLegauxDansCettePosition(const whichPos : PositionEtTraitRec; var liste : ListOfMoveRecords) : SInt32;


{ La position courante de Cassio }
procedure SetPositionInitialeStandardDansJeuCourant;
procedure SetJeuCourant(jeu : plateauOthello; trait : SInt32);
function UpdateJeuCourant(whichMove : SInt32) : boolean;
function PositionEtTraitCourant : PositionEtTraitRec;
function GetCouleurOfSquareDansJeuCourant(whichSquare : SInt32) : SInt32;
function JeuCourant : plateauOthello;
function AQuiDeJouer : SInt32;


{ Modifications de PositionEtTraitRec }
function UpdatePositionEtTrait(var positionEtTrait : PositionEtTraitRec; whichMove : SInt32) : boolean;
function RetournePionsPositionEtTrait(var positionEtTrait : PositionEtTraitRec; whichMove : SInt32) : SInt32;
function InverserCouleurPionsDansPositionEtTrait(const position : PositionEtTraitRec) : PositionEtTraitRec;


{ Traductions chaines  < -> PositionEtTraitRec }
function PositionEtTraitEnString(var positionEtTrait : PositionEtTraitRec) : String255;
function PositionEtTraitInitiauxStandardEnString : String255;
function ParsePositionEtTrait(s : String255; var positionEtTrait : PositionEtTraitRec) : boolean;
function ParserFENEnPositionEtTrait(s : String255; var positionEtTrait : PositionEtTraitRec) : boolean;
function PositionRapportEnPositionEtTrait(s : String255; couleur : SInt32) : PositionEtTraitRec;


{ Jouer une partie pour obtenir un PositionEtTraitRec }
function PositionEtTraitAfterMoveNumberAlpha(game : String255; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
function PositionEtTraitAfterMoveNumber(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
function PositionEtTraitAfterMoveEnString(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : String255;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitStrategie, UnitRapport, MyStrings, UnitScannerOthellistique, UnitPackedThorGame ;
{$ELSEC}
    {$I prelink/PositionEtTrait.lk}
{$ENDC}


{END_USE_CLAUSE}











const kTraitNonEncoreCalcule = -1256;

var gJeuCourant : PositionEtTraitRec;


procedure AssertParamsOfPositionEtTrait(var position : PositionEtTraitRec; fonctionAppelante : String255);
begin
  if (position.lazyTrait.traitNaturel <> pionNoir) and
     (position.lazyTrait.traitNaturel <> pionVide) and
     (position.lazyTrait.traitNaturel <> pionBlanc) and
     (position.lazyTrait.traitNaturel <> kTraitNonEncoreCalcule) then
    begin
      WritelnDansRapport('ASSERT ! traitNaturel dans AssertParamsOfPositionEtTrait, fonction appelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(position.position,position.lazyTrait.traitNaturel);
    end;

  if (position.lazyTrait.leTrait <> pionNoir) and
     (position.lazyTrait.leTrait <> pionVide) and
     (position.lazyTrait.leTrait <> pionBlanc) and
     (position.lazyTrait.leTrait <> kTraitNonEncoreCalcule) then
    begin
      WritelnDansRapport('ASSERT! leTrait dans AssertParamsOfPositionEtTrait, fonction appelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(position.position,position.lazyTrait.leTrait);
    end;
end;


function PartieEstFinieApresCeCoupDansPositionEtTrait(const position : PositionEtTraitRec; square : SInt32) : boolean;
var aux : PositionEtTraitRec;
begin
  aux := position;

  PartieEstFinieApresCeCoupDansPositionEtTrait := (GetTraitOfPosition(aux) = pionVide);
  if UpdatePositionEtTrait(aux, square) then
    PartieEstFinieApresCeCoupDansPositionEtTrait := (GetTraitOfPosition(aux) = pionVide);
end;


function GetListeDesCoupsLegauxDansCettePosition(const whichPos : PositionEtTraitRec; var liste : ListOfMoveRecords) : SInt32;
var square, t, nbFilsTrouves : SInt32;
    platAux : PositionEtTraitRec;
begin

  platAux := whichPos;
  nbFilsTrouves := 0;

  for t := 1 to 64 do
    begin
      liste[t].notePourLeTri := -100000;
      liste[t].x             := 0;
      liste[t].theDefense    := 0;
    end;

  for t := 1 to 64 do
    begin
      square := othellier[t];
      if UpdatePositionEtTrait(platAux, square) then
        begin
          inc(nbFilsTrouves);
          liste[nbFilsTrouves].x             := square;

          platAux := whichPos;
        end;
    end;

  GetListeDesCoupsLegauxDansCettePosition := nbFilsTrouves;
end;


procedure ForceLazyCalculationOfTrait(var position : PositionEtTraitRec);
begin

  with position.lazyTrait do
    if (leTrait = kTraitNonEncoreCalcule) then
      begin
        if traitNaturel = pionVide then
          begin
            WritelnDansRapport('WARNING : (traitNaturel = pionVide) dans ForceLazyCalculationOfTrait !');
            traitNaturel := pionNoir;
          end;

        if not(DoitPasserPlatSeulement(traitNaturel,position.position))
          then
            begin
              leTrait := traitNaturel;
            end
          else
            if not(DoitPasserPlatSeulement(-traitNaturel,position.position))
              then leTrait := -traitNaturel
              else
                begin
                  leTrait      := pionVide;  {game over}
                  traitNaturel := pionVide;
                end;
      end;

end;


function MakePositionEtTrait(var plat : plateauOthello; trait : SInt32) : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  aux.position               := plat;
  aux.lazyTrait.leTrait      := kTraitNonEncoreCalcule;
  aux.lazyTrait.traitNaturel := trait;

  if trait = pionVide then WritelnDansRapport('WARNING : (trait = pionVide) dans MakePositionEtTrait !');

  MakePositionEtTrait := aux;
end;


function MakeEmptyPositionEtTrait : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  OthellierDeDepart(aux.position);
  aux.position[44] := pionVide;
  aux.position[45] := pionVide;
  aux.position[54] := pionVide;
  aux.position[55] := pionVide;
  aux.lazyTrait.leTrait      := pionVide;
  aux.lazyTrait.traitNaturel := pionVide;

  MakeEmptyPositionEtTrait := aux;
end;


function PositionEtTraitInitiauxStandard : PositionEtTraitRec;
var aux : PositionEtTraitRec;
begin
  OthellierDeDepart(aux.position);
  aux.lazyTrait.leTrait      := pionNoir;
  aux.lazyTrait.traitNaturel := pionNoir;

  PositionEtTraitInitiauxStandard := aux;
end;



function PositionEtTraitCourant : PositionEtTraitRec;
// var aux : PositionEtTraitRec;
begin
  (*
  if (AQuiDeJouer = pionVide) then
    WritelnDansRapport('WARNING : (AQuiDeJouer = pionVide) dans PositionEtTraitCourant, fonction appelante = '+fonctionAppelante);
  *)
  (*

  if AQuiDeJouer = pionVide
    then
      begin
         aux.position               := JeuCourant;
         aux.lazyTrait.leTrait      := AQuiDeJouer;
         aux.lazyTrait.traitNaturel := AQuiDeJouer;

         PositionEtTraitCourant := aux;
      end
    else
      PositionEtTraitCourant := MakePositionEtTrait(JeuCourant,AQuiDeJouer);
  *)

  PositionEtTraitCourant := gJeuCourant;
end;


function JeuCourant : plateauOthello;
begin
  JeuCourant := gJeuCourant.position;
end;


function AQuiDeJouer : SInt32;
begin
  AQuiDeJouer := GetTraitOfPosition(gJeuCourant);
end;


procedure SetPositionInitialeStandardDansJeuCourant;
begin
  gJeuCourant := PositionEtTraitInitiauxStandard;
end;

procedure SetJeuCourant(jeu : plateauOthello; trait : SInt32);
begin
  gJeuCourant := MakePositionEtTrait(jeu, trait);
end;


function UpdateJeuCourant(whichMove : SInt32) : boolean;
begin
  UpdateJeuCourant := UpdatePositionEtTrait(gJeuCourant, whichMove);
end;


function GetCouleurOfSquareDansJeuCourant(whichSquare : SInt32) : SInt32;
begin
  GetCouleurOfSquareDansJeuCourant := gJeuCourant.position[whichSquare];
end;



function SamePositionEtTrait(var pos1,pos2 : PositionEtTraitRec) : boolean;
var i : SInt32;
begin
  SamePositionEtTrait := false;

  for i := 0 to 99 do
    if (pos1.position[i] <> pos2.position[i]) then exit;

  ForceLazyCalculationOfTrait(pos1);
  ForceLazyCalculationOfTrait(pos2);

  if (pos1.lazyTrait.leTrait <> pos2.lazyTrait.leTrait) then exit;

  SamePositionEtTrait := true;
end;


function EstLaPositionCourante(var position : PositionEtTraitRec) : boolean;
var current : PositionEtTraitRec;
begin
  current := PositionEtTraitCourant;
  EstLaPositionCourante := SamePositionEtTrait(position,current);
end;


function EstLaPositionInitialeStandard(var position : PositionEtTraitRec) : boolean;
var initiale : PositionEtTraitRec;
begin
  initiale := PositionEtTraitInitiauxStandard;
  EstLaPositionInitialeStandard := SamePositionEtTrait(position,initiale);
end;

function EstLaPositionInitialeStandardInversee(var position : PositionEtTraitRec) : boolean;
var initiale : PositionEtTraitRec;
begin
  initiale := PositionEtTraitInitiauxStandard;
  initiale.position[44] := -initiale.position[44];
  initiale.position[45] := -initiale.position[45];
  initiale.position[54] := -initiale.position[54];
  initiale.position[55] := -initiale.position[55];
  EstLaPositionInitialeStandardInversee := SamePositionEtTrait(position,initiale);
end;


function NbPionsDeCetteCouleurDansPosition(couleur : SInt32; var position : plateauOthello) : SInt32;
var aux,i,j : SInt32;
begin
  aux := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      if position[i*10+j] = couleur then inc(aux);
  NbPionsDeCetteCouleurDansPosition := aux;
end;


function NbCasesVidesDansPosition(var position : plateauOthello) : SInt32;
var aux,i,j : SInt32;
begin
  aux := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      if position[i*10+j] = pionVide then inc(aux);
  NbCasesVidesDansPosition := aux;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   NombresCasesOccupeesDifferentes : renvoie le nombre de cases qui sont     *
 *   vides dans l'une des positions et pleines dans l'autre, ou vice-versa.    *
 *                                                                             *
 *******************************************************************************
 *)
function NombresCasesOccupeesDifferentes(p1, p2 : PositionEtTraitRec) : SInt32;
var i,n : SInt32;
begin
  n := 0;
  for i := 1 to 64 do
    if ((p1.position[othellier[i]] = pionVide)  and (p2.position[othellier[i]] <> pionVide)) or
       ((p1.position[othellier[i]] <> pionVide) and (p2.position[othellier[i]]  = pionVide))
      then inc(n);
  NombresCasesOccupeesDifferentes := n;
end;



function GetTraitOfPosition(var position : PositionEtTraitRec) : SInt32;
begin
  if (position.lazyTrait.leTrait = kTraitNonEncoreCalcule) then
    ForceLazyCalculationOfTrait(position);

  GetTraitOfPosition := position.lazyTrait.leTrait;
end;


procedure SetTraitOfPosition(var position : PositionEtTraitRec; trait : SInt32);
begin
  with position.lazyTrait do
    begin
      leTrait      := trait;
      traitNaturel := trait;
    end;
end;


function UpdatePositionEtTrait(var positionEtTrait : PositionEtTraitRec; whichMove : SInt32) : boolean;
var coupLegal : boolean;
begin
  if (whichMove < 11) or (whichMove > 88) or (positionEtTrait.lazyTrait.leTrait = pionVide) then
    begin
      UpdatePositionEtTrait := false;
      exit;
    end;

  with positionEtTrait do
    begin

      if (position[whichMove] <> pionVide) then
        begin
          UpdatePositionEtTrait := false;
          exit;
        end;

      if (lazyTrait.leTrait <> kTraitNonEncoreCalcule)
        then
          coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.leTrait)
        else
          begin
            (* Calcul lazy *)
            coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.traitNaturel);
            if coupLegal
              then
                lazyTrait.leTrait := lazyTrait.traitNaturel  {le trait naturel propose Žtait en fait le bon}
              else
                begin
                  ForceLazyCalculationOfTrait(positionEtTrait);

                  if (lazyTrait.leTrait <> pionVide) then
                    coupLegal := ModifPlatSeulement(whichMove,position,lazyTrait.leTrait);
                end;
          end;

      if not(coupLegal) then
        begin
          UpdatePositionEtTrait := false;
          exit;
        end;

      {on met a jour le trait, en suspendant le glacon de l'evaluation lazy }
      lazyTrait.traitNaturel := -lazyTrait.leTrait;
      lazyTrait.leTrait      := kTraitNonEncoreCalcule;

    end;  {with positionEtTrait}

  UpdatePositionEtTrait := true;
end;


function RetournePionsPositionEtTrait(var positionEtTrait : PositionEtTraitRec; whichMove : SInt32) : SInt32;
var coupLegal : boolean;
    nbPionsRetournes : SInt32;
begin
  RetournePionsPositionEtTrait := 0;

  if (whichMove < 11) or (whichMove > 88) then
    begin
      RetournePionsPositionEtTrait := 0;
      exit;
    end;

  ForceLazyCalculationOfTrait(positionEtTrait);

  if (positionEtTrait.lazyTrait.leTrait <> pionVide) then
    begin

      coupLegal := (positionEtTrait.position[whichMove] = pionVide) and
                  ModifPlatPrise(whichMove,positionEtTrait.position,positionEtTrait.lazyTrait.leTrait,nbPionsRetournes);

      if not(coupLegal) then
        begin
          RetournePionsPositionEtTrait := 0;
          exit;
        end;

      with positionEtTrait do
        begin
          lazyTrait.traitNaturel := -lazyTrait.leTrait;
          lazyTrait.leTrait      := kTraitNonEncoreCalcule;
        end;

    end;

  RetournePionsPositionEtTrait := nbPionsRetournes;
end;


function PositionEtTraitEnString(var positionEtTrait : PositionEtTraitRec) : String255;
var i,j : SInt32;
    s : String255;
begin
  s := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        case positionEtTrait.position[i*10+j] of
          pionNoir : s := s + 'X';
          pionBlanc : s := s + 'O';
          pionVide : s := s + '-';
          otherwise s := s + '-';
        end;
      end;
  s := s + '   ';
  case GetTraitOfPosition(positionEtTrait) of
    pionNoir : s := s + 'X';
    pionBlanc : s := s + 'O';
    pionVide : s := s + '-';
    otherwise s := s + '-';
  end;
  PositionEtTraitEnString := s;
end;


function PositionEtTraitInitiauxStandardEnString : String255;
var thePos : PositionEtTraitRec;
begin
  thePos := PositionEtTraitInitiauxStandard;
  PositionEtTraitInitiauxStandardEnString := PositionEtTraitEnString(thePos);
end;


function ParsePositionEtTrait(s : String255; var positionEtTrait : PositionEtTraitRec) : boolean;
var i,j,aux : SInt32;
    s1,s2,reste : String255;
begin
  ParsePositionEtTrait := false;

  EnleveEspacesDeGaucheSurPlace(s);
  s := StripDiacritics(s);
  Parser2(s,s1,s2,reste);

  if LENGTH_OF_STRING(s1) = 65 then
    begin
      s2 := s1[65];
      s1 := LeftOfString(s1,64);
    end;

  {WritelnDansRapport('s = '+s);
  WritelnDansRapport('s1 = '+s1);
  WritelnDansRapport('s2 = '+s2);}

  if LENGTH_OF_STRING(s1) <> 64 then
    begin
      WritelnDansRapport('parse error 1 in ParsePositionEtTrait !');
      exit;
    end;

  positionEtTrait := PositionEtTraitInitiauxStandard;
  aux := 1;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        case s1[aux] of
          'X','*','x','¥','b','#'       : positionEtTrait.position[i*10+j] := pionNoir;
          'O','0','o','w'               : positionEtTrait.position[i*10+j] := pionBlanc;
          '-','.','_','Ð','Ñ','e','+'   : positionEtTrait.position[i*10+j] := pionVide;
          otherwise
            begin
              WritelnDansRapport('parse error 2 in ParsePositionEtTrait !');
              exit;
            end;
        end;
        inc(aux);
      end;

  if LENGTH_OF_STRING(s2) <= 0 then
    begin
      WritelnDansRapport('parse error 3 in ParsePositionEtTrait !');
      exit;
    end;

  positionEtTrait.lazyTrait.leTrait := kTraitNonEncoreCalcule;
  case s2[1] of
    'X','*','x','¥','b','#'       : positionEtTrait.lazyTrait.traitNaturel := pionNoir;
    'O','0','o','w'               : positionEtTrait.lazyTrait.traitNaturel := pionBlanc;
    '-','.','_','Ð','Ñ','e','+'   : positionEtTrait.lazyTrait.traitNaturel := pionVide;
    otherwise
      begin
        WritelnDansRapport('parse error 4 in ParsePositionEtTrait !');
        exit;
      end;
  end;

  ParsePositionEtTrait := true;
end;




function ParserFENEnPositionEtTrait(s : String255; var positionEtTrait : PositionEtTraitRec) : boolean;
const k_CASE_NON_AFFECTEE = 93;
var i,t, ligne, colonne : SInt32;
    s1,reste,accu, positionString, traitString  : String255;
    c : char;


  { ParseError() : pour indiquer une erreur }
  procedure ParseError(message : String255);
  begin
    WritelnDansRapport(message);
    exit;
  end;


  { Affecter() : pour affecter une valeur dans une case }
  procedure Affecter(x, y, valeurCase : SInt32);
  begin
    if (x >= 1) and (x <= 8) and
       (y >= 1) and (y <= 8)
      then positionEtTrait.position[y * 10 + x] := valeurCase
      else ParseError('parse error 0 in ParserFENEnPositionEtTrait : invalid square in line '+IntToStr(ligne) + ' !');

    accu := '';
  end;

  { AffecterCasesVides() : pour affecter des cases vides consecutives }
  procedure AffecterCasesVides;
  var n,j : SInt32;
  begin

    n := ChaineEnLongint(accu);
    for j := 0 to (n - 1) do
      Affecter(colonne + j , ligne , pionVide);

    colonne := colonne + n;

    accu := '';
  end;




begin {ParserFENEnPositionEtTrait}

  ParserFENEnPositionEtTrait := false;

  // initialisation des tokens

  ReplaceCharByCharInString(s, '"', ' ');
  ReplaceCharByCharInString(s, '[', ' ');
  ReplaceCharByCharInString(s, ']', ' ');

  Parser(s,s1,reste);
  if (s1 = 'FEN')
    then s := reste
    else s := s1 + reste;

  Parser2(s, positionString, traitString, reste);


  // pour le debugage...

  {
  WritelnDansRapport('s = '+s);
  WritelnDansRapport('positionString = '+positionString);
  WritelnDansRapport('traitString = '+traitString);
  WritelnDansRapport('reste = '+reste);
  }


  // on initialise un plateau avec des valeurs "non affectees"

  positionEtTrait := PositionEtTraitInitiauxStandard;

  for t := 1 to 64 do
    positionEtTrait.position[othellier[t]] := k_CASE_NON_AFFECTEE;



  // on essaye de parser la position du plateau

  if (LENGTH_OF_STRING(positionString) <= 15) then
    ParseError('parse error 1 in ParserFENEnPositionEtTrait : description is too short !');

  ligne          := 1;
  colonne        := 1;
  accu           := '';
  i              := 0;
  positionString := positionString + 'Ã';    { sentinelle }

  repeat

    inc(i);
    c := positionString[i];

    case c of
      'Ã' :
        begin
          AffecterCasesVides;
        end;

      '/'  :
        begin
          AffecterCasesVides;
          inc(ligne);
          colonne := 1;
        end;

      'P','O','W' :
        begin
          AffecterCasesVides;
          Affecter(colonne, ligne, pionBlanc);
          inc(colonne);
        end;

      'p','x','*','b','#' :
        begin
          AffecterCasesVides;
          Affecter(colonne, ligne, pionNoir);
          inc(colonne);
        end;

      '0','1','2','3','4','5','6','7','8','9' :
        begin
          accu := accu + c;
        end;

      otherwise
        ParseError('parse error 2 in ParserFENEnPositionEtTrait : invalid character in line ' + IntToStr(ligne) + ' ('+c+') !');
    end; {case}

  until (c = ' ') or (c = 'Ã') or (i >= LENGTH_OF_STRING(positionString)) or (ligne > 8);



  // on verifie que toutes les cases de l'othellier ont ete couvertes

  for t := 1 to 64 do
    begin
      if (positionEtTrait.position[othellier[t]] = k_CASE_NON_AFFECTEE) then
         ParseError('parse error 3 in ParserFENEnPositionEtTrait : not enough squares are filled !');

      { i := othellier[t];
        WriteNumDansRapport('i = ',i);
        WritelnNumDansRapport('   position['+CoupEnStringEnMajuscules(i)+'] = ',positionEtTrait.position[i]);
      }
    end;


  // et maintenant on essaye de trouver le trait

  if LENGTH_OF_STRING(traitString) <= 0 then
    ParseError('parse error 4 in ParserFENEnPositionEtTrait : impossible to find the color of the player to move !');

  positionEtTrait.lazyTrait.leTrait := kTraitNonEncoreCalcule;

  // par defaut on met le trait de la parite

  t := NbCasesVidesDansPosition(positionEtTrait.position);
  if t <= 0
    then positionEtTrait.lazyTrait.traitNaturel := pionVide
    else
      if odd(t)
        then positionEtTrait.lazyTrait.traitNaturel := pionBlanc
        else positionEtTrait.lazyTrait.traitNaturel := pionNoir;

  // et on regarde si il y a une indication de trait valide

  case traitString[1] of
    'B','b','X','*','x','¥','#','p'   : positionEtTrait.lazyTrait.traitNaturel := pionNoir;
    'W','w','O','0','o','P'           : positionEtTrait.lazyTrait.traitNaturel := pionBlanc;
    '-','.','_','Ð','Ñ','e','+'       : positionEtTrait.lazyTrait.traitNaturel := pionVide;
    otherwise
      ParseError('parse error 5 in ParserFENEnPositionEtTrait : invalid color to move !');
  end;



  // tout a l'air bon, hein

  ParserFENEnPositionEtTrait := true;
end;



function InverserCouleurPionsDansPositionEtTrait(const position : PositionEtTraitRec) : PositionEtTraitRec;
var result : PositionEtTraitRec;
    t : SInt32;
begin
  result := position;

  for t := 11 to 88 do
    begin
      if result.position[t] = pionNoir then result.position[t]  := pionBlanc else
      if result.position[t] = pionBlanc then result.position[t] := pionNoir;
    end;

  InverserCouleurPionsDansPositionEtTrait := result;
end;


function PositionRapportEnPositionEtTrait(s : String255; couleur : SInt32) : PositionEtTraitRec;
var c : char;
    result : PositionEtTraitRec;
    k,i,j,longueur,compteur : SInt32;
begin

  result := PositionEtTraitInitiauxStandard;


  longueur := LENGTH_OF_STRING(s);
  i := 1;
  j := 1;
  compteur := 0;
  for k := 1 to longueur do
    begin
      c := s[k];
      if (compteur < 64) then
	      case c of
	        'X','*','x','#','¥' :
	          begin
	            result.position[10*j+i] := pionNoir;
	            inc(i);
	            inc(compteur);
	          end;
	        '0','O','o' :
	          begin
	            result.position[10*j+i] := pionBlanc;
	            inc(i);
	            inc(compteur);
	          end;
	        '-','.','_','Ð','Ñ','+' :
	          begin
	            result.position[10*j+i] := pionVide;
	            inc(i);
	            inc(compteur);
	          end;
	      end; {case}
      if (i > 8) then
        begin
          i := 1;
          inc(j);
        end;
    end;


  if (compteur < 64) or (compteur > 64)
    then
      begin
        result.lazyTrait.leTrait      := pionVide;
        result.lazyTrait.traitNaturel := pionVide;
      end
    else
      begin
        result.lazyTrait.leTrait := kTraitNonEncoreCalcule;
        case couleur of
          pionNoir,pionVide,pionBlanc :
            result.lazyTrait.traitNaturel := couleur;
          otherwise
            result.lazyTrait.traitNaturel := pionVide;
        end; {case}
      end;

  PositionRapportEnPositionEtTrait := result;
end;


function PositionEtTraitAfterMoveNumber(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
var s255 : String255;
    result : PositionEtTraitRec;
    i : SInt32;
begin
  typeErreur := kPartieOK;
  PositionEtTraitAfterMoveNumber := PositionEtTraitInitiauxStandard;

  TraductionThorEnAlphanumerique(game,s255);
  if (LENGTH_OF_STRING(s255) < numeroCoup*2) then
    begin
      typeErreur := kPartieTropCourte;
      exit;
    end;
  if not(EstUnePartieOthello(s255,true)) then
    begin
      typeErreur := kPartieIllegale;
      exit;
    end;
  result := PositionEtTraitInitiauxStandard;
  for i := 1 to numeroCoup do
    if not(UpdatePositionEtTrait(result,GET_NTH_MOVE_OF_PACKED_GAME(game,i,'PositionEtTraitAfterMoveNumber'))) then
      begin
        typeErreur := kPartieIllegale;
        exit;
      end;
  PositionEtTraitAfterMoveNumber := result;
end;


function PositionEtTraitAfterMoveNumberAlpha(game : String255; numeroCoup : SInt32; var typeErreur : SInt32) : PositionEtTraitRec;
var s60 : PackedThorGame;
begin
  if EstUnePartieOthello(game,true)
    then
      begin
        TraductionAlphanumeriqueEnThor(game,s60);
        PositionEtTraitAfterMoveNumberAlpha := PositionEtTraitAfterMoveNumber(s60,numeroCoup,typeErreur);
      end
    else
      begin
        typeErreur := kPartieIllegale;
        PositionEtTraitAfterMoveNumberAlpha := PositionEtTraitInitiauxStandard;
      end;
end;


function PositionEtTraitAfterMoveEnString(var game : PackedThorGame; numeroCoup : SInt32; var typeErreur : SInt32) : String255;
var positionEtTrait : PositionEtTraitRec;
begin
  positionEtTrait := PositionEtTraitAfterMoveNumber(game,numeroCoup,typeErreur);

  if typeErreur = kPasErreur
    then PositionEtTraitAfterMoveEnString := PositionEtTraitEnString(positionEtTrait)
    else PositionEtTraitAfterMoveEnString := '';
end;







END.

































