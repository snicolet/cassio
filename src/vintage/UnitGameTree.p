UNIT UnitGameTree;



INTERFACE








USES UnitDefCassio;




{fonctions d'initialisation et de fin de programme}
procedure InitUnitGameTree;
procedure LibereMemoireUnitGameTree;


{creation et destruction de GameTree}
function NewGameTree : GameTree;
procedure DisposeGameTree(var G : GameTree);
procedure CompacterGameTree(var G : GameTree);
procedure CopyGameTree(source : GameTree; var dest : GameTree); {attention : seulement copie de pointeurs, n'alloue pas de memoire}
function DuplicateGameTree(var G : GameTree) : GameTree;       {utiliser celle-ci pour allouer une nouvelle memoire}
function GameTreePtrEstValide(G : GameTree) : boolean;


{creation d'un GameTree à partir de properties}
function MakeGameTreeFromPropertyList(L : PropertyList) : GameTree;
function MakeGameTreeFromPropertyListSansDupliquer(L : PropertyList) : GameTree;
function MakeGameTreeFromProperty(prop : Property) : GameTree;


{fonctions d'acces à un GameTree}
function GetFather(G : GameTree) : GameTree;
function GameTreeEstVide(G : GameTree) : boolean;
function IsLeaf(G : GameTree) : boolean;
function IsInternalNode(G : GameTree) : boolean;
function HasSons(G : GameTree) : boolean;
function GetSons(G : GameTree) : GameTreeList;
function NumberOfSons(G : GameTree) : SInt16;
function NumberOfVirtualSons(G : GameTree) : SInt16;
function NumberOfRealSons(G : GameTree) : SInt16;
function NumberOfVirtualNodesUsedForZebraBookDisplay(G : GameTree) : SInt16;
function HasBrothers(G : GameTree) : boolean;
function GetBrothers(G : GameTree) : GameTreeList;
function GetOlderBrother(G : GameTree) : GameTree;
function GetNextBrother(G : GameTree) : GameTree;
function GetOlderSon(G : GameTree) : GameTree;
function GetGameNodeMagicCookie(G : GameTree) : SInt32;
function GetPropertyList(G : GameTree) : PropertyList;
function GetCouleurOfMoveInNode(G : GameTree) : SInt32;
function GetSquareOfMoveInNode(G : GameTree; var square : SInt32) : boolean;
function MakeListOfThesePropertiesOfSons(whichTypes : SetOfPropertyTypes; var G : GameTree) : PropertyList;
function MakeListOfMovePropertyOfSons(couleur : SInt16; var G : GameTree) : PropertyList;
function GetEnsembleDesCasesDesFilsAvecCesProprietes(whichTypes : SetOfPropertyTypes; G : GameTree) : SquareSet;
function GetEnsembleDesCoupsDesFils(couleur : SInt16; G : GameTree) : SquareSet;
function GetEnsembleDesCoupsDesFilsReels(G : GameTree) : SquareSet;
function GetEnsembleDesCoupsDesFreres(G : GameTree) : SquareSet;
function GetEnsembleDesCoupsDesFreresReels(G : GameTree) : SquareSet;
function GameNodeHasTooManySons(var G : GameTree; var nbreMinDeFils : SInt32) : boolean;


{Ajout et retrait de properties à un GameTree}
procedure AddPropertyToGameTree(prop : Property; var G : GameTree);
procedure AddPropertyToGameTreeSansDuplication(prop : Property; var G : GameTree);
procedure AddTranspositionPropertyToGameTree(var texte : String255; var G : GameTree);
procedure DeletePropertyFromGameNode(prop : Property; var G : GameTree);
procedure DeletePropertiesOfTheseTypeFromGameNode(whichType : SInt16; var G : GameTree);
procedure DeletePropertiesOfTheseTypesFromGameNode(whichTypes : SetOfPropertyTypes; var G : GameTree);
procedure OverWritePropertyToGameTree(prop : Property; var G : GameTree; var changed : boolean);


{Ajout et retrait des fils}
procedure AddSonToGameTree(fils,G : GameTree);
procedure AddSonToGameTreeSansDupliquer(fils,G : GameTree);
procedure SetBrothers(var G : GameTree; brothers : GameTreeList);
procedure DeleteAllSons(var G : GameTree);
procedure DeleteThisSon(var G : GameTree; var whichSon : GameTree);
function  DeleteSonsOfThatColor(var G : GameTree; couleur : SInt16) : SInt16;
procedure SetSons(var G : GameTree; whichSons : GameTreeList);


{gestion des interversions}
function EstSeulDansSonOrbiteDInterversions(G : GameTree) : boolean;
function GetOrbiteInterversions(G : GameTree) : GameTreeList;
procedure DetacheDeSonOrbiteDInterversions(var G : GameTree);
procedure FusionOrbitesInterversions(var G1,G2 : GameTree);


{creation et destruction de GameTreeList}
function NewGameTreeList : GameTreeList;
procedure DisposeGameTreeList(var L : GameTreeList);
procedure CompacterGameTreeList(var L : GameTreeList);
function DuplicateGameTreeList(var L : GameTreeList) : GameTreeList;


{fonctions d'acces à une GameTreeList}
function HeadOfGameTreeList(L : GameTreeList) : GameTree;
function TailOfGameTreeList(L : GameTreeList) : GameTreeList;
function GameTreeListLength(L : GameTreeList) : SInt32;


{Ajout et retrait d'element à une GameTreeList}
procedure ReplaceHeadOfGameTreeList(tree : GameTree; var L : GameTreeList);
function CreateOneElementGameTreeList(tree : GameTree) : GameTreeList;
procedure AddGameTreeToList(tree : GameTree; var L : GameTreeList);
procedure AddGameTreeToListSansDupliquer(tree : GameTree; var L : GameTreeList);
procedure DeleteThisGameTreeInList(var whichTree : GameTree; var L : GameTreeList);


{permutations de l'arbre}
procedure BringToFrontInGameTreeList(whichTree : GameTree; var L : GameTreeList);
procedure BringToPositionNInGameTreeList(whichTree : GameTree; N : SInt16; var L : GameTreeList);
procedure PromeutParmiSesFreres(G : GameTree);
procedure MakeMainLineInGameTree(var G : GameTree);
procedure TrierLesFilsDeCeNoeud(G : GameTree; critereDeTri : SInt32; var changed : boolean);



{iterateurs sur les GameTree et les GameTreeList}
function MapGameTreeList(L : GameTreeList; f : GameTreeToGameTreeFunc) : GameTreeList;
procedure ForEachGameTreeInListDo(L : GameTreeList ; DoWhat : GameTreeProc);
procedure ForEachGameTreeInListDoAvecResult(L : GameTreeList ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ForEachGameTreeInListDoAvecGameTree(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);
procedure ForEachGameTreeInListDoAvecGameTreeEtResult(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTreeEtResult; var Tree : GameTree; var result : SInt32);
procedure ForEachNodeInGameTreeDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ForEachNodeInGameTreeListDoAvecResult(L : GameTreeList ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ForEachPropertyInGameTreeDoAvecResult(G : GameTree ; DoWhat : PropertyProcAvecResult; var result : SInt32);
procedure ForEachPropertyInGameTreeListDoAvecResult(L : GameTreeList ; DoWhat : PropertyProcAvecResult; var result : SInt32);
procedure ForEachPropertyOfTheseTypesInNodeDo(G : GameTree; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
procedure ForEachPropertyOfTheseTypesInNodeDoAvecResult(G : GameTree; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecResult; var result : SInt32);


{fonction de recherche dans un GameTree ou une GameTreeList}
function NodeHasTheseProperties(G : GameTree; L : PropertyList) : boolean;
function NodeHasThesePropertyTypes(G : GameTree; whichTypes : SetOfPropertyTypes) : boolean;
function NodeHasNoMoreThanThesePropertyTypes(G : GameTree; whichTypes : SetOfPropertyTypes) : boolean;
function GameTreeListEstVide(L : GameTreeList) : boolean;
function ExistsInGameTreeList(G : GameTree; L : GameTreeList) : boolean;


{fonctions de selection}
function SelectFirstGameTreeWithThisPropertyInList(prop : Property; L : GameTreeList) : GameTree;
function SelectFirstSubtreeWithThisProperty(prop : Property; G : GameTree) : GameTree;
function SelectFirstPropertyOfTypesInGameTree(whichTypes : SetOfPropertyTypes; G : GameTree) : PropertyPtr;
function SelectNthGameTreeInList(n : SInt16; L : GameTreeList) : GameTree;
function SelectNthRealGameTreeInList(n : SInt16; L : GameTreeList) : GameTree;
function SelectNthSon(n : SInt16; G : GameTree) : GameTree;
function SelectNthRealSon(n : SInt16; G : GameTree) : GameTree;
function SelectTheSonAfterThisMove(G : GameTree; square,couleur : SInt16) : GameTree;


{iterateurs sur les fils}
procedure ForEachSonDo(G : GameTree ; DoWhat : GameTreeProc);
procedure ForEachSonDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ForEachSonDoAvecGameTree(G : GameTree ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);


{iterateurs sur les freres}
procedure ForEachBrotherDo(G : GameTree ; DoWhat : GameTreeProc);
procedure ForEachBrotherDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ForEachBrotherDoAvecGameTree(G : GameTree ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);


{parcours de l'arbre}
function NextNodePourParcoursEnProfondeurArbre(G : GameTree) : GameTree;
procedure ParcourirGameTree(noeudDepart,noeudArret : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure LancerNouveauParcoursOfGameTree(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
procedure ContinuerParcoursOfGameTree(DoWhat : GameTreeProcAvecResult; var result : SInt32);


{recherche générale dans l'arbre}
function SearchFromGameTree(noeudDepart,noeudArret : GameTree; whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
function FindNodeInGameTree(G : GameTree; whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
function FindNextNodeInGameTree(whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
function FindNodeAvecCesPropertiesDansGameTree(G : GameTree; L : PropertyList) : GameTree;
function FindNextNodeAvecCesPropertiesDansGameTree(L : PropertyList) : GameTree;


{recherche d'une chaine de caracteres dans l'arbre}
function FindStringInNode(var G : GameTree; var whichStringPtr : SInt32) : boolean;
function FindUpperStringWithoutDiacriticsInNode(var G : GameTree; var whichStringPtr : SInt32) : boolean;
procedure SetLastStringSearchedInGameTree(s : String255);
function GetLastStringSearchedInGameTree : String255;


{fonction d'ecriture de GameTree dans le rapport}
procedure WriteGameTreeDansRapport(var G : GameTree);
procedure WritelnGameTreeDansRapport(var G : GameTree);
procedure WriteStringAndGameTreeDansRapport(s : String255; G : GameTree);
procedure WritelnStringAndGameTreeDansRapport(s : String255; G : GameTree);
procedure WriteGameNodeDansRapport(var G : GameTree);
procedure WritelnGameNodeDansRapport(var G : GameTree);
procedure WriteStringAndGameNodeDansRapport(s : String255; G : GameTree);
procedure WritelnStringAndGameNodeDansRapport(s : String255; G : GameTree);


{fonction de symetrie}
procedure EffectueSymetrieOnGameTree(G : GameTree; axeSymetrie : SInt32);


{fonction de traduction des chemins en String255}
function CoupOfGameNodeEnString(G : GameTree) : String255;
function CoupsDuCheminAuDessusEnString(G : GameTree) : String255;
function CoupsDuCheminJusquauNoeudEnString(G : GameTree) : String255;
function CoupsOfMainLineInGameTreeEnString(G : GameTree) : String255;
function CoupsOfMainLineIncludingThisNodeEnString(G : GameTree) : String255;


{gestion des interversions}
procedure CreeTableHachageInterversions;
procedure DisposeTableHachageInterversions;
procedure VideTableHashageInterversions;
procedure GarbageCollectionDansTableHashageInterversions;
procedure MetDansHashTableInterversions(G : GameTree; var positionEtTrait : PositionEtTraitRec; hashIndex : InterversionHashIndexRec);
procedure SetDansHashTableInterversion(index : SInt32; G : GameTree; stamp : SInt32);
procedure SetNbCollisionsInterversions(n : SInt32);
function GetDansHashTableInversion(index : SInt32; var stamp : SInt32) : GameTree;
function CalculeIndexHashTableInterversions(var positionEtTrait : PositionEtTraitRec) : SInt32;
function ExisteDansHashTableInterversions(var positionEtTrait : PositionEtTraitRec; var GameTreeInterversion : GameTree; var hashIndex : InterversionHashIndexRec) : boolean;
function GetNbCollisionsInterversions : SInt32;


{gestion des noeuds virtuels}
function IsAVirtualNode(G : GameTree) : boolean;
function IsARealNode(G : GameTree) : boolean;
function IsAVirtualNodeUsedForZebraBookDisplay(G : GameTree) : boolean;
function IsAVirtualSon(G : GameTree; square,couleur : SInt16) : boolean;
function IsARealSon(G : GameTree; square,couleur : SInt16) : boolean;
function IsAVirtualSonUsedForZebraBookDisplay(G : GameTree; square,couleur : SInt16) : boolean;
procedure MarquerCeNoeudCommeVirtuel(G : GameTree);
procedure MarquerCeNoeudCommeReel(G : GameTree);
procedure DetruitLesFilsVirtuelsInutilesDeCeNoeud(var G : GameTree);
procedure DetruitLesFilsZebraBookInutilesDeCeNoeud(var G : GameTree);


{gestion des scores }
function SelectScorePropertyOfNode(G : GameTree) : PropertyPtr;
function SelectMovePropertyOfNode(G : GameTree) : PropertyPtr;
procedure AddScorePropertyToGameTreeSansDuplication(prop : Property; var G : GameTree);
procedure AjoutePropertyValeurDeCoupDansGameTree(quelGenreDeReflexion,scorePourNoir : SInt32; G : GameTree);
procedure AjoutePropertyScoreExactPourCetteCouleurDansGameTree(quelGenreDeReflexion,score,couleur : SInt32; G : GameTree);
procedure RemettreScorePropertyDansCeNoeud(var G : GameTree);
procedure RetropropagerScoreDesFilsDansGameTree(G : GameTree);
function GetEndgameScoreDeCetteCouleurDansGameNode(G : GameTree; couleur : SInt32; var scoreMinPourCouleur,scoreMaxPourCouleur : SInt32) : boolean;
function NodeHasAPerfectScoreInformation(G : GameTree) : boolean;
function NbreDeFilsAyantUnScoreParfait(G : GameTree) : SInt32;
function IsAWinningNode(G : GameTree) : boolean;
function IsALosingNode(G : GameTree) : boolean;
function IsADrawNode(G : GameTree) : boolean;
function GetValeurMinimumOfNode(G : GameTree; deltaFinale : SInt32) : SInt32;
function GetValeurMaximumOfNode(G : GameTree; deltaFinale : SInt32) : SInt32;
function ConnaitValeurDuNoeud(G : GameTree; deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;
function GetZebraBookEvalForThisNode(G : GameTree; forWhichColor : SInt32) : SInt32;


{extraction d'une suite parfaite d'un GameTree}
function PeutCompleterSuiteParfaiteParGameTree(G : GameTree; position : PositionEtTraitRec; var vmin,vmax : SInt32; var listeDesCoups : PropertyList) : boolean;
function PeutCalculerFinaleDansGameTree(G : GameTree; position : PositionEtTraitRec; var listeDesCoups : PropertyList; var vmin,vmax : SInt32) : boolean;


{une fonction de debuggage}
function IsCriticalOrCrashingTree(G : GameTree) : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, Sound
{$IFC NOT(USE_PRELINK)}
    , UnitServicesDialogs, UnitPositionEtTrait, MyStrings, UnitRapport, MyMathUtils, UnitMiniProfiler
    , UnitArbreDeJeuCourant, UnitStrategie, UnitHashing, UnitPagesDeGameTree, UnitPagesDeGameTreeList, UnitScannerUtils, UnitPropertyList, UnitProperties
    , UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/GameTree.lk}
{$ENDC}


{END_USE_CLAUSE}
















var MagicCookiePourWriteGameTreeDansRapport : SInt32;
    MagicCookiePourWriteGameTreeDansFichier : SInt32;

    gRechercheGameTree : record
                          numeroDeLaRecherche          : SInt32;
                          enCours                      : boolean;
                          arbreTraverse                : GameTree;
                          noeudCourant                 : GameTree;
                          dernierNoeudTrouve           : GameTree;
                          nbreTrouvesDerniereRecherche : SInt32;
                          propertiesCherchees          : PropertyList;
                          derniereChaineCherchee       : String255;
                        end;

const nbElementsTableHashageInterversions = 131072 {65536} {32768};
type t_CelluleHachageInterversions = record
                                       theGameTree : GameTree;  {pointeur}
                                       theStamp : SInt32;      {hash stamp}
                                     end;
     t_TableHachageInterversions = array[0..0] of t_CelluleHachageInterversions;
     TableHachageInterversionsPtr = ^t_TableHachageInterversions;
var  TableHachageInterversions : TableHachageInterversionsPtr;
     nbCollisionsInterversions : SInt32;




procedure InitUnitGameTree;
begin
  MagicCookiePourWriteGameTreeDansRapport := 0;
  MagicCookiePourWriteGameTreeDansFichier := 0;



  gRechercheGameTree.numeroDeLaRecherche          := 0;
  gRechercheGameTree.enCours                      := false;
  gRechercheGameTree.nbreTrouvesDerniereRecherche := 0;
  gRechercheGameTree.arbreTraverse                := NIL;
  gRechercheGameTree.noeudCourant                 := NIL;
  gRechercheGameTree.dernierNoeudTrouve           := NIL;
  gRechercheGameTree.propertiesCherchees          := NIL;
  gRechercheGameTree.derniereChaineCherchee       := 'toto';


  InitUnitPagesDeGameTree;
  InitUnitPagesDeGameTreeList;
end;

procedure LibereMemoireUnitGameTree;
begin
  if (gRechercheGameTree.propertiesCherchees <> NIL) then
    DisposePropertyList(gRechercheGameTree.propertiesCherchees);

  DisposeToutesLesPagesDeGameTree;
  DisposeToutesLesPagesDeGameTreeList;
end;


function NewGameTreeList : GameTreeList;
var aux : GameTreeList;
begin
  {aux := GameTreeList(AllocateMemoryPtr(sizeof(GameTreeListRec)));}
  aux := NewGameTreeListPaginee;

  if aux <> NIL then
    begin
      aux^.head := NIL;
      aux^.tail := NIL;
      inc(soldeCreationGameTreeList);
    end;
  NewGameTreeList := aux;
end;


function IsCriticalOrCrashingTree(G : GameTree) : boolean;
begin
  Discard(G);
  IsCriticalOrCrashingTree := false; // IsCriticalOrCrashingTree := (17146448 = longint(G));
end;


procedure DisposeGameTreeList(var L : GameTreeList);
var L2 : GameTreeList;
begin
  while (L <> NIL) do
    begin
      DisposeGameTree(L^.head);

      L2 := L^.tail;

      {DisposeMemoryPtr(Ptr(L));}
      DisposeGameTreeListPaginee(L);
      L := NIL;
      dec(soldeCreationGameTreeList);

      L := L2;

    end;
end;

procedure CompacterGameTreeList(var L : GameTreeList);
var L1,L2 : GameTreeList;
begin

  while (L <> NIL) and (L^.head = NIL) do
    begin

      L1 := L^.tail;

      DisposeGameTreeListPaginee(L);
      dec(soldeCreationGameTreeList);

      L := L1;
    end;

  if (L = NIL) then exit(CompacterGameTreeList);

  L1 := L;
  L2 := L1^.tail;

  while (L2 <> NIL) do
    begin
      if (L2^.head = NIL)
        then
          begin

            L1^.tail := L2^.tail;

            DisposeGameTreeListPaginee(L2);
            dec(soldeCreationGameTreeList);

            L2 := L1^.tail;
          end
        else
          begin
            L1 := L2;
            L2 := L2^.tail;
          end;
    end;
end;


function HeadOfGameTreeList(L : GameTreeList) : GameTree;
begin
  if (L = NIL)
    then HeadOfGameTreeList := NIL
    else HeadOfGameTreeList := L^.head;
end;

function TailOfGameTreeList(L : GameTreeList) : GameTreeList;
begin
  if (L = NIL)
    then TailOfGameTreeList := NIL
    else TailOfGameTreeList := L^.tail;
end;


procedure CopyGameTree(source : GameTree; var dest : GameTree);
begin
  if (source <> NIL) and (dest <> NIL) then
    begin
      dest^.properties          := source^.properties;
      dest^.father              := source^.father;
      dest^.sons                := source^.sons;
      dest^.transpositionOrbite := dest;  {par defaut reduite a soi-meme}
     {dest^.nodeMagicCookie     := source^.nodeMagicCookie;}  {on garde le magic cookie de dest}
    end;
end;

function MapGameTreeListIter(L : GameTreeList; f : GameTreeToGameTreeFunc) : GameTreeList;
var aux : GameTreeList;
begin
  aux := NewGameTreeList;
  if (L <> NIL) then
    begin
      if L^.head <> NIL then
        begin
          aux^.head := NewGameTree;
          if aux^.head <> NIL then CopyGameTree(f(L^.head),aux^.head);
        end;
      if L^.tail <> NIL then aux^.tail := MapGameTreeListIter(L^.tail,f);
    end;
  MapGameTreeListIter := aux;
end;


function MapGameTreeList(L : GameTreeList; f : GameTreeToGameTreeFunc) : GameTreeList;
begin
  MapGameTreeList := MapGameTreeListIter(L,f);
end;


function DuplicateGameTreeList(var L : GameTreeList) : GameTreeList;
var aux : GameTreeList;
begin
  if (L = NIL)
    then DuplicateGameTreeList := NIL
    else
      begin
        aux := MapGameTreeList(L,DuplicateGameTree);
        CompacterGameTreeList(aux);
        DuplicateGameTreeList := aux;
      end;
end;

function GameTreeListLength(L : GameTreeList) : SInt32;
begin
  CompacterGameTreeList(L);
  if (L = NIL) or (L = L^.tail)
    then GameTreeListLength := 0
    else GameTreeListLength := 1 + GameTreeListLength(L^.tail);
end;


function CreateOneElementGameTreeList(tree : GameTree) : GameTreeList;
var aux : GameTreeList;
begin
  aux := NewGameTreeList;
  if aux <> NIL then
    begin
      aux^.head := DuplicateGameTree(tree);
      aux^.tail := NIL;
    end;
  CreateOneElementGameTreeList := aux;
end;


procedure AddGameTreeToListIter(tree : GameTree; var L : GameTreeList);
var L2 : GameTreeList;
begin
  if (L = NIL)
    then L := CreateOneElementGameTreeList(tree)
    else
      begin
        L2 := L;
        while (L2^.tail <> NIL) do
          L2 := L2^.tail;
        L2^.tail := CreateOneElementGameTreeList(tree);
      end;
end;

procedure AddGameTreeToList(tree : GameTree; var L : GameTreeList);
begin
  CompacterGameTreeList(L);
  AddGameTreeToListIter(tree,L);
end;

procedure AddGameTreeToListSansDupliquer(tree : GameTree; var L : GameTreeList);
var L1 : GameTreeList;
begin
  if (L = NIL)
    then
      begin
        L := NewGameTreeList;
        L^.head := tree;
      end
    else
      begin
        L1 := L;
        while L1 <> NIL do
          begin
            if L1^.head = NIL then
              begin
                L1^.head := tree;
                exit(AddGameTreeToListSansDupliquer);
              end;
            if L1^.tail = NIL then
              begin
                L1^.tail := NewGameTreeList;
                L1^.tail^.head := tree;
                exit(AddGameTreeToListSansDupliquer);
              end;
            L1 := L1^.tail;
          end;
      end;
end;


{ whichTree doit etre un element de L, au sens de l'egalite des pointeurs }
procedure DeleteThisGameTreeInList(var whichTree : GameTree; var L : GameTreeList);
var aux,temp : GameTreeList;
begin
  if (whichTree = NIL) or (L = NIL)
    then exit(DeleteThisGameTreeInList);

  aux := L;
  while (aux <> NIL) do
    begin
      if (aux^.tail = aux) then
        begin
          AlerteSimple('boucle infinie dans DeleteThisGameTreeInList !!! Prévenez Stéphane');
          exit(DeleteThisGameTreeInList);
        end;

      if (aux^.head = whichTree) then  {trouve!}
        begin
          {on enleve whichTree de la liste}
          if aux^.tail = NIL
            then
              begin
                aux^.head := NIL;
                aux^.tail := NIL;
              end
            else
              begin
                temp := aux^.tail;
                aux^.head := temp^.head;
                aux^.tail := temp^.tail;
                temp^.head := NIL;
                temp^.tail := NIL;
                CompacterGameTreeList(temp);
              end;
          CompacterGameTreeList(L);

          {on detruit whichTree}
          DisposeGameTree(whichTree);

          exit(DeleteThisGameTreeInList);
        end;
      aux := aux^.tail;
    end;
end;


{ whichTree doit etre un element de L, au sens de l'egalite des pointeurs }
procedure BringToFrontInGameTreeList(whichTree : GameTree; var L : GameTreeList);
var aux,temp,myNewList : GameTreeList;
begin
  if (whichTree = NIL) or (L = NIL)
    then exit(BringToFrontInGameTreeList);

  if (L^.head = whichTree)   {whichTree est deja en tete}
    then exit(BringToFrontInGameTreeList);

  aux := L;
  while (aux <> NIL) do
    begin
      if (aux^.tail = aux) then
        begin
          AlerteSimple('boucle infinie dans BringToFrontInGameTreeList !!! Prévenez Stéphane');
          exit(BringToFrontInGameTreeList);
        end;

      if (aux^.head = whichTree) then  {trouve!}
        begin
          {on enleve whichTree de la liste}
          if aux^.tail = NIL
            then
              begin
                aux^.head := NIL;
                aux^.tail := NIL;
              end
            else
              begin
                temp := aux^.tail;
                aux^.head := temp^.head;
                aux^.tail := temp^.tail;
                temp^.head := NIL;
                temp^.tail := NIL;
                CompacterGameTreeList(temp);
              end;
          CompacterGameTreeList(L);

          {on rajoute whichTree en tete de la liste}
          myNewList := NewGameTreeList;
          myNewList^.tail := L;
          myNewList^.head := whichTree;
          L := myNewList;

          exit(BringToFrontInGameTreeList);
        end;
      aux := aux^.tail;
    end;
end;


procedure BringToPositionNInGameTreeList(whichTree : GameTree; N : SInt16; var L : GameTreeList);
var aux,temp,myNewList : GameTreeList;
    trouve : boolean;
    compteur : SInt16;
begin
  if N <= 1 then
    begin
      BringToFrontInGameTreeList(whichTree,L);
      exit(BringToPositionNInGameTreeList);
    end;

  if (whichTree = NIL) or (L = NIL) then
    exit(BringToPositionNInGameTreeList);

  aux := L;
  compteur := 1;
  trouve := false;
  while (aux <> NIL) and not(trouve) do
    begin
      if (aux^.tail = aux) then
        begin
          AlerteSimple('boucle infinie dans BringToPositionNInGameTreeList !!! Prévenez Stéphane');
          exit(BringToPositionNInGameTreeList);
        end;
      if (aux^.head = whichTree) then  {trouve!}
        begin
          trouve := true;

          { whichTree est-il deja a la bonne place ? }
          if (compteur = N) then exit(BringToPositionNInGameTreeList);

          {on enleve whichTree de la liste}
          if aux^.tail = NIL
            then
              begin
                aux^.head := NIL;
                aux^.tail := NIL;
              end
            else
              begin
                temp := aux^.tail;
                aux^.head := temp^.head;
                aux^.tail := temp^.tail;
                temp^.head := NIL;
                temp^.tail := NIL;
                CompacterGameTreeList(temp);
              end;
          CompacterGameTreeList(L);
          Leave;
        end;
      aux := aux^.tail;
      if aux <> NIL then inc(compteur);
    end;

  if not(trouve) then exit(BringToPositionNInGameTreeList);

  aux := L;
  compteur := 1;
  while (aux <> NIL) and (compteur <> (N-1)) do
    begin
      aux := aux^.tail;
      inc(compteur);
    end;

  {on place whichTree en position N de la liste}
   myNewList := NewGameTreeList;
   myNewList^.head := whichTree;
   myNewList^.tail := aux^.tail;
   aux^.tail := myNewList;

end;

procedure PromeutParmiSesFreres(G : GameTree);
var brothers : GameTreeList;
begin
  if (G = NIL)
    then exit(PromeutParmiSesFreres);
  brothers := GetBrothers(G);
  if GameTreeListEstVide(brothers) then
    begin
      { normalement cela n'arrive que si G est la racine globale de l'arbre de jeu,
        sinon c'est une erreur dans la construction de l'arbre… On devrait sans doute
        tester cela }
      WritelnDansRapport('erreur !!! brothers = NIL dans PromeutParmiSesFreres. Prévenez Stéphane');
      exit(PromeutParmiSesFreres);
    end;
  BringToFrontInGameTreeList(G,brothers);
  SetBrothers(G,brothers);
end;


procedure MakeMainLineInGameTree(var G : GameTree);
begin
  if (G = NIL)
    then exit(MakeMainLineInGameTree);
  if HasBrothers(G) then
    PromeutParmiSesFreres(G);
  if (G^.father = G) then
    begin
      AlerteSimple('boucle infinie dans MakeMainLineInGameTree !!! Prévenez Stéphane');
      exit(MakeMainLineInGameTree);
    end;
  MakeMainLineInGameTree(G^.father);
end;


procedure TrierLesFilsDeCeNoeud(G : GameTree; critereDeTri : SInt32; var changed : boolean);
type element = record
                 fils : GameTree;
                 note : SInt32;
               end;
var table : array[1..64] of element;
    temp : element;
    L : GameTreeList;
    t, k, compteur, couleur, vmin, vmax : SInt32;
begin

  changed := false;

  if (G = NIL) or not(HasSons(G))
    then exit(TrierLesFilsDeCeNoeud);

  for k := 1 to 64 do
    begin
      table[k].fils := NIL;
      table[k]. note := -noteMax;
    end;

  compteur := 0;

  { phase 1 : lire les valeurs de Zebra stockees dans les fils }
  L := GetSons(G);
  couleur := GetCouleurOfMoveInNode(G);

  while (L <> NIL) do
    begin
      if L^.head <> NIL then
        begin
          inc(compteur);
          table[compteur].fils := L^.head;

          case critereDeTri of
            kTriSelonValeursZebra :
              begin
                if IsAVirtualNodeUsedForZebraBookDisplay(L^.head)
                  then table[compteur].note := GetZebraBookEvalForThisNode(L^.head, -couleur)
                  else
                    if not(HasSons(L^.head)) and
                       IsAVirtualNode(L^.head) and
                       GetEndgameScoreDeCetteCouleurDansGameNode(L^.head, GetCouleurOfMoveInNode(L^.head), vmin, vmax)
                        then table[compteur].note := vmin
                        else table[compteur].note := 10000000; // pour que les vrais noeuds de l'arbre restent en tete
              end;
            kTriSelonValeurDeFinale :
              begin
                if IsARealNode(L^.head)
                  then table[compteur].note := 10000000  // pour que les vrais noeuds de l'arbre restent en tete
                  else
                    begin
                      if GetEndgameScoreDeCetteCouleurDansGameNode(L^.head, GetCouleurOfMoveInNode(L^.head), vmin, vmax)
                        then table[compteur].note := vmin
                        else table[compteur].note := -10000000;
                    end;
              end;
          end; {case}

        end;

      if (L^.tail = L) then
        begin
          AlerteSimple('boucle infinie dans TrierLesFilsDeCeNoeud !! Prévenez Stéphane !');
          exit(TrierLesFilsDeCeNoeud);
        end;

      L := L^.tail;
    end;

  { phase 2 : trier les valeurs : on utilise le tri par insertion, qui est stable }
  for t := 1 to compteur do
    for k := t downto 2 do
      if (table[k].note > table[k-1].note) then
        begin
          changed := true;
          temp := table[k-1];
          table[k-1] := table[k];
          table[k] := temp;
        end;

  (*
   WritelnDansRapport('---------------------------');
   WritelnNumDansRapport('NumberOfSons(G) = ',NumberOfSons(G));
   for t := 1 to compteur do
      WritelnNumDansRapport('',table[t].note);
  *)


  { phase 3 : mettre les fils dans l'ordre dans l'arbre }
  for t := compteur downto 1 do
    PromeutParmiSesFreres(table[t].fils);

end;


procedure DeleteAllSons(var G : GameTree);
var theSons : GameTreeList;
begin
  if (G <> NIL) then
    begin
      theSons := GetSons(G);
      DisposeGameTreeList(theSons);
      CompacterGameTreeList(theSons);
      SetSons(G,theSons);
    end;
end;

{ whichSon doit etre un element de G.sons, au sens de l'egalite des pointeurs }
procedure DeleteThisSon(var G : GameTree; var whichSon : GameTree);
var theSons : GameTreeList;
begin
  if (G = NIL) or not(HasSons(G)) then exit(DeleteThisSon);
  theSons := GetSons(G);
  DeleteThisGameTreeInList(whichSon,theSons);
  SetSons(G,theSons);
end;


function IsLeaf(G : GameTree) : boolean;
begin
  IsLeaf := not(IsInternalNode(G));
end;


function IsInternalNode(G : GameTree) : boolean;
begin
  IsInternalNode := HasSons(G);
end;


function DeleteSonsOfThatColor(var G : GameTree; couleur : SInt16) : SInt16;
var nbreDeFils,n : SInt16;
    LeFils : GameTree;
    nbFilsDetruits : SInt16;
begin
  nbFilsDetruits := 0;
  if HasSons(G) then
    begin
      nbreDeFils := NumberOfSons(G);
      for n := nbreDeFils downto 1 do
        begin
          LeFils := SelectNthSon(n,G);
          if (LeFils <> NIL) and
             (((couleur = pionNoir) and  (SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],LeFils) <> NIL)) or
             ((couleur = pionBlanc) and (SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],LeFils) <> NIL)))
            then
              begin
                nbFilsDetruits := nbFilsDetruits+1;
                DeleteThisSon(G,LeFils);
              end;
        end;
    end;
  DeleteSonsOfThatColor := nbFilsDetruits;
end;


procedure SetSons(var G : GameTree; whichSons : GameTreeList);
begin
  if (G <> NIL) then
    begin
      G^.sons := whichSons;
    end;
end;



procedure ForEachGameTreeInListDoIter(L : GameTreeList ; DoWhat : GameTreeProc);
begin
  if (L <> NIL) then
    begin
      if L^.head <> NIL then   {on fait l'action}
        DoWhat(L^.head);
      if L^.tail <> NIL then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachGameTreeInListDoIter !! Prévenez Stéphane !');
              exit(ForEachGameTreeInListDoIter);
            end
          else               {on fait l'appel recursif}
            ForEachGameTreeInListDoIter(L^.tail,DoWhat);
    end;
end;


procedure ForEachGameTreeInListDo(L : GameTreeList ; DoWhat : GameTreeProc);
begin
  ForEachGameTreeInListDoIter(L,DoWhat);
end;

procedure ForEachGameTreeInListDoIterAvecResult(L : GameTreeList ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if L^.head <> NIL then   {on fait l'action}
        DoWhat(L^.head,result,continuer);
      if continuer and (L^.tail <> NIL) then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachGameTreeInListDoIterAvecResult !! Prévenez Stéphane !');
              exit(ForEachGameTreeInListDoIterAvecResult);
            end
          else               {on fait l'appel recursif}
            ForEachGameTreeInListDoIterAvecResult(L^.tail,DoWhat,result);
    end;
end;


procedure ForEachGameTreeInListDoAvecResult(L : GameTreeList ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
begin
  ForEachGameTreeInListDoIterAvecResult(L,DoWhat,result);
end;


procedure ForEachGameTreeInListDoIterAvecGameTree(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if L^.head <> NIL then   {on fait l'action}
        DoWhat(L^.head,Tree,continuer);
      if continuer and (L^.tail <> NIL) then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachGameTreeInListDoIterAvecGameTree !! Prévenez Stéphane !');
              exit(ForEachGameTreeInListDoIterAvecGameTree);
            end
          else               {on fait l'appel recursif}
            ForEachGameTreeInListDoIterAvecGameTree(L^.tail,DoWhat,Tree);
    end;
end;

procedure ForEachGameTreeInListDoAvecGameTree(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);
begin
  ForEachGameTreeInListDoIterAvecGameTree(L,DoWhat,Tree);
end;

procedure ForEachGameTreeInListDoIterAvecGameTreeEtResult(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTreeEtResult; var Tree : GameTree; var result : SInt32);
var continuer : boolean;
begin
  if (L <> NIL) then
    begin
      continuer := true;
      if L^.head <> NIL then   {on fait l'action}
        DoWhat(L^.head,Tree,result,continuer);
      if continuer and (L^.tail <> NIL) then
        if (L^.tail = L)
          then
            begin
              AlerteSimple('boucle infinie dans ForEachGameTreeInListDoIterAvecGameTreeEtResult !! Prévenez Stéphane !');
              exit(ForEachGameTreeInListDoIterAvecGameTreeEtResult);
            end
          else               {on fait l'appel recursif}
            ForEachGameTreeInListDoIterAvecGameTreeEtResult(L^.tail,DoWhat,Tree,result);
    end;
end;


procedure ForEachGameTreeInListDoAvecGameTreeEtResult(L : GameTreeList ; DoWhat : GameTreeProcAvecGameTreeEtResult; var Tree : GameTree; var result : SInt32);
begin
  ForEachGameTreeInListDoIterAvecGameTreeEtResult(L,DoWhat,Tree,result);
end;

procedure ForEachPropertyInGameTreeDoAvecResult(G : GameTree ; DoWhat : PropertyProcAvecResult; var result : SInt32);
begin
  if (G <> NIL) then
    begin
      ForEachPropertyInListDoAvecResult(G^.properties,DoWhat,result);
      ForEachPropertyInGameTreeListDoAvecResult(G^.sons,DoWhat,result);
    end;
end;

procedure ForEachPropertyInGameTreeListDoAvecResult(L : GameTreeList ; DoWhat : PropertyProcAvecResult; var result : SInt32);
var L1 : GameTreeList;
begin
  if (L <> NIL) then
    begin
      L1 := L;
      while L1 <> NIL do
        begin
          ForEachPropertyInGameTreeDoAvecResult(L1^.head,DoWhat,result);
          if (L1^.tail = L1) then
            begin
              AlerteSimple('boucle infinie dans ForEachPropertyInGameTreeListDoAvecResult !! Prévenez Stéphane !');
              exit(ForEachPropertyInGameTreeListDoAvecResult);
            end;
          L1 := L1^.tail;
        end;
    end;
end;

procedure ForEachNodeInGameTreeDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
var continuer : boolean;
begin
  if (G <> NIL) then
    begin
      DoWhat(G,result,continuer);
      if continuer then
        ForEachNodeInGameTreeListDoAvecResult(G^.sons,DoWhat,result);
    end;
end;

procedure ForEachNodeInGameTreeListDoAvecResult(L : GameTreeList ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
var L1 : GameTreeList;
begin
  if (L <> NIL) then
    begin
      L1 := L;
      while L1 <> NIL do
        begin
          ForEachNodeInGameTreeDoAvecResult(L1^.head,DoWhat,result);
          if (L1^.tail = L1) then
            begin
              AlerteSimple('boucle infinie dans ForEachPropertyInGameTreeListDoAvecResult !! Prévenez Stéphane !');
              exit(ForEachNodeInGameTreeListDoAvecResult);
            end;
          L1 := L1^.tail;
        end;
    end;
end;

procedure ForEachPropertyOfTheseTypesInNodeDo(G : GameTree; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProc);
var L2 : PropertyList;
begin
  if (G <> NIL) then
    begin
	    L2 := ExtractPropertiesOfTypes(whichTypes,G^.properties);
	    ForEachPropertyInListDo(L2,DoWhat);
	    DisposePropertyList(L2);
	  end;
end;

procedure ForEachPropertyOfTheseTypesInNodeDoAvecResult(G : GameTree; whichTypes : SetOfPropertyTypes ; DoWhat : PropertyProcAvecResult; var result : SInt32);
var L2 : PropertyList;
begin
  if (G <> NIL) then
    begin
	    L2 := ExtractPropertiesOfTypes(whichTypes,G^.properties);
	    ForEachPropertyInListDoAvecResult(L2,DoWhat,result);
	    DisposePropertyList(L2);
	  end;
end;


function SelectFirstGameTreeWithThisPropertyInList(prop : Property; L : GameTreeList) : GameTree;
begin
  if (L = NIL)
    then
      SelectFirstGameTreeWithThisPropertyInList := NIL
    else
      begin
        while (L <> NIL) do
          begin
            if L^.tail = L then
              begin
                AlerteSimple('boucle infinie dans SelectFirstGameTreeWithThisPropertyInList !! Prévenez Stéphane !');
                exit(SelectFirstGameTreeWithThisPropertyInList);
              end;
            if ExistsInPropertyList(prop,L^.head^.properties) then
              begin                                {found}
                SelectFirstGameTreeWithThisPropertyInList := L^.head;
                exit(SelectFirstGameTreeWithThisPropertyInList)
              end;
            L := L^.tail;
          end;
        SelectFirstGameTreeWithThisPropertyInList := NIL;  {not found}
      end;
end;


function SelectFirstSubtreeWithThisProperty(prop : Property; G : GameTree) : GameTree;
begin
  if (G = NIL)
    then SelectFirstSubtreeWithThisProperty := NIL
    else SelectFirstSubtreeWithThisProperty := SelectFirstGameTreeWithThisPropertyInList(prop,G^.sons);
end;


procedure ReplaceHeadOfGameTreeList(tree : GameTree; var L : GameTreeList);
begin
  CompacterGameTreeList(L);
  if (L <> NIL) then
    begin
      if (L^.head <> NIL) then DisposeGameTree(L^.head);
      L^.head := NewGameTree;
      if L^.head <> NIL then
        CopyGameTree(tree,L^.head);
    end;
end;


function NewGameTree : GameTree;
var aux : GameTree;
begin
  {aux := GameTree(AllocateMemoryPtr(sizeof(GameTreeRec)));}
  aux := NewGameTreePaginee;

  if aux <> NIL then
    begin
      aux^.properties          := NIL;
      aux^.father              := NIL;
      aux^.sons                := NIL;
      aux^.transpositionOrbite := aux;  {par defaut reduite à soi-meme}
      aux^.nodeMagicCookie     := NewMagicCookie;
    end;
  NewGameTree := aux;
  inc(SoldeCreationGameTree);
end;

procedure DisposeGameTree(var G : GameTree);
begin
  if (G <> NIL) then
    begin

    {
      WritelnNumDansRapport('avant DisposePropertyList de G('+NumEnString(SInt32(G))+'), SoldeCreationProperties = ',SoldeCreationProperties);
      }
      DisposePropertyList(G^.properties);

      {
      WritelnNumDansRapport('apres DisposePropertyList de G('+NumEnString(SInt32(G))+'), SoldeCreationProperties = ',SoldeCreationProperties);

      WritelnNumDansRapport('appel de DisposeGameTreeList sur les fils de de G('+NumEnString(SInt32(G))+'), de longueur = ',GameTreeListLength(G^.sons));
      }

      DisposeGameTreeList(G^.sons);

      DetacheDeSonOrbiteDInterversions(G);

      {
      WritelnNumDansRapport('apres DisposeGameTreeList sur les fils de G('+NumEnString(SInt32(G))+'), SoldeCreationProperties = ',SoldeCreationProperties);
      }
      G^.properties           := NIL;
      G^.sons                 := NIL;
      G^.father               := NIL;
      G^.transpositionOrbite  := NIL;
      G^.nodeMagicCookie      := 0;

      {DisposeMemoryPtr(Ptr(G));}
      DisposeGameTreePaginee(G);

      G := NIL;
      dec(soldeCreationGameTree);
    end;
end;


procedure CompacterGameTree(var G : GameTree);
begin

  if (G <> NIL) then
    begin
      CompacterPropertyList(G^.properties);
      ForEachGameTreeInListDo(G^.sons,CompacterGameTree);
      if PropertyListEstVide(G^.properties) and GameTreeListEstVide(G^.sons) then
        begin
          DetacheDeSonOrbiteDInterversions(G);

          G^.properties           := NIL;
          G^.sons                 := NIL;
          G^.father               := NIL;
          G^.transpositionOrbite  := NIL;
          G^.nodeMagicCookie      := 0;

          {DisposeMemoryPtr(Ptr(G));}
          DisposeGameTreePaginee(G);

          G := NIL;
          dec(soldeCreationGameTree);
        end;
    end;
end;


procedure SetFatherOfGameTree(var G : GameTree; var whichFather : GameTree; var continuer : boolean);
begin
  {$UNUSED continuer}
  if (G <> NIL) then
    G^.father := whichFather;
end;



function DuplicateGameTree(var G : GameTree) : GameTree;
var aux : GameTree;
begin
  if (G = NIL)
    then DuplicateGameTree := NIL
    else
      begin
        aux := NewGameTree;
        if aux <> NIL then
          begin
            aux^.properties          := DuplicatePropertyList(G^.properties);
            aux^.sons                := DuplicateGameTreeList(G^.sons);
            ForEachGameTreeInListDoAvecGameTree(aux^.sons,SetFatherOfGameTree,aux);
            aux^.father              := G^.father;
            aux^.transpositionOrbite := aux;      {car l'orbite est par defaut réduite à soi-meme}
            {aux^.nodeMagicCookie    := G^.nodeMagicCookie;}  {on garde le magic cookie donne par NewGameTree}
          end;
        DuplicateGameTree := aux;
      end;
end;

function GameTreePtrEstValide(G : GameTree) : boolean;
begin
  if G = NIL
    then GameTreePtrEstValide := false
    else GameTreePtrEstValide := (G^.transpositionOrbite <> NIL) and (G^.nodeMagicCookie <> 0);
end;


function GameTreeListEstVide(L : GameTreeList) : boolean;
begin
  GameTreeListEstVide := (L = NIL);
end;


function GameTreeEstVide(G : GameTree) : boolean;
begin
  GameTreeEstVide := (G = NIL);
end;


function MakeGameTreeFromPropertyList(L : PropertyList) : GameTree;
var aux : GameTree;
begin
  if (L = NIL)
    then MakeGameTreeFromPropertyList := NIL
    else
      begin
        aux := NewGameTree;
        if aux <> NIL then
          aux^.properties := DuplicatePropertyList(L);
        MakeGameTreeFromPropertyList := aux;
      end;
end;


function MakeGameTreeFromPropertyListSansDupliquer(L : PropertyList) : GameTree;
var aux : GameTree;
begin
  if (L = NIL)
    then MakeGameTreeFromPropertyListSansDupliquer := NIL
    else
      begin
        aux := NewGameTree;
        if aux <> NIL then
          aux^.properties := L;
        MakeGameTreeFromPropertyListSansDupliquer := aux;
      end;
end;


function MakeGameTreeFromProperty(prop : Property) : GameTree;
var aux : GameTree;
begin
  if PropertyEstVide(prop)
    then MakeGameTreeFromProperty := NIL
    else
      begin
        aux := NewGameTree;
        if aux <> NIL then
          aux^.properties := CreateOneElementPropertyList(prop);
        MakeGameTreeFromProperty := aux;
      end;
end;

procedure AddPropertyToGameTree(prop : Property; var G : GameTree);
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyToGameTree, prévenez Stéphane !');
      exit(AddPropertyToGameTree);
    end;

  if not(PropertyEstVide(prop)) then
    begin
      if (G = NIL) then G := NewGameTree;
      if (G <> NIL) then
         AddPropertyToList(prop,G^.properties);
    end;
end;

procedure AddPropertyToGameTreeSansDuplication(prop : Property; var G : GameTree);
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddPropertyToGameTreeSansDuplication, prévenez Stéphane !');
      exit(AddPropertyToGameTreeSansDuplication);
    end;

  if not(PropertyEstVide(prop)) then
    begin
      if (G = NIL) then G := NewGameTree;
      if (G <> NIL) then
         AddPropertyToListSansDuplication(prop,G^.properties);
    end;
end;


procedure AddTranspositionPropertyToGameTree(var texte : String255; var G : GameTree);
var interversionProp : Property;
begin
  if (G <> NIL) and (SelectFirstPropertyOfTypesInGameTree([TranspositionProp],G) = NIL) then
    begin
      interversionProp := MakeStringProperty(TranspositionProp,texte);
      AddPropertyToGameTree(interversionProp,G);
      DisposePropertyStuff(interversionProp);
    end;
end;

procedure DeletePropertyFromGameNode(prop : Property; var G : GameTree);
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in DeletePropertyFromGameNode, prévenez Stéphane !');
      exit(DeletePropertyFromGameNode);
    end;

  if PropertyEstVide(prop) or (G = NIL) then
    exit(DeletePropertyFromGameNode);

  if (G <> NIL) then
    DeletePropertyFromList(prop,G^.properties);
end;

procedure DeletePropertiesOfTheseTypeFromGameNode(whichType : SInt16; var G : GameTree);
begin
  if (G = NIL) then
    exit(DeletePropertiesOfTheseTypeFromGameNode);

  if (G <> NIL) then
    DeletePropertiesOfThisTypeInList(whichType,G^.properties);
end;


procedure DeletePropertiesOfTheseTypesFromGameNode(whichTypes : SetOfPropertyTypes; var G : GameTree);
begin
  if (G = NIL) then
    exit(DeletePropertiesOfTheseTypesFromGameNode);

  if (G <> NIL) then
    DeletePropertiesOfTheseTypesInList(whichTypes,G^.properties);
end;


procedure OverWritePropertyToGameTree(prop : Property; var G : GameTree; var changed : boolean);
begin
  changed := false;

  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in OverWritePropertyToGameTree, prévenez Stéphane !');
      exit(OverWritePropertyToGameTree);
    end;

  if not(PropertyEstVide(prop)) and (G <> NIL) then
    OverWritePropertyToList(prop,G^.properties,changed);
end;


function GetFather(G : GameTree) : GameTree;
begin
  if (G = NIL)
   then GetFather := NIL
   else GetFather := G^.father;
end;

procedure AddSonToGameTree(fils,G : GameTree);
begin
  if (G <> NIL) and (fils <> NIL) then
    begin
      fils^.father := G;
      AddGameTreeToList(fils,G^.sons);
    end;
end;

procedure AddSonToGameTreeSansDupliquer(fils,G : GameTree);
begin
  if (G <> NIL) and (fils <> NIL) then
    begin
      fils^.father := G;
      AddGameTreeToListSansDupliquer(fils,G^.sons);
    end;
end;

function HasSons(G : GameTree) : boolean;
begin
  if (G = NIL) or (G^.sons = NIL)
    then HasSons := false
    else HasSons := true;
end;

function GetSons(G : GameTree) : GameTreeList;
begin
  if (G = NIL)
   then GetSons := NIL
   else GetSons := G^.sons;
end;

function NumberOfSons(G : GameTree) : SInt16;
begin
  if (G = NIL)
    then NumberOfSons := 0
    else NumberOfSons := GameTreeListLength(GetSons(G));
end;

procedure CountRealNodes(var G : GameTree; var count : SInt32; var continuer : boolean);
begin {$UNUSED continuer}
  if IsARealNode(G) then inc(count);
end;

procedure CountVirtualNodes(var G : GameTree; var count : SInt32; var continuer : boolean);
begin {$UNUSED continuer}
  if IsAVirtualNode(G) then inc(count);
end;

procedure CountVirtualNodesUsedForZebraBookDisplay(var G : GameTree; var count : SInt32; var continuer : boolean);
begin {$UNUSED continuer}
  if IsAVirtualNodeUsedForZebraBookDisplay(G) then inc(count);
end;

function NumberOfVirtualSons(G : GameTree) : SInt16;
var result : SInt32;
begin
  if (G = NIL)
    then NumberOfVirtualSons := 0
    else
      begin
        result := 0;
        ForEachSonDoAvecResult(G,CountVirtualNodes,result);
        NumberOfVirtualSons := result;
      end;
end;

function NumberOfRealSons(G : GameTree) : SInt16;
var result : SInt32;
begin
  if (G = NIL)
    then NumberOfRealSons := 0
    else
      begin
        result := 0;
        ForEachSonDoAvecResult(G,CountRealNodes,result);
        NumberOfRealSons := result;
      end;
end;

function NumberOfVirtualNodesUsedForZebraBookDisplay(G : GameTree) : SInt16;
var result : SInt32;
begin
  if (G = NIL)
    then NumberOfVirtualNodesUsedForZebraBookDisplay := 0
    else
      begin
        result := 0;
        ForEachSonDoAvecResult(G,CountVirtualNodesUsedForZebraBookDisplay,result);
        NumberOfVirtualNodesUsedForZebraBookDisplay := result;
      end;
end;

function HasBrothers(G : GameTree) : boolean;
begin
  if (G = NIL) or (G^.father = NIL) or GameTreeListEstVide(G^.father^.sons)
    then HasBrothers := false
    else HasBrothers := true;
end;

function GetBrothers(G : GameTree) : GameTreeList;
begin
  if (G = NIL) or (G^.father = NIL)
    then GetBrothers := NIL
    else GetBrothers := G^.father^.sons;
end;


function GetOlderBrother(G : GameTree) : GameTree;
begin
  if (G = NIL) or (G^.father = NIL) or (G^.father^.sons = NIL)
    then GetOlderBrother := G
    else GetOlderBrother := G^.father^.sons^.head;
end;

function GetNextBrother(G : GameTree) : GameTree;
var L : GameTreeList;
begin
  if (G = NIL) or (G^.father = NIL) or (G^.father^.sons = NIL)
    then
      begin
        GetNextBrother := NIL;
        exit(GetNextBrother);
      end
    else
      begin
        L := G^.father^.sons;
        while (L <> NIL) do
          begin
            if (L^.head = G) then
              begin
                if L^.tail = NIL
                  then GetNextBrother := NIL
                  else GetNextBrother := L^.tail^.head;
                exit(GetNextBrother);
              end;
            L := L^.tail;
          end;
      end;

  AlerteSimple('Should never happen dans GetNextBrother !! Prévenez Stéphane');
  WritelnDansRapport('Should never happen dans GetNextBrother !! Prévenez Stéphane');

  GetNextBrother := NIL;
end;

function GetOlderSon(G : GameTree) : GameTree;
begin
  if (G = NIL) or (G^.sons = NIL)
    then GetOlderSon := NIL
    else GetOlderSon := G^.sons^.head;
end;

function GetPropertyList(G : GameTree) : PropertyList;
begin
  if G = NIL
    then GetPropertyList := NIL
    else GetPropertyList := G^.properties;
end;

function GetGameNodeMagicCookie(G : GameTree) : SInt32;
begin
  if G = NIL
    then
      begin
        WritelnDansRapport('WARNING : GetGameNodeMagicCookie sur un arbre vide ! ');
        GetGameNodeMagicCookie := 0;
      end
    else
      GetGameNodeMagicCookie := G^.nodeMagicCookie;
end;


procedure SetBrothers(var G : GameTree; brothers : GameTreeList);
begin
  if (G = NIL) or (G^.father = NIL)
    then exit(SetBrothers)
    else G^.father^.sons := brothers;
end;



function EstSeulDansSonOrbiteDInterversions(G : GameTree) : boolean;
begin
  EstSeulDansSonOrbiteDInterversions := (G = NIL) or
                                        (G^.transpositionOrbite = NIL) or
                                        (G^.transpositionOrbite = G);
end;

function GetOrbiteInterversions(G : GameTree) : GameTreeList;
var L : GameTreeList;
    aux : GameTree;
begin
  L := NIL;
  if (G <> NIL) then
    begin
      AddGameTreeToList(G,L);
      aux := G;
      while (aux <> NIL) and (aux^.transpositionOrbite <> NIL) and (aux^.transpositionOrbite <> G) do
        begin
          if aux^.transpositionOrbite = aux then
            begin
              AlerteSimple('boucle infinie dans GetOrbiteInterversions !! Prévenez Stéphane');
              exit(GetOrbiteInterversions);
            end;
          aux := aux^.transpositionOrbite;
          AddGameTreeToList(aux,L);
        end;
    end;
  GetOrbiteInterversions := L;
end;


procedure DetacheDeSonOrbiteDInterversions(var G : GameTree);
var aux : GameTree;
begin
  if not((G = NIL) or (G^.transpositionOrbite = NIL) or (G^.transpositionOrbite = G)) then
    begin
      aux := G;
      while (aux <> NIL) and (aux^.transpositionOrbite <> NIL) and (aux^.transpositionOrbite <> G) do
        begin
          if aux^.transpositionOrbite = aux then
            begin
              AlerteSimple('boucle infinie dans DetacheDeSonOrbiteDInterversions !! Prévenez Stéphane');
              exit(DetacheDeSonOrbiteDInterversions);
            end;
          aux := aux^.transpositionOrbite;
        end;
     {detachement de l'orbite}
     aux^.transpositionOrbite := G^.transpositionOrbite;
     G^.transpositionOrbite := G;
   end;
end;

procedure FusionOrbitesInterversions(var G1,G2 : GameTree);
var aux1,aux2 : GameTree;
    memeOrbite : boolean;
begin
  if not((G1 = NIL) or (G2 = NIL) or (G1 = G2)) then  {egalite de pointeurs}
    begin
      if G1^.transpositionOrbite = NIL then G1^.transpositionOrbite := G1;
      if G2^.transpositionOrbite = NIL then G2^.transpositionOrbite := G2;

      {
      WritelnNumDansRapport('G1 = ',SInt32(G1));
      WritelnNumDansRapport('G1.orbite = ',SInt32(G1^.transpositionOrbite));

      WritelnNumDansRapport('G2 = ',SInt32(G2));
      WritelnNumDansRapport('G2.orbite = ',SInt32(G2^.transpositionOrbite));
      }

      memeOrbite := false;

		  aux1 := G1;
		  while (aux1 <> NIL) and (aux1^.transpositionOrbite <> NIL) and (aux1^.transpositionOrbite <> G1) do
		    begin
		      {WritelnNumDansRapport('aux1 = ',SInt32(aux1));
	         WritelnNumDansRapport('aux1.orbite = ',SInt32(aux1^.transpositionOrbite));}

		      if aux1^.transpositionOrbite = aux1 then
		        begin
		          AlerteSimple('boucle infinie (1) dans FusionOrbitesInterversions !! Prévenez Stéphane');
		          exit(FusionOrbitesInterversions);
		        end;
		      aux1 := aux1^.transpositionOrbite;

		      if (aux1 = G2) then memeOrbite := true;
		    end;

		  aux2 := G2;
		  while (aux2 <> NIL) and (aux2^.transpositionOrbite <> NIL) and (aux2^.transpositionOrbite <> G2) do
		    begin
		      {WritelnNumDansRapport('aux2 = ',SInt32(aux2));
	         WritelnNumDansRapport('aux2.orbite = ',SInt32(aux2^.transpositionOrbite));}

		      if aux2^.transpositionOrbite = aux2 then
		        begin
		          AlerteSimple('boucle infinie (2) dans FusionOrbitesInterversions !! Prévenez Stéphane');
		          exit(FusionOrbitesInterversions);
		        end;
		      aux2 := aux2^.transpositionOrbite;

		      if (aux2 = G1) then memeOrbite := true;
		    end;

		  {Concatenation des orbites}
		  if not(memeOrbite) then
		    begin
		      aux2^.transpositionOrbite := G1;
		      aux1^.transpositionOrbite := G2;
		    end;
    end;
end;



function SelectFirstPropertyOfTypesInGameTree(whichTypes : SetOfPropertyTypes; G : GameTree) : PropertyPtr;
begin
  if (G = NIL)
    then SelectFirstPropertyOfTypesInGameTree := NIL
    else SelectFirstPropertyOfTypesInGameTree := SelectFirstPropertyOfTypes(whichTypes,G^.properties);
end;


function NodeHasThesePropertyTypes(G : GameTree; whichTypes : SetOfPropertyTypes) : boolean;
begin
  NodeHasThesePropertyTypes := (SelectFirstPropertyOfTypesInGameTree(whichTypes, G) <> NIL);
end;



function NodeHasNoMoreThanThesePropertyTypes(G : GameTree; whichTypes : SetOfPropertyTypes) : boolean;
begin
  if (G = NIL)
    then NodeHasNoMoreThanThesePropertyTypes := false
    else NodeHasNoMoreThanThesePropertyTypes := PropertyListHasNoMoreThanTheseTypes(whichTypes, G^.properties);
end;


function SelectNthGameTreeInList(n : SInt16; L : GameTreeList) : GameTree;
var i : SInt16;
    aux : GameTreeList;
begin
  if (L = NIL) or (n <= 0)
    then SelectNthGameTreeInList := NIL
    else
      begin
        aux := L;
        i := 1;
        while (i < n) and (aux <> NIL) do
          begin
            aux := aux^.tail;
            inc(i);
          end;
        if (i = n) and (aux <> NIL)
          then SelectNthGameTreeInList := aux^.head
          else SelectNthGameTreeInList := NIL;
      end;
end;

function SelectNthRealGameTreeInList(n : SInt16; L : GameTreeList) : GameTree;
var i : SInt16;
    aux : GameTreeList;
begin
  if (L = NIL) or (n <= 0)
    then SelectNthRealGameTreeInList := NIL
    else
      begin
        aux := L;
        if IsARealNode(aux^.head)
          then i := 1
          else i := 0;
        while (i < n) and (aux <> NIL) do
          begin
            aux := aux^.tail;
            if IsARealNode(aux^.head) then inc(i);
          end;
        if (i = n) and (aux <> NIL)
          then SelectNthRealGameTreeInList := aux^.head
          else SelectNthRealGameTreeInList := NIL;
      end;
end;


function SelectNthSon(n : SInt16; G : GameTree) : GameTree;
begin
  if (G = NIL) or (n <= 0)
    then SelectNthSon := NIL
    else SelectNthSon := SelectNthGameTreeInList(n,GetSons(G));
end;

function SelectNthRealSon(n : SInt16; G : GameTree) : GameTree;
begin
  if (G = NIL) or (n <= 0)
    then SelectNthRealSon := NIL
    else SelectNthRealSon := SelectNthRealGameTreeInList(n,GetSons(G));
end;


function SelectTheSonAfterThisMove(G : GameTree; square,couleur : SInt16) : GameTree;
var prop : Property;
begin
  if ((square < 11) or (square > 88)) or
     ((couleur <> pionNoir) and (couleur <> pionBlanc)) or
     (G = NIL) then
    begin
      SelectTheSonAfterThisMove := NIL;
      exit(SelectTheSonAfterThisMove);
    end;

  if debuggage.arbreDeJeu then
    WritelnDansRapport('appel de SelectSubTreeAfterThisMove('+CoupEnStringEnMajuscules(square)+','+NumEnString(couleur)+')');

  case couleur of
    pionNoir    : prop := MakeOthelloSquareProperty(BlackMoveProp,square);
    pionBlanc   : prop := MakeOthelloSquareProperty(WhiteMoveProp,square);
    otherwise     prop := MakeEmptyProperty;
  end; {case}
  SelectTheSonAfterThisMove := SelectFirstSubtreeWithThisProperty(prop,G);
  DisposePropertyStuff(prop);
end;


procedure ComparePourExists(var theElement,elementATrouver : GameTree; var result : SInt32; var continuer : boolean);
begin
  if theElement = elementATrouver then
    begin
      result := 1;
      continuer := false;
    end;
end;


function ExistsInGameTreeList(G : GameTree; L : GameTreeList) : boolean;
var result : SInt32;
begin
  if (L = NIL) then
    begin
      ExistsInGameTreeList := false;
      exit(ExistsInGameTreeList);
    end;

  result := 0;
  ForEachGameTreeInListDoAvecGameTreeEtResult(L,ComparePourExists,G,result);
  ExistsInGameTreeList := (result >= 1);
end;


function NodeHasTheseProperties(G : GameTree; L : PropertyList) : boolean;
var nodeProperties : PropertyList;
    prop : Property;
    toutesTrouvees : boolean;
begin
  NodeHasTheseProperties := false;

  if not(GameTreeEstVide(G) or PropertyListEstVide(L)) then
    begin
      nodeProperties := GetPropertyList(G);
      if not(PropertyListEstVide(nodeProperties)) then
        begin
          toutesTrouvees := true;

          while toutesTrouvees and (L <> NIL) do
            begin
              prop := L^.head;
              toutesTrouvees := toutesTrouvees and ExistsInPropertyList(prop,nodeProperties);
              L := L^.tail;
            end;

          NodeHasTheseProperties := toutesTrouvees;
        end;
    end;
end;


{iterateurs sur les fils}
procedure ForEachSonDo(G : GameTree ; DoWhat : GameTreeProc);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDo(GetSons(G),DoWhat);
end;

procedure ForEachSonDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDoAvecResult(GetSons(G),DoWhat,result);
end;

procedure ForEachSonDoAvecGameTree(G : GameTree ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDoAvecGameTree(GetSons(G),DoWhat,Tree);
end;



{iterateurs sur les freres}
procedure ForEachBrotherDo(G : GameTree ; DoWhat : GameTreeProc);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDo(GetBrothers(G),DoWhat);
end;

procedure ForEachBrotherDoAvecResult(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDoAvecResult(GetBrothers(G),DoWhat,result);
end;

procedure ForEachBrotherDoAvecGameTree(G : GameTree ; DoWhat : GameTreeProcAvecGameTree; var Tree : GameTree);
begin
  if (G <> NIL) then
    ForEachGameTreeInListDoAvecGameTree(GetBrothers(G),DoWhat,Tree);
end;



function NextNodePourParcoursEnProfondeurArbre(G : GameTree) : GameTree;
var frere : GameTree;
begin
  if (G = NIL) then
    begin
      NextNodePourParcoursEnProfondeurArbre := NIL;
      exit(NextNodePourParcoursEnProfondeurArbre);
    end;

  if HasSons(G)
    then
      NextNodePourParcoursEnProfondeurArbre := GetOlderSon(G)
    else
      begin
        while (G <> NIL) and (G^.father <> NIL) do
          begin
            frere := GetNextBrother(G);
            if (frere <> NIL) then
              begin
                NextNodePourParcoursEnProfondeurArbre := frere;
                exit(NextNodePourParcoursEnProfondeurArbre);
              end;
            G := GetFather(G);
          end;
        NextNodePourParcoursEnProfondeurArbre := G;
      end;
end;


procedure ParcourirGameTree(noeudDepart,noeudArret : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
var continuer : boolean;
begin
  with gRechercheGameTree do
    if (noeudDepart <> NIL) and (noeudArret <> NIL) then
	    begin
        continuer := true;
        noeudCourant := noeudDepart;

        repeat
          DoWhat(noeudCourant,result,continuer);
          if continuer
            then noeudCourant := NextNodePourParcoursEnProfondeurArbre(noeudCourant);
        until not(continuer) or (noeudCourant = noeudDepart) or (noeudCourant = noeudArret);
      end;
end;


procedure LancerNouveauParcoursOfGameTree(G : GameTree ; DoWhat : GameTreeProcAvecResult; var result : SInt32);
begin
  if (G <> NIL) then
    begin
      inc(gRechercheGameTree.numeroDeLaRecherche);
      gRechercheGameTree.arbreTraverse := G;
      gRechercheGameTree.noeudCourant := G;
      ParcourirGameTree(G,G,DoWhat,result);
    end;
end;


procedure ContinuerParcoursOfGameTree(DoWhat : GameTreeProcAvecResult; var result : SInt32);
begin
  ParcourirGameTree(NextNodePourParcoursEnProfondeurArbre(gRechercheGameTree.noeudCourant),
                    gRechercheGameTree.arbreTraverse,DoWhat,result);
end;


function SearchFromGameTree(noeudDepart,noeudArret : GameTree; whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
var trouve : boolean;
begin
  with gRechercheGameTree do
    begin
      SearchFromGameTree := NIL;

      if (noeudDepart = NIL) or (noeudArret = NIL)
        then exit(SearchFromGameTree);

      trouve := false;
      noeudCourant := noeudDepart;

      repeat
        trouve := whichPredicate(noeudCourant,parametre);
        if not(trouve)
          then noeudCourant := NextNodePourParcoursEnProfondeurArbre(noeudCourant);
      until trouve or (noeudCourant = noeudArret) or (noeudCourant = noeudDepart);

      if trouve then
        begin
          inc(nbreTrouvesDerniereRecherche);
          dernierNoeudTrouve := noeudCourant;
          SearchFromGameTree := noeudCourant;
        end;
    end;
end;


procedure ReinitilialiseRechercheDansGameTree(G : GameTree);
begin
  gRechercheGameTree.enCours                      := false;
  gRechercheGameTree.arbreTraverse                := G;
  gRechercheGameTree.noeudCourant                 := G;
  gRechercheGameTree.nbreTrouvesDerniereRecherche := 0;
  gRechercheGameTree.dernierNoeudTrouve           := NIL;
end;


function FindNodeInGameTree(G : GameTree; whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
var result : GameTree;
begin
  ReinitilialiseRechercheDansGameTree(G);
  result := SearchFromGameTree(G,G,whichPredicate,parametre);

  if (whichPredicate(result, parametre))
    then FindNodeInGameTree := result
    else FindNodeInGameTree := NIL;
end;


function FindNextNodeInGameTree(whichPredicate : GameTreePredicate; var parametre : SInt32) : GameTree;
var result : GameTree;
begin
  result := SearchFromGameTree(NextNodePourParcoursEnProfondeurArbre(gRechercheGameTree.noeudCourant),
                               gRechercheGameTree.arbreTraverse,
                               whichPredicate,
                               parametre);

  if (whichPredicate(result, parametre))
    then FindNextNodeInGameTree := result
    else FindNextNodeInGameTree := NIL;
end;


function MatchingPredicate(var G : GameTree; var parametre : SInt32) : boolean;
begin {$UNUSED parametre}
  MatchingPredicate := NodeHasTheseProperties(G,gRechercheGameTree.propertiesCherchees);
end;


procedure SetMatchingPredicate(L : PropertyList);
begin
  with gRechercheGameTree do
    begin
      if (propertiesCherchees <> NIL) then
        DisposePropertyList(propertiesCherchees);
      if (L <> NIL)
        then propertiesCherchees := DuplicatePropertyList(L)
        else propertiesCherchees := NIL;
    end;
end;


function FindNodeAvecCesPropertiesDansGameTree(G : GameTree; L : PropertyList) : GameTree;
var bidlong : SInt32;
begin
  SetMatchingPredicate(L);
  bidlong := 0;
  FindNodeAvecCesPropertiesDansGameTree := FindNodeInGameTree(G,MatchingPredicate,bidlong);
end;


function FindNextNodeAvecCesPropertiesDansGameTree(L : PropertyList) : GameTree;
var bidlong : SInt32;
begin
  SetMatchingPredicate(L);
  bidlong := 0;
  FindNextNodeAvecCesPropertiesDansGameTree := FindNextNodeInGameTree(MatchingPredicate,bidlong);
end;


function FindStringInNode(var G : GameTree; var whichStringPtr : SInt32) : boolean;
var s : String255;
    texte : Ptr;
    longueurCommentaire : SInt32;
    longueurPattern : SInt32;
    depart, k : SInt32;
    commentaire : PackedArrayOfCharPtr;
begin
  FindStringInNode := false;

  if (whichStringPtr <> 0) then
    begin
      s := String255Ptr(whichStringPtr)^ ;
      GetCommentaireDeCeNoeud(G, texte, longueurCommentaire);

      if (texte <> NIL) and (longueurCommentaire > 0) then
        begin
      	  depart := 0;
      	  longueurPattern := LENGTH_OF_STRING(s);
      	  commentaire := PackedArrayOfCharPtr(texte);

      	  while (depart >= 0) and ((depart + longueurPattern - 1) <= longueurCommentaire) do
      	    begin
      			  k := 0;
      			  while (k < longueurPattern) and (commentaire^[depart + k] = s[k+1]) do
      			    inc(k);

      			  if (k = longueurPattern) then
      			    begin
      			      FindStringInNode := true;
      			      exit(FindStringInNode);
      			    end;

      			  depart := depart + 1;
      			end;
        end;
    end;
end;


function FindUpperStringWithoutDiacriticsInNode(var G : GameTree; var whichStringPtr : SInt32) : boolean;
var s : String255;
    texte : Ptr;
    longueurCommentaire : SInt32;
    longueurPattern : SInt32;
    depart, k : SInt32;
    commentaire : PackedArrayOfCharPtr;
begin
  FindUpperStringWithoutDiacriticsInNode := false;

  if (whichStringPtr <> 0) then
    begin
      s := String255Ptr(whichStringPtr)^ ;
      GetCommentaireDeCeNoeud(G, texte, longueurCommentaire);

      if (texte <> NIL) and (longueurCommentaire > 0) then
        begin
      	  depart := 0;
      	  longueurPattern := LENGTH_OF_STRING(s);
      	  commentaire := PackedArrayOfCharPtr(texte);

      	  while (depart >= 0) and ((depart + longueurPattern - 1) <= longueurCommentaire) do
      	    begin
      			  k := 0;
      			  while (k < longueurPattern) and (MyUpperString(commentaire^[depart + k],false)[1] = s[k+1]) do
      			    inc(k);

      			  if (k = longueurPattern) then
      			    begin
      			      FindUpperStringWithoutDiacriticsInNode := true;
      			      exit(FindUpperStringWithoutDiacriticsInNode);
      			    end;

      			  depart := depart + 1;
      			end;
        end;
    end;
end;


function GetLastStringSearchedInGameTree : String255;
begin
  GetLastStringSearchedInGameTree := gRechercheGameTree.derniereChaineCherchee;
end;


procedure SetLastStringSearchedInGameTree(s : String255);
begin
  gRechercheGameTree.derniereChaineCherchee := s;
end;


function GetEnsembleDesCasesDesFilsAvecCesProprietes(whichTypes : SetOfPropertyTypes; G : GameTree) : SquareSet;
var result : SquareSet;
    fils : GameTreeList;
    aux : PropertyPtr;
begin
  if (G = NIL)
    then GetEnsembleDesCasesDesFilsAvecCesProprietes := []
    else
      begin
        result := [];
        fils := G^.sons;

        while (fils <> NIL) do
          begin
            aux := SelectFirstPropertyOfTypesInGameTree(whichTypes,fils^.head);
            if aux <> NIL then result := result+[GetOthelloSquareOfProperty(aux^)];
            if  (fils^.tail = fils) then
              begin
                AlerteSimple('boucle infinie dans GetEnsembleDesCasesDesFilsAvecCesProprietes !! Prévenez Stéphane !');
                exit(GetEnsembleDesCasesDesFilsAvecCesProprietes);
              end;
            fils := fils^.tail;
          end;

        GetEnsembleDesCasesDesFilsAvecCesProprietes := result;
      end;
end;


function MakeListOfThesePropertiesOfSons(whichTypes : SetOfPropertyTypes; var G : GameTree) : PropertyList;
var accumulateur : PropertyList;
    fils : GameTreeList;
    aux : PropertyPtr;
begin
  if (G = NIL)
    then
      MakeListOfThesePropertiesOfSons := NIL
    else
      begin
        accumulateur := NIL;

        fils := G^.sons;
        while (fils <> NIL) do
          begin
            aux := SelectFirstPropertyOfTypesInGameTree(whichTypes,fils^.head);
            if aux <> NIL then AddPropertyToList(aux^,accumulateur);

            if  (fils^.tail = fils) then
              begin
                AlerteSimple('boucle infinie dans MakeListOfThesePropertiesOfSons !! Prévenez Stéphane !');
                exit(MakeListOfThesePropertiesOfSons);
              end;

            fils := fils^.tail;
          end;

        MakeListOfThesePropertiesOfSons := accumulateur;
      end;
end;


function MakeListOfMovePropertyOfSons(couleur : SInt16; var G : GameTree) : PropertyList;
begin
  case couleur of
    pionNoir   : MakeListOfMovePropertyOfSons := MakeListOfThesePropertiesOfSons([BlackMoveProp],G);
    pionBlanc  : MakeListOfMovePropertyOfSons := MakeListOfThesePropertiesOfSons([WhiteMoveProp],G);
    otherwise    MakeListOfMovePropertyOfSons := MakeListOfThesePropertiesOfSons([BlackMoveProp,WhiteMoveProp],G);
  end;
end;



function GetEnsembleDesCoupsDesFils(couleur : SInt16; G : GameTree) : SquareSet;
begin
  case couleur of
    pionNoir   : GetEnsembleDesCoupsDesFils := GetEnsembleDesCasesDesFilsAvecCesProprietes([BlackMoveProp],G);
    pionBlanc  : GetEnsembleDesCoupsDesFils := GetEnsembleDesCasesDesFilsAvecCesProprietes([WhiteMoveProp],G);
    otherwise    GetEnsembleDesCoupsDesFils := GetEnsembleDesCasesDesFilsAvecCesProprietes([BlackMoveProp,WhiteMoveProp],G);
  end;
end;

function GetEnsembleDesCoupsDesFilsReels(G : GameTree) : SquareSet;
begin
  if HasSons(G)
    then GetEnsembleDesCoupsDesFilsReels := GetEnsembleDesCoupsDesFreresReels(GetOlderSon(G))
    else GetEnsembleDesCoupsDesFilsReels := [];
end;


function GetEnsembleDesCoupsDesFreres(G : GameTree) : SquareSet;
begin
  if HasBrothers(G)
    then GetEnsembleDesCoupsDesFreres := GetEnsembleDesCoupsDesFils(GetCouleurOfMoveInNode(G),GetFather(G))
    else GetEnsembleDesCoupsDesFreres := [];
end;


function GetEnsembleDesCoupsDesFreresReels(G : GameTree) : SquareSet;
var result : SquareSet;
    couleur, square, k : SInt32;
begin
  result := [];
  if HasBrothers(G) then
    begin
      couleur := GetCouleurOfMoveInNode(G);
      result := GetEnsembleDesCoupsDesFils(couleur,GetFather(G));

      for k := 1 to 64 do
        begin
          square := othellier[k];
          if (square in result) and IsAVirtualSon(GetFather(G),square,couleur)
            then result := result - [square];
        end;
    end;
  GetEnsembleDesCoupsDesFreresReels := result;
end;


function GetSquareOfMoveInNode(G : GameTree; var square : SInt32) : boolean;
var coupBlanc,coupNoir : PropertyPtr;
begin
  if (G = NIL) then
    begin
      {WritelnDansRapport('Bizarre : G = NIL dans GetSquareOfMoveInNode…');}
      square := 0;
      GetSquareOfMoveInNode := false;
      exit(GetSquareOfMoveInNode);
    end;
  coupBlanc := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G);
  coupNoir := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G);

  if (coupBlanc <> NIL) and (coupNoir = NIL) then
    begin
      square := GetOthelloSquareOfProperty(coupBlanc^);
      GetSquareOfMoveInNode := true;
      exit(GetSquareOfMoveInNode);
    end;

  if (coupBlanc = NIL) and (coupNoir <> NIL) then
    begin
      square := GetOthelloSquareOfProperty(coupNoir^);
      GetSquareOfMoveInNode := true;
      exit(GetSquareOfMoveInNode);
    end;

  if (coupBlanc = NIL) and (coupNoir = NIL) then
    begin
      if debuggage.arbreDeJeu then
        begin
		      WritelnDansRapport('');
		      WritelnDansRapport('Erreur dans GetSquareOfMoveInNode : pas de coup dans ce noeud !!');
		      WritelnNumDansRapport('adresse du noeud = ',SInt32(G));
		      WritelnNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie));
		      WritelnDansRapport('');
		    end;
      square := 0;
      GetSquareOfMoveInNode := false;
      exit(GetSquareOfMoveInNode);
    end;

  AlerteSimple('Deux couleurs différentes dans un meme noeud dans GetSquareOfMoveInNode!! Prévenez Stéphane');
  if debuggage.arbreDeJeu then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('erreur : Deux couleurs différentes dans un meme noeud dans GetSquareOfMoveInNode !! Prévenez Stéphane');
      WritelnStringAndPropertyListDansRapport('noeud fautif = ',G^.properties);
      WritelnDansRapport('');
    end;

  square := 0;
  GetSquareOfMoveInNode := false;
end;



function GameNodeHasTooManySons(var G : GameTree; var nbreMinDeFils : SInt32) : boolean;
begin
  if (NumberOfSons(G) < nbreMinDeFils)
    then GameNodeHasTooManySons := false
    else
      begin
        if (NbreDeFilsAyantUnScoreParfait(G) = NumberOfSons(G))
          then GameNodeHasTooManySons := false  {noeud OK dans les fichiers de Lazard}
          else GameNodeHasTooManySons := true;  {noeud douteux au sens de Lazard}
      end;
end;


function GetCouleurOfMoveInNode(G : GameTree) : SInt32;
var coupBlanc,coupNoir : PropertyPtr;
begin
  if (G = NIL) then
    begin
      GetCouleurOfMoveInNode := pionVide;
      exit(GetCouleurOfMoveInNode);
    end;
  coupBlanc := SelectFirstPropertyOfTypesInGameTree([WhiteMoveProp],G);
  coupNoir := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp],G);

  if (coupBlanc <> NIL) and (coupNoir = NIL) then
    begin
      GetCouleurOfMoveInNode := pionBlanc;
      exit(GetCouleurOfMoveInNode);
    end;

  if (coupBlanc = NIL) and (coupNoir <> NIL) then
    begin
      GetCouleurOfMoveInNode := pionNoir;
      exit(GetCouleurOfMoveInNode);
    end;

  if (coupBlanc = NIL) and (coupNoir = NIL) then
    begin
      if debuggage.arbreDeJeu then
        begin
		      WritelnDansRapport('');
		      WritelnDansRapport('Erreur dans GetCouleurOfMoveInNode : pas de coup dans ce noeud !!');
		      WritelnNumDansRapport('adresse du noeud = ',SInt32(G));
		      WritelnNumDansRapport('adresse de la racine = ',SInt32(GetRacineDeLaPartie));
		      WritelnDansRapport('');
		    end;
      GetCouleurOfMoveInNode := pionVide;
      exit(GetCouleurOfMoveInNode);
    end;

  AlerteSimple('Deux couleurs différentes dans un meme noeud dans GetCouleurOfMoveInNode!! Prévenez Stéphane');
  if debuggage.arbreDeJeu then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('erreur : Deux couleurs différentes dans un meme noeud dans GetCouleurOfMoveInNode !! Prévenez Stéphane');
      WritelnStringAndPropertyListDansRapport('noeud fautif = ',G^.properties);
      WritelnDansRapport('');
    end;
  GetCouleurOfMoveInNode := pionVide;

end;


function CoupOfGameNodeEnString(G : GameTree) : String255;
var aux : PropertyPtr;
begin
  if (G = NIL) or PropertyListEstVide(G^.properties) then
    begin
      CoupOfGameNodeEnString := '';
      exit(CoupOfGameNodeEnString);
    end;

  aux := SelectFirstPropertyOfTypes([BlackMoveProp,WhiteMoveProp],G^.properties);
  if aux <> NIL
    then CoupOfGameNodeEnString := CoupEnString(GetOthelloSquareOfProperty(aux^),CassioUtiliseDesMajuscules)
    else CoupOfGameNodeEnString := '';
end;


function CoupsDuCheminAuDessusEnString(G : GameTree) : String255;
var G1 : GameTree;
    result : String255;
begin
  if (G = NIL) then
    begin
      CoupsDuCheminAuDessusEnString := '';
      exit(CoupsDuCheminAuDessusEnString);
    end;

  G1 := G;
  result := '';
  while G1^.father <> NIL do
    begin
      G1 := G1^.father;
      result := Concat(CoupOfGameNodeEnString(G1),result);
    end;
  CoupsDuCheminAuDessusEnString := result;
end;


function CoupsOfMainLineInGameTreeEnString(G : GameTree) : String255;
var G1 : GameTree;
    result : String255;
begin
  if (G = NIL) then
    begin
      CoupsOfMainLineInGameTreeEnString := '';
      exit(CoupsOfMainLineInGameTreeEnString);
    end;

  G1 := G;
  result := CoupOfGameNodeEnString(G1);
  while (G1 <> NIL) and (G1^.sons <> NIL) do
    begin
      if (G1^.sons^.head = G1) then
        begin
          AlerteSimple('boucle infinie dans CoupsOfMainLineInGameTreeEnString !! Prévenez Stéphane !');
          CoupsOfMainLineInGameTreeEnString := '';
          exit(CoupsOfMainLineInGameTreeEnString);
        end;
      G1 := G1^.sons^.head;
      result := Concat(result,CoupOfGameNodeEnString(G1));
    end;
  CoupsOfMainLineInGameTreeEnString := result;
end;


function CoupsDuCheminJusquauNoeudEnString(G : GameTree) : String255;
begin
  if (G = NIL)
    then CoupsDuCheminJusquauNoeudEnString := ''
    else CoupsDuCheminJusquauNoeudEnString := CoupsDuCheminAuDessusEnString(G) +
                                              CoupOfGameNodeEnString(G);
end;

function CoupsOfMainLineIncludingThisNodeEnString(G : GameTree) : String255;
begin
  if (G = NIL)
    then CoupsOfMainLineIncludingThisNodeEnString := ''
    else CoupsOfMainLineIncludingThisNodeEnString := CoupsDuCheminAuDessusEnString(G) +
                                                     CoupOfGameNodeEnString(G) +
                                                     CoupsOfMainLineInGameTreeEnString(GetOlderSon(G));
end;


procedure WriteGameTreeDansRapport(var G : GameTree);
var myMagicCookie : SInt32;
    s : String255;
    L : PropertyList;
begin
  inc(MagicCookiePourWriteGameTreeDansRapport);
  myMagicCookie := MagicCookiePourWriteGameTreeDansRapport;
  if (G = NIL)
    then
      WriteDansRapport('NIL')
    else
      begin
        s := NumEnString(myMagicCookie);
        WritelnDansRapport('begin (Ecriture de GameTree #'+s+')');
        WritelnNumDansRapport('@['+s+'] = ',SInt32(G));
        WritelnStringAndPropertyListDansRapport('properties['+s+'] = ',G^.properties);
        if G^.father = NIL
          then WritelnDansRapport('father['+s+'] = NIL')
          else WritelnNumDansRapport('father['+s+'] = ',SInt32(G^.father));
        if G^.sons = NIL
          then WritelnDansRapport('sons['+s+'] = NIL')
          else
            begin
              L := MakeListOfMovePropertyOfSons(0,G);
              WritelnStringAndPropertyListDansRapport('sons['+s+'] = ',L);
              DisposePropertyList(L);
              WritelnDansRapport('begin (affichage recursif de sons['+s+'])');
              ForEachGameTreeInListDo(G^.sons,WriteGameTreeDansRapport);
              WritelnDansRapport('end (affichage recursif de sons['+s+'])');
            end;
        WritelnDansRapport('end (Ecriture de GameTree #'+s+' )');
      end;
end;

procedure WritelnGameTreeDansRapport(var G : GameTree);
begin
  WriteGameTreeDansRapport(G);
  WritelnDansRapport('');
end;


procedure WriteStringAndGameTreeDansRapport(s : String255; G : GameTree);
begin
  WritelnDansRapport(s);
  WriteGameTreeDansRapport(G);
end;

procedure WritelnStringAndGameTreeDansRapport(s : String255; G : GameTree);
begin
  WritelnDansRapport(s);
  WritelnGameTreeDansRapport(G);
end;


procedure WriteGameNodeDansRapport(var G : GameTree);
var myMagicCookie : SInt32;
    s : String255;
    L : PropertyList;
begin
  inc(MagicCookiePourWriteGameTreeDansRapport);
  myMagicCookie := MagicCookiePourWriteGameTreeDansRapport;
  if (G = NIL)
    then
      WriteDansRapport('NIL')
    else
      begin
        s := NumEnString(myMagicCookie);
        WritelnDansRapport('begin (Ecriture de GameNode #'+s+')');
        WritelnNumDansRapport('@['+s+'] = ',SInt32(G));
        WritelnStringAndPropertyListDansRapport('properties['+s+'] = ',G^.properties);
        if G^.father = NIL
          then WritelnDansRapport('father['+s+'] = NIL')
          else WritelnNumDansRapport('father['+s+'] = ',SInt32(G^.father));
        if G^.sons = NIL
          then WritelnDansRapport('sons['+s+'] = NIL')
          else
            begin
              L := MakeListOfMovePropertyOfSons(0,G);
              WritelnStringAndPropertyListDansRapport('sons['+s+'] = ',L);
              DisposePropertyList(L);
            end;
        WritelnDansRapport('end (Ecriture de GameNode #'+s+' )');
      end;
end;

procedure WritelnGameNodeDansRapport(var G : GameTree);
begin
  WriteGameNodeDansRapport(G);
  WritelnDansRapport('');
end;


procedure WriteStringAndGameNodeDansRapport(s : String255; G : GameTree);
begin
  WritelnDansRapport(s);
  WriteGameNodeDansRapport(G);
end;

procedure WritelnStringAndGameNodeDansRapport(s : String255; G : GameTree); begin
  WritelnDansRapport(s);
  WritelnGameNodeDansRapport(G);
end;



procedure EffectueSymetrieOnGameTree(G : GameTree; axeSymetrie : SInt32);
begin
  if (G <> NIL) then
    ForEachPropertyInGameTreeDoAvecResult(G,EffectueSymetrieOnProperty,axeSymetrie);
end;



procedure VideTableHashageInterversions;
var i : SInt32;
begin
  for i := 0 to nbElementsTableHashageInterversions-1 do
    SetDansHashTableInterversion(i,NIL,0);
  SetNbCollisionsInterversions(0);
end;

procedure GarbageCollectionDansTableHashageInterversions;
var i,stamp : SInt32;
    G : GameTree;
begin
  for i := 0 to nbElementsTableHashageInterversions-1 do
    begin
      G := GetDansHashTableInversion(i,stamp);
      if (G <> NIL) and not(GameTreePtrEstValide(G)) then
        begin
          {WritelnNumDansRapport('@GameTree non valide =',SInt32(G));}
          SetDansHashTableInterversion(i,NIL,0);
        end;
    end;
end;

function CalculeIndexHashTableInterversions(var positionEtTrait : PositionEtTraitRec) : SInt32;
var clef,i,t : SInt32;
begin
  clef := 0;
  for i := 1 to 64 do
    begin
      t := othellier[i];
      case positionEtTrait.position[t] of
        pionNoir   : clef := BXOr(clef , (IndiceHash^^[pionNoir,t]));
        pionBlanc  : clef := BXOr(clef , (IndiceHash^^[pionBlanc,t]));
        pionVide   : clef := BXOr(clef , (IndiceHash^^[pionVide,t]));
      end {case}
    end;

  case GetTraitOfPosition(positionEtTrait) of
    pionNoir   : clef := BXOr(clef,281357080);   {trois nombres differents choisis au hazard}
    pionBlanc  : clef := BXOr(clef,1620260161);  {ils doivent etre > 0 et < MaxLongint}
    pionVide   : clef := BXOr(clef,1417447180);
  end; {case}

  CalculeIndexHashTableInterversions := BAnd(clef,nbElementsTableHashageInterversions-1);
end;


function GetDansHashTableInversion(index : SInt32; var stamp : SInt32) : GameTree;
var cellArrow : ^t_CelluleHachageInterversions;
begin
  if (index < 0) or (index > nbElementsTableHashageInterversions-1)
    then
      begin
        AlerteSimple('Erreur : index = '+NumEnString(index)+ ' dans GetDansHashTableInversion');
        GetDansHashTableInversion := NIL;
        stamp := 0;
      end
    else
      begin
        cellArrow := POINTER_ADD(TableHachageInterversions , index*sizeof(t_CelluleHachageInterversions));
        GetDansHashTableInversion := cellArrow^.theGameTree;
        stamp := cellArrow^.theStamp;
      end;
end;


procedure SetDansHashTableInterversion(index : SInt32; G : GameTree; stamp : SInt32);
var cellArrow : ^t_CelluleHachageInterversions;
begin
  if (index < 0) or (index > nbElementsTableHashageInterversions-1)
    then
      begin
        AlerteSimple('Erreur : index = '+NumEnString(index)+ ' dans SetDansHashTableInterversion');
      end
    else
      begin
        cellArrow := POINTER_ADD(TableHachageInterversions , index*sizeof(t_CelluleHachageInterversions));
        cellArrow^.theGameTree := G;
        cellArrow^.theStamp    := stamp;
      end;
end;


function ExisteDansHashTableInterversions(var positionEtTrait : PositionEtTraitRec; var GameTreeInterversion : GameTree; var hashIndex : InterversionHashIndexRec) : boolean;
var stampDansHashTable : SInt32;
begin

  ExisteDansHashTableInterversions := false;
  GameTreeInterversion := NIL;

  hashIndex.clef := CalculeIndexHashTableInterversions(positionEtTrait);
  hashIndex.stamp := GenericHash(@positionEtTrait,sizeof(PositionEtTraitRec));

  GameTreeInterversion := GetDansHashTableInversion(hashIndex.clef,stampDansHashTable);

  if GameTreePtrEstValide(GameTreeInterversion)
    then
      begin
        if (hashIndex.stamp = stampDansHashTable)
          then ExisteDansHashTableInterversions := true
          else
            begin
              ExisteDansHashTableInterversions := false;
              GameTreeInterversion := NIL;
            end;
      end
    else
      begin
        if (GameTreeInterversion <> NIL) then
          WritelnDansRapport('HAHA dans ExisteDansHashTableInterversions !');
        GameTreeInterversion := NIL;
      end;

end;

procedure MetDansHashTableInterversions(G : GameTree; var positionEtTrait : PositionEtTraitRec; hashIndex : InterversionHashIndexRec);
begin
  with hashIndex do
    begin
      if (clef = 0)  then clef := CalculeIndexHashTableInterversions(positionEtTrait);
      if (stamp = 0) then stamp := GenericHash(@positionEtTrait,sizeof(PositionEtTraitRec));
      SetDansHashTableInterversion(clef,G,stamp);
    end;
end;


function GetNbCollisionsInterversions : SInt32;
begin
  GetNbCollisionsInterversions := nbCollisionsInterversions;
end;


procedure SetNbCollisionsInterversions(n : SInt32);
begin
  nbCollisionsInterversions := n;
end;


procedure CreeTableHachageInterversions;
var tailleHashTableInterversion : SInt32;
begin
  tailleHashTableInterversion := sizeof(t_CelluleHachageInterversions)*nbElementsTableHashageInterversions + 20;
  TableHachageInterversions   := TableHachageInterversionsPtr(AllocateMemoryPtr(tailleHashTableInterversion));
  SetNbCollisionsInterversions(0);
end;


procedure DisposeTableHachageInterversions;
begin
  if TableHachageInterversions <> NIL  then DisposeMemoryPtr(Ptr(TableHachageInterversions));
end;


{un noeud virtuel est un noeud qui verifie ces conditions :
  1) il a une propriete de genre SigmaProp[n] avec n >= 3;
}
function IsAVirtualNode(G : GameTree) : boolean;
var L : PropertyList;
    prop : Property;
    virtualPropertyFound : boolean;
begin
  if (G = NIL)
    then IsAVirtualNode := false
    else
	    begin
	      virtualPropertyFound := false;

	      L := G^.properties;
	      while (L <> NIL) do
	        begin
	          prop := L^.head;

	          if (prop.genre = SigmaProp)
	             and not((GetTripleOfProperty(prop).nbTriples = 1) or (GetTripleOfProperty(prop).nbTriples = 2))
	            then
	              begin
	                virtualPropertyFound := true;
	                IsAVirtualNode := true;
	                exit(IsAVirtualNode);
	              end;

	          L := L^.tail;
	        end;

	      IsAVirtualNode := virtualPropertyFound;
	    end;
end;

function IsARealNode(G : GameTree) : boolean;
begin
  IsARealNode := (G <> NIL) and not(IsAVirtualNode(G));
end;


function IsAVirtualNodeUsedForZebraBookDisplay(G : GameTree) : boolean;
begin
  IsAVirtualNodeUsedForZebraBookDisplay := not(HasSons(G)) and
                                           IsAVirtualNode(G) and
                                           NodeHasNoMoreThanThesePropertyTypes(G, [BlackMoveProp,WhiteMoveProp,SigmaProp,ZebraBookProp,TranspositionRangeProp,TranspositionProp]);
end;


function IsAVirtualSon(G : GameTree; square,couleur : SInt16) : boolean;
begin
  IsAVirtualSon := IsAVirtualNode(SelectTheSonAfterThisMove(G,square,couleur));
end;

function IsARealSon(G : GameTree; square,couleur : SInt16) : boolean;
begin
  IsARealSon := IsARealNode(SelectTheSonAfterThisMove(G,square,couleur));
end;

function IsAVirtualSonUsedForZebraBookDisplay(G : GameTree; square,couleur : SInt16) : boolean;
begin
  IsAVirtualSonUsedForZebraBookDisplay := IsAVirtualNodeUsedForZebraBookDisplay(SelectTheSonAfterThisMove(G,square,couleur));
end;

procedure MarquerCeNoeudCommeVirtuel(G : GameTree);
var prop : Property;
begin
  MarquerCeNoeudCommeReel(G);

  prop := MakeTripleProperty(SigmaProp,MakeTriple(3));
  AddPropertyToGameTreeSansDuplication(prop,G);
  DisposePropertyStuff(prop);
end;

procedure MarquerCeNoeudCommeReel(G : GameTree);
begin
  if IsAVirtualNode(G) then
    DeletePropertiesOfTheseTypeFromGameNode(SigmaProp,G);
end;


procedure DetruitLesFilsVirtuelsInutilesDeCeNoeud(var G : GameTree);
var lesFils,L : GameTreeList;
    unFils : GameTree;
begin
  if (G <> NIL) and HasSons(G) then
    begin
      lesFils := GetSons(G);
      L := lesFils;
      while (L <> NIL) do
        begin
          unFils := L^.head;
          L := L^.tail;

          if (unFils <> NIL) and IsAVirtualNode(unFils) and (PropertyListLength(unFils^.properties) = 2) and (unFils <> GetCurrentNode) then
            begin
              if (unFils = GetCurrentNode) then
                WritelnDansRapport('ASSERT dans DetruitLesFilsVirtuelsInutilesDeCeNoeud : (unFils = GetCurrentNode) !!! ');

              DeleteThisSon(G,unFils);
              lesFils := GetSons(G);
              L := lesFils;
            end;
        end;
    end;
end;


procedure DetruitLesFilsZebraBookInutilesDeCeNoeud(var G : GameTree);
var lesFils,L : GameTreeList;
    unFils : GameTree;
begin
  if (G <> NIL) and HasSons(G) then
    begin
      lesFils := GetSons(G);
      L := lesFils;
      while (L <> NIL) do
        begin
          unFils := L^.head;
          L := L^.tail;

          if (unFils <> NIL) and IsAVirtualNodeUsedForZebraBookDisplay(unFils) and (unFils <> GetCurrentNode) then
            begin
              if (unFils = GetCurrentNode) then
                WritelnDansRapport('ASSERT dans DetruitLesFilsZebraBookInutilesDeCeNoeud : (unFils = GetCurrentNode) !!! ');

              DeleteThisSon(G,unFils);
              lesFils := GetSons(G);
              L := lesFils;
            end;
        end;
    end;
end;



{renvoie un encadrement du score de finale pour la couleur si une telle info est dans le noeud}
function GetEndgameScoreDeCetteCouleurDansGameNode(G : GameTree; couleur : SInt32; var scoreMinPourCouleur,scoreMaxPourCouleur : SInt32) : boolean;
var aux : PropertyPtr;
    scoreMinPourNoir,scoreMaxPourNoir : SInt32;
    couleurDansProp,signe : SInt16;
    scoreEntierDansProp,centiemesDansProp : SInt16;
begin

  if not((couleur = pionNoir) or (couleur = pionBlanc)) then
    begin
      AlerteSimple('couleur <> pionNoir et couleur <> pionBlanc dans GetEndgameScoreDeCetteCouleurDansGameNode');
      WritelnNumDansRapport('dans GetEndgameScoreDeCetteCouleurDansGameNode, couleur = ',couleur);
      GetEndgameScoreDeCetteCouleurDansGameNode := false;
      scoreMinPourCouleur := -10000;
      scoreMaxPourCouleur := -10000;
      exit(GetEndgameScoreDeCetteCouleurDansGameNode);
    end;


  aux := SelectScorePropertyOfNode(G);
  scoreMinPourNoir := -10000;
  scoreMaxPourNoir :=  10000;

  if aux <> NIL then
    case aux^.genre of
      NodeValueProp :
        begin
          GetOthelloValueOfProperty(aux^,couleurDansProp,signe,scoreEntierDansProp,centiemesDansProp);
          if (scoreEntierDansProp = 0) and (centiemesDansProp = 0)
             then
               begin
                 scoreMinPourNoir := 0;
                 scoreMaxPourNoir := 0;
               end
             else
               begin
                 case couleurDansProp of
                   pionNoir  :
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end;
                   pionBlanc :
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                   otherwise  {defaut : comme noir}
                     if signe >= 0
                       then
                         begin
                           scoreMinPourNoir :=  scoreEntierDansProp;
                           scoreMaxPourNoir :=  scoreEntierDansProp;
                         end
                       else
                         begin
                           scoreMinPourNoir :=  - scoreEntierDansProp;
                           scoreMaxPourNoir :=  - scoreEntierDansProp;
                         end;
                 end;{case}

                 { cas speciaux venant des properties V[B+] et V[W+] }
                 if (scoreMinPourNoir = 1) and (scoreMaxPourNoir = 1) then
                   begin
                     scoreMinPourNoir := 2;
                     scoreMaxPourNoir := 64;
                   end;
                 if (scoreMinPourNoir = -1) and (scoreMaxPourNoir = -1) then
                   begin
                     scoreMinPourNoir := -64;
                     scoreMaxPourNoir := -2;
                   end;
	             end;
        end;
      GoodForBlackProp :
        begin
          if SelectFirstPropertyOfTypesInGameTree([DrawMarkProp],G) <> NIL
            then scoreMinPourNoir :=  0
            else scoreMinPourNoir := +2;
          scoreMaxPourNoir := +64;
        end;
      GoodForWhiteProp :
        begin
          scoreMinPourNoir := -64;
          if SelectFirstPropertyOfTypesInGameTree([DrawMarkProp],G) <> NIL
            then scoreMaxPourNoir :=  0
            else scoreMaxPourNoir := -2;
        end;
      DrawMarkProp :
        begin
          if SelectFirstPropertyOfTypesInGameTree([GoodForWhiteProp],G) <> NIL
            then scoreMinPourNoir := -64
            else scoreMinPourNoir :=   0;
          if SelectFirstPropertyOfTypesInGameTree([GoodForBlackProp],G) <> NIL
            then scoreMaxPourNoir := +64
            else scoreMaxPourNoir :=   0;
        end;
    end; {case}

  if (scoreMinPourNoir = -10000) or (scoreMaxPourNoir =  10000) or ((couleur <> pionNoir) and (couleur <> pionBlanc))
    then
      begin
        scoreMinPourCouleur := -10000;
        scoreMaxPourCouleur := -10000;
        GetEndgameScoreDeCetteCouleurDansGameNode := false;
      end
    else
      begin
        GetEndgameScoreDeCetteCouleurDansGameNode  := true;
        if couleur = pionNoir
          then
            begin
              scoreMinPourCouleur :=  scoreMinPourNoir;
              scoreMaxPourCouleur :=  scoreMaxPourNoir;
            end
          else
            begin
              scoreMinPourCouleur := -scoreMaxPourNoir;
              scoreMaxPourCouleur := -scoreMinPourNoir;
            end;
      end;
   if (odd(scoreMinPourNoir) or odd(scoreMaxPourNoir)) then
     begin
       WritelnDansRapport('BIZARRE : mauvaise parité dans GetEndgameScoreDeCetteCouleurDansGameNode!!');
       WritelnNumDansRapport('scoreMinPourNoir = ',scoreMinPourNoir);
       WritelnNumDansRapport('scoreMaxPourNoir = ',scoreMaxPourNoir);
     end;
end;


function NodeHasAPerfectScoreInformation(G : GameTree) : boolean;
var scoreMinPourNoir,scoreMaxPourNoir : SInt32;
begin
  if GetEndgameScoreDeCetteCouleurDansGameNode(G,pionNoir,scoreMinPourNoir,scoreMaxPourNoir) and
     (scoreMinPourNoir = scoreMaxPourNoir) and (scoreMinPourNoir >= -64) and (scoreMinPourNoir <= 64)
     then NodeHasAPerfectScoreInformation := true
     else NodeHasAPerfectScoreInformation := false;
end;


procedure IncrementeCompteurSiNoeudAUnScoreParfait(var G : GameTree; var compteur : SInt32; var continuer : boolean);
begin
  continuer := true;
  if NodeHasAPerfectScoreInformation(G) then inc(compteur);
end;

function NbreDeFilsAyantUnScoreParfait(G : GameTree) : SInt32;
var compteur : SInt32;
begin
  compteur := 0;
  ForEachSonDoAvecResult(G,IncrementeCompteurSiNoeudAUnScoreParfait,compteur);
  NbreDeFilsAyantUnScoreParfait := compteur;
end;


function IsAWinningNode(G : GameTree) : boolean;
var couleur,scoreMin,scoreMax : SInt32;
begin
  if (G = NIL) then
    begin
      IsAWinningNode := false;
      exit(IsAWinningNode);
    end;

  couleur := GetCouleurOfMoveInNode(G);
  if couleur = pionVide then
    begin
      IsAWinningNode := false;
      exit(IsAWinningNode);
    end;

  if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMin,scoreMax)
    then IsAWinningNode := (scoreMin > 0)
    else IsAWinningNode := false;
end;


function IsALosingNode(G : GameTree) : boolean;
var couleur,scoreMin,scoreMax : SInt32;
begin
  if (G = NIL) then
    begin
      IsALosingNode := false;
      exit(IsALosingNode);
    end;

  couleur := GetCouleurOfMoveInNode(G);
  if couleur = pionVide then
    begin
      IsALosingNode := false;
      exit(IsALosingNode);
    end;

  if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMin,scoreMax)
    then IsALosingNode := (scoreMax < 0)
    else IsALosingNode := false;
end;


function IsADrawNode(G : GameTree) : boolean;
var couleur,scoreMin,scoreMax : SInt32;
begin
  if (G = NIL) then
    begin
      IsADrawNode := false;
      exit(IsADrawNode);
    end;

  couleur := GetCouleurOfMoveInNode(G);
  if couleur = pionVide then
    begin
      IsADrawNode := false;
      exit(IsADrawNode);
    end;

  if GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMin,scoreMax)
    then IsADrawNode := (scoreMin = 0) and (scoreMax = 0)
    else IsADrawNode := false;
end;


function SelectScorePropertyOfNode(G : GameTree) : PropertyPtr;
begin
  SelectScorePropertyOfNode := SelectFirstPropertyOfTypesInGameTree([NodeValueProp,GoodForBlackProp,GoodForWhiteProp,DrawMarkProp],G);
end;

function SelectMovePropertyOfNode(G : GameTree) : PropertyPtr;
begin
  SelectMovePropertyOfNode := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],G);
end;


procedure AddScorePropertyToGameTreeSansDuplication(prop : Property; var G : GameTree);
var couleur,couleurDuPere : SInt32;
    scoreMin,scoreMax : SInt32;
    scoreMinDuPere,scoreMaxDuPere : SInt32;
begin
  if not(PropertyEstValide(prop)) then
    begin
      WritelnDansRapport('WARNING : invalid property in AddScorePropertyToGameTreeSansDuplication, prévenez Stéphane !');
      exit(AddScorePropertyToGameTreeSansDuplication);
    end;

  if not(PropertyEstVide(prop)) then
    begin
      if (G = NIL) then G := NewGameTree;
      if (G <> NIL) then
         begin
           AddScorePropertyToListSansDuplication(prop,G^.properties);
           {MarquerCeNoeudCommeReel(G);}

           if (G^.father <> NIL) then
             begin
               couleur       := GetCouleurOfMoveInNode(G);
               couleurDuPere := GetCouleurOfMoveInNode(G^.father);

               if (couleur <> pionVide) and (couleurDuPere <> pionVide) and
                  GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMin,scoreMax) and
                  GetEndgameScoreDeCetteCouleurDansGameNode(G^.father,couleurDuPere,scoreMinDuPere,scoreMaxDuPere) then
                 begin
                   { si on sait que le pere (l'adversaire) est gagnant, et qu'on
                     vient de prouver qu'un de ses fils vaut -2 (ou plus), alors le pere vaut
                     exactement +2 }
                   if (couleur = -couleurDuPere) and
                      (scoreMin = -2) and (scoreMinDuPere > 0) and (scoreMinDuPere <> scoreMaxDuPere) then
                      begin
                        {SysBeep(0);
                        WritelnDansRapport('Chouette (1), je peux propager la valeur du noeud au pere, qui gagne de +2');}
                        AddScorePropertyToGameTreeSansDuplication(prop,G^.father);
                      end;

                   { Plus generalement, si on sait que le pere (l'adversaire) peut faire au moins n,
                     et qu'on vient de prouver qu'un de ses fils peut faire au moins -n, alors le pere
                     vaut exactement n }
                   if (couleur = -couleurDuPere) and
                      (-scoreMin = scoreMinDuPere) and (scoreMinDuPere <> scoreMaxDuPere) then
                      begin
                        {SysBeep(0);
                        WritelnDansRapport('Chouette (2), je peux propager la valeur du noeud au pere, qui fait '+NumEnString(scoreMinDuPere));}
                        AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,scoreMinDuPere,couleurDuPere,G^.father);
                      end;

                   { si le pere est de la meme couleur que ce noeud (on a passe), et
                     qu'on sait qu'on vaut -2 ou plus, et que le pere est perdant, alors
                     le pere vaut exactement -2 }
                   if (couleur = couleurDuPere) and
                      (scoreMin = -2) and (scoreMaxDuPere < 0) and (scoreMinDuPere <> scoreMaxDuPere) then
                      begin
                        {SysBeep(0);
                        WritelnDansRapport('Chouette (3), je peux propager la valeur du noeud au pere, qui perd de -2');}
                        AddScorePropertyToGameTreeSansDuplication(prop,G^.father);
                      end;

                   { Plus generalement, si on sait que le pere est de la meme couleur que ce noeud (on a passe),
                     que l'on peut faire n ou plus et que le pere peut faire n au maximum, alors
                     le pere vaut exactement n }
                   if (couleur = couleurDuPere) and
                      (scoreMin = scoreMaxDuPere) and (scoreMinDuPere <> scoreMaxDuPere) then
                      begin
                        {SysBeep(0);
                        WritelnDansRapport('Chouette (4), je peux propager la valeur du noeud au pere, qui fait '+NumEnString(scoreMaxDuPere));}
                        AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,scoreMaxDuPere,couleurDuPere,G^.father);
                      end;
                 end;

               if (couleur <> pionVide) and (couleurDuPere <> pionVide) and
                  GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,scoreMin,scoreMax) and (scoreMin > 0) then
                 begin

                   {si on sait qu'un noeud est gagnant et que la couleur du noeud pere est l'adversaire,
                    on sait que le pere est un coup perdant}
                   if (couleurDuPere <> couleur) and not(IsALosingNode(G^.father)) then
                     begin
                       if (scoreMin = 64)
		                     then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,-64,couleurDuPere,G^.father)
		                     else AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,-2,couleurDuPere,G^.father);
                     end;

                   {si on sait qu'un noeud est gagnant et que la couleur du noeud pere est le meme (passe),
                    on sait que le pere est un coup gagnant}
                   if (couleurDuPere = couleur) and not(IsAWinningNode(G^.father)) then
                     begin
                       if (scoreMin = 64)
		                     then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,64,couleurDuPere,G^.father)
		                     else AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,2,couleurDuPere,G^.father);
                     end;
                 end;

             end;
         end;
    end;
end;


procedure RemettreScorePropertyDansCeNoeud(var G : GameTree);
var valeurMinNoir,valeurMaxNoir : SInt32;
begin
  if GetEndgameScoreDeCetteCouleurDansGameNode(G,pionNoir,valeurMinNoir, valeurMaxNoir) then
    begin
      if (valeurMinNoir = valeurMaxNoir)
        then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,valeurMinNoir,pionNoir,G)
        else
          begin
            if (valeurMinNoir > 0) then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMinNoir,pionNoir,G) else
            if (valeurMaxNoir < 0) then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMaxNoir,pionNoir,G);
          end;
    end;
end;


procedure RetropropagerScoreDesFilsDansGameTree(G : GameTree);
begin
  ForEachSonDo(G,RemettreScorePropertyDansCeNoeud);
end;


procedure AjoutePropertyValeurDeCoupDansGameTree(quelGenreDeReflexion,scorePourNoir : SInt32; G : GameTree);
var scoreProperty : Property;
begin
  (*
  WritelnDansRapport('Entree dans AjoutePropertyValeurDeCoupDansGameTree...');
  WritelnNumDansRapport('quelGenreDeReflexion = ',quelGenreDeReflexion);
  WritelnNumDansRapport('scorePourNoir = ',scorePourNoir);
  *)

  if (G = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT(G <> NIL) dans AjoutePropertyValeurDeCoupDansGameTree !!');
      exit(AjoutePropertyValeurDeCoupDansGameTree);
    end;

  if (G <> NIL) then
    begin
      if (quelGenreDeReflexion = ReflParfait) and odd(scorePourNoir) then
        begin
          {SysBeep(0);}
          WritelnNumDansRapport('PAS NORMAL ! dans AjoutePropertyValeurDeCoupDansGameTree, scorePourNoir = ',scorePourNoir);
        end;


      if ((scorePourNoir < -64) or (scorePourNoir > 64)) and
         not(GenreDeReflexionInSet(quelGenreDeReflexion,[ReflMilieu,ReflRetrogradeMilieu,ReflMilieuExhaustif,ReflZebraBookEval,ReflZebraBookEvalSansDoutePerdant,ReflZebraBookEvalSansDouteGagnant])) then
        begin
          WritelnDansRapport('ERREUR : scorePourNoir = '+NumEnString(scorePourNoir)+' dans AjoutePropertyValeurDeCoupDansGameTree(reflexion de finale), prévenez Stéphane !');
          WritelnNumDansRapport('quelGenreDeReflexion = ',quelGenreDeReflexion);
          Sysbeep(0);
          exit(AjoutePropertyValeurDeCoupDansGameTree);
        end;

		  scoreProperty := MakeScoringProperty(quelGenreDeReflexion,scorePourNoir);

		  AddScorePropertyToGameTreeSansDuplication(scoreProperty,G);

		  DisposePropertyStuff(scoreProperty);

		  (*
		  WritelnDansRapport('... sortie de AjoutePropertyValeurDeCoupDansGameTree');
		  *)

		end;
end;


procedure AjoutePropertyScoreExactPourCetteCouleurDansGameTree(quelGenreDeReflexion,score,couleur : SInt32; G : GameTree);
begin
  if (G = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT(G <> NIL) dans AjoutePropertyScoreExactPourCetteCouleurDansGameTree !!');
      exit(AjoutePropertyScoreExactPourCetteCouleurDansGameTree);
    end;

  if (couleur <> pionNoir) and (couleur <> pionBlanc) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT((couleur <> pionNoir) and (couleur <> pionBlanc)) dans AjoutePropertyScoreExactPourCetteCouleurDansGameTree !!');
      exit(AjoutePropertyScoreExactPourCetteCouleurDansGameTree);
    end;

  if (quelGenreDeReflexion = ReflParfait) and odd(score) then
    begin
      {SysBeep(0);}
      WritelnNumDansRapport('PAS NORMAL ! dans AjoutePropertyScoreExactPourCetteCouleurDansGameTree, scorePourNoir = ',score);
    end;

  if couleur = pionNoir
    then AjoutePropertyValeurDeCoupDansGameTree(quelGenreDeReflexion,  score, G)
    else AjoutePropertyValeurDeCoupDansGameTree(quelGenreDeReflexion, -score, G);
end;


function PeutCompleterSuiteParfaiteParGameTree(G : GameTree; position : PositionEtTraitRec; var vmin,vmax : SInt32; var listeDesCoups : PropertyList) : boolean;
var position2 : PositionEtTraitRec;
    temp : SInt32;
    scoreProp,moveProp : PropertyPtr;
    longueurListeDesCoups,nbCoupsAjoutes : SInt32;
    liste2 : PropertyList;
    suiteLegale : boolean;
begin

  PeutCompleterSuiteParfaiteParGameTree := false;

  if not(GetPositionEtTraitACeNoeud(G, position2, 'PeutCompleterSuiteParfaiteParGameTree')) or
     not(SamePositionEtTrait(position,position2)) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : not(SamePositionEtTrait(position,PositionEtTraitACeNoeud(G))) dans PeutCompleterSuiteParfaiteParGameTree');
      exit(PeutCompleterSuiteParfaiteParGameTree);
    end;

  if GetTraitOfPosition(position) = -GetCouleurOfMoveInNode(G)
    then
      begin
        temp := vmin;
        vmin := -vmax;
        vmax := -temp;
      end;

  scoreProp := SelectScorePropertyOfNode(G);
  if (scoreProp = NIL) or (scoreProp^.genre <> NodeValueProp) then
    begin
      SysBeep(0);
      if (scoreProp = NIL)
        then WritelnDansRapport('ASSERT : (scoreProp = NIL) dans PeutCompleterSuiteParfaiteParGameTree')
        else WritelnDansRapport('ASSERT : (scoreProp^.genre <> NodeValueProp) dans PeutCompleterSuiteParfaiteParGameTree');
      exit(PeutCompleterSuiteParfaiteParGameTree);
    end;

(*WritelnDansRapport('avant NbCasesVidesDansPosition');
  AttendFrappeClavier;*)


(* creation de la liste des coups *)


(*WritelnStringAndPropertyListDansRapport('apres NewPropertyList, listeDesCoups = ',listeDesCoups);*)
  nbCoupsAjoutes := 0;
  repeat
    G := SelectFirstSubtreeWithThisProperty(scoreProp^,G);

    (*
    if (G = NIL) then
      begin
        WritelnDansRapport('G = NIL');
        AttendFrappeClavier;
      end; *)

    moveProp := SelectMovePropertyOfNode(G);
    if moveProp <> NIL then
      begin
        AddPropertyToList(moveProp^,listeDesCoups);
        inc(nbCoupsAjoutes);
      (*WritelnStringAndPropertyListDansRapport('apres AddPropertyToList, listeDesCoups = ',listeDesCoups);
        AttendFrappeClavier;*)
      end;

    (*
    if (moveProp = NIL) then
      begin
        WritelnDansRapport('moveProp = NIL');
        AttendFrappeClavier;
      end; *)

  until (G = NIL) or (moveProp = NIL);

(*WritelnDansRapport('avant PropertyListLength');
  AttendFrappeClavier;*)

  longueurListeDesCoups := PropertyListLength(listeDesCoups);

(*WritelnNumDansRapport('longueurListeDesCoups = ',longueurListeDesCoups);
  AttendFrappeClavier;*)

  if (longueurListeDesCoups > 0) and (nbCoupsAjoutes > 0) then
    begin
      (* testons la legalite de la suite des coups *)
      suiteLegale := true;
		  liste2 := listeDesCoups;

		(*WritelnStringAndPropertyListDansRapport('avant la boucle, liste2 = ',liste2);
      AttendFrappeClavier;*)

		  repeat
		  (*WritelnDansRapport('avant PlayMoveProperty :');
		    WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
		    AttendFrappeClavier;*)

		    suiteLegale := suiteLegale and PlayMoveProperty(liste2^.head,position);
		    liste2 := liste2^.tail;

		  (*WritelnStringAndPropertyListDansRapport('dans la boucle, liste2 = ',liste2);
        AttendFrappeClavier;*)

		  until (liste2 = NIL);

		(*WritelnDansRapport('apres la boucle :');
		  WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
		  AttendFrappeClavier;*)

		  if not(suiteLegale) then
		    begin
		      SysBeep(0);
		      WritelnDansRapport('WARNING : not(suiteLegale) dans PeutCompleterSuiteParfaiteParGameTree');
		    end;

      if suiteLegale and (GetTraitOfPosition(position) = pionVide) then
        begin

        (*WritelnDansRapport('je mets PeutCompleterSuiteParfaiteParGameTree à true');
          AttendFrappeClavier;*)

          PeutCompleterSuiteParfaiteParGameTree := true;

         (*  WritelnStringAndPropertyListDansRapport('dans PeutCompleterSuiteParfaiteParGameTree, listeDesCoups = ',listeDesCoups); *)

        end;
    end;

end;


function PeutCalculerFinaleDansGameTree(G : GameTree; position : PositionEtTraitRec; var listeDesCoups : PropertyList; var vmin,vmax : SInt32) : boolean;
begin
  PeutCalculerFinaleDansGameTree := false;

(*WritelnDansRapport('avant ConnaitValeurDuNoeudParEndgameTree');
  AttendFrappeClavier;*)

  if (listeDesCoups = NIL) then
    begin
      SysBeep(0);
      WritelnDansRapport('ASSERT : listeDesCoups = NIL dans PeutCalculerFinaleDansGameTree');
      exit(PeutCalculerFinaleDansGameTree);
    end;

  if (GetTraitOfPosition(position) <> pionVide) and ConnaitValeurDuNoeud(G,kDeltaFinaleInfini,vmin,vmax)
     then
       PeutCalculerFinaleDansGameTree := PeutCompleterSuiteParfaiteParGameTree(G, position, vmin, vmax, listeDesCoups) ;

end;



function GetValeurMinimumOfNode(G : GameTree; deltaFinale : SInt32) : SInt32;
var couleur,valeurMin,valeurMax : SInt32;
begin {$UNUSED deltaFinale}

  if (G <> NIL) then
    begin
		  couleur := GetCouleurOfMoveInNode(G);

		  (* d'abord on cherche une info exacte (WLD ou score exact) dans le noeud *)
		  if ((couleur = pionNoir) or (couleur = pionBlanc)) and
		      GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,valeurMin,valeurMax) then
		    begin
		      GetValeurMinimumOfNode := valeurMin;
		      exit(GetValeurMinimumOfNode);
		    end;
		end;

  GetValeurMinimumOfNode := -64; {par defaut}
end;

function GetValeurMaximumOfNode(G : GameTree; deltaFinale : SInt32) : SInt32;
var couleur,valeurMin,valeurMax : SInt32;
begin {$UNUSED deltaFinale}

  if (G <> NIL) then
    begin
		  couleur := GetCouleurOfMoveInNode(G);

		  (* d'abord on cherche une info exacte (WLD ou score exact) dans le noeud *)
		  if ((couleur = pionNoir) or (couleur = pionBlanc)) and
		      GetEndgameScoreDeCetteCouleurDansGameNode(G,couleur,valeurMin,valeurMax) then
		    begin
		      GetValeurMaximumOfNode := valeurMax;
		      exit(GetValeurMaximumOfNode);
		    end;
		end;

  GetValeurMaximumOfNode := +64;  {par defaut}
end;

function ConnaitValeurDuNoeud(G : GameTree; deltaFinale : SInt32; var vmin,vmax : SInt32) : boolean;
begin
  vmin := GetValeurMinimumOfNode(G,deltaFinale);
  vmax := GetValeurMaximumOfNode(G,deltaFinale);

  if vmin < vmax
    then ConnaitValeurDuNoeud := false
    else
      begin
        ConnaitValeurDuNoeud := true;
        if vmin > vmax then
          begin
		        SysBeep(0);
		        WritelnDansRapport('ERROR : vmin > vmax dans ConnaitValeurDuNoeud');
		        WritelnNumDansRapport('vmin = ',vmin);
		        WritelnNumDansRapport('vmax = ',vmax);
		      end;
      end;
end;


function GetZebraBookEvalForThisNode(G : GameTree; forWhichColor : SInt32) : SInt32;
var couleurDansProperty,signe,valeurEntiere,centiemes : SInt16;
    prop : PropertyPtr;
    note : SInt32;
begin
  note := -noteMax;


  if (G <> NIL) then
    begin
      prop := SelectFirstPropertyOfTypesInGameTree([ZebraBookProp], G);
      if (prop <> NIL) then
        begin
          GetOthelloValueOfProperty(prop^,couleurDansProperty,signe,valeurEntiere,centiemes);

          note := 100*valeurEntiere + centiemes;
          if (signe < 0) then note := -note;

          if couleurDansProperty <> forWhichColor then
            begin
              couleurDansProperty := -couleurDansProperty;
              note := -note;
            end;

          (*
          if forWhichColor = pionBlanc
            then WritelnNumDansRapport('Blanc : ',note)
            else WritelnNumDansRapport('Noir : ',note);
          *)

        end;
    end;

  GetZebraBookEvalForThisNode := note;
end;

end.




