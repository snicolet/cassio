UNIT UnitSolve;



INTERFACE







 USES UnitDefCassio;



{ des fonctions de calcul qui ne changent pas l'othellier de Cassio }
function NbCoupsGagnantsOuNuls(whichPosition : PositionEtTraitRec; var valeurOptimale : SInt32; borneNbCoupsGagnants : SInt32) : SInt32;
function ScoreWLDPositionEtTrait(whichPosition : PositionEtTraitRec; var solveResults : MakeEndgameSearchResultRec) : SInt32;
function ScoreParfaitFinalePositionEtTrait(whichPosition : PositionEtTraitRec; endgameSolveFlags : SInt32; var solveResults : MakeEndgameSearchResultRec) : SInt32;
function ScoreParfaitFinaleWithSearchParams(var params : MakeEndgameSearchParamRec; endgameSolveFlags : SInt32) : SInt32;


{ des fonctions de calcul qui changent l'othellier }
function DoPlaquerPositionAndMakeEndgameSolve(var positionEtTrait : PositionEtTraitRec; endgameSolveFlags : SInt32; var solveResults : MakeEndgameSearchResultRec) : SInt32;
function CalculeLigneOptimalePositionEtTrait(whichPosition : PositionEtTraitRec; endgameSolveFlags : SInt32; var score : SInt32) : String255;


{ calcul de la ligne optimale permettant de completer une partie; pour l'instant, cette implementation change l'othellier }
function PeutCompleterPartieAvecLigneOptimale(var partieEnAlpha : String255) : boolean;


{ manipulations de SearchParamRec et des MakeEndgameSearchResultRec }
procedure ViderSearchParams(var params : MakeEndgameSearchParamRec);
procedure CopySearchParams(const source : MakeEndgameSearchParamRec; var dest : MakeEndgameSearchParamRec);
function CheckEndgameSearchParams(var params : MakeEndgameSearchParamRec) : boolean;
procedure ViderSearchResults(var results : MakeEndgameSearchResultRec);
procedure CopySearchResults(const source : MakeEndgameSearchResultRec; var dest : MakeEndgameSearchResultRec);


{ ecriture d'un MakeEndgameSearchResultRec dans le rapport }
procedure WritelnEndgameSearchParamsDansRapport(var params : MakeEndgameSearchParamRec);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, ToolUtils, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitGestionDuTemps, UnitStrategie, UnitRapport, UnitSuperviseur, UnitUtilitairesFinale, UnitScannerUtils, UnitZoo
    , UnitScannerOthellistique, UnitZoo, UnitSetUp, UnitFinaleFast, UnitPhasesPartie, UnitAffichageReflexion, UnitUtilitaires, UnitArbreDeJeuCourant
    , MyMathUtils, UnitPositionEtTrait, UnitAffichagePlateau, UnitJeu ;
{$ELSEC}
    ;
    {$I prelink/Solve.lk}
{$ENDC}


{END_USE_CLAUSE}







{renvoie 0 (si la position est perdante) ou le nombre de coups optimaux si la
 position est nulle ou gagnante, ainsi que la valeur de la position (0 ou +1)}
function NbCoupsGagnantsOuNuls(whichPosition : PositionEtTraitRec; var valeurOptimale : SInt32; borneNbCoupsGagnants : SInt32) : SInt32;
var compteurCoupsOptimaux : SInt32;
    listeCasesVides : listeVides;
    nbVides,nbCoups,i : SInt32;
    positionFils : PositionEtTraitRec;
    bestScoreSoFar,scoreWLD : SInt32;
    solveResults : MakeEndgameSearchResultRec;
begin
  compteurCoupsOptimaux := 0;
  bestScoreSoFar := -1;
  valeurOptimale := -1;

  if GetTraitOfPosition(whichPosition) <> pionVide then
    begin
		  nbVides := EtablitListeCasesVides(whichPosition.position,listeCasesVides);
		  nbCoups := TrierSelonDivergenceSansMilieu(whichPosition.position,GetTraitOfPosition(whichPosition),nbVides,listeCasesVides,listeCasesVides);

		  for i := 1 to nbCoups do
		    begin
		      positionFils := whichPosition;

		      if UpdatePositionEtTrait(positionFils,listeCasesVides[i]) then
		        begin
		          if GetTraitOfPosition(positionFils) = pionVide
				        then
				          begin
				            scoreWLD := Signe(NbPionsDeCetteCouleurDansPosition(GetTraitOfPosition(whichPosition),positionFils.position) - NbPionsDeCetteCouleurDansPosition(-GetTraitOfPosition(whichPosition),positionFils.position));
				          end
				        else
				          begin
				            if GetTraitOfPosition(whichPosition) <> GetTraitOfPosition(positionFils)
				              then scoreWLD := -ScoreWLDPositionEtTrait(positionFils,solveResults)
				              else scoreWLD :=  ScoreWLDPositionEtTrait(positionFils,solveResults);
				          end;

				      if scoreWLD > bestScoreSoFar then
		            begin
		              bestScoreSoFar := scoreWLD;
		              compteurCoupsOptimaux := 0;
		            end;
		          if scoreWLD = bestScoreSoFar then inc(compteurCoupsOptimaux);

		          if (bestScoreSoFar = +1) & (compteurCoupsOptimaux >= borneNbCoupsGagnants) then Leave;
		        end;
        end;

    end;

  valeurOptimale := bestScoreSoFar;
  if valeurOptimale < 0
    then NbCoupsGagnantsOuNuls := 0
    else NbCoupsGagnantsOuNuls := compteurCoupsOptimaux;
end;




{renvoie -1 si la position est perdante, 0 si nulle et +1 si gagnante}
function ScoreWLDPositionEtTrait(whichPosition : PositionEtTraitRec; var solveResults : MakeEndgameSearchResultRec) : SInt32;
var nbBlanc,nbNoir,prof : SInt32;
    numeroDuCoup : SInt32;
    oldInterruption : SInt16;
    gagnant : boolean;
    searchParam : MakeEndgameSearchParamRec;
begin

  if GetTraitOfPosition(whichPosition) = pionVide then
    begin
      SysBeep(0);
      WritelnDansRapport('ERREUR : GetTraitOfPosition(whichPosition) = pionVide dans ScoreWLDPositionEtTrait !!');
      exit(ScoreWLDPositionEtTrait);
    end;

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  couleurMacintosh := GetTraitOfPosition(whichPosition);
  HumCtreHum := false;
  nbBlanc := NbPionsDeCetteCouleurDansPosition(pionBlanc,whichPosition.position);
  nbNoir  := NbPionsDeCetteCouleurDansPosition(pionNoir,whichPosition.position);
  prof := 64 - nbBlanc - nbNoir;
  numeroDuCoup := nbNoir+nbBlanc-4;
  vaDepasserTemps := false;
  RefleSurTempsJoueur := false;
  Superviseur(numeroDuCoup);
  AjusteSleep;

  if not(calculPrepHeurisFait) then Initialise_table_heuristique(whichPosition.position,false);

  EnleveCetteInterruption(GetCurrentInterruption);


  with searchParam do
    begin
       inTypeCalculFinale                   := ReflGagnant;
       inCouleurFinale                      := GetTraitOfPosition(whichPosition);
       inProfondeurFinale                   := prof;
       inNbreBlancsFinale                   := nbBlanc;
       inNbreNoirsFinale                    := nbNoir;
       inAlphaFinale                        := -64;
       inBetaFinale                         := 64;
       inMuMinimumFinale                    := 0;
       inMuMaximumFinale                    := kDeltaFinaleInfini;
       inPrecisionFinale                    := 100;
       inPrioriteFinale                     := 0;
       inGameTreeNodeFinale                 := NIL;
       inPositionPourFinale                 := whichPosition.position;
       inMessageHandleFinale                := NIL;
       inCommentairesDansRapportFinale      := false;
       inMettreLeScoreDansLaCourbeFinale    := false;
       inMettreLaSuiteDansLaPartie          := false;
       inDoitAbsolumentRamenerLaSuiteFinale := true;
       inDoitAbsolumentRamenerUnScoreFinale := true;
       SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
       ViderSearchResults(outResult);
    end;

  gagnant := MakeEndgameSearch(searchParam);

  CopySearchResults(searchParam.outResult, solveResults);


  LanceInterruption(oldInterruption,'ScoreWLDPositionEtTrait');

  ScoreWLDPositionEtTrait := Signe(solveResults.outScoreFinale);
end;




function ScoreParfaitFinaleWithSearchParams(var params : MakeEndgameSearchParamRec; endgameSolveFlags : SInt32) : SInt32;
var nbNoirs,nbBlancs,empties,score : SInt32;
    typeFinaleDemandee : SInt16;
    oldInterruption : SInt16;
    gagnant : boolean;
    onlyWLD : boolean;
    ecrireInfosTechniquesDansRapport : boolean;
    toujoursRamenerLaSuite : boolean;
    ecrirePositionDansRapport : boolean;
    calculateInBackground : boolean;
    calculateInForeground : boolean;
    passDirectlyToEngine : boolean;
    whichPosition : PositionEtTraitRec;
    numeroDuCoup : SInt32;
    couleurArrivee : SInt32;
    localParams : MakeEndgameSearchParamRec;
    solveResults : MakeEndgameSearchResultRec;
    foo : SInt16;
begin

  with params do
    begin
      if (inProfondeurFinale <= 0) |
         (DoitPasserPlatSeulement(pionBlanc, inPositionPourFinale) & DoitPasserPlatSeulement(pionNoir, inPositionPourFinale))
          then
        begin
          ViderSearchResults(outResult);

          case inCouleurFinale of
            pionBlanc : score := NbPionsDeCetteCouleurDansPosition(pionBlanc,inPositionPourFinale) - NbPionsDeCetteCouleurDansPosition(pionNoir,inPositionPourFinale);
            pionNoir  : score := NbPionsDeCetteCouleurDansPosition(pionNoir,inPositionPourFinale) - NbPionsDeCetteCouleurDansPosition(pionBlanc,inPositionPourFinale);
            otherwise   score := -1000;
          end; {case}

          // donner les cases vides au vainqueur
          if (score >= -64) & (score <= 64) then
            begin
              if (score > 0) then score := score + NbCasesVidesDansPosition(inPositionPourFinale) else
              if (score < 0) then score := score - NbCasesVidesDansPosition(inPositionPourFinale);
            end;

          with outResult do
            begin
              outTimeTakenFinale := 0.0;
              outScoreFinale     := score;
            end;

          ScoreParfaitFinaleWithSearchParams := score;
          exit(ScoreParfaitFinaleWithSearchParams);
        end;
    end;


  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  score := -1000;

  if CassioEstEnTrainDeReflechir
    then
      begin
        WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir = true)  dans ScoreParfaitFinaleWithSearchParams !!');
      end
    else
      begin

        CopySearchParams(params,localParams);



        onlyWLD                          := BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0;
        ecrireInfosTechniquesDansRapport := BitAnd(endgameSolveFlags,kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0;
        toujoursRamenerLaSuite           := BitAnd(endgameSolveFlags,kEndgameSolveToujoursRamenerLaSuite) <> 0;
        ecrirePositionDansRapport        := BitAnd(endgameSolveFlags,kEndgameSolveEcrirePositionDansRapport) <> 0;
        calculateInBackground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInBackground) <> 0;
        calculateInForeground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInForeground) <> 0;
        passDirectlyToEngine             := BitAnd(endgameSolveFlags,kEndgameSolvePassDirectlyToEngine) <> 0;


        whichPosition := MakePositionEtTrait(params.inPositionPourFinale,params.inCouleurFinale);
        couleurArrivee := params.inCouleurFinale;



        if calculateInForeground
          then
            begin

              if not(calculateInForeground) then
                endgameSolveFlags := endgameSolveFlags + kEndgameSolveCalculateInForeground;

              if calculateInBackground then
                endgameSolveFlags := endgameSolveFlags - kEndgameSolveCalculateInBackground;

              { on lance la finale, mais en plaquant la position dans la fenetre othellier }

              if GetTraitOfPosition(whichPosition) = couleurArrivee
                then score :=  DoPlaquerPositionAndMakeEndgameSolve(whichPosition, endgameSolveFlags, solveResults)
                else score := -DoPlaquerPositionAndMakeEndgameSolve(whichPosition, endgameSolveFlags, solveResults);

              if (interruptionReflexion <> pasdinterruption) then score := -1000;
              solveResults.outScoreFinale := score;

              CopySearchResults(solveResults, params.outResult);


            end
          else
            begin

              nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,whichPosition.position);
        		  nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,whichPosition.position);
        		  RefleSurTempsJoueur := false;
        		  vaDepasserTemps := false;
              empties := 64 - nbBlancs - nbNoirs;
              numeroDuCoup := nbNoirs + nbBlancs - 4;
              vaDepasserTemps := false;
              RefleSurTempsJoueur := false;
              Superviseur(numeroDuCoup);
              Initialise_table_heuristique(whichPosition.position,false);
              AjusteSleep;


        		  InfosTechniquesDansRapport := ecrireInfosTechniquesDansRapport;

        		  if ecrirePositionDansRapport then
        		    begin
        		      WritelnDansRapport('');
        		      WritelnDansRapport('Appel de ScoreParfaitFinaleWithSearchParams pour cette position : ');
        		      WritelnPositionEtTraitDansRapport(whichPosition.position,GetTraitOfPosition(whichPosition));
        		    end;

              if passDirectlyToEngine
                then
                  typeFinaleDemandee := ReflFinalePasseeDirectementAuMoteur
                else
            		  if onlyWLD
            		    then typeFinaleDemandee := ReflGagnant
            		    else typeFinaleDemandee := ReflParfait;

        		  EnleveCetteInterruption(GetCurrentInterruption);
        		  dernierTick := TickCount-tempsDesJoueurs[AQuiDeJouer].tick;
        		  LanceChrono;
        		  tempsPrevu := 10;
        		  tempsAlloue := minutes10000000;


              with localParams do
                begin
                  inTypeCalculFinale                   := typeFinaleDemandee;
                  inCouleurFinale                      := GetTraitOfPosition(whichPosition);
                  inCommentairesDansRapportFinale      := ecrireInfosTechniquesDansRapport;
                  inDoitAbsolumentRamenerLaSuiteFinale := toujoursRamenerLaSuite;
                  inDoitAbsolumentRamenerUnScoreFinale := true;
                end;


              // On lance le calcul par Cassio !
              gagnant := MakeEndgameSearch(localParams);


              CopySearchResults(localParams.outResult, solveResults);

              with solveResults do
                begin

                  score := outScoreFinale;

                  if (interruptionReflexion = pasdinterruption) then
                    if (GetTraitOfPosition(whichPosition) = couleurArrivee)
                      then score :=  score
                      else score := -score;

                  if (interruptionReflexion <> pasdinterruption) then score := -1000;

                  outScoreFinale := score;

                  if (LENGTH_OF_STRING(outLineFinale) <= 0) & (outBestMoveFinale >= 11) & (outBestMoveFinale <= 88) & (whichPosition.position[outBestMoveFinale] = pionVide)
                    then outLineFinale := CoupEnStringEnMajuscules(outBestMoveFinale);

                  if (LENGTH_OF_STRING(outLineFinale) >= 2)
                    then outBestMoveFinale  := ScannerStringPourTrouverCoup(1,outLineFinale,foo)
                    else outBestMoveFinale  := 44;

                  if (LENGTH_OF_STRING(outLineFinale) >= 4)
                    then outBestDefenseFinale  := ScannerStringPourTrouverCoup(3,outLineFinale,foo)
                    else outBestDefenseFinale  := 44;

                end;


              CopySearchResults(solveResults, params.outResult);



              if ecrirePositionDansRapport then
                begin
                  if (interruptionReflexion <> pasdinterruption)
                    then EcritTypeInterruptionDansRapport(interruptionReflexion);
                  WritelnNumDansRapport('Sortie de ScoreParfaitFinaleWithSearchParams, score = ', score);
                end;

            end;
      end;

  LanceInterruption(oldInterruption,'ScoreParfaitFinaleWithSearchParams');

  ScoreParfaitFinaleWithSearchParams := score;

