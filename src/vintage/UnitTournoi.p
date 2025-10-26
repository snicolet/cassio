UNIT UnitTournoi;


INTERFACE




USES UnitDefCassio, UnitDefParallelisme, UnitDefTournoi;


{ initialisation de l'unite }
procedure InitUnitTournoi;
procedure LibereMemoireUnitTournoi;


{ quelques fonctions de test pour savoir si on est en tournoi }
function CassioEstEnModeTournoi : boolean;
procedure SetCassioEstEnModeTournoi(flag : boolean);


{ pour tester les algos de finale de Cassio }
procedure AlignerTestsFinales(NumeroDeb,numeroFin : SInt16; typeFinaleAlgoReference,typeFinaleAlgoFast : SInt16);


{ organisation d'un tournoi entre moteurs }
function OuvrirFichierTournoiEntreEngines(nomCompletFichier : String255) : OSErr;
function PeutLireParametresTournoisEntreEnginesDansFichier(path : String255; var tournoi : ToutesRondesRec) : boolean;
procedure FaireUnTournoiToutesRondesEntreEngines(var tournoi : ToutesRondesRec);
procedure CreerTournoiToutesRondes(var tournoi : ToutesRondesRec);
procedure FaireTournerParticipantsTournoiToutesRondes(nroRonde : SInt32; var tournoi : ToutesRondesRec);
procedure SauvegarderEtatGlobalDeCassioAvantLeTournoi;
procedure RemettreEtatGlobalDeCassioApresLeTournoi;


{ un match dans un tournoi }
function FaireUnMatch(var match : MatchTournoiRec; var ouverturesDejaJouees : StringSet) : double_t;
procedure ResetStatistiquesDuMatch(var theMatch : MatchTournoiRec);
procedure ChoisirUneOuvertureEquilibree(var ouverture : OuvertureRec; var ouverturesInterdites : StringSet);


{ gestion des moteurs pour une partie }
procedure ArreterLesAnciensMoteurs;
procedure LancerLesMoteursPourCettePartie(joueur1, joueur2 : SInt32);
function NomDeLEngineDansLeMatch(match : MatchTournoiRec; nroJoueur : SInt32) : String255;
function NumeroDuMoteurParlantDansCeCanal(nroCanal : SInt32) : SInt32;


{ affichage des scores a l'ecran ou dans le rapport }
procedure EcrireDeuxPartiesDuMatchDansRapport(match : MatchTournoiRec);
procedure EcrireClassementTournoiDansRapport(var tournoi : ToutesRondesRec; nroDuCeTour : SInt32);
procedure EcritScoreMatch(match : MatchTournoiRec; ScoreUnAGauche : boolean);
procedure EcrireAnnonceTournoiDansRapport(var tournoi : ToutesRondesRec; var match : MatchTournoiRec);
procedure EcrireConclusionDuTournoiDansRapport(var tournoi : ToutesRondesRec);
procedure EcrireAnnonceDeLaRondeDansRapport(var tournoi : ToutesRondesRec; tours : SInt32);
procedure EcrireAnnonceDuMatchDansRapport(var tournoi : ToutesRondesRec; var match : MatchTournoiRec);
procedure EcrireConclusionDuMatchDansRapport(var tournoi : ToutesRondesRec; scoreDuJoueur2 : double_t);
procedure BeginInfosTournoiDansRapport;
procedure EndInfosTournoisDansRapport;


{ calcul des variations Elo }
function CalculateEloErrorBar(numberOfGames : SInt32) : double_t;
function CalculateEloIncrease(p : double_t) : double_t;


{ tournoi entre deviations de Cassio }
procedure DoDemo(niveau1,niveau2 : SInt32; avecAttente,avecSauvegardePartieDansListe : boolean);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, UnitDefEngine, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitFenetres, UnitMilieuDePartie, UnitNouvelleEval, UnitUtilitaires, UnitZoo
    , UnitGestionDuTemps, UnitPalette, UnitActions, UnitBibl, UnitServicesMemoire, UnitSuperviseur, UnitJeu, UnitPotentiels
    , UnitBords, UnitEntreesSortiesGraphe, UnitListe, UnitEntreesSortiesListe, UnitTroisiemeDimension, UnitApprentissagePartie, UnitRapport, UnitCarbonisation
    , UnitUtilitairesFinale, UnitPhasesPartie, UnitFinaleFast, UnitArbreDeJeuCourant, UnitBitboardAlphaBeta, MyStrings, UnitNormalisation, UnitPackedThorGame
    , UnitBitboardFlips, UnitParallelisme, MyFileSystemUtils, MyMathUtils, SNEvents, UnitEvenement, UnitAffichagePlateau, UnitFichiersTEXT
    , UnitGeneralSort, UnitServicesRapport, UnitPositionEtTrait, UnitZooAvecArbre, UnitZoo, UnitSolve, UnitCriteres, UnitMiniProfiler
    , UnitEngine, UnitAffichageReflexion, UnitRapportUtils, UnitRapportImplementation, UnitScannerOthellistique, UnitCurseur, UnitStringSet, UnitMenus
    , UnitBufferedPICT, UnitAffichagePlateau, UnitBaseNouveauFormat, UnitCouleur ;
{$ELSEC}
    ;
    {$I prelink/Tournoi.lk}
{$ENDC}


{END_USE_CLAUSE}




(* dans chaque passe *)
const kNombreDeviationTesteesSurPourcentage = 15;
      kNombreDeviationTesteesSurPions       = 0;
      kNombreViellesDeviationTestees        = 0;
      kNombreDeviationsDansLeTournoi        = 15;

      kNombreMaxDeviationsTesteesParPasse = 625;
      kFaireCetteDeviation = 1;
      kIndexJoueurSansDeviation = 312;

const kNombrePartiesParMatchDansDemo = 12;

const kEngineSpecialCassioEdmond    = -1000;
      kEngineSpecialBip             = -1001;


type DeviationRecord = record
                         nombreParties : SInt32;
                         pions : SInt32;
                         nbreGains : SInt32;
                         flags : SInt32;
                       end;
     DeviationArray = array[-2..2,-2..2,-2..2,-2..2] of DeviationRecord;
     DeviationArrayPtr = ^DeviationArray;

var deviations : DeviationArrayPtr;
    table_de_tri_des_deviations : array[0..624] of SInt32;
    deviations_a_tester :
      record
        numeros : array[1..kNombreMaxDeviationsTesteesParPasse] of SInt32;
        cardinal : SInt32;
      end;
    deja_au_moins_un_match_en_memoire : boolean;
    auxLog : boolean;
    gCassioEstEnTournoi : boolean;

    doitArreterLeMoteurDeCeCanal      : array[0..1] of boolean;
    numeroMoteurDeCeCanal             : array[0..1] of SInt32;

    tournoiDeviations : ToutesRondesRec;

    tournoiEngines : ToutesRondesRec;

    gEtatGlobalDeCassioAvantTournoi :
      record
        sauvegardeInfosTechniques               : boolean;
        sauvegardeHumCtreHum                    : boolean;
        sauvegardeInterruption                  : SInt16;
        sauvegardeEngineEnCours                 : SInt32;
        sauvegardeAvecBibl                      : boolean;
        sauvegardeCassioVarieSesCoups           : boolean;
        sauvegardeLevel                         : SInt32;
        sauvegardeNbCoupsEnTete                 : SInt32;
        sauvegardeAvecEvaluationTotale          : boolean;
        sauvegardeProfImposee                   : boolean;
        sauvegardeFinDePartieVitesseMac         : SInt32;
        sauvegardeFinDePartieOptimaleVitesseMac : SInt32;
        sauvegardeUtiliserGrapheApprentissage   : boolean;
        sauvegardeEcritToutDansRapport          : boolean;
        sauvegardeDiscretisationEval            : boolean;
        sauvegardeAvecSelectivite               : boolean;
        sauvegardeCadence                       : SInt32;
        sauvegardeCadencePersoAffichee          : SInt32;
        sauvegardeJeuInstantane                 : boolean;
        sauvegardeNeJamaisTomberAuTemps         : boolean;
        sauvegardeAfficheSuggestionDeCassio     : boolean;
        sauvegardeAfficheMeilleureSuite         : boolean;
        sauvegardeAfficheNumeroCoup             : boolean;
      end;


(*
 *******************************************************************************
 *                                                                             *
 *   InitUnitTournoi est appelee par Cassio au demarrage et initialise le      *
 *   module de gestion des tournois.                                            *
 *                                                                             *
 *******************************************************************************
 *)
procedure InitUnitTournoi;
begin
  deviations := NIL;
  deja_au_moins_un_match_en_memoire := false;
  doitArreterLeMoteurDeCeCanal[0] := true;
  doitArreterLeMoteurDeCeCanal[1] := false;

  numeroMoteurDeCeCanal[0] := 0;
  numeroMoteurDeCeCanal[1] := 0;

  tournoiDeviations.ouverturesDejaJouees := MakeEmptyStringSet;
  tournoiEngines.ouverturesDejaJouees := MakeEmptyStringSet;

  SetCassioEstEnModeTournoi(false);
end;


(*
 *******************************************************************************
 *                                                                             *
 *   LibereMemoireUnitTournoi est appelee par Cassio quand il quitte.          *
 *                                                                             *
 *******************************************************************************
 *)
procedure LibereMemoireUnitTournoi;
begin
  if (deviations <> NIL) then DisposeMemoryPtr(Ptr(deviations));

  DisposeStringSet(tournoiDeviations.ouverturesDejaJouees);
  DisposeStringSet(tournoiEngines.ouverturesDejaJouees);

end;


(*
 ********************************************************************************
 *                                                                              *
 *   CassioEstEnModeTournoi permet de savoir si Cassio est en train d'organiser *
 *   un tournoi (par exemple entre moteurs).                                    *
 *                                                                              *
 ********************************************************************************
 *)
function CassioEstEnModeTournoi : boolean;
begin
  CassioEstEnModeTournoi := gCassioEstEnTournoi;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   SetCassioEstEnModeTournoi : le drapeau est mis a true en debut de tournoi *
 *                                                                             *
 *******************************************************************************
 *)
procedure SetCassioEstEnModeTournoi(flag : boolean);
begin
  gCassioEstEnTournoi := flag;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   FaireTournerParticipantsTournoiToutesRondes applique l'algo Tastet pour   *
 *   trouver les appariements de la n-ieme ronde d'un tournoi toutes-rondes.   *
 *   On rappelle qu'il vaut mieux que le bip soit le pivot (numero 0).         *
 *                                                                             *
 *******************************************************************************
 *)
procedure FaireTournerParticipantsTournoiToutesRondes(nroRonde : SInt32; var tournoi : ToutesRondesRec);
var k,r,temp : SInt32;
begin
  with tournoi do
    begin
      (* recopier la liste des partipants *)
      for k := 0 to nbParticipants - 1 do
        tableauTouteRonde[k] := k;

      (* faire tourner tout le monde, sauf le pivot *)
      for r := 1 to nroRonde - 1 do
        begin
          temp := tableauTouteRonde[nbParticipants - 1];
          for k := nbParticipants - 1 downto 2 do
            tableauTouteRonde[k] := tableauTouteRonde[k - 1];
          tableauTouteRonde[1] := temp;
        end;

      (*
      for k := 0 to nbParticipants - 1 do
        WriteNumDansRapport('',tableauTouteRonde[k]);
      WritelnDansRapport('');
      *)

    end;
end;


(*
 ********************************************************************************
 *                                                                              *
 *   ResetStatistiquesDuMatch : remise a zero des scores d'un match du tournoi. *
 *                                                                              *
 ********************************************************************************
 *)
procedure ResetStatistiquesDuMatch(var theMatch : MatchTournoiRec);
begin
  theMatch.fanny[1]                               := 0;
  theMatch.fanny[2]                               := 0;
  theMatch.scoreCumule[1]                         := 0;
  theMatch.scoreCumule[2]                         := 0;
  theMatch.nbreDePionsPartiePrecedente[pionNoir]  := 0;
  theMatch.nbreDePionsPartiePrecedente[pionBlanc] := 0;
  theMatch.partiePrecedente                       := '';
  theMatch.partieActuelle                         := '';
end;


(*
 ********************************************************************************
 *                                                                              *
 *   NomDeLEngineDansLeMatch : renvoie le nom d'un moteur du tournoi.           *
 *                                                                              *
 ********************************************************************************
 *)
function NomDeLEngineDansLeMatch(match : MatchTournoiRec; nroJoueur : SInt32) : String255;
var nom : String255;
begin
  if (match.typeDeMatch <> ENTRE_ENGINES)
    then nom := ''
    else
      if (nroJoueur > 0)
        then nom := GetEngineName(nroJoueur)
        else
          if (nroJoueur = kEngineSpecialBip)
            then nom := 'Bip'
            else nom := 'Cassio';
  nom[1] := UpCase(nom[1]);
  NomDeLEngineDansLeMatch := nom;
end;

(*
 ********************************************************************************
 *                                                                              *
 *   NumeroDuMoteurParlantDansCeCanal : pendant les tournois, renvoie le numero *
 *   du moteur communicant via le bundle intermediaire sur le channel "nroCanal"*
 *   (nroCanal = 0 ou 1 selon le dernier SwitchToEngine)                        *
 *                                                                              *
 ********************************************************************************
 *)
function NumeroDuMoteurParlantDansCeCanal(nroCanal : SInt32) : SInt32;
begin
  if not(enTournoi) then
    begin
      NumeroDuMoteurParlantDansCeCanal := 0;
      exit(NumeroDuMoteurParlantDansCeCanal);
    end;

  if (nroCanal < 0) or (nroCanal > 1) then
    begin
      NumeroDuMoteurParlantDansCeCanal := 0;
      exit(NumeroDuMoteurParlantDansCeCanal);
    end;

  NumeroDuMoteurParlantDansCeCanal := numeroMoteurDeCeCanal[nroCanal];
end;





(*
 ********************************************************************************
 *                                                                              *
 *   CalculateEloErrorBar : calcule l'intervalle de confiance à 95% de la va-   *
 *   riation de l'Elo dans un match un contre un, apres numberOfGames parties.  *
 *   Voir http://www.talkchess.com/forum/viewtopic.php?t = 31401                *
 *                                                                              *
 ********************************************************************************
 *)
function CalculateEloErrorBar(numberOfGames : SInt32) : double_t;
begin
  if (numberOfGames <= 0)
    then CalculateEloErrorBar := 1200.0
    else CalculateEloErrorBar := 560 * sqrt(2) / sqrt(numberOfGames);
end;


(*
 ********************************************************************************
 *                                                                              *
 *   CalculateEloIncrease : calcule l'accroissement de Elo de A par rapport a B *
 *   lorsque A fait contre B un score de p (0.0 <= p <= 1.0)                    *
 *   Voir http://fr.wikipedia.org/wiki/Classement_Elo                           *
 *                                                                              *
 ********************************************************************************
 *)
function CalculateEloIncrease(p : double_t) : double_t;
begin
  if (p <= 0.01) then CalculateEloIncrease := -1000.0 else
  if (p >= 0.99) then CalculateEloIncrease := +1000.0 else
    CalculateEloIncrease := ln(p / (1.0 - p)) * 400.0 / ln(10.0);
end;



(*
 ********************************************************************************
 *                                                                              *
 *   EcritScoreMatch : affichage des resultat d'un match dans le rapport        *
 *                                                                              *
 ********************************************************************************
 *)
 procedure EcritScoreMatch(match : MatchTournoiRec; ScoreUnAGauche : boolean);
 var oldport : grafPtr;
     posV : SInt32;
     ligneRect : rect;
     local1,local2,localMin,localMax : SInt32;
     gauche, droite : SInt32;
     len : SInt32;
     s1,s2 : String255;
     secondePartieSynchro : boolean;
     nbreNoirs,nbreBlancs : SInt32;
     scorePourNoirPartiePrecedente : SInt32;
     ombrageRect : rect;
     tailleOmbrageDuBouton, radius : SInt32;
     couleurDuBois : RGBColor;
     posDroite : SInt32;
     plusLongueChaineDroite : String255;
   begin
     if windowPlateauOpen then
       with match do
       begin
         GetPort(oldPort);
         SetPortByWindow(wPlateauPtr);

         PrepareTexteStatePourHeure;

         secondePartieSynchro := (nbreDePionsPartiePrecedente[pionNoir] + nbreDePionsPartiePrecedente[pionBlanc] <> 0);

         gauche := 15;
         droite := 115;

         s1 := NomDeLEngineDansLeMatch(match,joueur1);
         if (niveau1 >= 0) then s1 := s1 + ' (prof ' + NumEnString(niveau1) + ')';

         s2 := NomDeLEngineDansLeMatch(match,joueur2);
         if (niveau2 >= 0) then s2 := s2 + ' (prof ' + NumEnString(niveau2) + ')';

         if secondePartieSynchro
           then len := Max(LENGTH_OF_STRING(s1), LENGTH_OF_STRING(s2))
           else len := LENGTH_OF_STRING(s1);

         if (len >= 13) then
           droite := droite + 20 + (len - 13) * 6;

         if ScoreUnAGauche
            then
              begin
                local1 := aireDeJeu.right + gauche;
                local2 := aireDeJeu.right + droite;
              end
            else
              begin
                local1 := aireDeJeu.right + droite;
                local2 := aireDeJeu.right + gauche;
              end;

          localMin := local1;
          localMax := local2;
          if local2 < localMin then
            begin
              localMin := local2;
              localMax := local1;
            end;
          plusLongueChaineDroite := '';


          posV := 75;
          SetRect(ligneRect,localMin,posV-12,512,posV+10);
          //MyEraseRect(ligneRect);
          MyEraseRectWithColor(ligneRect,OrangeCmd,blackPattern,'');

          Moveto(local2,posV);
          s1 := NomDeLEngineDansLeMatch(match,joueur2);
          if (niveau2 >= 0) then s1 := s1 + ' (prof ' + NumEnString(niveau2) + ')';
          if (typeDeMatch <> ENTRE_ENGINES) then s1 := s1+' (n°2)';
          MyDrawString(s1);
          if (local2 = localMax) and (LENGTH_OF_STRING(s1) > LENGTH_OF_STRING(plusLongueChaineDroite))
            then plusLongueChaineDroite := s1;

          if (typeDeMatch <> ENTRE_ENGINES) then
            begin
              Moveto(local2,posV+10);
              s1 := NumEnString(fanny[2] div 2);
              if odd(fanny[2]) then s1 := s1 + '.5';
              s2 := NumEnString(scorecumule[2]);
              MyDrawString(s1+'   '+s2);
            end;

          if (fanny[2]+fanny[1]) <> 0 then
            begin
              Moveto(local2,posV+20);
              s1 := ReelEnString(100.0*fanny[2]/(1.0*(fanny[2]+fanny[1])));
              MyDrawString(s1+' %');
            end;

          Moveto(local1,posV);
          s1 := NomDeLEngineDansLeMatch(match,joueur1);
          if (niveau1 >= 0) then s1 := s1 + ' (prof ' + NumEnString(niveau1) + ')';
          if (typeDeMatch <> ENTRE_ENGINES) then s1 := s1+' (n°1)';
          MyDrawString(s1);
          if (local1 = localMax) and (LENGTH_OF_STRING(s1) > LENGTH_OF_STRING(plusLongueChaineDroite))
            then plusLongueChaineDroite := s1;

          if (typeDeMatch <> ENTRE_ENGINES) then
            begin
              Moveto(local1,posV+10);
              s1 := NumEnString(fanny[1] div 2);
              if odd(fanny[1]) then s1 := s1 + '.5';
              s2 := NumEnString(scorecumule[1]);
              MyDrawString(s1+'   '+s2);
            end;


          if (fanny[2]+fanny[1]) <> 0 then
            begin
              Moveto(local1,posV+20);
              s1 := ReelEnString(100.0*fanny[1]/(1.0*(fanny[2]+fanny[1])));
              MyDrawString(s1+' %');
            end;

          {si c'est la seconde partie d'un match synchro, on ecrit le score de la premiere}
          if secondePartieSynchro then
            begin
              nbreNoirs  := nbreDePionsPartiePrecedente[pionNoir];
              nbreBlancs := nbreDePionsPartiePrecedente[pionBlanc];
              scorePourNoirPartiePrecedente := nbreNoirs - nbreBlancs;

              Moveto(Min(local1,local2),posV + 40);
              MyDrawString('precédente : ');
              Moveto(Min(local1,local2),posV + 40 + 12);
              s1 := '';
              if (typeDeMatch = ENTRE_ENGINES) then s1 := s1 + NomDeLEngineDansLeMatch(match,joueur1)+' ';
              if (scorePourNoirPartiePrecedente > 0)
                then s1 := s1 + '+' + NumEnString(scorePourNoirPartiePrecedente)
                else s1 := s1 +       NumEnString(scorePourNoirPartiePrecedente);
              MyDrawString(s1);

              Moveto(Max(local1,local2),posV + 40);
              MyDrawString('precédente : ');
              Moveto(Max(local1,local2),posV + 40 + 12);
              s2 := '';
              if (typeDeMatch = ENTRE_ENGINES) then s2 := s2 + NomDeLEngineDansLeMatch(match,joueur2)+ ' ';
              if (scorePourNoirPartiePrecedente < 0)
                then s2 := s2 + '+' + NumEnString(-scorePourNoirPartiePrecedente)
                else s2 := s2 +       NumEnString(-scorePourNoirPartiePrecedente);
              MyDrawString(s2);
              if (LENGTH_OF_STRING(s2) > LENGTH_OF_STRING(plusLongueChaineDroite))
                then plusLongueChaineDroite := s2;

            end;

          {on dessine l'ombrage}
          if not(CassioEstEn3D) then
            begin
              posDroite := localMax + MyStringWidth(plusLongueChaineDroite) + 47;
              SetRect(ombrageRect,localMin - 8,posV - 15,posDroite,posV + 60);
              tailleOmbrageDuBouton := 5;
              radius := 10;
              SetRGBColor(couleurDuBois,30500,14000,2800);
              DessineOmbreRoundRect(ombrageRect,radius,radius,couleurDuBois,tailleOmbrageDuBouton,2000,0,1);
            end;

          SetPort(oldport);
        end;
   end;


(*
 ********************************************************************************
 *                                                                              *
 *   ChoisirUneOuvertureEquilibree : choix d'une ouverture aleatoire equilibree *
 *   pour une ronde ou une partie d'un match.                                   *
 *                                                                              *
 ********************************************************************************
 *)
procedure ChoisirUneOuvertureEquilibree(var ouverture : OuvertureRec; var ouverturesInterdites : StringSet);
var i : SInt32;
    lesCasesCEtlesCasesX : SquareSet;
begin
  with ouverture do
    begin
      nbCoupsImposes := 0;
      lesCasesCEtlesCasesX := [12,21,22,17,27,28,71,72,82,77,78,87];

      GenereOuvertureAleatoireEquilibree(longueurOuvertureAleatoire,-400,400,lesCasesCEtlesCasesX,ouvertureEquilibree,ouverturesInterdites);

      for i := 1 to longueurOuvertureAleatoire do
        premiersCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(ouvertureEquilibree, i, 'FaireUnMatch(1)');
      for i := longueurOuvertureAleatoire + 1 to 60 do
        premiersCoups[i] := 0;
    end;
end;


(*
 ********************************************************************************
 *                                                                              *
 *   ArreterLesAnciensMoteurs : on arrete les deux moteurs entre chaque partie. *
 *                                                                              *
 ********************************************************************************
 *)
procedure ArreterLesAnciensMoteurs;
begin
  (* arreter les anciens moteurs *)

  if doitArreterLeMoteurDeCeCanal[0] then
    begin
      SwitchToEngine(0);
      engine.state := ENGINE_RUNNING;
      SendStringToEngine('ENGINE-PROTOCOL stop');
      engine.state := ENGINE_RUNNING;
      KillCurrentEngine;
      doitArreterLeMoteurDeCeCanal[0]  := false;
      numeroMoteurDeCeCanal[0]         := 0;
      Wait(0.25);
    end;

  if doitArreterLeMoteurDeCeCanal[1] then
    begin
      SwitchToEngine(1);
      engine.state := ENGINE_RUNNING;
      SendStringToEngine('ENGINE-PROTOCOL stop');
      engine.state := ENGINE_RUNNING;
      KillCurrentEngine;
      doitArreterLeMoteurDeCeCanal[1]  := false;
      numeroMoteurDeCeCanal[1]         := 0;
      Wait(0.25);
    end;

end;


(*
 ********************************************************************************
 *                                                                              *
 *   LancerLesMoteursPourCettePartie : on relance les deux moteurs au debut de  *
 *   chaque partie, ce qui permet d'effacer leur table de hachage...            *
 *                                                                              *
 ********************************************************************************
 *)
procedure LancerLesMoteursPourCettePartie(joueur1, joueur2 : SInt32);
begin

  ArreterLesAnciensMoteurs;

  (* lancer le premier moteur *)

  SwitchToEngine(0);

  if (joueur1 > 0)
    then numeroEngineEnCours := joueur1
    else numeroEngineEnCours := 0;      // ceci forcera Cassio à jouer avec l'eval d'Edmond

  numeroMoteurDeCeCanal[0] := numeroEngineEnCours;

  if (numeroEngineEnCours > 0) then
    if CanStartEngine(GetEnginePath(numeroEngineEnCours,''), NumEnString(numProcessors))
      then doitArreterLeMoteurDeCeCanal[0] := true
      else numeroEngineEnCours := 0;

  (* lancer le deuxieme moteur *)

  SwitchToEngine(1);

  if (joueur2 > 0)
    then numeroEngineEnCours := joueur2
    else numeroEngineEnCours := 0;      // ceci forcera Cassio à jouer avec l'eval d'Edmond

  numeroMoteurDeCeCanal[1] := numeroEngineEnCours;

  if (numeroEngineEnCours > 0) then
    if CanStartEngine(GetEnginePath(numeroEngineEnCours,''), NumEnString(numProcessors))
      then doitArreterLeMoteurDeCeCanal[1] := true
      else numeroEngineEnCours := 0;

  Wait(1.0);
 // Wait(0.2);  seulement pour les tests !!

end;


(*
 ********************************************************************************
 *                                                                              *
 *   FaireUnMatch : organise un match, et renvoie le score du joueur 2 contre   *
 *   le joueur 1, en pourcentage.                                               *
 *                                                                              *
 ********************************************************************************
 *)
function FaireUnMatch(var match : MatchTournoiRec; var ouverturesDejaJouees : StringSet) : double_t;
var i, oldInterruption, compteurPartie : SInt32;
    quitterMatch : boolean;
    UnContreDeux,premierAppele : boolean;
    scoreSurDeuxParties : array[1..2] of SInt32;
    premiersCoupsOK : boolean;
    chainePartie : String255;
    tempo3D, tempoSon : boolean;
    foobool : boolean;
    partieRec : t_PartieRecNouveauFormat;
    nroReference : SInt32;
    diagonaleInversee : boolean;
    gainTheorique : String255;
    ouvertureDuMatch : OuvertureRec;
    s1 : String255;
    seulementLancerLesMoteurs : boolean;
    myDate : DateTimeRec;
    joueurNoirPourBaseWthor : SInt32;
    joueurBlancPourBaseWthor : SInt32;
begin

  ouvertureDuMatch := match.ouverture;

  with ouvertureDuMatch, match do
    begin

      avecSauvegardePartieDansListe := true;
      seulementLancerLesMoteurs := false;

      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
      FlushEvents(everyEvent,0);

      ResetStatistiquesDuMatch(match);

      if (joueur1 = kEngineSpecialBip) or (joueur2 = kEngineSpecialBip) then
        begin
          if (joueur1 = kEngineSpecialBip) and (joueur2 = kEngineSpecialBip) then FaireUnMatch := 50.0 else
          if (joueur1 = kEngineSpecialBip) then FaireUnMatch := 100.0 else
          if (joueur2 = kEngineSpecialBip) then FaireUnMatch := 0.0;
          exit(FaireUnMatch);
        end;

      FaireUnMatch := 0.5;

      oldInterruption := GetCurrentInterruption;
      EnleveCetteInterruption(oldInterruption);

      {
      VideStatistiquesDeBordsABLocal(essai_bord_AB_local);
      VideStatistiquesDeBordsABLocal(coupure_bord_AB_local);
      }

      SetPotentielsOptimums(PositionEtTraitInitiauxStandard);
      {AffichePotentiels;}

      compteurPartie := 0;
      quitterMatch := false;


      if (seulementLancerLesMoteurs)
        then
          begin

            if (typeDeMatch = ENTRE_ENGINES) then
              LancerLesMoteursPourCettePartie(joueur1,joueur2);

            RandomizeTimer;
            if odd(Random)
              then fanny[1] := fanny[1] + 2
              else fanny[2] := fanny[2] + 2;

            kWNESleep := 3;
            DoSystemTask(AQuiDeJouer);
            DoSystemTask(AQuiDeJouer);
            DoSystemTask(AQuiDeJouer);
            DoSystemTask(AQuiDeJouer);
            DoSystemTask(AQuiDeJouer);

          end
        else
      while not(quitterMatch or Quitter) and (compteurPartie < nbParties) do
        begin

          {EcritStatistiquesDeBordsABLocal;}

          compteurPartie := compteurPartie + 1;
          PrepareNouvellePartie(false);
          SetGameMode(ReflMilieu);
          EnleveCetteInterruption(interruptionSimple);


          {if (compteurPartie mod 20 = 0) then AffichePotentiels;}

          if (compteurPartie >= 3) and ouverturesAleatoires and odd(compteurPartie)
            then ChoisirUneOuvertureEquilibree(ouvertureDuMatch, ouverturesDejaJouees);


          if (typeDeMatch = ENTRE_ENGINES) then
            LancerLesMoteursPourCettePartie(joueur1,joueur2);

         {WritelnDansRapport('GetEngineState = ' + GetEngineState);}

          while not(gameOver or quitterMatch or Quitter) do
             begin
                UnContreDeux := (compteurPartie mod 4 = 1) or (compteurPartie mod 4 = 0);


                {UpdatePotentiels(JeuCourant,AQuiDeJouer);}

                EcritScoreMatch(match, UnContreDeux);
                if (UnContreDeux and (AQuiDeJouer = pionNoir)) or
                   (not(UnContreDeux) and (AQuiDeJouer = pionBlanc))
                 then premierAppele := true
                 else premierAppele := false;

                if premierAppele {n°1}
                  then
                    begin
                      level := niveau1;

                      if niveau1 >= 0
                        then SetProfImposee(true,'niveau 1 dans FaireUnMatch')
                        else SetProfImposee(false,'niveau 1 dans FaireUnMatch');

                      SetCadence(tempsParPartie);
                      cadencePersoAffichee := GetCadence;
                      AjusteEtatGeneralDeCassioApresChangementDeCadence;

                      {SetUtilisationNouvelleEval(false);}

                      {
                      if LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger) <> NoErr then SysBeep(0);
                      }

                      SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);
                      if (typeDeMatch = ENTRE_ENGINES)
                        then
                          begin
                            SetEffetSpecial(false);
                            SwitchToEngine(0);
                            if (joueur1 > 0)
                              then numeroEngineEnCours := joueur1
                              else numeroEngineEnCours := 0;      // ceci forcera Cassio à jouer avec l'eval d'Edmond
                          end
                        else
                          if(joueur1 = kIndexJoueurSansDeviation)
                            then SetEffetSpecial(false)
                            else SetEffetSpecial(true);
                      avecSelectivite                      := false;
                      utilisateurVeutDiscretiserEvaluation := true;

                      (*
                      if avecEvaluationTablesDeCoins <> avecEvaluationTablesDeCoins1
                        then DoChangeEvaluationTablesDeCoins;
                      CoeffInfluence := Coeffinfluence1;
                      Coefffrontiere := Coefffrontiere1;
                      CoeffEquivalence := CoeffEquivalence1;
                      Coeffcentre := Coeffcentre1;
                      Coeffgrandcentre := Coeffgrandcentre1;
                      Coeffbetonnage := Coeffdispersion1;
                      Coeffminimisation := Coeffminimisation1;
                      CoeffpriseCoin := CoeffpriseCoin1;
                      CoeffdefenseCoin := CoeffdefenseCoin1;
                      CoeffValeurCoin := CoeffValeurCoin1;
                      CoeffValeurCaseX := CoeffValeurCaseX1;
                      CoeffPenalite := CoeffPenalite1;
                      CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelle1;
                      *)
                      UtiliseGrapheApprentissage := FALSE;
                      avecBibl := not(ouverturesAleatoires);
                      Superviseur(nbreCoup);
                      Initialise_valeurs_bords(-0.5);
                      Initialise_turbulence_bords(true);
                    end
                  else           {n°2}
                    begin
                      level := niveau2;
                      if niveau2 >= 0
                        then SetProfImposee(true,'niveau 2 dans FaireUnMatch')
                        else SetProfImposee(false,'niveau 2 dans FaireUnMatch');

                      SetCadence(tempsParPartie);
                      cadencePersoAffichee := GetCadence;
                      AjusteEtatGeneralDeCassioApresChangementDeCadence;

                      {
                      if LitVecteurEvaluationIntegerSurLeDisque('Evaluation de Cassio',vecteurEvaluationInteger) <> NoErr then SysBeep(0);
                      }

                      SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);

                      if (typeDeMatch = ENTRE_ENGINES)
                        then
                          begin
                            SetEffetSpecial(false);
                            SwitchToEngine(1);
                            if (joueur2 > 0)
                              then numeroEngineEnCours := joueur2
                              else numeroEngineEnCours := 0;      // ceci forcera Cassio à jouer avec l'eval d'Edmond
                          end
                        else
                          if (joueur2 = kIndexJoueurSansDeviation) and (joueur1 <> joueur2)
                            then SetEffetSpecial(false)
                            else SetEffetSpecial(true);
                      avecSelectivite                      := false;
                      utilisateurVeutDiscretiserEvaluation := true;
                      (*
                      if avecEvaluationTablesDeCoins <> avecEvaluationTablesDeCoins2
                        then DoChangeEvaluationTablesDeCoins;
                      CoeffInfluence := Coeffinfluence2;
                      Coefffrontiere := Coefffrontiere2;
                      CoeffEquivalence := CoeffEquivalence2;
                      Coeffcentre := Coeffcentre2;
                      Coeffgrandcentre := Coeffgrandcentre2;
                      Coeffbetonnage := Coeffdispersion2;
                      Coeffminimisation := Coeffminimisation2;
                      CoeffpriseCoin := CoeffpriseCoin2;
                      CoeffdefenseCoin := CoeffdefenseCoin2;
                      CoeffValeurCoin := CoeffValeurCoin2;
                      CoeffValeurCaseX := CoeffValeurCaseX2;
                      CoeffPenalite := CoeffPenalite2;
                      CoeffMobiliteUnidirectionnelle := CoeffMobiliteUnidirectionnelle2;
                      *)
                      UtiliseGrapheApprentissage := FALSE;
                      avecBibl := not(ouverturesAleatoires);
                      Superviseur(nbreCoup);
                      Initialise_valeurs_bords(-0.5);
                      Initialise_turbulence_bords(true);
                    end;


                EcritScoreMatch(match, UnContreDeux);
                if nbreCoup = 40 then
                  for i := 1 to 40 do PremiersCoups[i] := GetNiemeCoupPartieCourante(i);
                couleurMacintosh := AQuiDeJouer;

                premiersCoupsOK := true;
                for i := 1 to nbreCoup do
                  premiersCoupsOK := premiersCoupsOK and (GetNiemeCoupPartieCourante(i) = PremiersCoups[i]);
                premiersCoupsOK := premiersCoupsOK and possibleMove[PremiersCoups[nbreCoup+1]];


                if not(Quitter or quitterMatch) then
                  if ouverturesAleatoires and (nbreCoup < longueurOuvertureAleatoire)
                    then
                      begin
                        tempoSon := avecSon;
                        avecSon := false;
                        DealWithEssai(PremiersCoups[nbreCoup+1],PositionEtTraitCourant,'FaireUnMatch(1)');
                        avecSon := tempoSon;
                      end
                    else
    		              if premiersCoupsOK and ((nbCoupsImposes > 0) and (nbreCoup < nbCoupsImposes))
    		                then
    		                  begin
    		                    tempoSon := avecSon;
                            avecSon := false;
    		                    DealWithEssai(PremiersCoups[nbreCoup+1],PositionEtTraitCourant,'FaireUnMatch(2)');
    		                    avecSon := tempoSon;
    		                  end
    		                else
    		                  begin
    		                    if premiersCoupsOK and
    		                       not(odd(compteurPartie)) and
    		                       ((nbreCoup < nbCoupsIdentiques) or PositionCouranteEstDansLaBibliotheque)
    		                      then
    		                        begin
    		                          tempoSon := avecSon;
                                  avecSon := false;
    		                          DealWithEssai(PremiersCoups[nbreCoup+1],PositionEtTraitCourant,'FaireUnMatch(3)');
    		                          avecSon := tempoSon;
    		                        end
    		                      else
    		                        begin
    		                          if (nbreCoup = 0) or true
    		                            then gEntrainementOuvertures.CassioVarieSesCoups := false
    		                            else gEntrainementOuvertures.CassioVarieSesCoups := PositionCouranteEstDansGrapheApprentissage;
    		                          {JeuMac(level,'FaireUnMatch(3)');}

    		                          {if premierAppele
    		                            then
    		                              begin
    		                                SetPotentielsOptimums(PositionEtTraitCourant);
    		                                DealWithEssai(ChoixDeVincenz(PositionEtTraitCourant,1,false).bestMove,PositionEtTraitCourant,'FaireUnMatch(4)');
    		                              end
    		                            else
    		                              begin
    		                                SetPotentielsOptimums(PositionEtTraitCourant);
    		                                DealWithEssai(ChoixDeVincenz(PositionEtTraitCourant,1,false).bestMove,PositionEtTraitCourant,'FaireUnMatch(5)');
    		                              end;
    		                              }


    		                          if premierAppele
    		                            then
    		                              begin

    		                                SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);
    		                                {NiveauJeuInstantane := NiveauClubs;}

    		                                JeuMac(level,'FaireUnMatch(4)');
    		                              end
    		                            else
    		                              begin
    		                                {if UneChanceSur(2)
    		                                  then NiveauJeuInstantane := NiveauClubs
    		                                  else NiveauJeuInstantane := NiveauExperts;}

    		                                SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);
    		                                {NiveauJeuInstantane := NiveauClubs;}

    		                                JeuMac(level,'FaireUnMatch(5)');
    		                              end;

    		                          SetOthellierEstSale(meilleurCoupHum,true);
    		                          EffaceAideDebutant(true,false,othellierToutEntier,'FaireUnMatch');


    		                          if HasGotEvent(everyEvent,theEvent,0,NIL)
    														    then TraiteEvenements
    														    else TraiteNullEvent(theEvent);

    		                        end;
    		                   end;
             end;

          quitterMatch := quitterMatch or Quitter;


          if avecSauvegardePartieDansListe and gameOver and not(quitterMatch) then
            begin
              if sousSelectionActive then DoChangeSousSelectionActive;

              joueurNoirPourBaseWthor  := kNroJoueurCassio;
              joueurBlancPourBaseWthor := kNroJoueurCassio;

              if (typeDeMatch = ENTRE_ENGINES) then
                begin
                  if UnContreDeux
                    then
                      begin
                        if (joueur1 > 0) and (NoCasePos('roxane',GetEngineName(joueur1)) > 0) then joueurNoirPourBaseWthor  := kNroJoueurCyrano else
                        if (joueur1 > 0) and (NoCasePos('edax',  GetEngineName(joueur1)) > 0) then joueurNoirPourBaseWthor  := kNroJoueurEdax;
                        if (joueur2 > 0) and (NoCasePos('roxane',GetEngineName(joueur2)) > 0) then joueurBlancPourBaseWthor := kNroJoueurCyrano else
                        if (joueur2 > 0) and (NoCasePos('edax',  GetEngineName(joueur2)) > 0) then joueurBlancPourBaseWthor := kNroJoueurEdax;
                      end
                    else
                      begin
                        if (joueur1 > 0) and (NoCasePos('roxane',GetEngineName(joueur1)) > 0) then joueurBlancPourBaseWthor := kNroJoueurCyrano else
                        if (joueur1 > 0) and (NoCasePos('edax',  GetEngineName(joueur1)) > 0) then joueurBlancPourBaseWthor := kNroJoueurEdax;
                        if (joueur2 > 0) and (NoCasePos('roxane',GetEngineName(joueur2)) > 0) then joueurNoirPourBaseWthor  := kNroJoueurCyrano else
                        if (joueur2 > 0) and (NoCasePos('edax',  GetEngineName(joueur2)) > 0) then joueurNoirPourBaseWthor  := kNroJoueurEdax;
                      end;
                end;

              GetTime(myDate);

              foobool := AjouterPartieCouranteDansListe(joueurNoirPourBaseWthor,joueurBlancPourBaseWthor,kNroTournoiDiversesParties,myDate.year,false,partieRec,nroReference);
            end;


          if avecAttenteEntreParties and not(quitterMatch) then
            begin
              AttendFrappeClavier;
              tempo3D := EnVieille3D;
              SetEnVieille3D(false);
              SetPositionsTextesWindowPlateau;
              DessineDiagramme(GetTailleCaseCourante,NIL,'FaireUnMatch');
              AfficheScore;
              dernierTick := TickCount;
              Heure(pionNoir);
              Heure(pionBlanc);
              AttendFrappeClavier;
              SetEnVieille3D(tempo3D);
              SetPositionsTextesWindowPlateau;
            end;

          {Les cases vides vont au vainqueur}
          if gameOver and not(quitterMatch) then
            begin
              if (nbredepions[pionNoir ] > nbredepions[pionBlanc]) then nbredepions[pionNoir ] := 64 - nbredepions[pionBlanc] else
              if (nbredepions[pionBlanc] > nbredepions[pionNoir ]) then nbredepions[pionBlanc] := 64 - nbredepions[pionNoir ] else
              if (nbredepions[pionBlanc] = nbredepions[pionNoir ]) then
                begin
                  nbredepions[pionBlanc] := 32;
                  nbredepions[pionNoir]  := 32;
                end;
            end;

          {calcul du score, à la mode "synchro-games" de GGS : on regarde un match de
           deux parties sur une position donnee (une fois Noir, une fois Blanc), celui
           qui en moyenne s'en est le mieux tiré, empoche le point}
          if (compteurPartie mod 2) = 0
            then
    	        begin
    			      if UnContreDeux
    			        then
    			          begin
    			            scoreSurDeuxParties[1] := nbredepions[pionNoir]  + nbreDePionsPartiePrecedente[pionBlanc];
    			            scoreSurDeuxParties[2] := nbredepions[pionBlanc] + nbreDePionsPartiePrecedente[pionNoir];
    			          end
    			        else
    			          begin
    			            scoreSurDeuxParties[1] := nbredepions[pionBlanc] + nbreDePionsPartiePrecedente[pionNoir];
    			            scoreSurDeuxParties[2] := nbredepions[pionNoir]  + nbreDePionsPartiePrecedente[pionBlanc];
    			          end;

    			      scoreCumule[1] := scoreCumule[1] + scoreSurDeuxParties[1];
    			      scoreCumule[2] := scoreCumule[2] + scoreSurDeuxParties[2];

    			      partieActuelle := PartieNormalisee(diagonaleInversee,true);

    			      if scoreSurDeuxParties[1] > scoreSurDeuxParties[2] then fanny[1] := fanny[1] + 2 else
    			      if scoreSurDeuxParties[1] < scoreSurDeuxParties[2] then fanny[2] := fanny[2] + 2 else
    			      if scoreSurDeuxParties[1] = scoreSurDeuxParties[2] then
    			        begin
    			          fanny[2] := fanny[2]+1;
    			          fanny[1] := fanny[1]+1;
    			        end;

    			      s1 := NumEnString(fanny[2] div 2);
    			      if odd(fanny[2]) then s1 := s1 + '.5';
    			      s1 := s1 + '/' + NumEnString(compteurPartie div 2);
    			      if (scoreSurDeuxParties[2] >= scoreSurDeuxParties[1])
    			        then s1 := s1 + '  (+' + NumEnString((scoreSurDeuxParties[2] - scoreSurDeuxParties[1]) div 2) + ')'
    			        else s1 := s1 + '  ('  + NumEnString((scoreSurDeuxParties[2] - scoreSurDeuxParties[1]) div 2) + ')';
    			      (* WritelnDansRapport('[2] : '+s1); *)

    			      nbreDePionsPartiePrecedente[pionNoir]  := 0;
    			      nbreDePionsPartiePrecedente[pionBlanc] := 0;
    	        end
    	      else
    	        begin
    			      nbreDePionsPartiePrecedente[pionNoir]  := nbredepions[pionNoir];
    			      nbreDePionsPartiePrecedente[pionBlanc] := nbredepions[pionBlanc];
    			      partiePrecedente := PartieNormalisee(diagonaleInversee,true);
    			    end;


          {on met les parties du match dans le graphe d'apprentissage}
          if LaDemoApprend and not(Quitter) and not(quitterMatch) and gameOver then
            if not(jeuInstantane) then
            begin
              if nbredepions[pionNoir] > nbredepions[pionBlanc] then gainTheorique := CaracterePourNoir;
              if nbredepions[pionNoir] = nbredepions[pionBlanc] then gainTheorique := CaracterePourEgalite;
              if nbredepions[pionNoir] < nbredepions[pionBlanc] then gainTheorique := CaracterePourBlanc;
              chainePartie := PartieNormalisee(diagonaleInversee,true);
              ApprendPartieIsolee(chainePartie,gainTheorique,finDePartie);
            end;

          if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
        end;


      if (fanny[2]+fanny[1]) <> 0
        then FaireUnMatch := 100.0*fanny[2]/(1.0*(fanny[2]+fanny[1]))
        else FaireUnMatch := 0;

  end;


  if (match.typeDeMatch = ENTRE_ENGINES)
    then ArreterLesAnciensMoteurs;


end;


(*
 ********************************************************************************
 *                                                                              *
 *   CreerTournoiToutesRondes : creation d'un enregistrement pour le tournoi.    *
 *                                                                              *
 ********************************************************************************
 *)
procedure CreerTournoiToutesRondes(var tournoi : ToutesRondesRec);
var k : SInt32;
begin
  with tournoi do
    begin
      for k := 0 to kNombreMaxJoueursDansLeTournoi do
        begin
          indexParticipant[k]     := 0;
          nroEngineParticipant[k] := 0;
          scoreParticipant[k]     := 0.0;
          tableauTouteRonde[k]    := 0;
        end;
      with ouverture do
        begin
          ouverturesAleatoires       := false;
          nbCoupsImposes             := 0;
          nbCoupsIdentiques          := 0;
          longueurOuvertureAleatoire := 0;
          for k := 0 to 65 do
            premiersCoups[k] := 0;
        end;
      ouverturesDejaJouees           := MakeEmptyStringSet;
      typeTournoi                    := 0;
      numeroRonde                    := 0;
      nbParticipants                 := 0;
      nbToursDuTournoi               := 0;
      nbPartiesParMatch              := 0;
      nomTournoi                     := '';
      doitSauvegarderPartieDansListe := false;
      settings.niveau1               := 18;
      settings.niveau2               := 18;
      settings.tempsParPartie        := 0;
    end;
end;



(*
 ********************************************************************************
 *                                                                              *
 *   BeginInfosTournoiDansRapport : appeler cette fonction avant tout affichage *
 *   concernant un tournoi dans le rapport. Ceci permet de rediriger eventuel-  *
 *   lement l'affichage vers un fichier, etc.                                   *
 *                                                                              *
 ********************************************************************************
 *)
procedure BeginInfosTournoiDansRapport;
begin
  auxLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(true);
end;


(*
 ********************************************************************************
 *                                                                              *
 *   EndInfosTournoisDansRapport : appeler cette fonction a la fin de toute     *
 *   fonction affichant dans le rapport des infos concernat un tournoi. C'est   *
 *   le pendant de la fonction BeginInfosTournoiDansRapport.                    *
 *                                                                              *
 ********************************************************************************
 *)
procedure EndInfosTournoisDansRapport;
begin
  SetEcritToutDansRapportLog(auxLog);
end;


(*
 ********************************************************************************
 *                                                                              *
 *   EcrireDeuxPartiesDuMatchDansRapport : pour l'affichage des parties synchro *
 *   qui ne se sont pas terminées par la nulle.                                 *
 *                                                                              *
 ********************************************************************************
 *)
 procedure EcrireDeuxPartiesDuMatchDansRapport(match : MatchTournoiRec);
 var nbNoirs,nbBlancs : SInt32;
     coupDivergent, i : SInt32;
     numeroDuCoupDivergent : SInt32;
     coupDivergentEstBon : boolean;
 begin
   BeginInfosTournoiDansRapport;

   with match do
      begin

        if (joueur1 = kEngineSpecialBip) or (joueur2 = kEngineSpecialBip) then
          exit(EcrireDeuxPartiesDuMatchDansRapport);

        coupDivergent := -1;
        for i := 1 to 120 do
          if (coupDivergent = -1) and (partieActuelle[i] <> partiePrecedente[i])
            then coupDivergent := i;
        if (coupDivergent > 0) and not(odd(coupDivergent)) then dec(coupDivergent);

        numeroDuCoupDivergent := (coupDivergent + 1) div 2;

        TextNormalDansRapport;

        if EstUnePartieOthelloTerminee(partiePrecedente,false,nbNoirs,nbBlancs) then
          begin
            if (fanny[1] > fanny[2]) then ChangeFontFaceDansRapport(bold);
            WriteDansRapport(NomDeLEngineDansLeMatch(match,joueur1) + ' ');
            TextNormalDansRapport;

            WriteNumDansRapport(NumEnString(nbNoirs) + ' - ',nbBlancs);
            WriteDansRapport(' ');

            if (fanny[2] > fanny[1]) then ChangeFontFaceDansRapport(bold);
            WriteDansRapport(NomDeLEngineDansLeMatch(match,joueur2) + ' ');
            TextNormalDansRapport;

            WritelnDansRapport(' :');

            if (partiePrecedente = partieActuelle)
              then WritelnDansRapport(partiePrecedente)
              else
                begin
                  WriteDansRapport(LeftOfString(partiePrecedente,coupDivergent - 1) + ' ');

                  if (fanny[1] <> fanny[2])
                    then
                      begin
                        coupDivergentEstBon := ((fanny[1] > fanny[2]) and odd(numeroDuCoupDivergent)) or
                                               ((fanny[2] > fanny[1]) and not(odd(numeroDuCoupDivergent)));
                        if coupDivergentEstBon
                          then ChangeFontColorDansRapport(VertSapinCmd)
                          else ChangeFontColorDansRapport(RougeCmd);
                        ChangeFontFaceDansRapport(bold);
                        WriteDansRapport(partiePrecedente[coupDivergent] + partiePrecedente[coupDivergent + 1]);
                        if coupDivergentEstBon
                          then WriteDansRapport('!')
                          else WriteDansRapport('?');
                        WriteDansRapport(' ');
                      end
                    else
                      begin
                        ChangeFontColorDansRapport(VertSapinCmd);
                        WriteDansRapport(partiePrecedente[coupDivergent] + partiePrecedente[coupDivergent + 1]);
                      end;


                  ChangeFontColorDansRapport(VertSapinCmd);
                  ChangeFontFaceDansRapport(normal);
                  WritelnDansRapport(RightOfString(partiePrecedente,LENGTH_OF_STRING(partiePrecedente) - coupDivergent - 1));

                  TextNormalDansRapport;
                end;
          end;

        if EstUnePartieOthelloTerminee(partieActuelle,false,nbNoirs,nbBlancs) then
          begin
            if (fanny[2] > fanny[1]) then ChangeFontFaceDansRapport(bold);
            WriteDansRapport(NomDeLEngineDansLeMatch(match,joueur2) + ' ');
            TextNormalDansRapport;

            WriteNumDansRapport(NumEnString(nbNoirs) + ' - ',nbBlancs);
            WriteDansRapport(' ');

            if (fanny[1] > fanny[2]) then ChangeFontFaceDansRapport(bold);
            WriteDansRapport(NomDeLEngineDansLeMatch(match,joueur1) + ' ');
            TextNormalDansRapport;

            WritelnDansRapport(' :');

            if (partiePrecedente = partieActuelle)
              then WritelnDansRapport(partieActuelle)
              else
                begin
                  WriteDansRapport(LeftOfString(partieActuelle,coupDivergent - 1) + ' ');

                  if (fanny[1] <> fanny[2])
                    then
                      begin
                        coupDivergentEstBon := ((fanny[2] > fanny[1]) and odd(numeroDuCoupDivergent)) or
                                               ((fanny[1] > fanny[2]) and not(odd(numeroDuCoupDivergent)));
                        if coupDivergentEstBon
                          then ChangeFontColorDansRapport(VertSapinCmd)
                          else ChangeFontColorDansRapport(RougeCmd);

                        ChangeFontFaceDansRapport(bold);
                        WriteDansRapport(partieActuelle[coupDivergent] + partieActuelle[coupDivergent + 1]);
                        if coupDivergentEstBon
                          then WriteDansRapport('!')
                          else WriteDansRapport('?');
                        WriteDansRapport(' ');
                      end
                    else
                      begin
                        ChangeFontColorDansRapport(VertSapinCmd);
                        WriteDansRapport(partieActuelle[coupDivergent] + partieActuelle[coupDivergent + 1]);
                      end;

                  ChangeFontColorDansRapport(VertSapinCmd);
                  ChangeFontFaceDansRapport(normal);
                  WritelnDansRapport(RightOfString(partieActuelle,LENGTH_OF_STRING(partieActuelle) - coupDivergent - 1));

                  TextNormalDansRapport;
                end;
          end;
        WritelnDansRapport('');

        TextNormalDansRapport;
      end;

   EndInfosTournoisDansRapport;
 end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireAnnonceTournoiDansRapport : on affiche quelques infos sur le tournoi.*
 *                                                                              *
 ********************************************************************************
 *)
procedure EcrireAnnonceTournoiDansRapport(var tournoi : ToutesRondesRec; var match : MatchTournoiRec);
var t : SInt32;
    nom : String255;
begin
  BeginInfosTournoiDansRapport;

  with tournoi do
    begin

      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport('## DEBUT DU TOURNOI');
      TextNormalDansRapport;

      WritelnDansRapport('');
      WritelnDansRapport('Utilisez cmd-Q pour arrêter le tournoi…');
      if (nomTournoi <> '') then WritelnDansRapport('Nom du tournoi = "' + nomTournoi+'"');
      if (settings.niveau1 > 0) and (settings.niveau2 > 0)
        then WritelnNumDansRapport('Tournoi à profondeur fixe = ',settings.niveau1)
        else WritelnDansRapport('Temps par joueur = ' + NumEnString(settings.tempsParPartie div 60) + ' min.');


      (* Afficher les participants *)

      if odd(nbParticipants) then
        begin
          WritelnDansRapport('Comme il y a '+NumEnString(nbParticipants)+' inscrits au tournoi, j''ajoute un Bip qui perdra toutes ses parties.');
          inc(nbParticipants);
          for t := (nbParticipants - 1) downto ((nbParticipants div 2) + 1) do
            nroEngineParticipant[t] := nroEngineParticipant[t - 1];
          nroEngineParticipant[(nbParticipants div 2)] := kEngineSpecialBip;
        end;

      ChangeFontFaceDansRapport(italic);
      WritelnDansRapport('');
      WriteDansRapport('-- Inscrits au tournoi --');
      TextNormalDansRapport;
      WritelnDansRapport(' ');
      ChangeFontFaceDansRapport(italic);
      for t := 0 to nbParticipants - 1 do
        begin
          scoreParticipant[t] := 0.0;
          match.typeDeMatch := ENTRE_ENGINES;
          nom := NomDeLEngineDansLeMatch(match, nroEngineParticipant[t]);
          WritelnDansRapport('  ' + nom);
        end;
      TextNormalDansRapport;
    end;

  EndInfosTournoisDansRapport;
end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireConclusionDuTournoiDansRapport : a la fin du tournoi.                *
 *                                                                              *
 ********************************************************************************
 *)
