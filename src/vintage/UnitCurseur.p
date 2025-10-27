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
		  if (LastMousePositionInAjusteCurseur.h <> mouseLoc.h) or
		     (LastMousePositionInAjusteCurseur.v <> mouseLoc.v)
		    then
  		    begin {2}
  		      { la souris vient de bouger }
  		      LastMousePositionInAjusteCurseur := mouseLoc;
  		      if (nbreCoup <= 0) and CassioEstEnTrainDeCalculerPourLeZoo and not(inBackGround)
  		        then AccelereProchainDoSystemTask(4)
  		        else AccelereProchainDoSystemTask(60);
  		      DiminueLatenceEntreDeuxDoSystemTask;
  		      {WritelnDansRapport('AjusteCurseur :   delaiAvantDoSystemTask = '+IntToStr(delaiAvantDoSystemTask));}
  		    end {2}
  		  else
  		    begin
  		      { la souris est immobile }
  		      if (gDernierEtatAjusteCurseur.option       = DernierEvenement.option) and
  		         (gDernierEtatAjusteCurseur.command      = DernierEvenement.command) and
  		         (gDernierEtatAjusteCurseur.shift        = DernierEvenement.shift) and
  		         (gDernierEtatAjusteCurseur.control      = DernierEvenement.control) and
  		         (gDernierEtatAjusteCurseur.verouillage  = DernierEvenement.verouillage) and
  		         (gDernierEtatAjusteCurseur.numeroCoup   = nbreCoup) and
  		         (gDernierEtatAjusteCurseur.dateKeyboard = DateOfLastKeyboardOperation)
  		         then goto sortie;
  		    end;


		  if not(inBackGround) then
		    begin {2}
		      localFrontWindow := FrontWindow;

  		    if WindowDeCassio(localFrontWindow) or (localFrontWindow = NIL)
  		      then
  		        begin {3}

  		          if Quitter then
		              begin {4}
		                InitCursor;
		                goto sortie;
		              end; {4}

                if enSetUp and not(iconisationDeCassio.encours) then
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

                if windowCourbeOpen and (wCourbePtr <> NIL) and (wCourbePtr = localFrontWindowSaufPalette) then
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

                if enSetUp or iconisationDeCassio.encours or enRetour then
                  begin {4}
                    InitCursor;
                    goto sortie;
                  end; {4}

                if windowPaletteOpen and (wPalettePtr <> NIL) and (wPalettePtr = localFrontWindow) then
                  begin {4}
                    unRect := GetWindowStructRect(wPalettePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        InitCursor;
                        goto sortie;
                      end; {5}
                  end; {4}

                if windowListeOpen and (wListePtr <> NIL) and (wListePtr = localFrontWindowSaufPalette)  then
                  begin {4}
                    unRect := GetWindowContentRect(wListePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wListePtr);
                        GlobalToLocal(mouseLoc);

                        if {(nbPartiesChargees > 0) and}
                           (((SousCriteresRuban[TournoiRubanBox]      <> NIL) and PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[TournoiRubanBox]))) or
                            ((SousCriteresRuban[JoueurNoirRubanBox]   <> NIL) and PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurNoirRubanBox]))) or
                            ((SousCriteresRuban[JoueurBlancRubanBox]  <> NIL) and PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[JoueurBlancRubanBox]))) or
                            ((SousCriteresRuban[DistributionRubanBox] <> NIL) and PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[DistributionRubanBox]))))
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
                                   if (nbPartiesActives > 0) or gameOver
                                     then InitCursor
                                     else SafeSetCursor(CurseurPourLaCouleurActive);
                                 end;
                        goto sortie;
                      end; {5}
                  end; {4}


                if windowStatOpen and (wStatPtr <> NIL) and (wStatPtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wStatPtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByWindow(wStatPtr);
                        GlobalToLocal(mouseLoc);
                        if (mouseLoc.v < hauteurRubanStatistiques) and (nbreCoup > 0)
                          then
                            begin {6}
                              //backMoveCurseur := GetCursor(backMoveCurseurID);
                              backMoveCurseur := GetCursor(interversionCursorID);
                              SafeSetCursor(backMoveCurseur);
                            end {6}
                          else
                        if (nbPartiesActives > 0) and not(gameOver) and (statistiques <> NIL) and
                           (mouseLoc.v <= hauteurRubanStatistiques+hauteurChaqueLigneStatistique*statistiques^^.nbreponsesTrouvees + 3) and
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

                if windowAideOpen and (wAidePtr <> NIL) and (wAidePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wAidePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                  end; {4}

                if windowNuageOpen and (wNuagePtr <> NIL) and (wNuagePtr = localFrontWindowSaufPalette) then
                  begin {4}
                    unRect := GetWindowContentRect(wNuagePtr);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        if TraiteCurseurSeBalladantSurLaFenetreDuNuage(mouseLoc)
                          then goto sortie;
                      end; {5}
                  end; {4}

                if arbreDeJeu.windowOpen and (GetArbreDeJeuWindow <> NIL) and (GetArbreDeJeuWindow = localFrontWindowSaufPalette) then
                  with arbreDeJeu do
                  begin {4}
                    unRect := GetWindowContentRect(GetArbreDeJeuWindow);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        SetPortByDialog(arbreDeJeu.theDialog);
                        if (mouseLoc.h >= unRect.right - 15) and (mouseLoc.v >= unRect.bottom - 15)
                          then
                            begin {6}
                              InitCursor;
                              goto sortie;
                            end; {6}
                        GlobalToLocal(mouseLoc);
                        if enModeEdition and PtInRect(mouseLoc,editionRect)
                          then
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                              goto sortie;
                            end {6}
                          else
                            begin {6}
                              if avecInterversions and
                                 SurIconeInterversion(mouseLoc,whichNode) and not(Button) then
                                begin {7}
                                  EcrireInterversionsDuGrapheCeNoeudDansRapport(whichNode);
                                  if (whichNode = GetCurrentNode) then
                                    begin {8}
                                      interversionCurseur := GetCursor(interversionCursorID);
                                      SafeSetCursor(interversionCurseur);
                                      goto sortie;
                                    end; {8}
                                end; {7}
                              if PtInRect(mouseLoc,backMoveRect) and (nbreCoup > 0) and (not(enModeEdition) or doitResterEnModeEdition)
	                              then
	                                begin {7}
	                                  //backMoveCurseur := GetCursor(backMoveCurseurID);
	                                  backMoveCurseur := GetCursor(interversionCursorID);
	                                  SafeSetCursor(backMoveCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v > EditionRect.top-12) and (mouseLoc.v < EditionRect.top)
	                              then
                                  begin {7}
	                                  DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);
	                                  SafeSetCursor(DragLineHorizontalCurseur);
	                                  goto sortie;
	                                end {7}
	                              else
	                            if (mouseLoc.v >= backMoveRect.bottom) and (mouseLoc.v <= EditionRect.top-12) and
	                               (NbDeFilsOfCurrentNode >= 1) and
	                               (((mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu) <= NbDeFilsOfCurrentNode+1) and (not(enModeEdition) or doitResterEnModeEdition)
                                then
	                                begin {7}
	                                  if (DernierEvenement.shift or DernierEvenement.command or DernierEvenement.option) and (NbDeFilsOfCurrentNode > 1)
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

                if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan then
                  begin {4}
                    unRect := GetWindowContentRect(GetRapportWindow);
                    if PtInRect(mouseLoc,unRect) then
                      begin {5}
                        unRect.right := unRect.right-15;
                        unRect.bottom := unRect.bottom-15;
                        if EnTraitementDeTexte and PtInRect(mouseLoc,unRect)
                          then
                            begin {6}
                              iBeam := GetCursor(iBeamCursor);
                              SafeSetCursor(iBeam);
                            end {6}
                          else
                            begin
                              if gameOver or SelectionRapportNonVide
                                then InitCursor
                                else SafeSetCursor(CurseurPourLaCouleurActive);
                            end;
                        goto sortie;
                      end; {5}
                  end; {4}


                if windowPlateauOpen and (wPlateauPtr <> NIL) then
                  begin {4}
                    if PtInRect(mouseLoc,gHorlogeRectGlobal) and not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if PtInRect(mouseLoc,GetRectEscargotGlobal) and not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if (GetMeilleureSuite <> '') and PtInRect(mouseLoc,GetMeilleureSuiteRectGlobal) and not(EnModeEntreeTranscript) then
                      begin {5}
                        SafeSetCursor(GetCursor(DigitCurseurID));
                        goto sortie;
                      end; {5}
                    if (DernierEvenement.control or DernierEvenement.option) then
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
                                    if DernierEvenement.option or DernierEvenement.command then
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
                                    if (mouseLoc.h >= GetWindowContentRect(wPlateauPtr).right-16) and
                                       (mouseLoc.v >= GetWindowContentRect(wPlateauPtr).bottom-16)
                                      then InitCursor
                                      else SafeSetCursor(GetCursor(DigitCurseurID));
                                    goto sortie;
                                  end; {7}
                              LocalToGlobal(mouseLoc);
                            end; {6}
                      end; {5}
                  end; {4}


                if EnModeEntreeTranscript and (NombreSuggestionsAffichees >= 1) then
                  if windowPlateauOpen and (wPlateauPtr <> NIL) then
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
