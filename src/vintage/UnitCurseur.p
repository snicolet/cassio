UNIT UnitCurseur;



INTERFACE


 USES UnitDefCassio;

{fonctions general de manipulation du curseur de Cassio}
procedure AjusteCurseur;
procedure RemettreLeCurseurNormalDeCassio;
procedure BeginCurseurSpecial(whichCursor : CursHandle);
procedure EndCurseurSpecial;


{fonctions de gestion du curseur Tete-de-Mort}
function CurseurEstEnTeteDeMort : boolean;
procedure DecrementeNiveauCurseurTeteDeMort;
procedure SetNiveauTeteDeMort(niveau : SInt16);


{fonctions speciales permettant d'inverser les couleurs du curseur}
function CurseurPourLaCouleurActive : CursHandle;
function InverserLesCouleursDuCurseur : boolean;
procedure SetInverserLesCouleursDuCurseur(flag : boolean);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickDraw, MacWindows
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, MyMathUtils, UnitCarbonisation, UnitGeometrie, UnitRegressionLineaire, UnitFenetres
    , UnitRapportWindow, UnitGestionDuTemps, UnitCourbe, UnitAffichageArbreDeJeu, UnitInterversions, UnitArbreDeJeuCourant, UnitServicesRapport, UnitRapportImplementation
    , UnitEntreeTranscript, UnitAffichagePlateau, UnitNormalisation, UnitRapport, MyStrings, UnitZoo, UnitTroisiemeDimension, UnitAffichageReflexion
    , UnitEvenement, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/Curseur.lk}
{$ENDC}


{END_USE_CLAUSE}



var gInversionDuCurseur : boolean;


function CurseurEstEnTeteDeMort : boolean;
begin
  CurseurEstEnTeteDeMort := (enTeteDeMort > 0);
end;

procedure DecrementeNiveauCurseurTeteDeMort;
begin
  enTeteDeMort := Max(0,enTeteDeMort-1);
end;

procedure SetNiveauTeteDeMort(niveau : SInt16);
begin
  enTeteDeMort := niveau;
end;

function InverserLesCouleursDuCurseur : boolean;
begin
  InverserLesCouleursDuCurseur := gInversionDuCurseur;
end;

procedure SetInverserLesCouleursDuCurseur(flag : boolean);
begin
  gInversionDuCurseur := flag;
end;

function CurseurPourLaCouleurActive : CursHandle;
begin
  if InverserLesCouleursDuCurseur
    then
      if (AQuiDeJouer = pionBlanc)
        then CurseurPourLaCouleurActive := pionNoirCurseur
        else CurseurPourLaCouleurActive := pionBlancCurseur
    else
      if (AQuiDeJouer = pionBlanc)
        then CurseurPourLaCouleurActive := pionBlancCurseur
        else CurseurPourLaCouleurActive := pionNoirCurseur;
end;


procedure AjusteCurseur;
var mouseLoc : Point;
    unRect : rect;
    oldPort : grafPtr;
    whichSquare,numeroDuCoup : SInt16;
    whichNode : GameTree;
    localFrontWindow : WindowPtr;
    localFrontWindowSaufPalette : WindowPtr;
