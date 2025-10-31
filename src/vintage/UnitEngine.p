UNIT UnitEngine;



INTERFACE


 USES UnitDefCassio, UnitDefEngine, UnitVarGlobalesFinale;




{ fonctions d'initialisation et de fin de module }
procedure InitUnitEngine;
procedure LibereMemoireUnitEngine;
procedure TestEngineUnit;


{ Les fonctions principales de cette unite : elles le lien avec les modules de finale ou de milieu }
function EnginePeutFaireCalculDeFinale(var plateau : plateauOthello; couleur,  alpha, beta, precision, dernierCoup : SInt64; var note, bestMove : SInt64; var meilleureSuite : t_meilleureSuite) : boolean;
function EnginePeutFaireCalculDeMilieu(var plateau : plateauOthello; profondeur, couleur, alpha, beta, dernierCoup : SInt64; var note, bestMove : SInt64; var meilleureSuite : t_meilleureSuite) : boolean;


{ fonctions de tests pour savoir si l'engine est present, vivant, sa vitesse, etc. }
function CassioIsUsingAnEngine(var numero : SInt64) : boolean;
function CanStartEngine(pathMac, arguments : String255) : boolean;
procedure KillAndRestartCurrentEngine;
procedure KillCurrentEngine;
procedure StopCurrentEngine;
procedure SuspendCurrentEngine;
procedure ResumeCurrentEngine;
function CassioIsWaitingAnEngineResult : boolean;
function EngineIsDead : boolean;
procedure SetEngineState(state : SInt64);
function GetEngineState : String255;
function GetSpeedOfEngine : double;
procedure CalculateSpeedOfEngine(const result : EngineResultRec);
procedure CheckIncreaseOfNodesInAnswerFromEngine(const result : EngineResultRec);
function DurationOfLastResultReceivedByEngine : double;
function DateOfLastActivityByEngine : SInt64;
function DateOfLastStartOfEngine : SInt64;
procedure PingEngine;
procedure RelancerDerniereRechercheEngine;


{ Fonctions d'interface texte avec le bundle "EngineBundle.bundle" }
procedure ReceiveEngineData(theCString : Ptr);
procedure SendStringToEngine(s : String255);
procedure InterpretEngineCommand(line : LongString);
procedure SwitchToEngine(whichChannel : SInt16);


{ Lancement d'une recherche pour l'engine }
function FabriquerChaineRequestPourEngine(var search : EngineSearchRec) : String255;
procedure StartEngineSearch(var demande : String255; var search : EngineSearchRec);
procedure EngineNewPosition;


{ Traduction et manipulation des EngineResultRec }
procedure InitResult(var result : EngineResultRec);
function ParserResultLine(const line : LongString; var result : EngineResultRec) : boolean;
function ParseSpeedResult(const line : LongString; var result : EngineResultRec) : boolean;
procedure PatcherLesResultatsEntiersDesRequetesDeMilieu(search : EngineSearchRec; var result : EngineResultRec);
procedure PatcherLesResultatsFlottantsDesRequetesDeFinale(search : EngineSearchRec; var result : EngineResultRec);
procedure EcrireEngineResultDansRapport(var result : EngineResultRec);


{ Gestion d'une file locale des lignes recues en provenance l'engine }
function GetNextResultFromEngine(var line : LongString) : boolean;
procedure PosterUnResultatVenantDeLEngine(const line : LongString);


{ Fonctions utilitaires pour passer des degres mu de Cassio aux precisions @95%, @100% des moteurs (Zebra, Edax, Roxane, etc) }
function PrecisionEngineEnMuString(precision : SInt64) : String255;
function MuStringEnPrecisionEngine(mu : String255) : SInt64;
function IndexDeltaFinaleEnPrecisionEngine(indexDeltaFinale : SInt64) : SInt64;
function ProfondeurMilieuEnPrecisionFinaleEngine(profondeur, empties : SInt64) : SInt64;
function PrecisionFinaleEngineEnProfondeurMilieu(precision, empties : SInt64) : SInt64;


{ La boucle d'attente d'un resultat de l'engine }
function WaitEngineResult(const search : EngineSearchRec; var result : EngineResultRec) : boolean;
procedure AmeliorerResultatGlobalParResultatPartiel(search : EngineSearchRec; var resultGlobal : EngineResultRec; resultPartiel : EngineResultRec);
procedure AnalyserLeResultatGlobal(couleur : SInt64; search : EngineSearchRec; result : EngineResultRec; var rechercheTerminee : boolean; var note : SInt64; var meilleureSuite : t_meilleureSuite);
procedure MettreLeResultatGlobalDansLesVariablesDeCassio(search : EngineSearchRec; result : EngineResultRec; var meilleureSuite : t_meilleureSuite);


{ Fonctions pour manipuler la hash table de l'engine }
procedure EngineInit;
procedure EngineEmptyHash;
procedure EngineBeginFeedHashSequence;
procedure EngineFeedHashValues(var position : PositionEtTraitRec; depth, valeurMin, valeurMax, bestMove : SInt64);
procedure EngineEndFeedHashSequence;
procedure EngineViderFeedHashHistory;


{ Decouverte des moteurs places par l'utilisateur dans le dossier 'Engines' }
function TraiteFichierEngineEtRecursion(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
procedure ChercheEnginesDansDossier(pathDuDossier : String255; var dossierTrouve : boolean);
procedure LecturePreparatoireDossierEngines(pathDuDossierPere : String255 );
function GetEngineBundleName : String255;


{ Liste des moteurs disponibles }
function NumberOfEngines : SInt64;
function GetNumeroOfEngine(nomEngine : String255) : SInt64;
function GetEngineName(numeroEngine : SInt64) : String255;
function GetEnginePath(numeroEngine : SInt64; nomEngine : String255) : String255;
function GetEngineVersion(numeroEngine : SInt64) : String255;
function EngineExists(nomEngine : String255) : boolean;
procedure AddEngine(nomEngine, pathEngine : String255);
procedure SetEngineVersion(numeroEngine : SInt64; version : String255);


{ Fonctions d'affichage dans le rapport }
procedure EnginePrint(const s : String255);
procedure EnginePrintDebug(const s : String255);
procedure EnginePrintWarning(const s : String255);
procedure EnginePrintInput(const s : String255);
procedure EnginePrintOutput(const s : String255);
procedure EnginePrintError(const s : String255);
procedure EnginePrintColoredStringInRapport(const s : String255; whichColor : SInt16; whichStyle : StyleParameter);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Script, Fonts, MacWindows, GestaltEqu, Processes, CFBase, CFString, OSUtils
    , OSAtomic_glue, Multiprocessing, UnitDebuggage, UnitDefParallelisme
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitServicesMemoire, MyFileSystemUtils, basicfile, UnitPositionEtTrait
    , UnitHashTableExacte, MyMathUtils, UnitCarbonisation, UnitRapport, UnitRapportImplementation, UnitGestionDuTemps, UnitStringSet, UnitScannerUtils
    , SNEvents, UnitEnvirons, UnitRetrograde, UnitZoo, UnitLongString, UnitTournoi, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/Engine.lk}
{$ENDC}


{END_USE_CLAUSE}



const nbreMaxEngines = 60;
const kTailleBufferStandardInput = 1024 * 128;

const kValeurMutexPrintColoredStringInRapport  = -1;

var debugEngine : boolean;
    mutex_engine_print_colored_string_in_rapport : SInt64;
    lastTickOfEngineErrorInRapport : SInt64;
    lastSpeedResultReceived : EngineResultRec;

    listOfEngines : record
                      cardinal : SInt64;
                      engines : array[1..nbreMaxEngines] of
                                  record
                                    name    : String255;
                                    path    : String255;
                                    version : String255;
                                  end;
                    end;

    gVitessesInstantaneesEngine : record
                                    compteur : SInt64;  {nbre de vitesses enregistrees }
                                    data : array[1..5] of record
                                                            kilonodes : double;
                                                            time      : double;
                                                          end;
                                  end;

    lignesEnvoyeesParHashFeed : StringSet;
    lignesTraiteesParHashFeed : StringSet;

    FeedHashInfos : record
                      chaineCourante   : String255;
                      positionCourante : PositionEtTraitRec;
                      depthCourante    : SInt64;
                      vMinCourant      : SInt64;
                      vMaxCourant      : SInt64;
                    end;


(*
 *******************************************************************************
 *                                                                             *
 *   InitUnitEngine est appelee par Cassio au demarrage et initialise le       *
 *   module de gestion des moteurs.                                            *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitUnitEngine;
var k : SInt64;
begin
  myStartEnginePtr          := NIL;
  mySuspendEnginePtr        := NIL;
  myResumeEnginePtr         := NIL;
  mySendDataToEnginePtr     := NIL;
  mySetCallBackForEnginePtr := NIL;
  mySwitchToEnginePtr       := NIL;

  mutex_engine_print_colored_string_in_rapport := 0;

  // on implementente la file les resultats comme une liste FIFO
  with engine.fileResultats do
    begin
      mutex_modif_de_la_file := 0;
      cardinal               := 0;
      tete                   := 0;
      queue                  := 0;
      for k := 0 to kNombreMaxResultatsDansFileEngine - 1 do
        InitLongString(resultats[k]);
    end;

  numeroEngineEnCours           := 0;
  listOfEngines.cardinal        := 0;
  engine.nbStartsOfEngine       := 0;
  engine.nbQuitCommandsSent     := 0;
  engine.CassioIsWaitingAResult := false;
  engine.suspendCount           := 0;
  engine.mutex_reception_data   := 0;
  engine.lastDateOfStarting     := TickCount + 360000;
  SetEngineState(ENGINE_KILLED);

  lignesEnvoyeesParHashFeed     := MakeEmptyStringSet;
  lignesTraiteesParHashFeed     := MakeEmptyStringSet;

  debugEngine := false;
  lastTickOfEngineErrorInRapport := 0;
  InitResult(lastSpeedResultReceived);

end;


(*
 *******************************************************************************
 *                                                                             *
 *   LibereMemoireUnitEngine est appelee par Cassio quand il quitte.           *
 *                                                                             *
 *******************************************************************************
 *)
procedure LibereMemoireUnitEngine;
begin

  if (numeroEngineEnCours <> 0) then
    begin

      if (mySetCallBackForEnginePtr <> NIL)
        then mySetCallBackForEnginePtr(NIL);

      KillCurrentEngine;

      DisposeStringSet(lignesEnvoyeesParHashFeed);
      DisposeStringSet(lignesTraiteesParHashFeed);

      // wait 0.25 second
      Wait(0.25);

    end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   NumberOfEngines renvoie le nombre de moteurs que Cassio a trouve dans     *
 *   son répertoire "Engines".                                                 *
 *                                                                             *
 *******************************************************************************
 *)
function NumberOfEngines : SInt64;
begin
  NumberOfEngines := listOfEngines.cardinal;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetEngineName permet de connaitre le nom d'un moteur si on a son numero.  *
 *                                                                             *
 *******************************************************************************
 *)
function GetEngineName(numeroEngine : SInt64) : String255;
begin
  GetEngineName := '';

  if (numeroEngine >= 1) and (numeroEngine <= NumberOfEngines)
    then GetEngineName := listOfEngines.engines[numeroEngine].name;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetNumeroOfEngine est la fonctionalite inverse de la precedente.          *
 *                                                                             *
 *******************************************************************************
 *)
function GetNumeroOfEngine(nomEngine : String255) : SInt64;
var k : SInt64;
    s : String255;
begin

  GetNumeroOfEngine := 0;  // not found

  if (nomEngine <> '') then
    begin
      s := UpperCase(nomEngine, true);
      for k := 1 to NumberOfEngines do
        if (s = UpperCase(listOfEngines.engines[k].name, true)) then
          begin
            GetNumeroOfEngine := k;
            exit;
          end;
   end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetEnginePath renvoie le path (à la mode Mac) d'un moteur, connaissant    *
 *   soit son numero, soit son nom.                                            *
 *                                                                             *
 *******************************************************************************
 *)
function GetEnginePath(numeroEngine : SInt64; nomEngine : String255) : String255;
var k : SInt64;
    s : String255;
begin

  // chercher eventuellement par numero
  if (numeroEngine >= 1) and (numeroEngine <= NumberOfEngines) then
    begin
      GetEnginePath := listOfEngines.engines[numeroEngine].path;
      exit;
    end;

  // sinon, chercher par nom
  if (nomEngine <> '') then
    begin
      s := UpperCase(nomEngine, true);
      for k := 1 to NumberOfEngines do
        if (s = UpperCase(listOfEngines.engines[k].name, true)) then
          begin
            GetEnginePath := listOfEngines.engines[k].path;
            exit;
          end;
    end;

  GetEnginePath := '';
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetEngineVersion renvoie la chaine de version fournie par un moteur donne.*
 *                                                                             *
 *******************************************************************************
 *)
function GetEngineVersion(numeroEngine : SInt64) : String255;
begin
  GetEngineVersion := '';

  if (numeroEngine >= 1) and (numeroEngine <= NumberOfEngines)
    then GetEngineVersion := listOfEngines.engines[numeroEngine].version;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SetEngineVersion permet de stocker la chaine renvoyee par un moteur en    *
 *   reponse a la commande "ENGINE-PROTOCOL version".                          *
 *                                                                             *
 *******************************************************************************
 *)
procedure SetEngineVersion(numeroEngine : SInt64; version : String255);
begin
  version := ReplaceStringOnce(version, '[[0]] version : ' , '');
  version := ReplaceStringOnce(version, '[[1]] version : ' , '');
  version := ReplaceStringOnce(version, 'version : '       , '');
  version := ReplaceStringOnce(version, '[[0]] version: '  , '');
  version := ReplaceStringOnce(version, '[[1]] version: '  , '');
  version := ReplaceStringOnce(version, 'version: '        , '');

  if (numeroEngine >= 1) and (numeroEngine <= NumberOfEngines) then
    begin
      listOfEngines.engines[numeroEngine].version := version;
      EcritGestionTemps;
    end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EngineExists permet de tester pour savoir si un moteur dont on connait    *
 *   le nom (par exemple, trouve dans un fichier de preferences de Cassio)     *
 *   est bien présent)                                                         *
 *                                                                             *
 *******************************************************************************
 *)
