Unit UnitDefHash;


INTERFACE

USES UnitOth0;


type  DecompressionHashExacteRec =
             record
               valMin               : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               valMax               : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               nbArbresCoupesValMin : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               nbArbresCoupesValMax : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
               coupDeCetteValMin    : array[1..kNbreMaxDeltasSuccessifsDansHashExacte] of SInt32;
             end;

type codePositionRec =
                 record
                   platLigne1,platLigne2,platLigne3,platLigne4 : UInt16;
                   platLigne5,platLigne6,platLigne7,platLigne8 : UInt16;
                   couleurCodage : SInt32;
                   nbreVidesCodage : SInt32;
                 end;


{$IFC USE_DEBUG_STEP_BY_STEP}
var gDebuggageAlgoFinaleStepByStep :
       record
         actif : boolean;
         profMin : SInt32;
         positionsCherchees : PositionEtTraitSet;
       end;
    dummyLong : SInt32;
{$ENDC}



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}













end.
