

#include <stdio.h>


extern void flush_standard_output( void );


void flush_standard_output( void ) {

 fflush (stdout);

}
