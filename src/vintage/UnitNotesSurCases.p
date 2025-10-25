UNIT UnitNotesSurCases;



INTERFACE







 USES UnitDefCassio;




{initialisation}
procedure InitUnitNotesSurCases;
procedure LibereMemoireUnitNotesSurCases;

{activation/desactivation}
procedure SetAvecAffichageNotesSurCases(origine : SInt32; flag : boolean);
procedure SetPoliceNameNotesSurCases(origine : SInt32; whichPoliceName : String255);
procedure SetAlternativePoliceNameNotesSurCases(origine : SInt32; whichPoliceName : String255);
procedure SetTailleNotesSurCases(origine : SInt32; whichTaille : SInt16);
procedure SetAlternativeTailleNotesSurCases(origine : SInt32; whichTaille : SInt16);
function GetAvecAffichageNotesSurCases(origine : SInt32) : boolean;
function GetPoliceNameNotesSurCases(origine : SInt32) : String255;
function GetPoliceIDNotesSurCases(origine : SInt32) : SInt16;
function GetTailleNotesSurCases(origine : SInt32) : SInt16;

{procedures d'ecriture}
procedure ViderNotesSurCases(origine : SInt32; effacer : boolean; surQuellesCases : SquareSet);
procedure SetNoteSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
procedure SetFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
procedure AjouterFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
procedure RetirerFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
procedure SetNoteMilieuSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
procedure SetMeilleureNoteSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
procedure SetMeilleureNoteMilieuSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);

{procedures de lecture}
function GetNoteSurCase(origine : SInt32; whichSquare : SInt16) : SInt32;
function GetFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16) : SInt32;
function GetSquareOfMeilleureNoteSurCase(origine : SInt32; var whichSquare : SInt16; var whichNote : SInt32) : boolean;
function EstLaMeilleureCaseDesNotesSurCase(origine : SInt32; whichSquare : SInt16) : boolean;
function CaseALaMeilleureDesNotes(origine : SInt32; whichSquare : SInt16) : boolean;
function EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(whichNote : SInt32) : boolean;
function AuMoinsUneNoteSurCasesEstAffichee(origine : SInt32) : boolean;

{procedures de dessin}
procedure EffaceNoteSurCases(origine : SInt32; surQuellesCases : SquareSet);
procedure DessineNoteSurCases(origine : SInt32; surQuellesCases : SquareSet);
function GetRectAffichageCouleurZebra(whichSquare : SInt32) : rect;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickdrawText, MacWindows, Fonts, ToolUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitScannerUtils, Zebra_to_Cassio, UnitAffichagePlateau
    , UnitTroisiemeDimension, UnitSquareSet, UnitPositionEtTrait, UnitCouleur, MyStrings, UnitCarbonisation, UnitCouleur, UnitAffichageArbreDeJeu
    , UnitGestionDuTemps, MyUtils, MyMathUtils, MyFonts, MyAntialiasing ;
{$ELSEC}
    ;
    {$I prelink/NotesSurCases.lk}
{$ENDC}


{END_USE_CLAUSE}

















procedure InvalidateDessinEnTraceDeRayon(square : SInt16);     external;
function GetValeurDessinEnTraceDeRayon(square : SInt16) : SInt16;     external;




type NotesDurCaseRec = record
                       meilleureCase : SInt16;
                       meilleureNote : SInt32;
                       table_notes   : array[11..88] of SInt32;
                       flags_notes   : array[11..88] of SInt32;
                       policeName    : String255;
                       policeID      : SInt16;
                       policeSize    : SInt16;
                       altPoliceName : String255;
                       altPoliceID   : SInt16;
                       altPoliceSize : SInt16;
                       doitAfficher  : boolean;
                     end;

var gNotesSurCases : array[kNotesDeCassio..kNotesDeZebra] of NotesDurCaseRec;



procedure InitUnitNotesSurCases;
var origine : SInt16;
begin

  origine := kNotesDeCassio;
  ViderNotesSurCases(origine,false,othellierToutEntier);
  SetPoliceNameNotesSurCases(origine,'Geneva');
  SetTailleNotesSurCases(origine,9);  {par defaut}
  SetAlternativePoliceNameNotesSurCases(origine,'Geneva');
  SetAlternativeTailleNotesSurCases(origine,9);  {par defaut}

  origine := kNotesDeZebra;
  ViderNotesSurCases(origine,false,othellierToutEntier);
  SetPoliceNameNotesSurCases(origine,'Geneva');
  SetTailleNotesSurCases(origine,9);  {par defaut}
  SetAlternativePoliceNameNotesSurCases(origine,'Geneva');
  SetAlternativeTailleNotesSurCases(origine,9);  {par defaut}
