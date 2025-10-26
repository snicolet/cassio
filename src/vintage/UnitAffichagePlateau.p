UNIT UnitAffichagePlateau;


INTERFACE


 USES UnitDefCassio;





procedure InitUnitOth1;
procedure InstalleEssaieUpdateEventsWindowPlateauProc(aRoutine : ProcedureType);


procedure EcritCommentaireOuverture(commentaire : String255);
procedure EffaceCommentaireOuverture;

function EpaisseurBordureOthellier : SInt32;

procedure PrepareTexteStatePourTranscript;
procedure PrepareTexteStatePourHeure;
procedure PrepareTexteStatePourMeilleureSuite;
procedure PrepareTexteStatePourDemandeCoup;
procedure PrepareTexteStatePourCommentaireSolitaire;
procedure PrepareTexteStatePourSystemeCoordonnees;
procedure PrepareTexteStatePourCommentaireOuverture;
procedure PrepareTexteStatePourEcritCoupsBibl;
procedure SetPositionScore;
procedure SetPositionDemandeCoup(fonctionAppelante : String255);
procedure SetPositionMeilleureSuite;
procedure SetAffichageVertical;
procedure SetPositionsTextesWindowPlateau;
procedure DessineAffichageVertical;
function GetTailleCaseCourante : SInt32;
procedure SetTailleCaseCourante(taille : SInt32);
function TailleCaseIdeale : SInt16;
procedure AjusteTailleFenetrePlateauPourLa3D;
procedure AjusteAffichageFenetrePlat(tailleCaseForcee : SInt16; var tailleCaseChange,positionscorechange : boolean);
procedure AjusteAffichageFenetrePlatRapide;
procedure AfficheScore;
procedure AfficheDemandeCoup;
procedure EcritJeReflechis(coulChoix : SInt16);
procedure EcritPromptFenetreReflexion;
procedure EffacePromptFenetreReflexion;
function GetRectOfSquare2DDansAireDeJeu(whichSquare,QuelGenreDeMarque : SInt16) : rect;
function GetBoundingRectOfSquare(whichSquare : SInt16) : rect;
function GetOthellier2DVistaBuffer : rect;
function GetOthellierVistaBuffer : rect;
procedure RetrecirRectOfSquarePourTexturesAlveolees(var theRect : rect);
procedure ChangeRectOfSquarePourPicture(var theRect : rect);
procedure DessinePion2D(square,valeurPion : SInt16);
procedure DessinePion(square,valeurPion : SInt16);
procedure ApprendPolygonePionDelta(r : rect);
procedure ApprendPolygonePionLosange(r : rect);
procedure ApprendPolygonePionCarre(r : rect);
procedure DessinePionSpecial(rectangle2D,dest : rect; quelleCase,valeurPion : SInt16; texte : String255; use3D : boolean);
procedure DrawJustifiedStringInRectWithRGBColor(whichRect : rect; var s : String255; justification : SInt32; whichSquare : SInt16; color : RGBColor);
procedure DrawJustifiedStringInRect(whichRect : rect; couleurDesLettres : SInt16; var s : String255; justification : SInt32; whichSquare : SInt16);
procedure DrawClockBoundingRect(clockRect : rect; radius : SInt32);
procedure DrawInvertedClockBoundingRect(clockRect : rect; radius : SInt32);
procedure DessineStringInRect(whichRect : rect; couleurDesLettres : SInt16; var s : String255; whichSquare : SInt16);
procedure DessineStringOnSquare(whichSquare,couleurDesLettres : SInt16; var s : String255; var continuer : boolean);
procedure DessineLettreBlancheOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineLettreNoireOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineLettreOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
procedure DessineAnglesCarreCentral;
procedure DessineSystemeCoordonnees;
procedure EffacerSquare(var whichSquare : SInt16; var continuer : boolean);
procedure RedessinerRectDansSquare(whichSquare : SInt16; whichRect : rect);
procedure SetPositionPlateau2D(nbrecases,tailleCase : SInt16; HG_h,HG_v : SInt16; fonctionAppelante : String255);
procedure DessinePlateau(avecDessinFondNoir : boolean);
procedure DessinePlateau2D(cases,tailleCase : SInt16; HG_h,HG_v : SInt16; avecDessinFondNoir : boolean);
procedure DessinePosition(const position : plateauOthello);
procedure DessineDiagramme(tailleCaseDiagramme : SInt16; clipRegion : RgnHandle; fonctionAppelante : String255);
procedure DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(jusquaQuelCoup : SInt16);
procedure Faitcalculs2DParDefaut;
procedure DessineBordureDuPlateau2D(quellesBordures : SInt32);

procedure DessineNumeroCoup(square,n,couleurDesChiffres : SInt16; whichNode : GameTree);
procedure DessineNumeroDernierCoupSurOthellier(surQuellesCases : SquareSet; whichNode : GameTree);
procedure EffaceNumeroCoup(square,n : SInt16; whichNode : GameTree);



procedure EcritCommentaireSolitaire;
procedure DessineGarnitureAutourOthellierPourEcranStandard;
procedure EcranStandard(clipRegion : RgnHandle; forcedErase : boolean);
procedure DessineAutresInfosSurCasesAideDebutant(surQuellesCases : SquareSet; fonctionAppelante : String255);
procedure DessineAideDebutant(avecDessinAutresInfosSurLesCases : boolean; surQuellesCases : SquareSet);
procedure EffaceAideDebutant(avecDessinAutresInfosSurLesCases,effacageLarge : boolean; surQuellesCases : SquareSet; fonctionAppelante : String255);
procedure EffaceSuggestionDeCassio;
procedure ActiverSuggestionDeCassio(whichPos : PositionEtTraitRec; bestMove,bestDef : SInt32; fonctionAppelante : String255);
function GetBestSuggestionDeCassio : SInt32;
function CaseContientUnPionDore(whichSquare : SInt32) : boolean;
procedure EraseRectDansWindowPlateau(whichRect : rect);
procedure EffaceZoneADroiteDeLOthellier;
procedure EffaceZoneAuDessousDeLOthellier;
procedure EffaceZoneAGaucheDeLOthellier;
procedure EffaceZoneAuDessusDeLOthellier;
procedure EffaceTouteLaFenetreSaufLOthellier;
function  CalculateBordureRect(quelleBordure : SInt32; quelleTexture : CouleurOthellierRec) : rect;
function  PtInPlateau2D(loc : Point; var caseCliquee : SInt16) : boolean;
function  PtInPlateau(loc : Point; var caseCliquee : SInt16) : boolean;
procedure EffaceAnnonceFinaleSiNecessaire;



procedure SetOthellierEstSale(square : SInt16; flag : boolean);
function GetOthellierEstSale(square : SInt16) : boolean;
procedure SetOthellierToutEntierEstSale;

function CalculeTailleCaseParPlateauRect(thePlateauRect : rect) : SInt16;
procedure SetAffichageResserre(forceUpdate : boolean);

function UpdateRgnTouchePlateau : boolean;
procedure DessinePourcentage(square,n : SInt16);
procedure DessinePionMontreCoupLegal(x : SInt16);
procedure EffacePionMontreCoupLegal(x : SInt16);


procedure SetCoupEntete(square : SInt16);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp, QuickdrawText, MacWindows, Fonts, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitBufferedPICT, UnitTroisiemeDimension, Unit3DPovRayPicts, UnitDiagramFforum, UnitGestionDuTemps
    , UnitEntreeTranscript, UnitFenetres, UnitAffichageReflexion, UnitGestionDuTemps, UnitStrategie, UnitArbreDeJeuCourant, UnitAffichageArbreDeJeu, Zebra_to_Cassio
    , UnitNotesSurCases, UnitCalculCouleurCassio, UnitNormalisation, UnitSolitaire, UnitCurseur, UnitSetUp, UnitEntreesSortiesGraphe, UnitBibl
    , UnitActions, UnitRapport, UnitPositionEtTrait, MyQuickDraw, UnitCarbonisation, UnitGeometrie, MyAntialiasing, UnitCouleur
    , MyMathUtils, UnitSquareSet, MyStrings, UnitModes, MyFonts, UnitScannerUtils, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/AffichagePlateau.lk}
{$ENDC}


{END_USE_CLAUSE}








var gTailleCase : record
                    private : SInt32;
                  end;
    gNiveauDeRecursionDansDrawJustifiedStringInRect : SInt32;
    coupEnTete : SInt32;

    gPileDesRectanglesRecursifsARedessiner :  record
                                                cardinal          : SInt32;
                                                pile              : array[0..100] of record
                                                                                       square : SInt32;
                                                                                       theRect : Rect;
                                                                                     end;
                                                nbAppelsRecursifs : SInt32;
                                              end;


procedure BidProc;
begin
end;





procedure InitUnitOth1;
var i,j : SInt16;
begin
  othellierToutEntier := [];
  for i := 1 to 8 do
    for j := 1 to 8 do
      othellierToutEntier := othellierToutEntier+[i*10+j];

  EssaieUpdateEventsWindowPlateauProcEstInitialise := false;
  EssaieUpdateEventsWindowPlateauProc := BidProc;
  gHorlogeRect       := MakeRect(0,0,0,0);
  gHorlogeRectGlobal := MakeRect(0,0,0,0);

  gNiveauDeRecursionDansDrawJustifiedStringInRect := 0;

  gPileDesRectanglesRecursifsARedessiner.cardinal          := 0;
  gPileDesRectanglesRecursifsARedessiner.nbAppelsRecursifs := 0;

  for i := 0 to 100 do
    begin
      gPileDesRectanglesRecursifsARedessiner.pile[i].square := -1;
      gPileDesRectanglesRecursifsARedessiner.pile[i].theRect := MakeRect(-1,-1,-1,-1);
    end;

  InvalidateAllCasesDessinEnTraceDeRayon;
end;


procedure InstalleEssaieUpdateEventsWindowPlateauProc(aRoutine : ProcedureType);
begin
  EssaieUpdateEventsWindowPlateauProcEstInitialise := true;
  EssaieUpdateEventsWindowPlateauProc := aRoutine;
end;


function CalculateBordureRect(quelleBordure : SInt32; quelleTexture : CouleurOthellierRec) : rect;
var epaisseur,dx,dy : SInt32;
    unRect : rect;
begin

  epaisseur := EpaisseurBordureOthellier;

  if (quelleTexture.estUneImage) and
     (quelleTexture.nomFichierTexture = 'Photographique')
    then begin dx :=  0; dy := +1 end
    else begin dx :=  0; dy := 0  end;

  {bordure en haut}
  if (quelleBordure and kBordureDuHaut) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur,
                         {dy + aireDeJeu.top    - epaisseur} 0,
                         dx + aireDeJeu.right  + epaisseur,
                         dy + aireDeJeu.top);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure a gauche}
  if (quelleBordure and kBordureDeGauche) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur,
                         dy + aireDeJeu.top    - epaisseur,
                         dx + aireDeJeu.left,
                         dy + aireDeJeu.bottom + 2 );
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure en bas}
  if (quelleBordure and kBordureDuBas) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.left   - epaisseur,
                         dy + aireDeJeu.bottom - 1,
                         dx + aireDeJeu.right  + epaisseur,
                         dy + aireDeJeu.bottom + epaisseur + 2);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;
  {bordure a droite}
  if (quelleBordure and kBordureDeDroite) <> 0 then
    begin
      unRect := MakeRect(dx + aireDeJeu.right  - 1,
                         dy + aireDeJeu.top    - epaisseur,
                         dx + aireDeJeu.right  + epaisseur ,
                         dy + aireDeJeu.bottom + epaisseur {- 1} + 2);
      CalculateBordureRect := unRect;
      exit(CalculateBordureRect);
    end;

  {default}
  CalculateBordureRect := MakeRect(0,0,0,0);
end;





procedure EraseRectDansWindowPlateau(whichRect : rect);
var oldPort : grafPtr;
    error : OSErr;
begin
  if windowPlateauOpen then
    begin
      if CassioEstEn3D and EnJolie3D
        then
          begin
            EraseRectPovRay3D(whichRect);
            if SectRect(whichRect,gHorlogeRect,whichRect)
             then DrawClockBoundingRect(gHorlogeRect,10);
          end
        else
          begin
			      GetPort(oldPort);
			      SetPortByWindow(wPlateauPtr);

			      if garderPartieNoireADroiteOthellier or not(BordureOthellierEstUneTexture)
			        then
			          begin
			            MyEraseRect(whichRect);
			            MyEraseRectWithColor(whichRect,BleuPaleCmd,blackPattern,'');
			          end
			        else error := DrawBordureRectDansFenetre(whichRect,wPlateauPtr);

			      SetPort(oldPort);
			    end;
    end;
end;


procedure EffaceZoneADroiteDeLOthellier;
var unRect : rect;
begin

  if CassioEstEn3D then
    begin
      DrawClockBoundingRect(gHorlogeRect,10);
      exit(EffaceZoneADroiteDeLOthellier);
    end;

  if not(CassioEstEn3D) and not(EnModeEntreeTranscript) {or enRetour} then
    with aireDeJeu do
    begin

      if avecSystemeCoordonnees
        then SetRect(unRect,CalculateBordureRect(kBordureDeDroite,gCouleurOthellier).right,0,3000,3000)
        else SetRect(unRect,aireDeJeu.right-1,0,3000,3000);

      EraseRectDansWindowPlateau(unRect);

      DrawClockBoundingRect(gHorlogeRect,10);
    end;
end;



procedure EffaceZoneAuDessousDeLOthellier;
var unRect : rect;
    oldPort : grafPtr;
begin
  if not(CassioEstEn3D) {and not(EnModeEntreeTranscript)} {or enRetour} then
    with aireDeJeu do
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      if avecSystemeCoordonnees
        then SetRect(unRect,0,CalculateBordureRect(kBordureDuBas,gCouleurOthellier).bottom,3000,3000)
        else SetRect(unRect,0,aireDeJeu.bottom-1,3000,3000);

      if EnModeEntreeTranscript
        then
          begin
            (* EraseRectDansWindowPlateau(MakeRect(3000,3000,3001,3001)); *) {cette ligne pour charger la texture de bois}
            MyEraseRect(unRect);
            MyEraseRectWithColor(unRect,BleuPaleCmd,blackPattern,'');
          end
        else
          EraseRectDansWindowPlateau(unRect);

      SetPort(oldPort);
    end;
end;

procedure EffaceZoneAGaucheDeLOthellier;
var unRect : rect;
begin
  if not(CassioEstEn3D) and not(EnModeEntreeTranscript) {or enRetour} then
    with aireDeJeu do
    begin
      SetRect(unRect,0,0,left,3000);
      EraseRectDansWindowPlateau(unRect);
    end;
end;

procedure EffaceZoneAuDessusDeLOthellier;
var unRect : rect;
begin
  if not(CassioEstEn3D) and not(EnModeEntreeTranscript) {or enRetour} then
    with aireDeJeu do
    begin
      SetRect(unRect,0,0,3000,top);
      if (gCouleurOthellier.nomFichierTexture = 'Photographique') then SetRect(unRect,0,0,3000,top+1);
      EraseRectDansWindowPlateau(unRect);
    end;
end;

procedure EffaceTouteLaFenetreSaufLOthellier;
begin
  EffaceZoneADroiteDeLOthellier;
  EffaceZoneAuDessousDeLOthellier;
  EffaceZoneAGaucheDeLOthellier;
  EffaceZoneAuDessusDeLOthellier;
end;



procedure EcritCommentaireOuverture(commentaire : String255);
var unRect : rect;
    oldport : grafPtr;
begin
  if windowPlateauOpen and not(EnModeEntreeTranscript) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      SetRect(unRect,posHdemande,posVdemande-26,posHdemande+300,posVdemande-14);
      EraseRectDansWindowPlateau(unRect);
      Moveto(posHdemande,posVdemande-16);
      MyDrawString('Ç '+commentaire+' È');
      SetPort(oldport);
    end;
end;

procedure EffaceCommentaireOuverture;
var unRect : rect;
    oldport : grafPtr;
begin
  if windowPlateauOpen and not(EnModeEntreeTranscript) then
    begin
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      SetRect(unRect,posHdemande,posVdemande-26,posHdemande+300,posVdemande-14);
      EraseRectDansWindowPlateau(unRect);
      SetPort(oldport);
    end;
end;








