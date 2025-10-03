UNIT  UnitDefABR;


INTERFACE


USES MacTypes;


TYPE
    ABRKey = SInt32;
    ABRData = SInt32;
    ABR = ^ABRRec;
    ABRRec = record
                cle : ABRKey;
                data : ABRData;
                gauche,droit,pere : ABR;
              end;



    ABRProc = procedure(var x : ABR);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
