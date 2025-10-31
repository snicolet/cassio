UNIT UnitProblemeDePriseDeCoin;



INTERFACE





 USES UnitDefCassio;





{ Initialisation de l'unité }
procedure InitUnitProblemeDePriseDeCoin;
procedure LibereMemoireUnitProblemeDePriseDeCoin;


{ On peut parametrer un peu le type de problemes a chercher }
procedure SetIntervalleDeDifficultePourProblemeDePriseDeCoin(difficulteMin,difficulteMax : SInt32);
procedure GetIntervalleDeDifficultePourProblemeDePriseDeCoin(var difficulteMin,difficulteMax : SInt32);
procedure SetRefuserDeDefensesTrivialesDeCoin(flag : boolean);
function DoitRefuserDefensesTrivialesDeCoin : boolean;


{ Fonction de recherche de problemes de coins }
function RechercheDeProblemeDePriseDeCoinEnCours : boolean;
procedure ChercherUnProblemeDePriseDeCoinDansListe(premierCoup,dernierCoup : SInt32);
procedure ChercherUnProblemeDePriseDeCoinDansPositionCourante;
procedure ChercherUnProblemeDePriseDeCoinAleatoire(premierCoup,dernierCoup : SInt32);


{ Fonctions d'interface utilisateur }
procedure RevenirAuProblemeDePriseDeCoinPrecedent;
procedure EcrireEnonceProblemePriseDeCoinDansRapport(var enonce : ProblemePriseDeCoin);
procedure EcrireCauseRejetPbDeCoinDansRapport(var enonce : ProblemePriseDeCoin);
procedure PlaquerProblemeDePriseDeCoin(enonce : ProblemePriseDeCoin);


{ Fonctions pour créer automatiquement les légendes des diagrammes pour le presse-papier }
procedure SetDoitNumeroterProblemesDePriseDeCoin(flag : boolean);
function DoitNumeroterProblemesDePriseDeCoin : boolean;
function EstUnEnonceNumeroteDeProblemeDeCoin(const s : String255; var numero : SInt32) : boolean;
procedure SetNumeroProblemeDePriseDeCoin(numero : SInt32);
procedure SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(flag : boolean);
function PeutIncrementerNumerotationDiagrammeDePriseDeCoin : boolean;
function GetNumeroDuProblemeDePriseDeCoinDansCetEnonce(const chaineEnonce : String255) : SInt32;
function GetEnonceProblemeDePriseDeCoinEnChaine(var enonce : ProblemePriseDeCoin) : String255;
function GetEnonceCourtProblemeDePriseDeCoinEnChaine(var enonce : ProblemePriseDeCoin) : String255;
function GetEnonceNumeroteProblemeDePriseDeCoin(var enonce : ProblemePriseDeCoin) : String255;


{ Procedures internes }
function DoMoveProblemePriseDeCoin(var probleme : ProblemePriseDeCoin; whichMove : SInt32) : boolean;
function TerminaisonDansAlgoProblemePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32; var valeurDuCoup : SInt32) : boolean;
procedure UndoMoveProblemePriseDeCoin(var probleme : ProblemePriseDeCoin);
function FiltreRechercheProblemeDePriseDeCoin(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;


{ Les fonctions mutuellement recursives de recherche d'une solution }
{ Ici alpha et beta ont une semantique un peu differente d'une recherche
  de finale :
     alpha = on a deja prouve que "attaquant" avait une solution en alpha coups au plus
     beta  = on a deja prouve que "defenseur" avait une defense de beta coups au moins
  Evidemment, il faut lancer la recherche avec une fenetre [alpha,beta] = [infini,0]
}
function DefensePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32) : SInt32;
function AttaquePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32) : SInt32;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitStrategie, UnitListe, UnitCurseur, MyStrings, UnitSetUp, UnitRapport
    , UnitStringSet, UnitActions, UnitGestionDuTemps, UnitRapportImplementation, UnitScannerUtils, UnitSolitaire, UnitJeu, SNEvents
    , UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/ProblemeDePriseDeCoin.lk}
{$ENDC}


{END_USE_CLAUSE}















const kHorizonMaxProblemesPriseDeCoin = 20;

var pilePositionsIntermediaires : array[0..kHorizonMaxProblemesPriseDeCoin] of PositionEtTraitRec;
    gRechercheProblemesDePriseDeCoin :
       record
          enCours                           : boolean;
          interrompue                       : boolean;
          premierCoup                       : SInt32;
          dernierCoup                       : SInt32;
          nbTrouves                         : SInt32;
          difficulteMin                     : SInt32;
          difficulteMax                     : SInt32;
          nroDeDepartDansLaListe            : SInt32;
          pasDeDefenseTrivialeDeCoin        : boolean;
          rechercheListeEnCours             : boolean;
          nroPartieDerniereRechercheReussie : SInt32;
          numeroDuCoupDuProbleme            : SInt32;
          verbose                           : SInt32;
       end;
    gNumerotationDiagrammeProblemeDeCoin : SInt32;
    gPeutIncrementerNumerotationDiagrammeDePriseDeCoin : boolean;
    gDoitNumeroterProbleme : boolean;
    gProblemePrecedent : record
                           nbProblemesDejaProposes : SInt32;
                           problemeCourant   : ProblemePriseDeCoin;
                           problemePrecedent : ProblemePriseDeCoin;
                         end;

    (* pileDesCoupsJouees          : array[0..kHorizonMaxProblemesPriseDeCoin] of SInt32; *)



