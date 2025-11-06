UNIT UnitActions;


INTERFACE







 USES
     {$IFC USE_PROFILER_OUVERTURE_FICHIERS}
     Profiler ,
     {$ENDC}
     UnitDefCassio , Files;



procedure InitUnitActions;
procedure LibereMemoireUnitActions;

function ComprendPositionEtPartieDuFichier(nomFichier : String255; positionEtpartie : String255; mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatCassio(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatGGF(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierFormatEPS(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
function OuvrirFichierPartieFSp(fichier : fileInfo; whichFormats : SetOfKnownFormats; mergeWithCurrentTree : boolean) : OSErr;
procedure DoOuvrir;
procedure DoEnregistrerSousFormatCassio(modifiers : SInt16);
procedure DoEnregistrerSousFormatSmartGameBoard;
procedure DoEnregistrerSous(useSmartGameBoardFormat : boolean);
procedure DoOuvrirBibliotheque;
procedure DoEcritureSolutionSolitaire;
procedure PrepareNouvellePartie(ForceHumCtreHum : boolean);
procedure DoChangeAlerteInterversion;
{procedure DoChangeEvaluationAleatoire;}
procedure DoChangeEvaluationTablesDeCoins;
procedure DoChangeEvaluationDeFisher;
procedure DoChangeRefutationsDansRapport;
{procedure DoChangePionClignotant;}
{procedure DoChangeTorique;}
procedure DoNouvellePartie(ForceHumCtreHum : boolean);
procedure DoClose(whichWindow : WindowPtr; avecAnimationZoom : boolean);
procedure DoAjouteTemps(aQui : SInt16);
procedure DoSon;
procedure DoDemandeChangeCouleur;
procedure DoDemandeJouerSolitaires;
procedure DoDemandeChangerHumCtreHum;
procedure DoDemandeChangerHumCtreHumEtCouleur;
procedure DoDemandeCassioPrendLesBlancs;
procedure DoDemandeCassioPrendLesNoirs;
procedure DoDemandeCassioAnalyseLesDeuxCouleurs;
procedure DetruitSousArbreCourantEtBackMove;
procedure DoDialogueDetruitSousArbreCourant;
procedure DoTraiteBaseDeDonnee(actionDemandee : SInt16);
procedure DoChargerLaBase;
function AutorisationDeChargerLaBaseSansInterventionUtilisateur : boolean;
procedure DoChargerLaBaseSansInterventionUtilisateur;
procedure DoDemandeAnalyseRetrograde(sansDialogueRetrograde : boolean);
procedure DoParametrerAnalyseRetrograde;
procedure ToggleAideDebutant;
procedure DoTraiteClicEscargot;
procedure DoTracerNuage;
procedure DoChangeAfficheDernierCoup;
procedure DoChangeAfficheReflexion;
procedure DoChangeAfficheBibliotheque;
procedure DoChangeAfficheGestionTemps;
procedure DoChangeAfficheNuage;
procedure DoChangeAfficheSuggestionDeCassio;
procedure DoChangeAfficheMeilleureSuite;
procedure DoChangeAffichePierresDelta;
procedure DoChangeAfficheProchainsCoups;
procedure DoChangeAfficheSignesDiacritiques;
procedure DoChangeAfficheNotesSurCases(origine : SInt32);
procedure DoChangeEn3D(avecAlerte : boolean);
procedure DoRevenir;
procedure DoDebut(ForceHumCtreHum : boolean);
procedure DoCoefficientsEvaluation;
procedure DoMakeMainBranch;
procedure DoCourbe;
procedure DoRapport;
{procedure DoChangeSensLargeSolitaire;}
procedure DoChangeReferencesCompletes;
{procedure DoChangeFinaleEnSolitaire;}
procedure DoChangePalette;
procedure DoStatistiques;
procedure DoListeDeParties;
procedure DoChangeDessineAide;
procedure DoChangeAfficheInfosApprentissage;
procedure DoChangeUtiliseGrapheApprentissage;
procedure DoChangeLaDemoApprend;
procedure DoChangeEffetSpecial1;
procedure DoChangeEffetSpecial2;
procedure DoChangeEffetSpecial3;
{procedure DoChangeEffetSpecial4;}
{procedure DoChangeEffetSpecial5;}
{procedure DoChangeEffetSpecial6;}
{procedure DoChangeSelectivite;}
procedure DoChangeNomOuverture;
{procedure DoChangeEcran512;}
{procedure DoChangeToujoursIndexer;}
procedure DoChangeAvecSystemeCoordonnees;
procedure DoChangeGarderPartieNoireADroiteOthellier;
procedure DoChangeAvecReflexionTempsAdverse;
procedure DoChangeAvecBibl;
procedure DoChangeVarierOuvertures;
procedure DoChangeJoueBonsCoupsBibl;
procedure DoChangeEnModeIOS;
procedure DoChangeSousEmulatorSousPC;
procedure DoChangeInfosTechniques;
procedure DoChangeEcrireDansRapportLog;
procedure DoChangeUtilisationNouvelleEval;
procedure DoChangeUtiliserMetaphone;
procedure DoChangeEnTraitementDeTexte;
procedure DoChangePostscriptCompatibleXPress;
procedure DoChangeArrondirEvaluations;
procedure DoChangeFaireConfianceScoresArbre;
(*procedure DoChangeAfficheCoupTete;*)
procedure DoChangeInterversions;
procedure DoChoisitDemo;
{procedure DoChangeAnalyse;}
procedure DoChangeProfImposee;
procedure DoSetUp;
procedure FermeToutEtQuitte;
procedure FermeToutesLesFenetresAuxiliaires;
procedure DoCloseCmd(modifiers : SInt16);
procedure DoQuit;
procedure DoMaster;
procedure DoSymetrie(axe : SInt32);
procedure OuvrePartieSelectionnee(nroHilite : SInt32);
procedure DoProgrammation;
procedure DoPommeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoFileMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoEditionMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoCopierSpecialMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoNMeilleursCoupsMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoPartieMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoModeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoJoueursMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoAffichageMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoSolitairesMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoProgrammationMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoCouleurMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoPicture2DMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean; avecAlerte : boolean);
procedure DoPicture3DMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean; avecAlerte : boolean);
procedure DoTriMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoFormatBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoReouvrirMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoGestionBaseWThorMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
procedure DoMenuCommand(command : SInt32; var peutRepeter : boolean);
procedure DoKeyPress(ch : char; var peutRepeter : boolean);
function ToucheCommandeInterceptee(ch : char; evt : eventRecord; var peutRepeter : boolean) : boolean;
function EvenementTraiteParFenetreArbreDeJeu(evt : eventRecord) : boolean;
procedure MetFlagsModifiersDernierEvenement(var whichEvent : eventRecord; var modifiersChanged : boolean);
procedure TesterAffichageNomsDesGagnantsEnGras(modifiers : SInt16);
procedure TesterAffichageNomsJaponaisEnRoman(modifiers : SInt16);
procedure TraiteSourisStandard(mouseLoc : Point; modifiers : SInt16);
procedure TraiteSourisRetour(mouseLoc : Point; modifiers : SInt16);
procedure TraiteSourisFntrPlateau(evt : eventRecord);
procedure TraiteSourisPalette(evt : eventRecord);
procedure TraiteSourisAide(evt : eventRecord);
procedure TraiteSourisStatistiques(evt : eventRecord);
procedure TraiteSourisCommentaires(evt : eventRecord; fenetreActiveeParCeClic : boolean);
{procedure TraiteSourisGestion(evt : eventRecord);}
procedure TraiteSourisRapport(evt : eventRecord);

(*********************** displayHandlers ***************************)

procedure DrawContents(whichWindow : WindowPtr);
procedure DoUpdateWindow(whichWindow : WindowPtr);
procedure EssaieUpdateEventsWindowPlateau;



(*********************** event handlers ****************************)

procedure KeyUpEvents;
procedure KeyDownEvents;
procedure MouseDownEvents;
procedure MouseUpEvents;
procedure UpdateEvents;
procedure MultiFinderEvents;
procedure ActivateEvents;
procedure DoAppleEvents;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    AEInteraction, UnitDebuggage, ToolUtils, MacErrors, OSUtils, Sound, ControlDefinitions, Scrap
    , Processes, MacWindows, TextServices, MacMemory, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , UnitSaisiePartie, UnitListe, UnitCompilation, UnitTestZoo, UnitFFO
    , UnitZoo, UnitImportDesNoms, Zebra_to_Cassio, MyQuickDraw, SNMenus, UnitPositionEtTrait, UnitRapportImplementation, UnitNotesSurCases
    , UnitSelectionRapideListe, UnitServicesRapport, UnitCarbonisation, UnitTraceLog, UnitClassement, UnitAccesNouveauFormat, UnitUtilitaires, UnitFenetres
    , UnitNouvelleEval, UnitBibl, UnitCalculCouleurCassio, UnitAffichageArbreDeJeu, UnitAffichageReflexion, UnitMilieuDePartie, UnitArbreDeJeuCourant, UnitMoveRecords
    , UnitPierresDelta, UnitServicesDialogs, UnitTournoi, UnitEntreeTranscript, UnitSetUp, MyFileSystemUtils, UnitJeu, UnitPhasesPartie
    , UnitFinaleFast, UnitBaseNouveauFormat, UnitInitValeursBlocs, UnitBords, UnitVieilOthelliste, UnitPrefs, UnitCriteres, UnitInterversions
    , UnitRetrograde, UnitSolitaire, UnitPrint, UnitIconisation, UnitTestNouveauFormat, UnitTriListe, UnitEntreesSortiesListe, UnitRegressionLineaire
    , UnitGameTree, UnitSmartGameBoard, UnitFichierPhotos, UnitJaponais, UnitScripts, UnitTestNouvelleEval, UnitRapport, UnitMiniProfiler
    , UnitEntreesSortiesGraphe, UnitApprentissagePartie, UnitGrapheInterversions, UnitScannerUtils, UnitPotentiels, UnitBitboardAlphaBeta, UnitSauvegardeRapport, UnitSolitairesNouveauFormat
    , UnitRechercheSolitaires, UnitMoulinette, UnitTHOR_PAR, Unit3DPovRayPicts, UnitFichiersPICT, MyUtils, UnitCassioSounds, UnitTroisiemeDimension
    , UnitBufferedPICT, UnitGenericGameFormat, UnitGestionDuTemps, UnitBitboardMobilite, UnitPressePapier, UnitFormatsFichiers, UnitSymetrieDuRapport, UnitMenus
    , UnitStatistiques, UnitBaseOfficielle, UnitSuperviseur, UnitStrategie, UnitTore, UnitDialog, MyStrings, UnitLiveUndo
    , UnitProblemeDePriseDeCoin, UnitCourbe, UnitCFNetworkHTTP, UnitZoo, SNEvents, UnitLongintScroller, UnitNormalisation, UnitPackedThorGame
    , MyMathUtils, basicfile, UnitGeometrie, MyKeyMapUtils, UnitScannerOthellistique, UnitRapportUtils, UnitRapportWindow, UnitEvenement
    , UnitCurseur, UnitBallade, UnitOth2, UnitModes, UnitPalette, UnitCommentaireArbreDeJeu, UnitAccesGraphe, UnitSquareSet
    , UnitVecteursEvalInteger, UnitProperties, UnitPropertyList, UnitFichierAbstrait, UnitNewGeneral, UnitServicesMemoire, UnitAffichagePlateau, UnitListe
    , UnitDiagramFforum, UnitNouveauFormat, UnitSound, UnitEngine ;
{$ELSEC}
    ;
    {$I prelink/Actions.lk}
{$ENDC}


{END_USE_CLAUSE}







procedure InitUnitActions;
begin


  with gKeyDownEventsData do
    begin
      niveauxDeRecursionDansDoKeyPress               := 0;
      repetitionEnCours                              := false;
      noDelay                                        := false;
      delaiAvantDebutRepetition                      := 15;
      tickFrappeTouche                               := 0;
      tickChangementClavier                          := 0;
      theChar                                        := chr(0);
      keyCode                                        := 0;
      tickcountMinimalPourNouvelleRepetitionDeTouche := 0;
    end;
end;


procedure LibereMemoireUnitActions;
begin
end;


function ComprendPositionEtPartieDuFichier(nomFichier : String255; positionEtpartie : String255; mergeWithCurrentTree : boolean) : OSErr;
var platAux : plateauOthello;
    i,j,x,t,compt,mobilite,nombreCoupsRepris : SInt32;
    plateauEnString : String255;
    c : char;
    oldPort : grafPtr;
    temposon,tempobibl : boolean;
    tempoAfficheNumeroCoup : boolean;
    tempoCalculsActives : boolean;
    tempoAfficheInfosApprentissage : boolean;
    err : OSErr;
    legal : boolean;
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    tempoAvecDelaiDeRetournementDesPions : boolean;
    trait, tick : SInt32;
    usingZebraBookArrivee : boolean;
    tempoEnTrainDeRejouerUnePartie : boolean;
    oldCheckDangerousEvents : boolean;
begin
  err := 0;


  if LENGTH_OF_STRING(positionEtpartie) < 64 then
    begin
      AlerteFormatNonReconnuFichierPartie(nomFichier);
      ComprendPositionEtPartieDuFichier := -1;  {on rapporte l'erreur}
      exit;
    end;

  BeginUseZebraNodes('ComprendPositionEtPartieDuFichier');
  usingZebraBookArrivee := GetUsingZebraBook;
  SetUsingZebraBook(false);

  //BeginFonctionModifiantNbreCoup('ComprendPositionEtPartieDuFichier');
  SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

  tick := TickCount;

  temposon := avecSon;
  tempoBibl := afficheBibl;
  tempoCalculsActives := avecCalculPartiesActives;
  tempoAfficheNumeroCoup := afficheNumeroCoup;
  tempoAfficheInfosApprentissage := afficheInfosApprentissage;
  tempoAvecDelaiDeRetournementDesPions := avecDelaiDeRetournementDesPions;
  tempoEnTrainDeRejouerUnePartie := EnTrainDeRejouerUnePartie;

  ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
  EffaceProprietesOfCurrentNode;
  SetEffacageProprietesOfCurrentNode(kAucunePropriete);
  SetAffichageProprietesOfCurrentNode(kAucunePropriete);

  avecSon := false;
  afficheBibl := false;
  avecCalculPartiesActives := false;
  afficheNumeroCoup := false;
  afficheInfosApprentissage := false;
  avecDelaiDeRetournementDesPions := false;
  SetEnTrainDeRejouerUnePartie(true);

  EffacerTouteLaCourbe('ComprendPositionEtPartieDuFichier');
  DessineSliderFenetreCourbe;
  if not(windowPlateauOpen) then OuvreFntrPlateau(false);


  plateauEnString := TPCopy(positionEtpartie,1,64);

  { 'plateauEnString' contient désormais une description de l'othellier }

  Delete(positionEtpartie,1,64);
  EnleveEspacesDeGaucheSurPlace(positionEtpartie);

  { 'positionEtpartie' contient désormais :
      - (optionel) un caractere décrivant le trait + une espace
        attention : espace obligatoire si le trait est present
      - suivis d'une liste de coups

    exemples :
      positionEtpartie = 'X F5D6C3D3C4'
      positionEtpartie = 'F5D6C3D3C4'
  }


  { On parse la chaine 'plateauEnString' pour remplir le plateau }

  MemoryFillChar(@platAux,sizeof(plataux),chr(0));
  for i := 0 to 99 do
    if interdit[i] then platAux[i] := PionInterdit;

  compt := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        compt := compt+1;
        x := 10*i+j;
        c := plateauEnString[compt];
        if (c = 'o') or (c = 'O') or (c = '0') or (c = 'w') or (c = 'W')                         then plataux[x] := pionBlanc;
        if (c = 'x') or (c = 'X') or (c = '#') or (c = '*') or (c = '•') or (c = 'b') or (c = 'B') then plataux[x] := pionNoir;
      end;


   { on essaye de trouver une information de trait dans 'positionEtpartie',
     sinon on prendra plus tard le trait de la parite naturelle }

   trait := pionVide;

   if (LENGTH_OF_STRING(positionEtpartie) = 1) or
      ((LENGTH_OF_STRING(positionEtpartie) >= 2) and (positionEtpartie[2] = ' ')) then
     begin
       c := positionEtpartie[1];
       if (c = 'o') or (c = 'O') or (c = '0') or (c = 'w') or (c = 'W') then trait := pionBlanc else
       if (c = 'x') or (c = 'X') or (c = '#') or (c = '*') or (c = '•') or (c = 'b') or (c = 'B') then trait := pionNoir;
     end;

   { pour determiner le trait de la parité naturelle, nous aurons besoin
     du nombre de pions de chaque couleur }

   nbreDePions[pionNoir] := 0;
   nbreDePions[pionBlanc] := 0;
   for i := 1 to 64 do
     begin
       t := othellier[i];
       if plataux[t] <> pionVide then
         nbreDePions[plataux[t]] := nbreDePions[plataux[t]]+1;
     end;
   nbreCoup := nbreDePions[pionNoir]+nbreDePions[pionBlanc]-4;

   { On décide du trait, finalement }

   if trait = pionVide then
     begin
       if odd(nbreCoup)
         then trait := pionBlanc
         else trait := pionNoir;
     end;

   SetJeuCourant(platAux,trait);

   ViderValeursDeLaCourbe;

   nroDernierCoupAtteint := nbreCoup;
   IndexProchainFilsDansGraphe := -1;
   MyDisableItem(PartieMenu,ForwardCmd);
   FixeMarqueSurMenuMode(nbreCoup);
   if avecInterversions then PreouvrirGraphesUsuels;

   oldPositionFeerique := positionFeerique;
   positionFeerique := not(EstLaPositionStandardDeDepart(JeuCourant));
   if positionFeerique then nbPartiesActives := 0;

   doitDetruireAncienArbreDeJeu := not(mergeWithCurrentTree) or positionFeerique or oldPositionFeerique;
   ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);
   SetCurrentNodeToGameRoot;
   MarquerCurrentNodeCommeReel('ComprendPositionEtPartieDuFichier');

   InitialiseDirectionsJouables;
   CarteJouable(JeuCourant,emplJouable);




  (* if avecDessinCoupEnTete then EffaceCoupEnTete;
   SetCoupEntete(0);*)
   gameOver := false;
   PartieContreMacDeBoutEnBout := false;
   peutfeliciter := true;

   if AQuiDeJouer = pionVide then TachesUsuellesPourGameOver;


     SetPositionInitialeOfGameTree(JeuCourant,AQuiDeJouer,nbreDePions[pionBlanc],nbreDePions[pionNoir]);
     AddInfosStandardsFormatSGFDansArbre;
     if doitDetruireAncienArbreDeJeu then
       AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant,GetRacineDeLaPartie);

     CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
     CarteFrontiere(JeuCourant,frontiereCourante);
     meilleurCoupHum := 0;
     RefleSurTempsJoueur := false;
     LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'ComprendPositionEtPartieDuFichier');
     LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'ComprendPositionEtPartieDuFichier');
     vaDepasserTemps := false;
     reponsePrete := false;
     MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
     MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
     VideMeilleureSuiteInfos;
     MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
     MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));
     aideDebutant := false;
     dernierTick := TickCount;
     EssaieDisableForceCmd;


     if not(windowPlateauOpen) then OuvreFntrPlateau(false);
     MetTitreFenetrePlateau;
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     DessinePlateau(true);
     for i := 1 to 8 do
       for j := 1 to 8 do
         begin
           x := 10*i+j;
           if (GetCouleurOfSquareDansJeuCourant(x) = pionNoir) or (GetCouleurOfSquareDansJeuCourant(x) = pionBlanc)
             then DessinePion(x,GetCouleurOfSquareDansJeuCourant(x));
         end;


     MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));  { pour l'affichage }

     CompacterPartieAlphanumerique(positionEtpartie,kCompacterTelQuel);


     nombreCoupsRepris := LENGTH_OF_STRING(positionEtpartie) div 2;
     for i := 1 to nombreCoupsRepris do
       begin
         SetUsingZebraBook(false);
         x := PositionDansStringAlphaEnCoup(positionEtpartie,2*i-1);
         if PeutJouerIci(AQuiDeJouer,x,JeuCourant)
            and JoueEn(x,PositionEtTraitCourant,legal,true,(i = nombreCoupsRepris),'ComprendPositionEtPartieDuFichier')
           then
              DoNothing
           else
             if (AQuiDeJouer = pionVide) then TachesUsuellesPourGameOver;
       end;

   afficheNumeroCoup := tempoAfficheNumeroCoup;
   if afficheNumeroCoup and (nbreCoup > 0) then
      begin
        x := DerniereCaseJouee;
        if InRange(x,11,88) then
          DessineNumeroCoup(x,nbreCoup,-GetCouleurOfSquareDansJeuCourant(x),GetCurrentNode);
      end;

   SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
   SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
   AfficheProprietesOfCurrentNode(false,othellierToutEntier,'ComprendPositionEtPartieDuBuffer');

   CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
   if mobilite = 0 then TachesUsuellesPourGameOver;


   dernierTick := TickCount;
   Heure(pionNoir);
   Heure(pionBlanc);
   AfficheScore;
   ReinitilaliseInfosAffichageReflexion;
   if affichageReflexion.doitAfficher then EffaceReflexion(HumCtreHum);
   SetValeursGestionTemps(0,0,0,0.0,0,0);
   MyDisableItem(PartieMenu,ForceCmd);
   AfficheDemandeCoup;
   avecSon := temposon;
   afficheBibl := tempobibl;
   afficheInfosApprentissage := tempoAfficheInfosApprentissage;
   avecDelaiDeRetournementDesPions := tempoAvecDelaiDeRetournementDesPions;
   SetEnTrainDeRejouerUnePartie(tempoEnTrainDeRejouerUnePartie);
   avecCalculPartiesActives := true;
   {la}
   phaseDeLaPartie := CalculePhasePartie(nbreCoup);
   gDoitJouerMeilleureReponse := false;
   Initialise_table_heuristique(JeuCourant,false);
   DessineBoiteDeTaille(wPlateauPtr);
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
   NoUpdateWindowPlateau;
   if avecInterversions then FermerGraphesUsuels;
   SetPort(oldPort);
   AjusteCurseur;

   LanceInterruptionSimpleConditionnelle('ComprendPositionEtPartieDuFichier');

   FlushWindow(wPlateauPtr);

   MetTitreFenetrePlateau;
   if afficheInfosApprentissage then EcritLesInfosDApprentissage;

   SetUsingZebraBook(usingZebraBookArrivee);
   EndUseZebraNodes('ComprendPositionEtPartieDuFichier');

   {WritelnNumDansRapport('temps = ',TickCount - tick);}

   //EndFonctionModifiantNbreCoup('ComprendPositionEtPartieDuFichier');

   LireBibliothequeDeZebraPourCurrentNode('ComprendPositionEtPartieDuBuffer');
   DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'ComprendPositionEtPartieDuBuffer');


   SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);


   if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);

   ComprendPositionEtPartieDuFichier := err;
end;


function OuvrirFichierPartieFormatCassio(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomFichier doit etre un path complet }
var chainePositionEtPartie,s : String255;
    erreurES : SInt16;
    nomLongDuFichier : String255;
    ficPartie : basicfile;
    texteDuFichierMisDansRapport : boolean;
    debutSelection,finSelection : SInt32;
    infos : FormatFichierRec;
    position : SInt32;
