UNIT UnitJeu;


INTERFACE







 USES UnitDefCassio;




{ initialisation de l'unite }
procedure InitUnitJeu;

{ un drapeau interne pour indiquer à Cassio que l'on est en train de rejouer rapidement une partie }
procedure SetEnTrainDeRejouerUnePartie(flag : boolean);
function EnTrainDeRejouerUnePartie : boolean;

{ fonctions pour plaquer une partie et/ou une position }
procedure RejouePartieOthello(s : String255; coupMax : SInt16; positionDepartStandart : boolean; platImpose : plateauOthello; traitImpose : SInt16; var gameNodeLePlusProfondGenere : GameTree; peutDetruireArbreDeJeu : boolean; avecNomsOuvertureDansArbre : boolean);
procedure RejouePartieOthelloFictive(s : String255; coupMax : SInt16; positionDepartStandart : boolean; platImpose : plateauOthello; traitImpose : SInt16; var gameNodeLePlusProfondGenere : GameTree; flags : SInt64);
procedure PlaquerPosition(plat : plateauOthello; trait : SInt16; flags : SInt64);
procedure PlaquerPositionEtPartie(position : PositionEtTraitRec; partieAlphaCompactee : String255; flags : SInt64);
procedure PlaquerPartieLegale(partieAlphaCompactee : String255; flags : SInt64);
function PlaquerPositionEtPartieFictive(initialPosition, moves : String255; nbreCoupsRepris : SInt64) : OSErr;

{ fonctions pour jouer un coup en modifiant la position courante }
function JoueEn(a : SInt16; const position : PositionEtTraitRec; var couplegal : boolean; avecNomOuverture : boolean; prendreMainVariationFromArbre : boolean; fonctionAppelante : String255) : boolean;
function JoueEnFictif(a,couleur : SInt16; JeuCourantFictif : plateauOthello; EmplJouableFictif : plBool; FrontiereCouranteFictive : InfoFront; nbBlancFictif,nbNoirFictif : SInt16; nbreCoupFictif : SInt16; doitAvancerDansArbreDeJeu : boolean; prendreMainVariationFromArbre : boolean; const fonctionAppelante : String255) : OSErr;
procedure DealWithEssai(whichSquare : SInt16; const position : PositionEtTraitRec; const fonctionAppelante : String255);
procedure Jouer(whichSquare : SInt16; const fonctionAppelante : String255);
procedure TraiteCoupImprevu(caseX : SInt64);
procedure DoJouerMeilleurCoupConnuMaintenant;
procedure JoueCoupPartieSelectionnee(nroHilite : SInt64);
procedure JoueCoupMajoritaireStat;
procedure JoueCoupQueMacAttendait;

{ reflexion de Cassio }
procedure ChoixMac(var ChoixX,whichNote,meiDef : SInt64; coulChoix,niveau,nbblanc,nbNoir : SInt64; plat : plateauOthello; var jouable : plBool; var fro : InfoFront; const fonctionAppelante : String255);
procedure PremierCoupMac;
procedure DeuxiemeCoupMac(var x,note : SInt64);
function ReponseInstantanee(var bestDef : SInt64; niveauJeuIntantaneVoulu : SInt16) : SInt64;
function ReponseInstantaneeTore(var bestDef : SInt64) : SInt64;
procedure JeuMac(niveau : SInt64; const fonctionAppelante : String255);
procedure ChoixMacStandard(var ChoixX,note,MeilleurDef : SInt64; coulChoix,niveau : SInt16; const fonctionAppelante : String255);
procedure DoForcerMacAJouerMaintenant;

{ parfois le bon coup est connu par ailleurs }
function GetMeilleurCoupConnuMaintenant : SInt64;
function LaBibliothequeEstCapableDeFournirUnCoup(var the_best_move,the_best_defense : SInt64) : boolean;
function  ConnaitSuiteParfaite(var ChoixX,MeilleurDef : SInt64; autorisationTemporisation : boolean) : boolean;
function ConnaitSuiteParfaiteParArbreDeJeu(var ChoixX,MeilleurDef : SInt64; autorisationTemporisation : boolean) : boolean;

{ ouvertures equilibrees }
procedure GenereOuvertureAleatoireEquilibree(nbDeCoupsDemandes,borneMin,borneMax : SInt16; casesInterdites : SquareSet; var s : PackedThorGame; var ouverturesInterdites : StringSet);
procedure GenerePartieAleatoireDesquilibree(nbDeCoupsDemandes, goodForWhichColor : SInt16; casesInterdites : SquareSet; var s : PackedThorGame; var ouverturesInterdites : StringSet);

{ utilitaires apres avoir joue un coup }
procedure TachesUsuellesPourGameOver;
procedure TachesUsuellesPourAffichageCourant;
procedure TachesUsuellesPourUnPasse;
procedure JoueSonPourGameOver;

{ fonctions internes }
procedure SupprimeDansHeuris(coup : SInt16);
procedure MiseAJourDeLaPartie(s : String255; jeuDepart : plateauOthello; jouableDepart : plBool; frontiereDepart : InfoFront; nbBlancsDepart,nbNoirsDepart : SInt64; traitDepart : SInt16; nbreCoupDepart : SInt16; depuisPositionInitiale : boolean; coupFinal : SInt16; var gameNodeLePlusProfondGenere : GameTree; fonctionAppelante : String255);
procedure UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteintMAJ : SInt16; jeuMAJ : plateauOthello; jouableMAJ : plBool; frontMAJ : InfoFront; nbBlancsMAJ,nbNoirsMAJ : SInt64; traitMAJ,nbreCoupMAJ : SInt16; fonctionAppelante : String255);
function ResynchronisePartieEtCurrentNode(ApresQuelCoup : SInt16) : OSErr;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, fp, Sound, MacWindows, Appearance
{$IFC NOT(USE_PRELINK)}
    , Zebra_to_Cassio, MyQuickDraw, UnitPositionEtTrait
    , UnitBitboardAlphaBeta, UnitListeChaineeCasesVides, UnitSolve, UnitSuperviseur, UnitPotentiels, UnitEvaluation, UnitEvenement, UnitEntreesSortiesGraphe
    , UnitBibl, UnitNotesSurCases, UnitRapportImplementation, UnitCarbonisation, UnitUtilitaires, UnitCurseur, UnitAccesNouveauFormat, UnitFenetres
    , UnitNouvelleEval, Unit_AB_simple, UnitAffichageArbreDeJeu, UnitPropertyList, SNEvents, UnitCourbe, UnitAccesGraphe, UnitGestionDuTemps
    , UnitMilieuDePartie, UnitFinaleFast, UnitSolitaire, UnitBallade, UnitTore, UnitArbreDeJeuCourant, UnitPhasesPartie, UnitPierresDelta
    , UnitServicesDialogs, UnitAffichageReflexion, UnitStrategie, UnitEntreeTranscript, UnitJaponais, UnitTroisiemeDimension, UnitCassioSounds, UnitInterversions
    , UnitRapport, UnitMenus, UnitStatistiques, UnitListe, UnitScannerUtils, MyStrings, UnitAffichagePlateau, UnitLongintScroller
    , UnitNormalisation, UnitPackedThorGame, UnitGameTree, UnitPressePapier, MyMathUtils, UnitScannerOthellistique, UnitRapportUtils, UnitRetrograde
    , UnitOth2, UnitModes, UnitSquareSet, UnitNewGeneral, UnitProperties, UnitSound, UnitServicesMemoire, UnitZoo
    , UnitEngine, UnitStringSet, UnitLiveUndo, UnitTestZoo, UnitBufferedPICT, UnitIconisation, UnitActions ;
{$ELSEC}
    ;
    {$I prelink/Jeu.lk}
{$ENDC}


{END_USE_CLAUSE}









var gEnTrainDeRejouerUnePartie : boolean;
    dernierSonAleatoireVictoireHumaine : SInt64;
    dernierSonAleatoireVictoireOrdi : SInt64;

procedure InitUnitJeu;
var i : SInt64;
begin
  InvalidateAnalyseDeFinale;
  SetDelaiDeRetournementDesPions(10);
  for i := 0 to 60 do
    SetDateEnTickDuCoupNumero(i,0);
  SetEnTrainDeRejouerUnePartie(false);
  dernierSonAleatoireVictoireHumaine := -1000;
  dernierSonAleatoireVictoireOrdi    := -1000;
end;


procedure SetEnTrainDeRejouerUnePartie(flag : boolean);
begin
  gEnTrainDeRejouerUnePartie := flag;
end;


function EnTrainDeRejouerUnePartie : boolean;
begin
  EnTrainDeRejouerUnePartie := gEnTrainDeRejouerUnePartie;
end;



procedure SupprimeDansHeuris(coup : SInt16);
var i,j,longueur,t : SInt16;
begin
  for t := 1 to 64 do
    begin
      i := othellier[t];
      if GetCouleurOfSquareDansJeuCourant(i) = pionVide then
        begin
          longueur := tableHeurisNoir[i,0];
          j := 0;
          repeat
            j := j+1;
          until (tableHeurisNoir[i,j] = coup) or (j >= longueur);
          if (tableHeurisNoir[i,j] = coup) and (j <= longueur) then
            begin
              Moveleft(tableHeurisNoir[i,j+1],tableHeurisNoir[i,j],longueur-j);
             {******** taille de tableHeurisNoir[i,j] = 1 octet *******}
              tableHeurisNoir[i,0] := longueur-1;
            end;
          longueur := tableHeurisBlanc[i,0];
          j := 0;
          repeat
            j := j+1;
          until (tableHeurisBlanc[i,j] = coup) or (j >= longueur);
          if (tableHeurisBlanc[i,j] = coup) and (j <= longueur) then
            begin
              Moveleft(tableHeurisBlanc[i,j+1],tableHeurisBlanc[i,j],longueur-j);
              tableHeurisBlanc[i,0] := longueur-1;
            end;
        end;
    end;
end;


procedure AjustementAutomatiqueDuNiveauDeJeuInstantane;
var s : String255;
    oldScript : SInt64;

  procedure SwitchToRed;
    begin
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontColorDansRapport(RougeCmd);
      ChangeFontFaceDansRapport(bold);
    end;

  procedure SwitchToBlue;
    begin
      GetCurrentScript(oldScript);
      DisableKeyboardScriptSwitch;
      FinRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontColorDansRapport(MarineCmd);
      ChangeFontFaceDansRapport(bold);
    end;

  procedure BackToNormal;
    begin
      EnableKeyboardScriptSwitch;
      SetCurrentScript(oldScript);
      SwitchToRomanScript;
      TextNormalDansRapport;
    end;

begin

  { Ajustement du niveau de jeu instantane suivant le nombre de victoires successives }

  if PartieContreMacDeBoutEnBout and not(CassioEstEnModeSolitaire) and not(HumCtreHum) and not(enTournoi) then
    begin
      if (nbreDePions[couleurMacintosh] <= nbreDePions[-couleurMacintosh])
        then
          begin
            humanWinningStreak := Max(+1,humanWinningStreak+1);
            humanScoreLastLevel := humanScoreLastLevel + 1;
          end
        else
          begin
            humanWinningStreak := Min(-1,humanWinningStreak-1);
            humanScoreLastLevel := humanScoreLastLevel -1;
          end;


      if jeuInstantane and (humanWinningStreak >= 2) and (NiveauJeuInstantane = NiveauChampions) then
        begin

          {affichage du streak au niveau Champion}

          EffaceDernierCaractereDuRapport;
          SwitchToRed;

          s := ParamStr(ReadStringFromRessource(TextesRapportID,32),IntToStr(humanWinningStreak),'','','');
          WritelnDansRapport('   '+s);  {Vous avez gagné ^0 parties d'affilée au niveau Champion.}
          {WritelnDansRapport('');}

          BackToNormal;
        end else

      if avecAjustementAutomatiqueDuNiveau and jeuInstantane then
        if ((humanWinningStreak >= 1) and (NiveauJeuInstantane < NiveauChampions))  then
        begin
          NiveauJeuInstantane := NiveauJeuInstantane + 1;  {ajustement positif}
          humanWinningStreak := 0;
          humanScoreLastLevel := 0;

          EffaceDernierCaractereDuRapport;
          SwitchToRed;

          s := ReadStringFromRessource(TextesRapportID,33);  {OK, voyons si vous serez aussi fort au niveau suivant :-)}
          WritelnDansRapport('   '+s);
          s := ReadStringFromRessource(TextesRapportID,33+NiveauJeuInstantane); {Je passe au niveau Debutant, Amateur, etc.}
          WritelnDansRapport('   '+s);
          {WritelnDansRapport('');}

          BackToNormal;
        end else

      if avecAjustementAutomatiqueDuNiveau and jeuInstantane and (humanScoreLastLevel <= -2) and
         (NiveauJeuInstantane > NiveauDebutants) then
        begin
          NiveauJeuInstantane := NiveauJeuInstantane - 1;  {ajustement negatif}
          humanWinningStreak := 0;
          humanScoreLastLevel := 0;

          EffaceDernierCaractereDuRapport;
          SwitchToBlue;

          s := ReadStringFromRessource(TextesRapportID,33+NiveauJeuInstantane); {Je passe au niveau Debutant, Amateur, etc.}
          WritelnDansRapport('   '+s);
          {WritelnDansRapport('');}

          BackToNormal;
        end;

    end;
end;

procedure TachesUsuellesPourGameOver;
var scoreFinalPourNoir : SInt16;
    prop : Property;
    s : String255;
    papa : GameTree;
begin
  gameOver := true;
  EffacePromptFenetreReflexion;
  DetruitMeilleureSuite;
  EngineNewPosition;
  if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
  if ((nbreDePions[pionNoir]+nbreDePions[pionBlanc]) = 64) or
     (nbreDePions[pionNoir] = nbreDePions[pionBlanc])
    then scoreFinalPourNoir := nbreDePions[pionNoir]-nbreDePions[pionBlanc]
    else if nbreDePions[pionNoir] > nbreDePions[pionBlanc]
           then scoreFinalPourNoir := 64-2*nbreDePions[pionBlanc]
           else scoreFinalPourNoir := 2*nbreDePions[pionNoir]-64;
  MetScorePrevuParFinaleDansCourbe(nbreCoup,61,kFinaleParfaite,scoreFinalPourNoir);
  MetTitreFenetrePlateau;
  if not(Quitter) and CassioEstEnModeSolitaire then EssaieAfficherFelicitation;

  if (scoreFinalPourNoir >= 0)
	  then prop := MakeValeurOthelloProperty(NodeValueProp,pionNoir, +1, scoreFinalPourNoir,0)
	  else prop := MakeValeurOthelloProperty(NodeValueProp,pionBlanc,+1,-scoreFinalPourNoir,0);
  AddScorePropertyToCurrentNodeSansDuplication(prop);
  if (nbreCoup = 60) and (GetCurrentNode^.father <> NIL) then
    begin
      papa := GetCurrentNode^.father;
      AddScorePropertyToGameTreeSansDuplication(prop,papa);
    end;
  DisposePropertyStuff(prop);
  EcritCurrentNodeDansFenetreArbreDeJeu(false,true);

  if not(CurrentNodeHasCommentaire) and
    (nbPartiesActives = 1) and JoueursEtTournoisEnMemoire and
    (windowListeOpen or windowStatOpen) then
    begin
      s := ConstruireChaineReferencesPartieDapresListe(1,false);
      if (s <> '') then
        SetCommentaireCurrentNodeFromString(s);
      EcritCommentairesOfCurrentNode;
      EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
    end;

  InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);

end;

procedure JoueSonPourGameOver;
const AnnonceVictoireHumID = 10001;
      AnnonceVictoireMacID = 10000;
      BugleVictoirMac = 128;
      PouetPouetPouetPouetID = 203;
      TriangleIntersideralID = 204;
      GameOverManID = 1412;
      WhatAreWeGottoDoNowID = 1414;
      ThisIsNothingSeriousID = 1002;
var scoreFinalPourNoir : SInt64;
    sonAleatoire : SInt64;
