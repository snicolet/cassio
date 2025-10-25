UNIT UnitOth2;




INTERFACE







 USES UnitDefCassio;




procedure InitUnitOth2;
procedure LibereMemoireUnitOth2;


procedure BeginRetournementSpecial(positionAAtteindre : PositionEtTraitRec);
procedure EndRetournementSpecial;
function RetournementSpecialEnCours : boolean;
function ValeurFutureDeCetteCaseDansRetournementSpecial(whichSquare : SInt32) : SInt32;





procedure AffichePourDebugage(chaine : String255);
procedure StoppeEtAffichePourDebugage(chaine : String255);
procedure StoppeEtAfficheAireDeJeuPourDebugage(chaine : String255);


function PeutReculerUnCoup : boolean;
function PeutReculerDeuxCoups : boolean;
function PeutAvancerUnCoup : boolean;
function PeutAvancerDeuxCoups : boolean;
function PeutAvancerPartieSelectionnee : boolean;
function PeutReculerUnCoupPuisJouerSurCetteCase(whichSquare : SInt32; var positionResultante : PositionEtTraitRec) : boolean;
procedure Bip(duree : SInt16);

procedure DialogueVousPassez;
procedure AlerteMicMacIndex(nbrePartiesIndex,nbrePartiesBase : SInt32);
function ConfirmationQuitter : boolean;
procedure EcritPositionAt(var plat : plateauOthello; hpos,vpos : SInt16);
procedure EcritPlatBoolAt(var plat : plBool; hpos,vpos : SInt16);
procedure StoppeEtAfficheMessageAt(message : String255; x,y : SInt16);
procedure DessineRetour(ClipRegion : RgnHandle; fonctionAppelante : String255);

procedure EcritEspaceDansPile;
procedure DialogueMemoireBase;
procedure DialoguePartieFeeriqueAvantChargementBase;
procedure AlerteErreurCollagePartie;
procedure AlerteFormatNonReconnuFichierPartie(nomFichier : String255);
procedure AlerteDoitInterompreReflexionPourFaireScript;

function MyFiltreClassiqueRapide(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
procedure AjoutePion(x,coul : SInt16; var platJeu : plateauOthello; var jouable : plBool);
procedure PosePion(x,couleur : SInt16);


procedure SetAfficheInfosApprentissage(flag : boolean);
function GetAfficheInfosApprentissage : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, Fonts, MacMemory, Appearance, QuickdrawText
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitRapport, UnitAffichageReflexion
    , UnitModes, UnitSolitaire, UnitTournoi, UnitBufferedPICT, UnitNormalisation, UnitTroisiemeDimension, UnitGeometrie, UnitPressePapier
    , UnitRapportImplementation, UnitCarbonisation, UnitFenetres, UnitServicesDialogs, UnitEntreeTranscript, UnitStatistiques, MyStrings, SNEvents
    , UnitDialog, UnitGestionDuTemps, UnitListe, UnitVieilOthelliste, UnitCourbe, UnitJeu, MyFonts, MyMathUtils
    , UnitCouleur, UnitPalette, UnitPositionEtTrait, UnitAffichagePlateau ;
{$ELSEC}
    ;
    {$I prelink/Oth2.lk}
{$ENDC}


{END_USE_CLAUSE}








var gRetournementSpecial : record
                             enCours        : boolean;
                             positionFuture : PositionEtTraitRec;
                           end;





procedure BeginRetournementSpecial(positionAAtteindre : PositionEtTraitRec);
begin
  gRetournementSpecial.enCours        := true;
  gRetournementSpecial.positionFuture := positionAAtteindre;
end;


function ValeurFutureDeCetteCaseDansRetournementSpecial(whichSquare : SInt32) : SInt32;
begin
  with gRetournementSpecial do
    if enCours and (whichSquare >= 11) and (whichSquare <= 88)
      then ValeurFutureDeCetteCaseDansRetournementSpecial := positionFuture.position[whichSquare]
      else ValeurFutureDeCetteCaseDansRetournementSpecial := 0;
end;

procedure EndRetournementSpecial;
begin
  gRetournementSpecial.enCours := false;
end;

function RetournementSpecialEnCours : boolean;
begin
  RetournementSpecialEnCours := gRetournementSpecial.enCours;
end;


procedure InitUnitOth2;
begin
  gRetournementSpecial.enCours        := false;
end;


procedure LibereMemoireUnitOth2;
begin
end;





procedure AffichePourDebugage(chaine : String255);
var yposition : SInt16;
    oldport : grafPtr;
    effaceRect : rect;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL)  then
    begin
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
    end;
  nbreDebugage := nbreDebugage+1;
  yposition := 10+(nbreDebugage mod 30)*10;
  SetRect(effaceRect,5,yposition,500,yposition+12);
  MyEraseRect(effacerect);
  MyEraseRectWithColor(effaceRect,OrangeCmd,blackPattern,'');
  Moveto(10,yposition);
  TextMode(srcXor);
  TextFont(0);
  MyDrawString(Concat(chaine,'   '));
  if windowPlateauOpen and (wPlateauPtr <> NIL) then SetPort(oldport);

  {Writeln(chaine);}
