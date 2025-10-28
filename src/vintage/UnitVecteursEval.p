UNIT UnitVecteursEval;

INTERFACE







 USES UnitDefCassio;







procedure InitUnitVecteurEval;
procedure AlloueVecteurEval(var vecteur : VectNewEval);
procedure DisposeVecteurEval(var vecteur : VectNewEval);

function VecteurEvalEstVide(var vecteur : VectNewEval) : boolean;
procedure AnnihileVecteurEval(var vecteur : VectNewEval);
procedure CopierPointeursVecteursEval(var source,dest : VectNewEval);
procedure AnnuleVecteurEval(var vecteur : VectNewEval);


procedure SetValeurDansVecteurEval(var p : VectNewEval; valeur : TypeReel);
procedure IdentiteVecteurEval(var p : VectNewEval);
procedure HomothetieVecteurEval(var p,result : VectNewEval; scale : TypeReel);
procedure NegationVecteurEval(var p,result : VectNewEval);
procedure ValeurAbsolueVecteurEval(var p,result : VectNewEval);
procedure AddVecteurEval(var p1,p2,resultat : VectNewEval);
procedure DiffVecteurEval(var p1,p2,resultat : VectNewEval);
procedure DivisionVecteurEval(var p1,p2,resultat : VectNewEval);
procedure DivisionBorneeVecteurEval(var p1,p2,resultat : VectNewEval; borne : TypeReel);
procedure CopierVecteurEval(var source,dest : VectNewEval);
procedure CopierOpposeVecteurEval(var source,dest : VectNewEval);
procedure CombinaisonLineaireVecteurEval(var p1,p2 : VectNewEval; lambda1,lambda2 : TypeReel; var resultat : VectNewEval);
function ProduitScalaireVecteurEval(var p1,p2 : VectNewEval) : TypeReel;
function CombinaisonScalaireVecteurEval(var p1,p2,p3 : VectNewEval; lambda1,lambda2 : TypeReel) : TypeReel;



procedure MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(var whichEval : VectNewEval);
procedure SmoothThisEvaluation(var whichEval : VectNewEval; var whichOccurences : VectNewEval);
procedure AbaisseEvalPatternsRares(var whichEval : VectNewEval; var whichOccurences : VectNewEval; valeurMaxPattern,RapportMaxValeurSurOccurence : TypeReel);
procedure AbaisseGradientPatternsRares(var whichEval,whichGradient,whichOccurences : VectNewEval; valeurMaxPattern,RapportMaxValeurSurOccurence : TypeReel);
procedure CalculeEvalPatternsInexistantParEchangeCouleur(var whichEval : VectNewEval; var whichOccurences : VectNewEval);




{ ATTENTION : ces fonctions ne sont pas ENDIAN safe, contrairement a celles de UnitBigVectorsInteger.p }

