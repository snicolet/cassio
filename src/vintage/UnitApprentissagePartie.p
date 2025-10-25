UNIT UnitApprentissagePartie;

INTERFACE







 USES UnitDefCassio;

{Création des cellules dans le graphe}

{Accès depuis l'exterieur, pour effectivement apprendre des parties}
procedure ApprendPartie(var fichier : Graphe; partieStr : String255; const couleurGagnante : String255; apresQuelCoup : SInt16);
procedure ApprendPartieIsolee(partieStr : String255; const couleurGagnante : String255; apresQuelCoup : SInt16);
procedure ApprendToutesLesPartiesActives;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage
{$IFC NOT(USE_PRELINK)}
    , UnitEntreesSortiesGraphe, UnitCalculsApprentissage, MyStrings, UnitServicesRapport, UnitEvenement, UnitAccesNouveauFormat, UnitRapportImplementation
    , UnitRapport, UnitScannerUtils, UnitFenetres, SNEvents, UnitNormalisation, UnitPackedThorGame, UnitScannerOthellistique, UnitRapportWindow
    , UnitAccesGraphe ;
{$ELSEC}
    ;
    {$I prelink/ApprentissagePartie.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure ApprendPartie(var fichier : Graphe;
                        partieStr : String255;
                        const couleurGagnante : String255;     (* 'N','E','B' ou 'X' si on ne sait pas *)
                        ApresQuelCoup : SInt16);       (*   < 0 si on ne sait pas *)
var s60 : PackedThorGame;
    s120 : String255;
    path : ListeDeCellules;
    autreCoupDiag : boolean;
    cellule : CelluleRec;
begin
  s120 := partieStr;
  Normalisation(s120,autreCoupDiag,false);
  TraductionAlphanumeriqueEnThor(s120,s60);

  if debuggage.apprentissage then
    begin
      WritelnDansRapport('dans ApprendPartie : avant CreePartieDansGrapheApprentissage');
      WritelnDansRapport('s120 = '+s120);
      AttendFrappeClavier;
    end;

  CreePartieDansGrapheApprentissage(fichier,s60,path);

  if debuggage.apprentissage then
    begin
      WritelnDansRapport('dans ApprendPartie : après CreePartieDansGrapheApprentissage');
      AttendFrappeClavier;
    end;

  if (couleurGagnante = CaracterePourNoir)  or
     (couleurGagnante = CaracterePourBlanc) or
     (couleurGagnante = CaracterePourEgalite) then
  if (ApresQuelCoup > 0) and (ApresQuelCoup <= path.cardinal) then
    begin
      if debuggage.apprentissage then
        begin
          WritelnNumDansRapport('dans ApprendPartie : ApresQuelCoup = ',ApresQuelCoup);
          AttendFrappeClavier;

          WritelnNumDansRapport('dans ApprendPartie : path.liste[ApresQuelCoup].numeroCellule = ',path.liste[ApresQuelCoup].numeroCellule);
          AttendFrappeClavier;
        end;

      LitCellule(fichier,path.liste[ApresQuelCoup].numeroCellule,cellule);

      if debuggage.apprentissage then
        begin
          WritelnDansRapport('dans ApprendPartie : après LitCellule');
          AttendFrappeClavier;
        end;

      {ici il faudrait mettre des kGainAbsolu, kNulleAbsolue, kPerteAbsolue … }
      if (couleurGagnante = CaracterePourEgalite) then
        SetValeurMinimax(cellule,kNulleDansT) else
      if ((couleurGagnante = CaracterePourBlanc) and (GetCouleur(cellule) = Blanc)) or
         ((couleurGagnante = CaracterePourNoir) and (GetCouleur(cellule) = Noir)) then
        SetValeurMinimax(cellule,kGainDansT) else
      if ((couleurGagnante = CaracterePourBlanc) and (GetCouleur(cellule) = Noir)) or
         ((couleurGagnante = CaracterePourNoir) and (GetCouleur(cellule) = Blanc)) then
        SetValeurMinimax(cellule,kPerteDansT);

      EcritCellule(fichier,path.liste[ApresQuelCoup].numeroCellule,cellule);

      if debuggage.apprentissage then
        begin
          AfficheCelluleDansRapport(fichier,path.liste[ApresQuelCoup].numeroCellule,cellule);

          WritelnDansRapport('dans ApprendPartie : avant PropageValeurMinimaxDansT');
          AttendFrappeClavier;
        end;

      PropageToutesLesValeursDansLeGraphe(fichier,path.liste[ApresQuelCoup].numeroCellule);

      if debuggage.apprentissage then
        begin
          WritelnDansRapport('dans ApprendPartie : apres PropageValeurMinimaxDansT');
          AttendFrappeClavier;
        end;

    end;

end;



procedure ApprendToutesLesPartiesActives;
const CoupDuCalculOptimalDansThor = 40;
var i,nroReference : SInt32;
    s60 : PackedThorGame;
    s120 : String255;
    s255 : String255;
    GainTheorique,GainReel : String255;
    ScoreReel : SInt16;
    fichier : Graphe;
    n1,n2 : SInt32;
    grapheDejaOuvertALArrivee : boolean;
begin

  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      {debuggage.apprentissage := true;}

      if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true);
      if FenetreRapportEstOuverte then SelectWindowSousPalette(GetRapportWindow);
      WritelnDansRapport('');
      WritelnDansRapport('nb de partie(s) à apprendre = '+NumEnString(nbPartiesActives));

      n1 := GetNbreEcrituresDansGraphe;
      n2 := GetNbreLecturesDansGraphe;

      i := 1;
      while (i <= nbPartiesActives) and not(Quitter) do
        begin
          nroReference := tableNumeroReference^^[i];
          GainTheorique := GetGainTheoriqueParNroRefPartie(nroReference);
          ScoreReel := GetScoreReelParNroRefPartie(nroReference);
          if ScoreReel > 32 then GainReel := CaracterePourNoir else
          if ScoreReel = 32 then GainReel := CaracterePourEgalite else
          if ScoreReel < 32 then GainReel := CaracterePourBlanc;


          {if (GainReel = GainTheorique) then}
            begin
              if debuggage.apprentissage then
                begin
                  WritelnDansRapport('apprentissage de la partie #'+NumEnString(nroReference));
                  AttendFrappeClavier;
                end;

              ExtraitPartieTableStockageParties(nroreference,s60);

              if debuggage.apprentissage then
                begin
                  WritelnDansRapport('apres ExtraitPartieTableStockageParties');
                  AttendFrappeClavier;
                end;

              SHORTEN_PACKED_GAME(s60, CoupDuCalculOptimalDansThor+1);
              TraductionThorEnAlphanumerique(s60,s255);
              s120 := s255;

              if debuggage.apprentissage then
                begin
                  WritelnDansRapport('appel de ApprendPartie');
                  AttendFrappeClavier;
                end;

              ApprendPartie(fichier,s120,GainTheorique,CoupDuCalculOptimalDansThor);
            end;

          if (i mod 40) = 0 then WritelnDansRapport(NumEnString(i)+CharToString('…'));


          if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;

          i := i+1;
        end;


      WritelnDansRapport('nbre Ecritures de cellules = '+NumEnString(GetNbreEcrituresDansGraphe-n1));
      WritelnDansRapport('nbre lectures de cellules = '+NumEnString(GetNbreLecturesDansGraphe-n2));

      WritelnDansRapport('apprentissage terminé.');
      WritelnDansRapport('');

      {debuggage.apprentissage := false;}

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
  Quitter := false;
end;

procedure ApprendPartieIsolee(partieStr : String255;
                              const couleurGagnante : String255;     (* 'N','E','B' ou 'X' si on ne sait pas *)
                              ApresQuelCoup : SInt16);       (*   < 0 si on ne sait pas *)
var fichier : Graphe;
    grapheDejaOuvertALArrivee : boolean;
    diagonaleInversee : boolean;
begin
  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      Normalisation(partieStr,diagonaleInversee,true);
      partieStr := TPCopy(partieStr,1,2*ApresQuelCoup+2);
      ApprendPartie(fichier,partieStr,couleurGagnante,ApresQuelCoup);

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;


END.
