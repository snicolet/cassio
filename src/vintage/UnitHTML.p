UNIT UnitHTML;




INTERFACE







 USES UnitDefCassio , Files;


{fonctions pour generer du code HTML correspondant ˆ un diagramme}
function StringEnHTML(s : String255) : String255;
function WritelnEnHTMLDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
function WritePositionEtTraitPageWebFFODansFichierAbstrait(position : PositionEtTraitRec; legende : String255; var theFile : FichierAbstrait) : OSErr;
function WritePositionEtTraitEnHTMLDansFichierAbstrait(position : PositionEtTraitRec; var theFile : FichierAbstrait; chainePrologue, chaineEpilogue, chainePionsNoirs, chainePionsBlancs, chaineCoupsLegauxBlancs, chaineCoupsLegauxNoirs, chaineAutresCasesVides, chaineTop, chaineBottom, chaineBordureGauche, chaineBordureDroite, chaineLegende : String255 ) : OSErr;


{quelques fonctions pour generer les images utilisees dans le code HTML}
procedure ConvertPICTtoJPEGandExportToFile(thePicHandle : PicHandle; fileSpec : fileInfo);
procedure ExportPictureToFile(thePicHandle : PicHandle; nomFichier : String255);
function QTGraph_ShowImageFromFile(whichWindow : CGrafPtr; whichBounds : rect; var theFSSpec : fileInfo) : OSErr;
procedure QTGraph_ShowImageWithTransparenceFromFile(whichWindow : CGrafPtr; transparentColor : RGBColor; whichBounds : rect; var theFSSpec : fileInfo);
procedure CreateJPEGImageOfPosition(position : PositionEtTraitRec; fileSpec : fileInfo);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Menus, MacErrors, Components, MacWindows, ImageCompression, QuickTimeComponents
{$IFC NOT(USE_PRELINK)}
    , UnitDiagramFforum, UnitStrategie
    , UnitScannerUtils, MyStrings, UnitGeometrie, UnitFichiersTEXT, UnitFichierAbstrait ;
{$ELSEC}
    ;
    {$I prelink/HTML.lk}
{$ENDC}


{END_USE_CLAUSE}











function StringEnHTML(s : String255) : String255;
var i : SInt32;
    c : char;
    result : String255;
begin
  result := '';
  for i := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[i];
      case c of
        'Ê' : result := result + '&nbsp;';
        '¤' : result := result + '&sect;';
        '¬' : result := result + '&ulm;';
        '«' : result := result + '&acute;';
        '¾' : result := result + '&aelig;';

        'Ë' : result := result + '&Agrave;';
        'å' : result := result + '&Acirc;';
        'é' : result := result + '&Egrave;';
        'è' : result := result + '&Euml;';
        'æ' : result := result + '&Ecirc;';
        'ƒ' : result := result + '&Eacute;';
        'ë' : result := result + '&Icirc;';

        '„' : result := result + '&Ntilde;';
        '–' : result := result + '&ntilde;';

        '©' : result := result + '&copy;';
        '¨' : result := result + '&reg;';

        'Ž' : result := result + '&eacute;';
        '' : result := result + '&egrave;';
        '' : result := result + '&ecirc;';
        '‘' : result := result + '&euml;';

        '•' : result := result + '&iuml;';
        '”' : result := result + '&icirc;';
        '“' : result := result + '&igrave;';

        'ˆ' : result := result + '&agrave;';
        '‰' : result := result + '&acirc;';
        'Š' : result := result + '&auml;';

        '™' : result := result + '&ocirc;';
        '˜' : result := result + '&ograve;';
        'š' : result := result + '&oulm;';

        '' : result := result + '&ugrave;';
        'ž' : result := result + '&ucirc;';

        '' : result := result + '&ccedil;';
        'Ç' : result := result + '&laquo;';
        'È' : result := result + '&raquo;';
        '¡' : result := result + '&deg;';
        otherwise result := result + CharToString(c);
      end;
    end;
  StringEnHTML := result;
end;


function WritelnEnHTMLDansFichierAbstrait(var theFile : FichierAbstrait; s : String255) : OSErr;
var i : SInt32;
    c : char;
    err : OSErr;
