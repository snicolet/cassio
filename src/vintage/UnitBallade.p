UNIT UnitBallade;


INTERFACE


 USES UnitDefCassio;

procedure DoAvanceMove;
procedure DoDoubleAvanceMove;
procedure DoBackMove;
procedure DoDoubleBackMove;
procedure DoBackMovePartieSelectionnee(nroHilite : SInt32);
procedure DoDoubleBackMovePartieSelectionnee(nroHilite : SInt32);
procedure DoDoubleAvanceMovePartieSelectionnee(nroHilite : SInt32);
procedure DoRetourAuCoupNro(numeroCoup : SInt32; NeDessinerQueLesNouveauxPions,ForceHumCtreHum : boolean);
procedure DoAvanceAuCoupNro(numeroCoup : SInt16; NeDessinerQueLesNouveauxPions : boolean);
procedure DoRetourDerniereMarque;
procedure DoAvanceProchaineMarque;
procedure DoRetourDernierEmbranchement;
procedure DoAvanceProchainEmbranchement;
procedure SeDeplacerDansLaPartieDeTantDeCoups(deplacement : SInt32; useLiveUndo : boolean);


procedure BeginFonctionModifiantNbreCoup(fonctionAppelante : String255);
procedure EndFonctionModifiantNbreCoup(fonctionAppelante : String255);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, UnitDebuggage, MacWindows, OSUtils
{$IFC NOT(USE_PRELINK)}
    , Zebra_to_Cassio, MyQuickDraw, UnitGameTree, UnitNormalisation
    , UnitRetrograde, UnitLiveUndo, UnitEvenement, UnitPositionEtTrait, UnitNotesSurCases, UnitJeu, UnitAffichageReflexion, UnitAffichagePlateau
    , UnitPhasesPartie, UnitGestionDuTemps, UnitMenus, UnitCurseur, UnitCarbonisation, UnitAffichageArbreDeJeu, MyMathUtils, UnitArbreDeJeuCourant
    , UnitCourbe, UnitSuperviseur, UnitStrategie, UnitTroisiemeDimension, UnitEntreesSortiesGraphe, UnitBibl, UnitFenetres, UnitPierresDelta
    , UnitEntreeTranscript, UnitListe, UnitCassioSounds, UnitOth2, UnitLongintScroller, UnitAccesNouveauFormat, UnitPackedThorGame, UnitUtilitaires
    , UnitRapport, UnitTore, SNEvents, UnitModes, UnitSquareSet, UnitServicesMemoire, MyStrings, UnitTournoi
    , UnitActions, UnitEngine ;
{$ELSEC}
    ;
    {$I prelink/Ballade.lk}
{$ENDC}


{END_USE_CLAUSE}




procedure DoAvanceMove;
var coup,couleur : SInt16;
    tempoSon : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
   if nroDernierCoupAtteint > nbreCoup then
    if GetNiemeCoupPartieCourante(nbreCoup+1) <> coupInconnu then
     begin
       RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
       EffaceAideDebutant(false,true,othellierToutEntier,'DoAvanceMove');
       ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
       coup := GetNiemeCoupPartieCourante(nbreCoup+1);
       if (coup <> coupInconnu) then
         begin
           couleur := GetCouleurNiemeCoupPartieCourante(nbreCoup+1);
           if couleur = AQuiDeJouer then
             begin
               tempoSon := avecSon;
               avecSon := false;
               DealWithEssai(coup,PositionEtTraitCourant,'DoAvanceMove');
               avecSon := tempoSon;
             end
             else
              if avecSon then SysBeep(3);
           if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
           if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
           meilleurCoupHum := 44;
           meilleureReponsePrete := 44;
           gDoitJouerMeilleureReponse := false;
           PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
           RefleSurTempsJoueur := false;
           LanceInterruptionSimpleConditionnelle('DoAvanceMove');
           LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoAvanceMove');
           LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoAvanceMove');
           vaDepasserTemps := false;
           reponsePrete := false;
           phaseDeLaPartie := CalculePhasePartie(nbreCoup);
           FixeMarqueSurMenuMode(nbreCoup);
           EssaieDisableForceCmd;
           dernierTick := TickCount;
           Heure(-AQuiDeJouer);
           Heure(AQuiDeJouer);

           FlushWindow(wPlateauPtr);

           AjusteCurseur;

           EngineNewPosition;
         end;
     end;
end;

procedure DoDoubleAvanceMove;
var coup,couleur,i,mobilite : SInt32;
    oldport : grafPtr;
    err : OSErr;
begin
  if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
  if (nroDernierCoupAtteint > nbreCoup) then
    begin
      if nroDernierCoupAtteint = nbreCoup+1
        then DoAvanceMove
        else
          if nroDernierCoupAtteint = nbreCoup+2
            then
              begin
                DoAvanceMove;
                DoAvanceMove;
              end
            else
              begin
                GetPort(OldPort);
                SetPortByWindow(wPlateauPtr);

                BeginFonctionModifiantNbreCoup('DoDoubleAvanceMove');

                RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
                EffaceAideDebutant(false,true,othellierToutEntier,'DoDoubleAvanceMove');
                ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
                EffaceProprietesOfCurrentNode;
                if afficheNumeroCoup & (nbreCoup > 0) then
                  begin
                    coup := DerniereCaseJouee;
                    if InRange(coup,11,88) then
                      EffaceNumeroCoup(coup,nbreCoup,GetCurrentNode);
                  end;

                IndexProchainFilsDansGraphe := -1;
                nbreCoup := nbreCoup+1;
                coup := DerniereCaseJouee;
                couleur := GetCouleurDernierCoup;
                with partie^^[nbreCoup] do
                  begin
                    DessinePion(coup,couleur);

                    err := ChangeCurrentNodeAfterNewMove(coup,couleur,'DoDoubleAvanceMove {1}');
                    MarquerCurrentNodeCommeReel('DoDoubleAvanceMove  {1}');

                    if UpdateJeuCourant(coup) then;

                    for i := 1 to nbRetourne do
                      DessinePion(retournes[i],GetCouleurOfSquareDansJeuCourant(retournes[i]));

                    nbreDePions[trait] := nbreDePions[trait] + nbRetourne + 1;
                    nbreDePions[-trait] := nbreDePions[-trait] - nbRetourne;
                  end;

                TraceSegmentCourbe(nbreCoup,kCourbeColoree,'DoDoubleAvanceMove {1}');
                DessineSliderFenetreCourbe;

                partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
                partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
                partie^^[nbreCoup].tickDuCoup := TickCount;
                nbreCoup := nbreCoup+1;
                coup := DerniereCaseJouee;
                couleur := GetCouleurDernierCoup;
                with partie^^[nbreCoup] do
                  begin
                    DessinePion(coup,couleur);

                    err := ChangeCurrentNodeAfterNewMove(coup,couleur,'DoDoubleAvanceMove {2}');
                    MarquerCurrentNodeCommeReel('DoDoubleAvanceMove {2}');

                    if UpdateJeuCourant(coup) then;

                    for i := 1 to nbRetourne do
                      DessinePion(retournes[i],GetCouleurOfSquareDansJeuCourant(retournes[i]));

                    nbreDePions[trait] := nbreDePions[trait] + nbRetourne + 1;
                    nbreDePions[-trait] := nbreDePions[-trait] - nbRetourne;
                  end;

                TraceSegmentCourbe(nbreCoup,kCourbeColoree,'DoDoubleAvanceMove {2}');
                DessineSliderFenetreCourbe;

                partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
                partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
                partie^^[nbreCoup].tickDuCoup := TickCount;
                IndexProchainFilsDansGraphe := -1;

                InitialiseDirectionsJouables;


               CarteJouable(JeuCourant,emplJouable);

               if AQuiDeJouer = pionVide then TachesUsuellesPourGameOver;


               MetTitreFenetrePlateau;
               AjusteCurseur;
               if EnVieille3D then Dessine3D(JeuCourant,false);
               if afficheNumeroCoup & (nbreCoup > 0) then
                 if (DerniereCaseJouee <> coupInconnu) & InRange(DerniereCaseJouee,11,88)
                    then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);
               {la}
               if EnModeEntreeTranscript then EntrerPartieDansCurrentTranscript(nbreCoup);
               if afficheInfosApprentissage then EcritLesInfosDApprentissage;
               EnableItemPourCassio(PartieMenu,ForwardCmd);
               CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
               CarteFrontiere(JeuCourant,frontiereCourante);
               {Initialise_table_heuristique(JeuCourant);}
               calculPrepHeurisFait := false;
               AfficheScore;
               if (HumCtreHum | (nbreCoup <= 0) | (AQuiDeJouer <> couleurMacintosh)) & not(enTournoi) then
                  begin
                    MyDisableItem(PartieMenu,ForceCmd);
                    AfficheDemandeCoup;
                  end;
               if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
               meilleurCoupHum := 44;
               meilleureReponsePrete := 44;
               gDoitJouerMeilleureReponse := false;
               RefleSurTempsJoueur := false;
               LanceInterruptionSimpleConditionnelle('DoDoubleAvanceMove');
               LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoDoubleAvanceMove');
               LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoDoubleAvanceMove');
               vaDepasserTemps := false;
               reponsePrete := false;
               {peutfeliciter := true;}
               TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoDoubleAvanceMove');
             (*  if avecDessinCoupEnTete then EffaceCoupEnTete;
               SetCoupEntete(0);*)
               PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
               phaseDeLaPartie := CalculePhasePartie(nbreCoup);
               FixeMarqueSurMenuMode(nbreCoup);
               EssaieDisableForceCmd;
               dernierTick := TickCount;
               Heure(-AQuiDeJouer);
               Heure(AQuiDeJouer);



               AjusteCurseur;
               AddRandomDeltaStoneToCurrentNode;


               EndFonctionModifiantNbreCoup('DoDoubleAvanceMove');

               LanceDemandeAffichageZebraBook('DoDoubleAvanceMove');
               AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleAvanceMove');
               if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

               FlushWindow(wPlateauPtr);

               if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
                 then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);

               EngineNewPosition;

               SetPort(OldPort);
             end;
    end;
