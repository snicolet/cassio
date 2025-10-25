UNIT UnitMoindresCarres;




INTERFACE







 uses UnitDefCassio;



procedure DoRegressionLineaireCoeffsCassio(ApresQuelCoup : SInt16);
procedure WritelnVecteurEvaluationDansRapport(nom : String255; vecteurEvals : VecteurReels; nbChiffres : SInt16);
procedure CalculeValeursEvaluationPartieNumero(nroRefPartie : SInt32; ApresQuelCoup : SInt16; var scoreParfaitPourNoir : SInt16; var vecteurEvaluationPourNoir : EvaluationCassioRec; var ok : boolean; var position : plateauOthello);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitEvaluation, UnitAccesNouveauFormat, UnitUtilitaires, UnitStrategie, UnitRapport, UnitNouveauFormat, UnitSuperviseur, MyStrings
    , UnitAlgebreLineaire, UnitNormalisation ;
{$ELSEC}
    {$I prelink/MoindresCarres.lk}
{$ENDC}


{END_USE_CLAUSE}















procedure CalculeValeursEvaluationPartieNumero(nroRefPartie     : SInt32;
                                               ApresQuelCoup : SInt16;
                                               var scoreParfaitPourNoir : SInt16;
                                               var vecteurEvaluationPourNoir : EvaluationCassioRec;
                                               var ok : boolean;
                                               var position : plateauOthello);

var s60 : PackedThorGame;
    trait : SInt32;
    nbNoir,nbBlanc : SInt32;
    jouables : plBool;
    frontiere : InfoFront;
begin
  ok := false;
  scoreParfaitPourNoir := -1;

  if (nroRefPartie >= 1) and (nroRefPartie <= nbPartiesActives) then
    begin
      ExtraitPartieTableStockageParties(nroRefPartie,s60);

      if CalculePositionEtTraitApres(s60,ApresQuelCoup,position,trait,nbBlanc,nbNoir) then
        begin
          Calcule_Valeurs_Tactiques(position,true);
          CarteFrontiere(position,frontiere);
          CarteJouable(position,jouables);

          vecteurEvaluationPourNoir := CreeEvaluationCassioRec(position,trait,nbBlanc,nbNoir,jouables,frontiere);
          if trait = pionNoir
            then scoreParfaitPourNoir := GetScoreTheoriqueParNroRefPartie(nroRefPartie)
            else scoreParfaitPourNoir := 64-GetScoreTheoriqueParNroRefPartie(nroRefPartie);

          {ok := true;}
          ok := (scoreParfaitPourNoir >= 12) and (scoreParfaitPourNoir <= 52);
        end;
    end;
end;




procedure TransformeEnregistrementEvaluationEnVecteur(valeursEvaluation    : EvaluationCassioRec;
                                                      nbValeursDansVecteur : SInt32;
                                                      var vecteurEvals     : VecteurReels);