begin
  if not(CassioEstEnModeSolitaire) then
    if avecSon and avecSonPourGameOver and not(HumCtreHum) and not(CassioEstEnModeAnalyse) and not(enTournoi) then
      if PartieContreMacDeBoutEnBout then
      begin
        if ((nbreDePions[pionNoir]+nbreDePions[pionBlanc]) = 64) or
           (nbreDePions[pionNoir] = nbreDePions[pionBlanc])
          then scoreFinalPourNoir := nbreDePions[pionNoir]-nbreDePions[pionBlanc]
          else if nbreDePions[pionNoir] > nbreDePions[pionBlanc]
                 then scoreFinalPourNoir := 64-2*nbreDePions[pionBlanc]
                 else scoreFinalPourNoir := 2*nbreDePions[pionNoir]-64;
        if ((scoreFinalPourNoir >= 0) and (couleurMacintosh = pionBlanc)) or
           ((scoreFinalPourNoir <= 0) and (couleurMacintosh = pionNoir))
          then
            begin  {victoire de l'humain}
              sonAleatoire := RandomBetween(1,4);
              if (sonAleatoire = dernierSonAleatoireVictoireHumaine) then sonAleatoire := RandomBetween(1,4);
              case sonAleatoire of
                1 : PlaySoundSynchrone(AnnonceVictoireHumID, kVolumeSonDesCoups);
                2 : PlaySoundSynchrone(PouetPouetPouetPouetID, kVolumeSonDesCoups);
                3 : PlaySoundSynchrone(WhatAreWeGottoDoNowID, kVolumeSonDesCoups);
                4 : PlaySoundSynchrone(ThisIsNothingSeriousID, kVolumeSonDesCoups);
              end;
              dernierSonAleatoireVictoireHumaine := sonAleatoire;
            end
          else  {victoire de l'ordinateur}
            begin
              sonAleatoire := RandomBetween(1,4);
              if (sonAleatoire = dernierSonAleatoireVictoireOrdi) then sonAleatoire := RandomBetween(1,4);
              case sonAleatoire of
                1 : PlaySoundSynchrone(AnnonceVictoireMacID, kVolumeSonDesCoups);
                2 : PlaySoundSynchrone(BugleVictoirMac, kVolumeSonDesCoups);
                3 : PlaySoundSynchrone(GameOverManID, kVolumeSonDesCoups);
                4 : PlaySoundSynchrone(TriangleIntersideralID, kVolumeSonDesCoups);
              end;
              dernierSonAleatoireVictoireOrdi := sonAleatoire;
            end;
      end;
end;




procedure TachesUsuellesPourUnPasse;
const SonDePasseID = 131;
begin
  if avecSon {and not(CassioEstEnModeSolitaire)} and not(enTournoi and (phaseDeLaPartie >= phaseFinale)) then
    PlaySoundSynchrone(SonDePasseID, kVolumeSonDesCoups);

  if (jeuInstantane or enModeIOS or (nbExplicationsPasses >= 10000)) and
     (PassesDejaExpliques < nbExplicationsPasses) and
     not(HumCtreHum) and (AQuiDeJouer = couleurMacintosh) and not(enTournoi) then
     begin
       if not(avecSon) and not(enTournoi and (phaseDeLaPartie >= phaseFinale)) then
          PlaySoundSynchrone(SonDePasseID, kVolumeSonDesCoups); {si avecSon on a deja sonné : cf plus haut}
       DialogueVousPassez;
     end;
end;







{ JoueEn pose un pion sur la case a, qui doit etre vide,
   retourne les pions qui doivent l'etre, met a jour les compteurs, etc. ;
   elle affecte le plateau courant; c'est la procedure finale }

function JoueEn(a : SInt16;
                 const position : PositionEtTraitRec;
                 var couplegal : boolean;
                 avecNomOuverture : boolean;
                 prendreMainVariationFromArbre : boolean;
                 fonctionAppelante : String255) : boolean;
var x,dx,i,t : SInt16;
    pionEnnemi,compteur,compteurPrise : SInt16;
    bidon,nouvellevariante : boolean;
    correctionsTemp : boolean;
    nbBlaDummy,nbNoiDummy : SInt64;
    erreurES : OSErr;
    couleurDeCeCoup : SInt64;
    mobilite : SInt64;
    oldCheckDangerousEvents : boolean;
    positionEnEntree : PositionEtTraitRec;
    current : PositionEtTraitRec;
begin

 JoueEn := false;

 //BeginFonctionModifiantNbreCoup('JoueEn');
 SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

 couleurDeCeCoup := AQuiDeJouer;

 positionEnEntree := position;

 if not(EstLaPositionCourante(positionEnEntree)) then
   begin
     WritelnDansRapport('ERROR !! au debut de JoueEn,  not(EstLaPositionCourante(positionEnEntree)) dans JoueEn (1)');
     WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
     WritelnDansRapport('position courante = ');
     current := PositionEtTraitCourant;
     WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
     WritelnDansRapport('position en entree = ');
     WritelnPositionEtTraitDansRapport(positionEnEntree.position,GetTraitOfPosition(positionEnEntree));
   end;

 couplegal := (GetCouleurOfSquareDansJeuCourant(a) = pionVide) and windowPlateauOpen and PeutJouerIci(couleurDeCeCoup,a,JeuCourant);

 if not(couplegal)
  then
    begin
      {for i := 1 to 10 do SysBeep(0);}
      if not(windowPlateauOpen) then OuvreFntrPlateau(false);
    end
  else
    begin
      SetPortByWindow(wPlateauPtr);

      if CassioEstEnModeSolitaire and (AQuiDeJouer = couleurMacintosh) then TemporisationSolitaire;

      if avecSon and avecSonPourPosePion and not(EnVieille3D) and not(enTournoi and (phaseDeLaPartie >= phaseFinale))
        then PlayPosePionSound;

      RetirerZebraBookOption(kAfficherZebraBookBrutDeDecoffrage);
      EffaceAideDebutant(false,true,othellierToutEntier,'JoueEn');
      ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
      EffaceProprietesOfCurrentNode;

      if afficheNumeroCoup then
        if (nbreCoup > 0) then
          begin
            x := DerniereCaseJouee;
            if InRange(x,11,88) then
              EffaceNumeroCoup(x,nbreCoup,GetCurrentNode);
          end;
      nbreCoup := nbreCoup+1;
      DessinePion(a,couleurDeCeCoup);


      if not(EstLaPositionCourante(positionEnEntree)) then
         begin
           WritelnDansRapport('ERROR !! avant d''appeler ChangeCurrentNodeAfterNewMove,  not(EstLaPositionCourante(positionEnEntree)) dans JoueEn (2)');
           WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
           WritelnDansRapport('position courante = ');
           current := PositionEtTraitCourant;
           WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
           WritelnDansRapport('position en entree = ');
           WritelnPositionEtTraitDansRapport(positionEnEntree.position,GetTraitOfPosition(positionEnEntree));
         end;

      erreurES := ChangeCurrentNodeAfterNewMove(a,couleurDeCeCoup,fonctionAppelante + ' JoueEn {1}');
      if (erreurES <> 0) and (ResynchronisePartieEtCurrentNode(nbreCoup-1) = 0)
        then erreurES := ChangeCurrentNodeAfterNewMove(a,couleurDeCeCoup,fonctionAppelante + ' JoueEn {2}');

      if not(LiveUndoEnCours) then
        MarquerCurrentNodeCommeReel(fonctionAppelante + ' JoueEn');

      if afficheNumeroCoup and not(EnVieille3D) then DessineNumeroCoup(a,nbreCoup,-couleurDeCeCoup,GetCurrentNode);

      IndexProchainFilsDansGraphe := -1;
      nouvellevariante := false;
      if (nbreCoup > nroDernierCoupAtteint) or (DerniereCaseJouee <> a) then
        begin
           nouvellevariante := true;
           nroDernierCoupAtteint := nbreCoup;
           if (a <> partie^^[nbreCoup].coupParfait) then
             begin
               partie^^[nbreCoup].coupParfait := a;
               partie^^[nbreCoup].optimal := (nbreCoup >= 60);  { = false sauf pour le dernier coup }
               for i := nbreCoup + 1 to 60 do
                 begin
                   partie^^[nbreCoup].coupParfait := 0;
                   partie^^[i].optimal := false;
                 end;
             end;
           InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
        end;
      if nroDernierCoupAtteint <= nbreCoup then MyDisableItem(PartieMenu,ForwardCmd);
      partie^^[nbreCoup+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
      partie^^[nbreCoup+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
      partie^^[nbreCoup].tickDuCoup := TickCount;
      SetNiemeCoup(nbreCoup,a);
      partie^^[nbreCoup].trait := couleurDeCeCoup;
      partie^^[nbreCoup].nbRetourne := 0;
      if (nbreCoup = 1) then SetPremierCoupParDefaut(a);

       compteurPrise := 0;
       pionEnnemi := -couleurDeCeCoup;
       nbreDePions[couleurDeCeCoup] := nbreDePions[couleurDeCeCoup]+1;
       for t := dirPriseDeb[a] to dirPriseFin[a] do
          begin
             dx := dirPrise[t];
             compteur := 0;
             x := a+dx;
             while GetCouleurOfSquareDansJeuCourant(x) = pionEnnemi do
                begin
                   inc(compteur);
                   x := x+dx;
                end;
             if (GetCouleurOfSquareDansJeuCourant(x) = couleurDeCeCoup) and (compteur <> 0) then
                begin
                   nbreDePions[couleurDeCeCoup] := nbreDePions[couleurDeCeCoup]+compteur;
                   nbreDePions[pionEnnemi] := nbreDePions[pionEnnemi]-compteur;
                   x := a;
                   for i := 1 to compteur do
                     begin
                      compteurPrise := compteurPrise+1;
                      x := x+dx;
                      if avecSon and avecSonPourRetournePion and not(EnVieille3D) and (compteurPrise = 1) and not(enTournoi and (phaseDeLaPartie >= phaseFinale))
                        then PlayRetournementDePionSound;
                      TemporisationRetournementDesPions;
                      DessinePion(x,couleurDeCeCoup);
                      partie^^[nbreCoup].nbRetourne := partie^^[nbreCoup].nbRetourne + 1;
                      partie^^[nbreCoup].retournes[partie^^[nbreCoup].nbRetourne] := x;
                     end;
                end;
          end;

      if not(EstLaPositionCourante(positionEnEntree)) then
        begin
          WritelnDansRapport('ERROR !! avant de retourner les pions,  not(EstLaPositionCourante(positionEnEntree)) dans JoueEn (3)');
          WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
          WritelnDansRapport('position courante = ');
          current := PositionEtTraitCourant;
          WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
          WritelnDansRapport('position en entree = ');
          WritelnPositionEtTraitDansRapport(positionEnEntree.position,GetTraitOfPosition(positionEnEntree));
        end;


      // mettre à jour les infos de frontiere, etc
      nbBlaDummy := 0;
      nbNoiDummy := 0;
      current := PositionEtTraitCourant;
      bidon := ModifPlat(a,couleurDeCeCoup,current.position,emplJouable,nbBlaDummy,nbNoiDummy,frontiereCourante);

      // Retourner vraiment les pions
      bidon := UpdateJeuCourant(a);


      if EnVieille3D then Dessine3D(JeuCourant,avecSon);
      if afficheNumeroCoup and EnVieille3D then DessineNumeroCoup(a,nbreCoup,-GetCouleurOfSquareDansJeuCourant(a),GetCurrentNode);
      if avecNomOuverture and not(CassioEstEnModeSolitaire)
        then CoupJoueDansRapport(nbreCoup,a);

      if afficheInfosApprentissage then EcritLesInfosDApprentissage;
      AfficheScore;
      if EnModeEntreeTranscript then
        begin
          FlushWindow(wPlateauPtr);
          SetTranscriptChercheDesCorrections(prendreMainVariationFromArbre,correctionsTemp);
          EntrerPartieDansCurrentTranscript(nbreCoup);
          SetTranscriptChercheDesCorrections(correctionsTemp,bidon);
        end;

      {la}
      SupprimeDansHeuris(a);
      gDoitJouerMeilleureReponse := false;
      FixeMarqueSurMenuMode(nbreCoup);

	    CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);

      FlushWindow(wPlateauPtr);

	    if nouvellevariante then
        begin
          InvalidateEvaluationPourCourbe(nbreCoup,60);

          if not(PeutCopierEndgameScoreFromGameTreeDansCourbe(GetCurrentNode,nbreCoup,[kFinaleParfaite,kFinaleWLD])) then
            EssaieMettreEvaluationDeMilieuDansCourbe(a,couleurDeCeCoup,nbreCoup ,JeuCourant,
                                                          nbreDePions[pionBlanc],nbreDePions[pionNoir],emplJouable,frontiereCourante);

	        SetNbrePionsPerduParVariation(nbreCoup+1,0);
	      end;


      TraceSegmentCourbe(nbreCoup,kCourbeColoree,fonctionAppelante + ' JoueEn');

      DessineSliderFenetreCourbe;

      AddRandomDeltaStoneToCurrentNode;


      if enModeIOS then
        GenereInfosIOSDansPressePapier(nbreCoup - 1,couleurDeCeCoup,a,tickPourCalculTempsIOS);
      tickPourCalculTempsIOS := TickCount;

      SetCassioMustCheckDangerousEvents(false, NIL);

      if nouvellevariante and prendreMainVariationFromArbre
        then UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteint,JeuCourant,emplJouable,frontiereCourante,
                                                   nbreDePions[pionBlanc],nbreDePions[pionNoir],0,nbreCoup,fonctionAppelante + ' JoueEn');

      SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

      LanceDemandeAffichageZebraBook(fonctionAppelante + ' JoueEn');
      AfficheProprietesOfCurrentNode(false,othellierToutEntier,fonctionAppelante + ' JoueEn');
      if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);

      FlushWindow(wPlateauPtr);

      SetDateEnTickDuCoupNumero(nbreCoup,TickCount);

      EngineNewPosition;

    end;  {coup legal}
  InvalidateAnalyseDeFinaleSiNecessaire(kNormal);

  //EndFonctionModifiantNbreCoup('JoueEn');
  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

  JoueEn := couplegal;
end;


{ fait la meme chose que JoueEn, mais n'affiche pas les mises à jour }
function JoueEnFictif(a,couleur : SInt16;
                      JeuCourantFictif : plateauOthello;
                      EmplJouableFictif : plBool;
                      FrontiereCouranteFictive : InfoFront;
                      nbBlancFictif,nbNoirFictif : SInt16;
                      nbreCoupFictif : SInt16;
                      doitAvancerDansArbreDeJeu : boolean;
                      prendreMainVariationFromArbre : boolean;
                      const fonctionAppelante : String255) : OSErr;
var x,dx,i,t : SInt16;
    pionEnnemi,compteur,compteurPrise : SInt16;
    bidon,nouvellevariante : boolean;
    nbBlaDummy,nbNoiDummy : SInt64;
    erreurES : OSErr;
    nbreDePionsFictif : array[pionNoir..pionBlanc] of SInt16;
    result : OSErr;
    doitEssayerNotesMilieuDePartie : boolean;
    oldCheckDangerousEvents : boolean;
begin
  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  nbreDePionsFictif[pionNoir] := nbNoirFictif;
  nbreDePionsFictif[pionBlanc] := nbBlancFictif;
  nbreCoupFictif := nbreCoupFictif+1;

  result := NoErr;
  if doitAvancerDansArbreDeJeu then
    begin
      erreurES := ChangeCurrentNodeAfterNewMove(a,couleur,fonctionAppelante + ' JoueCoupFictif {1}');

      result := erreurES;

      if erreurES <> NoErr then
        begin
          WriteNumDansRapport('ErreurES = ',ErreurES);
          WritelnDansRapport('  dans JoueEnFictif {1}, fonction appelante = '+fonctionAppelante);
          WritelnDansRapport('  JeuCourantFictif : ');
          WritelnPositionEtTraitDansRapport(JeuCourantFictif,couleur);
        end;

      if (erreurES <> NoErr) then
        begin
          erreurES := ResynchronisePartieEtCurrentNode(nbreCoupFictif-1);
          if erreurES = NoErr
            then
              begin
                erreurES := ChangeCurrentNodeAfterNewMove(a,couleur,fonctionAppelante + ' JoueCoupFictif {2}');
                if erreurES <> NoErr
                  then
                    begin
                      WritelnDansRapport('Pas de resynchronisation par JoueCoupFictif {2} !');
                      WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
                    end
                  else
                    begin
                      WritelnDansRapport('J''ai reussi a me resynchroniser temporairement dans JoueCoupFictif {2}');
                      WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
                    end;
              end
            else
              begin
                WritelnNumDansRapport('Ca a l''air grave, parce que, dans JoueCoupFictif {2}, ResynchronisePartieEtCurrentNode = ',erreurES);
                WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
              end;
        end;
      MarquerCurrentNodeCommeReel('JoueEnFictif');
      {WritelnDansRapport('JoueEnFictif : fonctionAppelante = '+fonctionAppelante);}
    end;

  nouvellevariante := false;
  if (nbreCoupFictif > nroDernierCoupAtteint) or (GetNiemeCoupPartieCourante(nbreCoupFictif) <> a) then
    begin
       nouvellevariante := true;
       nroDernierCoupAtteint := nbreCoupFictif;
       if (a <> partie^^[nbreCoupFictif].coupParfait) then
          begin
            partie^^[nbreCoupFictif].coupParfait := a;
            partie^^[nbreCoupFictif].optimal := (nbreCoupFictif >= 60);
            for i := nbreCoupFictif + 1 to 60 do
              begin
                partie^^[nbreCoupFictif].coupParfait := 0;
                partie^^[i].optimal := false;
              end;
          end;
       InvalidateNombrePartiesActivesDansLeCache(nbreCoupFictif);
    end;
  partie^^[nbreCoupFictif+1].tempsUtilise.tempsNoir := 60*tempsDesJoueurs[pionNoir].minimum+tempsDesJoueurs[pionNoir].sec;
  partie^^[nbreCoupFictif+1].tempsUtilise.tempsBlanc := 60*tempsDesJoueurs[pionBlanc].minimum+tempsDesJoueurs[pionBlanc].sec;
  partie^^[nbreCoupFictif].tickDuCoup := TickCount;
  SetNiemeCoup(nbreCoupFictif,a);
  partie^^[nbreCoupFictif].trait := couleur;
  partie^^[nbreCoupFictif].nbRetourne := 0;
  if (nbreCoupFictif = 1) then SetPremierCoupParDefaut(a);

   compteurPrise := 0;
   pionEnnemi := -couleur;
   nbreDePionsFictif[couleur] := nbreDePionsFictif[couleur]+1;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
      begin
         dx := dirPrise[t];
         compteur := 0;
         x := a+dx;
         while JeuCourantFictif[x] = pionEnnemi do
            begin
               inc(compteur);
               x := x+dx;
            end;
         if (JeuCourantFictif[x] = couleur) and (compteur <> 0) then
            begin
               nbreDePionsFictif[couleur] := nbreDePionsFictif[couleur]+compteur;
               nbreDePionsFictif[pionEnnemi] := nbreDePionsFictif[pionEnnemi]-compteur;
               for i := 1 to compteur do
                 begin
                  compteurPrise := compteurPrise+1;
                  x := x-dx;
                  partie^^[nbreCoupFictif].nbRetourne := partie^^[nbreCoupFictif].nbRetourne + 1;
                  partie^^[nbreCoupFictif].retournes[partie^^[nbreCoupFictif].nbRetourne] := x;
                 end;
            end;
      end;


  nbBlaDummy := 0;
  nbNoiDummy := 0;
  bidon := ModifPlat(a,couleur,JeuCourantFictif,EmplJouableFictif,nbBlaDummy,nbNoiDummy,FrontiereCouranteFictive);

  if EnModeEntreeTranscript then EntrerPartieDansCurrentTranscript(nbreCoupFictif);
  if nouvellevariante then
    begin

      InvalidateEvaluationPourCourbe(nbreCoupFictif,60);

      doitEssayerNotesMilieuDePartie := true;
      if doitAvancerDansArbreDeJeu then
        doitEssayerNotesMilieuDePartie := doitEssayerNotesMilieuDePartie and not(PeutCopierEndgameScoreFromGameTreeDansCourbe(GetCurrentNode,nbreCoupFictif,[kFinaleParfaite,kFinaleWLD]));


      if doitEssayerNotesMilieuDePartie then
        EssaieMettreEvaluationDeMilieuDansCourbe(a,couleur,nbreCoupFictif ,JeuCourantFictif,
                                                 nbreDePionsFictif[pionBlanc],nbreDePionsFictif[pionNoir],EmplJouableFictif,FrontiereCouranteFictive);
	    SetNbrePionsPerduParVariation(nbreCoupFictif+1,0);
	  end;
  if nouvellevariante and doitAvancerDansArbreDeJeu and prendreMainVariationFromArbre then
    UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteint,JeuCourantFictif,EmplJouableFictif,FrontiereCouranteFictive,
                                               nbreDePionsFictif[pionBlanc],nbreDePionsFictif[pionNoir],0,nbreCoupFictif,fonctionAppelante + ' JoueEnFictif');

  SetDateEnTickDuCoupNumero(nbreCoupFictif,TickCount);

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);

  JoueEnFictif := result;
end;







procedure GenereOuvertureAleatoireEquilibree(nbDeCoupsDemandes,borneMin,borneMax : SInt16; casesInterdites : SquareSet; var s : PackedThorGame; var ouverturesInterdites : StringSet);
var coup,i,nbEssai,ecart : SInt16;
    nbBlancsTest,nbNoirsTest : SInt64;
    EvalTest : SInt16;
    meilleurePartie,partieTestee : PackedThorGame;
    meilleure255 : String255;
    platTest : PositionEtTraitRec;
    jouableTest : plBool;
    FrontTest : InfoFront;
    bestDef : SInt64;
    oldInterruption : SInt16;
    legal : boolean;
    autreCoupQuatreDiag : boolean;
    data : SInt64;
begin

  FILL_PACKED_GAME_WITH_ZEROS(s);
  FILL_PACKED_GAME_WITH_ZEROS(meilleurePartie);

  nbEssai := 0;
  ecart := 30000;
  Superviseur(nbDeCoupsDemandes);
  RandomizeTimer;

  repeat
    inc(nbEssai);

    FILL_PACKED_GAME_WITH_ZEROS(partieTestee);

    platTest := PositionEtTraitInitiauxStandard;
    for i := 1 to nbDeCoupsDemandes do
      begin
        coup := CoupAleatoire(GetTraitOfPosition(platTest),platTest.position,casesInterdites);

        if (coup >= 11) and (coup <= 88) then
          begin
            ADD_MOVE_TO_PACKED_GAME(partieTestee, coup);
            legal := UpdatePositionEtTrait(platTest,coup);
          end;
      end;

    CarteJouable(platTest.position,jouableTest);
    CarteFrontiere(platTest.position,frontTest);
    nbBlancsTest := NbPionsDeCetteCouleurDansPosition(pionBlanc,platTest.position);
    nbNoirsTest  := NbPionsDeCetteCouleurDansPosition(pionNoir,platTest.position);

    oldInterruption := GetCurrentInterruption;
    EnleveCetteInterruption(oldInterruption);

    evalTest := -AB_simple(platTest.position,jouableTest,bestDef,GetTraitOfPosition(platTest),1,
              -30000,30000,nbBlancsTest,nbNoirsTest,frontTest,false);

    LanceInterruption(oldInterruption,'GenereOuvertureAleatoireEquilibree');

    {
    evalTest := -Evaluation(platTest,traitTest,nbBlancsTest,nbNoirsTest,
	                    jouableTest,frontTest,false,-30000,30000,nbEvalRecursives);
    }

    {
    EssaieSetPortWindowPlateau;
    WriteNumAt('nbEssai = ',nbEssai,10,10);
    Ecritpositionat(platTest,10,20);
    WriteNumAt('evalTest = ',evalTest,10,140);
    WriteNumAt('traitTest = ',traitTest,10,150);
    WriteNumAt('nbBlancsTest = ',nbBlancsTest,100,150);
    WriteNumAt('nbNoirsTest = ',nbNoirsTest,200,150);
    SysBeep(0);
    AttendFrappeClavier;}

    if (evalTest >= borneMin) and (evalTest <= borneMax) then
      begin

        TraductionThorEnAlphanumerique(partieTestee, meilleure255);
        Normalisation(meilleure255, autreCoupQuatreDiag, false);
        TraductionAlphanumeriqueEnThor(meilleure255, partieTestee);

        if not(MemberOfStringSet(meilleure255, data, ouverturesInterdites)) then
          begin
            ecart := 0;
            meilleurePartie := partieTestee;
            AddStringToSet(meilleure255, 0, ouverturesInterdites);
          end;
      end;
    if (evalTest < borneMin) and (Abs(borneMin-evalTest) < ecart) then
      begin
        ecart := Abs(borneMin-evalTest);
        meilleurePartie := partieTestee;
      end;
    if (evalTest > borneMax) and (Abs(borneMax-evalTest) < ecart) then
      begin
        ecart := Abs(borneMax-evalTest);
        meilleurePartie := partieTestee;
      end;

  until (nbEssai > 4000) or (ecart = 0);

  {WritelnNumDansRapport('dans GenereOuvertureAleatoireEquilibree, nbEssai = ',nbEssai);}


  TraductionThorEnAlphanumerique(meilleurePartie, meilleure255);
  Normalisation(meilleure255, autreCoupQuatreDiag, false);
  TraductionAlphanumeriqueEnThor(meilleure255, meilleurePartie);

  s := meilleurePartie;
end;


procedure GenerePartieAleatoireDesquilibree(nbDeCoupsDemandes, goodForWhichColor : SInt16; casesInterdites : SquareSet; var s : PackedThorGame; var ouverturesInterdites : StringSet);
var coup,i,nbEssai,ecart : SInt16;
    nbBlancsTest,nbNoirsTest : SInt64;
    EvalTest : SInt16;
    meilleurePartie,partieTestee : PackedThorGame;
    meilleure255 : String255;
    platTest : PositionEtTraitRec;
    jouableTest : plBool;
    FrontTest : InfoFront;
    bestDef : SInt64;
    oldInterruption : SInt16;
    legal : boolean;
    autreCoupQuatreDiag : boolean;
    data : SInt64;
    trait : SInt64;
begin

  FILL_PACKED_GAME_WITH_ZEROS(s);
  FILL_PACKED_GAME_WITH_ZEROS(meilleurePartie);

  nbEssai := 0;
  ecart := 30000;
  Superviseur(nbDeCoupsDemandes);
  RandomizeTimer;

  repeat
    inc(nbEssai);

    FILL_PACKED_GAME_WITH_ZEROS(partieTestee);

    platTest := PositionEtTraitInitiauxStandard;

    for i := 1 to 12 do
      begin
        coup := CoupAleatoire(GetTraitOfPosition(platTest),platTest.position,casesInterdites);

        if (coup >= 11) and (coup <= 88) then
          begin
            ADD_MOVE_TO_PACKED_GAME(partieTestee, coup);
            legal := UpdatePositionEtTrait(platTest,coup);
          end;
      end;

    for i := 13 to nbDeCoupsDemandes do
      begin

        trait := GetTraitOfPosition(platTest);

        if (trait = goodForWhichColor)
          then coup := CoupAleatoireDonnantPeuDeMobilite(trait,platTest.position,casesInterdites)
          else coup := CoupAleatoireDonnantPleinDeMobilite(trait,platTest.position,casesInterdites);

        if (coup >= 11) and (coup <= 88) then
          begin
            ADD_MOVE_TO_PACKED_GAME(partieTestee, coup);
            legal := UpdatePositionEtTrait(platTest,coup);
          end;
      end;

    CarteJouable(platTest.position,jouableTest);
    CarteFrontiere(platTest.position,frontTest);
    nbBlancsTest := NbPionsDeCetteCouleurDansPosition(pionBlanc,platTest.position);
    nbNoirsTest  := NbPionsDeCetteCouleurDansPosition(pionNoir,platTest.position);

    oldInterruption := GetCurrentInterruption;
    EnleveCetteInterruption(oldInterruption);

    evalTest := -AB_simple(platTest.position,jouableTest,bestDef,GetTraitOfPosition(platTest),1,
              -30000,30000,nbBlancsTest,nbNoirsTest,frontTest,false);

    LanceInterruption(oldInterruption,'GenereOuvertureAleatoireEquilibree');

    {
    evalTest := -Evaluation(platTest,traitTest,nbBlancsTest,nbNoirsTest,
	                    jouableTest,frontTest,false,-30000,30000,nbEvalRecursives);
    }

    {
    EssaieSetPortWindowPlateau;
    WriteNumAt('nbEssai = ',nbEssai,10,10);
    Ecritpositionat(platTest,10,20);
    WriteNumAt('evalTest = ',evalTest,10,140);
    WriteNumAt('traitTest = ',traitTest,10,150);
    WriteNumAt('nbBlancsTest = ',nbBlancsTest,100,150);
    WriteNumAt('nbNoirsTest = ',nbNoirsTest,200,150);
    SysBeep(0);
    AttendFrappeClavier;}

    TraductionThorEnAlphanumerique(partieTestee, meilleure255);
    Normalisation(meilleure255, autreCoupQuatreDiag, false);
    TraductionAlphanumeriqueEnThor(meilleure255, partieTestee);

    if not(MemberOfStringSet(meilleure255, data, ouverturesInterdites)) then
      begin
        ecart := 0;
        meilleurePartie := partieTestee;
        AddStringToSet(meilleure255, 0, ouverturesInterdites);
      end;

  until (nbEssai > 4000) or (ecart = 0);

  {WritelnNumDansRapport('dans GenereOuvertureAleatoireEquilibree, nbEssai = ',nbEssai);}

  TraductionThorEnAlphanumerique(meilleurePartie, meilleure255);
  Normalisation(meilleure255, autreCoupQuatreDiag, false);
  TraductionAlphanumeriqueEnThor(meilleure255, meilleurePartie);

  s := meilleurePartie;
end;


procedure DeuxiemeCoupMac(var x,note : SInt64);
var a,b,i,j : SInt16;
    test : boolean;
begin
  for a := 3 to 7 do
  begin
   case a of
    3 : b := 4;
    4 : b := 3;
    5 : b := 6;
    6 : b := 5;
   end;
   if GetCouleurOfSquareDansJeuCourant(a+10*b) = pionNoir then
     begin
       i := a;    {Coup du joueur adverse}
       j := b;
     end;
  end;
  test := odd(TickCount);
  if test then
    case i of
      3 : begin a := 3; b := 3; end;
      4 : begin a := 3; b := 5; end;
      5 : begin a := 6; b := 4; end;
      6 : begin a := 6; b := 6; end;
    end
    else
    case i of
      3 : begin a := 5; b := 3; end;
      4 : begin a := 3; b := 3; end;
      5 : begin a := 6; b := 6; end;
      6 : begin a := 4; b := 6; end;
    end;
  x := a+10*b;
  note := 0;
end;


function ReponseInstantanee(var bestDef : SInt64; NiveauJeuIntantaneVoulu : SInt16) : SInt64;
var platInst : plateauOthello;
    JouablInst : plBool;
    frontInst : InfoFront;
    VincenzChoice : VincenzMoveRec;
    coupPossible : plBool;
    mobiliteCourante : SInt64;
    nbNoirInst,nbBlancInst : SInt64;
    bestSuite : SInt64;
    yaffiche,iCourant,i : SInt64;
    eval,maxCourant,infini : SInt64;
    bidonBool : boolean;
    nbEvalsRecursives : SInt64;
    meilleurChoix : SInt64;
    noteCourante : SInt64;
    oldInterruption : SInt16;
    tempoDiscretisation : boolean;
    current : PositionEtTraitRec;
    chrono : SInt64;
begin

  chrono := TickCount;

  meilleurChoix := 0;
  bestDef := 0;

  if (AQuiDeJouer = couleurMacintosh) and not(HumCtreHum) then
    begin
      EcritJeReflechis(couleurMacintosh);
    end;
  frontiereCourante.occupationTactique := 0;
  SetPotentielsOptimums(PositionEtTraitCourant);
  CarteMove(AQuiDeJouer,JeuCourant,coupPossible,mobiliteCourante);


  if (nbreCoup = 1) and not(positionFeerique) and (RandomBetween(1,100) <= 66) then
    begin
      DeuxiemeCoupMac(iCourant,eval);
      if coupPossible[iCourant] then
        begin
          meilleurChoix := iCourant;
          ReponseInstantanee := iCourant;
          exit;
        end;
    end;

  tempoDiscretisation := discretisationEvaluationEstOK;
  discretisationEvaluationEstOK := false;

  if (mobiliteCourante = 1)
    then
      begin
        for iCourant := 11 to 88 do
          if coupPossible[iCourant] then
            begin
              meilleurChoix := iCourant;
              ReponseInstantanee := iCourant;
            end;
      end
    else
  if (NiveauJeuIntantaneVoulu = NiveauClubs)
    then
      begin
        VincenzChoice := ChoixDeVincenz(PositionEtTraitCourant,1,true);
        meilleurChoix := VincenzChoice.bestMove;
        ReponseInstantanee := VincenzChoice.bestMove;
        bestDef := VincenzChoice.bestDefense;
      end
    else
      begin
        yaffiche := 50;
        infini := noteMax;
        Superviseur(nbreCoup);
        Calcul_position_centre(JeuCourant);
        maxCourant := -30000;

        for i := 1 to 64 do
				  begin
				    iCourant := othellier[i];
            if coupPossible[iCourant] then
              begin
                platInst := JeuCourant;
                JouablInst := emplJouable;
                frontInst := frontiereCourante;
                nbNoirInst := nbreDePions[pionNoir];
                nbBlancInst := nbreDePions[pionBlanc];
                bidonBool := ModifPlat(iCourant,AQuiDeJouer,platInst,JouablInst,
                                      nbBlancInst,nbNoirInst,frontInst);

                case NiveauJeuIntantaneVoulu of
                  NiveauDebutants :
                      begin
  	                    eval := -EvaluationMaximisation(platInst,-AQuiDeJouer,nbBlancInst,nbNoirInst);
  	                    if estUneCaseX(iCourant)
  	                      then eval := eval+Random16() mod 300
  	                      else eval := eval+Random16() mod 500;
  	                  end;
                  NiveauAmateurs :
                      begin
  	                    eval := -EvaluationDesBords(platInst,-AQuiDeJouer,frontInst);
  	                    if estUneCaseX(iCourant)
  	                      then eval := eval - 500 - (Abs(Random16()) mod 500)
  	                      else eval := eval+Random16() mod 100;
  	                  end;
  	              NiveauForts :
  	                  begin
  	                    current := PositionEtTraitCourant;
  	                    eval := Trunc(105.0*EffectueMoveEtCalculePotentielVincenz(current,iCourant,1));
  	                    VincenzChoice := ChoixDeVincenz(MakePositionEtTrait(platInst,-AQuiDeJouer),1,false);
  	                    eval := eval+Trunc(-10*VincenzChoice.sommePotentiels);
  	                    eval := eval-(Evaluation(platInst,-AQuiDeJouer,nbBlancInst,nbNoirInst,JouablInst,frontInst,true,-30000,30000,nbEvalsRecursives) div 3);
  	                    eval := eval+Random16() mod 40;
  	                    if eval >  6400 then eval := 6400;
  	                    if eval < -6400 then eval := -6400;
  	                    bestSuite := VincenzChoice.bestMove;
  	                  end;
                  NiveauExperts :
                      begin
  	                    eval := -Evaluation(platInst,-AQuiDeJouer,nbBlancInst,nbNoirInst,
  	                                                JouablInst,frontInst,true,-30000,-maxCourant,nbEvalsRecursives);
  	                    if estUneCaseX(iCourant)
  	                      then eval := eval - 500 + Random16() mod 100
  	                      else eval := eval + Random16() mod 100;
  	                  end;
  	              NiveauGrandMaitres :
                      begin
                        oldInterruption := GetCurrentInterruption;
                        EnleveCetteInterruption(oldInterruption);
                        eval := -AB_simple(platInst,JouablInst,bestSuite,-AQuiDeJouer,0,
                                           -30000,-maxCourant,nbBlancInst,nbNoirInst,frontInst,false);
                        eval := eval + Random16() mod 25;
                        LanceInterruption(oldInterruption,'ReponseInstantanee (1)');
                      end;
                  NiveauChampions :
                      begin
                        oldInterruption := GetCurrentInterruption;
                        EnleveCetteInterruption(oldInterruption);
                        eval := -AB_simple(platInst,JouablInst,bestSuite,-AQuiDeJouer,2,
                                           -30000,-maxCourant,nbBlancInst,nbNoirInst,frontInst,false);


                        if (interruptionReflexion <> pasdinterruption) then eval := -32000;

                        LanceInterruption(oldInterruption,'ReponseInstantanee (2)');

                        {WritelnPositionDansRapport(platInst);
                        WritelnNumDansRapport(CoupEnStringEnMajuscules(iCourant) + ' => ',eval);}
                      end;
                  NiveauIntersideral :
                      begin
                        oldInterruption := GetCurrentInterruption;
                        EnleveCetteInterruption(oldInterruption);



                        if ((64 - (nbNoirInst + nbBlancInst)) < 17) and ListeChaineeDesCasesVidesEstDisponible and
                            PeutFaireFinaleBitboardCettePosition(platInst,-AQuiDeJouer,-30000,-maxCourant,nbNoirInst,nbBlancInst,noteCourante)
                          then
                            begin
                              eval := -noteCourante;
                              {WritelnNumDansRapport('note bitboard de ' + CoupEnStringEnMajuscules(iCourant) + ' => ',noteCourante);}
                            end
                          else
                            begin
                              eval := -AB_simple(platInst,JouablInst,bestSuite,-AQuiDeJouer,4,
                                                 -30000,-maxCourant,nbBlancInst,nbNoirInst,frontInst,false);
                            end;


                        if (interruptionReflexion <> pasdinterruption) then eval := -32000;

                        LanceInterruption(oldInterruption,'ReponseInstantanee (2)');

                        {WritelnPositionDansRapport(platInst);
                        WritelnNumDansRapport(CoupEnStringEnMajuscules(iCourant) + ' => ',eval);}
                      end;
                end; {case}

                if eval > maxCourant then
                  begin
                    bestDef := bestSuite;
                    maxCourant := eval;
                    meilleurChoix := iCourant;
                    ReponseInstantanee := iCourant;
                  end;
              end;
          end;
      end;

  {WritelnNumDansRapport('Resultat de ReponseInstantanee : ' + CoupEnStringEnMajuscules(meilleurChoix) + ' => ',maxCourant);}
  {WritelnNumDansRapport('Temps de ReponseInstantanee : ' + CoupEnStringEnMajuscules(meilleurChoix) + ' => ',TickCount - chrono);}

  discretisationEvaluationEstOK := tempoDiscretisation;
end;


function ReponseInstantaneeTore(var bestDef : SInt64) : SInt64;
var platInst : plateauOthello;
    nbNoirInst,nbBlancInst : SInt64;
    platEssai : plateauOthello;
    nbNrEssai,nbBlcEssai : SInt64;
    coupPossible : plBool;
    yaffiche : SInt16;
    mob : SInt64;
    i,iCourant,icourantEssai,meilDefEssai : SInt16;
    eval,maxCourant,noteCourante,maxPourBestDef,infini : SInt16;
    bidonBool : boolean;
begin
  if (AQuiDeJouer = couleurMacintosh) and not(HumCtreHum)
    then EcritJeReflechis(couleurMacintosh);
  frontiereCourante.occupationTactique := 0;
  CarteMoveTore(AQuiDeJouer,JeuCourant,coupPossible,mob);
  if mob = 1
    then
      begin
        for iCourant := 11 to 88 do
          if coupPossible[iCourant] then ReponseInstantaneeTore := iCourant;
      end
    else
      begin
        yaffiche := 50;
        infini := noteMax;
        Superviseur(nbreCoup);
        Calcul_position_centre(JeuCourant);
        maxCourant := -noteMax;
        for iCourant := 11 to 88 do
          if coupPossible[iCourant] then
            begin
              platInst := JeuCourant;
              nbNoirInst := nbreDePions[pionNoir];
              nbBlancInst := nbreDePions[pionBlanc];
              bidonBool := ModifPlatTore(iCourant,AQuiDeJouer,platInst,nbBlancInst,nbNoirInst);

              {eval := -Evaluation(platInst,-AQuiDeJouer,nbBlancInst,nbNoirInst,JouablInst,frontInst,true,-30000,30000,nbEvalRecursives);}

              maxPourBestDef := -noteMax;
              platEssai := platInst;
              nbBlcEssai := nbBlancInst;
              nbNrEssai := nbNoirInst;
              i := 0;
              repeat
                i := i+1;
                icourantEssai := othellier[i];
                if platEssai[icourantEssai] = pionVide then
                 begin
                   if ModifPlatTore(icourantEssai,-AQuiDeJouer,platEssai,
                                 nbBlcEssai,nbNrEssai)
                     then begin
                       if ((AQuiDeJouer = pionBlanc) and (nbBlcEssai < 2)) or
                          ((AQuiDeJouer = pionNoir) and (nbNrEssai < 2)) then
                            noteCourante := infini-1000
                       else
                          noteCourante := -EvaluationTore({platEssai,}AQuiDeJouer,nbBlcEssai,nbNrEssai);
                       if (noteCourante > maxPourBestDef) then
                         begin
                           maxPourBestDef := noteCourante;
                           meilDefEssai := icourantEssai;
                         end;
                       platEssai := platInst;
                       nbBlcEssai := nbBlancInst;
                       nbNrEssai := nbNoirInst;
                     end;
                  end;
               until (i >= 64) or (maxPourBestDef > -maxCourant);
               Eval := -maxPourBestDef;
               if estUneCaseX(iCourant) then eval := eval-200;



              if eval > maxCourant then
                begin
                  bestDef := meilDefEssai;
                  maxCourant := eval;
                  ReponseInstantaneeTore := iCourant;
                end;
            end;
      end;
end;


procedure ChoixMac(var ChoixX,whichNote,meiDef : SInt64; coulChoix,niveau,nbblanc,nbNoir : SInt64; plat : plateauOthello; var jouable : plBool; var fro : InfoFront; const fonctionAppelante : String255);
var prof,typeFinaleDemande : SInt16;
    numberCoup,nbremeilleur,causerejet : SInt64;
    scoreaatteindre : SInt16;
    s255 : String255;
    ToujoursRamenerLaSuite,annonceDansRapport : boolean;
    resultatCalculMilieu : MoveRecord;
    bidbool : boolean;
    searchParam : MakeEndgameSearchParamRec;
    timeTaken : double;

    procedure CheckParameters(s : String255);
    begin
      WritelnDansRapport(s);
      WritelnNumDansRapport('  CoulChoix = ',CoulChoix);
      WritelnNumDansRapport('  niveau = ',niveau);
      WritelnNumDansRapport('  nbblanc = ',nbblanc);
      WritelnNumDansRapport('  nbNoir = ',nbNoir);
      WritelnDansRapport('  plat et CoulChoix = ');
      WritelnPositionEtTraitDansRapport(plat,CoulChoix);
      WritelnDansRapport('');
    end;

begin

  if not((CoulChoix = pionNoir) or (CoulChoix = pionBlanc)) or
     ((nbblanc < 0) or (nbblanc > 64)) or
     ((nbNoir < 0) or (nbNoir > 64)) or
     ((niveau < -1) or (niveau > 64)) then
    begin
      CheckParameters('ASSERT dans ChoixMac !');
      AlerteSimple('ASSERT dans ChoixMac!! Merci de prévenir Stéphane');
      exit;
    end;

  if debuggage.gestionDuTemps then
    CheckParameters('Entree dans ChoixMac , fonction appelante = ' + fonctionAppelante);

  ChoixX := 0;
  whichNote := -noteMax;
  meiDef := 0;

  {CheckParameters('après ChoixX := 0');}

  numberCoup := nbblanc+nbNoir-4;
  dernierTick := TickCount-tempsDesJoueurs[CoulChoix].tick;
  LanceChrono;
  tempsPrevu := 10;
  tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh);
  if not(RefleSurTempsJoueur) and (AQuiDeJouer = couleurMacintosh) and not(HumCtreHum) then
    begin
      EcritJeReflechis(coulChoix);
    end;
  ReinitilaliseInfosAffichageReflexion;
  EffaceReflexion(HumCtreHum);
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      valeurCoup := -noteMax;
      coul       := pionVide;
      prof       := 0;
    end;

 {CheckParameters('apres ReinitilaliseInfosAffichageReflexion');}


 {
 if phaseDeLaPartie <= phaseMilieu then
      whichNote := -penalitePourTraitAff+Evaluation(plat,CoulChoix,nbBlanc,nbNoir,jouable,fro,true,-30000,30000,nbEvalRecursives);
 GOTOXY(5,24);
 Write('note de ce plat :',whichNote,'    ');
 }


 phaseDeLaPartie := CalculePhasePartie(numberCoup);
 Superviseur(numberCoup);
 if not(calculPrepHeurisFait) then
   Initialise_table_heuristique(JeuCourant,false);
 {afficheplat(fro.nbvide);}

 {CheckParameters('apres Initialise_table_heuristique');}

 if (nbreCoup = 0)
  then
    begin
      CoupAuHazard(CoulChoix,plat,jouable,ChoixX,whichNote);
      {CheckParameters('apres CoupAuHazard');}
    end
  else
   begin
    {if (enTournoi and (numberCoup < 7) and not(avecBibl))
     then CoupAuHazard(CoulChoix,plat,jouable,ChoixX,whichNote)
     else}
     begin
       {CheckParameters('avant if (numberCoup = 1) and not(positionFeerique)');}
       if (numberCoup = 1) and not(positionFeerique) and not(CassioEstEnModeAnalyse)
        then
          begin
            if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
              then TraiteEvenements
              else TraiteNullEvent(theEvent);
            if (interruptionReflexion = pasdinterruption) then
              DeuxiemeCoupMac(choixX,whichNote);
          end
        else
          begin
           IF (phaseDeLaPartie >= phaseFinale) then
            begin
             prof := 60-numberCoup;
             typeFinaleDemande := ReflGagnant;
             if prof <= (60-finDePartie) then
               if CassioEstEnModeAnalyse and not(CassioEstEnModeSolitaire)
                 then typeFinaleDemande := ReflGagnantExhaustif
                 else typeFinaleDemande := ReflGagnant;
             if prof <= (60-finDePartieOptimale) then
               if CassioEstEnModeAnalyse and not(CassioEstEnModeSolitaire)
                 then typeFinaleDemande := ReflParfaitExhaustif
                 else typeFinaleDemande := ReflParfait;

             if afficheMeilleureSuite then DetruitMeilleureSuite;
             if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
             if finaleEnModeSolitaire and (typeFinaleDemande = ReflParfait)
               then
                 begin
                   scoreaatteindre := 64;
                   if CassioEstEnModeSolitaire then
                     if positionFeerique and (DerniereCaseJouee = coupInconnu) then
                       begin
                         s255 := CommentaireSolitaire^^;
                         if ((Pos(ReadStringFromRessource(TextesSolitairesID,19),s255) > 0) and (CoulChoix = pionNoir)) or
                            ((Pos(ReadStringFromRessource(TextesSolitairesID,20),s255) > 0) and (CoulChoix = pionBlanc)) then
                              begin
                                (* reduire la fenetre pour le premier coup du solitaire  *)
                                if Pos(ReadStringFromRessource(TextesSolitairesID,5),s255) > 0  {'gagne'}
                                then scoreaatteindre := +1
                                else scoreaatteindre := 0 ;
                              end;
                       end;
                    bidbool := EstUnSolitaire(choixX,meiDef,CoulChoix,prof,nbblanc,nbnoir,plat,jouable,
                                            fro,whichNote,nbremeilleur,true,causerejet,kJeuNormal,scoreaatteindre);
                 end
               else
                 begin
                   ToujoursRamenerLaSuite := false;
                   annonceDansRapport := true;

                   with searchParam do
                      begin
                         inTypeCalculFinale                   := typeFinaleDemande;
                         inCouleurFinale                      := CoulChoix;
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
                         inPositionPourFinale                 := plat;
                         inMessageHandleFinale                := NIL;
                         inCommentairesDansRapportFinale      := annonceDansRapport;
                         inMettreLeScoreDansLaCourbeFinale    := true;
                         inMettreLaSuiteDansLaPartie          := true;
                         inDoitAbsolumentRamenerLaSuiteFinale := ToujoursRamenerLaSuite;
                         inDoitAbsolumentRamenerUnScoreFinale := false;
                         ViderSearchResults(outResult);
                      end;

                   bidbool := MakeEndgameSearch(searchParam);


                   choixX          := searchParam.outResult.outBestMoveFinale;
                   meiDef          := searchParam.outResult.outBestDefenseFinale;
                   whichNote       := searchParam.outResult.outScoreFinale;
                   timeTaken       := searchParam.outResult.outTimeTakenFinale;

                 end;
            end
          else
            begin
             {CheckParameters('avant Calcule_Valeurs_Tactiques');}
              Calcule_Valeurs_Tactiques(plat,true);
             {CheckParameters('avant CalculeMeilleurCoupMilieuDePartie');}
              resultatCalculMilieu := CalculeMeilleurCoupMilieuDePartie(plat,jouable,fro,CoulChoix,niveau,nbblanc,nbnoir);
             {CheckParameters('apres CalculeMeilleurCoupMilieuDePartie');
              WritelnNumDansRapport('resultatCalculMilieu.theDefense = ',resultatCalculMilieu.theDefense);}
              choixX      := resultatCalculMilieu.x;
              whichNote   := resultatCalculMilieu.note;
              meiDef      := resultatCalculMilieu.theDefense;
            end;
         end;
      end;
   end;

 {CheckParameters('avant ChoixMac(1)');}
  if (interruptionReflexion <> pasdinterruption) and not(vaDepasserTemps) then   {si interruption brutale...}
    TraiteInterruptionBrutale(choixX,meiDef,'ChoixMac(1)');
 {CheckParameters('avant HasGotEvent');}
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
    then TraiteEvenements
    else TraiteNullEvent(theEvent);
 {CheckParameters('avant ChoixMac(2)');}
  if (interruptionReflexion <> pasdinterruption) and not(vaDepasserTemps) then    {si interruption brutale...}
    TraiteInterruptionBrutale(choixX,meiDef,'ChoixMac(2)');
 {CheckParameters('avant DerniereHeure');}
  DerniereHeure(CoulChoix);
 {CheckParameters('sortie de ChoixMac');}
 if debuggage.gestionDuTemps then
    WritelnDansRapport('Sortie de ChoixMac , fonction appelante = ' + fonctionAppelante);

