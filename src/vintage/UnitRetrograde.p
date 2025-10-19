UNIT UnitRetrograde;


INTERFACE







USES UnitDefCassio;


procedure InitUnitRetrograde;                                                                                                                                                       ATTRIBUTE_NAME('InitUnitRetrograde')
procedure DoAnalyseRetrograde(limiteAnalyseRetro : SInt32);                                                                                                                         ATTRIBUTE_NAME('DoAnalyseRetrograde')
function DoDialogueRetrograde(seulementParametrage : boolean) : boolean;                                                                                                            ATTRIBUTE_NAME('DoDialogueRetrograde')

function EstDansBanniereAnalyseRetrograde(positionClic : SInt32) : boolean;                                                                                                         ATTRIBUTE_NAME('EstDansBanniereAnalyseRetrograde')
procedure SelectionneAnalyseRetrograde(positionClic : SInt32);                                                                                                                      ATTRIBUTE_NAME('SelectionneAnalyseRetrograde')


function AnalyseRetrogradeEnCours : boolean;                                                                                                                                        ATTRIBUTE_NAME('AnalyseRetrogradeEnCours')
function PeutArreterAnalyseRetrograde : boolean;                                                                                                                                    ATTRIBUTE_NAME('PeutArreterAnalyseRetrograde')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, MacWindows
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitRapport, UnitFinaleFast, UnitSuperviseur, UnitPhasesPartie
    , UnitServicesDialogs, UnitSolve, UnitIconisation, MyMemory, UnitJeu, UnitMilieuDePartie, UnitAffichageArbreDeJeu, UnitHashTableExacte
    , UnitBallade, UnitListe, UnitServicesRapport, UnitRapportImplementation, UnitCarbonisation, UnitUtilitaires, UnitArbreDeJeuCourant, UnitAffichageReflexion
    , UnitJaponais, UnitMenus, UnitGestionDuTemps, UnitDialog, UnitOth2, UnitScannerUtils, MyStrings, UnitCourbe, UnitZoo
    , UnitFenetres, UnitNormalisation, UnitSetUp, SNMenus, UnitGeometrie, MyMathUtils, UnitRapportWindow, UnitPressePapier
    , UnitAffichagePlateau, UnitPalette, UnitGameTree, UnitProperties, UnitServicesMemoire, UnitActions, UnitEngine, UnitPositionEtTrait
     ;
{$ELSEC}
    ;
    {$I prelink/Retrograde.lk}
{$ENDC}


{END_USE_CLAUSE}








var menuAnalyse : array[1..nbMaxDePassesAnalyseRetrograde,1..nbMaxDeStagesAnalyseRetrograde] of MenuFlottantRec;
    menuDuree : array[1..nbMaxDePassesAnalyseRetrograde,1..nbMaxDeStagesAnalyseRetrograde] of MenuFlottantRec;
    menuProfondeur : array[1..nbMaxDePassesAnalyseRetrograde,1..nbMaxDeStagesAnalyseRetrograde] of MenuFlottantRec;
    menuNbNotesMilieu : array[1..nbMaxDePassesAnalyseRetrograde,1..nbMaxDeStagesAnalyseRetrograde] of MenuFlottantRec;
    changementsMenusRetrograde : array[0..nbMaxDePassesAnalyseRetrograde,0..nbMaxDeStagesAnalyseRetrograde] of boolean;
    dialogueAnalyseRetrograde : DialogPtr;
    coupMaxPossiblePourFinale : SInt32;



procedure CalculeBornesAnalyseRetrograde(nroPasse,nroStage,whichMoveNumber : SInt32);
var t : SInt32;
begin
  if (nroPasse >= 1) & (nroPasse <= nbMaxDePassesAnalyseRetrograde) &
     (nroStage >= 1) & (nroStage <= nbMaxDeStagesAnalyseRetrograde) then
    with analyseRetrograde do
      begin
        numeroPasse := nroPasse;
        numeroStage := nroStage;
        if (nroStage = 1) then
          tickDebutCettePasseAnalyse := TickCount;
        tickDebutCeStageAnalyse := TickCount;
        if (nroStage = 1) & (nroPasse = 1) then
          tickDebutAnalyse := TickCount;

        case menuItems[nroPasse,nroStage,kMenuGenre] of
          RetrogradeParfaiteCmd,RetrogradeGagnanteCmd:
            begin
              tempsMaximumCettePasse := 1000000000;        {1000000000 sec = 11570 jours = 31,6 ans}
              if menuItems[nroPasse,nroStage,kMenuGenre] = RetrogradeParfaiteCmd
                then genreAnalyseEnCours := ReflRetrogradeParfait
                else genreAnalyseEnCours := ReflRetrogradeGagnant;
              case menuItems[nroPasse,nroStage,kMenuDuree] of
                Pendant1MinCmd:
                  begin
                    tempsMaximumCeStage := 60;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant2MinCmd:
                  begin
                    tempsMaximumCeStage := 120;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant5MinCmd:
                  begin
                    tempsMaximumCeStage := 300;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant10MinCmd:
                  begin
                    tempsMaximumCeStage := 600;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant30MinCmd:
                  begin
                    tempsMaximumCeStage := 1800;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant1HeureCmd:
                  begin
                    tempsMaximumCeStage := 3600;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant2HeuresCmd:
                  begin
                    tempsMaximumCeStage := 7200;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant6HeuresCmd:
                  begin
                    tempsMaximumCeStage := 21600;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Pendant12HeuresCmd:
                  begin
                    tempsMaximumCeStage := 43200;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Jusque45Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;  {1000000000 sec = 11570 jours = 31,6 ans}
                    for t := whichMoveNumber downto 44 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Jusque40Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 39 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Jusque35Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 34 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Jusque30Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 29 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        Jusque25Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 24 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
                Jusque20Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 19 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
                Jusque15Cmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto 14 do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
				        FinDesTempsCmd:
                  begin
                    tempsMaximumCeStage := 1000000000;
                    for t := whichMoveNumber downto coupMaxPossiblePourFinale do
                      begin
                        demande[t,nroPasse].genre              := genreAnalyseEnCours;
                        demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;
                        demande[t,nroPasse].profondeur         := 0;
                      end;
                  end;
               end; {case}
            end;
          RetrogradeMilieuCmd:
            begin
              genreAnalyseEnCours := ReflRetrogradeMilieu;
              tempsMaximumCettePasse := 1000000000;       {1000000000 sec = 11570 jours = 31,6 ans}
              tempsMaximumCeStage := 1000000000;
              for t := whichMoveNumber downto 0 do
                begin
                  demande[t,nroPasse].genre := ReflRetrogradeMilieu;
                  demande[t,nroPasse].tempsAlloueParCoup := tempsMaximumCeStage;  {valeur par defaut}
                  demande[t,nroPasse].profondeur := 0;                     {valeur par defaut}
                end;
              case menuItems[nroPasse,nroStage,kMenuProf] of
                 Profondeur3Cmd:      for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 3;
						     Profondeur5Cmd:      for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 5;
						     Profondeur7Cmd:      for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 7;
						     Profondeur9Cmd:      for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 9;
						     Profondeur11Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 11;
						     Profondeur13Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 13;
						     Profondeur15Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 15;
						     Profondeur17Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 17;
						     Profondeur19Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 19;
						     Profondeur21Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 21;
						     Profondeur23Cmd:     for t := whichMoveNumber downto 0 do demande[t,nroPasse].profondeur := 23;
						     DixSecParCoupCmd:    for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 10;
						     VingtSecParCoupCmd:  for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 20;
						     TrenteSecParCoupCmd: for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 30;
						     UneMinParCoupCmd:    for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 60;
						     DeuxMinParCoupCmd:   for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 120;
						     CinqMinParCoupCmd:   for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 300;
						     QuinzeMinParCoupCmd: for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 900;
						     UneHeureParCoupCmd:  for t := whichMoveNumber downto 0 do demande[t,nroPasse].tempsAlloueParCoup := 3600;
              end; {case}
            end;
          RienDuToutCmd:
            begin
              genreAnalyseEnCours := PasAnalyseRetrograde;
              tempsMaximumCettePasse := -1;
              tempsMaximumCeStage := -1;
              for t := whichMoveNumber downto 0 do
                begin
                  demande[t,nroPasse].genre := PasAnalyseRetrograde;
                  demande[t,nroPasse].tempsAlloueParCoup := 0;
                  demande[t,nroPasse].profondeur := 0;
                end;
            end;
        end; {case}

      end;
end;

procedure InitUnitRetrograde;
var nroCoup,passe,i,j : SInt32;
    unRect : rect;
