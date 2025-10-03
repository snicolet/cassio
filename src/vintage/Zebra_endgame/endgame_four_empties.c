
#include <stdlib.h>

#include "bitbcnt.h"
#include "bitbtest.h"
#include "endgame_four_empties.h"





static BitBoard neighborhood_mask[100];
const unsigned int quadrant_mask[100] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};


/*
  TESTFLIPS_WRAPPER
  Checks if SQ is a valid move by
  (1) verifying that there exists a neighboring opponent disc,
  (2) verifying that the move flips some disc.
*/

INLINE static int
TestFlips_wrapper( int sq,
		   BitBoard my_bits,
		   BitBoard opp_bits,
		   BitBoard *flips ) {
  int flipped;

  if ( ((neighborhood_mask[sq].high & opp_bits.high) |
       (neighborhood_mask[sq].low & opp_bits.low)) != 0 )
    flipped = TestFlips_bitboard[sq - 11]( my_bits.high, my_bits.low, opp_bits.high, opp_bits.low, flips );
  else
    flipped = 0;

  return flipped;
}


  
pascal int
solve_two_empty( BitBoard my_bits,
		 BitBoard opp_bits,
		 int sq1,
		 int sq2,
		 int alpha,
		 int beta,
		 int disc_diff,
		 int pass_legal ) {
  int score = -INFINITE_EVAL;
  int flipped;
  int ev;
  BitBoard flips;

  // INCREMENT_COUNTER( nodes );

  /* Overall strategy: Lazy evaluation whenever possible, i.e., don't
     update bitboards until they are used. Also look at alpha and beta
     in order to perform strength reduction: Feasibility testing is
     faster than counting number of flips. */

  /* Try the first of the two empty squares... */

  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits, &flips);
  if ( flipped != 0 ) {  /* SQ1 feasible for me */
    // INCREMENT_COUNTER( nodes );

    ev = disc_diff + 2 * flipped;


      flipped = CountFlips_bitboard[sq2 - 11]( opp_bits.high & ~flips.high, opp_bits.low & ~flips.low );
      if ( flipped != 0 )
	ev -= 2 * flipped;
      else {  /* He passes, check if SQ2 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq2 - 11]( flips.high, flips.low );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq2 - 11]( flips.high, flips.low );
	    if ( flipped != 0 )  /* SQ2 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ2 will end up empty, game over */
	  }
	}
      }


    /* Being legal, the first move is the best so far */
    score = ev;
    if ( score > alpha ) {
      if ( score >= beta )
	return score;
      alpha = score;
    }
  }

  /* ...and then the second */

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits, &flips);
  if ( flipped != 0 ) {  /* SQ2 feasible for me */
   // INCREMENT_COUNTER( nodes );

    ev = disc_diff + 2 * flipped;

      flipped = CountFlips_bitboard[sq1 - 11]( opp_bits.high & ~flips.high, opp_bits.low & ~flips.low );
      if ( flipped != 0 )  /* SQ1 feasible for him, game over */
	ev -= 2 * flipped;
      else {  /* He passes, check if SQ1 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq1 - 11]( flips.high, flips.low );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq1 - 11]( flips.high, flips.low );
	    if ( flipped != 0 )  /* SQ1 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ1 will end up empty, game over */
	  }
	}
      }


    /* If the second move is better than the first (if that move was legal),
       its score is the score of the position */
    if ( ev >= score )
      return ev;
  }

  /* If both SQ1 and SQ2 are illegal I have to pass,
     otherwise return the best score. */

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Two empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 2;
      if ( disc_diff < 0 )
	return disc_diff - 2;
      return 0;
    }
    else
      return -solve_two_empty( opp_bits, my_bits, sq1, sq2, -beta,
			       -alpha, -disc_diff, 0 /*FALSE*/ );
  }
  else
    return score;
}


static int
solve_three_empty( BitBoard my_bits,
		   BitBoard opp_bits,
		   int sq1,
		   int sq2,
		   int sq3,
		   int alpha,
		   int beta,
		   int disc_diff,
		   int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int flipped;
  int new_disc_diff;
  int ev;
  BitBoard flips;

 //  INCREMENT_COUNTER( nodes );

  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    score = -solve_two_empty( new_opp_bits, flips, sq2, sq3,
			      -beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( score >= beta )
      return score;
    else if ( score > alpha )
      alpha = score;
  }

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_two_empty( new_opp_bits, flips, sq1, sq3,
			   -beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq3, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_two_empty( new_opp_bits, flips, sq1, sq2,
			   -beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( ev >= score )
      return ev;
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Three empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 3;
      if ( disc_diff < 0 )
	return disc_diff - 3;
      return 0;  /* Can't reach this code, only keep it for symmetry */
    }
    else
      return -solve_three_empty( opp_bits, my_bits, sq1, sq2, sq3,
				 -beta, -alpha, -disc_diff, 0 /*FALSE*/ );
  }

  return score;
}



pascal int
solve_four_empty( BitBoard my_bits,
		  BitBoard opp_bits,
		  int sq1,
		  int sq2,
		  int sq3,
		  int sq4,
		  int alpha,
		  int beta,
		  int disc_diff,
		  int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int flipped;
  int new_disc_diff;
  int ev;
  BitBoard flips;

//  INCREMENT_COUNTER( nodes );

  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    score = -solve_three_empty( new_opp_bits, flips, sq2, sq3, sq4,
				-beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( score >= beta )
      return score;
    else if ( score > alpha )
      alpha = score;
  }

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, flips, sq1, sq3, sq4,
			     -beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq3, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, flips, sq1, sq2, sq4,
			     -beta, -alpha, new_disc_diff,  1 /*TRUE*/ );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq4, my_bits, opp_bits, &flips );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, flips, sq1, sq2, sq3,
			     -beta, -alpha, new_disc_diff, 1 /*TRUE*/ );
    if ( ev >= score )
      return ev;
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Four empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 4;
      if ( disc_diff < 0 )
	return disc_diff - 4;
      return 0;
    }
    else
      return -solve_four_empty( opp_bits, my_bits, sq1, sq2, sq3, sq4,
				-beta, -alpha, -disc_diff, 0 /*FALSE*/ );
  }

  return score;
}


/* Calculate the neighborhood masks */
pascal void calculate_neighborhood_mask( void )
{

  int i, j;
  static const int dir_shift[8] = {1, -1, 7, -7, 8, -8, 9, -9};
  const int dir_mask[100] = {
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,  81,  81,  87,  87,  87,  87,  22,  22,   0,
  0,  81,  81,  87,  87,  87,  87,  22,  22,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0,  41,  41, 171, 171, 171, 171, 162, 162,   0,
  0,  41,  41, 171, 171, 171, 171, 162, 162,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

  
  for ( i = 1; i <= 8; i++ )
    for ( j = 1; j <= 8; j++ ) {
      /* Create the neighborhood mask for the square POS */

      int pos = 10 * i + j;
      int shift = 8 * (i - 1) + (j - 1);
      unsigned int k;

      neighborhood_mask[pos].low = 0;
      neighborhood_mask[pos].high = 0;

      for ( k = 0; k < 8; k++ )
	if ( dir_mask[pos] & (1 << k) ) {
	  unsigned int neighbor = shift + dir_shift[k];
	  if ( neighbor < 32 )
	    neighborhood_mask[pos].low |= (1 << neighbor);
	  else
	    neighborhood_mask[pos].high |= (1 << (neighbor - 32));
	}
    }
}
