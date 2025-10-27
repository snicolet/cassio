UNIT UnitTestZoo;


INTERFACE


USES UnitDefCassio;


{ flag indiquant si Cassio est en train de faire un benchmark de milieu }
function CassioEstEnBenchmarkDeMilieu : boolean;
procedure SetCassioEstEnBenchmarkDeMilieu(flag : boolean);


{ fonctions elementaires pour tester le zoo }
procedure TesterUnitZoo(whichPosition : PositionEtTraitRec);
procedure TesterUnJobDuZooEnLocal(s : String255);
procedure TesterUnCalculDeFinale(var params : MakeEndgameSearchParamRec);
procedure TesterUnCalculDeMilieu(var params : MakeEndgameSearchParamRec);
procedure TesterDesRequetesAuZoo(var searchParams : MakeEndgameSearchParamRec);
procedure TesterNoteDeCettePositionDeMilieu(var position : plateauOthello; var jou : plBool; var fr : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nbPosEvaluees : SInt32);


{ benchamrk de milieu dans le menu Programmation }
procedure StressTestMilieuPourLeZoo;


{ Test avec la souris}
procedure DemarrerLeTestDuZooAvecLaSouris;
procedure EssayerEnvoyerPositionCouranteAuZooPourLeTester;


{ script de zoo }
function OuvrirFichierScriptZoo(nomCompletFichier : String255) : OSErr;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitZoo, UnitAffichageReflexion, UnitRapport, UnitRapportImplementation, UnitSolve, UnitZoo
    , UnitZooAvecArbre, UnitLongString, MyStrings, UnitFichiersTEXT, UnitPositionEtTrait, UnitMilieuDePartie
    , UnitGestionDuTemps, UnitJeu, MyMathUtils, UnitStringSet, SNEvents, UnitListe
    ;
{$ELSEC}
    ;
    {$I prelink/TestZoo.lk}
{$ENDC}


{END_USE_CLAUSE}






const gEOFPourZooFile : boolean = false;

const gCassioEstEnBenchmarkDeMilieu : boolean = false;

const gDateDebutDuTestDuZooAvecLaSouris : SInt32 = 0;


procedure StressTestMilieuPourLeZoo;
var lesCasesInterdites : SquareSet;
    partie60 : PackedThorGame;
    ouverturesDejaGenerees : StringSet;
    compteur, nbCoupsDemandes, nbPosEvaluees, ticks, temps : SInt32;
    vitesse : double;
begin

  if CassioEstEnBenchmarkDeMilieu
    then exit(StressTestMilieuPourLeZoo);

  SetCassioEstEnBenchmarkDeMilieu(true);


  WritelnDansRapport('Lancement du benchmark de milieu...');

  RandomizeTimer;

  nbCoupsDemandes := 35;
  lesCasesInterdites := [];
  ouverturesDejaGenerees := MakeEmptyStringSet;

  compteur := 0;
  nbPosEvaluees := 0;
  ticks := TickCount;

  repeat
    PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

    if (compteur mod 5) = 0
      then GenereOuvertureAleatoireEquilibree(nbCoupsDemandes,-20000,20000,lesCasesInterdites,partie60,ouverturesDejaGenerees)
      else
        if odd(compteur)
          then GenerePartieAleatoireDesquilibree(nbCoupsDemandes,pionNoir,lesCasesInterdites,partie60,ouverturesDejaGenerees)
          else GenerePartieAleatoireDesquilibree(nbCoupsDemandes,pionBlanc,lesCasesInterdites,partie60,ouverturesDejaGenerees);

    DisposeStringSet(ouverturesDejaGenerees);

    ForEachPositionInGameDo(partie60,TesterNoteDeCettePositionDeMilieu,nbPosEvaluees);

    inc(compteur);

    if (compteur mod 5) = 0  then
      begin
        WriteNumDansRapport('parties, evals = ',compteur);
        WriteNumDansRapport(', ',nbPosEvaluees);

        temps := TickCount - ticks;
        if temps <> 0
          then vitesse := 60.0 * nbPosEvaluees / temps
          else vitesse := 0.0;
        WritelnStringAndReelDansRapport('    =>  nbre positions par sec. = ',vitesse,6);
      end;

  until EscapeDansQueue or Quitter;

  if Quitter then Quitter := false;

  WriteNumDansRapport('parties, evals = ',compteur);
  WriteNumDansRapport(', ',nbPosEvaluees);

  temps := TickCount - ticks;
  if temps <> 0
    then vitesse := 60.0 * nbPosEvaluees / temps
    else vitesse := 0.0;
  WritelnStringAndReelDansRapport('    =>  nbre positions par sec. = ',vitesse,6);

  WritelnDansRapport('Fin du benchmark de milieu.');

  SetCassioEstEnBenchmarkDeMilieu(false);

