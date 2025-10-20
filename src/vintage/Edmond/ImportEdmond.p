


UNIT ImportEdmond;


INTERFACE


 USES UnitDefCassio;



{ Traduction en Pascal des typages des fonctions C de Edmond}

function GetEdmondCoefficientsFileName : String255;
procedure edmond_load_coefficients(filename : charP);     external;
procedure edmond_release_coefficients;     external;


{ Utilitaires de traduction C <--> Pascal }

function size_of_float_in_c : SInt32;     external;
function size_of_int_in_c : SInt32;     external;



{ Import dans Cassio des pointeurs C de Edmond }

function edmond_get_black_diag_5_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_diag_5_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_diag_6_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_diag_6_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_diag_7_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_diag_7_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_diag_8_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_diag_8_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_hv_4_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_hv_4_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_hv_3_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_hv_3_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_hv_2_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_hv_2_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_edge_6_4_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_edge_6_4_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_corner_2x5_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_corner_2x5_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_corner_11_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_corner_11_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_black_edge_2XC_pointer(stage : SInt32) : LongintArrayPtr;     external;
function edmond_get_white_edge_2XC_pointer(stage : SInt32) : LongintArrayPtr;     external;

procedure ImporterLesPointeursCDeEdmond;


{ Copie des valeurs des tables C de Edmond (sur 4 octets) vers
  les tables Pascal de Cassio (sur 2 octets)         }

procedure CopierEdmondCoefficientsDansCassio;
function TransformePatternCassioVersBruno(adresseCassio : SInt32; nbreCasesDansPattern : SInt32) : SInt32;
procedure CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio : SInt32; tableEdmond : LongintArrayPtr; tableCassio : IntegerArrayPtr; const nomTable : String255);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyFileSystemUtils, MyStrings, EdmondEvaluation, UnitBords, UnitFichiersTEXT ;
{$ELSEC}
    ;
    {$I prelink/ImportEdmond.lk}
{$ENDC}


{END_USE_CLAUSE}









{$IFC DEFINED __GPC__}

  // Compile the C file
  {$L ImportEdmond_in_C.c }

{$ENDC}


// tables de Edmond, correspondant aux allocation dans le fichier C de Bruno
var
    Edmond_BLACK_DIAG_5 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_DIAG_5 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_DIAG_6 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_DIAG_6 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_DIAG_7 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_DIAG_7 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_DIAG_8 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_DIAG_8 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_HV_4 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_HV_4 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_HV_3 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_HV_3 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_HV_2 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_HV_2 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_EDGE_6_4 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_EDGE_6_4 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_CORNER_2x5 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_CORNER_2x5 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_CORNER_11 : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_CORNER_11 : array[0..64] of LongintArrayPtr;

    Edmond_BLACK_EDGE_2XC : array[0..64] of LongintArrayPtr;
    Edmond_WHITE_EDGE_2XC : array[0..64] of LongintArrayPtr;



var demi_taille_pattern_5_cases : SInt32;
    demi_taille_pattern_6_cases : SInt32;
    demi_taille_pattern_7_cases : SInt32;
    demi_taille_pattern_8_cases : SInt32;
    demi_taille_pattern_10_cases : SInt32;
    demi_taille_pattern_11_cases : SInt32;
    demi_taille_pattern_12_cases : SInt32;