procedure InitUnitProblemeDePriseDeCoin;
begin
  SetIntervalleDeDifficultePourProblemeDePriseDeCoin(2,5);
  gRechercheProblemesDePriseDeCoin.enCours                           := false;
  gRechercheProblemesDePriseDeCoin.rechercheListeEnCours             := false;
  gRechercheProblemesDePriseDeCoin.nroDeDepartDansLaListe            := 0;
  gRechercheProblemesDePriseDeCoin.nroPartieDerniereRechercheReussie := 0;
  gRechercheProblemesDePriseDeCoin.verbose                           := 0;


  SetNumeroProblemeDePriseDeCoin(0);
  SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(true);  {le prochain commencera à 1}
  SetDoitNumeroterProblemesDePriseDeCoin(true);


  SetRefuserDeDefensesTrivialesDeCoin(false);

  gProblemePrecedent.nbProblemesDejaProposes := 0;
end;


procedure SetRefuserDeDefensesTrivialesDeCoin(flag : boolean);
begin
  gRechercheProblemesDePriseDeCoin.pasDeDefenseTrivialeDeCoin := flag;
end;


function DoitRefuserDefensesTrivialesDeCoin : boolean;
begin
  DoitRefuserDefensesTrivialesDeCoin := gRechercheProblemesDePriseDeCoin.pasDeDefenseTrivialeDeCoin;
end;


procedure LibereMemoireUnitProblemeDePriseDeCoin;
begin
end;


function RechercheDeProblemeDePriseDeCoinEnCours : boolean;
begin
  RechercheDeProblemeDePriseDeCoinEnCours := gRechercheProblemesDePriseDeCoin.enCours;
end;

procedure SetDoitNumeroterProblemesDePriseDeCoin(flag : boolean);
begin
  gDoitNumeroterProbleme := flag;
end;


function DoitNumeroterProblemesDePriseDeCoin : boolean;
begin
  DoitNumeroterProblemesDePriseDeCoin := gDoitNumeroterProbleme;
end;


procedure SetIntervalleDeDifficultePourProblemeDePriseDeCoin(difficulteMin,difficulteMax : SInt32);
begin
  gRechercheProblemesDePriseDeCoin.difficulteMin := difficulteMin;
  gRechercheProblemesDePriseDeCoin.difficulteMax := difficulteMax;
end;

procedure GetIntervalleDeDifficultePourProblemeDePriseDeCoin(var difficulteMin,difficulteMax : SInt32);
begin
  difficulteMin := gRechercheProblemesDePriseDeCoin.difficulteMin;
  difficulteMax := gRechercheProblemesDePriseDeCoin.difficulteMax;
end;

procedure SetNumeroProblemeDePriseDeCoin(numero : SInt32);
begin
  gNumerotationDiagrammeProblemeDeCoin := numero;
end;

procedure SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(flag : boolean);
begin
  gPeutIncrementerNumerotationDiagrammeDePriseDeCoin := flag;
end;

function PeutIncrementerNumerotationDiagrammeDePriseDeCoin : boolean;
begin
  PeutIncrementerNumerotationDiagrammeDePriseDeCoin := gPeutIncrementerNumerotationDiagrammeDePriseDeCoin;
end;


function SolutionEstUneDefenseDeCoinTriviale(var probleme : ProblemePriseDeCoin) : boolean;
var nbCoinsEnPriseAvantSolution : SInt32;
    nbCoinsEnPriseApresSolution : SInt32;
    platAux : PositionEtTraitRec;
begin
  SolutionEstUneDefenseDeCoinTriviale := false;

  with probleme do
    begin
      if (solution.nbCoupsSolutions = 1) then
        begin
          nbCoinsEnPriseAvantSolution := NbCoinsPrenables(defenseur,currentBoard.position);

          if (nbCoinsEnPriseAvantSolution = 1) then
            begin
              platAux := currentBoard;

              if UpdatePositionEtTrait(platAux,solution.coup[1]) then
                begin
                  nbCoinsEnPriseApresSolution := NbCoinsPrenables(defenseur,platAux.position);

                  SolutionEstUneDefenseDeCoinTriviale := (nbCoinsEnPriseApresSolution < nbCoinsEnPriseAvantSolution);
                end;

            end;
        end;
    end;
end;


function SolutionEstUneCaseX(var probleme : ProblemePriseDeCoin) : boolean;
begin
  SolutionEstUneCaseX := false;

  with probleme do
    if (solution.nbCoupsSolutions = 1) and
       (solution.coup[1] in [22,27,72,77])
        then SolutionEstUneCaseX := true;

end;



function DoMoveProblemePriseDeCoin(var probleme : ProblemePriseDeCoin; whichMove : SInt32) : boolean;
var coupLegal : boolean;
    traitDuCoup : SInt32;
