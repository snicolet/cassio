UNIT  UnitRapportUtils;


INTERFACE


 USES UnitDefCassio , Events, Scrap;


function CreateRapport : boolean;
function DetruitRapport : boolean;


procedure ClicInRapport(evt : eventRecord);
procedure EcritKeyDownEventDansRapport(evt : eventRecord);



{quelques fonction d'acces}
function CollerDansRapport : boolean;
function CopierFromRapport : boolean;
function CouperFromRapport : boolean;
function EffacerDansRapport : boolean;
function SelectionneToutDansRapport : boolean;





procedure AnnonceScoreFinalDansRapport;
procedure AnnonceOuvertureFichierEnRougeDansRapport(nomFichier : String255);
procedure AnnonceSupposeSuitConseilMac(numeroCoup,conseil : SInt16);



function SelectionRapportEstUnePartieLegale(var partieAlpha : String255) : boolean;


procedure EcritBienvenueDansRapport;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitRapportTypes, ControlDefinitions, MacWindows, QuickdrawText
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitRapportImplementation, UnitJaponais, UnitRapport, UnitJeu
    , UnitModes, MyFonts, MyStrings, UnitCarbonisation, UnitDialog, SNEvents, UnitRetrograde, UnitSetUp
    , UnitPressePapier, UnitScannerUtils, UnitFenetres, UnitServicesDialogs, UnitScannerOthellistique, UnitModes, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/RapportUtils.lk}
{$ENDC}


{END_USE_CLAUSE}















function MyFenetreFictiveAvantPlan : WindowPtr;
begin
  MyFenetreFictiveAvantPlan := MAKE_MEMORY_POINTER(-1);
end;



function CreateRapport : boolean;
var r : Rect;
    titre : String255;
    err : OSErr;
    theTSMDoc : TSMDocumentID;
