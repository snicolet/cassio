UNIT UnitUtilitairesFinale;



INTERFACE







 USES UnitDefCassio,UnitDefParallelisme;




(* initialisation de l'unite *)
procedure InitUnitUtilitairesFinale;
procedure calculate_neighborhood_mask;     external;
procedure InitValeursDeltasSuccessifsFinale;
procedure InitValeursDesBonusDeParite;
procedure InitValeursRestrictionsLargeurSousArbres(profondeurMinimalePourRestriction : SInt32);
procedure InitValeursStandardAlgoFinale;
function VerifieAssertionsDeFinale : boolean;



(* utilitaire pour retrouver la ligne parfaite si elle est stockee en memoire *)
function PeutCalculerFinaleOptimaleParOptimalite(var PlatAcomparer : plateauOthello; nbNoirCompare,nbBlancCompare : SInt32; var ChoixX,MeilleurDef,scorePourNoir : SInt32) : boolean;


(* affichages *)
procedure EcritRefutationsDansRapport(longClass : SInt32; var classAux : ListOfMoveRecords);
procedure EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,nroCoup,deltaFinale : SInt32);
procedure SetDerniereAnnonceFinaleDansMeilleureSuite(s : String255);
function GetDerniereAnnonceFinaleDansMeilleureSuite : String255;


(* conversions *)
procedure CopyEnPlOthEndgame(var source : plateauOthello; var dest : plOthEndgame);
function EtablitListeCasesVides(var plat : plateauOthello; var listeCasesVides : listeVides) : SInt32;
function StructureMeilleureSuiteToString(const meilleureSuite : t_meilleureSuite; prof : SInt32) : String255;


(* idee de base de Fastest First *)
function TrierSelonDivergenceSansMilieu(var plat : plateauOthello; couleur,nbCasesVides : SInt32; var source,dest : listeVides) : SInt32;
function TrierSelonDivergenceAvecMilieu(var plat : plateauOthello; couleur,nbCasesVides,conseilHash : SInt32; var source,dest : listeVides; var InfosMilieuDePartie : InfosMilieuRec; alpha,beta : SInt32; var coupureAlphaProbable,coupureBetaProbable : boolean; utiliserMilieu : boolean; var evalCouleur : SInt32) : SInt32;


(* tri stable selon les valeurs min de la table de hashage *)
procedure TrierSelonHashTableExacte(platDepart : PositionEtTraitRec; var classement : ListOfMoveRecords; longClass, clefHashage : SInt32);


(* divers *)
procedure SetNombreDeCoupsEvaluesParMinimaxDansCettePasse(nombre : SInt32);
function GetNombreDeCoupsEvaluesParMinimaxDansCettePasse : SInt32;
function MinimaxAEvalueAUMoinsUnCoupDansCettePasse : boolean;
function MinimaxAEvalueTousLesCoupsDansCettePasse(longClass : SInt32) : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, UnitDebuggage, Timer
{$IFC NOT(USE_PRELINK)}
    , UnitMiniProfiler, UnitScannerUtils, UnitEvaluation, Unit_AB_simple, UnitHashTableExacte, UnitUtilitaires
    , MyMathUtils, UnitRapportImplementation, UnitNouvelleEval, UnitArbreDeJeuCourant, UnitJaponais, UnitStrategie, MyStrings, UnitAffichageReflexion
    , UnitSuperviseur, UnitMiniProfiler, UnitRapport, UnitListeChaineeCasesVides, UnitBitboardFlips, UnitParallelisme, UnitServicesMemoire, SNEvents
    , UnitModes, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/UtilitairesFinale.lk}
{$ENDC}


{END_USE_CLAUSE}









VAR EvaluationSuffisantePourFastestFirst : array[0..64] of SInt32;
    bonus_parite_zone_paire : array[0..127] of SInt32;
    bonus_parite_zone_impaire : array[0..127] of SInt32;



var gDerniereAnnonceFinaleDansMeilleureSuite : String255;
    gNombreDeCoupsEvaluesParMinimaxDansCettePasse : SInt32;


procedure InitUnitUtilitairesFinale;
begin
  InitValeursStandardAlgoFinale;

  {initialisation des tables du code bitboard de zebra}
  calculate_neighborhood_mask;
end;



procedure InitValeursDeltasSuccessifsFinale;
var k : SInt32;
begin


  // pour Cassio's eval

  (*
  for k := 1 to kNbreMaxDeltasSuccessifs do
    deltaSuccessifs[k] := -1;

  deltaSuccessifs[1] := 0;
  deltaSuccessifs[2] := 100;
  deltaSuccessifs[3] := 200;
  deltaSuccessifs[4] := 400;
  deltaSuccessifs[5] := 1100;
  deltaSuccessifs[6] := 1600;
  deltaSuccessifs[7] := kDeltaFinaleInfini;
  nbreDeltaSuccessifs := 7;
  *)


  // pour Edmond's eval


  for k := 1 to kNbreMaxDeltasSuccessifs do
    begin
      deltaSuccessifs[k].valeurDeMu       := -1;
      deltaSuccessifs[k].selectiviteZebra := 0;
    end;

  deltaSuccessifs[1].valeurDeMu       := 0;
  deltaSuccessifs[1].selectiviteZebra := 57;

  deltaSuccessifs[2].valeurDeMu       := 100;
  deltaSuccessifs[2].selectiviteZebra := 72;

  deltaSuccessifs[3].valeurDeMu       := 200;
  deltaSuccessifs[3].selectiviteZebra := 83;

  deltaSuccessifs[4].valeurDeMu       := 400;
  deltaSuccessifs[4].selectiviteZebra := 91;

  deltaSuccessifs[5].valeurDeMu       := 1100;
  deltaSuccessifs[5].selectiviteZebra := 95;

  deltaSuccessifs[6].valeurDeMu       := 1700;
  deltaSuccessifs[6].selectiviteZebra := 98;

  deltaSuccessifs[7].valeurDeMu       := kDeltaFinaleInfini;
  deltaSuccessifs[7].selectiviteZebra := 100;

  nbreDeltaSuccessifs := 7;