function EcritEvalDansFichierTexte(var fic : FichierTEXT; var v : VectNewEval) : OSErr;
function LitEvalDansFichierTexte(var fic : FichierTEXT; var v : VectNewEval) : OSErr;
function EcritVecteurEvaluationSurLeDisque(nomFichier : String255 ; vRefNum : SInt16; var whichEval : VectNewEval) : OSErr;
function LitVecteurEvaluationSurLeDisque(nomFichier : String255; var whichEval : VectNewEval) : OSErr;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, MacMemory, fp
{$IFC NOT(USE_PRELINK)}
    , UnitNouvelleEval, UnitRapport, MyStrings, MyMathUtils, UnitFichiersTEXT
    , UnitBigVectors, UnitNewGeneral ;
{$ELSEC}
    ;
    {$I prelink/VecteursEval.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure InitUnitVecteurEval;
var stage,k : SInt32;

  procedure AddDescription(whichsorte,whichLongueur,whichNroPattern,whichstage : SInt16);
  begin
    with descriptionVecteurEval do
      begin
        inc(nbTablesDifferentes);
        with table[nbTablesDifferentes] do
          begin
            sorte := whichSorte;
            longueurPattern := whichLongueur;
            numeroPattern := whichNroPattern;
            stage := whichStage;
          end;
      end;
  end;

begin
  with descriptionVecteurEval do
    begin
      nbTablesDifferentes := 0;
      for k := 0 to 100 do
        with table[k] do
          begin
            sorte := 0;
            longueurPattern := 0;
            numeroPattern := 0;
            stage := 0;
          end;
    end;

  AddDescription(kCorner13,13,kAdresseBlocCoinA1,0);
  for stage := 0 to kNbMaxGameStage do
    begin
      AddDescription(kEdge2X,10,0,stage);
      AddDescription(kPatternLigne,8,kAdresseColonne1,stage);
      AddDescription(kPatternLigne,8,kAdresseColonne2,stage);
      AddDescription(kPatternLigne,8,kAdresseColonne3,stage);
      AddDescription(kPatternLigne,8,kAdresseColonne4,stage);
      AddDescription(kPatternLigne,5,kAdresseDiagonaleA4E8,stage);
      AddDescription(kPatternLigne,6,kAdresseDiagonaleA3F8,stage);
      AddDescription(kPatternLigne,7,kAdresseDiagonaleA2G8,stage);
      AddDescription(kPatternLigne,8,kAdresseDiagonaleA1H8,stage);
    end;
end;

procedure AlloueVecteurEval(var vecteur : VectNewEval);
var stage,taille : SInt32;
    whichDiago,otherDiago,longueurDiago : SInt32;
    tailleDisponible,grow : SInt32;
begin

  AnnihileVecteurEval(vecteur);

  grow := 0;
  tailleDisponible := MaxMem(grow)-GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('tailleDisponible = ',tailleDisponible);
  if tailleDisponible > 10000000 then
    begin

		  { la table pour le pattern de 13 cases dans le coin }
		  { est unique pour toute la partie : on le l'alloue qu'une fois}
		  taille := puiss3[14];
		  if AllocatePointMultidimensionnel(taille,vecteur.Pattern[kAdresseBlocCoinA1,0])
		    then AnnulePointMultidimensionnel(vecteur.Pattern[kAdresseBlocCoinA1,0])
		    else WritelnDansRapport('impossible d''allouer la table de 13 de coin');
		  for stage := 0 to kNbMaxGameStage do
		    begin
		      vecteur.Pattern[kAdresseBlocCoinA1,stage] := vecteur.Pattern[kAdresseBlocCoinA1,0];
		      vecteur.Pattern[kAdresseBlocCoinH1,stage] := vecteur.Pattern[kAdresseBlocCoinA1,0];
		      vecteur.Pattern[kAdresseBlocCoinA8,stage] := vecteur.Pattern[kAdresseBlocCoinA1,0];
		      vecteur.Pattern[kAdresseBlocCoinH8,stage] := vecteur.Pattern[kAdresseBlocCoinA1,0];
		    end;

		  {les patterns Edge + 2X changent avec le game stage}
		  taille := puiss3[11];
		  for stage := 0 to kNbMaxGameStage do
		    if AllocatePointMultidimensionnel(taille,vecteur.Edges2X[stage])
		      then AnnulePointMultidimensionnel(vecteur.Edges2X[stage])
		      else WritelnNumDansRapport('impossible d''allouer la table bord + 2X pour stage = ',stage);

		  {les patterns unidimensionnels changent avec le game stage}
		  for stage := 0 to kNbMaxGameStage do
		    begin
		      taille := puiss3[9];

		      {les bords}
		      if AllocatePointMultidimensionnel(taille,vecteur.Pattern[kAdresseColonne1,stage])
		        then AnnulePointMultidimensionnel(vecteur.Pattern[kAdresseColonne1,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de bord pour stage = ',stage);
		      vecteur.Pattern[kAdresseColonne8,stage] := vecteur.Pattern[kAdresseColonne1,stage];
		      vecteur.Pattern[kAdresseLigne1  ,stage] := vecteur.Pattern[kAdresseColonne1,stage];
		      vecteur.Pattern[kAdresseLigne8  ,stage] := vecteur.Pattern[kAdresseColonne1,stage];

		      {les prebords}
		      if AllocatePointMultidimensionnel(taille,vecteur.Pattern[kAdresseColonne2,stage])
		        then AnnulePointMultidimensionnel(vecteur.Pattern[kAdresseColonne2,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de prebord pour stage = ',stage);
		      vecteur.Pattern[kAdresseColonne7,stage] := vecteur.Pattern[kAdresseColonne2,stage];
		      vecteur.Pattern[kAdresseLigne2  ,stage] := vecteur.Pattern[kAdresseColonne2,stage];
		      vecteur.Pattern[kAdresseLigne7  ,stage] := vecteur.Pattern[kAdresseColonne2,stage];

		      {les troisiemes lignes}
		      if AllocatePointMultidimensionnel(taille,vecteur.Pattern[kAdresseColonne3,stage])
		        then AnnulePointMultidimensionnel(vecteur.Pattern[kAdresseColonne3,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de ligne3 pour stage = ',stage);
		      vecteur.Pattern[kAdresseColonne6,stage] := vecteur.Pattern[kAdresseColonne3,stage];
		      vecteur.Pattern[kAdresseLigne3  ,stage] := vecteur.Pattern[kAdresseColonne3,stage];
		      vecteur.Pattern[kAdresseLigne6  ,stage] := vecteur.Pattern[kAdresseColonne3,stage];

		      {les lignes centrales}
		      if AllocatePointMultidimensionnel(taille,vecteur.Pattern[kAdresseColonne4,stage])
		        then AnnulePointMultidimensionnel(vecteur.Pattern[kAdresseColonne4,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de ligne4 pour stage = ',stage);
		      vecteur.Pattern[kAdresseColonne5,stage] := vecteur.Pattern[kAdresseColonne4,stage];
		      vecteur.Pattern[kAdresseLigne4  ,stage] := vecteur.Pattern[kAdresseColonne4,stage];
		      vecteur.Pattern[kAdresseLigne5  ,stage] := vecteur.Pattern[kAdresseColonne4,stage];

		      {les diagonales}
		      for whichDiago := kAdresseDiagonaleA4E8 to kAdresseDiagonaleA1H8 do
		        begin
		          longueurDiago := taillePattern[whichDiago];
		          taille := puiss3[longueurDiago+1];
		          if AllocatePointMultidimensionnel(taille,vecteur.Pattern[whichDiago,stage])
		            then AnnulePointMultidimensionnel(vecteur.Pattern[whichDiago,stage])
		            else WritelnNumDansRapport('impossible d''allouer la table de diago('+IntToStr(longueurDiago)+') pour stage = ',stage);
		          for otherDiago := kAdresseDiagonaleB1H7 to kAdresseDiagonaleD8H4 do
		            if taillePattern[otherDiago] = longueurDiago then
		              vecteur.Pattern[otherDiago,stage] := vecteur.Pattern[whichDiago,stage];
		        end;
		    end;

		  {la Mobilite, coup par coup}
		  if AllocatePointMultidimensionnel(65,vecteur.Mobilite)
		    then AnnulePointMultidimensionnel(vecteur.Mobilite)
		    else WritelnStringDansRapport('impossible d''allouer la table de Mobilite');

		  {les pions en frontiere, coup par coup}
		  if AllocatePointMultidimensionnel(65,vecteur.FrontiereDiscs)
		    then AnnulePointMultidimensionnel(vecteur.FrontiereDiscs)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereDiscs');

		  {les cases en frontiere, coup par coup}
		  if AllocatePointMultidimensionnel(65,vecteur.FrontiereSquares)
		    then AnnulePointMultidimensionnel(vecteur.FrontiereSquares)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereSquares');

		  {la frontiere non lineaire, coup par coup}
		  if AllocatePointMultidimensionnel(65,vecteur.FrontiereNonLineaire)
		    then AnnulePointMultidimensionnel(vecteur.FrontiereNonLineaire)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereNonLineaire');

    end;
end;



procedure DisposeVecteurEval(var vecteur : VectNewEval);
var stage,k : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      DisposePointMultidimensionnel(vecteur.Edges2X[stage]);
      for k := 0 to kNbPatternsDansEvalDeCassio do
        DisposePointMultidimensionnel(vecteur.Pattern[k,stage]);
    end;
  DisposePointMultidimensionnel(vecteur.Mobilite);
  DisposePointMultidimensionnel(vecteur.FrontiereDiscs);
  DisposePointMultidimensionnel(vecteur.FrontiereSquares);
  DisposePointMultidimensionnel(vecteur.FrontiereNonLineaire);
end;

function VecteurEvalEstVide(var vecteur : VectNewEval) : boolean;
var k,stage : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      for k := 0 to kNbPatternsDansEvalDeCassio do
        if vecteur.Pattern[k,stage] <> NIL then
           begin
             VecteurEvalEstVide := false;
             exit;
           end;
      if vecteur.Edges2X[stage] <> NIL then
        begin
          VecteurEvalEstVide := false;
          exit;
        end;
    end;
  if vecteur.Mobilite <> NIL then
    begin
      VecteurEvalEstVide := false;
      exit;
    end;
  if vecteur.FrontiereDiscs <> NIL then
    begin
      VecteurEvalEstVide := false;
      exit;
    end;
  if vecteur.FrontiereSquares <> NIL then
    begin
      VecteurEvalEstVide := false;
      exit;
    end;
  if vecteur.FrontiereNonLineaire <> NIL then
    begin
      VecteurEvalEstVide := false;
      exit;
    end;
  VecteurEvalEstVide := true;
end;


procedure AnnihileVecteurEval(var vecteur : VectNewEval);
var k,stage : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      vecteur.Edges2X[stage] := NIL;
      for k := 0 to kNbPatternsDansEvalDeCassio do
        vecteur.Pattern[k,stage] := NIL;
    end;
  vecteur.Mobilite := NIL;
  vecteur.FrontiereDiscs := NIL;
  vecteur.FrontiereSquares := NIL;
  vecteur.FrontiereNonLineaire := NIL;
end;

procedure CopierPointeursVecteursEval(var source,dest : VectNewEval);
var k,stage : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      dest.Edges2X[stage] := source.Edges2X[stage];
      for k := 0 to kNbPatternsDansEvalDeCassio do
        dest.Pattern[k,stage] := source.Pattern[k,stage];
    end;
  dest.Mobilite := source.Mobilite;
  dest.FrontiereDiscs := source.FrontiereDiscs;
  dest.FrontiereSquares := source.FrontiereSquares;
  dest.FrontiereNonLineaire := source.FrontiereNonLineaire;
end;




procedure AnnuleVecteurEval(var vecteur : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (vecteur.Edges2X[stage] <> NIL) then
             AnnulePointMultidimensionnel(vecteur.Edges2X[stage]);
         end else
         begin
           if (vecteur.Pattern[numeroPattern,stage] <> NIL) then
             AnnulePointMultidimensionnel(vecteur.Pattern[numeroPattern,stage]);
         end;
  AnnulePointMultidimensionnel(vecteur.Mobilite);
  AnnulePointMultidimensionnel(vecteur.FrontiereDiscs);
  AnnulePointMultidimensionnel(vecteur.FrontiereSquares);
  AnnulePointMultidimensionnel(vecteur.FrontiereNonLineaire);
end;

procedure SetValeurDansVecteurEval(var p : VectNewEval; valeur : TypeReel);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p.Edges2X[stage] <> NIL) then
             SetValeurDansPointMultidimensionnel(p.Edges2X[stage],valeur);
         end else
         begin
           if (p.Pattern[numeroPattern,stage] <> NIL) then
             SetValeurDansPointMultidimensionnel(p.Pattern[numeroPattern,stage],valeur);
         end;
  SetValeurDansPointMultidimensionnel(p.Mobilite,valeur);
  SetValeurDansPointMultidimensionnel(p.FrontiereDiscs,valeur);
  SetValeurDansPointMultidimensionnel(p.FrontiereSquares,valeur);
  SetValeurDansPointMultidimensionnel(p.FrontiereNonLineaire,valeur);
end;


procedure IdentiteVecteurEval(var p : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p.Edges2X[stage] <> NIL) then
             IdentitePointMultidimensionnel(p.Edges2X[stage]);
         end else
         begin
           if (p.Pattern[numeroPattern,stage] <> NIL) then
             IdentitePointMultidimensionnel(p.Pattern[numeroPattern,stage]);
         end;
 {IdentitePointMultidimensionnel(p.Mobilite);
  IdentitePointMultidimensionnel(p.FrontiereDiscs);
  IdentitePointMultidimensionnel(p.FrontiereSquares);
  IdentitePointMultidimensionnel(p.FrontiereNonLineaire);}
end;



procedure HomothetieVecteurEval(var p,result : VectNewEval; scale : TypeReel);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p.Edges2X[stage] <> NIL) then
             HomothetiePointMultidimensionnel(p.Edges2X[stage],result.Edges2X[stage],scale);
         end else
         begin
           if (p.Pattern[numeroPattern,stage] <> NIL) then
             HomothetiePointMultidimensionnel(p.Pattern[numeroPattern,stage],result.Pattern[numeroPattern,stage],scale);
         end;
  HomothetiePointMultidimensionnel(p.Mobilite,result.Mobilite,scale);
  HomothetiePointMultidimensionnel(p.FrontiereDiscs,result.FrontiereDiscs,scale);
  HomothetiePointMultidimensionnel(p.FrontiereSquares,result.FrontiereSquares,scale);
  HomothetiePointMultidimensionnel(p.FrontiereNonLineaire,result.FrontiereNonLineaire,scale);
end;

procedure NegationVecteurEval(var p,result : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p.Edges2X[stage] <> NIL) then
             NegationPointMultidimensionnel(p.Edges2X[stage],result.Edges2X[stage]);
         end else
         begin
           if (p.Pattern[numeroPattern,stage] <> NIL) then
             NegationPointMultidimensionnel(p.Pattern[numeroPattern,stage],result.Pattern[numeroPattern,stage]);
         end;
  NegationPointMultidimensionnel(p.Mobilite,result.Mobilite);
  NegationPointMultidimensionnel(p.FrontiereDiscs,result.FrontiereDiscs);
  NegationPointMultidimensionnel(p.FrontiereSquares,result.FrontiereSquares);
  NegationPointMultidimensionnel(p.FrontiereNonLineaire,result.FrontiereNonLineaire);
end;

procedure ValeurAbsolueVecteurEval(var p,result : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p.Edges2X[stage] <> NIL) then
             ValeurAbsoluePointMultidimensionnel(p.Edges2X[stage],result.Edges2X[stage]);
         end else
         begin
           if (p.Pattern[numeroPattern,stage] <> NIL) then
             ValeurAbsoluePointMultidimensionnel(p.Pattern[numeroPattern,stage],result.Pattern[numeroPattern,stage]);
         end;
  ValeurAbsoluePointMultidimensionnel(p.Mobilite,result.Mobilite);
  ValeurAbsoluePointMultidimensionnel(p.FrontiereDiscs,result.FrontiereDiscs);
  ValeurAbsoluePointMultidimensionnel(p.FrontiereSquares,result.FrontiereSquares);
  ValeurAbsoluePointMultidimensionnel(p.FrontiereNonLineaire,result.FrontiereNonLineaire);
end;

procedure AddVecteurEval(var p1,p2,resultat : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             AddPointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],resultat.Edges2X[stage]);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             AddPointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],resultat.Pattern[numeroPattern,stage]);
         end;
  AddPointMultidimensionnel(p1.Mobilite,p2.Mobilite,resultat.Mobilite);
  AddPointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,resultat.FrontiereDiscs);
  AddPointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,resultat.FrontiereSquares);
  AddPointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,resultat.FrontiereNonLineaire);
end;

procedure DiffVecteurEval(var p1,p2,resultat : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             DiffPointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],resultat.Edges2X[stage]);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             DiffPointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],resultat.Pattern[numeroPattern,stage]);
         end;
  DiffPointMultidimensionnel(p1.Mobilite,p2.Mobilite,resultat.Mobilite);
  DiffPointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,resultat.FrontiereDiscs);
  DiffPointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,resultat.FrontiereSquares);
  DiffPointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,resultat.FrontiereNonLineaire);