end;


procedure DoBackMove;
var i,mobilite : SInt32;
    oldport : grafPtr;
    jeu : plateauOthello;
begin
  if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
  begin
    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup >= 1 then
    if DerniereCaseJouee <> coupInconnu then
     begin

       BeginFonctionModifiantNbreCoup('DoBackMove');

       RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
       PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
       if not(HumCtreHum) & (jeuInstantane | CassioEstEnModeSolitaire) & PartieContreMacDeBoutEnBout & (nbreCoup >= 20)
         then PlayZamfirSound('DoBackMove');
       if analyseRetrograde.enCours {& (nbPartiesActives > 0)} & (analyseRetrograde.tempsDernierCoupAnalyse < 300) & (nbreCoup > 40)
         then avecCalculPartiesActives := false
         else avecCalculPartiesActives := true;

       EffaceAideDebutant(false,true,othellierToutEntier,'DoBackMove');
       ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
       EffaceProprietesOfCurrentNode;

       with partie^^[nbreCoup] do
       begin
         jeu := JeuCourant;
         DessinePion(DerniereCaseJouee,pionVide);
         jeu[DerniereCaseJouee] := pionVide;
         for i := 1 to nbRetourne do
           begin
             jeu[retournes[i]] := -jeu[retournes[i]];
             if RetournementSpecialEnCours
               then DessinePion(retournes[i],ValeurFutureDeCetteCaseDansRetournementSpecial(retournes[i]))
               else DessinePion(retournes[i],jeu[retournes[i]]);
           end;
         nbreDePions[trait] := nbreDePions[trait] - nbRetourne - 1;
         nbreDePions[-trait] := nbreDePions[-trait] + nbRetourne;
         SetJeuCourant(jeu,trait);
       end;
       tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
       tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
       tempsDesJoueurs[pionNoir].tick := 0;
       tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
       tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
       tempsDesJoueurs[pionBlanc].tick := 0;
       AjusteCurseur;
       if EnVieille3D then Dessine3D(JeuCourant,false);

       ChangeCurrentNodeForBackMove;

       if not(LiveUndoEnCours) then
         MarquerCurrentNodeCommeReel('DoBackMove');


       {
       with partie^^[nbreCoup] do
       begin
         trait := 0;
         x := coupInconnu;
         nbRetourne := 0;
       end;
       }
       IndexProchainFilsDansGraphe := -1;
       nbreCoup := nbreCoup-1;


       if afficheNumeroCoup & (nbreCoup > 0) then
         if (DerniereCaseJouee <> coupInconnu) & InRange(DerniereCaseJouee,11,88)
            then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);
       EffaceCourbe(nbreCoup,nbreCoup+1,kCourbePastel,'DoBackMove');
       DessineSliderFenetreCourbe;
       {la}
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       InitialiseDirectionsJouables;
       CarteJouable(JeuCourant,emplJouable);
       CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
       CarteFrontiere(JeuCourant,frontiereCourante);
       {Initialise_table_heuristique(JeuCourant);}
       calculPrepHeurisFait := false;
       AfficheScore;
       if (HumCtreHum | (nbreCoup <= 0) | (AQuiDeJouer <> couleurMacintosh)) & not(enTournoi) then
          begin
            MyDisableItem(PartieMenu,ForceCmd);
            AfficheDemandeCoup;
          end;
       gameOver := false;
       if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
       if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       RefleSurTempsJoueur := false;
       LanceInterruptionSimpleConditionnelle('DoBackMove');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoBackMove');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoBackMove');
       vaDepasserTemps := false;
       reponsePrete := false;
       PartieContreMacDeBoutEnBout := false;
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoBackMove');
       {peutfeliciter := true;}
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       dernierTick := TickCount;
       Heure(-AQuiDeJouer);
       Heure(AQuiDeJouer);


       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;

       EndFonctionModifiantNbreCoup('DoBackMove');

       if not(LiveUndoVaRejouerImmediatementUnAutreCoup) then
         begin
           LanceDemandeAffichageZebraBook('DoBackMove');
           AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoBackMove');
           if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);
         end;

       FlushWindow(wPlateauPtr);

       if not(LiveUndoVaRejouerImmediatementUnAutreCoup) then
         begin
           if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
             then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
           avecCalculPartiesActives := true;
         end;


     end;
     SetPort(oldport);
  end;
end;



procedure DoDoubleBackMove;
var i,mobilite : SInt32;
    oldport : grafPtr;
    limiteInfNbreCoup : SInt16;
    peutPlusReculer : boolean;
    jeu : plateauOthello;
