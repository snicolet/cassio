UNIT UnitDefUnixTask;


INTERFACE


USES MacTypes, StringTypes, UnitDefCassio, CFBase, UnitDefLongString;


{ variable globale, vaut 0 si Cassio n'utilise aucune tache Unix }
var numeroUnixTaskEnCours    : SInt32;


{ tester l'etat d'un moteur }
const UNIX_TASK_STARTING    = 1;
      UNIX_TASK_RUNNING     = 2;
      UNIX_TASK_STOPPED     = 3;
      UNIX_TASK_KILLED      = 4;


{ commnunication avec le pont vers les moteurs externes : traduction en Pascal des types de fonction C }
type GetUnixTaskBackOutputCallBackType           = procedure (theCString : Ptr);
     StartUnixTaskProcPtr                        = function (path : CFStringRef; arguments : CFStringRef) : SInt32;
     SuspendUnixTaskProcPtr                      = procedure;
     ResumeUnixTaskProcPtr                       = procedure;
     SendDataToUnixTaskProcPtr                   = procedure (data : CFStringRef);
     SetCallBackForUnixTaskProcPtr               = procedure (callBack : GetUnixTaskBackOutputCallBackType);
     SwitchToUnixTaskProcPtr                     = procedure (channelNumber : SInt16);


{ pointeurs de fonctions dans le bundle qui implemente le pont }
var myStartUnixTaskPtr           : StartUnixTaskProcPtr;
    mySuspendUnixTaskPtr         : SuspendUnixTaskProcPtr;
    myResumeUnixTaskPtr          : ResumeUnixTaskProcPtr;
    mySendDataToUnixTaskPtr      : SendDataToUnixTaskProcPtr;
    mySetCallBackForUnixTaskPtr  : SetCallBackForUnixTaskProcPtr;
    mySwitchToUnixTaskPtr        : SwitchToUnixTaskProcPtr;




{ type de donnees decrivant un moteur }
type UnixTaskRec = record
                   path                    : String255;
                   state                   : SInt32;
                   suspendCount            : SInt32;
                   lastStringReceived      : LongString;
                   lastCommandSent         : String255;
                   lastStringSent          : String255;
                   lastDateOfActivity      : SInt32;
                   lastDateOfStarting      : SInt32;
                   lastDateOfPinging       : SInt32;
                   lastDateOfSearchStart   : SInt32;
                   mutex_reception_data    : SInt32;
                   nbStartsOfUnixTask      : SInt32;
                   nbQuitCommandsSent      : SInt32;
                 end;



{ une globale contenant l'enregistrement decrivant le moteur }
var unixTask : UnixTaskRec;


{ gestion des exclusions mutuelles pour la reception des octets venant des taches Unix }
const kValeurMutexReceptionDataUnixTask                  = -1;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}



END.













