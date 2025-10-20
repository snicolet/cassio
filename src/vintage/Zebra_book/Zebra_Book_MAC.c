#ifdef __GCC__
#else
  #pragma options align = packed
#endif



#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <malloc.h>
#include <time.h>


#include "Zebra_Book.h"
#include "Zebra_HashPattern.h"

/************/

static BookNode *nodesTable  = NULL ;     /* La table de toutes les positions */
static int FileNodeCount     = 0;         /* Nombre de positions dans la table */


#define ZEBRA_BOOK_READING_BLOCK         16384


pascal
int read_binary_database( char *file_name ) {
	int i,k,size;
	short magic1, magic2 ;
	FILE *stream;
	int nodeCountStoredInFile;
	int number_of_blocks;
	size_t size_of_block_in_byte;


	stream = fopen( file_name, "rb" );
	if ( stream == NULL ) {
		/* printf( "Could not open database file: %s\n", file_name ); */
		return (-1) ;
	}

	fread( &magic1, sizeof( short ), 1, stream );
	fread( &magic2, sizeof( short ), 1, stream );
	
	swap_endianess_of_short_for_zebra( &magic1 );
	swap_endianess_of_short_for_zebra( &magic2 );
	
	if ( (magic1 != BOOK_MAGIC1) || (magic2 != BOOK_MAGIC2) ) {
		printf( "Wrong checksum, might be an old version or the wrong format: %s\n", file_name );
	}
	
	
	fread( &nodeCountStoredInFile, sizeof( int ), 1, stream );
	
	swap_endianess_of_int_for_zebra( &nodeCountStoredInFile );
	
	/* printf( "%d nodes in file\n", FileNodeCount) ; */
	
	
	
	
	if (nodesTable)
	  free(nodesTable);
	
	size = nodeCountStoredInFile*sizeof(BookNode);
	nodesTable = malloc(size) ;
	
	
	if (nodesTable) {
	
	    number_of_blocks      = nodeCountStoredInFile / ZEBRA_BOOK_READING_BLOCK;
	    size_of_block_in_byte = sizeof(BookNode) * ZEBRA_BOOK_READING_BLOCK;
	
	    i = 0;  // number of records read
	
	    // Read the file by blocks of ZEBRA_BOOK_READING_BLOCK records
	    for ( k = 1; k < number_of_blocks; k++ ) {
	
	      if (!fread( &nodesTable[i], size_of_block_in_byte, 1 , stream ))
    			 break ;
    	  i += ZEBRA_BOOK_READING_BLOCK;
    	
    	  // check events during the reading of the file (so that Cassio remains responsive)
    	  if (lecture_zebra_book_interrompue_par_evenement()) {
      	    FileNodeCount = 0;
      	    fclose( stream );
      	    return (-1);
      	    }
	    }
	
	    // Read the remaining records
    	for ( i = i; i < nodeCountStoredInFile; i++ ) {
    	  if (!fread( &nodesTable[i], sizeof(BookNode), 1, stream ) )
    			 break ;
    		
    		if (((i % 1024) == 0) && lecture_zebra_book_interrompue_par_evenement()) {
    		    FileNodeCount = 0;
      	    fclose( stream );
      	    return (-1);
      	    }
    	}
    	
  }

	fclose( stream );
	prepare_zebra_hash() ; /* Preparation des valeurs des tables de hash */
	
	if (i != nodeCountStoredInFile) {
		printf(" There was an error reading the Zebra-book.data file.\n") ;
		printf(" i = %d ,  nodeCountStoredInFile = %d \n", i, nodeCountStoredInFile) ;
		printf(" Or maybe allocating %d bytes failed....\n",size) ;
		return (-1);
	}
	
	for ( i = 0; i < nodeCountStoredInFile; i++)
	   swap_endianess_of_zebra_node( &nodesTable[i] );
	
	FileNodeCount = nodeCountStoredInFile;
	
	return nodeCountStoredInFile ;
}



/* Lit le tableau des positions */
/* Renvoie nodeTable[index] dans la variable &node */
pascal
void get_zebra_node(int index, BookNode* node) {

   if (cassio_must_get_zebra_nodes_from_disk())
       {
          if (zebra_node_est_present_dans_le_cache(index, node))
             return;

          get_zebra_node_from_disk(index, node);
          ajouter_zebra_node_dans_le_cache_des_presents(index, node);
       }
   else
       {
          *node = nodesTable[index];
       }
}



/* Fonction d'interpolation pour la recherche dans une table triee */
int interpolation_index(int low, int high, int pos_hash1, int pos_hash2, int low_hash1, int low_hash2, int high_hash1, int high_hash2)
{
  unsigned long long key;
  unsigned long long low_key;
  unsigned long long high_key;
  double alpha;

  key       = pos_hash1 * (1ULL << 32)  + pos_hash2;
  low_key   = low_hash1 * (1ULL << 32)  + low_hash2;
  high_key  = high_hash1 * (1ULL << 32) + high_hash2;

  alpha = (87.5 / 100.0) * (1.0 * (key - low_key)) / (1.0 * (high_key - low_key));

  return (low + alpha * (high - low));
}