procedure EcrireConclusionDuTournoiDansRapport(var tournoi : ToutesRondesRec);
begin
  BeginInfosTournoiDansRapport;

  if (tournoi.nbParticipants > 2) then WritelnDansRapport('');
  WritelnDansRapport('');
  WritelnDansRapport('## Fin du tournoi, merci à tous !');
  WritelnDansRapport('');

  EndInfosTournoisDansRapport;
end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireAnnonceDeLaRondeDansRapport : on affiche quelques infos sur la ronde.*
 *                                                                              *
 ********************************************************************************
 *)
procedure EcrireAnnonceDeLaRondeDansRapport(var tournoi : ToutesRondesRec; tours : SInt32);
begin
  BeginInfosTournoiDansRapport;

  with tournoi do
    begin

      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport('');
      WriteNumDansRapport('# RONDE ', (nbParticipants - 1)*(tours - 1) + numeroRonde);
      if (numeroRonde = 1) and (nbParticipants > 2)
        then WriteDansRapport('  (toutes-rondes '+NumEnString(tours)+')');
      WritelnDansRapport('');
      WritelnDansRapport('');
      TextNormalDansRapport;

    end;

  EndInfosTournoisDansRapport;
end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireClassementTournoiDansRapport : on ecrit le classement du tournoi.    *
 *                                                                              *
 ********************************************************************************
 *)
 procedure EcrireClassementTournoiDansRapport(var tournoi : ToutesRondesRec; nroDuCeTour : SInt32);
 var t,k,longueurMax,nbChiffres : SInt32;
     nom : String255;
     match : MatchTournoiRec;
     nombreDeRondesJouees : SInt32;
     p : double_t;
 begin
   BeginInfosTournoiDansRapport;

   with tournoi do
      begin
        match.typeDeMatch := ENTRE_ENGINES;

        longueurMax := -1000;
        for t := 0 to nbParticipants - 1 do
          begin
            nom := NomDeLEngineDansLeMatch(match,nroEngineParticipant[t]);
            if (LENGTH_OF_STRING(nom) > longueurMax) then longueurMax := LENGTH_OF_STRING(nom);
          end;

        TextNormalDansRapport;
        ChangeFontFaceDansRapport(italic);

        nombreDeRondesJouees := (nbParticipants - 1)*(nroDuCeTour - 1) + numeroRonde;

        WriteNumDansRapport(' Classement après la ronde ',nombreDeRondesJouees);
        WritelnDansRapport(' :');
        for t := 0 to nbParticipants - 1 do
          begin
            nom := NomDeLEngineDansLeMatch(match,nroEngineParticipant[t]);
            WriteDansRapport('   '+nom);
            for k := 1 to (longueurMax - LENGTH_OF_STRING(nom)) do
              WriteDansRapport('  ');
            if (nom = 'Cassio') then WriteDansRapport('   ');

            if (scoreParticipant[t] > 1000.0) then nbChiffres := 5 else
            if (scoreParticipant[t] > 100.0)  then nbChiffres := 4 else
            if (scoreParticipant[t] > 10.0)   then nbChiffres := 3
              else nbChiffres := 2;

            WriteStringAndReelDansRapport('     =>    ',scoreParticipant[t],nbChiffres);

            if (scoreParticipant[t] <> 0) and (nombreDeRondesJouees > 0)
              then WriteStringAndReelDansRapport(' pts      (',100*scoreParticipant[t]/nombreDeRondesJouees,4)
              else WriteDansRapport(' pts      (0.00');
            WriteDansRapport('%)');

            if (nbParticipants = 2) then
              begin
                p := scoreParticipant[t]/nombreDeRondesJouees;
                WriteDansRapport('     [ ∆Elo = ');
                if (p > 0.5) then WriteDansRapport('+');
                WriteStringAndReelDansRapport('',CalculateEloIncrease(p),3);
                WriteStringAndReelDansRapport(' ± ',CalculateEloErrorBar(nombreDeRondesJouees),3);
                WriteDansRapport(' ]');
              end;

            WritelnDansRapport('');
          end;
        TextNormalDansRapport;
      end;

   EndInfosTournoisDansRapport;
 end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireAnnonceDuMatchDansRapport : on ecrit le nom des joueurs.             *
 *                                                                              *
 ********************************************************************************
 *)