end;

procedure LibereMemoireUnitNotesSurCases;
begin
end;

procedure SetPoliceIDNotesSurCases(origine : SInt32; whichPolice : SInt16);
begin
  gNotesSurCases[origine].policeID := whichPolice;
end;

procedure SetAlternativePoliceIDNotesSurCases(origine : SInt32; whichPolice : SInt16);
begin
  gNotesSurCases[origine].altPoliceID := whichPolice;
end;

procedure SetPoliceNameNotesSurCases(origine : SInt32; whichPoliceName : String255);
var theID : SInt16;
begin
  EnleveEspacesDeGaucheSurPlace(whichPoliceName);
  if (whichPoliceName <> '') then
    begin
		  theID := MyGetFontNum(whichPoliceName);

		  gNotesSurCases[origine].policeName := whichPoliceName;
		  SetPoliceIDNotesSurCases(origine,theID);
		end;
end;

procedure SetAlternativePoliceNameNotesSurCases(origine : SInt32; whichPoliceName : String255);
var theID : SInt16;
begin
  EnleveEspacesDeGaucheSurPlace(whichPoliceName);
  if (whichPoliceName <> '') then
    begin
		  theID := MyGetFontNum(whichPoliceName);

		  gNotesSurCases[origine].altPoliceName := whichPoliceName;
		  SetAlternativePoliceIDNotesSurCases(origine,theID);
		end;
end;

procedure SetTailleNotesSurCases(origine : SInt32; whichTaille : SInt16);
begin
  if (whichTaille > 4) then
    gNotesSurCases[origine].policeSize := whichTaille;
end;

procedure SetAlternativeTailleNotesSurCases(origine : SInt32; whichTaille : SInt16);
begin
  if (whichTaille > 4) then
    gNotesSurCases[origine].altPoliceSize := whichTaille;
end;

function GetPoliceIDNotesSurCases(origine : SInt32) : SInt16;
begin
  GetPoliceIDNotesSurCases := gNotesSurCases[origine].policeID;
end;

function GetPoliceNameNotesSurCases(origine : SInt32) : String255;
begin
  GetPoliceNameNotesSurCases := gNotesSurCases[origine].policeName;
end;

function GetTailleNotesSurCases(origine : SInt32) : SInt16;
begin
  GetTailleNotesSurCases := gNotesSurCases[origine].policeSize;
end;



procedure SetAvecAffichageNotesSurCases(origine : SInt32; flag : boolean);
begin
  gNotesSurCases[origine].doitAfficher := flag;
end;


function GetAvecAffichageNotesSurCases(origine : SInt32) : boolean;
begin
  if (origine = kNotesDeCassioEtZebra)
    then GetAvecAffichageNotesSurCases := GetAvecAffichageNotesSurCases(kNotesDeCassio) or
                                          GetAvecAffichageNotesSurCases(kNotesDeZebra)
    else GetAvecAffichageNotesSurCases := gNotesSurCases[origine].doitAfficher;
end;


procedure ViderNotesSurCases(origine : SInt32; effacer : boolean; surQuellesCases : SquareSet);
var i : SInt32;
    accumulateur : SquareSet;
begin

  (*
  WritelnDansRapport('Je suis dans ViderNotesSurCases');
  WritelnNumDansRapport('origine = ',origine);
  *)

  if (origine = kNotesDeCassioEtZebra)
    then
      begin
        ViderNotesSurCases(kNotesDeCassio,effacer,surQuellesCases);
        ViderNotesSurCases(kNotesDeZebra,effacer,surQuellesCases);
      end
    else
      begin
        with gNotesSurCases[origine] do
          begin
            meilleureCase := 0;
            meilleureNote := kNoteSurCaseNonDisponible;

            accumulateur := [];
            for i := 11 to 88 do
              begin

                if effacer and (i in surQuellesCases) and
                   GetAvecAffichageNotesSurCases(origine) and
                   (table_notes[i] <> kNoteSurCaseNonDisponible)
                  then accumulateur := accumulateur + [i];

                table_notes[i] := kNoteSurCaseNonDisponible;
                flags_notes[i] := 0;
              end;

            if (accumulateur <> []) then
              EffaceNoteSurCases(origine,accumulateur);
          end;
        end;
