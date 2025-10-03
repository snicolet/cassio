

#include <stdio.h>
#include "EngineCalculations.h"
#include "EngineProtocol.h"
#include "standardInput.h"



int main (int argc, const char * argv[]) {
	
	/* Write some infos about the environment */
  printf("Welcome to the FakeOthelloEngine... \n\n");
	printf("Am I running in 64 bits mode? ");
  #ifdef __LP64__
		printf("YES\n\n");
	#else
		printf("NO\n\n");
	#endif
	printf("sizeof(int) = %ld\n",sizeof(int));
	printf("sizeof(long) = %ld\n",sizeof(long));
	printf("sizeof(long long) = %ld\n",sizeof(long long));
	printf("\n");
	
	/* Call the main loop of the fake othello engine */
	EngineProtocolMainLoop();
	
	return 0;
}
