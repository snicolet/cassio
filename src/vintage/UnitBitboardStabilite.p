UNIT UnitBitboardStabilite;



INTERFACE







 USES UnitDefCassio;



procedure TestStabiliteBitboard;
function CalculePionsStablesBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32; nbPionsStablesSuffisant : SInt32) : SInt32;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Timer
{$IFC NOT(USE_PRELINK)}
    , UnitUtilitaires, MyStrings, UnitRapport, UnitBitboardUtils ;
{$ELSEC}
    ;
    {$I prelink/BitboardStabilite.lk}
{$ENDC}


{END_USE_CLAUSE}











function CalculePionsStablesBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32; nbPionsStablesSuffisant : SInt32) : SInt32;
var remplies_hi,remplies_lo : UInt32;
    vides_hi,vides_lo : UInt32;
    left_right_hi,left_right_lo : UInt32;
    up_down_hi,up_down_lo : UInt32;
    diag_hi,diag_lo : UInt32;
    anti_hi,anti_lo : UInt32;
    stables_lo,stables_hi : UInt32;
    old_stables_lo,old_stables_hi : UInt32;
    dir1_lo,dir1_hi : UInt32;
    dir2_lo,dir2_hi : UInt32;
    dir3_lo,dir3_hi : UInt32;
    dir4_lo,dir4_hi : UInt32;
    n1,n2 : UInt32;
    constante1,constante2,constante3,constante4(*,constante5*) : UInt32;