end;



function ScoreParfaitFinalePositionEtTrait(whichPosition : PositionEtTraitRec; endgameSolveFlags : SInt32; var solveResults : MakeEndgameSearchResultRec) : SInt32;
var nbNoirs,nbBlancs,empties,score : SInt32;
    typeFinaleDemandee : SInt16;
    oldInterruption : SInt16;
    gagnant : boolean;
    onlyWLD : boolean;
    ecrireInfosTechniquesDansRapport : boolean;
    toujoursRamenerLaSuite : boolean;
    ecrirePositionDansRapport : boolean;
    calculateInBackground : boolean;
    calculateInForeground : boolean;
    searchParam : MakeEndgameSearchParamRec;
    numeroDuCoup : SInt32;
begin


  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  score := -1000;

  if CassioEstEnTrainDeReflechir
    then
      begin
        WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir = true)  dans ScoreParfaitFinalePositionEtTrait !!');
      end
    else
      begin

        onlyWLD                          := BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0;
        ecrireInfosTechniquesDansRapport := BitAnd(endgameSolveFlags,kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0;
        toujoursRamenerLaSuite           := BitAnd(endgameSolveFlags,kEndgameSolveToujoursRamenerLaSuite) <> 0;
        ecrirePositionDansRapport        := BitAnd(endgameSolveFlags,kEndgameSolveEcrirePositionDansRapport) <> 0;
        calculateInBackground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInBackground) <> 0;
        calculateInForeground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInForeground) <> 0;

        if calculateInForeground
          then
            begin

              if not(calculateInForeground) then
                endgameSolveFlags := endgameSolveFlags + kEndgameSolveCalculateInForeground;

              if calculateInBackground then
                endgameSolveFlags := endgameSolveFlags - kEndgameSolveCalculateInBackground;

              { on lance la finale, mais en plaquant la position dans la fenetre othellier }
              score := DoPlaquerPositionAndMakeEndgameSolve(whichPosition, endgameSolveFlags, solveResults);

            end
          else
            begin

              nbNoirs := NbPionsDeCetteCouleurDansPosition(pionNoir,whichPosition.position);
        		  nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,whichPosition.position);
        		  RefleSurTempsJoueur := false;
        		  vaDepasserTemps := false;
              empties := 64 - nbBlancs - nbNoirs;
              numeroDuCoup := nbNoirs + nbBlancs - 4;
              vaDepasserTemps := false;
              RefleSurTempsJoueur := false;
              Superviseur(numeroDuCoup);
              Initialise_table_heuristique(whichPosition.position,false);
              AjusteSleep;


        		  InfosTechniquesDansRapport := ecrireInfosTechniquesDansRapport;

        		  if ecrirePositionDansRapport then
        		    begin
        		      WritelnDansRapport('');
        		      WritelnDansRapport('Appel de ScoreParfaitFinalePositionEtTrait pour cette position : ');
        		      WritelnPositionEtTraitDansRapport(whichPosition.position,GetTraitOfPosition(whichPosition));
        		    end;

        		  if onlyWLD
        		    then typeFinaleDemandee := ReflGagnant
        		    else typeFinaleDemandee := ReflParfait;

        		  EnleveCetteInterruption(GetCurrentInterruption);
        		  dernierTick := TickCount-tempsDesJoueurs[AQuiDeJouer].tick;
        		  LanceChrono;
        		  tempsPrevu := 10;
        		  tempsAlloue := minutes10000000;


              with searchParam do
                begin
                   inTypeCalculFinale                   := typeFinaleDemandee;
                   inCouleurFinale                      := GetTraitOfPosition(whichPosition);
                   inProfondeurFinale                   := empties;
                   inNbreBlancsFinale                   := nbBlancs;
                   inNbreNoirsFinale                    := nbNoirs;
                   inAlphaFinale                        := -64;
                   inBetaFinale                         := 64;
                   inMuMinimumFinale                    := 0;
                   inMuMaximumFinale                    := kDeltaFinaleInfini;
                   inPrecisionFinale                    := 100;
                   inPrioriteFinale                     := 0;
                   inGameTreeNodeFinale                 := NIL;
                   inPositionPourFinale                 := whichPosition.position;
                   inMessageHandleFinale                := NIL;
                   inCommentairesDansRapportFinale      := ecrireInfosTechniquesDansRapport;
                   inMettreLeScoreDansLaCourbeFinale    := false;
                   inMettreLaSuiteDansLaPartie          := false;
                   inDoitAbsolumentRamenerLaSuiteFinale := toujoursRamenerLaSuite;
                   inDoitAbsolumentRamenerUnScoreFinale := true;
                   SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
                   ViderSearchResults(outResult);
                end;

              gagnant := MakeEndgameSearch(searchParam);

              CopySearchResults(searchParam.outResult, solveResults);


              score  := solveResults.outScoreFinale;


              if (interruptionReflexion <> pasdinterruption) then score := -1000;

              if ecrirePositionDansRapport then
                begin
                  if (interruptionReflexion <> pasdinterruption)
                    then EcritTypeInterruptionDansRapport(interruptionReflexion);
                  WritelnNumDansRapport('Sortie de ScoreParfaitFinalePositionEtTrait, score = ', score);
                end;

            end;
      end;

  LanceInterruption(oldInterruption,'ScoreParfaitFinalePositionEtTrait');

  ScoreParfaitFinalePositionEtTrait := score;

