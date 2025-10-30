UNIT UnitProbCutValues;


INTERFACE







 USES UnitDefCassio;









procedure InitUnitProbCutValues;
procedure LibereMemoireUnitProbCutValues;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitAffichageReflexion, UnitMoveRecords, UnitRapport, UnitGestionDuTemps, MyMathUtils
    , UnitPositionEtTrait, UnitAffichagePlateau, basicfile, UnitBigVectors, UnitStatisticalFitting, UnitSetUp, UnitSuperviseur, UnitPhasesPartie
    , UnitMilieuDePartie, UnitJeu ;
{$ELSEC}
    ;
    {$I prelink/ProbCutValues.lk}
{$ENDC}


{END_USE_CLAUSE}











const MAX_PROBCUT_HEIGHT = 25;
      NUM_TRY = 3;

type ProbCutRecord =
       record
         profHaute : SInt16;             (* profondeur haute *)
         profBasse : SInt16;             (* profondeur de remplacement *)
         ProbCutWindowWidth : SInt32;    (* = RoundToL(threshold*sigma/a) *)
         a,b,sigma : TypeReel;            (* offset, slope, standard-deviation *)
         threshold : TypeReel;            (* cut threshold *)
       end;

var ProbCutValues: array[0..64,0..MAX_PROBCUT_HEIGHT,1..NUM_TRY] of ProbCutRecord;




const ScoreOthelloImpossible = -1000.0;

var ProbCutStat : array[0..64] of
                   record
                     nbData : SInt32;
                     data: array[0..MAX_PROBCUT_HEIGHT] of PointMultidimensionnel;
                   end;


procedure InitUnitProbCutValues;
var numeroCoup,prof,k : SInt32;
begin
  for numeroCoup := 0 to 64 do
    for prof := 0 to MAX_PROBCUT_HEIGHT do
      for k := 1 to NUM_TRY do
        with ProbCutValues[numeroCoup,prof,k] do
          begin
            profHaute         := -1;
            profBasse         := -1;
            a                 := 0.0;
            b                 := 1.0;
            sigma             := 0.0;
            threshold         := 0.0;
            ProbCutWindowWidth := 0;
          end;
end;

procedure LibereMemoireUnitProbCutValues;
begin
end;


function ExtractValidStatistics(numeroCoup,prof1,prof2 : SInt32; var p1,p2 : PointMultidimensionnel; var nbValides : SInt32) : boolean;
var k,dimp1,dimp2,dimProf1,dimProf2 : SInt32;
    x,y : TypeReel;
    ok : boolean;
begin
  ok := false;
  nbValides := 0;

  if (numeroCoup >= 0) and (numeroCoup <= 64) and
     (prof1 >= 0) and (prof1 <= MAX_PROBCUT_HEIGHT) and
     (prof2 >= 0) and (prof2 <= MAX_PROBCUT_HEIGHT) then
    begin
      dimp1 := DimensionDuPointMultidimensionnel(p1);
      dimp2 := DimensionDuPointMultidimensionnel(p2);
      if (dimp1 > 0) and (dimp2 > 0) and (dimp1 = dimp2) then
        if (ProbCutStat[numeroCoup].nbData > 0) and (ProbCutStat[numeroCoup].nbData <= dimp1) then
	     	  if (ProbCutStat[numeroCoup].data[prof1] <> NIL) and (ProbCutStat[numeroCoup].data[prof2] <> NIL) then
			      begin
			        dimProf1 := DimensionDuPointMultidimensionnel(ProbCutStat[numeroCoup].data[prof1]);
		          dimProf2 := DimensionDuPointMultidimensionnel(ProbCutStat[numeroCoup].data[prof2]);
		          if (dimProf1 = dimProf2) and (dimProf1 > 0) then
		            begin
			            nbValides := 0;
			            for k := 1 to ProbCutStat[numeroCoup].nbData do
			              begin
			                x := ProbCutStat[numeroCoup].data[prof1]^[k];
			                y := ProbCutStat[numeroCoup].data[prof2]^[k];
			                if (nbValides < dimp1) and
			                   (x >= -64.0) and (x <= 64.0) and
			                   (y >= -64.0) and (y <= 64) then
			                   begin
			                     inc(nbValides);
			                     p1^[nbValides] := x;
			                     p2^[nbValides] := y;
			                   end;
			              end;
			            ok := (nbValides > 2);
			          end;
			      end;
		end;

  ExtractValidStatistics := ok;