begin

  remplies_hi := my_bits_high or opp_bits_high;
  remplies_lo := my_bits_low or opp_bits_low;

  constante1 := $01010101;
  constante2 := $81818181;

  left_right_hi := remplies_hi;
  left_right_hi := left_right_hi and (left_right_hi shr 4);
  left_right_hi := left_right_hi and (left_right_hi shr 2);
  left_right_hi := left_right_hi and (left_right_hi shr 1);
  left_right_hi := left_right_hi and constante1;
  left_right_hi := BSL(left_right_hi,8) - left_right_hi ; {left_right_hi := left_right_hi * 255;}

  left_right_lo := remplies_lo;
  left_right_lo := left_right_lo and (left_right_lo shr 4);
  left_right_lo := left_right_lo and (left_right_lo shr 2);
  left_right_lo := left_right_lo and (left_right_lo shr 1);
  left_right_lo := left_right_lo and constante1;
  left_right_lo := BSL(left_right_lo,8) - left_right_lo ; {left_right_lo := left_right_lo * 255;}

  left_right_hi := left_right_hi or constante2;
  left_right_lo := left_right_lo or constante2;


  up_down_hi := (remplies_hi and (remplies_hi shr 8) and (remplies_hi shr 16) and (remplies_hi shr 24)) and $FF;
  up_down_lo := (remplies_lo and (remplies_lo shr 8) and (remplies_lo shr 16) and (remplies_lo shr 24)) and $FF;
  up_down_lo := (up_down_lo and up_down_hi) * constante1;

  up_down_hi := up_down_lo or $FF000000;
  up_down_lo := up_down_lo or $000000FF;

  {
  diag_lo := remplies_lo;
  diag_lo := diag_lo     and ((diag_lo or $01010101) shl 7);
  diag_lo := diag_lo     and ((diag_lo or $01010101) shl 7);
  diag_lo := diag_lo     and ((diag_lo or $01010101) shl 7);
  diag_hi := remplies_hi and ((diag_lo or $01010101) shl 7);
  diag_hi := diag_hi     and ((diag_hi or $01010101) shl 7);
  diag_hi := diag_hi     and ((diag_hi or $01010101) shl 7);
  diag_hi := diag_hi     and ((diag_hi or $01010101) shl 7);

  diag_lo := diag_lo or $818181FF;
  diag_hi := diag_hi or $FF818181;

  anti_hi := remplies_hi;
  anti_hi := anti_hi     and ((anti_hi or $80808080) shr 7);
  anti_hi := anti_hi     and ((anti_hi or $80808080) shr 7);
  anti_hi := anti_hi     and ((anti_hi or $80808080) shr 7);
  anti_lo := remplies_lo and ((anti_hi or $80808080) shr 7);
  anti_lo := anti_lo     and ((anti_lo or $80808080) shr 7);
  anti_lo := anti_lo     and ((anti_lo or $80808080) shr 7);
  anti_lo := anti_lo     and ((anti_lo or $80808080) shr 7);

  anti_lo := anti_lo or $818181FF;
  anti_hi := anti_hi or $FF818181;
  }

  diag_lo := $818181FF;
  diag_hi := $FF818181;

  vides_hi := not(remplies_hi);
  vides_lo := not(remplies_lo);


  constante1 := $00010204;
  if BAND(vides_lo,constante1) = 0 then
    begin
      diag_lo := diag_lo or constante1;
    end;

  constante2 := $01020408;
  if BAND(vides_lo,constante2) = 0 then
    begin
      diag_lo := diag_lo or constante2;
    end;

  constante3 := $02040810;
  constante4 := $00000001;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      diag_lo := diag_lo or constante3;
      diag_hi := diag_hi or constante4;
    end;

  constante1 := $04081020;
  constante2 := $00000102;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      diag_lo := diag_lo or constante1;
      diag_hi := diag_hi or constante2;
    end;

  constante3 := $08102040;
  constante4 := $00010204;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      diag_lo := diag_lo or constante3;
      diag_hi := diag_hi or constante4;
    end;

  constante1 := $10204080;
  constante2 := $01020408;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      diag_lo := diag_lo or constante1;
      diag_hi := diag_hi or constante2;
    end;

  constante3 := $20408000;
  constante4 := $02040810;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      diag_lo := diag_lo or constante3;
      diag_hi := diag_hi or constante4;
    end;

  constante1 := $40800000;
  constante2 := $04081020;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      diag_lo := diag_lo or constante1;
      diag_hi := diag_hi or constante2;
    end;

  constante3 := $80000000;
  constante4 := $08102040;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      diag_lo := diag_lo or constante3;
      diag_hi := diag_hi or constante4;
    end;

  constante1 := $10204080;
  if (BAND(vides_hi,constante1) = 0) then
    begin
      diag_hi := diag_hi or constante1;
    end;

  constante2 := $20408000;
  if (BAND(vides_hi,constante2) = 0) then
    begin
      diag_hi := diag_hi or constante2;
    end;



  anti_lo := $818181FF;
  anti_hi := $FF818181;

  constante3 := $00804020;
  if (BAND(vides_lo,constante3) = 0) then
    begin
      anti_lo := anti_lo or constante3;
    end;

  constante4 := $80402010;
  if (BAND(vides_lo,constante4) = 0) then
    begin
      anti_lo := anti_lo or constante4;
    end;

  constante1 := $40201008;
  constante2 := $00000080;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      anti_lo := anti_lo or constante1;
      anti_hi := anti_hi or constante2;
    end;

  constante3 := $20100804;
  constante4 := $00008040;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      anti_lo := anti_lo or constante3;
      anti_hi := anti_hi or constante4;
    end;

  constante1 := $10080402;
  constante2 := $00804020;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      anti_lo := anti_lo or constante1;
      anti_hi := anti_hi or constante2;
    end;

  constante3 := $08040201;
  constante4 := $80402010;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      anti_lo := anti_lo or constante3;
      anti_hi := anti_hi or constante4;
    end;

  constante1 := $04020100;
  constante2 := $40201008;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      anti_lo := anti_lo or constante1;
      anti_hi := anti_hi or constante2;
    end;

  constante3 := $02010000;
  constante4 := $20100804;
  if (BAND(vides_lo,constante3) = 0) and
     (BAND(vides_hi,constante4) = 0) then
    begin
      anti_lo := anti_lo or constante3;
      anti_hi := anti_hi or constante4;
    end;

  constante1 := $01000000;
  constante2 := $10080402;
  if (BAND(vides_lo,constante1) = 0) and
     (BAND(vides_hi,constante2) = 0) then
    begin
      anti_lo := anti_lo or constante1;
      anti_hi := anti_hi or constante2;
    end;

  constante3 := $08040201;
  if (BAND(vides_hi,constante3) = 0) then
    begin
      anti_hi := anti_hi or constante3;
    end;

  constante4 := $04020100;
  if (BAND(vides_hi,constante4) = 0) then
    begin
      anti_hi := anti_hi or constante4;
    end;


  stables_lo := (left_right_lo and up_down_lo) and (diag_lo and anti_lo) and my_bits_low;
  stables_hi := (left_right_hi and up_down_hi) and (diag_hi and anti_hi) and my_bits_high;





  (*
  EcritBitboardDansRapport('position = ',MakeBitboard(my_bits_low,my_bits_high,opp_bits_low,opp_bits_high));
  EcritBitboardDansRapport('left_right et up_down = ',MakeBitboard(left_right_lo,left_right_hi,up_down_lo,up_down_hi));
  EcritBitboardDansRapport('diag et anti = ',MakeBitboard(diag_lo,diag_hi,anti_lo,anti_hi));
  EcritBitboardDansRapport('remplies et stables =  ',MakeBitboard(remplies_lo,remplies_hi,stables_lo,stables_hi));
  WritelnDansRapport('');
  AttendFrappeClavier;
  *)


  CalculePionsStablesBitboard := 0;

  if (stables_lo <> 0) or (stables_hi <> 0) then
    begin
      {calcul du nombre de bits ˆ 1 dans stables_lo et dans stables_hi}
      if nbPionsStablesSuffisant <= 1 then
        begin
          CalculePionsStablesBitboard := 1;
          exit;
        end;

      constante1 := $55555555;
      constante2 := $33333333;
      constante3 := $0F0F0F0F;
      constante4 := $000000FF;
      (*
      constante1 := $55555555;
      constante2 := $33333333;
      constante3 := $0F0F0F0F;
      constante4 := $00FF00FF;
      constante5 := $0000FFFF;
      *)

      if (stables_lo <> 0)
        then
	        begin
	          n1 := ((stables_lo shr 1) and constante1) + (stables_lo and constante1);
			      n1 := ((n1 shr 2) and constante2)  + (n1 and constante2);
			      n1 := (n1 + (n1 shr 4)) and constante3;
			      n1 := (n1 + (n1 shr 8));
			      n1 := (n1 + (n1 shr 16)) and constante4;

			      (*
	          n1 := ((stables_lo shr 1) and constante1) + (stables_lo and constante1);
			      n1 := ((n1 shr 2) and constante2)  + (n1 and constante2);
			      n1 := ((n1 shr 4) and constante3)  + (n1 and constante3);
			      n1 := ((n1 shr 8) and constante4)  + (n1 and constante4);
			      n1 := ((n1 shr 16) and constante5) + (n1 and constante5);
			      *)

			      if n1 >= nbPionsStablesSuffisant then
			        begin
			          CalculePionsStablesBitboard := n1;
                exit;
			        end;

			      if (stables_hi <> 0) then
			        begin
			          n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
					      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
					      n2 := (n2 + (n2 shr 4)) and constante3;
			          n2 := (n2 + (n2 shr 8));
			          n2 := (n2 + (n2 shr 16)) and constante4;

			          (*
					      n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
					      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
					      n2 := ((n2 shr 4) and constante3)  + (n2 and constante3);
					      n2 := ((n2 shr 8) and constante4)  + (n2 and constante4);
					      n2 := ((n2 shr 16) and constante5) + (n2 and constante5);
					      *)

					      if (n1+n2) >= nbPionsStablesSuffisant then
					        begin
					          CalculePionsStablesBitboard := n1 + n2;
		                exit;
					        end;
					    end;

			    end
			  else
			    begin
			      n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
			      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
			      n2 := (n2 + (n2 shr 4)) and constante3;
			      n2 := (n2 + (n2 shr 8));
			      n2 := (n2 + (n2 shr 16)) and constante4;

			      (*
			      n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
			      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
			      n2 := ((n2 shr 4) and constante3)  + (n2 and constante3);
			      n2 := ((n2 shr 8) and constante4)  + (n2 and constante4);
			      n2 := ((n2 shr 16) and constante5) + (n2 and constante5);
			      *)

			      if n2 >= nbPionsStablesSuffisant then
			        begin
			          CalculePionsStablesBitboard := n2;
                exit;
			        end;
			    end;


	    repeat
		    old_stables_lo := stables_lo;
		    old_stables_hi := stables_hi;


		    dir1_lo := (stables_lo shl 1) or (stables_lo shr 1) or (stables_hi shl 31) or left_right_lo;
		    dir1_hi := (stables_hi shl 1) or (stables_hi shr 1) or (stables_lo shr 31) or left_right_hi;

		    dir2_lo := (stables_lo shl 8) or (stables_lo shr 8) or (stables_hi shl 24) or up_down_lo;
		    dir2_hi := (stables_hi shl 8) or (stables_hi shr 8) or (stables_lo shr 24) or up_down_hi;

		    dir3_lo := (stables_lo shl 7) or (stables_lo shr 7) or (stables_hi shl 25) or diag_lo;
		    dir3_hi := (stables_hi shl 7) or (stables_hi shr 7) or (stables_lo shr 25) or diag_hi;

		    dir4_lo := (stables_lo shl 9) or (stables_lo shr 9) or (stables_hi shl 23) or anti_lo;
		    dir4_hi := (stables_hi shl 9) or (stables_hi shr 9) or (stables_lo shr 23) or anti_hi;


		    stables_lo := dir1_lo and dir2_lo and dir3_lo and dir4_lo and my_bits_low;
		    stables_hi := dir1_hi and dir2_hi and dir3_hi and dir4_hi and my_bits_high;

		    (*
		    EcritBitboardDansRapport('dir1 et dir2 = ',MakeBitboard(dir1_lo,dir1_hi,dir2_lo,dir2_hi));
	      EcritBitboardDansRapport('dir3 et dir4 = ',MakeBitboard(dir3_lo,dir3_hi,dir4_lo,dir4_hi));
	      EcritBitboardDansRapport('old_stables et stables = ',MakeBitboard(old_stables_lo,old_stables_hi,stables_lo,stables_hi));
	      WritelnDansRapport('');
		    AttendFrappeClavier;
		    *)

		  until (stables_lo = old_stables_lo) and (stables_hi = old_stables_hi);

		  n1 := 0;
		  n2 := 0;
		  if stables_lo <> 0 then
		    begin
		      n1 := ((stables_lo shr 1) and constante1) + (stables_lo and constante1);
		      n1 := ((n1 shr 2) and constante2)  + (n1 and constante2);
		      n1 := (n1 + (n1 shr 4)) and constante3;
			    n1 := (n1 + (n1 shr 8));
			    n1 := (n1 + (n1 shr 16)) and constante4;

		      (*
		      n1 := ((stables_lo shr 1) and constante1) + (stables_lo and constante1);
		      n1 := ((n1 shr 2) and constante2)  + (n1 and constante2);
		      n1 := ((n1 shr 4) and constante3)  + (n1 and constante3);
		      n1 := ((n1 shr 8) and constante4)  + (n1 and constante4);
		      n1 := ((n1 shr 16) and constante5) + (n1 and constante5);
		      *)
			  end;
      if (stables_hi <> 0) then
        begin
          n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
		      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
          n2 := (n2 + (n2 shr 4)) and constante3;
			    n2 := (n2 + (n2 shr 8));
			    n2 := (n2 + (n2 shr 16)) and constante4;

          (*
		      n2 := ((stables_hi shr 1) and constante1) + (stables_hi and constante1);
		      n2 := ((n2 shr 2) and constante2)  + (n2 and constante2);
		      n2 := ((n2 shr 4) and constante3)  + (n2 and constante3);
		      n2 := ((n2 shr 8) and constante4)  + (n2 and constante4);
		      n2 := ((n2 shr 16) and constante5) + (n2 and constante5);
		      *)
		    end;

		  (*
		  EcritBitboardDansRapport('stables = ',MakeBitboard(stables_lo,stables_hi,0,0));
		  WritelnNumDansRapport('n1 = ',n1);
		  WritelnNumDansRapport('n2 = ',n2);
		  WritelnNumDansRapport('nbre stables = ',n1+n2);
		  WritelnDansRapport('');
		  AttendFrappeClavier;
		  *)

      CalculePionsStablesBitboard := n1 + n2;


		end;