end;



procedure SetNoteSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
var oldMeilleureCase : SInt16;
    old_note,oldMeilleureNote : SInt32;
begin
  with gNotesSurCases[origine] do
  if (whichSquare >= 11) and (whichSquare <= 88) and
     ((whichNote = kNoteSurCaseNonDisponible) or
      (whichNote = kNoteSpecialeSurCasePourPerte) or
      (whichNote = kNoteSpecialeSurCasePourNulle) or
      (whichNote = kNoteSpecialeSurCasePourGain) or
      ((whichNote >= -6400) and (whichNote <= 6400)))
    then
	    begin

        (*
	      WritelnDansRapport('еееееееееееееееееееееееееееееее');
	      WriteNumDansRapport('Je suis dans SetNoteSurCase(',origine);
        WriteNumDansRapport(', '+CoupEnStringEnMajuscules(whichSquare)+', ',whichNote);
        WritelnDansRapport(' )');
        *)

	      old_note := table_notes[whichSquare];
	      table_notes[whichSquare] := whichNote;


	      if (origine = kNotesDeCassio) and (old_note = kNoteSurCaseNonDisponible) and
	         (GetNoteSurCase(kNotesDeZebra,whichSquare) = whichNote) and
	         (ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)) and
	         (BAnd(GetAffichageProprietesOfCurrentNode, kNotesZebraSurLesCases) <> 0) then
	        begin
	          EffaceNoteSurCases(origine,[whichSquare]);
	        end;

	      if whichNote > meilleureNote then
	        begin
	          oldMeilleureCase := meilleureCase;
	          oldMeilleureNote := meilleureNote;

	          meilleureNote := whichNote;
	          meilleureCase := whichSquare;

	          if GetAvecAffichageNotesSurCases(origine) then
	            if ((oldMeilleureNote <> kNoteSurCaseNonDisponible) or
	               ((meilleureCase = oldMeilleureCase) and (meilleureNote <> kNoteSurCaseNonDisponible)))  then
    	            begin

    	              if (oldMeilleureNote <> meilleureNote) or
    	                 (oldMeilleureCase <> meilleureCase)
    	                then EffaceNoteSurCases(origine,[oldMeilleureCase]);

    	              if (meilleureCase <> oldMeilleureCase)
    	                then DessineNoteSurCases(origine,[oldMeilleureCase]);

    	            end;
	        end;

	      if GetAvecAffichageNotesSurCases(origine) then
	        begin

	          (*
	          WritelnNumDansRapport('old_note = ',old_note);
	          WritelnNumDansRapport('whichNote = ',whichNote);
	          *)

	          if (old_note <> kNoteSurCaseNonDisponible) and
	             (old_note <> whichNote)
	            then EffaceNoteSurCases(origine,[whichSquare]);

	          if (whichNote <> kNoteSurCaseNonDisponible)
	            then DessineNoteSurCases(origine,[whichSquare]);

	        end;

	     (*
	     WriteNumDansRapport('Sortie de SetNoteSurCase(',origine);
       WriteNumDansRapport(', '+CoupEnStringEnMajuscules(whichSquare)+', ',whichNote);
       WritelnDansRapport(' )');
       WritelnDansRapport('еееееееееееееееееееееееееееееее');
       *)

     end;
end;


procedure SetFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
begin
  with gNotesSurCases[origine] do
    if (whichSquare >= 11) and (whichSquare <= 88) then
      flags_notes[whichSquare] := whichFlags;
end;

procedure AjouterFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
var oldFlags : SInt32;
begin
  with gNotesSurCases[origine] do
    if (whichSquare >= 11) and (whichSquare <= 88) then
      begin
        oldFlags := flags_notes[whichSquare];
        SetFlagsNoteSurCase(origine, whichSquare, oldFlags or whichFlags);
      end;
end;

procedure RetirerFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16; whichFlags : SInt32);
var oldFlags : SInt32;
begin
  with gNotesSurCases[origine] do
    if (whichSquare >= 11) and (whichSquare <= 88) then
      begin
        oldFlags := flags_notes[whichSquare];
        SetFlagsNoteSurCase(origine, whichSquare, (oldFlags and not(whichFlags)));
      end;