begin
  if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
  begin



    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup >= 1 then
    if DerniereCaseJouee <> coupInconnu then
     begin

       BeginFonctionModifiantNbreCoup('DoDoubleBackMove');

       RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
       if not(HumCtreHum) & (jeuInstantane | CassioEstEnModeSolitaire) & PartieContreMacDeBoutEnBout & (nbreCoup >= 20)
         then PlayZamfirSound('DoDoubleBackMove');
       if HumCtreHum | (not(CassioEstEnModeSolitaire) & (AQuiDeJouer = couleurMacintosh))
         then
           limiteInfNbreCoup := nbreCoup-2
         else
           begin
             i := nbreCoup;
             while (i > 0) & (GetCouleurNiemeCoupPartieCourante(i) = couleurMacintosh) do i := i-1;
             limiteInfNbreCoup := i-1;
           end;
       if limiteInfNbreCoup < 0 then limiteInfNbreCoup := 0;
       repeat
         peutPlusReculer := true;
         if nbreCoup >= 1 then
         if DerniereCaseJouee <> coupInconnu then
           begin
            avecCalculPartiesActives := true;

            EffaceAideDebutant(false,true,othellierToutEntier,'DoDoubleBackMove');
            ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
            EffaceProprietesOfCurrentNode;
            with partie^^[nbreCoup] do
            begin
              DessinePion(DerniereCaseJouee,pionVide);

              jeu := JeuCourant;

              jeu[DerniereCaseJouee] := pionVide;
              for i := 1 to nbRetourne do
                jeu[retournes[i]] := -jeu[retournes[i]];

              SetJeuCourant(jeu,trait);

              for i := 1 to nbRetourne do
                DessinePion(retournes[i],GetCouleurOfSquareDansJeuCourant(retournes[i]));

              nbreDePions[trait] := nbreDePions[trait] - nbRetourne - 1;
              nbreDePions[-trait] := nbreDePions[-trait] + nbRetourne;

            end;
            tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
            tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
            tempsDesJoueurs[pionNoir].tick := 0;
            tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
            tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
            tempsDesJoueurs[pionBlanc].tick := 0;
            AjusteCurseur;

            ChangeCurrentNodeForBackMove;
            MarquerCurrentNodeCommeReel('DoDoubleBackMove');


            {
            with partie^^[nbreCoup] do
            begin
              trait := 0;
              x := coupInconnu;
              nbRetourne := 0;
            end;
            }
            IndexProchainFilsDansGraphe := -1;
            nbreCoup := nbreCoup-1;
            if nbreCoup >= 1
              then peutPlusReculer := (DerniereCaseJouee = coupInconnu)
              else peutPlusReculer := true;

            EffaceCourbe(nbreCoup,nbreCoup+1,kCourbePastel,'DoDoubleBackMove');
            DessineSliderFenetreCourbe;
          end;
       until (nbreCoup <= limiteInfNbreCoup) | peutPlusReculer;



       if EnVieille3D then Dessine3D(JeuCourant,false);
       if afficheNumeroCoup & (nbreCoup > 0) then
         if (DerniereCaseJouee <> coupInconnu) & InRange(DerniereCaseJouee,11,88)
           then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);
       {la}
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       InitialiseDirectionsJouables;
       CarteJouable(JeuCourant,emplJouable);
       CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
       CarteFrontiere(JeuCourant,frontiereCourante);
       {Initialise_table_heuristique(JeuCourant);}
       calculPrepHeurisFait := false;
       AfficheScore;
       if (HumCtreHum | (nbreCoup <= 0) | (AQuiDeJouer <> couleurMacintosh)) & not(enTournoi) then
          begin
            MyDisableItem(PartieMenu,ForceCmd);
            AfficheDemandeCoup;
          end;
       gameOver := false;
       if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
       if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       RefleSurTempsJoueur := false;
       LanceInterruptionSimpleConditionnelle('DoDoubleBackMove');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoDoubleBackMove');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoDoubleBackMove');
       vaDepasserTemps := false;
       reponsePrete := false;
       {peutfeliciter := true;}
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoDoubleBackMove');
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       PartieContreMacDeBoutEnBout := false;
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       dernierTick := TickCount;
       Heure(-AQuiDeJouer);
       Heure(AQuiDeJouer);


       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;

       EndFonctionModifiantNbreCoup('DoDoubleBackMove');

       LanceDemandeAffichageZebraBook('DoDoubleBackMove');
       AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleBackMove');
       if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

       FlushWindow(wPlateauPtr);

       if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);

     end;

     SetPort(oldport);


  end;
end;

procedure DoBackMovePartieSelectionnee(nroHilite : SInt32);
var s60,anciennePartie : PackedThorGame;
    couleurs : String255;
    nroreference : SInt32;
    coup,i,t,longueur : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup : SInt16;
    test,good,bidbool : boolean;
    jeu,anciennePositionCourante : plateauOthello;
    jouable : plBool;
    front : InfoFront;
    nbBlanc,nbNoir : SInt32;
    coulTrait,mobilite : SInt32;
    oldNode : GameTree;
    GameNodeAAtteindre : GameTree;
    axe : SInt16;
    oldCheckDangerousEvents : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
 if windowListeOpen & not(positionFeerique) & (nbreCoup > 0) then
   with infosListeParties do
     begin



       GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
		   {if (nroHilite >= premierNumero) & (nroHilite <= dernierNumero)
		    then}
		   if (nroHilite >= 1) & (nroHilite <= nbPartiesActives) then
		     begin



		      nroReference := infosListeParties.dernierNroReferenceHilitee;

		      ExtraitPartieTableStockageParties(nroReference,s60);
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup >= 4),1,60);

		      if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) &
		         not(TrouveSymetrieEgalisante(JeuCourant, nbreCoup, s60, axe)) then
	          begin
	            WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoBackMovePartieSelectionnee');
	            with DemandeCalculsPourBase do
	              if (EtatDesCalculs <> kCalculsEnCours) | (NumeroDuCoupDeLaDemande <> nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
	            exit(DoBackMovePartieSelectionnee);
	          end;


          test := true;
		      for i := 1 to nbreCoup do
		        begin
		          coup := GetNiemeCoupPartieCourante(i);
		          {patch pour les diagonales avec l'autre coup 4}
		          if autreCoupQuatreDansPartie & ((i = 1) | (i = 3))
		            then test := test & ((coup = GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(1)')) | (coup = CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(2)'),axeSE_NW)))
		            else test := test & (coup = GET_NTH_MOVE_OF_PACKED_GAME(s60, i,'DoBackMovePartieSelectionnee(3)'));
		        end;

		      if not(test) & (nbreCoup > 5) then
		        begin
		          if PartieDansLaListeIdentiqueAPartieCourante(nroReference, nbreCoup - 1, autreCoupQuatreDansPartie)
		            then test := true;
		        end;


		      if test
		        then
		          begin
		            PartieContreMacDeBoutEnBout := false;
		            DoBackMove;
		          end
		        else
		          begin

		            //BeginFonctionModifiantNbreCoup('DoBackMovePartieSelectionnee');
		            SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

		            anciennePositionCourante := JeuCourant;
		            couleurs := '';

		            longueur := nroDernierCoupAtteint;
		            if longueur < 0  then longueur := 0;
		            if longueur > 60 then longueur := 60;

		            FILL_PACKED_GAME_WITH_ZEROS(anciennePartie);
		            for i := 1 to longueur do
		              begin
		                SET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i, GetNiemeCoupPartieCourante(i));
		                if GetCouleurNiemeCoupPartieCourante(i) = pionNoir
		                  then couleurs := couleurs+CharToString('N')
		                  else couleurs := couleurs+CharToString('B');
		              end;
		            SET_LENGTH_OF_PACKED_GAME(anciennePartie,longueur);


		            MemoryFillChar(@jeu,sizeof(jeu),chr(0));
		            for i := 0 to 99 do
		              if interdit[i] then jeu[i] := PionInterdit;
		            jeu[54] := pionNoir;
		            jeu[45] := pionNoir;
		            jeu[44] := pionBlanc;
		            jeu[55] := pionBlanc;
		            coulTrait := pionNoir;
		            nbBlanc := 2;
		            nbNoir := 2;

		            SetPositionInitialeStandardDansGameTree;

		            InitialiseDirectionsJouables;
		            CarteJouable(jeu,jouable);
		            CarteFrontiere(Jeu,front);
		            good := true;

		            oldNode := GetCurrentNode;
		            SetCurrentNodeToGameRoot;
		            MarquerCurrentNodeCommeReel('DoBackMovePartieSelectionnee');

		            for i := 1 to nbreCoup-1 do
		             begin
		              InvalidateNombrePartiesActivesDansLeCache(i);
		              coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoBackMovePartieSelectionnee(4)');
		              good := good & (coup >= 11) & (coup <= 88);
		              if good then
		               if PeutJouerIci(coulTrait,coup,jeu)
		                then
		                 begin
		                  if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoup-1),'DoBackMovePartieSelectionnee(5)') = NoErr then DoNothing;
		                  good := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                  coulTrait := -coulTrait;
		                 end
		                else
		                 begin
		                  if PeutJouerIci(-coulTrait,coup,jeu)
		                    then
		                     begin
		                       coulTrait := -coulTrait;
		                       if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoup-1),'DoBackMovePartieSelectionnee(6)') = NoErr then DoNothing;
		                       good := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                       coulTrait := -coulTrait;
		                     end
		                    else
		                     good := false;
		                 end;
		              end;

		             if good then
		               begin
		                 SetPortByWindow(wPlateauPtr);
		                 SetJeuCourant(jeu, coulTrait);
		                 emplJouable := jouable;
		                 frontiereCourante := front;
		                 nbreDePions[pionBlanc] := nbBlanc;
		                 nbreDePions[pionNoir] := nbNoir;
		                 tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup].tempsUtilise.tempsNoir div 60;
		                 tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup].tempsUtilise.tempsNoir mod 60;
		                 tempsDesJoueurs[pionNoir].tick := 0;
		                 tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup].tempsUtilise.tempsBlanc div 60;
		                 tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup].tempsUtilise.tempsBlanc mod 60;
		                 tempsDesJoueurs[pionBlanc].tick := 0;
		                 IndexProchainFilsDansGraphe := -1;
		                 nbreCoup := nbreCoup-1;
		                 phaseDeLaPartie := CalculePhasePartie(nbreCoup);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 peutfeliciter := true;
		                (* if avecDessinCoupEnTete then EffaceCoupEnTete;
		                 SetCoupEntete(0);*)


                     RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
		                 EffaceAideDebutant(false,true,othellierToutEntier,'DoBackMovePartieSelectionnee');
		                 ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
		                 EffaceProprietes(oldNode);
		                 if afficheNumeroCoup
		                   then EffaceNumeroCoup(GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, (nbreCoup+1),'DoBackMovePartieSelectionnee(7)'), nbreCoup+1, oldNode);
		                 DessinePion(GET_NTH_MOVE_OF_PACKED_GAME(s60, (nbreCoup+1),'DoBackMovePartieSelectionnee(8)'),pionVide);
		                 for i := 1 to 64 do
		                   begin
		                     t := othellier[i];
		                     if GetCouleurOfSquareDansJeuCourant(t) <> pionVide then
		                       if GetCouleurOfSquareDansJeuCourant(t) <> anciennePositionCourante[t] then
		                         DessinePion(t,GetCouleurOfSquareDansJeuCourant(t));
		                   end;
		                 if EnVieille3D then Dessine3D(JeuCourant,false);
		                 if afficheNumeroCoup & (nbreCoup > 0)
		                   then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);

		                 gameOver := false;
		                 if (AQuiDeJouer = pionVide) then TachesUsuellesPourGameOver;

		                 AjusteCurseur;
		                 CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);

		                 PartieContreMacDeBoutEnBout := false;
		                 MetTitreFenetrePlateau;
		                 Initialise_table_heuristique(JeuCourant,false);
		                 meilleurCoupHum := 0;
		                 MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
		                 aideDebutant := false;
		                 dernierTick := TickCount;
		                 EssaieDisableForceCmd;

		                 if EnModeEntreeTranscript then EntrerPartieDansCurrentTranscript(nbreCoup);
		                 if afficheInfosApprentissage then EcritLesInfosDApprentissage;
		                 {la}

		                 EffacerTouteLaCourbe('DoBackMovePartieSelectionnee');
		                 DessineCourbe(kCourbeColoree,'DoBackMovePartieSelectionnee');
		                 DessineSliderFenetreCourbe;

		                 AfficheScore;
		                 if (HumCtreHum | (nbreCoup <= 0) | (AQuiDeJouer <> couleurMacintosh)) & not(enTournoi) then
		                    begin
		                      MyDisableItem(PartieMenu,ForceCmd);
		                      AfficheDemandeCoup;
		                    end;
		                 if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
		                 if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;

		                 jeu := JeuCourant;
		                 jouable := emplJouable;
		                 front := frontiereCourante;
		                 nbBlanc := nbreDePions[pionBlanc];
		                 nbNoir := nbreDePions[pionNoir];
		                 coulTrait := AQuiDeJouer;


		                 GameNodeAAtteindre := GetCurrentNode;

		                 coup := GET_NTH_MOVE_OF_PACKED_GAME(s60, (nbreCoup+1),'DoBackMovePartieSelectionnee(10)');
		                 if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,nbreCoup,true,true,'DoBackMovePartieSelectionnee(3)') = NoErr then DoNothing;
		                 bidbool := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                 for i := nbreCoup+2 to GET_LENGTH_OF_PACKED_GAME(anciennePartie) do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i,'DoBackMovePartieSelectionnee(11)');
		                     if couleurs[i] = 'B'
		                       then coulTrait := pionBlanc
		                       else coulTrait := pionNoir;
		                     if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,true,'DoBackMovePartieSelectionnee(4)') = NoErr then DoNothing;
		                     bidbool := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 nroDernierCoupAtteint := GET_LENGTH_OF_PACKED_GAME(anciennePartie);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 DessineBoiteDeTaille(wPlateauPtr);
		                 gDoitJouerMeilleureReponse := false;
		                 if not(HumCtreHum) then
		                   begin
		                     reponsePrete := false;
		                     RefleSurTempsJoueur := false;
		                     LanceInterruptionSimpleConditionnelle('DoBackMovePartieSelectionnee');
		                     LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoBackMovePartieSelectionnee');
                         LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoBackMovePartieSelectionnee');
		                     vaDepasserTemps := false;
		                   end;


		                 AjusteCurseur;

		                 DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
		                 MarquerCurrentNodeCommeReel('DoBackMovePartieSelectionnee');
		                 AddRandomDeltaStoneToCurrentNode;

		                 SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

		                 if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
		                    then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);

		                 LanceDemandeAffichageZebraBook('DoBackMovePartieSelectionnee');
		                 AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoBackMovePartieSelectionnee');
		                 if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

		                 FlushWindow(wPlateauPtr);
		           end;

		           //EndFonctionModifiantNbreCoup('DoBackMovePartieSelectionnee');
		           SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

		        end;

		     end;

		  end;