// on pourait envisager aussi un mapping µ=800   95%
//                                       µ=1100  98%
//                                       µ=1700  99%

end;

procedure InitValeursRestrictionsLargeurSousArbres(profondeurMinimalePourRestriction : SInt32);
var k,p : SInt32;
begin {$UNUSED profondeurMinimalePourRestriction}


  for k := 1 to kNbreMaxDeltasSuccessifs do
    for p := 0 to 64 do
      restrictionLargeurSousArbreCeDelta[k,p] := 1000;  {par defaut : pas de restriction}

  (*
  if effetspecial_blah_blah then
    begin
		  {for p := profondeurMinimalePourRestriction to 64 do
		    for k := 1 to nbreDeltaSuccessifs-1 do
		      restrictionLargeurSousArbreCeDelta[k,p] := k;}

		  for p := profondeurMinimalePourRestriction to 64 do
		      restrictionLargeurSousArbreCeDelta[5,p] := 5;
		  for p := profondeurMinimalePourRestriction to 64 do
		      restrictionLargeurSousArbreCeDelta[7,p] := 5;
		end;
  *)

  {
  WritelnDansRapport('table des restrictionLargeurSousArbreCeDelta : ');
  for p := 0 to 64 do
    if restrictionLargeurSousArbreCeDelta[1,p] <> 1000 then
    begin
      WriteNumDansRapport('p = ',p);
      for k := 1 to nbreDeltaSuccessifs do
        WriteNumDansRapport(' ',restrictionLargeurSousArbreCeDelta[k,p]);
      WritelnDansRapport('');
    end;
  }

end;


procedure InitValeursDesBonusDeParite;
var square,i,j,valeur : SInt32;
    tableau : array[1..8] of String255;
begin
   for square := 0 to 127 do
     begin
       bonus_parite_zone_paire[square]  := 0;
       bonus_parite_zone_impaire[square] := 0;
     end;

   // initialisation des bonus de parite pour les zones paires, suivant le type de case

   tableau[1] :=  '128 086 122 125 125 122 086 128 ';
   tableau[2] :=  '086 117 128 128 128 128 117 086 ';
   tableau[3] :=  '122 128 128 128 128 128 128 122 ';
   tableau[4] :=  '125 128 128 128 128 128 128 125 ';
   tableau[5] :=  '125 128 128 128 128 128 128 125 ';
   tableau[6] :=  '122 128 128 128 128 128 128 122 ';
   tableau[7] :=  '086 117 128 128 128 128 117 086 ';
   tableau[8] :=  '128 086 122 125 125 122 086 128 ';

   for i := 1 to 8 do
   for j := 1 to 8 do
   begin
      ChaineToLongint(TPCopy(tableau[j],4*i-3,3),valeur);
      square := j*10+i;
      bonus_parite_zone_impaire[square] := valeur;
      {WritelnCoupAndNumDansRapport(square, bonus_parite_zone_paire[square]);}
   end;

   // initialisation des bonus de parite pour les zones impaires, suivant le type de case

   tableau[1] :=  '024 001 000 025 025 000 001 024 ';
   tableau[2] :=  '001 000 000 000 000 000 000 001 ';
   tableau[3] :=  '000 000 000 000 000 000 000 000 ';
   tableau[4] :=  '025 000 000 000 000 000 000 025 ';
   tableau[5] :=  '025 000 000 000 000 000 000 025 ';
   tableau[6] :=  '000 000 000 000 000 000 000 000 ';
   tableau[7] :=  '001 000 000 000 000 000 000 001 ';
   tableau[8] :=  '024 001 000 025 025 000 001 024 ';

   for i := 1 to 8 do
   for j := 1 to 8 do
   begin
      ChaineToLongint(TPCopy(tableau[j],4*i-3,3),valeur);
      square := j*10+i;
      bonus_parite_zone_paire[square] := valeur;
      {WritelnCoupAndNumDansRapport(square, bonus_parite_zone_impaire[square]);}
   end;
end;



(* on verifie que les delta successifs sont bien croissants,
   qu'il n'y en a pas trop et qu'ils se terminent bien par
   kDeltaFinaleInfini, etc. *)
function VerifieAssertionsDeFinale : boolean;
var erreur,i : SInt32;
begin
  erreur := 0;

  {croissance}
  for i := 2 to nbreDeltaSuccessifs do
    if (deltaSuccessifs[i].valeurDeMu <= deltaSuccessifs[i-1].valeurDeMu)
      then erreur := 1;

  {ni trop, ni trop peu}
  if (nbreDeltaSuccessifs < 1) or
     (nbreDeltaSuccessifs > kNbreMaxDeltasSuccessifs) or
     (nbreDeltaSuccessifs > kNbreMaxDeltasSuccessifsDansHashExacte)
     then erreur := 2;

  {terminaison}
  if (deltaSuccessifs[nbreDeltaSuccessifs].valeurDeMu <> kDeltaFinaleInfini)
    then erreur := 3;

  {intervalle de dernierIndexDeltaRenvoye}
  if (dernierIndexDeltaRenvoye < 1) or
     (dernierIndexDeltaRenvoye > nbreDeltaSuccessifs)
    then erreur := 4;


  if (erreur <> 0) then
    begin
      SysBeep(0);
      WriteDansRapport('ASSERT failed dans VerifieAssertionsDeFinale !!');
      WritelnNumDansRapport('erreur = ',erreur);
    end;

  VerifieAssertionsDeFinale := (erreur = 0);
