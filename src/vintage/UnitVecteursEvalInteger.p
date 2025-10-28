UNIT UnitVecteursEvalInteger;

INTERFACE







 USES UnitDefCassio;




procedure InitUnitVecteurEvalInteger;
procedure AlloueVecteurEvalInteger(var vecteur : VectNewEvalInteger);
procedure DisposeVecteurEvalInteger(var vecteur : VectNewEvalInteger);

function VecteurEvalIntegerEstVide(var vecteur : VectNewEvalInteger) : boolean;
procedure AnnihileVecteurEvalInteger(var vecteur : VectNewEvalInteger);
procedure CopierPointeursVecteursEvalInteger(var source,dest : VectNewEvalInteger);
procedure AnnuleVecteurEvalInteger(var vecteur : VectNewEvalInteger);



function EcritEvalIntegerDansFichierTexte(var fic : FichierTEXT; var v : VectNewEvalInteger) : OSErr;
function LitEvalIntegerDansFichierTexte(var fic : FichierTEXT; var v : VectNewEvalInteger) : OSErr;
function EcritVecteurEvaluationIntegerSurLeDisque(nomFichier : String255 ; vRefNum : SInt16; var whichEval : VectNewEvalInteger) : OSErr;
function LitVecteurEvaluationIntegerSurLeDisque(nomFichier : String255; var whichEval : VectNewEvalInteger) : OSErr;



procedure VecteurEvalToVecteurEvalInteger(var source : VectNewEval; var dest : VectNewEvalInteger);
procedure VecteurEvalIntegerToVecteurEval(var source : VectNewEvalInteger; var dest : VectNewEval);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacMemory, MacErrors
{$IFC NOT(USE_PRELINK)}
    , UnitTraceLog, UnitRapport, UnitNewGeneral, MyStrings, UnitFichiersTEXT, UnitBigVectorsInteger
     ;
{$ELSEC}
    ;
    {$I prelink/VecteursEvalInteger.lk}
{$ENDC}


{END_USE_CLAUSE}













