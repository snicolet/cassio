UNIT UnitChi2NouvelleEval;


INTERFACE







 USES UnitDefCassio;




procedure InitUnitChi2NouvelleEval;

procedure SetPrefixeCalculeChi2(s : String255);  {pour affichage dans rapport}
procedure SetPrefixeCalculeChi2EtGradient(s : String255);  {pour affichage dans rapport}

procedure SetBornePourCalculGradientChi2(borne : TypeReel);
function CalculeChi2(var v : VectNewEval) : TypeReel;
function CalculeChi2EtGradient(var v,gradient : VectNewEval) : TypeReel;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitRapport, UnitUtilitaires, MyStrings, UnitGestionDuTemps, UnitNouvelleEval, UnitVecteursEval
    , UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/Chi2NouvelleEval.lk}
{$ENDC}


{END_USE_CLAUSE}










var sommePartielleChi2 : TypeReel;
    compteurPartiesChi2 : SInt32;
    compteurPositionsChi2 : SInt32;
    vecteurEvaluationChi2 : VectNewEval;
    vecteurGradientChi2 : VectNewEval;


    affichePositionsDansChi2 : boolean;
    afficheSommesPartiellesDanschi2 : boolean;

    prefixeCalculeChi2 : String255;
    prefixeCalculeChi2EtGradient : String255;

    bornePourCalculGradientChi2 : TypeReel;
    estimationRobuste : boolean;



procedure InitUnitChi2NouvelleEval;
begin
  SetPrefixeCalculeChi2('');
  SetPrefixeCalculeChi2EtGradient('');
  SetBornePourCalculGradientChi2(0.0);
  estimationRobuste := false;
end;

procedure SetPrefixeCalculeChi2(s : String255);  {pour affichage dans rapport}
begin
  PrefixeCalculeChi2 := s;
end;

procedure SetPrefixeCalculeChi2EtGradient(s : String255);  {pour affichage dans rapport}
begin
  PrefixeCalculeChi2EtGradient := s;
end;





procedure IncrementeChi2Position(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nroRefPartie : SInt32);
var thisEvaluation,scoreCiblePourNoir,deltaEval : TypeReel;
    nbCoupsJoues : SInt16;
begin
  trait := pionNoir;
  nbCoupsJoues := nbNoir+nbBlanc-4;

  deltaEval := DeltaPourCettePosition(position,jouable,frontiere,nbNoir,nbBlanc,pionNoir,nroRefPartie,scoreCiblePourNoir,thisEvaluation,vecteurEvaluationChi2);

  if estimationRobuste
    then sommePartielleChi2 := sommePartielleChi2+ Abs(deltaEval)
    else sommePartielleChi2 := sommePartielleChi2+ deltaEval*deltaEval;

  inc(compteurPositionsChi2);

  if afficheSommesPartiellesDanschi2 then
    if (compteurPositionsChi2 <> 0) and ((compteurPositionsChi2 mod 100) = 0) then
      WritelnStringAndReelDansRapport('N = '+NumEnString(compteurPositionsChi2)+' ',sommePartielleChi2/compteurPositionsChi2,5);
  if affichePositionsDansChi2 then
    if (nroRefPartie <= 10) and ((nbCoupsJoues mod 7) = 0) and (compteurPositionsChi2 <> 0) then
      begin
        WritelnPositionEtTraitDansRapport(position,trait);
        WritelnNumDansRapport('nbCoupsJoues = '+NumEnString(nbCoupsJoues)+' => gameStage = ',gameStage[nbCoupsJoues]);
        WritelnStringAndReelDansRapport('thisEvaluation = ',thisEvaluation,5);
        WritelnStringAndReelDansRapport('scoreCiblePourNoir = ',scoreCiblePourNoir,5);
        WritelnStringAndReelDansRapport('deltaEval = ',deltaEval,5);
        WritelnStringAndReelDansRapport('N = '+NumEnString(compteurPositionsChi2)+' ',sommePartielleChi2/compteurPositionsChi2,5);
        WritelnDansRapport('');
      end;
end;

procedure IncrementeChi2Partie(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var result : SInt32);
begin
  {$UNUSED numeroRefPartie,result}
  inc(compteurPartiesChi2);
  ForEachPositionInGameDo(partie60,IncrementeChi2Position,numeroRefPartie);
end;


procedure SetBornePourCalculGradientChi2(borne : TypeReel);
begin
  bornePourCalculGradientChi2 := borne;
end;


function CalculeChi2(var v : VectNewEval) : TypeReel;
var tick,tickgroupe : SInt32;
    chi2 : TypeReel;
begin
  if VecteurEvalEstVide(v) or VecteurEvalEstVide(vecteurEvaluationChi2) then
   begin
     CalculeChi2 := -1.0;
   end;

  CopierPointeursVecteursEval(v,vecteurEvaluationChi2);
  sommePartielleChi2 := 0.0;
  compteurPositionsChi2 := 0;
  compteurPartiesChi2 := 0;

  tick := TickCount;
  tickGroupe := TickCount;

  affichePositionsDansChi2 := false;
  afficheSommesPartiellesDanschi2 := false;

  ForEachGameInListDo(ParticipeAuChi2,bidFiltreGameProc,IncrementeChi2Partie,tickGroupe);

  if compteurPositionsChi2 <> 0
    then chi2 := (sommePartielleChi2/compteurPositionsChi2)
    else chi2 := -1.0;

  tick := TickCount-tick;

  {WritelnNumDansRapport('temps CalculeChi2 =',tick);}
  {WritelnNumDansRapport('compteurPartiesChi2 = ',compteurPartiesChi2);
  WritelnNumDansRapport('compteurPositionsChi2 = ',compteurPositionsChi2);}

  if not(verboseMinimisationChi2) then
    begin
      WriteDansRapport(prefixeCalculeChi2+' : ');
      WriteDansRapport('CalculeChi2 ('+NumEnString(compteurPartiesChi2)+' => temps = '+NumEnString(tick)+')');
      WritelnDansRapport(' chi2 = '+ReelEnStringAvecDecimales(chi2,10));
    end;

  DoSystemTask(AQuiDeJouer);

  CalculeChi2 := chi2;
