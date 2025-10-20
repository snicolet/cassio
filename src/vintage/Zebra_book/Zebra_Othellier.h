/* Définition pour une classe d'Othelliers… */

/* D'abord quelques #defines pour plus de clarte. */

#define PASS		 99
#define NOIR		  1
#define BLANC		  2
#define VIDE		  0
#define BIDON		  3
#define SPECIAL       4

#define ADVERSAIRE( color )  ((NOIR + BLANC) - (color))


/* L'othellier est code par les cases 0 a 99. a1=11, b1=12… case = 10*ligne + colonne */


	     /* cree les variables + position de depart. Permet de reinitialise le jeu. */
void init_othellier_manu_lazard(void) ;

		 /* Teste si un coup est legal (renvoie le nombre de pions retournes) */
		 /* pour la couleur en parametre. */
short othellier_manu_lazard_coup_est_legal(int , int ) ;
		
		 /* Test et eventuellement joue le coup en param. avec la couleur en param. */
		 /* renvoie Legal(coup, coul). */
		 /* Si la couleur est VIDE, on prend la couleur qui doit jouer.		*/
short othellier_manu_lazard_joue_coup(int , int ) ;

		 /* Renvoie 0 si la couleur passee en parametre peut jouer, sinon renvoie 1. */
short othellier_manu_lazard_check_pass(int) ;

		 /* Pour les trois fonctions precedentes, si couleur=VIDE, on prend la */
		 /* couleur de la variable toMove, mise à jour a chaque coup joue. */
		
		 /* Renvoie 1 si la partie est finie. */
short othellier_manu_lazard_partie_est_finie(void) ;

		 /*	Revient en arriere d'un coup */	
		 /* Renvoie le numero du prochain coup */
short othellier_manu_lazard_go_back() ;

		 /* Pos, qui est int Pos[100], se voit egal a la position courante (Board[100]). */
void othellier_manu_lazard_get_othellier(int *Pos) ;
		
void othellier_manu_lazard_draw_othellier(void) ;

