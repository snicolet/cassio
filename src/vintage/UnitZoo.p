UNIT UnitZoo;


INTERFACE





USES UnitDefCassio, UnitDefCFNetworkHTTP;



{ initialisation de l'unite }
procedure InitUnitZoo;                                                                                                                                                           ATTRIBUTE_NAME('InitUnitZoo')
procedure LibereMemoireUnitZoo;                                                                                                                                                  ATTRIBUTE_NAME('LibereMemoireUnitZoo')
function CassioDoitRentrerEnContactAvecLeZoo : boolean;                                                                                                                          ATTRIBUTE_NAME('CassioDoitRentrerEnContactAvecLeZoo')
procedure SetCassioDoitRentrerEnContactAvecLeZoo(s : String255);                                                                                                                 ATTRIBUTE_NAME('SetCassioDoitRentrerEnContactAvecLeZoo')


{ flag indiquant si Cassio est en train de calculer pour le zoo }
function CassioEstEnTrainDeCalculerPourLeZoo : boolean;                                                                                                                          ATTRIBUTE_NAME('CassioEstEnTrainDeCalculerPourLeZoo')
procedure SetCassioEstEnTrainDeCalculerPourLeZoo(newValue : boolean; oldValue : BooleanPtr);                                                                                     ATTRIBUTE_NAME('SetCassioEstEnTrainDeCalculerPourLeZoo')
function CassioEstEnTrainDeDebuguerLeZooEnLocal : boolean;                                                                                                                       ATTRIBUTE_NAME('CassioEstEnTrainDeDebuguerLeZooEnLocal')
procedure SetCassioEstEnTrainDeDebugguerLeZooEnLocal(flag : boolean);                                                                                                            ATTRIBUTE_NAME('SetCassioEstEnTrainDeDebugguerLeZooEnLocal')
function GetCalculCourantDeCassioPourLeZoo : LongString;                                                                                                                         ATTRIBUTE_NAME('GetCalculCourantDeCassioPourLeZoo')
function HashDuCalculCourantDeCassioPourLeZoo : UInt64;                                                                                                                          ATTRIBUTE_NAME('HashDuCalculCourantDeCassioPourLeZoo')
function ProfDuCalculCourantDeCassioPourLeZoo : SInt32;                                                                                                                          ATTRIBUTE_NAME('ProfDuCalculCourantDeCassioPourLeZoo')


{ determinons si Cassio peut donner du temps CPU au zoo }
function CassioPeutDonnerDuTempsAuZoo : boolean;                                                                                                                                 ATTRIBUTE_NAME('CassioPeutDonnerDuTempsAuZoo')
procedure SetDateDerniereEcouteDeResultatsDuZoo(date : SInt32);                                                                                                                  ATTRIBUTE_NAME('SetDateDerniereEcouteDeResultatsDuZoo')
function DateDernierEnvoiDeResultatAuZoo : SInt32;                                                                                                                               ATTRIBUTE_NAME('DateDernierEnvoiDeResultatAuZoo')
function DateDerniereDemandeDeJobAuZoo : SInt32;                                                                                                                                 ATTRIBUTE_NAME('DateDerniereDemandeDeJobAuZoo')
function DateDernierPingAuZoo : SInt32;                                                                                                                                          ATTRIBUTE_NAME('DateDernierPingAuZoo')
function DateDernierKeepAliveAuZoo : SInt32;                                                                                                                                     ATTRIBUTE_NAME('DateDernierKeepAliveAuZoo')
function TempsTotalConsacreAuZoo : double_t;                                                                                                                                     ATTRIBUTE_NAME('TempsTotalConsacreAuZoo')
function TempsUtileConsacreAuZoo : double_t;                                                                                                                                     ATTRIBUTE_NAME('TempsUtileConsacreAuZoo')
function TempsDeMidgameConsacreAuZoo : double_t;                                                                                                                                 ATTRIBUTE_NAME('TempsDeMidgameConsacreAuZoo')
function NombreTotalDeJobsCalculesPourLeZoo : SInt32;                                                                                                                            ATTRIBUTE_NAME('NombreTotalDeJobsCalculesPourLeZoo')
function NombreDeJobsEndgameTriviauxCalculesPourLeZoo : SInt32;                                                                                                                  ATTRIBUTE_NAME('NombreDeJobsEndgameTriviauxCalculesPourLeZoo')
function NombreDeJobsMidgameCalculesPourLeZoo : SInt32;                                                                                                                          ATTRIBUTE_NAME('NombreDeJobsMidgameCalculesPourLeZoo')


{ statut de Cassio en tant qu'agent du zoo }
function GetZooStatus : String255;                                                                                                                                               ATTRIBUTE_NAME('GetZooStatus')
procedure SetZooStatus(const status : String255);                                                                                                                                ATTRIBUTE_NAME('SetZooStatus')
function CalculateZooStatusPourCetEtatDeCassio : String255;                                                                                                                      ATTRIBUTE_NAME('CalculateZooStatusPourCetEtatDeCassio')
procedure VerifierLeStatutDeCassioPourLeZoo;                                                                                                                                     ATTRIBUTE_NAME('VerifierLeStatutDeCassioPourLeZoo')
procedure SetIntervalleVerificationDuStatutDeCassioPourLeZoo(ticks : SInt32; oldValue : SInt32Ptr);                                                                              ATTRIBUTE_NAME('SetIntervalleVerificationDuStatutDeCassioPourLeZoo')


{ gestion de la connection permanente au serveur OthelloZoo }
procedure OuvrirConnectionPermanenteAuZoo;                                                                                                                                       ATTRIBUTE_NAME('OuvrirConnectionPermanenteAuZoo')
function SerialiserMessagesDuZoo(theFile : FichierAbstraitPtr; buffer : Ptr; from : SInt32; var lenBuffer : SInt32) : OSErr;                                                     ATTRIBUTE_NAME('SerialiserMessagesDuZoo')
function LibererMemoireConnectionPermanenteAuZoo(whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;                                                          ATTRIBUTE_NAME('LibererMemoireConnectionPermanenteAuZoo')


{ envoi des requetes au serveur }
function GetZooURL : String255;                                                                                                                                                  ATTRIBUTE_NAME('GetZooURL')
procedure EnvoyerUneRequeteAuZoo(var requete : LongString);                                                                                                                      ATTRIBUTE_NAME('EnvoyerUneRequeteAuZoo')
procedure EnvoyerUneRequeteAuZooParTelechargementHTML(var requete : LongString);                                                                                                 ATTRIBUTE_NAME('EnvoyerUneRequeteAuZooParTelechargementHTML')
procedure RetryEnvoyerUneRequeteAuZoo(var requete : LongString);                                                                                                                 ATTRIBUTE_NAME('RetryEnvoyerUneRequeteAuZoo')
function GetDerniereRequeteEnvoyeeAuZoo : LongString;                                                                                                                            ATTRIBUTE_NAME('GetDerniereRequeteEnvoyeeAuZoo')
procedure SetDerniereRequeteEnvoyeeAuZoo(var s : LongString);                                                                                                                    ATTRIBUTE_NAME('SetDerniereRequeteEnvoyeeAuZoo')
procedure EncoderSearchParamsPourURL(var searchParams : MakeEndgameSearchParamRec; var urlParams : String255; fonctionAppelante : String255);                                    ATTRIBUTE_NAME('EncoderSearchParamsPourURL')
procedure CalculateHashOfSearchParams(var searchParams : MakeEndgameSearchParamRec);                                                                                             ATTRIBUTE_NAME('CalculateHashOfSearchParams')
procedure DetruireLeZoo;                                                                                                                                                         ATTRIBUTE_NAME('DetruireLeZoo')


{ requetes pour garder la connection ouverte sur le serveur }
procedure VerifierLePoussageDesRequetesAuZoo;                                                                                                                                    ATTRIBUTE_NAME('VerifierLePoussageDesRequetesAuZoo')
procedure EnvoyerUneRequeteDePoussageAuZoo;                                                                                                                                      ATTRIBUTE_NAME('EnvoyerUneRequeteDePoussageAuZoo')
procedure EnvoyerUnPingSiNecessaire;                                                                                                                                             ATTRIBUTE_NAME('EnvoyerUnPingSiNecessaire')
procedure EnvoyerUnKeepAliveSiNecessaire;                                                                                                                                        ATTRIBUTE_NAME('EnvoyerUnKeepAliveSiNecessaire')


{ reception des requetes du serveur }
function AcknowledgementOfZooTransaction(whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;                                                                      ATTRIBUTE_NAME('AcknowledgementOfZooTransaction')
procedure TraiterZooTransaction(ligne : LongString; var fic : FichierAbstrait; var mustResendRequest : boolean);                                                                    ATTRIBUTE_NAME('TraiterZooTransaction')
function FindWordInTransaction(mot : String255; ligne : LongString; var fic : FichierAbstrait; afficherTouteLaRequete : boolean) : boolean;                                         ATTRIBUTE_NAME('FindWordInTransaction')
function PeutParserDemandeDeJob(const ligne : LongString; var searchParams : MakeEndgameSearchParamRec) : boolean;                                                               ATTRIBUTE_NAME('PeutParserDemandeDeJob')
function PeutParserUnResultatDuZoo(const ligne : LongString; var params : MakeEndgameSearchParamRec; var action,moves,timestamp : String255) : boolean;                          ATTRIBUTE_NAME('PeutParserUnResultatDuZoo')
procedure ParserLesResultatsDuZoo(ligne : LongString; var fic : FichierAbstrait);                                                                                                   ATTRIBUTE_NAME('ParserLesResultatsDuZoo')
procedure ParserLesPositionStoppeesDuZoo(ligne : LongString; var fic : FichierAbstrait);                                                                                            ATTRIBUTE_NAME('ParserLesPositionStoppeesDuZoo')
procedure ParserLesPrefetchEncoreUtiles(ligne : LongString; var fic : FichierAbstrait);                                                                                             ATTRIBUTE_NAME('ParserLesPrefetchEncoreUtiles')
procedure TraiterPositionInchargeDuZoo(const ligne : LongString);                                                                                                                ATTRIBUTE_NAME('TraiterPositionInchargeDuZoo')
procedure EndgameSearchParamToZooJob(var searchParams : MakeEndgameSearchParamRec; var zooJob : ZooJobRec);                                                                      ATTRIBUTE_NAME('EndgameSearchParamToZooJob')
procedure ViderZooJob(var zooJob : ZooJobRec);                                                                                                                                   ATTRIBUTE_NAME('ViderZooJob')


{ lancement d'un calcul local pour le zoo }
procedure TraiterJobDuZoo(const s : LongString);                                                                                                                                 ATTRIBUTE_NAME('TraiterJobDuZoo')
procedure PrefetchJobDuZoo(const s : LongString);                                                                                                                                ATTRIBUTE_NAME('PrefetchJobDuZoo')
function DoitInterrompreCalculPourLeZoo(const s : LongString) : boolean;                                                                                                         ATTRIBUTE_NAME('DoitInterrompreCalculPourLeZoo')
procedure VerifierUtiliteCalculPourLeZoo(alsoCheckPretch : boolean);                                                                                                             ATTRIBUTE_NAME('VerifierUtiliteCalculPourLeZoo')
function LancerCalculCommeClientPourLeZoo(zooJob : ZooJobRec) : OSStatus;                                                                                                        ATTRIBUTE_NAME('LancerCalculCommeClientPourLeZoo')
procedure LancerCalculDeMilieuCommeClientPourLeZoo(var zooJob : ZooJobRec);                                                                                                      ATTRIBUTE_NAME('LancerCalculDeMilieuCommeClientPourLeZoo')
procedure LancerCalculDeFinaleCommeClientPourLeZoo(var zooJob : ZooJobRec);                                                                                                      ATTRIBUTE_NAME('LancerCalculDeFinaleCommeClientPourLeZoo')



{ reponse au zoo donnant le resultat d'un calcul }
function EnvoyerResultatDuCalculAuZoo(var zooJob : ZooJobRec; score : SInt32) : OSStatus;                                                                                        ATTRIBUTE_NAME('EnvoyerResultatDuCalculAuZoo')
function SExcuserAupresDuZoo(var zooJob : ZooJobRec; const reason : String255) : OSStatus;                                                                                       ATTRIBUTE_NAME('SExcuserAupresDuZoo')
function SExcuserAupresDuZooPourLaPositionPrefetched(const reason : String255) : OSStatus;                                                                                       ATTRIBUTE_NAME('SExcuserAupresDuZooPourLaPositionPrefetched')
function SExcuserAupresDuZooPourCetteHash(const whichHash : UInt64; const reason : String255) : OSStatus;                                                                        ATTRIBUTE_NAME('SExcuserAupresDuZooPourCetteHash')
procedure AjouterHashDansCacheDesScoresEnvoyesAuZoo(const whichHash : UInt64);                                                                                                   ATTRIBUTE_NAME('AjouterHashDansCacheDesScoresEnvoyesAuZoo')
function FindHashDansCacheDesScoresEnvoyesAuZoo(const whichHash : UInt64) : boolean;                                                                                             ATTRIBUTE_NAME('FindHashDansCacheDesScoresEnvoyesAuZoo')


{ cache des positions prefetch par le zoo }
function FindZooJobDansCacheDesPrefetch(whichHash : UInt64; var index : SInt32) : boolean;                                                                                       ATTRIBUTE_NAME('FindZooJobDansCacheDesPrefetch')
function FindUnJobInutileDansCacheDesPrefetch(var index : SInt32) : boolean;                                                                                                     ATTRIBUTE_NAME('FindUnJobInutileDansCacheDesPrefetch')
function GetPrefetchImportantPasEncoreCalcule : LongString;                                                                                                                      ATTRIBUTE_NAME('GetPrefetchImportantPasEncoreCalcule')
procedure AjouterDansCacheDesPrefetch(const params : MakeEndgameSearchParamRec; const job : LongString);                                                                         ATTRIBUTE_NAME('AjouterDansCacheDesPrefetch')
function GetJobDansCacheDesPrefetch(index : SInt32) : LongString;                                                                                                                ATTRIBUTE_NAME('GetJobDansCacheDesPrefetch')
procedure VerifierLocalementLaFileDesPrefetchs;                                                                                                                                  ATTRIBUTE_NAME('VerifierLocalementLaFileDesPrefetchs')
procedure EnvoyerUneRequetePourVerifierLeCacheDesPrefetch;                                                                                                                       ATTRIBUTE_NAME('EnvoyerUneRequetePourVerifierLeCacheDesPrefetch')
procedure RetirerCeJobDuCacheDesPositionsPrefetchUtiles(whichHash : UInt64);                                                                                                     ATTRIBUTE_NAME('RetirerCeJobDuCacheDesPositionsPrefetchUtiles')
procedure GetOccupationDuCacheDesPrefetch(var nbPositionDansCache,profMin,profMax : SInt32);                                                                                     ATTRIBUTE_NAME('GetOccupationDuCacheDesPrefetch')
function NumberOfPrefetch : SInt32;                                                                                                                                              ATTRIBUTE_NAME('NumberOfPrefetch')



{ affichage des infos du zoo dans le rapport et la fenetre gestion du temps }
procedure SetVerbosityOfZoo(value : SInt32);                                                                                                                                     ATTRIBUTE_NAME('SetVerbosityOfZoo')
function VerbosityOfZoo : SInt32;                                                                                                                                                ATTRIBUTE_NAME('VerbosityOfZoo')
procedure BeginRapportPourZoo;                                                                                                                                                   ATTRIBUTE_NAME('BeginRapportPourZoo')
procedure EndRapportPourZoo;                                                                                                                                                     ATTRIBUTE_NAME('EndRapportPourZoo')
procedure WriteTickOperationPourLeZooDansRapport;                                                                                                                                ATTRIBUTE_NAME('WriteTickOperationPourLeZooDansRapport')
procedure MettreAJourLeTempsDeReponseDuZoo;                                                                                                                                      ATTRIBUTE_NAME('MettreAJourLeTempsDeReponseDuZoo')
procedure WritelnFenetreAlphaBetaDansRapport(alpha,beta : SInt32);                                                                                                               ATTRIBUTE_NAME('WritelnFenetreAlphaBetaDansRapport')
procedure AfficherEtatDuZooDansFenetreGestionDuTemps(s : String255);                                                                                                             ATTRIBUTE_NAME('AfficherEtatDuZooDansFenetreGestionDuTemps')
procedure AfficherTouteLaTransactionDansRapport(var fic : FichierAbstrait);                                                                                                         ATTRIBUTE_NAME('AfficherTouteLaTransactionDansRapport')




{ interface avec le reste de Cassio }
procedure EcouterLesResultatsDuZoo;                                                                                                                                              ATTRIBUTE_NAME('EcouterLesResultatsDuZoo')
procedure ZooWantsToStartANewTest;                                                                                                                                               ATTRIBUTE_NAME('ZooWantsToStartANewTest')
procedure DemanderUnJobAuZoo;                                                                                                                                                    ATTRIBUTE_NAME('DemanderUnJobAuZoo')
procedure GererLeZoo;                                                                                                                                                            ATTRIBUTE_NAME('GererLeZoo')
procedure BoucleDeLancementsDesCalculsLocauxPourLeZoo;                                                                                                                           ATTRIBUTE_NAME('BoucleDeLancementsDesCalculsLocauxPourLeZoo')
function DemandeDeCalculPourLeZooDansLaFileLocale(var job : LongString) : boolean;                                                                                               ATTRIBUTE_NAME('DemandeDeCalculPourLeZooDansLaFileLocale')
procedure TransfererPositionPrefetchedDuZooDansLaFileLocale;                                                                                                                     ATTRIBUTE_NAME('TransfererPositionPrefetchedDuZooDansLaFileLocale')
procedure EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo(const fonctionAppelante : String255);                                                                              ATTRIBUTE_NAME('EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo')
procedure EnvoyerUneRequetePourPrendreMoiMemeUnCalculDuZoo(const whichHashes : String255);                                                                                       ATTRIBUTE_NAME('EnvoyerUneRequetePourPrendreMoiMemeUnCalculDuZoo')
procedure EnvoyerUneRequetePourArreterDesCalculsDuZoo(const whichHashes : String255);                                                                                            ATTRIBUTE_NAME('EnvoyerUneRequetePourArreterDesCalculsDuZoo')
procedure EnvoyerUneRequetePourArreterUnCalculDuZoo(whichHash : UInt64);                                                                                                         ATTRIBUTE_NAME('EnvoyerUneRequetePourArreterUnCalculDuZoo')
procedure EnvoyerUneRequetePourArreterTousMesCalculsDuZoo;                                                                                                                       ATTRIBUTE_NAME('EnvoyerUneRequetePourArreterTousMesCalculsDuZoo')



{ utilitaires pour parser/envoyer des résultats au zoo }
function JobIsEmpty(const job : LongString) : boolean;                                                                                                                           ATTRIBUTE_NAME('JobIsEmpty')
function SameJobs(const job1, job2 : LongString) : boolean;                                                                                                                      ATTRIBUTE_NAME('SameJobs')
function ProbCutStringDuZooEnMuString(cut : String255) : String255;                                                                                                              ATTRIBUTE_NAME('ProbCutStringDuZooEnMuString')
function MuStringEnProbCutStringDuZoo(mu : String255) : String255;                                                                                                               ATTRIBUTE_NAME('MuStringEnProbCutStringDuZoo')
function GetParameterStringInResultatDuZoo(const parameterName : String255; buffer : PackedArrayOfCharPtr; bufferSize : SInt32) : String255;                                     ATTRIBUTE_NAME('GetParameterStringInResultatDuZoo')
procedure SetHashValueDuZoo(var hash : UInt64; value : SInt32);                                                                                                                  ATTRIBUTE_NAME('SetHashValueDuZoo')
function HashValueDuZooEstNegative(const hash : UInt64) : boolean;                                                                                                               ATTRIBUTE_NAME('HashValueDuZooEstNegative')
function HashValueDuZooEstCorrecte(const hash : UInt64) : boolean;                                                                                                               ATTRIBUTE_NAME('HashValueDuZooEstCorrecte')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, Sound, Timer
{$IFC NOT(USE_PRELINK)}
    , UnitHashing, UnitPositionEtTrait, UnitRapport, UnitGestionDuTemps, UnitModes, UnitMilieuDePartie, UnitScannerUtils, UnitCouleur
    , UnitEntreeTranscript, UnitScannerUtils, UnitFichierAbstrait, UnitCFNetworkHTTP, UnitBaseNouveauFormat, MyStrings, UnitHashing, SNEvents
    , MyStrings, MyMathUtils, UnitRapportImplementation, UnitZooAvecArbre, UnitAffichageReflexion, UnitSolve, UnitServicesMemoire, UnitLongString
    , UnitEngine, UnitServicesRapport, UnitFichiersTEXT, UnitTestZoo, UnitTournoi, UnitHashTableExacte, UnitBaseOfficielle
    , UnitSolitaire ;
{$ELSEC}
    ;
    {$I prelink/Zoo.lk}
{$ENDC}


{END_USE_CLAUSE}









var gZoo : record
                dateDernierReleveDeJobSurLeZoo                 : SInt32;
                dateDerniereVerificationUtiliteCalculPourLeZoo : SInt32;
                dateDerniereEcouteDeResultatsSurLeZoo          : SInt32;
                dateDernierEnvoiDeResultatSurLeZoo             : SInt32;
                dateDernierEnvoiDePingSurLeZoo                 : SInt32;
                dateDernierEnvoiDeKeepAliveSurLeZoo            : SInt32;
                dateDernierPoussageDeRequete                   : SInt32;
                dateDerniereVerificationDuStatutPourLeZoo      : SInt32;
                intervalleReleveDeJobSurLeZoo                  : SInt32;
                intervalleVerificationUtiliteCalculPourLeZoo   : SInt32;
                intervalleEnvoiDeDemandesAuZoo                 : SInt32;
                intervalleEcouteDeResultatsSurLeZoo            : SInt32;
                intervalleEnvoiDeResultatSurLeZoo              : SInt32;
                intervalleEnvoiDePingSurLeZoo                  : SInt32;
                intervalleEnvoiDeKeepAliveSurLeZoo             : SInt32;
                intervallePoussageDeRequete                    : SInt32;
                intervalleVerificationDuStatutPourLeZoo        : SInt32;
                nbJobsCommences                                : SInt32;
                nbJobsMidgame                                  : SInt32;
                nbJobsEndgameTriviaux                          : SInt32;
                tempsTotalDesJobsUtilesPourLeZoo               : double_t;
                tempsTotalDeCalculPourLeZoo                    : double_t;
                tempsTotalDesJobsDeMilieuPourLeZoo             : double_t;
                tempsDeReponse                                 : SInt32;
                nbreDePingsSurLeZoo                            : SInt32;
                host                                           : String255;
                port                                           : SInt32;
                urlDuZoo                                       : String255;
                statutDeCassioSurLeZoo                         : String255;
                rechercheEnCours                               : ZooJobRec;
                verbosity                                      : SInt32;
                jobEnCoursDeTraitement                         : LongString;
                jobPrefetched                                  : LongString;
                derniereRequeteEnvoyee                         : LongString;
                timer                                          : UnsignedWide;
                timerPourPing                                  : UnsignedWide;
                nbreRequetesPoussees                           : SInt32;
                enTrainDeCalculerPourLeZoo                     : boolean;
                positionChercheeADisparuDuZoo                  : boolean;
                requeteDePoussageNecessaire                    : boolean;
                doitRentrerEnContactAvecLeZoo                  : boolean;
                enTrainDeDebuguerLeZooEnLocal                  : boolean;
              end;

const kTailleCacheDesPositionsCalculees = 20;
var gCompteurCacheZooPositionsCalculees : SInt32;
    gLastIndexCacheZooPositionsCalculees : SInt32;
    gCacheZooDesPositionsCalculees : array[1..kTailleCacheDesPositionsCalculees] of
                                   record
                                     hashValue    : UInt64;
                                     score        : SInt32;
                                     meilleurCoup : SInt32;
                                     meilleureDef : SInt32;
                                     ligne        : String255;
                                   end;


const kTailleCacheDesPrefetch = 40;
var gCompteurCacheDesPrefetch : SInt32;
    gLastIndexCacheDesPrefetch : SInt32;
    gCacheDesPrefetch    : array[1..kTailleCacheDesPrefetch] of
                                   record
                                     hashValue : UInt64;
                                     depth     : SInt32;
                                     priority  : SInt32;
                                     s         : LongString;
                                   end;




const kTailleCacheDesScoresEnvoyesAuZoo = 30;
var gCompteurCacheDesScoresEnvoyesAuZoo : SInt32;
    gCacheDesScoresEnvoyesAuZoo : array[1..kTailleCacheDesScoresEnvoyesAuZoo] of UInt64;



procedure EmptyCacheZooDesPositionsCalculees;
var k : SInt32;
begin
  for k := 1 to kTailleCacheDesPositionsCalculees do
    begin
      SetHashValueDuZoo(gCacheZooDesPositionsCalculees[k].hashValue , k_ZOO_NOT_INITIALIZED_VALUE);
      gCacheZooDesPositionsCalculees[k].score         := k_ZOO_NOT_INITIALIZED_VALUE;
      gCacheZooDesPositionsCalculees[k].meilleurCoup  := k_ZOO_NOT_INITIALIZED_VALUE;
      gCacheZooDesPositionsCalculees[k].meilleureDef  := k_ZOO_NOT_INITIALIZED_VALUE;
      gCacheZooDesPositionsCalculees[k].ligne         := '';
    end;
end;



procedure InitUnitZoo;
var k : SInt32;
begin
  SetCassioEstEnTrainDeCalculerPourLeZoo(false, NIL);

  with gZoo do
    begin
      nbJobsCommences                                   := 0;
      nbJobsEndgameTriviaux                             := 0;
      nbJobsMidgame                                     := 0;
      tempsTotalDeCalculPourLeZoo                       := 0.0;
      tempsTotalDesJobsUtilesPourLeZoo                  := 0.0;
      tempsTotalDesJobsDeMilieuPourLeZoo                := 0.0;

      dateDernierReleveDeJobSurLeZoo                    := TickCount - 3600*60;       { une heure dans le passe environ }
      dateDerniereVerificationUtiliteCalculPourLeZoo    := TickCount - 3600*60 + 15;
      dateDerniereEcouteDeResultatsSurLeZoo             := TickCount - 3600*60 + 45;
      dateDernierEnvoiDeResultatSurLeZoo                := TickCount - 3600*60;
      dateDernierEnvoiDePingSurLeZoo                    := TickCount - 3600*60;
      dateDernierEnvoiDeKeepAliveSurLeZoo               := TickCount - 3600*60;
      dateDernierPoussageDeRequete                      := TickCount - 3600*60;
      dateDerniereVerificationDuStatutPourLeZoo         := Tickcount - 3600*60;

      intervalleReleveDeJobSurLeZoo                     :=  120 * 60;       { 19 ticks = 1/3 de seconde }   {120 ticks = 2 secondes }
      intervalleVerificationUtiliteCalculPourLeZoo      :=  3600 * 60 * 60; { 19 ticks = 1/3 de seconde }   {120 ticks = 2 secondes }
      intervalleEcouteDeResultatsSurLeZoo               :=  3600 * 60 * 60; { 19 ticks = 1/3 de seconde }   {3600 * 60 ticks = 1 heure }
      intervalleEnvoiDeResultatSurLeZoo                 := 0;               { instantanne }
      intervalleEnvoiDePingSurLeZoo                     := 0;               { instantanne }
      intervalleEnvoiDeKeepAliveSurLeZoo                := 60 * 15;         { 15 secondes }
      intervallePoussageDeRequete                       := 100000000;       { longtemps }
      intervalleVerificationDuStatutPourLeZoo           := 2;               { 2/60 de seconde }

      tempsDeReponse                                    := 10;      { on suppose 1/6 de seconde par defaut }
      nbreDePingsSurLeZoo                               := 0;
      nbreRequetesPoussees                              := 0;
      statutDeCassioSurLeZoo                            := 'IDLE';

      // host                                           := 'cassio.free.fr/solver';
      // host                                           := 'ffothello.org/solver';
      // host                                           := '82.230.184.124'; // Freebox normale v3
      host                                              := '78.192.201.23';  // Freebox optique
      port                                              := 80;


      urlDuZoo                                          := 'http://' + host + '/';


      jobEnCoursDeTraitement                            := MakeLongString('');
      jobPrefetched                                     := MakeLongString('');
      derniereRequeteEnvoyee                            := MakeLongString('');

      positionChercheeADisparuDuZoo                     := false;
      requeteDePoussageNecessaire                       := false;
      doitRentrerEnContactAvecLeZoo                     := false;   // FIXME POUR UN MEILEUR DEFAUT !!!!
      enTrainDeDebuguerLeZooEnLocal                     := false;
      
      verbosity                                         := 0;      // verbosity level

      ViderZooJob(rechercheEnCours);

    end;

  gCompteurCacheZooPositionsCalculees := 1;
  gLastIndexCacheZooPositionsCalculees := 1;
  EmptyCacheZooDesPositionsCalculees;



  gCompteurCacheDesPrefetch := 1;
  gLastIndexCacheDesPrefetch := 1;
  for k := 1 to kTailleCacheDesPrefetch do
    begin
      SetHashValueDuZoo(gCacheDesPrefetch[k].hashValue , k_ZOO_NOT_INITIALIZED_VALUE);
      gCacheDesPrefetch[k].depth     :=                  k_ZOO_NOT_INITIALIZED_VALUE;
      gCacheDesPrefetch[k].priority  :=                  k_ZOO_NOT_INITIALIZED_VALUE;
      gCacheDesPrefetch[k].s         :=                  MakeLongString('');
    end;


  gCompteurCacheDesScoresEnvoyesAuZoo := 1;
  for k := 1 to kTailleCacheDesScoresEnvoyesAuZoo do
    begin
      SetHashValueDuZoo(gCacheDesScoresEnvoyesAuZoo[k] , k_ZOO_NOT_INITIALIZED_VALUE);
    end;


end;


function CassioDoitRentrerEnContactAvecLeZoo : boolean;
begin
  CassioDoitRentrerEnContactAvecLeZoo := gZoo.doitRentrerEnContactAvecLeZoo;
  
  
  // Activer une des deux lignes ci-dessous pour faire des versions speciales
  // qui ne respectent par la préférence "doitRentrerEnContactAvecLeZoo".
  // Ceci peut etre utile pour les Mac de Dauphine, ou pour les versions
  // stables dans la distribution grand public de Cassio...
  // CassioDoitRentrerEnContactAvecLeZoo := false; 
  // CassioDoitRentrerEnContactAvecLeZoo := true;  
end;


procedure SetCassioDoitRentrerEnContactAvecLeZoo(s : String255);
begin
  s := UpCaseStr(s);
  gZoo.doitRentrerEnContactAvecLeZoo := ((Pos('YES', s) > 0) | (Pos('TRUE', s) > 0));
end;


procedure SetVerbosityOfZoo(value : SInt32);
begin
  gZoo.verbosity := value;
end;


function VerbosityOfZoo : SInt32;
begin
  VerbosityOfZoo := gZoo.verbosity;
end;


(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrintColoredStringInRapport : affiche une ligne en couleur dans        *
 *   le rapport.                                                               *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrintColoredStringInRapport(const s : String255; whichColor : SInt16; whichStyle : StyleParameter);
begin
  ChangeFontColorDansRapport(whichColor);
  ChangeFontFaceDansRapport(whichStyle);
  WritelnDansRapport(s);
  TextNormalDansRapport;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrint : affiche une ligne noire normale dans le rapport.               *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrint(const s : String255);
begin
  BeginRapportPourZoo;
  ChangeFontColorDansRapport(NoirCmd);
  WriteTickOperationPourLeZooDansRapport;
  WritelnDansRapport(s);
  EndRapportPourZoo;
end;



(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrintDebug : affiche une ligne de debuggage verte dans le rapport      *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrintDebug(const s : String255);
begin
  ZooPrintColoredStringInRapport(s, VertCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrintWarning : affiche une ligne de warning verte dans le rapport      *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrintWarning(const s : String255);
begin
  ZooPrintColoredStringInRapport(s, VertCmd, normal);
end;



(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrintInput : affiche les lignes recues du zoo en orange                *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrintInput(const s : String255);
begin
  ZooPrintColoredStringInRapport(s, OrangeCmd, normal);
end;




(*
 *******************************************************************************
 *                                                                             *
 *   ZooPrintOutput : affiche les lignes envoyees au zoo dans le rapport, en   *
 *   utilisant la couleur de l'othellier pour pouvoir distinguer facilement    *
 *   les transactions si on a plusieurs Cassio ouverts en meme temps           *
 *                                                                             *
 *******************************************************************************
 *)
procedure ZooPrintOutput(const s : LongString);
begin
  BeginRapportPourZoo;
  ChangeFontColorRGBDansRapport(NoircirCouleurDeCetteQuantite(CouleurDesPetitsOthelliers,10000));
  WriteTickOperationPourLeZooDansRapport;
  WriteDansRapport(' --> ');
  WritelnLongStringDansRapport(s);
  EndRapportPourZoo;
end;




procedure BeginRapportPourZoo;
begin
  ChangeFontColorDansRapport(RougeCmd);
end;


procedure EndRapportPourZoo;
begin
  ChangeFontColorDansRapport(NoirCmd);
end;

procedure WriteTickOperationPourLeZooDansRapport;
var time : UnsignedWide;
    centiemesDeSeconde : SInt32;
    nombreDeSecondes : SInt32;
    s : String255;
begin
  MicroSeconds(time);

  centiemesDeSeconde := time.lo div 10000;

  nombreDeSecondes := centiemesDeSeconde div 100;
  centiemesDeSeconde := centiemesDeSeconde mod 100;
  
  s := '[tick = '+NumEnString(nombreDeSecondes mod 1000)+'.';

  if centiemesDeSeconde < 10  
    then s := s + '0' + NumEnString(centiemesDeSeconde) else
  if centiemesDeSeconde < 100 
    then s := s + NumEnString(centiemesDeSeconde) 
    else s := s + NumEnString(centiemesDeSeconde);

  s := s + 's ] ';

  WriteDansRapport(s);
end;

procedure WritelnFenetreAlphaBetaDansRapport(alpha,beta : SInt32);
begin
  WritelnDansRapport('[alpha,beta] = ['+NumEnString(alpha)+','+NumEnString(beta)+']');
end;


procedure LibereMemoireUnitZoo;
begin
  if CassioEstEnTrainDeCalculerPourLeZoo then
    begin
      gZoo.positionChercheeADisparuDuZoo := true;
      LanceInterruptionSimple('LibereMemoireUnitZoo');
    end;
end;



procedure ParserLesResultatsDuZoo(ligne : LongString; var fic : FichierAbstrait);
var err : OSErr;
begin

  (* exemples de resultats a parser : 
  
  CALCULATED pos=--------------------O-----XXO------XXO------XOO-----X-----------O window=-64,64 cut=100 depth=23 hash=6fa6f2a0fa9672d0 date=1300879529 score=0 time=0.5 moves=D8F3C5D3D6D7C6C7B5F4E8B4A3A5B3C3C8G5H5F7G4
  STOPPED 6fa6f2a0fa9672d0
  COULD_NOT_STOP 6fa6f2a0fa9672d0
  
  *)

  err := NoErr;
  while (err = NoErr) & not(LongStringBeginsWith('OK<br>',ligne)) do
    begin

      if not(LongStringIsEmpty(ligne)) &
         not(LongStringBeginsWith('NO NEW RESULT', ligne)) then
        begin

          if (LongStringBeginsWith('STOPPED ',ligne)) |
             (LongStringBeginsWith('COULD_NOT_STOP ',ligne))
             then ParserLesPositionStoppeesDuZoo(ligne, fic)

          else
            if (LongStringBeginsWith('ASKER_TAKES_IT',ligne))
              then DoNothing

          else
            RecevoirUnResultatDuZoo(ligne);

        end;

      err := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
    end;

  {WritelnDansRapport('');}
end;


procedure ParserLesPositionStoppeesDuZoo(ligne : LongString; var fic : FichierAbstrait);
var action, hash, presence, reste: String255;
    err : OSErr;
    hashValue : UInt64;
begin

  (* exemples de resultats a parser : 
  
  CALCULATED pos=--------------------O-----XXO------XXO------XOO-----X-----------O window=-64,64 cut=100 depth=23 hash=6fa6f2a0fa9672d0 date=1300879529 score=0 time=0.5 moves=D8F3C5D3D6D7C6C7B5F4E8B4A3A5B3C3C8G5H5F7G4
  INCHARGE pos=--O-------O-----OOOOXXXXOOOXOXX-OXOXOXX-OOOOXOO----OOX----XO----X window=-64,64 cut=0,100000 depth=28 hash=1102267451 score=-6 time=20.3 moves=G4B2 date=20080702001545
  STOPPED  d97fa4c64ecd9
  COULD_NOT_STOP  6fa6f2a0fa9672d0
  DELETED 420297083
  
  *)


  err := NoErr;
  while (err = NoErr) & not(LongStringBeginsWith('OK<br>',ligne)) do
    begin

      Parser3(ligne.debutLigne, action, hash, presence, reste);

      if ((action = 'STOPPED') | (action = 'COULD_NOT_STOP')) & (hash <> '') 
        then hashValue := HexToUInt64(hash);
        

      if (action = 'CALCULATED '  ) |
         (action = 'INCHARGE '    ) |
         (action = 'PREFETCHED '  ) |
         (action = 'COULDNTSOLVE ') |
         (action = 'DELETED '     )
        then ParserLesResultatsDuZoo(ligne, fic);

      err := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
    end;
end;


procedure ParserLesPrefetchEncoreUtiles(ligne : LongString; var fic : FichierAbstrait);
var err : OSErr;
    action1, action2, valeur, hash, aux : String255;
    hashValue : UInt64;
    ignored : boolean;
    s : LongString;
begin

  (* Exemples de ligne a parser :
  
       STILL USEFUL true 4168132959e9f8d2
       STILL USEFUL false 78b0caecadebe8be
  *)


  err := NoErr;
  while (err = NoErr) & not(LongStringBeginsWith('OK<br>',ligne)) do
    begin

      Parser4(ligne.debutLigne , action1, action2, valeur, hash, ligne.debutLigne);

      if (action1 = 'STILL') & (action2 = 'USEFUL') & (valeur = 'false') & (hash <> '') then
        begin
          hashValue := HexToUInt64(hash);
          
          // le serveur vient de nous prevenir que ce prefetch n'est plus utile
          RetirerCeJobDuCacheDesPositionsPrefetchUtiles(hashValue);

          // on interrompt aussi la recherche en cours, si elle est sur cette position
          if CassioEstEnTrainDeCalculerPourLeZoo &
            Same64Bits(hashValue, HashDuCalculCourantDeCassioPourLeZoo) then
            begin
              s := MakeLongString('STILL INCHARGE false hash=' + hash);
              ignored := DoitInterrompreCalculPourLeZoo(s);
            end;

          // on essaye aussi de vider la position prefetched active, si necessaire
          aux := 'hash=' + hash;
          if (FindStringInLongString(aux , gZoo.jobPrefetched) > 0) then
            InitLongString(gZoo.jobPrefetched);

        end;

      err := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
    end;
end;


procedure TraiterPositionInchargeDuZoo(const ligne : LongString);
var action1, action2, valeur, hash, aux : String255;
    hashValue : UInt64;
    reason : String255;
    err : OSErr;
begin

  (* Exemple de ligne a parser (attention il y a hash= dans la chaine...) :
  
       STILL INCHARGE true hash=1524be455ff
  *)


  Parser4(ligne.debutLigne , action1, action2, valeur, hash, aux);
  if (action1 = 'STILL') & (action2 = 'INCHARGE') & (valeur = 'true') & (hash <> '') then
    begin
    
      hash := TPCopy(hash,6,255);
      hashValue := HexToUInt64(hash);
      
      // Si le serveur du zoo pense que nous sommes en train de calculer sur une position qui n'est
      // pas celle en cours, ou dont on ne vient pas d'envoyer le résultat au zoo, il y a un probleme
      // de croisement des messages sur Internet, et on previent le serveur...
      if not(CassioEstEnTrainDeCalculerPourLeZoo & Same64Bits(hashValue, HashDuCalculCourantDeCassioPourLeZoo))
         & HashValueDuZooEstCorrecte(hashValue)
         & not(FindHashDansCacheDesScoresEnvoyesAuZoo(hashValue)) then
           begin
             reason := CalculateZooStatusPourCetEtatDeCassio;
             err := SExcuserAupresDuZooPourCetteHash(hashValue, reason);
           end;
           
    
      // WritelnDansRapport('Setting the online zoo status of Cassio to CALCULATING !');
      SetZooStatus('CALCULATING');
    end;
end;



function FindWordInTransaction(mot : String255; ligne : LongString; var fic : FichierAbstrait; afficherTouteLaRequete : boolean) : boolean;
var err,err2 : OSErr;
    found : boolean;
    positionMarqueur : SInt32;
    compteurDelignes : SInt32;
begin

  found := false;

  if afficherTouteLaRequete then
    begin
      BeginRapportPourZoo;
      WriteTickOperationPourLeZooDansRapport;
    end;

  positionMarqueur := GetPositionMarqueurFichierAbstrait(fic);
  
  compteurDelignes := 0;

  err := NoErr;
  while (err = NoErr) do
    begin
      if afficherTouteLaRequete & not(LongStringIsEmpty(ligne)) then
        begin
          inc(compteurDelignes);
          
          if (compteurDelignes >= 2) then WriteDansRapport('                             ');
        
          WritelnLongStringDansRapport(ligne);
        end;

      found := found | (FindStringInLongString(mot,ligne) > 0);

      err := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
    end;

  err2 := SetPositionMarqueurFichierAbstrait(fic,positionMarqueur);


  if afficherTouteLaRequete then EndRapportPourZoo;

  FindWordInTransaction := found;
end;


procedure AfficherTouteLaTransactionDansRapport(var fic : FichierAbstrait);
var err : OSErr;
    foo : boolean;
    positionMarqueur : SInt32;
    premiereLigne : LongString;
begin

  if (gZoo.verbosity >= 2) then
    begin
      positionMarqueur := GetPositionMarqueurFichierAbstrait(fic);

      err := SetPositionMarqueurFichierAbstrait(fic, 0);
      err := ReadlnLongStringDansFichierAbstrait(fic, premiereLigne, true);

       // this find will fail, but will have the side-effect to show the transaction in the rapport
      foo := FindWordInTransaction('WBSLDO@é&@é&@"&@',premiereLigne, fic, true);

      err := SetPositionMarqueurFichierAbstrait(fic, positionMarqueur);
    end;

end;



procedure TraiterZooTransaction(ligne : LongString; var fic : FichierAbstrait; var mustResendRequest : boolean);
var err2 : OSErr;
    debugRequeteDansRapport : boolean;
begin

    debugRequeteDansRapport := false;

    mustResendRequest := false;


    if (gZoo.verbosity >= 2) then AfficherTouteLaTransactionDansRapport(fic);


    if debugRequeteDansRapport then
      WritelnLongStringDansRapport(ligne);


    AfficherEtatDuZooDansFenetreGestionDuTemps(ligne.debutLigne);



    if (LongStringBeginsWith('STILL INCHARGE false', ligne))
      then
        begin
          if DoitInterrompreCalculPourLeZoo(ligne)
            then EnvoyerUneRequetePourVerifierLeCacheDesPrefetch;
        end 
      else
    
    if (LongStringBeginsWith('STILL INCHARGE true', ligne))
      then TraiterPositionInchargeDuZoo(ligne) else
      
    if (LongStringBeginsWith('NO JOB', ligne))
      then SetZooStatus('SEEKING_JOB') else
      
    if (LongStringBeginsWith('JOB pos', ligne))
      then TraiterJobDuZoo(ligne) else

    if (LongStringBeginsWith('PREFETCH pos', ligne))
      then PrefetchJobDuZoo(ligne) else

    if (LongStringBeginsWith('STILL USEFUL ', ligne))
      then ParserLesPrefetchEncoreUtiles(ligne, fic) else

    if (LongStringBeginsWith('STOPPED ', ligne)) |
       (LongStringBeginsWith('COULD_NOT_STOP ', ligne))
      then ParserLesPositionStoppeesDuZoo(ligne, fic) else

    if (LongStringBeginsWith('START NEW TEST', ligne))
      then ZooWantsToStartANewTest else
      
    if (LongStringBeginsWith('PING ANSWERED', ligne))
      then MettreAJourLeTempsDeReponseDuZoo else

    if (LongStringBeginsWith('CALCULATED '          ,ligne)) |
       (LongStringBeginsWith('INCHARGE '            ,ligne)) |
       (LongStringBeginsWith('PREFETCHED '          ,ligne)) |
       (LongStringBeginsWith('COULDNTSOLVE '        ,ligne)) |
       (LongStringBeginsWith('DELETED '             ,ligne)) |
       (LongStringBeginsWith('ERROR_TIMED_OUT '     ,ligne))
      then ParserLesResultatsDuZoo(ligne, fic) else

    if (FindStringInLongString('ERROR'  ,ligne) > 0)  |
       (FindStringInLongString('arning' ,ligne) > 0)  |
       (FindStringInLongString('<br />'  ,ligne) > 0) |
       (FindStringInLongString('DOCTYPE'  ,ligne) > 0)
      then
        begin
          mustResendRequest := FindWordInTransaction('RETRY',ligne, fic, false);

          if not(mustResendRequest) then
            AfficherTouteLaTransactionDansRapport(fic);   {pour afficher les messages d'erreur}

        end;

    // on parse la seconde ligne qui est souvent une information de prefetch
    err2 := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);

    if (err2 = NoErr) & (LongStringBeginsWith('PREFETCH pos',ligne)) then
      begin
        PrefetchJobDuZoo(ligne);
        err2 := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
      end;
    
    if (err2 = NoErr) & (LongStringBeginsWith('PREFETCH pos',ligne)) then
      begin
        PrefetchJobDuZoo(ligne);
        err2 := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
      end;
    
    if (err2 = NoErr) & (LongStringBeginsWith('PREFETCH pos',ligne)) then
      begin
        PrefetchJobDuZoo(ligne);
        err2 := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);
      end;

    if (err2 = NoErr) & (LongStringBeginsWith('NO PREFETCH',ligne)) then
      err2 := ReadlnLongStringDansFichierAbstrait(fic, ligne, true);

    // on parse les resultats des lignes suivantes pour les requetes multiples
    // ADD_AND_GET_RESULTS, STILL_INCHARGE_AND_GET_RESULTS et GET_WORK_AND_GET_RESULTS

    if (err2 = NoErr) &
       ((LongStringBeginsWith('CALCULATED '          ,ligne))  |
        (LongStringBeginsWith('INCHARGE '            ,ligne))  |
        (LongStringBeginsWith('PREFETCHED '          ,ligne))  |
        (LongStringBeginsWith('COULDNTSOLVE '        ,ligne))  |
        (LongStringBeginsWith('DELETED '             ,ligne))  |
        (LongStringBeginsWith('ERROR_TIMED_OUT '     ,ligne))) 
      then ParserLesResultatsDuZoo(ligne, fic);

    if (err2 = NoErr) &
       ((LongStringBeginsWith('STOPPED '  ,ligne)) |
        (LongStringBeginsWith('COULD_NOT_STOP '    ,ligne)))
      then ParserLesPositionStoppeesDuZoo(ligne, fic);

    if (err2 = NoErr) &
       (LongStringBeginsWith('STILL USEFUL ', ligne))
      then ParserLesPrefetchEncoreUtiles(ligne, fic);

    if (err2 = NoErr) & 
      (LongStringBeginsWith('NO JOB', ligne))
      then SetZooStatus('SEEKING_JOB');
      
    if (err2 = NoErr) & 
      (LongStringBeginsWith('STILL INCHARGE true', ligne))
      then TraiterPositionInchargeDuZoo(ligne);
      
    if (err2 = NoErr) &
       (LongStringBeginsWith('STILL INCHARGE false', ligne))
      then
        begin
          if DoitInterrompreCalculPourLeZoo(ligne)
            then EnvoyerUneRequetePourVerifierLeCacheDesPrefetch;
        end;
    
    if (err2 = NoErr) &
       (LongStringBeginsWith('PLEASE EMPTY CACHE', ligne))
      then
        begin
          {ViderLesCachesPourLeZoo;}
        end;

    if (err2 = NoErr) &
       ((FindStringInLongString('ERROR'  ,ligne) > 0)  |
        (FindStringInLongString('arning' ,ligne) > 0)  |
        (FindStringInLongString('<br />'  ,ligne) > 0))
      then
        begin
          mustResendRequest := FindWordInTransaction('RETRY', ligne, fic, false);
          (*
          if not(mustResendRequest) then
            AfficherTouteLaTransactionDansRapport(fic);   {pour afficher les messages d'erreur}
          *)
        end;

end;


procedure AfficherEtatDuZooDansFenetreGestionDuTemps(s : String255);
begin
  if (s <> '') & (Pos('....',s) <> 1)
    then
      begin

        (*
        if (Pos('<br />',s) <> 1) &
           (Pos('NO JOB',s) = 0) &
           (Pos('STILL INCHARGE',s) = 0) &
           (Pos('STILL USEFUL ',s) = 0) &
           (Pos('NO NEW RESULT',s) = 0) &
           (Pos('CALCULATED',s) = 0) &
           (Pos('INCHARGE',s) = 0) &
           (Pos('COULDNTSOLVE',s) = 0) &
           (Pos('ADD : OK',s) = 0) &
           (Pos('ASKER_TAKES_IT : OK',s) = 0) &
           (Pos(' : OK',s) = 0) &
           (Pos('PREFETCHED pos',s) = 0) &
           (Pos('STOPPED ',s) = 0) &
           (Pos('DELETED ',s) = 0) &
           (Pos('COULD_NOT_STOP ',s) = 0) &
           (Pos('PREFETCH pos',s) = 0) &
           (Pos('NO PREFETCH',s) = 0) &
           (Pos('SEND_SCORE : OK',s) = 0) &
           (Pos('JOB pos',s) = 0) &
           (Pos('RESET_STATUS : pos',s) = 0) &
           (Pos('RESET_STATUS : OK',s) = 0) &
           (Pos('WARNING for RESET_STATUS ',s) = 0)
          then
            begin
              BeginRapportPourZoo;
              WriteTickOperationPourLeZooDansRapport;
              WritelnDansRapport('url= '+url);
              WritelnDansRapport('ack= '+s);
              EndRapportPourZoo;
            end;
        *)

        SetReseauEstVivant(true);
        SetMessageEtatDuReseau(s);
        AfficheEtatDuReseau(GetLastEtatDuReseauAffiche);
      end;
end;


function AcknowledgementOfZooTransaction(whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;
type t_LocalFichierAbstraitPtr = ^FichierAbstrait;
var s : LongString;
    url : LongString;
    err : OSErr;
    mustResendRequest : boolean;
    fic : t_LocalFichierAbstraitPtr;
    time : UnsignedWide;
    numeroDansReserve : SInt32;
begin
  fic := t_LocalFichierAbstraitPtr(whileFilePtr);

  err := -1;
  InitLongString(s);
  InitLongString(url);


  {WritelnDansRapport('Entree dans AcknowledgementOfZooTransaction');}
  {AttendFrappeClavier;}

  if (fic <> NIL) then
    begin

      err := SetPositionMarqueurFichierAbstrait(fic^, 0);

      if (err = NoErr) then
        err := ReadlnLongStringDansFichierAbstrait(fic^, s, true);

      {
      s := 'ERROR';
      WritelnDansRapport(s);
      }

      {

      WritelnDansRapport('avant DisposeFichierAbstrait dans AcknowledgementOfZooTransaction');
      AttendFrappeClavier;
      }

      MicroSeconds(time);




      numeroDansReserve := fic^.refCon;

      {WritelnNumDansRapport('ack : numeroDansReserve = ',numeroDansReserve);}



      if (numeroDansReserve >= 0) & (numeroDansReserve <= kNumberOfAsynchroneNetworkConnections)
        then
          begin
            { recuperons l'url de la requete}
            url := gReserveZonesPourTelecharger.table[numeroDansReserve].infoNetworkConnection;

            { Liberons le slot de fichier abstrait dans la reserve }
            LibereSlotDansLaReservePourTelecharger(numeroDansReserve);
          end
        else
          begin
            WritelnNumDansRapport('ASSERT dans AcknowledgementOfZooTransaction !! numeroDansReserve = ',numeroDansReserve);
          end;


      (*
      WritelnNumDansRapport('reçu après (en seconds) : ',time.hi - gZoo.timer.hi);
      WritelnNumDansRapport('reçu après (en µsecondes) : ',time.lo - gZoo.timer.lo);
      WritelnDansRapport('AcknowledgementOfZooTransaction :');
      *)


      if (err = NoErr) & (networkError <> 0) then
          err := networkError;


      (*** Gestion des actions en reponse à la requete ***)

      if err = NoErr then
        begin

          TraiterZooTransaction(s, fic^, mustResendRequest);

          // si le zoo nous demande de reessayer, et que on ne l'a pas encore fait,
          // on relance la requete (ceci peur arriver si la base mySQL n'a pas pu traiter
          // la requete a cause d'un nombre de connexions simultanées trop grand chez Free ou Sivit).

          if mustResendRequest & (FindStringInLongString('&retry=1',url) <= 0) then
            begin
              // WritelnDansRapport(url);
              // WritelnDansRapport('SQL server overloaded => retrying...');
              RetryEnvoyerUneRequeteAuZoo(url);
            end;
        end;

    end;

  {
  WritelnDansRapport('Sortie de AcknowledgementOfZooTransaction');
  AttendFrappeClavier;
  }

  AcknowledgementOfZooTransaction := err;
end;


procedure OuvrirConnectionPermanenteAuZoo;
var foo : boolean;
    numeroSlot : SInt32;
begin
  Discard(foo);

  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(OuvrirConnectionPermanenteAuZoo);

  with gZoo do
    begin
      foo := TryOpenPermanentConnection(host, port, SerialiserMessagesDuZoo, LibererMemoireConnectionPermanenteAuZoo, numeroSlot);

      (*
      if foo
        then WritelnNumDansRapport('TryOpenPermanentConnection = true,  numeroSlot = ',numeroSlot)
        else WritelnDansRapport('TryOpenPermanentConnection = false');
      *)
    end;
end;



function SerialiserMessagesDuZoo(theFile : FichierAbstraitPtr; buffer : Ptr; from : SInt32; var lenBuffer : SInt32) : OSErr;
type t_LocalFichierAbstraitPtr = ^FichierAbstrait;
var fic : t_LocalFichierAbstraitPtr;
    sent, received, posSeparateur : SInt32;
    endOfMessageWasFound : boolean;
    separateurDeMessages : String255;
    s : LongString;
    shouldResendRequest : boolean;
    err : OSErr;
    texte : PackedArrayOfCharPtr;




    procedure SerialiserFichierAbstrait;
    var endOfMessageWasFoundDansFichierAbstrait : boolean;
        texte2 : PackedArrayOfCharPtr;
        oldZoneSize : SInt32;
        err : OSErr;
    begin

      // Notre serialisateur ne marche que si fic^ une fic en memoire (pas un fichier)
      if (fic^.genre <> FichierAbstraitEstPointeur) then
        begin
          WritelnDansRapport('ASSERT : theFile devrait etre de type FichierAbstraitEstPointeur dans SerialiserMessagesDuZoo');
          exit(SerialiserMessagesDuZoo);
        end;



      repeat

        // trouver le séparateur de messages dans le fichier abstrait
        endOfMessageWasFoundDansFichierAbstrait :=  FindStringInBuffer(separateurDeMessages, fic^.infos, fic^.nbOctetsOccupes, 0 , +1, posSeparateur);

        if endOfMessageWasFoundDansFichierAbstrait then
          begin

            // tronquer le fichier abstrait jusqu'au premier separateur de message (on 
            // deplacera les octets negliges apres avoir traité le premier message, cf plus bas)
            oldZoneSize := fic^.nbOctetsOccupes;
            fic^.nbOctetsOccupes := posSeparateur;

            // lire la premiere ligne du premier message

            err := SetPositionMarqueurFichierAbstrait(fic^, 0);
            repeat
              err := ReadlnLongStringDansFichierAbstrait(fic^, s, true);
            until (err <> NoErr) | not(LongStringIsEmpty(s)) ;


            if not(LongStringIsEmpty(s)) then
              begin

                // faire traiter le premier message par Cassio

                TraiterZooTransaction(s, fic^, shouldResendRequest);

                // deplacer les octets que l'on avait negligés (ceux de la fin du fichier abstrait,
                // apres le premier separateur de messages) vers le debut du fichier abstrait, de sorte
                // que l'on puisse trouver le message suivant, etc.

                texte2 := PackedArrayOfCharPtr(fic^.infos);
                fic^.nbOctetsOccupes := oldZoneSize - posSeparateur - LENGTH_OF_STRING(separateurDeMessages);
                if (fic^.nbOctetsOccupes > 0)
                  then MoveMemory(@texte2^[posSeparateur + LENGTH_OF_STRING(separateurDeMessages)], fic^.infos, fic^.nbOctetsOccupes);
                err := SetPositionMarqueurFichierAbstrait(fic^, fic^.nbOctetsOccupes);

                (*
                WritelnDansRapport('***************');
                *)

              end;

          end;
        until not(endOfMessageWasFoundDansFichierAbstrait);

    end;



begin

  Discard(from);

  err := -1;

  if (theFile <> NIL) & (buffer <> NIL) then
    begin
      fic  := t_LocalFichierAbstraitPtr(theFile);
      texte := PackedArrayOfCharPtr(buffer);

      (*
      WritelnDansRapport('avant la boucle repeat dans SerialiserMessagesDuZoo :');
      WritelnNumDansRapport('lenBuffer = ',lenBuffer);
      InsereTexteDansRapport(buffer, lenBuffer);
      WritelnDansRapport('');
      *)

      separateurDeMessages := 'END.' + lf ;  // lf = linefeed caracter ($0A)
      received := 0;

      repeat

        endOfMessageWasFound := FindStringInBuffer(separateurDeMessages, Ptr(texte), lenBuffer, received , +1, posSeparateur);

        if endOfMessageWasFound
          then sent := posSeparateur + LENGTH_OF_STRING(separateurDeMessages) - received
          else sent := lenBuffer - received;

        if sent > 0
          then err := EcrireFichierAbstrait(fic^, -1, @texte^[received], sent);

        received := received + sent;

        SerialiserFichierAbstrait;

      until not(endOfMessageWasFound) | (received >= lenBuffer) | (err <> NoErr);


      (*
      WritelnDansRapport('a la fin de SerialiserMessagesDuZoo, fic contient : ');
      WritelnNumDansRapport('fic^.nbOctetsOccupes = ',fic^.nbOctetsOccupes);
      InsereTexteDansRapport(fic^.infos, fic^.nbOctetsOccupes);
      WritelnDansRapport('');
      WritelnDansRapport('sortie de SerialiserMessagesDuZoo...');
      WritelnDansRapport('');
      *)

    end;

  SerialiserMessagesDuZoo := err;
end;


function LibererMemoireConnectionPermanenteAuZoo(whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;
type t_LocalFichierAbstraitPtr = ^FichierAbstrait;
var err : OSErr;
    fic : t_LocalFichierAbstraitPtr;
    numeroDansReserve : SInt32;
begin
  fic := t_LocalFichierAbstraitPtr(whileFilePtr);
  err := -1;

  if (fic <> NIL) then
    begin
      err := ViderFichierAbstrait(fic^);
      numeroDansReserve := fic^.refCon;

      if (numeroDansReserve >= 0) & (numeroDansReserve <= kNumberOfAsynchroneNetworkConnections)
        then LibereSlotDansLaReservePourTelecharger(numeroDansReserve)
        else WritelnNumDansRapport('ASSERT dans LibererMemoireConnectionPermanenteAuZoo !! numeroDansReserve = ',numeroDansReserve);

      if (err = NoErr) & (networkError <> 0) then  err := networkError;
    end;

  { WritelnDansRapport('Sortie de LibererMemoireConnectionPermanenteAuZoo');
  AttendFrappeClavier;}

  LibererMemoireConnectionPermanenteAuZoo := err;
end;


function GetZooStatus : String255;
begin
  GetZooStatus := gZoo.statutDeCassioSurLeZoo;
end;


procedure SetZooStatus(const status : String255);
begin
  gZoo.statutDeCassioSurLeZoo := status;
  // WritelnDansRapport('Setting ZooStatus to ' + status);
end;


function CalculateZooStatusPourCetEtatDeCassio : String255;
var status : String255;
    job : LongString;
begin

  status := 'RETIRED';
          
  if CassioEstEnTrainDeCalculerPourLeZoo | 
     (CassioPeutDonnerDuTempsAuZoo & DemandeDeCalculPourLeZooDansLaFileLocale(job))
    then status := 'CALCULATING';
  
  if Quitter | enRetour                                
    then status := 'RETIRED';
    
  if CassioPeutDonnerDuTempsAuZoo       
    then status := 'SEEKING_JOB';
    
  CalculateZooStatusPourCetEtatDeCassio := status;
  
end;


procedure VerifierLeStatutDeCassioPourLeZoo;
var statusReelSurLeZoo : String255;
    statutVouluParEtatDeCassio : String255;
begin

  if (interruptionReflexion <> pasdinterruption) & not(Quitter)
    then exit(VerifierLeStatutDeCassioPourLeZoo);
        

  with gZoo do
    if ((TickCount - dateDerniereVerificationDuStatutPourLeZoo) >= intervalleVerificationDuStatutPourLeZoo) then
      begin
      
        
        statusReelSurLeZoo         := GetZooStatus;
        statutVouluParEtatDeCassio := CalculateZooStatusPourCetEtatDeCassio;
        
        // WritelnDansRapport('Dans VerifierLeStatutDeCassioPourLeZoo, statusReelSurLeZoo = ' + statusReelSurLeZoo);
        
        if (statusReelSurLeZoo <> statutVouluParEtatDeCassio) then
          begin
          
            // WritelnDansRapport('BINGO !!  statusReelSurLeZoo = ' + statusReelSurLeZoo + ' mais statutVouluParEtatDeCassio = '+statutVouluParEtatDeCassio);
            
            
            if (statutVouluParEtatDeCassio = 'RETIRED') then
              begin
                EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo('AIE AIE dans VerifierLeStatutDeCassioPourLeZoo');
                if Quitter then BouclerUnPeuAvantDeQuitterEnSurveillantLeReseau(30);
              end;
            
            if (statutVouluParEtatDeCassio = 'SEEKING_JOB') then
              begin
                // on accelère tant qu'on peut le relevé d'un nouveau job sur le zoo
                gZoo.dateDernierReleveDeJobSurLeZoo := 0;
                DemanderUnJobAuZoo;
              end;
              
            if (statutVouluParEtatDeCassio = 'CALCULATING') then
              begin
                // on accelere tant qu'on peut la verification de l'utilite des calculs sur le zoo
                gZoo.dateDerniereVerificationUtiliteCalculPourLeZoo := TickCount - intervalleVerificationUtiliteCalculPourLeZoo - 10;
                VerifierUtiliteCalculPourLeZoo(true);
              end;
              
          end;
        
        dateDerniereVerificationDuStatutPourLeZoo := TickCount;
      end;
    
end;


procedure SetIntervalleVerificationDuStatutDeCassioPourLeZoo(ticks : SInt32; oldValue : SInt32Ptr);
begin
  if oldValue <> NIL then
    oldValue^ := gZoo.intervalleVerificationDuStatutPourLeZoo;
  
  gZoo.intervalleVerificationDuStatutPourLeZoo := ticks;
end;

function CassioEstEnTrainDeCalculerPourLeZoo : boolean;
begin
  CassioEstEnTrainDeCalculerPourLeZoo := gZoo.enTrainDeCalculerPourLeZoo;
end;


function CassioEstEnTrainDeDebuguerLeZooEnLocal : boolean;
begin
  CassioEstEnTrainDeDebuguerLeZooEnLocal := gZoo.enTrainDeDebuguerLeZooEnLocal;
end;


procedure SetCassioEstEnTrainDeCalculerPourLeZoo(newValue : boolean; oldValue : BooleanPtr);
begin
  if oldValue <> NIL
    then oldValue^ := gZoo.enTrainDeCalculerPourLeZoo;

  gZoo.enTrainDeCalculerPourLeZoo := newValue;
end;


procedure SetCassioEstEnTrainDeDebugguerLeZooEnLocal(flag : boolean);
begin
  gZoo.enTrainDeDebuguerLeZooEnLocal := flag;
end;


function GetCalculCourantDeCassioPourLeZoo : LongString;
begin
  if not(CassioEstEnTrainDeCalculerPourLeZoo)
    then GetCalculCourantDeCassioPourLeZoo := MakeLongString('')
    else GetCalculCourantDeCassioPourLeZoo := gZoo.jobEnCoursDeTraitement;
end;


function HashDuCalculCourantDeCassioPourLeZoo : UInt64;
var result : UInt64;
begin
  if CassioEstEnTrainDeCalculerPourLeZoo
    then HashDuCalculCourantDeCassioPourLeZoo := gZoo.rechercheEnCours.params.inHashValue
    else 
      begin
        SetHashValueDuZoo(result, -1);
        HashDuCalculCourantDeCassioPourLeZoo := result;
      end;
end;


function ProfDuCalculCourantDeCassioPourLeZoo : SInt32;
begin
  if not(CassioEstEnTrainDeCalculerPourLeZoo)
    then ProfDuCalculCourantDeCassioPourLeZoo := -1
    else ProfDuCalculCourantDeCassioPourLeZoo := gZoo.rechercheEnCours.params.inProfondeurFinale;
end;




function CassioPeutDonnerDuTempsAuZoo : boolean;
var config : ConfigurationCassioRec;
    numero : SInt32;
begin

  (********************)

  { les raisons faciles de refuser du temps au zoo }

  CassioPeutDonnerDuTempsAuZoo := false;
  
 // WritelnStringAndBoolDansRapport('CassioEstEnTrainDeReflechir = ',CassioEstEnTrainDeReflechir);

  if Quitter                                     then exit(CassioPeutDonnerDuTempsAuZoo);
  if (interruptionReflexion <> pasdinterruption) then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnTrainDeCalculerPourLeZoo         then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnTrainDeReflechir                 then exit(CassioPeutDonnerDuTempsAuZoo);
  if EnModeEntreeTranscript                      then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnModeSolitaire & not(HumCtreHum)  then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnRechercheSolitaire               then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnTrainDePlaquerUnSolitaire        then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioIsWaitingAnEngineResult               then exit(CassioPeutDonnerDuTempsAuZoo);
  if CassioEstEnModeTournoi                      then exit(CassioPeutDonnerDuTempsAuZoo);
  if CalculDesScoresTheoriquesDeLaBaseEnCours    then exit(CassioPeutDonnerDuTempsAuZoo);
  if enRetour                                    then exit(CassioPeutDonnerDuTempsAuZoo);
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  if not(CassioIsUsingAnEngine(numero))          then exit(CassioPeutDonnerDuTempsAuZoo);
  if (GetEngineState = 'ENGINE_KILLED') & 
     (DateOfLastStartOfEngine < TickCount - 200) then exit(CassioPeutDonnerDuTempsAuZoo);
  {$ENDC}
  
  {if not(CassioIsUsingAnEngine(numero))          then exit(CassioPeutDonnerDuTempsAuZoo);}  { peut-etre bien ? }


  (********************)

  { les raisons faciles de donner du temps au zoo }

  CassioPeutDonnerDuTempsAuZoo := true;

  if HumCtreHum                                  then exit(CassioPeutDonnerDuTempsAuZoo);


  (********************)

  { les situations compliquees, un peu plus longues a discriminer }


  GetConfigurationCouranteDeCassio(config);
  if TypeDeCalculLanceParCassioDansCetteConfiguration(config) = k_AUCUN_CALCUL
    then CassioPeutDonnerDuTempsAuZoo := true
    else CassioPeutDonnerDuTempsAuZoo := (jeuInstantane & (NiveauJeuInstantane < NiveauGrandMaitres) & (nbreCoup <= 40));

  Discard(numero);

end;


procedure SetDateDerniereEcouteDeResultatsDuZoo(date : SInt32);
begin
  gZoo.dateDerniereEcouteDeResultatsSurLeZoo := date;
end;


function DateDernierEnvoiDeResultatAuZoo : SInt32;
begin
  DateDernierEnvoiDeResultatAuZoo := gZoo.dateDernierEnvoiDeResultatSurLeZoo;
end;


function DateDerniereDemandeDeJobAuZoo : SInt32;
begin
  DateDerniereDemandeDeJobAuZoo := gZoo.dateDernierReleveDeJobSurLeZoo;
end;


function DateDernierPingAuZoo : SInt32;
begin
  DateDernierPingAuZoo := gZoo.dateDernierEnvoiDePingSurLeZoo;
end;


function DateDernierKeepAliveAuZoo : SInt32;
begin
  DateDernierKeepAliveAuZoo := gZoo.dateDernierEnvoiDeKeepAliveSurLeZoo;
end;


function TempsTotalConsacreAuZoo : double_t;
begin
  TempsTotalConsacreAuZoo := gZoo.tempsTotalDeCalculPourLeZoo;
end;


function TempsUtileConsacreAuZoo : double_t;
begin
  TempsUtileConsacreAuZoo := gZoo.tempsTotalDesJobsUtilesPourLeZoo;
end;


function TempsDeMidgameConsacreAuZoo : double_t; 
begin
    TempsDeMidgameConsacreAuZoo := gZoo.tempsTotalDesJobsDeMilieuPourLeZoo;
end;


function NombreTotalDeJobsCalculesPourLeZoo : SInt32;
begin
  NombreTotalDeJobsCalculesPourLeZoo := gZoo.nbJobsCommences;
end;

function NombreDeJobsEndgameTriviauxCalculesPourLeZoo : SInt32;
begin
  NombreDeJobsEndgameTriviauxCalculesPourLeZoo := gZoo.nbJobsEndgameTriviaux;
end;

function NombreDeJobsMidgameCalculesPourLeZoo : SInt32;
begin
  NombreDeJobsMidgameCalculesPourLeZoo := gZoo.nbJobsMidgame;
end;

function GetZooURL : String255;
begin
  GetZooURL := gZoo.urlDuZoo;
end;


procedure EnvoyerUneRequeteDePoussageAuZoo;
var err : OSStatus;
    numeroLibre : SInt32;
    randomURL : LongString;
    requestSent : boolean;
begin
  with gZoo do
    begin

      if FALSE &
        ((TickCount - dateDernierPoussageDeRequete) >= intervallePoussageDeRequete) then
        if TrouverSlotLibreDansLaReservePourTelecharger(numeroLibre) then
          with gReserveZonesPourTelecharger.table[numeroLibre] do
            begin

              requestSent := false;

              if (numeroLibre >= 0) & (numeroLibre <= kNumberOfAsynchroneNetworkConnections) then
                begin

                  randomURL := MakeLongString('http://foo.random'+NumEnString(abs(RandomLongint))+'.bar' + '?rand=' + NumEnString(abs(RandomLongint)));

                  infoNetworkConnection := randomURL;


                  err := ViderFichierAbstrait(petitFichierTampon);

                  if FichierAbstraitEstCorrect(petitFichierTampon) & (err = NoErr)
                    then
                      begin
                        {WritelnDansRapport(randomURL);}
                        DownloadURLToFichierAbstrait(numeroLibre, randomURL, petitFichierTampon, AcknowledgementOfZooTransaction);
                        requestSent := true;

                        (*
                        WritelnNumDansRapport('interv poussage = ',TickCount - dateDernierPoussageDeRequete);
                        WritelnNumDansRapport('nbreRequetesPoussees = ',nbreRequetesPoussees);
                        WritelnDansRapport(derniereRequeteEnvoyee);
                        *)

                        nbreRequetesPoussees := 0;


                      end;

                  dateDernierPoussageDeRequete := TickCount;

                  requeteDePoussageNecessaire := false;

                end;

              if not(requestSent) then
                WritelnDansRapport('ASSERT : memory leak in EnvoyerUneRequeteDePoussageAuZoo');

            end;

     end;
end;


procedure VerifierLePoussageDesRequetesAuZoo;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(VerifierLePoussageDesRequetesAuZoo);

  with gZoo do
    begin
      if requeteDePoussageNecessaire &
         ((TickCount - dateDernierPoussageDeRequete) >= intervallePoussageDeRequete) then
        begin
          EnvoyerUneRequeteDePoussageAuZoo;
          requeteDePoussageNecessaire := false;
        end;
    end;
end;


procedure SetDerniereRequeteEnvoyeeAuZoo(var s : LongString);
begin
  gZoo.derniereRequeteEnvoyee := s;
end;


function GetDerniereRequeteEnvoyeeAuZoo : LongString;
begin
  GetDerniereRequeteEnvoyeeAuZoo := gZoo.derniereRequeteEnvoyee;
end;


procedure EnvoyerUneRequeteAuZoo(var requete : LongString);
var numeroSlot : SInt32;
    permanentConnectionFound : boolean;
    canUsePermanentConnection : boolean;
    action : LongString;
    s : String255;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequeteAuZoo);

  with gZoo do
    begin

      SetDateDernierEnvoiRequeteSurReseau(TickCount);
      SetDerniereRequeteEnvoyeeAuZoo(requete);
      
      if (Pos('GET_WORK',requete.debutLigne) > 0)
        then SetZooStatus('SEEKING_JOB');
      
      if (Pos('STILL_INCHARGE',requete.debutLigne) > 0)
        then SetZooStatus('CALCULATING');

      permanentConnectionFound := FindPermanentConnectionToHost( host, port, numeroSlot);

      if not(permanentConnectionFound)
        then
          begin
            OuvrirConnectionPermanenteAuZoo;
            
            if (verbosity >= 2) then ZooPrintOutput(requete);
            
            EnvoyerUneRequeteAuZooParTelechargementHTML(requete);
          end
        else
          begin

            action := requete;

            // on efface la partie 'http://82.230.184.124/' de l'url : le serveur marche
            // meme si on l'envoie, mais la requete reseau est plus petite si on l'enleve !
            
            
            s := ReplaceStringByStringInString(gZoo.urlDuZoo, '', action.debutLigne);
            action.debutLigne := s;
            

            if (verbosity >= 2) then ZooPrintOutput(action);

            AppendCharToLongString(action , lf );

            // envoyer la chaine au server Othello Zoo

            canUsePermanentConnection := SendStringToPermanentConnection(action , numeroSlot);
            if not(canUsePermanentConnection) then EnvoyerUneRequeteAuZooParTelechargementHTML(requete);
            
          end;
    end;
end;


procedure EnvoyerUneRequeteAuZooParTelechargementHTML(var requete : LongString);
var err : OSStatus;
    numeroLibre : SInt32;
    requestSent : boolean;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequeteAuZooParTelechargementHTML);

  with gZoo do
    begin

      if TrouverSlotLibreDansLaReservePourTelecharger(numeroLibre) then
        with gReserveZonesPourTelecharger.table[numeroLibre] do
          begin

            requestSent := false;

            if (numeroLibre >= 0) & (numeroLibre <= kNumberOfAsynchroneNetworkConnections) then
              begin

                if FindStringInLongString('rand=', requete) <= 0 then
                  AppendToLongString(requete, '&rand=' + NumEnString(abs(RandomLongint)));


                infoNetworkConnection := requete;

                MicroSeconds(gZoo.timer);

                err := ViderFichierAbstrait(petitFichierTampon);

                if FichierAbstraitEstCorrect(petitFichierTampon) & (err = NoErr)
                  then
                    begin
                      DownloadURLToFichierAbstrait(numeroLibre, requete, petitFichierTampon, AcknowledgementOfZooTransaction);

                      requestSent := true;

                      requeteDePoussageNecessaire := true;
                      inc(nbreRequetesPoussees);
                    end;
              end;

            if not(requestSent) then
              WritelnDansRapport('ASSERT : memory leak in EnvoyerUneRequeteAuZooParTelechargementHTML');

          end;

      VerifierLePoussageDesRequetesAuZoo;
      
      
      // Demander un nouveau job dans une seconde...
      dateDernierReleveDeJobSurLeZoo := Min(dateDernierReleveDeJobSurLeZoo, (TickCount + 60 - intervalleReleveDeJobSurLeZoo));  

  end;

end;




procedure RetryEnvoyerUneRequeteAuZoo(var requete : LongString);
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(RetryEnvoyerUneRequeteAuZoo);

  if (FindStringInLongString('&retry=1' , requete) <= 0) then
    begin
      AppendToLongString(requete , '&retry=1');
      EnvoyerUneRequeteAuZoo(requete);
    end;
end;




procedure AjouterHashDansCacheDesScoresEnvoyesAuZoo(const whichHash : UInt64);
begin
  gCacheDesScoresEnvoyesAuZoo[gCompteurCacheDesScoresEnvoyesAuZoo] := whichHash;

  inc(gCompteurCacheDesScoresEnvoyesAuZoo);
  if (gCompteurCacheDesScoresEnvoyesAuZoo > kTailleCacheDesScoresEnvoyesAuZoo)
    then gCompteurCacheDesScoresEnvoyesAuZoo := 1;
end;



function FindHashDansCacheDesScoresEnvoyesAuZoo(const whichHash : UInt64) : boolean;
var k,t : SInt32;
begin
  FindHashDansCacheDesScoresEnvoyesAuZoo := false;
  
  if not(HashValueDuZooEstCorrecte(whichHash)) then
    exit(FindHashDansCacheDesScoresEnvoyesAuZoo);
  
  for t := 0 to kTailleCacheDesScoresEnvoyesAuZoo do
    begin
      k := gCompteurCacheDesScoresEnvoyesAuZoo - t;
      
      if (k > kTailleCacheDesScoresEnvoyesAuZoo) then k := k - kTailleCacheDesScoresEnvoyesAuZoo;
      if (k < 1) then k := k + kTailleCacheDesScoresEnvoyesAuZoo;
      
      if Same64Bits(whichHash, gCacheDesScoresEnvoyesAuZoo[k]) then
        begin
          FindHashDansCacheDesScoresEnvoyesAuZoo := true;
          exit(FindHashDansCacheDesScoresEnvoyesAuZoo);
        end;
    end;
end;



function EnvoyerResultatDuCalculAuZoo(var zooJob : ZooJobRec; score : SInt32) : OSStatus;
var urlParams : String255;
    requete : LongString;
    job : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerResultatDuCalculAuZoo);

  with gZoo, zooJob.params, zooJob.params.outResult do
    begin

      if (score >= -64) & (score <= 64)
        then
          begin

            urlParams := '';
            EncoderSearchParamsPourURL(zooJob.params, urlParams, 'EnvoyerResultatDuCalculAuZoo');

            InitLongString(requete);

            if not(CassioEstEnTrainDeCalculerPourLeZoo) &
               CassioPeutDonnerDuTempsAuZoo &
               not(DemandeDeCalculPourLeZooDansLaFileLocale(job)) &
               JobIsEmpty(gZoo.jobPrefetched) &
               JobIsEmpty(GetPrefetchImportantPasEncoreCalcule)
              then
                begin
                  AppendToLongString(requete, urlDuZoo + '?action=SEND_SCORE_AND_GET_WORK&' + urlParams) ;
                  dateDernierReleveDeJobSurLeZoo := TickCount;
                end
              else
                begin
                  // WriteDansRapport('prefetched : ');
                  // WritelnLongStringDansRapport(gZoo.jobPrefetched);
                  
                  AppendToLongString(requete, urlDuZoo + '?action=SEND_SCORE&' + urlParams);

                  // on accelère tant qu'on peut le relevé d'un nouveau job
                  dateDernierReleveDeJobSurLeZoo := 0;
                end;



            // on met les resultats (score, suite, etc) dans l'url de la reponse
            AppendToLongString(requete, '&score=' + NumEnString(score));

            if (outBestMoveFinale >= 11) &
               (outBestMoveFinale <= 88) &
               (inPositionPourFinale[outBestMoveFinale] = pionVide) 
               then
                  begin

                    if (LENGTH_OF_STRING(outLineFinale) >= 4) & (CoupEnStringEnMajuscules(outBestMoveFinale) = LeftOfString(outLineFinale,2))
                      then
                        //AppendToLongString(requete, '&moves=' + LeftOfString(outLineFinale,20))  // on n'envoie que 10 coups de la suite :-(
                        //AppendToLongString(requete, '&moves=' + outLineFinale + 'Lessanglotslongsdesviolonsdelautomneblessentmoncoeurdunelangueurmonotone')
                        AppendToLongString(requete, '&moves=' + outLineFinale )
                      else
                        begin
                          AppendToLongString(requete, '&moves=' + CoupEnStringEnMajuscules(outBestMoveFinale));
                          if (outBestDefenseFinale >= 11) &
                             (outBestDefenseFinale <= 88) &
                             (inPositionPourFinale[outBestDefenseFinale] = pionVide) then
                             AppendToLongString(requete, CoupEnStringEnMajuscules(outBestDefenseFinale));
                        end;
                  end
               else
                 begin
                   WritelnDansRapport('ASSERT : moves est vide dans une reponse au zoo');
                   WritelnDansRapport('La réponse est la suivante : ');
                   WritelnLongStringDansRapport(requete);
                 end;

            AppendToLongString(requete, '&time=' + ReelEnString(outTimeTakenFinale));
            

            if (NumberOfPrefetch >= 30) then
              AppendToLongString(requete, '&prefetch=NO');
            
            
            // On ecrit dans le rapport les requetes longues de plus de 10 secondes ?
            {if outTimeTakenFinale >= 10.0 then
              WritelnLongStringDansRapport(requete);}
            
            
            // on envoie la reponse !
            AjouterHashDansCacheDesScoresEnvoyesAuZoo(zooJob.params.inHashValue);
            EnvoyerUneRequeteAuZoo(requete);


            dateDernierEnvoiDeResultatSurLeZoo := TickCount;

            
          end
        else
          begin
            ZooPrintWarning('ASSERT (score = '+NumEnString(score)+') dans EnvoyerResultatDuCalculAuZoo');
          end;

    end;


  EnvoyerResultatDuCalculAuZoo := NoErr;
end;


function SExcuserAupresDuZoo(var zooJob : ZooJobRec; const reason : String255) : OSStatus;
var urlParams : String255;
    requete : LongString;
begin

  (* reason peut valoir : CALCULATING  si Cassio calculait deja une autre position du zoo
                          RETIRED      si l'utilisateur a repris la main le Cassio
  *)

  (*
  BeginRapportPourZoo;
  WritelnDansRapport('');
  WriteTickOperationPourLeZooDansRapport;
  WritelnDansRapport('Je m''excuse auprès du zoo de ne pas pouvoir finir : ');
  ChangeFontFaceDansRapport(normal);
  WritelnPositionEtTraitDansRapport(zooJob.params.inPositionPourFinale,zooJob.params.inCouleurFinale);
  WritelnFenetreAlphaBetaDansRapport(zooJob.params.inAlphaFinale,zooJob.params.inBetaFinale);
  WritelnDansRapport('hash = ' + UInt64ToHexa(zooJob.inHashValue));
  WritelnDansRapport('');
  EndRapportPourZoo;
  *)

  urlParams := '';
  EncoderSearchParamsPourURL(zooJob.params, urlParams, 'SExcuserAupresDuZoo');

  requete := MakeLongString(gZoo.urlDuZoo + '?action=I_CANT_SOLVE&status=' + reason + '&' + urlParams);

  EnvoyerUneRequeteAuZoo(requete);
  
  SetZooStatus(reason);


  SExcuserAupresDuZoo := NoErr;
end;


function SExcuserAupresDuZooPourCetteHash(const whichHash : UInt64; const reason : String255) : OSStatus;
var requete : LongString;
begin

  (* reason peut valoir : CALCULATING  si Cassio calculait deja une autre position du zoo
                          RETIRED      si l'utilisateur a repris la main le Cassio
                          SEEKING_JOB  (normalement, ne devrait jamais arriver...)
  *)

  requete := MakeLongString(gZoo.urlDuZoo + '?action=I_CANT_SOLVE' 
                                          + '&asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio)
                                          + '&hash=' + UInt64ToHexa(whichHash)
                                          + '&status=' + reason);
                       
  // WritelnLongStringDansRapport(requete);
             
  EnvoyerUneRequeteAuZoo(requete);
  
  SExcuserAupresDuZooPourCetteHash := NoErr;
end;



function GetParameterStringInResultatDuZoo(const parameterName : String255; buffer : PackedArrayOfCharPtr; bufferSize : SInt32) : String255;
var s, result : String255;
    loc, start, lastRead : SInt32;
begin
  result := '';

  s := parameterName + '=';
  
  
  if FindStringInBuffer(s , Ptr(buffer) , bufferSize , 0 , +1 , loc) then
    begin
    
      start := loc + LENGTH_OF_STRING(s);
      
      result := ParserBuffer(Ptr(buffer) , bufferSize , start , lastRead );
    end;
  

  if (result = 'null') then result := '';

  GetParameterStringInResultatDuZoo := result;
end;


function JobIsEmpty(const job : LongString) : boolean;
begin
  JobIsEmpty := LongStringIsEmpty(job);
end;


function SameJobs(const job1, job2 : LongString) : boolean;
var empty1, empty2 : boolean;
    aux1, aux2 : LongString;
begin

  // d'abord, traiter les cas où l'un des jobs est vide...

  empty1 := LongStringIsEmpty(job1);
  empty2 := LongStringIsEmpty(job2);
  
  if (empty1 & empty2) then
    begin
      SameJobs := true;
      exit(SameJobs);
    end;
  
  if (empty1 <> empty2) then
    begin
      SameJobs := false;
      exit(SameJobs);
    end;
  
  // Maintenant on est sûr que (empty1 = false) et que (empty2 = false) !


  // Les deux jobs sont-ils tous les deux un "PREFETCH" ?   ==>  comparer les chaines ...
  if LongStringBeginsWith('PREFETCH ', job1) & LongStringBeginsWith('PREFETCH ', job2) then
    begin
      SameJobs := SameLongString(job1, job2);
      exit(SameJobs);
    end;
  
  // Les deux jobs sont-ils tous les deux un "JOB" ?   ==>  comparer les chaines ...
  if LongStringBeginsWith('JOB ', job1) & LongStringBeginsWith('JOB ', job2) then
    begin
      SameJobs := SameLongString(job1, job2);
      exit(SameJobs);
    end;
    
    
  //  Le cas le plus lent : un "JOB" et un "PREFETCH" : il faut remplacer PREFETCH par JOB et comparer les chaines...
  if ((LongStringBeginsWith('JOB ', job1) & LongStringBeginsWith('PREFETCH ', job2)) | (LongStringBeginsWith('PREFETCH ', job1) & LongStringBeginsWith('JOB ', job2))) then
    begin
      
      aux1 := CopyLongString(job1);
      aux2 := CopyLongString(job2);
      
      aux1.debutLigne := ReplaceStringByStringInString('PREFETCH ','JOB ',aux1.debutLigne);
      aux2.debutLigne := ReplaceStringByStringInString('PREFETCH ','JOB ',aux2.debutLigne);
    
      NormaliserLongString(aux1);
      NormaliserLongString(aux2);
    
      SameJobs := SameLongString(aux1 , aux2);
      
      exit(SameJobs);
     end;

  // On a tout essayer, mais ça ne semble vraiment pas les memes jobs
  SameJobs := false;
  
end;


function ProbCutStringDuZooEnMuString(cut : String255) : String255;
var selectivite,dist,distMin, i : SInt32;
    mu : String255;
begin

  cut    := ReplaceStringByStringInString('%','',cut);
  selectivite := ChaineEnLongint(cut);

  if (selectivite <= 0) | (selectivite >= 100) then selectivite := 100;

  mu := '0,'+NumEnString(kDeltaFinaleInfini);

  distMin := 1000000;
  for i := 1 to nbreDeltaSuccessifs do
    begin
      dist := abs(selectivite - deltaSuccessifs[i].selectiviteZebra);
      if (dist < distMin) then
      begin
        distMin := dist;
        mu := '0,'+ NumEnString(deltaSuccessifs[i].valeurDeMu);
      end;
    end;

  // WritelnDansRapport('ProbCutStringDuZooEnMuString  : ' + cut + ' => ' + mu);

  ProbCutStringDuZooEnMuString := mu;

end;


function MuStringEnProbCutStringDuZoo(mu : String255) : String255;
var left, right, cut : String255;
    muMax, dist, distMin, i: SInt32;
begin
  SplitByStr(mu, ',', left, right);

  muMax := ChaineEnLongint(right);

  cut := '';

  distMin := 1000000000;
  for i := 1 to nbreDeltaSuccessifs do
    begin

      dist := abs(muMax - deltaSuccessifs[i].valeurDeMu);

      if (dist < distMin) then
      begin
        distMin := dist;
        cut := NumEnString(deltaSuccessifs[i].selectiviteZebra) ;
      end;
    end;

  // WritelnDansRapport('MuStringEnProbCutStringDuZoo  : ' + mu + ' => ' + cut);


  if (cut = '') then
    begin
      WritelnDansRapport('ASSERT dans MuStringEnProbCutStringDuZoo');
      cut := '100';
    end;

  MuStringEnProbCutStringDuZoo := cut;

end;


procedure SetHashValueDuZoo(var hash : UInt64; value : SInt32);
begin
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  hash := value;
  {$ELSEC}
  hash.lo := value;
  if (value >= 0)
    then hash.hi := $00000000
    else hash.hi := $FFFFFFFF;
  {$ENDC}
end;


function HashValueDuZooEstNegative(const hash : UInt64) : boolean;
begin
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  HashValueDuZooEstNegative := ((hash and $8000000000000000) <> 0);
  {$ELSEC}
  HashValueDuZooEstNegative := ((hash.hi and $80000000) <> 0);
  {$ENDC}
end;


function HashValueDuZooEstCorrecte(const hash : UInt64) : boolean;
begin
  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  HashValueDuZooEstCorrecte := (SInt64(hash) > 0);
  {$ELSEC}
  HashValueDuZooEstCorrecte := ((hash.hi <> 0) | (hash.lo <> 0)) 
                               & (BAnd(hash.hi,$80000000) = 0);
  {$ENDC}
end;


function SExcuserAupresDuZooPourLaPositionPrefetched(const reason : String255) : OSStatus;
var params : MakeEndgameSearchParamRec;
    myJob : ZooJobRec;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(SExcuserAupresDuZooPourLaPositionPrefetched);

  if not(JobIsEmpty(gZoo.jobPrefetched))
     & PeutParserDemandeDeJob(gZoo.jobPrefetched, params) then
    begin
      EndgameSearchParamToZooJob(params, myJob);
      SExcuserAupresDuZooPourLaPositionPrefetched := SExcuserAupresDuZoo(myJob, reason);
    end;
end;


procedure CalculateHashOfSearchParams(var searchParams : MakeEndgameSearchParamRec);
var foo : String255;
begin
  SetHashValueDuZoo(searchParams.inHashValue , k_ZOO_NOT_INITIALIZED_VALUE);

  foo := '';
  EncoderSearchParamsPourURL(searchParams, foo, 'CalculateHashOfSearchParams');  // this has the side effect of calculating the hash value
end;


procedure EndgameSearchParamToZooJob(var searchParams : MakeEndgameSearchParamRec; var zooJob : ZooJobRec);
begin
  with zooJob do
    begin

      if HashValueDuZooEstNegative(searchParams.inHashValue) then
        CalculateHashOfSearchParams(searchParams);

      params := searchParams;
      comment := 'un petit commentaire';

      endgameSolveFlags := {kEndgameSolveEcrireInfosTechniquesDansRapport + }
                           kEndgameSolveCalculateInBackground;
                           {kEndgameSolveEcrirePositionDansRapport +}
                           {kEndgameSolveToujoursRamenerLaSuite};
    end;
end;


procedure ViderZooJob(var zooJob : ZooJobRec);
begin
  with zooJob do
    begin
      comment := '';
      endgameSolveFlags := 0;
      ViderSearchParams(params);
    end;
end;


function PeutParserDemandeDeJob(const ligne : LongString; var searchParams : MakeEndgameSearchParamRec) : boolean;
var i,j,len : SInt32;
    nbCasesVides : SInt32;
    s : LongString;
    buffer : packed array [0..1023] of char;
    action,platString,window,cut,depth,hash,mu,reste,priority : String255;
    left, right : String255;
    c : char;
    correct : boolean;
begin

  PeutParserDemandeDeJob := false;  // jusqu'a preuve du contraire...

  s := ligne;

  (*
  WritelnDansRapport('Je dois parser cette demande : ');
  WritelnDansRapport(s.debutLigne);
  *)
  

  (* des exemples a parser :
        JOB pos=----------X------OXX-----OXXXO---OXXXX---OOOO-------------------X window=-64,64 cut=100 depth=26 priority=0 hash=622f154deed2b1ad
     ou bien
        JOB pos=---O------O------OXX-----OXXXO---XXXXX----XOO-------------------X window=-64,64 cut=100 depth=26 priority=0 hash=7f0d61a1f00ef6bb
     ou bien :
        PREFETCH pos=----------X------OXX-----OXXXOO--XXXXO----XOO-------------------X window=-64,64 cut=100 depth=26 priority=0 hash=73d4b10ee8623955
     ou bien :
        PREFETCH pos=----------XO-----OOO-----OXOXO---XXOXX----XOO-------------------X window=-64,64 cut=100 depth=26 priority=0 hash=6f4ce977fee002c2

  *)

  
  LongStringToBuffer(s, @buffer[0], len);
  
  Parser(s.debutLigne, action, reste);
  
  platString  := GetParameterStringInResultatDuZoo('pos',      @buffer[0], len);
  window      := GetParameterStringInResultatDuZoo('window',   @buffer[0], len);
  cut         := GetParameterStringInResultatDuZoo('cut',      @buffer[0], len);
  depth       := GetParameterStringInResultatDuZoo('depth',    @buffer[0], len);
  hash        := GetParameterStringInResultatDuZoo('hash',     @buffer[0], len);
  priority    := GetParameterStringInResultatDuZoo('priority', @buffer[0], len);

  mu := ProbCutStringDuZooEnMuString(cut);


  if (action = 'JOB') | (action = 'PREFETCH') then
    begin

      ViderSearchParams(searchParams);

      (*
      WritelnDansRapport('action = '+action);
      WritelnDansRapport('platString = '+platString);
      WritelnDansRapport('window = '+window);
      WritelnDansRapport('cut = '+cut);
      WritelnDansRapport('depth = '+depth);
      WritelnDansRapport('hash = '+hash);
      *)

      with searchParams do
        begin

          // on parse les 64 caracteres de la position
          for i := 1 to 8 do
            for j := 1 to 8 do
              begin
                c := platString[i*8 + j - 8];

                if CharInSet(c,['#','x','X','*','•']) then
                  begin
                    inPositionPourFinale[i*10 + j] := pionNoir;
                    inc(inNbreNoirsFinale);
                  end;

                if CharInSet(c,['o','O','0']) then
                  begin
                    inPositionPourFinale[i*10 + j] := pionBlanc;
                    inc(inNbreBlancsFinale);
                  end;

                if CharInSet(c,['.','-','_',',','–','—','+'])
                  then inPositionPourFinale[i*10 + j] := pionVide;
              end;

          // le 65eme caractere code le trait
          c := platString[65];

          if CharInSet(c,['#','x','X','*','•'])
            then inCouleurFinale := pionNoir else

          if CharInSet(c,['o','O','0'])
            then inCouleurFinale := pionBlanc;

          // en finale, la profondeur est le nombre de cases vides

          nbCasesVides := 64 - inNbreNoirsFinale - inNbreBlancsFinale;

          // la fenetre alpha-beta

          SplitBy(window, ',' , left, right);
          inAlphaFinale := ChaineEnLongint(left);
          inBetaFinale := ChaineEnLongint(right);

          // la fenetre des mu

          SplitBy(mu, ',' , left, right);
          inMuMinimumFinale := ChaineEnLongint(left);
          inMuMaximumFinale := ChaineEnLongint(right);

          // la precision

          inPrecisionFinale := MuStringEnPrecisionEngine(mu);
          
          // la priorite

          inPrioriteFinale := ChaineEnLongint(priority);

          // la profondeur

          inProfondeurFinale := Min(nbCasesVides, ChaineEnLongint(depth));

          // le hash

          inHashValue := HexToUInt64(hash);
          
          // le type de calcul
          
          if (inProfondeurFinale >= nbCasesVides - 8)
            then
              begin  
                // c'est un job de finale
                if (inAlphaFinale >= -1) & (inBetaFinale <= 1)
                  then inTypeCalculFinale := ReflGagnant
                  else inTypeCalculFinale := ReflParfait;
              end
            else
              begin  
                // c'est un job de milieu de partie
                inTypeCalculFinale := ReflMilieu;
              end;


          ViderSearchResults(outResult); 


          correct := CheckEndgameSearchParams(searchParams) & HashValueDuZooEstCorrecte(inHashValue);
                     
                     
          (*
          WritelnPositionEtTraitDansRapport(inPositionPourFinale, inCouleurFinale);
          WritelnNumDansRapport('inNbreNoirsFinale = ',inNbreNoirsFinale);
          WritelnNumDansRapport('inNbreBlancsFinale = ',inNbreBlancsFinale);
          WritelnNumDansRapport('inMuMinimumFinale = ',inMuMinimumFinale);
          WritelnNumDansRapport('inMuMaximumFinale = ',inMuMaximumFinale);
          WritelnNumDansRapport('inPrecisionFinale = ',inPrecisionFinale);
          WritelnNumDansRapport('inAlphaFinale = '    ,inAlphaFinale);
          WritelnNumDansRapport('inBetaFinale = '     ,inBetaFinale);
          WritelnNumDansRapport('inTypeCalculFinale = ',inTypeCalculFinale);
          WritelnNumDansRapport('inHashValue = ',inHashValue);
          WritelnStringAndBoolDansRapport('correct = ',correct);
          *)
          

          PeutParserDemandeDeJob := correct;

        end;

    end;

end;


function PeutParserUnResultatDuZoo(const ligne : LongString; var params : MakeEndgameSearchParamRec; var action,moves,timestamp : String255) : boolean;
var i,j,len,coup,nbCasesVides : SInt32;
    k : SInt16;
    s : LongString;
    buffer : packed array [0..1023] of char;
    platString,window,cut,depth,hash,mu,reste : String255;
    scoreString,timeString : String255;
    left, right : String255;
    c : char;
    correct : boolean;
begin
  {exemples de resultat à parser :
     CALCULATED pos=--O-------O-----OOOOXXXXOOOXOXX-OXOXOXX-OOOOXOO----OOX----XO----X window=-64,64 cut=0,100000 depth=28 hash=1102267451 score=-6 time=20.3 moves=G4B2 date=20080702001545
     INCHARGE pos=--O-------O-----OOOOXXXXOOOXOXX-OXOXOXX-OOOOXOO----OOX----XO----X window=-64,64 cut=0,100000 depth=28 hash=1102267451 score=-6 time=20.3 moves=G4B2 date=20080702001545
     DELETED 420297083
  }

  PeutParserUnResultatDuZoo := false;   {jusqu'à preuve du contraire...}

  s := ligne;

  (*
  WritelnDansRapport('Je viens de recevoir ce résultat du zoo : ');
  WritelnLongStringDansRapport(s);
  *)

  LongStringToBuffer(s, @buffer[0], len);
  
  Parser(s.debutLigne, action, reste);
  
  platString  := GetParameterStringInResultatDuZoo('pos',    @buffer[0], len);
  window      := GetParameterStringInResultatDuZoo('window', @buffer[0], len);
  cut         := GetParameterStringInResultatDuZoo('cut',    @buffer[0], len);
  depth       := GetParameterStringInResultatDuZoo('depth',  @buffer[0], len);
  hash        := GetParameterStringInResultatDuZoo('hash',   @buffer[0], len);
  scoreString := GetParameterStringInResultatDuZoo('score',  @buffer[0], len);
  timeString  := GetParameterStringInResultatDuZoo('time',   @buffer[0], len);
  moves       := GetParameterStringInResultatDuZoo('moves',  @buffer[0], len);
  timestamp   := GetParameterStringInResultatDuZoo('date',   @buffer[0], len);


  mu          := ProbCutStringDuZooEnMuString(cut);


  if (action = 'DELETED') then
    begin
      params.inHashValue := HexToUInt64(reste);
      PeutParserUnResultatDuZoo := false;
      exit(PeutParserUnResultatDuZoo);
    end;

  if (action = 'CALCULATED') |
     (action = 'INCHARGE') |
     (action = 'COULDNTSOLVE') |
     (action = 'PREFETCHED') then
    begin

      ViderSearchParams(params);

      (*
      WritelnDansRapport('action = '+action);
      WritelnDansRapport('platString = '+platString);
      WritelnDansRapport('window = '+window);
      WritelnDansRapport('cut = '+cut);
      WritelnDansRapport('depth = '+depth);
      WritelnDansRapport('hash = '+hash);
      WritelnDansRapport('scoreString = '+scoreString);
      WritelnDansRapport('timeString = '+timeString);
      WritelnDansRapport('moves = '+moves);
      WritelnDansRapport('timestamp = '+timestamp);
      *)
      

      with params do
        begin

          // on parse les 64 caracteres de la position
          for i := 1 to 8 do
            for j := 1 to 8 do
              begin
                c := platString[i*8 + j - 8];

                if CharInSet(c,['#','x','X','*','•']) then
                  begin
                    inPositionPourFinale[i*10 + j] := pionNoir;
                    inc(inNbreNoirsFinale);
                  end;

                if CharInSet(c,['o','O','0']) then
                  begin
                    inPositionPourFinale[i*10 + j] := pionBlanc;
                    inc(inNbreBlancsFinale);
                  end;

                if CharInSet(c,['.','-','_','—','–',',','+'])
                  then inPositionPourFinale[i*10 + j] := pionVide;
              end;

          // le 65eme caractere code le trait
          c := platString[65];

          if CharInSet(c,['#','x','X','*','•'])
            then inCouleurFinale := pionNoir else

          if CharInSet(c,['o','O','0'])
            then inCouleurFinale := pionBlanc;


          // en finale, la profondeur est le nombre de cases vides

          nbCasesVides := 64 - inNbreNoirsFinale - inNbreBlancsFinale;


          // la fenetre alpha-beta

          SplitBy(window, ',' , left, right);
          inAlphaFinale := ChaineEnLongint(left);
          inBetaFinale := ChaineEnLongint(right);


          // la fenetre des mu

          SplitBy(mu, ',' , left, right);
          inMuMinimumFinale := ChaineEnLongint(left);
          inMuMaximumFinale := ChaineEnLongint(right);

          // la precision

          inPrecisionFinale := MuStringEnPrecisionEngine(mu);


          // la profondeur

          inProfondeurFinale := Min(nbCasesVides, ChaineEnLongint(depth));


          // le hash

          inHashValue := HexToUInt64(hash);


          // le score

          outResult.outScoreFinale := ChaineEnLongint(scoreString);


          // le temps pris

          outResult.outTimeTakenFinale := StringSimpleEnReel(timeString);


          // la suite

          outResult.outLineFinale                        := moves;
          outResult.outBestMoveFinale                    := k_ZOO_NOT_INITIALIZED_VALUE;
          outResult.outBestDefenseFinale                 := k_ZOO_NOT_INITIALIZED_VALUE;

          coup := ScannerStringPourTrouverCoup(1,moves,k);
          if (coup >= 11) & (coup <= 88) & (inPositionPourFinale[coup] = pionVide) then
            begin
              outResult.outBestMoveFinale := coup;

              coup := ScannerStringPourTrouverCoup(k+2,moves,k);
              if (coup >= 11) & (coup <= 88) & (inPositionPourFinale[coup] = pionVide)
                then outResult.outBestDefenseFinale := coup;

            end;

          // le tyope de calcul


          if (inProfondeurFinale >= nbCasesVides - 8)
            then
              begin  
                // c'est un job de finale
                if (inAlphaFinale >= -1) & (inBetaFinale <= 1)
                  then inTypeCalculFinale := ReflGagnant
                  else inTypeCalculFinale := ReflParfait;
              end
            else
              begin  
                // c'est un job de milieu de partie
                inTypeCalculFinale := ReflMilieu;
              end;





          (*
          WritelnPositionEtTraitDansRapport(inPositionPourFinale, inCouleurFinale);
          WritelnNumDansRapport('inNbreNoirsFinale = ',inNbreNoirsFinale);
          WritelnNumDansRapport('inNbreBlancsFinale = ',inNbreBlancsFinale);
          WritelnNumDansRapport('inMuMinimumFinale = ',inMuMinimumFinale);
          WritelnNumDansRapport('inMuMaximumFinale = ',inMuMaximumFinale);
          WritelnNumDansRapport('inPrecisionFinale = ',inPrecisionFinale);
          WritelnNumDansRapport('inAlphaFinale = '    ,inAlphaFinale);
          WritelnNumDansRapport('inBetaFinale = '     ,inBetaFinale);
          WritelnNumDansRapport('inTypeCalculFinale = ',inTypeCalculFinale);
          WritelnNumDansRapport('outScoreFinale = '    ,outScoreFinale);
          WritelnStringAndCoupDansRapport('outBestMoveFinale = ',outBestMoveFinale);
          WritelnStringAndCoupDansRapport('outBestDefenseFinale = ',outBestDefenseFinale);
          WritelnDansRapport('outLigneFinale = '+outLineFinale);
          WritelnStringAndReelDansRapport('outTimeTakenFinale = ',outTimeTakenFinale,5);
          *)

          correct := CheckEndgameSearchParams(params);

          PeutParserUnResultatDuZoo := correct;

        end;

    end;


end;




function GetHashValueOfPositionPrefetched : UInt64;
var params : MakeEndgameSearchParamRec;
    myJob : ZooJobRec;
    result : UInt64;
begin
  if not(JobIsEmpty(gZoo.jobPrefetched))
     & PeutParserDemandeDeJob(gZoo.jobPrefetched, params) 
    then
      begin
        EndgameSearchParamToZooJob(params, myJob);
        GetHashValueOfPositionPrefetched := params.inHashValue;
       end
    else
      begin
        SetHashValueDuZoo(result , k_ZOO_NOT_INITIALIZED_VALUE);
        GetHashValueOfPositionPrefetched := result;
      end;
end;





function FindZooJobDansCacheDesPositionsCalculees(whichHash : UInt64; var index : SInt32) : boolean;
var k : SInt32;
begin

  if Same64Bits(gCacheZooDesPositionsCalculees[gLastIndexCacheZooPositionsCalculees].hashValue , whichHash) then
      begin
        FindZooJobDansCacheDesPositionsCalculees := true;
        index := gLastIndexCacheZooPositionsCalculees;
        exit(FindZooJobDansCacheDesPositionsCalculees);
      end;

  for k := 1 to kTailleCacheDesPositionsCalculees do
    if Same64Bits(gCacheZooDesPositionsCalculees[k].hashValue , whichHash) then
      begin
        FindZooJobDansCacheDesPositionsCalculees := true;
        index := k;
        gLastIndexCacheZooPositionsCalculees := k;
        exit(FindZooJobDansCacheDesPositionsCalculees);
      end;

  FindZooJobDansCacheDesPositionsCalculees := false;
  index := -1;
end;


procedure AjouterDansCacheDesPositionsCalculees(whichHash : UInt64; whichScore,whichMove,whichDefense : SInt32; const suite : String255);
var foo : SInt32;
begin
  if not(FindZooJobDansCacheDesPositionsCalculees(whichHash,foo)) then
    begin
      gCacheZooDesPositionsCalculees[gCompteurCacheZooPositionsCalculees].hashValue    := whichHash;
      gCacheZooDesPositionsCalculees[gCompteurCacheZooPositionsCalculees].score        := whichScore;
      gCacheZooDesPositionsCalculees[gCompteurCacheZooPositionsCalculees].meilleurCoup := whichMove;
      gCacheZooDesPositionsCalculees[gCompteurCacheZooPositionsCalculees].meilleureDef := whichDefense;
      gCacheZooDesPositionsCalculees[gCompteurCacheZooPositionsCalculees].ligne        := suite;

      inc(gCompteurCacheZooPositionsCalculees);
      if (gCompteurCacheZooPositionsCalculees > kTailleCacheDesPositionsCalculees) then
         gCompteurCacheZooPositionsCalculees := 1;
    end;
end;

function GetScoreDansCacheDesPositionsCalculees(index : SInt32; var meilleurCoup,meilleureDef : SInt32; var suite : String255) : SInt32;
begin
  if (index >= 1) & (index <= kTailleCacheDesPositionsCalculees)
    then
      begin
        GetScoreDansCacheDesPositionsCalculees := gCacheZooDesPositionsCalculees[index].score;
        meilleurCoup                           := gCacheZooDesPositionsCalculees[index].meilleurCoup;
        meilleureDef                           := gCacheZooDesPositionsCalculees[index].meilleureDef;
        suite                                  := gCacheZooDesPositionsCalculees[index].ligne;
      end
    else
      begin
        GetScoreDansCacheDesPositionsCalculees := k_ZOO_NOT_INITIALIZED_VALUE;
        meilleurCoup                           := k_ZOO_NOT_INITIALIZED_VALUE;
        meilleureDef                           := k_ZOO_NOT_INITIALIZED_VALUE;
        suite                                  := '';
      end;
end;


function FindZooJobDansCacheDesPrefetch(whichHash : UInt64; var index : SInt32) : boolean;
var k : SInt32;
begin

  if Same64Bits(gCacheDesPrefetch[gLastIndexCacheDesPrefetch].hashValue , whichHash) then
    begin
      FindZooJobDansCacheDesPrefetch := true;
      index := gLastIndexCacheDesPrefetch;
      exit(FindZooJobDansCacheDesPrefetch);
    end;

  for k := 1 to kTailleCacheDesPrefetch do
    if Same64Bits(gCacheDesPrefetch[k].hashValue , whichHash) then
      begin
        FindZooJobDansCacheDesPrefetch := true;
        index := k;
        gLastIndexCacheDesPrefetch := k;
        exit(FindZooJobDansCacheDesPrefetch);
      end;

  FindZooJobDansCacheDesPrefetch := false;
  index := -1;
end;


(* Quand on doit absolument ecraser un job dans le cache des prefetch, il faut essayer 
   de supprimer celui qui semble le moins utile. 
   La fonction FindUnJobInutileDansCacheDesPrefetch() implemente ce choix. 
 *)
function FindUnJobInutileDansCacheDesPrefetch(var index : SInt32) : boolean;
var profMinMilieu, profMinEndgame : SInt32;
    profMaxMilieu, profMaxEndgame : SInt32;
    indexMinMilieu, indexMinEndgame : SInt32;
    indexMaxMilieu, indexMaxEndgame : SInt32;
    worstPriority, k : SInt32;
begin

  worstPriority := 5000000;
  
  profMinMilieu  :=  500;
  profMinEndgame :=  500;
  
  profMaxMilieu  := -500;
  profMaxEndgame := -500;
  
  indexMinMilieu  := -1;
  indexMinEndgame := -1;
  
  indexMaxMilieu  := -1;
  indexMaxEndgame := -1;

  for k := 1 to kTailleCacheDesPrefetch do
    with gCacheDesPrefetch[k] do
    if (depth <> k_ZOO_NOT_INITIALIZED_VALUE) & not(JobIsEmpty(s)) then
      begin
      
        if (priority < worstPriority) then
          begin
            worstPriority := priority;
          
            profMinMilieu  :=  500;
            profMinEndgame :=  500;
            
            profMaxMilieu  := -500;
            profMaxEndgame := -500;
            
            indexMinMilieu  := -1;
            indexMinEndgame := -1;
            
            indexMaxMilieu  := -1;
            indexMaxEndgame := -1;
          end;
          
        if (priority = worstPriority) then
          begin
      
            if (depth >= 24) 
              then
                begin
                  // depth >= 24 : on pense que c'est une requete de finale...
                  
                  // job de prof min de finale ?
                  if (depth < profMinEndgame) then
                    begin
                      profMinEndgame    := depth;
                      indexMinEndgame   := k;
                    end;
                  
                  // job de prof max de finale ?
                  if (depth > profMaxEndgame) then
                    begin
                      profMaxEndgame    := depth;
                      indexMaxEndgame   := k;
                    end;
                    
                end
              else
                begin
                  // depth < 23 : on pense que c'est une requete de milieu...
                  
                  // job de prof min de milieu ?
                  if (depth < profMinMilieu) then
                    begin
                      profMinMilieu     := depth;
                      indexMinMilieu    := k;
                    end; 
                  
                  // job de prof max de milieu ?
                  if (depth > profMaxMilieu) then
                    begin
                      profMaxMilieu     := depth;
                      indexMaxMilieu    := k;
                    end; 
                end;
            
          end;
      end;
      
   if (indexMinEndgame <> -1) & (profMinEndgame <= 64) & (profMinEndgame >= 0) then
     begin
       index := indexMinEndgame;
       FindUnJobInutileDansCacheDesPrefetch := true;
       exit(FindUnJobInutileDansCacheDesPrefetch);
     end;
   
   if (indexMinMilieu <> -1) & (profMinMilieu <= 64) & (profMinMilieu >= 0) then
     begin
       index := indexMinMilieu;
       FindUnJobInutileDansCacheDesPrefetch := true;
       exit(FindUnJobInutileDansCacheDesPrefetch);
     end;

   index := -1;
   FindUnJobInutileDansCacheDesPrefetch := false;
end;


(* Quand ils doivent developper un nouveau noeud de l'arbre (un nouveau job du zoo)
   les calculateurs doivent choisir, parmi les jobs qu'ils ont recus comme prefetch, 
   celui qui semble le plus utile. 
   La fonction GetPrefetchImportantPasEncoreCalcule() implemente ce choix dans Cassio. 
 *)
function GetPrefetchImportantPasEncoreCalcule : LongString;
var k,t,foo,alea : SInt32;
    profMinMilieu, profMinEndgame : SInt32;
    profMaxMilieu, profMaxEndgame : SInt32;
    indexMinMilieu, indexMinEndgame : SInt32;
    indexMaxMilieu, indexMaxEndgame : SInt32;
    bestPriority : SInt32;
begin
  bestPriority := -5000000;

  profMinMilieu  :=  50000;
  profMinEndgame :=  50000;
  
  profMaxMilieu  := -50000;
  profMaxEndgame := -50000;
  
  indexMinMilieu  := -1;
  indexMinEndgame := -1;
  
  indexMaxMilieu  := -1;
  indexMaxEndgame := -1;

  alea := (abs(Random)) mod kTailleCacheDesPrefetch;

  for t := 1 to kTailleCacheDesPrefetch do
    begin

      k := alea + t;

      if (k > kTailleCacheDesPrefetch) then k := k - kTailleCacheDesPrefetch;
      if (k < 1)                       then k := k + kTailleCacheDesPrefetch;

      with gCacheDesPrefetch[k] do
        if (depth <> k_ZOO_NOT_INITIALIZED_VALUE) &
           not(JobIsEmpty(s)) &  not(SameJobs(s, gZoo.jobEnCoursDeTraitement)) &
           not(FindZooJobDansCacheDesPositionsCalculees(hashValue,foo)) then
          begin
          
            if (priority > bestPriority) then
              begin
                bestPriority := priority;
              
                profMinMilieu  :=  50000;
                profMinEndgame :=  50000;
                
                profMaxMilieu  := -50000;
                profMaxEndgame := -50000;
                
                indexMinMilieu  := -1;
                indexMinEndgame := -1;
                
                indexMaxMilieu  := -1;
                indexMaxEndgame := -1;
              end;
              
            if (priority = bestPriority) then
              begin
          
                if (depth >= 24)   // depth >= 24 : on pense que c'est une requete de finale...
                  then
                    begin
                      
                      // job de prof min de finale ?
                      if (depth < profMinEndgame) then
                        begin
                          profMinEndgame    := depth;
                          indexMinEndgame   := k;
                        end;
                      
                      // job de prof max de finale ?
                      if (depth > profMaxEndgame) then
                        begin
                          profMaxEndgame    := depth;
                          indexMaxEndgame   := k;
                        end;
                        
                    end
                  else            // depth < 23 : on pense que c'est une requete de milieu...
                    begin
                      
                      // job de prof min de milieu ?
                      if (depth < profMinMilieu) then
                        begin
                          profMinMilieu     := depth;
                          indexMinMilieu    := k;
                        end; 
                      
                      // job de prof max de milieu ?
                      if (depth > profMaxMilieu) then
                        begin
                          profMaxMilieu     := depth;
                          indexMaxMilieu    := k;
                        end; 
                    end;
              end;
              
          end;
    end;


  // Notre stratégie de developpement des noeuds est la suivante : 
  // parmi les noeuds de priorite maximale, d'abord les noeuds de
  // finale de prof max, puis les noeuds de milieu de prof minimale
  

  
  
  // FIXME min ou max pour le milieu ?
    
  
  if (indexMaxMilieu <> -1) & (profMaxMilieu >= 0) & (profMaxMilieu <= 64) then
    begin
      GetPrefetchImportantPasEncoreCalcule := gCacheDesPrefetch[indexMaxMilieu].s;
      exit(GetPrefetchImportantPasEncoreCalcule);
    end;
  
  if (indexMinMilieu <> -1) & (profMinMilieu >= 0) & (profMinMilieu <= 64) then
    begin
      GetPrefetchImportantPasEncoreCalcule := gCacheDesPrefetch[indexMinMilieu].s;
      exit(GetPrefetchImportantPasEncoreCalcule);
    end;
    
    
  if (indexMaxEndgame <> -1) & (profMaxEndgame >= 0) & (profMaxEndgame <= 64) then
    begin
      GetPrefetchImportantPasEncoreCalcule := gCacheDesPrefetch[indexMaxEndgame].s;
      exit(GetPrefetchImportantPasEncoreCalcule);
    end;
  
  if (indexMinEndgame <> -1) & (profMinEndgame >= 0) & (profMinEndgame <= 64) then
    begin
      GetPrefetchImportantPasEncoreCalcule := gCacheDesPrefetch[indexMinEndgame].s;
      exit(GetPrefetchImportantPasEncoreCalcule);
    end;
    

  GetPrefetchImportantPasEncoreCalcule := MakeLongString('');
end;





procedure GetOccupationDuCacheDesPrefetch(var nbPositionDansCache,profMin,profMax : SInt32);
var k,foo : SInt32;
begin
  nbPositionDansCache := 0;

  profMin :=  500;
  profMax := -500;

  for k := 1 to kTailleCacheDesPrefetch do
    with gCacheDesPrefetch[k] do
    if (depth <> k_ZOO_NOT_INITIALIZED_VALUE) &
       not(JobIsEmpty(s)) & not(FindZooJobDansCacheDesPositionsCalculees(hashValue,foo)) then
      begin
        inc(nbPositionDansCache);

        if (depth < profMin) then profMin := depth;
        if (depth > profMax) then profMax := depth;
      end;
end;


function NumberOfPrefetch : SInt32;
var k, count : SInt32;
begin
  count := 0;
  for k := 1 to kTailleCacheDesPrefetch do
    if (gCacheDesPrefetch[k].depth <> k_ZOO_NOT_INITIALIZED_VALUE) then
      inc(count);
  
  NumberOfPrefetch := count;
end;



function FindEmplacementVideDansCacheDesPrefetch(var index : SInt32) : boolean;
var k : SInt32;
begin

  for k := 1 to kTailleCacheDesPrefetch do
    if (gCacheDesPrefetch[k].depth = k_ZOO_NOT_INITIALIZED_VALUE) then
      begin
        FindEmplacementVideDansCacheDesPrefetch := true;
        index := k;
        gLastIndexCacheDesPrefetch := k;
        exit(FindEmplacementVideDansCacheDesPrefetch);
      end;

  FindEmplacementVideDansCacheDesPrefetch := false;
  index := -1;
end;


procedure AjouterDansCacheDesPrefetch(const params : MakeEndgameSearchParamRec; const job : LongString);
var index, foo : SInt32;
begin
  if not(FindZooJobDansCacheDesPrefetch(params.inHashValue,foo)) then
    begin

      if FindEmplacementVideDansCacheDesPrefetch(index)
        then
          begin
          
            //WritelnDansRapport('nouveau prefetch');
          
            gCacheDesPrefetch[index].hashValue := params.inHashValue;
            gCacheDesPrefetch[index].depth     := params.inProfondeurFinale;
            gCacheDesPrefetch[index].priority  := params.inPrioriteFinale;
            gCacheDesPrefetch[index].s         := job;
          end
        else
          begin

            if FindUnJobInutileDansCacheDesPrefetch(index)
              then
                begin
                  // On ecrase un prefetch qui semble un peu inutile
                  
                  //WritelnDansRapport('ecrasement : profondeur minimale');
                
                  gCacheDesPrefetch[index].hashValue := params.inHashValue;
                  gCacheDesPrefetch[index].depth     := params.inProfondeurFinale;
                  gCacheDesPrefetch[index].priority  := params.inPrioriteFinale;
                  gCacheDesPrefetch[index].s         := job;
                end
              else
                begin
                  // on ecrase un prefetch au hasard
                  
                  //WritelnDansRapport('ecrasement : au hasard');

                  gCacheDesPrefetch[gCompteurCacheDesPrefetch].hashValue := params.inHashValue;
                  gCacheDesPrefetch[gCompteurCacheDesPrefetch].depth     := params.inProfondeurFinale;
                  gCacheDesPrefetch[gCompteurCacheDesPrefetch].priority  := params.inPrioriteFinale;
                  gCacheDesPrefetch[gCompteurCacheDesPrefetch].s         := job;

                  inc(gCompteurCacheDesPrefetch);
                  if (gCompteurCacheDesPrefetch > kTailleCacheDesPrefetch) then
                     gCompteurCacheDesPrefetch := 1;
                end;
          end;
    end;
end;

function GetJobDansCacheDesPrefetch(index : SInt32) : LongString;
begin
  if (index >= 1) & (index <= kTailleCacheDesPrefetch)
    then GetJobDansCacheDesPrefetch := gCacheDesPrefetch[index].s
    else GetJobDansCacheDesPrefetch := MakeLongString('');
end;



procedure RetirerCeJobDuCacheDesPositionsPrefetchUtiles(whichHash : UInt64);
var k : SInt32;
begin

  for k := 1 to kTailleCacheDesPrefetch do
    if Same64Bits(gCacheDesPrefetch[k].hashValue , whichHash) then
      begin
        gCacheDesPrefetch[k].depth     :=                  k_ZOO_NOT_INITIALIZED_VALUE;
        gCacheDesPrefetch[k].priority  :=                  k_ZOO_NOT_INITIALIZED_VALUE;
        SetHashValueDuZoo(gCacheDesPrefetch[k].hashValue , k_ZOO_NOT_INITIALIZED_VALUE);
        InitLongString(gCacheDesPrefetch[k].s);
      end;

end;


procedure LancerCalculDeMilieuCommeClientPourLeZoo(var zooJob : ZooJobRec);
var affichageDansRapport : boolean;
    score, ticks : SInt32;
    tempsRequete : double_t;
begin

  with zooJob do
    begin
    
      ticks := TickCount;
  
      affichageDansRapport := false;
      
      if affichageDansRapport | CassioEstEnTrainDeDebuguerLeZooEnLocal then
        begin
          BeginRapportPourZoo;
          WritelnDansRapport('');
          WriteTickOperationPourLeZooDansRapport;
          WritelnDansRapport('J''essaye de calculer en milieu pour le zoo : ');
          ChangeFontFaceDansRapport(normal);
          WritelnPositionEtTraitDansRapport(zooJob.params.inPositionPourFinale,zooJob.params.inCouleurFinale);
          WritelnFenetreAlphaBetaDansRapport(zooJob.params.inAlphaFinale,zooJob.params.inBetaFinale);
          WritelnNumDansRapport('depth = ',zooJob.params.inProfondeurFinale);
          WritelnDansRapport('hash = ' + UInt64ToHexa(zooJob.params.inHashValue));
          WritelnDansRapport('');
          EndRapportPourZoo;
        end;
      

      // on calcule ce job de milieu, hein !
      score := LanceurAlphaBetaMilieuWithSearchParams(params);
      
      
      // ajuster les statistiques du zoo
      tempsRequete := (1.0*(TickCount - ticks) / 60.0);
      if (params.outResult.outTimeTakenFinale >= 0.0) & (interruptionReflexion = pasdinterruption) & (params.outResult.outTimeTakenFinale > tempsRequete) 
        then tempsRequete := params.outResult.outTimeTakenFinale;
      gZoo.tempsTotalDeCalculPourLeZoo := gZoo.tempsTotalDeCalculPourLeZoo + tempsRequete;
      
      if (params.outResult.outTimeTakenFinale >= 0.0) & (interruptionReflexion = pasdinterruption) then
        begin
          gZoo.tempsTotalDesJobsUtilesPourLeZoo   := gZoo.tempsTotalDesJobsUtilesPourLeZoo   + params.outResult.outTimeTakenFinale;
          gZoo.tempsTotalDesJobsDeMilieuPourLeZoo := gZoo.tempsTotalDesJobsDeMilieuPourLeZoo + params.outResult.outTimeTakenFinale;
        end;
      inc(gZoo.nbJobsMidgame);
                
                
      if affichageDansRapport | CassioEstEnTrainDeDebuguerLeZooEnLocal then
        begin
          BeginRapportPourZoo;
          WritelnDansRapport('');
          WriteTickOperationPourLeZooDansRapport;
          WritelnDansRapport('Fin de mon calcul de milieu pour le zoo : ');
          ChangeFontFaceDansRapport(normal);
          WritelnPositionEtTraitDansRapport(zooJob.params.inPositionPourFinale,zooJob.params.inCouleurFinale);
          WritelnFenetreAlphaBetaDansRapport(zooJob.params.inAlphaFinale,zooJob.params.inBetaFinale);
          WritelnNumDansRapport('depth = ',zooJob.params.inProfondeurFinale);
          WriteNumDansRapport('score = ',zooJob.params.outResult.outScoreFinale);
          WritelnDansRapport(', suite = ' + zooJob.params.outResult.outLineFinale);
          WriteStringAndCoupDansRapport('coup = ',zooJob.params.outResult.outBestMoveFinale);
          WritelnStringAndCoupDansRapport(' , def = ',zooJob.params.outResult.outBestDefenseFinale);
          WritelnStringAndReelDansRapport('temps = ',zooJob.params.outResult.outTimeTakenFinale,5);
          WritelnDansRapport('hash = ' + UInt64ToHexa(zooJob.params.inHashValue));
          WritelnInterruptionDansRapport(interruptionReflexion);
          WritelnDansRapport('');
          EndRapportPourZoo;
        end;
            
    end;
            
end;



procedure LancerCalculDeFinaleCommeClientPourLeZoo(var zooJob : ZooJobRec);
var affichageDansRapport : boolean;
    numeroEngine, score, ticks : SInt32;
    tempsRequete : double_t;
begin

  with zooJob do
    begin
      ticks := TickCount;
  
      affichageDansRapport := false;
      
      if affichageDansRapport | CassioEstEnTrainDeDebuguerLeZooEnLocal then
        begin
          BeginRapportPourZoo;
          WritelnDansRapport('');
          WriteTickOperationPourLeZooDansRapport;
          WritelnDansRapport('J''essaye de calculer en finale pour le zoo : ');
          ChangeFontFaceDansRapport(normal);
          WritelnPositionEtTraitDansRapport(zooJob.params.inPositionPourFinale,zooJob.params.inCouleurFinale);
          WritelnFenetreAlphaBetaDansRapport(zooJob.params.inAlphaFinale,zooJob.params.inBetaFinale);
          WritelnDansRapport('hash = ' + UInt64ToHexa(zooJob.params.inHashValue));
          WritelnDansRapport('');
          EndRapportPourZoo;
        end;
      

      // si un moteur est disponible, on demandera directement au moteur la valeur
      // sans trier les coups avec le milieu de Cassio, etc.
      if CassioIsUsingAnEngine(numeroEngine) then
        endgameSolveFlags := endgameSolveFlags or kEndgameSolvePassDirectlyToEngine;

      // on calcule ce job de finale, hein !
      score := ScoreParfaitFinaleWithSearchParams(params, endgameSolveFlags);
      
      
      // ajuster les statistiques du zoo
      tempsRequete := (1.0*(TickCount - ticks) / 60.0);
      if (params.outResult.outTimeTakenFinale >= 0.0) & (interruptionReflexion = pasdinterruption) & (params.outResult.outTimeTakenFinale > tempsRequete) 
        then tempsRequete := params.outResult.outTimeTakenFinale;
      gZoo.tempsTotalDeCalculPourLeZoo := gZoo.tempsTotalDeCalculPourLeZoo + tempsRequete;
      
      if (params.outResult.outTimeTakenFinale >= 0.0) & (interruptionReflexion = pasdinterruption) then
        begin
          gZoo.tempsTotalDesJobsUtilesPourLeZoo := gZoo.tempsTotalDesJobsUtilesPourLeZoo + params.outResult.outTimeTakenFinale;
          // nb de jobs de moins d'1/20 de seconde ?
          if (params.outResult.outTimeTakenFinale <= 0.05)   
            then inc(gZoo.nbJobsEndgameTriviaux);
        end;
                
                
      if affichageDansRapport | CassioEstEnTrainDeDebuguerLeZooEnLocal then
        begin
          BeginRapportPourZoo;
          WritelnDansRapport('');
          WriteTickOperationPourLeZooDansRapport;
          WritelnDansRapport('Fin de mon calcul de finale pour le zoo : ');
          ChangeFontFaceDansRapport(normal);
          WritelnPositionEtTraitDansRapport(zooJob.params.inPositionPourFinale,zooJob.params.inCouleurFinale);
          WritelnFenetreAlphaBetaDansRapport(zooJob.params.inAlphaFinale,zooJob.params.inBetaFinale);
          WritelnNumDansRapport('depth = ',zooJob.params.inProfondeurFinale);
          WriteNumDansRapport('score = ',zooJob.params.outResult.outScoreFinale);
          WritelnDansRapport(', suite = ' + zooJob.params.outResult.outLineFinale);
          WriteStringAndCoupDansRapport('coup = ',zooJob.params.outResult.outBestMoveFinale);
          WritelnStringAndCoupDansRapport(' , def = ',zooJob.params.outResult.outBestDefenseFinale);
          WritelnStringAndReelDansRapport('temps = ',zooJob.params.outResult.outTimeTakenFinale,5);
          WritelnDansRapport('hash = ' + UInt64ToHexa(zooJob.params.inHashValue));
          WritelnDansRapport('');
          EndRapportPourZoo;
        end;
            
    end;
            
end;



function LancerCalculCommeClientPourLeZoo(zooJob : ZooJobRec) : OSStatus;
var score,index,meilleurCoup,meilleureDef : SInt32;
    meilleureSuite : String255;
    err : OSStatus;
    oldValue : boolean;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(LancerCalculCommeClientPourLeZoo);

  if CassioEstEnTrainDeCalculerPourLeZoo
    then
      begin
        ZooPrintWarning('ERROR !! Cassio est deja en train de calculer pour le zoo dans LancerCalculCommeClientPourLeZoo : aborting');

        LancerCalculCommeClientPourLeZoo := -1;
        exit(LancerCalculCommeClientPourLeZoo);
      end
    else
      begin
        SetCassioEstEnTrainDeCalculerPourLeZoo(true, @oldValue);

        with zooJob do
          begin

            inc(gZoo.nbJobsCommences);

            if FindZooJobDansCacheDesPositionsCalculees(zooJob.params.inHashValue,index)
              then
                begin
                  score := GetScoreDansCacheDesPositionsCalculees(index, meilleurCoup, meilleureDef, meilleureSuite);
                  params.outResult.outScoreFinale        := score;
                  params.outResult.outBestMoveFinale     := meilleurCoup;
                  params.outResult.outBestDefenseFinale  := meilleureDef;
                  params.outResult.outLineFinale         := meilleureSuite;
                  params.outResult.outTimeTakenFinale    := 0.01;    {un centieme de seconde, disons }
                  inc(gZoo.nbJobsEndgameTriviaux);
                end
              else
                begin
                  // Le job n'est plus un prefetch puisqu'on va le calculer
                  RetirerCeJobDuCacheDesPositionsPrefetchUtiles(zooJob.params.inHashValue);

                  // On va envoyer tout de suite une requete au zoo pour indiquer que l'on vient
                  // de commencer à calculer ce job, et demander de nous interrompre s'il a disparu
                  gZoo.positionChercheeADisparuDuZoo                  := false;
                  gZoo.dateDerniereVerificationUtiliteCalculPourLeZoo := TickCount - gZoo.intervalleVerificationUtiliteCalculPourLeZoo - 10;
                  
                  VerifierUtiliteCalculPourLeZoo(false);
                  
                  
                  // Go pour le calcul !
                  if (params.inTypeCalculFinale = ReflMilieu)
                    then LancerCalculDeMilieuCommeClientPourLeZoo(zooJob)   // midgame
                    else LancerCalculDeFinaleCommeClientPourLeZoo(zooJob);  // endgame
                    
                  
                  // Lire les resultats du calcul
                  score          := params.outResult.outScoreFinale;
                  meilleurCoup   := params.outResult.outBestMoveFinale;
                  meilleureDef   := params.outResult.outBestDefenseFinale;
                  meilleureSuite := params.outResult.outLineFinale;
                    
                end;


           if (score >= -64) & (score <= 64) & (interruptionReflexion = pasdinterruption)
             then
               begin
                 SetCassioEstEnTrainDeCalculerPourLeZoo(false, NIL);
                 InitLongString(gZoo.jobEnCoursDeTraitement);
                 ViderZooJob(gZoo.rechercheEnCours);

                 AjouterDansCacheDesPositionsCalculees(zooJob.params.inHashValue, score, meilleurCoup, meilleureDef, meilleureSuite);
                 RetirerCeJobDuCacheDesPositionsPrefetchUtiles(zooJob.params.inHashValue);

                 err := EnvoyerResultatDuCalculAuZoo(zooJob, score);
                 
                 AjusteSleep;
               end
             else
               begin

                 if gZoo.positionChercheeADisparuDuZoo
                   then
                     begin

                       gZoo.positionChercheeADisparuDuZoo := false;
                       EnleveCetteInterruption(interruptionPositionADisparuDuZoo);

                       // on accelère tant qu'on peut le relevé d'un nouveau job
                       gZoo.dateDernierReleveDeJobSurLeZoo := 0;
                     end
                   else
                     begin

                       (* L'utilisateur a repris la main dans notre Cassio : il faut indiquer
                          au zoo que l'on n'est plus capable de finir le calcul dont on
                          s'était chargé (il lui faut donc enlever le drapeau 'INCHARGE' dans
                          la base SQL)
                        *)

                       err := SExcuserAupresDuZoo(zooJob, 'RETIRED' );
                       err := SExcuserAupresDuZooPourLaPositionPrefetched( 'RETIRED' );
                       
                       EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo('L''utilisateur a repris la main ?');
                           

                       if Quitter then
                         begin
                           ViderZooJob(gZoo.rechercheEnCours);
                           BouclerUnPeuAvantDeQuitterEnSurveillantLeReseau(30);
                         end;

                     end;

                 err := -1;
               end;

         end;

        ViderZooJob(gZoo.rechercheEnCours);

        SetCassioEstEnTrainDeCalculerPourLeZoo(false, NIL);

        LancerCalculCommeClientPourLeZoo := err;
      end;
end;


procedure EncoderSearchParamsPourURL(var searchParams : MakeEndgameSearchParamRec; var urlParams : String255; fonctionAppelante : String255);
var i,j : SInt32;
    s,mu,cut : String255;
    calculatedHash : UInt64;
begin

  DIscard(fonctionAppelante);

  // urlParams := urlParams + 'rand=' + NumEnString(Abs(RandomLongint));


  s := 'pos=';

  with searchParams do
    begin

      for i := 1 to 8 do
        for j := 1 to 8 do
          begin
            case inPositionPourFinale[i*10+j] of
              pionNoir : s := s + 'X';
              pionBlanc : s := s + 'O';
              pionVide : s := s + '-';
              otherwise s := s + '-';
            end;
          end;

      case inCouleurFinale of
        pionNoir : s := s + 'X';
        pionBlanc : s := s + 'O';
        pionVide : s := s + '-';
        otherwise s := s + '-';
      end;

      s := s + '&window=' + NumEnString(inAlphaFinale) + ',' + NumEnString(inBetaFinale);

      mu := NumEnString(inMuMinimumFinale) + ',' + NumEnString(inMuMaximumFinale);
      cut := MuStringEnProbCutStringDuZoo(mu);

      s := s + '&cut=' + cut;

      s := s + '&depth=' + NumEnString(inProfondeurFinale);


      calculatedHash := HashString63Bits(s);


      if HashValueDuZooEstNegative(inHashValue)
        then
          begin
            (*
            WritelnDansRapport('dans EncoderSearchParamsPourURL, fonctionAppelante = '+fonctionAppelante);
            WritelnNumDansRapport('hashValue <= 0, donc j''utilise calculatedHash : ',calculatedHash);
            *)
            inHashValue := calculatedHash;
          end
        else
          begin
            if not(Same64Bits(inHashValue , calculatedHash)) then
              begin
                (*
                WritelnDansRapport('dans EncoderSearchParamsPourURL, fonctionAppelante = '+fonctionAppelante);
                WritelnNumDansRapport('inHashValue <> calculatedHash !  J''utilise la hash fournie : ',inHashValue);
                *)
              end;
          end;

      s := 'hash=' + UInt64ToHexa(inHashValue) + '&' + s;

      s := s + '&asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio);

      s := s + '&priority=' + NumEnString(inPrioriteFinale);

      urlParams := urlParams + s;

    end;

end;


procedure MettreAJourLeTempsDeReponseDuZoo;
var time : UnsignedWide;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(MettreAJourLeTempsDeReponseDuZoo);

  with gZoo do
    begin
      inc(nbreDePingsSurLeZoo);

      MicroSeconds(time);
      
      WritelnNumDansRapport('PING reçu après (en seconds) : ',time.hi - gZoo.timerPourPing.hi);
      WritelnNumDansRapport('PING reçu après (en µsecondes) : ',time.lo - gZoo.timerPourPing.lo);
      

      // on stock le temps de reponse (en ticks, c'est-a-dire en 1/60 de secondes }

      tempsDeReponse := (time.hi - gZoo.timerPourPing.hi) * 60 +
                        (time.lo - gZoo.timerPourPing.lo) div 16666;    (* car 1/60 de seconde = 16666 microsecondes *)

      
      BeginRapportPourZoo;
      ChangeFontFaceDansRapport(normal);
      WriteNumDansRapport('   tempsDeReponse  = ',(time.hi - gZoo.timerPourPing.hi)*1000 + ((time.lo - gZoo.timerPourPing.lo) div 1000));
      WritelnDansRapport(' ms');
      EndRapportPourZoo;
      
    end;
end;



procedure ZooWantsToStartANewTest;
var numero : SInt32;
begin
  
  if CassioPeutDonnerDuTempsAuZoo 
     & CassioIsUsingAnEngine(numero) 
     & not(CassioIsWaitingAnEngineResult)
    then EngineEmptyHash;
  
  if CassioPeutDonnerDuTempsAuZoo then
    begin
      LanceInterruptionSimple('ZooWantsToStartANewTest');
      KillAndRestartCurrentEngine;
      VideToutesLesHashTablesExactes;
      VideHashTable(HashTable);
    end;
    
  EmptyCacheZooDesPositionsCalculees;
end;



procedure PrefetchJobDuZoo(const s : LongString);
var params : MakeEndgameSearchParamRec;
    theJob : ZooJobRec;
    foo : SInt32;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(PrefetchJobDuZoo);

  if not(JobIsEmpty(s)) & not(SameJobs(s , gZoo.jobPrefetched)) & not(SameJobs(s , gZoo.jobEnCoursDeTraitement)) &
     PeutParserDemandeDeJob(s, params) then
    begin

      EndgameSearchParamToZooJob(params, theJob);

      if not(FindZooJobDansCacheDesPositionsCalculees(theJob.params.inHashValue,foo)) then
        begin
        
          AjouterDansCacheDesPrefetch(theJob.params, s);

          if JobIsEmpty(gZoo.jobPrefetched) then
            gZoo.jobPrefetched := GetPrefetchImportantPasEncoreCalcule;

          if ((Abs(random) mod 10000) = 0) then {une chance sur dix mille de passer comme prochaine position evaluee}
            begin
              if JobIsEmpty(gZoo.jobPrefetched) |
                 SameJobs(gZoo.jobPrefetched , gZoo.jobEnCoursDeTraitement)
                then gZoo.jobPrefetched := s;
            end;

        end;
    end;
end;


procedure TraiterJobDuZoo(const s : LongString);
var params : MakeEndgameSearchParamRec;
    myJob : ZooJobRec;
    err : OSStatus;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(TraiterJobDuZoo);

  if CassioPeutDonnerDuTempsAuZoo & not(CassioEstEnTrainDeCalculerPourLeZoo) &
     (JobIsEmpty(gZoo.jobEnCoursDeTraitement) | SameJobs(gZoo.jobEnCoursDeTraitement , s))
    then
      begin

        if not(JobIsEmpty(gZoo.jobEnCoursDeTraitement)) & not(SameJobs(gZoo.jobEnCoursDeTraitement , s)) then
          begin
            BeginRapportPourZoo;
            WritelnDansRapport('ASSERT !!!  Impossible de traiter le job suivant : ');
            ChangeFontFaceDansRapport(normal);
            WritelnLongStringDansRapport(s);
            WritelnDansRapport('car j''avais déjà un autre job sur le feu (prévenez Stéphane !)');
            WritelnDansRapport('');
            EndRapportPourZoo;
          end;

        // go pour cette position !
        gZoo.jobEnCoursDeTraitement := s;
      end
  else
    begin
    
      { si on était déjà en train de calculer pour le zoo sur une autre position,
        c'est que les messages se sont croisés sur l'internet : mais comme on ne peut
        pas faire deux recherches en meme temps, on s'excuse auprès du zoo...}
        
      if not(JobIsEmpty(s)) & not(SameJobs(s , gZoo.jobEnCoursDeTraitement)) &
         PeutParserDemandeDeJob(s, params) then
        begin
          EndgameSearchParamToZooJob(params, myJob);
          err := SExcuserAupresDuZoo(myJob, 'CALCULATING' );

          if JobIsEmpty(gZoo.jobPrefetched) then PrefetchJobDuZoo(s);
        end;
    end;
end;


procedure VerifierLocalementLaFileDesPrefetchs;
var hashCalculCourant : UInt64;
begin

  hashCalculCourant := HashDuCalculCourantDeCassioPourLeZoo;

  // d'abord nettoyer le cache des prefetchs en y enlevant la position calculee courante
  RetirerCeJobDuCacheDesPositionsPrefetchUtiles(hashCalculCourant);

  // puis nettoyer le prefetch en cours si c'est la position calculee courante
  if Same64Bits(hashCalculCourant , GetHashValueOfPositionPrefetched) then
    gZoo.jobPrefetched := GetPrefetchImportantPasEncoreCalcule;
end;



procedure EnvoyerUneRequetePourVerifierLeCacheDesPrefetch;
var requete : LongString;
    hashDuPrefetchActuel : String255;
    nbPrefetchedChecked, k : SInt32;
    hashCalculCourant : UInt64;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequetePourVerifierLeCacheDesPrefetch);

  // WritelnDansRapport('Entree dans EnvoyerUneRequetePourVerifierLeCacheDesPrefetch');

  if CassioEstEnTrainDeCalculerPourLeZoo then
    with gZoo do
      begin
      
        VerifierLocalementLaFileDesPrefetchs;

        hashCalculCourant := HashDuCalculCourantDeCassioPourLeZoo;

        requete := MakeLongString(urlDuZoo + '?action=STILL_PREFETCHED&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));

        nbPrefetchedChecked := 0;

        for k := 1 to kTailleCacheDesPrefetch do
          if (gCacheDesPrefetch[k].depth <> k_ZOO_NOT_INITIALIZED_VALUE) then
            begin
            
              if (nbPrefetchedChecked <= 10) then  // la commande STILL_PREFETCHED du zoo attend au max 10 (ou à la rigueur 11) parametres...
                begin
            
                  inc(nbPrefetchedChecked);
                  if (nbPrefetchedChecked = 1)
                    then AppendToLongString(requete , '&hash='                                      + UInt64ToHexa(gCacheDesPrefetch[k].hashValue))
                    else AppendToLongString(requete , '&h' + NumEnString(nbPrefetchedChecked) + '=' + UInt64ToHexa(gCacheDesPrefetch[k].hashValue));
                
                end;
                
              if not(HashValueDuZooEstCorrecte(gCacheDesPrefetch[k].hashValue)) then
                WritelnDansRapport('ASSERT : hashValue incorecte dans STILL_PREFETCHED, gCacheDesPrefetch[k].hashValue = ' +  UInt64ToHexa(gCacheDesPrefetch[k].hashValue));


              if Same64Bits(gCacheDesPrefetch[k].hashValue , hashCalculCourant) then
                WritelnDansRapport('ASSERT dans STILL_PREFETCHED : hash[k] = HashDuCalculCourantDeCassioPourLeZoo {1}');
            end;

        if not(JobIsEmpty(gZoo.jobPrefetched)) then
          begin
            hashDuPrefetchActuel := UInt64ToHexa(GetHashValueOfPositionPrefetched);

            if (FindStringInLongString(hashDuPrefetchActuel, requete) <= 0) then
              begin
                inc(nbPrefetchedChecked);
                if (nbPrefetchedChecked = 1)
                  then AppendToLongString(requete , '&hash='                                      + hashDuPrefetchActuel)
                  else AppendToLongString(requete , '&h' + NumEnString(nbPrefetchedChecked) + '=' + hashDuPrefetchActuel);
              end;
              
            if not(HashValueDuZooEstCorrecte(GetHashValueOfPositionPrefetched)) then
              begin
                WritelnDansRapport('ASSERT : hashValue incorecte dans STILL_PREFETCHED, GetHashValueOfPositionPrefetched = ' +  UInt64ToHexa(GetHashValueOfPositionPrefetched));
                WriteDansRapport('gZoo.jobPrefetched = ');
                WritelnLongStringDansRapport(gZoo.jobPrefetched);
              end;
                  

            if Same64Bits(GetHashValueOfPositionPrefetched , hashCalculCourant) then
                WritelnDansRapport('ASSERT dans STILL_PREFETCHED : hash = HashDuCalculCourantDeCassioPourLeZoo {2}');
          end;
          
        // WritelnNumDansRapport('nbPrefetchedChecked = ',nbPrefetchedChecked);

        if (nbPrefetchedChecked > 0) then
          EnvoyerUneRequeteAuZoo(requete);

      end;
end;


procedure EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo(const fonctionAppelante : String255);
var requete : LongString;
begin
  Discard(fonctionAppelante);

  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequetePourPrevenirQueCassioSeRetireDuZoo);

  with gZoo do
    begin
    
      (* WritelnDansRapport(fonctionAppelante); *)

      requete := MakeLongString(urlDuZoo + '?action=I_QUIT&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));

      EnvoyerUneRequeteAuZoo(requete);
      
      SetZooStatus('RETIRED');
    end;
end;


procedure EnvoyerUneRequetePourArreterDesCalculsDuZoo(const whichHashes : String255);
var requete : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequetePourArreterDesCalculsDuZoo);

  with gZoo do
    if (whichHashes <> '') then
      begin

        requete := MakeLongString(urlDuZoo + '?action=STOP&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
        AppendToLongString(requete , whichHashes);


        EnvoyerUneRequeteAuZoo(requete);

      end;
end;


procedure EnvoyerUneRequetePourArreterUnCalculDuZoo(whichHash : UInt64);
var requete : LongString;
begin
  with gZoo do
    if HashValueDuZooEstCorrecte(whichHash) then
      begin

        requete := MakeLongString(urlDuZoo + '?action=STOP&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
        AppendToLongString(requete , '&hash=' + UInt64ToHexa(whichHash));


        if (NombreDeResultatsEnAttenteSurLeZoo > 0)
          then
            begin
              requete := MakeLongString(urlDuZoo + '?action=STOP_AND_GET_RESULTS&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
              AppendToLongString(requete , '&hash=' + UInt64ToHexa(whichHash));
              AppendToLongString(requete , '&date=' + GetLastTimestampOfResultSurLeZoo);

              SetDateDerniereEcouteDeResultatsDuZoo(tickCount);
            end
          else
            begin
              requete := MakeLongString(urlDuZoo + '?action=STOP&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
              AppendToLongString(requete , '&hash=' + UInt64ToHexa(whichHash));
            end;

        EnvoyerUneRequeteAuZoo(requete);

      end;
end;


procedure EnvoyerUneRequetePourPrendreMoiMemeUnCalculDuZoo(const whichHashes : String255);
var requete : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUneRequetePourPrendreMoiMemeUnCalculDuZoo);

  with gZoo do
    if (whichHashes <> '') then
      begin

        if (NombreDeResultatsEnAttenteSurLeZoo > 0)
          then
            begin
              requete := MakeLongString(urlDuZoo + '?action=ASKER_TAKES_IT_AND_GET_RESULTS&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
              AppendToLongString(requete , whichHashes);
              AppendToLongString(requete , '&date=' + GetLastTimestampOfResultSurLeZoo);

              SetDateDerniereEcouteDeResultatsDuZoo(tickCount);
            end
          else
            begin
              requete := MakeLongString(urlDuZoo + '?action=ASKER_TAKES_IT&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
              AppendToLongString(requete , whichHashes);
            end;


        EnvoyerUneRequeteAuZoo(requete);

      end;
end;


procedure EnvoyerUneRequetePourArreterTousMesCalculsDuZoo;
var requete, derniereRequete : LongString;
begin
  with gZoo do
    begin

      requete := MakeLongString(urlDuZoo + '?action=STOP_ALL&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));

      derniereRequete := GetDerniereRequeteEnvoyeeAuZoo;
      if (GetZooStatus = 'RETIRED') &
         (GetLastEtatDuReseauAffiche = 'RETIRED') &
         ((TickCount - GetDateDerniereRequeteSurReseau) <= 200) &
         SameLongString(derniereRequete, requete) then
        exit(EnvoyerUneRequetePourArreterTousMesCalculsDuZoo);
        
      (*
      WritelnDansRapport('GetZooStatus = ' + GetZooStatus);
      WritelnDansRapport('GetLastEtatDuReseauAffiche = ' + GetLastEtatDuReseauAffiche);
      WriteDansRapport('derniereRequete = ');
      WritelnLongStringDansRapport(derniereRequete);
      *)

      EnvoyerUneRequeteAuZoo(requete);

    end;
end;


procedure DetruireLeZoo;
//var requete : LongString;
begin
  with gZoo do
    begin

     // requete := MakeLongString(urlDuZoo + '?action=DELETE_ALL&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
     // EnvoyerUneRequeteAuZoo(requete);

    end;
end;





function DoitInterrompreCalculPourLeZoo(const s : LongString) : boolean;
var action1,action2,bool,hash,reste : String255;
    hashValue : UInt64;
begin

  { exemple de ligne à parser (attention, il y a hash= dans la chaine...) :
    STILL INCHARGE false hash=2f77e7ee0fc90f8d
    ou bien
    STILL INCHARGE false
  }

  if CassioEstEnTrainDeCalculerPourLeZoo then
    begin

      Parser4(s.debutLigne, action1, action2, bool, hash, reste);

      // le hash

      hash := TPCopy(hash,6,255);
      hashValue := HexToUInt64(hash);

      {
      WritelnNumDansRapport('hashValue = ',hashValue);
      WritelnNumDansRapport('gZoo.rechercheEnCours.inHashValue = ',gZoo.rechercheEnCours.inHashValue);
      }

      if (action1 = 'STILL') &
         (action2 = 'INCHARGE') &
         (bool = 'false') &
         Same64Bits(hashValue , HashDuCalculCourantDeCassioPourLeZoo) &
         not(CassioEstEnTrainDeDebuguerLeZooEnLocal) then
        begin
          gZoo.positionChercheeADisparuDuZoo := true;
          RetirerCeJobDuCacheDesPositionsPrefetchUtiles(hashValue);
          LanceInterruption(interruptionPositionADisparuDuZoo,'InterrompreCalculPourLeZoo');
          DoitInterrompreCalculPourLeZoo := true;
          exit(DoitInterrompreCalculPourLeZoo);
        end;
      
      if (action1 = 'STILL') &
         (action2 = 'INCHARGE') &
         (bool = 'false') &
         (hash = '') then
         begin
           // something got strange here...
           gZoo.dateDerniereVerificationUtiliteCalculPourLeZoo := TickCount - gZoo.intervalleVerificationUtiliteCalculPourLeZoo - 10;
           VerifierUtiliteCalculPourLeZoo(true);
         end;

    end;

  DoitInterrompreCalculPourLeZoo := false;
end;


procedure EnvoyerUnPingSiNecessaire;
var requete : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUnPingSiNecessaire);

  with gZoo do
    begin
      if (nbreDePingsSurLeZoo <= 10) then
        begin
          MicroSeconds(timerPourPing);

          requete := MakeLongString(urlDuZoo + '?action=PING&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));

          gZoo.dateDernierEnvoiDePingSurLeZoo := TickCount;

          EnvoyerUneRequeteAuZoo(requete);
          
        end;
    end;
end;








procedure EnvoyerUnKeepAliveSiNecessaire;
var requete : LongString;
    status : String255;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EnvoyerUnKeepAliveSiNecessaire);

  with gZoo do
    begin
      if (TickCount > dateDernierEnvoiDeKeepAliveSurLeZoo + intervalleEnvoiDeKeepAliveSurLeZoo) then
        begin
        
          status := CalculateZooStatusPourCetEtatDeCassio;

          requete := MakeLongString(urlDuZoo + '?action=KEEP_ALIVE' 
                                             + '&asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio)
                                             + '&status=' + status);

          gZoo.dateDernierEnvoiDeKeepAliveSurLeZoo := TickCount;

          EnvoyerUneRequeteAuZoo(requete);
          
          SetZooStatus(status);
          
          if (status = 'RETIRED') & (GetLastEtatDuReseauAffiche = 'NO JOB !')
            then AfficheEtatDuReseau(status);
         
        end;
    end;
end;



procedure VerifierUtiliteCalculPourLeZoo(alsoCheckPretch : boolean);
var requete : LongString;
    urlParams, shortUrlParams : String255;
   // s : String255;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(VerifierUtiliteCalculPourLeZoo);
  
  // s := 'Appel de VerifierUtiliteCalculPourLeZoo : done = NO';

  if CassioEstEnTrainDeCalculerPourLeZoo then
    with gZoo do
      begin
        if ((TickCount - dateDerniereVerificationUtiliteCalculPourLeZoo) >= intervalleVerificationUtiliteCalculPourLeZoo) &
           CheckEndgameSearchParams(rechercheEnCours.params) & not(positionChercheeADisparuDuZoo) &
           (interruptionReflexion = pasdinterruption) & (ProfDuCalculCourantDeCassioPourLeZoo > 0) then

          begin

            {WritelnDansRapport('looking if the position is still in the grid…');}
            
            // s := 'Appel de VerifierUtiliteCalculPourLeZoo : done = YES';

            urlParams := '';
            EncoderSearchParamsPourURL(rechercheEnCours.params, urlParams, 'VerifierUtiliteCalculPourLeZoo');
            shortUrlParams := 'hash=' + UInt64ToHexa(rechercheEnCours.params.inHashValue) + '&asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio);

            (* if (NombreDeResultatsEnAttenteSurLeZoo > 0)
              then
                begin
                  requete := MakeLongString(urlDuZoo + '?action=STILL_INCHARGE_AND_GET_RESULTS&' + shortUrlParams + '&date=' + GetLastTimestampOfResultSurLeZoo);
                  dateDerniereVerificationUtiliteCalculPourLeZoo := TickCount;
                  dateDerniereEcouteDeResultatsSurLeZoo := TickCount;
                end
              else *)
                begin
                  requete := MakeLongString(urlDuZoo + '?action=STILL_INCHARGE&' + shortUrlParams);
                  dateDerniereVerificationUtiliteCalculPourLeZoo := TickCount;
                end;
                
            
            if (NumberOfPrefetch >= 30) then
              AppendToLongString(requete, '&prefetch=NO');
                
            // WritelnLongStringDansRapport(requete);
            
            EnvoyerUneRequeteAuZoo(requete);

            if alsoCheckPretch 
              then EnvoyerUneRequetePourVerifierLeCacheDesPrefetch
              else VerifierLocalementLaFileDesPrefetchs;

          end;
      end;
  
  // WritelnDansRapport(s);
end;




procedure EcouterLesResultatsDuZoo;
var requete : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(EcouterLesResultatsDuZoo);

  if (NombreDeResultatsEnAttenteSurLeZoo > 0) then
     with gZoo do
       if ((TickCount - dateDerniereEcouteDeResultatsSurLeZoo) >= intervalleEcouteDeResultatsSurLeZoo) then
         begin

           requete := MakeLongString(urlDuZoo + '?action=GET_RESULTS&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio) + '&date=' + GetLastTimestampOfResultSurLeZoo);

           EnvoyerUneRequeteAuZoo(requete);

           dateDerniereEcouteDeResultatsSurLeZoo := TickCount;
         end;
end;


function DemandeDeCalculPourLeZooDansLaFileLocale(var job : LongString) : boolean;
begin
  DemandeDeCalculPourLeZooDansLaFileLocale := false;

  if not(JobIsEmpty(gZoo.jobEnCoursDeTraitement)) then
    begin
      DemandeDeCalculPourLeZooDansLaFileLocale := true;
      job := gZoo.jobEnCoursDeTraitement;
    end;
end;


procedure TransfererPositionPrefetchedDuZooDansLaFileLocale;
var s,s2 : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(TransfererPositionPrefetchedDuZooDansLaFileLocale);

  if JobIsEmpty(gZoo.jobEnCoursDeTraitement) &
     not(JobIsEmpty(gZoo.jobPrefetched))
    then
      begin
        {WritelnDansRapport('transfert (1) : '+gZoo.jobPrefetched);}

        gZoo.jobEnCoursDeTraitement := gZoo.jobPrefetched;
        gZoo.jobPrefetched          := GetPrefetchImportantPasEncoreCalcule;

        {WritelnDansRapport('apres transfert : '+gZoo.jobPrefetched);}

        exit(TransfererPositionPrefetchedDuZooDansLaFileLocale);
      end;

  if JobIsEmpty(gZoo.jobEnCoursDeTraitement) &
     JobIsEmpty(gZoo.jobPrefetched)
    then
      begin
        s  := GetPrefetchImportantPasEncoreCalcule;
        s2 := GetPrefetchImportantPasEncoreCalcule;

        if not(JobIsEmpty(s)) then
          begin
            {WritelnDansRapport('transfert (2) : '+gZoo.jobPrefetched);}

            if not(SameJobs(s , s2))
              then
                begin
                  gZoo.jobEnCoursDeTraitement := s;
                  gZoo.jobPrefetched          := s2;
                end
              else
                begin
                  gZoo.jobEnCoursDeTraitement := s;
                  InitLongString(gZoo.jobPrefetched);
                end;

            {WritelnDansRapport('apres transfert : '+gZoo.jobPrefetched);}

            exit(TransfererPositionPrefetchedDuZooDansLaFileLocale);
          end;
      end;
end;



procedure DemanderUnJobAuZoo;
var requete : LongString;
    job : LongString;
begin
  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(DemanderUnJobAuZoo);

  with gZoo do
    if ((TickCount - dateDernierReleveDeJobSurLeZoo) >= intervalleReleveDeJobSurLeZoo) then
      begin

        (*
        WritelnStringAndBooleenDansRapport('CassioEstEnTrainDeCalculerPourLeZoo = ',CassioEstEnTrainDeCalculerPourLeZoo);
        WritelnStringAndBooleenDansRapport('CassioPeutDonnerDuTempsAuZoo = ',CassioPeutDonnerDuTempsAuZoo);
        WritelnStringAndBooleenDansRapport('DemandeDeCalculPourLeZooDansLaFileLocale = ',DemandeDeCalculPourLeZooDansLaFileLocale(job));
        *)

        if not(CassioEstEnTrainDeCalculerPourLeZoo) &
           CassioPeutDonnerDuTempsAuZoo &
           not(DemandeDeCalculPourLeZooDansLaFileLocale(job)) then
             begin
                {WritelnDansRapport('looking for jobs on the grid…');}

                (* if (NombreDeResultatsEnAttenteSurLeZoo > 0)
                  then
                    begin
                      requete := MakeLongString(urlDuZoo + '?action=GET_WORK_AND_GET_RESULTS&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio) + '&date=' + GetLastTimestampOfResultSurLeZoo);
                      dateDerniereEcouteDeResultatsSurLeZoo := TickCount;
                      dateDernierReleveDeJobSurLeZoo := TickCount;
                    end
                  else *)
                    begin
                      requete := MakeLongString(urlDuZoo + '?action=GET_WORK&' + 'asker=' + NumEnString(gIdentificateurUniqueDeCetteSessionDeCassio));
                      dateDernierReleveDeJobSurLeZoo := TickCount;
                    end;

                EnvoyerUneRequeteAuZoo(requete);

                {EnvoyerUnPingSiNecessaire;}
             end;
      end;
end;



procedure BoucleDeLancementsDesCalculsLocauxPourLeZoo;
var job : LongString;
    err : OSStatus;
begin

  if not(CassioDoitRentrerEnContactAvecLeZoo) then exit(BoucleDeLancementsDesCalculsLocauxPourLeZoo);

  while not(CassioEstEnTrainDeCalculerPourLeZoo) &
        CassioPeutDonnerDuTempsAuZoo &
        DemandeDeCalculPourLeZooDansLaFileLocale(job) &
        not(Quitter) do
    with gZoo do
     begin
                       
       if PeutParserDemandeDeJob(job, rechercheEnCours.params)
         then
           begin
             EndgameSearchParamToZooJob(rechercheEnCours.params, rechercheEnCours);
             err := LancerCalculCommeClientPourLeZoo(rechercheEnCours);
           end
         else
           begin
             ZooPrintWarning('ASSERT  !! Dans BoucleDeLancementsDesCalculsLocauxPourLeZoo, Cassio n''arrive pas à parser le job envoyé par le serveur');
           end;

       InitLongString(gZoo.jobEnCoursDeTraitement);

       TransfererPositionPrefetchedDuZooDansLaFileLocale;
       
       
       if (interruptionReflexion = interruptionPositionADisparuDuZoo) then
         begin
           EnleveCetteInterruption(interruptionPositionADisparuDuZoo);
           if not(CassioEstEnTrainDeCalculerPourLeZoo) &
              CassioPeutDonnerDuTempsAuZoo &
              DemandeDeCalculPourLeZooDansLaFileLocale(job) &
              not(Quitter)
            then
              begin
                WritelnDansRapport('DOMMAGE ! On pourrait enchainer sans quitter...');
              end;
           LanceInterruption(interruptionPositionADisparuDuZoo,'test dans BoucleDeLancementsDesCalculsLocauxPourLeZoo');
         end;
       
       
       
       
       
     end;
   
end;





{ cette fonction est appelee regulierement depuis la boucle principale de Cassio }
procedure GererLeZoo;
begin

  if CassioDoitRentrerEnContactAvecLeZoo then
    begin
      TransfererPositionPrefetchedDuZooDansLaFileLocale;
      VerifierLeStatutDeCassioPourLeZoo;
      DemanderUnJobAuZoo;
      BoucleDeLancementsDesCalculsLocauxPourLeZoo;
      VerifierLeStatutDeCassioPourLeZoo;
      DemanderUnJobAuZoo;
      EcouterLesResultatsDuZoo;
      VerifierUtiliteCalculPourLeZoo(true);
      VerifierLePoussageDesRequetesAuZoo;
      EnvoyerUnKeepAliveSiNecessaire;
    end;


end;





END.





