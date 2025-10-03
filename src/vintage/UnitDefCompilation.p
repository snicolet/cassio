UNIT UnitDefCompilation;


INTERFACE


USES
  UnitDefSet, UnitDefFichiersTEXT, UnitDefATR, UnitDefLongString;

TYPE
  Module = ^ModuleRec;
  ModuleRec =   record
                  nomModule : String255;
                  symbolesInterface : StringSet;
                  symbolesImplementation : StringSet;
                  symbolesImplementationATR : ATR;
                  symbolesDejaPrelinkes : StringSet;
                end;



  Symbole = ^SymboleRec;
  SymboleRec = record
                 nom : String255;
                 definition : LongString;
                 dansQuelModule : Module;
               end;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
