UNIT UnitTestNouvelleEval;


INTERFACE




procedure TestNouvelleEval;                                                                                                                                                         ATTRIBUTE_NAME('TestNouvelleEval')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio
{$IFC NOT(USE_PRELINK)}
    , UnitNouvelleEval, UnitChi2NouvelleEval, UnitMinimisationNewEval, UnitRapport, MyStrings, UnitBigVectors, UnitVecteursEval
    , UnitVecteursEvalInteger, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/TestNouvelleEval.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure EcritPointeursOccurencesDansRapport;
var n,k,stage,adresse : SInt32;
begin
  for stage := 0 to kNbMaxGameStage do
    begin
      adresse := SInt32(occurences.Edges2X[stage]);
      if adresse = 0
        then WritelnDansRapport('occurencesEdges2X['+NumEnString(stage)+'] = NIL')
        else
          begin
            n := DimensionDuPointMultidimensionnel(occurences.Edges2X[stage]);
            WriteNumDansRapport('occurencesEdges2X['+NumEnString(stage)+'] = ',adresse);
            WritelnNumDansRapport('   taille = ',n);
          end;

      for k := 1 to kNbPatternsDansEvalDeCassio do
        begin
          adresse := SInt32(occurences.Pattern[k,stage]);
          if adresse = 0
            then WritelnDansRapport('occurencesPattern['+NumEnString(k)+','+NumEnString(stage)+'] = NIL')
            else
              begin
                n := DimensionDuPointMultidimensionnel(occurences.Pattern[k,stage]);
                WriteNumDansRapport('occurencesPattern['+NumEnString(k)+','+NumEnString(stage)+'] = ',adresse);
                WritelnNumDansRapport('   taille = ',n);
              end;
        end;
    end;
end;





procedure TestNouvelleEval;
var i,k,n,longueur,numeroPattern,stage : SInt32;
    debutScan,scan,count : SInt32;
    chi2,tolerance : TypeReel;
    err : OSErr;
    s : String255;
begin {$UNUSED i,k,n,longueur,numeroPattern,stage,debutScan,scan,count,chi2,tolerance,s}

  {
  chi2 := CalculeChi2EtGradient(vecteurEvaluation,gradientEvaluation);
  WritelnStringAndReelDansRapport('chi^2 = ',chi2,10);
  }

  {
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
  WritelnDansRapport('');
  WritelnDansRapport('');
  }


  err := LitVecteurEvaluationSurLeDisque('Occurences(166415)',occurences);
  WritelnNumDansRapport('LitVecteurOccurencesSurLeDisque = ',err);



  (*
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);
  CollecteOccurencesPatternDApresListe;
  s := 'Occurences('+NumEnString(nbPartiesDansOccurences)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,occurences);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(occurences) = ',err);
  *)


  s := 'BestEvaluation';
  err := LitVecteurEvaluationSurLeDisque(s,vecteurEvaluation);
  WritelnNumDansRapport('LitVecteurEvaluationSurLeDisque("'+s+'") = ',err);
  {if err = 0 then
    begin
      SetUtilisationNouvelleEval(true);
    end;
  }



  (*
  WritelnDansRapport('Tri occurences :');
  TrieEvalEtEcritDansRapport(occurences);
  WritelnDansRapport('Tri vecteurEvaluation :');
  TrieEvalEtEcritDansRapport(vecteurEvaluation);
  DivisionVecteurEval(vecteurEvaluation,occurences,vecteurTriEval.rapportOccurence);
  WritelnDansRapport('Tri vecteurTriEval.rapportOccurence :');
  TrieEvalEtEcritDansRapport(vecteurTriEval.rapportOccurence);
  ValeurAbsolueVecteurEval(vecteurTriEval.rapportOccurence,vecteurTriEval.rapportOccurence);
  WritelnDansRapport('Tri valeur absolue de vecteurTriEval.rapportOccurence :');
  TrieEvalEtEcritDansRapport(vecteurTriEval.rapportOccurence);
  *)


  {
  VecteurEvalIntegerToVecteurEval(vecteurEvaluationInteger,vecteurEvaluation);
  EcritVecteurMobiliteDansRapport(vecteurEvaluation);
  }


  (*
  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);

  s := 'BestEvaluation(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  *)


  {
  err := LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger);
  WritelnNumDansRapport('LitVecteurEvaluationSurLeDisque(''Evaluation de Cassio'') = ',err);
  if err = 0 then
    begin
      SetUtilisationNouvelleEval(true);
    end;
  }





  VecteurEvalToVecteurEvalInteger(vecteurEvaluation,vecteurEvaluationInteger);


  s := 'Evaluation de Cassio';
  err := EcritVecteurEvaluationIntegerSurLeDisque(pathDossierFichiersAuxiliaires+s,0,vecteurEvaluationInteger);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(''Evaluation de Cassio'') = ',err);




