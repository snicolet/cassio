UNIT UnitIconisation;






INTERFACE










function InitUnitIconisationOK : boolean;
function LibereMemoireIconisation : boolean;

procedure CloseIconisationWindow;
procedure FabriquePictureIconisation;
procedure DessinePictureIconisation;
procedure DetruitPictureIconisation;
procedure RefletePositionCouranteDansPictureIconisation;
procedure DoUpdateIconisation;

procedure IconiserCassio;
procedure DeiconiserCassio;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio, MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitOffScreenGraphics, UnitBaseNouveauFormat, UnitAffichagePlateau, UnitTroisiemeDimension, UnitCarbonisation, MyQuickDraw
    , UnitRapportImplementation, UnitCarbonisation, UnitFenetres, UnitCurseur, MyFonts, SNMenus, UnitMenus, UnitNewGeneral
    , UnitDiagramFforum, UnitGestionDuTemps, MyStrings, UnitRegressionLineaire, UnitEnvirons, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/Iconisation.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure SetValeursParDefautDiagIconisation(var ParamDiag : ParamDiagRec; typeDiagramme : SInt16);
begin
  with ParamDiag do
    begin
      TypeDiagrammeFFORUM := typeDiagramme;
      DecalageHorFFORUM := 0;
      DecalageVertFFORUM := 0;
      tailleCaseFFORUM := 11 * iconisationDeCassio.scaleFactor;
      if gWindowsHaveThickBorders | gIsRunningUnderMacOSX
        then  {Kaleidoscope s'occupe deja d'aŽrer le diagramme => pas de marge}
          begin
            epaisseurCadreFFORUM := 0.0;
            distanceCadreFFORUM := 0;
          end
        else
          begin
            epaisseurCadreFFORUM := 1.0;
            distanceCadreFFORUM := 1;
          end;
      if (typeDiagramme = DiagrammePosition) | true
       then
         begin
           PionsEnDedansFFORUM := true;
           nbPixelDedansFFORUM := 2*iconisationDeCassio.scaleFactor div 2;
         end
       else
         begin
           PionsEnDedansFFORUM := false;
           nbPixelDedansFFORUM := 0;
         end;

      if gEcranCouleur
       then
         begin
           {FondOthellierPatternFFORUM := kDarkGrayPattern;}
           FondOthellierPatternFFORUM := kBlackPattern;
           couleurOthellierFFORUM := QuickdrawColorToDiagramFforumColor(gCouleurOthellier.plusProcheCouleurDeBaseSansBlanc);

           CouleurRGBOthellierFFORUM := CouleurDesPetitsOthelliers;
         end
       else
         begin
           FondOthellierPatternFFORUM := kDarkGrayPattern;
           couleurOthellierFFORUM := kCouleurDiagramBlanc;
         end;

      DessineCoinsDuCarreFFORUM := false;
      DessinePierresDeltaFFORUM := affichePierresDelta;
      EcritApres37c7FFORUM := false;
      EcritNomTournoiFFORUM := false;
      EcritNomsJoueursFFORUM := false;
      PoliceFFORUMID := CourierID;
      CoordonneesFFORUM := false;
      NumerosSeulementFFORUM := false;
      TraitsFinsFFORUM := false;
    end;

end;


procedure CreateOffScreenIconisation;
var GWorldPixMapHdl : PixMapHandle;
    lockPixResult : boolean;
begin
  with iconisationDeCassio do
    begin
      useOffScreenIconisationBuffer := (CreateTempOffScreenWorld(offScreenIconisationRect,offScreenIconisationWorld) = NoErr);
      if useOffScreenIconisationBuffer then
        begin
          GWorldPixMapHdl := GetGWorldPixMap(offScreenIconisationWorld);
          lockPixResult := LockPixels(GWorldPixMapHdl);
        end;
    end;
end;


function InitUnitIconisationOK : boolean;
var s : String255;
begin
  with iconisationDeCassio do
    begin
      enCours := false;
      s := 'Cassio';
      {s := getApplicationName('Cassio');}

      scaleFactor := 4;


      {SetRect(IconisationRect, 100,100, 1000,1000);}

      if gIsRunningUnderMacOSX
        then theWindow := MyNewCWindow(NIL, IconisationRect, s, False, kWindowMovableModalDialogProc, FenetreFictiveAvantPlan, false, 1)
        else theWindow := MyNewCWindow(NIL, IconisationRect, s, False, noGrowDocProc, FenetreFictiveAvantPlan, false, 1);

      possible := (theWindow <> NIL);
      NewParamDiag(ParametresIconeOthellier);
      SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePosition);
      OthellierPicture := NIL;

      {astuce : largeur x largeur pour eviter les textes au dessus et en dessous et avoir un diagramme carre}
      SetRect(offScreenIconisationRect,0,0,LargeurDiagrammeFFORUM, LargeurDiagrammeFFORUM);

      offScreenIconisationWorld := NIL; {on ne prend pas encore la place en memoire}

    end;
  InitUnitIconisationOK := iconisationDeCassio.possible;
end;

