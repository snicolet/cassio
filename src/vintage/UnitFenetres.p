UNIT UnitFenetres;



INTERFACE








 USES UnitDefCassio;


{ Ouverture des fenetres }
procedure OuvreFntrGestion(avecAnimationZoom : boolean);
procedure OuvreFntrNuage(avecAnimationZoom : boolean);
procedure OuvreFntrReflex(avecAnimationZoom : boolean);
procedure OuvreFntrListe(avecAnimationZoom : boolean);
procedure OuvreFntrStat(avecAnimationZoom : boolean);
procedure OuvreFntrCommentaires(avecAnimationZoom : boolean);
procedure OuvreFntrPalette;
procedure OuvreFntrCourbe(avecAnimationZoom : boolean);
procedure OuvreFntrAide;
procedure OuvreFntrPlateau(avecAnimationZoom : boolean);
procedure OuvrirLesFenetresDansLOrdre;


{ Fermeture des fenetres }
procedure CloseProgramWindow;
procedure CloseCourbeWindow;
procedure CloseAideWindow;
procedure CloseGestionWindow;
procedure CloseNuageWindow;
procedure CloseReflexWindow;
procedure CloseListeWindow;
procedure CloseStatWindow;
procedure CloseCommentairesWindow;
procedure ClosePaletteWindow;
procedure MasquerToutesLesFenetres;
function VeutVraimentFermerFenetre : boolean;


{ Empilement des fenetres }
procedure EmpileFenetresSousPalette;
procedure EmpileFenetres;
function FenetreFictiveAvantPlan : WindowPtr;


{ Acces aux fenetres }
function WindowDeCassio(whichWindow : WindowPtr) : boolean;
function WindowPlateauSousDAutresFenetres : boolean;
function FrontWindowSaufPalette : WindowPtr;
function OrdreFenetre(whichWindow : WindowPtr) : SInt16;
function GetArbreDeJeuWindow : WindowPtr;
function PaletteEstSurCeDialogue(dp : DialogPtr) : boolean;
function GetOrdreEmpilementDesFenetresEnChaine : String255;


{ Activation/Desactivation d'une fenetre }
procedure SelectWindowSousPalette(whichWindow : WindowPtr);
procedure DeactivateFrontWindowSaufPalette;
procedure DoActivateWindow(whichWindow : WindowPtr; activation : boolean);
procedure CyclerDansLEmpilementDesFenetres;


{ Procedure de dessin dans des fenetres }
procedure EssaieSetPortWindowPlateau;
procedure MetTitreFenetrePlateau;
procedure DessineBoiteDeTaille(whichWindow : WindowPtr);
procedure DessineBoiteAscenseurDroite(whichWindow : WindowPtr);
procedure DrawScrollBars(whichWindow : WindowPtr);
procedure InvalidateAllWindows;


{ Redimensionnement des fenetres }
procedure DoGrowWindow(thisWindow : WindowPtr; event : eventRecord);
procedure MyZoomInOut(window : WindowPtr; partcode : SInt16);


{ Mise a jour des contenus des fenetres }
procedure DrawContentsRapide(whichWindow : WindowPtr);
procedure DoUpdateWindowRapide(whichWindow : WindowPtr);
procedure NoUpdateThisWindow(whichWindow : WindowPtr);
procedure NoUpdateWindowPlateau;
procedure NoUpdateWindowListe;
procedure DoGlobalRefresh;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ToolUtils, MacWindows, QuickdrawText, Fonts, Dialogs, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitCurseur
    , UnitRegressionLineaire, UnitRapport, UnitCouleur, UnitAffichageReflexion, UnitCarbonisation, UnitJaponais, UnitEnvirons, UnitGestionDuTemps
    , UnitListe, UnitRapportImplementation, UnitRapportUtils, UnitServicesDialogs, MyStrings, UnitStatistiques, UnitTroisiemeDimension, Unit3DPovRayPicts
    , UnitEntreeTranscript, UnitDialog, UnitServicesRapport, UnitCourbe, UnitVieilOthelliste, MyAntialiasing, SNEvents, UnitRapportWindow
    , UnitPalette, UnitCommentaireArbreDeJeu, UnitAffichagePlateau, UnitOth2 ;
{$ELSEC}
    ;
    {$I prelink/Fenetres.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure DeactivateFrontWindowSaufPalette;
var whichWindow : WindowPtr;
begin
  whichWindow := FrontWindowSaufPalette;
  if whichWindow <> NIL then
    begin
      HiliteWindow(whichWindow,false);
      DoActivateWindow(whichWindow,false);
    end;
end;


procedure OuvreFntrGestion(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin  {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,8);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   wGestionPtr := MyNewCWindow(NIL,FntrGestionRect,titre,false,documentProc,behind,true,0);
   windowGestionOpen := ( wGestionPtr <> NIL );
   if windowGestionOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        rect2 := FntrGestionRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        ShowHide(wGestionPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wGestionPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wGestionPtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcOr);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        //RGBBackColor(EclaircirCouleurDeCetteQuantite(gPurGris,25000));
        //RGBBackColor(EclaircirCouleurDeCetteQuantite(gPurGris,30000));
        MyEraseRect(GetWindowPortRect(wGestionPtr));
        MyEraseRectWithColor(GetWindowPortRect(wGestionPtr),OrangeCmd,blackPattern,'');
     end;
end;

procedure OuvreFntrNuage(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin  {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,11);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   if wNuagePtr = NIL
     then wNuagePtr := MyNewCWindow(NIL,FntrNuageRect,titre,false,documentProc,behind,true,0);
   windowNuageOpen := ( wNuagePtr <> NIL );
   if windowNuageOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        rect2 := FntrNuageRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        MetTitreFenetreNuage;
        DeterminerLaMeilleureEchelleVerticaleDuNuage;
        ShowHide(wNuagePtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wNuagePtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wNuagePtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wNuagePtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcOr);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        MyEraseRect(GetWindowPortRect(wNuagePtr));
        MyEraseRectWithColor(GetWindowPortRect(wNuagePtr),OrangeCmd,blackPattern,'');
     end;
end;

procedure OuvreFntrReflex(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,7);
   titre := ' '+titre;
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   wReflexPtr := MyNewCWindow(NIL,FntrReflexRect,titre,false,documentProc,behind,true,0);

   windowReflexOpen := ( wReflexPtr <> NIL );
   if windowReflexOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen and (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteReflexion,rect1);
        rect2 := FntrReflexRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        ShowHide(wReflexPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wReflexPtr);
        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
        EnableQuartzAntiAliasingThisPort(GetWindowPort(wReflexPtr),true);
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        MyEraseRect(GetWindowPortRect(wReflexPtr));
        MyEraseRectWithColor(GetWindowPortRect(wReflexPtr),OrangeCmd,blackPattern,'');
        EffaceReflexion(true);
     end;
end;

procedure OuvreFntrListe(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,3);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   wListePtr := MyNewCWindow(NIL,FntrListeRect,titre,false,zoomDocProc,behind,true,0);
   windowListeOpen := ( wListePtr <> NIL );
   if windowListeOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen and (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteListe,rect1);
        rect2 := FntrListeRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        ShowHide(wListePtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wListePtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcOr);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        MyEraseRect(GetWindowPortRect(wListePtr));
        MyEraseRectWithColor(GetWindowPortRect(wListePtr),OrangeCmd,blackPattern,'');
        OuvreControlesListe;
        DessineBoiteDeTaille(wListePtr);
     end;
end;

procedure OuvreFntrStat(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,4);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   wStatPtr := MyNewCWindow(NIL,FntrStatRect,titre,false,documentProc,behind,true,0);
   windowStatOpen := ( wStatPtr <> NIL );
   if windowStatOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen and (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteStatistique,rect1);
        rect2 := FntrStatRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        ShowHide(wStatPtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wStatPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wStatPtr));
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        MyEraseRect(GetWindowPortRect(wStatPtr));
        MyEraseRectWithColor(GetWindowPortRect(wStatPtr),OrangeCmd,blackPattern,'');
        DessineBoiteDeTaille(wStatPtr);
     end;
end;

procedure OuvreFntrCommentaires(avecAnimationZoom : boolean);
const CommentairesID = 2000;
      CommentaireStaticTextID = 1;
var behind : WindowPtr;
    rect1,rect2 : rect;
begin {$unused avecAnimationZoom}
  with arbreDeJeu do
    begin
		  if (wPalettePtr <> NIL) and windowPaletteOpen
		     then behind := wPalettePtr
		     else behind := FenetreFictiveAvantPlan;
		   theDialog := GetNewDialog(CommentairesID,NIL,behind);
		   windowOpen := (arbreDeJeu.theDialog <> NIL);
		   if windowOpen then
		     begin
		       DeactivateFrontWindowSaufPalette;
		       SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
		       rect2 := FntrCommentairesRect;
		       rect2.top := rect2.top-18;
		       InsetRect(rect2,-1,-1);
		       SetPortByDialog(theDialog);
		       if gCassioUseQuartzAntialiasing
             then EnableQuartzAntiAliasingThisPort(GetDialogPort(theDialog),true)
             else DisableQuartzAntiAliasingThisPort(GetDialogPort(theDialog));
		       BackPat(whitePattern);
		       TextSize(gCassioSmallFontSize);
		       TextMode(0);
		       TextFace(normal);
		       TextFont(gCassioApplicationFont);

		       with FntrCommentairesRect do
		         begin
		           MoveWindow(GetArbreDeJeuWindow,left,top,false);
		           SizeWindow(GetArbreDeJeuWindow,right-left,bottom-top,true);
		         end;

		       ShowHide(GetArbreDeJeuWindow,true);

		       ChangeDelimitationEditionRectFenetreArbreDeJeu(positionLigneSeparation);

		       EmpileFenetresSousPalette;
		       SetPortByDialog(arbreDeJeu.theDialog);
		     end;
		 end;
end;

procedure OuvreFntrPalette;
var behind : WindowPtr;
    titre : String255;
begin
   titre := ReadStringFromRessource(TitresFenetresTextID,2);
   behind := FenetreFictiveAvantPlan;

   if false and gIsRunningUnderMacOSX then
     begin
       inc(FntrPaletteRect.right);
       inc(FntrPaletteRect.bottom);
     end;

   wPalettePtr := MyNewCWindow(NIL,FntrPaletteRect,titre,false,kWindowFloatProc,behind,true,0);
   {wPalettePtr := MyNewCWindow(NIL,FntrPaletteRect,titre,false,PaletteDefID*16,behind,true,0);}
   windowPaletteOpen := ( wPalettePtr <> NIL );
   if windowPaletteOpen then
     begin
        ShowHide(wPalettePtr,true);
        ShowWindow(wPalettePtr);
        BringToFront(wPalettePtr);
        SelectWindow(wPalettePtr);


        SetPortByWindow(wPalettePtr);
        BackPat(whitePattern);
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        MyEraseRect(GetWindowPortRect(wPalettePtr));
        MyEraseRectWithColor(GetWindowPortRect(wPalettePtr),OrangeCmd,blackPattern,'');
        DessinePalette;

        EmpileFenetresSousPalette;
     end;
end;


procedure OuvreFntrCourbe(avecAnimationZoom : boolean);
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin {$unused avecAnimationZoom}
   titre := ReadStringFromRessource(TitresFenetresTextID,6);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;
   wCourbePtr := MyNewCWindow(NIL,FntrCourbeRect,titre,false,zoomDocProc,behind,true,0);
   windowCourbeOpen := ( wCourbePtr <> NIL );
   if windowCourbeOpen then
     begin
        DeactivateFrontWindowSaufPalette;
        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        if windowPaletteOpen and (wPalettePtr <> NIL) then
          GetRectDansPalette(PaletteCourbe,rect1);
        rect2 := FntrCourbeRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-1,-1);
        ShowHide(wCourbePtr,true);
        EmpileFenetresSousPalette;
        SetPortByWindow(wCourbePtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr));
        TextSize(gCassioSmallFontSize);
        TextMode(srcBic);
        TextFace(normal);
        TextFont(gCassioApplicationFont);
        CreerImageDeFondPourCourbeSiNecessaire;
     end;
end;


procedure OuvreFntrAide;
var behind : WindowPtr;
    titre : String255;
begin
   titre := ReadStringFromRessource(TitresFenetresTextID,10);
   if (wPalettePtr <> NIL) and windowPaletteOpen
     then behind := wPalettePtr
     else behind := FenetreFictiveAvantPlan;

   wAidePtr := MyNewCWindow(NIL,FntrAideRect,titre,false,zoomDocProc,behind,true,0);
   windowAideOpen := ( wAidePtr <> NIL );
   if windowAideOpen then
     begin
       DeactivateFrontWindowSaufPalette;
       ShowHide(wAidePtr,true);
       EmpileFenetresSousPalette;
       SetPortByWindow(wAidePtr);
       if gCassioUseQuartzAntialiasing
         then EnableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr),true)
         else DisableQuartzAntiAliasingThisPort(GetWindowPort(wAidePtr));
       TextSize(gCassioSmallFontSize);
       TextMode(srcBic);
       TextFace(normal);
       TextFont(gCassioApplicationFont);
     end;
