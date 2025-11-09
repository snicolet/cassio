UNIT EdmondEvaluation;



INTERFACE

 USES UnitDefCassio;





{ Initialisation de l'unite }
procedure InitUnitEdmond;
procedure LibereMemoireUnitEdmond;


{ La fonction d'evaluation ! }
function EvaluationEdmond(var position : plateauOthello; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32) : SInt32;
function EvaluationMixteCassioEdmond(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoirs,nbBlancs,trait : SInt32; var whichEval : VectNewEvalInteger; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; alpha,beta : SInt32) : SInt32;


{ Disponibilite de l'eval pour le reste du programme ? }
procedure SetEvaluationEdmondEstDisponible(flag : boolean);
function EvaluationEdmondEstDisponible : boolean;


{ Gestion de la memoire pour l'eval d'Edmond }
procedure AnnihilePointersPourEvalEdmondDansCassio;               { initialisation à NIL des tables }
function AllocatePointersPourEvalEdmondDansCassio : OSErr;        { allocation des tables }
function TousLesPointeursDeLEvalEdmondSontBons : boolean;         { verification de la validite des pointeurs }
procedure DeallocatePointersPourEvalEdmondDansCassio;             { liberation des tables }


{ Fonctions diverses de manipulation des patterns }
function TailleDUnPatternDeTantDeCases(nbreCases : SInt32) : SInt32;
function AllocatePointerPourUnPatternDeTantDeCases(nbreCases : SInt32) : IntegerArrayPtr;
function PointeurVersLeMilieuDUnPatternDeTantDeCases(nbreCases : SInt32; patternArray : IntegerArrayPtr) : IntegerArrayPtr;


{ Fonctions de lecture/ecriture sur le disque du fichier d'eval }
function LireFichierEvalEdmondSurLeDisque : OSErr;
function EcrireFichierEvalEdmondSurLeDisque : OSErr;
function LectureEdmondEvalInterrompueParEvenement : boolean;
function LireUnTableauEvalEdmondSurLeDisque(var fic : basicfile; tableau : IntegerArrayPtr; tailleDuPattern : SInt32) : OSErr;
function EcrireUnTableauEvalEdmondSurLeDisque(var fic : basicfile; tableau : IntegerArrayPtr; tailleDuPattern : SInt32) : OSErr;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesMemoire, UnitNouvelleEval, ImportEdmond, UnitEvaluation, UnitEvenement, UnitGestionDuTemps
    , EdmondPatterns, SNEvents, basicfile, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/EdmondEvaluation.lk}
{$ENDC}


{END_USE_CLAUSE}









const kErrorCassioVeutQuitterEnCatastrophe = 12345;

var gMemoireUtiliseeParEvalEdmondDansCassio : SInt32;
    gEvalEdmondEstDisponible : boolean;
    dernierTickAppelHasGotEvent : SInt32;
    nbreAppelsHasGotEventsPendantLectureEvalEdmond : SInt32;


procedure InitUnitEdmond;
begin
  AnnihilePointersPourEvalEdmondDansCassio;
  SetEvaluationEdmondEstDisponible(false);
  nbreAppelsHasGotEventsPendantLectureEvalEdmond := 0;
  dernierTickAppelHasGotEvent := 0;
end;


procedure LibereMemoireUnitEdmond;
begin
  edmond_release_coefficients;
  DeallocatePointersPourEvalEdmondDansCassio;
  SetEvaluationEdmondEstDisponible(false);
end;


procedure SetEvaluationEdmondEstDisponible(flag : boolean);
begin
  gEvalEdmondEstDisponible := flag;
end;

function EvaluationEdmondEstDisponible : boolean;
begin
  EvaluationEdmondEstDisponible := gEvalEdmondEstDisponible;
end;


function TailleDUnPatternDeTantDeCases(nbreCases : SInt32) : SInt32;
begin
  TailleDUnPatternDeTantDeCases := puiss3[nbreCases + 1];
end;


function AllocatePointerPourUnPatternDeTantDeCases(nbreCases : SInt32) : IntegerArrayPtr;
var tailleEnOctets : SInt32;
begin
  tailleEnOctets := sizeof(SInt16)*TailleDUnPatternDeTantDeCases(nbreCases);
  gMemoireUtiliseeParEvalEdmondDansCassio := gMemoireUtiliseeParEvalEdmondDansCassio + tailleEnOctets;
  AllocatePointerPourUnPatternDeTantDeCases := IntegerArrayPtr(AllocateMemoryPtr(tailleEnOctets));
end;


function PointeurVersLeMilieuDUnPatternDeTantDeCases(nbreCases : SInt32; patternArray : IntegerArrayPtr) : IntegerArrayPtr;
var tailleDuPattern : SInt32;
    indexElementMilieu : SInt32;
begin
  tailleDuPattern := TailleDUnPatternDeTantDeCases(nbreCases);
  indexElementMilieu := (tailleDuPattern - 1) div 2;

  if (patternArray <> NIL)
    then PointeurVersLeMilieuDUnPatternDeTantDeCases := @patternArray^[indexElementMilieu]
    else PointeurVersLeMilieuDUnPatternDeTantDeCases := NIL;
end;


procedure AnnihilePointersPourEvalEdmondDansCassio;
var i : SInt32;
begin
  for i := 0 to 64 do
    begin
      Edmond_DIAG_5_stub[i]     := NIL;
      Edmond_DIAG_6_stub[i]     := NIL;
      Edmond_DIAG_7_stub[i]     := NIL;
      Edmond_DIAG_8_stub[i]     := NIL;
      Edmond_HV_4_stub[i]       := NIL;
      Edmond_HV_3_stub[i]       := NIL;
      Edmond_HV_2_stub[i]       := NIL;
      Edmond_EDGE_6_4_stub[i]   := NIL;
      Edmond_CORNER_2x5_stub[i] := NIL;
      Edmond_CORNER_11_stub[i]  := NIL;
      Edmond_EDGE_2XC_stub[i]   := NIL;

      Edmond_DIAG_5[i]     := NIL;
      Edmond_DIAG_6[i]     := NIL;
      Edmond_DIAG_7[i]     := NIL;
      Edmond_DIAG_8[i]     := NIL;
      Edmond_HV_4[i]       := NIL;
      Edmond_HV_3[i]       := NIL;
      Edmond_HV_2[i]       := NIL;
      Edmond_EDGE_6_4[i]   := NIL;
      Edmond_CORNER_2x5[i] := NIL;
      Edmond_CORNER_11[i]  := NIL;
      Edmond_EDGE_2XC[i]   := NIL;
    end;

  gMemoireUtiliseeParEvalEdmondDansCassio := 0;
end;


function TousLesPointeursDeLEvalEdmondSontBons : boolean;       { verification de la validite des pointeurs }
var i : SInt32;
begin
  TousLesPointeursDeLEvalEdmondSontBons := true;

  for i := 0 to 63 do
    if ( Edmond_DIAG_5_stub[i] = NIL)      or
       ( Edmond_DIAG_6_stub[i] = NIL )     or
       ( Edmond_DIAG_7_stub[i] = NIL )     or
       ( Edmond_DIAG_8_stub[i] = NIL )     or
       ( Edmond_HV_4_stub[i] = NIL )       or
       ( Edmond_HV_3_stub[i] = NIL )       or
       ( Edmond_HV_2_stub[i] = NIL )       or
       ( Edmond_EDGE_6_4_stub[i] = NIL )   or
       ( Edmond_CORNER_2x5_stub[i] = NIL ) or
       ( Edmond_CORNER_11_stub[i] = NIL )  or
       ( Edmond_EDGE_2XC_stub[i] = NIL )
         then
           begin
             TousLesPointeursDeLEvalEdmondSontBons := false;
             exit;
           end;
end;


function AllocatePointersPourEvalEdmondDansCassio : OSErr;
var i : SInt32;
begin

  for i := Edmond_stage_MIN to Edmond_stage_MAX do
    begin
      Edmond_DIAG_5_stub[i]     := AllocatePointerPourUnPatternDeTantDeCases(5);
      Edmond_DIAG_6_stub[i]     := AllocatePointerPourUnPatternDeTantDeCases(6);
      Edmond_DIAG_7_stub[i]     := AllocatePointerPourUnPatternDeTantDeCases(7);
      Edmond_DIAG_8_stub[i]     := AllocatePointerPourUnPatternDeTantDeCases(8);
      Edmond_HV_4_stub[i]       := AllocatePointerPourUnPatternDeTantDeCases(8);
      Edmond_HV_3_stub[i]       := AllocatePointerPourUnPatternDeTantDeCases(8);
      Edmond_HV_2_stub[i]       := AllocatePointerPourUnPatternDeTantDeCases(8);
      Edmond_EDGE_6_4_stub[i]   := AllocatePointerPourUnPatternDeTantDeCases(10);
      Edmond_CORNER_2x5_stub[i] := AllocatePointerPourUnPatternDeTantDeCases(10);
      Edmond_CORNER_11_stub[i]  := AllocatePointerPourUnPatternDeTantDeCases(11);
      Edmond_EDGE_2XC_stub[i]   := AllocatePointerPourUnPatternDeTantDeCases(12);
    end;


  for i := 0 to Edmond_stage_MIN - 1 do
    begin
      Edmond_DIAG_5_stub[i]     := Edmond_DIAG_5_stub[Edmond_stage_MIN];
      Edmond_DIAG_6_stub[i]     := Edmond_DIAG_6_stub[Edmond_stage_MIN];
      Edmond_DIAG_7_stub[i]     := Edmond_DIAG_7_stub[Edmond_stage_MIN];
      Edmond_DIAG_8_stub[i]     := Edmond_DIAG_8_stub[Edmond_stage_MIN];
      Edmond_HV_4_stub[i]       := Edmond_HV_4_stub[Edmond_stage_MIN];
      Edmond_HV_3_stub[i]       := Edmond_HV_3_stub[Edmond_stage_MIN];
      Edmond_HV_2_stub[i]       := Edmond_HV_2_stub[Edmond_stage_MIN];
      Edmond_EDGE_6_4_stub[i]   := Edmond_EDGE_6_4_stub[Edmond_stage_MIN];
      Edmond_CORNER_2x5_stub[i] := Edmond_CORNER_2x5_stub[Edmond_stage_MIN];
      Edmond_CORNER_11_stub[i]  := Edmond_CORNER_11_stub[Edmond_stage_MIN];
      Edmond_EDGE_2XC_stub[i]   := Edmond_EDGE_2XC_stub[Edmond_stage_MIN];
    end;

  for i := Edmond_stage_MAX + 1 to 64 do
    begin
      Edmond_DIAG_5_stub[i]     := Edmond_DIAG_5_stub[Edmond_stage_MAX];
      Edmond_DIAG_6_stub[i]     := Edmond_DIAG_6_stub[Edmond_stage_MAX];
      Edmond_DIAG_7_stub[i]     := Edmond_DIAG_7_stub[Edmond_stage_MAX];
      Edmond_DIAG_8_stub[i]     := Edmond_DIAG_8_stub[Edmond_stage_MAX];
      Edmond_HV_4_stub[i]       := Edmond_HV_4_stub[Edmond_stage_MAX];
      Edmond_HV_3_stub[i]       := Edmond_HV_3_stub[Edmond_stage_MAX];
      Edmond_HV_2_stub[i]       := Edmond_HV_2_stub[Edmond_stage_MAX];
      Edmond_EDGE_6_4_stub[i]   := Edmond_EDGE_6_4_stub[Edmond_stage_MAX];
      Edmond_CORNER_2x5_stub[i] := Edmond_CORNER_2x5_stub[Edmond_stage_MAX];
      Edmond_CORNER_11_stub[i]  := Edmond_CORNER_11_stub[Edmond_stage_MAX];
      Edmond_EDGE_2XC_stub[i]   := Edmond_EDGE_2XC_stub[Edmond_stage_MAX];
    end;


  // verification : si l'un des pointeurs vaut NIL, on a un probleme et il faut sortir

  if not(TousLesPointeursDeLEvalEdmondSontBons) then
    begin
      WritelnDansRapport('ERREUR : je n''ai pas pu allouer les pointeurs de l''eval d''Edmond...');
      WritelnDansRapport('');

      AllocatePointersPourEvalEdmondDansCassio := -1;
      exit;
    end;

  // Tout a l'air bon

  AllocatePointersPourEvalEdmondDansCassio := NoErr;


  // on pointe sur l'élément du milieu du tableau
  for i := 0 to 63 do
    begin
      Edmond_DIAG_5[i]     := PointeurVersLeMilieuDUnPatternDeTantDeCases(5,Edmond_DIAG_5_stub[i]);
      Edmond_DIAG_6[i]     := PointeurVersLeMilieuDUnPatternDeTantDeCases(6,Edmond_DIAG_6_stub[i]);
      Edmond_DIAG_7[i]     := PointeurVersLeMilieuDUnPatternDeTantDeCases(7,Edmond_DIAG_7_stub[i]);
      Edmond_DIAG_8[i]     := PointeurVersLeMilieuDUnPatternDeTantDeCases(8,Edmond_DIAG_8_stub[i]);
      Edmond_HV_4[i]       := PointeurVersLeMilieuDUnPatternDeTantDeCases(8,Edmond_HV_4_stub[i]);
      Edmond_HV_3[i]       := PointeurVersLeMilieuDUnPatternDeTantDeCases(8,Edmond_HV_3_stub[i]);
      Edmond_HV_2[i]       := PointeurVersLeMilieuDUnPatternDeTantDeCases(8,Edmond_HV_2_stub[i]);
      Edmond_EDGE_6_4[i]   := PointeurVersLeMilieuDUnPatternDeTantDeCases(10,Edmond_EDGE_6_4_stub[i]);
      Edmond_CORNER_2x5[i] := PointeurVersLeMilieuDUnPatternDeTantDeCases(10,Edmond_CORNER_2x5_stub[i]);
      Edmond_CORNER_11[i]  := PointeurVersLeMilieuDUnPatternDeTantDeCases(11,Edmond_CORNER_11_stub[i]);
      Edmond_EDGE_2XC[i]   := PointeurVersLeMilieuDUnPatternDeTantDeCases(12,Edmond_EDGE_2XC_stub[i]);
    end;

  {WritelnNumDansRapport('gMemoireUtiliseeParEvalEdmondDansCassio = ',gMemoireUtiliseeParEvalEdmondDansCassio);}
end;


procedure DeallocatePointersPourEvalEdmondDansCassio;
var i : SInt32;
begin

  for i := Edmond_stage_MIN to Edmond_stage_MAX do
    begin
      if (Edmond_DIAG_5_stub[i] <> NIL)     then DisposeMemoryPtr(Ptr(Edmond_DIAG_5_stub[i]));
      if (Edmond_DIAG_6_stub[i] <> NIL)     then DisposeMemoryPtr(Ptr(Edmond_DIAG_6_stub[i]));
      if (Edmond_DIAG_7_stub[i] <> NIL)     then DisposeMemoryPtr(Ptr(Edmond_DIAG_7_stub[i]));
      if (Edmond_DIAG_8_stub[i] <> NIL)     then DisposeMemoryPtr(Ptr(Edmond_DIAG_8_stub[i]));
      if (Edmond_HV_4_stub[i] <> NIL)       then DisposeMemoryPtr(Ptr(Edmond_HV_4_stub[i]));
      if (Edmond_HV_3_stub[i] <> NIL)       then DisposeMemoryPtr(Ptr(Edmond_HV_3_stub[i]));
      if (Edmond_HV_2_stub[i] <> NIL)       then DisposeMemoryPtr(Ptr(Edmond_HV_2_stub[i]));
      if (Edmond_EDGE_6_4_stub[i] <> NIL)   then DisposeMemoryPtr(Ptr(Edmond_EDGE_6_4_stub[i]));
      if (Edmond_CORNER_2x5_stub[i] <> NIL) then DisposeMemoryPtr(Ptr(Edmond_CORNER_2x5_stub[i]));
      if (Edmond_CORNER_11_stub[i] <> NIL)  then DisposeMemoryPtr(Ptr(Edmond_CORNER_11_stub[i]));
      if (Edmond_EDGE_2XC_stub[i] <> NIL)   then DisposeMemoryPtr(Ptr(Edmond_EDGE_2XC_stub[i]));
    end;

  AnnihilePointersPourEvalEdmondDansCassio;
end;





function EvaluationEdmond(var position : plateauOthello; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt32) : SInt32;
var theStage : SInt32;
    evalPartielle : SInt32;
    evalTable  : IntegerArrayPtr;
    evalTable2 : IntegerArrayPtr;
    evalDesBords : SInt32;
begin

  theStage := nbNoir + nbBlanc - 4;   // numero du dernier coup joue

  if theStage < 0 then theStage := 0;
  if theStage > 64 then theStage := 64;


  evalPartielle := 0;
  evalDesBords := 0;

  with frontiere do
    begin

      if (trait = pionNoir)
        then
          begin

            // les lignes centrales
            evalTable := Edmond_HV_2[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne2]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne7]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne2]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne7]];

            // les lignes intermediaires ( 3 et 6, col C et F)
            evalTable := Edmond_HV_3[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne3]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne6]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne3]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne6]];

            // les prebords
            evalTable := Edmond_HV_4[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne4]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseColonne5]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne4]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseLigne5]];

            // les coins de 11
            evalTable := Edmond_CORNER_11[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner11A1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner11H1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner11A8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner11H8]];

            // les blocs de coins 2x5
            evalTable := Edmond_CORNER_2x5[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25A1E1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25A1A5]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25H1D1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25H1H5]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25A8A4]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25A8E8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25H8D8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseCorner25H8H4]];

            // les diagonales de 5
            evalTable := Edmond_DIAG_5[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA4E8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleD1H5]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA5E1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleD8H4]];

            // les diagonales de 6
            evalTable := Edmond_DIAG_6[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA3F8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleC1H6]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA6F1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleC8H3]];

            // les diagonales de 7
            evalTable := Edmond_DIAG_7[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA2G8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleB1H7]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA7G1]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleB8H2]];

            // les grandes diagonales
            evalTable := Edmond_DIAG_8[theStage];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA1H8]];
            evalPartielle := evalPartielle + evalTable^[AdressePattern[kAdresseDiagonaleA8H1]];


            // les bords + 2X + 2C  ou les les bords 6+4, suivant que le coin et la case X sont vides ou pas

            evalTable  := Edmond_EDGE_6_4[theStage];
            evalTable2 := Edmond_EDGE_2XC[theStage];


            evalDesBords := 0;

            if (position[11] = pionVide) and (position[22] = pionVide) and (position[18] = pionVide) and (position[27] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[AdressePattern[kAdresseBord6Plus4Nord]]
              else evalDesBords := evalDesBords + evalTable2^[AdressePattern[kAdresseBord2XCNord]];

            if (position[11] = pionVide) and (position[22] = pionVide) and (position[81] = pionVide) and (position[72] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[AdressePattern[kAdresseBord6Plus4Ouest]]
              else evalDesBords := evalDesBords + evalTable2^[AdressePattern[kAdresseBord2XCOuest]];

            if (position[88] = pionVide) and (position[77] = pionVide) and (position[81] = pionVide) and (position[72] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[AdressePattern[kAdresseBord6Plus4Sud]]
              else evalDesBords := evalDesBords + evalTable2^[AdressePattern[kAdresseBord2XCSud]];

            if (position[88] = pionVide) and (position[77] = pionVide) and (position[18] = pionVide) and (position[27] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[AdressePattern[kAdresseBord6Plus4Est]]
              else evalDesBords := evalDesBords + evalTable2^[AdressePattern[kAdresseBord2XCEst]];

            evalPartielle := evalPartielle + evalDesBords;

          end
        else
          begin

          // les lignes centrales
            evalTable := Edmond_HV_2[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne2]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne7]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne2]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne7]];

            // les lignes intermediaires ( 3 et 6, col C et F)
            evalTable := Edmond_HV_3[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne3]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne6]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne3]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne6]];

            // les prebords
            evalTable := Edmond_HV_4[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne4]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseColonne5]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne4]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseLigne5]];

            // les coins de 11
            evalTable := Edmond_CORNER_11[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner11A1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner11H1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner11A8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner11H8]];

            // les blocs de coins 2x5
            evalTable := Edmond_CORNER_2x5[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25A1E1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25A1A5]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25H1D1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25H1H5]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25A8A4]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25A8E8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25H8D8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseCorner25H8H4]];

            // les diagonales de 5
            evalTable := Edmond_DIAG_5[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA4E8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleD1H5]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA5E1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleD8H4]];

            // les diagonales de 6
            evalTable := Edmond_DIAG_6[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA3F8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleC1H6]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA6F1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleC8H3]];

            // les diagonales de 7
            evalTable := Edmond_DIAG_7[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA2G8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleB1H7]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA7G1]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleB8H2]];

            // les grandes diagonales
            evalTable := Edmond_DIAG_8[theStage];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA1H8]];
            evalPartielle := evalPartielle + evalTable^[ -AdressePattern[kAdresseDiagonaleA8H1]];


            // les bords + 2X + 2C  ou les les bords 6+4, suivant que le coin et la case X sont vides ou pas

            evalTable  := Edmond_EDGE_6_4[theStage];
            evalTable2 := Edmond_EDGE_2XC[theStage];


            evalDesBords := 0;

            if (position[11] = pionVide) and (position[22] = pionVide) and (position[18] = pionVide) and (position[27] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[ -AdressePattern[kAdresseBord6Plus4Nord]]
              else evalDesBords := evalDesBords + evalTable2^[ -AdressePattern[kAdresseBord2XCNord]];

            if (position[11] = pionVide) and (position[22] = pionVide) and (position[81] = pionVide) and (position[72] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[ -AdressePattern[kAdresseBord6Plus4Ouest]]
              else evalDesBords := evalDesBords + evalTable2^[ -AdressePattern[kAdresseBord2XCOuest]];

            if (position[88] = pionVide) and (position[77] = pionVide) and (position[81] = pionVide) and (position[72] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[ -AdressePattern[kAdresseBord6Plus4Sud]]
              else evalDesBords := evalDesBords + evalTable2^[ -AdressePattern[kAdresseBord2XCSud]];

            if (position[88] = pionVide) and (position[77] = pionVide) and (position[18] = pionVide) and (position[27] = pionVide)
              then evalDesBords := evalDesBords + evalTable^[ -AdressePattern[kAdresseBord6Plus4Est]]
              else evalDesBords := evalDesBords + evalTable2^[ -AdressePattern[kAdresseBord2XCEst]];

            evalPartielle := evalPartielle + evalDesBords;

          end;

    end;

  // Les coefficients donnes dans le fichier "coefficients.bin" de Bruno correspondent
  // à (1600 * evaluation en pions), et puisque j'ai deja appliqué une division par 2
  // pour stocker sur deux octets les valeurs des patterns, il ne reste plus qu'a diviser
  // par 8, car Cassio renvoie lui, par convention, (100* evaluation en pions)...

  evalPartielle := evalPartielle div 8;


  // New in Cassio 7.0.9 : we do this dilatation here (basicaly, we return  1.1 * eval)
  // because Bruno's eval does fit completely the theoretical score of the WThor database otherwise
   evalPartielle := (evalPartielle * 141) div 128;



  // Il faut renvoyer un resultat dans l'intervalle [-64.00, +64.00]

  if evalPartielle >  6400 then evalPartielle :=  6400;
  if evalPartielle < -6400 then evalPartielle := -6400;


  // On discretise eventuellement l'evaluation

  if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
    then
      begin
        if evalPartielle >= 0
          then EvaluationEdmond := (((evalPartielle + MoitieQuantum) div QuantumDiscretisation)*QuantumDiscretisation)
          else EvaluationEdmond := (((evalPartielle - MoitieQuantum + 1) div QuantumDiscretisation)*QuantumDiscretisation);
      end
    else
      EvaluationEdmond := evalPartielle;


  (*
  evalDesBords := evalDesBords div 8;
  evalDesBords := (evalDesBords * 141) div 128;

  if ((evalDesBords >= 2000) or (evalDesBords <= -2000)) and
     ((position[11] = pionVide) and (position[18] = pionVide) and (position[81] = pionVide) and (position[88] = pionVide)) then
     begin
      if (trait = pionNoir)
        then
          begin
            WritelnDansRapport('');
            WritelnPositionEtTraitDansRapport(position,pionNoir);
            WritelnStringAndReelDansRapport('  evalDesBords = ', evalDesBords*0.01 , 4);
            WritelnStringAndReelDansRapport('  => EdmondEvaluation = ', evalPartielle*0.01 , 4);
          end
        else
          begin
            WritelnDansRapport('');
            WritelnPositionEtTraitDansRapport(position,pionBlanc);
            WritelnStringAndReelDansRapport('  evalDesBords = ', evalDesBords*0.01 , 4);
            WritelnStringAndReelDansRapport('  => EdmondEvaluation = ', evalPartielle*0.01 , 4);
          end;
    end;
  *)

end;


function EvaluationMixteCassioEdmond(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoirs,nbBlancs,trait : SInt32; var whichEval : VectNewEvalInteger; var tranquillesNoirs,tranquillesBlancs : ListeDeCases; alpha,beta : SInt32) : SInt32;
var evalPartielleCassio : SInt32;
    evalPartielleEdmond : SInt32;
    evalPartielle : SInt32;
    tempoDiscretisation : boolean;
begin

  // desactiver la discretisation
  tempoDiscretisation := discretisationEvaluationEstOK;
  discretisationEvaluationEstOK := false;

  // evaluer avec Cassio
  evalPartielleCassio := NewEvalDeCassio(position,jouable,frontiere,nbNoirs,nbBlancs,trait,whichEval,tranquillesNoirs,tranquillesBlancs,alpha,beta);


  // evaluer avec Edmond
  if EvaluationEdmondEstDisponible
    then
      evalPartielleEdmond := EvaluationEdmond(position,frontiere,nbNoirs,nbBlancs,trait)
    else
      begin
        // non disponible : on se rabat sur l'eval de Cassio
        typeEvalEnCours := EVAL_CASSIO;

        evalPartielleEdmond := evalPartielleCassio;
      end;


  // l'evaluation mixte est la moyenne des deux evals !
  evalPartielle := (evalPartielleEdmond + evalPartielleCassio) div 2;

  // reactiver eventuellement la discretisation
  discretisationEvaluationEstOK := tempoDiscretisation;

  // renvoyer cette eval mixte, eventuellement discretisee
  if utilisateurVeutDiscretiserEvaluation and discretisationEvaluationEstOK
    then
      begin
        if evalPartielle >= 0
          then EvaluationMixteCassioEdmond := (((evalPartielle + MoitieQuantum) div QuantumDiscretisation)*QuantumDiscretisation)
          else EvaluationMixteCassioEdmond := (((evalPartielle - MoitieQuantum + 1) div QuantumDiscretisation)*QuantumDiscretisation);
      end
    else
      EvaluationMixteCassioEdmond := evalPartielle;

end;



function LectureEdmondEvalInterrompueParEvenement : boolean;
var theTick : SInt32;
begin
  LectureEdmondEvalInterrompueParEvenement := false;


  theTick := TickCount;
  if theTick >= (dernierTickAppelHasGotEvent + 2) then
    begin

      inc(nbreAppelsHasGotEventsPendantLectureEvalEdmond);
      dernierTickAppelHasGotEvent := theTick;

      gCassioChecksEvents := true;
      if HasGotEvent(everyEvent,theEvent,0,NIL) then
        begin

          TraiteOneEvenement;
          AccelereProchainDoSystemTask(2);

          if Quitter
            then LectureEdmondEvalInterrompueParEvenement := true;
        end;
    end;
end;



function LireUnTableauEvalEdmondSurLeDisque(var fic : basicfile; tableau : IntegerArrayPtr; tailleDuPattern : SInt32) : OSErr;
var count : SInt32;
    err : OSErr;
begin

  // Lire le fichier, et mettre le resultat dans le tableau
  count := Sizeof(SInt16) * TailleDUnPatternDeTantDeCases(tailleDuPattern);
  err := Read(fic, Ptr(tableau) , count);


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  SWAP_INTEGER_ARRAY( @tableau^[0], 0, TailleDUnPatternDeTantDeCases(tailleDuPattern) - 1);
  {$ENDC}



  // Appeler eventuellement la verification des evenements : de cette facon,
  // Cassio reste reactif pendant la lecture du fichier
  if (err = NoErr) then
    if LectureEdmondEvalInterrompueParEvenement then err := kErrorCassioVeutQuitterEnCatastrophe;

  // sortie
  LireUnTableauEvalEdmondSurLeDisque := err;

end;




function EcrireUnTableauEvalEdmondSurLeDisque(var fic : basicfile; tableau : IntegerArrayPtr; tailleDuPattern : SInt32) : OSErr;
var count : SInt32;
    err : OSErr;
begin


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  SWAP_INTEGER_ARRAY( @tableau^[0], 0, TailleDUnPatternDeTantDeCases(tailleDuPattern) - 1);
  {$ENDC}

  // Ecrire le tableau dans le fichier
  count := Sizeof(SInt16) * TailleDUnPatternDeTantDeCases(tailleDuPattern);
  err := Write(fic, Ptr(tableau) , count);


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  SWAP_INTEGER_ARRAY( @tableau^[0], 0, TailleDUnPatternDeTantDeCases(tailleDuPattern) - 1);
  {$ENDC}


  // sortie
  EcrireUnTableauEvalEdmondSurLeDisque := err;

end;



function LireFichierEvalEdmondSurLeDisque : OSErr;
const k_TAILLE_FICHIER_EDMOND_EVAL = 70199298;
var err : OSErr;
    fichierEval : basicfile;
    stage : SInt32;
    count : SInt32;
    ticks : SInt32;
label sortie;
begin

  ticks := TickCount;

  err := NoErr;

  // Allocation des tables dans Cassio

  if (AllocatePointersPourEvalEdmondDansCassio <> NoErr) then
    begin
      DeallocatePointersPourEvalEdmondDansCassio;

      LireFichierEvalEdmondSurLeDisque := -1;
      exit;
    end;


  // Ouverture du fichier en lecture

  err := FichierTexteDeCassioExiste('Edmond-evaluation.data', fichierEval);
  if (err <> NoErr) then goto sortie;

  err := OpenFile(fichierEval);
  if (err <> NoErr) then goto sortie;


  // Verification de la taille du fichier

  err := GetFileSize(fichierEval, count);
  if (err <> Err) then goto sortie;

  if (count <> k_TAILLE_FICHIER_EDMOND_EVAL) then
    begin
      err := -1;
      goto sortie;
    end;


  // Lecture des tables dans le fichier

  for stage := Edmond_stage_MIN to Edmond_stage_MAX do
    begin

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_5_stub[stage] , 5);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_6_stub[stage] , 6);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_7_stub[stage] , 7);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_8_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_4_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_3_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_2_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_EDGE_6_4_stub[stage] , 10);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_CORNER_2x5_stub[stage] , 10);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_CORNER_11_stub[stage] , 11);
      if (err <> NoErr) then goto sortie;

      err := LireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_EDGE_2XC_stub[stage] , 12);
      if (err <> NoErr) then goto sortie;

    end;

  // Fin