end;


procedure SetNoteMilieuSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
begin
  if (origine = kNotesDeCassio)
    then
      begin
        if (whichNote = 0)
          then whichNote := 1;      {on remplace 0.00 par 0.01 pour eviter les pb de nulle}
      end
    else
  if (origine = kNotesDeZebra)
    then
      begin
        if (whichNote mod 100 = 0) then
          if whichNote >= 0
            then dec(whichNote)
            else inc(whichNote);
      end;

  SetNoteSurCase(origine,whichSquare,whichNote);
end;


function GetNoteSurCase(origine : SInt32; whichSquare : SInt16) : SInt32;
begin
  with gNotesSurCases[origine] do
    begin
		  if (whichSquare >= 11) and (whichSquare <= 88)
		    then GetNoteSurCase := table_notes[whichSquare]
		    else GetNoteSurCase := kNoteSurCaseNonDisponible;
		end;
end;


function GetFlagsNoteSurCase(origine : SInt32; whichSquare : SInt16) : SInt32;
begin
  with gNotesSurCases[origine] do
    begin
		  if (whichSquare >= 11) and (whichSquare <= 88)
		    then GetFlagsNoteSurCase := flags_notes[whichSquare]
		    else GetFlagsNoteSurCase := 0;
		end;
end;


function AuMoinsUneNoteSurCasesEstAffichee(origine : SInt32) : boolean;
begin
  if (origine = kNotesDeCassioEtZebra)
    then AuMoinsUneNoteSurCasesEstAffichee := AuMoinsUneNoteSurCasesEstAffichee(kNotesDeCassio) or
                                              AuMoinsUneNoteSurCasesEstAffichee(kNotesDeZebra)
    else AuMoinsUneNoteSurCasesEstAffichee := (gNotesSurCases[origine].meilleureNote <> kNoteSurCaseNonDisponible);
end;


procedure SetMeilleureNoteSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
var oldMeilleureCase : SInt16;
    oldMeilleureNote : SInt32;
begin
  with gNotesSurCases[origine] do
    begin
      oldMeilleureNote := meilleureNote;
      oldMeilleureCase := meilleureCase;

		  if (whichSquare >= 11) and (whichSquare <= 88) and
		     ((whichNote = kNoteSurCaseNonDisponible) or
          (whichNote = kNoteSpecialeSurCasePourPerte) or
          (whichNote = kNoteSpecialeSurCasePourNulle) or
          (whichNote = kNoteSpecialeSurCasePourGain) or
          ((whichNote >= -6400) and (whichNote <= 6400)))
		    then table_notes[whichSquare] := whichNote
		    else whichNote := kNoteSurCaseNonDisponible;

		  meilleureNote := whichNote;
		  meilleureCase := whichSquare;

		  if GetAvecAffichageNotesSurCases(origine) then
		    begin

    		  if (oldMeilleureNote <> meilleureNote) or
	           (oldMeilleureCase <> meilleureCase)
	          then EffaceNoteSurCases(origine,[oldMeilleureCase]);

          if (meilleureCase <> oldMeilleureCase) and
             (GetNoteSurCase(origine,oldMeilleureCase) <> kNoteSurCaseNonDisponible)
            then DessineNoteSurCases(origine,[oldMeilleureCase]);

        end;


		  if GetAvecAffichageNotesSurCases(origine) then
		    begin

		      if (oldMeilleureNote <> meilleureNote) or
			       (oldMeilleureCase <> meilleureCase)
			      then EffaceNoteSurCases(origine,[whichSquare]);

		      if (whichNote <> kNoteSurCaseNonDisponible)
		        then DessineNoteSurCases(origine,[whichSquare]);

		    end;

    end;
end;

procedure SetMeilleureNoteMilieuSurCase(origine : SInt32; whichSquare : SInt16; whichNote : SInt32);
begin
  if (origine = kNotesDeCassio)
    then
      begin
        if whichNote = 0 then whichNote := 1;        {0.00 -> 0.01 pour eviter les pb de nulle}
      end
    else
      begin
        if (whichNote mod 100 = 0) then
          if whichNote >= 0
            then dec(whichNote)
            else inc(whichNote);
      end;

  SetMeilleureNoteSurCase(origine,whichSquare,whichNote);
end;

