UNIT UnitBitboardAlphaBeta;


INTERFACE











 USES UnitDefCassio, UnitDefParallelisme;




function LanceurBitboardAlphaBeta(var plat : plOthEndgame; couleur,ESprof,alpha,beta,diffPions,numFirtSonToParallelize : SInt32) : SInt32;                                          ATTRIBUTE_NAME('LanceurBitboardAlphaBeta')
function PeutFaireFinaleBitboardCettePosition(var plat : plateauOthello; couleur,alphaMilieu,betaMilieu,nbNoirs,nbBlancs : SInt32; var note : SInt32) : boolean;                    ATTRIBUTE_NAME('PeutFaireFinaleBitboardCettePosition')


function ABFinBitboardQuatreCasesVides(var position : bitboard; alpha_4,beta_4,diffPions_4,vecteurParite_4 : SInt32; listeBitboard : UInt32{; debugageUnrolled : boolean}) : SInt32;                                                                                          ATTRIBUTE_NAME('ABFinBitboardQuatreCasesVides')
function ABFinBitboardPariteSansStabilite(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32) : SInt32;                            ATTRIBUTE_NAME('ABFinBitboardPariteSansStabilite')
function ABFinBitboardParite(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32) : SInt32;                                         ATTRIBUTE_NAME('ABFinBitboardParite')
function ABFinBitboardPariteHachage(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;  ATTRIBUTE_NAME('ABFinBitboardPariteHachage')
function ABFinBitboardFastestFirst(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;                                                                         ATTRIBUTE_NAME('ABFinBitboardFastestFirst')
function ABFinBitboardFastestFirstKnuth(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite,typeKnuth : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;                                                          ATTRIBUTE_NAME('ABFinBitboardFastestFirstKnuth')
function ABFinBitboardFastestFirstAvecETC(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;                                                                  ATTRIBUTE_NAME('ABFinBitboardFastestFirstAvecETC')
function ABFinBitboardParallele(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite,numFirtSonToParallelize : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;                                                    ATTRIBUTE_NAME('ABFinBitboardParallele')



// function QuatreCasesVidesBitboardFast(var position : bitboard; alpha_4,beta_4,diffPions_4,vecteurParite_4 : SInt32; listeBitboard : UInt32{; debugageUnrolled : boolean}) : SInt32;
function solve_four_empty( my_bits, opp_bits : demi_bitboard; sq1, sq2, sq3, sq4, alpha, beta, disc_diff, pass_legal : SInt32) : SInt32;                                            EXTERNAL_NAME('solve_four_empty');






{$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
procedure ResetStatistiquesOrdreOptimumDesCases;                                                                                                                                    ATTRIBUTE_NAME('ResetStatistiquesOrdreOptimumDesCases')
procedure EcritStatistiquesOrdreOptimumDesCasesDansRapport;                                                                                                                         ATTRIBUTE_NAME('EcritStatistiquesOrdreOptimumDesCasesDansRapport')
{$ENDC}

{$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
procedure ResetStatistiquesStatutKnuthDesNoeuds;                                                                                                                                    ATTRIBUTE_NAME('ResetStatistiquesStatutKnuthDesNoeuds')
procedure EcritStatistiquesStatutKnuthDesNoeudsDansRapport;                                                                                                                         ATTRIBUTE_NAME('EcritStatistiquesStatutKnuthDesNoeudsDansRapport')
{$ENDC}


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSAtomic_glue, Sound, Timer
{$IFC NOT(USE_PRELINK)}
    , UnitMiniProfiler, UnitRapport, UnitBitboardQuatreSimple, MyStrings, UnitBitboardUtils
    , UnitBitboardDernierCoup, UnitBitboardModifPlat, UnitBitboardDeuxCasesVides, UnitConstrListeBitboard, UnitBitboardFlips, UnitBitboardStabilite, UnitBitboardQuatreCases, UnitBitboardMobilite
    , UnitParallelisme, SNEvents, UnitBitboardHash, UnitListeChaineeCasesVides ;
{$ELSEC}
    ;
    {$I prelink/BitboardAlphaBeta.lk}
{$ENDC}


{END_USE_CLAUSE}









const
      STATUT_KNUTH_INCONNU   = 0;
      ALPHA_COUPURE_PROBABLE = 1;
      BETA_COUPURE_PROBABLE  = 2;




{$ifc defined __GPC__}
    {$I CountLeadingZerosForGNUPascal.inc}
{$endc}




  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}

  var gOrdreOptimum : record
                        nombre_statistiques : SInt32;
                        meilleur_coup_dans_cette_case : plOthLongint;
                        ce_coup_est_legal : plOthLongint;
                      end;

  {$ENDC}


  {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}

  var gStatutsKnuth : array[0..64] of
                        record
                          nombre_statistiques        : SInt32;
                          nombre_coupures_beta       : SInt32;
                          index_coupure_beta         : array[0..64] of SInt32;
                          nombre_coupures_alpha      : SInt32;
                          estimations_coupures_beta  : SInt32;
                          estimations_coupures_alpha : SInt32;
                          coupures_beta_anticipees   : SInt32;
                          coupures_alpha_anticipees  : SInt32;
                        end;

  {$ENDC}


	{$IFC UTILISE_MINIPROFILER_POUR_MILIEU OR UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
	var microSecondesCurrentBitboard : array[0..64] of UnsignedWide;
    	microSecondesDepartBitboard : array[0..64] of UnsignedWide;

	procedure BeginMiniprofilerBitboard(nroDuCoup : SInt32);
  	begin
    	Microseconds(microSecondesDepartBitboard[nroDuCoup]);
		end;

	procedure EndMiniprofilerBitboard(nroDuCoup : SInt32);
  	begin
    	Microseconds(microSecondesCurrentBitboard[nroDuCoup]);
	  	AjouterTempsDansMiniProfiler(nroDuCoup,-1,microSecondesCurrentBitboard[nroDuCoup].lo-microSecondesDepartBitboard[nroDuCoup].lo,ktempsMoyen+kpourcentage);
		end;

	{$ENDC}




{$IFC NOT(USING_DEUXCASESVIDESBITBOARDFAST) }

blah

{ DeuxCasesVidesBitboard pour quand il reste deux cases vides.
  Attention : position est modifiee par cette routine !
  Remarque : DeuxCasesVidesBitboardFast est nettement plus rapide }
function DeuxCasesVidesBitboard(var position : bitboard; alpha,beta,diffPionsDeuxCasesVides : SInt32; vientDePasser : boolean; listeBitboard : UInt32) : SInt32;
var my_bits_low,my_bits_high,opp_bits_low,opp_bits_high : UInt32;
    diffPions : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    iCourant1,iCourant2 : SInt32;
begin

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME) }
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  maxPourBestDefABFinPetite := -noteMax;
  with position do
   begin
     my_bits_low   := g_my_bits_low;
     my_bits_high  := g_my_bits_high;
     opp_bits_low  := g_opp_bits_low;
     opp_bits_high := g_opp_bits_high;
   end;
  diffPions := diffPionsDeuxCasesVides;

  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans DeuxCasesVidesBitboard :',position,2,alpha,beta,diffPionsDeuxCasesVides);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,2);
  AttendFrappeClavier;
  {$ENDC}


  GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE(listeBitboard,iCourant1,iCourant2);


  if ModifPlatPlausible(iCourant1,opp_bits_low,opp_bits_high) &
     (ModifPlatBitboard(iCourant1,0,my_bits_low,my_bits_high,opp_bits_low,opp_bits_high,position,diffPions) <> 0) then
    BEGIN
      with position do
        noteCourante := DernierCoupBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,diffPions,iCourant2);

      maxPourBestDefABFinPetite := noteCourante;
      if (noteCourante > alpha) then
        begin
          if (noteCourante >= beta) then
            begin
              DeuxCasesVidesBitboard := noteCourante;
              exit(DeuxCasesVidesBitboard);
            end;
          alpha := noteCourante;
        end;
      diffPions := diffPionsDeuxCasesVides;
    END;

  if ModifPlatPlausible(iCourant2,opp_bits_low,opp_bits_high) &
     (ModifPlatBitboard(iCourant2,0,my_bits_low,my_bits_high,opp_bits_low,opp_bits_high,position,diffPions) <> 0) then
    BEGIN
      with position do
        noteCourante := DernierCoupBitboard(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,diffPions,iCourant1);

		  if noteCourante > maxPourBestDefABFinPetite then
		    begin
		      maxPourBestDefABFinPetite := noteCourante;
		      if (noteCourante > alpha) then
		        begin
		          if (noteCourante >= beta) then
		            begin
		              DeuxCasesVidesBitboard := noteCourante;
		              exit(DeuxCasesVidesBitboard);
		            end;
		          alpha := noteCourante;
		        end;
		   end;
    END;


{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       DeuxCasesVidesBitboard := maxPourBestDefABFinPetite;
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPionsDeuxCasesVides > 0 then
             begin
               DeuxCasesVidesBitboard := diffPionsDeuxCasesVides + 2;
               exit(DeuxCasesVidesBitboard);
             end;
           if diffPionsDeuxCasesVides < 0 then
             begin
               DeuxCasesVidesBitboard := diffPionsDeuxCasesVides - 2;
               exit(DeuxCasesVidesBitboard);
             end;
           DeuxCasesVidesBitboard := 0;
           exit(DeuxCasesVidesBitboard);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := opp_bits_high;
               g_opp_bits_high := my_bits_high;
               g_my_bits_low   := opp_bits_low;
               g_opp_bits_low  := my_bits_low;
             end;
           DeuxCasesVidesBitboard := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffPionsDeuxCasesVides,true);
         end;
     end;
end;   { DeuxCasesVidesBitboard }

{$ENDC}




{ ABFinBitboardQuatreCasesVides : pour quand il reste quatre cases vides.
  Attention : position est modifiee par cette routine ! }
function ABFinBitboardQuatreCasesVides(var position : bitboard; alpha_4,beta_4,diffPions_4,vecteurParite_4 : SInt32; listeBitboard : UInt32{; debugageUnrolled : boolean}) : SInt32;
var neVientPasDePasser : SInt32;
    temp : SInt32;

var { variables pour la prof 4 }
    pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4 : UInt32;
    diffEssai_4 : SInt32;
    notecourante_4,maxPourBestDefABFinPetite_4 : SInt32;
    pairesImpaires_4 : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur_4,iCourant_4,bitCaseVide_4,leadingZeros_4);

var { variables pour la prof 3 }
    listeBitboard_3 : UInt32;
    alpha_3,beta_3 : SInt32;
    pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3 : UInt32;
    diffPions_3,diffEssai_3 : SInt32;
    maxPourBestDefABFinPetite_3 : SInt32;
    vecteurParite_3,pairesImpaires_3 : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur_3,iCourant_3,bitCaseVide_3,leadingZeros_3);
    {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}

label { labels pour la prof 4 }
      testerCetteParite_prof_4,debut_prof_4,fin_prof_4;



label { labels pour la prof 3 }
      testerCetteParite_prof_3,debut_prof_3,fin_prof_3;



begin

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}


  with position do
    begin
      pos_my_bits_low_4   := g_my_bits_low;
      pos_my_bits_high_4  := g_my_bits_high;
      pos_opp_bits_low_4  := g_opp_bits_low;
      pos_opp_bits_high_4 := g_opp_bits_high;
    end;

  if (alpha_4 >= 50) |
     ((alpha_4 >= 0) & (diffPions_4 <= alpha_4 - 24)) then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante_4 := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low_4,pos_opp_bits_high_4,pos_my_bits_low_4,pos_my_bits_high_4, BSr(65-alpha_4,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante_4 <= alpha_4 then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardQuatreCasesVides :',MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),4,alpha_4,beta_4,diffPions_4);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low_4,pos_opp_bits_high_4,pos_my_bits_low_4,pos_my_bits_high_4, BSr(65-alpha_4,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardQuatreCasesVides := noteCourante_4;
          exit(ABFinBitboardQuatreCasesVides);
        end;
    end;
  if (beta_4 <= -50) |
     ((beta_4 <= 0) & (diffPions_4 >= beta_4 + 24)) then
    begin
      { Calculons la note minimale que l'on peut obtenir,
        connaissant nos pions definitifs }
      noteCourante_4 := -64 + 2*CalculePionsStablesBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4, BSr(65+beta_4,1));
      { noteCourante = la note minimale que l'on peut esperer obtenir}
      if noteCourante_4 >= beta_4 then { coupure beta !... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardQuatreCasesVides :',MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),4,alpha_4,beta_4,diffPions_4);
          WritelnNumDansRapport('pions stables amis = ',CalculePionsStablesBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4, BSr(65+beta_4,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardQuatreCasesVides := noteCourante_4;
          exit(ABFinBitboardQuatreCasesVides);
        end;
    end;






  neVientPasDePasser := (neVientPasDePasser OR $00000010);   { bit set 4    : a priori on passe pas à prof 4}
  neVientPasDePasser := (neVientPasDePasser AND $FFFFBFFF);  { bit clear 14 : on ne sait pas encore si on va jouer à prof 4}
  maxPourBestDefABFinPetite_4 := -noteMax;

debut_prof_4:

  diffEssai_4 := diffPions_4;

  {$IFC AVEC_DEBUG_UNROLLED}
  if debugageUnrolled then
    begin
		  EcritBitboardState('label debut_prof_4 dans ABFinBitboardQuatreCasesVides :',
		                      MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
		                      4,alpha_4,beta_4,diffPions_4);
		  if (4 >= 3) then
		    begin
		      WritelnStringAndBooleanDansRapport('vient de passer = ',not(((neVientPasDePasser AND $00000010) <> 0)));
				  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite_4,constanteDeParite[11]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite_4,constanteDeParite[18]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite_4,constanteDeParite[81]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite_4,constanteDeParite[88]) = 0);
				end;
		  AttendFrappeClavier;
		end;
  {$ENDC}





 if (BAnd(vecteurParite_4,15) <> 0)
   then pairesImpaires_4 := vecteurParite_4        {s'il y a des coups impairs, on teste d'abord les coups impairs}
   else pairesImpaires_4 := not(vecteurParite_4);  {sinon, on commence directement tous les coups pairs}



 testerCetteParite_prof_4 :

  REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur_4);

     GET_NEXT_CASE_VIDE(iterateur_4,bitCaseVide_4,iCourant_4,leadingZeros_4);

        if COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros_4,pairesImpaires_4) then
	        begin
	          {$IFC AVEC_DEBUG_UNROLLED}
	          if debugageUnrolled then
	            begin
			          EcritBitboardState('dans ABFinBitboardQuatreCasesVides :',
			                              MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
			                              4,alpha_4,beta_4,diffPions_4);
			          WritelnDansRapport('pairesImpaires_4 = '+Hexa(pairesImpaires_4));
			          if BAnd(pairesImpaires_4,$00008000) = 0
			            then WritelnStringAndCoupDansRapport('coup impair : ',iCourant_4)
			            else WritelnStringAndCoupDansRapport('coup pair : ',iCourant_4);
			          WritelnDansRapport('');
			          AttendFrappeClavier;
	            end;
	          {$ENDC}

	          if ModifPlatPlausible(iCourant_4,pos_opp_bits_low_4,pos_opp_bits_high_4)
	            then vecteurParite_3 := ModifPlatBitboard(iCourant_4,vecteurParite_4, pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4,position,diffEssai_4)
	            else vecteurParite_3 := vecteurParite_4;

	          if (vecteurParite_3 <> vecteurParite_4) then
		          BEGIN


			          neVientPasDePasser := (neVientPasDePasser OR $00004000);  { bit set 14 : on a joue a profondeur 4 }

			          listeBitboard_3 := REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide_4);


		            (*

			          if (profMoins1 = 2)
			            then
			              begin
			                {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
			                with position do
			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,
			                                                              -beta_4,-alpha_4,-diffEssai_4,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide_4));
			                {$ELSEC}
			                noteCourante := -DeuxCasesVidesBitboard(position,-beta_4,-alpha_4,-diffEssai_4,false);
			                {$ENDC}
			              end
			            else
			              noteCourante := -ABFinBitboardQuatreCasesVides(position,profMoins1,-beta_4,-alpha_4,-diffEssai_4,nouvelleParite,debugageUnrolled);

			          *)

	(****************************************************************************)
	(******************* appel recursif à prof 3  *******************************)
  (****************************************************************************)

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}


  alpha_3 := -beta_4;
  beta_3 := -alpha_4;
  diffPions_3 := -diffEssai_4;

  with position do
    begin
      pos_my_bits_low_3   := g_my_bits_low;
      pos_my_bits_high_3  := g_my_bits_high;
      pos_opp_bits_low_3  := g_opp_bits_low;
      pos_opp_bits_high_3 := g_opp_bits_high;
    end;
  neVientPasDePasser := (neVientPasDePasser OR $00000008);   { bit set 3    : a priori on ne passe pas à prof 3}
  neVientPasDePasser := (neVientPasDePasser AND $FFFFDFFF);  { bit clear 13 : on ne sait pas encore si on va jouer à prof 3}
  maxPourBestDefABFinPetite_3 := -noteMax;