procedure EcrireAnnonceDuMatchDansRapport(var tournoi : ToutesRondesRec; var match : MatchTournoiRec);
var nom1,nom2 : String255;
begin
  BeginInfosTournoiDansRapport;

  with match do
    begin

      nom1 := NomDeLEngineDansLeMatch(match, joueur1);
      nom2 := NomDeLEngineDansLeMatch(match, joueur2);

      if (tournoi.nbParticipants > 2) and (joueur1 <> kEngineSpecialBip) and (joueur2 <> kEngineSpecialBip) then
        WriteDansRapport('match '+nom1+'-'+nom2+'… ');

    end;

  EndInfosTournoisDansRapport;
end;


 (*
 ********************************************************************************
 *                                                                              *
 *   EcrireConclusionDuMatchDansRapport : on ecrit le score du match.           *
 *                                                                              *
 ********************************************************************************
 *)
procedure EcrireConclusionDuMatchDansRapport(var tournoi : ToutesRondesRec; scoreDuJoueur2 : double_t);
begin
  BeginInfosTournoiDansRapport;

  Discard(tournoi);
  WriteStringAndReelDansRapport(' ',(1.0 - scoreDuJoueur2),2);
  WritelnStringAndReelDansRapport('-',scoreDuJoueur2,2);

  EndInfosTournoisDansRapport;
