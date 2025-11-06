UNIT UnitBords;


INTERFACE







 USES UnitDefCassio;


  { initialisation de l'unité }
  procedure InitUnitBords;
  procedure LibereMemoireUnitBords;
	procedure Init_utilitaires_bords;

	{ Manipulations de patterns }
	function DecoderBord(const chaine : t_code_pattern) : SInt32;
	function DecoderPattern(const chaine : t_code_pattern; tailleDuPattern : SInt32) : SInt32;
	procedure CoderBord(adresse : SInt32; var chaine : t_code_pattern; var nbretrous,nbpionsamis,nbpionsennemis : SInt32);
	procedure CoderPattern(adresse : SInt32; var chaine : t_code_pattern; tailleDuPattern : SInt32; var nbretrous,nbpionsamis,nbpionsennemis : SInt32);
	procedure AfficherPatternEtEvaluationDansRapport(commentaire : String255; indexPattern, longueurPattern, eval : SInt32);


	{ Gestion des bords turbulents (pour les extensions de recherche) }
	procedure Initialise_turbulence_bords(priseDeBordsSontTurbulentes : boolean);
	procedure SetTurbulenceBordsEstInitialisee(flag : boolean);
  function TurbulenceBordsEstInitialisee : boolean;



	{ Une table de bords simpliste, codee à la main (obsolete) }
	procedure Initialise_valeurs_bords(TendanceAuBeton : double);
	  {  TendanceAuBeton = 0   : neutre  }
	  {  TendanceAuBeton = 1.0 : Cassio bétonne  }
	  {  TendanceAuBeton = -1.0 : Cassio refuse les bords  }

  { Des stastistiques ? (a voir) }
  procedure VideStatistiquesDeBordsABLocal(var liste : t_liste_assoc_bord);
  procedure AjouteDansStatistiquesDeBordsABLocal(var liste : t_liste_assoc_bord; bord,indexdanstable : SInt32);
  procedure EcritStatistiquesDeBordsABLocal;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, fp, Sound, QuickdrawText
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, MyStrings, UnitRapport, UnitFenetres
    , UnitCarbonisation, UnitServicesMemoire, MyMathUtils, SNEvents ;
{$ELSEC}
    ;
    {$I prelink/Bords.lk}
{$ENDC}


{END_USE_CLAUSE}











var gTurbulenceBordsEstInitialisee : boolean;
    gTurbulenceDesPrisesDansTurbulenceDesBords : boolean;


procedure InitUnitBords;
begin
  Init_utilitaires_bords;
  SetTurbulenceBordsEstInitialisee(false);
end;


procedure LibereMemoireUnitBords;
begin
end;


procedure SetTurbulenceBordsEstInitialisee(flag : boolean);
begin
  gTurbulenceBordsEstInitialisee := flag;
end;


function TurbulenceBordsEstInitialisee : boolean;
begin
  TurbulenceBordsEstInitialisee := gTurbulenceBordsEstInitialisee;
end;


procedure VideStatistiquesDeBordsABLocal(var liste : t_liste_assoc_bord);
var i : SInt32;
begin
  for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do
    begin
      liste[i].WhichEdge := liste_assoc_turbulence_bord_AB_local[i].QuelBord;
      liste[i].Frequence := 0;
    end;
end;

procedure AjouteDansStatistiquesDeBordsABLocal(var liste : t_liste_assoc_bord; bord,indexDansTable : SInt32);
var i,caseCritiqueDansBord,inverse,CaseCritiqueInverse : SInt32;
    nbtrous,nbamis,nbennemis : SInt32;
    chaine,code_inverse : t_code_pattern;
begin
  {for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do}
  i := indexDansTable;
  if liste[i].WhichEdge = bord
    then
      begin
        inc(liste[i].Frequence);
        caseCritiqueDansBord := table_index_bords_AB_local[i];
      end
    else
      begin
        WriteDansRapport('erreur dans AjouteDansStatistiquesDeBordsABLocal !!   code = '+chaine);
        WriteNumDansRapport('  bord = ',bord);
        WritelnDansRapport('');
        {AlerteSimple('too bad : bord non trouve dans AjouteDansStatistiquesDeBordsABLocal !! ');}
        exit;
      end;

  CoderBord(bord,chaine,nbtrous,nbamis,nbennemis);

  code_inverse := '12345678';
  for i := 1 to 8 do code_inverse[i] := chaine[9-i];
  CaseCritiqueInverse := 9-caseCritiqueDansBord;
  inverse := DecoderBord(code_inverse);

  for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do
  if (liste_assoc_turbulence_bord_AB_local[i].QuelBord = inverse) and
     (liste_assoc_turbulence_bord_AB_local[i].QuelleCaseCritiqueSurLeBord = CaseCritiqueInverse)
    then
      begin
        inc(liste[i].Frequence);
        exit;
      end;

    WriteDansRapport('erreur dans AjouteDansStatistiquesDeBordsABLocal !!   code_inverse = '+chaine);
    WriteNumDansRapport('  bord = ',bord);
    WritelnDansRapport('');
    {AlerteSimple('too bad : bord non trouve dans AjouteDansStatistiquesDeBordsABLocal !! ');}

end;

procedure EcritStatistiquesDeBordsABLocal;
var i,bord,essais,coupures,square : SInt32;
    nbtrous,nbamis,nbennemis : SInt32;
    chaine : t_code_pattern;
    ratio : double;
begin
  WritelnDansRapport('Statistiques des AB locaux : ');
  for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do
    begin
      bord    := essai_bord_AB_local[i].WhichEdge;
      square  := liste_assoc_turbulence_bord_AB_local[i].QuelleCaseCritiqueSurLeBord;
      essais  := essai_bord_AB_local[i].Frequence;
      coupures := coupure_bord_AB_local[i].Frequence;

      if (essais > 0)
        then ratio := (1.0*coupures)/(1.0*essais)
        else ratio := -1.0;

      CoderBord(bord,chaine,nbtrous,nbamis,nbennemis);

      WriteNumDansRapport('i = ',i);
      WriteDansRapport('  t.code = '+chaine);
      WriteNumDansRapport('  t.bord = ',bord);
      WriteNumDansRapport('  t.case = ',square);
      WriteNumDansRapport('  t.essais = ',essais);
      WriteNumDansRapport('  t.coupures = ',coupures);
      WriteDansRapport('  ratio =  '+ReelEnStringAvecDecimales(ratio,4));
      WritelnDansRapport('');
    end;
  WritelnDansRapport('');
end;

procedure CreerTableTurbulenceBordABLocal;
var i,bord,square : SInt32;
  (*chaine : t_code_pattern;
    k,compteur : SInt32;
    nbtrous,nbamis,nbennemis : SInt32; *)
begin

  (*
  WritelnNumDansRapport('longueur = ',longueur_liste_assoc_turbulence_bord_AB_local-1);
  for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do
    begin
      bord := liste_assoc_turbulence_bord_AB_local[i].QuelBord;
      square := liste_assoc_turbulence_bord_AB_local[i].QuelleCaseCritiqueSurLeBord;
      CoderBord(bord,chaine,nbtrous,nbamis,nbennemis);

      WriteNumDansRapport('i = ',i);
      WriteDansRapport('  t.code = '+chaine);
      WriteNumDansRapport('  t.bord = ',bord);
      WriteNumDansRapport('  t.case = ',square);
      WritelnDansRapport('');
    end;
  *)

  MemoryFillChar(@table_index_bords_AB_local,sizeof(table_index_bords_AB_local),chr(0));


  for i := 0 to longueur_liste_assoc_turbulence_bord_AB_local-1 do
    begin
      bord := liste_assoc_turbulence_bord_AB_local[i].QuelBord;
      square := liste_assoc_turbulence_bord_AB_local[i].QuelleCaseCritiqueSurLeBord;

      table_index_bords_AB_local[i] := square;
      inc(table_Turbulence_alpha_beta_local^[bord]);
    end;

  for i := (-3280 -1) to 3280 +1 do
    table_Turbulence_alpha_beta_local^[i] := table_Turbulence_alpha_beta_local^[i-1]+table_Turbulence_alpha_beta_local^[i];

  {verification}
  (*
  compteur := 0;
  for bord := -3280 to 3280 do
    for k := table_Turbulence_alpha_beta_local^[bord-1] to table_Turbulence_alpha_beta_local^[bord]-1 do
      begin
        square := table_index_bords_AB_local[k];
        CoderBord(bord,chaine,nbtrous,nbamis,nbennemis);
        WriteNumDansRapport('compteur = ',compteur);
        WriteDansRapport('  t.code = '+chaine);
        WriteNumDansRapport('  t.bord = ',bord);
        WriteNumDansRapport('  t.case = ',square);
        WritelnDansRapport('');
        inc(compteur);
      end;
   *)

end;


procedure Trier_liste_assoc_turbulence_bord_AB_local; {on trie par bord ascendant avec ShellSort}
  var i,d,j,lo,up : SInt32;
      temp  : record
                bord,CaseCritique : SInt32;
              end;
  begin
    lo := 0;
    up := longueur_liste_assoc_turbulence_bord_AB_local-1;

    if up-lo > 0 then
      begin
        d := up-lo+1;
        while d > 1 do
          begin
            if d < 5
              then d := 1
              else d := Trunc(0.45454*d);
            for i := up-d downto lo do
              begin
                temp.bord        := liste_assoc_turbulence_bord_AB_local[i].QuelBord;
                temp.CaseCritique := liste_assoc_turbulence_bord_AB_local[i].QuelleCaseCritiqueSurLeBord;
                j := i+d;
                while (j <= up) and
                      (temp.bord > liste_assoc_turbulence_bord_AB_local[j].QuelBord) do
                  begin
                    liste_assoc_turbulence_bord_AB_local[j-d] := liste_assoc_turbulence_bord_AB_local[j];
                    j := j+d;
                  end;
                liste_assoc_turbulence_bord_AB_local[j-d].QuelBord                   := temp.bord;
                liste_assoc_turbulence_bord_AB_local[j-d].QuelleCaseCritiqueSurLeBord := temp.CaseCritique;
              end;
          end;
      end;
  end;

procedure Init_utilitaires_bords;
var i : SInt32;
begin

   puiss3[0] := 0;
   puiss3[1] := 1;
   for i := 2 to kTailleMaximumPattern+1 do
     puiss3[i] := 3*puiss3[i-1];
   for i := 0 to kTailleMaximumPattern+1 do
     doublePuiss3[i] := 2*puiss3[i];
   for i := 0 to kTailleMaximumPattern+1 do
     begin
       puiss3Coul[i,-1] := -puiss3[i];
       puiss3Coul[i,0] := 0;
       puiss3Coul[i,1] := puiss3[i];
       doublePuiss3Coul[i,-1] := -doublePuiss3[i];
       doublePuiss3Coul[i,0] := 0;
       doublePuiss3Coul[i,1] := doublePuiss3[i];
     end;
   equ_bord['0'] := 0;
   equ_bord['1'] := 1;
   equ_bord['2'] := -1;

   longueur_liste_assoc_turbulence_bord_AB_local := 0;
   MemoryFillChar(@liste_assoc_turbulence_bord_AB_local,sizeof(liste_assoc_turbulence_bord_AB_local),chr(0));
end;

function DecoderPattern(const chaine : t_code_pattern; tailleDuPattern : SInt32) : SInt32;
var i,aux : SInt32;
begin
  aux := 0;
  for i := 1 to tailleDuPattern do
      aux := aux+puiss3[i]*equ_bord[chaine[i]];
  DecoderPattern := aux;
end;


function DecoderBord(const chaine : t_code_pattern) : SInt32;
begin
  DecoderBord := DecoderPattern(chaine, 8);
end;



procedure CoderPattern(adresse : SInt32; var chaine : t_code_pattern; tailleDuPattern : SInt32; var nbretrous,nbpionsamis,nbpionsennemis : SInt32);
var i,aux : SInt32;
begin

  {WritelnNumDansRapport('ad = ',adresse);}

  adresse := adresse + ((puiss3[tailleDuPattern+1] - 1) div 2);

  {WritelnNumDansRapport('ad = ',adresse);}

  chaine := '';
  nbretrous := 0;
  nbpionsamis := 0;
  nbpionsennemis := 0;

  for i := 1 to tailleDuPattern do
    begin

      aux := adresse mod 3;

      if aux = 2 then
        begin
          chaine[i] := '1';
          inc(nbpionsamis);
        end else

      if aux = 0 then
        begin
          chaine[i] := '2';
          inc(nbpionsennemis);
        end

      else
        begin
          chaine[i] := '0';
          inc(nbretrous);
        end;

      adresse := adresse div 3;

      {WritelnNumDansRapport('ad = ',adresse);}

    end;

  SET_LENGTH_OF_STRING(chaine, tailleDuPattern);
end;


procedure CoderBord(adresse : SInt32; var chaine : t_code_pattern; var nbretrous,nbpionsamis,nbpionsennemis : SInt32);
begin
  CoderPattern(adresse, chaine, 8, nbretrous, nbpionsamis, nbpionsennemis);
end;



procedure AfficherPatternEtEvaluationDansRapport(commentaire : String255; indexPattern, longueurPattern, eval : SInt32);
var pattern : t_code_pattern;
    nbretrous,nbpionsamis,nbpionsennemis : SInt32;
begin
  CoderPattern(indexPattern, pattern, longueurPattern, nbreTrous, nbPionsAmis, nbPionsEnnemis);

  WriteDansRapport(commentaire);
  WritelnNumDansRapport(' : ' + pattern + ' =>  eval = ',eval);
end;



procedure Initialise_turbulence_bords(priseDeBordsSontTurbulentes : boolean);
var ticks : SInt32;

   procedure MetDansTableTurbulente_alpha_beta_local(bord,caseCritiqueDansBord : SInt32);
    begin
      if (caseCritiqueDansBord < 1) or (caseCritiqueDansBord > 8)
        then exit;


	    if longueur_liste_assoc_turbulence_bord_AB_local >= kTaille_Max_Index_Bords_AB_Local
	      then
	        begin
	          SysBeep(0);
	          WritelnDansRapport('longueur_liste_assoc_turbulence_bord_AB_local >= kTaille_Max_Index_Bords_AB_Local  dans MetDansTableTurbulente_alpha_beta_local!');
	        end
	      else
	        begin
	          if (caseCritiqueDansBord < 1) or (caseCritiqueDansBord > 8)
	            then
	              begin
	                SysBeep(0);
	                WritelnNumDansRapport('Erreur dans MetDansTableTurbulente_alpha_beta_local : caseCritiqueDansBord = ',caseCritiqueDansBord);
	              end
	            else
	              begin
      	          with liste_assoc_turbulence_bord_AB_local[longueur_liste_assoc_turbulence_bord_AB_local] do
      	            begin
      	              QuelBord := bord;
      	              QuelleCaseCritiqueSurLeBord := caseCritiqueDansBord;
      	            end;
      	          inc(longueur_liste_assoc_turbulence_bord_AB_local);
      	        end;
	        end;
	  end;


   procedure MetDansTableTurbulente(code : t_code_pattern; caseCritiqueDansBord,typeTurbulence : SInt32);
   var valeur,inverse : SInt32;
       code_inverse : t_code_pattern;
       i : SInt32;
       c : char;
   begin

     if (caseCritiqueDansBord <> -1)  then
      begin
        c := code[caseCritiqueDansBord];
        if c <> '0' then
          WritelnNumDansRapport('erreur dans ce bord : '+code+'  , '+c+' => ',caseCritiqueDansBord);
      end;

     valeur := DecoderBord(code);
     case typeTurbulence of
        independammentDuTrait :
          begin
            table_Turbulence_mono^[valeur] := caseCritiqueDansBord;
            table_Turbulence_mono^[-valeur] := caseCritiqueDansBord;
            MetDansTableTurbulente_alpha_beta_local(valeur,caseCritiqueDansBord);
            MetDansTableTurbulente_alpha_beta_local(-valeur,caseCritiqueDansBord);
          end;
        traitImportant :
          begin
            table_Turbulence_bi^[valeur] := caseCritiqueDansBord;
            MetDansTableTurbulente_alpha_beta_local(valeur,caseCritiqueDansBord);
          end;
        caseCritiqueSurLeBordPourAlphaBetaLocal :
          MetDansTableTurbulente_alpha_beta_local(valeur,caseCritiqueDansBord);
     end;

     code_inverse := '12345678';
     for i := 1 to 8 do code_inverse[i] := code[9-i];
     if (caseCritiqueDansBord <> -1) then caseCritiqueDansBord := 9-caseCritiqueDansBord;
     inverse := DecoderBord(code_inverse);
     case typeTurbulence of
        independammentDuTrait :
          begin
            table_Turbulence_mono^[inverse] := caseCritiqueDansBord;
            table_Turbulence_mono^[-inverse] := caseCritiqueDansBord;
            MetDansTableTurbulente_alpha_beta_local(inverse,caseCritiqueDansBord);
            MetDansTableTurbulente_alpha_beta_local(-inverse,caseCritiqueDansBord);
          end;
        traitImportant :
          begin
            table_Turbulence_bi^[inverse] := caseCritiqueDansBord;
            MetDansTableTurbulente_alpha_beta_local(inverse,caseCritiqueDansBord);
          end;
        caseCritiqueSurLeBordPourAlphaBetaLocal :
          MetDansTableTurbulente_alpha_beta_local(inverse,caseCritiqueDansBord);
     end;

     {AfficherBord(code);}
   end;


begin  {Initialise_turbulence_bords}

   // Si on a déjà initialisé la turbulence, avec les memes parametres, ce n'est pas la peine de la refaire

   if TurbulenceBordsEstInitialisee and (priseDeBordsSontTurbulentes = gTurbulenceDesPrisesDansTurbulenceDesBords)
     then exit;


   // Il faut y aller

   ticks := TickCount;

   Init_utilitaires_bords;

   MemoryFillChar(table_Turbulence_mono,sizeof(table_Turbulence_mono^),chr(0));
   MemoryFillChar(table_Turbulence_bi,sizeof(table_Turbulence_bi^),chr(0));
   MemoryFillChar(table_Turbulence_alpha_beta_local,sizeof(table_Turbulence_alpha_beta_local^),chr(0));

   {turbulence}
   MetDansTableTurbulente('01111010',6,independammentDuTrait);
   MetDansTableTurbulente('01110110',5,independammentDuTrait);
   MetDansTableTurbulente('01101110',4,independammentDuTrait);
   MetDansTableTurbulente('01011110',3,independammentDuTrait);
   MetDansTableTurbulente('02222020',6,independammentDuTrait);
   MetDansTableTurbulente('02220220',5,independammentDuTrait);
   MetDansTableTurbulente('02202220',4,independammentDuTrait);
   MetDansTableTurbulente('02022220',3,independammentDuTrait);

   MetDansTableTurbulente('01111011',6,independammentDuTrait);
   MetDansTableTurbulente('01110111',5,independammentDuTrait);
   MetDansTableTurbulente('01101111',4,independammentDuTrait);
   MetDansTableTurbulente('01011111',3,independammentDuTrait);
   MetDansTableTurbulente('02222022',6,independammentDuTrait);
   MetDansTableTurbulente('02220222',5,independammentDuTrait);
   MetDansTableTurbulente('02202222',4,independammentDuTrait);
   MetDansTableTurbulente('02022222',3,independammentDuTrait);

   MetDansTableTurbulente('00111010',6,independammentDuTrait);
   MetDansTableTurbulente('00110110',5,independammentDuTrait);
   MetDansTableTurbulente('00101110',4,independammentDuTrait);
   MetDansTableTurbulente('00222020',6,independammentDuTrait);
   MetDansTableTurbulente('00220220',5,independammentDuTrait);
   MetDansTableTurbulente('00202220',4,independammentDuTrait);

   MetDansTableTurbulente('10111110',2,independammentDuTrait);
   MetDansTableTurbulente('20222220',2,independammentDuTrait);
   MetDansTableTurbulente('10111100',2,independammentDuTrait);
   MetDansTableTurbulente('10100100',2,independammentDuTrait);
   MetDansTableTurbulente('20222200',2,independammentDuTrait);
   MetDansTableTurbulente('20200200',2,independammentDuTrait);
   MetDansTableTurbulente('10102010',2,independammentDuTrait);
   MetDansTableTurbulente('20201020',2,independammentDuTrait);
   MetDansTableTurbulente('20220020',2,independammentDuTrait);
   MetDansTableTurbulente('20200220',2,independammentDuTrait);
   MetDansTableTurbulente('20201120',2,traitImportant);
   MetDansTableTurbulente('20201220',2,traitImportant);
   MetDansTableTurbulente('20220120',2,traitImportant);


   MetDansTableTurbulente('01220100',5,traitImportant); {remplissage des bords de cinq}
   MetDansTableTurbulente('01120100',5,traitImportant);
   MetDansTableTurbulente('01102100',4,traitImportant);
   MetDansTableTurbulente('01201100',4,traitImportant);
   MetDansTableTurbulente('01021100',3,traitImportant);
   MetDansTableTurbulente('01202100',4,traitImportant);

   MetDansTableTurbulente('02001110',3,traitImportant); {ruse Caspard}
   MetDansTableTurbulente('02200110',4,traitImportant);
   MetDansTableTurbulente('02220010',5,traitImportant);
   MetDansTableTurbulente('02201010',4,traitImportant);
   MetDansTableTurbulente('01100200',4,traitImportant);
   MetDansTableTurbulente('02200100',4,traitImportant);
   MetDansTableTurbulente('01102020',6,traitImportant);
   MetDansTableTurbulente('02001100',3,traitImportant);
   MetDansTableTurbulente('02002100',3,traitImportant);
   MetDansTableTurbulente('02001000',3,traitImportant);

(* MetDansTableTurbulente('01000000',5,traitImportant); *) {cases C isolee}
   MetDansTableTurbulente('01200000',4,traitImportant);
(* MetDansTableTurbulente('01100000',6,traitImportant); *)
   MetDansTableTurbulente('01120000',5,traitImportant);
(* MetDansTableTurbulente('02000000',3,traitImportant); *)
(* MetDansTableTurbulente('02100000',1,traitImportant); *)
   MetDansTableTurbulente('12000000',3,traitImportant);
   MetDansTableTurbulente('12200000',4,traitImportant);
   MetDansTableTurbulente('11200000',4,traitImportant);
   MetDansTableTurbulente('12220000',5,traitImportant);
   MetDansTableTurbulente('11220000',5,traitImportant);
   MetDansTableTurbulente('11120000',5,traitImportant);
   MetDansTableTurbulente('02200000',4,traitImportant);
(*  MetDansTableTurbulente('02210000',1,traitImportant); *)

   if priseDeBordsSontTurbulentes then
     begin
       MetDansTableTurbulente('00121000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00101200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00102100',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00202100',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00201200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);

       MetDansTableTurbulente('00200000',4,caseCritiqueSurLeBordPourAlphaBetaLocal);

       MetDansTableTurbulente('00102000',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00102000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
      {MetDansTableTurbulente('00102000',7,caseCritiqueSurLeBordPourAlphaBetaLocal);}

       MetDansTableTurbulente('00010200',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00010200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);

       MetDansTableTurbulente('00110200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00102200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00012000',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00012000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00120000',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00210000',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00210000',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00210000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00122000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
       MetDansTableTurbulente('00112000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00012200',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00012200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00211000',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00122200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00112200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00111200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   MetDansTableTurbulente('00111000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('00222000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   MetDansTableTurbulente('01110000',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01110000',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01111000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		  {MetDansTableTurbulente('01111100',7,caseCritiqueSurLeBordPourAlphaBetaLocal);}

		   {
		   MetDansTableTurbulente('01222200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01122200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01112200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01111200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   }

		   MetDansTableTurbulente('01222000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01122000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01112000',6,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   {perte seche de coin ?}
		   MetDansTableTurbulente('01202000',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01202200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01220200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01120200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01202220',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01220220',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01120220',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01222020',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01122020',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01112020',6,caseCritiqueSurLeBordPourAlphaBetaLocal);


		   {attaque de bord de cinq}
		   MetDansTableTurbulente('20222220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20220020',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20200220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20201020',2,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   {bord bi-bi}
		   MetDansTableTurbulente('21022220',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('21102220',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('21110220',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('21111020',6,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   {remplissage des bords de sept}
		   MetDansTableTurbulente('20122220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20112220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20111220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20111120',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('10211110',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('10221110',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('10222110',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('10222210',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11021110',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11022110',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11022210',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11102110',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11102210',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('11110210',5,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   {remplissage des bord de six}
		   {par moi…}
		   MetDansTableTurbulente('01201110',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01202110',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01220110',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01022110',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01022210',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01120110',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01112010',6,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   {par l'adversaire…}
		   MetDansTableTurbulente('02102220',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02101220',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02110220',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02011220',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02011120',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02210220',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02221020',6,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   {remplissage des bord de cinq}
		   {par moi…}
		   MetDansTableTurbulente('01201100',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01021100',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01202100',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01220100',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01022100',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01120100',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('01102100',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   {par l'adversaire…}
		   MetDansTableTurbulente('02102200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02012200',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02101200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02110200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02011200',3,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02210200',5,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('02201200',4,caseCritiqueSurLeBordPourAlphaBetaLocal);

		   MetDansTableTurbulente('10222220',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20111200',2,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20111200',7,caseCritiqueSurLeBordPourAlphaBetaLocal);
		   MetDansTableTurbulente('20111112',2,caseCritiqueSurLeBordPourAlphaBetaLocal);

     end;


   {MetDansTableTurbulente('00120100',5,independammentDuTrait);}
   {MetDansTableTurbulente('00210200',5,independammentDuTrait);}


   MetDansTableTurbulente('02201200',4,traitImportant);
   MetDansTableTurbulente('02011200',3,traitImportant);
   MetDansTableTurbulente('02012200',3,traitImportant);
   MetDansTableTurbulente('02012000',3,traitImportant);




   (*
   MetDansTableTurbulente('01022100',3,independammentDuTrait);
   MetDansTableTurbulente('01102100',4,independammentDuTrait);
   MetDansTableTurbulente('01021100',3,independammentDuTrait);
   *)

   (*
   MetDansTableTurbulente('01220100',5,traitImportant); {remplissage de bords de cinq}
   MetDansTableTurbulente('01120100',5,traitImportant);
   MetDansTableTurbulente('01022100',3,traitImportant);
   MetDansTableTurbulente('01201100',4,traitImportant);
   MetDansTableTurbulente('01021100',3,traitImportant);
   MetDansTableTurbulente('01120100',5,traitImportant);
   MetDansTableTurbulente('01102100',4,traitImportant);
   MetDansTableTurbulente('01202100',4,traitImportant);
   *)

   MetDansTableTurbulente('01001200',7,traitImportant); { stoner en cours ?}
   MetDansTableTurbulente('01201200',4,traitImportant);
   MetDansTableTurbulente('01201000',4,traitImportant);
   MetDansTableTurbulente('01021000',3,traitImportant);
   MetDansTableTurbulente('01111200',7,traitImportant);
   MetDansTableTurbulente('01112200',7,traitImportant);
   MetDansTableTurbulente('01122200',7,traitImportant);
   MetDansTableTurbulente('01222200',7,traitImportant);
   MetDansTableTurbulente('02111102',7,traitImportant);
   MetDansTableTurbulente('02211102',7,traitImportant);
   MetDansTableTurbulente('02221102',7,traitImportant);
   MetDansTableTurbulente('02222102',7,traitImportant);
   MetDansTableTurbulente('02102102',7,traitImportant);
   MetDansTableTurbulente('02002102',7,traitImportant);

   {
   MetDansTableTurbulente('01111200',8,traitImportant);
   MetDansTableTurbulente('01112200',8,traitImportant);
   MetDansTableTurbulente('01122200',8,traitImportant);
   MetDansTableTurbulente('01222200',8,traitImportant);

   MetDansTableTurbulente('02111102',1,traitImportant);
   MetDansTableTurbulente('02211102',1,traitImportant);
   MetDansTableTurbulente('02221102',1,traitImportant);
   MetDansTableTurbulente('02222102',1,traitImportant);
   }


   MetDansTableTurbulente('01112000',6,traitImportant); { stoner diagonal en cours ?}
   MetDansTableTurbulente('01122000',6,traitImportant);
   MetDansTableTurbulente('01222000',6,traitImportant);

   MetDansTableTurbulente('21022220',3,traitImportant); { insertions dans les bords bi-bi}
   MetDansTableTurbulente('21102220',4,traitImportant);
   MetDansTableTurbulente('21110220',5,traitImportant);
   MetDansTableTurbulente('21111020',6,traitImportant);
   MetDansTableTurbulente('21020020',3,traitImportant);
   MetDansTableTurbulente('21001020',6,traitImportant);

   MetDansTableTurbulente('20120200',2,traitImportant); {Boscov et assimilés}
   MetDansTableTurbulente('20122200',2,traitImportant);
   MetDansTableTurbulente('20112200',2,traitImportant);
   MetDansTableTurbulente('20111200',2,traitImportant);
   MetDansTableTurbulente('20120220',2,traitImportant);
   MetDansTableTurbulente('20122000',2,traitImportant);
   MetDansTableTurbulente('20112000',2,traitImportant);
   MetDansTableTurbulente('22012000',3,traitImportant);
   MetDansTableTurbulente('22012200',3,traitImportant);
   MetDansTableTurbulente('22011200',3,traitImportant);

   MetDansTableTurbulente('20212200',2,traitImportant); {marconisation}
   MetDansTableTurbulente('20211200',2,traitImportant);
   MetDansTableTurbulente('20221200',2,traitImportant);
   MetDansTableTurbulente('20212202',-1,traitImportant);
   MetDansTableTurbulente('20211202',-1,traitImportant);
   MetDansTableTurbulente('20221202',-1,traitImportant);
   MetDansTableTurbulente('20212000',2,traitImportant);
   MetDansTableTurbulente('20212002',2,traitImportant);
   MetDansTableTurbulente('20210200',5,traitImportant);
   MetDansTableTurbulente('10120100',2,traitImportant);
   MetDansTableTurbulente('20201200',-1,traitImportant);
   MetDansTableTurbulente('10102100',2,traitImportant);

   MetDansTableTurbulente('20122100',2,traitImportant); {marconisation renversee}
   MetDansTableTurbulente('20112100',2,traitImportant);
   MetDansTableTurbulente('20121100',2,traitImportant);
   MetDansTableTurbulente('20122112',2,traitImportant);
   MetDansTableTurbulente('20112112',2,traitImportant);
   MetDansTableTurbulente('20121112',2,traitImportant);
   MetDansTableTurbulente('20122101',-1,traitImportant);
   MetDansTableTurbulente('20112101',-1,traitImportant);
   MetDansTableTurbulente('20121101',-1,traitImportant);
   MetDansTableTurbulente('20122102',-1,traitImportant);

   MetDansTableTurbulente('20121000',2,traitImportant);
   MetDansTableTurbulente('20121002',2,traitImportant);
   MetDansTableTurbulente('20121001',2,traitImportant);
   MetDansTableTurbulente('20120100',2,traitImportant);

   MetDansTableTurbulente('21022200',3,traitImportant); {sacrifices classiques avec case C}
   MetDansTableTurbulente('21022000',3,traitImportant);
   MetDansTableTurbulente('21020000',3,traitImportant);
   MetDansTableTurbulente('21020200',3,traitImportant);
   MetDansTableTurbulente('21021200',3,traitImportant);
   MetDansTableTurbulente('21102200',4,traitImportant);
   MetDansTableTurbulente('21102000',4,traitImportant);
   MetDansTableTurbulente('21012200',3,traitImportant);
   MetDansTableTurbulente('21012100',3,traitImportant);
   MetDansTableTurbulente('21012000',3,traitImportant);
   MetDansTableTurbulente('21110200',5,traitImportant);
   MetDansTableTurbulente('21101200',4,traitImportant);
   MetDansTableTurbulente('21011200',3,traitImportant);

   MetDansTableTurbulente('21022202',3,traitImportant); {sacrifices classiques avec case C}
   MetDansTableTurbulente('21022002',3,traitImportant); {et coin oppose rempli par 2}
   MetDansTableTurbulente('21020002',3,traitImportant);
   MetDansTableTurbulente('21020202',3,traitImportant);
   MetDansTableTurbulente('21021202',3,traitImportant);
   MetDansTableTurbulente('21102202',4,traitImportant);
   MetDansTableTurbulente('21102002',4,traitImportant);
   MetDansTableTurbulente('21012202',3,traitImportant);
   MetDansTableTurbulente('21012102',3,traitImportant);
   MetDansTableTurbulente('21012002',3,traitImportant);
   MetDansTableTurbulente('21110202',5,traitImportant);
   MetDansTableTurbulente('21101202',4,traitImportant);
   MetDansTableTurbulente('21011202',3,traitImportant);

   MetDansTableTurbulente('21022201',3,traitImportant); {sacrifices classiques avec case C}
   MetDansTableTurbulente('21022001',3,traitImportant); {et coin oppose rempli par 1}
   MetDansTableTurbulente('21020001',3,traitImportant);
   MetDansTableTurbulente('21020201',3,traitImportant);
   MetDansTableTurbulente('21021201',3,traitImportant);
   MetDansTableTurbulente('21102201',4,traitImportant);
   MetDansTableTurbulente('21102001',4,traitImportant);
   MetDansTableTurbulente('21012201',3,traitImportant);
   MetDansTableTurbulente('21012101',3,traitImportant);
   MetDansTableTurbulente('21012001',3,traitImportant);
   MetDansTableTurbulente('21110201',5,traitImportant);
   MetDansTableTurbulente('21101201',4,traitImportant);
   MetDansTableTurbulente('21011201',3,traitImportant);

   MetDansTableTurbulente('02010100',3,traitImportant);
   MetDansTableTurbulente('02012100',3,traitImportant);
   MetDansTableTurbulente('02021200',3,traitImportant);
   MetDansTableTurbulente('02010101',3,traitImportant);
   MetDansTableTurbulente('02012101',3,traitImportant);
   MetDansTableTurbulente('02021201',3,traitImportant);
   MetDansTableTurbulente('02010102',3,traitImportant);
   MetDansTableTurbulente('02012102',3,traitImportant);
   MetDansTableTurbulente('02021202',3,traitImportant);

   MetDansTableTurbulente('20122200',2,traitImportant); {arnaque sur la case C ?}
   MetDansTableTurbulente('20122000',2,traitImportant);
   MetDansTableTurbulente('20120000',2,traitImportant);
   MetDansTableTurbulente('20120200',2,traitImportant);
   MetDansTableTurbulente('20120020',2,traitImportant);
   MetDansTableTurbulente('20122220',2,traitImportant);
   MetDansTableTurbulente('20112220',2,traitImportant);
   MetDansTableTurbulente('20111220',2,traitImportant);
   MetDansTableTurbulente('20111120',2,traitImportant);
   MetDansTableTurbulente('20120220',2,traitImportant);
   MetDansTableTurbulente('20122020',2,traitImportant);
   MetDansTableTurbulente('20112020',2,traitImportant);
   MetDansTableTurbulente('20112200',2,traitImportant);
   MetDansTableTurbulente('20112000',2,traitImportant);
   MetDansTableTurbulente('20111200',2,traitImportant);

   MetDansTableTurbulente('20122202',2,traitImportant); {arnaque sur la case C ?}
   MetDansTableTurbulente('20122002',2,traitImportant); {avec coin oppose rempli par 2}
   MetDansTableTurbulente('20120002',2,traitImportant);
   MetDansTableTurbulente('20120202',2,traitImportant);
   MetDansTableTurbulente('20120022',2,traitImportant);
   MetDansTableTurbulente('20122222',2,traitImportant);
   MetDansTableTurbulente('20112222',2,traitImportant);
   MetDansTableTurbulente('20111222',2,traitImportant);
   MetDansTableTurbulente('20111122',2,traitImportant);
   MetDansTableTurbulente('20120222',2,traitImportant);
   MetDansTableTurbulente('20122022',2,traitImportant);
   MetDansTableTurbulente('20112022',2,traitImportant);
   MetDansTableTurbulente('20112202',2,traitImportant);
   MetDansTableTurbulente('20112002',2,traitImportant);
   MetDansTableTurbulente('20111202',2,traitImportant);

   MetDansTableTurbulente('20122201',2,traitImportant); {arnaque sur la case C ?}
   MetDansTableTurbulente('20122001',2,traitImportant); {avec coin oppose rempli par 1}
   MetDansTableTurbulente('20120001',2,traitImportant);
   MetDansTableTurbulente('20120201',2,traitImportant);
   MetDansTableTurbulente('20120021',2,traitImportant);
   MetDansTableTurbulente('20122221',2,traitImportant);
   MetDansTableTurbulente('20112221',2,traitImportant);
   MetDansTableTurbulente('20111221',2,traitImportant);
   MetDansTableTurbulente('20111121',2,traitImportant);
   MetDansTableTurbulente('20120221',2,traitImportant);
   MetDansTableTurbulente('20122021',2,traitImportant);
   MetDansTableTurbulente('20112021',2,traitImportant);
   MetDansTableTurbulente('20112201',2,traitImportant);
   MetDansTableTurbulente('20112001',2,traitImportant);
   MetDansTableTurbulente('20111201',2,traitImportant);

   MetDansTableTurbulente('20111111',2,traitImportant); {remplissage d'un bord par la case C}
   MetDansTableTurbulente('20111112',2,traitImportant);
   MetDansTableTurbulente('20111121',2,traitImportant);
   MetDansTableTurbulente('20111122',2,traitImportant);
   MetDansTableTurbulente('20111211',2,traitImportant);
   MetDansTableTurbulente('20111221',2,traitImportant);
   MetDansTableTurbulente('20111222',2,traitImportant);
   MetDansTableTurbulente('20112111',2,traitImportant);
   MetDansTableTurbulente('20112112',2,traitImportant);
   MetDansTableTurbulente('20112211',2,traitImportant);
   MetDansTableTurbulente('20112222',2,traitImportant);
   MetDansTableTurbulente('20112221',2,traitImportant);
   MetDansTableTurbulente('20112212',2,traitImportant);
   MetDansTableTurbulente('20121111',2,traitImportant);
   MetDansTableTurbulente('20121122',2,traitImportant);
   MetDansTableTurbulente('20121112',2,traitImportant);
   MetDansTableTurbulente('20122111',2,traitImportant);
   MetDansTableTurbulente('20122122',2,traitImportant);
   MetDansTableTurbulente('20122121',2,traitImportant);
   MetDansTableTurbulente('20122112',2,traitImportant);
   MetDansTableTurbulente('20122211',2,traitImportant);
   MetDansTableTurbulente('20122222',2,traitImportant);
   MetDansTableTurbulente('20122221',2,traitImportant);
   MetDansTableTurbulente('20122212',2,traitImportant);
   MetDansTableTurbulente('20211111',2,traitImportant);
   MetDansTableTurbulente('20211112',2,traitImportant);
   MetDansTableTurbulente('20211121',2,traitImportant);
   MetDansTableTurbulente('20211122',2,traitImportant);
   MetDansTableTurbulente('20211211',2,traitImportant);
   MetDansTableTurbulente('20211221',2,traitImportant);
   MetDansTableTurbulente('20211222',2,traitImportant);
   MetDansTableTurbulente('20212111',2,traitImportant);
   MetDansTableTurbulente('20212112',2,traitImportant);
   MetDansTableTurbulente('20212211',2,traitImportant);
   MetDansTableTurbulente('20212222',2,traitImportant);
   MetDansTableTurbulente('20212221',2,traitImportant);
   MetDansTableTurbulente('20221111',2,traitImportant);
   MetDansTableTurbulente('20221122',2,traitImportant);
   MetDansTableTurbulente('20221121',2,traitImportant);
   MetDansTableTurbulente('20221112',2,traitImportant);
   MetDansTableTurbulente('20221211',2,traitImportant);
   MetDansTableTurbulente('20221222',2,traitImportant);
   MetDansTableTurbulente('20221221',2,traitImportant);
   MetDansTableTurbulente('20222111',2,traitImportant);
   MetDansTableTurbulente('20222122',2,traitImportant);
   MetDansTableTurbulente('20222121',2,traitImportant);
   MetDansTableTurbulente('20222112',2,traitImportant);
   MetDansTableTurbulente('20222211',2,traitImportant);
   MetDansTableTurbulente('20222222',2,traitImportant);
   MetDansTableTurbulente('20222221',2,traitImportant);
   MetDansTableTurbulente('20222212',2,traitImportant);

   MetDansTableTurbulente('21011111',3,traitImportant); {remplissage d'un bord par la case A}
   MetDansTableTurbulente('21011112',3,traitImportant);
   MetDansTableTurbulente('21011121',3,traitImportant);
   MetDansTableTurbulente('21011122',3,traitImportant);
   MetDansTableTurbulente('21011211',3,traitImportant);
   MetDansTableTurbulente('21011212',3,traitImportant);
   MetDansTableTurbulente('21011221',3,traitImportant);
   MetDansTableTurbulente('21011222',3,traitImportant);
   MetDansTableTurbulente('21012111',3,traitImportant);
   MetDansTableTurbulente('21012112',3,traitImportant);
   MetDansTableTurbulente('21012121',3,traitImportant);
   MetDansTableTurbulente('21012122',3,traitImportant);
   MetDansTableTurbulente('21012211',3,traitImportant);
   MetDansTableTurbulente('21012212',3,traitImportant);
   MetDansTableTurbulente('21012221',3,traitImportant);
   MetDansTableTurbulente('21012222',3,traitImportant);
   MetDansTableTurbulente('21021111',3,traitImportant);
   MetDansTableTurbulente('21021112',3,traitImportant);
   MetDansTableTurbulente('21021121',3,traitImportant);
   MetDansTableTurbulente('21021122',3,traitImportant);
   MetDansTableTurbulente('21021211',3,traitImportant);
   MetDansTableTurbulente('21021212',3,traitImportant);
   MetDansTableTurbulente('21021221',3,traitImportant);
   MetDansTableTurbulente('21021222',3,traitImportant);
   MetDansTableTurbulente('21022111',3,traitImportant);
   MetDansTableTurbulente('21022112',3,traitImportant);
   MetDansTableTurbulente('21022121',3,traitImportant);
   MetDansTableTurbulente('21022122',3,traitImportant);
   MetDansTableTurbulente('21022211',3,traitImportant);
   MetDansTableTurbulente('21022212',3,traitImportant);
   MetDansTableTurbulente('21022221',3,traitImportant);
   MetDansTableTurbulente('21022222',3,traitImportant);
   MetDansTableTurbulente('22011111',3,traitImportant);
   MetDansTableTurbulente('22011112',3,traitImportant);
   MetDansTableTurbulente('22011121',3,traitImportant);
   MetDansTableTurbulente('22011122',3,traitImportant);
   MetDansTableTurbulente('22011211',3,traitImportant);
   MetDansTableTurbulente('22011212',3,traitImportant);
   MetDansTableTurbulente('22011221',3,traitImportant);
   MetDansTableTurbulente('22011222',3,traitImportant);
   MetDansTableTurbulente('22012111',3,traitImportant);
   MetDansTableTurbulente('22012112',3,traitImportant);
   MetDansTableTurbulente('22012121',3,traitImportant);
   MetDansTableTurbulente('22012122',3,traitImportant);
   MetDansTableTurbulente('22012211',3,traitImportant);
   MetDansTableTurbulente('22012212',3,traitImportant);
   MetDansTableTurbulente('22012221',3,traitImportant);
   MetDansTableTurbulente('22012222',3,traitImportant);
   MetDansTableTurbulente('22021111',3,traitImportant);
   MetDansTableTurbulente('22021112',3,traitImportant);
   MetDansTableTurbulente('22021121',3,traitImportant);
   MetDansTableTurbulente('22021122',3,traitImportant);
   MetDansTableTurbulente('22021211',3,traitImportant);
   MetDansTableTurbulente('22021212',3,traitImportant);
   MetDansTableTurbulente('22021221',3,traitImportant);
   MetDansTableTurbulente('22021222',3,traitImportant);
   MetDansTableTurbulente('22022111',3,traitImportant);
   MetDansTableTurbulente('22022112',3,traitImportant);
   MetDansTableTurbulente('22022121',3,traitImportant);
   MetDansTableTurbulente('22022122',3,traitImportant);
   MetDansTableTurbulente('22022211',3,traitImportant);
   MetDansTableTurbulente('22022212',3,traitImportant);
   MetDansTableTurbulente('22022221',3,traitImportant);
   MetDansTableTurbulente('22022222',3,traitImportant);


   MetDansTableTurbulente('10102000',2,traitImportant); {arnaques sur la case B…}
   MetDansTableTurbulente('10102200',2,traitImportant);
   MetDansTableTurbulente('10101000',2,traitImportant);
   MetDansTableTurbulente('10102100',2,traitImportant);
   MetDansTableTurbulente('10101200',2,traitImportant);
   MetDansTableTurbulente('12101000',4,traitImportant);
   MetDansTableTurbulente('12101200',4,traitImportant);
   MetDansTableTurbulente('12102200',4,traitImportant);
   MetDansTableTurbulente('12101100',4,traitImportant);
   MetDansTableTurbulente('20201000',2,traitImportant);
   MetDansTableTurbulente('20201100',2,traitImportant);
   MetDansTableTurbulente('20202000',2,traitImportant);
   MetDansTableTurbulente('20202200',2,traitImportant);
   MetDansTableTurbulente('20202100',2,traitImportant);
   MetDansTableTurbulente('20201200',2,traitImportant);
   MetDansTableTurbulente('20202220',2,traitImportant);
   MetDansTableTurbulente('21202000',4,traitImportant);
   MetDansTableTurbulente('21202200',4,traitImportant);
   MetDansTableTurbulente('21202220',4,traitImportant);


   MetDansTableTurbulente('10100000',2,traitImportant); {arnaques sur la case C…}
   MetDansTableTurbulente('10110000',2,traitImportant);
   MetDansTableTurbulente('10111000',2,traitImportant);
   MetDansTableTurbulente('10100001',2,traitImportant);
   MetDansTableTurbulente('10110001',2,traitImportant);
   MetDansTableTurbulente('10111001',2,traitImportant);
   MetDansTableTurbulente('10100002',2,traitImportant);
   MetDansTableTurbulente('10110002',2,traitImportant);
   MetDansTableTurbulente('10111002',2,traitImportant);
   MetDansTableTurbulente('20200000',2,traitImportant);
   MetDansTableTurbulente('20220000',2,traitImportant);
   MetDansTableTurbulente('20222000',2,traitImportant);
   MetDansTableTurbulente('20200001',2,traitImportant);
   MetDansTableTurbulente('20220001',2,traitImportant);
   MetDansTableTurbulente('20222001',2,traitImportant);
   MetDansTableTurbulente('20200002',2,traitImportant);
   MetDansTableTurbulente('20220002',2,traitImportant);
   MetDansTableTurbulente('20222002',2,traitImportant);

   MetDansTableTurbulente('12222200',7,traitImportant); {peut-on prendre les pions definitifs ?}
   MetDansTableTurbulente('11222200',7,traitImportant);
   MetDansTableTurbulente('11122200',7,traitImportant);
   MetDansTableTurbulente('11112200',7,traitImportant);
   MetDansTableTurbulente('11111200',7,traitImportant);


  { MetDansTableTurbulente('00202000',-1,traitImportant); }

   {AttendFrappeClavier;}

   Trier_liste_assoc_turbulence_bord_AB_local;
   CreerTableTurbulenceBordABLocal;



   // On met le drapeau disant que l'on a fini d'initialiser la turbulence des bords

   SetTurbulenceBordsEstInitialisee(true);
   gTurbulenceDesPrisesDansTurbulenceDesBords := priseDeBordsSontTurbulentes;


   {WritelnNumDansRapport('temps de Initialise_turbulence_bords en ticks = ',TickCount - ticks);}

end;  { Initialise_turbulence_bords }




procedure Initialise_valeurs_bords(TendanceAuBeton : double);
  {  TendanceAuBeton = 0   : neutre  }
  {  TendanceAuBeton = 1.0 : Cassio bétonne  }
  {  TendanceAuBeton = -1.0 : Cassio refuse les bords  }
var tick : SInt32;
    {nbtrous,nbamis,nbennemis,i,aux : SInt32; }
    {unCode,autreCode : t_code_pattern; }
    {fichierBordsNonCotes:TEXT;}
    {adresse,compteur : SInt32; }
    {reply : SFReply;}
    {nomfichier : String255;}

    probleme : boolean;
    compteurFautes : SInt32;
    compteurTurbulence : SInt32;

    attraitPourLesBords : SInt32;
    NoteBordDeSixAmi : SInt32;
    NoteBordDeSixAdv : SInt32;
    oldport : grafPtr;





procedure EnvoyerBord(code : t_code_pattern; note : SInt32);
var adresse,inverse,i : SInt32;
    dejaProblemepourcebord : boolean;
begin
  dejaProblemepourcebord := false;

  adresse := 0;
  for i := 1 to 8 do
     adresse := adresse+puiss3[i]*equ_bord[code[i]];
  inverse := 0;
  for i := 1 to 8 do
     inverse := inverse+puiss3[i]*equ_bord[code[9-i]];

  (*
  if (code[1] = '0') and (code[8] = '0') then
    for i := 2 to 7 do
      if code[i] = '1' then note := note+25 else
      if code[i] = '2' then note := note-25;
  *)

  if note = 0 then note := 1;

  if (valeurBord^[inverse] <> 0) then
   if valeurBord^[inverse] <> note then
    begin
      compteurFautes := compteurFautes+1;
      SysBeep(0);
      Moveto({-55+}(compteurFautes mod 8)*57,40+(compteurFautes div 8)*13);
      MyDrawString(code+CharToString(' '));
      dejaProblemepourcebord := true;
      probleme := true;
    end;
  if (valeurBord^[adresse] <> 0) then
   if valeurBord^[adresse] <> note then
    begin
      SysBeep(0);
      if not dejaProblemepourcebord then
        begin
          compteurFautes := compteurFautes+1;
          Moveto(10+(compteurFautes mod 8)*50,40+(compteurFautes div 8)*13);
          MyDrawString(code+CharToString(' '));
        end;
      probleme := true;
    end;

  valeurBord^[inverse] := note;
  valeurBord^[adresse] := note;
end; {envoyer}



procedure AfficherBord(code : t_code_pattern);
var a,b,valeur : SInt32;
begin
  valeur := DecoderBord(code);
  a := 10+(compteurTurbulence mod 5)*97;
  b := 40+(compteurTurbulence div 5)*13;
  Moveto(a,b);
  MyDrawString(code);
  WriteNumAt(':',valeur,a+51,b);
  compteurTurbulence := compteurTurbulence+1;
end;








procedure noter_Bords_1;
begin
   EnvoyerBord('10000000',450);
   EnvoyerBord('01011110',-1000);
   EnvoyerBord('01110110',-1000);
   EnvoyerBord('01111010',-1000);
   EnvoyerBord('01011100',-1000);
   EnvoyerBord('01101100',-1000);
   EnvoyerBord('00101110',-1000);
   EnvoyerBord('00110110',-1000);
   EnvoyerBord('00111010',-1000);
   EnvoyerBord('01011000',-1000);
   EnvoyerBord('01101000',-1000);
   EnvoyerBord('00010110',-1000);
   EnvoyerBord('00011010',-1000);
   EnvoyerBord('01010000',-1000);
   EnvoyerBord('00001010',-1000);
   EnvoyerBord('01000110',-800);
   EnvoyerBord('01100010',-800);
   EnvoyerBord('01000100',-1800);
   EnvoyerBord('00100010',-1800);
   EnvoyerBord('01010110',-1300);
   EnvoyerBord('01011010',-1300);
   EnvoyerBord('01101010',-1300);
   EnvoyerBord('01010100',-1300);
   EnvoyerBord('00101010',-1300);
   EnvoyerBord('01000010',-1300);
   EnvoyerBord('01010010',-1700);
   EnvoyerBord('01210010',-1700);
   EnvoyerBord('01012210',-1700);
   EnvoyerBord('01020010',-1300);
   EnvoyerBord('01021010',-1700);
   EnvoyerBord('01020210',-1700);
   EnvoyerBord('01002110',-1700);
   EnvoyerBord('01200110',-1700);


   EnvoyerBord('20000000',-450);
   EnvoyerBord('02022220',1000);
   EnvoyerBord('02202220',1000);
   EnvoyerBord('02022200',1000);
   EnvoyerBord('02202200',1000);
   EnvoyerBord('02220200',1000);
   EnvoyerBord('02022000',1200);
   EnvoyerBord('02202000',1200);
   EnvoyerBord('02020000',1200);
   EnvoyerBord('02000220',1400);
   EnvoyerBord('02000200',1800);
   EnvoyerBord('02020220',1300);
   EnvoyerBord('02022020',1300);
   EnvoyerBord('02020200',1300);
   EnvoyerBord('02000020',1300);
   EnvoyerBord('02020020',1300);
   EnvoyerBord('02120020',900);
   EnvoyerBord('02021120',900);
   EnvoyerBord('02010020',1300);
   EnvoyerBord('02012020',1300);
   EnvoyerBord('02010120',900);
   EnvoyerBord('02100110',900);
   EnvoyerBord('02001220',900);
   EnvoyerBord('02100220',900);
   EnvoyerBord('01200220',500);
   EnvoyerBord('01201220',100);
   EnvoyerBord('01201120',100);


   EnvoyerBord('02020010',200);
   EnvoyerBord('02102020',valPriseCoin);
   EnvoyerBord('02201200',valPriseCoin);
   EnvoyerBord('02020100',valPriseCoin);
   EnvoyerBord('02010100',900);
   EnvoyerBord('02012100',900);
   EnvoyerBord('02000100',valPriseCoin);
   EnvoyerBord('02210100',valPriseCoin);
   EnvoyerBord('02001000',valPriseCoin);
   EnvoyerBord('01010210',-1200);
   EnvoyerBord('01010200',-800);
   EnvoyerBord('01002000',-800);
   EnvoyerBord('01020200',-900);
   EnvoyerBord('01021200',-900);
   EnvoyerBord('01000200',-1000);
   EnvoyerBord('01120200',-800);
   EnvoyerBord('01221200',-800);
   EnvoyerBord('02001010',-800);
   EnvoyerBord('01101020',-800);
   EnvoyerBord('01011020',-800);
   EnvoyerBord('01010220',-800);
   EnvoyerBord('02202010',800);
   EnvoyerBord('02202010',800);
   EnvoyerBord('02020110',800);
end;



procedure noter_bords_2;
begin
   EnvoyerBord('01202200',-900);
   EnvoyerBord('01012100',-1400);
   EnvoyerBord('01210100',-900);
   EnvoyerBord('01210200',-900);
   EnvoyerBord('01210000',-900);
   EnvoyerBord('02021200',1400);
   EnvoyerBord('01002200',-600);
   EnvoyerBord('01100200',-600);
   EnvoyerBord('02001100',600);
   EnvoyerBord('02200100',600);
   EnvoyerBord('01002100',-950);
   EnvoyerBord('01200100',-950);
   EnvoyerBord('02001200',950);
   EnvoyerBord('02100200',950);
   EnvoyerBord('01020100',-200);
   EnvoyerBord('02010200',200);
   EnvoyerBord('02011200',1100);
   EnvoyerBord('02012200',1100);
   EnvoyerBord('02012000',1100);
   EnvoyerBord('02002100',1100);
   EnvoyerBord('02120200',1000);
   EnvoyerBord('02120100',1000);
   EnvoyerBord('02120000',1000);
   EnvoyerBord('02102100',1000);
   EnvoyerBord('02102220',1400);
   EnvoyerBord('02210220',1400);
   EnvoyerBord('02221020',1400);
   EnvoyerBord('02120220',1500);


   EnvoyerBord('01221110',-1000);
   EnvoyerBord('01122110',-1000);
   EnvoyerBord('01222110',-1000);
   EnvoyerBord('01222210',-1000);
   EnvoyerBord('01211110',-1000);
   EnvoyerBord('01121110',-1000);



   EnvoyerBord('02110220',1000);
   EnvoyerBord('02011220',1000);
   EnvoyerBord('02101220',1000);
   EnvoyerBord('02111020',1000);
   EnvoyerBord('02110120',1000);

   EnvoyerBord('02112220',1400);
   EnvoyerBord('02211220',1400);
   EnvoyerBord('02111220',1400);
   EnvoyerBord('02111120',1400);
   EnvoyerBord('02122220',1400);
   EnvoyerBord('02212220',1400);
   EnvoyerBord('01221000',-1400);
   EnvoyerBord('01221100',-1400);
   EnvoyerBord('01122100',-1400);
   EnvoyerBord('01222100',-1400);
   EnvoyerBord('01211100',-1400);
   EnvoyerBord('01121100',-1400);
   EnvoyerBord('01112100',-1400);
   EnvoyerBord('02112000',1300);
   EnvoyerBord('02112200',1300);
   EnvoyerBord('02211200',1300);
   EnvoyerBord('02111200',1300);
   EnvoyerBord('02122200',1300);
   EnvoyerBord('02212200',1300);
   EnvoyerBord('02221200',1300);


   EnvoyerBord('00111110',attraitPourLesBords+100);
   EnvoyerBord('00222220',-attraitPourLesBords-100);
   EnvoyerBord('01111000',attraitPourLesBords);
   EnvoyerBord('02222000',-attraitPourLesBords);
   EnvoyerBord('00111000',attraitPourLesBords+50);
   EnvoyerBord('00222000',-attraitPourLesBords-50);
   EnvoyerBord('01110000',attraitPourLesBords-150);
   EnvoyerBord('02220000',-attraitPourLesBords+150);
   EnvoyerBord('01100000',-500);
   EnvoyerBord('02200000',500);
   EnvoyerBord('00100000',attraitPourLesBords div 4 + 30);
   EnvoyerBord('00200000',-attraitPourLesBords div 4 - 30);
   EnvoyerBord('00010000',attraitPourLesBords div 4-10);
   EnvoyerBord('00020000',-attraitPourLesBords div 4+10);
   EnvoyerBord('00110000',attraitPourLesBords-10);
   EnvoyerBord('00220000',-attraitPourLesBords+10);
   EnvoyerBord('00011000',attraitPourLesBords);
   EnvoyerBord('00022000',-attraitPourLesBords);
   EnvoyerBord('00111100',attraitPourLesBords+350);
   EnvoyerBord('00222200',-attraitPourLesBords-350);
   EnvoyerBord('01111110',NoteBordDeSixAmi);
   EnvoyerBord('02222220',NoteBordDeSixAdv);
   EnvoyerBord('02000000',1000);
   EnvoyerBord('01000000',-1000);
   EnvoyerBord('00102000',20);
   EnvoyerBord('00010200',-20);
   EnvoyerBord('00110200',attraitPourLesBords);
   EnvoyerBord('00102200',-attraitPourLesBords);
   EnvoyerBord('00100200',1);
   EnvoyerBord('01000020',500);
end;


procedure noter_bords_3;
begin
   EnvoyerBord('02100000',520);
   EnvoyerBord('00120000',1);
   EnvoyerBord('00012000',-5);
   EnvoyerBord('00210000',1);
   EnvoyerBord('00221000',attraitPourLesBords+80);
   EnvoyerBord('00211000',attraitPourLesBords+80);
   EnvoyerBord('01021000',attraitPourLesBords+80);
   EnvoyerBord('00111200',attraitPourLesBords+80);
   EnvoyerBord('00112200',attraitPourLesBords+80);
   EnvoyerBord('00122200',attraitPourLesBords+80);
   EnvoyerBord('00112010',attraitPourLesBords+80);
   EnvoyerBord('00122010',attraitPourLesBords+80);
   EnvoyerBord('00120110',attraitPourLesBords+80);
   EnvoyerBord('00122000',attraitPourLesBords+100);
   EnvoyerBord('00120100',attraitPourLesBords+100);
   EnvoyerBord('00112000',attraitPourLesBords+100);




   EnvoyerBord('01022220',50); {car les cases C n'ont qu'une case vide à côté}
   EnvoyerBord('01102220',0);
   EnvoyerBord('01110220',0);
   EnvoyerBord('01111020',-50);


   EnvoyerBord('00100100',attraitPourLesBords+20);
   EnvoyerBord('00200200',-attraitPourLesBords-20);
   EnvoyerBord('00101200',50);
   EnvoyerBord('00120200',-50);

   EnvoyerBord('01020000',-900);
   EnvoyerBord('02010000',900);
   EnvoyerBord('02210000',1100);
   EnvoyerBord('02110000',1100);

   EnvoyerBord('00201110',-450);
   EnvoyerBord('00210110',-450);
   EnvoyerBord('00211010',-450);
   EnvoyerBord('00221010',-450);
   EnvoyerBord('00222010',-450);
   EnvoyerBord('00220110',-450);
   EnvoyerBord('00020110',-400);
   EnvoyerBord('00022010',-400);
   EnvoyerBord('00021010',-500);
   EnvoyerBord('02220100',450);
   EnvoyerBord('02202100',450);
   EnvoyerBord('02022100',450);
   EnvoyerBord('02201100',450);
   EnvoyerBord('02011100',450);
   EnvoyerBord('02021100',450);
   EnvoyerBord('02201000',400);
   EnvoyerBord('02011000',400);
   EnvoyerBord('02021000',500);



   EnvoyerBord('00122100',-400);
   EnvoyerBord('00121100',-350);
   EnvoyerBord('00211200',400);
   EnvoyerBord('00212200',350);
   EnvoyerBord('00121000',-300);
   EnvoyerBord('00212000',300);
   EnvoyerBord('00101000',-150);
   EnvoyerBord('00101100',-250);
   EnvoyerBord('00202000',150);
   EnvoyerBord('00202200',250);
   EnvoyerBord('00210200',100);


   EnvoyerBord('01222200',valDefenseCoin-500);
   EnvoyerBord('01122200',valDefenseCoin-500);
   EnvoyerBord('01112200',valDefenseCoin-500);
   EnvoyerBord('01111200',valDefenseCoin-500);
   EnvoyerBord('01222010',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01220110',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01201110',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01120110',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01022110',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01021110',valDefenseCoin+NoteBordDeSixAmi-200);
   EnvoyerBord('01120210',valDefenseCoin+valDefenseCoin+600);
   EnvoyerBord('01222000',valDefenseCoin-400);
   EnvoyerBord('01122000',valDefenseCoin-300);
   EnvoyerBord('01112000',valDefenseCoin-200);
   EnvoyerBord('01220100',valDefenseCoin);
   EnvoyerBord('01120100',valDefenseCoin);
   EnvoyerBord('01202100',valDefenseCoin);
   EnvoyerBord('01201100',valDefenseCoin);
   EnvoyerBord('01120000',valDefenseCoin-200);
   EnvoyerBord('01220000',valDefenseCoin-200);
   EnvoyerBord('01201000',valDefenseCoin-200);
   EnvoyerBord('01200000',valDefenseCoin-300);
end;


procedure noter_bords_4;
begin



   EnvoyerBord('02100100',810);
   EnvoyerBord('02111100',900);
   EnvoyerBord('02111000',700);
   EnvoyerBord('02222100',700);
   EnvoyerBord('02221000',700);
   EnvoyerBord('02221100',700);
   EnvoyerBord('02211000',700);


   EnvoyerBord('11111111',1100);
   EnvoyerBord('01111111',1100);
   EnvoyerBord('00111111',1100);
   EnvoyerBord('00011111',977);
   EnvoyerBord('00001111',877);
   EnvoyerBord('00000111',627);
   EnvoyerBord('02111111',1000);
   EnvoyerBord('00021111',950);
   EnvoyerBord('00002111',900);
   EnvoyerBord('00000211',877);
   EnvoyerBord('00000021',627);
   EnvoyerBord('22222222',-1100);
   EnvoyerBord('02222222',-1100);
   EnvoyerBord('00222222',-1100);
   EnvoyerBord('00022222',-977);
   EnvoyerBord('00002222',-877);
   EnvoyerBord('00000222',-627);
   EnvoyerBord('00122222',-1000);
   EnvoyerBord('00012222',-950);
   EnvoyerBord('00001222',-900);
   EnvoyerBord('00000122',-777);
   EnvoyerBord('00000012',-627);

   EnvoyerBord('11101111',827);
   EnvoyerBord('11011111',827);
   EnvoyerBord('10111111',827);
   EnvoyerBord('20111111',927);
   EnvoyerBord('20011111',827);
   EnvoyerBord('20001111',827);
   EnvoyerBord('20000111',827);
   EnvoyerBord('20222222',-827);
   EnvoyerBord('10222222',-927);
   EnvoyerBord('10022222',-827);
   EnvoyerBord('10002222',-827);
   EnvoyerBord('10000222',-827);

   EnvoyerBord('02221010',-100);
   EnvoyerBord('02211010',-100);
   EnvoyerBord('02210110',-100);
   EnvoyerBord('02101110',-100);
   EnvoyerBord('02110110',-100);
   EnvoyerBord('02111010',-100);
   EnvoyerBord('02120110',-100);
   EnvoyerBord('02112010',-100);
   EnvoyerBord('01112020',100);
   EnvoyerBord('01122020',100);
   EnvoyerBord('01120220',100);
   EnvoyerBord('01222020',100);
   EnvoyerBord('01220220',100);
   EnvoyerBord('01202220',100);
   EnvoyerBord('01210220',100);
   EnvoyerBord('01221020',100);

   EnvoyerBord('02220010',600);
   EnvoyerBord('01110020',200);


   EnvoyerBord('02222210',valPriseCoin+600);
   EnvoyerBord('02222110',valPriseCoin+600);
   EnvoyerBord('02221110',valPriseCoin+600);
   EnvoyerBord('02211110',valPriseCoin+600);
   EnvoyerBord('02111110',valPriseCoin+600);


   EnvoyerBord('20210000',-500);
   EnvoyerBord('20221000',-500);
   EnvoyerBord('20211000',-500);
   EnvoyerBord('20222100',-500);
   EnvoyerBord('20221100',-500);
   EnvoyerBord('20211100',-500);
   EnvoyerBord('20222210',-1000);
   EnvoyerBord('20222110',-1000);
   EnvoyerBord('20221110',-1000);
   EnvoyerBord('20211110',-1000);
   EnvoyerBord('22021000',-500);
   EnvoyerBord('22101000',-500);
   EnvoyerBord('22022100',-600);
   EnvoyerBord('22202100',-700);
   EnvoyerBord('22101100',-800);
   EnvoyerBord('22110100',-800);
   EnvoyerBord('22022210',-800);
   EnvoyerBord('22022110',-800);
   EnvoyerBord('22021110',-800);
   EnvoyerBord('22202210',-800);
   EnvoyerBord('22202110',-800);
   EnvoyerBord('22220210',-800);

   EnvoyerBord('10120000',500);
   EnvoyerBord('10112000',500);
   EnvoyerBord('10122000',500);
   EnvoyerBord('10111200',100);
   EnvoyerBord('10112200',100);
   EnvoyerBord('10122200',100);
   EnvoyerBord('10111120',1000);
   EnvoyerBord('10111220',1000);
   EnvoyerBord('10112220',1000);
   EnvoyerBord('10122220',1000);
   EnvoyerBord('11012000',500);
   EnvoyerBord('11202000',500);
   EnvoyerBord('11011200',600);
   EnvoyerBord('11101200',700);
   EnvoyerBord('11202200',800);
   EnvoyerBord('11220200',800);
   EnvoyerBord('11011120',800);
   EnvoyerBord('11011220',800);
   EnvoyerBord('11012220',800);
   EnvoyerBord('11101120',800);
   EnvoyerBord('11101220',800);
   EnvoyerBord('11110120',800);



  EnvoyerBord('20200000',-100);
  EnvoyerBord('20002000',-500);
  EnvoyerBord('20000020',-200);
  EnvoyerBord('20000200',-500);
  EnvoyerBord('10100000',100);
  EnvoyerBord('10001000',500);
  EnvoyerBord('10000010',200);
  EnvoyerBord('10000100',500);
  EnvoyerBord('20222200',900);
  EnvoyerBord('10111100',200);
  EnvoyerBord('20200200',700);
  EnvoyerBord('10100100',-20);
  EnvoyerBord('22022200',350);
  EnvoyerBord('11011100',-400);

  EnvoyerBord('20200202',200);
  EnvoyerBord('10100101',-200);

  EnvoyerBord('21222010',-400);
  EnvoyerBord('12111020',400);

  EnvoyerBord('12111100',-600);
  EnvoyerBord('21222200',600);
  EnvoyerBord('11211100',-600);
  EnvoyerBord('22122200',600);
  EnvoyerBord('11221100',-600);
  EnvoyerBord('22112200',600);
  EnvoyerBord('11222100',-600);
  EnvoyerBord('22111200',600);
  EnvoyerBord('11122100',-100);
  EnvoyerBord('22211200',100);
  EnvoyerBord('11211000',-600);
  EnvoyerBord('22122000',600);
  EnvoyerBord('11221000',-600);
  EnvoyerBord('22112000',600);



  EnvoyerBord('21222202',2*valCoin);
  EnvoyerBord('21122202',2*valCoin);
  EnvoyerBord('21112202',2*valCoin);
  EnvoyerBord('21111202',2*valCoin);
  EnvoyerBord('21222012',2*valCoin);
  EnvoyerBord('21122012',2*valCoin);
  EnvoyerBord('21112012',2*valCoin);
  EnvoyerBord('21220112',2*valCoin);
  EnvoyerBord('21120112',2*valCoin);
  EnvoyerBord('21220212',2*valCoin);
  EnvoyerBord('21120212',2*valCoin);
  EnvoyerBord('21110212',2*valCoin);
  EnvoyerBord('21111112',2*valCoin);


  EnvoyerBord('12222221',-2*valCoin);
  EnvoyerBord('12111101',-600);
  EnvoyerBord('12211101',-600);
  EnvoyerBord('12221101',-600);
  EnvoyerBord('12222101',-600);
  EnvoyerBord('12111021',850);
  EnvoyerBord('12211021',650);
  EnvoyerBord('12221021',450);
  EnvoyerBord('12110221',850);
  EnvoyerBord('12210221',650);
  EnvoyerBord('12110121',-600);
  EnvoyerBord('12210121',-600);
  EnvoyerBord('12220121',850);





   EnvoyerBord('12222220',1000);
   EnvoyerBord('11222220',1000);
   EnvoyerBord('11122220',1000);
   EnvoyerBord('12222200',800);
   EnvoyerBord('11222200',800);
   EnvoyerBord('11122200',800);
   EnvoyerBord('11112200',800);
   EnvoyerBord('11111200',900);
   EnvoyerBord('21111102',100);
   EnvoyerBord('22111102',500);
   EnvoyerBord('22211102',400);
   EnvoyerBord('22221102',300);
   EnvoyerBord('22222102',200);
   EnvoyerBord('21111012',400);
   EnvoyerBord('22111012',300);
   EnvoyerBord('22211012',200);
   EnvoyerBord('22221012',100);
   EnvoyerBord('21111022',-1000);
   EnvoyerBord('22111022',-1000);
   EnvoyerBord('22211022',-1000);
   EnvoyerBord('22221022',-1000);
   EnvoyerBord('21110112',-1000);
   EnvoyerBord('22110112',-1000);
   EnvoyerBord('22210112',-1000);
   EnvoyerBord('21110122',-1000);
   EnvoyerBord('22110122',-1000);
   EnvoyerBord('22210122',-1000);


   EnvoyerBord('21111110',-1000);
   EnvoyerBord('22111110',-1000);
   EnvoyerBord('22211110',-1000);
   EnvoyerBord('22221110',-1000);
   EnvoyerBord('22222110',-1000);
   EnvoyerBord('22222210',-1000);
   EnvoyerBord('21111100',-927);
   EnvoyerBord('22111100',-950);
   EnvoyerBord('22211100',-950);
   EnvoyerBord('22221100',-950);
   EnvoyerBord('22221010',-850);
   EnvoyerBord('22211010',-850);
   EnvoyerBord('22111010',-850);
   EnvoyerBord('21111010',-850);
   EnvoyerBord('22210010',-850);
   EnvoyerBord('22100010',-850);
   EnvoyerBord('21000010',-1000);
   EnvoyerBord('22220010',-850);
   EnvoyerBord('22200010',-850);
   EnvoyerBord('22000010',-850);
end;

procedure noter_bords_5;
begin
   EnvoyerBord('20012220',700);
   EnvoyerBord('20011220',700);
   EnvoyerBord('20011120',700);


   EnvoyerBord('12222000',900);
   EnvoyerBord('11222000',900);
   EnvoyerBord('11122000',900);
   EnvoyerBord('12220000',900);
   EnvoyerBord('11220000',900);
   EnvoyerBord('11120000',900);
   EnvoyerBord('21111000',-900);
   EnvoyerBord('22111000',-900);
   EnvoyerBord('22211000',-900);
   EnvoyerBord('21110000',-900);
   EnvoyerBord('22110000',-900);
   EnvoyerBord('22210000',-900);



  EnvoyerBord('02220002',valCoin-50);
  EnvoyerBord('02222202',valCoin+550);
  EnvoyerBord('02222022',valCoin+100);
  EnvoyerBord('02220222',valCoin-100);
  EnvoyerBord('02202222',valCoin-400);
  EnvoyerBord('02022222',valCoin-650);
  EnvoyerBord('10111110',-250-valCoin div 2);
  EnvoyerBord('11011110',-200-valCoin);
  EnvoyerBord('11101110',-150-valCoin);
  EnvoyerBord('11110110',-valCoin);
  EnvoyerBord('11111010',650-valCoin);
  EnvoyerBord('10001110',-150-valCoin div 2);
  EnvoyerBord('10021110',-500-valCoin);

  EnvoyerBord('22222221',-900);
  EnvoyerBord('22222211',-900);
  EnvoyerBord('22222111',-650);
  EnvoyerBord('22221111',1);
  EnvoyerBord('22211111',650);
  EnvoyerBord('22111111',900);
  EnvoyerBord('21111111',900);

  EnvoyerBord('21222221',-1000);
  EnvoyerBord('21222211',-800);
  EnvoyerBord('22211121',-550);
  EnvoyerBord('22221111',1);
  EnvoyerBord('21222111',550);
  EnvoyerBord('22111121',800);
  EnvoyerBord('21111121',1000);

  EnvoyerBord('02222012',valCoin-300);
  EnvoyerBord('02220112',valCoin-300);
  EnvoyerBord('02201112',valCoin-300);
  EnvoyerBord('02011112',valCoin-300);

  EnvoyerBord('01111021',1000);
  EnvoyerBord('01110211',1000);
  EnvoyerBord('01110221',1000);
  EnvoyerBord('01102111',1000);
  EnvoyerBord('01102211',1000);
  EnvoyerBord('01102221',1000);
  EnvoyerBord('01021111',1000);
  EnvoyerBord('01022111',1000);
  EnvoyerBord('01022211',1000);
  EnvoyerBord('01022221',1000);
  EnvoyerBord('10211111',1000);
  EnvoyerBord('10221111',1000);
  EnvoyerBord('10222111',1000);
  EnvoyerBord('10222211',1000);
  EnvoyerBord('10222221',1000);

  EnvoyerBord('02222122',900);
  EnvoyerBord('02221222',500);
  EnvoyerBord('02212222',100);
  EnvoyerBord('02122222',-300);

  EnvoyerBord('11211110',-950);
  EnvoyerBord('11121110',-900);
  EnvoyerBord('11112110',-850);
  EnvoyerBord('11111210',-800);


  EnvoyerBord('02200200',-100);
  EnvoyerBord('02002200',-100);
  EnvoyerBord('02002220',NoteBordDeSixAdv+300);
  EnvoyerBord('02200220',NoteBordDeSixAdv+300);
  EnvoyerBord('02002000',150);
  EnvoyerBord('02010220',NoteBordDeSixAdv+750);
  EnvoyerBord('02011020',NoteBordDeSixAdv+750);
  EnvoyerBord('01020110',NoteBordDeSixAmi-750);
  EnvoyerBord('01022010',NoteBordDeSixAmi-750);
  EnvoyerBord('01001100',100);
  EnvoyerBord('01100100',100);
  EnvoyerBord('01001110',NoteBordDeSixAmi-300);
  EnvoyerBord('01100110',NoteBordDeSixAmi-300);
  EnvoyerBord('01001200',100);
  EnvoyerBord('01201200',-1000);
  EnvoyerBord('01001000',-150);



  EnvoyerBord('11101000',400);
  EnvoyerBord('11110100',600);
  EnvoyerBord('22202000',-400);
  EnvoyerBord('22220200',-600);

  EnvoyerBord('01220200',-1000);
  EnvoyerBord('02110100',1000);

  EnvoyerBord('11210010',-800);
  EnvoyerBord('11210110',-800);
  EnvoyerBord('11211010',-800);
  EnvoyerBord('10010010',1000);
  EnvoyerBord('10010210',1000+valDefenseCoin);
  EnvoyerBord('10012010',1000);
  EnvoyerBord('10210010',1000);
  EnvoyerBord('12010010',1000);
  EnvoyerBord('11110010',1000);
  EnvoyerBord('11110210',1000+valDefenseCoin);
  EnvoyerBord('11112010',1000);
  EnvoyerBord('10010000',800);
  EnvoyerBord('12010000',800);
  EnvoyerBord('10210000',800);
  EnvoyerBord('10012000',800);
  EnvoyerBord('11001000',800);
  EnvoyerBord('11201000',800);
  EnvoyerBord('11001200',800);
  EnvoyerBord('12100000',-200);
  EnvoyerBord('12110000',-400);
  EnvoyerBord('12111000',-500);
  EnvoyerBord('12111100',-600);
  EnvoyerBord('12210010',-100);
  EnvoyerBord('12100100',-520);
  EnvoyerBord('12100101',-500);

  EnvoyerBord('22120020',600);
  EnvoyerBord('22120220',800);
  EnvoyerBord('22122020',800);
  EnvoyerBord('20020020',-1000);
  EnvoyerBord('20020000',-800);
  EnvoyerBord('22002000',-800);
  EnvoyerBord('22002100',-800);
  EnvoyerBord('21200000',200);
  EnvoyerBord('21220000',400);
  EnvoyerBord('21222000',500);
  EnvoyerBord('21222200',600);
  EnvoyerBord('21222220',600);
  EnvoyerBord('21120020',700);
  EnvoyerBord('21200200',520);
  EnvoyerBord('21200202',500);
  EnvoyerBord('20021000',-800);
  EnvoyerBord('22102000',100);


  EnvoyerBord('10100111',350);
  EnvoyerBord('20200222',-350);
  EnvoyerBord('12102220',300);
  EnvoyerBord('21201110',-300);

  EnvoyerBord('20211200',1200);
  EnvoyerBord('20221200',1200);
  EnvoyerBord('20212200',1200);

  EnvoyerBord('10122100',-500);
  EnvoyerBord('10121100',-500);
  EnvoyerBord('10112100',-500);

  EnvoyerBord('21020000',500);
  EnvoyerBord('21022000',500);
  EnvoyerBord('21022200',600);
  EnvoyerBord('21102000',700);
  EnvoyerBord('21102200',700);
  EnvoyerBord('21110200',700);
  EnvoyerBord('20120000',500);
  EnvoyerBord('20122000',600);
  EnvoyerBord('20122200',600);
  EnvoyerBord('20122220',800);
  EnvoyerBord('20120200',800);
  EnvoyerBord('20120220',800);
  EnvoyerBord('20122020',800);
  EnvoyerBord('20112000',600);
  EnvoyerBord('20112200',600);
  EnvoyerBord('20112220',800);
  EnvoyerBord('20120200',800);
  EnvoyerBord('20120220',800);
  EnvoyerBord('20111200',800);
  EnvoyerBord('20111220',800);
  EnvoyerBord('20111120',800);
  EnvoyerBord('20212000',1200);
  EnvoyerBord('20212200',1200);
  EnvoyerBord('20212220',900);
  EnvoyerBord('20211200',1200);
  EnvoyerBord('20221200',1200);
  EnvoyerBord('20211220',900);
  EnvoyerBord('20221220',900);
  EnvoyerBord('20211120',900);
  EnvoyerBord('20221120',900);
  EnvoyerBord('20222120',900);
  EnvoyerBord('21012000',600);
  EnvoyerBord('21012200',600);
  EnvoyerBord('21012220',600);
  EnvoyerBord('21011200',600);
  EnvoyerBord('21011220',600);
  EnvoyerBord('21021200',1000);
  EnvoyerBord('21021220',800);
  EnvoyerBord('21011120',600);
  EnvoyerBord('21021120',900);
  EnvoyerBord('21022120',900);
  EnvoyerBord('21101200',700);
  EnvoyerBord('21101220',700);
  EnvoyerBord('21201200',900);
  EnvoyerBord('21101120',1000);
  EnvoyerBord('21110120',1000);
  EnvoyerBord('21102120',1000);
  EnvoyerBord('21120120',1000);
  EnvoyerBord('21120220',1000);
end;

procedure noter_bords_6;
begin
  EnvoyerBord('21120000',1100);
  EnvoyerBord('21122000',1100);
  EnvoyerBord('21122200',1100);
  EnvoyerBord('21122220',600);
  EnvoyerBord('21112000',1100);
  EnvoyerBord('21112200',1100);
  EnvoyerBord('21112220',600);
  EnvoyerBord('21111200',1100);
  EnvoyerBord('21111220',600);
  EnvoyerBord('21111120',600);

  EnvoyerBord('12111110',-500);
  EnvoyerBord('12210000',-1100);
  EnvoyerBord('12211000',-1100);
  EnvoyerBord('12211100',-1100);
  EnvoyerBord('12211110',-500);
  EnvoyerBord('12221000',-1100);
  EnvoyerBord('12221100',-1100);
  EnvoyerBord('12221110',-500);
  EnvoyerBord('12222100',-1100);
  EnvoyerBord('12222110',-500);
  EnvoyerBord('12222210',-500);

  EnvoyerBord('10222200',1000);
  EnvoyerBord('10222220',100);
  EnvoyerBord('11022220',1000);
  EnvoyerBord('11102220',1000);
  EnvoyerBord('11110220',1000);
  EnvoyerBord('10010220',1000);
  EnvoyerBord('11111020',1000);
  EnvoyerBord('11001020',1000);
  EnvoyerBord('10011020',1000);
  EnvoyerBord('20111100',-1000);
  EnvoyerBord('20111110',-1000);
  EnvoyerBord('22011110',-1000);
  EnvoyerBord('22201110',-1000);
  EnvoyerBord('22220110',-1000);
  EnvoyerBord('20020110',-1000);
  EnvoyerBord('22222010',-1000);
  EnvoyerBord('20022010',-1000);
  EnvoyerBord('22002010',-1000);

  EnvoyerBord('12022200',1000);
  EnvoyerBord('12022220',1000);
  EnvoyerBord('11202220',1000);
  EnvoyerBord('11120220',1000);
  EnvoyerBord('11112020',1000);
  EnvoyerBord('21011100',-1000);
  EnvoyerBord('21011110',-1000);
  EnvoyerBord('22101110',-1000);
  EnvoyerBord('22210110',-1000);

  EnvoyerBord('20200020',1000);
  EnvoyerBord('20200220',1000);
  EnvoyerBord('20202020',1000);
  EnvoyerBord('20220020',1000);
  EnvoyerBord('20220220',1000);
  EnvoyerBord('21200020',1000);
  EnvoyerBord('21200220',1000);
  EnvoyerBord('21202020',1000);
  EnvoyerBord('21220020',1000);
  EnvoyerBord('21220220',1000);
  EnvoyerBord('21200120',1000);
  EnvoyerBord('21201120',1000);
  EnvoyerBord('21201020',1000);
  EnvoyerBord('21201220',1000);
  EnvoyerBord('21202120',1000);
  EnvoyerBord('21220120',1000);
  EnvoyerBord('20021111',1000);
  EnvoyerBord('20022111',1000);
  EnvoyerBord('20022211',1000);
  EnvoyerBord('20020021',1000);
  EnvoyerBord('20200021',1000);
  EnvoyerBord('20200221',1000);
  EnvoyerBord('20200211',1000);
  EnvoyerBord('20202021',1000);
  EnvoyerBord('20220021',1000);
  EnvoyerBord('20220221',1000);
  EnvoyerBord('20220211',1000);
  EnvoyerBord('20200111',1000);
  EnvoyerBord('20220111',1000);
  EnvoyerBord('20202111',1000);
  EnvoyerBord('20201111',1000);
  EnvoyerBord('21200021',1000);
  EnvoyerBord('21200221',1000);
  EnvoyerBord('21200211',1000);
  EnvoyerBord('21202021',1000);
  EnvoyerBord('21220021',1000);
  EnvoyerBord('21220221',1300);
  EnvoyerBord('21220211',1300);
  EnvoyerBord('21200111',1300);
  EnvoyerBord('21220111',1300);
  EnvoyerBord('21202111',1300);
  EnvoyerBord('21201111',1300);
  EnvoyerBord('10012222',-1000);
  EnvoyerBord('10011222',-1000);
  EnvoyerBord('10011122',-1000);
  EnvoyerBord('10011112',-1000);
  EnvoyerBord('10100010',-1000);
  EnvoyerBord('10100110',-1000);
  EnvoyerBord('10101010',-1000);
  EnvoyerBord('10110010',-1000);
  EnvoyerBord('10110110',-1000);
  EnvoyerBord('12100010',-1000);
  EnvoyerBord('12100110',-1000);
  EnvoyerBord('12101010',-1000);
  EnvoyerBord('12110010',-1000);
  EnvoyerBord('12110110',-1000);
  EnvoyerBord('12100210',-1000);
  EnvoyerBord('12102210',-1000);
  EnvoyerBord('12102010',-1000);
  EnvoyerBord('12102110',-1000);
  EnvoyerBord('12101210',-1000);
  EnvoyerBord('12110210',-1000);
  EnvoyerBord('10110012',-1000);
  EnvoyerBord('10100112',-1000);
  EnvoyerBord('10100122',-1000);
  EnvoyerBord('10101012',-1000);
  EnvoyerBord('10110012',-1000);
  EnvoyerBord('10110112',-1000);
  EnvoyerBord('10110122',-1000);
  EnvoyerBord('10100222',-1000);
  EnvoyerBord('10110222',-1000);
  EnvoyerBord('10101222',-1000);
  EnvoyerBord('10102222',-1000);
  EnvoyerBord('12100012',-1000);
  EnvoyerBord('12100112',-1000);
  EnvoyerBord('12100122',-1000);
  EnvoyerBord('12101012',-1000);
  EnvoyerBord('12110012',-1000);
  EnvoyerBord('12110112',-1000);
  EnvoyerBord('12110122',-1300);
  EnvoyerBord('12100222',-1000);
  EnvoyerBord('12110222',-1300);
  EnvoyerBord('12101222',-1300);
  EnvoyerBord('12102222',-1300);


  EnvoyerBord('20211111',1300);
  EnvoyerBord('20221111',1300);
  EnvoyerBord('20222111',1300);
  EnvoyerBord('20222211',1300);
  EnvoyerBord('20222221',1300);
  EnvoyerBord('21021111',1300);
  EnvoyerBord('21022111',1300);
  EnvoyerBord('21022211',1300);
  EnvoyerBord('21022221',1300);
  EnvoyerBord('21102111',1300);
  EnvoyerBord('21102211',1300);
  EnvoyerBord('21102221',1300);
  EnvoyerBord('21201111',1300);
  EnvoyerBord('21202111',1300);
  EnvoyerBord('21202211',1300);
  EnvoyerBord('21202221',1300);
  EnvoyerBord('21110211',1300);
  EnvoyerBord('21110221',1300);
  EnvoyerBord('21120111',1300);
  EnvoyerBord('21120211',1300);
  EnvoyerBord('21120221',1300);
  EnvoyerBord('21220111',1300);
  EnvoyerBord('21220211',1300);
  EnvoyerBord('21222021',1300);
  EnvoyerBord('21122021',1300);
  EnvoyerBord('21112021',1300);
  EnvoyerBord('21111021',1300);
  EnvoyerBord('21112011',1300);
  EnvoyerBord('21122011',1300);
  EnvoyerBord('21222011',1300);
  EnvoyerBord('21222201',1300);
  EnvoyerBord('21122201',1300);
  EnvoyerBord('21112201',1300);
  EnvoyerBord('21111201',1300);
end;

procedure noter_bords_7;
begin
  EnvoyerBord('10122222',-1000);
  EnvoyerBord('10112222',-1000);
  EnvoyerBord('10111222',-1000);
  EnvoyerBord('10111122',-1000);
  EnvoyerBord('10111112',-1000);
  EnvoyerBord('12101122',-1000);
  EnvoyerBord('12101112',-1000);
  EnvoyerBord('12210122',-1000);
  EnvoyerBord('12210112',-1000);
  EnvoyerBord('12111012',-1000);
  EnvoyerBord('12211012',-1000);
  EnvoyerBord('12221012',-1000);
  EnvoyerBord('12221022',-1000);
  EnvoyerBord('12211022',-1000);
  EnvoyerBord('12111022',-1000);
  EnvoyerBord('12111102',300);
  EnvoyerBord('12211102',-1000);
  EnvoyerBord('12221102',-1000);
  EnvoyerBord('12222102',-1000);


  EnvoyerBord('20122100',500);
  EnvoyerBord('20121100',500);
  EnvoyerBord('20112100',500);
  EnvoyerBord('10211200',800); {arnaque...}
  EnvoyerBord('10212200',800);
  EnvoyerBord('10221200',800);
  EnvoyerBord('10211100',800); {arnaque...}
  EnvoyerBord('10211100',800);
  EnvoyerBord('10221100',800);
  EnvoyerBord('11021100',800);
  EnvoyerBord('11022100',800);
  EnvoyerBord('11201100',800);
  EnvoyerBord('11220100',800);
  EnvoyerBord('11202100',800);
  EnvoyerBord('12021100',800);
  EnvoyerBord('12022100',800);
  EnvoyerBord('12201100',800);
  EnvoyerBord('12220100',800);
  EnvoyerBord('12202100',800);

  EnvoyerBord('10011110',950);
  EnvoyerBord('11001110',950);
  EnvoyerBord('11100110',950);
  EnvoyerBord('11110010',1000);
  EnvoyerBord('20022220',-950);
  EnvoyerBord('22002220',-950);
  EnvoyerBord('22200220',-950);
  EnvoyerBord('22220020',-1000);
  EnvoyerBord('10011100',550);
  EnvoyerBord('11001100',650);
  EnvoyerBord('11100100',750);
  EnvoyerBord('20022200',-550);
  EnvoyerBord('22002200',-650);
  EnvoyerBord('22200200',-750);


  EnvoyerBord('10211110',valDefenseCoin+1000);
  EnvoyerBord('10221110',valDefenseCoin+1000);
  EnvoyerBord('10222110',valDefenseCoin+1000);
  EnvoyerBord('10222210',valDefenseCoin+1000);
  EnvoyerBord('11021110',valDefenseCoin+1000);
  EnvoyerBord('11022110',valDefenseCoin+1000);
  EnvoyerBord('11022210',valDefenseCoin+1000);
  EnvoyerBord('11102110',valDefenseCoin+1000);
  EnvoyerBord('11110210',valDefenseCoin+1000);



  EnvoyerBord('12111200',-600);
  EnvoyerBord('12211200',-600);
  EnvoyerBord('12221200',-600);
  EnvoyerBord('12112200',-600);
  EnvoyerBord('12212200',-600);
  EnvoyerBord('12100200',-200);
  EnvoyerBord('12110200',-200);
  EnvoyerBord('12101200',-200);
  EnvoyerBord('12210200',-200);
  EnvoyerBord('12102200',-200);
  EnvoyerBord('10100200',-100);
  EnvoyerBord('10110200',-200);
  EnvoyerBord('10101200',-500);
  EnvoyerBord('10102200',-200);
  EnvoyerBord('12112000',-300);
  EnvoyerBord('12212000',-300);
  EnvoyerBord('12102000',-100);

  EnvoyerBord('21222100',600);
  EnvoyerBord('21122100',600);
  EnvoyerBord('21112100',600);
  EnvoyerBord('21221100',600);
  EnvoyerBord('21121100',600);
  EnvoyerBord('21200100',200);
  EnvoyerBord('21220100',200);
  EnvoyerBord('21202100',200);
  EnvoyerBord('21120100',200);
  EnvoyerBord('21201100',200);
  EnvoyerBord('20200100',100);
  EnvoyerBord('20220100',300);
  EnvoyerBord('20202100',500);
  EnvoyerBord('20120100',300);
  EnvoyerBord('20201100',200);
  EnvoyerBord('21221000',600);
  EnvoyerBord('21121000',600);
  EnvoyerBord('21201000',-100);
  EnvoyerBord('20201000',-300);

  EnvoyerBord('11110200',1000);
  EnvoyerBord('11110220',1000);
  EnvoyerBord('11102000',1000);
  EnvoyerBord('11102200',1000);
  EnvoyerBord('11102220',1000);
  EnvoyerBord('11020000',1000);
  EnvoyerBord('11022000',1000);
  EnvoyerBord('11022200',1000);
  EnvoyerBord('11022220',1000);
  EnvoyerBord('22220100',-1000);
  EnvoyerBord('22220110',-1000);
  EnvoyerBord('22201000',-1000);
  EnvoyerBord('22201100',-1000);
  EnvoyerBord('22201110',-1000);
  EnvoyerBord('22010000',-1000);
  EnvoyerBord('22011000',-1000);
  EnvoyerBord('22011100',-1000);
  EnvoyerBord('22011110',-1000);

  EnvoyerBord('01020222',-1000);
  EnvoyerBord('01102022',-1000);
  EnvoyerBord('01110202',-1000);
  EnvoyerBord('02010111',1000);
  EnvoyerBord('02201011',1000);
  EnvoyerBord('02220101',1000);



end;

procedure noter_bords_8;
begin
  EnvoyerBord('20220000',900);
  EnvoyerBord('22020000',400);
  EnvoyerBord('20222000',900);
  EnvoyerBord('22022000',400);
  EnvoyerBord('20022212',400);
  EnvoyerBord('20022112',400);
  EnvoyerBord('20021112',400);
  EnvoyerBord('22002212',400);
  EnvoyerBord('22002112',400);

  EnvoyerBord('10110000',-20);
  EnvoyerBord('11010000',-200);
  EnvoyerBord('10111000',-20);
  EnvoyerBord('11011000',-200);
  EnvoyerBord('10011121',-600);
  EnvoyerBord('10011221',-600);
  EnvoyerBord('10012221',-600);
  EnvoyerBord('11001121',-600);
  EnvoyerBord('11001221',-600);

  EnvoyerBord('20000010',-800);
  EnvoyerBord('20000210',-1000);
  EnvoyerBord('20000110',-1000);
  EnvoyerBord('20002110',-1000);
  EnvoyerBord('20011110',-1000);
  EnvoyerBord('20211110',-1000);
  EnvoyerBord('20001110',-1000);
  EnvoyerBord('20021110',-1000);
  EnvoyerBord('20111110',-1000);
  EnvoyerBord('21000010',-1000);
  EnvoyerBord('21000210',-1000);
  EnvoyerBord('21000110',-1000);
  EnvoyerBord('21002110',-1000);
  EnvoyerBord('21011110',-1000);
  EnvoyerBord('21001110',-1000);
  EnvoyerBord('21021110',-1000);
  EnvoyerBord('20100010',-1000);
  EnvoyerBord('20100210',-1000);
  EnvoyerBord('20100110',-1000);
  EnvoyerBord('20102110',-1000);
  EnvoyerBord('20011110',-1000);
  EnvoyerBord('20211110',-1000);
  EnvoyerBord('20101110',-1000);
  EnvoyerBord('20021110',-1000);
  EnvoyerBord('20111110',-1000);

  EnvoyerBord('10000020',800);
  EnvoyerBord('10000120',1000);
  EnvoyerBord('10000220',1000);
  EnvoyerBord('10001220',1000);
  EnvoyerBord('10022220',1000);
  EnvoyerBord('10122220',1000);
  EnvoyerBord('10002220',1000);
  EnvoyerBord('10012220',1000);
  EnvoyerBord('10222220',100);
  EnvoyerBord('12000020',1000);
  EnvoyerBord('12000120',1000);
  EnvoyerBord('12000220',1000);
  EnvoyerBord('12001220',1000);
  EnvoyerBord('12022220',1000);
  EnvoyerBord('12002220',1000);
  EnvoyerBord('12012220',1000);
  EnvoyerBord('10200020',1000);
  EnvoyerBord('10200120',1000);
  EnvoyerBord('10200220',1000);
  EnvoyerBord('10201220',1000);
  EnvoyerBord('10022220',1000);
  EnvoyerBord('10122220',1000);
  EnvoyerBord('10202220',1000);
  EnvoyerBord('10012220',1000);
  EnvoyerBord('10222220',100);


  EnvoyerBord('10011000',300);
  EnvoyerBord('20022000',-300);

  EnvoyerBord('22120200',500);
  EnvoyerBord('22120220',800);
  EnvoyerBord('22120120',800);
  EnvoyerBord('21120200',1000);
  EnvoyerBord('21120220',1000);
  EnvoyerBord('21120120',1000);
  EnvoyerBord('21220200',800);
  EnvoyerBord('11210100',-500);
  EnvoyerBord('11210110',-800);
  EnvoyerBord('11210210',-800);
  EnvoyerBord('12210100',-1000);
  EnvoyerBord('12210110',-1000);
  EnvoyerBord('12210210',-1000);
  EnvoyerBord('12110100',-500);


  EnvoyerBord('22120201',500);
  EnvoyerBord('22120221',800);
  EnvoyerBord('22120121',800);
  EnvoyerBord('21120201',1000);
  EnvoyerBord('21120121',1000);
  EnvoyerBord('21220201',800);
  EnvoyerBord('21220121',1000);
  EnvoyerBord('11210102',-500);
  EnvoyerBord('11210112',-800);
  EnvoyerBord('11210212',-800);
  EnvoyerBord('12210102',-1000);
  EnvoyerBord('12210112',-1000);
  EnvoyerBord('12210212',-1000);
  EnvoyerBord('12110102',-500);
  EnvoyerBord('12110212',-1000);

  EnvoyerBord('10201110',300);
  EnvoyerBord('10220110',300);
  EnvoyerBord('10222010',300);
  EnvoyerBord('20102220',-300);
  EnvoyerBord('20110220',-300);
  EnvoyerBord('20111020',-300);
  EnvoyerBord('11020110',400);
  EnvoyerBord('11022010',400);
  EnvoyerBord('22010220',-400);
  EnvoyerBord('22011020',-400);
  EnvoyerBord('11102010',600);
  EnvoyerBord('22201020',-600);

  EnvoyerBord('22111112',1200);
  EnvoyerBord('22211112',1100);
  EnvoyerBord('21221112',1100);
  EnvoyerBord('22111122',1000);
  EnvoyerBord('22221112',700);
  EnvoyerBord('22211122',700);
  EnvoyerBord('21222112',700);

  EnvoyerBord('22122202',1200);
  EnvoyerBord('22112202',1200);
  EnvoyerBord('22111202',1200);
  EnvoyerBord('22022212',1200);
  EnvoyerBord('22022112',1200);
  EnvoyerBord('22021112',1200);
  EnvoyerBord('22122012',1200);
  EnvoyerBord('22112012',1200);
  EnvoyerBord('22120212',1200);
  EnvoyerBord('22110212',1200);
  EnvoyerBord('22120112',1200);
  EnvoyerBord('22102212',1200);
  EnvoyerBord('22102112',1200);
  EnvoyerBord('22212202',1100);
  EnvoyerBord('22202212',1100);
  EnvoyerBord('22211202',1100);
  EnvoyerBord('22212012',1100);
  EnvoyerBord('22210212',1100);
  EnvoyerBord('22122022',1000);
  EnvoyerBord('22022122',1000);
  EnvoyerBord('22120122',1000);
  EnvoyerBord('22102122',1000);
  EnvoyerBord('22221202',500);
  EnvoyerBord('22220212',500);
  EnvoyerBord('22212022',500);
  EnvoyerBord('22202122',500);

  EnvoyerBord('11222221',-1200);
  EnvoyerBord('11122221',-1100);
  EnvoyerBord('12112221',-1100);
  EnvoyerBord('11222211',-1000);
  EnvoyerBord('11112221',-500);
  EnvoyerBord('11122211',-500);
  EnvoyerBord('12111221',-500);

  EnvoyerBord('11211101',-800);
  EnvoyerBord('11221101',-800);
  EnvoyerBord('11222101',-800);
  EnvoyerBord('11011121',-800);
  EnvoyerBord('11011221',-800);
  EnvoyerBord('11012221',-800);
  EnvoyerBord('11211021',-800);
  EnvoyerBord('11221021',-800);
  EnvoyerBord('11210121',-800);
  EnvoyerBord('11220121',-800);
  EnvoyerBord('11210221',-800);
  EnvoyerBord('11201121',-800);
  EnvoyerBord('11201221',-800);
  EnvoyerBord('11121101',-700);
  EnvoyerBord('11101121',-700);
  EnvoyerBord('11122101',-700);
  EnvoyerBord('11121021',-700);
  EnvoyerBord('11120121',-700);
  EnvoyerBord('11211011',-650);
  EnvoyerBord('11011211',-650);
  EnvoyerBord('11210211',-650);
  EnvoyerBord('11201211',-650);
  EnvoyerBord('11112101',-350);
  EnvoyerBord('11110121',-350);
  EnvoyerBord('11121011',-350);
  EnvoyerBord('11101211',-350);
end;


procedure noter_Bords_9;
begin

EnvoyerBord('10001100',-300);
  EnvoyerBord('20002200',300);
  EnvoyerBord('11000100',-300);
  EnvoyerBord('00200022',300);

  EnvoyerBord('10200002',400);
  EnvoyerBord('10200022',400);
  EnvoyerBord('10220002',400);
  EnvoyerBord('10202002',400);
  EnvoyerBord('10220000',500);
  EnvoyerBord('10202000',600);
  EnvoyerBord('10222002',400);
  EnvoyerBord('10222000',600);
  EnvoyerBord('10220022',400);
  EnvoyerBord('10200002',400);
  EnvoyerBord('10200022',400);
  EnvoyerBord('10210002',900);
  EnvoyerBord('10212002',900);
  EnvoyerBord('10212000',900);
  EnvoyerBord('10221000',900);
  EnvoyerBord('10221002',900);
  EnvoyerBord('10210022',900);

  EnvoyerBord('20100001',-400);
  EnvoyerBord('20100011',-400);
  EnvoyerBord('20110001',-400);
  EnvoyerBord('20101000',-600);
  EnvoyerBord('20101001',-400);
  EnvoyerBord('20110000',-500);
  EnvoyerBord('20111001',-400);
  EnvoyerBord('20111000',-600);
  EnvoyerBord('20110011',-400);
  EnvoyerBord('20100001',-400);
  EnvoyerBord('20100011',-400);
  EnvoyerBord('20120001',-500);
  EnvoyerBord('20121001',-500);
  EnvoyerBord('20121000',-500);
  EnvoyerBord('20112001',-500);
  EnvoyerBord('20120011',-500);

  EnvoyerBord('21222020',1000);
  EnvoyerBord('21202020',1000);
  EnvoyerBord('21122020',1000);
  EnvoyerBord('21112020',1000);
  EnvoyerBord('21120220',1000);
  EnvoyerBord('21202220',1000);
  EnvoyerBord('21120120',1000);
  EnvoyerBord('12111010',-1000);
  EnvoyerBord('12101010',-1000);
  EnvoyerBord('12211010',-1000);
  EnvoyerBord('12221010',-1000);
  EnvoyerBord('12210110',-1000);
  EnvoyerBord('12101110',-1000);
  EnvoyerBord('12210210',-1000);

  EnvoyerBord('10211020',1000);
  EnvoyerBord('10221020',1000);
  EnvoyerBord('10212020',1000);
  EnvoyerBord('10210120',1000);
  EnvoyerBord('10210220',1000);
  EnvoyerBord('10210200',1000);
  EnvoyerBord('20122010',-1000);
  EnvoyerBord('20112010',-1000);
  EnvoyerBord('20121010',-1000);
  EnvoyerBord('20120210',-1000);
  EnvoyerBord('20120110',-1000);

  EnvoyerBord('10020200',600);
  EnvoyerBord('10021200',600);
  EnvoyerBord('12020200',900);
  EnvoyerBord('12021200',900);
  EnvoyerBord('20010100',-600);
  EnvoyerBord('20012100',-600);
  EnvoyerBord('21010100',-900);
  EnvoyerBord('21012100',-900);

  EnvoyerBord('10101000',-100);
  EnvoyerBord('10101002',-100);
  EnvoyerBord('10101100',-100);
  EnvoyerBord('10101102',-100);
  EnvoyerBord('10110100',-100);
  EnvoyerBord('10110102',-100);
  EnvoyerBord('20202001',100);
  EnvoyerBord('20202000',100);
  EnvoyerBord('20202201',100);
  EnvoyerBord('20202200',100);
  EnvoyerBord('20220201',100);
  EnvoyerBord('20220200',100);

  EnvoyerBord('11100020',850);
  EnvoyerBord('12110020',850);
  EnvoyerBord('21220010',-850);

  EnvoyerBord('10021020',1000);
  EnvoyerBord('12021020',1000);
  EnvoyerBord('10221020',1000);
  EnvoyerBord('12201020',1000);
  EnvoyerBord('11021020',1000);
  EnvoyerBord('12201020',1000);
  EnvoyerBord('10211020',1000);
  EnvoyerBord('10212020',1000);
  EnvoyerBord('20012010',-1000);
  EnvoyerBord('21012010',-1000);
  EnvoyerBord('20112010',-1000);
  EnvoyerBord('21102010',-1000);
  EnvoyerBord('22012010',-1000);
  EnvoyerBord('21102010',-1000);
  EnvoyerBord('20122010',-1000);
  EnvoyerBord('20121010',-1000);

  EnvoyerBord('10101010',-1000);
  EnvoyerBord('10111010',-1000);
  EnvoyerBord('10110110',-1000);
  EnvoyerBord('10101110',-1000);
  EnvoyerBord('11011010',-1000);
  EnvoyerBord('11010110',-1000);
  EnvoyerBord('11101010',-1000);
  EnvoyerBord('20202020',1000);
  EnvoyerBord('20222020',1000);
  EnvoyerBord('20220220',1000);
  EnvoyerBord('20202220',1000);
  EnvoyerBord('22022020',1000);
  EnvoyerBord('22020220',1000);
  EnvoyerBord('22202020',1000);

  EnvoyerBord('21222222',-1400);
  EnvoyerBord('22122222',-1400);
  EnvoyerBord('21122222',-1000);
  EnvoyerBord('22212222',-1400);
  EnvoyerBord('12212222',-1000);
  EnvoyerBord('22112222',-1000);
  EnvoyerBord('12112222',-550);
  EnvoyerBord('11112222',1);
  EnvoyerBord('12221222',-1000);
  EnvoyerBord('11221222',-550);
  EnvoyerBord('22211222',-1000);
  EnvoyerBord('12211222',-550);
  EnvoyerBord('11211222',1);
  EnvoyerBord('12222122',-1000);
  EnvoyerBord('21222122',-1000);
  EnvoyerBord('11222122',-550);
  EnvoyerBord('21122122',-550);
  EnvoyerBord('11122122',1);
  EnvoyerBord('12221122',-550);
  EnvoyerBord('21221122',-550);
  EnvoyerBord('11221122',1);
  EnvoyerBord('21121122',1);
  EnvoyerBord('11121122',550);
  EnvoyerBord('12211122',1);
  EnvoyerBord('11211122',550);
  EnvoyerBord('21222212',-1000);
  EnvoyerBord('12112212',1);
  EnvoyerBord('11112212',550);
  EnvoyerBord('12222112',-550);
  EnvoyerBord('11222112',1);
  EnvoyerBord('21122112',1);
  EnvoyerBord('11122112',550);
  EnvoyerBord('21112112',950);
  EnvoyerBord('11112112',1000);
  EnvoyerBord('12221112',1);
  EnvoyerBord('11221112',550);
  EnvoyerBord('11121112',1000);
  EnvoyerBord('12211112',550);
  EnvoyerBord('11211112',1000);
  EnvoyerBord('12212221',-950);
  EnvoyerBord('11221221',1);
  EnvoyerBord('12211221',1);
  EnvoyerBord('11211221',550);
  EnvoyerBord('11111221',1000);
  EnvoyerBord('11221121',550);
  EnvoyerBord('11211121',1000);
  EnvoyerBord('12111121',1000);
  EnvoyerBord('11111121',1400);
  EnvoyerBord('11112211',1000);
  EnvoyerBord('11111211',1400);
  EnvoyerBord('11122111',1000);
  EnvoyerBord('11112111',1400);

  EnvoyerBord('22022222',-1300);
  EnvoyerBord('12022222',-500);
  EnvoyerBord('21022222',-1100);
  EnvoyerBord('11022222',-800);
  EnvoyerBord('22202222',-1300);
  EnvoyerBord('12202222',-20);
  EnvoyerBord('11202222',-10);
  EnvoyerBord('22102222',-1100);
  EnvoyerBord('21102222',-800);
  EnvoyerBord('11102222',-200);
  EnvoyerBord('10212222',-20);
  EnvoyerBord('12012222',-20);
  EnvoyerBord('11012222',-200);
  EnvoyerBord('02112222',-20);
  EnvoyerBord('12220222',500);
  EnvoyerBord('11220222',510);
  EnvoyerBord('21120222',200);
  EnvoyerBord('11120222',540);
  EnvoyerBord('22210222',-1100);
  EnvoyerBord('12210222',-800);
  EnvoyerBord('11210222',-800);
  EnvoyerBord('22110222',-800);
  EnvoyerBord('21110222',-200);
  EnvoyerBord('11110222',200);
  EnvoyerBord('10221222',520);
  EnvoyerBord('01221222',-800);
  EnvoyerBord('12021222',800);
  EnvoyerBord('11021222',540);
  EnvoyerBord('12201222',540);
  EnvoyerBord('11201222',540);
  EnvoyerBord('11101222',100);
  EnvoyerBord('02211222',540);
  EnvoyerBord('10211222',540);
  EnvoyerBord('01211222',-400);
  EnvoyerBord('12011222',540);
  EnvoyerBord('11011222',-100);
  EnvoyerBord('02111222',540);
  EnvoyerBord('12222022',1000);
  EnvoyerBord('11222022',1000);
  EnvoyerBord('11122022',1000);
  EnvoyerBord('12212022',100);
  EnvoyerBord('22112022',100);
  EnvoyerBord('12112022',500);
  EnvoyerBord('11112022',1000);
  EnvoyerBord('21221022',-800);
  EnvoyerBord('11221022',-300);
  EnvoyerBord('21121022',-300);
  EnvoyerBord('11121022',400);
  EnvoyerBord('11211022',-100);
  EnvoyerBord('11111022',700);
  EnvoyerBord('10222122',1000);
  EnvoyerBord('01222122',-1500);
  EnvoyerBord('12022122',1000);
  EnvoyerBord('11022122',1000);
  EnvoyerBord('20122122',-1300);
  EnvoyerBord('10122122',-700);
  EnvoyerBord('01122122',-300);
  EnvoyerBord('11202122',1000);
  EnvoyerBord('11102122',1000);
  EnvoyerBord('12220122',1000);
  EnvoyerBord('11220122',1000);
  EnvoyerBord('11120122',1000);
  EnvoyerBord('11210122',-400);
  EnvoyerBord('11110122',300);
  EnvoyerBord('02221122',1000);
  EnvoyerBord('10221122',1000);
  EnvoyerBord('01221122',-800);
  EnvoyerBord('12021122',1000);
  EnvoyerBord('11021122',1000);
  EnvoyerBord('20121122',-800);
  EnvoyerBord('10121122',-700);
  EnvoyerBord('01121122',-400);
  EnvoyerBord('12201122',1000);
  EnvoyerBord('11201122',1000);
  EnvoyerBord('11101122',-300);
  EnvoyerBord('02211122',900);
  EnvoyerBord('10211122',1000);
  EnvoyerBord('01211122',-300);
  EnvoyerBord('12011122',1000);
  EnvoyerBord('11011122',-800);
  EnvoyerBord('02111122',900);
  EnvoyerBord('12212202',700);
  EnvoyerBord('12112202',1100);
  EnvoyerBord('12221202',200);
  EnvoyerBord('11221202',600);
  EnvoyerBord('12211202',600);
  EnvoyerBord('11211202',1000);
  EnvoyerBord('12111202',1000);
  EnvoyerBord('21222102',-700);
  EnvoyerBord('11222102',-100);
  EnvoyerBord('21122102',-100);
  EnvoyerBord('11122102',100);
  EnvoyerBord('21112102',100);
  EnvoyerBord('11112102',500);
  EnvoyerBord('21221102',-300);
  EnvoyerBord('11221102',100);
  EnvoyerBord('21121102',100);
  EnvoyerBord('11121102',300);
  EnvoyerBord('11211102',200);
  EnvoyerBord('01222212',-900);
  EnvoyerBord('02122212',1);
  EnvoyerBord('10122212',-900);
  EnvoyerBord('01122212',-1500);
  EnvoyerBord('12012212',500);
  EnvoyerBord('21012212',-1200);
  EnvoyerBord('11012212',-100);
  EnvoyerBord('02112212',550);
  EnvoyerBord('10112212',-1100);
  EnvoyerBord('01112212',-1300);
  EnvoyerBord('12212012',550);
  EnvoyerBord('12112012',1000);
  EnvoyerBord('11221012',-500);
  EnvoyerBord('21121012',-500);
  EnvoyerBord('11121012',-300);
  EnvoyerBord('11211012',-500);
  EnvoyerBord('11111012',900);
  EnvoyerBord('01222112',-900);
  EnvoyerBord('02122112',1);
  EnvoyerBord('10122112',-100);
  EnvoyerBord('01122112',-900);
  EnvoyerBord('12012112',1000);
  EnvoyerBord('11012112',-300);
  EnvoyerBord('02112112',500);
  EnvoyerBord('10112112',-800);
  EnvoyerBord('01112112',-900);
  EnvoyerBord('11110112',300);
  EnvoyerBord('01221112',-600);
  EnvoyerBord('10121112',-100);
  EnvoyerBord('01121112',-600);
  EnvoyerBord('11101112',-300);
  EnvoyerBord('01211112',-100);
  EnvoyerBord('11011112',-800);
  EnvoyerBord('12212220',1000);
  EnvoyerBord('12112220',1000);
  EnvoyerBord('11112220',1000);
  EnvoyerBord('12221220',500);
  EnvoyerBord('11221220',1000);
  EnvoyerBord('12211220',1000);
  EnvoyerBord('11211220',1300);
  EnvoyerBord('12111220',1300);
  EnvoyerBord('11111220',1000);
  EnvoyerBord('12222120',-200);
  EnvoyerBord('11222120',-100);
  EnvoyerBord('11122120',-50);
  EnvoyerBord('12221120',-100);
  EnvoyerBord('11221120',-100);
  EnvoyerBord('11121120',500);
  EnvoyerBord('12211120',-50);
  EnvoyerBord('11211120',500);
  EnvoyerBord('12111120',500);
  EnvoyerBord('11222210',-550);
  EnvoyerBord('11122210',-550);
  EnvoyerBord('11112210',-550);
  EnvoyerBord('12212210',-1000);
  EnvoyerBord('12112210',-500);
  EnvoyerBord('12211210',-500);
  EnvoyerBord('12111210',-550);
  EnvoyerBord('11222110',-550);
  EnvoyerBord('11122110',-550);
  EnvoyerBord('11221110',-1000);

  EnvoyerBord('12022221',1200);
  EnvoyerBord('11022221',1200);
  EnvoyerBord('12202221',1200);
  EnvoyerBord('11202221',1200);
  EnvoyerBord('11102221',1200);
  EnvoyerBord('11220221',1200);
  EnvoyerBord('11120221',1200);
  EnvoyerBord('11110221',1200);
  EnvoyerBord('10212221',550);
  EnvoyerBord('10221221',1000);
  EnvoyerBord('12021221',1000);
  EnvoyerBord('11021221',1000);
  EnvoyerBord('10211221',1000);
  EnvoyerBord('11222021',1200);
  EnvoyerBord('11122021',1200);
  EnvoyerBord('12112021',1200);
  EnvoyerBord('11112021',1200);
  EnvoyerBord('11111021',1200);
  EnvoyerBord('10221121',1200);
  EnvoyerBord('11021121',1200);
  EnvoyerBord('10211121',1200);
  EnvoyerBord('11221201',1000);
  EnvoyerBord('11211201',1200);
  EnvoyerBord('11022211',1200);
  EnvoyerBord('11202211',1200);
  EnvoyerBord('11102211',1200);
  EnvoyerBord('11120211',1200);
  EnvoyerBord('11110211',1200);
  EnvoyerBord('11122011',1200);
  EnvoyerBord('11112011',1200);
  EnvoyerBord('11102111',1200);
  EnvoyerBord('11101221',500);
  EnvoyerBord('11012211',500);

  EnvoyerBord('01012212',-1000);
  EnvoyerBord('01012112',-1000);
  EnvoyerBord('01010222',-1000);
  EnvoyerBord('01012022',-1000);
  EnvoyerBord('01011022',-1000);
  EnvoyerBord('01010122',-1000);
  EnvoyerBord('01012202',-1000);
  EnvoyerBord('01011202',-1000);
  EnvoyerBord('01011102',-1000);
  EnvoyerBord('01010212',-1000);
  EnvoyerBord('01012012',-1000);
  EnvoyerBord('01011012',-1000);
  EnvoyerBord('01010112',-1000);
  EnvoyerBord('01011210',-1000);
  EnvoyerBord('01010022',-1000);
  EnvoyerBord('01010202',-1000);
  EnvoyerBord('01012002',-1000);
  EnvoyerBord('01011002',-1000);
  EnvoyerBord('01010102',-1000);
  EnvoyerBord('01010012',-1000);
  EnvoyerBord('01012020',-1000);
  EnvoyerBord('01010120',-1000);
  EnvoyerBord('01010002',-1000);
  EnvoyerBord('11221010',-1000);
  EnvoyerBord('11121010',-1000);
  EnvoyerBord('10221010',-500);
  EnvoyerBord('12021010',-500);
  EnvoyerBord('11021010',-500);
  EnvoyerBord('10121010',-1000);
  EnvoyerBord('01121010',-1000);
  EnvoyerBord('12201010',-1000);
  EnvoyerBord('11201010',-1000);
  EnvoyerBord('10211010',-500);
  EnvoyerBord('12011010',-1000);
  EnvoyerBord('10021010',-1000);
  EnvoyerBord('10201010',-1000);
  EnvoyerBord('12001010',-1000);
  EnvoyerBord('11001010',-1000);
  EnvoyerBord('10011010',-1000);
  EnvoyerBord('10001010',-1000);
  EnvoyerBord('12222020',1000);
  EnvoyerBord('11222020',1000);
  EnvoyerBord('11122020',1000);
  EnvoyerBord('12212020',1000);
  EnvoyerBord('12112020',1000);
  EnvoyerBord('10222020',1000);
  EnvoyerBord('12022020',1000);
  EnvoyerBord('11022020',1000);
  EnvoyerBord('02122020',1000);
  EnvoyerBord('10122020',1000);
  EnvoyerBord('12202020',1000);
  EnvoyerBord('11202020',1000);
  EnvoyerBord('12102020',1000);
  EnvoyerBord('11102020',1000);
  EnvoyerBord('12012020',1000);
  EnvoyerBord('11012020',1000);
  EnvoyerBord('10112020',1000);
  EnvoyerBord('10022020',1000);
  EnvoyerBord('01022020',1000);
  EnvoyerBord('10202020',1000);
  EnvoyerBord('01202020',1000);
  EnvoyerBord('12002020',1000);
  EnvoyerBord('11002020',1000);
  EnvoyerBord('10102020',1000);
  EnvoyerBord('10012020',1000);
  EnvoyerBord('10002020',1000);
  EnvoyerBord('02021222',1000);
  EnvoyerBord('02021122',1000);
  EnvoyerBord('02021022',500);
  EnvoyerBord('02020122',1000);
  EnvoyerBord('02021202',1000);
  EnvoyerBord('02021102',500);
  EnvoyerBord('02022012',1000);
  EnvoyerBord('02021012',500);
  EnvoyerBord('02020112',1000);
  EnvoyerBord('02021220',1000);
  EnvoyerBord('02020022',1000);
  EnvoyerBord('02022002',1000);
  EnvoyerBord('02021002',1000);
  EnvoyerBord('02020102',1000);
  EnvoyerBord('02020012',1000);
  EnvoyerBord('02020002',1000);

  EnvoyerBord('01101122',-1000);
  EnvoyerBord('01101112',-1000);
  EnvoyerBord('01101022',-1000);
  EnvoyerBord('01101202',-1000);
  EnvoyerBord('01101102',-1000);
  EnvoyerBord('01101012',-1000);
  EnvoyerBord('01101210',-1000);
  EnvoyerBord('10210110',-1000);
  EnvoyerBord('12010110',-1000);
  EnvoyerBord('01101002',-1000);
  EnvoyerBord('10010110',-1000);
  EnvoyerBord('12220220',1000);
  EnvoyerBord('11220220',1000);
  EnvoyerBord('02202012',1000);
  EnvoyerBord('10220220',1000);
  EnvoyerBord('12020220',1000);
  EnvoyerBord('11020220',1000);
  EnvoyerBord('10120220',1000);
  EnvoyerBord('02202002',1000);
  EnvoyerBord('10020220',1000);

  EnvoyerBord('02000022',-300);
  EnvoyerBord('02200002',-300);
  EnvoyerBord('11000010',300);
  EnvoyerBord('10000110',300);

  EnvoyerBord('02012222',350);
  EnvoyerBord('02011222',350);
  EnvoyerBord('02011122',valCoin);
  EnvoyerBord('02012212',550);
  EnvoyerBord('02012112',550);
  EnvoyerBord('02001222',-700);
  EnvoyerBord('02012022',550);
  EnvoyerBord('02010122',-700);
  EnvoyerBord('02001122',-700);
  EnvoyerBord('02012202',550);
  EnvoyerBord('02011202',550);
  EnvoyerBord('02012102',550);
  EnvoyerBord('02012012',550);
  EnvoyerBord('02011012',-700);
  EnvoyerBord('02010112',-700);
  EnvoyerBord('02001112',-700);
  EnvoyerBord('02000222',550);
  EnvoyerBord('02002022',550);
  EnvoyerBord('02010022',550);
  EnvoyerBord('02001022',550);
  EnvoyerBord('02000122',550);
  EnvoyerBord('02010202',550);
  EnvoyerBord('02001202',550);
  EnvoyerBord('02012002',550);
  EnvoyerBord('02011002',550);
  EnvoyerBord('02002102',550);
  EnvoyerBord('02010102',550);
  EnvoyerBord('02001102',550);
  EnvoyerBord('02002012',550);
  EnvoyerBord('02010012',550);
  EnvoyerBord('02001012',550);
  EnvoyerBord('02000112',550);
  EnvoyerBord('02010002',-700);
  EnvoyerBord('02001002',550);
  EnvoyerBord('02000102',-700);
  EnvoyerBord('02000012',-700);
  EnvoyerBord('12221020',550);
  EnvoyerBord('11221020',550);
  EnvoyerBord('11121020',550);
  EnvoyerBord('12211020',550);
  EnvoyerBord('11211020',550);
  EnvoyerBord('12220020',1000);
  EnvoyerBord('11220020',1000);
  EnvoyerBord('11120020',1000);
  EnvoyerBord('12210020',550);
  EnvoyerBord('11210020',550);
  EnvoyerBord('11110020',550);
  EnvoyerBord('10121020',550);
  EnvoyerBord('01121020',550);
  EnvoyerBord('11201020',550);
  EnvoyerBord('12101020',550);
  EnvoyerBord('01211020',550);
  EnvoyerBord('12011020',1000);
  EnvoyerBord('11011020',1000);
  EnvoyerBord('10111020',1000);
  EnvoyerBord('10220020',1000);
  EnvoyerBord('01220020',1000);
  EnvoyerBord('12020020',1000);
  EnvoyerBord('11020020',1000);
  EnvoyerBord('10120020',1000);
  EnvoyerBord('01120020',1000);
  EnvoyerBord('12200020',1000);
  EnvoyerBord('11200020',1000);
  EnvoyerBord('12100020',550);
  EnvoyerBord('10210020',1000);
  EnvoyerBord('01210020',550);
  EnvoyerBord('12010020',1000);
  EnvoyerBord('11010020',550);
  EnvoyerBord('02110020',1000);
  EnvoyerBord('10110020',550);
  EnvoyerBord('01021020',550);
  EnvoyerBord('10201020',1000);
  EnvoyerBord('01201020',550);
  EnvoyerBord('12001020',1000);
  EnvoyerBord('10101020',550);
  EnvoyerBord('10020020',1000);
  EnvoyerBord('01020020',50);
  EnvoyerBord('01200020',-500);
  EnvoyerBord('11000020',1000);
  EnvoyerBord('02100020',1000);
  EnvoyerBord('10100020',550);
  EnvoyerBord('01100020',-10);
  EnvoyerBord('10010020',1000);
  EnvoyerBord('10001020',1000);
  EnvoyerBord('01001020',-50);

  EnvoyerBord('01021222',-1000);
  EnvoyerBord('01022022',-1000);
  EnvoyerBord('01002022',-1000);
  EnvoyerBord('01001022',-1000);
  EnvoyerBord('01022122',-1000);
  EnvoyerBord('01002122',-1000);
  EnvoyerBord('01020122',-900);
  EnvoyerBord('01021122',-1000);
  EnvoyerBord('01001122',-1000);
  EnvoyerBord('01022202',-1000);
  EnvoyerBord('01002202',-1000);
  EnvoyerBord('01020202',-1000);
  EnvoyerBord('01120202',-1000);
  EnvoyerBord('01000202',-1000);
  EnvoyerBord('01021202',-800);
  EnvoyerBord('01001202',-1000);
  EnvoyerBord('01002002',-1000);
  EnvoyerBord('01020002',-1000);
  EnvoyerBord('01001002',-1000);
  EnvoyerBord('01002102',-1000);
  EnvoyerBord('01020102',-1000);
  EnvoyerBord('01001102',-1000);
  EnvoyerBord('01020212',-800);
  EnvoyerBord('01000212',-1000);
  EnvoyerBord('01022012',-900);
  EnvoyerBord('01002012',-900);
  EnvoyerBord('01020012',-1000);
  EnvoyerBord('01001012',-1000);
  EnvoyerBord('01022112',-900);
  EnvoyerBord('01002112',-800);
  EnvoyerBord('01000112',-1000);
  EnvoyerBord('01021112',-800);
  EnvoyerBord('01001112',-1000);
  EnvoyerBord('01000220',10);
  EnvoyerBord('01021220',-800);
  EnvoyerBord('01001220',200);
  EnvoyerBord('01022120',-800);
  EnvoyerBord('01002120',200);
  EnvoyerBord('01020120',200);
  EnvoyerBord('01000120',-500);
  EnvoyerBord('01001120',200);
  EnvoyerBord('01002210',-1000);
  EnvoyerBord('01000210',valCoin+400);
  EnvoyerBord('12022010',700);
  EnvoyerBord('10022010',100);
  EnvoyerBord('10122010',-1000);
  EnvoyerBord('12202010',700);
  EnvoyerBord('10202010',-1000);
  EnvoyerBord('10202110',-1000);
  EnvoyerBord('10202210',-1000);
  EnvoyerBord('11202010',700);
  EnvoyerBord('12002010',500);
  EnvoyerBord('10002010',700);
  EnvoyerBord('11002010',100);
  EnvoyerBord('12212010',-1000);
  EnvoyerBord('10212010',-400);
  EnvoyerBord('12012010',-400);
  EnvoyerBord('11012010',-1000);
  EnvoyerBord('12112010',-1000);
  EnvoyerBord('10112010',-1000);
  EnvoyerBord('12220010',700);
  EnvoyerBord('10220010',700);
  EnvoyerBord('11220010',700);
  EnvoyerBord('12020010',700);
  EnvoyerBord('10020010',-1000);
  EnvoyerBord('11020010',700);
  EnvoyerBord('10120010',-300);
  EnvoyerBord('11120010',700);
  EnvoyerBord('12200010',700);
  EnvoyerBord('10200010',700);
  EnvoyerBord('11200010',700);
  EnvoyerBord('12000010',700);
  EnvoyerBord('11100010',-300);


  EnvoyerBord('01100222',-1000);
  EnvoyerBord('01100022',-1000);
  EnvoyerBord('01102122',-1000);
  EnvoyerBord('01100122',-1000);
  EnvoyerBord('01102202',-1000);
  EnvoyerBord('01100202',-1000);
  EnvoyerBord('01102212',-1000);
  EnvoyerBord('01100212',-1000);
  EnvoyerBord('01102012',-1000);
  EnvoyerBord('01102112',-1000);
  EnvoyerBord('01100112',-1000);
  EnvoyerBord('01100220',100);
  EnvoyerBord('12020110',10);
  EnvoyerBord('10020110',100);
  EnvoyerBord('10120110',-1000);
  EnvoyerBord('12200110',10);
  EnvoyerBord('10200110',800);
  EnvoyerBord('11200110',10);
  EnvoyerBord('12000110',800);
  EnvoyerBord('11000110',-300);

  EnvoyerBord('02201222',800);
  EnvoyerBord('02200022',1000);
  EnvoyerBord('02200122',-500);
  EnvoyerBord('02201122',800);
  EnvoyerBord('02201202',800);
  EnvoyerBord('02201002',800);
  EnvoyerBord('02200102',900);
  EnvoyerBord('02200012',1000);
  EnvoyerBord('02201012',-500);
  EnvoyerBord('02200112',-500);
  EnvoyerBord('12200220',1000);
  EnvoyerBord('11200220',1000);
  EnvoyerBord('11000220',1000);
  EnvoyerBord('12100220',1000);
  EnvoyerBord('10100220',1000);
  EnvoyerBord('11100220',1000);
  EnvoyerBord('12210220',1000);
  EnvoyerBord('11210220',1000);
  EnvoyerBord('12010220',1000);
  EnvoyerBord('12110220',1000);
  EnvoyerBord('10110220',1000);
  EnvoyerBord('01110022',-1000);
  EnvoyerBord('01110112',-1000);
  EnvoyerBord('12001110',700);
  EnvoyerBord('02220122',800);
  EnvoyerBord('02220012',-500);
  EnvoyerBord('12202220',1000);
  EnvoyerBord('11002220',1000);

  EnvoyerBord('00212222',300);
  EnvoyerBord('00221222',400);
  EnvoyerBord('00122122',700);
  EnvoyerBord('00121122',750);
  EnvoyerBord('11221200',-750);
  EnvoyerBord('11211200',-700);
  EnvoyerBord('11112100',-300);
  EnvoyerBord('11121100',-400);
  EnvoyerBord('00220222',400);
  EnvoyerBord('00210222',100);
  EnvoyerBord('00021222',300);
  EnvoyerBord('00201222',100);
  EnvoyerBord('00101222',-1000);
  EnvoyerBord('00212022',800);
  EnvoyerBord('00112022',-1000);
  EnvoyerBord('00221022',300);
  EnvoyerBord('00121022',200);
  EnvoyerBord('00211022',300);
  EnvoyerBord('00102122',-1000);
  EnvoyerBord('00220122',200);
  EnvoyerBord('00120122',-1000);
  EnvoyerBord('00210122',10);
  EnvoyerBord('00201122',200);
  EnvoyerBord('00220212',800);
  EnvoyerBord('00122012',-1000);
  EnvoyerBord('00112012',-1000);
  EnvoyerBord('00120112',-1000);
  EnvoyerBord('00110112',-1000);
  EnvoyerBord('00101112',-1000);
  EnvoyerBord('00111220',900);
  EnvoyerBord('00122120',900);
  EnvoyerBord('00121120',900);
  EnvoyerBord('12202200',1000);
  EnvoyerBord('12012200',1000);
  EnvoyerBord('11012200',700);
  EnvoyerBord('12220200',1000);
  EnvoyerBord('11120200',1000);
  EnvoyerBord('11210200',400);
  EnvoyerBord('11021200',1000);
  EnvoyerBord('12201200',1000);
  EnvoyerBord('11201200',1000);
  EnvoyerBord('01211200',-900);
  EnvoyerBord('12011200',1000);
  EnvoyerBord('11012100',-400);
  EnvoyerBord('11102100',1000);
  EnvoyerBord('12011100',1000);
  EnvoyerBord('10222100',1000);
  EnvoyerBord('12101100',-800);
  EnvoyerBord('00100222',-1000);
  EnvoyerBord('00202022',500);
  EnvoyerBord('00102022',200);
  EnvoyerBord('00210022',100);
  EnvoyerBord('00110022',-1000);
  EnvoyerBord('00021022',600);
  EnvoyerBord('00201022',-400);
  EnvoyerBord('00101022',-1000);
  EnvoyerBord('00200122',-600);
  EnvoyerBord('00100122',-1000);
  EnvoyerBord('00210202',400);
  EnvoyerBord('00201202',100);
  EnvoyerBord('00101202',-1000);
  EnvoyerBord('00122002',-1000);
  EnvoyerBord('00212002',100);
  EnvoyerBord('00112002',-1000);
  EnvoyerBord('00221002',-100);
  EnvoyerBord('00211002',-100);
  EnvoyerBord('00111002',-1000);
  EnvoyerBord('20000010',-800);
  EnvoyerBord('20000100',-500);
  EnvoyerBord('20001000',-500);
  EnvoyerBord('20010000',-500);
  EnvoyerBord('20100000',-500);
  EnvoyerBord('20000110',-1000);
  EnvoyerBord('20001100',-500);
  EnvoyerBord('20011000',-500);
  EnvoyerBord('20110000',-500);
  EnvoyerBord('21100000',-500);
  EnvoyerBord('00220102',-600);
  EnvoyerBord('00210102',-600);
  EnvoyerBord('00110102',-1000);
  EnvoyerBord('00201102',-700);
  EnvoyerBord('00101102',-1000);
  EnvoyerBord('00020212',800);
  EnvoyerBord('00202012',800);
  EnvoyerBord('00102012',600);
  EnvoyerBord('00012012',-1000);
  EnvoyerBord('00220012',-700);
  EnvoyerBord('00120012',-1000);
  EnvoyerBord('00210012',200);
  EnvoyerBord('00110012',-1000);
  EnvoyerBord('00201012',-1000);
  EnvoyerBord('00011012',-1000);
  EnvoyerBord('00200112',-800);
  EnvoyerBord('00100112',-1000);
  EnvoyerBord('00010112',-1000);
  EnvoyerBord('00021220',1000);
  EnvoyerBord('00201220',1000);
  EnvoyerBord('00220120',1000);
  EnvoyerBord('00210120',800);
  EnvoyerBord('00110120',800);
  EnvoyerBord('00201120',1000);
  EnvoyerBord('10000020',800);
  EnvoyerBord('10000200',500);
  EnvoyerBord('10002000',500);
  EnvoyerBord('10020000',500);
  EnvoyerBord('10200000',500);
  EnvoyerBord('10000220',1000);
  EnvoyerBord('10002200',500);
  EnvoyerBord('10022000',500);
  EnvoyerBord('10220000',500);
  EnvoyerBord('12200000',500);
  EnvoyerBord('10022200',1000);
  EnvoyerBord('10202200',1000);
  EnvoyerBord('12002200',1000);
  EnvoyerBord('11002200',1000);
  EnvoyerBord('10012200',1000);
  EnvoyerBord('10220200',1000);
  EnvoyerBord('11020200',1000);
  EnvoyerBord('10120200',1000);
  EnvoyerBord('12200200',1000);
  EnvoyerBord('11200200',1000);
  EnvoyerBord('11100200',1000);
  EnvoyerBord('12010200',1000);
  EnvoyerBord('11010200',-500);
  EnvoyerBord('10201200',800);
  EnvoyerBord('12001200',1000);
  EnvoyerBord('10011200',800);
  EnvoyerBord('10022100',100);
  EnvoyerBord('10202100',200);
  EnvoyerBord('12002100',200);
  EnvoyerBord('11002100',200);
  EnvoyerBord('10102100',-100);
  EnvoyerBord('10012100',-100);
  EnvoyerBord('10220100',700);
  EnvoyerBord('12020100',500);
  EnvoyerBord('11020100',700);
  EnvoyerBord('10120100',-100);
  EnvoyerBord('10102100',-100);
  EnvoyerBord('12200100',200);
  EnvoyerBord('11200100',200);
  EnvoyerBord('10210100',200);
  EnvoyerBord('12010100',200);
  EnvoyerBord('11010100',-300);
  EnvoyerBord('10021100',700);
  EnvoyerBord('10201100',700);
  EnvoyerBord('12001100',700);
  EnvoyerBord('00100022',-1000);
  EnvoyerBord('00010022',-1000);
  EnvoyerBord('00202002',300);
  EnvoyerBord('00102002',-1000);
  EnvoyerBord('00120002',-400);
  EnvoyerBord('10002200',500);
  EnvoyerBord('10200200',1000);
  EnvoyerBord('01200200',valDefenseCoin-500);
  EnvoyerBord('12000200',1000);
  EnvoyerBord('11000200',700);
  EnvoyerBord('10010200',500);
  EnvoyerBord('10001200',400);
  EnvoyerBord('10002100',1000);
  EnvoyerBord('10020100',500);
  EnvoyerBord('10200100',1000);
  EnvoyerBord('12000100',1000);
  EnvoyerBord('10010100',-500);
  EnvoyerBord('00100012',-400);
  EnvoyerBord('00200012',-400);
  EnvoyerBord('00100102',-400);
  EnvoyerBord('00200102',-200);
  EnvoyerBord('00201002',-200);
  EnvoyerBord('00210002',-200);
  EnvoyerBord('00110002',-500);
  EnvoyerBord('00000022',-200);
  EnvoyerBord('11000000',200);

  {bords que j'avais oublies de coter}
  EnvoyerBord('00110111',-400);
	EnvoyerBord('00012111',-300);
	EnvoyerBord('00102111',800);
	EnvoyerBord('01001011',-550);
	EnvoyerBord('00020011',1000);
	EnvoyerBord('00012011',800);
	EnvoyerBord('01211101',-900);
	EnvoyerBord('01121101',-900);
	EnvoyerBord('01221101',-900);
	EnvoyerBord('02210101',1000);
	EnvoyerBord('21000101',-1000);
	EnvoyerBord('01020101',-550);
	EnvoyerBord('00020101',300);
	EnvoyerBord('01112101',-900);
	EnvoyerBord('00012101',-900);
	EnvoyerBord('01122101',-900);
	EnvoyerBord('01222101',-900);
	EnvoyerBord('21001001',-1000);
	EnvoyerBord('01122001',-700);
	EnvoyerBord('01222001',-700);
	EnvoyerBord('00011201',800);
	EnvoyerBord('00010121',-700);
	EnvoyerBord('00120121',-700);
	EnvoyerBord('00011021',800);
	EnvoyerBord('01211021',-900);
	EnvoyerBord('01121021',-800);
	EnvoyerBord('00121021',-800);
	EnvoyerBord('00021021',1000);
	EnvoyerBord('01221021',-900);
	EnvoyerBord('01112021',1500);
	EnvoyerBord('00012021',900);
	EnvoyerBord('01122021',1500);
	EnvoyerBord('00022021',1500);
	EnvoyerBord('01222021',1500);
	EnvoyerBord('00010221',900);
	EnvoyerBord('01210221',-200);
	EnvoyerBord('01120221',1500);
	EnvoyerBord('00020221',1000);
	EnvoyerBord('01220221',1500);
	EnvoyerBord('01202221',1500);
	EnvoyerBord('20022221',1000);
	EnvoyerBord('00012110',-950);
	EnvoyerBord('02102110',-75);
	EnvoyerBord('01220210',1025);
	EnvoyerBord('02102210',-125);
	EnvoyerBord('02102000',300);
	EnvoyerBord('22011120',500);
	EnvoyerBord('20101120',1000);
	EnvoyerBord('20020120',900);
	EnvoyerBord('22220120',400);
	EnvoyerBord('22011220',400);
	EnvoyerBord('20101220',600);
	EnvoyerBord('22201220',400);
	EnvoyerBord('22012220',700);
	EnvoyerBord('10010012',-1000);
	EnvoyerBord('10100012',-1000);
	EnvoyerBord('02110102',1000);
	EnvoyerBord('12222002',1000);
  EnvoyerBord('20222012',400);
  EnvoyerBord('10111021',-400);
  EnvoyerBord('20122002',400);
  EnvoyerBord('20112002',400);
  EnvoyerBord('20102100',-800);
  EnvoyerBord('10001112',-600);
  EnvoyerBord('10001122',-600);
  EnvoyerBord('10001222',-600);
  EnvoyerBord('20002221',600);
  EnvoyerBord('20002211',600);
  EnvoyerBord('20002111',600);


end;

procedure ecrireIndexDeQuelquesBords;
var ypos : SInt32;
begin

  EssaieSetPortWindowPlateau;


  ypos := 10;
  WriteNumAt('01111110 = ',DecoderBord('01111110'),10,ypos); ypos := ypos+10;
  WriteNumAt('02222220 = ',DecoderBord('02222220'),10,ypos); ypos := ypos+10;
  WriteNumAt('01111100 = ',DecoderBord('01111100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00111110 = ',DecoderBord('00111110'),10,ypos); ypos := ypos+10;
  WriteNumAt('02222200 = ',DecoderBord('02222200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00222220 = ',DecoderBord('00222220'),10,ypos); ypos := ypos+10;
  WriteNumAt('01111000 = ',DecoderBord('01111000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00011110 = ',DecoderBord('00011110'),10,ypos); ypos := ypos+10;
  WriteNumAt('02222000 = ',DecoderBord('02222000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00022220 = ',DecoderBord('00022220'),10,ypos); ypos := ypos+10;
  WriteNumAt('01001000 = ',DecoderBord('01001000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00010010 = ',DecoderBord('00010010'),10,ypos); ypos := ypos+10;
  WriteNumAt('02002000 = ',DecoderBord('02002000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00020020 = ',DecoderBord('00020020'),10,ypos); ypos := ypos+10;
  WriteNumAt('02220100 = ',DecoderBord('02220100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00102220 = ',DecoderBord('00102220'),10,ypos); ypos := ypos+10;
  WriteNumAt('01110200 = ',DecoderBord('01110200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00201110 = ',DecoderBord('00201110'),10,ypos); ypos := ypos+10;
  WriteNumAt('02201100 = ',DecoderBord('02201100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00110220 = ',DecoderBord('00110220'),10,ypos); ypos := ypos+10;
  WriteNumAt('01102200 = ',DecoderBord('01102200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00220110 = ',DecoderBord('00220110'),10,ypos); ypos := ypos+10;
  WriteNumAt('02011100 = ',DecoderBord('02011100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00111020 = ',DecoderBord('00111020'),10,ypos); ypos := ypos+10;
  WriteNumAt('01022200 = ',DecoderBord('01022200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00222010 = ',DecoderBord('00222010'),10,ypos); ypos := ypos+10;


  WriteNumAt('00122100 = ',DecoderBord('00122100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00112100 = ',DecoderBord('00112100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00121100 = ',DecoderBord('00121100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00121000 = ',DecoderBord('00121000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00012100 = ',DecoderBord('00012100'),10,ypos); ypos := ypos+10;

  WriteNumAt('00211200 = ',DecoderBord('00211200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00212200 = ',DecoderBord('00212200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00221200 = ',DecoderBord('00221200'),10,ypos); ypos := ypos+10;
  WriteNumAt('00212000 = ',DecoderBord('00212000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00021200 = ',DecoderBord('00021200'),10,ypos); ypos := ypos+10;

  WriteNumAt('00101000 = ',DecoderBord('00101000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00010100 = ',DecoderBord('00010100'),10,ypos); ypos := ypos+10;
  WriteNumAt('00202000 = ',DecoderBord('00202000'),10,ypos); ypos := ypos+10;
  WriteNumAt('00020200 = ',DecoderBord('00020200'),10,ypos); ypos := ypos+10;

  WriteNumAt('00101110 = ',DecoderBord('00101110'),10,ypos); ypos := ypos+10;
  WriteNumAt('00121110 = ',DecoderBord('00121110'),10,ypos); ypos := ypos+10;
  WriteNumAt('01110100 = ',DecoderBord('01110100'),10,ypos); ypos := ypos+10;
  WriteNumAt('01112100 = ',DecoderBord('01112100'),10,ypos); ypos := ypos+10;

  WriteNumAt('00202220 = ',DecoderBord('00202220'),10,ypos); ypos := ypos+10;
  WriteNumAt('00212220 = ',DecoderBord('00212220'),10,ypos); ypos := ypos+10;
  WriteNumAt('02220200 = ',DecoderBord('02220200'),10,ypos); ypos := ypos+10;
  WriteNumAt('02221200 = ',DecoderBord('02221200'),10,ypos); ypos := ypos+10;

  AttendFrappeClavier;
end;

begin
   Init_utilitaires_bords;

   GetPort(oldport);
   SetPortByWindow(wPlateauPtr);
   TextMode(srcBic);
   probleme := false;
   compteurFautes := 0;
   compteurTurbulence := 0;
   if TendanceAuBeton > 0
     then attraitPourLesBords := Trunc(100.0*TendanceAuBeton+0.49)
     else attraitPourLesBords := Trunc(100.0*TendanceAuBeton-0.49);
   NoteBordDeSixAmi := 300+attraitPourLesBords;
   NoteBordDeSixAdv := -300-attraitPourLesBords;






   MemoryFillChar(valeurBord,sizeof(valeurBord^),chr(0));






   tick := TickCount;





  noter_Bords_1;
  noter_Bords_2;
  noter_Bords_3;
  noter_Bords_4;
  noter_Bords_5;
  noter_Bords_6;
  noter_Bords_7;
  noter_Bords_8;
  noter_Bords_9;



  {ecrireIndexDeQuelquesBords;}

	{
  for i := -3280 to 3280 do
    if i <> 0 then
    begin
      aux := valeurBord^[i];
      if (aux <> 0) then
        if valeurBord^[-i] = 0 then
          begin
            CoderBord(i,uncode,nbtrous,nbamis,nbennemis);
            compteurFautes := compteurFautes+1;
            Moveto(10,compteurFautes*10);
            MyDrawString(uncode+CharToString(' => ')+IntToStr(aux));
            CoderBord(-i,uncode,nbtrous,nbamis,nbennemis);
            autreCode := MirrorString(uncode);
            aux := DecoderBord(autrecode);
            if valeurBord^[aux] = 0 then
              begin
                SysBeep(0);
                valeurBord^[aux] := 1;
              end;
            probleme := true;
          end;
    end;
  }




  if probleme
     then
       begin
         Moveto(50+50+50,50+50);
         MyDrawString('nb erreurs = '+IntToStr(compteurFautes)+'  tapez une touche');
         AttendFrappeClavier;
      end;


  (**    enlever les commentaires pour obtenir un fichier des bords non cotés **)
  (**
  compteur := 0;
  for adresse := -3280 to 3280 do
    if (valeurBord^[adresse] = 0)
      then
        begin
          compteur := compteur+1;
          CoderBord(adresse,uncode,nbtrous,nbamis,nbennemis);
          aux := 0;
          for i := 1 to 8 do
              aux := aux+puiss3[i]*equ_bord[uncode[9-i]];
          if aux <> adresse then
            if valeurBord^[aux] = 0
              then valeurBord^[aux] := 1
              else SysBeep(0);
        end;
  WriteNumAt('nb de bords non cotés = ',compteur,10,10);

  nomfichier := ReadStringFromRessource(TextesDiversID,2); {'sans titre'}
  SetNameOfSFReply(reply, nomfichier);
  if MakeFileName(reply,'bords sans trou',nomfichier) then
      begin
        nomfichier := GetNameOfSFReply(reply);
        Rewrite(fichierBordsNonCotes,nomfichier);
        for i := -3280 to 3280 do
          if (valeurBord^[i] = 0) then
            begin
              CoderBord(i,uncode,nbtrous,nbamis,nbennemis);
              if (Pos('1212',uncode) <= 0) and (Pos('2121',uncode) <= 0) then
              if (Pos('121121',uncode) <= 0) and (Pos('212212',uncode) <= 0) then
                begin
                  Write(fichierBordsNonCotes,'EnvoyerBord(''');
                  Write(fichierBordsNonCotes,uncode);
                  Writeln(fichierBordsNonCotes,''',);');
                end;
            end;
        Close(fichierBordsNonCotes);
        SetFileCreator(nomfichier,'CWIE');
        SetFileType(nomfichier,'TEXT');

      end;
   **)

  (**    enlever les commentaires pour obtenir un fichier des bords cotés   **)
  (**    pour une couleur, mais pas pour l'autre                            **)
  (**
  nomfichier := ReadStringFromRessource(TextesDiversID,2); {'sans titre'}
  SetNameOfSFReply(reply, nomfichier);
  if MakeFileName(reply,'bords oubliés',nomfichier) then
      begin
        nomfichier := GetNameOfSFReply(reply);
        Rewrite(fichierBordsNonCotes,nomfichier);
        for i := -3280 to 3280 do
				    if i <> 0 then
				    begin
				      aux := valeurBord^[i];
				      if (aux <> 0) then
				        if valeurBord^[-i] = 0 then
				          begin
				            CoderBord(-i,autreCode,nbtrous,nbamis,nbennemis);
				            Write(fichierBordsNonCotes,'EnvoyerBord('''+autreCode+''',');
				            Write(fichierBordsNonCotes,IntToStr(-aux));
                    Writeln(fichierBordsNonCotes,');');
				          end;
				    end;
        Close(fichierBordsNonCotes);
        SetFileCreator(nomfichier,'CWIE');
        SetFileType(nomfichier,'TEXT');
      end;
  **)

  SetPort(oldport);
end;


end.