begin
  SetVecteurNul(nbValeursDansVecteur,vecteurEvals);
  with valeursEvaluation do
    begin
      vecteurEvals.vec[kNotePenalite]                 := notePenalite;
      vecteurEvals.vec[kNoteBord]                     := noteBord;
      vecteurEvals.vec[kNoteCoin]                     := noteCoin;
      vecteurEvals.vec[kNotePriseCoin]                := notePriseCoin;
      vecteurEvals.vec[kNoteDefenseCoin]              := noteDefenseCoin;
      vecteurEvals.vec[kNoteMinimisationAvant]        := noteMinimisationAvant;
      vecteurEvals.vec[kNoteMinimisationApres]        := noteMinimisationApres;
      vecteurEvals.vec[kNoteCentre]                   := noteCentre;
      vecteurEvals.vec[kNoteGrandCentre]              := noteGrandCentre;
      vecteurEvals.vec[kNoteFrontiere]                := noteFrontiere;
      vecteurEvals.vec[kNoteEquivalentFrontiere]      := noteEquivalentFrontiere;
      vecteurEvals.vec[kNoteMobilite]                 := noteMobilite;
      vecteurEvals.vec[kNoteCaseX]                    := noteCaseX;
      vecteurEvals.vec[kNoteCaseXPlusCoin]            := noteCaseXPlusCoin;
      vecteurEvals.vec[kNoteCaseXEntreCasesC]         := noteCaseXEntreCasesC;
      vecteurEvals.vec[kNoteTrouCaseC]                := noteTrouCaseC;
      vecteurEvals.vec[kNoteOccupationTactique]       := noteOccupationTactique;
      vecteurEvals.vec[kNoteWipeOut]                  := noteWipeOut;
      vecteurEvals.vec[kNoteAleatoire]                := noteAleatoire;
      vecteurEvals.vec[kNoteTrousDeTroisHorrible]     := noteTrousDeTroisHorrible;
      vecteurEvals.vec[kNoteLiberteSurCaseA]          := noteLiberteSurCaseA;
      vecteurEvals.vec[kNoteLiberteSurCaseB]          := noteLiberteSurCaseB;
      vecteurEvals.vec[kNoteBonsBordsDeCinq]          := noteBonsBordsDeCinq;
      vecteurEvals.vec[kNoteTrousDeDeuxPerdantLaParite] := noteTrousDeDeuxPerdantLaParite;
      vecteurEvals.vec[kNoteArnaqueSurBordDeCinq]     := noteArnaqueSurBordDeCinq;
      vecteurEvals.vec[kNoteValeurBlocsDeCoin]        := noteValeurBlocsDeCoin;
      vecteurEvals.vec[kNoteBordsOpposes]             := noteBordsOpposes;
      vecteurEvals.vec[kNoteBordDeCinqTransformable]  := noteBordDeCinqTransformable;
      vecteurEvals.vec[kNoteGameOver]                 := noteGameOver;
      vecteurEvals.vec[kNoteBordDeSixPlusQuatre]      := noteBordDeSixPlusQuatre;
      vecteurEvals.vec[kNoteGrosseMasse]              := noteGrosseMasse;
      vecteurEvals.vec[kNoteCaseXConsolidantBordDeSix] := noteCaseXConsolidantBordDeSix;
    end;
end;

