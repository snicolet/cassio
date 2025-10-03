UNIT UnitRapport;


INTERFACE







 USES UnitDefCassio, UnitDefParallelisme;

{la dernire chaine de caracteres ecrite dans le rapport}
function LastStringEcriteDansRapport : String255;                                                                                                                                   ATTRIBUTE_NAME('LastStringEcriteDansRapport')

{insertion de texte dans le rapport}
{procedure InsereTexteDansRapportSync(text : Ptr; length : SInt32; scrollerSynchronisation : boolean);}
procedure InsereStringDansRapportSync(s : String255; scrollerSynchronisation : boolean);                                                                                            ATTRIBUTE_NAME('InsereStringDansRapportSync')
procedure InsereStringlnDansRapportSync(s : String255; scrollerSynchronisation : boolean);                                                                                          ATTRIBUTE_NAME('InsereStringlnDansRapportSync')
procedure WriteDansRapportSync(s : String255; scrollerSynchronisation : boolean);                                                                                                   ATTRIBUTE_NAME('WriteDansRapportSync')
procedure WritelnDansRapportSync(s : String255; scrollerSynchronisation : boolean);                                                                                                 ATTRIBUTE_NAME('WritelnDansRapportSync')
procedure InsereTexteDansRapport(text : Ptr; length : SInt32);                                                                                                                      ATTRIBUTE_NAME('InsereTexteDansRapport')
procedure InsereStringDansRapport(s : String255);                                                                                                                                   ATTRIBUTE_NAME('InsereStringDansRapport')
procedure InsereStringlnDansRapport(s : String255);                                                                                                                                 ATTRIBUTE_NAME('InsereStringlnDansRapport')
procedure WriteDansRapport(s : String255);                                                                                                                                          ATTRIBUTE_NAME('WriteDansRapport')
procedure WritelnDansRapport(s : String255);                                                                                                                                        ATTRIBUTE_NAME('WritelnDansRapport')
procedure WritelnDansRapportSansRepeter(s : String255);                                                                                                                             ATTRIBUTE_NAME('WritelnDansRapportSansRepeter')
procedure WritelnDansRapportThreadSafe(s : String255);                                                                                                                              ATTRIBUTE_NAME('WritelnDansRapportThreadSafe')
procedure WritelnDansRapportEtAttendFrappeClavier(s : String255; bip : boolean);                                                                                                    ATTRIBUTE_NAME('WritelnDansRapportEtAttendFrappeClavier')

{des synonymes de fonctions declarees plus hautÉ}
procedure WriteStringDansRapport(s : String255);                                                                                                                                    ATTRIBUTE_NAME('WriteStringDansRapport')
procedure WritelnStringDansRapport(s : String255);                                                                                                                                  ATTRIBUTE_NAME('WritelnStringDansRapport')
procedure WritelnInterruptionDansRapport(uneInterruption : SInt16);                                                                                                                 ATTRIBUTE_NAME('WritelnInterruptionDansRapport')
procedure EcritTypeInterruptionDansRapport(uneinterruption : SInt16);                                                                                                               ATTRIBUTE_NAME('EcritTypeInterruptionDansRapport')

{ecriture des numeriques dans le rapport}
procedure WriteNumDansRapport(s : String255; num : SInt32);                                                                                                                         ATTRIBUTE_NAME('WriteNumDansRapport')
procedure WritelnNumDansRapport(s : String255; num : SInt32);                                                                                                                       ATTRIBUTE_NAME('WritelnNumDansRapport')

{ecriture des numeriques dans le rapport, en separant les chiffres par groupe de trois}
procedure WriteNumEnSeparantLesMilliersDansRapport(num : SInt32);                                                                                                                   ATTRIBUTE_NAME('WriteNumEnSeparantLesMilliersDansRapport')
procedure WritelnNumEnSeparantLesMilliersDansRapport(num : SInt32);                                                                                                                 ATTRIBUTE_NAME('WritelnNumEnSeparantLesMilliersDansRapport')
procedure WriteStringAndNumEnSeparantLesMilliersDansRapport(s : String255; num : SInt32);                                                                                           ATTRIBUTE_NAME('WriteStringAndNumEnSeparantLesMilliersDansRapport')
procedure WritelnStringAndNumEnSeparantLesMilliersDansRapport(s : String255; num : SInt32);                                                                                         ATTRIBUTE_NAME('WritelnStringAndNumEnSeparantLesMilliersDansRapport')