sortie :

  if (err = 0) or (err = kErrorCassioVeutQuitterEnCatastrophe) then
    err := CloseFile(fichierEval);

  if (err <> NoErr)
    then
      begin
        DeallocatePointersPourEvalEdmondDansCassio;
        {WritelnNumDansRapport('LireFichierEvalEdmondSurLeDisque :  err = ',err);}
      end
    else
      begin
        {
        WritelnNumDansRapport('LireFichierEvalEdmondSurLeDisque : OK   , temps de lecture en ticks = ',TickCount - ticks);
        WritelnNumDansRapport('nbreAppelsHasGotEventsPendantLectureEvalEdmond  = ',nbreAppelsHasGotEventsPendantLectureEvalEdmond);
        }
      end;

  LireFichierEvalEdmondSurLeDisque := err;

end;



function EcrireFichierEvalEdmondSurLeDisque : OSErr;
var err : OSErr;
    fichierEval : basicfile;
    stage : SInt32;
label sortie;
begin
  err := NoErr;

  WritelnDansRapport('Entree dans EcrireFichierEvalEdmondSurLeDisque...');

  // Verification des tables

  if not(TousLesPointeursDeLEvalEdmondSontBons) then
    begin
      EcrireFichierEvalEdmondSurLeDisque := -1;
      exit;
    end;


  // Ouverture du fichier en ecriture

  err := FichierTexteDeCassioExiste('vide.data', fichierEval);
  if (err <> NoErr) then goto sortie;

  err := OpenFile(fichierEval);
  if (err <> NoErr) then goto sortie;

  err := ClearFileContent(fichierEval);
  if (err <> NoErr) then goto sortie;


  // Ecriture des tables dans le fichier

  for stage := Edmond_stage_MIN to Edmond_stage_MAX do
    begin

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_5_stub[stage] , 5);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_6_stub[stage] , 6);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_7_stub[stage] , 7);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_DIAG_8_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_4_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_3_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_HV_2_stub[stage] , 8);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_EDGE_6_4_stub[stage] , 10);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_CORNER_2x5_stub[stage] , 10);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_CORNER_11_stub[stage] , 11);
      if (err <> NoErr) then goto sortie;

      err := EcrireUnTableauEvalEdmondSurLeDisque(fichierEval, Edmond_EDGE_2XC_stub[stage] , 12);
      if (err <> NoErr) then goto sortie;

    end;

   err := CloseFile(fichierEval);

  // Fin

sortie :

  WritelnDansRapport('Sortie de EcrireFichierEvalEdmondSurLeDisque');

  if (err <> NoErr) then
    WritelnNumDansRapport('EcrireFichierEvalEdmondSurLeDisque :  err = ',err);

  EcrireFichierEvalEdmondSurLeDisque := err;


end;



END.



