end;



procedure TesterUnCalculDeFinale(var params : MakeEndgameSearchParamRec);
var score : SInt32;
    zooJob : ZooJobRec;
    affichage : boolean;
begin

  affichage := false;

  if affichage then
    begin
      WritelnDansRapport('');
      WriteTickOperationPourLeZooDansRapport;
      WritelnDansRapport('Test de la finale : ');
      ChangeFontFaceDansRapport(normal);
      WritelnPositionEtTraitDansRapport(params.inPositionPourFinale,params.inCouleurFinale);
      WritelnFenetreAlphaBetaDansRapport(params.inAlphaFinale,params.inBetaFinale);
      WritelnDansRapport('');
    end;


  EndgameSearchParamToZooJob(params,zooJob);

  VideMeilleureSuiteInfos;

  score := ScoreParfaitFinaleWithSearchParams(params, zooJob.endgameSolveFlags);

  if affichage then
    begin
      WritelnDansRapport('');
      WriteTickOperationPourLeZooDansRapport;
      WritelnNumDansRapport('score = ',score);
      ChangeFontFaceDansRapport(normal);
      WritelnDansRapport('');
    end;
end;



procedure TesterUnCalculDeMilieu(var params : MakeEndgameSearchParamRec);
var score : SInt32;
    affichage : boolean;
begin

  affichage := false;
  // affichage := true;

  if affichage then
    begin
      WritelnDansRapport('');
      WriteTickOperationPourLeZooDansRapport;
      WritelnDansRapport('Test d''un calcul de milieu : ');
      ChangeFontFaceDansRapport(normal);
      WritelnPositionEtTraitDansRapport(params.inPositionPourFinale,params.inCouleurFinale);
      WritelnFenetreAlphaBetaDansRapport(params.inAlphaFinale,params.inBetaFinale);
      WritelnNumDansRapport('prof = ', params.inProfondeurFinale);
      WritelnDansRapport('');
    end;

  score := LanceurAlphaBetaMilieuWithSearchParams(params);


  // Quitter := false;

  if affichage then
    begin
      WritelnDansRapport('');
      WriteTickOperationPourLeZooDansRapport;
      WritelnNumDansRapport('score = ',score);
      WritelnDansRapport('moves = ' + params.outResult.outLineFinale);
      ChangeFontFaceDansRapport(normal);
      WritelnDansRapport('');
    end;

end;



procedure TesterNoteDeCettePositionDeMilieu(var position : plateauOthello; var jou : plBool; var fr : InfoFront; nbNoir,nbBlanc,trait : SInt16; var nbPosEvaluees : SInt32);
var searchParams : MakeEndgameSearchParamRec;
begin
  Discard2(jou,fr);

  if EscapeDansQueue or Quitter then exit(TesterNoteDeCettePositionDeMilieu);

  with searchParams do
    begin
       inTypeCalculFinale                   := ReflMilieu;
       inCouleurFinale                      := trait;
       inProfondeurFinale                   := 10;
       inNbreBlancsFinale                   := nbBlanc;
       inNbreNoirsFinale                    := nbNoir;
       inAlphaFinale                        := -64;
       inBetaFinale                         := 64;
       inMuMinimumFinale                    := 0;
       inMuMaximumFinale                    := kDeltaFinaleInfini;
       inPrecisionFinale                    := 100;
       inPrioriteFinale                     := 0;
       SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
       inGameTreeNodeFinale                 := NIL;
       inPositionPourFinale                 := position;
       inMessageHandleFinale                := NIL;
       inCommentairesDansRapportFinale      := false;
       inMettreLeScoreDansLaCourbeFinale    := false;
       inMettreLaSuiteDansLaPartie          := false;
       inDoitAbsolumentRamenerLaSuiteFinale := false;
       inDoitAbsolumentRamenerUnScoreFinale := true;
       ViderSearchResults(outResult);
    end;

  if (nbBlanc + nbNoir) > 20 then
    begin

      // tester avec le trait normal
      if not(EscapeDansQueue) then
        TesterUnCalculDeMilieu(searchParams);

      // et aussi avec le trait inverse (pour la robustesse du passe)
      searchParams.inCouleurFinale := -searchParams.inCouleurFinale;

      if not(EscapeDansQueue) then
        TesterUnCalculDeMilieu(searchParams);


      (*
      // et aussi avec le trait nul (pour la robustesse du passe)
      searchParams.inCouleurFinale := pionVide;

      if not(EscapeDansQueue) then
        TesterUnCalculDeMilieu(searchParams);
      *)

      nbPosEvaluees := nbPosEvaluees + 2;

    end;

end;


function CassioEstEnBenchmarkDeMilieu : boolean;
begin
  CassioEstEnBenchmarkDeMilieu := gCassioEstEnBenchmarkDeMilieu;