begin
  for i := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[i];
      case c of
        'Ê' : err := WriteDansFichierAbstrait(theFile,'&nbsp;');
        '¤' : err := WriteDansFichierAbstrait(theFile,'&sect;');
        '¬' : err := WriteDansFichierAbstrait(theFile,'&ulm;');
        '«' : err := WriteDansFichierAbstrait(theFile,'&acute;');
        '¾' : err := WriteDansFichierAbstrait(theFile,'&aelig;');

        'Ë' : err := WriteDansFichierAbstrait(theFile,'&Agrave;');
        'å' : err := WriteDansFichierAbstrait(theFile,'&Acirc;');
        'é' : err := WriteDansFichierAbstrait(theFile,'&Egrave;');
        'è' : err := WriteDansFichierAbstrait(theFile,'&Euml;');
        'æ' : err := WriteDansFichierAbstrait(theFile,'&Ecirc;');
        'ƒ' : err := WriteDansFichierAbstrait(theFile,'&Eacute;');
        'ë' : err := WriteDansFichierAbstrait(theFile,'&Icirc;');

        '„' : err := WriteDansFichierAbstrait(theFile,'&Ntilde;');
        '–' : err := WriteDansFichierAbstrait(theFile,'&ntilde;');

        '©' : err := WriteDansFichierAbstrait(theFile,'&copy;');
        '¨' : err := WriteDansFichierAbstrait(theFile,'&reg;');

        'Ž' : err := WriteDansFichierAbstrait(theFile,'&eacute;');
        '' : err := WriteDansFichierAbstrait(theFile,'&egrave;');
        '' : err := WriteDansFichierAbstrait(theFile,'&ecirc;');
        '‘' : err := WriteDansFichierAbstrait(theFile,'&euml;');

        '•' : err := WriteDansFichierAbstrait(theFile,'&iuml;');
        '”' : err := WriteDansFichierAbstrait(theFile,'&icirc;');
        '“' : err := WriteDansFichierAbstrait(theFile,'&igrave;');

        'ˆ' : err := WriteDansFichierAbstrait(theFile,'&agrave;');
        '‰' : err := WriteDansFichierAbstrait(theFile,'&acirc;');
        'Š' : err := WriteDansFichierAbstrait(theFile,'&auml;');

        '™' : err := WriteDansFichierAbstrait(theFile,'&ocirc;');
        '˜' : err := WriteDansFichierAbstrait(theFile,'&ograve;');
        'š' : err := WriteDansFichierAbstrait(theFile,'&oulm;');

        '' : err := WriteDansFichierAbstrait(theFile,'&ugrave;');
        'ž' : err := WriteDansFichierAbstrait(theFile,'&ucirc;');

        '' : err := WriteDansFichierAbstrait(theFile,'&ccedil;');
        'Ç' : err := WriteDansFichierAbstrait(theFile,'&laquo;');
        'È' : err := WriteDansFichierAbstrait(theFile,'&raquo;');
        '¡' : err := WriteDansFichierAbstrait(theFile,'&deg;');
        otherwise err := WriteDansFichierAbstrait(theFile,CharToString(c));
      end;
    end;
  err := WritelnDansFichierAbstrait(theFile,'');
  WritelnEnHTMLDansFichierAbstrait := err;
end;

function WritePositionEtTraitEnHTMLDansFichierAbstrait(position : PositionEtTraitRec;
                                               var theFile : FichierAbstrait;
                                               chainePrologue,
                                               chaineEpilogue,
                                               chainePionsNoirs,
                                               chainePionsBlancs,
                                               chaineCoupsLegauxBlancs,
                                               chaineCoupsLegauxNoirs,
                                               chaineAutresCasesVides,
                                               chaineTop,
                                               chaineBottom,
                                               chaineBordureGauche,
                                               chaineBordureDroite,
                                               chaineLegende : String255
                                               ) : OSErr;
var fichierEtaitOuvertEnArrivant : boolean;
    ligneStr,squareStr : String255;
    err : OSErr;
    i,j : SInt32;
    square : SInt32;
    fic : FichierTEXT;
