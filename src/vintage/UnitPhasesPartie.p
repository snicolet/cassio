UNIT UnitPhasesPartie;



INTERFACE







 USES UnitDefCassio;

{ Phases de la partie : phaseDebut, phaseMilieu, phaseFinale, phaseFinaleParfaite}
function CalculePhasePartie(numeroCoup : SInt16) : SInt16;                                                                                                                          ATTRIBUTE_NAME('CalculePhasePartie')
function GenreReflexionToPhasePartie(genre : SInt32) : SInt32;                                                                                                                      ATTRIBUTE_NAME('GenreReflexionToPhasePartie')
procedure InterruptionCarPhasePartieChange;                                                                                                                                         ATTRIBUTE_NAME('InterruptionCarPhasePartieChange')

{ Changements de phases }
procedure DetermineMomentFinDePartie;                                                                                                                                               ATTRIBUTE_NAME('DetermineMomentFinDePartie')
procedure DoChangeHumCtreHum;                                                                                                                                                       ATTRIBUTE_NAME('DoChangeHumCtreHum')
procedure DoChangeCouleur;                                                                                                                                                          ATTRIBUTE_NAME('DoChangeCouleur')
procedure DoFinaleGagnante(selectedByMenu : boolean);                                                                                                                               ATTRIBUTE_NAME('DoFinaleGagnante')
procedure DoFinaleOptimale(selectedByMenu : boolean);                                                                                                                               ATTRIBUTE_NAME('DoFinaleOptimale')
procedure DoChangeEvaluationTotale(selectedByMenu : boolean);                                                                                                                       ATTRIBUTE_NAME('DoChangeEvaluationTotale')
procedure DoMilieuDeJeu(selectedByMenu : boolean);                                                                                                                                  ATTRIBUTE_NAME('DoMilieuDeJeu')
procedure DoMilieuDeJeuNormal(combienDeCoups : SInt16; selectedByMenu : boolean);                                                                                                   ATTRIBUTE_NAME('DoMilieuDeJeuNormal')
procedure DoMilieuDeJeuAnalyse(selectedByMenu : boolean);                                                                                                                           ATTRIBUTE_NAME('DoMilieuDeJeuAnalyse')
procedure SetGameMode(typeDeJeuDemande : SInt16);                                                                                                                                   ATTRIBUTE_NAME('SetGameMode')

{ Derniere reflexion effectuee par Cassio : ReflGagnant, ReflParfait, ReflMilieu, etc}
procedure SetGenreDerniereReflexionDeCassio(typeReflexion,numeroCoup : SInt32);                                                                                                     ATTRIBUTE_NAME('SetGenreDerniereReflexionDeCassio')
function GenreDerniereReflexion : SInt32;                                                                                                                                           ATTRIBUTE_NAME('GenreDerniereReflexion')
function NumeroDuCoupDerniereReflexion : SInt32;                                                                                                                                    ATTRIBUTE_NAME('NumeroDuCoupDerniereReflexion')
function PhasePartieDerniereReflexion : SInt32;                                                                                                                                     ATTRIBUTE_NAME('PhasePartieDerniereReflexion')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitMenus, UnitAffichageReflexion, UnitGestionDuTemps, UnitModes, UnitPalette, UnitRapport, UnitCarbonisation, UnitRetrograde
    , UnitNormalisation, UnitAffichagePlateau, MyMathUtils, SNMenus, MyStrings, UnitPositionEtTrait ;
{$ELSEC}
    {$I prelink/PhasesPartie.lk}
{$ENDC}


{END_USE_CLAUSE}











var gDerniereReflexionDeCassio :
      record
        genre        : SInt32;
        numeroDuCoup : SInt32;
      end;


function CalculePhasePartie(numeroCoup : SInt16) : SInt16;
begin
  CalculePhasePartie := phaseDebut;
  if numeroCoup >  finDuDebut          then CalculePhasePartie := phaseMilieu;
  if numeroCoup >= finDePartie         then CalculePhasePartie := phaseFinale;
  if numeroCoup >= finDePartieOptimale then CalculePhasePartie := phaseFinaleParfaite;
end;


