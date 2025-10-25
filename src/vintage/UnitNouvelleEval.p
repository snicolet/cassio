UNIT UnitNouvelleEval;


INTERFACE



 USES UnitDefCassio;







procedure InitUnitNouvelleEval;
procedure AlloueMemoireNouvelleEvaluation(allouerOccurences,allouerEvaluation,allouerEvaluationInteger,allouerConjugate,allouerLigne,allouerTriEval : boolean);
procedure LibereMemoireNouvelleEvaluation;
procedure SetPenalitesPourLeTrait(valeurAuCoup0,valeurAuCoup40,valeurEnFinale : SInt32);
procedure SetPenalitesPourLeTraitStandards;


procedure PrepareCoefficientsEvaluation;


function FichierEvaluationDeCassioTrouvable(nom : String255) : boolean;
procedure EssayerLireFichiersEvaluationDeCassio;


procedure SetUtilisationNouvelleEval(doitUtiliserNouvelleEval : boolean);
procedure SetNouvelleEvalDejaChargee(dejaChargee : boolean);
function GetUtilisationNouvelleEval : boolean;
function GetNouvelleEvalDejaChargee : boolean;


function NewEval(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; minimisation : boolean) : TypeReel;
function DeltaPourCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var nroRefPartie : SInt32; var ScoreCiblePourNoir,EvalPourNoir : TypeReel; var whichEval : VectNewEval) : TypeReel;
function NewEvalEnInteger(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval; var tranquillesNoirs,tranquillesBlancs : ListeDeCases) : SInt32;
function NewEvalDeCassio(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEvalInteger; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; alpha,beta : SInt32) : SInt32;
procedure EcritNewEvalDansRapport(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval);
procedure EcritNewEvalIntegerDansRapport(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEvalInteger);


procedure IncrementeDeriveesPartiellesCettePosition(deltaEval : TypeReel; var jouable : plBool; var position : plateauOthello; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval);

function InverseNoirBlancDansAddressePattern(pattern,longueur : SInt32) : SInt32;
procedure CalculeIndexesEdges2X(var plat : plateauOthello; var frontiere : InfoFront; var edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32);
procedure IncrementeEdge2X(var v : VectNewEval; whichIndex,whichGameStage : SInt32; incr : TypeReel);
procedure IncrementePattern(var v : VectNewEval; whichNroPattern,whichIndex,whichGameStage : SInt32; incr : TypeReel);

procedure WritelnLinePatternAndStringDansRapport(pattern,length : SInt32; s : String255);
procedure Writeln13SquareCornerAndStringDansRapport(pattern : SInt32; s : String255);
procedure WritelnEdge2XAndStringDansRapport(pattern : SInt32; s : String255);

function ParticipeAuChi2(numeroDansLaListe,numeroRefPartie : SInt32; var tickGroupe : SInt32) : boolean;
procedure CollecteOccurenceCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var bidon : SInt32);
procedure CollecteOccurencesPatternDApresListe;

procedure EcritDeltaEvalCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nroRefPartie : SInt32);
procedure EcritsQuelquesPositionsDeCettePartie(nroRefPartie : SInt32);
procedure EcritQuelsquesPositionsPartieAleatoireDansListe;
procedure EcritVecteurMobiliteDansRapport(var whichEval : VectNewEval);
procedure TrieEvalEtEcritDansRapport(var whichVecteur : VectNewEval);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils, fp
{$IFC NOT(USE_PRELINK)}
    , EdmondEvaluation, UnitListe, UnitAccesNouveauFormat, UnitStrategie, UnitNewGeneral
    , UnitEvaluation, UnitPositionEtTrait, UnitRapport, MyStrings, UnitSymmetricalMapping, MyMathUtils, UnitFichiersTEXT, UnitBigVectors
    , UnitVecteursEval, UnitVecteursEvalInteger ;
{$ELSEC}
    ;
    {$I prelink/NouvelleEval.lk}
{$ENDC}


{END_USE_CLAUSE}











var tablePenalitePourLeTraitEnInteger : array[0..64] of SInt32;
    tablePenalitePourLeTraitEnFlottant : array[0..64] of TypeReel;

    statistiques_mobilite : record
                              total : SInt32;
                              nb_mobility_cut : SInt32;
                              echec_mobility_cut : SInt32;
                              occ_par_stage : array[0..6] of SInt32;
                              stat  : array[0..6,-64..64] of record
                                                              occ : SInt32;
                                                              val_sans_mob : SInt32;
                                                              echec_cut : SInt32;
                                                            end;
                            end;
     gNouvelleEvalDejaChargee : boolean;

procedure InitUnitNouvelleEval;
var k,n : SInt32;
begin
  SetUtilisationNouvelleEval(false);
  SetNouvelleEvalDejaChargee(false);

  AnnihileVecteurEval(occurences);
  AnnihileVecteurEval(vecteurEvaluation);
  AnnihileVecteurEvalInteger(vecteurEvaluationInteger);

  memoireAlloueeConjugateGradientChi2 := false;
  with vecteursConjugateGradientChi2 do
    begin
      AnnihileVecteurEval(g);
      AnnihileVecteurEval(h);
      AnnihileVecteurEval(xi);
    end;

  memoireAlloueeFonctionLigneChi2 := false;
  with vecteursFonctionLigneChi2 do
    begin
      AnnihileVecteurEval(p);
      AnnihileVecteurEval(dir);
    end;

  memoireAlloueeTriEvaluation := false;
  with vecteurTriEval do
    begin
      AnnihileVecteurEval(rapportOccurence);
      AnnihileVecteurEval(rank);
    end;

  nbPartiesDansOccurences := 0;
  SetUtilisationNouvelleEval(false);

  versionEvaluationDeCassio := 1;  {attention : augmenter cela quand on recalcule
                                                une nouvelle evaluation ! }



  SetPenalitesPourLeTraitStandards;

  with statistiques_mobilite do
    begin
      total := 0;
      nb_mobility_cut := 0;
      echec_mobility_cut := 0;
      for k := 0 to 6 do
        begin
          occ_par_stage[k] := 0;
		        for n := -64 to 64 do
		          begin
		            stat[k,n].occ := 0;
		            stat[k,n].val_sans_mob := 0;
		          end;
		    end;
    end;
end;


procedure SetPenalitesPourLeTrait(valeurAuCoup0,valeurAuCoup40,valeurEnFinale : SInt32);
var n : SInt32;
begin
   {les pénalités pour le trait sont exprimées en 1/100 de pions, et valent :
      valeurAuCoup0   au coup 0
      interpolation   pour les coups entre 0 et 40
      valeurAuCoup40  au coup 40
      valeurEnFinale  pour les coups >= 41
   }

  for n := 0 to 40 do
    tablePenalitePourLeTraitEnInteger[n] := InterpolationLineaire(n, 0, valeurAuCoup0, 40, valeurAuCoup40);
  for n := 41 to 64 do
    tablePenalitePourLeTraitEnInteger[n] := valeurEnFinale;
  for n := 0 to 64 do
    tablePenalitePourLeTraitEnFlottant[n] := 0.01*tablePenalitePourLeTraitEnInteger[n];

end;


procedure SetPenalitesPourLeTraitStandards;
begin
  {SetPenalitesPourLeTrait(-200,-200,-300);}
  SetPenalitesPourLeTrait(-300,-300,-300);
end;



procedure AlloueMemoireNouvelleEvaluation(allouerOccurences,allouerEvaluation,allouerEvaluationInteger,allouerConjugate,allouerLigne,allouerTriEval : boolean);
begin

  if allouerOccurences then
    begin
      AlloueVecteurEval(occurences);
      if occurences.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
    end;

  if allouerEvaluation then
    begin
      AlloueVecteurEval(vecteurEvaluation);
      if vecteurEvaluation.Pattern[kAdresseBlocCoinA1,0] = NIL
        then SysBeep(0);
    end;

  if allouerEvaluationInteger then
    begin
      AlloueVecteurEvalInteger(vecteurEvaluationInteger);
      if vecteurEvaluationInteger.Pattern[kAdresseBlocCoinA1,0].data = NIL
        then SysBeep(0);
    end;

  if allouerConjugate then
    with vecteursConjugateGradientChi2 do
	  begin
	    AlloueVecteurEval(g);
	    AlloueVecteurEval(h);
	    AlloueVecteurEval(xi);
	    if g.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
      if h.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
      if xi.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
	    memoireAlloueeConjugateGradientChi2 := (g.Pattern[kAdresseBlocCoinA1,0] <> NIL) and
	                                         (h.Pattern[kAdresseBlocCoinA1,0] <> NIL) and
	                                         (xi.Pattern[kAdresseBlocCoinA1,0] <> NIL);
	  end;

  if allouerLigne then
	with vecteursFonctionLigneChi2 do
	  begin
	   {AlloueVecteurEval(p);}    {on fera plutot des copies de pointeurs}
	   {AlloueVecteurEval(dir);}  {on fera plutot des copies de pointeurs}
	   {if p.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
      if dir.Pattern[kAdresseBlocCoinA1,0] = NIL then SysBeep(0);
        then SysBeep(0)
	      else} memoireAlloueeFonctionLigneChi2 := true;
	  end;

  if allouerTriEval then
    with vecteurTriEval do
      begin
        AlloueVecteurEval(rapportOccurence);
        AlloueVecteurEval(rank);
        if (rapportOccurence.Pattern[kAdresseBlocCoinA1,0] = NIL) or
           (rank.Pattern[kAdresseBlocCoinA1,0] = NIL)
          then SysBeep(0)
          else memoireAlloueeTriEvaluation := true;
      end;
end;

procedure LibereMemoireNouvelleEvaluation;
begin
  DisposeVecteurEval(occurences);
  DisposeVecteurEval(vecteurEvaluation);
  DisposeVecteurEvalInteger(vecteurEvaluationInteger);

  with vecteursConjugateGradientChi2 do
    begin
      DisposeVecteurEval(g);
      DisposeVecteurEval(h);
      DisposeVecteurEval(xi);
      memoireAlloueeConjugateGradientChi2 := false;
    end;

  with vecteursFonctionLigneChi2 do
    begin
      DisposeVecteurEval(p);
      DisposeVecteurEval(dir);
      memoireAlloueeFonctionLigneChi2 := false;
    end;

  with vecteurTriEval do
    begin
      DisposeVecteurEval(rapportOccurence);
      DisposeVecteurEval(rank);
      memoireAlloueeTriEvaluation := false;
    end;
end;


procedure PrepareCoefficientsEvaluation;
begin
  // Lecture des fichiers d'evaluation

  if not(GetNouvelleEvalDejaChargee) then
     EssayerLireFichiersEvaluationDeCassio;


  if not(EvaluationEdmondEstDisponible) then
    begin
      WriteDansRapport('Reading Edmond evaluation...');
      if (LireFichierEvalEdmondSurLeDisque = NoErr)
        then
          begin
            WritelnDansRapport('  OK');
            SetEvaluationEdmondEstDisponible(true);
          end
        else
          begin
            WritelnDansRapport('  FAILURE');
          end;
    end;