end;


procedure DivisionVecteurEval(var p1,p2,resultat : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             DivisionPointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],resultat.Edges2X[stage]);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             DivisionPointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],resultat.Pattern[numeroPattern,stage]);
         end;
  DivisionPointMultidimensionnel(p1.Mobilite,p2.Mobilite,resultat.Mobilite);
  DivisionPointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,resultat.FrontiereDiscs);
  DivisionPointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,resultat.FrontiereSquares);
  DivisionPointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,resultat.FrontiereNonLineaire);
end;

procedure DivisionBorneeVecteurEval(var p1,p2,resultat : VectNewEval; borne : TypeReel);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             DivisionBorneePointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],resultat.Edges2X[stage],borne);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             DivisionBorneePointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],resultat.Pattern[numeroPattern,stage],borne);
         end;
  DivisionBorneePointMultidimensionnel(p1.Mobilite,p2.Mobilite,resultat.Mobilite,borne);
  DivisionBorneePointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,resultat.FrontiereDiscs,borne);
  DivisionBorneePointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,resultat.FrontiereSquares,borne);
  DivisionBorneePointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,resultat.FrontiereNonLineaire,borne);
end;



procedure CombinaisonLineaireVecteurEval(var p1,p2 : VectNewEval; lambda1,lambda2 : TypeReel; var resultat : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             CombinaisonLineairePointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],lambda1,lambda2,resultat.Edges2X[stage]);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             CombinaisonLineairePointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],lambda1,lambda2,resultat.Pattern[numeroPattern,stage]);
         end;
  CombinaisonLineairePointMultidimensionnel(p1.Mobilite,p2.Mobilite,lambda1,lambda2,resultat.Mobilite);
  CombinaisonLineairePointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,lambda1,lambda2,resultat.FrontiereDiscs);
  CombinaisonLineairePointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,lambda1,lambda2,resultat.FrontiereSquares);
  CombinaisonLineairePointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,lambda1,lambda2,resultat.FrontiereNonLineaire);