procedure InitUnitVecteurEvalInteger;
begin
  {on ne fait pas grand-chose, mais on est quand meme content d'etre la}
end;


procedure EcritPatternsAlloues(vecteur : VectNewEvalInteger);
var stage,k : SInt32;
    s,s1 : String255;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      s := IntToStr(stage);
      if vecteur.Edges2X[stage].alloue
        then TraceLog('vecteur.Edges2X['+s+'].alloue = true')
        else TraceLog('vecteur.Edges2X['+s+'].alloue = false');

      for k := 0 to kNbPatternsDansEvalDeCassio do
        begin
		      if vecteur.Pattern[k,stage].alloue
		        then s1 := 'vecteur.Pattern['+IntToStr(k)+','+s+'].alloue = true'
		        else s1 := 'vecteur.Pattern['+IntToStr(k)+','+s+'].alloue = false';
		      TraceLog(s1);
		    end;
    end;
end;


procedure AlloueVecteurEvalInteger(var vecteur : VectNewEvalInteger);
var stage,taille : SInt32;
    whichDiago,otherDiago,longueurDiago : SInt32;
    tailleDisponible,grow : SInt32;
begin

  AnnihileVecteurEvalInteger(vecteur);

  (*
  TraceLog('avant EcritPatternsAlloues{1} dans AlloueVecteurEvalInteger : ');
  EcritPatternsAlloues(vecteur);
  *)

  grow := 0;
  tailleDisponible := MaxMem(grow)-GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('tailleDisponible = ',tailleDisponible);
  if tailleDisponible > 5000000 then
    begin

		  { la table pour le pattern de 13 cases dans le coin }
		  { est unique pour toute la partie : on le l'alloue qu'une fois}

		  taille := puiss3[14];
		  if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[kAdresseBlocCoinA1,0])
		    then AnnulePointMultidimensionnelInteger(vecteur.Pattern[kAdresseBlocCoinA1,0])
		    else WritelnDansRapport('impossible d''allouer la table de 13 de coin');


		  {Tous les autres ne sont que des copies}
		  for stage := 0 to kNbMaxGameStage do
		    begin
		      if stage <> 0 then
		        vecteur.Pattern[kAdresseBlocCoinA1,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseBlocCoinA1,0]);

		      vecteur.Pattern[kAdresseBlocCoinH1,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseBlocCoinA1,0]);
		      vecteur.Pattern[kAdresseBlocCoinA8,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseBlocCoinA1,0]);
		      vecteur.Pattern[kAdresseBlocCoinH8,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseBlocCoinA1,0]);
		    end;

		  {les patterns Edge + 2X changent avec le game stage}
		  taille := puiss3[11];
		  for stage := 0 to kNbMaxGameStage do
		    if AllocatePointMultidimensionnelInteger(taille,vecteur.Edges2X[stage])
		      then AnnulePointMultidimensionnelInteger(vecteur.Edges2X[stage])
		      else WritelnNumDansRapport('impossible d''allouer la table bord + 2X pour stage = ',stage);

		  {les patterns unidimensionnels changent avec le game stage}
		  for stage := 0 to kNbMaxGameStage do
		    begin
		      taille := puiss3[9];

		      {les bords}
		      if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[kAdresseColonne1,stage])
		        then AnnulePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne1,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de bord pour stage = ',stage);

		      vecteur.Pattern[kAdresseColonne8,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne1,stage]);
		      vecteur.Pattern[kAdresseLigne1  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne1,stage]);
		      vecteur.Pattern[kAdresseLigne8  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne1,stage]);

		      {les prebords}
		      if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[kAdresseColonne2,stage])
		        then AnnulePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne2,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de prebord pour stage = ',stage);

		      vecteur.Pattern[kAdresseColonne7,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne2,stage]);
		      vecteur.Pattern[kAdresseLigne2  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne2,stage]);
		      vecteur.Pattern[kAdresseLigne7  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne2,stage]);

		      {les troisiemes lignes}
		      if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[kAdresseColonne3,stage])
		        then AnnulePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne3,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de ligne3 pour stage = ',stage);

		      vecteur.Pattern[kAdresseColonne6,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne3,stage]);
		      vecteur.Pattern[kAdresseLigne3  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne3,stage]);
		      vecteur.Pattern[kAdresseLigne6  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne3,stage]);

		      {les lignes centrales}
		      if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[kAdresseColonne4,stage])
		        then AnnulePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne4,stage])
		        else WritelnNumDansRapport('impossible d''allouer la table de ligne4 pour stage = ',stage);

		      vecteur.Pattern[kAdresseColonne5,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne4,stage]);
		      vecteur.Pattern[kAdresseLigne4  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne4,stage]);
		      vecteur.Pattern[kAdresseLigne5  ,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[kAdresseColonne4,stage]);

		      {les diagonales}
		      for whichDiago := kAdresseDiagonaleA4E8 to kAdresseDiagonaleA1H8 do
		        begin
		          longueurDiago := taillePattern[whichDiago];
		          taille := puiss3[longueurDiago+1];
		          if AllocatePointMultidimensionnelInteger(taille,vecteur.Pattern[whichDiago,stage])
		            then AnnulePointMultidimensionnelInteger(vecteur.Pattern[whichDiago,stage])
		            else WritelnNumDansRapport('impossible d''allouer la table de diago('+IntToStr(longueurDiago)+') pour stage = ',stage);

		          for otherDiago := kAdresseDiagonaleB1H7 to kAdresseDiagonaleD8H4 do
		            if taillePattern[otherDiago] = longueurDiago then
		              vecteur.Pattern[otherDiago,stage] := DuplicatePointMultidimensionnelInteger(vecteur.Pattern[whichDiago,stage]);
		        end;
		    end;

		  {la mobilite, coup par coup}
		  if AllocatePointMultidimensionnelInteger(65,vecteur.Mobilite)
		    then AnnulePointMultidimensionnelInteger(vecteur.Mobilite)
		    else WritelnStringDansRapport('impossible d''allouer la table de Mobilite');

		  {les pions en frontiere, coup par coup}
		  if AllocatePointMultidimensionnelInteger(65,vecteur.FrontiereDiscs)
		    then AnnulePointMultidimensionnelInteger(vecteur.FrontiereDiscs)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereDiscs');

		  {les cases en frontiere, coup par coup}
		  if AllocatePointMultidimensionnelInteger(65,vecteur.FrontiereSquares)
		    then AnnulePointMultidimensionnelInteger(vecteur.FrontiereSquares)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereSquares');

		  {la frontiere non lineaire, coup par coup}
		  if AllocatePointMultidimensionnelInteger(65,vecteur.FrontiereNonLineaire)
		    then AnnulePointMultidimensionnelInteger(vecteur.FrontiereNonLineaire)
		    else WritelnStringDansRapport('impossible d''allouer la table de FrontiereNonLineaire');

    end;

  (*
  TraceLog('avant EcritPatternsAlloues{2} dans AlloueVecteurEvalInteger : ');
  EcritPatternsAlloues(vecteur);
  *)
