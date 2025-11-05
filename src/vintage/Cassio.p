UNIT Cassio;



INTERFACE

procedure MainDeCassio;

procedure Crash_with_stack_alignment;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio, UnitDebuggage, OSAtomic_glue, Processes, OSUtils, UnitDefATR, fp
    , GestaltEqu, Resources, MacWindows, Appearance, MacMemory, Sound, MacHelp, Timer
    , QuickDraw, CFNetworkglue, UnitDefEngine, UnitDefParallelisme
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitEnvirons, UnitCFNetworkHTTP, UnitBaseOfficielle, UnitNouveauFormat, UnitPierresDelta
    , EdmondEvaluation, ImportEdmond, UnitActions, UnitTestNouveauFormat, UnitTestProperties, UnitTestFichierAbstrait, UnitEvaluation, UnitFichierPhotos
    , UnitBufferedPICT, UnitJaponais, UnitAppleEventsCassio, UnitTestMinimisation, UnitTestNouvelleEval, UnitCampFire, UnitProbCutValues, UnitAccesGraphe
    , UnitEntreesSortiesGraphe, UnitCalculsApprentissage, UnitGrapheInterversions, UnitApprentissagePartie, UnitTestGraphe, UnitPileEtFile, UnitSortedSet, UnitWeightedSet
    , UnitHashing, UnitPositionEtTraitSet, UnitAffichageReflexion, UnitCreateBitboardCode, UnitBitboardStabilite, UnitGeometrie, UnitEndgameTree, UnitGenericGameFormat
    , UnitProgressBar, UnitHashTableExacte, UnitNewGeneral, UnitJeu, UnitGestionDuTemps, UnitNotesSurCases, UnitATR, UnitMiniProfiler
    , UnitBitboard64bitsModifPlat, UnitSelectionRapideListe, UnitRapportImplementation, UnitCarbonisation, UnitTraceLog, UnitUtilitaires, UnitNouvelleEval, UnitChi2NouvelleEval
    , UnitVecteursEval, UnitBibl, UnitCalculCouleurCassio, UnitMoveRecords, UnitPostScript, UnitArbreDeJeuCourant, Unit_AB_Scout, UnitAffichageArbreDeJeu
    , UnitServicesDialogs, UnitTournoi, UnitEntreeTranscript, UnitBitboardHash, UnitImagettesMeteo, UnitImportDesNoms, UnitDiagramFforum, UnitTroisiemeDimension
    , UnitPrefs, UnitPotentiels, Unit3DPovRayPicts, Zebra_to_Cassio, UnitRetrograde, UnitSolitairesNouveauFormat, UnitFormatsFichiers, UnitCassioSounds
    , UnitInterversions, UnitSmartGameBoard, UnitScripts, UnitPrint, UnitIconisation, UnitInitValeursBlocs, UnitBords, UnitSaisiePartie
    , UnitMenus, UnitStatistiques, UnitRapport, UnitNouveauFormat, UnitRegressionLineaire, UnitDialog, UnitFenetres, UnitTestHashing
    , UnitVieilOthelliste, UnitSolve, UnitUtilitairesFinale, MyStrings, UnitCourbe, UnitScannerUtils, UnitBaseNouveauFormat, UnitOthelloGeneralise
    , UnitLiveUndo, UnitProblemeDePriseDeCoin, UnitNormalisation, MyUtils, UnitAlgebreLineaire, UnitClassement, UnitFinaleFast, SNMenus
    , UnitScannerOthellistique, UnitTHOR_PAR, UnitSearchValues, UnitSymmetricalMapping, UnitTriListe, UnitParallelisme, UnitConstrListeBitboard, MyMathUtils
    , MyFonts, MyAntialiasing, MyFileSystemUtils, MyQuickDraw, SNEvents, UnitCouleur, UnitRapportUtils, UnitEvenement, UnitTestZoo
    , UnitZoo, UnitCurseur, UnitOth2, UnitModes, UnitCompilation, basicfile, UnitPagesATR, UnitPagesABR, UnitLongString
    , UnitPagesDeModules, UnitZooAvecArbre, UnitPagesDeSymboles, UnitVecteursEvalInteger, UnitProperties, UnitGameTree, UnitPropertyList, UnitPhasesPartie
    , UnitListe, UnitServicesMemoire, UnitSuperviseur, UnitMilieuDePartie, UnitAffichagePlateau, UnitListeChaineeCasesVides, UnitPositionEtTrait, UnitEstimationCharge
    , UnitEngine, UnitMetaphone, UnitUnixTask ;
{$ELSEC}
    ;
    {$I prelink/Cassio.lk}
{$ENDC}


{END_USE_CLAUSE}



{$ifc defined __GPC__}
    {$I CountLeadingZerosForGNUPascal.inc}
{$endc}






{ Petites choses utiles pour construire Cassio :

  a) Attention, quand on fait une sauvegarde des sources, il faut reconstruire
     le menu rapide de Resedit.

  b) Pour changer la ressource plist :
     - Ouvrir Resedit et l'application Console
     - Créer un fichier Cassio.info.plist
     - L'editer dans TextEdit, le sauvegarder en UTF-8
     - Le vérifier dans le Terminal :
         plutil Cassio.info.plist
     - Fermer le fichier Cassio.info.plist
     - L'ouvrir dans Tex-Edit Plus, de Trans-Tex Software
     - Tout selectionner, puis Edition->CouperandColler spécial->Copier sans style
     - Coller le presse-papier dans la ressource plst 0 dans Resedit, sauvegarder
     - Construire Cassio dans CodeWarrior
     - Lancer Cassio depuis le Finder
     - Vérifier dans la Console que les accents sont bien passés
       (pas de message : "This is not proper Unicode...")
     - ouf !

  c) Si on change les icônes, penser à reconstruire la base de donnees de
     LaunchServices pour faire apparaitre les icônes, en utilisant la
     commande suivante dans le Terminal :


    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user


  d) option du linker ld pour construire sur Intel :
      -whyload -whatsloaded -execute -Y 10 -x -S -dead_strip

     bien aussi :

      -S -dead_strip

     bien aussi :

      -x -S -dead_strip


     optimization level -S

  e) pour que la technique des "late imports" marche, il faut mettre le fragment
     dans les preferences du projet de CodeWarrior

  f) pour regarder les sockets UNIX : netstat -an | grep tcp4
     avec les noms DNS              : netstat -a  | grep tcp4

  g) pour ajouter/retirer des labels sur les cases, il faut taper les commandes suivantes
     dans la fenetre arbre de jeu puis appuyer sur Entree (espaces facultatives) :

     add : LB[a1:toto]
     delete : LB[a1:toto]


{*********************** initialisations ****************************}




{ Traduction en Pascal des typages des fonctions C de EngineProtocol.h}
procedure EngineProtocolMainLoop;     external;



procedure SetUpMenuBar;
  var preferenceItemText : String255;
      cmdChar : CharParameter;
      {s : String255;
      i : SInt32;}
  begin
    SetAppleMenu(MyGetMenu(AppleID));
    SetFileMenu(MyGetMenu(fileID));
    EditionMenu := MyGetMenu(editionID);
    PartieMenu := MyGetMenu(partieID);
    ModeMenu := MyGetMenu(modeID);
    JoueursMenu := MyGetMenu(joueursID);
    BaseMenu := MyGetMenu(baseID);
    TriMenu := MyGetMenu(triID);
    FormatBaseMenu := MyGetMenu(FormatBaseID);
    Picture2DMenu := MyGetMenu(Picture2DID);
    Picture3DMenu := MyGetMenu(Picture3DID);
    CopierSpecialMenu := MyGetMenu(CopierSpecialID);
    GestionBaseWThorMenu := MyGetMenu(GestionBaseWThorID);
    AffichageMenu := MyGetMenu(affichageID);
    SolitairesMenu := MyGetMenu(solitairesID);
    CouleurMenu := MyGetMenu(couleurID);
    if avecProgrammation then
      ProgrammationMenu := MyGetMenu(programmationID);
    OuvertureMenu := MyGetMenu(OuvertureID);
    ReouvrirMenu := MyGetMenu(ReouvrirID);
    NMeilleursCoupsMenu := MyGetMenu(NMeilleursCoupID);

    if gIsRunningUnderMacOSX then
      begin
        DeleteMenuItem(GetFileMenu,QuitCmd);
        DeleteMenuItem(GetFileMenu,QuitCmd-1);
        MyGetMenuItemText(GetFileMenu,PreferencesCmd,preferenceItemText);
        if InsertMenuItemText(GetAppleMenu,StringToStr255(preferenceItemText),AboutCmd+1) = NoErr then
          begin
            GetItemCmd(GetFileMenu,PreferencesCmd,cmdChar);
            SetItemCmd(GetAppleMenu,PreferencesDansPommeCmd,',');
            DeleteMenuItem(GetFileMenu,PreferencesCmd);
          end;
      end;

    InsertMenu(GetAppleMenu,0);
    InsertMenu(GetFileMenu,0);
    InsertMenu(EditionMenu,0);
    InsertMenu(PartieMenu,0);
    InsertMenu(ModeMenu,0);
    InsertMenu(JoueursMenu,0);
    InsertMenu(AffichageMenu,0);
    InsertMenu(CouleurMenu,-1);
    InsertMenu(SolitairesMenu,0);
    InsertMenu(BaseMenu,0);
    InsertMenu(TriMenu,-1);
    InsertMenu(FormatBaseMenu,-1);
    InsertMenu(Picture2DMenu,-1);
    InsertMenu(Picture3DMenu,-1);
    InsertMenu(CopierSpecialMenu,-1);
    InsertMenu(GestionBaseWThorMenu,-1);
    if avecProgrammation then InsertMenu(ProgrammationMenu,0);
    InsertMenu(ReouvrirMenu,-1);
    InsertMenu(NMeilleursCoupsMenu,-1);
    DrawMenuBar;
  end;




procedure AfficheMemoire;
begin
  EcritEtatMemoire;
end;