function LibereMemoireIconisation : boolean;
begin
  with iconisationDeCassio do
	 begin
	   DisposeWindow(theWindow);
	   theWindow := NIL;
	   enCours := false;
	   possible := false;
	   DisposeParamDiag(ParametresIconeOthellier);
	   DetruitPictureIconisation;
	   KillTempOffscreenWorld(offScreenIconisationWorld);
	 end;
  LibereMemoireIconisation := true;
end;

procedure CloseIconisationWindow;
begin
  with iconisationDeCassio do
    begin
	  SetPortByWindow(theWindow);
	  iconisationRect := GetWindowPortRect(iconisationDeCassio.theWindow);
	  LocalToGlobal(IconisationRect.topleft);
	  LocalToGlobal(IconisationRect.botright);
	  ShowHide(theWindow,false);
    end;
end;

procedure FabriquePictureIconisation;
var oldport : grafPtr;
    unrectDiag : rect;
    oldClipRgn : RgnHandle;
    chainePositionInitiale,chaineCoups : String255;
begin
  with iconisationDeCassio do
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);

      if enRetour
        then SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePartie)
        else SetValeursParDefautDiagIconisation(ParametresIconeOthellier,DiagrammePosition);
      SetParamDiag(ParametresIconeOthellier);

      oldClipRgn := NewRgn;
      GetClip(oldClipRgn);
      {ClipRect(QDGetPortBound);}
      SetRect(unrectDiag,0,0,LargeurDiagrammeFFORUM-1, LargeurDiagrammeFFORUM-1);
      OthellierPicture := OpenPicture(unrectDiag);

      ParserPositionEtCoupsOthello8x8(PositionEtCoupIconeStr,chainePositionInitiale,chaineCoups);

      if enRetour
        then
          ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups)
        else
          begin
            ConstruitPositionPicture(ConstruitChainePosition8x8(JeuCourant),chaineCoups);
            if ParametresIconeOthellier.DessinePierresDeltaFFORUM
              then ConstruitPicturePionsDeltaCourants;
          end;

      PrintEpilogueForEPSFile;

      ClosePicture;
      SetClip(oldclipRgn);
      DisposeRgn(oldclipRgn);

      SetPort(oldPort);
    end;
end;

procedure DetruitPictureIconisation;
begin
  with iconisationDeCassio do
    if OthellierPicture <> NIL then
      begin
        KillPicture(OthellierPicture);
        OthellierPicture := NIL;
      end;
end;

procedure DessinePictureIconisation;
var oldport : grafPtr;
    myRect : Rect;
begin
  with iconisationDeCassio do
    if OthellierPicture <> NIL then
	    begin

	      if (offScreenIconisationWorld = NIL) then
          CreateOffScreenIconisation;

	      GetPort(oldport);

        SetGWorld(offScreenIconisationWorld, NIL);

        RGBForeColor(gPurNoir);
        RGBBackColor(gPurBlanc);
        ForeColor(BlackColor);
        BackColor(WhiteColor);

        DrawPicture(OthellierPicture,offScreenIconisationRect);

        SetPortByWindow(theWindow);

        RGBForeColor(gPurNoir);
        RGBBackColor(gPurBlanc);
        ForeColor(BlackColor);
        BackColor(WhiteColor);

        if CassioEstEn3D {& false}
          then
              CopyBits(GetPortBitMapForCopyBits(GetWindowPort(wPlateauPtr))^ ,
                     GetPortBitMapForCopyBits(GetWindowPort(theWindow))^ ,
		                 GetWindowPortRect(wPlateauPtr), QDGetPortBound, ditherCopy + srcCopy, NIL)
		      else
    		    if not(gCouleurOthellier.estUneImage) | CassioEstEn3D
    		      then
                  CopyBits(GetPortBitMapForCopyBits(offScreenIconisationWorld)^ ,
                          GetPortBitMapForCopyBits(GetWindowPort(theWindow))^ ,
    		                  offScreenIconisationRect, QDGetPortBound, ditherCopy + srcCopy, NIL)
    		      else
      			    begin
      			      myRect := aireDeJeu;
      			      dec(myRect.right);
      			      CopyBits(GetPortBitMapForCopyBits(GetWindowPort(wPlateauPtr))^ ,
                         GetPortBitMapForCopyBits(GetWindowPort(theWindow))^ ,
    		                 myRect, GetWindowPortRect(theWindow), ditherCopy + srcCopy, NIL);
    		        end;


	     ValidRect(QDGetPortBound);
	     SetPort(oldport);
	   end;
end;

procedure RefletePositionCouranteDansPictureIconisation;
begin
  if iconisationDeCassio.encours then
    begin
  	  DetruitPictureIconisation;
  	  ConstruitPositionEtCoupDapresPartie(iconisationDeCassio.PositionEtCoupIconeStr);
  	  FabriquePictureIconisation;
  	  DessinePictureIconisation;
  	end;
end;