end;

procedure DoDoubleBackMovePartieSelectionnee(nroHilite : SInt32);
var s60,anciennePartie : PackedThorGame;
    couleurs : String255;
    nroreference : SInt32;
    coup,i,t,longueur : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup,ancienNbreCoup : SInt16;
    test,good,bidbool : boolean;
    jeu,anciennePositionCourante : plateauOthello;
    jouable : plBool;
    front : InfoFront;
    nbBlanc,nbNoir : SInt32;
    coulTrait,mobilite : SInt32;
    oldNode : GameTree;
    GameNodeAAtteindre : GameTree;
    axe : SInt16;
    oldCheckDangerousEvents : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) &
    windowListeOpen & not(positionFeerique) & (nbreCoup > 0) then
 if (nbreCoup = 1)
  then
    DoBackMovePartieSelectionnee(nroHilite)
  else
    with infosListeParties do
		  begin
		   GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
		   {if (nroHilite >= premierNumero) & (nroHilite <= dernierNumero)
		    then}
		   if (nroHilite >= 1) & (nroHilite <= nbPartiesActives) then
		     begin
		      nroReference := infosListeParties.dernierNroReferenceHilitee;

		      ExtraitPartieTableStockageParties(nroReference,s60);
		      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		      ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		      TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup >= 4),1,60);

		      if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) &
		         not(TrouveSymetrieEgalisante(JeuCourant, nbreCoup, s60, axe)) then
		        begin
		          WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoDoubleBackMovePartieSelectionnee');
		          with DemandeCalculsPourBase do
	              if (EtatDesCalculs <> kCalculsEnCours) | (NumeroDuCoupDeLaDemande <> nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
		          exit(DoDoubleBackMovePartieSelectionnee);
		        end;

		      test := true;
		      for i := 1 to nbreCoup do
		        begin
		          coup := GetNiemeCoupPartieCourante(i);
		          {patch pour les diagonales avec l'autre coup 4}
		          if autreCoupQuatreDansPartie & ((i = 1) | (i = 3))
		            then test := test & ((coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(1)')) |
		                                 (coup = CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(2)'),axeSE_NW)))
		            else test := test & (coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(3)'));
		        end;

		      if not(test) & (nbreCoup > 6) & PartieDansLaListeIdentiqueAPartieCourante(nroReference, nbreCoup - 2, autreCoupQuatreDansPartie)
		        then test := true;

		      if test
		        then
		          begin
		            PartieContreMacDeBoutEnBout := false;
		            DoDoubleBackMove;
		          end
		        else
		          begin

		            //BeginFonctionModifiantNbreCoup('DoDoubleBackMovePartieSelectionnee');
		            SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

		            anciennePositionCourante := JeuCourant;
		            couleurs := '';

		            longueur := nroDernierCoupAtteint;
		            if longueur < 0  then longueur := 0;
		            if longueur > 60 then longueur := 60;

		            FILL_PACKED_GAME_WITH_ZEROS(anciennePartie);
		            for i := 1 to longueur do
		              begin
		                SET_NTH_MOVE_OF_PACKED_GAME(anciennePartie, i, GetNiemeCoupPartieCourante(i));
		                if GetCouleurNiemeCoupPartieCourante(i) = pionNoir
		                  then couleurs := couleurs+CharToString('N')
		                  else couleurs := couleurs+CharToString('B');
		              end;
		            SET_LENGTH_OF_PACKED_GAME(anciennePartie,longueur);

		            oldNode := GetCurrentNode;
		            SetCurrentNodeToGameRoot;
		            MarquerCurrentNodeCommeReel('');

		            MemoryFillChar(@jeu,sizeof(jeu),chr(0));
		            for i := 0 to 99 do
		              if interdit[i] then jeu[i] := PionInterdit;
		            jeu[54] := pionNoir;
		            jeu[45] := pionNoir;
		            jeu[44] := pionBlanc;
		            jeu[55] := pionBlanc;
		            coulTrait := pionNoir;
		            nbBlanc := 2;
		            nbNoir := 2;
		            SetPositionInitialeStandardDansGameTree;
		            InitialiseDirectionsJouables;
		            CarteJouable(jeu,jouable);
		            CarteFrontiere(Jeu,front);
		            good := true;

		            for i := 1 to nbreCoup-2 do
		              begin
  		              InvalidateNombrePartiesActivesDansLeCache(i);
  		              coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(4)');
  		              good := good & (coup >= 11) & (coup <= 88);
  		              if good then
  		                if PeutJouerIci(coulTrait,coup,jeu)
  		                  then
  		                    begin
  		                      if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoup-2),'DoDoubleBackMovePartieSelectionnee(1)') = NoErr then DoNothing;
  		                      good := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
  		                      coulTrait := -coulTrait;
  		                    end
  		                  else
  		                    begin
  		                      if PeutJouerIci(-coulTrait,coup,jeu)
  		                        then
  		                          begin
  		                            coulTrait := -coulTrait;
  		                            if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoup-2),'DoDoubleBackMovePartieSelectionnee(2)') = NoErr then DoNothing;
  		                            good := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
  		                            coulTrait := -coulTrait;
  		                          end
  		                        else
  		                          good := false;
  		                    end;
		              end;

		            if good then
		               begin
		                 SetPortByWindow(wPlateauPtr);
		                 SetJeuCourant(jeu, coulTrait);
		                 emplJouable := jouable;
		                 frontiereCourante := front;
		                 nbreDePions[pionBlanc] := nbBlanc;
		                 nbreDePions[pionNoir] := nbNoir;
		                 ancienNbreCoup := nbreCoup;
		                 nbreCoup := nbreCoup-2;
		                 tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsNoir div 60;
		                 tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup+1].tempsUtilise.tempsNoir mod 60;
		                 tempsDesJoueurs[pionNoir].tick := 0;
		                 tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc div 60;
		                 tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc mod 60;
		                 tempsDesJoueurs[pionBlanc].tick := 0;
		                 IndexProchainFilsDansGraphe := -1;
		                 phaseDeLaPartie := CalculePhasePartie(nbreCoup);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 peutfeliciter := true;
		                (* if avecDessinCoupEnTete then EffaceCoupEnTete;
		                 SetCoupEntete(0);*)


                     RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
		                 EffaceAideDebutant(false,true,othellierToutEntier,'DoDoubleBackMovePartieSelectionnee');
		                 ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
		                 EffaceProprietes(oldNode);
		                 if afficheNumeroCoup
		                   then EffaceNumeroCoup(GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie,ancienNbreCoup,'DoDoubleBackMovePartieSelectionnee(5)'),ancienNbreCoup,oldNode);
		                 for i := nbreCoup+1 to ancienNbreCoup do
		                   DessinePion(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(6)'),pionVide);
		                 for i := 1 to 64 do
		                   begin
		                     t := othellier[i];
		                     if GetCouleurOfSquareDansJeuCourant(t) <> pionVide then
		                       if GetCouleurOfSquareDansJeuCourant(t) <> anciennePositionCourante[t] then
		                         DessinePion(t,GetCouleurOfSquareDansJeuCourant(t));
		                   end;
		                 if EnVieille3D then Dessine3D(JeuCourant,false);
		                 if afficheNumeroCoup & (nbreCoup > 0)
		                   then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);

		                 gameOver := false;
		                 if (AQuiDeJouer = pionVide) then TachesUsuellesPourGameOver;

		                 AjusteCurseur;
		                 CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);

		                 PartieContreMacDeBoutEnBout := false;
		                 MetTitreFenetrePlateau;
		                 Initialise_table_heuristique(JeuCourant,false);
		                 meilleurCoupHum := 0;
		                 MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
		                 aideDebutant := false;
		                 dernierTick := TickCount;
		                 EssaieDisableForceCmd;

		                 if EnModeEntreeTranscript then EntrerPartieDansCurrentTranscript(nbreCoup);
		                 if afficheInfosApprentissage then EcritLesInfosDApprentissage;
		                 {la}

		                 EffacerTouteLaCourbe('DoDoubleBackMovePartieSelectionnee');
		                 DessineCourbe(kCourbeColoree,'DoDoubleBackMovePartieSelectionnee');
		                 DessineSliderFenetreCourbe;

		                 AfficheScore;
		                 if (HumCtreHum | (nbreCoup <= 0) | (AQuiDeJouer <> couleurMacintosh)) & not(enTournoi) then
		                    begin
		                      MyDisableItem(PartieMenu,ForceCmd);
		                      AfficheDemandeCoup;
		                    end;
		                 if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
		                 if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;

		                 GameNodeAAtteindre := GetCurrentNode;

		                 jeu := JeuCourant;
		                 jouable := emplJouable;
		                 front := frontiereCourante;
		                 nbBlanc := nbreDePions[pionBlanc];
		                 nbNoir := nbreDePions[pionNoir];
		                 coulTrait := AQuiDeJouer;


		                 for i := nbreCoup+1 to ancienNbreCoup do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleBackMovePartieSelectionnee(7)');
		                     if couleurs[i] = 'B'
		                       then coulTrait := pionBlanc
		                       else coulTrait := pionNoir;
		                     if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = ancienNbreCoup),'DoDoubleBackMovePartieSelectionnee(3)') = NoErr then DoNothing;
		                     bidbool := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 for i := ancienNbreCoup+1 to GET_LENGTH_OF_PACKED_GAME(anciennePartie) do
		                   begin
		                     coup := GET_NTH_MOVE_OF_PACKED_GAME(anciennePartie,i,'DoDoubleBackMovePartieSelectionnee(8)');
		                     if couleurs[i] = 'B'
		                       then coulTrait := pionBlanc
		                       else coulTrait := pionNoir;
		                     if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = GET_LENGTH_OF_PACKED_GAME(anciennePartie)),'DoDoubleBackMovePartieSelectionnee(4)') = NoErr then DoNothing;
		                     bidbool := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
		                   end;
		                 nroDernierCoupAtteint := GET_LENGTH_OF_PACKED_GAME(anciennePartie);
		                 FixeMarqueSurMenuMode(nbreCoup);
		                 DessineBoiteDeTaille(wPlateauPtr);
		                 gDoitJouerMeilleureReponse := false;
		                 if not(HumCtreHum) then
		                   begin
		                     reponsePrete := false;
		                     RefleSurTempsJoueur := false;
		                     LanceInterruptionSimpleConditionnelle('DoDoubleBackMovePartieSelectionnee');
		                     LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoDoubleBackMovePartieSelectionnee');
                         LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoDoubleBackMovePartieSelectionnee');
		                     vaDepasserTemps := false;
		                   end;


		                 AjusteCurseur;



		                 DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
		                 MarquerCurrentNodeCommeReel('DoDoubleBackMovePartieSelectionnee');
		                 AddRandomDeltaStoneToCurrentNode;

		                 SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

		                 if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
		                   then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);


		                 LanceDemandeAffichageZebraBook('DoDoubleBackMovePartieSelectionnee');
		                 AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoDoubleBackMovePartieSelectionnee');
		                 if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

		                 FlushWindow(wPlateauPtr);
		              end;

		          //EndFonctionModifiantNbreCoup('DoDoubleBackMovePartieSelectionnee');
		          SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
		        end;
		     end;
     end;