end;

procedure OuvreFntrPlateau(avecAnimationZoom : boolean);
const FenetreOthellierID = 128;
var rect1,rect2 : rect;
    behind : WindowPtr;
    titre : String255;
begin  {$unused avecAnimationZoom}

   titre := ReadStringFromRessource(TitresFenetresTextID,1);
   behind := NIL;

   wPlateauPtr := MyNewCWindow(NIL,FntrPlatRect,titre,false,zoomDocProc,behind,false,0);
   windowPlateauOpen := ( wPlateauPtr <> NIL );
   if windowPlateauOpen then
     begin

        SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
        rect2 := FntrPlatRect;
        rect2.top := rect2.top-18;
        InsetRect(rect2,-2,-2);

        {ShowHide(wPlateauPtr,true);}

        EmpileFenetresSousPalette;
        SetPortByWindow(wPlateauPtr);
        if gCassioUseQuartzAntialiasing
          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),false)
          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));

        BackPat(fond);
        MyEraseRect(GetWindowPortRect(wPlateauPtr));
        MyEraseRectWithColor(GetWindowPortRect(wPlateauPtr),OrangeCmd,blackPattern,'');

        PrepareTexteStatePourHeure;
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
          then
            begin
              SetAffichageResserre(false);
            end
          else
            begin

              genreAffichageTextesDansFenetrePlateau := kAffichageAere;
              SetTailleCaseCourante(CalculeTailleCaseParPlateauRect(aireDeJeu));
              if GetTailleCaseCourante <= 0 then SetTailleCaseCourante(TailleCaseIdeale);

              if avecSystemeCoordonnees
                then SetPositionPlateau2D(8,GetTailleCaseCourante,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,'OuvreFntrPlateau')
                else SetPositionPlateau2D(8,GetTailleCaseCourante,PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,'OuvreFntrPlateau');
              SetPositionsTextesWindowPlateau;
            end;
        MyEnableItem(PartieMenu,0);
        DrawMenuBar;

        if gCassioUseQuartzAntialiasing then
	        if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

        doitAjusterCurseur := true;
        AjusteCurseur;
     end;
end;



