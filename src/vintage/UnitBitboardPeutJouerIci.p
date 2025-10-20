UNIT UnitBitboardPeutJouerIci;

INTERFACE







 USES UnitDefCassio;




function PeutJouerIciBitboard(coup : SInt32; var position : bitboard) : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}
















function PeutJouerIciBitboard(coup : SInt32; var position : bitboard) : boolean;
var my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
label LeCoupEstLegal,LeCoupEstIllegal;
begin
  with position do
    begin

      my_bits_low := g_my_bits_low   ;
      my_bits_high := g_my_bits_high  ;
      opp_bits_low := g_opp_bits_low  ;
      opp_bits_high := g_opp_bits_high ;

		  case coup of
        11 :    { A1 }
          begin
            if BAnd(opp_bits_low+$00000002,BAnd(my_bits_low,$000000FC)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        12 :    { B1 }
          begin
            if BAnd(opp_bits_low+$00000004,BAnd(my_bits_low,$000000F8)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        13 :    { C1 }
          begin
            if BAnd(opp_bits_low+$00000008,BAnd(my_bits_low,$000000F0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000002)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        14 :    { D1 }
          begin
            if BAnd(opp_bits_low+$00000010,BAnd(my_bits_low,$000000E0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000004)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        15 :    { E1 }
          begin
            if BAnd(opp_bits_low+$00000020,BAnd(my_bits_low,$000000C0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000008)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        16 :    { F1 }
          begin
            if BAnd(opp_bits_low+$00000040,BAnd(my_bits_low,$00000080)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000010)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        17 :    { G1 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000020)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        18 :    { H1 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000040)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                              begin
                                if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                                  begin
                                    if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        21 :    { A2 }
          begin
            if BAnd(opp_bits_low+$00000200,BAnd(my_bits_low,$0000FC00)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        22 :    { B2 }
          begin
            if BAnd(opp_bits_low+$00000400,BAnd(my_bits_low,$0000F800)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        23 :    { C2 }
          begin
            if BAnd(opp_bits_low+$00000800,BAnd(my_bits_low,$0000F000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000200)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        24 :    { D2 }
          begin
            if BAnd(opp_bits_low+$00001000,BAnd(my_bits_low,$0000E000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000400)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        25 :    { E2 }
          begin
            if BAnd(opp_bits_low+$00002000,BAnd(my_bits_low,$0000C000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00000800)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        26 :    { F2 }
          begin
            if BAnd(opp_bits_low+$00004000,BAnd(my_bits_low,$00008000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00001000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        27 :    { G2 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00002000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        28 :    { H2 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00004000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                          begin
                            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                              begin
                                if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        31 :    { A3 }
          begin
            if BAnd(opp_bits_low+$00020000,BAnd(my_bits_low,$00FC0000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        32 :    { B3 }
          begin
            if BAnd(opp_bits_low+$00040000,BAnd(my_bits_low,$00F80000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        33 :    { C3 }
          begin
            if BAnd(opp_bits_low+$00080000,BAnd(my_bits_low,$00F00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00020000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        34 :    { D3 }
          begin
            if BAnd(opp_bits_low+$00100000,BAnd(my_bits_low,$00E00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00040000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        35 :    { E3 }
          begin
            if BAnd(opp_bits_low+$00200000,BAnd(my_bits_low,$00C00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00080000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        36 :    { F3 }
          begin
            if BAnd(opp_bits_low+$00400000,BAnd(my_bits_low,$00800000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00100000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        37 :    { G3 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00200000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        38 :    { H3 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$00400000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                      begin
                        if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                          begin
                            if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        41 :    { A4 }
          begin
            if BAnd(opp_bits_low+$02000000,BAnd(my_bits_low,$FC000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        42 :    { B4 }
          begin
            if BAnd(opp_bits_low+$04000000,BAnd(my_bits_low,$F8000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        43 :    { C4 }
          begin
            if BAnd(opp_bits_low+$08000000,BAnd(my_bits_low,$F0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$02000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
              begin
                if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        44 :    { D4 }
          begin
            if BAnd(opp_bits_low+$10000000,BAnd(my_bits_low,$E0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$04000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        45 :    { E4 }
          begin
            if BAnd(opp_bits_low+$20000000,BAnd(my_bits_low,$C0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$08000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        46 :    { F4 }
          begin
            if BAnd(opp_bits_low+$40000000,BAnd(my_bits_low,$80000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$10000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        47 :    { G4 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$20000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        48 :    { H4 }
          begin
            if BAnd(BSr(opp_bits_low,1)+my_bits_low,BAnd(opp_bits_low,$40000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                      begin
                        if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        51 :    { A5 }
          begin
            if BAnd(opp_bits_high+$00000002,BAnd(my_bits_high,$000000FC)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        52 :    { B5 }
          begin
            if BAnd(opp_bits_high+$00000004,BAnd(my_bits_high,$000000F8)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        53 :    { C5 }
          begin
            if BAnd(opp_bits_high+$00000008,BAnd(my_bits_high,$000000F0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000002)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
              begin
                if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(my_bits_high,$00010000) <> 0 then { if plat[A7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        54 :    { D5 }
          begin
            if BAnd(opp_bits_high+$00000010,BAnd(my_bits_high,$000000E0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000004)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00020000) <> 0 then { if plat[B7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        55 :    { E5 }
          begin
            if BAnd(opp_bits_high+$00000020,BAnd(my_bits_high,$000000C0)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000008)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00040000) <> 0 then { if plat[C7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        56 :    { F5 }
          begin
            if BAnd(opp_bits_high+$00000040,BAnd(my_bits_high,$00000080)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000010)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00080000) <> 0 then { if plat[D7] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        57 :    { G5 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000020)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00400000) <> 0 then { if plat[G7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00100000) <> 0 then { if plat[E7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        58 :    { H5 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000040)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00800000) <> 0 then { if plat[H7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00200000) <> 0 then { if plat[F7] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
              begin
                if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        61 :    { A6 }
          begin
            if BAnd(opp_bits_high+$00000200,BAnd(my_bits_high,$0000FC00)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
              begin
                if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        62 :    { B6 }
          begin
            if BAnd(opp_bits_high+$00000400,BAnd(my_bits_high,$0000F800)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        63 :    { C6 }
          begin
            if BAnd(opp_bits_high+$00000800,BAnd(my_bits_high,$0000F000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000200)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
              begin
                if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(my_bits_high,$01000000) <> 0 then { if plat[A8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        64 :    { D6 }
          begin
            if BAnd(opp_bits_high+$00001000,BAnd(my_bits_high,$0000E000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000400)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(my_bits_high,$02000000) <> 0 then { if plat[B8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        65 :    { E6 }
          begin
            if BAnd(opp_bits_high+$00002000,BAnd(my_bits_high,$0000C000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00000800)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(my_bits_high,$04000000) <> 0 then { if plat[C8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        66 :    { F6 }
          begin
            if BAnd(opp_bits_high+$00004000,BAnd(my_bits_high,$00008000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00001000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(my_bits_high,$08000000) <> 0 then { if plat[D8] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        67 :    { G6 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00002000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(my_bits_high,$40000000) <> 0 then { if plat[G8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(my_bits_high,$10000000) <> 0 then { if plat[E8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        68 :    { H6 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00004000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
              begin
                if BAnd(my_bits_high,$80000000) <> 0 then { if plat[H8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(my_bits_high,$20000000) <> 0 then { if plat[F8] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
              begin
                if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        71 :    { A7 }
          begin
            if BAnd(opp_bits_high+$00020000,BAnd(my_bits_high,$00FC0000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        72 :    { B7 }
          begin
            if BAnd(opp_bits_high+$00040000,BAnd(my_bits_high,$00F80000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        73 :    { C7 }
          begin
            if BAnd(opp_bits_high+$00080000,BAnd(my_bits_high,$00F00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00020000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        74 :    { D7 }
          begin
            if BAnd(opp_bits_high+$00100000,BAnd(my_bits_high,$00E00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00040000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        75 :    { E7 }
          begin
            if BAnd(opp_bits_high+$00200000,BAnd(my_bits_high,$00C00000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00080000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                  begin
                    if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        76 :    { F7 }
          begin
            if BAnd(opp_bits_high+$00400000,BAnd(my_bits_high,$00800000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00100000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        77 :    { G7 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00200000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        78 :    { H7 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$00400000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
                  begin
                    if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        81 :    { A8 }
          begin
            if BAnd(opp_bits_high+$02000000,BAnd(my_bits_high,$FC000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00010000) <> 0 then { if plat[A7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000100) <> 0 then { if plat[A6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000001) <> 0 then { if plat[A5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$01000000) <> 0 then { if plat[A4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00010000) <> 0 then { if plat[A3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00000100) <> 0 then { if plat[A2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        82 :    { B8 }
          begin
            if BAnd(opp_bits_high+$04000000,BAnd(my_bits_high,$F8000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000002) <> 0 then { if plat[B1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        83 :    { C8 }
          begin
            if BAnd(opp_bits_high+$08000000,BAnd(my_bits_high,$F0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$02000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00020000) <> 0 then { if plat[B7] = adversaire then }
              begin
                if BAnd(my_bits_high,$00000100) <> 0 then { if plat[A6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00000400) <> 0 then { if plat[C2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000004) <> 0 then { if plat[C1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00000400) <> 0 then { if plat[C2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        84 :    { D8 }
          begin
            if BAnd(opp_bits_high+$10000000,BAnd(my_bits_high,$E0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$04000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00040000) <> 0 then { if plat[C7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000200) <> 0 then { if plat[B6] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00000001) <> 0 then { if plat[A5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000200) <> 0 then { if plat[B6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00080000) <> 0 then { if plat[D3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00000800) <> 0 then { if plat[D2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000008) <> 0 then { if plat[D1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00000800) <> 0 then { if plat[D2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00080000) <> 0 then { if plat[D3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        85 :    { E8 }
          begin
            if BAnd(opp_bits_high+$20000000,BAnd(my_bits_high,$C0000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$08000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00080000) <> 0 then { if plat[D7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000400) <> 0 then { if plat[C6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000002) <> 0 then { if plat[B5] = adversaire then }
                      begin
                        if BAnd(my_bits_low,$01000000) <> 0 then { if plat[A4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000002) <> 0 then { if plat[B5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000400) <> 0 then { if plat[C6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$10000000) <> 0 then { if plat[E4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00100000) <> 0 then { if plat[E3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00001000) <> 0 then { if plat[E2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000010) <> 0 then { if plat[E1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00001000) <> 0 then { if plat[E2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00100000) <> 0 then { if plat[E3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$10000000) <> 0 then { if plat[E4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                  begin
                    if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        86 :    { F8 }
          begin
            if BAnd(opp_bits_high+$40000000,BAnd(my_bits_high,$80000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$10000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00100000) <> 0 then { if plat[E7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00000800) <> 0 then { if plat[D6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000004) <> 0 then { if plat[C5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$02000000) <> 0 then { if plat[B4] = adversaire then }
                          begin
                            if BAnd(my_bits_low,$00010000) <> 0 then { if plat[A3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$02000000) <> 0 then { if plat[B4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000004) <> 0 then { if plat[C5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00000800) <> 0 then { if plat[D6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000020) <> 0 then { if plat[F5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$20000000) <> 0 then { if plat[F4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00200000) <> 0 then { if plat[F3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00002000) <> 0 then { if plat[F2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000020) <> 0 then { if plat[F1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00002000) <> 0 then { if plat[F2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00200000) <> 0 then { if plat[F3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$20000000) <> 0 then { if plat[F4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000020) <> 0 then { if plat[F5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        87 :    { G8 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$20000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00200000) <> 0 then { if plat[F7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00001000) <> 0 then { if plat[E6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000008) <> 0 then { if plat[D5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$04000000) <> 0 then { if plat[C4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00020000) <> 0 then { if plat[B3] = adversaire then }
                              begin
                                if BAnd(my_bits_low,$00000100) <> 0 then { if plat[A2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00020000) <> 0 then { if plat[B3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$04000000) <> 0 then { if plat[C4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000008) <> 0 then { if plat[D5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00001000) <> 0 then { if plat[E6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00004000) <> 0 then { if plat[G6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000040) <> 0 then { if plat[G5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$40000000) <> 0 then { if plat[G4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00400000) <> 0 then { if plat[G3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00004000) <> 0 then { if plat[G2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000040) <> 0 then { if plat[G1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00004000) <> 0 then { if plat[G2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00400000) <> 0 then { if plat[G3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$40000000) <> 0 then { if plat[G4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000040) <> 0 then { if plat[G5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00004000) <> 0 then { if plat[G6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
        88 :    { H8 }
          begin
            if BAnd(BSr(opp_bits_high,1)+my_bits_high,BAnd(opp_bits_high,$40000000)) <> 0 then goto LeCoupEstLegal;
            if BAnd(opp_bits_high,$00400000) <> 0 then { if plat[G7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00002000) <> 0 then { if plat[F6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000010) <> 0 then { if plat[E5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$08000000) <> 0 then { if plat[D4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00040000) <> 0 then { if plat[C3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00000200) <> 0 then { if plat[B2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000001) <> 0 then { if plat[A1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00000200) <> 0 then { if plat[B2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00040000) <> 0 then { if plat[C3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$08000000) <> 0 then { if plat[D4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000010) <> 0 then { if plat[E5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00002000) <> 0 then { if plat[F6] = couleur then }
                  goto LeCoupEstLegal
              end;
            if BAnd(opp_bits_high,$00800000) <> 0 then { if plat[H7] = adversaire then }
              begin
                if BAnd(opp_bits_high,$00008000) <> 0 then { if plat[H6] = adversaire then }
                  begin
                    if BAnd(opp_bits_high,$00000080) <> 0 then { if plat[H5] = adversaire then }
                      begin
                        if BAnd(opp_bits_low,$80000000) <> 0 then { if plat[H4] = adversaire then }
                          begin
                            if BAnd(opp_bits_low,$00800000) <> 0 then { if plat[H3] = adversaire then }
                              begin
                                if BAnd(opp_bits_low,$00008000) <> 0 then { if plat[H2] = adversaire then }
                                  begin
                                    if BAnd(my_bits_low,$00000080) <> 0 then { if plat[H1] = couleur then }
                                      goto LeCoupEstLegal
                                  end
                                else
                                if BAnd(my_bits_low,$00008000) <> 0 then { if plat[H2] = couleur then }
                                  goto LeCoupEstLegal
                              end
                            else
                            if BAnd(my_bits_low,$00800000) <> 0 then { if plat[H3] = couleur then }
                              goto LeCoupEstLegal
                          end
                        else
                        if BAnd(my_bits_low,$80000000) <> 0 then { if plat[H4] = couleur then }
                          goto LeCoupEstLegal
                      end
                    else
                    if BAnd(my_bits_high,$00000080) <> 0 then { if plat[H5] = couleur then }
                      goto LeCoupEstLegal
                  end
                else
                if BAnd(my_bits_high,$00008000) <> 0 then { if plat[H6] = couleur then }
                  goto LeCoupEstLegal
              end;
            goto LeCoupEstIllegal;
          end;
     end; {case}
  end; {with}

  LeCoupEstIllegal :
    begin
      PeutJouerIciBitboard := false;
      exit(PeutJouerIciBitboard);
    end;
  LeCoupEstLegal :
      PeutJouerIciBitboard := true;
end; {PeutJouerIciBitboard}



END.