function EngineExists(nomEngine : String255) : boolean;
begin
  EngineExists := (GetEnginePath(0,nomEngine) <> '');
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AddEngine est appelee lorsque Cassio parcourt le dossier "Engines" : a    *
 *   chaque fois que Cassio trouve un nouveau moteur, il l'ajoute a sa liste   *
 *   des moteurs connus                                                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure AddEngine(nomEngine, pathEngine : String255);
begin
  with listOfEngines do
    if (cardinal < nbreMaxEngines) and not(EngineExists(nomEngine)) then
      begin
        inc(cardinal);
        engines[cardinal].name    := nomEngine;
        engines[cardinal].path    := pathEngine;
        engines[cardinal].version := '';
      end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   LecturePreparatoireDossierEngines() : fonction appelee au demarrage de    *
 *   Cassio ou juste avant l'affichage du dialogue des preferences pour        *
 *   la liste des moteurs disponibles.                                         *
 *                                                                             *
 *******************************************************************************
 *)
procedure LecturePreparatoireDossierEngines(pathDuDossierPere : String255 );
var trouve : boolean;
    iterateurCassioFolderPaths : String255;
begin

  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(pathDuDossierPere);

  repeat
    ChercheEnginesDansDossier(iterateurCassioFolderPaths + 'Engines',trouve);
    if not(trouve) then ChercheEnginesDansDossier(iterateurCassioFolderPaths + 'Engine',trouve);

    if trouve
      then AddValidCassioFolderPath(iterateurCassioFolderPaths)
      else iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until trouve or (iterateurCassioFolderPaths = '');

end;


(*
 *******************************************************************************
 *                                                                             *
 *   Pour chercher recursivement les moteurs dans un dossier donne.            *
 *                                                                             *
 *******************************************************************************
 *)
procedure ChercheEnginesDansDossier(pathDuDossier : String255; var dossierTrouve : boolean);
var directoryDepart : fileInfo;
    codeErreur : OSErr;
    cheminDirectoryDepartRecursion : String255;
begin
  cheminDirectoryDepartRecursion := pathDuDossier + ':';
  codeErreur := MakeFileInfo(0,0,cheminDirectoryDepartRecursion,directoryDepart);
  codeErreur := SetPathOfScannedDirectory(directoryDepart);
  if (codeErreur = 0) then
    codeErreur := ScanDirectory(directoryDepart,TraiteFichierEngineEtRecursion);
  dossierTrouve := (codeErreur = 0);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   On a trouve un fichier, on cherche a savoir si ça pourait etre un moteur  *
 *   a lancer. Par convention, les executables des moteurs respectant le pro-  *
 *   tocole de Cassio doivent etre places dans la racine de leur repertoire,   *
 *   et s'appeler "engine.sh" . En pratique, ce seront souvent de simples      *
 *   scripts shell qui lanceront un vrai moteur d'othello dont le binaire est  *
 *   compile par l'auteur.                                                     *
 *   Usage :  ./engine.sh n                                                    *
 *            où n est le nombre de processeurs que doit utiliser le moteur.   *
 *                                                                             *
 *******************************************************************************
 *)
function TraiteFichierEngineEtRecursion(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var p : SInt64;
    s, foo : String255;
    pathEngine, nomEngine : String255;
    pathUnix : String255;
    err : OSErr;
begin
 Discard2(fs,pb);


 p := CompterOccurencesDeSousChaine(':',path);

 if not(isFolder) then
   begin
     if (Pos('engine.sh',GetName(fs)) <> 0) then
       begin
         err := FSSpecToFullPath(fs, pathEngine);

         SplitAt(pathEngine,':',foo,pathUnix);            // enlever le nom du disque dur
         pathUnix := ReplaceStringAll(pathUnix,':','/');  // separateurs a la mode UNIX

         s := ReplaceStringOnce(pathEngine, ':engine.sh' , '');
         SplitRightByChar(s,':',foo,nomEngine);
         AddEngine(nomEngine,pathEngine);

       end;
   end;

  TraiteFichierEngineEtRecursion := isFolder and (p < 2);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   Lorsqu'un moteur est en train de calculer pour nous, il est utile de      *
 *   lui envoyer chaque seconde un message message : soit un get-search-infos, *
 *   auquel cas il doit reppondre par le nombre de noeuds et le temps de re-   *
 *   cherche; soit un simple retour charriot, auquel cas il doit repondre par  *
 *   "ok." ou "ready." suivant qu'il est en train de calculer ou d'attendre    *
 *   la prochaine requete.                                                     *
 *                                                                             *
 *******************************************************************************
 *)
procedure PingEngine;
var t : SInt64;
begin
  t := Tickcount;
  if (t - engine.lastDateOfActivity > 70) and
     (t - engine.lastDateOfPinging > 70)
      then
    begin
      engine.lastDateOfPinging := t;

      if engine.CassioIsWaitingAResult
        then SendStringToEngine('ENGINE-PROTOCOL  get-search-infos')
        else SendStringToEngine('');

    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineIsDead : fonction pour tester si le moteur en cours semble mort.    *
 *   Dans une bonne implementation, il faudrait sans doute essayer de le tuer  *
 *   mechamment s'il ne répond plus (il est sans doute plante).                *
 *                                                                             *
 *******************************************************************************
 *)
function EngineIsDead : boolean;
var dead : boolean;
begin

  dead := (engine.state = ENGINE_RUNNING) and
          (Tickcount - engine.lastDateOfPinging < 60) and  // 1 seconde
          (Tickcount - engine.lastDateOfActivity > 1800) and  // 30 secondes
          (Tickcount - engine.lastDateOfSearchStart > 1800);  // 30 secondes

  if dead and engine.CassioIsWaitingAResult then
    begin
      EnginePrint('Engine seems dead, trying to kill it properly');
      KillCurrentEngine;
    end;

  EngineIsDead := dead;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SetEngineState : procedure pour changer la connaissance dans Cassio de    *
 *                    l'etat du moteur.                                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure SetEngineState(state : SInt64);
begin
  engine.state := state;

  if (state = ENGINE_KILLED)
    then mySendDataToEnginePtr     := NIL;

  if (state = ENGINE_KILLED) or
     ((state = ENGINE_STOPPED) and (interruptionReflexion <> interruptionPositionADisparuDuZoo))
    then EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo('SetEngineState');
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetEngineState : une fonction de debuggage.                               *
 *                                                                             *
 *******************************************************************************
 *)
function GetEngineState : String255;
begin
  case engine.state of
    ENGINE_STARTING : GetEngineState := 'ENGINE_STARTING';
    ENGINE_RUNNING  : GetEngineState := 'ENGINE_RUNNING';
    ENGINE_STOPPED  : GetEngineState := 'ENGINE_STOPPED';
    ENGINE_KILLED   : GetEngineState := 'ENGINE_KILLED';
    otherwise         GetEngineState := 'UNKNOWN ENGINE STATE !!!';
  end; {case}
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   KillCurrentEngine : on essaye de demander poliment au moteur de quitter.  *
 *   Attention : penser à bien attendre un petit peu apres avoir appele cette  *
 *   fonction, sinon Cassio risque de planter car le moteur va répondre "bye." *
 *   ou quelque chose comme ça et il faut que le bundle ait toujours son       *
 *   callback dans Cassio !                                                    *
 *                                                                             *
 *******************************************************************************
 *)
procedure KillCurrentEngine;
begin
  inc(engine.nbQuitCommandsSent);
  engine.lastDateOfStarting := TickCount + 360000;
  SendStringToEngine('ENGINE-PROTOCOL quit');
  EngineViderFeedHashHistory;
  SetEngineState(ENGINE_KILLED);
end;


 (*
 *******************************************************************************
 *                                                                             *
 *   KillAndRestartCurrentEngine : pour faire des tests de vitesse, on veut    *
 *   parfois etre sur que la table de hachage du moteur est videe... Cette     *
 *   fonction fait cela avec une methode brutale qui consiste a quitter le     *
 *   moteur puis a le relancer ! A utiliser avec parcimonie, car cela prend    *
 *   du temps.                                                                 *
 *                                                                             *
 *******************************************************************************
 *)
procedure KillAndRestartCurrentEngine;
begin

  // arreter l'ancien moteur
  SwitchToEngine(0);
  engine.state := ENGINE_RUNNING;
  SendStringToEngine('ENGINE-PROTOCOL stop');
  engine.state := ENGINE_RUNNING;
  KillCurrentEngine;
  Wait(0.25);

  // relancer le meme
  if (numeroEngineEnCours > 0) and CanStartEngine(GetEnginePath(numeroEngineEnCours,''), IntToStr(numProcessors))
    then Wait(1.0);
end;


 (*
 *******************************************************************************
 *                                                                             *
 *   StopCurrentEngine : on interrompt la recherche en cours dans le moteur.   *
 *                                                                             *
 *******************************************************************************
 *)
procedure StopCurrentEngine;
begin
  if (engine.state <> ENGINE_KILLED) then
    begin
      SendStringToEngine('ENGINE-PROTOCOL stop');
      SetEngineState(ENGINE_STOPPED);
    end;
end;


 (*
 *******************************************************************************
 *                                                                             *
 *   SuspendCurrentEngine : on essaye de suspendre le moteur (au sens UNIX).   *
 *   Note : un probleme de l'appel actuel des moteurs via le script shell      *
 *          "engine.sh" est que la suspension du script ne va pas suspendre    *
 *          le vrai moteur, qui continue a aller à 100% du CPU... Aussi, pour  *
 *          l'instant, j'utilise le "suspend du pauvre" en arretant juste la   *
 *          recherche du moteur brutalement :-)                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure SuspendCurrentEngine;
begin

  inc(engine.suspendCount);
  StopCurrentEngine;

  (*
  if (mySuspendEnginePtr <> NIL) then
    begin
      EnginePrint('FIXME : Appel de mySuspendEnginePtr dans Cassio');
      mySuspendEnginePtr;
    end;
  *)
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   ResumeCurrentEngine : on continue l'execution du moteur (au sens UNIX).   *
 *   Note : un probleme de l'appel actuel des moteurs via le script shell      *
 *          "engine.sh" est que la suspension du moteur a forcément été faite  *
 *          par le "suspend du pauvre" (cf SuspendCurrentEngine()). Aussi,     *
 *          pour l'instant, le "resume" est-il implemente en demandant juste   *
 *          au moteur de recommencer la recherche interrompue, avec l'espoir   *
 *          que le moteur pourra utiliser certains de ses resultats partiels   *
 *          encore stockes dans sa table de hachage (c'est mieux que rien).    *
 *                                                                             *
 *******************************************************************************
 *)