procedure PrepareTexteStatePourTranscript;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourTranscript');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(bold);
      TextFont(gCassioApplicationFont);


      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
	        {DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));}
	        EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	      end;

      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourHeure;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourHeure');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      if NePasUtiliserLeGrasFenetreOthellier
        then TextFace(normal)
        else TextFace(bold);
      TextFont(gCassioApplicationFont);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourMeilleureSuite;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourMeilleureSuite');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      TextSize(gCassioSmallFontSize);
      if BordureOthellierEstUneTexture
        then
          begin
            TextFace(normal);
            TextMode(srcBic);
            if false and gCassioUseQuartzAntialiasing then
              begin
                if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
	              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false);
	            end;

          end
        else
          begin
            TextFace(normal);
            TextMode(srcBic);
          end;
      TextFont(gCassioApplicationFont);



      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourDemandeCoup;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourDemandeCoup');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      if NePasUtiliserLeGrasFenetreOthellier or EnJolie3D
        then TextFace(normal)
        else TextFace(bold);
      TextFont(gCassioApplicationFont);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourCommentaireSolitaire;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireSolitaire');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      if BordureOthellierEstUneTexture
        then
          begin
            TextFace(normal);
            TextMode(srcBic);
            {if gCassioUseQuartzAntialiasing then
              begin
                if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
                EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false);
              end;}
          end
        else
          begin
            TextFace(normal);
            TextMode(srcBic);
          end;
      TextFont(gCassioApplicationFont);

      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourSystemeCoordonnees;
var oldPort : grafPtr;
    couleurCoordonnees : RGBColor;
begin  {$UNUSED couleurCoordonnees}
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourSystemeCoordonnees');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize+1);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      if BordureOthellierEstUneTexture and not(FichierBordureEstIntrouvable)
        then
          begin
            TextMode(srcOr);
            TextFace(normal);
            {SetRGBColor(couleurCoordonnees,65535,60138,6168);  (* couleur du pion dore *)
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);}
            couleurCoordonnees := CouleurCmdToRGBColor(MarronCmd);
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);
            if gCassioUseQuartzAntialiasing then
              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
          end
        else
          begin
            {utiliser les deux lignes ci-dessous pour un blanc tout simple et discret}
            (* TextMode(srcBic);
               TextFace(normal); *)


            TextMode(srcOr);
            TextFace(normal);
            {SetRGBColor(couleurCoordonnees,65535,60138,6168);}        {* couleur du pion dor *}
            couleurCoordonnees := CouleurCmdToRGBColor(BlancCmd);  {* Blanc *}
            RGBForeColor(couleurCoordonnees);
            RGBBackColor(couleurCoordonnees);
            if false and gCassioUseQuartzAntialiasing then
              EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);


          end;

      TextFont(gCassioApplicationFont);
      SetPort(oldPort);
    end;
end;

procedure PrepareTexteStatePourCommentaireOuverture;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireOuverture');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(normal);
      TextFont(gCassioApplicationFont);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      SetPort(oldPort);
    end;
end;


procedure PrepareTexteStatePourEcritCoupsBibl;
var oldPort : grafPtr;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      {WritelnDansRapport('entree dans PrepareTexteStatePourCommentaireOuverture');}
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextSize(gCassioSmallFontSize);
      TextMode(srcBic);
      TextFace(normal);
      TextFont(gCassioApplicationFont);

      if gCassioUseQuartzAntialiasing then
	      begin
	        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;
	        DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	      end;

      SetPort(oldPort);
    end;
end;


function EpaisseurBordureOthellier : SInt32;
begin
  EpaisseurBordureOthellier := aireDeJeu.top;
end;


function CalculateHorlogeBoundingRect : rect;
var positionNaturelleOfBoundingRect,delta : SInt32;
    limiteANePasDepasserVersLaGauche : SInt32;
begin
  if CassioEstEn3D
    then
      begin
        if (GetWindowPortRect(wPlateauPtr).right - GetWindowPortRect(wPlateauPtr).left ) <= 650
          then CalculateHorlogeBoundingRect := MakeRect(posHNoirs-8,posVNoirs-15,posHBlancs+69,posVBlancs+18)
          else CalculateHorlogeBoundingRect := MakeRect(posHNoirs-8,posVNoirs-15,posHBlancs+70,posVBlancs+18);
      end
    else
      begin
        positionNaturelleOfBoundingRect := posHNoirs-8;

        if garderPartieNoireADroiteOthellier or not(BordureOthellierEstUneTexture)
          then limiteANePasDepasserVersLaGauche := aireDeJeu.right + EpaisseurBordureOthellier + 3
          else limiteANePasDepasserVersLaGauche := aireDeJeu.right;

        delta := limiteANePasDepasserVersLaGauche - positionNaturelleOfBoundingRect;

        if delta < 0
          then CalculateHorlogeBoundingRect := MakeRect(positionNaturelleOfBoundingRect,posVNoirs-15,posHBlancs+70,posVBlancs+18)
          else CalculateHorlogeBoundingRect := MakeRect(limiteANePasDepasserVersLaGauche,posVNoirs-15,posHBlancs+70-delta+2,posVBlancs+18);
      end;
end;


procedure DrawClockBoundingRect(clockRect : rect; radius : SInt32);
var couleurDuBois : RGBColor;
    tailleOmbrageDuBouton : SInt32;
begin

  if not(CassioEstEn3D) and garderPartieNoireADroiteOthellier
    then exit(DrawClockBoundingRect);


  if not(EnModeEntreeTranscript or enRetour or enSetUp) then
    begin

      if not(CassioEstEn3D)
        then SetRGBColor(couleurDuBois,30500,14000,2800)
        else
          if (Pos('Table',NomTexture3D) > 0) or
             (Pos('Escargot',NomTexture3D) > 0)
            then SetRGBColor(couleurDuBois,21120,15680,7280)
            else exit(DrawClockBoundingRect);

      if CassioEstEn3D or (BordureOthellierEstUneTexture and not(garderPartieNoireADroiteOthellier))
        then tailleOmbrageDuBouton := 5
        else tailleOmbrageDuBouton := 2;

      if CassioEstEn3D then tailleOmbrageDuBouton := 4;

      DessineOmbreRoundRect(clockRect,radius,radius,couleurDuBois,tailleOmbrageDuBouton,2000,0,1);
    end;
end;


procedure DrawInvertedClockBoundingRect(clockRect : rect; radius : SInt32);
var couleurDuBois : RGBColor;
    tailleOmbrageDuBouton : SInt32;
begin

  if not(CassioEstEn3D) and garderPartieNoireADroiteOthellier
    then exit(DrawInvertedClockBoundingRect);

  if not(EnModeEntreeTranscript or enRetour or enSetUp) then
    begin
      if not(CassioEstEn3D)
        then SetRGBColor(couleurDuBois,30500,14000,2800)
        else
          if (Pos('Table',NomTexture3D) > 0) or
             (Pos('Escargot',NomTexture3D) > 0)
            then SetRGBColor(couleurDuBois,21120,15680,7280)
            else exit(DrawInvertedClockBoundingRect);

      if CassioEstEn3D or BordureOthellierEstUneTexture and not(garderPartieNoireADroiteOthellier)
        then tailleOmbrageDuBouton := 5
        else tailleOmbrageDuBouton := 2;

      if CassioEstEn3D then tailleOmbrageDuBouton := 4;

      DessineOmbreRoundRect(clockRect,radius,radius,couleurDuBois,tailleOmbrageDuBouton,2500,2000,1);
    end;
end;


function RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(windowRect : rect; whichRect : rect) : boolean;
var oldPort : grafPtr;
begin
  RectangleDeFenetreCacheCeRectangleDansFenetrePlateau := false;

  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    begin
      GetPort(oldPort);
      EssaieSetPortWindowPlateau;
      GlobalToLocalRect(windowRect);

      RectangleDeFenetreCacheCeRectangleDansFenetrePlateau := SectRect(whichRect,windowRect,windowRect);

      SetPort(oldPort);
    end;
end;


procedure SetPositionScore2D;
var limiteDroiteDeLaFenetre : SInt32;
    auxNoirs,auxBlancs : SInt32;
    decalageAuxiliaireVersLaDroite : SInt32;
begin
 if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
   then
     begin
      posHNoirs := 3;
      posVNoirs := aireDeJeu.bottom+24;
      posHBlancs := posHNoirs;
      posVBlancs := posVNoirs+25;
     end
   else
     begin
       limiteDroiteDeLaFenetre := GetWindowPortRect(wPlateauPtr).right;


       decalageAuxiliaireVersLaDroite := 0;
       if garderPartieNoireADroiteOthellier or not(BordureOthellierEstUneTexture) then
        if avecSystemeCoordonnees
          then decalageAuxiliaireVersLaDroite := EpaisseurBordureOthellier + 4;


       posHNoirs := aireDeJeu.right+20;
       posVNoirs := 25;
       if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre) or
          (limiteDroiteDeLaFenetre-aireDeJeu.right < 156 + EpaisseurBordureOthellier + decalageAuxiliaireVersLaDroite)
         then posHNoirs := aireDeJeu.right+3;



       posHBlancs := posHNoirs+80;
       posVBlancs := 25;
       if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre)  or
          (genreAffichageTextesDansFenetrePlateau = kAffichageUnPeuSerre) or
          (limiteDroiteDeLaFenetre-aireDeJeu.right < 156 + EpaisseurBordureOthellier + decalageAuxiliaireVersLaDroite)
        then
          begin
            if (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre) or
               (limiteDroiteDeLaFenetre-aireDeJeu.right < 80 + EpaisseurBordureOthellier + decalageAuxiliaireVersLaDroite)
              then posHNoirs := aireDeJeu.right+3
              else posHNoirs := aireDeJeu.right+20;
            posHBlancs := posHNoirs;
            if gVersionJaponaiseDeCassio and gHasJapaneseScript
              then posVBlancs := posVNoirs+33  {on met un peu plus de blanc car affichage en 12 points}
              else posVBlancs := posVNoirs+30;
          end;

       posHNoirs  := posHNoirs  + decalageAuxiliaireVersLaDroite;
       posHBlancs := posHBlancs + decalageAuxiliaireVersLaDroite;

       {on dcale vers le bas parce que l'on affiche dsormais un cadre autour de l'horloge}
       posVNoirs  := posVNoirs + 8;
       posVBlancs := posVBlancs + 8;


       {on met le bouton plutot en bas de l'othellier}
       if false then
         begin
           auxNoirs  := posVNoirs;
           auxBlancs := posVBlancs;
           posVBlancs := aireDeJeu.bottom - auxNoirs - 18;
           posVNoirs  := aireDeJeu.bottom - auxBlancs - 18;
         end;

     end;
end;


procedure SetPositionScore;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    if CassioEstEn3D
      then SetPositionScore3D
      else SetPositionScore2D;


  gHorlogeRect := CalculateHorlogeBoundingRect;

  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      gHorlogeRectGlobal := gHorlogeRect;
      LocalToGlobalRect(gHorlogeRectGlobal);
      SetPort(oldPort);
    end;
end;




procedure SetPositionDemandeCoup2D;
var limiteDroiteDeLaFenetre : SInt16;
begin
  {if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
     then
      begin
        posHDemande := 40;
        PosVDemande := aireDeJeu.bottom+50;
      end
     else}
      begin
        limiteDroiteDeLaFenetre := GetWindowPortRect(wPlateauPtr).right;
        posHDemande := aireDeJeu.right+20;


        if (limiteDroiteDeLaFenetre-aireDeJeu.right < 150 + EpaisseurBordureOthellier) or
           (genreAffichageTextesDansFenetrePlateau = kAffichageUnPeuSerre)
          then posHDemande := aireDeJeu.right+5;


        if (limiteDroiteDeLaFenetre-aireDeJeu.right < 130 + EpaisseurBordureOthellier) or
           (genreAffichageTextesDansFenetrePlateau = kAffichageTresSerre)
          then posHDemande := aireDeJeu.right+1;

        {on decale eventuellement a cause de la bordure}
        if garderPartieNoireADroiteOthellier or not(BordureOthellierEstUneTexture) then
          if avecSystemeCoordonnees then
            posHDemande := posHDemande + EpaisseurBordureOthellier + 1;

        PosVDemande := aireDeJeu.bottom-9;

      end;
end;

procedure SetPositionDemandeCoup(fonctionAppelante : String255);
begin  {$UNUSED fonctionAppelante}
  if windowPlateauOpen then
	  if CassioEstEn3D
	    then SetPositionDemandeCoup3D
	    else SetPositionDemandeCoup2D;
end;

procedure SetPositionMeilleureSuite2D;
begin
  posHMeilleureSuite := aireDeJeu.left   + 3;
  posVMeilleureSuite := aireDeJeu.bottom + 12;
end;


procedure SetPositionMeilleureSuite;
var theRect,windowRect : rect;
    largeurParDefaut,hauteurFenetre : SInt32;
begin
  if windowPlateauOpen then
	  begin
	    if CassioEstEn3D
	      then SetPositionMeilleureSuite3D
	      else SetPositionMeilleureSuite2D;


	    (* WritelnDansRapport('dans SetPositionMeilleureSuite'); *)
	    with theRect do
	      begin

	        largeurParDefaut := 150;
	        windowRect       := GetWindowPortRect(wPlateauPtr);
	        hauteurFenetre   := windowRect.bottom - windowRect.top;

	        left   := posHMeilleureSuite - 15;
	        right  := left + largeurParDefaut;
	        top    := Max(posVMeilleureSuite  - 30, GetOthellierVistaBuffer.bottom);
	        bottom := Min(posVMeilleureSuite + 15, hauteurFenetre);

	      end;

	    SetMeilleureSuiteRect(theRect);
	    CalculateMeilleureSuiteWidth;
	    CalculateMeilleureSuiteRectGlobal;
	  end;
end;



procedure SetAffichageVertical;
var doitredessiner : boolean;
    tempoGenreAffichage : SInt32;
begin
  doitredessiner := false;
  if windowPlateauOpen and not(CassioEstEn3D) and (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) then
    with VisibiliteInitiale do
      begin
        if (windowListeOpen or windowStatOpen) or
           (gPendantLesInitialisationsDeCassio and (tempowindowListeOpen or tempowindowStatOpen))
          then
            begin
              tempoGenreAffichage := genreAffichageTextesDansFenetrePlateau;

              { on essaie avec l'affichage aere normal}
              genreAffichageTextesDansFenetrePlateau := kAffichageAere;
              SetPositionScore;
              SetPositionDemandeCoup('SetAffichageVertical {1}');
              SetPositionMeilleureSuite;

              if RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wListePtr),gHorlogeRect) or
                 RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wStatPtr),gHorlogeRect) then
                begin
                  { on essaie avec l'affichage un peu serre pres de l'othellier }
                  genreAffichageTextesDansFenetrePlateau := kAffichageUnPeuSerre;
                  SetPositionScore;
                  SetPositionDemandeCoup('SetAffichageVertical {2}');
                  SetPositionMeilleureSuite;

                  if RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wListePtr),gHorlogeRect) or
                     RectangleDeFenetreCacheCeRectangleDansFenetrePlateau(GetWindowStructRect(wStatPtr),gHorlogeRect) then
                    begin
                      { on essaie avec l'affichage tres serre pres de l'othellier }
                      genreAffichageTextesDansFenetrePlateau := kAffichageTresSerre;
                      SetPositionScore;
                      SetPositionDemandeCoup('SetAffichageVertical {3}');
                      SetPositionMeilleureSuite;
                    end;
                end;
              doitredessiner := true;
            end
          else
            begin
              { on met avec l'affichage aere normal}
              if (genreAffichageTextesDansFenetrePlateau <> kAffichageAere) then
                begin
                  genreAffichageTextesDansFenetrePlateau := kAffichageAere;
                  SetPositionScore;
                  SetPositionDemandeCoup('SetAffichageVertical {4}');
                  SetPositionMeilleureSuite;
                  doitredessiner := true;
                end;
            end;
      end;
  if doitredessiner then
    DessineAffichageVertical;
end;

procedure SetPositionsTextesWindowPlateau;
begin
  SetAffichageVertical;
  SetPositionScore;
  SetPositionDemandeCoup('SetPositionsTextesWindowPlateau');
  SetPositionMeilleureSuite;
  CalculateRectEscargotGlobal;
end;


procedure DessineAffichageVertical;
var unRect : rect;
    oldPort : grafPtr;
begin
  if windowPlateauOpen and not(CassioEstEn3D) and
    (genreAffichageTextesDansFenetrePlateau <> kAffichageSousOthellier) and
    not(EnModeEntreeTranscript) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if not(enRetour or enSetUp) then
        begin
          DessineBordureDuPlateau2D(kBordureDeDroite);
          SetRect(unRect,aireDeJeu.right+EpaisseurBordureOthellier,0,GetWindowPortRect(wPlateauPtr).right,aireDeJeu.bottom);
          EraseRectDansWindowPlateau(unRect);
          PrepareTexteStatePourHeure;
          AfficheScore;
          EcritPromptFenetreReflexion;
          if afficheMeilleureSuite and not(MeilleureSuiteEffacee) then EcritMeilleureSuite;
          DessineBoiteDeTaille(wPlateauPtr);
          dernierTick := TickCount;
          Heure(pionNoir);
          Heure(pionBlanc);
          DrawClockBoundingRect(gHorlogeRect,10);
        end;

      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      SetPort(oldPort);
    end;
end;

function GetTailleCaseCourante : SInt32;
begin
  GetTailleCaseCourante := gTailleCase.private;
end;


procedure SetTailleCaseCourante(taille : SInt32);
begin
  gTailleCase.private := taille;
end;


function TailleCaseIdeale : SInt16;
var aux : SInt16;
    unRect : rect;
    tailleIdealeHorizontale : SInt16;
    tailleIdealeVerticale : SInt16;
begin
  if not(windowPlateauOpen)
    then TailleCaseIdeale := 37
    else
      begin
        unRect := GetWindowPortRect(wPlateauPtr);


        aux := unRect.bottom-unRect.top;
        if avecSystemeCoordonnees
          then aux := aux-PositionCoinAvecCoordonnees
          else aux := aux-PositionCoinSansCoordonnees;
        aux := aux - 12;
        tailleIdealeVerticale := aux div 8;


        aux := unRect.right-unRect.left;
        if EnModeEntreeTranscript
          then
            begin
              aux := (aux - RoundToL(3.7*EpaisseurBordureOthellier)) div 2;
              tailleIdealeHorizontale := aux div 8;
            end
          else
            begin
              if avecSystemeCoordonnees
                then aux := aux-PositionCoinAvecCoordonnees-10
                else aux := aux-PositionCoinSansCoordonnees-1;
              tailleIdealeHorizontale := aux div 8;
            end;

        TailleCaseIdeale := Min(tailleIdealeVerticale,tailleIdealeHorizontale);
      end;
end;

procedure AjusteAffichageFenetrePlat(tailleCaseForcee : SInt16; var tailleCaseChange,positionscorechange : boolean);
var tailleCasePrec : SInt16;
    genreAffichagePrec : SInt32;
    posHblancprec,posHNoirprec,posVblancprec,posVnoirprec : SInt16;
begin
  tailleCasePrec := GetTailleCaseCourante;
  genreAffichagePrec := genreAffichageTextesDansFenetrePlateau;
  posHblancprec := posHBlancs;
  posHNoirprec := posHNoirs;
  posVblancprec := posVBlancs;
  posVnoirprec := posVNoirs;

  if (tailleCaseForcee > 0)
    then SetTailleCaseCourante(tailleCaseForcee)
    else SetTailleCaseCourante(TailleCaseIdeale);
  if avecSystemeCoordonnees
    then SetPositionPlateau2D(8,GetTailleCaseCourante,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,'AjusteAffichageFenetrePlat')
    else SetPositionPlateau2D(8,GetTailleCaseCourante,PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,'AjusteAffichageFenetrePlat');
  SetPositionsTextesWindowPlateau;
  tailleCaseChange := (GetTailleCaseCourante <> tailleCasePrec);
  positionscorechange := (genreAffichagePrec <> genreAffichageTextesDansFenetrePlateau) or
                      (posHBlancs <> posHblancprec) or
                      (posHNoirs <> posHNoirprec) or
                      (posVBlancs <> posVblancprec) or
                      (posVNoirs <> posVnoirprec);
end;

procedure AjusteAffichageFenetrePlatRapide;
var foo : boolean;
begin
  AjusteAffichageFenetrePlat(0,foo,foo);
end;


procedure AjusteTailleFenetrePlateauPourLa3D;
var tailleActuelle,tailleDesiree : Point;
    nouvelleTaille : Point;
    tailleCaseChange,infosChangent : boolean;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) and CassioEstEn3D then
    begin
      tailleActuelle := GetWindowSize(wPlateauPtr);
      tailleDesiree := GetTailleImagesPovRay;

      if (tailleActuelle.h <> tailleDesiree.h) or (tailleActuelle.v <> tailleDesiree.v) then
        begin
          nouvelleTaille := tailleDesiree;

          {nouvelleTaille.h := Min(tailleActuelle.h,tailleDesiree.h);
          nouvelleTaille.v := Min(tailleActuelle.v,tailleDesiree.v);}

          SizeWindow(wPlateauPtr,nouvelleTaille.h,nouvelleTaille.v,false);
          AjusteAffichageFenetrePlat(0,tailleCaseChange,infosChangent);
        end;
    end;