begin
  OuvrirFichierPartieFormatCassio := -1;

  if not(PeutArreterAnalyseRetrograde) then
    exit;

  if nomFichier = '' then
    begin
      AlerteSimpleFichierTexte(nomFichier,0);
      exit;
    end;

  {SetDebugFiles(false);}

  erreurES := FileExists(nomFichier,0,ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatCassio := erreurES;
      exit;
    end;


  if TypeDeFichierEstConnu(ficPartie,infos,erreurES)
     and ((infos.format = kTypeFichierCassio) or
        (infos.format = kTypeFichierXBoardAlien) or
        (infos.format = kTypeFichierHTMLOthelloBrowser) or
        (infos.format = kTypeFichierTranscript) or
        (infos.format = kTypeFichierZebra) or
        (infos.format = kTypeFichierExportTexteDeZebra) or
        (infos.format = kTypeFichierSimplementDesCoups) or
        (infos.format = kTypeFichierLigneAvecJoueurEtPartie))
     and (infos.tailleOthellier = 8)
    then
      begin
        chainePositionEtPartie := infos.positionEtPartie;
      end
    else
      begin
        erreurES := ExtractFileName(nomFichier,nomLongDuFichier);
        AlerteFormatNonReconnuFichierPartie(nomLongDuFichier);
        exit;
      end;

  erreurES := OpenFile(ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatCassio := erreurES;
      exit;
    end;

  erreurES := ExtractFileName(ficPartie.info, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);


  SetNomFichierDansTitreDiagrammeFFORUM(nomLongDuFichier);
  titrePartie^^ := nomLongDuFichier;
  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  finaleEnModeSolitaire := false;

  position := Pos(DirectorySeparator , nomFichier);
  while position <> 0 do
     begin
       nomFichier := TPCopy(nomFichier,position+1,LENGTH_OF_STRING(nomFichier)-position);
       position := Pos(DirectorySeparator , nomFichier);
     end;


  erreurES := ComprendPositionEtPartieDuFichier(nomFichier,chainePositionEtPartie,mergeWithCurrentTree);


  texteDuFichierMisDansRapport := false;
  FinRapport;
  TextNormalDansRapport;
  debutSelection := GetPositionPointDinsertion;
  finSelection := debutSelection;

  if (erreurES <> NoErr) then
    begin
      OuvrirFichierPartieFormatCassio := erreurES;
      erreurES := CloseFile(ficPartie);
      exit;
    end
  else
    if not(EndOfFile(ficPartie,erreurES)) then
    begin
      while not(EndOfFile(ficPartie,erreurES)) do
        begin
          erreurES := Readln(ficPartie,s);
          if Pos('¬R¬',s) = 1 then  {rapport}
            begin
              texteDuFichierMisDansRapport := true;
              s := TPCopy(s,4,LENGTH_OF_STRING(s)-3);
              if s[LENGTH_OF_STRING(s)] = '¶'
                then
                  begin
                    s := TPCopy(s,1,LENGTH_OF_STRING(s)-1);
                    WritelnDansRapportSync(s,false);
                  end
                else
                  WriteDansRapportSync(s,false);
            end;
          if s[1] = '%' then   {commentaire}
            begin
              {nothing}
            end;
        end;
      if texteDuFichierMisDansRapport then
        begin
          WritelnDansRapportSync('',false);
          finSelection := GetPositionPointDinsertion;
          WritelnDansRapportSync('',false);
        end;
    end;
  UpdateScrollersRapport;

  if FenetreRapportEstOuverte then InvalidateWindow(GetRapportWindow);
  if not(CassioEstEnModeAnalyse) and not(HumCtreHum)
    then DoChangeHumCtreHum;

  erreurES := CloseFile(ficPartie);

  if texteDuFichierMisDansRapport then
    begin
      AppliquerStyleDuFichierAuRapport(ficPartie,debutSelection,finSelection);
      FinRapport;
      TextNormalDansRapport;
    end;

  OuvrirFichierPartieFormatCassio := NoErr;
end;




function OuvrirFichierFormatEPS(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomFichier doit etre un path complet }
type InfosOthelloDansEPS = record
                             initialPosition : String255;
                             moves           : String255;
                             moveNumber      : String255;
                             SGFAnnotations  : String255;
                             diagramComment  : String255;
                             diagramTitle    : String255;
                           end;
var erreurES : OSErr;
    ficPartie : basicfile;
    ligne, foo : String255;
    infosFichier : InfosOthelloDansEPS;
    infosReelles : InfosOthelloDansEPS;
    compteurLignes : SInt32;
    whichPosition : PositionEtTraitRec;
    changed : boolean;
begin

  OuvrirFichierFormatEPS := -1;

  if nomFichier = '' then
    begin
      AlerteSimpleFichierTexte(nomFichier,0);
      exit;
    end;

  erreurES := FileExists(nomFichier,0,ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier, erreurES);
      OuvrirFichierFormatEPS := erreurES;
      exit;
    end;

  erreurES := OpenFile(ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier, erreurES);
      OuvrirFichierFormatEPS := erreurES;
      exit;
    end;


  infosFichier.initialPosition := PositionEtTraitInitiauxStandardEnString;
  infosFichier.moves           := '';
  infosFichier.moveNumber      := '';
  infosFichier.SGFAnnotations  := '';
  infosFichier.diagramComment  := '';
  infosFichier.diagramTitle    := '';


  compteurLignes := 0;

  repeat
    inc(compteurLignes);
    erreurES := Readln(ficPartie,ligne);
    if (ligne <> '') then
      begin
        (* WritelnDansRapport(ligne); *)

        if (Pos('%%Othello-initial-position: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.initialPosition);

        if (Pos('%%Othello-moves: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.moves);

        if (Pos('%%Othello-current-move-number: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.moveNumber);

        if (Pos('%%Othello-SGF-annotations: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.SGFAnnotations);

        if (Pos('%%Othello-diagram-comment: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.diagramComment);

        if (Pos('%%Othello-diagram-title: ', ligne) = 1) then
          Parse(ligne, foo, infosFichier.diagramTitle);

      end;
  until (compteurLignes > 20) or (erreurES <> NoErr) or EndOfFile(ficPartie,erreurES) or (Pos('%%BeginProlog',ligne) = 1);


  erreurES := CloseFile(ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier, erreurES);
      OuvrirFichierFormatEPS := erreurES;
      exit;
    end;


  whichPosition                := GetPositionEtTraitInitiauxOfGameTree;
  infosReelles.initialPosition := PositionEtTraitEnString(whichPosition);
  infosReelles.moves           := PartiePourPressePapier(true,false,60);
  infosReelles.moveNumber      := IntToStr(nbreCoup);
  infosReelles.SGFAnnotations  := GetPierresDeltaCourantesEnString;
  infosReelles.diagramComment  := ParamDiagPositionFFORUM.commentPositionFFORUM^^;
  infosReelles.diagramTitle    := ParamDiagPartieFFORUM.titreFFORUM^^;

  (*
  WritelnDansRapport('infos reelles : ');
  WritelnDansRapport('initialPosition = ' + infosReelles.initialPosition);
  WritelnDansRapport('moves = '           + infosReelles.moves);
  WritelnDansRapport('moveNumber = '      + infosReelles.moveNumber);
  WritelnDansRapport('SGFAnnotations = '  + infosReelles.SGFAnnotations);
  *)

  if (infosFichier.initialPosition = infosReelles.initialPosition) and
     (infosFichier.moves           = infosReelles.moves)           and
     (infosFichier.moveNumber      = infosReelles.moveNumber)      and
     (infosFichier.SGFAnnotations  = infosReelles.SGFAnnotations)  and
     (infosFichier.diagramComment  = infosReelles.diagramComment)  and
     (infosFichier.diagramTitle    = infosReelles.diagramTitle)    then
     begin
       // tout est déjà là, hein
       OuvrirFichierFormatEPS := NoErr;
       exit;
     end;


  if not(PeutArreterAnalyseRetrograde) then
    exit;

  (*
  WritelnDansRapport('infos fichier : ');
  WritelnDansRapport('initialPosition = ' + infosFichier.initialPosition);
  WritelnDansRapport('moves = '           + infosFichier.moves);
  WritelnDansRapport('moveNumber = '      + infosFichier.moveNumber);
  WritelnDansRapport('SGFAnnotations = '  + infosFichier.SGFAnnotations);
  *)

  with infosFichier do
    begin
      if not(mergeWithCurrentTree) then DoNouvellePartie(false);

      erreurES := PlaquerPositionEtPartieFictive(initialPosition, moves, 60);

      if erreurES = NoErr then
        begin
          if (SGFAnnotations <> '') or (not((moveNumber = '0') and (LENGTH_OF_STRING(moves) = 120)))
            then DoRetourAuCoupNro(StrToInt32(moveNumber), true, false);

          if (SGFAnnotations <> '') then
             begin
               affichePierresDelta := true;
               changed := AddPropertyListAsStringDansCurrentNode(SGFAnnotations);
               AfficheProprietesOfCurrentNode(true,othellierToutEntier,'OuvrirFichierFormatEPS');
             end;

          if (diagramComment <> '') then ParamDiagPositionFFORUM.commentPositionFFORUM^^ := diagramComment;

          if (diagramTitle <> '')   then ParamDiagPartieFFORUM.titreFFORUM^^ := diagramTitle;
        end;
    end;

  OuvrirFichierFormatEPS := erreurES;
end;



function OuvrirFichierPartieFormatGGF(nomFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
{ attention! On doit être dans le bon repertoire, ou nomFichier doit etre un path complet }
var partieEnAlpha : String255;
    erreurES : SInt16;
    nomLongDuFichier : String255;
    ficPartie : basicfile;
    infos : FormatFichierRec;
    posInitialeDansFichier : PositionEtTraitRec;
begin  {$UNUSED mergeWithCurrentTree}
  OuvrirFichierPartieFormatGGF := -1;

  if not(PeutArreterAnalyseRetrograde) then
    exit;

  if nomFichier = '' then
    begin
      AlerteSimpleFichierTexte(nomFichier,0);
      exit;
    end;

  {SetDebugFiles(false);}

  erreurES := FileExists(nomFichier,0,ficPartie);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichier,erreurES);
      OuvrirFichierPartieFormatGGF := erreurES;
      exit;
    end;

  if TypeDeFichierEstConnu(ficPartie,infos,erreurES) and
     (infos.format = kTypeFichierGGF) and (infos.tailleOthellier = 8)
    then
      begin
        nomLongDuFichier := nomFichier;
        erreurES := GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(ficPartie,kTypeFichierGGF,posInitialeDansFichier,partieEnAlpha);
        if (erreurES <> 0)
          then
            begin
              SysBeep(0);
              WritelnNumDansRapport('ERREUR !!! Dans OuvrirFichierPartieFormatGGF, erreurES = ',erreurES);
              OuvrirFichierPartieFormatGGF := erreurES;
              exit;
            end
          else
            begin
              PlaquerPositionEtPartie(posInitialeDansFichier,partieEnAlpha,kRejouerLesCoupsEnDirect);
              erreurES := ExtractFileName(ficPartie.info, nomLongDuFichier);
              AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
            end;
      end
    else
      begin
        AlerteFormatNonReconnuFichierPartie(nomFichier);
        exit;
      end;

  SetNomFichierDansTitreDiagrammeFFORUM(nomLongDuFichier);
  titrePartie^^ := nomLongDuFichier;


  if not(CassioEstEnModeAnalyse) and not(HumCtreHum)
    then DoChangeHumCtreHum;

  OuvrirFichierPartieFormatGGF := NoErr;
end;


function OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier : String255; mergeWithCurrentTree : boolean) : OSErr;
var theFile : FichierAbstrait;
    ficPartie : basicfile;
    erreurES : SInt16;
    tick : SInt32;
    theDate : DateTimeRec;
    nomLongDuFichier : String255;
    nomCourt,dateModifFichier : String255;
    dateDansDatabase : String255;
    oldCheckDangerousEvents : boolean;
begin

  OuvrirFichierPartieFormatSmartGameBoard := -1;

  if not(PeutArreterAnalyseRetrograde) then
    exit;

  if (nomCompletFichier = '') then
    begin
      AlerteSimpleFichierTexte(nomCompletFichier,0);
      exit;
    end;

  erreurES := FileExists(nomCompletFichier,0,ficPartie);
  if erreurES <> NoErr then
    begin
      OuvrirFichierPartieFormatSmartGameBoard := erreurES;
      AlerteSimpleFichierTexte(nomCompletFichier, erreurES);
      exit;
    end;

  nomCourt := ExtractFileOrDirectoryName(nomCompletFichier);
  erreurES := ExtractFileName(ficPartie.info, nomLongDuFichier);
  if not(EstUnNomDeFichierTemporaireDePressePapier(nomCompletFichier)) and
     (GetModificationDate(ficPartie,theDate) = NoErr) then
    begin
      dateModifFichier := DateEnString(theDate);
      if FichierExisteDansDatabaseOfRecentSGFFiles(nomCourt,dateDansDatabase) and (dateDansDatabase = dateModifFichier)
        then SetToujoursAjouterInterversionDansGrapheInterversions(false)
        else SetToujoursAjouterInterversionDansGrapheInterversions(true);
      AjouterNomDansDatabaseOfRecentSGFFiles(dateModifFichier,nomCourt);
    end;



  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tick := TickCount;
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);


  theFile := MakeFichierAbstraitFichier(nomCompletFichier,0);

  if FichierAbstraitEstCorrect(theFile) then
    begin
      if positionFeerique
         then DoNouvellePartie(true)
         else DoDebut(not(CassioEstEnModeAnalyse));

      if mergeWithCurrentTree
        then SetCurrentNodeToGameRoot
        else ReInitialiseGameRootGlobalDeLaPartie;
      MarquerCurrentNodeCommeReel('OuvrirFichierPartieFormatSmartGameBoard');

      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      titrePartie^^ := nomLongDuFichier;
      AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);

      LitFormatSmartGameBoard(GetCurrentNode,theFile);
      DisposeFichierAbstrait(theFile);

      SetToujoursAjouterInterversionDansGrapheInterversions(true);
      {WritelnNumDansRapport('temps de lecture = ',TickCount-tick);}

      UpdateGameByMainBranchFromCurrentNode(nbreCoup,JeuCourant,emplJouable,frontiereCourante,
                                            nbreDePions[pionBlanc],nbreDePions[pionNoir],AQuiDeJouer,nbreCoup,
                                            'OuvrirFichierPartieFormatSmartGameBoard');

      EffaceProprietesOfCurrentNode;
      AfficheProprietesOfCurrentNode(false,othellierToutEntier,'OuvrirFichierPartieFormatSmartGameBoard');


      if not(CassioEstEnModeAnalyse) and not(HumCtreHum)
        then DoChangeHumCtreHum;

      if not(afficheProchainsCoups) then DoChangeAfficheProchainsCoups;

      ToggleAideDebutant;
      ToggleAideDebutant;

      if positionFeerique or (NbDeFilsOfCurrentNode <= 0)
        then SetNomFichierDansTitreDiagrammeFFORUM(nomLongDuFichier);
    end;

  RemettreLeCurseurNormalDeCassio;
  FinRapport;
  TextNormalDansRapport;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

  OuvrirFichierPartieFormatSmartGameBoard := NoErr;
end;




function OuvrirFichierParNomComplet(nomCompletFichier : String255; formats_a_ouvrir : SetOfKnownFormats; mergeWithCurrentTree : boolean) : OSErr;
var fic : basicfile;
    infos : FormatFichierRec;
    err : OSErr;
    tempEntreesSorties : boolean;
    tempExplicationsTri : boolean;
{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
    nomFichierProfileOuvrirFichier : String255;
{$ENDC}
label clean_up;

  procedure NotRecognised;
  begin
    AlerteFormatNonReconnuFichierPartie(GetName(fic.info));
    err := -1;
  end;

begin
  tempEntreesSorties := gEnEntreeSortieLongueSurLeDisque;
  gEnEntreeSortieLongueSurLeDisque := true;

  tempExplicationsTri := DoitExpliquerTrierListeSuivantUnClassement;
  SetDoitExpliquerTrierListeSuivantUnClassement(false);

  AjusteSleep;

{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
    then ProfilerSetStatus(1);
{$ENDC}

  if not(PeutArreterAnalyseRetrograde) then
    begin
      OuvrirFichierParNomComplet := -1;
      goto clean_up;
    end;


  err := FileExists(nomCompletFichier,0,fic);

  if (err = NoErr) then
    if TypeDeFichierEstConnu(fic, infos, err)
      then
				begin
				  err := 1000;

				  {WritelnNumDansRapport('infos.format = ',SInt32(infos.format));
				  WritelnNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);}

				  if (kTypeFichierScriptFinale in formats_a_ouvrir) and
				     (infos.format = kTypeFichierScriptFinale)
				      then
					      begin
					        if Pos('problemes_stepanov',nomCompletFichier) > 0
      					    then
      					      begin
      					        dernierProblemeStepnanovAffiche := 0;
      					        err := ProcessProblemesStepanov(nomCompletFichier,dernierProblemeStepnanovAffiche + 1);
      					      end
      					    else
      					      begin
      					        err := NoErr;
      					        LancerInterruptionPourOuvrirScriptDeFinale(nomCompletFichier);
      					      end;
      					end;


					if (kTypeFichierTortureImportDesNoms in formats_a_ouvrir) and
				     (infos.format = kTypeFichierTortureImportDesNoms) and
					   (NoCasePos('import-des-noms.torture.txt',nomCompletFichier) > 0) then
					  err := OuvrirFichierTortureImportDesNoms(nomCompletFichier);


          if (kTypeFichierCronjob in formats_a_ouvrir) and
				     (infos.format = kTypeFichierCronjob) then
            begin
              InstallerFichierCronjob(nomCompletFichier);
              err := NoErr;
            end;
					

					if (kTypeFichierTournoiEntreEngines in formats_a_ouvrir) and
				     (infos.format = kTypeFichierTournoiEntreEngines) then
					  err := OuvrirFichierTournoiEntreEngines(nomCompletFichier);

					if (kTypeFichierPGN in formats_a_ouvrir) and
				     (infos.format = kTypeFichierPGN) then
					  err := AjouterPartiesFichierPGNDansListe('name_mapping_VOG_to_WThor.txt',fic);

					if ((kTypeFichierGGFMultiple                        in formats_a_ouvrir) or
					    (kTypeFichierSuiteDePartiePuisJoueurs           in formats_a_ouvrir) or
					    (kTypeFichierSuiteDeJoueursPuisPartie           in formats_a_ouvrir) or
					    (kTypeFichierMultiplesLignesAvecJoueursEtPartie in formats_a_ouvrir) or
					    (kTypeFichierSimplementDesCoupsMultiple         in formats_a_ouvrir)) and
				     ((infos.format = kTypeFichierGGFMultiple)                        or
					    (infos.format = kTypeFichierSuiteDePartiePuisJoueurs)           or
					    (infos.format = kTypeFichierSuiteDeJoueursPuisPartie)           or
					    (infos.format = kTypeFichierMultiplesLignesAvecJoueursEtPartie) or
					    (infos.format = kTypeFichierSimplementDesCoupsMultiple))  then
  					err := AjouterPartiesFichierDestructureDansListe(infos.format,fic);

					if (kTypeFichierTHOR_PAR in formats_a_ouvrir) and
				     (infos.format = kTypeFichierTHOR_PAR) and (infos.tailleOthellier = 8) then
					  err := AjouterPartiesFichierTHOR_PARDansListe(fic);

			    if (kTypeFichierCassio in formats_a_ouvrir) and
				     (infos.format = kTypeFichierCassio) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);
					
					if (kTypeFichierXBoardAlien in formats_a_ouvrir) and
				     (infos.format = kTypeFichierXBoardAlien) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierHTMLOthelloBrowser in formats_a_ouvrir) and
				     (infos.format = kTypeFichierHTMLOthelloBrowser) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierTranscript in formats_a_ouvrir) and
				     (infos.format = kTypeFichierTranscript) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierZebra in formats_a_ouvrir) and
				     (infos.format = kTypeFichierZebra) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierExportTexteDeZebra in formats_a_ouvrir) and
				     (infos.format = kTypeFichierExportTexteDeZebra) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierSimplementDesCoups in formats_a_ouvrir) and
				     (infos.format = kTypeFichierSimplementDesCoups) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierLigneAvecJoueurEtPartie in formats_a_ouvrir) and
				     (infos.format = kTypeFichierLigneAvecJoueurEtPartie) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatCassio(nomCompletFichier,mergeWithCurrentTree);

					if (kTypeFichierGGF in formats_a_ouvrir) and
				     (infos.format = kTypeFichierGGF) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatGGF(nomCompletFichier,mergeWithCurrentTree);

			    if (kTypeFichierSGF in formats_a_ouvrir) and
				     (infos.format = kTypeFichierSGF) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierPartieFormatSmartGameBoard(nomCompletFichier,mergeWithCurrentTree);
					
					if (kTypeFichierEPS in formats_a_ouvrir) and
				     (infos.format = kTypeFichierEPS) and (infos.tailleOthellier = 8) then
					  err := OuvrirFichierFormatEPS(nomCompletFichier,mergeWithCurrentTree);
					
					if (kTypeFichierScriptZoo in formats_a_ouvrir) and
				     (infos.format = kTypeFichierScriptZoo) then
					  err := OuvrirFichierScriptZoo(nomCompletFichier);

					if (kTypeFichierBibliotheque in formats_a_ouvrir) and
				     (infos.format = kTypeFichierBibliotheque) then
					  err := LitBibliotheque(nomCompletFichier,BAND(theEvent.modifiers,optionKey) <> 0);

					if (kTypeFichierPreferences in formats_a_ouvrir) and
				     (infos.format = kTypeFichierPreferences) then
					  err := NoErr;

			    if (err = 1000) and (infos.format = kTypeFichierInconnu)
			      then NotRecognised;
	       end
	     else
	       NotRecognised;

  {WritelnNumDansRapport('dans OuvrirFichierParNomComplet, err = ',err);}
  OuvrirFichierParNomComplet := err;

{$IFC USE_PROFILER_OUVERTURE_FICHIERS}
  nomFichierProfileOuvrirFichier := 'ouvrir_fichier_' + IntToStr(Tickcount div 60) + '.profile';
  WritelnDansRapport('nomFichierProfileOuvrirFichier = '+nomFichierProfileOuvrirFichier);
  if ProfilerDump(nomFichierProfileOuvrirFichier) <> NoErr
    then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfileOuvrirFichier+') a échoué !')
    else ProfilerSetStatus(0);
  ProfilerTerm;
{$ENDC}

 RemettreLeCurseurNormalDeCassio;

 clean_up :

  gEnEntreeSortieLongueSurLeDisque := tempEntreesSorties;
  SetDoitExpliquerTrierListeSuivantUnClassement(tempExplicationsTri);

end;


function OuvrirFichierPartieFSp(fichier : fileInfo; whichFormats : SetOfKnownFormats; mergeWithCurrentTree : boolean) : OSErr;
var nomComplet : String255;
begin
  OuvrirFichierPartieFSp := -1;
  ExpandFileName(fichier);
  if ExpandFileName(fichier,nomComplet) = NoErr then
    begin
      AjoutePartieDansMenuReouvrir(nomComplet);
      if gPendantLesInitialisationsDeCassio then
        gPartieOuvertePendantLesInitialisationsDeCassio := nomComplet;
	    OuvrirFichierPartieFSp := OuvrirFichierParNomComplet(nomComplet, whichFormats, mergeWithCurrentTree);
    end;
end;


function OuvrirPartieDansFichierPressePapier(whichFormats : SetOfKnownFormats) : OSErr;
var fic : basicfile;
    myError : OSErr;
    erreurOuvertureEnFormatTEXT : OSErr;
    erreurOuvertureEnFormatEPS : OSErr;
begin
  erreurOuvertureEnFormatTEXT := -1;
  erreurOuvertureEnFormatEPS  := -1;

  (* WritelnDansRapport('Entree dans OuvrirPartieDansFichierPressePapier'); *)

  myError := DumpPressePapierToFile(fic, FOUR_CHAR_CODE('TEXT'));
  if (myError = NoErr) then
    begin
      erreurOuvertureEnFormatTEXT := OuvrirFichierPartieFSp(fic.info, whichFormats, true);
      myError := DeleteFile(fic);
    end;

  if erreurOuvertureEnFormatTEXT = NoErr then
    begin
      OuvrirPartieDansFichierPressePapier := NoErr;
      exit;
    end;

  myError := DumpPressePapierToFile(fic, FOUR_CHAR_CODE('EPS '));
  if (myError = NoErr) then
    begin
      erreurOuvertureEnFormatEPS := OuvrirFichierPartieFSp(fic.info, whichFormats, true);
      myError := DeleteFile(fic);
      myError := erreurOuvertureEnFormatEPS;
    end;


  OuvrirPartieDansFichierPressePapier := myError;
end;


procedure DoOuvrir;
  var reply : SFReply;
      ok : boolean;
      nomComplet : String255;
      err : OSErr;
      info : fileInfo;
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  BeginDialog;
  ok := GetFileName('',reply,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),info);
  EndDialog;
  if ok then
    begin
      nomComplet := ExpandFileName(info);
      AjoutePartieDansMenuReouvrir(nomComplet);
      err := OuvrirFichierParNomComplet(nomComplet, AllKnownFormats, true);
    end;
end;

procedure DoEnregistrerSousFormatCassio(modifiers : SInt16);
  var reply : SFReply;
      posEtPartie,s : String255;
      info : fileInfo;
      ficPartie : basicfile;
      texteRapportHdl : CharArrayHandle;
      i,count,fin : SInt32;
      c : char;
      erreurES : OSErr;
      bidon : boolean;
begin
  SetNameOfSFReply(reply,titrePartie^^);
  BeginDialog;
  bidon := MakeFileName(reply,ReadStringFromRessource(TextesDiversID,1),info);  {'Donnez un nom à la partie'}
  EndDialog;
  if reply.good then
   begin

     if (BAND(modifiers,optionKey) <> 0)
       then posEtPartie := PositionInitialeEnLignePourPressePapier+PartiePourPressePapier(false,true,nbreCoup)
       else posEtPartie := PositionInitialeEnLignePourPressePapier+PartiePourPressePapier(false,true,60);

     erreurES := FileExists(info,ficPartie);
     if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
       then erreurES := CreateFile(info,ficPartie);
     if erreurES = NoErr then
       begin
         erreurES := OpenFile(ficPartie);
         erreurES := EmptyFile(ficPartie);
       end;
     if ErreurES <> NoErr then
       begin
         AlerteSimpleFichierTexte(GetNameOfSFReply(reply),ErreurES);
         erreurES := CloseFile(ficPartie);
         exit;
       end;

     erreurES := Writeln(ficPartie,posEtpartie);

     {on ecrit le nom du fichier comme commentaire a l'intérieur}
     {les lignes de commentaire commancent par %}
     s := Concat('%filename = ',GetNameOfSFReply(reply));
     erreurES := Writeln(ficPartie,s);

     {on ecrit la selection du rapport dans le fichier}
     {chaque ligne coommence par '¬R¬' et finit par '¶'}
     if SelectionRapportNonVide then
       begin
         texteRapportHdl := GetRapportTextHandle;
         i := GetDebutSelectionRapport;
         fin := GetFinSelectionRapport;
         s := ''; count := 0;
         repeat
           c := texteRapportHdl^^[i];
           if c = chr(13) then c := '¶';
           s := s + c;
           i := i+1;
           count := count+1;
           if (c = '¶') or (count >= 230) then
             begin
               erreurES := Writeln(ficPartie,'¬R¬'+s);
               s := ''; count := 0;
             end;
         until (i >= fin) or (erreurES <> NoErr);
         if (s <> '') then
           erreurES := Writeln(ficPartie,'¬R¬'+s);
       end;

     erreurES := CloseFile(ficPartie);
     SetFileTypeFichierTexte(ficPartie,FOUR_CHAR_CODE('TSNX'));
     SetFileCreatorFichierTexte(ficPartie,FOUR_CHAR_CODE('SNX4'));

     if SelectionRapportNonVide then
       SauverStyleDuRapport(ficPartie);

     titrePartie^^ := GetNameOfSFReply(reply);
     AjoutePartieDansMenuReouvrir(ExpandFileName(info));
   end;
end;


procedure DoEnregistrerSousFormatSmartGameBoard;
var theFile : FichierAbstrait;
    nomComplet,s : String255;
    info : fileInfo;
    reply : SFReply;
    err : OSErr;
    texteRapportHdl : CharArrayHandle;
    debut,count : SInt32;
    state : SInt8;
    prop : Property;
    fichier : basicfile;
    theDate : DateTimeRec;
    bidon : boolean;
begin
  s := titrePartie^^;
  if not(EndsWith(s,'.sof') or EndsWith(s,'.SOF') or EndsWith(s,'.sgf') or EndsWith(s,'.SGF')) then
    begin
      if EndsWith(s,'.')
        then s := s + 'sof'
        else s := s + '.sof';
    end;

  SetNameOfSFReply(reply, s);

  BeginDialog;
  bidon := MakeFileName(reply,ReadStringFromRessource(TextesDiversID,4),info);  {'Donnez un nom à l'arbre de jeu'}
  EndDialog;

  if reply.good then
    begin
      titrePartie^^ := GetNameOfSFReply(reply);
      nomComplet := ExpandFileName(info);

      theFile := MakeFichierAbstraitFichier(nomComplet,0);

      if FichierAbstraitEstCorrect(theFile) then
        begin

          AjoutePartieDansMenuReouvrir(nomComplet);
          err := ViderFichierAbstrait(theFile);

          watch := GetCursor(watchcursor);
          SafeSetCursor(watch);

          {fabrication d'une property d'ecriture dans le rapport, à interpreter quand on rouvrira le fichier}
          if SelectionRapportNonVide then
             begin
               texteRapportHdl := GetRapportTextHandle;
               debut := GetDebutSelectionRapport;
               count := LongueurSelectionRapport;

               state := HGetState(Handle(texteRapportHdl));
               HLock(Handle(texteRapportHdl));
               prop := MakeTexteProperty(GameCommentProp,Ptr(SInt32(texteRapportHdl^)+debut),count);
               HSetState(Handle(texteRapportHdl),state);
               DeletePropertiesOfTheseTypesInList([GameCommentProp],GetRacineDeLaPartie^.properties);
               AddPropertyToRoot(prop);
               DisposePropertyStuff(prop);
             end;
          EcritFormatSmartGameBoard(GetRacineDeLaPartie,theFile);
          if SelectionRapportNonVide then
            begin
              DeletePropertiesOfTheseTypesInList([GameCommentProp],GetRacineDeLaPartie^.properties);
              if GetBasicFileOfFichierAbstraitPtr(@theFile,fichier) = NoErr then
                SauverStyleDuRapport(fichier);
            end;
          SetAbstractFileType(theFile,FOUR_CHAR_CODE('KSOF'));
          SetAbstractFileCreator(theFile,FOUR_CHAR_CODE('SNX4'));

          if (GetBasicFileOfFichierAbstraitPtr(@theFile,fichier) = NoErr) then
            begin
              err := GetModificationDate(fichier,theDate);
              AjouterNomDansDatabaseOfRecentSGFFiles(DateEnString(theDate),GetNameOfSFReply(reply));
            end;
          DisposeFichierAbstrait(theFile);
        end;

      RemettreLeCurseurNormalDeCassio;
    end;
end;



procedure DoEnregistrerSous(useSmartGameBoardFormat : boolean);
begin
  if useSmartGameBoardFormat
    then DoEnregistrerSousFormatSmartGameBoard
    else DoEnregistrerSousFormatCassio(theEvent.modifiers);
end;

procedure DoOuvrirBibliotheque;
var reply : SFReply;
    info : fileInfo;
begin
  if GetFileName('',reply,FOUR_CHAR_CODE('TEXT'),FOUR_CHAR_CODE('BIBL'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),info) then
    begin
      if LitBibliotheque(GetNameOfSFReply(reply),BAND(theEvent.modifiers,optionKey) <> 0) = NoErr then DoNothing;
      EnableItemTousMenus;
    end;
end;

procedure DoEcritureSolutionSolitaire;
var bidbool : boolean;
    seulCoup,seuleDef,couleur,prof,score : SInt32;
    nbBlanc,nbNoir : SInt32;
    tempoSensLarge : boolean;
    nbremeill,causerejet : SInt32;
    oldInterruption : SInt16;
begin
  tempoSensLarge := senslargeSolitaire;
  couleur := AQuiDeJouer;
  nbBlanc := nbreDePions[pionBlanc];
  nbNoir := nbreDePions[pionNoir];
  prof := 64 - nbBlanc - nbNoir;
  if prof <= 20 then
    begin
     senslargeSolitaire := true;
     oldInterruption := GetCurrentInterruption;
     EnleveCetteInterruption(oldInterruption);
     bidbool := EstUnSolitaire(seulCoup,seuleDef,couleur,prof,nbblanc,nbnoir,JeuCourant,
                    emplJouable,frontiereCourante,score,nbremeill,true,causerejet,kSortiePapier,65);
     LanceInterruption(oldInterruption,'DoEcritureSolutionSolitaire');
    end;
  senslargeSolitaire := tempoSensLarge;
end;




procedure PrepareNouvellePartie(ForceHumCtreHum : boolean);
var i : SInt16;
    oldPort : grafPtr;
    s : String255;
    mobilite : SInt32;
    commentaireChange : boolean;
begin

   BeginFonctionModifiantNbreCoup('PrepareNouvellePartie');

   ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
   positionFeerique := false;
   peutfeliciter := true;
   PartieContreMacDeBoutEnBout := true;
   gGongDejaSonneDansCettePartie := false;
  (* if avecDessinCoupEnTete then EffaceCoupEnTete;
   SetCoupEntete(0);*)
   gameOver := false;
   MetTitreFenetrePlateau;
   enSetUp := false;
   enRetour := false;
   SetPositionInitialeStandardDansJeuCourant;
   nbreCoup := 0;
   CommentaireSolitaire^^ := '';
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;
   LanceInterruptionConditionnelle(interruptionSimple,'SET_NBRECOUP',0,'PrepareNouvellePartie');
   vaDepasserTemps := false;
   reponsePrete := false;
   gDoitJouerMeilleureReponse := false;
   SetSuggestionDeFinaleEstDessinee(false);
   VideMeilleureSuiteInfos;
   ViderValeursDeLaCourbe;
   MemoryFillChar(@emplJouable,sizeof(emplJouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@marques,sizeof(marques),chr(0));
   with gEntrainementOuvertures do
     begin
       for i := 0 to 64 do
         deltaNotePerduCeCoup[i] := 0;
       deltaNotePerduAuTotal := 0;
       ViderListOfMoveRecords(classementVariations);
       derniereProfCompleteMilieuDePartie := 0;
     end;
   ParamDiagCourant.titreFFORUM^^ := '';
   ParamDiagCourant.commentPositionFFORUM^^ := '';
   ParamDiagPositionFFORUM.titreFFORUM^^ := '';
   ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
   ParamDiagPartieFFORUM.titreFFORUM^^ := '';
   ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
   s := ReadStringFromRessource(TextesDiversID,2);     {'sans titre'}
   titrePartie^^ := s;
   CommentaireSolitaire^^ := '';
   SetMeilleureSuite('');
   chainePourIOS := '';
   finaleEnModeSolitaire := false;



   EffaceProprietesOfCurrentNode;
   ReInitialisePartieHdlPourNouvellePartie(true);
   SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetRacineDeLaPartie,true,commentaireChange);


   VideMeilleureSuiteInfos;
   nbreCoup := 0;
   nroDernierCoupAtteint := 0;
   IndexProchainFilsDansGraphe := -1;
   nbreToursFeuillesMilieu := 0;
   nbreFeuillesMilieu := 0;
   SommeNbEvaluationsRecursives := 0;
   nbreToursNoeudsGeneresMilieu := 0;
   nbreNoeudsGeneresMilieu := 0;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   if not(HumCtreHum) and ForceHumCtreHum then DoChangeHumCtreHum;
   EssaieDisableForceCmd;

   EffacerTouteLaCourbe('PrepareNouvellePartie');
   DessineSliderFenetreCourbe;
   if not(windowPlateauOpen) then OuvreFntrPlateau(false);
   GetPort(oldPort);
   SetPortByWindow(wPlateauPtr);
   if IsWindowVisible(wPlateauPtr) then DessinePlateau(true);
   SetPositionsTextesWindowPlateau;
   InitialiseDirectionsJouables;
   PosePion(54,pionNoir);
   PosePion(45,pionNoir);
   PosePion(55,pionBlanc);
   PosePion(44,pionBlanc);
   aideDebutant := false;
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);

   SetPositionInitialeStandardDansGameTree;
   AddInfosStandardsFormatSGFDansArbre;
   AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitInitiauxStandard, GetRacineDeLaPartie);
   AfficheProprietesOfCurrentNode(false,othellierToutEntier,'PrepareNouvellePartie');

   FlushEvents(updateEvt,0);


   CarteJouable(JeuCourant,emplJouable);
   Calcule_Valeurs_Tactiques(JeuCourant,true);
   CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
   CarteFrontiere(JeuCourant,frontiereCourante);
   nbreDePions[pionNoir] := 2;
   nbreDePions[pionBlanc] := 2;

   AfficheScore;

   Initialise_table_heuristique(JeuCourant,false);
   MyDisableItem(PartieMenu,ForceCmd);

   EngineViderFeedHashHistory;

   AfficheDemandeCoup;
   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
   if avecAleatoire then RandomizeTimer;
   {la}
   AjusteCadenceMin(GetCadence);

   DessineBoiteDeTaille(wPlateauPtr);
   dernierTick := TickCount;
   Heure(pionNoir);
   Heure(pionBlanc);

   if not(IsWindowVisible(wPlateauPtr)) then
     begin
       InvalidateAllCasesDessinEnTraceDeRayon;
       ShowHide(wPlateauPtr,true);
       EcranStandard(NIL,false);
     end;

   LanceInterruptionSimpleConditionnelle('PrepareNouvellePartie');

   {AttendFrappeClavier;}

   SetPort(oldPort);
   AjusteCurseur;
   DetruitMeilleureSuite;

   EndFonctionModifiantNbreCoup('PrepareNouvellePartie');

   if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);


end;



procedure DoChangeAlerteInterversion;
begin
  avecAlerteNouvInterversion := not(avecAlerteNouvInterversion);
end;

{
procedure DoChangeEvaluationAleatoire;
begin
  EvaluationAleatoire := not(EvaluationAleatoire);
end;
}

procedure DoChangeEvaluationTablesDeCoins;
  begin
    avecEvaluationTablesDeCoins := not(avecEvaluationTablesDeCoins);
  end;

procedure DoChangeEvaluationDeFisher;
  begin
    avecEvaluationDeFisher := not(avecEvaluationDeFisher);
  end;

procedure DoChangeRefutationsDansRapport;
  begin
    avecRefutationsDansRapport := not(avecRefutationsDansRapport);
  end;
{
procedure DoChangePionClignotant;
  begin
    PionClignotant := not(PionClignotant);
  end;
}

procedure DoNouvellePartie(ForceHumCtreHum : boolean);
var commentaireChange : boolean;
begin
  if not(gPendantLesInitialisationsDeCassio) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;
  PrepareNouvellePartie(ForceHumCtreHum);
  SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetRacineDeLaPartie,true,commentaireChange);
  EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
  if not(HumCtreHum) then
    begin
      reponsePrete := false;
      RefleSurTempsJoueur := false;
      LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoNouvellePartie');
      vaDepasserTemps := false;
    end;
  RemettreLeCurseurNormalDeCassio;
  VideMeilleureSuiteInfos;
  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
end;




procedure DoClose(whichWindow : WindowPtr; avecAnimationZoom : boolean);
begin  {$unused avecAnimationZoom}
  if whichWindow = NIL then exit;
  if whichWindow = wPlateauPtr
    then CloseProgramWindow
    else
      if whichWindow = wCourbePtr
       then CloseCourbeWindow
       else
         if whichWindow = wGestionPtr
         then CloseGestionWindow
         else
         if whichWindow = wNuagePtr
         then CloseNuageWindow
         else
         if whichWindow = GetTooltipWindowInCloud
         then CloseTooltipWindowInCloud
         else
           if whichWindow = wReflexPtr
             then CloseReflexWindow
             else
               if whichWindow = wListePtr
               then
                 begin
                   CloseListeWindow;
                   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
                 end
               else
                 if whichWindow = wStatPtr
                   then
                     begin
                       CloseStatWindow;
                       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
                     end
                   else
                     if whichWindow = wPalettePtr
                       then ClosePaletteWindow
                       else
                         if EstLaFenetreDuRapport(whichWindow)
                           then CloseRapportWindow
                           else
                             if whichWindow = iconisationDeCassio.theWindow
                               then CloseIconisationWindow
                               else
                                 if whichWindow = GetArbreDeJeuWindow
                                   then CloseCommentairesWindow
                                   else
                                     if whichWindow = wAidePtr
                                       then CloseAideWindow
                                       else
    				                             begin

    				                               DisposeWindow(whichWindow);

    				                               CloseDAwindow;
    				                               if (FrontWindow <> NIL) then
    				                                  if WindowDeCassio(FrontWindow) then SetPortByWindow(FrontWindow);
    				                             end;

  if not(Quitter) then
    begin
      if HasGotEvent(activMask,theEvent,0,NIL) then
        TraiteOneEvenement;
      if HasGotEvent(activMask,theEvent,0,NIL) then
        TraiteOneEvenement;
      if HasGotEvent(activMask,theEvent,0,NIL) then
        TraiteOneEvenement;
      EssaieUpdateEventsWindowPlateau;
      EssaieUpdateEventsWindowPlateau;
      if CloseZoomRectFrom.left <> -13333 then
        begin
          {InsetRect(CloseZoomRectTo,1,1);}
          SetRect(CloseZoomRectFrom,-13333,-13333,-13333,-13333);
        end;
    end;

  if (FrontWindow = NIL) or (enSetUp or enRetour)
      then MyDisableItem(GetFileMenu,CloseCmd)
      else EnableItemPourCassio(GetFileMenu,CloseCmd);

  FixeMarqueSurMenuBase;
