UNIT UnitParallelisme;


INTERFACE








 USES Multiprocessing , UnitDefCassio, UnitDefParallelisme;


{$DEFINEC AVEC_DEBUG_PARALLELISME   FALSE}
{$DEFINEC USE_ASSERTIONS_DE_PARALLELISME   FALSE}
{$DEFINEC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES  FALSE}



// Initialisations de l'unite

procedure InitUnitParallelisme;
procedure LibereMemoireUnitParallelisme;
procedure AllocateMemoryForAlphaBetaTasks;
procedure LibereMemoireForAlphaBetaTasks;


// Fonctions generales sur le multiprocessing

function MPLibraryIsLoaded : boolean;
procedure SetNombreDeProcesseursActifs(nombre : SInt32);
function Reflector(parameter : UnivPtr) : OSStatus;
procedure CalculateIntertaskSignalingTime;
function OrdinateurMultiprocesseurSimuleSurUnMonoprocesseur : boolean;
procedure BouclerUnPetitPeu(nbreTours : SInt32);
procedure CalculerLeNombreDeToursPourUnDelaiUneMicroseconde;



////////////  PARALELLISATION DE L'ALPHA-BETA   ///////////////




// Fonction d'interface avec l'alpha-beta sequentiel

function CalculerCoupsEnParallele(inNroThreadDuPere : SInt32; inNroThreadFilsDisponible : SInt32; inPosition : bitboard; inNbreVides : SInt32; inAlpha,inBeta : SInt32; inDiffPions : SInt32; inVecteurParite : SInt32; inListeBitboard : UInt32; var inListeDesCoupsLegaux : listeVides; indexPremierFils,indexDernierFils : SInt32; var outMeilleureDefense : UInt32; var outNroDuDernierFilsEvalue : SInt32) : SInt32;


// Interruption generale d'une thread à partir d'un certain niveau

procedure InterrompreUneThread(nroThreadAInterrompre, nbreCasesVides, hashStampAInterrompre : SInt32; nroThreadAgissante : SInt32);
procedure EnleverLInterruptionPourCetteThread(nroThreadARelacher, nbreCasesVides, nroThreadAgissante : SInt32);
function ThreadEstInterrompue(nroThread, nbreCasesVides : SInt32) : boolean;
function ThreadEstInterrompuePourCeHashStamp(nroThread, hashStamp : SInt32; action : SInt32) : boolean;
procedure ReinitialiserInterruptionsParHashStampsDesThreads(nroThreadAgissante : SInt32);


// Proposition de travail et reservation des threads


function EssayerDEmettreUnePropositionDeTravail(nroThread : SInt32; profondeur : SInt32; const hashStamps : TableauDeQuatreHashStamps) : boolean;
function CetteThreadAEmisUnePropositionDeTravail(nroThread : SInt32; var profDeLaProposition : SInt32) : boolean;
procedure EmettreUnePropositionDeTravail(nroThread : SInt32; profondeur : SInt32; const hashStamps : TableauDeQuatreHashStamps; fonctionAppelante : String255);
procedure EnleverPropositionDeTravailDeCetteThread(nroThread : SInt32);
procedure EmettreUnePropositionDeTravailRecursivePourAiderSesFils(var node : NoeudDeParallelisme);
procedure EnleverPropositionDeTravailRecursivePourAiderSesFils(nroThread : SInt32);
function PrendrePropositionDeTravailDeCetteThread(nroThread : SInt32; nbreCasesVides, hashStamp : SInt32) : boolean;
function PeutTrouverUneThreadDisponible(nroThreadMaitre, nbreCasesVides, hashStamp : SInt32; var nroThreadEsclave : SInt32) : boolean;


// Gestion d'un noeud de parallelisme

procedure GererNoeudDeParallelisme(var node : NoeudDeParallelisme; action : SInt32; var whichResult : ResultParallelismeRec);
function NomActionDeParallelisme(action : SInt32) : String255;


// Preparation et lancement des fils dans un noeud de parallelisme

function PeutTrouverUneThreadEsclave(var node : NoeudDeParallelisme; action : SInt32; var nroThreadFilsAuChomage : SInt32) : boolean;
procedure PreparerUnTravailPourLaThreadAuChomage(var node: NoeudDeParallelisme; nroThreadFilsAuChomage : SInt32);
procedure LancerUnFils(var node : NoeudDeParallelisme; indexDuFils : SInt32; fonctionAppelante : String255);
procedure AnnulerUnFilsEnAttenteDeLancement(var node : NoeudDeParallelisme; indexDuFils : SInt32);
procedure InterrompreUnFils(var node : NoeudDeParallelisme; indexDuFils : SInt32);
function MeLancerMoiMemeRecursivementSurUnFils(var node : NoeudDeParallelisme; var coupDuFils : SInt32) : SInt32;


// Gestion de l'interruption d'un noeud de parallelisme

function InterruptionDansCeNoeudDeParallelisme(var node : NoeudDeParallelisme) : boolean;
procedure InterrompreLesFilsEnActiviteDansCeNoeud(var node : NoeudDeParallelisme);


// Attente active des resultats des autres fils dans un noeud de parallelisme

procedure AttendreDesResultatsEnProposantSesServices(var node : NoeudDeParallelisme);
procedure TrouverQuatreHashStampDeFilsEnActivite(var node : NoeudDeParallelisme; var hashStampsFils : TableauDeQuatreHashStamps);


// Calcul d'un sous-arbre par une thread

function MySubTreeValue(plat : bitboard; whichHashStamp, nbreVides, alpha, beta, diffPions, vecteurParite, nroThread, nroThreadPere : SInt32; listeBitboard : UInt32) : SInt32;



// Transmission des resultats entre les threads

function GetAnyResultForThisThread(nroThread : SInt32; var whichResult : ResultParallelismeRec) : boolean;
function GetAResultAtThisSpecificDepth(nroThread, profondeurSouhaitee : SInt32; var whichResult : ResultParallelismeRec) : boolean;
procedure PosterUnResultatAUneThread(nroThreadDuPere, nroThreadDuFils, note, whichMove, hashStampDuPere, numeroPosDuPere, nbCasesVidesDuPere : SInt32);
procedure EcouterLesResultatsDansCetteThread(nroThread : SInt32);



// Gestion des semaphores pour les jobs prets

function GetSemaphoreDeJobAndLock(nroThread : SInt32) : boolean;
procedure UnlockSemaphoreDeJob(nroThread : SInt32);
procedure RelockSemaphoreDeJob(nroThread : SInt32);
function JAiTraiteUnJobEnAttente(nroThread : SInt32; profondeurPropositionDeTravail : SInt32; const hashStamps : TableauDeQuatreHashStamps) : boolean;


// Les threads elles-meme

function CreateAlphaBetaTasks : OSStatus;
function StopAlphaBetaTasks : OSStatus;
function MyAlphaBetaTask( parameter : UnivPtr) : OSStatus;
function CetteThreadEstTuee(nroThread : SInt32) : boolean;


//  Mesure de parallelisme, par exemple à quatre cases vides

procedure PointDeMesureDeParallelisme;
function TauxDeParallelisme : double_t;
function FraisDeSynchro : double_t;
function ParallelismeUtile : double_t;
procedure EcrireMesureDeParallelismeDansRapport;
procedure EcrireFraisDeSynchronisationDansRapport;
procedure EcrireParallelismeUtileDansRapport;
procedure AfficherLesSpinlocksDuParallelisme;


// Des utilitaires de debugage

{$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
function BoucleInfinie(s : String255; tickDepart : SInt32) : boolean;
{$ENDC}

procedure AttendreFrappeClavierParallelisme(attenteTouche : boolean);
function DoitDebugguerParallelismeDansRapport : boolean;
procedure TesterLaFileDesResultatsDuParallelisme;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    CodeFragments, OSAtomic_glue, Sound, OSUtils, MacErrors, MacMemory, MacWindows, Timer

{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitServicesMemoire, UnitRapport, UnitMiniProfiler, MyStrings, UnitScannerUtils, MyMathUtils, UnitBitboardAlphaBeta
    , UnitConstrListeBitboard, UnitBitboardMobilite, UnitBitboardModifPlat, UnitBitboardHash, UnitCarbonisation, SNEvents, UnitBitboardUtils ;
{$ELSEC}
    ;
    {$I prelink/Parallelisme.lk}
{$ENDC}


{END_USE_CLAUSE}












{$pragmac  optimization_level 4}


var debug_file_des_resultats : boolean;


procedure InitUnitParallelisme;
var i : SInt32;
begin
  CassioUtiliseLeMultiprocessing              := false;

  gSpinLocksYieldTimeToCPU                    := true;
  gAvecParallelismeSpeculatif                 := true;


  gNbreAppelsMesureDeParallelisme             := 0;
  gDegreDeParallelisme                        := 0;
  gNbreDeSplitNodes                           := 0;
  gNbreDeCoupuresBetaDansUnSplitNode          := 0;
  gNbreDeSplitNodesRates                      := 0;
  gFraisDeSynchronisation                     := 0;
  gNbreMaxDInterruptions                      := 0;

  gFractionParallelisableMicroSecondes        := 0;
  gFractionParallelisableSecondes             := 0;


  gNombreDeCoupuresBetaPresquesSures          := 0;
  gNombreDeCoupuresBetaReussies               := 0;

  gYoungBrotherWaitElders                     := 2;   // (number+1) of sons we want to have evaluated before starting parallelizing a node
  gNbreEmptiesMinimalPourParallelisme         := 11;  // on peut faire du parallelisme a ce nombre de cases vides ou plus
  gExtensionDeParallelisme                    := 1;   // on plonge en bitboard parallele à tant case(s) vide(s) de plus que l'algo sequentiel
  gExtensionDeCoupureBetaProbable             := 1;   // si c'est une coupure beta probable, on plonge meme tant case(s) vide(s) plus tot

  debug_file_des_resultats                    := false;

  for i := 0 to kNombreMutexAccesBitboard*16 do
    gMutexAccesBitboardHash[i] := 0;

  AllocateMemoryForAlphaBetaTasks;

  CalculerLeNombreDeToursPourUnDelaiUneMicroseconde;

  for i := 0 to kNombreDeProfilersDuParallelisme do
    gProfilerParallelisme[i] := 0;
end;



procedure LibereMemoireUnitParallelisme;
var err : OSStatus;
begin
  err := StopAlphaBetaTasks;
  LibereMemoireForAlphaBetaTasks;
end;



function MPLibraryIsLoaded : boolean;
begin
  MPLibraryIsLoaded := ( ( UInt32(_MPIsFullyInitialized) <> UInt32(kUnresolvedCFragSymbolAddress) )
                       & ( _MPIsFullyInitialized ) );
end;


procedure SetNombreDeProcesseursActifs(nombre : SInt32);
begin

  // If the multiprocessing librairy is present then create the tasks
  if CanInitializeOSAtomicUnit &  MPLibraryIsLoaded & (kNombreMaxAlphaBetaTasks > 0) & (nombre >= 1)
    then
      begin
        numProcessors := Min(MPProcessorsScheduled,nombre);
        numProcessors := Min(numProcessors,kNombreMaxAlphaBetaTasks + 1);


        // FIXME : activate the next line to use more virtual processors than physical processors

        // numProcessors := numProcessors + 14;
        // numProcessors := 8;

         // WritelnDansRapport('');
         // WritelnDansRapport('FIXME : enlever la ligne suivante pour les versions publiques');
         // WritelnNumDansRapport('numProcessors = ',numProcessors);

        CassioUtiliseLeMultiprocessing := (numProcessors >= 2);
      end
    else
      begin
        numProcessors := 1;
        CassioUtiliseLeMultiprocessing := false;
      end;
end;


{$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}

function BoucleInfinie(s : String255; tickDepart : SInt32) : boolean;
var errDebug : OSErr;
begin

 {$IFC AVEC_DEBUG_PARALLELISME}

 if (TickCount - tickDepart) >= 3600  // 60 secondes

 {$ELSEC}

 if (TickCount - tickDepart) >= 300  // 5 secondes

 {$ENDC}
    then
      begin


        // ASSERT : boucle infinie
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WritelnDansRapport('');
        WritelnDansRapport('ASSERT : boucle infinie '+s+' !!! ');
        WritelnDansRapport('');


        SysBeep(0);

        (*
        GetPort(oldPort);
			  SetPortByWindow(wPlateauPtr);
        AfficherLesSpinlocksDuParallelisme;
        FlushWindow(wPlateauPtr);
        SetPort(oldPort);

        AttendreFrappeClavierParallelisme(true);

        *)

        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);

        Quitter := true;

        OS_MEMORY_BARRIER;

        BoucleInfinie := true;
      end
    else
      BoucleInfinie := false;



end;
  {$ENDC}


procedure BouclerUnPetitPeu(nbreTours : SInt32);
var k, compteur : SInt32;
    a,b,c : SInt32;
begin
  a := 1;
  b := 7;
  compteur := 0;
  for k := 0 to nbreTours do
    begin
      a := a*a + a*13263797 + 2353;
      if a < 0 then a := -a;
      c := a mod 10000;
      if c > 5000 then inc(compteur);
      if c > 20000 then Sysbeep(0);
    end;
  if compteur > (nbreTours + 2) then Sysbeep(0);
end;


procedure CalculerLeNombreDeToursPourUnDelaiUneMicroseconde;
var nbreTours : SInt32;
    microSecondesDepart : UnsignedWide;
    microSecondesFin : UnsignedWide;
    microSecondesDepart2 : UnsignedWide;
    microSecondesFin2 : UnsignedWide;
    delta : SInt32;
    i : SInt32;
begin

  gNbreDeToursPourAttendreUneMicroseconde := 0;


  for i := 1 to 4 do
    begin

      // Calculate the number of loops necessary for a 1 microsecond delay

      delta := 0;
      nbreTours := 1;

      repeat

        nbreTours := nbreTours * 10;

        MicroSeconds(microSecondesDepart2);
        MicroSeconds(microSecondesDepart);

        BouclerUnPetitPeu(nbreTours);

        MicroSeconds(microSecondesFin);
        MicroSeconds(microSecondesFin2);

        delta := microSecondesFin.lo-microSecondesDepart.lo;

        // WritelnNumDansRapport('temps de '+NumEnString(nbreTours)+' tours, en µsec = ',delta);

        // WritelnNumDansRapport('temps (2) de '+NumEnString(nbreTours)+' tours, en µsec = ',microSecondesFin2.lo-microSecondesDepart2.lo);


      until (delta > 100);

      if (delta > 0) & ((nbreTours div delta) > gNbreDeToursPourAttendreUneMicroseconde)
        then gNbreDeToursPourAttendreUneMicroseconde := nbreTours div delta;

      {WritelnNumDansRapport('gNbreDeToursPourAttendreUneMicroseconde = ', gNbreDeToursPourAttendreUneMicroseconde);}

    end;

end;







procedure EcrireFileDesResultatsDansRapport(nroThread : SInt32);
var errDebug : OSErr;
    k : SInt32;
begin

  OS_MEMORY_BARRIER;

  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);


  OS_MEMORY_BARRIER;

  WritelnDansRapport('----');
  WritelnNumDansRapport('Voici la file des résultats de la thread ',nroThread);

  with gFileDesResultats[nroThread] do
    begin
     // WritelnNumDansRapport('kNombreMaxResultasDansUneFile = ',kNombreMaxResultasDansUneFile);
     // WritelnNumDansRapport('mutex_modif_de_la_file = ',mutex_modif_de_la_file);
      WriteNumDansRapport('cardinal = ',cardinal);
      WriteNumDansRapport(',  tete = ',tete);
      WritelnNumDansRapport(',  queue = ',queue);
      WritelnDansRapport('(val, coup, hashpere, numeroPos, prof):');
      for k := 0 to kNombreMaxResultasDansUneFile - 1 do
        with resultats[k] do
          begin
            WriteNumDansRapport(' k = ',k);
            WriteNumDansRapport(' (',valeurResultat);
            WriteStringAndCoupDansRapport(' , ',coup);
            WriteNumDansRapport(' , ',hashPere);
            WriteNumDansRapport(' , ',numeroPere);
            WriteNumDansRapport(' , ',profondeur);

            if ((queue < tete) & (queue < k) & (k <= tete)) |
               ((queue >= tete) & ((k <= tete) | (queue < k)))
              then WritelnDansRapport(') **')
              else WritelnDansRapport(')');
          end;
    end;

  WritelnDansRapport('----');

  OS_MEMORY_BARRIER;

  errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);

  OS_MEMORY_BARRIER;

end;