{ecriture des reels dans le rapport}
procedure WriteReelDansRapport(x : double_t; nbDecimales : SInt16);                                                                                                                 ATTRIBUTE_NAME('WriteReelDansRapport')
procedure WritelnReelDansRapport(x : double_t; nbDecimales : SInt16);                                                                                                               ATTRIBUTE_NAME('WritelnReelDansRapport')
procedure WriteStringAndReelDansRapport(s : String255; x : double_t; nbDecimales : SInt16);                                                                                         ATTRIBUTE_NAME('WriteStringAndReelDansRapport')
procedure WritelnStringAndReelDansRapport(s : String255; x : double_t; nbDecimales : SInt16);                                                                                       ATTRIBUTE_NAME('WritelnStringAndReelDansRapport')

{ecriture des reels dans le rapport, en separant les chiffres par groupe de trois}
procedure WriteReelEnSeparantLesMilliersDansRapport(x : double_t; nbDecimales : SInt16);                                                                                            ATTRIBUTE_NAME('WriteReelEnSeparantLesMilliersDansRapport')
procedure WritelnReelEnSeparantLesMilliersDansRapport(x : double_t; nbDecimales : SInt16);                                                                                          ATTRIBUTE_NAME('WritelnReelEnSeparantLesMilliersDansRapport')
procedure WriteStringAndReelEnSeparantLesMilliersDansRapport(s : String255; x : double_t; nbDecimales : SInt16);                                                                    ATTRIBUTE_NAME('WriteStringAndReelEnSeparantLesMilliersDansRapport')
procedure WritelnStringAndReelEnSeparantLesMilliersDansRapport(s : String255; x : double_t; nbDecimales : SInt16);                                                                  ATTRIBUTE_NAME('WritelnStringAndReelEnSeparantLesMilliersDansRapport')

{ecriture des positions dans le rapport}
procedure WritelnPositionDansRapport(var position : plateauOthello);                                                                                                                ATTRIBUTE_NAME('WritelnPositionDansRapport')
procedure WritelnPositionEtTraitDansRapport(const position : plateauOthello; trait : SInt32);                                                                                       ATTRIBUTE_NAME('WritelnPositionEtTraitDansRapport')
procedure WritelnPlatValeurDansRapport(var plateau : platValeur);                                                                                                                   ATTRIBUTE_NAME('WritelnPlatValeurDansRapport')
procedure WritelnBigOthelloDansRapport(var position : BigOthelloRec);                                                                                                               ATTRIBUTE_NAME('WritelnBigOthelloDansRapport')

{ecriture des coups dans le rapport}
procedure WriteCoupDansRapport(square : SInt16);                                                                                                                                    ATTRIBUTE_NAME('WriteCoupDansRapport')
procedure WritelnCoupDansRapport(square : SInt16);                                                                                                                                  ATTRIBUTE_NAME('WritelnCoupDansRapport')
procedure WriteStringAndCoupDansRapport(s : String255; square : SInt16);                                                                                                            ATTRIBUTE_NAME('WriteStringAndCoupDansRapport')
procedure WritelnStringAndCoupDansRapport(s : String255; square : SInt16);                                                                                                          ATTRIBUTE_NAME('WritelnStringAndCoupDansRapport')
procedure WriteCoupAndNumDansRapport(square : SInt32; num : SInt32);                                                                                                                ATTRIBUTE_NAME('WriteCoupAndNumDansRapport')
procedure WritelnCoupAndNumDansRapport(square : SInt32; num : SInt32);                                                                                                              ATTRIBUTE_NAME('WritelnCoupAndNumDansRapport')