end;


procedure DoCloseCmd(modifiers : SInt16);
var shift,command,option,control : boolean;
  begin
    shift := BAND(modifiers,shiftKey) <> 0;
    command := BAND(modifiers,cmdKey) <> 0;
    option := BAND(modifiers,optionKey) <> 0;
    control := BAND(modifiers,controlKey) <> 0;

	  if (FrontWindowSaufPalette = NIL)
	     then
	       begin
	         if windowPaletteOpen and (wPalettePtr <> NIL) then DoClose(wPalettePtr,true)
	       end
	     else
	       if windowPaletteOpen and (FrontWindowSaufPalette = wPlateauPtr)
	         then DoClose(wPalettePtr,true)
	         else
	           begin
	             DoClose(FrontWindowSaufPalette,not(option));
	             if option then FermeToutesLesFenetresAuxiliaires;
	           end
  end;


procedure DoAjouteTemps(aQui : SInt16);
var i : SInt16;
    tempsAjouteMin,tempsAjouteSec : SInt16;
    retireDuTemps : boolean;
begin
   tempsAjouteMin := 1;
   tempsAjouteSec := 60;
   retireDuTemps := BAND(theEvent.modifiers,optionKey) <> 0;
   if retireDuTemps then
     begin
       tempsAjouteMin := -tempsAjouteMin;
       tempsAjouteSec := -tempsAjouteSec;
     end;
   tempsDesJoueurs[aQui].minimum := tempsDesJoueurs[aQui].minimum-tempsAjouteMin;
   if aQui = pionNoir
     then
       for i := 0 to nbreCoup+1 do
           partie^^[i].tempsUtilise.tempsNoir := partie^^[i].tempsUtilise.tempsNoir-tempsAjouteSec
     else
       for i := 0 to nbreCoup+1 do
         partie^^[i].tempsUtilise.tempsBlanc := partie^^[i].tempsUtilise.tempsBlanc-tempsAjouteSec;
   Heure(aQui)
end;

procedure DoSon;
  begin
    avecSon := not(avecSon);
    DessineIconesChangeantes;
  end;


procedure DoDemandeChangeCouleur;
  begin
    LanceInterruptionConditionnelle(kHumainVeutChangerCouleur,'SET_COULEURMAC',-couleurMacintosh,'DoDemandeChangeCouleur');
    if not(HumCtreHum) then
      begin
        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;
        LanceInterruptionConditionnelle(kHumainVeutChangerCouleur,'SET_COULEURMAC',-couleurMacintosh,'DoDemandeChangeCouleur');
      end;
  end;


procedure DoDemandeJouerSolitaires;
  begin
    LanceInterruption(kHumainVeutJouerSolitaires,'DoDemandeJouerSolitaires');
    if not(HumCtreHum) then
      begin
        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;
      end;
  end;


procedure DoDemandeChangerHumCtreHum;
var tempoHumCtreHum : boolean;
  begin
    if CassioEstEnModeTournoi then exit;

    if HumCtreHum
      then
        DoChangeHumCtreHum
      else
        begin
          if PeutArreterAnalyseRetrograde then
            begin
              tempoHumCtreHum := HumCtreHum;

              HumCtreHum := true;
              DessineIconesChangeantes;
              if afficheSuggestionDeCassio and HumCtreHum then EffaceSuggestionDeCassio;
              HumCtreHum := tempoHumCtreHum;

              LanceInterruptionConditionnelle(kHumainVeutChangerHumCtreHum,'SET_HUMCTREHUM',1,'DoDemandeChangerHumCtreHum');
              reponsePrete := false;
              RefleSurTempsJoueur := false;
              vaDepasserTemps := false;
              LanceInterruptionConditionnelle(kHumainVeutChangerHumCtreHum,'SET_HUMCTREHUM',1,'DoDemandeChangerHumCtreHum');
            end;
        end;
  end;


procedure DoDemandeChangerHumCtreHumEtCouleur;
begin
  if CassioEstEnModeTournoi then exit;

  if (AQuiDeJouer = -couleurMacintosh) and HumCtreHum
    then
      begin
        couleurMacintosh := -couleurMacintosh;
        HumCtreHum := not(HumCtreHum);

        reponsePrete := false;
        RefleSurTempsJoueur := false;
        vaDepasserTemps := false;

        LanceInterruptionConditionnelle(kHumainVeutChangerCoulEtHumCtreHum,'',0,'DoDemandeChangerHumCtreHumEtCouleur');

        couleurMacintosh := -couleurMacintosh;
        HumCtreHum := not(HumCtreHum);
      end
    else
      begin
        if (AQuiDeJouer = -couleurMacintosh) then DoDemandeChangeCouleur else
        if HumCtreHum then DoDemandeChangerHumCtreHum;
      end;
end;


procedure DoDemandeCassioPrendLesBlancs;
begin
  if (GetCadence = minutes10000000) and (not(CassioEstEnTrainDePlaquerUnSolitaire))
    then
      begin
        if PeutArreterAnalyseRetrograde then
          begin
            SetCadence(GetCadenceAutreQueAnalyse);
            jeuInstantane := GetJeuInstantaneAutreQueAnalyse;
            if (couleurMacintosh <> pionBlanc) then DoDemandeChangeCouleur;
            AjusteEtatGeneralDeCassioApresChangementDeCadence;
          end;
      end
    else
      begin
        if (couleurMacintosh <> pionBlanc) then
          if PeutArreterAnalyseRetrograde then DoDemandeChangeCouleur;
      end;
end;


procedure DoDemandeCassioPrendLesNoirs;
begin
  if (GetCadence = minutes10000000) and (not(CassioEstEnTrainDePlaquerUnSolitaire))
    then
      begin
        if PeutArreterAnalyseRetrograde then
          begin
            SetCadence(GetCadenceAutreQueAnalyse);
            jeuInstantane := GetJeuInstantaneAutreQueAnalyse;
            if (couleurMacintosh <> pionNoir) then DoDemandeChangeCouleur;
            AjusteEtatGeneralDeCassioApresChangementDeCadence;
          end;
      end
    else
      begin
        if (couleurMacintosh <> pionNoir) then
          if PeutArreterAnalyseRetrograde then DoDemandeChangeCouleur;
      end;
end;


procedure DoDemandeCassioAnalyseLesDeuxCouleurs;
begin
  if not(CassioEstEnModeAnalyse) and
     not(CassioEstEnTrainDePlaquerUnSolitaire) and
     (CommentaireSolitaire^^ = '') then
    begin
      SetCadence(minutes10000000);
      AjusteEtatGeneralDeCassioApresChangementDeCadence;
    end;
end;


procedure DetruitSousArbreCourantEtBackMove;
var whichSon : GameTree;
begin
  whichSon := GetCurrentNode;
  DoBackMove;
  EffaceProprietesOfCurrentNode;
  DeleteSonOfCurrentNode(whichSon);
  if not(LiveUndoVaRejouerImmediatementUnAutreCoup) then
    begin
      DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DetruitSousArbreCourantEtBackMove');
      AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DetruitDernierCoupEtBackMove');
    end;
  GarbageCollectionDansTableHashageInterversions;
end;


procedure DoDialogueDetruitSousArbreCourant;
const DestructionDialogueID = 155;
      OK = 1;
      Annuler = 2;
var dp : DialogPtr;
    itemHit : SInt16;
    destructionRadios : RadioRec;
    whichSon : GameTree;
    err : OSErr;
begin
  destructionRadios := NewRadios(kDetruireCeNoeudEtFils,kDetruireLesFils,TypeDerniereDestructionDemandee);
  itemHit := Annuler;
  BeginDialog;
  dp := MyGetNewDialog(DestructionDialogueID);
  if dp <> NIL then
    begin
      MyDrawDialog(dp);
      InitRadios(dp,destructionRadios);
      err := SetDialogTracksCursor(dp,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
        if InRange(ItemHit,destructionRadios.firstButton,destructionRadios.lastButton) then
          PushRadio(dp,destructionRadios,ItemHit);
      until (itemHit = OK) or (itemHit = Annuler);
      MyDisposeDialog(dp);
    end;
  EndDialog;

  TypeDerniereDestructionDemandee := destructionRadios.selection;
  if (itemHit = OK) then
    begin
      EffaceProprietesOfCurrentNode;
      case TypeDerniereDestructionDemandee of
        kDetruireCeNoeudEtFils:
          if PeutReculerUnCoup and PeutArreterAnalyseRetrograde
            then
              begin
                whichSon := GetCurrentNode;
                DoBackMove;
                EffaceProprietesOfCurrentNode;
                DeleteSonOfCurrentNode(whichSon);
              end
            else
              DeleteAllSonsOfCurrentNode;
        kDetruireLesFils:
          DeleteAllSonsOfCurrentNode;
      end; {case}

      DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoDialogueDetruitSousArbreCourant');
      AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoDialogueDetruitSousArbreCourant');

      FlushWindow(wPlateauPtr);

      GarbageCollectionDansTableHashageInterversions;
    end;
  SetNiveauTeteDeMort(0);
end;



procedure DoTraiteBaseDeDonnee(actionDemandee : SInt16);
var bidbool,doitRejouerLaPartie,test : boolean;
    s : String255;
    platAux : plateauOthello;
    trait : SInt16;
    coup,i,k,nbPartiesDansListe,indexDepart : SInt32;
    gameNodeLePlusProfond : GameTree;
begin

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('entree dans DoTraiteBaseDeDonnee',true);

 if avecGestionBase then
  begin
    if problemeMemoireBase
      then
        DialogueMemoireBase
      else
        begin

          if (InfosFichiersNouveauFormat.nbFichiers <= 0) then
            begin
              if not(gPendantLesInitialisationsDeCassio) then
                begin
                  watch := GetCursor(watchcursor);
                  SafeSetCursor(watch);
                end;
              LecturePreparatoireDossierDatabase(pathCassioFolder,'DoTraiteBaseDeDonnees');
              DoLectureJoueursEtTournoi(false);
              RemettreLeCurseurNormalDeCassio;
            end;

          DerniereChaineComplementation^^ := '@andµôπ¶«Ç‘';
          if ActionBaseDeDonnee(actionDemandee,s) then
            begin

              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('apres ActionBaseDeDonnee dans DoTraiteBaseDeDonnee',true);


              InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
              nbreCoupsApresLecture := LENGTH_OF_STRING(s) div 2;
              {EnableItemPourCassio(BaseMenu,CriteresCmd);}
              if JoueursEtTournoisEnMemoire and (windowListeOpen or windowStatOpen or windowNuageOpen)
                then EnableItemPourCassio(BaseMenu,SousSelectionActiveCmd);

              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('apres EnableItemPourCassio dans DoTraiteBaseDeDonnee',true);

              if not(positionLectureModifiee)
                then
                   begin
                     if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
                        then
                          begin
                            EcritRubanListe(false);
                            LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
                          end;
                     if not(HumCtreHum) and (nbreCoup <= 0) and not(CassioEstEnModeAnalyse) then DoChangeHumCtreHum;
                   end
                 else
                   begin
                     if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DetruitMeilleureSuite dans DoTraiteBaseDeDonnee',true);

                     DetruitMeilleureSuite;
                     EffaceMeilleureSuite;
                     CommentaireSolitaire^^ := '';
                     finaleEnModeSolitaire := false;
                     doitRejouerLaPartie := true;
                     if not(positionFeerique) and (nbreCoupsApresLecture <= nbreCoup) then
                       begin
                         test := true;
                         for i := 1 to nbreCoupsApresLecture do
                           begin
                             coup := PositionDansStringAlphaEnCoup(s,2*i-1);
                             test := test and (coup = GetNiemeCoupPartieCourante(i));
                           end;
                         doitRejouerLaPartie := not(test);
                       end;
                    if positionFeerique
                      then
                        begin
                          NoUpdateWindowPlateau;
                          trait := pionNoir;
                          RejouePartieOthello(s,nbreCoupsApresLecture,true,platAux,trait,gameNodeLePlusProfond,true,true);
                        end
                      else
                        begin
                         if doitRejouerLaPartie and (nbreCoupsApresLecture > 0)
                           then
                             begin
                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant NoUpdateWindowPlateau dans DoTraiteBaseDeDonnee',true);

                               NoUpdateWindowPlateau;
                               if odd(nbreCoupsApresLecture)
                                 then trait := pionBlanc
                                 else trait := pionNoir;

                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant RejouePartieOthello dans DoTraiteBaseDeDonnee',true);


                               RejouePartieOthello(s,nbreCoupsApresLecture,true,platAux,trait,gameNodeLePlusProfond,false,true);
                             end
                           else
                             begin
                               if nbreCoupsApresLecture < nbreCoup then NoUpdateWindowPlateau;

                               if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DoRetourAuCoupNro dans DoTraiteBaseDeDonnee',true);

                               DoRetourAuCoupNro(nbreCoupsApresLecture,false,not(CassioEstEnModeAnalyse));
                             end;
                        end;

                     if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DoChangeHumCtreHum dans DoTraiteBaseDeDonnee',true);

                     if not(HumCtreHum) and not(CassioEstEnModeAnalyse) then DoChangeHumCtreHum;
                   end;

              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant "on sait sans avoir à les compter…" dans DoTraiteBaseDeDonnee',true);

              {on sait sans avoir besoin de les calculer les parties compatibles des coups précédents}
              if avecCalculPartiesActives and (windowListeOpen or windowStatOpen) then
                begin
                  nbPartiesDansListe := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
                  if (nbPartiesDansListe <> PasDePartieActive) and
                     (nbPartiesDansListe <> NeSaitPasNbrePartiesActives) then
                    for i := 0 to nbreCoup-1 do
                      begin
                        SetNombreDePartiesActivesDansLeCachePourCeCoup(i,nbPartiesDansListe);
                        if ListePartiesEstGardeeDansLeCache(i,nbPartiesDansListe) then
                          begin
                            indexDepart := IndexInfoDejaCalculeesCoupNro^^[i-1];
                            for k := 1 to nbPartiesDansListe do
                              TableInfoDejaCalculee^^[indexDepart+k] := tableNumeroReference^^[k];
                          end;
                      end;
                 end;

              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant derniereChaineComplementation dans DoTraiteBaseDeDonnee',true);

              DerniereChaineComplementation^^ := '@andµôπ¶«Ç‘';
            end;


          if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire)
            then
              begin
                if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant if not(enSetUp) dans DoTraiteBaseDeDonnee',true);

                if not(enSetUp) then
                   begin
                     if HasGotEvent(updateMask,theEvent,0,NIL) then
                        TraiteOneEvenement;
                   end;

                if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant bidbool := ActionBaseDeDonnee(BaseLectureJoueursEtTournois,s); dans DoTraiteBaseDeDonnee',true);

                bidbool := ActionBaseDeDonnee(BaseLectureJoueursEtTournois,s);
                if windowListeOpen and (nbPartiesChargees > 0) and JoueursEtTournoisEnMemoire then
                  begin
                    EcritRubanListe(true);
                    WritelnDansRapport('qu''est-ce que ca change ?');
                    EcritListeParties(false,'DoTraiteBaseDeDonnees');
                  end;
              end;

          if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('avant DessineBoiteDeTaille dans DoTraiteBaseDeDonnee',true);

          if windowListeOpen then DessineBoiteDeTaille(wListePtr);

        end;
   end;

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de DoTraiteBaseDeDonnee',true);

end;


procedure DoChargerLaBase;
begin
  DoTraiteBaseDeDonnee(BaseLectureCriteres);
end;


function AutorisationDeChargerLaBaseSansInterventionUtilisateur : boolean;
begin
  if GetAutorisationChargerLaBaseSansPasserParLeDialogue and
     (nbPartiesChargees <= 0) and not(enRetour or enSetUp or CassioEstEnModeSolitaire) and (nbInformationMemoire <= 0) and
     ((ParametresOuvrirThor^^[1] = '') and (ParametresOuvrirThor^^[2] = '') and (ParametresOuvrirThor^^[3] = '')) and
		 ((windowListeOpen and (wListePtr = FrontWindowSaufPalette)) or (windowStatOpen and (wStatPtr = FrontWindowSaufPalette)))
		 then AutorisationDeChargerLaBaseSansInterventionUtilisateur := true
		 else AutorisationDeChargerLaBaseSansInterventionUtilisateur := false;
end;


procedure DoChargerLaBaseSansInterventionUtilisateur;
var s1,s2,s3,s4,s5 : String255;
    genreTest : SInt16;
    tickDepart : SInt32;
    doitAfficherMessages, temp : boolean;
begin

  // lancer le chrono
  tickDepart := TickCount;

  // sauvegarder les criteres du dialogue de la base
  s1 := ParametresOuvrirThor^^[1];
  s2 := ParametresOuvrirThor^^[2];
  s3 := ParametresOuvrirThor^^[3];
  s4 := ParametresOuvrirThor^^[4];
  s5 := ParametresOuvrirThor^^[5];
  genreTest := ParametreGenreTestThor;


  // effacer ces criteres
  ParametresOuvrirThor^^[1] := '';
  ParametresOuvrirThor^^[2] := '';
  ParametresOuvrirThor^^[3] := '';
  ParametresOuvrirThor^^[4] := '';
  ParametresOuvrirThor^^[5] := '';
  ParametreGenreTestThor := testEgalite;


  doitAfficherMessages := (gDernierTempsDeChargementDeLaBase >= 120);  // 2.0 secondes
  SetDoitDessinerMessagesChargementBase(doitAfficherMessages,@temp);

  // lire la base
  DoTraiteBaseDeDonnee(BaseLectureSansInterventionUtilisateur);

  SetDoitDessinerMessagesChargementBase(temp, NIL);


  // remettre les anciens criteres du dialogue de la base
  ParametresOuvrirThor^^[1] := s1;
  ParametresOuvrirThor^^[2] := s2;
  ParametresOuvrirThor^^[3] := s3;
  ParametresOuvrirThor^^[4] := s4;
  ParametresOuvrirThor^^[5] := s5;
  ParametreGenreTestThor := genreTest;

  // arreter le chrono
  gDernierTempsDeChargementDeLaBase := TickCount - tickDepart;

  //WritelnNumDansRapport('gDernierTempsDeChargementDeLaBase = ',gDernierTempsDeChargementDeLaBase);

end;


procedure DoDemandeAnalyseRetrograde(sansDialogueRetrograde : boolean);
begin
  if not(analyseRetrograde.enCours) and (nroDernierCoupAtteint >= 20) then
    if sansDialogueRetrograde or DoDialogueRetrograde(false) then
      begin
        LanceInterruption(kHumainVeutAnalyserFinale,'DoDemandeAnalyseRetrograde');
        if not(HumCtreHum) then
          begin
            reponsePrete := false;
            RefleSurTempsJoueur := false;
            vaDepasserTemps := false;
          end;
      end;
end;

procedure DoParametrerAnalyseRetrograde;
var bidon : boolean;
begin
  if not(analyseRetrograde.enCours) then
    begin
      if (nroDernierCoupAtteint >= 20)
        then DoDemandeAnalyseRetrograde(false)
        else bidon := DoDialogueRetrograde(true);
    end;
end;

procedure DoChangeAfficheDernierCoup;
var oldport : grafPtr;
    a : SInt16;
begin
  afficheNumeroCoup := not(afficheNumeroCoup);
  if windowPlateauOpen and (nbreCoup > 0) then
     begin
       GetPort(oldport);
       SetPortByWindow(wPlateauPtr);
       a := DerniereCaseJouee;
       if (a <> coupInconnu) and InRange(a,11,88) then
         if afficheNumeroCoup
           then DessineNumeroCoup(a,nbreCoup,-GetCouleurOfSquareDansJeuCourant(a),GetCurrentNode)
           else
             begin
               if affichePierresDelta then EffacePierresDelta(GetCurrentNode);
               EffaceNumeroCoup(a,nbreCoup,GetCurrentNode);
               if affichePierresDelta then AfficheProprietesOfCurrentNode(true,{[a]}othellierToutEntier,'DoChangeAfficheDernierCoup');
             end;
       FlushWindow(wPlateauPtr);
       SetPort(oldport);
     end;
end;


procedure DoChangeAfficheReflexion;
begin
  with affichageReflexion do
    begin
	    if not(windowReflexOpen)
	      then
	        begin
	          doitAfficher := true;
	          OuvreFntrReflex(not(SupprimerLesEffetsDeZoom));
	          EcritReflexion('DoChangeAfficheReflexion');
	        end
	      else
	        begin
	          if (wReflexPtr <> FrontWindowSaufPalette)
	            then
	              SelectWindowSousPalette(wReflexPtr)
	            else
	              begin
	                doitAfficher := false;
	                DoClose(wReflexPtr,true);
	              end;
	        end;
    end;
end;

procedure DoChangeAfficheBibliotheque;
  begin
    afficheBibl := not(afficheBibl);
    if not(afficheBibl)
      then
        begin
          if (nbreCoup <= LongMaxBibl) then EffaceCoupsBibliotheque;
        end
      else
        begin
          if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);
        end;
     DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoChangeAfficheBibliotheque');
  end;

procedure DoChangeAfficheGestionTemps;
  begin
    if not(afficheGestionTemps) or not(windowGestionOpen)
      then
        begin
          afficheGestionTemps := true;
          if not(windowGestionOpen) then OuvreFntrGestion(not(SupprimerLesEffetsDeZoom));
          EcritGestionTemps;
          if affichageReflexion.doitAfficher then EcritReflexion('DoChangeAfficheGestionTemps');
        end
      else
        begin
          if (wGestionPtr <> FrontWindowSaufPalette)
            then SelectWindowSousPalette(wGestionPtr)
            else
              begin
                afficheGestionTemps := false;
                DoClose(wGestionPtr,true);
              end;
        end;
  end;

procedure DoChangeAfficheNuage;
  begin
    if not(afficheNuage) or not(windowNuageOpen)
      then
        begin
          afficheNuage := true;
          if not(windowNuageOpen) then OuvreFntrNuage(not(SupprimerLesEffetsDeZoom));
          DessineNuage('DoChangeAfficheNuage');
          ShowTooltipWindowInCloud;
          if affichageReflexion.doitAfficher then EcritReflexion('DoChangeAfficheNuage');
        end
      else
        begin
          if (wNuagePtr <> FrontWindowSaufPalette)
            then SelectWindowSousPalette(wNuagePtr)
            else
              begin
                afficheNuage := false;
                HideTooltipWindowInCloud;
                DoClose(wNuagePtr,true);
              end;
        end;
  end;



procedure DoChangeAfficheZebraBookBrutDeDecoffrage;
  begin

    if GetAvecAffichageNotesSurCases(kNotesDeZebra) then
      begin
        ToggleZebraOption(kAfficherZebraBookBrutDeDecoffrage);

        InvalidateAllCasesDessinEnTraceDeRayon;

        LireBibliothequeDeZebraPourCurrentNode('DoChangeAfficheZebraBookBrutDeDecoffrage');

        DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoChangeAfficheZebraBookBrutDeDecoffrage');
        DessineNoteSurCases(kNotesDeZebra,othellierToutEntier);

        if aideDebutant
          then DessineAideDebutant(true,othellierToutEntier)
          else EffaceAideDebutant(true,false,othellierToutEntier,'DoChangeAfficheZebraBookBrutDeDecoffrage');



        AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoChangeAfficheZebraBookBrutDeDecoffrage');
        if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

      end;

  end;

procedure DoChangeAfficheSuggestionDeCassio;
begin
  afficheSuggestionDeCassio := not(afficheSuggestionDeCassio);
  if not(afficheSuggestionDeCassio) then
    begin
      gDoitJouerMeilleureReponse := false;
      SetSuggestionDeFinaleEstDessinee(false);
    end;
  if aideDebutant
    then DessineAideDebutant(true,othellierToutEntier)
    else EffaceAideDebutant(true,false,othellierToutEntier,'DoChangeAfficheSuggestionDeCassio');
end;

procedure DoChangeAffichePierresDelta;
begin
  affichePierresDelta := not(affichePierresDelta);
  if affichePierresDelta
    then DesssinePierresDeltaCourantes
    else
      begin
        EffacePierresDeltaCourantes;
        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAffichePierresDelta');
      end;
  if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoChangeAffichePierresDelta');
  if afficheNumeroCoup and (nbreCoup > 0)
    then DessineNumeroCoup(GetDernierCoup,nbreCoup,-GetCouleurOfSquareDansJeuCourant(GetDernierCoup),GetCurrentNode);
end;

procedure DoChangeAfficheProchainsCoups;
begin
  EffaceProprietesOfCurrentNode;
  afficheProchainsCoups := not(afficheProchainsCoups);
  if aideDebutant then DessineAideDebutant(false,othellierToutEntier);
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAfficheProchainsCoups');
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoChangeAfficheProchainsCoups');
end;

procedure DoChangeAfficheSignesDiacritiques;
begin
  EffaceProprietesOfCurrentNode;
  if afficheNumeroCoup and (nbreCoup > 0)
    then EffaceNumeroCoup(GetDernierCoup,nbreCoup,GetCurrentNode);
  afficheSignesDiacritiques := not(afficheSignesDiacritiques);
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoChangeAfficheSignesDiacritiques');
  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoChangeAfficheSignesDiacritiques');
  if afficheNumeroCoup and (nbreCoup > 0)
    then DessineNumeroCoup(GetDernierCoup,nbreCoup,-GetCouleurOfSquareDansJeuCourant(GetDernierCoup),GetCurrentNode);
end;

procedure DoChangeAfficheNotesSurCases(origine : SInt32);
begin
  if GetAvecAffichageNotesSurCases(origine) then EffaceNoteSurCases(origine,othellierToutEntier);
  SetAvecAffichageNotesSurCases(origine,not(GetAvecAffichageNotesSurCases(origine)));

  if (origine = kNotesDeCassio) then
    begin
      if GetAvecAffichageNotesSurCases(kNotesDeCassio) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) = 0)
        then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode + kNotesCassioSurLesCases);

      if not(GetAvecAffichageNotesSurCases(kNotesDeCassio)) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) <> 0)
        then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode - kNotesCassioSurLesCases);
    end;

  if GetAvecAffichageNotesSurCases(origine) then DessineNoteSurCases(origine,othellierToutEntier);
end;

procedure DoChangeAfficheMeilleureSuite;
begin
  if afficheMeilleureSuite and MeilleureSuiteEffacee
    then
      begin
        EcritMeilleureSuite;
        meilleureSuiteEffacee := false;
      end
    else
      begin
  	    afficheMeilleureSuite := not(afficheMeilleureSuite);
  	    if afficheMeilleureSuite
  	      then EcritMeilleureSuite
  	      else
  	        begin
  	          EffaceMeilleureSuite;
  	          if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
  	        end;
      end;
end;

procedure DoTraiteClicEscargot;
var coupSuggere, defenseSuggeree: SInt32;
begin

  coupSuggere := 0;

  if (afficheSuggestionDeCassio or gDoitJouerMeilleureReponse) then
    if AttenteAnalyseDeFinaleDansPositionCourante
      then coupSuggere := GetBestMoveAttenteAnalyseDeFinale
      else coupSuggere := meilleurCoupHum;

  if (coupSuggere > 0) and (coupSuggere >= 11) and (coupSuggere <= 88) and (possibleMove[coupSuggere]) then
     begin
       (* on a déjà un coup doré affiché => on l'efface *)
       DoChangeAfficheSuggestionDeCassio;
       exit;
     end;


  (* normalement, on sait ici que l'on n'a pas de pion doré affiche *)

  coupSuggere     := 0;
  defenseSuggeree := 44;

  (* on cherche un bon coup a afficher *)
  if AttenteAnalyseDeFinaleDansPositionCourante
    then
      begin
        coupSuggere     := GetBestMoveAttenteAnalyseDeFinale;
        defenseSuggeree := GetBestDefenseAttenteAnalyseDeFinale;
      end
    else
      coupSuggere := meilleurCoupHum;
  if not((coupSuggere > 0) and (coupSuggere >= 11) and (coupSuggere <= 88) and (possibleMove[coupSuggere]))
    then coupSuggere := GetMeilleurCoupConnuMaintenant;


  if (coupSuggere > 0) and (coupSuggere >= 11) and (coupSuggere <= 88) and (possibleMove[coupSuggere]) then
    begin
      {WritelnStringAndCoupDansRapport('appel de ActiverSuggestionDeCassio, coup = ',coupSuggere);}
      afficheSuggestionDeCassio := true;

      {gDoitJouerMeilleureReponse := not(gDoitJouerMeilleureReponse);
      SetSuggestionDeFinaleEstDessinee(gDoitJouerMeilleureReponse);}

      ActiverSuggestionDeCassio(PositionEtTraitCourant,coupSuggere,defenseSuggeree,'DoTraiteClicEscargot');
    end;
end;



procedure SauvegarderDerniereDimensionFenetre2D;
var tailleFenetreActuelle : Point;
begin
  if windowPlateauOpen and (wPlateauPtr <> NIL) then
    if not(CassioEstEn3D) then
	    begin
	      tailleFenetreActuelle := GetWindowSize(wPlateauPtr);
	      tailleFenetrePlateauAvantPassageEn3D := tailleFenetreActuelle.h +  65536*tailleFenetreActuelle.v ;
	      tailleCaseAvantPassageEn3D := GetTailleCaseCourante;
	    end;
end;


procedure RestaurerDerniereDimensionFenetre2D;
var ignored : boolean;
begin
  if (tailleFenetrePlateauAvantPassageEn3D > 0) and windowPlateauOpen and (wPlateauPtr <> NIL) then
    if CassioEstEn3D then
	    begin
	      SizeWindow(wPlateauPtr,LoWord(tailleFenetrePlateauAvantPassageEn3D),HiWord(tailleFenetrePlateauAvantPassageEn3D),true);
	      AjusteAffichageFenetrePlat(tailleCaseAvantPassageEn3D,ignored,ignored);
	      MetTitreFenetrePlateau;
	    end;
end;


procedure DoChangeEn3D(avecAlerte : boolean);
var ignored : boolean;
begin
  if not(EnModeEntreeTranscript) then
    begin
      if CassioEstEn3D
        then
          begin
            RestaurerDerniereDimensionFenetre2D;
            case gLastTexture2D.theMenu of
              CouleurID   : DoCouleurMenuCommands(CouleurID,gLastTexture2D.theCmd,ignored);
              Picture2DID : DoPicture2DMenuCommands(Picture2DID,gLastTexture2D.theCmd,ignored,avecAlerte);
            end; {case}
            SetRectEscargot(MakeRect(-100,-100,-101,-101));
            CalculateRectEscargotGlobal;
          end
        else
          begin
            SauvegarderDerniereDimensionFenetre2D;
            DoPicture3DMenuCommands(gLastTexture3D.theCmd,ignored,avecAlerte);
          end;
    end;
  MetTitreFenetrePlateau;
end;


procedure RepasserEn2D(avecAlerte : boolean);
begin
  {on repasse en 2D}
  SetEnVieille3D(true);
  DoChangeEn3D(avecAlerte);
end;


procedure DoChangeDisplayJapaneseNamesInJapanese;
begin
  if gVersionJaponaiseDeCassio and gHasTextServices then
    begin
      gDisplayJapaneseNamesInJapanese := not(gDisplayJapaneseNamesInJapanese);
      InvalidateJustificationPasDePartieDansListe;
      if windowListeOpen then EcritListeParties(false,'DoChangeDisplayJapaneseNamesInJapanese');
    end;
end;

procedure DoChangeAvecGagnantEnGrasDansListe;
begin
  avecGagnantEnGrasDansListe := not(avecGagnantEnGrasDansListe);
  if windowListeOpen then EcritListeParties(false,'DoChangeAvecGagnantEnGrasDansListe');
end;

procedure TesterAffichageNomsDesGagnantsEnGras(modifiers : SInt16);
var verouillage,shift,option,control,command : boolean;
begin
  option      := BAND(modifiers,optionKey)  <> 0;
  shift       := BAND(modifiers,shiftKey)   <> 0;
  verouillage := BAND(modifiers,alphaLock)  <> 0;
  control     := BAND(modifiers,controlKey) <> 0;
  command     := BAND(modifiers,cmdKey)     <> 0;
  if (control and shift) and not(inBackGround)
    then DoChangeAvecGagnantEnGrasDansListe;
end;

procedure TesterAffichageNomsJaponaisEnRoman(modifiers : SInt16);
var verouillage,shift,option : boolean;
begin
  option := BAND(modifiers,optionKey) <> 0;
  {if (option <> avecGagnantEnGrasDansListe) then
    DoChangeAvecGagnantEnGrasDansListe;}
  if gVersionJaponaiseDeCassio then
    begin
      shift := BAND(modifiers,shiftKey) <> 0;
      verouillage := BAND(modifiers,alphaLock) <> 0;
      if verouillage <> not(gDisplayJapaneseNamesInJapanese) then
        DoChangeDisplayJapaneseNamesInJapanese;
    end;
end;

procedure DoRevenir;
var oldTextureSelection : MenuCmdRec;
    nextTick, oldIntervalle : SInt32;
    mustSuspendEngine : boolean;
begin
  if not windowPlateauOpen then DoNouvellePartie(false);
  avecCalculPartiesActives := true;
  enRetour := true;
  humainVeutAnnuler := false;

  oldTextureSelection.theMenu := gCouleurOthellier.menuID;
  oldTextureSelection.theCmd := gCouleurOthellier.menuCmd;
  if EnVieille3D then
     gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
  ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
  DessineRetour(NIL,'DoRevenir');
  AjusteCurseur;
  AjusteSleep;
  DisableItemTousMenus;
  DisableTitlesOfMenusForRetour;

  SetIntervalleVerificationDuStatutDeCassioPourLeZoo(-1000, @oldIntervalle);
  VerifierLeStatutDeCassioPourLeZoo;
  SetIntervalleVerificationDuStatutDeCassioPourLeZoo(oldIntervalle, NIL);

  mustSuspendEngine := CassioIsWaitingAnEngineResult;
  if mustSuspendEngine then SuspendCurrentEngine;

  nextTick := tickCount + 60;
  repeat  // loop
    if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
      then TraiteEvenements
      else TraiteNullEvent(theEvent);
    AjusteCurseur;
    // une fois toute les secondes, en gros
    if TickCount > nextTick then
      begin
        CheckStreamEvents;
        GererTelechargementWThor;
        EnvoyerUnKeepAliveSiNecessaire;
        nextTick := TickCount + 60;
      end;
  until not(enRetour) or Quitter or humainVeutAnnuler or not(windowPlateauOpen);

  if mustSuspendEngine then ResumeCurrentEngine;

  if humainVeutAnnuler then
    begin
      enRetour := false;
      humainVeutAnnuler := false;
      AjusteSleep;
      dernierTick := TickCount;
      if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,false);
    end;
  if (gCouleurOthellier.menuID <> oldTextureSelection.theMenu) or (gCouleurOthellier.menuCmd <> oldTextureSelection.theCmd)
    then
	    begin
	      gCouleurOthellier := CalculeCouleurRecord(oldTextureSelection.theMenu,oldTextureSelection.theCmd);
	      EcranStandard(NIL,false);
	    end
	  else
	    begin
	      if gCouleurOthellier.estUneImage {and not(CassioEstEn3D)} and not(Quitter) then
	        DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(nbreCoup); {effacement des numeros fantomes}
	      EcranStandard(NIL,false);
	    end;
	TachesUsuellesPourAffichageCourant;
	AjusteSleep;
  EnableItemTousMenus;
  EnableAllTitlesOfMenus;

  SetIntervalleVerificationDuStatutDeCassioPourLeZoo(-1000, @oldIntervalle);
  VerifierLeStatutDeCassioPourLeZoo;
  SetIntervalleVerificationDuStatutDeCassioPourLeZoo(oldIntervalle, NIL);