function GetAnyResultForThisThread(nroThread : SInt32; var whichResult : ResultParallelismeRec) : boolean;
var  errDebug : OSErr;
begin

  GetAnyResultForThisThread := false;

  with gFileDesResultats[nroThread] do
      begin
         if cardinal > 0 then
           begin
             if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexLectureResultat, mutex_modif_de_la_file) <> 0 ) then
               begin

                 if cardinal > 0 then
                   begin

                     {$IFC AVEC_DEBUG_PARALLELISME AND FALSE}
                     WritelnNumDansRapport('Avant, GetAnyResultForThisThread va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
                     EcrireFileDesResultatsDansRapport(nroThread);
                     {$ENDC}

                     // GERER L'EXTRACTION EN QUEUE DANS LA FILE
                     queue := queue + 1;
                     if (queue >= kNombreMaxResultasDansUneFile) then queue := queue - kNombreMaxResultasDansUneFile;
                     cardinal := cardinal - 1;



                     // LIRE LE RESULTAT AU DEBUT DE LA FILE ET LE TRANSMETTRE A UN NOEUD
                     with whichResult do
                       begin
                         valeurResultat         := resultats[queue].valeurResultat;
                         coup                   := resultats[queue].coup;
                         hashPere               := resultats[queue].hashPere;
                         numeroPere             := resultats[queue].numeroPere;
                         profondeur             := resultats[queue].profondeur;
                       end;


                     {$IFC AVEC_DEBUG_PARALLELISME}
                      if DoitDebugguerParallelismeDansRapport then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WriteDansRapport('La thread '+NumEnString(nroThread)+' a trouvé le résultat suivant dans sa file (GetAnyResultForThisThread) :  ');
                          WriteDansRapport('(val, coup, hashpere, numeroPos, prof) = ');
                          with whichResult do
                            begin
                              WriteNumDansRapport(' (',valeurResultat);
                              WriteStringAndCoupDansRapport(', ',coup);
                              WriteNumDansRapport(', ',hashPere);
                              WriteNumDansRapport(', ',numeroPere);
                              WriteNumDansRapport(', ',profondeur);
                              WritelnDansRapport(')');
                            end;
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                     {$ENDC}



                     resultats[queue].profondeur := -1; // il a été lu, hein

                     OS_MEMORY_BARRIER;

                     {$IFC AVEC_DEBUG_PARALLELISME AND FALSE}
                     WritelnNumDansRapport('Apres, GetAnyResultForThisThread va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
                     EcrireFileDesResultatsDansRapport(nroThread);
                     {$ENDC}

                     GetAnyResultForThisThread := true;

                   end;  { if cardinal > 0 }


                 (*
                 if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureResultat, 0, mutex_modif_de_la_file) = 0 ) then
                    begin
                      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                        WritelnDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : impossible de remettre le mutex de lecture de mon resultat !!!');
                        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                      {$ENDC}
                    end;
                 *)
                 mutex_modif_de_la_file := 0;

               end;  { if ATOMIC_COMPARE_AND_SWAP }

           end; { if cardinal > 0 }
      end;


  {$IFC AVEC_DEBUG_PARALLELISME}
  if debug_file_des_resultats then
      begin
        WritelnNumDansRapport('GetAnyResultForThisThread va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
        EcrireFileDesResultatsDansRapport(nroThread);
      end;
  {$ENDC}

end;


function GetAResultAtThisSpecificDepth(nroThread, profondeurSouhaitee : SInt32; var whichResult : ResultParallelismeRec) : boolean;
var i,k,a,b,fin : SInt32;
    trouve : boolean;
    errDebug : OSErr;
begin

  GetAResultAtThisSpecificDepth := false;

  with gFileDesResultats[nroThread] do
      begin
         if cardinal > 0 then
           begin
             if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexLectureResultat, mutex_modif_de_la_file) <> 0 ) then
               begin

                 if cardinal > 0 then
                   begin


                     // RECHERCHE DANS LA FILE
                     trouve := false;
                     i := queue;
                     repeat
                       inc(i);
                       if i >= kNombreMaxResultasDansUneFile then i := 0;

                       if resultats[i].profondeur = profondeurSouhaitee
                         then trouve := true;  { trouve! }

                     until trouve | (i = tete);

                     if trouve then
                       begin

                         {$IFC AVEC_DEBUG_PARALLELISME AND FALSE}
                         WritelnNumDansRapport('Avant, GetAResultAtThisSpecificDepth va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
                         EcrireFileDesResultatsDansRapport(nroThread);
                         {$ENDC}

                         //  LIRE LE RESULTAT EN POSITION i DANS LA FILE ET LE TRANSMETTRE A UN NOEUD
                         with whichResult do
                           begin
                             valeurResultat         := resultats[i].valeurResultat;
                             coup                   := resultats[i].coup;
                             hashPere               := resultats[i].hashPere;
                             numeroPere             := resultats[i].numeroPere;
                             profondeur             := resultats[i].profondeur;
                           end;


                         {$IFC AVEC_DEBUG_PARALLELISME}
                          if DoitDebugguerParallelismeDansRapport then
                            begin
                              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                              WriteDansRapport('La thread '+NumEnString(nroThread)+' a trouvé le résultat suivant dans sa file (GetAResultAtThisSpecificDepth) :  ');
                              WriteDansRapport('(val, coup, hashpere, numeroPos, prof) = ');
                              with whichResult do
                                begin
                                  WriteNumDansRapport(' (',valeurResultat);
                                  WriteStringAndCoupDansRapport(', ',coup);
                                  WriteNumDansRapport(', ',hashPere);
                                  WriteNumDansRapport(', ',numeroPere);
                                  WriteNumDansRapport(', ',profondeur);
                                  WritelnDansRapport(')');
                                end;
                              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                            end;
                         {$ENDC}


                         if (i = queue + 1)
                           then
                             begin

                               // LE RESULTAT A ETE TROUVE EN QUEUE DANS LA FILE :
                               // GERER L'EXTRACTION EN QUEUE
                               queue := queue + 1;
                               if (queue >= kNombreMaxResultasDansUneFile) then queue := queue - kNombreMaxResultasDansUneFile;
                               cardinal := cardinal - 1;

                               resultats[queue].profondeur := -1; // il a été lu, hein

                             end
                           else
                             begin


                               // GERER LA SUPPRESSION DE L'ELEMENT EN POSITION i DANS LA FILE
                               if (i <> tete) then
                                 begin

                                   fin := (tete - 1);
                                   if fin < i then fin := fin + kNombreMaxResultasDansUneFile;

                                   for k := i to fin do
                                     begin

                                       a := k;
                                       b := k + 1;

                                       if a >= kNombreMaxResultasDansUneFile then a := a - kNombreMaxResultasDansUneFile;
                                       if b >= kNombreMaxResultasDansUneFile then b := b - kNombreMaxResultasDansUneFile;

                                       resultats[a].valeurResultat := resultats[b].valeurResultat;
                                       resultats[a].coup           := resultats[b].coup;
                                       resultats[a].hashPere       := resultats[b].hashPere;
                                       resultats[a].numeroPere     := resultats[b].numeroPere;
                                       resultats[a].profondeur     := resultats[b].profondeur;

                                     end;
                                 end;

                               // RETRECIR LA TETE DE LA FILE D'UNE UNITE

                               resultats[tete].profondeur := -1;  // il a ete lu, hein

                               tete := tete - 1;
                               if (tete < 0) then tete := tete + kNombreMaxResultasDansUneFile;
                               cardinal := cardinal - 1;

                             end;


                         {$IFC AVEC_DEBUG_PARALLELISME AND FALSE}
                         WritelnNumDansRapport('Apres, GetAResultAtThisSpecificDepth va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
                         EcrireFileDesResultatsDansRapport(nroThread);
                         {$ENDC}


                         OS_MEMORY_BARRIER;


                         GetAResultAtThisSpecificDepth := true;

                       end;  { if trouve }

                   end;  { if cardinal > 0 }


                 (*
                 if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureResultat, 0, mutex_modif_de_la_file) = 0 ) then
                    begin
                      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WritelnDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : impossible de remettre le mutex de lecture de mon resultat !!!');
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                      {$ENDC}
                    end;
                 *)
                 mutex_modif_de_la_file := 0;

               end;  { if ATOMIC_COMPARE_AND_SWAP_BARRIER }


           end;  { if cardinal > 0 }

      end;  { with gFileDesResultats[nroThreadDuPere] }


   {$IFC AVEC_DEBUG_PARALLELISME}
   if debug_file_des_resultats then
      begin
        WritelnNumDansRapport('GetAResultAtThisSpecificDepth va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThread);
        EcrireFileDesResultatsDansRapport(nroThread);
      end;
   {$ENDC}

end;





procedure PosterUnResultatAUneThread(nroThreadDuPere, nroThreadDuFils, note, whichMove, hashStampDuPere, numeroPosDuPere, nbCasesVidesDuPere : SInt32);
var ecrit : boolean;
    compteurDeSpin : SInt32;
    errDebug : OSErr;
    whichResult : ResultParallelismeRec;
    {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
    tickDepart : SInt32;
    s : String255;
    {$ENDC}
begin

  {$IFC AVEC_DEBUG_PARALLELISME}
    if DoitDebugguerParallelismeDansRapport then
      begin
        whichResult.valeurResultat := note;
        whichResult.coup           := whichMove;
        whichResult.hashPere       := hashStampDuPere;
        whichResult.numeroPere     := numeroPosDuPere;
        whichResult.profondeur     := nbCasesVidesDuPere;
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WriteDansRapport('La thread '+NumEnString(nroThreadDuFils)+' poste (dans PosterUnResultatAUneThread) le résultat suivant :  ');
        WriteDansRapport('(val, coup, hashpere, numeroPos, nroThreadDuPere, prof) = ');
        with whichResult do
          begin
            WriteNumDansRapport(' (',valeurResultat);
            WriteStringAndCoupDansRapport(', ',coup);
            WriteNumDansRapport(', ',hashPere);
            WriteNumDansRapport(', ',numeroPere);
            WriteNumDansRapport(', thread ',nroThreadDuPere);
            WriteNumDansRapport(', ',profondeur);
            WritelnDansRapport(')');
          end;
        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      end;
   {$ENDC}

  ecrit := false;
  compteurDeSpin := 0;

  with gFileDesResultats[nroThreadDuPere] do
    begin

      {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
      tickDepart := TickCount;
      s := 'dans PosterUnResultatAUneThread (thread '+ NumEnString(nroThreadDuFils)+')';
      {$ENDC}


      while not(ecrit)
        {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} & not(BoucleInfinie(s,tickDepart)) {$ENDC}
        do
          begin

            if (cardinal < kNombreMaxResultasDansUneFile) then
              begin
                if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexEcritureResultat, mutex_modif_de_la_file) <> 0 ) then
                  begin


                    if (cardinal < kNombreMaxResultasDansUneFile) then
                      begin

                        // GERER L'INSERTION A LA TETE DE LA FILE

                        tete := tete + 1;
                        if tete >= kNombreMaxResultasDansUneFile then tete := tete - kNombreMaxResultasDansUneFile;
                        cardinal := cardinal + 1;


                        // PLACER LE RESULTAT A LA FIN DE LA FILE
                        resultats[tete].valeurResultat := note;
                        resultats[tete].coup           := whichMove;
                        resultats[tete].hashPere       := hashStampDuPere;
                        resultats[tete].numeroPere     := numeroPosDuPere;
                        resultats[tete].profondeur     := nbCasesVidesDuPere;

                        OS_MEMORY_BARRIER;

                        ecrit := true ;

                      end;  { cardinal < kNombreMaxResultasDansUneFile }


                    (*
                    if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexEcritureResultat, 0, mutex_modif_de_la_file) = 0 ) then
                      begin
                        {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                        WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuFils)+') : impossible de remettre le mutex d''ecriture de mon resultat !!!');
                        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        {$ENDC}
                      end;
                    *)
                    mutex_modif_de_la_file := 0;

                  end;  { if ATOMIC_COMPARE_AND_SWAP_BARRIER }


              end;  { if cardinal < kNombreMaxResultasDansUneFile }

            if not(ecrit) then
              begin

                inc(compteurDeSpin);

                {$IFC AVEC_DEBUG_PARALLELISME}
                if (compteurDeSpin = 1) & (cardinal >= kNombreMaxResultasDansUneFile) then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnDansRapport('WARNING (thread '+NumEnString(nroThreadDuFils)+') : la file des résultats de la thread '+NumEnString(nroThreadDuPere)+', à qui je dois poster un résultat, est pleine !');
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}

                EcouterLesResultatsDansCetteThread(nroThreadDuFils);
                if gSpinLocksYieldTimeToCPU then MPYield;

                if (compteurDeSpin = 2) then OS_MEMORY_BARRIER;
              end;

          end;  { while not(ecrit) }

    end;  { with gFileDesResultats[nroThreadDuPere] }


   {$IFC AVEC_DEBUG_PARALLELISME}
   if debug_file_des_resultats then
     begin
       WritelnNumDansRapport('PosterUnResultatAUneThread va appeler EcrireFileDesResultatsDansRapport pour la thread ',nroThreadDuPere);
       EcrireFileDesResultatsDansRapport(nroThreadDuPere);
     end;
   {$ENDC}

end;




procedure EcouterLesResultatsDansCetteThread(nroThread : SInt32);
var whichResult : ResultParallelismeRec;
begin

  while GetAnyResultForThisThread(nroThread,whichResult) do
    GererNoeudDeParallelisme(gNoeudsDeParallelisme[nroThread,whichResult.profondeur],kRECEVOIR_UN_NOUVEAU_RESULTAT,whichResult);

end;



procedure InterrompreUnFils(var node : NoeudDeParallelisme; indexDuFils : SInt32);
var nroThreadAInterrompre : SInt32;
    hashStampDuFils : SInt32;
    profProposition : SInt32;
    (* k : SInt32;
    hashDansStack : StackParallelismeRec; *)
    laThreadAvaitEmisUneProposition : boolean;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin1 : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart1 : UnsignedWide; {$ENDC}
    errDebug : OSErr;
begin

  with node do
    if not(filsEnCoursDAnnulation[indexDuFils]) then
      begin

        filsEnCoursDAnnulation[indexDuFils] := true;

        {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart1); {$ENDC}

        {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}

        nroThreadAInterrompre := threadAffecteeACeFils[indexDuFils];
        hashStampDuFils       := hashStampDeCeFils[indexDuFils];


        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('');
            WritelnNumDansRapport('La thread '+NumEnString(node.nroThreadDuPere)+' va interrompre dans InterrompreUnFils sa fille, la thread '+NumEnString(nroThreadAInterrompre)+' à la profondeur ',node.nbreVides - 1);
            WritelnDansRapport('');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}

        if (nroThreadAInterrompre >= 0) & (nroThreadAInterrompre <= kNombreMaxAlphaBetaTasks) then
          begin

            laThreadAvaitEmisUneProposition := CetteThreadAEmisUnePropositionDeTravail(nroThreadAInterrompre, profProposition);

            if not(laThreadAvaitEmisUneProposition) | (profProposition <= node.nbreVides - 1)
              then
                begin


                 if (nroThreadDuPere = nroThreadAInterrompre)
                   then
                     begin
                       InterrompreUneThread(nroThreadAInterrompre, node.nbreVides - 1, hashStampDuFils, nroThreadDuPere);
                     end
                   else
                     begin
                       OS_MEMORY_BARRIER;
                       if (gStackParallelisme[nroThreadAInterrompre].hashStampACetteProf[nbreVides - 1] = hashStampDuFils) then
                          InterrompreUneThread(nroThreadAInterrompre, node.nbreVides - 1, hashStampDuFils, nroThreadDuPere) ;
                     end;

                end
              else
                begin
                  {$IFC AVEC_DEBUG_PARALLELISME}
                  if DoitDebugguerParallelismeDansRapport then
                    begin
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WritelnDansRapport('');
                      WritelnDansRapport(' La thread '+NumEnString(node.nroThreadDuPere)+' dit : en fait, je n''ai pas interrompu, dans InterrompreUnFils, la thread '+NumEnString(nroThreadAInterrompre)+' à la profondeur '+NumEnString(node.nbreVides - 1)+' parce qu''elle avait emis une proposition de travail');
                      WritelnDansRapport('');
                      AttendreFrappeClavierParallelisme(true);
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                    end;
                  {$ENDC}
                end;
          end;


        filsEnAttenteDeLancement[indexDuFils] := false;
        threadAffecteeACeFils[indexDuFils]    := -524;


        {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
        {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin1); {$ENDC}

        {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[0] := gProfilerParallelisme[0] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}
        {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[1] := gProfilerParallelisme[1] + (microSecondesFin1.lo-microSecondesDepart1.lo); {$ENDC}

      end;

end;


function ThreadEstInterrompue(nroThread, nbreCasesVides : SInt32) : boolean;
var hashStampDansStack, k : SInt32;
    test : boolean;
    testStack : boolean;
    testHistory : boolean;
    errDebug : OSErr;
begin


   ThreadEstInterrompue := (gAlphaBetaInterrompu[nroThread].profInterruption  >= nbreCasesVides);   //  FIXME !!  THINK TWICE, IS THIS CORRECT ?!?

   // ThreadEstInterrompue := (gAlphaBetaInterrompu[nroThread].profInterruption  = nbreCasesVides);   // FIXME !!


end;




procedure InterrompreUneThread(nroThreadAInterrompre, nbreCasesVides, hashStampAInterrompre : SInt32; nroThreadAgissante : SInt32);
var errDebug : OSErr;
    index : SInt32;
    {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
    tickDepart : SInt32;
    s : String255;
    {$ENDC}
begin


  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnDansRapport('');
      WritelnNumDansRapport('La thread '+NumEnString(nroThreadAgissante)+' va rentrer dans la boucle du mutex d''interruption dans InterrompreUneThread pour interrompre la thread ',nroThreadAInterrompre);
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}



  {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
  tickDepart := TickCount;
  s := 'dans InterrompreUneThread (thread '+ NumEnString(nroThreadAgissante)+')';
  {$ENDC}


  // Attendre de pouvoir prendre le mutex d'ecriture d'une interruption pour cette thread
  while (ATOMIC_COMPARE_AND_SWAP_32(0,1,gMutexEcritureInterruptionThread[nroThreadAInterrompre]) = 0 )
        {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} & not(BoucleInfinie(s,tickDepart)) {$ENDC}
     do
       begin
         EcouterLesResultatsDansCetteThread(nroThreadAgissante);
         if gSpinLocksYieldTimeToCPU then MPYield;
       end;



  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('La thread '+NumEnString(nroThreadAgissante)+' est sortie de sa boucle du mutex d''interruption InterrompreUneThread pour interrompre la thread ',nroThreadAInterrompre);
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}


  {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
  {$IFC AVEC_DEBUG_PARALLELISME}
  if (TickCount - tickDepart) > 3000  then   // 50 secondes
  {$ELSEC}
  if (TickCount - tickDepart) > 30  then   // une demi-seconde
  {$ENDC}
    if DoitDebugguerParallelismeDansRapport then
      begin
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadAgissante) +') : la prise de mutex etait trop longue dans InterrompreUneThread ( >  0.5s)');
        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      end;
  {$ENDC}


  // On a le mutex  : faire notre magie d'interruption !

  // ATOMIC_INCREMENT_32(gAlphaBetaInterrompu[nroThreadAInterrompre].positions.cardinal);

  if (hashStampAInterrompre <> 0) then
    begin
      index := gAlphaBetaInterrompu[nroThreadAInterrompre].positions.cardinal;
      inc(index);
      if (index > 15) then index := 0;
      gAlphaBetaInterrompu[nroThreadAInterrompre].positions.cardinal := index;
      gAlphaBetaInterrompu[nroThreadAInterrompre].positions.hashStamps[index] := hashStampAInterrompre;
    end;


  // On interrompt la thread inconditionnnelement
  if (gAlphaBetaInterrompu[nroThreadAInterrompre].profInterruption < nbreCasesVides) then
    begin
      gAlphaBetaInterrompu[nroThreadAInterrompre].profInterruption      := nbreCasesVides;
      gAlphaBetaInterrompu[nroThreadAInterrompre].hashStampInterruption := hashStampAInterrompre;
    end;

  OS_MEMORY_BARRIER;


  // Relacher le mutex
  gMutexEcritureInterruptionThread[nroThreadAInterrompre] := 0;

  OS_MEMORY_BARRIER;

end;


procedure EnleverLInterruptionPourCetteThread(nroThreadARelacher, nbreCasesVides, nroThreadAgissante : SInt32);
var errDebug : OSErr;
    {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
    tickDepart : SInt32;
    s : String255;
    {$ENDC}
begin

  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnDansRapport('');
      if (nroThreadARelacher = nroThreadAgissante)
        then WritelnDansRapport('La thread '+NumEnString(nroThreadAgissante)+' va rentrer dans la boucle du mutex d''interruption dans EnleverLInterruptionPourCetteThread')
        else WritelnNumDansRapport('La thread '+NumEnString(nroThreadAgissante)+' va rentrer dans la boucle du mutex d''interruption dans EnleverLInterruptionPourCetteThread pour enlever l''interruption de la thread ',nroThreadARelacher);
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}



  {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
  tickDepart := TickCount;
  s := 'dans EnleverLInterruptionPourCetteThread (thread '+ NumEnString(nroThreadAgissante)+')';
  {$ENDC}


  // Attendre de pouvoir prendre le mutex d'ecriture d'une interruption pour cette thread
  while (ATOMIC_COMPARE_AND_SWAP_32(0,1,gMutexEcritureInterruptionThread[nroThreadARelacher]) = 0 )
        {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} & not(BoucleInfinie(s,tickDepart)) {$ENDC}
     do
       begin
         EcouterLesResultatsDansCetteThread(nroThreadAgissante);
         if gSpinLocksYieldTimeToCPU then MPYield;
       end;



  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      if (nroThreadARelacher = nroThreadAgissante)
        then WritelnDansRapport('La thread '+NumEnString(nroThreadAgissante)+' est sortie de sa boucle du mutex d''interruption dans EnleverLInterruptionPourCetteThread')
        else WritelnNumDansRapport('La thread '+NumEnString(nroThreadAgissante)+' est sortie de sa boucle du mutex d''interruption dans EnleverLInterruptionPourCetteThread pour enlever l''interruption de la thread ',nroThreadARelacher);
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}


  {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
  {$IFC AVEC_DEBUG_PARALLELISME}
  if (TickCount - tickDepart) > 3000  then   // 50 secondes
  {$ELSEC}
  if (TickCount - tickDepart) > 30  then   // une demi-seconde
  {$ENDC}
    if DoitDebugguerParallelismeDansRapport then
      begin
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadAgissante) +') : la prise de mutex etait trop longue dans EnleverLInterruptionPourCetteThread ( >  0.5s)');
        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      end;
  {$ENDC}


  // On a le mutex  : faire notre magie d'interruption !

  if (gAlphaBetaInterrompu[nroThreadARelacher].profInterruption <= nbreCasesVides) then
    begin
      gAlphaBetaInterrompu[nroThreadARelacher].profInterruption      := kPasDInterrumptionPourCetteThread;
      gAlphaBetaInterrompu[nroThreadARelacher].hashStampInterruption := kPasDInterrumptionPourCetteThread;

      OS_MEMORY_BARRIER;
    end;


  // Relacher le mutex
  gMutexEcritureInterruptionThread[nroThreadARelacher] := 0;

  OS_MEMORY_BARRIER;

end;


