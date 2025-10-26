UNIT UnitMilieuDePartie;




INTERFACE







 USES
     {$IFC USE_PROFILER_MILIEU_DE_PARTIE}
     Profiler ,
     {$ENDC}
     UnitDefCassio;



{ Les fonctions de base, qui permettent de calculer le meilleur coup de milieu sur une position }
function LanceurAlphaBetaMilieu(var plateau : plateauOthello; var joua : plBool; var bstDef : SInt32; pere,coul,prof,distPV,couleurDeCassio,alpha,beta : SInt32; var fr : InfoFront; var conseilTurbulence : SInt32) : SInt32;
function LanceurAlphaBetaMilieuWithSearchParams(var params : MakeEndgameSearchParamRec) : SInt32;


{ La fonction terminale, qui fait de l'approfondissement iteratif, de l'affichage dans les fenetres de Cassio, etc.}
procedure CalculeClassementMilieuDePartie(var classement : ListOfMoveRecords; var indexDuCoupConseille : SInt32; MC_coul,MC_prof,MC_nbBl,MC_nbNo : SInt32; var MC_jeu : plateauOthello; var MC_empl : plBool; var MC_frontiere : InfoFront; calculerMemeSiUnSeulCoupLegal : boolean; casesExclues : SquareSet);
function CalculeMeilleurCoupMilieuDePartie(const jeu : plateauOthello; var emplBool : plBool; var frontiere : InfoFront; couleur,profondeur,nbBlancs,nbNoirs : SInt32) : MoveRecord;


{ Fonctions auxiliaires }
procedure SetProfImposee(flag : boolean; const fonctionAppelante : String255);
function ProfondeurMilieuEstImposee : boolean;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, UnitDebuggage, OSUtils, fp, Timer
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitEvaluation, UnitSuperviseur, UnitEvenement, UnitTraceLog, MyUtils, UnitZoo
    , UnitParallelisme, UnitEngine, UnitEntreesSortiesGraphe, UnitJeu, UnitNotesSurCases, UnitRapportImplementation, UnitUtilitaires, Unit_AB_Scout
    , Unit_AB_simple, UnitTore, MyMathUtils, UnitAffichageReflexion, UnitMoveRecords, UnitServicesDialogs, UnitModes, UnitStrategie
    , UnitMiniProfiler, UnitJaponais, UnitCalculsApprentissage, UnitListe, UnitHashTableExacte, UnitRapport, UnitBufferedPICT, SNEvents
    , UnitGestionDuTemps, UnitPhasesPartie, MyStrings, UnitScannerUtils, UnitFenetres, UnitProblemeDePriseDeCoin, UnitStringSet, UnitAffichagePlateau
    , UnitServicesMemoire, UnitPositionEtTrait, UnitSolve, UnitUtilitairesFinale ;
{$ELSEC}
    ;
    {$I prelink/MilieuDePartie.lk}
{$ENDC}


{END_USE_CLAUSE}











var profondeurDerniereLigneEcriteDansRapport : SInt32;




procedure VerifieAssertionsSurClassementDeMilieu(var classement : ListOfMoveRecords; longClass : SInt32; var position : plateauOthello; const fonctionAppelante : String255);
var i,t : SInt32;
begin
  if (longClass >= 2) then
    begin
      for i := 2 to longClass do
        if (classement[i].x = classement[i - 1].x) then
          begin
            Sysbeep(0);
            WritelnDansRapport('WARNING : deux coups identiques dans VerifieAssertionsSurClassementDeMilieu !');
            WritelnDansRapport('fonction appelante = ' + fonctionAppelante);
            WritelnPositionDansRapport(position);
            for t := 1 to longClass do
              begin
                WriteStringAndCoupDansRapport('coup class = ',classement[t].x);
	              WritelnNumDansRapport(' =>  ',classement[t].note);
              end;
          end;
    end;
end;

procedure CalculeClassementMilieuDePartie(var classement : ListOfMoveRecords;
                                          var indexDuCoupConseille : SInt32;
                                          MC_coul,MC_prof,MC_nbBl,MC_nbNo : SInt32;
                                          var MC_jeu : plateauOthello; var MC_empl : plBool; var MC_frontiere : InfoFront;
                                          calculerMemeSiUnSeulCoupLegal : boolean;
                                          casesExclues : SquareSet);
var coulPourMeilleurMilieu,coulDefense:-1..1;
    nbCasesVidesMilieu : SInt32;
    casesVidesMilieu : array[1..64] of 0..99;
    moves : plBool;
    mob : SInt32;
    iCourant,nbCoup : SInt32;
    i : SInt32;
    tempoPhase : SInt32;
    profondeurDemandee : SInt32;
    profReelle,profsuivante : SInt32;
    tempseffectif : SInt32;
    diffDeTemps : SInt32;
    diffprecedent : SInt32;
    tempsAlloueAuDebutDeLaReflexion : SInt32;
    doitSeDepecher : boolean;
    defense : SInt32;
    MFniv : SInt32;
    rapidite,divergence : double;
    coeffMultiplicateur : double;
    hesitationSurLeBonCoup,vraimentTresFacile : boolean;
    nbFeuillesCetteProf : double;
    nbToursFeuillesCetteProf : SInt32;
    sortieBoucleProfIterative : boolean;
    StatistiquesSurLesCoups : array[0..kNbMaxNiveaux] of
                                     record
                                       teteDeListe : SInt32;  {coup en tete à ce niveau}
                                       nbFeuillesTeteDeListe : double;
                                       nbFeuillesTotalCetteProf : double;
                                       tempsCetteProf : double;
                                     end;
    rechercheDejaAnnoncee : boolean;
    nbCoupRecherche : SInt32;
    MeilleureNoteProfInterativePrecedente : SInt32;
    oldInterruption : SInt32;
    numeroCellule : SInt32;
    varierLesCoups : boolean;
    lignesEcritesDansRapport : StringSet;
    positionArrivee : PositionEtTraitRec;
    tickDepartCetteProf : SInt32;
    tempsAfficheDansGestion : SInt32;
    numeroEngine : SInt32;

{$IFC USE_PROFILER_MILIEU_DE_PARTIE}
    nomFichierProfile : String255;
    tempsGlobalDeLaFonction : SInt32;
{$ENDC}

procedure AnnonceRechercheMilieuDePartieDansRapport;
var s,s1,s2 : String255;
begin
  if not(enTournoi) and not(jeuInstantane) and not(analyseRetrograde.enCours) then
    begin
      s1 := NumEnString((MC_nbBl+MC_nbNo-4)+1);
      if MC_coul = pionNoir
        then s2 := ReadStringFromRessource(TextesListeID,7)   {Noir}
        else s2 := ReadStringFromRessource(TextesListeID,8);  {Blanc}
      s := ReadStringFromRessource(TextesRapportID,2); {Recherche au coup ^0 pour ^1 : milieu de partie}
      s := ParamStr(s,s1,s2,'','');
      if GetEffetSpecial then s := s + ' (effet special)';

      {
      s := s + ' (eval = ' + ReplaceStringByStringInString('EVAL_','',TypeEvalEnChaine(typeEvalEnCours))+' )';
      }

      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      WritelnDansRapport('');

      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);

      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport(s);
      ChangeFontFaceDansRapport(normal);
      EnableKeyboardScriptSwitch;
      rechercheDejaAnnoncee := true;
      profondeurDerniereLigneEcriteDansRapport := -1000;
    end;
end;


procedure MeilleureSuiteEtNoteDansRapport(coul,note,profondeur : SInt16; chaineGauche : String255; var chainesDejaEcrites : StringSet);
var s : String255;
    oldScript : SInt32;
    data : SInt32;
begin
  {if not(jeuInstantane) or analyseRetrograde.enCours then}
  if not(jeuInstantane) and not(analyseRetrograde.enCours) then
    begin
		  s := chaineGauche + MeilleureSuiteEtNoteEnChaine(coul,note,profondeur);
		  if not(MemberOfStringSet(s,data,chainesDejaEcrites))
		    then
		      begin

					  GetCurrentScript(oldScript);
					  DisableKeyboardScriptSwitch;
					  FinRapport;
			      TextNormalDansRapport;

			      if (profondeur <> profondeurDerniereLigneEcriteDansRapport) and
			         (profondeurDerniereLigneEcriteDansRapport > 0) and
			         (avecEvaluationTotale or (nbCoupsEnTete > 1))
			        then WritelnDansRapport('');

			      WritelnDansRapport(s);
			      EnableKeyboardScriptSwitch;
			      SetCurrentScript(oldScript);
			      SwitchToRomanScript;
			      AddStringToSet(s,0,chainesDejaEcrites);
			      profondeurDerniereLigneEcriteDansRapport := profondeur;
			    end;
    end;
end;


procedure AnnonceMeilleureSuiteEtNoteDansRapport(couleur,note,profondeur : SInt32);
begin
  if not(enTournoi) and not(jeuInstantane) and not(analyseRetrograde.enCours) then
    begin
      if not(rechercheDejaAnnoncee) then
        if not(HumCtreHum) and (MC_Coul = couleurMacintosh) then
          AnnonceRechercheMilieuDePartieDansRapport;
      MeilleureSuiteEtNoteDansRapport(couleur,note,profondeur,'  ',lignesEcritesDansRapport);
    end;
end;


procedure VerifierMeilleureSuiteDuMoteur(profondeur : SInt32);
var longueurSuite : SInt32;
    empties : SInt32;
begin
  if CassioIsUsingAnEngine(numeroEngine) then
    begin
      longueurSuite := LongueurMeilleureSuite;
      empties := nbCasesVidesMilieu;

      if (longueurSuite < profondeur - 3) and (longueurSuite < empties - 10) then
        begin
          {
          WritelnNumDansRapport('attendue = ',profondeur);
          WritelnNumDansRapport('empties = ',empties);
          WritelnNumDansRapport('longueurSuite = ',longueurSuite);
          }
          {EngineEmptyHash;}
        end;
    end;