procedure CloseProgramWindow;
var fermeture : boolean;
    oldPort : grafPtr;
  begin
    if windowPlateauOpen then
      begin
        fermeture := true;
        if not(Quitter) then fermeture := VeutVraimentFermerFenetre;
        if fermeture then
          begin
            GetPort(oldport);
            SetPortByWindow(wPlateauPtr);
            FntrPlatRect := GetWindowPortRect(wPlateauPtr);
            LocalToGlobal(FntrPlatRect.topleft);
            LocalToGlobal(FntrPlatRect.botright);
            SetPort(oldport);
            windowPlateauOpen := false;
            MyDisableItem(PartieMenu,0);
            DrawMenuBar;
            gameOver := true;
            LanceInterruptionSimple('CloseProgramWindow');
            vaDepasserTemps := false;
            AjusteCurseur;
            SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
            CloseZoomRectFrom := FntrPlatRect;
            CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
            InsetRect(CloseZoomRectFrom,-2,-2);
            if wPlateauPtr <> NIL then DisposeWindow(wPlateauPtr);
            wPlateauPtr := NIL;
            EssaieSetPortWindowPlateau;
            EmpileFenetresSousPalette;
          end;
      end;
  end;

procedure CloseCourbeWindow;
var oldPort : grafPtr;
  begin
    if windowCourbeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      FntrCourbeRect := GetWindowPortRect(wCourbePtr);
      LocalToGlobal(FntrCourbeRect.topleft);
      LocalToGlobal(FntrCourbeRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen and (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteCourbe,CloseZoomRectTo);
      CloseZoomRectFrom := FntrCourbeRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowCourbeOpen := false;
      AjusteCurseur;
      if wCourbePtr <> NIL then DisposeWindow(wCourbePtr);
      wCourbePtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;

procedure CloseAideWindow;
var oldPort : grafPtr;
  begin
    if windowAideOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wAidePtr);
      FntrAideRect := GetWindowPortRect(wAidePtr);
      LocalToGlobal(FntrAideRect.topleft);
      LocalToGlobal(FntrAideRect.botright);
      SetPort(oldport);
      windowAideOpen := false;
      AjusteCurseur;
      if wAidePtr <> NIL then DisposeWindow(wAidePtr);
      wAidePtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;

procedure CloseGestionWindow;
var oldPort : grafPtr;
  begin
    if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      FntrGestionRect := GetWindowPortRect(wGestionPtr);
      LocalToGlobal(FntrGestionRect.topleft);
      LocalToGlobal(FntrGestionRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      CloseZoomRectFrom := FntrGestionRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      windowGestionOpen := false;
      afficheGestionTemps := false;
      InsetRect(CloseZoomRectFrom,-1,-1);
      AjusteCurseur;
      if wGestionPtr <> NIL then DisposeWindow(wGestionPtr);
      wGestionPtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
      if affichageReflexion.doitAfficher then EcritReflexion('CloseGestionWindow');
    end;
  end;


procedure CloseNuageWindow;
var oldPort : grafPtr;
  begin
    if windowNuageOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);
      FntrNuageRect := GetWindowPortRect(wNuagePtr);
      LocalToGlobal(FntrNuageRect.topleft);
      LocalToGlobal(FntrNuageRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      CloseZoomRectFrom := FntrNuageRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      windowNuageOpen := false;
      afficheNuage := false;
      InsetRect(CloseZoomRectFrom,-1,-1);
      AjusteCurseur;
      if (wNuagePtr <> NIL) then
        begin
          if Quitter
            then
              begin
                DisposeWindow(wNuagePtr);
                wNuagePtr := NIL;
              end
            else
              ShowHide(wNuagePtr,false);
        end;
      CloseTooltipWindowInCloud;
      DisposeMemoryForEdaxMatrix;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
      if affichageReflexion.doitAfficher then EcritReflexion('CloseNuageWindow');
    end;
  end;

procedure CloseReflexWindow;
var oldPort : grafPtr;
  begin
    if windowReflexOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wReflexPtr);
      FntrReflexRect := GetWindowPortRect(wReflexPtr);
      LocalToGlobal(FntrReflexRect.topleft);
      LocalToGlobal(FntrReflexRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen and (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteReflexion,CloseZoomRectTo);
      CloseZoomRectFrom := FntrReflexRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowReflexOpen := false;
      affichageReflexion.doitAfficher := false;
      AjusteCurseur;
      if wReflexPtr <> NIL then DisposeWindow(wReflexPtr);
      wReflexPtr := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
  end;

procedure CloseListeWindow;
var oldPort : grafPtr;
  begin
    if windowListeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);
      FntrListeRect := GetWindowPortRect(wListePtr);
      LocalToGlobal(FntrListeRect.topleft);
      LocalToGlobal(FntrListeRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen and (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteListe,CloseZoomRectTo);
      CloseZoomRectFrom := FntrListeRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);

      CloseControlesListe;
      if wListePtr <> NIL then DisposeWindow(wListePtr);
      wListePtr := NIL;
      windowListeOpen := false;

      SaveInfosFermetureListePartie(infosListeParties,infosListePartiesDerniereFermeture);
      InvalidateJustificationPasDePartieDansListe;

      EmpileFenetresSousPalette;
      EssaieSetPortWindowPlateau;
      if not(Quitter) then
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) and not(windowListeOpen or windowStatOpen)
          then
            begin
              AjusteAffichageFenetrePlatRapide;
              EcranStandard(NIL,false);
            end
          else
            begin
              SetAffichageVertical;
              DessineAffichageVertical;
            end;
      AjusteCurseur;
    end;
  end;

procedure CloseStatWindow;
var oldPort : grafPtr;
  begin
    if windowStatOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wStatPtr);
      FntrStatRect := GetWindowPortRect(wStatPtr);
      LocalToGlobal(FntrStatRect.topleft);
      LocalToGlobal(FntrStatRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      if windowPaletteOpen and (wPalettePtr <> NIL) then
        GetRectDansPalette(PaletteStatistique,CloseZoomRectTo);
      CloseZoomRectFrom := FntrStatRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);
      windowStatOpen := false;
      if wStatPtr <> NIL then DisposeWindow(wStatPtr);
      wStatPtr := NIL;
      EmpileFenetresSousPalette;
      EssaieSetPortWindowPlateau;
      if not(Quitter) then
        if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) and not(windowListeOpen or windowStatOpen)
          then
            begin
              AjusteAffichageFenetrePlatRapide;
              EcranStandard(NIL,false);
            end
          else
            begin
              SetAffichageVertical;
              DessineAffichageVertical;
            end;
      AjusteCurseur;
    end;
  end;

procedure CloseCommentairesWindow;
var oldPort : grafPtr;
begin
  with arbreDeJeu do
  if windowOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(GetArbreDeJeuWindow);
      FntrCommentairesRect := GetWindowPortRect(GetArbreDeJeuWindow);
      LocalToGlobal(FntrCommentairesRect.topleft);
      LocalToGlobal(FntrCommentairesRect.botright);
      SetPort(oldport);
      SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
      CloseZoomRectFrom := FntrCommentairesRect;
      CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
      InsetRect(CloseZoomRectFrom,-1,-1);

      if enModeEdition then
        begin
          enModeEdition := false;
          doitResterEnModeEdition := false;
          GetCurrentScript(gLastScriptUsedInDialogs);
          SwitchToRomanScript;
        end;
      windowOpen := false;
      if theDialog <> NIL then DisposeDialog(theDialog);
      theDialog := NIL;
      EssaieSetPortWindowPlateau;
      EmpileFenetresSousPalette;
    end;
end;


procedure ClosePaletteWindow;
var oldPort : grafPtr;
  begin
    if windowPaletteOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wPalettePtr);
      FntrPaletteRect := GetWindowPortRect(wPalettePtr);
      LocalToGlobal(FntrPaletteRect.topleft);
      LocalToGlobal(FntrPaletteRect.botright);

      if false and gIsRunningUnderMacOSX then
			   begin
			     dec(FntrPaletteRect.right);
			     dec(FntrPaletteRect.bottom);
			   end;

      SetPort(oldport);
      windowPaletteOpen := false;
      AjusteCurseur;
      if wPalettePtr <> NIL then DisposeWindow(wPalettePtr);
      wPalettePtr := NIL;
      EssaieSetPortWindowPlateau;
    end;
  end;