/* A partir d'une position, renvoie l'index dans la table des positions. */
/* Ainsi que son orientation (cf. HashPattern.h)                         */
/* Renvoie -1 si la position n'est pas dans la biblio                    */
pascal
int trouver_position_in_zebra_book( int *Pos, BookNode *node, int* orientation, char*  file_name, int probableIndex) {
	int pos_hash1, pos_hash2, i, k ;
	int low, high;
  int low_hash1, high_hash1;
  int low_hash2, high_hash2;
  int searchtrace[110];
  int count = 0;


	if (cassio_must_get_zebra_nodes_from_disk())
	    {
	        if (FileNodeCount <= 0)
	              FileNodeCount = number_of_positions_in_zebra_book();
	    }
	else
	    {
	        if ((FileNodeCount <= 0) || !nodesTable)
	              FileNodeCount = read_binary_database(file_name);
	    }
	
	
	if (FileNodeCount <= 0)
	  return (-1);

	get_zebra_hash( Pos, &pos_hash1, &pos_hash2, orientation ) ; /* Hash de la position */
	
	
  /* Intervalle de recherche */
  low = 0;
  high = FileNodeCount - 1;


  /* Si on a une proposition d'index, on l'essaye en premier ... */
  if ((probableIndex > low) && (probableIndex < high))
      {
          get_zebra_node(probableIndex, node);
          if ((node->hash1 == pos_hash1) && (node->hash2 == pos_hash2))
              return probableIndex ;     /* found  !!  */
      }

  for (i = 0; i < 100; i++)
    searchtrace[i] = -2;

  get_zebra_node(low, node);
  if ((node->hash1 == pos_hash1) && (node->hash2 == pos_hash2))
      return low ;     /* found  !!  */

  low_hash1 = node->hash1;
  low_hash2 = node->hash2;


  get_zebra_node(high, node);
  if ((node->hash1 == pos_hash1) && (node->hash2 == pos_hash2))
      return high ;    /* found  !! */

  high_hash1 = node->hash1;
  high_hash2 = node->hash2;



  /* Verifions que l'index cherchŽ est bien dans l'intervalle [low ... high] ,  */
  /* c'est-a-dire que l'on sort tout de suite si ce n'est pas la cas.            */

  if ((low_hash1 > pos_hash1) || ((low_hash1 == pos_hash1) && (low_hash2 > pos_hash2)))
      return (-1);    /* not found !! */

  if ((high_hash1 < pos_hash1) || ((high_hash1 == pos_hash1) && (high_hash2 < pos_hash2)))
      return (-1);    /* not found !! */


  /* Debut de la recherche par interpolation dans la table ! */

  while ((high - low) > 1) {

      i = interpolation_index(low, high, pos_hash1, pos_hash2, low_hash1, low_hash2, high_hash1, high_hash2);


      if (i <= low)
         i = low + 1;
      if (i >= high)
         i = high - 1;

      if (count < 100)
          searchtrace[count] = i;
      count++;


      get_zebra_node(i, node);
      if ((node->hash1 == pos_hash1) && (node->hash2 == pos_hash2))
           return i ;    /* found !! */

      if ((node->hash1 < pos_hash1) ||
          ((node->hash1 == pos_hash1) && (node->hash2 <= pos_hash2)))
          {
           low = i ;
           low_hash1 = node->hash1;
           low_hash2 = node->hash2;
          }
      else
          {
           high = i ;
           high_hash1 = node->hash1;
           high_hash2 = node->hash2;
          }
  }


  /* pas trouvŽ : effacons la trace dans le cache des presents, puisque */
  /* on a un cache plus efficace specialise dans les positions absentes */


  if (count >= 100)   count = 99;

  if (count >= 1)
      for (k = 0; k < count; k++)
          enlever_zebra_node_dans_cache_des_presents(searchtrace[k]);



	return (-1) ; /* not found... */
}



/* Extrait les valeurs d'un element de la table des noeuds */
pascal
void extraire_vals_from_zebra_book(int indexVal, BookNode *node, short *Score_Noir, short *Score_Blanc, short *Alternative_Move, short *Alternative_Score, unsigned short *Flags) {

	*Score_Noir        = node->black_minimax_score ;
	*Score_Blanc       = node->white_minimax_score ;
	*Alternative_Move  = node->best_alternative_move ;
	*Alternative_Score = node->alternative_score ;
	*Flags             = node->flags ;
	
}

/* Renvoie le coup correspondant a move dans l'orientation consideree */
pascal
int symetrise_coup_for_zebra_book( int orientation, int move ) {
	int c, l ;

	c = move % 10 ; /* numero de colonne */
	l = move / 10 ; /* numero de ligne */
	switch( orientation ) {
		case 0 : return move ;
		case 1 : return 10*l + (9-c) ;
		case 2 : return 10*(9-l) + (9-c) ;
		case 3 : return 10*(9-l) + c ;
		case 4 : return 10*c + l ;
		case 5 : return 10*(9-c) + l ;
		case 6 : return 10*(9-c) + (9-l);
		case 7 : return 10*c + (9-l) ;
		default : printf("BUG in symetrise_coup_for_zebra_book !!") ; exit (1) ;
	}
	return 0 ;
}


pascal
int number_of_positions_in_zebra_book()
{
  if (cassio_must_get_zebra_nodes_from_disk())
     FileNodeCount = get_number_of_positions_in_zebra_book_from_disk();

  if (FileNodeCount > 0)
     return FileNodeCount;
  else
     return 0;
}