end;



(*
 ********************************************************************************
 *                                                                              *
 *   On doit sauvegarder avec cette fonction le plus possible de l'etat global  *
 *   de Cassio avant de lancer le tournoi, pour pouvoir retablir cet etat plus  *
 *   tard.
 *                                                                              *
 ********************************************************************************
 *)
procedure SauvegarderEtatGlobalDeCassioAvantLeTournoi;
begin

  with gEtatGlobalDeCassioAvantTournoi do
    begin
      sauvegardeInfosTechniques               := InfosTechniquesDansRapport;
      sauvegardeHumCtreHum                    := HumCtreHum;
      sauvegardeInterruption                  := GetCurrentInterruption;
      sauvegardeEngineEnCours                 := numeroEngineEnCours;
      sauvegardeAvecBibl                      := avecBibl;
      sauvegardeCassioVarieSesCoups           := gEntrainementOuvertures.CassioVarieSesCoups;
      sauvegardeLevel                         := level;
      sauvegardeProfImposee                   := profimposee;
      sauvegardeNbCoupsEnTete                 := nbCoupsEnTete;
      sauvegardeAvecEvaluationTotale          := avecEvaluationTotale;
      sauvegardeFinDePartieVitesseMac         := finDePartieVitesseMac;
      sauvegardeFinDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMac;
      sauvegardeUtiliserGrapheApprentissage   := UtiliseGrapheApprentissage;
      sauvegardeEcritToutDansRapport          := GetEcritToutDansRapportLog;
      sauvegardeDiscretisationEval            := utilisateurVeutDiscretiserEvaluation;
      sauvegardeAvecSelectivite               := avecSelectivite;
      sauvegardeJeuInstantane                 := jeuInstantane;
      sauvegardeCadence                       := GetCadence;
      sauvegardeCadencePersoAffichee          := cadencePersoAffichee;
      sauvegardeNeJamaisTomberAuTemps         := neJamaisTomber;
      sauvegardeAfficheSuggestionDeCassio     := afficheSuggestionDeCassio;
      sauvegardeAfficheMeilleureSuite         := afficheMeilleureSuite;
      sauvegardeAfficheNumeroCoup             := afficheNumeroCoup;
    end;



  SetEcritToutDansRapportLog(false);
  InfosTechniquesDansRapport := false;
  if HumCtreHum then DoChangeHumCtreHum;
  EnleveCetteInterruption(GetCurrentInterruption);
  jeuInstantane := false;
  neJamaisTomber := false;
  afficheSuggestionDeCassio := true;
  afficheMeilleureSuite := true;
  afficheNumeroCoup := true;

  enTournoi := true;

  EndHiliteMenu(TickCount,8,false);
end;



(*
 ********************************************************************************
 *                                                                              *
 *   Il faut faire un grand menage precautionnaux quand on finit un tournoi.    *
 *                                                                              *
 ********************************************************************************
 *)