begin
  with probleme do
    begin
      traitDuCoup := GetTraitOfPosition(currentBoard);
      coupLegal   := UpdatePositionEtTrait(currentBoard,whichMove);
      if coupLegal then
        begin

          (*
          if (gRechercheProblemesDePriseDeCoin.verbose >= 1) then
            begin
              WritelnDansRapport('');
              if (traitDuCoup = attaquant)
                then
                  if traitDuCoup = pionNoir
                    then WritelnStringAndCoupDansRapport(' DoMove (B) '+IntToStr((distanceDepart div 2)+1)+'.',whichMove)
                    else WritelnStringAndCoupDansRapport(' DoMove (W) '+IntToStr((distanceDepart div 2)+1)+'.',whichMove)
                else
                  if traitDuCoup = pionNoir
                    then WritelnStringAndCoupDansRapport(' DoMove (B) '+IntToStr((distanceDepart div 2)+1)+' ...',whichMove)
                    else WritelnStringAndCoupDansRapport(' DoMove (W) '+IntToStr((distanceDepart div 2)+1)+' ...',whichMove)
            end;
          *)

          (* pileDesCoupsJouees[distanceDepart] := whichMove; *)

          SetTraitOfPosition(pilePositionsIntermediaires[distanceDepart],traitDuCoup);
          inc(distanceDepart);
          pilePositionsIntermediaires[distanceDepart] := currentBoard;
          if (traitDuCoup = attaquant) then inc(nbCoupsJouesParAttaquant);
        end;
      DoMoveProblemePriseDeCoin := coupLegal;
    end;
end;


procedure UndoMoveProblemePriseDeCoin(var probleme : ProblemePriseDeCoin);
begin
  with probleme do
    if (distanceDepart > 0) then
      begin
        (* if (gRechercheProblemesDePriseDeCoin.verbose >= 1) then WritelnDansRapport('UndoMove'); *)

        dec(distanceDepart);
        currentBoard := pilePositionsIntermediaires[distanceDepart];
        if GetTraitOfPosition(currentBoard) = attaquant then dec(nbCoupsJouesParAttaquant);
      end;
end;


function TerminaisonDansAlgoProblemePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32; var valeurDuCoup : SInt32) : boolean;
begin  {$UNUSED beta}
  with probleme do
    begin
      if (nbCoupsJouesParAttaquant >= horizon) or
         (nbCoupsJouesParAttaquant >= alpha) then
        begin
          if (NbCoins(attaquant,currentBoard.position) > 0)
            then valeurDuCoup := nbCoupsJouesParAttaquant
            else valeurDuCoup := 1000;
          TerminaisonDansAlgoProblemePriseDeCoin := true;
          exit;
        end;
    end;
  TerminaisonDansAlgoProblemePriseDeCoin := false;
end;


function DefensePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32) : SInt32;
var i,whichSquare : SInt32;
    valeurMeilleureDefenseTrouvee : SInt32;
    trait,valeurDuCoup : SInt32;
