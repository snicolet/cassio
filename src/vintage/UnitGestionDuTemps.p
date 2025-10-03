UNIT UnitGestionDuTemps;


INTERFACE








 USES UnitDefCassio;



{Initialisation de l'unite}
procedure InitUnitGestionDuTemps;                                                                                                                                                   ATTRIBUTE_NAME('InitUnitGestionDuTemps')
procedure LibereMemoireGestionDuTemps;                                                                                                                                              ATTRIBUTE_NAME('LibereMemoireGestionDuTemps')


{ Temps alloue pour un coup, en fonction du temps restant a la pendule}
function TempsRestantPendule(couleur : SInt16) : SInt32;                                                                                                                            ATTRIBUTE_NAME('TempsRestantPendule')
function TempsPourCeCoup(n,couleur : SInt16) : SInt32;                                                                                                                              ATTRIBUTE_NAME('TempsPourCeCoup')
function CalculeTempsAlloueEnFinale(CoulPourMeilleurFin : SInt16) : SInt32;                                                                                                         ATTRIBUTE_NAME('CalculeTempsAlloueEnFinale')
procedure TestDepassementTemps;                                                                                                                                                     ATTRIBUTE_NAME('TestDepassementTemps')
procedure EcritOopsMaPenduleDansRapport;                                                                                                                                            ATTRIBUTE_NAME('EcritOopsMaPenduleDansRapport')
procedure DerniereHeure(couleur : SInt32);                                                                                                                                          ATTRIBUTE_NAME('DerniereHeure')
procedure SetDateEnTickDuCoupNumero(numero,date : SInt32);                                                                                                                          ATTRIBUTE_NAME('SetDateEnTickDuCoupNumero')
function GetDateEnTickDuCoupNumero(numero : SInt32) : SInt32;                                                                                                                       ATTRIBUTE_NAME('GetDateEnTickDuCoupNumero')


{ Cadence de la partie}
procedure SetCadence(cadence : SInt32);                                                                                                                                             ATTRIBUTE_NAME('SetCadence')
function GetCadence : SInt32;                                                                                                                                                       ATTRIBUTE_NAME('GetCadence')
procedure AjusteCadenceMin(cadence : SInt32);                                                                                                                                       ATTRIBUTE_NAME('AjusteCadenceMin')
procedure Heure(couleur : SInt16);                                                                                                                                                  ATTRIBUTE_NAME('Heure')
procedure SetCadenceAutreQueAnalyse(cadenceAutreQueAnalyse : SInt32; avecJeuInstantane : boolean);                                                                                  ATTRIBUTE_NAME('SetCadenceAutreQueAnalyse')
function GetCadenceAutreQueAnalyse : SInt32;                                                                                                                                        ATTRIBUTE_NAME('GetCadenceAutreQueAnalyse')
function GetJeuInstantaneAutreQueAnalyse : boolean;                                                                                                                                 ATTRIBUTE_NAME('GetJeuInstantaneAutreQueAnalyse')


{ Changements d'etats }
procedure InvalidateAnalyseDeFinale;                                                                                                                                                ATTRIBUTE_NAME('InvalidateAnalyseDeFinale')
procedure InvalidateAnalyseDeFinaleSiNecessaire(mode : InvalidateMode);                                                                                                             ATTRIBUTE_NAME('InvalidateAnalyseDeFinaleSiNecessaire')
procedure ActiverAttenteAnalyseDeFinale(whichPos : PositionEtTraitRec; bestMove,bestDef : SInt32; dessinee : boolean);                                                              ATTRIBUTE_NAME('ActiverAttenteAnalyseDeFinale')
procedure SetSuggestionDeFinaleEstDessinee(flag : boolean);                                                                                                                         ATTRIBUTE_NAME('SetSuggestionDeFinaleEstDessinee')
procedure AjusteEtatGeneralDeCassioApresChangementDeCadence;                                                                                                                        ATTRIBUTE_NAME('AjusteEtatGeneralDeCassioApresChangementDeCadence')



{ Pour savoir si Cassio a terminé l'analyse de la position }
function AttenteAnalyseDeFinaleDansPositionCourante : boolean;                                                                                                                      ATTRIBUTE_NAME('AttenteAnalyseDeFinaleDansPositionCourante')
function AttenteAnalyseDeFinaleEstActive : boolean;                                                                                                                                 ATTRIBUTE_NAME('AttenteAnalyseDeFinaleEstActive')
function SuggestionAnalyseDeFinaleEstDessinee : boolean;                                                                                                                            ATTRIBUTE_NAME('SuggestionAnalyseDeFinaleEstDessinee')
function GetBestMoveAttenteAnalyseDeFinale : SInt32;                                                                                                                                ATTRIBUTE_NAME('GetBestMoveAttenteAnalyseDeFinale')
function GetBestDefenseAttenteAnalyseDeFinale : SInt32;                                                                                                                             ATTRIBUTE_NAME('GetBestDefenseAttenteAnalyseDeFinale')
function EstLeCoupParfaitAfficheCommeSuggestionDeFinale(whichMove : SInt32) : boolean;                                                                                              ATTRIBUTE_NAME('EstLeCoupParfaitAfficheCommeSuggestionDeFinale')



{ Un drapeau simple que Cassio levera quand il sera en train de calculer }
procedure SetCassioEstEnTrainDeReflechir(newvalue : boolean; oldValue : BooleanPtr);                                                                                                ATTRIBUTE_NAME('SetCassioEstEnTrainDeReflechir')
function CassioEstEnTrainDeReflechir : boolean;                                                                                                                                     ATTRIBUTE_NAME('CassioEstEnTrainDeReflechir')
function CassioDoitReflechirSurLeTempsAdverse : boolean;                                                                                                                            ATTRIBUTE_NAME('CassioDoitReflechirSurLeTempsAdverse')
function CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration(var config : ConfigurationCassioRec) : boolean;                                                                 ATTRIBUTE_NAME('CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration')
function CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante : boolean;                                                                                                   ATTRIBUTE_NAME('CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante')
procedure SetReveillerRegulierementLeMac(flag : boolean);                                                                                                                           ATTRIBUTE_NAME('SetReveillerRegulierementLeMac')
function GetReveillerRegulierementLeMac : boolean;                                                                                                                                  ATTRIBUTE_NAME('GetReveillerRegulierementLeMac')


{ Temps donné au système d'exploitation }
procedure AjusteSleep;                                                                                                                                                              ATTRIBUTE_NAME('AjusteSleep')
function CassioVaJouerInstantanement : boolean;                                                                                                                                     ATTRIBUTE_NAME('CassioVaJouerInstantanement')
procedure SetDelaiAvantDoSystemTask(newValue : SInt32; fonctionAppelante : String255);                                                                                              ATTRIBUTE_NAME('SetDelaiAvantDoSystemTask')
procedure DiminueLatenceEntreDeuxDoSystemTask;                                                                                                                                      ATTRIBUTE_NAME('DiminueLatenceEntreDeuxDoSystemTask')
procedure AccelereProchainDoSystemTask(nbTicksMax : SInt32);                                                                                                                        ATTRIBUTE_NAME('AccelereProchainDoSystemTask')
procedure DoSystemTask(couleur : SInt32);                                                                                                                                           ATTRIBUTE_NAME('DoSystemTask')
procedure PartagerLeTempsMachineAvecLesAutresProcess(WNESleep : SInt32);                                                                                                            ATTRIBUTE_NAME('PartagerLeTempsMachineAvecLesAutresProcess')
procedure Wait(secondes : double_t);                                                                                                                                                ATTRIBUTE_NAME('Wait')


{ Temporisations avant de jouer }
function DoitTemporiserPourRetournerLesPions : boolean;                                                                                                                             ATTRIBUTE_NAME('DoitTemporiserPourRetournerLesPions')
procedure SetDelaiDeRetournementDesPions(nouveauDelai : SInt32);                                                                                                                    ATTRIBUTE_NAME('SetDelaiDeRetournementDesPions')
function GetDelaiDeRetournementDesPions : SInt32;                                                                                                                                   ATTRIBUTE_NAME('GetDelaiDeRetournementDesPions')
procedure TemporisationSolitaire;                                                                                                                                                   ATTRIBUTE_NAME('TemporisationSolitaire')
procedure TemporisationArnaqueFinale;                                                                                                                                               ATTRIBUTE_NAME('TemporisationArnaqueFinale')
procedure TemporisationRetournementDesPions;                                                                                                                                        ATTRIBUTE_NAME('TemporisationRetournementDesPions')


{ Gestion des interruptions }
procedure LanceInterruption(typeInterruption : SInt16; const fonctionAppelante : String255);                                                                                        ATTRIBUTE_NAME('LanceInterruption')
procedure LanceInterruptionSimple(const fonctionAppelante : String255);                                                                                                             ATTRIBUTE_NAME('LanceInterruptionSimple')
procedure LanceInterruptionConditionnelle(typeInterruption : SInt16; const message : String255; value : SInt32; const fonctionAppelante : String255);                               ATTRIBUTE_NAME('LanceInterruptionConditionnelle')
procedure LanceInterruptionSimpleConditionnelle(const fonctionAppelante : String255);                                                                                               ATTRIBUTE_NAME('LanceInterruptionSimpleConditionnelle')
procedure EnleveCetteInterruption(typeInterruption : SInt16);                                                                                                                       ATTRIBUTE_NAME('EnleveCetteInterruption')
function GetCurrentInterruption : SInt16;                                                                                                                                           ATTRIBUTE_NAME('GetCurrentInterruption')
procedure EffectueTacheInterrompante(var interruptionEnCours : SInt16);                                                                                                             ATTRIBUTE_NAME('EffectueTacheInterrompante')
procedure LanceDemandeDeChangementDeConfig(typeInterruption : SInt16; value : SInt32; const fonctionAppelante : String255);                                                         ATTRIBUTE_NAME('LanceDemandeDeChangementDeConfig')
procedure GererDemandesChangementDeConfig;                                                                                                                                          ATTRIBUTE_NAME('GererDemandesChangementDeConfig')



{ Les 'interruptions brutales' permettent de s'assurer que Cassio ne renvoie pas un coup legal à la fin d'un calcul }
procedure LanceDemandeInterruptionBrutale;                                                                                                                                          ATTRIBUTE_NAME('LanceDemandeInterruptionBrutale')
function DemandeInterruptionBrutaleEnCours : boolean;                                                                                                                               ATTRIBUTE_NAME('DemandeInterruptionBrutaleEnCours')
procedure SetDemandeInterruptionBrutaleEnCours(flag : boolean);                                                                                                                     ATTRIBUTE_NAME('SetDemandeInterruptionBrutaleEnCours')
procedure GererDemandeInterruptionBrutaleEnCours;                                                                                                                                   ATTRIBUTE_NAME('GererDemandeInterruptionBrutaleEnCours')
procedure TraiteInterruptionBrutale(var coup,reponse : SInt32; fonctionAppelante : String255);                                                                                      ATTRIBUTE_NAME('TraiteInterruptionBrutale')


{ Cassio doit-il tester tous les evenements classiques ? }
procedure SetCassioChecksEvents(flag : boolean);                                                                                                                                    ATTRIBUTE_NAME('SetCassioChecksEvents')
function GetCassioChecksEvents : boolean;                                                                                                                                           ATTRIBUTE_NAME('GetCassioChecksEvents')


{ Etalonnage de la vitesse du Mac }
function CalculVitesseMac(afficherDansRapport : boolean) : SInt32;                                                                                                                  ATTRIBUTE_NAME('CalculVitesseMac')
procedure EtalonnageVitesseMac(afficherDansRapport : boolean);                                                                                                                      ATTRIBUTE_NAME('EtalonnageVitesseMac')


{ Dialogue du choix de la cadence pour la partie }
function FiltreCadenceDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;                                                                                 ATTRIBUTE_NAME('FiltreCadenceDialog')
procedure DoCadence;                                                                                                                                                                ATTRIBUTE_NAME('DoCadence')


{ Fenetre de gestion du temps }
procedure SetValeursGestionTemps(alloue,effectif,prevu : SInt32; divergence : double_t; prof,suivante : SInt16);                                                                    ATTRIBUTE_NAME('SetValeursGestionTemps')
procedure SetValeurTempsAlloueDansGestionTemps(alloue : SInt32);                                                                                                                    ATTRIBUTE_NAME('SetValeurTempsAlloueDansGestionTemps')
procedure EcritGestionTemps;                                                                                                                                                        ATTRIBUTE_NAME('EcritGestionTemps')
procedure LanceChronoCetteProf;                                                                                                                                                     ATTRIBUTE_NAME('LanceChronoCetteProf')
procedure LanceChrono;                                                                                                                                                              ATTRIBUTE_NAME('LanceChrono')
procedure LanceDecompteDesNoeuds;                                                                                                                                                   ATTRIBUTE_NAME('LanceDecompteDesNoeuds')
procedure AffichageNbreNoeuds;                                                                                                                                                      ATTRIBUTE_NAME('AffichageNbreNoeuds')


{ Etat du reseau dans la fenetre de gestion du temps }
procedure AfficheEtatDuReseau(message : String255);                                                                                                                                 ATTRIBUTE_NAME('AfficheEtatDuReseau')
function GetLastEtatDuReseauAffiche : String255;                                                                                                                                    ATTRIBUTE_NAME('GetLastEtatDuReseauAffiche')
procedure SetDateDernierEnvoiRequeteSurReseau(date : SInt32);                                                                                                                           ATTRIBUTE_NAME('SetDateDernierEnvoiRequeteSurReseau')
function GetDateDerniereRequeteSurReseau : SInt32;                                                                                                                                  ATTRIBUTE_NAME('GetDateDerniereRequeteSurReseau')
procedure SetMessageEtatDuReseau(message : String255);                                                                                                                              ATTRIBUTE_NAME('SetMessageEtatDuReseau')
procedure SetReseauEstVivant(vivant : boolean);                                                                                                                                     ATTRIBUTE_NAME('SetReseauEstVivant')
procedure BouclerUnPeuAvantDeQuitterEnSurveillantLeReseau(nbreDeTicks : SInt32);                                                                                                    ATTRIBUTE_NAME('BouclerUnPeuAvantDeQuitterEnSurveillantLeReseau')


{ Reveil régulier du mac }
procedure DoReveilDuMac;                                                                                                                                                            ATTRIBUTE_NAME('DoReveilDuMac')





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, fp, Sound, MacWindows, QuickdrawText, Fonts, UnitDefEngine, UnitDefParallelisme
{$IFC NOT(USE_PRELINK)}
    , Zebra_to_Cassio, MyQuickDraw, UnitPositionEtTrait, UnitAffichageReflexion, UnitRapport, UnitCurseur, UnitJeu
    , UnitEntreeTranscript, UnitSound, UnitLiveUndo, UnitDialog, UnitUtilitaires, MyStrings, UnitPhasesPartie, UnitRetrograde
    , UnitSolitairesNouveauFormat, UnitMilieuDePartie, UnitPrefs, UnitListe, UnitJaponais, UnitRapportImplementation, UnitScripts, UnitCarbonisation
    , UnitProblemeDePriseDeCoin, UnitFenetres, UnitInterversions, MyMathUtils, UnitParallelisme, SNEvents, UnitGeometrie, UnitEvenement
    , UnitModes, UnitAffichagePlateau, UnitCommentaireArbreDeJeu, UnitRegressionLineaire, UnitModes, UnitZoo, UnitActions, UnitCFNetworkHTTP
    , UnitZooAvecArbre, UnitCarbonisation, UnitBaseNouveauFormat, UnitBaseOfficielle, UnitEngine, UnitCouleur, UnitRechercheSolitaires ;
{$ELSEC}
    ;
    {$I prelink/GestionDuTemps.lk}
{$ENDC}


{END_USE_CLAUSE}





var
  attenteAnalyseDeFinale : record
                             activee            : boolean;
                             suggestionDessinee : boolean;
                             position           : PositionEtTraitRec;
                             bestMove           : SInt32;
                             bestDefense        : SInt32;
                           end;

  gCassioEstEnTrainDeReflechir : boolean;
  gMouseRegionForWaitNextEvent : RgnHandle;

  gCadence : SInt32;
  gCadenceAutreQueModeAnalyse : SInt32;
  gJeuInstantaneAutreQueAnalyse : boolean;
  gCadencesRadios : RadioRec;

  reveilRegulierDuMac : record
                          necessaire : boolean;
                          tickDerniereFois : SInt32;
                        end;

  delaiDeRetournementDesPions : SInt32;
  gDateDesCoups : array[0..60] of SInt32;

  gDemandesChangementsDeConfig :
      record
        flags                  : SInt32;
        humCtreHumVoulu        : boolean;
        couleurMacintoshVoulue : SInt32;
      end;

 gDemandeInterruptionBrutaleEnCours : boolean;




var gEtatDuReseau : record
                      messageAffiche            : String255;
                      dateMessageAffiche        : SInt32;
                      derniereRequeteZooEnvoyee : LongString;
                      dateDerniereRequeteZoo    : SInt32;
                      nbreRequetesSansReponse   : SInt32;
                      dateDernierAffichageEtat  : SInt32;
                      
                      statsZoo : record
                                   dateDernierAffichageStats : SInt32;
                                   nbrePositionsPrefetched : SInt32;
                                   profMin : SInt32;
                                   profMax : SInt32;
                                   tempsTotal : double_t;
                                   tempsDeMidgame : double_t;
                                   tempsUtile : double_t;
                                   tempsPositionCourante : double_t;
                                   nbrePositions : SInt32;
                                   nbrePositionsTriviales : SInt32;
                                   nbrePositionsMilieu : SInt32;
                                   nbrePositionsEnAttente : SInt32;
                                 end;
                    end;


const gEnTrainDeBouclerPourSurveillerLeReseau : boolean = false;




procedure InitUnitGestionDuTemps;
var myTinyRect : rect;
begin
  gMouseRegionForWaitNextEvent := NIL;

  gMouseRegionForWaitNextEvent := NewRgn;
  SetRect(myTinyRect, 10, 10, 20, 20);
	RectRgn (gMouseRegionForWaitNextEvent, myTinyRect);

	SetDemandeInterruptionBrutaleEnCours(false);

	with gEtatDuReseau do
	  begin
	    messageAffiche            := '';
	    dateMessageAffiche        := TickCount;
	    dateDerniereRequeteZoo    := TickCount;
	    nbreRequetesSansReponse   := 0;
	  end;
	
	with gEtatDuReseau.statsZoo do
	   begin
	     dateDernierAffichageStats := -1;
       nbrePositionsPrefetched   := -1;
       profMin                   := -1;
       profMax                   := -1;
       tempsTotal                := -1.0;
       tempsDeMidgame            := -1.0;
       tempsUtile                := -1.0;
       tempsPositionCourante     := -1.0;
       nbrePositions             := -1;
       nbrePositionsTriviales    := -1;
       nbrePositionsMilieu       := -1;
       nbrePositionsEnAttente    := -1;
     end;
end;


procedure LibereMemoireGestionDuTemps;
begin
  if gMouseRegionForWaitNextEvent <> NIL then
    begin
      DisposeRgn(gMouseRegionForWaitNextEvent);
      gMouseRegionForWaitNextEvent := NIL;
    end;
end;



procedure DoSystemTask(couleur : SInt32);
var gotEvent : boolean;
    deltaRes,deltaJob,deltaPing : SInt32;
    temps : double_t;
begin

  GererLiveUndo;

  FaireClignoterFenetreArbreDeJeu;

  TraiterDemandesDeVisiteDesPartiesDuNuage;

  CheckStreamEvents;

  EnvoyerUnKeepAliveSiNecessaire;

  GererTelechargementWThor;

  GererRapportSafe;

  if not(gameOver) | CassioEstEnTrainDeCalculerPourLeZoo then
    begin

      {gotEvent := HasGotEvent(EveryEvent,theEvent,kWNESleep,gMouseRegionForWaitNextEvent);}
      gotEvent := HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL);


      if gotEvent
        then
          begin
            TraiteEvenements;
          end
        else
          begin
            TraiteNullEvent(theEvent);
            AjusteCurseur;
          end;

      with reveilRegulierDuMac do
        if necessaire & ((TickCount-tickDerniereFois) >= 3600) {plus d'une minute ?}
          then DoReveilDuMac;

      if ((TickCount - dernierTick) >= 60) | ((TickCount - gEtatDuReseau.dateDernierAffichageEtat) >= 60)
        then AfficheEtatDuReseau(GetLastEtatDuReseauAffiche);

      if ((nbreCoup >= 1) | CassioEstEnTrainDeTracerLeNuage | CassioEstEnTrainDeCalculerPourLeZoo) &
         ((TickCount-dernierTick) >= 60)
        then
    	    begin
    	      latenceEntreDeuxDoSystemTask := latenceEntreDeuxDoSystemTask + 1;
    	      if latenceEntreDeuxDoSystemTask > 30 then latenceEntreDeuxDoSystemTask := 30;



    	      if CassioIsWaitingAnEngineResult then
    	        begin
    	          temps := (TickCount-dernierTick) / 60.0 ;  // temps en secondes depuis le dernier affichage
    	          if (engine.lastSearchSent.utilisationDansCassio = ReflMilieu)
    	            then
    	              begin
    	                nbreNoeudsGeneresMilieu := nbreNoeudsGeneresMilieu + MyTrunc((1000 * GetSpeedOfEngine * temps));
    	                nbreFeuillesMilieu      := nbreFeuillesMilieu +  MyTrunc((1000 * GetSpeedOfEngine * temps));
    	              end
    	            else nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale + MyTrunc((1000 * GetSpeedOfEngine * temps));
    	        end;

    	      if (nbreCoup >= 1) & not(enRetour) then
    	        Heure(couleur);

    	      if (gEnRechercheSolitaire |
                gEnEntreeSortieLongueSurLeDisque |
                CassioEstEnTrainDeTracerLeNuage |
                CassioEstEnTrainDeReflechir |
                CassioEstEnTrainDeCalculerPourLeZoo)
                then dernierTick := TickCount;

    	      if (phaseDeLaPartie >= phaseFinale) then
    	        while (nbreNoeudsGeneresFinale > 1000000000) do
    	          begin
    	            nbreNoeudsGeneresFinale := nbreNoeudsGeneresFinale - 1000000000;
    	            inc(nbreToursNoeudsGeneresFinale);
    	          end;

    	      while (nbreNoeudsGeneresMilieu > 1000000000) do
              begin
                nbreNoeudsGeneresMilieu := nbreNoeudsGeneresMilieu - 1000000000;
                inc(nbreToursNoeudsGeneresMilieu);
              end;

    	      while (nbreFeuillesMilieu > 1000000000) do
              begin
                nbreFeuillesMilieu := nbreFeuillesMilieu - 1000000000;
                inc(nbreToursFeuillesMilieu);
              end;

    	      if afficheGestionTemps then AffichageNbreNoeuds;

    	      TestDepassementTemps;
    	    end
    	  else
    	    begin

    	      if (nbreCoup <= 0) & (gEnRechercheSolitaire |
    	                            gEnEntreeSortieLongueSurLeDisque |
    	                            CassioEstEnTrainDeTracerLeNuage  |
    	                            CassioEstEnTrainDeReflechir |
    	                            CassioEstEnTrainDeCalculerPourLeZoo)
    	        then dernierTick := TickCount;

    	    end;

      with affichageReflexion do
        if doitAfficher & demandeEnSuspend &
           ((Tickcount - tickDernierAffichageReflexion) >= 25) {toutes les demi secondes environ}
           then EcritReflexion('DoSystemTask');


      if (TickCount - DateOfLastKeyDownEvent < 60)
         & (HumCtreHum
            | (not(analyseRetrograde.enCours)
               & (windowListeOpen | windowStatOpen)
               & ZebraBookACetteOption(kAfficherNotesZebraSurOthellier + kAfficherCouleursZebraSurOthellier + kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre)))
        then SetDelaiAvantDoSystemTask(delaiAvantDoSystemTask + (latenceEntreDeuxDoSystemTask div 10), 'DoSystemTask {1}')
        else SetDelaiAvantDoSystemTask(delaiAvantDoSystemTask + latenceEntreDeuxDoSystemTask , 'DoSystemTask {2}');




      (*
      if CassioEstEnTrainDeCalculerPourLeZoo & (delaiAvantDoSystemTask > 15)
        then SetDelaiAvantDoSystemTask(15, 'DoSystemTask {3}');
      *)


     { si on peut travailler pour le zoo, que l'on vient d'envoyer un resulat
       au zoo et que l'on attend un nouveau job (ou que l'on vient de faire un ping),
       il faut enchainer les calculs donc on va regarder les evenements plus souvent, hein }

     deltaRes  := Tickcount - DateDernierEnvoiDeResultatAuZoo;
     deltaJob  := Tickcount - DateDerniereDemandeDeJobAuZoo;
     deltaPing := TickCount - DateDernierPingAuZoo;

     if (delaiAvantDoSystemTask > 2) &
        (((deltaRes <= 100) & (deltaJob <= 100)) | (deltaPing <= 200)) &
        CassioPeutDonnerDuTempsAuZoo & CassioDoitRentrerEnContactAvecLeZoo
        then
          begin
            {WritelnDansRapport('accel delai !');}
            SetDelaiAvantDoSystemTask(2, 'DoSystemTask {4}');
          end;

      GererLiveUndo;

      if (DemandeCalculsPourBase.EtatDesCalculs = kCalculsDemandes) & not(CassioVaJouerInstantanement)
        then TraiteDemandeCalculsPourBase('DoSystemTask');

      if gDemandeAffichageZebraBook.enAttente
          then TraiteDemandeAffichageZebraBook;

  end;
  
  VerifierLeStatutDeCassioPourLeZoo;

  VerifierUtiliteCalculPourLeZoo(true);

  EcouterLesResultatsDuZoo;

end;


procedure AjusteSleep;
var CassioReflechitIntensement : boolean;
    oldkWNESleep : SInt32;
    deltaRes,deltaJob,deltaPing : SInt32;
    x : double_t;
begin
  oldkWNESleep := kWNESleep;

  if CassioIsWaitingAnEngineResult & (interruptionReflexion = pasdinterruption) & not(Quitter)
    then
      begin
        {WritelnDansRapport('0');}
        x := DurationOfLastResultReceivedByEngine;
        if (x < 0.02) & (Tickcount - DateOfLastActivityByEngine <= 1)
          then kWNESleep := 1
          else
            if (x < 0.2)
              then kWNESleep := 1
              else kWNESleep := 2;
        exit(AjusteSleep);
      end;

  if Quitter | humainVeutAnnuler | (interruptionReflexion <> pasdinterruption) | CassioEstEnTrainDeCalculerLaListe |
     gEnRechercheSolitaire | gEnEntreeSortieLongueSurLeDisque | RechercheDeProblemeDePriseDeCoinEnCours |
     CassioEstEnTrainDeLireLaBibliothequeDeZebra | ZebraBookDemandeAccelerationDesEvenements | CassioEstEnTrainDeTracerLeNuage |
     UtilisateurEstEnTrainDeSurvolerLeNuage | enTournoi | CassioEstEnTrainDeCorrigerUnTranscript |
     ((CassioEstEnTrainDeCalculerPourLeZoo | CassioEstEnTrainDeReflechir) & not(enRetour | enSetUp))
    then
      begin
        kWNESleep := 0;   { Cassio gets 100% CPU }
        {WritelnDansRapport('1');}
      end
    else
      begin
        CassioReflechitIntensement := CassioEstEnTrainDeReflechir | CassioEstEnTrainDeCalculerPourLeZoo;
        if LiveUndoEnCours
          then
            begin
              if CassioReflechitIntensement
                then kWNESleep := 0
                else kWNESleep := 1;
              {WritelnDansRapport('2');}
            end
          else
            begin
              if gameOver | enSetUp | enRetour | (nbreCoup <= 0) |
                 ((AQuiDeJouer <> couleurMacintosh) & not(CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante) & not(CassioEstEnModeAnalyse) & not(CassioReflechitIntensement)) |
                 (not(CassioReflechitIntensement) & AttenteAnalyseDeFinaleDansPositionCourante)
                then
                  begin
                    if (gEtatDuReseau.nbreRequetesSansReponse > 1)
                      then kWNESleep := 2
                      else kWNESleep := 15;
                    {WritelnDansRapport('3');}
                  end
                else
                  if HumCtreHum |
                     ((AQuiDeJouer <> couleurMacintosh) & (reponsePrete | (nbreCoup <= 0)) & not(CassioReflechitIntensement))
                    then
                      begin
                        if (gEtatDuReseau.nbreRequetesSansReponse > 1)
                          then kWNESleep := 2
                          else kWNESleep := 15;
                        {WritelnDansRapport('4');}
                      end
                    else
                      begin
                        kWNESleep := 0;  { Cassio gets 100% CPU }
                        {WritelnDansRapport('5');}
                      end;
            end;
      end;


  { si on peut travailler pour le zoo, que l'on vient d'envoyer un resulat
    au zoo et que l'on attend un nouveau job (ou que l'on vient de faire un ping),
    il faut enchainer les calculs donc on ne va pas trop dormir, hein }

  deltaRes  := Tickcount - DateDernierEnvoiDeResultatAuZoo;
  deltaJob  := Tickcount - DateDerniereDemandeDeJobAuZoo;
  deltaPing := TickCount - DateDernierPingAuZoo;

  if (kWNESleep > 2) &
     (((deltaRes <= 100) & (deltaJob <= 100)) | (deltaPing <= 200)) &
     CassioPeutDonnerDuTempsAuZoo & CassioDoitRentrerEnContactAvecLeZoo
     then kWNESleep := 2;
       
  
  if (kWNESleep > 0) & (deltaRes <= 2) &
     CassioPeutDonnerDuTempsAuZoo & CassioDoitRentrerEnContactAvecLeZoo &
     (NumberOfPrefetch > 0)
     then
       begin
         // WritelnNumDansRapport('deltaRes = ',deltaRes);
         kWNESleep := 0;
       end;

  if (kWNESleep > 2) & CassioPeutDonnerDuTempsAuZoo & CassioDoitRentrerEnContactAvecLeZoo
    then kWNESleep := 2;

  (*
  if (kWNESleep <> oldkWNESleep) then
    begin
      WritelnNumDansRapport('oldkWNESleep = ',oldkWNESleep);
      WritelnNumDansRapport('kWNESleep = ',kWNESleep);
    end;
  *)
  
end;



procedure SetCadence(cadence : SInt32);
begin
  gCadence := cadence;
end;


function GetCadence : SInt32;
begin
  GetCadence := gCadence;
end;


procedure SetCadenceAutreQueAnalyse(cadenceAutreQueAnalyse : SInt32; avecJeuInstantane : boolean);
begin
  if (cadenceAutreQueAnalyse <> minutes10000000) &
     (cadenceAutreQueAnalyse >= minutes3) then
    begin
      gCadenceAutreQueModeAnalyse   := cadenceAutreQueAnalyse;
      gJeuInstantaneAutreQueAnalyse := avecJeuInstantane;
    end;
end;


function GetCadenceAutreQueAnalyse : SInt32;
begin
  GetCadenceAutreQueAnalyse := gCadenceAutreQueModeAnalyse;
end;


function GetJeuInstantaneAutreQueAnalyse : boolean;
begin
  GetJeuInstantaneAutreQueAnalyse := gJeuInstantaneAutreQueAnalyse;
end;


procedure AjusteCadenceMin(cadence : SInt32);
begin
  case cadence of
    minutes3        : cadenceMin := 3;
    minutes5        : cadenceMin := 5;
    minutes10       : cadenceMin := 10;
    minutes25       : cadenceMin := 25;
    minutes1440     : cadenceMin := 1440;
    minutes48000    : cadenceMin := 48000;
    minutes10000000 : cadenceMin := 10000000;
    otherwise         cadenceMin := cadence div 60;
  end;
end;


{temps alloue, en secondes}
function CalculeTempsAlloueEnFinale(CoulPourMeilleurFin : SInt16) : SInt32;
var allocationTemps : SInt32;
begin
  if analyseRetrograde.enCours
	  then allocationTemps := analyseRetrograde.demande[nbreCoup,analyseRetrograde.numeroPasse].tempsAlloueParCoup
	  else
	    if not(neJamaisTomber)
	      then allocationTemps := 1000000000
	      else
	       if RefleSurTempsJoueur
	         then allocationTemps := RoundToL(0.6*TempsRestantPendule(couleurMacintosh))
	         else allocationTemps := RoundToL(0.6*TempsRestantPendule(CoulPourMeilleurFin));
  CalculeTempsAlloueEnFinale := allocationTemps;
end;


{ renvoie (en secondes) le temps alloue pour le coup n }
function TempsPourCeCoup(n,couleur : SInt16) : SInt32;
var nbCoupRestant : SInt32;
    tempsEcoule : SInt32;
    aux,foo : SInt32;
begin
  if analyseRetrograde.enCours & (n >= 0) & (n <= 60)
    then
      begin
        TempsPourCeCoup := analyseRetrograde.demande[n,analyseRetrograde.numeroPasse].tempsAlloueParCoup
      end
    else
      begin
        if GetCadence = minutes10000000
          then TempsPourCeCoup := minutes10000000  {temps infini}
          else
            begin
			        tempsEcoule := (tempsDesJoueurs[couleur].minimum * 60) + tempsDesJoueurs[couleur].sec;
			        if CassioIsUsingAnEngine(foo)
			          then nbCoupRestant := (45 - n) div 2
			          else nbCoupRestant := (55 - n) div 2;
						  if nbCoupRestant <> 0
						    then aux := (GetCadence - tempsEcoule) div nbCoupRestant
						    else aux := 10;
						  if (aux <= 1) & enTournoi then aux := 2;
						  if (aux <= 0) then aux := 5;
						  TempsPourCeCoup := aux;
						end;
			end;
end;

{ renvoie (en secondes) le temps restant}
function TempsRestantPendule(couleur : SInt16) : SInt32;
var tempsEcoule : SInt32;
    aux : SInt32;
begin
  tempsEcoule := tempsDesJoueurs[couleur].minimum*60+tempsDesJoueurs[couleur].sec;
  aux := 60*cadenceMin-tempsEcoule;
  if aux <= 0 then aux := 0;
  TempsRestantPendule := aux;
end;


procedure InvalidateAnalyseDeFinale;
begin
  attenteAnalyseDeFinale.activee            := false;
  attenteAnalyseDeFinale.position           := MakeEmptyPositionEtTrait;
  attenteAnalyseDeFinale.bestMove           := 0;
	attenteAnalyseDeFinale.bestDefense        := 0;
	SetSuggestionDeFinaleEstDessinee(false);
end;


procedure ActiverAttenteAnalyseDeFinale(whichPos : PositionEtTraitRec; bestMove,bestDef : SInt32; dessinee : boolean);
begin
  attenteAnalyseDeFinale.activee            := true;
  attenteAnalyseDeFinale.position           := whichPos;
  attenteAnalyseDeFinale.bestMove           := bestMove;
	attenteAnalyseDeFinale.bestDefense        := bestDef;
	SetSuggestionDeFinaleEstDessinee(dessinee);
end;


procedure SetSuggestionDeFinaleEstDessinee(flag : boolean);
begin
  attenteAnalyseDeFinale.suggestionDessinee := flag;
end;


procedure InvalidateAnalyseDeFinaleSiNecessaire(mode : InvalidateMode);
begin

  (* ATTENTION : BIEN PENSER A MODIFIER AUSSI TypeDeCalculLanceParCassioDansCetteConfiguration
                 SI ON CHANGE QUELQUE CHOSE DANS CETTE ROUTINE  !!
  *)

  if attenteAnalyseDeFinale.activee | (mode = kForceInvalidate) then
    begin
      if (mode = kForceInvalidate) | HumCtreHum | (AQuiDeJouer <> couleurMacintosh) |
         not(CassioEstEnModeAnalyse) | not(AttenteAnalyseDeFinaleDansPositionCourante) then
        begin
          InvalidateAnalyseDeFinale;
          ReinitilaliseInfosAffichageReflexion;
          EffaceReflexion(HumCtreHum);
        end;
    end;
end;


function AttenteAnalyseDeFinaleEstActive : boolean;
begin
  AttenteAnalyseDeFinaleEstActive := attenteAnalyseDeFinale.activee;
end;


function SuggestionAnalyseDeFinaleEstDessinee : boolean;
begin
  SuggestionAnalyseDeFinaleEstDessinee := attenteAnalyseDeFinale.suggestionDessinee;
end;


function EstLeCoupParfaitAfficheCommeSuggestionDeFinale(whichMove : SInt32) : boolean;
begin
  if afficheSuggestionDeCassio &
     SuggestionAnalyseDeFinaleEstDessinee &
    (GetBestMoveAttenteAnalyseDeFinale = whichMove) &
     AttenteAnalyseDeFinaleDansPositionCourante
    then EstLeCoupParfaitAfficheCommeSuggestionDeFinale := true
    else EstLeCoupParfaitAfficheCommeSuggestionDeFinale := false;
end;


function AttenteAnalyseDeFinaleDansPositionCourante : boolean;
begin
  AttenteAnalyseDeFinaleDansPositionCourante  :=
      attenteAnalyseDeFinale.activee &
      EstLaPositionCourante(attenteAnalyseDeFinale.position);
end;


function GetBestMoveAttenteAnalyseDeFinale : SInt32;
begin
  GetBestMoveAttenteAnalyseDeFinale := attenteAnalyseDeFinale.bestMove;
end;


function GetBestDefenseAttenteAnalyseDeFinale : SInt32;
begin
  GetBestDefenseAttenteAnalyseDeFinale := attenteAnalyseDeFinale.bestDefense;
end;


procedure SetCassioEstEnTrainDeReflechir(newvalue : boolean; oldValue : BooleanPtr);
begin
  if (oldValue <> NIL) then
    oldValue^ := gCassioEstEnTrainDeReflechir;
  gCassioEstEnTrainDeReflechir := newValue;
end;


function CassioEstEnTrainDeReflechir : boolean;
begin
  CassioEstEnTrainDeReflechir := gCassioEstEnTrainDeReflechir;
end;

function CassioDoitReflechirSurLeTempsAdverse : boolean;
begin
  CassioDoitReflechirSurLeTempsAdverse := not(sansReflexionSurTempsAdverse);
end;


function CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration(var config : ConfigurationCassioRec) : boolean;
var doitReflechir : boolean;
begin
  with config do
    begin
      if jeuEstInstantane & (niveauDeJeuInstantane < NiveauGrandMaitres) & (nombreDeCoupsJoues <= 40)
        then doitReflechir := false
        else doitReflechir := not(sansReflexionSurTempsAdversaire);
    end;
  CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration := doitReflechir;
end;


function CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante : boolean;
var config : ConfigurationCassioRec;
begin
  GetConfigurationCouranteDeCassio(config);
  CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante := CassioDoitReflechirSurLeTempsAdverseDansCetteConfiguration(config);
end;


 
procedure SetCassioChecksEvents(flag : boolean);
begin
  gCassioChecksEvents := flag;
end;

function GetCassioChecksEvents : boolean;
begin
  GetCassioChecksEvents := gCassioChecksEvents;
end;


function CalculVitesseMac(afficherDansRapport : boolean) : SInt32;
var tickDepart,lastTick,newTick : SInt32;
    compteur,resultat,nbToursCompteur : SInt32;
    a,b : SInt32;
begin
   (**    indice de vitesse
           < 10   : MacClassic
          = 13   : Powerbook 100
          = 30   : IIci
          = 51   : PowerBook 150
          = 100  : Quadra
          = 2700 : PowerMac 6400 a 200 MgH
          = 7700 : PowerMac 6400 a 200 MgH, avec carte Sonnet G3/L2 a 400 MgH

   Note : les variables a,b et le test  < Abs(a-b) < 0)  >
          sont la pour etre des opérations realistes
          typiques de Cassio. Si on les change, verifier
          que l'optimisateur du compilateur ne supprime *pas*
          ce code inutile **)

  compteur := 0;
  nbToursCompteur := 0;
  a := 0;
  b := 5000;
  lastTick := TickCount;
  tickDepart := lastTick;

  {attendre un nouveau tick}
  repeat until (TickCount <> lastTick);

  {puis faire la boucle de test pendant 30 ticks (0.5 seconde)}
  repeat
    inc(compteur);
    {on essaie d'eviter les gags d'overflow sur compteur}
    if (compteur > 1000000) then
      begin
        inc(nbToursCompteur);
        compteur := 0;
      end;
    (* code typique *)
    if (compteur > b) | ((BAnd((compteur - 30) , 1023) <> 0))
       then a := 2*compteur;

    {autre code typique : gestion du temps }
    newTick := TickCount;
    if (newTick <> lastTick) then
      begin
        lastTick := newTick;
        if HasGotEvent(everyEvent,theEvent,0,NIL) then
          begin
            TraiteOneEvenement;
            AccelereProchainDoSystemTask(1);
          end;
      end;

  until ((TickCount-tickDepart) > 30) | (Abs(a-b) < 0);

  resultat := 1000*nbToursCompteur + ((compteur + 500) div 1000);

  if afficherDansRapport then
    begin
      WritelnDansRapport('CalculVitesseMac :');
      WritelnNumDansRapport('   compteur = ',compteur);
      WritelnNumDansRapport('   nbToursCompteur = ',nbToursCompteur);
      WritelnNumDansRapport('   resultat = ',resultat);
    end;

  CalculVitesseMac := resultat;
end;


{ Calcul du coup declanchement de la finale en fonction de la vitesse du Mac.
  Cette routine est basee sur une hypothese de divergence 3 pour les finales }
procedure EtalonnageVitesseMac(afficherDansRapport : boolean);
var vitesse : SInt32;
begin
  vitesse := indiceVitesseMac;

  finDePartieVitesseMac := 41;           {apres ce coup}
  finDePartieOptimaleVitesseMac := 43;   {apres ce coup}

  if vitesse >= 13 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-2;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-2;
    end;
  if vitesse >= 32 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 90 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 270 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 810 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 2430 then  {note : vitesse = 2800 environ sur PowerMac 6400 @ 200MgH }
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 7290 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 21870 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 65610 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 196830 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 590490 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 1771470 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;
  if vitesse >= 5314410 then
    begin
     finDePartieVitesseMac := finDePartieVitesseMac-1;
     finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac-1;
    end;

  if debuggage.general & windowPlateauOpen then
    begin
      SetPortByWindow(wPlateauPtr);
      WriteNumAt('EtalonnageVitesseMac :  indiceVitesseMac = ',vitesse,100,100);
      WriteNumAt('finale gagnante au coup ',finDePartieVitesseMac+1,100,120);
      WriteNumAt('finale parfaite au coup ',finDePartieOptimaleVitesseMac+1,100,132);
      WriteStringAt('tapez une touche, svp ',100,144);
      SysBeep(0);
      AttendFrappeClavier;
    end;

  if afficherDansRapport then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('EtalonnageVitesseMac  :');
      WritelnNumDansRapport('    indiceVitesseMac = ',vitesse);
      WritelnNumDansRapport('    finale gagnante au coup ',finDePartieVitesseMac+1);
      WritelnNumDansRapport('    finale parfaite au coup ',finDePartieOptimaleVitesseMac+1);
      WritelnDansRapport('');
    end;
end;


procedure TemporisationSolitaire;
var temporisation,nbCasesVidesRestantes : SInt32;
    hazard,tick : SInt32;
    dateDuDernierCoup,delta : SInt32;
begin

  nbCasesVidesRestantes := 60-nbreCoup;

  { on definit une certaine temporisation "abstraite",
    qui augmente avec le nbre de cases vides, et qui
    a une certaine irregularite (aleatoire) }
  if nbCasesVidesRestantes > 10 then temporisation := 250;
  if nbCasesVidesRestantes = 10 then temporisation := 130;
  if nbCasesVidesRestantes = 9 then temporisation := 65;
  if nbCasesVidesRestantes = 8 then temporisation := 40;
  if nbCasesVidesRestantes = 7 then temporisation := 20;
  if nbCasesVidesRestantes < 7 then temporisation := 10;
  if nbCasesVidesRestantes < 5 then temporisation := 2;
  hazard := temporisation div 2;
  if hazard > 0 then
    temporisation := temporisation + (Abs(Random) mod MyTrunc(1.4*hazard)) - (hazard div 3);

  {convertir cette temporisation "abstraite" en ticks}
  temporisation := MyTrunc((70.0*temporisation)/indiceVitesseMac);


  if temporisation > 240  then temporisation := 240;  {4 sec.}
  if temporisation < 10   then temporisation := 10;    {1/6eme de sec}

  if (nbreCoup >= 0) & (nbreCoup <= 60) & (partie <> NIL) then
    begin
      dateDuDernierCoup := partie^^[nbreCoup].tickDuCoup;

      if (dateDuDernierCoup > 0) then
        begin
          delta := TickCount - dateDuDernierCoup;
          if delta >= temporisation
            then temporisation := 0
            else temporisation := temporisation - delta;
        end;
    end;

  tick := TickCount;
  repeat
    if EventAvail(everyEvent,theEvent) then DoNothing;
  until TickCount-tick > temporisation;
end;


procedure TemporisationArnaqueFinale;
var temporisation : SInt16;
    tick : SInt32;
begin
  temporisation := 22;
  tick := TickCount;
  repeat
    if EventAvail(everyEvent,theEvent) then DoNothing;
  until TickCount-tick > temporisation;
end;


function DoitTemporiserPourRetournerLesPions : boolean;
var enleverTemporisation : SInt32;
begin

  DoitTemporiserPourRetournerLesPions := true;

  enleverTemporisation := 0;

  if not(avecDelaiDeRetournementDesPions)
    then enleverTemporisation := 1;

  if (Abs(TickCount - DateOfLastKeyDownEvent) < 60) &
     (HumCtreHum | (nbreCoup > 1)) then
    begin
      enleverTemporisation := 2;
      (* WritelnNumDansRapport('DateOfLastKeyDownEvent = ',DateOfLastKeyDownEvent);
      WritelnNumDansRapport('TickCount = ',TickCount);
      WritelnNumDansRapport('nbreCoup = ',nbreCoup);
      *)
    end;

  if RepetitionDeToucheEnCours
    then enleverTemporisation := 3;

  if (AQuiDeJouer <> couleurMacintosh)
    then enleverTemporisation := 4;

  if GetCadence >= minutes5
    then enleverTemporisation := 5;

  if HumCtreHum
    then enleverTemporisation := 6;

  if not(jeuInstantane)
    then enleverTemporisation := 7;

  if enTournoi
    then enleverTemporisation := 8;

  if Quitter
    then enleverTemporisation := 9;

  {WritelnNumDansRapport('enleverTemporisation = ',enleverTemporisation);}

  if (enleverTemporisation <> 0) then DoitTemporiserPourRetournerLesPions := false;

end;


procedure TemporisationRetournementDesPions;
var temporisation : SInt16;
    tick : SInt32;
begin

  if not(DoitTemporiserPourRetournerLesPions)
    then exit(TemporisationRetournementDesPions);

  SetDelaiDeRetournementDesPions(7);
  temporisation := GetDelaiDeRetournementDesPions;
  if (temporisation > 0) then
    begin
      tick := TickCount;
      repeat
        if EventAvail(everyEvent,theEvent) then DoNothing;
      until TickCount-tick > temporisation;
    end;
end;



procedure SetDelaiDeRetournementDesPions(nouveauDelai : SInt32);
begin
  delaiDeRetournementDesPions := nouveauDelai;
end;


function GetDelaiDeRetournementDesPions : SInt32;
begin
  GetDelaiDeRetournementDesPions := delaiDeRetournementDesPions;
end;




function CassioVaJouerInstantanement : boolean;
var choice,bestDef : SInt32;
begin
  if not(HumCtreHum) & not(CassioEstEnModeAnalyse) &
     (AQuiDeJouer = couleurMacintosh) & not(enTournoi) & not(Quitter) & not(gameOver) then
    begin
      if reponsePrete & (phaseDeLaPartie >= phaseFinale) & not(CassioEstEnModeSolitaire) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car reponsePrete)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;

      if jeuInstantane & (phaseDeLaPartie <= phaseMilieu) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car jeuInstantane)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;

      if (nbreCoup >= 45) & (phaseDeLaPartie >= phaseFinale) & (phaseDeLaPartie < phaseFinale) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car nbreCoup >= 50)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;

      if (nbreCoup >= 50) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car nbreCoup >= 50)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;

      if (phaseDeLaPartie >= phaseFinale) & ((interruptionReflexion = pasdinterruption) | vaDepasserTemps) &
         ConnaitSuiteParfaite(choice,bestDef,false) then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car ConnaitSuiteParfaite)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;

      if vaDepasserTemps then
        begin
          {WritelnDansRapport('CassioVaJouerInstantanement := true (car vaDepasserTemps)');}
          CassioVaJouerInstantanement := true;
          exit(CassioVaJouerInstantanement);
        end;
    end;

  {WritelnDansRapport('CassioVaJouerInstantanement := false');}
  CassioVaJouerInstantanement := false;