end;


procedure SetCassioEstEnBenchmarkDeMilieu(flag : boolean);
begin
  gCassioEstEnBenchmarkDeMilieu := flag;
end;



procedure TesterDesRequetesAuZoo(var searchParams : MakeEndgameSearchParamRec);
var url : String255;
    urlParams : String255;
    requete : String255;
    ignored : boolean;
begin {$unused requete}

  url := GetZooURL;



  SetHashValueDuZoo(searchParams.inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);

  urlParams := '';
  EncoderSearchParamsPourURL(searchParams,urlParams,'TesterDesRequetesAuZoo (1)');

  (* WritelnDansRapport('dans testerDesRequetes, avant incr(hash) urlParams = '+urlParams); *)


  ignored := AjouterDansLaListeDesRequetesDuZoo(searchParams);


  {TesterUnCalculDeFinale(searchParams);}


  (*
  AttendFrappeClavier;


  requete := url + '?action=SELECT&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=GET_WORK';
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=GET_WORK';
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=GET_SCORE&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=STILL_INCHARGE&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=SEND_SCORE&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=STILL_INCHARGE&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=GET_SCORE&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  AttendFrappeClavier;

  requete := url + '?action=STOP_ALL&' + 'asker=' + IntToStr(gIdentificateurUniqueDeCetteSessionDeCassio);
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);



  AttendFrappeClavier;

  requete := url + '?action=STOP&' + urlParams;
  EnvoyerUneRequeteAuZoo(requete);
  WritelnDansRapport(requete);

  *)

end;



procedure TesterUnJobDuZooEnLocal(s : String255);
var jobString : LongString;
begin
  SetCassioEstEnTrainDeDebugguerLeZooEnLocal(true);

  WritelnDansRapport(s);

  jobString := MakeLongString(s);
  PrefetchJobDuZoo(jobString);
end;


procedure ReadLineInScriptZoo(var ligne : LongString; var theFic : FichierTEXT; var compteur : SInt32);
var s : String255;
begin
  Discard2(theFic,compteur);

  if gEOFPourZooFile then exit(ReadLineInScriptZoo);

  s := Trim(ligne.debutLigne);

  if (s <> '') and (s[1] <> '%') then
    begin

      if (Pos('__END_OF_FILE__', s) = 1) then
        begin
          gEOFPourZooFile := true;
          exit(ReadLineInScriptZoo);
        end;

      if (Pos('JOB ', s) = 1) or (Pos('PREFETCH ', s) = 1) then
        begin
          TesterUnJobDuZooEnLocal(s);
        end;

    end;
end;



function OuvrirFichierScriptZoo(nomCompletFichier : String255) : OSErr;
var fic : FichierTEXT;
    err : OSErr;
    foo: SInt32;
begin
  err := -1;

  WritelnDansRapport('----------------------------------------------------------------------------------');
  WritelnDansRapport('Chargement de ' + nomCompletFichier);
  WritelnDansRapport('----------------------------------------------------------------------------------');

  gEOFPourZooFile := false;
  err := FichierTexteDeCassioExiste(nomCompletFichier,fic);
  if err = NoErr then
    ForEachLineInFileDo(fic.theFSSpec, ReadLineInScriptZoo, foo);

  OuvrirFichierScriptZoo := err;

  // OuvrirFichierScriptZoo;
end;


function MakeEmptyPositionEtTraitSet : PositionEtTraitSet;     external;
function MemberOfPositionEtTraitSet(var position : PositionEtTraitRec; var data : SInt32; S : PositionEtTraitSet) : boolean;     external;
procedure AddPositionEtTraitToSet(var position : PositionEtTraitRec; data : SInt32; var S : PositionEtTraitSet);     external;


procedure TesterUnitZoo(whichPosition : PositionEtTraitRec);
var searchParams : MakeEndgameSearchParamRec;
    midgameDepth, endgameDepth : SInt32;
    t, s, max_iterateur, trait, nbFilsTrouves : SInt32;
    position : PositionEtTraitRec;
    envoyerSeulementLaPositionActuelleCommeFinale : boolean;
    depthPourLeTest, typeCalculPourLeTest : SInt32;
    positionDoitEtreEnvoyee : boolean;
    positionsDejaEnvoyees : PositionEtTraitSet;
    foo : SInt32;