end;

procedure DoDoubleAvanceMovePartieSelectionnee(nroHilite : SInt32);
var s60 : PackedThorGame;
    nroreference,i : SInt32;
    premierNumero,derniernumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup,coup : SInt16;
    test : boolean;
begin
 if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
 if windowListeOpen & not(positionFeerique) then
   with infosListeParties do
	   begin
	     GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,DernierNumero);
	     {if (nroHilite >= premierNumero) & (nroHilite <= dernierNumero) then}
	     if (nroHilite >= 1) & (nroHilite <= nbPartiesActives) then
	       begin
	         nroReference := infosListeParties.dernierNroReferenceHilitee;

		       ExtraitPartieTableStockageParties(nroReference,s60);
		       ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
		       ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
		       TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie & ouvertureDiagonale & (nbreCoup >= 4),1,60);

		       if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) then
		        begin
		          WritelnDansRapport('WARNING : not(PositionsSontEgales(…) dans DoDoubleAvanceMovePartieSelectionnee');
		          with DemandeCalculsPourBase do
	              if (EtatDesCalculs <> kCalculsEnCours) | (NumeroDuCoupDeLaDemande <> nbreCoup) | bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
		          exit(DoDoubleAvanceMovePartieSelectionnee);
		        end;

	         test := (nroDernierCoupAtteint >= (nbreCoup+2));
	         for i := nbreCoup+1 to nbreCoup+2 do
	           begin
	             coup := GetNiemeCoupPartieCourante(i);
		           {patch pour les diagonales avec l'autre coup 4}
		           if autreCoupQuatreDansPartie & ((i = 1) | (i = 3))
		             then test := test & ((coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(1)')) | (coup = CaseSymetrique(GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(2)'),axeSE_NW)))
		             else test := test & (coup = GET_NTH_MOVE_OF_PACKED_GAME(s60,i,'DoDoubleAvanceMovePartieSelectionnee(3)'));
		         end;
	         if test
	           then
	             DoDoubleAvanceMove
	           else
	             begin
	               JoueCoupPartieSelectionnee(nroHilite);
	               JoueCoupPartieSelectionnee(nroHilite);
	             end;
	          EngineNewPosition;
	        end;
	   end;