end;

procedure EnleveCetteInterruption(typeInterruption : SInt16);
begin
  if BAnd(interruptionReflexion,typeInterruption) <> 0 then
    begin
      if debuggage.gestionDuTemps then
        begin
          WritelnDansRapport('');
          WriteDansRapport('EnleveCetteInterruption : type');
          EcritTypeInterruptionDansRapport(typeInterruption);
        end;

      interruptionReflexion := BXOr(interruptionReflexion,typeInterruption);
      if BAnd(typeInterruption,interruptionDepassementTemps) <> 0
        then vaDepasserTemps := false;

    end;
end;


procedure LanceInterruption(typeInterruption : SInt16; const fonctionAppelante : String255);
begin

  interruptionReflexion := BOr(interruptionReflexion,typeInterruption);

  if BAnd(typeInterruption,interruptionDepassementTemps) <> 0
    then vaDepasserTemps := true;


  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('LanceInterruption (fonction appelante = ' + fonctionAppelante + ')');
      WriteDansRapport('   => type ');
      EcritTypeInterruptionDansRapport(typeInterruption);
    end;

  (*
  if (typeInterruption <> pasdinterruption) then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('LanceInterruption (fonction appelante = ' + fonctionAppelante + ')');
      WriteDansRapport('   => type ');
      EcritTypeInterruptionDansRapport(typeInterruption);
    end;
  *)
  
