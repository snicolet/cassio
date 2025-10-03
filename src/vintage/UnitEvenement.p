UNIT  UnitEvenement;


INTERFACE


 USES UnitDefCassio , QuickDraw;


(*********************** Event handlers ***************************)

procedure TraiteOneEvenement;                                                                                                                                                       ATTRIBUTE_NAME('TraiteOneEvenement')
procedure TraiteEvenements;                                                                                                                                                         ATTRIBUTE_NAME('TraiteEvenements')
procedure TraiteNullEvent(var whichEvent : eventRecord);                                                                                                                            ATTRIBUTE_NAME('TraiteNullEvent')

function HasGotEvent(myEventMask : EventMask; var whichEvent : eventRecord; sleep : UInt32; mouseRgn : RgnHandle) : boolean;                                                        ATTRIBUTE_NAME('HasGotEvent')
procedure HandleEvent(var whichEvent : eventRecord);                                                                                                                                ATTRIBUTE_NAME('HandleEvent')



(*********************** Key down and up utilities *****************)

procedure StoreKeyDownEvent(var whichEvent : eventRecord);                                                                                                                          ATTRIBUTE_NAME('StoreKeyDownEvent')
procedure SetRepetitionDeToucheEnCours(flag : boolean);                                                                                                                             ATTRIBUTE_NAME('SetRepetitionDeToucheEnCours')
function RepetitionDeToucheEnCours : boolean;                                                                                                                                       ATTRIBUTE_NAME('RepetitionDeToucheEnCours')
function DateOfLastKeyDownEvent : SInt32;                                                                                                                                           ATTRIBUTE_NAME('DateOfLastKeyDownEvent')
function DateOfLastKeyboardOperation : SInt32;                                                                                                                                      ATTRIBUTE_NAME('DateOfLastKeyboardOperation')
function NoDelayAfterKeyboardOperation : boolean;                                                                                                                                   ATTRIBUTE_NAME('NoDelayAfterKeyboardOperation')
procedure RemoveDelayAfterKeyboardOperation;                                                                                                                                        ATTRIBUTE_NAME('RemoveDelayAfterKeyboardOperation')
procedure SimulateNumericKeyPad(var whichChar : char);                                                                                                                              ATTRIBUTE_NAME('SimulateNumericKeyPad')


(******************** Tell Cassio to suspend checking "dangerous" event (which can change the move number) *******************)
procedure SetCassioMustCheckDangerousEvents(newvalue : boolean; oldValue : BooleanPtr);                                                                                             ATTRIBUTE_NAME('SetCassioMustCheckDangerousEvents')
function CassioCanCheckForDangerousEvents : boolean;                                                                                                                                ATTRIBUTE_NAME('CassioCanCheckForDangerousEvents')





(********************************************************************)


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyKeyMapUtils, SNEvents, UnitModes, UnitActions, UnitCommentaireArbreDeJeu
    , UnitGestionDuTemps, UnitCurseur, UnitJaponais, UnitSelectionRapideListe, UnitMenus, UnitLiveUndo, UnitFenetres, UnitEntreeTranscript
    , UnitListe ;
{$ELSEC}
    ;
    {$I prelink/Evenement.lk}
{$ENDC}


{END_USE_CLAUSE}




var lastSleepUsed : SInt32;



procedure TraiteOneEvenement;
var doitTraiterEvenement : boolean;
    modifiersChanged : boolean;
    tickCountDepart : SInt32;