procedure DrawScrollBars(whichWindow : WindowPtr);
  var vbarrect : rect;
      hbarrect : rect;
      gbrect : rect;
  begin
    DessineBoiteDeTaille(whichWindow);
    CalculateControlRects(whichWindow,hbarrect,vbarrect,gbrect);
    ValidRect(hbarrect);
    ValidRect(vbarrect);
    ValidRect(gbrect);
  end;


function GetArbreDeJeuWindow : WindowPtr;
begin
  if arbreDeJeu.theDialog = NIL
    then GetArbreDeJeuWindow := NIL
    else GetArbreDeJeuWindow := GetDialogWindow(arbreDeJeu.theDialog);
end;


procedure OuvrirLesFenetresDansLOrdre;
var i : SInt16;
begin

  with VisibiliteInitiale do
    begin

		  FntrPaletteRect.right  := FntrPaletteRect.left + 9 * largeurCasePalette - 1;
			FntrPaletteRect.bottom := FntrPaletteRect.top  + 2 * hauteurcasepalette - 1;

      for i := LENGTH_OF_STRING(ordreOuvertureDesFenetres) downto 1 do
        case ordreOuvertureDesFenetres[i] of
          'O' : begin
                  { normalement, la fenetre de l'othellier devrait deja etre ouverte,
                    mais on verifie quand meme, a tout hasard… }
                  if not(windowPlateauOpen) then
                    OuvreFntrPlateau(false);
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) then
                    SetAffichageResserre(false);
                end;
          'R' : begin
		              if tempowindowRapportOpen then
		                begin
		                  if not(CreateRapport)
                        then AlerteSimple(ReadStringFromRessource(TextesErreursID,2))
                		    else EcritBienvenueDansRapport;
		                  OuvreFntrRapport(false,false);
		                end;
                end;
          'S' : begin
                  if tempowindowStatOpen then
						        begin
						          SetStatistiquesSontEcritesDansLaFenetreNormale(true);
						          OuvreFntrStat(false);
						          EcritRubanStatistiques;
						        end;
                end;
          'L' : begin
                  if tempowindowListeOpen then
						        begin
						          OuvreFntrListe(false);
						          EcritRubanListe(false);
						        end;
						    end;
          'K' : begin
                  if tempowindowCourbeOpen then
                    OuvreFntrCourbe(false);
                end;
          'A' : begin
                  if tempowindowAideOpen then
                    OuvreFntrAide;
                end;
          'P' : begin
                  if tempowindowReflexOpen then
                    OuvreFntrReflex(false);
                end;
          'G' : begin
                  if tempowindowGestionOpen then
                    OuvreFntrGestion(false);
                end;
          'N' : begin
                  if tempowindowNuageOpen then
                    OuvreFntrNuage(false);
                end;
          'C' : begin
                  if tempowindowCommentairesOpen then
                    OuvreFntrCommentaires(false);
                end;
          'T' : begin
								  if tempowindowPaletteOpen
								    then OuvreFntrPalette;
								end;
        end; {case}
    end;

  if not(GetWindowRapportOpen) then
    begin
      if not(CreateRapport)
        then AlerteSimple(ReadStringFromRessource(TextesErreursID,2))
        else EcritBienvenueDansRapport;
    end;

  EmpileFenetresSousPalette;
end;


procedure EmpileFenetresSousPalette;
var whichWindow : WindowPtr;
    n : SInt16;
    ok : boolean;
begin
  if not(windowPaletteOpen) or (wPalettePtr = NIL) then
    begin
      EmpileFenetres;
      exit;
    end;

  if FrontWindow <> wPalettePtr then
    begin
      BringToFront(wPalettePtr);
      DessinePalette;
    end;
  n := 0;
  whichWindow := wPalettePtr;
  repeat
    if whichWindow = NIL
      then ok := false
      else
        begin
			    whichWindow := MyGetNextWindow(whichWindow);
			    ok := WindowDeCassio(whichWindow);
			    if ok then
			      if IsWindowVisible(whichWindow) and (whichWindow <> GetTooltipWindowInCloud) then
			        begin
			          inc(n);
			          if (n = 1)
			            then
			              begin
			                if not(IsWindowHilited(whichWindow)) then
			                  begin
			                    HiliteWindow(whichWindow,true);
			                    DoActivateWindow(whichWindow,true);
			                  end
			              end
			            else
			              begin
			                if IsWindowHilited(whichWindow) then
			                  begin
			                    HiliteWindow(whichWindow,false);
			                    DoActivateWindow(whichWindow,false);
			                  end
			              end;
			         end;
			  end;
  until not(ok);
  MetTitreFenetrePlateau;
end;


procedure EmpileFenetres;
var whichWindow : WindowPtr;
    n : SInt16;
    ok : boolean;
begin
  n := 0;
  whichWindow := FrontNonFloatingWindow;
  ok := WindowDeCassio(whichWindow);
  repeat
    if ok and (whichWindow <> NIL) then
      begin
        if IsWindowVisible(whichWindow) and (whichWindow <> GetTooltipWindowInCloud) then
          begin
            inc(n);
            if (n = 1)
              then
                begin
                  if not(IsWindowHilited(whichWindow)) then
                    begin
                      HiliteWindow(whichWindow,true);
                    end;
                  DoActivateWindow(whichWindow,true);
                end
              else
                begin
                  if IsWindowHilited(whichWindow) then
                    HiliteWindow(whichWindow,false);
                  DoActivateWindow(whichWindow,false);
                end;
          end;
        whichWindow := MyGetNextWindow(whichWindow);
        ok := WindowDeCassio(whichWindow);
      end;
  until (whichWindow = NIL) or not(ok);
  MetTitreFenetrePlateau;
end;


function FenetreFictiveAvantPlan : WindowPtr;
begin
  FenetreFictiveAvantPlan := MAKE_MEMORY_POINTER(-1);
end;


procedure DoGrowWindow(thisWindow : WindowPtr; event : eventRecord);
const CommenentaireTitreStaticText = 1;
var growSize : SInt32;
    toucheOption,fenetreRedimensionnee : boolean;
    limitRect,unRect : rect;
    oldSizeRect,newSizeRect : rect;
    outNewContentRect : rect;
    oldPort : grafPtr;
    effaceFenetre,infosChangent : boolean;
    tailleboite : SInt16;