end;



procedure CopierVecteurEval(var source,dest : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (source.Edges2X[stage] <> NIL) then
             CopierPointMultidimensionnel(source.Edges2X[stage],dest.Edges2X[stage]);
         end else
         begin
           if (source.Pattern[numeroPattern,stage] <> NIL) then
             CopierPointMultidimensionnel(source.Pattern[numeroPattern,stage],dest.Pattern[numeroPattern,stage]);
         end;
  CopierPointMultidimensionnel(source.Mobilite,dest.Mobilite);
  CopierPointMultidimensionnel(source.FrontiereDiscs,dest.FrontiereDiscs);
  CopierPointMultidimensionnel(source.FrontiereSquares,dest.FrontiereSquares);
  CopierPointMultidimensionnel(source.FrontiereNonLineaire,dest.FrontiereNonLineaire);
end;


procedure CopierOpposeVecteurEval(var source,dest : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (source.Edges2X[stage] <> NIL) then
             CopierOpposePointMultidimensionnel(source.Edges2X[stage],dest.Edges2X[stage]);
         end else
         begin
           if (source.Pattern[numeroPattern,stage] <> NIL) then
             CopierOpposePointMultidimensionnel(source.Pattern[numeroPattern,stage],dest.Pattern[numeroPattern,stage]);
         end;
  CopierOpposePointMultidimensionnel(source.Mobilite,dest.Mobilite);
  CopierOpposePointMultidimensionnel(source.FrontiereDiscs,dest.FrontiereDiscs);
  CopierOpposePointMultidimensionnel(source.FrontiereSquares,dest.FrontiereSquares);
  CopierOpposePointMultidimensionnel(source.FrontiereNonLineaire,dest.FrontiereNonLineaire);
end;


function ProduitScalaireVecteurEval(var p1,p2 : VectNewEval) : TypeReel;
var i : SInt32;
    somme : TypeReel;
begin
  somme := 0.0;
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             somme := somme+ProduitScalairePointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage]);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             somme := somme+ProduitScalairePointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage]);
         end;
  somme := somme+ProduitScalairePointMultidimensionnel(p1.Mobilite,p2.Mobilite);
  somme := somme+ProduitScalairePointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs);
  somme := somme+ProduitScalairePointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares);
  somme := somme+ProduitScalairePointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire);
  ProduitScalaireVecteurEval := somme;
