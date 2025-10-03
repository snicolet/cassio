UNIT Zebra_to_Cassio;

INTERFACE

 USES UnitDefCassio;






{ Initialisation de l'unité}
procedure InitUnitZebraBook;                                                                                                                                                        ATTRIBUTE_NAME('InitUnitZebraBook')
procedure LibereMemoireUnitZebraBook;                                                                                                                                               ATTRIBUTE_NAME('LibereMemoireUnitZebraBook')



{ Traduction en Pascal des typages des fonctions C de Zebra}
procedure prepare_zebra_hash;                                                                                                                                                       EXTERNAL_NAME('prepare_zebra_hash');
procedure extraire_vals_from_zebra_book(indexVal : SInt32; var node : ZebraBookNode; Score_Noir,Score_Blanc,Alternative_Move,Alternative_Score : integerP; Flags : integerP);       EXTERNAL_NAME('extraire_vals_from_zebra_book');
function trouver_position_in_zebra_book(Pos : longintP; var node : ZebraBookNode; orientation : longintP; file_name : charP; probableIndex : SInt32) : SInt32;                      EXTERNAL_NAME('trouver_position_in_zebra_book');
function symetrise_coup_for_zebra_book(orientation : SInt32; move : SInt32) : SInt32;                                                                                               EXTERNAL_NAME('symetrise_coup_for_zebra_book');
function number_of_positions_in_zebra_book : SInt32;                                                                                                                                EXTERNAL_NAME('number_of_positions_in_zebra_book');



{ Lecture de la bibliotheque de Zebra }
procedure LoadZebraBook(withCheckEvents : boolean);                                                                                                                                 ATTRIBUTE_NAME('LoadZebraBook')
function ZebraBookEstIntrouvable : boolean;                                                                                                                                         ATTRIBUTE_NAME('ZebraBookEstIntrouvable')
procedure SetZebraBookEstIntrouvable(flag : boolean);                                                                                                                               ATTRIBUTE_NAME('SetZebraBookEstIntrouvable')


{ Les fonctions d'interface avec Cassio}
function GetZebraBookName : String255;                                                                                                                                              ATTRIBUTE_NAME('GetZebraBookName')
function ReadZebraBookValuesFromDisc(const plat : plateauOthello; var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; var Flags : SInt16; indexProbable : SInt32) : SInt32;    ATTRIBUTE_NAME('ReadZebraBookValuesFromDisc')
procedure LanceDemandeAffichageZebraBook(const fonctionAppelante : String255);                                                                                                      ATTRIBUTE_NAME('LanceDemandeAffichageZebraBook')
procedure TraiteDemandeAffichageZebraBook;                                                                                                                                          ATTRIBUTE_NAME('TraiteDemandeAffichageZebraBook')
procedure LireBibliothequeDeZebraPourCurrentNode(const fonctionAppelante : String255);                                                                                              ATTRIBUTE_NAME('LireBibliothequeDeZebraPourCurrentNode')
procedure WritelnZebraValuesDansRapport(var pos : PositionEtTraitRec);                                                                                                              ATTRIBUTE_NAME('WritelnZebraValuesDansRapport')
function BibliothequeDeZebraEstAfficheeSurOthellier : boolean;                                                                                                                      ATTRIBUTE_NAME('BibliothequeDeZebraEstAfficheeSurOthellier')


{ Selections des options}
function GetZebraBookOptions : SInt32;                                                                                                                                              ATTRIBUTE_NAME('GetZebraBookOptions')
procedure SetZebraBookOptions(options : SInt32);                                                                                                                                    ATTRIBUTE_NAME('SetZebraBookOptions')
function ZebraBookACetteOption(mask : SInt32) : boolean;                                                                                                                            ATTRIBUTE_NAME('ZebraBookACetteOption')
procedure AjouterZebraBookOption(mask : SInt32);                                                                                                                                    ATTRIBUTE_NAME('AjouterZebraBookOption')
procedure RetirerZebraBookOption(mask : SInt32);                                                                                                                                    ATTRIBUTE_NAME('RetirerZebraBookOption')
procedure ToggleZebraOption(mask : SInt32);                                                                                                                                         ATTRIBUTE_NAME('ToggleZebraOption')
procedure SetUsingZebraBook(flag : boolean);                                                                                                                                        ATTRIBUTE_NAME('SetUsingZebraBook')
function GetUsingZebraBook : boolean;                                                                                                                                               ATTRIBUTE_NAME('GetUsingZebraBook')


{ Gestion des evenements pendant la lecture du fichier bibliotheque de Zebra }
function lecture_zebra_book_interrompue_par_evenement : SInt32;                                                                                                                     ATTRIBUTE_NAME('lecture_zebra_book_interrompue_par_evenement')
function CassioEstEnTrainDeLireLaBibliothequeDeZebra : boolean;                                                                                                                     ATTRIBUTE_NAME('CassioEstEnTrainDeLireLaBibliothequeDeZebra')
function ZebraBookDemandeAccelerationDesEvenements : boolean;                                                                                                                       ATTRIBUTE_NAME('ZebraBookDemandeAccelerationDesEvenements')
procedure SetZebraBookDemandeAccelerationDesEvenements(newValue : boolean; var oldValue : boolean);                                                                                 ATTRIBUTE_NAME('SetZebraBookDemandeAccelerationDesEvenements')


{ Lecture en acces direct du fichier de la bibliotheque de Zebra }
function cassio_must_get_zebra_nodes_from_disk : SInt32;                                                                                                                            ATTRIBUTE_NAME('cassio_must_get_zebra_nodes_from_disk')
procedure SetCassioMustGetZebraNodesFromDisk(flag : boolean);                                                                                                                       ATTRIBUTE_NAME('SetCassioMustGetZebraNodesFromDisk')
function get_number_of_positions_in_zebra_book_from_disk : SInt32;                                                                                                                  ATTRIBUTE_NAME('get_number_of_positions_in_zebra_book_from_disk')
procedure get_zebra_node_from_disk(index : SInt32; var node : ZebraBookNode);                                                                                                       ATTRIBUTE_NAME('get_zebra_node_from_disk')
procedure swap_endianess_of_zebra_node( var node : ZebraBookNode);                                                                                                                  ATTRIBUTE_NAME('swap_endianess_of_zebra_node')
procedure swap_endianess_of_short_for_zebra( n : SInt16Ptr) ;                                                                                                                       ATTRIBUTE_NAME('swap_endianess_of_short_for_zebra')
procedure swap_endianess_of_int_for_zebra( n : SInt32Ptr) ;                                                                                                                         ATTRIBUTE_NAME('swap_endianess_of_int_for_zebra')
procedure BeginUseZebraNodes(fonctionAppelante : String255);                                                                                                                        ATTRIBUTE_NAME('BeginUseZebraNodes')
procedure EndUseZebraNodes(fonctionAppelante : String255);                                                                                                                          ATTRIBUTE_NAME('EndUseZebraNodes')
procedure writeln_zebra_node_dans_rapport(index : SInt32; var node : ZebraBookNode);                                                                                                ATTRIBUTE_NAME('writeln_zebra_node_dans_rapport')


{ Gestion des caches de la bibliotheque de Zebra }
procedure ajouter_zebra_node_dans_le_cache_des_presents(theKey : SInt32; var node : ZebraBookNode);                                                                                 ATTRIBUTE_NAME('ajouter_zebra_node_dans_le_cache_des_presents')
procedure enlever_zebra_node_dans_cache_des_presents(theKey : SInt32);                                                                                                              ATTRIBUTE_NAME('enlever_zebra_node_dans_cache_des_presents')
function zebra_node_est_present_dans_le_cache(theKey : SInt32; var node : ZebraBookNode) : SInt32;                                                                                  ATTRIBUTE_NAME('zebra_node_est_present_dans_le_cache')
procedure VerifierIntegriteDuCacheDesPresents;                                                                                                                                      ATTRIBUTE_NAME('VerifierIntegriteDuCacheDesPresents')


{ Prefect du cache de la bibliotheque de Zebra }
procedure PrefetchZebraIndexOfThisPosition(var pos : PositionEtTraitRec; niveauRecursion : SInt32);                                                                                 ATTRIBUTE_NAME('PrefetchZebraIndexOfThisPosition')
procedure PrefetchPartiePourRechercheDansZebraBook(var partieEnAlpha : String255; posDepart : PositionEtTraitRec; nbCoupsMin,nbCoupsMax,nbCoupsCourant: SInt32);                    ATTRIBUTE_NAME('PrefetchPartiePourRechercheDansZebraBook')
procedure GerePrefetchingOfZebraBook;                                                                                                                                               ATTRIBUTE_NAME('GerePrefetchingOfZebraBook')


{ Magic number }
procedure IncrementerMagicCookieOfZebraBook;                                                                                                                                        ATTRIBUTE_NAME('IncrementerMagicCookieOfZebraBook')
function GetMagicCookieOfZebraBook : SInt32;                                                                                                                                        ATTRIBUTE_NAME('GetMagicCookieOfZebraBook')


{ Algo ruse d'affichage des valeurs de la bibliotheque (pour les mauvais coups) }
function EvaluationHeuristiquePourAffichageBiblZebra(var whichPos : PositionEtTraitRec; valeurMilieuDeZebra : SInt32; var genreDeNote : SInt32) : SInt32;                           ATTRIBUTE_NAME('EvaluationHeuristiquePourAffichageBiblZebra')
procedure SetZebraBookContemptWindowWidth(whichContempt : SInt32);                                                                                                                  ATTRIBUTE_NAME('SetZebraBookContemptWindowWidth')
function GetZebraBookContemptWindowWidth : SInt32;                                                                                                                                  ATTRIBUTE_NAME('GetZebraBookContemptWindowWidth')
function EstUneEvaluationDansLeBookDeZebra(genreDeNote : SInt32) : boolean;                                                                                                         ATTRIBUTE_NAME('EstUneEvaluationDansLeBookDeZebra')
function RessembleAUneNoteDeFinale(note : SInt32) : boolean;                                                                                                                        ATTRIBUTE_NAME('RessembleAUneNoteDeFinale')
procedure ResetMinEtMaxValuationDeZebraAffichee;                                                                                                                                    ATTRIBUTE_NAME('ResetMinEtMaxValuationDeZebraAffichee')
function GetMaxValuationDeZebraAffichee : SInt32;                                                                                                                                   ATTRIBUTE_NAME('GetMaxValuationDeZebraAffichee')
function GetMinValuationDeZebraAffichee : SInt32;                                                                                                                                   ATTRIBUTE_NAME('GetMinValuationDeZebraAffichee')
procedure UpdateMaxValuationDeZebraAffichee(squareValue, genreDeNote : SInt32);                                                                                                     ATTRIBUTE_NAME('UpdateMaxValuationDeZebraAffichee')
procedure UpdateMinValuationDeZebraAffichee(squareValue, genreDeNote : SInt32);                                                                                                     ATTRIBUTE_NAME('UpdateMinValuationDeZebraAffichee')
procedure EffacerValeursDeZebraMiserablesSiNecessaire;                                                                                                                              ATTRIBUTE_NAME('EffacerValeursDeZebraMiserablesSiNecessaire')


{ Gestion des affichages des noeuds virtuels de la bibliotheque dans l'arbre de jeu }
procedure TrierLesFilsSelonLesNotesDeLaBibliothequeDeZebra(G : GameTree);                                                                                                           ATTRIBUTE_NAME('TrierLesFilsSelonLesNotesDeLaBibliothequeDeZebra')
procedure NotifyThatThisGameTreeHasVirtualNodes(G : GameTree);                                                                                                                      ATTRIBUTE_NAME('NotifyThatThisGameTreeHasVirtualNodes')
procedure ClearUselessVirtualZebraNodes;                                                                                                                                            ATTRIBUTE_NAME('ClearUselessVirtualZebraNodes')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, MacMemory, Sound, fp
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesMemoire, UnitArbreDeJeuCourant, UnitAffichageArbreDeJeu
    , UnitEvaluation, UnitGameTree, UnitNotesSurCases, MyStrings, MyFileSystemUtils, UnitEvenement, UnitGestionDuTemps, UnitSet
    , UnitLiveUndo, UnitModes, UnitPositionEtTraitSet, UnitPileEtFile, UnitScannerUtils, MyMathUtils, SNEvents, UnitFichiersTEXT
    , UnitPositionEtTrait, UnitServicesDialogs, UnitProperties ;
{$ELSEC}
    ;
    {$I prelink/Zebra_to_Cassio.lk}
{$ENDC}


{END_USE_CLAUSE}




var ZebraBookOptions : SInt32;
    ZebraInfosRec : record
                      thePositionEtTrait : PositionEtTraitRec;
                      contempt           : SInt32;
                      maxCourantAffiche  : SInt32;
                      minCourantAffiche  : SInt32;
                    end;

const gZebraBookNameInitialised : boolean = false;
      kPositionNotInZebraBook = -1000;  { must be < -1 }
      kScoreOfDrawTreeWindowByJan = 400;  {les scores en dehors de [-4.00, 4+00] sont censés etre décisifs dans la bibli de Jan }


var  gLectureZebraBook : record
                           lectureEnCours                     : boolean;
                           bookNameInitialised                : boolean;
                           introuvable                        : boolean;
                           doitVerifierEvenements             : boolean;
                           nbreAppelsHasGotEvents             : SInt32;
                           dernierTickAppelGotEvent           : SInt32;
                           bookName                           : String255;
                           utiliserLectureALaVolee            : boolean;
                           accelerationDemandee               : boolean;
                         end;


const NB_BUCKETS_ZEBRA_NODES = 100;
      SIZE_OF_EACH_NODES_BUCKET = 2000;
      NB_NODES_IN_ZEBRA_CACHE = 5000;

      TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS = 100;


type Zebra_nodes_bucket = packed array[0..0] of ZebraBookNode;
     Zebra_nodes_bucket_ptr = ^Zebra_nodes_bucket;

var gZebraBookNodes : record
                        nombreAppelsGetZebraNode     : SInt32;
                        nombreAccesDisque            : SInt32;
                        timeStamp                    : SInt32;
                        niveauRecursionUseZebraNodes : SInt32;
                        dernierBucketUtilise         : SInt32;
                        nodes                        : array[1..NB_BUCKETS_ZEBRA_NODES] of
                                                         record
                                                            indexMin  : SInt32;
                                                            indexMax  : SInt32;
                                                            date      : SInt32;
                                                            table     : Zebra_nodes_bucket_ptr;
                                                         end;
                        theBook                      : FichierTEXT;
                        nbreEnregistrementsDansFic   : SInt32;
                        ficEstInitialise             : boolean;
                      end;

var gCacheDesPresents : record
                          table              : Zebra_nodes_bucket_ptr;
                          keys               : array[0..NB_NODES_IN_ZEBRA_CACHE+10] of SInt32;
                          presents           : IntegerSet;
                          spotsVides         : Pile;
                          verbosityLevel     : SInt32;
                          verificationLevel  : SInt32;
                          nombreErreurs      : SInt32;
                          magicCookie        : SInt32;
                        end;

    gEnsembleDesPositionsDejaVues  : PositionEtTraitSet;
    gZebraBookPrefetchingData : record
                                  lastMagicCookieSeen    : SInt32;
                                  tempsDuDernierPrefetch : SInt32;
                                  dateDuDernierPrefetch  : SInt32;
                                end;
    gMagicCookiePourDebugageZebraValuesDansCassio : SInt32;


    gListeDesPositionsAvecDesFilsVirtuels : array[1..TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS] of GameTree;


procedure InitUnitZebraBook;
var i : SInt32;
    ok : boolean;
begin
  SetZebraBookOptions(kUtiliserZebraBook +
                      kAfficherNotesZebraSurOthellier +
                      kAfficherCouleursZebraSurOthellier +
                      kAfficherNotesZebraDansArbre +
                      kAfficherCouleursZebraDansArbre);
  SetZebraBookEstIntrouvable(false);

  // on n'affichera pas les lignes de la bibli
  // si elles font 6.00 pions de moins que l'optimum
  SetZebraBookContemptWindowWidth(600);

  gDemandeAffichageZebraBook.enAttente := false;

  with gLectureZebraBook do
    begin
      lectureEnCours       := false;
      accelerationDemandee := false;
    end;

  SetCassioMustGetZebraNodesFromDisk(true);

  with gZebraBookNodes do
    begin
      nombreAppelsGetZebraNode     := 0;
      nombreAccesDisque            := 0;
      timeStamp                    := 0;
      niveauRecursionUseZebraNodes := 0;
      dernierBucketUtilise         := 0;
      for i := 1 to NB_BUCKETS_ZEBRA_NODES do
        begin
          nodes[i].indexMin  := -1;
          nodes[i].indexMax  := -1;
          nodes[i].date      := -1;
          nodes[i].table     := Zebra_nodes_bucket_ptr(AllocateMemoryPtr((SIZE_OF_EACH_NODES_BUCKET + 10) * SizeOf(ZebraBookNode)));
        end;
      ficEstInitialise             := false;
      nbreEnregistrementsDansFic   := -1;
    end;

  with gCacheDesPresents do
    begin
      for i := 0 to NB_NODES_IN_ZEBRA_CACHE+10 do
         keys[i]         := -1;

      presents           := MakeEmptyIntegerSet;
      table              := Zebra_nodes_bucket_ptr(AllocateMemoryPtr((NB_NODES_IN_ZEBRA_CACHE + 10) * SizeOf(ZebraBookNode)));
      spotsVides         := AllocatePile(NB_NODES_IN_ZEBRA_CACHE + 10, ok);
      verbosityLevel     := 0;
      verificationLevel  := 0;
      nombreErreurs      := 0;
      magicCookie        := 0;
    end;


  gEnsembleDesPositionsDejaVues  := MakeEmptyPositionEtTraitSet;

  gZebraBookPrefetchingData.lastMagicCookieSeen    := -1234;
  gZebraBookPrefetchingData.tempsDuDernierPrefetch := 0;
  gZebraBookPrefetchingData.dateDuDernierPrefetch  := 0;

  gMagicCookiePourDebugageZebraValuesDansCassio := 0;


  for i := 1 to TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS do
    gListeDesPositionsAvecDesFilsVirtuels[i] := NIL;

end;


procedure LibereMemoireUnitZebraBook;
var k : SInt32;
begin
  for k := 1 to NB_BUCKETS_ZEBRA_NODES do
    if gZebraBookNodes.nodes[k].table <> NIL then
      DisposeMemoryPtr(Ptr(gZebraBookNodes.nodes[k].table));

  with gCacheDesPresents do
    begin
      DisposeIntegerSet(presents);
      DisposePile(spotsVides);
      if table <> NIL then DisposeMemoryPtr(Ptr(table));
    end;

  DisposePositionEtTraitSet(gEnsembleDesPositionsDejaVues);
end;


procedure IncrementerMagicCookieOfZebraBook;
begin
  inc(gCacheDesPresents.magicCookie);
end;


function GetMagicCookieOfZebraBook : SInt32;
begin
  GetMagicCookieOfZebraBook := gCacheDesPresents.magicCookie;
end;


procedure NotifyThatThisGameTreeHasVirtualNodes(G : GameTree);
var k : SInt32;
begin
  for k := 1 to TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS do
    if (G = gListeDesPositionsAvecDesFilsVirtuels[k])
      then exit(NotifyThatThisGameTreeHasVirtualNodes); // already there !

  for k := 1 to TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS do
    if (gListeDesPositionsAvecDesFilsVirtuels[k] = NIL) then
      begin
        gListeDesPositionsAvecDesFilsVirtuels[k] := G;
        exit(NotifyThatThisGameTreeHasVirtualNodes);
      end;
end;

procedure ClearUselessVirtualZebraNodes;
var k : SInt32;
    G, current : GameTree;
begin
  current := GetCurrentNode;

  if (current = NIL) | Quitter then exit(ClearUselessVirtualZebraNodes);

  for k := 1 to TAILLE_LISTE_DES_POSITIONS_AVEC_FILS_VIRTUELS do
    begin
      G := gListeDesPositionsAvecDesFilsVirtuels[k];
      if (G <> NIL) & (G <> current) then
        begin
          gListeDesPositionsAvecDesFilsVirtuels[k] := NIL;
          DetruitLesFilsZebraBookInutilesDeCeNoeud(G);
        end;
    end;
end;



function GetZebraBookName : String255;
var nom : String255;
    theFic : FichierTEXT;
begin
  with gLectureZebraBook do
    begin
      if bookNameInitialised
        then
          GetZebraBookName := bookName
        else
          begin
            if FichierTexteDeCassioExiste('Zebra-book.data',theFic) = NoErr
              then nom := GetFullPathOfFSSpec(theFic.theFSSpec)
              else nom := 'Zebra-book.data';

            bookName            := nom;
            bookNameInitialised := true;

            GetZebraBookName := nom;
          end;
    end;
end;


function ReadZebraBookValuesFromDisc(const plat : plateauOthello; var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16; var Flags : SInt16; indexProbable : SInt32) : SInt32;
var pos : plOthLongint;
    i,j,t : SInt16;
    index,orientation : SInt32;
    ZebraBookPath : String255;
    node : ZebraBookNode;
begin

  {creer la position}
  for i := 0 to 100 do pos[i] := 0;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        t := i + j*10;
        case plat[t] of
          pionNoir  : pos[t] := 1;
          pionBlanc : pos[t] := 2;
          otherwise   pos[t] := 0;
        end; {case}
      end;

  {on fabrique une chaine au format C}
  ZebraBookPath := GetZebraBookName + chr(0);

  {chercher si la position est dans la bibliotheque de Zebra}
  index := trouver_position_in_zebra_book(@pos[0], node, @orientation, @ZebraBookPath[1], indexProbable);
  if (index < 0) then
    begin
      ReadZebraBookValuesFromDisc := index;  (* not found *)
      exit(ReadZebraBookValuesFromDisc);
    end;

  extraire_vals_from_zebra_book(index, node, @Score_Noir, @Score_Blanc, @Alt_Move, @Alt_Score, @Flags);
  if (Alt_Move > 0)  then
    Alt_Move := symetrise_coup_for_zebra_book(orientation, Alt_Move);

  ReadZebraBookValuesFromDisc := index;   (* found *)
end;


procedure WritelnZebraValuesDansRapport(var pos : PositionEtTraitRec);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16;
    Flags : SInt16;
    index : SInt32;
begin
  if CassioEstEnTrainDeLireLaBibliothequeDeZebra then
    exit(WritelnZebraValuesDansRapport);

  if (number_of_positions_in_zebra_book <= 0) then
    begin
      if not(ZebraBookEstIntrouvable) & not(CassioEstEnTrainDeLireLaBibliothequeDeZebra)
        then LoadZebraBook(true);
      exit(WritelnZebraValuesDansRapport);
    end;

  BeginUseZebraNodes('WritelnZebraValuesDansRapport');

  index := ReadZebraBookValuesFromDisc(pos.position,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags, -1);
  if (index >= 0) then
    begin

      WritelnPositionEtTraitDansRapport(pos.position,GetTraitOfPosition(pos));

      if (Flags AND FULL_SOLVED) <> 0
        then
          begin (* Finale parfaite *)
            if (Score_Noir = 0)
              then
                WritelnDansRapport(' Score : Nulle')
              else
               if (Score_Noir > CONFIRMED_WIN)
                 then
                   begin
                     if (Flags AND BLACK_TO_MOVE) <> 0
                       then WritelnNumDansRapport('  Gain pour Noir ' , Score_Noir - CONFIRMED_WIN)
                       else WritelnNumDansRapport('  Gain pour Noir ' , Score_Noir - CONFIRMED_WIN) ;
                   end
                 else
                   begin
                     if (Flags AND BLACK_TO_MOVE) <> 0
                       then WritelnNumDansRapport('  Gain pour Blanc ', -(Score_Noir + CONFIRMED_WIN))
                       else WritelnNumDansRapport('  Gain pour Blanc  ', -(Score_Noir + CONFIRMED_WIN)) ;
                   end
            end  (* Finale parfaite *)
        else
          if (Flags AND WLD_SOLVED) <> 0 then
            begin (* Finale WLD *)
              if (Score_Noir = 0)
                then
                  WritelnDansRapport('  Score : Nulle')
                else
                  begin
                    if (Score_Noir > CONFIRMED_WIN) then begin
                    if (Flags AND BLACK_TO_MOVE) <> 0 then
                      WritelnDansRapport('  Score : gain Noir')
                    else
                      WritelnDansRapport('  Score : perdant pour Blanc') ;
                  end else begin
                    if (Flags AND BLACK_TO_MOVE) <> 0 then
                      WritelnDansRapport('  Score : perdant pour Noir')
                    else
                      WritelnDansRapport('  Score : gain Blanc') ;
                  end
            end
            end (* Finale WLD *)
       else
        begin  (* Milieu de partie *)
            if (Score_Noir = NO_SCORE)
            then
            WritelnDansRapport('  Pas de score' )
            else
            if (Flags AND BLACK_TO_MOVE) <> 0
              then WritelnStringAndReelDansRapport('  Score pour noir  : ',  1.0*Score_Noir/128.0 , 4)
              else WritelnStringAndReelDansRapport('  Score pour blanc : ', -1.0*Score_Noir/128.0 , 4);

          if (Alt_Move < 0)
            then
            WritelnDansRapport('  Pas de deviation')
            else
              begin
                WriteStringAndCoupDansRapport('  Deviation : ', Alt_Move);
                if (Flags AND BLACK_TO_MOVE) <> 0
                then WritelnStringAndReelDansRapport(' score pour noir : ',  1.0*Alt_Score/128.0 , 4)
                else WritelnStringAndReelDansRapport(' score pour blanc : ',  -1.0*Alt_Score/128.0 , 4);
              end;
          end;  (* Milieu de partie *)

    end;

  EndUseZebraNodes('WritelnZebraValuesDansRapport');
end;


function EstUneEvaluationDansLeBookDeZebra(genreDeNote : SInt32) : boolean;
begin
  EstUneEvaluationDansLeBookDeZebra := (genreDeNote = ReflZebraBookEval) |
                                       (genreDeNote = ReflZebraBookEvalSansDouteGagnant) |
                                       (genreDeNote = ReflZebraBookEvalSansDoutePerdant);
end;


function RessembleAUneNoteDeFinale(note : SInt32) : boolean;
begin
  RessembleAUneNoteDeFinale := ((note mod 200) = 0);
end;




procedure ResetMinEtMaxValuationDeZebraAffichee;
begin
  ZebraInfosRec.maxCourantAffiche := -10000;
  ZebraInfosRec.minCourantAffiche :=  10000;
end;

function GetMaxValuationDeZebraAffichee : SInt32;
begin
  GetMaxValuationDeZebraAffichee := ZebraInfosRec.maxCourantAffiche;
end;

function GetMinValuationDeZebraAffichee : SInt32;
begin
  GetMinValuationDeZebraAffichee := ZebraInfosRec.minCourantAffiche;
end;

procedure UpdateMaxValuationDeZebraAffichee(squareValue, genreDeNote : SInt32);
begin
  if (squareValue >= -6400) & (squareValue <= 6400) then
    begin

      if EstUneEvaluationDansLeBookDeZebra(genreDeNote) & RessembleAUneNoteDeFinale(squareValue)
        then inc(squareValue);

      if squareValue > ZebraInfosRec.maxCourantAffiche
        then ZebraInfosRec.maxCourantAffiche := squareValue;

      {WritelnNumDansRapport('max = ',gMaxCourantAfficheDeZebraBook);}
    end;
end;

procedure UpdateMinValuationDeZebraAffichee(squareValue, genreDeNote : SInt32);
begin
  if (squareValue >= -6400) & (squareValue <= 6400) then
    begin

      if EstUneEvaluationDansLeBookDeZebra(genreDeNote) & RessembleAUneNoteDeFinale(squareValue)
        then inc(squareValue);

      if squareValue < ZebraInfosRec.minCourantAffiche
        then ZebraInfosRec.minCourantAffiche := squareValue;

      {WritelnNumDansRapport('min = ',gMaxCourantAfficheDeZebraBook);}
    end;
end;





procedure EffacerValeursDeZebraMiserablesSiNecessaire;
var valMin,valMax : SInt32;
    k,square,valeur : SInt32;
begin

  if ZebraBookACetteOption(kAfficherZebraBookBrutDeDecoffrage) then
    exit(EffacerValeursDeZebraMiserablesSiNecessaire);

  valMin := GetMinValuationDeZebraAffichee;
  valMax := GetMaxValuationDeZebraAffichee;

  if (valMin >= -6400) & (valMin <= 6400) & (valMax >= -6400) & (valMax <= 6400) then
    if (valMin < valMax - GetZebraBookContemptWindowWidth) & not(RessembleAUneNoteDeFinale(valMax)) then
      begin

        for k := 1 to 64 do
          begin
            square := othellier[k];
            valeur := GetNoteSurCase(kNotesDeZebra,square);

            if (valeur <> kNoteSurCaseNonDisponible) &
               (valeur >= valMin - 10) &
               (valeur < valMax - GetZebraBookContemptWindowWidth) then
              begin
                SetNoteSurCase(kNotesDeZebra, square, kNoteSurCaseNonDisponible);
                EffaceNoteSurCases(kNotesDeZebra, [square]);
              end;
          end;
      end;

end;


procedure AddSonAndZebraValueAtThisNode(whichNode : GameTree; fils : SInt32; pos : PositionEtTraitRec; scorePourNoir : SInt32; genreDeNote : SInt32);
var err : OSErr;
    pos2 : PositionEtTraitRec;
    isANewSon : boolean;
    oldCurrentNode : GameTree;
    scoreAffiche : SInt32;
    doitAfficherLaNote : boolean;
    homogeneite_error : SInt32;
label sortie;
begin

  if CassioEstEnTrainDeLireLaBibliothequeDeZebra then
    exit(AddSonAndZebraValueAtThisNode);


  (* validation des scores *)
  if ((genreDeNote = ReflParfait) | (genreDeNote = ReflGagnant)) then
    if (scorePourNoir > 64) | (scorePourNoir < -64) then
      begin
        (* WritelnNumDansRapport('WARNING ! note impossible dans la bibliothèque de Zebra :  scorePourNoir = ',scorePourNoir); *)
        exit(AddSonAndZebraValueAtThisNode);
      end;


  homogeneite_error := VerifieHomogeneiteDesCouleurs(whichNode, false);
  if (homogeneite_error <> 0) then exit(AddSonAndZebraValueAtThisNode);


  oldCurrentNode := GetCurrentNode;
  SetCurrentNode(whichNode, 'AddSonAndZebraValueAtThisNode {1}');
  pos2 := ZebraInfosRec.thePositionEtTrait;
  err := NoErr;


  isANewSon := false;


  {jouer eventuellement le coup dans l'arbre}
  if (fils > 0) then
    begin

      if not(EstUneEvaluationDansLeBookDeZebra(genreDeNote)) | ZebraBookACetteOption(kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre)
        then err := ChangeCurrentNodeAfterThisMove(fils,GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait),'AddSonAndZebraValueAtThisNode',isANewSon);

      if not(UpdatePositionEtTrait(pos2,fils)) then err := -1;
    end;


  {on vérifie encore une fois que la position dans l'arbre de jeu
  où on va ajouter de l'info correspond bien à la position trouvee
  dans la biblio de Zebra}
  if (err = NoErr) & not(SamePositionEtTrait(pos,pos2)) then
    begin
      {Sysbeep(0);
      WritelnDansRapport('Desynchronisation dans AddSonAndZebraValueAtThisNode !!');
      }
      {
      WritelnPositionEtTraitDansRapport(pos.position,GetTraitOfPosition(pos));
      WritelnPositionEtTraitDansRapport(pos2.position,GetTraitOfPosition(pos2));
      }
      err := -1;
    end;

  {Si la case correspondante n'est pas vide, il y a un probleme}
  if (err = NoErr) & (fils >= 11) & (fils <= 88) & (GetCouleurOfSquareDansJeuCourant(fils) <> pionVide) then
    begin
      Sysbeep(0);
      WritelnDansRapport('La case devrait etre vide dans AddSonAndZebraValueAtThisNode !!');
      err := -1;
    end;

  {ajouter l'info}
  if (err = NoErr) then
    begin

      if isANewSon then
        begin
          (* WritelnDansRapport('virtual : '+ CoupEnStringEnMajuscules(fils)); *)
          MarquerCurrentNodeCommeVirtuel;
        end;
      {
      WritelnNumDansRapport('scorePourNoir = ',scorePourNoir);
      WritelnNumDansRapport('genreDeNote = ',genreDeNote);
      }


      if not(EstUneEvaluationDansLeBookDeZebra(genreDeNote)) | ZebraBookACetteOption(kAfficherNotesZebraDansArbre + kAfficherCouleursZebraDansArbre)
        then AjoutePropertyValeurDeCoupDansCurrentNode(genreDeNote,scorePourNoir);


      SetCurrentNode(whichNode, 'AddSonAndZebraValueAtThisNode {2}');


      if EstUneEvaluationDansLeBookDeZebra(genreDeNote) then
        begin

          if GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir
            then scoreAffiche :=  scorePourNoir
            else scoreAffiche := -scorePourNoir;

          UpdateMaxValuationDeZebraAffichee(scoreAffiche, genreDeNote);

          doitAfficherLaNote := (scoreAffiche >= -200) |
                                (scoreAffiche >= GetMaxValuationDeZebraAffichee - GetZebraBookContemptWindowWidth) |
                                ZebraBookACetteOption(kAfficherZebraBookBrutDeDecoffrage) |
                                RessembleAUneNoteDeFinale(GetMaxValuationDeZebraAffichee) |
                                (nbreCoup >= 31);

          if doitAfficherLaNote
            then
              begin

                UpdateMinValuationDeZebraAffichee(scoreAffiche, genreDeNote);

                if (genreDeNote = ReflZebraBookEvalSansDouteGagnant) | (genreDeNote = ReflZebraBookEvalSansDoutePerdant)
                  then AjouterFlagsNoteSurCase(kNotesDeZebra,fils,kFlagPositionEstSansDouteNonNulleSelonBiblZebra)
                  else RetirerFlagsNoteSurCase(kNotesDeZebra,fils,kFlagPositionEstSansDouteNonNulleSelonBiblZebra);

                SetNoteMilieuSurCase(kNotesDeZebra, fils, scoreAffiche);

                EffacerValeursDeZebraMiserablesSiNecessaire;

              end
            else
              begin
                if (GetNoteSurCase(kNotesDeZebra,fils) <> kNoteSurCaseNonDisponible) then
                  begin
                    SetNoteSurCase(kNotesDeZebra, fils, kNoteSurCaseNonDisponible);
                    EffaceNoteSurCases(kNotesDeZebra, [fils]);
                  end;
              end;

        end
      else if (genreDeNote = ReflGagnant) then
        begin
          if (GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir)
            then
              begin
                if (scorePourNoir > 0) then scoreAffiche :=  200  else  {+2}
                if (scorePourNoir = 0) then scoreAffiche :=    0  else  {0}
                if (scorePourNoir < 0) then scoreAffiche := -200;       {-2}

                if (scorePourNoir > 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourGain) else
                if (scorePourNoir = 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourNulle) else
                if (scorePourNoir < 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourPerte);

                UpdateMaxValuationDeZebraAffichee(scoreAffiche, ReflGagnant);
              end
            else
              begin
                if (scorePourNoir < 0) then scoreAffiche :=  200  else  {+2}
                if (scorePourNoir = 0) then scoreAffiche :=    0  else  {0}
                if (scorePourNoir > 0) then scoreAffiche := -200;       {-2}

                if (scorePourNoir < 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourGain) else
                if (scorePourNoir = 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourNulle) else
                if (scorePourNoir > 0) then SetNoteSurCase(kNotesDeZebra, fils, kNoteSpecialeSurCasePourPerte);

                UpdateMaxValuationDeZebraAffichee(scoreAffiche, ReflGagnant);
              end
        end
      else if (genreDeNote = ReflParfait) then
        begin

          if (GetTraitOfPosition(ZebraInfosRec.thePositionEtTrait) = pionNoir)
            then scoreAffiche :=  100*scorePourNoir
            else scoreAffiche := -100*scorePourNoir;

          UpdateMaxValuationDeZebraAffichee(scoreAffiche, ReflParfait);

          SetNoteSurCase(kNotesDeZebra, fils, scoreAffiche);
        end;
    end;

  SetCurrentNode(oldCurrentNode, 'AddSonAndZebraValueAtThisNode {3}');


sortie :



end;



function EvaluationHeuristiquePourAffichageBiblZebra(var whichPos : PositionEtTraitRec; valeurMilieuDeZebra : SInt32; var genreDeNote : SInt32) : SInt32;
var valeurHeuristique : SInt32;
    bestDef : SInt32;
begin

  // par defaut on affichera le score de deviation stocké dans la bibli
  valeurHeuristique := valeurMilieuDeZebra;
  genreDeNote       := ReflZebraBookEval;

  // mais s'il est vraiment trop débile...

  (*
  if ZebraBookACetteOption(kAfficherZebraBookBrutDeDecoffrage)
    then WritelnDansRapport('brut de decoffrage = true')
    else WritelnDansRapport('brut de decoffrage = false');
  *)


  if not(ZebraBookACetteOption(kAfficherZebraBookBrutDeDecoffrage)) then
    if (valeurMilieuDeZebra >= kScoreOfDrawTreeWindowByJan) | (valeurMilieuDeZebra <= -kScoreOfDrawTreeWindowByJan) then
      begin

        genreDeNote := ReflZebraBookEvalSansDouteGagnant;

        // calculer une meilleure estimation avec l'eval d'Edmond

        if ((GetTraitOfPosition(whichPos) = pionNoir) & (valeurMilieuDeZebra > 0))
           | ((GetTraitOfPosition(whichPos) = pionBlanc) & (valeurMilieuDeZebra < 0))

          then valeurHeuristique := EvaluationHorsContexteACetteProfondeur(whichPos, 3, bestDef, false) - 100
          else valeurHeuristique := EvaluationHorsContexteACetteProfondeur(whichPos, 3, bestDef, false) + 100;

        // normaliser la note pour la présenter pour les Noirs
        if GetTraitOfPosition(whichPos) = pionBlanc
          then valeurHeuristique := -valeurHeuristique;

        // ne pas changer de signe, quand meme !
        if (valeurMilieuDeZebra >= kScoreOfDrawTreeWindowByJan) & (valeurHeuristique < 200)
          then valeurHeuristique := 200;

        // idem !
        if (valeurMilieuDeZebra <= -kScoreOfDrawTreeWindowByJan) & (valeurHeuristique > -200)
          then valeurHeuristique := -200;

        // ne pas dépasser l'eval de Zebra, quand meme
        if (valeurMilieuDeZebra >= kScoreOfDrawTreeWindowByJan) & (valeurHeuristique > valeurMilieuDeZebra)
          then valeurHeuristique := valeurMilieuDeZebra;

        // idem !
        if (valeurMilieuDeZebra <= -kScoreOfDrawTreeWindowByJan) & (valeurHeuristique < valeurMilieuDeZebra)
          then valeurHeuristique := valeurMilieuDeZebra;

    end;

  EvaluationHeuristiquePourAffichageBiblZebra := valeurHeuristique;

end;



procedure TrierLesFilsSelonLesNotesDeLaBibliothequeDeZebra(G : GameTree);
var changed : boolean;
begin
  TrierLesFilsDeCeNoeud(G, kTriSelonValeursZebra, changed);
end;


procedure AddAllZebraValuesAtThisNode(whichNode : GameTree; fils : SInt32; var pos : PositionEtTraitRec; niveauRecursion : SInt32);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16;
    Flags : SInt16;
    i,square : SInt32;
    pos2 : PositionEtTraitRec;
    index : SInt32;
    indexProbable : SInt32;
    oldMagicCookieZebraBook : SInt32;
    bidBool : SInt32;
    valeurMilieuDeZebra : SInt32;
    valeurHeuristique : SInt32;
    genreDeNote : SInt32;
    nbreDeFils : SInt32;
    liste : ListOfMoveRecords;
label sortie;
begin

  oldMagicCookieZebraBook := GetMagicCookieOfZebraBook;


  if CassioEstEnTrainDeLireLaBibliothequeDeZebra then
    exit(AddAllZebraValuesAtThisNode);

  if (number_of_positions_in_zebra_book <= 0) then
    begin
      if not(ZebraBookEstIntrouvable) & not(CassioEstEnTrainDeLireLaBibliothequeDeZebra)
        then LoadZebraBook(true);
      exit(AddAllZebraValuesAtThisNode);
    end;


  (* On essaie de mettre tous les fils connus *)
  if (niveauRecursion > 0) then
    begin
      ResetMinEtMaxValuationDeZebraAffichee;

      nbreDeFils := GetListeTrieeDesCoupsACetteProfondeurHorsContexte(pos, 4, liste, false);

      pos2 := pos;
      for i := 1 to nbreDeFils do
        begin
          square := liste[i].x ;

          if UpdatePositionEtTrait(pos2, square) then
            begin
              if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;
              bidBool := lecture_zebra_book_interrompue_par_evenement;
              if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;

              AddAllZebraValuesAtThisNode(whichNode, square, pos2, niveauRecursion - 1 );
              pos2 := pos;
            end;
        end;

      if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;
      bidBool := lecture_zebra_book_interrompue_par_evenement;
      if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;

    end;

  if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;
  bidBool := lecture_zebra_book_interrompue_par_evenement;
  if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;


  indexProbable := -1;
  if MemberOfPositionEtTraitSet(pos,indexProbable,gEnsembleDesPositionsDejaVues) then
    begin

      (*   kPositionNotInZebraBook = -1000 = not found                            *)
      (*   Si l'index proposé pour aider vaut -1000, cela signifie                *)
      (*   que l'on a déjà cherché la position dans la bibliotheque               *)
      (*   de Zebra, et qu'on a déja prouvé qu'elle n'y est pas !                 *)

      if (indexProbable = kPositionNotInZebraBook)
        then exit(AddAllZebraValuesAtThisNode);
    end;

  index := ReadZebraBookValuesFromDisc(pos.position,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags,indexProbable);

  if (index >= 0)
    then
      begin  (* found *)


        (* si c'est la premiere fois que l'on voit cette position, stocker l'index pour
           pouvoir retrouver la position plus vite la prochaine fois.                    *)

        if (indexProbable = -1) then
           AddPositionEtTraitToSet(pos,index,gEnsembleDesPositionsDejaVues);


        (* extraction des valeurs de Zebra *)

        if (Flags AND FULL_SOLVED) <> 0
          then
            begin (* Finale parfaite *)
              if (Score_Noir = 0) | (Score_Noir = UNWANTED_DRAW)
                then
                  AddSonAndZebraValueAtThisNode(whichNode, fils, pos, 0, ReflParfait)    {nulle}
                else
                 if (Score_Noir > CONFIRMED_WIN)
                   then AddSonAndZebraValueAtThisNode(whichNode, fils, pos,   Score_Noir - CONFIRMED_WIN  , ReflParfait)  {gagne pour Noir}
                   else AddSonAndZebraValueAtThisNode(whichNode, fils, pos,   Score_Noir + CONFIRMED_WIN  , ReflParfait); {gagne pour Blanc}
            end  (* Finale parfaite *)
          else
            if (Flags AND WLD_SOLVED) <> 0 then
              begin (* Finale WLD *)
                if (Score_Noir = 0) | (Score_Noir = UNWANTED_DRAW)
                  then
                    AddSonAndZebraValueAtThisNode(whichNode, fils, pos, 0, ReflParfait)    {nulle}
                  else
                    begin
                      if (Score_Noir > CONFIRMED_WIN)
                        then AddSonAndZebraValueAtThisNode(whichNode, fils, pos, +1 ,ReflGagnant)       {gagne pour Noir}
                        else AddSonAndZebraValueAtThisNode(whichNode, fils, pos, -1 ,ReflGagnant);      {gagne pour Blanc}
                    end
              end (* Finale WLD *)
          else
            begin  (* Milieu de partie *)
              if (Score_Noir = NO_SCORE)
                then
                  {WritelnDansRapport('  Pas de score' )}
                else
                  begin
                    valeurMilieuDeZebra := MyTrunc(0.4999 + 100.0*Score_Noir/128.0);
                    valeurHeuristique   := EvaluationHeuristiquePourAffichageBiblZebra(pos,valeurMilieuDeZebra,genreDeNote);
                    AddSonAndZebraValueAtThisNode(whichNode, fils, pos, valeurHeuristique , genreDeNote);
                  end;

              if (niveauRecursion > 0) & (VerifieHomogeneiteDesCouleurs(whichNode, false) = NoErr) then
                begin
                  if (Alt_Move < 0)
                    then
                      {WritelnDansRapport('  Pas de deviation') }
                    else
                      begin
                        {WriteStringAndCoupDansRapport('  Deviation : ', Alt_Move);}
                        pos2 := pos;
                        if UpdatePositionEtTrait(pos2,Alt_Move) then
                          begin
                            valeurMilieuDeZebra := MyTrunc(0.4999 + 100.0*Alt_Score/128.0);
                            valeurHeuristique   := EvaluationHeuristiquePourAffichageBiblZebra(pos2,valeurMilieuDeZebra,genreDeNote);
                            AddSonAndZebraValueAtThisNode(whichNode, Alt_Move, pos2, valeurHeuristique , genreDeNote);
                          end;
                      end;
                end;
            end;  (* Milieu de partie *)
      end
    else
      begin  (* kPositionNotInZebraBook = not found = -1000 *)
        if (GetMagicCookieOfZebraBook = oldMagicCookieZebraBook)
          then AddPositionEtTraitToSet(pos,kPositionNotInZebraBook,gEnsembleDesPositionsDejaVues)
          else Sysbeep(0);
      end;

  if (niveauRecursion > 0) then
    begin
      if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;
      bidBool := lecture_zebra_book_interrompue_par_evenement;
      if GetMagicCookieOfZebraBook <> oldMagicCookieZebraBook then goto sortie;

      TrierLesFilsSelonLesNotesDeLaBibliothequeDeZebra(whichNode);
    end;

  exit(AddAllZebraValuesAtThisNode);

sortie :

  (* WritelnDansRapport('sortie par interuption de AddAllZebraValuesAtThisNode'); *)

end;





procedure LanceDemandeAffichageZebraBook(const fonctionAppelante : String255);
var index : SInt32;
    position : PositionEtTraitRec;
begin
  Discard(fonctionAppelante);
  // WritelnDansRapport('entree dans LanceDemandeAffichageZebraBook, fonctionAppelante = ' + fonctionAppelante);

  IncrementerMagicCookieOfZebraBook;

  position := PositionEtTraitCourant;

  if MemberOfPositionEtTraitSet(position,index,gEnsembleDesPositionsDejaVues) & (index >= 0)
     & not(LiveUndoVaRejouerImmediatementUnAutreCoup)
    then
      begin
        gDemandeAffichageZebraBook.enAttente := false;
        LireBibliothequeDeZebraPourCurrentNode('LanceDemandeAffichageZebraBook');  (* instantané *)
      end
    else gDemandeAffichageZebraBook.enAttente := true;    (* Ca risque d'etre plus long : on remet l'affichage à plus tard *)
end;


procedure TraiteDemandeAffichageZebraBook;
begin
  {WritelnDansRapport('entree dans TraiteDemandeAffichageZebraBook');}
  if not(LiveUndoVaRejouerImmediatementUnAutreCoup) then
    begin
      gDemandeAffichageZebraBook.enAttente := false;
      LireBibliothequeDeZebraPourCurrentNode('TraiteDemandeAffichageZebraBook');
    end;
end;


procedure LireBibliothequeDeZebraPourCurrentNode(const fonctionAppelante : String255);
var positionArrivee : PositionEtTraitRec;
    ticks : SInt32;
    nombreAppelsGetZebraNodeArrivee : SInt32;
    nombreAccesDisqueArrivee : SInt32;
    nbreAppelsHasGotEventsArrivee : SInt32;
    oldMagicCookie : SInt32;
    accelerationArrive, bidbool : boolean;
    whichNode : GameTree;
begin
  Discard(fonctionAppelante);
  
  (*
  WritelnDansRapport('Entree dans LireBibliothequeDeZebraPourCurrentNode, fonction appelante = ' + fonctionAppelante);
  
  WritelnNumDansRapport('ZebraBookOptions = ',ZebraBookOptions);
  WritelnStringAndBoolDansRapport('ZebraBookACetteOption(kUtiliserZebraBook) = ',ZebraBookACetteOption(kUtiliserZebraBook));
  WritelnStringAndBoolDansRapport('ZebraBookACetteOption(kAllZebraOptions - kUtiliserZebraBook) = ',ZebraBookACetteOption(kAllZebraOptions - kUtiliserZebraBook));
  WritelnStringAndBoolDansRapport('CassioEstEnModeSolitaire = ',CassioEstEnModeSolitaire);
  WritelnStringAndBoolDansRapport('CassioEstEnTrainDeLireLaBibliothequeDeZebra = ',CassioEstEnTrainDeLireLaBibliothequeDeZebra);
  *)

  if ZebraBookACetteOption(kUtiliserZebraBook) &
     ZebraBookACetteOption(kAllZebraOptions - kUtiliserZebraBook) &
     not(CassioEstEnModeSolitaire) &
     not(CassioEstEnTrainDeLireLaBibliothequeDeZebra) &
     (nbreCoup <= 40) then

    with ZebraInfosRec do
      begin
        
        {WritelnDansRapport('dans le corps de LireBibliothequeDeZebraPourCurrentNode au coup ' + NumEnString(nbreCoup) + ', fonction appelante = ' + fonctionAppelante);}


        IncrementerMagicCookieOfZebraBook;
        oldMagicCookie := GetMagicCookieOfZebraBook;

        { WritelnNumDansRapport('magic = ',GetMagicCookieOfZebraBook); }


        BeginUseZebraNodes('LireBibliothequeDeZebraPourCurrentNode');
        SetZebraBookDemandeAccelerationDesEvenements(true,accelerationArrive);

        nombreAppelsGetZebraNodeArrivee := gZebraBookNodes.nombreAppelsGetZebraNode;
        nombreAccesDisqueArrivee        := gZebraBookNodes.nombreAccesDisque;
        nbreAppelsHasGotEventsArrivee   := gLectureZebraBook.nbreAppelsHasGotEvents;
        ticks := TickCount;

        (* les scores de Zebra sur l'othellier *)
        positionArrivee := PositionEtTraitCourant;
        whichNode       := GetCurrentNode;


        // WritelnNumDansRapport('dans LireBibliothequeDeZebraPourCurrentNode, nbreCoup = ',nbreCoup);
        // WriteGameTreeDansRapport(whichNode);

        if (nbreCoup > 0) & GetPositionEtTraitACeNoeud(whichNode, thePositionEtTrait, 'LireBibliothequeDeZebraPourCurrentNode') then
          begin

            gLectureZebraBook.doitVerifierEvenements := true;

            AddAllZebraValuesAtThisNode(whichNode,NO_MOVE,thePositionEtTrait,1);

            if EstLaPositionCourante(positionArrivee) & (oldMagicCookie = GetMagicCookieOfZebraBook)
              then
                begin

                  if EstVisibleDansFenetreArbreDeJeu(whichNode) then
                    begin
                      EffaceNoeudDansFenetreArbreDeJeu;
                      EcritCurrentNodeDansFenetreArbreDeJeu(true,true);
                      NotifyThatThisGameTreeHasVirtualNodes(whichNode);
                    end;
                end
              else
                begin
                  {sysbeep(0);}
                  {WritelnDansRapport('WARNING dans LireBibliothequeDeZebraPourCurrentNode : la position a sans doute changé !!!!!!!');}
                end;
          end;

        if (gCacheDesPresents.verbosityLevel >= 1) then
          begin
            WriteNumDansRapport('GetZebraNodes/CachesMisses/∆GZM/∆CM/vus/presents/events/∆events = ',gZebraBookNodes.nombreAppelsGetZebraNode);
            WriteNumDansRapport('/',gZebraBookNodes.nombreAccesDisque);
            WriteNumDansRapport('/',gZebraBookNodes.nombreAppelsGetZebraNode-nombreAppelsGetZebraNodeArrivee);
            WriteNumDansRapport('/',gZebraBookNodes.nombreAccesDisque-nombreAccesDisqueArrivee);
            WriteNumDansRapport('/',gEnsembleDesPositionsDejaVues.cardinal);
            WriteNumDansRapport('/',gCacheDesPresents.presents.cardinal);
            WriteNumDansRapport('/',gLectureZebraBook.nbreAppelsHasGotEvents);
            WriteNumDansRapport('/',gLectureZebraBook.nbreAppelsHasGotEvents-nbreAppelsHasGotEventsArrivee);
            WritelnNumDansRapport(',   temps = ',TickCount - ticks);
          end;

        SetZebraBookDemandeAccelerationDesEvenements(accelerationArrive,bidbool);
        EndUseZebraNodes('LireBibliothequeDeZebraPourCurrentNode');

      end;
end;


function GetZebraBookOptions : SInt32;
begin
  GetZebraBookOptions := ZebraBookOptions;
end;


procedure SetZebraBookOptions(options : SInt32);
begin
  ZebraBookOptions := options;
end;


function ZebraBookACetteOption(mask : SInt32) : boolean;
begin
  ZebraBookACetteOption := ((ZebraBookOptions AND mask) <> 0)
end;


procedure AjouterZebraBookOption(mask : SInt32);
begin
  SetZebraBookOptions(GetZebraBookOptions OR mask);
end;


procedure RetirerZebraBookOption(mask : SInt32);
begin
  SetZebraBookOptions(GetZebraBookOptions AND (kAllZebraOptions - mask));
end;


procedure ToggleZebraOption(mask : SInt32);
begin
  if ZebraBookACetteOption(mask)
    then RetirerZebraBookOption(mask)
    else AjouterZebraBookOption(mask);
end;


procedure SetUsingZebraBook(flag : boolean);
begin
  if flag
    then AjouterZebraBookOption(kUtiliserZebraBook)
    else RetirerZebraBookOption(kUtiliserZebraBook);
end;


function GetUsingZebraBook : boolean;
begin
  GetUsingZebraBook := ZebraBookACetteOption(kUtiliserZebraBook);
end;


function ZebraBookEstIntrouvable : boolean;
begin
  ZebraBookEstIntrouvable := gLectureZebraBook.introuvable;
end;



procedure SetZebraBookEstIntrouvable(flag : boolean);
begin
  gLectureZebraBook.introuvable := flag;
end;


procedure LoadZebraBook(withCheckEvents : boolean);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16;
    Flags : SInt16;
    memoire : SInt32;
    ticks : SInt32;
    bidon : SInt32;
    s : String255;
begin  {$unused s}
  with gLectureZebraBook do
    if not(CassioEstEnTrainDeLireLaBibliothequeDeZebra) then
      begin
        if (cassio_must_get_zebra_nodes_from_disk > 0)
          then
            begin

               (* lecture directe du fichier a chaque coup
                => pas besoin de le precharger en memoire,
                   il suffit de l'initialiser.              *)

              if not(gZebraBookNodes.ficEstInitialise) then
                gZebraBookNodes.nbreEnregistrementsDansFic := get_number_of_positions_in_zebra_book_from_disk;

            end
          else
            begin

                (* on veut avoir toute la bibliotheque de Zebra en memoire
                => il faut la precharger (attention, 111 Mo quand meme !)  *)

              if not(CassioEstEnTrainDeLireLaBibliothequeDeZebra) then
                begin
                  lectureEnCours := true;


                  ticks := TickCount;

                  {on compacte la memoire}
                  if not(gIsRunningUnderMacOSX) then memoire := FreeMem;


                  nbreAppelsHasGotEvents := 0;
                  dernierTickAppelGotEvent := 0;


                  {et on force le chargement de la bibliotheque de Zebra en memoire}

                  doitVerifierEvenements := withCheckEvents;
                  BeginUseZebraNodes('LoadZebraBook');

                  bidon := ReadZebraBookValuesFromDisc(JeuCourant,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags, -1);

                  EndUseZebraNodes('LoadZebraBook');
                  doitVerifierEvenements := false;



                  if (number_of_positions_in_zebra_book <= 0) & not(withCheckEvents) then
                    SetZebraBookEstIntrouvable(true);


                  if ((TickCount - ticks) > 1) then
                    begin
                      (*
                      s := ParamStr(ReadStringFromRessource(TextesDiversID,12),NumEnString(number_of_positions_in_zebra_book),'','','');  {s := 'Nb de positions dans la bibliothèque de Zebra : ^0'}
                      WritelnDansRapport(s);
                      WritelnNumDansRapport('temps en ticks pour lire la bibl de Zebra = ',TickCount - ticks);
                      WritelnDansRapport('');
                      WritelnNumDansRapport('nbreAppelsHasGotEvents = ',nbreAppelsHasGotEvents)
                      *)
                    end;


                  lectureEnCours := false;
                end;
            end;
      end; {with gLectureZebraBook do}
end;






function lecture_zebra_book_interrompue_par_evenement : SInt32;
var theTick : SInt32;
    tempoCassioCheckEvent : boolean;
    gotEvent : boolean;
begin
  lecture_zebra_book_interrompue_par_evenement := 0;

  (*
  if gLectureZebraBook.doitVerifierEvenements
    then WritelnDansRapport('dans lecture_zebra_book_interrompue_par_evenement, doitVerifierEvenements = true')
    else WritelnDansRapport('dans lecture_zebra_book_interrompue_par_evenement, doitVerifierEvenements = false');
  *)

  with gLectureZebraBook do
    if doitVerifierEvenements then
      begin

        theTick := TickCount;
        if theTick <> dernierTickAppelGotEvent then
          begin

            inc(nbreAppelsHasGotEvents);
            dernierTickAppelGotEvent := theTick;

            (*
            if CassioCanCheckForDangerousEvents
              then WritelnDansRapport('CassioCanCheckForDangerousEvents = true')
              else WritelnDansRapport('CassioCanCheckForDangerousEvents = false');
            *)

            tempoCassioCheckEvent := gCassioChecksEvents;
            gCassioChecksEvents := true;

            gotEvent := false;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
            if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true; end; end; end; end; end; end; end; end;

            GererLiveUndo;

            if gotEvent then
              begin
                AccelereProchainDoSystemTask(2);
                dernierTickAppelGotEvent := dernierTickAppelGotEvent - 100;
              end;


            if Quitter
              then lecture_zebra_book_interrompue_par_evenement := 1;

            gCassioChecksEvents := tempoCassioCheckEvent;

          end;
      end;
end;


function CassioEstEnTrainDeLireLaBibliothequeDeZebra : boolean;
begin
  CassioEstEnTrainDeLireLaBibliothequeDeZebra := gLectureZebraBook.lectureEnCours;
end;


function ZebraBookDemandeAccelerationDesEvenements : boolean;
begin
  ZebraBookDemandeAccelerationDesEvenements := gLectureZebraBook.accelerationDemandee;
end;


procedure SetZebraBookDemandeAccelerationDesEvenements(newValue : boolean; var oldValue : boolean);
begin
  with gLectureZebraBook do
    begin
      oldValue := accelerationDemandee;
      accelerationDemandee := newValue;
    end;
end;


function BibliothequeDeZebraEstAfficheeSurOthellier : boolean;
begin
  BibliothequeDeZebraEstAfficheeSurOthellier := AuMoinsUneNoteSurCasesEstAffichee(kNotesDeZebra);
end;


procedure SetZebraBookContemptWindowWidth(whichContempt : SInt32);
begin
  ZebraInfosRec.contempt := whichContempt;
end;


function GetZebraBookContemptWindowWidth : SInt32;
begin
  GetZebraBookContemptWindowWidth := ZebraInfosRec.contempt;
end;


function cassio_must_get_zebra_nodes_from_disk : SInt32;
begin
  if gLectureZebraBook.utiliserLectureALaVolee
    then cassio_must_get_zebra_nodes_from_disk := 1
    else cassio_must_get_zebra_nodes_from_disk := 0;
end;


procedure SetCassioMustGetZebraNodesFromDisk(flag : boolean);
begin
  gLectureZebraBook.utiliserLectureALaVolee := flag;
end;


function get_number_of_positions_in_zebra_book_from_disk : SInt32;
var err : OSErr;
    bidlong : SInt32;
begin
  with gZebraBookNodes do
    begin
      if ficEstInitialise
        then
          get_number_of_positions_in_zebra_book_from_disk := nbreEnregistrementsDansFic
        else
          begin

            err := FichierTexteDeCassioExiste(GetZebraBookName,theBook);

            if err = NoErr
              then
                begin
                  SetZebraBookEstIntrouvable(false);

                  err := OuvreFichierTexte(theBook);
                  err := SetPositionTeteLectureFichierTexte(theBook, 0);
                  err := ReadLongintDansFichierTexte(theBook,bidlong);
                  err := ReadLongintDansFichierTexte(theBook,nbreEnregistrementsDansFic);
                  err := FermeFichierTexte(theBook);


                  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
                  MY_SWAP_LONGINT( @nbreEnregistrementsDansFic);
                  {$ENDC}

                end
              else
                begin
                  SetZebraBookEstIntrouvable(true);
                  nbreEnregistrementsDansFic := 0;
                end;

            prepare_zebra_hash ;

            ficEstInitialise := true;

            get_number_of_positions_in_zebra_book_from_disk := nbreEnregistrementsDansFic;
          end;
    end;
end;



procedure BeginUseZebraNodes(fonctionAppelante : String255);
begin  {$unused fonctionAppelante}
  with gZebraBookNodes do
    begin
      inc(niveauRecursionUseZebraNodes);

      { WritelnStringDansRapport('--> BeginUseZebraNodes :  fonction appelante = '+fonctionAppelante);
        WritelnNumDansRapport('      niveauRecursionUseZebraNodes = ',niveauRecursionUseZebraNodes);
      }

      if (niveauRecursionUseZebraNodes = 1) & not(ficEstInitialise)
        then nbreEnregistrementsDansFic := get_number_of_positions_in_zebra_book_from_disk;

    end;
end;


procedure EndUseZebraNodes(fonctionAppelante : String255);
var err : OSErr;
begin  {$unused fonctionAppelante}
  with gZebraBookNodes do
    begin

      {  WritelnStringDansRapport('--> EndUseZebraNodes :  fonction appelante = '+fonctionAppelante);
         WritelnNumDansRapport('      niveauRecursionUseZebraNodes = ',niveauRecursionUseZebraNodes);
      }

      if (niveauRecursionUseZebraNodes = 1) & FichierTexteEstOuvert(theBook) then
         begin
           err := FermeFichierTexte(theBook);
           {WritelnNumDansRapport('      apres FermeFichierTexte  ,  err = ', err);}
         end;

      dec(niveauRecursionUseZebraNodes);
    end;
end;



procedure writeln_zebra_node_dans_rapport(index : SInt32; var node : ZebraBookNode);
var i : SInt32;
begin
  WritelnNumDansRapport('Zebra node : ',index);
  for i := 0 to 17 do
    WritelnNumDansRapport('',node[i]);
end;


function LireBucketOfZebraNodes(numeroBucket, indexMin, indexMax : SInt32) : OSErr;
const kTailleHeaderZebraBook = 8;
var taille, count, k : SInt32;
    positionTeteLecture : SInt32;
    err : OSErr;
begin

  Discard(k);

  with gZebraBookNodes do
    begin

      inc(nombreAccesDisque);
      inc(timeStamp);
      dernierBucketUtilise := numeroBucket;

      taille := (indexMax - indexMin + 1) * SizeOf(ZebraBookNode);


      // open the file, if necessary

      if (niveauRecursionUseZebraNodes >= 1) & not(FichierTexteEstOuvert(theBook)) then
        begin
          err := OuvreFichierTexte(theBook);
          {WritelnNumDansRapport('LireBucketOfZebraNodes : apres OuvreFichierTexte,   err = ', err); }
        end;

      // set the file pointer

      positionTeteLecture := kTailleHeaderZebraBook + indexMin*SizeOf(ZebraBookNode);

      if (gCacheDesPresents.verbosityLevel >= 3) then
        begin

          WritelnNumDansRapport('LireBucketOfZebraNodes : indexMin = ',indexMin);
          WritelnNumDansRapport('LireBucketOfZebraNodes : indexMax = ',indexMax);
          WritelnNumDansRapport('LireBucketOfZebraNodes : taille = ',taille);
          WritelnNumDansRapport('LireBucketOfZebraNodes : positionTeteLecture = ',positionTeteLecture);
        end;

      err := SetPositionTeteLectureFichierTexte(theBook,positionTeteLecture);

      if (err <> NoErr) then
        WritelnDansRapport('ERROR dans LireBucketOfZebraNodes (SetPositionTeteLectureFichierTexte) : (err <> NoErr)');

      // read file

      count := taille;
      err := ReadBufferDansFichierTexte(theBook,@nodes[numeroBucket].table^[0],count);


      if (err <> NoErr) | (count <> taille) then
        WritelnDansRapport('ERROR dans LireBucketOfZebraNodes (ReadBufferDansFichierTexte) : (err <> NoErr) | (count <> taille)');


      {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
      for k := 0 to (indexMax - indexMin) do
        swap_endianess_of_zebra_node(nodes[numeroBucket].table^[k]);
      {$ENDC}



      nodes[numeroBucket].indexMin  := indexMin;
      nodes[numeroBucket].indexMax  := indexMax;
      nodes[numeroBucket].date      := timeStamp;

      if (gCacheDesPresents.verbosityLevel >= 3) then
        begin
          WritelnNumDansRapport('LireBucketOfZebraNodes :    ==>  count = ',count);
          WritelnNumDansRapport('LireBucketOfZebraNodes : bucket numero ',numeroBucket);
          WritelnNumDansRapport('    indexMin = ',nodes[numeroBucket].indexMin);
          WritelnNumDansRapport('    indexMax = ',nodes[numeroBucket].indexMax);
          WritelnNumDansRapport('    date     = ',nodes[numeroBucket].date);
        end;

    end;

  LireBucketOfZebraNodes := NoErr;
end;


procedure swap_endianess_of_zebra_node( var node : ZebraBookNode);
 {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
type ZebraBookNodeRecordPtr = ^ZebraBookNodeRecord;
var rec : ZebraBookNodeRecordPtr;
begin


  (*
  rec := ZebraBookNodeRecordPtr(@node);
  with rec^ do
    begin
      MY_SWAP_LONGINT( @hash1);
      MY_SWAP_LONGINT( @hash2);
      MY_SWAP_INTEGER( @black_minimax_score);
      MY_SWAP_INTEGER( @white_minimax_score);
      MY_SWAP_INTEGER( @best_alternative_move);
      MY_SWAP_INTEGER( @alternative_score);
      MY_SWAP_INTEGER( @flags);
    end;
  *)

  MY_SWAP_LONGINT( @node[0]);    // MY_SWAP_LONGINT( @hash1);
  MY_SWAP_LONGINT( @node[4]);    // MY_SWAP_LONGINT( @hash2);
  MY_SWAP_INTEGER( @node[8]);    // MY_SWAP_INTEGER( @black_minimax_score);
  MY_SWAP_INTEGER( @node[10]);   // MY_SWAP_INTEGER( @white_minimax_score);
  MY_SWAP_INTEGER( @node[12]);   // MY_SWAP_INTEGER( @best_alternative_move);
  MY_SWAP_INTEGER( @node[14]);   // MY_SWAP_INTEGER( @alternative_score);
  MY_SWAP_INTEGER( @node[16]);   // MY_SWAP_INTEGER( @flags);

end;
{$ELSEC }
begin
  Discard(node);
end;
{$ENDC}


procedure swap_endianess_of_short_for_zebra( n : SInt16Ptr) ;
begin
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  MY_SWAP_INTEGER( UInt16Ptr(n) );
  {$ELSEC }
  Discard(n);
  {$ENDC}
end;


procedure swap_endianess_of_int_for_zebra( n : SInt32Ptr) ;
begin
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  MY_SWAP_LONGINT( UInt32Ptr(n) );
  {$ELSEC }
  Discard(n);
  {$ENDC}
end;



procedure get_zebra_node_from_disk(index : SInt32; var node : ZebraBookNode);
var n,k                   : SInt32;
    indexDansSaTable      : SInt32;
    numeroPlusVieuxBucket : SInt32;
    plusVieilleDate       : SInt32;
    indexMin              : SInt32;
    indexMax              : SInt32;
begin  {$unused node}

  with gZebraBookNodes do
    begin

      inc(nombreAppelsGetZebraNode);


      // par defaut, ce sera celui-ci que l'on detruira
      numeroPlusVieuxBucket  := 1;
      plusVieilleDate        := nodes[numeroPlusVieuxBucket].date;

      (* Cherchons si index est dans un des buffers *)

      for k := 0 to (NB_BUCKETS_ZEBRA_NODES div 2) do
        begin

          (* un coup en montant... *)
          n := dernierBucketUtilise + k;
          if (n > NB_BUCKETS_ZEBRA_NODES) then n := n - NB_BUCKETS_ZEBRA_NODES else
          if (n < 1) then n := n + NB_BUCKETS_ZEBRA_NODES;

          if (index >= nodes[n].indexMin) & (index <= nodes[n].indexMax) then
            begin
              (* trouvé !! *)
              dernierBucketUtilise := n;

              inc(timeStamp);
              nodes[dernierBucketUtilise].date := timeStamp;

              indexDansSaTable := index - nodes[n].indexMin;
              node := nodes[n].table^[indexDansSaTable];

              if (gCacheDesPresents.verbosityLevel >= 2) then
                begin
                  WriteNumDansRapport('',n);
                  WritelnNumDansRapport('  ==> ',index);
                end;

              exit(get_zebra_node_from_disk);
            end;

          if (nodes[n].date < plusVieilleDate) then
            begin
              numeroPlusVieuxBucket := n;
              plusVieilleDate := nodes[n].date;
            end;



          (* un coup en descendant... *)
          n := dernierBucketUtilise - k - 1;
          if (n > NB_BUCKETS_ZEBRA_NODES) then n := n - NB_BUCKETS_ZEBRA_NODES else
          if (n < 1) then n := n + NB_BUCKETS_ZEBRA_NODES;

          if (index >= nodes[n].indexMin) & (index <= nodes[n].indexMax) then
            begin
              (* trouvé !! *)
              dernierBucketUtilise := n;

              inc(timeStamp);
              nodes[dernierBucketUtilise].date := timeStamp;

              indexDansSaTable := index - nodes[n].indexMin;
              node := nodes[n].table^[indexDansSaTable];

              if (gCacheDesPresents.verbosityLevel >= 2) then
                begin
                  WriteNumDansRapport('',n);
                  WritelnNumDansRapport('  ==> ',index);
                end;

              exit(get_zebra_node_from_disk);
            end;

          if (nodes[n].date < plusVieilleDate) then
            begin
              numeroPlusVieuxBucket := n;
              plusVieilleDate := nodes[n].date;
            end;
      end;

      (* On n'a pas trouvé (page miss) : il faut lire le disque *)

      indexMin := index - (SIZE_OF_EACH_NODES_BUCKET div 2);
      indexMax := index + (SIZE_OF_EACH_NODES_BUCKET div 2) - 1;

      if (indexMin < 0) then indexMin := 0;
      if (indexMax > number_of_positions_in_zebra_book - 1) then indexMax := number_of_positions_in_zebra_book - 1;



      if LireBucketOfZebraNodes(numeroPlusVieuxBucket, indexMin, indexMax) = NoErr
        then
          begin
            indexDansSaTable := index - nodes[numeroPlusVieuxBucket].indexMin;

            if (gCacheDesPresents.verbosityLevel >= 3) then
              WritelnNumDansRapport('indexDansSaTable = ',indexDansSaTable);

            node := nodes[numeroPlusVieuxBucket].table^[indexDansSaTable];

            if (gCacheDesPresents.verbosityLevel >= 2) then
              WritelnNumDansRapport('***** ',index);
          end
        else
          begin
          end;

    end;
end;


procedure VerifierIntegriteDuCacheDesPresents;
var k,compteur,data : SInt32;
    theKey : SInt32;
begin
  with gCacheDesPresents do
    begin

      if verificationLevel <= 0 then exit(VerifierIntegriteDuCacheDesPresents);

      compteur := 0;
      for k := 1 to NB_NODES_IN_ZEBRA_CACHE do
        begin
          theKey := keys[k];

          if (theKey < 0)
            then
              begin
                if (theKey <> -1) then
                  begin
                    WritelnNumDansRapport('ERROR !! Erreur dans VerifierIntegriteDuCacheDesPresents !! theKey = ',theKey);
                    inc(nombreErreurs);
                  end;
              end
            else
              begin
                if MemberOfIntegerSet(theKey, data, presents)
                  then
                    begin
                      if (data = k)
                        then
                          begin
                            // Tout a l'air bon
                            inc(compteur);
                          end
                        else
                          begin
                            WritelnDansRapport('ERROR !! Erreur dans VerifierIntegriteDuCacheDesPresents !! data <> k !!!');
                            inc(nombreErreurs);
                          end;
                    end
                  else
                    begin
                      WritelnDansRapport('ERROR !! Erreur dans VerifierIntegriteDuCacheDesPresents !! not(MemberOfIntegerSet)');
                      inc(nombreErreurs);
                    end;
              end;
        end;

      if (compteur <> presents.cardinal) then
        begin
          WritelnDansRapport('Erreur dans VerifierIntegriteDuCacheDesPresents !! compteur <> presents.cardinal');
          WritelnNumDansRapport('     compteur = ',compteur);
          WritelnNumDansRapport('     presents.cardinal = ',presents.cardinal);
          inc(nombreErreurs);
        end;
    end;
end;


procedure ajouter_zebra_node_dans_le_cache_des_presents(theKey : SInt32; var node : ZebraBookNode);
var data : SInt32;
    ok : boolean;
begin
  with gCacheDesPresents do
    begin

      if MemberOfIntegerSet(theKey, data, presents) then
        begin
          {WritelnNumDansRapport('Déja dans cache : ',theKey);}
          exit(ajouter_zebra_node_dans_le_cache_des_presents);
        end;

      if presents.cardinal < NB_NODES_IN_ZEBRA_CACHE
        then
          begin

            (* on a la place pour mettre un nouvel element *)

            if NbElementsDansPile(spotsVides) > 0
              then data := Depiler(spotsVides,ok)
              else data := presents.cardinal + 1;

            if (data <= 0) | (data > NB_NODES_IN_ZEBRA_CACHE) | (keys[data] <> -1) then
              begin
                WritelnNumDansRapport('ERROR : dans ajouter_zebra_node_dans_le_cache_des_presents, ce slot n''est pas vide = ',data);
                inc(nombreErreurs);
              end;

            AddIntegerToSet(theKey,data,presents);
            table^[data] := node;
            keys[data] := theKey;

          end
        else
          begin

            (* plus de place : supprimons un element au hasard... *)

            repeat
              data := RandomEntreBornes(1,NB_NODES_IN_ZEBRA_CACHE - 1);
              RemoveIntegerFromSet(keys[data],presents);
              keys[data] := -1;
            until (presents.cardinal < NB_NODES_IN_ZEBRA_CACHE);


            (* ...et mettons le nouvel element dans cet emplacement *)

            AddIntegerToSet(theKey,data,presents);
            table^[data] := node;
            keys[data] := theKey;

          end;
    end;
end;


procedure enlever_zebra_node_dans_cache_des_presents(theKey : SInt32);
var data : SInt32;
    ok : boolean;
begin
  with gCacheDesPresents do
    begin

      if (theKey < 0) then
        begin
          WritelnNumDansRapport('ERROR !!! Erreur dans enlever_zebra_node_dans_cache_des_presents : (theKey < 0) , puisque theKey = ',theKey);
          inc(nombreErreurs);
        end;

      if MemberOfIntegerSet(theKey, data, presents) then
        begin

          if (data <= 0) & (data > NB_NODES_IN_ZEBRA_CACHE) then
            begin
              WritelnNumDansRapport('ERROR !!! Erreur dans enlever_zebra_node_dans_cache_des_presents : data (out of range) = ',data);
              inc(nombreErreurs);
            end;

          RemoveIntegerFromSet(theKey, presents);

          if (data >= 0) & (data <= NB_NODES_IN_ZEBRA_CACHE) then
            begin
              keys[data] := -1;
              Empiler(spotsVides,data,ok);
            end;
        end;
    end;
end;


function zebra_node_est_present_dans_le_cache(theKey : SInt32; var node : ZebraBookNode) : SInt32;
var data : SInt32;
begin

  zebra_node_est_present_dans_le_cache := 0; (* default : not found *)

  with gCacheDesPresents do
    begin

      if (nombreErreurs > 0) then exit(zebra_node_est_present_dans_le_cache);

      if MemberOfIntegerSet(theKey, data, presents) then
        begin
          zebra_node_est_present_dans_le_cache := 1;   (* found !! *)
          node := table^[data];
        end;
    end;
end;




procedure PrefetchPartiePourRechercheDansZebraBook(var partieEnAlpha : String255; posDepart : PositionEtTraitRec; nbCoupsMin,nbCoupsMax,nbCoupsCourant: SInt32);
var positions : array[0..64] of PositionEtTraitRec;
    correcte : array[0..64] of boolean;
    myPos : PositionEtTraitRec;
    i,k : SInt32;
    coup : SInt32;
    oldMagicCookie : SInt32;
    accelerationArrive, bidbool : boolean;
label sortie;
begin

  if ZebraBookACetteOption(kUtiliserZebraBook) &
     ZebraBookACetteOption(kAllZebraOptions - kUtiliserZebraBook) &
     not(CassioEstEnModeSolitaire) &
     not(CassioEstEnTrainDeLireLaBibliothequeDeZebra) then

  with gCacheDesPresents do
    begin
      IncrementerMagicCookieOfZebraBook;
      oldMagicCookie := GetMagicCookieOfZebraBook;

      {WritelnDansRapport('Entree dans PrefetchPartiePourRechercheDansZebraBook...');}

      BeginUseZebraNodes('PrefetchPartiePourRechercheDansZebraBook');
      SetZebraBookDemandeAccelerationDesEvenements(true,accelerationArrive);

      for i := 0 to 64 do correcte[i] := false;

      myPos := posDepart;
      positions[0] := myPos;
      correcte[0] := true;

      for i := 1 to 64 do
        begin
          coup := PositionDansStringAlphaEnCoup(partieEnAlpha, 2*i-1);
          if (coup >= 11) & (coup <= 88) & UpdatePositionEtTrait(myPos,coup) then
            begin
              positions[i] := myPos;
              correcte[i] := true;
            end;
        end;

      gLectureZebraBook.doitVerifierEvenements := true;

      i := nbCoupsCourant;
      for k := 0 to 32 do
        begin
          i := nbCoupsCourant + k;   (* un coup en montant... *)
          if i > 64 then i := i - 64;

          if (i >= nbCoupsMin) & (i <= nbCoupsMax) & (correcte[i])
            then PrefetchZebraIndexOfThisPosition(positions[i], 1);

          if (GetMagicCookieOfZebraBook <> oldMagicCookie) then goto sortie;

          i := nbCoupsCourant - k - 1;  (* un coup en descendant... *)
          if i < 0 then i := i + 64;

          if (i >= nbCoupsMin) & (i <= nbCoupsMax) & (correcte[i])
            then PrefetchZebraIndexOfThisPosition(positions[i], 1);

          if (GetMagicCookieOfZebraBook <> oldMagicCookie) then goto sortie;
        end;

sortie :
     SetZebraBookDemandeAccelerationDesEvenements(accelerationArrive,bidBool);
     EndUseZebraNodes('PrefetchPartiePourRechercheDansZebraBook');

  end;
end;


procedure PrefetchZebraIndexOfThisPosition(var pos : PositionEtTraitRec; niveauRecursion : SInt32);
var Score_Noir,Score_Blanc,Alt_Move, Alt_Score : SInt16;
    Flags : SInt16;
    i,square : SInt32;
    pos2 : PositionEtTraitRec;
    index : SInt32;
    indexProbable : SInt32;
    oldMagicCookie : SInt32;
    bidbool : SInt32;
label sortie;
begin

  oldMagicCookie := GetMagicCookieOfZebraBook;

  if CassioEstEnTrainDeLireLaBibliothequeDeZebra then
    exit(PrefetchZebraIndexOfThisPosition);

  if (number_of_positions_in_zebra_book <= 0) then
    begin
      if not(ZebraBookEstIntrouvable) & not(CassioEstEnTrainDeLireLaBibliothequeDeZebra)
        then LoadZebraBook(true);
      exit(PrefetchZebraIndexOfThisPosition);
    end;


  // if (niveauRecursion >= 1) then WritelnPositionEtTraitDansRapport(pos.position, GetTraitOfPosition(pos));


  (* on essaie de mettre cette position *)

  indexProbable := -1;


  if MemberOfPositionEtTraitSet(pos,indexProbable,gEnsembleDesPositionsDejaVues) &
     (indexProbable = kPositionNotInZebraBook)
    then goto sortie;



  index := ReadZebraBookValuesFromDisc(pos.position,Score_Noir,Score_Blanc,Alt_Move,Alt_Score,Flags,indexProbable);



  if (index < 0)
    then
      begin
        if (GetMagicCookieOfZebraBook = oldMagicCookie)
          then AddPositionEtTraitToSet(pos,kPositionNotInZebraBook,gEnsembleDesPositionsDejaVues);     (* not found = kPositionNotInZebraBook = -1000 *)
        goto sortie;
      end
    else
      begin
        if (indexProbable = -1) then
           AddPositionEtTraitToSet(pos,index,gEnsembleDesPositionsDejaVues);  (* found *)
      end;


  if GetMagicCookieOfZebraBook <> oldMagicCookie then goto sortie;


  (* On essaie de mettre tous les fils connus *)
  if (niveauRecursion > 0) then
    begin
      pos2 := pos;
      for i := 1 to 64 do
        begin
          square := othellier[i];
          if UpdatePositionEtTrait(pos2,square) then
            begin

              bidBool := lecture_zebra_book_interrompue_par_evenement;

              if GetMagicCookieOfZebraBook <> oldMagicCookie then goto sortie;

              PrefetchZebraIndexOfThisPosition(pos2,niveauRecursion - 1);

              if GetMagicCookieOfZebraBook <> oldMagicCookie then goto sortie;

              pos2 := pos;
            end;
        end;
    end;

sortie :

end;




procedure GerePrefetchingOfZebraBook;
var index : SInt32;
    thePos : PositionEtTraitRec;
    tick : SInt32;
    gotEvent : boolean;
    nombreAppelsGetZebraNodeArrivee : SInt32;
    nombreAccesDisqueArrivee : SInt32;
    nbreAppelsHasGotEventsArrivee : SInt32;
    magicCookieZebraBookArrivee : SInt32;
label sortie;
begin

  if (interruptionReflexion = pasdinterruption) &
     (gZebraBookPrefetchingData.lastMagicCookieSeen <> GetMagicCookieOfZebraBook) &
     not(gDemandeAffichageZebraBook.enAttente)
   then
      with gZebraBookPrefetchingData do
        begin

          if (tempsDuDernierPrefetch > 30) then
            if ((TickCount - dateDuDernierPrefetch) <= 300 )
              then goto sortie;  // le disque dur semble chargé, ne le sollicitons pas trop

          gotEvent := false;
          if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
          if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
          if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
          if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true;
          if HasGotEvent(everyEvent ,theEvent,0,NIL) then begin TraiteOneEvenement; gotEvent := true; end; end; end; end; end;


          if gotEvent then goto sortie; // l'utilisateur semble actif, ne chargeons pas trop le disque


          tick := TickCount; // un chronometre

          nombreAppelsGetZebraNodeArrivee := gZebraBookNodes.nombreAppelsGetZebraNode;
          nombreAccesDisqueArrivee        := gZebraBookNodes.nombreAccesDisque;
          nbreAppelsHasGotEventsArrivee   := gLectureZebraBook.nbreAppelsHasGotEvents;
          magicCookieZebraBookArrivee     := GetMagicCookieOfZebraBook;

          if ZebraBookACetteOption(kUtiliserZebraBook) &
             ZebraBookACetteOption(kAllZebraOptions - kUtiliserZebraBook) &
             not(CassioEstEnModeSolitaire) &
             not(CassioEstEnTrainDeLireLaBibliothequeDeZebra) &
             (nbreCoup <= 40) then
               begin
                 thePos := PositionEtTraitCourant;

                 if MemberOfPositionEtTraitSet(thePos,index,gEnsembleDesPositionsDejaVues) & (index > 0) then
                   begin
                     if (gCacheDesPresents.verbosityLevel >= 1) then
                       WritelnDansRapport('début du prefetch...');


                     BeginUseZebraNodes('GerePrefetchingOfZebraBook');
                     gLectureZebraBook.doitVerifierEvenements := true;
                     PrefetchZebraIndexOfThisPosition(thePos, 2);
                     EndUseZebraNodes('GerePrefetchingOfZebraBook');

                     if (GetMagicCookieOfZebraBook <> magicCookieZebraBookArrivee) then
                       begin
                         // ceci signifie sans doute que l'on a changé de position, on accelère donc le prochain prefetch...
                         tick := TickCount;
                       end;

                     if (gCacheDesPresents.verbosityLevel >= 1) then
                       begin
                         WriteNumDansRapport('GetZebraNodes/CachesMisses/∆GZM/∆CM/vus/presents/events/∆events = ',gZebraBookNodes.nombreAppelsGetZebraNode);
                         WriteNumDansRapport('/',gZebraBookNodes.nombreAccesDisque);
                         WriteNumDansRapport('/',gZebraBookNodes.nombreAppelsGetZebraNode-nombreAppelsGetZebraNodeArrivee);
                         WriteNumDansRapport('/',gZebraBookNodes.nombreAccesDisque-nombreAccesDisqueArrivee);
                         WriteNumDansRapport('/',gEnsembleDesPositionsDejaVues.cardinal);
                         WriteNumDansRapport('/',gCacheDesPresents.presents.cardinal);
                         WriteNumDansRapport('/',gLectureZebraBook.nbreAppelsHasGotEvents);
                         WriteNumDansRapport('/',gLectureZebraBook.nbreAppelsHasGotEvents-nbreAppelsHasGotEventsArrivee);
                         WritelnDansRapport('');
                         WritelnNumDansRapport('...fin du prefetch,  temps = ',TickCount - tick);
                       end;

                   end;
               end;

          tempsDuDernierPrefetch := TickCount - tick;
          dateDuDernierPrefetch  := TickCount;
          lastMagicCookieSeen    := GetMagicCookieOfZebraBook;
        end;

sortie :

end;




END.
