begin
  if thisWindow = NIL then exit;

  if (thisWindow = wPlateauPtr) and CassioEstEn3D
    then
      begin
        SetRect(limitrect,64,64,GetTailleImagesPovRay.h  ,GetTailleImagesPovRay.v  );
        {SetRect(limitrect,64,64,GetTailleImagesPovRay.h+1,GetTailleImagesPovRay.v+1);}
      end
    else
  if (thisWindow = wListePtr)
    then
      SetRect(limitRect,64,64,LargeurNormaleFenetreListe(nbColonnesFenetreListe),30000)
    else
      SetRect(limitRect,64,64,30000,30000);

  if (thisWindow = wPlateauPtr)
    then tailleboite := 16
    else tailleboite := 15;

  toucheOption := BAND(theEvent.modifiers,optionKey) <> 0;

  GetPort(oldport);
  SetPortByWindow(thisWindow);
  oldSizeRect := QDGetPortBound;

  fenetreRedimensionnee := ResizeWindow(thisWindow,event.where,@limitrect,@outNewContentRect);
  with outNewContentRect do
    growsize := (right - left) + 65536*(bottom - top);

  if fenetreRedimensionnee then
    begin

      effaceFenetre := (thisWindow = wCourbePtr) or
                       (thisWindow = wListePtr) or
                      // (thisWindow = wNuagePtr) or
                       ((thisWindow = wPlateauPtr) and enRetour) or
                       ((thisWindow = wPlateauPtr) and enSetUp) or
                       (EstLaFenetreDuRapport(thisWindow)) or
                       (thisWindow = GetArbreDeJeuWindow);


      with GetWindowPortRect(thisWindow) do
        if effaceFenetre
          then
            begin
              MyEraseRect(GetWindowPortRect(thisWindow));
              MyEraseRectWithColor(GetWindowPortRect(thisWindow),OrangeCmd,blackPattern,'');
		          if EstLaFenetreDuRapport(thisWindow)
		            then ChangeWindowRapportSize(LoWord(growsize),HiWord(growsize))
		            else SizeWindow(thisWindow,LoWord(growsize),HiWord(growsize),false);
		          InvalRect(GetWindowPortRect(thisWindow));
		        end
		      else
		        begin
		         SetRect(unRect,right-tailleboite,bottom-tailleboite,right,bottom);
		         MyEraseRect(unRect);
		         MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
		         InvalRect(unRect);
		         SizeWindow(thisWindow,LoWord(growsize),HiWord(growsize),true);
		         SetRect(unRect,right-tailleboite,bottom-tailleboite,right,bottom);
		         InvalRect(unRect);
		        end;

      newSizeRect := QDGetPortBound;
      if (thisWindow = wPlateauPtr) then
        begin
          SetPortByWindow(wPlateauPtr);
          infosChangent := false;
          if not(toucheOption) then
            begin
              if ((newSizeRect.bottom - newSizeRect.top) > (oldSizeRect.bottom - newSizeRect.top)) or
                  ((newSizeRect.right - newSizeRect.left) >  (oldSizeRect.right - oldSizeRect.left)) then
                begin
                  if not(CassioEstEn3D) then DessineBordureDuPlateau2D(kBordureDuBas+kBordureDeDroite);
                  EffaceTouteLaFenetreSaufLOthellier;
                  FlushWindow(wPlateauPtr);
                end;
              AjusteAffichageFenetrePlat(0,effaceFenetre,infosChangent);
            end;
          if infosChangent or effaceFenetre or not(CassioEstEn3D) or enSetUp or enRetour or EnModeEntreeTranscript
            then InvalRect(GetWindowPortRect(wPlateauPtr));
          if infosChangent and not(CassioEstEn3D) then
            begin
              SetRect(unRect,aireDeJeu.right+1,0,GetWindowPortRect(wPlateauPtr).right,GetWindowPortRect(wPlateauPtr).bottom);
              InvalRect(unRect);
            end;
          MetTitreFenetrePlateau;
        end;
      if (thisWindow = wReflexPtr) and (wReflexPtr <> NIL) and gameOver
        then
          EffaceReflexion(true);
      if (thisWindow = wListePtr) and (wListePtr <> NIL)
        then
          begin
            AjustePositionAscenseurListe;
            AjustePouceAscenseurListe(true);
          end;
      if (thisWindow = GetArbreDeJeuWindow) and (GetArbreDeJeuWindow <> NIL) then
        begin
          GetDialogItemRect(arbreDeJeu.theDialog,CommenentaireTitreStaticText,unRect);
          ChangeDelimitationEditionRectFenetreArbreDeJeu(unRect.top+6 + (newSizeRect.bottom - oldSizeRect.bottom));
        end;
      if (thisWindow = wNuagePtr) and (wNuagePtr <> NIL) then
        begin
          MetTitreFenetreNuage;
          if not(EqualRect(oldSizeRect,newSizeRect)) then
            begin
              CloseTooltipWindowInCloud;
              RedimensionnerLeNuage(oldSizeRect,newSizeRect);
            end;
          SetPortByWindow(wNuagePtr);
          SetRect(unRect,0,0,5000,5000);
          ValidRect(unRect);
          InvalRect(unRect);
        end;

      if (thisWindow = wCourbePtr) and (wCourbePtr <> NIL) then
        CreerImageDeFondPourCourbeSiNecessaire;

    end;

  SetPort(oldport);
end;


procedure MyZoomInOut(window : WindowPtr; partcode : SInt16);
var oldport : grafPtr;
begin
  {if has128KROM then}
    begin
      GetPort(oldport);
      SetPortByWindow(window);
      ZoomWindow(window,partcode,false);
      if (window = wPlateauPtr) and (BAND(theEvent.modifiers,optionKey) = 0)
        then
          begin
            AjusteTailleFenetrePlateauPourLa3D;
            AjusteAffichageFenetrePlatRapide;
          end;
      if EstLaFenetreDuRapport(window) then ChangeWindowRapportSize( -1, -1);
      SetPort(oldport);
    end;
end;


function  PaletteEstSurCeDialogue(dp : DialogPtr) : boolean;
var dialogRect,PaletteRect,inter : rect;
    oldPort : grafPtr;
begin

  if (dp = NIL) or not(windowPaletteOpen) or (wPalettePtr = NIL) then
    begin
      PaletteEstSurCeDialogue := false;
      exit;
    end;

  PaletteEstSurCeDialogue := false;

  GetPort(oldPort);
  SetPortByDialog(dp);
  dialogRect := QDGetPortBound;
  LocalToGlobal(dialogRect.topleft);
  LocalToGlobal(dialogRect.botright);
  if windowPaletteOpen and (wPalettePtr <> NIL) and IsWindowVisible(wPalettePtr) then
    begin
      SetPortByWindow(wPalettePtr);
      PaletteRect := QDGetPortBound;
      LocalToGlobal(PaletteRect.topleft);
      LocalToGlobal(PaletteRect.botright);

      PaletteEstSurCeDialogue := SectRect(PaletteRect,dialogRect,inter);

    end;
  SetPort(oldPort);

end;


function GetOrdreEmpilementDesFenetresEnChaine : String255;
var s : String255;
    whichWindow : WindowPtr;
begin
  s := '';

  whichWindow := FrontNonFloatingWindow;
  repeat

    if (whichWindow <> NIL) and WindowDeCassio(whichWindow) and IsWindowVisible(whichWindow) then
      begin
        if (whichWindow = wPalettePtr)             then s := s + 'T' else
        if (whichWindow = wStatPtr)                then s := s + 'S' else
        if (whichWindow = wListePtr)               then s := s + 'L' else
        if (whichWindow = wReflexPtr)              then s := s + 'P' else
        if (whichWindow = wCourbePtr)              then s := s + 'K' else
        if (whichWindow = wAidePtr)                then s := s + 'A' else
        if (whichWindow = wPlateauPtr)             then s := s + 'O' else
        if (whichWindow = wGestionPtr)             then s := s + 'G' else
        if (whichWindow = wNuagePtr)               then s := s + 'N' else
        if (whichWindow = GetArbreDeJeuWindow)     then s := s + 'C' else
        if (whichWindow = GetRapportWindow)        then s := s + 'R' else
        if (whichWindow = GetTooltipWindowInCloud) then s := s + 'H';
      end;
    whichWindow := MyGetNextWindow(whichWindow);

  until (whichWindow = NIL) or not(WindowDeCassio(whichWindow));

  // on rajoute la palette, si necessaire
  if windowPaletteOpen and (wPalettePtr <> NIL) and IsWindowVisible(wPalettePtr) and (Pos('T',s) <= 0)
    then s := 'T' + s;

  GetOrdreEmpilementDesFenetresEnChaine := s;
end;


var gDernierTickPourCycleDansLesFenetres : SInt32;
    gCompteurDeEmpilementsDeFenetres : SInt32;


procedure CyclerDansLEmpilementDesFenetres;
var s : String255;
    theChar : char;
    nombreFenetresDansEmpilement : SInt32;
    delai : SInt32;
