UNIT UnitBitboard64bitsModifPlat;

INTERFACE









procedure TestRapiditeBitboard64Bits;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, UnitDefCassio
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitBitboardModifPlat ;
{$ELSEC}
    ;
    {$I prelink/Bitboard64bitsModifPlat.lk}
{$ENDC}


{END_USE_CLAUSE}









{$ifc defined __GPC__}
   {$I CountLeadingZerosForGNUPascal.inc}
{$endc}




procedure TestRapiditeBitboard64Bits;
var k, nb_iterations,nbTicks,tempsDeBase: SInt32;
    a,b,r,s,t,myBool,total_opp : UInt32;
    MY,OPP : UInt32;
    my_left,my_right : UInt32;
    flipped,number_of_flipped : UInt32;
    total_flipped,accu_flipped : UInt32;
    dejaEcrit : boolean;
begin  {$UNUSED myBool,my_left,my_right,s,t}


  (*

  Resultats : il est
  1) plus rapide de faire le test "if (r <> 0) then ..." plutot
     que faire "flipped := flipped * (r >> 24)"
  2) plus rapide de faire "(a shl 8) - a" plutot que faire "a*255"
  3) plus rapide de faire "n shr 3" plutot que "n div 9"
     si n est un multiple de 9 , O <= n <= 63
  4) plus rapide de faire "(n+7) shr 3" plutot que "n div 7"
     si n est un multiple de 7, 0 <= n <= 49
  5) plus rapide de retourner vers la droite au moins deux pions a l'aide d'additions

     Bonne version sans garde, valable a peu pres tout le temps (attention a bien paralleliser!) :
     { flipping to the right of A1, without guard }
      my_right := MY and $000000FC;
      r := (OPP + $00000002) and my_right;
      if r <> 0 then
        begin
          flipped := (r-1) and ($0000007E);
          number_of_flipped := 30 - COUNT_LEADING_ZEROS(r);
        end;


     Bonne version avec garde (attention a bien paralleliser!)
     { flipping to the right of A1, with guard}
      if BAND(OPP,$00000002) <> 0 then { if plat[B1] = adversaire then }
        begin
          my_right := MY and $000000FC;
          r := (OPP + $00000002) and my_right;
		      if r <> 0 then
		        begin
		          flipped := (r-1) and $0000007E;
		          number_of_flipped := 30 - COUNT_LEADING_ZEROS(r);
		        end;
		    end;



  6) moins rapide de retourner vers la droite un pion a l'aide d'additions (attention!)

  7) plus rapide de retourner vers la gauche au moins 2 pions a l'aide d'additions.

     Bonne version sans garde, pour les othelliers tres remplis (attention!) :
    { Flipping to the left of H1, without guard }
      s := $00000080;
      my_left := MY and $0000003F;
			r := (OPP + (my_left shl 1)) and s;
			if (r <> 0) then
			  begin
			    number_of_flipped := COUNT_LEADING_ZEROS(my_left) - 25;
			    flipped := s - (s shr number_of_flipped);
			  end;

		 Bonne version avec garde, pour les othelliers peu remplis (attention!) :
    { Flipping to the left of H1, with guard }
      if BAND(OPP,$00000040) <> 0 then { if plat[G1] = adversaire then }
        begin
		      s := $00000080;
					r := (OPP + (MY shl 1)) and s;
					if (r <> 0) then
					  begin
					    my_left := MY and $0000003F;
					    number_of_flipped := COUNT_LEADING_ZEROS(my_left) - 25;
					    flipped := s - (s shr number_of_flipped);
					  end;
			  end;

  *)



  nb_iterations := 200000000;



  nbTicks := TickCount;
  flipped := 0;
  number_of_flipped := 0;
  total_flipped := 0;
  accu_flipped := 0;
  total_opp := 0;
  a := 1;
  b := 1;
  for k := nb_iterations downto 0 do
    begin
      b := a;
      {a := a+100;}
      a := 1664525 * a + 1013904223;

      MY  := a and $FFFFFF7F;
      {OPP := not(MY) and $FFFFFF7F;}
      OPP := (b and not(MY)) and $FFFFFF7F;

      total_opp := total_opp + OPP;
    end;
  nbTicks := TickCount - nbTicks;
  tempsDeBase := nbTicks;
  WritelnNumDansRapport('methode 0 : nbTicks = ', nbTicks);
  WritelnNumDansRapport('temps de retournements : nbTicks = ',nbTicks- tempsDeBase);
  {WritelnNumDansRapport('flipped = ', flipped);
  {WritelnNumDansRapport('flipped = ', flipped);
  WritelnNumDansRapport('number_of_flipped = ', number_of_flipped);}
  WritelnNumDansRapport('accu_flipped = ',accu_flipped);
  WritelnNumDansRapport('total_flipped = ',total_flipped);
  WritelnNumDansRapport('total_opp = ',total_opp);
  WritelnDansRapport('');
  dejaEcrit := false;






  nbTicks := TickCount;


  flipped := 0;
  number_of_flipped := 0;
  total_flipped := 0;
  accu_flipped := 0;
  total_opp := 0;

  a := 1;
  b := 1;
  for k := nb_iterations downto 0 do
    begin
      b := a;
      {a := a+100;}
      a := 1664525 * a + 1013904223;


      MY  := a and $FFFFFF7F;
      {OPP := not(MY) and $FFFFFF7F;}
      OPP := (b and not(MY)) and $FFFFFF7F;

      total_opp := total_opp + OPP;

      {
      EcritBitboardDansRapport('position = ',MakeBitboard(MY,$FFFFFFFF,OPP,0));
      }

      {retournements a la gauche de H1}
      if BAND(OPP,$00000040) <> 0 then { if plat[G1] = adversaire then }
        begin
          if BAND(OPP,$00000020) <> 0 then { if plat[F1] = adversaire then }
            begin
              if BAND(OPP,$00000010) <> 0 then { if plat[E1] = adversaire then }
                begin
                  if BAND(OPP,$00000008) <> 0 then { if plat[D1] = adversaire then }
                    begin
                      if BAND(OPP,$00000004) <> 0 then { if plat[C1] = adversaire then }
                        begin
                          if BAND(OPP,$00000002) <> 0 then { if plat[B1] = adversaire then }
                            begin
                              if BAND(MY,$00000001) <> 0 then { if plat[A1] = couleur then }
                                begin
                                  flipped := $0000007E;
													        number_of_flipped := 6;

                                  accu_flipped := accu_flipped + flipped;
												          total_flipped := total_flipped + number_of_flipped;
                                end;
                            end
                          else
                          if BAND(MY,$00000002) <> 0 then { if plat[B1] = couleur then }
                            begin
                              flipped := $0000007C;
													    number_of_flipped := 5;

                              accu_flipped := accu_flipped + flipped;
												      total_flipped := total_flipped + number_of_flipped;
                            end;
                        end
                      else
                      if BAND(MY,$00000004) <> 0 then { if plat[C1] = couleur then }
                        begin
                          flipped := $00000078;
													number_of_flipped := 4;

                          accu_flipped := accu_flipped + flipped;
												  total_flipped := total_flipped + number_of_flipped;
                        end;
                    end
                  else
                  if BAND(MY,$00000008) <> 0 then { if plat[D1] = couleur then }
                    begin
                      flipped := $00000070;
											number_of_flipped := 3;

                      accu_flipped := accu_flipped + flipped;
											total_flipped := total_flipped + number_of_flipped;
                    end;
                end
              else
              if BAND(MY,$00000010) <> 0 then { if plat[E1] = couleur then }
                begin
                  flipped := $00000060;
									number_of_flipped := 2;

                  accu_flipped := accu_flipped + flipped;
									total_flipped := total_flipped + number_of_flipped;
                end;
            end
          else
          if BAND(MY,$00000020) <> 0 then { if plat[F1] = couleur then }
            begin
              flipped := $00000040;
							number_of_flipped := 1;

              accu_flipped := accu_flipped + flipped;
							total_flipped := total_flipped + number_of_flipped;
            end;
        end;


    end;
  nbTicks := TickCount - nbTicks;


  WritelnNumDansRapport('methode 1 : nbTicks = ', nbTicks);
  WritelnNumDansRapport('temps de retournements : nbTicks = ',nbTicks- tempsDeBase);
  {WritelnNumDansRapport('flipped = ', flipped);
  WritelnNumDansRapport('number_of_flipped = ', number_of_flipped);}
  WritelnNumDansRapport('accu_flipped = ',accu_flipped);
  WritelnNumDansRapport('total_flipped = ',total_flipped);
  WritelnNumDansRapport('total_opp = ',total_opp);
  WritelnDansRapport('');
  dejaEcrit := false;
















  nbTicks := TickCount;

  flipped := 0;
  number_of_flipped := 0;
  total_flipped := 0;
  accu_flipped := 0;
  total_opp := 0;

  a := 1;
  b := 1;
  for k := nb_iterations downto 0 do
    begin
      b := a;
      {a := a+100;}
      a := 1664525 * a + 1013904223;

      MY  := a and $FFFFFF7F;
      {OPP := not(MY) and $FFFFFF7F;}
      OPP := (b and not(MY)) and $FFFFFF7F;

      total_opp := total_opp + OPP;

      {EcritBitboardDansRapport('position = ',MakeBitboard(MY,$FFFFFFFF,OPP,0));}

      { Flipping to the left of H1, with guard }
      if BAND(OPP,$00000040) <> 0 then { if plat[G1] = adversaire then }
        begin
		      s := $00000080;
					r := (OPP + (MY shl 1)) and s;
					if (r <> 0) then
					  begin
					    my_left := MY and $0000003F;
					    number_of_flipped := COUNT_LEADING_ZEROS(my_left) - 25;
					    flipped := s - (s shr number_of_flipped);

		          accu_flipped := accu_flipped + flipped;
		          total_flipped := total_flipped + number_of_flipped;

		          {
		          EcritBitboardDansRapport('r, flipped = ',MakeBitboard(r,0,flipped,0));
		          WritelnNumDansRapport('number_of_flipped = ',number_of_flipped);
		          }
		        end;
		    end;
    end;
  nbTicks := TickCount - nbTicks;

  WritelnNumDansRapport('methode 2 : nbTicks = ', nbTicks);
  WritelnNumDansRapport('temps de retournements : nbTicks = ',nbTicks- tempsDeBase);
  {WritelnNumDansRapport('flipped = ', flipped);
  WritelnNumDansRapport('number_of_flipped = ', number_of_flipped);}
  WritelnNumDansRapport('accu_flipped = ',accu_flipped);
  WritelnNumDansRapport('total_flipped = ',total_flipped);
  WritelnNumDansRapport('total_opp = ',total_opp);
  WritelnDansRapport('');
  dejaEcrit := false;


  nbTicks := TickCount;

  flipped := 0;
  number_of_flipped := 0;
  total_flipped := 0;
  accu_flipped := 0;
  total_opp := 0;

  a := 1;
  b := 1;
  for k := nb_iterations downto 0 do
    begin
      b := a;
      {a := a+100;}
      a := 1664525 * a + 1013904223;

      MY  := a and $FFFFFF7F;
      {OPP := not(MY) and $FFFFFF7F;}
      OPP := (b and not(MY)) and $FFFFFF7F;

      total_opp := total_opp + OPP;

      {EcritBitboardDansRapport('position = ',MakeBitboard(MY,$FFFFFFFF,OPP,0));}

      { Flipping to the left of H1, without guard }

			s := $00000080;
      my_left := MY and $0000003F;
			r := (OPP + (my_left shl 1)) and s;
			if (r <> 0) then
			  begin
			    number_of_flipped := COUNT_LEADING_ZEROS(my_left) - 25;
			    flipped := s - (s shr number_of_flipped);


          accu_flipped := accu_flipped + flipped;
          total_flipped := total_flipped + number_of_flipped;

          {
          EcritBitboardDansRapport('r, flipped = ',MakeBitboard(r,0,flipped,0));
          WritelnNumDansRapport('number_of_flipped = ',number_of_flipped);
          }
        end;
    end;
  nbTicks := TickCount - nbTicks;

  WritelnNumDansRapport('methode 3 : nbTicks = ', nbTicks);
  WritelnNumDansRapport('temps de retournements : nbTicks = ',nbTicks- tempsDeBase);
  {WritelnNumDansRapport('flipped = ', flipped);
  WritelnNumDansRapport('number_of_flipped = ', number_of_flipped);}
  WritelnNumDansRapport('accu_flipped = ',accu_flipped);
  WritelnNumDansRapport('total_flipped = ',total_flipped);
  WritelnNumDansRapport('total_opp = ',total_opp);
  WritelnDansRapport('');
  dejaEcrit := false;







end;



(*
      {retournements a la droite de A1}
      if BAND(OPP,$00000002) <> 0 then { if plat[B1] = adversaire then }
              begin
                if BAND(OPP,$00000004) <> 0 then { if plat[C1] = adversaire then }
                  begin
                    if BAND(OPP,$00000008) <> 0 then { if plat[D1] = adversaire then }
                      begin
                        if BAND(OPP,$00000010) <> 0 then { if plat[E1] = adversaire then }
                          begin
                            if BAND(OPP,$00000020) <> 0 then { if plat[F1] = adversaire then }
                              begin
                                if BAND(OPP,$00000040) <> 0 then { if plat[G1] = adversaire then }
                                  begin
                                    if BAND(MY,$00000080) <> 0 then { if plat[H1] = couleur then }
                                      begin
                                        flipped := $0000007E;
													              number_of_flipped := 6;

													              accu_flipped := accu_flipped + flipped;
												                total_flipped := total_flipped + number_of_flipped;
                                      end;
                                  end
                                else
                                if BAND(MY,$00000040) <> 0 then { if plat[G1] = couleur then }
                                  begin
                                    flipped := $0000003E;
													          number_of_flipped := 5;

													          accu_flipped := accu_flipped + flipped;
												            total_flipped := total_flipped + number_of_flipped;
                                  end;
                              end
                            else
                            if BAND(MY,$00000020) <> 0 then { if plat[F1] = couleur then }
                              begin
                                flipped := $0000001E;
													      number_of_flipped := 4;

													      accu_flipped := accu_flipped + flipped;
												        total_flipped := total_flipped + number_of_flipped;
                              end;
                          end
                        else
                        if BAND(MY,$00000010) <> 0 then { if plat[E1] = couleur then }
                          begin
                            flipped := $0000000E;
													  number_of_flipped := 3;

													  accu_flipped := accu_flipped + flipped;
												    total_flipped := total_flipped + number_of_flipped;
                          end;
                      end
                    else
                    if BAND(MY,$00000008) <> 0 then { if plat[D1] = couleur then }
                      begin
                        flipped := $00000006;
											  number_of_flipped := 2;

											  accu_flipped := accu_flipped + flipped;
												total_flipped := total_flipped + number_of_flipped;
                      end;
                  end
                else
                if BAND(MY,$00000004) <> 0 then { if plat[C1] = couleur then }
                  begin
                    flipped := $00000002;
										number_of_flipped := 1;

										accu_flipped := accu_flipped + flipped;
										total_flipped := total_flipped + number_of_flipped;
                  end;
              end;
 *)

(*
*)

(*

function ModifPlatCompBitboard(coup : SInt32; var g_bitboard : t_compbitboard; var diffPions : SInt32) : boolean;
var nbprise : SInt32;
    my_bits,opp_bits : comp;
    my_double : double;
begin
  with g_bitboard do
    begin
      nbprise := 0;

      my_bits := g_mybits   ;
      opp_bits := g_oppbits  ;

      my_double := double(my_bits);

      case coup of
        11 :    { A1 }
          begin
              if (opp_bits and $0000000000000002) <> 0 then { if plat[B1] = adversaire then }
                begin
                  if (opp_bits and $0000000000000004) <> 0 then { if plat[C1] = adversaire then }
                    begin
                      if (opp_bits and $0000000000000008) <> 0 then { if plat[D1] = adversaire then }
                        begin
                          if (opp_bits and $0000000000000010) <> 0 then { if plat[E1] = adversaire then }
                            begin
                              if (opp_bits and $0000000000000020) <> 0 then { if plat[F1] = adversaire then }
                                begin
                                  if (opp_bits and $0000000000000040) <> 0 then { if plat[G1] = adversaire then }
                                    begin
                                      if (my_bits and $0000000000000080) <> 0 then { if plat[H1] = couleur then }
                                        begin
                                          nbprise := nbprise + 12;
                                          my_bits := (my_bits or $000000000000007E);
                                          opp_bits := (opp_bits xor $000000000000007E);
                                        end;
                                    end
                                  else
                                  if (my_bits and $0000000000000040) <> 0 then { if plat[G1] = couleur then }
                                    begin
                                      nbprise := nbprise + 10;
                                      my_bits := (my_bits or $000000000000003E);
                                      opp_bits := (opp_bits xor $000000000000003E);
                                    end;
                                end
                              else
                              if (my_bits and $0000000000000020) <> 0 then { if plat[F1] = couleur then }
                                begin
                                  nbprise := nbprise + 8;
                                  my_bits := (my_bits or $000000000000001E);
                                  opp_bits := (opp_bits xor $000000000000001E);
                                end;
                            end
                          else
                          if (my_bits and $0000000000000010) <> 0 then { if plat[E1] = couleur then }
                            begin
                              nbprise := nbprise + 6;
                              my_bits := (my_bits or $000000000000000E);
                              opp_bits := (opp_bits xor $000000000000000E);
                            end;
                        end
                      else
                      if (my_bits and $0000000000000008) <> 0 then { if plat[D1] = couleur then }
                        begin
                          nbprise := nbprise + 4;
                          my_bits := (my_bits or $0000000000000006);
                          opp_bits := (opp_bits xor $0000000000000006);
                        end;
                    end
                  else
                  if (my_bits and $0000000000000004) <> 0 then { if plat[C1] = couleur then }
                    begin
                      nbprise := nbprise + 2;
                      my_bits := (my_bits or $0000000000000002);
                      opp_bits := (opp_bits xor $0000000000000002);
                    end;
                end;
              if (opp_bits and $0000000000000200) <> 0 then { if plat[B2] = adversaire then }
                begin
                  if (opp_bits and $0000000000040000) <> 0 then { if plat[C3] = adversaire then }
                    begin
                      if (opp_bits and $0000000008000000) <> 0 then { if plat[D4] = adversaire then }
                        begin
                          if (opp_bits and $0000001000000000) <> 0 then { if plat[E5] = adversaire then }
                            begin
                              if (opp_bits and $0000200000000000) <> 0 then { if plat[F6] = adversaire then }
                                begin
                                  if (opp_bits and $0040000000000000) <> 0 then { if plat[G7] = adversaire then }
                                    begin
                                      if (my_bits and $8000000000000000) <> 0 then { if plat[H8] = couleur then }
                                        begin
                                          nbprise := nbprise + 12;
                                          my_bits := (my_bits shl 1);
                                          opp_bits := (opp_bits xor $0000000008040200);
                                          my_bits := (my_bits shr 9);
                                          opp_bits := (opp_bits xor $0040201000000000);
                                        end;
                                    end
                                  else
                                  if (my_bits and $0040000000000000) <> 0 then { if plat[G7] = couleur then }
                                    begin
                                      nbprise := nbprise + 10;
                                      my_bits := (my_bits or $0000000008040200);
                                      opp_bits := (opp_bits xor $0000000008040200);
                                      my_bits := (my_bits or $0000201000000000);
                                      opp_bits := (opp_bits xor $0000201000000000);
                                    end;
                                end
                              else
                              if (my_bits and $0000200000000000) <> 0 then { if plat[F6] = couleur then }
                                begin
                                  nbprise := nbprise + 8;
                                  my_bits := (my_bits or $0000000008040200);
                                  opp_bits := (opp_bits xor $0000000008040200);
                                  my_bits := (my_bits or $0000001000000000);
                                  opp_bits := (opp_bits xor $0000001000000000);
                                end;
                            end
                          else
                          if (my_bits and $0000001000000000) <> 0 then { if plat[E5] = couleur then }
                            begin
                              nbprise := nbprise + 6;
                              my_bits := (my_bits or $0000000008040200);
                              opp_bits := (opp_bits xor $0000000008040200);
                            end;
                        end
                      else
                      if (my_bits and $0000000008000000) <> 0 then { if plat[D4] = couleur then }
                        begin
                          nbprise := nbprise + 4;
                          my_bits := (my_bits or $0000000000040200);
                          opp_bits := (opp_bits xor $0000000000040200);
                        end;
                    end
                  else
                  if (my_bits and $0000000000040000) <> 0 then { if plat[C3] = couleur then }
                    begin
                      nbprise := nbprise + 2;
                      my_bits := (my_bits or $0000000000000200);
                      opp_bits := (opp_bits xor $0000000000000200);
                    end;
                end;
              if (opp_bits and $0000000000000100) <> 0 then { if plat[A2] = adversaire then }
                begin
                  if (opp_bits and $0000000000010000) <> 0 then { if plat[A3] = adversaire then }
                    begin
                      if (opp_bits and $0000000001000000) <> 0 then { if plat[A4] = adversaire then }
                        begin
                          if (opp_bits and $0000000100000000) <> 0 then { if plat[A5] = adversaire then }
                            begin
                              if (opp_bits and $0000010000000000) <> 0 then { if plat[A6] = adversaire then }
                                begin
                                  if (opp_bits and $0001000000000000) <> 0 then { if plat[A7] = adversaire then }
                                    begin
                                      if (my_bits and $0100000000000000) <> 0 then { if plat[A8] = couleur then }
                                        begin
                                          nbprise := nbprise + 12;
                                          my_bits := (my_bits or $0000000001010100);
                                          opp_bits := (opp_bits xor $0000000001010100);
                                          my_bits := (my_bits or $0001010100000000);
                                          opp_bits := (opp_bits xor $0001010100000000);
                                        end;
                                    end
                                  else
                                  if (my_bits and $00010000) <> 0 then { if plat[A7] = couleur then }
                                    begin
                                      nbprise := nbprise + 10;
                                      my_bits := (my_bits or $0000000001010100);
                                      opp_bits := (opp_bits xor $0000000001010100);
                                      my_bits := (my_bits or $0000010100000000);
                                      opp_bits := (opp_bits xor $0000010100000000);
                                    end;
                                end
                              else
                              if (my_bits and $0000010000000000) <> 0 then { if plat[A6] = couleur then }
                                begin
                                  nbprise := nbprise + 8;
                                  my_bits := (my_bits or $0000000001010100);
                                  opp_bits := (opp_bits xor $0000000001010100);
                                  my_bits := (my_bits or $0000000100000000);
                                  opp_bits := (opp_bits xor $0000000100000000);
                                end;
                            end
                          else
                          if (my_bits and $0000000100000000) <> 0 then { if plat[A5] = couleur then }
                            begin
                              nbprise := nbprise + 6;
                              my_bits := (my_bits or $0000000001010100);
                              opp_bits := (opp_bits xor $0000000001010100);
                            end;
                        end
                      else
                      if (my_bits and $0000000001000000) <> 0 then { if plat[A4] = couleur then }
                        begin
                          nbprise := nbprise + 4;
                          my_bits := (my_bits or $0000000000010100);
                          opp_bits := (opp_bits xor $0000000000010100);
                        end;
                    end
                  else
                  if (my_bits and $0000000000010000) <> 0 then { if plat[A3] = couleur then }
                    begin
                      nbprise := nbprise + 2;
                      my_bits := (my_bits or $0000000000000100);
                      opp_bits := (opp_bits xor $0000000000000100);
                    end;
                end;
            if (nbprise > 0)
              then
                begin
                  diffPions := succ(diffPions+nbprise);
                  ModifPlatCompBitboard := true;
                  my_bits := (my_bits or $0000000000000001);  { place the disc in A1 }
                  g_mybits   := opp_bits;  {le trait change : on echange my_bits et opp_bits}
                  g_oppbits  := my_bits;
                end
              else
                ModifPlatCompBitboard := false;
          end;
      end; {case}
    end;
end;

*)


(*

// __shl2i 	- 64-bit shift left for 32-bit PowerPC
//
//	Input:
//		[unsigned/signed] long long value in R3:R4
//		shift count in R5
//
//
//	Output:
//		shifted value in R3:R4
//
//
asm void __shl2i(void)
{
	subfic	r8,r5,32
	subic	r9,r5,32
	slw		r3,r3,r5
	srw		r10,r4,r8
	or		r3,r3,r10
	slw		r10,r4,r9
	or		r3,r3,r10			// high word
	slw		r4,r4,r5			// low word
	blr
}


// __shr2u 	- 64-bit logical shift right for 32-bit PowerPC
//
//	Input:
//		unsigned long long value in R3:R4
//		shift count in R5
//
//
//	Output:
//		shifted value in R3:R4
//
//
asm void __shr2u(void)
{
	subfic	r8,r5,32
	subic	r9,r5,32
	srw		r4,r4,r5
	slw		r10,r3,r8
	or		r4,r4,r10
	srw		r10,r3,r9
	or		r4,r4,r10			// low word
	srw		r3,r3,r5			// high word
	blr
}


// __shr2i 	- 64-bit arithmetic shift right for 32-bit PowerPC
//
//	Input:
//		signed long long value in R3:R4
//		shift count in R5
//
//
//	Output:
//		shifted value in R3:R4
//
//
asm void __shr2i(void)
{
	subfic	r8,r5,32
	subic.	r9,r5,32
	srw		r4,r4,r5
	slw		r10,r3,r8
	or		r4,r4,r10
	sraw	r10,r3,r9
	ble		around
	or		r4,r4,r10			// low word
around:
	sraw	r3,r3,r5			// high word
	blr
}

asm void __div2u(void)
{
       // count the number of leading 0s in the dividend
       cmpwi	cr0,r3,0		// dvd.msw == 0?
       cntlzw	r0,r3			// R0 = dvd.msw.LZ
       cntlzw	r9,r4			// R9 = dvd.lsw.LZ
       bne		cr0,lab1		// if(dvd.msw == 0) dvd.LZ = dvd.msw.LZ
       addi		r0,r9,32		// dvd.LZ = dvd.lsw.LZ + 32
 lab1:
       // count the number of leading 0s in the divisor
       cmpwi	cr0,r5,0		// dvd.msw == 0?
       cntlzw	r9,r5			// R9 = dvs.msw.LZ
       cntlzw	r10,r6			// R10 = dvs.lsw.LZ
       bne		cr0,lab2		// if(dvs.msw == 0) dvs.LZ = dvs.msw.LZ
       addi		r9,r10,32		// dvs.LZ = dvs.lsw.LZ + 32
 lab2:
       // determine shift amounts to minimize the number of iterations
       cmpw		cr0,r0,r9		// compare dvd.LZ to dvs.LZ
       subfic	r10,r0,64		// R10 = dvd.SD
       bgt		cr0,lab9		// if(dvs > dvd) quotient = 0
       addi		r9,r9,1			// ++dvs.LZ (or --dvs.SD)
       subfic	r9,r9,64		// R9 = dvs.SD
       add		r0,r0,r9		// (dvd.LZ + dvs.SD) = left shift of dvd for
                         		// initial dvd
       subf		r9,r9,r10		// (dvd.SD - dvs.SD) = right shift of dvd for
                         		// initial tmp
       mtctr	r9				// number of iterations = dvd.SD - dvs.SD

       // R7:R8 = R3:R4 >> R9
       cmpwi	cr0,r9,32		// compare R9 to 32
       addi		r7,r9,-32
       blt		cr0,lab3		// if(R9 < 32) jump to lab3
       srw		r8,r3,r7		// tmp.lsw = dvd.msw >> (R9 - 32)
       li		r7,0			// tmp.msw = 0
       b		lab4
 lab3:
       srw		r8,r4,r9		// R8 = dvd.lsw >> R9
       subfic	r7,r9,32
       slw		r7,r3,r7		// R7 = dvd.msw << 32 - R9
       or		r8,r8,r7		// tmp.lsw = R8 or R7
       srw		r7,r3,r9		// tmp.msw = dvd.msw >> R9
 lab4:
       // R3:R4 = R3:R4 << R0
       cmpwi	cr0,r0,32		// compare R0 to 32
       addic	r9,r0,-32
       blt		cr0,lab5		// if(R0 < 32) jump to lab5
       slw		r3,r4,r9		// dvd.msw = dvd.lsw << R9
       li		r4,0			// dvd.lsw = 0
       b		lab6
 lab5:
       slw		r3,r3,r0		// R3 = dvd.msw << R0
       subfic	r9,r0,32
       srw		r9,r4,r9		// R9 = dvd.lsw >> 32 - R0
       or		r3,r3,r9		// dvd.msw = R3 or R9
       slw		r4,r4,r0		// dvd.lsw = dvd.lsw << R0
 lab6:
       // restoring division shift and subtract loop
       li		r10,-1			// R10 = -1
       addic	r7,r7,0			// clear carry bit before loop starts
 lab7:
       // tmp:dvd is considered one large register
       // each portion is shifted left 1 bit by adding it to itself
       // adde sums the carry from the previous and creates a new carry
       adde		r4,r4,r4		// shift dvd.lsw left 1 bit
       adde		r3,r3,r3		// shift dvd.msw to left 1 bit
       adde		r8,r8,r8		// shift tmp.lsw to left 1 bit
       adde		r7,r7,r7		// shift tmp.msw to left 1 bit
       subfc	r0,r6,r8		// tmp.lsw - dvs.lsw
       subfe.	r9,r5,r7		// tmp.msw - dvs.msw
       blt		cr0,lab8		// if(result < 0) clear carry bit
       mr		r8,r0			// move lsw
       mr		r7,r9			// move msw
       addic	r0,r10,1		// set carry bit
 lab8:
       bdnz		lab7

       // write quotient
       adde		r4,r4,r4		// quo.lsw (lsb = CA)
       adde		r3,r3,r3		// quo.msw (lsb from lsw)
       blr						// return
 lab9:
       // Quotient is 0 (dvs > dvd)
       li		r4,0			// dvd.lsw = 0
       li		r3,0			// dvd.msw = 0
       blr						// return
}



*)

END.