begin

  (* quelques requetes de job critiques, qui font bugger ? *)
  (* WritelnDansRapport('test des requetes de milieu...'); *)
  (* TesterUnJobDuZooEnLocal('JOB pos=-----------X------XX------OXXO---OXXXX-----O--------------------O window=-64,64 cut=72 depth=10 hash=12345');
     TesterUnJobDuZooEnLocal('JOB pos=-----------XO-------XXOO-OOOOOXX-OOXOXXXOOOOOXXX--OOOOXX-OOOOO-XX window=-64,64 cut=72 depth=24 hash=1782520643');
     TesterUnJobDuZooEnLocal('JOB pos=---------------------------OOO-----XXO------XO------------------X window=-64,64 cut=72 depth=56 hash=10000000');
  *)
   {exit(TesterUnitZoo);}


  if not(CassioDoitRentrerEnContactAvecLeZoo) or Quitter
    then exit(TesterUnitZoo);


  envoyerSeulementLaPositionActuelleCommeFinale := false;


  trait := GetTraitOfPosition(whichPosition);


  nbFilsTrouves := 0;

  positionsDejaEnvoyees := MakeEmptyPositionEtTraitSet();

  position := whichPosition;

  // On envoie tous les petits-fils de la whichPosition dans le zoo

  if envoyerSeulementLaPositionActuelleCommeFinale
    then max_iterateur := 1    // car on prendra seulement la position actuelle
    else max_iterateur := 64;  // car on veut generer tous les fils et tous les petits fils


  for t := 1 to max_iterateur do
    for s := 1 to max_iterateur do
     begin

      position := whichPosition;

      // Pour envoyer les petits fils de la position courante
      // positionDoitEtreEnvoyee := envoyerSeulementLaPositionActuelleCommeFinale
      //                           or (UpdatePositionEtTrait(position, othellier[t]) and UpdatePositionEtTrait(position, othellier[s]));

      // Pour envoyer seulement les fils de la position courante
      positionDoitEtreEnvoyee := envoyerSeulementLaPositionActuelleCommeFinale
                                 or (UpdatePositionEtTrait(position, othellier[t]));

      positionDoitEtreEnvoyee := positionDoitEtreEnvoyee and not(MemberOfPositionEtTraitSet(position,foo,positionsDejaEnvoyees));

      if positionDoitEtreEnvoyee then
        begin
          inc(nbFilsTrouves);

          endgameDepth := NbCasesVidesDansPosition(position.position);

          midgameDepth := Min( 30 , endgameDepth - 12 );


          if (endgameDepth <= 25) or envoyerSeulementLaPositionActuelleCommeFinale
            then
              begin
                depthPourLeTest      := endgameDepth;
                typeCalculPourLeTest := ReflParfait;
              end
            else
              begin
                depthPourLeTest      := midgameDepth;

                //depthPourLeTest      := endgameDepth;  // FIXME FIXME

                typeCalculPourLeTest := ReflMilieu;
              end;


          with searchParams do
            begin
               inTypeCalculFinale                   := typeCalculPourLeTest;
               inCouleurFinale                      := GetTraitOfPosition(position);
               inProfondeurFinale                   := depthPourLeTest;
               inNbreBlancsFinale                   := NbPionsDeCetteCouleurDansPosition(pionBlanc, position.position);
               inNbreNoirsFinale                    := NbPionsDeCetteCouleurDansPosition(pionNoir, position.position);
               inAlphaFinale                        := -64;
               inBetaFinale                         := 64;
               inMuMinimumFinale                    := 0;
               inMuMaximumFinale                    := kDeltaFinaleInfini;
               inPrecisionFinale                    := 100;
               inPrioriteFinale                     := 0;  // RandomBetween(0,10);  0
               inGameTreeNodeFinale                 := NIL;
               inPositionPourFinale                 := position.position;
               inMessageHandleFinale                := NIL;
               inCommentairesDansRapportFinale      := true;
               inMettreLeScoreDansLaCourbeFinale    := false;
               inMettreLaSuiteDansLaPartie          := false;
               inDoitAbsolumentRamenerLaSuiteFinale := false;
               inDoitAbsolumentRamenerUnScoreFinale := true;
               ViderSearchResults(outResult);
            end;

          TesterDesRequetesAuZoo(searchParams);

          AddPositionEtTraitToSet(position, 0, positionsDejaEnvoyees);

          position := whichPosition;
        end;
    end;

  if (nbFilsTrouves > 0) then
    WritelnDansRapport(IntToStr(NombreDeResultatsEnAttenteSurLeZoo) + ' positions currently on the zoo');
end;



procedure DemarrerLeTestDuZooAvecLaSouris;
begin
  gDateDebutDuTestDuZooAvecLaSouris := TickCount;
end;



procedure EssayerEnvoyerPositionCouranteAuZooPourLeTester;
begin
  // si on est moins de 30 secondes apres le alt-maj-Q, alors
  // on envoie la position au zoo pour tester le zoo
  if ((TickCount - gDateDebutDuTestDuZooAvecLaSouris) < 30 * 60)
    then TesterUnitZoo(PositionEtTraitCourant);
end;



END.