function GenreReflexionToPhasePartie(genre : SInt32) : SInt32;
begin
  case genre of

    ReflPasDeDonnees                     : GenreReflexionToPhasePartie :=  phaseDebut;
    ReflZebraBookEval                    : GenreReflexionToPhasePartie :=  phaseDebut;
    ReflZebraBookEvalSansDouteGagnant    : GenreReflexionToPhasePartie :=  phaseDebut;
    ReflZebraBookEvalSansDoutePerdant    : GenreReflexionToPhasePartie :=  phaseDebut;

    ReflRetrogradeMilieu                 : GenreReflexionToPhasePartie :=  phaseMilieu;
    ReflMilieuExhaustif                  : GenreReflexionToPhasePartie :=  phaseMilieu;
    ReflMilieu                           : GenreReflexionToPhasePartie :=  phaseMilieu;

    ReflGagnant                          : GenreReflexionToPhasePartie :=  phaseFinale;
    ReflGagnantExhaustif                 : GenreReflexionToPhasePartie :=  phaseFinale;
    ReflAnnonceGagnant                   : GenreReflexionToPhasePartie :=  phaseFinale;
    ReflRetrogradeGagnant                : GenreReflexionToPhasePartie :=  phaseFinale;
    ReflTriGagnant                       : GenreReflexionToPhasePartie :=  phaseFinale;
    ReflRetrogradeGagnantPhaseGagnant    : GenreReflexionToPhasePartie :=  phaseFinale;

    ReflParfait                          : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflParfaitExhaustif                 : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflAnnonceParfait                   : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflRetrogradeParfait                : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflTriParfait                       : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflParfaitPhaseGagnant              : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflParfaitExhaustPhaseGagnant       : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflParfaitPhaseRechScore            : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflRetrogradeParfaitPhaseGagnant    : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflRetrogradeParfaitPhaseRechScore  : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflScoreDejaConnuFinale             : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;
    ReflScoreDeCeCoupConnuFinale         : GenreReflexionToPhasePartie :=  phaseFinaleParfaite;

    otherwise
      begin
        WritelnNumDansRapport('WARNING !! genre inconnu dans GenreReflexionToPhasePartie, prévenez Stéphane ! genre = ',genre);
      end;
  end;
end;



procedure DetermineMomentFinDePartie;
var i,n : SInt16;
begin
  finDePartie := finDePartieVitesseMac;
  finDePartieOptimale := finDePartieOptimaleVitesseMac;
  if jeuInstantane & not(enTournoi)
   then
    begin
      finDePartie := finDePartie+5;
      finDePartieOptimale := finDePartieOptimale+7;
      if NiveauJeuInstantane < NiveauChampions then
        begin
          finDePartie := finDePartie+2;
          finDePartieOptimale := finDePartieOptimale+1;
        end;
    end
   else
    if (GetCadence = minutes3) & not(enTournoi) then
      begin
        finDePartie := finDePartie+1;
        finDePartieOptimale := finDePartieOptimale+3;
      end;
  if CassioEstEnModeSolitaire then
    begin
      i := 0;
      repeat
        i := i+1;
      until (GetNiemeCoupPartieCourante(i) <> coupInconnu) | (i >= 60);
      if i > nbreCoup then i := nbreCoup;
      finDePartie := i-2;
      finDePartieOptimale := i-2;
    end;

  if enTournoi then
    begin
      n := Min(finDePartie,finDePartieOptimale);
      finDePartie := n + 2;
      finDePartieOptimale := n + 2;
    end;

  // WritelnNumDansRapport('    finale gagnante au coup ',finDePartie+1);
  // WritelnNumDansRapport('    finale parfaite au coup ',finDePartieOptimale+1);

  phaseDeLaPartie := CalculePhasePartie(nbreCoup);
end;


procedure DoChangeHumCtreHum;
begin
  HumCtreHum := not(HumCtreHum);
  DessineIconesChangeantes;
  if afficheSuggestionDeCassio & HumCtreHum then EffaceSuggestionDeCassio;
  AjusteSleep;
  if HumCtreHum then MyDisableItem(PartieMenu,ForceCmd);
  AfficheDemandeCoup;
  if afficheMeilleureSuite then EffaceAnnonceFinaleSiNecessaire;
  reponsePrete := false;
  RefleSurTempsJoueur := false;
  {WritelnStringAndBooleanDansRapport('a la fin de DoChangeHumCtreHum, HumCtreHum = ',HumCtreHum);}
  LanceInterruptionSimpleConditionnelle('DoChangeHumCtreHum');
  vaDepasserTemps := false;
  if HumCtreHum then
    begin
      ReinitilaliseInfosAffichageReflexion;
      if affichageReflexion.doitAfficher then EffaceReflexion(HumCtreHum);
    end;
end;


procedure DoChangeCouleur;
begin
  couleurMacintosh := -couleurMacintosh;
  DessineIconesChangeantes;

  if afficheSuggestionDeCassio then EffaceSuggestionDeCassio;
  if not(HumCtreHum) & (AQuiDeJouer <> couleurMacintosh)
     then
       begin
         MyDisableItem(PartieMenu,ForceCmd);
         AfficheDemandeCoup;
       end;
end;