end;

function CalculePaireProbCut(numeroCoup,prof1,prof2 : SInt32) : boolean;
const nMaxPos = 50000;
var x,y,dev,erreur : PointMultidimensionnel;
    decalage,pente,sigmaDec,sigmaPente,chi2,q : TypeReel;
    moyenne,deviationAbsolueMoyenne,standardDeviation : TypeReel;
    variance,skewness,kurtosis : TypeReel;
    nPos,mySwap,k : SInt32;
begin
  CalculePaireProbCut := false;
  if prof1 < prof2 then
    begin
      mySwap := prof2;
      prof2 := prof1;
      prof1 := mySwap;
    end;

  if prof1 = prof2 then
    begin
      WritelnDansRapport('erreur : prof1 = prof2 dans CalculePaireProbCut');
      exit;
    end;

  if (numeroCoup >= 0) and (numeroCoup <= 64) and
     (prof1 >= 0) and (prof1 <= MAX_PROBCUT_HEIGHT) and
     (prof2 >= 0) and (prof2 <= MAX_PROBCUT_HEIGHT) then
    begin
      x := NIL;
      y := NIL;
      dev := NIL;
      erreur := NIL;
      if AllocatePointMultidimensionnel(nMaxPos,x) and
         AllocatePointMultidimensionnel(nMaxPos,y) and
         AllocatePointMultidimensionnel(nMaxPos,erreur) and
         ExtractValidStatistics(numeroCoup,prof1,prof2,x,y,nPos) then
        begin

          {Find the best pair (decalage,pente) such that y = decalage + pente*x }
          StraightLineFitting(x,y,dev,nPos,false,decalage,pente,sigmaDec,sigmaPente,chi2,q);

          {Calculate error vector: erreur = y - (decalage + pente*x)}
          SetValeurDansPointMultidimensionnel(erreur,decalage);                 {erreur := decalage}
          CombinaisonLineairePointMultidimensionnel(erreur,x,1.0,pente,erreur); {erreur := erreur+pente*x}
          DiffPointMultidimensionnel(y,erreur,erreur);                          {erreur := y-erreur}


          {Calculate standard deviation of error}
          MomentsOfPointMultidimensionnel(erreur,nPos,moyenne,deviationAbsolueMoyenne,standardDeviation,variance,skewness,kurtosis);

          for k := 1 to NUM_TRY do
            if (ProbCutValues[numeroCoup,prof1,k].profHaute < 0) then {place vide ?}
		          begin
		            CalculePaireProbCut := true;
		            with ProbCutValues[numeroCoup,prof1,k] do
			            begin
			              profHaute := prof1;
			              profBasse := prof2;
			              a := decalage;
			              b := pente;
			              sigma := standardDeviation;
			              if numeroCoup >= 36
			                then threshold := 1.4
			                else threshold := 1.1;
			              ProbCutWindowWidth := Trunc(0.5 + threshold*sigma/b);
			            end;
			        end;
        end;
      DisposePointMultidimensionnel(x);
      DisposePointMultidimensionnel(y);
    end;
end;


procedure SetValeurDansProbCutStat(valeur : TypeReel; numeroCoup,prof,positionDansData : SInt32);
begin
  if (numeroCoup >= 0) and (numeroCoup <= 64) and
     (prof >= 0) and (prof <= MAX_PROBCUT_HEIGHT) and
     (ProbCutStat[numeroCoup].data[prof] <> NIL) and
     (positionDansData > 0) and (positionDansData <= ProbCutStat[numeroCoup].nbData) and
     (positionDansData <= DimensionDuPointMultidimensionnel(ProbCutStat[numeroCoup].data[prof]))
    then ProbCutStat[numeroCoup].data[prof]^[positionDansData] := valeur
    else WritelnDansRapport('Affectation illegale dans SetValeurDansProbCutStat !!');
