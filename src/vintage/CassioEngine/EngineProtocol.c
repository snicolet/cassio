/*
 *  EngineProtocol.c
 *
 *  Implementation d'un protocole texte pour un moteur d'othello :
 *  la lecture et l'ecriture se font via l'entree et la sortie standard
 *
 *  Created by Stéphane Nicolet on 03/10/09.
 *
 */

#include "EngineProtocol.h"
#include "EngineCalculations.h"
#include "EntreeStandard.h"


void* engine;


/*
 *******************************************************************************
 *                                                                             *
 *   EngineProtocolMainLoop() : la boucle principale de notre implementation.  *
 *   On lit l'entree standard ligne par ligne, et si la ligne commence par le  *
 *   mot cle special ENGINE-PROTOCOL, on execute la commande.                  *
 *   Cette implementation prend 0% du temps CPU tant que la ligne ne contient  *
 *   pas de commande.                                                          *
 *                                                                             *
 *******************************************************************************
 */
pascal void EngineProtocolMainLoop(void)
{ int readstatus, nargs;
  int quit;


  Print("sizeof(float) = %d\n",sizeof(float));
	
	
	quit = 0;
	while (!quit) {
		Print("ready.\n");
		readstatus = Read(1, line_buffer);  // blocking read of stdin
		if (readstatus > 0) {
				nargs = ReadParse(line_buffer, args, " ");
				if (nargs > 0) {
					if (strstr(args[0], "ENGINE-PROTOCOL"))
					  {
					  EngineProtocolInterpretCommand(nargs, args);
					  if (strstr(args[1], "quit"))
					      quit = 1;
					  }
					else
						EngineProtocolSyntaxError(nargs, args);
				}
			}
	}		
}


/*
 *******************************************************************************
 *                                                                             *
 *   EngineProtocolCheckEvents() : fonction qui doit etre appelee reguliere-   *
 *   ment par le moteur lorsqu'il analyse une position, de facon que Cassio    *
 *   puisse l'interrompre.                                                     *
 *   Cette fonction est non bloquante, et fait seulement deux choses :         *
 *      1) elle repond "ok." sur la sortie standard si elle recoit une         *
 *         commande vide (ligne vide). Ceci permet a Cassio de tester pendant  *
 *         la recherche si le moteur est toujours vivant;                      *
 *      2) elle verifie si elle doit executer une des deux commandes "stop" ou *
 *         "quit", en appelant respectivement les fonctions engine_stop() ou   *
 *         engine_free() du moteur.                                            *
 *                                                                             *
 *******************************************************************************
 */
pascal void EngineProtocolCheckEvents(void)
{ int readstatus, nargs;
	
	readstatus = Read(0, line_buffer);  // non blocking read of stdin
	if (readstatus > 0) {
		nargs = ReadParse(line_buffer, args, " ");
		if (nargs == 0) {
			Print("ok.\n");
		}
		else {
			if (strstr(args[0], "ENGINE-PROTOCOL") &&
				 (strstr(args[1], "stop") || strstr(args[1], "quit")))
				EngineProtocolInterpretCommand(nargs, args);
			else
				EngineProtocolSyntaxError(nargs, args);
			}
	}
}

/*
 *******************************************************************************
 *                                                                             *
 *   EngineProtocolInterpretCommand() : interpretation d'une commande recue    *
 *   par le moteur sur l'entree standard.                                      *
 *                                                                             *
 *******************************************************************************
 */
pascal void EngineProtocolInterpretCommand(int nargs, char *args[])
{
	if (strstr(args[1], "init"))
		engine = engine_init();
	
	else if (strstr(args[1], "stop"))
		engine_stop(engine);
	
	else if (strstr(args[1], "quit"))
		engine_free(engine);	
	
	else if (strstr(args[1], "midgame-search")) {
		
		char *position;
		float alpha, beta;
		int depth, precision;
		
		position  = args[1];
		alpha     = atof(args[2]);
		beta      = atof(args[3]);
		depth     = atoi(args[4]);
		precision = atoi(args[5]);
		
		engine_midgame_search(engine, position, alpha, beta, depth, precision);
	}
	
	else if (strstr(args[1], "endgame-search")) {
		
		char *position;
		int alpha, beta, precision;
		
		position  = args[1];
		alpha     = atoi(args[2]);
		beta      = atoi(args[3]);
		precision = atoi(args[4]);
		
		engine_endgame_search(engine, position, alpha, beta, precision);
	}
	
	else
		EngineProtocolSyntaxError(nargs,args);
}

/*
 *******************************************************************************
 *                                                                             *
 *   EngineProtocolSyntaxError() : aide au debugage. Affiche les lexemes recus *
 *   sur la derniere ligne de l'entree standard, en cas d'erreur de syntaxe.   *
 *                                                                             *
 *******************************************************************************
 */
pascal void EngineProtocolSyntaxError(int nargs, char *args[])
{int i;
											
  Print("\nSYNTAX ERROR :\n");
  for (i = 0; i < nargs; i++)
		Print("Token[%d] = %s\n", i, args[i]);
	Print("\n");
}
															
															
															
															
															
															
															