procedure LancerUnFils(var node : NoeudDeParallelisme; indexDuFils : SInt32; fonctionAppelante : String255);
var errDebug : OSStatus;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    nroThreadDuFils, i : SInt32;
begin

  with node do
    begin

      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}

      nroThreadDuFils := threadAffecteeACeFils[indexDuFils];

      if (nroThreadDuFils < 0) | (nroThreadDuFils > kNombreMaxAlphaBetaTasks) then
        begin

          // ASSERT : fils inconnu dans LancerUnFils...

          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : impossible de lancer un fils dans LancerUnFils:'+fonctionAppelante+'... mauvais numero de fils !!  nroThreadDuFils = ',nroThreadDuFils);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          {$ENDC}

          exit(LancerUnFils);
        end;

      filsEnAttenteDeLancement[indexDuFils] := false;


      if ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0,1,gAlphaBetaTasksData^[nroThreadDuFils].semaphoreDeJobPret) <> 0 then
        begin


          {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
          {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[12] := gProfilerParallelisme[12] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

          // c'est bon, on vient de lever le semaphore de job du fils

          OS_MEMORY_BARRIER;

          exit(LancerUnFils);
        end;


      // On essaye 10 fois en passant un peu la main
      for i := 1 to 10 do
        begin
          if ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0,1,gAlphaBetaTasksData^[nroThreadDuFils].semaphoreDeJobPret) <> 0 then
            begin

              {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
              {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[12] := gProfilerParallelisme[12] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

              // c'est bon, on vient (finalement !!) de lever le semaphore de job du fils

              exit(LancerUnFils);
            end;

          MPYield;

          OS_MEMORY_BARRIER;
        end;


      // ASSERT : état inconnu dans LancerUnFils...

      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : impossible de lancer un fils dans LancerUnFils:'+fonctionAppelante+'...  semaphoreDeJob <> 0 !!  nroThreadDuFils = ',nroThreadDuFils);
      WritelnNumDansRapport('gAlphaBetaTasksData^[nroThreadDuFils].semaphoreDeJobPret = ',gAlphaBetaTasksData^[nroThreadDuFils].semaphoreDeJobPret);
      Sysbeep(0);
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      {$ENDC}

    end;

end;


function ThreadEstInterrompuePourCeHashStamp(nroThread, hashStamp : SInt32; action : SInt32) : boolean;
var k : SInt32;
begin

  with gAlphaBetaInterrompu[nroThread].positions do
    begin
      for k := 0 to 15 do
        if (hashStamps[k] = hashStamp) then
          begin
            if (action = kEnleverCetteInterruptionPourCetteThread) then
              hashStamps[k] := 0;

            ThreadEstInterrompuePourCeHashStamp := true;
            exit(ThreadEstInterrompuePourCeHashStamp);
          end;
    end;

  ThreadEstInterrompuePourCeHashStamp := false;

end;


procedure ReinitialiserInterruptionsParHashStampsDesThreads(nroThreadAgissante : SInt32);
var errDebug : OSStatus;
    bidHashStamps : TableauDeQuatreHashStamps;
begin


  // Si c'est la thread 0 qui agit, elle pourrait avoir un vieux job à solder

  if (nroThreadAgissante = 0) then
    begin

      bidHashStamps[0] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[1] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[2] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[3] := kNePasFaireDePropositionDeTravail;

      if JAiTraiteUnJobEnAttente(nroThreadAgissante, kNePasFaireDePropositionDeTravail, bidHashStamps) then
        begin
          {$IFC AVEC_DEBUG_PARALLELISME}
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('BIZARRE : la thread '+NumEnString(nroThreadAgissante)+' a soldé un vieux job à traiter dans ReinitialiserInterruptionsParHashStampsDesThreads');
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          {$ENDC}
        end;

    end;



  // reinitialiser les interruptions (par hashstamp de positions) de toutes les threads

  // on ne le fait plus :-)

end;


procedure AnnulerUnFilsEnAttenteDeLancement(var node : NoeudDeParallelisme; indexDuFils : SInt32);
var errDebug : OSErr;
    nroThreadFils : SInt32;
    hashStampDuFils : SInt32;
    profProposition : SInt32;
    laThreadAvaitEmisUneProposition : boolean;
    etaitEnAttenteDeLancement : boolean;
begin

  with node do
    if not(filsEnCoursDAnnulation[indexDuFils]) then
      begin

        filsEnCoursDAnnulation[indexDuFils] := true;

        nroThreadFils                         := threadAffecteeACeFils[indexDuFils];
        hashStampDuFils                       := hashStampDeCeFils[indexDuFils];


        if (nroThreadFils >= 0) & (nroThreadFils <= kNombreMaxAlphaBetaTasks)
          then etaitEnAttenteDeLancement := filsEnAttenteDeLancement[indexDuFils]
          else etaitEnAttenteDeLancement := false;

        filsEnAttenteDeLancement[indexDuFils] := false;


        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuPere)+' est interrompue et, avant meme de le lancer, libere son fils, la thread ',nroThreadFils);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}


        // Interrompre le fils avant meme de le lancer

        if (nroThreadFils >= 0) & (nroThreadFils <= kNombreMaxAlphaBetaTasks) then
          begin
            laThreadAvaitEmisUneProposition := CetteThreadAEmisUnePropositionDeTravail(nroThreadFils, profProposition);

            if not(laThreadAvaitEmisUneProposition) | (profProposition <= node.nbreVides - 1) then
              begin
                InterrompreUneThread(nroThreadFils, node.nbreVides - 1, hashStampDuFils, nroThreadDuPere);
              end;
          end;

        OS_MEMORY_BARRIER;

        // Puis faire semblant de lancer le fils normalement (il devrait sortir tout de suite)

        if etaitEnAttenteDeLancement &
           (threadAffecteeACeFils[indexDuFils] >= 0) &
           (threadAffecteeACeFils[indexDuFils] <= kNombreMaxAlphaBetaTasks) then
           begin
             inc(nbreResultatsEnAttente);
             LancerUnFils(node,indexDuFils,'AnnulerUnFilsEnAttenteDeLancement');
           end;

        threadAffecteeACeFils[indexDuFils] := -500;
        filsEnAttenteDeLancement[indexDuFils] := false;


        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('La thread '+NumEnString(nroThreadDuPere)+' vient de lancer un fils (la thread '+NumEnString(nroThreadFils)+') en esperant qu''il sera arrete immédiatement ');
            WritelnDansRapport('');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}



    end;
end;





function CalculerCoupsEnParallele(inNroThreadDuPere                            : SInt32;
                                  inNroThreadFilsDisponible                    : SInt32;
                                  inPosition                                   : bitboard;
                                  inNbreVides                                  : SInt32;
                                  inAlpha,inBeta                               : SInt32;
                                  inDiffPions                                  : SInt32;
                                  inVecteurParite                              : SInt32;
                                  inListeBitboard                              : UInt32;
                                  var inListeDesCoupsLegaux                    : listeVides;
                                  indexPremierFils,indexDernierFils            : SInt32;
                                  var outMeilleureDefense                      : UInt32;
                                  var outNroDuDernierFilsEvalue                : SInt32)     : SInt32;
var {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    i : SInt32;
    foo_bar_atomic_register : SInt32;
    errDebug : OSErr;
    bidon : ResultParallelismeRec;
begin

  {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}

  with gNoeudsDeParallelisme[inNroThreadDuPere, inNbreVides] do
    begin

      ATOMIC_INCREMENT_32(gNbreDeSplitNodes);

      ATOMIC_INCREMENT_32(gNroPositionParallele);

      // Initialisation des variables

      nroThreadDuPere                  := inNroThreadDuPere;
      nbreVides                        := inNbreVides;
      alpha                            := inAlpha;
      beta                             := inBeta;
      diffPions                        := inDiffPions;
      vecteurParite                    := inVecteurParite;
      listeBitboard                    := inListeBitboard;
      filsDebut                        := indexPremierFils;
      filsFin                          := indexDernierFils;
      listeDesCoupsLegaux              := inListeDesCoupsLegaux;
      betaCoupureTrouvee               := false;
      dansLaBoucleDAttenteDesResultats := false;

      with inPosition do
        begin
          pos_my_bits_low   := g_my_bits_low;
          pos_my_bits_high  := g_my_bits_high;
          pos_opp_bits_low  := g_opp_bits_low;
          pos_opp_bits_high := g_opp_bits_high;
        end;

      maximum := -100000;
      nbreResultatsEnAttente := 0;
      nroDuDernierFilsEvalue := -333;


      // On calcule une clef hash de la position pour valider les communications inter-process

      hashStamp := (pos_my_bits_low * pos_opp_bits_high) + (pos_my_bits_high + pos_opp_bits_low);
      hashStamp := hashStamp XOR gNroPositionParallele;


      // On validera aussi avec le numero de cette position parallele
      nroNoeudParallele := gNroPositionParallele;



     // Pour l'instant aucune thread ne travaille pour nous
     for i := filsDebut to filsFin do
       begin
         threadAffecteeACeFils[i]    := -500;
         hashStampDeCeFils[i]        := -1;
         filsEnAttenteDeLancement[i] := false;
         filsEnCoursDAnnulation[i]   := false;
       end;


     {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
     {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[3] := gProfilerParallelisme[3] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}




     // Commencer à repartir le travail des fils

      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('');
          WritelnDansRapport('/////////////////////////////////////////////////////////////////////////////////');
          WritelnDansRapport('');
          EcritBitboardState('Entree dans CalculerCoupsEnParallele (nroThreadDuPere, nroThreadFilsDispo) = (thread '+NumEnString(nroThreadDuPere)+',thread '+NumEnString(inNroThreadFilsDisponible)+') :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),nbreVides,alpha,beta,diffPions);
          WritelnNumDansRapport('vecteurParite = ',vecteurParite);
          WriteDansRapport('Liste des fils à étudier : ');
          for i := filsDebut to filsFin do
            WriteStringAndCoupDansRapport(' ',listeDesCoupsLegaux[i]);
          WritelnDansRapport('');
          WritelnNumDansRapport('indexPremierFils = ',indexPremierFils);
          WritelnNumDansRapport('indexDernierFils = ',indexDernierFils);
          WritelnNumDansRapport('hashStamp = ',hashStamp);
          WritelnNumDansRapport('nroNoeudParallele = ',nroNoeudParallele);
          WritelnNumDansRapport('diffPions recu = ',diffPions);
          WritelnNumDansRapport('diffPions calculé = ',BitboardToDiffPions(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high));
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          WritelnNumDansRapport('gNbreThreadsReveillees = ',gNbreThreadsReveillees);
          WritelnNumDansRapport('numProcessors = ',numProcessors);
          WritelnDansRapport('Etat des interruptions : ');
          for i := 0 to kNombreMaxAlphaBetaTasks do
             WritelnNumDansRapport('        gAlphaBetaInterrompu['+NumEnString(i)+'].prof = ',gAlphaBetaInterrompu[i].profInterruption);
          WritelnDansRapport('');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


     // preparer le premier fils

     nroDuFilsCourant := filsDebut - 1;

     PreparerUnTravailPourLaThreadAuChomage(gNoeudsDeParallelisme[nroThreadDuPere, inNbreVides], inNroThreadFilsDisponible);


     // c'est parti !!

     gStackParallelisme[nroThreadDuPere].hashStampACetteProf[inNbreVides] := hashStamp;

     GererNoeudDeParallelisme(gNoeudsDeParallelisme[nroThreadDuPere, nbreVides], kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE, bidon);

     gStackParallelisme[nroThreadDuPere].hashStampACetteProf[nbreVides] := -2;

     // renvoyer les resultats

     outMeilleureDefense         := bestDef;
     outNroDuDernierFilsEvalue   := nroDuDernierFilsEvalue;

     CalculerCoupsEnParallele    := maximum;




     // ASSERT : verification de la cohérence des resultats


     {$IFC USE_ASSERTIONS_DE_PARALLELISME }
     if ((maximum < -64) | (maximum > 64)) &
        (maximum <>  kValeurSpecialeInterruptionCalculParallele) &
        (maximum <> -kValeurSpecialeInterruptionCalculParallele) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : (maximum < -64) | (maximum > 64) à la sortie de CalculerCoupsEnParallele !!   maximum = ',maximum);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
     {$ENDC}

     {$IFC USE_ASSERTIONS_DE_PARALLELISME }
     if (maximum <>   kValeurSpecialeInterruptionCalculParallele) &
        (maximum <>  -kValeurSpecialeInterruptionCalculParallele) &
        ((outNroDuDernierFilsEvalue < indexPremierFils) | (outNroDuDernierFilsEvalue > indexDernierFils)) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : outNroDuDernierFilsEvalue out of bounds à la sortie de CalculerCoupsEnParallele !!!');
          WritelnNumDansRapport('indexPremierFils = ',indexPremierFils);
          WritelnNumDansRapport('indexDernierFils = ',indexDernierFils);
          WritelnNumDansRapport('outNroDuDernierFilsEvalue = ',outNroDuDernierFilsEvalue);
          WritelnNumDansRapport('bestDef = ',bestDef);
          WritelnNumDansRapport('maximum = ',maximum);
          WritelnNumDansRapport('alpha = ',alpha);
          WritelnNumDansRapport('beta = ',beta);
          WritelnDansRapport('');
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
     {$ENDC}

     {$IFC USE_ASSERTIONS_DE_PARALLELISME }
     if (maximum <>   kValeurSpecialeInterruptionCalculParallele) &
        (maximum <>  -kValeurSpecialeInterruptionCalculParallele) &
        ((bestDef < 11) | (bestDef > 88)) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : (bestDef < 11) | (bestDef > 88) à la sortie de CalculerCoupsEnParallele !!');
          WritelnNumDansRapport('   bestDef = ',bestDef);
          WritelnNumDansRapport('   maximum = ',maximum);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
     {$ENDC}


     {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('');
          EcritBitboardState('Sortie de CalculerCoupsEnParallele (nroThreadDuPere, nroThreadFilsDispo) = ('+NumEnString(nroThreadDuPere)+','+NumEnString(inNroThreadFilsDisponible)+') :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),nbreVides,alpha,beta,diffPions);
          WritelnDansRapport('  -> resultat à la prof '+NumEnString(inNbreVides)+' : (bestDef,dernierFilsEvalue,max) = ('+CoupEnString(bestDef,true)+','+NumEnString(nroDuDernierFilsEvalue)+','+NumEnString(maximum)+')');
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          WritelnDansRapport('Etat des interruptions : ');
          for i := 0 to kNombreMaxAlphaBetaTasks do
             WritelnNumDansRapport('        gAlphaBetaInterrompu['+NumEnString(i)+'].prof = ',gAlphaBetaInterrompu[i].profInterruption);
          WritelnDansRapport('');
          WritelnDansRapport('----------------------------------------------------------------------------');
          WritelnDansRapport('');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}

    end;
end;




procedure InterrompreLesFilsEnActiviteDansCeNoeud(var node : NoeudDeParallelisme);
var k : SInt32;
    nroThreadAInterrompre : SInt32;
    errDebug : OSErr;
    auMoinsUnFilsInterrompu : boolean;
begin
  with node do
    begin

      // Interrompre tous les fils precedents encore en activite

      auMoinsUnFilsInterrompu := false;

      for k := filsDebut to filsFin do
        begin

          if (threadAffecteeACeFils[k] >= 0) then
              begin

                nroThreadAInterrompre := threadAffecteeACeFils[k];

                if not(filsEnCoursDAnnulation[k]) then auMoinsUnFilsInterrompu := true;

                {$IFC AVEC_DEBUG_PARALLELISME}
                if DoitDebugguerParallelismeDansRapport then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnDansRapport('La thread '+NumEnString(nroThreadDuPere)+' essaye d''interrompre la thread '+NumEnString(threadAffecteeACeFils[k])+ ' avant de sortir elle-meme');
                    WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                    WritelnDansRapport('');
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}


                if filsEnAttenteDeLancement[k]
                  then AnnulerUnFilsEnAttenteDeLancement(node,k)      // annuler le lancement
                  else InterrompreUnFils(node,k);                     // bye bye, cow-boy


                {$IFC AVEC_DEBUG_PARALLELISME}
                if DoitDebugguerParallelismeDansRapport then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(nbreVides)+' vient d''essayer d''interrompre sa fille, la thread ',nroThreadAInterrompre);
                    WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                    WritelnDansRapport('');
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}

              end;

        end;  { for }


      // s'interrompre recursivement si on était en train d'aider un de ses fils
      (* if effetspecial & auMoinsUnFilsInterrompu & dansLaBoucleDAttenteDesResultats then   // FIXME : ceci est peut-etre interessant ?
        InterrompreUneThread(nroThreadDuPere, node.nbreVides - 1, 0, nroThreadDuPere);
        *)



    end; { with }

end;



function InterruptionDansCeNoeudDeParallelisme(var node : NoeudDeParallelisme) : boolean;
 var {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
     {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
     errDebug : OSErr;
     k : SInt32;
 begin

   with node do
     begin

       if ThreadEstInterrompue(nroThreadDuPere, nbreVides) then
          begin

            {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}

            // ASSERT : verification que l'on n'a aucun fils réservé mais non lancé
            {$IFC USE_ASSERTIONS_DE_PARALLELISME }
            for k := filsDebut to filsFin do
              if filsEnAttenteDeLancement[k] & not(filsEnCoursDAnnulation[k]) then
                begin
                  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                  WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : j''ai un fils réservé au moment d''une InterruptionDansCeNoeudDeParallelisme (peut-etre un probleme de coupure beta ?) !! ');
                  Sysbeep(0);
                  AttendreFrappeClavierParallelisme(true);
                  errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                end;
            {$ENDC}


            nbreResultatsEnAttente := -100;


            // On est interrompu : interrompre tous les fils precedents encore en activite

            InterrompreLesFilsEnActiviteDansCeNoeud(node);


            // Sortir immediatement de la fonction en renvoyant une valeur speciale

            nroDuDernierFilsEvalue := -1;
            maximum := kValeurSpecialeInterruptionCalculParallele;


            {$IFC AVEC_DEBUG_PARALLELISME}
            if DoitDebugguerParallelismeDansRapport then
              begin
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuPere)+' est interrompue et sort de InterruptionDansCeNoeudDeParallelisme en renvoyant kValeurSpecialeInterruptionCalculParallele : ',kValeurSpecialeInterruptionCalculParallele);
                WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                WritelnDansRapport('');
                AttendreFrappeClavierParallelisme(true);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              end;
            {$ENDC}

            {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
            {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[15] := gProfilerParallelisme[15] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}


            InterruptionDansCeNoeudDeParallelisme := true;



          end;

     end;

   InterruptionDansCeNoeudDeParallelisme := false;
 end;



procedure PreparerUnTravailPourLaThreadAuChomage(var node: NoeudDeParallelisme; nroThreadFilsAuChomage : SInt32);
var diffEssai : SInt32;
    iCourant : SInt32;
    nouvelleParite : SInt32;
    positionFils : bitboard;
    hashDeCeFils : SInt32;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    errDebug : OSErr;
begin

  with node do
    begin

      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}


      // ASSERT : verification que le numero de la thread qui prétend etre disponible n'est pas débile
      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
      if ( nroThreadFilsAuChomage < 0 ) | ( nroThreadFilsAuChomage > kNombreMaxAlphaBetaTasks ) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT : ( nroThreadFilsAuChomage < 0 ) | ( nroThreadFilsAuChomage > kNombreMaxAlphaBetaTasks ) dans PreparerUnTravailPourLaThreadAuChomage !!  nroThreadFilsAuChomage = ',nroThreadFilsAuChomage);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      inc(nroDuFilsCourant);

      // Jouer le coup

      iCourant := listeDesCoupsLegaux[nroDuFilsCourant];
      diffEssai := diffPions;
      nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,positionFils,diffEssai);


      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WriteStringAndCoupDansRapport('La thread '+NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(node.nbreVides)+' vient de preparer un coup legal (',iCourant);
          WritelnNumDansRapport(') qui sera sans doute affecté à la thread ',nroThreadFilsAuChomage);
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          WritelnDansRapport('');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      // On garde la trace que l'on va lancer telle thread sur tel fils,
      // pour pouvoir interrompre eventuellement les fils

      threadAffecteeACeFils[nroDuFilsCourant]    := nroThreadFilsAuChomage;
      filsEnAttenteDeLancement[nroDuFilsCourant] := true;
      filsEnCoursDAnnulation[nroDuFilsCourant]   := false;

      // Calcul du hashStamp du fils
      with positionFils do
        begin
          hashDeCeFils := (g_my_bits_low * g_opp_bits_high) + (g_my_bits_high + g_opp_bits_low);
          hashDeCeFils := hashDeCeFils XOR hashStamp;

          hashStampDeCeFils[nroDuFilsCourant]  := hashDeCeFils;
        end;

      // Fabriquer les donnees pour la thread qui accepte de travailler pour nous

      gAlphaBetaTasksData^[nroThreadFilsAuChomage].nroThread  := nroThreadFilsAuChomage;

      with gAlphaBetaTasksData^[nroThreadFilsAuChomage].jobRecu do
        begin
          positionSubTree        := positionFils;
          profondeurSubTree      := nbreVides - 1;
          alphaSubTree           := -beta;
          betaSubTree            := -alpha;
          diffPionsSubTree       := -diffEssai;
          vecteurPariteSubTree   := nouvelleParite;
          listeBitboardSubTree   := REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant);
          coupSubTree            := iCourant;
          hashDuPere             := hashStamp;
          hashDuFils             := hashDeCeFils;
          nroPosDuPere           := nroNoeudParallele;
          threadDuPere           := nroThreadDuPere;
        end;



      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
      {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[2] := gProfilerParallelisme[2] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

   end;

end;


function MeLancerMoiMemeRecursivementSurUnFils(var node : NoeudDeParallelisme; var coupDuFils : SInt32) : SInt32;
var valeur : SInt32;
    diffEssai : SInt32;
    nouvelleParite : SInt32;
    positionFils : bitboard;
    hashDeCeFils : SInt32;
    errDebug : OSErr;
begin
  with node do
    begin
      inc(nroDuFilsCourant);


      // Jouer le coup

      coupDuFils := listeDesCoupsLegaux[nroDuFilsCourant];
      diffEssai  := diffPions;
      nouvelleParite := ModifPlatBitboard(coupDuFils,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,positionFils,diffEssai);


      with positionFils do
        begin
          hashDeCeFils := (g_my_bits_low * g_opp_bits_high) + (g_my_bits_high + g_opp_bits_low);
          hashDeCeFils := hashDeCeFils XOR hashStamp;
        end;


      threadAffecteeACeFils[nroDuFilsCourant]    := nroThreadDuPere;  // puisque l'on va prendre soi-meme en charge ce fils
      hashStampDeCeFils[nroDuFilsCourant]        := hashDeCeFils;

      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuPere)+' s''appelle recursivement sur le coup '+CoupEnString(coupDuFils,true)+' pour participer au travail, pouf pouf...  hashStamp = ',hashStamp);
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      // on enleve les interruptions avant de plonger

      EnleverLInterruptionPourCetteThread(nroThreadDuPere, nbreVides - 1, nroThreadDuPere);


      // plonger récursivement

      valeur := MySubTreeValue( positionFils, hashDeCeFils, nbreVides - 1, -beta, -alpha, -diffEssai, nouvelleParite, nroThreadDuPere, nroThreadDuPere, REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,coupDuFils));


      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('Sortie de MeLancerMoiMemeRecursivementSurUnFils pour la thread '+NumEnString(nroThreadDuPere)+' avec la valeur = ',-valeur);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}

      // Une eventuelle interruption de notre thread ayant fait son office dans le sous arbre, on peut
      // desormais enlever les interruptions de ce meme sous-arbre
      EnleverLInterruptionPourCetteThread(nroThreadDuPere, nbreVides - 1, nroThreadDuPere);


      MeLancerMoiMemeRecursivementSurUnFils := valeur;
    end;