begin
  CreateRapport := false;
  rapport.theWindow := NIL;
  rapport.prochaineAlerteRemplissage := maxTextEditSize-2000;
  with rapport do
    begin
      titre := ReadStringFromRessource(TitresFenetresTextID,5);
      theWindow := MyNewCWindow(NIL, FntrRapportRect, titre, False, zoomDocProc, MyFenetreFictiveAvantPlan, True, 1);
      if theWindow <> NIL then
        begin
          SetPortByWindow(theWindow);
          TextFont(gCassioApplicationFont);

          if gIsRunningUnderMacOSX
            then TextSize(12)
            else TextSize(9);
          {TextSize(GetDefFontSize);}

          r := GetWindowPortRect(rapport.theWindow);
          InsetRect(r, TEdecalage, TEdecalage);
          theText := TEStyleNew(r, r);
          if theText <> NIL then
            begin
              { Adaptation de la taille standard de la fenêtre de telle façon que }
              { les lignes du texte ne soient jamais coupées en bas par l'ascenseur. }
              r := GetWindowPortRect(rapport.theWindow);
              while ((r.bottom - 15) - (r.top + TEdecalage)) MOD vUnit <> 0 do
                 dec(r.bottom);
              while ((r.right - 15) - (r.left + TEdecalage)) MOD hUnit <> 0 do
                 dec(r.right);
              SizeWindow(theWindow, r.right - r.left, r.bottom - r.top, False);
              CalculateViewAndDestRapport;
              SetDeroulementAutomatiqueDuRapport(true);



              { Création des deux ascenseurs }
              r := GetWindowPortRect(rapport.theWindow);
              InsetRect(r, -1, -1);
              r.top := r.bottom - 16;
              r.right := r.right - 15;
              hScroller := NewControl(theWindow, r, StringToStr255(''), True, 1, 1, 210, scrollBarProc, 0);
              r := GetWindowPortRect(rapport.theWindow);
              InsetRect(r, -1, -1);
              r.left := r.right - 16;
              r.bottom := r.bottom - 15;
              vScroller := NewControl(theWindow, r, StringToStr255(''), True, 1, 1, 1, scrollBarProc, 0);

              TextNormalDansRapport;

              theTSMDoc := GetTSMDocOfRapport;

              err := AddTSMTESupport(theWindow,theText,theTSMDoc,docTSMTERecHandle);

              SwitchToRomanScript;

              changed := False;
              fileName := '';
              CreateRapport := true;
            end;
        end;
   end;
end;


function DetruitRapport : boolean;
begin
    DetruitRapport := True;
    with rapport do
       begin
         RemoveTSMTESupport(docTSMDoc);
         if (theText <> NIL) then
           begin
             TEDispose(theText);
             theText := NIL;
           end;
         if (theWindow <> NIL) then
           begin
             DisposeWindow(theWindow);
             theWindow := NIL;
           end;
         windowRapportOpen := false;
       end;
end;



procedure EcritBienvenueDansRapport;
var oldscript : SInt32;
    oldEcritureDansRapportLog : boolean;
    policeMise : boolean;
    niceJapaneseFont : SInt16;
    niceRomanFont : SInt16;
    s : String255;
begin
  oldEcritureDansRapportLog := GetEcritToutDansRapportLogDansImplementation;
  SetEcritToutDansRapportLogDansImplementation(false);
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  WritelnDansRapport('');
  EnableKeyboardScriptSwitch;
  FinRapport;
  ChangeFontColorDansRapport(VertCmd);
  ChangeFontFaceDansRapport(bold);
  ChangeFontSizeDansRapport(24);
  policeMise := false;
  if not(gVersionJaponaiseDeCassio) and not(policeMise) then
    begin
      niceRomanFont := MyGetFontNum('Bookman');
      if niceRomanFont > 0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if not(gVersionJaponaiseDeCassio) and not(policeMise) then
    begin
      niceRomanFont := MyGetFontNum('Comic Sans MS');
      if niceRomanFont > 0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if not(gVersionJaponaiseDeCassio) and not(policeMise) then
    begin
      niceRomanFont := MyGetFontNum('Times');
      if niceRomanFont > 0 then
        begin
          ChangeFontDansRapport(niceRomanFont);
          policeMise := true;
        end;
    end;
  if gVersionJaponaiseDeCassio and not(policeMise) then
    begin
      niceJapaneseFont := MyGetFontNum('ñ{ñæí©ÅorÇl');
      if niceJapaneseFont > 0 then
        begin
          ChangeFontDansRapport(niceJapaneseFont);
          policeMise := true;
        end;
    end;
  if gVersionJaponaiseDeCassio and not(policeMise) then
    begin
      niceJapaneseFont := MyGetFontNum('ä€ÉSÉVÉbÉNÅorÇl');
      if niceJapaneseFont > 0 then
        begin
          ChangeFontDansRapport(niceJapaneseFont);
          policeMise := true;
        end;
    end;
  if not(policeMise) then ChangeFontDansRapport(gCassioApplicationFont);
  s := ReadStringFromRessource(TextesRapportID,1);
  SetLongueurMessageBienvenueDansCassio(LENGTH_OF_STRING(s));
  WritelnDansRapport(s);  {'Bienvenue…'}

  SelectionnerTexteDansRapport(0,1);
  ChangeFontSizeDansRapport(9);

  FinRapport;
  TextNormalDansRapport;
  ChangeFontSizeDansRapport(9);
  WritelnDansRapport('');
  WritelnDansRapport('');
  TextNormalDansRapport;
  EnableKeyboardScriptSwitch;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
  SetEcritToutDansRapportLogDansImplementation(oldEcritureDansRapportLog);
end;




procedure ClicInRapport(evt : eventRecord);
var ch: ControlHandle;
    trackScrollingRapportUPP  : ControlActionUPP;
    part : SInt16;
    oldport : grafPtr;
   {oldValue : SInt16}
    oldScript,posMilieuMot : SInt32;
    modifiers : SInt16;
    where : Point;
    partieLegale : String255;
begin
  modifiers := evt.modifiers;
  where := evt.where;

  GetPort(oldport);
  with rapport do
    if (theWindow <> NIL) and (theText <> NIL) then
     begin
        SetPortByWindow(theWindow);
        GlobalToLocal(where);
        part := FindControl(where, theWindow, ch);
        case part OF
        kControlDownButtonPart, kControlPageDownPart, kControlUpButtonPart, kControlPageUpPart:
          begin
            if GetControlMaximum(ch) > 1 then
              begin
                trackScrollingRapportUPP := NewControlActionUPP(TrackScrollingRapport);
                if TrackControl(ch, where, trackScrollingRapportUPP) = part then DoNothing;
                MyDisposeControlActionUPP(trackScrollingRapportUPP);
              end;
          end;
        kControlIndicatorPart:
            begin
              if MyTrackControlIndicatorPartRapport(ch) = kControlIndicatorPart then DoNothing;

           {
           oldValue := GetControlValue(ch);
           if TrackControl(ch, where, NIL) = kControlIndicatorPart then
             begin
                    if ch = vScroller then TEScroll(0, (oldValue - GetControlValue(ch)) * vUnit, theText) else
                    if ch = hScroller then TEScroll((oldValue - GetControlValue(ch)) * hUnit, 0, theText);
             end;
           }
             end;
          otherwise
            begin
             if (where.h < GetWindowPortRect(rapport.theWindow).right-15) and
                (where.v < GetWindowPortRect(rapport.theWindow).bottom-15)
               then
                 begin
                   GetCurrentScript(oldScript);
                   DisableKeyboardScriptSwitch;
                   TEClick(where, BAND(modifiers, shiftKey) <> 0, rapport.theText);

                   posMilieuMot := GetMilieuSelectionRapport;

                   if EstUnDoubleClic(evt,false) and
                      EstDansBanniereAnalyseRetrograde(posMilieuMot)
                     then SelectionneAnalyseRetrograde(posMilieuMot);

                   if EstUnDoubleClic(evt,false) and
                      FenetreRapportEstOuverte and
		                  SelectionRapportNonVide and
		                  (BAND(theEvent.modifiers,optionKey) <> 0) and
		                  SelectionRapportEstUnePartieLegale(partieLegale) and
		                  PeutArreterAnalyseRetrograde
		                 then PlaquerPartieLegale(partieLegale,kRejouerLesCoupsEnDirect);

                   EnableKeyboardScriptSwitch;
                   SetCurrentScript(oldScript);
                   SwitchToRomanScript;
                 end;
            end;
         end; {case}
        UpdateScrollersRapport;
     end;
  SetPort(oldport);
end;




procedure AnnonceScoreFinalDansRapport;
var s,s1 : String255;
    oldScript : SInt32;
begin
  if gameOver and not(HumCtreHum) and not(enTournoi) then
    if not(CassioEstEnModeSolitaire) then
      begin
        s := IntToStr(nbreDePions[pionNoir]);
        s1 := IntToStr(nbreDePions[pionBlanc]);
        s1 := s+CharToString('-')+s1;
        s := ParamStr(ReadStringFromRessource(TextesRapportID,7),s1,'','','');  {'score final ^0'}
        if not(HumCtreHum) and not(CassioEstEnModeAnalyse) then
          if ((nbreDePions[pionNoir] > 32) and (couleurMacintosh = pionBlanc)) or
             ((nbreDePions[pionBlanc] > 32) and (couleurMacintosh = pionNoir))
             then s := s + '. ' + ReadStringFromRessource(TextesRapportID,8)    {'Félicitations !'}
             else s := s + '. ' + ReadStringFromRessource(TextesRapportID,9);   {'Voulez-vous en faire une autre ?'}


        if ((s+chr(13)) <> LastStringEcriteDansRapport) then
          begin
            GetCurrentScript(oldScript);
            DisableKeyboardScriptSwitch;
            FinRapport;
            TextNormalDansRapport;
            WritelnDansRapport('');

            ChangeFontSizeDansRapport(gCassioRapportBoldSize);
            ChangeFontDansRapport(gCassioRapportBoldFont);

            ChangeFontFaceDansRapport(bold);
            ChangeFontColorDansRapport(VertCmd);
            WritelnDansRapport(s);
            WritelnDansRapport('');
            EnableKeyboardScriptSwitch;
            SetCurrentScript(oldScript);
            SwitchToRomanScript;
            TextNormalDansRapport;
          end;
      end;
end;

procedure AnnonceOuvertureFichierEnRougeDansRapport(nomFichier : String255);
begin
  if not(EstUnNomDeFichierTemporaireDePressePapier(nomFichier)) then
    begin
		  FinRapport;
		  TextNormalDansRapport;

      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);

		  ChangeFontFaceDansRapport(bold);
		  ChangeFontColorDansRapport(VertSapinCmd);
		  WritelnDansRapportSync('',false);
		  WritelnDansRapportSync('### '+nomfichier+' ###',false);
		  WritelnDansRapportSync('',false);
		  TextNormalDansRapport;
		end;
