UNIT UnitDiagramFforum;




INTERFACE







USES
   UnitDefCassio;


procedure InitUnitDiagrammesFFORUM;

function DoDiagrammeFFORUM(ParametreTexte: String255; const chainePositionInitiale,chainePosition,chaineCoups : String255) : boolean;

function LargeurDiagrammeFFORUM : SInt16;
function HauteurDiagrammeFFORUM : SInt16;
function LargeurTexteSousDiagrammeFFORUM : SInt16;
function HauteurTexteDansDiagrammeFFORUM : SInt16;
function BlancAGaucheDiagrammeFFORUM : SInt16;
function BlancADroiteDiagrammeFFORUM : SInt16;

function QuickdrawColorToDiagramFforumColor(qdColor : SInt16) : SInt16;
function DiagramFforumColorToRGBColor(diagramForumColor : SInt16) : RGBColor;
function QuickDrawColorToRGBColor(qdColor : SInt16) : RGBColor;
function DoitGenererPostScriptCompatibleXPress : boolean;

procedure SetValeursParDefautDiagFFORUM(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
procedure SetValeursRevueAnglaise(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
procedure SetNomFichierDansTitreDiagrammeFFORUM(nomFichier : String255);

procedure ConstruitOthellierPicture;
procedure ConstruitPositionPicture(chainePosition,chaineCoups : String255);
procedure ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups : String255);
procedure ConstruitPicturePionsDeltaCourants;

procedure CopierEnMacDraw;
function CopierPICTDansPressePapier(myPicture : PicHandle) : OSErr;
procedure CopierPucesNumerotees;
procedure ConstruitPositionEtCoupDapresPartie(var positionEtCoupStr : String255);
procedure ConstruitPositionEtCoupPositionInitiale(var positionEtCoupStr : String255);

procedure ParserPositionEtCoupsOthello8x8(positionEtCoupStr : String255; var chainePositionInitiale,chaineCoups : String255);
function NbreCoupsDansChaineCoups(chaineCoups : String255) : SInt16;
function ConstruitChainePosition8x8(plat : plateauOthello) : String255;

procedure SetTailleOthelloPourDiagrammeFForum(nbCasesH,nbCasesV : SInt16);
procedure GetTailleOthelloPourDiagrammeFforum(var nbCasesH,nbCasesV : SInt16);

function GetLegendeSousLeDiagrammeCourant : String255;


{ gestion des fichiers EPS construits pour le presse-papier }

function PeutOuvrirFichierEPSPourPressePapier(var fic : FichierTEXT) : OSErr;
procedure FermerFichierEPSPourPressePapier;

function CalculateScaleFactorForEPSDiagram(var EPSBoudingBox : Rect) : double;
function CalculateScaleFactorForDiscsInEPSDiagram : double;

procedure SetFichierPourDiagrammeEPS(const fichierEPS : FichierTEXT);
procedure SetNomsFichiersPostscriptPressePapier(EPSfilename, PDFfilename : String255);
procedure SetDiagrammeDoitCreerVersionEPS(flag : boolean);
function DiagrammeDoitCreerVersionEPS : boolean;
function GetNewCounterDiagramEPS : SInt32;

procedure PrintForEPSFile(s : String255);
procedure PrintEpilogueForEPSFile;
procedure PrintFontsForEPSDiagram;
procedure PrintLegendeDiagrammeForEPSFile(str, str1 : String255);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
  fp, Scrap, Sound, MacWindows, Fonts, QuickdrawText, MacMemory, Appearance, CFString

{$IFC NOT(USE_PRELINK)}
  , UnitCouleur, MyQuickDraw, UnitPressePapier, UnitCarbonisation, UnitArbreDeJeuCourant, UnitOth2, UnitPierresDelta, UnitPostScript
  , UnitJaponais, MyStrings, UnitDialog, UnitProblemeDePriseDeCoin, MyAntialiasing, UnitSquareSet, UnitFenetres, UnitJeu
  , MyMathUtils, UnitGeometrie, SNEvents, SNMenus, MyFonts, UnitNormalisation, UnitProperties, UnitPositionEtTrait, UnitRapport
  , UnitScannerUtils, UnitGeometrie, MyMathUtils, UnitEPS, UnitFichiersTEXT, MyFileSystemUtils, UnitUtilitaires, UnitEnvirons
  , UnitUnixTask, UnitFichierAbstrait
   ;
{$ELSEC}
  ;
  {$I prelink/DiagramFforum.lk}
{$ENDC}



{END_USE_CLAUSE}


var tailleVersionOthello : Point;
    gInfosDiagrammeFforumEPS : record
                                 compteur      : SInt32;
                                 doitCreerEPS  : boolean;
                                 ficEPS        : FichierTEXT;
                                 buffer        : FichierAbstrait;
                                 nomFichierEPS : String255;
                                 nomFichierPDF : STring255;
                               end;


procedure InitUnitDiagrammesFFORUM;
begin
  SetDiagrammeDoitCreerVersionEPS(false);
  gInfosDiagrammeFforumEPS.compteur := 0;
end;



function GetNewCounterDiagramEPS : SInt32;
begin
  with gInfosDiagrammeFforumEPS do
    begin
      GetNewCounterDiagramEPS := compteur;
      inc(compteur);
      if (compteur < 0) then compteur := 0;
    end;
end;


procedure SetDiagrammeDoitCreerVersionEPS(flag : boolean);
begin
  gInfosDiagrammeFforumEPS.doitCreerEPS := flag;
end;


procedure SetFichierPourDiagrammeEPS(const fichierEPS : FichierTEXT);
begin
  gInfosDiagrammeFforumEPS.ficEPS := fichierEPS;
end;


function MakeBufferPourDiagrammeEPS : OSErr;
begin
  gInfosDiagrammeFforumEPS.buffer := MakeFichierAbstraitEnMemoire(128 * 1024);

  if FichierAbstraitEstCorrect(gInfosDiagrammeFforumEPS.buffer)
    then MakeBufferPourDiagrammeEPS := NoErr
    else MakeBufferPourDiagrammeEPS := -3;
end;

procedure SetNomsFichiersPostscriptPressePapier(EPSfilename, PDFfilename : String255);
begin
  gInfosDiagrammeFforumEPS.nomFichierEPS := EPSfilename;
  gInfosDiagrammeFforumEPS.nomFichierPDF := PDFfilename;
end;


function DiagrammeDoitCreerVersionEPS : boolean;
begin
  DiagrammeDoitCreerVersionEPS := (tailleVersionOthello.h = 8) and gInfosDiagrammeFforumEPS.doitCreerEPS;
end;


procedure PrintForEPSFile(s : String255);
var err : OSErr;
begin
  if DiagrammeDoitCreerVersionEPS then
    begin
      {WritelnDansRapport(s);}

      err := WritelnDansFichierAbstrait(gInfosDiagrammeFforumEPS.buffer, s);

      if (err <> NoErr) then
        begin
          WritelnNumDansRapport('WARNING, dans PrintForEPSFile, err = ',err);
          SetDiagrammeDoitCreerVersionEPS(false);
        end;

    end;
end;


procedure PrintEpilogueForEPSFile;
begin
  PrintForEPSFile(' ');
  PrintForEPSFile(' ');
  PrintForEPSFile(' ');
  PrintForEPSFile('grestore');
  PrintForEPSFile('');
  PrintForEPSFile('%%EOF');
end;





{ str  = chaine affiche en normal sous le diagramme
  str1 = chaine affichee en gras, apres str, sous le diagramme }
procedure PrintLegendeDiagrammeForEPSFile(str, str1 : String255);
var fontID : SInt32;
begin

  if DiagrammeDoitCreerVersionEPS then
    begin

      fontID := ParamDiagCourant.PoliceFForumID;

      if (str = '') and (str1 = '') and (fontID <> GetCassioFontNum('New Century Schoolbook Roman')) then
        exit;

      if (fontID = GetCassioFontNum('Baskerville')) or (fontID = GetCassioFontNum('Fontin Regular')) then
        begin
          ReplaceCharByCharInString(str,'-',' ');
          ReplaceCharByCharInString(str1,'-',' ');
        end;

      str := ReplaceStringOnce('\', '\\', str);

      str := ReplaceStringOnce('(',  'ππ', str);
    	str := ReplaceStringOnce('(',  '\(', str);
    	str := ReplaceStringOnce('ππ', '\(', str);
    	str := ReplaceStringOnce(')',  'ππ', str);
    	str := ReplaceStringOnce(')',  '\)', str);
    	str := ReplaceStringOnce('ππ', '\)', str);
    	
    	str1 := ReplaceStringOnce('(',  'ππ', str1);
    	str1 := ReplaceStringOnce('(',  '\(', str1);
    	str1 := ReplaceStringOnce('ππ', '\(', str1);
    	str1 := ReplaceStringOnce(')',  'ππ', str1);
    	str1 := ReplaceStringOnce(')',  '\)', str1);
    	str1 := ReplaceStringOnce('ππ', '\)', str1);
    	
    	if (str1 <> '') then str := str + ' ';
    	
    	PrintForEPSFile(' ');
      PrintForEPSFile(' ');
      PrintForEPSFile(' % draw the text under the diagram');
      PrintForEPSFile(' ');
      PrintForEPSFile(' (' + ConvertEncodingOfString(str , kCFStringEncodingMacRoman , kCFStringEncodingISOLatin1) + ')' +
                      ' (' + ConvertEncodingOfString(str1 , kCFStringEncodingMacRoman , kCFStringEncodingISOLatin1) + ')'+
                      ' center_text');
      PrintForEPSFile(' ');

      if (fontID = GetCassioFontNum('New Century Schoolbook Roman')) then
        begin
          PrintForEPSFile(' % bugfix for the New Century Schoolbook Roman font (it''s a Windows font...)');
          PrintForEPSFile(' ');
          PrintForEPSFile(' 1 setgray');
          PrintForEPSFile(' 110 6 moveto /RegularFontLatin 0.1 selectfont (-) show');
          PrintForEPSFile(' 110 6 moveto /BoldFontLatin    0.1 selectfont (-) show');
          PrintForEPSFile(' 0 setgray');
          PrintForEPSFile(' ');
        end;
    end;

end;


procedure PrintFontsForEPSDiagram;
var fontID : SInt32;
begin
  if DiagrammeDoitCreerVersionEPS then
    begin

      fontID := ParamDiagCourant.PoliceFForumID;

      // WritelnNumDansRapport('PoliceFForumID = ',fontID);

      if (fontID = GetCassioFontNum('Times')) then
        begin
          PrintForEPSFile(' /regularfont /Times-Roman       def');
          PrintForEPSFile(' /boldfont    /Times-Bold        def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Times New Roman')) then
        begin
          PrintForEPSFile(' /regularfont /TimesNewRomanPSMT      def');
          PrintForEPSFile(' /boldfont    /TimesNewRomanPS-BoldMT def');
          PrintForEPSFile(' /movenumberscale { 1.1 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Georgia')) then
        begin
          PrintForEPSFile(' /regularfont /Georgia      def');
          PrintForEPSFile(' /boldfont    /Georgia-Bold def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 1.4 } def');
        end
      else if (fontID = GetCassioFontNum('Baskerville')) then
        begin
          PrintForEPSFile(' /regularfont /Baskerville          def');
          PrintForEPSFile(' /boldfont    /Baskerville-SemiBold def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.25 } def');
        end
      else if (fontID = GetCassioFontNum('Gentium')) then
        begin
          PrintForEPSFile(' /regularfont /Gentium           def');
          PrintForEPSFile(' /boldfont    /GentiumBasic-Bold def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.5 } def');
        end
      else if (fontID = GetCassioFontNum('Palatino')) then
        begin
          PrintForEPSFile(' /regularfont /Palatino-Roman    def');
          PrintForEPSFile(' /boldfont    /Palatino-Bold     def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Optima')) then
        begin
          PrintForEPSFile(' /regularfont /Optima-Regular    def');
          PrintForEPSFile(' /boldfont    /Optima-Bold       def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Cochin')) then
        begin
          PrintForEPSFile(' /regularfont /Cochin            def');
          PrintForEPSFile(' /boldfont    /Cochin-Bold       def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Helvetica')) then
        begin
          PrintForEPSFile(' /regularfont /Helvetica         def');
          PrintForEPSFile(' /boldfont    /Helvetica-Bold    def');
          PrintForEPSFile(' /movenumberscale { 0.9 } def');
          PrintForEPSFile(' /moveverticaloffset { -0.1 } def');
        end
      else if (fontID = GetCassioFontNum('Fontin Regular')) then
        begin
          PrintForEPSFile(' /regularfont /Fontin-Regular  def');
          PrintForEPSFile(' /boldfont    /Fontin-Bold     def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.5 } def');
        end
      else if (fontID = GetCassioFontNum('Arial Rounded MT Bold')) then
        begin
          PrintForEPSFile(' /regularfont /ArialRoundedMTBold  def');
          PrintForEPSFile(' /boldfont    /ArialRoundedMTBold  def');
          PrintForEPSFile(' /movenumberscale { 0.9 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Trebuchet MS')) then
        begin
          PrintForEPSFile(' /regularfont /TrebuchetMS       def');
          PrintForEPSFile(' /boldfont    /TrebuchetMS-Bold  def');
          PrintForEPSFile(' /movenumberscale { 0.9 } def');
          PrintForEPSFile(' /moveverticaloffset { -0.4 } def');
        end
      else if (fontID = GetCassioFontNum('New Century Schoolbook Roman')) then
        begin
          PrintForEPSFile(' /regularfont /NewCenturySchlbk-Roman  def');
          PrintForEPSFile(' /boldfont    /NewCenturySchlbk-Bold  def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end
      else if (fontID = GetCassioFontNum('Virginie')) then
        begin
          PrintForEPSFile(' /regularfont /Virginie          def');
          PrintForEPSFile(' /boldfont    /Virginie          def');
          PrintForEPSFile(' /movenumberscale { 1.0 } def');
          PrintForEPSFile(' /moveverticaloffset { 0.0 } def');
        end;
    end;
end;



function CalculateScaleFactorForEPSDiagram(var EPSBoudingBox : Rect) : double;
var ll, ur : Point;
    largeurPostscript, hauteurPostscript : double;
    scale_x, scale_y, scale : double;
    arrondi_h, arrondi_v : double;
begin


  if ParamDiagCourant.CoordonneesFFORUM
    then
      begin
        ll := MakePoint(10,-10);   // lower left
        ur := MakePoint(202,191);  // upper right   // rem : MakePoint(196,191) est bien
      end
    else
      begin
        ll := MakePoint(20,-10);   // lower left
        ur := MakePoint(200,179);  // upper right   // rem : MakePoint(196,179)
      end;


  if (GetLegendeSousLeDiagrammeCourant = '')
    then ll.v := 5;


  if (ParamDiagCourant.epaisseurCadreFFORUM <= 0.01) then
    begin
      ll.h := ll.h + 4;
      ll.v := ll.v + 3;
      ur.v := ur.v - 3;
      ur.h := ur.h - 3;
    end;

  largeurPostscript := ur.h - ll.h;
  hauteurPostscript := ur.v - ll.v;


  scale_x := LargeurDiagrammeFFORUM / largeurPostscript;
  scale_y := HauteurDiagrammeFFORUM / hauteurPostscript;

  // WritelnNumDansRapport('larg diag EPS = ',Trunc(largeurPostscript + 0.5));
  // WritelnNumDansRapport('haut diag EPS = ',Trunc(hauteurPostscript + 0.5));
  // WritelnNumDansRapport('larg diag FFORUM = ',LargeurDiagrammeFFORUM);
  // WritelnNumDansRapport('haut diag FFORUM = ',HauteurDiagrammeFFORUM);
  // WriteStringAndReelDansRapport('scale_x = ',scale_x, 7);WritelnDansRapport('');
  // WriteStringAndReelDansRapport('scale_y = ',scale_y, 7);WritelnDansRapport('');

  scale := scale_x;
  if scale_y > scale then scale := scale_y;
  scale := scale * 1.3663 / 1.34;

  scale := (Trunc(scale * 500.0 + 5) - (Trunc(scale * 500.0 + 5) mod 10)) / 500.0;


  // WriteStringAndReelDansRapport('scale = ',scale, 7);
  // WritelnDansRapport('');
  // WritelnDansRapport('');


  if ll.h >= 0 then arrondi_h := 0.0 else arrondi_h := -0.999999;
  if ll.v >= 0 then arrondi_v := 0.0 else arrondi_v := -0.999999;
  ll := MakePoint( Trunc(ll.h * scale + arrondi_h) ,
                   Trunc(ll.v * scale + arrondi_v) );

  if ur.h >= 0 then arrondi_h := 0.999999 else arrondi_h := 0.0;
  if ur.v >= 0 then arrondi_v := 0.999999 else arrondi_v := 0.0;
  ur := MakePoint( Trunc(ur.h * scale + arrondi_h) ,
                   Trunc(ur.v * scale + arrondi_v) );


  EPSBoudingBox := MakeRect(ll.h, ll.v, ur.h, ur.v);

  CalculateScaleFactorForEPSDiagram := scale;
end;


function CalculateScaleFactorForDiscsInEPSDiagram : double;
var scale : double;
    rapportDesCases, retrecissementAEchelle : double;
begin
  scale := 1.0000;

  with ParamDiagCourant do
    if not(PionsEnDedansFFORUM)
      then scale := 1.07
      else
        begin
          rapportDesCases := TaillecaseFFORUM * 1.0 / 28.0 ;
          retrecissementAEchelle := nbPixelDedansFFORUM / rapportDesCases;
          scale := (28 - retrecissementAEchelle) / 26.0;
        end;

  CalculateScaleFactorForDiscsInEPSDiagram := scale;
end;


function LaverNomFichierEPSPourPressePapier(oldname : String255) : String255;
var result : String255;
begin

  result := oldname;

  result := ReplaceStringOnce('\b','',result);
  result := ReplaceStringOnce('  ',' ',result);
  result := ReplaceStringOnce('  ',' ',result);
  result := ReplaceStringOnce('  ',' ',result);
  ReplaceCharByCharInString(result,'/','-');
  ReplaceCharByCharInString(result,' ','-');
  ReplaceCharByCharInString(result,' ','-');
  ReplaceCharByCharInString(result,':','-');
  ReplaceCharByCharInString(result,'"','-');
  ReplaceCharByCharInString(result,'(','-');
  ReplaceCharByCharInString(result,')','-');
  ReplaceCharByCharInString(result,'…','.');
  result := ReplaceStringOnce('V-d-','',result);
  result := ReplaceStringOnce('-!-','-',result);
  result := ReplaceStringOnce('-!','-',result);
  result := ReplaceStringOnce('..','.',result);
  result := ReplaceStringOnce('..','.',result);
  result := ReplaceStringOnce('..','.',result);
  result := ReplaceStringOnce('..','.',result);
  result := ReplaceStringOnce('.-','-',result);
  result := ReplaceStringOnce('.-','-',result);
  result := ReplaceStringOnce('.-','-',result);
  result := ReplaceStringOnce('-.','-',result);
  result := ReplaceStringOnce('-.','-',result);
  result := ReplaceStringOnce('-.','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  result := ReplaceStringOnce('--','-',result);
  while (result[1] = '-') do
     result := ReplaceStringOnce('-','',result);

  result := LeftOfString(result, 27) + '.';

  result := ReplaceStringOnce('..','.',result);
  result := ReplaceStringOnce('-.','.',result);

  result := result + 'eps';

  LaverNomFichierEPSPourPressePapier := result;
end;



function PeutOuvrirFichierEPSPourPressePapier(var fic : FichierTEXT) : OSErr;
var legende, nomFichierEPS, nomFichierPDF : String255;
    pathDossierEPS : String255;
    ficPDF : FichierTEXT;
    err, foo : OSErr;
label sortie;
begin
  err := -1;


  if not(DiagrammeDoitCreerVersionEPS) then goto sortie;

  legende := GetLegendeSousLeDiagrammeCourant;
  if (legende = '') then
    legende := ReadStringFromRessource(TextesDiversID,2);   {'sans titre'}


  legende := StripDiacritics(Trim(UTF8ToAscii(legende)));


  // pour les diagrammes de partie, on enleve les scores et les initiales de prenoms
  if (ParamDiagCourant.typeDiagrammeFFORUM = DiagrammePartie) or
     (ParamDiagCourant.typeDiagrammeFFORUM = DiagrammePourListe) then
    begin
      legende := EnleverTousLesChiffres(legende);                                    // pour enlever les scores
      legende := legende + '.∂';
      legende := EnleverLesCaracteresMajusculesEntreCesCaracteres(' ','.',legende);  // pour enlever les initiales de prenoms
      legende := ReplaceStringOnce(' .∂','',legende);
      legende := ReplaceStringOnce('.∂' ,'',legende);
      legende := ReplaceStringOnce(' .',' ',legende);
      legende := ReplaceStringOnce(' .',' ',legende);
    end;

  pathDossierEPS := pathDossierFichiersAuxiliaires + ':eps:';

  err := CreateDirectoryWithThisPath(pathDossierEPS);
  if (err <> NoErr) then goto sortie;

  // on essaye de fabriquer un nom sans ajouter de numero
  nomFichierEPS := LaverNomFichierEPSPourPressePapier(legende);


  // si le fichier existe, il faut rajouter un numero, tant pis
  if FichierTexteExiste(pathDossierEPS + nomFichierEPS, 0, fic) = NoErr
    then nomFichierEPS := LaverNomFichierEPSPourPressePapier(legende + '-' + IntToStr(Abs(GetNewCounterDiagramEPS)));



  nomFichierEPS := pathDossierEPS + nomFichierEPS;
  nomFichierPDF := ReplaceStringOnce('.eps', '.pdf', nomFichierEPS);


  (*
  WritelnDansRapport('nomFichierEPS = ' + nomFichierEPS);
  WritelnDansRapport('nomFichierPDF = ' + nomFichierPDF);
  *)


  err := FichierTexteExiste(nomFichierEPS, 0, fic);
  if (err = -43) {fnfErr => fichier non trouvé, on le crée}
    then err := CreeFichierTexte(nomFichierEPS, 0, fic);
  if (err <> NoErr) then goto sortie;

  err := OuvreFichierTexte(fic);
  if (err <> NoErr) then goto sortie;

  err := VideFichierTexte(fic);
  if (err <> NoErr) then goto sortie;


sortie :

  if (err = NoErr)
    then
      begin
        SetNomsFichiersPostscriptPressePapier(nomFichierEPS, nomFichierPDF);

        if FichierTexteExiste(nomFichierPDF, 0, ficPDF) = NoErr
          then foo := DetruitFichierTexte(ficPDF);

      end
    else
      begin
        if not(CassioSansDouteLanceDepuisUneImageDisque) then
          WritelnNumDansRapport('WARNING : sortie de PeutOuvrirFichierEPSPourPressePapier, err = ', err);
        SetNomsFichiersPostscriptPressePapier('', '');
      end;

  PeutOuvrirFichierEPSPourPressePapier := err;

end;


procedure FermerFichierEPSPourPressePapier;
var err : OSErr;
    taille : SInt32;
begin
  with gInfosDiagrammeFforumEPS do
    begin

      if DiagrammeDoitCreerVersionEPS then
        begin
          // copier le buffer dans le fichier EPS
          taille := GetPositionMarqueurFichierAbstrait(buffer);
          err := WriteFichierAbstraitDansFichierTexte(ficEPS, buffer, 0, taille);

          // fermer le fichier EPS
          err := FermeFichierTexte(ficEPS);
          if (err <> NoErr) then
            begin
              WritelnNumDansRapport('WARNING, dans FermerFichierEPSPourPressePapier, err = ',err);
              SetDiagrammeDoitCreerVersionEPS(false);
            end;
        end;

      // fermer le buffer
      if FichierAbstraitEstCorrect(buffer)
        then DisposeFichierAbstrait(buffer);

    end;
end;


procedure ConstruitPositionEtCoupDapresPartie(var positionEtCoupStr : String255);
	var
		t : SInt16;
		positionInitiale: plateauOthello;
		numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
	positionEtCoupStr := '';
	GetPositionInitialeOfGameTree(positionInitiale, numeroPremierCoup, traitInitial,nbBlancsInitial,nbNoirsInitial);

	for t := 1 to 64 do
		case positionInitiale[othellier[t]] of
			pionNoir:
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('X'));
			pionBlanc:
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('O'));
			otherwise
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('.'));
		end;

	for t := 1 to nbreCoup do
		begin
			case GetCouleurNiemeCoupPartieCourante(t) of
				pionNoir:
					positionEtCoupStr := Concat(positionEtCoupStr, CharToString('N'));
				pionBlanc:
					positionEtCoupStr := Concat(positionEtCoupStr, CharToString('B'));
				otherwise
					positionEtCoupStr := Concat(positionEtCoupStr, CharToString(' '));
			end;
			positionEtCoupStr := Concat(positionEtCoupStr, chr(GetNiemeCoupPartieCourante(t)));
		end;
	for t := nbreCoup + 1 to 60 do
		begin
			positionEtCoupStr := Concat(positionEtCoupStr, CharToString(' '));
			positionEtCoupStr := Concat(positionEtCoupStr, CharToString(' '));
		end;