end;

procedure IncrementeChi2EtGradientPosition(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nroRefPartie : SInt32);
var thisEvaluation,scoreCiblePourNoir,deltaEval : TypeReel;
    nbCoupsJoues : SInt16;
begin
  trait := pionNoir;
  nbCoupsJoues := nbNoir+nbBlanc-4;

  deltaEval := DeltaPourCettePosition(position,jouable,frontiere,nbNoir,nbBlanc,pionNoir,nroRefPartie,scoreCiblePourNoir,thisEvaluation,vecteurEvaluationChi2);

  IncrementeDeriveesPartiellesCettePosition(-deltaEval,jouable,position,frontiere,nbNoir,nbBlanc,pionNoir,vecteurGradientChi2);

  if estimationRobuste
    then sommePartielleChi2 := sommePartielleChi2+ Abs(deltaEval)
    else sommePartielleChi2 := sommePartielleChi2+ deltaEval*deltaEval;

  inc(compteurPositionsChi2);

  if afficheSommesPartiellesDanschi2 then
    if (compteurPositionsChi2 <> 0) and ((compteurPositionsChi2 mod 100) = 0) then
      WritelnStringAndReelDansRapport('N = '+NumEnString(compteurPositionsChi2)+' ',sommePartielleChi2/compteurPositionsChi2,5);
  if affichePositionsDansChi2 then
    if (nroRefPartie <= 10) and ((nbCoupsJoues mod 7) = 0) and (compteurPositionsChi2 <> 0) then
      begin
        WritelnPositionEtTraitDansRapport(position,trait);
        WritelnNumDansRapport('nbCoupsJoues = '+NumEnString(nbCoupsJoues)+' => gameStage = ',gameStage[nbCoupsJoues]);
        WritelnStringAndReelDansRapport('thisEvaluation = ',thisEvaluation,5);
        WritelnStringAndReelDansRapport('scoreCiblePourNoir = ',scoreCiblePourNoir,5);
        WritelnStringAndReelDansRapport('deltaEval = ',deltaEval,5);
        WritelnStringAndReelDansRapport('N = '+NumEnString(compteurPositionsChi2)+' ',sommePartielleChi2/compteurPositionsChi2,5);
        WritelnDansRapport('');
      end;
end;




procedure IncrementeChi2EtGradientPartie(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var result : SInt32);
begin
  {$UNUSED numeroRefPartie,result}
  inc(compteurPartiesChi2);
  ForEachPositionInGameDo(partie60,IncrementeChi2EtGradientPosition,numeroRefPartie);
end;


function CalculeChi2EtGradient(var v,gradient : VectNewEval) : TypeReel;
var tick,tickgroupe : SInt32;
    chi2 : TypeReel;
begin
  if VecteurEvalEstVide(v) or VecteurEvalEstVide(vecteurEvaluationChi2) or
     VecteurEvalEstVide(gradient) or VecteurEvalEstVide(occurences) then
   begin
     CalculeChi2EtGradient := -1.0;
   end;

  CopierPointeursVecteursEval(v,vecteurEvaluationChi2);
  CopierPointeursVecteursEval(gradient,vecteurGradientChi2);
  AnnuleVecteurEval(vecteurGradientChi2);

  sommePartielleChi2 := 0.0;
  compteurPositionsChi2 := 0;
  compteurPartiesChi2 := 0;

  tick := TickCount;
  tickGroupe := TickCount;

  affichePositionsDansChi2 := false;
  afficheSommesPartiellesDanschi2 := false;

  ForEachGameInListDo(ParticipeAuChi2,bidFiltreGameProc,IncrementeChi2EtGradientPartie,tickGroupe);

  if compteurPositionsChi2 <> 0
    then
      begin
        chi2 := (sommePartielleChi2/compteurPositionsChi2);


        if bornePourCalculGradientChi2 > 0.0
          then DivisionBorneeVecteurEval(vecteurGradientChi2,occurences,vecteurGradientChi2,bornePourCalculGradientChi2)
          else HomothetieVecteurEval(vecteurGradientChi2,vecteurGradientChi2,2.0/compteurPositionsChi2);


        {DivisionVecteurEval(vecteurGradientChi2,occurences,vecteurGradientChi2);}
        {HomothetieVecteurEval(vecteurGradientChi2,vecteurGradientChi2,2.0/compteurPositionsChi2);}
      end
    else
        chi2 := -1.0;

  tick := TickCount-tick;
  {
  WritelnDansRapport('');
  WritelnNumDansRapport('temps CalculeChi2EtGradient =',tick);}
  {WritelnNumDansRapport('compteurPartiesChi2 = ',compteurPartiesChi2);
  WritelnNumDansRapport('compteurPositionsChi2 = ',compteurPositionsChi2);}

  if not(verboseMinimisationChi2) then
    begin
      WriteDansRapport(prefixeCalculeChi2EtGradient+' : ');
      WriteDansRapport('CalculeChi2EtGradient ('+NumEnString(compteurPartiesChi2)+' => temps = '+NumEnString(tick)+')');
      WritelnDansRapport(' chi2 = '+ReelEnStringAvecDecimales(chi2,10));
    end;

  DoSystemTask(AQuiDeJouer);

  CalculeChi2EtGradient := chi2;
end;



END.
