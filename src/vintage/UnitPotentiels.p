UNIT UnitPotentiels;



INTERFACE







 USES UnitDefCassio;





procedure InitUnitPotentiels;
procedure SetPotentielsOptimums(position : PositionEtTraitRec);
procedure AffichePotentiels;

procedure UpdatePotentiels(whichPlat : plateauOthello; whichColor : SInt16);

function VincenzPenseQueCEstUnTresMauvaisCoup(whichSquare : SInt16; whichPos : PositionEtTraitRec) : boolean;
function EffectueMoveEtCalculePotentielVincenz(var whichPos : PositionEtTraitRec; whichSquare,degreMinimisation : SInt16) : double_t;

{simulation du program Perl "Vincenz" de Jakub Tesinsky}
function ChoixDeVincenz(positionEtTrait : PositionEtTraitRec; degreMinimisation : SInt16; doitChercherDefense : boolean) : VincenzMoveRec;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitStrategie, UnitNormalisation, UnitRapport, UnitScannerUtils, MyMathUtils, UnitPositionEtTrait, UnitEvaluation
    , UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/Potentiels.lk}
{$ENDC}


{END_USE_CLAUSE}










var nbUpdatesPotentiels : SInt32;


procedure InitUnitPotentiels;
var square,minimisation : SInt32;
begin
  for minimisation := 0 to nbDegresMinimisation do
    for square := 0 to 99 do
      begin
        potentiels[minimisation,square] := 0.0;
        hits[minimisation,square] := 0;
      end;
  nbUpdatesPotentiels := 0;
end;

(*  bons potentiels !!
potentiels pour le degre de minimisation : 1.0000
13.2  -6.12  0.55  -0.50  -0.50  0.55  -6.12  13.2      936  8094  4078  5654  5654  4078  8094  936
-6.12  -10.8  -1.10  0.32  0.32  -1.10  -10.8  -6.12      8094  16318  7068  5229  5229  7068  16318  8094
0.55  -1.10  1.54  2.15  2.15  1.54  -1.10  0.55      4078  7068  2360  1788  1788  2360  7068  4078
-0.50  0.32  2.15  0.00  0.00  2.15  0.32  -0.50      5654  5229  1788  0  0  1788  5229  5654
-0.50  0.32  2.15  0.00  0.00  2.15  0.32  -0.50      5654  5229  1788  0  0  1788  5229  5654
0.55  -1.10  1.54  2.15  2.15  1.54  -1.10  0.55      4078  7068  2360  1788  1788  2360  7068  4078
-6.12  -10.8  -1.10  0.32  0.32  -1.10  -10.8  -6.12      8094  16318  7068  5229  5229  7068  16318  8094
13.2  -6.12  0.55  -0.50  -0.50  0.55  -6.12  13.2      936  8094  4078  5654  5654  4078  8094  936
*)