end;

procedure AfficheScore;
var s1,s2 : String255;
    oldPort : grafPtr;
    ligneRect : rect;
begin
 if windowPlateauOpen and not(EnModeEntreeTranscript) then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     s1 := ReadStringFromRessource(TextesPlateauID,1);
     s1 := s1 + PourcentageEntierEnString(nbreDePions[pionNoir]);
     s2 := ReadStringFromRessource(TextesPlateauID,2);
     s2 := s2 + PourcentageEntierEnString(nbreDePions[pionBlanc]);
     SetRect(lignerect,posHNoirs,posVNoirs-12,posHNoirs+67,posVNoirs);


     PrepareTexteStatePourHeure;
     if gVersionJaponaiseDeCassio and gHasJapaneseScript
       then TextSize(gCassioNormalFontSize);

     Moveto(posHNoirs,posVNoirs);

     EraseRectDansWindowPlateau(lignerect);
     MyDrawString(s1);
     SetRect(lignerect,posHBlancs,posVBlancs-12,posHBlancs+67,posVBlancs);
     Moveto(posHblancs,posVBlancs);

     EraseRectDansWindowPlateau(lignerect);
     MyDrawString(s2);
     if gVersionJaponaiseDeCassio and gHasJapaneseScript
       then PrepareTexteStatePourHeure;

	   if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

     SetPort(oldPort);
   end;
end;



procedure DessineBordureDuPlateau2D(quellesBordures : SInt32);
var couleurBordure : RGBColor;
    unRect : rect;
begin

  couleurBordure := NoircirCouleur(gCouleurOthellier.RGB);
  RGBForeColor(couleurBordure);

  {bordure en haut}
  if (quellesBordures and kBordureDuHaut) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture) or (DrawBordureColorPict(kBordureDuHaut) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDuHaut,gCouleurOthellier),blackPattern);
    end;

  {bordure a gauche}
  if (quellesBordures and kBordureDeGauche) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture) or (DrawBordureColorPict(kBordureDeGauche) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDeGauche,gCouleurOthellier),blackPattern);
    end;

  {bordure en bas}
  if (quellesBordures and kBordureDuBas) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture) or (DrawBordureColorPict(kBordureDuBas) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDuBas,gCouleurOthellier),blackPattern);
    end;

  {bordure a droite}
  if (quellesBordures and kBordureDeDroite) <> 0 then
    begin
      if not(BordureOthellierEstUneTexture) or (DrawBordureColorPict(kBordureDeDroite) <> NoErr) then
        FillRect(CalculateBordureRect(kBordureDeDroite,gCouleurOthellier),blackPattern);
      DrawClockBoundingRect(gHorlogeRect,10);
    end;

  ForeColor(BlackColor);
  BackColor(WhiteColor);

  {trait noir autour de l'othellier}
  if not(gCouleurOthellier.estUneImage) then
    begin
      unRect := aireDeJeu;
      Pensize(1,1);
      FrameRect(unRect);
    end;

end;


procedure EffacePromptFenetreReflexion;
var oldPort : grafPtr;
    ligneRect : rect;
begin
  if windowPlateauOpen and not(EnModeEntreeTranscript) then
	  begin
		  GetPort(oldPort);
		  SetPortByWindow(wPlateauPtr);
		  SetPositionDemandeCoup('EffacePromptFenetreReflexion');
		  if CassioEstEn3D
		    then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
		    else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
		  EraseRectDansWindowPlateau(lignerect);
		  if PosVDemande >= GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);
		  SetPort(oldPort);
		end;
end;

procedure AfficheDemandeCoup;
var oldPort : grafPtr;
    s : String255;
    ligneRect : rect;
begin
 if not(EnModeEntreeTranscript) then
   begin
     {WritelnDansRapport('Entree dans AfficheDemandeCoup');}
     if CassioEstEnModeAnalyse and not(HumCtreHum) and (nbreCoup > 0)
       then
         begin
           EcritJeReflechis(AQuiDeJouer);
         end
       else
    		 if windowPlateauOpen then
    		   begin
    		     GetPort(oldPort);
    		     SetPortByWindow(wPlateauPtr);
    		     SetPositionDemandeCoup('afficheDemandeCoup');
    		     PrepareTexteStatePourDemandeCoup;
    		     if CassioEstEn3D
    		       then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
    		       else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
    		     EraseRectDansWindowPlateau(lignerect);
    		     Moveto(posHDemande,PosVDemande);

    		     if HumCtreHum
    		       then
    		         case AQuiDeJouer of
        		       pionNoir  :   s := ReadStringFromRessource(TextesPlateauID,29);  {Trait ˆ Noir}
        		       pionBlanc :   s := ReadStringFromRessource(TextesPlateauID,30);  {Trait ˆ Blanc}
        		       otherwise     s := '';
        		     end
    		       else
        		     case AQuiDeJouer of
        		       pionNoir  :   s := ReadStringFromRessource(TextesPlateauID,3);   {Votre coup, Noir}
        		       pionBlanc :   s := ReadStringFromRessource(TextesPlateauID,4);   {Votre coup, Blanc}
        		       otherwise     s := '';
        		     end;
    		     MyDrawString(s);
    		     if PosVDemande >= GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);


    		     if gCassioUseQuartzAntialiasing then
               if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

    		     SetPort(oldPort);
    		   end;
   end;
end;


procedure EcritJeReflechis(coulChoix : SInt16);
var oldPort : grafPtr;
    s : String255;
    ligneRect : rect;
begin
 if not(EnModeEntreeTranscript) then
   begin
     {WritelnDansRapport('Entree dans EcritJeReflechis');}
     if not(DoitPasser(coulChoix,JeuCourant,emplJouable)) then
       begin
        if windowPlateauOpen then
          begin
            GetPort(oldPort);
            SetPortByWindow(wPlateauPtr);
            SetPositionDemandeCoup('EcritJeReflechis');
            PrepareTexteStatePourDemandeCoup;
            if CassioEstEn3D
    		      then SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3)
    		      else SetRect(lignerect,posHDemande,PosVDemande-9,posHDemande+300,PosVDemande+3);
            EraseRectDansWindowPlateau(lignerect);
            Moveto(posHDemande,PosVDemande);
            s := '';
            case coulChoix of
                pionNoir    :
    			         if CassioEstEnModeAnalyse and not(analyseRetrograde.enCours) and not(CassioEstEnModeSolitaire)
    			           then s := ReadStringFromRessource(TextesPlateauID,19)  {Analyse pour Noir}
    			           else s := ReadStringFromRessource(TextesPlateauID,5);  {Je reflechis au choix des Noirs}
    		        pionBlanc   :
    		           if CassioEstEnModeAnalyse and not(analyseRetrograde.enCours) and not(CassioEstEnModeSolitaire)
    		             then s := ReadStringFromRessource(TextesPlateauID,20)  {Analyse pour Blanc}
    		             else s := ReadStringFromRessource(TextesPlateauID,6);  {Je reflechis au choix des Blancs}
            end;
            MyDrawString(s);
            if PosVDemande >= GetWindowPortRect(wPlateauPtr).bottom-19 then DessineBoiteDeTaille(wPlateauPtr);


            if gCassioUseQuartzAntialiasing then
              if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

            SetPort(oldPort);
          end;
       end;
   end;
end;

procedure EcritPromptFenetreReflexion;
begin
  if not(EnModeEntreeTranscript) then
    begin
      if gameOver
        then
          EffacePromptFenetreReflexion
        else
          begin
            (*
            WritelnDansRapport('dans EcritPromptFenetreReflexion : ');
            WritelnStringAndBoolDansRapport('  HumCtreHum  ->  ',HumCtreHum);
            WritelnStringAndBoolDansRapport('  (AQuiDeJouer = couleurMacintosh)  ->  ', (AQuiDeJouer = couleurMacintosh));
            *)
      		  if not(HumCtreHum) and (AQuiDeJouer = couleurMacintosh) and not((nbreCoup <= 0) and CassioEstEnModeAnalyse)
      		    then EcritJeReflechis(AQuiDeJouer)
      		    else AfficheDemandeCoup;
      		end;
    end;
end;


function GetRectOfSquare2DDansAireDeJeu(whichSquare,QuelGenreDeMarque : SInt16) : rect;
var x,y,a,b : SInt16;
   result : rect;
begin
  {$UNUSED QuelGenreDeMarque}
  x := platMod10[whichSquare];
  y := platDiv10[whichSquare];
  a := aireDeJeu.left+2+GetTailleCaseCourante*(x-1);
  b := aireDeJeu.top+2+GetTailleCaseCourante*(y-1);
  SetRect(result,a,b,a+GetTailleCaseCourante-3,b+GetTailleCaseCourante-3);
  GetRectOfSquare2DDansAireDeJeu := result;
end;



function GetBoundingRectOfSquare(whichSquare : SInt16) : rect;
begin
  if CassioEstEn3D
    then GetBoundingRectOfSquare := GetBoundingRect3D(whichSquare)
    else GetBoundingRectOfSquare := GetRectOfSquare2DDansAireDeJeu(whichSquare,0);
end;


function GetOthellier2DVistaBuffer : rect;
begin
  GetOthellier2DVistaBuffer := aireDeJeu;
end;

function GetOthellierVistaBuffer : rect;
begin
  if CassioEstEn3D
    then GetOthellierVistaBuffer := GetOthellier3DVistaBuffer
    else GetOthellierVistaBuffer := GetOthellier2DVistaBuffer;
end;

procedure ChangeRectOfSquarePourPicture(var theRect : rect);
begin
  with theRect do
   begin
    top := top-2;
    left := left-2;
    inc(right);
    inc(bottom);
  end;
  if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(theRect,0,1);
end;

procedure RetrecirRectOfSquarePourTexturesAlveolees(var theRect : rect);
var largeur, hauteur : SInt32;
    facteur : double;
begin
  largeur := theRect.right - theRect.left;
  hauteur := theRect.bottom - theRect.top;

  facteur := 1.0;

  if not(CassioEstEn3D) then
    with gCouleurOthellier do
      if estUneImage then
        begin
          if (Pos('Alveoles',nomFichierTexture) > 0)         then facteur := 0.94 else
          if (Pos('Tsukuda magnetic',nomFichierTexture) > 0) then facteur := 0.90 else
          if (Pos('Spear',nomFichierTexture) > 0)            then facteur := 0.83;
        end;

  if (facteur <> 1.0) then
    begin
      InsetRect(theRect, Trunc(largeur * (1.0 -facteur)) div 2 , Trunc(hauteur * (1.0 - facteur)) div 2);
    end;

end;


var dernierTickCopyBits : SInt32;


procedure DessineContourDeCase2D(whichRect : rect; square : SInt32);
var couleurOthellierClaire : RGBColor;
    couleurOthellierFoncee : RGBColor;