procedure RemettreEtatGlobalDeCassioApresLeTournoi;
begin

  with gEtatGlobalDeCassioAvantTournoi do
    begin

      avecBibl                                    := sauvegardeAvecBibl;
      gEntrainementOuvertures.CassioVarieSesCoups := sauvegardeCassioVarieSesCoups;
      level                                       := sauvegardeLevel;
      nbCoupsEnTete                               := sauvegardeNbCoupsEnTete;
      finDePartieVitesseMac                       := sauvegardeFinDePartieVitesseMac;
      finDePartieOptimaleVitesseMac               := sauvegardeFinDePartieOptimaleVitesseMac;
      UtiliseGrapheApprentissage                  := sauvegardeUtiliserGrapheApprentissage;
      utilisateurVeutDiscretiserEvaluation        := sauvegardeDiscretisationEval;
      avecSelectivite                             := sauvegardeAvecSelectivite;
      neJamaisTomber                              := sauvegardeNeJamaisTomberAuTemps;
      phaseDeLaPartie                             := CalculePhasePartie(nbreCoup);
      afficheMeilleureSuite                       := sauvegardeAfficheMeilleureSuite;
      afficheNumeroCoup                           := sauvegardeAfficheNumeroCoup;

      if (sauvegardeAfficheSuggestionDeCassio <> afficheSuggestionDeCassio)
        then DoChangeAfficheSuggestionDeCassio;

      if (sauvegardeCadence              <> GetCadence)           or
         (sauvegardeCadencePersoAffichee <> cadencePersoAffichee) or
         (sauvegardeJeuInstantane        <> jeuInstantane) then
        begin
          SetCadence(sauvegardeCadence);
          cadencePersoAffichee := sauvegardeCadencePersoAffichee;
          jeuInstantane        := sauvegardeJeuInstantane;
          AjusteCadenceMin(GetCadence);
        end;


      SetProfImposee(sauvegardeProfImposee,'RemettreEtatGlobalDeCassioApresLeTournoi');
      SetEcritToutDansRapportLog(sauvegardeEcritToutDansRapport);

      if (sauvegardeHumCtreHum <> HumCtreHum)
        then DoChangeHumCtreHum;

      if (sauvegardeAvecEvaluationTotale <> avecEvaluationTotale)
        then DoChangeEvaluationTotale(true);

      (* essayer de relancer propremement l'ancien moteur que nous avions à l'arrivée *)
      ArreterLesAnciensMoteurs;
      SwitchToEngine(0);
      numeroEngineEnCours := sauvegardeEngineEnCours;
      if (numeroEngineEnCours > 0) then
        if CanStartEngine(GetEnginePath(numeroEngineEnCours,''), NumEnString(numProcessors))
          then
            begin
              doitArreterLeMoteurDeCeCanal[0] := true;
              numeroMoteurDeCeCanal[0]        := numeroEngineEnCours;
              Wait(1.0);
            end
          else
            numeroEngineEnCours := 0;

      // ne pas mettre ceci plus haut, sinon Cassio va ecrire "starting engine blah blah"...
      InfosTechniquesDansRapport := sauvegardeInfosTechniques;

      AjusteEtatGeneralDeCassioApresChangementDeCadence;
      RemettreLeCurseurNormalDeCassio;
      EcritGestionTemps;

      EffaceTouteLaFenetreSaufLOthellier;
      InvalidateAllCasesDessinEnTraceDeRayon;
      DrawContents(wPlateauPtr);

      enTournoi := false;

      LanceInterruption(sauvegardeInterruption,'RemettreEtatGlobalDeCassioApresLeTournoi');

    end;

end;



(*
 ********************************************************************************
 *                                                                              *
 *   FaireUnTournoiToutesRondesEntreEngines : tournoi toutes rondes entre des   *
 *   moteurs.                                                                   *
 *                                                                              *
 ********************************************************************************
 *)
procedure FaireUnTournoiToutesRondesEntreEngines(var tournoi : ToutesRondesRec);
var t,r,n1,n2 : SInt32;
    scoreDuJoueur2 : double_t;
    tours : SInt32;
    match : MatchTournoiRec;
    ouvertureDeLaRonde : OuvertureRec;
begin

  { Pas de tournoi récursif ! }
  // if CassioEstEnModeTournoi then exit(FaireUnTournoiToutesRondesEntreEngines);

  SauvegarderEtatGlobalDeCassioAvantLeTournoi;
  SetCassioEstEnModeTournoi(true);

  if not(Quitter) then
    with tournoi do
      begin

        nbPartiesParMatch := 2;

        EcrireAnnonceTournoiDansRapport(tournoi,match);

        DoLectureJoueursEtTournoi(false);

        for tours := 1 to nbToursDuTournoi do
          for r := 1 to nbParticipants - 1 do
             if not(Quitter) then
                begin
                  numeroRonde := r;

                  EcrireAnnonceDeLaRondeDansRapport(tournoi, tours);

                  FaireTournerParticipantsTournoiToutesRondes(numeroRonde,tournoi);

                  ouvertureDeLaRonde := tournoi.ouverture;
                  ChoisirUneOuvertureEquilibree(ouvertureDeLaRonde,ouverturesDejaJouees);


                  for t := 1 to (nbParticipants div 2) do
                    if not(Quitter) then
                      begin
                        n1 := tableauTouteRonde[t - 1];
                        n2 := tableauTouteRonde[nbParticipants - t];

                        match.joueur1 := nroEngineParticipant[n1];
                        match.joueur2 := nroEngineParticipant[n2];

                        if (nbParticipants > 2) and
                           (match.joueur1 <> kEngineSpecialBip) and
                           (match.joueur2 <> kEngineSpecialBip) then
                          EcrireAnnonceDuMatchDansRapport(tournoi, match);

                        (* Faire le match *)
                        match.typeDeMatch                   := ENTRE_ENGINES;
                        match.ouverture                     := ouvertureDeLaRonde;
                        match.nbParties                     := nbPartiesParMatch;
                        match.niveau1                       := tournoi.settings.niveau1;
                        match.niveau2                       := tournoi.settings.niveau2;
                        match.tempsParPartie                := tournoi.settings.tempsParPartie;
                        match.avecAttenteEntreParties       := false;
                        match.avecSauvegardePartieDansListe := true;

                        scoreDuJoueur2 := FaireUnMatch(match, ouverturesDejaJouees)/100.0;

                        if (nbParticipants > 2) and
                           not(Quitter) and
                           (match.joueur1 <> kEngineSpecialBip) and
                           (match.joueur2 <> kEngineSpecialBip) then
                          EcrireConclusionDuMatchDansRapport(tournoi,scoreDuJoueur2);

                        (* mettre a jour les scores des joueurs dans le tournoi *)
                        scoreParticipant[n1] := scoreParticipant[n1] + (1.0 - scoreDuJoueur2);
                        scoreParticipant[n2] := scoreParticipant[n2] + scoreDuJoueur2;

                        if not(Quitter) and ((scoreDuJoueur2 <> 0.5) or (match.partieActuelle <> match.partiePrecedente))
                          then EcrireDeuxPartiesDuMatchDansRapport(match);

                      end;

                  if not(Quitter) then
                    begin
                      if (nbParticipants > 2) and (scoreDuJoueur2 = 0.5)
                        then WritelnDansRapport('');
                      EcrireClassementTournoiDansRapport(tournoi, tours);
                    end;
                end;

        EcrireConclusionDuTournoiDansRapport(tournoi);

        DisposeStringSet(ouverturesDejaJouees);

      end;

  Quitter := false;

  SetCassioEstEnModeTournoi(false);
  RemettreEtatGlobalDeCassioApresLeTournoi;

end;


(*
 ********************************************************************************
 *                                                                              *
 *   Lecture, dans un fichier texte, des parametres du tournoi a organiser.     *
 *                                                                              *
 ********************************************************************************
 *)
function PeutLireParametresTournoisEntreEnginesDansFichier(path : String255; var tournoi : ToutesRondesRec) : boolean;
var err : OSErr;
    fic : FichierTEXT;
    s,s1,s2,s3,s4,s5,s6,reste : String255;
    num : SInt32;
    nomLongDuFichier : String255;
label sortie;
begin

  PeutLireParametresTournoisEntreEnginesDansFichier := false;

  CreerTournoiToutesRondes(tournoi);

  err := FichierTexteExiste(path,0,fic);
  if (err <> NoErr) then goto sortie;


  err := FSSpecToLongName(fic.theFSSpec,nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);


  err := OuvreFichierTexte(fic);
  if (err <> NoErr) then goto sortie;

  repeat
    err := ReadlnDansFichierTexte(fic,s);
    s := EnleveEspacesDeGauche(s);

    if (err = NoErr) and (s <> '') and (s[1] <> '#') and (s[1] <> '%') then
      with tournoi do
        begin
          Parser6(s,s1,s2,s3,s4,s5,s6,reste);

          if NoCaseEquals('NOM-TOURNOI',s1) then
            Parser2(s,s1,s2,nomTournoi);

          if (NoCasePos('ENGINES[',s1) > 0) then
            begin
              num := GetNumeroOfEngine(s3);
              if (num > 0)
                then
                  begin
                    inc(nbParticipants);
                    nroEngineParticipant[nbParticipants - 1] := num;
                  end
                else
                  begin
                    if not(NoCaseEquals(s3,'Cassio')) and not(NoCaseEquals(s3,'Edmond')) then
                      begin
                        WritelnDansRapport('');
                        ChangeFontColorDansRapport(RougeCmd);
                        ChangeFontFaceDansRapport(bold);
                        WritelnDansRapport('WARNING : Moteur "' + s3 + '" non trouvé, j''utilise Cassio à la place.');
                      end;
                    inc(nbParticipants);
                    nroEngineParticipant[nbParticipants - 1] := kEngineSpecialCassioEdmond;
                  end;
            end;

          if NoCaseEquals('NOMBRE-DE-TOURS-COMPLETS',s1) then
            nbToursDuTournoi := ChaineEnLongint(s3);

          if NoCaseEquals('TEMPS-PAR-JOUEUR',s1) then
            settings.tempsParPartie := 60 * ChaineEnLongint(s3);  // le temps est donné en minutes dans le fichier

          if NoCaseEquals('OUVERTURE',s1) then
            begin
              if NoCaseEquals('aleatoire',s3) then
                begin
                  ouverture.ouverturesAleatoires := true;
                  ouverture.longueurOuvertureAleatoire := ChaineEnLongint(s4);
                end;
            end;

          if NoCaseEquals('PROFONDEUR-FIXE',s1) then
            begin
              num := ChaineEnLongint(s3);
              if not(IsDigit(s3[1]))  or NoCaseEquals('non',s3) or (num <= 0) or (num > 64)
                then
                  begin
                    settings.niveau1 := -1;
                    settings.niveau2 := -1;
                  end
                else
                  begin
                    if (num >= 12)
                      then
                        begin
                          settings.niveau1 := num;
                          settings.niveau2 := num;
                          settings.tempsParPartie := 3600 * 100;
                        end
                      else
                        begin
                          WritelnDansRapport('');
                          ChangeFontColorDansRapport(RougeCmd);
                          ChangeFontFaceDansRapport(bold);
                          WritelnDansRapport('WARNING : La profondeur minimum est de 12');
                          settings.niveau1 := 12;
                          settings.niveau2 := 12;
                          settings.tempsParPartie := 3600 * 100;
                        end;
                  end;
            end;


        end;
  until (err <> NoErr) or EOFFichierTexte(fic,err);

  err := FermeFichierTexte(fic);
  if (err <> NoErr) then goto sortie;

  sortie :

  TextNormalDansRapport;

  PeutLireParametresTournoisEntreEnginesDansFichier := (err = NoErr)

end;


(*
 ********************************************************************************
 *                                                                              *
 *   OuvrirFichierTournoiEntreEngines : lit les parametres du tournoi dans le   *
 *   fichier, puis organise le tournoi.                                         *
 *                                                                              *
 ********************************************************************************
 *)
function OuvrirFichierTournoiEntreEngines(nomCompletFichier : String255) : OSErr;
var tournoi : ToutesRondesRec;
begin
  OuvrirFichierTournoiEntreEngines := -1;

  { Pas de tournois recursifs ! }
  if CassioEstEnModeTournoi then
    exit(OuvrirFichierTournoiEntreEngines);

  if PeutLireParametresTournoisEntreEnginesDansFichier(nomCompletFichier, tournoi) then
    begin
      FaireUnTournoiToutesRondesEntreEngines(tournoi);
      OuvrirFichierTournoiEntreEngines := NoErr;
    end
end;



(********************************************)
(********************************************)
(********************************************)


(* renvoie un entier entre 0 et 624 *)
function IndexTriTableauDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32) : SInt32;
var aux : SInt32;
begin
  aux := 0;

  case dev_frontiere of
     -2 : aux := aux + 0;
     -1 : aux := aux + 125;
     0  : aux := aux + 250;
     1  : aux := aux + 375;
     2  : aux := aux + 500;
  end;

  case dev_minimisation of
     -2 : aux := aux + 0;
     -1 : aux := aux + 25;
     0  : aux := aux + 50;
     1  : aux := aux + 75;
     2  : aux := aux + 100;
  end;

  case dev_mobilite of
     -2 : aux := aux + 0;
     -1 : aux := aux + 5;
     0  : aux := aux + 10;
     1  : aux := aux + 15;
     2  : aux := aux + 20;
  end;

  case dev_penalitetrait of
     -2 : aux := aux + 0;
     -1 : aux := aux + 1;
     0  : aux := aux + 2;
     1  : aux := aux + 3;
     2  : aux := aux + 4;
  end;

  IndexTriTableauDeviation := aux;
end;




procedure VideTableauDeviations;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  if (deviations <> NIL) then
    begin
      for deviation_frontiere := -2 to 2 do
        for deviation_minimisation := -2 to 2 do
          for deviation_mobilite := -2 to 2 do
            for deviation_penalitetrait := -2 to 2 do
              with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
                begin
                  nombreParties := 0;
                  pions := 0;
                  nbreGains := 0;
                  flags := 0;
                end;
      deja_au_moins_un_match_en_memoire := false;
    end;
end;


function PeutAllouerTableauDeviations : boolean;
begin
  if (deviations = NIL) then
    begin
      deviations := DeviationArrayPtr(AllocateMemoryPtr(SizeOf(DeviationArray)));
      VideTableauDeviations;
    end;
  PeutAllouerTableauDeviations := (deviations <> NIL);
end;


procedure DesallouerMemoireTableauDeviations;
begin
  if (deviations <> NIL) then DisposeMemoryPtr(Ptr(deviations));
  deviations := NIL;
end;


function GetBoolean(flagBits : SInt32; mask : SInt32) : boolean;
begin
  GetBoolean := ((flagBits and mask) <> 0);
end;

procedure SetBoolean(var flagBits : SInt32; mask : SInt32; whichBoolean : boolean);
begin
  if whichBoolean
    then flagBits := BOR(flagBits,mask)
    else flagBits := BOR(flagBits,mask) - mask;
end;


function GetDoitFaireCetteDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait : SInt32) : boolean;
begin
  if deviations <> NIL
    then GetDoitFaireCetteDeviation := GetBoolean(deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait].flags, kFaireCetteDeviation)
    else GetDoitFaireCetteDeviation := false;
end;


procedure SetDoitFaireCetteDeviation(flag : boolean; deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait : SInt32);
begin
  if deviations <> NIL then
    begin
      SetBoolean(deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait].flags, kFaireCetteDeviation, flag);
    end;
end;