label cut_off;
begin
  with probleme do
    begin

      if TerminaisonDansAlgoProblemePriseDeCoin(probleme,alpha,beta,valeurDuCoup) then
        begin
          DefensePriseDeCoin := valeurDuCoup;
          exit;
        end;

      valeurMeilleureDefenseTrouvee := -10000;
      for i := 1 to 64 do
        begin
          whichSquare := othellier[i];
          if DoMoveProblemePriseDeCoin(probleme,whichSquare) then
            begin
              if not(TerminaisonDansAlgoProblemePriseDeCoin(probleme,alpha,beta,valeurDuCoup)) then
                begin
                  trait := GetTraitOfPosition(currentBoard);

                  (* appel recursif *)
                  if (trait = attaquant) then valeurDuCoup := AttaquePriseDeCoin(probleme,alpha,beta) else
                  if (trait = defenseur) then valeurDuCoup := DefensePriseDeCoin(probleme,alpha,beta) else
                  if (trait = pionVide) then
                    if (NbCoins(attaquant,currentBoard.position) > 0)
                      then valeurDuCoup := nbCoupsJouesParAttaquant
                      else valeurDuCoup := 1000;

                end;

              UndoMoveProblemePriseDeCoin(probleme);

              { Le defenseur cherche a maximiser le temps utilise par l'attaquant pour arriver a un coin }
              if (valeurDuCoup > valeurMeilleureDefenseTrouvee)
                then valeurMeilleureDefenseTrouvee := valeurDuCoup;

              { Gestion des coupures alpha-beta . Ici alpha et beta ont une semantique
                un peu differente d'une recherche de finale :
                alpha = on a deja prouve que "attaquant" avait une solution en alpha coups au plus
                beta  = on a deja prouve que "defenseur" avait une defense de beta coups au moins
               }
              if (valeurDuCoup > beta) then beta := valeurDuCoup;
              if (valeurDuCoup >= alpha) then goto cut_off;

            end;
        end;

      cut_off:
      DefensePriseDeCoin := valeurMeilleureDefenseTrouvee;
    end;
end;



function AttaquePriseDeCoin(var probleme : ProblemePriseDeCoin; alpha,beta : SInt32) : SInt32;
var i,whichSquare : SInt32;
    valeurMeilleureAttaqueTrouvee : SInt32;
    trait,valeurDuCoup : SInt32;
    indiceMaxDeGenerationDesCoups : SInt32;
label cut_off;
begin
  with probleme do
    begin

      if TerminaisonDansAlgoProblemePriseDeCoin(probleme,alpha,beta,valeurDuCoup) then
        begin
          AttaquePriseDeCoin := valeurDuCoup;
          exit;
        end;


      valeurMeilleureAttaqueTrouvee := 10000;

      (* optimisation : si on est juste un coup avant l'horizon de recherche,
                        on ne genere que les coups dans les coins
       *)
      if (nbCoupsJouesParAttaquant >= horizon - 1) or (nbCoupsJouesParAttaquant >= alpha - 1)
        then indiceMaxDeGenerationDesCoups := 4   { comme cela on ne genere que les coins }
        else indiceMaxDeGenerationDesCoups := 64; { comme ceci on genere tout l'othellier }


      for i := 1 to indiceMaxDeGenerationDesCoups do
        begin
          whichSquare := othellier[i];
          if DoMoveProblemePriseDeCoin(probleme,whichSquare) then
            begin
              if estUnCoin[whichSquare]
                then
                  begin
                    AttaquePriseDeCoin := nbCoupsJouesParAttaquant;
                    UndoMoveProblemePriseDeCoin(probleme);
                    exit;
                  end
                else
                  begin
                    if not(TerminaisonDansAlgoProblemePriseDeCoin(probleme,alpha,beta,valeurDuCoup)) then
                      begin
                        trait := GetTraitOfPosition(currentBoard);

                        (* Appel recursif *)
                        if (trait = defenseur) then valeurDuCoup := DefensePriseDeCoin(probleme,alpha,beta) else
                        if (trait = attaquant) then valeurDuCoup := AttaquePriseDeCoin(probleme,alpha,beta) else
                        if (trait = pionVide) then
                          if (NbCoins(attaquant,currentBoard.position) > 0)
                            then valeurDuCoup := nbCoupsJouesParAttaquant
                            else valeurDuCoup := 1000;

                      end;

                    (*if (nbCoupsJouesParAttaquant = 2) and (pileDesCoupsJouees[0] = 85) then
                      begin
                        WritelnPositionEtTraitDansRapport(currentBoard.position,GetTraitOfPosition(currentBoard));
                        WritelnStringAndCoupDansRapport('whichsquare : ',whichSquare);
                        WritelnNumDansRapport('valeur = ',valeurDuCoup);
                      end;*)

                    UndoMoveProblemePriseDeCoin(probleme);


                    { Attention, a-t-on une solution dupliquee ? }
                    if (nbCoupsJouesParAttaquant = 0) and
                       (valeurDuCoup = valeurMeilleureAttaqueTrouvee) and
                       (valeurDuCoup <= horizon)
                      then
                        begin
                          {WritelnPositionEtTraitDansRapport(currentBoard.position,GetTraitOfPosition(currentBoard));
                          WritelnStringAndCoupDansRapport('solution dupliquée : ',whichSquare);
                          WritelnNumDansRapport('longueur = ',valeurDuCoup);}
                          inc(solution.nbCoupsSolutions);
                          if solution.nbCoupsSolutions <= kNbMaxCoupsSolutions
                            then solution.coup[solution.nbCoupsSolutions] := whichSquare;
                        end;



                    { L'attaquant cherche a minimiser le temps utilise pour arriver a un coin }
                    if (valeurDuCoup < valeurMeilleureAttaqueTrouvee) then
                      begin
                        if (nbCoupsJouesParAttaquant = 0) and
                           (valeurDuCoup <= horizon) then
                          begin
                            solution.coup[1]          := whichSquare;
                            solution.nbCoupsSolutions := 1;

                            {WritelnPositionEtTraitDansRapport(currentBoard.position,GetTraitOfPosition(currentBoard));
                            WritelnStringAndCoupDansRapport('solution initiale : ',whichSquare);
                            WritelnNumDansRapport('longueur = ',valeurDuCoup);}

                          end;

                        valeurMeilleureAttaqueTrouvee := valeurDuCoup;
                      end;

                    { Gestion des coupures alpha-beta . Ici alpha et beta ont une semantique
                      un peu differente d'une recherche de finale :
                      alpha = on a deja prouve que "attaquant" avait une solution en alpha coups au plus
                      beta  = on a deja prouve que "defenseur" avait une defense de beta coups au moins
                     }
                    if (nbCoupsJouesParAttaquant = 0)
                      then
                        begin
                          if (valeurDuCoup < alpha) then alpha := valeurDuCoup + 1;  {pour pouvoir distinguer les solution multiples}
                          if (valeurDuCoup <= beta) then goto cut_off;
                        end
                      else
                        begin
                          if (valeurDuCoup < alpha) then alpha := valeurDuCoup;
                          if (valeurDuCoup <= beta) then goto cut_off;
                        end;

                  end;
            end;
        end;

      cut_off :
      AttaquePriseDeCoin := valeurMeilleureAttaqueTrouvee;
    end;
end;


function EstUnProblemeDePriseDeCoinValable(var position : PositionEtTraitRec; horizonRecherche : SInt32; var outEnonce : ProblemePriseDeCoin) : boolean;
var valeur : SInt32;
    alpha,beta : SInt32;
label clean_up;
begin
  EstUnProblemeDePriseDeCoinValable := false;

  if not(gRechercheProblemesDePriseDeCoin.enCours) then
    begin
      gRechercheProblemesDePriseDeCoin.enCours := true;

      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

      (* on initialise les donnees *)
      with outEnonce do
        begin
          if horizon > kHorizonMaxProblemesPriseDeCoin then horizon := kHorizonMaxProblemesPriseDeCoin;


          attaquant                            := GetTraitOfPosition(position);
          defenseur                            := -GetTraitOfPosition(position);
          currentBoard                         := position;
          horizon                              := horizonRecherche;
          nbCoupsJouesParAttaquant             := 0;
          distanceDepart                       := 0;
          solution.coup[1]                     := 0;
          solution.longueur                    := 0;
          solution.attaquantPasse              := false;
          solution.estUneDefenseDeCoinTriviale := false;
          solution.nbCoupsSolutions            := 0;
          solution.causeRejet                  := kPasDeRejet;
          pilePositionsIntermediaires[0]       := currentBoard;


          if (NbCoins(attaquant,position.position) > 0) then
            begin
              solution.causeRejet := kRejetADejaUnCoin;
              goto clean_up;
            end;

          if (NbCoinsPrenables(attaquant,position.position) > 0) then
            begin
              solution.causeRejet := kRejetPeutDejaPrendreUnCoin;
              goto clean_up;
            end;


          (* on lance la recherche *)
          alpha := horizon + 1;
          beta  := 0;
          valeur := AttaquePriseDeCoin(outEnonce,alpha,beta);


          (* A-t-on trouve une solution valable ? *)
          if (valeur >= gRechercheProblemesDePriseDeCoin.difficulteMin) and
             (valeur <= gRechercheProblemesDePriseDeCoin.difficulteMax) and
             (solution.nbCoupsSolutions = 1) {and
             SolutionEstUneCaseX(outEnonce)}
            then
              begin
                solution.longueur := valeur;

                (* on teste si la solution est une defense de coin triviale *)
                solution.estUneDefenseDeCoinTriviale := SolutionEstUneDefenseDeCoinTriviale(outEnonce);

                if DoitRefuserDefensesTrivialesDeCoin and solution.estUneDefenseDeCoinTriviale
                  then EstUnProblemeDePriseDeCoinValable := false
                  else EstUnProblemeDePriseDeCoinValable := true;

              end
            else
              begin

                if (valeur > gRechercheProblemesDePriseDeCoin.difficulteMax) or
                   (valeur < gRechercheProblemesDePriseDeCoin.difficulteMin) then
                  begin
                    solution.causeRejet  := kRejetPasDeSolutionPbDeCoin;
                  end;

                if (solution.nbCoupsSolutions > 1) then
                  begin
                    solution.longueur    := valeur;
                    solution.causeRejet  := kRejetSolutionsMultiplesPourPbDeCoin;
                  end;

                EstUnProblemeDePriseDeCoinValable := false;
              end;

        end;

      clean_up :
      gRechercheProblemesDePriseDeCoin.enCours := false;

      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
    end;
end;


function FiltreRechercheProblemeDePriseDeCoin(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;
begin {$unused numeroReference}

  (*
  WritelnStringAndBooleanDansRapport('gRechercheProblemesDePriseDeCoin.enCours = ',gRechercheProblemesDePriseDeCoin.enCours);
  WritelnStringAndBooleanDansRapport('Quitter = ',Quitter);
  WritelnStringAndBooleanDansRapport('gRechercheProblemesDePriseDeCoin.interrompue = ',gRechercheProblemesDePriseDeCoin.interrompue);
  WritelnStringAndBooleanDansRapport('numeroReference >= gRechercheProblemesDePriseDeCoin.nroDeDepartDansLaListe = ',(numeroReference >= gRechercheProblemesDePriseDeCoin.nroDeDepartDansLaListe));
  WritelnStringAndBooleanDansRapport('PartieEstActive(numeroReference) = ',PartieEstActive(numeroReference));
  *)

  result := numeroDansLaListe;

  FiltreRechercheProblemeDePriseDeCoin := not(gRechercheProblemesDePriseDeCoin.enCours) and
                                          not(Quitter) and
                                          not(gRechercheProblemesDePriseDeCoin.interrompue) and
                                          (numeroDansLaListe >= gRechercheProblemesDePriseDeCoin.nroDeDepartDansLaListe) and
                                          PartieEstActive(numeroReference);
end;


const kTextesProblemesDeCoin = 10023;



function GetEnonceProblemeDePriseDeCoinEnChaine(var enonce : ProblemePriseDeCoin) : String255;
var s : String255;
begin
  case GetTraitOfPosition(enonce.currentBoard) of

    pionNoir  : {'Noir prend un coin en ^0 coups'}
                s := ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,1),IntToStr(enonce.solution.longueur),'','','');

    pionBlanc : {'Blanc prend un coin en ^0 coups'}
                s := ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,2),IntToStr(enonce.solution.longueur),'','','');

    otherwise   s := 'BUG ! Pas de couleur dans le problème de prise de coin en '+IntToStr(enonce.solution.longueur)+' coups';
  end;

  GetEnonceProblemeDePriseDeCoinEnChaine := s;