end;


procedure DoRetourAuCoupNro(numeroCoup : SInt32; NeDessinerQueLesNouveauxPions,ForceHumCtreHum : boolean);
var i,j : SInt32;
    mobilite : SInt32;
    oldport : grafPtr;
    anciensPionsDessines : plateauOthello;
    jeu : plateauOthello;
begin
  if windowPlateauOpen then
  begin
    GetPort(oldport);
    SetPortByWindow(wPlateauPtr);
    if nbreCoup > numeroCoup then
     begin

      BeginFonctionModifiantNbreCoup('DoRetourAuCoupNro');

      RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
      EffaceAideDebutant(false,true,othellierToutEntier,'DoRetourAuCoupNro');
      ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
      EffaceProprietesOfCurrentNode;

      anciensPionsDessines := JeuCourant;
      repeat
        if DerniereCaseJouee <> coupInconnu then
         begin
           with partie^^[nbreCoup] do
           begin
             jeu := JeuCourant;

             jeu[DerniereCaseJouee] := pionVide;
             for i := 1 to nbRetourne do
               begin
                 jeu[retournes[i]] := -jeu[retournes[i]];
               end;
             nbreDePions[trait] := nbreDePions[trait] - nbRetourne - 1;
             nbreDePions[-trait] := nbreDePions[-trait] + nbRetourne;

             SetJeuCourant(jeu,trait);
           end;
           {
           with partie^^[nbreCoup] do
           begin
             trait := 0;
             x := coupInconnu;
             nbRetourne := 0;
           end;
           }
           IndexProchainFilsDansGraphe := -1;
           nbreCoup := nbreCoup-1;

           ChangeCurrentNodeForBackMove;
           MarquerCurrentNodeCommeReel('DoRetourAuCoupNro');

         end;
       until (nbreCoup = numeroCoup) | (DerniereCaseJouee = coupInconnu);
       tempsDesJoueurs[pionNoir].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsNoir div 60;
       tempsDesJoueurs[pionNoir].sec := partie^^[nbreCoup+1].tempsUtilise.tempsNoir mod 60;
       tempsDesJoueurs[pionNoir].tick := 0;
       tempsDesJoueurs[pionBlanc].minimum := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc div 60;
       tempsDesJoueurs[pionBlanc].sec := partie^^[nbreCoup+1].tempsUtilise.tempsBlanc mod 60;
       tempsDesJoueurs[pionBlanc].tick := 0;
       AjusteCurseur;
       EnableItemPourCassio(PartieMenu,ForwardCmd);
       meilleurCoupHum := 44;
       meilleureReponsePrete := 44;
       gDoitJouerMeilleureReponse := false;
       if windowPlateauOpen then
         begin
           if NeDessinerQueLesNouveauxPions & not(CassioEstEn3D)
             then
               begin
                 SetPortByWindow(wPlateauPtr);
                 for i := 1 to 8 do
                   for j := 1 to 8 do
                     if anciensPionsDessines[10*i+j] <> GetCouleurOfSquareDansJeuCourant(10*i+j) then
                       DessinePion(10*i+j,GetCouleurOfSquareDansJeuCourant(10*i+j));
                 DessineGarnitureAutourOthellierPourEcranStandard;
                 if afficheNumeroCoup then
                   begin
                     if (nbreCoup > 0) & (DerniereCaseJouee <> coupInconnu) & InRange(DerniereCaseJouee,11,88)
                       then DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);
                   end;
               end
             else
               begin
                 EcranStandard(NIL,CassioEstEn3D)
               end;
         end;
       if afficheInfosApprentissage then EcritLesInfosDApprentissage;


       {la}
       if not(HumCtreHum) & not(CassioEstEnModeSolitaire) & ForceHumCtreHum
         then DoChangeHumCtreHum;
       EffaceCourbe(nbreCoup,61,kCourbePastel,'DoRetourAuCoupNro');
       InvalidateEvaluationPourCourbe(nroDernierCoupAtteint + 1, 61);
       DessineCourbe(kCourbeColoree,'DoRetourAuCoupNro');
       DessineSliderFenetreCourbe;
       gameOver := false;
       if afficheMeilleureSuite then EffaceMeilleureSuiteSiNecessaire;
       if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
       InitialiseDirectionsJouables;
       CarteJouable(JeuCourant,emplJouable);
       CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
       CarteFrontiere(JeuCourant,frontiereCourante);
       Initialise_table_heuristique(JeuCourant,false);
       RefleSurTempsJoueur := false;
       LanceInterruptionSimpleConditionnelle('DoRetourAuCoupNro');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoRetourAuCoupNro');
       LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoRetourAuCoupNro');
       vaDepasserTemps := false;
       reponsePrete := false;
       peutfeliciter := true;
       TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'DoRetourAuCoupNro');
      (* if avecDessinCoupEnTete then EffaceCoupEnTete;
       SetCoupEntete(0);*)
       PartieContreMacDeBoutEnBout := (numeroCoup <= 2);
       MetTitreFenetrePlateau;
       phaseDeLaPartie := CalculePhasePartie(nbreCoup);
       FixeMarqueSurMenuMode(nbreCoup);
       EssaieDisableForceCmd;
       enRetour := false;
       dernierTick := TickCount;
       Heure(-AQuiDeJouer);
       Heure(AQuiDeJouer);


       AjusteCurseur;
       AddRandomDeltaStoneToCurrentNode;


       EndFonctionModifiantNbreCoup('DoRetourAuCoupNro');


       LanceDemandeAffichageZebraBook('DoRetourAuCoupNro');
       AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoRetourAuCoupNro');
       if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

       FlushWindow(wPlateauPtr);

       if avecCalculPartiesActives & (windowListeOpen | windowStatOpen)
         then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);

       EngineNewPosition;

    end;
   SetPort(oldport);
  end;
end;

procedure DoAvanceAuCoupNro(numeroCoup : SInt16; neDessinerQueLesNouveauxPions : boolean);
var i,j,coup,coulTrait : SInt16;
    anciensPionsDessines : plateauOthello;
    ancienNbreCoup : SInt16;
    oldport : grafPtr;
    jeu : plateauOthello;
    jouable : plBool;
    front : InfoFront;
    nbBlanc,nbNoir : SInt32;
    good : boolean;
    mobilite : SInt32;
    oldCurrentNodeInGameTree : GameTree;
