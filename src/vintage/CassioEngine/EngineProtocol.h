/*
 *  EngineProtocol.h
 *
 *
 *  Created by Stéphane Nicolet on 03/10/09.
 *
 */

#ifndef ENGINE_PROTOCOL_H
#define ENGINE_PROTOCOL_H


#include "EntreeStandard.h"

extern void* engine;

pascal void EngineProtocolMainLoop(void);
pascal void EngineProtocolCheckEvents(void);
pascal void EngineProtocolInterpretCommand(int nargs, char *args[]);
pascal void EngineProtocolSyntaxError(int nargs, char *args[]);



#endif   /* ENGINE_PROTOCOL_H */