end;

procedure InvalidateProbCutStat(numeroCoup,positionDansData : SInt32);
var prof,dim : SInt32;
begin
  if (numeroCoup >= 0) and (numeroCoup <= 64) then
    begin
      for prof := 0 to MAX_PROBCUT_HEIGHT do
        if ProbCutStat[numeroCoup].data[prof] <> NIL then
          begin
            dim := DimensionDuPointMultidimensionnel(ProbCutStat[numeroCoup].data[prof]);
            if (positionDansData >= 1) and (positionDansData <= dim) then
              begin
                if positionDansData < ProbCutStat[numeroCoup].nbData then
                  begin
                    WritelnDansRapport('WARNING : positionDansData < ProbCutStat[numeroCoup,k].nbData dans InvalidateProbCutStat !');
                    WritelnNumDansRapport('numeroCoup = ',numeroCoup);
                    WritelnNumDansRapport('positionDansData = ',positionDansData);
                  end;
                SetValeurDansProbCutStat(ScoreOthelloImpossible,numeroCoup,prof,positionDansData);
              end;
          end;
    end;
end;


function NewProbCutCell(numeroCoup : SInt32) : SInt32;
var n : SInt32;
begin
  inc(ProbCutStat[numeroCoup].nbData);
  n := ProbCutStat[numeroCoup].nbData;
  InvalidateProbCutStat(numeroCoup,n);
  NewProbCutCell := n;
end;


procedure AddMidgameValuesInProbCutStats(numeroCoup : SInt32);
var i,k,coup,n,dataPos : SInt32;
    prof,profAux,profMax : SInt32;
    valeur : TypeReel;
begin
  if (numeroCoup >= 0) and (numeroCoup <= 64) then
    begin
      HLockAllProfsDansDansTableOfMoveRecordsLists;
      profMax := Min(ProfMaxDansTableOfMoveRecordsLists,MAX_PROBCUT_HEIGHT);

      n := DimensionDuPointMultidimensionnel(ProbCutStat[numeroCoup].data[1]);
		  if (n > 0) and (ProbCutStat[numeroCoup].nbData < n) then
		    begin

		      {on prend la note du meilleur coup de chaque profondeur}
		      dataPos := NewProbCutCell(numeroCoup);
		      for prof := 1 to profMax do
		        if TableOfMoveRecordsLists[prof-1].utilisee and
		           (TableOfMoveRecordsLists[prof-1].cardinal > 0) and
		           (TableOfMoveRecordsLists[prof-1].list <> NIL) then
		          begin
		            valeur := 0.01*TableOfMoveRecordsLists[prof-1].list^^[1].note;
		            SetValeurDansProbCutStat(valeur,numeroCoup,prof,dataPos);
		          end;

		      {Pour chaque coup, on regarde sa note a chaque profondeur}
		      {find the first used depth}
		      prof := 0;
		      while (prof <= profMax) and not(TableOfMoveRecordsLists[prof].utilisee) do inc(prof);
		      {for each move at depth "prof"}
		      if (prof <= profMax) and (TableOfMoveRecordsLists[prof].utilisee) then
		        for k := 1 to TableOfMoveRecordsLists[prof].cardinal do
			        begin
			          dataPos := NewProbCutCell(numeroCoup);
			          coup := TableOfMoveRecordsLists[prof].list^^[k].x;

			          {find the note of move "coup" at depths >= prof}
			          for profAux := prof to profMax do
			            if TableOfMoveRecordsLists[profAux].utilisee then
			              for i := 1 to TableOfMoveRecordsLists[profAux].cardinal do
			                if TableOfMoveRecordsLists[profAux].list^^[i].x = coup then
			                begin
			                  valeur := 0.01*TableOfMoveRecordsLists[profAux].list^^[i].note;
			                  SetValeurDansProbCutStat(valeur,numeroCoup,profAux,dataPos);
			                end;
			        end;

		    end;
		  HUnlockAllProfsDansDansTableOfMoveRecordsLists;
		end;
end;