end;




procedure InitValeursStandardAlgoFinale;
var i : SInt32;
begin

  InitialiseEndgameSquareOrder(ordreDesCasesDeCassio);

  for i := 0 to 17 do  profTriInterneEnFinale[i] := -2;
  for i := 18 to 19 do profTriInterneEnFinale[i] := 0;
  for i := 20 to 21 do profTriInterneEnFinale[i] := 1;
  for i := 22 to 23 do profTriInterneEnFinale[i] := 2;
  for i := 24 to 64 do profTriInterneEnFinale[i] := 3;


  for i := 0  to 16 do profEvaluationHeuristique[i] := 1;
  for i := 17 to 17 do profEvaluationHeuristique[i] := 2;
  for i := 18 to 23 do profEvaluationHeuristique[i] := 3;
  for i := 24 to 64 do profEvaluationHeuristique[i] := 4;

  for i := 0 to 64 do
    EvaluationSuffisantePourFastestFirst[i] := 100000;


  for i := 0 to 4 do
    stability_alpha[i] := 49;
  stability_alpha[5]  := 49;
  stability_alpha[6]  := 42;
  stability_alpha[7]  := 35;
  stability_alpha[8]  := 28;
  stability_alpha[9]  := 21;
  stability_alpha[10] := 14;
  stability_alpha[11] := 7;
  stability_alpha[12] := 0;
  for i := 13 to 64 do
    stability_alpha[i] := 0;


  InitValeursDeltasSuccessifsFinale;

  InitValeursRestrictionsLargeurSousArbres(1000);

  InitValeursDesBonusDeParite;


  for i := 0 to 64 do
    valeur_seuil_fastest_first[i] := 100 + Max(200,Min(1000,(i-14)*100));
  valeur_seuil_super_fastest := 800;

  seuil_pour_alpha_fastest := 800;
  seuil_pour_beta_fastest := 1800;

  // dilatationEvalEnFinale := 1.1;  {1.0 voudrait dire pas de dilatation}

  dilatationEvalEnFinale := 1.0;  // new in Cassio 7.0.9 : that's what we do, see the dilatation at the end of the evaluation function !


  // equivalentUnCoupDansTrierSelonDivergenceAvecMilieu := 200; // pour Cassio's eval

  equivalentUnCoupDansTrierSelonDivergenceAvecMilieu := 140;  // pour Edmond's eval




  dernierIndexDeltaRenvoye := 1;

  gProfondeurCoucheEvalsHeuristiques := 8;
  gProfondeurCoucheProofNumberSearch := -400; {négatif et grand : c'est-à-dire jamais de proof-number}

  SetPenalitesPourLeTraitStandards;


  gNbreAppelsMesureDeParallelisme             := 0;
  gDegreDeParallelisme                        := 0;
  gFraisDeSynchronisation                     := 0;
  gNbreDeSplitNodes                           := 0;
  gNbreDeCoupuresBetaDansUnSplitNode          := 0;
  gNbreDeSplitNodesRates                      := 0;

  gFractionParallelisableMicroSecondes        := 0;
  gFractionParallelisableSecondes             := 0;

  CassioUtiliseLeMultiprocessing              := false;

  gYoungBrotherWaitElders                     := 2;
  gNbreEmptiesMinimalPourParallelisme         := 11;


  gSpinLocksYieldTimeToCPU                    := true;
  gAvecParallelismeSpeculatif                 := true;




  if VerifieAssertionsDeFinale then DoNothing;

end;




function PeutCalculerFinaleOptimaleParOptimalite(var PlatAcomparer : plateauOthello; nbNoirCompare,nbBlancCompare : SInt32;
                                                 var ChoixX,MeilleurDef,scorePourNoir : SInt32) : boolean;
var i,coup,aux,t : SInt32;
    ok,ligneOptimaleJusquaLaFin : boolean;
    plat : plateauOthello;
    nBla,nNoi,aQui : SInt32;
    coupPossible : boolean;
    nroCoupAtteint,coulTrait : SInt32;
    ChoixXTemp,MeilleurDefTemp : SInt32;
begin

  if debuggage.calculFinaleOptimaleParOptimalite and (nbreCoup > 40) then
   begin
     WritelnDansRapport('');
     WritelnDansRapport('Entrée dans PeutCalculerFinaleOptimaleParOptimalite…');
     for i := 42 to 60 do
       begin
         WriteNumDansRapport('coup ',i);
         aux := partie^^[i].coupParfait;
         WriteNumDansRapport(' : ' + chr(64+platMod10[aux]),platDiv10[aux]);
         if partie^^[i].optimal
           then WritelnDansRapport(' optimal  ')
           else WritelnDansRapport(' non optimal ');
       end;
   end;

  nroCoupAtteint := nbNoirCompare+nbBlancCompare-4;
  ligneOptimaleJusquaLaFin := false;

  ChoixX := 44;
  MeilleurDef := 44;
  ok := not(gameOver) and (nroCoupAtteint < 60) and (phaseDeLaPartie >= phaseFinale) and
       (interruptionReflexion = pasdinterruption);

  if ok then
    begin
      MemoryFillChar(@plat,sizeof(plat),chr(0));
      for t := 0 to 99 do
        if interdit[t] then plat[t] := PionInterdit;
      plat[44] := pionBlanc;
      plat[55] := pionBlanc;
      plat[45] := pionNoir;
      plat[54] := pionNoir;
      coulTrait := pionNoir;
      for t := 1 to nroCoupAtteint do
        begin
          coup := partie^^[t].coupParfait;
          if (coup < 11) or (coup > 88) or (plat[coup] <> pionVide) then ok := false;
          if ok then
            if ModifPlatSeulement(coup,plat,coulTrait)
              then coulTrait := -coulTrait
              else ok := ModifPlatSeulement(coup,plat,-coulTrait);
        end;
      if ok then
        for t := 11 to 88 do
          ok := ok and (plat[t] = PlatAcomparer[t]);
    end;


  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok
      then WritelnDansRapport('meme position : ok    ')
      else WritelnDansRapport('meme position : faux  ');


  if ok then ok := (ok and partie^^[nroCoupAtteint+1].optimal);


  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok
      then WritelnDansRapport('coup optimal : ok    ')
      else WritelnDansRapport('coup optimal : faux  ');


  if ok then
    begin
      coup := partie^^[nroCoupAtteint+1].coupParfait;
      aux := partie^^[nroCoupAtteint+2].coupParfait;
      if (coup < 11) or (coup > 88) then ok := false;
      if ok then
        begin
          ChoixXTemp := coup;
          if partie^^[nroCoupAtteint+2].optimal then
            if (aux >= 11) and (aux <= 88) then
              MeilleurDefTemp := aux;
        end;
    end;


  if debuggage.calculFinaleOptimaleParOptimalite then
    if ok
      then WritelnDansRapport('coup legal : ok    ')
      else WritelnDansRapport('coup legal : faux    ');


 if ok then
   begin
     ligneOptimaleJusquaLaFin := true;
     for i := nroCoupAtteint+1 to 60 do
       begin
         coup := partie^^[i].coupParfait;
         if (coup < 11) or (coup > 88) then ligneOptimaleJusquaLaFin := false;
         ligneOptimaleJusquaLaFin := ligneOptimaleJusquaLaFin and partie^^[i].optimal;
       end;
     if ligneOptimaleJusquaLaFin then
       begin
         VideMeilleureSuiteInfos;
         with meilleureSuiteInfos do
           begin
             for i := nbreCoup + 1 to 60 do
               SetCoupDansMeilleureSuite(i - (nbreCoup + 1), partie^^[i].coupParfait);
             numeroCoup := nbreCoup;
             couleur := AQuiDeJouer;

             {determination du score}
             plat := PlatAcomparer;
             nBla := nbBlancCompare;
             nNoi := nbNoirCompare;
             aQui := coulTrait;
             for i := nroCoupAtteint+1 to 60 do
               begin
                 coup := partie^^[i].coupParfait;
                 if (coup >= 11) and (coup <= 88) then
                   begin

                     coupPossible := ModifPlatFin(Coup,aQui,plat,nBla,nNoi);
                     if coupPossible
                       then aQui := -aQui
                       else coupPossible := ModifPlatFin(Coup,-aQui,plat,nBla,nNoi);
                   end;
               end;
             statut := NeSaitPas;
             score.Noir := nNoi;
             score.Blanc := nBla;
           end;  {with meilleureSuiteInfos}

         ChoixX := ChoixXtemp;               {resultats de la fonction}
         MeilleurDef := MeilleurDefTemp;
         ScorePourNoir := nNoi-nBla;

         SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
         if afficheMeilleureSuite then EcritMeilleureSuite;
       end;
   end;


  if debuggage.calculFinaleOptimaleParOptimalite then
    if ligneOptimaleJusquaLaFin
      then WritelnNumDansRapport('ligne optimale : ok    ',nroCoupAtteint)
      else WritelnNumDansRapport('ligne optimale : faux  ',nroCoupAtteint);



  if debuggage.calculFinaleOptimaleParOptimalite and not(ligneOptimaleJusquaLaFin) then
    begin
     SysBeep(0);
     WritelnStringAndBoolDansRapport('PeutCalculerFinaleOptimaleParOptimalite := ',ligneOptimaleJusquaLaFin);
     WritelnNumDansRapport('Sortie de PeutCalculerFinaleOptimaleParOptimalite, coup = ',nroCoupAtteint);
     WritelnDansRapport('');
    end;

   PeutCalculerFinaleOptimaleParOptimalite := ligneOptimaleJusquaLaFin;
end;


procedure EcritRefutationsDansRapport(longClass : SInt32; var classAux : ListOfMoveRecords);
var i,coup,refutation : SInt32;
    s,s1 : String255;
begin
  s := '(';
  for i := 1 to longClass do
    begin
      coup := classAux[i].x;
      refutation := classAux[i].theDefense;
      if i = 1
        then s1 := Concat('sur ',CoupEnString(coup,CassioUtiliseDesMajuscules),', ',CoupEnString(refutation,CassioUtiliseDesMajuscules),'!')
        else s1 := Concat(CoupEnString(coup,CassioUtiliseDesMajuscules),' ',CoupEnString(refutation,CassioUtiliseDesMajuscules),'!');
      if i < longClass then s1 := s1 + ' ; ';
      s := s + s1;
    end;
  s := s + ')';
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  WritelnDansRapport('  '+s);
  EnableKeyboardScriptSwitch;
end;

procedure EcritAnnonceFinaleDansMeilleureSuite(typeCalculFinale,nroCoup,deltaFinale : SInt32);
// var i : SInt32;
begin
  if not(CassioEstEnModeAnalyse and meilleureSuiteAEteCalculeeParOptimalite) then
    begin
      with meilleureSuiteInfos do
        begin
          // enlever les commentaires des deux lignes suivantes pour etre tres rigoureux
          { for i := 0 to 60 do
             SetCoupDansMeilleureSuite(i, 0); }
          case TypeCalculFinale of
            ReflGagnant           : statut := ReflAnnonceGagnant;
            ReflGagnantExhaustif  : statut := ReflAnnonceGagnant;
            ReflParfait           : statut := ReflAnnonceParfait;
            ReflParfaitExhaustif  : statut := ReflAnnonceParfait;
            ReflRetrogradeParfait : statut := ReflAnnonceParfait;
            ReflRetrogradeGagnant : statut := ReflAnnonceGagnant;
            otherwise               statut := NeSaitPas;
          end;
          meilleureSuiteInfos.numeroCoup := nroCoup;
        end;
      SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,(deltaFinale < kDeltaFinaleInfini),0));
      if afficheMeilleureSuite and (GetMeilleureSuite <> GetDerniereAnnonceFinaleDansMeilleureSuite) then
        begin
          EcritMeilleureSuite;
          SetDerniereAnnonceFinaleDansMeilleureSuite(GetMeilleureSuite);
        end;
    end;