debut_prof_3:

  diffEssai_3 := diffPions_3;

  {$IFC AVEC_DEBUG_UNROLLED}
  if debugageUnrolled then
    begin
		  EcritBitboardState('label debut_prof_3 dans ABFinBitboardQuatreCasesVides_3 :',
		                      MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
		                      3,alpha_3,beta_3,diffEssai_3);
		  if (3 >= 3) then
		    begin
		      WritelnStringAndBooleanDansRapport('vient de passer = ',not(((neVientPasDePasser AND $00000008) <> 0)));
				  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite_3,constanteDeParite[11]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite_3,constanteDeParite[18]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite_3,constanteDeParite[81]) = 0);
				  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite_3,constanteDeParite[88]) = 0);
				end;
		  AttendFrappeClavier;
		end;
  {$ENDC}

 pairesImpaires_3 := vecteurParite_3;  {d'abord les coups impairs}

 testerCetteParite_prof_3 :

  REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard_3,iterateur_3);

     GET_NEXT_CASE_VIDE(iterateur_3,bitCaseVide_3,iCourant_3,leadingZeros_3);

        if COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros_3,pairesImpaires_3) then
	        begin
	          {$IFC AVEC_DEBUG_UNROLLED}
	          if debugageUnrolled then
	            begin
			          EcritBitboardState('dans ABFinBitboardQuatreCasesVides_3 :',
			                              MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
			                              3,alpha_3,beta_3,diffEssai_3);
			          WritelnDansRapport('pairesImpaires_3 = '+Hexa(pairesImpaires_3));
			          if BAnd(pairesImpaires_3,$00008000) = 0
			            then WritelnStringAndCoupDansRapport('coup impair : ',iCourant_3)
			            else WritelnStringAndCoupDansRapport('coup pair : ',iCourant_3);
			          WritelnDansRapport('');
			          AttendFrappeClavier;
	            end;
	          {$ENDC}

	           if ModifPlatPlausible(iCourant_3,pos_opp_bits_low_3,pos_opp_bits_high_3) &
                (ModifPlatBitboard(iCourant_3,0,pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3,position,diffEssai_3) <> 0)
              then

		          BEGIN

		            neVientPasDePasser := (neVientPasDePasser OR $00002000);  { bit set 13 : on a joue a profondeur 3 }



		            {$IFC USING_DEUXCASESVIDESBITBOARDFAST}

                with position do
                  temp := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,
                                                              -beta_3,-alpha_3,-diffEssai_3,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard_3,bitCaseVide_3));

                {$ELSEC}

                temp := -DeuxCasesVidesBitboard(position,-beta_3,-alpha_3,-diffEssai_3,false);

                {$ENDC}






							 	if temp > maxPourBestDefABFinPetite_3 then
							 	  begin
		                if temp > alpha_3 then
		                  begin
		                    if temp >= beta_3 then
		                      begin
		                        if ((neVientPasDePasser AND $00000008) <> 0)  { bit test 3 : est-ce un coup normal à prof 3… ? }
										          then
										            begin
										              noteCourante_4 := -temp;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnNumDansRapport('beta-coupure à prof 3, soit ',-temp);
										              {$ENDC}
										            end
										          else                                         { …ou le resultat d'un passe a profondeur 3 ? }
										            begin
										              noteCourante_4 := temp;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnNumDansRapport('- beta-coupure à prof 3, soit ',temp);
										              {$ENDC}
										            end;
		                        goto fin_prof_3;
		                      end;
		                    alpha_3 := temp;
		                  end; { if temp > alpha_3 }
                    maxPourBestDefABFinPetite_3 := temp;
                  end; { if temp > maxPourBestDefABFinPetite_3 }

			          diffEssai_3 := diffPions_3;
	            END;
	        end;

	UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur_3);


  if BAnd(pairesImpaires_3,$00008000) = 0 then
    begin
      pairesImpaires_3 := not(vecteurParite_3);   {puis les coups pairs}
      goto testerCetteParite_prof_3;
    end;