end;

procedure StoppeEtAffichePourDebugage(chaine : String255);
begin
  AffichePourDebugage(chaine);
  SysBeep(0);
  if windowCourbeOpen or (windowPlateauOpen and (wPlateauPtr <> NIL))
    then AttendFrappeClavier;
end;

procedure StoppeEtAfficheAireDeJeuPourDebugage(chaine : String255);
var s : String255;
begin
  s := chaine + ' : aireDeJeu.left = '+NumEnString(aireDeJeu.left);
  AffichePourDebugage(s);
  TraceLog(s);
  SysBeep(0);
  {AttendFrappeClavier;}
end;



function PeutReculerUnCoup : boolean;
var result : boolean;
begin
  result := false;
  if (nbreCoup > 0) and not(CassioEstEnModeTournoi) then
    if (DerniereCaseJouee <> coupInconnu) then result := true;
  PeutReculerUnCoup := result;
end;

function PeutReculerDeuxCoups : boolean;
var result : boolean;
begin
  result := false;
  if (nbreCoup > 1) and not(CassioEstEnModeTournoi) then
    if (DerniereCaseJouee <> coupInconnu) then result := true;
  PeutReculerDeuxCoups := result;
end;


function PeutReculerUnCoupPuisJouerSurCetteCase(whichSquare : SInt32; var positionResultante : PositionEtTraitRec) : boolean;
var result : boolean;
    i : SInt32;
    plateauResultant : plateauOthello;
begin
  result := false;

  if (nbreCoup > 0) and not(CassioEstEnModeTournoi) then
    with partie^^[nbreCoup] do
      if (DerniereCaseJouee <> coupInconnu) then
        begin

          plateauResultant := JeuCourant;

          plateauResultant[DerniereCaseJouee] := pionVide;
          for i := 1 to nbRetourne do
            plateauResultant[retournes[i]] := -plateauResultant[retournes[i]];

          positionResultante := MakePositionEtTrait(plateauResultant,GetCouleurDernierCoup);
          result := UpdatePositionEtTrait(positionResultante,whichSquare);
        end;

  PeutReculerUnCoupPuisJouerSurCetteCase := result;
end;


function PeutAvancerUnCoup : boolean;
begin
  PeutAvancerUnCoup := (nbreCoup < nroDernierCoupAtteint) and not(CassioEstEnModeTournoi);
end;


function PeutAvancerDeuxCoups : boolean;
begin
  PeutAvancerDeuxCoups := ((nbreCoup+1) < nroDernierCoupAtteint) and not(CassioEstEnModeTournoi);
end;


function PeutAvancerPartieSelectionnee : boolean;
var test : boolean;
begin
  test := not(gameOver) and (nbPartiesActives > 0) and windowListeOpen and not(CassioEstEnModeTournoi);
  PeutAvancerPartieSelectionnee := test;
end;


procedure Bip(duree : SInt16);
begin
   if avecSon then SysBeep(duree);
end;



procedure DialogueVousPassez;
const VousPassezID = 131;
      OK = 1;
begin

  if CassioEstEnModeSolitaire
    then AlertOneButtonFromRessource(VousPassezID,3,0,OK)
    else AlertOneButtonFromRessource(VousPassezID,3,4,OK);  // version du dialogue avec "Essayez de prendre moins de pions en début de partie"

  PassesDejaExpliques := PassesDejaExpliques+1;
end;


procedure AlerteMicMacIndex(nbrePartiesIndex,nbrePartiesBase : SInt32);
const MicMacIndexID = 1132;
      ok = 1;
var s1,s2 : String255;
begin
  BeginDialog;
  s1 := NumEnString(nbrePartiesIndex);
  s2 := NumEnString(nbrePartiesBase);
  MyParamText(s1,s2,'','');
  if MyLegacyAlert(MicMacIndexID,FiltreClassiqueAlerteUPP,[ok]) = ok then DoNothing;
  EndDialog;
end;

function ConfirmationQuitter : boolean;
const QuitterID = 128;
      AnnulerButton = 2;
      QuitterButton = 1;
var itemHit : SInt16;
begin
  ConfirmationQuitter := true;
  if doitConfirmerQuitter and not(enTournoi) then
    begin

      itemHit := AlertTwoButtonsFromRessource(QuitterID,3,0,QuitterButton,AnnulerButton);

      if (itemHit = AnnulerButton)
        then ConfirmationQuitter := false
        else ConfirmationQuitter := true;

    end;
