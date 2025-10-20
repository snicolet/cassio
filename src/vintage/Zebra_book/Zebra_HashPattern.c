#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include "Zebra_myrandom.h"
#include "Zebra_HashPattern.h"

/* Global variables */

int Zebra_pow3[10] = { 1, 3, 9, 27, 81, 243, 729, 2187, 6561, 19683 };
static int Zebra_line_hash[2][8][6561]; /* Contient les valeurs de hash */

/* The patterns describing the current state of the board. */
/* and all symmetries */

int Zebra_row_patt[8];       /* b1 -> b1 */
int Zebra_col_patt[8];       /* b1 -> a2 */
int Zebra_row_patt_symV[8];  /* b1 -> g1 */
int Zebra_col_patt_symV[8];  /* b1 -> h2 */
int Zebra_row_patt_symH[8];  /* b1 -> b8 */
int Zebra_col_patt_symH[8];  /* b1 -> a7 */
int Zebra_col_patt_symD[8];  /* b1 -> h7 */
int Zebra_row_patt_symD[8];  /* b1 -> g8 */


/*
   PREPARE_HASH
   Compute the position hash codes.
*/
pascal void prepare_zebra_hash( void ) {
	int i, j, k;

	/* The hash keys are static, hence the same keys must be
		produced every time the program is run. */
	my_srandom( 0 );

	for ( i = 0; i < 2; i++ )
		for ( j = 0; j < 8; j++ )
			for ( k = 0; k < 6561; k++ )
				Zebra_line_hash[i][j][k] = (my_random() % 2) ? my_random() : -my_random();
}


/*
   GET_HASH
   Return the hash values for the current board position.
   The position is rotated so that the 64-bit hash value
   is minimized among all rotations. This ensures detection
   of all transpositions.
   See also init_maps().
*/

pascal void get_zebra_hash( int *board, int *val0, int *val1, int *orientation ) {
	int i, j;
	int min_map;
	int min_hash0, min_hash1;
	int out[8][2];

	/* Calculate the 8 different 64-bit hash values for the
		different rotations. */

	compute_zebra_line_patterns( board );
	/* recuperation des valeurs pour les 8 rangees et leurs symetries */

	for ( i = 0; i < 8; i++ )
		for ( j = 0; j < 2; j++ )
			out[i][j] = 0;
	for ( i = 0; i < 8; i++ ) {
    	/* b1 -> b1 */
		out[0][0] ^=  Zebra_line_hash[0][i][Zebra_row_patt[i]]; /* Calcul hash_val1 */
		out[0][1] ^=  Zebra_line_hash[1][i][Zebra_row_patt[i]]; /* Calcul hash_val2 */
    	
		/* b1 -> g1 */
		out[1][0] ^=  Zebra_line_hash[0][i][Zebra_row_patt_symV[i]]; /* Calcul hash_val1 */
		out[1][1] ^=  Zebra_line_hash[1][i][Zebra_row_patt_symV[i]]; /* Calcul hash_val2 */

		/* b1 -> g8 */
		out[2][0] ^=  Zebra_line_hash[0][i][Zebra_row_patt_symD[i]]; /* Calcul hash_val1 */
		out[2][1] ^=  Zebra_line_hash[1][i][Zebra_row_patt_symD[i]]; /* Calcul hash_val2 */

		/* b1 -> b8 */
		out[3][0] ^=  Zebra_line_hash[0][i][Zebra_row_patt_symH[i]]; /* Calcul hash_val1 */
		out[3][1] ^=  Zebra_line_hash[1][i][Zebra_row_patt_symH[i]]; /* Calcul hash_val2 */

		/* b1 -> a2 */
		out[4][0] ^=  Zebra_line_hash[0][i][Zebra_col_patt[i]]; /* Calcul hash_val1 */
		out[4][1] ^=  Zebra_line_hash[1][i][Zebra_col_patt[i]]; /* Calcul hash_val2 */

		/* b1 -> a7 */
		out[5][0] ^=  Zebra_line_hash[0][i][Zebra_col_patt_symH[i]]; /* Calcul hash_val1 */
		out[5][1] ^=  Zebra_line_hash[1][i][Zebra_col_patt_symH[i]]; /* Calcul hash_val2 */

		/* b1 -> h7 */
		out[6][0] ^=  Zebra_line_hash[0][i][Zebra_col_patt_symD[i]]; /* Calcul hash_val1 */
		out[6][1] ^=  Zebra_line_hash[1][i][Zebra_col_patt_symD[i]]; /* Calcul hash_val2 */

		/* b1 -> h2 */
		out[7][0] ^=  Zebra_line_hash[0][i][Zebra_col_patt_symV[i]]; /* Calcul hash_val1 */
		out[7][1] ^=  Zebra_line_hash[1][i][Zebra_col_patt_symV[i]]; /* Calcul hash_val2 */
	}

	/* Find the rotation minimizing the hash index.
		If two hash indices are equal, map number is implicitly used
		as tie-breaker. */

	min_map = 0;
	min_hash0 = out[0][0];
	min_hash1 = out[0][1];
	for ( i = 1; i < 8; i++)
		if ( (out[i][0] < min_hash0) ||
		     ((out[i][0] == min_hash0) && (out[i][1] < min_hash1)) ) {
			min_map = i;
			min_hash0 = out[i][0];
			min_hash1 = out[i][1];
		}

	*val0 = abs( min_hash0 );
	*val1 = abs( min_hash1 );
	*orientation = min_map ;
}


/*
   COMPUTE_LINE_PATTERNS
   Translate the current board configuration into patterns.
*/

pascal static void compute_zebra_line_patterns( int *in_board ) {
	int i, j;
	int pos;
	int mask;

	for ( i = 0; i < 8; i++ ) {
		Zebra_row_patt[i] = Zebra_row_patt_symH[i] = 0;
		Zebra_col_patt[i] = Zebra_col_patt_symH[i] = 0;
		Zebra_row_patt_symV[i] = Zebra_row_patt_symD[i] = 0;
		Zebra_col_patt_symV[i] = Zebra_col_patt_symD[i] = 0;
	}

	for ( i = 1; i <= 8; i++ )
		for ( j = 1; j <= 8; j++ ) {
			pos = 10 * i + j;
			mask = in_board[pos] ; /* valeur du pion 0 = vide, 1 = noir, 2 = blanc */
			assert(0 <= mask && mask < 3) ;

			Zebra_row_patt[i-1]      += mask * Zebra_pow3[j-1];
			Zebra_row_patt_symH[8-i] += mask * Zebra_pow3[j-1];

			Zebra_col_patt[j-1]      += mask * Zebra_pow3[i-1];
			Zebra_col_patt_symV[8-j] += mask * Zebra_pow3[i-1];

			Zebra_row_patt_symV[i-1] += mask * Zebra_pow3[8-j];
			Zebra_col_patt_symH[j-1] += mask * Zebra_pow3[8-i];

			Zebra_col_patt_symD[8-j] += mask * Zebra_pow3[8-i];
			Zebra_row_patt_symD[8-i] += mask * Zebra_pow3[8-j];
		}
}