procedure SetPotentielsOptimums(position : PositionEtTraitRec);
const bonus = 4.0;
begin
  potentiels[1,11] := 13.2; potentiels[1,12] := -2.64; potentiels[1,13] := 0.55; potentiels[1,14] := -0.50; potentiels[1,15] := -0.50; potentiels[1,16] := 0.55; potentiels[1,17] := -2.64; potentiels[1,18] := 13.2;
  potentiels[1,21] := -2.64; potentiels[1,22] := -10.8; potentiels[1,23] := -1.10; potentiels[1,24] := 0.56; potentiels[1,25] := 0.56; potentiels[1,26] := -1.10; potentiels[1,27] := -10.8; potentiels[1,28] := -2.64;
  potentiels[1,31] := 0.55; potentiels[1,32] := -1.10; potentiels[1,33] := 1.54; potentiels[1,34] := 2.15; potentiels[1,35] := 2.15; potentiels[1,36] := 1.54; potentiels[1,37] := -1.10; potentiels[1,38] := 0.55;
  potentiels[1,41] := -0.50; potentiels[1,42] := 0.56; potentiels[1,43] := 2.15; potentiels[1,44] := 2.15; potentiels[1,45] := 2.15; potentiels[1,46] := 2.15; potentiels[1,47] := 0.56; potentiels[1,48] := -0.50;
  potentiels[1,51] := -0.50; potentiels[1,52] := 0.56; potentiels[1,53] := 2.15; potentiels[1,54] := 2.15; potentiels[1,55] := 2.15; potentiels[1,56] := 2.15; potentiels[1,57] := 0.56; potentiels[1,58] := -0.50;
  potentiels[1,61] := 0.55; potentiels[1,62] := -1.10; potentiels[1,63] := 1.54; potentiels[1,64] := 2.15; potentiels[1,65] := 2.15; potentiels[1,66] := 1.54; potentiels[1,67] := -1.10; potentiels[1,68] := 0.55;
  potentiels[1,71] := -2.64; potentiels[1,72] := -10.8; potentiels[1,73] := -1.10; potentiels[1,74] := 0.56; potentiels[1,75] := 0.56; potentiels[1,76] := -1.10; potentiels[1,77] := -10.8; potentiels[1,78] := -2.64;
  potentiels[1,81] := 13.2; potentiels[1,82] := -2.64; potentiels[1,83] := 0.55; potentiels[1,84] := -0.50; potentiels[1,85] := -0.50; potentiels[1,86] := 0.55; potentiels[1,87] := -2.64; potentiels[1,88] := 13.2;

  if (position.position[11] <> pionVide) then
    begin
      potentiels[1,12] := potentiels[1,12]+bonus;
      potentiels[1,21] := potentiels[1,21]+bonus;
      potentiels[1,22] := potentiels[1,22]+bonus;
    end;
  if (position.position[18] <> pionVide) then
    begin
      potentiels[1,17] := potentiels[1,12]+bonus;
      potentiels[1,28] := potentiels[1,21]+bonus;
      potentiels[1,27] := potentiels[1,22]+bonus;
    end;
  if (position.position[81] <> pionVide) then
    begin
      potentiels[1,71] := potentiels[1,12]+bonus;
      potentiels[1,82] := potentiels[1,21]+bonus;
      potentiels[1,72] := potentiels[1,22]+bonus;
    end;
  if (position.position[88] <> pionVide) then
    begin
      potentiels[1,78] := potentiels[1,12]+bonus;
      potentiels[1,87] := potentiels[1,21]+bonus;
      potentiels[1,77] := potentiels[1,22]+bonus;
    end;

end;





procedure AffichePotentiels;
var i,j,square,minimisation : SInt32;
    rapportLog : boolean;
begin

  rapportLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(true);

  for minimisation := 0 to nbDegresMinimisation do
    begin
      WritelnDansRapport('');
      WritelnStringAndReelDansRapport('potentiels pour le degre de minimisation : ',minimisation,5);
	    for i := 1 to 8 do
	      begin
	        for j := 1 to 8 do
			      begin
			        square := i*10+j;
			        WriteReelDansRapport(potentiels[minimisation,square],3);
			        WriteDansRapport('  ');
			      end;
			    WriteDansRapport('    ');

			    for j := 1 to 8 do
			      begin
			        square := i*10+j;
			        WriteNumDansRapport('',hits[minimisation,square]);
			        WriteDansRapport('  ');
			      end;
			    WritelnDansRapport('');
			 end;
   end;

   SetEcritToutDansRapportLog(rapportLog);
end;




procedure UpdatePotentiels(whichPlat : plateauOthello; whichColor : SInt16);
var nbPionsRetournes,nbHits,nbVides : SInt32;
    t,whichSquare,minimisation : SInt32;
    whichPos,posAux : PositionEtTraitRec;
    evalPos,evalOfSquare,coeffMinimisation : double_t;
    deltaPotentiel,oldPotentiel : double_t;
    debug,rapportLog : boolean;


    procedure UdpatePotentielsCetteCase(whichSquare : SInt16);
    begin
      nbHits      := hits[      minimisation, whichSquare];
      oldPotentiel := potentiels[minimisation, whichSquare];
      potentiels[minimisation, whichSquare] := (oldPotentiel*nbHits+deltaPotentiel)/(nbHits+1);
      hits[      minimisation, whichSquare] := nbHits+1;
    end;