{ecriture des booleens dans le rapport}
procedure WriteBooleenDansRapport(b : boolean);                                                                                                                                     ATTRIBUTE_NAME('WriteBooleenDansRapport')
procedure WritelnBooleenDansRapport(b : boolean);                                                                                                                                   ATTRIBUTE_NAME('WritelnBooleenDansRapport')
procedure WriteStringAndBooleenDansRapport(s : String255; b : boolean);                                                                                                             ATTRIBUTE_NAME('WriteStringAndBooleenDansRapport')
procedure WritelnStringAndBooleenDansRapport(s : String255; b : boolean);                                                                                                           ATTRIBUTE_NAME('WritelnStringAndBooleenDansRapport')
{des synonymesÉ}
procedure WriteBooleanDansRapport(b : boolean);                                                                                                                                     ATTRIBUTE_NAME('WriteBooleanDansRapport')
procedure WritelnBooleanDansRapport(b : boolean);                                                                                                                                   ATTRIBUTE_NAME('WritelnBooleanDansRapport')
procedure WriteStringAndBooleanDansRapport(s : String255; b : boolean);                                                                                                             ATTRIBUTE_NAME('WriteStringAndBooleanDansRapport')
procedure WritelnStringAndBooleanDansRapport(s : String255; b : boolean);                                                                                                           ATTRIBUTE_NAME('WritelnStringAndBooleanDansRapport')
procedure WriteBoolDansRapport(b : boolean);                                                                                                                                        ATTRIBUTE_NAME('WriteBoolDansRapport')
procedure WritelnBoolDansRapport(b : boolean);                                                                                                                                      ATTRIBUTE_NAME('WritelnBoolDansRapport')
procedure WriteStringAndBoolDansRapport(s : String255; b : boolean);                                                                                                                ATTRIBUTE_NAME('WriteStringAndBoolDansRapport')
procedure WritelnStringAndBoolDansRapport(s : String255; b : boolean);                                                                                                              ATTRIBUTE_NAME('WritelnStringAndBoolDansRapport')

{ecriture dans le rapport, mais seulement s'il est ouvert}
procedure WritelnDansRapportOuvert(s : String255);                                                                                                                                  ATTRIBUTE_NAME('WritelnDansRapportOuvert')
procedure WritelnNumDansRapportOuvert(s : String255; num : SInt32);                                                                                                                 ATTRIBUTE_NAME('WritelnNumDansRapportOuvert')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , SNEvents, UnitScannerUtils, MyStrings, MyFonts, UnitRapportImplementation, UnitServicesRapport
     ;
{$ELSEC}
    ;
    {$I prelink/Rapport.lk}
{$ENDC}


{END_USE_CLAUSE}






const
  gLastStringEcriteDansRapport : String255 = '';


function LastStringEcriteDansRapport : String255;
begin
  LastStringEcriteDansRapport := gLastStringEcriteDansRapport;
end;


procedure InsereStringDansRapportSync(s : String255; scrollerSynchronisation : boolean);
var longueur : SInt32;
begin
  longueur := LENGTH_OF_STRING(s);
  InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);

  if (longueur >= 2) then gLastStringEcriteDansRapport := s;
end;

procedure InsereStringlnDansRapportSync(s : String255; scrollerSynchronisation : boolean);
var longueur : SInt32;
begin
  s := s + chr(13);
  longueur := LENGTH_OF_STRING(s);
  InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);

  if (longueur >= 2) then gLastStringEcriteDansRapport := s;
end;

procedure WriteDansRapportSync(s : String255; scrollerSynchronisation : boolean);
var longueur : SInt32;
    longueurRapport,selectionDebut,selectionFin : SInt32;
    errDebug : OSStatus;
begin

  if (s = '') then exit(WriteDansRapportSync);

  errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);

  if GetRapportTextHandle <> NIL then
    begin
	    longueurRapport := GetTailleRapport;
	    selectionDebut := GetDebutSelectionRapport;
	    selectionFin := GetFinSelectionRapport;
	    if (selectionDebut <> selectionFin) | (selectionDebut <> longueurRapport)
	      then SelectionnerTexteDansRapport(longueurRapport,longueurRapport);
	    longueur := LENGTH_OF_STRING(s);
	    InsereTexteDansRapportSync(@s[1],longueur,scrollerSynchronisation);

	    if (longueur >= 2) then gLastStringEcriteDansRapport := s;
	  end;

	errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