end;


procedure CollecteStatistiques(prof : SInt32; var classement : ListOfMoveRecords; nbFeuillesCetteProf,tempsDeCetteProf,tempsTotal : double);
var s, s2 : String255;
    precision, empties : SInt32;
    numeroEngine : SInt32;
begin

  if (prof < 0) or (prof > kNbMaxNiveaux) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : (prof < 0) or (prof > kNbMaxNiveaux) dans CollecteStatistiques');
      WritelnNumDansRapport('prof = ',prof);
      exit(CollecteStatistiques);
    end;

  StatistiquesSurLesCoups[prof].teteDeListe := classement[1].x;
  StatistiquesSurLesCoups[prof].nbfeuillesTeteDeListe := classement[1].nbfeuilles;
  StatistiquesSurLesCoups[prof].nbFeuillesTotalCetteProf := nbFeuillesCetteProf;
  StatistiquesSurLesCoups[prof].tempsCetteProf := tempsDeCetteProf;

  if {InfosTechniquesDansRapport
     and} (prof + 1 >= kProfMinimalePourSuiteDansRapport)
     and not(enTournoi)
     and not(RechercheDeProblemeDePriseDeCoinEnCours)
     and not(jeuInstantane)
     and not(analyseRetrograde.enCours)
     and ((interruptionReflexion = pasdinterruption))
    then
      begin

        FinRapport;
        ChangeFontFaceDansRapport(italic);
        ChangeFontColorDansRapport(MarronCmd);  // VertSapinCmd et MarinePaleCmd sont bien aussi

        empties := nbCasesVidesMilieu;

        if (prof + 1 > empties) and CassioIsUsingAnEngine(numeroEngine)
          then
            begin
              precision := ProfondeurMilieuEnPrecisionFinaleEngine(prof + 1, empties);
              s2 := ReadStringFromRessource(TextesRapportID,49);   {prof = }
              WriteNumDansRapport(s2 + ' ',empties);
              WriteDansRapport('@'+NumEnString(precision)+'%');
            end
          else
            begin
              s2 := ReadStringFromRessource(TextesRapportID,49);   {prof = }
              WriteNumDansRapport(s2 + ' ',prof + 1);
            end;

        s2 := ReadStringFromRessource(TextesRapportID,51);   {noeuds = }
        WriteStringAndReelEnSeparantLesMilliersDansRapport('  ' + s2 + ' ',nbFeuillesCetteProf,0);

        if (tempsDeCetteProf < 100.0)
          then s := ReelEnStringAvecDecimales(tempsDeCetteProf,2) + 's.'
          else s := ReplaceStringByStringInString(' sec.','s.',SecondesEnJoursHeuresSecondes(Trunc(tempsDeCetteProf)));
        s2 := ReadStringFromRessource(TextesRapportID,52);   {temps = }
        WriteDansRapport('  ' + s2 + ' ' + s);

        if (tempsTotal < 100.0)
          then s := ReelEnStringAvecDecimales(tempsTotal,2) + 's.'
          else s := ReplaceStringByStringInString(' sec.','s.',SecondesEnJoursHeuresSecondes(Trunc(tempsTotal)));
        s2 := ReadStringFromRessource(TextesRapportID,53);   {cumul = }
        WriteDansRapport('  ' + s2 + ' ' + s);

        ChangeFontFaceDansRapport(normal);

        if (interruptionReflexion <> pasdinterruption)
          then WritelnDansRapport('  (interruption !)')
          else WritelnDansRapport('');

        ChangeFontColorDansRapport(NoirCmd);
      end;
end;



function CoupFacile(var classement : ListOfMoveRecords; longClass : SInt32; var vraimentFacile : boolean) : boolean;
var i,nbNiveauxTermines,coupEnTeteDernierNiveau : SInt32;
    memeCoupEnTeteDernierNiveauEtPrec,testCoupFacile : boolean;
    rapportDeuxiemeSurTete : SInt32;
    nbFeuillesDeuxieme : double;
    profmax : SInt32;
    numEngine : SInt32;
begin
  testCoupFacile := false;
  vraimentFacile := false;
  nbNiveauxTermines := 0;
  profMax := 0;
  for i := 0 to kNbMaxNiveaux do
    if StatistiquesSurLesCoups[i].teteDeListe <> 0 then
      begin
        nbNiveauxTermines := nbNiveauxTermines + 1;
        profMax := i;
      end;
  if (nbNiveauxTermines >= 3) then
    begin
      coupEnTeteDernierNiveau := StatistiquesSurLesCoups[profmax].teteDeListe;
      memeCoupEnTeteDernierNiveauEtPrec := false;
      for i := 0 to kNbMaxNiveaux do
        if (i <> profmax) and (StatistiquesSurLesCoups[i].teteDeListe <> 0) then
          memeCoupEnTeteDernierNiveauEtPrec := (StatistiquesSurLesCoups[i].teteDeListe = coupEnTeteDernierNiveau);
      nbFeuillesDeuxieme := -20000;
      with StatistiquesSurLesCoups[profmax] do
        begin
         for i := 1 to longClass do
           if classement[i].x <> teteDeListe then
             if classement[i].nbfeuilles > nbFeuillesDeuxieme then
               nbFeuillesDeuxieme := classement[i].nbfeuilles;
        end;
      if nbFeuillesDeuxieme > 0
        then rapportDeuxiemeSurTete := Trunc((100.0*nbFeuillesDeuxieme) / StatistiquesSurLesCoups[profmax].nbfeuillesTeteDeListe)
        else rapportDeuxiemeSurTete := 500;

      with StatistiquesSurLesCoups[profmax] do
      if ((rapportDeuxiemeSurTete <= 30) and (profmax+1 >= 19)) or
         (((nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf) > 0.90) and (profmax+1 >= 17)) then
        if memeCoupEnTeteDernierNiveauEtPrec and not(enTournoi) and not(CassioIsUsingAnEngine(numEngine)) then
            begin
              testCoupFacile := true;
              vraimentFacile := ((nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf) > 0.90);
            end;


      if debuggage.gestionDuTemps then
        begin
          InvalidateAllCasesDessinEnTraceDeRayon;
          EcranStandard(NIL,true);
          EssaieSetPortWindowPlateau;
          for i := 0 to Min(20,kNbMaxNiveaux) do
           if StatistiquesSurLesCoups[i].teteDeListe <> 0 then
             with StatistiquesSurLesCoups[i] do
             begin
               WriteNumAt('p = ',i+1,10,10+i*12);
               WriteNumAt('AdressePattern[kAdresseBordEst] = ',teteDeListe,50,10+i*12);
               WriteStringAndReelAt('% feuilles du meilleur sur cette prof = ',
                                   100.0*nbfeuillesTeteDeListe/nbFeuillesTotalCetteProf,120,10+i*12);
             end;
          WriteNumAt('% nb feuilles du 2ème/1er  = ',rapportDeuxiemeSurTete,350,10+12*profmax);
          WriteStringAndBoolAt('coup facile  = ',testCoupFacile,10,30+12*profmax);
        end;

    end;
  Coupfacile := testCoupFacile;
end;


procedure MiniMax(couleur,MiniProf,longClass,nbBla,nbNoi : SInt32; jeu : plateauOthello; empl : plBool;
                  var class : ListOfMoveRecords; var front : InfoFront; var hesitation : boolean);
var XCourant : SInt32;
    valXY : SInt32;
    platMod : plateauOthello;
    jouablMod : plBool;
    nbBlancMod,nbNoirMod : SInt32;
    frontMod : InfoFront;
    sortieDeBoucle : boolean;
    classAux : ListOfMoveRecords;
    i,j,k,compteur,aux_compteur : SInt32;
    indice_du_meilleur : SInt32;
    longueurDuClassement : SInt32;
    betaAB,bestAB : SInt32;
    DefCoup : SInt32;
    tickChrono,TempsDeXCourant : SInt32;
    nbreFeuillesDeXCourant : double;
    nbreToursFeuillesDeXCourant : SInt32;
    sauvegardeValeursTactiquesNoir,sauvegardeValeursTactiquesBlanc : platValeur;
    ValeurDeGauche : SInt32;
    oldMeilleureSuiteInfos : meilleureSuiteInfosRec;
    suiteEstInteressante : boolean;
    nbEvalRecursives : SInt32;
    coupLegal : boolean;
    nbLignes : SInt32;
    err : OSStatus;
    numeroEngine : SInt32;

function NoteDeCeCoupIterationPrecedente(whichSquare : SInt32) : SInt32;
var i,valeur : SInt32;
begin

  valeur := -notemax;

  for i := 1 to longClass do
    if (class[i].x = whichSquare) then
      valeur := class[i].note;

  {WritelnNumDansRapport('NoteDeCeCoupIterationPrecedente('+CoupEnString(whichSquare,true)+') = ',valeur);}

  NoteDeCeCoupIterationPrecedente := valeur;
end;

function CalculParIncrement(estimationDeDepart,largeurFenetre,increment : SInt32; alpha,beta : SInt32; var derniereEvalRenvoyee : SInt32) : SInt32;
var aux,bas_Fenetre,haut_Fenetre : SInt32;
    conseilTurbulence : SInt32;
    copieDeClefHashage : SInt32;
