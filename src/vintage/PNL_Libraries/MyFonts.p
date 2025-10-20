UNIT MyFonts;



INTERFACE


 USES UnitDefCassio;



function MyGetFontNum(nomPolice : String255) : SInt16;
procedure GetClassicalFontsID;
function LoadFont(fontFSSpec : FSSpec) : OSErr;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{$DEFINEC USE_PRELINK true}

USES
    Fonts
{$IFC NOT(USE_PRELINK)}
    , UnitRapport ;
{$ELSEC}
    ;
    {$I prelink/MyFonts.lk}
{$ENDC}


{END_USE_CLAUSE}



function MyGetFontNum(nomPolice : String255) : SInt16;
  var result : SInt16;
  begin
    GetFNum(StringToStr255(nomPolice),result);
    MyGetFontNum := result;
  end;



procedure GetClassicalFontsID;
	begin
		GenevaID := 0;
		CourierID := 0;
		TimesID := 0;
		MonacoID := 0;
		NewYorkID := 0;
		PalatinoID := 0;
		SymbolID := 0;
		TimesNewRomanID := 0;
		TrebuchetMSID := 0;
		EpsiSansID := 0;
		HelveticaID := 0;

		GenevaID := MyGetFontNum('Geneva');
		CourierID := MyGetFontNum('Courier');
		TimesID := MyGetFontNum('Times');
		MonacoID := MyGetFontNum('Monaco');
		NewYorkID := MyGetFontNum('New York');
		PalatinoID := MyGetFontNum('Palatino');
		SymbolID := MyGetFontNum('Symbol');
		TimesNewRomanID := MyGetFontNum('Times New Roman');
		TrebuchetMSID := MyGetFontNum('Trebuchet MS');
		EpsiSansID := MyGetFontNum('Espi Sans');
		HelveticaID := MyGetFontNum('Helvetica');
	end;


function LoadFont(fontFSSpec : FSSpec) : OSErr;
var err : OSErr;
    fileRef : FSRef;
    theFSSpec : FSSpec;
begin

  err := FSpMakeFSRef(fontFSSpec,fileRef);

  if err = NoErr then
    begin
      err := FSGetCatalogInfo(fileRef, kFSCatInfoNone, NIL, NIL, @theFSSpec, NIL);
      if (err = NoErr) then
        begin
          err := FMActivateFonts(theFSSpec, NIL, NIL, kFMGlobalActivationContext);
        end;
    end;

  LoadFont := err;
end;



END.









