begin

  SetEcritToutDansRapportLog(true);
  {WritelnPositionEtTraitDansRapport(whichPlat,whichColor);}

  if DoitPasserPlatSeulement(whichColor,whichPlat) then
    begin
      SysBeep(0);
      exit(UpdatePotentiels);
    end;

  whichPos := MakePositionEtTrait(whichPlat,whichColor);

  inc(nbUpdatesPotentiels);
  debug := (nbUpdatesPotentiels < 1000) & false;
  rapportLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(true);

  if debug then
    begin
      WritelnDansRapport('');
      WritelnNumDansRapport('nbUpdatesPotentiels = ',nbUpdatesPotentiels);
      WritelnDansRapport('whichPos = ');
      WritelnPositionEtTraitDansRapport(whichPos.position,GetTraitOfPosition(whichPos));
    end;

  nbVides := NbCasesVidesDansPosition(whichPos.position);

  if (nbVides <= 1) | (nbVides >= 57) | (GetTraitOfPosition(whichPos) = pionVide)
    then exit(UpdatePotentiels);

  if debug then WritelnNumDansRapport('nbVides = ',nbVides);

  evalPos := 0.01*EvaluationHorsContexte(whichPos);

  for t := 1 to 64 do
    begin
      posAux := whichPos;
      whichSquare := othellier[t];
      nbPionsRetournes := RetournePionsPositionEtTrait(posAux,whichSquare);
      if (nbPionsRetournes > 0) &
         (whichSquare >= 11) &
         (whichSquare <= 88) &
         (estUneCaseC[whichSquare] | not(VincenzPenseQueCEstUnTresMauvaisCoup(whichSquare,whichPos))) then
        begin

          if (GetTraitOfPosition(posAux) <> pionVide) &
             (GetTraitOfPosition(whichPos) = -GetTraitOfPosition(posAux)) then
	          begin


	            if debug then
	              begin
	                WritelnDansRapport('');
	                WriteStringDansRapport('whichSquare = '+CoupEnString(whichSquare,true));
	                WritelnNumDansRapport('  nbPionsRetournes = ',nbPionsRetournes);
	                WritelnDansRapport('posAux = ');
                  WritelnPositionEtTraitDansRapport(posAux.position,GetTraitOfPosition(posAux));
	              end;


	            evalOfSquare := -0.01*EvaluationHorsContexte(posAux);

	            if estUneCaseC[whichSquare] then evalOfSquare := evalOfSquare+1.0;

	            if debug then
	              WritelnStringAndReelDansRapport('eval of square '+CoupEnString(whichSquare,true)+' = ',evalOfSquare,5);


	            for minimisation := 0 to nbDegresMinimisation do
						    begin


						      if nbVides > 15
						        then coeffMinimisation := minimisation
						        else coeffMinimisation := -minimisation;
						      if (nbVides > 15) & (NbPionsDefinitifsSurLesBords(whichColor,whichPlat) > 0) then
						        coeffMinimisation := 0.5*minimisation;

						      if debug then
						        WriteStringAndReelDansRapport('coeffMinimisation = ',coeffMinimisation,3);

						      deltaPotentiel := (evalOfSquare{-evalPos})+coeffMinimisation*nbPionsRetournes;

						      if debug then
						        WriteStringAndReelDansRapport('  deltaPotentiel '+CoupEnString(whichSquare,true)+' = ',deltaPotentiel,5);

						      UdpatePotentielsCetteCase(whichSquare);
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,central));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,axeSE_NW));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,axeSW_NE));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,axeVertical));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,axeHorizontal));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,quartDeTourTrigo));
						      UdpatePotentielsCetteCase(CaseSymetrique(whichSquare,quartDeTourAntiTrigo));

						      if debug then
				            WritelnNumDansRapport('  nbHits = ',nbHits);

						    end;
		        end;
        end;
    end;


    SetEcritToutDansRapportLog(rapportLog);
end;




function VincenzPenseQueCEstUnTresMauvaisCoup(whichSquare : SInt16; whichPos : PositionEtTraitRec) : boolean;
var newPos : PositionEtTraitRec;
    coin : SInt16;