end;


procedure DisposeVecteurEvalInteger(var vecteur : VectNewEvalInteger);
var stage,k : SInt32;
begin

  (*
  TraceLog('avant EcritPatternsAlloues dans DisposeVecteurEvalInteger : ');
  EcritPatternsAlloues(vecteur);
  *)

  for stage := 0 to kNbMaxGameStage do
    begin
      DisposePointMultidimensionnelInteger(vecteur.Edges2X[stage]);
      for k := 0 to kNbPatternsDansEvalDeCassio do
        DisposePointMultidimensionnelInteger(vecteur.Pattern[k,stage]);
    end;
  DisposePointMultidimensionnelInteger(vecteur.Mobilite);
  DisposePointMultidimensionnelInteger(vecteur.FrontiereDiscs);
  DisposePointMultidimensionnelInteger(vecteur.FrontiereSquares);
  DisposePointMultidimensionnelInteger(vecteur.FrontiereNonLineaire);
end;

function VecteurEvalIntegerEstVide(var vecteur : VectNewEvalInteger) : boolean;
var k,stage : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      for k := 0 to kNbPatternsDansEvalDeCassio do
        if vecteur.Pattern[k,stage].data <> NIL then
           begin
             VecteurEvalIntegerEstVide := false;
             exit;
           end;
      if vecteur.Edges2X[stage].data <> NIL then
        begin
          VecteurEvalIntegerEstVide := false;
          exit;
        end;
    end;
  if vecteur.Mobilite.data <> NIL then
    begin
      VecteurEvalIntegerEstVide := false;
      exit;
    end;
  if vecteur.FrontiereDiscs.data <> NIL then
    begin
      VecteurEvalIntegerEstVide := false;
      exit;
    end;
  if vecteur.FrontiereSquares.data <> NIL then
    begin
      VecteurEvalIntegerEstVide := false;
      exit;
    end;
  if vecteur.FrontiereNonLineaire.data <> NIL then
    begin
      VecteurEvalIntegerEstVide := false;
      exit;
    end;
  VecteurEvalIntegerEstVide := true;
end;


procedure AnnihileVecteurEvalInteger(var vecteur : VectNewEvalInteger);
var k,stage : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      vecteur.Edges2X[stage].data := NIL;
      vecteur.Edges2X[stage].taille := 0;
      vecteur.Edges2X[stage].alloue := false;

      for k := 0 to kNbPatternsDansEvalDeCassio do
        begin
          vecteur.Pattern[k,stage].data := NIL;
          vecteur.Pattern[k,stage].taille := 0;
          vecteur.Pattern[k,stage].alloue := false;
        end;
    end;

  vecteur.Mobilite.data := NIL;
  vecteur.Mobilite.taille := 0;
  vecteur.Mobilite.alloue := false;

  vecteur.FrontiereDiscs.data := NIL;
  vecteur.FrontiereDiscs.taille := 0;
  vecteur.FrontiereDiscs.alloue := false;

  vecteur.FrontiereSquares.data := NIL;
  vecteur.FrontiereSquares.taille := 0;
  vecteur.FrontiereSquares.alloue := false;

  vecteur.FrontiereNonLineaire.data := NIL;
  vecteur.FrontiereNonLineaire.taille := 0;
  vecteur.FrontiereNonLineaire.alloue := false;
end;

procedure CopierPointeursVecteursEvalInteger(var source,dest : VectNewEvalInteger);
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

procedure AnnuleVecteurEvalInteger(var vecteur : VectNewEvalInteger);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X then
         begin
           if (vecteur.Edges2X[stage].data <> NIL) then
             AnnulePointMultidimensionnelInteger(vecteur.Edges2X[stage]);
         end else
         begin
           if (vecteur.Pattern[numeroPattern,stage].data <> NIL) then
             AnnulePointMultidimensionnelInteger(vecteur.Pattern[numeroPattern,stage]);
         end;
  AnnulePointMultidimensionnelInteger(vecteur.Mobilite);
  AnnulePointMultidimensionnelInteger(vecteur.FrontiereDiscs);
  AnnulePointMultidimensionnelInteger(vecteur.FrontiereSquares);
  AnnulePointMultidimensionnelInteger(vecteur.FrontiereNonLineaire);
