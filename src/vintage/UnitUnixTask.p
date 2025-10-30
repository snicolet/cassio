UNIT UnitUnixTask;



INTERFACE


 USES UnitDefCassio, UnitDefUnixTask, UnitVarGlobalesFinale;




{ fonctions d'initialisation et de fin de module }
procedure InitUnitUnixTask;
procedure LibereMemoireUnitUnixTask;
procedure TestUnixTaskUnit;


{ Lancement d'un process UNIX }
function LaunchUNIXProcess(command, arguments : String255) : OSErr;


{ fonctions de bas niveau pour manipuler la tache unix }
function CanStartUnixTask(pathMac, arguments : String255) : boolean;
procedure KillCurrentUnixTask;
procedure SuspendCurrentUnixTask;
procedure ResumeCurrentUnixTask;
procedure SetUnixTaskState(state : SInt32);
function GetUnixTaskState : String255;
function DateOfLastActivityByUnixTask : SInt32;
function DateOfLastStartOfUnixTask : SInt32;


{ Fonctions d'interface texte avec le bundle de communication }
procedure ReceiveUnixTaskData(theCString : Ptr);
procedure SendStringToUnixTask(s : String255);
procedure InterpretUnixTaskCommand(line : LongString);
procedure SwitchToUnixTask(whichChannel : SInt16);


{ Nom du bundle de communication avec Unix }
function GetUnixTaskBundleName : String255;


{ Fonctions d'affichage dans le rapport }
procedure UnixTaskPrint(const s : String255);
procedure UnixTaskPrintDebug(const s : String255);
procedure UnixTaskPrintWarning(const s : String255);
procedure UnixTaskPrintInput(const s : String255);
procedure UnixTaskPrintOutput(const s : String255);
procedure UnixTaskPrintError(const s : String255);
procedure UnixTaskPrintColoredStringInRapport(const s : String255; whichColor : SInt16; whichStyle : StyleParameter);




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
    {$I prelink/UnixTask.lk}
{$ENDC}


{END_USE_CLAUSE}



const nbreMaxUnixTasks = 60;
const kTailleBufferStandardInput = 1024 * 128;

const kValeurMutexPrintColoredStringInRapport  = -1;

var debugUnixTask : boolean;
    mutex_UnixTask_print_colored_string_in_rapport : SInt32;
    lastTickOfUnixTaskErrorInRapport : SInt32;



(*
 *******************************************************************************
 *                                                                             *
 *   InitUnitUnixTask est appelee par Cassio au demarrage et initialise le     *
 *   module de gestion des taches Unix.                                        *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitUnitUnixTask;
begin
  myStartUnixTaskPtr          := NIL;
  mySuspendUnixTaskPtr        := NIL;
  myResumeUnixTaskPtr         := NIL;
  mySendDataToUnixTaskPtr     := NIL;
  mySetCallBackForUnixTaskPtr := NIL;
  mySwitchToUnixTaskPtr       := NIL;

  mutex_UnixTask_print_colored_string_in_rapport := 0;


  numeroUnixTaskEnCours           := 0;

  unixTask.nbStartsOfUnixTask     := 0;
  unixTask.nbQuitCommandsSent     := 0;
  unixTask.suspendCount           := 0;
  unixTask.mutex_reception_data   := 0;
  unixTask.lastDateOfStarting     := TickCount + 360000;


  debugUnixTask := false;
  lastTickOfUnixTaskErrorInRapport := 0;

  SwitchToUnixTask(0);

end;


(*
 *******************************************************************************
 *                                                                             *
 *   LibereMemoireUnitUnixTask est appelee par Cassio quand il quitte.         *
 *                                                                             *
 *******************************************************************************
 *)
procedure LibereMemoireUnitUnixTask;
begin

  if (numeroUnixTaskEnCours <> 0) then
    begin

      if (mySetCallBackForUnixTaskPtr <> NIL)
        then mySetCallBackForUnixTaskPtr(NIL);

      KillCurrentUnixTask;

      // wait 0.25 second
      Wait(0.25);

    end;
end;





(*
 *******************************************************************************
 *                                                                             *
 *   SetUnixTaskState : procedure pour changer la connaissance dans Cassio de  *
 *                     l'etat de la tache Unix.                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure SetUnixTaskState(state : SInt32);
begin
  unixTask.state := state;

  if (state = UNIX_TASK_KILLED)
    then mySendDataToUnixTaskPtr     := NIL;

end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetUnixTaskState : une fonction de debuggage.                             *
 *                                                                             *
 *******************************************************************************
 *)
function GetUnixTaskState : String255;
begin
  case unixTask.state of
    UNIX_TASK_STARTING : GetUnixTaskState := 'UNIX_TASK_STARTING';
    UNIX_TASK_RUNNING  : GetUnixTaskState := 'UNIX_TASK_RUNNING';
    UNIX_TASK_STOPPED  : GetUnixTaskState := 'UNIX_TASK_STOPPED';
    UNIX_TASK_KILLED   : GetUnixTaskState := 'UNIX_TASK_KILLED';
    otherwise            GetUnixTaskState := 'UNKNOWN UNIX TASK STATE !!!';
  end; {case}
end;



 (*
 *********************************************************************************
 *                                                                               *
 *   KillCurrentUnixTask : on essaye de demander poliment à la tache de quitter. *
 *   Attention : penser à bien attendre un petit peu apres avoir appele cette    *
 *   fonction, sinon Cassio risque de planter si la tache répond "bye." ou       *
 *   quelque chose comme ça et il faut que le bundle ait toujours son callback   *
 *   dans Cassio !                                                               *
 *                                                                               *
 *********************************************************************************
 *)
procedure KillCurrentUnixTask;
begin
  inc(unixTask.nbQuitCommandsSent);
  unixTask.lastDateOfStarting := TickCount + 360000;
  SendStringToUnixTask('KILL-TASK');
  SetUnixTaskState(UNIX_TASK_KILLED);
end;



 (*
 *******************************************************************************
 *                                                                             *
 *   SuspendCurrentUnixTask : on essaye de suspendre la tache (au sens UNIX).  *
 *                                                                             *
 *******************************************************************************
 *)
procedure SuspendCurrentUnixTask;
begin

  inc(unixTask.suspendCount);

  if (unixTask.suspendCount > 0) and (mySuspendUnixTaskPtr <> NIL) then
    begin
      UnixTaskPrint('WARNING : Appel de mySuspendUnixTaskPtr dans Cassio');
      mySuspendUnixTaskPtr;
    end;
end;



 (*
 *********************************************************************************
 *                                                                               *
 *   ResumeCurrentUnixTask : on continue l'execution de la tache (au sens UNIX). *
 *                                                                               *
 *********************************************************************************
 *)
procedure ResumeCurrentUnixTask;
begin

  dec(unixTask.suspendCount);

  if (unixTask.suspendCount = 0) and (myResumeUnixTaskPtr <> NIL) then
    begin
      myResumeUnixTaskPtr;
      UnixTaskPrint('WARNING : Appel de myResumeUnixTaskPtr dans Cassio');
    end;

end;




(*
 *******************************************************************************
 *                                                                             *
 *   InterpretUnixTaskCommand : reagit correctement à la reception d'une ligne *
 *   en provenance de la tache Unix.                                           *
 *                                                                             *
 *******************************************************************************
 *)
procedure InterpretUnixTaskCommand(line : LongString);
var s : String255;
    stringIsPoint, stringIsReady, stringIsOk, stringIsStarted : boolean;
begin

  s := line.debutLigne;


  (* check the results of requests when they are short strings (ready, ok, pings, etc.) *)
  if (LENGTH_OF_STRING(s) <= 14) then
    begin
      stringIsPoint   := (s = '.');
      stringIsReady   := not(stringIsPoint) and (Pos('ready.',s) > 0);
      stringIsOk      := not(stringIsPointorstringIsReady) and (Pos('ok.',s) > 0);
      stringIsStarted := not(stringIsPointorstringIsReadyorstringIsOk) and (Pos('Unix task started',s) > 0);

      if stringIsPoint or stringIsReady or stringIsOk or stringIsStarted then
        begin
          if ((unixTask.state = UNIX_TASK_STARTING) and stringIsReady) and
             (debugUnixTask or debuggage.engineInput or debuggage.engineOutput)
             then UnixTaskPrint('OK, confirmation que la commande unix a démarré');

          if (stringIsPoint or stringIsReady or stringIsOk) then
            begin
              SetUnixTaskState(UNIX_TASK_RUNNING);
            end;

          unixTask.lastDateOfActivity := TickCount;

          exit;
        end;
    end;


  (* write DEBUG messages sent by the UnixTasks back in Cassio *)
  if ((s[1] = 'D') and (Pos('DEBUG',s) = 1)) then
    begin
      UnixTaskPrintDebug(s);
      exit;
    end;


  (* write WARNING messages sent by the UnixTasks back in Cassio *)
  if ((s[1] = 'W') and (Pos('WARNING',s) = 1)) then
    begin
      UnixTaskPrintWarning(s);
      exit;
    end;

  (* check if the UnixTask crashed or has been killed by the Unix kernel *)
  if ((Pos('Killed', s) > 0)
      or (Pos('Segmentation fault', s) > 0)
      or (Pos('Bus error', s) > 0)
      or ((Pos('Unix task terminated', s) > 0))
      ) then
    begin
      if (Pos('Killed', s) > 0)
        then UnixTaskPrint('The unix task seems to have been killed by the Unix kernel') else

      if (Pos('Segmentation fault', s) > 0) or (Pos('Bus error', s) > 0)
        then UnixTaskPrint('The unix task seems to have had a problem, as Apollo 13 said');

      if Pos('Unix task terminated', s) <= 0
        then
          SetUnixTaskState(UNIX_TASK_KILLED)
        else
          begin
            dec(unixTask.nbQuitCommandsSent);
            if (unixTask.nbQuitCommandsSent < 0) then
              SetUnixTaskState(UNIX_TASK_KILLED);
          end;

      exit;
    end;

end;


(*
 *******************************************************************************
 *                                                                             *
 *   ReceiveUnixTaskData : fonction de callback passee au bundle intermediaire *
 *   EngineBundle.bundle, chargee de lire les octets sur le buffer d'entree    *
 *   de stdin et de transfomer le flux d'octets en lignes distinctes.          *
 *                                                                             *
 *******************************************************************************
 *)
procedure ReceiveUnixTaskData(theCString : Ptr);
type buffer    = packed array[0 .. kTailleBufferStandardInput - 1] of char;
     bufferPtr = ^buffer;
var i : SInt32;
    myBuffer : bufferPtr;
    c : char;
begin

  with unixTask do
    begin

      while (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexReceptionDataUnixTask, mutex_reception_data) = 0)
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
                  if debugUnixTask or debuggage.engineInput then
                    UnixTaskPrintInput(lastStringReceived.debutLigne);

                  InterpretUnixTaskCommand(lastStringReceived);
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
        UnixTaskPrintError('ERROR dans ReceiveUnixTaskData : le buffer est trop petit');

      mutex_reception_data := 0;

  end;
end;


(*
 *********************************************************************************
 *                                                                               *
 *   SendStringToUnixTask : envoi d'une commande à la tache. On envoie la chaine *
 *   caracteres au bundle intermediaire EngineBundle.bundle via la fonction      *
 *   mySendDataToUnixTaskPtr (pointeur de fonction dans la librairie externe     *
 *   du bundle).                                                                 *
 *                                                                               *
 *********************************************************************************
 *)
procedure SendStringToUnixTask(s : String255);
var data : CFStringRef;
begin
  if (mySendDataToUnixTaskPtr <> NIL) and (unixTask.state <> UNIX_TASK_KILLED) then
    begin

      if (debugUnixTask or debuggage.engineOutput) and (s <> '') then
        begin
          UnixTaskPrintOutput(s);
        end;

      if (s <> '') then
        unixTask.lastStringSent := s;


      data := MakeCFSTR(s);
      mySendDataToUnixTaskPtr(data);
      CFRelease(CFTypeRef(data));
    end;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   GetUnixTaskBundleName : nom du bundle intermediaire de communication.     *
 *   Dans le cas où Cassio est un bundle applicatif (Cassio.app), on renvoie   *
 *   seulement "EngineBundle.bundle" et GetFunctionPointerFromPrivateBundle()  *
 *   saura le chercher dans le dossier "Frameworks" de l'application. Mais si  *
 *   est une applicatiopn PPC, l'utilisateur doit placer le bundle dans le     *
 *   dossier des fichiers auxiliaires de Cassio et on renvoie la path complet  *
 *   vers le bundle EngineBundle.bundle                                        *
 *                                                                             *
 *******************************************************************************
 *)
function GetUnixTaskBundleName : String255;
var bundlePathMac,bundlePathUnix,foo, result : String255;
begin
  if CassioEstUnBundleApplicatif
    then result := 'EngineBundle.bundle'
    else
      begin
        bundlePathMac := pathDossierFichiersAuxiliaires + ':Frameworks:EngineBundle.bundle';
        bundlePathMac := ReplaceStringAll(bundlePathMac,'/',':');   // separateurs a la mode Mac
        SplitAt(bundlePathMac,':',foo,bundlePathUnix);      // enlever le nom du disque dur
        bundlePathUnix := ReplaceStringAll(bundlePathUnix,':','/');  // separateurs a la mode UNIX
        result := bundlePathUnix;
      end;
  GetUnixTaskBundleName := result;
end;


(*
 *********************************************************************************
 *                                                                               *
 *   SwitchToUnixTask : le bundle intermediaire EngineBundle.bundle supporte     *
 *   neufs taches unix simultanes. On peut selectionner celui auquel on veut     *
 *   parler en appelant SwitchToUnixTask(n)  (où 0 <= n <= 9) avant d'employer   *
 *   une autre fonction de ce module.                                            *
 *                                                                               *
 *********************************************************************************
 *)
procedure SwitchToUnixTask(whichChannel : SInt16);
begin

  if (mySwitchToUnixTaskPtr = NIL) then
    mySwitchToUnixTaskPtr := SwitchToUnixTaskProcPtr(GetFunctionPointerFromPrivateBundle( GetUnixTaskBundleName ,'SwitchToUnixTask'));

  if (mySwitchToUnixTaskPtr <> NIL) then
    if (whichChannel >= 0) and (whichChannel <= 1)
      then mySwitchToUnixTaskPtr(whichChannel);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LaunchUNIXProcess : fonction pour essayer de lancer une tache Unix. Le    *
 *   premier argument est le path (au sens Mac) vers l'executable, et le       *
 *   deuxieme la chaine de caracteres des arguments sur la ligne de commande.  *
 *                                                                             *
 *******************************************************************************
 *)
function LaunchUNIXProcess(command, arguments : String255) : OSErr;
begin

  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  exit;
  {$ENDC}

  { WritelnDansRapport('command = ' + command);
    WritelnDansRapport('arguments = ' + arguments); }

  SwitchToUnixTask(0);

  if CanStartUnixTask(command, arguments)
    then
      begin
        Wait(0.5);
        LaunchUNIXProcess := NoErr;
      end
    else
      begin
        WritelnDansRapport('WARNING : launching UNIX command "' + command + '" failed');
        LaunchUNIXProcess := -1;
      end;


  SwitchToUnixTask(0);
  Wait(0.5);
end;




(*
 *******************************************************************************
 *                                                                             *
 *   CanStartUnixTask : fonction pour essayer de lancer une tache Unix.        *
 *                                                                             *
 *******************************************************************************
 *)
function CanStartUnixTask(pathMac, arguments : String255) : boolean;
var pathUnix, foo : String255;
    CFpath, CFarguments : CFStringRef;
    fic : basicfile;
    ok : SInt32;
    bundleName : String255;
    pathIsAnUnixBinary : boolean;
begin

  CanStartUnixTask := false;
  pathIsAnUnixBinary := (Pos('/',pathMac) = 1);


  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  exit;
  {$ENDC}

  if (pathMac = '') then
    exit;


  pathMac := ReplaceStringAll(pathMac,'/',':');      // separateurs a la mode Mac
  if (pathMac[1] = ':')
    then pathUnix := pathMac
    else SplitAt(pathMac,':',foo, pathUnix);         // enlever le nom du disque dur
  pathUnix := ReplaceStringAll(pathUnix,':','/');    // separateurs a la mode UNIX

  if (debugUnixTask or debuggage.engineInput or debuggage.engineOutput) then
    begin
      UnixTaskPrint('');
      UnixTaskPrint('Trying to start   '+pathUnix);
    end;


  if pathIsAnUnixBinary or (FileExists(pathMac,0,fic) = NoErr)
    then
      begin

        bundleName := GetUnixTaskBundleName;

        myStartUnixTaskPtr          := StartUnixTaskProcPtr         (GetFunctionPointerFromPrivateBundle( bundleName, 'StartUnixTask'));
        mySuspendUnixTaskPtr        := SuspendUnixTaskProcPtr       (GetFunctionPointerFromPrivateBundle( bundleName, 'SuspendUnixTask'));
        myResumeUnixTaskPtr         := ResumeUnixTaskProcPtr        (GetFunctionPointerFromPrivateBundle( bundleName, 'ResumeUnixTask'));
        mySendDataToUnixTaskPtr     := SendDataToUnixTaskProcPtr    (GetFunctionPointerFromPrivateBundle( bundleName, 'SendDataToUnixTask'));
        mySetCallBackForUnixTaskPtr := SetCallBackForUnixTaskProcPtr(GetFunctionPointerFromPrivateBundle( bundleName, 'SetCallBackForUnixTask'));
        mySwitchToUnixTaskPtr       := SwitchToUnixTaskProcPtr      (GetFunctionPointerFromPrivateBundle( bundleName ,'SwitchToUnixTask'));


        if (myStartUnixTaskPtr <> NIL) and (mySetCallBackForUnixTaskPtr <> NIL)
          then
            begin

              mySetCallBackForUnixTaskPtr(ReceiveUnixTaskData);


              SetUnixTaskState(UNIX_TASK_STARTING);
              unixTask.lastDateOfActivity   := Tickcount;
              unixTask.lastDateOfPinging    := Tickcount;
              unixTask.suspendCount         := 0;
              unixTask.lastStringSent       := '';
              unixTask.lastDateOfStarting   := TickCount;
              inc(unixTask.nbStartsOfUnixTask);
              InitLongString(unixTask.lastStringReceived);


              CFpath      := MakeCFSTR(pathUnix);
              CFarguments := MakeCFSTR(arguments);

              ok := myStartUnixTaskPtr(CFpath, CFarguments);

              CFRelease(CFTypeRef(CFpath));
              CFRelease(CFTypeRef(CFarguments));

              if (ok = 1)
                then
                  begin
                    CanStartUnixTask := true;
                  end
                else
                  begin
                    mySetCallBackForUnixTaskPtr(NIL);
                    SetUnixTaskState(UNIX_TASK_KILLED);
                    CanStartUnixTask        := false;
                    UnixTaskPrint('Impossible to start an unix task (#' + IntToStr(unixTask.nbStartsOfUnixTask) + ')');
                  end;
            end
          else UnixTaskPrint('(myStartUnixTaskPtr = NIL)');

      end
    else
      begin
        UnixTaskPrint('Executable non trouve:     '+pathMac);
      end;

end;





(*
 *******************************************************************************
 *                                                                             *
 *   DateOfLastActivityByUnixTask() : renvoie, en ticks, la date du dernier    *
 *   message renvoye par la tache unix.                                        *
 *                                                                             *
 *******************************************************************************
 *)
function DateOfLastActivityByUnixTask : SInt32;
begin
  DateOfLastActivityByUnixTask := unixTask.lastDateOfActivity;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   DurationOfLastResultReceivedByUnixTask() : renvoie, en ticks, la date du  *
 *   dernier demarrage d'une tache unix.                                       *
 *                                                                             *
 *******************************************************************************
 *)
function DateOfLastStartOfUnixTask : SInt32;
begin
  DateOfLastStartOfUnixTask := unixTask.lastDateOfStarting;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   TestUnixTaskUnit() : divers tests des fonctions de ce module.             *
 *                                                                             *
 *******************************************************************************
 *)
