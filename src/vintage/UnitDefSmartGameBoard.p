UNIT UnitDefSmartGameBoard;


INTERFACE







USES UnitDefFichierAbstrait,UnitDefPositionEtTrait,UnitDefGameTree;


var LectureSmartGameBoard :
      record
        compteurCaracteres             : SInt32;
        dernierCaractereLu             : char;
        avantDernierCaractereLu        : char;
        theFile                        : FichierAbstrait;
        EmboitementParentheses         : SInt32;
        profondeur                     : SInt32;
        ProprietesDeLaRacinesDejaLues  : boolean;
        enCours                        : boolean;
        reportErrors                   : boolean;
        QuitterLecture                 : boolean;
        thePosition                    : PositionEtTraitRec;
        buffer                         : packed array[0..4095] of char;
        premierOctetDansBuffer         : SInt32;
        dernierOctetDansBuffer         : SInt32;
      end;

  EcritureSmartGameBoard :
    record
      theFile                          : FichierAbstrait;
      QuitterEcriture                  : boolean;
      DernierCaractereEcrit            : char;
      compteurCaracteres               : SInt32;
      EmboitementParentheses           : SInt32;
      profondeur                       : SInt32;
      ProprietesDeLaRacinesDejaEcrites : boolean;
      AvecPrettyPrinter                : boolean;
      CompteurDeCoupsNoirsEcrits       : SInt32;
      typesDePropertyAEcrire           : SetOfPropertyTypes;
    end;


procedure InitUnitDefinitionsSmartGameBoard;
procedure LibereMemoireUnitDefinitionsSmartGameBoard;


function PendantLectureFormatSmartGameBoard : boolean;
function PendantEcritureFormatSmartGameBoard : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitFichierAbstrait ;
{$ELSEC}
    {$I prelink/DefSmartGameBoard.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure InitUnitDefinitionsSmartGameBoard;
begin
  LectureSmartGameBoard.compteurCaracteres := 0;
  EcritureSmartGameBoard.compteurCaracteres := 0;
end;

procedure LibereMemoireUnitDefinitionsSmartGameBoard;
begin
end;

function PendantLectureFormatSmartGameBoard : boolean;
begin
  PendantLectureFormatSmartGameBoard := (LectureSmartGameBoard.compteurCaracteres > 0);
end;

function PendantEcritureFormatSmartGameBoard : boolean;
begin
  PendantEcritureFormatSmartGameBoard := (EcritureSmartGameBoard.compteurCaracteres > 0);
end;



END.