begin

  conseilTurbulence := -1;

  copieDeClefHashage := SetClefHashageGlobale(gClefHashage);

  if (alpha >= beta) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('la fenêtre (alpha,beta) n''est pas dans le bon sens dans CalculParIncrement : ');
      WritelnNumDansRapport('alpha = ',alpha);
      WritelnNumDansRapport('beta = ',beta);
      WritelnDansRapport('j''utilise (-notemax,+notemax) à la place...');
      alpha := -30000;
      beta  := +30000;
    end;

  if (estimationDeDepart >= 25000) or (estimationDeDepart <= -25000) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('estimationDeDepart semble trop grand ou trop petit : ',estimationDeDepart);
      WritelnDansRapport('j''utilise 0 à la place...');
      estimationDeDepart := 0;
    end;

  if estimationDeDepart - largeurFenetre >= beta   then estimationDeDepart := beta  + largeurFenetre - 1;
  if estimationDeDepart + largeurFenetre <= alpha  then estimationDeDepart := alpha - largeurFenetre + 1;

  if (estimationDeDepart + largeurFenetre <= alpha) or (estimationDeDepart - largeurFenetre >= beta) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('estimationDeDepart n''est pas dans la fenetre (alpha,beta) : ');
      WritelnNumDansRapport('alpha = ',alpha);
      WritelnNumDansRapport('beta = ',beta);
      WritelnNumDansRapport('estimationDeDepart = ',estimationDeDepart);
      WritelnDansRapport('j''utilise (alpha+beta)/2 à la place...');

      estimationDeDepart := (alpha + beta) div 2;
    end;



  bas_Fenetre  := Max(estimationDeDepart - largeurFenetre,alpha);
  haut_Fenetre := Min(estimationDeDepart + largeurFenetre,beta);

  if (bas_Fenetre >= haut_Fenetre) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('problème dans CalculParIncrement : (bas_Fenetre >= haut_Fenetre)');
      WritelnNumDansRapport('bas_Fenetre = ',bas_Fenetre);
      WritelnNumDansRapport('haut_Fenetre = ',haut_Fenetre);
    end;


  {
  WriteDansRapport('dans CalculParIncrement('+CoupEnString(XCourant,true)+') : ');
  WriteNumDansRapport(' estim = ',estimationDeDepart);
  WritelnNumDansRapport('  hist = ',NoteDeCeCoupIterationPrecedente(XCourant));
  WriteNumDansRapport('  bas_Fenetre = ',bas_Fenetre);
  WritelnNumDansRapport('  haut_Fenetre = ',haut_Fenetre);}


  aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,0,coulPourMeilleurMilieu,-haut_Fenetre,-bas_Fenetre,frontMod,conseilTurbulence);

  {WritelnNumDansRapport('  =  >   ',aux);}

  if (aux >= haut_Fenetre)
    then
      {on monte jusqu'a trouver la bonne valeur}
      while (aux >= haut_Fenetre) and (aux < beta) and (interruptionReflexion = pasdinterruption) do
        begin

          bas_Fenetre  := aux;
          haut_Fenetre := Min(aux+increment,beta);

          aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,0,coulPourMeilleurMilieu,-haut_Fenetre,-bas_Fenetre,frontMod,conseilTurbulence);

          {WritelnNumDansRapport(' up  =  >   ',aux);}

        end
    else
  if (aux <= bas_fenetre)
    then
      {on descend jusqu'a trouver la bonne valeur}
      while (aux <= bas_fenetre) and (aux > alpha) and (interruptionReflexion = pasdinterruption) do
        begin

          bas_Fenetre  := Max(aux-increment,alpha);
          haut_Fenetre := aux;

          aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,0,coulPourMeilleurMilieu,-haut_Fenetre,-bas_Fenetre,frontMod,conseilTurbulence);

          {WritelnNumDansRapport(' down  =  >   ',aux);}

        end;

  derniereEvalRenvoyee := aux;

  if (interruptionReflexion = pasdinterruption)
    then CalculParIncrement := aux
    else CalculParIncrement := -noteMax;

  TesterClefHashage(copieDeClefHashage,'CalculParIncrement');

end;

function CalculNormal(nMeilleursCoups : SInt32; var suiteInteressante : boolean) : SInt32;
var aux,bas_Fenetre,haut_Fenetre,NoteMinimumAffichee,v : SInt32;
    conseilTurbulence,i : SInt32;
    copieDeClefHashage : SInt32;
begin

  Calcule_Valeurs_Tactiques(platMod,false);

  copieDeClefHashage := SetClefHashageGlobale(0);

  conseilTurbulence := -1;
  if (compteur = 1)
    then
      begin
        suiteInteressante := true;
        if (MiniProf >= 4)
          then aux := CalculParIncrement(MeilleureNoteProfInterativePrecedente,300,500,-20000,20000,v)
          else aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,0,coulPourMeilleurMilieu,-20000,20000,frontMod,conseilTurbulence);

        if (interruptionReflexion <> pasdinterruption) then
          begin
            aux := -noteMax;
            suiteInteressante := false;
          end;
      end
    else
      begin {compteur >= 2}
        suiteInteressante := false;
        if not(varierLesCoups)
          then
            begin
              if compteur <= nMeilleursCoups
                 then
                   begin
                     bas_Fenetre  := -32000;
                     haut_Fenetre := bestAB+1;
                   end
                 else
                   begin
                     bas_Fenetre  := classAux[nMeilleursCoups].note;
                     haut_Fenetre := bestAB+1;
                   end;
            end
          else
            begin
              bas_Fenetre  := bestAB - gEntrainementOuvertures.deltaNoteAutoriseParCoup;
              haut_Fenetre := bestAB+1;
            end;

        NoteMinimumAffichee := noteMax;
        for i := 1 to compteur-1 do
          if (classAux[i].note < NoteMinimumAffichee) and (classAux[i].note > -30000) then
            NoteMinimumAffichee := classAux[i].note;


        if (MiniProf >= 4)
          then aux := CalculParIncrement(NoteDeCeCoupIterationPrecedente(XCourant),300,500,bas_Fenetre,haut_Fenetre,v)
          else aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,compteur-1,coulPourMeilleurMilieu,-haut_Fenetre,-bas_Fenetre,frontMod,conseilTurbulence);

        if (interruptionReflexion <> pasdinterruption)
          then
            begin
              aux := -noteMax;
              suiteInteressante := false;
            end
          else
            if (aux >= haut_Fenetre) and (aux < betaAB) then
              begin

                ReflexData^.class[compteur].note := aux + (ReflexData^.class[1].note - bestAB);  {penalite affichee}
                ReflexData^.class[compteur].temps := TickCount - tickChrono;
                if affichageReflexion.doitAfficher then EcritReflexion('CalculNormal');

                aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,0,coulPourMeilleurMilieu,-betaAB,-aux,frontMod,conseilTurbulence);

                if interruptionReflexion <> pasdinterruption
                  then
                    begin
                      defense := 44;
                      if aux <= haut_Fenetre + 3
                        then aux := bas_Fenetre
                        else aux := haut_Fenetre + 10;
                    end
                  else
                    if aux <= haut_Fenetre + 3 then aux := bas_Fenetre;
              end;
        if not(varierLesCoups)
          then
            begin
              if aux <= bas_Fenetre
                then
                  begin
                    aux := NoteMinimumAffichee;
                    suiteInteressante := false;
                  end
                else
                  suiteInteressante := true;
            end
          else
            begin
              if aux <= bas_Fenetre
                then
                  begin
                    aux := valeurDeGauche - gEntrainementOuvertures.deltaNoteAutoriseParCoup;
                    suiteInteressante := false;
                  end
                else
                  suiteInteressante := aux >= bestAB;
            end;
      end;
  CalculNormal := aux;

  TesterClefHashage(copieDeClefHashage,'CalculNormal(UnitMilieuDePartie)');
end;


function CalculParEvaluationTotale(var suiteInteressante : boolean) : SInt32;
var aux,estimationDeDepart,v : SInt32;
    conseilTurbulence : SInt32;
    copieDeClefHashage : SInt32;
begin
  suiteInteressante := true;
  Calcule_Valeurs_Tactiques(platMod,false);

  copieDeClefHashage := SetClefHashageGlobale(0);

  conseilTurbulence := -1;

  if (MiniProf >= 4)
    then
      begin
        estimationDeDepart := NoteDeCeCoupIterationPrecedente(XCourant);
        aux := CalculParIncrement(estimationDeDepart,300,500,-20000,20000,v);
      end
    else
      begin
			   aux := -LanceurAlphaBetaMilieu(platMod,jouablMod,defense,XCourant,coulDefense,MiniProf,compteur-1,coulPourMeilleurMilieu,-notemax,notemax,frontMod,conseilTurbulence);
			end;


  if (interruptionReflexion <> pasdinterruption) then
    begin
      aux := -noteMax;
      suiteInteressante := false;
    end;

  TesterClefHashage(copieDeClefHashage,'CalculParEvaluationTotale(UnitMilieuDePartie)');

  CalculParEvaluationTotale := aux;
end;


function CalculParTore : SInt32;
var aux : SInt32;
    defenseTore : SInt32;
begin
  aux := -AB_tore(platMod,defenseTore,coulDefense,MiniProf,-betaAB,-bestAB,nbBlancMod,nbNoirMod);
  defense := defenseTore;
  CalculParTore := aux;
end;