procedure DoUpdateIconisation;
var oldport: GrafPtr;
begin
  with iconisationDeCassio do
    begin
      GetPort(oldport);
      SetPortByWindow(theWindow);
      BeginUpdate(theWindow);
      DessinePictureIconisation;
      EndUpdate(theWindow);
      SetPort(oldport);
    end;
end;

procedure IconiserCassio;
var thePlateauRect,IconeRect : rect;
begin
  with iconisationDeCassio do
    if possible then
    	begin

    	  enCours := true;

    	  thePlateauRect := GetWindowStructRect(wPlateauPtr);
    	  IconeRect := GetWindowStructRect(theWindow);
    	  HiliteWindow(theWindow,true);
    	  if windowCourbeOpen then ShowHide(wCourbePtr,false);
    	  if windowAideOpen then ShowHide(wAidePtr,false);
        if windowGestionOpen then ShowHide(wGestionPtr,false);
        if windowNuageOpen then ShowHide(wNuagePtr,false);
        if windowReflexOpen then ShowHide(wReflexPtr,false);
        if windowListeOpen then ShowHide(wListePtr,false);
        if windowStatOpen then ShowHide(wStatPtr,false);
        if windowRapportOpen then ShowHide(GetRapportWindow,false);
        if windowPaletteOpen then ShowHide(wPalettePtr,false);
        if windowPlateauOpen then ShowHide(wPlateauPtr,false);
        if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow,false);
        ShowHide(iconisationDeCassio.theWindow,true);
        HideTooltipWindowInCloud;

        SetPortByWindow(theWindow);

        if enRetour then
          begin
            ConstruitPositionEtCoupPositionInitiale(PositionEtCoupIconeStr);
            FabriquePictureIconisation;
            DessinePictureIconisation;
            DetruitPictureIconisation;
          end;

        ConstruitPositionEtCoupDapresPartie(PositionEtCoupIconeStr);
        FabriquePictureIconisation;
        DessinePictureIconisation;

        DisableItemTousMenus;
        MyDisableItem(EditionMenu,0);
        MyDisableItem(PartieMenu,0);
        MyDisableItem(ModeMenu,0);
        MyDisableItem(JoueursMenu,0);
        MyDisableItem(BaseMenu,0);
        MyDisableItem(SolitairesMenu,0);
        MyDisableItem(AffichageMenu,0);
        if avecProgrammation then MyDisableItem(ProgrammationMenu,0);
        MySetMenuItemText(GetFileMenu,IconisationCmd,ReadStringFromRessource(MenusChangeantsID,16));{'Deiconiser'}
        DrawMenuBar;
        AjusteSleep;
        InitCursor;
    	end;
end;


  procedure DeiconiserCassio;
  var thePlateauRect,IconeRect : rect;
  begin
  with iconisationDeCassio do
    if possible then
	begin
	  enCours := false;

	  DetruitPictureIconisation;

	  thePlateauRect := GetWindowStructRect(wPlateauPtr);
	  IconeRect := GetWindowStructRect(iconisationDeCassio.theWindow);
	  {CloseIconisationWindow;}
	  CloseIconisationWindow;
	  if windowPlateauOpen then ShowHide(wPlateauPtr,true);
	  if EssaieUpdateEventsWindowPlateauProcEstInitialise
	     then EssaieUpdateEventsWindowPlateauProc;
	  if windowCourbeOpen then ShowHide(wCourbePtr,true);
	  if windowAideOpen then ShowHide(wAidePtr,true);
    if windowGestionOpen then ShowHide(wGestionPtr,true);
    if windowNuageOpen then ShowHide(wNuagePtr,true);
    if windowReflexOpen then ShowHide(wReflexPtr,true);
    if windowListeOpen then ShowHide(wListePtr,true);
    if windowStatOpen then ShowHide(wStatPtr,true);
    if windowRapportOpen then ShowHide(GetRapportWindow,true);
    if windowPaletteOpen then ShowHide(wPalettePtr,true);
    if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow,true);
    if EssaieUpdateEventsWindowPlateauProcEstInitialise
     then EssaieUpdateEventsWindowPlateauProc;

    EmpileFenetresSousPalette;

    ShowTooltipWindowInCloud;

    MyEnableItem(EditionMenu,0);
    MyEnableItem(PartieMenu,0);
    MyEnableItem(ModeMenu,0);
    MyEnableItem(JoueursMenu,0);
    MyEnableItem(BaseMenu,0);
    MyEnableItem(SolitairesMenu,0);
    MyEnableItem(AffichageMenu,0);
    if avecProgrammation then MyEnableItem(ProgrammationMenu,0);
    MySetMenuItemText(GetFileMenu,IconisationCmd,ReadStringFromRessource(MenusChangeantsID,15));{'Iconiser'}
    if not(enSetUp) then
      begin
      EnableItemTousMenus;
      FixeMarquesSurMenus;
      FixeMarqueSurMenuBase;
      FixeMarqueSurMenuMode(nbreCoup);
      if enRetour then
        begin
          DisableItemTousMenus;
          DisableTitlesOfMenusForRetour;
        end;
      end;
    DrawMenuBar;
    AjusteSleep;
    AjusteCurseur;
	end;
end;

end.