procedure ResumeCurrentEngine;
begin

  dec(engine.suspendCount);
  if (engine.suspendCount = 0)
    then RelancerDerniereRechercheEngine;

  (*
  if (myResumeEnginePtr <> NIL) then
    begin
      myResumeEnginePtr;
      EnginePrint('FIXME : Appel de myResumeEnginePtr dans Cassio');
    end;
  *)
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   RelancerDerniereRechercheDeEngine : relancer la derniere requete du       *
 *   moteur.
 *                                                                             *
 *******************************************************************************
 *)
procedure RelancerDerniereRechercheEngine;
begin
  if (numeroEngineEnCours <> 0) then
    StartEngineSearch(engine.lastCommandSent,engine.lastSearchSent);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EcrireEngineResultDansRapport : pour le debugage d'un resultat recu       *
 *   en provenance de l'un des moteurs.                                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure EcrireEngineResultDansRapport(var result : EngineResultRec);
begin

  EnginePrint(PositionEtTraitEnString(result.position));
  EnginePrint('type = ' + IntToStr(result.typeResult));
  EnginePrint('candidateMove = ' + IntToStr(result.candidateMove));
  EnginePrint('depth = ' + IntToStr(result.depth));
  EnginePrint('precision = ' + IntToStr(result.precision));
  EnginePrint('colorOfValue = ' + IntToStr(result.colorOfValue));
  EnginePrint('minorantOfValue = ' + IntToStr(result.minorantOfValue));
  EnginePrint('majorantOfValue = ' + IntToStr(result.majorantOfValue));
  EnginePrint('line = '+result.line);
  EnginePrint('kilonodes = ' + ReelEnStringAvecDecimales(result.kilonodes,0));
  EnginePrint('time = ' + ReelEnStringAvecDecimales(result.time,3));

end;




(*
 *******************************************************************************
 *                                                                             *
 *   Fonction utilitaire pour transformer une precision Zebra (en pourcentage) *
 *   en une precision Cassio (en mu).                                          *
 *                                                                             *
 *******************************************************************************
 *)
function PrecisionEngineEnMuString(precision : SInt64) : String255;
var dist,distMin, i : SInt64;
    mu : String255;
begin

  if (precision <= 0) or (precision >= 100) then precision := 100;

  mu := '0,'+IntToStr(kDeltaFinaleInfini);

  distMin := 1000000;
  for i := 1 to nbreDeltaSuccessifs do
    begin
      dist := abs(precision - deltaSuccessifs[i].selectiviteZebra);
      if (dist < distMin) then
      begin
        distMin := dist;
        mu := '0,'+ IntToStr(deltaSuccessifs[i].valeurDeMu);
      end;
    end;

  PrecisionEngineEnMuString := mu;

end;




(*
 *******************************************************************************
 *                                                                             *
 *   Fonction utilitaire pour transformer une chaine de caracteres decrivant   *
 *   une precison Cassio (en mu) en une precision zebra (en pourcentage).      *
 *                                                                             *
 *******************************************************************************
 *)
function MuStringEnPrecisionEngine(mu : String255) : SInt64;
var left, right, cut : String255;
    muMax, dist, distMin, i: SInt64;
begin
  SplitAt(mu, ',', left, right);

  muMax := StrToInt32(right);

  cut := '';

  distMin := 1000000000;
  for i := 1 to nbreDeltaSuccessifs do
    begin

      dist := abs(muMax - deltaSuccessifs[i].valeurDeMu);

      if (dist < distMin) then
      begin
        distMin := dist;
        cut := IntToStr(deltaSuccessifs[i].selectiviteZebra) ;
      end;
    end;

  if (cut = '') then
    begin
      EnginePrintError('ASSERT dans MuStringEnPrecisionEngine');
      cut := '100';
    end;

  MuStringEnPrecisionEngine := StrToInt32(cut);

end;


(*
 *******************************************************************************
 *                                                                             *
 *   Fonction utilitaire pour transformer une precision Cassio (en mu) en une  *
 *   precision zebra (en pourcentage).                                         *
 *                                                                             *
 *******************************************************************************
 *)
function IndexDeltaFinaleEnPrecisionEngine(indexDeltaFinale : SInt64) : SInt64;
begin

  IndexDeltaFinaleEnPrecisionEngine := MuStringEnPrecisionEngine('0,'+IntToStr(deltaSuccessifs[indexDeltaFinale].valeurDeMu));

end;


(*
 *******************************************************************************
 *                                                                             *
 *   Dans certains cas, (typiquement, quand profondeur sera > à empties),      *
 *   Cassio demandera une recherche de finale avec une certaine precision      *
 *   (dependant de la profondeur) plutot qu'une recherche de milieu.           *
 *                                                                             *
 *******************************************************************************
 *)
function ProfondeurMilieuEnPrecisionFinaleEngine(profondeur, empties : SInt64) : SInt64;
var precision : SInt64;
begin
  precision := Min(100, 72 + 2*(profondeur - empties));
  ProfondeurMilieuEnPrecisionFinaleEngine := precision;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   La fonction réciproque de la précédente.                                  *
 *                                                                             *
 *******************************************************************************
 *)
function PrecisionFinaleEngineEnProfondeurMilieu(precision, empties : SInt64) : SInt64;
var profondeur : SInt64;
begin
  profondeur := Max(empties, empties + ((precision - 72) div 2));
  PrecisionFinaleEngineEnProfondeurMilieu := profondeur;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   PatcherLesResultatsEntiersDesRequetesDeMilieu() : transforme un resultat  *
 *   donné sous forme d'un encadrement entier en encadrement de milieu.        *
 *                                                                             *
 *******************************************************************************
 *)
procedure PatcherLesResultatsEntiersDesRequetesDeMilieu(search : EngineSearchRec; var result : EngineResultRec);
begin
  if (CassioIsWaitingAnEngineResult)
     and (search.typeDeRecherche = ReflMilieu)
     and (result.typeResult = ReflParfait)
     and (SamePositionEtTrait(result.position, search.position))
    then
      begin
        result.minorantOfValue := 100 * result.minorantOfValue;
        result.majorantOfValue := 100 * result.majorantOfValue;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   PatcherLesResultatsFlottantsDesRequetesDeFinale() : transforme un         *
 *   resultats de milieu en résultat de finale.                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure PatcherLesResultatsFlottantsDesRequetesDeFinale(search : EngineSearchRec; var result : EngineResultRec);
var v : SInt64;
begin
  if (CassioIsWaitingAnEngineResult)
     and (search.typeDeRecherche = ReflParfait)
     and (result.typeResult = ReflMilieu)
     and (SamePositionEtTrait(result.position, search.position))
    then
      with result do
        begin

          if (minorantOfValue = majorantOfValue)
            then
              begin
                v := minorantOfValue;
                if ((v mod 100) = 0)
                  then
                    begin
                      minorantOfValue := (v div 100);
                      majorantOfValue := (v div 100);
                    end
                  else
                    begin
                      if (v > 0)
                        then
                          begin
                            minorantOfValue := (v div 100);
                            majorantOfValue := minorantOfValue + 1;
                          end
                        else
                          begin
                            majorantOfValue := (v div 100);
                            minorantOfValue := majorantOfValue - 1;
                          end;
                    end;
              end
            else
              begin
                if (minorantOfValue < 0) and (majorantOfValue <= 0) then
                  begin
                    minorantOfValue := ((minorantOfValue - 99) div 100);
                    majorantOfValue := (majorantOfValue div 100);
                  end
                else if (minorantOfValue < 0) and (majorantOfValue > 0) then
                  begin
                    minorantOfValue := ((minorantOfValue - 99) div 100);
                    majorantOfValue := ((majorantOfValue + 99) div 100);
                  end
                else if (minorantOfValue >= 0) and (majorantOfValue > 0) then
                  begin
                    minorantOfValue := (minorantOfValue div 100);
                    majorantOfValue := ((majorantOfValue + 99) div 100);
                  end
                else if (minorantOfValue >= 0) and (majorantOfValue <= 0) then
                  begin
                    minorantOfValue := (minorantOfValue div 100);
                    majorantOfValue := (majorantOfValue div 100);
                    EnginePrintError('ASSERT : should never happen (1) in PatcherLesResultatsFlottantsDesRequetesDeFinale() !');
                  end
                else
                  begin
                    EnginePrintError('ASSERT : should never happen (2) in PatcherLesResultatsFlottantsDesRequetesDeFinale() !');
                  end;
              end;

          if (minorantOfValue < -64) then minorantOfValue := -64;
          if (majorantOfValue >  64) then majorantOfValue :=  64;

          if (minorantOfValue > majorantOfValue) then
            EnginePrintError('ASSERT : (result.minorantOfValue > result.majorantOfValue) dans PatcherLesResultatsFlottantsDesRequetesDeFinale !');
        end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   ParserResultLine : transformation d'une ligne de texte de resultat en     *
 *   un enregistrement Pascal contenant les infos.                             *
 *                                                                             *
 *******************************************************************************
 *)
function ParserResultLine(const line : LongString; var result : EngineResultRec) : boolean;
var oldParsingSet : SetOfChar;
    s1,s2,s3,s4,s5,s6,s7,s8,reste : String255;
    c1,c2,c3,c4,c5 : String255;
    aux : EngineResultRec;
    temp : SInt64;


  (* fonction locale *)
  procedure ParseError(message : String255);
  begin
    EnginePrintError('commande = '+engine.lastCommandSent);
    EnginePrintError('PARSE ERROR : '+message);
    EnginePrintError('reponse = '+line.debutLigne);
    SetParserDelimiters(oldParsingSet);
    exit;
  end;



