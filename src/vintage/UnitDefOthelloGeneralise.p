UNIT UnitDefOthelloGeneralise;



INTERFACE


USES MacTypes;


CONST
  kSizeOthellierMax = 20;

TYPE
  BigOthellier =
       array[0..kSizeOthellierMax+1,0..kSizeOthellierMax+1] of SInt16;

  BigOthelloRec =
        record
          size : Point;
          plateau : BigOthellier;
          trait : SInt16;
        end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.