begin
  coupMaxPossiblePourFinale := 60-kNbMaxNiveaux+2;

  with analyseRetrograde do
    begin
      nbMinPourConfirmationArret       := 0;
      tickDebutAnalyse                 := 0;
      tickDebutCettePasseAnalyse       := 0;
      tickDebutCeStageAnalyse          := 0;
      tempsDernierCoupAnalyse          := 0;
      genreAnalyseEnCours              := PasAnalyseRetrograde;
      genreDerniereAmeliorationCherchee := PasAnalyseRetrograde;
      numeroPasse                      := 1;
      numeroStage                      := 1;
      tempsMaximumCettePasse           := 0;
      tempsMaximumCeStage              := 0;
      enCours                          := false;
      doitConfirmerArret               := true;
      peutDemanderConfirmerArret       := false;
      for passe := 1 to nbMaxDePassesAnalyseRetrograde do
        for nroCoup := 0 to 64 do
          begin
            demande[nroCoup,passe].tempsAlloueParCoup := minutes10000000;  {temps infini}
            if nroCoup >= 50
              then demande[nroCoup,passe].genre := ReflRetrogradeParfait
              else demande[nroCoup,passe].genre := PasAnalyseRetrograde;
          end;
      menuItems[1,1,kMenuGenre] := RetrogradeParfaiteCmd;
      menuItems[1,1,kMenuProf] := Profondeur17Cmd;
      menuItems[1,1,kMenuDuree] := Jusque45Cmd;
      menuItems[1,1,kMenuNotes] := 1;

      menuItems[1,2,kMenuGenre] := RetrogradeGagnanteCmd;
      menuItems[1,2,kMenuProf] := Profondeur17Cmd;
      menuItems[1,2,kMenuDuree] := Jusque35Cmd;
      menuItems[1,2,kMenuNotes] := 1;

      menuItems[1,3,kMenuGenre] := RetrogradeMilieuCmd;
      menuItems[1,3,kMenuProf] := DixSecParCoupCmd;
      menuItems[1,3,kMenuDuree] := Jusque45Cmd;
      menuItems[1,3,kMenuNotes] := 1;

      menuItems[2,1,kMenuGenre] := RetrogradeParfaiteCmd;
      menuItems[2,1,kMenuProf] := Profondeur17Cmd;
      menuItems[2,1,kMenuDuree] := Pendant1HeureCmd;
      menuItems[2,1,kMenuNotes] := 1;

      menuItems[2,2,kMenuGenre] := RetrogradeGagnanteCmd;
      menuItems[2,2,kMenuProf] := Profondeur17Cmd;
      menuItems[2,2,kMenuDuree] := Pendant2HeuresCmd;
      menuItems[2,2,kMenuNotes] := 1;

      menuItems[2,3,kMenuGenre] := RetrogradeMilieuCmd;
      menuItems[2,3,kMenuProf] := Profondeur17Cmd;
      menuItems[2,3,kMenuDuree] := Jusque45Cmd;
      menuItems[2,3,kMenuNotes] := 1;

      menuItems[3,1,kMenuGenre] := RienDuToutCmd;
      menuItems[3,1,kMenuProf] := 1;
      menuItems[3,1,kMenuDuree] := 1;
      menuItems[3,1,kMenuNotes] := 1;

      menuItems[3,2,kMenuGenre] := RienDuToutCmd;
      menuItems[3,2,kMenuProf] := 1;
      menuItems[3,2,kMenuDuree] := 1;
      menuItems[3,2,kMenuNotes] := 1;

      menuItems[3,3,kMenuGenre] := RienDuToutCmd;
      menuItems[3,3,kMenuProf] := 1;
      menuItems[3,3,kMenuDuree] := 1;
      menuItems[3,3,kMenuNotes] := 1;


		  dialogueAnalyseRetrograde := NIL;
		  unRect := MakeRect(0,0,0,0);
		  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		    for j := 1 to nbMaxDeStagesAnalyseRetrograde do
			    begin
			      menuAnalyse[i,j] := NewMenuFlottant(TypeAnalyseID,unRect,menuItems[i,j,kMenuGenre]);
			      menuDuree[i,j] := NewMenuFlottant(DureeAnalyseID,unRect,menuItems[i,j,kMenuDuree]);
			      menuProfondeur[i,j] := NewMenuFlottant(ProfondeurID,unRect,menuItems[i,j,kMenuProf]);
			      menuNbNotesMilieu[i,j] := NewMenuFlottant(NbMeilleuresNotesRetrogradeID,unRect,menuItems[i,j,kMenuNotes]);
			    end;
	end;

	for i := 1 to nbMaxDePassesAnalyseRetrograde do
	  for j := nbMaxDeStagesAnalyseRetrograde downto 1 do
	    CalculeBornesAnalyseRetrograde(i,j,60);
end;


procedure LoadMenusRetrograde;
var i,j : SInt32;
    unRect : rect;