label sortie;
begin {AjusteCurseur}

  if doitAjusterCurseur then
    begin {1}
      GetPort(oldPort);
      EssaieSetPortWindowPlateau;

		  GetMouse(mouseLoc);
		  if (LastMousePositionInAjusteCurseur.h <> mouseLoc.h) |
		     (LastMousePositionInAjusteCurseur.v <> mouseLoc.v)
		    then
  		    begin {2}
  		      { la souris vient de bouger }
  		      LastMousePositionInAjusteCurseur := mouseLoc;
  		      if (nbreCoup <= 0) & CassioEstEnTrainDeCalculerPourLeZoo & not(inBackGround)
  		        then AccelereProchainDoSystemTask(4)
  		        else AccelereProchainDoSystemTask(60);
  		      DiminueLatenceEntreDeuxDoSystemTask;
  		      {WritelnDansRapport('AjusteCurseur :   delaiAvantDoSystemTask = '+NumEnString(delaiAvantDoSystemTask));}
  		    end {2}
  		  else
  		    begin
  		      { la souris est immobile }
  		      if (gDernierEtatAjusteCurseur.option       = DernierEvenement.option) &
  		         (gDernierEtatAjusteCurseur.command      = DernierEvenement.command) &
  		         (gDernierEtatAjusteCurseur.shift        = DernierEvenement.shift) &
  		         (gDernierEtatAjusteCurseur.control      = DernierEvenement.control) &
  		         (gDernierEtatAjusteCurseur.verouillage  = DernierEvenement.verouillage) &
  		         (gDernierEtatAjusteCurseur.numeroCoup   = nbreCoup) &
  		         (gDernierEtatAjusteCurseur.dateKeyboard = DateOfLastKeyboardOperation)
  		         then goto sortie;
  		    end;


		  if not(inBackGround) then
		    begin {2}
		      localFrontWindow := FrontWindow;

  		    if WindowDeCassio(localFrontWindow) | (localFrontWindow = NIL)
  		      then
  		        begin {3}

  		          if Quitter then
		              begin {4}
		                InitCursor;
		                goto sortie;
		              end; {4}

                if enSetUp & not(iconisationDeCassio.encours) then
                  begin {4}
                    case couleurEnCoursPourSetUp of
                      pionNoir  : SafeSetCursor(pionNoirCurseur);
                      pionBlanc : SafeSetCursor(pionBlancCurseur);
                      pionVide  : SafeSetCursor(gommeCurseur);
                      otherwise   InitCursor;
                    end; {case}
                    goto sortie;
                  end; {4}

                if CurseurEstEnTeteDeMort then
                  begin {4}
                    teteDeMortCurseur := GetCursor(teteDeMortCursorID);
                    SafeSetCursor(teteDeMortCurseur);
                    goto sortie;
                  end; {4}

                LocalToGlobal(mouseLoc);

                localFrontWindowSaufPalette := FrontWindowSaufPalette;

                if windowCourbeOpen & (wCourbePtr <> NIL) & (wCourbePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wCourbePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        if TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseLoc)
                          then DoNothing
                          else
                            begin
                              if gameOver
                                then InitCursor
                                else SafeSetCursor(CurseurPourLaCouleurActive);
                            end;
                        goto sortie;
                      end; {5}
                  end; {4}

                if enSetUp | iconisationDeCassio.encours | enRetour then
                  begin {4}
                    InitCursor;
                    goto sortie;
                  end; {4}

                if windowPaletteOpen & (wPalettePtr <> NIL) & (wPalettePtr = localFrontWindow) then
                  begin {4}
                    unRect := GetWindowStructRect(wPalettePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}

                if windowListeOpen & (wListePtr <> NIL) & (wListePtr = localFrontWindowSaufPalette)  then
                  begin {4}
                    unRect := GetWindowContentRect(wListePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wListePtr);
                        GlobalToLocal(mouseLoc);

                        if {(nbPartiesChargees > 0) &}
                           (((SousCriteresRuban[TournoiRubanBox]      <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[TournoiRubanBox]))) |
                            ((SousCriteresRuban[JoueurNoirRubanBox]   <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurNoirRubanBox]))) |
                            ((SousCriteresRuban[JoueurBlancRubanBox]  <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurBlancRubanBox]))) |
                            ((SousCriteresRuban[DistributionRubanBox] <> NIL) & PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[DistributionRubanBox]))))
                           then
                             begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                             end {6}
                           else
                             if (mouseLoc.v <= hauteurRubanListe - 3)
                               then SafeSetCursor(GetCursor(DigitCurseurID))
                               else
                                 begin
                                   if (nbPartiesActives > 0) | gameOver
                                     then InitCursor
                                     else SafeSetCursor(CurseurPourLaCouleurActive);
                                 end;
                        goto sortie;
                      end; {5}
                  end; {4}


                if windowStatOpen & (wStatPtr <> NIL) & (wStatPtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wStatPtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wStatPtr);
                        GlobalToLocal(mouseLoc);
                        if (mouseLoc.v < hauteurRubanStatistiques) & (nbreCoup > 0)
                          then
                            begin {6}
                              //backMoveCurseur := GetCursor(backMoveCurseurID);
                              backMoveCurseur := GetCursor(interversionCursorID);
                              SafeSetCursor(backMoveCurseur);
                            end {6}
                          else
                        if (nbPartiesActives > 0) & not(gameOver) & (statistiques <> NIL) &
                           (mouseLoc.v <= hauteurRubanStatistiques+hauteurChaqueLigneStatistique*statistiques^^.nbreponsesTrouvees + 3) &
                           (mouseLoc.v >= hauteurRubanStatistiques)
                          then
                            begin {6}
                              //avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
                              avanceMoveCurseur := GetCursor(interversionCursorID);
                              SafeSetCursor(avanceMoveCurseur);
                            end {6}
                          else
                            InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}

                if windowAideOpen & (wAidePtr <> NIL) & (wAidePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wAidePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                  end; {4}

                if windowNuageOpen & (wNuagePtr <> NIL) & (wNuagePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wNuagePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        if TraiteCurseurSeBalladantSurLaFenetreDuNuage(mouseLoc)
                          then goto sortie;
                      end; {5}
                  end; {4}

                if arbreDeJeu.windowOpen & (GetArbreDeJeuWindow <> NIL) & (GetArbreDeJeuWindow = localFrontWindowSaufPalette) then
                  with arbreDeJeu do
                  begin {4}
                    unRect := GetWindowContentRect(GetArbreDeJeuWindow);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByDialog(arbreDeJeu.theDialog);
                        if (mouseLoc.h >= unRect.right - 15) & (mouseLoc.v >= unRect.bottom - 15)
                          then
                            begin {6}
                              InitCursor;
                              goto sortie;
                            end; {6}
                        GlobalToLocal(mouseLoc);
                        if enModeEdition & PtInRect(mouseLoc,editionRect)
                          then
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                              goto sortie;
                            end {6}
                          else
                            begin {6}
                              if avecInterversions &
                                 SurIconeInterversion(mouseLoc,whichNode) & not(Button) then
                                begin {7}
                                  EcrireInterversionsDuGrapheCeNoeudDansRapport(whichNode);
                                  if (whichNode = GetCurrentNode) then
                                    begin {8}
                                      interversionCurseur := GetCursor(interversionCursorID);
                                      SafeSetCursor(interversionCurseur);
                                      goto sortie;
                                    end; {8}
                                end; {7}
                              if PtInRect(mouseLoc,backMoveRect) & (nbreCoup > 0) & (not(enModeEdition) | doitResterEnModeEdition)
	                              then
	                                begin {7}
	                                  //backMoveCurseur := GetCursor(backMoveCurseurID);
	                                  backMoveCurseur := GetCursor(interversionCursorID);
	                                  SafeSetCursor(backMoveCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v > EditionRect.top-12) & (mouseLoc.v < EditionRect.top)
	                              then
                                  begin {7}
	                                  DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
	                                  SafeSetCursor(DragLineHorizontalCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v >= backMoveRect.bottom) & (mouseLoc.v <= EditionRect.top-12) &
	                               (NbDeFilsOfCurrentNode >= 1) &
	                               (((mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu) <= NbDeFilsOfCurrentNode+1) & (not(enModeEdition) | doitResterEnModeEdition)
                                then
	                                begin {7}
	                                  if (DernierEvenement.shift | DernierEvenement.command | DernierEvenement.option) & (NbDeFilsOfCurrentNode > 1)
	                                    then
	                                      begin {8}
	                                        DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
	                                        SafeSetCursor(DragLineHorizontalCurseur);
	                                        goto sortie;
	                                      end {8}
	                                    else
	                                      begin {8}
	                                        //avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
	                                        avanceMoveCurseur := GetCursor(interversionCursorID);
	                                        SafeSetCursor(avanceMoveCurseur);
	                                        goto sortie;
	                                      end; {8}
	                                end {7}
	                              else
	                                InitCursor;
	                          end; {6}
                        goto sortie;
                      end; {5}
                  end; {4}

                if FenetreRapportEstOuverte & FenetreRapportEstAuPremierPlan then
                  begin {4}
                    unRect := GetWindowContentRect(GetRapportWindow);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        unRect.right := unRect.right-15;
                        unRect.bottom := unRect.bottom-15;
                        if EnTraitementDeTexte & PtInRect(mouseLoc,unRect)
                          then
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                            end {6}
                          else
                            begin
                              if gameOver | SelectionRapportNonVide
                                then InitCursor
                                else SafeSetCursor(CurseurPourLaCouleurActive);
                            end;
                        goto sortie;
                      end; {5}
                  end; {4}


                if windowPlateauOpen & (wPlateauPtr <> NIL) then
                  begin {4}
                    if PtInRect(mouseLoc,gHorlogeRectGlobal) & not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if PtInRect(mouseLoc,GetRectEscargotGlobal) & not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if (GetMeilleureSuite <> '') & PtInRect(mouseLoc,GetMeilleureSuiteRectGlobal) & not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if (DernierEvenement.control | DernierEvenement.option) then
                      begin {5}
                        unRect := GetWindowContentRect(wPlateauPtr);
                        if PtInRect(mouseLoc,unRect)
                          then
                            begin {6}
                              SetPortByWindow(wPlateauPtr);
                              GlobalToLocal(mouseLoc);
                              if PtInPlateau(mouseLoc,whichSquare)
                                then
                                  begin {7}
                                    if DernierEvenement.control   then
                                      {on prepare pour le menu des pierres delta}
                                      begin {8}
                                        InitCursor;
                                        goto sortie;
                                      end; {8}
                                    if DernierEvenement.option | DernierEvenement.command then
                                      {on prepare pour avancer/reculer}
                                      if TrouveCoupDansPartieCourante(whichSquare,numeroDuCoup) then
                                        begin {8}
    	                                    if numeroDuCoup < nbreCoup  then
                                            begin {9}
    				                                  backMoveCurseur := GetCursor(backMoveCurseurID);
    	                                        SafeSetCursor(backMoveCurseur);
    				                                  goto sortie;
    				                                end; {9}
    				                              if numeroDuCoup > nbreCoup then
                                            begin {9}
    				                                  avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
    				                                  SafeSetCursor(avanceMoveCurseur);
    				                                  goto sortie;
    				                                end; {9}
    	                                  end; {8}
                                  end {7}
                                else
                                  begin {7}
                                    LocalToGlobal(mouseLoc);
                                    if (mouseLoc.h >= GetWindowContentRect(wPlateauPtr).right-16) &
                                       (mouseLoc.v >= GetWindowContentRect(wPlateauPtr).bottom-16)
                                      then InitCursor
                                      else SafeSetCursor(GetCursor(DigitCurseurID));
                                    goto sortie;
                                  end; {7}
                              LocalToGlobal(mouseLoc);
                            end; {6}
                      end; {5}
                  end; {4}


                if EnModeEntreeTranscript & (NombreSuggestionsAffichees >= 1) then
                  if windowPlateauOpen & (wPlateauPtr <> NIL) then
                    begin {4}
                      unRect := GetWindowContentRect(wPlateauPtr);
                      if PtInRect(mouseLoc,unRect) then
                        begin {5}
                          SetPortByWindow(wPlateauPtr);
                          GlobalToLocal(mouseLoc);
                          if (mouseLoc.v > (aireDeJeu.bottom + EpaisseurBordureOthellier + 4)) then
                            begin {6}
                              InitCursor;
                              goto sortie;
		                        end; {6}
		                      LocalToGlobal(mouseLoc);
		                    end; {5}
                    end; {4}

                if gameOver
                  then InitCursor
                  else SafeSetCursor(CurseurPourLaCouleurActive);

		          end; {3}

		    end; {2}

		 sortie :


		   gDernierEtatAjusteCurseur.option       := DernierEvenement.option;
  		 gDernierEtatAjusteCurseur.command      := DernierEvenement.command;
  		 gDernierEtatAjusteCurseur.shift        := DernierEvenement.shift;
  		 gDernierEtatAjusteCurseur.control      := DernierEvenement.control;
  		 gDernierEtatAjusteCurseur.verouillage  := DernierEvenement.verouillage;
  		 gDernierEtatAjusteCurseur.numeroCoup   := nbreCoup;
  		 gDernierEtatAjusteCurseur.dateKeyboard := DateOfLastKeyboardOperation;


		   SetPort(oldPort);

	 end; {1}

end;


procedure RemettreLeCurseurNormalDeCassio;
begin
  doitAjusterCurseur := true;
  LastMousePositionInAjusteCurseur.h := -4333;
  LastMousePositionInAjusteCurseur.v := -4333;
  InvalidatePositionSourisFntreCourbe;
  AjusteCurseur;
end;


procedure BeginCurseurSpecial(whichCursor : CursHandle);
begin
  SafeSetCursor(whichCursor);
  doitAjusterCurseur := false;
end;


procedure EndCurseurSpecial;
begin
  doitAjusterCurseur := true;
  AjusteCurseur;
end;


END.
