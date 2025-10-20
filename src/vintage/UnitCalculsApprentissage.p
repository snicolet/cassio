UNIT UnitCalculsApprentissage;



INTERFACE







 USES UnitDefCassio;




procedure InitUnitCalculsApprentissage;


{Calculs des valeurs dans UNE cellule du graphe}
{procedure CalculeValeurMinimaxDansT(var fichier : Graphe; numCellule : SInt32; var valeurChangee : boolean); }
{procedure CalculeValeurDeviante(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean); }
{procedure CalculeProofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean); }
{procedure CalculeDisproofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean); }
{procedure CalculeEsperanceDeGain(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean); }
procedure CalculeToutesLesValeursDuGraphe(var fichier : Graphe; numCellule : SInt32; var valeurChangees : boolean);

{Calculs des valeurs dans une orbite du graphe}
{procedure CalculeValeurMinimaxDeLOrbite(var fichier : Graphe; numCellule : SInt32; var AuMoinsUnChange : boolean); }
{procedure CalculeValeurDevianteDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean); }
{procedure CalculeProofNumberDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean); }
{procedure CalculeDisproofNumberDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean); }
{procedure CalculeEsperanceDeGainDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean); }
procedure CalculeToutesLesValeursDeLOrbite(var fichier : Graphe; numCellule : SInt32; var AuMoinsUnChange : boolean);

{Propagation des valeurs dans le graphe}
{procedure PropageValeurMinimaxDansT(var fichier : Graphe; numCellule : SInt32); }
{procedure PropageValeurDeviante(var fichier : Graphe; couleur : SInt16; numCellule : SInt32); }
{procedure PropageProofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32); }
{procedure PropageDisproofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32); }
{procedure PropageEsperanceDeGain(var fichier : Graphe; couleur : SInt16; numCellule : SInt32); }
procedure PropageToutesLesValeursDansLeGraphe(var fichier : Graphe; numCellule : SInt32);



function PasseApresCeCoup(var fichier : Graphe; numCellule : SInt32) : boolean;
procedure UnionListes(var liste1,liste2 : ListeDeCellules; var result : ListeDeCellules);
procedure SelectionneDansListe(var fichier : Graphe; var uneListe : ListeDeCellules; typesCherches : EnsembleDeTypes; var result : ListeDeCellules);
function CelluleEstDansListe(num : SInt32; var liste : ListeDeCellules) : boolean;