{fin:}
 if ((neVientPasDePasser AND $00002000) <> 0) { bit test 13 : a-t-on joue à prof 3 ?}
   then
     begin
       if ((neVientPasDePasser AND $00000008) <> 0) { bit test 3 : est-ce un coup normal à prof 3… ? }
         then
           begin
             noteCourante_4 := -maxPourBestDefABFinPetite_3;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnNumDansRapport('on renvoie -maxPourBestDefABFinPetite_3, soit ',-maxPourBestDefABFinPetite_3);
						 {$ENDC}
					 end
         else                        { …ou le resultat d'un passe à prof 3 ? }
           begin
             noteCourante_4 := maxPourBestDefABFinPetite_3;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnNumDansRapport('on renvoie maxPourBestDefABFinPetite_3, soit ',maxPourBestDefABFinPetite_3);
						 {$ENDC}
					 end;
       goto fin_prof_3;
     end
   else
     begin
      if ((neVientPasDePasser AND $00000008) <> 0)   { si l'adversaire ne vient pas de passer a profondeur 3… }
       then
         begin
           { passe! }

           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               WritelnDansRapport('passe !');
               AttendFrappeClavier;
             end;
           {$ENDC}

           neVientPasDePasser := (neVientPasDePasser AND $FFFFFFF7);

           temp                := pos_opp_bits_high_3;
           pos_opp_bits_high_3 := pos_my_bits_high_3;
           pos_my_bits_high_3  := temp;
           temp                := pos_opp_bits_low_3;
           pos_opp_bits_low_3  := pos_my_bits_low_3;
           pos_my_bits_low_3   := temp;

           temp    := -alpha_3;
           alpha_3 := -beta_3;
           beta_3  := temp;
           diffPions_3 := -diffPions_3;

           goto debut_prof_3;
         end
       else
         begin
           { terminé! }

           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               EcritBitboardState('position à trois cases vides :',
			                              MakeBitboard(pos_my_bits_low_3,pos_my_bits_high_3,pos_opp_bits_low_3,pos_opp_bits_high_3),
			                              3,alpha_3,beta_3,diffEssai_3);
		           WritelnDansRapport('terminé : il reste 3 cases vides !!');
		           AttendFrappeClavier;
		         end;
		       {$ENDC}

           if diffPions_3 > 0 then
             begin
               noteCourante_4 := (diffPions_3 + 3);
               goto fin_prof_3;
             end;
           if diffPions_3 < 0 then
             begin
               noteCourante_4 := (diffPions_3 - 3) ;
               goto fin_prof_3;
             end;
           noteCourante_4 := 0;
           goto fin_prof_3;
         end;
     end;


   fin_prof_3 :

	(****************************************************************************)
	(******************* fin de l'appel recursif à prof 3  **********************)
  (****************************************************************************)




							 	if noteCourante_4 > maxPourBestDefABFinPetite_4 then
							 	  begin
		                if noteCourante_4 > alpha_4 then
		                  begin
		                    if noteCourante_4 >= beta_4 then
		                      begin
		                        if ((neVientPasDePasser AND $00000010) <> 0)
										          then
										            begin
										              ABFinBitboardQuatreCasesVides := noteCourante_4;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnNumDansRapport('beta-coupure à prof 4, soit ',noteCourante_4);
										              {$ENDC}
										            end
										          else
										            begin
										              ABFinBitboardQuatreCasesVides := -noteCourante_4;
										              {$IFC AVEC_DEBUG_UNROLLED}
										              if debugageUnrolled then
										                WritelnNumDansRapport('- beta-coupure à prof 4, soit ',-noteCourante_4);
										              {$ENDC}
										            end;
		                        goto fin_prof_4;
		                      end;
		                    alpha_4 := noteCourante_4;
		                  end; { if noteCourante_4 > alpha_4 }
		                maxPourBestDefABFinPetite_4 := noteCourante_4;
		              end; { if noteCourante_4 > maxPourBestDefABFinPetite_4 }
			          diffEssai_4 := diffPions_4;
	            END;
	        end;

	 UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur_4);


 if BAnd(pairesImpaires_4,$00008000) = 0 then
   begin
     pairesImpaires_4 := not(vecteurParite_4);   {puis les coups pairs}
     goto testerCetteParite_prof_4;
   end;


{fin:}
 if ((neVientPasDePasser AND $00004000) <> 0)  { bit test 14 : a-t-on joue à prof 4 ?}
   then
     begin
       if ((neVientPasDePasser AND $00000010) <> 0)  { bit test 4 : est-ce un coup normal à prof 4… ? }
         then
           begin
             ABFinBitboardQuatreCasesVides := maxPourBestDefABFinPetite_4;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnNumDansRapport('on renvoie maxPourBestDefABFinPetite_4, soit ',maxPourBestDefABFinPetite_4);
						 {$ENDC}
					 end
         else                         { …ou le resultat d'un passe à prof 4 ? }
           begin
             ABFinBitboardQuatreCasesVides := -maxPourBestDefABFinPetite_4;
             {$IFC AVEC_DEBUG_UNROLLED}
             if debugageUnrolled then
							 WritelnNumDansRapport('on renvoie -maxPourBestDefABFinPetite_4, soit ',-maxPourBestDefABFinPetite_4);
						 {$ENDC}
					 end;
       goto fin_prof_4;
     end
   else
     begin
      if ((neVientPasDePasser AND $00000010) <> 0)
       then
         begin
           { passe! }

           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               WritelnDansRapport('passe !');
               AttendFrappeClavier;
             end;
           {$ENDC}

           neVientPasDePasser := (neVientPasDePasser AND $FFFFFFEF);

           temp                := pos_opp_bits_high_4;
           pos_opp_bits_high_4 := pos_my_bits_high_4;
           pos_my_bits_high_4  := temp;
           temp                := pos_opp_bits_low_4;
           pos_opp_bits_low_4  := pos_my_bits_low_4;
           pos_my_bits_low_4   := temp;

           temp    := -alpha_4;
           alpha_4 := -beta_4;
           beta_4  := temp;
           diffPions_4 := -diffPions_4;

           goto debut_prof_4;
         end
       else
         begin
           { terminé! }

           {$IFC AVEC_DEBUG_UNROLLED}
           if debugageUnrolled then
             begin
               EcritBitboardState('position à quatre cases vides :',
			                              MakeBitboard(pos_my_bits_low_4,pos_my_bits_high_4,pos_opp_bits_low_4,pos_opp_bits_high_4),
			                              4,alpha_4,beta_4,diffEssai_4);
		           WritelnDansRapport('terminé : il reste 4 cases vides !!');
		           AttendFrappeClavier;
		         end;
		       {$ENDC}

           if diffPions_4 > 0 then
             begin
               ABFinBitboardQuatreCasesVides := - (diffPions_4 + 4);
               goto fin_prof_4;
             end;
           if diffPions_4 < 0 then
             begin
               ABFinBitboardQuatreCasesVides :=   4 - diffPions_4 ;
               goto fin_prof_4;
             end;
           ABFinBitboardQuatreCasesVides := 0;
           goto fin_prof_4;
         end;
     end;


   fin_prof_4 :

end;   { ABFinBitboardQuatreCasesVides }



{ ABFinBitboardPariteSansStabilite pour les petites profondeurs ( 4 < p <= 7 ).
  On utilise un ordre fixe des cases en jouant la parité.
  Attention : position est modifiee par cette routine ! }

function ABFinBitboardPariteSansStabilite(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32) : SInt32;
var ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    nouvelleParite : SInt32;
    vientDePasser : boolean;
    {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		bestmove : SInt32;
		{$ENDC}
		{$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}
    {
    sauvegardePosition : bitboard;
    autreNoteCourante : SInt32;
    }

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
      bestmove := 0;
    end;
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardPariteSansStabilite :',position,ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}



  if (BAnd(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN

    {impairs:}

       REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


          GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


            if COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros,vecteurParite) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardPariteSansStabilite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}

    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;

    	          if nouvelleParite <> vecteurParite then
    		          BEGIN

    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}


    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}

    			          if (profMoins1 = 4)
    			            then
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}

		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}


		                    	{$IFC AVEC_MESURE_DE_PARALLELISME}
		                    	PointDeMesureDeParallelisme;
		                    	{$ENDC}


		                    	noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
                          {$ELSEC}
                          blah
                          noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                          noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}

		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else
    			              begin
    			                if (profMoins1 = 2)
    			                  then
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
          			                {$ELSEC}
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else noteCourante := -ABFinBitboardPariteSansStabilite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
    			              end;

    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}


    			          if (noteCourante > maxPourBestDefABFinPetite) then
    			            begin
    			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
    			              {$ENDC}
    			              if (noteCourante >= beta) then
    	                    begin
    	                      ABFinBitboardPariteSansStabilite := noteCourante;
    	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    			                  EndMiniprofilerBitboard(ESProf);
    		                   {$ENDC}
    		                    exit(ABFinBitboardPariteSansStabilite);
    	                    end;
    			              if (noteCourante > alpha) then alpha := noteCourante;
    			              maxPourBestDefABFinPetite := noteCourante;
    			            end;

    			          diffEssai := diffPions;
    	            END;
    	        end;

      UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);

    END;

{pairs:}


    REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


      GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


	      if COUP_EST_DANS_UNE_ZONE_PAIRE(leadingZeros,vecteurParite) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardPariteSansStabilite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}


            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;

	          if nouvelleParite <> vecteurParite then
		          BEGIN

		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}


		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}

			          if (profMoins1 = 4)
			            then
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}

			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}

			                {$IFC AVEC_MESURE_DE_PARALLELISME}
		                  PointDeMesureDeParallelisme;
		                  {$ENDC}



                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
                      {$ELSEC}
                      blah
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}

                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else
			              begin
			                if (profMoins1 = 2)
			                  then
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
      			                {$ELSEC}
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else noteCourante := -ABFinBitboardPariteSansStabilite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
			              end;

			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}



							  if (noteCourante > maxPourBestDefABFinPetite) then
			            begin
			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
			              {$ENDC}
			              if (noteCourante >= beta) then
	                    begin
	                      ABFinBitboardPariteSansStabilite := noteCourante;
	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
			                  EndMiniprofilerBitboard(ESProf);
		                   {$ENDC}
		                    exit(ABFinBitboardPariteSansStabilite);
	                    end;
			              if (noteCourante > alpha) then alpha := noteCourante;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;

			          diffEssai := diffPions;
		          END;
		      end;

	 UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);


{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardPariteSansStabilite := maxPourBestDefABFinPetite;
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardPariteSansStabilite := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardPariteSansStabilite);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardPariteSansStabilite := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardPariteSansStabilite);
             end;
           ABFinBitboardPariteSansStabilite := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardPariteSansStabilite);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardPariteSansStabilite := -ABFinBitboardPariteSansStabilite(position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),listeBitboard);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardPariteSansStabilite }



{ ABFinBitboardParite pour les petites profondeurs ( 4 < p <= 17 ).
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) un ordre fixe des cases en jouant la parité.

  Attention : position est modifiee par cette routine !
  Attention : toujours appeler cette routine avec au moins 5 cases vides,
              sinon on boucle. Notez que ABFinBitboardFastestFirst est une
              autre routine plus robuste, qui peut etre utilisee pour
              0 <= p <= profForceBrute }
function ABFinBitboardParite(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    nouvelleParite : SInt32;
    {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		bestmove : SInt32;
		{$ENDC}
		vientDePasser : boolean;
		{$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}
    {
    sauvegardePosition : bitboard;
    autreNoteCourante : SInt32;
    }

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
      bestmove := 0;
    end;
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;

  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardParite := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardParite);
        end;
      if noteCourante < beta then beta := noteCourante;
    end;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardParite :',position,ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}



  if (BAnd(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN

    {impairs:}

      REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


          GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


            if COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros,vecteurParite) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}

    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;

    	          if nouvelleParite <> vecteurParite then
    		          BEGIN


    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}


    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}


    			          if (profMoins1 = 4)
    			            then
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}

		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}


		                    	{$IFC AVEC_MESURE_DE_PARALLELISME}
		                    	PointDeMesureDeParallelisme;
		                    	{$ENDC}

		                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
                          {$ELSEC}
                          blah
                          noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                          noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}

		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else
    			              begin
    			                if (profMoins1 = 2)
    			                  then
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
          			                {$ELSEC}
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else
    			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
    			              end;

    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}


    			          if (noteCourante > maxPourBestDefABFinPetite) then
    			            begin
    			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
    			              {$ENDC}
    			              if (noteCourante >= beta) then
    	                    begin
    	                      ABFinBitboardParite := noteCourante;
    	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    			                  EndMiniprofilerBitboard(ESProf);
    		                   {$ENDC}
    		                    exit(ABFinBitboardParite);
    	                    end;
    			              if (noteCourante > alpha) then alpha := noteCourante;
    			              maxPourBestDefABFinPetite := noteCourante;
    			            end;

    			          diffEssai := diffPions;
    	            END;
    	        end;

       UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);

    END;



