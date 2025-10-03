UNIT UnitDefParallelisme;


INTERFACE



USES MacTypes, StringTypes, Multiprocessing, UnitBitboardTypes;



const kMPStackSize                                  = 17408;     // use 17 Kb of stack size
      kMPTaskOptions                                = 0;         // use no options


      kValeurSpecialeInterruptionCalculParallele    = -757575;   // a negative magic number
      kNroThreadNotFound                            = -33;
      kPasDInterrumptionPourCetteThread             = -1;        // MUST be strictly negative
      kPourToutesLesThreads                         = -400;
      kEnleverToutesLesInterruptionsPourCetteThread = 100;
      kEnleverCetteInterruptionPourCetteThread      = 101;
      kNePasEnleverCetteInterruptionPourCetteThread = 102;


      kFairePropositionUniverselleDeTravail         = 200;       // MUST be > 64
      kNePasFaireDePropositionDeTravail             = 201;
      kAccepterNimporteQuellePropositionDeTravail   = -1;


      kNombreMaxAlphaBetaTasks                      = 15;
   //   kNombreMaxAlphaBetaTasks                      = 1;
      kNombreDeTableHachageBitboard                 = 1;         // mettre 1 si toutes les threads partagent la meme table, sinon le nombre de threads plus un
      kNombreDeProfilersDuParallelisme              = 20;
      kNombreMaxResultasDansUneFile                 = 31;


      kPleaseGoSleeping                             = 2000;
      kPleaseWaitForJobPreparation                  = 2001;
      kPleaseExploreThisSubtree                     = 2002;
      kPleaseDoSpinLock                             = 2003;
      kPleaseTryParallelisingASon                   = 2004;
      kNoOrderReceived                              = 2005;
      kAnyState                                     = 2006;


      kValeurMutexEcritureResultat                  = -1;
      kValeurMutexLectureResultat                   = -2;

      kValeurMutexLectureJobPret                    = -3;
      kValeurMutexEcritureJobPret                   = -4;

      kValeurMutexEcritureProposition               = -5;
      kValeurMutexLectureProposition                = -6;


      kVerbosityLevelAlgoParallele                  = 3;
      kNombreDeNoeudMinimalPourSuiviDansRapport     = 0;    // par exemple 126287514;


      kNombreMutexAccesBitboard                     = 512;      // doit etre une puissance de deux
      kMutexAccesBitboardMask                       = kNombreMutexAccesBitboard - 1;


      kEVALUER_TOUTE_LA_POSITION_EN_PARALLELE       = 1;
      kTROUVER_D_AUTRES_TACHES_AU_CHOMAGE           = 2;
      kRECEVOIR_UN_NOUVEAU_RESULTAT                 = 3;
      kANALYSER_UN_RESULTAT                         = 4;
      kCONTINUER_NORMALEMENT                        = 5;
      kLANCER_LES_FILS_EN_ATTENTE                   = 6;



type NoeudDeParallelisme = record
                             nroThreadDuPere                    : SInt32;
                             nbreVides                          : SInt32;
                             alpha, beta                        : SInt32;
                             diffPions                          : SInt32;
                             filsDebut,filsFin                  : SInt32;
                             nroDuFilsCourant                   : SInt32;
                             maximum                            : SInt32;
                             pos_my_bits_low,pos_my_bits_high   : SInt32;
                             pos_opp_bits_low,pos_opp_bits_high : SInt32;
                             listeBitboard                      : UInt32;
                             vecteurParite                      : SInt32;
                             nbreResultatsEnAttente             : SInt32;
                             threadAffecteeACeFils              : array[0..31] of SInt32;
                             hashStampDeCeFils                  : array[0..31] of SInt32;
                             filsEnAttenteDeLancement           : array[0..31] of boolean;
                             filsEnCoursDAnnulation             : array[0..31] of boolean;
                             listeDesCoupsLegaux                : listeVides;
                             hashStamp                          : SInt32;
                             nroNoeudParallele                  : SInt32;
                             bestDef                            : UInt32;
                             nroDuDernierFilsEvalue             : SInt32;
                             betaCoupureTrouvee                 : boolean;
                             dansLaBoucleDAttenteDesResultats   : boolean;
                             reserved                           : array[0..7] of SInt32;  // to reach 128 bytes
                           end;

    TableauDeQuatreHashStamps = array[0..3] of SInt32;



    ParalleJobDescriptionRec = record
                                 positionSubTree         : bitboard;
                                 profondeurSubTree       : SInt32;
                                 alphaSubTree            : SInt32;
                                 betaSubTree             : SInt32;
                                 diffPionsSubTree        : SInt32;
                                 vecteurPariteSubTree    : SInt32;
                                 listeBitboardSubTree    : UInt32;
                                 threadDuPere            : SInt32;
                                 coupSubTree             : SInt32;
                                 hashDuPere              : SInt32;
                                 nroPosDuPere            : SInt32;
                                 hashDuFils              : SInt32;
                               end;


    ParallelAlphaBetaRec = record
                              nroThread                : SInt32;
                              jobRecu                  : ParalleJobDescriptionRec;
                              propositionDeTravail     : SInt32;
                              profondeurProposition    : SInt32;
                              hashStampProposition     : TableauDeQuatreHashStamps;
                              semaphoreDeJobPret       : SInt32;
                              nombreMortsDeCetteThread : SInt32;
                              semaphoreDeReveil        : MPSemaphoreID;
                              taskID                   : MPTaskID;
                              reserved                 : array[0..6] of SInt32;  // to reach 128 bytes
                            end;

     ParallelAlphaBetaPtr = ^ParallelAlphaBetaRec;
     ParallelAlphaBetaRecArray = array[0..0] of ParallelAlphaBetaRec;
     ParallelAlphaBetaRecArrayPtr = ^ParallelAlphaBetaRecArray;

     ResultParallelismeRec = record
                               valeurResultat : SInt32;
                               coup           : SInt32;
                               hashPere       : SInt32;
                               numeroPere     : SInt32;
                               profondeur     : SInt32;
                               reserved       : array[0..2] of SInt32;   // to reach 32 bytes
                             end;


     StackParallelismeRec = array[0..63] of SInt32;





     FileResultatsParallelismeRec = record
                                      mutex_modif_de_la_file : SInt32;
                                      cardinal               : SInt32;
                                      tete                   : SInt32;
                                      queue                  : SInt32;
                                      resultats              : array[0..kNombreMaxResultasDansUneFile - 1] of ResultParallelismeRec;
                                      reserved               : array[0..3] of SInt32;   // to reach 1024 bytes
                                    end;