end;


procedure SetDerniereAnnonceFinaleDansMeilleureSuite(s : String255);
begin
  gDerniereAnnonceFinaleDansMeilleureSuite := s;
end;


function GetDerniereAnnonceFinaleDansMeilleureSuite : String255;
begin
  GetDerniereAnnonceFinaleDansMeilleureSuite := gDerniereAnnonceFinaleDansMeilleureSuite;
end;


procedure CopyEnPlOthEndgame(var source : plateauOthello; var dest : plOthEndgame);
var i : SInt32;
begin
  for i := 0 to 99 do
    dest[i] := source[i];
end;


function EtablitListeCasesVides(var plat : plateauOthello; var listeCasesVides : listeVides) : SInt32;
var nbVidesTrouvees,i,caseTestee : SInt32;
begin
  nbVidesTrouvees := 0;
  i := 0;
  repeat
    inc(i);
    caseTestee := othellier[i];
    if plat[caseTestee] = pionVide then
      begin
        inc(nbVidesTrouvees);
        listeCasesVides[nbVidesTrouvees] := caseTestee;
      end;
  until i >= 64;
  EtablitListeCasesVides := nbVidesTrouvees;
end;


function StructureMeilleureSuiteToString(const meilleureSuite : t_meilleureSuite; prof : SInt32) : String255;
var s : String255;
    p, k, coup : SInt32;
    debugage : boolean;