procedure TestUnixTaskUnit;
var pathMac, arguments : String255;
    positionToSolve : PositionEtTraitRec;
    test : boolean;
    tick : SInt32;
begin

  // pathMac       := 'Glenans:Users:stephane:Desktop:FakeOthelloUnixTask:build:Release:FakeOthelloUnixTask';
  // pathMac       := 'Glenans:Users:stephane:Programmation:Cassio_5.2:Cassio.app:Contents:UnixTasks:CassioUnixTask';
  // pathMac       := 'Glenans:Users:stephane:Desktop:edax:unixTask.sh';
  // pathMac       := 'Glenans:Users:stephane:Desktop:roxane:unixTask.sh';
  // pathMac       := 'Glenans:Users:stephane:Jeux:Othello:Cassio:UnixTasks:edax:unixTask.sh';

  // pathMac := GetUnixTaskPath(0,'edax');

  pathMac := '/usr/bin/blah';

  arguments := 'my-argument';

  if CanStartUnixTask(pathMac, arguments) then
    begin


      if FALSE and ParsePositionEtTrait('--X-OOO---XXOO---XXOXXO-XXOOOOOOXXXXXXOX-XOOOOXX--OOOO-------O--X',positionToSolve) then
        begin

          tick := Tickcount;


          UnixTaskPrint('Waiting 2 seconds...');

          // waiting two seconds
          Wait(2.0);

          interruptionReflexion := pasdinterruption;
          tick := TickCount;

          UnixTaskPrint('...testing the UnixTask...');
          UnixTaskPrint('');

          {test := UnixTaskPeutFaireCalculDeFinale(positionToSolve.position, GetTraitOfPosition(positionToSolve), -1, 0, 100, 0, note, bestDef, foo^);}



          UnixTaskPrint('');
          if test
            then UnixTaskPrint('... OK, test reussi, temps en ticks = ' + IntToStr(TickCount - tick))
            else UnixTaskPrint('... test raté ! temps en ticks = ' + IntToStr(TickCount - tick));
        end;


    end;


