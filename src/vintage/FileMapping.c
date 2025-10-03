/*
	File:		FileMapping.c
*/

#include <stdio.h>
#include <stdlib.h>

#include <time.h>
#include <time.h>

#include <unistd.h>
#include <fcntl.h>

#include <types.h>
#include <mman.h>



/* Prototypes */

pascal void UnmapFile( size_t *dataLength, void ** dataPtr);
pascal int MapFile( char * inPathName, void ** outDataPtr, size_t * outDataLength );


int	munmap(void *, size_t);
void *	mmap(void *, size_t, int, int, int, off_t);


pascal void UnmapFile( size_t *dataLength, void ** dataPtr)
{
    munmap( *dataPtr, *dataLength );
}




// MapFile
// Return the contents of the specified file as a read-only pointer.
//
// Enter:inPathName is a UNIX-style Ò/Ó-delimited pathname
//
// Exit: outDataPtra pointer to the mapped memory region
//       outDataLength size of the mapped memory region
//       return value an errno value on error (see sys/errno.h)
//       or zero for success
//
pascal int MapFile( char * inPathName, void ** outDataPtr, size_t * outDataLength )
{
  int outError;
  int fileDescriptor;
  struct stat statInfo;


  // Return safe values on error.
  
  outError = 0;
  *outDataPtr = NULL;
  *outDataLength = 0;
  
  // Open the file.
  
  fileDescriptor = open( inPathName, O_RDONLY, 0 );
  if( fileDescriptor < 0 )
    {
    outError = errno;
    }
  else
    {
    
    // We now know the file exists. Retrieve the file size.
    
    if( fstat( fileDescriptor, &statInfo ) != 0 )
      {
      outError = errno;
      }
    else
      {
      
      // Map the file into a read-only memory region.
      
      *outDataPtr = mmap(NULL, statInfo.st_size, PROT_READ, 0, fileDescriptor, 0);
      
      if( *outDataPtr == MAP_FAILED )
        {
        outError = errno;
        }
      else
        {
        
        // On success, return the size of the mapped file.
        
        *outDataLength = statInfo.st_size;
        }
      }
      
    // Now close the file. The kernel doesnÕt use our file descriptor.

    close( fileDescriptor );
    }
    
  return outError;
}