begin

  tickCountDepart := TickCount;

  (*
  WriteNumDansRapport('Debut de TraiteOneEvenement, kWNESleep = ',kWNESleep);
  WriteNumDansRapport('  latenceEntreDeuxDoSystemTask = ',latenceEntreDeuxDoSystemTask);
  WriteNumDansRapport('  tickCountDepart = ',tickCountDepart);
  WritelnNumDansRapport('  delta = ',TickCount - tickCountDepart);
  *)

  if (theEvent.what = mouseDown) |
     (theEvent.what = mouseUp)   |
     (theEvent.what = keyUp)     |
     (theEvent.what = keyDown)   |
     (theEvent.what = autoKey)   |
     (theEvent.what = nullEvent)
     then MetFlagsModifiersDernierEvenement(theEvent,modifiersChanged);

  if debuggage.evenementsDansRapport then
    begin
      if DernierEvenement.command
        then WritelnDansRapport('command = TRUE')
        else WritelnDansRapport('command = FALSE');
    end;


  FaireClignoterFenetreArbreDeJeu;
  if modifiersChanged then
    begin
      TesterAffichageNomsDesGagnantsEnGras(theEvent.modifiers);
      TesterAffichageNomsJaponaisEnRoman(theEvent.modifiers);
    end;

  doitTraiterEvenement := not(EvenementTraiteParFenetreArbreDeJeu(theEvent));

  if doitTraiterEvenement then
    begin
		  if debuggage.evenementsDansRapport then
			  CASE theEvent.what of
			      mouseDown       :  WritelnDansRapport('TraiteOneEvenement : MouseDownEvents ');
			      mouseUp         :  WritelnDansRapport('TraiteOneEvenement : MouseUpEvents ');
			      keyUp           :  WritelnDansRapport('TraiteOneEvenement : KeyUpEvents ');
			      keyDown         :  WritelnDansRapport('TraiteOneEvenement : KeyDownEvents   ');
			      autoKey         :  WritelnDansRapport('TraiteOneEvenement : KeyDownEvents   ');
			      updateEvt       :  WritelnDansRapport('TraiteOneEvenement : UpdateEvents;   ');
			      activateEvt     :  WritelnDansRapport('TraiteOneEvenement : ActivateEvents; ');
			      osEvt           :  WritelnDansRapport('TraiteOneEvenement : MultiFinderEvents; ');
			      diskEvt         :  WritelnDansRapport('TraiteOneEvenement : DiskEvents');
			      kHighLevelEvent :  WritelnDansRapport('TraiteOneEvenement : AppleEvents');
			      nullEvent       :  WritelnDansRapport('TraiteOneEvenement : nullEvent');
			      otherwise          WritelnDansRapport('TraiteOneEvenement : evenement inconnu !!!!');
			  END;    {case}
			if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(theEvent);
		  CASE theEvent.what of
		      mouseDown       : MouseDownEvents;
		      mouseUp         : MouseUpEvents;
		      keyUp           : KeyUpEvents;
		      keyDown         : KeyDownEvents;
		      autoKey         : KeyDownEvents;
		      updateEvt       : UpdateEvents;
		      activateEvt     : ActivateEvents;
		      osEvt           : MultiFinderEvents;
		      kHighLevelEvent : DoAppleEvents;
		  END;   {case}
    end;
  DiminueLatenceEntreDeuxDoSystemTask;
  AccelereProchainDoSystemTask(60);

  if arbreDeJeu.doitResterEnModeEdition then ActiverModeEditionFenetreArbreDeJeu;

  AjusteCurseur;
  SwitchToRomanScript;


  GererDemandesChangementDeConfig;

  {
  WriteNumDansRapport('Fin de TraiteOneEvenement, kWNESleep = ',kWNESleep);
  WriteNumDansRapport('  latenceEntreDeuxDoSystemTask = ',latenceEntreDeuxDoSystemTask);
  WriteNumDansRapport('  tickCountDepart = ',tickCountDepart);
  WriteNumDansRapport('  delta = ',TickCount - tickCountDepart);
  WritelnNumDansRapport('  delaiAvantDoSystemTask = ',delaiAvantDoSystemTask);
  }


end;


procedure TraiteEvenements;
var nbreAttentes : SInt32;
    precedente : String255;