end;


function FichierEvaluationDeCassioTrouvable(nom : String255) : boolean;
var fic : FichierTEXT;
    err : OSErr;
begin
  err := FichierTexteDeCassioExiste(nom,fic);
  if err <> NoErr then err := FichierTexteDeCassioExiste('Evaluation de Cassio',fic);
  if err <> NoErr then err := FichierTexteDeCassioExiste('Evaluation Cassio',fic);
  if err <> NoErr then err := FichierTexteDeCassioExiste('Evaluation of Cassio',fic);
  if err <> NoErr then err := FichierTexteDeCassioExiste('Cassio Evaluation',fic);
  FichierEvaluationDeCassioTrouvable := (err = NoErr);
end;

procedure EssayerLireFichiersEvaluationDeCassio;
var erreurES : OSErr;
begin
  erreurES := LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger);
  if erreurES <> 0 then erreurES := LitVecteurEvaluationIntegerSurLeDisque('Evaluation of Cassio',vecteurEvaluationInteger);
  if erreurES <> 0 then erreurES := LitVecteurEvaluationIntegerSurLeDisque('Cassio evaluation',vecteurEvaluationInteger);
  if erreurES = NoErr
    then
      begin
        SetUtilisationNouvelleEval(true);
        SetNouvelleEvalDejaChargee(true);
      end
    else
      WritelnDansRapport('WARNING : impossible de lire le fichier d''evaluation de Cassio');
end;


procedure SetUtilisationNouvelleEval(doitUtiliserNouvelleEval : boolean);
begin
  utilisationNouvelleEval := doitUtiliserNouvelleEval;
end;


procedure SetNouvelleEvalDejaChargee(dejaChargee : boolean);
begin
  gNouvelleEvalDejaChargee := dejaChargee;
end;


function GetNouvelleEvalDejaChargee : boolean;
begin
  GetNouvelleEvalDejaChargee := gNouvelleEvalDejaChargee;
end;


function GetUtilisationNouvelleEval : boolean;
begin
  GetUtilisationNouvelleEval := utilisationNouvelleEval;
end;


procedure WritelnLinePatternAndStringDansRapport(pattern,length : SInt32; s : String255);
var aux : array[1..kTailleMaximumPattern] of SInt32;
    i : SInt32;
begin
  {si on s'est trompe de procedure...}
  if length = 10 then
    begin
      WritelnEdge2XAndStringDansRapport(pattern,s);
      exit(WritelnLinePatternAndStringDansRapport);
    end;
  if length = 13 then
    begin
      Writeln13SquareCornerAndStringDansRapport(pattern,s);
      exit(WritelnLinePatternAndStringDansRapport);
    end;

  {on ne s'est pas trompe…}
  pattern := pattern+(puiss3[length+1] div 2);
  for i := length downto 1 do
    begin
      aux[i] := (pattern div puiss3[i]);
      pattern := pattern-aux[i]*puiss3[i];
      dec(aux[i]);
    end;
  for i := 1 to length do
    case aux[i] of
      pionNoir  : WriteDansRapport('X');
      pionBlanc : WriteDansRapport('0');
      pionVide  : WriteDansRapport('_');
      otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux[i])+ ' ');
    end;
  WritelnDansRapport('  '+s);
end;

procedure Writeln13SquareCornerAndStringDansRapport(pattern : SInt32; s : String255);
var aux : array[1..13] of SInt32;
    i : SInt32;
begin
  pattern := pattern+(puiss3[14] div 2);
  for i := 13 downto 1 do
    begin
      aux[i] := (pattern div puiss3[i]);
      pattern := pattern-aux[i]*puiss3[i];
      aux[i] := aux[i]-1;
    end;
  for i := 1 to 4 do
    case aux[i] of
      pionNoir  : WriteDansRapport('X');
      pionBlanc : WriteDansRapport('0');
      pionVide  : WriteDansRapport('_');
      otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux[i])+ ' ');
    end;
  WritelnDansRapport('  '+s);
  for i := 5 to 8 do
    case aux[i] of
      pionNoir  : WriteDansRapport('X');
      pionBlanc : WriteDansRapport('0');
      pionVide  : WriteDansRapport('_');
      otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux[i])+ ' ');
    end;
  WritelnDansRapport('');
  for i := 9 to 11 do
    case aux[i] of
      pionNoir  : WriteDansRapport('X');
      pionBlanc : WriteDansRapport('0');
      pionVide  : WriteDansRapport('_');
      otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux[i])+ ' ');
    end;
  WritelnDansRapport('');
  for i := 12 to 13 do
    case aux[i] of
      pionNoir  : WriteDansRapport('X');
      pionBlanc : WriteDansRapport('0');
      pionVide  : WriteDansRapport('_');
      otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux[i])+ ' ');
    end;
  WritelnDansRapport('');
end;

procedure WritelnEdge2XAndStringDansRapport(pattern : SInt32; s : String255);
var aux1,aux2 : SInt32;
begin
  pattern := pattern+(puiss3[11] div 2);
  aux2 := pattern div puiss3[10];
  pattern := pattern-aux2*puiss3[10];
  aux1 := pattern div puiss3[9];
  pattern := pattern-aux1*puiss3[9];
  dec(aux1);
  dec(aux2);
  pattern := pattern-(puiss3[9] div 2);
  WritelnLinePatternAndStringDansRapport(pattern,8,s);
  WriteDansRapport('  ');
  case aux1 of
    pionNoir  : WriteDansRapport('X');
    pionBlanc : WriteDansRapport('0');
    pionVide  : WriteDansRapport('_');
    otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux1)+ ' ');
  end;
  WriteDansRapport('        ');
  case aux2 of
    pionNoir  : WriteDansRapport('X');
    pionBlanc : WriteDansRapport('0');
    pionVide  : WriteDansRapport('_');
    otherwise   WriteDansRapport('qu''est-ce à dire ? ' +NumEnString(aux2)+ ' ');
  end;
  WritelnDansRapport('');
end;


procedure CalculeIndexesEdges2X(var plat : plateauOthello; var frontiere : InfoFront; var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32);
begin
  with frontiere do
    begin
      Edge2XNord := AdressePattern[kAdresseBordNord ] + 6561*(plat[22] + 3*plat[27]);
      Edge2XSud  := AdressePattern[kAdresseBordSud  ] + 6561*(plat[72] + 3*plat[77]);
      Edge2XOuest := AdressePattern[kAdresseBordOuest] + 6561*(plat[22] + 3*plat[72]);
      Edge2XEst  := AdressePattern[kAdresseBordEst  ] + 6561*(plat[27] + 3*plat[77]);
    end;
end;


function InverseNoirBlancDansAddressePattern(pattern,longueur : SInt32) : SInt32;
var aux : SInt32;
begin
  aux := (puiss3[longueur+1] div 2) + 1;
  InverseNoirBlancDansAddressePattern := aux+aux-pattern;
end;



procedure IncrementeEdge2X(var v : VectNewEval; whichIndex,whichGameStage : SInt32; incr : TypeReel);
begin
  whichIndex := whichIndex+kDecalagePourEdge2X;
  v.Edges2X[whichGameStage]^[whichIndex] := v.Edges2X[whichGameStage]^[whichIndex]+incr;
end;

procedure IncrementePattern(var v : VectNewEval; whichNroPattern,whichIndex,whichGameStage : SInt32; incr : TypeReel);
begin
  whichIndex := whichIndex+decalagePourPattern[whichNroPattern];
  v.Pattern[whichNroPattern,whichGameStage]^[whichIndex] := v.Pattern[whichNroPattern,whichGameStage]^[whichIndex]+incr;
end;


function NewEval(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; minimisation : boolean) : TypeReel;
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage : SInt32;
    evalPartielle : TypeReel;
    mobiliteNoire,mobiliteBlanche : SInt32;
    evalFrontiereNonLineaire : SInt32;
    evalFrontiereSquares,evalFrontiereDiscs : SInt32;
    diffNbreDiscs : SInt32;
begin
  evalPartielle := 0.0;


  numeroDuCoup := nbNoir+nbBlanc-3;
  theStage := gameStage[numeroDuCoup];

  {CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);}
  {la meme fonction, inline}
  with frontiere do
    begin
      Edge2XNord := AdressePattern[kAdresseBordNord ] + 6561*(position[22] + 3*position[27]);
      Edge2XSud  := AdressePattern[kAdresseBordSud  ] + 6561*(position[72] + 3*position[77]);
      Edge2XOuest := AdressePattern[kAdresseBordOuest] + 6561*(position[22] + 3*position[72]);
      Edge2XEst  := AdressePattern[kAdresseBordEst  ] + 6561*(position[27] + 3*position[77]);
    end;

  evalPartielle := evalPartielle+
                   whichEval.Edges2X[theStage]^[Edge2XNord  + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage]^[Edge2XSud   + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage]^[Edge2XOuest + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage]^[Edge2XEst   + kDecalagePourEdge2X];

  with frontiere,whichEval do
    begin
      evalPartielle := evalPartielle + Pattern[kAdresseColonne2,theStage]^[AdressePattern[kAdresseColonne2]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne3,theStage]^[AdressePattern[kAdresseColonne3]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne4,theStage]^[AdressePattern[kAdresseColonne4]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne5,theStage]^[AdressePattern[kAdresseColonne5]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne6,theStage]^[AdressePattern[kAdresseColonne6]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne7,theStage]^[AdressePattern[kAdresseColonne7]+3281];

      evalPartielle := evalPartielle + Pattern[kAdresseLigne2,theStage]^[AdressePattern[kAdresseLigne2]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne3,theStage]^[AdressePattern[kAdresseLigne3]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne4,theStage]^[AdressePattern[kAdresseLigne4]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne5,theStage]^[AdressePattern[kAdresseLigne5]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne6,theStage]^[AdressePattern[kAdresseLigne6]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne7,theStage]^[AdressePattern[kAdresseLigne7]+3281];

      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinA1,theStage]^[AdressePattern[kAdresseBlocCoinA1]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinH1,theStage]^[AdressePattern[kAdresseBlocCoinH1]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinA8,theStage]^[AdressePattern[kAdresseBlocCoinA8]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinH8,theStage]^[AdressePattern[kAdresseBlocCoinH8]+797162];

      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA4E8,theStage]^[AdressePattern[kAdresseDiagonaleA4E8]+122];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA3F8,theStage]^[AdressePattern[kAdresseDiagonaleA3F8]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA2G8,theStage]^[AdressePattern[kAdresseDiagonaleA2G8]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA1H8,theStage]^[AdressePattern[kAdresseDiagonaleA1H8]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleB1H7,theStage]^[AdressePattern[kAdresseDiagonaleB1H7]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleC1H6,theStage]^[AdressePattern[kAdresseDiagonaleC1H6]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleD1H5,theStage]^[AdressePattern[kAdresseDiagonaleD1H5]+122];

      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA5E1,theStage]^[AdressePattern[kAdresseDiagonaleA5E1]+122];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA6F1,theStage]^[AdressePattern[kAdresseDiagonaleA6F1]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA7G1,theStage]^[AdressePattern[kAdresseDiagonaleA7G1]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA8H1,theStage]^[AdressePattern[kAdresseDiagonaleA8H1]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleB8H2,theStage]^[AdressePattern[kAdresseDiagonaleB8H2]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleC8H3,theStage]^[AdressePattern[kAdresseDiagonaleC8H3]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleD8H4,theStage]^[AdressePattern[kAdresseDiagonaleD8H4]+122];
    end;


  if numeroDuCoup < 40 then
    with frontiere do
    begin
      mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
			mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);
			evalPartielle   := evalPartielle+whichEval.Mobilite^[numeroDuCoup]*(mobiliteNoire-mobiliteBlanche);

      evalFrontiereNonLineaire := nbadjacent[pionBlanc]*nbfront[pionBlanc] - nbadjacent[pionNoir]*nbfront[pionNoir];
			if evalFrontiereNonLineaire >  250 then evalFrontiereNonLineaire := 250 else
			if evalFrontiereNonLineaire < -250 then evalFrontiereNonLineaire := -250;
			evalPartielle := evalPartielle + whichEval.FrontiereNonLineaire^[numeroDuCoup]*evalFrontiereNonLineaire;

      evalFrontiereSquares := nbadjacent[pionBlanc]-nbadjacent[pionNoir];
      evalPartielle := evalPartielle + whichEval.FrontiereSquares^[numeroDuCoup]*evalFrontiereSquares;

			evalFrontiereDiscs := nbfront[pionBlanc]-nbfront[pionNoir];
			evalPartielle := evalPartielle + whichEval.FrontiereDiscs^[numeroDuCoup]*evalFrontiereDiscs;

      if minimisation and (position[11] = pionVide) and (position[18] = pionVide) and (position[81] = pionVide) and (position[88] = pionVide) then
			  begin
			    diffNbreDiscs := nbBlanc-nbNoir;
			    evalPartielle := evalPartielle+0.25*diffNbreDiscs;
			  end;
    end;


  if trait = pionNoir
    then NewEval := tablePenalitePourLeTraitEnFlottant[numeroDuCoup] + evalPartielle
    else NewEval := tablePenalitePourLeTraitEnFlottant[numeroDuCoup] - evalPartielle;