begin
  ParserResultLine := false;


  if (LENGTH_OF_STRING(line.debutLigne) > 80) then
    begin

      // les champs des resultats sont séparés par des virgules

      oldParsingSet := GetParserDelimiters;
      SetParserDelimiters([',']);

      Parse5(line.debutLigne,s1,s2,s3,s4,s5,reste);
      Parse3(reste + line.finLigne,s6,s7,s8,reste);


      SetParserDelimiters([' ','@','%',tab]);


      // la position ?
      if not(ParsePositionEtTrait(s1, aux.position))
        then ParseError('impossible de parser la position dans un resultat de l''engine');

      // le coup proposé ?
      Parse2(s2,c1,c2,reste);

      if (c1 <> 'move')
        then ParseError('impossible de parser le coup dans un resultat de l''engine');

      aux.candidateMove := StringEnCoup(c2);


      // la profondeur ?

      Parse2(s3,c1,c2,reste);

      if (c1 <> 'depth')
        then ParseError('impossible de parser la profondeur dans un resultat de l''engine');

      aux.depth := StrToInt32(c2);

      // la precision ?

      Parse(s4,c1,reste);

      aux.precision := StrToInt32(c1);

      // la couleur pour laquelle les resultats sont donnes ?

      if (Pos('W',s5) > 0)
        then aux.colorOfValue := pionBlanc
        else aux.colorOfValue := pionNoir;

      // l'encadrement des valeurs ?

      SetParserDelimiters([' ','W','B',tab]);

      Parse5(s5,c1,c2,c3,c4,c5,reste);

      if ((c2 <> '<=') and (c2 <> '<')) or (c3 <> 'v') or ((c4 <> '<=') and (c4 <> '<'))
        then ParseError('impossible de parser l''encadrement des valeurs dans un resultat de l''engine');


      if (Pos('.',c1) = 0) then c1 := c1 + '.00';
      if (Pos('.',c5) = 0) then c5 := c5 + '.00';


      if (Pos('.',c1) > 0) or (Pos('.',c5) > 0)
        then aux.typeResult := ReflMilieu
        else aux.typeResult := ReflParfait;


      if (Pos('.',c1) > 0)
        then aux.minorantOfValue := Trunc(100.0 * StringSimpleEnReel(c1))
        else
          if (aux.typeResult = ReflMilieu)
            then aux.minorantOfValue := 100 * StrToInt32(c1)
            else aux.minorantOfValue := StrToInt32(c1);

      if (Pos('.',c5) > 0)
        then aux.majorantOfValue := Trunc(100.0 * StringSimpleEnReel(c5))
        else
          if (aux.typeResult = ReflMilieu)
            then aux.majorantOfValue := 100 * StrToInt32(c5)
            else aux.majorantOfValue := StrToInt32(c5);


      if (c2 = '<') then inc(aux.minorantOfValue);
      if (c4 = '<') then dec(aux.majorantOfValue);


      if (aux.typeResult = ReflMilieu)  then
        begin
          aux.minorantOfValue := Max(aux.minorantOfValue , -6400);
          aux.minorantOfValue := Min(aux.minorantOfValue ,  6400);
          aux.majorantOfValue := Max(aux.majorantOfValue , -6400);
          aux.majorantOfValue := Min(aux.majorantOfValue ,  6400);
        end;
      if (aux.typeResult = ReflParfait)  then
        begin
          aux.minorantOfValue := Max(aux.minorantOfValue , -64);
          aux.minorantOfValue := Min(aux.minorantOfValue ,  64);
          aux.majorantOfValue := Max(aux.majorantOfValue , -64);
          aux.majorantOfValue := Min(aux.majorantOfValue ,  64);
        end;


      if ((aux.colorOfValue = pionBlanc) and (GetTraitOfPosition(aux.position) = pionNoir)) or
         ((aux.colorOfValue = pionNoir)  and (GetTraitOfPosition(aux.position) = pionBlanc)) then
         begin
           aux.colorOfValue    := GetTraitOfPosition(aux.position);
           temp                :=  aux.minorantOfValue;
           aux.minorantOfValue := -aux.majorantOfValue;
           aux.majorantOfValue := -temp;
         end;

      // la ligne principale ?

      aux.line := UpperCase(s6,true);
      repeat
        s6 := aux.line;
        aux.line := ReplaceStringOnce(aux.line, 'PA' , '');
      until (s6 = aux.line);


      if (StringEnCoup(aux.line) <> aux.candidateMove) then
        ParseError('the candidate move in result must always be the first move of the principal variation line !');

      // le nombre de noeuds ?

      aux.kilonodes := 0.0;
      if (s7 <> '')
        then
          begin
            Parse2(s7,c1,c2,reste);
            c3 := LeftStr(c2, LENGTH_OF_STRING(c2) - 3);

            if (c1 <> 'node')
              then ParseError('impossible de parser le nombre de noeuds dans un resultat de l''engine');

            if (c3 = '')
              then aux.kilonodes := 1.0
              else aux.kilonodes := 1.0 + StringSimpleEnReel(c3);
          end;


      // le temps ?

      aux.time := 0.0;
      if (s8 <> '') then
        begin
          Parse2(s8,c1,c2,reste);

          if (c1 <> 'time')
            then ParseError('impossible de parser le temps dans un resultat de l''engine');

          aux.time := StringSimpleEnReel(c2);
        end;

      // tout a l'air bon, hein
      result := aux;
      ParserResultLine := true;

      SetParserDelimiters(oldParsingSet);

    end;


end;



(*
 *******************************************************************************
 *                                                                             *
 *   ParseSpeedResult : transformation d'une ligne de texte d'infos de vitesse *
 *   en un enregistrement Pascal contenant les infos.                          *
 *                                                                             *
 *******************************************************************************
 *)
function ParseSpeedResult(const line : LongString; var result : EngineResultRec) : boolean;
var oldParsingSet : SetOfChar;
    s7,s8,reste : String255;
    c1,c2,c3 : String255;


  (* fonction locale *)
  procedure ParseError(message : String255);
  begin
    EnginePrintError('commande = ' + engine.lastCommandSent);
    EnginePrintError('PARSE ERROR : '+message);
    EnginePrintError('reponse = '+line.debutLigne);
    SetParserDelimiters(oldParsingSet);
    exit;
  end;



begin
  ParseSpeedResult := false;


  if (LENGTH_OF_STRING(line.debutLigne) > 10) then
    begin

      // les champs des resultats sont séparés par des virgules

      oldParsingSet := GetParserDelimiters;
      SetParserDelimiters([',']);

      Parse2(line.debutLigne,s7,s8,reste);

      SetParserDelimiters([' ','@','%',tab]);

      // le nombre de noeuds ?

      result.kilonodes := 0.0;
      if (s7 <> '')
        then
          begin
            Parse2(s7,c1,c2,reste);
            c3 := LeftStr(c2, LENGTH_OF_STRING(c2) - 3);

            if (c1 <> 'node')
              then ParseError('impossible de parser le nombre de noeuds dans un resultat de l''engine');

            if (c3 = '')
              then result.kilonodes := 1.0
              else result.kilonodes := 1.0 + StringSimpleEnReel(c3);
          end;


      // le temps ?

      result.time := 0.0;
      if (s8 <> '') then
        begin
          Parse2(s8,c1,c2,reste);

          if (c1 <> 'time')
            then ParseError('impossible de parser le temps dans un resultat de l''engine');

          result.time := StringSimpleEnReel(c2);
        end;

      // tout a l'air bon, hein
      ParseSpeedResult := true;

      SetParserDelimiters(oldParsingSet);

    end;


end;


(*
 *******************************************************************************
 *                                                                             *
 *   Lecture de la prochaine ligne en provenance du moteur, apres serialisa-   *
 *   tion du buffer de stdin. La serialisation est implementee comme une file  *
 *   FIFO de kNombreMaxResultatsDansFileEngine chaines de caracteres, et cette *
 *   fonction extrait la plus ancienne chaine de caracteres dans cette file.   *
 *                                                                             *
 *******************************************************************************
 *)
function GetNextResultFromEngine(var line : LongString) : boolean;
begin
  GetNextResultFromEngine := false;
  with engine.fileResultats do
      begin
         if cardinal > 0 then
           begin
             if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexLectureResultatEngine, mutex_modif_de_la_file) <> 0 ) then
               begin

                 if cardinal > 0 then
                   begin

                     // GERER L'INDEX D'EXTRACTION EN QUEUE DANS LA FILE
                     queue := queue + 1;
                     if (queue >= kNombreMaxResultatsDansFileEngine) then queue := queue - kNombreMaxResultatsDansFileEngine;
                     cardinal := cardinal - 1;


                     // LIRE LE RESULTAT EN QUEUE DE LA FILE ET LE TRANSMETTRE
                     line := resultats[queue];

                     // EFFACER CE RESULTAT DANS LA FILE
                     InitLongString(resultats[queue]);   // il a été lu, hein

                     OS_MEMORY_BARRIER;
                     GetNextResultFromEngine := true;
                   end;  { if cardinal > 0 }

                 mutex_modif_de_la_file := 0;
               end;  { if ATOMIC_COMPARE_AND_SWAP }
           end; { if cardinal > 0 }
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   PosterUnResultatVenantDeLEngine : la lecture du buffer de stdin vient de  *
 *   trouver une ligne complete avec un resultat, on l'envoie donc dans la     *
 *   file FIFO.                                                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure PosterUnResultatVenantDeLEngine(const line : LongString);
var ecrit : boolean;
begin
  ecrit := false;
  with engine.fileResultats do
    begin
      while not(ecrit) do
          begin
            if (cardinal < kNombreMaxResultatsDansFileEngine) then
              begin
                if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexEcritureResultatEngine, mutex_modif_de_la_file) <> 0 ) then
                  begin
                    if (cardinal < kNombreMaxResultatsDansFileEngine) then
                      begin

                        // GERER L'INDEX D'INSERTION A LA TETE DE LA FILE
                        tete := tete + 1;
                        if tete >= kNombreMaxResultatsDansFileEngine then tete := tete - kNombreMaxResultatsDansFileEngine;
                        cardinal := cardinal + 1;


                        // PLACER LE RESULTAT A LA TETE DE LA FILE
                        resultats[tete]   := line;

                        OS_MEMORY_BARRIER;
                        ecrit := true ;
                      end;  { cardinal < kNombreMaxResultasDansUneFile }

                    mutex_modif_de_la_file := 0;
                  end;  { if ATOMIC_COMPARE_AND_SWAP_BARRIER }
              end;  { if cardinal < kNombreMaxResultasDansUneFile }

            if not(ecrit) then
              begin
                EnginePrintError('ERROR : impossible d''ecrire un resultat de l''engine dans la file des resultats, qui est trop petite !!');
                ecrit := true;
              end;
          end;  { while not(ecrit) }
    end;  { with engine.fileResultats do }
end;


(*
 *******************************************************************************
 *                                                                             *
 *   InterpretEngineCommand : reagit correctement à la reception d'une ligne   *
 *   en provenance du moteur, soit en mettant à jour Cassio après un PING      *
 *   reussi, soit en mettant la ligne dans la file des resultats si c'est un   *
 *   resultat pertinent.                                                       *
 *                                                                             *
 *******************************************************************************
 *)
procedure InterpretEngineCommand(line : LongString);
var theResult : EngineResultRec;
    s : String255;
    stringIsPoint, stringIsReady, stringIsOk, stringIsStarted : boolean;
    canal, moteur : SInt64;
begin

  s := line.debutLigne;


  (* check the results of requests when they are short strings (ready, ok, pings, etc.) *)
  if (LENGTH_OF_STRING(s) <= 14) then
    begin
      stringIsPoint   := (s = '.');
      stringIsReady   := not(stringIsPoint) and (Pos('ready.',s) > 0);
      stringIsOk      := not(stringIsPointorstringIsReady) and (Pos('ok.',s) > 0);
      stringIsStarted := not(stringIsPointorstringIsReadyorstringIsOk) and (Pos('Engine started',s) > 0);

      if stringIsPoint or stringIsReady or stringIsOk or stringIsStarted then
        begin
          if ((engine.state = ENGINE_STARTING) and stringIsReady) and
             (debugEngine or debuggage.engineInput or debuggage.engineOutput or InfosTechniquesDansRapport)
             then EnginePrint('OK, confirmation que le moteur a démarré');

          if stringIsReady then
            if engine.CassioIsWaitingAResult
              then PosterUnResultatVenantDeLEngine(line)
              else engine.readyReceived := true;

          if (stringIsPoint or stringIsReady or stringIsOk) then
            begin
              SetEngineState(ENGINE_RUNNING);
            end;

          engine.lastDateOfActivity := TickCount;

          exit;
        end;
    end;

  (* interpret speed and nodes results *)
  if ((s[1] = 'n') and (LENGTH_OF_STRING(s) <= 60) and (Pos('node',s) = 1)) then
    if ParseSpeedResult(line,theResult) then
      begin
        CalculateSpeedOfEngine(theResult);
        CheckIncreaseOfNodesInAnswerFromEngine(theResult);
        SetEngineState(ENGINE_RUNNING);
        engine.lastDateOfActivity := TickCount;
        exit;
      end;


  (* write DEBUG messages sent by the engines back in Cassio *)
  if ((s[1] = 'D') and (Pos('DEBUG',s) = 1)) then
    begin
      EnginePrintDebug(s);
      exit;
    end;


  (* write WARNING messages sent by the engines back in Cassio *)
  if ((s[1] = 'W') and (Pos('WARNING',s) = 1)) then
    begin
      EnginePrintWarning(s);
      exit;
    end;

  (* understand version information sent by the engines *)
  if ((s[1] = '[') and ((Pos('version: ',s) >= 1) or (Pos('version : ',s) >= 1))) then
    begin
      canal := StrToInt32(CharToString(s[3]));
      moteur := NumeroDuMoteurParlantDansCeCanal(canal);
      if moteur > 0
        then SetEngineVersion(moteur,s)
        else SetEngineVersion(numeroEngineEnCours,s);
      exit;
    end;


  (* check if the engine crashed or has been killed by the Unix kernel *)
  if (s[1] <> 'X') and
     (s[1] <> 'O') and
     (s[1] <> '-') and
     ((Pos('Killed', s) > 0)
      or (Pos('Segmentation fault', s) > 0)
      or (Pos('Bus error', s) > 0)
      or ((Pos('Engine terminated', s) > 0))
      ) then
    begin
      if (Pos('Killed', s) > 0)
        then EnginePrint('The engine seems to have been killed by the Unix kernel') else

      if (Pos('Segmentation fault', s) > 0) or (Pos('Bus error', s) > 0)
        then EnginePrint('The engine seems to have had a problem, as Apollo 13 said');

      if Pos('Engine terminated', s) <= 0
        then
          SetEngineState(ENGINE_KILLED)
        else
          begin
            dec(engine.nbQuitCommandsSent);
            if (engine.nbQuitCommandsSent < 0) then
              SetEngineState(ENGINE_KILLED);
          end;

      EcritGestionTemps;
      exit;
    end;



  (* try to parse othello results *)
  if (LENGTH_OF_STRING(s) >= 65)
      and engine.CassioIsWaitingAResult
      and ParserResultLine(line,theResult) then
      begin
        // Filtrer les resultats : ne nous interessent a priori (dans cette
        // premiere implementation) que les resultats exactement de la
        // position dont on a demande la resolution, et pas les resultats
        // partiels donnes par exemple par Roxane.

        if (theResult.depth >= engine.lastSearchSent.depth) and
           SamePositionEtTrait(theResult.position,engine.lastSearchSent.position)
          then PosterUnResultatVenantDeLEngine(line);

        exit;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   ReceiveEngineData : fonction de callback passee au bundle intermediaire   *
 *   EngineBundle.bundle, chargee de lire les octets sur le buffer d'entree    *
 *   de stdin et de transfomer le flux d'octets en lignes distinctes.          *
 *                                                                             *
 *******************************************************************************
 *)
