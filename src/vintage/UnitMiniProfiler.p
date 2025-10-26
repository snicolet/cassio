UNIT UnitMiniProfiler;

INTERFACE










 USES Timer , UnitDefCassio;

(* un mini-profiler pour TrierSelonDivergenceAvecMilieu *)



procedure InitUnitMiniProfiler;
procedure LibereMemoireUnitMiniProfiler;


CONST kpourcentage  = 1;
      ktempsMoyen   = 2;
      kTempsRelatif = 4;

procedure InitMiniProfiler;
procedure AfficheMiniProfilerDansRapport(affichage : SInt32);
procedure AjouterTempsDansMiniProfiler(nbVides,prof : SInt32; microsecondesUtilisees : UInt32; affichage : SInt32);

procedure BeginChronometreMiniprofiler(nbVides,prof : SInt32);
procedure StopChronometreMiniProfiler(nbVides,prof : SInt32);


procedure BeginChronometreRelatif(num : SInt32);
procedure TempsIntermediaireChronometreRelatif(num : SInt32);
procedure StopChronometreRelatif(num : SInt32);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ToolUtils, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyUtils ;
{$ELSEC}
    ;
    {$I prelink/MiniProfiler.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure InitUnitMiniProfiler;
begin
  {$IFC UTILISE_MINIPROFILER}
  InitMiniProfiler;
  {$ENDC}
end;


procedure LibereMemoireUnitMiniProfiler;
begin
end;


const k_MAX_PROF_MINIPROFILER = 40;
      k_MIN_PROF_MINIPROFILER = -5;  { attention : doir rester < 0 }
var  microProfiler :
      record
        dernierTickAffichageMicrosecondes : SInt32;
        total : unsignedWide;
        microtickDepart : array[0..64,k_MIN_PROF_MINIPROFILER..k_MAX_PROF_MINIPROFILER] of unsignedWide;
        temps : array[0..64,k_MIN_PROF_MINIPROFILER..k_MAX_PROF_MINIPROFILER] of unsignedWide;
        occu : array[0..64,k_MIN_PROF_MINIPROFILER..k_MAX_PROF_MINIPROFILER] of SInt32;
      end;

procedure InitMiniProfiler;
var i,j : SInt32;
begin
  with microProfiler do
    begin
      dernierTickAffichageMicrosecondes := 0;
      total.lo := 0;
      total.hi := 0;
      for i := 0 to 64 do
        for j := k_MIN_PROF_MINIPROFILER to k_MAX_PROF_MINIPROFILER do
          begin
            temps[i,j].lo := 0;
            temps[i,j].hi := 0;
            microtickDepart[i,j].lo := 0;
            microtickDepart[i,j].hi := 0;
            occu[i,j] := 0;
          end;
    end;
end;

procedure AjouterTempsDansMiniProfiler(nbVides,prof : SInt32; microsecondesUtilisees : UInt32; affichage : SInt32);
begin
  if (prof < k_MIN_PROF_MINIPROFILER) or (prof > k_MAX_PROF_MINIPROFILER) then
    begin
      WritelnNumDansRapport('ERROR : prof out of range dans AjouterTempsDansMiniProfiler!  prof = ',prof);
      exit(AjouterTempsDansMiniProfiler);
    end;

  if (nbVides < 0) or (nbVides > 64) then
    begin
      WritelnNumDansRapport('ERROR : nbVides out of range dans AjouterTempsDansMiniProfiler! nbVides = ',nbVides);
      exit(AjouterTempsDansMiniProfiler);
    end;

  with microProfiler do
    begin
      total.lo := total.lo + microsecondesUtilisees;
      temps[nbVides,prof].lo := temps[nbVides,prof].lo + microsecondesUtilisees;
      inc(occu[nbVides,prof]);

      if InfosTechniquesDansRapport and
         (TickCount - dernierTickAffichageMicrosecondes >= 3600)  {toutes les 60 sec}
        then AfficheMiniProfilerDansRapport(affichage);
    end;
end;


procedure BeginChronometreMiniprofiler(nbVides,prof : SInt32);
begin
  Microseconds(microProfiler.microtickDepart[nbVides,prof]);
end;


procedure StopChronometreMiniProfiler(nbVides,prof : SInt32);
var microSecondesCurrent : UnsignedWide;
begin
  Microseconds(microSecondesCurrent);
  AjouterTempsDansMiniProfiler(nbVides,prof,microSecondesCurrent.lo-microProfiler.microtickDepart[nbVides,prof].lo,ktempsMoyen);
end;


procedure BeginChronometreRelatif(num : SInt32);
var premiereCelluleVidePourCetteSequence : SInt32;
    microSecondesCurrent : UnsignedWide;
begin

  Microseconds(microSecondesCurrent);

  premiereCelluleVidePourCetteSequence := 0;
  microProfiler.microtickDepart[num,0].lo := microSecondesCurrent.lo;
  microProfiler.microtickDepart[num,0].hi := microSecondesCurrent.hi;

  microProfiler.occu[num,k_MIN_PROF_MINIPROFILER] := premiereCelluleVidePourCetteSequence; {on surcharge}
end;


procedure TempsIntermediaireChronometreRelatif(num : SInt32);
var premiereCelluleVidePourCetteSequence : SInt32;
    microSecondesCurrent : UnsignedWide;
begin
  premiereCelluleVidePourCetteSequence := microProfiler.occu[num,k_MIN_PROF_MINIPROFILER];
  if (premiereCelluleVidePourCetteSequence < k_MAX_PROF_MINIPROFILER) then
    begin
      inc(premiereCelluleVidePourCetteSequence);


      Microseconds(microSecondesCurrent);

      microProfiler.microtickDepart[num,premiereCelluleVidePourCetteSequence].lo := microSecondesCurrent.lo;
      microProfiler.microtickDepart[num,premiereCelluleVidePourCetteSequence].hi := microSecondesCurrent.hi;

      inc(microProfiler.occu[num,premiereCelluleVidePourCetteSequence]);



      microProfiler.occu[num,k_MIN_PROF_MINIPROFILER] := premiereCelluleVidePourCetteSequence;
    end;
end;


procedure StopChronometreRelatif(num : SInt32);
begin
  TempsIntermediaireChronometreRelatif(num);
  AfficheMiniProfilerDansRapport(kTempsRelatif);
end;


procedure AfficheMiniProfilerDansRapport(affichage : SInt32);
var tempsTotal,tempsLocal : double;
    i,j : SInt32;
    remplie : boolean;
begin

  if InfosTechniquesDansRapport then
  with microProfiler do
    begin
      tempsTotal := MicrosecondesToSecondes(total);
      WriteStringAndReelDansRapport('total = ',tempsTotal,4);
      WritelnDansRapport(' sec.');
      for i := 0 to 64 do
        begin
          remplie := false;
          for j := k_MIN_PROF_MINIPROFILER to k_MAX_PROF_MINIPROFILER do
            if (occu[i,j] > 0) then remplie := true;
          if remplie then
            begin
              WriteNumDansRapport(' prof = ',i);
              for j := k_MIN_PROF_MINIPROFILER to k_MAX_PROF_MINIPROFILER do
                if (occu[i,j] > 0) then
	                begin
	                  tempsLocal := MicrosecondesToSecondes(temps[i,j]);

	                  WriteNumDansRapport('  (j = ',j);
	                  WriteNumDansRapport(',occ = ',occu[i,j]);
	                  WriteStringAndReelDansRapport(',temps = ',tempsLocal,4);
	                  WriteDansRapport('s');

	                  if BitAnd(affichage,kpourcentage) <> 0 then
	                    begin
	                      WriteStringAndReelDansRapport('s, ',100.0*tempsLocal/tempsTotal,3);
	                      WriteDansRapport('%');
	                    end;
	                  if BitAnd(affichage,ktempsMoyen) <> 0 then
	                    begin
	                      WriteStringAndReelDansRapport(',moy = ',1000000.0*tempsLocal/(1.0*occu[i,j]),4);
	                      WriteDansRapport('µs');
	                    end;
	                  if BitAnd(affichage,kTempsRelatif) <> 0 then
	                    begin
	                      WriteStringAndReelDansRapport(', ¶ = ',1000000.0*(MicrosecondesToSecondes(microTickDepart[i,j]) - MicrosecondesToSecondes(microTickDepart[i,j-1])),4);
	                      WriteDansRapport('µs');
	                    end;

	                  if BitAnd(affichage,kTempsRelatif) <> 0
	                    then WritelnDansRapport(')')
	                    else WriteDansRapport(')');
	                end;
              WritelnDansRapport('');
            end;
        end;
      WritelnDansRapport('');
      dernierTickAffichageMicrosecondes := TickCount;
    end;
end;



END.