end;



procedure EcritNewEvalDansRapport(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval);
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage : SInt32;
    aux,evalPartielle : TypeReel;
    mobiliteNoire,mobiliteBlanche : SInt32;
    evalFrontiereNonLineaire : SInt32;
    evalFrontiereSquares,evalFrontiereDiscs : SInt32;
    diffNbreDiscs : SInt32;
    tranquillesNoirs,tranquillesBlancs : ListeDeCases;
begin
  trait := pionNoir;

  evalPartielle := 0.0;


  numeroDuCoup := nbNoir+nbBlanc-3;
  theStage := gameStage[numeroDuCoup];

  WritelnPositionEtTraitDansRapport(position,trait);

  {CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);}
  {la meme fonction, inline}
  with frontiere do
    begin
      Edge2XNord := AdressePattern[kAdresseBordNord ] + 6561*(position[22] + 3*position[27]);
      Edge2XSud  := AdressePattern[kAdresseBordSud  ] + 6561*(position[72] + 3*position[77]);
      Edge2XOuest := AdressePattern[kAdresseBordOuest] + 6561*(position[22] + 3*position[72]);
      Edge2XEst  := AdressePattern[kAdresseBordEst  ] + 6561*(position[27] + 3*position[77]);
    end;

  aux := whichEval.Edges2X[theStage]^[Edge2XNord  + kDecalagePourEdge2X];
  WritelnStringAndReelDansRapport('bordNord = ',aux,5);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage]^[Edge2XSud   + kDecalagePourEdge2X];
  WritelnStringAndReelDansRapport('bordSud = ',aux,5);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage]^[Edge2XOuest + kDecalagePourEdge2X];
  WritelnStringAndReelDansRapport('bordOuest = ',aux,5);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage]^[Edge2XEst   + kDecalagePourEdge2X];
  WritelnStringAndReelDansRapport('bordEst = ',aux,5);
  evalPartielle := evalPartielle+aux;

  with frontiere,whichEval do
    begin
      aux := Pattern[kAdresseColonne2,theStage]^[AdressePattern[kAdresseColonne2]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne2 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne3,theStage]^[AdressePattern[kAdresseColonne3]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne3 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne4,theStage]^[AdressePattern[kAdresseColonne4]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne4 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne5,theStage]^[AdressePattern[kAdresseColonne5]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne5 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne6,theStage]^[AdressePattern[kAdresseColonne6]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne6 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne7,theStage]^[AdressePattern[kAdresseColonne7]+3281];
      WritelnStringAndReelDansRapport('kAdresseColonne7 = ',aux,5);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseLigne2,theStage]^[AdressePattern[kAdresseLigne2]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne2 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne3,theStage]^[AdressePattern[kAdresseLigne3]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne3 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne4,theStage]^[AdressePattern[kAdresseLigne4]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne4 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne5,theStage]^[AdressePattern[kAdresseLigne5]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne5 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne6,theStage]^[AdressePattern[kAdresseLigne6]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne6 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne7,theStage]^[AdressePattern[kAdresseLigne7]+3281];
      WritelnStringAndReelDansRapport('kAdresseLigne7 = ',aux,5);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseBlocCoinA1,theStage]^[AdressePattern[kAdresseBlocCoinA1]+797162];
      WritelnStringAndReelDansRapport('kAdresseBlocCoinA1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinH1,theStage]^[AdressePattern[kAdresseBlocCoinH1]+797162];
      WritelnStringAndReelDansRapport('kAdresseBlocCoinH1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinA8,theStage]^[AdressePattern[kAdresseBlocCoinA8]+797162];
      WritelnStringAndReelDansRapport('kAdresseBlocCoinA8 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinH8,theStage]^[AdressePattern[kAdresseBlocCoinH8]+797162];
      WritelnStringAndReelDansRapport('kAdresseBlocCoinH8 = ',aux,5);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseDiagonaleA4E8,theStage]^[AdressePattern[kAdresseDiagonaleA4E8]+122];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA4E8 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA3F8,theStage]^[AdressePattern[kAdresseDiagonaleA3F8]+365];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA3F8 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA2G8,theStage]^[AdressePattern[kAdresseDiagonaleA2G8]+1094];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA2G8 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA1H8,theStage]^[AdressePattern[kAdresseDiagonaleA1H8]+3281];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA1H8 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleB1H7,theStage]^[AdressePattern[kAdresseDiagonaleB1H7]+1094];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleB1H7 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleC1H6,theStage]^[AdressePattern[kAdresseDiagonaleC1H6]+365];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleC1H6 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleD1H5,theStage]^[AdressePattern[kAdresseDiagonaleD1H5]+122];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleD1H5 = ',aux,5);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseDiagonaleA5E1,theStage]^[AdressePattern[kAdresseDiagonaleA5E1]+122];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA5E1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA6F1,theStage]^[AdressePattern[kAdresseDiagonaleA6F1]+365];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA6F1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA7G1,theStage]^[AdressePattern[kAdresseDiagonaleA7G1]+1094];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA7G1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA8H1,theStage]^[AdressePattern[kAdresseDiagonaleA8H1]+3281];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleA8H1 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleB8H2,theStage]^[AdressePattern[kAdresseDiagonaleB8H2]+1094];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleB8H2 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleC8H3,theStage]^[AdressePattern[kAdresseDiagonaleC8H3]+365];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleC8H3 = ',aux,5);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleD8H4,theStage]^[AdressePattern[kAdresseDiagonaleD8H4]+122];
      WritelnStringAndReelDansRapport('kAdresseDiagonaleD8H4 = ',aux,5);
      evalPartielle := evalPartielle+aux;
    end;


  if numeroDuCoup < 40 then
    with frontiere do
    begin
      mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
			mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);
			aux := whichEval.Mobilite^[numeroDuCoup]*(mobiliteNoire-mobiliteBlanche);
			WritelnStringAndReelDansRapport('Mobilite = ',aux,5);
      evalPartielle := evalPartielle+aux;

      evalFrontiereNonLineaire := nbadjacent[pionBlanc]*nbfront[pionBlanc] - nbadjacent[pionNoir]*nbfront[pionNoir];
			if evalFrontiereNonLineaire >  250 then evalFrontiereNonLineaire := 250 else
			if evalFrontiereNonLineaire < -250 then evalFrontiereNonLineaire := -250;
			aux := whichEval.FrontiereNonLineaire^[numeroDuCoup]*evalFrontiereNonLineaire;
			WritelnStringAndReelDansRapport('FrontiereNonLineaire = ',aux,5);
      evalPartielle := evalPartielle+aux;

      evalFrontiereSquares := nbadjacent[pionBlanc]-nbadjacent[pionNoir];
      aux := whichEval.FrontiereSquares^[numeroDuCoup]*evalFrontiereSquares;
      WritelnStringAndReelDansRapport('FrontiereSquares = ',aux,5);
      evalPartielle := evalPartielle+aux;

			evalFrontiereDiscs := nbfront[pionBlanc]-nbfront[pionNoir];
			aux := whichEval.FrontiereDiscs^[numeroDuCoup]*evalFrontiereDiscs;
			WritelnStringAndReelDansRapport('FrontiereDiscs = ',aux,5);
      evalPartielle := evalPartielle+aux;

      if (position[11] = pionVide) and (position[18] = pionVide) and (position[81] = pionVide) and (position[88] = pionVide) then
			  begin
			    diffNbreDiscs := nbBlanc-nbNoir;
			    aux := 0.25*diffNbreDiscs;
			    WritelnStringAndReelDansRapport('Minimisation = ',aux,5);
			    evalPartielle := evalPartielle+aux;
			  end;
    end;

  if trait = pionNoir
    then evalPartielle := tablePenalitePourLeTraitEnFlottant[numeroDuCoup] + evalPartielle
    else evalPartielle := tablePenalitePourLeTraitEnFlottant[numeroDuCoup] - evalPartielle;

  WritelnStringAndReelDansRapport('Eval totale (pour Noir) = ',evalPartielle,5);


end;


function DeltaPourCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var nroRefPartie : SInt32; var ScoreCiblePourNoir,EvalPourNoir : TypeReel; var whichEval : VectNewEval) : TypeReel;
var deltaEval : TypeReel;
    scoreTheoriquePourNoir,scoreReelPourNoir,nbCoupsJoues : SInt16;
    tranquillesNoirs,tranquillesBlancs : ListeDeCases;