end;

procedure WritelnDansRapportSync(s : String255; scrollerSynchronisation : boolean);
begin
  s := s + chr(13);
  WriteDansRapportSync(s,scrollerSynchronisation);
end;

procedure InsereTexteDansRapport(text : Ptr; length : SInt32);
begin
  InsereTexteDansRapportSync(text,length,true);
end;

procedure InsereStringDansRapport(s : String255);
begin
  InsereStringDansRapportSync(s,true);
end;

procedure InsereStringlnDansRapport(s : String255);
begin
  InsereStringlnDansRapportSync(s,true);
end;


procedure WriteDansRapport(s : String255);
begin
  WriteDansRapportSync(s,true);
end;

procedure WritelnDansRapport(s : String255);
begin
  WritelnDansRapportSync(s,true);
end;

procedure WritelnDansRapportSansRepeter(s : String255);
begin
  if ((s+chr(13)) <> LastStringEcriteDansRapport) then
    WritelnDansRapport(s);
end;

procedure WritelnDansRapportThreadSafe(s : String255);
begin

  s := s + chr(13);

  AjouterStringDansListePourRapportThreadSafe(s);

end;


procedure WritelnDansRapportEtAttendFrappeClavier(s : String255; bip : boolean);
begin
  WritelnDansRapport(s);
  if bip then SysBeep(0);
  AttendFrappeClavier;
end;



procedure WriteStringDansRapport(s : String255);
begin
  WriteDansRapport(s);
end;

procedure WriteBooleenDansRapport(b : boolean);
begin
  if b
    then WriteDansRapport('true')
    else WriteDansRapport('false');
end;


procedure WritelnBooleenDansRapport(b : boolean);
begin
  if b
    then WritelnDansRapport('true')
    else WritelnDansRapport('false');
end;

procedure WriteStringAndBooleenDansRapport(s : String255; b : boolean);
begin
   if b
    then WriteDansRapport(s+'true')
    else WriteDansRapport(s+'false');
end;

procedure WritelnStringAndBooleenDansRapport(s : String255; b : boolean);
begin
   if b
    then WritelnDansRapport(s+'true')
    else WritelnDansRapport(s+'false');
end;

procedure WriteBooleanDansRapport(b : boolean);
begin
  WriteBooleenDansRapport(b);
end;

procedure WritelnBooleanDansRapport(b : boolean);
begin
  WritelnBooleenDansRapport(b);
end;

procedure WriteStringAndBooleanDansRapport(s : String255; b : boolean);
begin
  WriteStringAndBooleenDansRapport(s,b);
end;

procedure WritelnStringAndBooleanDansRapport(s : String255; b : boolean);
begin
  WritelnStringAndBooleenDansRapport(s,b);
end;


procedure WriteBoolDansRapport(b : boolean);
begin
  WriteBooleenDansRapport(b);
end;

procedure WritelnBoolDansRapport(b : boolean);
begin
  WritelnBooleenDansRapport(b);
end;

procedure WriteStringAndBoolDansRapport(s : String255; b : boolean);
begin
  WriteStringAndBooleenDansRapport(s,b);
end;

procedure WritelnStringAndBoolDansRapport(s : String255; b : boolean);
begin
  WritelnStringAndBooleenDansRapport(s,b);
end;