procedure ReceiveEngineData(theCString : Ptr);
type buffer    = packed array[0 .. kTailleBufferStandardInput - 1] of char;
     bufferPtr = ^buffer;
var i : SInt64;
    myBuffer : bufferPtr;
    c : char;
begin

  with engine do
    begin

      while (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexReceptionDataEngine, mutex_reception_data) = 0)
        do;

      myBuffer := bufferPtr(theCString);

      i := 0;
      repeat
        c := myBuffer^[i];

        if (c = lf)
          then
            begin
              if (lastStringReceived.debutLigne <> '') then
                begin
                  if debugEngine or debuggage.engineInput then
                    EnginePrintInput(lastStringReceived.debutLigne);

                  InterpretEngineCommand(lastStringReceived);
                  InitLongString(lastStringReceived);
                end;
            end
          else
            begin
              if (c <> chr(0)) then
                AppendCharToLongString(lastStringReceived, c);
            end;

        inc(i);

        if (c = chr(0)) then Leave;

      until (i >= kTailleBufferStandardInput);

      if (i >= kTailleBufferStandardInput) then
        EnginePrintError('ERROR dans ReceiveEngineData : le buffer est trop petit');

      mutex_reception_data := 0;

  end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SendStringToEngine : envoi d'une commande au moteur. On envoie la chaine  *
 *   caracteres au bundle intermediaire EngineBundle.bundle via la fonction    *
 *   mySendDataToEnginePtr (pointeur de fonction dans la librairie externe     *
 *   du bundle).                                                               *
 *                                                                             *
 *******************************************************************************
 *)
procedure SendStringToEngine(s : String255);
var data : CFStringRef;
begin
  if (mySendDataToEnginePtr <> NIL) and (engine.state <> ENGINE_KILLED) then
    begin

      if (debugEngine or debuggage.engineOutput) and (s <> '') then
        begin
          if (s <> 'ENGINE-PROTOCOL  get-search-infos')
            then EnginePrintOutput(s)
            else
              if (s <> engine.lastStringSent)
                then EnginePrintOutput(s + '      (note: repeated command, only first occurence shown)');
        end;

      if (s <> '') then
        engine.lastStringSent := s;


      data := MakeCFSTR(s);
      mySendDataToEnginePtr(data);
      CFRelease(CFTypeRef(data));
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetEngineBundleName : nom du bundle intermediaire de communication.       *
 *   Dans le cas où Cassio est un bundle applicatif (Cassio.app), on renvoie   *
 *   seulement "EngineBundle.bundle" et GetFunctionPointerFromPrivateBundle()  *
 *   saura le chercher dans le dossier "Frameworks" de l'application. Mais si  *
 *   est une applicatiopn PPC, l'utilisateur doit placer le bundle dans le     *
 *   dossier des fichiers auxiliaires de Cassio et on renvoie la path complet  *
 *   vers le bundle EngineBundle.bundle                                        *
 *                                                                             *
 *******************************************************************************
 *)
function GetEngineBundleName : String255;
var bundlePathMac,bundlePathUnix,foo, result : String255;
begin
  if CassioEstUnBundleApplicatif
    then result := 'EngineBundle.bundle'
    else
      begin
        bundlePathMac := pathDossierFichiersAuxiliaires + ':Frameworks:EngineBundle.bundle';
        bundlePathMac := ReplaceStringAll(bundlePathMac,'/',':');    // separateurs a la mode Mac
        SplitAt(bundlePathMac,':',foo,bundlePathUnix);               // enlever le nom du disque dur
        bundlePathUnix := ReplaceStringAll(bundlePathUnix,':','/');  // separateurs a la mode UNIX
        result := bundlePathUnix;
      end;
  GetEngineBundleName := result;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SwitchToEngine : le bundle intermediaire EngineBundle.bundle supporte     *
 *   deux moteurs simultanes. On peut selectionner celui auquel on veut parler *
 *   en appelant SwitchToEngine(0) ou SwitchToEngine(1) avant d'employer une   *
 *   autre fonction de ce module.                                              *
 *                                                                             *
 *******************************************************************************
 *)
procedure SwitchToEngine(whichChannel : SInt16);
begin

  if (mySwitchToEnginePtr = NIL) then
    mySwitchToEnginePtr := SwitchToEngineProcPtr(GetFunctionPointerFromPrivateBundle( GetEngineBundleName ,'SwitchToEngine'));

  if (mySwitchToEnginePtr <> NIL) then
    if (whichChannel >= 0) and (whichChannel <= 1)
      then mySwitchToEnginePtr(whichChannel);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   CanStartEngine : fonction pour essayer de lancer un moteur. Le premier    *
 *   argument est le path (au sens Mac) vers l'executable, et le deuxieme la   *
 *   chaine de caracteres des arguments sur la ligne de commande.              *
 *                                                                             *
 *******************************************************************************
 *)
function CanStartEngine(pathMac, arguments : String255) : boolean;
var pathUnix, foo : String255;
    CFpath, CFarguments : CFStringRef;
    fic : basicfile;
    i, ok : SInt64;
    bundleName : String255;
    pathIsAnUnixBinary : boolean;
begin

  CanStartEngine := false;
  pathIsAnUnixBinary := (Pos('/',pathMac) = 1);


  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  exit;
  {$ENDC}

  if (pathMac = '') then
    exit;


  pathMac := ReplaceStringAll(pathMac,'/',':');     // separateurs a la mode Mac
  if (pathMac[1] = ':')
    then pathUnix := pathMac
    else SplitAt(pathMac,':',foo, pathUnix);        // enlever le nom du disque dur
  pathUnix := ReplaceStringAll(pathUnix,':','/');   // separateurs a la mode UNIX

  if (debugEngine or debuggage.engineInput or debuggage.engineOutput or InfosTechniquesDansRapport) then
    begin
      EnginePrint('');
      EnginePrint('Trying to start   '+pathUnix);
    end;


  if pathIsAnUnixBinary or (FileExists(pathMac,0,fic) = NoErr)
    then
      begin

        bundleName := GetEngineBundleName;

        myStartEnginePtr          := StartEngineProcPtr         (GetFunctionPointerFromPrivateBundle( bundleName, 'StartEngine'));
        mySuspendEnginePtr        := SuspendEngineProcPtr       (GetFunctionPointerFromPrivateBundle( bundleName, 'SuspendEngine'));
        myResumeEnginePtr         := ResumeEngineProcPtr        (GetFunctionPointerFromPrivateBundle( bundleName, 'ResumeEngine'));
        mySendDataToEnginePtr     := SendDataToEngineProcPtr    (GetFunctionPointerFromPrivateBundle( bundleName, 'SendDataToEngine'));
        mySetCallBackForEnginePtr := SetCallBackForEngineProcPtr(GetFunctionPointerFromPrivateBundle( bundleName, 'SetCallBackForEngine'));
        mySwitchToEnginePtr       := SwitchToEngineProcPtr      (GetFunctionPointerFromPrivateBundle( bundleName ,'SwitchToEngine'));


        if (myStartEnginePtr <> NIL) and (mySetCallBackForEnginePtr <> NIL)
          then
            begin

              mySetCallBackForEnginePtr(ReceiveEngineData);


              SetEngineState(ENGINE_STARTING);
              engine.lastDateOfActivity   := Tickcount;
              engine.lastDateOfPinging    := Tickcount;
              engine.readyReceived        := false;
              engine.speed                := 0.0;
              engine.durationOfLastResult := 0.0;
              engine.suspendCount         := 0;
              engine.lastStringSent       := '';
              engine.lastDateOfStarting   := TickCount;
              inc(engine.nbStartsOfEngine);
              InitLongString(engine.lastStringReceived);
              EngineViderFeedHashHistory;


              with gVitessesInstantaneesEngine do
                begin
                  compteur := 0;
                  for i := 1 to 5 do
                    begin
                      data[i].kilonodes := 0.0;
                      data[i].time      := 0.0;
                    end;
                end;

              CFpath      := MakeCFSTR(pathUnix);
              CFarguments := MakeCFSTR(arguments);

              ok := myStartEnginePtr(CFpath, CFarguments);

              CFRelease(CFTypeRef(CFpath));
              CFRelease(CFTypeRef(CFarguments));

              if (ok = 1)
                then
                  begin
                    EngineInit;
                    CanStartEngine := true;
                  end
                else
                  begin
                    mySetCallBackForEnginePtr(NIL);
                    SetEngineState(ENGINE_KILLED);
                    CanStartEngine        := false;
                    EnginePrint('Impossible to start an engine (#' + IntToStr(engine.nbStartsOfEngine) + ')');
                  end;
            end
          else EnginePrint('(myStartEnginePtr = NIL)');

      end
    else
      begin
        EnginePrint('Executable non trouve:     '+pathMac);
      end;

end;


(*
 *******************************************************************************
 *                                                                             *
 *   Fonction permettant de savoir s'il y a un moteur lancé à la disposition   *
 *   de Cassio pour ses calculs. Si oui, le numero de ce moteur est renvoyé    *
 *   dans "numero".                                                            *
 *                                                                             *
 *******************************************************************************
 *)
function CassioIsUsingAnEngine(var numero : SInt64) : boolean;
begin
  if (numeroEngineEnCours <> 0)
    then
      begin
        CassioIsUsingAnEngine := true;
        numero := numeroEngineEnCours;
      end
    else
      CassioIsUsingAnEngine := false;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   Transformation d'un enregistrement Pascal decrivant une requete en la     *
 *   chaine de caracteres (format protocole texte) qui va etre envoyee au      *
 *   moteur.                                                                   *
 *                                                                             *
 *******************************************************************************
 *)
function FabriquerChaineRequestPourEngine(var search : EngineSearchRec) : String255;
var s,s1,s2 : String255;
    i : SInt64;
begin
  s := '';

  s  := 'ENGINE-PROTOCOL ';

  s2 := '';
  s1 := PositionEtTraitEnString(search.position);
  for i := 1 to LENGTH_OF_STRING(s1) do
    if (s1[i] <> ' ') then s2 := s2 + s1[i];

  with search do
    begin
      if (typeDeRecherche = ReflParfait)
        then
          begin
            // endgame search
            s := s + ' endgame-search '+ s2 + ' ' + IntToStr(alpha) + ' ' + IntToStr(beta) + ' '+ IntToStr(precision);
          end
        else
          begin
            // midgame search
            s := s + ' midgame-search '+ s2 + ' ' + ReelEnString(alpha/100.0) + ' ' + ReelEnString(beta/100.0) + ' ' + IntToStr(depth) + ' '+ IntToStr(precision);
          end;
    end;

  FabriquerChaineRequestPourEngine := s;
