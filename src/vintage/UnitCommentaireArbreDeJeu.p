UNIT UnitCommentaireArbreDeJeu;


INTERFACE


 USES UnitDefCassio , QuickDraw;


procedure DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition : boolean);
procedure DessineZoneDeTexteDansFenetreArbreDeJeu(forceModeEdition : boolean);
procedure CalculeEditionRectFenetreArbreDeJeu;
procedure ChangeDelimitationEditionRectFenetreArbreDeJeu(positionDelimitation : SInt16);
procedure ActiverModeEditionFenetreArbreDeJeu;
procedure DeactiverModeEditionFenetreArbreDeJeu;
procedure FaireClignoterFenetreArbreDeJeu;
procedure ClicDansTexteCommentaires(pt : Point; extend : boolean);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickdrawText, Dialogs
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitCarbonisation, UnitGeometrie, MyStrings, UnitFenetres, UnitDialog
    , UnitNormalisation, UnitJaponais, UnitAffichageArbreDeJeu ;
{$ELSEC}
    ;
    {$I prelink/CommentaireArbreDeJeu.lk}
{$ENDC}


{END_USE_CLAUSE}





procedure DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition : boolean);
const CommentaireTitreStaticText = 1;
var oldPort : grafPtr;
    unRect : rect;
    s : String255;
begin
  with arbreDeJeu do
  if windowOpen and (GetArbreDeJeuWindow <> NIL) then
    begin
      {WritelnDansRapport('DessineRubanDuCommentaireDansFenetreArbreDeJeu');}

      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow);

      TextSize(gCassioSmallFontSize);
      TextFace(normal);
      TextFont(gCassioApplicationFont);
      TextMode(srcOr);

      GetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
      Moveto(4,unRect.top+gCassioSmallFontSize+1);
      MyEraseRect(MakeRect(3,unrect.top,EditionRect.right,unRect.top+gCassioSmallFontSize+3));
      MyEraseRectWithColor(MakeRect(3,unrect.top,EditionRect.right,unRect.top+gCassioSmallFontSize+3),OrangeCmd,blackPattern,'');

      if (nbreCoup <= 0) or positionFeerique
        then
          begin
            s := ReadStringFromRessource(10020,8);  {'Commentaires'}
            MyDrawString(s);
          end
        else
          begin
            s := ReadStringFromRessource(10020,9);  {'Commentaires de ^0'}
            MyDrawString(s);
            TextFace(bold);
            MyDrawString(NumEnString(nbreCoup)+'.'+DernierCoupEnString(false));
          end;


      if forceModeEdition then enModeEdition := true;
      if not(forceModeEdition) and (GetArbreDeJeuWindow <> FrontWindowSaufPalette)
        then enModeEdition := false;

      if forceModeEdition or (enModeEdition and (GetArbreDeJeuWindow = FrontWindowSaufPalette)) or doitResterEnModeEdition
        then
          begin
            PenSize(2,2);
            PenPat(blackPattern);
            FrameRect(EditionRect);
            PenNormal;
          end
        else
          begin
            PenSize(2,2);
            PenPat(whitePattern);
            FrameRect(EditionRect);
            PenNormal;
          end;
      unRect := EditionRect;


      SetPort(oldPort);
    end;
end;




procedure DessineZoneDeTexteDansFenetreArbreDeJeu(forceModeEdition : boolean);
var oldPort : grafPtr;
begin
  with arbreDeJeu do
  if windowOpen and (GetArbreDeJeuWindow <> NIL) then
    begin
      {WritelnDansRapport('DessineZoneDeTexteDansFenetreArbreDeJeu');}
      GetPort(oldPort);
      SetPortByWindow(GetArbreDeJeuWindow);
      MyDrawDialog(arbreDeJeu.theDialog);
      DessineRubanDuCommentaireDansFenetreArbreDeJeu(forceModeEdition);
      DessineBoiteDeTaille(GetArbreDeJeuWindow);
      SetPort(oldPort);
    end;
end;


procedure CalculeEditionRectFenetreArbreDeJeu;
const CommentairesEditableText = 2;
var unRect : rect;
    oldPort : grafPtr;
    myText : TEHandle;
begin
  with arbreDeJeu do
    if windowOpen and (GetArbreDeJeuWindow <> NIL) then
      begin
        GetPort(oldPort);
        SetPortByWindow(GetArbreDeJeuWindow);
        GetDialogItemRect(arbreDeJeu.theDialog,CommentairesEditableText,unRect);
        unRect.bottom := QDGetPortBound.bottom-7;
        unRect.right := QDGetPortBound.right-7;
        SetDialogItemRect(arbreDeJeu.theDialog,CommentairesEditableText,unRect);


        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then
          begin
            TESetViewRect(myText,unRect);
            TESetDestRect(myText,unRect);
            myText^^.txSize := 9;
            myText^^.lineHeight := 11;
            myText^^.fontAscent := 9;
            myText^^.txFont := gCassioApplicationFont;
            TECalText(myText);
          end;

        EditionRect := unRect;
        InsetRect(EditionRect,-6,-6);
        SetPort(oldPort);
      end;
end;

procedure ChangeDelimitationEditionRectFenetreArbreDeJeu(positionDelimitation : SInt16);
const CommentaireTitreStaticText = 1;
      CommentairesEditableText = 2;
var unRect : rect;
    oldPort : grafPtr;
begin
  with arbreDeJeu do
    if windowOpen and (theDialog <> NIL) then
      begin
        GetPort(oldPort);
        SetPortByDialog(arbreDeJeu.theDialog);

        if positionDelimitation > QDGetPortBound.bottom-29 then positionDelimitation := QDGetPortBound.bottom-29;
        if positionDelimitation < 42 then positionDelimitation := 42;

        arbreDeJeu.positionLigneSeparation := positionDelimitation;

        GetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
        OffsetRect(unRect,0,positionDelimitation-6 - unRect.top);
        SetDialogItemRect(theDialog,CommentaireTitreStaticText,unRect);
        GetDialogItemRect(theDialog,CommentairesEditableText,unRect);
        unRect.top := positionDelimitation+12;
        SetDialogItemRect(theDialog,CommentairesEditableText,unRect);
        CalculeEditionRectFenetreArbreDeJeu;
        SetPort(oldPort);
      end;
end;

procedure ActiverModeEditionFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
    begin
      myText := GetDialogTextEditHandle(theDialog);
      if myText <> NIL then
        begin
          enModeEdition := true;
          doitResterEnModeEdition := EnTraitementDeTexte;
          SwitchToScript(gLastScriptUsedInDialogs);
          TEActivate(myText);
          DessineZoneDeTexteDansFenetreArbreDeJeu(enModeEdition);
        end;
    end;
end;

procedure DeactiverModeEditionFenetreArbreDeJeu;
begin
  ValideZoneCommentaireDansFenetreArbreDeJeu;
end;

procedure FaireClignoterFenetreArbreDeJeu;
var myText : TEHandle;
begin
  with arbreDeJeu do
    if {enModeEdition and }windowOpen and (GetArbreDeJeuWindow <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then TEIdle(myText)
      end;
end;

procedure ClicDansTexteCommentaires(pt : Point; extend : boolean);
var myText : TEHandle;
begin
  with arbreDeJeu do
    if windowOpen and (GetArbreDeJeuWindow <> NIL) then
      begin
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then TEClick(pt,extend,myText);
      end;
end;



END.