(* A partir d'un entier entre 0 et 624, renvoie le quadruplet des chiffres en base 5 *)
procedure IndexTriEnQuadrupletDeviations(index : SInt32; var dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32);
var aux : SInt32;
begin
  dev_frontiere := 0;
  dev_minimisation := 0;
  dev_mobilite := 0;
  dev_penalitetrait := 0;

  if (index >= 0) and (index <= 624) then
    begin
      aux := index mod 5;
      dev_penalitetrait := aux - 2;

      index := index div 5;
      aux := index mod 5;
      dev_mobilite := aux - 2;

      index := index div 5;
      aux := index mod 5;
      dev_minimisation := aux - 2;

      index := index div 5;
      aux := index mod 5;
      dev_frontiere := aux - 2;

    end;
end;


procedure AjouterResultatMatchPourCetteDeviation(index : SInt32; delta_nombreParties,delta_pions,delta_nbreGains : SInt32);
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          nombreParties := nombreParties + delta_nombreParties;
          pions         := pions         + delta_pions;
          nbreGains     := nbreGains     + delta_nbreGains;
        end;
      deja_au_moins_un_match_en_memoire := true;
    end;
end;


function PourcentageDeCetteDeviation(index : SInt32) : double_t;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  PourcentageDeCetteDeviation := 0.0;

  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          if (nombreParties <> 0) then
            PourcentageDeCetteDeviation := 100.0 * (nbreGains / nombreParties);
        end;
    end;
end;

function NombrePionsDeCetteDeviation(index : SInt32) : SInt32;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePionsDeCetteDeviation := 0;

  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          NombrePionsDeCetteDeviation := pions;
        end;
    end;
end;

function NombrePartiesDeCetteDeviation(index : SInt32) : SInt32;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePartiesDeCetteDeviation := 0;

  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          NombrePartiesDeCetteDeviation := nombreParties;
        end;
    end;
end;

function NombrePionsMoyenDeCetteDeviation(index : SInt32) : double_t;
var deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
begin
  NombrePionsMoyenDeCetteDeviation := 0.0;

  if (deviations <> NIL) then
    begin
      IndexTriEnQuadrupletDeviations(index,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
      with deviations^[deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait] do
        begin
          if (nombreParties <> 0) then
            NombrePionsMoyenDeCetteDeviation := (pions / nombreParties);
        end;
    end;
end;


function LecturePourTriDeviations(index : SInt32) : SInt32;
begin
  LecturePourTriDeviations := table_de_tri_des_deviations[index];
end;

procedure AffectionPourTriDeviations(index,element : SInt32);
begin
  table_de_tri_des_deviations[index] := element;
end;

function OrdrePourcentageGlobalPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : double_t;
begin
  v1 := PourcentageDeCetteDeviation(element1) - 0.00*NombrePartiesDeCetteDeviation(element1);
  v2 := PourcentageDeCetteDeviation(element2) - 0.00*NombrePartiesDeCetteDeviation(element2);

  if (abs(v1 - v2) > 0.001)
    then OrdrePourcentageGlobalPourTriDeviation := (v1 < v2)
    else OrdrePourcentageGlobalPourTriDeviation := (NombrePionsMoyenDeCetteDeviation(element1) <= NombrePionsMoyenDeCetteDeviation(element2));
end;

function OrdreNombreMoyenDePionsPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : double_t;
begin
  v1 := NombrePionsMoyenDeCetteDeviation(element1);
  v2 := NombrePionsMoyenDeCetteDeviation(element2);

  if (abs(v1 - v2) > 0.001)
    then OrdreNombreMoyenDePionsPourTriDeviation := (v1 < v2)
    else OrdreNombreMoyenDePionsPourTriDeviation := (PourcentageDeCetteDeviation(element1) <= PourcentageDeCetteDeviation(element2));
end;


function OrdrePlusVieuxPourTriDeviation(element1,element2 : SInt32) : boolean;
var v1,v2 : SInt32;
begin
  v1 := NombrePartiesDeCetteDeviation(element1);
  v2 := NombrePartiesDeCetteDeviation(element2);

  if (v1 <> v2)
    then OrdrePlusVieuxPourTriDeviation := (v1 > v2)
    else OrdrePlusVieuxPourTriDeviation := OrdrePourcentageGlobalPourTriDeviation(element1,element2);
end;


procedure AfficherDeviationDansRapport(rang,index : SInt32);
var dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    s1 : String255;
begin
  IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

  WriteNumDansRapport('#',rang);
  WriteNumDansRapport(' • ',index);
  WriteNumDansRapport('•(',dev_frontiere);
  WriteNumDansRapport(',',dev_minimisation);
  WriteNumDansRapport(',',dev_mobilite);
  WriteNumDansRapport(',',dev_penalitetrait);
  WriteDansRapport(') => ');


  s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index)) + '%';
  s1 := s1 + '•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index));
  s1 := s1 + '•'+NumEnString(NombrePartiesDeCetteDeviation(index)) + ')';
  WriteDansRapport(s1);

  WritelnDansRapport('');

end;


procedure SelectionnerUnChampion;
var t,index : SInt32;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    compteur : SInt32;
begin