begin
  trait := pionNoir;
  nbCoupsJoues := nbNoir+nbBlanc-4;
  evalPourNoir := NewEval(position,jouable,frontiere,nbNoir,nbBlanc,trait,whichEval,tranquillesNoirs,tranquillesBlancs,false);
  if nbCoupsJoues <= 40
    then
      begin
        scoreTheoriquePourNoir := GetScoreTheoriqueParNroRefPartie(nroRefPartie);
        scoreCiblePourNoir := scoreTheoriquePourNoir;
      end
    else
      begin
        GetScoresTheoriqueEtReelParNroRefPartie(nroRefPartie,scoreTheoriquePourNoir,scoreReelPourNoir);
        {on fait une interpolation lineaire entre :
          -- le score theorique, suppose calcule apres le coup 40
          -- le score reel, suppose calcule apres le coup 60 }
        scoreCiblePourNoir := scoreTheoriquePourNoir+(nbCoupsJoues-40)*(scoreReelPourNoir-scoreTheoriquePourNoir)/20.0;
      end;
  {on normalise de [0.0 .. 64.0] à [-64.0 .. 64.0]}
  scoreCiblePourNoir := scoreCiblePourNoir+scoreCiblePourNoir;
  scoreCiblePourNoir := scoreCiblePourNoir-64.0;
  if trait = pionNoir
    then deltaEval := scoreCiblePourNoir-evalPourNoir
    else deltaEval := (-scoreCiblePourNoir)-evalPourNoir;

  DeltaPourCettePosition := deltaEval;
end;

function NewEvalEnInteger(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval; var tranquillesNoirs,tranquillesBlancs : ListeDeCases) : SInt32;
var EvalEnReel : TypeReel;
    aux : SInt32;
begin

  EvalEnReel := NewEval(position,jouable,frontiere,nbNoir,nbBlanc,trait,whichEval,tranquillesNoirs,tranquillesBlancs,true);
  aux := RoundToL(100.0*EvalEnReel);
  if aux > 6400 then aux := 6400;
  if aux < -6400 then aux := -6400;
  NewEvalEnInteger := aux;

  {NewEvalEnInteger := 0;}
end;

procedure AfficheStatistiquesMobilite;
var k,n : SInt32;
begin
  with statistiques_mobilite do
    begin
      WritelnNumDansRapport('occ_total = ',total);
      WritelnStringAndReelDansRapport('nb_mobility_cut = ',100.0*nb_mobility_cut/total,4);
      WritelnStringAndReelDansRapport('echecs_total = ',100.0*echec_mobility_cut/total,4);
      for k := 0 to 6 do
        if occ_par_stage[k] > 0 then
        begin
          WritelnNumDansRapport('stage = ',k);
          for n := -64 to 64 do
            begin
              if stat[k,n].occ <> 0 then
                begin
                  WriteNumDansRapport('mob = ',n);
                  WriteNumDansRapport(' : ',stat[k,n].occ);
                  WriteStringAndReelDansRapport('  % = ',100.0*stat[k,n].occ/occ_par_stage[k],3);
                  WriteStringAndReelDansRapport('  eval = ',1.0*stat[k,n].val_sans_mob/stat[k,n].occ,4);
                  WritelnStringAndReelDansRapport('  echec = ',100.0*stat[k,n].echec_cut/stat[k,n].occ,4);
                end;
            end;
        end;
    end;
end;

procedure CollecteStatistiqueValeurMobilite(stage,evalSansMobilite,valeurMobilite : SInt32; mobilityCut,mobCutEstRate : boolean);
var mob,eval : SInt32;
begin
  if valeurMobilite > 0
    then mob := (valeurMobilite + 50) div 100
    else mob := (valeurMobilite - 50) div 100;

  if mob >  64 then mob :=  64;
  if mob < -64 then mob := -64;

  if evalSansMobilite > 0
    then eval := (evalSansMobilite + 50) div 100
    else eval := (evalSansMobilite - 50) div 100;

  if eval >  64 then eval :=  64;
  if eval < -64 then eval := -64;

  with statistiques_mobilite do
    begin
      inc(total);


      if mobilityCut then inc(nb_mobility_cut);
      if mobCutEstRate then inc(echec_mobility_cut);

      inc(occ_par_stage[stage]);
      inc(stat[stage,mob].occ);
      stat[stage,mob].val_sans_mob := stat[stage,mob].val_sans_mob + eval;

      if mobCutEstRate then inc(stat[stage,mob].echec_cut);

      if (total mod 400000) = 0 then AfficheStatistiquesMobilite;
    end;

end;


function NewEvalDeCassio(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEvalInteger; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; alpha,beta : SInt32) : SInt32;
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage : SInt32;
    evalPartielle : SInt32;
    mobiliteNoire,mobiliteBlanche : SInt32;
    evalFrontiereNonLineaire : SInt32;
    evalFrontiereSquares,evalFrontiereDiscs : SInt32;
    diffNbreDiscs,coeffMobilite : SInt32;
    evalMinimisation,evalFrontiere : SInt32;
    mobilitePourCoupure : SInt32;

const MOBILITY_WINDOW = 350;

