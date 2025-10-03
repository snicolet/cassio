UNIT UnitDefPackedThorGame;


INTERFACE








USES MacTypes;


TYPE
  PackedThorGame =
    record
      theMoves : packed array[0..61] of UInt8;
    end;
  PackedThorGamePtr = ^PackedThorGame;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}













END.
