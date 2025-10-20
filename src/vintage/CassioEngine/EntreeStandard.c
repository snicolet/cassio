/*
 *  EntreeStandard.c
 *
 *  Input/output routines for the engine and the engine protocol.
 *
 *  Created by Stephane Nicolet on 03/10/09.
 *
 *  Most of the code below in taken from Robert Hyatt's chess
 *  program "crafty" (thanks). See http://www.craftychess.com/
 *  for the crafty source code.
 *
 *
 */


#include "EntreeStandard.h"

/* global variables */
FILE *input_stream;
char cmd_buffer[STDIN_BUFFER_SIZE];
char line_buffer[STDIN_BUFFER_SIZE];
char *args[512];

static int standard_input_unit_initialized = 0;



/*
 *******************************************************************************
 *                                                                             *
 *   Print() is the main output procedure. Same format as printf(), and        *
 *   uses the "variable number of arguments" facility in ANSI C since the      *
 *   normal printf() function accepts a variable number of arguments.          *
 *                                                                             *
 *******************************************************************************
 */
void Print(char *fmt, ...) {
  va_list ap;
	
	if (!standard_input_unit_initialized)
			SetReadStream(stdin);
	
  va_start(ap, fmt);
  vprintf(fmt, ap);
  fflush(stdout);
  va_end(ap);
}


/*
 *******************************************************************************
 *                                                                             *
 *   SetReadStream() will be used to set the read stream to the standard input *
 *                                                                             *
 *******************************************************************************
 */
void SetReadStream(FILE *stream) {
	int i;
	
	standard_input_unit_initialized = 1;

  input_stream = stream;
	for (i = 0; i < 512; i++)
    args[i] = (char *) malloc(256);
	
	ReadClear();
	
}


/*
 *******************************************************************************
 *                                                                             *
 *   ReadClear() clears the input buffer when input_stream is being switched   *
 *   to a file, since we have info buffered up from a different input stream.  *
 *                                                                             *
 *******************************************************************************
 */
void ReadClear() {
	
	if (!standard_input_unit_initialized)
		SetReadStream(stdin);
	
  cmd_buffer[0] = 0;
}

/*
 *******************************************************************************
 *                                                                             *
 *   ReadInput() reads data from the input_stream, and buffers this into the   *
 *   command_buffer for later processing.                                      *
 *                                                                             *
 *******************************************************************************
 */
int ReadInput(void) {
  char buffer[STDIN_BUFFER_SIZE], *end;
  int bytes;
	
	if (!standard_input_unit_initialized)
			SetReadStream(stdin);
	
  do
    bytes = read(fileno(input_stream), buffer, STDIN_BUFFER_SIZE);
  while (bytes < 0 && errno == EINTR);
  if (bytes == 0) {
    if (input_stream != stdin)
      fclose(input_stream);
    input_stream = stdin;
    return (0);
  } else if (bytes < 0) {
    Print("ERROR!  input I/O stream is unreadable, exiting.\n");
    exit(1);
  }
  end = cmd_buffer + strlen(cmd_buffer);
  memcpy(end, buffer, bytes);
  *(end + bytes) = 0;
	
  return (1);
}


/*
 *******************************************************************************
 *                                                                             *
 *   Read() copies data from the command_buffer into a local buffer, so that   *
 *   the user can call ReadParse to break this command up into tokens for      *
 *   processing.                                                               *
 *                                                                             *
 *******************************************************************************
 */
int Read(int wait, char *buffer) {
  char *eol, *ret, readdata;
	
	if (!standard_input_unit_initialized)
		SetReadStream(stdin);
	
  *buffer = 0;
	/*
	 case 1:  We have a complete command line, with terminating
	 N/L character in the buffer.  We can simply extract it from
	 the I/O buffer, parse it and return.
	 */
	
  if (strchr(cmd_buffer, '\n')) ;
	
	
	/*
	 case 2:  The buffer does not contain a complete line.  If we
	 were asked to not wait for a complete command, then we first
	 see if I/O is possible, and if so, read in what is available.
	 If that includes a N/L, then we are ready to parse and return.
	 If not, we return indicating no input available just yet.
	 */
  else if (!wait) {
    if (CheckKeyboardInput()) {
      readdata = ReadInput();
      if (!strchr(cmd_buffer, '\n'))
        return (0);
      if (!readdata)
        return (-1);
    } else
      return (0);
  }
	/*
	 case 3:  The buffer does not contain a complete line, but we
	 were asked to wait until a complete command is entered.  So we
	 hang by doing a ReadInput() and continue doing so until we get
	 a N/L character in the buffer.  Then we parse and return.
	 */
  else
    while (!strchr(cmd_buffer, '\n')) {
      readdata = ReadInput();
      if (!readdata)
        return (-1);
    }
	
	
  eol = strchr(cmd_buffer, '\n');
  *eol = 0;
  ret = strchr(cmd_buffer, '\r');
  if (ret)
    *ret = ' ';
  strcpy(buffer, cmd_buffer);
  memmove(cmd_buffer, eol + 1, strlen(eol + 1) + 1);
	
  return (1);
}