begin  {MiniMax}
  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
    then TraiteEvenements
    else TraiteNullEvent(theEvent);

  if (interruptionReflexion <> pasdinterruption)
    then exit(MiniMax);


  Initialise_table_heuristique(JeuCourant,false);

  SetLargeurFenetreProbCut;

	profMinimalePourTriDesCoups := 3;

  nbNiveauxRemplissageHash := 10;
  {nbNiveauxHashExacte := 15}  {est pas mal, surtout en fin de milieu de partie}
  nbNiveauxHashExacte := miniprof - 3;  {pour obtenir ProfPourHashExacte = 4, qui est optimal}
	nbNiveauxUtilisationHash := Max(nbNiveauxHashExacte,nbNiveauxRemplissageHash);

	profondeurRemplissageHash := miniprof-nbNiveauxRemplissageHash+1;
	ProfPourHashExacte := miniprof-nbNiveauxHashExacte+1;
	ProfUtilisationHash := miniprof-nbNiveauxUtilisationHash+1;

	{WritelnNumDansRapport('ProfPourHashExacte = ',ProfPourHashExacte);}
  {WritelnNumDansRapport('profondeurRemplissageHash = ',profondeurRemplissageHash);
	WritelnNumDansRapport('ProfUtilisationHash = ',ProfUtilisationHash);}

	Calcule_Valeurs_Tactiques(jeu,false);
	sauvegardeValeursTactiquesNoir := valeurTactNoir;
	sauvegardeValeursTactiquesBlanc := valeurTactBlanc;

	ViderStringSet(lignesEcritesDansRapport);

	MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0));
	indice_du_meilleur := longClass;
	hesitation := false;
	ViderListOfMoveRecords(classAux);
	CopyListOMoveRecords(class,classAux);
	longueurDuClassement := longClass;

	bestAB := -30000;
	betaAB := +30000;



	for i := 1 to longueurDuClassement+1 do
	  classAux[i].note := -32000;

	VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {1}');

	compteur := 0;
	sortieDeBoucle := false;
	repeat
	  if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
	  compteur := compteur + 1;

	  MemoryFillChar(KillerGlb,sizeof(KillerGlb^),chr(0));
	  MemoryFillChar(nbKillerGlb,sizeof(nbKillerGlb^),chr(0));

	  if (compteur = 1) then MeilleureSuiteDansKiller(miniprof);

	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {2}');

	  XCourant := classAux[compteur].x;
	  DefCoup := classAux[compteur].theDefense;

	  if KillerGlb^[miniprof,1] <> defcoup then
	  if (DefCoup >= 11) and (DefCoup <= 88) then
	    if not(interdit[defCoup]) then
	      if not(estUnCoin[defcoup]) then
	          begin
	            nbKillerGlb^[miniprof] := 1;
	            KillerGlb^[miniprof,1] := defcoup;
	          end;



	  if not(RefleSurTempsJoueur) and (GetCouleurOfSquareDansJeuCourant(XCourant) = pionVide) and pionclignotant
	    then DessinePionMontreCoupLegal(XCourant);

	  platMod := jeu;
	  jouablMod := empl;
	  nbBlancMod := nbBla;
	  nbNoirMod := nbNoi;
	  frontMod := front;

	  tickChrono := TickCount;
	  nbreFeuillesDeXCourant := nbreFeuillesMilieu;
	  nbreToursFeuillesDeXCourant := nbreToursFeuillesMilieu;

	  valeurTactNoir := sauvegardeValeursTactiquesNoir;
	  valeurTactBlanc := sauvegardeValeursTactiquesBlanc;
	  coupLegal := ModifPlat(XCourant,couleur,platMod,jouablMod,nbBlancMod,nbNoirMod,frontMod);
	  if MiniProf <= 0 then
	      begin
	        valXY := -Evaluation(platMod,Couldefense,nbBlancMod,nbNoirMod,jouablMod,frontMod,true,-30000,30000,nbEvalRecursives);
	      end
	    else
	      begin
	        if avecEvaluationTotale or (miniprof+1 <= 2)
	          then valXY := CalculParEvaluationTotale(suiteEstInteressante)
	          else valXY := CalculNormal(Min(nbCoupsEnTete,longueurDuClassement),suiteEstInteressante);
	      end;


	  TempsDeXCourant := Max(TickCount - tickChrono + 10 * (longueurDuClassement - compteur) , 0);  {pour favoriser ceux en tete de liste}
	  nbreFeuillesDeXCourant := (nbreFeuillesMilieu - nbreFeuillesDeXCourant)*1.0 + 1000000000.0*(nbreToursFeuillesMilieu - nbreToursFeuillesDeXCourant);

	  if (nbreFeuillesDeXCourant = 0) and CassioIsUsingAnEngine(numeroEngine)
	    then nbreFeuillesDeXCourant := 1000.0 * GetSpeedOfEngine * ((TickCount - tickChrono) / 60.0);


	  if compteur = 1
	    then ValeurDeGauche := valXY
	    else hesitation := hesitation or (valXY > bestAB);

	  if suiteEstInteressante and (valXY <= bestAB) then
	    begin
	      GetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
	      FabriqueMeilleureSuiteInfos(XCourant,suiteJoueeGlb^,meilleureSuiteGlb,
	                                 coulDefense,platMod,nbBlancMod,nbNoirMod,PasDeMessage);

	      VerifierMeilleureSuiteDuMoteur(miniprof+1);

	      if not(HumCtreHum) and (coulPourMeilleurMilieu = couleurMacintosh) then
	        if (MiniProf+1 >= kProfMinimalePourSuiteDansRapport) then
	          if (not(jeuInstantane) or analyseRetrograde.enCours) then
	            AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,valXY,miniprof+1);
	      SetMeilleureSuiteInfos(oldMeilleureSuiteInfos);
	    end;

	  if (valXY > bestAB) and (interruptionReflexion = pasdinterruption) then
	    begin

	      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
	        then TraiteEvenements
	        else TraiteNullEvent(theEvent);

	      FabriqueMeilleureSuiteInfos(XCourant,suiteJoueeGlb^,meilleureSuiteGlb,
	                               coulDefense,platMod,nbBlancMod,nbNoirMod,PasDeMessage);
	      SetMeilleureSuite(MeilleureSuiteEtNoteEnChaine(coulPourMeilleurMilieu,valXY,miniprof+1));
	      if afficheMeilleureSuite then EcritMeilleureSuite;

	      VerifierMeilleureSuiteDuMoteur(miniprof+1);

	      if not(HumCtreHum) and (coulPourMeilleurMilieu = couleurMacintosh) then
	        if (MiniProf+1 >= kProfMinimalePourSuiteDansRapport) then
	          if (not(jeuInstantane) or analyseRetrograde.enCours) then
	          begin
	            AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,valXY,miniprof+1);
	          end;
	     (* if avecDessinCoupEnTete and (GetCouleurOfSquareDansJeuCourant(XCourant) = pionVide) then
	        if not(RefleSurTempsJoueur) or afficheSuggestionDeCassio then
	          begin
	            if (compteur > 1) then EffaceCoupEnTete;
	            SetCoupEntete(XCourant);
	            DessineCoupEnTete;
	          end;
	      SetCoupEntete(XCourant); *)
	      bestAB := valXY;
	    end;


	  if valxy > classAux[1].note then indice_du_meilleur := compteur;

	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {3}');

	  k := 1;
	  while ((classAux[k].note >= valxy))
	         and (k < compteur) do k := k+1;
	  for j := compteur downto k+1 do classAux[j] := classAux[j-1];
	  classAux[k].x := XCourant;
	  classAux[k].note := ValXY;
	  classAux[k].theDefense := defense;
	  classAux[k].temps := TempsDeXCourant;
	  classAux[k].nbfeuilles := nbreFeuillesDeXCourant;
	  classAux[k].pourcentageCertitude := 100;
	  classAux[k].delta := kTypeMilieuDePartie;


	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {4}');

	  (***  classement au temps si pas meilleur  ***)
	  if (compteur >= 2) and (k = compteur) and (valXY = valeurDeGauche) and
	     not(avecEvaluationTotale or (miniprof+1 <= 2)) then
	    begin
	      k := 1;
	      while ((classAux[k].note > valxy))
	         and (k < compteur) do k := k+1;
	      if (k < compteur) and (classAux[k].note = valxy) then k := k+1;
	      while (classAux[k].temps >= TempsDeXCourant) and (classAux[k].note = valxy)
	         and (k < compteur) do k := k+1;
	      for j := compteur downto k+1 do classAux[j] := classAux[j-1];
	      classAux[k].x := XCourant;
	      classAux[k].note := ValXY;
	      classAux[k].theDefense := defense;
	      classAux[k].temps := TempsDeXCourant;
	      classAux[k].nbfeuilles := nbreFeuillesDeXCourant;
	      classAux[k].pourcentageCertitude := 100;
	      classAux[k].delta := kTypeMilieuDePartie;
	    end;

	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {5}');

	  if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
	  if compteur+1 <= longueurDuClassement then classAux[compteur+1].note := -32000;

	  VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {6}');

	  if (interruptionReflexion = pasdinterruption) then
	    begin
			  if avecEvaluationTotale
			    then
			      begin
			        SetValReflex(classAux,MiniProf,compteur,longueurDuClassement,ReflMilieuExhaustif,nbCoupRecherche,compteur+1,coulPourMeilleurMilieu);
			        SetNbLignesScoresCompletsCetteProf(ReflexData^,1000);
			      end
			    else
			      begin
			        SetValReflex(classAux,MiniProf,compteur,longueurDuClassement,ReflMilieu,nbCoupRecherche,compteur+1,coulPourMeilleurMilieu);
			        {on cherche combien de notes differentes il faut afficher dans la fenetre de Reflexion}
			        j := 1;
			        for aux_compteur := 2 to compteur do
			          if classAux[aux_compteur].note <> classAux[aux_compteur-1].note then j := aux_compteur;
			        SetNbLignesScoresCompletsCetteProf(ReflexData^,Max(nbCoupsEnTete,j));
			      end;
			  if affichageReflexion.doitAfficher then EcritReflexion('MiniMax');

			  if (CassioEstEnModeAnalyse {or analyseRetrograde.enCours}) and EstLaPositionCourante(positionArrivee) and (MiniProf >= 7) then
			    begin
			      nbLignes := GetNbLignesScoresCompletsCetteProf(ReflexData^);
			      for j := 1 to Min(nbLignes,longueurDuClassement) do
			        SetNoteMilieuSurCase(kNotesDeCassio,classAux[j].x,classAux[j].note);
			      for j := (1 + Min(nbLignes,longueurDuClassement)) to longueurDuClassement do
			        SetNoteMilieuSurCase(kNotesDeCassio,classAux[j].x,kNoteSurCaseNonDisponible);
			      SetMeilleureNoteMilieuSurCase(kNotesDeCassio,classAux[1].x,classAux[1].note);
			    end;

	   end;

	if not(RefleSurTempsJoueur) and (GetCouleurOfSquareDansJeuCourant(XCourant) = pionVide) and pionclignotant then
		EffacePionMontreCoupLegal(XCourant);


	until sortieDeBoucle or (compteur >= longueurDuClassement) or ((interruptionReflexion <> pasdinterruption));



	if (interruptionReflexion = pasdinterruption)
	  then
			begin
			  if avecEvaluationTotale or (miniprof+1 <= 2)
			    then
			      begin
			        class := classAux;
			        VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {7}');
			        VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {7}');
			      end
			    else
			      begin
			        k := 1;
			        class[1] := classAux[1];
			        { on rejette a la fin les coups affiches comme "pas mieux" }
			        { 1) d'abord on prend les autres }
			        for i := 2 to longClass do
			          if (classAux[i].note <> classAux[i-1].note) or (i <= nbCoupsEnTete) then
			            begin
			              k := k+1;
			              class[k] := classAux[i];
			            end;
			        { 2) puis les pas mieux }
			        for i := 2 to longClass do
			          if not((classAux[i].note <> classAux[i-1].note) or (i <= nbCoupsEnTete)) then
			            begin
			              k := k+1;
			              class[k] := classAux[i];
			            end;

              VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {8}');
              VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {8}');
			      end;
			  {CopyClassementDansTableOfMoveRecordsLists(class,MiniProf,compteur);}
			end
	  else  { si (interruptionReflexion <> pasdinterruption) }
	    begin
	     {WritelnNumDansRapport('dans Minimax (interruptionReflexion <> pasdinterruption), compteur = ',compteur);
	      WritelnNumDansRapport('dans Minimax (interruptionReflexion <> pasdinterruption), longClass = ',longClass);}

	      if compteur <= 1
	        then
	          begin
	            for i := 1 to longClass do
	              class[i] := class[i]; {on ne change pas le classement}

	            VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {9}');
	            VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {9}');
	          end
	        else
	          begin
	            for i := 1 to longClass do
	              class[i] := classAux[i];
	            for i := compteur to longClass do
	              class[i].note := -32000;

	            VerifieAssertionsSurClassementDeMilieu(classAux, longClass, MC_jeu, 'Minimax classAux {10}');
	            VerifieAssertionsSurClassementDeMilieu(class, longClass, MC_jeu, 'Minimax class {10}');
	          end;
	      {CopyClassementDansTableOfMoveRecordsLists(class,MiniProf,compteur-1);}
	    end;

	if interruptionReflexion = pasdinterruption then
	  begin
			if avecEvaluationTotale
			  then
			    begin
			      SetValReflex(class,MiniProf,longClass,longClass,ReflMilieuExhaustif,nbCoupRecherche,MAXINT_16BITS,coulPourMeilleurMilieu);
			      SetNbLignesScoresCompletsCetteProf(ReflexData^,1000);
			    end
			  else
			    begin
			      SetValReflex(class,MiniProf,longClass,longClass,ReflMilieu,nbCoupRecherche,MAXINT_16BITS,coulPourMeilleurMilieu);
			      {on cherche combien de notes differentes il faut afficher dans la fenetre de Reflexion}
			      j := 1;
			      for k := 2 to compteur do
			        if class[k].note <> class[k-1].note then j := k;
			      SetNbLignesScoresCompletsCetteProf(ReflexData^,Max(nbCoupsEnTete,j));
			    end;
			if affichageReflexion.doitAfficher then EcritReflexion('MiniMax');
		end;


	MeilleureNoteProfInterativePrecedente := classAux[1].note;


	with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := MC_nbBl + MC_nbNo - 4 + 1;
      coup       := class[1].x;
      def        := class[1].theDefense;
      valeurCoup := class[1].note + penalitePourTraitAff;
      coul       := MC_coul;
      prof       := profondeurDemandee+1;
    end;


  {if (gNbreThreadsReveillees > 0) then}
    begin
      err := StopAlphaBetaTasks;
      err := CreateAlphaBetaTasks;
    end;