end;


{ plaque la position dans l'ohellier de gauche et lance un calcul de final;
  renvoie le score, ou -1000 en cas d'interruption du calcul }
function DoPlaquerPositionAndMakeEndgameSolve(var positionEtTrait : PositionEtTraitRec; endgameSolveFlags : SInt32; var solveResults : MakeEndgameSearchResultRec) : SInt32;
var score : SInt32;
    typeFinaleDemandee : SInt16;
    oldInterruption : SInt16;
    onlyWLD : boolean;
    ecrireInfosTechniquesDansRapport : boolean;
    toujoursRamenerLaSuite : boolean;
    ecrirePositionDansRapport : boolean;
    calculateInBackground : boolean;
    calculateInForeground : boolean;
begin


  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  score := -1000;

  if CassioEstEnTrainDeReflechir
    then
      begin
        WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir = true)  dans DoPlaquerPositionAndMakeEndgameSolve !!');
      end
    else
      begin

        onlyWLD                          := BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0;
        ecrireInfosTechniquesDansRapport := BitAnd(endgameSolveFlags,kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0;
        toujoursRamenerLaSuite           := BitAnd(endgameSolveFlags,kEndgameSolveToujoursRamenerLaSuite) <> 0;
        ecrirePositionDansRapport        := BitAnd(endgameSolveFlags,kEndgameSolveEcrirePositionDansRapport) <> 0;
        calculateInBackground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInBackground) <> 0;
        calculateInForeground            := BitAnd(endgameSolveFlags,kEndgameSolveCalculateInForeground) <> 0;

        if calculateInBackground
          then
            begin

              if not(calculateInBackground) then
                endgameSolveFlags := endgameSolveFlags + kEndgameSolveCalculateInBackground;

              if calculateInForeground then
                endgameSolveFlags := endgameSolveFlags - kEndgameSolveCalculateInForeground;

              { on lance la finale, mais en background }
              score := ScoreParfaitFinalePositionEtTrait(positionEtTrait, endgameSolveFlags, solveResults);

            end
          else
            begin

              { on plaque la position et on affiche un peu tout correctement }

              if HumCtreHum then DoChangeHumCtreHum;
        		  PlaquerPosition(positionEtTrait.position,GetTraitOfPosition(positionEtTrait),kRedessineEcran);
        		  DoFinaleOptimale(false);
              SetGameMode(typeFinaleDemandee);
              couleurMacintosh := GetTraitOfPosition(positionEtTrait);
        		  EnleveCetteInterruption(GetCurrentInterruption);
        		  ReinitilaliseInfosAffichageReflexion;
        		  EffaceReflexion(true);
        		  RefleSurTempsJoueur := false;
        		  if not(RefleSurTempsJoueur) & (AQuiDeJouer = couleurMacintosh) then EcritJeReflechis(AQuiDeJouer);
        		  EnleveCetteInterruption(GetCurrentInterruption);

        		  { maintenant que l'on a plaqué la position, on peut calculer la finale en background}

              if calculateInForeground then
                endgameSolveFlags := endgameSolveFlags - kEndgameSolveCalculateInForeground;

              if not(calculateInBackground) then
                endgameSolveFlags := endgameSolveFlags + kEndgameSolveCalculateInBackground;

              { on lance la finale ! }
              score := ScoreParfaitFinalePositionEtTrait(positionEtTrait, endgameSolveFlags, solveResults);


           end;
      end;

  LanceInterruption(oldInterruption,'DoPlaquerPositionAndMakeEndgameSolve');

  DoPlaquerPositionAndMakeEndgameSolve := score;
end;



function CalculeLigneOptimalePositionEtTrait(whichPosition : PositionEtTraitRec; endgameSolveFlags : SInt32; var score : SInt32) : String255;
var ligneOptimale : String255;
    valeurDeLaPosition : SInt32;
    solveResults : MakeEndgameSearchResultRec;
    oldInterruption : SInt16;
begin
  ligneOptimale := '';

  if CassioEstEnTrainDeReflechir
    then
      begin
        WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir = true)  dans CalculeLigneOptimalePositionEtTrait !!');
      end
    else
      begin

        oldInterruption := GetCurrentInterruption;
        EnleveCetteInterruption(oldInterruption);


        { On force le calcul en mode finale parfaite }
        if BitAnd(endgameSolveFlags,kEndgameSolveOnlyWLD) <> 0 then
          endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;

        { Lancer la finale ! }
        valeurDeLaPosition := DoPlaquerPositionAndMakeEndgameSolve(whichPosition, endgameSolveFlags, solveResults);


        { Si tout est bon, on retourne le résultat }
        if (valeurDeLaPosition >= -64) & (valeurDeLaPosition <= 64) & (interruptionReflexion = pasdinterruption) then
          begin
            score := valeurDeLaPosition;
            ligneOptimale := MeilleureSuiteInfosEnChaine(0,false,false,true,false,0);
          end;


        LanceInterruption(oldInterruption,'CalculeLigneOptimalePositionEtTrait');

      end;


  CalculeLigneOptimalePositionEtTrait := ligneOptimale;