end;


procedure DoDebut(ForceHumCtreHum : boolean);
var i,numeroDuCoupInitial : SInt16;
begin
  if not(windowPlateauOpen) then DoNouvellePartie(ForceHumCtreHum);

  if not(HumCtreHum) and not(CassioEstEnModeSolitaire) and ForceHumCtreHum
    then DoChangeHumCtreHum;
  numeroDuCoupInitial := nbreCoup+1;
  for i := nbreCoup downto 1 do
    if (GetNiemeCoupPartieCourante(i) <> 0) then numeroDuCoupInitial := i;
  if nbreCoup > numeroDuCoupInitial-1 then
    begin
      if nbreCoup = numeroDuCoupInitial+1 then DoDoubleBackMove else
      if nbreCoup = numeroDuCoupInitial then DoBackMove else
        DoRetourAuCoupNro(numeroDuCoupInitial-1,true,ForceHumCtreHum);
    end;
  dernierTick := TickCount;
  PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
  gGongDejaSonneDansCettePartie := false;
  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);
end;




procedure DoCoefficientsEvaluation;
const
    CoefficientsID = 133;
    OK = 1;
    Annuler = 2;
    ValeursStandard = 3;
    TablesPositionnellesBox = 4;
var dp : DialogPtr;
    itemHit : SInt16;
    unRect : rect;
    FiltreCoeffDialogUPP : ModalFilterUPP;
    err : OSErr;
    CoeffinfluenceArrivee : double;
    CoefffrontiereArrivee : double;
    CoeffEquivalenceArrivee : double;
    CoeffcentreArrivee : double;
    CoeffgrandcentreArrivee : double;
    CoeffdispersionArrivee : double;
    CoeffminimisationArrivee : double;
    CoeffpriseCoinArrivee : double;
    CoeffdefenseCoinArrivee : double;
    CoeffValeurCoinArrivee : double;
    CoeffValeurCaseXArrivee : double;
    CoeffPenaliteArrivee : double;
    CoeffMobiliteUnidirectionnelleArrivee : double;
    EvalueTablesDeCoinsArrivee : boolean;

procedure SauveValeursArrivee;
begin
    CoeffinfluenceArrivee := CoeffInfluence;
    CoefffrontiereArrivee := Coefffrontiere;
    CoeffEquivalenceArrivee := CoeffEquivalence;
    CoeffcentreArrivee := Coeffcentre;
    CoeffgrandcentreArrivee := Coeffgrandcentre;
    CoeffdispersionArrivee := Coeffbetonnage;
    CoeffminimisationArrivee := Coeffminimisation;
    CoeffpriseCoinArrivee := CoeffpriseCoin;
    CoeffdefenseCoinArrivee := CoeffdefenseCoin;
    CoeffValeurCoinArrivee := CoeffValeurCoin;
    CoeffValeurCaseXArrivee := CoeffValeurCaseX;
    CoeffPenaliteArrivee := CoeffPenalite;
    CoeffMobiliteUnidirectionnelleArrivee := CoeffMobiliteUnidirectionnelle;
    EvalueTablesDeCoinsArrivee := avecEvaluationTablesDeCoins;
end;


procedure RemetValeursArrivee;
begin
    CoeffInfluence := CoeffinfluenceArrivee;
    Coefffrontiere := CoefffrontiereArrivee;
    CoeffEquivalence := CoeffEquivalenceArrivee;
    Coeffcentre := CoeffcentreArrivee;
    Coeffgrandcentre := CoeffgrandcentreArrivee;
    Coeffbetonnage := CoeffdispersionArrivee;
    Coeffminimisation := CoeffminimisationArrivee;
    CoeffpriseCoin := CoeffpriseCoinArrivee;
    CoeffdefenseCoin := CoeffdefenseCoinArrivee;
    CoeffValeurCoin := CoeffValeurCoinArrivee;
    CoeffValeurCaseX := CoeffValeurCaseXArrivee;
    CoeffPenalite := CoeffPenaliteArrivee;
    CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelleArrivee;
    avecEvaluationTablesDeCoins := EvalueTablesDeCoinsArrivee;
end;


begin
  BeginDialog;
  FiltreCoeffDialogUPP := NewModalFilterUPP(FiltreCoeffDialog);
  dp := MyGetNewDialog(CoefficientsID);
  if dp <> NIL then
  begin
    Superviseur(nbreCoup);
    EcritParametres(dp,0);
    DessineEchellesCoeffs(dp);
    EcritEtDessineBords;
    SetBoolCheckBox(dp,TablesPositionnellesBox,avecEvaluationTablesDeCoins);
    if avecEvaluationTablesDeCoins
      then EcritValeursTablesPositionnelles(dp)
      else EffaceValeursTablesPositionnelles(dp);
    SauveValeursArrivee;
    err := SetDialogTracksCursor(dp,true);
    repeat
      ModalDialog(FiltreCoeffDialogUPP,itemHit);
      case itemHit of
        VirtualUpdateItemInDialog:
          begin
            BeginUpdate(GetDialogWindow(dp));
            SetPortByDialog(dp);
            if gCassioUseQuartzAntialiasing then MyEraseRect(GetWindowPortRect(GetDialogWindow(dp)));
            OutlineOK(dp);
            MyDrawDialog(dp);
            EcritParametres(dp,0);
            DessineEchellesCoeffs(dp);
            EcritEtDessineBords;
            if avecEvaluationTablesDeCoins
				      then EcritValeursTablesPositionnelles(dp)
				      else EffaceValeursTablesPositionnelles(dp);
            EndUpdate(GetDialogWindow(dp));
          end;
        OK:;
        Annuler:
           begin
             RemetValeursArrivee;
             Superviseur(nbreCoup);
           end;
        ValeursStandard:
           begin
             CoefficientsStandard;
             Superviseur(nbreCoup);
             if gCassioUseQuartzAntialiasing then MyEraseRect(GetWindowPortRect(GetDialogWindow(dp)));
             with EchelleCoeffsRect do
               SetRect(unRect,220,top-2,right+60,EchelleCoeffsRect.bottom+2);
             MyEraseRect(unRect);
             EcritParametres(dp,0);
             DessineEchellesCoeffs(dp);
             EcritEtDessineBords;
             if avecEvaluationTablesDeCoins
					      then EcritValeursTablesPositionnelles(dp)
					      else EffaceValeursTablesPositionnelles(dp);
					   MyDrawDialog(dp);
           end;
         TablesPositionnellesBox:
           begin
             DoChangeEvaluationTablesDeCoins;
             SetBoolCheckBox(dp,TablesPositionnellesBox,avecEvaluationTablesDeCoins);
             if avecEvaluationTablesDeCoins
					      then EcritValeursTablesPositionnelles(dp)
					      else EffaceValeursTablesPositionnelles(dp);
           end;
      end; {case}
    until (itemHit = OK) or (itemHit = Annuler);
    MyDisposeDialog(dp);
    AjusteSleep;
    if not(enSetUp) then
      if HasGotEvent(updateMask,theEvent,0,NIL) then
        TraiteOneEvenement;
  end;
  MyDisposeModalFilterUPP(FiltreCoeffDialogUPP);
  EndDialog;
  AjusteSleep;
end;




procedure DoMakeMainBranch;
const MakeMainBranchID = 157;
      Annuler = 2;
      OK = 1;
var itemHit : SInt16;
    confirmationMakeMainBranch : boolean;
    G : GameTree;
begin
  confirmationMakeMainBranch := true;

  itemHit := AlertTwoButtonsFromRessource(MakeMainBranchID, 3, 0, OK, Annuler) ;

  if (itemHit = Annuler)
    then confirmationMakeMainBranch := false
    else confirmationMakeMainBranch := true;

  if confirmationMakeMainBranch then
    begin
      EffaceProprietesOfCurrentNode;
      G := GetCurrentNode;
      MakeMainLineInGameTree(G);
      AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoMakeMainBranch');
      DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DoMakeMainBranch');
    end;
end;


procedure DoCourbe;
  begin
    if windowCourbeOpen
      then
        begin
          if (wCourbePtr <> FrontWindowSaufPalette)
            then SelectWindowSousPalette(wCourbePtr)
            else DoClose(wCourbePtr,true);
        end
      else
        OuvreFntrCourbe(not(SupprimerLesEffetsDeZoom));
  end;

procedure DoRapport;
  begin
    if FenetreRapportEstOuverte
      then
        begin
          if not(FenetreRapportEstAuPremierPlan)
            then SelectWindowSousPalette(GetRapportWindow)
            else DoClose(GetRapportWindow,true);
        end
      else OuvreFntrRapport(not(SupprimerLesEffetsDeZoom),true);
  end;


{
procedure DoChangeSensLargeSolitaire;
  begin
    SensLargeSolitaire := not(SensLargeSolitaire);
  end;
}

procedure DoChangeReferencesCompletes;
  begin
    referencesCompletes := not(referencesCompletes);
  end;

{
procedure DoChangeFinaleEnSolitaire;
  begin
    finaleEnModeSolitaire := not(finaleEnModeSolitaire);
  end;
}

procedure DoChangeSensLectureBase;
  begin
    LectureAntichronologique := not(LectureAntichronologique);
  end;

procedure DoChangePalette;
begin
  if windowPaletteOpen and (wPalettePtr <> NIL)
    then DoClose(wPalettePtr,true)
    else OuvreFntrPalette;
end;

procedure DoStatistiques;
 begin
   if avecGestionBase then
      if windowStatOpen
        then
          begin
            if (wStatPtr <> FrontWindowSaufPalette)
              then SelectWindowSousPalette(wstatptr)
              else DoClose(wStatPtr,true);
          end
        else
          begin
            OuvreFntrStat(not(SupprimerLesEffetsDeZoom));
            if windowStatOpen then
              begin
                SetPositionsTextesWindowPlateau;
                if afficheInfosApprentissage then EcritLesInfosDApprentissage;
              end;
            if not(windowListeOpen) then
              begin
                IncrementeMagicCookieDemandeCalculsBase;
                ConstruitTablePartiesActives(false,false);
                ConstruitTableNumeroReference(false,false);
                EssayerConstruireTitrePartie;
              end;
            if windowStatOpen then
              begin
                ConstruitStatistiques(false);
                EcritRubanStatistiques;
                EcritStatistiques(false);
              end;
          end;
   FixeMarqueSurMenuBase;
 end;


procedure DoListeDeParties;
 begin
  if avecGestionBase then
    if windowListeOpen
      then
        begin
          if ((wListePtr = FrontWindowSaufPalette) and not(AutorisationDeChargerLaBaseSansInterventionUtilisateur))
            then
              DoClose(wListePtr,true)
            else
              begin
                if (wListePtr <> FrontWindowSaufPalette) then SelectWindowSousPalette(wListePtr);

                if AutorisationDeChargerLaBaseSansInterventionUtilisateur and not(DernierEvenement.option)
                  then DoChargerLaBaseSansInterventionUtilisateur;
              end;
        end
      else
        begin

          OuvreFntrListe(not(SupprimerLesEffetsDeZoom));
          if windowListeOpen then
            begin

              SetPositionsTextesWindowPlateau;

              if afficheInfosApprentissage then EcritLesInfosDApprentissage;

              if not(windowStatOpen) then
                begin
                  IncrementeMagicCookieDemandeCalculsBase;
                  ConstruitTablePartiesActives(false,false);
                  ConstruitTableNumeroReference(false,false);
                  EssayerConstruireTitrePartie;
                end;

              with infosListePartiesDerniereFermeture do
                if (nombrePartiesActives  = nbPartiesActives) and
                   (nombrePartiesChargees = nbPartiesChargees) and
                   (nbreLignesFntreListe  = CalculeNbreLignesVisiblesFntreListe) and
                   (partieHilitee >= 1) and
                   (partieHilitee <= nbPartiesActives) and
                   (tableNumeroReference^^[partieHilitee] = dernierNroReferenceHilitee)
                 then
                   begin
                     {ce qui suit est mieux que SetPartieHiliteeEtAjusteAscenseurListe(partieHilitee) car on conserve la position de l'ascenseur}
                     SetControlLongintMinimum(longintMinimum);
                     SetControlLongintMaximum(longintMaximum);
                     SetValeurAscenseurListe(positionPouceAscenseurListe);
                     SetPartieHilitee(partieHilitee);
                     AjustePouceAscenseurListe(false);
                   end
                 else
                   begin
                     AjustePouceAscenseurListe(false);
                     NroReference2NroHilite(dernierNroReferenceHilitee,infosListeParties.partieHilitee);
                     SetPartieHiliteeEtAjusteAscenseurListe(infosListeParties.partieHilitee);
                   end;

              if AutorisationDeChargerLaBaseSansInterventionUtilisateur and not(DernierEvenement.option)
                then DoChargerLaBaseSansInterventionUtilisateur
                else EcritListeParties(false,'DoListeDeParties');

            end;
        end;
   FixeMarqueSurMenuBase;
 end;

procedure DoCommentaires;
var commentaireChange : boolean;
begin
  with arbreDeJeu do
    begin
		  if windowOpen
		    then
		      begin
		        if (GetArbreDeJeuWindow <> FrontWindowSaufPalette)
		          then SelectWindowSousPalette(GetArbreDeJeuWindow)
		          else DoClose(GetArbreDeJeuWindow,true);
		      end
		    else
		      begin
		        OuvreFntrCommentaires(not(SupprimerLesEffetsDeZoom));
		        SetTexteFenetreArbreDeJeuFromArbreDeJeu(GetCurrentNode,false,commentaireChange);
		      end;
		  ValideZoneCommentaireDansFenetreArbreDeJeu;
    end;
end;

procedure DoChangeDessineAide;
begin
  if windowAideOpen
    then CloseAideWindow
    else
      begin
        OuvreFntrAide;
        DessineAide(gAideCourante);
      end;
end;

procedure DoChangeAfficheInfosApprentissage;
var oldport : grafPtr;
  begin
    afficheInfosApprentissage := not(afficheInfosApprentissage);
    GetPort(oldPort);
    EssaieSetPortWindowPlateau;
    InvalRect(QDGetPortBound);
    SetPort(oldport);
  end;

procedure DoChangeUtiliseGrapheApprentissage;
  begin
    UtiliseGrapheApprentissage := not(UtiliseGrapheApprentissage);
  end;

procedure DoChangeLaDemoApprend;
  begin
    LaDemoApprend := not(LaDemoApprend);
  end;

procedure DoChangeEffetSpecial1;
  begin
    SetEffetSpecial(not(GetEffetSpecial));
  end;

procedure DoChangeEffetSpecial2;
  begin
    effetspecial2 := not(effetspecial2);
  end;

procedure DoChangeEffetSpecial3;
  begin
    effetspecial3 := not(effetspecial3);
  end;
{
procedure DoChangeEffetSpecial4;
  begin
    effetspecial4 := not(effetspecial4);
  end;

procedure DoChangeEffetSpecial5;
  begin
    effetspecial5 := not(effetspecial5);
  end;

procedure DoChangeEffetSpecial6;
  begin
    effetspecial6 := not(effetspecial6);
  end;

}
{
procedure DoChangeSelectivite;
  begin
    avecSelectivite := not(avecSelectivite);
  end;
}

procedure DoChangeNomOuverture;
  begin
    avecNomOuvertures := not(avecNomOuvertures);
    if not(affichebibl) then DoChangeAfficheBibliotheque;
  end;


{
procedure DoChangeToujoursIndexer;
  begin
    ToujoursIndexerBase := not(ToujoursIndexerBase);
  end;
}

procedure DoChangeAvecSystemeCoordonnees;
begin
  avecSystemeCoordonnees := not(avecSystemeCoordonnees);
  AjusteAffichageFenetrePlatRapide;

  if not(EnVieille3D) then
    begin
      InvalidateAllCasesDessinEnTraceDeRayon;
      EcranStandard(NIL,true);
    end;
end;

procedure DoChangeGarderPartieNoireADroiteOthellier;
begin
  garderPartieNoireADroiteOthellier := not(garderPartieNoireADroiteOthellier);
  AjusteAffichageFenetrePlatRapide;

  if not(EnVieille3D) then
    begin
      InvalidateAllCasesDessinEnTraceDeRayon;
      EcranStandard(NIL,true);
    end;
end;


procedure DoChangeAvecReflexionTempsAdverse;
  begin
    sansReflexionSurTempsAdverse := not(sansReflexionSurTempsAdverse);

    if sansReflexionSurTempsAdverse and not(HumCtreHum) and (AQuiDeJouer = -couleurMacintosh) then
       LanceInterruptionSimpleConditionnelle('DoChangeAvecReflexionTempsAdverse');
  end;

procedure DoChangeAvecBibl;
  begin
    avecBibl := not(avecBibl);
  end;

procedure DoChangeVarierOuvertures;
  begin
    with gEntrainementOuvertures do
      begin
        CassioVarieSesCoups := not(CassioVarieSesCoups);
        if CassioVarieSesCoups then modeVariation := kVarierEnUtilisantMilieu;
      end;
  end;

procedure DoChangeJoueBonsCoupsBibl;
  begin
    JoueBonsCoupsBibl := not(JoueBonsCoupsBibl);
  end;

procedure DoChangeEnModeIOS;
  begin
    enModeIOS := not(enModeIOS);
  end;

procedure DoChangeSousEmulatorSousPC;
  begin
    sousEmulatorSousPC := not(sousEmulatorSousPC);
  end;

procedure DoChangeInfosTechniques;
  begin
    InfosTechniquesDansRapport := not(InfosTechniquesDansRapport);
  end;

procedure DoChangeEcrireDansRapportLog;
  begin
    ecrireDansRapportLog := GetEcritToutDansRapportLog;
    ecrireDansRapportLog := not(ecrireDansRapportLog);
    SetEcritToutDansRapportLog(ecrireDansRapportLog);
    SetAutoVidageDuRapport(ecrireDansRapportLog);
  end;

procedure DoChangeUtilisationNouvelleEval;
  begin
    if utilisationNouvelleEval
      then utilisationNouvelleEval := false
      else
        if not(VecteurEvalIntegerEstVide(vecteurEvaluationInteger)) and FichierEvaluationDeCassioTrouvable('Evaluation de Cassio')
          then utilisationNouvelleEval := true;
  end;

procedure DoChangeUtiliserMetaphone;
  begin
    SetCassioIsUsingMetaphone(not(CassioIsUsingMetaphone));
    RegenererLesNomsMetaphoneDeLaBase;
  end;

procedure DoChangeEnTraitementDeTexte;
const MachineAEcrireID = 10129;
  begin
    EnTraitementDeTexte := not(EnTraitementDeTexte);
    if EnTraitementDeTexte
      then
        begin
          PlaySoundSynchrone(MachineAEcrireID, 128);
          EnableKeyboardScriptSwitch;
          arbreDeJeu.doitResterEnModeEdition := arbreDeJeu.enModeEdition;
        end
      else
        begin
          arbreDeJeu.doitResterEnModeEdition := false;
        end;
  end;

procedure DoChangePostscriptCompatibleXPress;
  begin
    PostscriptCompatibleXPress := not(PostscriptCompatibleXPress);
  end;

procedure DoChangeArrondirEvaluations;
  begin
    utilisateurVeutDiscretiserEvaluation := not(utilisateurVeutDiscretiserEvaluation);
  end;

procedure DoChangeFaireConfianceScoresArbre;
  begin
    seMefierDesScoresDeLArbre := not(seMefierDesScoresDeLArbre);
  end;

procedure DoChangeInterversions;
begin
  avecInterversions := not(avecInterversions);
  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
  if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
      then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
end;




procedure DoChoisitDemo;
  begin
    if enTournoi then
      begin
        Quitter := true;
        LanceInterruptionSimple('DoChoisitDemo');
        vaDepasserTemps := false;
        enTournoi := false;
      end
    else
      begin
        enTournoi := true;
        if BAND(theEvent.modifiers,optionKey) <> 0
          then DoDemo(-1,-1,false,true)
          else DoDemo(7,7,false,true);
        PrepareNouvellePartie(false);
      end;
  end;

{
procedure DoChangeAnalyse;
  begin
    analyse := not(analyse);
    if analyse then
     begin
       cadence := minutes10000000;
       if not(affichageReflexion.doitAfficher) then DoChangeAffichereflexion;
       if not(afficheGestionTemps) then DoChangeAfficheGestionTemps;
       if not(afficheMeilleureSuite) then DochangeafficheMeilleureSuite;
       if not(afficheSuggestionDeCassio) then DochangeafficheSuggestionDeCassio;
       if not(afficheNumeroCoup) then DoChangeAfficheDernierCoup;
       AjusteCadenceMin(cadence);
       dernierTick := TickCount;
       Heure(pionNoir);
       Heure(pionBlanc);
     end
     else
     begin
       cadence := minutes3;
       if affichageReflexion.doitAfficher then DoChangeAffichereflexion;
       if afficheGestionTemps then DoChangeAfficheGestionTemps;
       if afficheMeilleureSuite then DochangeafficheMeilleureSuite;
       if afficheSuggestionDeCassio then DochangeafficheSuggestionDeCassio;
       if afficheNumeroCoup then DoChangeAfficheDernierCoup;
       AjusteCadenceMin(cadence);
       dernierTick := TickCount;
       Heure(pionNoir);
       Heure(pionBlanc);
       EcranStandard;
     end;
  end;
}


procedure DoChangeProfImposee;
begin
  SetProfImposee(not(ProfondeurMilieuEstImposee),'DoChangeProfImposee')
end;



procedure DoSetUp;
  begin
    enSetUp := true;

    DisableItemTousMenus;
    MyDisableItem(PartieMenu,0);
    MyDisableItem(ModeMenu,0);
    MyDisableItem(JoueursMenu,0);
    MyDisableItem(BaseMenu,0);
    MyDisableItem(SolitairesMenu,0);
    MyDisableItem(AffichageMenu,0);
    if avecProgrammation then MyDisableItem(ProgrammationMenu,0);
    DrawMenuBar;
    if not windowPlateauOpen then DoNouvellePartie(true);
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
    NoUpdateWindowPlateau;
    AjusteSleep;

    SetUp;

    enSetUp := false;
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
    if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier) then SetAffichageResserre(true);
    EnableItemTousMenus;
    MyEnableItem(PartieMenu,0);
    MyEnableItem(ModeMenu,0);
    MyEnableItem(JoueursMenu,0);
    MyEnableItem(BaseMenu,0);
    MyEnableItem(SolitairesMenu,0);
    MyEnableItem(AffichageMenu,0);
    if avecProgrammation then MyEnableItem(ProgrammationMenu,0);
    DrawMenuBar;
    AjusteSleep;
  end;




procedure FermeToutEtQuitte;
var tick : SInt32;
  begin
    gameOver := true;
    Quitter := true;
    while (FrontWindow <> NIL) and ((TickCount-tick) < 500) do
        DoClose(FrontWindow,false);
    LanceInterruptionSimple('FermeToutEtQuitte');
    vaDepasserTemps := false;
    FlushEvents(everyEvent-DiskEvt,0);
    tick := TickCount;
    while (FrontWindow <> NIL) and ((TickCount-tick) < 500) do
        DoClose(FrontWindow,false);
    {donnons une chance aux autres applications de se redessiner}
    ShareTimeWithOtherProcesses(10);
  end;

procedure FermeToutesLesFenetresAuxiliaires;
var tick : SInt32;
    whichWindow,windowAux : WindowPtr;
  begin
    tick := TickCount;
    whichWindow := FrontWindowSaufPalette;
    while (whichWindow <> NIL) and ((TickCount-tick) < 500) do
      begin
        windowAux := MyGetNextWindow(whichWindow);
        if IsWindowVisible(whichWindow) then
          if (whichWindow <> wPlateauPtr) and (whichWindow <> wPalettePtr) and (whichWindow <> iconisationDeCassio.theWindow) then
            DoClose(whichWindow,false);
        whichWindow := windowAux;
      end;
  end;


procedure DoQuit;      {utilisee dans UnitAppleEventsCassio.p}
begin
  if ConfirmationQuitter then
    if doitConfirmerQuitter or PeutArreterAnalyseRetrograde then
    begin
      {gameOver := true;}
      Quitter := true;
      LanceInterruptionSimple('DoQuit');
      vaDepasserTemps := false;
      if EnModeEntreeTranscript then DoChangeEnModeEntreeTranscript;
      doitEcrireInterversions := BAND(theEvent.modifiers,optionKey) <> 0;
    end;
end;

procedure DoMaster;
  begin
    DerouleMaster;
    DrawMenuBar;
  end;


procedure DoTracerNuage;
begin
 if not(windowNuageOpen) then DoChangeAfficheNuage;
 if (nbPartiesActives <= 10) and (nbreCoup > 0) and (nbPartiesChargees > 0) then
   begin
     DoDebut(false);
     LanceNouvelleDemandeCalculsPourBase(false,true);
     CalculsEtAffichagePourBase(false,true);
   end;
 DessineNuageDePointsRegression;
end;


procedure DoSymetrie(axe : SInt32);
const OuiBouton = 1;
var s,s1 : String255;
    i,coup,t,x : SInt16;
    tempoAideDebutant : boolean;
    platAux,positionInitialeCourante : plateauOthello;
    gameNodeLePlusProfond : GameTree;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
    oldCheckDangerousEvents : boolean;
begin

    SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

    tempoAideDebutant := aideDebutant;

    if (nbreCoup > 0) and EnModeEntreeTranscript and
       ((NombreCasesVidesTranscriptCourant > 0) or not(TranscriptCourantEstUnePartieLegaleEtComplete)) {and
       PlusLonguePartieLegaleDuTranscriptEstDansOthellierDeGauche}
      then ViderTranscriptCourant;


    if positionFeerique and not(EnModeEntreeTranscript) and GameTreeHasStandardInitialPositionInversed then
      begin

        s := ReadStringFromRessource(TextesErreursID,22);  { 'Souhaitez-vous redresser la position initiale ?' }
        s1 := ReadStringFromRessource(TextesErreursID,23);

        if (AlerteDoubleOuiNon(s,s1) = OuiBouton)
          then axe := axeVertical;
      end;

    if not(enRetour) then EffaceProprietesOfCurrentNode;
    EffectueSymetrieArbreDeJeuGlobal(axe);


    if debuggage.arbreDeJeu and not(enRetour) then
      begin
        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {1}');
        WritelnNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie));
        WritelnNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode));
        SysBeep(0);
        AttendFrappeClavier;
      end;

    s := '';
    if (nroDernierCoupAtteint > 0) then
      for i := 1 to nroDernierCoupAtteint do
        begin
          coup := GetNiemeCoupPartieCourante(i);
          if coup > 0 then s := s + CoupEnStringEnMajuscules(CaseSymetrique(coup,axe));
        end;
    s1 := s;
    if positionFeerique then
      for i := 1 to nbreCoup do
        if (GetNiemeCoupPartieCourante(i) = 0) then s := '  '+s;   {double espace}

    GetPositionInitialeOfGameTree(positionInitialeCourante,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
    for t := 1 to 64 do
      begin
        x := othellier[t];
        plataux[CaseSymetrique(x,axe)] := positionInitialeCourante[x];
      end;
    SetPositionInitialeOfGameTree(platAux,traitInitial,nbBlancsInitial,nbNoirsInitial);


    if (LENGTH_OF_STRING(s) > 0) or positionFeerique then
      begin

        if debuggage.arbreDeJeu then
          begin
		        AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {2}');
		        WritelnNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie));
		        WritelnNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode));
		        SysBeep(0);
		        AttendFrappeClavier;
          end;

        if not(enRetour)
          then
            begin
              RejouePartieOthello(s,nbreCoup,not(positionFeerique),platAux,GetCouleurNiemeCoupPartieCourante(nbreCoup+1),gameNodeLePlusProfond,false,false);

              if debuggage.arbreDeJeu then
                begin
		              AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoSymetrie {3}');
		              WritelnNumDansRapport('Adresse de la racine = ',SInt32(GetRacineDeLaPartie));
		              WritelnNumDansRapport('Adresse du noeud courant = ',SInt32(GetCurrentNode));
					        SysBeep(0);
					        AttendFrappeClavier;
                end;
            end
          else
            begin
              RejouePartieOthelloFictive(s,nbreCoup,not(positionFeerique),platAux,GetCouleurNiemeCoupPartieCourante(nbreCoup+1),gameNodeLePlusProfond,kNoFlag);
              DessineRetour(NIL,'DoSymetrie');
            end;

        if (nbreCoup < (LENGTH_OF_STRING(s) div 2)) then
          MiseAJourDeLaPartie(s1,JeuCourant,emplJouable,frontiereCourante,
                              nbreDePions[pionBlanc],nbreDePions[pionNoir],
                              AQuiDeJouer,nbreCoup,false, (LENGTH_OF_STRING(s) div 2),
                              gameNodeLePlusProfond,'DoSymetrie');
      end;

    if not(enRetour) then
      begin
        aideDebutant := tempoAideDebutant;
        AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DoSymetrie {4}');
      end;

    positionFeerique := not(GameTreeHasStandardInitialPosition);

    if SelectionRapportNonVide then
      DoSymetrieSelectionDuRapport(axe);

    SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;