end;


function GetEnonceCourtProblemeDePriseDeCoinEnChaine(var enonce : ProblemePriseDeCoin) : String255;
var s : String255;
begin
  case GetTraitOfPosition(enonce.currentBoard) of

    pionNoir  : {'Noir en ^0 coups'}
                s := ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,10),IntToStr(enonce.solution.longueur),'','','');

    pionBlanc : {'Blanc en ^0 coups'}
                s := ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,11),IntToStr(enonce.solution.longueur),'','','');

    otherwise   s := 'BUG ! Pas de couleur dans le problème de prise de coin en '+IntToStr(enonce.solution.longueur)+' coups';
  end;

  GetEnonceCourtProblemeDePriseDeCoinEnChaine := s;
end;


function GetEnonceNumeroteProblemeDePriseDeCoin(var enonce : ProblemePriseDeCoin) : String255;
begin

  if DoitNumeroterProblemesDePriseDeCoin
    then
      begin
        if PeutIncrementerNumerotationDiagrammeDePriseDeCoin then inc(gNumerotationDiagrammeProblemeDeCoin);

        GetEnonceNumeroteProblemeDePriseDeCoin := IntToStr(gNumerotationDiagrammeProblemeDeCoin) + '.  \b'+
                                                  GetEnonceCourtProblemeDePriseDeCoinEnChaine(enonce);
      end
    else
      begin
        GetEnonceNumeroteProblemeDePriseDeCoin := '\b'+ GetEnonceCourtProblemeDePriseDeCoinEnChaine(enonce);
      end;