end;   {MiniMax}

function CalculeVariationAvecGraphe(classement : ListOfMoveRecords; longueurClassement : SInt32) : SInt32;
 var nbCoupsEnvisageables,i : SInt32;
     CoupsEnvisageables : ListOfMoveRecords;
     FilsDejaJoues:listeDeCellulesEtDeCoups;
     variationJamaisJoueeDansGraphe : boolean;
     nbreHit,alea : SInt32;
 begin

   ViderListOfMoveRecords(CoupsEnvisageables);

	 nbCoupsEnvisageables := 1;
	 CoupsEnvisageables[1] := classement[1];
	 for i := 2 to longueurClassement do
	   if (classement[i].note > classement[1].note - gEntrainementOuvertures.deltaNoteAutoriseParCoup) and
	      (classement[i].note <> classement[i-1].note) then
	     begin
	       nbCoupsEnvisageables := nbCoupsEnvisageables+1;
	       CoupsEnvisageables[nbCoupsEnvisageables] := classement[i];
	     end;

	 GetFilsDeLaPositionCouranteDansLeGraphe([kGainDansT,kGainAbsolu,kNulleDansT,kNulleAbsolue,kPerteDansT,kPerteAbsolue],false,FilsDejaJoues);
	 variationJamaisJoueeDansGraphe := false;
	 nbreHit := 1;
	 repeat
	   CalculeVariationAvecGraphe := nbreHit;
	   variationJamaisJoueeDansGraphe := not(CoupEstDansListeDeCellulesEtDeCoups(classement[indexDuCoupConseille].x,FilsDejaJoues,numeroCellule));
	   nbreHit := nbreHit+1;
	 until (nbreHit > nbCoupsEnvisageables) or variationJamaisJoueeDansGraphe;

   RandomizeTimer;
	 if not(variationJamaisJoueeDansGraphe) then  {tous les coups envisageables sont deja connus}
	   begin
	     alea := 1+(Abs(Random16()) mod nbCoupsEnvisageables);
	     CalculeVariationAvecGraphe := alea;
	   end;
 end;

function CalculeVariationAvecMilieu(classement : ListOfMoveRecords; longueurClassement : SInt32) : SInt32;
 var nbCoupsEnvisageables,i,j : SInt32;
     CoupsEnvisageables : ListOfMoveRecords;
     alea,probaDeCeCoup,sommeDesProba : SInt32;
     exposant:real;
     found : boolean;
     coupChoisi : SInt32;
 begin

   ViderListOfMoveRecords(CoupsEnvisageables);

   {if (longueurClassement >= 2) and (classement[1].x = classement[2].x) then
     begin
       Sysbeep(0);
       WritelnDansRapport('WARNING : deux coups identiques dans CalculeVariationAvecMilieu !');
     end;
   WritelnDansRapport('entrée dans CalculeVariationAvecMilieu');
   WritelnNumDansRapport('longueurClassement = ',longueurClassement);}


	 nbCoupsEnvisageables := 1;
	 CoupsEnvisageables[1] := classement[1];

	 {WriteStringAndCoupDansRapport('coup class = ',classement[1].x);
	  WritelnNumDansRapport(' =  >   ',classement[1].note);}

	 for i := 2 to longueurClassement do
	   begin
	     {WriteStringAndCoupDansRapport('coup class = ',classement[i].x);
	     WritelnNumDansRapport(' =  >   ',classement[i].note);}
  	   if (classement[i].note > classement[1].note - gEntrainementOuvertures.deltaNoteAutoriseParCoup) and
  	      (classement[i].note <> classement[i-1].note) then
  	     begin
  	       nbCoupsEnvisageables := nbCoupsEnvisageables + 1;
  	       CoupsEnvisageables[nbCoupsEnvisageables] := classement[i];
  	     end;
  	 end;

   exposant := 1.5;
   if classement[1].note < 0  {si on est mal, on sert le jeu un peu : on augmente exposant}
     then exposant := exposant - (0.0005*classement[1].note);

   sommeDesProba := 0;
   for i := 1 to nbCoupsEnvisageables do
     with CoupsEnvisageables[i] do
       begin
         {WriteStringAndCoupDansRapport('coup = ',CoupsEnvisageables[i].x);
         WriteNumDansRapport('  note = ',CoupsEnvisageables[i].note);}


         note := classement[1].note - note - 50;
         if note < 0 then note := 0;

         {WriteNumDansRapport('  delta = ',CoupsEnvisageables[i].note);}

         probaDeCeCoup := Trunc(1000.0*PuissanceReelle(100.0/(100.0+note),exposant));

         CoupsEnvisageables[i].note := probaDeCeCoup;

         {WritelnNumDansRapport('  proba = ',CoupsEnvisageables[i].note);}


         sommeDesProba := sommeDesProba + probaDeCeCoup;
       end;

   {WritelnNumDansRapport('somme des probas = ',sommeDesProba);}

   {on tire au hazard un nombre entre 1 et sommeDesProba}
   {et on regarde a quel coup il correspond}
   RandomizeTimer;
   alea := RandomLongintEntreBornes(1, sommeDesProba);

   {WritelnNumDansRapport('alea = ',alea);}


   sommeDesProba := 0;
   found := false;
   for i := 1 to nbCoupsEnvisageables do
     if not(found) then
       begin
         sommeDesProba := sommeDesProba + CoupsEnvisageables[i].note;
         if sommeDesProba >= alea then
           begin
             coupChoisi := CoupsEnvisageables[i].x;
             for j := 1 to longueurClassement do
               if classement[j].x = coupChoisi then
                 begin
                   found := true;
                   CalculeVariationAvecMilieu := j;
                   {WritelnStringAndCoupDansRapport('OK, found pour ',CoupsEnvisageables[i].x);}
                 end;
           end;
       end;

	 if not(found)
	   then
		   begin
		     WritelnDansRapport('ERREUR dans CalculeVariationAvecMilieu : not(found)');
		     SysBeep(0);
		     CalculeVariationAvecMilieu := 1;
		   end;

 end;