end;

function CombinaisonScalaireVecteurEval(var p1,p2,p3 : VectNewEval; lambda1,lambda2 : TypeReel) : TypeReel;
var i : SInt32;
    somme : TypeReel;
begin
  somme := 0.0;
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (p1.Edges2X[stage] <> NIL) then
             somme := somme+CombinaisonScalairePointMultidimensionnel(p1.Edges2X[stage],p2.Edges2X[stage],p3.Edges2X[stage],lambda1,lambda2);
         end else
         begin
           if (p1.Pattern[numeroPattern,stage] <> NIL) then
             somme := somme+CombinaisonScalairePointMultidimensionnel(p1.Pattern[numeroPattern,stage],p2.Pattern[numeroPattern,stage],p3.Pattern[numeroPattern,stage],lambda1,lambda2);
         end;
  somme := somme+CombinaisonScalairePointMultidimensionnel(p1.Mobilite,p2.Mobilite,p3.Mobilite,lambda1,lambda2);
  somme := somme+CombinaisonScalairePointMultidimensionnel(p1.FrontiereDiscs,p2.FrontiereDiscs,p3.FrontiereDiscs,lambda1,lambda2);
  somme := somme+CombinaisonScalairePointMultidimensionnel(p1.FrontiereSquares,p2.FrontiereSquares,p3.FrontiereSquares,lambda1,lambda2);
  somme := somme+CombinaisonScalairePointMultidimensionnel(p1.FrontiereNonLineaire,p2.FrontiereNonLineaire,p3.FrontiereNonLineaire,lambda1,lambda2);
  CombinaisonScalaireVecteurEval := somme;
end;


function EcritEvalDansFichierTexte(var fic : FichierTEXT; var v : VectNewEval) : OSErr;
var err : OSErr;
    stage : SInt32;
begin
  err := NoErr;
  with v do
    begin
      {les blocs de 13 de coin}
      if (err = NoErr) and (Pattern[kAdresseBlocCoinA1,0] <> NIL) then
        err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseBlocCoinA1,0]);
      {edge+2X}
      for stage := 0 to kNbMaxGameStage do
        if (err = NoErr) and (Edges2X[stage] <> NIL) then
          err := EcritPointMultidimensionnelDansFichierTexte(fic,Edges2X[stage]);
      for stage := 0 to kNbMaxGameStage do
        begin
          {bords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne1,stage]);
          {prebords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne2,stage]);
          {lignes3}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne3,stage]);
          {lignes4}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne4,stage]);
          {diag. de 5}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA4E8,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA4E8,stage]);
          {diag. de 6}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA3F8,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA3F8,stage]);
          {diag. de 7}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA2G8,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA2G8,stage]);
          {diag. de 8}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA1H8,stage] <> NIL) then
            err := EcritPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA1H8,stage]);
        end;
      if (err = NoErr) and (v.Mobilite <> NIL) then
        err := EcritPointMultidimensionnelDansFichierTexte(fic,v.Mobilite);
      if (err = NoErr) and (v.FrontiereDiscs <> NIL) then
        err := EcritPointMultidimensionnelDansFichierTexte(fic,v.FrontiereDiscs);
      if (err = NoErr) and (v.FrontiereSquares <> NIL) then
        err := EcritPointMultidimensionnelDansFichierTexte(fic,v.FrontiereSquares);
      if (err = NoErr) and (v.FrontiereNonLineaire <> NIL) then
        err := EcritPointMultidimensionnelDansFichierTexte(fic,v.FrontiereNonLineaire);
    end;
  EcritEvalDansFichierTexte := err;