begin

  if CassioEstEnModeTournoi then exit(DoAvanceAuCoupNro);

  if (numeroCoup <= 0)
    then WritelnNumDansRapport('ASSERT : (numeroCoup <= 0) in DoAvanceAuCoupNro, value is ', numeroCoup);


  if (numeroCoup >= nbreCoup) & (numeroCoup <= nroDernierCoupAtteint) then
    begin

     BeginFonctionModifiantNbreCoup('DoAvanceAuCoupNro');

     anciensPionsDessines := JeuCourant;
     ancienNbreCoup := nbreCoup;
     jeu := JeuCourant;
     jouable := emplJouable;
     front := frontiereCourante;
     nbBlanc := nbreDePions[pionBlanc];
     nbNoir := nbreDePions[pionNoir];
     good := true;

     oldCurrentNodeInGameTree := GetCurrentNode;

     for i := nbreCoup+1 to numeroCoup do
       begin
        coup := GetNiemeCoupPartieCourante(i);
        coulTrait := GetCouleurNiemeCoupPartieCourante(i);
        if good then
          if PeutJouerIci(coulTrait,coup,jeu)
            then
              begin
                if JoueEnFictif(coup,coulTrait,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = numeroCoup),'DoAvanceAuCoupNro') = NoErr then DoNothing;
                good := ModifPlat(coup,coulTrait,jeu,jouable,nbblanc,nbNoir,front);
              end
            else
              begin
                good := false;
              end;
       end;


     if good then
       begin
         RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
         EffaceAideDebutant(false,true,othellierToutEntier,'DoAvanceAuCoupNro');
         ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
         nbreCoup := numeroCoup;

         SetJeuCourant(jeu, -GetCouleurDernierCoup);
         emplJouable := jouable;
         frontiereCourante := front;
         nbreDePions[pionBlanc] := nbBlanc;
         nbreDePions[pionNoir] := nbNoir;
         IndexProchainFilsDansGraphe := -1;
         phaseDeLaPartie := CalculePhasePartie(nbreCoup);
         FixeMarqueSurMenuMode(nbreCoup);
         peutfeliciter := true;
        (* if avecDessinCoupEnTete then EffaceCoupEnTete;
         SetCoupEntete(0);*)

         gameOver := false;
         if (AQuiDeJouer = pionVide) then TachesUsuellesPourGameOver;

         CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
         MetTitreFenetrePlateau;

         Initialise_table_heuristique(JeuCourant,false);
         meilleurCoupHum := 0;
         MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
         aideDebutant := false;
         dernierTick := TickCount;
         EssaieDisableForceCmd;
         if windowPlateauOpen then
           begin
             EffaceProprietes(oldCurrentNodeInGameTree);
             if NeDessinerQueLesNouveauxPions & not(EnVieille3D)
               then
                 begin
                   GetPort(oldport);
                   SetPortByWindow(wPlateauPtr);
                   if afficheNumeroCoup  & (ancienNbreCoup > 0) &
                      (GetNiemeCoupPartieCourante(ancienNbreCoup) <> coupInconnu) &
                      InRange(GetNiemeCoupPartieCourante(ancienNbreCoup),11,88) then
                      EffaceNumeroCoup(GetNiemeCoupPartieCourante(ancienNbreCoup),ancienNbreCoup,oldCurrentNodeInGameTree);
                   for i := 1 to 8 do
                     for j := 1 to 8 do
                       if anciensPionsDessines[10*i+j] <> GetCouleurOfSquareDansJeuCourant(10*i+j) then
                         DessinePion(10*i+j,GetCouleurOfSquareDansJeuCourant(10*i+j));
                   DessineGarnitureAutourOthellierPourEcranStandard;
                   if afficheNumeroCoup  & (nbreCoup > 0) &
                      (DerniereCaseJouee <> coupInconnu) &
                      InRange(DerniereCaseJouee,11,88) then
                      DessineNumeroCoup(DerniereCaseJouee,nbreCoup,-GetCouleurOfSquareDansJeuCourant(DerniereCaseJouee),GetCurrentNode);
                   SetPort(oldPort);
                 end
               else
                 begin
                   EcranStandard(NIL,EnVieille3D);
                   NoUpdateWindowPlateau;
                 end;
           end;
         if afficheInfosApprentissage then EcritLesInfosDApprentissage;
         {la}


         EffacerTouteLaCourbe('DoAvanceAuCoupNro');
         InvalidateEvaluationPourCourbe(nroDernierCoupAtteint + 1, 61);
         DessineCourbe(kCourbeColoree,'DoAvanceAuCoupNro');
         DessineSliderFenetreCourbe;

         DessineBoiteDeTaille(wPlateauPtr);
         AjusteCurseur;
         gDoitJouerMeilleureReponse := false;
         PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
         if (numeroCoup < nroDernierCoupAtteint)
           then EnableItemPourCassio(PartieMenu,ForwardCmd)
           else MyDisableItem(PartieMenu,ForwardCmd);
         EnableItemPourCassio(PartieMenu,BackCmd);
         if not(HumCtreHum) then
           begin
             reponsePrete := false;
             RefleSurTempsJoueur := false;
             LanceInterruptionSimpleConditionnelle('DoAvanceAuCoupNro');
             LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'DoAvanceAuCoupNro');
             LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'DoAvanceAuCoupNro');
             vaDepasserTemps := false;
           end;
         enRetour := false;

         AddRandomDeltaStoneToCurrentNode;
         LanceDemandeAffichageZebraBook('DoAvanceAuCoupNro');
         AfficheProprietesOfCurrentNode(false,othellierToutEntier,'DoAvanceAuCoupNro');
         if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

         FlushWindow(wPlateauPtr);

         if (windowListeOpen | windowStatOpen)
           then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);

         EngineNewPosition;
      end;

      EndFonctionModifiantNbreCoup('DoAvanceAuCoupNro');
   end;
end;




procedure DoRetourDerniereMarque;
var i,maximum : SInt16;
begin
 if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
  if (nbreCoup > 0) then
   begin
    maximum := -100;
    for i := 1 to marques[0] do
      if (marques[i] > maximum) & (marques[i] < nbreCoup) then
        maximum := marques[i];
    if (nbreCoupsApresLecture > 0) & not(positionFeerique) then
      if (nbreCoupsApresLecture > maximum) & (nbreCoupsApresLecture < nbreCoup) then
        maximum := nbreCoupsApresLecture;
    if (maximum <= 0)
      then DoDebut(false)
      else
        if (maximum < nbreCoup)
         then DoRetourAuCoupNro(maximum,true,not(CassioEstEnModeAnalyse))
         else DoDebut(false);
    EngineNewPosition;
   end;
end;

procedure DoAvanceProchaineMarque;
var i,maximum : SInt32;
begin
 if windowPlateauOpen & not(enRetour | enSetUp) then
  if (nbreCoup < nroDernierCoupAtteint) then
   begin
    maximum := 1000;
    for i := 1 to marques[0] do
      if (marques[i] < maximum) & (marques[i] > nbreCoup) then
        maximum := marques[i];
    if (nbreCoupsApresLecture > 0) & not(positionFeerique) then
      if (nbreCoupsApresLecture < maximum) & (nbreCoupsApresLecture > nbreCoup) then
        maximum := nbreCoupsApresLecture;
    if maximum > nroDernierCoupAtteint then maximum := nroDernierCoupAtteint;
    if (maximum > nbreCoup)
      then DoAvanceAuCoupNro(maximum,true);
    EngineNewPosition
   end;
end;


procedure DoAvanceProchainEmbranchement;
var i,k,nroCoupEmbranchement : SInt32;
    EmbranchementTrouve : boolean;
    nbrePartiesSuivies : SInt32;
