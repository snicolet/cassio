
(*
	File:		CFNetworkglue.p

	Contains:	This file imports at run time a couple of CFNetwork related
	          functions and constants for CFM architecture, using (for the
	          functions) the function pointers method rather than the CLateImport
	          method.

*)


(* You will need to hop on to pascal-central.com, download the mach-o samples and import
   (dynamically link) the required functions from CoreFoundation.framework. I can't get the
   interfaces Adriaan mentioned to compile but at least you can still use the pascal routine
   declarations when importing the functions from the framework.
*)



UNIT CFNetworkglue;




INTERFACE


{$ifc not(defined __GPC__) }


USES CFStream, CFHTTPMessage, CFSocket;



function CanInitializeCFNetworkGlue : boolean;


{ Read streams}
function CFReadStreamOpen( stream : CFReadStreamRef ): Boolean;
function CFReadStreamSetProperty( stream : CFReadStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
function CFReadStreamGetError( stream : CFReadStreamRef ): CFStreamError;
function CFReadStreamGetStatus( stream : CFReadStreamRef ): CFStreamStatus;
procedure CFReadStreamClose( stream : CFReadStreamRef );
function CFReadStreamRead( stream : CFReadStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
function CFReadStreamHasBytesAvailable( stream : CFReadStreamRef ): Boolean;
function CFReadStreamGetBuffer( stream : CFReadStreamRef; maxBytesToRead: CFIndex; var numBytesRead: CFIndex ): UInt8Ptr;


{ HTTP request streams }
function CFReadStreamCreateForHTTPRequest( alloc: CFAllocatorRef; request: CFHTTPMessageRef ): CFReadStreamRef;
function CFHTTPMessageCreateRequest( alloc: CFAllocatorRef; requestMethod: CFStringRef; url : CFURLRef; httpVersion: CFStringRef ): CFHTTPMessageRef;


{ Write streams }
function CFWriteStreamOpen( stream : CFWriteStreamRef ): Boolean;
function CFWriteStreamSetProperty( stream : CFWriteStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
function CFWriteStreamGetError( stream : CFWriteStreamRef ): CFStreamError;
function CFWriteStreamGetStatus( stream : CFWriteStreamRef ): CFStreamStatus;
procedure CFWriteStreamClose( stream : CFWriteStreamRef );
function CFWriteStreamWrite( stream : CFWriteStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
function CFWriteStreamCanAcceptBytes( stream : CFWriteStreamRef ): Boolean;


{ Socket streams; the returned streams are paired such that they use the same socket; pass NULL if you want only the read stream or the write stream }
procedure CFStreamCreatePairWithSocket( alloc: CFAllocatorRef; sock: CFSocketNativeHandle; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
procedure CFStreamCreatePairWithSocketToHost( alloc: CFAllocatorRef; host: CFStringRef; port: UInt32; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
procedure CFStreamCreatePairWithPeerSocketSignature( alloc: CFAllocatorRef;{const} var signature: CFSocketSignature; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );

{$endc}



IMPLEMENTATION


{$ifc not(defined __GPC__) }


USES MyFileSystemUtils, GestaltEqu;


type CFReadStreamOpenFuncPtr                           = function ( stream : CFReadStreamRef ): Boolean;
     CFReadStreamSetPropertyFuncPtr                    = function ( stream : CFReadStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
     CFReadStreamGetErrorFuncPtr                       = function ( stream : CFReadStreamRef ): CFStreamError;
     CFReadStreamGetStatusFuncPtr                      = function ( stream : CFReadStreamRef ): CFStreamStatus;
     CFReadStreamCloseFuncPtr                          = procedure ( stream : CFReadStreamRef );
     CFReadStreamReadFuncPtr                           = function ( stream : CFReadStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
     CFReadStreamHasBytesAvailableFuncPtr              = function ( stream : CFReadStreamRef ): Boolean;
     CFReadStreamGetBufferFuncPtr                      = function ( stream : CFReadStreamRef; maxBytesToRead: CFIndex; var numBytesRead: CFIndex ): UInt8Ptr;


     CFReadStreamCreateForHTTPRequestFuncPtr           = function ( alloc: CFAllocatorRef; request: CFHTTPMessageRef ): CFReadStreamRef;
     CFHTTPMessageCreateRequestFuncPtr                 = function ( alloc: CFAllocatorRef; requestMethod: CFStringRef; url : CFURLRef; httpVersion: CFStringRef ): CFHTTPMessageRef;


     CFStreamCreatePairWithSocketFuncPtr               = procedure ( alloc: CFAllocatorRef; sock: CFSocketNativeHandle; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
     CFStreamCreatePairWithSocketToHostFuncPtr         = procedure ( alloc: CFAllocatorRef; host: CFStringRef; port: UInt32; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
     CFStreamCreatePairWithPeerSocketSignatureFuncPtr  = procedure ( alloc: CFAllocatorRef;{const} var signature: CFSocketSignature; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );



     CFWriteStreamOpenFuncPtr                           = function ( stream : CFWriteStreamRef ): Boolean;
     CFWriteStreamSetPropertyFuncPtr                    = function ( stream : CFWriteStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
     CFWriteStreamGetErrorFuncPtr                       = function ( stream : CFWriteStreamRef ): CFStreamError;
     CFWriteStreamGetStatusFuncPtr                      = function ( stream : CFWriteStreamRef ): CFStreamStatus;
     CFWriteStreamCloseFuncPtr                          = procedure ( stream : CFWriteStreamRef );
     CFWriteStreamWriteFuncPtr                          = function ( stream : CFWriteStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
     CFWriteStreamCanAcceptBytesFuncPtr                 = function ( stream : CFWriteStreamRef ): Boolean;




var CFReadStreamOpenPtr                          : CFReadStreamOpenFuncPtr;
    CFReadStreamSetPropertyPtr                   : CFReadStreamSetPropertyFuncPtr;
    CFReadStreamGetErrorPtr                      : CFReadStreamGetErrorFuncPtr;
    CFReadStreamGetStatusPtr                     : CFReadStreamGetStatusFuncPtr;
    CFReadStreamClosePtr                         : CFReadStreamCloseFuncPtr;
    CFReadStreamReadPtr                          : CFReadStreamReadFuncPtr;
    CFReadStreamHasBytesAvailablePtr             : CFReadStreamHasBytesAvailableFuncPtr;
    CFReadStreamGetBufferPtr                     : CFReadStreamGetBufferFuncPtr;

    CFReadStreamCreateForHTTPRequestPtr          : CFReadStreamCreateForHTTPRequestFuncPtr;
    CFHTTPMessageCreateRequestPtr                : CFHTTPMessageCreateRequestFuncPtr;

    CFStreamCreatePairWithSocketPtr              : CFStreamCreatePairWithSocketFuncPtr;
    CFStreamCreatePairWithSocketToHostPtr        : CFStreamCreatePairWithSocketToHostFuncPtr;
    CFStreamCreatePairWithPeerSocketSignaturePtr : CFStreamCreatePairWithPeerSocketSignatureFuncPtr;

    CFWriteStreamOpenPtr                          : CFWriteStreamOpenFuncPtr;
    CFWriteStreamSetPropertyPtr                   : CFWriteStreamSetPropertyFuncPtr;
    CFWriteStreamGetErrorPtr                      : CFWriteStreamGetErrorFuncPtr;
    CFWriteStreamGetStatusPtr                     : CFWriteStreamGetStatusFuncPtr;
    CFWriteStreamClosePtr                         : CFWriteStreamCloseFuncPtr;
    CFWriteStreamWritePtr                         : CFWriteStreamWriteFuncPtr;
    CFWriteStreamCanAcceptBytesPtr                : CFWriteStreamCanAcceptBytesFuncPtr;




function CanInitializeCFNetworkGlue : boolean;
var MacVersion : SInt32;
    whichFramework : String255;
begin
  CFReadStreamOpenPtr                          := NIL;
  CFReadStreamSetPropertyPtr                   := NIL;
  CFReadStreamGetErrorPtr                      := NIL;
  CFReadStreamGetStatusPtr                     := NIL;
  CFReadStreamClosePtr                         := NIL;
  CFReadStreamReadPtr                          := NIL;
  CFReadStreamHasBytesAvailablePtr             := NIL;
  CFReadStreamGetBufferPtr                     := NIL;

  CFReadStreamCreateForHTTPRequestPtr          := NIL;
  CFHTTPMessageCreateRequestPtr                := NIL;

  CFStreamCreatePairWithSocketPtr              := NIL;
  CFStreamCreatePairWithSocketToHostPtr        := NIL;
  CFStreamCreatePairWithPeerSocketSignaturePtr := NIL;

  CFWriteStreamOpenPtr                          := NIL;
  CFWriteStreamSetPropertyPtr                   := NIL;
  CFWriteStreamGetErrorPtr                      := NIL;
  CFWriteStreamGetStatusPtr                     := NIL;
  CFWriteStreamClosePtr                         := NIL;
  CFWriteStreamWritePtr                         := NIL;
  CFWriteStreamCanAcceptBytesPtr                := NIL;

  if (Gestalt(gestaltSystemVersion, MacVersion) = noErr) &
     (MacVersion >= $1030)  (* au moins Mac OS X 10.3 *)
    then
      begin

        whichFramework := 'System.framework';

        {whichFramework := 'CoreFoundation.framework';}

        CFReadStreamOpenPtr                          := CFReadStreamOpenFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamOpen'));
        CFReadStreamSetPropertyPtr                   := CFReadStreamSetPropertyFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamSetProperty'));
        CFReadStreamGetErrorPtr                      := CFReadStreamGetErrorFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamGetError'));
        CFReadStreamGetStatusPtr                     := CFReadStreamGetStatusFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamGetStatus'));
        CFReadStreamClosePtr                         := CFReadStreamCloseFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamClose'));
        CFReadStreamReadPtr                          := CFReadStreamReadFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamRead'));
        CFReadStreamHasBytesAvailablePtr             := CFReadStreamHasBytesAvailableFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamHasBytesAvailable'));
        CFReadStreamGetBufferPtr                     := CFReadStreamGetBufferFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamGetBuffer'));

        CFReadStreamCreateForHTTPRequestPtr          := CFReadStreamCreateForHTTPRequestFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFReadStreamCreateForHTTPRequest'));
        CFHTTPMessageCreateRequestPtr                := CFHTTPMessageCreateRequestFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFHTTPMessageCreateRequest'));

        CFStreamCreatePairWithSocketPtr              := CFStreamCreatePairWithSocketFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFStreamCreatePairWithSocket'));
        CFStreamCreatePairWithSocketToHostPtr        := CFStreamCreatePairWithSocketToHostFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFStreamCreatePairWithSocketToHost'));
        CFStreamCreatePairWithPeerSocketSignaturePtr := CFStreamCreatePairWithPeerSocketSignatureFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFStreamCreatePairWithPeerSocketSignature'));

        CFWriteStreamOpenPtr                         := CFWriteStreamOpenFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamOpen'));
        CFWriteStreamSetPropertyPtr                  := CFWriteStreamSetPropertyFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamSetProperty'));
        CFWriteStreamGetErrorPtr                     := CFWriteStreamGetErrorFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamGetError'));
        CFWriteStreamGetStatusPtr                    := CFWriteStreamGetStatusFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamGetStatus'));
        CFWriteStreamClosePtr                        := CFWriteStreamCloseFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamClose'));
        CFWriteStreamWritePtr                        := CFWriteStreamWriteFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamWrite'));
        CFWriteStreamCanAcceptBytesPtr               := CFWriteStreamCanAcceptBytesFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'CFWriteStreamCanAcceptBytes'));



        CanInitializeCFNetworkGlue := (CFReadStreamOpenPtr                          <> NIL) &
                                      (CFReadStreamSetPropertyPtr                   <> NIL) &
                                      (CFReadStreamGetErrorPtr                      <> NIL) &
                                      (CFReadStreamGetStatusPtr                     <> NIL) &
                                      (CFReadStreamClosePtr                         <> NIL) &
                                      (CFReadStreamReadPtr                          <> NIL) &
                                      (CFReadStreamHasBytesAvailablePtr             <> NIL) &
                                      (CFReadStreamGetBufferPtr                     <> NIL) &

                                      (CFReadStreamCreateForHTTPRequestPtr          <> NIL) &
                                      (CFHTTPMessageCreateRequestPtr                <> NIL) &

                                      (CFStreamCreatePairWithSocketPtr              <> NIL) &
                                      (CFStreamCreatePairWithSocketToHostPtr        <> NIL) &
                                      (CFStreamCreatePairWithPeerSocketSignaturePtr <> NIL) &

                                      (CFWriteStreamOpenPtr                          <> NIL) &
                                      (CFWriteStreamSetPropertyPtr                   <> NIL) &
                                      (CFWriteStreamGetErrorPtr                      <> NIL) &
                                      (CFWriteStreamGetStatusPtr                     <> NIL) &
                                      (CFWriteStreamClosePtr                         <> NIL) &
                                      (CFWriteStreamWritePtr                         <> NIL) &
                                      (CFWriteStreamCanAcceptBytesPtr                <> NIL) ;
      end;
end;




///////////////// READ STREAMS  //////////////


function CFReadStreamOpen( stream : CFReadStreamRef ): Boolean;
begin
  CFReadStreamOpen := CFReadStreamOpenPtr(stream);
end;


function CFReadStreamSetProperty( stream : CFReadStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
begin
  CFReadStreamSetProperty := CFReadStreamSetPropertyPtr( stream, propertyName, propertyValue);
end;




function CFReadStreamGetError( stream : CFReadStreamRef ): CFStreamError;
begin
  CFReadStreamGetError := CFReadStreamGetErrorPtr(stream);
end;


function CFReadStreamGetStatus( stream : CFReadStreamRef ): CFStreamStatus;
begin
  CFReadStreamGetStatus := CFReadStreamGetStatusPtr(stream);
end;


procedure CFReadStreamClose( stream : CFReadStreamRef );
begin
  CFReadStreamClosePtr(stream);
end;


function CFReadStreamRead( stream : CFReadStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
begin
  CFReadStreamRead := CFReadStreamReadPtr(stream,buffer,bufferLength);
end;


function CFReadStreamHasBytesAvailable( stream : CFReadStreamRef ): Boolean;
begin
  CFReadStreamHasBytesAvailable := CFReadStreamHasBytesAvailablePtr(stream);
end;


function CFReadStreamGetBuffer( stream : CFReadStreamRef; maxBytesToRead: CFIndex; var numBytesRead: CFIndex ): UInt8Ptr;
begin
  CFReadStreamGetBuffer := CFReadStreamGetBufferPtr( stream, maxBytesToRead, numBytesRead);
end;




////////////// HTTP REQUEST STREAMS //////////////////


function CFReadStreamCreateForHTTPRequest( alloc: CFAllocatorRef; request: CFHTTPMessageRef ): CFReadStreamRef;
begin
  CFReadStreamCreateForHTTPRequest := CFReadStreamCreateForHTTPRequestPtr(alloc, request);
end;


function CFHTTPMessageCreateRequest( alloc: CFAllocatorRef; requestMethod: CFStringRef; url : CFURLRef; httpVersion: CFStringRef ): CFHTTPMessageRef;
begin
  CFHTTPMessageCreateRequest := CFHTTPMessageCreateRequestPtr(alloc,requestMethod,url,httpVersion);
end;




/////////////  SOCKET STREAMS  //////////////////

procedure CFStreamCreatePairWithSocket( alloc: CFAllocatorRef; sock: CFSocketNativeHandle; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
begin
  CFStreamCreatePairWithSocketPtr( alloc, sock, readStream, writeStream );
end;


procedure CFStreamCreatePairWithSocketToHost( alloc: CFAllocatorRef; host: CFStringRef; port: UInt32; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
begin
  CFStreamCreatePairWithSocketToHostPtr( alloc, host, port, readStream, writeStream );
end;


procedure CFStreamCreatePairWithPeerSocketSignature( alloc: CFAllocatorRef;{const} var signature: CFSocketSignature; var readStream: CFReadStreamRef; var writeStream: CFWriteStreamRef );
begin
  CFStreamCreatePairWithPeerSocketSignaturePtr( alloc, signature, readStream, writeStream );
end;




/////////////  WRITE STREAMS  ///////////////



function CFWriteStreamOpen( stream : CFWriteStreamRef ): Boolean;
begin
  CFWriteStreamOpen := CFWriteStreamOpenPtr(stream);
end;


function CFWriteStreamSetProperty( stream : CFWriteStreamRef; propertyName: CFStringRef; propertyValue: CFTypeRef ): Boolean;
begin
  CFWriteStreamSetProperty := CFWriteStreamSetPropertyPtr( stream, propertyName, propertyValue);
end;


function CFWriteStreamGetError( stream : CFWriteStreamRef ): CFStreamError;
begin
  CFWriteStreamGetError := CFWriteStreamGetErrorPtr(stream);
end;


function CFWriteStreamGetStatus( stream : CFWriteStreamRef ): CFStreamStatus;
begin
  CFWriteStreamGetStatus := CFWriteStreamGetStatusPtr(stream);
end;


procedure CFWriteStreamClose( stream : CFWriteStreamRef );
begin
  CFWriteStreamClosePtr(stream);
end;


function CFWriteStreamWrite( stream : CFWriteStreamRef; buffer : UnivPtr; bufferLength: CFIndex ): CFIndex;
begin
  CFWriteStreamWrite := CFWriteStreamWritePtr(stream,buffer,bufferLength);
end;


function CFWriteStreamCanAcceptBytes( stream : CFWriteStreamRef ): Boolean;
begin
  CFWriteStreamCanAcceptBytes := CFWriteStreamCanAcceptBytesPtr(stream);
end;



{$endc}



END.