begin
  if retirerEffet3DSubtilOthellier2D and not(Pos('VOG',gCouleurOthellier.nomFichierTexture) > 0)
    then
      begin
        FrameRect(whichRect);
      end
    else
      begin
        couleurOthellierClaire := EclaircirCouleur(gCouleurOthellier.RGB);
			  couleurOthellierFoncee := NoircirCouleur(gCouleurOthellier.RGB);

			  PenPat(blackPattern);

			  {WritelnDansRapport('dans DessineContourDeCase2Dƒ');}
			  with whichRect do
			    begin
			      {Dessin de l'clairage :
	           on utilise la couleur de l'othellier, en plus clair }
			      RGBForeColor(couleurOthellierClaire);
	          Moveto(right-1,top+1);
	          Lineto(left+1,top+1);

	          Moveto(left+1,top+1);
	          Lineto(left+1,bottom-1);

	          {Dessin de l'ombrage :
	           sur la colonne H et la ligne 8, et si la bordure est dessinee,
	           il faut utiliser du noir a cause du cadre autour de l'othellier.
	           Sinon on utilise la couleur de l'othellier, en plus fonc }
	          if avecSystemeCoordonnees and (square div 10 = 8) and not(gCouleurOthellier.estUneImage)
	            then ForeColor(BlackColor)
	            else RGBForeColor(couleurOthellierFoncee);
	          Moveto(left+1,bottom-1);
	          Lineto(right-1,bottom-1);

	          if avecSystemeCoordonnees and (square mod 10 = 8) and not(gCouleurOthellier.estUneImage)
	            then ForeColor(BlackColor)
	            else RGBForeColor(couleurOthellierFoncee);
	          Moveto(right-1,bottom-2);
	          Lineto(right-1,top+1);

			    end;

			  ForeColor(BlackColor);

      end;
end;

procedure DessinerEventuellementContoursDesCasesTexturees(whichRect : rect; whichSquare : SInt16);
begin
  if ((Pos('VOG',gCouleurOthellier.nomFichierTexture) > 0) {or (Pos('Pions go',gCouleurOthellier.nomFichierTexture) > 0)})
    then
    begin
      {if (Pos('Pions go',gCouleurOthellier.nomFichierTexture) > 0) then
        begin
          Dec(whichRect.top);
          Dec(whichRect.left);
        end;}
      DessineContourDeCase2D(whichRect,whichSquare);
    end;
end;

procedure DessinePion2D(square,valeurPion : SInt16);
var rectangle : rect;
    a, couleur : SInt32;
begin
  rectangle := GetRectOfSquare2DDansAireDeJeu(square,0);

  case valeurPion of
    kCaseDevantEtreRedessinee :
       begin
         {if not(gCouleurOthellier.estUneImage) then DessinePion2D(square,pionVide);}
         {TraceLog(Concat('DessinePion2D : kCaseDevantEtreRedessinee, case = ',NumEnString(square)));}

         SetOthellierEstSale(square,true);
         couleur := GetCouleurOfSquareDansJeuCourant(square);
         case couleur of
           pionBlanc,pionNoir:
             begin
               DessinePion2D(square,couleur);
               if afficheNumeroCoup then DessineNumeroDernierCoupSurOthellier([square],GetCurrentNode);
               AfficheProprietesOfCurrentNode(false,[square],'DessinePion2D {1}');
             end;
           otherwise
             begin
               DessinePion2D(square,pionVide);
               if aideDebutant then DessineAideDebutant(false,[square]);
               {TraceLog('avant DessineAutresInfosSurCasesAideDebutant dans DessinePion2D');}
               DessineAutresInfosSurCasesAideDebutant([square],'DessinePion2D');
             end;
         end;
       end;

    pionBlanc:
         if gCouleurOthellier.estUneImage
           then
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionBlanc then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(1+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionBlanc);
                 end;
             end
           else
		         begin
		           {DessinePion2D(square,pionVide);}
		           PenSize(1,1);

		           if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           {FillOval(rectangle,whitePattern);
		           ForeColor(BlackColor);
		           FrameOval(rectangle);}

		           {DessinePionsAntiAliase2D(rectangle,pionBlanc,80,1,GetWindowPort(wPlateauPtr));}
		           DrawBufferedColorPict(2,rectangle,gCouleurOthellier);
		           SetValeurDessinEnTraceDeRayon(square,pionBlanc);
		         end;

    pionNoir:
        if gCouleurOthellier.estUneImage
           then
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionNoir then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(2+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionNoir);
                 end;
             end
           else
         begin
           {DessinePion2D(square,pionVide);}
           PenSize(1,1);
           if not(retirerEffet3DSubtilOthellier2D) then
             begin
               rectangle.left := rectangle.left +1;
               rectangle.top  := rectangle.top + 1;
             end;
           {FillOval(rectangle,blackPattern);}
           PenPat(blackPattern);
           {DessinePionsAntiAliase2D(rectangle,pionNoir,80,1,GetWindowPort(wPlateauPtr));}
           DrawBufferedColorPict(1,rectangle,gCouleurOthellier);
           SetValeurDessinEnTraceDeRayon(square,pionNoir);
         end;

    pionVide:
        if gCouleurOthellier.estUneImage
           then
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionVide then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionVide);
                   SetOthellierEstSale(square,false);
                 end;
             end
           else
         begin
           InsetRect(rectangle,-1,-1);
           ForeColor(gCouleurOthellier.couleurFront);
           BackColor(gCouleurOthellier.couleurBack);
           RGBForeColor(gCouleurOthellier.RGB);
           if retirerEffet3DSubtilOthellier2D or enSetUp
             then
               begin
                 FillRect(rectangle,gCouleurOthellier.whichPattern);
               end
             else
               begin
                 rectangle.left := rectangle.left + 1;
                 rectangle.top  := rectangle.top + 1;
                 FillRect(rectangle,gCouleurOthellier.whichPattern);
                 rectangle.left := rectangle.left - 1;
                 rectangle.top  := rectangle.top - 1;
               end;
           ForeColor(BlackColor);
           BackColor(WhiteColor);
           InsetRect(rectangle,-1,-1);
           DessineContourDeCase2D(rectangle,square);
           if SquareInSquareSet(square,[22,23,32,33,26,27,36,37,62,63,72,73,66,67,76,77])
             then DessineAnglesCarreCentral;
           SetValeurDessinEnTraceDeRayon(square,pionVide);
           SetOthellierEstSale(square,false);
         end;

      pionEffaceCaseLarge:
        if gCouleurOthellier.estUneImage
           then
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionVide then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionVide);
                   SetOthellierEstSale(square,false);
                 end;
             end
           else
         begin
           InsetRect(rectangle,-1,-1);
           ForeColor(gCouleurOthellier.couleurFront);
           BackColor(gCouleurOthellier.couleurBack);
           RGBForeColor(gCouleurOthellier.RGB);
           FillRect(rectangle,gCouleurOthellier.whichPattern);
           ForeColor(BlackColor);
           BackColor(WhiteColor);
           InsetRect(rectangle,-1,-1);
           DessineContourDeCase2D(rectangle,square);
           if SquareInSquareSet(square,[22,23,32,33,26,27,36,37,62,63,72,73,66,67,76,77])
             then DessineAnglesCarreCentral;
           SetValeurDessinEnTraceDeRayon(square,pionVide);
           SetOthellierEstSale(square,false);
         end;
      pionMontreCoupLegal :
         begin
           if gCouleurOthellier.estUneImage
           then
             begin
               if GetValeurDessinEnTraceDeRayon(square) <> pionMontreCoupLegal then
                 begin
                   ChangeRectOfSquarePourPicture(rectangle);
                   DrawBufferedColorPict(3+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
                   DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
                   SetValeurDessinEnTraceDeRayon(square,pionMontreCoupLegal);
                   SetOthellierEstSale(square,true);
                 end;
             end
           else
             begin
               if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           if gEcranCouleur
		             then
		               begin
		                 DrawBufferedColorPict(3,rectangle,gCouleurOthellier);

		                 ForeColor(BlackColor);
		                 BackColor(WhiteColor);
		               end
		             else
		               begin
		                 InSetRect(rectangle,1,1);
		                 InsetRect(rectangle,1,1);
		                 InvertOval(rectangle);
		               end;
		           SetValeurDessinEnTraceDeRayon(square,pionMontreCoupLegal);
		         end;
           SetOthellierEstSale(square,true);
         end;
      pionSuggestionDeCassio:
        begin
         if gCouleurOthellier.estUneImage
	         then
	           begin
	             if GetValeurDessinEnTraceDeRayon(square) <> pionSuggestionDeCassio then
	               begin
	                 ChangeRectOfSquarePourPicture(rectangle);
	                 DrawBufferedColorPict(4+NroPremierePictDeLaSerie(gCouleurOthellier.menuCmd),rectangle,gCouleurOthellier);
	                 DessinerEventuellementContoursDesCasesTexturees(rectangle,square);
	                 SetValeurDessinEnTraceDeRayon(square,pionSuggestionDeCassio);
	                 SetOthellierEstSale(square,true);
	               end;
	           end
	         else
	           begin
	             if not(retirerEffet3DSubtilOthellier2D) then
		             begin
		               rectangle.left := rectangle.left +1;
		               rectangle.top  := rectangle.top + 1;
		             end;
		           if gEcranCouleur
		             then
		               begin
		                 DrawBufferedColorPict(4,rectangle,gCouleurOthellier);
		                 {
		                 ForeColor(gCouleurOthellier.couleurFront);
		                 if gCouleurOthellier.estTresClaire
			                 then BackColor(BlackColor)
			                 else
					               if (gCouleurOthellier.menuCmd = VertSapinCmd)     or
					                  (gCouleurOthellier.menuCmd = VertTurquoiseCmd)
					                  then BackColor(WhiteColor)
					                  else BackColor(gCouleurOthellier.couleurBack);}
		               end
		             else
		               begin
		                 InsetRect(rectangle,1,1);
					           for a := 1 to (GetTailleCaseCourante div 2) do
					             begin
					               if odd(a)
					                 then PenPat(pionInversePat)
					                 else PenPat(InversePionInversePat);
					               FrameOval(rectangle);
					               InsetRect(rectangle,1,1);
					             end;
					         end;
		           ForeColor(BlackColor);
		           BackColor(WhiteColor);
		           PenPat(blackPattern);
		           SetValeurDessinEnTraceDeRayon(square,pionSuggestionDeCassio);
		         end;
          SetOthellierEstSale(square,true);
        end;
      petitpion:
        begin
          InsetRect(rectangle,8,8);
          InvertOval(rectangle);
          SetOthellierEstSale(square,true);
        end;
      (*
      pionEntoureCasePourMontrerCoupEnTete:
        begin
	        InsetRect(rectangle,-1,-1);
	        PenPat(blackPattern);
	        PenSize(1,1);
	        ForeColor(BlackColor);
	        {FrameRect(rectangle);} {c'est l'ancienne methode}
	        with rectangle do       {c'est la nouvelle mthode}
	          begin
	            dec(right);
	            dec(bottom);
	            for j := 0 to 1 do
	              begin
	                i := (GetTailleCaseCourante div 20);
	                if i > 4 then i := 4;
	                if j = 0 then a := 4+i else
	                if j = 1 then a := i;
	                if a < 1 then a := 1;
	                if (j = 0) and (a > 8) then a := 8;
	                if (j = 1) and (a > 4) then a := 4;
	                Moveto(left+j,top+a);
	                Lineto(left+j,top+j);
	                Lineto(left+a,top+j);
	                Moveto(right-j,top+a);
			            Lineto(right-j,top+j);
			            Lineto(right-a,top+j);
			            Moveto(left+j,bottom-a);
			            Lineto(left+j,bottom-j);
			            Lineto(left+a,bottom-j);
			            Moveto(right-j,bottom-a);
			            Lineto(right-j,bottom-j);
			            Lineto(right-a,bottom-j);
			          end;
	          end;
	        SetOthellierEstSale(square,true);
	      end;
	    pionEntoureCasePourEffacerCoupEnTete:
        begin
          if gCouleurOthellier.estUneImage
	          then
	            begin
	              a := GetValeurDessinEnTraceDeRayon(square);
	              if a <> pionEntoureCasePourEffacerCoupEnTete then
	                begin
	                  InvalidateDessinEnTraceDeRayon(square);
	                  DessinePion2D(square,a);
	                end;
	            end
	          else
	            begin
				        InsetRect(rectangle,-1,-1);
				        PenPat(gCouleurOthellier.whichPattern);
			          PenSize(1,1);
			          ForeColor(gCouleurOthellier.couleurFront);
			          BackColor(gCouleurOthellier.couleurBack);
			          RGBForeColor(gCouleurOthellier.RGB);
			          {FrameRect(rectangle);} {c'est ancienne methode}
			          with rectangle do       {c'est la nouvelle mthode}
				          begin
				            dec(right);
				            dec(bottom);
				            for j := 0 to 1 do
				              begin
				                i := (GetTailleCaseCourante div 20);
				                if i > 4 then i := 4;
				                if j = 0 then a := 4+i else
				                if j = 1 then a := i;
				                if a < 1 then a := 1;
				                if (j = 0) and (a > 8) then a := 8;
				                if (j = 1) and (a > 4) then a := 4;
				                Moveto(left+j,top+a);
				                Lineto(left+j,top+j);
				                Lineto(left+a,top+j);
				                Moveto(right-j,top+a);
						            Lineto(right-j,top+j);
						            Lineto(right-a,top+j);
						            Moveto(left+j,bottom-a);
						            Lineto(left+j,bottom-j);
						            Lineto(left+a,bottom-j);
						            Moveto(right-j,bottom-a);
						            Lineto(right-j,bottom-j);
						            Lineto(right-a,bottom-j);
						          end;
						      end;
			          ForeColor(BlackColor);
			          BackColor(WhiteColor);
			          PenNormal;
			          PenPat(blackPattern);
				        SetOthellierEstSale(square,true);
				        DessineAnglesCarreCentral;
				      end;
	      end;*)
   end;

end;



procedure ApprendPolygonePionDelta(r : rect);
var EchelleRect : rect;
    p1,p2,p3 : Point;
begin

  SetRect(EchelleRect,-11000,-11500,11000,10500);
  SetPt(p1,    0, -10000);   { p1 := (   0.0 ,  1.0 ) , et le signe est change a cause de QuickDraw}
  SetPt(p2, 8660,   5000);   { p2 := (  sqrt3/2 , -0.5 ) }
  SetPt(p3,-8600,   5000);   { p3 := ( -sqrt3/2 , -0.5 ) }

  InsetRect(r,1,1);
  with r do
    begin
      right := right-1;
      bottom := bottom-1;

      MapPt(p1,EchelleRect,r);
      MapPt(p2,EchelleRect,r);
      MapPt(p3,EchelleRect,r);

      Moveto(p1.h,p1.v);
      Lineto(p2.h,p2.v);
      Lineto(p3.h,p3.v);
      Lineto(p1.h,p1.v);
      {
      Moveto((left+right) div 2,top);
      Lineto(right,bottom);
      Lineto(left,bottom);
      Lineto((left+right) div 2,top);
      }
    end;
end;

procedure ApprendPolygonePionLosange(r : rect);
begin
  InsetRect(r,1,1);
  with r do
    begin
      right := right-1;
      bottom := bottom-1;
      Moveto(left,(top+bottom) div 2);
      Lineto((left+right) div 2,top);
      Lineto(right,(top+bottom) div 2);
      Lineto((left+right) div 2,bottom);
      Lineto(left,(top+bottom) div 2);
    end;
end;

procedure ApprendPolygonePionCarre(r : rect);
var aux : SInt16;
begin
  with r do
    begin
      right := right-1;
      bottom := bottom-1;
      aux := (right-left) div 4;
      InsetRect(r,aux,aux);
      Moveto(left,top);
      Lineto(right,top);
      Lineto(right,bottom);
      Lineto(left,bottom);
      Lineto(left,top);
    end;
end;


procedure ApprendPolygoneEtoile(r : rect);
var EchelleRect : rect;
    p1,p2,p3,p4,p5 : Point;
begin

  SetRect(EchelleRect,-11000,-11500,11000,10500);
  SetPt(p1,    0, -10500);   { p1 := (   0.0 ,  1.0 ) , et le signe est change a cause de QuickDraw}
  SetPt(p2, 6660,   8000);
  SetPt(p3,-9600,  -3500);
  SetPt(p4, 9600,  -3500);
  SetPt(p5,-6660,   8000);

  InsetRect(r,1,1);
  with r do
    begin
      right := right-1;
      bottom := bottom-1;

      MapPt(p1,EchelleRect,r);
      MapPt(p2,EchelleRect,r);
      MapPt(p3,EchelleRect,r);
      MapPt(p4,EchelleRect,r);
      MapPt(p5,EchelleRect,r);

      Moveto(p1.h,p1.v);
      Lineto(p2.h,p2.v);
      Lineto(p3.h,p3.v);
      Lineto(p4.h,p4.v);
      Lineto(p5.h,p5.v);
      Lineto(p1.h,p1.v);
    end;
end;

function CalculateRectOfPetitPion(r : rect) : rect;
var aux : SInt16;
begin
  with r do
    begin
      aux := (right-left) div 3;
      InsetRect(r,aux,aux);
    end;
  CalculateRectOfPetitPion := r;
end;

function CalculateRectOfPionCroix(r : rect) : rect;
var aux : SInt16;
begin
 with r do
    begin
      dec(right);
      dec(bottom);
      aux := (3*(right-left)) div 20;  {Ì2/2 = 0.707}
      InsetRect(r,aux+1,aux+1);
    end;
  CalculateRectOfPionCroix := r;
end;



procedure DessinePionSpecial(rectangle2D,dest : rect; quelleCase,valeurPion : SInt16; texte : String255; use3D : boolean);
var myPoly : PolyHandle;
    myRect : rect;
    oldClipRgn,uneRgn : RgnHandle;
    square : String255;

    procedure ClipToViewArea(x : SInt16);
     {x est la case ou on veut Dessiner}
    var r : rect;
    begin
      oldclipRgn := NewRgn;
      uneRgn := NewRgn;
      GetClip(oldClipRgn);
      r := QDGetPortBound;
      OpenRgn;
      FrameRect(r);
      if (platDiv10[x] <= 7) then
        if (GetCouleurOfSquareDansJeuCourant(x+10) <> pionVide) then
          FrameOval(GetRect3DDessus(x+10));
      CloseRgn(uneRgn);
      SetClip(uneRgn);
    end;

  procedure DeClipToViewArea;
        (******  toujours faire aller avec ClipToViewArea   ****)
    begin
      SetClip(oldClipRgn);
      DisposeRgn(oldclipRgn);
      DisposeRgn(uneRgn);
    end;

begin
  myPoly := NIL;
  myPoly := OpenPoly;
  case  valeurPion of
    PionDeltaTraitsBlancs,PionDeltaTraitsNoirs,
    PionDeltaNoir,PionDeltaBlanc                             : ApprendPolygonePionDelta(rectangle2D);
    PionLosangeTraitsBlancs,PionLosangeTraitsNoirs,
    PionLosangeNoir,PionLosangeBlanc                         : ApprendPolygonePionLosange(rectangle2D);
    PionCarreTraitsBlancs,PionCarreTraitsNoirs,
    PionCarreNoir,PionCarreBlanc                             : ApprendPolygonePionCarre(rectangle2D);
    PionPetitCercleTraitsBlancs,PionPetitCercleTraitsNoirs,
    PionPetitCercleNoir,PionPetitCercleBlanc                 : begin
                                                                 myRect := CalculateRectOfPetitPion(rectangle2D);
                                                                 MapRect(myRect,rectangle2D,dest);
                                                               end;
    PionEtoile                                               : ApprendPolygoneEtoile(rectangle2D);
    PionLabel                                                : begin
                                                                 myRect := rectangle2D;
                                                                 MapRect(myRect,rectangle2D,dest);
                                                               end;
    PionCroixTraitsBlancs,PionCroixTraitsNoirs               : begin
                                                                 myRect := CalculateRectOfPionCroix(rectangle2D);
                                                                 MapRect(myRect,rectangle2D,dest);
                                                               end;
  end;
  ClosePoly;
  MapPoly(myPoly,rectangle2D,dest);


  PenNormal;
  PenSize(1,1);
  if use3D then ClipToViewArea(quelleCase);

  square := ' ' + CoupEnStringEnMajuscules(quelleCase) + ' ';

  case valeurPion of
    PionDeltaBlanc   :
      begin
        PrintForEPSFile(square + 'white_delta');
        FillPoly(myPoly,whitePattern);
        FramePoly(myPoly);
      end;
    PionDeltaNoir    :
      begin
        PrintForEPSFile(square + 'solid_delta');
        FillPoly(myPoly,blackPattern);
        FramePoly(myPoly);
      end;
    PionDeltaTraitsBlancs    :
      begin
        PrintForEPSFile(' 1 setgray');
        PrintForEPSFile(square + 'hollow_delta');
        PrintForEPSFile(' 0 setgray');
        PenPat(whitePattern);
        FramePoly(myPoly);
      end;
    PionDeltaTraitsNoirs    :
      begin
        PrintForEPSFile(square + 'hollow_delta');
        PenPat(blackPattern);
        FramePoly(myPoly);
      end;
    PionLosangeBlanc :
      begin
        PrintForEPSFile(square + 'white_diamond');
        FillPoly(myPoly,whitePattern);
        FramePoly(myPoly);
      end;
    PionLosangeNoir  :
      begin
        PrintForEPSFile(square + 'solid_diamond');
        FillPoly(myPoly,blackPattern);
        FramePoly(myPoly);
      end;
    PionLosangeTraitsBlancs  :
      begin
        PrintForEPSFile(' 1 setgray');
        PrintForEPSFile(square + 'hollow_diamond');
        PrintForEPSFile(' 0 setgray');
        PenPat(whitePattern);
        FramePoly(myPoly);
      end;
    PionLosangeTraitsNoirs  :
      begin
        PrintForEPSFile(square + 'hollow_diamond');
        PenPat(blackPattern);
        FramePoly(myPoly);
      end;
    PionCarreBlanc   :
      begin
        PrintForEPSFile(square + 'white_square');
        FillPoly(myPoly,whitePattern);
        FramePoly(myPoly);
      end;
    PionCarreNoir    :
      begin
        PrintForEPSFile(square + 'solid_square');
        FillPoly(myPoly,blackPattern);
        FramePoly(myPoly);
      end;
    PionCarreTraitsBlancs    :
      begin
        PrintForEPSFile(' 1 setgray');
        PrintForEPSFile(square + 'hollow_square');
        PrintForEPSFile(' 0 setgray');
        PenPat(whitePattern);
        FramePoly(myPoly);
      end;
    PionCarreTraitsNoirs    :
      begin
        PrintForEPSFile(square + 'hollow_square');
        PenPat(blackPattern);
        FramePoly(myPoly);
      end;
    PionEtoile       :
      with myRect do
        begin
          TextFace(bold);
          TextMode(3);
          if GetCouleurOfSquareDansJeuCourant(quelleCase) = pionNoir
            then
              begin
                PrintForEPSFile(square + 'white_star');
                FillPoly(myPoly,whitePattern);
                FramePoly(myPoly);
                // DessineStringInRect(myRect,pionBlanc,s,quelleCase);
              end
            else
              begin
                if GetCouleurOfSquareDansJeuCourant(quelleCase) = pionBlanc
                  then
                    begin
                      PrintForEPSFile(square + 'solid_star');
                      FillPoly(myPoly,blackPattern);
                      FramePoly(myPoly);
                    end
                  else
                    begin
                      PrintForEPSFile(square + 'hollow_star');
                      FillPoly(myPoly,whitePattern);
                      PenPat(blackPattern);
                      FramePoly(myPoly);
                    end;
                // DessineStringInRect(myRect,pionNoir,s,quelleCase);
              end;
          TextMode(srcOr);
          TextFace(normal);
          ForeColor(BlackColor);
          BackColor(WhiteColor);
        end;
    PionLabel :
      with myRect do
        begin
          TextFace(bold);
          TextMode(3);
          if GetCouleurOfSquareDansJeuCourant(quelleCase) = pionNoir
            then
              begin
                PrintForEPSFile( ' (' + texte + ') ' + square + 'black_move');
                DessineStringInRect(myRect,pionBlanc,texte,quelleCase);
              end
            else
              begin
                if GetCouleurOfSquareDansJeuCourant(quelleCase) = pionBlanc
                  then
                    begin
                      PrintForEPSFile( ' (' + texte + ') ' + square + 'white_move');
                      DessineStringInRect(myRect,pionNoir,texte,quelleCase);
                    end
                  else
                    begin
                      PrintForEPSFile( ' (' + texte + ') ' + square + 'move_number');
                      DessineStringInRect(myRect,pionNoir,texte,quelleCase);
                    end;
              end;
          TextMode(srcOr);
          TextFace(normal);
          ForeColor(BlackColor);
          BackColor(WhiteColor);
        end;
    PionCroixTraitsNoirs :
      with myRect do
        begin
          PrintForEPSFile(square + 'cross');
          PenPat(blackPattern);
          Moveto(left,top);
          Lineto(right,bottom);
          Moveto(left,bottom);
          Lineto(right,top);
        end;
    PionCroixTraitsBlancs :
      with myRect do
        begin
          PrintForEPSFile(' 1 setgray');
          PrintForEPSFile(square + 'cross');
          PrintForEPSFile(' 0 setgray');
          PenPat(whitePattern);
          Moveto(left,top);
          Lineto(right,bottom);
          Moveto(left,bottom);
          Lineto(right,top);
        end;
    PionPetitCercleBlanc :
      begin
        PrintForEPSFile(square + 'white_small_circle');
        PrintForEPSFile(square + 'hollow_small_circle');
        FillOval(myRect,whitePattern);
        FrameOval(myRect);
      end;
     PionPetitCercleNoir :
      begin
        PrintForEPSFile(square + 'black_small_circle');
        FillOval(myRect,blackPattern);
        FrameOval(myRect);
      end;
    PionPetitCercleTraitsBlancs :
      begin
        PrintForEPSFile(' 1 setgray');
        PrintForEPSFile(square + 'hollow_small_circle');
        PrintForEPSFile(' 0 setgray');
        PenPat(whitePattern);
        FrameOval(myRect);
      end;
    PionPetitCercleTraitsNoirs :
      begin
        PrintForEPSFile(square + 'hollow_small_circle');
        PenPat(blackPattern);
        FrameOval(myRect);
      end;
  end;

  if use3D then DeClipToViewArea;

  KillPoly(myPoly);
  myPoly := NIL;

  PenNormal;
end;


procedure DrawJustifiedStringInRect(whichRect : rect; couleurDesLettres : SInt16; var s : String255; justification : SInt32; whichSquare : SInt16);
var a,b,haut,largeur : SInt32;
    InfosPolice: fontinfo;
    smallRect : rect;
begin

  if (s = '') then exit(DrawJustifiedStringInRect);

  inc(gNiveauDeRecursionDansDrawJustifiedStringInRect);

  GetFontInfo(InfosPolice);
	with InfosPolice do
		haut := ascent + {descent +} leading;

  (*
  WritelnDansRapport('');
	WritelnDansRapport('entree dans DrawJustifiedStringInRect ( s = ' + s + ' )');
  *)

  if couleurDesLettres = pionNoir  then TextMode(srcOr) else
	if couleurDesLettres = pionBlanc then TextMode(srcBic)
		else TextMode(srcXor);


	 with whichRect do
     begin

       largeur := MyStringWidth(s);

      // WritelnNumDansRapport('haut = ',haut);
      // WritelnNumDansRapport('largeur = ',largeur);

      // WritelnNumDansRapport('bottom = ',bottom);
      // WritelnNumDansRapport('top = ',top);

       {defaut = on centre}
       a := (left + right - largeur) div 2;
       b := (bottom + top + haut) div 2 ;


      // WritelnNumDansRapport('a = ',a);
      // WritelnNumDansRapport('b = ',b);

       {justification horizontale}
       if (justification and kJusticationCentreHori) <> 0 then a := ((left + right - largeur) div 2) else
       if (justification and kJusticationGauche) <> 0     then a := (left) else
       if (justification and kJusticationDroite) <> 0     then a := (right - largeur);
       {justification verticale}
       if (justification and kJusticationCentreVert) <> 0 then b := (-1 + (bottom + top + haut) div 2) else
       if (justification and kJusticationBas) <> 0        then b := (bottom - 1) else
       if (justification and kJusticationHaut) <> 0       then b := (top + haut + 1);

       if ((justification and kJusticationCentreHori) <> 0) and IsDigit(s[1])
         then inc(a);

       smallRect := MakeRect(a, b - haut -1, a + largeur, b);

      // WritelnNumDansRapport('smallRect.bottom = ',smallRect.bottom);

       if gCassioUseQuartzAntialiasing and doitEffacerSousLesTextesSurOthellier then
         begin
           doitEffacerSousLesTextesSurOthellier := (gNiveauDeRecursionDansDrawJustifiedStringInRect < 10);
           RedessinerRectDansSquare(whichSquare,smallRect);
           doitEffacerSousLesTextesSurOthellier := true;
         end;

       if (justification and kJustificationInverseVideo) <> 0 then
         begin
           OffSetRect(smallRect,0,(InfosPolice.descent+InfosPolice.leading) div 2);
           {InsetRect(smallRect,1,0);}
           InvertRect(smallRect);
         end;

       Moveto(a,b);
       MyDrawString(s);

       // FrameRect(whichRect);

        (*
	    	WritelnDansRapport('sortie de DrawJustifiedStringInRect');
		    WritelnDansRapport('');
		    *)

     end;

  dec(gNiveauDeRecursionDansDrawJustifiedStringInRect);
end;


procedure DrawJustifiedStringInRectWithRGBColor(whichRect : rect; var s : String255; justification : SInt32; whichSquare : SInt16; color : RGBColor);
begin
  RGBForeColor(color);
  RGBBackColor(color);
  DrawJustifiedStringInRect(whichRect,pionNoir,s,justification,whichSquare);
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;


procedure DessineStringInRect(whichRect : rect; couleurDesLettres : SInt16; var s : String255; whichSquare : SInt16);
var haut : SInt32;
begin


  if (s = '') then exit(DessineStringInRect);

  if ((whichRect.bottom - whichRect.top) <= 15)
     then
       begin
         haut := 9;
         TextFont(MonacoID);
         TextSize(haut);
         TextFace(normal);
       end
     else
       begin
         if ((whichRect.bottom - whichRect.top) <= 25)
           then haut := gPoliceNumeroCoup.petiteTaille
           else haut := gPoliceNumeroCoup.grandeTaille;
         TextSize(haut);
         TextFont(gPoliceNumeroCoup.policeID);
         TextFace(gPoliceNumeroCoup.theStyle);
       end;

	    (*
		  case couleurDesLettres of
		    pionBlanc : WritelnDansRapport(' "'+s+'" blanc en'+CoupEnStringEnMajuscules(whichsquare))
		    pionNoir  : WritelnDansRapport(' "'+s+'" noir en'+CoupEnStringEnMajuscules(whichsquare))
		    otherwise   WritelnDansRapport(' "'+s+'" (couleur = '+NumEnString(couleurDesLettres)+') en'+CoupEnStringEnMajuscules(whichsquare))
		  end;
	    *)

	 DrawJustifiedStringInRect(whichRect,couleurDesLettres,s,kJusticationCentreVert+kJusticationCentreHori,whichSquare);

end;

procedure DessineStringOnSquare(whichSquare,couleurDesLettres : SInt16; var s : String255; var continuer : boolean);
var myRect, r1, r2 : rect;
    oldPort : grafPtr;
begin
  {$UNUSED continuer}


  if (s = '') then exit(DessineStringOnSquare);

  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

		  if not(CassioEstEn3D)
		    then
		      myRect := GetRectOfSquare2DDansAireDeJeu(whichSquare,0)
		    else
		      begin
		        if (GetCouleurOfSquareDansJeuCourant(whichSquare) <> pionVide) then
		          begin
		            // haut d'un pion dans une case remplie
		            myRect := GetRectAreteVisiblePion3DPourPionDelta(whichSquare,0);
		          end
		        else
		        if  (AttenteAnalyseDeFinaleDansPositionCourante and (whichSquare = GetBestMoveAttenteAnalyseDeFinale) and
		            (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse or SuggestionAnalyseDeFinaleEstDessinee))

		           or (not(AttenteAnalyseDeFinaleDansPositionCourante and (whichSquare <> GetBestMoveAttenteAnalyseDeFinale))
		             and (gDoitJouerMeilleureReponse or afficheSuggestionDeCassio) and (whichSquare = meilleurCoupHum)) then
                begin

                  // les pions dores font a peu pres une demi-epaiasseur, donc on fait
                  // une moyenne entre le bas et le haut des pions normaux
		              r1 := GetRectAreteVisiblePion3DPourPionDelta(whichSquare,0);
		              r2 := GetRectPionDessous3DPourPionDelta(whichSquare,0);

		              myRect := MakeRect((r1.left + r2.left) div 2,
		                                 (r1.top + r2.top) div 2,
		                                 (r1.right + r2.right) div 2,
		                                 (r1.bottom + r2.bottom) div 2);
		            end
		        else
		          begin
		            // bas d'un pion dans une case vide
		            myRect := GetRectPionDessous3DPourPionDelta(whichSquare,0);
		          end;

		        OffSetRect(myRect,0,-1);
		      end;


		  // WritelnNumDansRapport('myRect.bottom = ',myRect.bottom);
		  // WritelnDansRapport('s = '+s);

		  DessineStringInRect(myRect,couleurDesLettres,s,whichSquare);
		  InvalidateDessinEnTraceDeRayon(whichSquare);
		  SetOthellierEstSale(whichSquare,true);

      SetPort(oldPort);
    end;
end;


procedure DessineLettreBlancheOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
var s : String255;
begin
  s := chr(codeAsciiDeLaLettre);
  DessineStringOnSquare(whichSquare,pionBlanc,s,continuer);
  codeAsciiDeLaLettre := succ(codeAsciiDeLaLettre);
end;

procedure DessineLettreNoireOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
var s : String255;
begin
  s := chr(codeAsciiDeLaLettre);
  DessineStringOnSquare(whichSquare,pionNoir,s,continuer);
  codeAsciiDeLaLettre := succ(codeAsciiDeLaLettre);
end;

procedure DessineLettreOnSquare(var whichSquare : SInt16; var codeAsciiDeLaLettre : SInt32; var continuer : boolean);
begin
  DessineLettreNoireOnSquare(whichSquare,codeAsciiDeLaLettre,continuer);
end;


procedure DessinePion(square,valeurPion : SInt16);
begin
 if CassioEstEn3D
   then
     begin
       if EnVieille3D
         then WritelnDansRapport('pas d''appel a DessinePion3D dans DessinePion('+CoupEnString(square,true)+','+NumEnString(valeurPion)+')')
         else DessinePion3D(square,valeurPion);
     end
   else DessinePion2D(square,valeurPion);
end;

procedure DessineAnglesCarreCentral;
var x,y : SInt16;
    unRect : rect;
    oldPort : grafPtr;
begin
  if CassioEstEn3D then
    exit(DessineAnglesCarreCentral);

  if gCouleurOthellier.estUneImage then
    exit(DessineAnglesCarreCentral);


  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      if retirerEffet3DSubtilOthellier2D
        then ForeColor(BlackColor)
        else RGBForeColor(NoircirCouleur(gCouleurOthellier.RGB));

      x := aireDeJeu.left+2*GetTailleCaseCourante;
      y := aireDeJeu.top+2*GetTailleCaseCourante;
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      x := x+4*GetTailleCaseCourante;
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      y := y+4*GetTailleCaseCourante;
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);
      x := x-4*GetTailleCaseCourante;
      SetRect(unRect,x-1,y-1,x+2,y+2);
      FillOval(unRect,blackPattern);

      ForeColor(BlackColor);
      SetPort(oldPort);
    end;
end;

procedure EffacerSquare(var whichSquare : SInt16; var continuer : boolean);
begin
  {$UNUSED continuer}
  if CassioEstEn3D and not(enRetour)
    then DessinePion3D(whichSquare,effaceCase)
    else DessinePion2D(whichSquare,pionVide);
  {WritelnStringAndCoupDansRapport('EffacerSquare : ',whichsquare);}
end;



function GetNombreAppelsRecursifsRedessinerRectDansSquare(whichSquare : SInt16; whichRect : rect) : SInt32;
var k, compteur : SInt32;
begin
  compteur := 0;

  with gPileDesRectanglesRecursifsARedessiner do
    begin
      for k := 1 to cardinal do
        if (pile[k].square = whichSquare) and (SameRect(pile[k].theRect, whichRect))
          then inc(compteur);
    end;

  GetNombreAppelsRecursifsRedessinerRectDansSquare := compteur;
end;


function AddDansPileParametresRecursifsRectDansSquare(whichSquare : SInt16; whichRect : rect) : SInt32;
var index : SInt32;
begin
  index := -1;

  with gPileDesRectanglesRecursifsARedessiner do
    begin
      if (cardinal < 100) then
        begin
          inc(cardinal);
          index := cardinal;

          pile[cardinal].square  := whichSquare;
          pile[cardinal].theRect := whichRect;
        end;
    end;

  AddDansPileParametresRecursifsRectDansSquare := index;
end;


procedure RemoveDansPileParametresRecursifsRectDansSquare(index : SInt32; whichSquare : SInt16; whichRect : rect);
begin
  Discard2(whichSquare, whichRect);

  if (index >= 1) and (index <= 100) then
    with gPileDesRectanglesRecursifsARedessiner do
      begin
        with pile[index] do
          begin
            square := -1;
            theRect := MakeRect(-1,-1,-1,-1);
          end;

        if (index = cardinal) and (cardinal >= 1)
          then dec(cardinal)
          else WritelnDansRapport('ASSERT : pile des appels recursifs fausse dans RemoveDansPileParametresRecursifsRectDansSquare !!');
      end;
end;


procedure RedessinerRectDansSquare(whichSquare : SInt16; whichRect : rect);
var valeurCase : SInt16;
    oldClipRgn : RgnHandle;
    oldPort : grafPtr;
    tempoAffichageProprietesOfCurrentNode : UInt32;
    tempoAfficheNumeroCoup : boolean;
    valeurZebra : SInt32;
    oldTextFont,oldTextMode,oldTextSize : SInt16;
    oldTextFace : ByteParameter;
    nbAppelsRecursifs, index : SInt32;
begin
  index := -1;

  if (whichSquare >= 11) and (whichSquare <= 88) and
     (gPileDesRectanglesRecursifsARedessiner.nbAppelsRecursifs < 150) and not(quitter) then
    begin

      (*
      WritelnNumDansRapport('entree dans RedessinerRectDansSquare : ',gPileDesRectanglesRecursifsARedessiner.nbAppelsRecursifs);
      WritelnNumDansRapport('  square : ',whichSquare);
      Wait(0.05);
      *)

      inc(gPileDesRectanglesRecursifsARedessiner.nbAppelsRecursifs);


      nbAppelsRecursifs := GetNombreAppelsRecursifsRedessinerRectDansSquare(whichSquare, whichRect);

      (* WritelnNumDansRapport('  recur : ',nbAppelsRecursifs); *)

      if (nbAppelsRecursifs <= 0) then
        begin

          index := AddDansPileParametresRecursifsRectDansSquare(whichSquare, whichRect);

          (* WritelnNumDansRapport('  index : ',index); *)

    		  GetPort(oldPort);
    		  SetPortByWindow(wPlateauPtr);

    		  oldTextFont := GetPortTextFont(GetWindowPort(wPlateauPtr));
    		  oldTextFace := GetPortTextFace(GetWindowPort(wPlateauPtr));
    		  oldTextMode := GetPortTextMode(GetWindowPort(wPlateauPtr));
    		  oldTextSize := GetPortTextSize(GetWindowPort(wPlateauPtr));


    		  oldclipRgn := NewRgn;
    		  GetClip(oldClipRgn);
    		  ClipRect(whichRect);

    		  valeurCase := GetValeurDessinEnTraceDeRayon(whichSquare);

    		  tempoAffichageProprietesOfCurrentNode := GetAffichageProprietesOfCurrentNode;
    		  tempoAfficheNumeroCoup := afficheNumeroCoup;

    		  SetAffichageProprietesOfCurrentNode(kAideDebutant + kPierresDeltas + kBibliotheque);
    		  afficheNumeroCoup := false;

    		  DessinePion(whichSquare,valeurCase);

    		  if ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier) then
    		    begin
    		      valeurZebra := GetNoteSurCase(kNotesDeZebra,whichSquare);
    		      if EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeurZebra) then
    		        begin
    		          DessineCouleurDeZebraBookDansRect(whichRect,AQuiDeJouer,valeurZebra,false);

    		          (*
    		          WriteStringAndCoupDansRapport('dans RedessinerRectDansSquare : ', whichSquare);
    		          if (AQuiDeJouer = pionNoir)
                    then WritelnNumDansRapport(' : trait = noir, valeur = ',valeurZebra)
                    else WritelnNumDansRapport(' : trait = blanc, valeur = ',valeurZebra);
                  *)

    		        end;
    		    end;

    		  AfficheProprietesOfCurrentNode(false,[whichSquare],'RedessinerRectDansSquare');

    		  SetAffichageProprietesOfCurrentNode(tempoAffichageProprietesOfCurrentNode);
    		  afficheNumeroCoup := tempoAfficheNumeroCoup;

    		  SetClip(oldClipRgn);
    		  DisposeRgn(oldclipRgn);

    		  TextFont(oldTextFont);
    		  TextMode(oldTextMode);
    		  TextSize(oldTextSize);
    		  TextFace(StyleParameter(oldTextFace));

    		  SetPort(oldPort);
    		
    		
    		
    		  RemoveDansPileParametresRecursifsRectDansSquare(index, whichSquare, whichRect);
    		
    		end;
		
		
		  dec(gPileDesRectanglesRecursifsARedessiner.nbAppelsRecursifs);
		
		
		  (*
		  WritelnDansRapport('sortie de RedessinerRectDansSquare');
		  Wait(0.05);
		  *)
		end;
end;


procedure SetPositionPlateau2D(nbrecases,tailleCase : SInt16; HG_h,HG_v : SInt16; fonctionAppelante : String255);
begin  {$UNUSED fonctionAppelante}
  SetRect(aireDeJeu,HG_h,HG_v,HG_h+1+nbrecases*tailleCase,HG_v+1+nbrecases*tailleCase);
end;



procedure DessineSystemeCoordonnees;
var d,a,HG_h,HG_v,i : SInt16;
begin
  if enSetUp or not((genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) or CassioEstEn3D) then
    begin

      DessineBordureDuPlateau2D(kBordureDeGauche + kBordureDeDroite + kBordureDuHaut + kBordureDuBas);
      d := -GetTailleCaseCourante div 2;
      HG_h := aireDeJeu.left;
      HG_v := aireDeJeu.top-2;

      if BordureOthellierEstUneTexture
        then a := HG_h - 11
        else a := HG_h - 10;

      if avecSystemeCoordonnees then
        begin
          PrepareTexteStatePourSystemeCoordonnees;
          FOR i := 1 TO 8 do
            begin
              d := d+GetTailleCaseCourante;

              Moveto(HG_h+d-2,HG_v-1);
              if CassioUtiliseDesMajuscules
                then MyDrawString(chr(64+i))
                else MyDrawString(chr(96+i));

              Moveto(a,HG_v+d+5);
              MyDrawString(chr(48+i));
            end;

          if gCassioUseQuartzAntialiasing then
            if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
        end;

      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);

    end;
