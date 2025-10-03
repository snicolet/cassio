UNIT UnitDefHugeString;


INTERFACE

USES StringTypes;


TYPE

     HugeString =
       record
         longueur   : SInt32;
         theChars   : CharArrayPtr;
       end;

     HugeStringPtr = ^HugeString;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.

