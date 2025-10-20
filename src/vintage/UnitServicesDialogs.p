UNIT UnitServicesDialogs;


INTERFACE







 USES UnitDefCassio;



{ fonctions de base }
procedure AlerteSimple(texte : String255);
procedure AlerteDouble(texte,explication : String255);
function AlerteDoubleOuiNon(texte,explication : String255) : SInt16;


{ fonctions pour reconditionner des dialogues faits avec Resedit }
procedure AlertOneButtonFromRessource(dialogID, texteItemID, explicationItemID, buttonID : SInt16);
function AlertTwoButtonsFromRessource(dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;
procedure CautionAlertOneButtonFromRessource(dialogID, texteItemID, explicationItemID, buttonID : SInt16);
function CautionAlertTwoButtonsFromRessource(dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;
procedure TypedAlertOneButtonFromRessource(alertType : AlertType; dialogID, texteItemID, explicationItemID, buttonID : SInt16);
function TypedAlertTwoButtonsFromRessource(alertType : AlertType; dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;


{ fonctions utilitaires }
procedure DialogueSimple(dialogueID : SInt16{; s1,s2,s3,s4 : String255});
function MySimpleLegacyAlert(alertID : SInt16; s : String255) : SInt16;
function MyLegacyAlert(alertID : SInt16; filterProc : ModalFilterUPP; acceptationSet : SetOfItemNumber) : SInt16;
procedure MyParamText( const (*var*) param0: String255; const (*var*) param1: String255; const (*var*) param2: String255; const (*var*) param3: String255 );
function IsADuplicateRecentDialog(texte : String255) : boolean;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Dialogs, CFBase, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitDialog, MyFileSystemUtils, MyStrings, UnitEnvirons
    , UnitFenetres, UnitPalette ;
{$ELSEC}
    ;
    {$I prelink/ServicesDialogs.lk}
{$ENDC}


{END_USE_CLAUSE}






const UnitServicesDialogsInitialised : boolean = false;

var dernierMessageAlerteSimple : String255;
    compteurAlertesSimplesIdentiques : SInt32;
    dateDerniereAlerteSimple : SInt32;


procedure MyParamText( const (*var*) param0: String255; const (*var*) param1: String255; const (*var*) param2: String255; const (*var*) param3: String255 );
begin
  ParamText(StringToStr255(param0),StringToStr255(param1),StringToStr255(param2),StringToStr255(param3));
end;




procedure InitUnitServicesDialogs;
begin
  dernierMessageAlerteSimple := '';
  compteurAlertesSimplesIdentiques := 0;
  dateDerniereAlerteSimple := 0;

  UnitServicesDialogsInitialised := true;
end;


function IsADuplicateRecentDialog(texte : String255) : boolean;
begin

  if not(UnitServicesDialogsInitialised) then
    InitUnitServicesDialogs;


  // mettre a jour le compteur des alertes simples successives identiques
  if (dernierMessageAlerteSimple <> texte) | (compteurAlertesSimplesIdentiques >= 1000000)
    then compteurAlertesSimplesIdentiques := 0
    else inc(compteurAlertesSimplesIdentiques);


  // on ne fait rien si il s'agit au moins de la troisieme alerte
  // identique en moins de trois secondes
  if (compteurAlertesSimplesIdentiques >= 2) &
     (Abs(TickCount - dateDerniereAlerteSimple) <= 180) then
    begin
      IsADuplicateRecentDialog := true;
      exit(IsADuplicateRecentDialog);
    end;


  // mettre a jour le texte et la date
  dernierMessageAlerteSimple := texte;
  dateDerniereAlerteSimple := TickCount;

  IsADuplicateRecentDialog := false;
end;


procedure AlerteSimple(texte : String255);
var item : SInt16;
    tempoDoitAjusterCurseur : boolean;
    oldTexte : String255;
    explication : String255;
    err : OSErr;
begin


  // si on vient d'afficher deux fois de suite le meme dialogue, basta
  if IsADuplicateRecentDialog(texte) then
    exit(AlerteSimple);


  oldTexte  := texte;

  // parser le texte grossirement
  texte := ReplaceStringByStringInString('PrŽvenez StŽphane, SVP !','',texte);
  texte := ReplaceStringByStringInString('Prevenez StŽphane','',texte);
  texte := ReplaceStringByStringInString('PrŽvenez StŽphane','',texte);
  texte := ReplaceStringByStringInString('PrŽvŽnez StŽphane','',texte);
  texte := ReplaceStringByStringInString('Sauvegardez le rapport et prŽvenez StŽphane','',texte);
  texte := ReplaceStringByStringInString(',prŽvenez StŽphane','',texte);
  texte := ReplaceStringByStringInString(', prŽvenez StŽphane','',texte);
  texte := ReplaceStringByStringInString('(prŽvenez StŽphane)','',texte);
  texte := ReplaceStringByStringInString('Merci de prŽvenir StŽphane','',texte);

  texte := ReplaceStringByStringInString('PrŽvenez Stephane, SVP !','',texte);
  texte := ReplaceStringByStringInString('Prevenez Stephane','',texte);
  texte := ReplaceStringByStringInString('PrŽvenez Stephane','',texte);
  texte := ReplaceStringByStringInString('PrŽvŽnez Stephane','',texte);
  texte := ReplaceStringByStringInString('Sauvegardez le rapport et prŽvenez Stephane','',texte);
  texte := ReplaceStringByStringInString(',prŽvenez Stephane','',texte);
  texte := ReplaceStringByStringInString(', prŽvenez Stephane','',texte);
  texte := ReplaceStringByStringInString('(prŽvenez Stephane)','',texte);
  texte := ReplaceStringByStringInString('Merci de prŽvenir Stephane','',texte);

  texte := ReplaceStringByStringInString('Prevenez StŽphane, SVP !','',texte);
  texte := ReplaceStringByStringInString('Prevenez StŽphane','',texte);
  texte := ReplaceStringByStringInString('PrevŽnez StŽphane','',texte);
  texte := ReplaceStringByStringInString('Sauvegardez le rapport et prevenez StŽphane','',texte);
  texte := ReplaceStringByStringInString(',prevenez StŽphane','',texte);
  texte := ReplaceStringByStringInString(', prevenez StŽphane','',texte);
  texte := ReplaceStringByStringInString('(prevenez StŽphane)','',texte);
  texte := ReplaceStringByStringInString('Merci de prŽvenir StŽphane','',texte);

  texte := ReplaceStringByStringInString('Prevenez Stephane, SVP !','',texte);
  texte := ReplaceStringByStringInString('Prevenez Stephane','',texte);
  texte := ReplaceStringByStringInString('PrŽvŽnez Stephane','',texte);
  texte := ReplaceStringByStringInString('Sauvegardez le rapport et prevenez Stephane','',texte);
  texte := ReplaceStringByStringInString(',prevenez Stephane','',texte);
  texte := ReplaceStringByStringInString(', prevenez Stephane','',texte);
  texte := ReplaceStringByStringInString('(prevenez Stephane)','',texte);
  texte := ReplaceStringByStringInString('Merci de prŽvenir Stephane','',texte);


  if (oldTexte = texte)
    then explication := ''
    else
      if not(EstLaVersionFrancaiseDeCassio)
        then explication := 'Please take a screenshot, save the rapport and email StŽphane.'
        else explication := 'Merci de faire une copie d''Žcran, sauvegarder le rapport et prŽvenir StŽphane.';




  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }

  AlerteDouble(texte,explication);

  {$ELSEC}

  // c'est parti pour l'alerte !!
  BeginDialog;
  tempoDoitAjusterCurseur := doitAjusterCurseur;
  doitAjusterCurseur := false;

  // MyParamText(texte + ' ' +explication ,'','','');
  // item := MyLegacyAlert(AlerteOKID,FiltreClassiqueAlerteUPP,[OK]);

  err := StandardAlert(kAlertStopAlert,texte,explication,NIL,item);

  doitAjusterCurseur := tempoDoitAjusterCurseur;
  EndDialog;

  {$ENDC}



end;



procedure AlerteDouble(texte,explication : String255);
var err : OSStatus;
    item : DialogItemIndex;
    errorRef : CFStringRef;
    explanationRef : CFStringRef;
    tempoDoitAjusterCurseur : boolean;
    params : AlertStdAlertParamRec;
    OKString : String255;
    OK255 : str255;
    theAlert : DialogRef;
begin


  // si on vient d'afficher deux fois de suite le meme dialogue, basta
  if IsADuplicateRecentDialog(texte+explication) then
    exit(AlerteDouble);


  BeginDialog;
  tempoDoitAjusterCurseur := doitAjusterCurseur;
  doitAjusterCurseur := false;

  errorRef       := MakeCFSTR(texte);
  explanationRef := MakeCFSTR(explication);

  {$IFC  CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL}
  err := CreateStandardAlert(kAlertNoteAlert,errorRef,explanationRef, NIL, theAlert);
  err := RunStandardAlert(theAlert,FiltreClassiqueAlerteUPP,item);
  {$ELSEC}
  Discard(theAlert);
  OKString := 'OK';
  OK255    := StringToStr255(OKString);
  with params do
    begin
      movable       := true;
      helpButton    := false;
      filterProc    := FiltreClassiqueAlerteUPP;
      defaultText   := @OK255;
      cancelText    := NIL;
      otherText     := NIL;
      defaultButton := 1;
      cancelButton  := 0;
      position      := $700A;  // := kWindowAlertPositionParentWindowScreen;
    end;
  err := StandardAlert(kAlertNoteAlert,StringToStr255(texte),StringToStr255(explication),@params,item);
  {$ENDC}

  CFRelease(CFTypeRef(errorRef));
  CFRelease(CFTypeRef(explanationRef));

  doitAjusterCurseur := tempoDoitAjusterCurseur;
  EndDialog;

end;


function AlerteDoubleOuiNon(texte,explication : String255) : SInt16;
var err : OSErr;
    params : AlertStdAlertParamRec;
    defaut,cancel : String255;
    defaut255,cancel255 : str255;
    item : SInt16;
    dp : DialogRef;
const AlerteOuiNonID = 1129;
begin

  BeginDialog;

  defaut := 'Oui';
  cancel := 'Non';

  // charger le dialogue fictif 1129 des ressources, sans
  // l'afficher, pour pouvoir recuperer le nom des boutons
  // oui et non

  dp := GetNewDialog(AlerteOuiNonID,NIL,MAKE_MEMORY_POINTER(-1));

  if (dp <> NIL) then
    begin
      GetControlTitleInDialog(dp,1,defaut);
      GetControlTitleInDialog(dp,2,cancel);
      DisposeDialog(dp);
    end;

  defaut255 := StringToStr255(defaut);
  cancel255 := StringToStr255(cancel);

  with params do
    begin
      movable       := true;
      helpButton    := false;
      filterProc    := FiltreClassiqueAlerteUPP;
      defaultText   := @defaut255;
      cancelText    := @cancel255;
      otherText     := NIL;
      defaultButton := 1;
      cancelButton  := 2;
      position      := $700A;  // := kWindowAlertPositionParentWindowScreen;
    end;

  err := StandardAlert(kAlertNoteAlert,StringToStr255(texte),StringToStr255(explication),@params,item);

  EndDialog;

  AlerteDoubleOuiNon := item;
end;




procedure TypedAlertOneButtonFromRessource(alertType : AlertType; dialogID, texteItemID, explicationItemID, buttonID : SInt16);
var s : String255;
    foo : SInt16;
begin

  // verifions que ce n'est pas une alerte repetee
  s := NumEnString(alertType) + NumEnString(dialogID) + NumEnString(texteItemID) + NumEnString(explicationItemID) + NumEnString(buttonID);

  if IsADuplicateRecentDialog(s) then
    exit(TypedAlertOneButtonFromRessource);

  // non : on affiche l'alerte
  foo := TypedAlertTwoButtonsFromRessource(alertType, dialogID, texteItemID, explicationItemID, buttonID, 0);
end;


function TypedAlertTwoButtonsFromRessource(alertType : AlertType; dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;
var texte,explication : String255;
    err : OSErr;
    params : AlertStdAlertParamRec;
    defaut,cancel : String255;
    defaut255,cancel255 : str255;
    item : SInt16;
    dp : DialogRef;
begin

  BeginDialog;

  defaut      := 'OK';
  cancel      := '';

  texte       := '';
  explication := '';

  // charger le dialogue fictif 'dialogID' des ressources, sans
  // l'afficher, pour pouvoir recuperer le nom des boutons
  // et les textes

  dp := GetNewDialog(dialogID,NIL,MAKE_MEMORY_POINTER(-1));

  if (dp <> NIL) then
    begin

      // recuperer les intitulŽs des boutons
      if (buttonOneID > 0) then
        GetControlTitleInDialog(dp,buttonOneID,defaut);

      if (buttonTwoID > 0) then
        GetControlTitleInDialog(dp,buttonTwoID,cancel);

      // recuperer les textes du dialogue
      if (texteItemID > 0) then
        GetItemTextInDialog(dp,texteItemID,texte);

      if (explicationItemID > 0) then
        GetItemTextInDialog(dp,explicationItemID,explication);

      DisposeDialog(dp);
    end;

  defaut255 := StringToStr255(defaut);
  cancel255 := StringToStr255(cancel);

  with params do
    begin
      movable       := true;
      helpButton    := false;
      filterProc    := FiltreClassiqueAlerteUPP;

      defaultText   := @defaut255;

      if (cancel <> '')
        then cancelText    := @cancel255
        else cancelText    := NIL;

      otherText     := NIL;

      defaultButton := buttonOneID;
      cancelButton  := buttonTwoID;

      position      := $700A;  // := kWindowAlertPositionParentWindowScreen;
    end;

  err := StandardAlert(alertType,StringToStr255(texte),StringToStr255(explication),@params,item);

  EndDialog;

  if (item = kAlertStdAlertOKButton)
    then TypedAlertTwoButtonsFromRessource := buttonOneID
    else TypedAlertTwoButtonsFromRessource := buttonTwoID;

end;

procedure AlertOneButtonFromRessource(dialogID, texteItemID, explicationItemID, buttonID : SInt16);
begin
  TypedAlertOneButtonFromRessource(kAlertNoteAlert, dialogID, texteItemID, explicationItemID, buttonID);
end;


function AlertTwoButtonsFromRessource(dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;
begin
  AlertTwoButtonsFromRessource := TypedAlertTwoButtonsFromRessource(kAlertNoteAlert, dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID);
end;


procedure CautionAlertOneButtonFromRessource(dialogID, texteItemID, explicationItemID, buttonID : SInt16);
begin
  TypedAlertOneButtonFromRessource(kAlertCautionAlert, dialogID, texteItemID, explicationItemID, buttonID);
end;


function CautionAlertTwoButtonsFromRessource(dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID : SInt16) : SInt16;
begin
  CautionAlertTwoButtonsFromRessource := TypedAlertTwoButtonsFromRessource(kAlertCautionAlert, dialogID, texteItemID, explicationItemID, buttonOneID, buttonTwoID);
end;



function MySimpleLegacyAlert(alertID : SInt16; s : String255) : SInt16;
begin

  // si on vient d'afficher deux fois de suite le meme dialogue, basta
  if IsADuplicateRecentDialog(s + NumEnString(alertID)) then
    exit(MySimpleLegacyAlert);


  BeginDialog;
  MyParamText(s,'','','');
  MySimpleLegacyAlert := Alert(alertID,FiltreClassiqueAlerteUPP);
  EndDialog;
end;


function MyLegacyAlert(alertID : SInt16; filterProc : ModalFilterUPP; acceptationSet : SetOfItemNumber) : SInt16;
var item : SInt16;
begin
  repeat
    item := Alert(alertID,filterProc);
  until (item = -1) | (item in acceptationSet);
  MyLegacyAlert := item;
end;


procedure DialogueSimple(dialogueID : SInt16{; s1,s2,s3,s4 : String255});
const OK = 1;
var dp : DialogPtr;
    itemHit : SInt16;
    err : OSErr;
begin
  BeginDialog;
  dp := MyGetNewDialog(DialogueID);
  if dp <> NIL then
    begin
      {MyParamText(s1,s2,s3,s4);}
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit = OK);
      MyDisposeDialog(dp);
      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
    end;
  EndDialog;
end;



END.