end;




function EcritEvalIntegerDansFichierTexte(var fic : FichierTEXT; var v : VectNewEvalInteger) : OSErr;
var err : OSErr;
    stage : SInt32;
begin
  err := NoErr;
  with v do
    begin
      {les blocs de 13 de coin}
      if (err = NoErr) and (Pattern[kAdresseBlocCoinA1,0].data <> NIL) then
        err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseBlocCoinA1,0]);
      {edge+2X}
      for stage := 0 to kNbMaxGameStage do
        if (err = NoErr) and (Edges2X[stage].data <> NIL) then
          err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Edges2X[stage]);
      for stage := 0 to kNbMaxGameStage do
        begin
          {bords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne1,stage]);
          {prebords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne2,stage]);
          {lignes3}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne3,stage]);
          {lignes4}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne4,stage]);
          {diag. de 5}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA4E8,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA4E8,stage]);
          {diag. de 6}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA3F8,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA3F8,stage]);
          {diag. de 7}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA2G8,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA2G8,stage]);
          {diag. de 8}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA1H8,stage].data <> NIL) then
            err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA1H8,stage]);
        end;
      if (err = NoErr) and (v.Mobilite.data <> NIL) then
        err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,v.Mobilite);
      if (err = NoErr) and (v.FrontiereDiscs.data <> NIL) then
        err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereDiscs);
      if (err = NoErr) and (v.FrontiereSquares.data <> NIL) then
        err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereSquares);
      if (err = NoErr) and (v.FrontiereNonLineaire.data <> NIL) then
        err := EcritPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereNonLineaire);
    end;
  EcritEvalIntegerDansFichierTexte := err;
end;

function LitEvalIntegerDansFichierTexte(var fic : FichierTEXT; var v : VectNewEvalInteger) : OSErr;
var err : OSErr;
    stage : SInt32;
begin
  err := -1;
  with v do
    begin
      {les blocs de 13 de coin}
      if (Pattern[kAdresseBlocCoinA1,0].data <> NIL) then
        err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseBlocCoinA1,0]);
      {edge+2X}
      for stage := 0 to kNbMaxGameStage do
        if (err = NoErr) and (Edges2X[stage].data <> NIL) then
          err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Edges2X[stage]);
      for stage := 0 to kNbMaxGameStage do
        begin
          {bords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne1,stage]);
          {prebords}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne2,stage]);
          {lignes3}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne3,stage]);
          {lignes4}
          if (err = NoErr) and (Pattern[kAdresseColonne1,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseColonne4,stage]);
          {diag. de 5}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA4E8,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA4E8,stage]);
          {diag. de 6}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA3F8,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA3F8,stage]);
          {diag. de 7}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA2G8,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA2G8,stage]);
          {diag. de 8}
          if (err = NoErr) and (Pattern[kAdresseDiagonaleA1H8,stage].data <> NIL) then
            err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,Pattern[kAdresseDiagonaleA1H8,stage]);
        end;
      if (err = NoErr) and (v.Mobilite.data <> NIL) then
        err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,v.Mobilite);
      if (err = NoErr) and (v.FrontiereDiscs.data <> NIL) then
        err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereDiscs);
      if (err = NoErr) and (v.FrontiereSquares.data <> NIL) then
        err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereSquares);
      if (err = NoErr) and (v.FrontiereNonLineaire.data <> NIL) then
        err := LitPointMultidimensionnelIntegerDansFichierTexte(fic,v.FrontiereNonLineaire);
    end;
  LitEvalIntegerDansFichierTexte := err;
end;


function LitVecteurEvaluationIntegerSurLeDisque(nomFichier : String255; var whichEval : VectNewEvalInteger) : OSErr;
var fichierEval : FichierTEXT;
    err : OSErr;