/*
 *******************************************************************************
 *                                                                             *
 *   ReadParse() takes one complete command-line, and breaks it up into        *
 *   tokens. You must pass common delimiters (such as " ", ",", "/" and ";")   *
 *   in the "delims" string, any caracter of which will delimit tokens.        *                                                        *
 *                                                                             *
 *******************************************************************************
 */
int ReadParse(char *buffer, char *args[], char *delims) {
  char *next, tbuffer[STDIN_BUFFER_SIZE];
  int nargs;
	
	if (!standard_input_unit_initialized)
		SetReadStream(stdin);
	
  strcpy(tbuffer, buffer);
  for (nargs = 0; nargs < 512; nargs++)
    *(args[nargs]) = 0;
  next = strtok(tbuffer, delims);
  if (!next)
    return (0);
  strcpy(args[0], next);
  for (nargs = 1; nargs < 512; nargs++) {
    next = strtok(0, delims);
    if (!next)
      break;
    strcpy(args[nargs], next);
  }
	
  return (nargs);
}



/*
 *******************************************************************************
 *                                                                             *
 *   CheckKeyboardInput() : the following function is used to determine if     *
 *   keyboard input is present.  There are several ways this is done depending *
 *   on which operating system is used, so for simplicity there are several    *
 *   O/S-specific versions of the function.                                    *
 *                                                                             *
 *******************************************************************************
 */
#if defined(NT_i386)
#  include <windows.h>
#  include <conio.h>
/* Windows NT using PeekNamedPipe() function */
int CheckKeyboardInput(void) {
  int i;
  static int init = 0, pipe;
  static HANDLE inh;
  DWORD dw;
	
	if (!standard_input_unit_initialized)
		SetReadStream(stdin);
	
  if (strchr(cmd_buffer, '\n'))
    return (1);
  if (xboard) {
#  if defined(FILE_CNT)
    if (stdin->_cnt > 0)
      return stdin->_cnt;
#  endif
    if (!init) {
      init = 1;
      inh = GetStdHandle(STD_INPUT_HANDLE);
      pipe = !GetConsoleMode(inh, &dw);
      if (!pipe) {
        SetConsoleMode(inh, dw & ~(ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT));
        FlushConsoleInputBuffer(inh);
      }
    }
    if (pipe) {
      if (!PeekNamedPipe(inh, NULL, 0, NULL, &dw, NULL)) {
        return 1;
      }
      return dw;
    } else {
      GetNumberOfConsoleInputEvents(inh, &dw);
      return dw <= 1 ? 0 : dw;
    }
  } else {
    i = _kbhit();
  }
  return (i);
}
#endif
#if defined(__GNUC__) || defined(UNIX)
/* Simple UNIX approach using select with a zero timeout value */
int CheckKeyboardInput(void) {
  fd_set readfds;
  struct timeval tv;
  int data;
	
	if (!standard_input_unit_initialized)
		SetReadStream(stdin);
	
  if (strchr(cmd_buffer, '\n'))
    return (1);
	
  FD_ZERO(&readfds);
  FD_SET(fileno(stdin), &readfds);
  tv.tv_sec = 0;
  tv.tv_usec = 0;
  select(16, &readfds, 0, 0, &tv);
  data = FD_ISSET(fileno(stdin), &readfds);
	
  return (data);
}
#else
/* empty, fake function, just to make the compiler happy */
int CheckKeyboardInput(void) {
  return (0);
}
#endif


/*
 *******************************************************************************
 *                                                                             *
 *   ReadClock() is a procedure used to read the elapsed time.  Since this     *
 *   varies from system to system, this procedure has several flavors to       *
 *   provide portability. It returns the time in 1/100 of seconds.             *
 *                                                                             *
 *******************************************************************************
 */
unsigned int ReadClock(void) {
#if defined(__GNUC__) || defined(AMIGA) || defined(UNIX)
  struct timeval timeval;
#endif
#if defined(NT_i386)
  HANDLE hThread;
  FILETIME ftCreate, ftExit, ftKernel, ftUser;
  BITBOARD tUser64;
#endif
#if defined(__GNUC__) || defined(UNIX) || defined(AMIGA)
  gettimeofday(&timeval, NULL);
  return (timeval.tv_sec * 100 + (timeval.tv_usec / 10000));
#endif
#if defined(NT_i386)
  return ((unsigned int) GetTickCount() / 10);
#endif
}