begin
  if dialogueAnalyseRetrograde <> NIL then
    begin
		  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		    for j := 1 to nbMaxDeStagesAnalyseRetrograde do
			    begin
			      GetDialogItemRect(dialogueAnalyseRetrograde,9+(i-1)*6+(j-1)*2,unRect);  {ceci donne les rectangles de gauche dans le dialogue d'analyse retrograde}
			      menuAnalyse[i,j] := NewMenuFlottant(TypeAnalyseID,unRect,analyseRetrograde.menuItems[i,j,kMenuGenre]);

			      GetDialogItemRect(dialogueAnalyseRetrograde,9+(i-1)*6+(j-1)*2+1,unRect);{ceci donne les rectangles de droite dans le dialogue d'analyse retrograde}
			      menuDuree[i,j] := NewMenuFlottant(DureeAnalyseID,unRect,analyseRetrograde.menuItems[i,j,kMenuDuree]);
			      menuProfondeur[i,j] := NewMenuFlottant(ProfondeurID,unRect,analyseRetrograde.menuItems[i,j,kMenuProf]);
			      menuNbNotesMilieu[i,j] := NewMenuFlottant(NbMeilleuresNotesRetrogradeID,unRect,analyseRetrograde.menuItems[i,j,kMenuNotes]);
			    end;
			InstalleMenuFlottant(menuAnalyse[1,1],GetDialogWindow(dialogueAnalyseRetrograde));
			InstalleMenuFlottant(menuDuree[1,1],GetDialogWindow(dialogueAnalyseRetrograde));
			InstalleMenuFlottant(menuProfondeur[1,1],GetDialogWindow(dialogueAnalyseRetrograde));
			InstalleMenuFlottant(menuNbNotesMilieu[1,1],GetDialogWindow(dialogueAnalyseRetrograde));
			for i := 1 to nbMaxDePassesAnalyseRetrograde do
		    for j := 1 to nbMaxDeStagesAnalyseRetrograde do
		      if (i <> 1) | (j <> 1) then
		      begin
		        menuAnalyse[i,j].theMenu           := menuAnalyse[1,1].theMenu;
			      menuDuree[i,j].theMenu             := menuDuree[1,1].theMenu;
			      menuProfondeur[i,j].theMenu        := menuProfondeur[1,1].theMenu;
			      menuNbNotesMilieu[i,j].theMenu     := menuNbNotesMilieu[1,1].theMenu;
			      menuAnalyse[i,j].theMenuWidth      := menuAnalyse[1,1].theMenuWidth;
			      menuDuree[i,j].theMenuWidth        := menuDuree[1,1].theMenuWidth;
			      menuProfondeur[i,j].theMenuWidth   := menuProfondeur[1,1].theMenuWidth;
			      menuNbNotesMilieu[i,j].theMenuWidth := menuNbNotesMilieu[1,1].theMenuWidth;
			      CalculateMenuFlottantControl(menuAnalyse[i,j],GetDialogWindow(dialogueAnalyseRetrograde));
			      CalculateMenuFlottantControl(menuDuree[i,j],GetDialogWindow(dialogueAnalyseRetrograde));
			      CalculateMenuFlottantControl(menuProfondeur[i,j],GetDialogWindow(dialogueAnalyseRetrograde));
			      CalculateMenuFlottantControl(menuNbNotesMilieu[i,j],GetDialogWindow(dialogueAnalyseRetrograde));
		      end;
	  end;
end;


procedure DesinstalleMenusRetrograde;
var i,j : SInt32;
begin
  for i := 1 to nbMaxDePassesAnalyseRetrograde do
    for j := 1 to nbMaxDeStagesAnalyseRetrograde do
      begin
        {on sauvegarde les parametres de l'analyse retrograde}
        analyseRetrograde.menuItems[i,j,kMenuGenre] := menuAnalyse[i,j].theItem;
        analyseRetrograde.menuItems[i,j,kMenuDuree] := menuDuree[i,j].theItem;
			  analyseRetrograde.menuItems[i,j,kMenuProf] := menuProfondeur[i,j].theItem;
        analyseRetrograde.menuItems[i,j,kMenuNotes] := menuNbNotesMilieu[i,j].theItem;

        {on detruit les menus pop-up}
        DesinstalleMenuFlottant(menuAnalyse[i,j]);
        DesinstalleMenuFlottant(menuDuree[i,j]);
        DesinstalleMenuFlottant(menuProfondeur[i,j]);
        DesinstalleMenuFlottant(menuNbNotesMilieu[i,j]);
      end;
end;

function FiltreDialogueRetrograde(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
begin
	FiltreDialogueRetrograde := false;
	if not (EvenementDuDialogue(dlog,evt)) then
		FiltreDialogueRetrograde := MyFiltreClassique(dlog, evt, item)
	else
		case evt.what of
			updateEvt:
				begin
					item := VirtualUpdateItemInDialog;
					FiltreDialogueRetrograde := true;
				end;
			otherwise
				FiltreDialogueRetrograde := MyFiltreClassique(dlog,evt,item);
		end;  {case}
end;

procedure AjusteInterdependancesMenusRetrograde(var changements : boolean);
var passe,stage : SInt32;
    change,changementCeStage : boolean;
begin
  changements := false;
  for passe := 1 to nbMaxDePassesAnalyseRetrograde do
    for stage := 1 to nbMaxDeStagesAnalyseRetrograde do
      changementsMenusRetrograde[passe,stage] := false;
  for passe := 1 to nbMaxDePassesAnalyseRetrograde do
    begin
      repeat
        changementCeStage := false;
        for stage := 1 to nbMaxDeStagesAnalyseRetrograde do
          begin

          	if InMenuCmdSet(menuAnalyse[passe,stage].theItem, [RetrogradeParfaiteCmd,RetrogradeGagnanteCmd]) &
          	   (menuDuree[passe,stage].theItem = FinDesTempsCmd) then
              if stage+1 <= nbMaxDeStagesAnalyseRetrograde then
                begin
                  change := false;
                  SetItemMenuFlottant(menuAnalyse[passe,stage+1],RienDuToutCmd,change);
                  if change then changementCeStage := true;
                  if change then changementsMenusRetrograde[passe,stage+1] := true;
                end;

            if menuAnalyse[passe,stage].theItem = RetrogradeMilieuCmd then
              if stage+1 <= nbMaxDeStagesAnalyseRetrograde then
                begin
                  change := false;
                  SetItemMenuFlottant(menuAnalyse[passe,stage+1],RienDuToutCmd,change);
                  if change then changementCeStage := true;
                  if change then changementsMenusRetrograde[passe,stage+1] := true;
                end;

            if (menuAnalyse[passe,stage].theItem = RienDuToutCmd) & (stage = 1) then
              begin
                change := false;
                SetItemMenuFlottant(menuAnalyse[passe,stage],RienDuToutCmd,change);
                if change then changementCeStage := true;
                if change then changementsMenusRetrograde[passe,stage] := true;
              end;

            if (menuAnalyse[passe,stage].theItem = RienDuToutCmd) &
               (stage > 1) & (menuAnalyse[passe,stage-1].theItem <> RienDuToutCmd)
               {& (menuAnalyse[passe,stage-1].theItem <> 0)} then
              begin
                change := false;
                SetItemMenuFlottant(menuAnalyse[passe,stage],RienDuToutCmd,change);
                if change then changementCeStage := true;
                if change then changementsMenusRetrograde[passe,stage] := true;
              end;

            if menuAnalyse[passe,stage].theItem = RienDuToutCmd then
              if stage+1 <= nbMaxDeStagesAnalyseRetrograde then
                begin
                  change := false;
                  SetItemMenuFlottant(menuAnalyse[passe,stage+1],RienDuToutCmd,change);
                  if change then changementCeStage := true;
                  if change then changementsMenusRetrograde[passe,stage+1] := true;
                end;

          end;
        changements := changements | changementCeStage;
      until not(changementCeStage);
    end;
end;

procedure EnableMenuRetrograde(passe,stage : SInt32);
var itemLignePrecedente,j,dureeLignePrecedente : SInt32;
begin
  with menuAnalyse[passe,stage] do
    begin
      MyEnableItem(theMenu,0);
      MyEnableItem(theMenu,RienDuToutCmd);
      if stage > 1
        then
          begin
            itemLignePrecedente := menuAnalyse[passe,stage-1].theItem;
            dureeLignePrecedente := menuDuree[passe,stage-1].theItem;
          end
        else
          begin
            itemLignePrecedente := -1000;  {valeur inutilisee}
            dureeLignePrecedente := -1000;
          end;
      for j := RetrogradeParfaiteCmd to RetrogradeMilieuCmd do
        if stage = 1
          then MyEnableItem(theMenu,j)
          else
            begin
			        if (j > itemLignePrecedente) &
			           not(InMenuCmdSet(itemLignePrecedente,[RetrogradeParfaiteCmd,RetrogradeGagnanteCmd]) &
			           		(dureeLignePrecedente = FinDesTempsCmd))
			          then MyEnableItem(theMenu,j)
			          else MyDisableItem(theMenu,j);
			      end;
    end;
end;

procedure DrawLeftOfLineOfMenusRetrograde(passe,stage : SInt32);
begin
  MyEnableItem(menuAnalyse[passe,stage].theMenu,menuAnalyse[passe,stage].theItem);
  DrawPUItemMenuFlottant(menuAnalyse[passe,stage],false);
end;

procedure DrawRightOfLineOfMenusRetrograde(passe,stage : SInt32);
begin
  case menuAnalyse[passe,stage].theItem of
    RetrogradeParfaiteCmd,RetrogradeGagnanteCmd:
      DrawPUItemMenuFlottant(menuDuree[passe,stage],false);
    RetrogradeMilieuCmd :
      begin
        EffaceMenuFlottant(menuProfondeur[passe,stage]);
        DrawPUItemMenuFlottant(menuProfondeur[passe,stage],false);
      end;
    otherwise
      EffaceMenuFlottant(menuProfondeur[passe,stage]);
  end {case}
end;

procedure DrawLineOfMenusRetrograde(passe,stage : SInt32);
begin
  if menuAnalyse[passe,stage].theItem = 0
    then
      begin
        EffaceMenuFlottant(menuAnalyse[passe,stage]);
        EffaceMenuFlottant(menuProfondeur[passe,stage]);
      end
    else
      begin
        DrawLeftOfLineOfMenusRetrograde(passe,stage);
			  DrawRightOfLineOfMenusRetrograde(passe,stage);
      end;
end;

procedure DrawDialogueRetrograde(redrawDialog : boolean);
var i,j : SInt32;
    oldPort : grafPtr;
begin
  if (dialogueAnalyseRetrograde <> NIL) then
    begin
      GetPort(oldPort);
      SetPortByDialog(dialogueAnalyseRetrograde);
		  if redrawDialog then
		    MyDrawDialog(dialogueAnalyseRetrograde);
		  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		    for j := 1 to nbMaxDeStagesAnalyseRetrograde do
		      DrawLineOfMenusRetrograde(i,j);
		  OutlineOK(dialogueAnalyseRetrograde);
		  SetPort(oldPort);
		end;
end;



procedure ClicInMenusRetrograde(whichRect : rect);
var i,j,olditem : SInt16;
    changements : boolean;
    bidbool : boolean;
begin
  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		for j := 1 to nbMaxDeStagesAnalyseRetrograde do
		  if EqualRect(whichRect,menuAnalyse[i,j].theRect) then
		    begin
		      EnableMenuRetrograde(i,j);
		      oldItem := menuAnalyse[i,j].theItem;
		      CheckOnlyThisItem(menuAnalyse[i,j],menuAnalyse[i,j].theItem);
		      bidbool := EventPopUpItemMenuFlottant(menuAnalyse[i,j],false,true,true);
		      if menuAnalyse[i,j].theItem <> oldItem then
		        begin
		          DrawLeftOfLineOfMenusRetrograde(i,j);
		          if ((oldItem <> RetrogradeParfaiteCmd) | (menuAnalyse[i,j].theItem <> RetrogradeGagnanteCmd)) &
		             ((oldItem <> RetrogradeGagnanteCmd) | (menuAnalyse[i,j].theItem <> RetrogradeParfaiteCmd))
		            then DrawRightOfLineOfMenusRetrograde(i,j);
		        end;
		    end;
  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		for j := 1 to nbMaxDeStagesAnalyseRetrograde do
		  if EqualRect(whichRect,menuProfondeur[i,j].theRect) then
		    begin
		      case menuAnalyse[i,j].theItem of
		        RetrogradeParfaiteCmd,RetrogradeGagnanteCmd:
		          begin
		            CheckOnlyThisItem(menuDuree[i,j],menuDuree[i,j].theItem);
		            oldItem := menuDuree[i,j].theItem;
		            bidbool := EventPopUpItemMenuFlottant(menuDuree[i,j],false,true,true);
		            if menuDuree[i,j].theItem <> oldItem then DrawPUItemMenuFlottant(menuDuree[i,j],false);
		          end;
		        RetrogradeMilieuCmd :
		          begin
		            CheckOnlyThisItem(menuProfondeur[i,j],menuProfondeur[i,j].theItem);
		            oldItem := menuProfondeur[i,j].theItem;
		            bidbool := EventPopUpItemMenuFlottant(menuProfondeur[i,j],false,true,true);
		            if menuProfondeur[i,j].theItem <> oldItem then DrawPUItemMenuFlottant(menuProfondeur[i,j],false);
		          end;
		      end; {case}
		    end;
	AjusteInterdependancesMenusRetrograde(changements);
	if changements then
	  for i := 1 to nbMaxDePassesAnalyseRetrograde do
		  for j := 1 to nbMaxDeStagesAnalyseRetrograde do
		    if changementsMenusRetrograde[i,j] then DrawLineOfMenusRetrograde(i,j);
end;


procedure AjusteBoutonsDialogueRetrograde(seulementParametrage : boolean);
const OK = 1;
      annulerBouton = 2;
var s : String255;
    itemType : SInt16;
    itemHandle : handle;
    itemrect : rect;
begin
  if seulementParametrage then
    begin
      GetDialogItem(dialogueAnalyseRetrograde,annulerBouton,itemType,itemHandle,itemrect);
      HideControl(ControlHandle(itemHandle));
      s := 'OK';
      GetDialogItem(dialogueAnalyseRetrograde,OK,itemType,itemHandle,itemrect);
      SetControlTitle(ControlHandle(itemHandle),StringToStr255(s));
      SetRect(itemrect,itemrect.left-90,itemrect.top,itemrect.left,itemrect.bottom);
      SetDialogItem(dialogueAnalyseRetrograde,OK,itemType,itemHandle,itemrect);
      MoveControl(ControlHandle(itemHandle),itemRect.left,itemRect.top);
      SizeControl(ControlHandle(itemHandle),itemRect.right-itemRect.left,itemRect.bottom-itemRect.top);
    end;
end;

function DoDialogueRetrograde(seulementParametrage : boolean) : boolean;
const DialogueRetrogradeID = 156;
      OK = 1;
      annulerBouton = 2;
      premierMenuFlottant = 9;
      dernierMenuFlottant = 26;
var FiltreDialogueRetrogradeUPP : ModalFilterUPP;
    itemHit : SInt16;
    itemRect : rect;
		err : OSErr;
		changement : boolean;
begin
  DoDialogueRetrograde := false;
  BeginDialog;
	SwitchToScript(gLastScriptUsedInDialogs);
	dialogueAnalyseRetrograde := MyGetNewDialog(DialogueRetrogradeID);
	if dialogueAnalyseRetrograde <> NIL then
	  begin
	    LoadMenusRetrograde;
	    AjusteInterdependancesMenusRetrograde(changement);
	    AjusteBoutonsDialogueRetrograde(seulementParametrage);
	    ShowWindow(GetDialogWindow(dialogueAnalyseRetrograde));
      SetPortByDialog(dialogueAnalyseRetrograde);
	    BeginUpdate(GetDialogWindow(dialogueAnalyseRetrograde));
	    DrawDialogueRetrograde(true);
			EndUpdate(GetDialogWindow(dialogueAnalyseRetrograde));
	    FiltreDialogueRetrogradeUPP := NewModalFilterUPP(FiltreDialogueRetrograde);
	    err := SetDialogTracksCursor(dialogueAnalyseRetrograde,true);

	    repeat
	      ModalDialog(FiltreDialogueRetrogradeUPP, itemHit);
				SetPortByDialog(dialogueAnalyseRetrograde);
				case itemHit of
				  VirtualUpdateItemInDialog:
				    begin
				      BeginUpdate(GetDialogWindow(dialogueAnalyseRetrograde));
				      DrawDialogueRetrograde(true);
				      EndUpdate(GetDialogWindow(dialogueAnalyseRetrograde));
				    end;
				  premierMenuFlottant..dernierMenuFlottant :
				    begin
				      GetDialogItemRect(dialogueAnalyseRetrograde,itemHit,itemRect);
				      ClicInMenusRetrograde(itemRect);
				    end;
				end;
	    until (itemHit = OK) | (itemHit = annulerBouton);
	    HideWindow(GetDialogWindow(dialogueAnalyseRetrograde));
	    EssaieUpdateEventsWindowPlateau;
	    DoDialogueRetrograde := (itemHit = OK);
	    DesinstalleMenusRetrograde;
			MyDisposeDialog(dialogueAnalyseRetrograde);
			MyDisposeModalFilterUPP(FiltreDialogueRetrogradeUPP);
			inc(analyseRetrograde.nbPresentationsDialogue);
		end;
	GetCurrentScript(gLastScriptUsedInDialogs);
  SwitchToRomanScript;
  EndDialog;
end;




procedure EcritDemandeAnalyseDansRapport(whichPasse : SInt32);
var i,j : SInt32;
    s,s1 : String255;
begin
  i := whichPasse;
  for j := 30 to 60 do
    with analyseRetrograde do
      begin
        s1 := NumEnString(i);
        s := NumEnString(j);
        WritelnNumDansRapport('demande['+s+','+s1+'].genre = ',demande[j,i].genre);
        WritelnNumDansRapport('demande['+s+','+s1+'].tempsAlloueParCoup = ',demande[j,i].tempsAlloueParCoup);
        {WritelnNumDansRapport('demande['+s+','+s1+'].profondeur = ',demande[j,i].profondeur);}
      end;
end;


var positionInsertionLocale : SInt32;
    positionInsertionGlobale : SInt32;
    scoreOptimalEnChaine : String255;
    tempoSonAnalyseRetrograde : boolean;
    scriptDebutAnalyseRetrograde : SInt32;
    HumCtreHumDebutAnalyseRetrograde : boolean;


procedure AnnonceAnalyseRetrogradeDansRapport(numeroPasse : SInt32);
var s,passeStr : String255;
    oldScript : SInt32;
    oldInterruption : SInt16;
begin
 GetCurrentScript(oldScript);
 case numeroPasse of
   1 : passeStr := ReadStringFromRessource(TextesRetrogradeID,27);  {"première passe"}
   2 : passeStr := ReadStringFromRessource(TextesRetrogradeID,28);  {"deuxième passe"}
   3 : passeStr := ReadStringFromRessource(TextesRetrogradeID,29);  {"troisième passe"}
   4 : passeStr := ReadStringFromRessource(TextesRetrogradeID,30);  {"quatrième passe"}
   5 : passeStr := ReadStringFromRessource(TextesRetrogradeID,31);  {"cinquième passe"}
   otherwise
     begin
       passeStr := ReadStringFromRessource(TextesRetrogradeID,32);  {"passe numéro ^0"}
       passeStr := ParamStr(passeStr,NumEnString(numeroPasse),'','','');
     end;
 end; {case}
 s := ReadStringFromRessource(TextesRetrogradeID,2); {'analyse rétrograde de la partie"}
 WritelnDansRapportSync(s+', '+passeStr,false);

 if (nbPartiesActives = 1) & JoueursEtTournoisEnMemoire & (windowListeOpen | windowStatOpen) then
   begin
     s := ConstruireChaineReferencesPartieDapresListe(1,false);
     if s <> '' then WritelnDansRapportSync(s,false);


     if GetPartieEnAlphaDapresListe(tableNumeroReference^^[1],nbreCoup) <> PartiePourPressePapier(true,false,nbreCoup)
       then   { la partie courante est une interversion d'une partie de la liste ! On prefere analyser cette derniere }
         begin

           analyseRetrograde.enCours := false;
           oldInterruption := GetCurrentInterruption;
           EnleveCetteInterruption(oldInterruption);

           PlaquerPartieLegale(GetPartieEnAlphaDapresListe(tableNumeroReference^^[1],nbreCoup),kNePasRejouerLesCoupsEnDirect);

           EnleveCetteInterruption(GetCurrentInterruption);
           LanceInterruption(oldInterruption,'AnnonceAnalyseRetrogradeDansRapport');
           analyseRetrograde.enCours := true;

         end;

   end;
 SetCurrentScript(oldScript);
 SwitchToRomanScript;
end;

procedure SetPhasePartieRetrograde(typeDeJeuDemande : SInt32);
begin
  case typeDeJeuDemande of
    ReflRetrogradeParfait : DoFinaleOptimale(false);
    ReflParfait           : DoFinaleOptimale(false);
    ReflRetrogradeGagnant : DoFinaleGagnante(false);
    ReflGagnant           : DoFinaleGagnante(false);
    ReflRetrogradeMilieu  : DoMilieuDeJeuNormal(1,false);
    ReflMilieu            : DoMilieuDeJeuNormal(1,false);
  end; {case}
  phaseDeLaPartie := CalculePhasePartie(nbreCoup);

  EnleveCetteInterruption(GetCurrentInterruption);
end;


procedure DoBackMoveAnalyseRetrograde;
begin
  SetDoitEcrireCommentaireCourbe(false);
  DoBackMove;
  SetDoitEcrireCommentaireCourbe(true);
end;


function Amelioration(typeDeJeuDemande : SInt32; handleFinale : MessageFinaleHdl; scoreABattre,coupABattre : SInt32; var scoreParfait,choixX : SInt32) : boolean;
var nbBlanc,nbNoir,prof : SInt32;
   numeroDuCoup,profondeurMilieu : SInt32;
   tickPourDernierCoupAnalyse : SInt32;
   resultatCalculMilieu : MoveRecord;
   oldInterruption : SInt16;
   AmeliorationDeFinaleReussie : boolean;
   gagnant : boolean;
   searchParam : MakeEndgameSearchParamRec;
begin
  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  analyseRetrograde.genreAnalyseEnCours := typeDeJeuDemande;

  couleurMacintosh := AQuiDeJouer;
  HumCtreHum := false;
  nbBlanc := nbreDePions[pionBlanc];
  nbNoir := nbreDePions[pionNoir];
  numeroDuCoup := nbNoir+nbBlanc-4;
  tickPourDernierCoupAnalyse := TickCount;

  DessineCourbe(kCourbeColoree,'Amelioration');

  SetPhasePartieRetrograde(typeDeJeuDemande);
  vaDepasserTemps := false;
  RefleSurTempsJoueur := false;
  Superviseur(numeroDuCoup);
  if not(calculPrepHeurisFait) then Initialise_table_heuristique(JeuCourant,false);
  EcritJeReflechis(AQuiDeJouer);
  DessineIconesChangeantes;
  EnleveCetteInterruption(GetCurrentInterruption);

  if analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeMilieu
    then
      begin
        Calcule_Valeurs_Tactiques(JeuCourant,true);
        profondeurMilieu := analyseRetrograde.demande[nbreCoup,analyseRetrograde.numeroPasse].profondeur;
        SetProfImposee((profondeurMilieu > 0),'Amelioration');

        resultatCalculMilieu := CalculeMeilleurCoupMilieuDePartie(JeuCourant,emplJouable,frontiereCourante,AQuiDeJouer,profondeurMilieu,nbBlanc,nbNoir);

        choixX         := resultatCalculMilieu.x;
        scoreParfait   := resultatCalculMilieu.note + penalitePourTraitAff;
        {meiDef         := resultatCalculMilieu.theDefense;}

        if BAnd(interruptionReflexion,interruptionDepassementTemps) <> 0 then
          begin
            EnleveCetteInterruption(interruptionDepassementTemps);
            vaDepasserTemps := false;
          end;

        Amelioration := ( choixX <> coupABattre ) &
                        ( scoreParfait > scoreABattre + 200 );            {200 = un pion, en milieu de partie }
      end
    else
      begin
        if debuggage.algoDeFinale then
			    begin
			      SetAutoVidageDuRapport(true);
			      SetEcritToutDansRapportLog(true);
			      WritelnDansRapport('');
			      WritelnDansRapport('Entrée dans Amelioration du module AnalyseRetrograde :');
			      WritelnNumDansRapport('coup = ',nbBlanc+nbNoir-4+1);
			      WritelnNumDansRapport('scoreABattre = ',scoreABattre);
			      WritelnDansRapport('');
			    end;
			    
			  (* if faitConfiance *)

			  if ((analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeParfait) & (scoreABattre = 64)) |
			     ((analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeGagnant) & (scoreABattre > 0))
			    then
			      begin
			        scoreParfait := scoreABattre;
			      end
			    else
			      begin

			        prof := 64-nbBlanc-nbNoir;
			        {SetEffetSpecial(false);}

			        with searchParam do
                begin
                   inTypeCalculFinale                   := analyseRetrograde.genreAnalyseEnCours;
                   inCouleurFinale                      := AQuiDeJouer;
                   inProfondeurFinale                   := prof;
                   inNbreBlancsFinale                   := nbBlanc;
                   inNbreNoirsFinale                    := nbNoir;
                   inAlphaFinale                        := -64;
                   inBetaFinale                         := 64;
                   inMuMinimumFinale                    := 0;
                   inMuMaximumFinale                    := kDeltaFinaleInfini;
                   inPrecisionFinale                    := 100;
                   inPrioriteFinale                     := 0;
                   inGameTreeNodeFinale                 := GetCurrentNode;
                   inPositionPourFinale                 := JeuCourant;
                   inMessageHandleFinale                := handleFinale;
                   inCommentairesDansRapportFinale      := false;
                   inMettreLeScoreDansLaCourbeFinale    := true;
                   inMettreLaSuiteDansLaPartie          := true;
                   inDoitAbsolumentRamenerLaSuiteFinale := (scoreABattre < -64);
                   inDoitAbsolumentRamenerUnScoreFinale := false;
                   SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
                   ViderSearchResults(outResult);
                end;

              gagnant := MakeEndgameSearch(searchParam);


              choixX          := searchParam.outResult.outBestMoveFinale;
              scoreParfait    := searchParam.outResult.outScoreFinale;
              {meiDef          := searchParam.outResult.outBestDefenseFinale;
               timeTaken       := searchParam.outResult.outTimeTakenFinale;}


			        if scoreParfait = ScorePourUnSeulCoupLegal then
			           scoreParfait := scoreABattre;


			      end;

			  if (analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeParfait)
			    then AmeliorationDeFinaleReussie := (scoreParfait > scoreABattre)
			    else AmeliorationDeFinaleReussie := (Signe(scoreParfait) > Signe(scoreABattre));

			  if debuggage.algoDeFinale then
			    begin
			      SetAutoVidageDuRapport(true);
			      SetEcritToutDansRapportLog(true);
			      WritelnDansRapport('');
			      WritelnDansRapport('Sortie de Amelioration du module AnalyseRetrograde :');
			      WritelnNumDansRapport('coup = ',nbBlanc+nbNoir-4+1);
			      WritelnNumDansRapport('scoreParfait = ',scoreParfait);
			      if AmeliorationDeFinaleReussie
			        then WritelnDansRapport('Amélioration de finale réussie !')
			        else WritelnDansRapport('Pas d''amélioration.');
			      WritelnDansRapport('');
			    end;

			  Amelioration := AmeliorationDeFinaleReussie;
			end;

  analyseRetrograde.tempsDernierCoupAnalyse := TickCount-tickPourDernierCoupAnalyse;
  analyseRetrograde.genreDerniereAmeliorationCherchee := analyseRetrograde.genreAnalyseEnCours;

  LanceInterruption(oldInterruption,'Amelioration');
end;


procedure SetTempsInfiniPourCalculBanniere;
begin
  with analyseRetrograde do
    begin
      nbMinPourConfirmationArret := 0;
      tickDebutAnalyse           := Tickcount;
      tickDebutCettePasseAnalyse := Tickcount;
      tickDebutCeStageAnalyse    := Tickcount;
      tempsDernierCoupAnalyse    := 0;
      tempsMaximumCettePasse     := 1000000000;
      tempsMaximumCeStage        := 1000000000;
      {doitConfirmerArret        := true;}
      peutDemanderConfirmerArret := false;
    end;
end;


procedure CreeBanniereAnalyseRetrograde(numeroPasse : SInt32; var scoreOptimalPourNoir : SInt32; var oldInterruption : SInt16);
var oldScript : SInt32;
    s,s1,s2 : String255;
    nouveauscore,nouveauCoup : SInt32;
    bidbool : boolean;
begin
  oldInterruption := BOr(oldInterruption,GetCurrentInterruption);
  EnleveCetteInterruption(GetCurrentInterruption);
  GetCurrentScript(oldScript);
  SetDeroulementAutomatiqueDuRapport(true);
  FinRapport;
  TextNormalDansRapport;
  ChangeFontFaceDansRapport(bold);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  if not(gameOver)
    then
      begin
        WritelnDansRapportSync('',false);
        s := ReadStringFromRessource(TextesRetrogradeID,1);  {###################################}
        WritelnDansRapportSync(s,false);
        AnnonceAnalyseRetrogradeDansRapport(numeroPasse);
        SetTempsInfiniPourCalculBanniere;

        analyseRetrograde.enCours := false;
        bidbool := Amelioration(ReflParfait,NIL,-1000,0,nouveauScore,nouveauCoup);
        analyseRetrograde.enCours := true;

        s1 := NumEnString(nbreCoup+1);
        s2 := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
        if AQuiDeJouer = pionNoir
          then scoreOptimalPourNoir := nouveauScore
          else scoreOptimalPourNoir := -nouveauScore;
        if (interruptionReflexion = pasdinterruption) then
          AjouteMeilleureSuiteDansArbreDeJeuCourant(ReflParfait,s2,scoreOptimalPourNoir);
        scoreOptimalEnChaine := TPCopy(s2,LENGTH_OF_STRING(s2)-4,5);
        EnleveEspacesDeGaucheSurPlace(s2);
        if (interruptionReflexion = pasdinterruption)
          then s2 := s1+CharToString('.')+s2
          else s2 := '?????';
        s1 := NumEnString(nbreCoup);
        s := ReadStringFromRessource(TextesRetrogradeID,3);
        s := ParamStr(s,s1,s2,'','');
        GetCurrentScript(oldScript);
        WritelnDansRapportSync(s,false);
        s := ReadStringFromRessource(TextesRetrogradeID,1);  {###################################}
        WritelnDansRapportSync(s,false);
        SetCurrentScript(oldScript);
        SwitchToRomanScript;
      end
    else
      begin
        GetCurrentScript(oldScript);
        WritelnDansRapportSync('',false);
        s := ReadStringFromRessource(TextesRetrogradeID,1);  {###################################}
        WritelnDansRapportSync(s,false);
        AnnonceAnalyseRetrogradeDansRapport(numeroPasse);
        s1 := NumEnString(nbreDePions[pionNoir]);
        s2 := NumEnString(nbreDePions[pionBlanc]);
        s := ReadStringFromRessource(TextesRetrogradeID,4);
        s := ParamStr(s,s1+CharToString('-')+s2,'','','');
        WritelnDansRapportSync(s,false);
        s := ReadStringFromRessource(TextesRetrogradeID,1);  {###################################}
        WritelnDansRapportSync(s,false);
        if nbreDePions[pionNoir] = nbreDePions[pionBlanc]
          then scoreOptimalPourNoir := 0
          else if nbreDePions[pionNoir] < nbreDePions[pionBlanc]
                 then scoreOptimalPourNoir := (2*nbreDePions[pionNoir]-64)
                 else scoreOptimalPourNoir := (64-2*nbreDePions[pionBlanc]);
        scoreOptimalEnChaine := s1+CharToString('-')+s2;
        SetCurrentScript(oldScript);
        SwitchToRomanScript;
        analyseRetrograde.genreDerniereAmeliorationCherchee := PasAnalyseRetrograde;
      end;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
  TextNormalDansRapport;
end;

procedure CreeLignesBlanchesDebutAnalyseRetrograde;
var oldScript,aux,i : SInt32;
begin
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  aux := Min(NbLignesVisiblesDansRapport-5,20);
  for i := 1 to aux do WritelnDansRapportSync('',false);
  for i := 1 to aux-1 do FrappeClavierDansRapport(chr(RetourArriereKey));
  if FenetreRapportEstOuverte then InvalidateWindow(GetRapportWindow);
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;

procedure EffacerAnnonceAnalyseRetrogradeEnCours;
var s1 : String255;
    oldScript,posChaineAnalyseEnCours : SInt32;
begin
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;

  s1 := ReadStringFromRessource(TextesRetrogradeID,5);  {'analyse retrograde en cours'}
  {s1 := Concat(chr(13),s1);}
  if FindStringInRapport(s1,1,1,posChaineAnalyseEnCours)
    then
      begin
        SelectionnerTexteDansRapport(posChaineAnalyseEnCours,posChaineAnalyseEnCours+LENGTH_OF_STRING(s1)+1);
        DetruireSelectionDansRapport;
        UpdateScrollersRapport;
      end;
  SetCurrentScript(oldScript);
  analyseRetrograde.dejaAnnoncee := false;
end;


procedure EcritAnalyseInterrompueDansRapport;
var s : String255;
    oldScript : SInt32;
begin
  if analyseRetrograde.enCours then
    begin
		  GetCurrentScript(oldScript);
		  DisableKeyboardScriptSwitch;
		  s := ReadStringFromRessource(TextesRetrogradeID,6);   {'analyse rétrograde interrompue…'}
		  {EffaceDernierCaractereDuRapportSync(false);}
		  EffacerAnnonceAnalyseRetrogradeEnCours;
		  FinRapport;
		  TextNormalDansRapport;
		  ChangeFontFaceDansRapport(bold);
		  ChangeFontDansRapport(gCassioRapportBoldFont);
		  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
		  {WritelnDansRapportSync('',false);}
		  WritelnDansRapportSync(s,false);
		  TextNormalDansRapport;
		  SetCurrentScript(oldScript);
		end;
end;

procedure EcritAnalyseTermineeDansRapport;
var s : String255;
    oldScript : SInt32;
begin
  if analyseRetrograde.enCours then
    begin
		  GetCurrentScript(oldScript);
		  DisableKeyboardScriptSwitch;
		  s := ReadStringFromRessource(TextesRetrogradeID,7);  {'analyse retrograde terminée'}
		  EffacerAnnonceAnalyseRetrogradeEnCours;
		  EffaceDernierCaractereDuRapportSync(false);
		  FinRapport;
		  TextNormalDansRapport;
		  ChangeFontFaceDansRapport(bold);
		  ChangeFontDansRapport(gCassioRapportBoldFont);
		  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
		  WritelnDansRapportSync('',false);
		  WritelnDansRapportSync(s,false);
		  TextNormalDansRapport;
		  SetCurrentScript(oldScript);
		end;
end;

procedure EcritAnalyseEnCoursDansRapport;
var s : String255;
    oldScript : SInt32;
begin
  if analyseRetrograde.enCours & not(analyseRetrograde.dejaAnnoncee) then
    begin
		  GetCurrentScript(oldScript);
		  DisableKeyboardScriptSwitch;
		  s := ReadStringFromRessource(TextesRetrogradeID,5);  {'analyse retrograde en cours'}
		  EffaceDernierCaractereDuRapportSync(false);
		  FinRapport;
		  TextNormalDansRapport;
		  ChangeFontFaceDansRapport(bold);
		  ChangeFontDansRapport(gCassioRapportBoldFont);
		  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
		  WritelnDansRapportSync('',false);
		  WritelnDansRapportSync(s,false);
		  TextNormalDansRapport;
		  SetCurrentScript(oldScript);
		  analyseRetrograde.dejaAnnoncee := true;
		end;
end;

procedure EcritCoupVerifieAnalyseRetrograde(numeroCoupVerifie,coupVerifie : SInt32; var coupVerifieString : String255);
var s : String255;
    oldScript : SInt32;
begin
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  PositionnePointDinsertion(positionInsertionGlobale);
  TextNormalDansRapport;
  ChangeFontSizeDansRapport(gCassioRapportNormalSize);

  s := NumEnString(numeroCoupVerifie);
  s := s + CharToString('.')+CoupEnString(coupVerifie,CassioUtiliseDesMajuscules);
  coupVerifieString := s;

  InsereStringlnDansRapport(coupVerifieString);
  positionInsertionLocale := GetPositionPointDinsertion-1;
  {ViewRectAGaucheRapport;}
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;


procedure AjoutePropertyBadMoveDansCurrentNode(numeroCoupVerifie,scorePourTrait,nouveauScore : SInt32);
var uneProperty,coupSuivantProp : Property;
    sousArbreOfBadMove : GameTree;
begin
  if ((scorePourTrait < 0) & (nouveauscore >= 0)) |
     ((scorePourTrait = 0) & (nouveauscore > 0))
    then uneProperty := MakeTripleProperty(BadMoveProp,MakeTriple(2))  {??}
    else uneProperty := MakeTripleProperty(BadMoveProp,MakeTriple(1)); {?}

  if AQuiDeJouer = pionNoir
    then coupSuivantProp := MakeOthelloSquareProperty(BlackMoveProp,GetNiemeCoupPartieCourante(numeroCoupVerifie))
    else coupSuivantProp := MakeOthelloSquareProperty(WhiteMoveProp,GetNiemeCoupPartieCourante(numeroCoupVerifie));
  sousArbreOfBadMove := SelectFirstSubtreeWithThisProperty(coupSuivantProp,GetCurrentNode);
  if sousArbreOfBadMove <> NIL then AddPropertyToGameTreeSansDuplication(uneProperty,sousArbreOfBadMove);
  DisposePropertyStuff(uneProperty);
  DisposePropertyStuff(coupSuivantProp);
end;


procedure EcritCoupFautifDansRapport(numeroCoupVerifie,scorePourNoir,scorePourTrait,nouveauScore,nouveauCoup,nbPionsPerdus : SInt32; var chaineMeilleureSuite,coupVerifieString : String255);
var s,s1,s2 : String255;
    oldScript,i : SInt32;
    nbDePionsPerdusDejaAnnonce : boolean;
begin
  s1 := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
  scoreOptimalEnChaine := TPCopy(s1,LENGTH_OF_STRING(s1)-4,5);

  if ((scorePourTrait < 0) & (nouveauscore >= 0)) |
     ((scorePourTrait = 0) & (nouveauscore > 0))
    then 
      begin
        s := ' ' + ReadStringFromRessource(TextesRetrogradeID,9);  {??}
        if (nbPionsPerdus >= 5) then s := s + '?';
      end
    else 
      begin
        s := ' ' + ReadStringFromRessource(TextesRetrogradeID,8); {?}
        if (nbPionsPerdus >= 5) then s := s + '?';
      end;
  s := s + '  ';
  
  nbDePionsPerdusDejaAnnonce := false;

  case analyseRetrograde.genreAnalyseEnCours of
    ReflRetrogradeParfait,ReflRetrogradeGagnant:
      begin
        if (scorePourTrait = 0) & (nouveauscore > 0) then
			    if AQuiDeJouer = pionNoir
			      then s1 := ReadStringFromRessource(TextesRetrogradeID,10)       {Noir rate le gain}
			      else s1 := ReadStringFromRessource(TextesRetrogradeID,15) else  {Blanc rate le gain}
			  if (scorePourTrait < 0) & (nouveauscore > 0) then
			    if AQuiDeJouer = pionNoir
			      then s1 := ReadStringFromRessource(TextesRetrogradeID,11)       {Noir donne le gain}
			      else s1 := ReadStringFromRessource(TextesRetrogradeID,16) else  {Blanc donne le gain}
			  if (scorePourTrait < 0) & (nouveauscore = 0) then
			    if AQuiDeJouer = pionNoir
			      then s1 := ReadStringFromRessource(TextesRetrogradeID,12)       {Noir rate la nulle}
			      else s1 := ReadStringFromRessource(TextesRetrogradeID,17)       {Blanc rate la nulle}
			    else
			      begin
			        if nbPionsPerdus > 1
			          then
			            begin
			              s2 := NumEnString(nbPionsPerdus);
			              if AQuiDeJouer = pionNoir
			                then s1 := ReadStringFromRessource(TextesRetrogradeID,14)  {Noir perd ^0 pions}
			                else s1 := ReadStringFromRessource(TextesRetrogradeID,19); {Blanc perd ^0 pions}
			              s1 := ParamStr(s1,s2,'','','');
			            end
			          else
			            if AQuiDeJouer = pionNoir
			              then s1 := ReadStringFromRessource(TextesRetrogradeID,13)  {Noir perd 1 pion}
			              else s1 := ReadStringFromRessource(TextesRetrogradeID,18); {Blanc perd 1 pion}
			        nbDePionsPerdusDejaAnnonce := true;
			      end;
			end;
    ReflRetrogradeMilieu  :
      begin
        if AQuiDeJouer = pionNoir
			    then s1 := ReadStringFromRessource(TextesRetrogradeID,33)  {Noir perd environ ^0 pions}
			    else s1 := ReadStringFromRessource(TextesRetrogradeID,34); {Blanc perd environ ^0 pions}
        s2 := NoteEnString(nbPionsPerdus,false,0,1);
        s1 := ParamStr(s1,s2,'','','');
        nbDePionsPerdusDejaAnnonce := true;
      end;
    otherwise
      InsereStringlnDansRapport('Qu''est-ce que c''est que cette reflexion dans EcritCoupFautifDansRapport (1) ?? Prévenez Stéphane, SVP !');
  end; {case}



  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  PositionnePointDinsertion(positionInsertionLocale);
  {on efface le coup verifie pour que le gras et la couleur apparaissent}
  for i := 1 to LENGTH_OF_STRING(coupVerifieString) do FrappeClavierDansRapport(chr(RetourArriereKey));
  if AQuiDeJouer = pionNoir
    then ChangeFontColorDansRapport(MarineCmd)
    else ChangeFontColorDansRapport(RougeCmd);
  (* if AQuiDeJouer = pionNoir
      then ChangeFontColorRGBDansRapport(GetCouleurAffichageValeurCourbe(pionNoir,40))
      else ChangeFontColorRGBDansRapport(GetCouleurAffichageValeurCourbe(pionBlanc,-40)); *)
  if ((scorePourTrait < 0) & (nouveauscore >= 0)) | ((scorePourTrait = 0) & (nouveauscore > 0))
    then ChangeFontFaceDansRapport(bold);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  s := Concat(coupVerifieString,s,s1);

  s := Concat(s,chr(0));  {énorme astuce pour contourner le bug de TextEdit sous MacOSX : le chr(0) sera invisible, c'est parfais !}
  InsereStringDansRapport(s);
  s2 := NumEnString(numeroCoupVerifie);

  {
  InsereStringDansRapport(' ');
  SelectionnerTexteDansRapport(GetPositionPointDinsertion-1,GetPositionPointDinsertion);
  }

  case analyseRetrograde.genreAnalyseEnCours of
    ReflRetrogradeParfait :
      begin
        if nbDePionsPerdusDejaAnnonce
          then
            begin
              if scorePourNoir = 0
                then s := ReadStringFromRessource(TextesRetrogradeID,22) {'^0 faisait nulle'}
                else s := ReadStringFromRessource(TextesRetrogradeID,23);{'^0 faisait ^1'}
              s := ParamStr(s,s2+CharToString('.')+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules),scoreOptimalEnChaine,'','') + ' ';
              TextNormalDansRapport;
              ChangeFontSizeDansRapport(gCassioRapportNormalSize);
              InsereStringDansRapport(', '+s);
            end
          else
            begin
              if scorePourNoir = 0
                then 
                  if (nbPionsPerdus > 1)
                    then s := ReadStringFromRessource(TextesRetrogradeID,37) {'^0 faisait ^1 pions de plus et annulait'}
                    else s := ReadStringFromRessource(TextesRetrogradeID,36) {'^0 faisait un pion de plus et annulait'}
                else 
                  if (nbPionsPerdus > 1)
                    then s := ReadStringFromRessource(TextesRetrogradeID,39) {'^0 faisait ^1 pions de plus et ^2'}
                    else s := ReadStringFromRessource(TextesRetrogradeID,38);{'^0 faisait un pion de plus et ^2'}
              s := ParamStr(s,s2+CharToString('.')+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules),NumEnString(nbPionsPerdus),scoreOptimalEnChaine,'') + ' ';
              TextNormalDansRapport;
              if AQuiDeJouer = pionNoir
                then ChangeFontColorDansRapport(MarineCmd)
                else ChangeFontColorDansRapport(RougeCmd);
              ChangeFontSizeDansRapport(gCassioRapportNormalSize);
              InsereStringDansRapport(', '+s);
            end;
        
        positionInsertionLocale := GetPositionPointDinsertion+1;
        chaineMeilleureSuite := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
        EnleveEspacesDeGaucheSurPlace(chaineMeilleureSuite);
        s := NumEnString(numeroCoupVerifie);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportSmallSize);
        InsereStringlnDansRapport('     '+s+CharToString('.')+chaineMeilleureSuite);
      end;
    ReflRetrogradeGagnant :
      begin
        if scorePourNoir = 0
          then s := ReadStringFromRessource(TextesRetrogradeID,22)  {'^0 faisait nulle'}
          else s := ReadStringFromRessource(TextesRetrogradeID,24); {'^0 était gagnant'}
        s := ParamStr(s,s2+CharToString('.')+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules),'','','');
        TextNormalDansRapport;
        ChangeFontSizeDansRapport(gCassioRapportNormalSize);
          
          
        with analyseRetrograde do
          if (scorePourNoir = 0) & (nbreCoup + 2 <= 60) & (nbreCoup + 1 >= 0)
             & (demande[nbreCoup + 2, numeroPasse].genre = ReflRetrogradeParfait)
             & (demande[nbreCoup + 1, numeroPasse].genre = ReflRetrogradeGagnant) then
            begin
              (* cas où on a une nulle en gagnant/perdant au coup n, mais un score perdant au coup n+1 :
                 en fait on connait le nombre exact de pions perdus dans ce cas... *)
              
              if (nbPionsPerdus > 1)
                then s := ReadStringFromRessource(TextesRetrogradeID,37)  {'^0 faisait ^1 pions de plus et annulait'}
                else s := ReadStringFromRessource(TextesRetrogradeID,36); {'^0 faisait un pion de plus et annulait'}
              s := ParamStr(s,s2+CharToString('.')+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules),NumEnString(nbPionsPerdus),scoreOptimalEnChaine,'') + ' ';
              
              if AQuiDeJouer = pionNoir
                then ChangeFontColorDansRapport(MarineCmd)
                else ChangeFontColorDansRapport(RougeCmd);
            end;
        
        InsereStringDansRapport(', '+s);
        positionInsertionLocale := GetPositionPointDinsertion+1;
        {InsereStringlnDansRapport('');}
        {InsereStringDansRapport('     '+s);}
        chaineMeilleureSuite := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,true,0);
        EnleveEspacesDeGaucheSurPlace(chaineMeilleureSuite);

        s := chaineMeilleureSuite;
        s := DeleteSubstringBeforeThisChar('(',s,false);
        s := DeleteSubstringAfterThisChar(')',s,false);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportSmallSize);
        InsereStringlnDansRapport('     '+s);
      end;
    ReflRetrogradeMilieu  :
      begin
        s := ReadStringFromRessource(TextesRetrogradeID,35); {'^0 était meilleur'}
        s := ParamStr(s,s2+CharToString('.')+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules),'','','');
        TextNormalDansRapport;
        ChangeFontSizeDansRapport(gCassioRapportNormalSize);
        InsereStringDansRapport(', '+s);
        positionInsertionLocale := GetPositionPointDinsertion+1;
        chaineMeilleureSuite := MeilleureSuiteEtNoteEnChaine(AQuiDeJouer,nouveauScore,InfosDerniereReflexionMac.prof);
        EnleveEspacesDeGaucheSurPlace(chaineMeilleureSuite);
        s := NumEnString(numeroCoupVerifie);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportSmallSize);
        InsereStringlnDansRapport('     '+chaineMeilleureSuite);
      end;
    otherwise
      InsereStringlnDansRapport('Qu''est-ce que c''est que cette reflexion dans EcritCoupFautifDansRapport (2) ?? Prévenez Stéphane, SVP !');
  end; {case}
  positionInsertionLocale := GetPositionPointDinsertion;
  SetCurrentScript(oldScript);
end;


procedure EcritCoupOKDansRapport(scorePourNoir,numeroDuCoupVerifie,coupVerifie,nouveauCoup : SInt32);
var s : String255;
    oldScript : SInt32;
begin
  case analyseRetrograde.genreAnalyseEnCours of
    ReflRetrogradeParfait :
      begin
        if scorePourNoir = 0
          then s := ReadStringFromRessource(TextesRetrogradeID,20)  {'fait nulle'}
          else s := ReadStringFromRessource(TextesRetrogradeID,21); {'fait ^0}
        s := '   '+ParamStr(s,scoreOptimalEnChaine,'','','');
        GetCurrentScript(oldScript);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportNormalSize);
        InsereStringDansRapport(s);
        SetCurrentScript(oldScript);
        positionInsertionLocale := GetPositionPointDinsertion+1;
      end;
    ReflRetrogradeGagnant :
      begin
        if scorePourNoir = 0 then s := ReadStringFromRessource(TextesRetrogradeID,20) else {'fait nulle'}
        if scorePourNoir > 0 then s := ReadStringFromRessource(TextesRetrogradeID,25) else {'Noir est gagnant'}
        if scorePourNoir < 0 then s := ReadStringFromRessource(TextesRetrogradeID,26);     {'Blanc est gagnant'}
        GetCurrentScript(oldScript);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportNormalSize);
        InsereStringDansRapport('   '+s);
        SetCurrentScript(oldScript);
        positionInsertionLocale := GetPositionPointDinsertion+1;
      end;
    ReflRetrogradeMilieu :
      begin
        if scorePourNoir >= 0
          then
            begin
              s := ReadStringFromRessource(TextesSolitairesID,19);    {'Noir'}
              s := Concat('   ',s,NoteEnString(scorePourNoir,true,0,2));
            end
          else
            begin
              s := ReadStringFromRessource(TextesSolitairesID,20);   {'Blanc'}
              s := Concat('   ',s,NoteEnString(-scorePourNoir,true,0,2));
            end;
        if nouveauCoup <> coupVerifie then
          s := s + '  ('+NumEnString(numeroDuCoupVerifie)+'.'+CoupEnString(nouveauCoup,CassioUtiliseDesMajuscules)+'!?)';

        GetCurrentScript(oldScript);
        PositionnePointDinsertion(positionInsertionLocale);
        ChangeFontSizeDansRapport(gCassioRapportNormalSize);
        InsereStringDansRapport(s);
        SetCurrentScript(oldScript);
        positionInsertionLocale := GetPositionPointDinsertion+1;
      end;
    otherwise
      InsereStringDansRapport('Qu''est-ce que c''est que cette reflexion dans EcritCoupOKDansRapport ?? Prévenez Stéphane, SVP !');
  end;
end;


function NewHandleRetrograde(scorePourTrait,coupVerifie,meilleureDefense : SInt32) : MessageFinaleHdl;
type
    LocalMessageFinaleRec = MessageFinaleRec;
    LocalMessageFinalePtr = ^LocalMessageFinaleRec;
    LocalMessageFinaleHdl = ^LocalMessageFinalePtr;
var aux : LocalMessageFinaleHdl;
begin
  aux := LocalMessageFinaleHdl(AllocateMemoryHdl(100));
  if aux <> NIL then
    begin
      aux^^.typeData     := ReflScoreDeCeCoupConnuFinale;
      aux^^.longueurData := 1;
      aux^^.data[0]      := scorePourTrait;
      aux^^.data[1]      := coupVerifie;
      aux^^.data[2]      := meilleureDefense;
    end;
  NewHandleRetrograde := MessageFinaleHdl(aux);
end;


procedure PrepareAnalyseRetrograde(var oldInterruption : SInt16);
var placeDisponibleDansRapport : SInt32;
begin
  oldInterruption := GetCurrentInterruption;

  EngineNewPosition;
  EngineViderFeedHashHistory;

  if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true) else
  if not(FenetreRapportEstAuPremierPlan) then SelectWindowSousPalette(GetRapportWindow);
  if not(windowCourbeOpen) then DoCourbe;

  placeDisponibleDansRapport := GetPlaceDisponibleDansRapport;
  if (placeDisponibleDansRapport < 4000) then FaireDeLaPlaceAuDebutDuRapport(4000-placeDisponibleDansRapport);

  if not(afficheProchainsCoups) then DoChangeAfficheProchainsCoups;
  if not(afficheSignesDiacritiques) then DoChangeAfficheSignesDiacritiques;

  analyseRetrograde.genreDerniereAmeliorationCherchee := PasAnalyseRetrograde;
  HumCtreHumDebutAnalyseRetrograde := HumCtreHum;
  HumCtreHum := false;
  DessineIconesChangeantes;
  VideToutesLesHashTablesExactes;
  DisableKeyboardScriptSwitch;
  GetCurrentScript(scriptDebutAnalyseRetrograde);
  analyseRetrograde.dejaAnnoncee := false;

  tempoSonAnalyseRetrograde := avecSon;
  avecSon := false;
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
end;