end;

function ConnaitSuiteParfaite(var ChoixX,MeilleurDef : SInt64; autorisationTemporisation : boolean) : boolean;
var i,coup,aux : SInt16;
    ok : boolean;
    temp : boolean;
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

  temp := debuggage.calculFinaleOptimaleParOptimalite;
  {debuggage.calculFinaleOptimaleParOptimalite := (partie^^[50].coupParfait = 27) or (partie^^[51].coupParfait = 27); }

  if debuggage.calculFinaleOptimaleParOptimalite and (nbreCoup > 30) then
   begin
     WritelnDansRapport('');
     WritelnDansRapport('Entrée dans ConnaitSuiteParfaite :');
     WritelnNumDansRapport('nbreCoup = ',nbreCoup);
     for i := 31 to 60 do
       begin
         WriteNumDansRapport('coup ',i);
         aux := partie^^[i].coupParfait;
         WriteStringDansRapport(' : '+CoupEnStringEnMajuscules(aux));
         if partie^^[i].optimal
           then WritelnStringDansRapport(' optimal  ')
           else WritelnStringDansRapport(' non optimal ');
       end;
   end;

  debuggage.calculFinaleOptimaleParOptimalite := temp;

  ConnaitSuiteParfaite := false;
  ChoixX := 44;
  MeilleurDef := 44;
  ok := not(gameOver) and (nbreCoup < 60);
  // ok := ok and (interruptionReflexion = pasdinterruption);
  ok := ok and (not(CassioEstEnModeSolitaire) or (AQuiDeJouer = -couleurMacintosh));
  if ok then for i := 1 to nbreCoup do
                 ok := (ok and (GetNiemeCoupPartieCourante(i) = partie^^[i].coupParfait));
  if ok then ok := (ok and partie^^[nbreCoup+1].optimal);
  if ok then
    begin
      coup := partie^^[nbreCoup+1].coupParfait;
      aux := partie^^[nbreCoup+2].coupParfait;
      if (coup < 11) or (coup > 88) then ok := false;
      if ok and possibleMove[coup]
         then
           begin
             ConnaitSuiteParfaite := true;
             ChoixX := coup;
             if partie^^[nbreCoup+2].optimal then
               if (aux >= 11) and (aux <= 88) then
                 MeilleurDef := aux;
             if CassioEstEnModeSolitaire and (AQuiDeJouer = couleurMacintosh) and autorisationTemporisation
               then TemporisationSolitaire;
           end
         else
           ok := false;
    end;

 if ok and ((interruptionReflexion = pasdinterruption) or vaDepasserTemps)
   then EcritMeilleureSuiteParOptimalite;