procedure OuvrePartieSelectionnee(nroHilite : SInt32);
var s255 : String255;
    s60 : PackedThorGame;
    nomNoir,nomBlanc : String255;
    scoreNoir : SInt16;
    titre : String255;
    nroreference : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup, axe : SInt16;
    gameNodeLePlusProfond : GameTree;
begin
  if windowListeOpen then
    begin
      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
      if (nroHilite >= premierNumero) and (nroHilite <= dernierNumero) then
        if (nroHilite >= 1) and (nroHilite <= nbPartiesActives) then
          begin
            {nroReference := tableNumeroReference^^[nroHilite];
            if nroReference <> infosListeParties.dernierNroReferenceHilitee then SysBeep(0);}
            nroReference := infosListeParties.dernierNroReferenceHilitee;

		        ExtraitPartieTableStockageParties(nroReference,s60);
		        ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		        ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		        TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie and ouvertureDiagonale,4,60);
		        TraductionThorEnAlphanumerique(s60,s255);

		        if not(EstUnePartieOthello(s255,false)) then
		          begin
		            Sysbeep(0);
		            WritelnDansRapport('ERREUR : partie illégale dans la base !');
		            WritelnDansRapport(s255);
		            exit;
		          end;

		        if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) and
		           not(TrouveSymetrieEgalisante(JeuCourant, nbreCoup, s60, axe)) then
			        begin
			          WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans OuvrePartieSelectionnee');
			          with DemandeCalculsPourBase do
	              if (EtatDesCalculs <> kCalculsEnCours) or (NumeroDuCoupDeLaDemande <> nbreCoup) or bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	              InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
			          exit;
			        end;


            CommentaireSolitaire^^ := '';
            finaleEnModeSolitaire := false;
            NoUpdateWindowPlateau;

            TraductionThorEnAlphanumerique(s60,s255);

            (* RejouePartieOthello(s255,LENGTH_OF_STRING(s255) div 2,true,bidplat,0,gameNodeLePlusProfond,false,true); *)

            RejouePartieOthelloFictive(s255,LENGTH_OF_STRING(s255) div 2,true,bidplat,0,gameNodeLePlusProfond,kNoFlag);
            DrawContents(wPlateauPtr);


            nomNoir := GetNomJoueurNoirSansPrenomParNroRefPartie(nroreference);
            nomBlanc := GetNomJoueurBlancSansPrenomParNroRefPartie(nroreference);
            scoreNoir := GetScoreReelParNroRefPartie(nroreference);

            ConstruitTitrePartie(nomNoir,nomBlanc,true,scoreNoir,titre);
            titrePartie^^ := titre;
            ParamDiagCourant.titreFFORUM^^ := titre;
						ParamDiagCourant.commentPositionFFORUM^^ := '';
						ParamDiagPositionFFORUM.titreFFORUM^^ := '';
						ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
						ParamDiagPartieFFORUM.titreFFORUM^^ := titre;
            ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
          end;
     end;
end;



procedure DoProgrammation;
begin
  if avecProgrammation
    then
      begin
        avecProgrammation := false;
        DeleteMenu(programmationID);
        TerminateMenu(ProgrammationMenu,true);
        DrawMenuBar;
      end
    else
      begin
        avecProgrammation := true;
        ProgrammationMenu := MyGetMenu(programmationID);
        MyLockMenu(ProgrammationMenu);
        InsertMenu(ProgrammationMenu,0);
        DrawMenuBar;
      end;
end;



procedure OuvreAccessoireDeBureau(cmdNumber : SInt16);
var DAName  : String255;
begin
  if (FrontWindow = NIL) and not(iconisationDeCassio.enCours) then
     EnableMenu(EditionMenu,[AnnulerCmd,CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
   MyGetMenuItemText(GetAppleMenu,cmdNumber,DAName);
end;


procedure DoPommeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin {$UNUSED peutRepeter}
    case cmdNumber of
      AboutCmd                : DisplayCassioAboutBox;
      {FFOCmd                  : DerouleMaster;}
      PreferencesDansPommeCmd : if gIsRunningUnderMacOSX
                                  then DoDialoguePreferences
                                  else OuvreAccessoireDeBureau(cmdNumber);
      otherwise                 OuvreAccessoireDeBureau(cmdNumber);
		end; {case}
  end;


procedure DoFileMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var shift,command,option,control : boolean;
  begin
    {$UNUSED peutRepeter}
    shift := BAND(theEvent.modifiers,shiftKey) <> 0;
    command := BAND(theEvent.modifiers,cmdKey) <> 0;
    option := BAND(theEvent.modifiers,optionKey) <> 0;
    control := BAND(theEvent.modifiers,controlKey) <> 0;

    case cmdNumber of
      NouvellePartieCmd         :  if PeutArreterAnalyseRetrograde then
                                     if positionFeerique {or not(HumCtreHum)} or (nbreCoup = 0)
                                       then DoNouvellePartie(false)
                                       else DoDebut(false);
      OuvrirCmd                 :  DoOuvrir;
      ReouvrirCmd               :  {desormais géré par le sous-menu};
      CloseCmd                  :  DoCloseCmd(theEvent.modifiers);
      ImporterUnRepertoireCmd   :  ImporterToutesPartiesRepertoire;
      EnregistrerPartieCmd      :  DoEnregistrerSous(false);
      EnregistrerArbreCmd       :  DoEnregistrerSous(true);
      FormatImpressionCmd       :  DoDialogueFormatImpression;
      ApercuAvantImpressionCmd  :  DoDialogueApercuAvantImpression;
      ImprimerCmd               :  DoProcessPrinting(true);
      PreferencesCmd            :  DoDialoguePreferences;
      IconisationCmd            :  If not(iconisationDeCassio.enCours)
                                     then
                                       begin
                                         if not(windowPlateauOpen) then DoNouvellePartie(false);
                                         IconiserCassio;
                                       end
                                     else DeiconiserCassio;
      QuitCmd                   :  DoQuit;
    end;
  end;

procedure DoEditionMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var positionEtCoupStr : String255;
    chainePositionInitiale,chainePosition,chaineCoups : String255;
    s : String255;
    positionNormale : boolean;
begin
  case cmdNumber of
    AnnulerCmd    : if enRetour or enSetUp
                      then humainVeutAnnuler := true
                      else
                        if PeutArreterAnalyseRetrograde then
                          begin
                            if theEvent.what = autoKey
                              then DoDoubleBackMove
                              else DoBackMove;
                            peutrepeter := (nbreCoup > 0);
                          end;
    CouperCmd     : if not(CouperFromRapport) then
                      if FenetreListeEstEnModeEntree
                        then
                          begin
                            TECut(SousCriteresRuban[BoiteDeSousCritereActive]);
                            {if (MyZeroScrap = noErr) then if (TEToScrap = noErr) then DoNothing;}
                            sousCritereMustBeAPerfectMatch[BoiteDeSousCritereActive] := false;
                            CriteresRubanModifies := true;
                            EcritRubanListe(true);
                          end
                        else
                      if arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition
                        then
                          begin
                            TECut(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                            {if (MyZeroScrap = noErr) then if (TEToScrap = noErr) then DoNothing;}
                            SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                          end
                        else
                          if BAND(theEvent.modifiers,optionKey) <> 0
                            then CopierPartieEnTEXT(true,false)
                            else
                              begin
                                if enRetour
                                  then SetParamDiag(ParamDiagPartieFFORUM)
                                  else SetParamDiag(ParamDiagPositionFFORUM);
                                CopierEnMacDraw;
                              end;
    CopierCmd      : if not(CopierFromRapport) then
                      begin
                        if FenetreListeEstEnModeEntree
                         then
                          begin
                            TECopy(SousCriteresRuban[BoiteDeSousCritereActive]);
                            {if (MyZeroScrap = noErr) then if (TEToScrap = noErr) then DoNothing;}
                          end
                        else
                      if arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition
                        then
                          begin
                            TECopy(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                            {if (MyZeroScrap = noErr) then if (TEToScrap = noErr) then DoNothing;}
                            SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                          end
                        else
                          begin
                            if enRetour
                              then SetParamDiag(ParamDiagPartieFFORUM)
                              else SetParamDiag(ParamDiagPositionFFORUM);
                            CopierEnMacDraw;
                          end;
                      end;
    CollerCmd     : if not(CollerDansRapport) then
                      begin
                        if FenetreListeEstEnModeEntree
                          then
                            begin
                              TEPaste(SousCriteresRuban[BoiteDeSousCritereActive]);
                              sousCritereMustBeAPerfectMatch[BoiteDeSousCritereActive] := false;
                              CriteresRubanModifies := true;
                              EcritRubanListe(true);
                            end
                          else
                        if arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition
                          then
                            begin
                              TEPaste(GetDialogTextEditHandle(arbreDeJeu.theDialog));
                              SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
                            end
                          else
                            begin
                              if (OuvrirPartieDansFichierPressePapier([kTypeFichierEPS]) <> NoErr) then
                                if not(PeutCollerPartie(positionNormale, s)) then
                                  begin
                                    if (OuvrirPartieDansFichierPressePapier(AllKnownFormats) <> NoErr) then
                                      AlerteErreurCollagePartie;
                                  end;
                            end;
                      end;
    EffacerCmd     : if windowListeOpen
                        and ((OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) or (LongueurSelectionRapport <= 0))
                        and not(FenetreListeEstEnModeEntree)
                        and (nbPartiesActives > 0)
                       then
                         DoSupprimerPartiesDansListe
                       else
                         if not(EffacerDansRapport) then
		                        begin
		                          if FenetreListeEstEnModeEntree then
		                            begin
		                              TEDelete(SousCriteresRuban[BoiteDeSousCritereActive]);
		                              sousCritereMustBeAPerfectMatch[BoiteDeSousCritereActive] := false;
		                              CriteresRubanModifies := true;
		                              EcritRubanListe(true);
		                            end else
		                          if arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition then
		                            begin
		                              TEDelete(GetDialogTextEditHandle(arbreDeJeu.theDialog));
		                              SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
		                            end;
		                        end;
    ToutSelectionnerCmd :  begin
                             if windowListeOpen and (nbPartiesActives > 0)
                                and not(arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition and (OrdreFenetre(wListePtr) > OrdreFenetre(GetArbreDeJeuWindow)))
                                and not(FenetreListeEstEnModeEntree)
                                and not(OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr))
                               then
                                 begin
                                   SelectionnerToutesLesPartiesActivesDansLaListe;
                                   EcritListeParties(false,'ToutSelectionnerCmd');
                                 end
                               else
                                 begin
		                               if not(FenetreListeEstEnModeEntree) and not(arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition) and
		                                  FenetreRapportEstOuverte and not(FenetreRapportEstAuPremierPlan)
		                                  then SelectWindowSousPalette(GetRapportWindow);
		                               if not(SelectionneToutDansRapport) then
			                               begin
			                                 if FenetreListeEstEnModeEntree then
			                                   TESetSelect(0,MAXINT_16BITS,SousCriteresRuban[BoiteDeSousCritereActive]);
			                                 if arbreDeJeu.windowOpen and arbreDeJeu.enModeEdition then
			                                   TESetSelect(0,MAXINT_16BITS,GetDialogTextEditHandle(arbreDeJeu.theDialog));
			                               end;
			                           end;
                           end;
    ParamPressePapierCmd : begin
                             if enRetour
                               then SetParamDiag(ParamDiagPartieFFORUM)
                               else SetParamDiag(ParamDiagPositionFFORUM);
                             ConstruitPositionEtCoupDapresPartie(positionEtCoupStr);

                             ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
	                           chainePosition := ConstruitChainePosition8x8(JeuCourant);

                             s := ReadStringFromRessource(TextesImpressionID,1);
                             if DoDiagrammeFFORUM(s,chainePositionInitiale,chainePosition,chaineCoups) then DoNothing;
                             if enRetour
                               then GetParamDiag(ParamDiagPartieFFORUM)
                               else GetParamDiag(ParamDiagPositionFFORUM);
                           end;
     RaccourcisCmd : DoChangeDessineAide;
  end; {case}
end;


procedure DoCopierSpecialMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}
    case cmdNumber of
      CopierSequenceCoupsEnTEXTCmd       : CopierPartieEnTEXT(true,false);
      CopierDiagrammePartieEnTEXTCmd     : CopierDiagrammePartieEnTEXT;
      CopierPositionCouranteEnTEXTCmd    : CopierDiagrammePositionEnTEXT;
      CopierPositionCouranteEnHTMLCmd    : CopierDiagrammePositionEnHTML;
      CopierPositionPourEndgameScriptCmd : CopierPositionPourEndgameScriptEnTEXT;
      CopierDiagramme10x10Cmd            : DoDiagramme10x10;
    end;
  end;

procedure DoNMeilleursCoupsMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var n : SInt16;
  begin
    {$UNUSED peutRepeter}
    n := cmdNumber+1;
    MySetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd,ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,17),IntToStr(n),'','',''));
    DoMilieuDeJeuNormal(n,true);
  end;


procedure DoPartieMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    case cmdNumber of
     RevenirCmd             : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteDiagramme);
                                DoRevenir;
                              end;
     DebutCmd               : DoDebut(false);
     BackCmd                : if PeutArreterAnalyseRetrograde then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                                  if theEvent.what = autoKey
                                    then DoDoubleBackMove
                                    else DoBackMove;
                                  peutRepeter := (nbreCoup > 0);
                                end;
     ForwardCmd             : if PeutArreterAnalyseRetrograde then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                                  if theEvent.what = autoKey
                                    then DoDoubleAvanceMove
                                    else DoAvanceMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := not(gameOver);
                                end;
     DoubleBackCmd          : if PeutArreterAnalyseRetrograde then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                                  DoDoubleBackMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := (nbreCoup > 0);
                                end;
     DoubleForwardCmd       : if PeutArreterAnalyseRetrograde then
                                begin
                                  AccelereProchainDoSystemTask(2);
                                  gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                                  DoDoubleAvanceMove;
                                  AccelereProchainDoSystemTask(2);
                                  peutRepeter := not(gameOver);
                                end;
     DiagrameCmd            : begin
                                if windowPaletteOpen then FlashCasePalette(PaletteDiagramme);
                                DoRevenir;
                              end;
     TaperUnDiagrammeCmd   : DoChangeEnModeEntreeTranscript;
     MakeMainBranchCmd      : DoMakeMainBranch;
     DeleteMoveCmd          : if CurseurEstEnTeteDeMort
                                then SetNiveauTeteDeMort(0)
                                else SetNiveauTeteDeMort(2);
     SetUpCmd               : DoSetUp;
     ForceCmd               : if PeutArreterAnalyseRetrograde then
                                begin
                                  RemoveDelayAfterKeyboardOperation;
                                  DoForcerMacAJouerMaintenant;
                                  AccelereProchainDoSystemTask(1);
                                end;
    end;
  end;

procedure DoModeMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
     CadenceCmd                    : begin
                                       if windowPaletteOpen then FlashCasePalette(PaletteHorloge);
                                       DoCadence;
                                     end;
     ReflSurTempsAdverseCmd        : DoChangeAvecReflexionTempsAdverse;
     BiblActiveCmd                 : DoChangeAvecBibl;
     VarierOuverturesCmd           : DoChangeVarierOuvertures;
     MilieuDeJeuNormalCmd          : begin
                                       MySetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd,ReadStringFromRessource(MenusChangeantsID,18));
                                       DoMilieuDeJeuNormal(1,true);
                                     end;
     MilieuDeJeuNMeilleursCoupsCmd : DoMilieuDeJeuNormal(nbCoupsEnTete,true);
     MilieuDeJeuAnalyseCmd         : DoMilieuDeJeuAnalyse(true);
     FinaleGagnanteCmd             : DoFinaleGagnante(true);
     FinaleOptimaleCmd             : DoFinaleOptimale(true);
     CoeffEvalCmd                  : DoCoefficientsEvaluation;
     ParametrerAnalyseRetrogradeCmd: DoParametrerAnalyseRetrograde;
     AnalyseRetrogradeCmd          : DoDemandeAnalyseRetrograde(analyseRetrograde.nbPresentationsDialogue >= 1);
    end;
  end;

procedure DoJoueursMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
      HumCreHumCmd                 :   DoDemandeChangerHumCtreHum;
      MacBlancsCmd                 :   DoDemandeCassioPrendLesBlancs;
      MacNoirsCmd                  :   DoDemandeCassioPrendLesNoirs;
      MacAnalyseLesDeuxCouleursCmd :   DoDemandeCassioAnalyseLesDeuxCouleurs;
      MinuteBlancCmd               :   DoAjouteTemps(pionBlanc);
      MinuteNoirCmd                :   DoAjouteTemps(pionNoir);
    end;
  end;

procedure DoAffichageMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
     ChangerEn3DCmd         : DoChangeEn3D(true);
     Symetrie_A1_H8Cmd      : if PeutArreterAnalyseRetrograde then
                                DoSymetrie(axeSW_NE);
     Symetrie_A8_H1Cmd      : if PeutArreterAnalyseRetrograde then
                                DoSymetrie(axeSE_NW);
     DemiTourCmd            : if PeutArreterAnalyseRetrograde then
                                DoSymetrie(central);

     ConfigurerAffichageCmd : DoDialoguePreferencesAffichage;
     ReflexionsCmd          : begin
                                {if windowPaletteOpen then FlashCasePalette(PaletteReflexion);}
                                DoChangeAfficheReflexion;
                              end;
     RapportCmd             : DoRapport;
     CourbeCmd              : begin
                                {if windowPaletteOpen then FlashCasePalette(PaletteCourbe);}
                                DoCourbe;
                              end;
     CyclerDansFenetresCmd  : CyclerDansLEmpilementDesFenetres;
     GestionTempsCmd        : DoChangeAfficheGestionTemps;
     CommentairesCmd        : DoCommentaires;
     PaletteFlottanteCmd    : DoChangePalette;
     SonCmd                 : DoSon;
    end;
  end;

procedure DoSolitairesMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
      JouerNouveauSolitaireCmd           : {ProcessEachSolitaireOnDisc(0,10000000);}
                                           if PeutArreterAnalyseRetrograde then DoDemandeJouerSolitaires;
      ConfigurationSolitaireCmd          : DoDialogueConfigurationSolitaires;
      EcrireSolutionSolitaireCmd         : DoEcritureSolutionSolitaire;
      EstSolitaireCmd                    : DoEstUnSolitaire;
      ChercherNouveauProblemeDeCoinCmd   : if PeutArreterAnalyseRetrograde then ChercherUnProblemeDePriseDeCoinAleatoire(20,40);
      ChercherProblemeDeCoinDansListeCmd : if PeutArreterAnalyseRetrograde then ChercherUnProblemeDePriseDeCoinDansListe(20,40);
      EstProblemeDeCoinCmd               : ChercherUnProblemeDePriseDeCoinDansPositionCourante;
    end;
  end;

procedure DoBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
     ChargerDesPartiesCmd          : begin
                                       if windowPaletteOpen then FlashCasePalette(PaletteBase);
                                       DoChargerLaBase;
                                     end;
     EnregistrerPartiesBaseCmd     : ; { Desormais géré par un sous-menu}
     AjouterPartieDansListeCmd     : DialogueSaisieNomsJoueursPartie(nbreCoup);
     ChangerOrdreCmd               : DoChangerOrdreListe;
     OuvrirSelectionneeCmd         : OuvrePartieSelectionnee(infosListeParties.partieHilitee);
     JouerSelectionneCmd           : if windowListeOpen and (nbPartiesActives > 0) then
                                      if PeutArreterAnalyseRetrograde then
                                        begin
                                          AccelereProchainDoSystemTask(2);
                                          gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
	                                        if BAND(theEvent.modifiers,shiftKey) = 0
	                                          then if theEvent.what = autoKey
	                                                 then DoDoubleAvanceMovePartieSelectionnee(infosListeParties.partieHilitee)
	                                                 else JoueCoupPartieSelectionnee(infosListeParties.partieHilitee)
	                                          else if theEvent.what = autoKey
	                                                 then DoDoubleBackMovePartieSelectionnee(infosListeParties.partieHilitee)
	                                                 else DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
	                                      end;
     JouerMajoritaireCmd           : begin
                                       AccelereProchainDoSystemTask(2);
                                       gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                                       JoueCoupMajoritaireStat;
                                     end;
     StatistiqueCmd                : begin
                                       {if windowPaletteOpen then FlashCasePalette(PaletteStatistique);}
                                       DoStatistiques;
                                     end;
     ListePartiesCmd               : begin
                                       {if windowPaletteOpen then FlashCasePalette(PaletteListe);}
                                       DoListeDeParties;
                                     end;
     NuageDeRegressionCmd          : DoChangeAfficheNuage;
     SousSelectionActiveCmd        : DoChangeSousSelectionActive;
     {CriteresCmd                   : DoCriteres;}
     AjouterGroupeCmd              : DoAjouterGroupe;
     ListerGroupesCmd              : DoListerLesGroupes;
     InterversionCmd               : DoChangeInterversions;
     (* AlerteInterversionCmd      : DoChangeAlerteInterversion; *)
    end;
  end;


procedure DoProgrammationMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  var current : PositionEtTraitRec;
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
     AjusterModeleLineaireCmd  : {afficher_zebra_book;}
                                 {ImportBaseAllDrawLinesDeBougeard;}
                                 {EpoquesDesJoueursDeLaListe;}
                                 {AjusteModeleLineaireFinale;}
                                 AfficherLesJoueursWthorSansNumeroFFO;

     ChercherSolitairesListeCmd  : LancerInterruptionPourRechercherSolitairesDansListe;

                                 {TestNouvelleEval;}
                                 {ApprendToutesLesPartiesActives;}
                                 {ApprendCoeffsLignesPartiesDeLaListe;}
                                 {ApprendCoeffsPartiesDeLaListeAlaBill;}
                                 {ApprendBlocsDeCoinPartiesDeLaListe;}

                                 {
                                 if BAND(theEvent.modifiers,optionKey) <> 0
                                   then
                                     begin
                                       profMinimalePourTriDesCoupsParAlphaBeta := profMinimalePourTriDesCoupsParAlphaBeta-1;
                                       WriteDansRapport('profMinimalePourTriDesCoupsParAlphaBeta = ');
                                       WritelnDansRapport(IntToStr(profMinimalePourTriDesCoupsParAlphaBeta));
                                     end
                                   else
                                     begin
                                       profMinimalePourTriDesCoupsParAlphaBeta := profMinimalePourTriDesCoupsParAlphaBeta+1;
                                       WriteDansRapport('profMinimalePourTriDesCoupsParAlphaBeta = ');
                                       WritelnDansRapport(IntToStr(profMinimalePourTriDesCoupsParAlphaBeta));
                                     end;
                                  }

     VariablesSpecialesCmd           : DoDialoguePreferencesSpeciales;
     OuvrirBiblCmd                   : DoOuvrirBibliotheque;
     effetspecial1Cmd                : DoChangeEffetSpecial1;
     effetspecial2Cmd                : DoChangeEffetSpecial2;
     NettoyerGrapheCmd               : NettoyerGrapheApprentissage(nomGrapheInterversions);
                                       {CompterLesPartiesDansGrapheApprentissage(40,nbreParties);}
     BenchmarkDeMilieuCmd            : StressTestMilieuPourLeZoo;
     AffCelluleApprentissaCmd        : VoirLesInfosDApprentissageDansRapport;
     DemoCmd                         : DoChoisitDemo;
     EcrireDansRapportLogCmd         : DoChangeEcrireDansRapportLog;
     UtiliserMetaphoneCmd            : DoChangeUtiliserMetaphone;
     TraitementDeTexteCmd            : DoChangeEnTraitementDeTexte;
     ArrondirEvaluationsCmd          : DoChangeArrondirEvaluations;
     UtiliserScoresArbreCmd          : DoChangeFaireConfianceScoresArbre;
     GestionBaseWThorCmd             : ;
     Unused2Cmd                      : begin
                                         current := PositionEtTraitCourant;
                                         TestMobiliteBitbooard(current);
                                         {if DernierEvenement.option
                                           then EcritListeJoueursBlancsNonJaponaisPourTraduction
                                           else EcritListeJoueursNoirsNonJaponaisPourTraduction;}
                                       end;
     Unused3Cmd                      : EcritListeTournoisPourTraductionJaponais;
     Unused4Cmd                      : ;
     PrecompilerLesSourcesCmd        : VerifierLesSourcesDeCassio;
    end;
  end;


procedure DoCouleurMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean);
var gBlackAndWhiteArrivee : boolean;
    visibleRgn : RgnHandle;
begin
  {$UNUSED peutRepeter}

  if (menuID = Picture2DID) then
    begin
      DoPicture2DMenuCommands(menuID,cmdNumber,peutRepeter,false);
      exit;
    end;

  if (menuID = CouleurID) then
    begin

		  gBlackAndWhiteArrivee := gBlackAndWhite;
		  gCouleurOthellier := CalculeCouleurRecord(CouleurID,cmdNumber);


		  gEcranCouleur                := true;
		  gBlackAndWhite               := not(gEcranCouleur);

		  SetEnVieille3D(false);
		  KillPovOffScreenWorld;
		  if windowPaletteOpen and BooleanXor(gBlackAndWhite,gBlackAndWhiteArrivee) then DessinePalette;
		  SetPositionsTextesWindowPlateau;

		  visibleRgn := NewRgn;
		  EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);
		  DisposeRgn(visibleRgn);

		  {sauvegarde de la derniere texture 2D utilisee}
		  gLastTexture2D.theMenu  := CouleurID;
		  gLastTexture2D.theCmd := cmdNumber;
		end;
end;


procedure DoPicture2DMenuCommands(menuID,cmdNumber : SInt16; var peutRepeter : boolean; avecAlerte : boolean);
var fic : basicfile;
    gBlackAndWhiteArrivee : boolean;
    s : String255;
    visibleRgn : RgnHandle;
begin

  if (menuID = CouleurID) then
    begin
      DoCouleurMenuCommands(menuID,cmdNumber,peutRepeter);
      exit;
    end;

  if (menuID = Picture2DID) then
    begin
		  gBlackAndWhiteArrivee := gBlackAndWhite;
		  gCouleurOthellier := CalculeCouleurRecord(Picture2DID,cmdNumber);

		  if not(FichierPhotosExisteSurLeDisque(GetPathCompletFichierPionsPourCetteTexture(gCouleurOthellier),fic))
		    then
		      begin
		        s := GetNomDansMenuPourCetteTexture(gCouleurOthellier);
		        gCouleurOthellier := CalculeCouleurRecord(CouleurID,VertPaleCmd);
		        if avecAlerte then AlerteFichierPhotosNonTrouve(s);
		        DoCouleurMenuCommands(CouleurID,VertPaleCmd,peutRepeter);
		      end
		    else
		      begin
		        if not(gPendantLesInitialisationsDeCassio) then
		          begin

		            watch := GetCursor(watchcursor);
		            SafeSetCursor(watch);
		          end;

		        SetEnVieille3D(false);
		        KillPovOffScreenWorld;
		        SetPositionsTextesWindowPlateau;

		        visibleRgn := NewRgn;
		        EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);
		        DisposeRgn(visibleRgn);

		        {sauvegarde de la derniere texture 2D utilisee}
		        gLastTexture2D.theMenu  := Picture2DID;
		        gLastTexture2D.theCmd := cmdNumber;
		      end;
		  RemettreLeCurseurNormalDeCassio;
		end;
end;

procedure DoPicture3DMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean; avecAlerte : boolean);
const AlertePbMemoire3DID = 258;
var fic : basicfile;
    error : OSErr;
    nomDansMenu,path,s : String255;
    visibleRgn : RgnHandle;
begin

  gCouleurOthellier := CalculeCouleurRecord(Picture3DID,cmdNumber);

  nomDansMenu := GetNomDansMenuPourCetteTexture(gCouleurOthellier);
  path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionNoir);

  if not(FichierPhotosExisteSurLeDisque(path,fic))
    then
      begin
        s := GetNomDansMenuPourCetteTexture(gCouleurOthellier);

        gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
        if avecAlerte then AlerteFichierPhotosNonTrouve(s);
        DoPicture2DMenuCommands(gLastTexture2D.theMenu,gLastTexture2D.theCmd,peutRepeter,false);
      end
    else
      begin
        if not(gPendantLesInitialisationsDeCassio) then
          begin

            watch := GetCursor(watchcursor);
            SafeSetCursor(watch);
          end;

        error := LitFichierCoordoneesImages3D(gCouleurOthellier);

        if error <> NoErr then
          begin
            WritelnNumDansRapport(' error <> NoErr (1) dans DoPicture3DMenuCommands, error =',error);
            KillPovOffScreenWorld;
            RepasserEn2D(false);
            exit;
          end;

        error := CreatePovOffScreenWorld(gCouleurOthellier);

        if error <> NoErr then
          begin
            if avecAlerte and ((error = opWrErr) or (error = memFullErr) or (error = cTempMemErr) or (error = cNoMemErr))
              then AlertOneButtonFromRessource(AlertePbMemoire3DID,2,0,1)
              else WritelnNumDansRapport(' error <> NoErr (2) dans DoPicture3DMenuCommands, error =',error);
            KillPovOffScreenWorld;
            RepasserEn2D(false);
            exit;
          end;

        SetEnVieille3D(false);
        SetCalculs3DMocheSontFaits(false);
        AjusteTailleFenetrePlateauPourLa3D;
        SetPositionsTextesWindowPlateau;

        visibleRgn := NewRgn;
        EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),true);
        DisposeRgn(visibleRgn);

        {sauvegarde de la derniere texture 3D utilisee}
        gLastTexture3D.theMenu  := Picture3DID;
        gLastTexture3D.theCmd   := cmdNumber;
      end;
  RemettreLeCurseurNormalDeCassio;
end;

procedure DoTriMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
      TriParDatabaseCmd    : DoTrierListe(TriParDistribution,kRadixSort);
      TriParDateCmd        : DoTrierListe(TriParDate,kRadixSort);
      TriParJoueurNoirCmd  : DoTrierListe(TriParJoueurNoir,kRadixSort);
      TriParJoueurBlancCmd : DoTrierListe(TriParJoueurBlanc,kRadixSort);
      TriParOuvertureCmd   : DoTrierListe(TriParOuverture,kQuickSort);
      TriParTheoriqueCmd   : DoTrierListe(TriParScoreTheorique,kRadixSort);
      TriParReelCmd        : DoTrierListe(TriParScoreReel,kRadixSort);
      TriParClassementCmd  : DoTrierListe(TriParClassementDuRapport,kQuickSort);
    end;
  end;

procedure DoFormatBaseMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
  begin
    {$UNUSED peutRepeter}

    case cmdNumber of
      FormatWTBCmd   : if (SauvegardeListeCouranteAuNouveauFormat(FiltrePartieEstActiveEtSelectionnee) <> NoErr)
                         then AlerteSimple('L''enregistrement a échoué, désolé');
      FormatPARCmd   : if SauvegardeListeCouranteEnTHOR_PAR <> NoErr
                         then AlerteSimple('L''enregistrement a échoué, désolé');
      FormatTexteCmd : DoExporterListeDePartiesEnTexte;
      FormatHTMLCmd  : ExportListeAuFormatHTML;
      FormatPGNCmd   : ExportListeAuFormatPGN;
      FormatXOFCmd   : ExportListeAuFormatXOF;
    end;
  end;

