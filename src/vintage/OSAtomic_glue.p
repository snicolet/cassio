UNIT OSAtomic_glue;


{*
 * Copyright (c) 2004 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 *
 *
 * Note : Ported to Pascal by Stephane NICOLET, 22 feb 2007
 *
 *}


INTERFACE


USES MacTypes;



(* These are the preferred versions of the atomic and synchronization operations.
 * Their implementation is customized at boot time for the platform, including
 * late-breaking errata fixes as necessary.   They are thread safe.
 *
 * WARNING: all addresses passed to these functions must be "naturally aligned", ie
 * int32_t's must be 32-bit aligned (low 2 bits of address zero), and int64_t's
 * must be 64-bit aligned (low 3 bits of address zero.)
 *
 * Note that some versions of the atomic functions incorporate memory barriers,
 * and some do not.  Barriers strictly order memory access on a weakly-ordered
 * architecture such as PPC.  All loads and stores executed in sequential program
 * order before the barrier will complete before any load or store executed after
 * the barrier.  On a uniprocessor, the barrier operation is typically a nop.
 * On a multiprocessor, the barrier can be quite expensive.
 *
 * Most code will want to use the barrier functions to insure that memory shared
 * between threads is properly synchronized.  For example, if you want to initialize
 * a shared data structure and then atomically increment a variable to indicate
 * that the initialization is complete, then you MUST use OSAtomicIncrement32Barrier
 * to ensure that the stores to your data structure complete before the atomic add.
 * Likewise, the consumer of that data structure MUST use OSAtomicDecrement32Barrier,
 * in order to ensure that their loads of the structure are not executed before
 * the atomic decrement.  On the other hand, if you are simply incrementing a global
 * counter, then it is safe and potentially faster to use OSAtomicIncrement32.
 *
 * If you are unsure which version to use, prefer the barrier variants as they are
 * safer.
 *
 * The spinlock and queue operations always incorporate a barrier.
 *)


type

  OSSpinLock = SInt32;

  OSAtomicChange32FuncPtr          = function ( theAmount : SInt32; var theValue : SInt32 ) : SInt32;
  OSAtomicIncrDecr32FuncPtr        = function ( var theValue : SInt32 ) : SInt32;
  OSAtomicLogical32FuncPtr         = function ( theMask : UInt32; var theValue : UInt32 ) : SInt32;
  OSAtomicCompareAndSwap32FuncPtr  = function ( oldValue : SInt32; newValue : SInt32; var theValue : SInt32 ) : SInt32;
  OSAtomicTestAndSetFuncPtr        = function ( n : UInt32; theAddress : Ptr) : SInt32;
  OSSpinLockFuncPtr                = function ( var lock : OSSpinLock ) : SInt32;
  OSSpinLockProcPtr                = procedure( var lock : OSSpinLock );
  OSMemoryBarrierProcPtr           = procedure;


var
  OSAtomicAdd32Ptr        : OSAtomicChange32FuncPtr;
  OSAtomicAdd32BarrierPtr : OSAtomicChange32FuncPtr;



  OSAtomicOr32Ptr        : OSAtomicLogical32FuncPtr;
  OSAtomicOr32BarrierPtr : OSAtomicLogical32FuncPtr;

  OSAtomicAnd32Ptr        : OSAtomicLogical32FuncPtr;
  OSAtomicAnd32BarrierPtr : OSAtomicLogical32FuncPtr;

  OSAtomicXor32Ptr        : OSAtomicLogical32FuncPtr;
  OSAtomicXor32BarrierPtr : OSAtomicLogical32FuncPtr;

  OSAtomicCompareAndSwap32Ptr        : OSAtomicCompareAndSwap32FuncPtr;
  OSAtomicCompareAndSwap32BarrierPtr : OSAtomicCompareAndSwap32FuncPtr;


  OSAtomicTestAndSetPtr :          OSAtomicTestAndSetFuncPtr;
  OSAtomicTestAndSetBarrierPtr :   OSAtomicTestAndSetFuncPtr;
  OSAtomicTestAndClearPtr :        OSAtomicTestAndSetFuncPtr;
  OSAtomicTestAndClearBarrierPtr : OSAtomicTestAndSetFuncPtr;

  OSSpinLockTryPtr :    OSSpinLockFuncPtr;
  OSSpinLockLockPtr :   OSSpinLockProcPtr;
  OSSpinLockUnlockPtr : OSSpinLockProcPtr;

  OSMemoryBarrierPtr : OSMemoryBarrierProcPtr;




function CanInitializeOSAtomicUnit : boolean;


{* some functionalities are implemented here as Pascal Macros to avoid the overhead
 * of the glue function call : see the file MacrosCassio.prefix
 *}