end;




procedure EcritPositionAt(var plat : plateauOthello; hpos,vpos : SInt16);
var i,j,a,b : SInt16;
begin
 PrepareTexteStatePourMeilleureSuite;
 for j := 1 to 8 do
   for i := 1 to 8 do
     begin
       a := hPos+i*12;
       b := vPos+j*12;
       if plat[i+10*j] = pionNoir then WriteStringAt('X ',a,b) else
       if plat[i+10*j] = pionBlanc then WriteStringAt('O ',a,b) else
       if plat[i+10*j] = pionVide then WriteStringAt(' . ',a,b) else
       WriteStringAt(' ? ',a,b)
     end;
end;


procedure EcritPlatBoolAt(var plat : plBool; hpos,vpos : SInt16);
var i,j,a,b : SInt16;
begin
 PrepareTexteStatePourMeilleureSuite;
 for j := 1 to 8 do
   for i := 1 to 8 do
     begin
       a := hPos+i*12;
       b := vPos+j*12;
       if plat[i+10*j]
         then WriteStringAt('1 ',a,b)
         else WriteStringAt('0 ',a,b);
     end;
end;


procedure StoppeEtAfficheMessageAt(message : String255; x,y : SInt16);
begin
  WriteStringAt(message,x,y);
  SysBeep(0);
  AttendFrappeClavier;
end;

procedure DessineRetour(ClipRegion : RgnHandle; fonctionAppelante : String255);
var s : String255;
    oldport : grafPtr;
    promptEnDessous : boolean;
    posH,posV,larg : SInt16;
    theRect : rect;
begin
  {$UNUSED fonctionAppelante}
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      {WritelnDansRapport('appel de DessineRetour par '+fonctionAppelante);}

      DessineDiagramme(GetTailleCaseCourante,ClipRegion,'DessineRetour');


      EffaceZoneADroiteDeLOthellier;
      EffaceZoneAuDessousDeLOthellier;
      if avecSystemeCoordonnees then DessineSystemeCoordonnees;

      if (TrebuchetMSID <> 0) and gIsRunningUnderMacOSX
        then
          begin
            TextFont(TrebuchetMSID);
            TextFace(bold);
          end
        else
          begin
            TextFont(systemFont);
            TextFace(normal);
          end;
      TextSize(12);
      TextMode(srcBic);

      promptEnDessous := ((GetWindowPortRect(wPlateauPtr).right-aireDeJeu.right - EpaisseurBordureOthellier) < 100) or
                         (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) or CassioEstEn3D or EnModeEntreeTranscript;
      if promptEnDessous
        then
          begin
            if not(CassioEstEn3D)
              then theRect := MakeRect(aireDeJeu.left,aireDeJeu.bottom+1,aireDeJeu.right,aireDeJeu.bottom+12)
              else theRect := MakeRect(GetBoundingRect3D(81).left,PosVDemande-1,GetBoundingRect3D(88).right,PosVDemande);
            with theRect do
              begin
                s := ReadStringFromRessource(TextesSetUpID,4);
                Moveto(Max(left,(left+right-MyStringWidth(s)) div 2),bottom);
                MyDrawString(s);
                s := ReadStringFromRessource(TextesSetUpID,5);
                DessineBoutonParControlManager(kThemeStateActive,Max(left,(left+right-MyStringWidth(s)-30) div 2),bottom+4,bottom+24,30,s,annulerRetourRect);
                EffaceZoneADroiteDeLOthellier;
               end;
          end
        else
          begin
             PosH := 15;
             PosV := 16;
             s := ReadStringFromRessource(TextesSetUpID,1);
             larg := MyStringWidth(s);
             if aireDeJeu.right+EpaisseurBordureOthellier+larg > GetWindowPortRect(wPlateauPtr).right-10 then
               posH := GetWindowPortRect(wPlateauPtr).right-larg-(aireDeJeu.right+EpaisseurBordureOthellier)-10;
             if posH < 5 then posH := 5;
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier+PosH,PosV+12);
             MyDrawString(s);
             s := ReadStringFromRessource(TextesSetUpID,2);
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier+PosH,PosV+24);
             MyDrawString(s);
             s := ReadStringFromRessource(TextesSetUpID,3);
             Moveto(aireDeJeu.right+EpaisseurBordureOthellier+PosH,PosV+36);
             MyDrawString(s);
             s := ReadStringFromRessource(TextesSetUpID,5);
             DessineBoutonParControlManager(kThemeStateActive,aireDeJeu.right+EpaisseurBordureOthellier+PosH+15,PosV+45,PosV+65,30,s,annulerRetourRect);
             EffaceZoneAuDessousDeLOthellier;
          end;

      if EnModeEntreeTranscript then EcranStandardTranscript;
      DessineBoiteDeTaille(wPlateauPtr);
      SetPort(oldPort);
    end;
