UNIT UnitDefEngine;


INTERFACE


USES MacTypes, StringTypes, UnitDefCassio, CFBase, UnitDefLongString;


{ variable globale, vaut 0 si Cassio n'utilise aucun moteur }
var numeroEngineEnCours    : SInt32;

{ tester l'etat d'un moteur }
const ENGINE_STARTING    = 1;
      ENGINE_RUNNING     = 2;
      ENGINE_STOPPED     = 3;
      ENGINE_KILLED      = 4;


{ commnunication avec le pont vers les moteurs externes : traduction en Pascal des types de fonction C }
type GetBackOutputCallBackType                 = procedure (theCString : Ptr);
     StartEngineProcPtr                        = function (path : CFStringRef; arguments : CFStringRef) : SInt32;
     SuspendEngineProcPtr                      = procedure;
     ResumeEngineProcPtr                       = procedure;
     SendDataToEngineProcPtr                   = procedure (data : CFStringRef);
     SetCallBackForEngineProcPtr               = procedure (callBack : GetBackOutputCallBackType);
     SwitchToEngineProcPtr                     = procedure (channelNumber : SInt16);


{ pointeurs de fonctions dans le bundle qui implemente le pont }
var myStartEnginePtr           : StartEngineProcPtr;
    mySuspendEnginePtr         : SuspendEngineProcPtr;
    myResumeEnginePtr          : ResumeEngineProcPtr;
    mySendDataToEnginePtr      : SendDataToEngineProcPtr;
    mySetCallBackForEnginePtr  : SetCallBackForEngineProcPtr;
    mySwitchToEnginePtr        : SwitchToEngineProcPtr;



{ gestion de la file FIFO des resultats du moteur }
const  kValeurMutexEcritureResultatEngine                  = -1;
       kValeurMutexLectureResultatEngine                   = -2;
const  kNombreMaxResultatsDansFileEngine = 400;

type FileResultatsEngineRec = record
                                mutex_modif_de_la_file : SInt32;
                                cardinal               : SInt32;
                                tete                   : SInt32;
                                queue                  : SInt32;
                                resultats              : array[0..kNombreMaxResultatsDansFileEngine - 1] of LongString;
                              end;


{ type de donnees d'une recherche pour le moteur }
type EngineSearchRec = record
                         typeDeRecherche       : SInt32;  { = ReflMilieu (midgame) ou ReflParfait (endgame) }
                         utilisationDansCassio : SInt32;
                         position              : PositionEtTraitRec;
                         alpha                 : SInt32;
                         beta                  : SInt32;
                         precision             : SInt32;
                         depth                 : SInt32;
                         lastMove              : SInt32;
                         empties               : SInt32;
                       end;


{ type de donnees decrivant un moteur }
type EngineRec = record
                   path                    : String255;
                   state                   : SInt32;
                   suspendCount            : SInt32;
                   lastStringReceived      : LongString;
                   lastSearchSent          : EngineSearchRec;
                   lastCommandSent         : String255;
                   lastStringSent          : String255;
                   lastDateOfActivity      : SInt32;
                   lastDateOfStarting      : SInt32;
                   lastDateOfPinging       : SInt32;
                   lastDateOfSearchStart   : SInt32;
                   CassioIsWaitingAResult  : boolean;
                   readyReceived           : boolean;
                   fileResultats           : FileResultatsEngineRec;
                   mutex_reception_data    : SInt32;
                   speed                   : double_t;  {en kilonodes par seconde}
                   durationOfLastResult    : double_t;  {en secondes}
                   nbStartsOfEngine        : SInt32;
                   nbQuitCommandsSent      : SInt32;
                 end;


{ type de donnees d'un resultat pour le moteur }
type EngineResultRec = record
                         typeResult      : SInt32;   { = ReflMilieu (midgame) ou ReflParfait (endgame) }
                         position        : PositionEtTraitRec;
                         candidateMove   : SInt32;
                         depth           : SInt32;
                         precision       : SInt32;
                         colorOfValue    : SInt32;
                         minorantOfValue : SInt32;
                         majorantOfValue : SInt32;
                         line            : String255;
                         kilonodes       : double_t;
                         time            : double_t;
                       end;

{ une globale contenant l'enregistrement decrivant le moteur }
var engine : EngineRec;


{ gestion des exclusions mutuelles pour la reception des octets venant des moteurs }
const kValeurMutexReceptionDataEngine                  = -1;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}



END.













