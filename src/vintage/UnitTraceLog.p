UNIT UnitTraceLog;



INTERFACE













 USES UnitDefCassio;




{Gestion du fichier "Cassio.trace.log"}
procedure SetTracingLog(flag : boolean);
function GetTraceLogState : boolean;
procedure WriteInTraceLog(s : String255);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    TextEdit, MacErrors
{$IFC NOT(USE_PRELINK)}
    , UnitRapportImplementation, UnitServicesDialogs, MyStrings, UnitServicesRapport, UnitCarbonisation, UnitFichiersTEXT
     ;
{$ELSEC}
    ;
    {$I prelink/TraceLog.lk}
{$ENDC}


{END_USE_CLAUSE}











const tracingState : boolean = true;

var FichierTraceLog : FichierTEXT;





procedure OuvreFichierTrace;
var erreurES : OSErr;
begin
  erreurES := FichierTexteDeCassioExiste('Cassio.trace.log',FichierTraceLog);
  if erreurES = fnfErr then {-43 => fichier non trouvé, on le crée}
    begin
      erreurES := CreeFichierTexteDeCassio('Cassio.trace.log',FichierTraceLog);
      SetFileCreatorFichierTexte(FichierTraceLog,MY_FOUR_CHAR_CODE('R*ch'));  {BBEdit}
      SetFileTypeFichierTexte(FichierTraceLog,MY_FOUR_CHAR_CODE('TEXT'));
    end;
  if erreurES = NoErr then
    erreurES := OuvreFichierTexte(FichierTraceLog);
end;

procedure FermeFichierTrace;
var erreurES : OSErr;
begin
  erreurES := FermeFichierTexte(FichierTraceLog);
end;


procedure WriteInTraceLog(s : String255);
var erreurES : OSErr;
    oldEcritureDansLog : boolean;
    oldTraceState : boolean;
    oldDebuggageUnitFichierTexte : boolean;
begin
  if tracingState then
    begin
      oldDebuggageUnitFichierTexte := GetDebuggageUnitFichiersTexte;
		  oldEcritureDansLog := GetEcritToutDansRapportLog;
		  oldTraceState := GetTraceLogState;

		  SetDebuggageUnitFichiersTexte(false);
		  SetEcritToutDansRapportLog(false);
		  SetTracingLog(false);

		  OuvreFichierTrace;
		  erreurES := SetPositionTeteLectureFinFichierTexte(FichierTraceLog);
		  erreurES := WritelnDansFichierTexte(FichierTraceLog,s);
		  FermeFichierTrace;

		  SetDebuggageUnitFichiersTexte(oldDebuggageUnitFichierTexte);
		  SetEcritToutDansRapportLog(oldEcritureDansLog);
		  SetTracingLog(oldTraceState);
		end;
end;


procedure SetTracingLog(flag : boolean);
begin
  tracingState := flag;
end;

function GetTraceLogState : boolean;
begin
  GetTraceLogState := tracingState;
end;



END.