(*
  s := 'BestEvalRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  EcritVecteurMobiliteDansRapport(vecteurEvaluation);
*)





  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);

 {evaluation par le chi2, non robuste}
  (*
  estimationRobuste := false;
  tolerance := 0.0001;
  MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(vecteurEvaluation);
  ConjugateGradientChi2(vecteurEvaluation,tolerance,count,chi2,true);
  WritelnNumDansRapport('sortie de ConjugateGradientChi2, nbiter = ',count);
  WritelnDansRapport('minimum = '+ReelEnStringAvecDecimales(chi2,10));


  s := 'BestEval(non rob,chi2 = '+ReelEnStringAvecDecimales(chi2,5)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,non robuste) = ',err);


  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);
  s := 'BestEvalNonRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,non robuste,smoothed) = ',err);
  *)


 {evaluation par la somme des valeurs absolues des deviation, robuste}
  (*
  estimationRobuste := true;
  tolerance := 0.0001;
  MetCoeffsMobiliteEtFrontiereConstantsDansEvaluation(vecteurEvaluation);
  ConjugateGradientChi2(vecteurEvaluation,tolerance,count,chi2,true);
  WritelnNumDansRapport('sortie de ConjugateGradientChi2, nbiter = ',count);
  WritelnDansRapport('minimum = '+ReelEnStringAvecDecimales(chi2,10));
  s := 'BestEval(robuste,chi2 = '+ReelEnStringAvecDecimales(chi2,5)+')';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste) = ',err);


  SmoothThisEvaluation(vecteurEvaluation,occurences);
  CalculeEvalPatternsInexistantParEchangeCouleur(vecteurEvaluation,occurences);
  AbaisseEvalPatternsRares(vecteurEvaluation,occurences,10.0,8.0);
  s := 'BestEvalRobuste(smoothed)';
  err := EcritVecteurEvaluationSurLeDisque(s,0,vecteurEvaluation);
  WritelnNumDansRapport('EcritVecteurEvaluationSurLeDisque(vecteurEvaluation,robuste,smoothed) = ',err);
  *)






  (*
  CollecteStatistiquesOccurencesPatternDApresListe;
  RandomizeTimer;
  stage := 0;
  numeroPattern := kAdresseBlocCoinH8;
  longueur := DimensionDuPointMultidimensionnel(occurences.Pattern[numeroPattern,stage]);
  for i := 1 to 50 do
    begin
      debutScan := RandomLongintEntreBornes(1,longueur);
      count := 0;
      for k := 0 to longueur do
        begin
          scan := debutScan+k;
          if scan > longueur then scan := scan-longueur;

          n := RoundToL(occurences.Pattern[numeroPattern,stage]^[scan]+0.25);
          if n = i then
            begin
              inc(count);
              Writeln13SquareCornerAndStringDansRapport(scan-decalagePourPattern[numeroPattern],NumEnString(n)+' occurences');
              WritelnDansRapport('');
              if count = 3 then leave;
            end;
        end;
    end;
  *)



  {
  for i := 1 to 34 do
    WritelnNumDansRapport('',decalagePourPattern[i]);}


  SetAutoVidageDuRapport(false);
  SetEcritToutDansRapportLog(false);
end;



END.