begin          {CalculeClassementMilieuDePartie}


  {$IFC USE_PROFILER_MILIEU_DE_PARTIE}
  if ProfilerInit(collectDetailed,bestTimeBase,20000,200) = NoErr
    then ProfilerSetStatus(1);
  tempsGlobalDeLaFonction := TickCount;
  {$ENDC}

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

  profSupUn := false;
  ReinitilaliseInfosAffichageReflexion;
  SetPositionDansFntreReflexion(ReflexData^,MakePositionEtTrait(MC_jeu,MC_coul));
  nbCoupRecherche := MC_nbBl+MC_nbNo-4+1;
  rechercheDejaAnnoncee := false;
  InitialiseDirectionsJouables;
  CarteJouable(MC_jeu,MC_empl);
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      valeurCoup := -noteMax;
      coul       := pionVide;
      prof       := 0;
    end;
  indexDuCoupConseille := 0;
  ViderListOfMoveRecords(classement);
  lignesEcritesDansRapport := MakeEmptyStringSet;


  with gEntrainementOuvertures do
    begin
      varierLesCoups := CassioVarieSesCoups and
                        (MC_coul = couleurMacintosh) and
                        (nbreCoup <= varierJusquaCeNumeroDeCoup) and
                        (GetCadence <= varierJusquaCetteCadence) and
                        not(analyseRetrograde.enCours) and
                        not(positionFeerique);
      ViderListOfMoveRecords(classementVariations);
      derniereProfCompleteMilieuDePartie := 0;
    end;

  discretisationEvaluationEstOK := not(analyseRetrograde.enCours) and not(varierLesCoups);

  LanceDecompteDesNoeuds;
  compteurNoeuds := 0;
  nbreToursFeuillesMilieu := 0;
  nbreFeuillesMilieu := 0;
  SommeNbEvaluationsRecursives := 0;
  nbreToursNoeudsGeneresMilieu := 0;
  nbreNoeudsGeneresMilieu := 0;
  lastNbreNoeudsGeneres := 0;
  nbreToursNoeudsGeneresFinale := 0;
  nbreNoeudsGeneresFinale := 0;
  MemoryFillChar(@NbreDeNoeudsMoyensFinale,sizeof(NbreDeNoeudsMoyensFinale),chr(0));
  tickNoeuds := TickCount;
  MemoryFillChar(KillerGlb,sizeof(KillerGlb^),chr(0));
  MemoryFillChar(nbKillerGlb,sizeof(nbKillerGlb^),chr(0));
  MemoryFillChar(suiteJoueeGlb,sizeof(suiteJoueeGlb^),chr(0));
  MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0));
  MemoryFillChar(@StatistiquesSurLesCoups,sizeof(StatistiquesSurLesCoups),chr(0));


  positionArrivee := MakePositionEtTrait(MC_jeu,MC_coul);
  if EstLaPositionCourante(positionArrivee) then
    ViderNotesSurCases(kNotesDeCassio,true,othellierToutEntier);


  InitialiseConstantesCodagePosition;
  InvalidateAllProfsDansDansTableOfMoveRecordsLists;

  ViderHashTablePourMilieuDePartie(true);




  MFniv := MC_prof-1;
  coulPourMeilleurMilieu := MC_coul;
  coulDefense := -coulPourMeilleurMilieu;
  MemoryFillChar(@casesVidesMilieu,sizeof(casesVidesMilieu),chr(0));
  nbCasesVidesMilieu := 0;

  if RefleSurTempsJoueur
    then tempsAlloue := TempsPourCeCoup(nbreCoup,couleurMacintosh)
    else tempsAlloue := TempsPourCeCoup(nbreCoup,coulPourMeilleurMilieu);
  tempsAlloueAuDebutDeLaReflexion := tempsAlloue;
  LanceChrono;
  LanceChronoCetteProf;



  for i := 1 to 64 do
    begin
      iCourant := othellier[i];
      if MC_jeu[iCourant] = pionVide then
        begin
          nbCasesVidesMilieu := nbCasesVidesMilieu + 1;
          casesVidesMilieu[nbCasesVidesMilieu] := iCourant;
        end;
    end;
  if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);


  if (interruptionReflexion = pasdinterruption) then
    begin
		  CarteMove(coulPourMeilleurMilieu,MC_jeu,moves,mob);

		  for i := 1 to nbCasesVidesMilieu do
		    if moves[casesVidesMilieu[i]] and (casesVidesMilieu[i] in casesExclues) then
		      begin
		        dec(mob);
		        moves[casesVidesMilieu[i]] := false;
		      end;


		  if (mob > 1) or calculerMemeSiUnSeulCoupLegal or ((analyseRetrograde.enCours) and ((MC_nbBl+MC_nbNo) >= 44))
		    then
		     begin
		       nbCoup := 0;
		       for i := 1 to nbCasesVidesMilieu do
		         if moves[casesVidesMilieu[i]] and not(casesVidesMilieu[i] in casesExclues) then
		           begin
		             nbCoup := nbCoup+1;
		             classement[nbCoup].x := casesVidesMilieu[i];
		             classement[nbCoup].theDefense := 44;
		             classement[nbCoup].note := -noteMax;
		           end;
		       MC_frontiere.occupationTactique := 0;


				   if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
				     then TraiteEvenements
				     else TraiteNullEvent(theEvent);

		       if (interruptionReflexion = pasdinterruption) then
		         begin

		           if avecSelectivite
		             then SelectivitePourCetteRecherche := -6
		             else SelectivitePourCetteRecherche := -6;


		           diffprecedent := 50;
		           tempseffectif := 50;
		           tempsPrevu := 0;
		           profondeurDemandee := -1;

				       REPEAT
						     tempoPhase := phaseDeLaPartie;
						     phaseDeLaPartie := phaseMilieu;
						     if (profondeurDemandee = 1) or (ProfondeurMilieuEstImposee and (profondeurDemandee = MFniv-1))
						       then profondeurDemandee := profondeurDemandee + 1
						       else profondeurDemandee := profondeurDemandee + valeurApprondissementIteratif;
						     if (profondeurDemandee < 1) then profondeurDemandee := 1;

						     (*
						     WritelnStringAndBoolDansRapport('ProfondeurMilieuEstImposee = ', ProfondeurMilieuEstImposee);
						     WritelnNumDansRapport('profondeurDemandee = ', profondeurDemandee);
						     WritelnStringAndBoolDansRapport('not(odd(profondeurDemandee)) = ', not(odd(profondeurDemandee)));
						     WritelnNumDansRapport('coulPourMeilleurMilieu = ', coulPourMeilleurMilieu);
						     WritelnNumDansRapport('PionNoir = ', PionNoir);
						     WritelnNumDansRapport('PionBlanc = ', PionBlanc);
						     *)

						     {on fait les profondeurs paires}
								 if not(ProfondeurMilieuEstImposee) and not(odd(profondeurDemandee)) then
									 inc(profondeurDemandee);

						     (*
						     WritelnNumDansRapport('profondeurDemandee = ', profondeurDemandee);
						     WritelnDansRapport('');
						     *)


						     SetNbLignesScoresCompletsProfPrecedente(ReflexData^,GetNbLignesScoresCompletsCetteProf(ReflexData^));

						     Superviseur(nbreCoup+profondeurDemandee);

						     LanceChronoCetteProf;
						     tickDepartCetteProf := TickCount;
						     nbFeuillesCetteProf := nbreFeuillesMilieu;
						     nbToursFeuillesCetteProf := nbreToursFeuillesMilieu;

						     MiniMax(coulPourMeilleurMilieu,profondeurDemandee,nbCoup,MC_nbBl,MC_nbNo,MC_jeu,MC_empl,
						             classement,MC_frontiere,hesitationSurLeBonCoup);

						     nbFeuillesCetteProf := (nbreFeuillesMilieu - nbFeuillesCetteProf)*1.0 + 1000000000.0*(nbreToursFeuillesMilieu - nbToursFeuillesCetteProf);
						     if (nbFeuillesCetteProf = 0) and CassioIsUsingAnEngine(numeroEngine)
	                 then nbFeuillesCetteProf := 1000.0 * GetSpeedOfEngine * ((TickCount - tickDepartCetteProf) / 60.0);

						     CollecteStatistiques(profondeurDemandee,classement,nbFeuillesCetteProf,(TickCount - tickDepartCetteProf)/60.0, (TickCount - tickNoeuds + 30)/60.0);


						     if interruptionReflexion <> pasdinterruption
						       then
						         begin
						           sortieBoucleProfIterative := true;
						         end
						       else
							       begin

									     profSupUn := (interruptionReflexion = pasdinterruption) and
									                  (profondeurDemandee > 0);

									     phaseDeLaPartie := tempoPhase;
									     diffprecedent := tempseffectif;
									     tempseffectif := tempsReflexionCetteProf;
									     diffDeTemps := tempseffectif;
									     if diffprecedent < 120 then diffprecedent := 120;
									     if phaseDeLaPartie <= phaseDebut
									        then rapidite := -0.8   { plus c'est negatif, plus on peut reflechir }
									        else
									          begin
									            rapidite := -1.0;
									            if hesitationSurLeBonCoup then rapidite := -2.5;
									          end;
									     coeffMultiplicateur := rapidite + diffDeTemps*1.0/diffprecedent;
									     if coeffMultiplicateur < 1.6 then coeffMultiplicateur := 1.6;
									     if coeffMultiplicateur > 10.0 then coeffMultiplicateur := 10.0;
									     tempsPrevu := Trunc(tempseffectif*coeffMultiplicateur);
									     if tempsPrevu < 200 then tempsPrevu := 200;
									     if tempsPrevu < tempseffectif then tempsPrevu := tempseffectif;

									     if (interruptionReflexion = pasdinterruption) and not(CassioEstEnModeAnalyse) then
									       begin
									         vraimentTresFacile := false;
									         {if CoupFacile(classement,nbCoup,vraimentTresFacile) and (tempsAlloue <> minutes10000000) then
									           if vraimentTresFacile
									             then tempsPrevu := tempsPrevu*500
									             else tempsPrevu := tempsPrevu*4;}
									         if hesitationSurLeBonCoup and (profondeurDemandee >= 6) and (classement[1].note <= 10) and
									            (tempsAlloue <> minutes10000000) and not(analyseRetrograde.enCours)
									           then tempsAlloue := Min(Trunc(1.35*tempsAlloue),Trunc(4.0*tempsAlloueAuDebutDeLaReflexion));
									       end;

									     LanceChronoCetteProf;

									     if (interruptionReflexion = pasdinterruption) then
									       begin
									         profReelle := profondeurDemandee+1;
									         if nbFeuillesCetteProf > 0
									           then divergence := exp(ln(nbFeuillesCetteProf)/(profReelle))
									           else divergence := 0.0;
									         if ProfondeurMilieuEstImposee
									           then profsuivante := Min(profReelle+2,MFniv)
									           else profsuivante := profReelle+2;

									         if Abs(tempsEffectif - (TickCount - tickDepartCetteProf)) < 120
									           then tempsAfficheDansGestion := (TickCount - tickDepartCetteProf)
									           else tempsAfficheDansGestion := tempsEffectif;
									         SetValeursGestionTemps(tempsAlloue,tempsAfficheDansGestion,tempsPrevu,divergence,profReelle,profsuivante);

									       end;
									     if afficheGestionTemps and (interruptionReflexion = pasdinterruption)
									       then EcritGestionTemps;

									     if (interruptionReflexion = pasdinterruption) and varierLesCoups then
									       with gEntrainementOuvertures do
									       begin
									         derniereProfCompleteMilieuDePartie := profondeurDemandee+1;
									         CopyListOMoveRecords(classement,classementVariations);
									       end;

									     doitSeDepecher := (profondeurDemandee >= 2) and not(analyseRetrograde.enCours) and
									                       (( 0.333*((tempsReflexionMac+tempsPrevu) div 60) > tempsAlloue) or
									                       (varierLesCoups and not(RefleSurTempsJoueur) and (profondeurDemandee+1 >= gEntrainementOuvertures.profondeurRechercheVariations)));
									     if (tempsAlloue >= kUnMoisDeTemps) or (tempsAlloueAuDebutDeLaReflexion >= kUnMoisDeTemps) then
									       doitSeDepecher := false;

									     if ProfondeurMilieuEstImposee
									       then sortieBoucleProfIterative := (profondeurDemandee >= MFniv)
									       else sortieBoucleProfIterative := (doitSeDepecher and not(RefleSurTempsJoueur and (AQuiDeJouer <> couleurMacintosh)));

									     sortieBoucleProfIterative := sortieBoucleProfIterative or
									                                  (profondeurDemandee >= kNbMaxNiveaux - 3) or
									                                  (profondeurDemandee >= nbCasesVidesMilieu + PlusGrandeProfondeurAvecProbCut) or
									                                  (interruptionReflexion <> pasdinterruption);

									  end;


						   UNTIL sortieBoucleProfIterative or (interruptionReflexion <> pasdinterruption);

						   if not(varierLesCoups)
						     then
						       begin     { on renvoie le premier du classement }
						         indexDuCoupConseille := 1;
						       end
						     else
						       begin
						         with gEntrainementOuvertures do
							         case modeVariation of
							           kVarierEnUtilisantMilieu :
							             begin
							               if derniereProfCompleteMilieuDePartie >= profondeurRechercheVariations
							                 then indexDuCoupConseille := CalculeVariationAvecMilieu(classementVariations,nbCoup)
							                 else indexDuCoupConseille := CalculeVariationAvecMilieu(classement,nbCoup);
							             end;
							           kVarierEnUtilisantGraphe :
							             begin
							               indexDuCoupConseille := CalculeVariationAvecGraphe(classement,nbCoup);
							             end;
							         end; {case}
						       end;

		           {
						   if (interruptionReflexion = pasdinterruption) or doitSeDepecher then
						     if not(HumCtreHum) and (coulPourMeilleurMilieu = couleurMacintosh) then
						       if (profondeurDemandee+1) > kProfMinimalePourSuiteDansRapport then
						         if not(jeuInstantane) or analyseRetrograde.enCours then
						         AnnonceMeilleureSuiteEtNoteDansRapport(coulPourMeilleurMilieu,classement[1].note,profondeurDemandee+1);
		           }

		         end
		     end
		   else
		     begin
		       if (mob <= 0)  {si on passe, quelque chose d'anormal s'est passe : on renvoie un coup fictif}
		         then
		           begin
		             indexDuCoupConseille := 0;
		             with InfosDerniereReflexionMac do
		               begin
		                 nroDuCoup  := -1;
		                 coup       := 0;
		                 def        := 0;
		                 valeurCoup := -noteMax;
		                 coul       := pionVide;
		                 prof       := 0;
		               end;
		           end
		         else
		           begin  { sinon on cherche l'unique coup }
		             indexDuCoupConseille := 0;
					       for i := 1 to 64 do
					         if moves[othellier[i]] then
							       begin
							         indexDuCoupConseille := 1;
							         classement[1].x   := othellier[i];
							         classement[1].note := -10000;
							         classement[1].theDefense := 44;
							       end;
							   if indexDuCoupConseille = 0 then {non trouvé}
			             with InfosDerniereReflexionMac do
			               begin
			                 nroDuCoup  := -1;
			                 coup       := 0;
		                   def        := 0;
		                   valeurCoup := -noteMax;
		                   coul       := pionVide;
		                   prof       := 0;
			               end;
							 end;
				 end;

	  end;

  ReinitilaliseInfosAffichageReflexion;
 (* if avecDessinCoupEnTete then EffaceCoupEnTete; *)
  if affichageReflexion.doitAfficher then EffaceReflexion(HumCtreHum);


  if (indexDuCoupConseille < 1) or (indexDuCoupConseille > 64)
    then
      begin
        if (interruptionReflexion = pasdinterruption) then
          AlerteSimple('Erreur :  indexDuCoupConseille = '+NumEnString(indexDuCoupConseille)+' dans CalculeClassementMilieuDePartie !!')
      end
    else
      begin
			  with InfosDerniereReflexionMac do
			    begin
			      nroDuCoup  := MC_nbBl + MC_nbNo - 4 + 1;
			      coup       := classement[indexDuCoupConseille].x;
			      def        := classement[indexDuCoupConseille].theDefense;
			      valeurCoup := classement[indexDuCoupConseille].note + penalitePourTraitAff;
			      coul       := MC_coul;
			      prof       := profondeurDemandee+1;
			    end;
			end;

  if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
    then TraiteEvenements
    else TraiteNullEvent(theEvent);





  LanceInterruption(oldInterruption,'CalculeClassementMilieuDePartie');
  discretisationEvaluationEstOK := false;
  DisposeStringSet(lignesEcritesDansRapport);


  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
  AfficheMiniProfilerDansRapport(ktempsmoyen);
  {$ENDC}

  {$IFC USE_PROFILER_MILIEU_DE_PARTIE}
   nomFichierProfile := PrefixeFichierProfiler + NumEnString((TickCount - tempsGlobalDeLaFonction) div 60) + '.midgame';
   WritelnDansRapport('nomFichierProfile = '+nomFichierProfile);
   if ProfilerDump(nomFichierProfile) <> NoErr
     then AlerteSimple('L''appel à ProfilerDump('+nomFichierProfile+') a échoué !')
     else ProfilerSetStatus(0);
   ProfilerTerm;
  {$ENDC}

end;         {CalculeClassementMilieuDePartie}


function CalculeMeilleurCoupMilieuDePartie(const jeu : plateauOthello; var emplBool : plBool; var frontiere : InfoFront;
                                            couleur,profondeur,nbBlancs,nbNoirs : SInt32) : MoveRecord;
var result : MoveRecord;
    casesExclues : SquareSet;
    liste : ListOfMoveRecords;
    numCoupConseille : SInt32;
    tempoProfImposee : boolean;
    tempoCassioEnTrainDeReflechir : boolean;
    aux : plateauOthello;
begin
  SetCassioEstEnTrainDeReflechir(true,@tempoCassioEnTrainDeReflechir);

	tempoProfImposee := ProfondeurMilieuEstImposee;


  with gEntrainementOuvertures do
	  if CassioVarieSesCoups and
	     not(analyseRetrograde.enCours) and
	     (couleur = couleurMacintosh) and
	     ((nbBlancs+nbNoirs-4) <= varierJusquaCeNumeroDeCoup) and
	     not(RefleSurTempsJoueur) and
	     not(positionFeerique) and
	     (GetCadence <= varierJusquaCetteCadence)
	     then
	       begin
	         SetProfImposee(true,'CalculeMeilleurCoupMilieuDePartie car CassioVarieSesCoups');
	         profondeur := profondeurRechercheVariations;
	       end;

  ViderMoveRecord(result);

  casesExclues := [];
  aux := jeu;
  CalculeClassementMilieuDePartie(liste,numCoupConseille,couleur,profondeur,nbBlancs,nbNoirs,aux,emplBool,frontiere,analyseRetrograde.enCours,casesExclues);

  {
  WritelnNumDansRapport('dans CalculeMeilleurCoupMilieuDePartie, numCoupConseille = ',numCoupConseille);
  WritelnDansRapport('');
  }

  if (numCoupConseille >= 1) and (numCoupConseille <= 64)
    then
      begin
        result.x := liste[numCoupConseille].x;
        result.note := liste[numCoupConseille].note;
        result.theDefense := liste[numCoupConseille].theDefense;
			end
	  else
	    begin
	      with result do
	        begin
	          note := -noteMax;
	          LanceInterruptionSimple('CalculeMeilleurCoupMilieuDePartie');
	          TraiteInterruptionBrutale(x,theDefense,'CalculeMeilleurCoupMilieuDePartie');
	        end;
	    end;

	SetProfImposee(tempoProfImposee,'fin de CalculeMeilleurCoupMilieuDePartie');
	SetCassioEstEnTrainDeReflechir(tempoCassioEnTrainDeReflechir,NIL);
	if analyseRetrograde.enCours
	  then SetGenreDerniereReflexionDeCassio(ReflRetrogradeMilieu,(nbBlancs + nbNoirs) - 4 +1)
	  else SetGenreDerniereReflexionDeCassio(ReflMilieu,(nbBlancs + nbNoirs) - 4 +1);

	CalculeMeilleurCoupMilieuDePartie := result;
end;



procedure SetProfImposee(flag : boolean; const fonctionAppelante : String255);
begin  {$UNUSED fonctionAppelante}

  {
  if flag
    then WritelnDansRapport('je met profImposee := true dans SetProfImposee, fonctionAppelante = '+fonctionAppelante)
    else WritelnDansRapport('je met profImposee := false dans SetProfImposee, fonctionAppelante = '+fonctionAppelante);
  }

  profimposee := flag;
end;

function ProfondeurMilieuEstImposee : boolean;
begin
  ProfondeurMilieuEstImposee := profimposee;
end;


procedure PrepareToutPourRechercheDeMilieu(const whichPlat : plateauOthello; prof : SInt32);
var copieDeClefHashage : SInt32;
begin
  {WritelnDansRapport('Appel de PrepareToutPourRechercheDeMilieu pour la position suivante : ');
  WritelnPositionEtTraitDansRapport(whichPlat,pionNoir);}

  MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0));
  MemoryFillChar(KillerGlb,sizeof(KillerGlb^),chr(0));
  MemoryFillChar(nbKillerGlb,sizeof(nbKillerGlb^),chr(0));
  ViderHashTablePourMilieuDePartie(false);
  copieDeClefHashage := SetClefHashageGlobale(0);
  SetLargeurFenetreProbCut;
  InitialiseDirectionsJouables;
  Calcule_Valeurs_Tactiques(whichPlat,true);
  Initialise_table_heuristique(whichPlat,false);

  SelectivitePourCetteRecherche := -6;
  profMinimalePourTriDesCoups   := 3;

  nbNiveauxRemplissageHash  := 10;
  nbNiveauxHashExacte       := prof - 3;  {pour obtenir ProfPourHashExacte = 4, qui est optimal}
	nbNiveauxUtilisationHash  := Max(nbNiveauxHashExacte,nbNiveauxRemplissageHash);

	profondeurRemplissageHash := prof - nbNiveauxRemplissageHash + 1;
	ProfPourHashExacte        := prof - nbNiveauxHashExacte + 1;
	ProfUtilisationHash       := prof - nbNiveauxUtilisationHash + 1;
