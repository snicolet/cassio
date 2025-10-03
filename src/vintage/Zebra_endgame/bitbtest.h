/*
   File:          bitbtest.h

   Created:       November 22, 1999
   
   Modified:      November 24, 2005

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:
*/



#ifndef BITBTEST_H
#define BITBTEST_H



#include "endgame_four_empties.h"
#include "macros.h"




extern int (REGPARM(2) * const TestFlips_bitboard[78])(unsigned int, unsigned int, unsigned int, unsigned int, BitBoard *);



#endif  /* BITBTEST_H */