end;


function GetNumeroDuProblemeDePriseDeCoinDansCetEnonce(const chaineEnonce : String255) : SInt32;
var s : String255;
begin
  s := chaineEnonce;
  s := DeleteSubstringAfterThisChar('.',s,false);

  GetNumeroDuProblemeDePriseDeCoinDansCetEnonce := StrToInt32(s);
end;


function EstUnEnonceNumeroteDeProblemeDeCoin(const s : String255; var numero : SInt32) : boolean;
var subStringSignificative : String255;
begin
  numero := GetNumeroDuProblemeDePriseDeCoinDansCetEnonce(s);
  subStringSignificative := IntToStr(numero) + '.  \b';
  if Pos(subStringSignificative,s) > 0
    then EstUnEnonceNumeroteDeProblemeDeCoin := true
    else EstUnEnonceNumeroteDeProblemeDeCoin := false;
end;


procedure EcrireEnonceProblemePriseDeCoinDansRapport(var enonce : ProblemePriseDeCoin);
var solution : String255;
begin

  ChangeFontFaceDansRapport(bold);
  ChangeFontColorDansRapport(MarinePaleCmd);
  WriteDansRapport(GetEnonceProblemeDePriseDeCoinEnChaine(enonce)+'  ');
  ChangeFontFaceDansRapport(normal);
  ChangeFontColorDansRapport(NoirCmd);


  {solution := 'solution = '+CoupEnString(enonce.solution.coup[1],true)}
  solution := ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,3),CoupEnString(enonce.solution.coup[1],true),'','','');
  WritelnDansRapport('                                                          ' + solution);

  {WritelnDansRapport('Il y a '+IntToStr(enonce.solution.nbCoupsSolutions)+' coups solutions');}
end;


procedure EcrireCauseRejetPbDeCoinDansRapport(var enonce : ProblemePriseDeCoin);
var i : SInt32;
begin
  with enonce,gRechercheProblemesDePriseDeCoin do
    case solution.causeRejet of

      kRejetPasDeSolutionPbDeCoin :
        if GetTraitOfPosition(enonce.currentBoard) = pionNoir
          then {Pas de puzzle de prise de coin pour Noir entre ^0 et ^1 coups}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,4),IntToStr(difficulteMin),IntToStr(difficulteMax),'',''))
          else {Pas de puzzle de prise de coin pour Blanc entre ^0 et ^1 coups}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,5),IntToStr(difficulteMin),IntToStr(difficulteMax),'',''));

      kRejetADejaUnCoin :
        if GetTraitOfPosition(enonce.currentBoard) = pionNoir
          then {Noir a déja un coin}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,12),'','','',''))
          else {Blanc a déja un coin}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,13),'','','',''));

      kRejetPeutDejaPrendreUnCoin :
        if GetTraitOfPosition(enonce.currentBoard) = pionNoir
          then {Noir peut déja prendre un coin}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,6),'','','',''))
          else {Blanc peut déja prendre un coin}
               WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,7),'','','',''));


      kRejetSolutionsMultiplesPourPbDeCoin :
        begin
          if GetTraitOfPosition(enonce.currentBoard) = pionNoir
          then {Noir a plusieurs solutions pour prendre un coin en ^0 coups : }
               WriteDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,8),IntToStr(solution.longueur),'','',''))
          else {Blanc a plusieurs solutions pour prendre un coin en ^0 coups : }
               WriteDansRapport(ReplaceParameters(ReadStringFromRessource(kTextesProblemesDeCoin,9),IntToStr(solution.longueur),'','',''));

          for i := 1 to solution.nbCoupsSolutions do
            begin
              WriteCoupDansRapport(solution.coup[i]);
              if i < solution.nbCoupsSolutions then WriteDansRapport(', ');
            end;
          WritelnDansRapport('');
        end;


      kPasDeRejet :
        WritelnDansRapport('WARNING : pas de rejet dans EcrireCauseRejetPbDeCoinDansRapport !');

      otherwise WritelnDansRapport('ERROR !! cause rejet inconnue dans EcrireCauseRejetPbDeCoinDansRapport !');
    end;
end;