procedure EcritTypeInterruptionDansRapport(uneinterruption : SInt16);
begin
  case uneInterruption of
     pasdinterruption                         : WritelnDansRapport('pas d''interruption');
     interruptionSimple                       : WritelnDansRapport('interruption = interruption simple');
     kHumainVeutChangerCouleur                : WritelnDansRapport('interruption = kHumainVeutChangerCouleur');
     kHumainVeutChargerBase                   : WritelnDansRapport('interruption = kHumainVeutChargerBase');
     kHumainVeutAnalyserFinale                : WritelnDansRapport('interruption = kHumainVeutAnalyserFinale');
     kHumainVeutJouerSolitaires               : WritelnDansRapport('interruption = kHumainVeutJouerSolitaires');
     kHumainVeutRechercherSolitaires          : WritelnDansRapport('interruption = kHumainVeutRechercherSolitaires');
     kHumainVeutChangerHumCtreHum             : WritelnDansRapport('interruption = kHumainVeutChangerHumCtreHum');
     kHumainVeutChangerCoulEtHumCtreHum       : WritelnDansRapport('interruption = kHumainVeutChangerCoulEtHumCtreHum');
     kHumainVeutOuvrirFichierScriptFinale     : WritelnDansRapport('interruption = kHumainVeutOuvrirFichierScriptFinale');
     kHumainVeutCalculerScoresTheoriquesWThor : WritelnDansRapport('interruption = kHumainVeutCalculerScoresTheoriquesWThor');
     interruptionDepassementTemps             : WritelnDansRapport('interruption = interruptionDepassementTemps');
     interruptionPositionADisparuDuZoo        : WritelnDansRapport('interruption = interruptionPositionADisparuDuZoo');
     otherwise                                  WritelnNumDansRapport('interruption inconnue !!!!!!!!!!!!!! ',uneInterruption);
  end;
end;

procedure WritelnInterruptionDansRapport(uneInterruption : SInt16);
begin
  EcritTypeInterruptionDansRapport(uneInterruption);
end;