end;

procedure ConstruitPositionEtCoupPositionInitiale(var positionEtCoupStr : String255);
	var
		t : SInt16;
		positionInitiale: plateauOthello;
		numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
	positionEtCoupStr := '';
	GetPositionInitialeOfGameTree(positionInitiale, numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
	for t := 1 to 64 do
		case positionInitiale[othellier[t]] of
			pionNoir:
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('X'));
			pionBlanc:
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('O'));
			otherwise
				positionEtCoupStr := Concat(positionEtCoupStr, CharToString('.'));
		end;
	for t := 1 to 60 do
		begin
			positionEtCoupStr := Concat(positionEtCoupStr, CharToString(' '));
			positionEtCoupStr := Concat(positionEtCoupStr, CharToString(' '));
		end;
end;


procedure ParserPositionEtCoupsOthello8x8(positionEtCoupStr : String255; var chainePositionInitiale,chaineCoups : String255);
var t,aux,i,j : SInt16;
    plat : plateauOthello;
begin

  chainePositionInitiale := TPCopy(positionEtCoupStr,1,64);
  {on traduit la chaine de la position initiale pour qu'elle soit ligne par ligne}
  for t := 0 to 99 do
    plat[t] := pionVide;
  for t := 1 to 64 do
    if chainePositionInitiale[t] <> '.' then
      begin
        aux := othellier[t];
        if (chainePositionInitiale[t] = 'X') then plat[aux] := pionNoir else
        if (chainePositionInitiale[t] = 'O') or
           (chainePositionInitiale[t] = '0') then plat[aux] := pionBlanc;
      end;
  chainePositionInitiale := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        case plat[10*i+j] of
          pionNoir  : chainePositionInitiale := Concat(chainePositionInitiale, CharToString('X'));
          pionBlanc : chainePositionInitiale := Concat(chainePositionInitiale, CharToString('O'));
          otherwise   chainePositionInitiale := Concat(chainePositionInitiale, CharToString('.'));
        end;
      end;

  chaineCoups := '';
  chaineCoups := TPCopy(positionEtCoupStr,65,120);
  {et on traduit la chaine des coups pour qu'ils soient dans l'intervalle 1..100}
  {NB : 0 represente toujours le coup impossible}
  for t := 1 to (LENGTH_OF_STRING(chaineCoups) div 2) do
    begin
      aux := ord(chaineCoups[2*t]);
      if aux <> 0 then
        begin
		      i := platMod10[aux];
		      j := platDiv10[aux];
		      chaineCoups[2*t] := chr(1 + (j-1)*10 + (i-1));
		    end;
    end;

end;


function GetLegendeSousLeDiagrammeCourant : String255;
var str : String255;
begin
  str := '';
  with ParamDiagCourant do
    begin
      case typeDiagrammeFFORUM of
				DiagrammePartie:
					str := titreFForum^^;
				DiagrammePosition:
					begin
					  if EcritApres37c7FFORUM
					  then
							begin
							  if (nbreCoup >= 1) and (DerniereCaseJouee <> coupInconnu) then
							    begin
								    str := ReadStringFromRessource( TextesImpressionID, 3);   {'Après ^0'}
								    str := ParamStr(str, '', '', '', '');
								    str := str + IntToStr(nbreCoup) + '.' + CHR(96 + platMod10[DerniereCaseJouee]) + CHR(48 + platDiv10[DerniereCaseJouee]);
								  end;
							end
						else if CommentPositionFForum^^ <> '' then
							begin
								str := CommentPositionFForum^^;
							end;
					end;
				DiagrammePourListe:
					if EcritNomsJoueursFFORUM then
					  str := titreFForum^^;
			end;
    end;
  GetLegendeSousLeDiagrammeCourant := str;
end;



function ConstruitChainePosition8x8(plat : plateauOthello) : String255;
var i,j : SInt16;
    result : String255;
begin
  result := '';
  for i := 1 to 8 do
    for j := 1 to 8 do
      case plat[i*10+j] of
        pionNoir  : result := Concat(result, CharToString('X'));
        pionBlanc : result := Concat(result, CharToString('O'));
        otherwise   result := Concat(result, CharToString('.'));
      end; {case}
  ConstruitChainePosition8x8 := result;
end;

function NbreCoupsDansChaineCoups(chaineCoups : String255) : SInt16;
var i,n,len : SInt16;
begin
  n := 0;
  len := LENGTH_OF_STRING(chaineCoups);
  for i := 1 to 126 do
    if (2*i <= len) and
       ((chaineCoups[2*i-1] = 'N') or (chaineCoups[2*i-1] = 'B'))
      then n := i;
  NbreCoupsDansChaineCoups := n;
end;


function QuickdrawColorToDiagramFforumColor(qdColor : SInt16) : SInt16;
begin
	QuickdrawColorToDiagramFforumColor := kCouleurDiagramTransparent;
	case qdColor of
		whiteColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramBlanc;
		GreenColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramVert;
		BlueColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramBleu;
		CyanColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramCyan;
		MagentaColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramMagenta;
		RedColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramRouge;
		YellowColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramJaune;
		BlackColor:
			QuickdrawColorToDiagramFforumColor := kCouleurDiagramNoir;
	end;
end;


function DiagramFforumColorToRGBColor(diagramForumColor : SInt16) : RGBColor;
begin
case diagramForumColor of
  kCouleurDiagramTransparent : DiagramFforumColorToRGBColor := gPurBlanc ;
  kCouleurDiagramBlanc       : DiagramFforumColorToRGBColor := gPurBlanc ;
  kCouleurDiagramVert        : DiagramFforumColorToRGBColor := gPurVert ;
  kCouleurDiagramBleu        : DiagramFforumColorToRGBColor := gPurBleu ;
  kCouleurDiagramCyan        : DiagramFforumColorToRGBColor := gPurCyan ;
  kCouleurDiagramMagenta     : DiagramFforumColorToRGBColor := gPurMagenta ;
  kCouleurDiagramRouge       : DiagramFforumColorToRGBColor := gPurRouge ;
  kCouleurDiagramJaune       : DiagramFforumColorToRGBColor := gPurJaune ;
  kCouleurDiagramNoir        : DiagramFforumColorToRGBColor := gPurNoir ;
end;
end;


function QuickDrawColorToRGBColor(qdColor : SInt16) : RGBColor;
begin
  QuickDrawColorToRGBColor := DiagramFforumColorToRGBColor(QuickdrawColorToDiagramFforumColor(qdColor));
end;



function DoitGenererPostScriptCompatibleXPress : boolean;
begin
  DoitGenererPostScriptCompatibleXPress := PostscriptCompatibleXPress;
end;


procedure SetValeursParDefautDiagFFORUM(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
begin
	with ParamDiag do
		begin
			TypeDiagrammeFFORUM := typeDiagramme;
			DecalageHorFFORUM := 0;
			DecalageVertFFORUM := 0;
			tailleCaseFFORUM := 16;
			epaisseurCadreFFORUM := 1.4;
			distanceCadreFFORUM := 1;
			if typeDiagramme = DiagrammePosition then
				begin
					PionsEnDedansFFORUM := true;
					nbPixelDedansFFORUM := 2;
					FondOthellierPatternFFORUM := kBlackPattern;
					couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
				end
			else
				begin
					PionsEnDedansFFORUM := false;
					nbPixelDedansFFORUM := 1;
					FondOthellierPatternFFORUM := kBlackPattern;
					couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
				end;
			DessineCoinsDuCarreFFORUM := true;
			DessinePierresDeltaFFORUM := true;
			EcritApres37c7FFORUM := true;
			EcritNomTournoiFFORUM := true;
			EcritNomsJoueursFFORUM := true;
			PoliceFFORUMID := 20;      { TimesID = 20 ,  NewYorkID = 2 }
			CoordonneesFFORUM := true;
			NumerosSeulementFFORUM := false;
			TraitsFinsFFORUM := false;
			CouleurRGBOthellierFFORUM := gPurNoir;
			GainTheoriqueFFORUM := '';
		end;
end;

procedure SetValeursRevueAnglaise(var paramDiag: ParamDiagRec; typeDiagramme : SInt16);
	var
		str : String255;
begin
	with paramDiag do
		begin
			TypeDiagrammeFFORUM := typeDiagramme;
			DecalageHorFFORUM := 0;
			DecalageVertFFORUM := 0;
			epaisseurCadreFFORUM := 0.0;
			distanceCadreFFORUM := 0;
			if typeDiagramme = DiagrammePosition then
				begin
					PionsEnDedansFFORUM := true;
					nbPixelDedansFFORUM := 2;
				end
			else
				begin
					PionsEnDedansFFORUM := true;
					nbPixelDedansFFORUM := 2;
				end;
			DessineCoinsDuCarreFFORUM := false;
			DessinePierresDeltaFFORUM := true;
			EcritApres37c7FFORUM := false;
			if (CommentPositionFFORUM^^ = '') and (nbreCoup >= 1) then
				if DerniereCaseJouee <> coupInconnu then
					begin
						str := IntToStr(nbreCoup);
						str := 'After ' + str + CHR(96 + platMod10[DerniereCaseJouee]) + CHR(48 + platDiv10[DerniereCaseJouee]) + CharToString('.');
						CommentPositionFFORUM^^ := str;
					end;
			EcritNomTournoiFFORUM := true;
			EcritNomsJoueursFFORUM := true;
			PoliceFFORUMID := 20;      { TimesID = 20 ,  NewYorkID = 2 }
			CoordonneesFFORUM := false;
			NumerosSeulementFFORUM := true;
			TraitsFinsFFORUM := true;
			FondOthellierPatternFFORUM := kBlackPattern;
			couleurOthellierFFORUM := kCouleurDiagramBlanc {was kCouleurDiagramTransparent};
			CouleurRGBOthellierFFORUM := gPurNoir;
			GainTheoriqueFFORUM := '&&&&&&&&';
		end;
end;


procedure SetNomFichierDansTitreDiagrammeFFORUM(nomFichier : String255);
begin

  while Pos(':',nomFichier) <> 0 do
    nomFichier := TPCopy(nomFichier,Pos(':',nomFichier)+1,LENGTH_OF_STRING(nomFichier)-Pos(':',nomFichier));

  nomFichier := ReplaceStringOnce('.sof', '', nomFichier);
  nomFichier := ReplaceStringOnce('.sgf', '', nomFichier);
  nomFichier := ReplaceStringOnce('.ggf', '', nomFichier);
  nomFichier := ReplaceStringOnce('.SOF', '', nomFichier);
  nomFichier := ReplaceStringOnce('.SGF', '', nomFichier);
  nomFichier := ReplaceStringOnce('.GGF', '', nomFichier);
  nomFichier := ReplaceStringOnce('.pdf', '', nomFichier);
  nomFichier := ReplaceStringOnce('.PDF', '', nomFichier);
  nomFichier := ReplaceStringOnce('.eps', '', nomFichier);
  nomFichier := ReplaceStringOnce('.EPS', '', nomFichier);

  ParamDiagCourant.titreFFORUM^^ := '';
  ParamDiagCourant.commentPositionFFORUM^^ := '';

  ParamDiagPositionFFORUM.titreFFORUM^^ := '';
  if (Pos('lipboard',nomFichier) <= 0) then
    begin
      ParamDiagPositionFFORUM.commentPositionFFORUM^^ := nomFichier;
      ParamDiagPartieFFORUM.titreFFORUM^^ := nomFichier;
    end;
  ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
end;



procedure TranslatePourPostScript(decX,decY : double);
begin
	SendPostscript(Concat(ReelEnString(decX), ' ', ReelEnString(decY), ' translate'));
end;


procedure UnTranslatePourPostScript(decX,decY : double);
begin
	SendPostscript(Concat(ReelEnString(-decX), ' ', ReelEnString(-decY), ' translate'));
end;


procedure SetLineThin;
begin
	SetLineWidthPostscript(2, 5);
end;

procedure SetLineThick;
begin
	SetLineWidthPostscript(5, 2);
	SetLineWidthPostscript(1, 1);
end;



procedure CalculeDecalagesDiagrammeFFORUM(var decalageH, decalageV : SInt16);
var decalagePourLeCadre : SInt16;
    largeurTexteSousLeDiagramme : SInt16;
    largeurDiagrammeProjetee : SInt16;
begin
  DisableQuartzAntiAliasing;
	with ParamDiagCourant do
		begin
		
		  decalagePourLeCadre := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM;
		
			decalageH := decalagePourLeCadre + BlancAGaucheDiagrammeFFORUM;
			if typeDiagrammeFFORUM = DiagrammePourListe then
				decalageH := decalageH + 9;

		  largeurTexteSousLeDiagramme := LargeurTexteSousDiagrammeFFORUM;
		  largeurDiagrammeProjetee := (decalageH + TaillecaseFFORUM * tailleVersionOthello.h + decalagePourLeCadre + BlancADroiteDiagrammeFFORUM);

		  if (largeurTexteSousLeDiagramme > largeurDiagrammeProjetee) and (typeDiagrammeFFORUM <> DiagrammePourListe)
		    then decalageH := decalageH + (largeurTexteSousLeDiagramme-largeurDiagrammeProjetee) div 2;


			if CoordonneesFFORUM then
				decalageV := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + RoundToL(5.5 * TaillecaseFFORUM / 8.0)
			else
				decalageV := RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM;
				
			if (typeDiagrammeFFORUM = DiagrammePourListe) and EcritNomTournoiFFORUM then
				decalageV := decalageV + ((3 * TaillecaseFFORUM) div 4);
				
		end;  {with}
  EnableQuartzAntiAliasing(true);
end;


function LargeurDiagrammeFFORUM : SInt16;
	var
		decalageH, decalageV : SInt16;
		largeurTexteSousLeDiagramme : SInt16;
    largeurDiagrammeProjetee : SInt16;
begin
  DisableQuartzAntiAliasing;
	CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
	with ParamDiagCourant do
	  begin
	    largeurDiagrammeProjetee := TaillecaseFFORUM * tailleVersionOthello.h + decalageH + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + BlancADroiteDiagrammeFFORUM;
	    largeurTexteSousLeDiagramme := LargeurTexteSousDiagrammeFFORUM;

	    if (typeDiagrammeFFORUM = DiagrammePourListe)
	      then LargeurDiagrammeFFORUM := largeurDiagrammeProjetee
	      else LargeurDiagrammeFFORUM := Max(largeurDiagrammeProjetee,largeurTexteSousLeDiagramme);
		end;
  EnableQuartzAntiAliasing(true);
end;

function BlancAGaucheDiagrammeFFORUM : SInt16;
begin
  with ParamDiagCourant do
    if CoordonneesFFORUM
      then BlancAGaucheDiagrammeFFORUM := (3 * TaillecaseFFORUM) div 4
      else BlancAGaucheDiagrammeFFORUM := 0;
end;

function BlancADroiteDiagrammeFFORUM : SInt16;
begin
  BlancADroiteDiagrammeFFORUM := 2;
end;


function HauteurDiagrammeFFORUM : SInt16;
	var
		decalageH, decalageV : SInt16;
		blancSousLeDiagramme : double;
begin

	CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
	
	with ParamDiagCourant do
		begin
		
		  if (GetLegendeSousLeDiagrammeCourant <> '')
		    then blancSousLeDiagramme := 0.85    {hauteur de la ligne sous le diagramme : environ 85% d'une case}
		    else blancSousLeDiagramme := 0.18;
		
		  HauteurDiagrammeFFORUM := RoundToL(TaillecaseFFORUM * (1.0*tailleVersionOthello.v + blancSousLeDiagramme)) + decalageV + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1;
		end;
		
end;


function LargeurTexteSousDiagrammeFFORUM : SInt16;
  var
    str,str1 : String255;
    aux,larg,larg1 : SInt16;
begin
  DisableQuartzAntiAliasing;
  DisableQuartzAntiAliasingThisPort(qdThePort);
  with ParamDiagCourant do
    begin
		  str := '';
			str1 := '';
			larg := 0;
			larg1 := 0;

			case typeDiagrammeFFORUM of
				DiagrammePartie:
					str := titreFForum^^;
				DiagrammePosition:
					begin
					  if EcritApres37c7FFORUM then
							begin
								str := ReadStringFromRessource( TextesImpressionID, 3);   {'Après ^0'}
								str := ParamStr(str, '', '', '', '');
								str := str + '\b37.c7';     {attention : ceci n'est qu'une approximation !}
							end
						else if CommentPositionFForum^^ <> '' then
							begin
								str := CommentPositionFForum^^;
							end;
					end;
				DiagrammePourListe:
					if EcritNomsJoueursFFORUM then
					  str := titreFForum^^;
			end;


			aux := Pos('\b', str);
			if aux > 0 then
				begin
					str1 := TPCopy(str, aux + 2, LENGTH_OF_STRING(str) - aux - 1);
					str := TPCopy(str, 1, aux - 1);
				end;
				

			if (str <> '') or (str1 <> '')
			  then
					begin
						TextFont(PoliceFForumID);
						TextSize(HauteurTexteDansDiagrammeFFORUM);
						TextMode(1);
						TextFace(normal);

						larg := MyStringWidth(str);
						TextFace(bold);
						larg1 := MyStringWidth(str1);

					end;
			LargeurTexteSousDiagrammeFFORUM := larg + larg1;
		end;
  DisableQuartzAntiAliasingThisPort(qdThePort);
  EnableQuartzAntiAliasing(true);
end;

function HauteurTexteDansDiagrammeFFORUM : SInt16;
begin
  with ParamDiagCourant do
    HauteurTexteDansDiagrammeFFORUM := TaillecaseFFORUM div 2 + 1;
end;

procedure ConstruitRectangleTaillePicture;
	var
		unRect : rect;
begin
	with ParamDiagCourant do
		SetRect(unRect, decalageHorFFORUM, decalageVertFFORUM, decalageHorFFORUM + LargeurDiagrammeFFORUM, decalageVertFFORUM + HauteurDiagrammeFFORUM);
	PenPat(grayPattern);
	FrameRect(unRect);
	PenPat(blackPattern);
end;

procedure ConstruitOthellierPicture;
	var
		unRect : rect;
		i, a, b, aux  : SInt16;
		bordExtr : Point;
		haut, diff, fontsize : SInt16;
		decalageH, decalageV : SInt16;
		InfosPolice : fontInfo;
		myFontID : SInt32;
		s : String255;
		theForeColor : RGBColor;
		foorect : Rect;
		scaleForEPS, scaleForDiscs : double;
		err : OSErr;
		{sortieStandard : FichierTEXT;}
begin
  DisableQuartzAntiAliasingThisPort(qdThePort);
	with ParamDiagCourant do
		begin
		
		  // This will force Cassio to copy its private fonts to ~/Library/Fonts/
      myFontID := GetCassioFontNum('aaaaaaaaaaaaabbbbbbb');
		
		
		  // EPS ?
		  if DiagrammeDoitCreerVersionEPS then
		    begin
  			
  			  err := WritePrologueEPSDansFichier(gInfosDiagrammeFforumEPS.buffer, gInfosDiagrammeFforumEPS.nomFichierEPS);
  			
  			  PrintForEPSFile(' ');
  			  PrintForEPSFile('% do the drawing');
  			  PrintForEPSFile(' ');
          PrintForEPSFile('gsave');
          PrintForEPSFile(' ');
          PrintForEPSFile(' ');
  			 	PrintForEPSFile(' % scale the diagram and the discs');
  			 	PrintForEPSFile(' ');
  			 	
  			 	scaleForEPS   := CalculateScaleFactorForEPSDiagram(fooRect);
  			  scaleForDiscs := CalculateScaleFactorForDiscsInEPSDiagram;
  			
  			  PrintForEPSFile(' ' + ReelEnStringAvecDecimales(scaleForEPS + 0.0000099, 5) + ' ' + ReelEnStringAvecDecimales(scaleForEPS + 0.0000099, 5) + ' scale                     %% change the bounding box if you change this');
  			 	PrintForEPSFile(' ');  			
   			  PrintForEPSFile(' /discscalefactor { ' + ReelEnStringAvecDecimales(scaleForDiscs + 0.0000099, 5) + ' } def');
  			 	
  			  if TraitsFinsFFORUM
  			    then PrintForEPSFile(' /pensize { 0.8 } def')
  			    else PrintForEPSFile(' /pensize { 1.0 } def');

  			
  			  PrintForEPSFile(' ');
  			  PrintForEPSFile(' ');
  			  PrintForEPSFile(' % set the fonts');
  			  PrintForEPSFile(' ');

          PrintFontsForEPSDiagram;
  			
  			  PrintForEPSFile(' ');
  			  PrintForEPSFile(' ');
  			 	PrintForEPSFile(' % draw an empty board');
  			 	PrintForEPSFile(' ');
  			
  			end;
		
		
			haut := HauteurTexteDansDiagrammeFFORUM;
			diff := TaillecaseFFORUM div 4;
			CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);


			PenSize(1, 1);
			PenPat(blackPattern);
			TextFont(PoliceFForumID);
			TextSize(haut);
			fontsize := haut;
			GetFontInfo(InfosPolice);
			TextMode(1);
			TextFace(normal);

			if PionsEnDedansFFORUM and odd(nbPixelDedansFFORUM) then
				TranslatePourPostScript(0.5, 0.5);

			if epaisseurCadreFFORUM > 0.0 then
				begin
					SetRect(unRect, decalageHorFFORUM  + decalageH - RoundToL(epaisseurCadreFFORUM) - distanceCadreFFORUM,
					                decalageVertFFORUM + decalageV - RoundToL(epaisseurCadreFFORUM) - distanceCadreFFORUM,
					                decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1,
					                decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM + 1);
					
							SetLineWidthPostscript(RoundToL(epaisseurCadreFFORUM * 100.0), 100);
							FrameRect(unRect);
							SetLineWidthPostscript(100, RoundToL(epaisseurCadreFFORUM * 100.0));
                {on cache le dessin quickdraw a PostScript}
							BeginPostScript;
							PenSize(RoundToL(epaisseurCadreFFORUM), RoundToL(epaisseurCadreFFORUM));
							FrameRect(unRect);
							EndPostScript;
							
				end;

			SetRect(unRect, decalageHorFFORUM  + decalageH,
			                decalageVertFFORUM + decalageV,
			                decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + 1,
			                decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + 1);


			if (couleurOthellierFFORUM <> kCouleurDiagramTransparent) and (FondOthellierPatternFFORUM <> kTranslucidPattern) then
				begin
					case couleurOthellierFFORUM of
						kCouleurDiagramTransparent:
							;
						kCouleurDiagramBlanc:
							ForeColor(WhiteColor);
						kCouleurDiagramVert:
							ForeColor(GreenColor);
						kCouleurDiagramBleu:
							ForeColor(BlueColor);
						kCouleurDiagramCyan:
							ForeColor(CyanColor);
						kCouleurDiagramMagenta:
							ForeColor(MagentaColor);
						kCouleurDiagramRouge:
							ForeColor(RedColor);
						kCouleurDiagramJaune:
							ForeColor(YellowColor);
						kCouleurDiagramNoir:
							ForeColor(BlackColor);
					end;

					if not(IsSameRGBColor(CouleurRGBOthellierFFORUM,gPurNoir)) then
					  begin
					    RGBForeColor(CouleurRGBOthellierFFORUM);
					  end;

					GetForeColor(theForeColor);
					case FondOthellierPatternFFORUM of
						kTranslucidPattern:
							;
						kWhitePattern:
						  begin
							  FillRect(unRect, whitePattern);
							end;
						kLightGrayPattern:
						  begin
						    theForeColor := EclaircirCouleur(theForeColor);
						    theForeColor := EclaircirCouleur(theForeColor);
						    theForeColor := EclaircirCouleur(theForeColor);
						    RGBForeColor(theForeColor);
						    FillRect(unRect, blackPattern);
							end;
						kGrayPattern:
						  begin
						    theForeColor := EclaircirCouleur(theForeColor);
						    theForeColor := EclaircirCouleur(theForeColor);
						    RGBForeColor(theForeColor);
						    FillRect(unRect, blackPattern);
							end;
						kDarkGrayPattern:
						  begin
						    theForeColor := EclaircirCouleur(theForeColor);
						    RGBForeColor(theForeColor);
						    FillRect(unRect, blackPattern);
							end;
						kBlackPattern:
						  begin
							  FillRect(unRect, blackPattern);
							end;
					end;
					
					with theForeColor do
					  PrintForEPSFile(' ' + ReelEnStringAvecDecimales(red/65535.0 , 5) +
					                  ' ' + ReelEnStringAvecDecimales(green/65535.0 , 5) +
					                  ' ' + ReelEnStringAvecDecimales(blue/65535.0 , 5) +
					                  ' board_rgbcolor');
					
					ForeColor(BlackColor);
				end;



      PrintForEPSFile(' board_grid');
      if (epaisseurCadreFFORUM > 0.01)
        then PrintForEPSFile(' board_frame');

			PenSize(1, 1);
			SetLineWidthPostscript(1, 3);

			PenSize(1, 1);
			FrameRect(unRect);
			bordExtr.h := tailleVersionOthello.h * TaillecaseFFORUM;
			bordExtr.v := tailleVersionOthello.v * TaillecaseFFORUM;
			for i := 0 to tailleVersionOthello.h-1 do
				begin
					a := i * TaillecaseFFORUM;
					SetRect(unRect, decalageHorFFORUM + decalageH + a,
					                decalageVertFFORUM + decalageV,
					                decalageHorFFORUM + decalageH + bordExtr.h + 1,
					                decalageVertFFORUM + decalageV + bordExtr.v + 1);
					FrameRect(unRect);
				end;
		  for i := 0 to tailleVersionOthello.v-1 do
				begin
					a := i * TaillecaseFFORUM;
					SetRect(unRect, decalageHorFFORUM + decalageH,
					                decalageVertFFORUM + decalageV + a,
					                decalageHorFFORUM + decalageH + bordExtr.h + 1,
					                decalageVertFFORUM + decalageV + bordExtr.v + 1);
					FrameRect(unRect);
				end;


			SetLineWidthPostscript(3, 1);
		  SetLineWidthPostscript(1, 1);
			PenSize(1, 1);

			if CoordonneesFFORUM then
				begin
				  PrintForEPSFile(' board_coord');
				
				
				  {TextMode(srcXor);}
				  RGBForeColor(gPurGris);
				  for i := 1 to tailleVersionOthello.h do
						begin
							s := chr(ord('a') + i - 1);
							a := i * TaillecaseFFORUM - ((TaillecaseFFORUM + MyStringWidth(s) -1) div 2);
							Moveto(decalageHorFFORUM + decalageH + a, decalageVertFFORUM + decalageV - tailleCaseFFORUM div 4 + 1 -(distanceCadreFFORUM + RoundToL(epaisseurCadreFFORUM)));
							MyDrawString(s);  {colonne}
						end;
				  for i := 1 to tailleVersionOthello.v do
						begin
						  s := IntToStr(i);
						  a := decalageHorFFORUM + decalageH - haut - distanceCadreFFORUM - RoundToL(epaisseurCadreFFORUM);
						  if i >= 10 then a := a-2;
						  if odd(TaillecaseFFORUM)
						    then b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM - diff - 1
						    else b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM - diff;
							{rangee}
							Moveto(a,b);
							if i < 10
							  then MyDrawString(s)
							  else
							    begin
							      DrawChar(s[1]);
							      Move(-1,0);
							      DrawChar(s[2]);
							    end;

						end;
					RGBForeColor(gPurNoir);
				end;
				
			if DessineCoinsDuCarreFFORUM and (tailleVersionOthello.h >= 4) and (tailleVersionOthello.v >= 4) then
				begin
				  PrintForEPSFile(' board_marks');
				
					SetLineThin;
					PenSize(1, 1);
					
					aux := TaillecaseFFORUM div 10;
					if aux = 0 then
						aux := 1;
					a := decalageHorFFORUM + decalageH + 2 * TaillecaseFFORUM;
					b := decalageVertFFORUM + decalageV + 2 * TaillecaseFFORUM;
					SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
					FillOval(unRect, blackPattern);
					a := decalageHorFFORUM + decalageH + 2 * TaillecaseFFORUM;
					b := decalageVertFFORUM + decalageV + (tailleVersionOthello.v-2) * TaillecaseFFORUM;
					SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
					FillOval(unRect, blackPattern);
					a := decalageHorFFORUM + decalageH + (tailleVersionOthello.h-2) * TaillecaseFFORUM;
					b := decalageVertFFORUM + decalageV + 2 * TaillecaseFFORUM;
					SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
					FillOval(unRect, blackPattern);
					a := decalageHorFFORUM + decalageH + (tailleVersionOthello.h-2) * TaillecaseFFORUM;
					b := decalageVertFFORUM + decalageV + (tailleVersionOthello.v-2) * TaillecaseFFORUM;
					SetRect(unRect, a - aux, b - aux, a + aux + 1, b + aux + 1);
					FillOval(unRect, blackPattern);
					
					SetLineThick;
					PenSize(1, 1);
				end;

			if PionsEnDedansFFORUM and odd(nbPixelDedansFFORUM) then
				UnTranslatePourPostScript(0.5, 0.5);
		end;
  DisableQuartzAntiAliasingThisPort(qdThePort);
end;

procedure CalculeRectanglePionEnDedansFFORUM(var PionRect : rect; nbPixelDedansFFORUM : SInt16);
begin
	if odd(nbPixelDedansFFORUM) then
		begin
			inc(PionRect.left);
			inc(PionRect.top);
		end;
	InsetRect(PionRect, nbPixelDedansFFORUM div 2, nbPixelDedansFFORUM div 2);
end;

procedure DessinePionNoirDiagrammeFforum(whichRect : rect);
begin
	ForeColor(blackColor);
	FrameOval(whichRect);
	InsetRect(whichRect, 1, 1);
	SetLineWidthPostscript(2, 1);
	FrameOval(whichRect);
	SetLineThin;
	FillOval(whichRect, blackPattern);
end;

procedure DessinePionBlancDiagrammeFforum(whichRect : rect);
begin
	if ParamDiagCourant.couleurOthellierFFORUM <> kCouleurDiagramTransparent then
		begin
			BackColor(whiteColor);
			ForeColor(whiteColor);
			EraseOval(whichRect);
		end;
	ForeColor(blackColor);
	FrameOval(whichRect);
end;



procedure ConstruitPositionPicture(chainePosition,chaineCoups : String255);
	var
		unRect : rect;
		i, j, a, b, aux  : SInt16;
		haut, diff, larg, larg1, fontsize : SInt16;
		decalageH, decalageV : SInt16;
		str, str1: String255;
		nbreCoupConstruction : SInt16;
		nbreCasesPosition : SInt16;
		InfosPolice: fontInfo;
begin
  DisableQuartzAntiAliasingThisPort(qdThePort);
	with ParamDiagCourant do
		begin
			nbreCoupConstruction := NbreCoupsDansChaineCoups(chaineCoups);
			nbreCasesPosition := LENGTH_OF_STRING(chainePosition);
			haut := HauteurTexteDansDiagrammeFFORUM;
			diff := (TaillecaseFFORUM) div 4;
			CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);


			PenSize(1, 1);
			PenPat(blackPattern);
			TextMode(1);
			TextFont(PoliceFForumID);
			TextFace(normal);
			TextSize(haut);
			fontsize := haut;
			GetFontInfo(InfosPolice);

			ConstruitOthellierPicture;
			
			
			PrintForEPSFile(' ');
			PrintForEPSFile(' ');
			PrintForEPSFile(' % draw the position');
			PrintForEPSFile(' ');
			

			SetLineThin;
			PenSize(1, 1);
			aux := 0;
			for i := 1 to tailleVersionOthello.v do
				for j := 1 to tailleVersionOthello.h do
					begin
					  inc(aux);
						if (aux <= nbreCasesPosition) and (chainePosition[aux] <> '.') then
							begin
								a := decalageHorFFORUM + decalageH + j * TaillecaseFFORUM;
								b := decalageVertFFORUM + decalageV + i * TaillecaseFFORUM;
								SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
								if PionsEnDedansFFORUM then
									CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);
								if chainePosition[aux] = 'X' then
								  begin
								    DessinePionNoirDiagrammeFforum(unRect);
								    PrintForEPSFile(' ' + CoupEnStringEnMajuscules(10 * i + j) + ' black_disc');
								  end else
								if (chainePosition[aux] = 'O') or (chainePosition[aux] = '0') then
									begin
									  DessinePionBlancDiagrammeFforum(unRect);
									  PrintForEPSFile(' ' + CoupEnStringEnMajuscules(10 * i + j) + ' white_disc');
									end;
							end;
					end;
			SetLineThick;
			PenSize(1, 1);



   {écriture de la ligne de texte sous le diagramme}
			str := '';
			str1 := '';
			if EcritApres37c7FFORUM then
				begin
					if nbreCoupConstruction >= 1 then
					  begin
					    aux := ord(chaineCoups[2 * nbreCoupConstruction]);
							if aux <> coupInconnu then
								begin
									str := ReadStringFromRessource( TextesImpressionID, 3);   {'Après ^0'}
									str := ParamStr(str, '', '', '', '');
									str1 := IntToStr(nbreCoupConstruction);
									str1 := str1 + CharToString('.') + CHR(96 + (platMod10[aux-1]+1)) + CHR(48 + (platDiv10[aux-1]+1));
								end;
					  end;
				end
			else if CommentPositionFForum^^ <> '' then
				begin
					str := CommentPositionFForum^^;
					aux := Pos('\b', str);
					if aux > 0 then
						begin
							str1 := TPCopy(str, aux + 2, LENGTH_OF_STRING(str) - aux - 1);
							str := TPCopy(str, 1, aux - 1);
						end;
				end;
		  DisableQuartzAntiAliasing;
			if (str <> '') or (str1 <> '') then
				begin
					TextFont(PoliceFForumID);
					TextSize(haut);
					fontsize := haut;
					GetFontInfo(InfosPolice);
					TextMode(1);
					TextFace(normal);
					larg := MyStringWidth(str);
					TextFace(bold);
					larg1 := MyStringWidth(str1);
					if (larg + larg1) <= (tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(2.0*epaisseurCadreFFORUM) + 2*distanceCadreFFORUM)
					  then
					    {justification au centre de l'othellier}
					    a := decalageHorFFORUM  + decalageH + ((tailleVersionOthello.h * TaillecaseFFORUM) div 2) - (larg + larg1) div 2
					  else
					    if (BlancAGaucheDiagrammeFFORUM > 0) and (BlancADroiteDiagrammeFFORUM = 2)
					      then
					        {justification à droite}
					        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM - (larg + larg1))
					      else
					        {justification au centre de toute l'image}
					        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM - (larg + larg1)) div 2;
				  DisableQuartzAntiAliasing;
					Moveto(a,decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + haut + diff - 1 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM);
					TextFace(normal);
					MyDrawString(str);
					TextFace(bold);
					MyDrawString(str1)
				end;
				
		  if DiagrammeDoitCreerVersionEPS then
				PrintLegendeDiagrammeForEPSFile(str, str1);
				
      EnableQuartzAntiAliasing(true);
		end;
  DisableQuartzAntiAliasingThisPort(qdThePort);