begin

  delai := Abs(TickCount - gDernierTickPourCycleDansLesFenetres);

 // WritelnNumDansRapport('delai = ',delai);

  if (delai < 10)
    then exit;


  gDernierTickPourCycleDansLesFenetres := TickCount;

  s := GetOrdreEmpilementDesFenetresEnChaine;

  if (s <> '') then
    begin


      if delai > 120 then
        gCompteurDeEmpilementsDeFenetres := 0;

      inc(gCompteurDeEmpilementsDeFenetres);

      if Pos('T',s) > 0       // la palette est-elle ouverte ?
        then nombreFenetresDansEmpilement := LENGTH_OF_STRING(s) - 1  // car la palette est inutile
        else nombreFenetresDansEmpilement := LENGTH_OF_STRING(s);

    //  WritelnNumDansRapport('gCompteurDeEmpilementsDeFenetres = ',gCompteurDeEmpilementsDeFenetres);
    //  WritelnNumDansRapport('nombreFenetresDansEmpilement = ',nombreFenetresDansEmpilement);

      if (LENGTH_OF_STRING(s) > 0) then
        begin

          theChar := s[LENGTH_OF_STRING(s)];

          // Exclure la fenetre d'othellier du premier cycle
           if (gCompteurDeEmpilementsDeFenetres < nombreFenetresDansEmpilement) and
             (nombreFenetresDansEmpilement > 2) and (theChar = 'O') then
            begin
              DeleteString(s, LENGTH_OF_STRING(s) , 1);
              theChar := s[LENGTH_OF_STRING(s)];
            end;


          // Exclure la fenetre de la palette du cycle
          if (LENGTH_OF_STRING(s) > 0) and (theChar = 'T') then
            begin
              DeleteString(s, LENGTH_OF_STRING(s) , 1);
              theChar := s[LENGTH_OF_STRING(s)];
            end;

          gDernierTickPourCycleDansLesFenetres := TickCount;

          if (s <> '') then
              case theChar of
                'T' : SelectWindowSousPalette(wPalettePtr);
                'S' : SelectWindowSousPalette(wStatPtr);
                'L' : SelectWindowSousPalette(wListePtr);
                'P' : SelectWindowSousPalette(wReflexPtr);
                'K' : SelectWindowSousPalette(wCourbePtr);
                'A' : SelectWindowSousPalette(wAidePtr);
                'O' : SelectWindowSousPalette(wPlateauPtr);
                'G' : SelectWindowSousPalette(wGestionPtr);
                'N' : SelectWindowSousPalette(wNuagePtr);
                'C' : SelectWindowSousPalette(GetArbreDeJeuWindow);
                'R' : SelectWindowSousPalette(GetRapportWindow);
              end; {case}

        end;

      gDernierTickPourCycleDansLesFenetres := TickCount;
    end;
end;


procedure MasquerToutesLesFenetres;
begin
  (* on sauvegarde l'ordre d'empilement des fenetres pour pouvoir l'ecrire dans les preferences *)
  VisibiliteInitiale.ordreOuvertureDesFenetres := GetOrdreEmpilementDesFenetresEnChaine;

  (* on masque toutes les fenetres *)
  if windowPlateauOpen then ShowHide(wPlateauPtr,false);
  if windowCourbeOpen then ShowHide(wCourbePtr,false);
  if windowAideOpen then ShowHide(wAidePtr,false);
  if windowGestionOpen then ShowHide(wGestionPtr,false);
  if windowNuageOpen then ShowHide(wNuagePtr,false);
  if windowReflexOpen then ShowHide(wReflexPtr,false);
  if windowListeOpen then ShowHide(wListePtr,false);
  if windowStatOpen then ShowHide(wStatPtr,false);
  if windowRapportOpen then ShowHide(GetRapportWindow,false);
  if windowPaletteOpen then ShowHide(wPalettePtr,false);
  if arbreDeJeu.windowOpen then ShowHide(GetArbreDeJeuWindow,false);
  if TooltipWindowInCloudOpened then HideTooltipWindowInCloud;

  {donnons une chance aux autres applications de se redessiner}
  ShareTimeWithOtherProcesses(5);
end;


procedure DoActivateWindow(whichWindow : WindowPtr; activation : boolean);
var growRect : rect;
begin
  if whichWindow = NIL then exit;

  if EstLaFenetreDuRapport(whichWindow)
    then
      begin
        if activation
          then DoActivateRapport
          else DoDeactivateRapport;
      end
    else
      begin
        if (whichWindow = wListeptr)
          then DoActivateFenetreListe(activation);

        if whichWindow = GetArbreDeJeuWindow then
          with arbreDeJeu do
	          begin
	            if not(activation) then
	              begin
	                if enModeEdition then
	                  begin
	                    enModeEdition := false;
	                    GetCurrentScript(gLastScriptUsedInDialogs);
                      SwitchToRomanScript;
                    end;
	              end;
	            if enModeEdition
	              then
	                begin
	                  SwitchToScript(gLastScriptUsedInDialogs);
	                  TEActivate(GetDialogTextEditHandle(theDialog));
	                end
	              else
	                begin
	                  TEDeactivate(GetDialogTextEditHandle(theDialog));
	                end;
	            DessineZoneDeTexteDansFenetreArbreDeJeu(false);
	          end;

        if activation
          then
            begin
              if (whichWindow <> wPalettePtr) and
                 (whichWindow <> iconisationDeCassio.theWindow) and
                 (whichWindow <> wNuagePtr) and
                 (whichWindow <> GetTooltipWindowInCloud) then
                begin
                  SetPortByWindow(whichWindow);
                  growRect := GetWindowPortRect(whichWindow);
                  growRect.left := growRect.right-15;
                  growRect.top := growRect.bottom-15;
                  InvalRect(growrect);
                end;
            end
          else
            begin
              SetPortByWindow(whichWindow);
              DessineBoiteDeTaille(whichWindow);
            end;
      end;
end;


function WindowDeCassio(whichWindow : WindowPtr) : boolean;
begin
  if whichWindow = NIL
    then WindowDeCassio := false
    else WindowDeCassio := (whichWindow = wPlateauPtr)                   or
                           (whichWindow = wCourbePtr)                    or
                           (whichWindow = wAidePtr)                      or
                           (whichWindow = wReflexPtr)                    or
                           (whichWindow = wGestionPtr)                   or
                           (whichWindow = wNuagePtr)                     or
                           (whichWindow = wListePtr)                     or
                           (whichWindow = wStatPtr)                      or
                           (EstLaFenetreDuRapport(whichWindow))        or
                           (whichWindow = iconisationDeCassio.theWindow) or
                           (whichWindow = GetArbreDeJeuWindow)           or
                           (whichWindow = wPalettePtr)                   or
                           (whichWindow = GetTooltipWindowInCloud);
end;



function WindowPlateauSousDAutresFenetres : boolean;
var test : boolean;
    whichWindow : WindowPtr;
begin
  test := windowPlateauOpen and WindowDeCassio(FrontNonFloatingWindow);
  test := test and (FrontNonFloatingWindow <> wPlateauPtr);
  if test then
    begin
      whichWindow := FrontNonFloatingWindow;
      repeat
        if (whichWindow <> NIL) then
          whichWindow := MyGetNextWindow(whichWindow);
      until (whichWindow = NIL) or (whichWindow = wPlateauPtr) or not(WindowDeCassio(whichWindow));
      test := (whichWindow = wPlateauPtr);
    end;
  windowPlateauSousDAutresFenetres := test;
end;



function FrontWindowSaufPalette : WindowPtr;
var whichWindow : WindowPtr;
begin
  if not(windowPaletteOpen) and not(TooltipWindowInCloudOpened)
    then
      begin
        FrontWindowSaufPalette := FrontWindow;
      end
    else
      begin
        whichWindow := FrontNonFloatingWindow;

        if (whichWindow <> NIL) and (whichWindow = wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);

        if (whichWindow <> NIL) and (whichWindow = GetTooltipWindowInCloud)
          then whichWindow := MyGetNextWindow(whichWindow);

        if (whichWindow <> NIL) and (whichWindow = wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);

        if (whichWindow <> NIL) and (whichWindow = GetTooltipWindowInCloud)
          then whichWindow := MyGetNextWindow(whichWindow);

        while (whichWindow <> NIL) and not(IsWindowVisible(whichWindow)) do
          whichWindow := MyGetNextWindow(whichWindow);

        while (whichWindow <> NIL) and not(IsWindowVisible(whichWindow)) do
          whichWindow := MyGetNextWindow(whichWindow);

        if (whichWindow <> NIL) and (whichWindow = wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);

        if (whichWindow <> NIL) and (whichWindow = GetTooltipWindowInCloud)
          then whichWindow := MyGetNextWindow(whichWindow);

        while (whichWindow <> NIL) and not(IsWindowVisible(whichWindow)) do
          whichWindow := MyGetNextWindow(whichWindow);

        {if (whichWindow <> NIL) and (whichWindow = wPalettePtr)
          then whichWindow := MyGetNextWindow(whichWindow);}

        FrontWindowSaufPalette := whichWindow;
      end;
end;

function OrdreFenetre(whichWindow : WindowPtr) : SInt16;
const kOrdreFenetreDansLeLointain = 10000;
var windowAux : WindowPtr;
    n : SInt16;
begin
  if (whichWindow <> NIL) and WindowDeCassio(whichWindow) and
      IsWindowVisible(whichWindow) then
    begin
      n := 0;
      windowAux := FrontWindow;
      while (windowAux <> NIL) do
        begin
          if (windowAux = whichWindow) then
            begin
              OrdreFenetre := n;
              exit;
            end;
          if IsWindowVisible(windowAux) then
            inc(n);
          windowAux := MyGetNextWindow(windowAux)
        end;
    end;
  OrdreFenetre := kOrdreFenetreDansLeLointain;
end;

procedure SelectWindowSousPalette(whichWindow : WindowPtr);
var ancienneFenetreActive : WindowPtr;
begin
  if whichWindow = NIL then exit;

  if not(windowPaletteOpen) or (whichWindow = wPalettePtr)
    then
      begin
        SelectWindow(whichWindow);
        EmpileFenetresSousPalette;
      end
    else
      begin  {on doit selectionner la premiere fenetre sous la palette}
        if sousEmulatorSousPC or true
          then   {methode sale : selectionner la fenetre, puis peindre la palette dessus}
            begin
              SelectWindow(whichWindow);
              EmpileFenetresSousPalette;
            end
          else   {methode propre, mais ne marche pas sous MacEmulator 2.0 !}
            begin
              ancienneFenetreActive := FrontWindowSaufPalette;
              if ancienneFenetreActive <> whichWindow then
                begin
                  HiliteWindow(ancienneFenetreActive,false);
                  DoActivateWindow(ancienneFenetreActive,false);
                  SendBehind(whichWindow,wPalettePtr);
                end;
              HiliteWindow(whichWindow,true);
              DoActivateWindow(whichWindow,true);
            end;
       end;
  MetTitreFenetrePlateau;
end;



procedure InvalidateAllWindows;
begin
  if windowRapportOpen then InvalidateWindow(GetRapportWindow);
  if windowPlateauOpen then InvalidateWindow(wPlateauPtr);
  if windowListeOpen then InvalidateWindow(wListePtr);
  if windowGestionOpen then InvalidateWindow(wGestionPtr);
  if windowNuageOpen then InvalidateWindow(wNuagePtr);
  if windowPaletteOpen then InvalidateWindow(wPalettePtr);
  if windowStatOpen then InvalidateWindow(wStatPtr);
  if windowCourbeOpen then InvalidateWindow(wCourbePtr);
  if windowAideOpen then InvalidateWindow(wAidePtr);
  if windowReflexOpen then InvalidateWindow(wReflexPtr);
  if arbreDeJeu.windowOpen then InvalidateWindow(GetArbreDeJeuWindow);
end;


procedure EssaieSetPortWindowPlateau;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL)
    then SetPortByWindow(wPlateauPtr)
    else
      begin
        if FrontWindow <> NIL then
          if WindowDeCassio(FrontWindow) then
            SetPortByWindow(FrontWindow);
      end;