function CoupEstDansListe(var fichier : Graphe; coupCherche : SInt16; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;
function CoupEstDansListeDeCellulesEtDeCoups(coupCherche : SInt16; var liste : ListeDeCellulesEtDeCoups; var numCellule : SInt32) : boolean;
function TrouveValMinimaxDansListe(var fichier : Graphe; valeursCherchees : EnsembleDeTypes; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;
function TrouveValDevianteDansListe(var fichier : Graphe; couleur,valeurCherchee : SInt16; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;

function MaxValeurDevianteDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MinValeurDevianteDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MaxProofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MinProofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MaxDisproofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MinDisproofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
function MaxEsperanceDeGainDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : double_t;
function MinEsperanceDeGainDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : double_t;


function NbFilsDeviants(var fichier : Graphe; numCellule : SInt32; var lesFilsDeviants : ListeDeCellules) : SInt16;
procedure CopieListeAvecProbasUniformes(var fichier : Graphe; var liste : ListeDeCellules; var result :listeDeProbas);
function PourcentageDeGainParmilesFils(var fichier : Graphe; numCellule : SInt32) : double_t;
procedure CalculeProbabilitesOptimalesDeReponse(whichGame : typePartiePourGraphe; var conseils : ListeDeProbas);





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitAccesNouveauFormat, UnitRapport, UnitScannerUtils, MyMathUtils, UnitEntreesSortiesGraphe, UnitPileEtFile, UnitScannerOthellistique
    , UnitAccesGraphe ;
{$ELSEC}
    ;
    {$I prelink/CalculsApprentissage.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure InitUnitCalculsApprentissage;
begin
end;

procedure CalculeValeurMinimaxDansT(var fichier : Graphe; numCellule : SInt32; var valeurChangee : boolean);
var LesFils : ListeDeCellules;
    cellule,unFils : CelluleRec;
    ancienneValeur,nouvelleValeurMinimax : SInt16;
    numeroCellule : SInt32;
begin
  valeurChangee := false;
  nouvelleValeurMinimax := valeurIndeterminee;
  LitCellule(fichier,numCellule,cellule);
  if HasFils(cellule) then
    begin
      LitCellule(fichier,GetFils(cellule),unFils);
      LitEnsembleDesFils(fichier,numCellule,LesFils);
      ancienneValeur := GetValeurMinimax(cellule);
      if GetCouleur(cellule) = GetCouleur(unFils)
        then
          begin
            if TrouveValMinimaxDansListe(fichier,[kGainDansT,kGainAbsolu],LesFils,numeroCellule) then nouvelleValeurMinimax := kGainDansT else
            if TrouveValMinimaxDansListe(fichier,[kNulleDansT,kNulleAbsolue],LesFils,numeroCellule) then nouvelleValeurMinimax := kNulleDansT else
            if TrouveValMinimaxDansListe(fichier,[kPerteDansT,kPerteAbsolue],LesFils,numeroCellule) then nouvelleValeurMinimax := kPerteDansT
              else nouvelleValeurMinimax := kPasDansT;
          end
        else
          begin
            if TrouveValMinimaxDansListe(fichier,[kGainDansT,kGainAbsolu],LesFils,numeroCellule) then nouvelleValeurMinimax := kPerteDansT else
            if TrouveValMinimaxDansListe(fichier,[kNulleDansT,kNulleAbsolue],LesFils,numeroCellule) then nouvelleValeurMinimax := kNulleDansT else
            if TrouveValMinimaxDansListe(fichier,[kPerteDansT,kPerteAbsolue],LesFils,numeroCellule) then nouvelleValeurMinimax := kGainDansT
              else nouvelleValeurMinimax := kPasDansT;
          end;
      if (nouvelleValeurMinimax <> valeurIndeterminee) & (nouvelleValeurMinimax <> ancienneValeur) then
        begin
          valeurChangee := true;
          SetValeurMinimax(cellule,nouvelleValeurMinimax);
          EcritCellule(fichier,numCellule,cellule);
        end;
    end;
end;

procedure CalculeValeurDeviante(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean);
var LesFils,FilsSelectionnes : ListeDeCellules;
    cellule,unFils : CelluleRec;
    ancienneValeur,nouvelleValeurDeviante : SInt16;
    typesVoulus : EnsembleDeTypes;
begin
  valeurChangee := false;
  LitCellule(fichier,numCellule,cellule);
  ancienneValeur := GetValeurDeviante(cellule,couleur);
  nouvelleValeurDeviante := valeurIndeterminee;

  if not(HasFils(cellule))  {feuille du graphe : cas de base de la récurrence}
    then
      begin
        case GetValeurMinimax(cellule) of
          kPropositionHeuristique   : nouvelleValeurDeviante := GetValeurDeviante(cellule,couleur);
          kGainDansT,kGainAbsolu    : nouvelleValeurDeviante := +kInfiniApprentissage;
          kNulleDansT,kNulleAbsolue : nouvelleValeurDeviante := 0 ; {-infini ??}
          kPerteDansT,kPerteAbsolue : nouvelleValeurDeviante := -kInfiniApprentissage;
        end; {case}
      end
    else
      if EstDansT(cellule) then
        begin
          LitCellule(fichier,GetFils(cellule),unFils);
          LitEnsembleDesFils(fichier,numCellule,LesFils);
          if GetCouleur(cellule) = GetCouleur(unFils)
            then
              begin
                case GetValeurMinimax(cellule) of
                  kGainDansT,kGainAbsolu    : typesVoulus := [kGainDansT,kGainAbsolu];
                  kNulleDansT,kNulleAbsolue : typesVoulus := [kNulleDansT,kNulleAbsolue,kPropositionHeuristique];
                  kPerteDansT,kPerteAbsolue : typesVoulus := [kPerteDansT,kPerteAbsolue,kPropositionHeuristique];
                end; {case}
                SelectionneDansListe(fichier,LesFils,TypesVoulus,FilsSelectionnes);
                if FilsSelectionnes.cardinal = 0
                  then RaiseError('calcul de la valeur déviante impossible')
                  else nouvelleValeurDeviante := MaxValeurDevianteDansListe(fichier,FilsSelectionnes,couleur);
              end
            else
              begin
                case GetValeurMinimax(cellule) of
                  kGainDansT,kGainAbsolu    : typesVoulus := [kPerteDansT,kPerteAbsolue];
                  kNulleDansT,kNulleAbsolue : typesVoulus := [kNulleDansT,kNulleAbsolue,kPropositionHeuristique];
                  kPerteDansT,kPerteAbsolue : typesVoulus := [kGainDansT,kGainAbsolu,kPropositionHeuristique];
                end; {case}
                SelectionneDansListe(fichier,LesFils,TypesVoulus,FilsSelectionnes);
                if FilsSelectionnes.cardinal = 0
                  then RaiseError('calcul de la valeur déviante impossible')
                  else nouvelleValeurDeviante := -MinValeurDevianteDansListe(fichier,FilsSelectionnes,couleur);
              end;
        end;

  if (nouvelleValeurDeviante <> valeurIndeterminee) & (nouvelleValeurDeviante <> ancienneValeur) then
    begin
      valeurChangee := true;
      SetValeurDeviante(cellule,couleur,nouvelleValeurDeviante);
      EcritCellule(fichier,numCellule,cellule);
    end;
end;

procedure CalculeProofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean);
begin {$UNUSED fichier,couleur,numCellule}
  valeurChangee := false;
end;

procedure CalculeDisproofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean);
begin {$UNUSED fichier,couleur,numCellule}
  valeurChangee := false;
end;

procedure CalculeEsperanceDeGain(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var valeurChangee : boolean);
begin {$UNUSED fichier,couleur,numCellule}
  valeurChangee := false;
end;

procedure CalculeToutesLesValeursDuGraphe(var fichier : Graphe; numCellule : SInt32; var valeurChangees : boolean);
var changement : boolean;
begin
  valeurChangees := false;

  CalculeValeurMinimaxDansT(fichier,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  {CalculeValeurDeviante(fichier,Noir,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeValeurDeviante(fichier,Blanc,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeProofNumber(fichier,Noir,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeProofNumber(fichier,Blanc,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeDisproofNumber(fichier,Noir,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeDisproofNumber(fichier,Blanc,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeEsperanceDeGain(fichier,Noir,numCellule,changement);
  valeurChangees := valeurChangees | changement;

  CalculeEsperanceDeGain(fichier,Blanc,numCellule,changement);
  valeurChangees := valeurChangees | changement;
  }
end;


procedure CalculeValeurMinimaxDeLOrbite(var fichier : Graphe; numCellule : SInt32; var AuMoinsUnChange : boolean);
var orbite : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  AuMoinsUnChange := false;
  LitOrbite(fichier,numCellule,orbite);
  for i := 1 to orbite.cardinal do
    CalculeValeurMinimaxDansT(fichier,orbite.liste[i].numeroCellule,changement[i]);
  for i := 1 to orbite.cardinal do
    AuMoinsUnChange := AuMoinsUnChange | changement[i];
end;

procedure CalculeValeurDevianteDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean);
var orbite : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  AuMoinsUnChange := false;
  LitOrbite(fichier,numCellule,orbite);
  for i := 1 to orbite.cardinal do
    CalculeValeurDeviante(fichier,couleur,orbite.liste[i].numeroCellule,changement[i]);
  for i := 1 to orbite.cardinal do
    AuMoinsUnChange := AuMoinsUnChange | changement[i];
end;

procedure CalculeProofNumberDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean);
var orbite : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  AuMoinsUnChange := false;
  LitOrbite(fichier,numCellule,orbite);
  for i := 1 to orbite.cardinal do
    CalculeProofNumber(fichier,couleur,orbite.liste[i].numeroCellule,changement[i]);
  for i := 1 to orbite.cardinal do
    AuMoinsUnChange := AuMoinsUnChange | changement[i];
end;

procedure CalculeDisproofNumberDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean);
var orbite : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  AuMoinsUnChange := false;
  LitOrbite(fichier,numCellule,orbite);
  for i := 1 to orbite.cardinal do
    CalculeDisproofNumber(fichier,couleur,orbite.liste[i].numeroCellule,changement[i]);
  for i := 1 to orbite.cardinal do
    AuMoinsUnChange := AuMoinsUnChange | changement[i];
end;

procedure CalculeEsperanceDeGainDeLOrbite(var fichier : Graphe; couleur : SInt16; numCellule : SInt32; var AuMoinsUnChange : boolean);
var orbite : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  AuMoinsUnChange := false;
  LitOrbite(fichier,numCellule,orbite);
  for i := 1 to orbite.cardinal do
    CalculeEsperanceDeGain(fichier,couleur,orbite.liste[i].numeroCellule,changement[i]);
  for i := 1 to orbite.cardinal do
    AuMoinsUnChange := AuMoinsUnChange | changement[i];
end;

procedure CalculeToutesLesValeursDeLOrbite(var fichier : Graphe; numCellule : SInt32; var AuMoinsUnChange : boolean);
var changement : boolean;
begin
  AuMoinsUnChange := false;

  CalculeValeurMinimaxDeLOrbite(fichier,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  {
  CalculeValeurDevianteDeLOrbite(fichier,Noir,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeValeurDevianteDeLOrbite(fichier,Blanc,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeProofNumberDeLOrbite(fichier,Noir,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeProofNumberDeLOrbite(fichier,Blanc,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeDisproofNumberDeLOrbite(fichier,Noir,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeDisproofNumberDeLOrbite(fichier,Blanc,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeEsperanceDeGainDeLOrbite(fichier,Noir,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;

  CalculeEsperanceDeGainDeLOrbite(fichier,Blanc,numCellule,changement);
  AuMoinsUnChange := AuMoinsUnChange | changement;
  }
end;


procedure PropageRecursivementValeurMinimaxDansT(var fichier : Graphe; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  LitEnsembleDesPeres(fichier,numCellule,peres);
  for i := 1 to peres.cardinal do
    CalculeValeurMinimaxDansT(fichier,peres.liste[i].numeroCellule,changement[i]);
  for i := 1 to peres.cardinal do
    if changement[i] then PropageRecursivementValeurMinimaxDansT(fichier,peres.liste[i].numeroCellule);
end;

procedure PropageRecursivementValeurDeviante(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  LitEnsembleDesPeres(fichier,numCellule,peres);
  for i := 1 to peres.cardinal do
    CalculeValeurDeviante(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
  for i := 1 to peres.cardinal do
    if changement[i] then PropageRecursivementValeurDeviante(fichier,couleur,peres.liste[i].numeroCellule);
end;

procedure PropageRecursivementProofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  LitEnsembleDesPeres(fichier,numCellule,peres);
  for i := 1 to peres.cardinal do
    CalculeProofNumber(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
  for i := 1 to peres.cardinal do
    if changement[i] then PropageRecursivementProofNumber(fichier,couleur,peres.liste[i].numeroCellule);
end;

procedure PropageRecursivementDisproofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  LitEnsembleDesPeres(fichier,numCellule,peres);
  for i := 1 to peres.cardinal do
    CalculeDisproofNumber(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
  for i := 1 to peres.cardinal do
    if changement[i] then PropageRecursivementDisproofNumber(fichier,couleur,peres.liste[i].numeroCellule);
end;

procedure PropageRecursivementEsperanceDeGain(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
begin
  LitEnsembleDesPeres(fichier,numCellule,peres);
  for i := 1 to peres.cardinal do
    CalculeEsperanceDeGain(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
  for i := 1 to peres.cardinal do
    if changement[i] then PropageRecursivementEsperanceDeGain(fichier,couleur,peres.liste[i].numeroCellule);
end;


procedure PropageValeurMinimaxDansT(var fichier : Graphe; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
    memoireOK,ok : boolean;
    cellulesAParcourir : Pile;
begin
  cellulesAParcourir := AllocatePile(1000,memoireOK);

  if memoireOK
    then
      begin
	      Empiler(cellulesAParcourir,numCellule,ok);

	      while not(FileEstVide(cellulesAParcourir)) do
	        begin
	          numCellule := Defiler(cellulesAParcourir,ok);

	          LitEnsembleDesPeres(fichier,numCellule,peres);
				    for i := 1 to peres.cardinal do
					    begin
					      CalculeValeurMinimaxDansT(fichier,peres.liste[i].numeroCellule,changement[i]);
					      if changement[i] then
					        EmpilerSiPasDansPile(cellulesAParcourir,peres.liste[i].numeroCellule,ok);
					    end;
				  end;
	    end
    else
	    PropageRecursivementValeurMinimaxDansT(fichier,numCellule);

  DisposePile(cellulesAParcourir);
end;

procedure PropageValeurDeviante(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
    memoireOK,ok : boolean;
    cellulesAParcourir : Pile;
begin
  cellulesAParcourir := AllocatePile(1000,memoireOK);

  if memoireOK
    then
      begin
	      Empiler(cellulesAParcourir,numCellule,ok);

	      while not(FileEstVide(cellulesAParcourir)) do
	        begin
	          numCellule := Defiler(cellulesAParcourir,ok);

	          LitEnsembleDesPeres(fichier,numCellule,peres);
				    for i := 1 to peres.cardinal do
					    begin
					      CalculeValeurDeviante(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
					      if changement[i] then
					        EmpilerSiPasDansPile(cellulesAParcourir,peres.liste[i].numeroCellule,ok);
					    end;
				  end;
	    end
    else
	    PropageRecursivementValeurDeviante(fichier,couleur,numCellule);

  DisposePile(cellulesAParcourir);
end;


procedure PropageProofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
    memoireOK,ok : boolean;
    cellulesAParcourir : Pile;
begin
  cellulesAParcourir := AllocatePile(1000,memoireOK);

  if memoireOK
    then
      begin
	      Empiler(cellulesAParcourir,numCellule,ok);

	      while not(FileEstVide(cellulesAParcourir)) do
	        begin
	          numCellule := Defiler(cellulesAParcourir,ok);

	          LitEnsembleDesPeres(fichier,numCellule,peres);
				    for i := 1 to peres.cardinal do
					    begin
					      CalculeProofNumber(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
					      if changement[i] then
					        EmpilerSiPasDansPile(cellulesAParcourir,peres.liste[i].numeroCellule,ok);
					    end;
				  end;
	    end
    else
	    PropageRecursivementProofNumber(fichier,couleur,numCellule);

  DisposePile(cellulesAParcourir);
end;


procedure PropageDisproofNumber(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
    memoireOK,ok : boolean;
    cellulesAParcourir : Pile;
begin
  cellulesAParcourir := AllocatePile(1000,memoireOK);

  if memoireOK
    then
      begin
	      Empiler(cellulesAParcourir,numCellule,ok);

	      while not(FileEstVide(cellulesAParcourir)) do
	        begin
	          numCellule := Defiler(cellulesAParcourir,ok);

	          LitEnsembleDesPeres(fichier,numCellule,peres);
				    for i := 1 to peres.cardinal do
					    begin
					      CalculeDisproofNumber(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
					      if changement[i] then
					        EmpilerSiPasDansPile(cellulesAParcourir,peres.liste[i].numeroCellule,ok);
					    end;
				  end;
	    end
    else
	    PropageRecursivementDisproofNumber(fichier,couleur,numCellule);

  DisposePile(cellulesAParcourir);
end;


procedure PropageEsperanceDeGain(var fichier : Graphe; couleur : SInt16; numCellule : SInt32);
var Peres : ListeDeCellules;
    changement : array[0..TaileMaxListeDeCoups] of boolean;
    i : SInt16;
    memoireOK,ok : boolean;
    cellulesAParcourir : Pile;
begin
  cellulesAParcourir := AllocatePile(1000,memoireOK);

  if memoireOK
    then
      begin
	      Empiler(cellulesAParcourir,numCellule,ok);

	      while not(FileEstVide(cellulesAParcourir)) do
	        begin
	          numCellule := Defiler(cellulesAParcourir,ok);

	          LitEnsembleDesPeres(fichier,numCellule,peres);
				    for i := 1 to peres.cardinal do
					    begin
					      CalculeEsperanceDeGain(fichier,couleur,peres.liste[i].numeroCellule,changement[i]);
					      if changement[i] then
					        EmpilerSiPasDansPile(cellulesAParcourir,peres.liste[i].numeroCellule,ok);
					    end;
				  end;
	    end
    else
	    PropageRecursivementEsperanceDeGain(fichier,couleur,numCellule);

  DisposePile(cellulesAParcourir);
end;





procedure PropageToutesLesValeursDansLeGraphe(var fichier : Graphe; numCellule : SInt32);
begin
  PropageValeurMinimaxDansT(fichier,numCellule);

  PropageValeurDeviante(fichier,Noir,numCellule);
  PropageValeurDeviante(fichier,Blanc,numCellule);
  PropageProofNumber(fichier,Noir,numCellule);
  PropageProofNumber(fichier,Blanc,numCellule);
  PropageDisproofNumber(fichier,Noir,numCellule);
  PropageDisproofNumber(fichier,Blanc,numCellule);
  PropageEsperanceDeGain(fichier,Noir,numCellule);
  PropageEsperanceDeGain(fichier,Blanc,numCellule);

end;

function PasseApresCeCoup(var fichier : Graphe; numCellule : SInt32) : boolean;
var cellule : CelluleRec;
begin

  LitCellule(fichier,numCellule,cellule);

  { le vieux code : }
  {PasseApresCeCoup := false;
  if HasFils(cellule) then
    begin
      LitCellule(fichier,GetFils(cellule),CelluleFils);
      PasseApresCeCoup := (GetCouleur(CelluleFils) = GetCouleur(cellule));
    end;}
  PasseApresCeCoup := (GetTrait(cellule) = GetCouleur(cellule));
end;



procedure UnionListes(var liste1,liste2 : ListeDeCellules; var result : ListeDeCellules);
var i,card1,card2 : SInt32;
    adresseListe1,adresseListe2,adresseResult : SInt32;
begin
  card1 := liste1.cardinal;
  card2 := liste2.cardinal;
  adresseListe1 := SInt32(@liste1);  {pour que UnionListes marche meme si result == liste1 ou result == liste2 }
  adresseListe2 := SInt32(@liste2);
  adresseResult := SInt32(@result);
  {
  WritelnNumDansRapport('adresseListe1 = ',adresseListe1);
  WritelnNumDansRapport('adresseListe2 = ',adresseListe2);
  WritelnNumDansRapport('adresseResult = ',adresseResult);
  }

  result.cardinal := card1+card2;

  if (adresseListe2 <> adresseResult)
    then
		  for i := 1 to result.cardinal do
		    if i <= card1
		      then result.liste[i] := liste1.liste[i]
		      else result.liste[i] := liste2.liste[i-card1]
		else
		  for i := 1 to result.cardinal do
		    if i <= card2
		      then result.liste[i] := liste2.liste[i]
		      else result.liste[i] := liste1.liste[i-card2];
end;


function CelluleEstDansListe(num : SInt32; var liste : ListeDeCellules) : boolean;
var t : SInt16;
begin
  CelluleEstDansListe := false;
  for t := 1 to liste.cardinal do
    if liste.liste[t].numeroCellule = num then
      begin
        CelluleEstDansListe := true;
        exit(CelluleEstDansListe);
      end;
end;

function CoupEstDansListe(var fichier : Graphe; coupCherche : SInt16; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;
var t : SInt16;
begin
  CoupEstDansListe := false;
  numCellule := -1;

  if (coupCherche < 11) | (coupCherche > 88) then
    begin
      WritelnDansRapport('## ERROR : (coupCherche < 11) | (coupCherche > 88) dans CoupEstDansListe');
      WritelnNumDansRapport('coupCherche = ',coupCherche);
      exit(CoupEstDansListe);
    end;

  for t := 1 to liste.cardinal do
    if GetNiemeCoupDansListe(fichier,liste,t) = coupCherche then
      begin
        CoupEstDansListe := true;
        numCellule := liste.liste[t].numeroCellule;
        exit(CoupEstDansListe);
      end;
end;

function CoupEstDansListeDeCellulesEtDeCoups(coupCherche : SInt16; var liste : ListeDeCellulesEtDeCoups; var numCellule : SInt32) : boolean;
var t : SInt16;
begin
  CoupEstDansListeDeCellulesEtDeCoups := false;
  numCellule := -1;

  if (coupCherche < 11) | (coupCherche > 88) then
    begin
      WritelnDansRapport('## ERROR : (coupCherche < 11) | (coupCherche > 88) dans CoupEstDansListeDeCellulesEtDeCoups');
      exit(CoupEstDansListeDeCellulesEtDeCoups);
    end;

  for t := 1 to liste.cardinal do
    if liste.liste[t].coup = coupCherche then
      begin
        CoupEstDansListeDeCellulesEtDeCoups := true;
        numCellule := liste.liste[t].numeroCellule;
        exit(CoupEstDansListeDeCellulesEtDeCoups);
      end;
end;

function TrouveValMinimaxDansListe(var fichier : Graphe; valeursCherchees : EnsembleDeTypes; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;
var t : SInt16;
    CellAux : CelluleRec;
begin
  TrouveValMinimaxDansListe := false;
  numCellule := -1;
  for t := 1 to liste.cardinal do
    begin
      LitCellule(fichier,liste.liste[t].numeroCellule,CellAux);
      if GetValeurMinimax(CellAux) in valeursCherchees then
	      begin
	        TrouveValMinimaxDansListe := true;
	        numCellule := liste.liste[t].numeroCellule;
	        exit(TrouveValMinimaxDansListe);
	      end;
    end;
end;

function TrouveValDevianteDansListe(var fichier : Graphe; couleur,valeurCherchee : SInt16; var liste : ListeDeCellules; var numCellule : SInt32) : boolean;
var t : SInt16;
    cellAux : CelluleRec;
begin
  TrouveValDevianteDansListe := false;
  numCellule := -1;
  for t := 1 to liste.cardinal do
    begin
      LitCellule(fichier,liste.liste[t].numeroCellule,cellAux);
      if GetValeurDeviante(cellAux,couleur) = valeurCherchee then
      begin
        TrouveValDevianteDansListe := true;
        numCellule := liste.liste[t].numeroCellule;
        exit(TrouveValDevianteDansListe);
      end;
    end;
end;

function MaxValeurDevianteDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var maximum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  maximum := -kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetValeurDeviante(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux > maximum)
       then maximum := aux;
    end;
  MaxValeurDevianteDansListe := maximum;
end;

function MinValeurDevianteDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var minimum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  minimum := +kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetValeurDeviante(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux < minimum)
       then minimum := aux;
    end;
  MinValeurDevianteDansListe := minimum;
end;

function MaxProofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var maximum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  maximum := -kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetProofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux > maximum)
       then maximum := aux;
    end;
  MaxProofNumberDansListe := maximum;
end;

function MinProofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var minimum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  minimum := +kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetProofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux < minimum)
       then minimum := aux;
    end;
  MinProofNumberDansListe := minimum;
end;

function MaxDisproofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var maximum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  maximum := -kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetDisproofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux > maximum)
       then maximum := aux;
    end;
  MaxDisproofNumberDansListe := maximum;
end;

function MinDisproofNumberDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var minimum,t,aux : SInt16;
    cellAux : CelluleRec;
begin
  minimum := +kInfiniApprentissage;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetDisproofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) & (aux < minimum)
       then minimum := aux;
    end;
  MinDisproofNumberDansListe := minimum;
end;

function SommeProofNumbersDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var somme,aux,t : SInt32;
    cellAux : CelluleRec;
    AuMoinsUneValeur : boolean;
begin
  somme := 0;
  AuMoinsUneValeur := false;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetProofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) then
        begin
          somme := aux;
          if somme > kMaxProofNumber then somme := kMaxProofNumber;
          AuMoinsUneValeur := true;
        end;
    end;
  if AuMoinsUneValeur
    then SommeProofNumbersDansListe := somme
    else SommeProofNumbersDansListe := valeurIndeterminee;
end;


function SommeDisproofNumbersDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : SInt16;
var somme,aux,t : SInt32;
    cellAux : CelluleRec;
    AuMoinsUneValeur : boolean;
begin
  somme := 0;
  AuMoinsUneValeur := false;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetDisproofNumber(cellAux,couleur);
      if (aux <> valeurIndeterminee) then
        begin
          somme := aux;
          if somme > kMaxProofNumber then somme := kMaxProofNumber;
          AuMoinsUneValeur := true;
        end;
    end;
  if AuMoinsUneValeur
    then SommeDisproofNumbersDansListe := somme
    else SommeDisproofNumbersDansListe := valeurIndeterminee;
end;

function MaxEsperanceDeGainDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : double_t;
var maximum,aux : double_t;
    t : SInt16;
    cellAux : CelluleRec;
begin
  maximum := 0.0;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetEsperanceDeGain(cellAux,couleur);
      if (aux <> esperanceIndeterminee) & (aux > maximum)
       then maximum := aux;
    end;
  MaxEsperanceDeGainDansListe := maximum;
end;

function MinEsperanceDeGainDansListe(var fichier : Graphe; var maListe : ListeDeCellules; couleur : SInt16) : double_t;
var minimum,aux : double_t;
    t : SInt16;
    cellAux : CelluleRec;
begin
  minimum := 1.0;
  for t := 1 to maListe.cardinal do
    begin
      LitCellule(fichier,maListe.liste[t].numeroCellule,cellAux);
      aux := GetEsperanceDeGain(cellAux,couleur);
      if (aux <> esperanceIndeterminee) & (aux < minimum)
       then minimum := aux;
    end;
  MinEsperanceDeGainDansListe := minimum;
end;




function NbFilsDeviants(var fichier : Graphe; numCellule : SInt32; var lesFilsDeviants : ListeDeCellules) : SInt16;
var premierFils,aux,compteur : SInt32;
    cellule : CelluleRec;
    erreur : OSErr;
begin
  lesFilsDeviants.cardinal := 0;
  LitCellule(fichier,numCellule,cellule);
  if HasFils(cellule) then
    begin
      premierFils := GetFils(cellule);
      aux := premierFils;
      compteur := 0;
      repeat
        LitCellule(fichier,aux,cellule);
        if EstUnePropositionHeuristique(cellule) then
          begin
            lesFilsDeviants.cardinal := lesFilsDeviants.cardinal+1;
            lesFilsDeviants.liste[lesFilsDeviants.cardinal].numeroCellule := aux;
          end;
        aux := GetFrere(cellule);

        inc(compteur);
        if (compteur >= kLongueurListeInfinie) then
          begin
            {SysBeep(0);}
            WritelnDansRapport('## ERROR : boucle infinie dans NbFilsDeviants');
            erreur := RepareListeDesFreres(fichier,premierFils,lesFilsDeviants,'NbFilsDeviants:');
            NbFilsDeviants := lesFilsDeviants.cardinal;
            exit(NbFilsDeviants);
          end;
      until (aux = premierFils);
    end;
  NbFilsDeviants := lesFilsDeviants.cardinal;
end;

procedure SelectionneDansListe(var fichier : Graphe;
                               var uneListe : ListeDeCellules;
                               typesCherches : EnsembleDeTypes;
                               var result : ListeDeCellules);
var k : SInt16;
    cellAux : CelluleRec;
    myLongintPtr : ^SInt32;
begin  {$UNUSED myLongintPtr}
  (*
  WritelnNumDansRapport('sizeof(typesCherches) = ',Sizeof(typesCherches));
  myLongintPtr := @typesCherches;
  WritelnNumDansRapport('SInt32(typesCherches) = ',myLongintPtr^);
  WriteDansRapport('typesCherches = {');
  for k := kPasDansT to kPerteAbsolue do
    if k in typesCherches then
      WriteNumDansRapport(' ',k);
  WritelnDansRapport(' }');
  *)

  if (SInt32(@uneliste) = SInt32(@result)) then
    begin
      SysBeep(0);
      WritelnDansRapport('## ERROR : uneliste et result ont la meme adresse dans SelectionneDansListe !');
      exit(SelectionneDansListe);
    end;

  result.cardinal := 0;
  for k := 1 to uneListe.cardinal do
    begin
      LitCellule(fichier,UneListe.liste[k].numeroCellule,cellAux);
      if GetValeurMinimax(cellAux) in typesCherches then
        begin
          result.cardinal := result.cardinal+1;
          result.liste[result.cardinal] := uneListe.liste[k];
        end;
    end;
end;



procedure CopieListeAvecProbasUniformes(var fichier : Graphe; var liste : ListeDeCellules; var result :listeDeProbas);
var k : SInt16;
begin
  result.cardinal := liste.cardinal;
  for k := 1 to result.cardinal do
    begin
      result.liste[k].coup := GetNiemeCoupDansListe(fichier,liste,k);
      result.liste[k].proba := (1.0/result.cardinal);
    end;
end;

function PourcentageDeGainParmilesFils(var fichier : Graphe; numCellule : SInt32) : double_t;
var lesFils : ListeDeCellules;
    score : double_t;
    k,nbreFilsDansT : SInt16;
    cellAux : CelluleRec;
begin
  PourcentageDeGainParmilesFils := 0.0;
  LitEnsembleDesFils(fichier,numCellule,lesFils);
  if lesFils.cardinal > 0 then
    begin
      nbreFilsDansT := 0;
      score := 0.0;
      for k := 1 to LesFils.cardinal do
        begin
          LitCellule(fichier,lesFils.liste[k].numeroCellule,cellAux);
          case GetValeurMinimax(cellAux) of
            kGainDansT,kGainAbsolu  : begin
                                        inc(nbreFilsDansT);
                                        score := score+1.0;
                                      end;
            kNulleDansT,kNulleAbsolue : begin
                                          inc(nbreFilsDansT);
                                          score := score+0.5;
                                        end;
            kPerteDansT,kPerteAbsolue : begin
                                          inc(nbreFilsDansT);
                                          score := score+0.0;
                                        end;
          end; {case}
        end;
      if nbreFilsDansT > 0 then
        PourcentageDeGainParmilesFils := (score/nbreFilsDansT);
    end;
end;


procedure CalculeProbabilitesOptimalesDeReponse(whichGame : typePartiePourGraphe; var conseils:listeDeProbas);
var cellule : CelluleRec;
    fichier : Graphe;
    partie60 : PackedThorGame;
    path,LesFils,FilsSelectionnes : ListeDeCellules;
    k,numFils : SInt32;
    risque : double_t;
    typesVoulus : EnsembleDeTypes;
    grapheDejaOuvertALArrivee : boolean;
begin
  conseils.cardinal := 0;
  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      TraductionAlphanumeriqueEnThor(whichGame,partie60);
      if PositionEstDansLeGraphe(fichier,partie60,path) then
        begin
          LitCellule(fichier,path.liste[path.cardinal].numeroCellule,cellule);
          if HasFils(cellule) & EstDansT(cellule) then
            begin
              LitEnsembleDesFils(fichier,path.liste[path.cardinal].numeroCellule,LesFils);
              if PasseApresCeCoup(fichier,path.liste[path.cardinal].numeroCellule)
                then
                  begin
                    case GetValeurMinimax(cellule) of
                      kGainDansT,kGainAbsolu:
                        begin
                          typesVoulus := [kGainDansT,kGainAbsolu];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          CopieListeAvecProbasUniformes(fichier,FilsSelectionnes,conseils);
                        end;
                      kNulleDansT,kNulleAbsolue:
                        begin
                          typesVoulus := [kNulleDansT,kNulleAbsolue];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          if gEntrainementOuvertures.CassioSeContenteDeLaNulle |
                             (((LesFils.cardinal = 1) & UneChanceSur(2)) |
                             ((LesFils.cardinal > 1) & PChancesSurN(3,4))) then
                            CopieListeAvecProbasUniformes(fichier,FilsSelectionnes,conseils);
                        end;
                      kPerteDansT,kPerteAbsolue:
                        begin
                          if gEntrainementOuvertures.CassioVarieSesCoups
                            then typesVoulus := [kPerteDansT,kPerteAbsolue,kPasDansT,kPropositionHeuristique]
                            else typesVoulus := [kPerteDansT,kPerteAbsolue];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          if (FilsSelectionnes.cardinal > 6) |
                             not(gEntrainementOuvertures.CassioVarieSesCoups) |
                             UneChanceSur(4) |
                             ((FilsSelectionnes.cardinal >= 3) & UneChanceSur(2)) then
                          if (FilsSelectionnes.cardinal > 1) then {choisir parmi plusieurs coups perdants}
                            begin
                              conseils.cardinal := FilsSelectionnes.cardinal;
                              for k := 1 to conseils.cardinal do
                                begin
                                  conseils.liste[k].coup := GetNiemeCoupDansListe(fichier,FilsSelectionnes,k);
                                  numFils := FilsSelectionnes.liste[k].numeroCellule;
                                  if not(AuMoinsUnFils(fichier,numFils))
                                    then conseils.liste[k].proba := 0.0
                                    else
                                     if PasseApresCeCoup(fichier,numFils)
                                       then conseils.liste[k].proba := PourcentageDeGainParmilesFils(fichier,numFils)
                                       else conseils.liste[k].proba := 1.0-PourcentageDeGainParmilesFils(fichier,numFils);
                                end;
                            end;
                        end;
                    end; {case}
                  end
                else
                  begin
                    case GetValeurMinimax(cellule) of
                      kPerteDansT,kPerteAbsolue:
                        begin
                          typesVoulus := [kGainDansT,kGainAbsolu];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          CopieListeAvecProbasUniformes(fichier,FilsSelectionnes,conseils);
                        end;
                      kNulleDansT,kNulleAbsolue:
                        begin
                          typesVoulus := [kNulleDansT,kNulleAbsolue];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          if gEntrainementOuvertures.CassioSeContenteDeLaNulle |
                             ((LesFils.cardinal = 1) & UneChanceSur(2)) |
                             ((LesFils.cardinal > 1) & PChancesSurN(3,4)) then
                            CopieListeAvecProbasUniformes(fichier,FilsSelectionnes,conseils);
                        end;
                      kGainDansT,kGainAbsolu:
                        begin
                          if gEntrainementOuvertures.CassioVarieSesCoups
                            then typesVoulus := [kPerteDansT,kPerteAbsolue,kPasDansT,kPropositionHeuristique]
                            else typesVoulus := [kPerteDansT,kPerteAbsolue];
                          SelectionneDansListe(fichier,LesFils,typesVoulus,FilsSelectionnes);
                          if (FilsSelectionnes.cardinal > 6) |
                             not(gEntrainementOuvertures.CassioVarieSesCoups) |
                             UneChanceSur(4) |
                             ((FilsSelectionnes.cardinal >= 3) & UneChanceSur(2)) then
                          if (FilsSelectionnes.cardinal > 1) then {choisir parmi plusieurs coups perdants}
                            begin
                              conseils.cardinal := FilsSelectionnes.cardinal;
                              for k := 1 to conseils.cardinal do
                                begin
                                  conseils.liste[k].coup := GetNiemeCoupDansListe(fichier,FilsSelectionnes,k);
                                  numFils := FilsSelectionnes.liste[k].numeroCellule;
                                  if not(AuMoinsUnFils(fichier,numFils))
                                    then conseils.liste[k].proba := 0.0
                                    else
                                     if PasseApresCeCoup(fichier,numFils)
                                       then conseils.liste[k].proba := PourcentageDeGainParmilesFils(fichier,numFils)
                                       else conseils.liste[k].proba := 1.0-PourcentageDeGainParmilesFils(fichier,numFils);
                                end;
                            end;
                        end;
                    end; {case}
                  end;
            end;
        end;
      if gEntrainementOuvertures.CassioVarieSesCoups then risque := 0.05 else risque := 0.0;
      for k := 1 to conseils.cardinal do
        conseils.liste[k].proba := conseils.liste[k].proba+risque;

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;




END.

