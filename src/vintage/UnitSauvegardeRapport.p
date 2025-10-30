UNIT UnitSauvegardeRapport;


INTERFACE







 USES UnitDefCassio;

procedure SauverStyleDuRapport(var fichier : basicfile);
procedure AppliquerStyleDuFichierAuRapport(var fichier : basicfile; debutSelection,finSelection : SInt32);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Resources, MacMemory, TextEdit, TextServices
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesRapport, UnitRapportImplementation, UnitServicesMemoire
    , basicfile ;
{$ELSEC}
    ;
    {$I prelink/SauvegardeRapport.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure SauverStyleDuRapport(var fichier : basicfile);
var styleScrapHdl : StScrpHandle;
    OSError: OSErr;
    oldResourceFile : SInt16;
    h : handle;
begin
  if (GetTextEditRecordOfRapport <> NIL) then
    begin
		  styleScrapHdl := TEGetStyleScrapHandle(GetTextEditRecordOfRapport); { Get list of all attributes. }

		  oldResourceFile := CurResFile;

		  OSError := CreerRessourceForkFichierTEXT(fichier);  {Create ressource fork if not already exists}
		  OSError := OuvreRessourceForkFichierTEXT(fichier);
		  if OSError = NoErr
		    then OSError := UseRessourceForkFichierTEXT(fichier);

		  if OSError = NoErr then
		    begin
		      {on enleve la vielle ressource 'styl' d'ID 0 dans le fichier}
		      if Count1Resources(MY_FOUR_CHAR_CODE('styl')) > 0 then
		        begin
		          h := Get1Resource(MY_FOUR_CHAR_CODE('styl'),0);
		          if h <> NIL then
		            begin
		              {WritelnDansRapport('enlèvement de l''ancienne ressource de style');}
		              RemoveResource(h);
		              DisposeMemoryHdl(h);
		              UpdateResFile(CurResFile);
		            end;
		        end;

				  AddResource(Handle(styleScrapHdl), MY_FOUR_CHAR_CODE('styl'), 0, StringToStr255('')); { Write attributes.}
				  WriteResource(Handle(styleScrapHdl));
				  ReleaseResource(Handle(styleScrapHdl));
				  OSError := FermeRessourceForkFichierTEXT(fichier); { close resource fork.}
			  end;

		  UseResFile(oldResourceFile);
    end;
end;



procedure AppliquerStyleDuFichierAuRapport(var fichier : basicfile; debutSelection,finSelection : SInt32);
var styleScrapHdl : StScrpHandle;
    OSError: OSErr;
    oldResourceFile : SInt16;
    savedState: UInt8;
    savedStart,savedEnd : SInt32;
begin
  if (GetTextEditRecordOfRapport <> NIL) then
    begin
		  oldResourceFile := CurResFile;

		  {desactivation de la methode d'entree du japonais}
		  if (GetTSMDocOfRapport <> NIL) then
				OSError := DeactivateTSMDocument(GetTSMDocOfRapport);
		  TEDeactivate(GetTextEditRecordOfRapport);
		  savedStart := GetDebutSelectionRapport;     { Save current selection }
		  savedEnd := GetFinSelectionRapport;         { starting and ending offsets.}
		  SetDebutSelectionRapport(debutSelection);			{ Select the adequate text. }
		  SetFinSelectionRapport(finSelection);					{ (Do not use TESetSelect.) }

		  OSError := OuvreRessourceForkFichierTEXT(fichier);
		  if OSError = NoErr then
		    begin
				  styleScrapHdl := StScrpHandle(GetResource(MY_FOUR_CHAR_CODE('styl'), 0)); { Get style scrap.}
		      OSError := ResError;
		      if OSError = NoErr then
		        begin
		          savedState := HGetState(Handle(styleScrapHdl)); { to edit record}
		          TEUseStyleScrap(debutSelection, finSelection, styleScrapHdl, true, GetTextEditRecordOfRapport);
		          HSetState(Handle(styleScrapHdl), savedState);
		        end;
				  WriteResource(Handle(styleScrapHdl));
				  ReleaseResource(Handle(styleScrapHdl));
				  OSError := FermeRessourceForkFichierTEXT(fichier);
			  end;

		  SetDebutSelectionRapport(savedStart);
		  SetFinSelectionRapport(savedEnd);
		  DoActivateRapport;

		  UseResFile(oldResourceFile);
		end;
end;



END.
