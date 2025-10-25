UNIT UnitJaponais;


INTERFACE







 USES GestaltEqu , TextServices , TSMTE , UnitDefCassio;






{initialisation et destruction de l'unité}
procedure InitUnitJaponais;
procedure LibereMemoireUnitJaponais;


{test pour le Text Service Manager}
procedure CheckForTextService;


{les pre et post-callback procedures}
procedure MyTSMTEPreUpdateProc(textH : TEHandle; refCon : SInt32);
procedure MyTSMTEPostUpdateProc(textH : TEHandle; fixLen,inputAreaStart,inputAreaEnd,pinStart,pinEnd,refCon : SInt32);




{fonctions gerant les changements de script}
procedure SwitchToScript(whichScript : SInt32);
procedure SwitchToJapaneseScript;
procedure SwitchToRomanScript;
procedure DisableKeyboardScriptSwitch;
procedure EnableKeyboardScriptSwitch;
procedure GetCurrentScript(var currentScript : SInt32);
procedure SetCurrentScript(whichScript : SInt32);


{pour lier un document TSMTE à un TEHandle}
function AddTSMTESupport(whichWindow : WindowPtr; whichText : TEHandle; var theTSMDoc : TSMDocumentID; var theTSMHandle : TSMTERecHandle) : OSErr;
procedure RemoveTSMTESupport(var theTSMDoc : TSMDocumentID);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Script
{$IFC NOT(USE_PRELINK)}
    , UnitDialog, MyStrings, UnitModes ;
{$ELSEC}
    ;
    {$I prelink/Japonais.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure InitUnitJaponais;
const TextesDiversID = 10020;
var pourVersionJaponaise,doIt : boolean;
    err : OSErr;
begin

  {la chaine suivante peut etre "version normale" ou "version japonaise",
   selon ce qu'il y a dans le fichier de ressources}
  pourVersionJaponaise := (ReadStringFromRessource(TextesDiversID,7) = 'version japonaise');

  CheckForTextService;

  if pourVersionJaponaise
    then gVersionJaponaiseDeCassio := gHasTextServices
    else gVersionJaponaiseDeCassio := false;

  if gHasTextServices
    then gHasJapaneseScript := (GetScriptVariable(smJapanese,smEnabled) <> 0)
    else gHasJapaneseScript := false;

  gDisplayJapaneseNamesInJapanese := gHasJapaneseScript;



  if gHasTSMTE
    then
      begin


        doIt := true;

        if doIt
          then
            begin
              gHasTSMTE := true;
			        gTSMTEPreUpdateUPP := NewTSMTEPreUpdateUPP(MyTSMTEPreUpdateProc);
			        gTSMTEPostUpdateUPP := NewTSMTEPostUpdateUPP(MyTSMTEPostUpdateProc);
			      end
			    else
			      begin
			        gHasTSMTE := false;
              gTSMTEPreUpdateUPP := NIL;
              gTSMTEPostUpdateUPP := NIL;
			      end;
      end
    else
      begin
        gHasTSMTE := false;
        gTSMTEPreUpdateUPP := NIL;
        gTSMTEPostUpdateUPP := NIL;
      end;
  gSavedFontForce := GetScriptManagerVariable(smFontForce);
	err := SetScriptManagerVariable(smFontForce,1);
	GetCurrentScript(gLastScriptUsedInDialogs);
	GetCurrentScript(gLastScriptUsedOutsideCassio);
end;


procedure CheckForTextService;
var gestaltResponse : SInt32;
begin
  gHasTextServices := false;
  gHasTSMTE := false;
  if GestaltImplemented then
    begin
      if (Gestalt(gestaltTSMgrVersion, gestaltResponse) = noErr) and (gestaltResponse  >= 1) then
        begin
          gHasTextServices := true;
          if Gestalt(gestaltTSMTEAttr, gestaltResponse) = noErr then
            gHasTSMTE := BTST(gestaltResponse, gestaltTSMTEPresent);
        end;
    end;
end;



{ this TSMTEPreUpdateProc only works around a bug in TSMTE 1.0, which has }
{ been fixed in 1.1. For other possible uses, see technote TE 27. }
procedure MyTSMTEPreUpdateProc(textH : TEHandle; refCon : SInt32);
var response : SInt32;
	  keyboardScript : ScriptCode;
	  mode : SInt16;
	  theStyle : TextStyle;
begin
  {$UNUSED refCon}
	if ((Gestalt(gestaltTSMTEVersion, response) = noErr) and (response = gestaltTSMTE1)) then
	begin
		keyboardScript := GetScriptManagerVariable(smKeyScript);
		mode := doFont;
		if not(TEContinuousStyle(mode, theStyle, textH) and
		      (FontToScript(theStyle.tsFont) = keyboardScript)) then
		begin
			theStyle.tsFont := GetScriptVariable(keyboardScript, smScriptAppFond);
			TESetStyle(doFont, theStyle, false, textH);
		end;
	end;
end;



{ this TSMTEPostUpdateProc makes sure that our scrollbars and scroll information }
{ are consistent with what TSMTE is doing. For other possible uses, see technote TE 27. }
procedure MyTSMTEPostUpdateProc(textH : TEHandle; fixLen,inputAreaStart,inputAreaEnd,pinStart,pinEnd,refCon : SInt32);
begin
	{$UNUSED textH, fixLen, inputAreaStart, inputAreaEnd, pinStart, pinEnd, refCon}

	{AdjustScrollbars(WindowPtr(refCon), false);
	AdjustTE(WindowPtr(refCon));}
end;



procedure SwitchToJapaneseScript;
begin
  if gVersionJaponaiseDeCassio and gHasTextServices and gHasJapaneseScript and not(CassioIsInBackground)
    then KeyScript(smJapanese);
end;


procedure SwitchToRomanScript;
var currentScript : SInt32;
begin
  if gHasTextServices and not(CassioIsInBackground) and not(UnDialogueEstAffiche) then
    begin
      currentScript := GetScriptManagerVariable(smKeyScript);
      if (currentScript <> smRoman) and not(AuMoinsUneZoneDeTexteEnModeEntree)
        then KeyScript(smKeyRoman);
    end;
end;

procedure SwitchToScript(whichScript : SInt32);
var currentScript : SInt32;
begin
  if gHasTextServices and not(CassioIsInBackGround) then
    begin
      EnableKeyboardScriptSwitch;
      currentScript := GetScriptManagerVariable(smKeyScript);
      if (currentScript <> whichScript)
        then KeyScript(whichScript);
    end;
end;


procedure EnableKeyboardScriptSwitch;
begin
  if gHasTextServices and not(CassioIsInBackGround) then
    begin
      KeyScript(smKeyEnableKybds);
    end;
end;


procedure DisableKeyboardScriptSwitch;
begin
  if gHasTextServices and not(CassioIsInBackGround) and not(AuMoinsUneZoneDeTexteEnModeEntree) then
    begin
      KeyScript(smKeyDisableKybdSwitch);
    end;
end;


procedure GetCurrentScript(var currentScript : SInt32);
begin
  if gHasTextServices
    then currentScript := GetScriptManagerVariable(smKeyScript)
    else currentScript := 0;
end;

procedure SetCurrentScript(whichScript : SInt32);
var currentScript : SInt32;
begin
  currentScript := GetScriptManagerVariable(smKeyScript);
  if (currentScript <> whichScript) then KeyScript(whichScript);
end;


function AddTSMTESupport(whichWindow : WindowPtr; whichText : TEHandle; var theTSMDoc : TSMDocumentID; var theTSMHandle : TSMTERecHandle) : OSErr;
var supportedInterfaces : OSType;
    myTSMTERecPtr : TSMTERecPtr;
    err : OSErr;
begin
  err := -1;
  if gHasTSMTE then
    begin
      supportedInterfaces := kTSMTEInterfaceType;
      err := NewTSMDocument(1,@supportedInterfaces,theTSMDoc,SInt32(@theTSMHandle));
	    if err <> NoErr
	      then
	        begin
	          theTSMDoc := NIL;
	          theTSMHandle := NIL;
	        end
	      else
		      begin
			      myTSMTERecPtr := theTSMHandle^;

			      with myTSMTERecPtr^ do
			        begin
			          textH := whichText;
			          preUpdateProc := gTSMTEPreUpdateUPP;
			          postUpdateProc := gTSMTEPostUpdateUPP;
			          updateFlag := kTSMTEAutoScroll;
			          refCon := SInt32(whichWindow);
			        end;
		      end;
	end;
	AddTSMTESupport := err;
end;

procedure RemoveTSMTESupport(var theTSMDoc : TSMDocumentID);
var err : OSErr;
begin
  if theTSMDoc <> NIL then
    begin
      err := FixTSMDocument(theTSMDoc);
			{DeleteTSMDocument might cause crash if we don't deactivate first, so...}
			err := DeactivateTSMDocument(theTSMDoc);
			err := DeleteTSMDocument(theTSMDoc);
			theTSMDoc := NIL;
		end;
end;

procedure LibereMemoireUnitJaponais;
var err : OSErr;
begin

  { set global fontForce flag so other apps don't get confused }
  err := SetScriptManagerVariable(smFontForce, gSavedFontForce);
end;



END.