{pairs:}
  REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


     GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


       if COUP_EST_DANS_UNE_ZONE_PAIRE(leadingZeros,vecteurParite) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardParite :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}


            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;

	          if nouvelleParite <> vecteurParite then
		          BEGIN

		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}


		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}

			          if (profMoins1 = 4)
			            then
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}

			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}


			                {$IFC AVEC_MESURE_DE_PARALLELISME}
		                  PointDeMesureDeParallelisme;
		                  {$ENDC}

			                noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
		                  {$ELSEC}
                      blah
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}

                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else
			              begin
			                if (profMoins1 = 2)
			                  then
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
      			                {$ELSEC}
      			                blah
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else
			                    noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
			              end;

			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}



							  if (noteCourante > maxPourBestDefABFinPetite) then
			            begin
			              {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
			              if (gOrdreOptimum.nombre_statistiques < 2000000000) then bestmove := iCourant;
			              {$ENDC}
			              if (noteCourante >= beta) then
	                    begin
	                      ABFinBitboardParite := noteCourante;
	                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
			                  EndMiniprofilerBitboard(ESProf);
		                   {$ENDC}
		                    exit(ABFinBitboardParite);
	                    end;
			              if (noteCourante > alpha) then alpha := noteCourante;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;

			          diffEssai := diffPions;
		          END;
		      end;

	 UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);


{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardParite := maxPourBestDefABFinPetite;
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardParite := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardParite);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardParite := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardParite);
             end;
           ABFinBitboardParite := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardParite);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardParite := -ABFinBitboardParite(position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),listeBitboard);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardParite }





{ ABFinBitboardPariteHachage pour les petites profondeurs ( 4 < p <= 7 ).
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) un ordre fixe des cases en jouant la parité.

  Attention : position est modifiee par cette routine !
  Attention : toujours appeler cette routine avec au moins 5 cases vides,
              sinon on boucle. Notez que ABFinBitboardFastestFirst est une routine
              plus robuste, qui peut etre utilisee pour 0 <= p <= profForceBrute }
function ABFinBitboardPariteHachage(var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    nouvelleParite : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash_index : UInt32;
    hash_info : loweruppermoveemptiesRec;
		bestmove : SInt32;
		vientDePasser : boolean;
		{$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}
    {
    sauvegardePosition : bitboard;
    autreNoteCourante : SInt32;
    }

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
  if (gOrdreOptimum.nombre_statistiques < 2000000000) then
    begin
      inc(gOrdreOptimum.nombre_statistiques);
      alpha := -64;
      beta  := 64;
    end;
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;


  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;


  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardPariteHachage := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardPariteHachage);
        end;
      if noteCourante < beta then beta := noteCourante;
    end;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardPariteHachage :',position,ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}


	if (BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index,hash_info) <> NIL) then
	  begin
		  if (beta > hash_info.upper) then
			  begin
			    beta := hash_info.upper;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardPariteHachage := beta;
			        exit(ABFinBitboardPariteHachage);
			      end;
		    end;
		  if (alpha < hash_info.lower) then
		    begin
			    alpha := hash_info.lower;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardPariteHachage := alpha;
			        exit(ABFinBitboardPariteHachage);
			      end;
			  end;
		  bestmove := hash_info.stored_move;
		  // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
		end;



  if (BAnd(vecteurParite,15) <> 0) then  {y a-t-il des coups impairs ?}
    BEGIN

    {impairs:}
      REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


         GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


            if COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros,vecteurParite) then
    	        begin
    	          {$IFC DEBUG_BITBOARD_ALPHA_BETA}
    	          EcritBitboardState('dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
    	          WritelnStringAndCoupDansRapport('coup impair : ',iCourant);
    	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
    	          WritelnDansRapport('');
    	          AttendFrappeClavier;
    	          {$ENDC}

    	          if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
    	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
    	            else nouvelleParite := vecteurParite;

    	          if nouvelleParite <> vecteurParite then
    		          BEGIN

    			          {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
    			          if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
    			          {$ENDC}


    		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    		            EndMiniprofilerBitboard(ESProf);
    		            {$ENDC}

    			          if (profMoins1 = 4)
    			            then
    			              begin
    			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      BeginMiniprofilerBitboard(4);
		                      {$ENDC}

		                    	{$IFC USING_QUATRECASESVIDESBITBOARDFAST}


		                    	{$IFC AVEC_MESURE_DE_PARALLELISME}
		                    	PointDeMesureDeParallelisme;
		                    	{$ENDC}



                          noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
                          {$ELSEC}
                           blah
                           noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                           noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                          {$ENDC}

		                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                      EndMiniprofilerBitboard(4);
		                      {$ENDC}
    			              end
    			            else
    			              begin
    			                if (profMoins1 = 2)
    			                  then
    			                    begin
    			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
          			                with position do
          			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
          			                {$ELSEC}
          			                blah
          			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
          			                {$ENDC}
    			                    end
    			                  else
    			                    begin
    			                      noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
    			                    end;
    			              end;

    			         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                    BeginMiniprofilerBitboard(ESProf);
                   {$ENDC}


    			          if (noteCourante > maxPourBestDefABFinPetite) then
    			             begin
    			               bestmove := iCourant;
    			               if (noteCourante > alpha) then
    			                 begin
    			                   if (noteCourante >= beta) then
    			                      begin
    			                        ABFinBitboardPariteHachage := noteCourante;
    			                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
    					                    EndMiniprofilerBitboard(ESProf);
    				                     {$ENDC}
    				                      BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,bestmove);
    				                      exit(ABFinBitboardPariteHachage);
    			                      end;
    			                   alpha := noteCourante;
    			                 end;
    			               maxPourBestDefABFinPetite := noteCourante;
    			             end;
    			          diffEssai := diffPions;
    	            END;
    	        end;

      UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);

    END;

{pairs:}
  REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);


     GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);


       if COUP_EST_DANS_UNE_ZONE_PAIRE(leadingZeros,vecteurParite) then
          begin
            {$IFC DEBUG_BITBOARD_ALPHA_BETA}
	          EcritBitboardState('dans ABFinBitboardPariteHachage :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
	          WritelnStringAndCoupDansRapport('coup pair : ',iCourant);
	          WritelnListeBitboardDansRapport('iterateur = ',iterateur,-1);
	          WritelnDansRapport('');
	          AttendFrappeClavier;
	          {$ENDC}


            if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high)
	            then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
	            else nouvelleParite := vecteurParite;

	          if nouvelleParite <> vecteurParite then
		          BEGIN

		            {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
		            if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.ce_coup_est_legal[iCourant]);
		            {$ENDC}


		            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		            EndMiniprofilerBitboard(ESProf);
		            {$ENDC}

			          if (profMoins1 = 4)
			            then
			              begin
			                {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  BeginMiniprofilerBitboard(4);
		                  {$ENDC}

			                {$IFC USING_QUATRECASESVIDESBITBOARDFAST}


			                {$IFC AVEC_MESURE_DE_PARALLELISME}
		                  PointDeMesureDeParallelisme;
		                  {$ENDC}



                      noteCourante := -QuatreCasesVidesBitboardFast(position,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
                      {$ELSEC}
                      blah
                      noteCourante := -QuatreCasesVidesBitboardSimple(position,-beta,-alpha,-diffEssai,nouvelleParite)
                      noteCourante := -ABFinBitboardQuatreCasesVides(position,-beta,-alpha,-diffEssai,nouvelleParite);
                      {$ENDC}

                      {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
		                  EndMiniprofilerBitboard(4);
		                  {$ENDC}
			              end
			            else
			              begin
			                if (profMoins1 = 2)
			                  then
			                    begin
			                      {$IFC USING_DEUXCASESVIDESBITBOARDFAST}
      			                with position do
      			                  noteCourante := -DeuxCasesVidesBitboardFast(g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,-beta,-alpha,-diffEssai,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
      			                {$ELSEC}
      			                blah
      			                noteCourante := -DeuxCasesVidesBitboard(position,-beta,-alpha,-diffEssai,false);
      			                {$ENDC}
			                    end
			                  else
			                    begin
			                      noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide));
			                    end
			              end;

			          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                BeginMiniprofilerBitboard(ESProf);
                {$ENDC}



			          if (noteCourante > maxPourBestDefABFinPetite) then
			            begin
			              bestmove := iCourant;
			              if (noteCourante > alpha) then
			                begin
			                  if (noteCourante >= beta) then
			                    begin
			                      ABFinBitboardPariteHachage := noteCourante;
			                     {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                  EndMiniprofilerBitboard(ESProf);
				                   {$ENDC}
				                    BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,bestmove);
				                    exit(ABFinBitboardPariteHachage);
			                    end;
			                  alpha := noteCourante;
			                end;
			              maxPourBestDefABFinPetite := noteCourante;
			            end;

			          diffEssai := diffPions;
		          END;
		      end;

	 UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);


{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardPariteHachage := maxPourBestDefABFinPetite;
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
       {$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}
       if (gOrdreOptimum.nombre_statistiques < 2000000000) then inc(gOrdreOptimum.meilleur_coup_dans_cette_case[bestmove]);
       {$ENDC}
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardPariteHachage := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardPariteHachage);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardPariteHachage := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
				      exit(ABFinBitboardPariteHachage);
             end;
           ABFinBitboardPariteHachage := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardPariteHachage);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardPariteHachage := -ABFinBitboardPariteHachage(position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),listeBitboard,hash_table);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardPariteHachage }



{ ABFinBitboardFastestFirst pour les petites profondeurs ( 7 < prof <= profForceBrute )
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) Fastest First pour trier les coups selon la divergence adversaire decroissante.
  Attention : position est modifiee par cette routine ! }
function ABFinBitboardFastestFirst(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    i : SInt32;
    iCourant : UInt32;
    nbCoupsLegaux : SInt32;
    nouvelleParite : SInt32;
    listeCoupsLegaux : listeVides;
    bestmove : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash_index : UInt32;
    hash_info : loweruppermoveemptiesRec;
    vientDePasser : boolean;
    {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai   := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;

  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardFastestFirst :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardFastestFirst := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardFastestFirst);
        end;
      if noteCourante < beta then beta := succ(noteCourante);
    end;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardFastestFirst :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}





	if (BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index,hash_info) <> NIL) then
	  begin
		  if (beta > hash_info.upper) then
			  begin
			    beta := hash_info.upper;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirst := beta;
			        exit(ABFinBitboardFastestFirst);
			      end;
		    end;
		  if (alpha < hash_info.lower) then
		    begin
			    alpha := hash_info.lower;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirst := alpha;
			        exit(ABFinBitboardFastestFirst);
			      end;
			  end;
		  bestmove := hash_info.stored_move;
		  // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
		end;



  (* trier les coups *)

  nbCoupsLegaux := TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,listeCoupsLegaux,bestmove,listeBitboard);



  (* jouer les coups *)

  for i := 1 to nbCoupsLegaux do
    begin

      if CassioUtiliseLeMultiprocessing then
        begin
          EcouterLesResultatsDansCetteThread(nroThread);

          // interruption ?
          if ThreadEstInterrompue(nroThread, ESProf) then
            begin
              ABFinBitboardFastestFirst := kValeurSpecialeInterruptionCalculParallele;
              exit(ABFinBitboardFastestFirst);
            end;
        end;


      iCourant := listeCoupsLegaux[i];

      nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai);

	    if nouvelleParite <> vecteurParite
        then
          BEGIN



	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
	          BeginCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}

            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            EndMiniprofilerBitboard(ESProf);
            {$ENDC}


            if (profMoins1 = 7)
              then noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant))
              else noteCourante := -ABFinBitboardFastestFirst(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);





	          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            BeginMiniprofilerBitboard(ESProf);
            {$ENDC}

	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
	          EndCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}


	          if (noteCourante > maxPourBestDefABFinPetite) &
	             (noteCourante <> -kValeurSpecialeInterruptionCalculParallele) then
	             begin
	               maxPourBestDefABFinPetite := noteCourante;
	               bestmove                  := iCourant;

	               if (noteCourante > alpha) then
	                 begin
	                   alpha := noteCourante;
	                   if (alpha >= beta) then
	                      begin
	                        ABFinBitboardFastestFirst := maxPourBestDefABFinPetite;
	                        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);

	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                EndMiniprofilerBitboard(ESProf);
				                 {$ENDC}
	                        exit(ABFinBitboardFastestFirst);
	                      end;
	                 end;
	             end;

	          diffEssai := diffPions;
          END;
    end;

 if CassioUtiliseLeMultiprocessing then
   begin
     EcouterLesResultatsDansCetteThread(nroThread);

     // interruption ?
     if ThreadEstInterrompue(nroThread, ESProf) then
       begin
         ABFinBitboardFastestFirst := kValeurSpecialeInterruptionCalculParallele;
         exit(ABFinBitboardFastestFirst);
       end;
   end;

