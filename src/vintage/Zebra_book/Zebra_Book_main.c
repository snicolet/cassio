#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#include "Zebra_Book.h"
#include "Zebra_Othellier.h"




/************/

 
pascal int afficher_zebra_book(char *file_name) {
 	int C, index ;
 	char s[15] ;
 	int Pos[100] ;
 	short Score_Noir, Score_Blanc, Alt_Move, Alt_Score;
 	unsigned short Flags ;
 	int orientation ; 
 	BookNode node;
 	
 	C = read_binary_database( file_name ) ;
 	
 	if (C > 0) {
     	printf("Read %d nodes\n", C) ;
     	
     	init_othellier_manu_lazard() ;
    	othellier_manu_lazard_draw_othellier() ;
     	while (1) {
     		printf("(Retour, Nouveau, Quit)  > ") ;
     		gets(s) ;
     		printf("\n") ;
     		s[0] = tolower(s[0]) ;
     		if (s[0] == 'q')
     			break ;
     		if (s[0] == 'r')
     			othellier_manu_lazard_go_back() ;
     		else if (s[0] == 'n')
     			init_othellier_manu_lazard() ;
     		else
     			othellier_manu_lazard_joue_coup((s[1]-'0')*10+(s[0]-'a')+1, VIDE) ;
     		othellier_manu_lazard_get_othellier(Pos) ;
     		index = trouver_position_in_zebra_book(Pos, &node, &orientation, file_name, -1) ;
    		othellier_manu_lazard_draw_othellier() ;
    		if (index == -1)
    			printf(" *** Pas dans la biblio...\n\n\n") ;
    		else {
    			extraire_vals_from_zebra_book(index, &node, &Score_Noir, &Score_Blanc, &Alt_Move, &Alt_Score, &Flags) ;
    			if (Flags & FULL_SOLVED) { /* Finale parfaite */
    				if (Score_Noir == 0) {
    					printf("  Score : Nulle\n") ;
    				} else {
    					if (Score_Noir > CONFIRMED_WIN) {
    						if (Flags & BLACK_TO_MOVE)
    							printf("  Score : +%d pour Noir\n", Score_Noir - CONFIRMED_WIN) ;
    						else
    							printf("  Score : -%d pour Blanc\n", Score_Noir - CONFIRMED_WIN) ;
    					} else {
    						if (Flags & BLACK_TO_MOVE)
    							printf("  Score : -%d pour Noir\n", -(Score_Noir + CONFIRMED_WIN)) ;
    						else
    							printf("  Score : +%d pour Blanc\n", -(Score_Noir + CONFIRMED_WIN)) ;
    					}
    				}
    			} else
    			if (Flags & WLD_SOLVED) { /* Finale WLD */
    				if (Score_Noir == 0) {
    					printf("  Score : Nulle\n") ;
    				} else {
    					if (Score_Noir > CONFIRMED_WIN) {
    						if (Flags & BLACK_TO_MOVE)
    							printf("  Score : gain Noir\n") ;
    						else
    							printf("  Score : perdant pour Blanc\n") ;
    					} else {
    						if (Flags & BLACK_TO_MOVE)
    							printf("  Score : perdant pour Noir\n") ;
    						else
    							printf("  Score : gain Blanc\n") ;
    					}
    				}
    			} else
    			if (Score_Noir == NO_SCORE)
    				printf("  Pas de score\n" );
    			 else
    				printf("  Score : %+.2f\n", (Flags & BLACK_TO_MOVE ? Score_Noir/128.0 : -Score_Noir/128.0)) ;
    			
    			if (Alt_Move < 0)
    				printf("  Pas de deviation\n\n") ;
    			else {
    				Alt_Move = symetrise_coup_for_zebra_book( orientation, Alt_Move ) ;
    				printf("  Deviation : %c%c (%+.2f)\n\n", 'a'+Alt_Move%10-1, '0'+Alt_Move/10,
    				       (Flags & BLACK_TO_MOVE ? Alt_Score/128.0 : -Alt_Score/128.0)) ;
    			}
    		}
    	}
    }
	return 0 ;
}