end;




function PeutTrouverUneThreadEsclave(var node : NoeudDeParallelisme; action : SInt32; var nroThreadFilsAuChomage : SInt32) : boolean;
begin

  OS_MEMORY_BARRIER;

  with node do
    begin

      if (action = kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE)
        then
          begin

            // Quand la procedure GererNoeudDeParallelisme est appelée avec l'action "kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE",
            // elle peut prendre en charge elle-meme, recursivement, le dernier fils à evaluer, ce qui explique le test
            // (nroDuFilsCourant < filsFin - 1)  ci-dessous : on ne cherche une thread esclave que pour les n-1 premiers fils...

            if (nroDuFilsCourant < filsFin - 1) & not(betaCoupureTrouvee) & not(ThreadEstInterrompue(nroThreadDuPere, nbreVides)) &
               (gNbreProcesseursCalculant < numProcessors) & PeutTrouverUneThreadDisponible(nroThreadDuPere, nbreVides, hashStamp, nroThreadFilsAuChomage) then
              begin
                PeutTrouverUneThreadEsclave := true;
                exit(PeutTrouverUneThreadEsclave);
              end;

          end
        else
          begin

            // Chercher une thread esclave...

            if (nroDuFilsCourant < filsFin) & not(betaCoupureTrouvee) & not(ThreadEstInterrompue(nroThreadDuPere, nbreVides)) &
               (gNbreProcesseursCalculant < numProcessors) & PeutTrouverUneThreadDisponible(nroThreadDuPere, nbreVides, hashStamp, nroThreadFilsAuChomage) then
              begin
                PeutTrouverUneThreadEsclave := true;
                exit(PeutTrouverUneThreadEsclave);
              end;

          end;


      PeutTrouverUneThreadEsclave := false;

    end;

end;


procedure AttendreDesResultatsEnProposantSesServices(var node : NoeudDeParallelisme);
var nroThread : SInt32;
    hashStampsDesFils : TableauDeQuatreHashStamps;
    jeViensDeTravailler : boolean;
begin

  jeViensDeTravailler := false;

  with node do
    begin

      nroThread := nroThreadDuPere;

      if (gAlphaBetaInterrompu[nroThread].profInterruption >= 0)
        then EnleverLInterruptionPourCetteThread(nroThread, nbreVides - 1, nroThread);

      TrouverQuatreHashStampDeFilsEnActivite(node, hashStampsDesFils);

      if JAiTraiteUnJobEnAttente(nroThread, nbreVides - 1, hashStampsDesFils)
        then jeViensDeTravailler := true;

      EcouterLesResultatsDansCetteThread(nroThread);

    end;

  if not(jeViensDeTravailler) & gSpinLocksYieldTimeToCPU
    then MPYield;

end;


procedure TrouverQuatreHashStampDeFilsEnActivite(var node : NoeudDeParallelisme; var hashStampsFils : TableauDeQuatreHashStamps);
var i, compteur : SInt32;
begin
  hashStampsFils[0] := 0;
  hashStampsFils[1] := 0;
  hashStampsFils[2] := 0;
  hashStampsFils[3] := 0;

  with node do
    begin
      compteur := 0;
      for i := filsDebut to filsFin do
        if (threadAffecteeACeFils[i] >= 0) & not(filsEnCoursDAnnulation[i]) &
           (gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.threadDuPere = nroThreadDuPere) then
           begin

             hashStampsFils[compteur] := hashStampDeCeFils[i];
             inc(compteur);

             if (compteur >= 4) then exit(TrouverQuatreHashStampDeFilsEnActivite);
           end;
    end;
end;


procedure EnleverPropositionDeTravailDeCetteThread(nroThread : SInt32);
var errDebug : OSErr;
begin

  // on enleve la proposition de travail
  if PrendrePropositionDeTravailDeCetteThread(nroThread, kAccepterNimporteQuellePropositionDeTravail, kAccepterNimporteQuellePropositionDeTravail)
    then
      begin

        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('La thread '+NumEnString(nroThread)+' vient d''enlever sa proposition de travail');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}
      end
    else
      begin
        {$IFC AVEC_DEBUG_PARALLELISME}
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WritelnDansRapport('ASSERT : La thread '+NumEnString(nroThread)+' n''arrive pas a reprendre sa proposition de travail');
        Sysbeep(0);
        AttendreFrappeClavierParallelisme(true);
        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        {$ENDC}
      end;
end;


procedure EmettreUnePropositionDeTravailRecursivePourAiderSesFils(var node : NoeudDeParallelisme);
var hashStampsDesFils : TableauDeQuatreHashStamps;
    bidHashStamps : TableauDeQuatreHashStamps;
    errDebug : OSErr;
begin

  with node do
    begin

      // il peut arriver, tres exceptionnelement, que l'on ait un vieux job à solder avant d'emettre notre proposition de travail

      bidHashStamps[0] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[1] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[2] := kNePasFaireDePropositionDeTravail;
      bidHashStamps[3] := kNePasFaireDePropositionDeTravail;

      if JAiTraiteUnJobEnAttente(nroThreadDuPere, kNePasFaireDePropositionDeTravail, bidHashStamps) then
        begin
          {$IFC AVEC_DEBUG_PARALLELISME}
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('BIZARRE : la thread '+NumEnString(nroThreadDuPere)+' a soldé un vieux job à traiter dans EmettreUnePropositionDeTravailRecursivePourAiderSesFils');
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          {$ENDC}
        end;


      // Notre proposition de travail ne s'appliquera qu'à l'un de nos fils en activite

      TrouverQuatreHashStampDeFilsEnActivite(node, hashStampsDesFils);


      // On essaye d'emettre effectivement notre proposition de travail

      if EssayerDEmettreUnePropositionDeTravail(nroThreadDuPere, nbreVides - 1, hashStampsDesFils) then
        begin
          DoNothing;
          {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('La thread '+NumEnString(nroThreadDuPere)+' vient d''emettre une proposition de travail pour aider ses fils');
              WritelnDansRapport('     fonctionAppelante = GererNoeudDeParallelisme:ATTENDRE_LES_RESULTATS');
              WritelnDansRapport('');
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}
        end;

     end;

end;


procedure EnleverPropositionDeTravailRecursivePourAiderSesFils(nroThread : SInt32);
var errDebug : OSErr;
    foo_bar_atomic_register : SInt32;
    bidHashStamps : TableauDeQuatreHashStamps;
    test : boolean;
    k : SInt32;
    h0,h1,h2,h3 : SInt32;
    propositionEnCours : SInt32;
    profPropEnCours : SInt32;
    ok : boolean;
    tickDepart : SInt32;
    {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
    s : String255;
    {$ENDC}
    positionCopie          : bitboard;
    profondeurCopie        : SInt32;
    alphaCopie             : SInt32;
    betaCopie              : SInt32;
    diffPionsCopie         : SInt32;
    vecteurPariteCopie     : SInt32;
    listeBitboardCopie     : UInt32;
    threadDuPereCopie      : SInt32;
    coupCopie              : SInt32;
    hashDuPereCopie        : SInt32;
    nroPosDuPereCopie      : SInt32;
    hashDuFilsCopie        : SInt32;
begin

  ok := false;

  // on enleve la proposition de travail destinee aux fils
  if PrendrePropositionDeTravailDeCetteThread(nroThread, kAccepterNimporteQuellePropositionDeTravail, kAccepterNimporteQuellePropositionDeTravail)
    then
      begin

        // notre thread sort de son attente passive et va se remettre a calculer
        ATOMIC_INCREMENT_32(gNbreProcesseursCalculant);

        ok := true;


        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('La thread '+NumEnString(nroThread)+' vient d''enlever la proposition de travail qu''elle avait emise pour aider ses fils (1)');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}

      end
    else
      begin

        // on ressaye, apres une barriere memoire :-)

        for k := 1 to 2 do
          begin

            OS_MEMORY_BARRIER;

            if PrendrePropositionDeTravailDeCetteThread(nroThread, kAccepterNimporteQuellePropositionDeTravail, kAccepterNimporteQuellePropositionDeTravail)
              then
                begin
                  ATOMIC_INCREMENT_32_BARRIER(gNbreProcesseursCalculant);

                  ok := true;

                  {$IFC AVEC_DEBUG_PARALLELISME}
                  if DoitDebugguerParallelismeDansRapport then
                    begin
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WritelnDansRapport('La thread '+NumEnString(nroThread)+' vient d''enlever la proposition de travail qu''elle avait emise pour aider ses fils (2)');
                      AttendreFrappeClavierParallelisme(true);
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                    end;
                  {$ENDC}

                  leave;

                end;


          end; { for }

        (*
        {$IFC AVEC_DEBUG_PARALLELISME}
        if (gAlphaBetaTasksData^[nroThread].propositionDeTravail <> 0) then
          begin

            test := PrendrePropositionDeTravailDeCetteThread(nroThread, kAccepterNimporteQuellePropositionDeTravail, kAccepterNimporteQuellePropositionDeTravail);
            if test then
              begin
                ATOMIC_INCREMENT_32_BARRIER(gNbreProcesseursCalculant);
                PeutEnleverPropositionDeTravailRecursivePourAiderSesFils := true;
              end;

            propositionEnCours := gAlphaBetaTasksData^[nroThread].propositionDeTravail;
            profPropEnCours    := gAlphaBetaTasksData^[nroThread].profondeurProposition;
            h0                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[0];
            h1                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[1];
            h2                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[2];
            h3                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[3];


            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('ASSERT : La thread '+NumEnString(nroThread)+' n''arrive pas a reprendre la proposition de travail qu''elle avait emise pour aider ses fils');
            WritelnNumDansRapport('    proposition en cours = ',propositionEnCours);
            WritelnNumDansRapport('    profondeurProposition = ',profPropEnCours);
            WritelnNumDansRapport('    hashStampProposition[0] = ',h0);
            WritelnNumDansRapport('    hashStampProposition[1] = ',h1);
            WritelnNumDansRapport('    hashStampProposition[2] = ',h2);
            WritelnNumDansRapport('    hashStampProposition[3] = ',h3);
            WritelnNumDansRapport('    test = ',SInt32(test));

            Sysbeep(0);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}
        *)

      end;

  (*
  if effetspecial & not(ok) then
    begin

      // tickDepart := TickCount;

      {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
      tickDepart := TickCount;
      s := 'dans EnleverPropositionDeTravailRecursivePourAiderSesFils (thread '+ NumEnString(nroThread)+')';
      {$ENDC}

      while not(ok | Quitter | (interruptionReflexion <> pasdinterruption))
            {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} & not(BoucleInfinie(s,tickDepart)) {$ENDC} do
        begin

          if GetSemaphoreDeJobAndLock(nroThread)
            then
              begin

                OS_MEMORY_BARRIER;

                // copier les donnes en local

                with gAlphaBetaTasksData^[nroThread].jobRecu do
                  begin
                    positionCopie          :=  positionSubTree;
                    profondeurCopie        :=  profondeurSubTree;
                    alphaCopie             :=  alphaSubTree;
                    betaCopie              :=  betaSubTree;
                    diffPionsCopie         :=  diffPionsSubTree;
                    vecteurPariteCopie     :=  vecteurPariteSubTree;
                    listeBitboardCopie     :=  listeBitboardSubTree;
                    threadDuPereCopie      :=  threadDuPere;
                    coupCopie              :=  coupSubTree;
                    hashDuPereCopie        :=  hashDuPere;
                    hashDuFilsCopie        :=  hashDuFils;
                    nroPosDuPereCopie      :=  nroPosDuPere;
                  end;

                UnlockSemaphoreDeJob(nroThread);

                PosterUnResultatAUneThread(threadDuPereCopie, nroThread, kValeurSpecialeInterruptionCalculParallele, coupCopie, hashDuPereCopie, nroPosDuPereCopie, profondeurCopie + 1);

                ok := true;

              end
            else
              begin
                EcouterLesResultatsDansCetteThread(nroThread);

                if gSpinLocksYieldTimeToCPU then MPYield;
              end;
        end;

      {
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('BIZARRE : la thread '+NumEnString(nroThread)+' n''avait pas de proposition de travail pour aider ses fils, temps en ticks = ',TickCount - tickDepart);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      }
    end;
  *)

  // il peut arriver, tres exceptionnelement, que l'on ait un vieux job à solder après avoir repris notre proposition de travail

  bidHashStamps[0] := kNePasFaireDePropositionDeTravail;
  bidHashStamps[1] := kNePasFaireDePropositionDeTravail;
  bidHashStamps[2] := kNePasFaireDePropositionDeTravail;
  bidHashStamps[3] := kNePasFaireDePropositionDeTravail;

  if JAiTraiteUnJobEnAttente(nroThread, kNePasFaireDePropositionDeTravail, bidHashStamps) then
    begin
      {$IFC AVEC_DEBUG_PARALLELISME}
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnDansRapport('BIZARRE : la thread '+NumEnString(nroThread)+' a soldé un vieux job à traiter dans EnleverPropositionDeTravailRecursivePourAiderSesFils');
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      {$ENDC}
    end;

end;


function NomActionDeParallelisme(action : SInt32) : String255;
var result : String255;
begin
  result := '';

  case action of
      kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE      :   result := 'kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE';
      kTROUVER_D_AUTRES_TACHES_AU_CHOMAGE          :   result := 'kTROUVER_D_AUTRES_TACHES_AU_CHOMAGE';
      kRECEVOIR_UN_NOUVEAU_RESULTAT                :   result := 'kRECEVOIR_UN_NOUVEAU_RESULTAT';
      kANALYSER_UN_RESULTAT                        :   result := 'kANALYSER_UN_RESULTAT';
      kCONTINUER_NORMALEMENT                       :   result := 'kCONTINUER_NORMALEMENT';
      kLANCER_LES_FILS_EN_ATTENTE                  :   result := 'kLANCER_LES_FILS_EN_ATTENTE';
      otherwise                                        result := 'ACTION INCONNUE : ' + NumEnString(action) + ' (ASSERT !)';
  end;

  NomActionDeParallelisme := result;
end;



procedure GererNoeudDeParallelisme(var node : NoeudDeParallelisme; action : SInt32; var whichResult : ResultParallelismeRec);
var i : SInt32;
    valeur : SInt32;
    nroThreadDuFils : SInt32;
    nroThreadFilsDisponible : SInt32;
    nroThreadAInterrompre : SInt32;
    {actionSuivante : SInt32;}
    errDebug : OSErr;
    resultatDuFils : SInt32;
    coupDuFils : SInt32;
    resultStamp : SInt32;
    resultNumero : SInt32;
    onVientDeRecevoirUnVraiResultat : boolean;
    foo_bar_atomic_register : SInt32;
    newResult : ResultParallelismeRec;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} tickDepart : SInt32; s : String255; {$ENDC}

label ON_VIENT_DE_TROUVER_UNE_TACHE_AU_CHOMAGE;
label ESSAYER_DE_TROUVER_D_AUTRES_TACHES_AU_CHOMAGE;
label LANCER_LES_NOUVEAUX_FILS;
label ATTENDRE_LES_RESULTATS;
label RECEVOIR_UN_NOUVEAU_RESULTAT;
label ON_VIENT_DE_TROUVER_UN_RESULTAT_A_ANALYSER;
label APRES_L_ANALYSE_D_UN_RESULTAT;
label SORTIE;