{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardFastestFirst := maxPourBestDefABFinPetite;
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardFastestFirst := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirst);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardFastestFirst := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirst);
             end;
           ABFinBitboardFastestFirst := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardFastestFirst);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardFastestFirst := -ABFinBitboardFastestFirst(nroThread,position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),listeBitboard,hash_table);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardFastestFirst }



{ ABFinBitboardFastestFirstKnuth pour les petites profondeurs ( 7 < prof <= profForceBrute )
  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) Fastest First pour trier les coups selon la divergence adversaire decroissante.
  Attention : position est modifiee par cette routine ! }
function ABFinBitboardFastestFirstKnuth(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite,typeKnuth : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    i : SInt32;
    iCourant : UInt32;
    nbCoupsLegaux : SInt32;
    nouvelleParite : SInt32;
    listeCoupsLegaux : listeVides;
    bestmove : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash_index : UInt32;
    hash_info : loweruppermoveemptiesRec;
    vientDePasser : boolean;
    {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}
    statutKnuthProbableDuFils : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,coupTest,bitCaseVide,leadingZeros);

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai   := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;

  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardFastestFirstKnuth :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardFastestFirstKnuth := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardFastestFirstKnuth);
        end;
      if noteCourante < beta then beta := succ(noteCourante);
    end;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardFastestFirstKnuth :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}





	if (BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index,hash_info) <> NIL) then
	  begin
		  if (beta > hash_info.upper) then
			  begin
			    beta := hash_info.upper;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirstKnuth := beta;
			        exit(ABFinBitboardFastestFirstKnuth);
			      end;
		    end;
		  if (alpha < hash_info.lower) then
		    begin
			    alpha := hash_info.lower;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirstKnuth := alpha;
			        exit(ABFinBitboardFastestFirstKnuth);
			      end;
			  end;
		  bestmove := hash_info.stored_move;
		  // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
		end;




  {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
  with gStatutsKnuth[ESProf] do
    if nombre_statistiques < 2000000000 then
      begin
        inc(nombre_statistiques);
        if (typeKnuth = ALPHA_COUPURE_PROBABLE) then inc(estimations_coupures_alpha);
        if (typeKnuth = BETA_COUPURE_PROBABLE) then inc(estimations_coupures_beta);
      end;
  {$ENDC}




  if (typeKnuth = ALPHA_COUPURE_PROBABLE) & (ESProf <= 9)
    then
      begin
        (* generer les coups *)

         nbCoupsLegaux := 1;
      	 listeCoupsLegaux[1] := 0; // pour pouvoir placer en tete le coup de la table de hachage

      	 REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);
      		  GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,coupTest,leadingZeros);
      		  if (coupTest = bestmove)
      		    then
      		      listeCoupsLegaux[1] := coupTest
      		    else
      		      begin
      		        if ModifPlatPlausible(coupTest,pos_opp_bits_low,pos_opp_bits_high) then
      		          begin
      		            inc(nbCoupsLegaux);
      		            listeCoupsLegaux[nbCoupsLegaux] := coupTest;
      		          end;
      		      end;
      		UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);
      end
    else
      (* trier les coups *)
      nbCoupsLegaux := TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,listeCoupsLegaux,bestmove,listeBitboard);




  (* jouer les coups *)

  for i := 1 to nbCoupsLegaux do
    begin

      if CassioUtiliseLeMultiprocessing then
        begin
          EcouterLesResultatsDansCetteThread(nroThread);

          // interruption ?
          if ThreadEstInterrompue(nroThread, ESProf) then
            begin
              ABFinBitboardFastestFirstKnuth := kValeurSpecialeInterruptionCalculParallele;
              exit(ABFinBitboardFastestFirstKnuth);
            end;
        end;


      iCourant := listeCoupsLegaux[i];

      if (iCourant <> 0)
        then nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai)
        else nouvelleParite := vecteurParite;

	    if nouvelleParite <> vecteurParite
        then
          BEGIN



	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
	          BeginCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}

            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            EndMiniprofilerBitboard(ESProf);
            {$ENDC}



            if (profMoins1 = 7)
        			then noteCourante := -ABFinBitboardParite(position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant))
        			else
        			  begin


        			    (* des heuristiques pour deviner le statut Knuth du fils *)




        			        if (i >= 5) then
            			      statutKnuthProbableDuFils := BETA_COUPURE_PROBABLE

            			    else if (typeKnuth = BETA_COUPURE_PROBABLE) & (i = 1) then
            			      statutKnuthProbableDuFils := ALPHA_COUPURE_PROBABLE

            			    else if (typeKnuth = ALPHA_COUPURE_PROBABLE) then
            			      statutKnuthProbableDuFils := BETA_COUPURE_PROBABLE

            			    else
            			      statutKnuthProbableDuFils := STATUT_KNUTH_INCONNU;



        			    noteCourante := -ABFinBitboardFastestFirstKnuth(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,statutKnuthProbableDuFils,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);
                end;







	          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            BeginMiniprofilerBitboard(ESProf);
            {$ENDC}

	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
	          EndCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}


	          if (noteCourante > maxPourBestDefABFinPetite) &
	             (noteCourante <> -kValeurSpecialeInterruptionCalculParallele) then
	             begin
	               maxPourBestDefABFinPetite := noteCourante;
	               bestmove                  := iCourant;

	               if (noteCourante > alpha) then
	                 begin
	                   alpha := noteCourante;
	                   if (alpha >= beta) then
	                      begin
	                        ABFinBitboardFastestFirstKnuth := maxPourBestDefABFinPetite;
	                        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);

	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                EndMiniprofilerBitboard(ESProf);
				                 {$ENDC}

				                 {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
                          with gStatutsKnuth[ESProf] do
                            if nombre_statistiques <= 2000000000 then
                              begin
                                inc(nombre_coupures_beta);
                                inc(index_coupure_beta[i]);
                                if (typeKnuth = BETA_COUPURE_PROBABLE) then inc(coupures_beta_anticipees);
                              end;
                          {$ENDC}

	                        exit(ABFinBitboardFastestFirstKnuth);
	                      end;
	                 end;
	             end;

	          diffEssai := diffPions;
          END;
    end;

 if CassioUtiliseLeMultiprocessing then
   begin
     EcouterLesResultatsDansCetteThread(nroThread);

     // interruption ?
     if ThreadEstInterrompue(nroThread, ESProf) then
       begin
         ABFinBitboardFastestFirstKnuth := kValeurSpecialeInterruptionCalculParallele;
         exit(ABFinBitboardFastestFirstKnuth);
       end;
   end;

{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardFastestFirstKnuth := maxPourBestDefABFinPetite;
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);

       {$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}
        with gStatutsKnuth[ESProf] do
          if nombre_statistiques <= 2000000000 then
            begin
              inc(nombre_coupures_alpha);
              if (typeKnuth = ALPHA_COUPURE_PROBABLE) then inc(coupures_alpha_anticipees);
            end;
        {$ENDC}

     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardFastestFirstKnuth := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirstKnuth);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardFastestFirstKnuth := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirstKnuth);
             end;
           ABFinBitboardFastestFirstKnuth := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardFastestFirstKnuth);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardFastestFirstKnuth := -ABFinBitboardFastestFirstKnuth(nroThread,position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),STATUT_KNUTH_INCONNU,listeBitboard,hash_table);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardFastestFirstKnuth }





{ ABFinBitboardFastestFirstAvecETC pour les petites profondeurs ( 14 < prof <= profForceBrute )

  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) Fastest First pour trier les coups selon la divergence adversaire decroissante.
              d) l'algorithme Enhanced Transposition Cutoff

  Attention : position est modifiee par cette routine ! }

function ABFinBitboardFastestFirstAvecETC(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    i : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    nbCoupsLegaux : SInt32;
    nouvelleParite : SInt32;
    listeCoupsLegaux : listeVides;
    bestmove : SInt32;
    alphaDepart,betaDepart : SInt32;
    hash_index : UInt32;
    hash_index_fils : UInt32;
    hash_info : loweruppermoveemptiesRec;
    diffBidon : SInt32;
    vientDePasser : boolean;
    {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}

begin

  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai   := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;

  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardFastestFirstAvecETC :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardFastestFirstAvecETC := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardFastestFirstAvecETC);
        end;
      if noteCourante < beta then beta := succ(noteCourante);
    end;


  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardFastestFirstAvecETC :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}


	if (BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index,hash_info) <> NIL) then
	  begin
		  if (beta > hash_info.upper) then
			  begin
			    beta := hash_info.upper;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirstAvecETC := beta;
			        exit(ABFinBitboardFastestFirstAvecETC);
			      end;
		    end;
		  if (alpha < hash_info.lower) then
		    begin
			    alpha := hash_info.lower;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardFastestFirstAvecETC := alpha;
			        exit(ABFinBitboardFastestFirstAvecETC);
			      end;
			  end;
		  bestmove := hash_info.stored_move;
		  // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
		end;



  (* on essaye le Enhanced Transposition Cutoff *)

   REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);

      GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);

		    if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high) &
		      (ModifPlatBitboard(iCourant,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon) <> 0)
		      then
		        with position do
		          begin
                if (BitboardHashGet(hash_table,g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,hash_index_fils,hash_info) <> NIL) then
              	  begin
              	    if ( -hash_info.upper >= beta ) then
              	      begin
              	        (* coupure ETC  trouvee ! *)
              	        noteCourante := -hash_info.upper;
              	        // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index_fils);
              	        ABFinBitboardFastestFirstAvecETC := noteCourante;
              	        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,iCourant);
              			    exit(ABFinBitboardFastestFirstAvecETC);
              	      end;
              	    // RELEASE_BITBOARD_HASH_LOCK(hash_index_fils);
              	  end;
		           end; {with}

	 UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);



  (* trier les coups *)

  nbCoupsLegaux := TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,listeCoupsLegaux,bestmove,listeBitboard);



  (* jouer les coups *)

  for i := 1 to nbCoupsLegaux do
    begin

      if CassioUtiliseLeMultiprocessing then
        begin
          EcouterLesResultatsDansCetteThread(nroThread);

          // interruption ?
          if ThreadEstInterrompue(nroThread, ESProf) then
            begin
              ABFinBitboardFastestFirstAvecETC := kValeurSpecialeInterruptionCalculParallele;
              exit(ABFinBitboardFastestFirstAvecETC);
            end;
        end;


      iCourant := listeCoupsLegaux[i];

      nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai);

	    if nouvelleParite <> vecteurParite
        then
          BEGIN

	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
            BeginCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}

            {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            EndMiniprofilerBitboard(ESProf);
            {$ENDC}




            if (profMoins1 <= 14)
      				then noteCourante := -ABFinBitboardFastestFirst(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table)
      				else noteCourante := -ABFinBitboardFastestFirstAvecETC(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);



	          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
            BeginMiniprofilerBitboard(ESProf);
            {$ENDC}

	          {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
	          EndCollecteStatsNbreNoeudsEndgame(profMoins1);
            {$ENDC}


	          if (noteCourante > maxPourBestDefABFinPetite) &
	             (noteCourante <> -kValeurSpecialeInterruptionCalculParallele) then
	             begin
	               maxPourBestDefABFinPetite := noteCourante;
	               bestmove                  := iCourant;

	               if (noteCourante > alpha) then
	                 begin
	                   alpha := noteCourante;
	                   if (alpha >= beta) then
	                      begin
	                        ABFinBitboardFastestFirstAvecETC := maxPourBestDefABFinPetite;
	                        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);

	                       {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					                EndMiniprofilerBitboard(ESProf);
				                 {$ENDC}
	                        exit(ABFinBitboardFastestFirstAvecETC);
	                      end;
	                 end;
	             end;

	          diffEssai := diffPions;
          END;
    end;

 if CassioUtiliseLeMultiprocessing then
   begin
     EcouterLesResultatsDansCetteThread(nroThread);

     // interruption ?
     if ThreadEstInterrompue(nroThread, ESProf) then
       begin
         ABFinBitboardFastestFirstAvecETC := kValeurSpecialeInterruptionCalculParallele;
         exit(ABFinBitboardFastestFirstAvecETC);
       end;
   end;

{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardFastestFirstAvecETC := maxPourBestDefABFinPetite;
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardFastestFirstAvecETC := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirstAvecETC);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardFastestFirstAvecETC := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardFastestFirstAvecETC);
             end;
           ABFinBitboardFastestFirstAvecETC := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardFastestFirstAvecETC);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardFastestFirstAvecETC := -ABFinBitboardFastestFirstAvecETC(nroThread,position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),listeBitboard,hash_table);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardFastestFirst }




{ ABFinBitboardParallele

  On utilise  a) les pions définitifs pour les positions a tres gros score
              b) la table de hachage bitboard
              c) Fastest First pour trier les coups selon la divergence adversaire decroissante.
              d) l'algorithme Enhanced Transposition Cutoff

  Attention : position est modifiee par cette routine ! }

function ABFinBitboardParallele(nroThread : SInt32; var position : bitboard; ESprof,alpha,beta,diffPions,vecteurParite,numFirtSonToParallelize : SInt32; listeBitboard : UInt32; hash_table : BitboardHashTable) : SInt32;
var pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
    diffEssai : SInt32;
    profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDefABFinPetite : SInt32;
    indexCourant : SInt32;
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    nbCoupsLegaux : SInt32;
    nouvelleParite : SInt32;
    listeCoupsLegaux : listeVides;
    bestmove : SInt32;
    alphaDepart,betaDepart : SInt32;
    hashStamp : SInt32;
    hash_index : UInt32;
    hash_index_fils : UInt32;
    hash_info : loweruppermoveemptiesRec;
    diffBidon : SInt32;
    vientDePasser : boolean;
    nroThreadEsclave : SInt32;
    meilleurFilsParallele : UInt32;
    nroDuDernierFilsEvalue : SInt32;
    utiliserParallelisme : boolean;
    {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
    foo_bar_atomic_register : SInt32;
    {$ENDC}

begin


  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
   BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  {$IFC (NBRE_NOEUDS_EXACT_DANS_ENDGAME or COLLECTE_STATS_NBRE_NOEUDS_ENDGAME)}
  ATOMIC_INCREMENT_32(nbreNoeudsGeneresFinale);
  {$ENDC}

  profMoins1 := pred(ESprof);
  maxPourBestDefABFinPetite := -noteMax;
  bestmove := 0;
  with position do
    begin
      pos_my_bits_low   := g_my_bits_low;
      pos_my_bits_high  := g_my_bits_high;
      pos_opp_bits_low  := g_opp_bits_low;
      pos_opp_bits_high := g_opp_bits_high;
    end;
  diffEssai   := diffPions;
  alphaDepart := alpha;
  betaDepart  := beta;

  // Extraire l'information de savoir si on vient de passer ou pas
  vientDePasser := (vecteurParite and kBitVientDePasser) <> 0;
  vecteurParite := vecteurParite and kNeVientDePasserDePasserMask;

  if (alpha >= stability_alpha[ESProf]) {& (diffPions <= alpha-ESProf)} then
    begin
      { Calculons la note maximale que l'on peut obtenir,
        connaissant les pions definitifs de l'adversaire }
      noteCourante := 64 - 2*CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1));
      { noteCourante = la note maximale que l'on peut esperer obtenir}
      if noteCourante <= alpha then { pas d'espoir... }
        begin
          {
          WritelnDansRapport('cut-off de stabilite :');
          EcritBitboardState('Entree dans ABFinBitboardParallele :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
          WritelnNumDansRapport('pions stables adversaire = ',CalculePionsStablesBitboard(pos_opp_bits_low,pos_opp_bits_high,pos_my_bits_low,pos_my_bits_high, BSr(65-alpha,1)));
          AttendFrappeClavier;
          }
          ABFinBitboardParallele := noteCourante;
         {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					EndMiniprofilerBitboard(ESProf);
				 {$ENDC}
          exit(ABFinBitboardParallele);
        end;
      if noteCourante < beta then beta := succ(noteCourante);
    end;



  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  EcritBitboardState('Entree dans ABFinBitboardParallele :',MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),ESprof,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  if (ESProf >= 3) then
    begin
		  WritelnDansRapport('');
		  WritelnStringAndBooleenDansRapport('pair[A1] = ',BAnd(vecteurParite,constanteDeParite[11]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H1] = ',BAnd(vecteurParite,constanteDeParite[18]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[A8] = ',BAnd(vecteurParite,constanteDeParite[81]) = 0);
		  WritelnStringAndBooleenDansRapport('pair[H8] = ',BAnd(vecteurParite,constanteDeParite[88]) = 0);
		end;
  AttendFrappeClavier;
  {$ENDC}


  hashStamp := (pos_my_bits_low * pos_opp_bits_high) + (pos_my_bits_high + pos_opp_bits_low);

	if (BitboardHashGet(hash_table,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,hash_index,hash_info) <> NIL) then
	  begin
		  if (beta > hash_info.upper) then
			  begin
			    beta := hash_info.upper;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardParallele := beta;
			        exit(ABFinBitboardParallele);
			      end;
		    end;
		  if (alpha < hash_info.lower) then
		    begin
			    alpha := hash_info.lower;
			    if (alpha >= beta) then
			      begin
			        // RELEASE_BITBOARD_HASH_LOCK(hash_index);
			        ABFinBitboardParallele := alpha;
			        exit(ABFinBitboardParallele);
			      end;
			  end;
		  bestmove := hash_info.stored_move;
		  // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index);
		end;



  (* on essaye le Enhanced Transposition Cutoff *)
  if (ESprof >= 13) then
     begin
       REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);

          GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);

      	    if ModifPlatPlausible(iCourant,pos_opp_bits_low,pos_opp_bits_high) &
    		      (ModifPlatBitboard(iCourant,0,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffBidon) <> 0)
    		      then
    		        with position do
    		          begin
                    if (BitboardHashGet(hash_table,g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,hash_index_fils,hash_info) <> NIL) then
                  	  begin
                  	    if ( -hash_info.upper >= beta ) then
                  	      begin
                  	        (* coupure ETC  trouvee ! *)
                  	        noteCourante := -hash_info.upper;
                  	        // RELEASE_BITBOARD_HASH_LOCK_BARRIER(hash_index_fils);
                  	        ABFinBitboardParallele := noteCourante;
                  	        BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,noteCourante,iCourant);
                  			    exit(ABFinBitboardParallele);
                  	      end;
                  	    // RELEASE_BITBOARD_HASH_LOCK(hash_index_fils);
                  	  end;
    		           end; {with}

       UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);
     end;




  (* trier les coups *)

  nbCoupsLegaux := TrierFastestFirstBitboardStabilite(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,listeCoupsLegaux,bestmove,listeBitboard);



  (* jouer les coups *)

  indexCourant := 1;

  WHILE (indexCourant <= nbCoupsLegaux) DO

    BEGIN

      noteCourante := kValeurSpecialeInterruptionCalculParallele;

      EcouterLesResultatsDansCetteThread(nroThread);

      // interruption ?
      if ThreadEstInterrompue(nroThread, ESProf) then
        begin
          ABFinBitboardParallele := kValeurSpecialeInterruptionCalculParallele;
          exit(ABFinBitboardParallele);
        end;

      utiliserParallelisme := (profMoins1 >= gNbreEmptiesMinimalPourParallelisme) &
                              (indexCourant >= numFirtSonToParallelize) &
                              (indexCourant < nbCoupsLegaux) &
                              (gNbreProcesseursCalculant < numProcessors) &
                              PeutTrouverUneThreadDisponible(nroThread,ESProf,hashStamp,nroThreadEsclave);



      if utiliserParallelisme
        then
          begin

            // PARALLELISATION DE L'ALPHA-BETA

            // {$IFC (AVEC_DEBUG_PARALLELISME OR TRUE)}
            {$IFC FALSE}
             if (kVerbosityLevelAlgoParallele >= 3) & (nbreNoeudsGeneresFinale >= kNombreDeNoeudMinimalPourSuiviDansRapport) then
                begin
                  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                  WritelnNumDansRapport('avant l''appel à CalculerCoupsEnParallele par la thread '+NumEnString(nroThread)+', nroThreadEsclave = ',nroThreadEsclave);
                  AttendreFrappeClavierParallelisme(true);
                  errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                end;
             {$ENDC}


             noteCourante :=  CalculerCoupsEnParallele(nroThread,
                                                       nroThreadEsclave,
                                                       MakeBitboard(pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high),
                                                       ESProf,
                                                       alpha,
                                                       beta,
                                                       diffEssai,
                                                       vecteurParite,
                                                       listeBitboard,
                                                       listeCoupsLegaux,
                                                       indexCourant,
                                                       nbCoupsLegaux,
                                                       meilleurFilsParallele,
                                                       nroDuDernierFilsEvalue);

            iCourant := meilleurFilsParallele;
            indexCourant := nroDuDernierFilsEvalue;


            // interruption ?
            if (noteCourante =  kValeurSpecialeInterruptionCalculParallele) |
               (noteCourante = -kValeurSpecialeInterruptionCalculParallele) then
              begin
                ABFinBitboardParallele := kValeurSpecialeInterruptionCalculParallele;
                exit(ABFinBitboardParallele);
              end;


          //  {$IFC AVEC_DEBUG_PARALLELISME}
           {$IFC FALSE}
             if (kVerbosityLevelAlgoParallele >= 3) & (nbreNoeudsGeneresFinale >= kNombreDeNoeudMinimalPourSuiviDansRapport) then
                begin
                  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
                  WritelnNumDansRapport('apres l''appel à CalculerCoupsEnParallele par la thread '+NumEnString(nroThread)+',  nroThreadEsclave = ',nroThreadEsclave);
                  AttendreFrappeClavierParallelisme(true);
                  errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
                end;
            {$ENDC}


          end
        else
          begin

            // on evalue ce fils en sequentiel

            iCourant := listeCoupsLegaux[indexCourant];

            nouvelleParite := ModifPlatBitboard(iCourant,vecteurParite,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,position,diffEssai);

            if nouvelleParite <> vecteurParite
              then
                begin



                  {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
                  BeginCollecteStatsNbreNoeudsEndgame(profMoins1);
                  {$ENDC}

                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                  EndMiniprofilerBitboard(ESProf);
                  {$ENDC}



                  // parallelisme recursif
                  if (profMoins1 >= gNbreEmptiesMinimalPourParallelisme )
            				then
            				  begin
            				    if (indexCourant < numFirtSonToParallelize) & gAvecParallelismeSpeculatif
                				  then noteCourante := -ABFinBitboardParallele(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,1,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table)
                				  else noteCourante := -ABFinBitboardParallele(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,gYoungBrotherWaitElders,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);
            				  end
            				else
            				  noteCourante := -ABFinBitboardFastestFirst(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);
            				  (*
            				  begin
            				    if (profMoins1 <= 14)
                  				then noteCourante := -ABFinBitboardFastestFirst(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table)
                  				else noteCourante := -ABFinBitboardFastestFirstAvecETC(nroThread,position,profMoins1,-beta,-alpha,-diffEssai,nouvelleParite,REMOVE_CASE_VIDE_FROM_LISTE(listeBitboard,iCourant),hash_table);
                  		end;
                  		*)

                  {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
                  BeginMiniprofilerBitboard(ESProf);
                  {$ENDC}

                  {$IFC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME}
                  EndCollecteStatsNbreNoeudsEndgame(profMoins1);
                  {$ENDC}

  		          end;
  		    end;


      if (noteCourante > maxPourBestDefABFinPetite) &
	       (noteCourante <> -kValeurSpecialeInterruptionCalculParallele) then
         begin
           maxPourBestDefABFinPetite := noteCourante;
           bestmove                  := iCourant;

           if (noteCourante > alpha) then
             begin
               alpha := noteCourante;
               if (alpha >= beta) then
                  begin
                    ABFinBitboardParallele := maxPourBestDefABFinPetite;
                    BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);

                   {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
  	                EndMiniprofilerBitboard(ESProf);
                   {$ENDC}
                    exit(ABFinBitboardParallele);
                  end;
             end;
         end;

      diffEssai := diffPions;

      inc(indexCourant);

    END;

 EcouterLesResultatsDansCetteThread(nroThread);

 // interruption ?
 if ThreadEstInterrompue(nroThread, ESProf) then
   begin
     ABFinBitboardParallele := kValeurSpecialeInterruptionCalculParallele;
     exit(ABFinBitboardParallele);
   end;

{fin:}
 if (maxPourBestDefABFinPetite <> -noteMax)  {a-t-on joue au moins un coup ?}
   then
     begin
       ABFinBitboardParallele := maxPourBestDefABFinPetite;
       BitboardHashUpdate(hash_table,hash_index,pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high,ESprof,alphaDepart,betaDepart,maxPourBestDefABFinPetite,bestmove);
     end
   else
     begin
       if vientDePasser then
         begin
           { terminé! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('terminé !');
           AttendFrappeClavier;
           {$ENDC}

           if diffPions > 0 then
             begin
               ABFinBitboardParallele := diffPions + ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardParallele);
             end;
           if diffPions < 0 then
             begin
               ABFinBitboardParallele := diffPions - ESprof;
              {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					     EndMiniprofilerBitboard(ESProf);
				      {$ENDC}
               exit(ABFinBitboardParallele);
             end;
           ABFinBitboardParallele := 0;
          {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
					 EndMiniprofilerBitboard(ESProf);
				  {$ENDC}
           exit(ABFinBitboardParallele);
         end
       else
         begin
           { passe! }

           {$IFC DEBUG_BITBOARD_ALPHA_BETA}
           WritelnDansRapport('passe !');
           AttendFrappeClavier;
           {$ENDC}

           with position do
             begin
               g_my_bits_high  := pos_opp_bits_high;
               g_opp_bits_high := pos_my_bits_high;
               g_my_bits_low   := pos_opp_bits_low;
               g_opp_bits_low  := pos_my_bits_low;
             end;
           ABFinBitboardParallele := -ABFinBitboardParallele(nroThread,position,ESprof,-beta,-alpha,-diffPions,(vecteurParite or kBitVientDePasser),gYoungBrotherWaitElders,listeBitboard,hash_table);
         end;
     end;
 {$IFC UTILISE_MINIPROFILER_POUR_MILIEU}
	EndMiniprofilerBitboard(ESProf);
 {$ENDC}
end;   { ABFinBitboardFastestFirst }



function LanceurBitboardAlphaBeta(var plat : plOthEndgame; couleur,ESprof,alpha,beta,diffPions,numFirtSonToParallelize : SInt32) : SInt32;
var note,adversaire,square,i,j : SInt32;
    myBitsLow,myBitsHigh,oppBitsLow,oppBitsHigh : UInt32;
    position : bitboard;
    listeBitboard : UInt32;
    microSecondesDepart : UnsignedWide;
    microSecondesFin : UnsignedWide;
begin



  {transforme un plateauOthello en bitboard}
	myBitsLow := 0;
	myBitsHigh := 0;
	oppBitsLow := 0;
	oppBitsHigh := 0;
	adversaire := -couleur;

	for j := 1 to 4 do
	  for i := 1 to 8 do
	    begin
	      square := j*10 + i;
	      if plat[square] = couleur then myBitsLow := BOr(myBitsLow,othellierBitboardDescr[square].constanteHexa)  else
	      if plat[square] = adversaire then oppBitsLow := BOr(oppBitsLow,othellierBitboardDescr[square].constanteHexa)
	    end;
	for j := 5 to 8 do
	  for i := 1 to 8 do
	    begin
	      square := j*10 + i;
	      if plat[square] = couleur then myBitsHigh := BOr(myBitsHigh,othellierBitboardDescr[square].constanteHexa)  else
	      if plat[square] = adversaire then oppBitsHigh := BOr(oppBitsHigh,othellierBitboardDescr[square].constanteHexa)
	    end;

	with position do
	  begin
	    g_my_bits_low := myBitsLow;
	    g_my_bits_high := myBitsHigh;
	    g_opp_bits_low := oppBitsLow;
	    g_opp_bits_high := oppBitsHigh;
	  end;

  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  WritelnDansRapport('plateau recu en parametre dans LanceurBitboardAlphaBeta: ');
  WritelnPositionEtTraitDansRapport(plat,couleur);
  WritelnNumDansRapport('diffPions = ',diffPions);
  WritelnDansRapport('(myBitsLow, myBitsHigh, oppBitsLow, oppBitsHigh) = ('+NumEnString(myBitsLow)+', '+NumEnString(myBitsHigh) + ', ' + NumEnString(oppBitsLow)+ ', '+NumEnString(oppBitsHigh) + ')');
  EcritBitboardState('dans LanceurBitboardAlphaBeta : ',position,ESprof,alpha,beta,diffPions);
  AttendFrappeClavier;
  {$ENDC}

  (*
  WritelnDansRapport('plateau recu en parametre dans LanceurBitboardAlphaBeta: ');
  WritelnPositionEtTraitDansRapport(plat,couleur);
  EcritTriFastestFirstBitboardDansRapport(position);
  AttendFrappeClavier;
  *)

  {$IFC UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
  BeginMiniprofilerBitboard(ESProf);
  {$ENDC}

  MicroSeconds(microSecondesDepart);

  listeBitboard := ListeChaineeDesCasesVidesEnListeBitboard(@gTeteListeChaineeCasesVides,ESProf);



  if CassioUtiliseLeMultiprocessing
    then
      begin
        if (listeBitboard = 0)
          then
            note := diffPions
          else
            begin
              if (ESProf >= gNbreEmptiesMinimalPourParallelisme)
                then
                  begin
                    ReinitialiserInterruptionsParHashStampsDesThreads(0);
                    note := ABFinBitboardParallele(0,position,ESProf,alpha,beta,diffPions,gVecteurParite,numFirtSonToParallelize,listeBitboard,gBitboardHashTable[0])  // 6.1.9
                  end
                else note := ABFinBitboardFastestFirstAvecETC(0,position,ESProf,alpha,beta,diffPions,gVecteurParite,listeBitboard,gBitboardHashTable[0]);  // 6.1.6
            end;

        EcouterLesResultatsDansCetteThread(0);
      end
    else
      begin
        if (listeBitboard = 0)
          then note := diffPions
          else note := ABFinBitboardFastestFirstAvecETC(0,position,ESProf,alpha,beta,diffPions,gVecteurParite,listeBitboard,gBitboardHashTable[0]);  // 6.1.6
      end;


  {note := ABFinBitboardFastestFirst(0,position,ESProf,alpha,beta,diffPions,gVecteurParite,false);  // 6.1.5 }
  {note := ABFinBitboardParite(position,ESProf,alpha,beta,diffPions,gVecteurParite,false);}

  MicroSeconds(microSecondesFin);
  gFractionParallelisableMicroSecondes        := gFractionParallelisableMicroSecondes + (microSecondesFin.lo-microSecondesDepart.lo);
  if (gFractionParallelisableMicroSecondes > 1000000) then
    begin
      inc(gFractionParallelisableSecondes);
      gFractionParallelisableMicroSecondes := gFractionParallelisableMicroSecondes - 1000000;
    end;

  {$IFC UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD}
  EndMiniprofilerBitboard(ESProf);
  {$ENDC}

  LanceurBitboardAlphaBeta := note;

  {$IFC DEBUG_BITBOARD_ALPHA_BETA}
  WritelnNumDansRapport('  ==>  note = ',note);
  EcritBitboardState('à la fin de LanceurBitboardAlphaBeta : ',position,ESProf,alpha,beta,diffPions);
  WritelnListeBitboardDansRapport('listeBitboard = ',listeBitboard,ESprof);
  AttendFrappeClavier;
  {$ENDC}

end;


function PeutFaireFinaleBitboardCettePosition(var plat : plateauOthello; couleur,alphaMilieu,betaMilieu,nbNoirs,nbBlancs : SInt32; var note : SInt32) : boolean;
var alphaFinale,betaFinale : SInt32;
begin

  if ListeChaineeDesCasesVidesEstDisponible
    then
      begin
        CreeListeCasesVidesDeCettePosition(plat,true);
		    CreerListeChaineeDesCasesVides(gNbreVides_entreeCoupGagnant,
		                                   gTeteListeChaineeCasesVides,
		                                   gBufferCellulesListeChainee,
		                                   gTableDesPointeurs,
		                                   'PeutFaireFinaleBitboardCettePosition');
        SetListeChaineeDesCasesVidesEstDisponible(false);


        (* on transforme les bornes de milieu en bornes de finale *)
        if alphaMilieu < 0 then alphaMilieu := alphaMilieu - 99;
        if betaMilieu  < 0 then betaMilieu  := betaMilieu  - 99;
        alphaFinale := alphaMilieu div 100;
        betaFinale  := (betaMilieu + 99) div 100;


        if (alphaFinale >  64) then alphaFinale :=  64;
        if (alphaFinale < -64) then alphaFinale := -64;
        if (betaFinale  >  64) then betaFinale  :=  64;
        if (betaFinale  < -64) then betaFinale  := -64;

        if (alphaFinale = -64) & (betaFinale = -64) then betaFinale  := -63;
        if (alphaFinale =  64) & (betaFinale =  64) then alphaFinale :=  63;

        if (alphaFinale > 64) | (alphaFinale < -64) | (alphaFinale > 64) | (alphaFinale < -64) then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : alphaFinale ou betaFinale est out of range dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnNumDansRapport('betaFinale  = ',betaFinale);
            WritelnNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnNumDansRapport('betaMilieu =  ',betaMilieu);
            WritelnNumDansRapport('nbNoirs =  ',nbNoirs);
            WritelnNumDansRapport('nbBlancs =  ',nbBlancs);
            WritelnDansRapport('tapez une touche…');
            WritelnDansRapport('');
            AttendFrappeClavier;
          end;

        (*
        WritelnDansRapport('plateau recu en parametre dans PeutFaireFinaleBitboardCettePosition : ');
        WritelnPositionEtTraitDansRapport(plat,couleur);
        WritelnNumDansRapport('gNbreVides_entreeCoupGagnant = ',gNbreVides_entreeCoupGagnant);
        WritelnNumDansRapport('alphaFinale = ',alphaFinale);
        WritelnNumDansRapport('betaFinale  = ',betaFinale);
        WritelnNumDansRapport('alphaMilieu = ',alphaMilieu);
        WritelnNumDansRapport('betaMilieu =  ',betaMilieu);
        WritelnDansRapport('tapez une touche…');
        WritelnDansRapport('');
        AttendFrappeClavier;
        *)

        if alphaFinale >= betaFinale then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : alphaFinale >= betaFinale dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnNumDansRapport('betaFinale  = ',betaFinale);
            WritelnNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnNumDansRapport('betaMilieu =  ',betaMilieu);
          end;




        if couleur = pionNoir
          then note := LanceurBitboardAlphaBeta(plat,couleur,gNbreVides_entreeCoupGagnant,alphaFinale,betaFinale,nbNoirs-nbBlancs,2)
          else note := LanceurBitboardAlphaBeta(plat,couleur,gNbreVides_entreeCoupGagnant,alphaFinale,betaFinale,nbBlancs-nbNoirs,2);


        (* on transforme inversement la note de finale en note de milieu *)

        if (note <>  kValeurSpecialeInterruptionCalculParallele) &
           (note <> -kValeurSpecialeInterruptionCalculParallele)
          then note := 100*note;


        if (note < -6400) | (note > 6400) then
          begin
            SysBeep(0);
            WritelnDansRapport('ASSERT : (note < -6400) | (note > 6400) dans PeutFaireFinaleBitboardCettePosition');
            WritelnPositionEtTraitDansRapport(plat,couleur);
            WritelnNumDansRapport('note = ',note);
            WritelnNumDansRapport('alphaFinale = ',alphaFinale);
            WritelnNumDansRapport('betaFinale  = ',betaFinale);
            WritelnNumDansRapport('alphaMilieu = ',alphaMilieu);
            WritelnNumDansRapport('betaMilieu =  ',betaMilieu);

            if (note <> kValeurSpecialeInterruptionCalculParallele) &
               (note <> -kValeurSpecialeInterruptionCalculParallele) then
              begin
                WritelnDansRapport('tapez une touche…');
                WritelnDansRapport('');
                AttendFrappeClavier;
              end;
          end;

        SetListeChaineeDesCasesVidesEstDisponible(true);

        PeutFaireFinaleBitboardCettePosition := (note <>  kValeurSpecialeInterruptionCalculParallele) &
                                                (note <> -kValeurSpecialeInterruptionCalculParallele);
      end
    else
      begin
        SysBeep(0);
        WritelnDansRapport('ASSERT : liste chainee non disponible dans PeutFaireFinaleBitboardCettePosition');

        PeutFaireFinaleBitboardCettePosition := false;
      end;

end;





{$IFC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES}

procedure ResetStatistiquesOrdreOptimumDesCases;
var i : SInt32;
begin
  with gOrdreOptimum do
    begin
      nombre_statistiques := 0;
      for i := 0 to 99 do
        meilleur_coup_dans_cette_case[i] := 0;
      for i := 0 to 99 do
        ce_coup_est_legal[i] := 0;
    end;
end;

procedure EcritStatistiquesOrdreOptimumDesCasesDansRapport;
var i,n,p,square : SInt32;
begin
  WritelnDansRapport('Statistiques pour déterminer l''ordre optimum des cases : ');
  with gOrdreOptimum do
    begin
      WritelnNumDansRapport('nombre_statistiques = ',nombre_statistiques);
      if (nombre_statistiques <> 0) then
        for i := 64 downto 1 do
          begin
            square := worst2bestOrder[i];

            if (ce_coup_est_legal[square] <> 0)
              then
                begin
                  WriteCoupDansRapport(square);

                  {nombre de fois où le meilleur coup a ete "square"}
                  n := meilleur_coup_dans_cette_case[square];
                  WriteStringAndNumEnSeparantLesMilliersDansRapport(', best = ',n);

                  {nombre de fois où "square" a ete legal}
                  p := ce_coup_est_legal[square];
                  WriteStringAndNumEnSeparantLesMilliersDansRapport(', legal = ',p);

                  {rapport entre les deux}
                  if (p <> 0)
                    then WritelnStringAndReelDansRapport(', % =', 100.0*n/p,4)
                    else WritelnDansRapport('');
                end;
          end;
    end;
end;

{$ENDC}




{$IFC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS}

procedure ResetStatistiquesStatutKnuthDesNoeuds;
var prof, k : SInt32;
begin
  for prof := 0 to 64 do
    with gStatutsKnuth[prof] do
      begin
        nombre_statistiques        := 0;
        nombre_coupures_beta       := 0;
        for k := 0 to 64 do
          index_coupure_beta[k]    := 0;
        nombre_coupures_alpha      := 0;
        estimations_coupures_beta  := 0;
        estimations_coupures_alpha := 0;
        coupures_beta_anticipees   := 0;
        coupures_alpha_anticipees  := 0;
      end;
end;


procedure EcritStatistiquesStatutKnuthDesNoeudsDansRapport;
var prof, a, n, p : SInt32;
begin
  for prof := 0 to 64 do
    with gStatutsKnuth[prof] do
      if (nombre_statistiques <> 0) then
        begin
          WritelnDansRapport('');
          WritelnNumDansRapport('gStatutsKnuth pour la prof ',prof);

          WritelnNumDansRapport('nombre_statistiques = ',nombre_statistiques);



          p := nombre_coupures_alpha;
          n := estimations_coupures_alpha;
          a := coupures_alpha_anticipees;
          WritelnNumDansRapport('nombre_coupures_alpha = ',p);
          WriteNumDansRapport('estimations_coupures_alpha = ',n);
          if (p <> 0)
            then WritelnStringAndReelDansRapport(', % =', 100.0*n/p,4)
            else WritelnDansRapport('');
          WriteNumDansRapport('coupures_alpha_anticipees = ',a);
          if (n <> 0)
            then WritelnStringAndReelDansRapport(', % =', 100.0*a/n,4)
            else WritelnDansRapport('');


          p := nombre_coupures_beta;
          n := estimations_coupures_beta;
          a := coupures_beta_anticipees;
          WritelnNumDansRapport('nombre_coupures_beta = ',p);
          WriteNumDansRapport('estimations_coupures_beta = ',n);
          if (p <> 0)
            then WritelnStringAndReelDansRapport(', % =', 100.0*n/p,4)
            else WritelnDansRapport('');
          WriteNumDansRapport('coupures_beta_anticipees = ',a);
          if (n <> 0)
            then WritelnStringAndReelDansRapport(', % =', 100.0*a/n,4)
            else WritelnDansRapport('');


          (*
          WritelnNumDansRapport('nombre_statistiques = ',nombre_statistiques);
          WritelnNumDansRapport('nombre_statistiques = ',nombre_statistiques);
          WritelnNumDansRapport('nombre_statistiques = ',nombre_statistiques);

          nombre_coupures_beta       := 0;
          for k := 0 to 64 do
            index_coupure_beta[k]    := 0;
          nombre_coupure_alpha       := 0;
          estimations_coupures_beta  := 0;
          estimations_coupures_alpha := 0;
          *)

        end;
end;

{$ENDC}


END.


(*
nombre_statistiques = 1976212046
H8, best = 127 339 615, legal = 284 999 846, % =44.68
A8, best = 107 615 771, legal = 245 756 404, % =43.78
H1, best = 146 244 136, legal = 335 222 974, % =43.62
A1, best = 151 886 797, legal = 347 701 248, % =43.68

F8, best = 31 519 640, legal = 110 319 449, % =28.57
C8, best = 27 172 577, legal = 99 398 649, % =27.33
H6, best = 36 639 923, legal = 129 968 443, % =28.19
A6, best = 39 938 217, legal = 152 450 245, % =26.19
H3, best = 37 798 831, legal = 143 025 326, % =26.42
A3, best = 31 861 533, legal = 118 444 179, % =26.90
F1, best = 23 401 325, legal = 76 314 757, % =30.66
C1, best = 15 865 410, legal = 58 526 030, % =27.10

F6, best = 1 201 012, legal = 3 300 915, % =36.38
F3, best = 40 918, legal = 115 406, % =35.45

E8, best = 16 134 663, legal = 59 333 732, % =27.19
D8, best = 25 090 125, legal = 86 838 141, % =28.89
H5, best = 36 819 423, legal = 126 169 747, % =29.18
A5, best = 45 621 993, legal = 160 570 752, % =28.41
H4, best = 38 306 028, legal = 139 110 517, % =27.53
A4, best = 43 038 108, legal = 151 414 868, % =28.42
E1, best = 12 392 907, legal = 42 614 738, % =29.08
D1, best = 12 175 672, legal = 43 083 595, % =28.26

E6, best = 248 823, legal = 497 364, % =50.02
F4, best = 722 934, legal = 1 680 795, % =43.01

E7, best = 3 514 882, legal = 14 087 895, % =24.94
D7, best = 10 067 082, legal = 33 113 734, % =30.40
G5, best = 7 655 764, legal = 28 728 264, % =26.64
B5, best = 5 760 729, legal = 21 362 971, % =26.96
G4, best = 10 034 775, legal = 37 919 616, % =26.46
B4, best = 15 054 657, legal = 56 954 481, % =26.43
E2, best = 1 231 042, legal = 3 237 873, % =38.02
D2, best = 12 664 936, legal = 42 322 608, % =29.92

F7, best = 7 415 603, legal = 28 605 687, % =25.92
C7, best = 5 750 344, legal = 25 797 871, % =22.28
G6, best = 8 534 313, legal = 38 251 867, % =22.31
B6, best = 9 659 848, legal = 41 745 433, % =23.13
G3, best = 13 174 995, legal = 58 644 271, % =22.46
F2, best = 6 799 031, legal = 27 495 257, % =24.72
C2, best = 22 661 165, legal = 92 169 209, % =24.58

G8, best = 85 450 688, legal = 317 577 519, % =26.90
B8, best = 54 483 603, legal = 231 300 969, % =23.55
H7, best = 59 026 953, legal = 232 089 622, % =25.43
A7, best = 76 360 863, legal = 306 183 127, % =24.93
H2, best = 98 481 475, legal = 408 397 189, % =24.11
A2, best = 56 489 086, legal = 253 995 379, % =22.24
G1, best = 81 104 004, legal = 341 934 205, % =23.71
B1, best = 86 099 010, legal = 330 229 754, % =26.07

G7, best = 66 907 961, legal = 327 578 011, % =20.42
B7, best = 30 950 445, legal = 156 959 670, % =19.71
G2, best = 44 553 249, legal = 228 091 037, % =19.53
B2, best = 53 150 234, legal = 244 325 817, % =21.75
*)