procedure DoMidgameForProbCutStats(var position : plateauOthello; var jouable : plBool; var frontiere : InfoFront; nbNoir,nbBlanc,trait : SInt16; var profondeurMilieuDemandee : SInt32);
var numeroDuCoup : SInt32;
    bestMove,valeur,bestDef,midgameDepth : SInt32;
    oldInterruption : SInt16;
    resultatCalculMilieu : MoveRecord;
begin

  oldInterruption := GetCurrentInterruption;
  EnleveCetteInterruption(oldInterruption);

  PlaquerPosition(position,trait,kRedessineEcran);
  if HumCtreHum then DoChangeHumCtreHum;
  RefleSurTempsJoueur := false;
  vaDepasserTemps := false;
  couleurMacintosh := trait;
  numeroDuCoup := nbNoir+nbBlanc-4;
  DoMilieuDeJeuAnalyse(false);

  phaseDeLaPartie := CalculePhasePartie(nbreCoup);

  ReinitilaliseInfosAffichageReflexion;
  EffaceReflexion(HumCtreHum);
  dernierTick := TickCount-tempsDesJoueurs[AQuiDeJouer].tick;
  LanceChrono;
  tempsPrevu := 10;
  tempsAlloue := minutes10000000;
  if not(RefleSurTempsJoueur) and (AQuiDeJouer = couleurMacintosh) then
    begin
      EcritJeReflechis(AQuiDeJouer);
    end;
  Superviseur(numeroDuCoup);
  Initialise_table_heuristique(position,false);

  Calcule_Valeurs_Tactiques(position,true);
  EnleveCetteInterruption(GetCurrentInterruption);

  midgameDepth := profondeurMilieuDemandee;
  SetProfImposee((midgameDepth > 0),'DoMidgameForProbCutStats');

  resultatCalculMilieu := CalculeMeilleurCoupMilieuDePartie(position,jouable,frontiere,AQuiDeJouer,midgameDepth,nbBlanc,nbNoir);

  bestMove := resultatCalculMilieu.x;
  valeur   := resultatCalculMilieu.note;
  bestDef  := resultatCalculMilieu.theDefense;

  AddMidgameValuesInProbCutStats(numeroDuCoup);

  LanceInterruption(oldInterruption,'DoMidgameForProbCutStats');
end;


procedure AccumulateProbCutStatistics(var partie60 : PackedThorGame; numeroReference : SInt32; var profondeurMilieuDemandee : SInt32);
begin {$UNUSED numeroReference}
  ForEachPositionInGameDo(partie60,DoMidgameForProbCutStats,profondeurMilieuDemandee);
end;



function LitVecteursStatProbDansFichierTexte(var fic : basicfile) : OSErr;
var numeroCoup,nbData,prof,tailleVecteur : SInt32;
    err : OSErr;
    p : PointMultidimensionnel;
begin
  err := -1;

  while not(EndOfFile(fic,err)) do
    begin
      err := ReadLongintDansFichierTexte(fic,numeroCoup);
      err := ReadLongintDansFichierTexte(fic,nbData);
      err := ReadLongintDansFichierTexte(fic,prof);
      err := ReadLongintDansFichierTexte(fic,tailleVecteur);

      if err <> 0 then
        begin
          LitVecteursStatProbDansFichierTexte := err;
          exit;
        end;

      if (tailleVecteur > 0) then
        begin
          if AllocatePointMultidimensionnel(tailleVecteur,p) then
            begin
              err := LitPointMultidimensionnelDansFichierTexte(fic,p);
              if err <> 0 then
				        begin
				          LitVecteursStatProbDansFichierTexte := err;
				          exit;
				        end;

              if (numeroCoup >= 0) and (numeroCoup <= 64) and (nbData > 0) then
                begin
                  ProbCutStat[numeroCoup].nbData := nbData;
                  CopierPointMultidimensionnel(p,ProbCutStat[numeroCoup].data[prof]);
                end;
            end;
          DisposePointMultidimensionnel(p);
        end;
    end;

  LitVecteursStatProbDansFichierTexte := err;
end;