procedure InitTablesHashageOthello;
var j,m : SInt32;
begin
  SetRandomSeed(4000);
  VideHashTable(HashTable);
  HashTable^^[0] := 1;
  for j := 11 to 88 do
    begin
      m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      IndiceHash^^[pionNoir,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  for j := 11 to 88 do
    begin
      m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      IndiceHash^^[pionBlanc,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  for j := 11 to 88 do
    begin
      m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      if HashTable^^[m mod 32768] <> 0 then m := Abs(Random32());
      IndiceHash^^[pionVide,j] := m;
      HashTable^^[m mod 32768] := 1;
    end;
  VideHashTable(HashTable);
  RandomizeTimer;
end;


function MyCreateNewWindow( windowClass : WindowClass; attributes : WindowAttributes; const (*var*) contentBounds : Rect; var outWindow : WindowRef ): OSStatus;
var a : boolean;
   err : OSStatus;
begin

  if (windowClass <> 0) then
     begin
         outWindow := NIL;
         err := -1;
         a := false;
       end;

 if (attributes <> 0) then
     begin
       outWindow := NIL;
       err := -2;
       a := true;
     end;

 if (contentBounds.left <> 0) then
   begin
     outWindow := NIL;
     err := -3;
     a := false;
   end;

 if (contentBounds.right <> 0) then
   begin
     outWindow := NIL;
     err := -4;
     a := true;
   end;

  if a
    then MyCreateNewWindow := NoErr
    else MyCreateNewWindow := err;
end;


function My_crasher_function(forWhichWindow : WindowPtr; var help : HMHelpContentRec; commandState : boolean) : OSStatus;
var
  err : OSStatus;
  contentRect : Rect;
  attributes : WindowAttributes;
  myWindow : WindowRef;
begin  {$unused forWhichWindow, help, commandState}


  with contentRect do
    begin
      left    := 100;
      top     := 100;
      right   := 200;
      bottom  := 200;
    end;


  attributes := 0;

  // create a new window ==> crash with "misaligned stack error "

  //err := MyCreateNewWindow(kHelpWindowClass,attributes,contentRect,myWindow);
  err := CreateNewWindow(kHelpWindowClass,attributes,contentRect,myWindow);

  My_crasher_function := err;
end;


procedure Make_GNU_Pascal_crash(pointNumber : SInt32; commandState : boolean);
var
  status : OSErr;
  helpTag : HMHelpContentRec;
  s : String255;
  x, y : SInt32;
  theRect : Rect;
  message : Str255;
begin

  Discard(pointNumber);

  x := 100;
  y := 100;



  with theRect do
    begin
      left    := x - 3;
      top     := y - 3;
      right   := x + 3;
      bottom  := y + 3;
    end;

  s := 'Some rather short text';

  helpTag.version    := kMacHelpVersion;
  helpTag.tagSide    := kHMOutsideRightCenterAligned;
  helpTag.absHotRect := theRect;
  helpTag.content[kHMMinimumContentIndex].contentType   := kHMPascalStrContent;

  message := StringToStr255(s);

  // And here is the bug : swap the two following lines to make the crash appear or desappear


  // helpTag.content[kHMMinimumContentIndex].tagString     := message;                   // will not crash
  helpTag.content[kHMMinimumContentIndex].tagString     := StringToStr255(s);            // will crash !


  // note that the following line is also necessary for the bug to appear
  s := s + ' and some other text for testing';

  status := My_crasher_function(NIL,helpTag,commandState);
end;


procedure Crash_with_stack_alignment;
var x,y : SInt32;
begin

  Make_GNU_Pascal_crash(1, false);


  if Abs(Random16()) < -20
    then y := 10
    else y := 0;


  if (x div y) > 10 then
     WritelnDansRapport('sortie de FaireCrasherLeCompilateur : BAD ');

  WritelnDansRapport('sortie de FaireCrasherLeCompilateur : OK ');

end;





procedure VerifierLeCompilateur;
var aux : SInt32;
    nbreErreursDeTypes : SInt32;
    foo_bar_atomic_register : SInt32;
    {node : ZebraBookNodeRecord;}
    my_u64 : UInt64;
    s : String255;
    my_double : double;

   procedure VerifierLaTailleDeCeType(nom : String255; tailleReelle,tailleTheorique : SInt32);
    begin
      if (tailleReelle <> tailleTheorique) then
        begin

          inc(nbreErreursDeTypes);

          {$IFC DEFINED __GPC__}
          (* Writeln('  VerifierLaTailleDeCeType('''+nom+''',Sizeof('+nom+'),'+IntToStr(tailleReelle)+');'); *)
          {$ENDC}

          WritelnDansRapport('  VerifierLaTailleDeCeType('''+nom+''',Sizeof('+nom+'),'+IntToStr(tailleReelle)+');');
        end;
    end;

begin
  nbreErreursDeTypes := 0;

  { Attention ! La liste suivante n'est pas exhaustive, mais devrait donner une bonne idee
   des problemes liés à la taille des enregistrements sur le compilateur utilisé pour compiler Cassio }


  VerifierLaTailleDeCeType('TERec',Sizeof(TERec),32098);
  VerifierLaTailleDeCeType('TextStyle',Sizeof(TextStyle),12);
  VerifierLaTailleDeCeType('SInt32',Sizeof(SInt32),4);
  VerifierLaTailleDeCeType('SInt16',Sizeof(SInt16),2);
  VerifierLaTailleDeCeType('unsignedword',Sizeof(unsignedword),2);
  VerifierLaTailleDeCeType('unsignedlong',Sizeof(unsignedlong),4);
  VerifierLaTailleDeCeType('char',Sizeof(char),2);
  VerifierLaTailleDeCeType('byte',Sizeof(byte),2);
  VerifierLaTailleDeCeType('UInt8',Sizeof(UInt8),2);
  VerifierLaTailleDeCeType('SInt8',Sizeof(SInt8),1);
  VerifierLaTailleDeCeType('t_Octet',Sizeof(t_Octet),2);
  VerifierLaTailleDeCeType('integerP',Sizeof(integerP),4);
  VerifierLaTailleDeCeType('ptrint',Sizeof(ptrint),4);
  VerifierLaTailleDeCeType('buf255',Sizeof(buf255),256);
  VerifierLaTailleDeCeType('String255',Sizeof(String255),256);
  VerifierLaTailleDeCeType('short',Sizeof(short),2);
  VerifierLaTailleDeCeType('long',Sizeof(long),4);
  VerifierLaTailleDeCeType('CharSet',Sizeof(CharSet),32);
  VerifierLaTailleDeCeType('SavedWindowInfo',Sizeof(SavedWindowInfo),16);
  VerifierLaTailleDeCeType('SetOfChar',Sizeof(SetOfChar),32);
  VerifierLaTailleDeCeType('PackedThorGame',Sizeof(PackedThorGame),62);
  VerifierLaTailleDeCeType('GrapheRec',Sizeof(GrapheRec),356);
  VerifierLaTailleDeCeType('RealType',Sizeof(RealType),8);
  VerifierLaTailleDeCeType('VecteurBooleens',Sizeof(VecteurBooleens),48);
  VerifierLaTailleDeCeType('MatriceReels',Sizeof(MatriceReels),12808);
  VerifierLaTailleDeCeType('VecteurReels',Sizeof(VecteurReels),324);
  VerifierLaTailleDeCeType('VecteurLongint',Sizeof(VecteurLongint),164);
  VerifierLaTailleDeCeType('menuFlottantBasesRec',Sizeof(menuFlottantBasesRec),124);
  VerifierLaTailleDeCeType('stringBibl',Sizeof(stringBibl),256);
  VerifierLaTailleDeCeType('IntegerArray',Sizeof(IntegerArray),2);
  VerifierLaTailleDeCeType('PointMultidimensionnelInteger',Sizeof(PointMultidimensionnelInteger),12);
  VerifierLaTailleDeCeType('loweruppermoveemptiesRec',Sizeof(loweruppermoveemptiesRec),4);
  VerifierLaTailleDeCeType('BitboardHashRec',Sizeof(BitboardHashRec),20);
  VerifierLaTailleDeCeType('BitboardHash',Sizeof(BitboardHash),4);
  VerifierLaTailleDeCeType('BitboardHashTableRec',Sizeof(BitboardHashTableRec),44);
  VerifierLaTailleDeCeType('BitboardHashEntryRec',Sizeof(BitboardHashEntryRec),40);
  VerifierLaTailleDeCeType('bitboard',Sizeof(bitboard),16);
  VerifierLaTailleDeCeType('t_othellierBitboard_descr',Sizeof(t_othellierBitboard_descr),800);
  VerifierLaTailleDeCeType('listeCoupsAvecBitboard',Sizeof(listeCoupsAvecBitboard),2800);
  VerifierLaTailleDeCeType('t_table_BlocsDeCoin',Sizeof(t_table_BlocsDeCoin),13122);
  VerifierLaTailleDeCeType('t_liste_assoc_bord',Sizeof(t_liste_assoc_bord),16008);
  VerifierLaTailleDeCeType('t_code_pattern',Sizeof(t_code_pattern),256);
  VerifierLaTailleDeCeType('CouleurOthellierRec',Sizeof(CouleurOthellierRec),286);
  VerifierLaTailleDeCeType('plateauOthello',Sizeof(plateauOthello),100);
  VerifierLaTailleDeCeType('typeColorationCourbe',Sizeof(typeColorationCourbe),1);
  VerifierLaTailleDeCeType('SetOfGenreDeReflexion',Sizeof(SetOfGenreDeReflexion),1);
  VerifierLaTailleDeCeType('CelluleRec',Sizeof(CelluleRec),44);
  VerifierLaTailleDeCeType('CelluleListeHeuristiqueRec',Sizeof(CelluleListeHeuristiqueRec),44);
  VerifierLaTailleDeCeType('EnsembleDeTypes',Sizeof(EnsembleDeTypes),4);
  VerifierLaTailleDeCeType('typePartiePourGraphe',Sizeof(typePartiePourGraphe),256);
  VerifierLaTailleDeCeType('ListeDeCellules',Sizeof(ListeDeCellules),1608);
  VerifierLaTailleDeCeType('t_EnTeteNouveauFormat',Sizeof(t_EnTeteNouveauFormat),16);
  VerifierLaTailleDeCeType('t_JoueurRecNouveauFormat',Sizeof(t_JoueurRecNouveauFormat),20);
  VerifierLaTailleDeCeType('t_TournoiRecNouveauFormat',Sizeof(t_TournoiRecNouveauFormat),26);
  VerifierLaTailleDeCeType('t_PartieRecNouveauFormat',Sizeof(t_PartieRecNouveauFormat),68);
  VerifierLaTailleDeCeType('t_SolitaireRecNouveauFormat',Sizeof(t_SolitaireRecNouveauFormat),36);
  VerifierLaTailleDeCeType('indexArray',Sizeof(indexArray),22);
  VerifierLaTailleDeCeType('DistributionRec',Sizeof(DistributionRec),24);
  VerifierLaTailleDeCeType('FichierNouveauFormatRec',Sizeof(FichierNouveauFormatRec),396);
  VerifierLaTailleDeCeType('JoueursNouveauFormatRec',Sizeof(JoueursNouveauFormatRec),792);
  VerifierLaTailleDeCeType('TournoisNouveauFormatRec',Sizeof(TournoisNouveauFormatRec),524);
  VerifierLaTailleDeCeType('tableJoueursNouveauFormat',Sizeof(tableJoueursNouveauFormat),792);
  VerifierLaTailleDeCeType('SetOfPropertyTypes',Sizeof(SetOfPropertyTypes),14);
  VerifierLaTailleDeCeType('Triple',Sizeof(Triple),4);
  VerifierLaTailleDeCeType('PartieFormatGGFRec',Sizeof(PartieFormatGGFRec),1998);
  VerifierLaTailleDeCeType('ChecksRecord',Sizeof(ChecksRecord),36);
  VerifierLaTailleDeCeType('SetOfItemNumber',Sizeof(SetOfItemNumber),32);
  VerifierLaTailleDeCeType('Transcript',Sizeof(Transcript),204);
  VerifierLaTailleDeCeType('FichierPictureRec',Sizeof(FichierPictureRec),16);
  VerifierLaTailleDeCeType('basicfile',Sizeof(basicfile),352);
  VerifierLaTailleDeCeType('AmeliorationsAlphaRec',Sizeof(AmeliorationsAlphaRec),772);
  VerifierLaTailleDeCeType('FormatFichierRec',Sizeof(FormatFichierRec),518);
  VerifierLaTailleDeCeType('InterversionHashIndexRec',Sizeof(InterversionHashIndexRec),8);
  VerifierLaTailleDeCeType('DecompressionHashExacteRec',Sizeof(DecompressionHashExacteRec),200);
  VerifierLaTailleDeCeType('codePositionRec',Sizeof(codePositionRec),24);
  VerifierLaTailleDeCeType('bitboard',Sizeof(bitboard),16);
  VerifierLaTailleDeCeType('celluleCaseVideDansListeChainee',Sizeof(celluleCaseVideDansListeChainee),16);
  VerifierLaTailleDeCeType('t_bufferCellulesListeChainee',Sizeof(t_bufferCellulesListeChainee),1056);
  VerifierLaTailleDeCeType('tableDePointeurs',Sizeof(tableDePointeurs),400);
  VerifierLaTailleDeCeType('celluleCaseVideDansListeChaineePtr',Sizeof(celluleCaseVideDansListeChaineePtr),4);
  VerifierLaTailleDeCeType('myKeyMap',Sizeof(myKeyMap),16);
  VerifierLaTailleDeCeType('MenuCmdRec',Sizeof(MenuCmdRec),4);
  VerifierLaTailleDeCeType('ReflexionTypesSet',Sizeof(ReflexionTypesSet),128);
  VerifierLaTailleDeCeType('plBool',Sizeof(plBool),100);
  VerifierLaTailleDeCeType('plOthSignedByte',Sizeof(plOthSignedByte),100);
  VerifierLaTailleDeCeType('plOtInteger',Sizeof(plOtInteger),200);
  VerifierLaTailleDeCeType('plOthLongint',Sizeof(plOthLongint),400);
  VerifierLaTailleDeCeType('plOthEndgame',Sizeof(plOthEndgame),100);
  VerifierLaTailleDeCeType('ListOfMoveRecords',Sizeof(ListOfMoveRecords),2304);
  VerifierLaTailleDeCeType('MinSec',Sizeof(MinSec),12);
  VerifierLaTailleDeCeType('DeuxOctets',Sizeof(DeuxOctets),2);
  VerifierLaTailleDeCeType('Property',Sizeof(Property),12);
  VerifierLaTailleDeCeType('PropertyListRec',Sizeof(PropertyListRec),16);
  VerifierLaTailleDeCeType('GameTreeListRec',Sizeof(GameTreeListRec),8);
  VerifierLaTailleDeCeType('GameTreeRec',Sizeof(GameTreeRec),20);
  VerifierLaTailleDeCeType('t_partie',Sizeof(t_partie),3432);
  VerifierLaTailleDeCeType('t_partieDansThorDBA',Sizeof(t_partieDansThorDBA),68);
  VerifierLaTailleDeCeType('InfoFront',Sizeof(InfoFront),336);
  VerifierLaTailleDeCeType('InfosMilieuRec',Sizeof(InfosMilieuRec),444);
  VerifierLaTailleDeCeType('tabl_heuristique',Sizeof(tabl_heuristique),4836);
  VerifierLaTailleDeCeType('meilleureSuiteInfosRec',Sizeof(meilleureSuiteInfosRec),92);
  VerifierLaTailleDeCeType('t_AnalyseRetrogradeInfos',Sizeof(t_AnalyseRetrogradeInfos),2464);
  VerifierLaTailleDeCeType('packed7',Sizeof(packed7),8);
  VerifierLaTailleDeCeType('tableCommentaireOuv',Sizeof(tableCommentaireOuv),15002);
  VerifierLaTailleDeCeType('EvaluationCassioRec',Sizeof(EvaluationCassioRec),64);
  VerifierLaTailleDeCeType('PageImprRec',Sizeof(PageImprRec),12);
  VerifierLaTailleDeCeType('BigOthellier',Sizeof(BigOthellier),968);
  VerifierLaTailleDeCeType('Point',Sizeof(Point),4);
  VerifierLaTailleDeCeType('PackedOthelloPosition',Sizeof(PackedOthelloPosition),16);
  VerifierLaTailleDeCeType('ABRRec',Sizeof(ABRRec),20);
  VerifierLaTailleDeCeType('ATRRec',Sizeof(ATRRec),16);
  VerifierLaTailleDeCeType('PositionEtTraitRec',Sizeof(PositionEtTraitRec),108);
  VerifierLaTailleDeCeType('double',Sizeof(double),8);
  VerifierLaTailleDeCeType('VincenzMoveRec',Sizeof(VincenzMoveRec),20);
  VerifierLaTailleDeCeType('ProblemePriseDeCoin',Sizeof(ProblemePriseDeCoin),184);
  VerifierLaTailleDeCeType('PropertyLocalisation',Sizeof(PropertyLocalisation),16);
  VerifierLaTailleDeCeType('InfoQuintuplet',Sizeof(InfoQuintuplet),8);
  VerifierLaTailleDeCeType('PackedSquareSet',Sizeof(PackedSquareSet),8);
  VerifierLaTailleDeCeType('SearchResult',Sizeof(SearchResult),20);
  VerifierLaTailleDeCeType('SearchWindow',Sizeof(SearchWindow),40);
  VerifierLaTailleDeCeType('CharArray',Sizeof(CharArray),32002);
  VerifierLaTailleDeCeType('CharArrayPtr',Sizeof(CharArrayPtr),4);
  VerifierLaTailleDeCeType('CharArrayHandle',Sizeof(CharArrayHandle),4);
  VerifierLaTailleDeCeType('SortedSet',Sizeof(SortedSet),8);
  VerifierLaTailleDeCeType('SquareSet',Sizeof(SquareSet),16);
  VerifierLaTailleDeCeType('PackedSquareSet',Sizeof(PackedSquareSet),8);
  VerifierLaTailleDeCeType('ThorParRec',Sizeof(ThorParRec),112);
  VerifierLaTailleDeCeType('Tableau60Longint',Sizeof(Tableau60Longint),244);
  VerifierLaTailleDeCeType('DoubleArray',Sizeof(DoubleArray),8);
  VerifierLaTailleDeCeType('Double',Sizeof(Double),8);
  VerifierLaTailleDeCeType('LongintArray',Sizeof(LongintArray),4);
  VerifierLaTailleDeCeType('VectNewEval',Sizeof(VectNewEval),880);
  VerifierLaTailleDeCeType('VectNewEvalInteger',Sizeof(VectNewEvalInteger),2640);
  VerifierLaTailleDeCeType('WeightedSet',Sizeof(WeightedSet),12);
  VerifierLaTailleDeCeType('FichierAbstraitPtr',Sizeof(FichierAbstraitPtr),4);
  VerifierLaTailleDeCeType('FichierAbstrait',Sizeof(FichierAbstrait),52);
  VerifierLaTailleDeCeType('ZebraBookNode',Sizeof(ZebraBookNode),18);
  VerifierLaTailleDeCeType('ZebraBookNodeRecord',Sizeof(ZebraBookNodeRecord),18);
  VerifierLaTailleDeCeType('size_of_int_in_c',size_of_int_in_c,4);
  VerifierLaTailleDeCeType('size_of_float_in_c',size_of_float_in_c,4);
  VerifierLaTailleDeCeType('TypeReel',Sizeof(TypeReel),8);
  VerifierLaTailleDeCeType('TypeReelArray',Sizeof(TypeReelArray),328);
  VerifierLaTailleDeCeType('TypeReelArrayPtr',Sizeof(TypeReelArrayPtr),4);
  VerifierLaTailleDeCeType('PackedArrayOfChar',Sizeof(PackedArrayOfChar),1);
  VerifierLaTailleDeCeType('LongintArray',Sizeof(LongintArray),4);
  VerifierLaTailleDeCeType('LongintArrayPtr',Sizeof(LongintArrayPtr),4);
  VerifierLaTailleDeCeType('IntegerArray',Sizeof(IntegerArray),2);
  VerifierLaTailleDeCeType('IntegerArrayPtr',Sizeof(IntegerArrayPtr),4);
  VerifierLaTailleDeCeType('NoeudDeParallelisme',Sizeof(NoeudDeParallelisme),664);
  VerifierLaTailleDeCeType('TableauDeQuatreHashStamps',Sizeof(TableauDeQuatreHashStamps),16);
  VerifierLaTailleDeCeType('ParallelAlphaBetaRec',Sizeof(ParallelAlphaBetaRec),128);
  VerifierLaTailleDeCeType('ParallelAlphaBetaRecArray',Sizeof(ParallelAlphaBetaRecArray),128);
  VerifierLaTailleDeCeType('FileResultatsParallelismeRec',Sizeof(FileResultatsParallelismeRec),1024);
  VerifierLaTailleDeCeType('ResultParallelismeRec',Sizeof(ResultParallelismeRec),32);
  VerifierLaTailleDeCeType('HashTableArray',Sizeof(HashTableArray),32768);
  VerifierLaTailleDeCeType('IndiceHashArray',Sizeof(IndiceHashArray),936);
  VerifierLaTailleDeCeType('HashTableExacteElement',Sizeof(HashTableExacteElement),54);
  VerifierLaTailleDeCeType('HashTableExacteRec',Sizeof(HashTableExacteRec),55296);
  VerifierLaTailleDeCeType('CoupsLegauxHashArray',Sizeof(CoupsLegauxHashArray),20480);



  if nbreErreursDeTypes <> 0 then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('Il y a '+IntToStr(nbreErreursDeTypes) +' types qui ont des tailles différentes dans CodeWarrior et GNU Pascal');
      WritelnDansRapport('');
    end;


  WritelnDansRapport('Vérifions que les positions des champs dans ZebraBookNodeRecord sont bons...');
  WriteNumDansRapport('sizeof(ZebraBookNodeRecord) = ',sizeof(ZebraBookNodeRecord));
  if sizeof(ZebraBookNodeRecord) = 18
    then WritelnDansRapport('...   OK')
    else WritelnDansRapport('...   ERREUR !  sizeof(ZebraBookNodeRecord) devrait valoir 18');
(*
  WritelnNumDansRapport('adresse de node : ',SInt32(@node));
  WritelnNumDansRapport('decalage de hash1 : ', SInt32(@node.hash1) - SInt32(@node));
  WritelnNumDansRapport('decalage de hash2 : ', SInt32(@node.hash2) - SInt32(@node));
  WritelnNumDansRapport('decalage de black_minimax_score : ', SInt32(@node.black_minimax_score) - SInt32(@node));
  WritelnNumDansRapport('decalage de white_minimax_score : ', SInt32(@node.white_minimax_score) - SInt32(@node));
  WritelnNumDansRapport('decalage de best_alternative_move : ', SInt32(@node.best_alternative_move) - SInt32(@node));
  WritelnNumDansRapport('decalage de alternative_score : ', SInt32(@node.alternative_score) - SInt32(@node));
  WritelnNumDansRapport('decalage de flags : ', SInt32(@node.flags) - SInt32(@node));
*)
  WritelnDansRapport('');


  WritelnDansRapport('Vérifions que les types enumerés commencent bien à zéro...');
  WriteNumDansRapport('SInt32(kNonPrecisee) = ',SInt32(kNonPrecisee));
  if SInt32(kNonPrecisee) = 0
    then WritelnDansRapport('...   OK')
    else WritelnDansRapport('...   ERREUR !');
  WritelnDansRapport('');


  WritelnDansRapport('Verification de BTst et de BSet et de BClr');
  aux := 0;
  BSET(aux, 14);
  WritelnDansRapport('apres BSET(aux, 14), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));

  aux := 0;
  BSET(aux, 13);
  WritelnDansRapport('apres BSET(aux, 13), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));

  aux := 0;
  BSET(aux, 4);
  WritelnDansRapport('apres BSET(aux, 4), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));

  aux := 0;
  BSET(aux, 3);
  WritelnDansRapport('apres BSET(aux, 3), aux = ' + Hexa(aux));
  WritelnDansRapport('Hexa(BNOT(aux)) = '+Hexa(BNOT(aux)));

  WritelnDansRapport('');

  WritelnDansRapport('Vérification de la présence des opérations atomiques...');
  nbreNoeudsGeneresFinale := 10;
  WritelnNumDansRapport('avant ATOMIC_INCREMENT_32, nbreNoeudsGeneresFinale = ',nbreNoeudsGeneresFinale);
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  WritelnNumDansRapport('après ATOMIC_INCREMENT_32, nbreNoeudsGeneresFinale = ',nbreNoeudsGeneresFinale);

  WritelnDansRapport('');

  WritelnDansRapport('Vérification de Count_leading_zeros...');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00000000) = ',COUNT_LEADING_ZEROS($00000000));
  SAFE_COUNT_LEADING_ZEROS($00000000, aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00000000) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00000001) = ',COUNT_LEADING_ZEROS($00000001));
  SAFE_COUNT_LEADING_ZEROS($00000001, aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00000001) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00000101) = ',COUNT_LEADING_ZEROS($00000101));
  SAFE_COUNT_LEADING_ZEROS($00000101, aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00000101) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00008000) = ',COUNT_LEADING_ZEROS($00008000));
  SAFE_COUNT_LEADING_ZEROS($00008000, aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00008000) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00008100) = ',COUNT_LEADING_ZEROS($00008100));
  SAFE_COUNT_LEADING_ZEROS($00008100, aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00008100) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($00010000) = ',COUNT_LEADING_ZEROS($00010000));
  SAFE_COUNT_LEADING_ZEROS($00010000,aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($00010000) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($20000000) = ',COUNT_LEADING_ZEROS($20000000));
  SAFE_COUNT_LEADING_ZEROS($20000000,aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($20000000) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($40000000) = ',COUNT_LEADING_ZEROS($40000000));
  SAFE_COUNT_LEADING_ZEROS($40000000,aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($40000000) = ',aux);
  WritelnDansRapport('');

  WritelnNumDansRapport('COUNT_LEADING_ZEROS($80000000) = ',COUNT_LEADING_ZEROS($80000000));
  SAFE_COUNT_LEADING_ZEROS($80000000,aux);
  WritelnNumDansRapport('SAFE_COUNT_LEADING_ZEROS($80000000) = ',aux);
  WritelnDansRapport('');




  SetHashValueDuZoo(my_u64,0);
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  SetHashValueDuZoo(my_u64,k_ZOO_NOT_INITIALIZED_VALUE);
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  SetHashValueDuZoo(my_u64,-k_ZOO_NOT_INITIALIZED_VALUE);
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  SetHashValueDuZoo(my_u64,-1);
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  SetHashValueDuZoo(my_u64,1);
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  my_u64 := HashString63Bits('toto est grand');
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  my_u64 := HashString63Bits('toto est fort');
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  my_u64 := HashString63Bits('toto est bleu');
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  my_u64 := HashString63Bits('toto est rouge');
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));
  WritelnDansRapport('');

  my_u64 := HashString63Bits('toto est vert');
  WritelnDansRapport(UInt64ToHexa(my_u64));
  WritelnDansRapport(UInt64ToHexa(HexToInt(UInt64ToHexa(my_u64))));
  WritelnStringAndBoolDansRapport('negatif ? ', HashValueDuZooEstNegative(my_u64));
  WritelnStringAndBoolDansRapport('correcte ? ', HashValueDuZooEstCorrecte(my_u64));

  s := '2241920287009';
  my_double := StringSimpleEnReel(s);
  WritelnDansRapport('');
  WritelnDansRapport('s est la chaine : ' + s);
  WritelnStringAndReelDansRapport('s traduit en reel vaut ', my_double, 20);

  s := '.512345678901';
  my_double := StringSimpleEnReel(s);
  WritelnDansRapport('');
  WritelnDansRapport('s est la chaine : ' + s);
  WritelnStringAndReelDansRapport('s traduit en reel vaut ', my_double, 14);

  s := '12';
  my_double := StringSimpleEnReel(s);
  WritelnDansRapport('');
  WritelnDansRapport('s est la chaine : ' + s);
  WritelnStringAndReelDansRapport('s traduit en reel vaut ', my_double, 0);
end;


{**********************************************************************************************}
{************************************** initialisation ****************************************}
{**********************************************************************************************}

procedure Initialisation;
var i,j : SInt16;
    s : String255;
    a,b : SInt16;
    textureAChange : boolean;
    err : OSErr;
    ignorePattern : PatternPtr;
    // myFontID : SInt32;
begin

  gPartieOuvertePendantLesInitialisationsDeCassio := '';

  SetCassioChecksEvents(true);
  SetInverserLesCouleursDuCurseur(false);

  windowPlateauOpen := false;
  windowCourbeOpen := false;
  windowAideOpen := false;
  windowGestionOpen := false;
  windowNuageOpen := false;
  windowReflexOpen := false;
  windowListeOpen := false;
  windowStatOpen := false;
  windowPaletteOpen := true;
  windowRapportOpen := false;
  arbreDeJeu.windowOpen := false;
  wPlateauPtr := NIL;
  wCourbePtr := NIL;
  wAidePtr := NIL;
  wGestionPtr := NIL;
  wNuagePtr := NIL;
  wReflexPtr := NIL;
  wListePtr := NIL;
  wStatPtr := NIL;
  wPalettePtr := NIL;
  arbreDeJeu.theDialog := NIL;
  with VisibiliteInitiale do
    begin
      ordreOuvertureDesFenetres := 'ORSLKPGCT';
      tempowindowPaletteOpen := windowPaletteOpen;
      tempowindowCourbeOpen := windowCourbeOpen;
      tempowindowAideOpen := windowAideOpen;
      tempowindowGestionOpen := windowGestionOpen;
      tempowindowNuageOpen := windowNuageOpen;
      tempowindowReflexOpen := windowReflexOpen;
      tempowindowListeOpen := windowListeOpen;
      tempowindowStatOpen := windowStatOpen;
      tempowindowRapportOpen := windowRapportOpen;
      tempowindowCommentairesOpen := arbreDeJeu.windowOpen;
    end;




  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Entrée initialisation');



  with gPoliceNumeroCoup do
    begin
      if (EpsiSansID <> 0) then
        begin
          policeID     := EpsiSansID;
          petiteTaille := 10;
          grandeTaille := 12;
          theStyle     := bold;
        end else
      if (TimesID <> 0) then
        begin
          policeID     := TimesID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (SymbolID <> 0) then
        begin
          policeID     := SymbolID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (TrebuchetMSID <> 0) then
        begin
          policeID     := TrebuchetMSID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
      if (NewYorkID <> 0) then
        begin
          policeID     := NewYorkID;
          petiteTaille := 10;
          grandeTaille := 12;
          theStyle     := bold;
        end else
      if (TimesNewRomanID <> 0) then
        begin
          policeID     := TimesNewRomanID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end else
     {if (PalatinoID <> 0) then}
        begin
          policeID     := PalatinoID;
          petiteTaille := 12;
          grandeTaille := 14;
          theStyle     := bold;
        end;
    end;

  err := InitialiseQuartzAntiAliasing;

  if gIsRunningUnderMacOSX
    then themeCourantDeCassio := kThemeGillSans
    else themeCourantDeCassio := kThemeMacOS9;

  DoitEcrireInterversions := false;
  avecProgrammation := false;
  UneSeuleBase := true;
  inBackGround := false;



  SetCassioChecksEvents(true);
  SetNiveauTeteDeMort(0);
  SetCassioEstEnBenchmarkDeMilieu(false);
  SetCassioEstEnTrainDeReflechir(false,NIL);
  SetGenreDerniereReflexionDeCassio(ReflPasDeDonnees,0);
  Initialise_turbulence_bords(true);


  fntrPlateauOuverteUneFois := false;
  CriteresRubanModifies := false;
  DejaFormatImpression := false;
  avecNomOuvertures := true;
  neJamaisTomber := false;
  LaDemoApprend := false;
  SetAvecAffichageNotesSurCases(kNotesDeCassio,true);
  SetAvecAffichageNotesSurCases(kNotesDeZebra,true);
  doitEffacerSousLesTextesSurOthellier := false;


  with gEntrainementOuvertures do
    begin
      CassioVarieSesCoups := false;
      CassioSeContenteDeLaNulle := false;
      modeVariation := kVarierEnUtilisantMilieu;
      varierJusquaCeNumeroDeCoup := 20;
      varierJusquaCetteCadence := minutes3;
      for i := 0 to 64 do
        deltaNotePerduCeCoup[i] := 0;
      deltaNoteAutoriseParCoup := 300;  {4 pions}
      deltaNotePerduAuTotal := 0;
      profondeurRechercheVariations := 11;
      ViderListOfMoveRecords(classementVariations);
      derniereProfCompleteMilieuDePartie := 0;
    end;


  avecFlecheProchainCoupDansGraphe := true;
  SupprimerLesEffetsDeZoom := true;
  OptimisePourKaleidoscope := true;
  NePasUtiliserLeGrasFenetreOthellier := false;
  doitAjusterCurseur := true;
  gEnRechercheSolitaire := false;
  gEnEntreeSortieLongueSurLeDisque := false;



  SousCriteresRuban[TournoiRubanBox] := NIL;
  SousCriteresRuban[JoueurNoirRubanBox] := NIL;
  SousCriteresRuban[JoueurBlancRubanBox] := NIL;
  SousCriteresRuban[DistributionRubanBox] := NIL;

  arbreDeJeu.enModeEdition           := false;
  arbreDeJeu.doitResterEnModeEdition := false;
  arbreDeJeu.EditionRect             := MakeRect(0,0,0,0);
  arbreDeJeu.backMoveRect            := MakeRect(-1,-1,536,16);
  arbreDeJeu.positionLigneSeparation := 100;
  arbreDeJeu.hauteurRuban            := 0;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant TrapExists');


  gAppleEventsInitialized := false;
  PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);




  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant DetermineVolumeApplication');


  VolumeRefThorDBA := -100;
  VolumeRefThorDBASolitaire := -100;


  dernierePartieExtraiteThor := 1;
  dernierePartieExtraiteWThor.numFichier := 1;
  dernierePartieExtraiteWThor.numPartie := 1;
  indexSolitaire := -57;  {ou n'importe quel nombre  <= -1}

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant GetWDName(VolumeRefThorDBASolitaire)');

  s := GetWDName(VolumeRefThorDBASolitaire);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant CheminAccesThorDBASolitaire^^ := …');

  CheminAccesThorDBASolitaire^^ := s+'Solitaires.dba';
  CheminAccesSolitaireCassio^^ := s+'Solitaires Cassio';
  CheminAccesThorDBA^^ := s+'Thor.dba';

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant s := ReadStringFromRessource(TextesListeID,12)');

  s := ReadStringFromRessource(TextesListeID,12);
  CaracterePourNoir := s;
  s := ReadStringFromRessource(TextesListeID,13);
  CaracterePourBlanc := s;
  s := ReadStringFromRessource(TextesListeID,14);
  CaracterePourEgalite := s;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant WindowsHaveThickBorders');

  gWindowsHaveThickBorders := WindowsHaveThickBorders(gEpaisseurBorduresFenetres);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant ProfondeurMainDevice');

  if gHasColorQuickDraw
    then gEcranCouleur := (ProfondeurMainDevice > 2)
    else gEcranCouleur := false;
  gBlackAndWhite := not(gEcranCouleur);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant CalculeCouleurRecord');

  gCouleurOthellier := CalculeCouleurRecord(CouleurID,VertPaleCmd);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant Picture3DID');

  gLastTexture3D.theMenu  := Picture3DID;
  gLastTexture3D.theCmd := 1;
  gLastTexture2D.theMenu  := gCouleurOthellier.menuID;
  gLastTexture2D.theCmd := gCouleurOthellier.menuCmd;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant PionInversePat');

  ignorePattern := GetQDGlobalsDarkGray(darkGrayPattern);
  ignorePattern := GetQDGlobalsLightGray(lightGrayPattern);
  ignorePattern := GetQDGlobalsGray(grayPattern);
  ignorePattern := GetQDGlobalsBlack(blackPattern);
  ignorePattern := GetQDGlobalsWhite(whitePattern);

  PionInversePat := grayPattern;
  for i := 0 to 7 do InversePionInversePat.pat[i] := 255-PionInversePat.pat[i];

  watch := GetCursor(watchcursor);
  iBeam := GetCursor(iBeamCursor);
  interversionCurseur := GetCursor(interversionCursorID);
  parcheminCurseur := GetCursor(parcheminCursorID);
  teteDeMortCurseur := GetCursor(teteDeMortCursorID);
  pionNoirCurseur := GetCursor(pionNoirCurseurID);
  pionBlancCurseur := GetCursor(pionBlancCurseurID);
  gommeCurseur := GetCursor(gommeCurseurID);
  backMoveCurseur := GetCursor(backMoveCurseurID);
  //avanceMoveCurseur := GetCursor(avanceMoveCurseurID);
  avanceMoveCurseur := GetCursor(interversionCursorID);
  DragLineVerticalCurseur := GetCursor(DragLineVerticalCurseurID);
  DragLineHorizontalCurseur := GetCursor(DragLineHorizontalCurseurID);



  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant Ecranrect');

  tailleFenetrePlateauAvantPassageEn3D := 0;
  Ecranrect := GetScreenBounds;
  {Ecranrect.right := 512;
  Ecranrect.bottom := 342;}
  genreAffichageTextesDansFenetrePlateau := kAffichageAere;
  nbColonnesFenetreListe := kAvecAffichageTournois;
  SetValeursStandardRubanListe(nbColonnesFenetreListe);
  SetCassioEstEnTrainDePlaquerUnSolitaire(false);
  SetCalculDesScoresTheoriquesDeLaBaseEnCours(false, NIL);
  SetPositionInitialeStandardDansJeuCourant;
  gameOver := false;
  avecAleatoire := true;
  fond := blackPattern;
  FntrFelicitationTopLeft.h := 300;
  FntrFelicitationTopLeft.v := 100;
  AuMoinsUneFelicitation := false;
  gNbreMegaoctetsPourLaBase := 20;


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant SetValeursParDefautDiagFFORUM');

  SetValeursParDefautDiagFFORUM(ParamDiagCourant,DiagrammePosition);
  SetValeursParDefautDiagFFORUM(ParamDiagPositionFFORUM,DiagrammePosition);
  SetValeursParDefautDiagFFORUM(ParamDiagPartieFFORUM,DiagrammePartie);
  SetValeursParDefautDiagFFORUM(ParamDiagImpr,DiagrammePourListe);
  SetDiagrammeDoitCreerVersionEPS(false);
  TypeDerniereDestructionDemandee := kDetruireCeNoeudEtFils;
  derniereLigneUtiliseeMenuFlottantDelta := 12;  {une ligne vide vers le milieu du menu}
  SetCalculs3DMocheSontFaits(false);
  profSupUn := false;
  nbAlertesPositionFeerique := 0;
  nbInformationMemoire := 0;
  numeroPuce := 0;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant HauteurChaqueLigneDansListe');

  if gVersionJaponaiseDeCassio and gHasJapaneseScript
    then HauteurChaqueLigneDansListe := 14
    else HauteurChaqueLigneDansListe := 12;

  dernierTick := TickCount;
  delaiAvantDoSystemTask := 60;
  latenceEntreDeuxDoSystemTask := 2;
  profMinimalePourTriDesCoups := 3;
  profMinimalePourTriDesCoupsParAlphaBeta := 7;
  SommeNbEvaluationsRecursives := 0;
  MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
  ReInitialisePartieHdlPourNouvellePartie(true);
  SetRect(aireDeJeu,0,0,0,0);
  SetRect(FntrPlatRect,4,41,580,433);
  SetRect(FntrCourbeRect,340,120,630,270);
  SetRect(FntrReflexRect,395,108,545,236);
  SetRect(FntrAideRect,100,100,634,476);
  SetRect(FntrGestionRect,330,248,508,328);
  SetRect(FntrNuageRect,230,248,608,528);
  a := Ecranrect.right;
  b := Ecranrect.bottom;
  if a > 637 then a := 637;
  if b > 405 then b := 405;
  SetRect(FntrListeRect,a-LargeurNormaleFenetreListe(nbColonnesFenetreListe)+1,45,a,b-145);

  with FntrListeRect do
    bottom := bottom - (bottom-top) mod 12 +2;
  SetRect(FntrStatRect,a-251,b-121,a,b-1);
  SetRect(FntrPaletteRect,395,362,395+9*largeurCasePalette,362+2*hauteurCasePalette);
  SetRect(FntrRapportRect,252,122,595,342);
  SetRect(FntrCommentairesRect,385,130,585,330);
  SetRect(FntrCadenceRect,0,0,0,0);
  with iconisationDeCassio do
    begin
      (*
      if gIsRunningUnderMacOSX or gWindowsHaveThickBorders
        then LargeurFenetreIconisation := 89
        else LargeurFenetreIconisation := 93;
      *)

      LargeurFenetreIconisation := 89;

      SetRect(iconisationDeCassio.IconisationRect,10,50,10+LargeurFenetreIconisation,50+LargeurFenetreIconisation);
    end;
  SetRect(CloseZoomRectFrom,-13333,-13333,-13333,-13333);
  SetRect(CloseZoomRectTo,-13333,-13333,-13333,-13333);
  globalRefreshNeeded := false;
  gPourcentageTailleDesPions := 94;
  avecLisereNoirSurPionsBlancs := true;
  avecOmbrageDesPions := true;


  ViderNotesSurCases(kNotesDeCassioEtZebra,false,othellierToutEntier);
  SetRestrictedAreaDessinPierreDelta(othellierToutEntier);
  dernierTick := TickCount;
  SetValeursGestionTemps(0,0,0,0.0,0,0);
  ReinitilaliseInfosAffichageReflexion;
  SetPotentielsOptimums(PositionEtTraitInitiauxStandard);
  if avecAleatoire
    then RandomizeTimer
    else SetRandomSeed(1000);
  JoueursEtTournoisEnMemoire := false;
  ToujoursIndexerBase := true;
  nbPartiesActives := 0;
  nbPartiesChargees := 0;
  nbreCoupsApresLecture := 0;
  with infosListeParties do
    begin
      partieHilitee := 1;
      dernierNroReferenceHilitee := 0;
      clicHilite := 0;
      justificationPasDePartie := -1;
    end;
  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
  InitInfosFermetureListePartie(infosListePartiesDerniereFermeture);
  avecInterversions := true;
  OrdreDuTriRenverse := false;
  genreDeTestPourAnnee := testEgalite;
  gGenreDeTriListe := TriParDate;
  DernierCritereDeTriListeParJoueur := TriParJoueurNoir;
  sousEmulatorSousPC := false;
  avecAlerteNouvInterversion := false;
  numeroCoupMaxPourRechercheIntervesionDansArbre := 40;
  PassesDejaExpliques := 0;
  nbExplicationsPasses := 3;
  ListeDesGroupesModifiee := false;
  listeEtroiteEtNomsCourts := false;
  SetPremierCoupParDefaut(43);

  Yannonc := 1;
  Quitter := false;
  enSetUp := false;
  enRetour := false;
  analyseRetrograde.enCours := false;
  analyseRetrograde.genreAnalyseEnCours := PasAnalyseRetrograde;
  analyseRetrograde.genreDerniereAmeliorationCherchee := PasAnalyseRetrograde;
  analyseRetrograde.tempsDernierCoupAnalyse := 0;
  couleurMacintosh := pionBlanc;
  SetPositionInitialeStandardDansJeuCourant;
  CoefficientsStandard;
  withUserCoeffDansNouvelleEval := true;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant avecSon');

  avecSon := true;
  avecSonPourPosePion := true;
  avecSonPourRetournePion := true;
  avecSonPourGameOver := true;
  sonPourPosePion := kSonTickID;
  sonPourRetournePion := kSonTockID;
  SetEnVieille3D(false);
  HumCtreHum := false;
  afficheBibl := false;
  with debuggage do
    begin
      general := false;
      entreesSortiesUnitFichiersTEXT := false;
      pendantLectureBase := false;
      {afficheSuiteInitialisations := true;}  {valeur deja mise au tout debut! }
      evenementsDansRapport := false;
      elementsStrategiques := false;
      gestionDuTemps := false;
      calculFinaleOptimaleParOptimalite := false;
      arbreDeJeu := false;
      lectureSmartGameBoard := false;
      apprentissage := false;
      algoDeFinale := false;
      MacOSX := false;
    end;
  with affichageReflexion do
    begin
      doitAfficher := false;
      demandeEnSuspend := false;
      tickDernierAffichageReflexion := 0;
      afficherToutesLesPasses := false;
      SetDemandeAffichageReflexionEnSuspens(false);
      SetRedirigerContenuFntreReflexionDansRapport(false);
    end;
  afficheNumeroCoup := true;
  afficheSuggestionDeCassio := false;
  afficheGestionTemps := false;
  afficheNuage := false;
  afficheMeilleureSuite := false;
  affichePierresDelta := false;
  afficheProchainsCoups := false;
  afficheSignesDiacritiques := false;
  avecGagnantEnGrasDansListe := true;
  avecEvaluationTotale := false;
  evaluationAleatoire := false;
  avecEvaluationDeFisher := false;
  avecEvaluationTablesDeCoins := true;
  EnTraitementDeTexte := false;
  analyseIntegraleDeFinale := false;
  doitEcrireReflexFinale := true;
  BoiteDeSousCritereActive := 0;
  for i := TournoiRubanBox to DistributionRubanBox do
    sousCritereMustBeAPerfectMatch[i] := false;
  PostscriptCompatibleXPress := true;
  avecAB_Constr := false;
  SetEffetSpecial(false);
  effetspecial2 := false;
  effetspecial3 := false;
  effetspecial4 := false;
  effetspecial5 := false;
  effetspecial6 := false;
  afficheInfosApprentissage := false;
  UtiliseGrapheApprentissage := false;
  enModeIOS := false;
  chainePourIOS := '';
  avecBibl := true;
  avecTestBibliotheque := false;
  JoueBonsCoupsBibl := false;
  sansReflexionSurTempsAdverse := false;
 (* avecDessinCoupEnTete := false; *)
  SensLargeSolitaire := true;
  finaleEnModeSolitaire := false;
  ecrireDansRapportLog := false;
  InfosTechniquesDansRapport := false;
  referencesCompletes := true;
  nbCasesVidesMinSolitaire := 2;
  nbCasesVidesMaxSolitaire := 64;
  for i := 1 to 64 do SolitairesDemandes[i] := false;
  for i := 6 to 18 do SolitairesDemandes[i] := true;
  eviterSolitairesOrdinateursSVP := false;
  PionClignotant := false;
  retirerEffet3DSubtilOthellier2D := false;
  avecSystemeCoordonnees := true;
  garderPartieNoireADroiteOthellier := true;
  avecGestionBase := true;
  LectureAntichronologique := false;
  sousSelectionActive := false;
  avecCalculPartiesActives := true;
  avecSauvegardePref := true;
  traductionMoisTournoi := MoisEnToutesLettres;
  CassioUtiliseDesMajuscules := true;
  differencierLesFreres := false;
  avecSelectivite := false;
  discretisationEvaluationEstOK := false;
  utilisateurVeutDiscretiserEvaluation := true;
  seMefierDesScoresDeLArbre := false;
  avecRecursiviteDansEval := true;
  peutDebrancherRecursiviteDansEval := true;
  doitConfirmerQuitter := true;
  analyseRetrograde.doitConfirmerArret := true;
  analyseRetrograde.nbMinPourConfirmationArret := 10;
  analyseRetrograde.nbPresentationsDialogue := 0;
  prefVersion40b11Enregistrees := false;
  nbCoupsEnTete := 1;
  valeurApprondissementIteratif := 2;
  SetTailleOthelloPourDiagrammeFForum(8,8); {par defaut les diagrammes pour Fforum seront en 8x8 }


  enTournoi            := false;           { à true, organise un match en demo }
  SetProfImposee(false,'initialisation');
  level                := 5;               { utile seulement si profimposee = true}
  decrementetemps      := true;
  jeuInstantane        := true;
  SetCadence(minutes3);
  SetCadenceAutreQueAnalyse(GetCadence,jeuInstantane);
  cadencePersoAffichee := GetCadence;
  NiveauJeuInstantane  := NiveauGrandMaitres;
  avecAjustementAutomatiqueDuNiveau := true;
  humanWinningStreak   := 0;
  humanScoreLastLevel  := 0;
  typeEvalEnCours      := EVAL_EDMOND;
  typeEvalDemandeeDansLesPreferences := EVAL_EDMOND;

  LecturePreparatoireDossierEngines(pathCassioFolder);


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant LitFichierPreferences');

  (********************************************************************************************)
  (********************************************************************************************)

  LitFichierPreferences;
  avecSauvegardePrefArrivee := avecSauvegardePref;
  typeEvalDemandeeDansLesPreferences := typeEvalEnCours;

  (********************************************************************************************)
  (********************************************************************************************)

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant VisibiliteInitiale');

  with VisibiliteInitiale do
    begin
      tempowindowPaletteOpen := windowPaletteOpen;
      tempowindowCourbeOpen := windowCourbeOpen;
      tempowindowAideOpen := windowAideOpen;
      tempowindowGestionOpen := windowGestionOpen;
      tempowindowNuageOpen := windowNuageOpen;
      tempowindowReflexOpen := windowReflexOpen;
      tempowindowListeOpen := windowListeOpen;
      tempowindowStatOpen := windowStatOpen;
      tempowindowRapportOpen := windowRapportOpen;
      tempowindowCommentairesOpen := arbreDeJeu.windowOpen;
    end;
  windowPaletteOpen := false;
  windowCourbeOpen := false;
  windowAideOpen := false;
  windowGestionOpen := false;
  windowNuageOpen := false;
  windowReflexOpen := false;
  windowListeOpen := false;
  windowStatOpen := false;
  windowRapportOpen := false;
  arbreDeJeu.windowOpen := false;


  SetUpMenuBar;

  SelectCassioFonts(themeCourantDeCassio);

  LecturePreparatoireDossierOthelliers(pathCassioFolder);


  DernierCoupPourMenuAff := 56;
  if nbCoupsEnTete > 1
    then MySetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,17),IntToStr(nbCoupsEnTete),'','',''))
    else MySetMenuItemText(ModeMenu,MilieuDeJeuNMeilleursCoupscmd,ReadStringFromRessource(MenusChangeantsID,18));
  if gVersionJaponaiseDeCassio and gHasJapaneseScript then
    NePasUtiliserLeGrasFenetreOthellier := true;  {on forcer cela}

  AjusteCadenceMin(GetCadence);
 (*SetCoupEntete(-100);*)
  gBlackAndWhite := not(gEcranCouleur);

  (* New in Cassio 7.6 : les valeurs et les couleurs de zebra dans l'arbre vont toujours de pair *)
  if ZebraBookACetteOption(kAfficherNotesZebraDansArbre) or
     ZebraBookACetteOption(kAfficherCouleursZebraDansArbre) then
    begin
      RetirerZebraBookOption(kAfficherNotesZebraDansArbre);
      RetirerZebraBookOption(kAfficherCouleursZebraDansArbre);
      AjouterZebraBookOption(kAfficherNotesZebraDansArbre);
      AjouterZebraBookOption(kAfficherCouleursZebraDansArbre);
    end;
  CheckValidityOfCouleurRecord(gCouleurOthellier,textureAChange);
  gCouleurOthellier := CalculeCouleurRecord(gCouleurOthellier.menuID,gCouleurOthellier.menuCmd);
  if EnJolie3D then
    begin
      err := LitFichierCoordoneesImages3D(gCouleurOthellier);
      if err = NoErr then err := CreatePovOffScreenWorld(gCouleurOthellier);
      if err <> NoErr then
        begin
          KillPovOffScreenWorld;
          gCouleurOthellier := CalculeCouleurRecord(gLastTexture2D.theMenu,gLastTexture2D.theCmd);
        end;
    end;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('  initialisation : avant VideHashTable');

  InitTablesHashageOthello;



  paramDiagCourant.titreFFORUM^^ := '';
  paramDiagCourant.CommentPositionFFORUM^^ := '';
  paramDiagPositionFFORUM.titreFFORUM^^ := '';
  paramDiagPositionFFORUM.CommentPositionFFORUM^^ := '';
  paramDiagPartieFFORUM.titreFFORUM^^ := '';
  paramDiagPartieFFORUM.CommentPositionFFORUM^^ := '';
  paramDiagImpr.titreFFORUM^^ := '';
  paramDiagImpr.CommentPositionFFORUM^^ := '';
  PageImpr.TitreImpression^^ := '';
  PageImpr.QuoiImprimer := ImprimerPosition;
  PageImpr.FontSizeTitre := 14;
  PageImpr.MargeTitre := 20;
  PageImpr.NumeroterPagesImpr := true;
  titrePartie^^ := '';
  for j := 1 to NbMaxItemsReouvrirMenu do
    if (nomLongDuFichierAReouvrir[j] <> NIL) then nomDuFichierAReouvrir[j]^^ := '';
  VolRefPourReouvrir := 0;
  CommentaireSolitaire^^ := '';
  SetMeilleureSuite('');
  MeilleureSuiteEffacee := true;
  DerniereChaineComplementation^^ := '@andµôπ¶«Ç‘';
  TypeDerniereComplementation := 0;


  with DemandeCalculsPourBase do
    begin
      magicCookie := 0;
      NumeroDuCoupDeLaDemande := 0;
      EtatDesCalculs := kCalculsTermines;
      NiveauRecursionCalculsEtAffichagePourBase := 0;
      PhaseDecroissanceRecursion := false;
    end;


  interruptionReflexion := pasdinterruption;
  gDoitJouerMeilleureReponse := false;
  DerniereActionBaseEffectuee := 0;
  Superviseur(0);
  with InfosDerniereReflexionMac do
    begin
      nroDuCoup  := -1;
      coup       := 0;
      def        := 0;
      coul       := pionVide;
      valeurCoup := -noteMax;
      prof       := 0;
    end;

  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant Initialise_IndexInfoDejaCalculees');

  Initialise_IndexInfoDejaCalculees;




  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant WaitNextEvent');


  {on donne une chance aux autres applications de faire des update events}
  {FlushEvents(everyEvent-DiskEvt,0);}
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);
  ShareTimeWithOtherProcesses(1);



  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant Initialise_valeurs_tactiques');

  Initialise_valeurs_tactiques;
  dernierTick := TickCount;
  MemoryFillChar(@tempsDesJoueurs,sizeof(tempsDesJoueurs),chr(0));
  nbreDePions[pionBlanc] := 0;
  nbreDePions[pionNoir] := 0;



  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant OuvreFntrPlateau');


  OuvreFntrPlateau(false);

  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant PrepareNouvellePartie');


  PrepareNouvellePartie(false);

  LanceInterruptionSimple('initialisation');


  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant Ouverture des fenetres');


  OuvrirLesFenetresDansLOrdre;



  NoUpdateWindowPlateau;
  PrepareNouvellePartie(false);
  if (traductionMoisTournoi < 1) or (traductionMoisTournoi > 3)
    then traductionMoisTournoi := SucrerPurementEtSimplement;
  dernierTick := TickCount;

  EffaceReflexion(true);


  EssaieUpdateEventsWindowPlateau;

  if WaitNextEvent(0,theEvent,2,NIL) then TraiteOneEvenement;


  {sur Mac Classic, on borne le nombre de parties chargeables par la mémoire donnée
   par le Finder (et ce nombre a deja ete calcule dans UnitNewGeneral) }

  if gNbreMegaoctetsPourLaBase <= 0 then gNbreMegaoctetsPourLaBase := 1;
  if gIsRunningUnderMacOSX
    then ChangeNbPartiesChargeablesPourBase(CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024))
    else ChangeNbPartiesChargeablesPourBase(Min(nbrePartiesEnMemoire,CalculeNbrePartiesOptimum(gNbreMegaoctetsPourLaBase*1024*1024)));


  if debuggage.afficheSuiteInitialisations then
    StoppeEtAffichePourDebugage('  initialisation : avant LitBibliotheque');

  bibliothequeLisible := false;
  if LitBibliotheque('bibliothèque Cassio',avecTestBibliotheque) <> NoErr then DoNothing;

  EssaieUpdateEventsWindowPlateau;



  SetPositionInitialeStandardDansJeuCourant;
  doitAjusterCurseur := true;
  AjusteCurseur;
  if HasGotEvent(everyEvent,theEvent,0,NIL) then
     TraiteOneEvenement;



  EnableItemTousMenus;
  EssaieDisableForceCmd;
  MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
  MyDisableItem(BaseMenu,JouerSelectionneCmd);
  MyDisableItem(BaseMenu,JouerMajoritaireCmd);




  if GetAvecAffichageNotesSurCases(kNotesDeCassio) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) = 0)
     then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode + kNotesCassioSurLesCases);

  if not(GetAvecAffichageNotesSurCases(kNotesDeCassio)) and (BAND(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) <> 0)
    then SetAffichageProprietesOfCurrentNode(GetAffichageProprietesOfCurrentNode - kNotesCassioSurLesCases);


  AjusteCurseur;

  FixeMarquesSurMenus;
  SetStatistiquesSontEcritesDansLaFenetreNormale(true);

  finDePartieVitesseMac := 41;           {valeur par defaut}
  finDePartieOptimaleVitesseMac := 43;   {valeur par defaut}

  DisableKeyboardScriptSwitch;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant GetPartiesAReouvrirFromPrefsFile');
  GetPartiesAReouvrirFromPrefsFile;


  indiceVitesseMac := CalculVitesseMac(false);
  EtalonnageVitesseMac(false);
  DetermineMomentFinDePartie;


  if InitUnitIconisationOK
    then
      begin
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant MyEnableItem');
        MyEnableItem(GetFileMenu,IconisationCmd)
      end
    else
      begin
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant MyDisableItem');
        MyDisableItem(GetFileMenu,IconisationCmd);
        if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlerteSimple');
        AlerteSimple('Iconisation impossible !! Prévenez Stéphane');
      end;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant EnableItemTousMenus');

  EnableItemTousMenus;
  FixeMarquesSurMenus;
  FixeMarqueSurMenuBase;
  FixeMarqueSurMenuMode(nbreCoup);
  SetMenusChangeant(0);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant LitFichierGroupes');

  LitFichierGroupes;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant LoadZebraBook');

  LoadZebraBook(true);

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('apres LoadZebraBook');


  (*
  if FichierTexteDeCassioExiste('Fonts:Virginie.ttf', fontFic) = NoErr
    then
      begin
        WritelnDansRapport('police Virginie trouvee');
        LoadFont(fontFic.info);
      end;
  *)


  // This will force Cassio to copy its private fonts to ~/Library/Fonts/
  // myFontID := GetCassioFontNum('aaaaaaa-$and@%$!§');



end;  {Initialisation}




(****************  UnLoad tous les segments  ********)


procedure UnLoadTousSegments;
begin

  InstalleEventHandler(TraiteOneEvenement);
  InstalleEssaieUpdateEventsWindowPlateauProc(EssaieUpdateEventsWindowPlateau);
end;



(************ boucle principale **************)



procedure BouclePrincipale;
var config : ConfigurationCassioRec;
    typeDeCalculALancer : SInt32;
begin

  {FlushEvents(everyEvent-DiskEvt,0);}
  REPEAT
    SetCassioChecksEvents(true);
    if globalRefreshNeeded then DoGlobalRefresh;
    if not(Quitter) then AjusteCurseur;

    AjusteSleep;
    if not(Quitter) then
      if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

    if not(Quitter or enSetUp or enRetour) then
      if (FrontWindow = NIL) then
          begin
            DisableMenu(EditionMenu,[AnnulerCmd,CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
            EnableItemPourCassio(GetFileMenu,NouvellePartieCmd);
            MyDisableItem(GetFileMenu,CloseCmd);
          end
        else
          begin
            if not(enSetUp)
              then EnableItemPourCassio(GetFileMenu,CloseCmd)
              else MyDisableItem(GetFileMenu,CloseCmd);
            if not(iconisationDeCassio.Encours) then
              EnableMenu(EditionMenu,[CouperCmd,CopierCmd,CopierSpecialCmd,CollerCmd,EffacerCmd]);
          end;
    if not(Quitter) then UnLoadTousSegments;
    SetCassioChecksEvents(true);
    if not(Quitter) then
      if HasGotEvent(everyEvent,theEvent,kWNESleep,NIL)
        then TraiteEvenements
        else TraiteNullEvent(theEvent);

    VerifierLeStatutDeCassioPourLeZoo;

    if not(Quitter) then UnLoadTousSegments;
    if not(Quitter) then
      if interruptionReflexion <> pasdinterruption then
         EffectueTacheInterrompante(interruptionReflexion);

    if (DemandeCalculsPourBase.EtatDesCalculs = kCalculsDemandes) and not(CassioVaJouerInstantanement)
      then TraiteDemandeCalculsPourBase('BouclePrincipale (1)');

    if gDemandeAffichageZebraBook.enAttente
      then TraiteDemandeAffichageZebraBook;

    UpdateConfigurationDeCassio;


    GetConfigurationCouranteDeCassio(config);

    typedeCalculALancer := TypeDeCalculLanceParCassioDansCetteConfiguration(config);

    VerifierLeStatutDeCassioPourLeZoo;

    if (typedeCalculALancer = k_PREMIER_COUP_MAC) or (typedeCalculALancer = k_JEU_MAC)  then
       begin
         if typedeCalculALancer = k_PREMIER_COUP_MAC then PremierCoupMac;
         if typedeCalculALancer = k_JEU_MAC then JeuMac(level,'BouclePrincipale');
         if (interruptionReflexion <> pasdinterruption) and not(Quitter)
            then EffectueTacheInterrompante(interruptionReflexion);
         vaDepasserTemps := false;
       end;

    if (interruptionReflexion <> pasdinterruption) and not(Quitter) then
      EffectueTacheInterrompante(interruptionReflexion);

    GererDemandeInterruptionBrutaleEnCours;

    GererDemandesChangementDeConfig;

    CheckStreamEvents;

    GererLeZoo;

    GererTelechargementWThor;

    GererRapportSafe;

    GerePrefetchingOfZebraBook;

  UNTIL Quitter;

  SetCassioChecksEvents(true);
end;




procedure Ecrit_taille_structures;
type t_buffer = packed array[1..260] of t_Octet;
begin
  EssaieSetPortWindowPlateau;
  WriteNumAt('sizeof(t_octet) = ',sizeof(t_octet),10,10);
  WriteNumAt('sizeof(DeuxOctets) = ',sizeof(DeuxOctets),10,20);
  WriteNumAt('sizeof(t_buffer) = ',sizeof(t_buffer),10,30);
  WriteNumAt('sizeof(t_partieDansThorDBA) = ',sizeof(t_partieDansThorDBA),10,40);

  AttendFrappeClavier;
end;

procedure DessinePaletteDeCouleurs;
var i,j : SInt16;
    coul : array[1..8] of SInt16;
begin
  EssaieSetPortWindowPlateau;

  gCouleurOthellier.whichPattern := grayPattern;
  coul[1] := MagentaColor;
  coul[2] := RedColor;
  coul[3] := YellowColor;
  coul[4] := GreenColor;
  coul[5] := CyanColor;
  coul[6] := BlueColor;
  coul[7] := blackColor;
  coul[8] := WhiteColor;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        gCouleurOthellier.couleurFront := coul[i];
        gCouleurOthellier.couleurBack := coul[j];
        DessinePion2D(10*i+j,pionVide);
      end;
  DetermineFrontAndBackColor(gCouleurOthellier.menuCmd,gCouleurOthellier.couleurFront,gCouleurOthellier.couleurBack);
end;


procedure TesterConvergenceDesFlottants;
 var u : double;
     n : SInt32;
 begin
   n := 0;

   u := 3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+IntToStr(n)+' = ',u, 14);
       u := -3.0*u*u/8.0 + 9.0*u/4.0 - 3.0/8.0;
     end;

   u := 1.0/3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+IntToStr(n)+' = ',u, 14);
       u := -3.0*u*u/8.0 + 9.0*u/4.0 - 3.0/8.0;
     end;

  u := 3.0;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+IntToStr(n)+' = ',u, 14);
       u := -4.0*u*u/9.0 + 26.0*u/9.0 - 4.0/9.0;
     end;

   u := 1.0/3.1;
   for n := 0 to 100 do
     begin
       WritelnStringAndReelDansRapport('u'+IntToStr(n)+' = ',u, 14);
       u := -4.0*u*u/9.0 + 26.0*u/9.0 - 4.0/9.0;
     end;

 end;

procedure TesterChampionnatMathematique;
var x,n,a,b,c,d,e,f,i,sum : SInt32;
    chiffre : array[0..9] of SInt32;
begin
  for x := 234567 to 765432 do
    begin

      n := x;

      f := n mod 10;
      n := (n - f) div 10;

      e := n mod 10;
      n := (n - e) div 10;

      d := n mod 10;
      n := (n - d) div 10;

      c := n mod 10;
      n := (n - c) div 10;

      b := n mod 10;
      n := (n - b) div 10;

      a := n mod 10;

    //  ASSERT( (n = a) )

      if ( (100*a + 10*b + c) * (100*d + 10*e + f) = (10*a + d) * (10*b + e) * (10*c + f)) then
        begin

          for i := 0 to 9 do
            chiffre[i] := 0;

          chiffre[a] := 1;
          chiffre[b] := 1;
          chiffre[c] := 1;
          chiffre[d] := 1;
          chiffre[e] := 1;
          chiffre[f] := 1;

          sum := 0;

          for i := 2 to 7 do
            sum := sum + chiffre[i];


          if (sum = 6) then
            WritelnNumDansRapport('Solution   abcdef = ',x);

        end;

    end;

  WritelnDansRapport('termine');
end;


procedure TesterLesManipulationsDeBoucle;
var k : SInt32;
begin

  for k := 1 to 10 do
    begin
      if k = 3 then leave;
      WritelnNumDansRapport('k = ',k);
    end;

  for k := 1 to 10 do
    begin
      if k = 3 then cycle;
      WritelnNumDansRapport('k = ',k);
    end;


end;




procedure MainDeCassio;
var i_main, gestalt_aux, i_main2 : SInt32;
    erreurES_main : OSErr;
    OSStatus_main : OSStatus;
    microTime : UnsignedWide;
    tickDebutInitialisations : SInt32;
    confiance : double;
    s, s1 : String255;
    s_main : String255;
    long_s : LongString;
    {thePos : PositionEtTraitRec;}

    {


    }

    { : SInt32;

    {packedPosMain : PackedOthelloPosition;
    plMain : plateauOthello;}
    {fic_main : basicfile;
    theAbstractFile_main : FichierAbstrait;
    theAbstractFile_main_2 : FichierAbstrait;
    theAbstractFile_main_3 : FichierAbstrait;}
begin

  Discard7(i_main,i_main2, confiance, s, s1, s_main, long_s);



  SetTracingLog(false);

  debuggage.general := false;
  debuggage.afficheSuiteInitialisations := false;
  nbreDebugage := 0;
  gPendantLesInitialisationsDeCassio := true;


  WaitNextEventImplemented := true;
  GestaltImplemented       := true;

  if not(GestaltImplemented)
    then gIsRunningUnderMacOSX := false
    else gIsRunningUnderMacOSX := (Gestalt(gestaltMenuMgrAttr,gestalt_aux) = NoErr) and
                                  ((gestalt_aux and gestaltMenuMgrAquaLayoutMask) <> 0);

  onlyEngine := Pos('CassioEngine',GetApplicationName('Cassio')) > 0;

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant DescendLimiteStack');


if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitMacintoshManagers');

  InitMacintoshManagers;
  GetClassicalFontsID;
  OSStatus_main := RegisterAppearanceClient;

  MicroSeconds(microTime);
  tickDebutInitialisations := TickCount;
  RandomizeTimer;
  gIdentificateurUniqueDeCetteSessionDeCassio := microTime.hi xor microTime.lo xor Random32();
  if gIdentificateurUniqueDeCetteSessionDeCassio < 0
    then gIdentificateurUniqueDeCetteSessionDeCassio := -gIdentificateurUniqueDeCetteSessionDeCassio;
  if gIdentificateurUniqueDeCetteSessionDeCassio = 0
    then gIdentificateurUniqueDeCetteSessionDeCassio := abs(Random32());

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant WaitNextEvent');

  ShareTimeWithOtherProcesses(1);

if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitMacExtras');

  InitUnitMacExtras(false);
  InitUnitAppleEventsCassio;

  {$ifc not(defined __GPC__)}
  (* InitLateImports; *)
  {$endc}

  InitUnitOth2;

  InitUnitNewGeneral;
  InitUnitCreateBitboardCode;
  InitUnitHashTableExacte;
  InitUnitHashing;
  InitUnitMyStrings;
  InitUnitPostscript;
  InitUnitJaponais;
  InitUnitFormatsFichiers;



if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitTroisiemeDimension');

  InitUnitGestionDuTemps;
  InitUnitTroisiemeDimension;
  InitUnitMoveRecords;
  InitUnitSuperviseur;
  InitUnitCouleur;
  InitUnitProgressBar;
  InitUnitOth1;
  InitUnitCassioSounds;
  InitUnitRetrograde;
  InitUnitProblemeDePriseDeCoin;


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitJeu');

  InitUnitJeu;
  InitUnitNouvelleEval;
  InitUnitChi2NouvelleEval;
  InitUnitVecteurEval;
  InitUnitVecteurEvalInteger;
  InitUnitSymmetricalMapping;
  InitUnitProbCutValues;
  InitUnitPotentiels;



  InitUnitPagesDeABR;
  InitUnitPagesDeATR;
  InitUnitInterversions;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant CurResFile');

  CassioResFile := CurResFile;
  pathCassioFolder := DetermineVolumeApplication;
  pathDossierFichiersAuxiliaires := DeterminePathDossierFichiersAuxiliaires(pathCassioFolder);
  pathDossierOthelliersCassio := DeterminePathDossierOthelliersCassio(pathCassioFolder);



(* initialisation de l'unite UnitDefFichiersTEXT et des handlers associes *)
  InitUnitBasicFile;
  InstallMessageDisplayerBasicFile(WritelnDansRapportOuvert);
  InstallMessageAndNumDisplayerBasicFile(WritelnNumDansRapportOuvert);
  InstallAlertBasicFile(AlerteSimpleFichierTexte);

  {TraceLog('*****************************');}

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitProperties');

  InitUnitProperties;
  InitUnitPropertyList;
  InitUnitGameTree;
  InitUnitArbreDeJeuCourant;
  InitUnitAfficheArbreJeuCourant;
  InitUnitDefinitionsSmartGameBoard;
  InitUnitSmartGameBoard;

  InitUnitRapport;
  InitUnitBufferedPICT;
  InitUnitLiveUndo;

  InitUnitAccesGrapheApprentissage;
  InitUnitCalculsApprentissage;
  InitUnitUtilitairesFinale;
  InitUnitEndgameTree;
  InitUnitApprentissageInterversion;
  InitUnitVariablesGlobalesFinale;
  InitUnitFichierPhotos;
  InitUnit3DPovRayPict;
  InitUnitGenericGameFormat;
  InitUnitSaisiePartie;
  InitUnitNotesSurCases;
  InitUnitMiniProfiler;
  InitUnitListeChaineeCasesVides;
  InitUnitSelectionRapideListe;
  InitUnitListe;
  InitUnit_AB_Scout;
  InitUnitScripts;
  InitUnitTournoi;
  InitUnitEntreeTranscript;
  InitUnitBitboardHash;
  InitUnitZebraBook;
  InitUnitImportDesNoms;
  InitUnitVieilOthelliste;
  InitUnitCourbe;
  InitUnitTriListe;
  InitUnitBords;
  InitUnitEvaluation;
  InitUnitEdmond;
  InitUnitConstructionListeBitboard;
  InitUnitParallelisme;
  if not(CanInitializeOSAtomicUnit) then WritelnDansRapport('Impossible d''initialiser les operations atomiques !!');
  InitUnitPagesDeModule;
  InitUnitPagesDeSymbole;
  InitUnitCompilation;
  InitUnitRegressionLineaire;
  {$ifc not(defined __GPC__) }
  if not(CanInitializeCFNetworkGlue) then WritelnDansRapport('Impossible d''initialiser les operations de réseau !!');
  {$endc}
  InitUnitCFNetworkHTPP;
  InitUnitZoo;
  InitUnitZooInterfaceAvecArbre;
  InitUnitEstimationCharge;
  InitUnitBaseNouveauFormat;
  InitUnitEngine;
  InitUnitDiagrammesFFORUM;
  InitUnitUnixTask;
  InitUnitMoulinette;
  InitUnitFFO;


  UnLoadTousSegments;



  {This next bit of code waits until MultiFinder brings our application
		to the front. This gives us a better effect if we open a window at
		startup.}
{ for i_main := 1 to 4 do bidbool := EventAvail(everyEvent, theEvent);  }
  UnLoadTousSegments;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitDialogUnit');
  InitDialogUnit;
  UnLoadTousSegments;



  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitUtilitaires');
  InitUnitUtilitaires;
  UnLoadTousSegments;


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant moremasters');
  UnLoadTousSegments;
  For i_main := 1 to 21 do MoreMasterPointers(64);
  UnLoadTousSegments;
  (* AlloueMemoireBill; *)
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlloueMemoireImpression');
  erreurES_main := AlloueMemoireImpression;
  UnLoadTousSegments;

  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant InitUnitNouveauFormat');
  InitUnitNouveauFormat;
  UnLoadTousSegments;



  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant AlloueMemoireNouvelleEvaluation');



 {si l'on veut calculer une nouvelle eval}
 {AlloueMemoireNouvelleEvaluation(true,true,false,true,true,false);
  AlloueMemoireSymmetricalMapping;}

 {si l'on veut calculer une nouvelle eval,avec les tris}
 {AlloueMemoireNouvelleEvaluation(true,true,false,true,true,true);
  AlloueMemoireSymmetricalMapping;}


 {si l'on veut seulement jouer,sans les flottants}
 if FichierEvaluationDeCassioTrouvable('Evaluation de Cassio')
    then AlloueMemoireNouvelleEvaluation(false,false,true,false,false,false);



 {si l'on veut seulement jouer, avec les flottants}
 {AlloueMemoireNouvelleEvaluation(false,true,true,false,false,false);}

 {si l'on veut seulement jouer, avec les flottants et les occurences}
 {AlloueMemoireNouvelleEvaluation(true,true,true,false,false,false);}

 {si l'on veut seulement jouer, avec les flottants et les occurences et les stats}
 {AlloueMemoireNouvelleEvaluation(true,true,true,false,false,true);}




  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant NewGeneral');
  NewGeneral;
  UnLoadTousSegments;



  erreurES_main := AllocateMemoireListePartieNouveauFormat(nbrePartiesEnMemoire);



  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('erreurES_main = '+IntToStr(erreurES_main));
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('nbrePartiesEnMemoire = '+IntToStr(nbrePartiesEnMemoire));
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('PartiesNouveauFormat.nbPartiesEnMemoire = '+IntToStr(PartiesNouveauFormat.nbPartiesEnMemoire));

  UnLoadTousSegments;
  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant verificationNewGeneral');
  VerificationNewGeneral;
  UnLoadTousSegments;



  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant initialisation');
 (********************* initialisation est ici **************)
  Initialisation;
 (********************* initialisation est ici **************)


 if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant OuvrirConnectionPermanenteAuZoo');
  OuvrirConnectionPermanenteAuZoo;



  // debuggage.afficheSuiteInitialisations := false;


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant UnLoadTousSegments');


  UnLoadTousSegments;
  InitValeursBlocsDeCoin;
  UnLoadTousSegments;
  InitialiseModeleLineaireValeursPotables;
  Initialise_valeurs_bords(-0.5);

  VideStatistiquesDeBordsABLocal(essai_bord_AB_local);
  VideStatistiquesDeBordsABLocal(coupure_bord_AB_local);
  UnLoadTousSegments;


  UnLoadTousSegments;


  Initialise_interversions;
  UnLoadTousSegments;


 {DoRechercheSolitaires(0,3248);}


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant CalculateRectEscargotGlobal');


  UnLoadTousSegments;
  CalculateRectEscargotGlobal;
  CalculateMeilleureSuiteRectGlobal;
  AjusteCurseur;
  UnLoadTousSegments;


  EnableItemTousMenus;
  FixeMarquesSurMenus;
  FixeMarqueSurMenuBase;
  FixeMarqueSurMenuMode(nbreCoup);
  SetMenusChangeant(0);

  UnLoadTousSegments;
  EnableKeyboardScriptSwitch;

  UnLoadTousSegments;




  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant EssayerLireFichiersEvaluationDeCassio');


  // WritelnDansRapport('avant EssayerLireFichiersEvaluationDeCassio');
  // AttendFrappeClavier;

  if not(GetNouvelleEvalDejaChargee) then
    EssayerLireFichiersEvaluationDeCassio;

  {BeginUseZebraNodes('Main');}

  // WritelnDansRapport('avant LireFichierEvalEdmondSurLeDisque');
  // AttendFrappeClavier;

  if not(EvaluationEdmondEstDisponible) and
     (LireFichierEvalEdmondSurLeDisque = NoErr)
    then SetEvaluationEdmondEstDisponible(true);



  (*
  if (ProfondeurMainDevice >= 8) then
    DoCampFire;
  *)

  {AlerteSimpleFichierTexte('Toto.txt',-49);}

  {TestMyEndGame;}
  {DessinePaletteDeCouleurs;
   AttendFrappeClavier;}

  {TesterProperties;}
  {TesteFichierAbstrait;}
  {TestUnitFichierPhotos;}
  {TestMinimisation;}
  {TestNouvelleEval;}
  {for i_main := 1 to 10 do
    TestStraightLineFitting;}
  {TestApprentissage;}
  {TestPilesEtFiles;}
  {TestWeightedSet;}
  {TestNouveauFormat;}


  {
  s := 'F5D6C3D3C4';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));

  s := 'F5 D6 C3 D3 C4';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));

  s := '  • F5 d6•6 c3 D3 t4 c4 ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));

  s := ' F5 2d6 3c3 4D3 5c4 ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthello(s,true));
  }

  {
  s := ' 1.f4 D3 3.c4   ';
  CompacterPartieAlphanumerique(s,kCompacterEnMajuscules);
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthelloAvecMiroir(s));
  WritelnStringAndBoolDansRapport(s+' = ',EstUnePartieOthelloAvecMiroir(s));
  }


  {TestUnitABR;}
  {TestPositionEtTraitSet;}
  {BibliothequeDansRapport;}
  {RejoueToutesLignesBibliothequeAvecCommentaire;}
  {TestUnitInterversions;}
  {TestUnitHashing;}
  {TestStringSet;}

  {TestUnitInterversions;}


  {
  i_main := Command_line_param_count;
  WritelnNumDansRapport('Command_line_param_count = ',i_main);
  s_main := Get_command_line(Get_program_name);
  WritelnDansRapport('Get_command_line = '+s_main);
  for i_main := 0 to Command_line_param_count do
    begin
      s_main := Get_command_line_parameter(i_main);
      WritelnNumDansRapport(s_main+'     <=  ',i_main);
    end;
  }

 (*
 for i_main := 1 to 60 do
   begin
     erreurES_main := CreerFichierSolitaireVideNouveauFormat(i_main);
     WritelnNumDansRapport('erreurES['+IntToStr(i_main)+'] = ',erreurES_main);
   end;
 *)

 (*
 WritelnNumDansRapport('sizeof(PackedOthelloPosition) = ',sizeof(PackedOthelloPosition));
 packedPosMain := PlOthToPackedOthelloPosition(JeuCourant);
 plMain := PackedOthelloPositionToPlOth(packedPosMain);
 WritelnPositionEtTraitDansRapport(plMain,pionNoir);
 *)

 {SetEcritToutDansRapportLog(true);}
 {SetAutoVidageDuRapport(true);}
 {EtalonnageVitesseMac(true);}
 {TestNouvelleEval;}
 {CreateJansEndgameCode(false);}
 {TestUnitATR;}

 {WritelnDansRapport('Hexa(nbElementsTableHashageInterversions-1) = '+Hexa(65536-1));}
 {WritelnDansRapport('Hexa(BNOT($00000007)) = '+Hexa(BNOT($00000007)));}
 {TestStabiliteBitboard;}
 {WritelnNumDansRapport('sizeof( : t_EnTeteNouveauFormat) = ',sizeof( : t_EnTeteNouveauFormat));}






 {ImporterToutesPartiesRepertoire;}

 (*WritelnDansRapport(EnleveCesCaracteresEntreCesCaracteres(['A'..'Z'],'{','}','blah{S}bip',false));
 WritelnDansRapport(EnleveCesCaracteresEntreCesCaracteres(['A'..'Z'],'{','}','blah{S}bip',true));
 WritelnDansRapport(EnleveChiffresEntreCesCaracteres('(',')','blah(1234)bip',false));
 WritelnDansRapport(EnleveChiffresEntreCesCaracteres('(',')','blah(1234)bip',true));
 WritelnDansRapport(EnleveChiffresAvantCeCaractereEnDebutDeLigne(')','1234)bip',false));
 WritelnDansRapport(EnleveChiffresAvantCeCaractereEnDebutDeLigne(')','1234)bip',true));
 WritelnDansRapport(EnleveChiffresApresCeCaractereEnFinDeLigne('(','blah(1234',false));
 WritelnDansRapport(EnleveChiffresApresCeCaractereEnFinDeLigne('(','blah(1234',true)); *)
 {ComparerFormatThorEtFormatSuedois('8.#BAJ/"$%9andCDKTL?UVSR5I+@:0M !4* = )3 > GNXWQH',
                                   'ongZflephcvamksuw2x5idqVjrXPUWTYQb43yKSMCLFDEJRBNG67zt01HOAI');}
 {ProcessEachSolitaireOnDisc(0,100);}





 {CopierEdmondCoefficientsDansCassio;}

 {WritelnNumDansRapport('GetEspaceDisponibleLancementCassio = ',GetEspaceDisponibleLancementCassio);}
 if CassioEnEnvironnementMemoireLimite then
   begin
     WritelnDansRapport('Pas beaucoup de mémoire : je passe en mode "light"');
     WritelnDansRapport('');
   end;


 {TestRapiditeBitboard64Bits;}
 {WritelnNumDansRapport('COUNT_LEADING_ZEROS(5) = ',COUNT_LEADING_ZEROS(5));}



 {if not(gIsRunningUnderMacOSX) then AfficheMemoire;}

 {DrawImagetteMeteoOnSquare(kAlertBig,23);}


{$IFC (DEFINED __GPC__)}
  {VerifierLeCompilateur;}
{$ENDC}
  {VerifierLeCompilateur;}


 {CalculateIntertaskSignalingTime;}
 {TesterConvergenceDesFlottants;}
 {TesterLesManipulationsDeBoucle;}

 {TesterListeCasesVidesBitboard(100000);
 TesterListeCasesVidesBitboard($FFFFFFFF);}


 if CassioUtiliseLeMultiprocessing
  then
    begin
      {WritelnDansRapport('');
      WritelnDansRapport('FIXME : enlever la ligne suivante pour les versions publiques');
      WritelnDansRapport('Je vais essayer de saturer mes '+IntToStr(numProcessors)+' processeurs.');
      }
    end;



 {EssaieAjouterInterversionPotentielle('F5D6C4D3C3','F5D6C3D3C4',NIL);}
 typeEvalEnCours := typeEvalDemandeeDansLesPreferences;


  (* VerifierLesSourcesDeCassio; *)
  (* Crash_with_stack_alignment; *)
  (* CalculerLeNombreDeToursPourUnDelaiUneMicroseconde; *)





  {$ifc not(defined __GPC__) }
  if not(CanInitializeCFNetworkGlue) then WritelnDansRapport('Impossible d''initialiser les opérations de réseau !!');
  {$endc}

  LecturePreparatoireDossierDatabase(pathCassioFolder,'Main {1}');
  MettreAJourLaBaseParTelechargement;



  {indiceVitesseMac := CalculVitesseMac(false);}
  {for i_main := 1 to 1000 do AlerteSimple('Iconisation impossible !! Prevenez Stéphane');}

  {
  MyParamText('Test : et alors ???','','','');
  AlerteFichierPhotosNonTrouve('CeFichier.txt');
  AlerteSimple('Iconisation impossible !! ^0 Prevenez Stéphane');
  }


  {WritelnNumDansRapport('indiceVitesseMac = ',indiceVitesseMac);}




  //i_main := AlerteDoubleOuiNon('Ceci est un texte, voulez-vous le lire ?','On a toujours le choix');
  // AlerteDouble('Ceci est un texte, voulez-vous le lire ?','On a toujours le choix');




  {DumpCFNetwortConstantsToRapport;}


  if debuggage.afficheSuiteInitialisations then StoppeEtAffichePourDebugage('Avant CanStartEngine');

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  if (numeroEngineEnCours <> 0) then
    begin
      if not(CanStartEngine(GetEnginePath(numeroEngineEnCours,''), IntToStr(numProcessors)))
        then numeroEngineEnCours := 0;
    end;
  {$ENDC}


  {ParserNumerosFFODesJoueurs;}



  {AlignerTestsFinales(61,78,ReflGagnant,ReflGagnant);}
  {AlignerTestsFinales(64,78,ReflGagnant,ReflGagnant);}
  {AlignerTestsFinales(62,63,ReflGagnant,ReflGagnant);}
  {AlignerTestsFinales(61,78,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(62,63,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(53,78,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(59,59,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(68,78,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(62,78,ReflParfait,ReflParfait);}
  {AlignerTestsFinales(74,78,ReflGagnantExhaustif,ReflGagnantExhaustif);}
  {AlignerTestsFinales(61,78,ReflParfaitExhaustif,ReflParfaitExhaustif);}
  {AlignerTestsFinales(61,78,ReflGagnantExhaustif,ReflGagnantExhaustif);}
  {AlignerTestsFinales(40,78,ReflParfaitExhaustif,ReflParfaitExhaustif);}

  gPendantLesInitialisationsDeCassio := false;

  {
  if onlyEngine
    then WritelnDansRapport('onlyEngine = TRUE')
    else WritelnDansRapport('onlyEngine = FALSE');
  }

  {
  WritelnNumDansRapport('sizeof(double) = ',Sizeof(double));
  WritelnNumDansRapport('sizeof(double) = ',Sizeof(double));
  WritelnNumDansRapport('sizeof(float_t) = ',Sizeof(float_t));
  WritelnNumDansRapport('size_of_float_in_c = ',size_of_float_in_c);
  }






  (* TestUnitDoubleMetaphone; *)
  (*
  Planetes;
  LSOpenURL ('http://ffothello.org');
  *)
  { InstallerFichierCronjob('UpdateCassio.cronjob'); }


  { DecrypterGrilleDuRallye2011; }

  (* Cryptographie; *)
  (* WritelnNumDansRapport('temps des initialisations = ',TickCount - tickDebutInitialisations); *)
  (* OptimiserLaFermeDuRallye; *)
  (* ReadUnicodeAccentsFromDisc; *)
  (* StressTestMilieuPourLeZoo; *)

  (*
  i_main := MetJoueursEtTournoisEnMemoire(false);
  if TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor('de Graaf Jan C.', i_main)
    then WritelnNumDansRapport(' de graf trouvé, numero = ',i_main);
  if TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor('De Camargo Lucas C.', i_main)
    then WritelnNumDansRapport(' de graf trouvé, numero = ',i_main);
  *)


  {if LaunchUNIXProcess('/usr/bin/pstopdf','/Users/stephane/Jeux/Othello/Cassio/Fichiers-auxiliaires/tiger_edax.eps') = NoErr then;}


  (*

  if ParserFENEnPositionEtTrait('[FEN 8/2p5/1P1p4/1Pppp3/1P1Ppp2/3P4/8/8 b - - 0 1]' , thePos) then
    WritelnPositionEtTraitDansRapport(thePos.position, GetTraitOfPosition(thePos));


  if ParserFENEnPositionEtTrait('FEN 8/2p5/1P1p4/1Pppp3/1P1Ppp2/3m4/8/8 b - - 0 1' , thePos) then
    WritelnPositionEtTraitDansRapport(thePos.position, GetTraitOfPosition(thePos));

  if ParserFENEnPositionEtTrait('FEN "8/2p5/1P1p4/1Pppp3/1P1Pppp2/3P4/8/8 b - - 0 1"' , thePos) then
    WritelnPositionEtTraitDansRapport(thePos.position, GetTraitOfPosition(thePos));

  if ParserFENEnPositionEtTrait('FEN "8/2p5/1P1p4/1Pppp3/1P1Ppp2/3P4/8/8    b - - 0 1"' , thePos) then
    WritelnPositionEtTraitDansRapport(thePos.position, GetTraitOfPosition(thePos));
  *)


(************************************************************)
(************************************************************)

  BouclePrincipale;

(************************************************************)
(************************************************************)


  DisposeTournoisNouveauFormat;


  Quitter := true;

  watch := GetCursor(watchcursor);
  InitCursor;

  {EndUseZebraNodes('Main');}

  MasquerToutesLesFenetres;
  InitCursor;

  UnLoadTousSegments;
  if ListeDesGroupesModifiee then CreeFichierGroupes;
  if (ChoixDistributions.genre <> kToutesLesDistributions) then LecturePreparatoireDossierDatabase(pathCassioFolder,'Main {2}');
  InitCursor;
  GereSauvegardePreferences;
  if DoitEcrireInterversions then EcritInterversionsSurDisque;

  {EcritCalculBlocsDeCoinSurDisque;}
  {EcritTablesBlocsDeCoinSurDisque('blocs');}


  InitCursor;
  FermeToutEtQuitte;
  InitCursor;
  UnLoadTousSegments;



  if DetruitRapport then DoNothing;
  if LibereMemoireIconisation then DoNothing;
  LibereMemoireUnitNouveauFormat;
  DisposeGeneral;
  LibereMemoireUnitRapport;
  LibereMemoireUnitParallelisme;
  LibereMemoireUnitConstructionListeBitboard;
  LibereMemoireUnitEdmond;
  LibereMemoireUnitEvaluation;
  LibereMemoireUnitBords;
  LibereMemoireUnitTriListe;
  LibereMemoireUnitCourbe;
  LibereMemoireUnitMiniProfiler;
  LibereMemoireUnitNotesSurCases;
  LibereMemoireUnitTroisiemeDimension;
  LibereMemoireUnitApprentissageInterversion;
  LibereMemoireUnitProbCutValues;
  LibereMemoireNouvelleEvaluation;
  LibereMemoireDialogUnit;
  LibereMemoireUnitUtilitaires;
  LibereMemoireUnitProperties;
  LibereMemoireUnitPropertyList;
  LibereMemoireUnitGameTree;
  LibereMemoireUnitArbreDeJeuCourant;
  LibereMemoireUnitAfficheArbreJeuCourant;
  LibereMemoireUnitDefinitionsSmartGameBoard;
  LibereMemoireUnitSmartGameBoard;
  LibereMemoireUnitBufferedPICT;
  LibereMemoireUnitLiveUndo;
  LibereMemoireUnitJaponais;
  LibereMemoireUnitMoveRecords;
  LibereMemoireUnitProblemeDePriseDeCoin;
  LibereMemoireUnitFichierPhotos;
  LibereMemoireUnit2DPovRayPicts;
  LibereMemoireUnitCassioSounds;
  LibereMemoireFormatsFichiers;
  LibereMemoireUnitSaisiePartie;
  LibereMemoireUnitHashTableExacte;
  LibereMemoireUnitNewGeneral;
  LibereMemoireUnitAccesGrapheApprentissage;
  LibereMemoireUnitSelectionRapideListe;
  LibereMemoireUnitListe;
  LibereMemoireUnit_AB_SCout;
  LibereMemoireUnitPrint;
  LibereMemoireUnitScripts;
  LibereMemoireUnitTournoi;
  LibereMemoireUnitEntreeTranscript;
  LibereMemoireUnitBitboardHash;
  LibereMemoireImportDesNoms;
  LibereMemoireVieilOthelliste;
  LibereMemoireGestionDuTemps;
  LibereMemoireUnitCompilation;
  LibereMemoireUnitRegressionLineaire;
  LibereMemoireUnitCFNetworkHTPP;
  LibereMemoireUnitZoo;
  LibereMemoireUnitZooInterfaceAvecArbre;
  LibereMemoireUnitEstimationCharge;
  LibereMemoireUnitBaseNouveauFormat;
  LibereMemoireUnitEngine;
  LibereMemoireUnitUnixTask;

  (* LibereMemoireBill; *)
  FlushEvents(everyEvent-DiskEvt,0);
  SwitchToScript(gLastScriptUsedOutsideCassio);



  ExitToShell;
end;

{ TODO and FIXME :

  0) aucun pour le moment...
}


{ BUGS a verifier avant de compiler avec CodeWarrior 8 Pascal :

 1) packed array of boolean
 2) valeur in set (pour des valeurs immediates seulement ?)
 3) reconstruire la librairie Pascal avec alignement PowerPC ?
 4) autres ?
}


END.