procedure DoReouvrirMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
var nomComplet : String255;
    ficPartie : basicfile;
    erreurES : SInt16;




    procedure EcritMenuReouvrirDansRapport(prompt : String255);
    var compteur,k : SInt32;
    begin

      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport(prompt);
      TextNormalDansRapport;
      compteur := 0;
      for k := 1 to NbMaxItemsReouvrirMenu do
        begin
          if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
            begin
              inc(compteur);
              WriteNumDansRapport('k = ',k);
              WritelnNumDansRapport(' , et compteur = ',compteur);
              WritelnDansRapport('nomDuFichierAReouvrir = ' + nomDuFichierAReouvrir[k]^^);
            end;
        end;
    end;


  begin  {DoReouvrirMenuCommands}
    {$UNUSED peutRepeter}

    nomComplet := GetNomCompletFichierDansMenuReouvrir(cmdNumber);

    if (nomComplet <> '') then
      begin
        erreurES := FileExists(nomComplet,0,ficPartie);
		    if (erreurES <> NoErr) then
		      begin
            AlerteSimpleFichierTexte(nomComplet,erreurES);
            SetReouvrirItem('',NumeroItemMenuReouvrirToIndexTablesFichiersAReouvrir(cmdNumber));
            {EcritMenuReouvrirDansRapport('avant CleanReouvrirMenu : ');}
            CleanReouvrirMenu;
            {EcritMenuReouvrirDansRapport('apres CleanReouvrirMenu : ');}
            exit;
          end;
        AjoutePartieDansMenuReouvrir(nomComplet);
        erreurES := OuvrirFichierParNomComplet(nomComplet, AllKnownFormats, true);
      end;

    {EcritMenuReouvrirDansRapport('Fin normale : ');}
  end;

procedure DoGestionBaseWThorMenuCommands(cmdNumber : SInt16; var peutRepeter : boolean);
begin
  {$UNUSED peutRepeter}
  case cmdNumber of
     ChangerTournoiCmd                : CreerOuRenommerMachinDansLaBaseOfficielle;
     ChangerJoueurNoirCmd             : CreerOuRenommerMachinDansLaBaseOfficielle;
     ChangerJoueurBlancCmd            : CreerOuRenommerMachinDansLaBaseOfficielle;
     SelectionnerTheoriqueEgalReelCmd : SelectionnerPartiesOuScoreTheoriqueEgalScoreReel;
     CalculerScoreTheoriqueCmd        : LancerInterruptionPourCalculerScoresTheoriquesPartiesDansListe;
     CreerTournoiCmd                  : if (NombreDeLignesDansSelectionRapport >= 2)
                                          then CreerPlusieursTournoisDansBaseOfficielle
                                          else CreerOuRenommerMachinDansLaBaseOfficielle;
     CreerJoueurCmd                   : if (NombreDeLignesDansSelectionRapport >= 2)
                                          then CreerPlusieursJoueursDansBaseOfficielle
                                          else CreerOuRenommerMachinDansLaBaseOfficielle;
  end;
end;