function GetSquareOfMeilleureNoteSurCase(origine : SInt32; var whichSquare : SInt16; var whichNote : SInt32) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) and (meilleureCase <= 88)
        then
          begin
            GetSquareOfMeilleureNoteSurCase := true;
            whichSquare := meilleureCase;
            whichNote := meilleureNote;
          end
        else
          begin
            GetSquareOfMeilleureNoteSurCase := false;
            whichSquare := 0;
            whichNote := kNoteSurCaseNonDisponible;
          end;
    end;
end;


function EstLaMeilleureCaseDesNotesSurCase(origine : SInt32; whichSquare : SInt16) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) and (meilleureCase <= 88)
        then EstLaMeilleureCaseDesNotesSurCase := (whichSquare = meilleureCase)
        else EstLaMeilleureCaseDesNotesSurCase := false;
    end;
end;


function CaseALaMeilleureDesNotes(origine : SInt32; whichSquare : SInt16) : boolean;
begin
  with gNotesSurCases[origine] do
    begin
      if (meilleureCase >= 11) and (meilleureCase <= 88) and (meilleureNote <> kNoteSurCaseNonDisponible)
        then CaseALaMeilleureDesNotes := (table_notes[whichSquare] = meilleureNote)
        else CaseALaMeilleureDesNotes := false;
    end;
end;


function EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(whichNote : SInt32) : boolean;
begin
  EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra := (whichNote mod 100) <> 0;
end;



procedure EffaceNoteSurCases(origine : SInt32; surQuellesCases : SquareSet);
var i : SInt32;
    tempoDoitAfficherNotesSurCases : boolean;
    accumulateur : SquareSet;
begin

  (*
  WritelnDansRapport('##################################');
  WritelnDansRapport('entree dans EffaceNoteSurCases : ');
  WritelnNumDansRapport('  origine = ',origine);
  WriteDansRapport('  surQuellesCases = ');
  WritelnDansRapport(SquareSetEnString(surQuellesCases));
  *)


  case origine of
    kNotesDeCassio : if ((GetEffacageProprietesOfCurrentNode and kNotesCassioSurLesCases) = 0) then exit(EffaceNoteSurCases);
    kNotesDeZebra  : if ((GetEffacageProprietesOfCurrentNode and kNotesZebraSurLesCases) = 0)  then exit(EffaceNoteSurCases);
  end; {case}


  with gNotesSurCases[origine] do
    begin
      accumulateur := [];

      for i := 11 to 88 do
        if (i in surQuellesCases) and (GetCouleurOfSquareDansJeuCourant(i) = pionVide) and (GetOthellierEstSale(i)) then
          begin
            accumulateur := accumulateur + [i];
          end;


      if (accumulateur <> []) then
        begin
		      tempoDoitAfficherNotesSurCases := GetAvecAffichageNotesSurCases(origine);
		      SetAvecAffichageNotesSurCases(origine,false);

		      for i := 11 to 88 do
		        if i in accumulateur then
		          InvalidateDessinEnTraceDeRayon(i);

		      if aideDebutant
				    then DessineAideDebutant(true,accumulateur)
				    else EffaceAideDebutant(true,true,accumulateur,'EffaceNoteSurCases');

				  SetAvecAffichageNotesSurCases(origine,tempoDoitAfficherNotesSurCases);
				end;
    end;

  (*
  WriteDansRapport('  -> accumulateur = ');
  WritelnDansRapport(SquareSetEnString(accumulateur));
  WritelnDansRapport('sortie dans EffaceNoteSurCases : ');
  *)

end;


function NoteSurCaseEnString(origine : SInt32; valeur : SInt32) : String255;
var s,s1,s2 : String255;
    v,v1,v2 : SInt32;