end;



procedure DessinePlateau2D(cases,tailleCase : SInt16; HG_h,HG_v : SInt16; avecDessinFondNoir : boolean);
var i,d : SInt16;
    x,y : SInt16;
    unRect : rect;
    couleurOthellierFoncee : RGBColor;
    couleurOthellierClaire : RGBColor;
begin
  if wPlateauPtr <> NIL then
    begin
      PenPat(blackPattern);
      unRect := GetWindowPortRect(wPlateauPtr);

      x := HG_h+1+cases*tailleCase;
			y := HG_v+1+cases*tailleCase;
			SetPositionPlateau2D(cases,tailleCase,HG_h,HG_v,'DessinePlateau2D');

      if avecDessinFondNoir then EffaceTouteLaFenetreSaufLOthellier;

      if gCouleurOthellier.estUneImage then
        begin
          for x := 1 to 8 do
            for y := 1 to 8 do
              DessinePion2D(x*10+y,pionVide);
        end
        else
	        begin

			      ForeColor(gCouleurOthellier.couleurFront);
			      BackColor(gCouleurOthellier.couleurBack);
			      RGBForeColor(gCouleurOthellier.RGB);

			      couleurOthellierClaire := EclaircirCouleur(gCouleurOthellier.RGB);
			      couleurOthellierFoncee := NoircirCouleur(gCouleurOthellier.RGB);


			      DetermineOthellierPatSelonCouleur(gCouleurOthellier.menuCmd,gCouleurOthellier.whichPattern);
			      FillRect(aireDeJeu,gCouleurOthellier.whichPattern);
			      ForeColor(BlackColor);
			      BackColor(WhiteColor);
			      {ForeColor(WhiteColor);
			      BackColor(WhiteColor);}
			      FrameRect(aireDeJeu);


			      if retirerEffet3DSubtilOthellier2D
			        then
			          begin
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          Moveto(HG_h,HG_v+d);
						          Lineto(x-1,HG_v+d);
						          Moveto(HG_h+d,HG_v);
						          Lineto(HG_h+d,y-1);
						        end;
			          end
			        else
			          begin
			            {on dessine les ombrages}

						      {horizontalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          RGBForeColor(couleurOthellierClaire);
						          Moveto(HG_h+1,HG_v+d+1);
						          Lineto(x-1,HG_v+d+1);
						          d := d+tailleCase;
						        end;

						      {verticalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          RGBForeColor(couleurOthellierClaire);
						          Moveto(HG_h+d+1,HG_v+1);
						          Lineto(HG_h+d+1,y-1);
						          d := d+tailleCase;
						        end;

						      {horizontalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          RGBForeColor(couleurOthellierFoncee);
						          Moveto(HG_h+1,HG_v+d);
						          Lineto(x-1,HG_v+d);
						        end;

						      {verticalement}
						      d := 0;
						      for i := 1 to cases do
						        begin
						          d := d+tailleCase;
						          RGBForeColor(couleurOthellierFoncee);
						          Moveto(HG_h+d,HG_v+1);
						          Lineto(HG_h+d,y-1);
						        end;

						    end;


			      ForeColor(BlackColor);
			      BackColor(WhiteColor);
			      Moveto(HG_h+1,y);
			      Line(cases*tailleCase,0);
			      Line(0,-cases*tailleCase);
			    end;

      if avecSystemeCoordonnees then DessineSystemeCoordonnees;
      DessineAnglesCarreCentral;
   end;
end;


procedure DessinePlateau(avecDessinFondNoir : boolean);
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if CassioEstEn3D
        then DessinePlateau3D(avecDessinFondNoir)
        else DessinePlateau2D(8,GetTailleCaseCourante,aireDeJeu.left,aireDeJeu.top,avecDessinFondNoir);
      SetPort(oldPort);
    end;
end;

procedure DessinePosition(const position : plateauOthello);
var i,t : SInt16;
begin
  for t := 64 downto 1 do
    begin
     i := othellier[t];
     if (position[i] <> pionVide) or gCouleurOthellier.estUneImage then DessinePion(i,position[i]);
    end;
end;

procedure DessinePetitCentre;
var i,t : SInt16;
begin
  for t := 1 to 64 do
    begin
     i := othellier[t];
     DessinePion(i,GetCouleurOfSquareDansJeuCourant(i));
    end;
  for t := 1 to 8 do
    DessinePion(casepetitcentre[t],petitPion);
end;

procedure PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres : SInt16; var hauteur,decalageHor,decalageVert : SInt16);
var currentPort : grafPtr;
    couleurNumeroCoup : RGBColor;
begin
  if (GetTailleCaseCourante <= 20) and not(CassioEstEn3D)
   then
     begin
       hauteur := 9;
       TextSize(hauteur);
       TextFont(CourierID);
       TextFace(normal);
       decalageHor := 1;
       decalageVert := 0;
     end
   else
     begin
       if GetTailleCaseCourante <= 25
         then
           begin
             hauteur := gPoliceNumeroCoup.petiteTaille;
             decalageHor := 1;
             decalageVert := 0;
           end
         else
           begin
             hauteur := gPoliceNumeroCoup.grandeTaille;
             decalageHor := 0;
             decalageVert := -1;
           end;
       TextSize(hauteur);
       TextFont(gPoliceNumeroCoup.policeID);
       TextFace(gPoliceNumeroCoup.theStyle);
     end;

  if not(gIsRunningUnderMacOSX) or ((GetTailleCaseCourante <= 20) and not(CassioEstEn3D))
    then
		  case couleurDesChiffres of
		    pionNoir  : TextMode(srcOr);
		    pionBlanc : TextMode(srcBic);
		    otherwise   TextMode(srcXor);
		  end {case}
		else
		  begin
		    if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
		    case couleurDesChiffres of
			    pionNoir  : couleurNumeroCoup := CouleurCmdToRGBColor(NoirCmd);
			    pionBlanc : couleurNumeroCoup := CouleurCmdToRGBColor(BlancCmd);
			    otherwise   couleurNumeroCoup := CouleurCmdToRGBColor(BlancCmd);
		    end; {case}
		    TextMode(srcOr);
		    RGBForeColor(couleurNumeroCoup);
        RGBBackColor(couleurNumeroCoup);
		    GetPort(currentPort);
		    EnableQuartzAntiAliasingThisPort(currentPort,true);
		  end;
end;


procedure GetPositionCorrecteNumeroDuCoup2D(square : SInt16; var result : Point);
var decalage : Point;
begin
  if (GetTailleCaseCourante <= 25)
    then SetPt(decalage,1,0)
	  else SetPt(decalage,0,-1);
	SetPt(result,aireDeJeu.left+GetTailleCaseCourante*(platMod10[square]-1)+GetTailleCaseCourante div 2+decalage.h,
	             aireDeJeu.top+ GetTailleCaseCourante*(platDiv10[square]-1)+GetTailleCaseCourante div 2+decalage.v);

	if not(retirerEffet3DSubtilOthellier2D or gCouleurOthellier.estUneImage) then
	  begin
	    inc(result.h);
	    inc(result.v);
	  end;

	(* Ajustement fin de la position du numŽro, car les photos de pions ne centrent pas les pions de la meme manire *)
	with gCouleurOthellier do
    if estUneImage then
      begin
        if (Pos('Photographi',nomFichierTexture) > 0)       then result.v := result.v - 1 else
        if (Pos('WZebra',nomFichierTexture) > 0)            then result.v := result.v - 1 else
        if (Pos('Magnetic',nomFichierTexture) > 0)          then result.h := result.h - 1 - (GetTailleCaseCourante div 50) else
        if (Pos('Clementoni',nomFichierTexture) > 0)        then result.h := result.h - 1 else
        if (Pos('Tsukuda magnetic',nomFichierTexture) > 0)  then result.h := result.h + 1 else
        if (Pos('Tsukuda official',nomFichierTexture) > 0)  then result.h := result.h - 1 else
        if (Pos('EuroCents',nomFichierTexture) > 0)         then result.v := result.v - 3 ;
      end;
end;


procedure GetPositionCorrecteNumeroDuCoup(square : SInt16; var result : Point);
begin
  if CassioEstEn3D
    then GetPositionCorrecteNumeroDuCoup3D(square,result)
    else GetPositionCorrecteNumeroDuCoup2D(square,result);
end;



procedure DessineNumeroCoupSurCetteCasePourDiagramme2D(whichSquare,whichNumber,couleurDesChiffres : SInt16);
var s : String255;
    haut,decalageHor,decalageVert : SInt16;
    where : Point;
begin
  PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres,haut,decalageHor,decalageVert);
  GetPositionCorrecteNumeroDuCoup2D(whichSquare,where);
  s := NumEnString(whichNumber);
  Moveto(where.h - MyStringWidth(s) div 2, where.v + haut div 2);
  MyDrawString(s);

  (* Restore the correct front and back color for Copybits *)
  ForeColor(BlackColor);
  BackColor(WhiteColor);

  InvalidateDessinEnTraceDeRayon(whichSquare);
end;

procedure DessineNumeroCoupSurCetteCasePourDiagramme(whichSquare,whichNumber,couleurDesChiffres : SInt16);
begin
  if CassioEstEn3D
    then DessineNumeroCoup(whichSquare,whichNumber,couleurDesChiffres,NIL)
    else DessineNumeroCoupSurCetteCasePourDiagramme2D(whichSquare,whichNumber,couleurDesChiffres);
end;


procedure DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(jusquaQuelCoup : SInt16);
var i,square : SInt16;
    oldPort : grafPtr;
begin
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);

     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;

     for i := 1 to jusquaQuelCoup do
	     begin
	       square := GetNiemeCoupPartieCourante(i);
	       if (square <> coupInconnu) and (square >= 11) and (square <= 88) and
	          (GetCouleurNiemeCoupPartieCourante(i) = GetValeurDessinEnTraceDeRayon(square)) then
				       begin
				         if GetCouleurNiemeCoupPartieCourante(i) = pionNoir
				           then DessineNumeroCoupSurCetteCasePourDiagramme(square,i,pionBlanc)
				           else DessineNumeroCoupSurCetteCasePourDiagramme(square,i,pionNoir);
				       end;
	     end;


     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

     SetPort(oldPort);
   end;
