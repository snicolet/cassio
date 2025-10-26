UNIT UnitHashTableExacte;






INTERFACE







 USES UnitDefCassio;



{initialisation et destruction de l'unite}
procedure InitUnitHashTableExacte;
procedure LibereMemoireUnitHashTableExacte;


{vidage}
procedure VideHashTableExacte(whichHashTableExacte : HashTableExactePtr);
procedure VideHashTableCoupsLegaux(whichHashTableCoupsLegaux : CoupsLegauxHashPtr);
procedure VideToutesLesHashTablesExactes;
procedure VideToutesLesHashTablesCoupsLegaux;
procedure ViderHashTablePourMilieuDePartie(withCheckEvents : boolean);
{procedure DetruitEntreesIncorrectesHashTableCoupsLegaux;}


{fonctions d'acces a la table de hachage exacte}
procedure SetTraitDansHashExacte(trait : SInt32; var cellule : HashTableExacteElement);
procedure SetBestDefenseDansHashExacte(bestDefense : SInt32; var cellule : HashTableExacteElement);
function GetTraitDansHashExacte(var cellule : HashTableExacteElement) : SInt32;
function GetBestDefenseDansHashExacte(var cellule : HashTableExacteElement) : SInt32;
procedure GetEndgameValuesInHashTableElement(var cellule : HashTableExacteElement; whichDeltaFinal : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32);


{utilisation en milieu de partie}
procedure SetValMinEtMaxDeMilieu(whichValeurMin,whichValeurMax : SInt16; var cellule : HashTableExacteElement);
procedure GetValMinEtMaxDeMilieu(var whichValeurMin,whichValeurMax : SInt16; var cellule : HashTableExacteElement);
procedure LigneMilieuToMeilleureSuiteInfos(couleur, prof, lastMove : SInt32; startingPosition : PositionEtTraitRec; ligne : String255; var meilleureSuite : t_meilleureSuite);



{utilisation en finale}
procedure CreeCodagePosition(var plat : plOthEndgame; couleur,prof : SInt32; var codagePosition : codePositionRec);
procedure WritelnCodagePositionDansRapport(codagePosition : codePositionRec);
procedure ExpandHashTableExacte(var whichElement : HashTableExacteElement; var whichLegalMoves : CoupsLegauxHashPtr; var codagePosition : codePositionRec; clefHashExacte : SInt32);
function InfoTrouveeDansHashTableExacte(var codagePosition : codePositionRec; var quelleHashTableExacte : HashTableExactePtr; clefHashage : SInt32; var whichClefExacte : SInt32) : boolean;
function MeilleurCoupEstStockeDansLesBornes(const bornes : DecompressionHashExacteRec; var meilleurCoup,valeurDeLaPosition : SInt32) : boolean;


{bornes, majorant, minorant, etc}
procedure AugmentationMinorant(newValeurMin,newDeltaMin,coup,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello; fonctionAppelante : String255);
procedure DiminutionMajorant(newValeurMax,newDeltaMax,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello; fonctionAppelante : String255);
procedure EnleverBornesMinPeuSuresDesAutresCoups(whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello);
procedure DecompresserBornesHashTableExacte(var whichElement : HashTableExacteElement; var bornes : DecompressionHashExacteRec);
procedure CompresserBornesDansHashTableExacte(var whichElement : HashTableExacteElement; var bornes : DecompressionHashExacteRec);
procedure WritelnBornesDansRapport(var bornes : DecompressionHashExacteRec);
procedure SetEndgameValuesInHashExacte(clefHash,nbVides : SInt32; jeu : PositionEtTraitRec; valMin,valMax,meilleurCoup,deltaFinale : SInt32);
procedure MetValeursDansHashExacte(clefHash,nbVides : SInt32; jeu : PositionEtTraitRec; valMin,valMax,meilleurCoup,deltaFinale,recursion : SInt32; const fonctionAppelante : String255);


{fonctions de haut niveau, ne necessitant que le hashKey de Cassio de la position (et eventuellement un fils) }
function GetEndgameValuesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey,deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
function GetEndgameValuesInHashTableFromThisNode(plat : PositionEtTraitRec; G : GameTree; deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
function GetEndgameBornesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
function GetEndgameBornesDansHashExacteAfterThisSon(whichSon : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
function GetEndgameScoreDansHashExacteAfterThisSon(whichSon : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var score : SInt32) : boolean;
function ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;
function ScoreFinalEstFaiblementConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;


(* fonction calculant la clef de hashage initiale pour la finale *)
function CalculateHashIndexFromThisNode(var positionCherchee : PositionEtTraitRec; whichNode : GameTree; var dernierCoup : SInt32) : SInt32;


(* Transfert des infos de l'arbre Smart Game Board dans les hash table, ou d'une ligne parfaite dans les hash table *)
procedure MetSousArbreDansHashTableExacte(G : GameTree; nbVidesMinimum : SInt32);
procedure MetSousArbreRecursivementDansHashTable(G : GameTree; plat : PositionEtTraitRec; hashValue, nbVides, nbVidesMinimum : SInt32);
procedure LigneFinaleToHashTable(couleur, prof, lastMove, vMin, vMax, deltaFinale : SInt32; startingPosition : PositionEtTraitRec; ligne : String255; var meilleureSuite : t_meilleureSuite);


{statistiques}
function TauxDeRemplissageHashExacte(nroTable : SInt32; ecritStatsDetaillees : boolean) : double_t;
procedure VideHashTable(whichHashTable : HashTableHdl);
procedure EcritStatistiquesCollisionsHashTableDansRapport;
procedure AfficheHashTable(minimum,maximum : SInt32);



{$IFC USE_DEBUG_STEP_BY_STEP}
procedure AjouterPositionsDevantEtreDebugueesPasAPas(var positionsCherchees : PositionEtTraitSet);
{$ENDC}






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitRapport, UnitNewGeneral, UnitEndgameTree, UnitSquareSet, UnitGestionDuTemps
    , MyStrings, UnitServicesMemoire, SNEvents, UnitPositionEtTrait, UnitPositionEtTraitSet, UnitArbreDeJeuCourant, UnitPropertyList, UnitProperties
    , UnitGameTree, UnitUtilitaires, UnitScannerUtils, UnitEngine ;
{$ELSEC}
    ;
    {$I prelink/HashTableExacte.lk}
{$ENDC}


{END_USE_CLAUSE}













procedure InitUnitHashTableExacte;
begin
  if CassioEnEnvironnementMemoireLimite
    then
      begin
        nbTablesHashExactes := 2;  { doit etre une puissance de 2 }
		    nbTablesHashExactesMoins1 := 1;
      end
    else
      begin
		    nbTablesHashExactes := 64;  { doit etre une puissance de 2 }
		    nbTablesHashExactesMoins1 := 63;
	  end
end;

procedure LibereMemoireUnitHashTableExacte;
begin
end;

procedure VideHashTableExacte(whichHashTableExacte : HashTableExactePtr);
var i,count : SInt32;
begin
  if whichHashTableExacte <> NIL
    then
  	  begin
        count := SizeOf(whichHashTableExacte^[1]);
        for i := 0 to 1023 do
          MemoryFillChar(@whichHashTableExacte^[i],count,chr(0));
	    end
    else
	    begin
		    SysBeep(0);
		    WritelnDansRapport('ERREUR : whichHashTableExacte = NIL dans VideHashTableExacte !');
      end;
end;

procedure VideHashTableCoupsLegaux(whichHashTableCoupsLegaux : CoupsLegauxHashPtr);
begin
  if whichHashTableCoupsLegaux <> NIL
    then
      MemoryFillChar(whichHashTableCoupsLegaux,sizeof(whichHashTableCoupsLegaux^),chr(0))
    else
		  begin
		    SysBeep(0);
		    WritelnDansRapport('ERREUR : whichHashTableCoupsLegaux = NIL dans VideHashTableCoupsLegaux !');
		  end;
end;

procedure VideToutesLesHashTablesExactes;
var i : SInt32;
begin
  if not(Quitter) then
    begin
      {WritelnDansRapport('je suis dans VideToutesLesHashTablesExactes…');}
		  for i := 0 to nbTablesHashExactes-1 do
		    VideHashTableExacte(HashTableExacte[i]);
		  VideToutesLesHashTablesCoupsLegaux;
		  nbCollisionsHashTableExactes := 0;
		  nbNouvellesEntreesHashTableExactes := 0;
		  nbPositionsRetrouveesHashTableExactes := 0;
		end;
end;


{version de VideToutesLesHashTablesExactes dans laquelle on verifie les interruptions}
procedure ViderHashTablePourMilieuDePartie(withCheckEvents : boolean);
var i : SInt32;
begin

  VideHashTable(HashTable);

  if withCheckEvents and ((TickCount - dernierTick) >= delaiAvantDoSystemTask) then DoSystemTask(AQuiDeJouer);

  for i := 0 to nbTablesHashExactes-1 do
    if (interruptionReflexion = pasdinterruption) then
	   begin
	     if withCheckEvents and ((TickCount - dernierTick) >= delaiAvantDoSystemTask) then DoSystemTask(AQuiDeJouer);
       if (interruptionReflexion = pasdinterruption) then VideHashTableExacte(HashTableExacte[i]);
	     if withCheckEvents and ((TickCount - dernierTick) >= delaiAvantDoSystemTask) then DoSystemTask(AQuiDeJouer);
       if (interruptionReflexion = pasdinterruption) then VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
	   end;
	
	nbCollisionsHashTableExactes := 0;
	nbNouvellesEntreesHashTableExactes := 0;
	nbPositionsRetrouveesHashTableExactes := 0;
end;



procedure VideToutesLesHashTablesCoupsLegaux;
var i : SInt32;
begin
  if not(Quitter) then
    for i := 0 to nbTablesHashExactes-1 do
      VideHashTableCoupsLegaux(CoupsLegauxHash[i]);
end;

(*
procedure DetruitEntreesIncorrectesHashTableCoupsLegaux;
var i,k : SInt32;
    whichHashTableCoupsLegaux : CoupsLegauxHashPtr;
    whichHashTableExacte : HashTableExactePtr;
begin
  for i := 0 to nbTablesHashExactes-1 do
    begin
      whichHashTableExacte := HashTableExacte[i];
      whichHashTableCoupsLegaux := CoupsLegauxHash[i];
      if (whichHashTableExacte <> NIL) and (whichHashTableCoupsLegaux <> NIL) then
        begin
          for k := 0 to 1023 do
            begin
              with whichHashTableExacte^[k] do
              if BAND(flags,kMaskRecalculerCoupsLegaux) <> 0 then
                begin
                  whichHashTableCoupsLegaux^[k,0] := 0;    {on fait comme si on n'avait pas calcule les coups legaux de cette position}
                  flags := BAND(flags,BNOT(kMaskRecalculerCoupsLegaux));
                end;
            end;
        end;
    end;
end;
*)

procedure SetTraitDansHashExacte(trait : SInt32; var cellule : HashTableExacteElement);
begin
  case trait of
    pionNoir  : cellule.traitEtBestDefense[0] := 1;
    pionBlanc : cellule.traitEtBestDefense[0] := 2;
    otherwise   cellule.traitEtBestDefense[0] := 0;
  end;
end;


function GetTraitDansHashExacte(var cellule : HashTableExacteElement) : SInt32;
begin
  case cellule.traitEtBestDefense[0] of
    1 :        GetTraitDansHashExacte := pionNoir;
    2 :        GetTraitDansHashExacte := pionBlanc;
    otherwise  GetTraitDansHashExacte := pionVide;
  end;
end;

procedure SetBestDefenseDansHashExacte(bestDefense : SInt32; var cellule : HashTableExacteElement);
begin
  cellule.traitEtBestDefense[1] := bestDefense;
end;


function GetBestDefenseDansHashExacte(var cellule : HashTableExacteElement) : SInt32;
begin
  GetBestDefenseDansHashExacte := cellule.traitEtBestDefense[1];
end;



procedure GetEndgameValuesInHashTableElement(var cellule : HashTableExacteElement; whichDeltaFinal : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32);
var bornes : DecompressionHashExacteRec;
    k,vMin,vMax : SInt32;
begin
  DecompresserBornesHashTableExacte(cellule,bornes);
  k := IndexOfThisDelta(whichDeltaFinal);
  vMin := bornes.valMin[k];
  vMax := bornes.valMax[k];
  if GetTraitDansHashExacte(cellule) = pionNoir
    then
      begin
        valMinPourNoir := vMin;
        valMaxPourNoir := vMax;
      end
    else
      begin
        valMinPourNoir := -vMax;
        valMaxPourNoir := -vMin;
      end;
end;



procedure SetValMinEtMaxDeMilieu(whichValeurMin,whichValeurMax : SInt16; var cellule : HashTableExacteElement);
begin
  with cellule do
    begin
      {ValeurMin := whichValeurMin;
      ValeurMax := whichValeurMax;}

      MoveMemory(@whichValeurMin,@cellule.bornesMin[1],sizeof(whichValeurMin));
      MoveMemory(@whichValeurMax,@cellule.bornesMax[1],sizeof(whichValeurMax));

    end;
end;

procedure GetValMinEtMaxDeMilieu(var whichValeurMin,whichValeurMax : SInt16; var cellule : HashTableExacteElement);
begin
  with cellule do
    begin
      {whichValeurMin := ValeurMin;
      whichValeurMax := ValeurMax;}

      MoveMemory(@cellule.bornesMin[1],@whichValeurMin,sizeof(whichValeurMin));
      MoveMemory(@cellule.bornesMax[1],@whichValeurMax,sizeof(whichValeurMax));

    end;
end;

procedure WritelnCodagePositionDansRapport(codagePosition : codePositionRec);
begin
  with codagePosition do
    begin
		  WritelnNumDansRapport('l1 = ',platLigne1);
		  WritelnNumDansRapport('l2 = ',platLigne2);
		  WritelnNumDansRapport('l3 = ',platLigne3);
		  WritelnNumDansRapport('l4 = ',platLigne4);
		  WritelnNumDansRapport('l5 = ',platLigne5);
		  WritelnNumDansRapport('l6 = ',platLigne6);
		  WritelnNumDansRapport('l7 = ',platLigne7);
		  WritelnNumDansRapport('l8 = ',platLigne8);
		  WritelnNumDansRapport('couleurCodage = ',couleurCodage);
		  WritelnNumDansRapport('nbreVidesCodage = ',nbreVidesCodage);
		end;
end;


procedure CreeCodagePosition(var plat : plOthEndgame; couleur,prof : SInt32; var codagePosition : codePositionRec);
  begin
    with codagePosition do
      begin
        platLigne1 := codage_c1[plat[11]]+codage_c2[plat[12]]+codage_c3[plat[13]]+codage_c4[plat[14]]+
                      codage_c5[plat[15]]+codage_c6[plat[16]]+codage_c7[plat[17]]+codage_c8[plat[18]];
        platLigne2 := codage_c1[plat[21]]+codage_c2[plat[22]]+codage_c3[plat[23]]+codage_c4[plat[24]]+
                      codage_c5[plat[25]]+codage_c6[plat[26]]+codage_c7[plat[27]]+codage_c8[plat[28]];
        platLigne3 := codage_c1[plat[31]]+codage_c2[plat[32]]+codage_c3[plat[33]]+codage_c4[plat[34]]+
                      codage_c5[plat[35]]+codage_c6[plat[36]]+codage_c7[plat[37]]+codage_c8[plat[38]];
        platLigne4 := codage_c1[plat[41]]+codage_c2[plat[42]]+codage_c3[plat[43]]+codage_c4[plat[44]]+
                      codage_c5[plat[45]]+codage_c6[plat[46]]+codage_c7[plat[47]]+codage_c8[plat[48]];
        platLigne5 := codage_c1[plat[51]]+codage_c2[plat[52]]+codage_c3[plat[53]]+codage_c4[plat[54]]+
                      codage_c5[plat[55]]+codage_c6[plat[56]]+codage_c7[plat[57]]+codage_c8[plat[58]];
        platLigne6 := codage_c1[plat[61]]+codage_c2[plat[62]]+codage_c3[plat[63]]+codage_c4[plat[64]]+
                      codage_c5[plat[65]]+codage_c6[plat[66]]+codage_c7[plat[67]]+codage_c8[plat[68]];
        platLigne7 := codage_c1[plat[71]]+codage_c2[plat[72]]+codage_c3[plat[73]]+codage_c4[plat[74]]+
                      codage_c5[plat[75]]+codage_c6[plat[76]]+codage_c7[plat[77]]+codage_c8[plat[78]];
        platLigne8 := codage_c1[plat[81]]+codage_c2[plat[82]]+codage_c3[plat[83]]+codage_c4[plat[84]]+
                      codage_c5[plat[85]]+codage_c6[plat[86]]+codage_c7[plat[87]]+codage_c8[plat[88]];
        couleurCodage := couleur;
        nbreVidesCodage := prof;
      end;
  end;

procedure ExpandHashTableExacte(var whichElement : HashTableExacteElement;
                                var whichLegalMoves : CoupsLegauxHashPtr;
                                var codagePosition : codePositionRec;
                                clefHashExacte : SInt32);
  var i : SInt32;
  begin
    with whichElement,codagePosition do
      begin
        ligne1 := platLigne1;
        ligne2 := platLigne2;
        ligne3 := platLigne3;
        ligne4 := platLigne4;
        ligne5 := platLigne5;
        ligne6 := platLigne6;
        ligne7 := platLigne7;
        ligne8 := platLigne8;
        SetTraitDansHashExacte(couleurCodage,whichElement);
        SetBestDefenseDansHashExacte(0,whichElement);
        profondeur := nbreVidesCodage;
        flags := 0;
        evaluationHeuristique := kEvaluationNonFaite;

        for i := 1 to kNbreMaxDeltasSuccessifsDansHashExacte do
          begin
            bornesMin[i]         := -64;
            bornesMax[i]         := 64;
            coupsDesBornesMin[i] := 0;
          end;

        whichLegalMoves^[clefHashExacte,0] := 0;
      end;
  end;


function InfoTrouveeDansHashTableExacte(var codagePosition : codePositionRec; var quelleHashTableExacte : HashTableExactePtr; clefHashage : SInt32; var whichClefExacte : SInt32) : boolean;
  var increment1,increment2,longueurCollisionPath : SInt32;
      clefHashExacteInitiale,clefAEcraser,minProf : SInt32;

  begin
    SetQDGlobalsRandomSeed(clefHashage+codagePosition.platLigne1+codagePosition.platLigne8+codagePosition.platLigne2+codagePosition.platLigne7);
    increment1 := BAND(Random,1023);
    if BAND(increment1,1) = 0 then inc(increment1);{pour avoir un nombre premier avec 1024}
    whichClefExacte := BAND((whichClefExacte+increment1),1023);
    clefHashExacteInitiale := whichClefExacte;

    (** on cherche si la position apparait dans la HashTable  dans la suite clefHashExacteInitiale,
    clefHashExacteInitiale + increment1, clefHashExacteInitiale + 2*increment1, ...  **)
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte],codagePosition do
        begin
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte]) = 0 then
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacte := false;
              inc(nbNouvellesEntreesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          if ligne1 = platLigne1 then
          if ligne2 = platLigne2 then
          if ligne3 = platLigne3 then
          if ligne4 = platLigne4 then
          if ligne5 = platLigne5 then
          if ligne6 = platLigne6 then
          if ligne7 = platLigne7 then
          if ligne8 = platLigne8 then
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte]) = couleurCodage then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacte := true;
              flags := BAND(flags,BNOT(kMaskLiberee));  {elle n'est plus liberee}
              inc(nbPositionsRetrouveesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          whichClefExacte := BAND((whichClefExacte+increment1),1023);
          inc(longueurCollisionPath);
        end;
     until (longueurCollisionPath > 12);

    SetQDGlobalsRandomSeed(clefHashExacteInitiale+codagePosition.platLigne2+codagePosition.platLigne7);
    increment2 := BAND(Random,1023);
    if BAND(increment2,1) = 0 then inc(increment2); {pour avoir un nb premier avec 1024}

    (** on cherche si la position apparait dans la HashTable avec le cycle d'increment2 **)
    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte],codagePosition do
        begin
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte]) = 0 then
            begin
              (** une place vide : on peut stopper la recherche **)
              InfoTrouveeDansHashTableExacte := false;
              inc(nbNouvellesEntreesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          if ligne1 = platLigne1 then
          if ligne2 = platLigne2 then
          if ligne3 = platLigne3 then
          if ligne4 = platLigne4 then
          if ligne5 = platLigne5 then
          if ligne6 = platLigne6 then
          if ligne7 = platLigne7 then
          if ligne8 = platLigne8 then
          if GetTraitDansHashExacte(quelleHashTableExacte^[whichClefExacte]) = couleurCodage then
            begin
              (** on a trouve la position dans la table **)
              InfoTrouveeDansHashTableExacte := true;
              flags := BAND(flags,BNOT(kMaskLiberee));  {elle n'est plus liberee}
              inc(nbPositionsRetrouveesHashTableExactes);
              exit(InfoTrouveeDansHashTableExacte);
            end;
          whichClefExacte := BAND((whichClefExacte+increment2),1023);
          inc(longueurCollisionPath);
        end;
    until (longueurCollisionPath > 12);

    InfoTrouveeDansHashTableExacte := false;


    (** on cherche une place liberee dans la HashTable **)

    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      if BAND(quelleHashTableExacte^[whichClefExacte].flags,kMaskLiberee) <> 0 then
        begin
          inc(nbNouvellesEntreesHashTableExactes);
          exit(InfoTrouveeDansHashTableExacte);  (** trouvé une place liberee **)
        end;
      whichClefExacte := BAND((whichClefExacte+increment1),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      if BAND(quelleHashTableExacte^[whichClefExacte].flags,kMaskLiberee) <> 0 then
        begin
          inc(nbNouvellesEntreesHashTableExactes);
          exit(InfoTrouveeDansHashTableExacte);  (** trouvé une place liberee  **)
        end;
      whichClefExacte := BAND((whichClefExacte+increment2),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    (** collision : on ecrase une place le plus bas possible dans l'arbre  **)

    inc(nbCollisionsHashTableExactes);
    minProf := 100000;


    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte] do
        begin
          if profondeur < minProf then
		        begin
              clefAEcraser := whichClefExacte;
              minProf := profondeur;
            end;
        end;
      whichClefExacte := BAND((whichClefExacte+increment1),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    whichClefExacte := clefHashExacteInitiale;
    longueurCollisionPath := 0;
    repeat
      with quelleHashTableExacte^[whichClefExacte] do
        begin
          if profondeur < minProf then
		        begin
              clefAEcraser := whichClefExacte;
              minProf := profondeur;
            end;
        end;
      whichClefExacte := BAND((whichClefExacte+increment2),1023);
      inc(longueurCollisionPath);
    until (longueurCollisionPath > 12);

    {
    WriteNumAt('minProf = ',minProf,10,40);
    WriteNumAt('clefAEcraser = ',clefAEcraser,10,50);
    SysBeep(0);
    AttendFrappeClavier;
    }

    whichClefExacte := clefAEcraser;  (** on ecrase cette position **)
  end;



procedure WritelnBornesDansRapport(var bornes : DecompressionHashExacteRec);
var k : SInt32;
begin
  with bornes do
    begin
      for k := 1 to nbreDeltaSuccessifs do
        begin
          WriteNumDansRapport('delta = ',ThisDeltaFinal(k));
          WriteNumDansRapport(' :   valMin[',k);
          WriteNumDansRapport('] = ',valMin[k]);
          WriteNumDansRapport(',  coupesMin[',k);
          WriteNumDansRapport('] = ',nbArbresCoupesValMin[k]);
          WriteNumDansRapport(',  moveMin[',k);
          WriteStringAndCoupDansRapport('] = ',coupDeCetteValMin[k]);
          WriteNumDansRapport(',  valMax[',k);
          WriteNumDansRapport('] = ',valMax[k]);
          WriteNumDansRapport(',  coupesMax[',k);
          WritelnNumDansRapport('] = ',nbArbresCoupesValMax[k]);
        end;
    end;
end;


function MeilleurCoupEstStockeDansLesBornes(const bornes : DecompressionHashExacteRec; var meilleurCoup,valeurDeLaPosition : SInt32) : boolean;
var coup : SInt32;
begin
   with bornes do
    begin
      coup := coupDeCetteValMin[nbreDeltaSuccessifs];

      if (coup = 0) or (valMin[nbreDeltaSuccessifs] <> valMax[nbreDeltaSuccessifs])
      then
        MeilleurCoupEstStockeDansLesBornes := false
      else
        begin
          MeilleurCoupEstStockeDansLesBornes := true;
          meilleurCoup := coup;
          valeurDeLaPosition := valMin[nbreDeltaSuccessifs];
        end
    end;
end;


function VerificationAssertionsSurLeMeilleurCoup(meilleurCoup : SInt32; var bornes : DecompressionHashExacteRec; fonctionAppelante : String255) : OSErr;
var meilleurCoupParBornes : SInt16;
    erreur : OSErr;
begin
  erreur := 0;

  with bornes do
    if (valMin[nbreDeltaSuccessifs] = valMax[nbreDeltaSuccessifs])
      then
        begin
          meilleurCoupParBornes := coupDeCetteValMin[nbreDeltaSuccessifs];

          if (meilleurCoupParBornes <> 0) and
             (meilleurCoupParBornes <> meilleurCoup) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante = '+fonctionAppelante);
              WritelnStringAndCoupDansRapport('meilleurCoupParBornes = ',meilleurCoupParBornes);
              WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
              WritelnDansRapport('ASSERT (meilleurCoupParBornes <> meilleurCoup) !!');
              erreur := 1;
            end;
        end;

  if (erreur <> 0) then
    begin
      SysBeep(0);
      WritelnBornesDansRapport(bornes);
      AttendFrappeClavier;
      LanceInterruptionSimple('VerificationAssertionsSurLeMeilleurCoup');
    end;

  VerificationAssertionsSurLeMeilleurCoup := erreur;
end;



function VerificationAssertionsSurLesBornes(var bornes : DecompressionHashExacteRec; fonctionAppelante : String255) : OSErr;
var k : SInt32;
    erreur : OSErr;
begin
  erreur := 0;
  VerificationAssertionsSurLesBornes := 0;

  with bornes do
    begin

      {verification de la parite des bornes}
      for k := 1 to nbreDeltaSuccessifs do
        if (BAND(valMin[k],$01) <> 0) and (erreur = 0) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : valMin[k] impair !!');
            erreur := 1;
          end;

      for k := 1 to nbreDeltaSuccessifs do
        if (BAND(valMax[k],$01) <> 0) and (erreur = 0) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : valMax[k] impair !!');
            erreur := 2;
          end;

      {verification de la coherence}
      for k := 1 to nbreDeltaSuccessifs do
        if (valMin[k] > valMax[k]) and (erreur = 0) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT (valMin[k] > valMax[k]) !!');
            erreur := 3;
          end;

      {verification des sens de variation}
      (*
      for k := 2 to nbreDeltaSuccessifs do
        if (valMin[k] > valMin[k-1]) and (erreur = 0)  then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : sens de variation des valMin[k] !!');
            erreur := 4;
          end;

      for k := 2 to nbreDeltaSuccessifs do
        if (valMax[k] < valMax[k-1]) and (erreur = 0)  then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT : sens de variation des valMax[k] !!');
            erreur := 5;
          end;
      *)

      {verification des intervalles}
      for k := 1 to nbreDeltaSuccessifs do
        if ((valMin[k] < -64) or (valMin[k] > 64)) and (erreur = 0) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT valMin[k] hors de l''intervalle !!');
            erreur := 6;
          end;

      for k := 1 to nbreDeltaSuccessifs do
        if ((valMax[k] < -64) or (valMax[k] > 64)) and (erreur = 0) then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('dans VerificationAssertionSurLesBornes, fonction appelante ='+fonctionAppelante);
            WritelnDansRapport('ASSERT valMax[k] hors de l''intervalle !!');
            erreur := 7;
          end;

    end;

  if (erreur <> 0) then
    begin
      SysBeep(0);
      WritelnBornesDansRapport(bornes);
      AttendFrappeClavier;
      LanceInterruptionSimple('VerificationAssertionsSurLesBornes');
    end;

  VerificationAssertionsSurLesBornes := erreur;
end;

procedure PutGarbageInBornes(var bornes : DecompressionHashExacteRec);
var k : SInt32;
begin
  with bornes do
	  for k := 1 to nbreDeltaSuccessifs do
	    begin
	      valMin[k]               := 1355 + k;
	      nbArbresCoupesValMin[k] := -14;

	      valMax[k]               := -101 - k;
	      nbArbresCoupesValMax[k] := -37;
	    end;
end;



procedure DecompresserBornesHashTableExacte(var whichElement : HashTableExacteElement; var bornes : DecompressionHashExacteRec);
var k : SInt32;
    aux,aux2 : SInt8;
begin
  with whichElement, bornes do
    begin

      for k := 1 to nbreDeltaSuccessifs do
        begin
          aux := bornesMin[k];
          aux2 := BAND(aux,$FE);
          valMin[k]               := aux2;
          nbArbresCoupesValMin[k] := BAND(aux,$01);
          {
          WritelnNumDansRapport('aux(min) = ',aux);
          WritelnNumDansRapport('aux2(min) = ',aux2);
          }
          aux := bornesMax[k];
          aux2 := BAND(aux,$FE);
          valMax[k]               := aux2;
          nbArbresCoupesValMax[k] := BAND(aux,$01);
          {
          WritelnNumDansRapport('aux(max) = ',aux);
          WritelnNumDansRapport('aux2(max) = ',aux2);
          }
          coupDeCetteValMin[k] := coupsDesBornesMin[k];
        end;

    end;

  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'DecompresserBornesHashTableExacte') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans DecompresserBornesHashTableExacte');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure CompresserBornesDansHashTableExacte(var whichElement : HashTableExacteElement; var bornes : DecompressionHashExacteRec);
var k : SInt32;
begin

  with whichElement, bornes do
    begin
      for k := 1 to nbreDeltaSuccessifs do
        begin

          bornesMin[k] := valMin[k];
          {if BAND(bornesMin[k],$01) <> 0 then
            begin
              SysBeep(0);
              WritelnDansRapport('ASSERT : bornesMin[k] impair dans CompresserBornesDansHashTableExacte');
              AttendFrappeClavier;
            end;}
          if (nbArbresCoupesValMin[k] > 0)
            then bornesMin[k] := BOR(bornesMin[k],$01);

          bornesMax[k] := valMax[k];
          {if BAND(bornesMax[k],$01) <> 0 then
            begin
              SysBeep(0);
              WritelnDansRapport('ASSERT : bornesMax[k] impair dans CompresserBornesDansHashTableExacte');
              AttendFrappeClavier;
            end;}
          if (nbArbresCoupesValMax[k] > 0)
            then bornesMax[k] := BOR(bornesMax[k],$01);

          coupsDesBornesMin[k] := coupDeCetteValMin[k];
        end;
    end;

  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'CompresserBornesDansHashTableExacte') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans CompresserBornesDansHashTableExacte');
      WritelnDansRapport('');
    end;

  if VerificationAssertionsSurLeMeilleurCoup(GetBestDefenseDansHashExacte(whichElement),bornes,'CompresserBornesDansHashTableExacte') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans CompresserBornesDansHashTableExacte');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure AugmentationMinorant(newValeurMin,newDeltaMin,coup,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello; fonctionAppelante : String255);
var k,index,aux,coupAux : SInt32; {$UNUSED fonctionAppelante,couleur,plat}
    {$IFC USE_DEBUG_STEP_BY_STEP}
    dummyLong : SInt32;
    {$ENDC}
begin

  {$IFC USE_DEBUG_STEP_BY_STEP}
  if (coup = 0) and (newValeurMin > -64) and (bornes.valMax[IndexOfThisDelta(newDeltaMin)] <= newValeurMin) then
    begin
      SysBeep(0);
      WritelnStringDansRapport('Vous avez sans doute trouvé un bug, coup = 0 dans AugmentationMinorant! fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnNumDansRapport('newValeurMin = ',newValeurMin);
      WritelnNumDansRapport('bornes.valMin[IndexOfThisDelta(newDeltaMin)] = ',bornes.valMin[IndexOfThisDelta(newDeltaMin)]);
      WritelnNumDansRapport('bornes.valMax[IndexOfThisDelta(newDeltaMin)] = ',bornes.valMax[IndexOfThisDelta(newDeltaMin)]);
      WritelnNumDansRapport('newDeltaMin = ',newDeltaMin);
      WritelnDansRapport('');
    end;
  {$ENDC}

  if (newValeurMin >= -64) and (newValeurMin <= 64) then
	  with bornes do
    begin
      index := IndexOfThisDelta(newDeltaMin);

      for k := 1 to index do
        begin
          if (valMin[k] = newValeurMin) and (nbArbresCoupesValMin[k] > 0) then
            begin
              valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0
	              else nbArbresCoupesValMin[k] := 1;
            end else
          if (valMin[k] < newValeurMin) then
	          begin
	            valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0
	              else nbArbresCoupesValMin[k] := 1;
	          end else
	        if (valMin[k] = newValeurMin) and (nbArbresCoupesValMin[k] = 0) and
	           (coupDeCetteValMin[k] = 0) and (newDeltaMin = kDeltaFinaleInfini) then
            begin
              valMin[k]            := newValeurMin;
	            coupDeCetteValMin[k] := coup;
	            if (newDeltaMin = kDeltaFinaleInfini)
	              then nbArbresCoupesValMin[k] := 0
	              else nbArbresCoupesValMin[k] := 1;
            end

        end;

      for k := 1 to index do
		    if (newValeurMin > valMax[k]) and (nbArbresCoupesValMax[k] <> 0)
		      then valMax[k] := newValeurMin;

		  {quand meme, on prefere l'information sure a 100%}
		  if (newDeltaMin <> kDeltaFinaleInfini) then
		    begin
		      aux     := valMin[nbreDeltaSuccessifs];
		      coupAux := coupDeCetteValMin[nbreDeltaSuccessifs];
		      for k := 1 to index do
		        if (valMin[k] <= aux) then
		          begin
		            valMin[k] := aux;
		            if coupAux <> 0 then coupDeCetteValMin[k] := coupAux;
		            nbArbresCoupesValMin[k] := 0;
		          end;
		    end;
    end;

	{$IFC USE_DEBUG_STEP_BY_STEP}
	if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
	                              gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
			WriteDansRapport('AugmentationMinorant : ');
		  WriteNumDansRapport('newValeurMin = ',newValeurMin);
		  WriteNumDansRapport(',   newDeltaMin = ',newDeltaMin);
		  WriteStringAndCoupDansRapport(',   coup = ',coup);
		  WritelnDansRapport(',   fonctionAppelante = '+fonctionAppelante);

		  index := IndexOfThisDelta(newDeltaMin);
		  WritelnNumDansRapport('index = ',index);
		  WritelnNumDansRapport('valMin['+NumEnString(newDeltaMin)+'] = ',bornes.valMin[index]);
		  WritelnNumDansRapport('valMax['+NumEnString(newDeltaMin)+'] = ',bornes.valMax[index]);
		  WritelnStringAndCoupDansRapport('coupDeCetteValMin['+NumEnString(newDeltaMin)+'] = ',bornes.coupDeCetteValMin[index]);
		  WritelnNumDansRapport('en SInt16 : coupDeCetteValMin['+NumEnString(newDeltaMin)+'] = ',bornes.coupDeCetteValMin[index]);
		  WritelnNumDansRapport('nbArbresCoupesValMin['+NumEnString(newDeltaMin)+'] = ',bornes.nbArbresCoupesValMin[index]);
		  WritelnDansRapport('');
		end;
  {$ENDC}

  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'AugmentationMinorant') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans AugmentationMinorant,   fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WriteNumDansRapport('newValeurMin = ',newValeurMin);
		  WriteNumDansRapport(',   newDeltaMin = ',newDeltaMin);
		  WriteStringAndCoupDansRapport(',   coup = ',coup);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure DiminutionMajorant(newValeurMax,newDeltaMax,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello; fonctionAppelante : String255);
var k,index,aux : SInt32;  {$UNUSED fonctionAppelante,couleur,plat}
begin

  if (newValeurMax >= -64) and (newValeurMax <= 64) then
  with bornes do
    begin
      index := IndexOfThisDelta(newDeltaMax);

      for k := 1 to index do
        begin
          if (valMax[k] = newValeurMax) and (nbArbresCoupesValMax[k] > 0) then
            begin
              valMax[k] := newValeurMax;
	            if (newDeltaMax = kDeltaFinaleInfini)
	              then nbArbresCoupesValMax[k] := 0
	              else nbArbresCoupesValMax[k] := 1;
            end else
	        if (valMax[k] > newValeurMax) then
	          begin
	            valMax[k] := newValeurMax;
	            if (newDeltaMax = kDeltaFinaleInfini)
	              then nbArbresCoupesValMax[k] := 0
	              else nbArbresCoupesValMax[k] := 1;
	          end;
        end;

      for k := 1 to index do
		    if (valMin[k] > newValeurMax ) and (nbArbresCoupesValMin[k] <> 0)
		      then valMin[k] := newValeurMax;

		  {quand meme, on prefere l'information sure a 100%}
			if (newDeltaMax <> kDeltaFinaleInfini) then
			  begin
			    aux := valMax[nbreDeltaSuccessifs];
			    for k := 1 to index do
			      if (valMax[k] >= aux) then
			        begin
			          valMax[k] := aux;
			          nbArbresCoupesValMax[k] := 0;
			        end;
			  end;
    end;

  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
                                gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
      WriteDansRapport('DiminutionMajorant : ');
      WriteNumDansRapport('newValeurMax = ',newValeurMax);
      WriteNumDansRapport(',   newDeltaMax = ',newDeltaMax);
      WritelnDansRapport(',   fonctionAppelante = '+fonctionAppelante);
      WritelnDansRapport('');
    end;
  {$ENDC}

  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'DiminutionMajorant') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans DiminutionMajorant,   fonctionAppelante = '+fonctionAppelante);
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WriteNumDansRapport('newValeurMax = ',newValeurMax);
      WriteNumDansRapport(',   newDeltaMax = ',newDeltaMax);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure EnleverBornesMinPeuSuresDesAutresCoups(whichLegalMoves : CoupsLegauxHashPtr; clefHashExacte,couleur : SInt32; var bornes : DecompressionHashExacteRec; var plat : plateauOthello);
var n,k,square : SInt32; {$UNUSED couleur,plat}
    coupsLegaux : SquareSet;
begin
  n := whichLegalMoves^[clefHashExacte,0];
  if (n > 0) then
    begin
      coupsLegaux := [];
      for k := 1 to n do
        begin
          square := whichLegalMoves^[clefHashExacte,k];
          if (square <> 0) then
            coupsLegaux := coupsLegaux + [square];
        end;

      with bornes do
	      for k := 1 to nbreDeltaSuccessifs - 1 do
	        begin
	          square := coupDeCetteValMin[k];
	          if (square <> 0) and not(square in coupsLegaux) then
	            begin
	              valMin[k]               := valMin[nbreDeltaSuccessifs];
	              coupDeCetteValMin[k]    := coupDeCetteValMin[nbreDeltaSuccessifs];
	              nbArbresCoupesValMin[k] := 0;
	            end;
	        end;
    end;

  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(MakePositionEtTrait(plat,couleur),dummyLong,
                                gDebuggageAlgoFinaleStepByStep.positionsCherchees) then
	  begin
	    WritelnDansRapport('');
      WriteDansRapport('EnleverBornesMinPeuSuresDesAutresCoups : ');
      WritelnNumDansRapport('nouveaux nbre de coups legaux  = ',n);
      WritelnBornesDansRapport(bornes);
      WritelnDansRapport('');
      WritelnDansRapport('');
    end;
  {$ENDC}

  {$IFC USE_VERIFICATION_ASSERTIONS_BORNES}
  if VerificationAssertionsSurLesBornes(bornes,'EnleverBornesMinPeuSuresDesAutresCoups') <> NoErr then
    begin
      WritelnDansRapport('Erreur dans EnleverBornesMinPeuSuresDesAutresCoups !!');
      WritelnDansRapport('');
      WritelnPositionEtTraitDansRapport(plat,couleur);
      WritelnDansRapport('');
    end;
  {$ENDC}
end;

procedure SetEndgameValuesInHashExacte(clefHash,nbVides : SInt32; jeu : PositionEtTraitRec; valMin,valMax,meilleurCoup,deltaFinale : SInt32);
var nroTableExacte,laClefExacte,bestDefDansHash : SInt32;
    valeurDeLaPositionDansHash : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    quelleHashTableCoupsLegaux : CoupsLegauxHashPtr;
    codagePosition : codePositionRec;
    bornes : DecompressionHashExacteRec;
    dejaDansHash : boolean;
    avecVerifAssertionsBornes : boolean;
begin

  avecVerifAssertionsBornes := false;


  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
    then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Entrée dans SetEndgameValuesInHashExacte :');
        WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
        WritelnNumDansRapport('valMin = ',valMin);
        WritelnNumDansRapport('valMax = ',valMax);
        WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
        WritelnDansRapport('');
      end;
  {$ENDC}



  if (odd(valMin) or odd(valMax)) then
    begin
      WritelnDansRapport('Erreur : valMin ou valMax est impair dans SetEndgameValuesInHashExacte!! Prévenez Stéphane');
      WritelnNumDansRapport('valMin = ',valMin);
      WritelnNumDansRapport('valMax = ',valMax);
      exit(SetEndgameValuesInHashExacte);
    end;

  if (valMin > valMax) then
    begin
      WritelnDansRapport('Erreur : valMin > valMax dans SetEndgameValuesInHashExacte!! Prévenez Stéphane');
      WritelnNumDansRapport('valMin = ',valMin);
      WritelnNumDansRapport('valMax = ',valMax);
      exit(SetEndgameValuesInHashExacte);
    end;





  nroTableExacte := BAND(clefHash div 1024,nbTablesHashExactesMoins1);
  laClefExacte := BAND(clefHash,1023);

  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  quelleHashTableCoupsLegaux := CoupsLegauxHash[nroTableExacte];
  CreeCodagePosition(jeu.position,GetTraitOfPosition(jeu),nbVides,codagePosition);

  dejaDansHash := InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,clefHash,laClefExacte);

  if dejaDansHash
    then
      begin
        if (valMin <= -64) and (meilleurCoup <> 0) then
          begin
            (*
            bestDefDansHash := GetBestDefenseDansHashExacte(quelleHashTableExacte^[laClefExacte]);
            WritelnStringAndCoupDansRapport(CoupEnStringEnMajuscules(meilleurCoup)+ ' vs ',bestDefDansHash);
            if (bestDefDansHash <> meilleurCoup) and (bestDefDansHash <> 0)
              then
                begin
                  meilleurCoup := 0;
                  SetBestDefenseDansHashExacte(0,quelleHashTableExacte^[laClefExacte]);
                end;
            *)
          end;
        DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
        if MeilleurCoupEstStockeDansLesBornes(bornes,bestDefDansHash,valeurDeLaPositionDansHash)
          then meilleurCoup := bestDefDansHash;

        SetBestDefenseDansHashExacte(meilleurCoup,quelleHashTableExacte^[laClefExacte]);
      end
    else
      begin
        ExpandHashTableExacte(quelleHashTableExacte^[laClefExacte],quelleHashTableCoupsLegaux,codagePosition,laClefExacte);
        if (meilleurCoup <> 0)
          then SetBestDefenseDansHashExacte(meilleurCoup,quelleHashTableExacte^[laClefExacte]);
      end;

  DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
  AugmentationMinorant(valMin,deltaFinale,meilleurCoup,GetTraitOfPosition(jeu),bornes,jeu.position,'SetEndgameValuesInHashExacte');
  DiminutionMajorant(valMax,deltaFinale,GetTraitOfPosition(jeu),bornes,jeu.position,'SetEndgameValuesInHashExacte');
  if avecVerifAssertionsBornes and (VerificationAssertionsSurLesBornes(bornes,'SetEndgameValuesInHashExacte') <> NoErr)
    then WritelnDansRapport('ASSERT : erreur sur les bornes dans SetEndgameValuesInHashExacte (cf plus haut)');
  CompresserBornesDansHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);

  {$IFC USE_DEBUG_STEP_BY_STEP}
  if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
    then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Sortie de SetEndgameValuesInHashExacte :');
        WritelnNumDansRapport('valMin = ',valMin);
        WritelnNumDansRapport('valMax = ',valMax);
        WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
        WritelnDansRapport('');
      end;
  {$ENDC}

end;


function GetEndgameBornesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
var nbVides : SInt32;
    laClefExacte,nroTableExacte : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    codagePosition : codePositionRec;
begin

  nbVides := NbCasesVidesDansPosition(plat.position);
	nroTableExacte := BAND(hashKey div 1024,nbTablesHashExactesMoins1);
	laClefExacte := BAND(hashKey,1023);
  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  CreeCodagePosition(plat.position,GetTraitOfPosition(plat),nbVides,codagePosition);

  if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,hashKey,laClefExacte)
    then
      begin
        DecompresserBornesHashTableExacte(quelleHashTableExacte^[laClefExacte],bornes);
        GetEndgameBornesInHashTableAtThisHashKey := true;

        (*
        WritelnDansRapport('OK : position trouvee (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        {WritelnBornesDansRapport(bornes);}
        WritelnNumDansRapport('valMinPourNoir = ',valMinPourNoir);
        WritelnNumDansRapport('valMaxPourNoir = ',valMaxPourNoir);
        WritelnDansRapport('');
        *)
      end
    else
      begin
        GetEndgameBornesInHashTableAtThisHashKey := false;

        (*
        WritelnDansRapport('BIZARRE : non trouvee dans hash dans GetEndgameValuesInHashTableAtThisHashKey (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        WritelnDansRapport('');
        *)
      end;
end;

function GetEndgameValuesInHashTableAtThisHashKey(plat : PositionEtTraitRec; hashKey,deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
var nbVides : SInt32;
    laClefExacte,nroTableExacte : SInt32;
    quelleHashTableExacte : HashTableExactePtr;
    codagePosition : codePositionRec;
begin

  nbVides := NbCasesVidesDansPosition(plat.position);
	nroTableExacte := BAND((hashKey div 1024),nbTablesHashExactesMoins1);
	laClefExacte := BAND(hashKey,1023);
  quelleHashTableExacte := HashTableExacte[nroTableExacte];
  CreeCodagePosition(plat.position,GetTraitOfPosition(plat),nbVides,codagePosition);

  if InfoTrouveeDansHashTableExacte(codagePosition,quelleHashTableExacte,hashKey,laClefExacte)
    then
      begin
        GetEndgameValuesInHashTableElement(quelleHashTableExacte^[laClefExacte],deltaFinale,valMinPourNoir,valMaxPourNoir);
        GetEndgameValuesInHashTableAtThisHashKey := true;

        (*
        WritelnDansRapport('OK : position trouvee (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        {WritelnBornesDansRapport(bornes);}
        WritelnNumDansRapport('valMinPourNoir = ',valMinPourNoir);
        WritelnNumDansRapport('valMaxPourNoir = ',valMaxPourNoir);
        WritelnDansRapport('');
        *)
      end
    else
      begin
        GetEndgameValuesInHashTableAtThisHashKey := false;
        valMinPourNoir := -64;
        valMaxPourNoir :=  64;

        (*
        WritelnDansRapport('BIZARRE : non trouvee dans hash dans GetEndgameValuesInHashTableAtThisHashKey (1)');
        WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
        WritelnDansRapport('');
        *)
      end;
end;



function GetEndgameValuesInHashTableFromThisNode(plat : PositionEtTraitRec; G : GameTree; deltaFinale : SInt32; var valMinPourNoir,valMaxPourNoir : SInt32) : boolean;
var myHashIndex,lastPlayedMove : SInt32;
    ok : boolean;
begin
	myHashIndex := CalculateHashIndexFromThisNode(plat,G,lastPlayedMove);

	ok := GetEndgameValuesInHashTableAtThisHashKey(plat,myHashIndex,deltaFinale,valMinPourNoir,valMaxPourNoir);

	if (ok and (valMinPourNoir > valMaxPourNoir)) then
	  begin
	    WritelnDansRapport('ASSERT : (valMinPourNoir > valMaxPourNoir) dans GetEndgameValuesInHashTableFromThisNode !');
	    WritelnDansRapport('J''ai essayé de trouver les valeurs dans la hash pour la position suivante : ');
      WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
      WritelnNumDansRapport('hash = ',myHashIndex);
	  end;

	GetEndgameValuesInHashTableFromThisNode := ok;
end;


function GetEndgameBornesDansHashExacteAfterThisSon(whichSon : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var bornes : DecompressionHashExacteRec) : boolean;
var k,hashKeyAfterCoup : SInt32;
    platAux : PositionEtTraitRec;
    aux : SInt32;
begin

  GetEndgameBornesDansHashExacteAfterThisSon := false;

  with bornes do
    for k := 1 to kNbreMaxDeltasSuccessifsDansHashExacte do
      begin
        valMin[k]               := -64;
        valMax[k]               := 64;
        nbArbresCoupesValMin[k] := 0;
        nbArbresCoupesValMax[k] := 0;
        coupDeCetteValMin[k]    := 0;
      end;

  (* WritelnDansRapport('');
     WritelnDansRapport('Entrée dans GetEndgameBornesDansHashExacteAfterThisSon'); *)

  platAux := platDepart;

  if UpdatePositionEtTrait(platAux,whichSon)
    then
      begin
	      hashKeyAfterCoup := BXOR(clefHashage, (IndiceHash^^[GetTraitOfPosition(platAux),whichSon]));

	      if GetEndgameBornesInHashTableAtThisHashKey(platAux,hashKeyAfterCoup,bornes)
	        then
	          begin
	            GetEndgameBornesDansHashExacteAfterThisSon := true;

	            if GetTraitOfPosition(platDepart) <> GetTraitOfPosition(platAux) then
	              begin
	                with bornes do
  	                for k := 1 to nbreDeltaSuccessifs do
  	                  begin
  	                    aux       := valMin[k];
  	                    valMin[k] := -valMax[k];
  	                    valMax[k] := -aux;
  	                    aux                     := nbArbresCoupesValMin[k];
  	                    nbArbresCoupesValMin[k] := nbArbresCoupesValMax[k];
  	                    nbArbresCoupesValMax[k] := aux;
  	                  end;
	              end;



	            (* WritelnNumDansRapport('trouvé '+CoupEnString(coup,true)+' => ',valMin[nbreDeltaSuccessifs]); *)
	          end
	        else
	          begin
	            (* WritelnDansRapport('non trouvé '+ CoupEnString(coup,true)); *)
	          end;
	    end
	  else
	    begin
	      WritelnDansRapport('HORREUR ! not(UpdatePositionEtTrait(platAux,coup) dans GetEndgameBornesDansHashExacteAfterThisSon !!!');
	    end;

end;


function GetEndgameScoreDansHashExacteAfterThisSon(whichSon : SInt32; platDepart : PositionEtTraitRec; clefHashage : SInt32; var score : SInt32) : boolean;
var bornes : DecompressionHashExacteRec;
begin
  GetEndgameScoreDansHashExacteAfterThisSon := false;

  if GetEndgameBornesDansHashExacteAfterThisSon(whichSon, platDepart, clefHashage, bornes) then
    begin
      if (bornes.valMin[nbreDeltaSuccessifs] = bornes.valMax[nbreDeltaSuccessifs]) then
        begin
          GetEndgameScoreDansHashExacteAfterThisSon := true;
          score := bornes.valMin[nbreDeltaSuccessifs];
        end;
    end;
end;





function CalculateHashIndexFromThisNode(var positionCherchee : PositionEtTraitRec; whichNode : GameTree; var dernierCoup : SInt32) : SInt32;
var gameTreeDeLaPosition : GameTree;
    hashValue : SInt32;
    prop : PropertyPtr;
    listeDesCoups,L : PropertyList;
    coup,pere,couleur,nbreFils : SInt16;
begin
  hashValue := 0;
  dernierCoup := 0;

  if (whichNode <> NIL) then
    begin
      nbreFils := NumberOfSons(whichNode);
      SearchPositionFromThisNode(positionCherchee,whichNode,gameTreeDeLaPosition);
      coup := 0;
      pere := 0;

      if (gameTreeDeLaPosition <> NIL) then
        begin
          listeDesCoups := CreateListeDesCoupsJusqua(gameTreeDeLaPosition);

          if (listeDesCoups <> NIL) then
            begin
              L := listeDesCoups;
              while (L <> NIL) do
                begin
                  prop := HeadOfPropertyList(L);
                  if (prop <> NIL) then
                    begin
                      pere := coup;
                      coup := GetOthelloSquareOfProperty(prop^);
                      couleur := GetCouleurOfMoveProperty(prop^);

                      if (pere >= 11) and (pere <= 88) then
                        hashValue := BXOR(hashValue , (IndiceHash^^[couleur,pere]));

                    end;
                  L := TailOfPropertyList(L);
                end;
              dernierCoup := coup;
            end;
          DisposePropertyList(listeDesCoups);

          if (NumberOfSons(whichNode) <> nbreFils) and
             (GetFather(gameTreeDeLaPosition) = whichNode) and
             not(HasSons(gameTreeDeLaPosition)) and
             IsAVirtualNode(gameTreeDeLaPosition)
            then DeleteThisSon(whichNode,gameTreeDeLaPosition);

        end;

      if (GetTraitOfPosition(positionCherchee) <> pionVide) and (dernierCoup >= 11) and (dernierCoup <= 88) then
        hashValue := BXOR(hashValue , (IndiceHash^^[GetTraitOfPosition(positionCherchee),dernierCoup]));

    end;

  (*
  WritelnDansRapport('•••••••• résultat de CalculateHashIndexFromThisNode : ••••••••••••••');
  WritelnPositionEtTraitDansRapport(positionCherchee.position,positionCherchee.trait);
  WritelnNumDansRapport('hashValue = ',hashValue);
  WritelnStringAndCoupDansRapport('dernierCoup = ',dernierCoup);
  WritelnDansRapport('');
  *)


  if dernierCoup = 0 then dernierCoup := 44;
  CalculateHashIndexFromThisNode := hashValue;

end;



procedure MetValeursDansHashExacte(clefHash,nbVides : SInt32; jeu : PositionEtTraitRec; valMin,valMax,meilleurCoup,deltaFinale,recursion : SInt32; const fonctionAppelante : String255);
var jeuEssai : PositionEtTraitRec;
    clefHashEssai,t,coup : SInt32;
begin {$UNUSED fonctionAppelante}
  if (GetTraitOfPosition(jeu) <> pionVide) and
     ((valMin > -64) or (valMax < 64) or (meilleurCoup <> 0)) then  {info interessante ?}
    begin

      (*
		  WritelnDansRapport('');
		  WritelnNumDansRapport('dans MetValeursDansHashExacte, recursion = ',recursion);
		  WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
		  WritelnNumDansRapport('clefHash = ',clefHash);
		  WritelnNumDansRapport('valMin = ',valMin);
		  WritelnNumDansRapport('valMax = ',valMax);
		  WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
		  *)


		  {$IFC USE_DEBUG_STEP_BY_STEP}
      if MemberOfPositionEtTraitSet(jeu,dummyLong,gDebuggageAlgoFinaleStepByStep.positionsCherchees)
        then
          begin
            WritelnDansRapport('');
            WritelnDansRapport('Avant appel de SetEndgameValuesInHashExacte dans MetValeursDansHashExacte :');
            WritelnPositionEtTraitDansRapport(jeu.position,GetTraitOfPosition(jeu));
            WritelnNumDansRapport('valMin = ',valMin);
            WritelnNumDansRapport('valMax = ',valMax);
            WritelnStringAndCoupDansRapport('meilleurCoup = ',meilleurCoup);
            WritelnNumDansRapport('recursion = ',recursion);
            WritelnDansRapport('fonctionAppelante = '+fonctionAppelante);
            WritelnDansRapport('');
          end;
      {$ENDC}

		  SetEndgameValuesInHashExacte(clefHash,nbVides,jeu,valMin,valMax,meilleurCoup,deltaFinale);

		  if (recursion > 0) then
		    begin
		      jeuEssai := jeu;
		      for t := 1 to 64 do
		        begin
		          coup := othellier[t];
			        if UpdatePositionEtTrait(jeuEssai,coup) then
			          begin
			            clefHashEssai := BXOR(clefHash , (IndiceHash^^[GetTraitOfPosition(jeuEssai),coup]));

			            if (GetTraitOfPosition(jeuEssai) = -GetTraitOfPosition(jeu)) then
			              if (coup = meilleurCoup)
			                then MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-valMax,-valMin,0,deltaFinale,recursion-1,'MetValeursDansHashExacte {1}')
			                else MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-valMax,     64,0,deltaFinale,recursion-1,'MetValeursDansHashExacte {2}');

			            if (GetTraitOfPosition(jeuEssai) =  GetTraitOfPosition(jeu)) then
			              if (coup = meilleurCoup)
			                then MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,valMin,valMax,0,deltaFinale,recursion-1,'MetValeursDansHashExacte {3}')
			                else MetValeursDansHashExacte(clefHashEssai,nbVides-1,jeuEssai,-64   ,valMax,0,deltaFinale,recursion-1,'MetValeursDansHashExacte {4}');

			            jeuEssai := jeu;
			          end;
			      end;
		    end;
	  end;
end;



procedure MetSousArbreRecursivementDansHashTable(G : GameTree; plat : PositionEtTraitRec; hashValue, nbVides, nbVidesMinimum : SInt32);
var valeurMin,valeurMax,bestScoreFilsConnu,meilleureDefense : SInt32;
    platEssai : PositionEtTraitRec;
    filsCourant,meilleurFils : GameTree;
    theSons,L : GameTreeList;
    square,hashValueEssai,recursion : SInt32;
    moveProperty : PropertyPtr;
begin

  (*
  WritelnNumDansRapport('---> Entrée dans MetSousArbreRecursivementDansHashTable, nbVides = ',nbVides);
  WritelnNumDansRapport('G = ',SInt32(G));
  WritelnPositionEtTraitDansRapport(plat.position,GetTraitOfPosition(plat));
  WritelnNumDansRapport('hashValue = ',hashValue);
  *)


  if (G <> NIL) and (nbVides >= nbVidesMinimum) then
    begin
		  if (GetTraitOfPosition(plat) <> pionVide) and
		     GetEndgameScoreDeCetteCouleurDansGameNode(G,GetTraitOfPosition(plat),valeurMin,valeurMax)
		    then
		      begin

		        (* a tout hasard, on remet la valeur de finale dans l'arbre, cela
		           permet de preciser certains scores sur des arbres bizarres fabriques
		           à la main par Marc Tastet, par exemple... *)
		        if NodeHasAPerfectScoreInformation(G)
		          then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflParfait,valeurMin,GetTraitOfPosition(plat),G)
		          else
		            begin
		              if valeurMin > 0 then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMin,GetTraitOfPosition(plat),G) else
		              if valeurMax < 0 then AjoutePropertyScoreExactPourCetteCouleurDansGameTree(ReflGagnant,valeurMax,GetTraitOfPosition(plat),G)

		              (*
		              else
		              if (valeurMin = 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMin = 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMax = 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMax = 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMin < 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMin < 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end else
		              if (valeurMax > 0) then
		                begin
		                  SysBeep(0);
                      WritelnDansRapport('ASSERT(valeurMax > 0) dans MetSousArbreRecursivementDansHashTable !!');
		                end;
		              *)
		            end;

		        meilleureDefense := 0;

		        if HasSons(G) then
		          begin

		            (* trouver le meilleur fils connu dans l'arbre de jeu *)
				        case GetTraitOfPosition(plat) of
				          pionBlanc : meilleurFils := TrouveMeilleurFilsBlanc(G,bestScoreFilsConnu);
				          pionNoir  : meilleurFils := TrouveMeilleurFilsNoir(G,bestScoreFilsConnu);
				        end;

				        (* a quelle case correspond-il ? *)
				        {if (bestScore > -64) then}
				          if not(GetSquareOfMoveInNode(meilleurFils,meilleureDefense))
				            then meilleureDefense := 0;

				        (* verifier que le score du meilleur fils connu est coherent avec le score du noeud courant *)
				        if (GetTraitOfPosition(plat) <> pionVide) and
				           (meilleureDefense >= 11) and (meilleureDefense <= 88) and
				           (plat.position[meilleureDefense] = pionVide)
				          then
  				          begin
  				            platEssai := plat;
  				            if not(UpdatePositionEtTrait(platEssai,meilleureDefense)) or                    { le fils n'est pas jouable }
  				               not((valeurMin <= bestScoreFilsConnu) and (bestScoreFilsConnu <= valeurMax))  { le score du meilleur fils connu n'est pas cohérent avec le score de notre noeud }
  				              then
  				                meilleureDefense := 0;
  				          end
  				        else
  				          meilleureDefense := 0;

				        (*
				        WritelnNumDansRapport('meilleurFils = ',SInt32(meilleurFils));
				        WritelnNumDansRapport(CoupEnString(meilleureDefense,true)+'  ==>  ',bestScoreFilsConnu);
				        *)

				      end;

				    (*
				    WritelnNumDansRapport('valeurMin = ',SInt32(valeurMin));
				    WritelnNumDansRapport('valeurMax = ',SInt32(valeurMax));
				    *)

		        if (nbVides > nbVidesMinimum)
		          then recursion := 1
		          else recursion := 0;

		        MetValeursDansHashExacte(hashValue,nbVides,plat,valeurMin,valeurMax,meilleureDefense,kDeltaFinaleInfini,recursion,'MetSousArbreRecursivementDansHashTable {1}');

		        EngineFeedHashValues(plat,nbVides,valeurMin,valeurMax,meilleureDefense);


		      end;

		  if (nbVides > nbVidesMinimum) and (GetTraitOfPosition(plat) <> pionVide) and HasSons(G) then
		    begin
		      theSons := GetSons(G);

		      (* itérer sur les fils dans l'arbre *)
		      L := theSons;
		      while (L <> NIL) do
		        begin
		          filsCourant := L^.head;

		          moveProperty := SelectFirstPropertyOfTypesInGameTree([BlackMoveProp,WhiteMoveProp],filsCourant);
		          if (moveProperty <> NIL) then
		            begin
				          square := GetOthelloSquareOfProperty(moveProperty^);
				          platEssai := plat;
				          if PlayMoveProperty(moveProperty^,platEssai) then
				            begin
				              hashValueEssai := BXOR(hashValue , (IndiceHash^^[GetTraitOfPosition(platEssai),square]) );
				              (* appel récursif *)
				              MetSousArbreRecursivementDansHashTable(filsCourant,platEssai,hashValueEssai,nbVides-1,nbVidesMinimum);
				            end;
				        end;

		          L := L^.tail;
		        end;
		    end;
		end;
end;


procedure MetSousArbreDansHashTableExacte(G : GameTree; nbVidesMinimum : SInt32);
var hashValue,dernierCoup,nbVides : SInt32;
    position : PositionEtTraitRec;
    ticks : SInt32;
begin

  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      positionsCherchees := MakeEmptyPositionEtTraitSet;
      actif := true;
      profMin := 0;
      if actif then AjouterPositionsDevantEtreDebugueesPasAPas(positionsCherchees);
    end;
  {$ENDC}


  if (G <> NIL) and GetPositionEtTraitACeNoeud(G, position, 'MetSousArbreDansHashTableExacte') then
    begin
      ticks := TickCount;
      {WritelnDansRapport('Entrée dans MetSousArbreDansHashTableExacte');}

      hashValue := CalculateHashIndexFromThisNode(position,G,dernierCoup);
      nbVides := NbCasesVidesDansPosition(position.position);
      if (nbVides >= nbVidesMinimum) then
        MetSousArbreRecursivementDansHashTable(G,position,hashValue,nbVides,nbVidesMinimum);

      {WritelnNumDansRapport('Temps de MetSousArbreDansHashTableExacte en ticks = ',TickCount - ticks);}
    end;

  {$IFC USE_DEBUG_STEP_BY_STEP}
  with gDebuggageAlgoFinaleStepByStep do
    begin
      DisposePositionEtTraitSet(positionsCherchees);
    end;
  {$ENDC}
end;


procedure LigneMilieuToMeilleureSuiteInfos(couleur, prof, lastMove : SInt32; startingPosition : PositionEtTraitRec; ligne : String255; var meilleureSuite : t_meilleureSuite);
var i, k, p, coup, profondeurCourante : SInt32;
   // valeurMinPourHash, valeurMaxPourHash : SInt32;
    next : SInt16;
    position : PositionEtTraitRec;
    copieDeClefHashage : SInt32;
    suiteLegale : boolean;
    debugage : boolean;
begin

    Discard(couleur);

    debugage := false;

    position := startingPosition;
    copieDeClefHashage := SetClefHashageGlobale(gClefHashage);


    if debugage then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('####################');
        WritelnDansRapport('Entree dans LigneMilieuToMeilleureSuiteInfos');
        WritelnDansRapport('ligne = '+ligne);
        WritelnNumDansRapport('prof = ',prof);
      end;


    { initialiser la matrice }
    for k := 1 to prof+1 do
      for i := 1 to prof+1 do
        meilleureSuite[i,k] := 0;

    profondeurCourante := prof;

    next := -1;
    suiteLegale := true;

    coup := lastMove;

    while (coup >= 11) and (coup <= 88) and suiteLegale do
      begin


        if debugage and ((prof - profondeurCourante) <= 3) then
          begin
            WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
            WritelnNumDansRapport('hash = ',gClefHashage);
            WritelnStringAndCoupDansRapport('lastMove = ',coup);
          end;


        gClefHashage := BXOR(gClefHashage , (IndiceHash^^[GetTraitOfPosition(position),coup]));

        (*
        if (GetTraitOfPosition(position) = couleur)
          then
            begin
              valeurMinPourHash := vMin;
              valeurMaxPourHash := vMax;
            end
          else
            begin
              valeurMinPourHash := -vMax;
              valeurMaxPourHash := -vMin;
            end;
         *)

        if debugage then
          WritelnDansRapport('Dans LineToHash,  profondeurCourante = '+NumEnString(profondeurCourante)+'   < -->  hash = '+NumEnString(gClefHashage));

        coup := ScannerStringPourTrouverCoup(next+2,ligne,next);

        (*
        if debugage and ((prof - profondeurCourante) <= 3) then
          begin
            WritelnNumDansRapport('vMin = ',vMin);
            WritelnNumDansRapport('vMax = ',vMax);
            WritelnStringAndCoupDansRapport('coup = ',coup);
            WritelnDansRapport('');
          end;
        *)

        if (coup >= 11) and (coup <= 88) then
          begin
            meilleureSuite[prof,profondeurCourante] := coup;

            suiteJoueeGlb^[profondeurCourante] := coup;

            if debugage then
              begin
                WritelnDansRapport('Je vais mettre les valeurs dans la hash pour la position suivante : ');
                WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
                WritelnNumDansRapport('hash = ',gClefHashage);
                // WritelnNumDansRapport('deltaFinale = ',deltaFinale);
              end;

            // MetValeursDansHashExacte(gClefHashage,profondeurCourante,position,valeurMinPourHash,valeurMaxPourHash,coup,deltaFinale,1,'LigneMilieuToMeilleureSuiteInfos');
          end;


        suiteLegale := suiteLegale and UpdatePositionEtTrait(position,coup);

        dec(profondeurCourante);
      end;


    for k := prof+1 downto 1 do
      for i := prof+1 downto 1 do
        meilleureSuite[k,i] := meilleureSuite[prof,i];


    if debugage then
      begin
        WritelnDansRapport('');
        for p := 64 downto 1 do
          begin
            WriteNumDansRapport('p = ',p);
            WriteDansRapport('  ligne = ');
            for k := prof downto 1 do
              begin
                coup := meilleureSuite[p , k];

                if (coup >= 11) and (coup <= 88) then
                  WriteDansRapport( CoupEnString(coup , true));
              end;
            WritelnDansRapport('');
          end;
      end;


    gClefHashage := copieDeClefHashage;
    TesterClefHashage(copieDeClefHashage,'LigneMilieuToMeilleureSuiteInfos');

    if debugage then
      begin
        WritelnDansRapport('Sortie de LigneMilieuToMeilleureSuiteInfos');
        WritelnDansRapport('####################');
        WritelnDansRapport('');
      end;

end;




procedure LigneFinaleToHashTable(couleur, prof, lastMove, vMin, vMax, deltaFinale : SInt32; startingPosition : PositionEtTraitRec; ligne : String255; var meilleureSuite : t_meilleureSuite);
var i, k, coup, profondeurCourante : SInt32;
    valeurMinPourHash, valeurMaxPourHash : SInt32;
    next : SInt16;
    position : PositionEtTraitRec;
    copieDeClefHashage : SInt32;
    suiteLegale : boolean;
    debugage : boolean;
begin
    debugage := (deltaFinale > 2000) and (vmin = vmax);
    debugage := false;

    position := startingPosition;
    copieDeClefHashage := SetClefHashageGlobale(gClefHashage);


    if debugage then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('####################');
        WritelnDansRapport('Entree dans LigneFinaleToHashTable');
        WritelnDansRapport('ligne = '+ligne);
      end;


    { initialiser la matrice }
    for k := 1 to prof+1 do
      for i := 1 to prof+1 do
        meilleureSuite[i,k] := 0;

    profondeurCourante := prof;

    next := -1;
    suiteLegale := true;

    coup := lastMove;

    while (coup >= 11) and (coup <= 88) and suiteLegale do
      begin


        if debugage and ((prof - profondeurCourante) <= 3) then
          begin
            WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
            WritelnNumDansRapport('hash = ',gClefHashage);
            WritelnStringAndCoupDansRapport('lastMove = ',coup);
          end;


        gClefHashage := BXOR(gClefHashage , (IndiceHash^^[GetTraitOfPosition(position),coup]));

        if (GetTraitOfPosition(position) = couleur)
          then
            begin
              valeurMinPourHash := vMin;
              valeurMaxPourHash := vMax;
            end
          else
            begin
              valeurMinPourHash := -vMax;
              valeurMaxPourHash := -vMin;
            end;

        if debugage then
          WritelnDansRapport('Dans LineToHash,  profondeurCourante = '+NumEnString(profondeurCourante)+'   < -->  hash = '+NumEnString(gClefHashage));

        coup := ScannerStringPourTrouverCoup(next+2,ligne,next);


        if debugage and ((prof - profondeurCourante) <= 3) then
          begin
            WritelnNumDansRapport('vMin = ',vMin);
            WritelnNumDansRapport('vMax = ',vMax);
            WritelnStringAndCoupDansRapport('coup = ',coup);
            WritelnDansRapport('');
          end;


        if (coup >= 11) and (coup <= 88) then
          begin
            meilleureSuite[prof,profondeurCourante] := coup;

            // if debugage then WritelnNumDansRapport('deltaFinale = ',deltaFinale);

            if debugage then
              begin
                WritelnDansRapport('Je vais mettre les valeurs dans la hash pour la position suivante : ');
                WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
                WritelnNumDansRapport('hash = ',gClefHashage);
                WritelnNumDansRapport('deltaFinale = ',deltaFinale);
              end;

            MetValeursDansHashExacte(gClefHashage,profondeurCourante,position,valeurMinPourHash,valeurMaxPourHash,coup,deltaFinale,1,'LigneFinaleToHashTable');
          end;


        suiteLegale := suiteLegale and UpdatePositionEtTrait(position,coup);

        dec(profondeurCourante);
      end;


    for k := prof+1 downto 1 do
      for i := prof+1 downto 1 do
        meilleureSuite[k,i] := meilleureSuite[prof,i];


    gClefHashage := copieDeClefHashage;
    TesterClefHashage(copieDeClefHashage,'LigneFinaleToHashTable');

    if debugage then
      begin
        WritelnDansRapport('Sortie de LigneFinaleToHashTable');
        WritelnDansRapport('####################');
        WritelnDansRapport('');
      end;

end;


function ScoreFinalEstConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;
var result : boolean;
begin
  result := false;
  case genreReflexion of
    ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif :
      begin
        result := (scoreDeNoir = vMinPourNoir) and (scoreDeNoir = vMaxPourNoir);
      end;
    ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant, ReflGagnantExhaustif:
      begin
        if (scoreDeNoir > 0) then result := (vMinPourNoir > 0) else
        if (scoreDeNoir < 0) then result := (vMaxPourNoir < 0) else
        if (scoreDeNoir = 0) then result := (vMinPourNoir = 0) and (vMaxPourNoir = 0);
      end;
  end; {case}
  ScoreFinalEstConfirmeParValeursHashExacte := result;
end;


function ScoreFinalEstFaiblementConfirmeParValeursHashExacte(genreReflexion,scoreDeNoir,vMinPourNoir,vMaxPourNoir : SInt32) : boolean;
var result : boolean;
begin
  result := false;
  case genreReflexion of
    ReflParfait,ReflRetrogradeParfait,ReflParfaitExhaustif :
      begin
        result := (scoreDeNoir >= vMinPourNoir) and (scoreDeNoir <= vMaxPourNoir);
      end;
    ReflGagnant,ReflRetrogradeGagnant,ReflParfaitExhaustPhaseGagnant, ReflGagnantExhaustif:
      begin
        if (scoreDeNoir > 0) then result := (vMinPourNoir > 0) else
        if (scoreDeNoir < 0) then result := (vMaxPourNoir < 0) else
        if (scoreDeNoir = 0) then result := (vMinPourNoir = 0) and (vMaxPourNoir = 0);
      end;
  end; {case}
  ScoreFinalEstFaiblementConfirmeParValeursHashExacte := result;
end;


function TauxDeRemplissageHashExacte(nroTable : SInt32; ecritStatsDetaillees : boolean) : double_t;
var vides,liberees,utilisees,k : SInt32;
    whichTableExacte : HashTableExactePtr;
    whichTableCoupsLegaux : CoupsLegauxHashPtr;
begin
  if (nroTable < 0) or (nroTable > nbMaxTablesHashExactes) then
    begin
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;

  if ((HashTableExacte[nroTable] =  NIL) and (CoupsLegauxHash[nroTable] <> NIL)) or
     ((HashTableExacte[nroTable] <> NIL) and (CoupsLegauxHash[nroTable] =  NIL)) then
    begin
      SysBeep(0);
      WritelnNumDansRapport('ERROR : (HashTableExacte[i] = NIL) XOR (CoupsLegauxHash[i] = NIL) pour i = ',nroTable);
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;

  if (HashTableExacte[nroTable] =  NIL) or (CoupsLegauxHash[nroTable] = NIL) then
    begin
      TauxDeRemplissageHashExacte := -1.0;
      exit(TauxDeRemplissageHashExacte);
    end;

  whichTableExacte := HashTableExacte[nroTable];
  whichTableCoupsLegaux := CoupsLegauxHash[nroTable];

  vides := 0;
  liberees := 0;
  utilisees := 0;
  for k := 0 to 1023 do
    begin
      if GetTraitDansHashExacte(whichTableExacte^[k]) = pionVide
        then
          inc(vides)
        else
          begin
            inc(utilisees);
            if BAND(whichTableExacte^[k].flags,kMaskLiberee) <> 0 then
              inc(liberees);
          end;
    end;

  if ecritStatsDetaillees then
    begin
      WriteDansRapport('HashTableExacte['+NumEnString(nroTable)+']:');
      WriteStringAndReelDansRapport(' remplissage = ', (1.0*utilisees/1024),5);
      WriteStringAndReelDansRapport(' vides = ', (1.0*vides/1024),5);
      WriteStringAndReelDansRapport(' liberees = ', (1.0*liberees/1024),5);
      WritelnDansRapport('');
    end;

  TauxDeRemplissageHashExacte := (1.0*(utilisees-liberees)/1024);

end;


{$IFC USE_DEBUG_STEP_BY_STEP}
procedure AjouterPositionsDevantEtreDebugueesPasAPas(var positionsCherchees : PositionEtTraitSet);
var aPosition : PositionEtTraitRec;
    typeErreur : SInt32;
    s : String255;
begin

  s := 'F5D6C3D3C4F4F6F3E6E7C6G6E8F7G5H6D2C5E3F8D8C8D7B6C7B5B4A3G4H3G3B8A5C2B3D1H4H5G7E2A6A4A2B7F1E1F2B2A1H2B1C1G2H1G1H7H8G8';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);

  s := 'F5D6C3D3C4F4F6F3E6E7C6G6E8F7G5H6D2C5E3F8D8C8D7B6C7B5B4A3G4H3G3B8A5C2B3D1H4H5G7E2A6A4A2B7F1E1F2B2A1H2B1C1G2H1G1H7H8G8A7';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);

  s := 'F5D6C3D3C4F4F6F3E6E7C6G6E8F7G5H6D2C5E3F8D8C8D7B6C7B5B4A3G4H3G3B8A5C2B3D1H4H5G7E2A6A4A2B7F1E1F2B2A1H2B1C1G2H1G1H7H8G8A8';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);


  (*
  s := 'C4E3F6E6F5C5F4G6F7D3G5C3B6D6E7B5A5D7C6C7C8G3D8H6H4G4H3A4A3F8E8B8F3F2E2A6H5A2D2C1D1E1H7G2B4B3';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  *)

  (*
  s := 'F5F6E6F4G5E7F7C5F3G4E3H5D6D3C6D7G6H6H3F8C8D8C7B5C2B6C3E2H4C4F2H2D1B3D2B1E8E1F1B8C1G1B7G3G2';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);

  s := 'F5F6E6F4G5E7F7C5F3G4E3H5D6D3C6D7G6H6H3F8C8D8C7B5C2B6C3E2H4C4F2H2D1B3D2B1E8E1F1B8C1G1B7G3H7';
  aPosition := PositionEtTraitAfterMoveNumberAlpha(s,LENGTH_OF_STRING(s) div 2,typeErreur);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  *)

  {aPosition := MakePositionEtTrait(plat,couleur);}
  {
  dummy := UpdatePositionEtTrait(aPosition,11);
  dummy := UpdatePositionEtTrait(aPosition,73);
  dummy := UpdatePositionEtTrait(aPosition,84);

  dummy := UpdatePositionEtTrait(aPosition,16);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);

  dummy := UpdatePositionEtTrait(aPosition,21);
  AddPositionEtTraitToSet(aPosition,0,positionsCherchees);
  }

  {dummy := UpdatePositionEtTrait(aPosition,12);}
end;


{$ENDC}





procedure VideHashTable(whichHashTable : HashTableHdl);
var t : SInt32;
begin
  if whichHashTable <> NIL then
    for t := 0 to kTailleHashTable do
      begin
        whichHashTable^^[t] := 0;
      end;
end;



procedure AfficheHashTable(minimum,maximum : SInt32);
var t,aux : SInt32;
begin
  for t := minimum to maximum do
    begin
    WriteNumAt('hash[',t,10,11*(t mod 20)+10);
    aux := HashTable^^[t];
    WriteNumAt('] = ',aux,70,11*(t mod 20)+10);
    end;
end;

procedure EcritStatistiquesCollisionsHashTableDansRapport;
var nbCellulesDansHashExactes : SInt32;
begin
  nbCellulesDansHashExactes := nbTablesHashExactes;
  nbCellulesDansHashExactes := nbCellulesDansHashExactes*1024;
  WritelnNumDansRapport('nbTablesHashExactes = ',nbTablesHashExactes);
  WriteNumDansRapport('nbCollisionsHashTableExactes = ',nbCollisionsHashTableExactes);
  WritelnNumDansRapport(' / ',nbCellulesDansHashExactes);
  WriteNumDansRapport('nbNouvellesEntreesHashTableExactes = ',nbNouvellesEntreesHashTableExactes);
  WritelnNumDansRapport(' / ',nbCellulesDansHashExactes);
  WriteNumDansRapport('nbPositionsRetrouveesHashTableExactes = ',nbPositionsRetrouveesHashTableExactes);
  WritelnNumDansRapport(' / ',nbCellulesDansHashExactes);
  WritelnDansRapport('');
end;


END.