end;




function LitEvalDansFichierTexte(var fic : FichierTEXT; var v : VectNewEval) : OSErr;
var err : OSErr;
    stage : SInt32;
begin
  err := -1;
  with v do
    begin
      {les blocs de 13 de coin}
      if (Pattern[kAdresseBlocCoinA1,0] <> NIL) then
        err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseBlocCoinA1,0]);
      {edge+2X}
      for stage := 0 to kNbMaxGameStage do
        if (err = NoErr) and (Edges2X[stage] <> NIL) then
          err := LitPointMultidimensionnelDansFichierTexte(fic,Edges2X[stage]);
      for stage := 0 to kNbMaxGameStage do
        begin
          {bords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne1,stage]);
          {prebords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne2,stage]);
          {lignes3}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne3,stage]);
          {lignes4}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseColonne4,stage]);
          {diag. de 5}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA4E8,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA4E8,stage]);
          {diag. de 6}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA3F8,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA3F8,stage]);
          {diag. de 7}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA2G8,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA2G8,stage]);
          {diag. de 8}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA1H8,stage] <> NIL) then
            err := LitPointMultidimensionnelDansFichierTexte(fic,Pattern[kAdresseDiagonaleA1H8,stage]);
        end;
      if (err = NoErr) and (v.Mobilite <> NIL) then
        err := LitPointMultidimensionnelDansFichierTexte(fic,v.Mobilite);
      if (err = NoErr) and (v.FrontiereDiscs <> NIL) then
        err := LitPointMultidimensionnelDansFichierTexte(fic,v.FrontiereDiscs);
      if (err = NoErr) and (v.FrontiereSquares <> NIL) then
        err := LitPointMultidimensionnelDansFichierTexte(fic,v.FrontiereSquares);
      if (err = NoErr) and (v.FrontiereNonLineaire <> NIL) then
        err := LitPointMultidimensionnelDansFichierTexte(fic,v.FrontiereNonLineaire);
    end;
  LitEvalDansFichierTexte := err;
end;


function LitVecteurEvaluationSurLeDisque(nomFichier : String255; var whichEval : VectNewEval) : OSErr;
var fichierEval : FichierTEXT;
    err : OSErr;
