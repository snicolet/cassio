UNIT UnitDefCFNetworkHTTP;

INTERFACE


USES MyTypes,UnitDefFichierAbstrait, UnitDefLongString;


const kNumberOfAsynchroneNetworkConnections = 64;


var gReserveZonesPourTelecharger :
       record
         numeroEnCours : SInt32;
         table : array[0..kNumberOfAsynchroneNetworkConnections] of
                     record
                       fic                         : FichierAbstrait;
                       petitFichierTampon          : FichierAbstrait;
                       infoNetworkConnection       : LongString;
                     end;
       end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}










END.