begin

  with node do
    begin


      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('Entree dans GererNoeudDeParallelisme pour la thread '+NumEnString(nroThreadDuPere)+' à la profondeur '+NumEnString(nbreVides)+' avec l''action ' + NomActionDeParallelisme(action));
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}

      case action of

        kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE       : goto ESSAYER_DE_TROUVER_D_AUTRES_TACHES_AU_CHOMAGE;

        kRECEVOIR_UN_NOUVEAU_RESULTAT                 : goto RECEVOIR_UN_NOUVEAU_RESULTAT;

        kANALYSER_UN_RESULTAT                         : goto ON_VIENT_DE_TROUVER_UN_RESULTAT_A_ANALYSER;

        otherwise
          begin
            // ASSERT : action non geree dans GererNoeudDeParallelisme
            {$IFC USE_ASSERTIONS_DE_PARALLELISME}
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('ASSERT : action non geree à l''entree de  GererNoeudDeParallelisme !!  action = ' + NomActionDeParallelisme(action));
            Sysbeep(0);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            {$ENDC}
          end;

      end; {case}


  RECEVOIR_UN_NOUVEAU_RESULTAT :

    begin



    //  with gFileDesResultats[nroThreadDuPere] do
        begin


          resultatDuFils         := whichResult.valeurResultat;
          coupDuFils             := whichResult.coup;
          resultStamp            := whichResult.hashPere;
          resultNumero           := whichResult.numeroPere;




          // aller analyser ce resultat
          goto ON_VIENT_DE_TROUVER_UN_RESULTAT_A_ANALYSER;



        end;
    end;


  ON_VIENT_DE_TROUVER_UNE_TACHE_AU_CHOMAGE :

      // ASSERT : verification que le numero de la thread qui prétend etre disponible en entree n'est pas débile
      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
      if ( nroThreadFilsDisponible < 0 ) | ( nroThreadFilsDisponible > kNombreMaxAlphaBetaTasks ) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : ( nroThreadFilsDisponible < 0 ) | ( nroThreadFilsDisponible > kNombreMaxAlphaBetaTasks ) à l''entree de  GererNoeudDeParallelisme !!  nroThreadFilsDisponible = ',nroThreadFilsDisponible);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      PreparerUnTravailPourLaThreadAuChomage(node,nroThreadFilsDisponible);


  ESSAYER_DE_TROUVER_D_AUTRES_TACHES_AU_CHOMAGE :

      // Tant que l'on a des threads disponibles, on essaye de lancer des autres fils

      if PeutTrouverUneThreadEsclave(node, action, nroThreadFilsDisponible) then
        goto ON_VIENT_DE_TROUVER_UNE_TACHE_AU_CHOMAGE;


  LANCER_LES_NOUVEAUX_FILS :


      EcouterLesResultatsDansCetteThread(nroThreadDuPere);



      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}



      // Lancer les nouveaux fils


      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuPere)+' va lancer des fils en parallele,   hashStamp = ',hashStamp);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}



      for i := filsDebut to filsFin do
        if filsEnAttenteDeLancement[i] & not(filsEnCoursDAnnulation[i]) then
          begin



            // ASSERT : verification que le numero de la thread affecte à ce fils n'est pas debile
            {$IFC USE_ASSERTIONS_DE_PARALLELISME}
            if ( threadAffecteeACeFils[i] < 0 ) | ( threadAffecteeACeFils[i] > kNombreMaxAlphaBetaTasks ) then
              begin
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : ( threadAffecteeACeFils[i] < 0 ) | ( threadAffecteeACeFils[i] > kNombreMaxAlphaBetaTasks ) dans GererNoeudDeParallelisme !!  threadAffecteeACeFils[i] = ',threadAffecteeACeFils[i]);
                Sysbeep(0);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              end;
            {$ENDC}


            // ASSERT : verification que la thread que l'on va lancer n'est pas nous-meme...
            {$IFC USE_ASSERTIONS_DE_PARALLELISME}
            if ( threadAffecteeACeFils[i] = nroThreadDuPere) then
              begin
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : (threadAffecteeACeFils[i] = nroThreadDuPere) dans GererNoeudDeParallelisme !!  threadAffecteeACeFils[i] = ',threadAffecteeACeFils[i]);
                Sysbeep(0);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              end;
            {$ENDC}




            // Normalement, on essaye de lancer les fils en levant leur semaphore de job, mais si on s'apercoit
            // que l'on a été interrompu pendant la recherche des taches au chomage, on ne va pas lancer normalement
            // le fils, mais au contraire essayer du mieux que l'on peut le fils en attente de lancement


            if betaCoupureTrouvee | ThreadEstInterrompue(nroThreadDuPere, nbreVides)
              then
                begin

                  AnnulerUnFilsEnAttenteDeLancement(node,i);


                end
              else
                begin


                  {$IFC AVEC_DEBUG_PARALLELISME}
                  if DoitDebugguerParallelismeDansRapport then
                    begin
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WriteDansRapport('La thread '+NumEnString(nroThreadDuPere)+' lance un job : ');
                      WriteDansRapport('(coupDuFils, threadFils, stampPere, stampFils ) = ('+CoupEnStringEnMajuscules(gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.coupSubTree)));
                      WriteNumDansRapport(',thread ',threadAffecteeACeFils[i]);
                      WriteNumDansRapport(',',gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.hashDuPere);
                      WriteNumDansRapport(',',gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.hashDuFils);
                      WritelnDansRapport(')');
                      AttendreFrappeClavierParallelisme(true);
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                    end;
                  {$ENDC}


                  {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                  if (gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.hashDuPere <> hashStamp) |
                     (gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.nroPosDuPere <> nroNoeudParallele) |
                     (gAlphaBetaTasksData^[threadAffecteeACeFils[i]].jobRecu.coupSubTree <> listeDesCoupsLegaux[i]) then
                  if DoitDebugguerParallelismeDansRapport then
                    begin
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : LA RESERVATION DE LA THREAD '+NumEnString(threadAffecteeACeFils[i])+' SEMBLE OBSOLETE !!!! ');
                      AttendreFrappeClavierParallelisme(true);
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                    end;
                  {$ENDC}


                  inc(nbreResultatsEnAttente);


                  // LANCEMENT DU FILS, EN LEVANT LE SEMAPHORE OU EN ARRETANT LE SPIN-LOCK, SELON LE CAS


                  LancerUnFils(node,i,'GererNoeudDeParallelisme:LANCER_LES_NOUVEAUX_FILS');


                end;


          end;


    {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[5] := gProfilerParallelisme[5] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}



  ATTENDRE_LES_RESULTATS :




      // Est-on interrompu ?
      if InterruptionDansCeNoeudDeParallelisme(node) then
        begin

          {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('Sortie par interruption {1} de la thread '+NumEnString(nroThreadDuPere)+' : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
              WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // ASSERT : verification que l'on renvoie bien le bon nroDuDernierFilsEvalue
          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          if ((nroDuDernierFilsEvalue < filsDebut) | (nroDuDernierFilsEvalue > filsFin)) & (action = kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE) then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : sortie prematureee {1} de GererNoeudDeParallelisme !!');
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}

          exit(GererNoeudDeParallelisme);
        end;



      if (action <> kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE)
        then
          begin

            {$IFC AVEC_DEBUG_PARALLELISME}
            if DoitDebugguerParallelismeDansRapport then
              begin
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnDansRapport('Sortie car (action <> kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE) de la thread '+NumEnString(nroThreadDuPere)+' : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
                WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                AttendreFrappeClavierParallelisme(true);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              end;
            {$ENDC}

            exit(GererNoeudDeParallelisme);
          end
        else
          begin


            EcouterLesResultatsDansCetteThread(nroThreadDuPere);


            if not(ThreadEstInterrompue(nroThreadDuPere, nbreVides)) & not(betaCoupureTrouvee) then
              begin
                if (nroDuFilsCourant < filsFin) & not(betaCoupureTrouvee)
                  then
                    begin
                      // PRENDRE MOI-MEME UN FILS A ANALYSER

                      resultatDuFils := MeLancerMoiMemeRecursivementSurUnFils(node, coupDuFils);

                      resultStamp  := hashStamp;
                      resultNumero := nroNoeudParallele;

                      goto ON_VIENT_DE_TROUVER_UN_RESULTAT_A_ANALYSER;

                    end
                  else
                    begin

                      {$IFC AVEC_DEBUG_PARALLELISME}
                      if DoitDebugguerParallelismeDansRapport then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WritelnDansRapport('');
                          WritelnDansRapport('ENTREE de la thread '+NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(nbreVides)+' dans la boucle pour attendre les resultats des fils');
                          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                          WritelnDansRapport('');
                          AttendreFrappeClavierParallelisme(true);
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                      {$ENDC}



                      // BOUCLER POUR ATTENDRE LES RESULTATS DES FILS

                      {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}
                      tickDepart := TickCount;
                      s := 'dans la boucle d''attente des resultats (thread '+ NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(nbreVides)+')';
                      {$ENDC}



                      if (nbreResultatsEnAttente > 0) & not(betaCoupureTrouvee) then
                        begin

                          // ON RENTRE EN ATTENTE PASSIVE

                          dansLaBoucleDAttenteDesResultats := true;

                          // Emettre une proposition de travail. Comme on veut aider un de nos fils
                          // a terminer plus vite (et aussi à cause de l'implementation actuelle
                          // de la gestion des interruptions des threads), on ne postera notre
                          // proposition de travail que pour des petites profondeurs.

                          EmettreUnePropositionDeTravailRecursivePourAiderSesFils(node);


                          while (nbreResultatsEnAttente > 0) & not(betaCoupureTrouvee)
                                {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES} & not(BoucleInfinie(s,tickDepart)) {$ENDC}
                            do
                              begin

                                // Attendre les resultats des fils que l'on a lancés
                                AttendreDesResultatsEnProposantSesServices(node);

                                // Est-on interrompu ?
                                if InterruptionDansCeNoeudDeParallelisme(node) | Quitter | (interruptionReflexion <> pasdinterruption) then
                                  begin

                                    // Il faut enlever la proposition de travail que la thread avait emise en attente passive
                                    EnleverPropositionDeTravailRecursivePourAiderSesFils(nroThreadDuPere);


                                    // On sort de la boucle d'attente des resultats des fils
                                    dansLaBoucleDAttenteDesResultats := false;


                                    {$IFC AVEC_DEBUG_PARALLELISME}
                                    if DoitDebugguerParallelismeDansRapport then
                                      begin
                                        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                                        WritelnDansRapport('SORTIE par interruption {2} de la thread '+NumEnString(nroThreadDuPere)+' : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
                                        WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                                        AttendreFrappeClavierParallelisme(true);
                                        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                                      end;
                                    {$ENDC}

                                    nroDuDernierFilsEvalue := nroDuFilsCourant;
                                    maximum := kValeurSpecialeInterruptionCalculParallele;

                                    exit(GererNoeudDeParallelisme);
                                  end;


                              end; {while}



                          // Il faut enlever la proposition de travail que la thread avait emise en attente passive
                          EnleverPropositionDeTravailRecursivePourAiderSesFils(nroThreadDuPere);

                          // On sort de la boucle d'attente des resultats des fils
                          dansLaBoucleDAttenteDesResultats := false;

                        end;





                      {$IFC AVEC_DEBUG_PARALLELISME}
                      if DoitDebugguerParallelismeDansRapport then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WritelnDansRapport('');
                          WritelnDansRapport('SORTIE de la thread '+NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(nbreVides)+' dans la boucle pour attendre les resultats des fils');
                          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                          WritelnDansRapport('');
                          AttendreFrappeClavierParallelisme(true);
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                      {$ENDC}


                      {$IFC AVEC_VERIFICATIONS_DE_BOUCLES_INFINIES}

                      {$IFC AVEC_DEBUG_PARALLELISME}
                      if (TickCount - tickDepart) > 3000  then   // 50 secondes
                      {$ELSEC}
                      if (TickCount - tickDepart) > 30  then   // une demi-seconde
                      {$ENDC}
                        if DoitDebugguerParallelismeDansRapport then
                          begin
                            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                            WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere) +') : la boucle d''attente des resultats des fils etait trop longue ( >  0.5s)');
                            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                          end;
                      {$ENDC}



                      goto APRES_L_ANALYSE_D_UN_RESULTAT;

                    end;
              end;

          end;


      if betaCoupureTrouvee | ThreadEstInterrompue(nroThreadDuPere, nbreVides) then
        goto APRES_L_ANALYSE_D_UN_RESULTAT;




  ON_VIENT_DE_TROUVER_UN_RESULTAT_A_ANALYSER :


      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}


      // Un resultat vient d'apparaitre dans la queue, ou mon appel recursif vient de se terminer


      onVientDeRecevoirUnVraiResultat := false;


      // On a le resultat d'un noeud !


      {$IFC AVEC_DEBUG_PARALLELISME}
      if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('La thread '+NumEnString(nroThreadDuPere)+' vient de recevoir un résultat : (prof, coupDuFils, result, stamp) = ('+NumEnString(nbreVides)+','+CoupEnStringEnMajuscules(coupDuFils)+','+NumEnString(-resultatDuFils)+','+NumEnString(resultStamp)+')');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      // Chercher quelle thread gerait ce fils

      nroThreadDuFils := kNroThreadNotFound;  {not found !}


      for i := FilsDebut to FilsFin do
        if (listeDesCoupsLegaux[i] = coupDuFils) &                 // la bonne case ? (pourrait sans doute etre avantageusement remplace par un hash du fils)
           (resultStamp = hashStamp) &                             // le bon hash du pere ?
           (resultNumero = nroNoeudParallele) &                    // le bon numero de position ?
           (threadAffecteeACeFils[i] >= 0) then                    // on attendait un resultat de cette thread ?
          begin
            nroThreadDuFils          := threadAffecteeACeFils[i];
            threadAffecteeACeFils[i] := -243;                      // on vient de recevoir le resultat de cette thread, hein...

            {$IFC AVEC_DEBUG_PARALLELISME}
            if DoitDebugguerParallelismeDansRapport then
              begin
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnNumDansRapport('La thread '+NumEnString(nroThreadDuFils)+' (fille) n''est plus affectée, pour le coup '+CoupEnStringEnMajuscules(coupDuFils)+' de la prof '+NumEnString(nbreVides)+', à la thread ',nroThreadDuPere);
                AttendreFrappeClavierParallelisme(true);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              end;
            {$ENDC}

          end;


      if (nroThreadDuFils <> kNroThreadNotFound) &
         (nroThreadDuFils >= 0) &
         (nroThreadDuFils <= kNombreMaxAlphaBetaTasks) &
         not(betaCoupureTrouvee) then
        begin


          // ASSERT : verification que l'on connait bien la thread qui a geré ce fils
          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          if ( nroThreadDuFils = kNroThreadNotFound ) then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : resultat dont on ne connait pas la thread fille dans GererNoeudDeParallelisme !!!!');
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // ASSERT : verifiaction que le resultat que nous venons de recevoir correspond bien
          //          à un job que nous avons donné (comparaison des hashs)
          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          if ( resultStamp <> hashStamp ) then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : (resultStamp <> hashStamp) dans GererNoeudDeParallelisme !!');
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // ASSERT : verifiaction que le resultat que nous venons de recevoir correspond bien
          //          à un job que nous avons donné (comparaison des numeros des positions)
          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          if ( resultNumero <> nroNoeudParallele ) then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : ( resultNumero <> nroNoeudParallele ) dans GererNoeudDeParallelisme !!');
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // ASSERT : verification que le numero de la thread qui a gere ce fils n'est pas débile
          {$IFC USE_ASSERTIONS_DE_PARALLELISME}
          if ( nroThreadDuFils < 0 ) | ( nroThreadDuFils > kNombreMaxAlphaBetaTasks ) then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : ( nroThreadDuFils < 0 ) | ( nroThreadDuFils > kNombreMaxAlphaBetaTasks ) dans GererNoeudDeParallelisme !!  nroThreadDuFils = ',nroThreadDuFils);
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}

          if (resultatDuFils <> kValeurSpecialeInterruptionCalculParallele) &
             (resultatDuFils <> -kValeurSpecialeInterruptionCalculParallele)
             then
               begin

                 onVientDeRecevoirUnVraiResultat := true;

                 valeur := -resultatDuFils;

                 // ASSERT : verification que la valeur retournee n'est pas debile
                {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                if ( valeur < -64 ) | ( valeur > 64 ) then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : ( valeur < -64 ) | ( valeur > 64 ) dans GererNoeudDeParallelisme !!  valeur = ',valeur);
                    Sysbeep(0);
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}

               end;


          // Débile ou pas, le fils que l'on attendait a renvoyé un resultat
          if (nroThreadDuFils <> nroThreadDuPere)
            then dec(nbreResultatsEnAttente);


          // Mettre a jour le meilleur score connu, eventuellement

          if onVientDeRecevoirUnVraiResultat &
            (valeur > maximum) &
            not(betaCoupureTrouvee) then
            begin

              // Ce fils est le meilleur jusqu'a present
              maximum := valeur;
              bestDef := coupDuFils;

              if (valeur > alpha) then
                begin
                  alpha := valeur;  // amelioration de la fenetre

                  if (valeur >= beta) then  // Coupure beta !!
                    begin

                      betaCoupureTrouvee := true;


                      // Mettre eventuellement a jour les statistiques d'overhead algorithmique
                      if (coupDuFils = listeDesCoupsLegaux[filsDebut]) then
                        ATOMIC_INCREMENT_32(gNbreDeCoupuresBetaDansUnSplitNode);


                      nbreResultatsEnAttente := -100;


                      // On vient de trouver une coupure beta : interrompre tous les fils precedents encore en activite

                      InterrompreLesFilsEnActiviteDansCeNoeud(node);


                      // Sortir immediatement de la fonction en renvoyant la valeur qui a provoque la coupure

                      nroDuDernierFilsEvalue := nroDuFilsCourant;
                      maximum := valeur;


                      {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
                      {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[6] := gProfilerParallelisme[6] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}


                      {$IFC AVEC_DEBUG_PARALLELISME}
                      if DoitDebugguerParallelismeDansRapport then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WritelnDansRapport('Sortie par beta-coupure de la thread '+NumEnString(nroThreadDuPere)+' à profondeur '+NumEnString(nbreVides)+' : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
                          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
                          AttendreFrappeClavierParallelisme(true);
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                      {$ENDC}



                      // ASSERT : verification que l'on renvoie bien le bon nroDuDernierFilsEvalue
                      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
                      if ((nroDuDernierFilsEvalue < filsDebut) | (nroDuDernierFilsEvalue > filsFin)) & (action = kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE) then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : sortie prematureee {beta-coupure} de GererNoeudDeParallelisme !!');
                          Sysbeep(0);
                          AttendreFrappeClavierParallelisme(true);
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                      {$ENDC}


                      exit(GererNoeudDeParallelisme);
                    end;
                end;
            end;



          // si le resultat etait le fruit d'un appel recursif a moi-meme, continuer

          if (nroThreadDuFils = nroThreadDuPere)
            then goto APRES_L_ANALYSE_D_UN_RESULTAT;


        end;



    {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[11] := gProfilerParallelisme[11] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}


    if (action <> kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE) & not(onVientDeRecevoirUnVraiResultat) then
      begin

        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('Le resultat reçu à la prof '+NumEnString(nbreVides)+' ne semblant pas correspondre à la position, la thread '+NumEnString(nroThreadDuPere)+' ne voudrait pas déranger... -> sortie de GererNoeudDeParallelisme');
            WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
            WritelnDansRapport('');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}

        exit(GererNoeudDeParallelisme);
      end;


APRES_L_ANALYSE_D_UN_RESULTAT :




    // Est-on interrompu ?
    if InterruptionDansCeNoeudDeParallelisme(node) then
      begin

        {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('Sortie par interruption {3} de la thread '+NumEnString(nroThreadDuPere)+' : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
              WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}

        // ASSERT : verification que l'on renvoie bien le bon nroDuDernierFilsEvalue
        {$IFC USE_ASSERTIONS_DE_PARALLELISME}
        if ((nroDuDernierFilsEvalue < filsDebut) | (nroDuDernierFilsEvalue > filsFin)) & (action = kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE) then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('ASSERT (thread '+NumEnString(nroThreadDuPere)+') : sortie prematureee {3} de GererNoeudDeParallelisme !!');
            Sysbeep(0);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}


        exit(GererNoeudDeParallelisme);
      end;


    // Ecouter eventuellement d'autres resultats
    if (nbreResultatsEnAttente > 0) then
      begin

        if GetAResultAtThisSpecificDepth(nroThreadDuPere,nbreVides,newResult)
          then
            begin
              whichResult := newResult;
              goto RECEVOIR_UN_NOUVEAU_RESULTAT;
            end;

      end;



    // On sait que l'on vient d'avoir une thread qui vient de se liberer,
    // on peut donc lancer un nouveau fils (s'il en reste a lancer) ou
    // continuer d'attendre les resultats des fils dejà lancés (si on a
    // lancé tous les fils)

    if PeutTrouverUneThreadEsclave(node, action, nroThreadFilsDisponible)
      then goto ON_VIENT_DE_TROUVER_UNE_TACHE_AU_CHOMAGE;



    // lancer eventuellement les nouveaux fils en attente

    for i := filsDebut to filsFin do
      if filsEnAttenteDeLancement[i] & not(filsEnCoursDAnnulation[i])
        then goto LANCER_LES_NOUVEAUX_FILS;


    // aller reecouter les resultats

    if (nbreResultatsEnAttente > 0)
      then goto ATTENDRE_LES_RESULTATS;


SORTIE :


    // Sortie normale de GererNoeudDeParallelisme : on renvoie la meilleure note des
    // fils evalués en parallele dans la variable "maximum", et l'index du dernier
    // fils evalué dans "nroDuDernierFilsEvalue".

    nroDuDernierFilsEvalue := nroDuFilsCourant;


    {$IFC AVEC_DEBUG_PARALLELISME}
    if DoitDebugguerParallelismeDansRapport then
      begin
        errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
        WritelnDansRapport('La thread '+NumEnString(nroThreadDuPere)+' sort normalement à la profondeur '+NumEnString(nbreVides)+' de GererNoeudDeParallelisme : (nroThreadDuPere,action) = ('+NumEnString(nroThreadDuPere)+','+NomActionDeParallelisme(action)+')');
        WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
        WritelnDansRapport('');
        AttendreFrappeClavierParallelisme(true);
        errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      end;
    {$ENDC}

  end;



end;




function MySubTreeValue(plat : bitboard; whichHashStamp, nbreVides, alpha, beta, diffPions, vecteurParite, nroThread, nroThreadPere : SInt32; listeBitboard : UInt32) : SInt32;
var valeur : SInt32;
    ticks : SInt32;
    delai : SInt32;
    errDebug : OSStatus;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    hash_table : BitboardHashTable;
begin {$unused delai, ticks, errDebug, nroThreadPere }



  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnDansRapport('');
      WriteDansRapport('Entree dans MySubTreeValue (nroThread, nroThreadPere) = (thread '+NumEnString(nroThread)+', thread '+NumEnString(nroThreadPere)+') : ');

      {
      EcritBitboardState('',plat,nbreVides,alpha,beta,diffPions);
      WritelnNumDansRapport('vecteurParite = ',vecteurParite);
      WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard, nbreVides);
      WritelnNumDansRapport('diffPions recu = ',diffPions);
      with plat do
        WritelnNumDansRapport('diffPions calculé = ',BitboardToDiffPions(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high));
      }

      WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
      WritelnDansRapport('');
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}

  OS_MEMORY_BARRIER;


  gStackParallelisme[nroThread].hashStampACetteProf[nbreVides] := whichHashStamp;


  if ThreadEstInterrompue(nroThread, nbreVides) then
    begin


      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
     (* if DoitDebugguerParallelismeDansRapport then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT : Bizarre ! La thread '+NumEnString(nroThread)+' est interrompue à profondeur '+NumEnString(nbreVides)+' dans MySubTreeValue avant meme d''avoir commencé son calcul...  gAlphaBetaInterrompu[nroThread].prof = ',gAlphaBetaInterrompu[nroThread].profInterruption);
          WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          WritelnDansRapport('');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      *)
      {$ENDC}

      gStackParallelisme[nroThread].hashStampACetteProf[nbreVides] := -2;

      MySubTreeValue := kValeurSpecialeInterruptionCalculParallele;
      exit(MySubTreeValue);
    end;


  if ThreadEstInterrompuePourCeHashStamp(nroThread, whichHashStamp, kEnleverCetteInterruptionPourCetteThread) then
    begin

      {$IFC AVEC_DEBUG_PARALLELISME}
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('Cool, interruption par hashStamp dans MySubTreeValue de la thread '+NumEnString(nroThread)+' pour whichHashStamp = ',whichHashStamp);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
      {$ENDC}

      gStackParallelisme[nroThread].hashStampACetteProf[nbreVides] := -2;

      MySubTreeValue := kValeurSpecialeInterruptionCalculParallele;
      exit(MySubTreeValue);
    end;




  // Debut de la recherche du sous-arbre...

  {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}


  //hash_table := gBitboardHashTable[nroThread];
  hash_table := gBitboardHashTable[0];  // toutes les threads partagent la meme table de hachage


  // parallelisme recursif
  if (nbreVides >= gNbreEmptiesMinimalPourParallelisme)
    then
      valeur := ABFinBitboardParallele(nroThread,plat,nbreVides,alpha,beta,diffPions,vecteurParite,gYoungBrotherWaitElders,listeBitboard,hash_table) // FIXME : gAvecParallelismeSpeculatif ?
    else
      begin
        if (nbreVides <= 14)
          then valeur := ABFinBitboardFastestFirst(nroThread,plat,nbreVides,alpha,beta,diffPions,vecteurParite,listeBitboard,hash_table)
          else valeur := ABFinBitboardFastestFirstAvecETC(nroThread,plat,nbreVides,alpha,beta,diffPions,vecteurParite,listeBitboard,hash_table);
      end;



  // ASSERT : verification que la valeur du calcule n'est pas débile
  {$IFC USE_ASSERTIONS_DE_PARALLELISME}
  if (( valeur < -64 ) | ( valeur > 64 )) & (valeur <> kValeurSpecialeInterruptionCalculParallele) & (valeur <> -kValeurSpecialeInterruptionCalculParallele) then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : ( valeur < -64 ) | ( valeur > 64 ) dans MySubTreeValue !!  valeur = ',valeur);
      Sysbeep(0);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}



  {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}

  gStackParallelisme[nroThread].hashStampACetteProf[nbreVides] := -2;

  // Fin de la recherche du sous-arbre...

  if ThreadEstInterrompue(nroThread, nbreVides)
    then MySubTreeValue := kValeurSpecialeInterruptionCalculParallele
    else MySubTreeValue := valeur;



  {$IFC AVEC_DEBUG_PARALLELISME}
  if DoitDebugguerParallelismeDansRapport then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      if ThreadEstInterrompue(nroThread, nbreVides)
        then WriteDansRapport('INTERRUPTION, dans MySubTreeValue, de la thread '+NumEnString(nroThread))
        else WriteDansRapport('MySubTreeValue : la thread '+NumEnString(nroThread)+' va bientôt renvoyer à la thread '+NumEnString(nroThreadPere)+' la valeur '+NumEnString(-valeur));

      {$IFC AVEC_MESURE_MICROSECONDES}
      WriteDansRapport(', après '+NumEnString(microSecondesFin.lo-microSecondesDepart.lo)+' µsec');
      {$ENDC}

      WritelnDansRapport('');
      WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
      WritelnDansRapport('');
      AttendreFrappeClavierParallelisme(true);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}