procedure DoMenuCommand(command : SInt32; var peutRepeter : boolean);
  var whichMenu : SInt16;
      whichItem : SInt16;
      err : OSErr;
  begin
    whichMenu := HiWord(command);
    whichItem := LoWord(command);


    if (whichMenu = 0) then exit;
    { no real menu command, so we don't want to confirm inline input text }


    if (whichMenu <> EditionID) or (whichItem < Coupercmd) or (whichItem > toutSelectionnercmd) then
      AnnulerSousCriteresRuban;

    if FenetreRapportEstAuPremierPlan and
       (GetTSMDocOfRapport <> NIL)
			then err := FixTSMDocument(GetTSMDocOfRapport);

	  (*
		 case whichMenu of
      appleID            : WritelnNumDansRapport('appleID , whichItem = ',whichItem);
      FileID             : WritelnNumDansRapport('FileID , whichItem = ',whichItem);
      EditionID          : WritelnNumDansRapport('EditionID , whichItem = ',whichItem);
      PartieID           : WritelnNumDansRapport('PartieID , whichItem = ',whichItem);
      ModeID             : WritelnNumDansRapport('ModeID , whichItem = ',whichItem);
      JoueursID          : WritelnNumDansRapport('JoueursID , whichItem = ',whichItem);
      AffichageID        : WritelnNumDansRapport('AffichageID , whichItem = ',whichItem);
      CouleurID          : WritelnNumDansRapport('CouleurID , whichItem = ',whichItem);
      Picture2DID        : WritelnNumDansRapport('Picture2DID , whichItem = ',whichItem);
      Picture3DID        : WritelnNumDansRapport('Picture3DID , whichItem = ',whichItem);
      SolitairesID       : WritelnNumDansRapport('SolitairesID , whichItem = ',whichItem);
      BaseID             : WritelnNumDansRapport('BaseID , whichItem = ',whichItem);
      TriID              : WritelnNumDansRapport('TriID , whichItem = ',whichItem);
      FormatBaseID       : WritelnNumDansRapport('FormatBaseID , whichItem = ',whichItem);
      CopierSpecialID    : WritelnNumDansRapport('CopierSpecialID , whichItem = ',whichItem);
      NMeilleursCoupID   : WritelnNumDansRapport('NMeilleursCoupID , whichItem = ',whichItem);
      ReouvrirID         : WritelnNumDansRapport('ReouvrirID , whichItem = ',whichItem);
      GestionBaseWThorID : WritelnNumDansRapport('GestionBaseWThorID , whichItem = ',whichItem);
      ProgrammationID    : WritelnNumDansRapport('ProgrammationID , whichItem = ',whichItem);
    end;
  *)

    peutRepeter := false;
    case whichMenu of
      appleID            : DoPommeMenuCommands(whichItem,peutRepeter);
      FileID             : DoFileMenuCommands(whichItem,peutRepeter);
      EditionID          : DoEditionMenuCommands(whichItem,peutRepeter);
      PartieID           : DoPartieMenuCommands(whichItem,peutRepeter);
      ModeID             : DoModeMenuCommands(whichItem,peutRepeter);
      JoueursID          : DoJoueursMenuCommands(whichItem,peutRepeter);
      AffichageID        : DoAffichageMenuCommands(whichItem,peutRepeter);
      CouleurID          : begin
                             if whichItem = AutreCouleurCmd then
                               begin
                                 if ChoisirCouleurOthellierAvecPicker(gCouleurSupplementaire)
                                   then InvalidateAllOffScreenPICTs
                                   else exit;
                               end;
                             RestaurerDerniereDimensionFenetre2D;
                             DoCouleurMenuCommands(CouleurID,whichItem,peutRepeter);
                           end;
      Picture2DID        : begin
                             RestaurerDerniereDimensionFenetre2D;
                             DoPicture2DMenuCommands(Picture2DID,whichItem,peutRepeter,true);
                           end;
      Picture3DID        : begin
                             SauvegarderDerniereDimensionFenetre2D;
                             DoPicture3DMenuCommands(whichItem,peutRepeter,true);
                           end;
      SolitairesID       : DoSolitairesMenuCommands(whichItem,peutRepeter);
      BaseID             : DoBaseMenuCommands(whichItem,peutRepeter);
      TriID              : DoTriMenuCommands(whichItem,peutRepeter);
      FormatBaseID       : DoFormatBaseMenuCommands(whichItem,peutRepeter);
      CopierSpecialID    : DoCopierSpecialMenuCommands(whichItem,peutRepeter);
      NMeilleursCoupID   : DoNMeilleursCoupsMenuCommands(whichItem,peutRepeter);
      ReouvrirID         : DoReouvrirMenuCommands(whichItem,peutRepeter);
      GestionBaseWThorID : DoGestionBaseWThorMenuCommands(whichItem,peutRepeter);
      ProgrammationID    : DoProgrammationMenuCommands(whichItem,peutRepeter);
    end;
    EndHiliteMenu(theEvent.when,10,peutRepeter);
    EssaieUpdateEventsWindowPlateau;
  end;




procedure DoKeyPress(ch : char; var peutRepeter : boolean);
const MachineAEcrireID = 10129;
var shift,command,option,control : boolean;
    longueur,i : SInt16;
    ancPosPouce : SInt32;
    numeroFilsCherche,square : SInt32;
    temposon : boolean;
    s : String255;
    caract : charsHandle;
   {tempoSon : boolean;
    FilsConnus:listeDeCoups;}
    current : PositionEtTraitRec;
    oldNbreCoups : SInt32;
    plat : plateauOthello;
begin
  shift := BAND(theEvent.modifiers,shiftKey) <> 0;
  command := BAND(theEvent.modifiers,cmdKey) <> 0;
  option := BAND(theEvent.modifiers,optionKey) <> 0;
  control := BAND(theEvent.modifiers,controlKey) <> 0;

  {if ch = '∆' then Debugger;}

  {WriteNumAt('code du caractere :',ord(ch),100,100);}


  {WritelnStringAndBoolDansRapport('EnModeEntreeTranscript = ',EnModeEntreeTranscript);}

  if EnTraitementDeTexte and FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan
    then
      begin
        if (ord(ch) = EscapeKey)
          then DoChangeEnTraitementDeTexte
          else
            begin
              FrappeClavierDansRapport(ch);
              UpdateScrollersRapport;
              PlaySoundSynchrone(MachineAEcrireID, 128);
              if (ch = cr) then
                begin
                  s := GetAvantDerniereLigneCouranteDuRapport;
                  if DoActionGestionBaseOfficielle(s) = NoErr then DoNothing;
                end;
            end
      end
    else
      if FenetreListeEstEnModeEntree
        then
          begin
            if (ord(ch) = ReturnKey) then
              begin
                ValiderSousCritereRuban;
                if AutorisationDeChargerLaBaseSansInterventionUtilisateur then DoChargerLaBaseSansInterventionUtilisateur;
                exit;
              end;
            if (ord(ch) = TabulationKey) or (ord(ch) = EntreeKey) then
              begin
                { Deplacement dans les champs de criteres actifs :
                    tabulation    => on circule en sens positif
                    majuscule-tab => on circule en sens negatif.
                  Le logique est compliquee par le fait que certains
                  champs peuvent etre caches si la fenetre est reduite }
                if shift
                  then
		                case nbColonnesFenetreListe of
		                  kAvecAffichageDistribution :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := DistributionRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := TournoiRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  kAvecAffichageTournois :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := TournoiRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  otherwise
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                end {case}
		              else
		                case nbColonnesFenetreListe of
		                  kAvecAffichageDistribution :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := DistributionRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := TournoiRubanBox;
		                    end;
		                  kAvecAffichageTournois :
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := TournoiRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                  otherwise
		                    case BoiteDeSousCritereActive of
		                      TournoiRubanBox      : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurNoirRubanBox   : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                      JoueurBlancRubanBox  : BoiteDeSousCritereActive := JoueurNoirRubanBox;
		                      DistributionRubanBox : BoiteDeSousCritereActive := JoueurBlancRubanBox;
		                    end;
		                end; {case}

                  if BoiteDeSousCritereActive <= 0 then BoiteDeSousCritereActive := DistributionRubanBox;
                  PasseListeEnModeEntree(BoiteDeSousCritereActive);
                  exit;
              end;
            if (ord(ch) = EscapeKey)
              then AnnulerSousCriteresRuban
              else
                begin
                  TEKey(ch,SousCriteresRuban[BoiteDeSousCritereActive]);
                  CriteresRubanModifies := true;
                  sousCritereMustBeAPerfectMatch[BoiteDeSousCritereActive] := false;

                  longueur := TEGetTextLength(SousCriteresRuban[BoiteDeSousCritereActive]);
                  if longueur > 245 then longueur := 245;
                  caract := TEGetText(SousCriteresRuban[BoiteDeSousCritereActive]);

                  s := '';
                  for i := 1 to longueur do s := s + caract^^[i-1];
                  if s[longueur] = '=' then
                    begin
                      if not(JoueursEtTournoisEnMemoire) and
                         avecGestionBase and not(problemeMemoireBase) then
                        DoLectureJoueursEtTournoi(false);
                      s := TPCopy(s,1,longueur-1);
                      case BoiteDeSousCritereActive of
                        JoueurNoirRubanBox   : s := Complemente(complementationJoueurNoir, false,s,i,sousCritereMustBeAPerfectMatch[JoueurNoirRubanBox]);
                        JoueurBlancRubanBox  : s := Complemente(complementationJoueurBlanc,false,s,i,sousCritereMustBeAPerfectMatch[JoueurBlancRubanBox]);
                        TournoiRubanBox      : s := Complemente(complementationTournoi,    false,s,i,sousCritereMustBeAPerfectMatch[TournoiRubanBox]);
                        DistributionRubanBox : s := s;
                      end;
                      TESetText(@s[1],LENGTH_OF_STRING(s),SousCriteresRuban[BoiteDeSousCritereActive]);
                      TESetSelect(i,MAXINT_16BITS,SousCriteresRuban[BoiteDeSousCritereActive]);
                      SetPortByWindow(wListePtr);
                      InvalRect(TEGetViewRect(SousCriteresRuban[BoiteDeSousCritereActive]));
                    end;

                  EcritRubanListe(true);

                end;
          end
        else
          begin
            if EnModeEntreeTranscript then
              begin
                if TraiteKeyboardEventDansTranscript(ch,peutRepeter)
                  then exit;
              end;

		        if enRetour
		          then
		            begin
		              if (ord(ch) = ReturnKey) or (ord(ch) = EntreeKey) or (ord(ch) = RetourArriereKey) or (ord(ch) = EscapeKey)
		                then humainVeutAnnuler := true;
		            end
		          else
		            begin
		              if (ord(ch) = ReturnKey) then {return}
		                begin
		                  if FenetreRapportEstOuverte and
		                     SelectionRapportNonVide and
		                     FenetreRapportEstAuPremierPlan
		                    then
		                      begin
		                        if PeutCompleterPartieAvecSelectionRapport(s) and PeutArreterAnalyseRetrograde then
		                          begin
		                            PlaquerPartieLegale(s,kNePasRejouerLesCoupsEnDirect);
		                            if not(HumCtreHum) and not(CassioEstEnModeAnalyse) then DoChangeHumCtreHum;
		                          end;
		                      end
		                    else
		                      begin
		                        if AutorisationDeChargerLaBaseSansInterventionUtilisateur
		                          then
		                            begin
		                              DoChargerLaBaseSansInterventionUtilisateur;
		                            end
		                          else
    		                        if windowListeOpen and (nbPartiesActives >= 1) and PeutArreterAnalyseRetrograde then
    		                          begin
    		                            oldNbreCoups := nbreCoup;
    		                            OuvrePartieSelectionnee(infosListeParties.partieHilitee);
    		                            if control and option then
    	                                 begin
    	                                   CalculsEtAffichagePourBase(false,true);
    	                                   DialogueSaisieNomsJoueursPartie(oldNbreCoups);
    	                                 end;
    		                          end;
		                      end;
		                end;

		              if (ord(ch) = EntreeKey) then  {entree}
		                if windowListeOpen and (nbPartiesChargees > 0) then
		                  begin
		                    if wListePtr <> FrontWindowSaufPalette then DoListeDeParties;
		                    if not(sousSelectionActive) then DoChangeSousSelectionActive;
		                    case nbColonnesFenetreListe of
				                  kAvecAffichageDistribution        : BoiteDeSousCritereActive := DistributionRubanBox;
				                  kAvecAffichageTournois            : BoiteDeSousCritereActive := TournoiRubanBox;
				                  kAvecAffichageSeulementDesJoueurs : BoiteDeSousCritereActive := JoueurNoirRubanBox;
				                end; {case}
		                    PasseListeEnModeEntree(BoiteDeSousCritereActive);
		                    CriteresRubanModifies := false;
		                    exit;
		                  end;

		              if (ord(ch) = TabulationKey) and windowListeOpen then
		                if not(shift)
		                  then
			                  case nbColonnesFenetreListe of
					                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
					                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
					                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
					              end {case}
					            else
					              begin
  					             (* case nbColonnesFenetreListe of
  					                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageTournois);
  					                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
  					                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageDistribution);
  					              end; {case} *)
  					              listeEtroiteEtNomsCourts := not(listeEtroiteEtNomsCourts);
  					              DoChangeEcritTournoi(nbColonnesFenetreListe);
  					            end;
		            end;

		        if not(enSetUp) then
		          begin
		            EnregisterToucheClavier(ch,theEvent.when);
		            if not(EstEnAttenteSelectionRapideDeListe) then
			            begin
			              case ch of

				              '$': begin
				                     plat := JeuCourant;
				                     EcritNewEvalIntegerDansRapport(plat,emplJouable,frontiereCourante,nbreDePions[pionNoir],nbreDePions[pionBlanc],AQuiDeJouer,vecteurEvaluationInteger);
				                   end;


				              '*': begin
				                     current := PositionEtTraitCourant;
				                     WritelnZebraValuesDansRapport(current);
				                   end;

				              '©','¢': if not(enModeIOS) and not(CassioEstEnModeAnalyse) and  {option-c}
				                         PeutArreterAnalyseRetrograde
				                        then DoDemandeChangeCouleur;

				              'π','∏': DoProgrammation;                                     {option-P}

				              'Æ'    : TestRegressionLineaire;                              {option-maj-A}

				              'Ω'    : DemarrerLeTestDuZooAvecLaSouris;                     {option-maj-Q}

				              '‡'    : HistogrammeDesMoyennesParScoreTheoriqueDansRapport;  {option-Q}

				              '®','€','Â','Å':  {option-r, option-z}
				                         begin
				                           if windowPaletteOpen then FlashCasePalette(PaletteRetourDebut);
				                           if PeutArreterAnalyseRetrograde then
				                             begin
				                               DoRetourDerniereMarque;
				                               peutRepeter := (nbreCoup > 0);
				                             end;
				                         end;

				              'ê','Ê':    {option-e}
				                         begin
				                           if windowPaletteOpen then FlashCasePalette(PaletteAllerFin);
				                           if PeutArreterAnalyseRetrograde then
				                             begin
				                               DoAvanceProchaineMarque;
				                               peutRepeter := not(gameOver);
				                             end;
				                         end;

				              ' ',' ': if not(enModeIOS) then
				                         begin
				                           AccelereProchainDoSystemTask(2);
				                           gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
				                           JoueCoupMajoritaireStat;
				                           peutRepeter := not(gameOver);
				                         end;

				              'e','E': if not(enModeIOS) and PeutArreterAnalyseRetrograde then
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
				                             if (theEvent.what = autoKey) or shift
				                               then DoDoubleAvanceMove
				                               else DoAvanceMove;
				                             peutRepeter := not(gameOver);
				                           end;

				              'r','R','z','Z': if not(enModeIOS) and PeutArreterAnalyseRetrograde then
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
				                             if (theEvent.what = autoKey) or shift
				                               then DoDoubleBackMove
				                               else DoBackMove;
				                             peutRepeter := (nbreCoup > 0);
				                           end;
				               't','T' : if not(enModeIOS) and PeutArreterAnalyseRetrograde then
				                           begin
				                             {RemoveDelayAfterKeyboardOperation;}
                                     DoJouerMeilleurCoupConnuMaintenant;
                                     AccelereProchainDoSystemTask(1);
                                     peutRepeter := false;
				                           end;

				              'p','P': if not(enModeIOS) and PeutArreterAnalyseRetrograde then
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
				                             DoDoubleAvanceMove;
				                             if shift then DoDoubleAvanceMove;
				                             peutRepeter := not(gameOver);
				                           end;

				              'o','O':if not(enModeIOS) and PeutArreterAnalyseRetrograde then
				                           begin
				                             AccelereProchainDoSystemTask(2);
				                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
				                             DoDoubleBackMove;
				                             if shift then DoDoubleBackMove;
				                             peutRepeter := (nbreCoup > 0);
				                           end;

				              'l','L':begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteListe);}
				                        DoListeDeParties;
				                      end;
				
				              '¬','|':begin  {option-l, option-L}
				                        SetAutorisationChargerLaBaseSansPasserParLeDialogue(false);
				                        DoListeDeParties;
				                        SetAutorisationChargerLaBaseSansPasserParLeDialogue(true);
				                      end;

				              'n','N': DoChangeAfficheNuage;

				              's','S': begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteStatistique);}
				                        DoStatistiques;
				                      end;

				              'k','K': begin
				                        {if windowPaletteOpen then FlashCasePalette(PaletteCourbe);}
				                        DoCourbe;
				                      end;

				              '"','3': if not(enRetour or enSetUp) then DoChangeEn3D(true);

				              '''','4',
				              '‘','’': DoChangeAfficheZebraBookBrutDeDecoffrage;
				                       {ChercherLeProchainNoeudAvecBeaucoupDeFils(4);}

				              'È','Ë': ChercherUnProblemeDePriseDeCoinDansPositionCourante;  {option-k}

				              '≈','⁄': if not(gameOver) then                       {option-x}
				                           DoDemandeChangerHumCtreHumEtCouleur;

				              'ƒ','·': if not(gameOver) then                       {option-f}
				                           begin
				                             DoFinaleOptimale(true);
				                             DoDemandeChangerHumCtreHumEtCouleur;
				                           end;

				              'ﬁ','ﬂ': if not(gameOver) then                       {option-g}
				                           begin
				                             DoFinaleGagnante(true);
				                             DoDemandeChangerHumCtreHumEtCouleur;
				                           end;

				              '◊','√': if not(gameOver) then                       {option-v}
				                           begin
				                             DoMilieuDeJeu(true);
				                             DoDemandeChangerHumCtreHumEtCouleur;
				                           end;

				              '•','Ÿ': begin                                       {option-@}
				                         CopierPucesNumerotees;
				                         peutRepeter := true;
				                       end;

				               '='   : DoChangePalette;

				               '+'   : if not(command) then DoChangePalette;

				               '{','[': AfficheProchainProblemeStepanov;   {option-5}


				               '≤','≥': DoDemandeAnalyseRetrograde(analyseRetrograde.nbPresentationsDialogue >= 1); {option-<}

				               (*
				               'h','H','Ì','Î':                     {h, option h}
				                      begin
				                        if IsMenuItemEnabled(JoueursMenu,HumCreHumCmd) then
				                          DoDemandeChangerHumCtreHum;
				                      end;
				                *)

				               otherwise {sinon, on cherche a avancer dans l'arbre}
				                 if afficheProchainsCoups and IsAlpha(ch) then
						               begin
						                 if IsLower(ch)
						                   then numeroFilsCherche := ord(ch) - ord('a') + 1
						                   else numeroFilsCherche := ord(ch) - ord('A') + 1;

						                 if (numeroFilsCherche <= NumberOfSons(GetCurrentNode)) and
						                    FindSquareWithThisEtiquette(ch, square) and
						                    (GetCouleurOfSquareDansJeuCourant(square) = pionVide) and
						                    PeutArreterAnalyseRetrograde then
						                      begin
						                        temposon := avecSon;
					                          avecSon := false;
						                        TraiteCoupImprevu(square);
						                        avecSon := tempoSon;
						                        peutRepeter := not(gameOver);
						                      end;
						               end;
				             end;                      {case ch}


				           end;

	                if not(enRetour or enSetUp) then
	                  begin

	                   if ch = chr(FlecheHautKey) then           {fleche en haut}
	                     begin
	                       if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan and command
	                         then TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlUpButtonPart)
	                         else
	                           begin
	                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+1;
	                             MontePartieHilitee(shift or option);
	                           end;
	                       peutRepeter := true;
	                     end;

		                 if ch = chr(FlecheBasKey) then            {fleche en bas}
		                   begin
		                     if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan and command
		                       then TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlDownButtonPart)
		                       else
		                         begin
		                           gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+1;
		                           DescendPartieHilitee(shift or option);
		                         end;
		                     peutRepeter := true;
		                   end;

		                 if ch = chr(FlecheGaucheKey) then        {fleche a gauche}
		                   begin
		                     if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan and command
		                     then TrackScrollingRapport(GetHorizontalScrollerOfRapport,kControlUpButtonPart)
		                     else
		                       if (nbreCoup > 0) and PeutArreterAnalyseRetrograde then
		                         if option then DoRetourDernierEmbranchement else
		                           begin
		                             AccelereProchainDoSystemTask(2);
		                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
		                             if windowListeOpen and (nbPartiesActives > 0)
		                               then if (theEvent.what = autoKey) or shift
		                                    then DoDoubleBackMovePartieSelectionnee(infosListeParties.partieHilitee)
		                                    else DoBackMovePartieSelectionnee(infosListeParties.partieHilitee)
		                               else if (theEvent.what = autoKey) or shift
		                                    then DoDoubleBackMove
		                                    else DoBackMove;

		                           end;
		                     peutRepeter := (nbreCoup > 0);
		                   end;

		                 if ch = chr(FlecheDroiteKey) then        {fleche a droite}
		                   begin
		                     if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan and command
		                     then TrackScrollingRapport(GetHorizontalScrollerOfRapport,kControlDownButtonPart)
		                     else
		                       if PeutArreterAnalyseRetrograde then
		                         if option then DoAvanceProchainEmbranchement else
		                           begin
		                             AccelereProchainDoSystemTask(2);
		                             gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
		                             if windowListeOpen and (nbPartiesActives > 0)
		                               then if (theEvent.what = autoKey) or shift
		                                    then DoDoubleAvanceMovePartieSelectionnee(infosListeParties.partieHilitee)
		                                    else JoueCoupPartieSelectionnee(infosListeParties.partieHilitee)
		                               else if (theEvent.what = autoKey) or shift
		                                    then DoDoubleAvanceMove
		                                    else DoAvanceMove;
		                           end;
		                     peutRepeter := not(gameOver);
		                   end;

		                 if ch = chr(TopDocumentKey) then       {document top}
		                   if windowListeOpen and (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) then
			                     with infosListeParties do
				                     begin
				                       ancPosPouce := positionPouceAscenseurListe;
				                       positionPouceAscenseurListe := 1;
					                     SetValeurAscenseurListe(positionPouceAscenseurListe);
					                     if ancPosPouce <> positionPouceAscenseurListe then
					                       EcritListeParties(false,'TopDocumentKey');
				                     end else
			                 if FenetreRapportEstOuverte and (OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr)) then
			                     VoirLeDebutDuRapport;

		                 if ch = chr(BottomDocumentKey) then    {document bottom}
		                   if windowListeOpen and (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) then
		                     with infosListeParties do
				                   begin
				                     ancPosPouce := positionPouceAscenseurListe;
				                     positionPouceAscenseurListe := nbPartiesActives-nbreLignesFntreListe+1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce <> positionPouceAscenseurListe then
				                       EcritListeParties(false,'BottomDocumentKey');
				                   end else
			                 if FenetreRapportEstOuverte and (OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr)) then
			                     VoirLaFinDuRapport;

		                 if ch = chr(PageUpKey) then            {page up}
		                   if windowListeOpen and (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) then
		                     with infosListeParties do
			                     begin
			                       ancPosPouce := positionPouceAscenseurListe;
			                       positionPouceAscenseurListe := positionPouceAscenseurListe-nbreLignesFntreListe+1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce <> positionPouceAscenseurListe then
				                       EcritListeParties(false,'PageUpKey');
			                     end else
			                 if FenetreRapportEstOuverte and (OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr)) then
			                     TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlPageUpPart);

		                 if ch = chr(PageDownKey) then          {page down}
		                   if windowListeOpen and (OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) then
		                     with infosListeParties do
			                     begin
			                       ancPosPouce := positionPouceAscenseurListe;
			                       positionPouceAscenseurListe := positionPouceAscenseurListe+nbreLignesFntreListe-1;
				                     SetValeurAscenseurListe(positionPouceAscenseurListe);
				                     if ancPosPouce <> positionPouceAscenseurListe then
				                       EcritListeParties(false,'PageDownKey');
			                     end else
			                 if FenetreRapportEstOuverte and (OrdreFenetre(GetRapportWindow) < OrdreFenetre(wListePtr)) then
			                     TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlPageDownPart);


		                 if ch = chr(RetourArriereKey) then   {retour arriere}
		                   begin
		                     if option and gDoitJouerMeilleureReponse
		                       then
		                         begin
		                           DoChangeAfficheSuggestionDeCassio;
		                         end
		                       else
		                         begin
        		                   if not(EffacerDansRapport) and PeutArreterAnalyseRetrograde then
        		                     begin
        		                       RemoveDelayAfterKeyboardOperation;
        		                       AccelereProchainDoSystemTask(2);
        		                       JoueCoupQueMacAttendait;
        		                       if not(afficheSuggestionDeCassio) and CassioEstEnModeAnalyse
        		                         then DoChangeAfficheSuggestionDeCassio;
        		                     end;
        		                 end;
		                   end;

		                 if ch = chr(HelpAndInsertKey) then   {touche aide}
		                   DoChangeDessineAide;

		                 if (ch = chr(EscapeKey)) and analyseRetrograde.enCours then {escape}
		                   DoDemandeChangerHumCtreHum;

	               (*
	               if afficheInfosApprentissage and avecFlecheProchainCoupDansGraphe then
	                 begin
	                   GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kNulleDansT,kPerteDansT,kPasDansT,kPropositionHeuristique,
	                                                            kGainAbsolu,kNulleAbsolue,kPerteAbsolue],
	                   true,FilsConnus);
	                   if filsConnus.cardinal <= 0
	                     then
	                       begin
	                         if PeutArreterAnalyseRetrograde then
	                           begin
	                             if theEvent.what = autoKey
	                               then DoDoubleAvanceMove
	                               else DoAvanceMove;
	                             peutRepeter := not(gameOver);
	                           end;
	                       end
	                     else
	                       if (IndexProchainFilsDansGraphe >= 1) and
	                          (IndexProchainFilsDansGraphe <= FilsConnus.cardinal) then
	                            begin
	                              tempoSon := avecSon;
	                              avecSon := false;
	                              TraiteCoupImprevu(FilsConnus.liste[IndexProchainFilsDansGraphe].coup);
	                              avecSon := tempoSon;
	                              peutRepeter := not(gameOver);
	                            end;
	                   end;
	                 *)
	                 (*
	                 if afficheInfosApprentissage and avecFlecheProchainCoupDansGraphe then
	                   begin
	                     if (ch = chr(FlecheHautKey)) and (IndexProchainFilsDansGraphe > 1) then {fleche en haut}
	                       begin
	                         IndexProchainFilsDansGraphe := IndexProchainFilsDansGraphe-1;
	                         EcritLesInfosDApprentissage;
	                       end;
	                     if ch = chr(FlecheBasKey) then                                         {fleche en bas}
	                       begin
	                         GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kNulleDansT,kPerteDansT,kPasDansT,kPropositionHeuristique,
	                                                                  kGainAbsolu,kNulleAbsolue,kPerteAbsolue],true,FilsConnus);
	                         if IndexProchainFilsDansGraphe < FilsConnus.cardinal then
	                           begin
	                             IndexProchainFilsDansGraphe := IndexProchainFilsDansGraphe+1;
	                             EcritLesInfosDApprentissage;
	                           end;
	                       end;
	                   end;
	                  *)

	                  end; {if not(enRetour or enSetUp) then}

             {WriteNumAt('ascii n°',ord(ch),20,40);}
          end;
      end;
end;

function ToucheCommandeInterceptee(ch : char; evt : eventRecord; var peutRepeter : boolean) : boolean;
var shift,command,option,control : boolean;
begin
  {$UNUSED peutRepeter}

  ToucheCommandeInterceptee := false;
  peutRepeter := false;

  if EnModeEntreeTranscript then
    begin
      if TraiteKeyboardEventDansTranscript(ch,peutRepeter) then
        begin
          ToucheCommandeInterceptee := true;
          exit;
        end;
    end;

  if not(iconisationDeCassio.enCours) then
    begin
      shift := BAND(evt.modifiers,shiftKey) <> 0;
      command := BAND(evt.modifiers,cmdKey) <> 0;
      option := BAND(evt.modifiers,optionKey) <> 0;
      control := BAND(evt.modifiers,controlKey) <> 0;

      if command then
        begin
          case ch of
            'Z':   {pomme-majuscules-Z}
              begin
                if shift and not(enRetour or enSetUp) and PeutArreterAnalyseRetrograde then
                  begin
                    AccelereProchainDoSystemTask(2);
                    gKeyDownEventsData.tickcountMinimalPourNouvelleRepetitionDeTouche := TickCount+4;
                    if theEvent.what = autoKey
                      then DoDoubleAvanceMove
                      else DoAvanceMove;
                    peutRepeter := not(gameOver);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            'K':   {pomme-majuscules-K}
              begin
                if shift and PeutArreterAnalyseRetrograde then
                  begin
                    BeginHiliteMenu(SolitairesID);
                    ChercherUnProblemeDePriseDeCoinDansListe(20,40);
                    EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            'È','Ë':   {pomme-option-K}
              begin
                if option and PeutArreterAnalyseRetrograde then
                  begin
                    BeginHiliteMenu(SolitairesID);
                    RevenirAuProblemeDePriseDeCoinPrecedent;
                    EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            'l','L':   {pomme-L}
              begin
                BeginHiliteMenu(AffichageID);
                DoChangeAfficheDernierCoup;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'æ','Æ':   {pomme-option-A}
              begin
                BeginHiliteMenu(AffichageID);
                DoChangeAfficheProchainsCoups;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'm','M':   {pomme-M}
              begin
                BeginHiliteMenu(AffichageID);
                if windowPaletteOpen then FlashCasePalette(PaletteInterrogation);
                DoChangeAfficheMeilleureSuite;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            chr(25) :   {pomme-control-y}
              begin
                BeginHiliteMenu(BaseID);
                DoNegationnerLesSousCriteres;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'Ú','Ÿ':   {pomme-option-y}
              begin
                BeginHiliteMenu(BaseID);
                DoSwaperLesSousCriteres;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            '†','™':   {pomme-option-t}
              begin
                if avecProgrammation then BeginHiliteMenu(ProgrammationID);
                DoChangeEnTraitementDeTexte;
                if avecProgrammation then EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'Ò':       {pomme-option-s}
              begin
                BeginHiliteMenu(FileID);
                DoEnregistrerSousFormatCassio(evt.modifiers);
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'ù','%','≤','≥':   {pomme-ù, pomme-%}
              begin
                DoDemandeAnalyseRetrograde(analyseRetrograde.nbPresentationsDialogue >= 1);
                ToucheCommandeInterceptee := true;
              end;
            '+':   {pomme-plus}
              begin
                if not(EnModeEntreeTranscript) and not(analyseRetrograde.enCours) then
                  begin
                    if avecProgrammation then BeginHiliteMenu(ProgrammationID);
                    DoChangeEnModeEntreeTranscript;
                    if avecProgrammation then EndHiliteMenu(evt.when,8,false);
                    ToucheCommandeInterceptee := true;
                  end;
              end;
            '‹','›':   {pomme-option-w}
              begin
                BeginHiliteMenu(FileID);
                FermeToutesLesFenetresAuxiliaires;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'Ï','Í':   {pomme-option-j}
              begin
                BeginHiliteMenu(SolitairesID);
                DoDemandeJouerSolitaires;
                EndHiliteMenu(evt.when,8,false);
                ToucheCommandeInterceptee := true;
              end;
            'µ','Ó':   {pomme-option-m}
              begin
                FindStringDansArbreDeJeuCourant(GetLastStringSearchedInGameTree,true);
              end;
          end;

	      if (ch = chr(FlecheGaucheKey)) then           {pomme-fleche a gauche}
	        begin
	          if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan then
	            begin
	              TrackScrollingRapport(GetHorizontalScrollerOfRapport,kControlUpButtonPart);
	              ToucheCommandeInterceptee := true;
	              peutRepeter := true;
		            exit;
		          end;
		        if windowListeOpen then
		          begin
		            case nbColonnesFenetreListe of
	                kAvecAffichageDistribution        : ;
	                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
	                kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
	              end; {case}
		            ToucheCommandeInterceptee := true;
		            peutRepeter := true;
		            exit;
		          end;
	        end;
	      if (ch = chr(FlecheDroiteKey)) then           {pomme-fleche a droite}
	        begin
	          if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan then
	            begin
	              TrackScrollingRapport(GetHorizontalScrollerOfRapport,kControlDownButtonPart);
	              ToucheCommandeInterceptee := true;
	              peutRepeter := true;
		            exit;
		          end;
		        if windowListeOpen then
		          begin
		            case nbColonnesFenetreListe of
	                kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageTournois);
	                kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
	                kAvecAffichageSeulementDesJoueurs : ;
	              end; {case}
		            ToucheCommandeInterceptee := true;
		            exit;
		          end;
	        end;
	      if (ch = chr(FlecheHautKey)) then             {pomme-fleche en haut}
	        begin
	          if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan
	            then
		            begin
		              TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlUpButtonPart);
		              ToucheCommandeInterceptee := true;
		              peutRepeter := true;
			            exit;
			          end
			        else
			          begin
	                MontePartieHilitee(command);
	                ToucheCommandeInterceptee := true;
	                exit;
	              end;
	        end;
	      if (ch = chr(FlecheBasKey)) then              {pomme-fleche en bas}
	        begin
	          if FenetreRapportEstOuverte and FenetreRapportEstAuPremierPlan
	            then
	              begin
		              TrackScrollingRapport(GetVerticalScrollerOfRapport,kControlDownButtonPart);
		              ToucheCommandeInterceptee := true;
		              peutRepeter := true;
			            exit;
			          end
			        else
		            begin
	                DescendPartieHilitee(command);
	                ToucheCommandeInterceptee := true;
	                exit;
	              end;
	        end;
	      if (ch = chr(RetourArriereKey)) then   {pomme-delete}
	        begin
	          if gDoitJouerMeilleureReponse then
              begin
                DoChangeAfficheSuggestionDeCassio;
                peutRepeter := false;
  		          exit;
              end;
	          if option and gDoitJouerMeilleureReponse then
              begin
                DoChangeAfficheSuggestionDeCassio;
                peutRepeter := false;
  		          exit;
              end;
            if option and not(afficheSuggestionDeCassio) and CassioEstEnModeAnalyse then
        		  begin
        		    DoChangeAfficheSuggestionDeCassio;
        		    peutRepeter := false;
  		          exit;
        		  end;
	          if windowListeOpen
	            and ((OrdreFenetre(wListePtr) < OrdreFenetre(GetRapportWindow)) or (LongueurSelectionRapport <= 0))
	            and not(FenetreListeEstEnModeEntree)
	            and (nbPartiesActives > 0)
	            then
  	            begin
  	              DoSupprimerPartiesDansListe;
  	              peutRepeter := false;
  		            exit;
  	            end
	            else
	              if EffacerDansRapport then DoNothing;
	        end;
	    end;
	  end;
end;


procedure ToggleAideDebutant;
  begin
    if not(enSetUp or enRetour) then
      begin
	      aideDebutant := not(aideDebutant);

	      if (nbreCoup <= 5) and not(BibliothequeDeZebraEstAfficheeSurOthellier)
	        then LireBibliothequeDeZebraPourCurrentNode('ToggleAideDebutant');

	      if aideDebutant
	        then DessineAideDebutant(true,othellierToutEntier)
          else EffaceAideDebutant(true,true,othellierToutEntier,'ToggleAideDebutant');

	    end;
  end;



procedure TraiteSourisStandard(mouseLoc : Point; modifiers : SInt16);
var whichSquare,numeroCoup : SInt16;
    nbreCoupAvantLeClic : SInt16;
    shift,command,option,control : boolean;
    whichSon : GameTree;
    coupsDejaGeneres : SquareSet;
    myRect : rect;
begin

 shift := BAND(modifiers,shiftKey) <> 0;
 command := BAND(modifiers,cmdKey) <> 0;
 option := BAND(modifiers,optionKey) <> 0;
 control := BAND(modifiers,controlKey) <> 0;


 if (control) and PtInPlateau(mouseLoc,whichSquare) then
   begin
     ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc,JeuCourant,true);
     AfficheProprietesOfCurrentNode(true,othellierToutEntier,'TraiteSourisStandard {1}');
     exit;
   end;


 if not(PtInPlateau(mouseLoc,whichSquare))
   then
     begin
       if PtInRect(mouseLoc,gHorlogeRect) and not(EnModeEntreeTranscript)
         then
           begin
             myRect := gHorlogeRect;
             if AppuieBouton(myRect,10,mouseLoc,DrawInvertedClockBoundingRect,DrawClockBoundingRect) then DoCadence;
           end
       else
       if (option or control or command) and not(EnModeEntreeTranscript)
         then
           begin
             DoDialoguePreferencesAffichage;
           end
       else
       if PtInRect(mouseLoc,gMeilleureSuiteRect) and not(EnModeEntreeTranscript)
         then
           begin
             DoChangeAfficheMeilleureSuite;
           end
       else
       if PtInRect(mouseLoc,GetRectEscargot) and not(EnModeEntreeTranscript)
         then
           begin
             DoTraiteClicEscargot;
           end
       else
         ToggleAideDebutant;
     end
   else
     begin
      if not(option or command)
        then
          begin
            if not(possibleMove[whichSquare])
              then
                begin
                  if PeutReculerUnCoup and CurseurEstEnTeteDeMort and (whichSquare = DerniereCaseJouee) and PeutArreterAnalyseRetrograde
								    then
								      begin
								        DetruitSousArbreCourantEtBackMove;
				              end
								    else
								      begin
								        ToggleAideDebutant;
								        if PeutReculerUnCoup and not(CurseurEstEnTeteDeMort) and (whichSquare = DerniereCaseJouee) and not(analyseRetrograde.enCours) then
								          BeginLiveUndo(GetEnsembleDesCoupsDesFreresReels(GetCurrentNode),0);
								      end;
								  if CurseurEstEnTeteDeMort then
								    begin
								      SetNiveauTeteDeMort(0);
								      RemettreLeCurseurNormalDeCassio;
								    end;
                end
              else
                if not(gameOver or CassioEstEnModeTournoi) then
                  begin
                    if CurseurEstEnTeteDeMort
                      then
                        begin
                          whichSon := SelectTheSonAfterThisMove(GetCurrentNode,whichSquare,AQuiDeJouer);
                          if whichSon <> NIL then DetruireCeFilsOfCurrentNode(whichSon);
								          SetNiveauTeteDeMort(0);
								          RemettreLeCurseurNormalDeCassio;
                        end
                      else
                        begin
                          nbreCoupAvantLeClic := nbreCoup;
                          coupsDejaGeneres := GetEnsembleDesCoupsDesFilsReels(GetCurrentNode);

                          // WritelnDansRapport('dans TraiteSourisStandard, coupsDejaGeneres = '+SquareSetEnString(coupsDejaGeneres));

                          TraiteCoupImprevu(whichSquare);  // <-- on essaye ici de jouer le coup

                          if (nbreCoup = nbreCoupAvantLeClic + 1) then
                            BeginLiveUndo(coupsDejaGeneres,15);
                        end;
                  end;
          end
        else
          begin
            if TrouveCoupDansPartieCourante(whichSquare,numeroCoup) then
              if PeutArreterAnalyseRetrograde and not(CassioEstEnModeTournoi) then
                begin
                  if numeroCoup < nbreCoup
                    then
                      begin
                        if numeroCoup <= 0
                          then DoDebut(false)
                          else
                            if numeroCoup = nbreCoup-1
                              then DoBackMove
                              else DoRetourAuCoupNro(numeroCoup,true,not(CassioEstEnModeAnalyse));
                        {if not(CassioEstEnModeSolitaire) then DoInsererMarque;}
                      end
                    else
                      if numeroCoup + 1 > nbreCoup then
                        begin
                          if numeroCoup + 1 = nbreCoup + 1
                            then
                              begin
                                DoAvanceMove;
                                BeginLiveUndo(GetEnsembleDesCoupsDesFreresReels(GetCurrentNode),15);
                              end
                            else DoAvanceAuCoupNro(numeroCoup+1,not(CassioEstEnModeAnalyse));
                          {if not(CassioEstEnModeSolitaire) then DoInsererMarque;}
                        end;
                end;
          end;
    end;
end;

procedure TraiteSourisRetour(mouseLoc : Point; modifiers : SInt16);
var numeroDuCoupTrouve,i,whichSquare : SInt16;
    trouve : boolean;
    shift,command,option,control : boolean;
begin
  shift := BAND(modifiers,shiftKey) <> 0;
  command := BAND(modifiers,cmdKey) <> 0;
  option := BAND(modifiers,optionKey) <> 0;
  control := BAND(modifiers,controlKey) <> 0;

  {
  if command then
    begin
      if not(windowPlateauOpen) then DoNouvellePartie;
      IconiserCassio;
      exit;
    end;
   }

  if PtInPlateau(mouseLoc,whichSquare) then
    begin
      trouve := false;
      for i := 1 to nbreCoup do
        if GetNiemeCoupPartieCourante(i) = whichSquare then
          begin
            numeroDuCoupTrouve := i-1;
            trouve := true;
          end;
      if trouve and (numeroDuCoupTrouve < nbreCoup)
        then
          begin
            if PeutArreterAnalyseRetrograde then
              begin
                EffaceZoneADroiteDeLOthellier;
                EffaceZoneAuDessousDeLOthellier;
                if gCouleurOthellier.estUneImage and not(Quitter) then
                  DessineNumerosDeCoupsSurTousLesPionsSurDiagramme(numeroDuCoupTrouve); {effacement des numeros fantomes}
                DoRetourAuCoupNro(numeroDuCoupTrouve,false,not(CassioEstEnModeAnalyse));
                {if not(CassioEstEnModeSolitaire) then DoInsererMarque;}
                enRetour := false;
              end
          end
        else
          begin
            enRetour := false;
            humainVeutAnnuler := true;
            dernierTick := TickCount;
          end;
    end
   else
    begin
     if PtInRect(mouseLoc,annulerRetourRect) then
       if AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,5),annulerRetourRect,30,mouseLoc) then
         begin
           enRetour := false;
           humainVeutAnnuler := true;
           dernierTick := TickCount;
           FlushEvents(MDownmask+MUpMask,0); {pour supprimer les double-clics}
         end;
    end;
end;

procedure TraiteSourisFntrPlateau(evt : eventRecord);
var mouseLoc : Point;
    oldport : grafPtr;
begin
  if windowPlateauOpen then
    begin
      AnnulerSousCriteresRuban;
      GetPort(oldport);
      SetPortByWindow(wPlateauPtr);
      mouseLoc := evt.where;
      GlobalToLocal(mouseLoc);
      if (mouseLoc.h >= GetWindowPortRect(wPlateauPtr).right-16) and
         (mouseLoc.v >= GetWindowPortRect(wPlateauPtr).bottom-16)
        then
          begin
            DoGrowWindow(wPlateauPtr,evt);
          end
        else
          begin
            if not(EnModeEntreeTranscript and TraiteMouseEventDansTranscript(evt)) then
              if enRetour
                then TraiteSourisRetour(mouseLoc,evt.modifiers)
                else TraiteSourisStandard(mouseLoc,evt.modifiers);
          end;
      SetPort(oldport);
    end;
  if windowPaletteOpen then
    if BooleanXor(HumCtreHum,SablierDessineEstRenverse) then
      DessineIconesChangeantes;
end;





procedure TraiteSourisPalette(evt : eventRecord);
var limiteRect : rect;
    oldport : grafPtr;
    mouseLoc : Point;
    CaseXPalette,CaseYPalette,nroAction : SInt16;
    ok : boolean;
    tick : SInt32;

   procedure FlashCase(nroAction : SInt16; rectangle : rect);
   var tick : SInt32;
     begin
       SetPortByWindow(wPalettePtr);
       tick := TickCount;
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,true);
       while TickCount-tick < 6 do DoNothing;
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,false);
     end;

   procedure PresseCase(nroAction : SInt16; rectangle : rect);
   var tick : SInt32;
     begin
       SetPortByWindow(wPalettePtr);
       tick := TickCount;
       if gBlackAndWhite
         then InvertRect(rectangle)
         else DessineCasePaletteCouleur(nroAction,true);
       while TickCount-tick < 6 do DoNothing;
       if not(StillDown) then
         if gBlackAndWhite
           then InvertRect(rectangle)
           else DessineCasePaletteCouleur(nroAction,false);
     end;

   function ActionVoulue(nroAction : SInt16; rectangle : rect) : boolean;
   var tick : SInt32;
       caseEnfoncee,dedans : boolean;
   begin
     SetPortByWindow(wPalettePtr);
     tick := TickCount;
     if gBlackAndWhite
       then InvertRect(rectangle)
       else DessineCasePaletteCouleur(nroAction,true);
     caseEnfoncee := true;

     while TickCount-tick < 6 do DoNothing;

     repeat
       GetMouse(mouseLoc);
       dedans := PtInRect(mouseLoc,rectangle);
       if dedans and not(caseEnfoncee) then
         begin
           if gBlackAndWhite
             then InvertRect(rectangle)
             else DessineCasePaletteCouleur(nroAction,true);
           caseEnfoncee := true;
         end;
       if not(dedans) and caseEnfoncee then
         begin
           if gBlackAndWhite
             then InvertRect(rectangle)
             else DessineCasePaletteCouleur(nroAction,false);
           caseEnfoncee := false;
         end;
     until not(StillDown);

     ActionVoulue := dedans;
     if not(gBlackAndWhite)
       then DessineCasePaletteCouleur(nroAction,false)
       else if caseEnfoncee then InvertRect(rectangle);

   end;

begin
  {$UNUSED evt}

  AjusteCurseur;
  GetPort(oldport);
  SetPortByWindow(wPalettePtr);
  mouseLoc := theEvent.where;
  GlobalToLocal(mouseLoc);
  CaseXPalette := mouseLoc.h div LargeurCasePalette +1;
  CaseYPalette := mouseLoc.v div HauteurCasePalette +1;
  if CaseXPalette > 9 then CaseXPalette := 9;
  if CaseYPalette > 2 then CaseYPalette := 2;
  nroaction := CaseXPalette+9*(CaseYPalette-1);
  SetRect(limiterect,(CaseXPalette-1)*largeurCasePalette,
                     (CaseYPalette-1)*hauteurCasePalette,
                     CaseXPalette*largeurCasePalette -1,
                     CaseYPalette*HauteurCasePalette -1);

  ok := true;
  if enSetUp then ok := false;
  if enRetour and (NroAction <> PaletteDiagramme) then ok := false;

  if CassioEstEnModeTournoi and ((NroAction = PaletteRetourDebut)   or
                               (NroAction = PaletteDoubleBack)    or
                               (NroAction = PaletteBack)          or
                               (NroAction = PaletteForward)       or
                               (NroAction = PaletteDoubleForward) or
                               (NroAction = PaletteAllerFin)      or
                               (NroAction = PaletteCoupPartieSel) or
                               (NroAction = PaletteCouleur)       or
                               (NroAction = PaletteSablier)) then ok := false;


  if ok then
    begin
      case NroAction of
        PaletteRetourDebut    : begin
                                  if ActionVoulue(PaletteRetourDebut,limiteRect) then
                                    if PeutArreterAnalyseRetrograde  then
                                      DoRetourDerniereMarque;
                                end;
        PaletteDoubleBack     : if PeutArreterAnalyseRetrograde then
                                begin
                                  tick := TickCount;
                                  PresseCase(PaletteDoubleBack,limiteRect);
                                  DoDoubleBackMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                  while BoutonAppuye(wPalettePtr,limiterect) and PeutReculerUnCoup do
                                    begin
                                      repeat until TickCount > tick+2;
			                                tick := TickCount;
                                      DoDoubleBackMove;
                                    end;
                                  if gBlackAndWhite
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteDoubleBack,false);
                                end;
        PaletteBack           : if PeutArreterAnalyseRetrograde then
                                begin
                                  tick := TickCount;
                                  PresseCase(PaletteBack,limiteRect);
                                  DoBackMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                  while BoutonAppuye(wPalettePtr,limiterect) and PeutReculerUnCoup do
                                    begin
                                      repeat until TickCount > tick+2;
			                                tick := TickCount;
			                                DoBackMove;
			                              end;
                                  if gBlackAndWhite
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteBack,false);
                                end;
        PaletteForward        : if PeutArreterAnalyseRetrograde then
                                begin
                                  tick := TickCount;
                                  PresseCase(PaletteForward,limiteRect);
                                  DoAvanceMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                  while BoutonAppuye(wPalettePtr,limiterect) and PeutAvancerUnCoup do
                                    begin
                                      repeat until TickCount > tick+2;
			                                tick := TickCount;
                                      DoAvanceMove;
                                    end;
                                  if gBlackAndWhite
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteForward,false);
                                end;
        PaletteDoubleForward  : if PeutArreterAnalyseRetrograde then
                                begin
                                  tick := TickCount;
                                  PresseCase(PaletteDoubleForward,limiteRect);
                                  DoDoubleAvanceMove;
                                  repeat
                                  until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                  while BoutonAppuye(wPalettePtr,limiterect) and PeutAvancerUnCoup do
                                    begin
                                      repeat until TickCount > tick+2;
			                                tick := TickCount;
                                      DoDoubleAvanceMove;
                                    end;
                                  if gBlackAndWhite
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteDoubleForward,false);
                                end;
        PaletteAllerFin       : begin
                                  if ActionVoulue(PaletteAllerFin,limiteRect) then
                                    if PeutArreterAnalyseRetrograde then
                                      DoAvanceProchaineMarque;
                                end;
        PaletteCoupPartieSel  : begin
                                  tick := TickCount;
                                  PresseCase(PaletteCoupPartieSel,limiteRect);
                                  if BAND(theEvent.modifiers,shiftKey) <> 0
                                    then
                                      begin
                                        if windowListeOpen and (nbPartiesActives > 0) then
                                          if PeutArreterAnalyseRetrograde then
                                            begin
                                              DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
                                              repeat
                                              until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                              while BoutonAppuye(wPalettePtr,limiterect) and PeutReculerUnCoup do
                                                begin
                                                  repeat until TickCount > tick+2;
			                                            tick := TickCount;
			                                            DoBackMovePartieSelectionnee(infosListeParties.partieHilitee);
			                                          end;
                                            end;
                                      end
                                    else
                                      begin
                                        JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);
                                        repeat
                                        until not(BoutonAppuye(wPalettePtr,limiterect)) or (TickCount-tick > 15);
                                        while BoutonAppuye(wPalettePtr,limiterect) and PeutAvancerPartieSelectionnee do
                                          begin
                                            repeat until TickCount > tick+2;
			                                      tick := TickCount;
			                                      JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);
			                                    end;
                                      end;
                                   if gBlackAndWhite
                                    then DessinePalette
                                    else DessineCasePaletteCouleur(PaletteCoupPartieSel,false);
                                end;
        PaletteCouleur        : begin
                                 {if not(HumCtreHum) then}
                                   if not(CassioEstEnModeAnalyse) and ActionVoulue(PaletteCouleur,limiteRect) then
                                     if PeutArreterAnalyseRetrograde then DoDemandeChangeCouleur;
                                end;
        PaletteSablier        : begin
                                  if ActionVoulue(PaletteSablier,limiteRect) then
                                    DoDemandeChangerHumCtreHum;
                                end;
        PaletteInterrogation  : begin
                                  if ActionVoulue(PaletteInterrogation,limiteRect) then
                                    DoChangeAfficheMeilleureSuite;
                                end;
        PaletteHorloge        : begin
                                  if ActionVoulue(PaletteHorloge,limiteRect) then
                                    DoCadence;
                                end;
        PaletteBase           : begin
                                  if ActionVoulue(PaletteBase,limiteRect) then
                                    DoChargerLaBase;
                                end;
        PaletteDiagramme      : begin
                                  if ActionVoulue(PaletteDiagramme,limiteRect) then
                                    if enRetour
                                      then humainVeutAnnuler := true
                                      else DoRevenir;
                                end;
        PaletteSon            : begin
                                  if ActionVoulue(PaletteSon,limiteRect) then
                                    begin
                                      DoSon;
                                      if avecSon then PlayPosePionSound;
                                    end;
                                end;
        PaletteStatistique    : begin
                                  if ActionVoulue(PaletteStatistique,limiteRect) then
                                    DoStatistiques;
                                end;
        PaletteListe          : begin
                                  if ActionVoulue(PaletteListe,limiteRect) then
                                    DoListeDeParties;
                                end;
        PaletteReflexion      : begin
                                  if ActionVoulue(PaletteReflexion,limiteRect) then
                                    DoChangeAfficheReflexion;
                                end;
        PaletteCourbe         : begin
                                  if ActionVoulue(PaletteCourbe,limiteRect) then
                                    DoCourbe;
                                end;
      end;  {case}
    end;

  SetPort(oldport);
end;


procedure TraiteSourisAide(evt : eventRecord);
begin {$UNUSED evt}
  gAideCourante := NextPageDansAide(gAideCourante);
  DessineAide(gAideCourante);
end;




procedure TraiteSourisStatistiques(evt : eventRecord);
var coup,premierCoup,numLigne : SInt16;
    autreCoupQuatreDansPartie,tempoSon : boolean;
    mouseLoc : Point;
    oldport : grafPtr;
    rubanRect : rect;
    tick : SInt32;
begin
  if windowStatOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wStatPtr);
      mouseLoc := evt.where;
      GlobalToLocal(mouseLoc);
      if mouseLoc.v < hauteurRubanStatistiques
        then
          begin
            tick := TickCount;
            SetRect(rubanRect,0,0,QDGetPortBound.right,hauteurRubanStatistiques);
            if PtInRect(mouseLoc,rubanRect) and PeutArreterAnalyseRetrograde then
	            begin
	              DoBackMove;
				        repeat until not(BoutonAppuye(wStatPtr,rubanRect)) or (TickCount-tick > 15);
			          while BoutonAppuye(wStatPtr,rubanRect) and PeutReculerUnCoup do
			            begin
			              repeat until TickCount > tick+2;
			              tick := TickCount;
			              DoBackMove;
			            end;
			        end;
          end
        else
          if (nbPartiesChargees > 0) and (nbPartiesActives > 0) and
             (statistiques <> NIL) and StatistiquesCalculsFaitsAuMoinsUneFois then
          begin
            numLigne := 1+((mouseLoc.v-hauteurRubanStatistiques-2) div hauteurChaqueLigneStatistique);
            if numLigne <= statistiques^^.nbreponsesTrouvees then
              begin
                autreCoupQuatreDansPartie := false;
                if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
                coup := ord(statistiques^^.table[numLigne].coup);
                if (coup >= 11) and (coup <= 88) then
                  begin
		                TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
		                tempoSon := avecSon;
		                avecSon := false;
		                TraiteCoupImprevu(coup);
		                avecSon := tempoSon;
		              end;
              end;
          end;
      SetPort(oldport);
    end;
end;

procedure TraiteSourisCommentaires(evt : eventRecord; fenetreActiveeParCeClic : boolean);
var mouseLoc : Point;
    lesFilsRect : rect;
    oldport : grafPtr;
    shift,verouillage,command,option,control : boolean;
    myText : TEHandle;
    enModeEditionArrivee,tempoSon : boolean;
    clicDansLaZoneDesCommentaires : boolean;
    positionSouris,dummy : SInt32;
    minimum,maximum : SInt16;
    tick : SInt32;
    gameNodeAvantInterversion : GameTree;

  procedure JoueLeFilsSousLeCurseurDeLaSouris;
  var whichSon : GameTree;
      move : PropertyPtr;
      numeroDuFils : SInt32;
  begin
    numeroDuFils := (mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu;
    if (numeroDuFils = NbDeFilsOfCurrentNode+1) then numeroDuFils := NbDeFilsOfCurrentNode;
	  whichSon := SelectNthSon(numeroDuFils,GetCurrentNode);
	  if whichSon <> NIL then
	    if CurseurEstEnTeteDeMort
	      then
	        begin
	          DetruireCeFilsOfCurrentNode(whichSon);
	          SetNiveauTeteDeMort(0);
					  RemettreLeCurseurNormalDeCassio;
					end
	      else
	        begin
	          move := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],whichSon);
	          if (move <> NIL) then
	            begin
	              tempoSon := avecSon;
	              avecSon := false;
	              TraiteCoupImprevu(GetOthelloSquareOfProperty(move^));
	              avecSon := tempoSon;
	            end;
	        end;
	end;

	procedure DeplaceLeFilsSousLeCurseurDeLaSouris;
  var whichSon : GameTree;
      numeroDuFils : SInt32;
      index : SInt32;
  begin
    numeroDuFils := (mouseLoc.v - 1) div InterligneArbreFenetreArbreDeJeu;
    if (numeroDuFils >= 1) and (numeroDuFils <= NbDeFilsOfCurrentNode) then
      with arbreDeJeu do
      begin
        InverserLeNiemeFilsDansFenetreArbreDeJeu(numeroDuFils);
        positionSouris := mouseLoc.v;
		    minimum := backMoveRect.bottom-1;
		    maximum := Min(minimum+espaceEntreLignesProperties*NbDeFilsOfCurrentNode+1,EditionRect.top-10);
		    DragLine(GetArbreDeJeuWindow, kDragHorizontalLine,false,minimum,maximum,espaceEntreLignesProperties,positionSouris,index,IdentiteSurN);
		    InverserLeNiemeFilsDansFenetreArbreDeJeu(numeroDuFils);
		    EffaceProprietesOfCurrentNode;
		    whichSon := SelectNthSon(numeroDuFils,GetCurrentNode);
		    if index > numeroDuFils then BringSonOfCurrentNodeInPositionN(whichSon,index) else
		    if index < numeroDuFils then BringSonOfCurrentNodeInPositionN(whichSon,index+1);
		    DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DeplaceLeFilsSousLeCurseurDeLaSouris');
		    AfficheProprietesOfCurrentNode(true,othellierToutEntier,'DeplaceLeFilsSousLeCurseurDeLaSouris');
      end;
  end;

begin  {TraiteSourisCommentaires}
  with arbreDeJeu do
    if windowOpen and (GetArbreDeJeuWindow <> NIL) then
      begin
        enModeEditionArrivee := enModeEdition;

        shift       := BAND(evt.modifiers,shiftKey) <> 0;
        verouillage := BAND(evt.modifiers,alphaLock) <> 0;
        command     := BAND(evt.modifiers,cmdKey) <> 0;
        option      := BAND(evt.modifiers,optionKey) <> 0;
        control     := BAND(evt.modifiers,controlKey) <> 0;

        GetPort(oldport);
        SetPortByWindow(GetArbreDeJeuWindow);
        mouseLoc := evt.where;
        GlobalToLocal(mouseLoc);

        clicDansLaZoneDesCommentaires := PtInRect(mouseLoc,EditionRect);
        myText := GetDialogTextEditHandle(theDialog);
        if myText <> NIL then
	        if clicDansLaZoneDesCommentaires
	          then
	            begin
	              enModeEdition := true;
	              ActiverModeEditionFenetreArbreDeJeu;
	              ClicDansTexteCommentaires(mouseLoc,shift);
	              doitResterEnModeEdition := EnTraitementDeTexte;
	            end
	          else
	            begin
	              if enModeEditionArrivee then
	                begin
	                  enModeEdition := false;
	                  GetCurrentScript(gLastScriptUsedInDialogs);
	                  SwitchToRomanScript;
	                  DeactiverModeEditionFenetreArbreDeJeu;
	                end;
	            end;

	      if not(fenetreActiveeParCeClic) and (GetArbreDeJeuWindow = FrontWindowSaufPalette) then
	        begin
	          tick := TickCount;

	          if avecInterversions and not(CurseurEstEnTeteDeMort) and
	             SurIconeInterversion(mouseLoc,gameNodeAvantInterversion) and
	             (gameNodeAvantInterversion = GetCurrentNode) then
	            begin
	              if PeutArreterAnalyseRetrograde then
	                CyclerDansOrbiteInterversionDuGraphe(gameNodeAvantInterversion,not(shift));
	              SetPort(oldPort);
	              exit;
	            end;

	          if PtInRect(mouseLoc,backMoveRect) and (not(enModeEditionArrivee) or doitResterEnModeEdition) then
	            begin
	              if PeutArreterAnalyseRetrograde then
	                begin
					          if CurseurEstEnTeteDeMort
					            then
					              DoDialogueDetruitSousArbreCourant
					            else
					              begin
											    DoBackMove;
											    repeat until not(BoutonAppuye(GetArbreDeJeuWindow,backMoveRect)) or (TickCount-tick > 15);
										      while BoutonAppuye(GetArbreDeJeuWindow,backMoveRect) and PeutReculerUnCoup do
										        begin
										          repeat until TickCount > tick+2;
										          tick := TickCount;
										          DoBackMove;
										        end;
										    end;
					        end;
	              SetPort(oldPort);
	              exit;
	            end;


	          if (mouseLoc.v >= backMoveRect.bottom) and (mouseLoc.v <= EditionRect.top-12) and (not(enModeEditionArrivee) or doitResterEnModeEdition) then
	            begin
	              lesFilsRect := MakeRect(-1,backMoveRect.bottom,10000,backMoveRect.bottom + 5 + NbDeFilsOfCurrentNode*InterligneArbreFenetreArbreDeJeu);
	              if not(PtInRect(mouseLoc,lesFilsRect)) and enModeEditionArrivee and doitResterEnModeEdition then
	                begin
	                  doitResterEnModeEdition := false;
	                  ValideZoneCommentaireDansFenetreArbreDeJeu;
	                end;

                if (shift or option or command) and (NbDeFilsOfCurrentNode > 1)
                  then
                    DeplaceLeFilsSousLeCurseurDeLaSouris
                  else
                    begin
							        lesFilsRect := MakeRect(-1,backMoveRect.bottom,1000,EditionRect.top-12);
							        JoueLeFilsSousLeCurseurDeLaSouris;
							        repeat
			                until not(BoutonAppuye(GetArbreDeJeuWindow,lesFilsRect)) or (TickCount-tick > 15);
		                  while BoutonAppuye(GetArbreDeJeuWindow,lesFilsRect) and PeutAvancerUnCoup do
			                  begin
			                    repeat until TickCount > tick+2;
			                    tick := TickCount;
			                    JoueLeFilsSousLeCurseurDeLaSouris;
			                  end;
		                end;

	              SetPort(oldPort);
	              exit;
	            end;

	          if (mouseLoc.v > EditionRect.top-12) and (mouseLoc.v < EditionRect.top) then
	            begin
	              positionSouris := mouseLoc.v;

	              DragLine(GetArbreDeJeuWindow, kDragHorizontalLine,false,45,QDGetPortBound.bottom-29,2,positionSouris,dummy,IdentiteSurN);
	              AjusteCurseur;
	              ChangeDelimitationEditionRectFenetreArbreDeJeu(positionSouris);
	              MyEraseRect(QDGetPortBound);
	              MyEraseRectWithColor(QDGetPortBound,VioletCmd,blackPattern,'');
	              DrawContents(GetArbreDeJeuWindow);

	              SetPort(oldPort);
	              exit;
	            end;
	        end;

        {WritelnDansRapport('tapez une touche');
        AttendFrappeClavier;}

        SetPort(oldPort);
      end;
end;


{
procedure TraiteSourisGestion(evt : eventRecord);
begin
end;
}

procedure TraiteSourisRapport(evt : eventRecord);
begin
  ClicInRapport(evt);
end;

(*********************** displayHandlers **************************)

procedure DrawContents(whichWindow : WindowPtr);
var oldClipRgn : RgnHandle;
    visibleRgn : RgnHandle;

  procedure ClipToViewArea;
    var r : rect;
    begin
      oldclipRgn := NewRgn;
      GetClip(oldClipRgn);
      r := GetWindowPortRect(whichWindow);
      with r do
      begin
        right := right-scbarWidth;
        bottom := bottom-scbarWidth;
      end;
      ClipRect(r);
    end;

  begin

    {DrawScrollBars(whichWindow);}
    {ClipToViewArea;}        (***** cf + bas *****)


    if (whichWindow = wPlateauPtr)
      then
        begin
          if enRetour
            then
              begin
                visibleRgn := NewRgn;
                DessineRetour(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),'DrawContents');
                DisposeRgn(visibleRgn);
              end
            else
              begin
                visibleRgn := NewRgn;
                EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn), enSetUp or EnModeEntreeTranscript or enTournoi);
                if not(enSetUp) and afficheInfosApprentissage then EcritLesInfosDApprentissage;
                DisposeRgn(visibleRgn);
              end;
        end
      else
        if whichWindow = wCourbePtr
          then
            begin
              DessineCourbe(kCourbeColoree,'DrawContents');
              DessineSliderFenetreCourbe;
            end
          else
            if whichWindow = wGestionPtr
            then EcritGestionTemps
            else
            if whichWindow = wNuagePtr
            then DessineNuage('DrawContents')
            else
              if whichWindow = wReflexPtr
              then EcritReflexion('DrawContents')
              else
                if whichWindow = wListePtr
                then
                  begin
                    EcritRubanListe(true);
                    EcritListeParties(false,'DrawContents');
                    if gIsRunningUnderMacOSX then
                      if IsWindowHilited(wListePtr)
							          then MontrerAscenseurListe
							          else CacherAscenseurListe;
                  end
                else
                  if whichWindow = wStatPtr
                    then
                      begin
                        EcritRubanStatistiques;
                        EcritStatistiques(false);
                      end
                    else
                      if EstLaFenetreDuRapport(whichWindow)
                        then RedrawFenetreRapport
                        else
                          if whichWindow = iconisationDeCassio.theWindow
                            then DessinePictureIconisation
                            else
                              if whichWindow = GetArbreDeJeuWindow
                                then
                                  begin
                                    DessineZoneDeTexteDansFenetreArbreDeJeu(false);
                                    LireBibliothequeDeZebraPourCurrentNode('DrawContents');
                                    EcritCurrentNodeDansFenetreArbreDeJeu(true,false);
                                  end
                                else
                                  if whichWindow = wAidePtr
                                    then DessineAide(gAideCourante)
                                    else
                                      if whichWindow = wPalettePtr
                                      then DessinePalette;

    DessineBoiteDeTaille(whichWindow);


    {
    SetClip(oldClipRgn);     (******  toujours faire aller ces 2 lignes ****)
    DisposeRgn(oldclipRgn);  (******  avec ClipToViewArea               ****)
    }
  end;

procedure DoUpdateWindow(whichWindow : WindowPtr);
var oldPort : grafPtr;
    visibleRgn : RgnHandle;
begin
  GetPort(oldPort);
  CheckScreenDepth;
  if whichWindow = NIL
    then
      begin
        SysBeep(0);
        WritelnDansRapport('ERROR : (whichWindow = NIL) dans DoUpdateWindow');
      end
    else
      begin
			  BeginUpdate(whichWindow);

			  // si (whichWindow = wNuagePtr), on donne une chance aux autres fenetres de se mettre à jour
			  // car le reaffichage du nuage prend un petit moment
			  if (whichWindow = wNuagePtr) then
			    begin
			      NoUpdateThisWindow(wNuagePtr);
			      DoSystemTask(AQuiDeJouer);
			    end;

			  visibleRgn := NewRgn;
			  if not(RegionEstVide(GetWindowVisibleRegion(whichWindow,visibleRgn))) then
			    begin
			      SetPortByWindow(whichWindow);

			      if gIsRunningUnderMacOSX and WindowDeCassio(whichWindow) and (whichWindow <> wNuagePtr) then
			        begin
			          if (whichWindow = wPlateauPtr)
			            then EraseRectDansWindowPlateau(GetWindowPortRect(whichWindow)) else
			          if (whichWindow = wReflexPtr)
			            then EffaceReflexion(HumCtreHum)
			            else begin
			                   MyEraseRect(GetWindowPortRect(whichWindow));
			                   MyEraseRectWithColor(GetWindowPortRect(whichWindow),VioletCmd,blackPattern,'');
			                 end;
			        end;

			      if (whichWindow = wListePtr) then InvalidateJustificationPasDePartieDansListe;

			      DrawContents(whichWindow);
			    end;
			  DisposeRgn(visibleRgn);

			  EndUpdate(whichWindow);
			end;

  SetPort(oldPort);
end;

procedure EssaieUpdateEventsWindowPlateau;
begin
 if not(Quitter) then
 if not(enSetUp) then
   begin
     if windowPaletteOpen and (wPalettePtr <> NIL) then
       if IsWindowUpdatePending(wPalettePtr) then
         begin
           DoUpdateWindow(wPalettePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;

     if windowPlateauOpen and (wPlateauPtr <> NIL) then
       if IsWindowUpdatePending(wPlateauPtr) then
         begin
           DoUpdateWindow(wPlateauPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;

     if windowListeOpen and (wListePtr <> NIL) then
       if IsWindowUpdatePending(wListePtr) then
         begin
           DoUpdateWindow(wListePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if FenetreRapportEstOuverte then
       if IsWindowUpdatePending(GetRapportWindow) then
         begin
           DoUpdateWindow(GetRapportWindow);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowStatOpen and (wStatPtr <> NIL) then
       if IsWindowUpdatePending(wStatPtr) then
         begin
           DoUpdateWindow(wStatPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if arbreDeJeu.windowOpen and (GetArbreDeJeuWindow <> NIL) then
       if IsWindowUpdatePending(GetArbreDeJeuWindow) then
         begin
           DoUpdateWindow(GetArbreDeJeuWindow);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowGestionOpen and (wGestionPtr <> NIL) then
       if IsWindowUpdatePending(wGestionPtr) then
         begin
           DoUpdateWindow(wGestionPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowNuageOpen and (wNuagePtr <> NIL) then
       if IsWindowUpdatePending(wNuagePtr) then
         begin
           DoUpdateWindow(wNuagePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowCourbeOpen and (wCourbePtr <> NIL) then
       if IsWindowUpdatePending(wCourbePtr) then
         begin
           DoUpdateWindow(wCourbePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowAideOpen and (wAidePtr <> NIL) then
       if IsWindowUpdatePending(wAidePtr) then
         begin
           DoUpdateWindow(wAidePtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
     if windowReflexOpen and (wReflexPtr <> NIL) then
       if IsWindowUpdatePending(wReflexPtr) then
         begin
           DoUpdateWindow(wReflexPtr);
           DiminueLatenceEntreDeuxDoSystemTask;
           AccelereProchainDoSystemTask(60);
         end;
   end;
end;


(*********************** event handlers ****************************)





procedure AttendrePendantRepetitionOfKeyDownEvent(var repetitionDetectee : boolean);
var doitAttendreRepetition : boolean;
    myLocalEvent : eventRecord;
    localSleep : SInt32;
    theKeysPourRepetition : myKeyMap;
begin
  doitAttendreRepetition := true;

  with gKeyDownEventsData do
    repeat
      {WritelnStringAndBoolDansRapport('1.doitAttendre = ',doitAttendreRepetition);}

      MyGetKeys(theKeysPourRepetition);
      if not(MemesTouchesAppuyees(theKeys,theKeysPourRepetition)) or
         not(ToucheAppuyee(keyCode)) then
        begin
          doitAttendreRepetition := false;
          repetitionDetectee := false;
        end;

      if TickCount < tickcountMinimalPourNouvelleRepetitionDeTouche
        then
          begin
            localSleep := 1;
            if doitAttendreRepetition and WaitNextEvent(autoKeyMask,myLocalEvent,localSleep,NIL) then
              begin
                {WritelnDansRapport('autoKeyDetecte');}
                doitAttendreRepetition := false;
                repetitionDetectee := true;
              end;
          end
        else
          begin
            if doitAttendreRepetition and EventAvail(autoKeyMask,myLocalEvent) then
              begin
                {WritelnDansRapport('autoKeyDetecte');}
                doitAttendreRepetition := false;
                repetitionDetectee := true;
              end;
          end;

      if doitAttendreRepetition and EventAvail(KeyDownMask,myLocalEvent) then
        begin
          {WritelnDansRapport('KeyDownDetecte');}
          doitAttendreRepetition := false;
          repetitionDetectee := false;
        end;

      if tickcountMinimalPourNouvelleRepetitionDeTouche < tickFrappeTouche + delaiAvantDebutRepetition
        then tickcountMinimalPourNouvelleRepetitionDeTouche := tickFrappeTouche + delaiAvantDebutRepetition;

      {WritelnStringAndBoolDansRapport('2.doitAttendre = ',doitAttendreRepetition);}

      SetRepetitionDeToucheEnCours(repetitionDetectee);


    until (TickCount >= tickcountMinimalPourNouvelleRepetitionDeTouche) or not(doitAttendreRepetition);
end;


procedure KeyDownEvents;
  var nbRepetitions : SInt32;
      theMenuKeyCmd : SInt32;
      peutRepeter : boolean;
      tickEntree : SInt32;
  begin
    with gKeyDownEventsData do
      begin
        inc(niveauxDeRecursionDansDoKeyPress);

        if (niveauxDeRecursionDansDoKeyPress >= 2) and ZebraBookDemandeAccelerationDesEvenements
          then IncrementerMagicCookieOfZebraBook;

        if (niveauxDeRecursionDansDoKeyPress <= 1) or
           (enRetour or enSetUp or EnModeEntreeTranscript or gPendantLesInitialisationsDeCassio or enTournoi) then
          begin
            {WritelnDansRapport('KeyDownEvents');}

            SetRepetitionDeToucheEnCours(true);

            StoreKeyDownEvent(theEvent);
            nbRepetitions := 0;

            if debuggage.evenementsDansRapport then EcritKeyDownEventDansRapport(lastEvent);

            DiminueLatenceEntreDeuxDoSystemTask;
            AccelereProchainDoSystemTask(2);


            tickEntree := TickCount;

            repeat
              nbRepetitions := nbRepetitions + 1;
              if nbRepetitions >= 4 then
                begin
                  lastEvent.what := autoKey;
                  theEvent.what  := autoKey;
                end;

              {WritelnDansRapport('theChar = '+theChar);}

              if not((lastEvent.what = autoKey) and (TickCount < tickcountMinimalPourNouvelleRepetitionDeTouche)) then
                begin
                  if BAND(lastEvent.modifiers,cmdKey) = 0
                    then
                      begin
                        if not(iconisationDeCassio.enCours) then
                          DoKeyPress(theChar,peutRepeter);
                      end
                    else
                      if not(ToucheCommandeInterceptee(theChar,lastEvent,peutRepeter)) then
                        begin
                          FixeMarquesSurMenus;
                          {SetMenusChangeant(theEvent.modifiers);}
                          if sousEmulatorSousPC
                            then theMenuKeyCmd := MyMenuKey(theChar)
                            else
                              begin
                                theMenuKeyCmd := MenuEvent(lastEvent);
                                if HiWord(theMenuKeyCmd) = 0
                                  then theMenuKeyCmd := MenuKey(theChar);
                              end;
                          DoMenuCommand(theMenuKeyCmd,peutRepeter);
                        end;
                end;
              if peutRepeter
                then AttendrePendantRepetitionOfKeyDownEvent(peutRepeter);

            until not(peutRepeter);

            DecrementeNiveauCurseurTeteDeMort;
            SetRepetitionDeToucheEnCours(false);

            {WritelnNumDansRapport('temps passé dans KeyDownEvents = ',TickCount-tickEntree);}
          end;
        dec(niveauxDeRecursionDansDoKeyPress);


    end;
  end;


procedure KeyUpEvents;
begin
  {WritelnDansRapport('KeyUp event détecté');}
  SetRepetitionDeToucheEnCours(false);
  gKeyDownEventsData.lastEvent.message     := 0;
  gKeyDownEventsData.tickChangementClavier := TickCount;
end;


procedure MouseDownEvents;
var codeEvt : SInt16;
    LimiteRect : rect;
    ActiveeParDrag : boolean;
    whichWindow : WindowPtr;
    ResumeEventClic : boolean;
    shift,command,option,control : boolean;
    menuResult : SInt32;
    peutRepeter : boolean;
    tick : SInt32;
begin
   IncrementeCompteurDeMouseEvents;
   begin
     shift := BAND(theEvent.modifiers,shiftKey) <> 0;
     command := BAND(theEvent.modifiers,cmdKey) <> 0;
     option := BAND(theEvent.modifiers,optionKey) <> 0;
     control := BAND(theEvent.modifiers,controlKey) <> 0;

     ResumeEventClic := BAND(theEvent.modifiers,activeflag) <> 0;
     codeEvt := FindWindow(theEvent.where,whichWindow);

     if ResumeEventClic or inBackGround then   {reactivation de l'application ?}
       begin
         if whichWindow <> NIL then
           DoActivateWindow(whichWindow,true);
         if inBackGround then
           if whichWindow <> NIL then
             if WindowDeCassio(whichWindow) then
               if (whichWindow <> wPlateauPtr) and (whichWindow <> wPalettePtr)
                 then HiliteWindow(whichWindow,true)
                 else
                   begin
                     if FrontWindowSaufPalette <> NIL
                      then HiliteWindow(FrontWindowSaufPalette,true)
                      else if wPalettePtr <>  NIL then
                              HiliteWindow(wPalettePtr,true);
                   end;
         ShowTooltipWindowInCloud;
         if windowPaletteOpen then
           if not(IsWindowVisible(wPalettePtr)) and not(enSetUp or iconisationDeCassio.enCours) then
             begin
               ShowHide(wPalettePtr,true);
               DessinePalette;
             end;
         TransfererLePressePapierGlobalDansTextEdit;
         inBackGround := false;
         ResumeEventClic := true;
         RemettreLeCurseurNormalDeCassio;
       end;


      if not(ResumeEventClic) then
        CASE codeEvt of
         InMenuBar   : begin
                         FixeMarquesSurMenus;
                         SetMenusChangeant(theEvent.modifiers);
                         menuResult := MenuSelect(theEvent.where);
                         DoMenuCommand(menuResult,peutRepeter);
                       end;
         InContent   : if (whichWindow = iconisationDeCassio.theWindow) and iconisationDeCassio.encours
                        then
                          begin
                            {if EstUnDoubleClic(theEvent,true) then}
                              DeiconiserCassio;
                          end
                        else
                          begin
                            if whichWindow = wPlateauPtr
			                         then
			                           begin
			                             if (wPlateauPtr = FrontWindowSaufPalette) or WindowPlateauSousDAutresFenetres
			                               then
			                                 begin
			                                   EssaieUpdateEventsWindowPlateau;
			                                   TraiteSourisFntrPlateau(theEvent);
			                                 end
			                               else
			                                 begin
			                                   SelectWindowSousPalette(wPlateauPtr);
			                                   if windowCourbeOpen then SelectWindowSousPalette(wCourbePtr);
			                                   if windowAideOpen then SelectWindowSousPalette(wAidePtr);
			                                   if windowGestionOpen then SelectWindowSousPalette(wGestionPtr);
			                                   if windowNuageOpen then SelectWindowSousPalette(wNuagePtr);
			                                   if windowReflexOpen then SelectWindowSousPalette(wReflexPtr);
			                                   if windowListeOpen then SelectWindowSousPalette(wListePtr);
			                                   if windowStatOpen then SelectWindowSousPalette(wStatPtr);
			                                   if arbreDeJeu.windowOpen then SelectWindowSousPalette(GetArbreDeJeuWindow);
			                                 end;
			                             if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
			                           end
			                         else
			                           begin
			                             if (whichWindow <> FrontWindowSaufPalette) and (whichWindow <> wPalettePtr)
			                               then
			                                 begin
			                                   if (whichWindow <> GetArbreDeJeuWindow) and arbreDeJeu.enModeEdition
			                                     then DeactiverModeEditionFenetreArbreDeJeu;
			                                   SelectWindowSousPalette(whichWindow);
			                                   if (whichWindow = wListePtr) and (wListePtr <> NIL)
			                                     then ShowControl(MyGetRootControl(wListePtr));
			                                   if not(WindowDeCassio(FrontWindow))
			                                     then InitCursor;
			                                   AnnulerSousCriteresRuban;
			                                   if whichWindow = GetArbreDeJeuWindow then
			                                     TraiteSourisCommentaires(theEvent,true);
			                                 end
			                               else
			                                 if not(ResumeEventClic) then
			                                 begin
			                                   if whichWindow <> GetArbreDeJeuWindow then
			                                     if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
			                                   if whichWindow = wListePtr then TraiteSourisListe(theEvent);
			                                   if whichWindow = wCourbePtr then TraiteSourisCourbe(theEvent);
			                                   if whichWindow = wAidePtr then TraiteSourisAide(theEvent);
			                                   if whichWindow = wPalettePtr then TraiteSourisPalette(theEvent);
			                                   if whichWindow = wNuagePtr then TraiteSourisNuage(theEvent);
			                                   {if whichWindow = wGestionPtr then TraiteSourisGestion(theEvent);}
			                                   if whichWindow = wStatPtr then TraiteSourisStatistiques(theEvent);
			                                   if EstLaFenetreDuRapport(whichWindow) then TraiteSourisRapport(theEvent);
			                                   if whichWindow = GetArbreDeJeuWindow then TraiteSourisCommentaires(theEvent,false);
			                                 end;
			                            end;
			                        end;
         InGoAway    : IF TrackGoAway(whichWindow,theEvent.where)
                         then
                           begin
                             if whichWindow <> GetArbreDeJeuWindow then
                               if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                             AnnulerSousCriteresRuban;
                             DoClose(whichWindow,not(option));
                             if option then FermeToutesLesFenetresAuxiliaires;
                           end;
         InSysWindow : begin
                         if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                         AnnulerSousCriteresRuban;
                       end;
         inDrag      : begin
                         {if whichWindow <> GetArbreDeJeuWindow then
                           if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;}
                         AnnulerSousCriteresRuban;
                         tick := TickCount;
                         ActiveeParDrag := false;
                         if (whichWindow <> FrontWindowSaufPalette) and (whichWindow <> wPalettePtr) then
                           begin
                             ActiveeParDrag := true;
                             if BAND(theEvent.modifiers,cmdKey) = 0 then
                               begin
                                 DoActivateWindow(FrontWindowSaufPalette,false);
                                 SelectWindowSousPalette(whichWindow);
                                 DoUpdateWindow(whichWindow);
                                 DoActivateWindow(whichWindow,true);
                               end;
                           end;
                         SetRect(limiteRect,-20000,20,20000,20000);
                         {if windowPaletteOpen then ClipWindowStructFromWMPort(wPalettePtr);}
                         if StillDown then
                           begin
                             DragWindow(whichWindow,theEvent.where,@limiteRect);
                             if (whichWindow = wPlateauPtr) or (whichWindow = wListePtr) or (whichWindow = wStatPtr)
                               then SetPositionsTextesWindowPlateau;
                             if (whichWindow = wNuagePtr) and (TickCount - tick > 10) then CloseTooltipWindowInCloud;
                           end;
                         EmpileFenetresSousPalette;
                         ActiveeParDrag := ActiveeParDrag and (whichWindow = FrontWindowSaufPalette);
                         if ActiveeParDrag then
                           if (whichWindow = wListePtr) and (wListePtr <> NIL)
                             then ShowControl(MyGetRootControl(wListePtr));
                       end;
         inGrow      : begin
                         if whichWindow <> GetArbreDeJeuWindow then
                           if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                         AnnulerSousCriteresRuban;
                         if (whichWindow = FrontWindowSaufPalette) or (whichWindow = wPlateauPtr)
                           then
                             begin
                               DoGrowWindow(whichWindow,theEvent);
                               if not(enSetUp) then DoUpdateWindow(whichWindow);
                             end
                           else
                             begin
                               SelectWindowSousPalette(whichWindow);
                             end;
                        end;

         inZoomIn,inZoomOut
                   :if TrackBox(whichWindow,theEvent.where,codeEvt)
                         then
                           begin
                             if whichWindow <> GetArbreDeJeuWindow then
                               if arbreDeJeu.enModeEdition then DeactiverModeEditionFenetreArbreDeJeu;
                             AnnulerSousCriteresRuban;
                             if whichWindow = wListePtr
                               then
                                 begin
                                   (*
                                   case nbColonnesFenetreListe of
										                 kAvecAffichageDistribution        : DoChangeEcritTournoi(kAvecAffichageSeulementDesJoueurs);
										                 kAvecAffichageTournois            : DoChangeEcritTournoi(kAvecAffichageDistribution);
										                 kAvecAffichageSeulementDesJoueurs : DoChangeEcritTournoi(kAvecAffichageTournois);
										               end; {case}
										               *)

										               listeEtroiteEtNomsCourts := not(listeEtroiteEtNomsCourts);
  					                       DoChangeEcritTournoi(nbColonnesFenetreListe);
										             end
                               else
                                 if (whichWindow = iconisationDeCassio.theWindow) and iconisationDeCassio.encours
                                 then DeiconiserCassio
                                 else MyZoomInOut(whichWindow,codeEvt);
                           end;

       END;   {case codeEvt}
    if EstUnDoubleClic(theEvent,false) then DoNothing;
    DecrementeNiveauCurseurTeteDeMort;
  end;
end;


procedure MouseUpEvents;
begin
  EndLiveUndo;
end;


procedure UpdateEvents;
var whichWindow : WindowPtr;
begin
  whichWindow := WindowPtr(theEvent.message);
  if windowPaletteOpen then
    if IsWindowUpdatePending(wPalettePtr)
     then DoUpdateWindow(wPalettePtr);
  if windowPlateauOpen then
    if whichWindow <> wPlateauPtr then
      if IsWindowUpdatePending(wPlateauPtr)
        then DoUpdateWindow(wPlateauPtr);
  DoUpdateWindow(whichWindow);
end;




procedure MultiFinderEvents;
const suspend_resume_bit = $0001;
      resuming = 1;
var theFrontWindow : WindowPtr;
    bidEvent : eventRecord;
    process : ProcessSerialNumber;
    err : OSErr;
begin
  theFrontWindow := FrontWindowSaufPalette;
  if (BAND(theEvent.message,suspend_resume_bit) = resuming)
    then      {resumeEvent}
      begin

        { Make us the front process : this brings all the windows to the front }
        if (GetCurrentProcess(process) = NoErr) then
          err := SetFrontProcess(process);

        GetCurrentScript(gLastScriptUsedOutsideCassio);
        if windowPaletteOpen then
          if not(IsWindowVisible(wPalettePtr)) and not(enSetUp or iconisationDeCassio.enCours) then
            begin
              ShowHide(wPalettePtr,true);
              DessinePalette;
            end;
        if (theFrontWindow <> NIL) then
          if WindowDeCassio(theFrontWindow) then
            begin
              HiliteWindow(theFrontWindow,true);
              DoActivateWindow(theFrontWindow,true);
            end;
        inBackGround := false;
        TransfererLePressePapierGlobalDansTextEdit;
        if GetNextEvent(MDownMask,bidEvent) then DoNothing;
           { à la place de FlushEvents(MDownmask,0); }

        ShowTooltipWindowInCloud;
      end
    else      {suspend event}
      begin
        if windowPaletteOpen and not(gIsRunningUnderMacOSX) then
          if IsWindowVisible(wPalettePtr) then
             ShowHide(wPalettePtr,false);
        if theFrontWindow <> NIL then
          if WindowDeCassio(theFrontWindow) then
            begin
              HiliteWindow(theFrontWindow,false);
              DoActivateWindow(theFrontWindow,false);
            end;
        EnableKeyboardScriptSwitch;
        SwitchToScript(gLastScriptUsedOutsideCassio);
        inBackGround := true;
        if enModeIOS and (MyZeroScrap = NoErr) and (MyPutScrap(LENGTH_OF_STRING(chainePourIOS),FOUR_CHAR_CODE('TEXT'),@chainePourIOS[1]) = NoErr) then DoNothing;
        AnnulerSousCriteresRuban;
        HideTooltipWindowInCloud;
      end;
  RemettreLeCurseurNormalDeCassio;
end;


procedure ActivateEvents;
var activate : boolean;
    whichWindow : WindowPtr;
begin
  with theEvent do
  begin
    whichWindow := WindowPtr(message);
    activate := BAND(modifiers,activeflag) <> 0;
    if whichWindow <> NIL then
      if WindowDeCassio(whichWindow) then
        begin
          DoActivateWindow(whichWindow,activate);
        end;
    RemettreLeCurseurNormalDeCassio;
  end;
end;

procedure DoAppleEvents;
var err : OSErr;
begin
  {TraceLog('DoAppleEvents');}
  err := AEProcessAppleEvent(theEvent);
  {TraceLog('AEProcessAppleEvent : err = '+IntToStr(err));}
end;


function EvenementTraiteParFenetreArbreDeJeu(evt : eventRecord) : boolean;
const MachineAEcrireID = 10129;
var shift,command,option,control : boolean;
    ch : char;
    myText : TEHandle;
    texteCommande,argument : String255;
begin

  shift := BAND(evt.modifiers,shiftKey) <> 0;
  command := BAND(evt.modifiers,cmdKey) <> 0;
  option := BAND(evt.modifiers,optionKey) <> 0;
  control := BAND(evt.modifiers,controlKey) <> 0;

  with arbreDeJeu do
   begin

     ch := chr(BAND(evt.message,charCodemask));

     {les evenements de menu, ou ceux qui ne sont pas des evenements claviers,
      ne concerent certainement pas la partie commentaire de la fenetre Arbre de Jeu}
     if command or not(windowOpen) or not((evt.what = keyDown) or (evt.what = autoKey)) then
	     begin
	       EvenementTraiteParFenetreArbreDeJeu := false;
	       exit;
	     end;

	   { Si c'est un evenement clavier, on regarde si la fenetre est au premier plan}
	   if ((evt.what = keyDown) or (evt.what = autoKey)) then
	     if EnTraitementDeTexte
	       then
	         begin
	           if ((FrontWindowSaufPalette = GetRapportWindow) and FenetreRapportEstOuverte) or
	              ((FrontWindowSaufPalette = wListePtr) and FenetreListeEstEnModeEntree) or
	              (IsAnArrowKey(ch) and not(option) and windowListeOpen) then
	             begin
	               EvenementTraiteParFenetreArbreDeJeu := false;
	               exit;
	             end;
	         end
	       else
	         begin
	           if (GetArbreDeJeuWindow <> FrontWindowSaufPalette) then
	             begin
	               EvenementTraiteParFenetreArbreDeJeu := false;
	               exit;
	             end;
	         end;


	   myText := GetDialogTextEditHandle(theDialog);

	   if enModeEdition and ((ord(ch) = TabulationKey) or
	                       (ord(ch) = EscapeKey) or
	                       ((ord(ch) =  ReturnKey) and shift) or
	                       (ord(ch) = EntreeKey)) then
	     begin     {desactivation}
	       arbreDeJeu.doitResterEnModeEdition := false;
	       ValideZoneCommentaireDansFenetreArbreDeJeu;
	       DecrementeNiveauCurseurTeteDeMort;
	       EvenementTraiteParFenetreArbreDeJeu := true;

	       if (ord(ch) = EntreeKey) then
	         begin
	           if TrouveCommandeDansCommentaireDansFenetreArbreDeJeu(texteCommande,argument)
	            then
	              begin
	                ExecuteCommandeArbreDeJeu(GetCurrentNode,texteCommande,argument);
	                DrawContents(wPlateauPtr);
	              end
	            else
	              AfficheCommentairePartieDansRapport;
	         end;

		     exit;
	     end;

		 if not(enModeEdition) and (GetArbreDeJeuWindow = FrontWindowSaufPalette) and
		                     ((ord(ch) = EntreeKey) or
		                      (ord(ch) = TabulationKey)) then
		   begin     {activation}
		     ActiverModeEditionFenetreArbreDeJeu;
		     DecrementeNiveauCurseurTeteDeMort;
		     EvenementTraiteParFenetreArbreDeJeu := true;
	       exit;
		   end;

		 if (myText <> NIL) and enModeEdition then
		   begin
		     TEKey(ch,myText);
		     {if EnTraitementDeTexte and avecSon then PlaySoundSynchrone(MachineAEcrireID, 128);}
		     SetCommentairesCurrentNodeFromFenetreArbreDeJeu;
		     EvenementTraiteParFenetreArbreDeJeu := true;
		     DecrementeNiveauCurseurTeteDeMort;
		     exit;
		   end;

		 EvenementTraiteParFenetreArbreDeJeu := false;
	   exit;
	end;
end;

procedure MetFlagsModifiersDernierEvenement(var whichEvent : eventRecord; var modifiersChanged : boolean);
var oldShift,oldCommand,oldOption,oldControl,oldVerouillage : boolean;
begin
  modifiersChanged := false;
  with DernierEvenement do
    begin
      oldShift        := shift;
      oldCommand      := command;
      oldOption       := option;
      oldControl      := control;
      oldVerouillage  := verouillage;

      with whichEvent do
      begin
        shift := BAND(modifiers,shiftKey) <> 0;
        command := BAND(modifiers,cmdKey) <> 0;
        option := BAND(modifiers,optionKey) <> 0;
        control := BAND(modifiers,controlKey) <> 0;
        verouillage := BAND(modifiers,alphaLock) <> 0;
      end;

      if (oldShift <> shift)       or
         (oldCommand <> command)   or
         (oldOption <> option)     or
         (oldControl <> control)   or
         (oldVerouillage <> verouillage) then
       begin
         modifiersChanged := true;
         AjusteCurseur;
         DiminueLatenceEntreDeuxDoSystemTask;
         AccelereProchainDoSystemTask(60);
       end;
    end;
end;








END.