end;



procedure LanceInterruptionSimple(const fonctionAppelante : String255);
begin
  LanceDemandeInterruptionBrutale;
  LanceInterruption(interruptionSimple, 'LanceInterruptionSimple:'+fonctionAppelante);
end;


procedure DumpConfigDansRapport(var config : ConfigurationCassioRec);
begin
  with config do
    begin
       WritelnNumDansRapport('  c.interruption = ',interruption);
       WritelnNumDansRapport('  c.nombreDeCoupsJoues = ',nombreDeCoupsJoues);
       WritelnNumDansRapport('  c.niveauDeJeuInstantane = ',niveauDeJeuInstantane);
       WritelnNumDansRapport('  c.trait = ',trait);
       WritelnNumDansRapport('  c.couleurDeCassio = ',couleurDeCassio);
       WritelnStringAndBooleanDansRapport('  c.partieEstFinie = ',partieEstFinie);
       WritelnStringAndBooleanDansRapport('  c.humainContreHumain = ',humainContreHumain);
       WritelnStringAndBooleanDansRapport('  c.CassioDoitQuitter = ',CassioDoitQuitter);
       WritelnStringAndBooleanDansRapport('  c.positionEstFeerique = ',positionEstFeerique);
       WritelnStringAndBooleanDansRapport('  c.CassioVaDepasserSonTemps = ',CassioVaDepasserSonTemps);
       WritelnStringAndBooleanDansRapport('  c.sansReflexionSurTempsAdversaire = ',sansReflexionSurTempsAdversaire);
       WritelnStringAndBooleanDansRapport('  c.laReponseEstPrete = ',laReponseEstPrete);
       WritelnStringAndBooleanDansRapport('  c.enModeAnalyse = ',enModeAnalyse);
       WritelnStringAndBooleanDansRapport('  c.attenteAnalyseDeFinaleActivee = ',attenteAnalyseDeFinaleActivee);
       WritelnStringAndBooleanDansRapport('  c.attenteEnPosCourante = ',attenteEnPosCourante);
    end;