end;

procedure DessineDiagramme(tailleCaseDiagramme : SInt16; clipRegion : RgnHandle; fonctionAppelante : String255);
var i,j,square,aux : SInt16;
    oldPort : grafPtr;
    positionInitiale : plateauOthello;
    theClipRect,unRect : rect;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
    visibleRgn : RgnHandle;
begin
 {$UNUSED fonctionAppelante}
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);

     if clipRegion <> NIL
       then theClipRect := MyGetRegionRect(clipRegion)
       else
         begin
           visibleRgn := NewRgn;
           theClipRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
           DisposeRgn(visibleRgn);
         end;

     {WritelnDansRapport('appel de DessineDiagramme par '+fonctionAppelante);}

     if not(CassioEstEn3D) then EffaceTouteLaFenetreSaufLOthellier;
     InvalidateDessinEnTraceDeRayon(DerniereCaseJouee);

     if CassioEstEn3D then DessinePlateau3D(false);
     if not(gCouleurOthellier.estUneImage)
       then
         begin
           DessinePlateau2D(8,tailleCaseDiagramme,aireDeJeu.left,aireDeJeu.top,true)
         end
       else
         begin
           for i := 1 to 8 do
             for j := 1 to 8 do
               if GetCouleurOfSquareDansJeuCourant(i*10+j) = pionVide then
               begin
                 square := 10*i+j;
                 unRect := GetBoundingRectOfSquare(square);
                 if not(CassioEstEn3D) then ChangeRectOfSquarePourPicture(unRect);
                 if SectRect(unRect,theClipRect,bidRect) then
                   begin
                     if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
                     DessinePion(square,GetCouleurOfSquareDansJeuCourant(square));
                   end;
               end;
           if avecSystemeCoordonnees then DessineSystemeCoordonnees;
         end;



     GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
     for i := 64 downto 1 do
       begin
         square := othellier[i];
         aux := positionInitiale[square];
         if (aux <> pionVide) then
           begin
             unRect := GetBoundingRectOfSquare(square);
             if not(CassioEstEn3D) then ChangeRectOfSquarePourPicture(unRect);
             if SectRect(unRect,theClipRect,bidRect) then
               begin
                 if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
                 DessinePion(square,aux);
               end;
           end;
       end;


     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;

     for i := 1 to nbreCoup do
     begin
       square := GetNiemeCoupPartieCourante(i);
       if square <> coupInconnu then
       if InRange(square,11,88) then
       begin
         unRect := GetBoundingRectOfSquare(square);
         if not(CassioEstEn3D) then ChangeRectOfSquarePourPicture(unRect);
         if SectRect(unRect,theClipRect,bidRect) then
           begin
             if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(square);
             DessinePion(square,GetCouleurNiemeCoupPartieCourante(i));
             DessineNumeroCoupSurCetteCasePourDiagramme(square,i,-GetCouleurNiemeCoupPartieCourante(i));
		       end;
       end;
     end;

     if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

     SetPort(oldPort);
   end;