procedure WritelnVecteurEvaluationDansRapport(nom : String255; vecteurEvals : VecteurReels; nbChiffres : SInt16);
begin
    WritelnDansRapport(nom+'[NotePenalite] = '                  +ReelEnStringAvecDecimales(vecteurEvals.vec[kNotePenalite],nbChiffres));
    WritelnDansRapport(nom+'[NoteBord] = '                      +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteBord],nbChiffres));
    WritelnDansRapport(nom+'[NoteCoin] = '                      +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCoin],nbChiffres));
    WritelnDansRapport(nom+'[NotePriseCoin] = '                 +ReelEnStringAvecDecimales(vecteurEvals.vec[kNotePriseCoin],nbChiffres));
    WritelnDansRapport(nom+'[NoteDefenseCoin] = '               +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteDefenseCoin],nbChiffres));
    WritelnDansRapport(nom+'[NoteMinimisationAvant] = '         +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteMinimisationAvant],nbChiffres));
    WritelnDansRapport(nom+'[NoteMinimisationApres] = '         +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteMinimisationApres],nbChiffres));
    WritelnDansRapport(nom+'[NoteCentre] = '                    +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCentre],nbChiffres));
    WritelnDansRapport(nom+'[NoteGrandCentre] = '               +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteGrandCentre],nbChiffres));
    WritelnDansRapport(nom+'[NoteFrontiere] = '                 +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteFrontiere],nbChiffres));
    WritelnDansRapport(nom+'[NoteEquivalentFrontiere] = '       +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteEquivalentFrontiere],nbChiffres));
    WritelnDansRapport(nom+'[NoteMobilite] = '                  +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteMobilite],nbChiffres));
    WritelnDansRapport(nom+'[NoteCaseX] = '                     +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCaseX],nbChiffres));
    WritelnDansRapport(nom+'[NoteCaseXPlusCoin] = '             +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCaseXPlusCoin],nbChiffres));
    WritelnDansRapport(nom+'[NoteCaseXEntreCasesC] = '          +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCaseXEntreCasesC],nbChiffres));
    WritelnDansRapport(nom+'[NoteTrouCaseC] = '                 +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteTrouCaseC],nbChiffres));
    WritelnDansRapport(nom+'[NoteOccupationTactique] = '        +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteOccupationTactique],nbChiffres));
    WritelnDansRapport(nom+'[NoteWipeOut] = '                   +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteWipeOut],nbChiffres));
    WritelnDansRapport(nom+'[NoteAleatoire] = '                 +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteAleatoire],nbChiffres));
    WritelnDansRapport(nom+'[NoteTrousDeTroisHorrible] = '      +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteTrousDeTroisHorrible],nbChiffres));
    WritelnDansRapport(nom+'[NoteLiberteSurCaseA] = '           +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteLiberteSurCaseA],nbChiffres));
    WritelnDansRapport(nom+'[NoteLiberteSurCaseB] = '           +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteLiberteSurCaseB],nbChiffres));
    WritelnDansRapport(nom+'[NoteBonsBordsDeCinq] = '           +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteBonsBordsDeCinq],nbChiffres));
    WritelnDansRapport(nom+'[NoteTrousDeDeuxPerdantLaParite] = '+ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteTrousDeDeuxPerdantLaParite],nbChiffres));
    WritelnDansRapport(nom+'[NoteArnaqueSurBordDeCinq] = '      +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteArnaqueSurBordDeCinq],nbChiffres));
    WritelnDansRapport(nom+'[NoteValeurBlocsDeCoin] = '         +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteValeurBlocsDeCoin],nbChiffres));
    WritelnDansRapport(nom+'[NoteBordsOpposes] = '              +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteBordsOpposes],nbChiffres));
    WritelnDansRapport(nom+'[NoteBordDeCinqTransformable] = '   +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteBordDeCinqTransformable],nbChiffres));
    WritelnDansRapport(nom+'[NoteGameOver] = '                  +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteGameOver],nbChiffres));
    WritelnDansRapport(nom+'[NoteBordDeSixPlusQuatre] = '       +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteBordDeSixPlusQuatre],nbChiffres));
    WritelnDansRapport(nom+'[NoteGrosseMasse] = '               +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteGrosseMasse],nbChiffres));
    WritelnDansRapport(nom+'[NoteCaseXConsolidantBordDeSix] = ' +ReelEnStringAvecDecimales(vecteurEvals.vec[kNoteCaseXConsolidantBordDeSix],nbChiffres));

end;


procedure covsrt(var covar : MatriceReels; ma : SInt32; coeffVariable : VecteurBooleens; mfit : SInt32);
var i,j,k : SInt32;
    swap  : RealType;
begin
  for i := mfit+1 to ma do
    for j := 1 to i do
      begin
        covar.mat[i,j] := 0.0;
        covar.mat[j,i] := 0.0;
      end;
  k := mfit;
  for j := ma downto 1 do
    if coeffVariable.bool[j] then
      begin
        for i := 1 to ma do
          begin
            swap := covar.mat[i,k];
            covar.mat[i,k] := covar.mat[i,j];
            covar.mat[i,j] := swap;
          end;
        for i := 1 to ma do
          begin
            swap := covar.mat[k,i];
            covar.mat[k,i] := covar.mat[j,i];
            covar.mat[j,i] := swap;
          end;
        k := k-1;
      end;
end;




{cf Numerical Recipes in C, p 674}
procedure LinearFit(nbData         : SInt32;
                    ApresQuelCoup  : SInt16;
                    var a          : VecteurReels;    {coefficients lineaires}
                    coeffVariable  : VecteurBooleens; {coeffVariable[i] = false si a.vec[i] doit rester constant}
                    ma             : SInt32;         {nb de coeffs}
                    var covar      : MatriceReels;    {matrice de covariance}
                    var chisquare  : RealType;        {chi2}
                    var sigmaData  : RealType);       {sigma observe des donnees}