end;


procedure LanceInterruptionConditionnelle(typeInterruption : SInt16; const message : String255; value : SInt32; const fonctionAppelante : String255);
var config : ConfigurationCassioRec;
    typeDeCalculALancer : SInt32;
    lancee : boolean;
begin
  lancee := false;

  if not(CassioEstEnTrainDeCalculerPourLeZoo)
    then
      begin
        lancee := true;
        if (typeInterruption = interruptionSimple)
          then LanceInterruptionSimple(fonctionAppelante)
          else LanceInterruption(typeInterruption,fonctionAppelante);
      end
    else
      begin
        if BAnd(interruptionReflexion, typeInterruption) = 0 then
          begin
            GetConfigurationCouranteDeCassio(config);

            ChangeConfiguration(config, message, value);
            typedeCalculALancer := TypeDeCalculLanceParCassioDansCetteConfiguration(config);

            if (typedeCalculALancer <> k_AUCUN_CALCUL) 
              then
                begin
                  if (typeInterruption = interruptionSimple) & 
                     (jeuInstantane & (NiveauJeuInstantane < NiveauGrandMaitres) & (nbreCoup <= 40))
                     then
                       begin
                         if typedeCalculALancer = k_PREMIER_COUP_MAC then PremierCoupMac;
                         if typedeCalculALancer = k_JEU_MAC then JeuMac(level,'LanceInterruptionConditionnelle:'+fonctionAppelante);
                       end
                     else
                       begin
                         lancee := true;
                         if (typeInterruption = interruptionSimple)
                           then LanceInterruptionSimple(fonctionAppelante)
                           else LanceInterruption(typeInterruption,fonctionAppelante);
                       end;
                end
              else
                begin
                  {DumpConfigDansRapport(config);
                  WritelnDansRapport('  =>  pas la peine d''interrompre ('+fonctionAppelante+')');
                  }
                end;
          end;
      end;

   if not(lancee) then
     begin
       case typeInterruption of

         kHumainVeutChangerHumCtreHum :
           LanceDemandeDeChangementDeConfig(kHumainVeutChangerHumCtreHum, SInt32(config.humainContreHumain), fonctionAppelante);

         kHumainVeutChangerCouleur :
           LanceDemandeDeChangementDeConfig(kHumainVeutChangerCouleur, config.couleurDeCassio, fonctionAppelante);

         kHumainVeutChangerCoulEtHumCtreHum :
           begin
             LanceDemandeDeChangementDeConfig(kHumainVeutChangerCouleur, config.couleurDeCassio, fonctionAppelante);
             LanceDemandeDeChangementDeConfig(kHumainVeutChangerHumCtreHum, SInt32(config.humainContreHumain), fonctionAppelante);
           end;
       end; {case}
     end;
end;


procedure LanceInterruptionSimpleConditionnelle(const fonctionAppelante : String255);
begin
  LanceInterruptionConditionnelle(interruptionSimple,'',0,fonctionAppelante);
end;


function GetCurrentInterruption : SInt16;
begin
  GetCurrentInterruption := interruptionReflexion;
end;





procedure LanceDemandeDeChangementDeConfig(typeInterruption : SInt16; value : SInt32; const fonctionAppelante : String255);
begin {$unused fonctionAppelante}
  case typeInterruption of
    kHumainVeutChangerHumCtreHum :
      begin
        gDemandesChangementsDeConfig.flags           := gDemandesChangementsDeConfig.flags or kHumainVeutChangerHumCtreHum;
        gDemandesChangementsDeConfig.humCtreHumVoulu := Boolean(value);
      end;
    kHumainVeutChangerCouleur :
      begin
        gDemandesChangementsDeConfig.flags := gDemandesChangementsDeConfig.flags or kHumainVeutChangerCouleur;
        gDemandesChangementsDeConfig.couleurMacintoshVoulue := value;
      end;
    otherwise WritelnNumDansRapport('ASSERT !! typeInterruption inconnu dans LanceDemandeDeChangementDeConfig,  typeInterruption = ',typeInterruption);
  end; {case}
end;


procedure GererDemandesChangementDeConfig;
var compteur : SInt32;
begin
  compteur := 0;

  while (compteur < 20) & (gDemandesChangementsDeConfig.flags <> 0) do
    begin
      inc(compteur);

      if BAnd(gDemandesChangementsDeConfig.flags, kHumainVeutChangerHumCtreHum) <> 0 then
        begin
          gDemandesChangementsDeConfig.flags := BXOr(gDemandesChangementsDeConfig.flags, kHumainVeutChangerHumCtreHum);
          if (HumCtreHum <> gDemandesChangementsDeConfig.humCtreHumVoulu)
            then DoChangeHumCtreHum;
        end;

      if BAnd(gDemandesChangementsDeConfig.flags, kHumainVeutChangerCouleur) <> 0 then
        begin
          gDemandesChangementsDeConfig.flags := BXOr(gDemandesChangementsDeConfig.flags, kHumainVeutChangerCouleur);
          if (couleurMacintosh <> gDemandesChangementsDeConfig.couleurMacintoshVoulue)
            then DoChangeCouleur;
        end;
    end;