end;


function ConnaitSuiteParfaiteParArbreDeJeu(var ChoixX,MeilleurDef : SInt64; autorisationTemporisation : boolean) : boolean;
var coup,aux : SInt16;
    ok : boolean;
    vMin,vMax : SInt64;
    listeDesCoups : PropertyList;
begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);


  ConnaitSuiteParfaiteParArbreDeJeu := false;


  ChoixX := 44;
  MeilleurDef := 44;
  ok := not(gameOver) and (nbreCoup < 60);

  (*
  if gameOver
    then WritelnDansRapport('gameOver = true')
    else WritelnDansRapport('gameOver = false');
  *)


  ok := ok and (not(CassioEstEnModeSolitaire) or (AQuiDeJouer = -couleurMacintosh));

  if ok then
    begin
      listeDesCoups := NewPropertyList;
      ok := PeutCalculerFinaleParfaiteParArbreDeJeuCourant(listeDesCoups,vMin,vMax);

      (*
      if ok
          then WritelnDansRapport('ok = true')
          else WritelnDansRapport('ok = false');
      *)

      if ok and (listeDesCoups <> NIL) and (vMin = vMax) then
        begin

          coup := GetOthelloSquareOfProperty(listeDesCoups^.head);

          ok := (coup >= 11) and (coup <= 88) and possibleMove[coup];

          if ok then
            begin
              ConnaitSuiteParfaiteParArbreDeJeu := true;
              ChoixX := coup;
            end;

          if ok and (listeDesCoups^.tail <> NIL) then
            begin
              aux := GetOthelloSquareOfProperty(listeDesCoups^.tail^.head);
              if (aux >= 11) and (aux <= 88) then
                 MeilleurDef := aux;
            end;

          (*
          if ok then
            begin
              WritelnStringAndCoupDansRapport('dans ConnaitSuiteParfaiteParArbreDeJeu, ChoixX = ',ChoixX);
              WritelnStringAndCoupDansRapport('     et MeilleurDef = ',MeilleurDef);
            end;
          *)

          if ok and ((interruptionReflexion = pasdinterruption) or vaDepasserTemps)
            then EcritMeilleureSuiteParArbreDeJeu(listeDesCoups);


          if ok and CassioEstEnModeSolitaire and (AQuiDeJouer = couleurMacintosh) and autorisationTemporisation
            then TemporisationSolitaire;
        end;

      DisposePropertyList(listeDesCoups);
    end;


end;



procedure ChoixMacStandard(var choixX,note,meilleurDef : SInt64; coulChoix,niveau : SInt16; const fonctionAppelante : String255);
const
  kGrapheDonneCoupIllegalID = 23;
  kBibliothequeDonneCoupIllegalID = 28;
  kConnaitSuiteParfaiteDonneCoupIllegalID = 29;
  kReponseInstantaneeDonneCoupIllegalID = 30;
  kChoixMacDonneCoupIllegalID = 31;
var nbBlanc,nbNoir : SInt64;
    doitRechercherEnProf : boolean;
    doitChercherDansBibl : boolean;
    the_best_move,the_best_defense : SInt64;
    current : PositionEtTraitRec;

  procedure ValiderLegaliteDuCoupCalcule(coupPropose,defenseProposee : SInt16; messageErreurID : SInt16);
  begin
    if debuggage.gestionDuTemps then
      begin
        WriteNumDansRapport('   …dans ValiderLegaliteDuCoupCalcule, coupPropose = '+CoupEnString(coupPropose,true)+'<->',coupPropose);
        WritelnNumDansRapport('   …dans ValiderLegaliteDuCoupCalcule, defenseProposee = '+CoupEnString(defenseProposee,true)+'<->',defenseProposee);
      end;
    if (coupPropose >= 11) and (coupPropose <= 88) and possibleMove[coupPropose]
      then
        begin
          choixX := coupPropose;
          if (defenseProposee >= 11) and (defenseProposee <= 88)
            then meilleurDef := defenseProposee
            else meilleurDef := 44;
        end
      else
        begin
          if (interruptionReflexion = pasdinterruption) then
            begin
              {'LE GRAPHE D''APPRENTISSAGE PROPOSE UN COUP ILLEGAL !!!!' ou la bibliotheque, reponseInstantanee, etc.}
              WritelnDansRapport(ReadStringFromRessource(TextesRapportID,messageErreurID));
              AlerteSimple(ReadStringFromRessource(TextesRapportID,messageErreurID));
            end;
          choixX := 44;
          meilleurDef := 44;
          doitRechercherEnProf := true;
        end;
  end;

begin
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
  doitRechercherEnProf := true;

  if debuggage.gestionDuTemps then
    begin
      current := PositionEtTraitCourant;
      WritelnDansRapport('Entrée dans ChoixMacStandard (fonction appelante = '+fonctionAppelante+') avec la position courante suivante :');
      WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
      WritelnNumDansRapport('interruptionReflexion = ',interruptionReflexion);
      WritelnDansRapport('');
    end;

  if doitRechercherEnProf and UtiliseGrapheApprentissage and not(positionFeerique) and (nbreCoup >= 5) and
     not(CassioEstEnModeAnalyse and not(HumCtreHum)) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de PeutChoisirDansGrapheApprentissage par ChoixMacStandard');

      doitRechercherEnProf := not(PeutChoisirDansGrapheApprentissage(the_best_move,the_best_defense));
      if not(doitRechercherEnProf) then
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kGrapheDonneCoupIllegalID);
    end;

  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après PeutChoisirDansGrapheApprentissage, doitRechercherEnProf = ',doitRechercherEnProf);
      WritelnNumDansRapport(', interruptionReflexion = ',interruptionReflexion);
    end;


  if doitRechercherEnProf  then
    begin
      doitChercherDansBibl := true;

      {quatre chance sur cinq d'utiliser la bibliotheque plutot que les variations du milieu}
		  if gEntrainementOuvertures.CassioVarieSesCoups and (gEntrainementOuvertures.modeVariation = kVarierEnUtilisantMilieu) and
		     avecBibl and (nbreCoup <= LongMaxBibl) and (CoulChoix = couleurMacintosh)
		    then doitChercherDansBibl := doitChercherDansBibl and PChancesSurN(4,5);

		  if doitChercherDansBibl then
		    begin
          doitRechercherEnProf := not(LaBibliothequeEstCapableDeFournirUnCoup(the_best_move,the_best_defense));
          if not(doitRechercherEnProf) then
    		    ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kBibliothequeDonneCoupIllegalID);
    		end;
		end;

  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après LaBibliothequeEstCapableDeFournirUnCoup, doitRechercherEnProf = ',doitRechercherEnProf);
      WritelnNumDansRapport(', interruptionReflexion = ',interruptionReflexion);
    end;

  if doitRechercherEnProf and (phaseDeLaPartie >= phaseFinale) and not(CassioEstEnModeAnalyse) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ConnaitSuiteParfaite par ChoixMacStandard');

      if ((interruptionReflexion = pasdinterruption) or vaDepasserTemps)
        then doitRechercherEnProf := not(ConnaitSuiteParfaite(the_best_move,the_best_defense,true))
        else doitRechercherEnProf := true;

      if not(doitRechercherEnProf) then
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kConnaitSuiteParfaiteDonneCoupIllegalID);
    end;

  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ConnaitSuiteParfaite, doitRechercherEnProf = ',doitRechercherEnProf);
      WritelnNumDansRapport(', interruptionReflexion = ',interruptionReflexion);
    end;

  if doitRechercherEnProf and jeuInstantane and (phaseDeLaPartie <= phaseMilieu) and (AQuiDeJouer = couleurMacintosh) then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ReponseInstantanee par ChoixMacStandard');

      the_best_move := ReponseInstantanee(the_best_defense,NiveauJeuInstantane);
      if (the_best_move >= 0) and (the_best_move <= 99) and possibleMove[the_best_move] then
          doitRechercherEnProf := false;
      if not(doitRechercherEnProf) then
        ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kReponseInstantaneeDonneCoupIllegalID);
    end;


  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ReponseInstantanee, doitRechercherEnProf = ',doitRechercherEnProf);
      WritelnNumDansRapport(', interruptionReflexion = ',interruptionReflexion);
    end;

  if doitRechercherEnProf then
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de ChoixMac par ChoixMacStandard');

      nbBlanc := nbreDePions[pionBlanc];
      nbNoir := nbreDePions[pionNoir];
      ChoixMac(the_best_move,note,the_best_defense,CoulChoix,niveau,nbblanc,nbNoir,JeuCourant,emplJouable,frontiereCourante,'ChoixMacStandard');
      ValiderLegaliteDuCoupCalcule(the_best_move,the_best_defense,kChoixMacDonneCoupIllegalID);
    end;


  if debuggage.gestionDuTemps then
    begin
      WriteStringAndBoolDansRapport('   …après ChoixMac, doitRechercherEnProf = ',doitRechercherEnProf);
      WritelnNumDansRapport(', interruptionReflexion = ',interruptionReflexion);
    end;

  if (interruptionReflexion <> pasdinterruption) and not(vaDepasserTemps) then   {si interruption brutale...}
    begin
      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de TraiteInterruptionBrutale(choixX,meilleurDef) à la fin de ChoixMacStandard');
      TraiteInterruptionBrutale(choixX,meilleurDef,'ChoixMacStandard');
    end;

  if debuggage.gestionDuTemps then
    begin
      current := PositionEtTraitCourant;
      WritelnDansRapport('Sortie de ChoixMacStandard (fonction appelante = '+fonctionAppelante+') avec la position courante suivante :');
      WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
    end;
end;


function LaBibliothequeEstCapableDeFournirUnCoup(var the_best_move,the_best_defense : SInt64) : boolean;
var doitChercherDansBibl : boolean;
    nbReponsesEnBibliotheque : SInt64;
    resultatBiblOK : boolean;
begin
  resultatBiblOK := false;

  with gEntrainementOuvertures do
    begin
      if positionFeerique or (CassioEstEnModeAnalyse and not(HumCtreHum) {and (CoulChoix = couleurMacintosh)})
        then doitChercherDansBibl := false
        else doitChercherDansBibl := true;


			if doitChercherDansBibl and (phaseDeLaPartie <= phaseMilieu) and (nbreCoup <= LongMaxBibl) then
		    begin
		      if debuggage.gestionDuTemps then WritelnDansRapport('   …appel de PeutChoisirEnBibl par LaBibliothequeEstCapableDeFournirUnCoup');

		      if avecBibl or (jeuInstantane and (NiveauJeuInstantane <= NiveauChampions))
            then
              begin
                if CassioVarieSesCoups or
		               (jeuInstantane and (NiveauJeuInstantane <= NiveauForts))  {on sort parfois de la bibl expres}
		              then resultatBiblOK := PeutChoisirEnBibl(the_best_move,the_best_defense,true,nbReponsesEnBibliotheque)
		              else resultatBiblOK := PeutChoisirEnBibl(the_best_move,the_best_defense,false,nbReponsesEnBibliotheque);

		            if resultatBiblOK and (nbReponsesEnBibliotheque = 1) and CassioVarieSesCoups and PChancesSurN(1,5)
                  then resultatBiblOK := false;

                if debuggage.gestionDuTemps then
                  begin
                    WritelnStringAndBoolDansRapport('resultatBiblOK = ',resultatBiblOK);
                    WritelnNumDansRapport('nbReponsesEnBibliotheque = ',nbReponsesEnBibliotheque);
                    WritelnStringAndCoupDansRapport('the_best_move = ',the_best_move);
                    WritelnStringAndCoupDansRapport('the_best_defense = ',the_best_defense);
                  end;

              end
            else
              begin
                resultatBiblOK := false;
                nbReponsesEnBibliotheque := 0;
              end;

		      if resultatBiblOK then
		        begin
		          if (the_best_move >= 11) and (the_best_move <= 88) and possibleMove[the_best_move]
                then
                  begin
                    if not((the_best_defense >= 11) and (the_best_defense <= 88))
                      then the_best_defense := 44;
                  end
                else
                  begin
                    resultatBiblOK := false;
                    the_best_move := 44;
                    the_best_defense := 44;
                  end;
		        end;
		    end;
    end;

  LaBibliothequeEstCapableDeFournirUnCoup := resultatBiblOK;

end;


procedure DealWithEssai(whichSquare : SInt16; const position : PositionEtTraitRec; const fonctionAppelante : String255);
var mobilite,tempoAquiDeJouer : SInt64;
    oldport : grafPtr;
    coupEstLegal : boolean;
    current : PositionEtTraitRec;
    s : String255;
    positionEnEntree : PositionEtTraitRec;
begin

  positionEnEntree := position;

  if not(EstLaPositionCourante(positionEnEntree)) then
   begin
     WritelnDansRapport('ERROR !! au debut de DealWithEssai,  not(EstLaPositionCourante(positionEnEntree)) dans DealWithEssai (1)');
     WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
     WritelnDansRapport('position courante = ');
     current := PositionEtTraitCourant;
     WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
     WritelnDansRapport('position en entree = ');
     WritelnPositionEtTraitDansRapport(positionEnEntree.position,GetTraitOfPosition(positionEnEntree));
   end;
 {
 if not(HumCtreHum) and (interruptionReflexion <> pasdinterruption) and not(vaDepasserTemps)
  then
    begin
      (** on ne fait rien.                           **)
      (** note: enlever les commentaires ci-dessus    **)
      (** pour être très rigoureux; mais on rate     **)
      (** alors parfois des clics.                    **)
    end
  else
  }

 {WritelnDansRapport('Dans DealWithEssai, fonctionAppelante = '+fonctionAppelante);}

    begin
      if (whichSquare < 11) or (whichSquare > 88) then
        begin
          AlerteSimple('ASSERT : (whichSquare < 11) or (whichSquare > 88) dans DealWithEssai!! Merci de prévenir Stéphane');
          WritelnDansRapport('ASSERT : (whichSquare < 11) or (whichSquare > 88) dans DealWithEssai !!');
          WritelnNumDansRapport('  pour infos : whichSquare = ',whichSquare);
          WritelnDansRapport('  fonction appelante = '+fonctionAppelante);
          SysBeep(0);
          exit;
        end;

      if not(possibleMove[whichSquare]) then
        begin
          if debuggage.general then
            if windowPlateauOpen then
            begin
              GetPort(oldport);
              SetPortByWindow(wPlateauPtr);
              case AQuiDeJouer of
                 pionBlanc  :  s := 'Probleme : Blanc';
                 pionNoir   :  s := 'Probleme : Noir';
              end;
              s := s + ' veut jouer en ' + chr(64+whichSquare mod 10);
              WriteNumAt(s,whichSquare div 10,10,100);
              SetPort(oldport);
            end;
        end
      else
        begin
         if not(HumCtreHum) and (AQuiDeJouer = couleurMacintosh) and CassioEstEnModeSolitaire and UnJoueurVientDePasser
           then TemporisationArnaqueFinale;

         {$UNUSED tempoAquiDeJouer}
         (** hack pour changer la couleur du curseur AVANT de retourner les pions… **)
         SetInverserLesCouleursDuCurseur(true);
         AjusteCurseur;


         if not(EstLaPositionCourante(positionEnEntree)) then
           begin
             WritelnDansRapport('ERROR !! avant d''appeler JoueEn,  not(EstLaPositionCourante(positionEnEntree)) dans DealWithEssai (2)');
             WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
             WritelnDansRapport('position courante = ');
             current := PositionEtTraitCourant;
             WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
             WritelnDansRapport('position en entree = ');
             WritelnPositionEtTraitDansRapport(positionEnEntree.position,GetTraitOfPosition(positionEnEntree));
           end;

         SetInverserLesCouleursDuCurseur(false);

         if JoueEn(whichSquare,positionEnEntree,coupEstLegal,not(enTournoi),true,fonctionAppelante + ' DealWithEssai') then
           begin

             AjusteCurseur;
             CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
             EssayeAfficherMeilleureSuiteParArbreDeJeu;

             if UnJoueurVientDePasser and (mobilite > 0)
               then TachesUsuellesPourUnPasse;

             if (mobilite = 0) then
               begin
                 TachesUsuellesPourGameOver;
                 VideMeilleureSuiteInfos;
                 AnnonceScoreFinalDansRapport;
                 JoueSonPourGameOver;
                 AjustementAutomatiqueDuNiveauDeJeuInstantane;
                 FixeMarqueSurMenuMode(nbreCoup);
               end;

             EssayerEnvoyerPositionCouranteAuZooPourLeTester;

            end;
         AjusteCurseur;
         if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
           then LanceCalculsRapidesPourBaseOuNouvelleDemande(nroDernierCoupAtteint > nbreCoup,true);
         if (HumCtreHum or (nbreCoup <= 0) or (AQuiDeJouer <> couleurMacintosh)) and not(enTournoi) then
	         begin
	           MyDisableItem(PartieMenu,ForceCmd);
	           AfficheDemandeCoup;
	         end;

	       if avecInterversions and (nbreCoup >= 1) and (nbreCoup <= numeroCoupMaxPourRechercheIntervesionDansArbre)
	         then
	           begin
	             current := PositionEtTraitCourant;
	             GererInterversionDeCeNoeud(GetCurrentNode,current);
	           end;
      end;
  end;
end;


procedure Jouer(whichSquare : SInt16; const fonctionAppelante : String255);
var caseCritiqueTurbulence,a : SInt64;
    {Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst : SInt64;}
begin

 if (whichSquare < 11) or (whichSquare > 88) then
   begin
     AlerteSimple('ASSERT : (whichSquare < 11) or (whichSquare > 88) dans Jouer !! Merci de prévenir Stéphane');
     WritelnDansRapport('ASSERT : (whichSquare < 11) or (whichSquare > 88) dans Jeu !');
     WritelnNumDansRapport('  pour infos : whichSquare = ',whichSquare);
     WritelnDansRapport('  fonction appelante = '+fonctionAppelante);
     SysBeep(0);
     exit;
   end;

 {WritelnDansRapport('Dans Jouer, fonction appelante = '+fonctionAppelante);}

 { Ces lignes (if...) font des problemes de recurrences non voulues dans TraiteCoupImprevu :-( }
 if (AQuiDeJouer = couleurMacintosh) and not(HumCtreHum) then
   begin
      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
		    then TraiteEvenements
		    else TraiteNullEvent(theEvent);

     if AQuiDeJouer = couleurMacintosh then
       begin
         DealWithEssai(whichSquare,PositionEtTraitCourant,fonctionAppelante + ' Jouer(1)');
       end;
   end
  else
   begin
     DealWithEssai(whichSquare,PositionEtTraitCourant,fonctionAppelante + ' Jouer(2)');
   end;


 if debuggage.elementsStrategiques then
   if EstTurbulent(JeuCourant,AQuiDeJouer,nbreDePions[pionNoir],nbreDePions[pionBlanc],frontiereCourante,caseCritiqueTurbulence)
     then WriteStringAt('position turbulente : il faut jouer '+CoupEnStringEnMajuscules(caseCritiqueTurbulence)+' !',500,100)
     else WriteStringAt('position non turbulente                  ',500,100);


 if debuggage.elementsStrategiques then
   if not(PasDeBordDeCinqAttaque(AQuiDeJouer,frontiereCourante,JeuCourant))
     then WriteNumAt('bord de cinq attaqué ',0,100,110)
     else WriteNumAt('                        ',0,100,110);

 if debuggage.elementsStrategiques then
   begin
     a := nbBordDeCinqTransformablesPourBlanc(JeuCourant,frontiereCourante);
     if a <> 0
       then WriteNumAt('nb bord de cinq transformable pour Blanc',a,100,110)
       else WriteNumAt('                                                 ',0,100,110);
   end;

if debuggage.elementsStrategiques then
   begin
     a := TrousDeTroisNoirsHorribles(JeuCourant);
     WriteNumAt('trous noirs ',a,100,110);
     a := TrousDeTroisBlancsHorribles(JeuCourant);
     WriteNumAt('trous blancs ',a,100,120);
   end;

 if debuggage.elementsStrategiques then
   begin
     a := LibertesNoiresSurCasesA(JeuCourant,frontiereCourante);
     WriteNumAt('lib noires sur case A ',a,100,110);
     a := LibertesBlanchesSurCasesA(JeuCourant,frontiereCourante);
     WriteNumAt('lib blanches sur case A  ',a,100,120);
   end;


 if debuggage.elementsStrategiques then
   begin
     a := ArnaqueSurBordDeCinqNoir(JeuCourant,frontiereCourante);
     WriteNumAt('arnaque noire sur bord de 5 ',a,100,110);
     a := ArnaqueSurBordDeCinqBlanc(JeuCourant,frontiereCourante);
     WriteNumAt('arnaque blanche sur bord de 5 ',a,100,120);
   end;

 (*
 with frontiereCourante do
   begin
     WritelnNumDansRapport('bord nord nouveau =',AdressePattern[kAdresseBordNord]);
     WritelnNumDansRapport('bord sud nouveau =',AdressePattern[kAdresseBordSud]);
     WritelnNumDansRapport('bord ouest nouveau =',AdressePattern[kAdresseBordOuest]);
     WritelnNumDansRapport('bord est nouveau =',AdressePattern[kAdresseBordEst]);
     WritelnDansRapport('');
   end;
 *)

 (*
 with frontiereCourante do
   begin
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinA1],'kAdresseBlocCoinA1');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinA1]),'kAdresseBlocCoinA1 (symetrique)');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinH1],'kAdresseBlocCoinH1');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinH1]),'kAdresseBlocCoinH1 (symetrique)');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinA8],'kAdresseBlocCoinA8');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinA8]),'kAdresseBlocCoinA8 (symetrique)');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(AdressePattern[kAdresseBlocCoinH8],'kAdresseBlocCoinH8');
     WritelnDansRapport('');
     Writeln13SquareCornerAndStringDansRapport(SymmetricalMapping13SquaresCorner(AdressePattern[kAdresseBlocCoinH8]),'kAdresseBlocCoinH8 (symetrique)');
     WritelnDansRapport('');
   end;
 *)

 (*
 CalculeIndexesEdges2X(JeuCourant,frontiereCourante,Edge2XNord,Edge2XSud,Edge2XOuest,Edge2XEst);
 WritelnEdge2XAndStringDansRapport(Edge2XNord,'edge2X nord');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XNord),'edge2X nord (symetrique)');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XOuest,'edge2X ouest');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XOuest),'edge2X ouest (symetrique)');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XEst,'edge2X est');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XEst),'edge2X est (symetrique)');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(Edge2XSud,'edge2X sud');
 WritelnDansRapport('');
 WritelnEdge2XAndStringDansRapport(SymmetricalMappingEdge2X(Edge2XSud),'edge2X sud (symetrique)');
 WritelnDansRapport('');


 with frontiereCourante do
   begin
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleA3F8],6,'kAdresseDiagonaleA3F8');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleA3F8]),6,'kAdresseDiagonaleA3F8 (symetrique)');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleC1H6],6,'kAdresseDiagonaleC1H6');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleC1H6]),6,'kAdresseDiagonaleC1H6 (symetrique)');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleA6F1],6,'kAdresseDiagonaleA6F1');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleA6F1]),6,'kAdresseDiagonaleA6F1 (symetrique)');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(AdressePattern[kAdresseDiagonaleC8H3],6,'kAdresseDiagonaleC8H3');
     WritelnDansRapport('');
     WritelnLinePatternAndStringDansRapport(SymmetricalMapping6SquaresLine(AdressePattern[kAdresseDiagonaleC8H3]),6,'kAdresseDiagonaleC8H3 (symetrique)');
     WritelnDansRapport('');
   end;
   *)

