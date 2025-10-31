UNIT UnitScripts;


INTERFACE







 USES UnitDefCassio;




{Initialisation et libération de l'unité}
procedure InitUnitScripts;
procedure LibereMemoireUnitScripts;


{Gestion des fichiers au format Othello script}
function EstUnScriptDeFinales(nomFichier : String255 ; vRefNum : SInt16) : boolean;
function CreateEndgameScript(nomDeLaBase : String255) : OSErr;
function OuvrirEndgameScript(nomScript : String255) : OSErr;
function ScriptDeFinaleEnCours : boolean;
function GetProchainScriptDeFinaleAOuvrir : String255;
procedure LancerInterruptionPourOuvrirScriptDeFinale(nomScript : String255);


{Quelques utilitaires}
function ExtraitPositionEtTraitDeLaListeEnString(numeroReference : SInt32; apresQuelCoup : SInt32; var typeErreur : SInt32) : String255;
function CreateResultStringForScript(score : SInt32; var positionEtTrait : PositionEtTraitRec; endgameSolveFlags : SInt32) : String255;


{Problemes de Stepanov}
procedure GenererCycleDesProblemesDeStepanov;
function ProcessProblemesStepanov(nomScript : String255; quelProbleme : SInt32) : OSErr;
procedure AfficheProchainProblemeStepanov;
procedure CreerQuizEnPHP(nomQuizGenerique : String255; numeroQuiz : SInt32; positionQuiz : PositionEtTraitRec; coupSolution : SInt32; commentaire : String255);
procedure CreerPositionQuizzEnJPEG(nomJPEG : String255; positionQuiz : PositionEtTraitRec);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , EdmondEvaluation, MyQuickDraw, UnitAffichageReflexion, UnitAccesNouveauFormat, UnitSetUp, UnitJeu
    , UnitMenus, UnitEnvirons, UnitEPS, UnitHTML, UnitDialog, MyFileSystemUtils, UnitServicesDialogs, MyStrings
    , UnitPositionEtTrait, UnitCurseur, UnitRapport, UnitSolve, UnitScannerUtils, UnitNouvelleEval, UnitGestionDuTemps, UnitEvaluation
    , basicfile, UnitRapportImplementation, MyMathUtils, SNEvents, UnitRetrograde, UnitRapportUtils, UnitFichierAbstrait, UnitServicesRapport
     ;
{$ELSEC}
    ;
    {$I prelink/Scripts.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure DoDemandeChangerHumCtreHum;     external;
procedure AlerteDoitInterompreReflexionPourFaireScript;     external;


const kNbTotalDeQuiz = 100;

var pathFichierProblemesStepanov : String255;
    permutationDesNumerosDeQuiz : array[1..kNbTotalDeQuiz] of SInt32;
    gScriptDeFinaleEnCours : boolean;
    gProchainFichierScriptDeFinaleAOuvrir : String255;

procedure GenererCycleDesProblemesDeStepanov;
const kValeurSpeciale = -100;
      kCelluleVide = -1;
var i,a,n,compteur,j,premierAntecedant : SInt32;
begin

  {generer le cycle aleatoire pour la page FFO}

  for i := 1 to kNbTotalDeQuiz do
    permutationDesNumerosDeQuiz[i] := kCelluleVide;
  SetRandomSeed(2);  {initialiser le generateur aleatoire}

  a := kValeurSpeciale;
  for i := 1 to kNbTotalDeQuiz do
    begin
      n := RandomBetween(1,kNbTotalDeQuiz-i+1);

      compteur := 0;
      j := 1;
      repeat
        if permutationDesNumerosDeQuiz[j] = kCelluleVide then inc(compteur);
        if (compteur < n) then inc(j);
      until (j >= kNbTotalDeQuiz) or (compteur >= n);

      permutationDesNumerosDeQuiz[j] := a;
      if a = kValeurSpeciale then premierAntecedant := j;
      a := j;

    end;

  permutationDesNumerosDeQuiz[premierAntecedant] := a;

  RandomizeTimer;
end;


procedure InitUnitScripts;

begin
  dernierProblemeStepnanovAffiche := 0;
  pathFichierProblemesStepanov := '';
  gScriptDeFinaleEnCours := false;

  GenererCycleDesProblemesDeStepanov;
end;


procedure LibereMemoireUnitScripts;
begin
end;

function EstUnScriptDeFinales(nomFichier : String255 ; vRefNum : SInt16) : boolean;
begin
  {$UNUSED vRefNum}
  EstUnScriptDeFinales := NoCasePos('.script',nomFichier) > 0;
end;


function ExtraitPositionEtTraitDeLaListeEnString(numeroReference : SInt32; apresQuelCoup : SInt32; var typeErreur : SInt32) : String255;
var s60 : PackedThorGame;
begin
  ExtraitPositionEtTraitDeLaListeEnString := '';
  typeErreur := kPartieOK;

  if (numeroReference > 0) and (numeroReference <= nbPartiesActives) then
    begin
      ExtraitPartieTableStockageParties(numeroReference,s60);
      ExtraitPositionEtTraitDeLaListeEnString := PositionEtTraitAfterMoveEnString(s60,apresQuelCoup,typeErreur);
    end;
end;



function CreateEndgameScript(nomDeLaBase : String255) : OSErr;
const kApresQuelCoup = 40;
var n,k : SInt32;
    script : basicfile;
    err : OSErr;
    reply : SFReply;
    nomfichier,theLine,s : String255;
    info : fileInfo;
    myDate : DateTimeRec;
    explicationRejetPartie : SInt32;
begin
  err := -1;
  if windowListeOpen and (nbPartiesActives > 0) then
    begin
		  s := ReadStringFromRessource(TextesDiversID,2);   {'sans titre'}
		  SetNameOfSFReply(reply, s);
		  if MakeFileName(reply,'Nom de la base à scripter ?',info) then
		      begin

		        nomDeLaBase := GetNameOfSFReply(reply);

		        nomfichier := GetNameOfSFReply(reply)+'.script';
		        err := FileExists(FileInfo(info.vRefNum,info.parID,nomfichier),script);
		        if err = fnfErr then err := CreateFile(FileInfo(info.vRefNum,info.parID,nomfichier),script);
		        if err = 0 then
		          begin
		            err := OpenFile(script);
		            err := EmptyFile(script);
		          end;
		        if err <> 0 then
		          begin
		            AlerteSimpleFichierTexte(nomFichier,err);
		            err := CloseFile(script);
		            CreateEndgameScript := err;
		            exit;
		          end;


		        theLine := '% File '+nomfichier;
		        err := Writeln(script,theLine);
		        GetTime(myDate);
		        theLine := '% Endgame script created by '+GetApplicationName('Cassio');
		        err := Writeln(script,theLine);
		        theLine := '% '+IntToStr(myDate.year)+'-'+
		                      IntToStr(myDate.month)+'-'+
		                      IntToStr(myDate.day);
		        err := Writeln(script,theLine);
		        theLine := '% All positions in this script are generated after move '+IntToStr(kApresQuelCoup)+', but this is not a requirement of the script format';
		        err := Writeln(script,theLine);
		        err := Writeln(script,'%');


		        watch := GetCursor(watchcursor);
            SafeSetCursor(watch);

		        for k := 1 to Min(1000,nbPartiesActives) do
		          begin


		           {n := k;}
		            n := RandomBetween(1, nbPartiesActives);

		            theLine := ExtraitPositionEtTraitDeLaListeEnString(n,kApresQuelCoup,explicationRejetPartie);

		            if (theLine <> '') and (explicationRejetPartie = kPartieOK)
		              then
		                err := Writeln(script,theLine+' % '+nomDeLaBase+' after '+IntToStr(kApresQuelCoup)+' #'+IntToStr(n))
		              else
		                begin
		                  (*
		                  case explicationRejetPartie of
		                    kPartieIllegale :
		                      err := Writeln(script,'% illegal game : '+nomDeLaBase+' #'+IntToStr(n));
		                    kPartieTropCourte :
		                      err := Writeln(script,'% game too short : '+nomDeLaBase+' #'+IntToStr(n));
		                  end;
		                  *)
		                end;
		          end;

		        err := Writeln(script,'%');
		        err := Writeln(script,'% End of the endgame script');

		        err := CloseFile(script);
		        SetFileCreatorFichierTexte(script,FOUR_CHAR_CODE('CWIE'));
		        SetFileTypeFichierTexte(script,FOUR_CHAR_CODE('TEXT'));
		      end;
		end;
  RemettreLeCurseurNormalDeCassio;
  CreateEndgameScript := err;
end;





function CreateResultStringForScript(score : SInt32; var positionEtTrait : PositionEtTraitRec; endgameSolveFlags : SInt32) : String255;
var result,s1,s2 : String255;
    scorePourNoir : SInt32;
    onlyWLD,withOptimalLine : boolean;
begin

  onlyWLD            := (endgameSolveFlags and kEndgameSolveOnlyWLD) <> 0;
  withOptimalLine    := (endgameSolveFlags and kEndgameSolveToujoursRamenerLaSuite) <> 0;

  result := '';
  if GetTraitOfPosition(positionEtTrait) = pionNoir
    then scorePourNoir := score
    else scorePourNoir := -score;

  if onlyWLD
    then
      begin
			  if scorePourNoir > 0 then result := 'Black win      ' else
			  if scorePourNoir = 0 then result := 'Draw           ' else
			  if scorePourNoir < 0 then result := 'White win      ';
      end
    else
      begin
			  s1 := IntToStr(32+(scorePourNoir div 2));
			  if LENGTH_OF_STRING(s1) = 1 then s1 := Concat(' ',s1);
			  s2 := IntToStr(32-(scorePourNoir div 2));
			  if LENGTH_OF_STRING(s2) = 1 then s2 := Concat(' ',s2);
			  result := s1+' - '+s2+'      ';
      end;

  if withOptimalLine then
    result := result + MeilleureSuiteInfosEnChaine(1,false,false,false,false,0)+'      ';

  CreateResultStringForScript := result;
end;


function OuvrirEndgameScript(nomScript : String255) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomfichier doit etre un path complet }
const kCassioCommandPrompt = '% TELL CASSIO : ';
var ligne,nomOutpuScript,comment,s,result : String255;
    erreurES : OSErr;
    inputScript,outputScript : basicfile;
    score,positionCommentaire : SInt32;
    positionEtTrait : PositionEtTraitRec;
    ticks,tempsPourCettePositionsEnSecondes,tempsTotalEnSecondes : SInt32;
    tempsMaximumEnSecondes,nbPositionsResolues : SInt32;
    endgameSolveFlags : SInt32;
    ecritureDansRapportTemp : boolean;
    solveResults : MakeEndgameSearchResultRec;

  procedure InterpreterCommandePourCassioDansFichierScript(ligne : String255);
  begin
    if (Pos(kCassioCommandPrompt,ligne) > 0) then
      begin

        ligne := TPCopy(ligne,Pos(kCassioCommandPrompt,ligne) + LENGTH_OF_STRING(kCassioCommandPrompt),255);

        if (Pos('WRITE ',ligne) > 0) then
          WritelnDansRapport(TPCopy(ligne,Pos('WRITE ',ligne) + LENGTH_OF_STRING('WRITE '),255));

        if (Pos('SET WLD = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) = 0
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;

        if (Pos('SET WLD = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) <> 0
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;

        if (Pos('SET EXACT = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) = 0
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;

        if (Pos('SET EXACT = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveOnlyWLD) <> 0
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveOnlyWLD;

        if (Pos('SET LINE = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveToujoursRamenerLaSuite) = 0
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveToujoursRamenerLaSuite;

        if (Pos('SET LINE = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveToujoursRamenerLaSuite) <> 0
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveToujoursRamenerLaSuite;

        if (Pos('SET POSITION = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrirePositionDansRapport) = 0
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrirePositionDansRapport;

        if (Pos('SET POSITION = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrirePositionDansRapport) <> 0
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveEcrirePositionDansRapport;

        if (Pos('SET ECHO = TRUE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrireInfosTechniquesDansRapport) = 0
            then endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrireInfosTechniquesDansRapport;

        if (Pos('SET ECHO = FALSE',ligne) > 0) then
          if (endgameSolveFlags and kEndgameSolveEcrireInfosTechniquesDansRapport) <> 0
            then endgameSolveFlags := endgameSolveFlags - kEndgameSolveEcrireInfosTechniquesDansRapport;



        if (Pos('SET ENGINE = CASSIO',ligne) > 0) or
           (Pos('SET ENGINE = EDMOND',ligne) > 0) or
           (Pos('SET ENGINE = MIXTE_CASSIO_EDMOND',ligne) > 0) then
          begin

            if (Pos('SET ENGINE = CASSIO',ligne) > 0) then typeEvalEnCours := EVAL_CASSIO;
            if (Pos('SET ENGINE = EDMOND',ligne) > 0) then typeEvalEnCours := EVAL_EDMOND;
            if (Pos('SET ENGINE = MIXTE_CASSIO_EDMOND',ligne) > 0) then typeEvalEnCours := EVAL_MIXTE_CASSIO_EDMOND;
          end;


      end;
  end;

begin
  OuvrirEndgameScript := NoErr;  {pas encore de gestion d'erreurs :-( }


  if CassioEstEnTrainDeReflechir then
    begin
      AlerteDoitInterompreReflexionPourFaireScript;
      exit;
    end;


  // On met les valeurs par défaut pour les drapeaux de résolution de la finale.
  // Ces valeurs pourront être changées par des commandes trouvées dans le
  // script lui-même.

  endgameSolveFlags := 0;

  if (nbreCoup > 20) and (phaseDeLaPartie < phaseFinaleParfaite) then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveOnlyWLD;

  if afficheMeilleureSuite then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveToujoursRamenerLaSuite;

  if InfosTechniquesDansRapport then
    endgameSolveFlags := endgameSolveFlags + kEndgameSolveEcrireInfosTechniquesDansRapport;


  if ScriptDeFinaleEnCours or
     not(PeutArreterAnalyseRetrograde) then
    exit;


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  EndHiliteMenu(TickCount,8,false);


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

  if (nomScript = '') then
    begin
      AlerteSimpleFichierTexte(nomScript,0);
      exit;
    end;
  {SetDebugFiles(false);}

  nomOutpuScript := nomScript+'.output';

  erreurES := FileExists(nomScript,0,inputScript);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit;
    end;

  erreurES := OpenFile(inputScript);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit;
    end;

  erreurES := FileExists(nomOutpuScript,0,outputScript);
  if erreurES = fnfErr then erreurES := CreateFile(nomOutpuScript,0,outputScript);
  if erreurES = 0 then
    begin
      erreurES := OpenFile(outputScript);
      erreurES := EmptyFile(outputScript);
    end;
  if erreurES <> 0 then
    begin
      AlerteSimpleFichierTexte(nomOutpuScript,erreurES);
      erreurES := CloseFile(outputScript);
      exit;
    end;

  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomOutpuScript,erreurES);
      exit;
    end;


  // On déroule le script

  gScriptDeFinaleEnCours := true;

  ecritureDansRapportTemp := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(true);

  AnnonceOuvertureFichierEnRougeDansRapport(nomScript);

  nbPositionsResolues := 0;
  tempsTotalEnSecondes := 0;
  tempsMaximumEnSecondes := 0;
  erreurES := NoErr;
  ligne := '';
  while not(EndOfFile(inputScript,erreurES)) and
        (Pos('% End of the endgame script',ligne) = 0) and
        not(EscapeDansQueue) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      erreurES := Readln(inputScript,s);
      ligne := s;
      ligne := EnleveEspacesDeGauche(ligne);
      if (ligne = '') or (ligne[1] = '%')
        then
          begin
            erreurES := Writeln(outputScript,s);
            if (Pos(kCassioCommandPrompt,ligne) > 0) then InterpreterCommandePourCassioDansFichierScript(ligne);
          end
        else
          begin
            if ParsePositionEtTrait(ligne,positionEtTrait) and (GetTraitOfPosition(positionEtTrait) <> pionVide)
              then
                begin
                  positionCommentaire := Pos('%',ligne);
                  if positionCommentaire > 0
                    then comment := TPCopy(ligne,positionCommentaire,LENGTH_OF_STRING(ligne)-positionCommentaire+1)
                    else comment := '';


                  ticks := TickCount;
                  if Quitter
                    then score := -1000     {or any impossible score  < -64 or > 64}
                    else score := DoPlaquerPositionAndMakeEndgameSolve(positionEtTrait,endgameSolveFlags,solveResults);

                  if Quitter or (score < -64) or (score > 64)
                    then result := '?? - ??      '
                    else
                      begin

                        result := CreateResultStringForScript(score,positionEtTrait,endgameSolveFlags);

                        inc(nbPositionsResolues);
                        tempsPourCettePositionsEnSecondes := (TickCount-ticks) div 60;
                        tempsTotalEnSecondes := tempsTotalEnSecondes+tempsPourCettePositionsEnSecondes;
                        if tempsPourCettePositionsEnSecondes > tempsMaximumEnSecondes then tempsMaximumEnSecondes := tempsPourCettePositionsEnSecondes;

                        if (nbPositionsResolues <> 0) and ((nbPositionsResolues mod 50) = 0) then
                          begin
                            WritelnDansRapport('après '+IntToStr(nbPositionsResolues)+' positions résolues :');
                            WritelnStringAndReelDansRapport('   temps moyen en sec : ',1.0*tempsTotalEnSecondes/nbPositionsResolues,3);
                            WritelnNumDansRapport('   temps maximum en sec : ',tempsMaximumEnSecondes);
                          end;

                      end;
                  erreurES := Writeln(outputScript,result+comment);
                end
              else
                begin
                  erreurES := Writeln(outputScript,'% Parse error for the following line :');
                  erreurES := Writeln(outputScript,'% '+s);
                end;
          end;
    end;

  erreurES := CloseFile(inputScript);
  erreurES := CloseFile(outputScript);

  if (nbPositionsResolues <> 0) then
    begin
      ChangeFontFaceDansRapport(bold);
		  ChangeFontColorDansRapport(RougeCmd);
      WritelnDansRapport('');
      WriteDansRapport('Fin de l''exécution du script de finales : ');
      s := 'j''ai résolu '+IntToStr(nbPositionsResolues)+' positions en ' + IntToStr(tempsTotalEnSecondes) + ' secondes';
      if (tempsTotalEnSecondes > 80) then s := s + ' ('+SecondesEnJoursHeuresSecondes(tempsTotalEnSecondes)+')';
      WritelnDansRapport(s + '.');
      WritelnDansRapport('');
      TextNormalDansRapport;
    end;

  gScriptDeFinaleEnCours := false;

  SetEcritToutDansRapportLog(ecritureDansRapportTemp);
  if not(HumCtreHum) then DoDemandeChangerHumCtreHum;
  RemettreLeCurseurNormalDeCassio;
end;


function ScriptDeFinaleEnCours : boolean;
begin
  ScriptDeFinaleEnCours := gScriptDeFinaleEnCours;
end;


function GetProchainScriptDeFinaleAOuvrir : String255;
begin
  GetProchainScriptDeFinaleAOuvrir := gProchainFichierScriptDeFinaleAOuvrir;
end;


procedure LancerInterruptionPourOuvrirScriptDeFinale(nomScript : String255);
begin
  gProchainFichierScriptDeFinaleAOuvrir := nomScript;
  LanceInterruption(kHumainVeutOuvrirFichierScriptFinale,'LancerInterruptionPourOuvrirScriptDeFinale');
end;



procedure CreerQuizEnPHP(nomQuizGenerique : String255; numeroQuiz : SInt32; positionQuiz : PositionEtTraitRec; coupSolution : SInt32; commentaire : String255);
var fichierPHP : basicfile;
    fichierAbstraitPHP : FichierAbstrait;
    erreurES : OSErr;
    s,nom_solution : String255;
    a : SInt32;
    nomQuiz : String255;
    positionSolution : PositionEtTraitRec;
    positionEssai : PositionEtTraitRec;
    i,j,square : SInt32;


  function FabriquerNomAutreQuiz(numero : SInt32) : String255;
  var s : String255;
  begin
    s := ParamStr('stepanov_^0.php',IntToStr(numero),'','','');
    FabriquerNomAutreQuiz := s;
  end;



begin {CreerQuizEnPHP}

  a := permutationDesNumerosDeQuiz[numeroQuiz];

  nomQuizGenerique := ReplaceStringOnce(nomQuizGenerique, 'problemes_stepanov' , 'stepanov');
  nomQuiz := ParamStr(nomQuizGenerique,IntToStr(numeroQuiz),'','','');


  erreurES := FileExists(nomQuiz,0,fichierPHP);
  if erreurES = fnfErr then erreurES := CreateFile(nomQuiz,0,fichierPHP);
  if erreurES = 0 then
    begin
      erreurES := OpenFile(fichierPHP);
      erreurES := EmptyFile(fichierPHP);


      erreurES := FSSpecToFullPath(fichierPHP.info,s);
      s := ReplaceStringOnce(s, GetName(fichierPHP.info),'quiz_prologue.php');
      erreurES := InsertFileInFile(fichierPHP,s);


      nom_solution := ReplaceStringOnce(GetName(fichierPHP.info), '.php' , '_^0.php');




      FermerFichierEtFabriquerFichierAbstrait(fichierPHP,fichierAbstraitPHP);

      if GetTraitOfPosition(positionQuiz) = pionBlanc
        then erreurES := WritePositionEtTraitEnHTMLDansFichierAbstrait(positionQuiz,fichierAbstraitPHP,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<a href="'+nom_solution+'"><img src="ee.gif" width="24" height="24" border="0"></a>',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           '<span><br><b > Problandegrave;me '+IntToStr(numeroQuiz)+'</b></span>'
                                          )
         else erreurES := WritePositionEtTraitEnHTMLDansFichierAbstrait(positionQuiz,fichierAbstraitPHP,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<a href="'+nom_solution+'"><img src="ee.gif" width="24" height="24" border="0"></a>',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           '<span><br><b > Problandegrave;me '+IntToStr(numeroQuiz)+'</b></span>'
                                          );

      DisposeFichierAbstraitEtOuvrirFichier(fichierPHP,fichierAbstraitPHP);

      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

      ErreurES := Writeln(fichierPHP,'</td>');


      ErreurES := Writeln(fichierPHP,'<td width="15">');
      ErreurES := Writeln(fichierPHP,'</td>');

      ErreurES := Writeln(fichierPHP,'<td valign="top">');

      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');
      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');
      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');

      ErreurES := Writeln(fichierPHP,'<p>');
      if GetTraitOfPosition(positionQuiz) = pionNoir
        then ErreurES := Writeln(fichierPHP,'Trait andagrave;  < b > Noir </b > .')
        else ErreurES := Writeln(fichierPHP,'Trait andagrave;  < b > Blanc </b > .');
      ErreurES := Writeln(fichierPHP,'Cliquez sur le bon coup ! </p>');
      ErreurES := Writeln(fichierPHP,'</td>');
      ErreurES := Writeln(fichierPHP,'</tr>');

      ErreurES := Writeln(fichierPHP,'</table>');


      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

      ErreurES := Writeln(fichierPHP,'<hr>');

      ErreurES := Writeln(fichierPHP,'<p class="menu-navigation-rapide">');
      ErreurES := Writeln(fichierPHP,'[ < a href="'+FabriquerNomAutreQuiz(permutationDesNumerosDeQuiz[numeroQuiz])+'">Autre quiz </a > ] - [ < a href="../index.php">Retour andagrave; l''accueil');
      ErreurES := Writeln(fichierPHP,'</a > ]');
      ErreurES := Writeln(fichierPHP,'</p>');



      erreurES := FSSpecToFullPath(fichierPHP.info,s);
      s := ReplaceStringOnce(s, GetName(fichierPHP.info),'quiz_epilogue.php');
      erreurES := InsertFileInFile(fichierPHP,s);

      erreurES := CloseFile(fichierPHP);
    end;



  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        square := i*10 + j;
        positionEssai    := positionQuiz;
        positionSolution := positionQuiz;

        if UpdatePositionEtTrait(positionEssai,square) and UpdatePositionEtTrait(positionSolution,coupSolution) then
          begin


            nomQuiz := ParamStr(nomQuizGenerique,IntToStr(numeroQuiz)+'_'+CoupEnStringEnMinuscules(square),'','','');


            erreurES := FileExists(nomQuiz,0,fichierPHP);
            if erreurES = fnfErr then erreurES := CreateFile(nomQuiz,0,fichierPHP);
            if erreurES = 0 then
              begin
                erreurES := OpenFile(fichierPHP);
                erreurES := EmptyFile(fichierPHP);


                erreurES := FSSpecToFullPath(fichierPHP.info,s);
                s := ReplaceStringOnce(s, GetName(fichierPHP.info),'quiz_prologue.php');
                erreurES := InsertFileInFile(fichierPHP,s);


                nom_solution := ReplaceStringOnce(GetName(fichierPHP.info), '.php' , '_^0.php');




                if (square = CoupSolution)
                  then
                    begin


                      FermerFichierEtFabriquerFichierAbstrait(fichierPHP,fichierAbstraitPHP);
                      erreurES := WritePositionEtTraitPageWebFFODansFichierAbstrait(positionEssai,'<span><br><b > Bravo ! </b></span>',fichierAbstraitPHP);
                      DisposeFichierAbstraitEtOuvrirFichier(fichierPHP,fichierAbstraitPHP);

                      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
                      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

                      ErreurES := Writeln(fichierPHP,'</td>');

                      ErreurES := Writeln(fichierPHP,'<td width="15">');
                      ErreurES := Writeln(fichierPHP,'</td>');


                      ErreurES := Writeln(fichierPHP,'<td valign="top">');
                      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');
                      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');
                      ErreurES := Writeln(fichierPHP,'<p align="center">andnbsp; </p>');
                      ErreurES := Writeln(fichierPHP,'<p><b > Bravo </b >  !');

                      FermerFichierEtFabriquerFichierAbstrait(fichierPHP,fichierAbstraitPHP);
                      ErreurES := WritelnEnHTMLDansFichierAbstrait(fichierAbstraitPHP,commentaire);
                      DisposeFichierAbstraitEtOuvrirFichier(fichierPHP,fichierAbstraitPHP);



                      ErreurES := Writeln(fichierPHP,'</td>');
                      ErreurES := Writeln(fichierPHP,'</tr>');


                    end
                  else
                    begin

                      FermerFichierEtFabriquerFichierAbstrait(fichierPHP,fichierAbstraitPHP);
                      erreurES := WritePositionEtTraitPageWebFFODansFichierAbstrait(positionEssai,'<span><br><b > Ratandeacute; </b></span>',fichierAbstraitPHP);
                      DisposeFichierAbstraitEtOuvrirFichier(fichierPHP,fichierAbstraitPHP);

                      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');
                      ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

                      ErreurES := Writeln(fichierPHP,'</td>');

                      ErreurES := Writeln(fichierPHP,'<td width="50%" valign="top">');

                      FermerFichierEtFabriquerFichierAbstrait(fichierPHP,fichierAbstraitPHP);
                      erreurES := WritePositionEtTraitPageWebFFODansFichierAbstrait(positionSolution,'<span><br />'+StringEnHTML(commentaire)+'</span>',fichierAbstraitPHP);
                      DisposeFichierAbstraitEtOuvrirFichier(fichierPHP,fichierAbstraitPHP);

                      ErreurES := Writeln(fichierPHP,'</td>');

                      ErreurES := Writeln(fichierPHP,'</tr>');


                    end;


                ErreurES := Writeln(fichierPHP,'</table>');



                ErreurES := Writeln(fichierPHP,'<div class="saut-de-paragraphe"><span></span></div>');

                ErreurES := Writeln(fichierPHP,'<hr>');

                ErreurES := Writeln(fichierPHP,'<p class="menu-navigation-rapide">');
                ErreurES := Writeln(fichierPHP,'[ < a href="'+FabriquerNomAutreQuiz(permutationDesNumerosDeQuiz[numeroQuiz])+'">Autre quiz </a > ] - [ < a href="../index.php">Retour andagrave; l''accueil');
                ErreurES := Writeln(fichierPHP,'</a > ]');
                ErreurES := Writeln(fichierPHP,'</p>');



                erreurES := FSSpecToFullPath(fichierPHP.info,s);
                s := ReplaceStringOnce(s, GetName(fichierPHP.info),'quiz_epilogue.php');
                erreurES := InsertFileInFile(fichierPHP,s);

                erreurES := CloseFile(fichierPHP);
              end;

          end;
      end;
end;



procedure CreerPositionQuizzEnJPEG(nomJPEG : String255; positionQuiz : PositionEtTraitRec);
var fichierJPEG : basicfile;
    erreurES : OSErr;
    path : String255;
begin
  SplitRightByChar(nomJPEG,':',path,nomJPEG);
  WritelnDansRapport('nomJPEG = '+nomJPEG);

  erreurES := FichierTexteDeCassioExiste(nomJPEG,fichierJPEG);
  if erreurES = fnfErr then erreurES := CreeFichierTexteDeCassio(nomJPEG,fichierJPEG);
  if erreurES = 0 then
    begin
      erreurES := OpenFile(fichierJPEG);
      erreurES := EmptyFile(fichierJPEG);
      erreurES := CloseFile(fichierJPEG);

      WritelnNumDansRapport('CreerPositionQuizzEnJPEG : avant CreateJPEGImageOfPosition, erreurES = ',erreurES);
      CreateJPEGImageOfPosition(positionQuiz,fichierJPEG.info);
    end;
end;



function ProcessProblemesStepanov(nomScript : String255; quelProbleme : SInt32) : OSErr;
var ligne,comment : String255;
    s1,s2,s3,s4,s5,s6,reste : String255;
    erreurES : OSErr;
    inputScript : basicfile;
    (* fichierEPS : basicfile;
    nomFichierEPS : String255; *)
    nomFichierPHP : String255;
    positionCommentaire : SInt32;
    positionEtTrait : PositionEtTraitRec;
    ticks,tempsPourCettePositionsEnSecondes,tempsTotalEnSecondes : SInt32;
    tempsMaximumEnSecondes,nbProblemesTraites : SInt32;
    arretPoblemesStepanov : boolean;
    foo : SInt16;
    coupDeLaSolution : SInt32;
    traitDeLaSolution : SInt32;
    buffer : packed array[0..1023] of char;
    count,nbEspacesEnleves : SInt32;
begin
   ProcessProblemesStepanov := NoErr;  {pas encore de gestion d'erreurs :-( }

  if not(PeutArreterAnalyseRetrograde) then
    exit;


  if nomScript = '' then
    begin
      AlerteSimpleFichierTexte(nomScript,0);
      exit;
    end;
  {SetDebugFiles(false);}


  erreurES := FileExists(nomScript,0,inputScript);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit;
    end;

  erreurES := OpenFile(inputScript);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomScript,erreurES);
      exit;
    end;



  pathFichierProblemesStepanov := nomScript;

  nbProblemesTraites := 0;
  tempsTotalEnSecondes := 0;
  tempsMaximumEnSecondes := 0;
  erreurES := NoErr;
  ligne := '';
  arretPoblemesStepanov := false;
  while not(arretPoblemesStepanov) and
        not(EndOfFile(inputScript,erreurES)) and
        (Pos('% End of the endgame script',ligne) = 0) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);


      count := 1024;
      erreurES := Readln(inputScript,@buffer[0],count);

      {on enleve les espaces au debut de la ligne}
      EnleveEtCompteCeCaractereAGaucheDansBuffer(@buffer[0],count,' ',nbEspacesEnleves);


      if (count >= 70) and (buffer[0] <> '%')  then
          begin

            ligne := BufferToPascalString(@buffer[0],0, 69);

            {WritelnDansRapport(ligne);}
            if ParsePositionEtTrait(ligne,positionEtTrait) and (GetTraitOfPosition(positionEtTrait) <> pionVide)
              then
                begin


                  comment := BufferToPascalString(@buffer[0], 66, count-1);


                  positionCommentaire := Pos('%',comment);
                  if positionCommentaire > 0
                    then
                      begin


                        comment := TPCopy(comment,positionCommentaire,LENGTH_OF_STRING(comment)-positionCommentaire+1);

                        Parse6(comment,s1,s2,s3,s4,s5,s6,reste);

                        coupDeLaSolution := ScannerStringPourTrouverCoup(1,s3,foo);
                        traitDeLaSolution := GetTraitOfPosition(positionEtTrait);

                        {WritelnDansRapport(reste);}
                        Parse5(reste,s1,s2,s3,s4,s5,reste);
                        {WritelnDansRapport(reste);}

                      end
                    else
                      begin
                        comment := '';
                        reste := '';
                        coupDeLaSolution := -1;
                      end;



                  inc(nbProblemesTraites);



                  ticks := TickCount;

                  if not(Quitter) and (nbProblemesTraites = quelProbleme) then
                    begin
                      dernierProblemeStepnanovAffiche := quelProbleme;
                      PlaquerPosition(positionEtTrait.position,GetTraitOfPosition(positionEtTrait),kRedessineEcran);

                      WritelnNumDansRapport('Problème numéro ',nbProblemesTraites);
                      {WritelnDansRapport('   commentaire = ' + comment);}

                      tempsPourCettePositionsEnSecondes := (TickCount-ticks) div 60;
                      tempsTotalEnSecondes := tempsTotalEnSecondes + tempsPourCettePositionsEnSecondes;
                      if tempsPourCettePositionsEnSecondes > tempsMaximumEnSecondes then tempsMaximumEnSecondes := tempsPourCettePositionsEnSecondes;


                      (* On ecrit le diagramme de la position dans un fichier EPS *)
                      (*
                      nomFichierEPS := ReplaceStringOnce(nomScript, '.script' , '_');
                      nomFichierEPS := nomFichierEPS + IntToStr(nbProblemesTraites) + '.eps';

                      erreurES := FileExists(nomFichierEPS,0,fichierEPS);
										  if erreurES = fnfErr then erreurES := CreateFile(nomFichierEPS,0,fichierEPS);
										  if erreurES = 0 then
										    begin
										      erreurES := OpenFile(fichierEPS);
										      erreurES := EmptyFile(fichierEPS);
										      erreurES := WritePositionEtTraitEnEPSDansFichier(positionEtTrait,fichierEPS);
										      erreurES := CloseFile(fichierEPS);
										    end;
                      *)

                      (* On ecrit le diagramme de la position dans un fichier quiz PHP *)
                      nomFichierPHP := ReplaceStringOnce(nomScript, '.script' , '_^0.php');
                      CreerQuizEnPHP(nomFichierPHP,nbProblemesTraites,positionEtTrait,coupDeLaSolution,reste);

                      (* On cree l'imagette JPEG de la solution *)
                      (*
                      CreerPositionQuizzEnJPEG(ParamStr(ReplaceStringOnce(positionEtTrait, '.script','_^0.jpg',nomScript),IntToStr(nbProblemesTraites),'','' , ''));
                      *)


                      (* On écrit le diagramme de la solution dans un autre fichier EPS *)
                      (*
                      if UpdatePositionEtTrait(positionEtTrait, coupDeLaSolution)
                        then
                          begin
			                      nomFichierEPS := ReplaceStringOnce(nomScript, '.script' , '_sol_');
			                      nomFichierEPS := nomFichierEPS + IntToStr(nbProblemesTraites) + '.eps';

			                      erreurES := FileExists(nomFichierEPS,0,fichierEsPS);
													  if erreurES = fnfErr then erreurES := CreateFile(nomFichierEPS,0,fichierEPS);
													  if erreurES = 0 then
													    begin
													      erreurES := OpenFile(fichierEPS);
													      erreurES := EmptyFile(fichierEPS);
													      erreurES := WritePositionEtTraitEnEPSDansFichier(positionEtTrait,fichierEPS);
													      erreurES := CloseFile(fichierEPS);
													    end;
													end
											  else
											    begin
											      WritelnNumDansRapport('WARNING : solution illégale ('+CoupEnStringEnMinuscules(coupDeLaSolution)+') dans le problème numéro ', nbProblemesTraites);
											    end;
										 *)


                     (* Ecriture du code TeX dans le rapport *)
                     (*
                     WritelnDansRapport('\includegraphics[scale = 1.75]{problemes_stepanov_'+IntToStr(nbProblemesTraites)+'}');
                     case traitDeLaSolution of
                       pionNoir  : WritelnDansRapport('\\ Noir');
                       pionBlanc : WritelnDansRapport('\\ Blanc');
                     end;
                     WritelnDansRapport('\newpage');
                     WritelnDansRapport('\includegraphics[scale = 0.75]{problemes_stepanov_sol_'+IntToStr(nbProblemesTraites)+'}');
                     WritelnDansRapport('\\ '+reste);
                     WritelnDansRapport('\vspace{0.75in}');
                     WritelnDansRapport('');
                     *)


                      if (nbProblemesTraites >= quelProbleme)
                        then arretPoblemesStepanov := true;
                    end;



                end
              else
                begin
                  WritelnDansRapport('% Parse error for the following line :');
                  WriteDansRapport('% ');
                  InsereTexteDansRapport(@buffer[0],count);
                  WritelnDansRapport('');
                end;
          end;
    end;

  erreurES := CloseFile(inputScript);

  RemettreLeCurseurNormalDeCassio;
end;


procedure AfficheProchainProblemeStepanov;
var err : OSErr;
begin
  err := ProcessProblemesStepanov(pathFichierProblemesStepanov,dernierProblemeStepnanovAffiche + 1);
end;

END.