end;

procedure DiminueLatenceEntreDeuxDoSystemTask;
begin
  latenceEntreDeuxDoSystemTask := 2;
end;


const yAff : SInt32 = 10;

procedure SetDelaiAvantDoSystemTask(newValue : SInt32; fonctionAppelante : String255);
begin

  {$UNUSED fonctionAppelante}

  Discard(fonctionAppelante);

  if newValue > 60 then newValue := 60;

  delaiAvantDoSystemTask := newValue;


  (*
  if (newValue > 20) | (newValue = 2) then
    begin
      yAff := yAff + 10;
      if yAff > 800 then yAff := 10;

      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourHeure;
      WriteStringAt('delai = '+NumEnString(newValue)+' , latence = '+NumEnString(latenceEntreDeuxDoSystemTask)+',   fonctionAppelante = '+fonctionAppelante+'                                   ', 800, yAff);
    end;
  *)

end;


procedure AccelereProchainDoSystemTask(nbTicksMax : SInt32);
var avantProchaineSeconde : SInt32;
begin
  {avantProchaineSeconde := 60- ((TickCount - dernierTick) + 1);}

  avantProchaineSeconde := ((TickCount - dernierTick) + 1);

  if (delaiAvantDoSystemTask > nbTicksMax)
    then SetDelaiAvantDoSystemTask(nbTicksMax, 'AccelereProchainDoSystemTask {1}');

  if delaiAvantDoSystemTask > avantProchaineSeconde
    then SetDelaiAvantDoSystemTask(avantProchaineSeconde, 'AccelereProchainDoSystemTask {2}');



   {SetDelaiAvantDoSystemTask(2,'');  est bien aussi, sauf pour l'analyse retrograde}

end;



procedure Heure(couleur : SInt16);
var aux,seco : SInt32;
    s,s1,s2 : String255;
    oldPort : grafPtr;
    heuresAffichees : boolean;
    ligneRect : rect;

  procedure TraduitMinEnFormat_hhmm(nbmin : SInt32; var chaine : String255);
  var nbheures : SInt32;
      s2 : String255;
  begin
    if (nbmin >= 60) & not((GetCadence = minutes10000000) & decrementetemps)
      then
        begin
          heuresAffichees := true;
          nbheures := nbmin div 60;
          s2 := NumEnString(nbheures);
          nbmin := nbmin mod 60;
          chaine := NumEnString(nbmin);
          if nbmin < 10 then chaine := StringOf('0')+chaine;
          chaine := s2+': '+chaine;
        end
      else
        begin
          heuresAffichees := false;
          chaine := NumEnString(nbmin);
        end;
  end;

begin
  if windowPlateauOpen & not(enRetour) then
    begin
      aux := TickCount-dernierTick;
      dernierTick := TickCount-(aux mod 60);
      AccelereProchainDoSystemTask(60);
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      with tempsDesJoueurs[couleur] do
        begin
          if aux < 200 then
            begin
              seco := sec+ (aux div 60);
              sec := seco mod 60;
              minimum := minimum+ (seco div 60);
              tempsReflexionMac := tempsReflexionMac+60;
              tempsReflexionCetteProf := tempsReflexionCetteProf+60;
            end;
          if sec < 0 then
             repeat
               minimum := minimum-1;
               sec := sec+60;
             until (sec >= 0);
          if decrementetemps then
          begin
            if cadenceMin-1-minimum < 0 then
              begin
                TraduitMinEnFormat_hhmm(minimum-cadenceMin,s1);
                s2 := NumEnString(sec);
                if sec < 10 then s2 := StringOf('0')+s2;
                s := StringOf('-')+s1+': '+s2;
              end
              else
              if sec = 0
                then
                  begin
                    TraduitMinEnFormat_hhmm(cadenceMin-minimum,s1);
                    s := s1+': 00'
                  end
                else
                  begin
                    TraduitMinEnFormat_hhmm(cadenceMin-minimum-1,s1);
                    s2 := NumEnString(60-sec);
                    if 60-sec < 10 then s2 := StringOf('0')+s2;
                    s := s1+': '+s2;
                  end;
            end
          else  {if decrementetemps then...}
            begin
              TraduitMinEnFormat_hhmm(minimum,s1);
              s2 := NumEnString(sec);
              if sec < 10 then s2 := StringOf('0')+s2;
              s := s1+': '+s2;
            end;
        end;


      if not(EnModeEntreeTranscript | enSetUp) then
        begin
          PrepareTexteStatePourHeure;
          case couleur of
              pionBlanc :
                begin
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                    then SetRect(lignerect,posHblancs,posVblancs+1,posHblancs+67,posVblancs+10)
                    else SetRect(lignerect,posHblancs,posVblancs+1,posHblancs+67,posVblancs+12);
                  EraseRectDansWindowPlateau(lignerect);
                  if (GetCadence <> minutes10000000) & not(heuresAffichees) then
                    OffsetRect(lignerect,5,0);
                  Moveto(lignerect.left,lignerect.bottom);
                  if (GetCadence = minutes10000000) & decrementetemps
                    then
                      begin
                        TextFace(normal);
                        MyDrawString(s);
                        if NePasUtiliserLeGrasFenetreOthellier
    							        then TextFace(normal)
    							        else TextFace(bold);
                      end
                    else
                      MyDrawString(s);
                end;
              pionNoir  :
                begin
                  if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                    then SetRect(lignerect,posHNoirs,posVNoirs+1,posHNoirs+67,posVNoirs+10)
                    else SetRect(lignerect,posHNoirs,posVNoirs+1,posHNoirs+67,posVNoirs+12);
                  EraseRectDansWindowPlateau(lignerect);
                  if (GetCadence <> minutes10000000) & not(heuresAffichees) then
                    OffsetRect(lignerect,5,0);
                  Moveto(lignerect.left,lignerect.bottom);
                  if (GetCadence = minutes10000000) & decrementetemps
                    then
                      begin
                        TextFace(normal);
                        MyDrawString(s);
                        if NePasUtiliserLeGrasFenetreOthellier
                          then TextFace(normal)
                          else TextFace(bold);
                      end
                    else
                      MyDrawString(s);
                end;
          end; {case...}

          if gCassioUseQuartzAntialiasing then
            if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;
        end;

      with tempsDesJoueurs[couleur] do
        if sec = 0 then
          if cadenceMin-minimum = 0 then
            if not(HumCtreHum) & (couleur = -couleurMacintosh) & avecSon then
              if not(analyseRetrograde.enCours | enTournoi | gGongDejaSonneDansCettePartie) then
              begin
                PlaySoundSynchrone(kSonGongID, kVolumeSonDesCoups);
                dernierTick := TickCount;
                gGongDejaSonneDansCettePartie := true;
              end;


      /// Afficher les spin-locks du parallelisme

      {AfficherLesSpinlocksDuParallelisme;}


      SetPort(oldPort);
    end;
end;



function FiltreCadenceDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
const
    BoutonDebutant = 4;
    BoutonAmateur = 5;
    BoutonClub = 6;
    BoutonFort = 7;
    BoutonExpert = 8;
    BoutonGrandMaitre = 9;
    BoutonChampion = 10;
    Bouton3minutes = 11;
    Bouton5minutes = 12;
    Bouton10minutes = 13;
    Bouton25minutes = 14;
    BoutonUnMois = 15;
    BoutonInfini = 16;
    BoutonAutre = 17;
    TextHeures = 18;
    StaticHeures = 19;
    TextMinutes = 20;
begin
  FiltreCadenceDialog := false;
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        keyDown,autoKey :
         begin
          if (BAnd(evt.message,charcodemask) = FlecheHautKey) then  {fleche en haut}
            begin
              case gCadencesRadios.selection of
                 BoutonDebutant    : item := BoutonDebutant;
                 BoutonAmateur     : item := BoutonDebutant;
                 BoutonClub        : item := BoutonAmateur;
                 BoutonFort        : item := BoutonClub;
                 BoutonExpert      : item := BoutonFort;
                 BoutonGrandMaitre : item := BoutonExpert;
                 BoutonChampion    : item := BoutonGrandMaitre;
                 Bouton3minutes    : item := BoutonChampion;
                 Bouton5minutes    : item := Bouton3minutes;
                 Bouton10minutes   : item := Bouton5minutes;
                 Bouton25minutes   : item := Bouton10minutes;
                 BoutonUnMois      : item := Bouton25minutes;
                 BoutonInfini      : item := BoutonUnMois;
                 BoutonAutre       : item := BoutonInfini;
              end;
              FiltreCadenceDialog := true;
            end
            else
            if (BAnd(evt.message,charcodemask) = FlecheBasKey) then  {fleche en bas}
              begin
                case gCadencesRadios.selection of
                   BoutonDebutant    : item := BoutonAmateur;
                   BoutonAmateur     : item := BoutonClub;
                   BoutonClub        : item := BoutonFort;
                   BoutonFort        : item := BoutonExpert;
                   BoutonExpert      : item := BoutonGrandMaitre;
                   BoutonGrandMaitre : item := BoutonChampion;
                   BoutonChampion    : item := Bouton3minutes;
                   Bouton3minutes    : item := Bouton5minutes;
                   Bouton5minutes    : item := Bouton10minutes;
                   Bouton10minutes   : item := Bouton25minutes;
                   Bouton25minutes   : item := BoutonUnMois;
                   BoutonUnMois      : item := BoutonInfini;
                   BoutonInfini      : item := BoutonAutre;
                   BoutonAutre       : item := BoutonAutre;
                end;
                FiltreCadenceDialog := true;
              end
              else FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item);
             end
          otherwise FiltreCadenceDialog := MyFiltreClassique(dlog,evt,item)
     end;   {case}
end;