end;


procedure EcritStructureDesCalculsDansJeuMac(const message : String255);
begin {$UNUSED message}
  (* WritelnDansRapport(message); *)
end;


procedure AfficheDebugageEntreeDansJeuMac(const fonctionAppelante : String255; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('entrée dans JeuMac, fonction appelante = '+fonctionAppelante);
      WritelnDansRapport('à l''entrée dans JeuMac : position et trait courant =');
      WritelnPositionEtTraitDansRapport(positionEtTraitDeLAppelReflexionDeMac.position,GetTraitOfPosition(positionEtTraitDeLAppelReflexionDeMac));
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('reponsePrete = ',reponsePrete);
      WritelnStringAndCoupDansRapport('meilleureReponsePrete = ',meilleureReponsePrete);
      WritelnStringAndCoupDansRapport('MeilleurCoupHumPret = ',MeilleurCoupHumPret);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
      WritelnDansRapport('');
    end;
end;


procedure AfficheDebuggageSortieDeJeuMac;
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('sortie de JeuMac :');
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('reponsePrete = ',reponsePrete);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
    end;
end;


function InterruptionReflexionDansJeuMac : boolean;
begin
  if (interruptionReflexion = pasdinterruption)
    then InterruptionReflexionDansJeuMac := false
    else
      begin
        if vaDepasserTemps and (interruptionReflexion = interruptionDepassementTemps)
          then InterruptionReflexionDansJeuMac := false
          else InterruptionReflexionDansJeuMac := true;
      end;
end;


procedure ReflexionInitialeDuMacintoshDansJeuMac(var coupMac : SInt64; niveau : SInt64; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16;
    note : SInt64;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans ReflexionInitialeDuMacintoshDansJeuMac');

  coupMac := 0;

  if (AQuiDeJouer = couleurMacintosh) and not(Quitter) then
	  begin
	    if (meilleureReponsePrete < 11) or (meilleureReponsePrete > 88)
	      then meilleureReponsePrete := 44;

		  reponsePrete := reponsePrete and (GetCouleurOfSquareDansJeuCourant(meilleureReponsePrete) = pionVide) and possibleMove[meilleureReponsePrete];
		  if not(reponsePrete)
		    then
			    begin
			      RefleSurTempsJoueur := false;
			      vaDepasserTemps := false;
			      EnableItemPourCassio(PartieMenu,ForceCmd);
			      oldInterruption := GetCurrentInterruption;
			      EnleveCetteInterruption(oldInterruption);
			      if debuggage.gestionDuTemps then
              begin
                WritelnNumDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (AQuiDeJouer = couleurMacintosh) : oldInterruption = ',oldInterruption);
                WritelnStringDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (AQuiDeJouer = couleurMacintosh) : appel de ChoixMacStandard');
              end;
			      ChoixMacStandard(coupMac,note,meilleurCoupHum,AQuiDeJouer,niveau,'ReflexionInitialeDuMacintoshDansJeuMac');
			      LanceInterruption(oldInterruption,'ReflexionInitialeDuMacintoshDansJeuMac');
			      if debuggage.gestionDuTemps then
              begin
                WritelnStringAndCoupDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (AQuiDeJouer = couleurMacintosh) : après ChoixMacStandard, coupMac = ',coupMac);
                WritelnNumDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (AQuiDeJouer = couleurMacintosh) : après ChoixMacStandard, GetCurrentInterruption = ',GetCurrentInterruption);
                WritelnStringAndBoolDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac (AQuiDeJouer = couleurMacintosh) : après ChoixMacStandard, vaDepasserTemps = ',vaDepasserTemps);
              end;
			    end
		    else
			    begin
			      coupMac := meilleureReponsePrete;
			      meilleurCoupHum := MeilleurCoupHumPret;
			      if CassioEstEnModeSolitaire then TemporisationSolitaire;
			      if debuggage.gestionDuTemps then
              WritelnStringDansRapport('dans ReflexionInitialeDuMacintoshDansJeuMac, j''essaie d''utiliser la reponse prete…');
			    end;

			if not(CassioEstEnModeSolitaire) and (AQuiDeJouer = couleurMacintosh) and (interruptionReflexion = pasdinterruption) and
			   CassioEstEnModeAnalyse and not(HumCtreHum)
			  then
			    begin
			      ActiverSuggestionDeCassio(positionEtTraitDeLAppelReflexionDeMac,coupMac,meilleurCoupHum,'ReflexionInitialeDuMacintoshDansJeuMac');
			    end;
	  end;
	EcritStructureDesCalculsDansJeuMac('sortie de ReflexionInitialeDuMacintoshDansJeuMac');
end;


procedure CheckEventsDansJeuMac(const whereAmI : String255);
begin
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
    then
      begin
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, appel de TraiteEvement pour ' + whereAmI);
        TraiteEvenements;
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, fin de l''appel de TraiteEvement pour ' + whereAmI);
      end
    else
      begin
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, appel de TraiteNullEvent pour ' + whereAmI);
        TraiteNullEvent(theEvent);
        if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('dans JeuMac, fin de l''appel de TraiteNullEvent pour ' + whereAmI);
      end;
end;


procedure AfficheInfosDebugage1DansJeuMac(var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var current : PositionEtTraitRec;
begin
  if debuggage.gestionDuTemps then
    begin
      current := PositionEtTraitCourant;
      WritelnNumDansRapport('dans JeuMac  : avant REPEAT, GetCurrentInterruption = ',GetCurrentInterruption);
      WritelnStringAndBoolDansRapport('dans JeuMac  : avant REPEAT, vaDepasserTemps = ',vaDepasserTemps);
      WritelnDansRapport('dans JeuMac  : avant REPEAT, position et trait courants =');
      WritelnPositionEtTraitDansRapport(current.position,GetTraitOfPosition(current));
    end;

  if debuggage.gestionDuTemps and
     (interruptionReflexion = pasdinterruption) and (AQuiDeJouer = couleurMacintosh) and
     not(EstLaPositionCourante(positionEtTraitDeLAppelReflexionDeMac)) then
    begin
      WritelnDansRapport('AHAH ! positionEtTraitDeLAppelReflexionDeMac <> PositionEtTraitCourant dans AfficheInfosDebugage1DansJeuMac!');
      SysBeep(0);
    end;
end;


procedure AfficheInfosDebugage2DansJeuMac(coupMac,auxCoupHum : SInt64);
begin
  if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('dans AfficheInfosDebugage2DansJeuMac, voici la situation :');
      WritelnStringAndCoupDansRapport('coupMac = ',coupMac);
      WritelnStringAndCoupDansRapport('auxCoupHum = ',auxCoupHum);
      EcritTypeInterruptionDansRapport(interruptionReflexion);
      WritelnStringAndBoolDansRapport('vaDepasserTemps = ',vaDepasserTemps);
      WritelnStringAndBoolDansRapport('RefleSurTempsJoueur = ',RefleSurTempsJoueur);
      WritelnDansRapport('');
    end;
end;


procedure JouerUnCoupDuMacintoshDansJeuMac(var coupMac : SInt64; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec; const fonctionAppelante : String255);
var conditionsCorrectesPourJouerLeCoup : boolean;
    tickPourJouerLeCoup : SInt64;
    dateDuDernierCoup : SInt64;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans JouerUnCoupDuMacintoshDansJeuMac');

  if (TickCount > DateOfLastKeyboardOperation + 15)
    then tickPourJouerLeCoup := -1000                    (* c'est-à-dire que l'on peut le jouer immediatement *)
    else
      { attendre un peu si l'utilisateur vient de taper une touche }
      if NoDelayAfterKeyboardOperation
        then tickPourJouerLeCoup := TickCount + 5
        else tickPourJouerLeCoup := DateOfLastKeyboardOperation + 15;

  { si on est dans un niveau de jeu instantané, il y a un petit delai avant d'afficher le coup }
  if (DoitTemporiserPourRetournerLesPions and (GetDelaiDeRetournementDesPions > 0)) then
    begin
      dateDuDernierCoup := GetDateEnTickDuCoupNumero(nbreCoup);
      if (tickPourJouerLeCoup < dateDuDernierCoup + 30) then
        tickPourJouerLeCoup := dateDuDernierCoup + 30;
    end;

  { on verifie que tout est toujours bon pour jouer le coup }
  conditionsCorrectesPourJouerLeCoup := true;
  while conditionsCorrectesPourJouerLeCoup and (TickCount < tickPourJouerLeCoup) do
    begin

      if HasGotEvent(everyEvent,theEvent,1,NIL) then TraiteEvenements;

      conditionsCorrectesPourJouerLeCoup := conditionsCorrectesPourJouerLeCoup and
                                            (AQuiDeJouer = couleurMacintosh) and
                                            not(InterruptionReflexionDansJeuMac) and
                                            EstLaPositionCourante(positionEtTraitDeLAppelReflexionDeMac) and
                                            not(Quitter);
    end;

  { à la fin du delai, on essaie de jouer le coup }
  if conditionsCorrectesPourJouerLeCoup then Jouer(coupMac,fonctionAppelante);

  EcritStructureDesCalculsDansJeuMac('sortie de JouerUnCoupDuMacintoshDansJeuMac');
end;


procedure EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(var coupMac : SInt64; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');

  if (AQuiDeJouer = couleurMacintosh) then
    begin
      if EstLaPositionCourante(positionEtTraitDeLAppelReflexionDeMac) and
	       not(InterruptionReflexionDansJeuMac)
	      then
			    begin
			      if debuggage.gestionDuTemps then WritelnDansRapport('appel de Jouer('+CoupEnString(coupMac,true)+') par EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');

			      JouerUnCoupDuMacintoshDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');

			      EnleveCetteInterruption(interruptionDepassementTemps);

			      if InterruptionReflexionDansJeuMac then
			        TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
			    end
			  else
			    begin
			      if not(reponsePrete and (phaseDeLaPartie >= phaseFinale)) then
			        begin
					      if debuggage.gestionDuTemps then WritelnDansRapport('J''invalide les calculs precedents dans EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
					      TraiteInterruptionBrutale(coupMac,meilleurCoupHum,'EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(bis)');
					    end;
			    end;
    end;
  EcritStructureDesCalculsDansJeuMac('sortie de EssaieJouerCoupCalculePourLOrdinateurDansJeuMac');
end;




procedure ContinuerAJouerTantQueLHumainPasseDansJeuMac(var coupMac : SInt64; niveau : SInt64; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16;
    compteurIterationsBoucle : SInt64;
    note : SInt64;
begin
  EcritStructureDesCalculsDansJeuMac('entrée ContinuerAJouerTantQueLHumainPasseDansJeuMac');

  compteurIterationsBoucle := 0;

  WHILE (AQuiDeJouer = couleurMacintosh) and not(gameOver) and not(Quitter) and not(HumCtreHum) and
        not(InterruptionReflexionDansJeuMac) and (compteurIterationsBoucle <= 500) DO
      begin

        EcritStructureDesCalculsDansJeuMac('début de la boucle WHILE de ContinuerAJouerTantQueLHumainPasseDansJeuMac');

        inc(compteurIterationsBoucle);

        if (meilleurCoupHum < 11) or (meilleurCoupHum > 88) then meilleurCoupHum := 44;


        if (GetCouleurOfSquareDansJeuCourant(meilleurCoupHum) = pionVide) and possibleMove[meilleurCoupHum]
          then
            begin
              if debuggage.gestionDuTemps then
                begin
                  EcritStructureDesCalculsDansJeuMac('Je mets coupMac := meilleurCoupHum ('+CoupEnString(meilleurCoupHum,true)+') dans ContinuerAJouerTantQueLHumainPasseDansJeuMac');
                  EcritStructureDesCalculsDansJeuMac('Je mets meilleurCoupHum := 44 ('+CoupEnString(44,true)+') dans ContinuerAJouerTantQueLHumainPasseDansJeuMac');
                end;
              coupMac := meilleurCoupHum;
              meilleurCoupHum := 44;
            end
          else
            begin
              oldInterruption := GetCurrentInterruption;
              EnleveCetteInterruption(oldInterruption);
              vaDepasserTemps := false;
              EnableItemPourCassio(PartieMenu,ForceCmd);
              positionEtTraitDeLAppelReflexionDeMac := PositionEtTraitCourant;
              ChoixMacStandard(coupMac,note,meilleurCoupHum,AQuiDeJouer,niveau,'ContinuerAJouerTantQueLHumainPasseDansJeuMac');
              LanceInterruption(oldInterruption,'ContinuerAJouerTantQueLHumainPasseDansJeuMac');
            end;
        if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
          then TraiteEvenements
          else TraiteNullEvent(theEvent);

        if debuggage.gestionDuTemps and
           not(InterruptionReflexionDansJeuMac) and (AQuiDeJouer = couleurMacintosh) and
           not(EstLaPositionCourante(positionEtTraitDeLAppelReflexionDeMac)) then
			    begin
			      WritelnDansRapport('AHAH !  positionEtTraitDeLAppelReflexionDeMac <> PositionEtTraitCourant dans ContinuerAJouerTantQueLHumainPasseDansJeuMac !');
			      SysBeep(0);
			    end;

			  if debuggage.gestionDuTemps then EcritStructureDesCalculsDansJeuMac('appel de Jouer('+CoupEnString(coupMac,true)+') par ContinuerAJouerTantQueLHumainPasseDansJeuMac(2)');

        JouerUnCoupDuMacintoshDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac,'ContinuerAJouerTantQueLHumainPasseDansJeuMac(2)');

        EcritStructureDesCalculsDansJeuMac('fin de la boucle WHILE de ContinuerAJouerTantQueLHumainPasseDansJeuMac');

      end;

  if (compteurIterationsBoucle >= 500) then WritelnDansRapport('ERREUR !!! boucle infinie dans ContinuerAJouerTantQueLHumainPasseDansJeuMac, prévenez Stéphane');

  EcritStructureDesCalculsDansJeuMac('sortie ContinuerAJouerTantQueLHumainPasseDansJeuMac');
end;


procedure CalculerBonneReponsePourLeJoueurHumainDansJeuMac;
var oldInterruption : SInt16;
    auxCoupHum : SInt64;
    auxColorMac : SInt64;
    tempoProfImposee : boolean;
    note : SInt64;
    uneDefense : SInt64;
begin

  EcritStructureDesCalculsDansJeuMac('entrée dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac');

  reponsePrete := false;
  RefleSurTempsJoueur := true;

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);
  vaDepasserTemps := false;

  if (nbreCoup >= finDePartieOptimale) and ((interruptionReflexion = pasdinterruption) or vaDepasserTemps) then
    if ConnaitSuiteParfaite(auxCoupHum,auxColorMac,false) then
        meilleurCoupHum := auxCoupHum;

  if (meilleurCoupHum < 11) or (meilleurCoupHum > 88) then meilleurCoupHum := 44;

  if (GetCouleurOfSquareDansJeuCourant(meilleurCoupHum) <> pionVide) or not(possibleMove[meilleurCoupHum])
    then
      begin

        EcritStructureDesCalculsDansJeuMac('Je dois calculer un nouveau coup');

        MyDisableItem(PartieMenu,ForceCmd);
        meilleurCoupHum := 44;
        tempoProfImposee := ProfondeurMilieuEstImposee;
        SetProfImposee(true,'cas 1 dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac');
        if not(jeuInstantane) or CassioEstEnModeSolitaire
          then ChoixMacStandard(meilleurCoupHum,note,uneDefense,AQuiDeJouer,4,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(1)')
          else
            if (NiveauJeuInstantane < NiveauChampions) and (phaseDeLaPartie <= phaseMilieu)
              then meilleurCoupHum := ReponseInstantanee(uneDefense,NiveauJeuInstantane)
              else ChoixMacStandard(meilleurCoupHum,note,uneDefense,AQuiDeJouer,3,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(2)');
        SetProfImposee(tempoProfImposee,'cas 1 dans CalculerBonneReponsePourLeJoueurHumainDansJeuMac (tempoProfImposee)');
        if (interruptionReflexion <> pasdinterruption) then
          TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac(3)');
      end
    else
      EcritStructureDesCalculsDansJeuMac('Je peux reutiliser le coup ' + CoupEnString(meilleurCoupHum,true) + ' déja calculé');

  LanceInterruption(oldInterruption,'CalculerBonneReponsePourLeJoueurHumainDansJeuMac');

  EcritStructureDesCalculsDansJeuMac('sortie de CalculerBonneReponsePourLeJoueurHumainDansJeuMac');
end;



procedure AfficherSuggestionDeCassioDansJeuMac;
var oldport : grafPtr;
begin
  EcritStructureDesCalculsDansJeuMac('entrée dans AfficherSuggestionDeCassioDansJeuMac');

  if afficheSuggestionDeCassio then
    begin
     if windowPlateauOpen then
       begin
        GetPort(oldport);
        SetPortByWindow(wPlateauPtr);
        if CassioEstEn3D
          then DessinePion3D(meilleurCoupHum,effaceCase)
          else DessinePion2D(meilleurCoupHum,pionVide);
        DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'AfficherSuggestionDeCassioDansJeuMac');
        SetPort(oldport);
        if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);
        if afficheInfosApprentissage then EcritLesInfosDApprentissage;
       end;
    end;

  EcritStructureDesCalculsDansJeuMac('sortie de AfficherSuggestionDeCassioDansJeuMac');
end;


procedure LanceReflexionSurLeTempsAdverseDansJeuMac(var coupMac : SInt64; var positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec);
var oldInterruption : SInt16;
    platSup : plateauOthello;
    jouablesup : plBool;
    nbblancsup : SInt64;
    nbNoirsup : SInt64;
    frontsup : InfoFront;
    auxColorMac : SInt64;
    coupLegal : boolean;
    tempoProfImposee : boolean;
    auxCoupHum : SInt64;
    auxNote : SInt64;
begin

  EcritStructureDesCalculsDansJeuMac('entrée dans LanceReflexionSurLeTempsAdverseDansJeuMac');

  nbblancsup := nbreDePions[pionBlanc];
  nbNoirsup := nbreDePions[pionNoir];
  platsup := JeuCourant;
  jouablesup := emplJouable;
  frontsup := frontiereCourante;
  auxColorMac := couleurMacintosh;
  coupLegal := ModifPlat(meilleurCoupHum,-auxColorMac,platsup,jouablesup,nbBlancsup,nbNoirsup,frontsup);

  {if phaseDeLaPartie < phaseFinaleParfaite then
    AnnonceSupposeSuitConseilMac(nbreCoup+1,meilleurCoupHum);}

  MyDisableItem(PartieMenu,ForceCmd);

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  vaDepasserTemps := false;
  tempoProfImposee := ProfondeurMilieuEstImposee;
  SetProfImposee(false,'cas 2 dans LanceReflexionSurLeTempsAdverseDansJeuMac');
  auxCoupHum := 44;


  if (((nbreCoup+1) >= 60) or DoitPasser(auxColorMac,platsup,jouablesup))
    then
      begin
        reponsePrete := true;
        MeilleurCoupHumPret := auxCoupHum;
        meilleureReponsePrete := 44;
      end
    else
      begin
        if (nbblancsup > 0) and (nbNoirsup > 0) then
          begin

            positionEtTraitDeLAppelReflexionDeMac := MakePositionEtTrait(platSup,auxColorMac);

            ChoixMac(coupMac,auxNote,auxCoupHum,auxColorMac,level,nbblancsup,nbNoirsup,platsup,jouablesup,frontsup,'LanceReflexionSurLeTempsAdverseDansJeuMac');

            AfficheInfosDebugage2DansJeuMac(coupMac,auxCoupHum);

	          if RefleSurTempsJoueur and (PhasePartieDerniereReflexion >= phaseMilieu)
	            then
		            begin
		              if not(InterruptionReflexionDansJeuMac) then
		               begin
		                reponsePrete := true;
		                meilleureReponsePrete := coupMac;
		                MeilleurCoupHumPret := auxCoupHum;
		               end;
		            end
	            else
		            begin
		              if not(InterruptionReflexionDansJeuMac) then
		                meilleurCoupHum := auxCoupHum;
		            end;
	        end;
      end;


  SetProfImposee(tempoProfImposee,'cas 2 dans LanceReflexionSurLeTempsAdverseDansJeuMac (tempoProfImposee)');
  EnableItemPourCassio(PartieMenu,ForceCmd);
{ DessinePosition(JeuCourant);}
{ DessinePetitCentre;}

  LanceInterruption(oldInterruption,'LanceReflexionSurLeTempsAdverseDansJeuMac');
  EnleveCetteInterruption(interruptionDepassementTemps);

	EcritStructureDesCalculsDansJeuMac('sortie LanceReflexionSurLeTempsAdverseDansJeuMac');
end;


procedure JeuMac(niveau : SInt64; const fonctionAppelante : String255);
var coupMac : SInt64;
    compteurIterationsBoucle : SInt64;
    positionEtTraitDeLAppelReflexionDeMac : PositionEtTraitRec;
begin
  if not(Quitter) then
    begin

      { Ceci est la position de reflexion de Cassio }
		  positionEtTraitDeLAppelReflexionDeMac := PositionEtTraitCourant;

		  { Des infos de debugage }
		  AfficheDebugageEntreeDansJeuMac(fonctionAppelante,positionEtTraitDeLAppelReflexionDeMac);
		  InvalidateAnalyseDeFinaleSiNecessaire(kNormal);

		  { On donne moins de temps aux autre applications puisque Cassio reflechit }
		  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

		  { On calcule le coup que Cassio va jouer }
		  ReflexionInitialeDuMacintoshDansJeuMac(coupMac,niveau,positionEtTraitDeLAppelReflexionDeMac);

		  { Verifions les evenements a tout hasard }
		  CheckEventsDansJeuMac(' CheckEventsDansJeuMac(1)');
		  AfficheInfosDebugage1DansJeuMac(positionEtTraitDeLAppelReflexionDeMac);



		  { Si c'est vraiement a Cassio de jouer, on boucle ainsi : }

		  compteurIterationsBoucle := 0;
		  if not(InterruptionReflexionDansJeuMac) and not(Quitter) and not(HumCtreHum) and
		     not(AttenteAnalyseDeFinaleDansPositionCourante) and
		     EstLaPositionCourante(positionEtTraitDeLAppelReflexionDeMac)
		    then
    		  REPEAT
    		    inc(compteurIterationsBoucle);
    		    EcritStructureDesCalculsDansJeuMac('au début de la boucle REPEAT dans JeuMac{1}');

    		    { On essaie de jouer le coup du Mac }
    		    EssaieJouerCoupCalculePourLOrdinateurDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac);

    		    { Si l'humain passe alors la "defense" precedente est le meilleur coup de Mac }
    		    ContinuerAJouerTantQueLHumainPasseDansJeuMac(coupMac,niveau,positionEtTraitDeLAppelReflexionDeMac);


    		    { Gestion de la reflexion sur le temps adverse }
    		    if not(CassioEstEnModeAnalyse) then
    		      if not(InterruptionReflexionDansJeuMac) and not(HumCtreHum) and not(enTournoi) and not(gameOver) then
    		        begin

    		          { D'abord on cherche une bonne reponse pour le joueur humain, la "suggestion de Cassio" }
    		          CalculerBonneReponsePourLeJoueurHumainDansJeuMac;

    		          if not(InterruptionReflexionDansJeuMac) and not(HumCtreHum) and
                     (meilleurCoupHum >= 11) and (meilleurCoupHum <= 88) and
                     (GetCouleurOfSquareDansJeuCourant(meilleurCoupHum) = pionVide) and possibleMove[meilleurCoupHum] then
                    begin

    		              { On essaie de l'affiche comme suggestion de Cassio (pion jaune) }
    		              AfficherSuggestionDeCassioDansJeuMac;

    		              { Puis on lance la reflexion de Cassio en supposant que l'humain a joué la suggestion }
    		              if CassioDoitReflechirSurLeTempsAdverseDansConfigurationCourante then
    		                LanceReflexionSurLeTempsAdverseDansJeuMac(coupMac,positionEtTraitDeLAppelReflexionDeMac);

    		            end;
    		        end;

    		     EcritStructureDesCalculsDansJeuMac('à la fin de la boucle REPEAT dans JeuMac(1)');

    		  UNTIL Quitter or gameOver or HumCtreHum or InterruptionReflexionDansJeuMac or enTournoi or (compteurIterationsBoucle >= 500) or
    		        RefleSurTempsJoueur or (AQuiDeJouer <> couleurMacintosh) or AttenteAnalyseDeFinaleDansPositionCourante;

		  if (compteurIterationsBoucle >= 500) then WritelnDansRapport('ERREUR !!!! boucle infinie dans JeuMac, prévenez Stéphane');

		  AfficheDebuggageSortieDeJeuMac;


	 end;
end;


function GetPremierCoupAleatoire : SInt64;
var a,b : SInt64;
begin
  a := 0;
  if not(positionFeerique) then
    begin
      a := (Abs(Random16()) mod 4) + 3;
        case a of
          3 : b := 4;
          4 : b := 3;
          5 : b := 6;
          6 : b := 5;
        end;
        a := a+10*b;
    end;
  GetPremierCoupAleatoire := a;
end;



procedure PremierCoupMac;
var a,b : SInt16;
begin
  if nroDernierCoupAtteint <= 1
    then
      begin
        a := (Abs(TickCount) mod 4)+3;
        case a of
          3 : b := 4;
          4 : b := 3;
          5 : b := 6;
          6 : b := 5;
        end;
        a := a+10*b;
      end
    else
      begin
        a := GetNiemeCoupPartieCourante(1);
      end;

  if AQuiDeJouer = couleurMacintosh then
    Jouer(a,'PremierCoupMac');

end;

procedure DoForcerMacAJouerMaintenant;
  begin
    if not(HumCtreHum) then
      begin
        if debuggage.gestionDuTemps then
          WritelnDansRapport('je suis dans DoForcerMacAJouerMaintenant');
        LanceInterruptionConditionnelle(interruptionDepassementTemps,'',0,'DoForcerMacAJouerMaintenant');
        vaDepasserTemps := true;
      end;
  end;


function GetMeilleurCoupConnuMaintenant : SInt64;
var result,coup,def : SInt64;
    positionFenetreReflexion : PositionEtTraitRec;
    ecritExplications : boolean;
    tempoAvecBibl,tempoVarierCoups,biblFournitUnCoup : boolean;
begin
  result := 0;

  ecritExplications := false;

  (* on cherche si on est au premier coup *)
  if (nbreCoup <= 0) then
    begin
      if (nroDernierCoupAtteint >= 1)
        then coup := GetNiemeCoupPartieCourante(1)
        else
          if not(positionFeerique)
            then coup := GetPremierCoupAleatoire
            else coup := ReponseInstantanee(def, NiveauChampions);
      if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
        begin
          GetMeilleurCoupConnuMaintenant := coup;
          exit;
        end;
    end;


  (* on cherche si l'arbre de jeu donne une suite parfaite *)
  if ConnaitSuiteParfaiteParArbreDeJeu(coup,def,false)
     and (coup >= 11) and (coup <= 88) and (possibleMove[coup])  then
    begin
      if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (ConnaitSuiteParfaiteParArbreDeJeu), coup = ',coup);
      GetMeilleurCoupConnuMaintenant := coup;
      exit;
    end;


  (* on cherche si on connait une suite parfaite *)
  if (phaseDeLaPartie >= phaseFinale) and ConnaitSuiteParfaite(coup,def,false)
     and (coup >= 11) and (coup <= 88) and (possibleMove[coup])  then
    begin
      if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (ConnaitSuiteParfaite), coup = ',coup);
      GetMeilleurCoupConnuMaintenant := coup;
      exit;
    end;


  (* on cherche si on est en attente d'analyse de finale *)
  if (phaseDeLaPartie >= phaseFinale) and AttenteAnalyseDeFinaleDansPositionCourante then
    begin
      coup := GetBestMoveAttenteAnalyseDeFinale;
      if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
        begin
          if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (GetBestMoveAttenteAnalyseDeFinale), coup = ',coup);
          GetMeilleurCoupConnuMaintenant := coup;
          exit;
        end;
    end;


  (* on cherche si on peut renvoyer une reflexion en cours *)
  positionFenetreReflexion := GetPositionDansFntreReflexion(ReflexData^);
  {if ecritExplications then WritelnPositionEtTraitDansRapport(positionFenetreReflexion.position,GetTraitOfPosition(positionFenetreReflexion));}
  if EstLaPositionCourante(positionFenetreReflexion) then
    begin
      coup := GetCoupEnTeteDansFenetreReflexion;
      if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
        begin
          if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (GetCoupEnTeteDansFenetreReflexion), coup = ',coup);
          GetMeilleurCoupConnuMaintenant := coup;
          exit;
        end;
    end;


  (* on cherche si on aurait prevu un coup pour l'humain *)
  if (meilleurCoupHum <> 0) then
    begin
      coup := meilleurCoupHum;
      if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
        begin
          if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (meilleurCoupHum), coup = ',coup);
          GetMeilleurCoupConnuMaintenant := coup;
          exit;
        end;
    end;


  (* on cherche si la bibliotheque pourrait trouver un coup *)
  tempoAvecBibl := avecBibl;
  tempoVarierCoups := gEntrainementOuvertures.CassioVarieSesCoups;
  avecBibl := true;
  gEntrainementOuvertures.CassioVarieSesCoups := true;
  biblFournitUnCoup := LaBibliothequeEstCapableDeFournirUnCoup(coup,def);
  avecBibl := tempoAvecBibl;
  gEntrainementOuvertures.CassioVarieSesCoups := tempoVarierCoups;

  if biblFournitUnCoup then
    if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
      begin
        if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (LaBibliothequeEstCapableDeFournirUnCoup), coup = ',coup);
        GetMeilleurCoupConnuMaintenant := coup;
        exit;
      end;


  (* on cherche a generer un coup potable instantanement en milieu de partie *)
  SetCassioChecksEvents(false);
  coup := ReponseInstantanee(def, NiveauIntersideral);
  SetCassioChecksEvents(true);
  if (coup >= 11) and (coup <= 88) and (possibleMove[coup]) then
    begin
      if ecritExplications then WritelnStringAndCoupDansRapport('GetMeilleurCoupConnuMaintenant (ReponseInstantanee), coup = ',coup);
      GetMeilleurCoupConnuMaintenant := coup;
      exit;
    end;

  (* rien n'a l'air de marcher... :-( *)
  GetMeilleurCoupConnuMaintenant := result;
end;



procedure DoJouerMeilleurCoupConnuMaintenant;
var coup : SInt64;
    tempoSon : boolean;
begin

  if gameOver then exit;

  coup := GetMeilleurCoupConnuMaintenant;

  {
  WritelnDansRapport('DoJouerMeilleurCoupConnuMaintenant');
  if (coup >= 11) and (coup <= 88)
    then WritelnStringAndCoupDansRapport('coup = ',coup)
    else WritelnNumDansRapport('coup = ',coup);
  }

  if (coup <> 0) and (coup >= 11) and (coup <= 88) then
    begin
      tempoSon := avecSon;
      avecSon := false;

      TraiteCoupImprevu(coup);

      avecSon := tempoSon;
    end;


  // DoForcerMacAJouerMaintenant;

end;


procedure TraiteCoupImprevu(caseX : SInt64);
var caseY : SInt64;
    CassioReflechissaitSurLeTempsHumain : boolean;
    coupDejaTrouveDansBibl : boolean;
    couplegal : boolean;
    laBibliothequeEstCapableDeFournirUnCoup : boolean;
    nbReponsesEnBibliotheque : SInt64;
    config : ConfigurationCassioRec;
begin

  if debuggage.gestionDuTemps then
    WritelnDansRapport('entrée dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+')');

  if (caseX < 11) or (caseX > 88) then
    begin
      WritelnDansRapport('ASSERT((caseX < 11) or (caseX > 88)) dans TraiteCoupImprevu!! Merci de prévenir Stéphane');
      AlerteSimple('ASSERT((caseX < 11) or (caseX > 88)) dans TraiteCoupImprevu');
      exit;
    end;

 avecCalculPartiesActives := true;
 if HumCtreHum
   then
     begin
       Jouer(caseX,'TraiteCoupImprevu (1)');
     end
   else
    if (AQuiDeJouer = -couleurMacintosh) then
     begin
       if debuggage.gestionDuTemps
         then WritelnDansRapport('dans TraiteCoupImprevu, (AQuiDeJouer = -couleurMacintosh)');
       CassioReflechissaitSurLeTempsHumain := false;
       couplegal := possibleMove[caseX];
       Jouer(caseX,'TraiteCoupImprevu (2)');
       if couplegal and RefleSurTempsJoueur then
         begin
           if debuggage.gestionDuTemps then
             begin
               WritelnDansRapport('dans TraiteCoupImprevu, couplegal and RefleSurTempsJoueur');
               WritelnStringAndCoupDansRapport('dans TraiteCoupImprevu, meilleurCoupHum = ',meilleurCoupHum);
             end;
           reponsePrete := reponsePrete and (caseX = meilleurCoupHum);
           CassioReflechissaitSurLeTempsHumain := true;
           RefleSurTempsJoueur := false;
           if (caseX <> meilleurCoupHum) then
             begin
               LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (3)');
               vaDepasserTemps := false;
               meilleurCoupHum := 44;
              (* if avecDessinCoupEnTete then EffaceCoupEnTete;
               SetCoupEnTete(0); *)
             end
           else
             if ((tempsPrevu div 60) > tempsAlloue) and (tempsAlloue < kUnMoisDeTemps) and
                 (phaseDeLaPartie <= phaseMilieu) and not(CassioEstEnModeAnalyse) then
               DoForcerMacAJouerMaintenant;
           LanceChrono;
           EnableItemPourCassio(PartieMenu,ForceCmd);
         end;
       if CassioReflechissaitSurLeTempsHumain and not(HumCtreHum) and (caseX = meilleurCoupHum)
         then
           begin
             EcritJeReflechis(couleurMacintosh);
           end;
       if (AQuiDeJouer = couleurMacintosh) and not(CassioEstEnModeAnalyse) then
         begin
          coupDejaTrouveDansBibl := false;
          if UtiliseGrapheApprentissage then
            if PeutChoisirDansGrapheApprentissage(caseY,MeilleurCoupHumPret) then
              begin
                if (caseY > 0) and (caseY < 99) then
                if possibleMove[caseY] then
                  begin
                    vaDepasserTemps := false;
                    reponsePrete := true;
                    meilleureReponsePrete := caseY;
                    MeilleurCoupHumPret := MeilleurCoupHumPret;
                    LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (4)');
                    coupDejaTrouveDansBibl := true;
                  end;
              end;
          if (nbreCoup <= LongMaxBibl) and not(coupDejaTrouveDansBibl) then
            begin
              if avecBibl or (jeuInstantane and (NiveauJeuInstantane <= NiveauChampions))
                then
                  begin
                    laBibliothequeEstCapableDeFournirUnCoup := PeutChoisirEnBibl(caseY,MeilleurCoupHumPret,false,nbReponsesEnBibliotheque);
                    {WritelnStringAndBoolDansRapport('laBibliothequeEstCapableDeFournirUnCoup = ',laBibliothequeEstCapableDeFournirUnCoup);
                    WritelnNumDansRapport('nbReponsesEnBibliotheque = ',nbReponsesEnBibliotheque);
                    WritelnStringAndCoupDansRapport('caseY = ',caseY);
                    WritelnStringAndCoupDansRapport('MeilleurCoupHumPret = ',MeilleurCoupHumPret);
                    WritelnDansRapport('');}
                    if not(avecBibl) then
                      laBibliothequeEstCapableDeFournirUnCoup := laBibliothequeEstCapableDeFournirUnCoup and
                                                                 (nbReponsesEnBibliotheque > 1);
                  end
                else
                  begin
                    laBibliothequeEstCapableDeFournirUnCoup := false;
                    nbReponsesEnBibliotheque := 0;
                  end;

	            if laBibliothequeEstCapableDeFournirUnCoup then
	              begin
	                if (caseY > 0) and (caseY < 99) then
	                if possibleMove[caseY] then
	                  begin
	                    vaDepasserTemps := false;
	                    reponsePrete := true;
	                    meilleureReponsePrete := caseY;
	                    MeilleurCoupHumPret := MeilleurCoupHumPret;
	                    LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (5)');
	                    coupDejaTrouveDansBibl := true;
	                  end;
	              end;
	          end;
          if (phaseDeLaPartie >= phaseFinale) and not(coupDejaTrouveDansBibl) then
           if ((interruptionReflexion = pasdinterruption) or vaDepasserTemps) and ConnaitSuiteParfaite(caseY,MeilleurCoupHumPret,true) then
             begin
               if (caseY > 0) and (caseY < 99) then
                if possibleMove[caseY] then
                  begin
                    vaDepasserTemps := false;
                    reponsePrete := true;
                    meilleureReponsePrete := caseY;
                    MeilleurCoupHumPret := MeilleurCoupHumPret;
                    LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (6)');
                    coupDejaTrouveDansBibl := true;
                  end;
             end;
          if jeuInstantane and (phaseDeLaPartie <= phaseMilieu) and not(coupDejaTrouveDansBibl) then
            with gEntrainementOuvertures do
	            begin
	             if CassioReflechissaitSurLeTempsHumain and not(HumCtreHum) and (caseX = meilleurCoupHum) and
	                (((NiveauJeuInstantane = NiveauChampions) and profSupUn) or
	                 (CassioVarieSesCoups and (derniereProfCompleteMilieuDePartie >= profondeurRechercheVariations)))
	              then
	                DoForcerMacAJouerMaintenant
	              else
	                begin
	                  if debuggage.gestionDuTemps
                      then WritelnDansRapport('appel à ReponseInstantanee dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+') !!');
	                  SetCassioChecksEvents(false);
	                  caseY := ReponseInstantanee(MeilleurCoupHumPret,NiveauJeuInstantane);
	                  SetCassioChecksEvents(true);
	                  if (caseY > 0) and (caseY < 99) then
	                  if possibleMove[caseY]
	                    then
	                      begin
	                        vaDepasserTemps := false;
	                        reponsePrete := true;
	                        meilleureReponsePrete := caseY;
	                        LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (7)');
	                      end
	                    else  {normalement on ne devrait jamais passer ici, mais sait-on jamais…}
	                      begin
	                        WritelnDansRapport('Should never happen dans TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+') !!');

	                        LanceInterruptionSimple('TraiteCoupImprevu (SHOULD NEVER HAPPEN)');
	                        vaDepasserTemps := false;
	                        reponsePrete := false;
	                      end;
	                end;
	            end;
         end;
     end
    else  { si on veut jouer a la place de Mac... }
	     begin
	       if debuggage.gestionDuTemps
            then WritelnDansRapport('On veut jouer a la place de Mac dans TraiteCoupImprevu…');

	       if possibleMove[caseX] then
	         if PeutArreterAnalyseRetrograde then
	           begin
	             (*if avecDessinCoupEnTete then EffaceCoupEnTete;
	             SetCoupEnTete(0); *)
	             SetCassioChecksEvents(false);
	             Jouer(caseX,'TraiteCoupImprevu (8)');
	             SetCassioChecksEvents(true);
	             LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'TraiteCoupImprevu (8)');
	             vaDepasserTemps := false;
	           end;
	     end;

	if CassioEstEnTrainDeCalculerPourLeZoo
	  then LanceInterruptionSimpleConditionnelle('TraiteCoupImprevu (9)');

	if debuggage.gestionDuTemps then
    begin
      WritelnDansRapport('sortie de TraiteCoupImprevu('+CoupEnStringEnMajuscules(caseX)+')');
      WritelnDansRapport('a la sortie de TraiteCoupImprevu, voici la position courante :');
      WritelnPositionEtTraitDansRapport(JeuCourant,AQuiDeJouer);
      GetConfigurationCouranteDeCassio(config);
      WritelnNumDansRapport('l''algo qui devrait etre lance est : ',TypeDeCalculLanceParCassioDansCetteConfiguration(config));
    end;
end;


procedure JoueCoupPartieSelectionnee(nroHilite : SInt64);
var nroreference : SInt64;
    premierNumero,dernierNumero : SInt64;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    CaseX,premierCoup : SInt16;
    temposon : boolean;
    coupEnByte : SInt64;
    theGame : PackedThorGame;
    s60 : String255;
    partieEnClair : String255;
    debuguerCetteFonction : boolean;
begin

  debuguerCetteFonction := false;

  if (nbreCoup < 60) and debuguerCetteFonction then WritelnDansRapport('(nbreCoup < 60) : OK');
  if windowListeOpen and debuguerCetteFonction then WritelnDansRapport('windowListeOpen : OK');
  if not(enRetour or enSetUp) and debuguerCetteFonction then WritelnDansRapport('not(enRetour or enSetUp) : OK');
  if (infosListeParties.ascenseurListe <> NIL) and debuguerCetteFonction then WritelnDansRapport('infosListeParties.ascenseurListe <> NIL : OK');

  if (nbreCoup < 60) and windowListeOpen and not(enRetour or enSetUp) and not(gameOver) then
    if infosListeParties.ascenseurListe <> NIL then
    begin


      if debuguerCetteFonction then WritelnDansRapport('avant GetNumerosPremiereEtDernierePartiesAffichees : OK');

      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);

      if debuguerCetteFonction then
        begin
          WritelnDansRapport('apres GetNumerosPremiereEtDernierePartiesAffichees : OK');
          WritelnNumDansRapport('premierNumero = ',premierNumero);
          WritelnNumDansRapport('dernierNumero = ',dernierNumero);
        end;

      {if (nroHilite >= premierNumero) and (nroHilite <= dernierNumero)
        then}
      if (nroHilite >= 1) and (nroHilite <= nbPartiesActives) then
          begin
            {nroReference := tableNumeroReference^^[nroHilite];
            if nroReference <> infosListeParties.dernierNroReferenceHilitee then SysBeep(0);}
            nroReference := infosListeParties.dernierNroReferenceHilitee;

            if debuguerCetteFonction then
            WritelnNumDansRapport('nroReference = ',nroReference);


            ExtraitPartieTableStockageParties(nroReference,theGame);

            ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(theGame);

            if debuguerCetteFonction then
              begin
                COPY_PACKED_GAME_TO_STR60(theGame, s60);
                WritelnDansRapport('theGame = ' + s60);
              end;

            if debuguerCetteFonction then
            TraductionThorEnAlphanumerique(theGame,partieEnClair);

            if debuguerCetteFonction then
            WritelnDansRapport('partieEnClair = '+partieEnClair);

		        ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);

		        if debuguerCetteFonction then
		        WritelnNumDansRapport('premierCoup = ',premierCoup);


		        TransposePartiePourOrientation(theGame,autreCoupQuatreDansPartie and (nbreCoup >= 4),1,60);

            if debuguerCetteFonction then
            TraductionThorEnAlphanumerique(theGame,partieEnClair);

            if debuguerCetteFonction then
            WritelnDansRapport('partieEnClair = '+partieEnClair);


            if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,theGame))) then
			        begin
			          if debuguerCetteFonction then WritelnDansRapport('WARNING : not(positionsSontEgales(…) dans JoueCoupPartieSelectionnee');
			          with DemandeCalculsPourBase do
	              if (EtatDesCalculs <> kCalculsEnCours) or (NumeroDuCoupDeLaDemande <> nbreCoup) or bInfosDejaCalcules then
	                LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
	              InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
			          exit;
			        end;


			      if debuguerCetteFonction then
			      WritelnDansRapport('avant extraitCoupTablestockagePartie : OK');

            ExtraitCoupTableStockagePartie(nroReference,nbreCoup+1,coupEnByte);
            caseX := coupEnByte;

            if debuguerCetteFonction then
            WritelnDansRapport('apres extraitCoupTablestockagePartie : OK');
            if debuguerCetteFonction then
            WritelnNumDansRapport('caseX = ',caseX);


            temposon := avecSon;
            avecSon := false;
            if (caseX >= 11) and (caseX <= 88) then
              begin
                autreCoupQuatreDansPartie := false;
                if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);

                if debuguerCetteFonction then
                WritelnDansRapport('avant TransposeCoupPourOrientation : OK');

                TransposeCoupPourOrientation(caseX,autreCoupQuatreDansPartie);

                if debuguerCetteFonction then
                WritelnDansRapport('apres TransposeCoupPourOrientation : OK');

                TraiteCoupImprevu(caseX);
              end;
            avecSon := temposon;
            PartieContreMacDeBoutEnBout := (nbreCoup <= 2);
          end;
    end;
end;


procedure JoueCoupMajoritaireStat;
var caseX : SInt16;
    autreCoupQuatreDansPartie : boolean;
    premierCoup : SInt16;
    temposon : boolean;
begin
  if not(gameOver) and (nbreCoup < 60) and not(problemeMemoireBase) then
    begin
		  if windowStatOpen and not(enRetour or enSetUp) and (statistiques <> NIL) and StatistiquesCalculsFaitsAuMoinsUneFois
		    then
		      begin
			      if statistiques^^.nbTotalParties > 0 then
			        begin
			           temposon := avecSon;
			           avecSon := false;
			           autreCoupQuatreDansPartie := false;
			           if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
			           caseX := ord(statistiques^^.table[1].coup);
			           TransposeCoupPourOrientation(caseX,autreCoupQuatreDansPartie);
			           TraiteCoupImprevu(caseX);
			           avecSon := temposon;
			        end;
		     end
		    else  {if windowStatOpen}
		      if windowListeOpen and (nbPartiesActives = 1) then
		        JoueCoupPartieSelectionnee(infosListeParties.partieHilitee);
    end;
end;

procedure JoueCoupQueMacAttendait;
var oldPort : grafPtr;
    joueCoupQueMacAttendaitOK : boolean;
    reponseOrdi,note : SInt64;


  function DessineOuJoueCoupQueMacAttendait(theMove : SInt64) : boolean;
  var coupTraite : boolean;
  begin
    coupTraite := false;
    if (theMove >= 11) and (theMove <= 88) then
    if possibleMove[theMove] then
      begin
        if afficheSuggestionDeCassio or gDoitJouerMeilleureReponse
          then
            begin
              coupTraite := true;
              TraiteCoupImprevu(theMove);
              gDoitJouerMeilleureReponse := false;
            end
          else
            begin
              coupTraite := true;
              gDoitJouerMeilleureReponse := true;
              SetSuggestionDeFinaleEstDessinee(true);
              DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'DessineOuJoueCoupQueMacAttendait');
            end;
      end;
    DessineOuJoueCoupQueMacAttendait := coupTraite;
  end;



begin  {JoueCoupQueMacAttendait}
  if windowPlateauOpen and not(gameOver) and (interruptionReflexion = pasdinterruption) then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      if (AQuiDeJouer = -couleurMacintosh) then
        begin

		      {afficher ou jouer le coup attendu}
		      joueCoupQueMacAttendaitOK := DessineOuJoueCoupQueMacAttendait(meilleurCoupHum);

		      {si le meilleur coup humain n'était pas precalculé, on le calcule et on l'affiche}
		      if not(joueCoupQueMacAttendaitOK) and not(gameOver) and not(RefleSurTempsJoueur) and
		         not(HumCtreHum) and (AQuiDeJouer = -couleurMacintosh) and (phaseDeLaPartie >= phaseFinale) and
		         (interruptionReflexion = pasdinterruption) then
		          begin
		            reponsePrete := false;
		            RefleSurTempsJoueur := true;
		            vaDepasserTemps := false;

		            MyDisableItem(PartieMenu,ForceCmd);
		            meilleurCoupHum := 44;
		            ChoixMacStandard(meilleurCoupHum,note,reponseOrdi,AQuiDeJouer,3,'JoueCoupQueMacAttendait{2}');
		            if (interruptionReflexion <> pasdinterruption)
		              then
		                TraiteInterruptionBrutale(meilleurCoupHum,MeilleurCoupHumPret,'JoueCoupQueMacAttendait(2)')
		              else
		                begin
		                  joueCoupQueMacAttendaitOK := true;
		                  gDoitJouerMeilleureReponse := true;
		                  SetSuggestionDeFinaleEstDessinee(true);
		                  DessineAutresInfosSurCasesAideDebutant(othellierToutEntier,'JoueCoupQueMacAttendait');
		                end;
		          end;
		      end
		    else
		      begin
		        {si on est en mode analyse de finale, on affiche le meilleur coup de la position}
		        if AttenteAnalyseDeFinaleDansPositionCourante then
		          begin
		            if DessineOuJoueCoupQueMacAttendait(GetBestMoveAttenteAnalyseDeFinale) then DoNothing;
		          end;
		      end;
      SetPort(oldPort);
    end;
end;



procedure MiseAJourDeLaPartie(s : String255;
                              jeuDepart : plateauOthello;
                              jouableDepart : plBool;
                              frontiereDepart : InfoFront;
                              nbBlancsDepart,nbNoirsDepart : SInt64;
                              traitDepart : SInt16;
                              nbreCoupDepart : SInt16;
                              depuisPositionInitiale : boolean;
                              coupFinal : SInt16;
                              var gameNodeLePlusProfondGenere : GameTree;
                              fonctionAppelante : String255);
{ remet à jour les retournements, les notes, etc, }
{ à partir de la position initiale (depuisDebut = true) }
{ ou de la position courante (depuisdebut = false) }
var jeu : plateauOthello;
    jouable : plBool;
    front : InfoFront;
    numFirst,nbBlanc,nbNoir : SInt64;
    i,len,index,x,coul,nbreCoupsDejaEffectues : SInt16;
    encorePossible,bidbool : boolean;
    GameNodeAAtteindre : GameTree;
    positionInitiale : plateauOthello;
    numeroPremierCoupJoue,traitInitial : SInt64;
    nbBlancsInitial,nbNoirsInitial : SInt64;
    numeroDuPlusGrandCoupLegal : SInt64;
    transcriptAccepteLesDonneesTemp : boolean;
    usingZebraBookArrivee : boolean;
    partieEnAlphaDepart : String255;
    err : OSErr;
    oldCheckDangerousEvents : boolean;
begin

  SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

  partieEnAlphaDepart := s;

  CompacterPartieAlphanumerique(s,kCompacterTelQuel);

  usingZebraBookArrivee := GetUsingZebraBook;
  SetUsingZebraBook(false);



  GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoupJoue,traitInitial,nbBlancsInitial,nbNoirsInitial);
  if not(depuisPositionInitiale)
    then
      begin
        jeu := jeuDepart;
        jouable := jouableDepart;
        front := frontiereDepart;
        nbBlanc := nbBlancsDepart;
        nbNoir := nbNoirsDepart;
        coul := traitDepart;
        nbreCoupsDejaEffectues := nbreCoupDepart;
      end
    else
      begin
        SetCurrentNodeToGameRoot;
        MarquerCurrentNodeCommeReel(fonctionAppelante + 'MiseAJourDeLaPartie');
        GetPositionInitialeOfGameTree(jeu,numFirst,traitInitial,nbBlanc,nbNoir);

        coul := 0;
        i := 0;
        repeat
          inc(i);
          if GetNiemeCoupPartieCourante(i) <> 0 then coul := GetCouleurNiemeCoupPartieCourante(i);
        until (coul <> 0) or (i >= 64);
        nbreCoupsDejaEffectues := i-1;
        InitialiseDirectionsJouables;
        CarteJouable(jeu,jouable);
        CarteFrontiere(jeu,front);
      end;
  {if (LENGTH_OF_STRING(s) div 2) < coupFinal then coupfinal := LENGTH_OF_STRING(s) div 2;}

  GameNodeAAtteindre := GetCurrentNode;

  len := LENGTH_OF_STRING(s);
  encorePossible := (len >= 2);
  numeroDuPlusGrandCoupLegal := nbreCoupsDejaEffectues;

  if debuggage.arbreDeJeu then
       begin
		     WritelnDansRapport('avant la boucle dans MiseAJourDeLaPartie :');
		     WritelnNumDansRapport('   s = '+s+' et lenght(s) = ',len);
		     WritelnNumDansRapport('   nbreCoupsDejaEffectues = ',nbreCoupsDejaEffectues);
		     WritelnNumDansRapport('   CoupFinal = ',CoupFinal);
		     WritelnNumDansRapport('   numeroPremierCoupJoue = ',numeroPremierCoupJoue);
		   end;

  for i := nbreCoupsDejaEffectues+1 to 65 do
    InvalidateNombrePartiesActivesDansLeCache(i);

 if EnModeEntreeTranscript then SetTranscriptAccepteLesDonnees(false,transcriptAccepteLesDonneesTemp);

  for i := nbreCoupsDejaEffectues+1 to CoupFinal do
   begin

     if debuggage.arbreDeJeu then
       begin
		     WriteDansRapport('i = '+IntToStr(i)+'  => ');
		     if encorepossible
		       then WritelnDansRapport('encorepossible = true')
		       else WritelnDansRapport('encorepossible = false');
		   end;

    if encorepossible then
     begin
       index := (i-numeroPremierCoupJoue+1);
       if 2*index > len then encorePossible := false;  {on est arrive a la fin de la chaine}

       if debuggage.arbreDeJeu then
         WritelnNumDansRapport('i = '+IntToStr(i)+'  => index = ',index);

       if debuggage.arbreDeJeu then
       begin
		     WriteDansRapport('i = '+IntToStr(i)+'  => ');
		     if encorepossible
		       then WritelnDansRapport('encorepossible = true')
		       else WritelnDansRapport('encorepossible = false (car 2*index > len)');
		   end;

       if encorePossible then
         begin
           SetUsingZebraBook(false);

           x := PositionDansStringAlphaEnCoup(s,2*index-1);

		       if debuggage.arbreDeJeu then
			       begin
					     WritelnNumDansRapport('i = '+IntToStr(i)+'  => coup = '+CoupEnStringEnMajuscules(x)+ ' car x = ',x);
					   end;


					 if (x < 11) or (x > 88) then
					   begin
					     WritelnNumDansRapport('ASSERT : (x < 11) or (x > 88) dans MiseAJourDeLaPartie,  x = ',x);
					     WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
					     WritelnDansRapport('  jeu : ');
               WritelnPositionEtTraitDansRapport(jeu,coul);

               WritelnDansRapport('  jeuDepart : ');
               WritelnPositionEtTraitDansRapport(jeuDepart,traitDepart);

               WritelnDansRapport('  partieEnAlphaDepart = '+partieEnAlphaDepart);
					     AttendFrappeClavier;
					   end;

					 if (jeu[x] <> pionVide) then
					   begin
					     WritelnNumDansRapport('ASSERT : (jeu[x] <> pionVide) dans MiseAJourDeLaPartie,  x = ',x);
					     WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
					     WritelnDansRapport('  jeu : ');
               WritelnPositionEtTraitDansRapport(jeu,coul);

               WritelnDansRapport('  jeuDepart : ');
               WritelnPositionEtTraitDansRapport(jeuDepart,traitDepart);

               WritelnDansRapport('  partieEnAlphaDepart = '+partieEnAlphaDepart);
					     AttendFrappeClavier;
					   end;

		       if (x < 11) or (x > 88) or (jeu[x] <> pionVide)
		         then
		           encorePossible := false
		         else
		           begin
    		         if PeutJouerIci(coul,x,Jeu)
      		         then
      		           begin
      		             err := JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = CoupFinal),fonctionAppelante + ' MiseAJourDeLaPartie(1)');

      		             if err <> NoErr then
      		               begin
      		                 WritelnNumDansRapport('ASSERT : (err <> NoErr) dans MiseAJourDeLaPartie(1),  err = ',err);
      		                 WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
      		                 WritelnDansRapport('  jeu : ');
                           WritelnPositionEtTraitDansRapport(jeu,coul);

                           WritelnDansRapport('  jeuDepart : ');
                           WritelnPositionEtTraitDansRapport(jeuDepart,traitDepart);

                           WritelnDansRapport('  partieEnAlphaDepart = '+partieEnAlphaDepart);

      		               end;


      		             bidbool := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
      		             numeroDuPlusGrandCoupLegal := i;
      		             coul := -coul;
      		           end
      		         else
      		           begin
      		             if PeutJouerIci(-coul,x,jeu)
      		              then
      		               begin
      		                 coul := -coul;
      		                 err := JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = CoupFinal),fonctionAppelante + ' MiseAJourDeLaPartie(2)');

      		                 if err <> NoErr then
          		               begin
          		                 WritelnNumDansRapport('ASSERT : (err <> NoErr) dans MiseAJourDeLaPartie(2),  err = ',err);
          		                 WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
          		                 WritelnDansRapport('  jeu : ');
                               WritelnPositionEtTraitDansRapport(jeu,coul);

                               WritelnDansRapport('  jeuDepart : ');
                               WritelnPositionEtTraitDansRapport(jeuDepart,traitDepart);

                               WritelnDansRapport('  partieEnAlphaDepart = '+partieEnAlphaDepart);
          		               end;

      		                 bidbool := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
      		                 coul := -coul;
      		                 numeroDuPlusGrandCoupLegal := i;
      		               end
      		              else
      		               begin
      		                 encorePossible := false;
      		               end;
      		           end;
		           end;
		      end;
     end;
   end;

  if EnModeEntreeTranscript then
    begin
      SetTranscriptAccepteLesDonnees(transcriptAccepteLesDonneesTemp,bidbool);
      EntrerPartieDansCurrentTranscript(numeroDuPlusGrandCoupLegal);
    end;

  gameNodeLePlusProfondGenere := GetCurrentNode;
  DoChangeCurrentNodeBackwardUntil(GameNodeAAtteindre);
  MarquerCurrentNodeCommeReel(fonctionAppelante + ' MiseAJourDeLaPartie');

  DessineCourbe(kCourbeColoree,fonctionAppelante + ' MiseAJourDeLaPartie');
	DessineSliderFenetreCourbe;

  EnableItemPourCassio(PartieMenu,ForwardCmd);

  SetUsingZebraBook(usingZebraBookArrivee);

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;


procedure UpdateGameByMainBranchFromCurrentNode(nroDernierCoupAtteintMAJ : SInt16;
																								jeuMAJ : plateauOthello;
																								jouableMAJ : plBool;
																								frontMAJ : InfoFront;
																								nbBlancsMAJ,nbNoirsMAJ : SInt64;
																								traitMAJ,nbreCoupMAJ : SInt16;
																								fonctionAppelante : String255);
var noeudActuel,GameNodeTerminal : GameTree;
    partieCompleteVoulue : String255;
    lignePrincipaleFromNow : String255;
    PartieJusquAPresent : String255;
    numeroCoupAAtteindre,numeroPremierCoupJoue : SInt64;
    positionInitiale : plateauOthello;
    nbBlancsInitial,nbNoirsInitial : SInt64;
    traitInitial : SInt64;
    transcriptAccepteLesDonneesTemp : boolean;
    bidbool : boolean;
    oldCheckDangerousEvents : boolean;
begin

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  noeudActuel := GetCurrentNode;
  if (NumberOfRealSons(noeudActuel) > 0) then
    begin
      lignePrincipaleFromNow := CoupsOfMainLineInGameTreeEnString(GetOlderSon(noeudActuel));
      if lignePrincipaleFromNow <> '' then
        begin
          PartieJusquAPresent := CoupsDuCheminJusquauNoeudEnString(noeudActuel);
          partieCompleteVoulue := PartieJusquAPresent+lignePrincipaleFromNow;
          numeroCoupAAtteindre := nroDernierCoupAtteintMAJ + (LENGTH_OF_STRING(lignePrincipaleFromNow) div 2);
          if traitMAJ = pionVide then
            begin
              GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoupJoue,traitInitial,nbBlancsInitial,nbNoirsInitial);
              traitMAJ := CalculeLeTraitApresTelCoup(nroDernierCoupAtteintMAJ-numeroPremierCoupJoue+1,partieCompleteVoulue,positionInitiale,traitInitial);

              if debuggage.arbreDeJeu then
                begin
		              EssaieSetPortWindowPlateau;
		              EcritPositionAt(positionInitiale,10,10);
		              EcritPositionAt(jeuMAJ,200,10);
		              WriteStringAt('partie jusqu''a présent = '+ PartieJusquAPresent+'      ',10,120);
		              WriteStringAt('partieCompleteVoulue = '+ partieCompleteVoulue+'       ',10,130);
		              WriteNumAt('nroDernierCoupAtteintMAJ = ',nroDernierCoupAtteintMAJ,10,140);
		              WriteNumAt('numeroCoupAAtteindre = ',numeroCoupAAtteindre,10,150);
		              WriteNumAt('numeroPremierCoupJoue = ',numeroPremierCoupJoue,10,160);
		              case TraitInitial of
		                pionBlanc : WriteStringAt('trait initial =  pionBlanc  ',10,170);
		                pionNoir  : WriteStringAt('trait initial =  pionNoir   ',10,170);
		                otherwise   WriteStringAt('trait initial inconnu !!  ',10,170);
		              end;
		              case traitMAJ of
		                pionBlanc : WriteStringAt('traitMAJ =  pionBlanc  ',10,180);
		                pionNoir  : WriteStringAt('traitMAJ =  pionNoir   ',10,180);
		                otherwise   WriteStringAt('traitMAJ inconnu !!  ',10,180);
		              end;
		              WriteNumAt('nbreCoupMAJ = ',nbreCoupMAJ,10,190);
		            end;

            end;

          if EnModeEntreeTranscript then SetTranscriptAccepteLesDonnees(false,transcriptAccepteLesDonneesTemp);
          MiseAJourDeLaPartie(partieCompleteVoulue,jeuMAJ,jouableMAJ,frontMAJ,
                             nbBlancsMAJ,nbNoirsMAJ,traitMAJ,nbreCoupMAJ,false,
                             numeroCoupAAtteindre,GameNodeTerminal,fonctionAppelante + ' UpdateGameByMainBranchFromCurrentNode');
          if EnModeEntreeTranscript then SetTranscriptAccepteLesDonnees(transcriptAccepteLesDonneesTemp,bidbool);
        end;
    end;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;