begin
  nbreAttentes := 0;
  precedente := '';
  repeat
    {WritelnNumDansRapport('nbreCoup = ',nbreCoup);}

    PartagerLeTempsMachineAvecLesAutresProcess(0);  (* 0 = kCassioGetsAll *)
    EssaieUpdateEventsWindowPlateau;
    TraiteOneEvenement;
    if EstEnAttenteSelectionRapideDeListe then
      inc(nbreAttentes);
    EssaieUpdateEventsWindowPlateau;
    if enSetUp
      then FixeMarquesSurMenus
      else
         while HasGotEvent(updateMask,theEvent,0,NIL) do
           begin
             if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(theEvent);
             UpdateEvents;
           end;
    PartagerLeTempsMachineAvecLesAutresProcess(0);  (* 0 = kCassioGetsAll *)
    if globalRefreshNeeded then DoGlobalRefresh;

    {si la vitesse du Mac est assez grande, on peut essayer la selection rapide
     dans la liste a la volee}
    if (indiceVitesseMac > 250) & (nbreAttentes > 0) & (GetDerniereChaineSelectionRapide <> precedente) then
      begin
        TraiteSelectionRapideDeListe(GetDernierGenreSelectionRapide,GetDerniereChaineSelectionRapide);
        precedente := GetDerniereChaineSelectionRapide;
      end;

  until not(HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)) &
        not(EstEnAttenteSelectionRapideDeListe);

  if (nbreAttentes > 0) & (GetDerniereChaineSelectionRapide <> precedente) then
    begin
      TraiteSelectionRapideDeListe(GetDernierGenreSelectionRapide,GetDerniereChaineSelectionRapide);
      precedente := GetDerniereChaineSelectionRapide;
    end;

  AjusteSleep;
  AjusteCurseur;
end;


{remplacement de WaitNextEvent qui prend en compte le systeme japonais}
function HasGotEvent(myEventMask : EventMask; var whichEvent : eventRecord; sleep : UInt32; mouseRgn : RgnHandle) : boolean;
var gotEvent : boolean;
    (* OSErreur : OSErr; *)
    localEventMask : EventMask;
