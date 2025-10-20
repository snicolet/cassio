



{$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }


// Tell the linker the name of the function
function FindLastBitForGNUPascal_in_C(word : UInt32) : UInt32;        EXTERNAL_NAME('FindLastBitForGNUPascal_in_C');


// Compile the C file
{$L CountLeadingZerosForGNUPascal.c }



(*
function CountLeadingZerosForGNUPascal(word : UInt32) : UInt32;
begin
  CountLeadingZerosForGNUPascal :=  32 - FindLastBitForGNUPascal_in_C(word);
end;
*)

{$definec CountLeadingZerosForGNUPascal_AS_A_MACRO(word)  (32 - FindLastBitForGNUPascal_in_C(word)) }




procedure GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE_POUR_INTEL(listeBitboard : UInt32; var square1,square2 : SInt32);
var leadingZeros, leadingZeros2 : UInt32;
 begin

   asm("bsf %0,%1 ; bsr %0,%2" : "=r" (leadingZeros), "=r" (leadingZeros2) : "r" (listeBitboard));

   square1 := gTableBitListeBitboardToSquare[31 - leadingZeros];
   square2 := gTableBitListeBitboardToSquare[31 - leadingZeros2];
 end;



function CountLeadingZerosForGNUPascal(word : UInt32) : UInt32;
var result : UInt32;
begin
  if (word = 0)
    then
      CountLeadingZerosForGNUPascal := 32
    else
      begin
        asm("bsr %0,%1" : "=r" (result) : "r" (word));
        CountLeadingZerosForGNUPascal := 31 - result;
      end;
end;



{$ELSEC}

function CountLeadingZerosForGNUPascal(word : UInt32) : UInt32; attribute (inline);
var result : UInt32;
begin
  asm("cntlzw %0,%1" : "=r" (result) : "r" (word));
  CountLeadingZerosForGNUPascal := result;
end;


{$ENDC}