end;



function LanceurAlphaBetaMilieu(var plateau : plateauOthello; var joua : plBool; var bstDef : SInt32; pere,coul,prof,distPV,couleurDeCassio,alpha,beta : SInt32; var fr : InfoFront; var conseilTurbulence : SInt32) : SInt32;
var nbBlancs,nbNoirs,valeur : SInt32;
    valeurCalculeeParLeMoteurExterne : boolean;
    numeroEngine : SInt32;
begin

  DIscard(numeroEngine);

  if (interruptionReflexion <> pasdinterruption) then
    begin
      LanceurAlphaBetaMilieu := -noteMax;
      exit(LanceurAlphaBetaMilieu);
    end;


  valeurCalculeeParLeMoteurExterne := false;


  if CassioIsUsingAnEngine(numeroEngine) and (prof > 8)
    then valeurCalculeeParLeMoteurExterne := EnginePeutFaireCalculDeMilieu(plateau,prof,coul,alpha,beta,pere,valeur,bstDef,meilleureSuiteGlb^);


  if not(valeurCalculeeParLeMoteurExterne) and not(Quitter) then
    begin

      nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,plateau);
      nbNoirs  := NbPionsDeCetteCouleurDansPosition(pionNoir,plateau);


      valeur := ABScout(plateau,joua,bstDef,pere,coul,
                        prof,prof,0,0,distPV,couleurDeCassio,
                        alpha,beta,nbBlancs,nbNoirs,fr,conseilTurbulence,true);
   end;

 LanceurAlphaBetaMilieu := valeur;