end;



procedure EmettreUnePropositionDeTravail(nroThread : SInt32; profondeur : SInt32; const hashStamps : TableauDeQuatreHashStamps; fonctionAppelante : String255);
var errDebug : OSErr;
    h0,h1,h2,h3 : SInt32;
    propositionEnCours : SInt32;
    profPropEnCours : SInt32;
begin


  if EssayerDEmettreUnePropositionDeTravail(nroThread, profondeur, hashStamps)
    then
      begin
        {$IFC AVEC_DEBUG_PARALLELISME}
        if DoitDebugguerParallelismeDansRapport then
          begin
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnNumDansRapport('La thread '+NumEnString(nroThread)+' vient d''emettre une proposition de travail pour la profondeur ',profondeur);
            WritelnDansRapport('     fonctionAppelante = EmettreUnePropositionDeTravail:' + fonctionAppelante);
            WritelnDansRapport('');
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
        {$ENDC}
      end
    else
      begin

        if (gAlphaBetaTasksData^[nroThread].propositionDeTravail <> 1) |
           (gAlphaBetaTasksData^[nroThread].profondeurProposition <> profondeur) |
           ((gAlphaBetaTasksData^[nroThread].hashStampProposition[0] <> hashStamps[0]) &
            (gAlphaBetaTasksData^[nroThread].hashStampProposition[1] <> hashStamps[0]) &
            (gAlphaBetaTasksData^[nroThread].hashStampProposition[2] <> hashStamps[0]) &
            (gAlphaBetaTasksData^[nroThread].hashStampProposition[3] <> hashStamps[0])) then
         begin

            // ASSERT : la thread n'arrive pas a emettre une proposition de travail !!!


            {$IFC AVEC_DEBUG_PARALLELISME}

            propositionEnCours := gAlphaBetaTasksData^[nroThread].propositionDeTravail;
            profPropEnCours    := gAlphaBetaTasksData^[nroThread].profondeurProposition;
            h0                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[0];
            h1                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[1];
            h2                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[2];
            h3                 := gAlphaBetaTasksData^[nroThread].hashStampProposition[3];


            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('ASSERT : la thread '+NumEnString(nroThread)+' n''arrive pas a emettre une proposition de travail !!! ');
            WritelnDansRapport('    fonctionAppelante = EmettreUnePropositionDeTravail:' + fonctionAppelante);
            WritelnNumDansRapport('    proposition en cours = ',propositionEnCours);
            WritelnNumDansRapport('    profondeurProposition = ',profPropEnCours);
            WritelnNumDansRapport('    hashStampProposition[0] = ',h0);
            WritelnNumDansRapport('    hashStampProposition[1] = ',h1);
            WritelnNumDansRapport('    hashStampProposition[2] = ',h2);
            WritelnNumDansRapport('    hashStampProposition[3] = ',h3);
            WritelnNumDansRapport('    profondeur proposition a emettre = ',profondeur);
            WritelnNumDansRapport('    hashStamps[0] = ',hashStamps[0]);
            WritelnNumDansRapport('    hashStamps[1] = ',hashStamps[1]);
            WritelnNumDansRapport('    hashStamps[2] = ',hashStamps[2]);
            WritelnNumDansRapport('    hashStamps[3] = ',hashStamps[3]);

            Sysbeep(0);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            {$ENDC}
         end;

      end;
end;


function EssayerDEmettreUnePropositionDeTravail(nroThread : SInt32; profondeur : SInt32; const hashStamps : TableauDeQuatreHashStamps) : boolean;
var foo_bar_atomic_register : SInt32;
begin
  with gAlphaBetaTasksData^[nroThread] do

    if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0,kValeurMutexEcritureProposition, propositionDeTravail) <> 0)
      then
        begin
          ATOMIC_DECREMENT_32(gNbreProcesseursCalculant);

          profondeurProposition   := profondeur;
          hashStampProposition[0] := hashStamps[0];
          hashStampProposition[1] := hashStamps[1];
          hashStampProposition[2] := hashStamps[2];
          hashStampProposition[3] := hashStamps[3];


          OS_MEMORY_BARRIER;

          propositionDeTravail := 1;

          OS_MEMORY_BARRIER;


          EssayerDEmettreUnePropositionDeTravail := true;
        end
      else
        EssayerDEmettreUnePropositionDeTravail := false;

end;


function CetteThreadAEmisUnePropositionDeTravail(nroThread : SInt32; var profDeLaProposition : SInt32) : boolean;
begin
  // CetteThreadAEmisUnePropositionDeTravail := (ATOMIC_COMPARE_AND_SWAP_32(1,1,gAlphaBetaTasksData^[nroThread].propositionDeTravail) <> 0);

  if (gAlphaBetaTasksData^[nroThread].propositionDeTravail = 1)
    then
      begin
        CetteThreadAEmisUnePropositionDeTravail := true;
        profDeLaProposition := gAlphaBetaTasksData^[nroThread].profondeurProposition;
      end
    else
      CetteThreadAEmisUnePropositionDeTravail := false;
end;


function PrendrePropositionDeTravailDeCetteThread(nroThread : SInt32; nbreCasesVides, hashStamp : SInt32) : boolean;
var errDebug : OSErr;
begin
  PrendrePropositionDeTravailDeCetteThread := false;



  if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(1,kValeurMutexLectureProposition, gAlphaBetaTasksData^[nroThread].propositionDeTravail) <> 0) then
     with gAlphaBetaTasksData^[nroThread] do
        begin

          if ( profondeurProposition >= nbreCasesVides)
            then
              begin

                // la proposition de travail avait assez de cases vides

                if (hashStampProposition[0] = kFairePropositionUniverselleDeTravail) |
                   (hashStamp = kAccepterNimporteQuellePropositionDeTravail) |
                   (hashStamp = hashStampProposition[0]) |
                   (hashStamp = hashStampProposition[1]) |
                   (hashStamp = hashStampProposition[2]) |
                   (hashStamp = hashStampProposition[3])
                   then
                    begin

                      // la proposition de travail nous était destinée, on l'accepte

                      if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureProposition, 0, gAlphaBetaTasksData^[nroThread].propositionDeTravail) = 0)
                        then
                          begin
                            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                            WritelnDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : impossible de remettre le mutex dans PrendrePropositionDeTravailDeCetteThread (1) !!! ');
                            Sysbeep(0);
                            AttendreFrappeClavierParallelisme(true);
                            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                          end;


                      PrendrePropositionDeTravailDeCetteThread := true;

                    end
                  else
                    begin

                      // la proposition de travail ne nous était pas destinée, on la refuse

                      if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureProposition, 1, gAlphaBetaTasksData^[nroThread].propositionDeTravail) = 0)
                        then
                          begin
                            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                            WritelnDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : impossible de remettre le mutex dans PrendrePropositionDeTravailDeCetteThread (2) !!! ');
                            Sysbeep(0);
                            AttendreFrappeClavierParallelisme(true);
                            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                          end;


                    end;

              end
            else
              begin

                // la proposition de travail n'avait pas assez de cases vides, on la refuse

                if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureProposition, 1, gAlphaBetaTasksData^[nroThread].propositionDeTravail) = 0)
                  then
                    begin
                      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                      WritelnDansRapport('ASSERT (thread '+NumEnString(nroThread)+') : impossible de remettre le mutex dans PrendrePropositionDeTravailDeCetteThread (3) !!! ');
                      Sysbeep(0);
                      AttendreFrappeClavierParallelisme(true);
                      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                    end;


              end;


        end;


end;



function PeutTrouverUneThreadDisponible(nroThreadMaitre, nbreCasesVides, hashStamp : SInt32; var nroThreadEsclave : SInt32) : boolean;
var k : SInt32;
    errDebug : OSErr;
    ecoute : OSErr;
    numeroThreadMorte : longintP;
    foo_bar_atomic_register : SInt32;
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesDepart : UnsignedWide; {$ENDC}
    {$IFC AVEC_MESURE_MICROSECONDES} microSecondesFin : UnsignedWide; {$ENDC}

begin

  {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesDepart); {$ENDC}


  OS_MEMORY_BARRIER;


  // D'ABORD CHERCHER SI ON A UNE THREAD DEJA VIVANTE


  if ((hashStamp and 2) <> 0)
    then   // CHERCHER UN NUMERO EN MONTANT...
      begin
        for k := 0 to kNombreMaxAlphaBetaTasks do
          begin
            if (k <> nroThreadMaitre) & not(ThreadEstInterrompue(k,nbreCasesVides)) & PrendrePropositionDeTravailDeCetteThread(k, nbreCasesVides, hashStamp) then
              begin

                // on indique que l'on vient de reserver une thread : elle va tourner sur un processeur
                ATOMIC_INCREMENT_32(gNbreProcesseursCalculant);


                PeutTrouverUneThreadDisponible := true;
                nroThreadEsclave := k;

              //  if ThreadEstInterrompue(k, nbreCasesVides) then SysBeep(0);


                {$IFC AVEC_DEBUG_PARALLELISME}
                if DoitDebugguerParallelismeDansRapport then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnNumDansRapport('La thread '+NumEnString(nroThreadMaitre)+' vient de reserver la thread '+NumEnString(nroThreadEsclave)+' (esclave), j''incremente gNbreProcesseursCalculant : ',gNbreProcesseursCalculant);
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}



                {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
                {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[4] := gProfilerParallelisme[4] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

                exit(PeutTrouverUneThreadDisponible);
              end;
          end
      end
    else  // CHERCHER UN NUMERO EN DESCENDANT... (CECI REPARTIT UN PEU MIEUX LA CHARGE)
      begin
        for k := kNombreMaxAlphaBetaTasks downto 0 do
          begin
            if (k <> nroThreadMaitre) & not(ThreadEstInterrompue(k,nbreCasesVides)) & PrendrePropositionDeTravailDeCetteThread(k, nbreCasesVides, hashStamp) then
              begin

                // on indique que l'on vient de reserver une thread : elle va tourner sur un processeur
                ATOMIC_INCREMENT_32(gNbreProcesseursCalculant);


                PeutTrouverUneThreadDisponible := true;
                nroThreadEsclave := k;

              //  if ThreadEstInterrompue(k, nbreCasesVides) then SysBeep(0);


                {$IFC AVEC_DEBUG_PARALLELISME}
                if DoitDebugguerParallelismeDansRapport then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnNumDansRapport('La thread '+NumEnString(nroThreadMaitre)+' vient de reserver la thread '+NumEnString(nroThreadEsclave)+' (esclave), j''incremente gNbreProcesseursCalculant : ',gNbreProcesseursCalculant);
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}



                {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
                {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[4] := gProfilerParallelisme[4] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

                exit(PeutTrouverUneThreadDisponible);
              end;
          end;
      end;



  OS_MEMORY_BARRIER;


// SINON CHERCHER SI IL Y A UNE THREAD MORTE A REVEILLER

  if (gNbreThreadsReveillees < (numProcessors - 1)) then
    begin

      ecoute := kMPTimeoutErr;

      OS_MEMORY_BARRIER;

      ecoute := MPWaitOnQueue(gListeDesThreadsMortes,@numeroThreadMorte,NIL,NIL,kDurationImmediate);

      if (ecoute = NoErr)  then
        begin

          if (numeroThreadMorte^ < 0) | (numeroThreadMorte^ > kNombreMaxAlphaBetaTasks) then
            begin

              // ASSERT : verification que le numero de la thread morte trouvee n'est pas debile !!!
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadMaitre)+') : (numeroThreadMorte < 0) | (numeroThreadMorte > kNombreMaxAlphaBetaTasks) dans PeutTrouverUneThreadDisponible !!!   numeroThreadMorte = ',numeroThreadMorte^);
              Sysbeep(0);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);


              PeutTrouverUneThreadDisponible := false;
              nroThreadEsclave := -1000;

              exit(PeutTrouverUneThreadDisponible);

            end;



          {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('GESTION DES THREADS : La thread '+NumEnString(nroThreadMaitre)+' va essayer de réveiller la thread '+NumEnString(numeroThreadMorte^)+', qui semble etre en sommeil...');
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // on indique que l'on vient de reserver une thread : elle va tourner sur un processeur
          ATOMIC_INCREMENT_32_BARRIER(gNbreProcesseursCalculant);



          {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('GESTION DES THREADS : Cool, la thread '+NumEnString(nroThreadMaitre)+' a réussi à réveiller la thread '+NumEnString(numeroThreadMorte^)+' et incremente donc gNbreProcesseursCalculant');
              WritelnNumDansRapport('gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}


          // on reveille effectivement la thread
          ecoute := MPSignalSemaphore(gAlphaBetaTasksData^[numeroThreadMorte^].semaphoreDeReveil);

          if (ecoute = NoErr)
            then
              begin

                // on indique que l'on vient de reserver une thread : elle va tourner sur un processeur
                ATOMIC_INCREMENT_32_BARRIER(gNbreThreadsReveillees);

                PeutTrouverUneThreadDisponible := true;
                nroThreadEsclave := numeroThreadMorte^;

                {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
                {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[14] := gProfilerParallelisme[14] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}



                // changement du nombre de thread reveillees
                {$IFC AVEC_DEBUG_PARALLELISME}
                errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                WritelnNumDansRapport('GESTION DES THREADS : Dans PeutTrouverUneThreadDisponible, la thread '+NumEnString(nroThreadMaitre)+' vient d''incrementer gNbreThreadsReveillees = ',gNbreThreadsReveillees);
                AttendreFrappeClavierParallelisme(true);
                errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                {$ENDC}


                exit(PeutTrouverUneThreadDisponible);
              end;



          // ASSERT : impossible de changer le semaphore de reveil dans PeutTrouverUneThreadDisponible !!!
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT (thread '+NumEnString(nroThreadMaitre)+') : impossible de changer le semaphore de réveil dans PeutTrouverUneThreadDisponible !!!  numeroThreadMorte^ = ',numeroThreadMorte^);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);

        end;

    end;


// IL N'Y A VRAIMENT RIEN !!


  PeutTrouverUneThreadDisponible := false;
  nroThreadEsclave := -1000;


  {$IFC AVEC_MESURE_MICROSECONDES} MicroSeconds(microSecondesFin); {$ENDC}
  {$IFC AVEC_MESURE_MICROSECONDES} gProfilerParallelisme[4] := gProfilerParallelisme[4] + (microSecondesFin.lo-microSecondesDepart.lo); {$ENDC}

end;





function GetSemaphoreDeJobAndLock(nroThread : SInt32) : boolean;
begin

  OS_MEMORY_BARRIER;

  if (gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret <> 1)
    then GetSemaphoreDeJobAndLock := false
    else GetSemaphoreDeJobAndLock := (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(1, kValeurMutexLectureJobPret, gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret) <> 0 );

end;



procedure UnlockSemaphoreDeJob(nroThread : SInt32);
var errDebug : OSErr;
begin

  if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureJobPret, 0, gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret) = 0 ) then
    begin
      //if gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret <> 0 then
        begin
          // ASSERT : la thread n'arrive pas a rendre son semaphore de travail !!!
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('ASSERT : la thread '+NumEnString(nroThread)+' n''arrive pas a rendre son semaphore de travail dans UnlockSemaphoreDeJob !!! ');
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
    end;

end;


procedure RelockSemaphoreDeJob(nroThread : SInt32);
var errDebug : OSErr;
begin

  if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureJobPret, 1, gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret) = 0 ) then
    if (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(kValeurMutexLectureJobPret, 1, gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret) = 0 ) then
      begin

        //if gAlphaBetaTasksData^[nroThread].semaphoreDeJobPret <> 0 then
          begin
            // ASSERT : la thread n'arrive pas a rendre son semaphore de travail !!!
            errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
            WritelnDansRapport('ASSERT : la thread '+NumEnString(nroThread)+' n''arrive pas a reverrouiller son semaphore de travail dans RelockSemaphoreDeJob !!! ');
            Sysbeep(0);
            AttendreFrappeClavierParallelisme(true);
            errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          end;
      end;