end;


(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintColoredStringInRapport : affiche une ligne  en couleur dans  *
 *   le rapport. On protege les ecritures simultanées a l'aide d'un mutex (de  *
 *   sorte que cette procedure soit en section critique) car il peut arriver   *
 *   que plusieures taches envoient des resultats en meme temps a Cassio !     *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintColoredStringInRapport(const s : String255; whichColor : SInt16; whichStyle : StyleParameter);
var ecrireDansRapport : boolean;
begin

  while (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexPrintColoredStringInRapport, mutex_UnixTask_print_colored_string_in_rapport) = 0)
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

  mutex_UnixTask_print_colored_string_in_rapport := 0;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrint : affiche une ligne noire normale dans le rapport.          *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrint(const s : String255);
begin
  UnixTaskPrintColoredStringInRapport(s, NoirCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintDebug : affiche une ligne de debuggage verte dans le rapport *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintDebug(const s : String255);
begin
  UnixTaskPrintColoredStringInRapport(s, VertCmd, normal);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintWarning : affiche une ligne de warning verte dans le rapport *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintWarning(const s : String255);
begin
  UnixTaskPrintColoredStringInRapport(s, VertCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintInput : affiche les lignes recues de la tache en orange      *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintInput(const s : String255);
begin
  // les infos de DEBUG et WARNING seront de toute façon écrites en vert,
  // donc pas besoin de les ecrire en orange...
  if ((s[1] = 'D') and (Pos('DEBUG',s) = 1))  or
     ((s[1] = 'W') and (Pos('WARNING',s) = 1))
    then exit;
  UnixTaskPrintColoredStringInRapport(s, OrangeCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintOutput : affiche les lignes envoyees à la tache en violet    *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintOutput(const s : String255);
begin
  UnixTaskPrintColoredStringInRapport(s, VioletCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   UnixTaskPrintError : affiche les erreurs en rouge gras dans le rapport.   *
 *                                                                             *
 *******************************************************************************
 *)
procedure UnixTaskPrintError(const s : String255);
begin

  if ((TickCount - lastTickOfUnixTaskErrorInRapport) > 30) then
    begin
      UnixTaskPrintColoredStringInRapport('current unix task = ' + '???', RougeCmd, bold);
      UnixTaskPrintColoredStringInRapport('last command = ' + UnixTask.lastCommandSent, RougeCmd, bold);
    end;

  UnixTaskPrintColoredStringInRapport(s, RougeCmd, bold);

  lastTickOfUnixTaskErrorInRapport := TickCount;
end;






END.

















