UNIT UnitABR;



INTERFACE







 USES UnitDefCassio;





{Creation et destruction}
function MakeEmptyABR : ABR;
function MakeOneElementABR(whichKey : ABRKey; whichData : ABRData) : ABR;
procedure DisposeABR(var theABR : ABR);

{Les fonctions du polymorphisme}
function ABRCompareClefs(a,b : ABRKey) : SInt32;
procedure ABRCopierData(var source,dest : ABR);
procedure ABRCopierCle(var source,dest : ABR);

{fonction d'insertion et de suppression dans un ABR}
procedure InsererCleEtDataDansABR(var arbre : ABR; cle : ABRKey; data : ABRData);
procedure SupprimerDansABR(var arbre : ABR; var element : ABR);

{Affichages}
procedure AfficherABRNodeDansRapport(var x : ABR);
procedure ABRAffichageInfixe(nomABR : String255; x : ABR);
procedure ABRAffichagePrefixe(nomABR : String255; x : ABR);
procedure ABRAffichageSuffixe(nomABR : String255; x : ABR);

{Iterateurs}
procedure ABRParcoursInfixe(x : ABR; DoWhat : ABRProc);
procedure ABRParcoursPrefixe(x : ABR; DoWhat : ABRProc);
procedure ABRParcoursSuffixe(x : ABR; DoWhat : ABRProc);


{Acces et tests sur les ABR}
function ABRGetRacine(x : ABR) : ABR;
function ABRSearch(x : ABR; whichKey : ABRKey) : ABR;
function ABRMinimum(x : ABR) : ABR;
function ABRMaximum(x : ABR) : ABR;
function ABRSuccesseur(x : ABR) : ABR;
function ABRPredecesseur(x : ABR) : ABR;
function ABRIsRacine(x : ABR) : boolean;
function ABRIsEmpty(x : ABR) : boolean;
function ABRHauteur(x : ABR) : SInt32;

{fonctions auxiliaires}
procedure ABRInserer(var arbre : ABR; var element : ABR);
function ABRSupprimer(var arbre : ABR; var element : ABR) : ABR;

{Test de l'unite}
procedure TestUnitABR;

IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitServicesMemoire, UnitRapport, MyMathUtils, UnitPagesABR ;
{$ELSEC}
    {$I prelink/ABR.lk}
{$ENDC}


{END_USE_CLAUSE}











{ CompareCles(a,b) = 0 si a = b
                   < 0 si a < b
                   > 0 si a > b }
function ABRCompareClefs(a,b : ABRKey) : SInt32;
begin
  ABRCompareClefs := (a-b);
end;

procedure ABRCopierData(var source,dest : ABR);
begin
  dest^.data := source^.data;
end;

procedure ABRCopierCle(var source,dest : ABR);
begin
  dest^.cle := source^.cle;
end;

function MakeEmptyABR : ABR;
begin
  MakeEmptyABR := NIL;
end;

function MakeOneElementABR(whichKey : ABRKey; whichData : ABRData) : ABR;
var aux : ABR;
begin
  aux := NewABRPaginee;
  if aux <> NIL then
    begin
      aux^.cle  := whichKey;
      aux^.data := whichData;
      aux^.gauche := NIL;
      aux^.droit := NIL;
      aux^.pere := NIL;
    end;
  MakeOneElementABR := aux;
end;


procedure DisposeABR(var theABR : ABR);
begin
  if theABR <> NIL then
    begin
      DisposeABR(theABR^.gauche);
      DisposeABR(theABR^.droit);

     { Dispose(x^.cle);  }
     { Dispose(x^.data); }
      DisposeABRPaginee(theABR);
      theABR := NIL;
    end;
end;


procedure ABRParcoursInfixe(x : ABR ; DoWhat : ABRProc);
begin
  if x <> NIL then
    begin
      ABRParcoursInfixe(x^.gauche,DoWhat);
      DoWhat(x);
      ABRParcoursInfixe(x^.droit,DoWhat);
    end;
end;

procedure ABRParcoursPrefixe(x : ABR ; DoWhat : ABRProc);
begin
  if x <> NIL then
    begin
      DoWhat(x);
      ABRParcoursPrefixe(x^.gauche,DoWhat);
      ABRParcoursPrefixe(x^.droit,DoWhat);
    end;
end;

procedure ABRParcoursSuffixe(x : ABR ; DoWhat : ABRProc);
begin
  if x <> NIL then
    begin
      ABRParcoursSuffixe(x^.gauche,DoWhat);
      ABRParcoursSuffixe(x^.droit,DoWhat);
      DoWhat(x);
    end;
end;

procedure AfficherABRNodeDansRapport(var x : ABR);
begin
  if x = NIL
    then
      WritelnDansRapport('ABR = NIL !')
    else
      begin
        WriteNumDansRapport('cle = ',x^.cle);
        WritelnNumDansRapport('  data = ',x^.data);
      end;
end;


procedure ABRAffichageInfixe(nomABR : String255; x : ABR);
begin
  WritelnDansRapport('ABR : '+nomABR);
  ABRParcoursInfixe(x,AfficherABRNodeDansRapport);
end;

procedure ABRAffichagePrefixe(nomABR : String255; x : ABR);
begin
  WritelnDansRapport('ABR : '+nomABR);
  ABRParcoursPrefixe(x,AfficherABRNodeDansRapport);
end;

procedure ABRAffichageSuffixe(nomABR : String255; x : ABR);
begin
  WritelnDansRapport('ABR : '+nomABR);
  ABRParcoursSuffixe(x,AfficherABRNodeDansRapport);
end;

function ABRGetRacine(x : ABR) : ABR;
begin
  if x = NIL
    then ABRGetRacine := NIL
    else
      begin
        while (x^.pere <> NIL) do
          x := x^.pere;
        ABRGetRacine := x
      end;
end;

function ABRSearch(x : ABR; whichKey : ABRKey) : ABR;
var compar : SInt32;
begin
  while (x <> NIL) do
    begin
      compar := ABRCompareClefs(whichKey,x^.cle);
      if compar = 0
        then
          begin
            ABRSearch := x;
            exit(ABRSearch);
          end
        else
          if compar < 0
            then x := x^.gauche
            else x := x^.droit;
    end;
  ABRSearch := x;
end;

function ABRMinimum(x : ABR) : ABR;
begin
  if x <> NIL then
    while x^.gauche <> NIL do x := x^.gauche;
  ABRMinimum := x;
end;

function ABRMaximum(x : ABR) : ABR;
begin
  if x <> NIL then
    while x^.droit <> NIL do x := x^.droit;
  ABRMaximum := x;
end;

function ABRSuccesseur(x : ABR) : ABR;
var y : ABR;
begin
  if x = NIL then
    begin
      ABRSuccesseur := NIL;
      exit(ABRSuccesseur);
    end;

  if x^.droit <> NIL
    then ABRSuccesseur := ABRMinimum(x^.droit)
    else
      begin
        y := x^.pere;
        while (y <> NIL) and (x = y^.droit) do
          begin
            x := y;
            y := y^.pere;
          end;
        ABRSuccesseur := y;
      end;
end;

function ABRPredecesseur(x : ABR) : ABR;
var y : ABR;
begin
  if x = NIL then
    begin
      ABRPredecesseur := NIL;
      exit(ABRPredecesseur);
    end;

  if x^.gauche <> NIL
    then ABRPredecesseur := ABRMaximum(x^.gauche)
    else
      begin
        y := x^.pere;
        while (y <> NIL) and (x = y^.gauche) do
          begin
            x := y;
            y := y^.pere;
          end;
        ABRPredecesseur := y;
      end;
end;


function ABRIsRacine(x : ABR) : boolean;
begin
  ABRIsRacine := (x <> NIL) and (x^.pere = NIL);
end;

function ABRIsEmpty(x : ABR) : boolean;
begin
  ABRIsEmpty := (x = NIL);
end;

function ABRHauteur(x : ABR) : SInt32;
begin
  if x = NIL
    then ABRHauteur := 0
    else
      begin
        ABRHauteur := 1+Max(ABRHauteur(x^.gauche),ABRHauteur(x^.droit));
      end;
end;


procedure ABRInserer(var arbre : ABR; var element : ABR);
var x,y : ABR;
begin
  y := NIL;
  x := ABRGetRacine(arbre);
  while x <> NIL do
    begin
      y := x;
      if ABRCompareClefs(element^.cle,x^.cle) < 0
        then x := x^.gauche
        else x := x^.droit;
    end;
  element^.pere := y;
  if y = NIL
    then arbre := element
    else
      if ABRCompareClefs(element^.cle,y^.cle) < 0
        then y^.gauche := element
        else y^.droit := element;
end;

procedure InsererCleEtDataDansABR(var arbre : ABR; cle : ABRKey; data : ABRData);
var element : ABR;
begin
  element := MakeOneElementABR(cle,data);
  if element <> NIL then ABRInserer(arbre,element);
end;



function ABRSupprimer(var arbre : ABR; var element : ABR) : ABR;
var x,y,pereDeY : ABR;
begin
  if element = NIL then exit(ABRSupprimer);

  if (element^.gauche = NIL) or (element^.droit = NIL)
    then y := element
    else y := ABRSuccesseur(element);

  if y^.gauche <> NIL
    then x := y^.gauche
    else x := y^.droit;

  if x <> NIL then x^.pere := y^.pere;

  if y^.pere = NIL
    then arbre := x
    else
      begin
        pereDeY := (y^.pere);
        if y = pereDeY^.gauche
          then pereDeY^.gauche := x
          else pereDeY^.droit := x;
      end;

  if y <> element then
    begin
      ABRCopierCle(y,element);
      ABRCopierData(y,element);
    end;

  ABRSupprimer := y;
end;

procedure SupprimerDansABR(var arbre : ABR; var element : ABR);
var aux : ABR;
begin
  aux := ABRSupprimer(arbre,element);
  if aux <> NIL then
    begin
      {detacher aux, puis liberer la memoire qu'il occupe}
      aux^.gauche := NIL;
      aux^.droit := NIL;
      aux^.pere := NIL;
      DisposeABR(aux);
    end;
end;

procedure TestUnitABR;
var S1,S2 : ABR;
begin
  {WritelnSoldesCreationsPropertiesDansRapport('entrée dans TestABR : ');}


  S1 := MakeEmptyABR;
  ABRAffichagePrefixe('ensemble vide S1',S1);
  DisposeABR(S1);

  {WritelnSoldesCreationsPropertiesDansRapport('après ensemble vide : ');}

  S1 := MakeEmptyABR;
  InsererCleEtDataDansABR(S1,31,31);
  InsererCleEtDataDansABR(S1,26,31);
  InsererCleEtDataDansABR(S1,23,31);
  InsererCleEtDataDansABR(S1,41,31);
  InsererCleEtDataDansABR(S1,59,31);
  InsererCleEtDataDansABR(S1,53,31);
  InsererCleEtDataDansABR(S1,44,31);
  InsererCleEtDataDansABR(S1,58,31);
  InsererCleEtDataDansABR(S1,97,31);
  InsererCleEtDataDansABR(S1,93,31);
  ABRAffichagePrefixe('ABR prefixe',S1);
  ABRAffichageInfixe('ABR infixe',S1);
  ABRAffichageSuffixe('ABR suffixe',S1);
  DisposeABR(S1);

  S1 := MakeEmptyABR;
  InsererCleEtDataDansABR(S1,58,31);
  InsererCleEtDataDansABR(S1,41,31);
  InsererCleEtDataDansABR(S1,26,31);
  InsererCleEtDataDansABR(S1,23,31);
  InsererCleEtDataDansABR(S1,31,31);
  InsererCleEtDataDansABR(S1,53,31);
  InsererCleEtDataDansABR(S1,44,31);
  InsererCleEtDataDansABR(S1,93,31);
  InsererCleEtDataDansABR(S1,59,31);
  InsererCleEtDataDansABR(S1,97,31);
  ABRAffichagePrefixe('ABR prefixe S1 = ',S1);
  S2 := ABRSearch(S1,41);
  ABRAffichagePrefixe('ABR prefixe S2 = ',S2);
  SupprimerDansABR(S1,S2);
  ABRAffichagePrefixe('ABR prefixe S1 = ',S1);
  ABRAffichagePrefixe('ABR prefixe S2 = ',S2);
  DisposeABR(S1);
  DisposeABR(S2);

  {WritelnSoldesCreationsPropertiesDansRapport('sortie de TestABR : ');}
end;


END.
