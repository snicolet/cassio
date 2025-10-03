/* File HashPattern.h */

/* Prototypes des fonctions */
pascal void prepare_zebra_hash( void ) ;
pascal void get_zebra_hash( int* , int *, int *, int *) ;
pascal static void compute_zebra_line_patterns( int * ) ;

/* UTILISATION */

/* Appeler prepare_hash() pour initialiser les tables de hashage        */
/*                                                                      */
/* Appeler get_hash() qui renvoie les deux hashs de la position         */
/* Le premier parametre est l'othellier                                 */
/*   -- Pos = int* avec a1=11, a8=18...                                 */
/*   -- VIDE = 0, NOIR = 1, BLANC = 2                                   */
/* Le dernier parametre est l'orientation de la position dans la table  */
/* Cela indique la symetrie a effectuer pour retomber sur nos pattes    */
/* 0 =  b1 -> b1 (Pas de symetrie)                                      */      
/* 1 =  g1 -> b1 (symetrie axe vertical)                                */
/* 2 =  g8 -> b1 (symetrie centrale)                                    */
/* 3 =  b8 -> b1 (symetrie axe horizontal)                              */
/* 4 =  a2 -> b1 (symetrie diagonale 1)                                 */
/* 5 =  a7 -> b1 (symetrie axe horizontal + diagonale 1)                */
/* 6 =  h7 -> b1 (symetrie diagonale 2)                                 */
/* 7 =  h2 -> b1 (symetrie axe horizontal + diagonale 2)                */