label suite;
begin

  if not(GetNouvelleEvalDejaChargee) then
    begin
      {WritelnDansRapport('ASSERT : eval non chargee dans NewEvalDeCassio !!');}
      NewEvalDeCassio := 0;
      exit(NewEvalDeCassio);
    end;

  numeroDuCoup := nbNoir+nbBlanc-3;
  if numeroDuCoup < 0 then numeroDuCoup := 0;
  if numeroDuCoup > 64 then numeroDuCoup := 64;

  theStage := gameStage[numeroDuCoup];

  evalPartielle := 0;
  if trait = pionNoir
		then evalPartielle :=  tablePenalitePourLeTraitEnInteger[numeroDuCoup]
		else evalPartielle := -tablePenalitePourLeTraitEnInteger[numeroDuCoup];

  evalPartielle := RoundToL(CoeffPenalitePourNouvelleEval*evalPartielle);


  {CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);}
  {la meme fonction, inline}
  with frontiere do
    begin
      Edge2XNord  := AdressePattern[kAdresseBordNord ] + 6561*(position[22] + 3*position[27]);
      Edge2XSud   := AdressePattern[kAdresseBordSud  ] + 6561*(position[72] + 3*position[77]);
      Edge2XOuest := AdressePattern[kAdresseBordOuest] + 6561*(position[22] + 3*position[72]);
      Edge2XEst   := AdressePattern[kAdresseBordEst  ] + 6561*(position[27] + 3*position[77]);
    end;

  evalPartielle := evalPartielle+
                   whichEval.Edges2X[theStage].data^[Edge2XNord  + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage].data^[Edge2XSud   + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage].data^[Edge2XOuest + kDecalagePourEdge2X] +
                   whichEval.Edges2X[theStage].data^[Edge2XEst   + kDecalagePourEdge2X];

  with frontiere,whichEval do
    begin
      evalPartielle := evalPartielle + Pattern[kAdresseColonne2,theStage].data^[AdressePattern[kAdresseColonne2]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne3,theStage].data^[AdressePattern[kAdresseColonne3]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne4,theStage].data^[AdressePattern[kAdresseColonne4]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne5,theStage].data^[AdressePattern[kAdresseColonne5]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne6,theStage].data^[AdressePattern[kAdresseColonne6]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseColonne7,theStage].data^[AdressePattern[kAdresseColonne7]+3281];

      evalPartielle := evalPartielle + Pattern[kAdresseLigne2,theStage].data^[AdressePattern[kAdresseLigne2]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne3,theStage].data^[AdressePattern[kAdresseLigne3]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne4,theStage].data^[AdressePattern[kAdresseLigne4]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne5,theStage].data^[AdressePattern[kAdresseLigne5]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne6,theStage].data^[AdressePattern[kAdresseLigne6]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseLigne7,theStage].data^[AdressePattern[kAdresseLigne7]+3281];

      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinA1,theStage].data^[AdressePattern[kAdresseBlocCoinA1]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinH1,theStage].data^[AdressePattern[kAdresseBlocCoinH1]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinA8,theStage].data^[AdressePattern[kAdresseBlocCoinA8]+797162];
      evalPartielle := evalPartielle + Pattern[kAdresseBlocCoinH8,theStage].data^[AdressePattern[kAdresseBlocCoinH8]+797162];

      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA4E8,theStage].data^[AdressePattern[kAdresseDiagonaleA4E8]+122];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA3F8,theStage].data^[AdressePattern[kAdresseDiagonaleA3F8]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA2G8,theStage].data^[AdressePattern[kAdresseDiagonaleA2G8]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA1H8,theStage].data^[AdressePattern[kAdresseDiagonaleA1H8]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleB1H7,theStage].data^[AdressePattern[kAdresseDiagonaleB1H7]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleC1H6,theStage].data^[AdressePattern[kAdresseDiagonaleC1H6]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleD1H5,theStage].data^[AdressePattern[kAdresseDiagonaleD1H5]+122];

      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA5E1,theStage].data^[AdressePattern[kAdresseDiagonaleA5E1]+122];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA6F1,theStage].data^[AdressePattern[kAdresseDiagonaleA6F1]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA7G1,theStage].data^[AdressePattern[kAdresseDiagonaleA7G1]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleA8H1,theStage].data^[AdressePattern[kAdresseDiagonaleA8H1]+3281];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleB8H2,theStage].data^[AdressePattern[kAdresseDiagonaleB8H2]+1094];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleC8H3,theStage].data^[AdressePattern[kAdresseDiagonaleC8H3]+365];
      evalPartielle := evalPartielle + Pattern[kAdresseDiagonaleD8H4,theStage].data^[AdressePattern[kAdresseDiagonaleD8H4]+122];
    end;

  { enlever les commentaires suivants pour que Cassio joue des mauvaises structures }
  {
  evalPartielle := -evalPartielle;
  }

  if (numeroDuCoup < 40)
    then
      with frontiere do
		    begin


		      (*****  La frontiere  *****)
		      evalFrontiere := 0;

		      evalFrontiereNonLineaire := nbadjacent[pionBlanc]*nbfront[pionBlanc] - nbadjacent[pionNoir]*nbfront[pionNoir];
					if evalFrontiereNonLineaire >  250 then evalFrontiereNonLineaire := 250 else
					if evalFrontiereNonLineaire < -250 then evalFrontiereNonLineaire := -250;
					evalFrontiere := evalFrontiere + whichEval.FrontiereNonLineaire.data^[numeroDuCoup]*evalFrontiereNonLineaire;

		      evalFrontiereSquares := nbadjacent[pionBlanc]-nbadjacent[pionNoir];
		      evalFrontiere := evalFrontiere + whichEval.FrontiereSquares.data^[numeroDuCoup]*evalFrontiereSquares;

					evalFrontiereDiscs := nbfront[pionBlanc]-nbfront[pionNoir];
					evalFrontiere := evalFrontiere + whichEval.FrontiereDiscs.data^[numeroDuCoup]*evalFrontiereDiscs;

					evalFrontiere := RoundToL(CoeffFrontierePourNouvelleEval*evalFrontiere);
					evalPartielle := evalPartielle + evalFrontiere;

		      (*****  la minimisation  *****)
		      if (position[11] = pionVide) and (position[18] = pionVide) and (position[81] = pionVide) and (position[88] = pionVide) then
					  begin
					    diffNbreDiscs := nbBlanc-nbNoir;
					    evalMinimisation := 25*diffNbreDiscs;
					    evalMinimisation := RoundToL(CoeffMinimisationPourNouvelleEval*evalMinimisation);
					    evalPartielle := evalPartielle + evalMinimisation;
					  end;

					(*****  la mobilite  *****)
					coeffMobilite := whichEval.Mobilite.data^[numeroDuCoup];
					coeffMobilite := RoundToL(CoeffMobiliteUnidirectionnellePourNouvelleEval*coeffMobilite);


					{ Le terme MobiliteSemiTranquilleAvecCasesC est le terme le plus long (et de loin) à
					  calculer dans l'évaluation : on sépare les calculs pour Blanc et Noir pour pouvoir
					  faire des élagages alpha-beta, en utilisant la positivité de coeffMobilite}
					if trait = pionNoir
					  then
					    begin

					      { 95% des corrections de mobilite sont dans l'intervalle [-3.5 pions, 3.5 pions] }
					      { on peut donc faire des elagages probabilistes }
					      if (evalPartielle <= (alpha - MOBILITY_WINDOW)) or (evalPartielle >= (beta + MOBILITY_WINDOW))
					        then goto suite;

					      if (evalPartielle < alpha)
					        then
					          begin
					            mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
							        evalPartielle   := evalPartielle + coeffMobilite*mobiliteNoire;

								      if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
								        then mobilitePourCoupure := 4 + ((evalPartielle - (alpha - MoitieQuantum)) div coeffMobilite)
								        else mobilitePourCoupure := 4 + ((evalPartielle - alpha) div coeffMobilite);

								      if mobilitePourCoupure > 0 then
							          begin
					                mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,mobilitePourCoupure);
								          evalPartielle   := evalPartielle - coeffMobilite*mobiliteBlanche;
							          end;
					          end
					        else
					          begin
								      mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);
								      evalPartielle   := evalPartielle - coeffMobilite*mobiliteBlanche;

								      if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
								        then mobilitePourCoupure := 4 + (((beta + MoitieQuantum) - evalPartielle) div coeffMobilite)
								        else mobilitePourCoupure := 4 + ((beta - evalPartielle) div coeffMobilite);

								      if mobilitePourCoupure > 0 then
							          begin
							            mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,mobilitePourCoupure);
							            evalPartielle   := evalPartielle + coeffMobilite*mobiliteNoire;
							          end;
							      end;
					    end
					  else
					    begin

					      { 95% des corrections de mobilite sont dans l'intervalle [-3.5 pions, 3.5 pions] }
					      { on peut donc faire des elagages probabilistes }
					      if ( -evalPartielle <= (alpha - MOBILITY_WINDOW)) or (-evalPartielle >= (beta + MOBILITY_WINDOW))
					        then goto suite;


					      if (-evalPartielle < alpha)
					        then
					          begin
					            mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);
										  evalPartielle   := evalPartielle - coeffMobilite*mobiliteBlanche;

								      if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
								        then mobilitePourCoupure := 4 + ((-evalPartielle - (alpha - MoitieQuantum)) div coeffMobilite)
								        else mobilitePourCoupure := 4 + ((-evalPartielle - alpha) div coeffMobilite);

								      if mobilitePourCoupure > 0 then
								        begin
					                mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,mobilitePourCoupure);
								          evalPartielle   := evalPartielle + coeffMobilite*mobiliteNoire;
										    end;
					          end
					        else
					          begin
								      mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
								      evalPartielle   := evalPartielle + coeffMobilite*mobiliteNoire;

								      if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
								        then mobilitePourCoupure := 4 + (((beta + MoitieQuantum) + evalPartielle) div coeffMobilite)
								        else mobilitePourCoupure := 4 + ((beta + evalPartielle) div coeffMobilite);

								      if mobilitePourCoupure > 0 then
								        begin
										      mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,mobilitePourCoupure);
										      evalPartielle   := evalPartielle - coeffMobilite*mobiliteBlanche;
										    end;
										end;
					    end;
		    end; {with frontiere}

  suite:

  { enlever les commentaires suivants pour que Cassio joue de l'anti-reversi }
  {
  evalPartielle := -evalPartielle;
  }

  {les coefficients dans les tables supposent que le trait est a Noir : on inverse l'eval si le trait est a Blanc}
  if trait = pionBlanc then evalPartielle := -evalPartielle;


  // REMARQUE : l'eval de Cassio n'est pas tres bien normalisee, alors la ligne suivante est necessaire !!
  evalPartielle := (evalPartielle * 182) div 128;


  if evalPartielle >  6400 then evalPartielle :=  6400;
  if evalPartielle < -6400 then evalPartielle := -6400;

  if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
    then
      begin
        if evalPartielle >= 0
          then NewEvalDeCassio := (((evalPartielle + MoitieQuantum) div QuantumDiscretisation)*QuantumDiscretisation)
          else NewEvalDeCassio := (((evalPartielle - MoitieQuantum + 1) div QuantumDiscretisation)*QuantumDiscretisation);
      end
    else
      NewEvalDeCassio := evalPartielle;

  {
  if trait = pionNoir
    then
      begin
        WritelnDansRapport('');
        WritelnPositionEtTraitDansRapport(position,pionNoir);
        WritelnStringAndReelDansRapport('  => NewEvalDeCassio = ',evalPartielle*0.01, 4);
      end
    else
      begin
        WritelnDansRapport('');
        WritelnPositionEtTraitDansRapport(position,pionBlanc);
        WritelnStringAndReelDansRapport('  => NewEvalDeCassio = ',-evalPartielle*0.01, 4);
      end;
  }
end;


procedure EcritNewEvalIntegerDansRapport(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEvalInteger);
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    numeroDuCoup,theStage : SInt32;
    aux,evalPartielle : SInt32;
    evalPartiellePourNoir : SInt32;
    evalPartiellePourBlanc : SInt32;
    evalPartielleEdmond : SInt32;
    mobiliteNoire,mobiliteBlanche : SInt32;
    evalFrontiereNonLineaire : SInt32;
    evalFrontiereSquares,evalFrontiereDiscs : SInt32;
    diffNbreDiscs : SInt32;
    tranquillesNoirs,tranquillesBlancs : ListeDeCases;
    rapportEdmondSurCassio : double_t;
    tempoRecursiviteDansEval : boolean;
    nbEvalsRecursives : SInt32;
    evalPartielleRecursive : SInt32;

    procedure WritelnStringAndNoteDansRapport(s : String255; note : SInt32);
    begin
      if (note >= 1000) or (note <= -1000)
        then WritelnStringAndReelDansRapport(s, (0.01 * note), 4)
        else WritelnStringAndReelDansRapport(s, (0.01 * note), 3);
    end;

begin

  WritelnPositionEtTraitDansRapport(position,trait);

  trait := pionNoir;

  evalPartielle := 0;

  numeroDuCoup := nbNoir+nbBlanc-3;
  theStage := gameStage[numeroDuCoup];



  {CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);}
  {la meme fonction, inline}
  with frontiere do
    begin
      Edge2XNord  := AdressePattern[kAdresseBordNord ] + 6561*(position[22] + 3*position[27]);
      Edge2XSud   := AdressePattern[kAdresseBordSud  ] + 6561*(position[72] + 3*position[77]);
      Edge2XOuest := AdressePattern[kAdresseBordOuest] + 6561*(position[22] + 3*position[72]);
      Edge2XEst   := AdressePattern[kAdresseBordEst  ] + 6561*(position[27] + 3*position[77]);
    end;

  aux := whichEval.Edges2X[theStage].data^[Edge2XNord  + kDecalagePourEdge2X];
  WritelnStringAndNoteDansRapport('bordNord = ',aux);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage].data^[Edge2XSud   + kDecalagePourEdge2X];
  WritelnStringAndNoteDansRapport('bordSud = ',aux);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage].data^[Edge2XOuest + kDecalagePourEdge2X];
  WritelnStringAndNoteDansRapport('bordOuest = ',aux);
  evalPartielle := evalPartielle+aux;
  aux := whichEval.Edges2X[theStage].data^[Edge2XEst   + kDecalagePourEdge2X];
  WritelnStringAndNoteDansRapport('bordEst = ',aux);
  evalPartielle := evalPartielle+aux;

  with frontiere,whichEval do
    begin
      aux := Pattern[kAdresseColonne2,theStage].data^[AdressePattern[kAdresseColonne2]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne2 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne3,theStage].data^[AdressePattern[kAdresseColonne3]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne3 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne4,theStage].data^[AdressePattern[kAdresseColonne4]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne4 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne5,theStage].data^[AdressePattern[kAdresseColonne5]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne5 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne6,theStage].data^[AdressePattern[kAdresseColonne6]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne6 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseColonne7,theStage].data^[AdressePattern[kAdresseColonne7]+3281];
      WritelnStringAndNoteDansRapport('kAdresseColonne7 = ',aux);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseLigne2,theStage].data^[AdressePattern[kAdresseLigne2]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne2 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne3,theStage].data^[AdressePattern[kAdresseLigne3]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne3 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne4,theStage].data^[AdressePattern[kAdresseLigne4]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne4 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne5,theStage].data^[AdressePattern[kAdresseLigne5]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne5 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne6,theStage].data^[AdressePattern[kAdresseLigne6]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne6 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseLigne7,theStage].data^[AdressePattern[kAdresseLigne7]+3281];
      WritelnStringAndNoteDansRapport('kAdresseLigne7 = ',aux);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseBlocCoinA1,theStage].data^[AdressePattern[kAdresseBlocCoinA1]+797162];
      WritelnStringAndNoteDansRapport('kAdresseBlocCoinA1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinH1,theStage].data^[AdressePattern[kAdresseBlocCoinH1]+797162];
      WritelnStringAndNoteDansRapport('kAdresseBlocCoinH1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinA8,theStage].data^[AdressePattern[kAdresseBlocCoinA8]+797162];
      WritelnStringAndNoteDansRapport('kAdresseBlocCoinA8 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseBlocCoinH8,theStage].data^[AdressePattern[kAdresseBlocCoinH8]+797162];
      WritelnStringAndNoteDansRapport('kAdresseBlocCoinH8 = ',aux);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseDiagonaleA4E8,theStage].data^[AdressePattern[kAdresseDiagonaleA4E8]+122];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA4E8 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA3F8,theStage].data^[AdressePattern[kAdresseDiagonaleA3F8]+365];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA3F8 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA2G8,theStage].data^[AdressePattern[kAdresseDiagonaleA2G8]+1094];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA2G8 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA1H8,theStage].data^[AdressePattern[kAdresseDiagonaleA1H8]+3281];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA1H8 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleB1H7,theStage].data^[AdressePattern[kAdresseDiagonaleB1H7]+1094];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleB1H7 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleC1H6,theStage].data^[AdressePattern[kAdresseDiagonaleC1H6]+365];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleC1H6 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleD1H5,theStage].data^[AdressePattern[kAdresseDiagonaleD1H5]+122];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleD1H5 = ',aux);
      evalPartielle := evalPartielle+aux;

      aux := Pattern[kAdresseDiagonaleA5E1,theStage].data^[AdressePattern[kAdresseDiagonaleA5E1]+122];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA5E1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA6F1,theStage].data^[AdressePattern[kAdresseDiagonaleA6F1]+365];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA6F1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA7G1,theStage].data^[AdressePattern[kAdresseDiagonaleA7G1]+1094];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA7G1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleA8H1,theStage].data^[AdressePattern[kAdresseDiagonaleA8H1]+3281];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleA8H1 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleB8H2,theStage].data^[AdressePattern[kAdresseDiagonaleB8H2]+1094];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleB8H2 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleC8H3,theStage].data^[AdressePattern[kAdresseDiagonaleC8H3]+365];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleC8H3 = ',aux);
      evalPartielle := evalPartielle+aux;
      aux := Pattern[kAdresseDiagonaleD8H4,theStage].data^[AdressePattern[kAdresseDiagonaleD8H4]+122];
      WritelnStringAndNoteDansRapport('kAdresseDiagonaleD8H4 = ',aux);
      evalPartielle := evalPartielle+aux;
    end;


  if numeroDuCoup < 40 then
    with frontiere do
    begin
      mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
			mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);
			aux := whichEval.Mobilite.data^[numeroDuCoup]*(mobiliteNoire-mobiliteBlanche);
			WritelnStringAndNoteDansRapport('Mobilite = ',aux);
      evalPartielle := evalPartielle+aux;

      evalFrontiereNonLineaire := nbadjacent[pionBlanc]*nbfront[pionBlanc] - nbadjacent[pionNoir]*nbfront[pionNoir];
			if evalFrontiereNonLineaire >  250 then evalFrontiereNonLineaire := 250 else
			if evalFrontiereNonLineaire < -250 then evalFrontiereNonLineaire := -250;
			aux := whichEval.FrontiereNonLineaire.data^[numeroDuCoup]*evalFrontiereNonLineaire;
			WritelnStringAndNoteDansRapport('FrontiereNonLineaire = ',aux);
      evalPartielle := evalPartielle+aux;

      evalFrontiereSquares := nbadjacent[pionBlanc]-nbadjacent[pionNoir];
      aux := whichEval.FrontiereSquares.data^[numeroDuCoup]*evalFrontiereSquares;
      WritelnStringAndNoteDansRapport('FrontiereSquares = ',aux);
      evalPartielle := evalPartielle+aux;

			evalFrontiereDiscs := nbfront[pionBlanc]-nbfront[pionNoir];
			aux := whichEval.FrontiereDiscs.data^[numeroDuCoup]*evalFrontiereDiscs;
			WritelnStringAndNoteDansRapport('FrontiereDiscs = ',aux);
      evalPartielle := evalPartielle+aux;

      if (position[11] = pionVide) and (position[18] = pionVide) and (position[81] = pionVide) and (position[88] = pionVide) then
			  begin
			    diffNbreDiscs := nbBlanc-nbNoir;
			    aux := 25*diffNbreDiscs;
			    WritelnStringAndNoteDansRapport('Minimisation = ',aux);
			    evalPartielle := evalPartielle+aux;
			  end;
    end;

  if trait = pionNoir
    then evalPartielle := tablePenalitePourLeTraitEnInteger[numeroDuCoup] + evalPartielle
    else evalPartielle := tablePenalitePourLeTraitEnInteger[numeroDuCoup] - evalPartielle;

  if evalPartielle >  6400 then evalPartielle :=  6400;
  if evalPartielle < -6400 then evalPartielle := -6400;

  WritelnStringAndNoteDansRapport('Eval totale (pour Noir) = ',evalPartielle);


  evalPartielle := NewEvalDeCassio(position,jouable,frontiere,nbNoir,nbBlanc,trait,whichEval,
                                   tranquillesNoirs,tranquillesBlancs,-6400,6400);
  evalPartiellePourNoir := evalPartielle;

  WritelnStringAndNoteDansRapport('Verification : eval totale (pour Noir) = ',evalPartielle);


  evalPartielle := NewEvalDeCassio(position,jouable,frontiere,nbNoir,nbBlanc,-trait,whichEval,
                                   tranquillesNoirs,tranquillesBlancs,-6400,6400);
  evalPartiellePourBlanc := evalPartielle;

  WritelnStringAndNoteDansRapport('Verification : eval totale (pour Blanc) = ',evalPartielle);


  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir,nbBlanc,AQuiDeJouer);
  WritelnDansRapport('');
  if (AQuiDeJouer = pionNoir)
    then WritelnStringAndNoteDansRapport('Nouveau !! : eval pour Noir de Edmond = ',evalPartielleEdmond)
    else WritelnStringAndNoteDansRapport('Nouveau !! : eval pour Blanc de Edmond = ',evalPartielleEdmond);



  tempoRecursiviteDansEval := avecRecursiviteDansEval;
  avecRecursiviteDansEval := true;
  evalPartielleRecursive := Evaluation(position, AQuiDeJouer, nbBlanc, nbNoir, jouable, frontiere, false, -6400, 6400, nbEvalsRecursives);
  avecRecursiviteDansEval := tempoRecursiviteDansEval;

  if (AQuiDeJouer = pionNoir)
    then WritelnStringAndNoteDansRapport('Nouveau !! : eval pour Noir avec récursivité = ',evalPartielleRecursive)
    else WritelnStringAndNoteDansRapport('Nouveau !! : eval pour Blanc avec récursivité = ',evalPartielleRecursive);


  (*
  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir,nbBlanc,-AQuiDeJouer);
  WritelnStringAndNoteDansRapport('Nouveau !! : eval de Edmond de l''adversaire = ',evalPartielleEdmond);

  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir + 1,nbBlanc,AQuiDeJouer);
  WritelnStringAndNoteDansRapport('Nouveau !! : eval de Edmond , coup + 1 = ',evalPartielleEdmond);

  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir + 1,nbBlanc,-AQuiDeJouer);
  WritelnStringAndNoteDansRapport('Nouveau !! : eval de Edmond de l''adversaire, coup + 1 =  ',evalPartielleEdmond);

  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir - 1,nbBlanc,AQuiDeJouer);
  WritelnStringAndNoteDansRapport('Nouveau !! : eval de Edmond , coup + 1 = ',evalPartielleEdmond);

  evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoir - 1,nbBlanc,-AQuiDeJouer);
  WritelnStringAndNoteDansRapport('Nouveau !! : eval de Edmond de l''adversaire, coup + 1 =  ',evalPartielleEdmond);

  *)

  if AQuiDeJouer = pionBlanc
    then rapportEdmondSurCassio := (0.01 * evalPartielleEdmond) / (evalPartiellePourBlanc * 0.01)
    else rapportEdmondSurCassio := (0.01 * evalPartielleEdmond) / (evalPartiellePourNoir * 0.01);

  WritelnStringAndReelDansRapport('rapport edmond/cassio = ',rapportEdmondSurCassio, 4);