end;

procedure ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups : String255);
	var
		unRect : rect;
		i, j, t, a, b, aux  : SInt16;
		x, y : SInt16;
		haut, diff, larg, larg1, fontsize : SInt16;
		decalageH, decalageV, centragevertical : SInt16;
		str, str1: String255;
		nbreCoupConstruction : SInt16;
		InfosPolice: fontInfo;
begin

	nbreCoupConstruction := NbreCoupsDansChaineCoups(chaineCoups);

	{
	WritelnDansRapport('chainePositionInitiale = '+chainePositionInitiale);
  WritelnDansRapport('chaineCoups = '+chaineCoups);
	WritelnNumDansRapport('nbreCoupConstruction = ',nbreCoupConstruction);
	}

	DisableQuartzAntiAliasingThisPort(qdThePort);
	with ParamDiagCourant do
		begin
			haut := HauteurTexteDansDiagrammeFFORUM;
			diff := TaillecaseFFORUM div 4;
			CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);

			PenSize(1, 1);
			PenPat(blackPattern);
			TextFont(PoliceFForumID);
			TextFace(normal);
			TextSize(haut);
			fontsize := haut;
			GetFontInfo(InfosPolice);
			ConstruitOthellierPicture;
			TextFont(PoliceFForumID);
			
			
			PrintForEPSFile(' ');
			PrintForEPSFile(' ');
			PrintForEPSFile(' % draw the initial position');
			PrintForEPSFile(' ');
			

			SetLineThin;
			PenSize(1,1);
			for j := 1 to tailleVersionOthello.v  do
			  for i := 1 to tailleVersionOthello.h  do
			    begin
			      t := (j-1)*tailleVersionOthello.h + i;
						if chainePositionInitiale[t] <> '.' then
							begin
								a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
								b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
								SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
								if PionsEnDedansFFORUM then
									CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);
							  if chainePositionInitiale[t] = 'X' then
								  begin
								    DessinePionNoirDiagrammeFforum(unRect);
								    PrintForEPSFile(' ' + CoupEnStringEnMajuscules(10 * j + i) + ' black_disc');
								  end else
								if (chainePositionInitiale[t] = 'O') or (chainePositionInitiale[t] = '0') then
									begin
									  DessinePionBlancDiagrammeFforum(unRect);
									  PrintForEPSFile(' ' + CoupEnStringEnMajuscules(10 * j + i) + ' white_disc');
									end;
							end;
					end;
			SetLineThick;
			PenSize(1, 1);
			
			
			PrintForEPSFile(' ');
			PrintForEPSFile(' ');
			PrintForEPSFile(' % draw the moves');
			PrintForEPSFile(' ');
			if numerosSeulementFFORUM then
			  PrintForEPSFile(' /discscalefactor { 1.05 } def');
			PrintForEPSFile(' regularfont findfont 12 scalemovenumber setfont');
			
			
			TextFont(PoliceFForumID);
			if numerosSeulementFFORUM then
				begin
					fontsize := haut + 1;
					TextSize(fontsize);
					GetFontInfo(InfosPolice);
					centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

					for t := 1 to nbreCoupConstruction do
						begin
							aux := ord(chaineCoups[2 * t]);
							if aux <> coupInconnu then
									begin
										i := platMod10[aux-1] + 1;
										j := platDiv10[aux-1] + 1;
										
										
										PrintForEPSFile(' (' + IntToStr(t) +') '
											                  + CoupEnStringEnMajuscules(10 * j + i)
											                  + ' move_number');
										
										TextMode(1);
										if t >= 100
										  then TextFace(condense)
										  else TextFace(normal);

										a := decalageH + i * TaillecaseFFORUM;
										b := decalageV + j * TaillecaseFFORUM;
										if (t >= 10) and (t <= 99) then
											begin
												str := IntToStr(platMod10[t]);
												str1 := IntToStr(platDiv10[t]);
												larg := MyStringWidth(str);
												larg1 := MyStringWidth(str1);
												y := b - centragevertical;
												x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
												Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
												MyDrawString(str1);
												x := a -(TaillecaseFFORUM - larg1 + larg) div 2;
												Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
												MyDrawString(str);
											end
										else
											begin
												str := IntToStr(t);
												y := b - centragevertical;
												x := a -(TaillecaseFFORUM + MyStringWidth(str) - 1) div 2;
												Moveto(decalageHorFFORUM + x, decalageVertFFORUM + y);
												MyDrawString(str);
											end;
									end;
						end;
				  PrintForEPSFile(' /discscalefactor { ' + ReelEnStringAvecDecimales(CalculateScaleFactorForDiscsInEPSDiagram + 0.0000099, 5) + ' } def');
				end
			else
				begin
					if PionsEnDedansFFORUM then
						fontsize := haut - (nbPixelDedansFFORUM div 2)
					else
						fontsize := haut;
					TextSize(fontsize);
					GetFontInfo(InfosPolice);
					centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

					SetLineThin;
					PenSize(1, 1);
					for t := 1 to nbreCoupConstruction do
						begin
							aux := ord(chaineCoups[2 * t]);
							if aux <> coupInconnu then
									begin
										i := platMod10[aux-1] + 1;
										j := platDiv10[aux-1] + 1;
										a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
										b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
										SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
										if PionsEnDedansFFORUM then
											CalculeRectanglePionEnDedansFFORUM(unRect, nbPixelDedansFFORUM);

										if chaineCoups[2*t - 1] = 'N' then  {pions noirs, avec le numero du coup en blanc}
											begin
											
											  PrintForEPSFile(' (' + IntToStr(t) +') '
											                  + CoupEnStringEnMajuscules(10 * j + i)
											                  + ' black_move');
											
											
												DessinePionNoirDiagrammeFforum(unRect);
                        DisableQuartzAntiAliasing;

												TextMode(3);
												if (PoliceFForumID = 0) and (haut >= 12) then
													TextFace(normal)        {Chicago est deja assez large}
												else
													TextFace(bold);
											  if t >= 100 then TextFace(condense);

												if (t >= 10) and (t <= 99) and (PoliceFForumID = NewYorkID) then  { New York }
													begin
														str := IntToStr(platMod10[t]);
														str1 := IntToStr(platDiv10[t]);
														larg := MyStringWidth(str);
														larg1 := MyStringWidth(str1);
														y := b - centragevertical;
														x := a - (TaillecaseFFORUM + larg + larg1) div 2 + 2;

														Moveto(x, y);
														PenPat(blackPattern);
														TextMode(3);
                            {MyDrawString(str1);}

														DrawTranslatedString(str1, +0.49, 0.0);

														x := a - (TaillecaseFFORUM - larg1 + larg) div 2;
														Moveto(x, y);
														PenPat(blackPattern);
														TextMode(3);
														MyDrawString(str);
													end
												else
													begin
														str := IntToStr(t);
														y := b - centragevertical;
														x := a - (TaillecaseFFORUM + MyStringWidth(str) + 1) div 2 + 2;

														Moveto(x, y);
														PenPat(blackPattern);
														TextMode(3);
														
														if (t >= 10) then MyDrawString(IntToStr(platDiv10[t]));
														
														Move(-1,0);
														MyDrawString(IntToStr(platMod10[t]));

													end;
											  EnableQuartzAntiAliasing(true);
											end
										else if chaineCoups[2*t - 1] = 'B' then   {pions blancs, avec le numero du coup en noir}
											begin
											
											  PrintForEPSFile(' (' + IntToStr(t) +') '
											                  + CoupEnStringEnMajuscules(10 * j + i)
											                  + ' white_move');
											
											
												DessinePionBlancDiagrammeFforum(unRect);
												DisableQuartzAntiAliasing;
												
												TextMode(1);
												if t >= 100
												  then TextFace(condense)
												  else TextFace(normal);
												if (t >= 10) and (t <= 99) and (PoliceFForumID = NewYorkID) then
													begin
														str := IntToStr(platMod10[t]);
														str1 := IntToStr(platDiv10[t]);
														larg := MyStringWidth(str);
														larg1 := MyStringWidth(str1);
														y := b - centragevertical;
														x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
														Moveto(x, y);
														MyDrawString(str1);
														x := a -(TaillecaseFFORUM - larg1 + larg + 1) div 2;
														Moveto(x, y);
														MyDrawString(str);
													end
												else
													begin
														str := IntToStr(t);
														y := b - centragevertical;
														x := a - (TaillecaseFFORUM + MyStringWidth(str) + 1) div 2 + 1;
														
														Moveto(x, y);
														
														if (t >= 10) then MyDrawString(IntToStr(platDiv10[t]));
														
														Move(-1,0);
														MyDrawString(IntToStr(platMod10[t]));
													end;
											  EnableQuartzAntiAliasing(true);
											end;
									end;
						end;
				end;

   {écriture de la ligne de texte sous le diagramme}
      DisableQuartzAntiAliasing;
			str := '';
			str1 := '';
			if (titreFForum^^ <> '') then
				if (typeDiagrammeFFORUM = DiagrammePartie) or
				   ((typeDiagrammeFFORUM = DiagrammePourListe) and EcritNomsJoueursFFORUM) then
					begin
						str := titreFForum^^;
						aux := Pos('\b', str);
						if aux > 0 then
							begin
								str1 := TPCopy(str, aux + 2, LENGTH_OF_STRING(str) - aux - 1);
								str := TPCopy(str, 1, aux - 1);
							end;
					end;
			if (str <> '') or (str1 <> '') then
				begin
					TextFont(PoliceFForumID);
					TextSize(haut);
					fontsize := haut;
					GetFontInfo(InfosPolice);
					TextMode(1);
					TextFace(normal);
					larg := MyStringWidth(str);
					TextFace(bold);
					larg1 := MyStringWidth(str1);


					if (larg + larg1) <= (tailleVersionOthello.h * TaillecaseFFORUM + RoundToL(2.0*epaisseurCadreFFORUM) + 2*distanceCadreFFORUM)
					  then
					    {justification au centre de l'othellier}
					    a := decalageHorFFORUM  + decalageH + ((tailleVersionOthello.h * TaillecaseFFORUM) div 2) - (larg + larg1) div 2
					  else
					    if (BlancAGaucheDiagrammeFFORUM > 0) and (BlancADroiteDiagrammeFFORUM = 2)
					      then
					        {justification à droite}
					        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM - (larg + larg1))
					      else
					        {justification au centre de toute l'image}
					        a := decalageHorFFORUM  + (LargeurDiagrammeFFORUM - (larg + larg1)) div 2;
					Moveto(a,decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM + haut + diff - 1 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM);

          DisableQuartzAntiAliasing;
					TextFace(normal);
					MyDrawString(str);
					TextFace(bold);
					MyDrawString(str1)
				end;
			
			if DiagrammeDoitCreerVersionEPS then
				PrintLegendeDiagrammeForEPSFile(str, str1);

   {écriture des infos facultatives telles que Gain théorique, tournoi, etc.}
			TextFont(PoliceFForumID);
			TextSize(haut);
			fontsize := haut;
			GetFontInfo(InfosPolice);
			TextMode(1);
			TextFace(normal);
			if typeDiagrammeFFORUM = DiagrammePourListe then
				begin
					Moveto(decalageHorFFORUM  + decalageH + tailleVersionOthello.h * TaillecaseFFORUM + 2 + RoundToL(epaisseurCadreFFORUM) + distanceCadreFFORUM,
					       decalageVertFFORUM + decalageV + tailleVersionOthello.v * TaillecaseFFORUM - 2);
					MyDrawString(GainTheoriqueFFORUM);
				end;
			if (CommentPositionFForum^^ <> '') then
				if ((typeDiagrammeFFORUM = DiagrammePourListe) and EcritNomTournoiFFORUM) then
					begin
						str := CommentPositionFForum^^;
						larg := MyStringWidth(str) div 2;
						Moveto(decalageHorFFORUM + decalageH + (tailleVersionOthello.h div 2) * TaillecaseFFORUM - larg, decalageVertFFORUM + haut + 1);
						MyDrawString(str);
					end;

		  EnableQuartzAntiAliasing(true);
		end;
  DisableQuartzAntiAliasingThisPort(qdThePort);
end;

function CalculeRectOfSquare2DDiagrammeFforum(quelleCase : SInt16) : rect;
	var
		result : rect;
		a, b, i, j, decalageH, decalageV : SInt16;
begin
	with ParamDiagCourant do
		begin
			CalculeDecalagesDiagrammeFFORUM(decalageH, decalageV);
			i := (quellecase mod 10);
			j := (quellecase div 10);
			a := decalageHorFFORUM + decalageH + i * TaillecaseFFORUM;
			b := decalageVertFFORUM + decalageV + j * TaillecaseFFORUM;
			SetRect(result, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
			if PionsEnDedansFFORUM then
				CalculeRectanglePionEnDedansFFORUM(result, nbPixelDedansFFORUM);
		end;
	CalculeRectOfSquare2DDiagrammeFforum := result;
end;

function DoitDecalerRectPourQueLesDeltaSoientCentres(quellecase, genreDeMarqueSpeciale : SInt16) : boolean;
	var
		result : rect;
begin
	result := CalculeRectOfSquare2DDiagrammeFforum(quelleCase);
	if not(odd(result.right - result.left)) and
	   InPropertyTypes(genreDeMarqueSpeciale,[LosangeWhiteProp, LosangeBlackProp, LosangeProp, DeltaWhiteProp, DeltaBlackProp, DeltaProp, LineProp, ArrowProp]) then
		DoitDecalerRectPourQueLesDeltaSoientCentres := true
	else
		DoitDecalerRectPourQueLesDeltaSoientCentres := false;
end;


function GetRectOfSquare2DDiagrammeFforum(quellecase, genreDeMarqueSpeciale : SInt16) : rect;
	var
		result : rect;
begin
	result := CalculeRectOfSquare2DDiagrammeFforum(quelleCase);
	if DoitDecalerRectPourQueLesDeltaSoientCentres(quellecase, genreDeMarqueSpeciale) then
		begin
			dec(result.left);
			dec(result.top);
		end;
	GetRectOfSquare2DDiagrammeFforum := result;
end;


function BidonGetRect3DFunc(foo, bar : SInt16) : rect;
	var
		result : rect;
begin
{$UNUSED foo,bar}
	SetRect(result, 0, 0, 0, 0);
	BidonGetRect3DFunc := result;
end;




procedure DessinerPierresDeltaOfPropertyDiagrammeFforum(var prop : Property);
	var
		whichSquare, i, j, whichSquare2 : SInt16;
		RegionMarquee : PackedSquareSet;
		texte, foo : String255;

    procedure SetEpaisseurTraitEtTranslateCommeNecessaire(genre,square : SInt16);
      var TraitMoyen,TraitFin,EstUnCercle : boolean;
      begin
          begin
		        TraitMoyen  := InPropertyTypes(genre,[CarreWhiteProp, CarreBlackProp, CarreProp, ArrowProp, LineProp]) or
		                      ((genre = MarkedPointsProp) and (GetCouleurOfSquareDansJeuCourant(square) = pionNoir));
		        TraitFin   := not(TraitMoyen);
		        EstUnCercle := InPropertyTypes(genre,[PetitCercleWhiteProp, PetitCercleBlackProp, PetitCercleProp]);

		        if TraitMoyen
		          then
		            begin
		              SetLineWidthPostscript(1, 2);
		              if not(EstUnCercle) then TranslatePourPostScript(0.25, 0.25);
		            end
		          else
		            begin
		              SetLineWidthPostscript(1, 3);
		              if not(EstUnCercle) then TranslatePourPostScript(0.33, 0.33);
		            end;

		        if DoitDecalerRectPourQueLesDeltaSoientCentres(11, genre)
		          then TranslatePourPostScript(0.5, 0.5);
		      end;
      end;

      procedure UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,square : SInt16);
      var TraitMoyen,TraitFin,EstUnCercle : boolean;
      begin
          begin
		        TraitMoyen  := InPropertyTypes(genre,[CarreWhiteProp, CarreBlackProp, CarreProp, ArrowProp, LineProp]) or
		                      ((genre = MarkedPointsProp) and (GetCouleurOfSquareDansJeuCourant(square) = pionNoir));
		        TraitFin   := not(TraitMoyen);
		        EstUnCercle := InPropertyTypes(genre,[PetitCercleWhiteProp, PetitCercleBlackProp, PetitCercleProp]);

		        if TraitMoyen
		          then
		            begin
		              SetLineWidthPostscript(2, 1);
		              SetLineWidthPostscript(1, 1);
		              if not(EstUnCercle) then UnTranslatePourPostScript(0.25, 0.25);
		            end
		          else
		            begin
		              SetLineWidthPostscript(3, 1);
		              SetLineWidthPostscript(1, 1);
		              if not(EstUnCercle) then UnTranslatePourPostScript(0.33, 0.33);
		            end;

		        if DoitDecalerRectPourQueLesDeltaSoientCentres(11, genre)
		          then UnTranslatePourPostScript(0.5, 0.5);
		      end;
      end;



begin
	with prop do
		begin
		  texte := '';
		  if prop.genre = LabelOnPointsProp then
		    begin
		      texte := GetStringInfoOfProperty(prop);
		      SplitBy(texte, ':', foo, texte);
		    end;
		
			case stockage of
				StockageEnEnsembleDeCases:
					begin
						RegionMarquee := GetPackedSquareSetOfProperty(prop);
						for i := 1 to 8 do
							for j := 1 to 8 do
								begin
									whichSquare := i * 10 + j;
									if SquareInPackedSquareSet(whichSquare, RegionMarquee) then
										begin
										  SetEpaisseurTraitEtTranslateCommeNecessaire(genre,whichSquare);
										  DessinerUnePierreDelta(JeuCourant, whichSquare, genre, GetRectOfSquare2DDiagrammeFforum, texte, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
								      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,whichSquare);
								    end;
								end;
					end;
				StockageEnCaseOthello:
				  begin
				    SetEpaisseurTraitEtTranslateCommeNecessaire(genre,GetOthelloSquareOfProperty(prop));
					  DessinerUnePierreDelta(JeuCourant, GetOthelloSquareOfProperty(prop), genre, GetRectOfSquare2DDiagrammeFforum, texte, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
				    UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,GetOthelloSquareOfProperty(prop));
				  end;
				StockageEnCaseOthelloAlpha:
					begin
					  SetEpaisseurTraitEtTranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
					  DessinerUnePierreDelta(JeuCourant, GetOthelloSquareOfPropertyAlpha(prop), genre, GetRectOfSquare2DDiagrammeFforum, texte, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
			      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
			    end;
			  StockageEnStr255:
			    begin
			      SetEpaisseurTraitEtTranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
					  DessinerUnePierreDelta(JeuCourant, GetOthelloSquareOfPropertyAlpha(prop), genre, GetRectOfSquare2DDiagrammeFforum, texte, false, BidonGetRect3DFunc, BidonGetRect3DFunc);
			      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,GetOthelloSquareOfPropertyAlpha(prop));
			    end;
			  StockageEnCoupleCases:
					begin
					  GetSquareCoupleOfProperty(prop, whichSquare, whichSquare2);
					  SetEpaisseurTraitEtTranslateCommeNecessaire(genre, whichSquare);
					  DessinerUnePierreDeltaDouble(JeuCourant, whichSquare, whichSquare2, genre,
                                         GetRectOfSquare2DDiagrammeFforum,
                                         false,
                                         BidonGetRect3DFunc,
                                         BidonGetRect3DFunc);
			      UnsetEpaisseurTraitEtUntranslateCommeNecessaire(genre,whichSquare);
			    end;
			end; {case}
		end; {with}
end;


procedure ConstruitPicturePionsDeltaCourants;
var flechesEtLignes : SetOfPropertyTypes;
begin
  PrintForEPSFile(' ');
	PrintForEPSFile(' % draw the SGF annotations (section may be empty)');
	PrintForEPSFile(' ');
	PrintForEPSFile(' regularfont findfont 12 scalemovenumber setfont');
	
	
	flechesEtLignes := [ LineProp , ArrowProp ];
	
	ItereSurPierresDeltaCourantes(TypesPierresDelta - flechesEtLignes, DessinerPierresDeltaOfPropertyDiagrammeFforum);
	ItereSurPierresDeltaCourantes(flechesEtLignes, DessinerPierresDeltaOfPropertyDiagrammeFforum);
	
end;



function CopierPICTDansPressePapier(myPicture : PicHandle) : OSErr;
begin
	HLockHi(Handle(myPicture));
	CopierPICTDansPressePapier := MyPutScrap(GetHandleSize(Handle(myPicture)), MY_FOUR_CHAR_CODE('PICT'), Ptr(myPicture^));
	HUnlock(Handle(myPicture));
end;


procedure ConvertirFichierEPSEnPDF;
var eps, pdf, UnixPath : String255;
    err : OSErr;
begin
  if DiagrammeDoitCreerVersionEPS then
    begin
      eps  := gInfosDiagrammeFforumEPS.nomFichierEPS;
      pdf  := gInfosDiagrammeFforumEPS.nomFichierPDF;

      (*
      WritelnDansRapport('eps = ' + eps);
      WritelnDansRapport('pdf = ' + pdf);
      WritelnDansRapport('eps = ' + MacPathToUNIXPath(eps));
      WritelnDansRapport('pdf = ' + MacPathToUNIXPath(pdf));
      *)

      if (eps <> '') then
        begin
          UnixPath := MacPathToUNIXPath(eps);
          err      := LaunchUNIXProcess('/usr/bin/pstopdf', '"' + UnixPath + '"' );
        end;

    end;
end;


procedure CopierEnMacDraw;
var numeroProbleme : SInt32;
		err : OSErr;
		saisie : rect;
		OthellierPicture : PicHandle;
		oldClipRgn : RgnHandle;
		positionEtCoupStr : String255;
		oldPen : PenState;
		chainePositionInitiale, chaineCoups : String255;
		chainePosition : String255;
		fichierEPS : FichierTEXT;
begin
	if not(enSetUp) then
		begin
		
			if enRetour then
				ParamDiagCourant.TypeDiagrammeFFORUM := DiagrammePartie
			else
				ParamDiagCourant.TypeDiagrammeFFORUM := DiagrammePosition;
				
		  SetDiagrammeDoitCreerVersionEPS(true);
		
		  if (MakeBufferPourDiagrammeEPS = NoErr) and (PeutOuvrirFichierEPSPourPressePapier(fichierEPS) = NoErr)
		    then SetFichierPourDiagrammeEPS(fichierEPS)
		    else SetDiagrammeDoitCreerVersionEPS(false);

			GetPenState(oldPen);
			oldClipRgn := NewRgn;
			GetClip(oldClipRgn);
			SetRect(saisie, ParamDiagCourant.decalageHorFFORUM,
			                ParamDiagCourant.decalageVertFFORUM,
			                ParamDiagCourant.decalageHorFFORUM + LargeurDiagrammeFFORUM,
			                ParamDiagCourant.decalageVertFFORUM + HauteurDiagrammeFFORUM);
			ClipRect(saisie);
			OthellierPicture := OpenPicture(saisie);

			ConstruitPositionEtCoupDapresPartie(positionEtCoupStr);
			ParserPositionEtCoupsOthello8x8(positionEtCoupStr,chainePositionInitiale,chaineCoups);
			chainePosition := ConstruitChainePosition8x8(JeuCourant);

			case ParamDiagCourant.typeDiagrammeFFORUM of
				DiagrammePartie:
					ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
				DiagrammePosition:
					begin
					  ConstruitPositionPicture(chainePosition,chaineCoups);
					  if not(ParamDiagCourant.EcritApres37c7FFORUM) then
					    if EstUnEnonceNumeroteDeProblemeDeCoin(ParamDiagCourant.CommentPositionFFORUM^^,numeroProbleme)
					      then
					        begin
					          SetDoitNumeroterProblemesDePriseDeCoin(true);
					          SetNumeroProblemeDePriseDeCoin(numeroProbleme);
			              SetPeutIncrementerNumerotationDiagrammeDePriseDeCoin(true);
			            end
			          else
			            SetDoitNumeroterProblemesDePriseDeCoin(false);
			    end;
				DiagrammePourListe:
					begin
					  WritelnDansRapport('ASSERT : should never happen in CopierEnMacDraw !!!');
					  ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
					end;
			end;
			if ParamDiagCourant.DessinePierresDeltaFFORUM then
				ConstruitPicturePionsDeltaCourants;
				
		  PrintEpilogueForEPSFile;
		  FermerFichierEPSPourPressePapier;
		
		  TextMode(srcOr);
      TextFace(normal);
      ForeColor(BlackColor);
      BackColor(WhiteColor);

			ClosePicture;
			SetClip(oldclipRgn);
			DisposeRgn(oldclipRgn);
			
			
			ConvertirFichierEPSEnPDF;
			
			err := MyZeroScrap;
			err := CopierPICTDansPressePapier(OthellierPicture);
			
			if DiagrammeDoitCreerVersionEPS then
			  begin
			    err := DumpFileToPressePapier(gInfosDiagrammeFforumEPS.nomFichierEPS , MY_FOUR_CHAR_CODE('EPS '));
			
			    {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
			    err := DumpFileToPressePapier(gInfosDiagrammeFforumEPS.nomFichierPDF , MY_FOUR_CHAR_CODE('PDF '));
			    {$ENDC}
			  end;
			

			KillPicture(OthellierPicture);
			SetPenState(oldPen);
			
			SetDiagrammeDoitCreerVersionEPS(false);
			
		end;
end;


procedure CopierPucesNumerotees;
	var
		aux : SInt32;
		saisie : rect;
		PucePicture : PicHandle;
		oldclipRgn : RgnHandle;
		oldPen : PenState;

procedure ConstruitPuce(numero : SInt16);
		var
			unRect : rect;
			a, b : SInt16;
			x, y : SInt16;
			haut, diff, larg, larg1, fontsize : SInt16;
			centragevertical : SInt16;
			str, str1: String255;
			InfosPolice: fontInfo;
	begin
	  DisableQuartzAntiAliasingThisPort(qdThePort);
		with ParamDiagCourant do
			begin
				haut := HauteurTexteDansDiagrammeFFORUM;
				diff := TaillecaseFFORUM div 4;

				PenSize(1, 1);
				PenPat(blackPattern);
				TextFont(PoliceFForumID);
				TextFace(normal);
				TextSize(haut);
				fontsize := haut;
				GetFontInfo(InfosPolice);

				fontsize := haut;
				TextSize(fontsize);
				GetFontInfo(InfosPolice);
				centragevertical := (tailleCaseFFORUM - Min(fontsize, InfosPolice.ascent - InfosPolice.leading) + 1) div 2;

				a := TaillecaseFFORUM;
				b := TaillecaseFFORUM;
				SetRect(unRect, a - TaillecaseFFORUM + 1, b - TaillecaseFFORUM + 1, a, b);
				if odd(numero) then
					begin
						FillOval(unRect, blackPattern);

						TextMode(3);
						if(PoliceFForumID = 0) and (haut >= 12) then
							TextFace(normal)        {Chicago est deja assez large}
						else
							TextFace(bold);
					  if numero >= 100 then TextFace(condense);

						if (numero >= 10) and (numero <= 99) then
							begin
								str := IntToStr(platMod10[numero]);
								str1 := IntToStr(platDiv10[numero]);
								larg := MyStringWidth(str);
								larg1 := MyStringWidth(str1);
								y := b - centragevertical;
								x := a -(TaillecaseFFORUM + larg + larg1) div 2 + 1;
								Moveto(x, y);
								MyDrawString(str1);
								x := a -(TaillecaseFFORUM - larg1 + larg) div 2;
								Moveto(x, y);
								MyDrawString(str);
							end
						else
							begin
								str := IntToStr(numero);
								y := b - centragevertical;
								x := a -(TaillecaseFFORUM + MyStringWidth(str) - 1) div 2;
								Moveto(x, y);
								MyDrawString(str);
							end;
					end
				else if not(odd(numero)) then
					begin
						ForeColor(whiteColor);
						FillOval(unRect, blackPattern);
						ForeColor(BlackColor);
						FrameOval(unRect);
						TextMode(1);
						if numero >= 100
						  then TextFace(condense)
						  else TextFace(normal);

						if (numero >= 10) and (numero <= 99) then
							begin
								str := IntToStr(platMod10[numero]);
								str1 := IntToStr(platDiv10[numero]);
								larg := MyStringWidth(str);
								larg1 := MyStringWidth(str1);
								y := b - centragevertical;
								x := a -(TaillecaseFFORUM + larg + larg1 - 1) div 2;
								Moveto(x, y);
								MyDrawString(str1);
								x := a -(TaillecaseFFORUM - larg1 + larg + 1) div 2;
								Moveto(x, y);
								MyDrawString(str);
							end
						else
							begin
								str := IntToStr(numero);
								y := b - centragevertical;
								x := a - (TaillecaseFFORUM + MyStringWidth(str) - 1) div 2;
								Moveto(x, y);
								MyDrawString(str);
							end;
					end;

			end;
	  DisableQuartzAntiAliasingThisPort(qdThePort);
	end;


begin
	inc(numeroPuce);

	GetPenState(oldPen);
	oldClipRgn := NewRgn;
	GetClip(oldClipRgn);
	SetRect(saisie, 0, 0, ParamDiagCourant.TaillecaseFFORUM, ParamDiagCourant.TaillecaseFFORUM);
	ClipRect(saisie);
	PucePicture := OpenPicture(saisie);
	ConstruitPuce(numeroPuce);
	ClosePicture;
	SetClip(oldclipRgn);
	DisposeRgn(oldclipRgn);

	aux := MyZeroScrap;
	aux := CopierPICTDansPressePapier(PucePicture);

	KillPicture(PucePicture);
	SetPenState(oldPen);
end;


procedure DessineExamplePictureDiagFFORUM(dp : DialogPtr; const chainePositionInitiale,chainePosition,chaineCoups : String255);
  const kPositionVerticaleExemple = 120;
        kPositionHorizontaleExemple = 244;
	var
		OthellierPicture : PicHandle;
		unRect, unrectDiag: rect;
		oldClipRgn : RgnHandle;
		oldDecH, oldDecV : SInt16;
		zoneGrisee : rect;
begin
  DisableQuartzAntiAliasingThisPort(qdThePort);
  DisableQuartzAntiAliasingThisPort(GetDialogPort(dp));

	oldDecH := ParamDiagCourant.decalageHorFFORUM;
	oldDecV := ParamDiagCourant.decalageVertFFORUM;
	ParamDiagCourant.decalageHorFFORUM := 0;
	ParamDiagCourant.decalageVertFFORUM := 0;
	oldClipRgn := NewRgn;
	GetClip(oldClipRgn);
	ClipRect(QDGetPortBound);
	SetRect(unrectDiag, 0, 0, LargeurDiagrammeFFORUM, HauteurDiagrammeFFORUM);

	{

	}

	OthellierPicture := OpenPicture(unrectDiag);
	DisableQuartzAntiAliasingThisPort(qdThePort);
	DisableQuartzAntiAliasingThisPort(GetDialogPort(dp));

	case ParamDiagCourant.typeDiagrammeFFORUM of
		DiagrammePartie:
			ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
		DiagrammePosition:
			ConstruitPositionPicture(chainePosition,chaineCoups);
		DiagrammePourListe:
			ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
	end;
	if ParamDiagCourant.DessinePierresDeltaFFORUM then
		ConstruitPicturePionsDeltaCourants;

  PrintEpilogueForEPSFile;

	ClosePicture;
	SetClip(oldclipRgn);
	DisposeRgn(oldclipRgn);


  SetRect(unRect, kPositionHorizontaleExemple, kPositionVerticaleExemple, QDGetPortBound.right+2, QDGetPortBound.bottom+2);
	MyEraseRect(unRect);
	MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');

	SetRect(zoneGrisee, kPositionHorizontaleExemple, kPositionVerticaleExemple, QDGetPortBound.right-5, QDGetPortBound.bottom-5);
	if DrawThemeWindowListViewHeader(zoneGrisee,kThemeStateActive) = NoErr then DoNothing;
	FrameRoundRect(zoneGrisee,0,0);


	unRect := GetPicFrameOfPicture(OthellierPicture);
	unRect := CenterRectInRect(unRect,zoneGrisee);
	if unRect.left < zoneGrisee.left then OffSetRect(unRect, zoneGrisee.left - unRect.left, 0);
	if unRect.top  < zoneGrisee.top then OffSetRect(unRect, 0, zoneGrisee.top - unRect.top);

	SetOrigin(-unRect.left, -unRect.top);
	unRect := GetPicFrameOfPicture(OthellierPicture);
	DisableQuartzAntiAliasing;
	DrawPicture(OthellierPicture, unRect);
	EnableQuartzAntiAliasing(true);
	KillPicture(OthellierPicture);
	SetOrigin(0, 0);
	ParamDiagCourant.decalageHorFFORUM := oldDecH;
	ParamDiagCourant.decalageVertFFORUM := oldDecV;
	TextSize(0);
	TextFont(systemFont);
	TextFace(normal);

	EnableQuartzAntiAliasingThisPort(NIL,true);
end;

function FiltreDialogueDiagramme(dlog : DialogPtr; var evt: eventrecord; var item : SInt16) : boolean;
begin
	FiltreDialogueDiagramme := false;
	if not(EvenementDuDialogue(dlog, evt)) then
		FiltreDialogueDiagramme := MyFiltreClassiqueRapide(dlog, evt, item)
	else
		case evt.what of
			updateEvt:
				begin
					item := VirtualUpdateItemInDialog;
					FiltreDialogueDiagramme := true;
				end;
			otherwise
				FiltreDialogueDiagramme := MyFiltreClassiqueRapide(dlog, evt, item);
		end;  {case}
end;


function DoDiagrammeFFORUM(ParametreTexte: String255; const chainePositionInitiale,chainePosition,chaineCoups : String255) : boolean;
	const
		PosiFFORUMDialogID = 146;
		DiagFFORUMDialogID = 147;
		ListFFORUMDialogID = 148;
		MenuFlottantPoliceID = 3000;
		MenuFlottantFondID = 3002;
		MenuFlottantIntensiteID = 3003;

		OK = 1;
		Annuler = 2;
		StyleAnglaisBouton = 3;
		ValeursStandardBouton = 4;
		LargeurText = 6;
		EpaisseurBordureText = 8;
		PoliceStaticText = 9;
		PoliceUserItemPopUp = 10;
		TitreRadio = 11;
		TitreText = 12;
		NomsJoueursBox = 11;
		NomTournoiBox = 12;
		TitreDuDialogueStatic = 13;
		ExempleStaticText = 14;
		CoordonneesBox = 16;
		CoinsDuCarreBox = 17;
		Pions1PixelBox = 18;
		PixelEnDedansText = 19;
		PixelEnDedansStatic = 20;
		TraitsFinsBox = 21;
		NumerosSeulementBox = 22;
		EcritureApresRadio = 22;
		FondStaticText = 24;
		FondUserItemPopUp = 25;
		DistanceBordureStatic = 26;
		DistanceBordureText = 27;
		IntensiteStaticText = 28;
		IntensiteUserItemPopUp = 29;
		PierresDeltaBox = 30;

	var
		dp : DialogPtr;
		itemHit : SInt16;
		itemrect : rect;
		FiltreDialogueDiagrammeUPP : modalFilterUPP;
		err : OSErr;
		myFontID : SInt32;

		tailleCaseArrivee : SInt16;
		epaisseurCadreArrivee : double;
		distanceCadreArrivee : SInt16;
		CoordonneesArrivee : boolean;
		TraitsFinsArrivee : boolean;
		NumerosSeulementArrivee : boolean;
		nbPixelDedansArrivee : SInt16;
		PionsEnDedansArrivee : boolean;
		DessineCoinsDuCarreArrivee : boolean;
		DessinePierresDeltaArrivee : boolean;
		EcritApres37c7Arrivee : boolean;
		EcritNomsJoueursArrivee : boolean;
		EcritNomTournoiArrivee : boolean;
		PoliceArrivee : SInt16;
		titreArrivee : String255;
		CommentPositionArrivee : String255;
		FondOthellierArrivee : SInt16;
		CouleurOthellierArrivee : SInt16;
		CouleurRGBOthellierArrivee : RGBColor;

		tailleCaseDessinee : SInt16;
		epaisseurCadreDessinee : double;
		distanceCadreDessinee : SInt16;
		CoordonneesDessinee : boolean;
		TraitsFinsDessinee : boolean;
		NumerosSeulementDessinee : boolean;
		PionsEnDedansDessinee : boolean;
		nbPixelDedansDessinee : SInt16;
		DessineCoinsDuCarreDessinee : boolean;
		DessinePierresDeltaDessinee : boolean;
		EcritApres37c7Dessinee : boolean;
		EcritNomsJoueursDessinee : boolean;
		EcritNomTournoiDessinee : boolean;
		PoliceDessinee : SInt16;
		TitreDessinee : String255;
		CommentPositionDessinee : String255;
		FondOthellierDessinee : SInt16;
		couleurOthellierDessinee : SInt16;

		menuFlottantPolice : MenuRef;
		menuPoliceRect : rect;
		itemMenuPolice : SInt16;
		menuFlottantFond : MenuRef;
		menuFondRect : rect;
		itemMenuFond : SInt16;
		menuFlottantIntensite : MenuRef;
		menuIntensiteRect : rect;
		itemMenuIntensite : SInt16;

		s, s1, s2 : String255;
		scoreFinalDejaAfficheDansDialogue: boolean;

procedure SauveValeursArrivee;
	begin
		with ParamDiagCourant do
			begin
				tailleCaseArrivee := tailleCaseFFORUM;
				epaisseurCadreArrivee := epaisseurCadreFFORUM;
				distanceCadreArrivee := distanceCadreFFORUM;
				PionsEnDedansArrivee := PionsEnDedansFFORUM;
				nbPixelDedansArrivee := nbPixelDedansFFORUM;
				DessineCoinsDuCarreArrivee := DessineCoinsDuCarreFFORUM;
				DessinePierresDeltaArrivee := DessinePierresDeltaFFORUM;
				EcritApres37c7Arrivee := EcritApres37c7FFORUM;
				EcritNomsJoueursArrivee := EcritNomsJoueursFFORUM;
				EcritNomTournoiArrivee := EcritNomTournoiFFORUM;
				PoliceArrivee := PoliceFForumID;
				CoordonneesArrivee := CoordonneesFFORUM;
				TraitsFinsArrivee := TraitsFinsFFORUM;
				NumerosSeulementArrivee := NumerosSeulementFFORUM;
				CommentPositionArrivee := CommentPositionFFORUM^^;
				TitreArrivee := titreFFORUM^^;
				FondOthellierArrivee := FondOthellierPatternFFORUM;
				CouleurOthellierArrivee := couleurOthellierFFORUM;
				CouleurRGBOthellierArrivee := CouleurRGBOthellierFFORUM;

				tailleCaseDessinee := tailleCaseFFORUM;
				epaisseurCadreDessinee := 0;
				distanceCadreDessinee := 0;
				PionsEnDedansDessinee := false;
				nbPixelDedansDessinee := 0;
				DessineCoinsDuCarreDessinee := false;
				DessinePierresDeltaDessinee := false;
				EcritApres37c7Dessinee := false;
				EcritNomsJoueursDessinee := false;
				EcritNomTournoiDessinee := false;
				PoliceDessinee := 0;
				Coordonneesdessinee := false;
				TraitsFinsdessinee := false;
				NumerosSeulementdessinee := false;
				CommentPositiondessinee := '';
				TitreDessinee := '';
				FondOthellierDessinee := kWhitePattern;
				couleurOthellierDessinee := BlackColor;

			end;
	end;

procedure RemetValeursArrivee;
	begin
		with ParamDiagCourant do
			begin
				tailleCaseFFORUM := tailleCaseArrivee;
				epaisseurCadreFFORUM := epaisseurCadreArrivee;
				distanceCadreFFORUM := distanceCadreArrivee;
				PionsEnDedansFFORUM := PionsEnDedansArrivee;
				nbPixelDedansFFORUM := nbPixelDedansArrivee;
				DessineCoinsDuCarreFFORUM := DessineCoinsDuCarreArrivee;
				DessinePierresDeltaFFORUM := DessinePierresDeltaArrivee;
				EcritApres37c7FFORUM := EcritApres37c7Arrivee;
				EcritNomsJoueursFFORUM := EcritNomsJoueursArrivee;
				EcritNomTournoiFFORUM := EcritNomTournoiArrivee;
				PoliceFForumID := PoliceArrivee;
				CoordonneesFFORUM := CoordonneesArrivee;
				TraitsFinsFFORUM := TraitsFinsArrivee;
				NumerosSeulementFFORUM := NumerosSeulementArrivee;
				FondOthellierPatternFFORUM := FondOthellierArrivee;
				couleurOthellierFFORUM := couleurOthellierArrivee;
				CouleurRGBOthellierFFORUM := CouleurRGBOthellierArrivee;
				titreFFORUM^^ := titreArrivee;
				CommentPositionFFORUM^^ := CommentPositionArrivee;
			end;
	end;

procedure AjusteDialogue(avecRemplissageEpaisseurBordureText: boolean);
	begin
		with ParamDiagCourant do
			begin


				if tailleCaseFFORUM > 0 then
					s := IntToStr(tailleCaseFFORUM)
				else
					s := '';
				SetItemTextInDialog(dp, LargeurText, s);
				if avecRemplissageEpaisseurBordureText then
					begin
						if epaisseurCadreFFORUM > 0.0 then
							s := ReelEnString(epaisseurCadreFFORUM)
						else
							s := '';
						SetItemTextInDialog(dp, EpaisseurBordureText, s);
					end;
				if distanceCadreFFORUM > 0 then
					s := IntToStr(distanceCadreFFORUM)
				else
					s := '';
				SetItemTextInDialog(dp, distanceBordureText, s);


				case TypeDiagrammeFFORUM of
					DiagrammePartie:
						begin
							if gameOver and not(scoreFinalDejaAfficheDansDialogue) then
								begin
									GetItemTextInDialog(dp, ExempleStaticText, s);
									s1 := IntToStr(nbreDePions[pionNoir]);
									s2 := IntToStr(nbreDePions[pionBlanc]);
									s1 := s1 + CharToString('-') + s2;
									s2 := ReadStringFromRessource(TextesRapportID, 7);   {'score final ^0'}
									s := s + ' ** ' + ParamStr(s2, s1, '', '', '') + ' **';
									SetItemTextInDialog(dp, ExempleStaticText, s);
									scoreFinalDejaAfficheDansDialogue := true;
								end;
							s := titreFForum^^;
							SetItemTextInDialog(dp, TitreText, s);
							SetBoolCheckBox(dp, NumerosSeulementBox, NumerosSeulementFFORUM);
						end;
					DiagrammePosition:
						begin
							SetBoolCheckBox(dp, EcritureApresRadio, EcritApres37c7FFORUM);
							SetBoolCheckBox(dp, TitreRadio, not(EcritApres37c7FFORUM));
							GetDialogItemRect(dp, TitreRadio, itemRect);

							if EcritApres37c7FFORUM then
								PenPat(grayPattern);
							s := CommentPositionFFORUM^^;
							SetItemTextInDialog(dp, TitreText, s);
							PenPat(blackPattern);
							InsetRect(itemrect, -3, -3);
							ValidRect(itemrect);
						end;
					DiagrammePourListe:
						begin
							SetBoolCheckBox(dp, NomTournoiBox, EcritNomTournoiFFORUM);
							SetBoolCheckBox(dp, NomsJoueursBox, EcritNomsJoueursFFORUM);
							SetBoolCheckBox(dp, NumerosSeulementBox, NumerosSeulementFFORUM);
						end;
				end;  {case}

				if(nbPixelDedansFFORUM > 0) and(nbPixelDedansFFORUM < 100) then
					s := IntToStr(nbPixelDedansFFORUM)
				else
					begin
						s := '';
						nbPixelDedansFFORUM := 0;
						PionsEnDedansFFORUM := false;
					end;
				if not(PionsEnDedansFFORUM) then
					PenPat(grayPattern);
				SetItemTextInDialog(dp, PixelEnDedansText, s);
				PenPat(blackPattern);
				InsetRect(itemrect, -3, -3);
				ValidRect(itemrect);

				SetBoolCheckBox(dp, TraitsFinsBox, TraitsFinsFFORUM);
				SetBoolCheckBox(dp, Pions1PixelBox, PionsEnDedansFFORUM);
				SetBoolCheckBox(dp, CoinsDuCarreBox, DessineCoinsDuCarreFFORUM);
				SetBoolCheckBox(dp, PierresDeltaBox, DessinePierresDeltaFFORUM);
				SetBoolCheckBox(dp, CoordonneesBox, CoordonneesFFORUM);

				if not(EventAvail(keydownmask + autokeymask, theEvent)) then
					if tailleCaseFFORUM >= 8 then
						begin
							if( tailleCaseDessinee <> tailleCaseFFORUM ) or
							  ( epaisseurCadreDessinee <> epaisseurCadreFFORUM ) or
							  ( distanceCadreDessinee <> distanceCadreFFORUM ) or
							  ( PionsEnDedansDessinee <> PionsEnDedansFFORUM ) or
							  ( nbPixelDedansDessinee <> nbPixelDedansFFORUM ) or
							  ( DessineCoinsDuCarreDessinee <> DessineCoinsDuCarreFFORUM ) or
							  ( DessinePierresDeltaDessinee <> DessinePierresDeltaFFORUM ) or
							  ( EcritApres37c7Dessinee <> EcritApres37c7FFORUM ) or
							  ( EcritNomsJoueursDessinee <> EcritNomsJoueursFFORUM ) or
							  ( EcritNomTournoiDessinee <> EcritNomTournoiFFORUM ) or
							  ( PoliceDessinee <> PoliceFForumID ) or
							  ( TitreDessinee <> TitreFFORUM^^ ) or
							  ( Coordonneesdessinee <> CoordonneesFFORUM ) or
							  ( TraitsFinsdessinee <> TraitsFinsFFORUM ) or
							  ( FondOthellierDessinee <> FondOthellierPatternFFORUM ) or
							  ( CouleurOthellierDessinee <> CouleurOthellierFFORUM ) or
							  ( NumerosSeulementdessinee <> NumerosSeulementFFORUM ) or
							  ( CommentPositiondessinee <> CommentPositionFFORUM^^ ) then
							begin
								DessineExamplePictureDiagFFORUM(dp,chainePositionInitiale,chainePosition,chaineCoups);
								tailleCaseDessinee := tailleCaseFFORUM;
								epaisseurCadreDessinee := epaisseurCadreFFORUM;
								distanceCadreDessinee := distanceCadreFFORUM;
								PionsEnDedansDessinee := PionsEnDedansFFORUM;
								nbPixelDedansDessinee := nbPixelDedansFFORUM;
								DessineCoinsDuCarreDessinee := DessineCoinsDuCarreFFORUM;
								DessinePierresDeltaDessinee := DessinePierresDeltaFFORUM;
								EcritApres37c7Dessinee := EcritApres37c7FFORUM;
								EcritNomsJoueursDessinee := EcritNomsJoueursFFORUM;
								EcritNomTournoiDessinee := EcritNomTournoiFFORUM;
								PoliceDessinee := PoliceFForumID;
								TitreDessinee := TitreFFORUM^^;
								Coordonneesdessinee := CoordonneesFFORUM;
								TraitsFinsdessinee := TraitsFinsFFORUM;
								FondOthellierDessinee := FondOthellierPatternFFORUM;
								CouleurOthellierDessinee := CouleurOthellierFFORUM;
								NumerosSeulementdessinee := NumerosSeulementFFORUM;
								CommentPositiondessinee := CommentPositionFFORUM^^;
							end;
						end;
				SetPortByDialog(dp);
				DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
				DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
				DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
			end;
	end;

procedure InstalleMenuFlottantPolice;
  var k : SInt32;
	begin
		MenuFlottantPolice := NewMenu(MenuFlottantPoliceID, StringToStr255(''));
		
		{AppendResMenu(MenuFlottantPolice, MY_FOUR_CHAR_CODE('FONT'));}
		
		MyInsertMenuItem(MenuFlottantPolice,'Times',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Times New Roman',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Georgia',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Baskerville',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Gentium',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Palatino',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Optima',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Cochin',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Fontin',1000);                  // cf MenuPoliceItemToFontName
		MyInsertMenuItem(MenuFlottantPolice,'Helvetica',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Trebuchet MS',1000);
		MyInsertMenuItem(MenuFlottantPolice,'New Century Schoolbook',1000);  // cf MenuPoliceItemToFontName
		MyInsertMenuItem(MenuFlottantPolice,'Arial Rounded MT Bold',1000);
		MyInsertMenuItem(MenuFlottantPolice,'Virginie',1000);
		
		for k := 1 to MyCountMenuItems(MenuFlottantPolice) do
		    MyEnableItem(MenuFlottantPolice,k);
		
		InsertMenu(MenuFlottantPolice, -1);
		{AjouteEspacesItemsMenu(MenuFlottantPolice,2);}
	end;

procedure InstalleMenuFlottantFond;
	begin
		MenuFlottantFond := MyGetMenu(MenuFlottantFondID);
		InsertMenu(MenuFlottantFond, -1);
	end;

procedure InstalleMenuFlottantIntensite;
	begin
		MenuFlottantIntensite := MyGetMenu(MenuFlottantIntensiteID);
		InsertMenu(MenuFlottantIntensite, -1);
	end;


procedure DesinstalleMenuFlottantPolice;
	begin
		DeleteMenu(MenuFlottantPoliceID);
		TerminateMenu(MenuFlottantPolice,false);
	end;

procedure DesinstalleMenuFlottantFond;
	begin
		DeleteMenu(MenuFlottantFondID);
		TerminateMenu(MenuFlottantFond,true);
	end;

procedure DesinstalleMenuFlottantIntensite;
	begin
		DeleteMenu(MenuFlottantIntensiteID);
		TerminateMenu(MenuFlottantIntensite,true);
	end;


function MenuPoliceItemToFontName(item : SInt16) : String255;
	begin
		MyGetMenuItemText(MenuFlottantPolice, item, s);
		s := EnleveEspacesDeDroite(s);
		
		if (s = 'New Century Schoolbook') then s := 'New Century Schoolbook Roman';
		if (s = 'Fontin')                 then s := 'Fontin Regular';
		
		MenuPoliceItemToFontName := s;
	end;


function MenuPoliceItemToPoliceID(item : SInt16) : SInt16;
	begin
		s := MenuPoliceItemToFontName(item);
		MenuPoliceItemToPoliceID := GetCassioFontNum(s);
		
		// MenuPoliceItemToPoliceID := 2;
		//   avant on aurait pu utiliser New York (ID = 2),
		//   mais Apple l'a retirée en arretant l'environement Classic...
	end;


procedure MenuFondToCouleurOthellier(itemMenuFond : SInt16; var CouleurOthellierFFORUM : SInt16);
	begin
		CouleurOthellierFFORUM := itemMenuFond;
	end;

procedure MenuIntensiteToOthellierPattern(itemMenuIntensite : SInt16; var FondOthellierPatternFFORUM : SInt16);
	begin
		FondOthellierPatternFFORUM := itemMenuIntensite + 2;
	end;

procedure GetMenuPoliceItemAndRect;
		var
			i : SInt16;
	begin
		GetDialogItemRect(dp, PoliceUserItemPopUp, menuPoliceRect);
		itemMenuPolice := 1;
		for i := 1 to MyCountMenuItems(MenuFlottantPolice) do
			if MenuPoliceItemToPoliceID(i) = ParamDiagCourant.PoliceFForumID then
				itemMenuPolice := i;
		ParamDiagCourant.PoliceFForumID := MenuPoliceItemToPoliceID(itemMenuPolice);
	end;

procedure GetMenuFondItemAndRect;
	begin
		GetDialogItemRect(dp, FondUserItemPopUp, menuFondRect);
		itemMenuFond := ParamDiagCourant.CouleurOthellierFFORUM;
		if itemMenuFond < kCouleurDiagramTransparent then
			itemMenuFond := kCouleurDiagramTransparent;
		if itemMenuFond > kCouleurDiagramNoir then
			itemMenuFond := kCouleurDiagramNoir;
	end;

procedure GetMenuIntensiteItemAndRect;
	begin
		GetDialogItemRect(dp, IntensiteUserItemPopUp, menuIntensiteRect);
		itemMenuIntensite := ParamDiagCourant.FondOthellierPatternFFORUM - 2;
		if itemMenuIntensite < 1 then
			itemMenuIntensite := 1;
		if itemMenuIntensite > 4 then
			itemMenuIntensite := 4;
	end;

begin
	DoDiagrammeFFORUM := false;
	
	// This will force Cassio to copy its private fonts to ~/Library/Fonts/
  myFontID := GetCassioFontNum('aaaaaaaaaaaaabbbbbbb');

	with ParamDiagCourant do
		begin
			BeginDialog;
			SwitchToScript(gLastScriptUsedInDialogs);
			FiltreDialogueDiagrammeUPP := NewModalFilterUPP(FiltreDialogueDiagramme);
			case typeDiagrammeFFORUM of
				DiagrammePartie:
					dp := MyGetNewDialog(DiagFFORUMDialogID);
				DiagrammePosition:
					dp := MyGetNewDialog(PosiFFORUMDialogID);
				DiagrammePourListe:
					dp := MyGetNewDialog(ListFFORUMDialogID);
			end;
			if dp <> NIL then
				begin
					scoreFinalDejaAfficheDansDialogue := false;
					CenterTextInDialog(dp, ParametreTexte, TitreDuDialogueStatic);
					SauveValeursArrivee;
					InstalleMenuFlottantPolice;
					InstalleMenuFlottantFond;
					InstalleMenuFlottantIntensite;
					GetMenuPoliceItemAndRect;
					GetMenuFondItemAndRect;
					GetMenuIntensiteItemAndRect;
					ShowWindow(GetDialogWindow(dp));
					AjusteDialogue(true);
					MyDrawDialog(dp);
					DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
					DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
					DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
					if(typeDiagrammeFFORUM = DiagrammePartie) or(typeDiagrammeFFORUM = DiagrammePosition) then
						SelectDialogItemText(dp, TitreText, 0, MAXINT_16BITS);
				  SelectWindow(GetDialogWindow(dp));
					NoUpdateThisWindow(GetDialogWindow(dp));
					err := SetDialogTracksCursor(dp,true);
					repeat
						ModalDialog(FiltreDialogueDiagrammeUPP, itemHit);
						SetPortByDialog(dp);
						case itemHit of
							VirtualUpdateItemInDialog:
								begin
									BeginUpdate(GetDialogWindow(dp));
									SetPortByDialog(dp);
									MyDrawDialog(dp);
									DessineExamplePictureDiagFFORUM(dp,chainePositionInitiale,chainePosition,chaineCoups);
									DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
									DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
									DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
									OutlineOK(dp);
									EndUpdate(GetDialogWindow(dp));
								end;
							OK:
								;
							Annuler:
								;{RemetValeursArrivee}
							LargeurText:
								begin
									GetItemTextInDialog(dp, itemHit, s1);
									s := GarderSeulementLesChiffres(s1);
									SetItemTextInDialog(dp, LargeurText, s);
									if LENGTH_OF_STRING(s) > 0 then
										begin
											ChaineToLongint(s, tailleCaseFFORUM);
                    {nbPixelDedansFFORUM := TaillecaseFFORUM div 20 +1;}
										end
									else
										tailleCaseFFORUM := 0;
								end;
							EpaisseurBordureText:
								begin
									GetItemTextInDialog(dp, EpaisseurBordureText, s1);
									s := GarderSeulementLesChiffresOuLesPoints(s1);
									if(s <> '') and not(EstUnReel(s)) then
										SysBeep(0);
									SetItemTextInDialog(dp, EpaisseurBordureText, s);
									if LENGTH_OF_STRING(s) > 0 then
										epaisseurCadreFFORUM := StringSimpleEnReel(s)
									else
										epaisseurCadreFFORUM := 0.0;
									{WritelnDansRapport(ReelEnStringAvecDecimales(epaisseurCadreFFORUM, 15));}
								end;
							DistanceBordureText:
								begin
								    GetItemTextInDialog(dp, DistanceBordureText, s1);
									s := GarderSeulementLesChiffres(s1);
									SetItemTextInDialog(dp, DistanceBordureText, s);
									if LENGTH_OF_STRING(s) > 0 then
										ChaineToLongint(s, distanceCadreFFORUM)
									else
										distanceCadreFFORUM := 0;
								end;
							PixelEnDedansText:
								begin
									GetItemTextInDialog(dp, itemHit, s1);
									s := GarderSeulementLesChiffres(s1);
									if(LENGTH_OF_STRING(s) >= 2) then
										s := '';
									SetItemTextInDialog(dp, itemHit, s);
									ChaineToLongint(s, nbPixelDedansFFORUM);
									if(LENGTH_OF_STRING(s) > 0) and (nbPixelDedansFFORUM < 10) then
										begin
											PionsEnDedansFFORUM := true;
											ChaineToLongint(s, nbPixelDedansFFORUM)
										end
									else
										begin
											PionsEnDedansFFORUM := false;
											nbPixelDedansFFORUM := 0;
										end;
								end;

							ValeursStandardBouton:
								begin
									SetValeursParDefautDiagFFORUM(ParamDiagCourant, typeDiagrammeFFORUM);
									GetMenuPoliceItemAndRect;
									GetMenuFondItemAndRect;
									GetMenuIntensiteItemAndRect;
									DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
									DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
									DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
									AjusteDialogue(true);
								end;
							StyleAnglaisBouton:
								begin
									SetValeursRevueAnglaise(ParamDiagCourant, typeDiagrammeFFORUM);
									GetMenuPoliceItemAndRect;
									GetMenuFondItemAndRect;
									GetMenuIntensiteItemAndRect;
									DrawPUItem(MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true);
									DrawPUItem(MenuFlottantFond, itemMenuFond, menuFondRect, true);
									DrawPUItem(MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true);
									AjusteDialogue(true);
								end;
							Pions1PixelBox, PixelEnDedansStatic:
								begin
									PionsEnDedansFFORUM := not(PionsEnDedansFFORUM);
									if nbPixelDedansFFORUM <= 0 then
										nbPixelDedansFFORUM := 1;
                                      {if PionsEnDedansFFORUM then SelectDialogItemText(dp,PixelEnDedansText,0,MAXINT_16BITS);}
								end;
							CoinsDuCarreBox:
								DessineCoinsDuCarreFFORUM := not(DessineCoinsDuCarreFFORUM);
							PierresDeltaBox:
								DessinePierresDeltaFFORUM := not(DessinePierresDeltaFFORUM);
							CoordonneesBox:
								CoordonneesFFORUM := not(CoordonneesFFORUM);
							TraitsFinsBox:
								TraitsFinsFFORUM := not(TraitsFinsFFORUM);
							EcritureApresRadio:
								case typeDiagrammeFFORUM of
									DiagrammePartie:
										numerosSeulementFFORUM := not(numerosSeulementFFORUM);
									DiagrammePosition:
										EcritApres37c7FFORUM := true;
									DiagrammePourListe:
										numerosSeulementFFORUM := not(numerosSeulementFFORUM);
								end;
							titreRadio
          { = NomsJoueursBox }
							:
								case typeDiagrammeFFORUM of
									DiagrammePosition:
										begin
											EcritApres37c7FFORUM := false;
											SelectDialogItemText(dp, TitreText, 0, MAXINT_16BITS);
										end;
									DiagrammePourListe:
										EcritNomsJoueursFFORUM := not(EcritNomsJoueursFFORUM);
								end;
							TitreText
          { = NomTournoiBox }
							:
								begin
									case typeDiagrammeFFORUM of
										DiagrammePartie:
											begin
												GetItemTextInDialog(dp, itemHit, s);
												titreFFORUM^^ := s;
											end;
										DiagrammePosition:
											begin
												GetItemTextInDialog(dp, itemHit, s);
												commentPositionFFORUM^^ := s;
												EcritApres37c7FFORUM := false;
											end;
										DiagrammePourListe:
											EcritNomTournoiFFORUM := not(EcritNomTournoiFFORUM);
									end; {case}
								end;
							PoliceUserItemPopUp :
								begin
									if EventPopUpItemInDialog(dp, PoliceStaticText, MenuFlottantPolice, itemMenuPolice, menuPoliceRect, true, true)
									  then PoliceFFORUMID := MenuPoliceItemToPoliceID(itemMenuPolice);
								end;
							FondUserItemPopUp :
								begin
									if EventPopUpItemInDialog(dp, FondStaticText, MenuFlottantFond, itemMenuFond, menuFondRect, true, true)
									   then MenuFondToCouleurOthellier(itemMenuFond, CouleurOthellierFFORUM);
								end;
							IntensiteUserItemPopUp :
								begin
									if EventPopUpItemInDialog(dp, IntensiteStaticText, MenuFlottantIntensite, itemMenuIntensite, menuIntensiteRect, true, true)
									   then MenuIntensiteToOthellierPattern(itemMenuIntensite, FondOthellierPatternFFORUM);
								end;

						end; {case}
						if(itemHit <> OK) and(itemHit <> Annuler) and(itemHit <> VirtualUpdateItemInDialog) then
							AjusteDialogue(false);
						SetPortByDialog(dp);
					until(itemHit = OK) or (itemHit = Annuler);
					DoDiagrammeFFORUM := (itemHit <> Annuler);
					DesinstalleMenuFlottantPolice;
					DesinstalleMenuFlottantFond;
					DesinstalleMenuFlottantIntensite;
					MyDisposeDialog(dp);
					if itemHit = annuler then
						RemetValeursArrivee;
				end;
			MyDisposeModalFilterUPP(FiltreDialogueDiagrammeUPP);
			GetCurrentScript(gLastScriptUsedInDialogs);
      SwitchToRomanScript;
			EndDialog;
		end;
end;


procedure SetTailleOthelloPourDiagrammeFForum(nbCasesH,nbCasesV : SInt16);
begin
  tailleVersionOthello.h := nbCasesH;
  tailleVersionOthello.v := nbCasesV;
end;

procedure GetTailleOthelloPourDiagrammeFforum(var nbCasesH,nbCasesV : SInt16);
begin
nbCasesH := tailleVersionOthello.h;
nbCasesV := tailleVersionOthello.v;
end;

end.