begin
  if VecteurEvalIntegerEstVide(whichEval) then
    begin
      LitVecteurEvaluationIntegerSurLeDisque := -1;
      exit;
    end;

  err := FichierTexteDeCassioExiste(nomFichier,fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := OuvreFichierTexte(fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := LitEvalIntegerDansFichierTexte(fichierEval,whichEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := FermeFichierTexte(fichierEval);
  if err <> 0 then
    begin
      LitVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  LitVecteurEvaluationIntegerSurLeDisque := err;
end;



function EcritVecteurEvaluationIntegerSurLeDisque(nomFichier : String255 ; vRefNum : SInt16; var whichEval : VectNewEvalInteger) : OSErr;
var fichierEval : FichierTEXT;
    err : OSErr;
begin
  if VecteurEvalIntegerEstVide(whichEval) then
    begin
      WritelnDansRapport('VecteurEvalIntegerEstVide(whichEval) dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := -1;
      exit;
    end;

  err := FichierTexteExiste(nomFichier,vRefNum,fichierEval);
  if err <> NoErr then err := FichierTexteDeCassioExiste(nomFichier,fichierEval);
  if err = fnfErr {-43 => fichier non trouvé, on le crée}
    then err := CreeFichierTexte(nomFichier,vRefNum,fichierEval);
  if err <> 0 then
    begin
      WritelnDansRapport('FichierTexteExiste <> 0 dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := OuvreFichierTexte(fichierEval);
  if err <> 0 then
    begin
      WritelnDansRapport('OuvreFichierTexte <> 0 dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := VideFichierTexte(fichierEval);
  if err <> 0 then
    begin
      WritelnDansRapport('VideFichierTexte <> 0 dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := EcritEvalIntegerDansFichierTexte(fichierEval,whichEval);
  if err <> 0 then
    begin
      WritelnDansRapport('EcritEvalIntegerDansFichierTexte <> 0 dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  err := FermeFichierTexte(fichierEval);
  if err <> 0 then
    begin
      WritelnDansRapport('FermeFichierTexte <> 0 dans EcritVecteurEvaluationIntegerSurLeDisque!!');
      EcritVecteurEvaluationIntegerSurLeDisque := err;
      exit;
    end;

  SetFileCreatorFichierTexte(fichierEval,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(fichierEval,MY_FOUR_CHAR_CODE('EVAL'));


  EcritVecteurEvaluationIntegerSurLeDisque := err;
end;



procedure VecteurEvalToVecteurEvalInteger(var source : VectNewEval; var dest : VectNewEvalInteger);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then HomothetieEtTruncaturePointMultidimensionnel(source.Edges2X[stage],100.0,dest.Edges2X[stage])
         else HomothetieEtTruncaturePointMultidimensionnel(source.Pattern[numeroPattern,stage],100.0,dest.Pattern[numeroPattern,stage]);
  HomothetieEtTruncaturePointMultidimensionnel(source.Mobilite,100.0,dest.Mobilite);
  HomothetieEtTruncaturePointMultidimensionnel(source.FrontiereDiscs,100.0,dest.FrontiereDiscs);
  HomothetieEtTruncaturePointMultidimensionnel(source.FrontiereSquares,100.0,dest.FrontiereSquares);
  HomothetieEtTruncaturePointMultidimensionnel(source.FrontiereNonLineaire,100.0,dest.FrontiereNonLineaire);
end;

procedure VecteurEvalIntegerToVecteurEval(var source : VectNewEvalInteger; var dest : VectNewEval);
var i : SInt32;
begin
  with descriptionVecteurEval do
   for i := 1 to nbTablesDifferentes do
     with table[i] do
       if sorte = kEdge2X
         then HomothetieEtPassageEnFloatPointMultidimensionnel(source.Edges2X[stage],0.01,dest.Edges2X[stage])
         else HomothetieEtPassageEnFloatPointMultidimensionnel(source.Pattern[numeroPattern,stage],0.01,dest.Pattern[numeroPattern,stage]);
  HomothetieEtPassageEnFloatPointMultidimensionnel(source.Mobilite,0.01,dest.Mobilite);
  HomothetieEtPassageEnFloatPointMultidimensionnel(source.FrontiereDiscs,0.01,dest.FrontiereDiscs);
  HomothetieEtPassageEnFloatPointMultidimensionnel(source.FrontiereSquares,0.01,dest.FrontiereSquares);
  HomothetieEtPassageEnFloatPointMultidimensionnel(source.FrontiereNonLineaire,0.01,dest.FrontiereNonLineaire);
end;









END.