procedure NettoieToutApresAnalyseRetrograde(oldInterruption : SInt16);
begin
  DetermineMomentFinDePartie;
  phaseDeLaPartie := CalculePhasePartie(nbreCoup);
  FixeMarqueSurMenuMode(nbreCoup);
  avecSon := tempoSonAnalyseRetrograde;
  SetProfImposee(false,'NettoieToutApresAnalyseRetrograde');

  WritelnDansRapport('');
  SetDeroulementAutomatiqueDuRapport(true);
  FinRapport;
  TextNormalDansRapport;
  EnableKeyboardScriptSwitch;
  SetCurrentScript(scriptDebutAnalyseRetrograde);
  SwitchToRomanScript;

  DessineCourbe(kCourbeColoree,'NettoieToutApresAnalyseRetrograde');
  DessineSliderFenetreCourbe;

  VideToutesLesHashTablesExactes;
  EffaceProprietesOfCurrentNode;
  AfficheProprietesOfCurrentNode(true,othellierToutEntier,'NettoieToutApresAnalyseRetrograde');
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'NettoieToutApresAnalyseRetrograde');
  avecCalculPartiesActives := true;
  if (windowListeOpen | windowStatOpen)
    then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
  LanceInterruption(oldInterruption,'NettoieToutApresAnalyseRetrograde');