procedure WriteNumDansRapport(s : String255; num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WriteDansRapport(s+s1);
end;

procedure WritelnStringDansRapport(s : String255);
begin
  WritelnDansRapport(s);
end;

procedure WritelnNumDansRapport(s : String255; num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WritelnDansRapport(s+s1);
end;

procedure WriteNumEnSeparantLesMilliersDansRapport(num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WriteDansRapport(SeparerLesChiffresParTrois(s1));
end;

procedure WritelnNumEnSeparantLesMilliersDansRapport(num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WritelnDansRapport(SeparerLesChiffresParTrois(s1));
end;

procedure WriteStringAndNumEnSeparantLesMilliersDansRapport(s : String255; num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WriteDansRapport(s+SeparerLesChiffresParTrois(s1));
end;

procedure WritelnStringAndNumEnSeparantLesMilliersDansRapport(s : String255; num : SInt32);
var s1 : String255;
begin
  s1 := NumEnString(num);
  WritelnDansRapport(s+SeparerLesChiffresParTrois(s1));
end;

procedure WriteReelDansRapport(x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WriteDansRapport(s1);
end;

procedure WritelnReelDansRapport(x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WritelnDansRapport(s1);
end;

procedure WriteStringAndReelDansRapport(s : String255; x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WriteDansRapport(s+s1);
end;

procedure WritelnStringAndReelDansRapport(s : String255; x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  WritelnDansRapport(s+s1);
end;

procedure WriteReelEnSeparantLesMilliersDansRapport(x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  if (nbDecimales <= 0)
    then WriteDansRapport(SeparerLesChiffresParTrois(s1))
    else WriteDansRapport(s1);
end;

procedure WritelnReelEnSeparantLesMilliersDansRapport(x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  if (nbDecimales <= 0)
    then WritelnDansRapport(SeparerLesChiffresParTrois(s1))
    else WritelnDansRapport(s1);
end;

procedure WriteStringAndReelEnSeparantLesMilliersDansRapport(s : String255; x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  if (nbDecimales <= 0)
    then WriteDansRapport(s+SeparerLesChiffresParTrois(s1))
    else WriteDansRapport(s+s1);
end;

procedure WritelnStringAndReelEnSeparantLesMilliersDansRapport(s : String255; x : double_t; nbDecimales : SInt16);
var s1 : String255;
begin
  s1 := ReelEnStringAvecDecimales(x,nbDecimales);
  if (nbDecimales <= 0)
    then WritelnDansRapport(s+SeparerLesChiffresParTrois(s1))
    else WritelnDansRapport(s+s1);
end;


procedure WritelnPositionDansRapport(var position : plateauOthello);
var i,j,x : SInt16;
    s : String255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := position[10*j+i];
          if x = pionNoir then s := s + 'X ' else
	      if x = pionBlanc then s := s + 'O ' else
	      if x = pionVide then s := s + '. ';
        end;
      WritelnDansRapport(s);
    end;
end;

procedure WritelnPositionEtTraitDansRapport(const position : plateauOthello; trait : SInt32);
var i,j,x : SInt16;
    s : String255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := position[10*j+i];
          if x = pionNoir then s := s + 'X ' else
	      if x = pionBlanc then s := s + 'O ' else
	      if x = pionVide then s := s + '. ';
        end;
      if j = 8 then
        case trait of
          pionNoir : s := s + '     trait ˆ X';
          pionBlanc: s := s + '     trait ˆ O';
          otherwise  s := s + '     trait = ??'+' ('+NumEnString(trait)+')';
        end; {case}
      WritelnDansRapport(s);
    end;
end;

procedure WritelnBigOthelloDansRapport(var position : BigOthelloRec);
var i,j,x : SInt16;
    s : String255;
begin
  ChangeFontDansRapport(MonacoID);
  for j := 1 to position.size.v do
    begin
      s := '';
      for i := 1 to position.size.h do
        begin
          s := '';
          x := position.plateau[i,j];
          if x = pionNoir then s := s + 'X ' else
	      if x = pionBlanc then s := s + 'O ' else
	      if x = pionVide then s := s + '. ';
	      WriteDansRapport(s);
        end;
      if (j < position.size.v)
        then WritelnDansRapport('')
        else
          case position.trait of
            pionNoir : WritelnDansRapport('     trait ˆ X');
            pionBlanc: WritelnDansRapport('     trait ˆ O');
            otherwise  WritelnDansRapport('     trait = ??');
          end;
    end;
end;


procedure WritelnPlatValeurDansRapport(var plateau : platValeur);
var i,j,x : SInt16;
    s : String255;
begin
  for j := 1 to 8 do
    begin
      s := '';
      for i := 1 to 8 do
        begin
          x := plateau[10*j+i];
          s := Concat(s,NumEnString(x),' ');
        end;
      WritelnDansRapport(s);
    end;
end;

procedure WriteCoupDansRapport(square : SInt16);
begin
  WriteDansRapport(CoupEnString(square,true));
end;

procedure WritelnCoupDansRapport(square : SInt16);
begin
  WritelnDansRapport(CoupEnString(square,true));
end;

procedure WriteStringAndCoupDansRapport(s : String255; square : SInt16);
begin
  if (square >= 11) & (square <= 88)
    then WriteDansRapport(s+CoupEnString(square,true))
    else WriteDansRapport(s+CoupEnString(square,true)+'( = '+NumEnString(square)+')');
end;

procedure WritelnStringAndCoupDansRapport(s : String255; square : SInt16);
begin
  if (square >= 11) & (square <= 88)
    then WritelnDansRapport(s+CoupEnString(square,true))
    else WritelnDansRapport(s+CoupEnString(square,true)+'( = '+NumEnString(square)+')');
end;

procedure WriteCoupAndNumDansRapport(square : SInt32; num : SInt32);
begin
  if (square >= 11) & (square <= 88)
    then WriteNumDansRapport(CoupEnString(square,true)+' => ',num)
    else WriteNumDansRapport(CoupEnString(square,true)+'( = '+NumEnString(square)+') => ',num);
end;

procedure WritelnCoupAndNumDansRapport(square : SInt32; num : SInt32);
begin
  if (square >= 11) & (square <= 88)
    then WritelnNumDansRapport(CoupEnString(square,true)+' => ',num)
    else WritelnNumDansRapport(CoupEnString(square,true)+'( = '+NumEnString(square)+') => ',num);
end;

procedure WritelnDansRapportOuvert(s : String255);
begin
  if FenetreRapportEstOuverte then
      WritelnDansRapport(s);
end;

procedure WritelnNumDansRapportOuvert(s : String255; num : SInt32);
begin
  if FenetreRapportEstOuverte then
      WritelnNumDansRapport(s,num);
end;



end.

















