(* Initialisation d'une passe : on ne garde aucune deviation *)
  for dev_frontiere := -2 to 2 do
    for dev_minimisation := -2 to 2 do
      for dev_mobilite := -2 to 2 do
        for dev_penalitetrait := -2 to 2 do
          SetDoitFaireCetteDeviation(false,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
  deviations_a_tester.cardinal := 0;
  for t := 1 to kNombreMaxDeviationsTesteesParPasse do
    deviations_a_tester.numeros[t] := -1;


  WritelnDansRapport('#Selection du champion…');

  index := 289;  (* Le champion ! *)
  index := kIndexJoueurSansDeviation;
  IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

  if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
    begin
      inc(compteur);
      SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      AfficherDeviationDansRapport(0,index);

      if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
        begin
          inc(deviations_a_tester.cardinal);
          deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
        end;
    end;
end;


procedure TrierMeilleuresDeviations;
var t,index : SInt32;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
    compteur : SInt32;
begin

  (* on teste d'abord si on est tout au debut... *)
  if not(deja_au_moins_un_match_en_memoire) then
    begin
      (* a la premiere passe, on essaye toutes les deviations *)
      for dev_frontiere := -2 to 2 do
        for dev_minimisation := -2 to 2 do
          for dev_mobilite := -2 to 2 do
            for dev_penalitetrait := -2 to 2 do
              SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
      deviations_a_tester.cardinal := kNombreMaxDeviationsTesteesParPasse;
      for t := 1 to kNombreMaxDeviationsTesteesParPasse do
        deviations_a_tester.numeros[t] := t-1;
      exit(TrierMeilleuresDeviations);
    end;


  (* Initialisation d'une passe : on ne garde aucune deviation *)
  for dev_frontiere := -2 to 2 do
    for dev_minimisation := -2 to 2 do
      for dev_mobilite := -2 to 2 do
        for dev_penalitetrait := -2 to 2 do
          SetDoitFaireCetteDeviation(false,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
  deviations_a_tester.cardinal := 0;
  for t := 1 to kNombreMaxDeviationsTesteesParPasse do
    deviations_a_tester.numeros[t] := -1;


  (* Selection éventuelle des déviations n'ayant jamais été testées *)
  compteur := 0;
  for t := 0 to 624 do
    begin
      index := t;
      IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

      if (NombrePartiesDeCetteDeviation(index) = 0) then
        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            if (compteur <= 0) then WritelnDansRapport('#Selection des deviations non encore testées…');

            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);

            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;

          end;
    end;

  (* A chaque passe, garder les 15 meilleures deviations... *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePourcentageGlobalPourTriDeviation);

  WritelnDansRapport('#Selection des meilleurs pourcentages…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreDeviationTesteesSurPourcentage) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);

            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;
          end;
      end;

  (* ...et les 5 meilleurs totaux de pions... *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdreNombreMoyenDePionsPourTriDeviation);

  WritelnDansRapport('#Selection des meilleures moyennes de pions…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreDeviationTesteesSurPions) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);

            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;

          end;
      end;

  (* ...et 5 deviations parmis les plus vieilles *)
  GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePlusVieuxPourTriDeviation);

  WritelnDansRapport('#Selection de quelques vieilles deviations…');
  compteur := 0;
  for t := 0 to 624 do
    if (compteur < kNombreViellesDeviationTestees) then
      begin
        index := LecturePourTriDeviations(t);
        IndexTriEnQuadrupletDeviations(index,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

        if not(GetDoitFaireCetteDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait)) then
          begin
            inc(compteur);
            SetDoitFaireCetteDeviation(true,dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);
            AfficherDeviationDansRapport(t,index);

            if (deviations_a_tester.cardinal < kNombreMaxDeviationsTesteesParPasse) then
              begin
                inc(deviations_a_tester.cardinal);
                deviations_a_tester.numeros[deviations_a_tester.cardinal] := index;
              end;

          end;
      end;

end;


function PeutParserFichierRapportLogPourTournoiDeviations : boolean;
var fichierRapport : FichierTEXT;
    filename : String255;
    s : String255;
    erreurES : SInt16;
    longueur,gains,index,pions : SInt32;
    s1,s2,s3,s4,s5,s6,reste : String255;
    i1,i2,i3,i4 : String255;
    oldParsingSet : SetOfChar;
    dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait : SInt32;
begin

  WritelnDansRapport('# Entree dans PeutParserFichierRapportLogPourTournoiDeviations');

  PeutParserFichierRapportLogPourTournoiDeviations := false;
  filename := 'Rapport.log';
  erreurES := FichierTexteDeCassioExiste(filename,fichierRapport);
  if erreurES <> NoErr then exit(PeutParserFichierRapportLogPourTournoiDeviations);
  erreurES := OuvreFichierTexte(fichierRapport);
  if erreurES <> NoErr then exit(PeutParserFichierRapportLogPourTournoiDeviations);

  repeat
    erreurES := ReadlnDansFichierTexte(fichierRapport,s);
    if (s <> '') and (erreurES = NoErr) then
      if (s[1] <> '#') and (Pos('(front,min,mob,pen)',s) = 1) then
        begin
          longueur := LENGTH_OF_STRING(s);


          Parser6(s,s1,s2,s3,s4,s5,s6,reste);

          (* calcul de l'index dans le tableau des deviations *)
          oldParsingSet := GetParsingCaracterSet;
        	SetParsingCaracterSet(['(',',',')']);
        	Parser4(s3,i1,i2,i3,i4,reste);
        	SetParsingCaracterSet(oldParsingSet);
        	ChaineToLongint(i1,dev_frontiere);
        	ChaineToLongint(i2,dev_minimisation);
        	ChaineToLongint(i3,dev_mobilite);
        	ChaineToLongint(i4,dev_penalitetrait);
        	index := IndexTriTableauDeviation(dev_frontiere,dev_minimisation,dev_mobilite,dev_penalitetrait);

          (* calcul du nombre de parties gagnees sur les kNombrePartiesParMatchDansDemo du match *)
          if (s5 = '0')   then gains := 0 else
          if (s5 = '0.5') then gains := 1 else
          if (s5 = '1')   then gains := 2 else
          if (s5 = '1.5') then gains := 3 else
          if (s5 = '2')   then gains := 4 else
          if (s5 = '2.5') then gains := 5 else
          if (s5 = '3')   then gains := 6 else
          if (s5 = '3.5') then gains := 7 else
          if (s5 = '4')   then gains := 8 else
          if (s5 = '4.5') then gains := 9 else
          if (s5 = '5')   then gains := 10 else
          if (s5 = '5.5') then gains := 11 else
          if (s5 = '6')   then gains := 12;

          (* calcul du nombre de pions recoltes dans le match *)
          ChaineToLongint(s6,pions);

          AjouterResultatMatchPourCetteDeviation(index,kNombrePartiesParMatchDansDemo,pions,gains);

          (* on ecrit quelques lignes au hasard pour verifier que l'on parse bien... *)
          if false and (index >= 168) and (index <= 168) then
            begin
              WritelnDansRapport(s);
              WriteNumDansRapport('••••••••• ',index);
              WriteNumDansRapport('•(',dev_frontiere);
              WriteNumDansRapport(',',dev_minimisation);
              WriteNumDansRapport(',',dev_mobilite);
              WriteNumDansRapport(',',dev_penalitetrait);
              WriteDansRapport(') => ');

              s1 := NumEnString(gains div 2);
              if odd(gains) then s1 := s1 + '.5';
              s2 := NumEnString(pions);
              WriteDansRapport(s1+'  '+s2+ '  ');
              if (kNombrePartiesParMatchDansDemo) <> 0 then
                begin
                  s1 := ReelEnString(100.0*gains/(1.0*(kNombrePartiesParMatchDansDemo)));
                  WriteDansRapport(s1+' %');
                end;

              s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index)) + '%';
              s1 := s1 + '•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index));
              s1 := s1 + '•'+NumEnString(NombrePartiesDeCetteDeviation(index)) + ')';
              WriteDansRapport(s1);

              WritelnDansRapport('');

            end;

        end;
  until (erreurES <> NoErr) or EOFFichierTexte(fichierRapport,erreurES);
  erreurES := FermeFichierTexte(fichierRapport);

  WritelnNumDansRapport('#sortie de PeutParserFichierRapportLogPourTournoiDeviations, erreurES = ',erreurES);

  PeutParserFichierRapportLogPourTournoiDeviations := (erreurES = NoErr);
end;


procedure DoDemo(niveau1,niveau2 : SInt32; avecAttente,avecSauvegardePartieDansListe : boolean);
var
    quitterDemo : boolean;

    Coeffinfluence1 : double_t;
    Coefffrontiere1 : double_t;
    CoeffEquivalence1 : double_t;
    Coeffcentre1 : double_t;
    Coeffgrandcentre1 : double_t;
    Coeffdispersion1 : double_t;
    Coeffminimisation1 : double_t;
    CoeffpriseCoin1 : double_t;
    CoeffdefenseCoin1 : double_t;
    CoeffValeurCoin1 : double_t;
    CoeffValeurCaseX1 : double_t;
    CoeffPenalite1 : double_t;
    CoeffMobiliteUnidirectionnelle1 : double_t;
    avecEvaluationTablesDeCoins1 : boolean;

    Coeffinfluence2 : double_t;
    Coefffrontiere2 : double_t;
    CoeffEquivalence2 : double_t;
    Coeffcentre2 : double_t;
    Coeffgrandcentre2 : double_t;
    Coeffdispersion2 : double_t;
    Coeffminimisation2 : double_t;
    CoeffpriseCoin2 : double_t;
    CoeffdefenseCoin2 : double_t;
    CoeffValeurCoin2 : double_t;
    CoeffValeurCaseX2 : double_t;
    CoeffPenalite2 : double_t;
    CoeffMobiliteUnidirectionnelle2 : double_t;
    avecEvaluationTablesDeCoins2 : boolean;

    finDePartieVitesseMactemp : SInt32;
    finDePartieOptimaleVitesseMactemp : SInt32;


    i : SInt32;


    utiliseGrapheApprentissageTemp : boolean;
    ecritureDansRapportTemp : boolean;
    avecBiblTemp : boolean;
    utilisateurVeutDiscretiserEvaluationTemp : boolean;
    oldInterruption : SInt16;
    tempoCassioVarieSesCoups : boolean;



    nroPasse : SInt32;
    deviation_frontiere : SInt32;
    deviation_minimisation : SInt32;
    deviation_mobilite : SInt32;
    deviation_penalitetrait : SInt32;
    index_deviation_courante : SInt32;
    scoreDuJoueur2 : double_t;







 procedure ChangeCoefficientDansDemo(var whichCoeff : double_t; amplitudeDeviation : SInt32);
 begin
   case amplitudeDeviation of
      -2 : whichCoeff := 0.66 * whichCoeff;
      -1 : whichCoeff := 0.80 * whichCoeff;
      0  : whichCoeff := 1.0  * whichCoeff;
      1  : whichCoeff := 1.15 * whichCoeff;
      2  : whichCoeff := 1.30 * whichCoeff;
   end;
 end;




procedure ChoisitCoefficientsDuMatch(indexJoueur1,indexJoueur2 : SInt32);
 var deviation_frontiere : SInt32;
     deviation_minimisation : SInt32;
     deviation_mobilite : SInt32;
     deviation_penalitetrait : SInt32;
  begin

    (* joueur 1 *)

    {DoCoefficientsEvaluation;}
    CoefficientsStandard;

    IndexTriEnQuadrupletDeviations(indexJoueur1,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
    ChangeCoefficientDansDemo(Coefffrontiere,                 deviation_frontiere);
    ChangeCoefficientDansDemo(Coeffminimisation,              deviation_minimisation);
    ChangeCoefficientDansDemo(CoeffMobiliteUnidirectionnelle, deviation_mobilite);
    ChangeCoefficientDansDemo(CoeffPenalite,                  deviation_penalitetrait);

    Coeffinfluence1 := CoeffInfluence;
    Coefffrontiere1 := Coefffrontiere;
    CoeffEquivalence1 := CoeffEquivalence;
    Coeffcentre1 := Coeffcentre;
    Coeffgrandcentre1 := Coeffgrandcentre;
    Coeffdispersion1 := Coeffbetonnage;
    Coeffminimisation1 := Coeffminimisation;
    CoeffpriseCoin1 := CoeffpriseCoin;
    CoeffdefenseCoin1 := CoeffdefenseCoin;
    CoeffValeurCoin1 := CoeffValeurCoin;
    CoeffValeurCaseX1 := CoeffValeurCaseX;
    CoeffPenalite1 := CoeffPenalite;
    CoeffMobiliteUnidirectionnelle1 := CoeffMobiliteUnidirectionnelle;
    avecEvaluationTablesDeCoins1 := avecEvaluationTablesDeCoins;



    (* joueur 2 *)

    {DoCoefficientsEvaluation;}
    CoefficientsStandard;


    IndexTriEnQuadrupletDeviations(indexJoueur2,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
    ChangeCoefficientDansDemo(Coefffrontiere,                 deviation_frontiere);
    ChangeCoefficientDansDemo(Coeffminimisation,              deviation_minimisation);
    ChangeCoefficientDansDemo(CoeffMobiliteUnidirectionnelle, deviation_mobilite);
    ChangeCoefficientDansDemo(CoeffPenalite,                  deviation_penalitetrait);


    Coeffinfluence2 := CoeffInfluence;
    Coefffrontiere2 := Coefffrontiere;
    CoeffEquivalence2 := CoeffEquivalence;
    Coeffcentre2 := Coeffcentre;
    Coeffgrandcentre2 := Coeffgrandcentre;
    Coeffdispersion2 := Coeffbetonnage;
    Coeffminimisation2 := Coeffminimisation;
    CoeffpriseCoin2 := CoeffpriseCoin;
    CoeffdefenseCoin2 := CoeffdefenseCoin;
    CoeffValeurCoin2 := CoeffValeurCoin;
    CoeffValeurCaseX2 := CoeffValeurCaseX;
    Coeffpenalite2 := CoeffPenalite;
    CoeffMobiliteUnidirectionnelle2 := CoeffMobiliteUnidirectionnelle;
    avecEvaluationTablesDeCoins2 := avecEvaluationTablesDeCoins;

  end;





 procedure EcritStatistiquesDuMatchDansRapport(match : MatchTournoiRec);
  var s1,s2 : String255;
  begin
    with match do
      begin

        WriteDansRapport('(front,min,mob,pen) = ');
        WriteNumDansRapport('(',deviation_frontiere);
        WriteNumDansRapport(',',deviation_minimisation);
        WriteNumDansRapport(',',deviation_mobilite);
        WriteNumDansRapport(',',deviation_penalitetrait);
        WriteDansRapport(') => ');

        (*
        NumEnString(niveau2,s1);
        s1 := 'prof '+s1+' (n°2)';
        WriteDansRapport(s1+'••••');
        *)

        s1 := NumEnString(fanny[2] div 2);
        if odd(fanny[2]) then s1 := s1 + '.5';
        s2 := NumEnString(scorecumule[2]);
        WriteDansRapport(s1+'  '+s2+ '  ');
        if (fanny[2]+fanny[1]) <> 0 then
          begin
            s1 := ReelEnString(100.0*fanny[2]/(1.0*(fanny[2]+fanny[1])));
            WriteDansRapport(s1+' %');
          end;

        s1 := ' (->'+ReelEnString(PourcentageDeCetteDeviation(index_deviation_courante)) + '%';
        s1 := s1 + '•'+ReelEnString(NombrePionsMoyenDeCetteDeviation(index_deviation_courante));
        s1 := s1 + '•'+NumEnString(NombrePartiesDeCetteDeviation(index_deviation_courante)) + ')';
        WriteDansRapport(s1);

        WritelnDansRapport('');
      end;
  end;

(* Renvoie le pourcentage du joueur 2 contre 1 *)
function FaireUnMatchEntreDeviations(var match : MatchTournoiRec) : double_t;
var ouverturesJouees : StringSet;
begin

  with match do
    begin
      ChoisitCoefficientsDuMatch(joueur1,joueur2);


      ouverturesJouees := MakeEmptyStringSet;

      FaireUnMatchEntreDeviations := FaireUnMatch(match, ouverturesJouees);

      DisposeStringSet(ouverturesJouees);


      (* Mettre a jour les pourcentages des deviations *)
      AjouterResultatMatchPourCetteDeviation(joueur1,fanny[1]+fanny[2],scorecumule[1],fanny[1]);
      AjouterResultatMatchPourCetteDeviation(joueur2,fanny[1]+fanny[2],scorecumule[2],fanny[2]);
    end;
end;


procedure FaireUnePasseDeMatchsContreLeChampion;
var rang_deviation_a_tester : SInt32;
    i,j,k,l : SInt32;
    match : MatchTournoiRec;
begin

  for rang_deviation_a_tester := 1 to deviations_a_tester.cardinal do
    for i := -2 to 2 do
      for j := -2 to 2 do
        for k := -2 to 2 do
          for l := -2 to 2 do
            if not(quitterDemo or Quitter) then
              BEGIN

                deviation_frontiere := i;
                deviation_minimisation := j;
                deviation_mobilite := k;
                deviation_penalitetrait := l;

                if GetDoitFaireCetteDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait) then
                  begin

                    index_deviation_courante := IndexTriTableauDeviation(deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);

                    if (index_deviation_courante = deviations_a_tester.numeros[rang_deviation_a_tester]) then
                      begin
                        (* Faire le match *)

                        match.typeDeMatch := ENTRE_DEVIATIONS;
                        match.joueur1 := kIndexJoueurSansDeviation;
                        match.joueur2 := index_deviation_courante;
                        match.ouverture := tournoiDeviations.ouverture;
                        match.nbParties := kNombrePartiesParMatchDansDemo;
                        match.niveau1                       := tournoiDeviations.settings.niveau1;
                        match.niveau2                       := tournoiDeviations.settings.niveau2;
                        match.avecAttenteEntreParties       := avecAttente;
                        match.avecSauvegardePartieDansListe := tournoiDeviations.doitSauvegarderPartieDansListe;

                        scoreDuJoueur2 := FaireUnMatchEntreDeviations(match);

                        (* Mettre a jour les pourcentages des deviations *)
                        if not(quitterDemoorQuitter) then
                          with match do
                            begin
                              AjouterResultatMatchPourCetteDeviation(index_deviation_courante,fanny[1]+fanny[2],scorecumule[2],fanny[2]);
                              EcritStatistiquesDuMatchDansRapport(match);
                              (* on ne conserve une combinaison de deviations que si elle a fait au moins 33 % *)
                              if (PourcentageDeCetteDeviation(index_deviation_courante) < 33.0) then
                                SetDoitFaireCetteDeviation(false,deviation_frontiere,deviation_minimisation,deviation_mobilite,deviation_penalitetrait);
                            end;
                      end;

                  end;

              END;
end;





procedure FaireUnTournoiToutesRondesDesMeilleursDeviations;
var index,t,r,n1,n2 : SInt32;
    indexJoueur1,indexJoueur2 : SInt32;
    scoreDuJoueur2 : double_t;
    tours : SInt32;
    match : MatchTournoiRec;
    ouverturesJoueesDansLeMatch : StringSet;
begin

  if not(quitterDemo or Quitter) then
    with tournoiDeviations do
      begin


        nbToursDuTournoi  := 1;
        nbPartiesParMatch := kNombrePartiesParMatchDansDemo;

        WritelnDansRapport('## DEBUT DU TOURNOI');

        (* On selectionne les 15 meilleures deviations pour jouer dans le tournoi... *)
        GeneralQuickSort(0,624,LecturePourTriDeviations,AffectionPourTriDeviations,OrdrePourcentageGlobalPourTriDeviation);



        (* Selection des meilleurs *)
        WritelnDansRapport('#Selection des meilleurs pourcentages pour le tournoi…');
        for t := 0 to kNombreDeviationsDansLeTournoi - 1 do
          begin
            index := LecturePourTriDeviations(t);
            indexParticipant[t] := index;
          end;

        (* Le champion local joue aussi (100% sur tous les coeffs) *)
        indexParticipant[kNombreDeviationsDansLeTournoi] := kIndexJoueurSansDeviation;  (* Le champion ! *)


        (* Afficher les participants *)

        WritelnDansRapport('#Participants au tournoi : ');
        nbParticipants := kNombreDeviationsDansLeTournoi + 1;
        for t := 0 to nbParticipants - 1 do
          begin
            scoreParticipant[t] := 0.0;
            AfficherDeviationDansRapport(t,indexParticipant[t]);
          end;


        if not(quitterDemo or Quitter) then
          for tours := 1 to nbToursDuTournoi do
            for r := 1 to kNombreDeviationsDansLeTournoi do
              begin
                numeroRonde := r;

                WritelnNumDansRapport('#RONDE ',numeroRonde);

                FaireTournerParticipantsTournoiToutesRondes(numeroRonde,tournoiDeviations);

                for t := 0 to (kNombreDeviationsDansLeTournoi div 2) do
                  if not(quitterDemo or Quitter) then
                    begin
                      n1 := tableauTouteRonde[t];
                      n2 := tableauTouteRonde[kNombreDeviationsDansLeTournoi - t];

                      indexJoueur1 := indexParticipant[n1];
                      indexJoueur2 := indexParticipant[n2];


                      (* Faire le match *)
                      WriteDansRapport('match '+NumEnString(indexJoueur1)+'-'+NumEnString(indexJoueur2)+'… ');

                      match.typeDeMatch := ENTRE_DEVIATIONS;
                      match.joueur1 := indexJoueur1;
                      match.joueur2 := indexJoueur2;
                      match.ouverture := tournoiDeviations.ouverture;
                      match.nbParties := nbPartiesParMatch;
                      match.niveau1                       := tournoiDeviations.settings.niveau1;
                      match.niveau2                       := tournoiDeviations.settings.niveau2;
                      match.avecAttenteEntreParties       := avecAttente;
                      match.avecSauvegardePartieDansListe := tournoiDeviations.doitSauvegarderPartieDansListe;


                      ouverturesJoueesDansLeMatch := MakeEmptyStringSet;

                      scoreDuJoueur2 := FaireUnMatch(match, ouverturesJoueesDansLeMatch)/100.0;

                      DisposeStringSet(ouverturesJoueesDansLeMatch);

                      WriteStringAndReelDansRapport(' ',(1.0 - scoreDuJoueur2),3);
                      WritelnStringAndReelDansRapport('-',scoreDuJoueur2,3);

                      (* mettre a jour les scores des joueurs dans le tournoi *)
                      scoreParticipant[n1] := scoreParticipant[n1] + (1.0 - scoreDuJoueur2);
                      scoreParticipant[n2] := scoreParticipant[n2] + scoreDuJoueur2;




                    end;

                if not(quitterDemo or Quitter) then
                  begin
                    WritelnNumDansRapport('Classement après la ronde ',numeroRonde);
                    for t := 0 to nbParticipants - 1 do
                      begin
                        WriteStringAndReelDansRapport(NumEnString(indexParticipant[t])+'   =>   s = ',scoreParticipant[t],3);
                        WriteStringAndReelDansRapport(' (',100*scoreParticipant[t]/numeroRonde,4);
                        WritelnDansRapport('%)');
                      end;
                  end;
              end;
      end;

end;



begin {DoDemo}

  with tournoiDeviations, tournoiDeviations.ouverture do
    begin

      tournoiDeviations.settings.niveau1 := niveau1;
      tournoiDeviations.settings.niveau2 := niveau2;
      tournoiDeviations.doitSauvegarderPartieDansListe := avecSauvegardePartieDansListe;

      if not(windowPlateauOpen) then OuvreFntrPlateau(false);
      finDePartieVitesseMactemp := finDePartieVitesseMac;
      finDePartieOptimaleVitesseMactemp := finDePartieOptimaleVitesseMac;
      finDePartieVitesseMac := 42;
      finDePartieOptimaleVitesseMac := 41;
      UtiliseGrapheApprentissageTemp := UtiliseGrapheApprentissage;
      ecritureDansRapportTemp := GetEcritToutDansRapportLog;
      SetEcritToutDansRapportLog(true);
      utilisateurVeutDiscretiserEvaluationTemp := utilisateurVeutDiscretiserEvaluation;
      avecBiblTemp := avecBibl;
      enTournoi := true;
      with gEntrainementOuvertures do
        begin
          tempoCassioVarieSesCoups := CassioVarieSesCoups;
          CassioVarieSesCoups := FALSE;
          CassioSeContenteDeLaNulle := FALSE;
          for i := 0 to 64 do
            deltaNotePerduCeCoup[i] := 0;
          deltaNoteAutoriseParCoup := 0;
          deltaNotePerduAuTotal := 0;
        end;
      ouverturesAleatoires := true;
      quitterDemo := false;
      HumCtreHum := false;
      AjusteSleep;
      DessineIconesChangeantes;


      nbCoupsImposes := nbreCoup;
      longueurOuvertureAleatoire := 8;
      nbCoupsIdentiques := Max(nbCoupsImposes,longueurOuvertureAleatoire);

      for i := 1 to nbCoupsImposes do
        premiersCoups[i] := GetNiemeCoupPartieCourante(i);
      for i := nbCoupsImposes+1 to 60 do
        premiersCoups[i] := 0;

       WritelnDansRapport('# avant PeutAllouerTableauDeviations dans DoDemo');

       if PeutAllouerTableauDeviations and PeutParserFichierRapportLogPourTournoiDeviations  then
         begin
           for nroPasse := 1 to 10000 do
             if not(quitterDemo or Quitter) then
               begin

                 WritelnNumDansRapport('## DEBUT DE LA PASSE ',nroPasse);

                 {if ((nroPasse mod 5) = 0) then }
                  {FaireUnTournoiToutesRondesDesMeilleursDeviations;}

                 (* Selectionner les meilleures deviations potentielles à developper *)
                 {TrierMeilleuresDeviations;}

                 (* Selectionner une seule deviation *)
                 SelectionnerUnChampion;

                 FaireUnePasseDeMatchsContreLeChampion;


               end;
         end;



       Quitter := false;
       enTournoi := false;
       gEntrainementOuvertures.CassioVarieSesCoups := tempoCassioVarieSesCoups;
       gEntrainementOuvertures.CassioSeContenteDeLaNulle := true;
       UtiliseGrapheApprentissage := UtiliseGrapheApprentissageTemp;
       avecBibl := avecBiblTemp;
       utilisateurVeutDiscretiserEvaluation := utilisateurVeutDiscretiserEvaluationTemp;
       SetProfImposee(false,'fin de DoDemo');
       finDePartieVitesseMac := finDePartieVitesseMactemp;
       finDePartieOptimaleVitesseMac := finDePartieOptimaleVitesseMactemp;
       SetEcritToutDansRapportLog(ecritureDansRapportTemp);

       Initialise_valeurs_bords(-0.5);
       Initialise_turbulence_bords(true);

       LanceInterruption(oldInterruption,'DoDemo');


       DesallouerMemoireTableauDeviations;

  end;

end;






(*
 *******************************************************************************
 *                                                                             *
 *   AlignerTestsFinales permet de tester des modifications de l'ago de finale *
 *   de Cassio.                                                                *
 *                                                                             *
 *******************************************************************************
 *)
procedure AlignerTestsFinales(numeroDeb,numeroFin : SInt16; typeFinaleAlgoReference,typeFinaleAlgoFast : SInt16);
label sortie;
const nbDiagrammes = 100;
      decalageVertAffichage = 150;
      nbAlgos = 20;
      faireAlgoStandard = true;    {false ou true }
      noMinLigneAff = 1;           {cette ligne et la suivante : nb d'algos testés en plus du normal}
      noMaxLigneAff = 1;           {mettre à 0 pour ne calculer que l'algo normal}
var numeroTest,increment : SInt16;
    s,nomFichier : String255;
    tempsCumules : array[0..nbAlgos] of SInt32;
    StatDiagramme : array[1..nbDiagrammes] of record
	                                              meilleurTemps : SInt32;
	                                              meilleurNbGeneres : SInt32;
	                                              deltaNoeudsReference : SInt32;
	                                              NbNoeudsReference : SInt32;
	                                              ref : SInt16;
	                                              valeur : SInt16;
                                              end;
    tick : SInt32;
    solveResults : MakeEndgameSearchResultRec;
    prof,nbBlanc,nbNoir : SInt32;
    noLigneAff : SInt16;
    nbreNoeudsAlgoNormal : SInt32;
    nbDiagDejaAffiches : SInt16;
    HumCtreHumArrivee : boolean;
    erreurES : OSErr;
    oldInterruption : SInt16;
    i : SInt16;
    positionGagnante : boolean;
    searchParam : MakeEndgameSearchParamRec;

 procedure GetStringDeLigneAff(noLigneAff : SInt16; var s : String255);
 var i,k : SInt16;
 begin {$unused i,k}
   s := NumEnString(noLigneAff);


   effetspecial := true;

   case noLigneAff of
     1: begin
          nroEffetspecial := 1;


        end;
     2: begin
          nroEffetspecial := 2;


        end;
     3: begin
          nroEffetspecial := 3;

        end;
     4: begin
          nroEffetspecial := 4;

        end;
     5: begin
          nroEffetspecial := 5;

        end;
     6: begin
          nroEffetspecial := 6;



        end;
     7: begin
          nroEffetspecial := 7;


        end;
     8: begin
          nroEffetspecial := 8;


        end;
     9: begin
          nroEffetspecial := 9;


        end;
     10: begin
          nroEffetspecial := 10;


        end;
     11: begin
          nroEffetspecial := 11;



        end;
     12: begin
          nroEffetspecial := 12;



        end;
     13: begin
          nroEffetspecial := 13;


        end;
     14: begin
          nroEffetspecial := 14;

          SetValeurStandardLiaisonArbreZoo;

          liaisonArbreZoo.tempsMinimalPourEnvoyerAuZoo  := 1.5;


          liaisonArbreZoo.margePourParallelismeAlphaSpeculatif  := 200;    {on considere que quand eval <= alpha - 6.0 , on a une coupure alpha presque sure }
          liaisonArbreZoo.margePourParallelismeHeuristique      := 800;    {on parellelisera moins facilement les coups dont (eval <= alpha - mu - 5.00) ou (eval >= beta + mu + 5.00) }


        end;
   end;




   s := '[s = '+NumEnString(nroEffetspecial)+'] : ';

   if VerifieAssertionsDeFinale then DoNothing;

   {WritelnStringAndBoolDansRapport('CassioUtiliseLeMultiprocessing = ',CassioUtiliseLeMultiprocessing);}

   {s := 'alg = '+s+' : ';}
 end;

 procedure AfficheResultats;
   const interligne = 10;
   var i,y : SInt16;
   begin
      PrepareTexteStatePourHeure;
      nbDiagDejaAffiches := 0;
      for i := 1 to nbDiagrammes do
        with StatDiagramme[i] do
          if (ref <> -1) then
            begin
              inc(nbDiagDejaAffiches);
              y := decalageVertAffichage+nbDiagDejaAffiches*interligne;
              WriteNumAt('dia = ',i,2,y);
              WriteNumAt('v = ',valeur,60,y);
              WriteStringAndReelAt('sec = ',1.0*meilleurTemps/60,100,y);
              WriteNumAt('algo = ',ref,175,y);
              WriteStringAndNumEnSeparantLesMilliersAt('norm = ',NbNoeudsReference,230,y);
              WriteStringAndNumEnSeparantLesMilliersAt('nœuds = ',meilleurNbGeneres,345,y);
              WriteStringAndNumEnSeparantLesMilliersAt('∆ = ',deltaNoeudsReference,460,y);
            end;
    end;

 function NombreKilosNoeudsGeneres : SInt32;
 begin
   NombreKilosNoeudsGeneres := nbreToursNoeudsGeneresFinale*1000000 +
                               ((nbreNoeudsGeneresFinale + 499) div 1000);
 end;

begin
  SetAutoVidageDuRapport(true);
  SetEcritToutDansRapportLog(true);

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);
  HumCtreHumArrivee := HumCtreHum;

  MemoryFillChar(@tempsCumules,sizeof(tempsCumules),chr(0));
  for i := 1 to nbDiagrammes do
    begin
      StatDiagramme[i].meilleurTemps := 1000000000;
      StatDiagramme[i].meilleurNbGeneres := 1000000000;
      StatDiagramme[i].ref := -1;
    end;

  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  ResetStatistiquesOrdreOptimumDesCases;
  {$ENDC}

  {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
  ResetStatistiquesStatutKnuthDesNoeuds;
  {$ENDC}


  // TesterLaFileDesResultatsDuParallelisme;


  if NumeroDeb = numeroFin then increment := 0;
  if NumeroDeb < numeroFin then increment := 1;
  if NumeroDeb > numeroFin then increment := -1;
  numeroTest := NumeroDeb-increment;
  repeat
   numeroTest := numeroTest+increment;
   if (interruptionReflexion = pasdinterruption) and not(Quitter) then
    begin
      s := NumEnString(numeroTest);
      if numeroTest < 10
        then nomFichier := pathCassioFolder+'Tests finale:TestFinale  '+s
        else nomFichier := pathCassioFolder+'Tests finale:TestFinale '+s;
      erreurES := OuvrirFichierPartieFormatCassio(nomFichier,false);
      if erreurES <> NoErr
        then goto sortie;


      if HumCtreHum then DoChangeHumCtreHum;
      InfosTechniquesDansRapport := true;
      couleurMacintosh := AQuiDeJouer;
      nbBlanc := nbreDePions[pionBlanc];
      nbNoir := nbreDePions[pionNoir];
      prof := 64 - nbBlanc - nbNoir;
      EnleveCetteInterruption(GetCurrentInterruption);
      seMefierDesScoresDeLArbre := true;

      dernierTick := TickCount-tempsDesJoueurs[AQuiDeJouer].tick;
      LanceChrono;
      tempsPrevu := 10;
      tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
      if not(RefleSurTempsJoueur) and (AQuiDeJouer = couleurMacintosh)
        then
          begin
            EcritJeReflechis(AQuiDeJouer);
          end;
      ReinitilaliseInfosAffichageReflexion;
      EffaceReflexion(true);

      case typeFinaleAlgoReference of
        ReflGagnant          : DoFinaleGagnante(false);
        ReflGagnantExhaustif : DoFinaleGagnante(false);
        ReflParfait          : DoFinaleOptimale(false);
        ReflParfaitExhaustif : DoFinaleOptimale(false);
        otherwise              DoFinaleGagnante(false);
      end;
      vaDepasserTemps := false;
      phaseDeLaPartie := CalculePhasePartie(nbreCoup);
      Superviseur(nbBlanc+pionNoir-4);
      if not(calculPrepHeurisFait) then
        Initialise_table_heuristique(JeuCourant,false);
      noLigneAff := 0;
      EnleveCetteInterruption(GetCurrentInterruption);

      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourHeure;
      WriteStringAndReelAt('cumulé normal : ',1.0*tempsCumules[0]/60,260,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin
          GetStringDeLigneAff(noLigneAff,s);
          WriteNumAt('a = ',noLigneAff,225,10+noLigneAff*10);
          WriteStringAndReelAt('cumulé '+s,1.0*tempsCumules[noLigneAff]/60,260,
                                    10+noLigneAff*10);
        end;


      AfficheResultats;
      PrepareTexteStatePourHeure;
      WriteNumAt('dia = ',numeroTest,2,decalageVertAffichage+(nbDiagDejaAffiches+1)*10);


      if (interruptionReflexion = pasdinterruption) then
        begin
          EssaieSetPortWindowPlateau;
          WriteStringAt('temps normal =                      ',0,10);
        end;



      Superviseur(nbNoir+nbBlanc-4);
      SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);
      EnleveCetteInterruption(GetCurrentInterruption);

      tick := TickCount;


      (************  ALGO STANDARD **************)

      if faireAlgoStandard then
        begin
		      SetEffetSpecial(false);
		      discretisationEvaluationEstOK := false;
		      typeEvalEnCours := EVAL_EDMOND;
		      InitValeursStandardAlgoFinale;
		      SetNombreDeProcesseursActifs(numProcessors);
		      //SetNombreDeProcesseursActifs(8);
		      SetValeurStandardLiaisonArbreZoo;
		      SetCassioUtiliseLeZoo(false,NIL);
		      DetruireLeZoo;

		      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
          InitMiniProfiler;
          {$ENDC}

          with searchParam do
            begin
               inTypeCalculFinale                   := typeFinaleAlgoReference;
               inCouleurFinale                      := AQuiDeJouer;
               inProfondeurFinale                   := prof;
               inNbreBlancsFinale                   := nbblanc;
               inNbreNoirsFinale                    := nbnoir;
               inAlphaFinale                        := -64;
               inBetaFinale                         := 64;
               inMuMinimumFinale                    := 0;
               inMuMaximumFinale                    := kDeltaFinaleInfini;
               inPrecisionFinale                    := 100;
               inPrioriteFinale                     := 0;
               inGameTreeNodeFinale                 := GetCurrentNode;
               inPositionPourFinale                 := JeuCourant;
               inMessageHandleFinale                := NIL;
               inCommentairesDansRapportFinale      := true;
               inMettreLeScoreDansLaCourbeFinale    := true;
               inMettreLaSuiteDansLaPartie          := true;
               inDoitAbsolumentRamenerLaSuiteFinale := false;
               inDoitAbsolumentRamenerUnScoreFinale := false;
               SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
               ViderSearchResults(outResult);
            end;

          positionGagnante := MakeEndgameSearch(searchParam);


          CopySearchResults(searchParam.outResult, solveResults);


		    end;

      if (interruptionReflexion = pasdinterruption) then
        begin
          tick := TickCount-tick;

          EssaieSetPortWindowPlateau;
          PrepareTexteStatePourHeure;
          WriteStringAndReelAt('temps normal = ',1.0*tick/60,0,10);
          WriteStringAndNumEnSeparantLesMilliersAt('nb = ',NombreKilosNoeudsGeneres,130,10);

          nbreNoeudsAlgoNormal := NombreKilosNoeudsGeneres;

          StatDiagramme[numeroTest].deltaNoeudsReference := 0;
          if noMaxLigneAff >= noMinLigneAff
            then StatDiagramme[numeroTest].meilleurNbGeneres := 2000000000  {2000000000 was MawLongint}
            else StatDiagramme[numeroTest].meilleurNbGeneres := 0;
          StatDiagramme[numeroTest].NbNoeudsReference := NombreKilosNoeudsGeneres;
          StatDiagramme[numeroTest].valeur := solveResults.outScoreFinale;
          if tick < StatDiagramme[numeroTest].meilleurTemps then
                begin
                  StatDiagramme[numeroTest].meilleurTemps := tick;
                  StatDiagramme[numeroTest].ref := 0;
                end;
          tempsCumules[0] := tempsCumules[0]+tick;


         {for i := 0 to nbTablesHashExactes-1 do}
         {for i := 0 to 0 do
             WritelnStringAndReelDansRapport('taux_remplissage['+NumEnString(i)+'] = ',TauxDeRemplissageHashExacte(i,false),5);
          EcritStatistiquesCollisionsHashTableDansRapport;
          }
        end;

      {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
      if faireAlgoStandard then EcritStatistiquesOrdreOptimumDesCasesDansRapport;
      {$ENDC}

      {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
      if faireAlgoStandard then EcritStatistiquesStatutKnuthDesNoeudsDansRapport;
      {$ENDC}


      (*********** LES ALGOS EN TEST **************)

      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin

          discretisationEvaluationEstOK := false;
          InitValeursStandardAlgoFinale;
          SetNombreDeProcesseursActifs(numProcessors);
          //SetNombreDeProcesseursActifs(8);
          SetCassioUtiliseLeZoo(false,NIL);
          SetValeurStandardLiaisonArbreZoo;
          DetruireLeZoo;

          GetStringDeLigneAff(noLigneAff,s);

          if (interruptionReflexion = pasdinterruption) then
            begin
              EssaieSetPortWindowPlateau;
              WriteStringAt('temps '+s+'                      ',0,10+noLigneAff*10);
            end;
          Superviseur(nbNoir+nbBlanc-4);
          SetUtilisationNouvelleEval(GetNouvelleEvalDejaChargee);
          tick := TickCount;


          {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
          ResetStatistiquesStatutKnuthDesNoeuds;
          {$ENDC}

          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
          InitMiniProfiler;
          {$ENDC}


          if (interruptionReflexion = pasdinterruption) then
            begin
              with searchParam do
                begin
                   inTypeCalculFinale                   := typeFinaleAlgoFast;
                   inCouleurFinale                      := AQuiDeJouer;
                   inProfondeurFinale                   := prof;
                   inNbreBlancsFinale                   := nbblanc;
                   inNbreNoirsFinale                    := nbnoir;
                   inAlphaFinale                        := -64;
                   inBetaFinale                         := 64;
                   inMuMinimumFinale                    := 0;
                   inMuMaximumFinale                    := kDeltaFinaleInfini;
                   inPrecisionFinale                    := 100;
                   inPrioriteFinale                     := 0;
                   inGameTreeNodeFinale                 := GetCurrentNode;
                   inPositionPourFinale                 := JeuCourant;
                   inMessageHandleFinale                := NIL;
                   inCommentairesDansRapportFinale      := true;
                   inMettreLeScoreDansLaCourbeFinale    := true;
                   inMettreLaSuiteDansLaPartie          := true;
                   inDoitAbsolumentRamenerLaSuiteFinale := false;
                   inDoitAbsolumentRamenerUnScoreFinale := false;
                   SetHashValueDuZoo(inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);
                   ViderSearchResults(outResult);
                end;

              positionGagnante := MakeEndgameSearch(searchParam);

              CopySearchResults(searchParam.outResult, solveResults);

            end;

          if (interruptionReflexion = pasdinterruption) then
            begin
              tick := TickCount-tick;

              EssaieSetPortWindowPlateau;
              PrepareTexteStatePourHeure;
              WriteStringAndReelAt('temps '+s,1.0*tick/60,0,10+noLigneAff*10);
              WriteStringAndNumEnSeparantLesMilliersAt('nb = ',NombreKilosNoeudsGeneres,130,10+noLigneAff*10);

              with StatDiagramme[numeroTest] do
                begin
                  if tick < meilleurTemps then
                     begin
                       meilleurTemps := tick;
                       ref := noLigneAff;
                     end;
                  if (NombreKilosNoeudsGeneres < meilleurNbGeneres) then
                    begin
                      meilleurNbGeneres := NombreKilosNoeudsGeneres;
                      deltaNoeudsReference := NombreKilosNoeudsGeneres-nbreNoeudsAlgoNormal;
                    end;
                  valeur := solveResults.outScoreFinale;
                end;


              tempsCumules[noLigneAff] := tempsCumules[noLigneAff]+tick;


             {for i := 0 to nbTablesHashExactes-1 do}
             {for i := 0 to 0 do
                WritelnStringAndReelDansRapport('taux_remplissage['+NumEnString(i)+'] = ',TauxDeRemplissageHashExacte(i,false),5);
              EcritStatistiquesCollisionsHashTableDansRapport;
              }

            end;

          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
          EcritStatistiquesOrdreOptimumDesCasesDansRapport;
          {$ENDC}

          {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
          EcritStatistiquesStatutKnuthDesNoeudsDansRapport;
          {$ENDC}

        end;



      EssaieSetPortWindowPlateau;
      PrepareTexteStatePourHeure;
      WriteNumAt('                                                 ',
                           0,0,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        WriteNumAt('                                                  ',
                           0,0,10+noLigneAff*10);

      WriteStringAndReelAt('cumulé normal = ',1.0*tempsCumules[0]/60,250,10);
      for noLigneAff := noMinLigneAff to noMaxLigneAff do
        begin
          GetStringDeLigneAff(noLigneAff,s);
          WriteNumAt('a = ',noLigneAff,225,10+noLigneAff*10);
          WriteStringAndReelAt('cumulé : '+s,1.0*tempsCumules[noLigneAff]/60,250,
                                    10+noLigneAff*10);
        end;

      AfficheResultats;

     end;
   until (numeroTest = numeroFin) or (interruptionReflexion <> pasdinterruption) or Quitter;

   {if not(Quitter) then
     begin
       AttendFrappeClavier;
     end;}
sortie:

   SetEffetSpecial(false);
   InitValeursStandardAlgoFinale;

   SetEcritToutDansRapportLog(false);
   if (HumCtreHum <> HumCtreHumArrivee) then DoChangeHumCtreHum;
   LanceInterruption(oldInterruption,'AlignerTestsFinales');
   Quitter := false;

end;







END.























