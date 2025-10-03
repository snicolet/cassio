UNIT UnitDefListeCasesVides;


INTERFACE


USES MacTypes;


type celluleCaseVideDansListeChaineePtr = ^celluleCaseVideDansListeChainee;
     celluleCaseVideDansListeChainee =
       record
         square : SInt32;
         next : celluleCaseVideDansListeChaineePtr;
         previous : celluleCaseVideDansListeChaineePtr;
         constantePariteDeSquare : SInt32;
       end;
     tableDePointeurs  = array[0..99] of celluleCaseVideDansListeChaineePtr;
     t_bufferCellulesListeChainee = array[0..65] of celluleCaseVideDansListeChainee;


var gTeteListeChaineeCasesVides : celluleCaseVideDansListeChainee;
    gBufferCellulesListeChainee : t_bufferCellulesListeChainee;
    gTableDesPointeurs : tableDePointeurs;





var gTableBitListeBitboardToSquare : array[0..32] of UInt32;
    gTableBitListeBitboardConstanteDePariteDeSquare : array[0..32] of UInt32;
    gTableSquareToBitCaseVidePourListeBiboard : array[0..99] of UInt32;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
