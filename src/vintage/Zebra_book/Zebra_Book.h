

#pragma options align=packed


#define ZEBRABOOK_FILENAME "Zebra-book.data"



/* Magic numbers for the opening book file format.
   Name convention: Decimals of E. */
#define BOOK_MAGIC1                2718
#define BOOK_MAGIC2                2818
/* In file MAGIC.H */

/* Values denoting absent moves and scores */
#define NONE                      -1
#define NO_MOVE                   -1
#define POSITION_EXHAUSTED        -2
#define NO_SCORE                  9999
#define CONFIRMED_WIN             30000
#define UNWANTED_DRAW             (CONFIRMED_WIN - 1)
#define INFINITE_WIN              32000
#define INFINITE_SPREAD           (1000 * 128)

/* Flag bits and shifts*/
#define NULL_MOVE                 0
#define BLACK_TO_MOVE             1
#define WHITE_TO_MOVE             2
#define WLD_SOLVED                4
#define NOT_TRAVERSED             8
#define FULL_SOLVED               16
#define PRIVATE_NODE              32
#define DEPTH_SHIFT               10

/* This is not a true flag bit but used in the context of generating
   book moves; it must be different from all flag bits though. */
#define DEVIATION                 64
/* In file OSFBOOK.H */


/* Voici les conventions pour le contenu des cases de la position         */
/* Un othellier = int Pos[100] avec les valeurs ci-dessous pour les cases */
/* a1 = 11, a8 = 18...                                                    */
#define VIDE		  0
#define NOIR		  1
#define BLANC		  2


/* La structure d'un element de la table des positions dans la fichier  */
/* Attention : bien penser ˆ changer aussi la dŽfinition en Pascal dans */
/*             Zebra_to_Cassio.p si le format change !                  */ 
typedef struct {
  int hash1;
  int hash2;
  short black_minimax_score;
  short white_minimax_score;
  short best_alternative_move;
  short alternative_score;
  unsigned short flags;
} BookNode;
/* hash1 et hash2 sont les valeurs de hash calculees sur la position          */
/* les trois scores sont calcules comme suit :                                */
/* Alternative_move donne la meilleure alternative qui n'est pas dans la      */
/* table des positions (attention a l'orientation)                            */
/* Remarque : ce coup amenant a une feuille, celle-ci n'est PAS dans          */
/* la table ; normal, on y aurait aucune info supplementaire                  */
/* Pour avoir tous les coups ayant une evaluation a partir d'une position     */
/* donnee, il faut regarder tous les coups legaux, voir si la position        */
/* resultante existe dans la table [et recuperer son evaluation] mais aussi   */
/* afficher le Alternative_move [avec son eval]                               */


/* Prototypes */

pascal int afficher_zebra_book(char *file_name) ;
/* Lit la bibliotheque dont on donne le nom en parametre       */
/* et permet de la consulter interactivement en mode texte     */


pascal void get_zebra_node(int iindex, BookNode* node) ;
/* Lit le tableau des positions                                       */
/* Renvoie nodeTable[index] dans la variable &node                    */

pascal int read_binary_database( char * ) ;
/* Lit le fichier de base dont on passe le nom en parametre           */
/* Le fichier doit avoir un format de nombres Macintosh et pas Intel. */
/* La fonction va appeler "prepare_hash()" pour preparer les valeurs  */
/* des tableaux de hash.                                              */
/* Renvoie le nombre de positions dans le fichier.                    */
 
 
pascal int trouver_position_in_zebra_book( int *, BookNode *, int *, char *, int) ;
/* Renvoie l'index de la position dans la table                 */
/* Ainsi que son orientation (cf. HashPattern.h)                */
/* Renvoie -1 si la position n'existe pas dans la table         */
/* Pour l'instant, est implementee comme recherche dichotomique */
/* de 1 a NbrElements.                                          */


pascal void extraire_vals_from_zebra_book(int , BookNode *, short *, short *, short *, short *, unsigned short *) ;
/* extrait les valeurs d'un element de la table des positions */
/* a partir de l'index. Renvoie Score_Noir, Score_Blanc,      */
/* Coup_Alt, Score_Alt, Flags                                 */


pascal int symetrise_coup_for_zebra_book( int orient, int move) ;
/* Symetrise un coup en fonction d'une orientation                       */
/* Celle-ci indique la symetrie a effectuer pour retomber sur nos pattes */
/* 0 =  b1 -> b1 (Pas de symetrie)                                       */      
/* 1 =  g1 -> b1 (symetrie axe vertical)                                 */
/* 2 =  g8 -> b1 (symetrie centrale)                                     */
/* 3 =  b8 -> b1 (symetrie axe horizontal)                               */
/* 4 =  a2 -> b1 (symetrie diagonale 1)                                  */
/* 5 =  a7 -> b1 (symetrie axe horizontal + diagonale 1)                 */
/* 6 =  h7 -> b1 (symetrie diagonale 2)                                  */
/* 7 =  h2 -> b1 (symetrie axe horizontal + diagonale 2)                 */


pascal int number_of_positions_in_zebra_book();
/* Renvoie le nombre de positions dans le fichier Zebra-book.data         */


pascal int get_number_of_positions_in_zebra_book_from_disk();
/* Renvoie le nombre de positions dans le fichier Zebra-book.data         */


int interpolation_index(int low, int high, int pos_hash1, int pos_hash2, int low_hash1, int low_hash2, int high_hash1, int high_hash2);
/* Foncton d'interpolation pour la recherche dans une table triee */


pascal int lecture_zebra_book_interrompue_par_evenement();
/* Renvoie 1 si on a recu un evenement (souris, clavier, etc), 0 sinon    */


pascal int cassio_must_get_zebra_nodes_from_disk();
/* Renvoie 1 si Cassio doit lire le fichier Zebra-book.data               */
/* en acces direct a chaque coup.                                         */
/* Renvoie 0 sinon, c'est-a-dire si Cassio le charge en memoire           */
/* au debut et la garde en memoire ensuite (plus rapide mais              */
/* necessite plus de memoire :-(  )                                       */


pascal void get_zebra_node_from_disk(int index, BookNode* node);
/* Renvoie dans node l'enregistrement index du fichier zebra-book.data    */


pascal void swap_endianess_of_zebra_node( BookNode* node);
/* Change l'endianess des entiers dans un enregistrement BookNode         */


pascal void swap_endianess_of_short_for_zebra( short *n);
pascal void swap_endianess_of_int_for_zebra( int *n);
/* Renvoient les representations dans l'autre endianess de l'argument     */



pascal int zebra_node_est_present_dans_le_cache(int index, BookNode* node);
/* Renvoie 1 si on a trouve l'enregistrement de numero index              */
/* dans le cache, auquel cas cet enregistrement est aussi renvoye         */
/* dans *node                                                             */


pascal void ajouter_zebra_node_dans_le_cache_des_presents(int index, BookNode* node);
/* Met un enregistrement dans le cache */


pascal void enlever_zebra_node_dans_cache_des_presents(int index);
/* Enleve un enregistrement dans le cache */


pascal void writeln_zebra_node_dans_rapport(int index, BookNode* node);
/* Ecrit un enregistrement dans le rapport */