procedure PlaquerProblemeDePriseDeCoin(enonce : ProblemePriseDeCoin);
var aux : ProblemePriseDeCoin;
begin

  (* on sauvegarde ce probleme *)
  with gProblemePrecedent do
    begin
      inc(nbProblemesDejaProposes);
      aux               := enonce;    (* necessaire pour le code suivant si adresse(enonce) = adresse(problemePrecedent) *)
      problemePrecedent := problemeCourant;
      problemeCourant   := aux;
    end;

  PlaquerPosition(enonce.currentBoard.position,GetTraitOfPosition(enonce.currentBoard),kRedessineEcran);

  if not(HumCtreHum) then DoDemandeChangerHumCtreHum;

  (* on met l'énoncé dans les parametres du diagramme, prêt pour le presse-papier *)
  ParamDiagPositionFFORUM.EcritApres37c7FFORUM    := false;
  ParamDiagPositionFFORUM.CommentPositionFFORUM^^ := GetEnonceNumeroteProblemeDePriseDeCoin(enonce);
  (* tant que l'utilisateur n'a pas copié un des problèmes dans le presse papier,
     il est inutile d'incrementer le numero du problème *)
  SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(false);

  (* on affiche l'énoncé dans le rapport *)
  EcrireEnonceProblemePriseDeCoinDansRapport(enonce);

end;


procedure ChercherProblemeDePriseDeCoinCettePosition(var plateau : plateauOthello; var jouable : plBool; var frontiere : InfoFront;
                                                     nbNoir,nbBlanc,trait : SInt16; var nroDePartieDansLaListe : SInt32);
var numeroDuCoup : SInt32;
    position : PositionEtTraitRec;
    enonce : ProblemePriseDeCoin;
    s : String255;
begin  {$UNUSED jouable,frontiere}
  numeroDuCoup := nbNoir + nbBlanc - 4;

  with gRechercheProblemesDePriseDeCoin do
    if not(interrompue) then
      begin
        if (numeroDuCoup >= premierCoup) and (numeroDuCoup <= dernierCoup) then
          begin

          (* on cherche un probleme avec le trait naturel *)
          position := MakePositionEtTrait(plateau,trait);

          if EstUnProblemeDePriseDeCoinValable(position,difficulteMax,enonce) then
            begin

              interrompue := true;
              inc(nbTrouves);

              nroPartieDerniereRechercheReussie := nroDePartieDansLaListe;
              numeroDuCoupDuProbleme            := numeroDuCoup;

              s := ConstruireChaineReferencesPartieDapresListe(nroDePartieDansLaListe,false);

              WritelnDansRapport('');
              if (s <> '') then WritelnDansRapport(s);

              PlaquerProblemeDePriseDeCoin(enonce);

            end;
          end;
      end;

end;


procedure ChercherUnProblemeDePriseDeCoinDansPartie(var partie60 : PackedThorGame; numeroReference : SInt32; var numeroDeLaPartieDansLaListe : SInt32);
begin  {$UNUSED numeroReference}

  {WritelnDansRapport('Appel de ForEachPositionInGameDo');}

  ForEachPositionInGameDo(partie60,ChercherProblemeDePriseDeCoinCettePosition,numeroDeLaPartieDansLaListe);

  {WritelnDansRapport('Sortie de ForEachPositionInGameDo');}

end;


procedure ChercherUnProblemeDePriseDeCoinDansListe(premierCoup,dernierCoup : SInt32);
var tickDepartRechercheDesProblemes : SInt32;
    numeroDeLaPartieDansLaListe : SInt32;
    tempDifficulteMin : SInt32;
    tempDifficulteMax : SInt32;
begin
  if (nbPartiesActives > 0) and windowListeOpen and
     not(gRechercheProblemesDePriseDeCoin.enCours) and
     not(gRechercheProblemesDePriseDeCoin.rechercheListeEnCours) then
    begin
      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

      GetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);
      {SetIntervalleDeDifficultePourProblemeDePriseDeCoin(2,5);}

      if positionFeerique then
        begin
          DoNouvellePartie(true);
          CalculsEtAffichagePourBase(false,false);
        end;

      gRechercheProblemesDePriseDeCoin.interrompue           := false;
      gRechercheProblemesDePriseDeCoin.premierCoup           := premierCoup;
      gRechercheProblemesDePriseDeCoin.dernierCoup           := dernierCoup;
      gRechercheProblemesDePriseDeCoin.nbTrouves             := 0;
      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := true;

      tickDepartRechercheDesProblemes := TickCount;

      {WritelnDansRapport('Appel de ForEachGameInListDo');}

      {WritelnDansRapport('Recherche d''un probleme de prise de coin…');
      WritelnDansRapport('');}

      BeginCurseurSpecial(GetCursor(watchcursor));

      ForEachGameInListDo(FiltreRechercheProblemeDePriseDeCoin,bidFiltreGameProc,
                          ChercherUnProblemeDePriseDeCoinDansPartie,numeroDeLaPartieDansLaListe);

      if gRechercheProblemesDePriseDeCoin.interrompue then
        begin
          { On vient de trouver une position de probleme de coin dans une partie, donc
            on change le depart de la prochaine recherche afin de parcourir toute la liste
            lors de recherches successives}

          {WritelnNumDansRapport('temps = ',TickCount - tickDepartRechercheDesProblemes);}

          gRechercheProblemesDePriseDeCoin.nroDeDepartDansLaListe := gRechercheProblemesDePriseDeCoin.nroPartieDerniereRechercheReussie + 1;
        end;

      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := false;

      EndCurseurSpecial;


      SetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);
    end;
end;



procedure ChercherUnProblemeDePriseDeCoinDansPositionCourante;
var position : PositionEtTraitRec;
    enonce : ProblemePriseDeCoin;
    tempDifficulteMin,tempDifficulteMax : SInt32;
begin
  if not(gRechercheProblemesDePriseDeCoin.enCours) and
     not(gRechercheProblemesDePriseDeCoin.rechercheListeEnCours) then
    begin
      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

      GetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);
      SetIntervalleDeDifficultePourProblemeDePriseDeCoin(2,5);


      gRechercheProblemesDePriseDeCoin.interrompue           := false;
      gRechercheProblemesDePriseDeCoin.nbTrouves             := 0;
      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := true;

      position := PositionEtTraitCourant;
      if EstUnProblemeDePriseDeCoinValable(position,gRechercheProblemesDePriseDeCoin.difficulteMax,enonce)
        then
          begin
            inc(gRechercheProblemesDePriseDeCoin.nbTrouves);
            WritelnDansRapport('');
            EcrireEnonceProblemePriseDeCoinDansRapport(enonce);
          end
        else
          begin
            EcrireCauseRejetPbDeCoinDansRapport(enonce);
            if avecSon then Sysbeep(0);
          end;


      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := false;


      SetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);
    end;