procedure TachesUsuellesPourAffichageCourant;
var square : SInt64;
begin
  if afficheNumeroCoup and (nbreCoup > 0) then
    begin
      square := DerniereCaseJouee;
      if InRange(square,11,88) then
        DessineNumeroCoup(square,nbreCoup,-GetCouleurOfSquareDansJeuCourant(square),GetCurrentNode);
    end;

  SetEffacageProprietesOfCurrentNode(kToutesLesProprietes);
  SetAffichageProprietesOfCurrentNode(kToutesLesProprietes);
  LanceDemandeAffichageZebraBook('TachesUsuellesPourAffichageCourant');
  AfficheProprietesOfCurrentNode(false,othellierToutEntier,'TachesUsuellesPourAffichageCourant');
  EcritCurrentNodeDansFenetreArbreDeJeu(true,true);

  AjusteCurseur;
  MetTitreFenetrePlateau;

  if CassioEstEnModeSolitaire then EcritCommentaireSolitaire;
  if (HumCtreHum or (nbreCoup <= 0) or (AQuiDeJouer <> couleurMacintosh)) and not(enTournoi) then
    begin
      MyDisableItem(PartieMenu,ForceCmd);
      AfficheDemandeCoup;
    end;

  if DoitAfficherBibliotheque then EcritCoupsBibliotheque(othellierToutEntier);
  if afficheInfosApprentissage then EcritLesInfosDApprentissage;

  phaseDeLaPartie := CalculePhasePartie(nbreCoup);
  FixeMarqueSurMenuMode(nbreCoup);

  if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
    then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