procedure AjusteEtatGeneralDeCassioApresChangementDeCadence;
begin

  AjusteCadenceMin(GetCadence);

  if (GetCadence >= minutes5)
    then jeuInstantane := false;

  dernierTick := TickCount;
  Heure(pionNoir);
  Heure(pionBlanc);

  DetermineMomentFinDePartie;
  tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
  humanWinningStreak  := 0;
  humanScoreLastLevel := 0;


  {si Cassio reflechissait sur son temps, peut-etre faut-il l'accélérer}
  if not(HumCtreHum) & (AQuiDeJouer = couleurMacintosh) then
    begin
      if (phaseDeLaPartie <= phaseMilieu) & (((tempsPrevu div 60) > tempsAlloue) | jeuInstantane) then
        if PeutArreterAnalyseRetrograde then
          DoForcerMacAJouerMaintenant;
    end;

  {si Cassio reflechissait sur le temps adverse et que l'on passe en analyse, on l'arrete}
  if not(HumCtreHum) & (AQuiDeJouer <> couleurMacintosh) & (nbreCoup > 0) &
     (GetCadence = minutes10000000) then
    begin
      if PeutArreterAnalyseRetrograde then
        LanceInterruptionSimple('DoCadence');
    end;

  EcritPromptFenetreReflexion;
end;


procedure DoCadence;
  const
    OK = 1;
    Annuler = 2;
    BoutonDebutant = 4;
    BoutonAmateur = 5;
    BoutonClub = 6;
    BoutonFort = 7;
    BoutonExpert = 8;
    BoutonGrandMaitre = 9;
    BoutonChampion = 10;
    Bouton3minutes = 11;
    Bouton5minutes = 12;
    Bouton10minutes = 13;
    Bouton25minutes = 14;
    BoutonUnMois = 15;
    BoutonInfini = 16;
    BoutonAutre = 17;
    TextHeures = 18;
    StaticHeures = 19;
    TextMinutes = 20;
    StaticMinutes = 21;
    CompteAReboursBox = 22;
    NeJamaisTomberBox = 23;
  var dp : DialogPtr;
      itemHit : SInt16;
      FiltreCadenceDialogUPP : ModalFilterUPP;
      err : OSErr;
      SelectionInitiale : record
                          BoutonRadioCadence : SInt16;
                          CompteRebours : boolean;
                          JamaisTomberAuTemps : boolean;
                        end;
      s,s1 : String255;
      i : SInt16;
      unlong : SInt32;
      nouveauJeuInstantane : boolean;


  procedure ChangeCadence(Radios : RadioRec);
    var aux : SInt32;
    begin
      GetItemTextInDialog(dp,TextHeures,s);
      ChaineToLongint(s,aux);
      cadencePersoAffichee := 3600*aux;
      GetItemTextInDialog(dp,TextMinutes,s);
      ChaineToLongint(s,aux);
      cadencePersoAffichee := cadencePersoAffichee+60*aux;
      case Radios.selection of
         BoutonDebutant    : SetCadence(minutes3);
         BoutonAmateur     : SetCadence(minutes3);
         BoutonClub        : SetCadence(minutes3);
         BoutonFort        : SetCadence(minutes3);
         BoutonExpert      : SetCadence(minutes3);
         BoutonGrandMaitre : SetCadence(minutes3);
         BoutonChampion    : SetCadence(minutes3);
         Bouton3minutes    : SetCadence(minutes3);
         Bouton5minutes    : SetCadence(minutes5);
         Bouton10minutes   : SetCadence(minutes10);
         Bouton25minutes   : SetCadence(minutes25);
         BoutonUnMois      : SetCadence(minutes48000);
         BoutonInfini      : SetCadence(minutes10000000);
         BoutonAutre       : SetCadence(cadencePersoAffichee);
       end;
    end;


  begin
    with gCadencesRadios do
      begin
        firstButton := BoutonDebutant;
        lastButton := BoutonAutre;
        if jeuInstantane
          then
            case NiveauJeuInstantane of
              NiveauDebutants    : selection := BoutonDebutant;
              NiveauAmateurs     : selection := BoutonAmateur;
              NiveauClubs        : selection := BoutonClub;
              NiveauForts        : selection := BoutonFort;
              NiveauExperts      : selection := BoutonExpert;
              NiveauGrandMaitres : selection := BoutonGrandMaitre;
              NiveauChampions    : selection := BoutonChampion;
            end
          else
            case GetCadence of
              minutes3          : selection := Bouton3minutes;
              minutes5          : selection := Bouton5minutes;
              minutes10         : selection := Bouton10minutes;
              minutes25         : selection := Bouton25minutes;
              minutes48000      : selection := BoutonUnMois;
              minutes10000000   : selection := BoutonInfini;
              otherWise           selection := BoutonAutre;
            end;
      end;
    SelectionInitiale.BoutonRadioCadence  := gCadencesRadios.selection;
    SelectionInitiale.CompteRebours       := decrementetemps;
    SelectionInitiale.JamaisTomberAuTemps := neJamaisTomber;

    BeginDialog;
    FiltreCadenceDialogUPP := NewModalFilterUPP(FiltreCadenceDialog);
    dp := MyGetNewDialog(CadenceDialogID);
    if dp <> NIL then
    begin
      s := NumEnString((cadencePersoAffichee+31) div 3600);
      SetItemTextInDialog(dp,TextHeures,s);
      s := NumEnString(((cadencePersoAffichee+31) mod 3600) div 60);
      SetItemTextInDialog(dp,TextMinutes,s);
      InitRadios(dp,gCadencesRadios);
      ChangeCadence(gCadencesRadios);
      SetBoolCheckBox(dp,NeJamaisTomberBox,SelectionInitiale.JamaisTomberAuTemps);
      SetBoolCheckBox(dp,CompteAReboursBox,SelectionInitiale.CompteRebours);


      if (FntrCadenceRect.right - FntrCadenceRect.left > 0) then MoveWindow(GetDialogWindow(dp),FntrCadenceRect.left,FntrCadenceRect.top,false);
      ShowWindow(GetDialogWindow(dp));
      MyDrawDialog(dp);
      OutlineOK(dp);

      err := SetDialogTracksCursor(dp,true);

      repeat
        ModalDialog(FiltreCadenceDialogUPP,itemHit);
        if (itemHit <> OK) & (itemHit <> Annuler) then
          begin

            if (itemHit >= gCadencesRadios.firstButton) & (itemHit <= gCadencesRadios.lastButton)
             then PushRadio(dp,gCadencesRadios,itemHit);

            if (itemHit >= BoutonAutre) & (itemHit <= StaticMinutes) then
              begin
                PushRadio(dp,gCadencesRadios,BoutonAutre);
                if (itemHit = TextHeures) | (itemHit = TextMinutes) then
                  begin
                    GetItemTextInDialog(dp,itemHit,s);
                    s1 := '';
                    for i := 1 to LENGTH_OF_STRING(s) do
                      if (s[i] >= '0') & (s[i] <= '9') then s1 := s1 + s[i];
                    if LENGTH_OF_STRING(s1) > 0 then
                      begin
                        ChaineToLongint(s1,unlong);
                        s1 := NumEnString(unlong);
                        if (unlong = 0) & (LENGTH_OF_STRING(s1) = 0) then s1 := '';
                      end;
                    if LENGTH_OF_STRING(s1) > 4 then s1 := TPCopy(s1,1,4);
                    if itemHit = TextMinutes then
                      begin
                        ChaineToLongint(s1,unlong);
                        if unlong > 59 then
                          begin
                            SysBeep(0);
                            s1 := '';
                          end;
                      end;
                    if s1 <> s then SetItemTextInDialog(dp,itemHit,s1);
                  end;
              end;

            if itemHit = CompteAReboursBox then
              ToggleCheckBox(dp,CompteAReboursBox);

            if itemHit = NeJamaisTomberBox then
              ToggleCheckBox(dp,NeJamaisTomberBox);

          end;
      until (itemHit = OK) | (itemHit = Annuler);

      if itemHit = Annuler
        then
          begin
            PushRadio(dp,gCadencesRadios,SelectionInitiale.BoutonRadioCadence);
            SetBoolCheckBox(dp,NeJamaisTomberBox,SelectionInitiale.JamaisTomberAuTemps);
            SetBoolCheckBox(dp,CompteAReboursBox,SelectionInitiale.CompteRebours);
          end
        else
          begin
            ChangeCadence(gCadencesRadios);
            if GetCadence < minutes3 then
              begin
                SysBeep(0);
                SetCadence(3*60);
                cadencePersoAffichee := GetCadence;
              end;
            if GetCadence < minutes10000000 then
              begin
                nouveauJeuInstantane := (gCadencesRadios.selection >= BoutonDebutant) & (gCadencesRadios.selection <= BoutonChampion);
                SetCadenceAutreQueAnalyse(GetCadence,nouveauJeuInstantane);
              end;
          end;
      decrementetemps := IsCheckBoxOn(dp,CompteAReboursBox);
      neJamaisTomber := IsCheckBoxOn(dp,NeJamaisTomberBox);

      FntrCadenceRect := GetWindowPortRect(GetDialogWindow(dp));
      LocalToGlobalRect(FntrCadenceRect);

      MyDisposeDialog(dp);

      AjusteCadenceMin(GetCadence);
      jeuInstantane := (gCadencesRadios.selection >= BoutonDebutant) &
                       (gCadencesRadios.selection <= BoutonChampion);
      if jeuInstantane then
        case gCadencesRadios.selection of
          BoutonDebutant     : NiveauJeuInstantane := NiveauDebutants;
          BoutonAmateur      : NiveauJeuInstantane := NiveauAmateurs;
          BoutonClub         : NiveauJeuInstantane := NiveauClubs;
          BoutonFort         : NiveauJeuInstantane := NiveauForts;
          BoutonExpert       : NiveauJeuInstantane := NiveauExperts;
          BoutonGrandMaitre  : NiveauJeuInstantane := NiveauGrandMaitres;
          BoutonChampion     : NiveauJeuInstantane := NiveauChampions;
        end;

      dernierTick := TickCount;
      Heure(pionNoir);
      Heure(pionBlanc);
      if (gCadencesRadios.selection <> SelectionInitiale.BoutonRadioCadence)
        then AjusteEtatGeneralDeCassioApresChangementDeCadence;

      if not(enSetUp) then
        if HasGotEvent(updateMask,theEvent,0,NIL) then
          TraiteOneEvenement;
    end;
    MyDisposeModalFilterUPP(FiltreCadenceDialogUPP);
    EndDialog;
 end;



procedure EffectueTacheInterrompante(var interruptionEnCours : SInt16);
var compteurBoucle : SInt16;
    err : OSErr;
begin
  compteurBoucle := 0;
  
  repeat
    inc(compteurBoucle);
    
    {EcritTypeInterruptionDansRapport(interruptionEnCours);}

    GererDemandeInterruptionBrutaleEnCours;

    if BAnd(interruptionEnCours,interruptionSimple) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , interruptionSimple);
        TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'EffectueTacheInterrompante(interruptionSimple)');
      end;
    if BAnd(interruptionEnCours,kHumainVeutChangerCouleur) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutChangerCouleur);
        DoChangeCouleur;
      end;
    if BAnd(interruptionEnCours,kHumainVeutChargerBase) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutChargerBase);
        DoTraiteBaseDeDonnee(BaseLectureCriteres);
      end;
    if BAnd(interruptionEnCours,kHumainVeutAnalyserFinale) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutAnalyserFinale);
        DoAnalyseRetrograde(0);
        cycle;
      end;
    if BAnd(interruptionEnCours,kHumainVeutJouerSolitaires) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutJouerSolitaires);
        {DoJoueAuxSolitaires;}
        DoJoueAuxSolitairesNouveauFormat(2,64);
      end;
    if BAnd(interruptionEnCours,kHumainVeutChangerHumCtreHum) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutChangerHumCtreHum);
        DoChangeHumCtreHum;
      end;
    if BAnd(interruptionEnCours,kHumainVeutChangerCoulEtHumCtreHum) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutChangerCoulEtHumCtreHum);
        DoChangeHumCtreHum;
        DoChangeCouleur;
      end;
    if BAnd(interruptionEnCours,kHumainVeutRechercherSolitaires) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutRechercherSolitaires);
        ChercheSolitairesDansListe(1,nbPartiesActives,1,60);
       {ChercheSolitairesDansListe(1,nbPartiesActives,60-nbCasesVidesMaxSolitaire+1,60-nbCasesVidesMinSolitaire+1);}
       {ChercheSolitairesDansListe(1,nbPartiesActives,50,55);}
        cycle;
      end;
    if BAnd(interruptionEnCours,kHumainVeutCalculerScoresTheoriquesWThor) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutCalculerScoresTheoriquesWThor);
        if DernierEvenement.option
          then err := DoActionGestionBaseOfficielle('search difficult WLD')
          else err := DoActionGestionBaseOfficielle('recalculate');
        cycle;
      end;
    if BAnd(interruptionEnCours,kHumainVeutOuvrirFichierScriptFinale) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , kHumainVeutOuvrirFichierScriptFinale);
        err := OuvrirEndgameScript(GetProchainScriptDeFinaleAOuvrir);
        cycle;
      end;
    if BAnd(interruptionEnCours,interruptionDepassementTemps) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , interruptionDepassementTemps);
      end;
    if BAnd(interruptionEnCours,interruptionPositionADisparuDuZoo) <> 0 then
      begin
        interruptionEnCours := BXOr(interruptionEnCours , interruptionPositionADisparuDuZoo);
      end;
   until (interruptionEnCours = pasdinterruption) |
         (compteurBoucle > 15);

   if (interruptionEnCours <> pasdinterruption) then
     begin
       SysBeep(0);
       WritelnNumDansRapport('interruption inconnue dans EffectueTacheInterrompante !!!!!!!!!!!!!!',interruptionEnCours);
       EcritTypeInterruptionDansRapport(interruptionEnCours);
       interruptionEnCours := pasdinterruption;
     end;

end;



function DemandeInterruptionBrutaleEnCours : boolean;
begin
  DemandeInterruptionBrutaleEnCours := gDemandeInterruptionBrutaleEnCours;
end;

procedure SetDemandeInterruptionBrutaleEnCours(flag : boolean);
begin
  gDemandeInterruptionBrutaleEnCours := flag;
end;

procedure LanceDemandeInterruptionBrutale;
begin
  SetDemandeInterruptionBrutaleEnCours(true);
end;

procedure GererDemandeInterruptionBrutaleEnCours;
begin
  if DemandeInterruptionBrutaleEnCours then
    begin
      SetDemandeInterruptionBrutaleEnCours(false);
      TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'GererDemandeInterruptionBrutaleEnCours');
    end;
end;

procedure TraiteInterruptionBrutale(var coup,reponse : SInt32; fonctionAppelante : String255);
begin
  if not((BAnd(interruptionReflexion,interruptionDepassementTemps) <> 0) & vaDepasserTemps) then
    begin
      if debuggage.gestionDuTemps then
        WritelnDansRapport('dans TraiteInterruptionBrutale, fonctionAppelante = '+fonctionAppelante);
      coup := 44;
      reponse := 44;
      reponsePrete := false;
      meilleureReponsePrete := 44;
      MeilleurCoupHumPret := 44;
      meilleurCoupHum := 44;
    end;
end;