var i,j,k,l,m,mfit           : SInt32;
    sig2i,wt,ym              : RealType;
    alpha                    : MatriceReels;
    beta                     : VecteurReels;
    sol                      : VecteurReels;
    afunc                    : VecteurReels;
    vecteurEvaluationPourNoir: EvaluationCassioRec;
    scoreParfaitPourNoir     : SInt16;
    nbPartiesOK              : SInt32;
    sum                      : RealType;
    sigma                    : RealType;
    partieOK,SystemeOK       : boolean;
    position                 : plateauOthello;
    aux                      : RealType;
begin
  mfit := 0;
  for j := 1 to ma do
    if coeffVariable.bool[j] then mfit := mfit+1;
  if mfit = 0 then
    begin
      WritelnDansRapport('Pas de parametre ˆ Ajuster dans LinearFit !');
      exit(linearFit);
    end;

  WritelnNumDansRapport('mfit = ',mfit);
  WritelnNumDansRapport('ma = ',ma);

  SetMatriceCarreeNulle(ma,covar);
  SetMatriceCarreeNulle(mfit,alpha);
  SetVecteurNul(mfit,beta);

  nbPartiesOK := 0;
  for i := 1 to nbData do
    begin
      CalculeValeursEvaluationPartieNumero(i,ApresQuelCoup,scoreParfaitPourNoir,vecteurEvaluationPourNoir,partieOK,position);
      if partieOK then
        begin
          if (i mod 1000) = 0 then WritelnNumDansRapport('',i);

          inc(nbPartiesOK);
          TransformeEnregistrementEvaluationEnVecteur(vecteurEvaluationPourNoir,ma,afunc);
          ym := 320.0*(scoreParfaitPourNoir-32);  { -6400.0 ... 6400.0 }

		      if (mfit < ma) then
		        for j := 1 to ma do
		          if not(coeffVariable.bool[j]) then ym := ym-a.vec[j]*afunc.vec[j];

        { sigma := sig[i]; }
          sigma := 1000.0;                 {on suppose que les sigma_i sont egaux a 1.0}
		      sig2i := 1.0/(sigma*sigma);
		      j := 0;
		      for l := 1 to ma do
		        if coeffVariable.bool[l] then
		          begin
		            wt := afunc.vec[l]*sig2i;
		            j := j+1;
		            k := 0;
		            for m := 1 to l do
		              if coeffVariable.bool[m] then
		                begin
		                  k := k+1;
		                  alpha.mat[j,k] := alpha.mat[j,k]+wt*afunc.vec[m];
		                end;
		            beta.vec[j] := beta.vec[j]+ym*wt;
		          end;
		    end;
    end;

  if mfit > 1 then
    for j := 2 to mfit do
      for k := 1 to j-1 do alpha.mat[k,j] := alpha.mat[j,k];

  WritelnDansRapport('alpha = ');
  WritelnMatriceReelsDansRapport(alpha,6);


  {on resoud [alpha].sol = beta par la methode decomposition LU}
  {covar est la matrice inverse de [alpha] }

  WritelnDansRapport('avant ResoudSystemeEquationsCarre');

  SystemeOK := ResoudSystemeEquationsCarre(alpha,beta,covar,sol);

  WritelnDansRapport('apres ResoudSystemeEquationsCarre');

  if not(SystemeOK) then
    begin
      WritelnDansRapport('Impossible de rŽsoudre les equations normales dans LinearFit !!');
      exit(LinearFit);
    end;

  WritelnDansRapport('covar = ');
  WritelnMatriceReelsDansRapport(covar,6);

  WritelnDansRapport('beta = ');
  WritelnVecteurReelsDansRapport(sol,6);



  j := 0;
  for l := 1 to ma do
    if coeffVariable.bool[l] then
      begin
        j := j+1;
        a.vec[l] := sol.vec[j];
      end;

  {evaluation du chi_2}
  chisquare := 0.0;
  for i := 1 to nbData do
    begin
      CalculeValeursEvaluationPartieNumero(i,ApresQuelCoup,scoreParfaitPourNoir,vecteurEvaluationPourNoir,partieOK,position);
      if partieOK then
        begin
          if (i mod 1000) = 0 then WritelnNumDansRapport('',i);

          TransformeEnregistrementEvaluationEnVecteur(vecteurEvaluationPourNoir,ma,afunc);
          ym := 320.0*(scoreParfaitPourNoir-32);   {-6400..6400}

          sum := 0.0;
          for j := 1 to ma do
             sum := sum+a.vec[j]*afunc.vec[j];

        { sigma := sig[i] }
          sigma := 1000.0;     {on suppose que les sigma_i sont egaux a 1.0}
          aux := (ym-sum)/sigma;
          chisquare := chisquare+aux*aux;
        end;
    end;
  if nbPartiesOK-mfit > 0
    then sigmaData := sqrt(chisquare/(nbPartiesOK-mfit))
    else sigmaData := 1.0;

  WritelnDansRapport('chi2 = '+ReelEnStringAvecDecimales(chisquare,8));
  WritelnDansRapport('sigmaData = '+ReelEnStringAvecDecimales(sigmaData,8));

  WritelnDansRapport('appel de covsrtÉ');

  covsrt(covar,ma,coeffVariable,mfit);

  WritelnDansRapport('sortie de covsrtÉ');