begin

  s := '';

  if (valeur <> kNoteSurCaseNonDisponible) then
    begin
      if (origine = kNotesDeCassio)
        then
          begin
            if valeur = kNoteSpecialeSurCasePourNulle then s := ReadStringFromRessource(TextesPlateauID,28) else  {nulle}
            if valeur = kNoteSpecialeSurCasePourGain  then s := ReadStringFromRessource(TextesPlateauID,26) else  {gagne}
            if valeur = kNoteSpecialeSurCasePourPerte then s := ReadStringFromRessource(TextesPlateauID,27)  {perd}
              else
                begin
                  s := NumEnString((Abs(valeur) + 49) div 100);
                  if (valeur < 0) and (s <> '0') then
                    s := Concat('-',s);
                end;
          end else
      if (origine = kNotesDeZebra)
        then
          begin
            if valeur = kNoteSpecialeSurCasePourNulle then s := ReadStringFromRessource(TextesPlateauID,28) else  {nulle}
            if valeur = kNoteSpecialeSurCasePourGain  then s := ReadStringFromRessource(TextesPlateauID,26) else  {gagne}
            if valeur = kNoteSpecialeSurCasePourPerte then s := ReadStringFromRessource(TextesPlateauID,27)  {perd}
              else
                begin
    	            v := Abs(valeur);

    	            v1 := v div 100;
    	            v2 := v mod 100;

    	            if (v2 = 0)
    	              then s := NumEnString(v1)
    	              else
    	                begin
    	                  if (v2 = 1) then v2 := 0 else
    	                  if (v2 = 99) then
    	                    begin
    	                      inc(v1);
    	                      v2 := 0;
    	                    end;

          	            s1 := NumEnString(v1);
          	            if (v2 >= 5)
          	              then
          	                begin
          	                  if (v2 <= 85)
          	                    then s2 := NumEnString((v2 + 5) div 10)
          	                    else s2 := '9';
          	                end
          	              else s2 := '0' {+ NumEnString(v2)};

          	            s := s1 + '.' + s2;
          	          end;


    	            if (valeur < 0) and (s <> '0.0') then
    	               s := Concat('-',s);
    	          end;
          end;
    end;


  NoteSurCaseEnString := s;
end;


procedure EcritNoteSurCase(origine,whichSquare,valeur : SInt32; var s : String255);
var oldPort : grafPtr;
    noteCassio,noteZebra : SInt32;
    pasAfficherCassio,pasAfficherZebra : boolean;
    noteSurLePionDore : boolean;
    myRect : rect;
    largeur,nouvelleLargeur,largeurMax : SInt32;
    justification : SInt32;
    {err : OSErr;}