end;


procedure DessineBoiteDeTaille(whichWindow : WindowPtr);
var oldPort : grafPtr;
    unRect : rect;
    oldClipRgn : RgnHandle;
    toujoursActivee : boolean;
begin

  // les fentres suivantes n'ont pas de boite de taille dessinees

  if (whichWindow = wPalettePtr) or
     (whichWindow = iconisationDeCassio.theWindow) or
     (whichWindow = NIL) or
     ((whichWindow = wPlateauPtr) and CassioEstEn3D) or
     (whichWindow = wNuagePtr) or
     (whichWindow = GetTooltipWindowInCloud)
     then exit;

  // on dessine la boite de taille

  if WindowDeCassio(whichWindow) then
    begin
      {sysbeep(0);sysbeep(0);}
      {attendfrappeclavier;}

      GetPort(oldPort);
      SetPortByWindow(whichWindow);
      with GetWindowPortRect(whichWindow) do
        SetRect(unRect,right-15,bottom-15,right+1,bottom+1);

      if (whichWindow = wPlateauPtr) and not(gIsRunningUnderMacOSX) and false
        then
          begin
            toujoursActivee := true;
            PenPat(whitePattern);
            PenSize(1,1);
            if (whichWindow = FrontWindowSaufPalette) or toujoursActivee
              then
                begin
                  if whichWindow = wPlateauPtr then OffsetRect(unRect,-1,-1);
                  FrameRect(unRect);
                  InsetRect(unRect,1,1);
                  MyEraseRect(unRect);
                  MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
                  SetRect(unRect,unRect.right-10,unRect.bottom-10,unRect.right-1,unRect.bottom-1);
                  FrameRect(unRect);
                  SetRect(unRect,unRect.right-11,unRect.bottom-11,unRect.right-4,unRect.bottom-4);
                  MyEraseRect(unRect);
                  MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
                  FrameRect(unRect);
                end
              else
                begin
                  FrameRect(unRect);
                  InsetRect(unRect,1,1);
                  MyEraseRect(unRect);
                  MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
                end;
              PenPat(blackPattern);
          end
        else
          begin
            oldclipRgn := NewRgn;
            GetClip(oldClipRgn);
            unRect.top := unRect.top +1;
            ClipRect(unRect);
            PenPat(blackPattern);
            MyEraseRect(unRect);
            MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
            DrawGrowIcon(whichWindow);
            SetClip(oldClipRgn);
            DisposeRgn(oldclipRgn);
          end;
      SetPort(oldPort);

      {sysbeep(0);
      attendfrappeclavier;}
    end;
end;

procedure DessineBoiteAscenseurDroite(whichWindow : WindowPtr);
var oldPort : grafPtr;
    unRect : rect;
    oldClipRgn : RgnHandle;
    toujoursActivee : boolean;
begin
  toujoursActivee := true;
  if whichWindow <> NIL then
    begin
      GetPort(oldPort);
      SetPortByWindow(whichWindow);
      with GetWindowPortRect(whichWindow) do
        SetRect(unRect,right-15,top-1+hauteurRubanListe,right+1,bottom-15);


      oldclipRgn := NewRgn;
      GetClip(oldClipRgn);
      ClipRect(unRect);
      PenSize(1,1);
      PenPat(blackPattern);
      DrawGrowIcon(whichWindow);

      RGBForeColor(EclaircirCouleurDeCetteQuantite(CouleurCmdToRGBColor(NoirCmd),35000));
      Moveto(unRect.left,unRect.top);
      Lineto(unRect.right,unRect.top);
      ForeColor(BlackColor);

      SetClip(oldClipRgn);
      DisposeRgn(oldclipRgn);
      SetPort(oldPort);
    end;
end;


procedure MetTitreFenetrePlateau;
var currentTitle255 : str255;
    s,currentTitle : String255;
    largEspace,largString,i,n : SInt16;
    oldPort : grafPtr;
