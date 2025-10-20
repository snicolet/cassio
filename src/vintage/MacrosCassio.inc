
(*

{$DEFINEC ATOMIC_ADD_32( theAmount, theValue )          begin foo_bar_atomic_register := OSAtomicAdd32Ptr( theAmount, theValue ); end }
{$DEFINEC ATOMIC_ADD_32_BARRIER( theAmount, theValue )  begin foo_bar_atomic_register := OSAtomicAdd32BarrierPtr( theAmount, theValue ); end }
{$DEFINEC ATOMIC_INCREMENT_32( theValue )               begin foo_bar_atomic_register := OSAtomicAdd32Ptr( +1, theValue ); end }
{$DEFINEC ATOMIC_INCREMENT_32_BARRIER( theValue )       begin foo_bar_atomic_register := OSAtomicAdd32BarrierPtr( +1, theValue ); end }
{$DEFINEC ATOMIC_DECREMENT_32( theValue )               begin foo_bar_atomic_register := OSAtomicAdd32Ptr( -1, theValue ); end }
{$DEFINEC ATOMIC_DECREMENT_32_BARRIER( theValue )       begin foo_bar_atomic_register := OSAtomicAdd32BarrierPtr( -1, theValue ); end }
{$DEFINEC ATOMIC_COMPARE_AND_SWAP_32( oldValue, newValue, theValue )         (OSAtomicCompareAndSwap32Ptr( oldValue , newValue ,  theValue )) }
{$DEFINEC ATOMIC_COMPARE_AND_SWAP_32_BARRIER( oldValue, newValue, theValue ) (OSAtomicCompareAndSwap32BarrierPtr( oldValue ,  newValue ,  theValue )) }
{$DEFINEC OS_MEMORY_BARRIER   OSMemoryBarrierPtr }

*)



{$DEFINEC ATOMIC_ADD_32( theAmount, theValue )          begin foo_bar_atomic_register := OSAtomicAdd32Ptr( theAmount, theValue ); end }
{$DEFINEC ATOMIC_ADD_32_BARRIER( theAmount, theValue )  begin foo_bar_atomic_register := OSAtomicAdd32Ptr( theAmount, theValue ); end }
{$DEFINEC ATOMIC_INCREMENT_32( theValue )               begin foo_bar_atomic_register := OSAtomicAdd32Ptr( +1, theValue ); end }
{$DEFINEC ATOMIC_INCREMENT_32_BARRIER( theValue )       begin foo_bar_atomic_register := OSAtomicAdd32Ptr( +1, theValue ); end }
{$DEFINEC ATOMIC_DECREMENT_32( theValue )               begin foo_bar_atomic_register := OSAtomicAdd32Ptr( -1, theValue ); end }
{$DEFINEC ATOMIC_DECREMENT_32_BARRIER( theValue )       begin foo_bar_atomic_register := OSAtomicAdd32Ptr( -1, theValue ); end }
{$DEFINEC ATOMIC_COMPARE_AND_SWAP_32( oldValue, newValue, theValue )         (OSAtomicCompareAndSwap32Ptr( oldValue , newValue ,  theValue )) }
{$DEFINEC ATOMIC_COMPARE_AND_SWAP_32_BARRIER( oldValue, newValue, theValue ) (OSAtomicCompareAndSwap32Ptr( oldValue , newValue ,  theValue )) }
{$DEFINEC OS_MEMORY_BARRIER   begin end }




{$DEFINEC ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,square,bit_case_vide,leading_zeros) iterateur : UInt32; square : UInt32 ; bit_case_vide : UInt32 ; leading_zeros : UInt32}
{$DEFINEC REPEAT_ITERER_LISTE_CASES_VIDES(listeArrivee,iterateur)  begin iterateur := (listeArrivee); repeat }
{$DEFINEC GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,square,leadingZeros)  begin   bitCaseVide := iterateur and (not(iterateur - 1)); SAFE_COUNT_LEADING_ZEROS(bitCaseVide, leadingZeros); square := gTableBitListeBitboardToSquare[leadingZeros]; iterateur := iterateur - bitCaseVide; end }
{$DEFINEC GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE(listeBitboard,square1,square2)  begin  bitCaseVide := listeBitboard and (not(listeBitboard - 1)); SAFE_COUNT_LEADING_ZEROS(bitCaseVide, leadingZeros); square1 := gTableBitListeBitboardToSquare[leadingZeros]; SAFE_COUNT_LEADING_ZEROS(listeBitboard, leadingZeros2); square2 := gTableBitListeBitboardToSquare[leadingZeros2];  end }

{$DEFINEC OLD_GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,square,leadingZeros)  begin   bitCaseVide := iterateur and (not(iterateur - 1));  if (bitCaseVide and $FFFF8000) <> 0 then leadingZeros := COUNT_LEADING_ZEROS(bitCaseVide shr 15) - 15 else leadingZeros := COUNT_LEADING_ZEROS(bitCaseVide); square := gTableBitListeBitboardToSquare[leadingZeros]; iterateur := iterateur - bitCaseVide; end }
{$DEFINEC OLD_GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE(listeBitboard,square1,square2)  begin  bitCaseVide := listeBitboard and (not(listeBitboard - 1)); if (bitCaseVide and $FFFF8000) <> 0 then leadingZeros := COUNT_LEADING_ZEROS(bitCaseVide shr 15) - 15 else leadingZeros := COUNT_LEADING_ZEROS(bitCaseVide); square1 := gTableBitListeBitboardToSquare[leadingZeros]; if (listeBitboard and $FFFF8000) <> 0 then leadingZeros2 := COUNT_LEADING_ZEROS(listeBitboard shr 15) - 15 else leadingZeros2 := COUNT_LEADING_ZEROS(listeBitboard); square2 := gTableBitListeBitboardToSquare[leadingZeros2];  end }


