UNIT UnitBitboardMobilite;


INTERFACE







 USES UnitDefCassio;




procedure TestMobiliteBitbooard(var whichPosition : PositionEtTraitRec);                                                                                                            ATTRIBUTE_NAME('TestMobiliteBitbooard')
function CalculeMobiliteBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;                                                                            ATTRIBUTE_NAME('CalculeMobiliteBitboard')
function PositionEtTraitToBitboard(var whichPosition : PositionEtTraitRec) : bitboard;                                                                                              ATTRIBUTE_NAME('PositionEtTraitToBitboard')
function BitboardToDiffPions(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;                                                                                ATTRIBUTE_NAME('BitboardToDiffPions')



function bitboard_mobility_with_zebra_mmx( my_bits_low, my_bits_high, opp_bits_low, opp_bits_high : UInt32) : SInt32;                                                               EXTERNAL_NAME('bitboard_mobility_with_zebra_mmx');


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, MyStrings, UnitStrategie, UnitRapport, UnitPositionEtTrait ;
{$ELSEC}
    ;
    {$I prelink/BitboardMobilite.lk}
{$ENDC}


{END_USE_CLAUSE}












{  $ p r a g m a c  optimization_level 4}



function CalculeMobiliteBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;
var
  coups_legaux_hi      : UInt32;
  coups_legaux_lo      : UInt32;
  opp_inner_bits_hi    : UInt32;
  opp_inner_bits_lo    : UInt32;
  flip_bits_hi         : UInt32;
  flip_bits_lo         : UInt32;
  adjacent_opp_bits_hi : UInt32;
  adjacent_opp_bits_lo : UInt32;
  constante1,constante2,constante3,constante4,constante5 : UInt32;
  result_lo,result_hi  : UInt32;

begin
  constante1 := $7E7E7E7E;

  opp_inner_bits_hi := opp_bits_high and constante1;
  opp_inner_bits_lo := opp_bits_low and constante1;

  flip_bits_hi := (my_bits_high shr 1) and opp_inner_bits_hi;
  flip_bits_lo := (my_bits_low shr 1) and opp_inner_bits_lo;
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 1) and opp_inner_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shr 1) and opp_inner_bits_lo);

  adjacent_opp_bits_hi := opp_inner_bits_hi and (opp_inner_bits_hi shr 1);
  adjacent_opp_bits_lo := opp_inner_bits_lo and (opp_inner_bits_lo shr 1);
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 2) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shr 2) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 2) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shr 2) and adjacent_opp_bits_lo);

  coups_legaux_hi := flip_bits_hi shr 1;
  coups_legaux_lo := flip_bits_lo shr 1;

  flip_bits_hi    := (my_bits_high shl 1);
  flip_bits_lo    := (my_bits_low shl 1);
  coups_legaux_hi := coups_legaux_hi or ((flip_bits_hi + opp_inner_bits_hi) and not(flip_bits_hi));
  coups_legaux_lo := coups_legaux_lo or ((flip_bits_lo + opp_inner_bits_lo) and not(flip_bits_lo));


  flip_bits_hi := (my_bits_high shr 8) and opp_bits_high;
  flip_bits_lo := ((my_bits_low shr 8) or (my_bits_high shl 24)) and opp_bits_low;
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 8) and opp_bits_high);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 8) or (flip_bits_hi shl 24)) and opp_bits_low);

  adjacent_opp_bits_hi := opp_bits_high and (opp_bits_high shr 8);
  adjacent_opp_bits_lo := opp_bits_low and ((opp_bits_low shr 8) or (opp_bits_high shl 24));
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 16) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 16) or (flip_bits_hi shl 16)) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 16) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 16) or (flip_bits_hi shl 16)) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or (flip_bits_hi shr 8);
  coups_legaux_lo := coups_legaux_lo or ((flip_bits_lo shr 8) or (flip_bits_hi shl 24));

  flip_bits_hi := ((my_bits_high shl 8) or (my_bits_low shr 24)) and opp_bits_high;
  flip_bits_lo := (my_bits_low shl 8) and opp_bits_low;
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 8) or (flip_bits_lo shr 24)) and opp_bits_high);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 8) and opp_bits_low);

  adjacent_opp_bits_hi := opp_bits_high and ((opp_bits_high shl 8) or (opp_bits_low shr 24));
  adjacent_opp_bits_lo := opp_bits_low and (opp_bits_low shl 8);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 16) or (flip_bits_lo shr 16)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 16) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 16) or (flip_bits_lo shr 16)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 16) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or ((flip_bits_hi shl 8) or (flip_bits_lo shr 24));
  coups_legaux_lo := coups_legaux_lo or (flip_bits_lo shl 8);

  flip_bits_hi := (my_bits_high shr 7) and opp_inner_bits_hi;
  flip_bits_lo := ((my_bits_low shr 7) or (my_bits_high shl 25)) and opp_inner_bits_lo;
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 7) and opp_inner_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 7) or (flip_bits_hi shl 25)) and opp_inner_bits_lo);

  adjacent_opp_bits_hi := opp_inner_bits_hi and (opp_inner_bits_hi shr 7);
  adjacent_opp_bits_lo := opp_inner_bits_lo and ((opp_inner_bits_lo shr 7) or (opp_inner_bits_hi shl 25));
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 14) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 14) or (flip_bits_hi shl 18)) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 14) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 14) or (flip_bits_hi shl 18)) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or (flip_bits_hi shr 7);
  coups_legaux_lo := coups_legaux_lo or (flip_bits_lo shr 7) or (flip_bits_hi shl 25);

  flip_bits_hi := ((my_bits_high shl 7) or (my_bits_low shr 25)) and opp_inner_bits_hi;
  flip_bits_lo := (my_bits_low shl 7) and opp_inner_bits_lo;
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 7) or (flip_bits_lo shr 25)) and opp_inner_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 7) and opp_inner_bits_lo);

  adjacent_opp_bits_hi := opp_inner_bits_hi and ((opp_inner_bits_hi shl 7) or (opp_inner_bits_lo shr 25));
  adjacent_opp_bits_lo := opp_inner_bits_lo and (opp_inner_bits_lo shl 7);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 14) or (flip_bits_lo shr 18)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 14) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 14) or (flip_bits_lo shr 18)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 14) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or ((flip_bits_hi shl 7) or (flip_bits_lo shr 25));
  coups_legaux_lo := coups_legaux_lo or (flip_bits_lo shl 7);

  flip_bits_hi := (my_bits_high shr 9) and opp_inner_bits_hi;
  flip_bits_lo := ((my_bits_low shr 9) or (my_bits_high shl 23)) and opp_inner_bits_lo;
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 9) and opp_inner_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 9) or (flip_bits_hi shl 23)) and opp_inner_bits_lo);

  adjacent_opp_bits_hi := opp_inner_bits_hi and (opp_inner_bits_hi shr 9);
  adjacent_opp_bits_lo := opp_inner_bits_lo and ((opp_inner_bits_lo shr 9) or (opp_inner_bits_hi shl 23));
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 18) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 18) or (flip_bits_hi shl 14)) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or ((flip_bits_hi shr 18) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or (((flip_bits_lo shr 18) or (flip_bits_hi shl 14)) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or (flip_bits_hi shr 9);
  coups_legaux_lo := coups_legaux_lo or ((flip_bits_lo shr 9) or (flip_bits_hi shl 23));

  flip_bits_hi := ((my_bits_high shl 9) or (my_bits_low shr 23)) and opp_inner_bits_hi;
  flip_bits_lo := (my_bits_low shl 9) and opp_inner_bits_lo;
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 9) or (flip_bits_lo shr 23)) and opp_inner_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 9) and opp_inner_bits_lo);

  adjacent_opp_bits_hi := opp_inner_bits_hi and ((opp_inner_bits_hi shl 9) or (opp_inner_bits_lo shr 23));
  adjacent_opp_bits_lo := opp_inner_bits_lo and (opp_inner_bits_lo shl 9);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 18) or (flip_bits_lo shr 14)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 18) and adjacent_opp_bits_lo);
  flip_bits_hi := flip_bits_hi or (((flip_bits_hi shl 18) or (flip_bits_lo shr 14)) and adjacent_opp_bits_hi);
  flip_bits_lo := flip_bits_lo or ((flip_bits_lo shl 18) and adjacent_opp_bits_lo);

  coups_legaux_hi := coups_legaux_hi or ((flip_bits_hi shl 9) or (flip_bits_lo shr 23));
  coups_legaux_lo := coups_legaux_lo or (flip_bits_lo shl 9);

  coups_legaux_hi := coups_legaux_hi and not(my_bits_high or opp_bits_high);
  coups_legaux_lo := coups_legaux_lo and not(my_bits_low or opp_bits_low);

  (*
  if debugMobilite then
  EcritBitboardDansRapport('coups legaux = ',MakeBitboard(coups_legaux_lo,coups_legaux_hi,0,0));
  *)

  constante2 := $55555555;
  constante3 := $33333333;
  constante4 := $0F0F0F0F;
  constante5 := $000000FF;

  {calcul du nombre de bits a 1 dans coups_legaux_lo et coups_legaux_hi}

  if coups_legaux_lo <> 0 then
    begin
      result_lo := ((coups_legaux_lo shr 1) and constante2) + (coups_legaux_lo and constante2);
      result_lo := ((result_lo shr 2) and constante3)  + (result_lo and constante3);
      result_lo := (result_lo + (result_lo shr 4)) and constante4;
      result_lo := result_lo + (result_lo shr 8);
      result_lo := (result_lo + (result_lo shr 16)) and constante5;


      {Attention ! cette routine ne calcule pas la vraie mobilite :
       ici on on ajoute un pour chaque coin (donc les coins comptent
       pour deux coups. Commenter les lignes suivantes pour avoir la
       vraie mobilite}

      result_lo := result_lo +  (coups_legaux_lo and $00000001);
      result_lo := result_lo + ((coups_legaux_lo shr 7) and $00000001);

	  end
	  else result_lo := 0;

  if (coups_legaux_hi <> 0) then
    begin
      result_hi := ((coups_legaux_hi shr 1) and constante2) + (coups_legaux_hi and constante2);
      result_hi := ((result_hi shr 2) and constante3)  + (result_hi and constante3);
      result_hi := (result_hi + (result_hi shr 4)) and constante4;
      result_hi := result_hi + (result_hi shr 8);
      result_hi := (result_hi + (result_hi shr 16)) and constante5;


      {Attention ! cette routine ne calcule pas la vraie mobilite :
       ici on on ajoute un pour chaque coin (donc les coins comptent
       pour deux coups. Commenter les lignes suivantes pour avoir la
       vraie mobilite}

      result_hi := result_hi + ((coups_legaux_hi shr 31) and $00000001);
      result_hi := result_hi + ((coups_legaux_hi shr 24) and $00000001);

    end
    else result_hi := 0;

	CalculeMobiliteBitboard := result_lo + result_hi;

end;


{  $ p r a g m a c  optimization_level reset}


function PositionEtTraitToBitboard(var whichPosition : PositionEtTraitRec) : bitboard;
var couleur,adversaire : SInt32;
    i,j,square,myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    theBitBoard : bitboard;
begin

  myBitsLow := 0;
	myBitsHigh := 0;
	oppBitsLow := 0;
	oppBitsHigh := 0;

  {transforme un plateauOthello en bitboard}
	with whichPosition do
	  begin
	    if GetTraitOfPosition(whichPosition) = pionVide
	      then couleur := pionNoir
	      else couleur := GetTraitOfPosition(whichPosition);

	    adversaire := -couleur;
			for j := 1 to 4 do
			  for i := 1 to 8 do
			    begin
			      square := j*10 + i;
			      if position[square] = couleur then myBitsLow := BOr(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
			      if position[square] = adversaire then oppBitsLow := BOr(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
			    end;
			for j := 5 to 8 do
			  for i := 1 to 8 do
			    begin
			      square := j*10 + i;
			      if position[square] = couleur then myBitsHigh := BOr(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
			      if position[square] = adversaire then oppBitsHigh := BOr(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
			    end;
	 end;

	with theBitBoard do
	  begin
	    g_my_bits_low := myBitsLow;
	    g_my_bits_high := myBitsHigh;
	    g_opp_bits_low := oppBitsLow;
	    g_opp_bits_high := oppBitsHigh;
	  end;

	PositionEtTraitToBitboard := theBitboard;
end;


procedure TestMobiliteBitbooard(var whichPosition : PositionEtTraitRec);
var couleur,adversaire : SInt32;
    i,j,square,myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    theBitBoard : bitboard;
    n,compteur,tick : SInt32;
    iterations : SInt32;
begin


  if GetTraitOfPosition(whichPosition) <> pionVide then
    begin

		  {transforme un plateauOthello en bitboard}
			myBitsLow := 0;
			myBitsHigh := 0;
			oppBitsLow := 0;
			oppBitsHigh := 0;

			with whichPosition do
			  begin
			    if GetTraitOfPosition(whichPosition) = pionVide
			      then couleur := pionNoir
			      else couleur := GetTraitOfPosition(whichPosition);

			    adversaire := -couleur;
					for j := 1 to 4 do
					  for i := 1 to 8 do
					    begin
					      square := j*10 + i;
					      if position[square] = couleur then myBitsLow := BOr(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
					      if position[square] = adversaire then oppBitsLow := BOr(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
					    end;
					for j := 5 to 8 do
					  for i := 1 to 8 do
					    begin
					      square := j*10 + i;
					      if position[square] = couleur then myBitsHigh := BOr(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
					      if position[square] = adversaire then oppBitsHigh := BOr(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
					    end;
			 end;

			with theBitBoard do
			  begin
			    g_my_bits_low := myBitsLow;
			    g_my_bits_high := myBitsHigh;
			    g_opp_bits_low := oppBitsLow;
			    g_opp_bits_high := oppBitsHigh;
			  end;



			WritelnStringDansRapport('entrŽe dans TestMobiliteBitbooard');

			iterations := 10000000;

			tick := TickCount;
			for compteur := 1 to iterations do
			  n := CalculeMobiliteBitboard(myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh);
			tick := TickCount - tick;


			WritelnNumDansRapport('   ==> mobilite bitboard = ',n);
			WritelnNumDansRapport('             temps = ',tick);




			tick := TickCount;
			for compteur := 1 to iterations do
			  n := CalculeMobilitePlatSeulement(whichPosition.position,GetTraitOfPosition(whichPosition));
			tick := TickCount - tick;


			WritelnNumDansRapport('   ==> mobilite normale = ',n);
			WritelnNumDansRapport('             temps = ',tick);




			tick := TickCount;
			for compteur := 1 to iterations do
			  n := bitboard_mobility_with_zebra_mmx(myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh);
			tick := TickCount - tick;


			WritelnNumDansRapport('   ==> mobilite mmx = ',n);
			WritelnNumDansRapport('             temps = ',tick);



	  end;

end;


function BitboardToDiffPions(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32) : SInt32;
var count_my_discs_lo : UInt32;
    count_my_discs_hi : UInt32;
    count_opp_discs_lo : UInt32;
    count_opp_discs_hi : UInt32;
    constante2 : UInt32;
    constante3 : UInt32;
    constante4 : UInt32;
    constante5 : UInt32;
begin

  constante2 := $55555555;
  constante3 := $33333333;
  constante4 := $0F0F0F0F;
  constante5 := $000000FF;

  count_my_discs_lo := ((my_bits_low shr 1) and constante2) + (my_bits_low and constante2);
  count_my_discs_lo := ((count_my_discs_lo shr 2) and constante3)  + (count_my_discs_lo and constante3);
  count_my_discs_lo := (count_my_discs_lo + (count_my_discs_lo shr 4)) and constante4;
  count_my_discs_lo := count_my_discs_lo + (count_my_discs_lo shr 8);
  count_my_discs_lo := (count_my_discs_lo + (count_my_discs_lo shr 16)) and constante5;

  count_my_discs_hi := ((my_bits_high shr 1) and constante2) + (my_bits_high and constante2);
  count_my_discs_hi := ((count_my_discs_hi shr 2) and constante3)  + (count_my_discs_hi and constante3);
  count_my_discs_hi := (count_my_discs_hi + (count_my_discs_hi shr 4)) and constante4;
  count_my_discs_hi := count_my_discs_hi + (count_my_discs_hi shr 8);
  count_my_discs_hi := (count_my_discs_hi + (count_my_discs_hi shr 16)) and constante5;

  count_opp_discs_lo := ((opp_bits_low shr 1) and constante2) + (opp_bits_low and constante2);
  count_opp_discs_lo := ((count_opp_discs_lo shr 2) and constante3)  + (count_opp_discs_lo and constante3);
  count_opp_discs_lo := (count_opp_discs_lo + (count_opp_discs_lo shr 4)) and constante4;
  count_opp_discs_lo := count_opp_discs_lo + (count_opp_discs_lo shr 8);
  count_opp_discs_lo := (count_opp_discs_lo + (count_opp_discs_lo shr 16)) and constante5;

  count_opp_discs_hi := ((opp_bits_high shr 1) and constante2) + (opp_bits_high and constante2);
  count_opp_discs_hi := ((count_opp_discs_hi shr 2) and constante3)  + (count_opp_discs_hi and constante3);
  count_opp_discs_hi := (count_opp_discs_hi + (count_opp_discs_hi shr 4)) and constante4;
  count_opp_discs_hi := count_opp_discs_hi + (count_opp_discs_hi shr 8);
  count_opp_discs_hi := (count_opp_discs_hi + (count_opp_discs_hi shr 16)) and constante5;

	BitboardToDiffPions := (count_my_discs_lo + count_my_discs_hi) - (count_opp_discs_lo + count_opp_discs_hi);
end;



END.
