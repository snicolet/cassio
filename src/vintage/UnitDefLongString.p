UNIT UnitDefLongString;


INTERFACE

USES StringTypes;


TYPE

     LongString =
       record
         debutLigne : String255;
         finLigne   : String255;
         complete   : boolean;
       end;

     LongStringPtr = ^LongString;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