begin
  if VecteurEvalEstVide(whichEval) then
    begin
      LitVecteurEvaluationSurLeDisque := -1;
      exit;
    end;

  err := FichierTexteDeCassioExiste(nomFichier,fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := OuvreFichierTexte(fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := LitEvalDansFichierTexte(fichierEval,whichEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := FermeFichierTexte(fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  LitVecteurEvaluationSurLeDisque := err;
end;



function EcritVecteurEvaluationSurLeDisque(nomFichier : String255 ; vRefNum : SInt16; var whichEval : VectNewEval) : OSErr;
var fichierEval : FichierTEXT;
    err : OSErr;
begin
  if VecteurEvalEstVide(whichEval) then
    begin
      EcritVecteurEvaluationSurLeDisque := -1;
      exit;
    end;

  err := FichierTexteExiste(nomFichier,vRefNum,fichierEval);
  if err <> NoErr then err := FichierTexteDeCassioExiste(nomFichier,fichierEval);
  if err = fnfErr {-43 => fichier non trouvé, on le crée}
    then err := CreeFichierTexteDeCassio(nomFichier,fichierEval);
  if err <> 0 then
    begin
      EcritVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := OuvreFichierTexte(fichierEval);
  if err <> 0 then
    begin
      EcritVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := VideFichierTexte(fichierEval);
  if err <> 0 then
    begin
      EcritVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := EcritEvalDansFichierTexte(fichierEval,whichEval);
  if err <> 0 then
    begin
      EcritVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  err := FermeFichierTexte(fichierEval);
  if err <> 0 then
    begin
      EcritVecteurEvaluationSurLeDisque := err;
      exit;
    end;

  SetFileCreatorFichierTexte(fichierEval,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(fichierEval,MY_FOUR_CHAR_CODE('EVAL'));

  EcritVecteurEvaluationSurLeDisque := err;
end;



procedure MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(var whichEval : VectNewEval);
begin
  SetValeurDansPointMultidimensionnel(whichEval.Mobilite,0.2);
  SetValeurDansPointMultidimensionnel(whichEval.FrontiereDiscs,0.5);
  SetValeurDansPointMultidimensionnel(whichEval.FrontiereSquares,0.3);
  SetValeurDansPointMultidimensionnel(whichEval.FrontiereNonLineaire,0.02);
end;



procedure SmoothThisEvaluation(var whichEval : VectNewEval; var whichOccurences : VectNewEval);
var i,j,k,stageMin,stageMax : SInt32;
    precedent,current,next : TypeReel;
    debut,fin : TypeReel;
begin

  {
  ValeurAbsoluePointMultidimensionnel(whichEval.Mobilite,whichEval.Mobilite);
  ValeurAbsoluePointMultidimensionnel(whichEval.FrontiereDiscs,whichEval.FrontiereDiscs);
  ValeurAbsoluePointMultidimensionnel(whichEval.FrontiereSquares,whichEval.FrontiereSquares);
  ValeurAbsoluePointMultidimensionnel(whichEval.FrontiereNonLineaire,whichEval.FrontiereNonLineaire);
  }

  MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(whichEval);

  {smooth du coeff de Mobilite par moyenne mobile}
  precedent := 0;
  current := whichEval.Mobilite^[1];
  next := whichEval.Mobilite^[2];
  for k := 2 to 59 do
    begin
      precedent := current;
      current  := next;
      if k+1 = 40
        then next := current
        else next := whichEval.Mobilite^[k+1];
      whichEval.Mobilite^[k] := 0.25*(precedent+2*current+next);
    end;

 {smooth du coeff de FrontiereDiscs par moyenne mobile}
  precedent := 0;
  current := whichEval.FrontiereDiscs^[1];
  next := whichEval.FrontiereDiscs^[2];
  for k := 2 to 59 do
    begin
      precedent := current;
      current  := next;
      if k+1 = 40
        then next := current
        else next := whichEval.FrontiereDiscs^[k+1];
      whichEval.FrontiereDiscs^[k] := 0.25*(precedent+2*current+next);
    end;

  {smooth du coeff de FrontiereSquares par moyenne mobile}
  precedent := 0;
  current := whichEval.FrontiereSquares^[1];
  next := whichEval.FrontiereSquares^[2];
  for k := 2 to 59 do
    begin
      precedent := current;
      current  := next;
      if k+1 = 40
        then next := current
        else next := whichEval.FrontiereSquares^[k+1];
      whichEval.FrontiereSquares^[k] := 0.25*(precedent+2*current+next);
    end;

  {smooth du coeff de FrontiereNonLineaire par moyenne mobile}
  precedent := 0;
  current := whichEval.FrontiereNonLineaire^[1];
  next := whichEval.FrontiereNonLineaire^[2];
  for k := 2 to 59 do
    begin
      precedent := current;
      current  := next;
      if k+1 = 40
        then next := current
        else next := whichEval.FrontiereNonLineaire^[k+1];
      whichEval.FrontiereNonLineaire^[k] := 0.25*(precedent+2*current+next);
    end;

 {smooth des patterns rares par interpolation}
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                {WritelnEdge2XAndStringDansRapport(k,'stage = '+IntToStr(stage)+'  occ = '+ReelEnStringAvecDecimales(whichOccurences.Edges2X[stage]^[k],10));}
                if whichOccurences.Edges2X[stage]^[k] <= 0.05 then
		               begin
		                 stageMin := 0;
		                 debut := 0.0;
		                 for j := 0 to stage-1 do
		                   if whichOccurences.Edges2X[j]^[k] > 0.1 then
		                     begin
		                       stageMin := j;
		                       debut := whichEval.Edges2X[j]^[k];
		                     end;

		                 stageMax := kNbMaxGameStage;
		                 fin := 0.0;
		                 for j := kNbMaxGameStage downto stage+1 do
		                   if whichOccurences.Edges2X[j]^[k] > 0.1 then
		                     begin
		                       stageMax := j;
		                       fin := whichEval.Edges2X[j]^[k];
		                     end;


		                  { begin
		                     WritelnEdge2XAndStringDansRapport(k,'stageMin = '+IntToStr(stageMin)+'  debut = '+ReelEnStringAvecDecimales(debut,5));
		                     WritelnEdge2XAndStringDansRapport(k,'stageMax = '+IntToStr(stageMax)+'  fin = '+ReelEnStringAvecDecimales(fin,5));
		                     WritelnNumDansRapport('stage = ',stage);
		                     WritelnDansRapport('');
		                   end;}

		                 whichEval.Edges2X[stage]^[k] := debut+(fin-debut)*(stage-stageMin)/(stageMax-stageMin);
		               end;
		           end;
           end
         else
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
		             if whichOccurences.Pattern[numeroPattern,stage]^[k] <= 0.05 then
		               begin
		                 stageMin := 0;
		                 debut := 0.0;
		                 for j := 0 to stage-1 do
		                   if whichOccurences.Pattern[numeroPattern,j]^[k] > 0.1 then
		                     begin
		                       stageMin := j;
		                       debut := whichEval.Pattern[numeroPattern,j]^[k];
		                     end;

		                 stageMax := kNbMaxGameStage;
		                 fin := 0.0;
		                 for j := kNbMaxGameStage downto stage+1 do
		                   if whichOccurences.Pattern[numeroPattern,j]^[k] > 0.1 then
		                     begin
		                       stageMax := j;
		                       fin := whichEval.Pattern[numeroPattern,j]^[k];
		                     end;

		                 whichEval.Pattern[numeroPattern,stage]^[k] := debut+(fin-debut)*(stage-stageMin)/(stageMax-stageMin);
		               end;
		           end;
           end;
end;



procedure AbaisseEvalPatternsRares(var whichEval : VectNewEval; var whichOccurences : VectNewEval; valeurMaxPattern,RapportMaxValeurSurOccurence : TypeReel);
var i,occ,k : SInt32;
    valeur : TypeReel;
begin
 {troncature (en valeur absolue) patterns rares}
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Edges2X[stage]^[k]);
                valeur := whichEval.Edges2X[stage]^[k];

                if valeur >=  valeurMaxPattern then valeur := valeurMaxPattern;
                if valeur <= -valeurMaxPattern then valeur := -valeurMaxPattern;
                if occ > 0 then
                  begin
                    if (valeur > 0.0) and ((valeur/occ) >= RapportMaxValeurSurOccurence)
                      then valeur := occ*RapportMaxValeurSurOccurence;
                    if (valeur < 0.0) and ((-valeur/occ) >= RapportMaxValeurSurOccurence)
                      then valeur := -occ*RapportMaxValeurSurOccurence;
                  end;

                whichEval.Edges2X[stage]^[k] := valeur;
		           end;
           end
         else
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Pattern[numeroPattern,stage]^[k]);
                valeur := whichEval.Pattern[numeroPattern,stage]^[k];

                if valeur >=  valeurMaxPattern then valeur := valeurMaxPattern;
                if valeur <= -valeurMaxPattern then valeur := -valeurMaxPattern;
                if occ > 0 then
                  begin
                    if (valeur > 0.0) and ((valeur/occ) >= RapportMaxValeurSurOccurence)
                      then valeur := occ*RapportMaxValeurSurOccurence;
                    if (valeur < 0.0) and ((-valeur/occ) >= RapportMaxValeurSurOccurence)
                      then valeur := -occ*RapportMaxValeurSurOccurence;
                  end;

                whichEval.Pattern[numeroPattern,stage]^[k] := valeur;
		           end;
           end;
end;




procedure AbaisseGradientPatternsRares(var whichEval,whichGradient,whichOccurences : VectNewEval; valeurMaxPattern,RapportMaxValeurSurOccurence : TypeReel);
var i,occ,k : SInt32;
    valeur,valeurGradient : TypeReel;
begin
 {troncature (en valeur absolue) patterns rares}
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Edges2X[stage]^[k]);
                valeur := whichEval.Edges2X[stage]^[k];
                valeurGradient := whichGradient.Edges2X[stage]^[k];

                if (valeur >=  valeurMaxPattern) and (valeurGradient >= 0) then valeurGradient := 0.0;
                if (valeur <= -valeurMaxPattern) and (valeurGradient <= 0) then valeurGradient := 0.0;
                if occ > 0 then
                  begin
                    if (valeur > 0.0) and ((valeur/occ) >= RapportMaxValeurSurOccurence) and (valeurGradient >= 0)
                      then valeurGradient := 0.0;
                    if (valeur < 0.0) and ((-valeur/occ) >= RapportMaxValeurSurOccurence) and (valeurGradient <= 0)
                      then valeurGradient := 0.0;
                  end;

                whichGradient.Edges2X[stage]^[k] := valeurGradient;
		           end;
           end
         else
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Pattern[numeroPattern,stage]^[k]);
                valeur := whichEval.Pattern[numeroPattern,stage]^[k];
                valeurGradient := whichGradient.Pattern[numeroPattern,stage]^[k];

                if (valeur >=  valeurMaxPattern) and (valeurGradient >= 0) then valeurGradient := 0.0;
                if (valeur <= -valeurMaxPattern) and (valeurGradient <= 0) then valeurGradient := 0.0;
                if occ > 0 then
                  begin
                    if (valeur > 0.0) and ((valeur/occ) >= RapportMaxValeurSurOccurence) and (valeurGradient >= 0)
                      then valeurGradient := 0.0;
                    if (valeur < 0.0) and ((-valeur/occ) >= RapportMaxValeurSurOccurence) and (valeurGradient <= 0)
                      then valeurGradient := 0.0;
                  end;

                whichGradient.Pattern[numeroPattern,stage]^[k] := valeurGradient;
		           end;
           end;
end;




procedure CalculeEvalPatternsInexistantParEchangeCouleur(var whichEval : VectNewEval; var whichOccurences : VectNewEval);
var i,occ,k,patternOppose : SInt32;
    valeur,valeurPatternOppose : TypeReel;
begin
 {troncature (en valeur absolue) patterns rares}
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Edges2X[stage]^[k]);
                if (occ = 0) then
                  begin
                    whichOccurences.Edges2X[stage]^[k] := 1.0;
                    patternOppose := InverseNoirBlancDansAddressePattern(k,longueurPattern);

                    valeur := whichEval.Edges2X[stage]^[k];
                    valeurPatternOppose := whichEval.Edges2X[stage]^[patternOppose];

                    if (valeur <> 0.0) and (valeurPatternOppose <> 0.0)
                      then whichEval.Edges2X[stage]^[k] := 0.5*(valeur-valeurPatternOppose);

                    if (valeur = 0) and (valeurPatternOppose <> 0.0)
                      then whichEval.Edges2X[stage]^[k] := -valeurPatternOppose;

                    if (valeur <> 0.0) and (valeurPatternOppose = 0.0)
                      then whichEval.Edges2X[stage]^[k] := valeur;

                    if (valeur = 0.0) and (valeurPatternOppose = 0.0)
                      then whichEval.Edges2X[stage]^[k] := 0.0;
                  end;
		           end;
           end
         else
           begin
            for k := 1 to puiss3[longueurPattern+1] do
              begin
                occ := RoundToL(whichOccurences.Pattern[numeroPattern,stage]^[k]);
                if (occ = 0) then
                  begin
                    whichOccurences.Pattern[numeroPattern,stage]^[k] := 1.0;
                    patternOppose := InverseNoirBlancDansAddressePattern(k,longueurPattern);

                    valeur := whichEval.Pattern[numeroPattern,stage]^[k];
                    valeurPatternOppose := whichEval.Pattern[numeroPattern,stage]^[patternOppose];

                    if (valeur <> 0.0) and (valeurPatternOppose <> 0.0)
                      then whichEval.Pattern[numeroPattern,stage]^[k] := 0.5*(valeur-valeurPatternOppose);

                    if (valeur = 0) and (valeurPatternOppose <> 0.0)
                      then whichEval.Pattern[numeroPattern,stage]^[k] := -valeurPatternOppose;

                    if (valeur <> 0.0) and (valeurPatternOppose = 0.0)
                      then whichEval.Pattern[numeroPattern,stage]^[k] := valeur;

                    if (valeur = 0.0) and (valeurPatternOppose = 0.0)
                      then whichEval.Pattern[numeroPattern,stage]^[k] := 0.0;
                  end;
		           end;
           end;
end;



END.