end;


procedure LanceCalculStabilite(const position : bitboard);
var n : SInt32;
begin
  EcritBitboardDansRapport('position = ',position);

  with position do
    n := CalculePionsStablesBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,1000);

  WritelnNumDansRapport('stables = ',n);
  WritelnDansRapport('');
end;


procedure TestStabiliteBitboard;
begin

  WritelnDansRapport('position verticale');
  LanceCalculStabilite(MakeBitboard($81010101,$80808081,$00000000,$00000000));

  WritelnDansRapport('position initiale');
  LanceCalculStabilite(MakeBitboard($10000000,$00000008,$08000000,$00000010));

  WritelnDansRapport('this is Nicolet position');
  LanceCalculStabilite(MakeBitboard($00000100,$00000000,$0F070201,$7F7F3F1F));

  WritelnDansRapport('this is the summers position');
  LanceCalculStabilite(MakeBitboard($00002AFE,$00000000,$7F7F5501,$837F7F7F));

  WritelnDansRapport('this is the summers position 2');
  LanceCalculStabilite(MakeBitboard($0004FFFF,$00000000,$01FB0000,$01010101));

  WritelnDansRapport('this is the summers position 3');
  LanceCalculStabilite(MakeBitboard($00000000,$00005000,$FFFFFFFF,$FFFFA8FF));

  WritelnDansRapport('this is the summers position 4');
  LanceCalculStabilite(MakeBitboard($FFFFFEFD,$7FFFFFFF,$00000000,$00000000));

  WritelnDansRapport('this is the summers position 5');
  LanceCalculStabilite(MakeBitboard($FFFEFFFD,$3FFFFFFF,$00000000,$00000000));

  WritelnDansRapport('this is the summers position 6');
  LanceCalculStabilite(MakeBitboard($FEFFFFFD,$DFAFFFFF,$00000000,$00000000));

  WritelnDansRapport('this is Nicolet position');
  LanceCalculStabilite(MakeBitboard($0F070201,$7F7F3F1F,$00000100,$00000000));

  WritelnDansRapport('this is the summers position');
  LanceCalculStabilite(MakeBitboard($7F7F5501,$837F7F7F,$00002AFE,$00000000));

  WritelnDansRapport('this is the summers position 2');
  LanceCalculStabilite(MakeBitboard($01FB0000,$01010101,$0004FFFF,$00000000));

  WritelnDansRapport('this is the summers position 3');
  LanceCalculStabilite(MakeBitboard($FFFFFFFF,$FFFFA8FF,$00000000,$00005000));

end;



END.