end;


procedure RejouePartieOthello(s : String255; coupMax : SInt16;
                              positionDepartStandart : boolean;
                              platImpose : plateauOthello; traitImpose : SInt16;
                              var gameNodeLePlusProfondGenere : GameTree;
                              peutDetruireArbreDeJeu : boolean;
                              avecNomsOuvertureDansArbre : boolean);
var i,x,t,mobilite,aux,trait : SInt64;
    oldPort : grafPtr;
    temposon,tempoAfficheBibl : boolean;
    tempoCalculsActives : boolean;
    tempoAfficheNumeroCoup : boolean;
    tempoAfficheInfosApprentissage : boolean;
    tempoAlerteNouvelleInterversion : boolean;
    nbreCoupsRepris : SInt16;
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    estLegal : boolean;
    tempoAvecDelaiDeRetournementDesPions : boolean;
    tempoEnTrainDeRejouerUnePartie : boolean;
    tickFinal : UInt32;
    tickChrono : UInt32;
    usingZebraBookArrivee : boolean;
    current : PositionEtTraitRec;
begin

   (*
   WritelnDansRapport('paramêtres d''entrée dans RejouePartieOthello :');
   WritelnDansRapport('s = '+s);
   WritelnNumDansRapport('coupMax = ',coupMax);
   WritelnStringAndBoolDansRapport('positionDepartStandart = ',positionDepartStandart);
   WritelnDansRapport('platImpose, traitImpose :');
   WritelnPositionEtTraitDansRapport(platImpose,traitImpose);
   WritelnStringAndBoolDansRapport('peutDetruireArbreDeJeu = ',peutDetruireArbreDeJeu);
   WritelnStringAndBoolDansRapport('avecNomsOuvertureDansArbre = ',avecNomsOuvertureDansArbre);
   *)

   BeginFonctionModifiantNbreCoup('RejouePartieOthello');

   CompacterPartieAlphanumerique(s,kCompacterTelQuel);

   BeginUseZebraNodes('RejouePartieOthello');
   usingZebraBookArrivee := GetUsingZebraBook;
   SetUsingZebraBook(false);

   tickChrono := TickCount;

   temposon := avecSon;
   tempoAfficheBibl := afficheBibl;
   tempoCalculsActives := false;
   tempoAfficheNumeroCoup := afficheNumeroCoup;
   tempoAfficheInfosApprentissage := afficheInfosApprentissage;
   tempoAlerteNouvelleInterversion := avecAlerteNouvInterversion;
   tempoAvecDelaiDeRetournementDesPions := avecDelaiDeRetournementDesPions;
   tempoEnTrainDeRejouerUnePartie := EnTrainDeRejouerUnePartie;
   avecSon := false;
   afficheBibl := false;
   avecCalculPartiesActives := false;
   afficheNumeroCoup := false;
   afficheInfosApprentissage := false;
   avecAlerteNouvInterversion := false;
   avecDelaiDeRetournementDesPions := false;
   SetEnTrainDeRejouerUnePartie(true);


   EffaceProprietesOfCurrentNode;
   ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),othellierToutEntier);
   SetEffacageProprietesOfCurrentNode(kAucunePropriete);
   SetAffichageProprietesOfCurrentNode(kAucunePropriete);

   oldPositionFeerique := positionFeerique;
   positionFeerique := not(positionDepartStandart);
   peutfeliciter := true;
 (*if avecDessinCoupEnTete then EffaceCoupEnTete;
   SetCoupEntete(0);*)
   PartieContreMacDeBoutEnBout := false;
   gameOver := false;
   enSetUp := false;
   enRetour := false;
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;


   LanceInterruptionSimpleConditionnelle('RejouePartieOthello');
   vaDepasserTemps := false;
   reponsePrete := false;
   ViderValeursDeLaCourbe;
   MemoryFillChar(@emplJouable,sizeof(emplJouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
   MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));

   doitDetruireAncienArbreDeJeu := peutDetruireArbreDeJeu and (positionFeerique or oldPositionFeerique);
   ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);

   VideMeilleureSuiteInfos;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   EssaieDisableForceCmd;
   if avecInterversions then PreouvrirGraphesUsuels;

   EffacerTouteLaCourbe('RejouePartieOthello');
   DessineSliderFenetreCourbe;

   if not(windowPlateauOpen) then OuvreFntrPlateau(false);
   GetPort(oldPort);
   SetPortByWindow(wPlateauPtr);

   DessinePlateau(true);
   if positionDepartStandart
     then
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthello {1}');

         SetPositionInitialeStandardDansJeuCourant;
         InitialiseDirectionsJouables;
         PosePion(54,pionNoir);
         PosePion(45,pionNoir);
         PosePion(55,pionBlanc);
         PosePion(44,pionBlanc);
         CarteJouable(JeuCourant,emplJouable);
         nbreDePions[pionNoir] := 2;
         nbreDePions[pionBlanc] := 2;

         SetPositionInitialeStandardDansGameTree;
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant,GetRacineDeLaPartie);


         nbreCoup := 0;
         nroDernierCoupAtteint := 0;
         IndexProchainFilsDansGraphe := -1;
       end
     else
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthello {2}');

         for i := 0 to 99 do
           if interdit[i] then platImpose[i] := PionInterdit;
         nbreDePions[pionNoir] := 0;
         nbreDePions[pionBlanc] := 0;
         for t := 1 to 64 do
           begin
             x := othellier[t];
             aux := platImpose[x];
             if (aux = pionNoir) or (aux = pionBlanc)
               then
                 begin
                   DessinePion(x,aux);
                   nbreDePions[aux] := nbreDePions[aux]+1;
                 end;
           end;
         if odd(nbreDePions[pionNoir]+nbreDePions[pionBlanc])
           then trait := pionBlanc
           else trait := pionNoir;
         if (traitImpose = pionNoir) or (traitImpose = pionBlanc) then trait := traitImpose;

         SetJeuCourant(platImpose, trait);


         SetPositionInitialeOfGameTree(JeuCourant,AQuiDeJouer,nbreDePions[pionBlanc],nbreDePions[pionNoir]);
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant,GetRacineDeLaPartie);

         InitialiseDirectionsJouables;
         CarteJouable(JeuCourant,emplJouable);

         nbreCoup := nbreDePions[pionNoir]+nbreDePions[pionBlanc]-4;
         nroDernierCoupAtteint := nbreCoup;
         IndexProchainFilsDansGraphe := -1;
       end;

   if EnVieille3D then Dessine3D(JeuCourant,false);
   aideDebutant := false;
   Calcule_Valeurs_Tactiques(JeuCourant,true);
   MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));
   CarteFrontiere(JeuCourant,frontiereCourante);
   AfficheScore;
   MyDisableItem(PartieMenu,ForceCmd);
   if avecAleatoire then RandomizeTimer;
   AjusteCadenceMin(GetCadence);
   DessineBoiteDeTaille(wPlateauPtr);
   dernierTick := TickCount;
   Heure(pionNoir);
   Heure(pionBlanc);
   InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);


   nbreCoupsRepris := LENGTH_OF_STRING(s) div 2;
   if nbreCoupsRepris > coupMax then nbreCoupsRepris := coupMax;

   tickFinal := TickCount;
   for i := 1 to nbreCoupsRepris do
     begin
       SetUsingZebraBook(false);
       x := PositionDansStringAlphaEnCoup(s,2*i-1);
       if (nbreCoup < coupMax) and (x >= 11) and (x <= 88) then
         begin
           if EstEnTrainDeRejouerUneInterversion then
             begin
               FlushWindow(wPlateauPtr);
               if LongueurInterversionEnTrainDEtreRejouee <= 20
                 then Delay(7, tickFinal)
                 else Delay(1, tickFinal);
             end;

           if PeutJouerIci(AQuiDeJouer,x,JeuCourant) and
              JoueEn(x,PositionEtTraitCourant,estLegal,avecNomsOuvertureDansArbre,(nbreCoup = nbreCoupsRepris - 1),'RejouePartieOthello' )
              then
                DoNothing
              else
               if (AQuiDeJouer = pionVide) then TachesUsuellesPourGameOver;

           if avecInterversions and (nbreCoup >= 1) and (nbreCoup <= numeroCoupMaxPourRechercheIntervesionDansArbre)
	            then
	              begin
	                current := PositionEtTraitCourant;
	                GererInterversionDeCeNoeud(GetCurrentNode,current);
	              end;
         end;
     end;

   gameNodeLePlusProfondGenere := GetCurrentNode;


   afficheNumeroCoup := tempoAfficheNumeroCoup;


   CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
   if mobilite = 0 then TachesUsuellesPourGameOver;

   Initialise_table_heuristique(JeuCourant,false);

   avecSon := temposon;
   afficheBibl := tempoAfficheBibl;
   afficheInfosApprentissage := tempoAfficheInfosApprentissage;
   avecAlerteNouvInterversion := tempoAlerteNouvelleInterversion;
   avecDelaiDeRetournementDesPions := tempoAvecDelaiDeRetournementDesPions;
   SetEnTrainDeRejouerUnePartie(tempoEnTrainDeRejouerUnePartie);



   avecCalculPartiesActives := true;
   gDoitJouerMeilleureReponse := false;

   {EffacerTouteLaCourbe('RejouePartieOthello');
   DessineCourbe(kCourbeColoree,'RejouePartieOthello');}

   if avecInterversions then FermerGraphesUsuels;

   SetUsingZebraBook(usingZebraBookArrivee);
   EndUseZebraNodes('RejouePartieOthello');

   TachesUsuellesPourAffichageCourant;

   EndFonctionModifiantNbreCoup('RejouePartieOthello');

   {WritelnNumDansRapport('temps = ',TickCount - tickChrono);}

   SetPort(oldPort);