begin

  if (s = '') then exit(EcritNoteSurCase);

  with gNotesSurCases[origine] do
    begin

      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);


       // DETERMINATION DE LA JUSTIFICATION (GAUCHE, CENTREE, DROITE) DE LA NOTE

      noteCassio := GetNoteSurCase(kNotesDeCassio,whichSquare);
      noteZebra := GetNoteSurCase(kNotesDeZebra,whichSquare);


      pasAfficherZebra  := (noteZebra = kNoteSurCaseNonDisponible) or
                           not(ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)) or
                           (BAnd(GetAffichageProprietesOfCurrentNode,kNotesZebraSurLesCases) = 0);

      pasAfficherCassio := {(noteCassio = kNoteSurCaseNonDisponible) or}
                           (BAnd(GetAffichageProprietesOfCurrentNode,kNotesCassioSurLesCases) = 0);


      {
      if (noteCassio = noteZebra) then
        WritelnNumDansRapport('noteCassio = ',noteCassio);
      }


      if ((noteCassio = noteZebra) and not((noteCassio = 1) and (nbreCoup < finDePartie))) or
         ((origine = kNotesDeCassio) and pasAfficherZebra) or
         ((origine = kNotesDeZebra) and pasAfficherCassio ) or
         ((origine = kNotesDeZebra) and (Pos('.',s) <= 0) and (noteCassio = kNoteSurCaseNonDisponible) and (nbreCoup >= finDePartie))
        then
          begin
            justification := kJusticationCentreHori+kJusticationBas;
          end
        else
          begin
            if (origine = kNotesDeCassio)
              then justification := kJusticationGauche+kJusticationBas
              else justification := kJusticationDroite+kJusticationBas;
          end;





      // DETERMINATION DU RECTANGLE D'AFFICHAGE DE LA NOTE

      noteSurLePionDore := CaseContientUnPionDore(whichSquare);

      if CassioEstEn3D and noteSurLePionDore and (BitAnd(justification,kJusticationCentreHori) <> 0)
        then myRect := GetRect3DDessus(whichSquare)
        else myRect := GetBoundingRectOfSquare(whichSquare);

      if (myRect.bottom - myRect.top) >= 32 then InSetRect(myRect,0,1);

      if CassioEstEn3D
        then InSetRect(myRect,4,0)
        else InSetRect(myRect,1,0);

      if not(CassioEstEn3D) then
        RetrecirRectOfSquarePourTexturesAlveolees(myRect);

      if noteSurLePionDore and not(CassioEstEn3D) then
        if LENGTH_OF_STRING(s) >= 4
          then OffSetRect(myRect,0,-6)
          else OffSetRect(myRect,0,-4);

      largeur := myRect.right - myRect.left;
      largeurMax := 70;
      if largeur > largeurMax then
        begin
          nouvelleLargeur := largeur;
          nouvelleLargeur := Max(largeurMax,(nouvelleLargeur * 90) div 100);

          InSetRect(myRect,(largeur - nouvelleLargeur) div 2,0);
        end;



      // DETERMINATION DE LA COULEUR DU TEXTE AFFICHANT LA NOTE

      if EstLaMeilleureCaseDesNotesSurCase(origine,whichSquare) or
         ((origine = kNotesDeZebra) and CaseALaMeilleureDesNotes(origine,whichSquare) and EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeur))
        then
          begin
            if {not(noteSurLePionDore) and }
               (CassioEstEn3D or gCouleurOthellier.estUneImage or RGBColorEstFoncee(gCouleurOthellier.RGB,20000) or (gCouleurOthellier.menuCmd = VertSapinCmd))
              then
                begin
                  ForeColor(cyanColor);  {pour les fonds foncОs : note en bleu}

                  if (Pos('Tsukuda magnetic',gCouleurOthellier.nomFichierTexture) > 0) or
                     (Pos('Spear',gCouleurOthellier.nomFichierTexture) > 0)
                    then RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurCmdToRGBColor(BleuPaleCmd),10000))
                    else
                  if (Pos('Clementoni',gCouleurOthellier.nomFichierTexture) > 0)
                    then RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurCmdToRGBColor(BleuPaleCmd),12000));

                end
              else
                begin
                  ForeColor(redColor);  {pour les fonds clairs : note en rouge}
                end;

             (* RGBForeColor(CouleurCmdToRGBColor(OrangeCmd)); *)
          end
        else
          begin
            if valeur >= 0
              then ForeColor(yellowColor)
              else ForeColor(whiteColor);
          end;





      // AFFICHAGE DE LA NOTE

      {TextSize(policeSize+3);}
      TextSize(policeSize);
      TextFont(policeID);
      TextFace(bold);

      DrawJustifiedStringInRect(myRect,pionNoir,s,justification,whichSquare);


      //TextSize(policeSize);
      //TextSize(30);
      //TextFont(policeID);
      //TextFont(TimesID);
      //TextFace(bold);
      //TextFace(normal);

      //DrawJustifiedStringInRect(myRect,pionNoir,s,justification,whichSquare);
      //DrawJustifiedStringInRect(myRect,pionNoir,s,kJusticationCentreVert,whichSquare);


      ForeColor(blackColor);
    	SetPort(oldPort);

  end;
end;


function GetRectAffichageCouleurZebra(whichSquare : SInt32) : rect;
var theRect : rect;
    retrecissement : SInt32;
    largeurMax : SInt32;
    largeurActuelle : SInt32;
    facteurEchelle : double_t;
begin
  theRect := GetBoundingRectOfSquare(whichSquare);

  if not(CassioEstEn3D) then RetrecirRectOfSquarePourTexturesAlveolees(theRect);

  retrecissement := Min(15, GetTailleCaseCourante div 4);
  if CassioEstEn3D
    then
      begin
        InsetRect(theRect,retrecissement-2,retrecissement-3);
        OffSetRect(theRect,0,1);
      end
    else
      InsetRect(theRect,retrecissement,retrecissement);

  with theRect do
    begin
      largeurMax := 45;
      largeurActuelle := right - left;

      if (largeurActuelle > largeurMax) and (largeurActuelle > 0) then
        begin
          facteurEchelle := 1.0*largeurMax/largeurActuelle;

          { WritelnNumDansRapport('facteurEchelle = ',MyTrunc(facteurEchelle * 1000)); }

          InSetRect(theRect, ((right - left) - largeurMax) div 2, 0);
          InSetRect(theRect, 0, MyTrunc(0.35 * (bottom - top) * (1.0 - facteurEchelle)));

          if (bottom - top) > largeurMax
            then InSetRect(theRect, 0, ((bottom - top) - largeurMax) div 2);


        end;
    end;

  GetRectAffichageCouleurZebra := theRect;
end;