var gTerminaisonDesTaches                       : MPQueueID;
    gListeDesThreadsMortes                      : MPQueueID;
    gAlphaBetaTasksData                         : ParallelAlphaBetaRecArrayPtr;


    numProcessors                               : SInt32;

    gNbreThreadsReveillees                      : SInt32;
    gNroPositionParallele                       : SInt32;

    CassioUtiliseLeMultiprocessing              : boolean;
    gSpinLocksYieldTimeToCPU                    : boolean;
    gAvecParallelismeSpeculatif                 : boolean;
    gAvecAttenteTouchePourDebuguerParallelisme  : boolean;

    gRapportCriticalRegionID                    : MPCriticalRegionID;
    gMesureDeParallelsimeMutex                  : SInt32;

    gAlphaBetaInterrompu                        : array[0..kNombreMaxAlphaBetaTasks*32] of
                                                    record
                                                      profInterruption      : SInt32;
                                                      hashStampInterruption : SInt32;
                                                      positions             : record
                                                                                cardinal : SInt32;
                                                                                hashStamps : array[0..15] of SInt32;
                                                                              end;
                                                    end;

    gStackParallelisme                          : array[0..kNombreMaxAlphaBetaTasks] of
                                                    record
                                                      hashStampACetteProf : StackParallelismeRec;
                                                      // pereDeCetteProf     : StackParallelismeRec;
                                                    end;


    gMutexEcritureInterruptionThread            : array[0..kNombreMaxAlphaBetaTasks*32] of SInt32;




    gFileDesResultats                           : array[0..kNombreMaxAlphaBetaTasks] of FileResultatsParallelismeRec;


    gNombreDeCoupuresBetaPresquesSures          : SInt32;
    gNombreDeCoupuresBetaReussies               : SInt32;

    gNbreAppelsMesureDeParallelisme             : SInt32;
    gDegreDeParallelisme                        : SInt32;
    gNbreDeSplitNodes                           : SInt32;
    gNbreDeCoupuresBetaDansUnSplitNode          : SInt32;
    gNbreDeSplitNodesRates                      : SInt32;
    gFraisDeSynchronisation                     : SInt32;
    gFractionParallelisableMicroSecondes        : SInt32;
    gFractionParallelisableSecondes             : SInt32;
    gNbreDeToursPourAttendreUneMicroseconde     : SInt32;
    gNbreMaxDInterruptions                      : SInt32;


    gYoungBrotherWaitElders                     : SInt32;
    gNbreEmptiesMinimalPourParallelisme         : SInt32;
    gExtensionDeParallelisme                    : SInt32;
    gExtensionDeCoupureBetaProbable             : SInt32;



    gBitboardHashTable                          : array[0..kNombreDeTableHachageBitboard-1] of BitboardHashTable;
    gMutexAccesBitboardHash                     : array[0..kNombreMutexAccesBitboard*16] of SInt32;


    gProfilerParallelisme                       : array[0..kNombreDeProfilersDuParallelisme] of SInt32;


    gNoeudsDeParallelisme                       : array[0..kNombreMaxAlphaBetaTasks, 0..64] of NoeudDeParallelisme;

    gNbreProcesseursCalculant                   : SInt32;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}










END.


