begin
  err := NoErr;

  fichierEtaitOuvertEnArrivant := false;
  if (GetFichierTEXTOfFichierAbstraitPtr(@theFile,fic) = NoErr) then
    begin
      fichierEtaitOuvertEnArrivant := FichierTexteEstOuvert(fic);
      if not(fichierEtaitOuvertEnArrivant) then err := OuvreFichierTexte(fic);
    end;


  err := WritelnDansFichierAbstrait(theFile,chainePrologue);
  err := WriteDansFichierAbstrait(theFile,chaineTop);
  for i := 1 to 8 do
    begin
      ligneStr := IntToStr(i);
      err := WriteDansFichierAbstrait(theFile,ParamStr(chaineBordureGauche,ligneStr,ligneStr,ligneStr,ligneStr));
      for j := 1 to 8 do
        begin
          square := i*10+j;
          squareStr := CoupEnStringEnMinuscules(square);
          case position.position[square] of
            pionBlanc : err := WriteDansFichierAbstrait(theFile,ParamStr(chainePionsBlancs,squareStr,squareStr,squareStr,squareStr));
            pionNoir  : err := WriteDansFichierAbstrait(theFile,ParamStr(chainePionsNoirs,squareStr,squareStr,squareStr,squareStr));
            pionVide  : begin
                          if PeutJouerIci(pionBlanc,square,position.position) and (Pos('^0',chaineCoupsLegauxBlancs) > 0)
                            then err := WriteDansFichierAbstrait(theFile,ParamStr(chaineCoupsLegauxBlancs,squareStr,squareStr,squareStr,squareStr)) else
                          if PeutJouerIci(pionNoir,square,position.position) and (Pos('^0',chaineCoupsLegauxNoirs) > 0)
                            then err := WriteDansFichierAbstrait(theFile,ParamStr(chaineCoupsLegauxNoirs,squareStr,squareStr,squareStr,squareStr))
                            else err := WriteDansFichierAbstrait(theFile,ParamStr(chaineAutresCasesVides,squareStr,squareStr,squareStr,squareStr));
                        end;
          end; {case}
        end;
      err := WritelnDansFichierAbstrait(theFile,ParamStr(chaineBordureDroite,ligneStr,ligneStr,ligneStr,ligneStr));
    end;
  err := WriteDansFichierAbstrait(theFile,chaineBottom);
  err := WriteDansFichierAbstrait(theFile,chaineLegende);
  err := WritelnDansFichierAbstrait(theFile,chaineEpilogue);


  if (GetFichierTEXTOfFichierAbstraitPtr(@theFile,fic) = NoErr) and not(fichierEtaitOuvertEnArrivant)
    then err := FermeFichierTexte(fic);


  WritePositionEtTraitEnHTMLDansFichierAbstrait := err;
end;


function WritePositionEtTraitPageWebFFODansFichierAbstrait(position : PositionEtTraitRec; legende : String255; var theFile : FichierAbstrait) : OSErr;
begin
  WritePositionEtTraitPageWebFFODansFichierAbstrait  :=
     WritePositionEtTraitEnHTMLDansFichierAbstrait(position,theFile,
                                           '<div class="diagramme">',
                                           '</div>',
                                           '<img src="bb.gif" width="24" height="24">',
                                           '<img src="ww.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="ee.gif" width="24" height="24">',
                                           '<img src="top.gif" width="224" height="16">',
                                           '<img src="top.gif" width="224" height="16"><br />',
                                           '<img src="^0^1.gif" width="16" height="24">',
                                           '<img src="^0^1.gif" width="16" height="24"><br />',
                                           legende
                                          );
end;




{refer to QuickTime 4 reference p 573 for more info.}
procedure ConvertPICTtoJPEGandExportToFile(thePicHandle : PicHandle; fileSpec : fileInfo);
var
    result  : ComponentResult;
    ge : GraphicsExportComponent;
    myError : OSErr;
    ActualSize : UInt32;
begin
  myError := OpenADefaultComponent(GraphicsExporterComponentType,kQTFileTypeJPEG, ge);
  result := GraphicsExportSetInputPicture(ge,thePicHandle);
  result := GraphicsExportSetOutputFileTypeAndCreator(ge,kQTFileTypeJPEG,MY_FOUR_CHAR_CODE('GKON')); {GKON is GraphicConverter}
  result := GraphicsExportSetOutputFile(ge,fileSpec);
  result := GraphicsExportDoExport(ge,ActualSize);
  myError := CloseComponent(ge);
end;


procedure ExportPictureToFile(thePicHandle : PicHandle; nomFichier : String255);
var
    result  : ComponentResult;
    ge : GraphicsExportComponent;
    myError : OSErr;
    ActualSize : UInt32;
    fileSpec : fileInfo;
    erreurES : OSErr;
    fic : FichierTEXT;
begin


  erreurES := FichierTexteExiste(nomFichier,0,fic);
  if erreurES = fnfErr then erreurES := CreeFichierTexte(nomFichier,0,fic);
  if erreurES = 0 then
    begin
      erreurES := OuvreFichierTexte(fic);
      erreurES := VideFichierTexte(fic);
      erreurES := FermeFichierTexte(fic);
      fileSpec := fic.theFSSpec;
    end;



  myError := OpenADefaultComponent(GraphicsExporterComponentType,kQTFileTypePicture, ge);
  result := GraphicsExportSetInputPicture(ge,thePicHandle);
  result := GraphicsExportSetOutputFileTypeAndCreator(ge,kQTFileTypePicture,MY_FOUR_CHAR_CODE('GKON')); {GKON is GraphicConverter}
  result := GraphicsExportSetOutputFile(ge,fileSpec);
  result := GraphicsExportDoExport(ge,ActualSize);
  myError := CloseComponent(ge);
end;


function QTGraph_ShowImageFromFile(whichWindow : CGrafPtr; whichBounds : rect; var theFSSpec : fileInfo) : OSErr;
var
  myImporter : GraphicsImportComponent;
  myRect : Rect;
  err : OSErr;
  oldPort : GrafPtr;