end;



function JAiTraiteUnJobEnAttente(nroThread : SInt32; profondeurPropositionDeTravail : SInt32; const hashStamps : TableauDeQuatreHashStamps) : boolean;
var
  positionCopie          : bitboard;
  profondeurCopie        : SInt32;
  alphaCopie             : SInt32;
  betaCopie              : SInt32;
  diffPionsCopie         : SInt32;
  vecteurPariteCopie     : SInt32;
  listeBitboardCopie     : UInt32;
  threadDuPereCopie      : SInt32;
  coupCopie              : SInt32;
  hashDuPereCopie        : SInt32;
  nroPosDuPereCopie      : SInt32;
  hashDuFilsCopie        : SInt32;
  valeur                 : SInt32;
begin

  if GetSemaphoreDeJobAndLock(nroThread) then
    begin

      OS_MEMORY_BARRIER;

      // copier les donnes en local

      with gAlphaBetaTasksData^[nroThread].jobRecu do
        begin
          positionCopie          :=  positionSubTree;
          profondeurCopie        :=  profondeurSubTree;
          alphaCopie             :=  alphaSubTree;
          betaCopie              :=  betaSubTree;
          diffPionsCopie         :=  diffPionsSubTree;
          vecteurPariteCopie     :=  vecteurPariteSubTree;
          listeBitboardCopie     :=  listeBitboardSubTree;
          threadDuPereCopie      :=  threadDuPere;
          coupCopie              :=  coupSubTree;
          hashDuPereCopie        :=  hashDuPere;
          hashDuFilsCopie        :=  hashDuFils;
          nroPosDuPereCopie      :=  nroPosDuPere;
        end;

      UnlockSemaphoreDeJob(nroThread);

      EnleverLInterruptionPourCetteThread(nroThread, profondeurCopie, nroThread);

      valeur := MySubTreeValue(positionCopie, hashDuFilsCopie, profondeurCopie, alphaCopie, betaCopie, diffPionsCopie, vecteurPariteCopie, nroThread, threadDuPereCopie, listeBitboardCopie);

      EnleverLInterruptionPourCetteThread(nroThread, profondeurCopie, nroThread);

      if (profondeurPropositionDeTravail <> kNePasFaireDePropositionDeTravail) then
        EmettreUnePropositionDeTravail(nroThread, profondeurPropositionDeTravail, hashStamps,'JAiTraiteUnJobEnAttente');

      PosterUnResultatAUneThread(threadDuPereCopie, nroThread, valeur, coupCopie, hashDuPereCopie, nroPosDuPereCopie, profondeurCopie + 1);

      EnleverLInterruptionPourCetteThread(nroThread, profondeurCopie, nroThread);

      JAiTraiteUnJobEnAttente := true;
      exit(JAiTraiteUnJobEnAttente);

    end;

  JAiTraiteUnJobEnAttente := false;
end;




function CetteThreadEstTuee(nroThread : SInt32) : boolean;
begin
  if (gAlphaBetaTasksData = NIL)
    then CetteThreadEstTuee := true
    else CetteThreadEstTuee := (gAlphaBetaTasksData^[nroThread].nombreMortsDeCetteThread > 0);
end;




function MyAlphaBetaTask( parameter : UnivPtr) : OSStatus;
var err : OSErr;
    errDebug : OSErr;
    p : ParallelAlphaBetaPtr;
    bidHashStamps : TableauDeQuatreHashStamps;
    tickDepart : SInt32;
    tickDepart2 : SInt32;
    foo_bar_atomic_register : SInt32;
    jeVaisMeRendormir : boolean;
    jeViensJusteDeTravailler : boolean;
    jamaisTravaille : boolean;
    propositionDeTravailEmise : boolean;
    endormissementProgressif : SInt32;
    bidon : SInt32;




    procedure FaireUneIterationElementaireDeTravail(nroThread : SInt32; quellePropositionDeTravail : SInt32; var jAiTraiteUnJob : boolean);
    begin
      jAiTraiteUnJob := false;

      if (gAlphaBetaInterrompu[nroThread].profInterruption >= 0)
        then EnleverLInterruptionPourCetteThread(nroThread, kEnleverToutesLesInterruptionsPourCetteThread, nroThread);

      bidHashStamps[0] := kFairePropositionUniverselleDeTravail;
      bidHashStamps[1] := kFairePropositionUniverselleDeTravail;
      bidHashStamps[2] := kFairePropositionUniverselleDeTravail;
      bidHashStamps[3] := kFairePropositionUniverselleDeTravail;

      if JAiTraiteUnJobEnAttente(nroThread, quellePropositionDeTravail, bidHashStamps) then
        begin
          tickDepart := TickCount;
          jAiTraiteUnJob := true;
        end;

      EcouterLesResultatsDansCetteThread(nroThread);
    end;



begin

  // Obtenir un pointeur sur les données de la tache
  p := ParallelAlphaBetaPtr(parameter);

  err := NoErr;

  with p^ do
    begin

      jeVaisMeRendormir := false;  // car pour l'instant on n'a jamais travaille

      // Tant que Cassio ne quitte pas...
      while not(Quitter) and not(CetteThreadEstTuee(nroThread)) do
        begin

          // on indique eventuellement que l'on va se rendormir (apres avoir travaille)

          if jeVaisMeRendormir then
            begin
              ATOMIC_DECREMENT_32(gNbreThreadsReveillees);

              {$IFC AVEC_DEBUG_PARALLELISME}
              if DoitDebugguerParallelismeDansRapport then
                begin
                  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                  WritelnDansRapport('GESTION DES THREADS : La thread '+NumEnString(nroThread) + ' va se rendormir pour cause d''inactivite pendant 3 secondes');
                  errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                end;
              {$ENDC}


              // changement du nombre de thread reveillees
              {$IFC AVEC_DEBUG_PARALLELISME}
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnNumDansRapport('GESTION DES THREADS : Dans MyAlphaBetaTask, la thread '+NumEnString(nroThread)+' vient de décrementer gNbreThreadsReveillees = ',gNbreThreadsReveillees);
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
              {$ENDC}

            end;

          // Indiquer que l'on est une thread morte en attente d'un reveil (en donnant son numero pour pouvoir etre reveillée)

          err := MPNotifyQueue(gListeDesThreadsMortes,Ptr(@nroThread),NIL,NIL);


          {$IFC AVEC_DEBUG_PARALLELISME}
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnDansRapport('GESTION DES THREADS : Dans MyAlphaBetaTask, la thread '+NumEnString(nroThread)+' vient de se mettre dans la liste des threads mortes');
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
          {$ENDC}


          // Attendre sur le semaphore de reveil, en jetant un oeil toutes les secondes
          // pour verifier si une autre thread ne nous avait pas posté un job avant la mort
          // de notre thread...

          endormissementProgressif := 1000;
          repeat

             endormissementProgressif := endormissementProgressif + 100;
             if endormissementProgressif > 1000 then endormissementProgressif := 1000;

             err := MPWaitOnSemaphore(semaphoreDeReveil, endormissementProgressif*kDurationMillisecond);

             if (err = kMPTimeoutErr) then
               begin

                 ATOMIC_INCREMENT_32(gNbreProcesseursCalculant);
                 ATOMIC_INCREMENT_32(gNbreThreadsReveillees);
                 FaireUneIterationElementaireDeTravail(nroThread, kNePasFaireDePropositionDeTravail, jeViensJusteDeTravailler);
                 ATOMIC_DECREMENT_32(gNbreThreadsReveillees);
                 ATOMIC_DECREMENT_32(gNbreProcesseursCalculant);

                 if jeViensJusteDeTravailler then
                   begin
                     endormissementProgressif := 1000;

                     if CetteThreadAEmisUnePropositionDeTravail(nroThread, bidon) then
                       EnleverPropositionDeTravailDeCetteThread(nroThread);

                     {$IFC AVEC_DEBUG_PARALLELISME}
                     if DoitDebugguerParallelismeDansRapport then
                        begin
                          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                          WritelnDansRapport('GESTION DES THREADS : La thread '+NumEnString(nroThread) + ' vient de jeter un oeil dans son sommeil et de traiter un vieux job');
                          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                        end;
                     {$ENDC}
                   end;
               end;

          until (err <> kMPTimeoutErr) or Quitter or CetteThreadEstTuee(nroThread);



          // Ecriture du reveil dans le rapport
          {$IFC AVEC_DEBUG_PARALLELISME}
          if DoitDebugguerParallelismeDansRapport then
            begin
              errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
              WritelnDansRapport('GESTION DES THREADS : La thread '+NumEnString(nroThread)+' dit : « Coucou, je me reveille, what''s up ? »');
              AttendreFrappeClavierParallelisme(true);
              errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
            end;
          {$ENDC}




          tickDepart := TickCount;

          jeVaisMeRendormir := false;
          jamaisTravaille := true;

          // Tant que Cassio ne quitte pas et que la thread n'est pas tuée...
          while not(Quitter) and not(CetteThreadEstTuee(nroThread)) and not(jeVaisMeRendormir) do
            begin


              FaireUneIterationElementaireDeTravail(nroThread, kFairePropositionUniverselleDeTravail, jeViensJusteDeTravailler);

              if jeViensJusteDeTravailler then jamaisTravaille := false;

              if gSpinLocksYieldTimeToCPU then MPYield;


              FaireUneIterationElementaireDeTravail(nroThread, kFairePropositionUniverselleDeTravail , jeViensJusteDeTravailler);  // TODO (POUR LA ROBUSTESSE) ?

              if jeViensJusteDeTravailler then jamaisTravaille := false;


              // Si je n'ai pas recu de travail depuis deux secondes,
              // c'est que je suis sans doute inutile !

              if ((TickCount - tickDepart) > 120) & not(jeViensJusteDeTravailler) then
                begin

                  OS_MEMORY_BARRIER;

                  propositionDeTravailEmise := CetteThreadAEmisUnePropositionDeTravail(nroThread, bidon);

                  if propositionDeTravailEmise | jamaisTravaille then
                    begin

                      jeVaisMeRendormir := true;


                      // Essayer diverses strategies pour verifier que je dois bien me rendormir

                      tickDepart2 := TickCount;

                      while jeVaisMeRendormir & (Tickcount - tickDepart2 <= 120) & not(Quitter) & not(CetteThreadEstTuee(nroThread)) do
                        begin


                          MPYield;

                          // Si je viens de recevoir un job a traiter,
                          // je ne dois certainement pas me rendormir.

                          // if GetSemaphoreDeJobAndLock(nroThread) then
                            // begin
                            //  jeVaisMeRendormir := false;
                            //  tickDepart := TickCount;
                            //  RelockSemaphoreDeJob(nroThread);
                            //end;

                          // Si je m'apercois que j'avais emis une proposition de travail,
                          // et que cette proposition de travail disparait, c'est que l'on
                          // vient de me reserver, et je ne dois certainement pas me rendormir.

                          if jeVaisMeRendormir and propositionDeTravailEmise and not(CetteThreadAEmisUnePropositionDeTravail(nroThread, bidon)) then
                            begin
                              jeVaisMeRendormir := false;
                              tickDepart := TickCount;
                            end;

                        end;


                        // apres une seconde suplementaire, on peut essayer
                        // de voir une derniere fois si on n'a pas un job pret

                        if jeVaisMeRendormir and not(Quitter) and not(CetteThreadEstTuee(nroThread)) then
                          begin

                            OS_MEMORY_BARRIER;

                            FaireUneIterationElementaireDeTravail(nroThread, kFairePropositionUniverselleDeTravail, jeViensJusteDeTravailler);

                            if jeViensJusteDeTravailler then jeVaisMeRendormir := false;

                          end;


                    end;

                end;


            end;  {while}

          OS_MEMORY_BARRIER;

          if CetteThreadAEmisUnePropositionDeTravail(nroThread, bidon)
            then EnleverPropositionDeTravailDeCetteThread(nroThread)
            else
              begin
                ATOMIC_DECREMENT_32_BARRIER(gNbreProcesseursCalculant);


                {$IFC USE_ASSERTIONS_DE_PARALLELISME OR TRUE }
                if jeVaisMeRendormir & not(Quitter) & not(CetteThreadEstTuee(nroThread)) then
                  begin
                    errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                    WritelnDansRapport('ASSERT : Dans MyAlphaBetaTask, la thread '+NumEnString(nroThread)+' va se rendormir alors qu''elle n''a pas de proposition de travail emise... Dommage !!');
                    AttendreFrappeClavierParallelisme(true);
                    errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                  end;
                {$ENDC}

              end;



        end; {while}
    end;  {with p^}

  MyAlphaBetaTask := err;
end;









procedure AllocateMemoryForAlphaBetaTasks;
var err : OSStatus;
    errDestruction : OSStatus;
begin

  // Assume single processor computer
  numProcessors := 1;

  // Initialise globals
  gAlphaBetaTasksData         := NIL;

  gAvecAttenteTouchePourDebuguerParallelisme := false;

  // If the multiprocessing librairy is present then create the tasks
  if CanInitializeOSAtomicUnit &
     MPLibraryIsLoaded &
     (kNombreMaxAlphaBetaTasks > 0) then
    begin


      numProcessors := MPProcessorsScheduled;

      SetNombreDeProcesseursActifs(numProcessors);



      // creer l'emplacement memoire reservé aux tâches
      gAlphaBetaTasksData := ParallelAlphaBetaRecArrayPtr(AllocateMemoryPtrClear((kNombreMaxAlphaBetaTasks + 2) * SizeOf(ParallelAlphaBetaRec)));
      err := MemError;


      // creer les taches
      if (err = noErr) then
         err := CreateAlphaBetaTasks;


      // if something went wrong, just go back to single processor mode
      if (err <> noErr) then
        begin
          errDestruction := StopAlphaBetaTasks;
          numProcessors := 1;
        end;


    end;



  // only one processor is active at the moment, on which the normal, monothreaded Cassio is running
  gNbreProcesseursCalculant    := 1;


  // Toutes les taches que l'on a lancees sont en attente sur leur semaphore de sommeil pour le moment
  gNbreThreadsReveillees       := 0;


  // Nous n'avons pour l'instant traite aucune position en parallele
  gNroPositionParallele        := 0;

end;






function CreateAlphaBetaTasks : OSStatus;
var err : OSStatus;
    bidErr : OSStatus;
    i,k : SInt32;
begin

  if (gAlphaBetaTasksData = NIL)
    then err := -1
    else err := noErr;


  // initialisation des pointeurs
  if err = NoErr then
    begin
      for i := 0 to kNombreMaxAlphaBetaTasks do
        if (gAlphaBetaTasksData <> NIL) then
          begin
            gAlphaBetaInterrompu[i].profInterruption          := kPasDInterrumptionPourCetteThread;
            gAlphaBetaInterrompu[i].hashStampInterruption     := kPasDInterrumptionPourCetteThread;
            gAlphaBetaInterrompu[i].positions.cardinal        := 0;
            for k := 0 to 15 do
              gAlphaBetaInterrompu[i].positions.hashStamps[k] := 0;
            gMutexEcritureInterruptionThread[i]               := 0;
            gAlphaBetaTasksData^[i].semaphoreDeReveil         := NIL;
            gAlphaBetaTasksData^[i].taskID                    := NIL;
            gAlphaBetaTasksData^[i].semaphoreDeJobPret        := 0;
            gAlphaBetaTasksData^[i].nombreMortsDeCetteThread  := 0;
            gAlphaBetaTasksData^[i].propositionDeTravail      := 0;
            gAlphaBetaTasksData^[i].profondeurProposition     := kFairePropositionUniverselleDeTravail;
            gAlphaBetaTasksData^[i].hashStampProposition[0]   := kFairePropositionUniverselleDeTravail;
            gAlphaBetaTasksData^[i].hashStampProposition[1]   := kFairePropositionUniverselleDeTravail;
            gAlphaBetaTasksData^[i].hashStampProposition[2]   := kFairePropositionUniverselleDeTravail;
            gAlphaBetaTasksData^[i].hashStampProposition[3]   := kFairePropositionUniverselleDeTravail;

            for k := 0 to 63 do
              gStackParallelisme[i].hashStampACetteProf[k]    := -2;


            // on implementente la file les resultats comme une liste FIFO
            with gFileDesResultats[i] do
              begin
                mutex_modif_de_la_file := 0;
                cardinal               := 0;
                tete                   := 0;
                queue                  := 0;
                for k := 0 to kNombreMaxResultasDansUneFile - 1 do
                  begin
                    resultats[k].valeurResultat := kValeurSpecialeInterruptionCalculParallele;
                    resultats[k].coup           := 0;
                    resultats[k].hashPere       := 0;
                    resultats[k].numeroPere     := 0;
                    resultats[k].profondeur     := 0;
                  end;
              end;
          end;
    end;



  // creer la file de validation de destruction des taches
  if (err = noErr) then
     err := MPCreateQueue(gTerminaisonDesTaches);


  // creer la file des threads initialement mortes
  if (err = noErr) then
     err := MPCreateQueue(gListeDesThreadsMortes);


  // creer la region critique d'ecriture dans le rapport pour le debugage
  if (err = noErr) then
     err := MPCreateCriticalRegion(gRapportCriticalRegionID);


  // creer le mutex d'affichage des valeurs de debugage du parallelisme
  gMesureDeParallelsimeMutex := 0;


  // lancement des taches esclaves, pour les processeurs 1 .. (nombreProcesseurs - 1)

  for i := 1 to kNombreMaxAlphaBetaTasks do
    if (err = noErr) then
        begin

          gAlphaBetaTasksData^[i].nroThread := i;

          if (err = noErr) then err := MPCreateSemaphore(1,0,gAlphaBetaTasksData^[i].semaphoreDeReveil);

          if (err = noErr) then err := MPCreateTask(MyAlphaBetaTask,
                                                    @gAlphaBetaTasksData^[i],
                                                    kMPStackSize,
                                                    gTerminaisonDesTaches, NIL, NIL,
                                                    kMPTaskOptions,
                                                    @gAlphaBetaTasksData^[i].taskID);

        end;


  // if something went wrong, just go back to single processor mode
  if (err <> noErr) then
    begin
      WritelnNumDansRapport('ERROR ! Assert : (err <> noErr) dans CreateAlphaBetaTasks, err = ',err);
      bidErr := StopAlphaBetaTasks;
      numProcessors := 1;
    end;


  // only one processor is active at the moment, on which the normal, monothreaded Cassio is running
  gNbreProcesseursCalculant    := 1;


  // Toutes les taches que l'on a lancees sont en attente sur leur semaphore de sommeil pour le moment
  gNbreThreadsReveillees       := 0;


  CreateAlphaBetaTasks := err;

