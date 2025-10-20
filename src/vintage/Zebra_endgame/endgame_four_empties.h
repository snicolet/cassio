


#ifndef BITBOARD_H
#define BITBOARD_H


#include "macros.h"	// REGPARM



typedef struct {
  unsigned int high;
  unsigned int low;
} BitBoard;


#define INFINITE_EVAL   1000



#define APPLY_NOT( a ) { \
  a.high = ~a.high; \
  a.low = ~a.low; \
}

#define APPLY_XOR( a, b ) { \
  a.high ^= b.high; \
  a.low ^= b.low; \
}

#define APPLY_OR( a, b ) { \
  a.high |= b.high; \
  a.low |= b.low; \
}

#define APPLY_AND( a, b ) { \
  a.high &= b.high; \
  a.low &= b.low; \
}

#define APPLY_ANDNOT( a, b ) { \
  a.high &= ~b.high; \
  a.low &= ~b.low; \
}

#define FULL_XOR( a, b, c ) { \
  a.high = b.high ^ c.high; \
  a.low = b.low ^ c.low; \
}

#define FULL_OR( a, b, c ) { \
  a.high = b.high | c.high; \
  a.low = b.low | c.low; \
}

#define FULL_AND( a, b, c ) { \
  a.high = b.high & c.high; \
  a.low = b.low & c.low; \
}

#define FULL_ANDNOT( a, b, c ) { \
  a.high = b.high & ~c.high; \
  a.low = b.low & ~c.low; \
}

#define CLEAR( a ) { \
  a.high = 0; \
  a.low = 0; \
}

// prototypes
pascal void calculate_neighborhood_mask( void );

pascal int
solve_two_empty( BitBoard my_bits,
		 BitBoard opp_bits,
		 int sq1,
		 int sq2,
		 int alpha,
		 int beta,
		 int disc_diff,
		 int pass_legal );
		
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
		  int pass_legal );


unsigned int REGPARM(2)
non_iterative_popcount( unsigned int n1, unsigned int n2 );


#endif  /* BITBOARD_H */