{* Arithmetic functions.  They return the new value.  All the "or", "and", and "xor"
 * operations, and the barrier forms of add, are layered on top of compare-and-swap.
 *}
procedure OSAtomicAdd32(theAmount : SInt32; var theValue : SInt32 );
procedure OSAtomicAdd32Barrier(theAmount : SInt32; var theValue : SInt32 );


procedure OSAtomicIncrement32( var theValue : SInt32 );
procedure OSAtomicIncrement32Barrier( var theValue : SInt32 );

procedure OSAtomicDecrement32( var theValue : SInt32 );
procedure OSAtomicDecrement32Barrier( var theValue : SInt32 );

procedure OSAtomicOr32(theMask : UInt32; var theValue : UInt32 );
procedure OSAtomicOr32Barrier(theMask : UInt32; var theValue : UInt32 );

procedure OSAtomicAnd32(theMask : UInt32; var theValue : UInt32 );
procedure OSAtomicAnd32Barrier(theMask : UInt32; var theValue : UInt32 );

procedure OSAtomicXor32(theMask : UInt32; var theValue : UInt32 );
procedure OSAtomicXor32Barrier(theMask : UInt32; var theValue : UInt32 );




{* Compare and swap.  They return 1 if the swap occured, 0 otherwise
 *}
function OSAtomicCompareAndSwap32(oldValue : SInt32; newValue : SInt32; var theValue : SInt32 ) : SInt32;
function OSAtomicCompareAndSwap32Barrier(oldValue : SInt32; newValue : SInt32; var theValue : SInt32 ) : SInt32;



{* Test and set.  They return the original value of the bit, and operate on bit (0x80 >> (n&7))
 * in byte ((char*)theAddress + (n >> 3)).  They are layered on top of the compare-and-swap
 * operation.
 *}
function OSAtomicTestAndSet(n : UInt32; theAddress : Ptr) : SInt32;
function OSAtomicTestAndSetBarrier(n : UInt32; theAddress : Ptr) : SInt32;
function OSAtomicTestAndClear(n : UInt32; theAddress : Ptr) : SInt32;
function OSAtomicTestAndClearBarrier(n : UInt32; theAddress : Ptr ) : SInt32;

{* Spinlocks.  These use memory barriers as required to synchronize access to shared
 * memory protected by the lock.  The lock operation spins, but employs various strategies
 * to back off if the lock is held, making it immune to most priority-inversion livelocks.
 * The try operation immediately returns false if the lock was held, true if it took the
 * lock.  The convention is that unlocked is zero, locked is nonzero.
 *}


function     OSSpinLockTry( var lock : OSSpinLock ) : SInt32;
procedure    OSSpinLockLock( var lock : OSSpinLock );
procedure    OSSpinLockUnlock( var lock : OSSpinLock );


{* Memory barrier.  It is both a read and write barrier.
 *}
procedure    OSMemoryBarrier;


IMPLEMENTATION


USES MyFileSystemUtils, GestaltEqu;


///////////////////////////////////////////////////////

function CanInitializeOSAtomicUnit : boolean;
var MacVersion : SInt32;
    whichFramework : String255;
