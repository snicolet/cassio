UNIT UnitRapportWindow;


INTERFACE


 USES QuickDraw , MacWindows , UnitDefCassio;


{fonctions de tests}
function EstLaFenetreDuRapport(whichWindow : WindowPtr) : boolean;                                                                                                                  ATTRIBUTE_NAME('EstLaFenetreDuRapport')
function FenetreRapportEstAuPremierPlan : boolean;                                                                                                                                  ATTRIBUTE_NAME('FenetreRapportEstAuPremierPlan')


procedure OuvreFntrRapport(avecAnimationZoom,forceSelectWindow : boolean);                                                                                                          ATTRIBUTE_NAME('OuvreFntrRapport')
procedure CloseRapportWindow;                                                                                                                                                       ATTRIBUTE_NAME('CloseRapportWindow')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitRapportTypes
{$IFC NOT(USE_PRELINK)}
    , UnitFenetres, UnitRapportImplementation, UnitCarbonisation ;
{$ELSEC}
    ;
    {$I prelink/RapportWindow.lk}
{$ENDC}


{END_USE_CLAUSE}











function EstLaFenetreDuRapport(whichWindow : WindowPtr) : boolean;
begin
  EstLaFenetreDuRapport := (whichWindow <> NIL) & (whichWindow = rapport.theWindow);
end;


function FenetreRapportEstAuPremierPlan : boolean;
begin
  FenetreRapportEstAuPremierPlan := (rapport.theWindow = FrontWindowSaufPalette);
end;


procedure OuvreFntrRapport(avecAnimationZoom,forceSelectWindow : boolean);
var rect1,rect2 : rect;
begin {$unused avecAnimationZoom}
  DeactivateFrontWindowSaufPalette;
  SetRect(rect1,ecranRect.right-29,2,ecranRect.right-13,18);
  rect2 := FntrRapportRect;
  rect2.top := rect2.top-18;
  InsetRect(rect2,-2,-2);

  ShowHide(rapport.theWindow,true);
  DoActivateRapport;

  windowRapportOpen := true;
  if windowPaletteOpen & (wPalettePtr <> NIL)
    then
      begin
        SendBehind(Rapport.theWindow,wPalettePtr);
        EmpileFenetresSousPalette;
      end
    else
      begin
        if forceSelectWindow then SelectWindow(Rapport.theWindow);
        EmpileFenetres;
        if forceSelectWindow then SelectWindow(Rapport.theWindow);
      end;

  UpdateScrollersRapport;
end;

procedure CloseRapportWindow;
begin
  SetPortByWindow(rapport.theWindow);
  FntrRapportRect := GetWindowPortRect(rapport.theWindow);
  LocalToGlobal(FntrRapportRect.topleft);
  LocalToGlobal(FntrRapportRect.botright);
  DoDeactivateRapport;
  HideWindow(rapport.theWindow);
  SetRect(CloseZoomRectTo,ecranRect.right-29,2,ecranRect.right-13,18);
  CloseZoomRectFrom := FntrRapportRect;
  CloseZoomRectFrom.top := CloseZoomRectFrom.top-18;
  InsetRect(CloseZoomRectFrom,-2,-2);
  windowRapportOpen := false;
  EssaieSetPortWindowPlateau;
  EmpileFenetresSousPalette;
end;


END.