begin

  if CassioCanCheckForDangerousEvents
    then GererLiveUndo;

  // if the global variable gCassioChecksEvents is false,
  // then we only want minimalist event checking, so we filter the eventMask

  if not(gCassioChecksEvents)
    then localEventMask := BAnd(mDownMask + highLevelEventMask + osMask, myEventMask)
    else localEventMask := myEventMask;


  // if the function CassioCanCheckForDangerousEvents returns false, that means
  // that Cassio is probably inside a function which can change the current move number
  // of the game, and since these functions are not reentrant we disable the kind of
  // events which can lead to another move change...

  if not(CassioCanCheckForDangerousEvents) then
     localEventMask := localEventMask and not(mDownMask + keyDownMask + autoKeyMask + highLevelEventMask);

  {
  if sleep <> lastSleepUsed then
    begin
      WritelnNumDansRapport('sleep = ',sleep);
      lastSleepUsed := sleep;
    end;
  }

  gotEvent := WaitNextEvent(localEventMask,whichEvent,sleep,mouseRgn);


  (*
  OSErreur := SetScriptManagerVariable(smFontForce,gSavedFontForce);
  gotEvent := WaitNextEvent(localEventMask,whichEvent,sleep,mouseRgn);

  { clear fontForce again so it doesn't upset our operations }
  gSavedFontForce := GetScriptManagerVariable(smFontForce);
  OSErreur := SetScriptManagerVariable(smFontForce, 0);
  *)


  {if gotEvent then WritelnNumDansRapport('nbreCoup = ',nbreCoup);}

  (*
  if gotEvent &
     ((whichEvent.what = keyDown) | (whichEvent.what = autoKey)) then
     begin
       CASE whichEvent.what of
	      mouseDown       :  WritelnDansRapport('gotEvent : MouseDownEvents ');
	      mouseUp         :  WritelnDansRapport('gotEvent : MouseUpEvents ');
	      keyUp           :  WritelnDansRapport('gotEvent : KeyUpEvents ');
	      keyDown         :  WritelnDansRapport('gotEvent : KeyDownEvents   ');
	      autoKey         :  WritelnDansRapport('gotEvent : autoKeyEvents   ');
	      updateEvt       :  WritelnDansRapport('gotEvent : UpdateEvents;   ');
	      activateEvt     :  WritelnDansRapport('gotEvent : ActivateEvents; ');
	      osEvt           :  WritelnDansRapport('gotEvent : MultiFinderEvents; ');
	      diskEvt         :  WritelnDansRapport('gotEvent : DiskEvents');
	      kHighLevelEvent :  WritelnDansRapport('gotEvent : AppleEvents');
	      nullEvent       :  WritelnDansRapport('gotEvent : nullEvent');
	     END;    {case}

	     WritelnNumDansRapport('  localEventMask = ',localEventMask);
	     WritelnNumDansRapport('  sleep = ',sleep);
	     WritelnNumDansRapport('  delaiAvantDoSystemTask = ',delaiAvantDoSystemTask);
	     WritelnNumDansRapport('  latenceEntreDeuxDoSystemTask = ',latenceEntreDeuxDoSystemTask);
       WritelnNumDansRapport('  TickCount = ',TickCount);
	     WritelnStringAndBoolDansRapport('  CassioCanCheckForDangerousEvents = ',CassioCanCheckForDangerousEvents);
	     WritelnStringAndBoolDansRapport('  gCassioChecksEvents = ',gCassioChecksEvents);
	     WritelnDansRapport('');
     end;
  *)


	HasGotEvent := gotEvent;
end;

procedure HandleEvent(var whichEvent : eventRecord);
begin
  theEvent := whichEvent;
  TraiteOneEvenement;
end;


procedure TraiteNullEvent(var whichEvent : eventRecord);
var modifiersChanged : boolean;
begin
  if debuggage.evenementsDansRapport then
	  CASE whichEvent.what of
	      mouseDown       :  WritelnDansRapport('TraiteNullEvent : MouseDownEvents ');
	      mouseUp         :  WritelnDansRapport('TraiteNullEvent : MouseUpEvents ');
	      keyUp           :  WritelnDansRapport('TraiteNullEvent : KeyUpEvents ');
	      keyDown         :  WritelnDansRapport('TraiteNullEvent : KeyDownEvents   ');
	      autoKey         :  WritelnDansRapport('TraiteNullEvent : AutoKeyEvents   ');
	      updateEvt       :  WritelnDansRapport('TraiteNullEvent : UpdateEvents;   ');
	      activateEvt     :  WritelnDansRapport('TraiteNullEvent : ActivateEvents; ');
	      osEvt           :  WritelnDansRapport('TraiteNullEvent : MultiFinderEvents; ');
	      diskEvt         :  WritelnDansRapport('TraiteNullEvent : DiskEvents');
	      kHighLevelEvent :  WritelnDansRapport('TraiteNullEvent : AppleEvents');
	      nullEvent       :  WritelnDansRapport('TraiteNullEvent : nullEvent');
	  END;    {case}
  if (whichEvent.what = nullEvent) then
    begin
      MetFlagsModifiersDernierEvenement(whichEvent,modifiersChanged);

      if debuggage.evenementsDansRapport then
        begin
          WritelnDansRapport('');
          if DernierEvenement.command
            then WritelnDansRapport('command = TRUE')
            else WritelnDansRapport('command = FALSE');
          WritelnDansRapport('');
        end;


      if modifiersChanged then
        begin
          TesterAffichageNomsDesGagnantsEnGras(whichEvent.modifiers);
          TesterAffichageNomsJaponaisEnRoman(whichEvent.modifiers);
        end;
    end;
  SwitchToRomanScript;
end;


procedure SimulateNumericKeyPad(var whichChar : char);
begin

  if EnModeEntreeTranscript then
    begin
      
      if FenetreListeEstEnModeEntree then
        exit(SimulateNumericKeyPad);
    
      if EnTraitementDeTexte & FenetreRapportEstOuverte & FenetreRapportEstAuPremierPlan then
        exit(SimulateNumericKeyPad);

      if (whichChar = '@')  | (whichChar = '#') then whichChar := '0' else
      if (whichChar = '&')  | (whichChar = '1') then whichChar := '1' else
      if (whichChar = 'é')  | (whichChar = '2') then whichChar := '2' else
      if (whichChar = '"')  | (whichChar = '3') then whichChar := '3' else
      if (whichChar = '''') | (whichChar = '4') then whichChar := '4' else
      if (whichChar = '(')  | (whichChar = '5') then whichChar := '5' else
      if (whichChar = '§')  | (whichChar = '6') then whichChar := '6' else
      if (whichChar = 'è')  | (whichChar = '7') then whichChar := '7' else
      if (whichChar = '!')  | (whichChar = '8') then whichChar := '8' else
      if (whichChar = 'ç')  | (whichChar = '9') then whichChar := '9' else
      if (whichChar = 'à')  | (whichChar = '0') then whichChar := '0' else
      if (whichChar = 'u')  | (whichChar = 'U') then whichChar := '4' else
      if (whichChar = 'i')  | (whichChar = 'I') then whichChar := '5' else
      if (whichChar = 'o')  | (whichChar = 'O') then whichChar := '6' else
      if (whichChar = 'j')  | (whichChar = 'J') then whichChar := '1' else
      if (whichChar = 'k')  | (whichChar = 'K') then whichChar := '2' else
      if (whichChar = 'l')  | (whichChar = 'L') then whichChar := '3' else
      if (whichChar = 'n')  | (whichChar = 'N') then whichChar := '0' else  // AZERTY
      if (whichChar = 'm')  | (whichChar = 'M') then whichChar := '0' else  // QWERTY
      if (whichChar = ',')  | (whichChar = '?') then whichChar := '0';



      (*
      else
      if (whichChar = ',') | (whichChar = '?') then whichChar := '0' else
      if (whichChar = ',') | (whichChar = '?') then whichChar := '0' else
      if (whichChar = ',') | (whichChar = '?') then whichChar := '0' else
      if (whichChar = ',') | (whichChar = '?') then whichChar := '0' else
      *)

    end;
end;


procedure StoreKeyDownEvent(var whichEvent : eventRecord);
begin
  with gKeyDownEventsData do
    begin

      delaiAvantDebutRepetition := 15;  {1/4eme de seconde}

      if (whichEvent.message <> lastEvent.message) |
         (TickCount >= tickFrappeTouche + 15)
        then
          begin
            tickFrappeTouche                               := TickCount;
            tickChangementClavier                          := tickFrappeTouche;
            tickcountMinimalPourNouvelleRepetitionDeTouche := 0;
            noDelay                                        := false;
          end;

      lastEvent       := whichEvent;
      lastEvent.what  := keyDown;
      whichEvent.what := keyDown;

      MyGetKeys(theKeys);
      theChar := chr(BAnd(whichEvent.message,charCodemask));
      keyCode := BSr(BAnd(whichEvent.message,keyCodeMask),8);

      if (BAnd(whichEvent.modifiers,cmdKey) = 0)
        then SimulateNumericKeyPad(theChar);

    end;
end;


procedure SetRepetitionDeToucheEnCours(flag : boolean);
begin
  gKeyDownEventsData.repetitionEnCours := flag;
end;


function RepetitionDeToucheEnCours : boolean;
begin
  RepetitionDeToucheEnCours := gKeyDownEventsData.repetitionEnCours;
end;


function DateOfLastKeyDownEvent : SInt32;
begin
  DateOfLastKeyDownEvent := gKeyDownEventsData.tickFrappeTouche;
end;


function DateOfLastKeyboardOperation : SInt32;
begin
  DateOfLastKeyboardOperation := gKeyDownEventsData.tickChangementClavier;
end;


function NoDelayAfterKeyboardOperation : boolean;
begin
  NoDelayAfterKeyboardOperation := gKeyDownEventsData.noDelay;
end;


procedure RemoveDelayAfterKeyboardOperation;
begin
  gKeyDownEventsData.noDelay := true;
end;


const gCassioMustCheckDangerousEvents : boolean = true;

procedure SetCassioMustCheckDangerousEvents(newvalue : boolean; oldValue : BooleanPtr);
begin
  if (oldValue <> NIL) then
    oldValue^ := gCassioMustCheckDangerousEvents;
  gCassioMustCheckDangerousEvents := newValue;
end;


function CassioCanCheckForDangerousEvents : boolean;
begin
  CassioCanCheckForDangerousEvents := gCassioMustCheckDangerousEvents;
end;


END.






























