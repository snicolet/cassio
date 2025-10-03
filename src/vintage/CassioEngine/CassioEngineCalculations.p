Unit CassioEngineCalculations;



INTERFACE

 USES UnitDefCassio;
 
 
 
{ On va implementer en Pascal les fonctions de "EngineCalculation.h" }

function engine_init : Ptr;                                                                                                              ATTRIBUTE_NAME('engine_init')
function engine_midgame_search(engine : Ptr; position : charP; alpha, beta : float_t; depth, precision : SInt32) : float_t;              ATTRIBUTE_NAME('engine_midgame_search')
function engine_endgame_search(engine : Ptr; position : charP; alpha, beta , precision : SInt32) : SInt32;                               ATTRIBUTE_NAME('engine_endgame_search')
procedure engine_stop(engine : Ptr);                                                                                                     ATTRIBUTE_NAME('engine_stop')
procedure engine_print_results(engine : Ptr; thestring : charP);                                                                         ATTRIBUTE_NAME('engine_print_results')
procedure engine_free(engine : Ptr);                                                                                                     ATTRIBUTE_NAME('engine_free')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, MacMemory, Sound, fp
{$IFC NOT(USE_PRELINK)}
    , UnitRapport,  UnitPositionEtTrait, UnitNouvelleEval, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/CassioEngineCalculations.lk}
{$ENDC}


{END_USE_CLAUSE}



procedure SendCassioEngineOutput(s : String255);
begin
  WritelnDansRapport(s);
end;


function engine_init : Ptr;
begin
  engine_init := NIL;
end;

                                                                                             
function engine_midgame_search(engine : Ptr; position : charP; alpha, beta : float_t; depth, precision : SInt32) : float_t;
var s : String255;
    positionEtTrait : PositionEtTraitRec;
begin

  engine_midgame_search := -5000.0;

  // Lecture des fichiers d'evaluation
  PrepareCoefficientsEvaluation;
  
  // transformation de la chaine C en chaine Pascal
  s := BufferToPascalString(Ptr(position),0, 65);
  
  if not(ParsePositionEtTrait(s,positionEtTrait)) then
    begin
      SendCassioEngineOutput('ERROR : impossible to parse the position');
      exit(engine_midgame_search);
    end;
  
  if (GetTraitOfPosition(positionEtTrait) = pionVide) then
    begin
      SendCassioEngineOutput('ERROR : position is finished (no player to move)');
      exit(engine_midgame_search);
    end;
    
  engine_midgame_search := 4.32;
end;

     
function engine_endgame_search(engine : Ptr; position : charP; alpha, beta , precision : SInt32) : SInt32;
var s : String255;
begin

  // Lecture des fichiers d'evaluation
  PrepareCoefficientsEvaluation;
  
  // transformation de la chaine C en chaine Pascal
  s := BufferToPascalString(Ptr(position),0, 65);
    
  engine_endgame_search := -17;
end;

            
procedure engine_stop(engine : Ptr);
begin
end;

                                                                                           
procedure engine_print_results(engine : Ptr; thestring : charP);
begin
end;

                                                              
procedure engine_free(engine : Ptr);
begin
end;                                                                                             



END.