procedure DessineCouleurDeZebraDansSaCase(whichSquare,valeur : SInt32);
var oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);

  (*
  WriteStringAndCoupDansRapport('entrОe dans DessineCouleurDeZebraDansSaCase : ', whichSquare);
  if (AQuiDeJouer = pionNoir)
    then WritelnNumDansRapport(' : trait = noir, valeur = ',valeur)
    else WritelnNumDansRapport(' : trait = blanc, valeur = ',valeur);
  *)

  DessineCouleurDeZebraBookDansRect(GetRectAffichageCouleurZebra(whichSquare),AQuiDeJouer,valeur,true);
  SetPort(oldPort);
end;

procedure DessineNoteSurCases(origine : SInt32; surQuellesCases : SquareSet);
var valeur : SInt32;
    tempo : UInt32;
    square : SInt16;
    s : String255;
    accumulateur : SquareSet;
    casesColorees : SquareSet;
    err : OSErr;

begin

  case origine of
    kNotesDeCassio :
      begin
        if ((GetAffichageProprietesOfCurrentNode and kNotesCassioSurLesCases) = 0) then exit(DessineNoteSurCases);
      end;
    kNotesDeZebra  :
      begin
        if ((GetAffichageProprietesOfCurrentNode and kNotesZebraSurLesCases) = 0)  then exit(DessineNoteSurCases);
        if not(ZebraBookACetteOption(kAfficherNotesZebraSurOthellier+kAfficherCouleursZebraSurOthellier)) then exit(DessineNoteSurCases);
      end;
  end; {case}


  with gNotesSurCases[origine] do
    if windowPlateauOpen and (wPlateauPtr <> NIL) then
	    begin
	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(false,9);
	          DisableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr));
	        end;

	      accumulateur := [];
	      casesColorees := [];

	      (*
	      if (AQuiDeJouer = pionBlanc)
	        then WritelnNumDansRapport('entrОe dans DessineNoteSurCases : AQuiDeJouer = pionBlanc, nbreCoup = ',nbreCoup)
	        else WritelnNumDansRapport('entrОe dans DessineNoteSurCases : AQuiDeJouer = pionNoir, nbreCoup = ',nbreCoup);
	      *)

	      for square := 11 to 88 do
	        if (square in surQuellesCases) and (GetCouleurOfSquareDansJeuCourant(square) = pionVide) then
	          begin
	            valeur := GetNoteSurCase(origine,square);

	            s := NoteSurCaseEnString(origine,valeur);

	            if (valeur > 0) and
	               ((GetFlagsNoteSurCase(origine,square) AND kFlagPositionEstSansDouteNonNulleSelonBiblZebra) <> 0)
	              then s := s + '''';


	            if (s = '') and GetOthellierEstSale(square)
	              then
	                accumulateur := accumulateur + [square]
	              else
		              begin
				            SetOthellierEstSale(square,true);

				            if (origine = kNotesDeZebra) and
    				           ZebraBookACetteOption(kAfficherNotesZebraSurOthellier)
				              then EcritNoteSurCase(origine,square,valeur,s);

				            if (origine = kNotesDeCassio)
    				          then EcritNoteSurCase(origine,square,valeur,s);

    				        if (origine = kNotesDeZebra) and
    				           ZebraBookACetteOption(kAfficherCouleursZebraSurOthellier) and
    				           EstUneNoteCalculeeEnMilieuDePartieDansLeBookDeZebra(valeur) then
    				          begin
    				            casesColorees := casesColorees + [square];
    				            DessineCouleurDeZebraDansSaCase(square,valeur);
    				          end;


				          end;

	          end;

	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(true,9);
	          EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	        end;

	      if (accumulateur <> []) then
	        EffaceNoteSurCases(origine,accumulateur);

	      if (casesColorees <> []) then
	        begin
	          tempo := GetAffichageProprietesOfCurrentNode;
		        SetAffichageProprietesOfCurrentNode(kAideDebutant + kPierresDeltas + kBibliotheque + kProchainCoup);
		        AfficheProprietesOfCurrentNode(false, casesColorees, 'DessineNoteSurCases');
	          SetAffichageProprietesOfCurrentNode(tempo);
	        end;

	      if gCassioUseQuartzAntialiasing then
	        begin
	          err := SetAntiAliasedTextEnabled(true,9);
	          EnableQuartzAntiAliasingThisPort(GetWindowPort(wPlateauPtr),true);
	        end;
      end;
end;







END.