end;


procedure Faitcalculs2DParDefaut;
  var HG_h,HG_v,x,y,cases : SInt16;
  begin
    HG_h := 20;
    HG_v := 16;
    cases := 8;
    x := HG_h+1+cases*GetTailleCaseCourante;
    y := HG_v+1+cases*GetTailleCaseCourante;
    SetRect(aireDeJeu,HG_h,HG_v,x,y);
  end;





procedure DessineNumeroCoup(square,n,couleurDesChiffres : SInt16; whichNode : GameTree);
var s : String255;
    oldPort : grafPtr;
    haut,decalageHor,decalageVert : SInt16;
    position : Point;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if InRange(square,11,88) then
       begin
         s := NumEnString(n);

         if afficheSignesDiacritiques and (whichNode <> NIL) then
           s := s + GetSignesDiacritiques(whichNode);

         PrepareTextModeAndSizePourDessineDiagramme(couleurDesChiffres,haut,decalageHor,decalageVert);
         GetPositionCorrecteNumeroDuCoup(square,position);
         Moveto(position.h-MyStringWidth(s) div 2,position.v+haut div 2);
         MyDrawString(s);

         (* Restore the correct front and back color for Copybits *)
         ForeColor(BlackColor);
         BackColor(WhiteColor);

         InvalidateDessinEnTraceDeRayon(square);
       end;

      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      SetPort(oldPort);
    end;
end;

procedure EffaceNumeroCoup(square,n : SInt16; whichNode : GameTree);
var s : String255;
    oldPort : grafPtr;
    haut : SInt16;
    position : Point;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(false,9) = NoErr) then DoNothing;

      if InRange(square,11,88) then
       begin
         if not(EnVieille3D)
           then
             begin
               InvalidateDessinEnTraceDeRayon(square);
               DessinePion(square,GetCouleurOfSquareDansJeuCourant(square));
             end
           else
             begin
			         s := NumEnString(n);
			         if afficheSignesDiacritiques and (whichNode <> NIL) then
			           s := s + GetSignesDiacritiques(whichNode);
			         if (GetTailleCaseCourante <= 20) and not(CassioEstEn3D)
			           then
				           begin
				             haut := 9;
				             TextFont(CourierID);
				             TextSize(haut);
				             TextFace(normal);
				           end
				         else
				           begin
				             if GetTailleCaseCourante <= 25
					             then haut := gPoliceNumeroCoup.petiteTaille
					             else haut := gPoliceNumeroCoup.grandeTaille;
					           TextSize(haut);
			               TextFont(gPoliceNumeroCoup.policeID);
			               TextFace(gPoliceNumeroCoup.theStyle);
					         end;
			         SetPortByWindow(wPlateauPtr);
			         GetPositionCorrecteNumeroDuCoup(square,position);
			         Moveto(position.h-MyStringWidth(s) div 2,position.v+haut div 2);
			         if GetCouleurOfSquareDansJeuCourant(square) = pionNoir  then TextMode(srcOr) else
			         if GetCouleurOfSquareDansJeuCourant(square) = pionBlanc then TextMode(srcBic)
			           else TextMode(srcXor);
			         MyDrawString(s);
			       end;
       end;

      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      SetPort(oldPort);
    end;
end;





procedure EcritCommentaireSolitaire;
var s,promptGras : String255;
    lignerect : rect;
    oldPort : grafPtr;
begin
  s := CommentaireSolitaire^^;


  { Quand la bordure de l'othellier est texture, on affichera en gras
    le prompt des solitaires ("Noir joue et gagneƒ", etc.). On parse
    donc la chaine CommentaireSolitaire pour en extraire le prompt }
  if BordureOthellierEstUneTexture
    then ParserCommentaireSolitaire(s,promptGras,s)
    else promptGras := '';

  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      PrepareTexteStatePourCommentaireSolitaire;

      if not(CassioEstEn3D)
        then
          begin
            SetRect(lignerect,posHMeilleureSuite {aireDeJeu.left-5},aireDeJeu.bottom,aireDeJeu.right+400,posVMeilleureSuite);
            if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1);
          end
        else
          SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,299,posVMeilleureSuite+2);
      if not(EnModeEntreeTranscript) then EraseRectDansWindowPlateau(lignerect);
      if avecSystemeCoordonnees and not(CassioEstEn3D) then DessineBordureDuPlateau2D(kBordureDuBas);

      Moveto(lignerect.left+8,lignerect.bottom-2);

      if (promptGras <> '') then  {faut-il ecrire le prompt en gras ?}
        begin
	        TextMode(srcBic);
          TextFace(bold);
          MyDrawString(promptGras);
        end;

      TextFace(normal);
      MyDrawString(s);
      if lignerect.bottom >= GetWindowPortRect(wPlateauPtr).bottom-20 then DessineBoiteDeTaille(wPlateauPtr);


      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      SetPort(oldPort);
    end;
end;

procedure DessineGarnitureAutourOthellierPourEcranStandard;
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  AjusteCurseur;
  AfficheScore;
  EcritPromptFenetreReflexion;
  if afficheMeilleureSuite and not(MeilleureSuiteEffacee) then EcritMeilleureSuite;
  if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
  SetPort(oldPort);
end;


procedure DessineNumeroDernierCoupSurOthellier(surQuellesCases : SquareSet; whichNode : GameTree);
var whichSquare, couleur : SInt32;
begin
  if (nbreCoup > 0) and (nbreCoup <= 64) then
    begin
      whichSquare := DerniereCaseJouee;
      if (whichSquare >= 11) and (whichSquare <= 88) then
        begin
          couleur := GetCouleurOfSquareDansJeuCourant(whichSquare);
          if (whichSquare <> coupInconnu) and (couleur <> pionVide) and (whichSquare in surQuellesCases)
            then DessineNumeroCoup(whichSquare,nbreCoup,-couleur,whichNode);
        end;
    end;
end;

procedure EcranStandard(clipRegion : RgnHandle; forcedErase : boolean);
var oldPort : grafPtr;
    unRect,VisRect,theClipRect : rect;
    positionEffacee : boolean;
    i,j,x,aux : SInt16;
    visibleRgn : RgnHandle;
begin
 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     PrepareTexteStatePourHeure;

     visibleRgn := NewRgn;
     visRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
     DisposeRgn(visibleRgn);

     if clipRegion <> NIL
       then theClipRect := MyGetRegionRect(clipRegion)
       else theClipRect := visRect;

     {if clipRegion = NIL
       then WritelnDansRapport('clipRegion = NIL dans EcranStandard')
       else
         with theClipRect do
           WritelnDansRapport('clipRegion =  '+
                              '(left = '+NumEnString(left)+
                              ', top = '+NumEnString(top)+
                              ', right = '+NumEnString(right)+
                              ', bottom = '+NumEnString(bottom)+')');}


     if not(CassioEstEn3D)
       then
         begin
           if forcedErase or not(gCouleurOthellier.estUneImage)
             then EraseRectDansWindowPlateau(theClipRect)
             else EffaceTouteLaFenetreSaufLOthellier;
           unRect := aireDeJeu;
         end
       else
         if Calculs3DMocheSontFaits
           then
             begin
               MyEraseRect(visrect);
               MyEraseRectWithColor(visRect,BleuPaleCmd,blackPattern,'');
               unRect := GetOthellier3DVistaBuffer;
             end
           else unRect := GetWindowPortRect(wPlateauPtr);
     positionEffacee := SectRect(unRect,visRect,unRect);


     if enSetUp
       then EcranStandardSetUp
       else
         begin
             if not(positionEffacee)
              then
                DessineSystemeCoordonnees
              else
                if CassioEstEn3D then
                   begin
                     DessinePlateau3D(not(Calculs3DMocheSontFaits));
                     Dessine3D(JeuCourant,false);
                   end
                  else
                   begin
                     if not(gCouleurOthellier.estUneImage)
                       then
                         begin
                           DessinePlateau2D(8,GetTailleCaseCourante,aireDeJeu.left,aireDeJeu.top,false);
                           DessinePosition(JeuCourant);
                         end
                       else
                         begin
                           for i := 1 to 8 do
                             for j := 1 to 8 do
                               begin
                                 x := 10*i+j;
                                 unRect := GetRectOfSquare2DDansAireDeJeu(x,0);
                                 ChangeRectOfSquarePourPicture(unRect);
                                 if SectRect(unRect,theClipRect,bidRect) then
                                   begin
                                     aux := GetValeurDessinEnTraceDeRayon(x);
                                     if (GetCouleurOfSquareDansJeuCourant(x) = pionVide) and (clipRegion <> NIL) and
                                        ((aux = pionSuggestionDeCassio) or (aux = pionMontreCoupLegal))
                                          then
                                            begin  {pour ne pas couper le pion bariole ou les coups legaux}
                                              InvalidateDessinEnTraceDeRayon(x);
                                              DessinePion2D(x,aux);
                                            end
                                          else
                                            begin
                                              if clipRegion <> NIL then InvalidateDessinEnTraceDeRayon(x);
                                              DessinePion2D(x,GetCouleurOfSquareDansJeuCourant(x));
                                            end;
                                   end;
                               end;
                           if avecSystemeCoordonnees then DessineSystemeCoordonnees;
                         end;
                   end;

          { SetPositionsTextesWindowPlateau; }

          if positionEffacee and afficheNumeroCoup then DessineNumeroDernierCoupSurOthellier(othellierToutEntier,GetCurrentNode);
          DessineGarnitureAutourOthellierPourEcranStandard;

          if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
          DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'EcranStandard'); {ceci inclut AfficheProprietesOfCurrentNode(false)}

          DessineBoiteDeTaille(wPlateauPtr);
          dernierTick := TickCount;
          Heure(pionNoir);
          Heure(pionBlanc);

          if EnModeEntreeTranscript then EcranStandardTranscript;
        end;

      ValidRect(GetWindowPortRect(wPlateauPtr));


      if not(EnModeEntreeTranscript) then FlushWindow(wPlateauPtr);


      if gCassioUseQuartzAntialiasing then
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      SetPort(oldPort);
    end;
end;

procedure DessineAutresInfosSurCasesAideDebutant(surQuellesCases : SquareSet; fonctionAppelante : String255);
var oldPort : grafPtr;
    coupSuggere : SInt32;
    tempo : UInt32;
begin
  Discard(fonctionAppelante);

  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      (*
      WritelnDansRapport('entree dans DessineAutresInfosSurCasesAideDebutant, fonctionAppelante = '+fonctionAppelante);
      *)

      tempo := GetAffichageProprietesOfCurrentNode;
      if (BAND(GetAffichageProprietesOfCurrentNode,kCommentaires) <> 0) then
        SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode - kCommentaires);
      if (BAND(GetAffichageProprietesOfCurrentNode,kNoeudDansFenetreArbreDeJeu) <> 0) then
        SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode - kNoeudDansFenetreArbreDeJeu);


			if (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse) and
			   (BAND(GetAffichageProprietesOfCurrentNode,kSuggestionDeCassio) <> 0) then
		    begin
		      if AttenteAnalyseDeFinaleDansPositionCourante
		        then coupSuggere := GetBestMoveAttenteAnalyseDeFinale
		        else coupSuggere := meilleurCoupHum;

		      if (coupSuggere in surQuellesCases) then
					  if (coupSuggere >= 11) and (coupSuggere <= 88) then
					    if possiblemove[coupSuggere] {and not(inverseVideo[coupSuggere])} then
					      if CassioEstEn3D
					        then DessinePion3D(coupSuggere,pionSuggestionDeCassio)
					        else DessinePion2D(coupSuggere,pionSuggestionDeCassio);
				end;

		  AfficheProprietesOfCurrentNode(false,surQuellesCases,'DessineAutresInfosSurCasesAideDebutant');

		  if GetAvecAffichageNotesSurCases(kNotesDeCassio) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) <> 0)
		    then DessineNoteSurCases(kNotesDeCassio,surQuellesCases);

		  if GetAvecAffichageNotesSurCases(kNotesDeZebra) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesZebraSurLesCases) <> 0)
		    then DessineNoteSurCases(kNotesDeZebra,surQuellesCases);

			if afficheInfosApprentissage and (BAND(GetAffichageProprietesOfCurrentNode,kInfosApprentissage) <> 0)
			  then EcritLesInfosDApprentissage;

			if DoitAfficherBibliotheque then EcritCoupsBibliotheque(surQuellesCases);

			SetAffichageProprietesOfCurrentNode(tempo);

			(*
			WritelnDansRapport('sortie de DessineAutresInfosSurCasesAideDebutant, fonctionAppelante = '+fonctionAppelante);
			*)

			SetPort(oldPort);
	  end;