end;





function PeutCompleterPartieAvecLigneOptimale(var partieEnAlpha : String255) : boolean;
var positionACompleter : PositionEtTraitRec;
    scoreParfait : SInt32;
    erreur : SInt32;
    longueurPartie : SInt32;
    theGame : String255;
    completion : String255;
    nbNoirs,nbBlancs : SInt32;
    oldInterruption : SInt16;
begin
  PeutCompleterPartieAvecLigneOptimale := false;

  theGame := partieEnAlpha;
  { Compressons la partie }
  if EstUnePartieOthello(theGame,true) then
    begin
      { de maniere à pouvoir calculer son nombre de coup }
      longueurPartie := LENGTH_OF_STRING(theGame) div 2;

      { si c'est une partie non terminee... }
      if (longueurPartie < 60) & not(EstUnePartieOthelloTerminee(theGame,false,nbNoirs,nbBlancs)) then
        begin
          { ...on calcule la derniere position atteinte... }
          positionACompleter := PositionEtTraitAfterMoveNumberAlpha(theGame,longueurPartie,erreur);
          if (erreur = kPasErreur) then
            begin

              oldInterruption := GetCurrentInterruption;
              EnleveCetteInterruption(oldInterruption);

              { ...et on essaye de calculer la meilleure suite depuis cette position intermediaire }
              completion := CalculeLigneOptimalePositionEtTrait(positionACompleter,kEndgameSolveToujoursRamenerLaSuite
                                                                                   {+ kEndgameSolveEcrirePositionDansRapport}
                                                                                   {+ kEndgameSolveEcrireInfosTechniquesDansRapport},
                                                                                   scoreParfait);
              if (completion <> '') then
                begin
                  theGame := theGame + completion;
                  if EstUnePartieOthelloTerminee(theGame,false,nbNoirs,nbBlancs) then
                    begin
                      PeutCompleterPartieAvecLigneOptimale := true;
                      partieEnAlpha := theGame;
                    end;
                end;

              LanceInterruption(oldInterruption,'PeutCompleterPartieAvecLigneOptimale');

            end;
        end;
    end;
end;



procedure ViderSearchResults(var results : MakeEndgameSearchResultRec);
begin
  with results do
    begin
      outBestMoveFinale          := k_ZOO_NOT_INITIALIZED_VALUE;
      outBestDefenseFinale       := k_ZOO_NOT_INITIALIZED_VALUE;
      outScoreFinale             := k_ZOO_NOT_INITIALIZED_VALUE;
      outTimeTakenFinale         := -1.0;
      outDernierMuVariant        := -1;
      outLineFinale              := '';
    end;
end;


procedure CopySearchResults(const source : MakeEndgameSearchResultRec; var dest : MakeEndgameSearchResultRec);
begin
  with dest do
    begin
      outBestMoveFinale          := source.outBestMoveFinale;
      outBestDefenseFinale       := source.outBestDefenseFinale;
      outScoreFinale             := source.outScoreFinale;
      outTimeTakenFinale         := source.outTimeTakenFinale;
      outDernierMuVariant        := source.outDernierMuVariant;
      outLineFinale              := source.outLineFinale;
    end;
end;


procedure ViderSearchParams(var params : MakeEndgameSearchParamRec);
begin
  with params do
    begin
      inTypeCalculFinale                   := 0;
      inCouleurFinale                      := 0;
      inProfondeurFinale                   := 0;
      inNbreBlancsFinale                   := 0;
      inNbreNoirsFinale                    := 0;
      inAlphaFinale                        := 0;
      inBetaFinale                         := 0;
      inMuMinimumFinale                    := 0;
      inMuMaximumFinale                    := 0;
      inPrecisionFinale                    := 0;
      inPrioriteFinale                     := 0;
      inGameTreeNodeFinale                 := NIL;
      inPositionPourFinale                 := JeuCourant;
      inMessageHandleFinale                := NIL;
      inCommentairesDansRapportFinale      := false;
      inMettreLeScoreDansLaCourbeFinale    := false;
      inMettreLaSuiteDansLaPartie          := false;
      inDoitAbsolumentRamenerLaSuiteFinale := false;
      inDoitAbsolumentRamenerUnScoreFinale := false;
      SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);

      ViderSearchResults(outResult);

    end;
