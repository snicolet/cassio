/*
 *  EngineCalculations.c
 *
 *  Implementation d'un faux programme d'othello (FakeOthelloEngine)...
 *  Edax ou Roxanne doivent implementer les memes fonctions correctement :-)
 *
 *  Created by Stéphane Nicolet on 03/10/09.
 *
 */

#include <stdio.h>
#include "EngineCalculations.h"
#include "EngineProtocol.h"
#include "EntreeStandard.h"


void* foo_engine_pointer_internal_stuff;
int engine_must_quit = 0;
int engine_must_stop_search = 0;


/*
 *******************************************************************************
 *                                                                             *
 *   engine_init() est appelee pour initialiser le moteur. Le moteur renvoie   *
 *   un pointeur opaque, qu'il pourra ensuite utiliser pour faire sa cuisine   *
 *   interne.                                                                  *
 *                                                                             *
 *******************************************************************************
 */
pascal void* engine_init(void)
{
	engine_must_quit = 0;
	return (foo_engine_pointer_internal_stuff);
}

/*
 *******************************************************************************
 *                                                                             *
 *   engine_stop() est appelee par Cassio pour arreter la reflexion en cours.  *
 *                                                                             *
 *******************************************************************************
 */
pascal void engine_stop(void* engine)
{
	  engine_must_stop_search = 1;
}


/*
 *******************************************************************************
 *                                                                             *
 *   engine_print_results() doit etre appelee le plus souvent possible par le  *
 *   moteur pour tous les resultats partiels significatisf a faire afficher    *
 *   par Cassio.                                                               *
 *                                                                             *
 *******************************************************************************
 */
pascal void engine_print_results(void *engine, char *string)
{
	 Print("%s",string);
}

/*
 *******************************************************************************
 *                                                                             *
 *   engine_free() est appelee par Cassio pour indiquer au moteur qu'il doit   *
 *   quitter.                                                                  *
 *                                                                             *
 *******************************************************************************
 */
pascal void engine_free(void *engine)
{
	engine_must_quit = 1;
	engine_must_stop_search = 1;
}


/*
 *******************************************************************************
 *                                                                             *
 *   engine_midgame_search() est appelee par Cassio lancer une recherche de    *
 *   milieu de partie.                                                         *
 *   Note : dans cette implementation FakeOthelloEngine, je simule simplement  *
 *   une fausse recherche de milieu de partie de 20 secondes !                 *
 *                                                                             *
 *******************************************************************************
 */
pascal float engine_midgame_search(void* engine, const char* position, const float alpha, const float beta, const int depth, const int precision)
{
	engine_must_stop_search = 0;
	
	engine_fake_search(2000);   // 20 seconds
	if (!engine_must_stop_search)
		Print("--X-OOO---X-OO---XXXXXX-XXXXXOO---OXXOO--XXXXO-------O----------O, move D2, depth 20, @55%%, W+3.55 <= v <= W+7.78 , D2B5H4G6H5H7E7H2B2E8F8G8D7D8A7A6H3A8H1H6\n");
	
	return (+4.31);
}


/*
 *******************************************************************************
 *                                                                             *
 *   engine_endgame_search() est appelee par Cassio lancer une recherche de    *
 *   finale.                                                                   *
 *   Note : dans cette implementation FakeOthelloEngine, je simule simplement  *
 *   une fausse recherche de finale de 30 secondes !                           *
 *                                                                             *
 *******************************************************************************
 */
pascal int engine_endgame_search(void* engine, const char* position, const int  alpha, const int beta, const int precision)
{
	engine_must_stop_search = 0;
	
	engine_fake_search(3000);  // 30 seconds
	if (!engine_must_stop_search)
		Print("--X-OOO---X-OO---XXXXXX-XXXXXOO---OXXOO--XXXXO-------O----------O, move D2, depth 33, @95%%, W+2 < v <= W+18 , D2B5H4G6H5H7E7H2B2E8F8G8D7D8A7A6H3A8H1H6\n");
	
	return (+4);
}


/*
 *******************************************************************************
 *                                                                             *
 *   engine_fake_search() : simulation bidon d'une recherche dans le moteur    *
 *   FakeOthelloEngine. La fonction est cependant realiste en ce sens qu'elle  *
 *   implemente les taches que devront realiser les vraies recherches :        *
 *      1) elle prend 100% du CPU                                              *
 *      2) elle appelle regulierement la fonction EngineProtocolCheckEvents()  *
 *         pour que Cassio puisse lever le drapeau engine_must_stop_search     *
 *      3) elle ecrit un point sur la sortie standard toutes les secondes      *
 *         pour que Cassio sache que le moteur est toujours vivant             *
 *                                                                             *
 *******************************************************************************
 */
pascal void engine_fake_search(const int duration)
{ unsigned int start = ReadClock();
	
	while (ReadClock() <= (start + duration)) {
		
		if (engine_must_stop_search || engine_must_quit)
			break;
		
		EngineProtocolCheckEvents();
		
		if (((ReadClock() - start) % 100) == 0) { Print("."); start-- ;}
	}
	Print("\n");
}