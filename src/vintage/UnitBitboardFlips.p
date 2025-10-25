UNIT UnitBitboardFlips;


INTERFACE







 USES UnitDefCassio;







{la meilleure fonction}
function TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var listeCoupsLegaux : listeVides; coupAMettreEnTete : SInt32; listeBitboard : UInt32) : SInt32;


{fonction de generation de transformation de la liste bitboard en liste des cases vides}
function GenererListeDesCasesVidesFromListeBitboard(var listeCoupsLegaux : listeVides; coupAMettreEnTete : SInt32; listeBitboard : UInt32) : SInt32;






IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, UnitBitboardModifPlat, UnitBitboardPeutJouerIci, UnitBitboardStabilite, UnitBitboardHash, UnitScannerUtils, UnitUtilitairesFinale, SNEvents
     ;
{$ELSEC}
    {$I prelink/BitboardFlips.lk}
{$ENDC}


{END_USE_CLAUSE}









{$ifc defined __GPC__}
    {$I CountLeadingZerosForGNUPascal.inc}
{$endc}




{ TrierFastestFirstBitboardStabilite : tri des coups legaux en bitboard.

  On utilise :
     * le fastest-first
     * la stabilite (coins + cases C adjacentes)

  On renvoie le nombre de coups legaux pour la couleur qui a le trait.
 }

function TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var listeCoupsLegaux : listeVides; coupAMettreEnTete : SInt32; listeBitboard : UInt32) : SInt32;
var i, j : SInt32;
    position : bitboard;
    nbCoups,mobAdverse,valTest : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,coupTest,bitCaseVide,leadingZeros);
    diffBidon : SInt32;
    my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    stabilite_amie : SInt32;
    coups_legaux_lo,coups_legaux_hi : UInt32;
    constante1,constante2,constante3,constante4,constante5 : UInt32;
    result_lo,result_hi : UInt32;
    listePourLeTri : listeVidesAvecValeur;
    opp_inner_bits_hi    : UInt32;
    opp_inner_bits_lo    : UInt32;
    flip_bits_hi         : UInt32;
    flip_bits_lo         : UInt32;
    adjacent_opp_bits_hi : UInt32;
    adjacent_opp_bits_lo : UInt32;