begin
  CanInitializeOSAtomicUnit := false;

  OSAtomicAdd32Ptr                   := NIL;
  OSAtomicAdd32BarrierPtr            := NIL;
  OSAtomicOr32Ptr                    := NIL;
  OSAtomicOr32BarrierPtr             := NIL;
  OSAtomicAnd32Ptr                   := NIL;
  OSAtomicAnd32BarrierPtr            := NIL;
  OSAtomicXor32Ptr                   := NIL;
  OSAtomicXor32BarrierPtr            := NIL;
  OSAtomicCompareAndSwap32Ptr        := NIL;
  OSAtomicCompareAndSwap32BarrierPtr := NIL;
  OSAtomicTestAndSetPtr              := NIL;
  OSAtomicTestAndSetBarrierPtr       := NIL;
  OSAtomicTestAndClearPtr            := NIL;
  OSAtomicTestAndClearBarrierPtr     := NIL;
  OSSpinLockTryPtr                   := NIL;
  OSSpinLockLockPtr                  := NIL;
  OSSpinLockUnlockPtr                := NIL;
  OSMemoryBarrierPtr                 := NIL;


  if (Gestalt(gestaltSystemVersion, MacVersion) = noErr) &
     (MacVersion >= $1040)  (* au moins Mac OS X 10.4 *)
    then
      begin

        {$ifc defined __GPC__ }
        whichFramework := 'System.framework';        // GNU Pascal probably builds a Mach-O application
        {$elsec}
        whichFramework := 'CoreServices.framework';  // CodeWarrior probably builds a CFM application
        {$endc}

        OSAtomicAdd32Ptr                   := OSAtomicChange32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAdd32'));
        OSAtomicAdd32BarrierPtr            := OSAtomicChange32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAdd32Barrier'));
        OSAtomicOr32Ptr                    := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicOr32'));
        OSAtomicOr32BarrierPtr             := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicOr32Barrier'));
        OSAtomicAnd32Ptr                   := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAnd32'));
        OSAtomicAnd32BarrierPtr            := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAnd32Barrier'));
        OSAtomicXor32Ptr                   := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicXor32'));
        OSAtomicXor32BarrierPtr            := OSAtomicLogical32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicXor32Barrier'));
        OSAtomicCompareAndSwap32Ptr        := OSAtomicCompareAndSwap32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicCompareAndSwap32'));
        OSAtomicCompareAndSwap32BarrierPtr := OSAtomicCompareAndSwap32FuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicCompareAndSwap32Barrier'));
        OSAtomicTestAndSetPtr              := OSAtomicTestAndSetFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndSet'));
        OSAtomicTestAndSetBarrierPtr       := OSAtomicTestAndSetFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndSetBarrier'));
        OSAtomicTestAndClearPtr            := OSAtomicTestAndSetFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndClear'));
        OSAtomicTestAndClearBarrierPtr     := OSAtomicTestAndSetFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndClearBarrier'));
        OSSpinLockTryPtr                   := OSSpinLockFuncPtr(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockTry'));
        OSSpinLockLockPtr                  := OSSpinLockProcPtr(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockLock'));
        OSSpinLockUnlockPtr                := OSSpinLockProcPtr(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockUnlock'));
        OSMemoryBarrierPtr                 := OSMemoryBarrierProcPtr(GetFunctionPointerFromBundle( whichFramework, 'OSMemoryBarrier'));

        (*
        WritelnNumDansRapport('OSAtomicAdd32Ptr = ',                  SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAdd32')));
        WritelnNumDansRapport('OSAtomicAdd32BarrierPtr = ',           SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAdd32Barrier')));
        WritelnNumDansRapport('OSAtomicOr32Ptr = ',                   SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicOr32')));
        WritelnNumDansRapport('OSAtomicOr32BarrierPtr = ',            SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicOr32Barrier')));
        WritelnNumDansRapport('OSAtomicAnd32Ptr = ',                  SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAnd32')));
        WritelnNumDansRapport('OSAtomicAnd32BarrierPtr = ',           SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicAnd32Barrier')));
        WritelnNumDansRapport('OSAtomicXor32Ptr = ',                  SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicXor32')));
        WritelnNumDansRapport('OSAtomicXor32BarrierPtr = ',           SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicXor32Barrier')));
        WritelnNumDansRapport('OSAtomicCompareAndSwap32Ptr = ',       SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicCompareAndSwap32')));
        WritelnNumDansRapport('OSAtomicCompareAndSwap32BarrierPtr = ',SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicCompareAndSwap32Barrier')));
        WritelnNumDansRapport('OSAtomicTestAndSetPtr = ',             SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndSet')));
        WritelnNumDansRapport('OSAtomicTestAndSetBarrierPtr = ',      SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndSetBarrier')));
        WritelnNumDansRapport('OSAtomicTestAndClearPtr = ',           SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndClear')));
        WritelnNumDansRapport('OSAtomicTestAndClearBarrierPtr = ',    SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSAtomicTestAndClearBarrier')));
        WritelnNumDansRapport('OSSpinLockTryPtr = ',                  SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockTry')));
        WritelnNumDansRapport('OSSpinLockLockPtr = ',                 SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockLock')));
        WritelnNumDansRapport('OSSpinLockUnlockPtr = ',               SInt32(GetFunctionPointerFromBundle( whichFramework, 'OSSpinLockUnlock')));
        *)

      end;


  CanInitializeOSAtomicUnit :=  ( OSAtomicAdd32Ptr                   <> NIL ) &
                                ( OSAtomicAdd32BarrierPtr            <> NIL ) &
                                ( OSAtomicOr32Ptr                    <> NIL ) &
                                ( OSAtomicOr32BarrierPtr             <> NIL ) &
                                ( OSAtomicAnd32Ptr                   <> NIL ) &
                                ( OSAtomicAnd32BarrierPtr            <> NIL ) &
                                ( OSAtomicXor32Ptr                   <> NIL ) &
                                ( OSAtomicXor32BarrierPtr            <> NIL ) &
                                ( OSAtomicCompareAndSwap32Ptr        <> NIL ) &
                                ( OSAtomicCompareAndSwap32BarrierPtr <> NIL ) &
                                ( OSAtomicTestAndSetPtr              <> NIL ) &
                                ( OSAtomicTestAndSetBarrierPtr       <> NIL ) &
                                ( OSAtomicTestAndClearPtr            <> NIL ) &
                                ( OSAtomicTestAndClearBarrierPtr     <> NIL ) &
                                ( OSSpinLockTryPtr                   <> NIL ) &
                                ( OSSpinLockLockPtr                  <> NIL ) &
                                ( OSSpinLockUnlockPtr                <> NIL ) &
                                ( OSMemoryBarrierPtr                 <> NIL );

end;



procedure OSAtomicAdd32(theAmount : SInt32; var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32Ptr(theAmount, theValue);
end;


procedure OSAtomicAdd32Barrier(theAmount : SInt32; var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32BarrierPtr(theAmount, theValue);
end;


procedure OSAtomicIncrement32( var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32Ptr( +1, theValue);
end;


procedure OSAtomicIncrement32Barrier( var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32BarrierPtr( +1, theValue);
end;


procedure OSAtomicDecrement32( var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32Ptr( -1, theValue);
end;


procedure OSAtomicDecrement32Barrier( var theValue : SInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAdd32BarrierPtr( -1, theValue);
end;


procedure OSAtomicOr32(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicOr32Ptr(theMask,theValue);
end;


procedure OSAtomicOr32Barrier(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicOr32BarrierPtr(theMask,theValue);
end;


procedure OSAtomicAnd32(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAnd32Ptr(theMask,theValue);
end;


procedure OSAtomicAnd32Barrier(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicAnd32BarrierPtr(theMask,theValue);
end;


procedure OSAtomicXor32(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicXor32Ptr(theMask,theValue);
end;


procedure OSAtomicXor32Barrier(theMask : UInt32; var theValue : UInt32 );
var foo : SInt32;
begin
  foo := OSAtomicXor32BarrierPtr(theMask,theValue);
end;






{* Compare and swap.  They return true if the swap occured.
 *}
function OSAtomicCompareAndSwap32(oldValue : SInt32; newValue : SInt32; var theValue : SInt32 ) : SInt32;
begin
  OSAtomicCompareAndSwap32 := OSAtomicCompareAndSwap32Ptr(oldValue, newValue, theValue);
end;


function OSAtomicCompareAndSwap32Barrier(oldValue : SInt32; newValue : SInt32; var theValue : SInt32 ) : SInt32;
begin
  OSAtomicCompareAndSwap32Barrier := OSAtomicCompareAndSwap32BarrierPtr(oldValue, newValue, theValue);
end;





{* Test and set.  They return the original value of the bit, and operate on bit (0x80 >> (n&7))
 * in byte ((char*)theAddress + (n >> 3)).  They are layered on top of the compare-and-swap
 * operation.
 *}
function OSAtomicTestAndSet(n : UInt32; theAddress : Ptr) : SInt32;
begin
  OSAtomicTestAndSet := OSAtomicTestAndSetPtr(n, theAddress);
end;


function OSAtomicTestAndSetBarrier(n : UInt32; theAddress : Ptr) : SInt32;
begin
  OSAtomicTestAndSetBarrier := OSAtomicTestAndSetBarrierPtr(n , theAddress);
end;


function OSAtomicTestAndClear(n : UInt32; theAddress : Ptr) : SInt32;
begin
  OSAtomicTestAndClear := OSAtomicTestAndClearPtr(n, theAddress);
end;


function OSAtomicTestAndClearBarrier(n : UInt32; theAddress : Ptr ) : SInt32;
begin
  OSAtomicTestAndClearBarrier := OSAtomicTestAndClearBarrierPtr(n, theAddress);
end;



{* Spinlocks.  These use memory barriers as required to synchronize access to shared
 * memory protected by the lock.  The lock operation spins, but employs various strategies
 * to back off if the lock is held, making it immune to most priority-inversion livelocks.
 * The try operation immediately returns false if the lock was held, true if it took the
 * lock.  The convention is that unlocked is zero, locked is nonzero.
 *}


function     OSSpinLockTry( var lock : OSSpinLock ) : SInt32;
begin
  OSSpinLockTry := OSSpinLockTryPtr(lock);
end;


procedure    OSSpinLockLock( var lock : OSSpinLock );
begin
  OSSpinLockLockPtr(lock);
end;


procedure    OSSpinLockUnlock( var lock : OSSpinLock );
begin
  OSSpinLockUnlockPtr(lock);
end;




{* Memory barrier.  It is both a read and write barrier.
 *}
procedure    OSMemoryBarrier;
begin
  OSMemoryBarrierPtr;
end;




END.




