begin
  if windowPlateauOpen and not(Quitter) then
    begin
      GetWTitle(wPlateauPtr,currentTitle255);
      currentTitle := MyStr255ToString(currentTitle255);
      if gameOver
        then
          begin
            s := IntToStr(nbreDePions[pionNoir])+CharToString('-')+IntToStr(nbreDePions[pionBlanc]);

            if EnModeEntreeTranscript then
              begin
                if (nbreDePions[pionNoir] < nbreDePions[pionBlanc])
                  then s := IntToStr(nbreDePions[pionNoir])+CharToString('-')+IntToStr(64 - nbreDePions[pionNoir]);
                if (nbreDePions[pionNoir] > nbreDePions[pionBlanc])
                  then s := IntToStr(64 - nbreDePions[pionBlanc])+CharToString('-')+IntToStr(nbreDePions[pionBlanc]);
                if (nbreDePions[pionNoir] = nbreDePions[pionBlanc])
                  then s := '32-32';
              end;

            if not(IsWindowHilited(wPlateauPtr)) then
              if (windowListeOpen or windowStatOpen or windowRapportOpen or windowAideOpen or
                  windowGestionOpen or windowCourbeOpen or windowReflexOpen or windowNuageOpen) then
                if not(CassioEstEn3D) then
                  begin
                    GetPort(oldPort);
                    SetPortByWindow(wPlateauPtr);
                    TextFont(systemFont);
                    TextSize(0);
                    TextFace(normal);
                    largString := MyStringWidth(s);
                    largEspace := MyStringWidth(' ');
                    if gWindowsHaveThickBorders
                      then n := (GetWindowPortRect(wPlateauPtr).left+GetWindowPortRect(wPlateauPtr).right)-(aireDeJeu.left+aireDeJeu.right) + (largString)
                      else n := (GetWindowPortRect(wPlateauPtr).left+GetWindowPortRect(wPlateauPtr).right)-(aireDeJeu.left+aireDeJeu.right) + (largString);
		                {
		                WritelnNumDansRapport('n = ',n);
		                WritelnNumDansRapport('largEspace = ',largEspace);
		                }
		                if (largEspace > 0) then
		                  for i := 1 to (n div largEspace) - 8 do s := s + CharToString(' ');

                    SetPort(oldPort);
                  end;
          end
        else
          begin
            {s := ReadStringFromRessource(TitresFenetresTextID,1);}  {'Othellier'}
            if CassioEstUnBundleApplicatif
              then s := GetApplicationBundleName
              else s := GetApplicationName('Cassio');
            s := ReplaceStringOnce('.app','',s);
            if (s = 'Cassio') or (s = 'Cassio.app') or (s = '')
              then s := 'Cassio '+VersionDeCassioEnString;
          end;
      if (s <> currentTitle) then SetWTitle(wPlateauPtr,StringToStr255(s));
    end;
end;


function FiltreConfirmationFermetureFenetre(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
  FiltreConfirmationFermetureFenetre := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  with evt do
   if ((what = keyDown) or (what = autoKey)) and
      ((BAND(message,charcodemask) = EscapeKey) or
      ((BAND(message,charcodemask) = ord('.')) and (BAND(modifiers,cmdKey) <> 0)))
      then
        begin
          item := 1;
          FlashItem(dlog,item);
          FiltreConfirmationFermetureFenetre := true;
        end
      else
        FiltreConfirmationFermetureFenetre := FiltreClassique(dlog,evt,item);
end;

function VeutVraimentFermerFenetre : boolean;
const FermetureID = 143;
      Annuler = 1;
      Fermer = 3;
var itemHit : SInt16;
begin
  VeutVraimentFermerFenetre := true;

  itemHit := CautionAlertTwoButtonsFromRessource(FermetureID, 2, 0, Annuler, Fermer);
  if (itemHit = Annuler)
    then VeutVraimentFermerFenetre := false
    else VeutVraimentFermerFenetre := true;

end;


procedure DoUpdateWindowRapide(whichWindow : WindowPtr);
var oldport : grafPtr;
    visibleRgn : RgnHandle;
begin
  BeginUpdate(whichWindow);
  GetPort(oldport);
  SetPortByWindow(whichWindow);

  visibleRgn := NewRgn;
  if not(EmptyRgn(GetWindowVisibleRegion(whichWindow,visibleRgn)))
    then DrawContentsRapide(whichWindow);
  DisposeRgn(visibleRgn);

  SetPort(oldport);
  EndUpdate(whichWindow);
end;


procedure NoUpdateThisWindow(whichWindow : WindowPtr);
begin
  if whichWindow <> NIL then
    begin
      BeginUpdate(whichWindow);
      EndUpdate(whichWindow);
    end;
end;

procedure NoUpdateWindowPlateau;
begin
  if windowPlateauOpen then
    NoUpdateThisWindow(wPlateauPtr);
end;

procedure NoUpdateWindowListe;
begin
  if windowListeOpen then
    NoUpdateThisWindow(wListePtr);
end;


procedure DoGlobalRefresh;
var oldport : grafPtr;
begin
  if globalRefreshNeeded then
    begin
      GetPort(oldport);
      if windowListeOpen then
        begin
          SetPortByWindow(wListePtr);
          InvalRect(QDGetPortBound);
        end;
      if windowStatOpen then
        begin
          SetPortByWindow(wStatPtr);
          InvalRect(QDGetPortBound);
        end;
      if FenetreRapportEstOuverte then
        begin
          SetPortByWindow(GetRapportWindow);
          InvalRect(QDGetPortBound);
        end;
      if arbreDeJeu.windowOpen then
        begin
          SetPortByWindow(GetArbreDeJeuWindow);
          InvalRect(QDGetPortBound);
        end;
      SetPort(oldport);
      globalRefreshNeeded := false;
    end;
end;


procedure DrawContentsRapide(whichWindow : WindowPtr);
var visibleRgn : RgnHandle;
begin
  if whichWindow = wPlateauPtr
    then
      begin
        if enRetour
          then
            begin
              visibleRgn := NewRgn;
              DessineRetour(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),'DrawContentsRapide');
              DisposeRgn(visibleRgn);
            end
          else
            if not(enSetUp) then
              begin
                visibleRgn := NewRgn;
                EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),false);
                DisposeRgn(visibleRgn);
              end;
      end
    else
      if whichWindow = wCourbePtr
        then
          begin
            DessineCourbe(kCourbeColoree,'DrawContentsRapide');
            DessineSliderFenetreCourbe;
          end
        else
          if whichWindow = wGestionPtr
          then EcritGestionTemps
          else
          if whichWindow = wNuagePtr
          then DessineNuage('DrawContentsRapide')
          else
            if whichWindow = wReflexPtr
            then EcritReflexion('DrawContentsRapide')
            else
              if whichWindow = wListePtr
              then
                begin
                  EcritRubanListe(true);
                  if IsWindowHilited(wListePtr)
					          then MontrerAscenseurListe
					          else CacherAscenseurListe;
                  globalRefreshNeeded := true;
                end
              else
                if whichWindow = wStatPtr
                  then
                    begin
                      EcritRubanStatistiques;
                      globalRefreshNeeded := true;
                    end
                  else
                    if EstLaFenetreDuRapport(whichWindow)
                      then
                        begin
                          TEUpdate(GetWindowPortRect(GetRapportWindow), GetTextEditRecordOfRapport);
                          DrawControls(GetRapportWindow);
                        end
                      else
                        if whichWindow = iconisationDeCassio.theWindow
                          then
                            begin
                              globalRefreshNeeded := true;
                            end
                          else
                            if whichWindow = GetArbreDeJeuWindow
                              then
                                begin
                                  DessineZoneDeTexteDansFenetreArbreDeJeu(false);
                                  {globalRefreshNeeded := true;}
                                end
                              else
                                if whichWindow = wAidePtr
                                  then DessineAide(gAideCourante)
                                  else
                                    if whichWindow = wPalettePtr
                                      then DessinePalette;
  DessineBoiteDeTaille(whichWindow);
end;



END.









































