begin

   {$IFC DEBUG_BITBOARD_ALPHA_BETA}
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans TrierFastestFirstBitboardStabilite :');
   {$ENDC}

	 diffBidon := 0;
	 nbCoups := 0;

	 (*
	 EcritBitboardDansRapport('position = ',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high));
	 *)

	 REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


		  GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,coupTest,leadingZeros);

		     if ModifPlatPlausible(coupTest,pos_opp_bits_low,pos_opp_bits_high) and
		       (ModifPlatBitboard(coupTest,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon) <> 0)
		       then
		         begin

		            nbCoups := nbCoups + 1;

	              {
	              with position do
	                mobAdverse := CalculeMobiliteBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high);
	              inline !
	              }

	             { Si coupTest est le coup a mettre en tete, on force artificiellement
		             la mobilite adverse a -10000 pour ce coup : cela tendra a le mettre en tete
		             dans le tri fastest first. Sinon, on calcule normalement la mobilite de
		             l'adversaire }


	             if (coupTest = coupAMettreEnTete)
	               then
	                 begin
	                   mobAdverse := -10000;
	                 end
	               else
	                 begin

	                    (* on met le bitboard dans les registres *)

      	              with position do
      									begin
      							      my_bits_low   := g_my_bits_low   ;
      							      my_bits_high  := g_my_bits_high  ;
      							      opp_bits_low  := g_opp_bits_low  ;
      							      opp_bits_high := g_opp_bits_high ;
      							    end;


      	              (* calculons maintenant la mobilite de l'adversaire *)

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

      							  {finalement, une case doit etre vide pour etre un coup legal}

      							  coups_legaux_lo := coups_legaux_lo and not(my_bits_low or opp_bits_low);
      							  coups_legaux_hi := coups_legaux_hi and not(my_bits_high or opp_bits_high);

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
      							      result_lo := (result_lo + (result_lo shr 8));
      							      result_lo := (result_lo + (result_lo shr 16)) and constante5;


      							      { On calcule le nombre de coins que l'adversaire peut prendre.
      							        Ceci permet de donner un malus dans le tri pour les sacrifices de coins. }

      							      result_lo := result_lo +  (coups_legaux_lo and $00000001);         { sacrifice de A1 ?}
      							      result_lo := result_lo + ((coups_legaux_lo shr 7) and $00000001);  { sacrifice de H1 ?}

      								  end
      								  else result_lo := 0;

      							  if (coups_legaux_hi <> 0) then
      							    begin

      							      result_hi := ((coups_legaux_hi shr 1) and constante2) + (coups_legaux_hi and constante2);
      							      result_hi := ((result_hi shr 2) and constante3)  + (result_hi and constante3);
      							      result_hi := (result_hi + (result_hi shr 4)) and constante4;
      							      result_hi := (result_hi + (result_hi shr 8));
      							      result_hi := (result_hi + (result_hi shr 16)) and constante5;

      							      { On calcule le nombre de coins que l'adversaire peut prendre.
      							        Ceci permet de donner un malus dans le tri pour les sacrifices de coins. }

      							      result_hi := result_hi + ((coups_legaux_hi shr 31) and $00000001);  { sacrifice de H8 ?}
      							      result_hi := result_hi + ((coups_legaux_hi shr 24) and $00000001);  { sacrifice de A8 ?}

      							    end
      							    else result_hi := 0;


      								(* on gagne un registre en indiquant au compilateur que l'on n'utilisera plus result_hi *)

      								result_lo := result_lo + result_hi;



      								(* calculons une mesure de stabilite de nos pions apres notre coup,
	                       sur les coins et les cases C  *)

	                    stabilite_amie := 0;

	                    if (opp_bits_low and $00000001) <> 0 then   { A1? }
	                      begin
	                        stabilite_amie := stabilite_amie + 1;
	                        stabilite_amie := stabilite_amie + ((opp_bits_low shr 1) and $00000001);   { B1? }
      							      stabilite_amie := stabilite_amie + ((opp_bits_low shr 8) and $00000001);   { A2? }
	                      end;

	                    if (opp_bits_low and $00000080) <> 0 then   { H1? }
	                      begin
	                        stabilite_amie := stabilite_amie + 1;
	                        stabilite_amie := stabilite_amie + ((opp_bits_low shr 6) and $00000001);    { G1? }
      							      stabilite_amie := stabilite_amie + ((opp_bits_low shr 15) and $00000001);   { H2? }
	                      end;

	                    if (opp_bits_high and $01000000) <> 0 then   { A8? }
	                      begin
	                        stabilite_amie := stabilite_amie + 1;
	                        stabilite_amie := stabilite_amie + ((opp_bits_high shr 25) and $00000001);   { B8? }
      							      stabilite_amie := stabilite_amie + ((opp_bits_high shr 16) and $00000001);   { A7? }
	                      end;

	                    if (opp_bits_high and $80000000) <> 0 then   { H8? }
	                      begin
	                        stabilite_amie := stabilite_amie + 1;
	                        stabilite_amie := stabilite_amie + ((opp_bits_high shr 30) and $00000001);   { G8? }
      							      stabilite_amie := stabilite_amie + ((opp_bits_high shr 23) and $00000001);   { H7? }
	                      end;


      								mobAdverse :=  (4 * result_lo)  -  stabilite_amie;


		               end;

		           with listePourLeTri[nbCoups] do
		             begin
		               coup := coupTest;
		               theVal := mobAdverse;
		             end;

		     end;

		UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);


	 {$IFC DEBUG_TRI_FASTEST_BITBOARD }
	 WritelnDansRapport('Avant le tri dans TrierFastestFirstBitboardStabilite : ');
	 EcritBitboardDansRapport('position = ',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high));
	 for i := 1 to nbCoups do
     WritelnNumDansRapport(CoupEnStringEnMajuscules(listePourLeTri[i].coup)+' => ',listePourLeTri[i].theVal);
   AttendFrappeClavier;
	 {$ENDC}


	 (* sentinelle *)
	 listePourLeTri[nbCoups + 1].theVal := 1000000;  { +infini }

	 (* trier par insertion la liste *)

	 for i := nbCoups - 1 downto 1 do
     begin

       with listePourLeTri[i] do
         begin
           coupTest := coup;
           valTest  := theVal;
         end;

       j := i + 1;
       while valTest > listePourLeTri[j].theVal do
         begin
           listePourLeTri[j - 1] := listePourLeTri[j];
           j := j + 1;
         end;

       with listePourLeTri[j - 1] do
         begin
           coup   := coupTest;
           theVal := valTest;
         end;

     end;

   (* recopier la liste *)

   for i := 1 to nbCoups do
     listeCoupsLegaux[i] := listePourLeTri[i].coup;


	 {$IFC (DEBUG_BITBOARD_ALPHA_BETA OR DEBUG_TRI_FASTEST_BITBOARD) }
	 WritelnDansRapport('Apres le tri dans TrierFastestFirstBitboardStabilite : ');
	 for i := 1 to nbCoups do
     WritelnNumDansRapport(CoupEnStringEnMajuscules(listePourLeTri[i].coup)+' => ',listePourLeTri[i].theVal);
	 WritelnNumDansRapport('donc  nbCoupsLegaux = ',nbCoups);
	 WritelnDansRapport('sortie de TrierFastestFirstBitboardStabilite.');
   WritelnDansRapport('');
   AttendFrappeClavier;
	 {$ENDC}

	 TrierFastestFirstBitboardStabilite := nbCoups;
end;



function GenererListeDesCasesVidesFromListeBitboard(var listeCoupsLegaux : listeVides; coupAMettreEnTete : SInt32; listeBitboard : UInt32) : SInt32;
var nbCoups : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,coupTest,bitCaseVide,leadingZeros);
begin

   {$IFC DEBUG_BITBOARD_ALPHA_BETA}
   WritelnDansRapport('');
   WritelnDansRapport('Entrée dans GenererListeDesCasesVidesFromListeBitboard :');
   {$ENDC}

	 nbCoups := 1;
	 listeCoupsLegaux[1] := 0;


	 REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


		  GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,coupTest,leadingZeros);

		  if (coupTest = coupAMettreEnTete)
		    then
		      listeCoupsLegaux[1] := coupTest
		    else
		      begin
		        inc(nbCoups);
		        listeCoupsLegaux[nbCoups] := coupTest;
		      end;


		UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);



	 GenererListeDesCasesVidesFromListeBitboard := nbCoups;
end;




END.











