end;



procedure IncrementeDeriveesPartiellesCettePosition(deltaEval : TypeReel; var jouable : plBool; var position : plateauOthello; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32; var whichEval : VectNewEval);
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    Edge2XNordRenverse,Edge2XSudRenverse,Edge2XOuestRenverse,Edge2XEstRenverse : SInt32;
    PatternsRenverses : array[0..kNbPatternsDansEvalDeCassio] of SInt32;
    theStage,numeroDuCoup,k : SInt32;
    mobiliteNoire,mobiliteBlanche : SInt32;
    tranquillesNoirs,tranquillesBlancs : ListeDeCases;
    evalFrontiereNonLineaire : SInt32;
    evalFrontiereSquares,evalFrontiereDiscs : SInt32;
begin  {$UNUSED trait}
  numeroDuCoup := nbNoir+nbBlanc-3;
  theStage := gameStage[numeroDuCoup];



  CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);
  Edge2XNordRenverse := SymmetricalMappingEdge2X(Edge2XNord);
  Edge2XSudRenverse  := SymmetricalMappingEdge2X(Edge2XSud);
  Edge2XOuestRenverse := SymmetricalMappingEdge2X(Edge2XOuest);
  Edge2XEstRenverse  := SymmetricalMappingEdge2X(Edge2XEst);

  whichEval.Edges2X[theStage]^[Edge2XNord  + kDecalagePourEdge2X] := whichEval.Edges2X[theStage]^[Edge2XNord  + kDecalagePourEdge2X] + deltaEval;
  whichEval.Edges2X[theStage]^[Edge2XSud   + kDecalagePourEdge2X] := whichEval.Edges2X[theStage]^[Edge2XSud   + kDecalagePourEdge2X] + deltaEval;
  whichEval.Edges2X[theStage]^[Edge2XOuest + kDecalagePourEdge2X] := whichEval.Edges2X[theStage]^[Edge2XOuest + kDecalagePourEdge2X] + deltaEval;
  whichEval.Edges2X[theStage]^[Edge2XEst   + kDecalagePourEdge2X] := whichEval.Edges2X[theStage]^[Edge2XEst   + kDecalagePourEdge2X] + deltaEval;

  if Edge2XNordRenverse  <> Edge2XNord  then IncrementeEdge2X(whichEval,Edge2XNordRenverse ,theStage,deltaEval);
  if Edge2XSudRenverse   <> Edge2XSud   then IncrementeEdge2X(whichEval,Edge2XSudRenverse  ,theStage,deltaEval);
  if Edge2XOuestRenverse <> Edge2XOuest then IncrementeEdge2X(whichEval,Edge2XOuestRenverse,theStage,deltaEval);
  if Edge2XEstRenverse   <> Edge2XEst   then IncrementeEdge2X(whichEval,Edge2XEstRenverse  ,theStage,deltaEval);



  with frontiere,whichEval do
    begin
      Pattern[kAdresseColonne2,theStage]^[AdressePattern[kAdresseColonne2]+3281] := Pattern[kAdresseColonne2,theStage]^[AdressePattern[kAdresseColonne2]+3281] + deltaEval;
      Pattern[kAdresseColonne3,theStage]^[AdressePattern[kAdresseColonne3]+3281] := Pattern[kAdresseColonne3,theStage]^[AdressePattern[kAdresseColonne3]+3281] + deltaEval;
      Pattern[kAdresseColonne4,theStage]^[AdressePattern[kAdresseColonne4]+3281] := Pattern[kAdresseColonne4,theStage]^[AdressePattern[kAdresseColonne4]+3281] + deltaEval;
      Pattern[kAdresseColonne5,theStage]^[AdressePattern[kAdresseColonne5]+3281] := Pattern[kAdresseColonne5,theStage]^[AdressePattern[kAdresseColonne5]+3281] + deltaEval;
      Pattern[kAdresseColonne6,theStage]^[AdressePattern[kAdresseColonne6]+3281] := Pattern[kAdresseColonne6,theStage]^[AdressePattern[kAdresseColonne6]+3281] + deltaEval;
      Pattern[kAdresseColonne7,theStage]^[AdressePattern[kAdresseColonne7]+3281] := Pattern[kAdresseColonne7,theStage]^[AdressePattern[kAdresseColonne7]+3281] + deltaEval;

      Pattern[kAdresseLigne2,theStage]^[AdressePattern[kAdresseLigne2]+3281] := Pattern[kAdresseLigne2,theStage]^[AdressePattern[kAdresseLigne2]+3281] + deltaEval;
      Pattern[kAdresseLigne3,theStage]^[AdressePattern[kAdresseLigne3]+3281] := Pattern[kAdresseLigne3,theStage]^[AdressePattern[kAdresseLigne3]+3281] + deltaEval;
      Pattern[kAdresseLigne4,theStage]^[AdressePattern[kAdresseLigne4]+3281] := Pattern[kAdresseLigne4,theStage]^[AdressePattern[kAdresseLigne4]+3281] + deltaEval;
      Pattern[kAdresseLigne5,theStage]^[AdressePattern[kAdresseLigne5]+3281] := Pattern[kAdresseLigne5,theStage]^[AdressePattern[kAdresseLigne5]+3281] + deltaEval;
      Pattern[kAdresseLigne6,theStage]^[AdressePattern[kAdresseLigne6]+3281] := Pattern[kAdresseLigne6,theStage]^[AdressePattern[kAdresseLigne6]+3281] + deltaEval;
      Pattern[kAdresseLigne7,theStage]^[AdressePattern[kAdresseLigne7]+3281] := Pattern[kAdresseLigne7,theStage]^[AdressePattern[kAdresseLigne7]+3281] + deltaEval;

      Pattern[kAdresseBlocCoinA1,theStage]^[AdressePattern[kAdresseBlocCoinA1]+797162] := Pattern[kAdresseBlocCoinA1,theStage]^[AdressePattern[kAdresseBlocCoinA1]+797162] + deltaEval;
      Pattern[kAdresseBlocCoinH1,theStage]^[AdressePattern[kAdresseBlocCoinH1]+797162] := Pattern[kAdresseBlocCoinH1,theStage]^[AdressePattern[kAdresseBlocCoinH1]+797162] + deltaEval;
      Pattern[kAdresseBlocCoinA8,theStage]^[AdressePattern[kAdresseBlocCoinA8]+797162] := Pattern[kAdresseBlocCoinA8,theStage]^[AdressePattern[kAdresseBlocCoinA8]+797162] + deltaEval;
      Pattern[kAdresseBlocCoinH8,theStage]^[AdressePattern[kAdresseBlocCoinH8]+797162] := Pattern[kAdresseBlocCoinH8,theStage]^[AdressePattern[kAdresseBlocCoinH8]+797162] + deltaEval;

      Pattern[kAdresseDiagonaleA4E8,theStage]^[AdressePattern[kAdresseDiagonaleA4E8]+122 ] := Pattern[kAdresseDiagonaleA4E8,theStage]^[AdressePattern[kAdresseDiagonaleA4E8]+122 ] + deltaEval;
      Pattern[kAdresseDiagonaleA3F8,theStage]^[AdressePattern[kAdresseDiagonaleA3F8]+365 ] := Pattern[kAdresseDiagonaleA3F8,theStage]^[AdressePattern[kAdresseDiagonaleA3F8]+365 ] + deltaEval;
      Pattern[kAdresseDiagonaleA2G8,theStage]^[AdressePattern[kAdresseDiagonaleA2G8]+1094] := Pattern[kAdresseDiagonaleA2G8,theStage]^[AdressePattern[kAdresseDiagonaleA2G8]+1094] + deltaEval;
      Pattern[kAdresseDiagonaleA1H8,theStage]^[AdressePattern[kAdresseDiagonaleA1H8]+3281] := Pattern[kAdresseDiagonaleA1H8,theStage]^[AdressePattern[kAdresseDiagonaleA1H8]+3281] + deltaEval;
      Pattern[kAdresseDiagonaleB1H7,theStage]^[AdressePattern[kAdresseDiagonaleB1H7]+1094] := Pattern[kAdresseDiagonaleB1H7,theStage]^[AdressePattern[kAdresseDiagonaleB1H7]+1094] + deltaEval;
      Pattern[kAdresseDiagonaleC1H6,theStage]^[AdressePattern[kAdresseDiagonaleC1H6]+365 ] := Pattern[kAdresseDiagonaleC1H6,theStage]^[AdressePattern[kAdresseDiagonaleC1H6]+365 ] + deltaEval;
      Pattern[kAdresseDiagonaleD1H5,theStage]^[AdressePattern[kAdresseDiagonaleD1H5]+122 ] := Pattern[kAdresseDiagonaleD1H5,theStage]^[AdressePattern[kAdresseDiagonaleD1H5]+122 ] + deltaEval;

      Pattern[kAdresseDiagonaleA5E1,theStage]^[AdressePattern[kAdresseDiagonaleA5E1]+122 ] := Pattern[kAdresseDiagonaleA5E1,theStage]^[AdressePattern[kAdresseDiagonaleA5E1]+122 ] + deltaEval;
      Pattern[kAdresseDiagonaleA6F1,theStage]^[AdressePattern[kAdresseDiagonaleA6F1]+365 ] := Pattern[kAdresseDiagonaleA6F1,theStage]^[AdressePattern[kAdresseDiagonaleA6F1]+365 ] + deltaEval;
      Pattern[kAdresseDiagonaleA7G1,theStage]^[AdressePattern[kAdresseDiagonaleA7G1]+1094] := Pattern[kAdresseDiagonaleA7G1,theStage]^[AdressePattern[kAdresseDiagonaleA7G1]+1094] + deltaEval;
      Pattern[kAdresseDiagonaleA8H1,theStage]^[AdressePattern[kAdresseDiagonaleA8H1]+3281] := Pattern[kAdresseDiagonaleA8H1,theStage]^[AdressePattern[kAdresseDiagonaleA8H1]+3281] + deltaEval;
      Pattern[kAdresseDiagonaleB8H2,theStage]^[AdressePattern[kAdresseDiagonaleB8H2]+1094] := Pattern[kAdresseDiagonaleB8H2,theStage]^[AdressePattern[kAdresseDiagonaleB8H2]+1094] + deltaEval;
      Pattern[kAdresseDiagonaleC8H3,theStage]^[AdressePattern[kAdresseDiagonaleC8H3]+365 ] := Pattern[kAdresseDiagonaleC8H3,theStage]^[AdressePattern[kAdresseDiagonaleC8H3]+365 ] + deltaEval;
      Pattern[kAdresseDiagonaleD8H4,theStage]^[AdressePattern[kAdresseDiagonaleD8H4]+122 ] := Pattern[kAdresseDiagonaleD8H4,theStage]^[AdressePattern[kAdresseDiagonaleD8H4]+122 ] + deltaEval;
    end;

  with frontiere do
    begin
      for k := 1 to kAdresseDiagonaleD8H4 do
        PatternsRenverses[k] := SymmetricalMappingLongSquaresLine(AdressePattern[k],taillePattern[k]);
      for k := kAdresseBlocCoinA1 to kAdresseBlocCoinH8 do
        PatternsRenverses[k] := SymmetricalMapping13SquaresCorner(AdressePattern[k]);
      for k := 1 to kAdresseBlocCoinH8 do
        if (k <> kAdresseBordOuest) and  {sauf les bords}
           (k <> kAdresseBordEst  ) and
           (k <> kAdresseBordNord ) and
           (k <> kAdresseBordSud  ) then
        begin
          if PatternsRenverses[k] <> AdressePattern[k] then
            IncrementePattern(whichEval,k,PatternsRenverses[k],theStage,deltaEval);
        end;
    end;



  if numeroDuCoup < 40 then
    with frontiere do
    begin
      {la mobilite}
      mobiliteNoire   := MobiliteSemiTranquilleAvecCasesC(pionNoir,position,jouable,frontiere,tranquillesNoirs,100000);
			mobiliteBlanche := MobiliteSemiTranquilleAvecCasesC(pionBlanc,position,jouable,frontiere,tranquillesBlancs,100000);

			(*
			if mobiliteNoire-mobiliteBlanche <> 0 then
			  whichEval.Mobilite^[numeroDuCoup] := whichEval.Mobilite^[numeroDuCoup]+deltaEval/(mobiliteNoire-mobiliteBlanche);
      *)

      {la frontiere non lineaire}
      evalFrontiereNonLineaire := nbadjacent[pionBlanc]*nbfront[pionBlanc] - nbadjacent[pionNoir]*nbfront[pionNoir];
			if evalFrontiereNonLineaire >  250 then evalFrontiereNonLineaire := 250 else
			if evalFrontiereNonLineaire < -250 then evalFrontiereNonLineaire := -250;

			(*
			if evalFrontiereNonLineaire <> 0 then
			  whichEval.FrontiereNonLineaire^[numeroDuCoup] := whichEval.FrontiereNonLineaire^[numeroDuCoup]+deltaEval/evalFrontiereNonLineaire;
      *)

      {la frontiere, vue comme la somme des cases adjacentes}
      evalFrontiereSquares := nbadjacent[pionBlanc]-nbadjacent[pionNoir];

      (*
      if evalFrontiereSquares <> 0 then
        whichEval.FrontiereSquares^[numeroDuCoup] := whichEval.FrontiereSquares^[numeroDuCoup]+deltaEval/evalFrontiereSquares;
      *)

      {la frontiere, vue comme les pions en frontiere}
			evalFrontiereDiscs := nbfront[pionBlanc]-nbfront[pionNoir];

			(*
			if evalFrontiereDiscs <> 0 then
			  whichEval.FrontiereDiscs^[numeroDuCoup] := whichEval.FrontiereDiscs^[numeroDuCoup]+deltaEval/evalFrontiereDiscs;
      *)

   end;
