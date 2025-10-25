UNIT UnitFichiersPICT;


INTERFACE







 USES UnitDefCassio , Quickdraw;


{fonctions pour ouvrir et afficher des fichiers au format ".pict" }


function ReadPictFile(picFile : FichierTEXT; var error : OSErr) : PicHandle;
function DisplayPictFile(picFile : FichierTEXT; displayWindow : WindowPtr) : OSErr;
function DrawPictFile(picFile : FichierTEXT; inRect : rect) : OSErr;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitCarbonisation, UnitFichiersTEXT, MyQuickDraw ;
{$ELSEC}
    ;
    {$I prelink/FichiersPICT.lk}
{$ENDC}


{END_USE_CLAUSE}












function ReadPictFile(picFile : FichierTEXT; var error : OSErr) : PicHandle;
var
	numberOfBytes : SInt32;
	OSError : OSErr;
	thePicture : PicHandle;
	tailleTempDispo,grow : Size;
begin

  ReadPictFile := NIL;

	OSError := GetTailleFichierTexte(picFile, numberOfBytes);
	if (OSError <> noErr) then
	  begin
	    error := OSError;
	    Exit(ReadPictFile);
	  end;

	OSError := SetPositionTeteLectureFichierTexte(picFile, 512);
	numberOfBytes := numberOfBytes - 512;
	if (OSError <> noErr) then
	  begin
	    error := OSError;
	    Exit(ReadPictFile);
	  end;

  {compactons la memoire temporaire}
  tailleTempDispo := TempMaxMem(grow);

  {avant d'allouer un handle dans la memoire temporaire}
	thePicture := PicHandle(TempNewHandle(numberOfBytes+100, OSError));
	if (thePicture = NIL) then
		begin
		  error := OSError;
			Exit(ReadPictFile);
		end;

  TempHLock(Handle(thePicture),OSError);
  if (OSError <> noErr) then
	  begin
	    error := OSError;
	    Exit(ReadPictFile);
	  end;

  OSError := ReadBufferDansFichierTexte(picFile,Ptr(thePicture^),numberOfBytes);
  if (OSError <> noErr) then
	  begin
	    error := OSError;
	    Exit(ReadPictFile);
	  end;

	TempHUnlock(Handle(thePicture),OSError);
	if (OSError <> noErr) then
	  begin
	    error := OSError;
	    Exit(ReadPictFile);
	  end;

	if ((OSError = noErr) or (OSError = eofErr))
		then
			begin
			  ReadPictFile := thePicture;
				error := noErr;
				Exit(ReadPictFile);
			end
		else
			error := OSError;

end; {ReadPictFile}


function DisplayPictFile(picFile : FichierTEXT; displayWindow : WindowPtr) : OSErr;
var oldPort : grafPtr;
    thePicture : PicHandle;
    bounds : rect;
    error : OSErr;
begin
  GetPort(oldPort);
  SetPortByWindow(displayWindow);

  thePicture := ReadPictFile(picFile,error);

  if (thePicture <> NIL) and (error = NoErr) then
    begin
      TempHLock(Handle(thePicture),error);			        { If we made it this far, lock handle.}
	  bounds := GetPicFrameOfPicture(thePicture);			    { Get a copy of the picture's bounds.}
	  TempHUnlock(Handle(thePicture),error);		          { We can unlock the picture now.}
	  DrawPicture(thePicture,bounds);
    end;

  if thePicture <> NIL then
    TempDisposeHandle(Handle(thePicture),error);

  DisplayPictFile := error;
  SetPort(oldPort);
end;  {DisplayPictFile}



function DrawPictFile(picFile : FichierTEXT; inRect : rect) : OSErr;
var thePicture : PicHandle;
    error : OSErr;
begin

  thePicture := ReadPictFile(picFile,error);

  if (thePicture <> NIL) and (error = NoErr) then
    DrawPicture(thePicture,inRect);

	if thePicture <> NIL then
	  TempDisposeHandle(Handle(thePicture),error);

  DrawPictFile := error;

end;  {DrawPictFile}



END.