end;

procedure DessineAideDebutant(avecDessinAutresInfosSurLesCases : boolean; surQuellesCases : SquareSet);
var i,coupSuggere,whichSquare : SInt16;
    oldPort : grafPtr;
    accumulateur : SquareSet;
begin
  if windowPlateauOpen then
    begin

      {WritelnDansRapport('DessineAideDebutant');}

      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));

      coupSuggere := 0;
      if (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse)  then
        if AttenteAnalyseDeFinaleDansPositionCourante
          then coupSuggere := GetBestMoveAttenteAnalyseDeFinale
          else coupSuggere := meilleurCoupHum;

		  accumulateur := [];

      for i := 1 to 64 do
        begin
          whichSquare := othellier[i];
          if (whichSquare in surQuellesCases) and possibleMove[whichSquare] then
	          begin
	            if (whichSquare <> CoupSuggere) then
			          begin
			            if CassioEstEn3D
			              then DessinePion3D(whichSquare,pionMontreCoupLegal)
			              else DessinePion2D(whichSquare,pionMontreCoupLegal);
			            if (whichSquare = CoupSuggere) then
			              gDoitJouerMeilleureReponse := false;
			          end;
		          inverseVideo[whichSquare] := true;
		          SetOthellierEstSale(whichSquare,true);

		          accumulateur := accumulateur + [whichSquare];
	          end;
        end;

      if avecDessinAutresInfosSurLesCases and (surQuellesCases <> [])
        then DessineAutresInfosSurCasesAideDebutant(surQuellesCases, 'DessineAideDebutant');

      if (BAND(GetAffichageProprietesOfCurrentNode,kAnglesCarreCentral) <> 0)
        then DessineAnglesCarreCentral;

      aideDebutant := true;
      SetPort(oldPort);
    end;
end;

procedure EffaceAideDebutant(avecDessinAutresInfosSurLesCases,effacageLarge : boolean; surQuellesCases : SquareSet; fonctionAppelante : String255);
var i,pionDeffacement,whichSquare,coupSuggere : SInt16;
    oldPort : grafPtr;
    accumulateur : SquareSet;
begin
 Discard(fonctionAppelante);

 if windowPlateauOpen then
   begin
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);

     (*
     WritelnDansRapport('Entree dans EffaceAideDebutant, fonctionAppelante = '+fonctionAppelante);
     WritelnDansRapport(SquareSetEnString(surQuellesCases));
     *)

     effacageLarge := effacageLarge and (GetTailleCaseCourante < 25) and afficheBibl and
                    (phaseDeLaPartie <= phaseMilieu) and (nbreCoup <= LongMaxBibl);
     if CassioEstEn3D
      then pionDeffacement := effaceCase
      else if effacageLarge
            then pionDeffacement := pionEffaceCaseLarge
            else pionDeffacement := pionVide;


     coupSuggere := 0;
     if (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse) then
       if AttenteAnalyseDeFinaleDansPositionCourante
         then coupSuggere := GetBestMoveAttenteAnalyseDeFinale
         else coupSuggere := meilleurCoupHum;

     accumulateur := [];

     for i := 1 to 64 do
       begin
         whichSquare := othellier[i];
	       if (whichSquare in surQuellesCases) and possibleMove[whichSquare] and
	          (GetCouleurOfSquareDansJeuCourant(whichSquare) = pionVide) and GetOthellierEstSale(whichSquare) then
	         begin

	           if (whichSquare = CoupSuggere) and avecDessinAutresInfosSurLesCases
	             then
	               begin
	                 if CassioEstEn3D
				             then DessinePion3D(whichSquare,pionSuggestionDeCassio)
				             else DessinePion2D(whichSquare,pionSuggestionDeCassio);
				           gDoitJouerMeilleureReponse := true;
	               end
	             else
	               begin
	                 if CassioEstEn3D
				             then DessinePion3D(whichSquare,pionDeffacement)
				             else DessinePion2D(whichSquare,pionDeffacement);
	               end;

	           accumulateur := accumulateur + [whichSquare];
	         end;
       end;

     MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
     aideDebutant := false;

     if avecDessinAutresInfosSurLesCases and (accumulateur <> [] ) then
       begin
         DessineAutresInfosSurCasesAideDebutant(accumulateur, 'EffaceAideDebutant');
         DessineAnglesCarreCentral;
       end;

     (*
     WritelnDansRapport('Sortie de EffaceAideDebutant, fonctionAppelante = '+fonctionAppelante);
     *)

     SetPort(oldPort);
   end;
end;


procedure EffaceSuggestionDeCassio;
var tempoSuggestionDeCassio : boolean;
begin
  tempoSuggestionDeCassio := afficheSuggestionDeCassio;
  afficheSuggestionDeCassio := false;
  if aideDebutant
    then DessineAideDebutant(true,othellierToutEntier)
    else EffaceAideDebutant(true,false,othellierToutEntier,'EffaceSuggestionDeCassio');
  afficheSuggestionDeCassio := tempoSuggestionDeCassio;
end;




procedure ActiverSuggestionDeCassio(whichPos : PositionEtTraitRec; bestMove,bestDef : SInt32; fonctionAppelante : String255);
var nbreCasesVides : SInt32;
begin
  nbreCasesVides := NbCasesVidesDansPosition(whichPos.position);

  (*
  if (nbreCasesVides = 6) then
    begin
      WritelnDansRapport('dans ActiverSuggestionDeCassio, fonctionAppelante = '+fonctionAppelante);
      WritelnStringAndCoupDansRapport('dans ActiverSuggestionDeCassio, bestMove = ',bestMove);
    end;
  *)

  if afficheSuggestionDeCassio and SuggestionAnalyseDeFinaleEstDessinee and
    (GetBestMoveAttenteAnalyseDeFinale <> bestMove) and AttenteAnalyseDeFinaleDansPositionCourante then
    begin
      WritelnDansRapport('ASSERT dans ActiverSuggestionDeCassio !! fonctionAppelante = '+fonctionAppelante);

      {WritelnPositionEtTraitDansRapport(whichPos.position,GetTraitOfPosition(whichPos));
      WritelnStringAndCoupDansRapport('bestMove = ',bestMove);
      WritelnStringAndCoupDansRapport('GetBestMoveAttenteAnalyseDeFinale = ',GetBestMoveAttenteAnalyseDeFinale);
      }

      DoChangeAfficheSuggestionDeCassio;
      afficheSuggestionDeCassio := true;
    end;

  ActiverAttenteAnalyseDeFinale(whichPos,bestMove,bestDef,afficheSuggestionDeCassio);
  meilleurCoupHum := bestMove;
  DessineAutresInfosSurCasesAideDebutant([bestMove],'ActiverSuggestionDeCassio');
  gDoitJouerMeilleureReponse := afficheSuggestionDeCassio;
end;


function GetBestSuggestionDeCassio : SInt32;
begin
  if AttenteAnalyseDeFinaleDansPositionCourante
    then GetBestSuggestionDeCassio := GetBestMoveAttenteAnalyseDeFinale
    else GetBestSuggestionDeCassio := meilleurCoupHum;
end;


function CaseContientUnPionDore(whichSquare : SInt32) : boolean;
var result : boolean;
begin

  result := false;

  if (GetValeurDessinEnTraceDeRayon(whichSquare) = pionSuggestionDeCassio) or
     ((BAND(GetAffichageProprietesOfCurrentNode,kSuggestionDeCassio) <> 0) and
      (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse or SuggestionAnalyseDeFinaleEstDessinee) and
      (GetBestSuggestionDeCassio = whichSquare))
    then result := true;

  if result then
  with gCouleurOthellier do
    if estUneImage and
       ((Pos('Pions go',nomFichierTexture) > 0)             or
        (Pos('Tsukuda',nomFichierTexture) > 0)              or
        (Pos('Spear',nomFichierTexture) > 0)                or
        (Pos('Ravensburger',nomFichierTexture) > 0)         or
        (Pos('Magnetic',nomFichierTexture) > 0)             or
        (Pos('EuroCents',nomFichierTexture) > 0)            or
        (Pos('Barnaba',nomFichierTexture) > 0)              or
        (Pos('Clementoni',nomFichierTexture) > 0))
    then result := false;

  CaseContientUnPionDore := result;
end;


function  PtInPlateau2D(loc : Point; var caseCliquee : SInt16) : boolean;
var X,Y : SInt16;
    test : boolean;
    tailleCaseCourante : SInt32;
begin
  test := PtInRect(loc,aireDeJeu);
  tailleCaseCourante := GetTailleCaseCourante;
  X := ((loc.h-aireDeJeu.left) div tailleCaseCourante)+1;
  Y := ((loc.v-aireDeJeu.top) div tailleCaseCourante)+1;
  PtInPlateau2D := test and InRange(X,1,8) and InRange(Y,1,8);
  caseCliquee := X+10*Y;
end;


function  PtInPlateau(loc : Point; var caseCliquee : SInt16) : boolean;
begin
  if CassioEstEn3D
    then PtInPlateau := PtInPlateau3D(loc,caseCliquee)
    else PtInPlateau := PtInPlateau2D(loc,caseCliquee);
end;


procedure EffaceAnnonceFinaleSiNecessaire;
begin
  if HumCtreHum then
    with meilleureSuiteInfos do
      if (statut = ReflAnnonceGagnant) or
         (statut = ReflAnnonceParfait) or
         (statut = ReflTriGagnant) or
         (statut = ReflTriParfait) then
        DetruitMeilleureSuite;
end;




procedure SetOthellierEstSale(square : SInt16; flag : boolean);
begin
  if (square >= 0) and (square <= 99) then othellierEstSale[square] := flag;
end;

function GetOthellierEstSale(square : SInt16) : boolean;
begin
  if (square >= 0) and (square <= 99)
    then GetOthellierEstSale := othellierEstSale[square]
    else GetOthellierEstSale := false;
    {
    GetOthellierEstSale := true;
    }
end;

procedure SetOthellierToutEntierEstSale;
var k : SInt16;
begin
  for k := 11 to 88 do
    SetOthellierEstSale(k,true);
end;





function CalculeTailleCaseParPlateauRect(thePlateauRect : rect) : SInt16;
var tailleTemp : SInt16;
begin
  if not(windowPlateauOpen)
    then tailleTemp := 37
    else
      begin
        tailleTemp := (thePlateauRect.bottom-thePlateauRect.top) div 8;
        if (thePlateauRect.right-thePlateauRect.left) div 8 < tailleTemp then
          tailleTemp := (thePlateauRect.right-thePlateauRect.left) div 8;
      end;
   CalculeTailleCaseParPlateauRect := TailleTemp;
end;



procedure SetAffichageResserre(forceUpdate : boolean);
var rectVoulu,CurrentRect : rect;
begin
 if windowPlateauOpen then
  begin
    SetPortByWindow(wPlateauPtr);
    genreAffichageTextesDansFenetrePlateau := kAffichageSousOthellier;
    {AvecSystemeCoordonnees := false;}
    SetTailleCaseCourante(30);

    SetRect(rectVoulu,-2,39,510,340);
    currentRect := GetWindowPortRect(wPlateauPtr);
    LocalToGlobalRect(currentRect);
    if not(EqualRect(currentRect,rectVoulu)) then
      with rectVoulu do
        begin
          ShowHide(wPlateauPtr,false);
          MoveWindow(wPlateauPtr,left,top,false);
          SizeWindow(wPlateauPtr,right-left,bottom-top,false);
          ShowHide(wPlateauPtr,true);
        end;
    SetPositionPlateau2D(8,GetTailleCaseCourante,0,-1,'SetAffichageResserre');
    SetPositionsTextesWindowPlateau;
    if forceUpdate then
      begin
        NoUpdateWindowPlateau;
        InvalidateAllCasesDessinEnTraceDeRayon;
        EcranStandard(NIL,true);
      end;
  end;
end;



function UpdateRgnTouchePlateau : boolean;
var visRect,unRect : rect;
    visibleRgn : RgnHandle;
begin

  visibleRgn := NewRgn;
  visRect := MyGetRegionRect(GetWindowVisibleRegion(wPlateauPtr,visibleRgn));
  DisposeRgn(visibleRgn);

  unRect := GetOthellierVistaBuffer;
  UpdateRgnTouchePlateau := SectRect(visRect,unRect,visRect);
end;



procedure DessinePourcentage(square,n : SInt16);
var s : String255;
    unRect : rect;
    x,y,a,b : SInt16;
    oldPort : grafPtr;
    larg : SInt16;
begin
 if windowPlateauOpen then
   begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      TextFont(MonacoID);
      if (GetTailleCaseCourante < 28) then TextFont(CourierID);
      TextSize(9);
      TextMode(1);
      s := PourcentageEntierEnString(n)+CharToString('%');
      larg := MyStringWidth(s);
      if CassioEstEn3D
       then
         begin
           unRect := GetRect3DDessous(square);
           with unRect do
            begin
             if right-left > 27 then
               begin
                 x := (right+left) div 2;
                 left := x-13;
                 right := x+14;
               end;
             if bottom-top > 14 then
               begin
                 x := (top+bottom) div 2;
                 top := x-7;
                 bottom := x+7;
               end;
           end;
         end
       else
         begin
          x := platMod10[square];
          y := platDiv10[square];
          a := aireDeJeu.left + 1 + GetTailleCaseCourante*(x-1);
          b := aireDeJeu.top + GetTailleCaseCourante*y- (GetTailleCaseCourante div 2);
          SetRect(unRect,a+3,b-7,a+GetTailleCaseCourante-4,b+7);
          if not(retirerEffet3DSubtilOthellier2D) then
            begin
              unRect.left := unRect.left + 1;
            end;
         end;
      while (unRect.right-unRect.left) < larg+1  do InsetRect(unRect,-1,0);
      while (unRect.right-unRect.left) > larg+10 do InsetRect(unRect,1,0);
      if GetTailleCaseCourante > 15 then
        begin
          FillRect(unRect,whitePattern);
          RGBForeColor(NoircirCouleurDeCetteQuantite(gCouleurOthellier.RGB,10000));
          RGBBackColor(NoircirCouleurDeCetteQuantite(gCouleurOthellier.RGB,10000));
          FrameRect(unRect);
          ForeColor(blackColor);
          BackColor(whiteColor);
        end;
      Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-3);
      MyDrawString(s);
      SetOthellierEstSale(square,true);
      InvalidateDessinEnTraceDeRayon(square);
      SetPort(oldPort);
   end;
end;

procedure DessinePionMontreCoupLegal(x : SInt16);
var oldport : grafPtr;
begin
  if windowPlateauOpen then
     begin
        GetPort(oldport);
        SetPortByWindow(wPlateauPtr);
        if inverseVideo[x]
          then
            begin
              if CassioEstEn3D
                then DessinePion3D(x,pionVide)
                else DessinePion2D(x,pionVide);
              inverseVideo[x] := false;
            end
          else
            begin
              if CassioEstEn3D
                then DessinePion3D(x,pionMontreCoupLegal)
                else DessinePion2D(x,pionMontreCoupLegal);
              inverseVideo[x] := true;
            end;
        SetPort(oldport);
     end;
end;


procedure EffacePionMontreCoupLegal(x : SInt16);
var oldport : grafPtr;
begin
   if windowPlateauOpen then
     begin
       GetPort(oldport);
       SetPortByWindow(wPlateauPtr);
       if aidedebutant then
         begin
           if not(inverseVideo[x]) then
            begin
              if CassioEstEn3D
                then DessinePion3D(x,pionMontreCoupLegal)
                else DessinePion2D(x,pionMontreCoupLegal);
              inverseVideo[x] := true;
              SetOthellierEstSale(x,true);
            end;
         end
         else
         begin
           if inverseVideo[x] then
            begin
              if CassioEstEn3D
                then DessinePion3D(x,effaceCase)
                else DessinePion2D(x,pionVide);
              inverseVideo[x] := false;
            end;
         end;
       SetPort(oldport);
     end;
end;







procedure SetCoupEntete(square : SInt16);
begin
  coupEnTete := square;
end;






END.