end;


procedure DoRegressionLineaireCoeffsCassio(ApresQuelCoup : SInt16);
var doitAjuster    : VecteurBooleens;
    multiplicateur : VecteurReels;
    variance       : VecteurReels;
    matCovariance  : MatriceReels;
    chi2           : RealType;
    sigma          : RealType;
    aux            : RealType;
    i              : SInt32;
begin
  doitAjuster.longueur                            := kLongueurEvaluationCassioRec;
  doitAjuster.bool[kNotePenalite]                 := true;
  doitAjuster.bool[kNoteBord]                     := false;
  doitAjuster.bool[kNoteCoin]                     := true;
  doitAjuster.bool[kNotePriseCoin]                := true;
  doitAjuster.bool[kNoteDefenseCoin]              := true;
  doitAjuster.bool[kNoteMinimisationAvant]        := true;
  doitAjuster.bool[kNoteMinimisationApres]        := false;
  doitAjuster.bool[kNoteCentre]                   := true;
  doitAjuster.bool[kNoteGrandCentre]              := true;
  doitAjuster.bool[kNoteFrontiere]                := true;
  doitAjuster.bool[kNoteEquivalentFrontiere]      := true;
  doitAjuster.bool[kNoteMobilite]                 := true;
  doitAjuster.bool[kNoteCaseX]                    := true;
  doitAjuster.bool[kNoteCaseXPlusCoin]            := true;
  doitAjuster.bool[kNoteCaseXEntreCasesC]         := true;
  doitAjuster.bool[kNoteTrouCaseC]                := true;
  doitAjuster.bool[kNoteOccupationTactique]       := false;
  doitAjuster.bool[kNoteWipeOut]                  := false;
  doitAjuster.bool[kNoteAleatoire]                := false;
  doitAjuster.bool[kNoteTrousDeTroisHorrible]     := true;
  doitAjuster.bool[kNoteLiberteSurCaseA]          := true;
  doitAjuster.bool[kNoteLiberteSurCaseB]          := true;
  doitAjuster.bool[kNoteBonsBordsDeCinq]          := false;
  doitAjuster.bool[kNoteTrousDeDeuxPerdantLaParite] := false;
  doitAjuster.bool[kNoteArnaqueSurBordDeCinq]     := true;
  doitAjuster.bool[kNoteValeurBlocsDeCoin]        := false;
  doitAjuster.bool[kNoteBordsOpposes]             := false;
  doitAjuster.bool[kNoteBordDeCinqTransformable]  := false;
  doitAjuster.bool[kNoteGameOver]                 := false;
  doitAjuster.bool[kNoteBordDeSixPlusQuatre]      := true;
  doitAjuster.bool[kNoteGrosseMasse]              := true;
  doitAjuster.bool[kNoteCaseXConsolidantBordDeSix] := false;


  multiplicateur.longueur                           := kLongueurEvaluationCassioRec;
  multiplicateur.vec[kNotePenalite]                 := 1.0;
  multiplicateur.vec[kNoteBord]                     := 1.0;
  multiplicateur.vec[kNoteCoin]                     := 1.0;
  multiplicateur.vec[kNotePriseCoin]                := 1.0;
  multiplicateur.vec[kNoteDefenseCoin]              := 1.0;
  multiplicateur.vec[kNoteMinimisationAvant]        := 1.0;
  multiplicateur.vec[kNoteMinimisationApres]        := 0.0;
  multiplicateur.vec[kNoteCentre]                   := 1.0;
  multiplicateur.vec[kNoteGrandCentre]              := 1.0;
  multiplicateur.vec[kNoteFrontiere]                := 1.0;
  multiplicateur.vec[kNoteEquivalentFrontiere]      := 1.0;
  multiplicateur.vec[kNoteMobilite]                 := 1.0;
  multiplicateur.vec[kNoteCaseX]                    := 1.0;
  multiplicateur.vec[kNoteCaseXPlusCoin]            := 1.0;
  multiplicateur.vec[kNoteCaseXEntreCasesC]         := 1.0;
  multiplicateur.vec[kNoteTrouCaseC]                := 1.0;
  multiplicateur.vec[kNoteOccupationTactique]       := 0.0;
  multiplicateur.vec[kNoteWipeOut]                  := 0.0;
  multiplicateur.vec[kNoteAleatoire]                := 0.0;
  multiplicateur.vec[kNoteTrousDeTroisHorrible]     := 1.0;
  multiplicateur.vec[kNoteLiberteSurCaseA]          := 1.0;
  multiplicateur.vec[kNoteLiberteSurCaseB]          := 1.0;
  multiplicateur.vec[kNoteBonsBordsDeCinq]          := 0.0;
  multiplicateur.vec[kNoteTrousDeDeuxPerdantLaParite] := 0.0;
  multiplicateur.vec[kNoteArnaqueSurBordDeCinq]     := 1.0;
  multiplicateur.vec[kNoteValeurBlocsDeCoin]        := 0.0;
  multiplicateur.vec[kNoteBordsOpposes]             := 0.0;
  multiplicateur.vec[kNoteBordDeCinqTransformable]  := 0.0;
  multiplicateur.vec[kNoteGameOver]                 := 0.0;
  multiplicateur.vec[kNoteBordDeSixPlusQuatre]      := 1.0;
  multiplicateur.vec[kNoteGrosseMasse]              := 1.0;
  multiplicateur.vec[kNoteCaseXConsolidantBordDeSix] := 0.0;

  SetVecteurNul(kLongueurEvaluationCassioRec,variance);

  WritelnDansRapport('appel de linearFit');
  Superviseur(ApresQuelCoup);
  linearFit(nbPartiesActives,ApresQuelCoup,multiplicateur,doitAjuster,kLongueurEvaluationCassioRec,matCovariance,chi2,sigma);
  WritelnDansRapport('sortie de LinearFit');

  for i := 1 to variance.longueur do
    if matCovariance.mat[i,i] >= 0.0
      then variance.vec[i] := sqrt(matCovariance.mat[i,i])
      else variance.vec[i] := -1.0;  {petit probleme !}

  WritelnDansRapport('');
  WritelnDansRapport('avant Normalisation du coeff des bords :');
  WritelnVecteurEvaluationDansRapport('multiplicateur',multiplicateur,5);
  WritelnVecteurEvaluationDansRapport('variance',variance,5);


  if (multiplicateur.vec[kNoteBord] <> 0.0) and (multiplicateur.vec[kNoteBord] <> 1.0) then
    begin
      aux := multiplicateur.vec[kNoteBord];
      for i := 1 to multiplicateur.longueur do
        begin
          multiplicateur.vec[i] := multiplicateur.vec[i]/aux;
          variance.vec[i] := variance.vec[i]/aux;
        end;
      WritelnDansRapport('');
      WritelnDansRapport('apres Normalisation du coeff des bords');
      WritelnVecteurEvaluationDansRapport('multiplicateur',multiplicateur,5);
      WritelnVecteurEvaluationDansRapport('variance',variance,5);
    end;

end;


end.
