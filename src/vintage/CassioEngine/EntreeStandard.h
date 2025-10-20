/*
 *  EntreeStandard.h
 *
 *
 *  Created by Stephane Nicolet on 03/10/09.
 *
 */

#ifndef STANDARD_INPUT_H
#define STANDARD_INPUT_H


#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// #include <sys/time.h>



#define STDIN_BUFFER_SIZE  (1024 * 128)

extern FILE *input_stream;
extern char cmd_buffer[STDIN_BUFFER_SIZE];
extern char line_buffer[STDIN_BUFFER_SIZE];
extern char *args[512];


void SetReadStream(FILE *stream);
void ReadClear();
int ReadInput(void);
int Read(int wait, char *buffer);
int ReadParse(char *buffer, char *args[], char *delims);

void Print(char *fmt, ...);

int CheckKeyboardInput(void);
unsigned int ReadClock(void);



#endif  /*  STANDARD_INPUT_H  */