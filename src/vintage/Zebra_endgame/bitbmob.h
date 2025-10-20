/*
   File:          bitbmob.h

   Created:       November 22, 1999

   Modified:      December 25, 2002

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:
*/



#ifndef BITBMOB_H
#define BITBMOB_H



//#include "bitboard.h"
#include "endgame_four_empties.h"
//#include "end.h"



void
init_mmx( void );



int
weighted_mobility( const BitBoard my_bits,
		   const BitBoard opp_bits );



int
bitboard_mobility( const BitBoard my_bits,
		   const BitBoard opp_bits );


pascal int
bitboard_mobility_with_zebra_mmx( unsigned int my_bits_low,
                                  unsigned int my_bits_high,
                                  unsigned int opp_bits_low,
                                  unsigned int opp_bits_high);


#endif  /* BITBMOB_H */