end;




(*
 *******************************************************************************
 *                                                                             *
 *   StartEngineSearch : lancement effective d'une recherche. Le premier para- *
 *   metre est la commande texte que l'on va envoyer au moteur, et le second   *
 *   parametre l'enregistrement Pascal decrivant la requete : on stocke les    *
 *   deux pour que Cassio sache facilement quelle etait la derniere requete    *
 *   envoyee.                                                                  *
 *                                                                             *
 *******************************************************************************
 *)
procedure StartEngineSearch(var demande : String255; var search : EngineSearchRec);
var line : LongString;
begin

  // vider la file des resultats
  while GetNextResultFromEngine(line) do;

  // si la requete semble completement independante de la precedente, le dire au moteur
  if (NombresCasesOccupeesDifferentes(search.position, engine.lastSearchSent.position) > 5)
    then EngineNewPosition;

  if (engine.state <> ENGINE_KILLED) then
    begin
      // preparer la demande
      engine.lastSearchSent           := search;
      engine.lastCommandSent          := demande;
      engine.lastDateOfPinging        := TickCount;
      engine.lastDateOfSearchStart    := TickCount;
      engine.CassioIsWaitingAResult   := true;
      engine.readyReceived            := false;
      SetEngineState(ENGINE_RUNNING);

      AjusteSleep;

      // envoyer la demande
      SendStringToEngine(demande);
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineNewPosition : on annonce au moteur que l'on va analyser une         *
 *   position completement independante des precedentes. Cassio n'envoie pas   *
 *   de new-position pendant une analyse retrograde, ni apres un ensemble de   *
 *   feed-hash.                                                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineNewPosition;
var s : String255;
begin
  if not(AnalyseRetrogradeEnCours) and not(CassioEstEnTrainDeCalculerPourLeZoo) then
    begin
      s := 'ENGINE-PROTOCOL new-position';
      if (engine.lastStringSent <> s) and (Pos('feed-hash',engine.lastStringSent) <= 0)
        then SendStringToEngine(s);
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineInit : on demande au moteur de reinitialiser sa table de hachage    *
 *   et de se preparer a recevoir des requetes.                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineInit;
var s : String255;
begin
  s := 'ENGINE-PROTOCOL get-version';
  if (engine.lastStringSent <> s) then
    SendStringToEngine(s);
  s := 'ENGINE-PROTOCOL init';
  if (engine.lastStringSent <> s) then
    SendStringToEngine(s);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineEmptyHash : on demande au moteur de vider totalement sa table de    *
 *   hachage.                                                                  *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineEmptyHash;
var s : String255;
begin
  s := 'ENGINE-PROTOCOL empty-hash';
  if (engine.lastStringSent <> s) then
    begin
      {EnginePrintError('Sending empty-hash to the engine');}
      SendStringToEngine(s);
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   ViderFeedHashInfos : vide l'enregistrement qui nous permet de noter les   *
 *   sequences de feed-hash.                                                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure ViderFeedHashInfos;
begin
  FeedHashInfos.chaineCourante   := '';
  FeedHashInfos.positionCourante := MakeEmptyPositionEtTrait;
  FeedHashInfos.depthCourante    := -1;
  FeedHashInfos.vMinCourant      := 1000;
  FeedHashInfos.vMaxCourant      := -1000;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EmitFeedHashString : envoi definitif d'une commande de feed-hash vers les *
 *   engines.                                                                  *
 *                                                                             *
 *******************************************************************************
 *)
procedure EmitFeedHashString(const s : String255);
var foo : SInt64;
begin
  if (s <> '') and not(MemberOfStringSet(s,foo,lignesEnvoyeesParHashFeed)) then
    begin
      SendStringToEngine(s);
      AddStringToSet(s,0,lignesEnvoyeesParHashFeed);
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AccumulateFeedHashSequenceForEngine : au lieu d'envoyer des commandes     *
 *   feed-hash distinctes, on essaye de les grouper en envoyant une seule      *
 *   position et une sequence de coups.                                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure AccumulateFeedHashSequenceForEngine(const s : String255; position : PositionEtTraitRec; depth, valeurMin, valeurMax, bestMove : SInt64);
var continuerSequence : boolean;
    trait : SInt64;
begin

  with FeedHashInfos do
    begin
      trait := GetTraitOfPosition(position);

      continuerSequence := false;

      if (depthCourante = depth) and
         (valeurMin = vMinCourant) and (valeurMax = vMaxCourant) and
         (SamePositionEtTrait(positionCourante, position)) and
         (bestMove >= 11) and (bestMove <= 88) and
         (UpdatePositionEtTrait(positionCourante, bestMove)) and
         (GetTraitOfPosition(positionCourante) = - trait)
        then
          begin
            continuerSequence := true;
            chaineCourante    := chaineCourante + CoupEnStringEnMajuscules(bestMove);
            depthCourante     := depthCourante - 1;
            vMinCourant       := -valeurMax;
            vMaxCourant       := -valeurMin;
          end;

      if not(continuerSequence) then
        begin
          EmitFeedHashString(chaineCourante);

          positionCourante := position;

          if (UpdatePositionEtTrait(positionCourante, bestMove)) and
             (GetTraitOfPosition(positionCourante) = - trait)
            then
              begin
                chaineCourante   := s;
                depthCourante    := depth - 1;
                vMinCourant      := -valeurMax;
                vMaxCourant      := -valeurMin;
              end
            else
              begin
                EmitFeedHashString(s);
                ViderFeedHashInfos;
              end;
        end;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineFeedHashValues : permet de preremplir la table de hachage du moteur *
 *   avec les bornes de la valeur d'une position.                              *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineFeedHashValues(var position : PositionEtTraitRec; depth, valeurMin, valeurMax, bestMove : SInt64);
var s,s1 : String255;
    i, foo : SInt64;
begin

  if (depth >= 15) and (engine.state <> ENGINE_KILLED) then
    begin

      // ENGINE-PROTOCOL feed-hash position lower upper depth selectivity move

      s := 'ENGINE-PROTOCOL  feed-hash ';

      s1 := PositionEtTraitEnString(position);
      for i := 1 to LENGTH_OF_STRING(s1) do
        if (s1[i] <> ' ') then s := s + s1[i];

      s := s + ' ' + IntToStr(valeurMin) + '.00';
      s := s + ' ' + IntToStr(valeurMax) + '.00';
      s := s + ' ' + IntToStr(depth);
      s := s + ' ' + IntToStr(100);

      if (bestMove >= 11) and (bestMove <= 88)
        then s := s + ' ' + CoupEnStringEnMajuscules(bestMove)
        else s := s + ' ??';

      if not(MemberOfStringSet(s,foo,lignesTraiteesParHashFeed)) then
        begin
          AccumulateFeedHashSequenceForEngine(s, position, depth, valeurMin, valeurMax, bestMove);
          AddStringToSet(s,0,lignesTraiteesParHashFeed);
        end;

    end;

end;




(*
 *******************************************************************************
 *                                                                             *
 *   EngineBeginFeedHashSequence : debut d'un bloc de commandes feed-hash.     *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineBeginFeedHashSequence;
begin
  ViderFeedHashInfos;
  EngineNewPosition;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineEndFeedHashSequence : fin d'un bloc de commandes feed-hash.         *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineEndFeedHashSequence;
begin
  with FeedHashInfos do
    begin
      EmitFeedHashString(chaineCourante);
      ViderFeedHashInfos;
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EngineViderFeedHashHistory : vide l'historique des feed-hash envoyés au   *
 *   moteur.                                                                   *
 *                                                                             *
 *******************************************************************************
 *)
procedure EngineViderFeedHashHistory;
begin
  ViderStringSet(lignesEnvoyeesParHashFeed);
  ViderStringSet(lignesTraiteesParHashFeed);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   CassioIsWaitingAnEngineResult : TRUE si et seulement si Cassio a envoye   *
 *   une requete au moteur et si le moteur est en train d'y repondre.          *
 *                                                                             *
 *******************************************************************************
 *)
function CassioIsWaitingAnEngineResult : boolean;
begin
  CassioIsWaitingAnEngineResult := engine.CassioIsWaitingAResult;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   InitResult() : reinitialisation des resultats intermediaires.             *
 *   Lorsque les moteurs font de l'approfondissmeent iteratif, on reinitialise *
 *   les resultas a chaque fois qu'ils commencent une nouvelle profondeur.     *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitResult(var result : EngineResultRec);
begin
  if engine.CassioIsWaitingAResult then
    with result do
      begin
        typeResult         := engine.lastSearchSent.typeDeRecherche;
        position           := engine.lastSearchSent.position;
        candidateMove      := 0;
        depth              := engine.lastSearchSent.depth;
        precision          := -1000;
        colorOfValue       := GetTraitOfPosition(engine.lastSearchSent.position);
        minorantOfValue    := -noteMax;
        majorantOfValue    :=  noteMax;
        line               := '';
        kilonodes          := 0.0;
        time               := 0.0;
      end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   AmeliorerResultatGlobalParResultatPartiel : Cassio vient de recevoir un   *
 *   resultat partiel sur une position, et essaye d'en deduire la meilleure    *
 *   note et le meilleur coup dans cette position.                             *
 *                                                                             *
 *******************************************************************************
 *)
procedure AmeliorerResultatGlobalParResultatPartiel(search : EngineSearchRec; var resultGlobal : EngineResultRec; resultPartiel : EngineResultRec);
var v : SInt64;
begin

  (*
  EnginePrint('resultGlobal = ');
  EcrireEngineResultDansRapport(resultGlobal);
  EnginePrint('resultPartiel = ');
  EcrireEngineResultDansRapport(resultPartiel);
  *)


  if (resultPartiel.depth     >= search.depth) and
     (resultPartiel.precision >= resultGlobal.precision) and
     SamePositionEtTrait(search.position, resultPartiel.position)
    then
      begin
        if (resultPartiel.precision > resultGlobal.precision) or
           not(SamePositionEtTrait(resultPartiel.position, resultGlobal.position))
          then InitResult(resultGlobal);

        with resultPartiel do
        if ((minorantOfValue <= search.alpha) and (majorantOfValue > search.alpha)) or
           ((majorantOfValue >= search.beta) and (minorantOfValue < search.beta)) or
           ((minorantOfValue >= search.alpha) and (majorantOfValue <= search.beta) and (minorantOfValue < majorantOfValue)) then
          begin
            EnginePrintError('ERROR : the result window overlaps the [alpha,beta] window !');
            EnginePrintError('[alpha , beta] = [' + IntToStr(search.alpha) + ' , ' + IntToStr(search.beta) + ']');
            EnginePrintError('result : [lower , upper] = [' + IntToStr(minorantOfValue) + ' , ' + IntToStr(majorantOfValue) + ']');
          end;

        if (resultPartiel.minorantOfValue <= resultPartiel.majorantOfValue)
          then
            begin
              v := resultPartiel.minorantOfValue;
              if v > resultGlobal.minorantOfValue then
                begin
                  resultGlobal.minorantOfValue   := v;
                  resultGlobal.candidateMove     := resultPartiel.candidateMove;
                  resultGlobal.line              := resultPartiel.line;
                  resultGlobal.precision         := resultPartiel.precision;
                end;
              v := resultPartiel.majorantOfValue;
              if v < resultGlobal.majorantOfValue then
                  resultGlobal.majorantOfValue   := v;
            end
          else
            begin
              EnginePrintError('ERROR : minorantOfValue > majorantOfValue dans AmeliorerResultatGlobalParResultatPartiel');
            end;
      end
    else
      begin
        EnginePrintError('ERROR : parametres non concordants dans AmeliorerResultatGlobalParResultatPartiel');
      end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   GetSpeedOfEngine() : cette fonction renvoie la vitesse du moteur externe, *
 *   exprimee en kilonoeuds par seconde.                                       *
 *                                                                             *
 *******************************************************************************
 *)
 function GetSpeedOfEngine : double;
 begin
   GetSpeedOfEngine := engine.speed;  { en kilonodes par seconde }
 end;


(*
 *******************************************************************************
 *                                                                             *
 *   CalculateSpeedOfEngine() : calculer la vitesse du moteur. On prend la     *
 *   vitesse max sur les cinq derniers resultats renvoyes par le moteur.       *
 *                                                                             *
 *******************************************************************************
 *)