end;


procedure CopySearchParams(const source : MakeEndgameSearchParamRec; var dest : MakeEndgameSearchParamRec);
begin
  with dest do
    begin
      inTypeCalculFinale                   := source.inTypeCalculFinale ;
      inCouleurFinale                      := source.inCouleurFinale ;
      inProfondeurFinale                   := source.inProfondeurFinale ;
      inNbreBlancsFinale                   := source.inNbreBlancsFinale ;
      inNbreNoirsFinale                    := source.inNbreNoirsFinale ;
      inAlphaFinale                        := source.inAlphaFinale ;
      inBetaFinale                         := source.inBetaFinale ;
      inMuMinimumFinale                    := source.inMuMinimumFinale ;
      inMuMaximumFinale                    := source.inMuMaximumFinale ;
      inPrecisionFinale                    := source.inPrecisionFinale ;
      inPrioriteFinale                     := source.inPrioriteFinale ;
      inGameTreeNodeFinale                 := source.inGameTreeNodeFinale ;
      inPositionPourFinale                 := source.inPositionPourFinale ;
      inMessageHandleFinale                := source.inMessageHandleFinale ;
      inCommentairesDansRapportFinale      := source.inCommentairesDansRapportFinale ;
      inMettreLeScoreDansLaCourbeFinale    := source.inMettreLeScoreDansLaCourbeFinale ;
      inMettreLaSuiteDansLaPartie          := source.inMettreLaSuiteDansLaPartie ;
      inDoitAbsolumentRamenerLaSuiteFinale := source.inDoitAbsolumentRamenerLaSuiteFinale ;
      inDoitAbsolumentRamenerUnScoreFinale := source.inDoitAbsolumentRamenerUnScoreFinale ;
      inHashValue                          := source.inHashValue;

      CopySearchResults(source.outResult, dest.outResult);

    end;