end;


procedure RejouePartieOthelloFictive(s : String255; coupMax : SInt16;
                                     positionDepartStandart : boolean;
                                     platImpose : plateauOthello; traitImpose : SInt16;
                                     var gameNodeLePlusProfondGenere : GameTree;
                                     flags : SInt64);
var jeu : plateauOthello;
    jouable : plBool;
    front : InfoFront;
    nbBlanc,nbNoir,coul : SInt64;
    i,x,t,mobilite,aux : SInt64;
    nbreCoupsRepris : SInt16;
    oldPositionFeerique : boolean;
    doitDetruireAncienArbreDeJeu : boolean;
    coupLegal : boolean;
    usingZebraBookArrivee : boolean;
begin
   BeginFonctionModifiantNbreCoup('RejouePartieOthelloFictive');

   BeginUseZebraNodes('RejouePartieOthelloFictive');
   usingZebraBookArrivee := GetUsingZebraBook;
   SetUsingZebraBook(false);

   CompacterPartieAlphanumerique(s,kCompacterTelQuel);

   oldPositionFeerique := positionFeerique;
   positionFeerique := not(positionDepartStandart);
   peutfeliciter := true;
   (*SetCoupEntete(0);*)
   gameOver := false;
   PartieContreMacDeBoutEnBout := false;
   DetermineMomentFinDePartie;
   phaseDeLaPartie := CalculePhasePartie(0);
   humainVeutAnnuler := false;
   RefleSurTempsJoueur := false;
   LanceInterruptionSimpleConditionnelle('RejouePartieOthelloFictive');
   vaDepasserTemps := false;
   reponsePrete := false;
   ViderValeursDeLaCourbe;
   MemoryFillChar(@jouable,sizeof(jouable),chr(0));
   MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
   MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
   MemoryFillChar(@tableHeurisNoir,sizeof(tableHeurisNoir),chr(0));
   MemoryFillChar(@tableHeurisBlanc,sizeof(tableHeurisBlanc),chr(0));

   doitDetruireAncienArbreDeJeu := ((flags and kPeutDetruireArbreDeJeu) <> 0) and (positionFeerique or oldPositionFeerique);
   ReInitialisePartieHdlPourNouvellePartie(doitDetruireAncienArbreDeJeu);

   VideMeilleureSuiteInfos;
   MyDisableItem(PartieMenu,ForwardCmd);
   Superviseur(nbreCoup);
   FixeMarqueSurMenuMode(nbreCoup);
   EssaieDisableForceCmd;

   if positionDepartStandart
     then
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthelloFictive {1}');

         MemoryFillChar(@jeu,sizeof(jeu),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeu[i] := PionInterdit;
         jeu[54] := pionNoir;
         jeu[45] := pionNoir;
         jeu[55] := pionBlanc;
         jeu[44] := pionBlanc;
         InitialiseDirectionsJouables;
         CarteJouable(jeu,jouable);
         coul := pionNoir;
         nbNoir := 2;
         nbBlanc := 2;

         SetPositionInitialeStandardDansGameTree;
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
            AjouteDescriptionPositionEtTraitACeNoeud(MakePositionEtTrait(jeu,coul),GetRacineDeLaPartie);

         nbreCoup := 0;
         nroDernierCoupAtteint := 0;
         IndexProchainFilsDansGraphe := -1;
       end
     else
       begin
         SetCurrentNodeToGameRoot;
         MarquerCurrentNodeCommeReel('RejouePartieOthelloFictive {2}');

         MemoryFillChar(@jeu,sizeof(jeu),chr(0));
         for i := 0 to 99 do
           if interdit[i] then jeu[i] := PionInterdit;
         nbNoir := 0;
         nbBlanc := 0;
         for t := 1 to 64 do
           begin
             x := othellier[t];
             aux := platImpose[x];
             jeu[x] := aux;
             if (aux = pionNoir) then inc(nbNoir);
             if (aux = pionBlanc) then inc(nbBlanc);
           end;
         if odd(nbNoir+nbBlanc)
           then coul := pionBlanc
           else coul := pionNoir;
         if traitImpose <> 0 then coul := traitImpose;

         SetPositionInitialeOfGameTree(jeu,coul,nbBlanc,nbNoir);
         AddInfosStandardsFormatSGFDansArbre;
         if doitDetruireAncienArbreDeJeu then
           AjouteDescriptionPositionEtTraitACeNoeud(MakePositionEtTrait(jeu,coul),GetRacineDeLaPartie);

         InitialiseDirectionsJouables;
         CarteJouable(jeu,jouable);

         nbreCoup := nbNoir+nbBlanc-4;
         nroDernierCoupAtteint := nbreCoup;
         IndexProchainFilsDansGraphe := -1;
       end;

   Calcule_Valeurs_Tactiques(jeu,true);
   MemoryFillChar(@possibleMove,sizeof(possibleMove),chr(0));
   CarteFrontiere(jeu,front);
   MyDisableItem(PartieMenu,ForceCmd);
   if avecAleatoire then RandomizeTimer;
   AjusteCadenceMin(GetCadence);
   dernierTick := TickCount;

   nbreCoupsRepris := LENGTH_OF_STRING(s) div 2;
   if nbreCoupsRepris > coupMax then nbreCoupsRepris := coupMax;
   for i := 1 to nbreCoupsRepris do
     begin
       SetUsingZebraBook(false);
       x := PositionDansStringAlphaEnCoup(s,2*i-1);
       if (x >= 11) and (x <= 88) then
         begin
          if PeutJouerIci(coul,x,jeu)
            then
              begin
                if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoupsRepris),'RejouePartieOthelloFictive(1)') = NoErr then DoNothing;
                coupLegal := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
                coul := -coul;
              end
            else
              begin
                if PeutJouerIci(-coul,x,jeu)
                 then
                   begin
                     coul := -coul;
                     if JoueEnFictif(x,coul,jeu,jouable,front,nbblanc,nbNoir,i-1,true,(i = nbreCoupsRepris),'RejouePartieOthelloFictive(2)') = NoErr then DoNothing;
                     coupLegal := ModifPlat(x,coul,jeu,jouable,nbblanc,nbNoir,front);
                     coul := -coul;
                   end
                 else
                   TachesUsuellesPourGameOver;
              end;
          end;
     end;

   gameNodeLePlusProfondGenere := GetCurrentNode;

   MetTitreFenetrePlateau;
   nbreCoup := nbreCoupsRepris;
   IndexProchainFilsDansGraphe := -1;
   SetJeuCourant(jeu, coul);
   emplJouable := jouable;
   frontiereCourante := front;
   nbreDePions[pionNoir] := nbNoir;
   nbreDePions[pionBlanc] := nbBlanc;


   CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
   if mobilite = 0 then TachesUsuellesPourGameOver;


   LanceInterruptionSimpleConditionnelle('RejouePartieOthelloFictive');

   AjusteCurseur;

   DessineCourbe(kCourbeColoree,'RejouePartieOthelloFictive');
	 DessineSliderFenetreCourbe;


   Initialise_table_heuristique(JeuCourant,false);
   if (HumCtreHum or (AQuiDeJouer <> couleurMacintosh)) and not(enTournoi) then MyDisableItem(PartieMenu,ForceCmd);
   avecCalculPartiesActives := true;
   gDoitJouerMeilleureReponse := false;

   SetUsingZebraBook(usingZebraBookArrivee);
   EndUseZebraNodes('RejouePartieOthelloFictive');

   EndFonctionModifiantNbreCoup('RejouePartieOthelloFictive');

   if afficheInfosApprentissage then EcritLesInfosDApprentissage;
   if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
     then LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);

   LanceInterruptionSimpleConditionnelle('RejouePartieOthelloFictive');

   TachesUsuellesPourAffichageCourant;

end;



function ResynchronisePartieEtCurrentNode(ApresQuelCoup : SInt16) : OSErr;
var position : plateauOthello;
    OldCurrentNode : GameTree;
    trait,coup,numeroPremierCoup,nbBlancs,nbNoirs,i,nbFilsDetruits,TraitCourant : SInt64;
    erreurES : OSErr;
    ok : boolean;
begin
  erreurES := 0;
  ResynchronisePartieEtCurrentNode := 0;

  oldCurrentNode := GetCurrentNode;
  SetCurrentNodeToGameRoot;
  GetPositionInitialeOfGameTree(position,numeroPremierCoup,trait,nbBlancs,nbNoirs);

  TraitCourant := 0;
  ok := true;
  i := numeroPremierCoup;
  repeat
    ok := (trait = GetCouleurNiemeCoupPartieCourante(i));
    coup := GetNiemeCoupPartieCourante(i);
    ok := ok and (position[coup] = pionVide);
    if ok then
      begin
		    if not(ModifPlatSeulement(coup,position,trait))
		      then ok := false
		      else
		        begin
		          ok := true;
		          if not(DoitPasserPlatSeulement(-trait,position))
		            then trait := -trait
		            else if DoitPasserPlatSeulement(trait,position)
		                   then trait := pionVide;  {partie finie !}
		        end;
		    if (i = ApresQuelCoup) then TraitCourant := trait;
		  end;
		(* WritelnStringAndboolDansRapport('coup n°'+IntToStr(i)+' : '+CoupEnString(coup,true)+' ==> ',ok); *)
    i := succ(i);
  until not(ok) or (i > ApresQuelCoup);

  if not(ok) then
    begin
      SetCurrentNode(oldCurrentNode, 'ResynchronisePartieEtCurrentNode {1}');
      ResynchronisePartieEtCurrentNode := -1;
      exit;
    end;



  for i := numeroPremierCoup to ApresQuelCoup do
    begin
      coup := GetNiemeCoupPartieCourante(i);
      trait := GetCouleurNiemeCoupPartieCourante(i);

      nbFilsDetruits := DeleteSonsOfThatColorInCurrentNode(-trait);

      erreurES := ChangeCurrentNodeAfterNewMove(coup,trait,'ResynchronisePartieEtPositionCourante');
      (* WritelnNumDansRapport('coup n°'+IntToStr(i)+' : '+CoupEnString(coup,true)+' ==> ',erreurES);
      *)
      if erreurES <> 0 then
        begin
          SetCurrentNode(oldCurrentNode, 'ResynchronisePartieEtCurrentNode {2}');
          ResynchronisePartieEtCurrentNode := erreurES;
          exit;
        end;
    end;

  nbFilsDetruits := DeleteSonsOfThatColorInCurrentNode(-TraitCourant);
end;



procedure PlaquerPosition(plat : plateauOthello; trait : SInt16; flags : SInt64);
var t,i : SInt16;
    mobilite : SInt64;
begin
    ViderNotesSurCases(kNotesDeCassioEtZebra,true,othellierToutEntier);
    InvalidateDessinEnTraceDeRayon(DerniereCaseJouee);
    ReInitialisePartieHdlPourNouvellePartie(true);
    CommentaireSolitaire^^ := '';
    SetMeilleureSuite('');
    finaleEnModeSolitaire := false;
    ViderValeursDeLaCourbe;
    for i := 0 to 99 do
        if interdit[i] then plat[i] := PionInterdit;
    nbreDePions[pionNoir] := 0;
    nbreDePions[pionBlanc] := 0;
    for i := 1 to 64 do
      begin
        t := othellier[i];
        if plat[t] <> pionVide then
          nbreDePions[plat[t]] := nbreDePions[plat[t]]+1;
      end;
    nbreCoup := nbreDePions[pionNoir]+nbreDePions[pionBlanc]-4;
    nroDernierCoupAtteint := nbreCoup;
    IndexProchainFilsDansGraphe := -1;
    phaseDeLaPartie := CalculePhasePartie(nbreCoup);
    MyDisableItem(PartieMenu,ForwardCmd);
    FixeMarqueSurMenuMode(nbreCoup);
    CarteJouable(plat,emplJouable);
    if (trait = pionNoir) or (trait = pionBlanc)
      then trait := trait
      else
        if odd(nbreCoup)
           then trait := pionBlanc
           else trait := pionNoir;

    SetJeuCourant(plat, trait);


    peutfeliciter := true;
   (*SetCoupEntete(0);*)
    gameOver := false;

    if AQuiDeJouer = pionVide then
      begin
        gameOver := true;
        EffaceMeilleureSuite;
      end;

    MetTitreFenetrePlateau;
    InvalidateAnalyseDeFinaleSiNecessaire(kForceInvalidate);

    EffaceProprietesOfCurrentNode;
    SetPositionInitialeOfGameTree(JeuCourant,AQuiDeJouer,nbreDePions[pionBlanc],nbreDePions[pionNoir]);
    AddInfosStandardsFormatSGFDansArbre;
    AjouteDescriptionPositionEtTraitACeNoeud(PositionEtTraitCourant,GetRacineDeLaPartie);

    CarteMove(AQuiDeJouer,JeuCourant,possibleMove,mobilite);
    CarteFrontiere(JeuCourant,frontiereCourante);
    Initialise_table_heuristique(JeuCourant,false);
    meilleurCoupHum := 0;
    RefleSurTempsJoueur := false;
    LanceInterruptionSimpleConditionnelle('PlaquerPosition');
		LanceInterruptionConditionnelle(interruptionSimple,'SET_REPONSEPRETE',0,'PlaquerPosition');
    LanceInterruptionConditionnelle(interruptionSimple,'SET_VADEPASSERTEMPS',0,'PlaquerPosition');
    vaDepasserTemps := false;
    reponsePrete := false;
    positionFeerique := not(EstLaPositionStandardDeDepart(JeuCourant) and (AQuiDeJouer = PionNoir));
    if positionFeerique then nbPartiesActives := 0;
    PartieContreMacDeBoutEnBout := not(positionFeerique);
    MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
    MemoryFillChar(@inverseVideo,sizeof(inverseVideo),chr(0));
    VideMeilleureSuiteInfos;
    LireBibliothequeDeZebraPourCurrentNode('PlaquerPosition');
    aidedebutant := false;
    dernierTick := TickCount;
    EssaieDisableForceCmd;
    if windowPlateauOpen then
      begin
        if ((flags and kRedessineEcran) <> 0) then
          begin
            EcranStandard(NIL,false);
            NoUpdateWindowPlateau;
          end;
      end;
    if (windowListeOpen or windowStatOpen) then
      begin
        LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
      end;

    EffacerTouteLaCourbe('PlaquerPosition');
    DessineCourbe(kCourbeColoree,'PlaquerPosition');
    DessineSliderFenetreCourbe;

    DessineBoiteDeTaille(wPlateauPtr);
    AjusteCurseur;
    RefletePositionCouranteDansPictureIconisation;
    gDoitJouerMeilleureReponse := false;
    PartieContreMacDeBoutEnBout := false;

    LanceInterruptionSimpleConditionnelle('PlaquerPosition');
end;


procedure PlaquerPositionEtPartie(position : PositionEtTraitRec; partieAlphaCompactee : String255; flags : SInt64);
var i : SInt16;
    gameNodeLePlusProfond : GameTree;
    oldCheckDangerousEvents : boolean;
begin

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  {la position initiale}
  if not(EstLaPositionInitialeDeLaPartieEnCours(position))
    then PlaquerPosition(position.position,GetTraitOfPosition(position),kRedessineEcran);

  {on rejoue la partie, qui doit etre legale à partir de position}
  if positionFeerique
    then
      begin
        for i := 1 to (60-NbCasesVidesDansPosition(position.position)) do
          partieAlphaCompactee := '  '+partieAlphaCompactee;

        RejouePartieOthello(partieAlphaCompactee,LENGTH_OF_STRING(partieAlphaCompactee) div 2,false,
                            position.position,GetTraitOfPosition(position),gameNodeLePlusProfond,false,false);
      end
    else
      PlaquerPartieLegale(partieAlphaCompactee,flags);


  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  finaleEnModeSolitaire := false;

  RefletePositionCouranteDansPictureIconisation;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;



procedure PlaquerPartieLegale(partieAlphaCompactee : String255; flags : SInt64);
var gameNodeLePlusProfond : GameTree;
    tempoAfficheDernierCoup : boolean;
    oldCheckDangerousEvents : boolean;
begin

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  {WritelnDansRapport('dans PlaquerPartieLegale, partieAlphaCompactee = '+partieAlphaCompactee);}

  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  finaleEnModeSolitaire := false;

  NoUpdateWindowPlateau;

  if ((flags and kRejouerLesCoupsEnDirect) <> 0)
    then
      RejouePartieOthello(partieAlphaCompactee,LENGTH_OF_STRING(partieAlphaCompactee) div 2,true,bidplat,0,gameNodeLePlusProfond,true,true)
    else
      begin
        tempoAfficheDernierCoup := afficheNumeroCoup;
        if afficheNumeroCoup then afficheNumeroCoup := false;

        PlaquerPositionEtPartieLegaleDansOthellierDeGauche(PositionEtTraitInitiauxStandard,partieAlphaCompactee);

        NoUpdateWindowPlateau;
        TachesUsuellesPourAffichageCourant;
        NoUpdateWindowPlateau;
        if tempoAfficheDernierCoup then DoChangeAfficheDernierCoup;
      end;

  NoUpdateWindowPlateau;

  RefletePositionCouranteDansPictureIconisation;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;


function PlaquerPositionEtPartieFictive(initialPosition, moves : String255; nbreCoupsRepris : SInt64) : OSErr;
var whichPos : PositionEtTraitRec;
    noeud : GameTree;
begin
  PlaquerPositionEtPartieFictive := -1;

  if ParsePositionEtTrait(initialPosition, whichPos) then
    begin

      EffaceAideDebutant(false,true,othellierToutEntier,'PlaquerPositionEtPartieFictive');
      EffaceProprietesOfCurrentNode;
      ViderNotesSurCases(kNotesDeCassioEtZebra,GetAvecAffichageNotesSurCases(kNotesDeCassioEtZebra),CoupsLegauxEnSquareSet);
      RejouePartieOthelloFictive(moves,
                                 nbreCoupsRepris,
                                 EstLaPositionInitialeStandard(whichPos),
                                 whichPos.position,
                                 GetTraitOfPosition(whichPos),
                                 noeud,
                                 kPeutDetruireArbreDeJeu);
      DrawContents(wPlateauPtr);


      (* code plus lent, équivalent aux cinq lignes précédentes *)
      (* if ComprendPositionEtPartieDuFichier('', initialPosition + ' ' + moves, true) <> NoErr then; *)


      PlaquerPositionEtPartieFictive := NoErr;

    end;

end;

{$R-}

END.






