end;



procedure DoAnalyseRetrograde(limiteAnalyseRetro : SInt32);
var handleRetrograde : MessageFinaleHdl;
    numeroCoupVerifie,coupVerifie,scoreOptimalPourNoir : SInt32;
    scorePourTrait,nouveauscore,nouveauCoup : SInt32;
    coupVerifieString,chaineMeilleureSuite : String255;
    nbPionsPerdus,meilleureDefense : SInt32;
    coupFautif : boolean;
    nroPasseAnalyse,nroStageAnalyse,i : SInt32;
    quitterCettePasse,quitterCeStage,coupPrecedentTermine : boolean;
    oldInterruption : SInt16;
begin
  if interruptionReflexion <> pasdinterruption then
    begin
      if debuggage.general then EcritTypeInterruptionDansRapport(interruptionReflexion);
      exit(DoAnalyseRetrograde);
    end;

  if (nbreCoup >= limiteAnalyseRetro) | gameOver then
    begin
      PrepareAnalyseRetrograde(oldInterruption);

      analyseRetrograde.tickDebutAnalyse := TickCount;
      analyseRetrograde.peutDemanderConfirmerArret := true;
      analyseRetrograde.tempsDernierCoupAnalyse := 0;

      nroPasseAnalyse := 1;
      repeat
        analyseRetrograde.numeroPasse := nroPasseAnalyse;
        analyseRetrograde.tickDebutCettePasseAnalyse := TickCount;
        quitterCettePasse := false;


        if analyseRetrograde.menuItems[nroPasseAnalyse,1,kMenuGenre] <> RienDuToutCmd then
          begin
            analyseRetrograde.enCours := true;

		        DoAvanceAuCoupNro(nroDernierCoupAtteint,true);
		        meilleureDefense := 0;
		        coupPrecedentTermine := true;
		        CreeBanniereAnalyseRetrograde(nroPasseAnalyse,scoreOptimalPourNoir,oldInterruption);
		        if (interruptionReflexion = pasdinterruption) & not(Quitter) then
		          begin
		            nroStageAnalyse := 1;
			          CreeLignesBlanchesDebutAnalyseRetrograde;
			          if HumCtreHum then DoChangeHumCtreHum;
			          positionInsertionGlobale := GetPositionPointDinsertion-1;
			          SetDeroulementAutomatiqueDuRapport(false);
			          EcritAnalyseEnCoursDansRapport;
			          numeroCoupVerifie := nbreCoup;

				        repeat
				          {SysBeep(0);
				          WritelnDansRapport('avant CalculeBornesAnalyseRetrograde : ');
				          WritelnNumDansRapport('nroPasseAnalyse = ',nroPasseAnalyse);
				          WritelnNumDansRapport('nroStageAnalyse = ',nroStageAnalyse);
				          WritelnDansRapport('');}

				          quitterCeStage := false;

				          for i := nbMaxDeStagesAnalyseRetrograde downto nroStageAnalyse do
				            CalculeBornesAnalyseRetrograde(nroPasseAnalyse,i,nbreCoup);
				          if (nbreCoup >= 1) then
				            analyseRetrograde.genreAnalyseEnCours := analyseRetrograde.demande[nbreCoup-1,nroPasseAnalyse].genre;

				          {on vide la table de hachage a chaque fois que l'on change de stage}
				          VideToutesLesHashTablesExactes;

				          {WritelnDansRapport('');
				          EcritDemandeAnalyseDansRapport(nroPasseAnalyse);}

				          {WritelnDansRapport('');
				          WritelnNumDansRapport('nbreCoup = ',nbreCoup);
				          WritelnNumDansRapport('analyseRetrograde.nroPasseAnalyse = ',analyseRetrograde.numeroPasse);
				          WritelnNumDansRapport('analyseRetrograde.numeroStage = ',analyseRetrograde.numeroStage);
				          WritelnNumDansRapport('analyseRetrograde.genreAnalyseEnCours = ',analyseRetrograde.genreAnalyseEnCours);}

				          {ici le corps de l'analyse}
				          if PeutReculerUnCoup &
				             (analyseRetrograde.genreAnalyseEnCours <> PasAnalyseRetrograde) then
			              repeat
			                analyseRetrograde.peutDemanderConfirmerArret := true;

				              if PeutCopierEndgameScoreFromGameTreeDansCourbe(GetCurrentNode,nbreCoup,[kFinaleParfaite,kFinaleWLD]) then DoNothing;

					            if coupPrecedentTermine then
					              DoBackMoveAnalyseRetrograde;


					            RefletePositionCouranteDansPictureIconisation;
					            SetPhasePartieRetrograde(analyseRetrograde.demande[nbreCoup,nroPasseAnalyse].genre);
					            if (analyseRetrograde.demande[nbreCoup,nroPasseAnalyse].genre = ReflRetrogradeMilieu) &
					               (analyseRetrograde.genreDerniereAmeliorationCherchee <> ReflRetrogradeMilieu)
					               then scoreOptimalPourNoir := 100*scoreOptimalPourNoir;

					            coupVerifie := GetNiemeCoupPartieCourante(numeroCoupVerifie);
					            If AQuiDeJouer = pionNoir
					              then scorePourTrait := scoreOptimalPourNoir
					              else scorePourTrait := -scoreOptimalPourNoir;
					            if (analyseRetrograde.genreAnalyseEnCours <> ReflRetrogradeMilieu) & odd(scorePourTrait) & (scorePourTrait > 0)
					              then scorePourTrait := scorePourTrait+1;

					            {WriteNumDansRapport('numeroCoupVerifie = ',numeroCoupVerifie);
					            WritelnNumDansRapport(' , nbreCoup = ',nbreCoup);}

					            handleRetrograde := NewHandleRetrograde(scorePourTrait,coupVerifie,meilleureDefense);
					            if coupPrecedentTermine then
					              EcritCoupVerifieAnalyseRetrograde(numeroCoupVerifie,coupVerifie,coupVerifieString);

					            coupFautif := Amelioration(analyseRetrograde.demande[nbreCoup,nroPasseAnalyse].genre,handleRetrograde,scorePourTrait,coupVerifie,nouveauScore,nouveauCoup);
					            if (interruptionReflexion <> pasdinterruption)
					              then
					                begin
					                  if BAnd(interruptionReflexion,interruptionDepassementTemps) = 0
					                    then EcritAnalyseInterrompueDansRapport
					                    else
					                      begin
					                        coupPrecedentTermine := false;
								                  EnleveCetteInterruption(interruptionDepassementTemps);
			                            vaDepasserTemps := false;
			                            quitterCeStage := true;
                                  { SysBeep(0);
                                    WritelnDansRapport('interruption au temps => j''arrete ce coup');
                                    WritelnNumDansRapport('interruptionReflexion = ',interruptionReflexion);}
					                      end;
					                end
					              else
					                begin
					                  if coupFautif
					                    then
					                      begin {le coup est une erreur}
					                        meilleureDefense := nouveauCoup;
					                        if AQuiDeJouer = pionNoir
					                          then scoreOptimalPourNoir := nouveauScore
					                          else scoreOptimalPourNoir := -nouveauScore;
					                        if analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeMilieu
					                          then nbPionsPerdus := (nouveauScore-scorePourTrait) div 2
					                          else nbPionsPerdus := (nouveauScore-scorePourTrait) div 2;

					                        AjoutePropertyBadMoveDansCurrentNode(numeroCoupVerifie,scorePourTrait,nouveauScore);
					                        EcritCoupFautifDansRapport(numeroCoupVerifie,scoreOptimalPourNoir,scorePourTrait,nouveauScore,nouveauCoup,nbPionsPerdus,chaineMeilleureSuite,coupVerifieString);
					                        AjouteMeilleureSuiteDansArbreDeJeuCourant(analyseRetrograde.genreAnalyseEnCours,chaineMeilleureSuite,scoreOptimalPourNoir);
					                      end
					                    else
					                      begin  {le coup est OK}
					                        meilleureDefense := coupVerifie;
					                        if analyseRetrograde.genreAnalyseEnCours = ReflRetrogradeMilieu
					                          then
					                            begin
					                              meilleureDefense := nouveauCoup;
					                              if AQuiDeJouer = pionNoir
					                                 then scoreOptimalPourNoir := nouveauScore
					                                 else scoreOptimalPourNoir := -nouveauScore;
					                              nbPionsPerdus := (nouveauScore-scorePourTrait);
					                            end;
					                        EcritCoupOKDansRapport(scoreOptimalPourNoir,numeroCoupVerifie,coupVerifie,nouveauCoup);
					                      end;

					                  AjoutePropertyValeurDeCoupDansCurrentNode(analyseRetrograde.genreAnalyseEnCours,scoreOptimalPourNoir);
					                  coupPrecedentTermine := true;
					                  dec(numeroCoupVerifie);
					                end;

					            MDisposeHandle(UnivHandle(handleRetrograde));
					            if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

					          until (interruptionReflexion <> pasdinterruption) |
					                Quitter | quitterCeStage | quitterCettePasse |
					                {(numeroCoupVerifie <= limiteAnalyseRetro) | }
					                not(PeutReculerUnCoup) |
					                (nbreCoup <= 1) | (nroPasseAnalyse > nbMaxDePassesAnalyseRetrograde) |
					                (analyseRetrograde.demande[nbreCoup-1,nroPasseAnalyse].genre <> analyseRetrograde.genreAnalyseEnCours);

				          inc(nroStageAnalyse);
				        until (nroStageAnalyse > nbMaxDeStagesAnalyseRetrograde) | (interruptionReflexion <> pasdinterruption) | Quitter | quitterCettePasse;

			        end;
			    end;
			 {
			  WritelnNumDansRapport('temps de cette passe = ',(TickCount - analyseRetrograde.tickDebutCettePasseAnalyse) div 60);
	     }
	      EffacerAnnonceAnalyseRetrogradeEnCours;
        inc(nroPasseAnalyse);
      until (nroPasseAnalyse > nbMaxDePassesAnalyseRetrograde) | (interruptionReflexion <> pasdinterruption) | Quitter;



      if (interruptionReflexion = pasdinterruption) & analyseRetrograde.enCours
         {(not(PeutReculerUnCoup) | (numeroCoupVerifie <= limiteAnalyseRetro))} then
         begin
           EcritAnalyseTermineeDansRapport;
           if not(HumCtreHum) then LanceInterruption(kHumainVeutChangerHumCtreHum,'DoAnalyseRetrograde');
         end;

      analyseRetrograde.enCours := false;
      analyseRetrograde.genreAnalyseEnCours := PasAnalyseRetrograde;
      analyseRetrograde.tempsDernierCoupAnalyse := 0;

      NettoieToutApresAnalyseRetrograde(oldInterruption);
    end;
end;


function EstDansBanniereAnalyseRetrograde(positionClic : SInt32) : boolean;
var s,s1,s2 : String255;
    pos1,pos2,pos3 : SInt32;
begin
  {WritelnDansRapport('entrée de EstDansBanniereAnalyseRetrograde');}

  EstDansBanniereAnalyseRetrograde := false;

  s := ReadStringFromRessource(TextesRetrogradeID,1);  {'###################'}
  s1 := Concat(chr(13),chr(13),s);
  s2 := Concat(s,chr(13));

  if FindStringInRapport(s1, positionClic - 2, -1, pos1) &
     FindStringInRapport(s2, positionClic-LENGTH_OF_STRING(s2)+1, +1, pos2)
    then
      begin
        if FindStringInRapport(s1, positionClic, +1, pos3)
          then EstDansBanniereAnalyseRetrograde := ((pos2 - pos1) <= 400) & (pos2 <> pos3 + 2)
          else EstDansBanniereAnalyseRetrograde := (pos2 - pos1) <= 400;
      end;

  {WritelnDansRapport('sortie de EstDansBanniereAnalyseRetrograde');}
end;

procedure SelectionneAnalyseRetrograde(positionClic : SInt32);
var s1,s2 : String255;
    pos1,pos2,posDebut,posFin : SInt32;
begin
  {WritelnDansRapport('entrée dans SelectionneAnalyseRetrograde');}

  s1 := ReadStringFromRessource(TextesRetrogradeID,1);  {'###################'}
  s1 := Concat(chr(13),chr(13),s1);


  if FindStringInRapport(s1,positionClic,-1,pos1) then
   begin
     posDebut := pos1 + 2;
     posFin := 100000000;

     s2 := ReadStringFromRessource(TextesRetrogradeID,5);  {analyse retrograde en cours…}
     if FindStringInRapport(s2,positionClic,+1,pos2) then
       posFin := Min(posFin,pos2+LENGTH_OF_STRING(s2));

     s2 := ReadStringFromRessource(TextesRetrogradeID,6);  {analyse retrograde interrompue…}
     if FindStringInRapport(s2,positionClic,+1,pos2) then
       posFin := Min(posFin,pos2+LENGTH_OF_STRING(s2));

     s2 := ReadStringFromRessource(TextesRetrogradeID,7);  {analyse retrograde terminée…}
     if FindStringInRapport(s2,positionClic,+1,pos2) then
       posFin := Min(posFin,pos2+LENGTH_OF_STRING(s2));

     {si on a trouve une des 3 phrases terminales…}
     if (posFin < 100000000) then
       begin
         SelectionnerTexteDansRapport(posDebut,posFin);
         exit(SelectionneAnalyseRetrograde);
       end;

    end;

  {WritelnDansRapport('sortie normale de SelectionneAnalyseRetrograde');}
end;


function AnalyseRetrogradeEnCours : boolean;
begin
  AnalyseRetrogradeEnCours := analyseRetrograde.enCours;
end;


function PeutArreterAnalyseRetrograde : boolean;
const ConfirmationArretRetroID = 150;
      Annuler = 2;
      Interrompre = 1;
var itemHit : SInt16;
begin
  PeutArreterAnalyseRetrograde := true;
  with analyseRetrograde do
  if enCours & doitConfirmerArret & peutDemanderConfirmerArret & not(Quitter) then
    if ((TickCount-tickDebutAnalyse) div 3600) >= nbMinPourConfirmationArret then
        begin

          itemHit := AlertTwoButtonsFromRessource(ConfirmationArretRetroID,3,0,Interrompre,Annuler);

          if (itemHit = Annuler)
            then
              PeutArreterAnalyseRetrograde := false
            else
              begin
                PeutArreterAnalyseRetrograde := true;
                analyseRetrograde.peutDemanderConfirmerArret := false;
              end;

        end;
end;


END.