procedure ImporterLesPointeursCDeEdmond;
var stage : SInt32;
begin
  for stage := 0 to 63 do
    begin

      Edmond_BLACK_DIAG_5[stage]      := edmond_get_black_diag_5_pointer(stage);
      Edmond_WHITE_DIAG_5[stage]      := edmond_get_white_diag_5_pointer(stage);

      Edmond_BLACK_DIAG_6[stage]      := edmond_get_black_diag_6_pointer(stage);
      Edmond_WHITE_DIAG_6[stage]      := edmond_get_white_diag_6_pointer(stage);

      Edmond_BLACK_DIAG_7[stage]      := edmond_get_black_diag_7_pointer(stage);
      Edmond_WHITE_DIAG_7[stage]      := edmond_get_white_diag_7_pointer(stage);

      Edmond_BLACK_DIAG_8[stage]      := edmond_get_black_diag_8_pointer(stage);
      Edmond_WHITE_DIAG_8[stage]      := edmond_get_white_diag_8_pointer(stage);

      Edmond_BLACK_HV_4[stage]        := edmond_get_black_hv_4_pointer(stage);
      Edmond_WHITE_HV_4[stage]        := edmond_get_white_hv_4_pointer(stage);

      Edmond_BLACK_HV_3[stage]        := edmond_get_black_hv_3_pointer(stage);
      Edmond_WHITE_HV_3[stage]        := edmond_get_white_hv_3_pointer(stage);

      Edmond_BLACK_HV_2[stage]        := edmond_get_black_hv_2_pointer(stage);
      Edmond_WHITE_HV_2[stage]        := edmond_get_white_hv_2_pointer(stage);

      Edmond_BLACK_EDGE_6_4[stage]    := edmond_get_black_edge_6_4_pointer(stage);
      Edmond_WHITE_EDGE_6_4[stage]    := edmond_get_white_edge_6_4_pointer(stage);

      Edmond_BLACK_CORNER_2x5[stage]  := edmond_get_black_corner_2x5_pointer(stage);
      Edmond_WHITE_CORNER_2x5[stage]  := edmond_get_white_corner_2x5_pointer(stage);

      Edmond_BLACK_CORNER_11[stage]   := edmond_get_black_corner_11_pointer(stage);
      Edmond_WHITE_CORNER_11[stage]   := edmond_get_white_corner_11_pointer(stage);

      Edmond_BLACK_EDGE_2XC[stage]    := edmond_get_black_edge_2XC_pointer(stage);
      Edmond_WHITE_EDGE_2XC[stage]    := edmond_get_white_edge_2XC_pointer(stage);

    end;
end;



function GetEdmondCoefficientsFileName : String255;
var nom : String255;
    theFic : FichierTEXT;
begin
  if FichierTexteDeCassioExiste('Edmond-coefficients.data',theFic) = NoErr
    then nom := GetFullPathOfFSSpec(theFic.theFSSpec)
    else nom := 'Edmond-coefficients.data';

  GetEdmondCoefficientsFileName := nom;
end;



procedure CopierEdmondCoefficientsDansCassio;
var indexCassio : SInt32;
    indexBruno : SInt32;
    stage : SInt32;
    EdmondEvaluationPath : String255;
label sortie;
begin

  WritelnDansRapport('Entree dans CopierEdmondCoefficientsDansCassio');

  // Fabrication de la chaine au format C contenant
  // le path du fichier des coefficients de l'eval d'Edmond
  EdmondEvaluationPath := GetEdmondCoefficientsFileName + chr(0);

  // Chargement de ce fichier, qui contient l'eval compressee de Bruno (lent !)
  edmond_load_coefficients(@EdmondEvaluationPath[1]);

  // Allocation des tables dans Cassio
  if (AllocatePointersPourEvalEdmondDansCassio <> NoErr)
    then goto sortie;

  // Import des tables C de Edmond
  ImporterLesPointeursCDeEdmond;

  // Calcul des tailles
  demi_taille_pattern_5_cases := (TailleDUnPatternDeTantDeCases(5) - 1) div 2;
  demi_taille_pattern_6_cases := (TailleDUnPatternDeTantDeCases(6) - 1) div 2;
  demi_taille_pattern_7_cases := (TailleDUnPatternDeTantDeCases(7) - 1) div 2;
  demi_taille_pattern_8_cases := (TailleDUnPatternDeTantDeCases(8) - 1) div 2;
  demi_taille_pattern_10_cases := (TailleDUnPatternDeTantDeCases(10) - 1) div 2;
  demi_taille_pattern_11_cases := (TailleDUnPatternDeTantDeCases(11) - 1) div 2;
  demi_taille_pattern_12_cases := (TailleDUnPatternDeTantDeCases(12) - 1) div 2;


  WritelnDansRapport('');


  for indexCassio := -demi_taille_pattern_12_cases to demi_taille_pattern_12_cases do
    begin


      // 12 cases : Edmond_EDGE_2XC

      indexBruno := TransformePatternCassioVersBruno(indexCassio, 12);

      for stage := Edmond_stage_MIN to Edmond_stage_MAX do
        CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_EDGE_2XC[stage],Edmond_EDGE_2XC[stage],'EDGE_2XC');



      // 11 cases : Edmond_CORNER_11

      if (indexCassio >= -demi_taille_pattern_11_cases) & (indexCassio <= demi_taille_pattern_11_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 11);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_CORNER_11[stage],Edmond_CORNER_11[stage],'CORNER_11');
        end;


      // 10 cases : Edmond_EDGE_6_4, Edmond_CORNER_2x5

      if (indexCassio >= -demi_taille_pattern_10_cases) & (indexCassio <= demi_taille_pattern_10_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 10);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_CORNER_2x5[stage],Edmond_CORNER_2x5[stage],'CORNER_2x5');

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_EDGE_6_4[stage],Edmond_EDGE_6_4[stage],'EDGE_6_4');
        end;


      // 8 cases : Edmond_DIAG_8, Edmond_HV_4, Edmond_HV_3, Edmond_HV_2

      if (indexCassio >= -demi_taille_pattern_8_cases) & (indexCassio <= demi_taille_pattern_8_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 8);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_HV_2[stage],Edmond_HV_2[stage],'HV_2');
          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_HV_3[stage],Edmond_HV_3[stage],'HV_3');
          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_HV_4[stage],Edmond_HV_4[stage],'HV_4');
          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_DIAG_8[stage],Edmond_DIAG_8[stage],'DIAG_8');
        end;


      // 7 cases : Edmond_DIAG_7

      if (indexCassio >= -demi_taille_pattern_7_cases) & (indexCassio <= demi_taille_pattern_7_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 7);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_DIAG_7[stage],Edmond_DIAG_7[stage],'DIAG_7');
        end;


      // 6 cases : Edmond_DIAG_6

      if (indexCassio >= -demi_taille_pattern_6_cases) & (indexCassio <= demi_taille_pattern_6_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 6);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_DIAG_6[stage],Edmond_DIAG_6[stage],'DIAG_6');
        end;


      // 5 cases : Edmond_DIAG_5

      if (indexCassio >= -demi_taille_pattern_5_cases) & (indexCassio <= demi_taille_pattern_5_cases) then
        begin

          indexBruno := TransformePatternCassioVersBruno(indexCassio, 5);

          for stage := Edmond_stage_MIN to Edmond_stage_MAX do
            CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio, Edmond_BLACK_DIAG_5[stage],Edmond_DIAG_5[stage],'DIAG_5');
        end;

    end;

  SetEvaluationEdmondEstDisponible(true);




