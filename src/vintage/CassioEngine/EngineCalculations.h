/*
 *  EngineCalculations.h
 *
 *
 *  Created by Stephane Nicolet on 03/10/09.
 *
 */

#ifndef ENGINE_CALCULATIONS_H
#define ENGINE_CALCULATIONS_H


extern int engine_must_quit;
extern int engine_must_stop_search;


pascal void* engine_init(void);
pascal float engine_midgame_search(void* engine, const char* position, const float alpha, const float beta, const int depth, const int precision);
pascal int engine_endgame_search(void* engine, const char* position, const int  alpha, const int beta, const int precision);
pascal void engine_stop(void* engine);
pascal void engine_print_results(void *engine, char *string);
pascal void engine_free(void *engine);

/* seulement dans le moteur bidon "FakeOthelloEngine" */
pascal void engine_fake_search(const int duration);


#endif   /* ENGINE_CALCULATIONS_H */