procedure TestDepassementTemps;
begin
  if CassioEstEnModeSolitaire |
     ScriptDeFinaleEnCours |
     CalculDesScoresTheoriquesDeLaBaseEnCours
    then exit(TestDepassementTemps);

  if analyseRetrograde.enCours &
     ((((tickCount-analyseRetrograde.tickDebutCeStageAnalyse) div 60) > analyseRetrograde.tempsMaximumCeStage) |
      (((tickCount-analyseRetrograde.tickDebutCettePasseAnalyse) div 60) > analyseRetrograde.tempsMaximumCettePasse)) then
    begin
      if debuggage.gestionDuTemps then
        WritelnDansRapport('appel 1 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
      DoForcerMacAJouerMaintenant;
      exit(TestDepassementTemps);
    end;

  if (interruptionReflexion = pasdinterruption) then
  if not(HumCtreHum) & (AQuiDeJouer = couleurMacintosh) then
  if not(RefleSurTempsJoueur) then
  if not(ProfondeurMilieuEstImposee) then
    begin
      if (phaseDeLaPartie >= phaseFinale)
	      then
	        begin
	          if (neJamaisTomber | analyseRetrograde.enCours)  then
  	          if (tempsReflexionMac div 60) >= (tempsAlloue-1) then
  	            begin
  	            	if debuggage.gestionDuTemps then
  	                WritelnDansRapport('appel 2 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
  	              DoForcerMacAJouerMaintenant;
  	              if not(analyseRetrograde.enCours) then
  	                EcritOopsMaPenduleDansRapport;
  	              exit(TestDepassementTemps);
  	            end;
	        end
	      else
	        begin
	          if ((tempsReflexionMac div 65) > tempsAlloue) &
	              (tempsAlloue < kUnMoisDeTemps) then
	            begin
	            	if debuggage.gestionDuTemps then
	                WritelnDansRapport('appel 3 a DoForcerMacAJouerMaintenant dans TestDepassementTemps');
	              DoForcerMacAJouerMaintenant;
	              exit(TestDepassementTemps);
	            end;
	        end;
	  end;
end;

procedure DerniereHeure(couleur : SInt32);
var aux : SInt32;
begin
   aux := TickCount-dernierTick;
   {DoSystemTask(couleur);}
   tempsDesJoueurs[couleur].tick := aux mod 60;
   dernierTick := TickCount-(aux mod 60);
   if not(enSetUp) then
    if HasGotEvent(updateMask,theEvent,0,NIL)
      then TraiteEvenements;
end;


procedure SetDateEnTickDuCoupNumero(numero,date : SInt32);
begin
  if (numero >= 0) & (numero <= 60) then
    gDateDesCoups[numero] := date;
end;


function GetDateEnTickDuCoupNumero(numero : SInt32) : SInt32;
begin
  if (numero >= 0) & (numero <= 60) then
    GetDateEnTickDuCoupNumero := gDateDesCoups[numero];
end;

procedure SetReveillerRegulierementLeMac(flag : boolean);
begin
  reveilRegulierDuMac.necessaire := flag;
  reveilRegulierDuMac.tickDerniereFois := TickCount;
end;

function GetReveillerRegulierementLeMac : boolean;
begin
  GetReveillerRegulierementLeMac := reveilRegulierDuMac.necessaire;
end;

procedure DoReveilDuMac;
var erreurES : OSErr;
    bidString : String255;
begin
  erreurES := OpenPrefsFileForSequentialReading;
  if erreurES = NoErr then erreurES := GetNextLineInPrefsFile(bidString);
  if erreurES = NoErr then erreurES := ClosePrefsFile;
  reveilRegulierDuMac.tickDerniereFois := TickCount;
end;



procedure PartagerLeTempsMachineAvecLesAutresProcess(WNESleep : SInt32);
begin
  kWNESleep := WNESleep;
end;


procedure Wait(secondes : double_t);
var ticks, ticksFin : SInt32;
begin
  if (secondes > 0.0) then
    begin
      ticks := TickCount;
      ticksFin := ticks + MyTrunc(0.5 + secondes * 60);
      while (Tickcount < ticksFin) do
        begin
          if (TickCount - dernierTick) >= delaiAvantDoSystemTask
            then DoSystemTask(AQuiDeJouer);
        end;
    end;
end;


procedure EcritOopsMaPenduleDansRapport;
var oldScript : SInt32;
begin
  GetCurrentScript(oldScript);
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  ChangeFontColorDansRapport(RougeCmd);
  ChangeFontDansRapport(gCassioRapportBoldFont);
  ChangeFontSizeDansRapport(gCassioRapportBoldSize);
  ChangeFontFaceDansRapport(bold);
  WritelnDansRapport(ReadStringFromRessource(TextesRapportID,6));  {' oops !!! ma pendule'}
  TextNormalDansRapport;
  EnableKeyboardScriptSwitch;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
end;



function GetLastEtatDuReseauAffiche : String255;
begin
  GetLastEtatDuReseauAffiche := gEtatDuReseau.messageAffiche;
end;


procedure VerifierSiLeReseauEstMort(nbreRequetesSansReponse, nbreDeSecondesSansReponseDuReseau : SInt32);
begin
  // WritelnNumDansRapport('Dans VerifierSiLeReseauEstMort : nbreDeSecondeSansResultat = ',nbreDeSecondeSansResultat);
  
  if (nbreRequetesSansReponse > 5) | (nbreDeSecondesSansReponseDuReseau > 5) then
    begin
      SetZooStatus('DEAD');
      SetIntervalleVerificationDuStatutDeCassioPourLeZoo(60, NIL); // toutes les secondes
    end;
end;


procedure SetDateDernierEnvoiRequeteSurReseau(date : SInt32);
begin
  with gEtatDuReseau do
    begin

      inc(nbreRequetesSansReponse);

      if (nbreRequetesSansReponse <= 1)
        then dateDerniereRequeteZoo := date;
        
      VerifierSiLeReseauEstMort(nbreRequetesSansReponse, 0);

      {WritelnNumDansRapport('dans SetDateDernierEnvoiRequeteSurReseau, nbreRequetesSansReponse = ',nbreRequetesSansReponse);}
    end;
end;

function GetDateDerniereRequeteSurReseau : SInt32;
begin
  GetDateDerniereRequeteSurReseau := gEtatDuReseau.dateDerniereRequeteZoo;
end;

procedure SetReseauEstVivant(vivant : boolean);
begin
  if vivant then
    begin
      gEtatDuReseau.nbreRequetesSansReponse := 0;
      SetIntervalleVerificationDuStatutDeCassioPourLeZoo(2, NIL);
    end;
end;


procedure SetMessageEtatDuReseau(message : String255);
begin
  with gEtatDuReseau do
    begin

      SetReseauEstVivant(true);
      
      if (Pos('KEEP_ALIVE : OK',message) > 0) then
        begin
          if (CalculateZooStatusPourCetEtatDeCassio = 'SEEKING_JOB') 
            then message := 'NO JOB !'
            else exit(SetMessageEtatDuReseau);
        end;
      

      if (Pos('STOP_ALL : OK',message) > 0) |
         (Pos('STILL USEFUL',message) > 0)
        then exit(SetMessageEtatDuReseau);
         
      if (Pos('SEND_SCORE : OK', message) > 0) & CassioEstEnTrainDeCalculerPourLeZoo
        then exit(SetMessageEtatDuReseau);
         

      if (Pos('STOPPED ',message) = 1) |
         (Pos('COULD_NOT_STOP ',message) = 1) |
         (Pos('ASKER_TAKES_IT : OK',message) > 0) then
        message := 'NO NEW RESULT  ';

      if (Pos('STILL INCHARGE true', message) > 0) then
        begin
          message := ReplaceStringByStringInString('STILL INCHARGE true','CALCULATING',message);
          if CassioEstEnTrainDeCalculerPourLeZoo then
            message := message + ' depth = ' + NumEnString(ProfDuCalculCourantDeCassioPourLeZoo);
        end;


      if messageAffiche <> message
        then dateMessageAffiche := TickCount;

      messageAffiche := message;

    end;
end;


procedure BouclerUnPeuAvantDeQuitterEnSurveillantLeReseau(nbreDeTicks : SInt32);
var mytick : SInt32;
begin
  if Quitter & not(gEnTrainDeBouclerPourSurveillerLeReseau) then
    begin
      
      mytick := TickCount;
      gEnTrainDeBouclerPourSurveillerLeReseau := true;

      while ((TickCount - mytick) < nbreDeTicks ) do 
        DoSystemTask(AQuiDeJouer);
      
      gEnTrainDeBouclerPourSurveillerLeReseau := false;
    end;
end;


procedure SetValeurTempsAlloueDansGestionTemps(alloue : SInt32);
begin
  gestionRec.alloue := alloue;
end;


procedure SetValeursGestionTemps(alloue,effectif,prevu : SInt32; divergence : double_t; prof,suivante : SInt16);
begin
  SetValeurTempsAlloueDansGestionTemps(alloue);
  gestionRec.prevu := prevu;
  gestionRec.effectif := effectif;
  gestionRec.divergence := divergence;
  gestionRec.prof := prof;
  gestionRec.profSuivante := suivante;
end;


procedure EcritGestionTemps;
var oldport : grafPtr;
    s, s2, foo : String255;
    posH, numeroEngine, mu : SInt32;
    lignerect,gestionRect : rect;
    tailleOmbrageDuBouton,radius : SInt32;
    divergAffichee : double_t;
    empties : SInt32;
    usingAnEngine : boolean;
    couleurOmbrage : RGBColor;
begin
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);
      TextSize(gCassioSmallFontSize);
      TextFont(gCassioApplicationFont);
      TextMode(1);
      TextFace(normal);
      posH := 4;


      SetRect(gestionRect,2,2,185,69);
      tailleOmbrageDuBouton := 4;
      radius := 10;
      SetRGBColor(couleurOmbrage,60000,60000,60000);
      MyEraseRectWithRGBColor(gestionRect,couleurOmbrage);
      dec(gestionRect.bottom);
      DessineOmbreRoundRect(gestionRect,radius,radius,couleurOmbrage,tailleOmbrageDuBouton,3000,500,1);


      with gestionRec do
        begin
           if ReflexData <> NIL
             then empties := ReflexData^.empties
             else empties := 64 - nbreDePions[pionNoir] - nbreDePions[pionBlanc];
           divergAffichee := gestionRec.divergence;

           s2 := ReadStringFromRessource(TextesGestionID,1);
           if alloue = minutes10000000 {temps infini}
             then s := ParamStr(s2,NumEnString(1000000000),'','','')
             else s := ParamStr(s2,NumEnString(alloue),'','','');
           Moveto(posH,13);
           SetRect(ligneRect,posH,13 - 9,gestionRect.right,13 + 2);
           MyEraseRectWithRGBColor(lignerect,couleurOmbrage);
           MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
           MyDrawString(s);

           usingAnEngine := CassioIsUsingAnEngine(numeroEngine);

           if (prof >= empties) & (prof > 0)
             then
               begin
                 s := ReadStringFromRessource(TextesGestionID,12);  {utilisé pour la finale à ^0 : ^1 sec.}

                 if ((profsuivante <= 0) & (divergAffichee > 0.0)) | (empties <= 3)
                   then
                     begin
                       s2 := PrecisionEngineEnMuString(ProfondeurMilieuEnPrecisionFinaleEngine(prof, empties));
                       SplitRightBy(s2, ',' ,foo, s2);
                       mu := ChaineEnLongint(s2) div 100;
                       if (mu >= 1000)
                         then s2 := 'µ=∞'
                         else s2 := 'µ=' + NumEnString(mu);
                     end
                   else s2 := NumEnString(ProfondeurMilieuEnPrecisionFinaleEngine(prof, empties)) + '%';
                 if (effectif >= 600)
                   then s := ParamStr(s,s2,NumEnString(effectif div 60),'','')
                   else s := ParamStr(s,s2,ReelEnStringRapide(effectif/60.0),'','');
               end
             else
               begin
                 s := ReadStringFromRessource(TextesGestionID,2);  {utilisé pour la prof. ^0 : ^1 sec.}
                 s2 := NumEnString(prof);
                 if (effectif >= 600) | (prof <= 0)
                   then s := ParamStr(s,s2,NumEnString(effectif div 60),'','')
                   else s := ParamStr(s,s2,ReelEnStringRapide(effectif/60.0),'','');
               end;
           Moveto(posH,25);
           SetRect(ligneRect,posH,25 - 9,gestionRect.right,25 + 2);
           MyEraseRectWithRGBColor(lignerect,couleurOmbrage);
           MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
           MyDrawString(s);

           (*
           if not(usingAnEngine) then
             begin
               if ((profsuivante <= 0) & (divergAffichee > 0.0) & (prof > 0))
                 then
                   begin
                     s := ReadStringFromRessource(TextesGestionID,4);  { "divergence : "}
                     s := s + ReelEnStringAvecDecimales(divergAffichee, 3);
                   end
                 else
                   if (profsuivante >= empties) & (profsuivante > 0)
                     then
                       begin
                         s := ReadStringFromRessource(TextesGestionID,13);  {prevu pour la finale à ^0 : ^1 sec.}
                         s2 := NumEnString(ProfondeurMilieuEnPrecisionFinaleEngine(profsuivante, empties)) + '%';
                         if (prevu >= 600)
                           then s := ParamStr(s,s2,NumEnString(prevu div 60),'','')
                           else s := ParamStr(s,s2,ReelEnStringRapide(prevu/60.0),'','');
                       end
                     else
                       begin
                         s := ReadStringFromRessource(TextesGestionID,3);   {prevu pour la prof. ^0 : ^1 sec.}
                         s2 := NumEnString(profsuivante);
                         if (prevu >= 600) | (prof <= 0)
                           then s := ParamStr(s,s2,NumEnString(prevu div 60),'','')
                           else s := ParamStr(s,s2,ReelEnStringRapide(prevu/60.0),'','');
                       end;
               Moveto(posH,37);
               SetRect(ligneRect,posH,37 - 9,gestionRect.right,37 + 2);
               MyEraseRectWithRGBColor(lignerect,couleurOmbrage);
               MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
               MyDrawString(s);
             end;
           *)


           s := ReadStringFromRessource(TextesGestionID,9);  { " moteur : " }
           if usingAnEngine
             then
               begin
                 s2 := GetEngineVersion(numeroEngine);
                 if (s2 = '') then s2 := GetEngineName(numeroEngine);
                 
                 s2[1] := UpCase(s2[1]);
                 s := s + s2;
               end
             else
               if (typeEvalEnCours = EVAL_EDMOND)
                   then s := s + 'Edmond'
                   else s := s + 'Cassio';
                   
           if usingAnEngine & (GetEngineState = 'ENGINE_KILLED') & (Tickcount > DateOfLastStartOfEngine + 120)
             then
               s := s + ' (KILLED)'
             else
               if (numProcessors > 1)
                 then s := s + ', ' + ParamStr(ReadStringFromRessource(TextesGestionID,10),NumEnString(numProcessors),'','','')   { " ^0 processeurs" }
                 else s := s + ', ' + ReadStringFromRessource(TextesGestionID,11);                                                { " 1 processeur " }



           SetRect(ligneRect,posH,37 - 9,gestionRect.right,37 + 2);
           MyEraseRectWithRGBColor(lignerect,couleurOmbrage);
           MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
           Moveto(posH,37);
           MyDrawString(s);

        end;  {with}






      DessineBoiteDeTaille(wGestionPtr);
      SetPort(oldport);
    end;

  AffichageNbreNoeuds;
end;

procedure LanceChronoCetteProf;
begin
  tempsReflexionCetteProf := 0;
end;

procedure LanceChrono;
begin
  tempsReflexionMac := 0;
end;

procedure LanceDecompteDesNoeuds;
begin
  nbreToursFeuillesMilieu := 0;
  nbreFeuillesMilieu := 0;
  SommeNbEvaluationsRecursives := 0;
  nbreToursNoeudsGeneresMilieu := 0;
  nbreNoeudsGeneresMilieu := 0;
  lastNbreNoeudsGeneres := 0;
  DebutComptageFeuilles := TickCount;
end;


procedure AffichageNbreNoeuds;
var oldPort : grafPtr;
    aux,nsec,i : SInt32;
    NodeCounter,TickCounter : UInt32;
    unRect, gestionRect : rect;
    s : String255;
    facteur : double_t;
    numeroEngine : SInt32;
    couleurOmbrage : RGBColor;
begin
 if not(HumCtreHum) then
  if windowGestionOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wGestionPtr);


      SetRect(gestionRect,2,2,185,69);
      SetRGBColor(couleurOmbrage,60000,60000,60000);

      SetRect(unRect,3,40,gestionRect.right,66);

      MyEraseRectWithRGBColor(unrect,couleurOmbrage);
      MyEraseRectWithColor(unRect,JauneCmd,blackPattern,'');
      DessineBoiteDeTaille(wGestionPtr);

      RGBForeColor(gPurNoir);
      RGBBackColor(couleurOmbrage);

      if phaseDeLaPartie >= phaseFinale
        then
          begin
            (*if nbreToursNoeudsGeneresFinale > 0 then
              begin
                s := ReadStringFromRessource(TextesGestionID,5); { "nbre tours du compteur : " }
                WriteStringAndNumEnSeparantLesMilliersAt(s,nbreToursNoeudsGeneresFinale,4,88);
              end;
            *)
            s := ReadStringFromRessource(TextesGestionID,6);     { "nbre nœuds : " }
            WriteStringAndBigNumEnSeparantLesMilliersAt(s,nbreToursNoeudsGeneresFinale,nbreNoeudsGeneresFinale,4,64);

            with NbreDeNoeudsMoyensFinale do
              begin
                if index < 0 then index := 0;
                if index > 9 then index := 9;
                nbreNoeudsCetteSeconde[index] := (nbreNoeudsGeneresFinale-lastNbreNoeudsFinale);
                nbreTicksCetteSeconde[index] := (TickCount-lastNbreTicksFinale);
                lastNbreNoeudsFinale := nbreNoeudsGeneresFinale;
                lastNbreTicksFinale := TickCount;
                index := (index + 1) mod 10;

                NodeCounter := 0;
                TickCounter := 0;

                {faire deux sommations separees pour eviter les overflow dans NodeCounter}
                for i := 0 to 9 do
                  if (nbreNoeudsCetteSeconde[i] > 0) &
                     (nbreTicksCetteSeconde[i] > 0) &
                     (nbreTicksCetteSeconde[i] < 1000)
                    then TickCounter := TickCounter + nbreTicksCetteSeconde[i];

                if TickCounter > 0 then
	                begin
	                  for i := 0 to 9 do
		                  if (nbreNoeudsCetteSeconde[i] > 0) &
		                     (nbreTicksCetteSeconde[i] > 0) &
		                     (nbreTicksCetteSeconde[i] < 1000)
		                    then NodeCounter := NodeCounter + (nbreNoeudsCetteSeconde[i] div TickCounter);
		                NodeCounter := NodeCounter * 60;

		                if (NodeCounter < 1200) then
	                    begin
			                  for i := 0 to 9 do
				                  if (nbreNoeudsCetteSeconde[i] > 0) &
				                     (nbreTicksCetteSeconde[i] > 0) &
				                     (nbreTicksCetteSeconde[i] < 1000)
				                    then NodeCounter := NodeCounter + nbreNoeudsCetteSeconde[i];
				                NodeCounter := (60*NodeCounter) div TickCounter;
			                end;
			            end;

                s := ReadStringFromRessource(TextesGestionID,8);  {"nbre noeuds par sec"}
                if TickCounter > 0
                  then WriteStringAndNumEnSeparantLesMilliersAt(s,NodeCounter,4,52)
                  else WriteNumAt(s,0,4,52);
              end;

          end
        else
          begin
            TextSize(gCassioSmallFontSize);
            TextFont(gCassioApplicationFont);
            nsec := (TickCount - DebutComptageFeuilles) div 60;
            facteur := 1.02;   // soyons optimistes de 2%

            if (nsec > 0)
              then
                begin
                  aux := MyTrunc(facteur*nbreToursNoeudsGeneresMilieu*(1000000000 div nsec));
                  aux := aux + MyTrunc(facteur*(nbreNoeudsGeneresMilieu div nsec));
                end
              else
                aux := 0;

            if (nbreNoeudsGeneresMilieu <> lastNbreNoeudsGeneres) & (aux > 0)
              then
                begin
                  if CassioIsUsingAnEngine(numeroEngine)
                    then
                      begin
                        s := ReadStringFromRessource(TextesGestionID,8);  { "nb nœuds par sec : " }
                        WriteStringAndNumEnSeparantLesMilliersAt(s,aux,4,52);
                        s := ReadStringFromRessource(TextesGestionID,6);     { "nbre nœuds : " }
                        WriteStringAndBigNumEnSeparantLesMilliersAt(s,nbreToursNoeudsGeneresMilieu,nbreNoeudsGeneresMilieu,4,64);
                      end
                    else
                      begin
                        s := ReadStringFromRessource(TextesGestionID,7);  { "nb feuilles par sec : " }
                        WriteStringAndNumEnSeparantLesMilliersAt(s,MyTrunc(facteur*(nbreToursFeuillesMilieu*(1000000000 div nsec) + (nbreFeuillesMilieu div nsec))),4,52);
                        s := ReadStringFromRessource(TextesGestionID,8);  { "nb nœuds par sec : " }
                        WriteStringAndNumEnSeparantLesMilliersAt(s,aux,4,64);
                      end;
                end
              else   {on écrit des zeros comme nb de noeuds par sec}
                begin

                  s := ReadStringFromRessource(TextesGestionID,7);   { "nb feuilles par sec : " }
                  WriteNumAt(s,0,4,52);
                  s := ReadStringFromRessource(TextesGestionID,8);   { "nb nœuds par sec : " }
                  WriteNumAt(s,0,4,64);
                end;
            lastNbreNoeudsGeneres := nbreNoeudsGeneresMilieu;
          end;

      RGBForeColor(gPurNoir);
      RGBBackColor(gPurBlanc);

      SetPort(oldport);
    end;