function EcritVecteursStatProbDansFichierTexte(var fic : basicfile) : OSErr;
var numeroCoup,prof,tailleVecteur : SInt32;
    err : OSErr;
    p : PointMultidimensionnel;
begin
  err := -1;
  for numeroCoup := 0 to 64 do
    if (ProbCutStat[numeroCoup].nbData > 0) then
      for prof := 0 to MAX_PROBCUT_HEIGHT do
        begin
          p := ProbCutStat[numeroCoup].data[prof];
          if p <> NIL then
            begin
              tailleVecteur := DimensionDuPointMultidimensionnel(p);
              if tailleVecteur > 0 then
                begin
                  err := Writeln(fic,numeroCoup);
                  err := Writeln(fic,ProbCutStat[numeroCoup].nbData);
                  err := Writeln(fic,prof);
                  err := Writeln(fic,tailleVecteur);
                  err := EcritPointMultidimensionnelDansFichierTexte(fic,p);

                  if err <> 0 then
                    begin
                      EcritVecteursStatProbDansFichierTexte := err;
                      exit;
                    end;

                end;
            end;
        end;
   EcritVecteursStatProbDansFichierTexte := err;
end;

function LitVecteursStatProbCutSurLeDisque(nomFichier : String255) : OSErr;
var fichierProbCut : basicfile;
    err : OSErr;
begin

  err := FichierTexteDeCassioExiste(nomFichier,fichierProbCut);
  if err <> 0 then
    begin
      LitVecteursStatProbCutSurLeDisque := err;
      exit;
    end;

  err := OpenFile(fichierProbCut);
  if err <> 0 then
    begin
      LitVecteursStatProbCutSurLeDisque := err;
      exit;
    end;

  err := LitVecteursStatProbDansFichierTexte(fichierProbCut);
  if err <> 0 then
    begin
      LitVecteursStatProbCutSurLeDisque := err;
      exit;
    end;

  err := CloseFile(fichierProbCut);
  if err <> 0 then
    begin
      LitVecteursStatProbCutSurLeDisque := err;
      exit;
    end;

  LitVecteursStatProbCutSurLeDisque := err;
end;

function EcritVecteursStatProbCutSurDisque(nomFichier : String255 ; vRefNum : SInt16) : OSErr;
var fichierProbCut : basicfile;
    err : OSErr;
begin

  err := FileExists(nomFichier,vRefNum,fichierProbCut);
  if err <> NoErr then err := FichierTexteDeCassioExiste(nomFichier,fichierProbCut);
  if err = fnfErr {-43 => fichier non trouvé, on le crée}
    then err := CreeFichierTexteDeCassio(nomFichier,fichierProbCut);
  if err <> 0 then
    begin
      EcritVecteursStatProbCutSurDisque := err;
      exit;
    end;

  err := OpenFile(fichierProbCut);
  if err <> 0 then
    begin
      EcritVecteursStatProbCutSurDisque := err;
      exit;
    end;

  err := EmptyFile(fichierProbCut);
  if err <> 0 then
    begin
      EcritVecteursStatProbCutSurDisque := err;
      exit;
    end;

  err := EcritVecteursStatProbDansFichierTexte(fichierProbCut);
  if err <> 0 then
    begin
      EcritVecteursStatProbCutSurDisque := err;
      exit;
    end;

  err := CloseFile(fichierProbCut);
  if err <> 0 then
    begin
      EcritVecteursStatProbCutSurDisque := err;
      exit;
    end;

  SetFileCreatorFichierTexte(fichierProbCut,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(fichierProbCut,MY_FOUR_CHAR_CODE('EVAL'));

  EcritVecteursStatProbCutSurDisque := err;
end;

procedure CalculateProbCutParameters(midgameDepth : SInt32);
var err : OSErr;
begin
  err := LitVecteursStatProbCutSurLeDisque('StatsProbCut');

  ForEachGameInListDo(bidFiltreNumRefProc,bidFiltreGameProc,AccumulateProbCutStatistics,midgameDepth);

  err := EcritVecteursStatProbCutSurDisque('StatsProbCut',0);
end;



END.
