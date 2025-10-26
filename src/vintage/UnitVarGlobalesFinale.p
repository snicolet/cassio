UNIT UnitVarGlobalesFinale;


INTERFACE










USES UnitOth0,UnitBitboardTypes,UnitDefGameTree,UnitDefPositionEtTrait;



type DoubleArray = array[0..0] of Double;  {pour pouvoir copier 8 octets ˆ la fois}
     DoubleArrayPtr = ^DoubleArray;
     LongintArray = array[0..0] of SInt32; {pour pouvoir copier 4 octets ˆ la fois}
     LongintArrayPtr = ^LongintArray;


     MakeEndgameSearchResultRec =
       record
         outBestMoveFinale                    : SInt32;
         outBestDefenseFinale                 : SInt32;
         outScoreFinale                       : SInt32;
         outTimeTakenFinale                   : TypeReel;
         outDernierMuVariant                  : SInt32;
         outLineFinale                        : String255;
       end;


     MakeEndgameSearchParamRec =
       record
         inTypeCalculFinale                   : SInt32;
         inCouleurFinale                      : SInt32;
         inProfondeurFinale                   : SInt32;
         inNbreBlancsFinale                   : SInt32;
         inNbreNoirsFinale                    : SInt32;
         inAlphaFinale                        : SInt32;
         inBetaFinale                         : SInt32;
         inMuMinimumFinale                    : SInt32;
         inMuMaximumFinale                    : SInt32;
         inPrecisionFinale                    : SInt32;
         inPrioriteFinale                     : SInt32;
         inHashValue                          : UInt64;
         inGameTreeNodeFinale                 : GameTree;
         inPositionPourFinale                 : plateauOthello;
         inMessageHandleFinale                : MessageFinaleHdl;
         inCommentairesDansRapportFinale      : boolean;
         inMettreLeScoreDansLaCourbeFinale    : boolean;
         inMettreLaSuiteDansLaPartie          : boolean;
         inDoitAbsolumentRamenerLaSuiteFinale : boolean;
         inDoitAbsolumentRamenerUnScoreFinale : boolean;
         outResult                            : MakeEndgameSearchResultRec;

       end;

   ZooJobRec = record
                  params            : MakeEndgameSearchParamRec;
                  endgameSolveFlags : SInt32;
                  comment           : String255;
                end;


type
  variablesMakeEndgameSearchRec =
     RECORD
        CoulPourMeilleurFin,coulDefense : SInt32;
        positionEtTraitDeMakeEndgameSearch : PositionEtTraitRec;
        emplacementsJouablesFinale : plBool;
        frontiereFinale : InfoFront;
        maxPourOrdonnancement : SInt32;
        classement : ListOfMoveRecords;
        valeurCible : SInt32;
        nbCoup : SInt32;
        infini : SInt32;
        defenseEndgameSearch : SInt32;
        MFniv : SInt32;
        endgameNode : GameTree;
        numeroEndgameTreeActif : SInt32;
        magicCookieEndgameTree : SInt32;
        clefHashageCoupGagnant : SInt32;
        dernierCoupJoue : SInt32;
        platClass : plateauOthello;
        jouableClass : plBool;
        nbBlancClass,nbNoirClass : SInt32;
        frontClass : InfoFront;
        noteClass : SInt32;
        suiteJouee : t_suiteJouee;
        meilleureSuite : t_meilleureSuite;
        typeDataDansHandle : SInt32;
        scoreDeNoir : SInt32;
        noCoupRecherche : SInt32;
        tempsGlobalDeLaFonction : SInt32;
        tickDepartDeLaFonction : SInt32;
        coupDontLeScoreEstConnu : SInt32;
        scoreDuCoupDontLeScoreEstConnu : SInt32;
        defenseDuCoupDontLeScoreEstConnu : SInt32;
        milieuFenetre : SInt32;
        profForceBrute : SInt32;
        profForceBrutePlusUn : SInt32;
        profPourTriSelonDivergence : SInt32;
        profondeurDepartPreordre,profondeurArretPreordre : SInt32;
        indexDuCoupDansFntrReflexion : SInt32;
        TickChrono : SInt32;
        err : OSStatus;
        InfosPourcentagesCertitudesAffiches:
          array[0..3] of record
                           mobiliteCetteProf : SInt32;
                           indexDuCoupCetteProf : SInt32;
                           PourcentageAfficheCetteProf : SInt32;
                         end;
        estimationPositionDApresMilieu : SInt32;
        mob : SInt32;
        move : plBool;
        bestMode : boolean;
        termine : boolean;
        passeDeRechercheAuMoinsValeurCible : boolean;
        FenetreLargePourRechercheScoreExact : boolean;
        resultatSansCalcul : boolean;
        bestmodeArriveeDansCoupGagnant : boolean;
        chainesDejaEcrites : StringSet;
        rechercheDejaAnnonceeDansRapport : boolean;
        coupGagnantUtiliseEndgameTrees : boolean;
        coupGagnantAUneFenetreAlphaBetaReduite : boolean;
        listeChaineeEstDisponibleArrivee : boolean;
        tempoUserCoeffDansNouvelleEval : boolean;
        dernierePasseTerminee : boolean;
        cassioEtaitEnTrainDeReflechir : boolean;
        passeEhancedTranspositionCutOffEstEnCours : boolean;
        meilleureSuiteCommeResultatDeMakeEndgameSearch : String255;
        infosPourMuVariant : MoveRecord;


    {$IFC USE_PROFILER_FINALE_FAST}
        nomFichierProfile : String255;
    {$ENDC}
 END;