end;






procedure CollecteOccurenceCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var bidon : SInt32);
var Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt32;
    Edge2XNordRenverse,Edge2XSudRenverse,Edge2XOuestRenverse,Edge2XEstRenverse : SInt32;
    PatternsRenverses : array[0..kNbPatternsDansEvalDeCassio] of SInt32;
    numeroDuCoup,k,theStage : SInt32;
begin
  {$UNUSED jouable,trait,bidon}
  numeroDuCoup := nbNoir+nbBlanc-3;
  theStage := gameStage[numeroDuCoup];

  CalculeIndexesEdges2X(position,frontiere,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);
  Edge2XNordRenverse := SymmetricalMappingEdge2X(Edge2XNord);
  Edge2XSudRenverse  := SymmetricalMappingEdge2X(Edge2XSud);
  Edge2XOuestRenverse := SymmetricalMappingEdge2X(Edge2XOuest);
  Edge2XEstRenverse  := SymmetricalMappingEdge2X(Edge2XEst);

  IncrementeEdge2X(occurences,Edge2XNord ,theStage,1.0);
  IncrementeEdge2X(occurences,Edge2XSud  ,theStage,1.0);
  IncrementeEdge2X(occurences,Edge2XOuest,theStage,1.0);
  IncrementeEdge2X(occurences,Edge2XEst  ,theStage,1.0);
  if Edge2XNordRenverse  <> Edge2XNord  then IncrementeEdge2X(occurences,Edge2XNordRenverse ,theStage,1.0);
  if Edge2XSudRenverse   <> Edge2XSud   then IncrementeEdge2X(occurences,Edge2XSudRenverse  ,theStage,1.0);
  if Edge2XOuestRenverse <> Edge2XOuest then IncrementeEdge2X(occurences,Edge2XOuestRenverse,theStage,1.0);
  if Edge2XEstRenverse   <> Edge2XEst   then IncrementeEdge2X(occurences,Edge2XEstRenverse  ,theStage,1.0);

  with frontiere do
    begin
      for k := 1 to kAdresseDiagonaleD8H4 do
        PatternsRenverses[k] := SymmetricalMappingLongSquaresLine(AdressePattern[k],taillePattern[k]);
      for k := kAdresseBlocCoinA1 to kAdresseBlocCoinH8 do
        PatternsRenverses[k] := SymmetricalMapping13SquaresCorner(AdressePattern[k]);
      for k := 1 to kAdresseBlocCoinH8 do
        begin
          IncrementePattern(occurences,k,AdressePattern[k],theStage,1.0);
          if PatternsRenverses[k] <> AdressePattern[k] then
            IncrementePattern(occurences,k,PatternsRenverses[k],theStage,1.0);
        end;
    end;

  occurences.Mobilite^[numeroDuCoup] := occurences.Mobilite^[numeroDuCoup]+1.0;
  occurences.FrontiereDiscs^[numeroDuCoup] := occurences.FrontiereDiscs^[numeroDuCoup]+1.0;
  occurences.FrontiereSquares^[numeroDuCoup] := occurences.FrontiereSquares^[numeroDuCoup]+1.0;
  occurences.FrontiereNonLineaire^[numeroDuCoup] := occurences.FrontiereNonLineaire^[numeroDuCoup]+1.0;