procedure CalculateSpeedOfEngine(const result : EngineResultRec);
var i : SInt64;
    totalKiloNoeuds, totalTime, v, vitesseMax : double;
begin

  if (result.time <> 0.0) and (result.kilonodes <> 0.0) then
    with gVitessesInstantaneesEngine do
      begin

        inc(compteur);
        if compteur > 5 then compteur := 1;

        data[compteur].kilonodes := result.kilonodes;
        data[compteur].time      := result.time;

        totalKiloNoeuds := 0.0;
        totalTime       := 0.0;
        vitesseMax      := 0.0;

        for i := 1 to 5 do
          if (data[i].kilonodes >= 0.0) and (data[i].time <> 0.0) then
            begin

              totalKiloNoeuds := totalKiloNoeuds + data[i].kilonodes;
              totalTime       := totalTime       + data[i].time;

              v := data[i].kilonodes / data[i].time;

              if (v > vitesseMax) then vitesseMax := v;
            end;

        engine.speed                := vitesseMax;  { en kilonodes par seconde }
        engine.durationOfLastResult := result.time; { en secondes }

      end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   CheckIncreaseOfNodesInAnswerFromEngine() : verifie que le moteur          *
 *   augmente bien le nombre de noeuds calcules seconde apres seconde.         *
 *                                                                             *
 *******************************************************************************
 *)
procedure CheckIncreaseOfNodesInAnswerFromEngine(const result : EngineResultRec);
begin

  if (result.time <> 0.0) and (result.kilonodes <> 0.0) then
      begin

        if (result.kilonodes = lastSpeedResultReceived.kilonodes) and
           (result.time      > lastSpeedResultReceived.time) and
           (debugEngine or debuggage.engineInput) then
          begin
            EnginePrintColoredStringInRapport('WARNING : node count didn''t change, engine is probably stuck', RougeCmd, normal);
          end;

        lastSpeedResultReceived.kilonodes := result.kilonodes;
        lastSpeedResultReceived.time      := result.time;
      end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   DurationOfLastResultReceivedByEngine() : renvoie, en seconde, la duree du *
 *   dernier resultat renvoye par le moteur.                                   *
 *                                                                             *
 *******************************************************************************
 *)
function DurationOfLastResultReceivedByEngine : double;
begin
  DurationOfLastResultReceivedByEngine := engine.durationOfLastResult;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   DateOfLastActivityByEngine() : renvoie, en ticks, la date du dernier      *
 *   message renvoye par le moteur.                                            *
 *                                                                             *
 *******************************************************************************
 *)
function DateOfLastActivityByEngine : SInt64;
begin
  DateOfLastActivityByEngine := engine.lastDateOfActivity;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   DurationOfLastResultReceivedByEngine() : renvoie, en ticks, la date du    *
 *   dernier demarrage d'un moteur.                                            *
 *                                                                             *
 *******************************************************************************
 *)
function DateOfLastStartOfEngine : SInt64;
begin
  DateOfLastStartOfEngine := engine.lastDateOfStarting;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   WaitEngineResult() : boucle d'attente apres l'envoi d'une requete au      *
 *   moteur, qui renvoie TRUE lorque la recherche est terminee et complete.    *
 *   Il faut faire en sorte de prendre le moins de temps CPU possible, tout    *
 *   en continuant à gere l'interface utilisateur dans Cassio.                 *
 *   En particulier, cette fonction est chargée de stopper la recherche en     *
 *   cours dans le moteur en lui envoyant une commande "stop" si la position   *
 *   sur l'othellier a bougé, ou plus generalement si l'utilisateur interrompt *
 *   la recherche dans Cassio.                                                 *
 *   D'autre part, cette fonction lit régulièrement (tous les 1/60 de seconde) *
 *   le buffer d'entree sur stdin pour recevoir les messages du moteur.        *
 *                                                                             *
 *******************************************************************************
 *)
function WaitEngineResult(const search : EngineSearchRec; var result : EngineResultRec) : boolean;
var terminee : boolean;
    interrompue : boolean;
    line : LongString;
    resultatPartiel : EngineResultRec;
    nbreResultatsPartiels : SInt64;
    nbreReadyRecus : SInt64;
begin

  InitResult(result);

  nbreResultatsPartiels := 0;
  nbreReadyRecus        := 0;

  terminee    := false;
  interrompue := false;

  while not(interrompue or terminee or (engine.state = ENGINE_KILLED) or (engine.state = ENGINE_STOPPED)) do
    begin

      PingEngine;

      MPYield;

      AjusteSleep;

      delaiAvantDoSystemTask := 0;

      if (TickCount - dernierTick) >= delaiAvantDoSystemTask then
        DoSystemTask(AQuiDeJouer);

      if Quitter or (interruptionReflexion <> pasdinterruption) or EngineIsDead then
        begin
          interrompue := true;
          engine.CassioIsWaitingAResult := false;
          StopCurrentEngine;
        end;


      while GetNextResultFromEngine(line) do
        begin
          if debugEngine then WritelnLongStringDansRapport(line);

          if (Pos('ready.',line.debutLigne) > 0)
            then
              begin
                inc(nbreReadyRecus);

                if (nbreResultatsPartiels > 0)
                  then
                    begin
                      // arret normal
                      engine.readyReceived := true;
                    end
                  else
                    begin
                      if (nbreReadyRecus >= 4) then
                        begin
                          // arret d'urgence pour les engines buggues
                          if not(interrompue) then
                            EnginePrintError('ERROR : the engine didn''t send any valuable result, aborting');
                          engine.readyReceived := true;
                        end;
                    end;
              end
            else
              begin
                if ParserResultLine(line, resultatPartiel) then
                  begin

                    if (engine.lastSearchSent.typeDeRecherche = ReflMilieu) and (resultatPartiel.typeResult = ReflParfait)
                      then PatcherLesResultatsEntiersDesRequetesDeMilieu(search, resultatPartiel);

                    if (engine.lastSearchSent.typeDeRecherche = ReflParfait) and (resultatPartiel.typeResult = ReflMilieu)
                      then PatcherLesResultatsFlottantsDesRequetesDeFinale(search, resultatPartiel);

                    inc(nbreResultatsPartiels);

                    if not(interrompue)
                      then AmeliorerResultatGlobalParResultatPartiel(search, result, resultatPartiel);

                    CalculateSpeedOfEngine(resultatPartiel);
                  end;
              end;
        end;

      terminee := engine.readyReceived and (engine.state = ENGINE_RUNNING);

    end;


  WaitEngineResult := terminee and not(interrompue);

  engine.CassioIsWaitingAResult := false;

  if (engine.state = ENGINE_STOPPED)
    then SetEngineState(ENGINE_RUNNING);

  AjusteSleep;


end;





(*
 *******************************************************************************
 *                                                                             *
 *   MettreLeResultatGlobalDansLesVariablesDeCassio() :                        *
 *   Cette fonction remplit la table de hachage de Cassio et sa structure      *
 *   (interne) de meilleure suite avec la meilleure suite donnee par le moteur *
 *   externe. Note : il faut avoir bien confiance dans la qualite de la meil-  *
 *   leure suite renvoyee par les moteurs externes ! Pour Edax et Roxane, ça   *
 *   va bien maintenant :-)                                                    *
 *                                                                             *
 *******************************************************************************
 *)
procedure MettreLeResultatGlobalDansLesVariablesDeCassio(search : EngineSearchRec; result : EngineResultRec; var meilleureSuite : t_meilleureSuite);
var vMin, vMax, deltaFinale : SInt64;
begin
  if (result.depth <> search.depth) then
    exit;


  if (search.utilisationDansCassio = ReflMilieu)
    then
      begin
        LigneMilieuToMeilleureSuiteInfos(result.colorOfValue, search.depth, search.lastMove, search.position, result.line, meilleureSuite);
      end
    else
      begin
        vMin := result.minorantOfValue;
        vMax := result.majorantOfValue;

        if (result.precision < 100)
          then
            begin
              deltaFinale := deltaFinaleCourant;
              inc(nbCoupuresHeuristiquesCettePasse);
            end
          else deltaFinale := kDeltaFinaleInfini;

        LigneFinaleToHashTable(result.colorOfValue, search.depth, search.lastMove, vMin, vMax, deltaFinale, search.position, result.line, meilleureSuite);
      end;

end;



(*
 *******************************************************************************
 *                                                                             *
 *   Lorsque Cassio recoit un resultat du moteur, il en fait une analyse       *
 *   simple pour savoir la note a renvoyer, en la redressant en cas de passe,  *
 *   en la mettant paire si c'est une note de finale (car Cassio attend tou-   *
 *   jours des notes paires dans son algo de finale), etc.                     *
 *                                                                             *
 *******************************************************************************
 *)
procedure AnalyserLeResultatGlobal(couleur : SInt64; search : EngineSearchRec; result : EngineResultRec; var rechercheTerminee : boolean; var note : SInt64; var meilleureSuite : t_meilleureSuite);
begin

  note := -noteMax;

  if rechercheTerminee then
    with result do
      begin

        if (search.precision >= 100) and (result.precision < 100) then
          EnginePrintError('ASSERT : précision insuffisante du résultat (' + IntToStr(result.precision) + '%) dans AnalyserLeResultatGlobal !');

        if (minorantOfValue > majorantOfValue) then
          EnginePrintError('ASSERT : Résultats incohérents de l''engine (minorantOfValue > majorantOfValue) dans AnalyserLeResultatGlobal !');

        // on decide de la note que l'on va renvoyer, en fonction de la fenetre alpha-beta
        if (minorantOfValue = majorantOfValue)
          then
            begin
              note := minorantOfValue;
            end
          else
            begin
              if minorantOfValue >= search.beta  then
                begin
                  if (typeResult = ReflParfait) and odd(minorantOfValue) then inc(minorantOfValue);
                  note := minorantOfValue;
                end
              else
              if majorantOfValue <= search.alpha then
                begin
                  if (typeResult = ReflParfait) and odd(majorantOfValue) then dec(majorantOfValue);
                  note := majorantOfValue;
                end
              else
                begin
                  note := -noteMax;
                  rechercheTerminee := false;
                end;
            end;

        // faut-il redresser la note (apres un passe ?)
        if (couleur = -result.colorOfValue) and (note <> -noteMax)
          then
            begin
              // EnginePrintWarning('WARNING : la recherche a ete faite par le moteur pour l''autre couleur...');
              note := -note;
            end;
      end;


  // remplir la ligne principale de Cassio

  if rechercheTerminee and (result.depth >= search.depth)
    then MettreLeResultatGlobalDansLesVariablesDeCassio(search, result, meilleureSuite);

end;


(*
 *******************************************************************************
 *                                                                             *
 *   EnginePeutFaireCalcul() : calcul d'une position en milieu ou en finale    *
 *                                                                             *
 *******************************************************************************
 *)
function EnginePeutFaireCeCalcul(var plateau : plateauOthello; typeCalcul, typeUtilisation, profondeur, couleur, alpha, beta, precision, dernierCoup : SInt64; var note, bestMove : SInt64; var meilleureSuite : t_meilleureSuite) : boolean;
var search    : EngineSearchRec;
    traitReel : SInt64;
    demande : String255;
    rechercheTerminee : boolean;
    result : EngineResultRec;
    nNoirs, nBlancs : SInt64;