begin
  {si c'est un coin => bon coup}
  if estUnCoin[whichSquare] then
    begin
      VincenzPenseQueCEstUnTresMauvaisCoup := false;
      exit(VincenzPenseQueCEstUnTresMauvaisCoup);
    end;

  newPos := whichPos;
  if UpdatePositionEtTrait(newPos,whichSquare) then
    begin

      {si on a retournŽ une case X => mauvais coup}
		  if ((whichPos.position[22] <> pionVide) & (newPos.position[22] = -whichPos.position[22])) |
		     ((whichPos.position[27] <> pionVide) & (newPos.position[27] = -whichPos.position[27])) |
		     ((whichPos.position[72] <> pionVide) & (newPos.position[72] = -whichPos.position[72])) |
		     ((whichPos.position[77] <> pionVide) & (newPos.position[77] = -whichPos.position[77])) then
		    begin
		      VincenzPenseQueCEstUnTresMauvaisCoup := true;
		      exit(VincenzPenseQueCEstUnTresMauvaisCoup);
		    end;

		  {si c'est une case C et que l'adversaire peut jouer le coin => mauvais coup }
		  if estUneCaseC[whichSquare] then
		    begin
		      coin := CoinPlusProche(whichSquare);
		      if (newPos.position[coin] = pionVide) & PeutJouerIci(-GetTraitOfPosition(whichPos),coin,newPos.position) then
		        begin
		          VincenzPenseQueCEstUnTresMauvaisCoup := true;
		          exit(VincenzPenseQueCEstUnTresMauvaisCoup);
		        end;
		    end;
    end;


  VincenzPenseQueCEstUnTresMauvaisCoup := false;

end;



function EffectueMoveEtCalculePotentielVincenz(var whichPos : PositionEtTraitRec; whichSquare,degreMinimisation : SInt16) : double_t;
var nbPionsRetournes,nbVides : SInt16;
    value,coeffMinimisation : double_t;
    mauvaisCoup : boolean;
begin

  nbVides := NbCasesVidesDansPosition(whichPos.position);

  if nbVides > 15
    then coeffMinimisation := degreMinimisation
    else coeffMinimisation := -degreMinimisation;
  if (nbVides > 15) & (NbPionsDefinitifsSurLesBords(GetTraitOfPosition(whichPos),whichPos.position) > 0) then
    coeffMinimisation := 0.5*degreMinimisation;


  mauvaisCoup := VincenzPenseQueCEstUnTresMauvaisCoup(whichSquare,whichPos);
  nbPionsRetournes := RetournePionsPositionEtTrait(whichPos,whichSquare);

  if nbPionsRetournes > 0
    then
	    begin
	      value := potentiels[degreMinimisation,whichSquare]-coeffMinimisation*nbPionsRetournes;
	      if mauvaisCoup then value := value-100.0;
	    end
	  else
	    value := -6400.0;

	EffectueMoveEtCalculePotentielVincenz := value;

end;


function ChoixDeVincenz(positionEtTrait : PositionEtTraitRec; degreMinimisation : SInt16; doitChercherDefense : boolean) : VincenzMoveRec;
var square,t,nbCoupsMemeNote : SInt16;
    maxval,value : double_t;
    newPos : PositionEtTraitRec;
    result : VincenzMoveRec;
begin
  if degreMinimisation < 0 then degreMinimisation := 0;
  if degreMinimisation > nbDegresMinimisation then degreMinimisation := nbDegresMinimisation;

  maxval := -6400.0;
  nbCoupsMemeNote := 1;

  with result do
    begin
      bestMove := 0;
      bestDefense := 0;
      sommePotentiels := 0.0;
    end;

  for t := 1 to 64 do
    begin
      square := othellier[t];
      if (positionEtTrait.position[square] = pionVide) &
          PeutJouerIci(GetTraitOfPosition(positionEtTrait),square,positionEtTrait.position) then
         begin
           newPos := positionEtTrait;

           value := EffectueMoveEtCalculePotentielVincenz(newPos,square,degreMinimisation);

           if (value > -5.0) then result.sommePotentiels := result.sommePotentiels+(value+5.0);

           if value > maxval
             then
               begin
                 maxval := value;
                 result.bestMove := square;
                 result.potentielBestMove := value;
                 nbCoupsMemeNote := 1;

                 if doitChercherDefense then
                   result.bestDefense := ChoixDeVincenz(newPos,degreMinimisation,false).bestMove;

               end
             else
               if value = maxval then
                 begin
                   nbCoupsMemeNote := nbCoupsMemeNote+1;
                   if UneChanceSur(nbCoupsMemeNote) then
                     begin
                       result.bestMove := square;
                       result.potentielBestMove := value;

                       if doitChercherDefense then
                         result.bestDefense := ChoixDeVincenz(newPos,degreMinimisation,false).bestMove;

                     end;
                 end;
         end;
    end;

  {
  WritelnDansRapport('');
  WritelnPositionEtTraitDansRapport(positionEtTrait.position,GetTraitOfPosition(positionEtTrait));
  WritelnStringDansRapport('result.bestMove = '+CoupEnString(result.bestMove,true));
  WritelnStringAndReelDansRapport('result.potentielBestMove = ',result.potentielBestMove,6);
  WritelnStringDansRapport('result.bestDefense = '+CoupEnString(result.bestDefense,true));
  WritelnStringAndReelDansRapport('result.sommePotentiels = ',result.sommePotentiels,6);
  }

  ChoixDeVincenz := result;

end;

END.
