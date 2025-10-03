UNIT UnitDefATR;


INTERFACE

TYPE
    ATR = ^ATRRec;
    ATRRec = record
                splitChar : char;
                filsMoins,filsEgal,filsPlus : ATR;
              end;


    ATRProc = procedure(var x : ATR);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
