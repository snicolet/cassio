UNIT  UnitDefABR;


INTERFACE


USES MacTypes;


TYPE
    ABRKey = SInt32;   // warning : should be able to be a pointer, so 64 bits
    ABRData = SInt32;  // warning : should be able to be a pointer, so 64 bits
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