end;


procedure ChercherUnProblemeDePriseDeCoinAleatoire(premierCoup,dernierCoup : SInt32);
var partie60 : PackedThorGame;
    lesCasesInterdites : SquareSet;
    compteur,bidon : SInt32;
    tempDifficulteMin,tempDifficulteMax : SInt32;
    typeDeProbleme : SInt32;
    ouverturesDejaGenerees : StringSet;
begin

  if not(gRechercheProblemesDePriseDeCoin.enCours) and
     not(gRechercheProblemesDePriseDeCoin.rechercheListeEnCours) then
    begin


      gRechercheProblemesDePriseDeCoin.interrompue           := false;
      gRechercheProblemesDePriseDeCoin.nbTrouves             := 0;
      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := true;
      SetRefuserDeDefensesTrivialesDeCoin(true);

      GetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);


      BeginCurseurSpecial(GetCursor(watchcursor));

      ouverturesDejaGenerees := MakeEmptyStringSet;

      compteur := 0;
      repeat

        typeDeProbleme := Abs(Random16()) mod 5;


        case typeDeProbleme of
          0 :
            begin
              lesCasesInterdites := [11,18,81,88,12,21,17,28,71,82,78,87,22,27,72{,77}];  {les cases C, et toutes les cases X sauf B7}
              premierCoup := 25;
              dernierCoup := 40;
            end;
          1 :
            begin
              lesCasesInterdites := [11,18,81,88,22,77];  {les coins, et toutes les cases X sauf B7 et G2}
              premierCoup := 25;
              dernierCoup := 41;
            end;
          2 :
            begin
              lesCasesInterdites := [11,18,81,88,22,27,72,77]; {les coins et les cases X}
              premierCoup := 25;
              dernierCoup := 40;
            end;
          3 :
            begin
              lesCasesInterdites := [22,27,72,77]; {les cases X}
              premierCoup := 25;
              dernierCoup := 40;
            end;
          4 :
            begin
              lesCasesInterdites := [11,18,81,88,22,27,72,77,12,21,17,28,71,82,78,87]; {les coins, les case C et les cases X}
              premierCoup := 20;
              dernierCoup := 40;
            end;
         end;

        gRechercheProblemesDePriseDeCoin.premierCoup           := premierCoup;
        gRechercheProblemesDePriseDeCoin.dernierCoup           := dernierCoup;

        {SetIntervalleDeDifficultePourProblemeDePriseDeCoin(3,3);}

        SetIntervalleDeDifficultePourProblemeDePriseDeCoin(4,4);



        repeat
          PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);

          GenereOuvertureAleatoireEquilibree(dernierCoup,-20000,20000,lesCasesInterdites,partie60,ouverturesDejaGenerees);

          DisposeStringSet(ouverturesDejaGenerees);

          bidon := 0;
          ChercherUnProblemeDePriseDeCoinDansPartie(partie60,0,bidon);

          inc(compteur);

        until (gRechercheProblemesDePriseDeCoin.nbTrouves > 0) or (compteur mod 100 = 0) or EscapeDansQueue or Quitter;

      until (gRechercheProblemesDePriseDeCoin.nbTrouves > 0) or (compteur >= 300) or EscapeDansQueue or Quitter;

      {WritelnNumDansRapport('Il a fallu '+IntToStr(compteur)+' parties aléatoires pour générer ce problème de type ',typeDeProbleme);}

      DisposeStringSet(ouverturesDejaGenerees);

      SetIntervalleDeDifficultePourProblemeDePriseDeCoin(tempDifficulteMin,tempDifficulteMax);

      SetRefuserDeDefensesTrivialesDeCoin(false);
      gRechercheProblemesDePriseDeCoin.rechercheListeEnCours := false;

      EndCurseurSpecial;

    end;


end;


procedure RevenirAuProblemeDePriseDeCoinPrecedent;
var ancienEnonce : ProblemePriseDeCoin;
begin
  if (gProblemePrecedent.nbProblemesDejaProposes >= 2) then
    begin
      ancienEnonce := gProblemePrecedent.problemePrecedent;
      WritelnDansRapport('');
      PlaquerProblemeDePriseDeCoin(ancienEnonce);
    end;
end;





END.















