end;



function ParticipeAuChi2(numeroDansLaListe,numeroRefPartie : SInt32; var tickGroupe : SInt32) : boolean;
var ok : boolean;
    scoreTheoriquePourNoir : SInt32;
begin  {$UNUSED numeroDansLaListe,tickGroupe}
  ok := (numeroRefPartie >= 1) and (numeroRefPartie <= nbPartiesActives) {and (numeroRefPartie <= 50)};


  if ok then
    begin
   (* if ((numeroRefPartie mod 100) = 0) then
        begin
          tickGroupe := TickCount-tickGroupe;
          WritelnNumDansRapport(NumEnString(numeroRefPartie)+' => temps = ',tickGroupe);
          tickGroupe := TickCount;
        end; *)

      scoreTheoriquePourNoir := GetScoreTheoriqueParNroRefPartie(numeroRefPartie);
      ok := (scoreTheoriquePourNoir >= 2) and (scoreTheoriquePourNoir <= 62);
    end;

  ParticipeAuChi2 := ok;
end;


procedure CollecteOccurencesPatternsDansPartie(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var result : SInt32);
begin
  {$UNUSED numeroRefPartie}
  inc(nbPartiesDansOccurences);
  ForEachPositionInGameDo(partie60,CollecteOccurenceCettePosition,result);
end;

procedure CollecteOccurencesPatternDApresListe;
var tick,tickgroupe : SInt32;
begin
  WriteDansRapport('Calcule du nombre d''occurences des patterns…');
  tick := TickCount;
  tickGroupe := TickCount;

  nbPartiesDansOccurences := 0;
  ForEachGameInListDo(ParticipeAuChi2,bidFiltreGameProc,CollecteOccurencesPatternsDansPartie,tickGroupe);

  tick := TickCount-tick;
  WritelnNumDansRapport(' : temps pour la boucle complete =',tick);
end;


procedure EcritDeltaEvalCettePosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nroRefPartie : SInt32);
var thisEvaluation,scoreCiblePourNoir,deltaEval : TypeReel;
    nbCoupsJoues : SInt32;
begin
  trait := pionNoir;
  nbCoupsJoues := nbNoir+nbBlanc-4;

  deltaEval := DeltaPourCettePosition(position,jouable,frontiere,nbNoir,nbBlanc,pionNoir,nroRefPartie,scoreCiblePourNoir,thisEvaluation,vecteurEvaluation);

  if ((nbCoupsJoues mod 7) = 0) then
      begin
        WritelnPositionEtTraitDansRapport(position,trait);
        WritelnNumDansRapport('nbCoupsJoues = '+NumEnString(nbCoupsJoues)+' => gameStage = ',GameStage[nbCoupsJoues]);
        WritelnStringAndReelDansRapport('Mobilite['+NumEnString(nbCoupsJoues+1)+'] = ',vecteurEvaluation.Mobilite^[nbCoupsJoues+1],5);
        WritelnStringAndReelDansRapport('thisEvaluation = ',thisEvaluation,5);
        WritelnStringAndReelDansRapport('scoreCiblePourNoir = ',scoreCiblePourNoir,5);
        WritelnStringAndReelDansRapport('deltaEval = ',deltaEval,5);
        WritelnDansRapport('');
      end;
end;



procedure EcritsQuelquesPositionsDeCettePartie(nroRefPartie : SInt32);
var partie60 : PackedThorGame;
begin
  ExtraitPartieTableStockageParties(nroRefPartie,partie60);
  ForEachPositionInGameDo(partie60,EcritDeltaEvalCettePosition,nroRefPartie);
end;

procedure EcritQuelsquesPositionsPartieAleatoireDansListe;
var nroRef : SInt32;
begin
  if (nbPartiesActives >= 1) then
    begin
      nroRef := RandomLongintEntreBornes(1,nbPartiesActives);
      WritelnNumDansRapport('partie n°',nroRef);
      EcritsQuelquesPositionsDeCettePartie(nroRef);
    end;
end;

procedure EcritVecteurMobiliteDansRapport(var whichEval : VectNewEval);
var k : SInt32;
begin
  for k := 1 to 41 do
    begin
      WriteStringAndReelDansRapport('Mobilite['+NumEnString(k)+'] = ',whichEval.Mobilite^[k],5);
      WriteStringAndReelDansRapport('   FrontiereDiscs['+NumEnString(k)+'] = ',whichEval.FrontiereDiscs^[k],5);
      WriteStringAndReelDansRapport('   FrontiereSquares['+NumEnString(k)+'] = ',whichEval.FrontiereSquares^[k],5);
      WriteStringAndReelDansRapport('   FrontiereNonLineaire['+NumEnString(k)+'] = ',whichEval.FrontiereNonLineaire^[k],5);
      WritelnDansRapport('');
    end;
end;

procedure TrieEvalEtEcritDansRapport(var whichVecteur : VectNewEval);
var n,stage,whichPattern,r,ticks,length,occ : SInt32;
    aux,valeur : TypeReel;
    patternOppose : SInt32;
begin
  stage := 3;
  whichPattern := kAdresseBlocCoinA1;
  length := taillePattern[whichPattern];

  WritelnDansRapport('entrée de la phase de tri…');
  ticks := TickCount;
  if length = 10
    then TrierPointMultidiemnsionnel(whichVecteur.Edges2X[stage],vecteurTriEval.rank.Edges2X[stage])
    else TrierPointMultidiemnsionnel(whichVecteur.Pattern[whichPattern,stage],vecteurTriEval.rank.Pattern[whichPattern,stage]);
  ticks := TickCount-ticks;
  WritelnDansRapport('sortie de la phase de tri…  temps = '+NumEnString(ticks));

  for n := 1 to 100 do
    begin
      if length = 10
        then
          begin
            r := RoundToL(vecteurTriEval.rank.Edges2X[stage]^[n]);

            aux := whichVecteur.Edges2X[stage]^[r];
            occ := RoundToL(occurences.Edges2X[stage]^[r]+0.25);
            valeur := vecteurEvaluation.Edges2X[stage]^[r];
            WritelnEdge2XAndStringDansRapport(r-kDecalagePourEdge2X,'stage = '+NumEnString(stage)+'  vect = '+ReelEnStringAvecDecimales(aux,10)+'  occ = '+NumEnString(occ)+'  valeur = '+ReelEnStringAvecDecimales(valeur,10));

            patternOppose := InverseNoirBlancDansAddressePattern(r,length);

            aux := whichVecteur.Edges2X[stage]^[patternOppose];
            occ := RoundToL(occurences.Edges2X[stage]^[patternOppose]+0.25);
            valeur := vecteurEvaluation.Edges2X[stage]^[patternOppose];
            WritelnEdge2XAndStringDansRapport(patternOppose-kDecalagePourEdge2X,'stage = '+NumEnString(stage)+'  vect = '+ReelEnStringAvecDecimales(aux,10)+'  occ = '+NumEnString(occ)+'  valeur = '+ReelEnStringAvecDecimales(valeur,10));

            WritelnDansRapport('');
          end
        else
          begin
            r := RoundToL(vecteurTriEval.rank.Pattern[whichPattern,stage]^[n]);

            aux := whichVecteur.Pattern[whichPattern,stage]^[r];
            occ := RoundToL(occurences.Pattern[whichPattern,stage]^[r]+0.25);
            valeur := vecteurEvaluation.Pattern[whichPattern,stage]^[r];
            WritelnLinePatternAndStringDansRapport(r-decalagePourPattern[whichPattern],length,'stage = '+NumEnString(stage)+'  vect = '+ReelEnStringAvecDecimales(aux,10)+'  occ = '+NumEnString(occ)+'  valeur = '+ReelEnStringAvecDecimales(valeur,10));

            patternOppose := InverseNoirBlancDansAddressePattern(r,length);

            aux := whichVecteur.Pattern[whichPattern,stage]^[patternOppose];
            occ := RoundToL(occurences.Pattern[whichPattern,stage]^[patternOppose]+0.25);
            valeur := vecteurEvaluation.Pattern[whichPattern,stage]^[patternOppose];
            WritelnLinePatternAndStringDansRapport(patternOppose-decalagePourPattern[whichPattern],length,'stage = '+NumEnString(stage)+'  vect = '+ReelEnStringAvecDecimales(aux,10)+'  occ = '+NumEnString(occ)+'  valeur = '+ReelEnStringAvecDecimales(valeur,10));

            WritelnDansRapport('');
          end;
    end;
end;




END.