end;


procedure AnnonceSupposeSuitConseilMac(numeroCoup,conseil : SInt16);
var s,s1 : String255;
    oldScript : SInt32;
begin
  if not(CassioEstEnModeSolitaire) and not(jeuInstantane) then
    begin
      s1 := IntToStr(numeroCoup);
      s := ReadStringFromRessource(TextesRapportID,10);   {'conseil'}
      s := '   '+ParamStr(s,s1+CharToString('.')+CoupEnString(conseil,CassioUtiliseDesMajuscules),'','','');
      {FrappeClavierDansRapport(chr(RetourArriereKey));}
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      WritelnDansRapport(s);
      TextNormalDansRapport;
      EnableKeyboardScriptSwitch;
      SetCurrentScript(oldScript);
      SwitchToRomanScript;
    end;
end;




procedure EcritKeyDownEventDansRapport(evt : eventRecord);
var ch,ch2 : char;
    option,command,shift,control,verouillage : boolean;
    keyCode : SInt16;
    s : String255;
begin
  shift := BAND(evt.modifiers,shiftKey) <> 0;
  verouillage := BAND(evt.modifiers,alphaLock) <> 0;
  command := BAND(evt.modifiers,cmdKey) <> 0;
  option := BAND(evt.modifiers,optionKey) <> 0;
  control := BAND(evt.modifiers,controlKey) <> 0;

  ch := chr(BAND(evt.message,charCodemask));
  keyCode := BSR(BAND(theEvent.message,keyCodeMask),8);

  s := '';
  if theEvent.what = keyDown then s := s + 'keyDown';
  if theEvent.what = autoKey then s := s + 'autoKey';

  s := s + ' caractère="'+ch+'"';
  s := s + ' ord = '+IntToStr(ord(ch));
  s := s + '  keycode = '+IntToStr(keycode);
  if shift        then s := s + '  shift = true'        else s := s + '  shift = false';
  if command      then s := s + '  command = true'      else s := s + '  command = false';
  if option       then s := s + '  option = true'       else s := s + '  option = false';
  if control      then s := s + '  control = true'      else s := s + '  control = false';
  if verouillage  then s := s + '  verrouillage = true' else s := s + '  verrouillage = false';
  WritelnDansRapport('');
  WritelnDansRapport(s);

  if control then
    begin
      ch2 := QuelCaractereDeControle(ch,shiftorverouillage);
      s := 'touche controle appuyée,  ';
      s := s + 'caractère =  ^'+ch2;
      WritelnDansRapport(s);
    end;