begin
  if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
    if not(gameOver) then
      with infosListeParties do
      begin
        EmbranchementTrouve := false;
        nroCoupEmbranchement := -1;
        if windowListeOpen | windowListeOpen then
          if (nbPartiesChargees > 0) & (nbPartiesActives >= 1) then
            if CoupSuivantPartieSelectionnee(partieHilitee) = GetNiemeCoupPartieCourante(nbreCoup+1) then
              begin
                i := nbreCoup+1;
                nbrePartiesSuivies := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);

                if debuggage.general then
                  begin
                    EssaieSetPortWindowPlateau;
                    WriteNumAt('nbreCoup = ',nbreCoup,200,10);
                    WriteNumAt('nbrePartiesSuivies = ',nbrePartiesSuivies,200,20);
                    for k := 0 to 60 do
                    begin
                      EssaieSetPortWindowPlateau;
                      WriteNumAt('k = ',k,10,10+10*k);
                      WriteNumAt('n[k] = ',GetNombreDePartiesActivesDansLeCachePourCeCoup(k),50,10+10*k);
                    end;
                    AttendFrappeClavier;
                  end;

                if (nbrePartiesSuivies <> NeSaitPasNbrePartiesActives) then
                  repeat
                    if GetNombreDePartiesActivesDansLeCachePourCeCoup(i) <> nbrePartiesSuivies then
                      begin
                        EmbranchementTrouve := true;
                        nroCoupEmbranchement := i-1;
                      end;
                    i := i+1;
                  until EmbranchementTrouve | (i > nroDernierCoupAtteint);
                if (i > nroDernierCoupAtteint) & not(EmbranchementTrouve) then
                  begin
                    EmbranchementTrouve := true;
                    nroCoupEmbranchement := nroDernierCoupAtteint;
                  end;

              end;
        if not(EmbranchementTrouve) | (nroCoupEmbranchement <= nbreCoup+1) | (nroCoupEmbranchement = 2)
          then
            if windowlisteOpen & (nbPartiesActives >= 1)
              then JoueCoupPartieSelectionnee(partieHilitee)
              else DoAvanceMove
          else
            if nroCoupEmbranchement = nbreCoup-2
              then DoDoubleAvanceMove
              else DoAvanceAuCoupNro(nroCoupEmbranchement,true);
      end;
end;


procedure DoRetourDernierEmbranchement;
var i,k,nroCoupEmbranchement : SInt32;
    EmbranchementTrouve : boolean;
    nbrePartiesSuivies : SInt32;
begin
  if windowPlateauOpen & not(enRetour | enSetUp | CassioEstEnModeTournoi) then
    if (nbreCoup > 0) then
      begin
        EmbranchementTrouve := false;
        nroCoupEmbranchement := -1;
        if windowListeOpen | windowListeOpen then
          if (nbPartiesChargees > 0) then
            begin

              i := nbreCoup-1;
              nbrePartiesSuivies := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);

              if debuggage.general then
                  begin
                    EssaieSetPortWindowPlateau;
                    WriteNumAt('nbreCoup = ',nbreCoup,200,10);
                    WriteNumAt('nbrePartiesSuivies = ',nbrePartiesSuivies,200,20);
                    for k := 0 to 60 do
                    begin
                      EssaieSetPortWindowPlateau;
                      WriteNumAt('k = ',k,10,10+10*k);
                      WriteNumAt('n[k] = ',GetNombreDePartiesActivesDansLeCachePourCeCoup(k),50,10+10*k);
                    end;
                    AttendFrappeClavier;
                  end;


              if (nbrePartiesSuivies <> NeSaitPasNbrePartiesActives) then
                repeat
                  if (GetNombreDePartiesActivesDansLeCachePourCeCoup(i) <> nbrePartiesSuivies) then
                    begin
                      EmbranchementTrouve := true;
                      nroCoupEmbranchement := i;
                    end;
                  i := i-1;
                until EmbranchementTrouve | (i < 0);
              if (i < 0) & not(EmbranchementTrouve) then
                  begin
                    EmbranchementTrouve := true;
                    nroCoupEmbranchement := 0;
                  end;
            end;
        if not(EmbranchementTrouve) | (nroCoupEmbranchement = nbreCoup-1)
          then DoBackMove
          else if nroCoupEmbranchement = nbreCoup-2
	              then DoDoubleBackMove
	              else DoRetourAuCoupNro(nroCoupEmbranchement,true,not(CassioEstEnModeAnalyse));
      end;
end;


procedure SeDeplacerDansLaPartieDeTantDeCoups(deplacement : SInt32; useLiveUndo : boolean);
var numeroCoup : SInt32;
begin

  if deplacement <> 0 then
    begin
      numeroCoup := nbreCoup + deplacement;

      if (numeroCoup <= 0) then numeroCoup := 0;
      if (numeroCoup >= nroDernierCoupAtteint) then numeroCoup := nroDernierCoupAtteint;

      if (numeroCoup <> nbreCoup) & PeutArreterAnalyseRetrograde then
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
              end
            else
              if numeroCoup > nbreCoup then
                begin
                  if numeroCoup = nbreCoup+1
                    then
                      begin
                        DoAvanceMove;
                        if useLiveUndo then
                          BeginLiveUndo(GetEnsembleDesCoupsDesFreresReels(GetCurrentNode),15);
                      end
                    else DoAvanceAuCoupNro(numeroCoup,not(CassioEstEnModeAnalyse));
                end;
        end;
    end;
end;


const gNiveauRecursionFonctionsModifiantNbreCoup : SInt32 = 0;
var gPileDesFonctionsModifiantNbreCoup :
       array[1..10] of record
                         name : String255;
                         dangerousEvents : boolean;
                       end;


procedure BeginFonctionModifiantNbreCoup(fonctionAppelante : String255);
var k : SInt32;
    currentDangerousEventsChecking : boolean;
begin
  inc(gNiveauRecursionFonctionsModifiantNbreCoup);

  if (gNiveauRecursionFonctionsModifiantNbreCoup >= 1) & (gNiveauRecursionFonctionsModifiantNbreCoup <= 10) then
    with gPileDesFonctionsModifiantNbreCoup[gNiveauRecursionFonctionsModifiantNbreCoup] do
      begin
        name := fonctionAppelante;
        SetCassioMustCheckDangerousEvents(false,@currentDangerousEventsChecking);
        dangerousEvents := currentDangerousEventsChecking;
      end;

  if gNiveauRecursionFonctionsModifiantNbreCoup <> 1 then
    begin
      WritelnDansRapport('ASSERT dans BeginFonctionModifiantNbreCoup !!');
      WritelnDansRapport('    les fonctions modifiant nbreCoup ne sont pas reentrantes !!');
      WritelnDansRapport('    fonction appelante = '+fonctionAppelante);
      WritelnNumDansRapport('    gNiveauRecursionFonctionsModifiantNbreCoup = ',gNiveauRecursionFonctionsModifiantNbreCoup);
      for k := 1 to gNiveauRecursionFonctionsModifiantNbreCoup do
        WritelnDansRapport('    pile['+NumEnString(k)+'] = '+gPileDesFonctionsModifiantNbreCoup[k].name);
      WritelnDansRapport('');
    end;
end;


procedure EndFonctionModifiantNbreCoup(fonctionAppelante : String255);
var k : SInt32;
begin


  if (gNiveauRecursionFonctionsModifiantNbreCoup >= 1) & (gNiveauRecursionFonctionsModifiantNbreCoup <= 10)  then
    with gPileDesFonctionsModifiantNbreCoup[gNiveauRecursionFonctionsModifiantNbreCoup] do
      begin

        if (name <> fonctionAppelante) then
          begin
            WritelnDansRapport('ASSERT dans EndFonctionModifiantNbreCoup !!');
            WritelnDansRapport('    appels de Begin/End non équilibrés !!');
            WritelnDansRapport('    fonction appelante = '+fonctionAppelante);
            WritelnNumDansRapport('    gNiveauRecursionFonctionsModifiantNbreCoup = ',gNiveauRecursionFonctionsModifiantNbreCoup);
            for k := 1 to gNiveauRecursionFonctionsModifiantNbreCoup do
              WritelnDansRapport('    pile['+NumEnString(k)+'] = '+name);
            WritelnDansRapport('');
          end;

       SetCassioMustCheckDangerousEvents(dangerousEvents,NIL);

     end;

  dec(gNiveauRecursionFonctionsModifiantNbreCoup);

  if gNiveauRecursionFonctionsModifiantNbreCoup <> 0 then
    begin
      WritelnDansRapport('ASSERT dans EndFonctionModifiantNbreCoup !!');
      WritelnDansRapport('    les fonctions modifiant nbreCoup ne sont pas reentrantes !!');
      WritelnDansRapport('    fonction appelante = '+fonctionAppelante);
      WritelnNumDansRapport('    gNiveauRecursionFonctionsModifiantNbreCoup = ',gNiveauRecursionFonctionsModifiantNbreCoup);
      for k := 1 to gNiveauRecursionFonctionsModifiantNbreCoup do
        WritelnDansRapport('    pile['+NumEnString(k)+'] = '+gPileDesFonctionsModifiantNbreCoup[k].name);
      WritelnDansRapport('');
    end;



end;




END.