begin
  s := '';

  if (prof >= -2) then
    begin
      for k := prof downto 1 do
        begin
          coup := meilleureSuite[prof , k];

          if (coup >= 11) and (coup <= 88) then
            s := s + CoupEnString(coup , true);
        end;
    end;

  debugage := false;

  if debugage then
    begin
      WritelnDansRapport('');
      WritelnNumDansRapport('prof = ',prof);
      for p := 64 downto 1 do
        begin
          WriteNumDansRapport('p = ',p);
          WriteDansRapport('  ligne = ');
          for k := prof downto 1 do
            begin
              coup := meilleureSuite[p , k];

              if (coup >= 11) and (coup <= 88) then
                WriteDansRapport( CoupEnString(coup , true));
            end;
          WritelnDansRapport('');
        end;
    end;

  StructureMeilleureSuiteToString := s;
end;



{faible mobilite adverse d'abord}
{attention ! les cases vides de source doivent etre *exactement* les cases vides de la position}
function TrierSelonDivergenceSansMilieu(var plat : plateauOthello; couleur,nbCasesVides : SInt32; var source,dest : listeVides) : SInt32;
label finBoucleFor;
var i,j,k,nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
    x,dx,t,couleurAdversaire : SInt32;
    classementDivergence : listeVidesAvecValeur;
    platDiv : plOthEndgame;
    coupLegal : boolean;
 begin
   platDiv := plat;
   couleurAdversaire := -couleur;

   nbCoups := 0;
   for i := 1 to nbCasesVides do
     begin
       coupTest := source[i];

       if platDiv[coupTest] <> pionVide then
         begin
           WritelnDansRapport('Probleme dans TrierSelonDivergenceSansMilieu: platDiv[coupTest] <> pionVide');
           SysBeep(0);
           AttendFrappeClavier;
         end;

       coupLegal := ModifPlatSeulementLongint(coupTest,couleur,couleurAdversaire,platDiv);
       if coupLegal
         then
           begin
             inc(nbCoups);
             mobAdverse := 0;
             for j := 1 to nbCasesVides do
               if j <> i then
                 begin
                   coupDiv := source[j];

                   if platDiv[coupDiv] <> pionVide then
						         begin
						           WritelnDansRapport('Probleme : platDiv[coupDiv] <> pionVide');
						           SysBeep(0);
						           AttendFrappeClavier;
						         end;


                   for t := dirPriseDeb[coupDiv] to dirPriseFin[coupDiv] do
                     begin
                       dx := dirPrise[t];
                       x := coupDiv+dx;
                       if platDiv[x] = couleur then
                         begin
                           repeat
                             x := x+dx;
                           until platDiv[x] <> couleur;
                           if (platDiv[x] = couleurAdversaire) then
                             begin
                               inc(mobAdverse);
                               if estUnCoin[coupDiv] then inc(mobAdverse);  {les coins comptent pour deux}
                               goto finBoucleFor;
                             end;
                         end;
                     end;
                   finBoucleFor:
                 end;

             {la phase d'insertion du tri par insertion selon la mobilite adverse decroissante}
             k := 1;
             while (classementDivergence[k].theVal <= mobAdverse) and (k < nbCoups) do inc(k);
             for j := nbCoups downto succ(k) do classementDivergence[j] := classementDivergence[j-1];
             classementDivergence[k].coup   := coupTest;
             classementDivergence[k].theVal := mobAdverse;

             platDiv := plat;
           end;
     end;
   for i := 1 to nbCoups do
     dest[i] := classementDivergence[i].coup;
   TrierSelonDivergenceSansMilieu := nbCoups;
 end;



// Fonction de tri melangeant la mobilite adverse et le milieu de partie : on peut voir
// cela comme un fastest first pondere par le milieu de partie (ou le contraire)

function TrierSelonDivergenceAvecMilieu(var plat : plateauOthello; couleur,nbCasesVides,conseilHash : SInt32; var source,dest : listeVides; var InfosMilieuDePartie : InfosMilieuRec;
                                        alpha,beta : SInt32; var coupureAlphaProbable,coupureBetaProbable : boolean; utiliserMilieu : boolean; var evalCouleur : SInt32) : SInt32;
label finBoucleFor;
var i,j,k,nbCoups,mobAdverse,coupTest,coupdiv : SInt32;
   x,dx,t,evalAdverse,couleurAdversaire,uneDefense : SInt32;
   profondeurPourLeTri : SInt32;
   // stabilite_amie : SInt32;
   nbEvalRecursives : SInt32;
   seuil_fastest,seuil_super_fastest : SInt32;
   platDiv : plOthEndgame;
   InfosMilieuDiv : InfosMilieuRec;
   classementDivergence : listeVidesAvecValeur;
   coupLegal : boolean;
   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
   microSecondesCurrent,microSecondesDepart : UnsignedWide;
   profAffichageMiniprofiler : SInt32;
   {$ENDC}
   tempUsingRecursiveEval : boolean;
   tempoRecursivite : boolean;
begin  {$UNUSED conseilHash}
	 platDiv := plat;



   if ((64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs) <= 15) then
	   begin
	     tempUsingRecursiveEval := avecRecursiviteDansEval;
	     avecRecursiviteDansEval := false;
	   end;


   evalCouleur := kEvaluationNonFaite;


	 // on fait une eval statique de la position pour nous,
	 // pour placer le drapeau "utiliserMilieu", et pour renvoyer a l'exterieur,
	 // le cas echeant, l'information si c'est une coupure alpha ou beta probable


	 if utiliserMilieu then
	   begin

	     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  	   Microseconds(microSecondesDepart);
  	   profAffichageMiniprofiler := (64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs);
  	   {$ENDC}

  	   with InfosMilieuDePartie do
  	     begin
  	       evalCouleur := Evaluation(plat,couleur,nbBlancs,nbNoirs,jouable,frontiere,false,
        	                                (alpha - seuil_pour_alpha_fastest),(beta + seuil_pour_beta_fastest),nbEvalRecursives);


           coupureAlphaProbable := coupureAlphaProbable or (evalCouleur <= alpha - 800);
        	 coupureBetaProbable  := coupureBetaProbable  or (evalCouleur >= beta  + 800);

        	 InfosMilieuDiv := InfosMilieuDePartie;

  	     end;

  	   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
       Microseconds(microSecondesCurrent);
       AjouterTempsDansMiniProfiler(profAffichageMiniprofiler,-4,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
       {$ENDC}

  	 end;


	 // maintenant si le drapeau "utiliserMilieu" est a FALSE, on fera un fastest first pur (ie basé sur la mobilité seulement)


	 {$IFC USE_DEBUG_STEP_BY_STEP}
	 if gDebuggageAlgoFinaleStepByStep.actif and
       (nbCasesVides >= gDebuggageAlgoFinaleStepByStep.profMin) and
       MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
      begin
        WritelnDansRapport('Entree dans TrierSelonDivergenceAvecMilieu');
        WritelnNumDansRapport('alpha = ',alpha);
        WritelnNumDansRapport('beta = ',beta);
        if utiliserMilieu then WritelnNumDansRapport('evalCouleur = ',evalCouleur);
        WritelnStringAndBoolDansRapport('utiliserMilieu = ',utiliserMilieu);
      end;
	 {$ENDC}

	 couleurAdversaire := -couleur;

	 nbCoups := 0;
	 for i := 1 to nbCasesVides do
	   if (source[i] >= 11) and (source[i] <= 88) then
	   begin
	     coupTest := source[i];

	     // on joue chacun de nos coups
	
	     //if utiliserMilieu then WritelnNumDansRapport('TrierSelonDivergenceAvecMilieu, coup = ',coupTest);
	
	     {exeptionnellement, pour le debugage seulement !}
       if (coupTest < 11) then AlerteSimple('Debugger : coupTest = '+NumEnString(coupTest)+' dans TrierSelonDivergenceAvecMilieu') else
       if (coupTest > 88) then AlerteSimple('Debugger : coupTest = '+NumEnString(coupTest)+' dans TrierSelonDivergenceAvecMilieu') else
       if (platDiv[coupTest] <> pionVide) then AlerteSimple('Debugger : platDiv['+NumEnString(coupTest)+'] <> 0 dans TrierSelonDivergenceAvecMilieu');


	     if utiliserMilieu
	       then with InfosMilieuDiv do
	              coupLegal := ModifPlatLongint(coupTest,couleur,platDiv,jouable,nbBlancs,nbNoirs,frontiere)
	       else   coupLegal := ModifPlatSeulementLongint(coupTest,couleur,couleurAdversaire,platDiv);

	     if coupLegal
	       then
	         begin
	           inc(nbCoups);
	           { if (coupTest = conseilHash) and (conseilHash > 0)
	             then
	               mobAdverse := -2000000  (* comme ca on est sur de le mettre en tete :-) *)
	             else }
	               begin

	                 // calcule de la mobilite adverse plus le nombre de coins que l'adversaire peut prendre

	                 mobAdverse := 0;
	                 for j := 1 to nbCasesVides do
	                   if j <> i then
	                     begin
	                       coupDiv := source[j];
	                       for t := dirPriseDeb[coupDiv] to dirPriseFin[coupDiv] do
	                         begin
	                           dx := dirPrise[t];
	                           x := coupDiv+dx;
	                           if platDiv[x] = couleur then
	                             begin
	                               repeat
	                                 x := x+dx;
	                               until platDiv[x] <> couleur;
	                               if (platDiv[x] = couleurAdversaire) then
	                                 begin
	                                   inc(mobAdverse);
	                                   if estUnCoin[coupDiv] then inc(mobAdverse); {les coins comptent pour deux}
	                                   goto finBoucleFor;
	                                 end;
	                             end;
	                         end;
	                       finBoucleFor:
	                     end;

	                 if not(utiliserMilieu)
	                   then
	                     begin

	                       mobAdverse := mobAdverse;

	                     end
	                   else
  	                   with InfosMilieuDiv do
  	                     begin

  	                       // la mobilite adverse ne suffit pas, on calcule une note de tri plus subtile




  	                       // largeur de fenetres ?

  	                       seuil_fastest       := valeur_seuil_fastest_first[64 - nbBlancs - nbNoirs] ;
  	                       seuil_super_fastest := valeur_seuil_fastest_first[64 - nbBlancs - nbNoirs] + valeur_seuil_super_fastest;



  	                       // Avant de lancer un shallow search apres notre coup pour ce fils-la,
  							           // on evalue statiquement la position avec le trait a l'aversaire...


  	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  	                       Microseconds(microSecondesDepart);
  	                       {$ENDC}

  	                       evalAdverse := Evaluation(platDiv,couleurAdversaire,nbBlancs,
    	                                                        nbNoirs,jouable,frontiere,false,
    	                                                        -30000,30000,nbEvalRecursives);

    	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
	                         Microseconds(microSecondesCurrent);
	                         AjouterTempsDansMiniProfiler(profAffichageMiniprofiler,-3,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
	                         Microseconds(microSecondesDepart);
	                         {$ENDC}



	                         // profondeur des shallows search ?

  	                       profondeurPourLeTri := profTriInterneEnFinale[64-nbBlancs-nbNoirs];


  	                       // ... et on ne prend la peine de faire un shallow search tres profond que
  	                       // si ce n'est pas un un coup qui semble tres bon ou tres mauvais

  	                       if (profondeurPourLeTri >= 0) and
  	                          not(evalAdverse <= (-beta - seuil_super_fastest)) and
  	                          not(evalAdverse >= (-alpha + seuil_super_fastest))
  	                            then
  	                              begin

  	                                tempoRecursivite := avecRecursiviteDansEval;
                                    avecRecursiviteDansEval := false;

                                    evalAdverse := AB_simple(platDiv,jouable,uneDefense,
  		                                                 couleurAdversaire,profondeurPourLeTri,
  		                                                 -30000,30000,nbBlancs,nbNoirs,frontiere,true);

  		                              avecRecursiviteDansEval := tempoRecursivite;

  					                        {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  					                        Microseconds(microSecondesCurrent);
  					                        AjouterTempsDansMiniProfiler(profAffichageMiniprofiler,profondeurPourLeTri,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
  					                        {$ENDC}
  					                      end
  					                    else
  					                      begin
  					                        {$IFC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME}
  					                        Microseconds(microSecondesCurrent);
  					                        AjouterTempsDansMiniProfiler(profAffichageMiniprofiler,-2,microSecondesCurrent.lo-microSecondesDepart.lo,kpourcentage);
  					                        {$ENDC}
  					                      end;



  	                       if utilisationNouvelleEval
  	                         then
  	                           begin


  	                             if evalAdverse <= (-beta - seuil_fastest)
  	                               then
  	                                 begin
  	                                   {WritelnPositionEtTraitDansRapport(plat,couleur);
  	                                   WritelnStringDansRapport('coup critique = '+CoupEnString(coupTest,true));
  	                                   WritelnNumDansRapport('evalAdverse = ',evalAdverse);
  	                                   WritelnNumDansRapport('avant, mobAdverse = ',mobAdverse);}

  	                                   // Tous les coups qui semblent tres bons sont mis vers la tete du classement
                  									   // (d'ou le -100000) et on les departage par une combinaison de mobilite adverse
                  									   // et de leur note statique, avec une grosse ponderation pour la mobilite adverse.


                                       mobAdverse := mobAdverse * 300;  {chaque coup adverse en moins vaut 1.5 pions}
  	                                   mobAdverse := mobAdverse + evalAdverse;
  	                                   mobAdverse := mobAdverse - 1000000;


  	                                   {WritelnNumDansRapport('après, mobAdverse = ',mobAdverse);
  	                                   WritelnDansRapport('');
  	                                   AttendFrappeClavier;}
  	                                 end
  	                               else
  	                                 begin

  	                                    // les coups qui semblent serres sont departages par une combinaison de mobilite adverse
                  									    // et de leur note resultant du shallow search mais, avec une moins grosse ponderation
                  									    // pour la mobilite adverse.

  	                                    mobAdverse := mobAdverse + (evalAdverse div equivalentUnCoupDansTrierSelonDivergenceAvecMilieu);
  	                                 end;
  	                           end
  	                         else mobAdverse := mobAdverse + (evalAdverse div 1000);
  	                     end; {with}

	               end;

	           {la phase d'insertion du tri par insertion selon la mobilite adverse decroissante}
	           k := 1;
	           while (classementDivergence[k].theVal <= mobAdverse) and (k < nbCoups) do inc(k);
	           for j := nbCoups downto succ(k) do classementDivergence[j] := classementDivergence[j-1];
	           classementDivergence[k].coup   := coupTest;
	           classementDivergence[k].theVal := mobAdverse;

	           platDiv := plat;
	           if utiliserMilieu then InfosMilieuDiv := InfosMilieuDePartie;
	         end;
	   end;

	 // recopie des coups tries

	 for i := 1 to nbCoups do
	   dest[i] := classementDivergence[i].coup;


	 // on renvoie le nombre de coups

	 TrierSelonDivergenceAvecMilieu := nbCoups;


	 if ((64 - InfosMilieuDePartie.nbBlancs - InfosMilieuDePartie.nbNoirs) <= 15) then
	   begin
	     avecRecursiviteDansEval := tempUsingRecursiveEval;
	   end;


end;


procedure TrierSelonHashTableExacte(platDepart : PositionEtTraitRec; var classement : ListOfMoveRecords; longClass, clefHashage : SInt32);
var i,k,coup,hashKeyAfterCoup : SInt32;
    platAux : PositionEtTraitRec;
    valMinDuCoup,valMinPourNoir,valMaxPourNoir : SInt32;
    table_tri : ListOfMoveRecords;
    temp : MoveRecord;
begin

  (* WritelnDansRapport('');
     WritelnDansRapport('Entrée dans TrierSelonHashTableExacte'); *)


  for i := 1 to longClass do
    begin
      table_tri[i] := classement[i];
      table_tri[i].notePourLeTri := -64;
    end;

  for i := 1 to longClass do
    begin
      coup := table_tri[i].x;
      platAux := platDepart;

      if UpdatePositionEtTrait(platAux,coup)
        then
	        begin
			      hashKeyAfterCoup := BXOR(clefHashage, (IndiceHash^^[GetTraitOfPosition(platAux),coup]));

			      if GetEndgameValuesInHashTableAtThisHashKey(platAux,hashKeyAfterCoup,kDeltaFinaleInfini,valMinPourNoir,valMaxPourNoir)
			        then
			          begin
			            if GetTraitOfPosition(platDepart) = pionNoir
			              then valMinDuCoup :=  valMinPourNoir
			              else valMinDuCoup := -valMaxPourNoir;
			            (* WritelnNumDansRapport('trouvé '+CoupEnString(coup,true)+' => ',valMinDuCoup); *)
			          end
			        else
			          begin
			            valMinDuCoup := -64;
			            (* WritelnDansRapport('non trouvé '+ CoupEnString(coup,true)); *)
			          end;
			      table_tri[i].notePourLeTri := valMinDuCoup;


			      {tri par insertion}
			      for k := i downto 2 do
			        if (table_tri[k].notePourLeTri > table_tri[k-1].notePourLeTri) then
			          begin
			            temp := table_tri[k-1];
			            table_tri[k-1] := table_tri[k];
			            table_tri[k] := temp;

			            {on fait les mouvements miroirs sur le vrai classement}
			            temp := classement[k-1];
			            classement[k-1] := classement[k];
			            classement[k] := temp;
			          end;
			    end
			  else
			    begin
			      WritelnDansRapport('HORREUR ! not(UpdatePositionEtTrait(platAux,coup) dans TrierSelonHashTableExacte !!!');
			    end;
    end;

(*WritelnDansRapport('apres tri :');
  for i := 1 to longClass do
    WritelnNumDansRapport(CoupEnString(table_tri[i].x,true)+' => ',table_tri[i].notePourLeTri);
  WritelnDansRapport('');
  for i := 1 to longClass do
    WritelnNumDansRapport(CoupEnString(classement[i].x,true)+' => ',classement[i].notePourLeTri);
  WritelnDansRapport('Sortie de TrierSelonHashTableExacte');
  WritelnDansRapport(''); *)
end;


procedure SetNombreDeCoupsEvaluesParMinimaxDansCettePasse(nombre : SInt32);
begin
  gNombreDeCoupsEvaluesParMinimaxDansCettePasse := nombre;
end;

function GetNombreDeCoupsEvaluesParMinimaxDansCettePasse : SInt32;
begin
  GetNombreDeCoupsEvaluesParMinimaxDansCettePasse := gNombreDeCoupsEvaluesParMinimaxDansCettePasse;
end;

function MinimaxAEvalueAUMoinsUnCoupDansCettePasse : boolean;
begin
  MinimaxAEvalueAUMoinsUnCoupDansCettePasse := (gNombreDeCoupsEvaluesParMinimaxDansCettePasse > 0);
end;

function MinimaxAEvalueTousLesCoupsDansCettePasse(longClass : SInt32) : boolean;
begin
  MinimaxAEvalueTousLesCoupsDansCettePasse := (gNombreDeCoupsEvaluesParMinimaxDansCettePasse >= longClass);
end;





END.






