end;




procedure EcritEspaceDansPile;
var a : SInt32;
begin
  a := StackSpace;
  if a > 0
    then WriteNumAt('espace entre le bas de la pile et le haut du tas : ',a,30,30)
    else
      begin
        SysBeep(30);
        SysBeep(30);
        SysBeep(30);
        WriteNumAt('stackspace < ',0,30,30)
      end;
  AttendFrappeClavier;
end;

procedure DialogueMemoireBase;
const problemeMemoireID = 141;
      OK = 1;
var dp : DialogPtr;
    itemHit : SInt16;
    err : OSErr;
begin
  BeginDialog;
  dp := MyGetNewDialog(problemeMemoireID);
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit = OK);
      MyDisposeDialog(dp);
    end;
  EndDialog;
  problemeMemoireBase := true;
end;


procedure DialoguePartieFeeriqueAvantChargementBase;
const TextesErreursID       = 10016;
var texte,explication : String255;
    prompt,refsSolitaire : String255;
begin
  if (nbAlertesPositionFeerique < 1) then
    begin

      texte       := ReadStringFromRessource(TextesErreursID,17);  {'La partie ne commence pas à la position initiale standard.'}

      explication := '';

      // Si on est en mode solitaire et que les references sont indiquees,
      // on les affiche dans le dialogue
      if CassioEstEnModeSolitaire then
        begin
          ParserCommentaireSolitaire(CommentaireSolitaire^^,prompt,refsSolitaire);
          explication := refsSolitaire;
        end;

      // sinon on met une explication bateau
      if (explication = '')
        then explication := ReadStringFromRessource(TextesErreursID,18);  {'Vous ne pourrez donc pas l'utiliser pour charger une partie dans la base WThor '}

      AlerteDouble(texte,explication);

      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
      nbAlertesPositionFeerique := nbAlertesPositionFeerique+1;

    end;
end;

procedure AlerteErreurCollagePartie;
var s1,s2 : String255;
begin
  s1 := ReadStringFromRessource(TextesErreursID,3);   {'Le format du presse-papier n'est pas connu de moi :-('}
  s2 := ReadStringFromRessource(TextesErreursID,19);  {'Je n'arrive pas a comprendre le contenu du presse-papier'}
  AlerteDouble(s2,s1);
end;

procedure AlerteFormatNonReconnuFichierPartie(nomFichier : String255);
var s : String255;
begin
  if EstUnNomDeFichierTemporaireDePressePapier(nomFichier)
    then
      begin
        // AlerteErreurCollagePartie
      end
    else
      begin
        s := ReadStringFromRessource(TextesErreursID,4);  {'Le format du fichier ^0 me semble incorrect !!'}
	      AlerteSimple(ParamStr(s,nomFichier,'','',''));
      end;
end;


procedure AlerteDoitInterompreReflexionPourFaireScript;
var s : String255;
begin
  s := ReadStringFromRessource(TextesErreursID,6);  {'Pas possible de faire script !!'}
	AlerteSimple(ParamStr(s,'','','',''));
end;





function MyFiltreClassiqueRapide(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  MyFiltreClassiqueRapide := false;
  if not(EvenementDuDialogue(dlog,evt))
    then
      begin
        if evt.what = UpdateEvt then
          begin
            if FiltreClassique(dlog,evt,item)
              then MyFiltreClassiqueRapide := true
              else DoUpdateWindowRapide(WindowPtr(evt.message));
          end;
      end
    else
      begin
        MyFiltreClassiqueRapide := FiltreClassique(dlog,evt,item);
      end;
end;



procedure AjoutePion(x,coul : SInt16; var platJeu : plateauOthello; var jouable : plBool);
var i,t : SInt16;
begin
   case coul of
   pionNoir,pionBlanc:
      begin
         platJeu[x] := coul;
         jouable[x] := false;
         for t := dirJouableDeb[x] to dirJouableFin[x] do
         begin
           i := x+dirJouable[t];
           jouable[i] := (platJeu[i] = 0);
         end;
      end;
   end;  {case of }
end;



procedure PosePion(x,couleur : SInt16);
var aux : plateauOthello;
begin
  aux := JeuCourant;
  AjoutePion(x,couleur,aux,emplJouable);
  SetJeuCourant(aux,AQuiDeJouer);
  DessinePion(x,couleur);
end;






procedure SetAfficheInfosApprentissage(flag : boolean);
begin
  afficheInfosApprentissage := flag;
end;


function GetAfficheInfosApprentissage : boolean;
begin
  GetAfficheInfosApprentissage := afficheInfosApprentissage;
end;


end.