end;


function LanceurAlphaBetaMilieuWithSearchParams(var params : MakeEndgameSearchParamRec) : SInt32;
var conseilTurbulence, meilleurCoup, scorePourNoir : SInt32;
    couleur, score, alpha, beta, nbCasesVides, prof : SInt32;
    inversionDuTrait, doitChercher : boolean;
    casesJouables : plBool;
    frontiere : InfoFront;
    ticks : SInt32;
    oldInterruption : SInt32;
    tempoCassioEnTrainDeReflechir : boolean;
    foo : SInt16;
begin

  LanceurAlphaBetaMilieuWithSearchParams := -noteMax;

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  with params do
    begin

      // dans un MakeEndgameSearchParamRec, les bornes sont données en pions entiers.
      // on les convertit donc en bornes pour le milieu de partie.
      couleur := inCouleurFinale;
      alpha   := inAlphaFinale * 100;
      beta    := inBetaFinale * 100;
      prof    := Max(inProfondeurFinale,0);

      // Verification de coherence
      if (couleur <> pionNoir) and (couleur <> pionBlanc) then
        begin
          WritelnNumDansRapport('ASSERT : dans LanceurAlphaBetaMilieuWithSearchParams, couleur = ',couleur);
          LanceurAlphaBetaMilieuWithSearchParams := -noteMax;
          exit(LanceurAlphaBetaMilieuWithSearchParams);
        end;

      // Quelques initialisations
      ticks := TickCount;
      doitChercher := true;
      nbCasesVides := 64 - inNbreBlancsFinale - inNbreNoirsFinale;
      conseilTurbulence := -1;
      InitialiseDirectionsJouables;
      CarteJouable(inPositionPourFinale,casesJouables);
      CarteFrontiere(inPositionPourFinale,frontiere);
      SetCassioEstEnTrainDeReflechir(true,@tempoCassioEnTrainDeReflechir);
      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
      AjusteSleep;
      PrepareToutPourRechercheDeMilieu(inPositionPourFinale,prof);
	
      // Vider les resultats
      ViderSearchResults(outResult);


      // Inversion du trait necessaire ?
      inversionDuTrait := false;
      if DoitPasser(couleur,inPositionPourFinale,casesJouables) then
        if not(DoitPasser(-couleur,inPositionPourFinale,casesJouables))
          then
            begin
              inversionDuTrait := true;
              couleur  := -couleur;
              alpha    := -(inBetaFinale * 100);
              beta     := -(inAlphaFinale * 100);
            end
          else
            begin
              WritelnDansRapport('ASSERT : position terminale dans LanceurAlphaBetaMilieuWithSearchParams');
              doitChercher := false;
              if (inNbreNoirsFinale = inNbreBlancsFinale) then scorePourNoir :=  0;
              if (inNbreNoirsFinale > inNbreBlancsFinale) then scorePourNoir :=  64 - 2*inNbreBlancsFinale;
              if (inNbreNoirsFinale < inNbreBlancsFinale) then scorePourNoir := -64 + 2*inNbreNoirsFinale;
              if (inCouleurFinale = pionNoir)
                then score :=  100 * scorePourNoir
                else score := -100 * scorePourNoir;
            end;


      // ABSCout s'attend un peu a avoir des très grandes fenetres
      if (alpha = -6400) then alpha := -20000;
      if (beta  =  6400) then beta  :=  20000;



      // Recherche !
      if doitChercher then score := LanceurAlphaBetaMilieu(inPositionPourFinale,
                                                           casesJouables,
                                                           meilleurCoup,
                                                           44,
                                                           couleur,
                                                           prof,
                                                           0,
                                                           couleur,
                                                           alpha,
                                                           beta,
                                                           frontiere,
                                                           conseilTurbulence);

      if inversionDuTrait then score := -score;


      // On remet les flags
      SetCassioEstEnTrainDeReflechir(tempoCassioEnTrainDeReflechir,NIL);
    	SetGenreDerniereReflexionDeCassio(ReflMilieu,(inNbreBlancsFinale + inNbreNoirsFinale) - 4 +1);


      // Lecture des resultats
      if (interruptionReflexion = pasdinterruption) and (score > -6500) and (score < 6500)
        then
          begin

            ticks := TickCount - ticks;
            if ticks <= 0 then ticks := 1; // au moins un soixantieme de seconde

            with outResult do
              begin

                //WritelnNumDansRapport('dans LanceurAlphaBetaMilieuWithSearchParams, score = ',score);

                outScoreFinale         := score div 100;  // convertir le score de milieu [-6400..6400] vers un score de finale [-64..64]
                outTimeTakenFinale     := ticks / 60.0;
                outBestMoveFinale      := meilleurCoup;
                outLineFinale          := StructureMeilleureSuiteToString(meilleureSuiteGlb^, inProfondeurFinale);

                if (LENGTH_OF_STRING(outLineFinale) <= 0) and (meilleurCoup >= 11) and (meilleurCoup <= 88) and (inPositionPourFinale[meilleurCoup] = pionVide)
                  then outLineFinale := CoupEnStringEnMajuscules(meilleurCoup);

                if (LENGTH_OF_STRING(outLineFinale) >= 2)
                  then outBestMoveFinale  := ScannerStringPourTrouverCoup(1,outLineFinale,foo)
                  else outBestMoveFinale  := 44;

                if (LENGTH_OF_STRING(outLineFinale) >= 4)
                  then outBestDefenseFinale  := ScannerStringPourTrouverCoup(3,outLineFinale,foo)
                  else outBestDefenseFinale  := 44;

                LanceurAlphaBetaMilieuWithSearchParams := outScoreFinale;
              end;

          end
        else
          begin

            outResult.outScoreFinale  := -noteMax;

            LanceurAlphaBetaMilieuWithSearchParams := -noteMax;

          end;
     end;

   LanceInterruption(oldInterruption,'LanceurAlphaBetaMilieuWithSearchParams');
end;





END.