end;

function CollerDansRapport : boolean;
begin
  collerDansRapport := false;
  with rapport do
  if windowRapportOpen and (theText <> NIL) then
   if (theWindow = FrontWindowSaufPalette) and (LongueurPressePapier(MY_FOUR_CHAR_CODE('TEXT')) > 0)
    then
     begin
       // Le presse-Papier contient du TEXT, mais le rapport
       // a-t-il assez de place libre pour le recevoir ?
       if TEGetScrapLength < (maxTextEditSize - GetTailleRapport)
         then
           begin
             TEStylePaste(theText);
             UpdateScrollersRapport;
             collerDansRapport := true;
           end
         else
           begin
             AlerteSimple(ReadStringFromRessource(TextesRapportID,27));
           end;
     end;
end;

function CouperFromRapport : boolean;
begin
  couperFromRapport := false;
  with rapport do
  if windowRapportOpen and (theText <> NIL) then
    if SelectionRapportNonVide  then
      if theWindow = FrontWindowSaufPalette then
        begin
         TECut(theText);
         UpdateScrollersRapport;
         {if (ZeroScrap = noErr) then
           if (TEToScrap = noErr) then DoNothing;}
         couperFromRapport := true;
        end;
end;

function CopierFromRapport : boolean;
begin
  copierFromRapport := false;
  with rapport do
  if windowRapportOpen and (theText <> NIL) then
    if SelectionRapportNonVide  then
      if theWindow = FrontWindowSaufPalette then
        begin
          TECopy(theText);
         {if (ZeroScrap = noErr) then
          if (TEToScrap = noErr) then DoNothing;}
         copierFromRapport := true;
       end;
end;




function EffacerDansRapport : boolean;
begin
  effacerDansRapport := false;
  with rapport do
  if windowRapportOpen and (theText <> NIL) then
    if SelectionRapportNonVide  then
      if theWindow = FrontWindowSaufPalette then
        begin
          TEDelete(theText);
          UpdateScrollersRapport;
          effacerDansRapport := true;
          if GetTailleRapport < maxTextEditSize      then prochaineAlerteRemplissage := maxTextEditSize;
          if GetTailleRapport < maxTextEditSize-1000 then prochaineAlerteRemplissage := maxTextEditSize-1000;
          if GetTailleRapport < maxTextEditSize-2000 then prochaineAlerteRemplissage := maxTextEditSize-2000;
          if GetTailleRapport <= 1 then EcritBienvenueDansRapport;
        end;
end;

function SelectionneToutDansRapport : boolean;
begin
  SelectionneToutDansRapport := false;
  with rapport do
    if windowRapportOpen and (theText <> NIL) then
      if theWindow = FrontWindowSaufPalette then
        begin
          TESetSelect(0,2000000000-1,theText);   {2000000000 was MawLongint}
          UpdateScrollersRapport;
          SelectionneToutDansRapport := true;
        end;
end;


function SelectionRapportEstUnePartieLegale(var partieAlpha : String255) : boolean;
var s : String255;
    longueur : SInt32;
    loc : SInt16;
begin
  SelectionRapportEstUnePartieLegale := false;
  partieAlpha := '';

  if SelectionRapportNonVide then
    begin
      longueur := LongueurSelectionRapport;

      if (longueur < 2) or (longueur > 250)
        then exit;

      s := SelectionRapportEnString(longueur);
      EnleveEspacesDeDroiteSurPlace(s);
      EnleveEspacesDeGaucheSurPlace(s);

      if (ScannerStringPourTrouverCoup(1,s,loc) > 0) and EstUnePartieOthello(s,true) then
        begin
          partieAlpha := s;
		      SelectionRapportEstUnePartieLegale := true;
		    end;
    end;
end;


END.