end;



procedure LibereMemoireForAlphaBetaTasks;
begin
  if gAlphaBetaTasksData <> NIL then
    begin

      DisposeMemoryPtr(Ptr(gAlphaBetaTasksData));
      gAlphaBetaTasksData := NIL;

    end;
end;


function StopAlphaBetaTasks : OSStatus;
var i : UInt32;
    err : OSStatus;
begin

   {WritelnDansRapport('Entree dans StopAlphaBetaTasks');}

  err := noErr;

  if gAlphaBetaTasksData <> NIL then
    begin

      for i := 1 to kNombreMaxAlphaBetaTasks do
        with gAlphaBetaTasksData^[i] do
          begin

            if (taskID <> NIL) then
              begin

                // avant de reveiller la thread, on lui indique qu'elle vient d'etre tuee
                inc(gAlphaBetaTasksData^[i].nombreMortsDeCetteThread);
                inc(gAlphaBetaTasksData^[i].nombreMortsDeCetteThread);

                // on reveille effectivement la thread, si necessaire
                err := MPSignalSemaphore(gAlphaBetaTasksData^[i].semaphoreDeReveil);

                if (gTerminaisonDesTaches <> NIL) then
                  err := MPWaitOnQueue(gTerminaisonDesTaches, NIL, NIL, NIL, kDurationForever);
              end;


            if (semaphoreDeReveil <> NIL)
              then err := MPDeleteSemaphore(semaphoreDeReveil);


          end;


    end;


  if (gListeDesThreadsMortes <> NIL) then
    begin
      err := MPDeleteQueue(gListeDesThreadsMortes);
      gListeDesThreadsMortes := NIL;
    end;

  if (gTerminaisonDesTaches <> NIL) then
    begin
      err := MPDeleteQueue(gTerminaisonDesTaches);
      gTerminaisonDesTaches := NIL;
    end;

  if (gRapportCriticalRegionID <> NIL) then
    begin
      err := MPDeleteCriticalRegion(gRapportCriticalRegionID);
      gRapportCriticalRegionID := NIL;
    end;



  StopAlphaBetaTasks := err;

  // WritelnDansRapport('Sortie de StopAlphaBetaTasks');

end;


procedure PointDeMesureDeParallelisme;
var errDebug : OSStatus;
    foo_bar_atomic_register : SInt32;
begin

(*
  if FALSE then
    begin

      // On incremente les compteurs

      ATOMIC_INCREMENT_32(gNbreAppelsMesureDeParallelisme);
      ATOMIC_ADD_32(gNbreProcesseursCalculant,gDegreDeParallelisme);

      if (gNbreProcesseursCalculant > numProcessors) then
        ATOMIC_INCREMENT_32(gFraisDeSynchronisation);


      // pas de blague d'overflow, hein...
      if (gDegreDeParallelisme < 0) | (gNbreAppelsMesureDeParallelisme < 0) | (gFraisDeSynchronisation < 0) then
        begin
          gNbreAppelsMesureDeParallelisme := 0;
          gDegreDeParallelisme := 0;
          gFraisDeSynchronisation := 0;
        end;



      // ASSERT : verification que Cassio a au moins un processeur actif... pouf pouf
      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
      if (gNbreProcesseursCalculant < 0) then
        begin
          errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
          WritelnNumDansRapport('ASSERT : (gNbreProcesseursCalculant < 0) dans PointDeMesureDeParallelisme !!  gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
          Sysbeep(0);
          AttendreFrappeClavierParallelisme(true);
          errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}


      // ASSERT : verification que Cassio n'a pas lancé plus de taches que de processeurs physiques...
      {$IFC USE_ASSERTIONS_DE_PARALLELISME}
      if (gNbreProcesseursCalculant > numProcessors) then
        begin  // TODO
     //     errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
     //     WritelnNumDansRapport('ASSERT : (gNbreProcesseursCalculant > numProcessors) dans PointDeMesureDeParallelisme !!  gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
     //     Sysbeep(0);
     //     AttendreFrappeClavierParallelisme(true);
     //     errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
        end;
      {$ENDC}




     // if (gNbreAppelsMesureDeParallelisme mod 1024) = 0
     //   then EcrireMesureDeParallelismeDansRapport;

  end;

*)

end;


function TauxDeParallelisme : double_t;
begin
  if (gNbreAppelsMesureDeParallelisme <> 0)
    then TauxDeParallelisme := 100.0*(1.0*gDegreDeParallelisme/(1.0*gNbreAppelsMesureDeParallelisme))
    else TauxDeParallelisme := 0.0;
end;


function FraisDeSynchro : double_t;
begin
  if (gNbreAppelsMesureDeParallelisme <> 0)
    then FraisDeSynchro := 100.0*(1.0*gFraisDeSynchronisation/(1.0*gNbreAppelsMesureDeParallelisme))
    else FraisDeSynchro := 0.0;
end;


function ParallelismeUtile : double_t;
begin
  ParallelismeUtile := TauxDeParallelisme - FraisDeSynchro;
end;


procedure EcrireMesureDeParallelismeDansRapport;
begin
  if (gNbreAppelsMesureDeParallelisme <> 0)
    then WritelnStringAndReelDansRapport('// = ',TauxDeParallelisme, 8)
    else WritelnDansRapport(' non disponible');
end;


procedure EcrireFraisDeSynchronisationDansRapport;
begin
  if (gNbreAppelsMesureDeParallelisme <> 0)
    then WritelnStringAndReelDansRapport('∑ = ',FraisDeSynchro, 8)
    else WritelnDansRapport(' non disponible');
end;


procedure EcrireParallelismeUtileDansRapport;
begin
  if (gNbreAppelsMesureDeParallelisme <> 0)
    then WritelnStringAndReelDansRapport('',ParallelismeUtile, 8)
    else WritelnDansRapport(' non disponible');
end;


procedure AfficherLesSpinlocksDuParallelisme;
var i : SInt32;
    s : String255;
begin



  if ATOMIC_COMPARE_AND_SWAP_32(0, 1, gMesureDeParallelsimeMutex) <> 0 then
    begin

      if windowPlateauOpen then
        begin

         (*
          for i := 0 to kNombreMaxAlphaBetaTasks do
            begin
              s := 'etat de la thread '+NumEnString(i)+' = ';

              WriteNumAt('                                                                                                                          ',0,365,300+i*10);
              WriteNumAt(s,gAlphaBetaTasksData^[i].etat,365,300+i*10);
            end;
          *)

          s := 'nombre de mutex utilisés sur la table de hachage = ';
          WriteNumAt(s,NumberOfBitHashMutexLocksInUse,365,300+(kNombreMaxAlphaBetaTasks+2)*10);

          s := 'nombre de processeurs calculants = ';
          WriteNumAt(s,gNbreProcesseursCalculant,365,300+(kNombreMaxAlphaBetaTasks+3)*10);


          for i := 0 to kNombreDeProfilersDuParallelisme do
            begin
              s := 'gProfilerParallelisme['+NumEnString(i)+'] = ';

              WriteNumAt(s,gProfilerParallelisme[i],15,300+i*10);
            end;


          for i := 0 to kNombreMaxAlphaBetaTasks do
            begin
              s := 'gFileDesResultats['+NumEnString(i)+'] = ';

              WriteNumAt(s,gFileDesResultats[i].cardinal,225,300+i*10);
            end;

        end;



      if ATOMIC_COMPARE_AND_SWAP_32(1, 0, gMesureDeParallelsimeMutex) <> 0 then DoNothing;
    end;



end;


procedure AttendreFrappeClavierParallelisme(attenteTouche : boolean);
var errDebug : OSErr;
begin   {$unused attenteTouche}


  {AfficherLesSpinlocksDuParallelisme;}
  {if WaitNextEvent(0,fooEventParallelisme,2,NIL) then DoNothing;}


  FlushWindow(wPlateauPtr);

  // ASSERT : verification que Cassio a au moins un processeur actif... pouf pouf
  {$IFC USE_ASSERTIONS_DE_PARALLELISME}
  if (gNbreProcesseursCalculant < 0) then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      WritelnNumDansRapport('ASSERT : (gNbreProcesseursCalculant < 0) dans AttendreFrappeClavierParallelisme !!  gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
      Sysbeep(0);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}


  // ASSERT : verification que Cassio n'a pas lancé plus de taches que de processeurs physiques...
  {$IFC USE_ASSERTIONS_DE_PARALLELISME}
  if (gNbreProcesseursCalculant > numProcessors) then
    begin  // TODO
      // errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      // WritelnNumDansRapport('ASSERT : (gNbreProcesseursCalculant > numProcessors) dans AttendreFrappeClavierParallelisme !!  gNbreProcesseursCalculant = ',gNbreProcesseursCalculant);
      // Sysbeep(0);
      // errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
  {$ENDC}

  (*
  if attenteTouche & gAvecAttenteTouchePourDebuguerParallelisme
    then
      begin
        AttendFrappeClavier;
      end;
  *)
end;


function DoitDebugguerParallelismeDansRapport : boolean;
begin
  if (kVerbosityLevelAlgoParallele >= 3) & (nbreNoeudsGeneresFinale >= kNombreDeNoeudMinimalPourSuiviDansRapport)
    then
      begin
        DoitDebugguerParallelismeDansRapport := true;

        //WritelnDansRapport('DoitDebugguerParallelismeDansRapport = true');
      end
    else
      begin
        DoitDebugguerParallelismeDansRapport := false;

        //WritelnDansRapport('DoitDebugguerParallelismeDansRapport = false');

        // mais on affiche quand meme les spin-locks du parallelisme dans la fenetre de l'othellier
        {AttendreFrappeClavierParallelisme(false);}
      end;
end;


function OrdinateurMultiprocesseurSimuleSurUnMonoprocesseur : boolean;
begin
  OrdinateurMultiprocesseurSimuleSurUnMonoprocesseur := (numProcessors > MPProcessorsScheduled);
end;


////////// EXEMPLE DE CODE D'APPLE : CALCULATING INTERTASK SIGNALING TIME ////////////



type reflectOPType = (aQueue, aSemaphore, anEvent);

var reflectOP : reflectOPType;
    waiterID, postID : MPOpaqueID;


function Reflector(parameter : UnivPtr) : OSStatus;
var p1, p2, p3 : Ptr;
    events : MPEventFlags;
    err : OSStatus;
begin {$UNUSED parameter}
  while (true) do
    begin

      case reflectOP of
        aQueue :     err := MPWaitOnQueue(MPQueueID(waiterID),@p1,@p2,@p3,kDurationForever);
        aSemaphore : err := MPWaitOnSemaphore(MPSemaphoreID(waiterID),kDurationForever);
        anEvent :    err := MPWaitForEvent(MPEventID(waiterID), @events,kDurationForever);
        otherwise    return (-123);
      end; {case}

      case reflectOP of
        aQueue :     err := MPNotifyQueue(MPQueueID(postID),p1,p2,p3);
        aSemaphore : err := MPSignalSemaphore(MPSemaphoreID(postID));
        anEvent :    err := MPSetEvent(MPEventID(postID), $01010101);
        otherwise    return (-123);
      end; {case}

    end;

  return (-123);
end;



procedure TesterLaFileDesResultatsDuParallelisme;
var nroThread : SInt32;
    err : OSErr;
    whichResult : ResultParallelismeRec;
begin

  err := StopAlphaBetaTasks;

  WritelnDansRapport('Entree dans TesterLaFileDesResultatsDuParallelisme :');
  WritelnDansRapport('Avant le test de la file des résultats : tapez une touche');
  AttendFrappeClavier;

  debug_file_des_resultats := false;



  nroThread := 3;

  PosterUnResultatAUneThread(nroThread,0,2,StringEnCoup('A1'),123,0,17);




  PosterUnResultatAUneThread(nroThread,1,2,StringEnCoup('A2'),123,10,17);


  PosterUnResultatAUneThread(nroThread,2,2,StringEnCoup('A3'),123,20,18);


  PosterUnResultatAUneThread(nroThread,3,2,StringEnCoup('A4'),123,30,18);


  PosterUnResultatAUneThread(nroThread,4,2,StringEnCoup('A5'),123,40,19);


  PosterUnResultatAUneThread(nroThread,5,2,StringEnCoup('A6'),123,50,19);



  PosterUnResultatAUneThread(nroThread,6,2,StringEnCoup('A7'),123,60,20);


  PosterUnResultatAUneThread(nroThread,7,2,StringEnCoup('A8'),123,70,20);


  PosterUnResultatAUneThread(nroThread,8,2,StringEnCoup('B1'),123,80,21);


  PosterUnResultatAUneThread(nroThread,9,2,StringEnCoup('B2'),123,90,21);


  PosterUnResultatAUneThread(nroThread,10,2,StringEnCoup('B3'),123,100,22);


  PosterUnResultatAUneThread(nroThread,11,2,StringEnCoup('B4'),123,110,22);


  PosterUnResultatAUneThread(nroThread,12,2,StringEnCoup('B5'),123,120,23);

  debug_file_des_resultats := true;


  PosterUnResultatAUneThread(nroThread,13,2,StringEnCoup('B6'),123,130,23);


  PosterUnResultatAUneThread(nroThread,14,2,StringEnCoup('B7'),123,140,24);


  PosterUnResultatAUneThread(nroThread,15,2,StringEnCoup('B8'),123,150,24);


  if GetAResultAtThisSpecificDepth(3,19,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 19')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat a prof 19');


  if GetAResultAtThisSpecificDepth(3,19,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 19')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat a prof 19');


  PosterUnResultatAUneThread(nroThread,0,2,StringEnCoup('C1'),123,160,25);


  PosterUnResultatAUneThread(nroThread,10,2,StringEnCoup('C2'),123,170,25);


  PosterUnResultatAUneThread(nroThread,10,2,StringEnCoup('C3'),123,180,26);


  if GetAnyResultForThisThread(3,whichResult)
    then  WritelnNumDansRapport('La thread 3 a trouve un resultat, profResultat = ',whichResult.profondeur)
    else  WritelnDansRapport('La thread 3 n''a plus de resultats');



  if GetAnyResultForThisThread(3,whichResult)
    then  WritelnNumDansRapport('La thread 3 a trouve un resultat, profResultat = ',whichResult.profondeur)
    else  WritelnDansRapport('La thread 3 n''a plus de resultats');


  if GetAResultAtThisSpecificDepth(3,19,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 19')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 19');


  if GetAResultAtThisSpecificDepth(3,19,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 19')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 19');

  if GetAResultAtThisSpecificDepth(3,21,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 21')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 21');


  if GetAResultAtThisSpecificDepth(3,21,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 21')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 21');


  if GetAResultAtThisSpecificDepth(3,25,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 25')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 25');

  if GetAResultAtThisSpecificDepth(3,25,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 25')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 25');


  if GetAResultAtThisSpecificDepth(3,25,whichResult)
    then  WritelnDansRapport('La thread 3 a pris un resultat specifique a prof 25')
    else  WritelnDansRapport('La thread 3 n''avait pas de résultat specifique a prof 25');

  PosterUnResultatAUneThread(nroThread,11,2,StringEnCoup('C4'),123,170,26);


  PosterUnResultatAUneThread(nroThread,11,2,StringEnCoup('C5'),123,180,27);



  WritelnDansRapport('Fin du test : tapez une touche');
  AttendFrappeClavier;

  WritelnDansRapport('Fin du test : tapez une touche');
  AttendFrappeClavier;

  debug_file_des_resultats := false;

end;




procedure CalculateIntertaskSignalingTime;
var err : OSStatus;
    task : MPTaskID;
    count,i : SInt32;
    p1,p2,p3 : Ptr;
    events : MPEventFlags;
begin

  WritelnDansRapport('entrée dans CalculateIntertaskSignalingTime…');
  WritelnDansRapport('');

  if not(MPLibraryIsLoaded) then
    begin
      WritelnDansRapport('The MP library did not load.');
      exit(CalculateIntertaskSignalingTime);
    end;

    WritelnDansRapport('Librairie multiprocessing chargée...   OK');


    // QUEUES

    WritelnDansRapport('');
    WritelnDansRapport('Essai de synchronisation par des QUEUES : ');
    WritelnDansRapport('');

    reflectOP := aQueue;
    err := MPCreateQueue(MPQueueID(waiterID));
    err := MPCreateQueue(MPQueueID(postID));


    WritelnDansRapport('temps de création du process (peut varier significativement) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(1);

    err := MPCreateTask(Reflector,NIL,0,NIL,NIL,NIL,kNilOptions,@task);

    StopChronometreRelatif(1);

    if (err <> noErr) then
      begin
        WritelnDansRapport('Task not created.');
        exit(CalculateIntertaskSignalingTime);
      end;

    WritelnDansRapport('temps de 100000 synchronisation (queues) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(2);

    count := 100000;
    for i := 1 to count do
      begin
        err := MPNotifyQueue(MPQueueID(waiterID),NIL,NIL,NIL);
        repeat
          err := MPWaitOnQueue(MPQueueID(postID),@p1,@p2,@p3,kDurationImmediate);
        until (err <> kMPTimeoutErr);
      end;

    StopChronometreRelatif(2);

    err := MPTerminateTask(task, 123);


    // SEMAPHORE

    WritelnDansRapport('');
    WritelnDansRapport('Essai de synchronisation par des SEMAPHORES : ');
    WritelnDansRapport('');

    reflectOP := aSemaphore;
    err := MPCreateSemaphore(1,0,MPSemaphoreID(waiterID));
    err := MPCreateSemaphore(1,0,MPSemaphoreID(postID));

    WritelnDansRapport('temps de création du process (peut varier significativement) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(3);

    err := MPCreateTask(Reflector,NIL,0,NIL,NIL,NIL,kNilOptions,@task);

    StopChronometreRelatif(3);

    if (err <> noErr) then
      begin
        WritelnDansRapport('Task not created.');
        exit(CalculateIntertaskSignalingTime);
      end;

    WritelnDansRapport('temps de 100000 synchronisation (sémaphores) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(4);

    count := 100000;
    for i := 1 to count do
      begin
        err := MPSignalSemaphore(MPSemaphoreID(waiterID));
        repeat
          err := MPWaitOnSemaphore(MPSemaphoreID(postID),kDurationImmediate);
        until (err <> kMPTimeoutErr);
      end;

    StopChronometreRelatif(4);

    err := MPTerminateTask(task, 123);


    // EVENT GROUP

    WritelnDansRapport('');
    WritelnDansRapport('Essai de synchronisation par des EVENT GROUPS : ');
    WritelnDansRapport('');

    reflectOP := anEvent;
    err := MPCreateEvent(MPEventID(waiterID));
    err := MPCreateEvent(MPEventID(postID));

    WritelnDansRapport('temps de création du process (peut varier significativement) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(5);

    err := MPCreateTask(Reflector,NIL,0,NIL,NIL,NIL,kNilOptions,@task);

    StopChronometreRelatif(5);

    if (err <> noErr) then
      begin
        WritelnDansRapport('Task not created.');
        exit(CalculateIntertaskSignalingTime);
      end;

    WritelnDansRapport('temps de 100000 synchronisation (event groups) : ');
    WritelnDansRapport('');
    BeginChronometreRelatif(6);

    count := 100000;
    for i := 1 to count do
      begin
        err := MPSetEvent(MPEventID(waiterID),$01);
        repeat
          err := MPWaitForEvent(MPEventID(postID),@events,kDurationImmediate);
        until (err <> kMPTimeoutErr);
      end;

    StopChronometreRelatif(6);

    err := MPTerminateTask(task, 123);

    WritelnDansRapport('');
    WritelnDansRapport('Sortie de CalculateIntertaskSignalingTime');
end;



{$pragmac  optimization_level reset }



END.






















