begin

  EnginePeutFaireCeCalcul := false;

  if (engine.state <> ENGINE_RUNNING) and (engine.state <> ENGINE_STOPPED) then
    begin
      // EnginePrintError('Cassio ERROR : Engine not ready');
      exit;
    end;


  if (alpha >= beta) then
    begin
      EnginePrintWarning('Cassio ERROR : alpha >= beta in EnginePeutFaireCeCalcul, aborting');
      EnginePrintWarning('    alpha = '+IntToStr(alpha)+', beta = '+IntToStr(beta));
      exit;
    end;

  if (couleur = pionVide) then
    begin
      EnginePrintError('Cassio ERROR : trait = pionvide');
      exit;
    end;

  search.position := MakePositionEtTrait(plateau, couleur);
  traitReel := GetTraitOfPosition(search.position);

  if (traitReel = pionVide) then
    begin
      nNoirs  := NbPionsDeCetteCouleurDansPosition(pionNoir,plateau);
      nBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,plateau);
      {Les cases vides vont au vainqueur}
      if nNoirs > nBlancs then nNoirs  := (64 - nBlancs) else
      if nNoirs < nBlancs then nBlancs := (64 - nNoirs);
      if (couleur = pionNoir)
        then note := nNoirs - nBlancs
        else note := nBlancs - nNoirs;
      if (typeCalcul = ReflMilieu) then note := note * 100;
      bestMove := 0;
      EnginePeutFaireCeCalcul := true;
      exit;
    end;

  if (precision < 0) or (precision > 100) then
    begin
      EnginePrintError('Cassio ERROR : precision out of bounds in EnginePeutFaireCeCalcul');
      exit;
    end;

  search.typeDeRecherche       := typeCalcul;
  search.utilisationDansCassio := typeUtilisation;
  search.precision             := precision;
  search.depth                 := profondeur;
  search.lastMove              := dernierCoup;
  search.empties               := NbCasesVidesDansPosition(search.position.position);

  if (traitReel = couleur)
    then
      begin
        search.alpha           := alpha;
        search.beta            := beta;
      end
    else
      begin
        search.alpha           := -beta;
        search.beta            := -alpha;
      end;

  (*
  if (search.depth < 20) and (search.typeDeRecherche = ReflParfait) then
    begin
      EnginePrintError('Cassio ERROR : (depth < 20) dans EnginePeutFaireCeCalcul');
      exit;
    end;
  *)

  demande := FabriquerChaineRequestPourEngine(search);

  if (demande = '') then
    begin
      EnginePrintError('Cassio ERROR : demande = ?');
      exit;
    end;


  if (interruptionReflexion <> pasdinterruption) then
    begin
      EnginePrintError('Cassio ERROR : (interruptionReflexion <> pasdinterruption)');
      exit;
    end;


  // lancer la recherche du moteur
  StartEngineSearch(demande, search);


  // boucle d'attente d'un resultat
  rechercheTerminee := WaitEngineResult(search, result);


  // analyse de la correction du resultat
  AnalyserLeResultatGlobal(couleur, search, result, rechercheTerminee, note, meilleureSuite);


  // tout a l'air bon, hein
  if rechercheTerminee then
    begin
      bestMove := result.candidateMove;
      EnginePeutFaireCeCalcul := true;
    end;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePeutFaireCalculDeFinale() : c'est la fonction principale de ce      *
 *   module, en ce sens que c'est celle qui est appelee par l'algo de finale   *
 *   de Cassio pour savoir si Cassio peut trouver un moteur externe plus       *
 *   rapide que lui pour l'aider à résoudre un sous-arbre.                     *
 *                                                                             *
 *******************************************************************************
 *)
function EnginePeutFaireCalculDeFinale(var plateau : plateauOthello; couleur, alpha, beta, precision, dernierCoup : SInt64; var note, bestMove : SInt64; var meilleureSuite : t_meilleureSuite) : boolean;
var empties : SInt64;
begin

  if (alpha < -64) and (beta >= -63) then alpha := -64;
  if (alpha <= 63) and (beta >   64) then beta  :=  64;

  if (alpha >= beta) then
    begin
      EnginePrintError('Cassio ERROR : alpha >= beta dans EnginePeutFaireCalculDeFinale');
      EnginePrintError('alpha = '+IntToStr(alpha)+', beta = '+IntToStr(beta));
      EnginePeutFaireCalculDeFinale := false;
      exit;
    end;

  empties := NbCasesVidesDansPosition(plateau);

  EnginePeutFaireCalculDeFinale := EnginePeutFaireCeCalcul(plateau,ReflParfait,ReflParfait,empties,couleur,alpha,beta,precision,dernierCoup,note,bestMove,meilleureSuite);


end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePeutFaireCalculDeMilieu() : estimation par les moteurs d'une        *
 *   recherche de milieu de partie                                             *
 *                                                                             *
 *******************************************************************************
 *)
function EnginePeutFaireCalculDeMilieu(var plateau : plateauOthello; profondeur, couleur, alpha, beta, dernierCoup : SInt64; var note, bestMove : SInt64; var meilleureSuite : t_meilleureSuite) : boolean;
var empties, precision : SInt64;
begin

  if (alpha < -6400) then alpha := -6400;
  if (alpha >  6400) then alpha :=  6400;
  if (beta  < -6400) then beta  := -6400;
  if (beta  >  6400) then beta  :=  6400;

  if (alpha >= beta) and ((alpha = 6400) or (beta = -6400)) then
    begin
      EnginePeutFaireCalculDeMilieu := false;
      exit;
    end;

  if (alpha >= beta) then
    begin
      EnginePrintError('Cassio ERROR : alpha >= beta dans EnginePeutFaireCalculDeMilieu');
      EnginePrintError('alpha = '+IntToStr(alpha)+', beta = '+IntToStr(beta));
      EnginePeutFaireCalculDeMilieu := false;
      exit;
    end;

  empties := NbCasesVidesDansPosition(plateau);


  if (profondeur > empties)
    then
      begin
        // on va utiliser une recherche de finale par le moteur a la place de notre recherche de milieu

        alpha := (PreviousMultipleOfN(alpha, 100) div 100);
        beta  := (NextMultipleOfN(beta, 100) div 100);

        precision := ProfondeurMilieuEnPrecisionFinaleEngine(profondeur, empties);

        EnginePeutFaireCalculDeMilieu := EnginePeutFaireCeCalcul(plateau,ReflParfait,ReflMilieu,empties,couleur,alpha,beta,precision,dernierCoup,note,bestMove,meilleureSuite);

        note := note * 100;

      end
    else
      begin
        // on va utiliser une vraie recherche de milieu par le moteur

        precision := 90;  //   90 %
        EnginePeutFaireCalculDeMilieu := EnginePeutFaireCeCalcul(plateau,ReflMilieu,ReflMilieu,profondeur,couleur,alpha,beta,precision,dernierCoup,note,bestMove,meilleureSuite);
      end;

end;



(*
 *******************************************************************************
 *                                                                             *
 *   TestEngineUnit() : divers tests des fonctions de ce module.               *
 *                                                                             *
 *******************************************************************************
 *)
procedure TestEngineUnit;
var pathMac, arguments : String255;
    positionToSolve : PositionEtTraitRec;
    test : boolean;
    tick : SInt64;
    note, bestDef : SInt64;
    foo : meilleureSuitePtr;
begin

  // pathMac       := 'Glenans:Users:stephane:Desktop:FakeOthelloEngine:build:Release:FakeOthelloEngine';
  // pathMac       := 'Glenans:Users:stephane:Programmation:Cassio_5.2:Cassio.app:Contents:Engines:CassioEngine';
  // pathMac       := 'Glenans:Users:stephane:Desktop:edax:engine.sh';
  // pathMac       := 'Glenans:Users:stephane:Desktop:roxane:engine.sh';
  // pathMac       := 'Glenans:Users:stephane:Jeux:Othello:Cassio:Engines:edax:engine.sh';

  pathMac := GetEnginePath(0,'edax');


  arguments := '2';  // nombre de threads pour le moteur : ceci sera passe comme argument du script "engine.sh"

  if CanStartEngine(pathMac, arguments) then
    begin


      if FALSE and ParsePositionEtTrait('--X-OOO---XXOO---XXOXXO-XXOOOOOOXXXXXXOX-XOOOOXX--OOOO-------O--X',positionToSolve) then
        begin

          tick := Tickcount;


          EnginePrint('Waiting 2 seconds...');

          // waiting two seconds
          Wait(2.0);

          interruptionReflexion := pasdinterruption;
          tick := TickCount;

          EnginePrint('...testing the engine...');
          EnginePrint('');

          {test := EnginePeutFaireCalculDeFinale(positionToSolve.position, GetTraitOfPosition(positionToSolve), -1, 0, 100, 0, note, bestDef, foo^);}

          foo := meilleureSuitePtr(AllocateMemoryPtrClear(sizeof(t_meilleureSuite)));

          if (foo <> NIL) then
            test := EnginePeutFaireCalculDeFinale(positionToSolve.position, GetTraitOfPosition(positionToSolve), -64, 64, 91, 0, note, bestDef, foo^);

          if foo <> NIL then DisposeMemoryPtr(Ptr(foo));


          EnginePrint('');
          if test
            then EnginePrint('... OK, test reussi, temps en ticks = ' + IntToStr(TickCount - tick))
            else EnginePrint('... test raté ! temps en ticks = ' + IntToStr(TickCount - tick));
        end;


    end;


end;


(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintColoredStringInRapport : affiche une ligne  en couleur dans    *
 *   le rapport. On protege les ecritures simultanées a l'aide d'un mutex (de  *
 *   sorte que cette procedure soit en section critique) car il peut arriver   *
 *   que plusieurs moteurs envoie des resultats en meme temps a Cassio !       *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintColoredStringInRapport(const s : String255; whichColor : SInt16; whichStyle : StyleParameter);
var ecrireDansRapport : boolean;
begin

  while (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexPrintColoredStringInRapport, mutex_engine_print_colored_string_in_rapport) = 0)
    do;

  // debut de la section critique

  ecrireDansRapport := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(false);
  ChangeFontColorDansRapport(whichColor);
  ChangeFontFaceDansRapport(whichStyle);
  WritelnDansRapport(s);
  TextNormalDansRapport;
  SetEcritToutDansRapportLog(ecrireDansRapport);

  // fin de la section critique

  mutex_engine_print_colored_string_in_rapport := 0;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrint : affiche une ligne noire normale dans le rapport.            *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrint(const s : String255);
begin
  EnginePrintColoredStringInRapport(s, NoirCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintDebug : affiche une ligne de debuggage verte dans le rapport   *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintDebug(const s : String255);
var version : String255;
begin
  if (Pos('DEBUG : Roxane',s) = 1) and
     (Pos('oxane',GetEngineName(numeroEngineEnCours)) > 0) then
    begin
      version := ReplaceStringOnce( s, 'DEBUG : ' , '' );
      SetEngineVersion(numeroEngineEnCours, version);
      exit;
    end;

  EnginePrintColoredStringInRapport(s, VertCmd, normal);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintWarning : affiche une ligne de warning verte dans le rapport   *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintWarning(const s : String255);
begin
  EnginePrintColoredStringInRapport(s, VertCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintInput : affiche les lignes recues du moteur en orange          *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintInput(const s : String255);
begin
  // les infos de DEBUG et WARNING seront de toute façon écrites en vert,
  // donc pas besoin de les ecrire en orange...
  if ((s[1] = 'D') and (Pos('DEBUG',s) = 1))  or
     ((s[1] = 'W') and (Pos('WARNING',s) = 1))
    then exit;
  EnginePrintColoredStringInRapport(s, OrangeCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintOutput : affiche les lignes envoyees au moteur en violet       *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintOutput(const s : String255);
begin
  EnginePrintColoredStringInRapport(s, VioletCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   EnginePrintError : affiche les erreurs en rouge gras dans le rapport.     *
 *                                                                             *
 *******************************************************************************
 *)
procedure EnginePrintError(const s : String255);
var theJob : LongString;
begin

  if ((TickCount - lastTickOfEngineErrorInRapport) > 30) then
    begin
      EnginePrintColoredStringInRapport('current engine = ' + GetEngineName(numeroEngineEnCours), RougeCmd, bold);
      EnginePrintColoredStringInRapport('last command = ' + engine.lastCommandSent, RougeCmd, bold);

      if CassioEstEnTrainDeCalculerPourLeZoo then
        begin
          theJob := GetCalculCourantDeCassioPourLeZoo;
          EnginePrintColoredStringInRapport('Current zoo job = ', RougeCmd, bold);
          EnginePrintColoredStringInRapport(theJob.debutLigne, RougeCmd, bold);
          EnginePrintColoredStringInRapport('Last command sent to the engine = ', RougeCmd, bold);
          EnginePrintColoredStringInRapport(engine.lastCommandSent, RougeCmd, bold);
        end;

    end;

  EnginePrintColoredStringInRapport(s, RougeCmd, bold);

  lastTickOfEngineErrorInRapport := TickCount;
end;






END.

