begin
  myImporter := NIL;

  err := GetGraphicsImporterForFile(theFSSpec, myImporter);
  if (myImporter <> NIL) then
    begin
      err := GraphicsImportGetNaturalBounds(myImporter, myRect);
      if (whichWindow <> NIL) and (err = NoErr) then
        begin
          GetPort(oldPort);
          SetPort(whichWindow);
          err := GraphicsImportSetGWorld(myImporter, whichWindow, NIL);
          err := GraphicsImportSetBoundsRect(myImporter, whichBounds);
          err := GraphicsImportDraw(myImporter);
          err := CloseComponent(myImporter);
          SetPort(oldPort);
        end;
     end;

   QTGraph_ShowImageFromFile := err;
end;

procedure QTGraph_ShowImageWithTransparenceFromFile(whichWindow : CGrafPtr; transparentColor : RGBColor; whichBounds : rect; var theFSSpec : fileInfo);
var
  myImporter : GraphicsImportComponent;
  myRect : Rect;
  err : OSErr;
  oldPort : GrafPtr;
begin
  myImporter := NIL;

  err := GetGraphicsImporterForFile(theFSSpec, myImporter);
  if (myImporter <> NIL) then
    begin
      err := GraphicsImportGetNaturalBounds(myImporter, myRect);
      if (whichWindow <> NIL) and (err = NoErr) then
        begin
          GetPort(oldPort);
          SetPort(whichWindow);
          err := GraphicsImportSetGWorld(myImporter, whichWindow, NIL);
          err := GraphicsImportSetBoundsRect(myImporter, whichBounds);
          err := GraphicsImportSetGraphicsMode(myImporter,transparent, transparentColor);
          err := GraphicsImportDraw(myImporter);
          err := CloseComponent(myImporter);
          SetPort(oldPort);
        end;
     end;
end;

procedure CreateJPEGImageOfPosition(position : PositionEtTraitRec; fileSpec : fileInfo);
const kTailleCase = 12;
      kLargeurBordure = 8;
var i,j,square : SInt32;
    erreurES : OSErr;
    fic : FichierTEXT;
    bounds : rect;
    marge : Point;
    myPicture : PicHandle;

    procedure DrawPicture(nom : String255; whichBounds : rect);
    begin
      erreurES := FichierTexteDeCassioExiste(nom,fic);
      if (erreurES = NoErr) and (wPlateauPtr <> NIL) then
        erreurES := QTGraph_ShowImageFromFile(GetWindowPort(wPlateauPtr),whichBounds,fic.theFSSpec);
    end;

begin

  SetPt(marge,0,0);

  with marge do
    begin

      myPicture := OpenPicture(MakeRect(h,
                                        v,
                                        h + 2*kLargeurBordure + 8*kTailleCase,
                                        v + 2*kLargeurBordure + 8*kTailleCase));


      bounds := MakeRect(h,v,h + 2*kLargeurBordure + 8*kTailleCase,v+kLargeurBordure);
      DrawPicture('top.gif',bounds);

      for i := 1 to 8 do
        begin

          bounds := MakeRect(h,
                             v + kLargeurBordure + (i-1)*kTailleCase,
                             h + kLargeurBordure,
                             v + kLargeurBordure + i*kTailleCase);
          DrawPicture(ParamStr('^0^1.gif',IntToStr(i),IntToStr(i),'',''),bounds);

          for j := 1 to 8 do
            begin
              square := i*10+j;
              bounds := MakeRect( h + kLargeurBordure + (j-1)*kTailleCase ,
                                  v + kLargeurBordure + (i-1)*kTailleCase ,
                                  h + kLargeurBordure + j*kTailleCase,
                                  v + kLargeurBordure + i*kTailleCase);
              case position.position[square] of
                pionBlanc : DrawPicture('ww.gif',bounds);
                pionNoir  : DrawPicture('bb.gif',bounds);
                pionVide  : DrawPicture('ee.gif',bounds);
              end;

            end;

          bounds := MakeRect(h + kLargeurBordure + 8*kTailleCase,
                             v + kLargeurBordure + (i-1)*kTailleCase,
                             h + 2*kLargeurBordure + 8*kTailleCase,
                             v + kLargeurBordure + i*kTailleCase);
          DrawPicture(ParamStr('^0^1.gif',IntToStr(i),IntToStr(i),'',''),bounds);

        end;


      bounds := MakeRect(h,
                         v + kLargeurBordure + 8*kTailleCase,
                         h + 2*kLargeurBordure + 8*kTailleCase,
                         v + 2*kLargeurBordure + 8*kTailleCase);
      DrawPicture('top.gif',bounds);

      ClosePicture;
      ConvertPICTtoJPEGandExportToFile(myPicture,fileSpec);
      KillPicture(myPicture);
    end;
end;



end.











