end;

                   
                    
procedure AfficheEtatDuReseau(message : String255);
var oldPort: grafPtr;
    nbreSecondes, idleTime : SInt32;
    s : String255;
    posH, posV : SInt32;
    ligneRect : Rect;
    left, right : String255;
    nbrePositionsPrefetchedAux,profMinAux,profMaxAux : SInt32;
    tempsTotalAux, tempsDeMidgameAux, tempsUtileAux, tempsPositionCouranteAux : double_t;
    nbrePositionsAux, nbrePositionsTrivialesAux,nbrePositionsMilieuAux : SInt32;
    nbrePositionsEnAttenteAux : SInt32;
    limiteDroiteFenetre,limiteBasseFenetre : SInt32;
    
    procedure AfficheStatReseau(const ligne : String255);
    begin
      posV := posV + 12;
      Moveto(posH,posV);
      if (limiteBasseFenetre >= posV-9) then
        begin
          SetRect(ligneRect,posH,posV-9,limiteDroiteFenetre,posV+2);
          MyEraseRect(lignerect);
          MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
          MyDrawString(ligne);
        end;
    end;
    
begin

  with gEtatDuReseau do
    begin

      SplitByStr(message,'<br>OK',left,right);
      message := left;

      if messageAffiche <> message then dateMessageAffiche := TickCount;
      messageAffiche := message;
      
      
      if TickCount <= dateDernierAffichageEtat + 5 
        then exit(AfficheEtatDuReseau);
      
      
      
      if (message = '') & (TickCount - dateMessageAffiche > 300) then
        VerifierSiLeReseauEstMort(nbreRequetesSansReponse, (TickCount - dateMessageAffiche) div 60);
        

      if windowGestionOpen & (wGestionPtr <> NIL) then
        begin

          nbreSecondes := ((TickCount - dateMessageAffiche) + 25) div 60;

          idleTime := (TickCount - dateDerniereRequeteZoo) div 60;

          GetPort(oldPort);
          SetPortByWindow(wGestionPtr);
          limiteDroiteFenetre := QDGetPortBound.right;
          limiteBasseFenetre := QDGetPortBound.bottom;

          TextSize(gCassioSmallFontSize);
          TextFont(gCassioApplicationFont);
          TextMode(1);
          TextFace(normal);
          posH := 4;

          with gestionRec do
           begin
               (* s := ReadStringFromRessource(TextesGestionID,1); *)

               if not(CassioDoitRentrerEnContactAvecLeZoo)
                 then s := 'Etat sur le zoo : NOT CONNECTED'
                 else 
                   if (nbreSecondes <= 60)
                     then s := 'Etat sur le zoo : ' + message +  '  (depuis ' + NumEnString(nbreSecondes) + ' sec.)'
                     else s := 'Etat sur le zoo : ' + message +  '  (depuis ' + SecondesEnJoursHeuresSecondes(nbreSecondes) + ')';

               if (Pos('NO JOB', message) <= 0) | (nbreSecondes >= 3) then
                 begin
                   posV := 88;
                   AfficheStatReseau(s);
                 end;

               posV := 100;

               if (nbreRequetesSansReponse > 5)
                 then s := '  Réseau mort depuis '+NumEnString(idleTime) + ' sec…'
                 else
                   if CassioDoitRentrerEnContactAvecLeZoo
                     then s := '  Réseau vivant : OK'
                     else s := '  Réseau vivant : je ne sais pas…';
               AfficheStatReseau(s);

               (*
               if nbreRequetesSansReponse >= 2
                 then s := '  requêtes réseau sans réponse : '+NumEnString(nbreRequetesSansReponse)
                 else s := '  requêtes réseau sans réponse : '+NumEnString(0);
               AfficheStatReseau(s);
               *)


               if Pos('CALCULATING',message) = 1
                 then tempsPositionCouranteAux := (Max(0,TickCount - dateMessageAffiche)) / 60.0
                 else tempsPositionCouranteAUx := 0;
               tempsTotalAux                   := TempsTotalConsacreAuZoo;
               tempsUtileAux                   := TempsUtileConsacreAuZoo;
               tempsDeMidgameAux               := TempsDeMidgameConsacreAuZoo;
               nbrePositionsAux                := NombreTotalDeJobsCalculesPourLeZoo;
               nbrePositionsTrivialesAux       := NombreDeJobsEndgameTriviauxCalculesPourLeZoo;
               nbrePositionsMilieuAux          := NombreDeJobsMidgameCalculesPourLeZoo;
               nbrePositionsEnAttenteAux       := NombreDeResultatsEnAttenteSurLeZoo;
               
               GetOccupationDuCacheDesPrefetch(nbrePositionsPrefetchedAux,profMinAux,profMaxAux);
               if CassioEstEnTrainDeCalculerPourLeZoo then inc(nbrePositionsPrefetchedAux);
               
               
               with gEtatDuReseau.statsZoo do
                 begin
                 
                   if (TickCount >= dateDernierAffichageStats + 60) |
                      (nbrePositionsPrefetched <> nbrePositionsPrefetchedAux) |
                      (profMin                 <> profMinAux) |
                      (profMax                 <> profMaxAux) |
                      (tempsTotal              <> tempsTotalAux) |
                      (tempsDeMidgame          <> tempsDeMidgameAux) |
                      (tempsUtile              <> tempsUtileAux) |
                      (tempsPositionCourante   <> tempsPositionCouranteAux) |
                      (nbrePositions           <> nbrePositionsAux) |
                      (nbrePositionsTriviales  <> nbrePositionsTrivialesAux) |
                      (nbrePositionsMilieu     <> nbrePositionsMilieuAux) |
                      (nbrePositionsEnAttente  <> nbrePositionsEnAttenteAux) then
                     begin
                     
                       dateDernierAffichageStats := TickCount;
                       nbrePositionsPrefetched   := nbrePositionsPrefetchedAux;
                       profMin                   := profMinAux;
                       profMax                   := profMaxAux;
                       tempsTotal                := tempsTotalAux;
                       tempsDeMidgame            := tempsDeMidgameAux;
                       tempsUtile                := tempsUtileAux;
                       tempsPositionCourante     := tempsPositionCouranteAux;
                       nbrePositions             := nbrePositionsAux;
                       nbrePositionsTriviales    := nbrePositionsTrivialesAux;
                       nbrePositionsMilieu       := nbrePositionsMilieuAux;
                       nbrePositionsEnAttente    := nbrePositionsEnAttenteAux;
                       

                       if nbrePositionsEnAttente >= 2
                         then s := '  Nombre de positions demandées au zoo : '+NumEnString(nbrePositionsEnAttente)
                         else s := '  Nombre de positions demandées au zoo : '+NumEnString(nbrePositionsEnAttente);
                       AfficheStatReseau(s);
                       
                       if CassioEstEnTrainDeCalculerPourLeZoo then
                         begin
                           inc(nbrePositionsPrefetched);
                           if (profMax < 0) then profMax := ProfDuCalculCourantDeCassioPourLeZoo;
                         end;

                       if nbrePositionsPrefetched <= 0
                         then s := '  Nombre de positions à calculer pour le zoo  : 0'
                         else s := '  Nombre de positions à calculer pour le zoo  : ' + NumEnString(nbrePositionsPrefetched);
                       if (profMax >= 0)
                         then s := s + ' (de prof. max ' + NumEnString(profMax) + ')';
                       AfficheStatReseau(s);
                       
                       
                       s := '  Temps CPU utile consacré au zoo : ' + ReelEnString(tempsUtile) + ' sec.';
                       AfficheStatReseau(s);
                       
                       if (nbrePositions <> 0) then
                         begin
                           s := '  Pour '+ NumEnString(nbrePositions) + ' positions, soit un temps moyen de ' +  ReelEnString(tempsTotal / nbrePositions) + ' sec.';
                           AfficheStatReseau(s);
                         end;
                       
                       if (abs(nbrePositions - nbrePositionsMilieu) >= 2) then
                         begin
                           s := '  Temps moyen des positions de finale : ' +  ReelEnString((tempsTotal - tempsDeMidgame) / (nbrePositions - nbrePositionsMilieu)) + ' sec.';
                           AfficheStatReseau(s);
                         end;
                         
                       if (tempsTotal <> 0.0) then
                         begin
                           s := '  Temps CPU total consacré au zoo : ' + ReelEnString(tempsTotal + tempsPositionCourante) + ' sec.';
                           AfficheStatReseau(s);
                         end;
                       
                       if (tempsTotal <> 0.0) & (tempsUtile <> tempsTotal) then
                         begin
                           s := '  Pertes dues aux annulations : ' + ReelEnString(100.0 * (tempsTotal - tempsUtile) / tempsTotal) + ' %';
                           AfficheStatReseau(s);
                         end;
                       
                       if (nbrePositions <> 0) & (nbrePositionsTriviales <> 0) then
                         begin
                           s := '  Pourcentage des positions de finale triviales (t < 0.05 sec.) : ' +  ReelEnString(100.0 * (nbrePositionsTriviales / nbrePositions)) + ' %';
                           AfficheStatReseau(s);
                         end;
                       
                       if (nbrePositions <> 0) & (nbrePositionsMilieu <> 0) then
                         begin
                           s := '  Pourcentage du nombre de positions de milieu : ' +  NumEnString(nbrePositionsMilieu) + ' positions = ' + ReelEnString(100.0 * (nbrePositionsMilieu / nbrePositions)) + ' %';
                           AfficheStatReseau(s);
                         end;
                       
                       if (tempsTotal <> 0.0) & (tempsDeMidgame <> 0.0) then
                         begin
                           s := '  Pourcentage du temps pour les positions de milieu : ' + ReelEnString(tempsDeMidgame) + ' sec. = ' + ReelEnString(100.0 * (tempsDeMidgame / tempsTotal)) + ' %';
                           AfficheStatReseau(s);
                         end;
                       
                       AfficheStatReseau('');
                       
                     end;
                 
                 end; {with gEtatDuReseau.statsZoo}

            end;  {with gestionRec}

          DessineBoiteDeTaille(wGestionPtr);

          SetPort(oldPort);

          dateDernierAffichageEtat := TickCount;
        end;
    end; {with gEtatDuReseau}
end;


END.











