const kNbreMaxDeltasSuccessifs = kNbreMaxDeltasSuccessifsDansHashExacte;  { = 10 }





var
    { stability_alpha[n] says for which value of alpha
      we should begin to try an stability cut-off at n empties }
    stability_alpha : array[0..64] of SInt32;


    (* degre d'approximations successifs *)
    nbreDeltaSuccessifs : SInt32;
    deltaSuccessifs : array[1..kNbreMaxDeltasSuccessifs] of
                        record
                          valeurDeMu       : SInt32;
                          selectiviteZebra : SInt32;
                        end;

    (* profEvaluationHeuristique[k] est la taille du sous-arbre local
       utilise pour l'evaluation heuristique quand il reste k cases vides *)
    profEvaluationHeuristique : array[0..64] of SInt32;


    deltaFinaleCourant : SInt32;
    indexDeltaFinaleCourant : SInt32;
    profFinaleHeuristique : SInt32;
    nbCoupuresHeuristiquesCettePasse : SInt32;
    maxEvalsRecursives : SInt32;
    dernierIndexDeltaRenvoye : SInt32;
    meilleureSuiteAEteCalculeeParOptimalite : boolean;
    scoreDuCoupCalculeParOptimalite : SInt32;

    {
    distanceFrontiereHeuristique : SInt32;
    profMinimalePourClassementParMilieuForcee : SInt32;
    }

    {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
    nbAppelsABFinPetite : array[0..64] of unsignedwide;
    nbNoeudsDansABFinPetite : array[0..64] of unsignedwide;
    tempoNbNoeudsDansABFinPetite : array[0..64] of UInt32;
    {$ENDC}

    nbNoeudsEstimes : array[0..64] of SInt32;


    usingEndgameTrees : boolean;

    profTriInterneEnFinale : array[0..64] of SInt32;
    (* profTriInterneEnFinale[k] dit a quelle profondeur de milieu de partie
       on doit aller pour trier des coups en finale ˆ k cases vides *)

    restrictionLargeurSousArbreCeDelta : array[1..kNbreMaxDeltasSuccessifs,0..64] of SInt32;
    (* restrictionLargeurSousArbreCeDelta[i,p] dit le degre de branchement
       de l'arbre que l'on examine pour l'index de deltaFinal i, a la
       profondeur p *)


    valeur_seuil_fastest_first : array[0..64] of SInt32;
    (* valeur_seuil_fastest_first[i] dit pour chaque profondeur
       a partir de combien au dessus de beta on fait du fastest-first *)


    dilatationEvalEnFinale : double;
    valeur_seuil_super_fastest : SInt32;
    seuil_pour_alpha_fastest : SInt32;
    seuil_pour_beta_fastest : SInt32;
    equivalentUnCoupDansTrierSelonDivergenceAvecMilieu : SInt32;

var gNbreNonCoins_entreeCoupGagnant : SInt32;    { sans les coins }
    gNbreVides_entreeCoupGagnant : SInt32;
    gNbreCoins_entreeCoupGagnant : SInt32;
    gNbreCoinsPlus1_entreeCoupGagnant : SInt32;
    gNbreCoinsPlus2_entreeCoupGagnant : SInt32;
    gCoins_entreeCoupGagnant : array[1..4] of SInt32;
    gNonCoins_entreeCoupGagnant : array[1..64] of SInt32;
    gCasesVides_entreeCoupGagnant : array[1..64] of SInt32;
    gNbreVidesCeQuadrantCoupGagnant : array[0..3] of SInt32;
    gListeCasesVidesOrdreJCWCoupGagnant : array[1..64] of SInt32;


var

  triParDenombrementMobilite : array[0..63,0..63] of SInt32;
  denombrementPourCetteMobilite : array[0..63] of SInt32;

  listeDesCoupsFastestBitboard : listeVidesAvecValeur;


  gProfondeurCoucheProofNumberSearch : SInt32;
  gProfondeurCoucheEvalsHeuristiques : SInt32;


type ModifPlatBitboardProcType =
  function (vecteurParite : SInt32; my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32; var resultat : bitboard; var diffPions : SInt32) : SInt32;


var ModifPlatBitboardFunction : array[0..99] of ModifPlatBitboardProcType;


type liaisonArbreZooRec = record
                              longueurListe           : SInt32;
                              trait                   : SInt32;
                              nbCoupsEnvoyesAuZoo : SInt32;
                              alphaInitial            : SInt32;
                              betaInitial             : SInt32;
                              hashCassioDuPere        : SInt32;
                              coupsFils               : listeVidesAvecValeur;
                              bestDef                 : listeVides;
                              hashRequete             : listeUInt64;
                              hashCassioDesFils       : listeVides;
                              timeUsed                : array[0..64] of double;
                              positionPere            : plateauOthello;
                            end;

var liaisonArbreZoo : record
                           tempsMinimalPourEnvoyerAuZoo     : TypeReel;  {en secondes}
                           tempsMaximalPourEnvoyerAuZoo     : TypeReel;  {en secondes}
                           profMinUtilisationZoo             : SInt32;
                           profMaxUtilisationZoo             : SInt32;
                           margePourParallelismeAlphaSpeculatif : SInt32;
                           margePourParallelismeHeuristique     : SInt32;
                           occupationPourParallelismeAlpha2     : SInt32;
                           nbTotalPositionsEnvoyees             : SInt32;
                           gNombreDeCoupuresAlphaPresquesSures  : SInt32;
                           gNombreDeCoupuresAlphaReussies       : SInt32;
                           gNombreDeMauvaisesParallelisation    : SInt32;
                           gNombreDeParallelisationEnRetard     : SInt32;
                           gNombreDeParallelisationVerifiees    : SInt32;
                           infosNoeuds                          : array[0..64] of liaisonArbreZooRec;
                         end;



procedure InitUnitVariablesGlobalesFinale;

{$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
procedure ResetCollecteStatsNbreNoeudsEndgame;
procedure BeginCollecteStatsNbreNoeudsEndgame(whichProf : SInt32);
procedure EndCollecteStatsNbreNoeudsEndgame(whichProf : SInt32);
procedure EcrireCollecteStatsNbreNoeudsEndgameDansRapport;
{$ENDC}


(* gestion du deltaFinaleCourant *)
function DeltaAAfficherImmediatement(whichDeltaFinal : SInt32) : boolean;
function IndexOfThisDelta(whichDeltaFinale : SInt32) : SInt32;
function ThisDeltaFinal(index : SInt32) : SInt32;
procedure SetDeltaFinalCourant(delta : SInt32);





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitBitboardModifPlat, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/VarGlobalesFinale.lk}
{$ENDC}


{END_USE_CLAUSE}










{$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
procedure ResetCollecteStatsNbreNoeudsEndgame;
var i : SInt16;
begin
  for i := 0 to 64 do
    begin
      nbAppelsABFinPetite[i].lo := 0;
      nbAppelsABFinPetite[i].hi := 0;
      nbNoeudsDansABFinPetite[i].lo := 0;
      nbNoeudsDansABFinPetite[i].hi := 0;
      tempoNbNoeudsDansABFinPetite[i] := 0;
    end;
end;


procedure BeginCollecteStatsNbreNoeudsEndgame(whichProf : SInt32);
begin
  tempoNbNoeudsDansABFinPetite[whichProf] := nbreNoeudsGeneresFinale;
end;


procedure EndCollecteStatsNbreNoeudsEndgame(whichProf : SInt32);
begin
  if (nbreNoeudsGeneresFinale > tempoNbNoeudsDansABFinPetite[whichProf]) then {pas de gag d'overflow!}
    begin
      tempoNbNoeudsDansABFinPetite[whichProf] := nbreNoeudsGeneresFinale - tempoNbNoeudsDansABFinPetite[whichProf];

      if (tempoNbNoeudsDansABFinPetite[whichProf] <= 4200000000 - nbNoeudsDansABFinPetite[whichProf].lo) then
        begin

          nbNoeudsDansABFinPetite[whichProf].lo := nbNoeudsDansABFinPetite[whichProf].lo + tempoNbNoeudsDansABFinPetite[whichProf];
          inc(nbAppelsABFinPetite[whichProf].lo);

          while (nbNoeudsDansABFinPetite[whichProf].lo > 1000000000) do
            begin
              nbNoeudsDansABFinPetite[whichProf].lo := nbNoeudsDansABFinPetite[whichProf].lo - 1000000000;
              inc(nbNoeudsDansABFinPetite[whichProf].hi);
            end;


          while (nbAppelsABFinPetite[whichProf].lo > 1000000000) do
            begin
              nbAppelsABFinPetite[whichProf].lo := nbAppelsABFinPetite[whichProf].lo - 1000000000;
              inc(nbAppelsABFinPetite[whichProf].hi);
            end;
        end;
    end;
end;


procedure EcrireCollecteStatsNbreNoeudsEndgameDansRapport;
var i : SInt32;
    nAppels, nNoeuds : double;
begin
  for i := 0 to 64 do
    begin
      if (nbAppelsABFinPetite[i].lo <> 0) or (nbAppelsABFinPetite[i].hi <> 0) then
        begin
          nAppels := (1000000000.0 * nbAppelsABFinPetite[i].hi) + 1.0*nbAppelsABFinPetite[i].lo;
          nNoeuds := (1000000000.0 * nbNoeudsDansABFinPetite[i].hi) + 1.0*nbNoeudsDansABFinPetite[i].lo;
          WritelnStringAndNumEnSeparantLesMilliersDansRapport('nb noeuds/appel de ABFinPetite['+NumEnString(i)+'] = ',RealToLongint(nNoeuds/nAppels + 0.499));
        end;
    end;
end;

{$ENDC}

procedure InitUnitVariablesGlobalesFinale;
var i : SInt16;
begin
  {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
  ResetCollecteStatsNbreNoeudsEndgame;
  {$ENDC}

  nbNoeudsEstimes[0] := 2;
  nbNoeudsEstimes[1] := 3;
  nbNoeudsEstimes[2] := 5;
  nbNoeudsEstimes[3] := 8;
  nbNoeudsEstimes[4] := 10;
  nbNoeudsEstimes[5] := 13;
  nbNoeudsEstimes[6] := 30;
  nbNoeudsEstimes[7] := 71;
  nbNoeudsEstimes[8] := 108;
  nbNoeudsEstimes[9] := 142;
  nbNoeudsEstimes[10] := 301;
  nbNoeudsEstimes[11] := 408;
  nbNoeudsEstimes[12] := 971;
  nbNoeudsEstimes[13] := 1360;
  nbNoeudsEstimes[14] := 3705;
  nbNoeudsEstimes[15] := 5152;
  nbNoeudsEstimes[16] := 14662;
  nbNoeudsEstimes[17] := 21509;
  nbNoeudsEstimes[18] := 62588;
  nbNoeudsEstimes[19] := 105164;
  nbNoeudsEstimes[20] := 304529;
  nbNoeudsEstimes[21] := 376368;
  nbNoeudsEstimes[22] := 536688;
  nbNoeudsEstimes[23] := 750608;
  nbNoeudsEstimes[24] := 2695735;
  nbNoeudsEstimes[25] := 5355271;
  nbNoeudsEstimes[26] := 14924662;
  nbNoeudsEstimes[27] := 26097048;
  nbNoeudsEstimes[28] := 26097048;
  nbNoeudsEstimes[29] := 26097048;
  for i := 30 to 64 do
    nbNoeudsEstimes[i] := nbNoeudsEstimes[29];


  ModifPlatBitboardFunction[11] := ModifPlatBitboard_a1;
  ModifPlatBitboardFunction[12] := ModifPlatBitboard_b1;
  ModifPlatBitboardFunction[13] := ModifPlatBitboard_c1;
  ModifPlatBitboardFunction[14] := ModifPlatBitboard_d1;
  ModifPlatBitboardFunction[15] := ModifPlatBitboard_e1;
  ModifPlatBitboardFunction[16] := ModifPlatBitboard_f1;
  ModifPlatBitboardFunction[17] := ModifPlatBitboard_g1;
  ModifPlatBitboardFunction[18] := ModifPlatBitboard_h1;

  ModifPlatBitboardFunction[21] := ModifPlatBitboard_a2;
  ModifPlatBitboardFunction[22] := ModifPlatBitboard_b2;
  ModifPlatBitboardFunction[23] := ModifPlatBitboard_c2;
  ModifPlatBitboardFunction[24] := ModifPlatBitboard_d2;
  ModifPlatBitboardFunction[25] := ModifPlatBitboard_e2;
  ModifPlatBitboardFunction[26] := ModifPlatBitboard_f2;
  ModifPlatBitboardFunction[27] := ModifPlatBitboard_g2;
  ModifPlatBitboardFunction[28] := ModifPlatBitboard_h2;

  ModifPlatBitboardFunction[31] := ModifPlatBitboard_a3;
  ModifPlatBitboardFunction[32] := ModifPlatBitboard_b3;
  ModifPlatBitboardFunction[33] := ModifPlatBitboard_c3;
  ModifPlatBitboardFunction[34] := ModifPlatBitboard_d3;
  ModifPlatBitboardFunction[35] := ModifPlatBitboard_e3;
  ModifPlatBitboardFunction[36] := ModifPlatBitboard_f3;
  ModifPlatBitboardFunction[37] := ModifPlatBitboard_g3;
  ModifPlatBitboardFunction[38] := ModifPlatBitboard_h3;

  ModifPlatBitboardFunction[41] := ModifPlatBitboard_a4;
  ModifPlatBitboardFunction[42] := ModifPlatBitboard_b4;
  ModifPlatBitboardFunction[43] := ModifPlatBitboard_c4;
  ModifPlatBitboardFunction[44] := ModifPlatBitboard_d4;
  ModifPlatBitboardFunction[45] := ModifPlatBitboard_e4;
  ModifPlatBitboardFunction[46] := ModifPlatBitboard_f4;
  ModifPlatBitboardFunction[47] := ModifPlatBitboard_g4;
  ModifPlatBitboardFunction[48] := ModifPlatBitboard_h4;

  ModifPlatBitboardFunction[51] := ModifPlatBitboard_a5;
  ModifPlatBitboardFunction[52] := ModifPlatBitboard_b5;
  ModifPlatBitboardFunction[53] := ModifPlatBitboard_c5;
  ModifPlatBitboardFunction[54] := ModifPlatBitboard_d5;
  ModifPlatBitboardFunction[55] := ModifPlatBitboard_e5;
  ModifPlatBitboardFunction[56] := ModifPlatBitboard_f5;
  ModifPlatBitboardFunction[57] := ModifPlatBitboard_g5;
  ModifPlatBitboardFunction[58] := ModifPlatBitboard_h5;

  ModifPlatBitboardFunction[61] := ModifPlatBitboard_a6;
  ModifPlatBitboardFunction[62] := ModifPlatBitboard_b6;
  ModifPlatBitboardFunction[63] := ModifPlatBitboard_c6;
  ModifPlatBitboardFunction[64] := ModifPlatBitboard_d6;
  ModifPlatBitboardFunction[65] := ModifPlatBitboard_e6;
  ModifPlatBitboardFunction[66] := ModifPlatBitboard_f6;
  ModifPlatBitboardFunction[67] := ModifPlatBitboard_g6;
  ModifPlatBitboardFunction[68] := ModifPlatBitboard_h6;

  ModifPlatBitboardFunction[71] := ModifPlatBitboard_a7;
  ModifPlatBitboardFunction[72] := ModifPlatBitboard_b7;
  ModifPlatBitboardFunction[73] := ModifPlatBitboard_c7;
  ModifPlatBitboardFunction[74] := ModifPlatBitboard_d7;
  ModifPlatBitboardFunction[75] := ModifPlatBitboard_e7;
  ModifPlatBitboardFunction[76] := ModifPlatBitboard_f7;
  ModifPlatBitboardFunction[77] := ModifPlatBitboard_g7;
  ModifPlatBitboardFunction[78] := ModifPlatBitboard_h7;

  ModifPlatBitboardFunction[81] := ModifPlatBitboard_a8;
  ModifPlatBitboardFunction[82] := ModifPlatBitboard_b8;
  ModifPlatBitboardFunction[83] := ModifPlatBitboard_c8;
  ModifPlatBitboardFunction[84] := ModifPlatBitboard_d8;
  ModifPlatBitboardFunction[85] := ModifPlatBitboard_e8;
  ModifPlatBitboardFunction[86] := ModifPlatBitboard_f8;
  ModifPlatBitboardFunction[87] := ModifPlatBitboard_g8;
  ModifPlatBitboardFunction[88] := ModifPlatBitboard_h8;






end;


function DeltaAAfficherImmediatement(whichDeltaFinal : SInt32) : boolean;
var aux : SInt32;
begin
  if whichDeltaFinal = kDeltaFinaleInfini
    then
      DeltaAAfficherImmediatement := true
    else
      if ((whichDeltaFinal mod 100) = 0)   {deltaFinale entier ?}
        then
          begin
            aux := whichDeltaFinal div 100;
            DeltaAAfficherImmediatement := {(aux = 0)  or} (aux = 1) or
                                            (aux = 2)  or (aux = 4)  or
                                            (aux = 8)  or (aux = 14) or
                                            (aux = 16) or (aux = 24);
          end
        else
          DeltaAAfficherImmediatement := false;
end;




function IndexOfThisDelta(whichDeltaFinale : SInt32) : SInt32;
var i : SInt32;
begin
  if deltaSuccessifs[dernierIndexDeltaRenvoye].valeurDeMu = whichDeltaFinale
    then
      begin
        IndexOfThisDelta := dernierIndexDeltaRenvoye;
        exit(IndexOfThisDelta);
      end
    else
      begin
        for i := nbreDeltaSuccessifs downto 1 do
          if deltaSuccessifs[i].valeurDeMu = whichDeltaFinale then
            begin
              IndexOfThisDelta := i;
              dernierIndexDeltaRenvoye := i;
              exit(IndexOfThisDelta);
            end;
      end;
  SysBeep(0);
  WritelnNumDansRapport('ERREUR dans IndexOfThisDelta : whichDeltaFinale = ',whichDeltaFinale);
  IndexOfThisDelta := 0;
end;

function ThisDeltaFinal(index : SInt32) : SInt32;
begin
  if (index < 1) or (index > nbreDeltaSuccessifs) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('ERREUR dans ThisDeltaFinal : index = ',index);
      ThisDeltaFinal := 0;
      exit(ThisDeltaFinal);
    end;
  ThisDeltaFinal := deltaSuccessifs[index].valeurDeMu;
end;

procedure SetDeltaFinalCourant(delta : SInt32);
begin
  deltaFinaleCourant := delta;
  indexDeltaFinaleCourant := IndexOfThisDelta(deltaFinaleCourant);
end;


END.