end;


function CheckEndgameSearchParams(var params : MakeEndgameSearchParamRec) : boolean;
var correct : boolean;
begin
  with params do
    begin

      correct :=     (inAlphaFinale < inBetaFinale) &            // pas de blague sur les bornes
                     (inProfondeurFinale <= 60) &                // pas plus de 60 cases vides, hein
                     (inMuMinimumFinale <= inMuMaximumFinale) &
                     (inPrioriteFinale >= 0) &
                     (inNbreNoirsFinale >= 0) &
                     (inNbreNoirsFinale <= 64) &
                     (inNbreBlancsFinale >= 0) &
                     (inNbreBlancsFinale <= 64) &
                     ((inCouleurFinale = pionNoir) | (inCouleurFinale = pionBlanc)) &
                     ((inTypeCalculFinale = ReflGagnant) | (inTypeCalculFinale = ReflParfait) | (inTypeCalculFinale = ReflMilieu));


      CheckEndgameSearchParams := correct;

    end;
end;


procedure WritelnEndgameSearchParamsDansRapport(var params : MakeEndgameSearchParamRec);
var s : String255;
begin
  s := '';

  EncoderSearchParamsPourURL(params, s, 'WritelnEndgameSearchParamsDansRapport');
  WritelnDansRapport(s);
end;



END.






