procedure DoFinaleGagnante(selectedByMenu : boolean);
begin
 if (60-nbreCoup) <= kNbMaxNiveaux-2 then
   begin
    if nbreCoup < finDePartie then
      begin
        if not(selectedByMenu) | PeutArreterAnalyseRetrograde then
          begin
            finDePartie := nbreCoup;
            if selectedByMenu & (finDePartie >= 2) then dec(finDePartie);

            if finDePartie > finDePartieOptimale then finDePartieOptimale := finDePartie;
            InterruptionCarPhasePartieChange;
          end;
      end
     else
      begin
       if nbreCoup >= finDePartieOptimale then
         begin
           if not(selectedByMenu) | PeutArreterAnalyseRetrograde then
             begin
               finDePartieOptimale := nbreCoup + 1;
               if selectedByMenu & (finDePartieOptimale <= 59) then inc(finDePartieOptimale);

               if finDePartie > finDePartieOptimale then finDePartieOptimale := finDePartie;
               InterruptionCarPhasePartieChange;
             end;
         end;
       end;
  end;
end;


procedure DoFinaleOptimale(selectedByMenu : boolean);
var finDePartieOptTest : SInt16;
begin
 if (60-nbreCoup) <= kNbMaxNiveaux-2 then
  begin
    finDePartieOptTest := nbreCoup;
    if not(HumCtreHum) & (AQuiDeJouer = -couleurMacintosh) then
      finDePartieOptTest := nbreCoup-1;

    if (finDePartieOptTest < finDePartieOptimale)  then
      begin
        if not(selectedByMenu) | PeutArreterAnalyseRetrograde then
          begin
            if selectedByMenu & (finDePartieOptTest <= 59) then dec(finDePartieOptTest);

            finDePartieOptimale := finDePartieOptTest;
            if (finDePartie > finDePartieOptimale) then finDePartie := finDePartieOptimale;
            InterruptionCarPhasePartieChange;
          end;
      end;
  end;
end;


procedure DoChangeEvaluationTotale(selectedByMenu : boolean);
  begin  {$UNUSED selectedByMenu}
    avecEvaluationTotale := not(avecEvaluationTotale);
    if (avecEvaluationTotale = false) then
      begin
        analyseIntegraleDeFinale := false;
        doitEcrireReflexFinale := true;
      end;
  end;


procedure DoMilieuDeJeu(selectedByMenu : boolean);
  begin
    if (nbreCoup >= finDePartie) then
      begin
        if not(selectedByMenu) | PeutArreterAnalyseRetrograde then
          begin
            finDePartie := nbreCoup+1;
            if (selectedByMenu) & (finDePartie <= 59) then inc(finDePartie);

            if (finDePartie > finDePartieOptimale) then finDePartieOptimale := finDePartie;
            InterruptionCarPhasePartieChange;
          end;
      end;
    FixeMarqueSurMenuMode(nbreCoup);
  end;


procedure DoMilieuDeJeuNormal(combienDeCoups : SInt16; selectedByMenu : boolean);
  begin
    nbCoupsEnTete := combienDeCoups;

    if (nbCoupsEnTete = 1)
      then MySetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ReadStringFromRessource(MenusChangeantsID,18));

    If avecEvaluationTotale then DoChangeEvaluationTotale(selectedByMenu);
    DoMilieuDeJeu(selectedByMenu);
  end;


procedure DoMilieuDeJeuAnalyse(selectedByMenu : boolean);
  begin
    If not(avecEvaluationTotale) then DoChangeEvaluationTotale(selectedByMenu);
    DoMilieuDeJeu(selectedByMenu);
  end;


procedure SetGameMode(typeDeJeuDemande : SInt16);
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
end;


procedure SetGenreDerniereReflexionDeCassio(typeReflexion,numeroCoup : SInt32);
begin
  with gDerniereReflexionDeCassio do
    begin
      genre        := typeReflexion;
      numeroDuCoup := numeroCoup;
    end;
end;


function GenreDerniereReflexion : SInt32;
begin
  GenreDerniereReflexion := gDerniereReflexionDeCassio.genre;
end;


function NumeroDuCoupDerniereReflexion : SInt32;
begin
  NumeroDuCoupDerniereReflexion := gDerniereReflexionDeCassio.numeroDuCoup;
end;


function PhasePartieDerniereReflexion : SInt32;
begin
  PhasePartieDerniereReflexion := GenreReflexionToPhasePartie(GenreDerniereReflexion);
end;


procedure InterruptionCarPhasePartieChange;
begin
  phaseDeLaPartie := CalculePhasePartie(nbreCoup);
  reponsePrete := false;
  RefleSurTempsJoueur := false;
  InvalidateAnalyseDeFinale;
  vaDepasserTemps := false;
  LanceInterruptionSimpleConditionnelle('InterruptionCarPhasePartieChange');
  FixeMarqueSurMenuMode(nbreCoup);
end;



END.
