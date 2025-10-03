UNIT UnitDefGeneralSort;

INTERFACE


uses MacTypes;


type LectureTableauProc = function(index : SInt32) : SInt32;
     AffectationProc = procedure(index,element : SInt32);
     OrdreProc = function(element1,element2 : SInt32) : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}








END.