{$DEFINEC COUP_EST_DANS_UNE_ZONE_PAIRE(leadingZeros,vecteurParite)  (BAnd(vecteurParite,gTableBitListeBitboardConstanteDePariteDeSquare[leadingZeros]) = 0) }
{$DEFINEC COUP_EST_DANS_UNE_ZONE_IMPAIRE(leadingZeros,vecteurParite)  (BAnd(vecteurParite,gTableBitListeBitboardConstanteDePariteDeSquare[leadingZeros]) <> 0) }
{$DEFINEC REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeArrivee,bitCaseVide) (listeArrivee - bitCaseVide) }
{$DEFINEC REMOVE_CASE_VIDE_FROM_LISTE(listeArrivee,square) (listeArrivee - gTableSquareToBitCaseVidePourListeBiboard[square]) }
{$DEFINEC UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur)  until (iterateur = 0); end }


{$definec packed_thor_accessors_are_macros 1}
{$ifc packed_thor_accessors_are_macros }
{$definec GET_NTH_MOVE_OF_PACKED_GAME(whichGame,n,fonctionAppelante)  (whichGame.theMoves[(n)]) }
{$definec SET_NTH_MOVE_OF_PACKED_GAME(whichGame,n,whichSquare)  begin whichGame.theMoves[(n)] := (whichSquare) end }
{$definec GET_LENGTH_OF_PACKED_GAME(whichGame) (whichGame.theMoves[0]) }
{$endc}


{$DEFINEC USE_PROFILER_OUVERTURE_FICHIERS FALSE}
{$DEFINEC USE_PROFILER_DISPOSE_GAME_TREE_GLOBAL   FALSE}
{$DEFINEC USE_PROFILER_FINALE_FAST   FALSE}
{$DEFINEC USE_PROFILER_MILIEU_DE_PARTIE   FALSE}
{$DEFINEC USE_PROFILER_RECHHERCHE_SOLITAIRES   FALSE}
{$DEFINEC USE_PROFILER_SMART_GAME_BOARD   FALSE}


{$DEFINEC UTILISE_MINIPROFILER_POUR_MILIEU    false}
{$DEFINEC UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME    false}
{$DEFINEC UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD    false}
{$DEFINEC UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD    false}
(*
{$DEFINEC UTILISE_MINIPROFILER := (UTILISE_MINIPROFILER_POUR_MILIEU OR UTILISE_MINIPROFILER_POUR_MILIEU_DANS_ENDGAME OR UTILISE_MINIPROFILER_POUR_LANCEUR_BITBOARD OR UTILISE_MINIPROFILER_LECTURE_SMART_GAME_BOARD) }
*)
{$DEFINEC UTILISE_MINIPROFILER    FALSE}

{$DEFINEC DEBUG_BITBOARD_ALPHA_BETA   FALSE}

{$DEFINEC AVEC_DEBUG_UNROLLED FALSE}
{$DEFINEC COLLECTER_STATISTIQUES_ORDRE_OPTIMUM_DES_CASES FALSE}
{$DEFINEC COLLECTER_STATISTIQUES_STATUT_KNUTH_DES_NOEUDS FALSE}

{$DEFINEC USING_DEUXCASESVIDESBITBOARDFAST TRUE }
{$DEFINEC DEBUG_DEUXCASESVIDESBITBOARDFAST FALSE }

{$DEFINEC DEBUG_TRI_FASTEST_BITBOARD FALSE }

(* bitboards use the hash table heuristics *)
{$DEFINEC BITBOARD_USE_HASH_TABLE TRUE}

{$DEFINEC ModifPlatPlausible(square,opp_low,opp_high) (BOr(BAnd(masque_voisinage[square].high,opp_high),BAnd(masque_voisinage[square].low,opp_low)) <> 0) }

{$DEFINEC AVEC_DEBUG_QUATRE_CASES_VIDES   FALSE}
{$DEFINEC USING_QUATRECASESVIDESBITBOARDFAST   TRUE }


{$DEFINEC USE_DEBUG_STEP_BY_STEP    FALSE}
{$DEFINEC USE_VERIFICATION_ASSERTIONS_BORNES    FALSE}


{$DEFINEC NBRE_NOEUDS_EXACT_DANS_ENDGAME   FALSE }
{$DEFINEC COLLECTE_STATS_NBRE_NOEUDS_ENDGAME   FALSE }


{$DEFINEC AVEC_MESURE_DE_PARALLELISME   FALSE }
{$DEFINEC AVEC_MESURE_MICROSECONDES   FALSE }


{$IFC not defined CASSIO_DEBUG_TRACE }
{$DEFINEC CASSIO_DEBUG_TRACE false }
{$ENDC }


{$IFC NOT(CASSIO_DEBUG_TRACE) }
{$DEFINEC TraceLog(s) begin end }
{$ELSEC }
{$DEFINEC TraceLog(s) WriteInTraceLog(s) }
{$ENDC }


{$DEFINEC DoNothing  begin end }





































