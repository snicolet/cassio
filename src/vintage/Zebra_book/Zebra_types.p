UNIT Zebra_types;


INTERFACE

USES MacTypes;

CONST

(* Flags pour interpreter les valeurs de la bibliotheque de zebra *)
    NONE                  =    -1 ;
    NO_MOVE               =    -1 ;
    POSITION_EXHAUSTED    =    -2 ;
    NO_SCORE              =    9999 ;
    CONFIRMED_WIN         =    30000 ;
    UNWANTED_DRAW         =    (CONFIRMED_WIN - 1) ;
    INFINITE_WIN          =    32000 ;
    INFINITE_SPREAD       =    (1000 * 128) ;

(* Flag bits and shifts*)
    NULL_MOVE             =    0 ;
    BLACK_TO_MOVE         =    1 ;
    WHITE_TO_MOVE         =    2 ;
    WLD_SOLVED            =    4 ;
    NOT_TRAVERSED         =    8 ;
    FULL_SOLVED           =    16 ;

(* Flags pour selectionner les options d'affichage *)
    kUtiliserZebraBook                    = 1;
    kAfficherNotesZebraSurOthellier       = 2;
    kAfficherCouleursZebraSurOthellier    = 4;
    kAfficherNotesZebraDansArbre          = 8;
    kAfficherCouleursZebraDansArbre       = 16;
    kAfficherNotesZebraDansReflexion      = 32;
    kAfficherCouleurZebraDansReflexion    = 64;
    kAfficherNotesZebraDansFenetreZebra   = 128;
    kAfficherCouleurZebraDansFenetreZebra = 256;
    kAfficherZebraBookBrutDeDecoffrage    = 512;
    kAllZebraOptions                      = $7FFFFFFF;


CONST

      (* constantes utilisées dans UnitNotesSurCases.p *)
      kNotesDeCassio        = 1;
      kNotesDeZebra         = 2;
      kNotesDeCassioEtZebra = 255;

      kFlagPositionEstSansDouteNonNulleSelonBiblZebra = 1;

      (* Attention, il est critique que les quatre constantes
         ci-dessous soient des multiples de 100 *)
      kNoteSurCaseNonDisponible     = -10000000;
      kNoteSpecialeSurCasePourPerte = -2000000;
      kNoteSpecialeSurCasePourNulle =  0;
      kNoteSpecialeSurCasePourGain  =  2000000;




TYPE

(* Type de données d'un enregistrement du fichier Zebra-book.data de Manu Lazard.
   Attention : bien penser à changer aussi la définition en C de la structure BookNode
               dans Zebra_Book.h si le format change !
 *)
   ZebraBookNode = packed array[0..17] of UInt8;


 (* Attention : le type de donnee ci-dessous fait 20 octets dans CodeWarrior !! Il ne
                faut donc pas l'utiliser dans un array of ZebraBookNodeRecord...
 *)
   ZebraBookNodeRecord = packed record
                                  hash1                 : SInt32;
                                  hash2                 : SInt32;
                                  black_minimax_score   : SInt16;
                                  white_minimax_score   : SInt16;
                                  best_alternative_move : SInt16;
                                  alternative_score     : SInt16;
                                  flags                 : UInt16;   {total = devrait etre 18 octets}
                                end;


VAR
    gDemandeAffichageZebraBook : record
                                   enAttente : boolean;
                                 end;

IMPLEMENTATION


END.