sortie :

  // C'est fini : on peut liberer la memoire des pointeurs C

  edmond_release_coefficients;


  // On ecrit les coefficients de l'eval sur le disque

  if not(EvaluationEdmondEstDisponible) | (EcrireFichierEvalEdmondSurLeDisque <> NoErr) then
    begin
      WritelnDansRapport('ERROR : impossible d''ecrire le fichier de l''eval d''Edmond sur le disque !! ');
      SysBeep(0);
    end;

  WritelnDansRapport('Sortie dans CopierEdmondCoefficientsDansCassio');

end;



procedure CopierValeurPatternEdmondDansCassio(indexBruno,indexCassio : SInt32; tableEdmond : LongintArrayPtr; tableCassio : IntegerArrayPtr; const nomTable : String255);
var evalPattern : SInt32;
begin  {$unused nomTable}

  // Recuperation de l'evaluation dans les tables de Bruno sur 4 octets

  evalPattern := tableEdmond^[indexBruno];

  // On veut stocker cette eval dans un tableau chez Cassio, sur 2 octets :
  // les plus grandes valeurs des patterns chez Bruno sont -36854 et 37612,
  // donc on divise par deux (en perdant un peu de "précision") pour les
  // stocker sur deux octets chez Cassio

  tableCassio^[indexCassio] := evalPattern div 2;

end;




function TransformePatternCassioVersBruno(adresseCassio : SInt32; nbreCasesDansPattern : SInt32) : SInt32;
var pattern : t_code_pattern;
    nbretrous,nbpionsamis,nbpionsennemis : SInt32;
    result : SInt32;
begin


  result := 0;


  { Transformation de l'index de Cassio en chaine de caracteres }
  CoderPattern(adresseCassio, pattern, nbreCasesDansPattern, nbreTrous, nbPionsAmis, nbPionsEnnemis);


  { On remplace 0 par 2 et 2 par 0 dans la chaine de caracteres }
  TripleRemplacementDeCaractereDansString(pattern, '2', '0', '0', '2', '1', '1');

  { on transforme la chaine de caracteres en index à la Bruno }
  result := DecoderPattern(pattern, nbreCasesDansPattern);
  result := result + ((TailleDUnPatternDeTantDeCases(nbreCasesDansPattern) - 1) div 2);


  { Verification du resultat }
  if (result < 0) | (result > TailleDUnPatternDeTantDeCases(nbreCasesDansPattern)) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('résultat out of range pour addresseCassio = ',adresseCassio);
    end;

  TransformePatternCassioVersBruno := result;
end;



END.


























