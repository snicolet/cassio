UNIT UnitFichierPhotos;



INTERFACE







 USES UnitDefCassio;








procedure InitUnitFichierPhotos;
procedure LibereMemoireUnitFichierPhotos;

function FichierPhotosExisteSurLeDisque(pathCompletFichierPhoto : String255; var fic : FichierTEXT) : boolean;
function FichierPhotosExisteEnMemoire(pathComplet : String255; var numeroFic : SInt16) : boolean;
function FichierPhotosExisteDansMenu(nomFichierDansMenu : String255; var numeroFic : SInt16) : boolean;
function FichierPhotosHappyEndExistePourCesTextureEtCouleur(nomFichierDansMenu : String255; couleur : SInt16; var numeroFic : SInt16) : boolean;



function GetPathCompletFichierPionsPourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
function GetPathCompletFichierBordurePourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
function GetNomDansMenuPourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
function LitFichierCoordoneesImages3D(var quelleTexture : CouleurOthellierRec) : OSErr;

function GetPathCompletDossierOthelliersDeCassio : String255;
function GetPathCompletFichierParNumero(numeroFic : SInt16) : String255;
function GetNomDansMenuParNumero(numeroFic : SInt16) : String255;


function PathFichierPicture3DDeCetteFamille(nomFichierDansMenu : String255; coul : SInt16) : String255;
function PathFichierPictureHappyEndDeCetteFamille(nomFichierDansMenu : String255; coul : SInt16) : String255;


procedure AlerteFichierPhotosNonTrouve(nomFichier : String255);

procedure AjouterFichierOthellierPicture(fs : FSSpec; typeFichierGraphique : SInt16);
procedure LecturePreparatoireDossierOthelliers(pathDuDossierPere : String255);

procedure TestUnitFichierPhotos;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Aliases
{$IFC NOT(USE_PRELINK)}
    , MyFileSystemUtils, UnitRapport, UnitTroisiemeDimension, UnitGeometrie, Unit3DPovRayPicts, UnitCarbonisation, MyStrings
    , UnitMenus, UnitDialog, UnitScannerUtils, UnitFenetres, UnitServicesMemoire, UnitServicesDialogs, SNMenus, UnitFichiersTEXT
    , UnitCalculCouleurCassio, UnitEnvirons ;
{$ELSEC}
    ;
    {$I prelink/FichierPhotos.lk}
{$ENDC}


{END_USE_CLAUSE}








procedure InitUnitFichierPhotos;
var i : SInt16;
begin
  with gFichiersPicture do
    begin
      nbFichiers := 0;
      for i := 0 to kMaxFichiersOthelliers do
        with fic[i] do
		      begin
		        typeFichier   := kFichierPictureInconnu;
		        whichMenuID   := 0;
		        whichMenuItem := 0;
		        couleurPions  := kAucuneEnParticulier;
		        nomComplet  := NIL;
		        nomDansMenu := NIL;
		      end;
		end;
end;


procedure LibereMemoireUnitFichierPhotos;
var i : SInt16;
begin
  with gFichiersPicture do
    begin
      nbFichiers := 0;
		  for i := 0 to kMaxFichiersOthelliers do
		    with fic[i] do
		      begin
		        typeFichier := kFichierPictureInconnu;
		        whichMenuID := 0;
		        whichMenuItem := 0;
		        couleurPions  := kAucuneEnParticulier;
		        if nomComplet <> NIL then
		          begin
		            DisposeMemoryPtr(Ptr(nomComplet));
		            nomComplet := NIL;
		          end;
		        if nomDansMenu <> NIL then
		          begin
		            DisposeMemoryPtr(Ptr(nomDansMenu));
		            nomDansMenu := NIL;
		          end;
		      end;
		end;
end;


function FichierPhotosExisteSurLeDisque(pathCompletFichierPhoto : String255; var fic : FichierTEXT) : boolean;
var err : OSErr;
begin
  if pathCompletFichierPhoto = '' then
    begin
      FichierPhotosExisteSurLeDisque := false;
      exit;
    end;

  err := FichierTexteExiste(pathCompletFichierPhoto,0,fic);
  FichierPhotosExisteSurLeDisque := (err = NoErr);
end;


function FichierPhotosExisteEnMemoire(pathComplet : String255; var numeroFic : SInt16) : boolean;
var i : SInt16;
begin
  FichierPhotosExisteEnMemoire := false;
  numeroFic := 0;

  if (pathComplet <> '') and
     (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       if (gFichiersPicture.fic[i].nomComplet <> NIL) and
          (pathComplet = gFichiersPicture.fic[i].nomComplet^) then
         begin
           FichierPhotosExisteEnMemoire := true;
           numeroFic := i;
           exit;
         end;
end;


function FichierPhotosExisteDansMenu(nomFichierDansMenu : String255; var numeroFic : SInt16) : boolean;
var i : SInt16;
begin
  FichierPhotosExisteDansMenu := false;
  numeroFic := 0;

  if (nomFichierDansMenu <> '') and
     (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       if (gFichiersPicture.fic[i].nomDansMenu <> NIL) and
          (nomFichierDansMenu = gFichiersPicture.fic[i].nomDansMenu^) then
         begin
           FichierPhotosExisteDansMenu := true;
           numeroFic := i;
           exit;
         end;
end;


function FichierPhotosHappyEndExistePourCesTextureEtCouleur(nomFichierDansMenu : String255; couleur : SInt16; var numeroFic : SInt16) : boolean;
var i : SInt16;
begin
  FichierPhotosHappyEndExistePourCesTextureEtCouleur := false;
  numeroFic := 0;

  if (nomFichierDansMenu <> '') and
     (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       if (gFichiersPicture.fic[i].nomDansMenu <> NIL) and
          (nomFichierDansMenu = gFichiersPicture.fic[i].nomDansMenu^) and
          (gFichiersPicture.fic[i].typeFichier = kFichierPictureHappyEnd) and
          (gFichiersPicture.fic[i].whichMenuID = Picture2DID) and
          (gFichiersPicture.fic[i].couleurPions = couleur) then
         begin
           FichierPhotosHappyEndExistePourCesTextureEtCouleur := true;
           numeroFic := i;
           exit;
         end;
end;


function GetPathCompletFichierPionsPourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
var i : SInt16;
begin
  GetPathCompletFichierPionsPourCetteTexture := '';  {defaut, par exemple pour une couleur simple}

  {on cherche dans tous les fichiers de texture celui qui a les menuID et menuItem de la whichTexture}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (whichMenuID = whichTexture.menuID) and
	          (whichMenuItem = whichTexture.menuCmd) and
	          (nomComplet <> NIL) and
	          (nomComplet^ <> '') then
	         begin
	           GetPathCompletFichierPionsPourCetteTexture := nomComplet^;
	           exit;
	         end;
end;


function GetPathCompletFichierBordurePourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
var i : SInt16;
begin  {$UNUSED whichTexture}
  GetPathCompletFichierBordurePourCetteTexture := '';  {defaut, par exemple pour une couleur simple}

  {on cherche le premier de tous les fichiers de bordure}
  {TODO : on devrait plutot pouvoir associer une bordure à une texture d'othellier, non ?}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (typeFichier = kFichierBordure) and
	          (nomComplet <> NIL) and
	          (nomComplet^ <> '') then
	         begin
	           GetPathCompletFichierBordurePourCetteTexture := nomComplet^;
	           exit;
	         end;
end;


function GetNomDansMenuPourCetteTexture(var whichTexture : CouleurOthellierRec) : String255;
var i : SInt16;
begin
  GetNomDansMenuPourCetteTexture := '';  {defaut, par exemple pour une couleur simple}

  {on cherche dans tous les fichiers de texture celui qui a les menuID et menuItem de la whichTexture}
  if (gFichiersPicture.nbFichiers > 0) then
     for i := 1 to gFichiersPicture.nbFichiers do
       with gFichiersPicture.fic[i] do
	       if (whichMenuID = whichTexture.menuID) and
	          (whichMenuItem = whichTexture.menuCmd) and
	          (nomDansMenu <> NIL) and
	          (nomDansMenu^ <> '') then
	         begin
	           GetNomDansMenuPourCetteTexture := nomDansMenu^;
	           exit;
	         end;
end;


function GetPathCompletDossierOthelliersDeCassio : String255;
begin
  GetPathCompletDossierOthelliersDeCassio := pathDossierOthelliersCassio;
end;



function GetPathCompletFichierParNumero(numeroFic : SInt16) : String255;
begin
  if (numeroFic >= 1) and (numeroFic <= gFichiersPicture.nbFichiers) and
     (gFichiersPicture.fic[numeroFic].nomComplet <> NIL)
    then GetPathCompletFichierParNumero := gFichiersPicture.fic[numeroFic].nomComplet^
    else GetPathCompletFichierParNumero := '';
end;



function GetNomDansMenuParNumero(numeroFic : SInt16) : String255;
begin
  if (numeroFic >= 1) and (numeroFic <= gFichiersPicture.nbFichiers) and
     (gFichiersPicture.fic[numeroFic].nomDansMenu <> NIL)
    then GetNomDansMenuParNumero := gFichiersPicture.fic[numeroFic].nomDansMenu^
    else GetNomDansMenuParNumero := '';
end;




function PathFichierPicture3DDeCetteFamille(nomFichierDansMenu : String255; coul : SInt16) : String255;
var k : SInt16;
begin
  PathFichierPicture3DDeCetteFamille := '';

  for k := 1 to gFichiersPicture.nbFichiers do
    with gFichiersPicture.fic[k] do
     if (couleurPions = coul) and
        (typeFichier = kFichierPicture3D) and (whichMenuID = Picture3DID) and
        (nomDansMenu <> NIL) and (nomDansMenu^ = nomFichierDansMenu) and
        (nomComplet <> NIL)
       then
         begin
           PathFichierPicture3DDeCetteFamille := nomComplet^;
           exit;
         end;
end;


function PathFichierPictureHappyEndDeCetteFamille(nomFichierDansMenu : String255; coul : SInt16) : String255;
var k : SInt16;
begin
  PathFichierPictureHappyEndDeCetteFamille := '';

  for k := 1 to gFichiersPicture.nbFichiers do
    with gFichiersPicture.fic[k] do
     if (couleurPions = coul) and
        (typeFichier = kFichierPictureHappyEnd) and (whichMenuID = Picture2DID) and
        (nomDansMenu <> NIL) and (nomDansMenu^ = nomFichierDansMenu) and
        (nomComplet <> NIL)
       then
         begin
           PathFichierPictureHappyEndDeCetteFamille := nomComplet^;
           exit;
         end;
end;




procedure AlerteFichierPhotosNonTrouve(nomFichier : String255);
const OK = 1;
      FichierPhotoNonTrouveID = 154;
var URL : String255;
begin
  URL := '<http://cassio.free.fr>';

  WritelnDansRapport('');
  WritelnDansRapport(URL);
  WritelnDansRapport('');

  MyParamText(URL,nomFichier,'','');
  AlertOneButtonFromRessource(FichierPhotoNonTrouveID,3,4,OK);

end;


function TransformeNomFichierPicture2D(ancienNom : String255) : String255;
var s : String255;
begin
  ancienNom := ReplaceStringOnce('photos Cassio',' ',ancienNom);
  ancienNom := ReplaceStringOnce('Photos Cassio',' ',ancienNom);

  repeat
    s := ancienNom;
    ancienNom := ReplaceStringOnce('alias',' ',ancienNom);
    ancienNom := ReplaceStringOnce('(',' ',ancienNom);
    ancienNom := ReplaceStringOnce(')',' ',ancienNom);
    ancienNom := ReplaceStringOnce('-',' ',ancienNom);
    ancienNom := ReplaceStringOnce('[',' ',ancienNom);
    ancienNom := ReplaceStringOnce(']',' ',ancienNom);
    EnleveEspacesDeGaucheSurPlace(ancienNom);
    EnleveEspacesDeDroiteSurPlace(ancienNom);
    if ancienNom = '' then ancienNom := 'Photos';
  until (s = ancienNom);

  TransformeNomFichierPicture2D := ancienNom;
end;


function TransformeNomFichierPicture3D(ancienNom : String255) : String255;
var s : String255;
begin

  repeat
    s := ancienNom;
    ancienNom := ReplaceStringOnce('.pict'       ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('[rect].txt'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('[rects].txt' ,' '  ,ancienNom);

    ancienNom := ReplaceStringOnce('Noirs'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('noirs'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Noir'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('noir'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Vides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('vides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Vide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('vide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Legaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('legaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Légaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('légaux' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Aides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('aides'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Aide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('aide'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Blancs' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('blancs' ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Blanc'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('blanc'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Black'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('black'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('White'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('white'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Empty'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('empty'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Legal'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('legal'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Hints'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('hints'  ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('Hint'   ,' '  ,ancienNom);
    ancienNom := ReplaceStringOnce('hint'   ,' '  ,ancienNom);

    ancienNom := ReplaceStringOnce('alias'  ,' '  ,ancienNom);

    ancienNom := ReplaceStringOnce('(',' ',ancienNom);
    ancienNom := ReplaceStringOnce(')',' ',ancienNom);
    ancienNom := ReplaceStringOnce('-',' ',ancienNom);
    ancienNom := ReplaceStringOnce('[',' ',ancienNom);
    ancienNom := ReplaceStringOnce(']',' ',ancienNom);
    EnleveEspacesDeGaucheSurPlace(ancienNom);
    EnleveEspacesDeDroiteSurPlace(ancienNom);
    if ancienNom = '' then ancienNom := 'Standard';
  until (s = ancienNom);

  TransformeNomFichierPicture3D := ancienNom;
end;


function TransformeNomFichierPictureHappyEnd(ancienNom : String255) : String255;
var path : String255;
    a : SInt32;
    HappyEndName : String255;
begin
  path := ancienNom;


  HappyEndName := 'Happy End';

  a := Pos(HappyEndName,path);
  if (a > 0) then path := RightOfString(path, LENGTH_OF_STRING(path) - a - LENGTH_OF_STRING(HappyEndName));

  path := ReplaceStringOnce('.jpg'       ,' '  ,path);
  path := ReplaceStringOnce('Home made'       ,' '  ,path);
  path := ReplaceStringOnce('home made'       ,' '  ,path);
  path := ReplaceStringOnce(':'       ,' '  ,path);
  path := ReplaceStringOnce('('       ,' '  ,path);
  path := ReplaceStringOnce(')'       ,' '  ,path);
  path := ReplaceStringOnce('-'       ,' '  ,path);
  path := ReplaceStringOnce('{'       ,' '  ,path);
  path := ReplaceStringOnce('}'       ,' '  ,path);
  path := ReplaceStringOnce('Black'  ,' '  ,path);
  path := ReplaceStringOnce('black'  ,' '  ,path);
  path := ReplaceStringOnce('White' ,' '  ,path);
  path := ReplaceStringOnce('white' ,' '  ,path);
  path := ReplaceStringOnce('Empty'  ,' '  ,path);
  path := ReplaceStringOnce('empty'  ,' '  ,path);
  path := ReplaceStringOnce('Legal' ,' '  ,path);
  path := ReplaceStringOnce('legal' ,' '  ,path);
  path := ReplaceStringOnce('Hint' ,' '  ,path);
  path := ReplaceStringOnce('hint' ,' '  ,path);

  EnleveEspacesDeGaucheSurPlace(path);
  EnleveEspacesDeDroiteSurPlace(path);

  TransformeNomFichierPictureHappyEnd := path;
end;



function CouleurPionsImage3D(path : String255) : SInt16;
begin
  CouleurPionsImage3D := kAucuneEnParticulier;

  path := UpperCase(path,false);
  if (Pos('[NOIRS]',path) > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[NOIR]',path)  > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[BLANCS]',path) > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[BLANC]',path) > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[VIDES]',path) > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[VIDE]',path)  > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[LEGAUX]',path) > 0) then CouleurPionsImage3D := kImageCoupsLegaux    else
  if (Pos('[AIDE]',path)  > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[AIDES]',path) > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[BLACK]',path) > 0) then CouleurPionsImage3D := kImagePionsNoirs     else
  if (Pos('[WHITE]',path) > 0) then CouleurPionsImage3D := kImagePionsBlancs    else
  if (Pos('[EMPTY]',path) > 0) then CouleurPionsImage3D := kImagePionsVides     else
  if (Pos('[LEGAL]',path) > 0) then CouleurPionsImage3D := kImageCoupsLegaux    else
  if (Pos('[HINT]',path)  > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[HINTS]',path) > 0) then CouleurPionsImage3D := kImagePionSuggestion else
  if (Pos('[COOR]',path)  > 0) then CouleurPionsImage3D := kFichierCoordonees   else
  if (Pos('[RECT]',path)  > 0) then CouleurPionsImage3D := kFichierCoordonees   else
  if (Pos('[RECTS]',path) > 0) then CouleurPionsImage3D := kFichierCoordonees   else
  if (Pos('BLACK.JPG',path) > 0) then CouleurPionsImage3D := kImagePionsNoirs   else
  if (Pos('WHITE.JPG',path) > 0) then CouleurPionsImage3D := kImagePionsBlancs   else
  if (Pos('EMPTY.JPG',path) > 0) then CouleurPionsImage3D := kImagePionsVides    else
  if (Pos('LEGAL.JPG',path) > 0) then CouleurPionsImage3D := kImageCoupsLegaux   else
  if (Pos('HINT.JPG',path) > 0) then CouleurPionsImage3D := kImagePionSuggestion
  ;

end;



procedure AjouterFichierOthellierPicture(fs : FSSpec; typeFichierGraphique : SInt16);
var codeErreur : OSErr;
    path : String255;
    textePourMenu : String255;
    dejaDansListe,dejaDansMenu : boolean;
    nbItemsDansMenu,num : SInt16;
begin
   with gFichiersPicture do
	    begin
	      codeErreur := FSSpecToFullPath(fs,path);

	      if (GetNameOfFSSpec(fs)[1] <> '.') and
	         (Pos('escr.txt',path) = 0) and (Pos('Borders',path) = 0) then
	        begin

			      case typeFichierGraphique of
			        kFichierPicture2D       : textePourMenu := TransformeNomFichierPicture2D(GetNameOfFSSpec(fs));
			        kFichierPicture3D       : textePourMenu := TransformeNomFichierPicture3D(GetNameOfFSSpec(fs));
			        kFichierPictureHappyEnd : textePourMenu := TransformeNomFichierPictureHappyEnd(path);
			        kFichierBordure         : textePourMenu := GetNameOfFSSpec(fs);
			        kFichierPictureMeteo    : textePourMenu := GetNameOfFSSpec(fs);
			        otherwise                 textePourMenu := GetNameOfFSSpec(fs);
			      end; {case}


			      dejaDansListe := FichierPhotosExisteEnMemoire(path,num);
			      dejaDansMenu  := FichierPhotosExisteDansMenu(textePourMenu,num);

			      if not(dejaDansListe) and (nbFichiers < kMaxFichiersOthelliers)  then
			        begin
							  inc(nbFichiers);
							  with fic[nbFichiers] do
						      begin
						        typeFichier   := typeFichierGraphique;

						        case typeFichier of
						          kFichierPicture2D       : couleurPions  := kAucuneEnParticulier;
						          kFichierPicture3D       : couleurPions  := CouleurPionsImage3D(path);
						          kFichierPictureHappyEnd : couleurPions  := CouleurPionsImage3D(path);
						          kFichierBordure         : couleurPions  := kAucuneEnParticulier;
						          kFichierPictureMeteo    : couleurPions  := kAucuneEnParticulier;
			                otherwise                 couleurPions  := kAucuneEnParticulier;
						        end;

						        nomComplet  := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
						        nomDansMenu := String255Ptr(AllocateMemoryPtr(sizeof(String255)));

						        if nomComplet  <> NIL then nomComplet^  := path;
						        if nomDansMenu <> NIL then nomDansMenu^ := textePourMenu;

						        if nomDansMenu <> NIL then
							        case typeFichierGraphique of
							          kFichierPicture2D :
							            begin
							              nbItemsDansMenu := MyCountMenuItems(Picture2DMenu);
							              whichMenuID     := Picture2DID;
							              whichMenuItem   := nbItemsDansMenu + 1;
							              MyInsertMenuItem(Picture2DMenu,nomDansMenu^,whichMenuItem);
							            end;
							          kFichierPicture3D :
							            begin
							              if dejaDansMenu
							                then
							                  begin {tous les fichiers de la meme famille partage le meme whichMenuItem}
							                    whichMenuID   := fic[num].whichMenuID;
							                    whichMenuItem := fic[num].whichMenuItem;
							                  end
							                else    {c'est le premier de la famille}
								                begin
										              nbItemsDansMenu := MyCountMenuItems(Picture3DMenu);
										              whichMenuID     := Picture3DID;
										              whichMenuItem   := nbItemsDansMenu + 1;
										              MyInsertMenuItem(Picture3DMenu,nomDansMenu^,whichMenuItem);
										            end;
							            end;
							          kFichierPictureHappyEnd :
							            begin
							              if dejaDansMenu
							                then
							                  begin {tous les fichiers de la meme famille partage le meme whichMenuItem}
							                    whichMenuID   := fic[num].whichMenuID;
							                    whichMenuItem := fic[num].whichMenuItem;
							                  end
							                else    {c'est le premier de la famille}
								                begin
										              nbItemsDansMenu := MyCountMenuItems(Picture2DMenu);
										              whichMenuID     := Picture2DID;
										              whichMenuItem   := nbItemsDansMenu + 1;
										              MyInsertMenuItem(Picture2DMenu,nomDansMenu^,whichMenuItem);
										            end;
							            end;
							        end; {case}

						      end; {with fic[nbFichiers]}
							end;
				  end;
	    end;
end;

function TraiteFichierPictureEtRecursion(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
begin
 {$UNUSED pb}

 if not(isFolder) then
   begin
     if (Pos('Meteo',path) <> 0)
       then AjouterFichierOthellierPicture(fs,kFichierPictureMeteo) else

     if (Pos('2D',path) <> 0) and ('Bordure' = GetNameOfFSSpec(fs))
       then AjouterFichierOthellierPicture(fs,kFichierBordure)      else

     if (Pos('2D',path) <> 0) and (Pos('Bordure',GetNameOfFSSpec(fs)) <= 0)
       then AjouterFichierOthellierPicture(fs,kFichierPicture2D)    else

     if (Pos('3D',path) <> 0)
       then AjouterFichierOthellierPicture(fs,kFichierPicture3D)    else

     if (Pos('Happy End',path) <> 0)
       then AjouterFichierOthellierPicture(fs,kFichierPictureHappyEnd);
   end;

  {on cherche recursivement, sauf dans le dossier "cache"}
  TraiteFichierPictureEtRecursion := isFolder and (Pos(':cache',path) = 0) ;
end;


procedure CherchePicturesOthelliersDansDossier( pathDuDossier : String255; var dossierTrouve : boolean);
var directoryDepart : FSSpec;
    codeErreur : OSErr;
    cheminDirectoryDepartRecursion : String255;
begin
  cheminDirectoryDepartRecursion := pathDuDossier + ':';

  codeErreur := MyFSMakeFSSpec(0,0,cheminDirectoryDepartRecursion,directoryDepart);

  codeErreur := SetPathOfScannedDirectory(directoryDepart);

  if (codeErreur = 0) then
    codeErreur := ScanDirectory(directoryDepart,TraiteFichierPictureEtRecursion);

  dossierTrouve := (codeErreur = 0);

end;


procedure LecturePreparatoireDossierOthelliers( pathDuDossierPere : String255 );
var trouve : boolean;
    iterateurCassioFolderPaths : String255;
begin

  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(pathDuDossierPere);

  repeat
    CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Othelliers Cassio',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Othelliers Cassio (alias)',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Othelliers',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Othelliers (alias)',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Boards',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Boards Cassio',trouve);
    if not(trouve) then CherchePicturesOthelliersDansDossier(iterateurCassioFolderPaths + 'Boards Cassio (alias)',trouve);

    if trouve
      then AddValidCassioFolderPath(iterateurCassioFolderPaths)
      else iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until trouve or (iterateurCassioFolderPaths = '');


end;


function LitFichierCoordoneesImages3D(var quelleTexture : CouleurOthellierRec) : OSErr;
var erreurES : OSErr;
    nomDansMenu,path,ligne : String255;
    fic : FichierTEXT;
    unRect : rect;
    unPoint : Point;
    s0,s1,s2,s3,s4,s : String255;
    i,k,square : SInt16;

  function ScaleCoordonate(coord : SInt32) : SInt32;
  var result : SInt32;
  begin
    result := coord;
    result := ((result * 225) + 128 ) div 256;   // pour passer de 1024x768  à  900x675
    ScaleCoordonate := result;
  end;


begin
  nomDansMenu := GetNomDansMenuPourCetteTexture(quelleTexture);

  path := PathFichierPicture3DDeCetteFamille(nomDansMenu,kFichierCoordonees);

  erreurES := FichierTexteExiste(path,0,fic);
  if (erreurES <> NoErr) then
    begin
      LitFichierCoordoneesImages3D := erreurES;
      exit;
    end;

  erreurES := OuvreFichierTexte(fic);
  if (erreurES <> NoErr) then
    begin
      LitFichierCoordoneesImages3D := erreurES;
      exit;
    end;

  SetRect(unRect,0,0,0,0);
  for k := 11 to 88 do
    begin
      SetBoundingRect3D(k,unRect);
      SetRect3DDessus(k,unRect);
      SetRect3DDessous(k,unRect);
    end;
  SetRectEscargot(unRect);
  SetDebugBoundingRects3DPovRay(false);
  SetDebugLegalMovesRects3DPovRay(false);
  SetDebugUpSideFacesRects3DPovRay(false);

  while (erreurES = NoErr) and not(EOFFichierTexte(fic,erreurES)) do
    begin
      erreurES := ReadlnDansFichierTexte(fic,ligne);
      //WritelnDansRapport(ligne);  // CREATE NEW
      if (erreurES = NoErr) and (ligne <> '') and (ligne[1] <> '%') then
        begin
          Parser3(ligne,s0,s1,s2,s);
          if (s1 = '=') and (s2 <> '{') then
            begin
              s0 := UpperCase(s0,false);
              s2 := UpperCase(s2,false);

              {parser les booleens}
              if (Pos('DEBUG_BOUNDING_RECTANGLES',s0) > 0) or
                 (Pos('DEBUG_UPPER_RECTANGLES',s0) > 0) or
                 (Pos('DEBUG_DOWN_RECTANGLES',s0) > 0) then
                begin
		              if Pos('DEBUG_BOUNDING_RECTANGLES',s0) > 0 then SetDebugBoundingRects3DPovRay(s2 = 'TRUE') else
		              if Pos('DEBUG_UPPER_RECTANGLES',s0)   > 0 then SetDebugUpSideFacesRects3DPovRay(s2 = 'TRUE') else
		              if Pos('DEBUG_DOWN_RECTANGLES',s0)    > 0 then SetDebugLegalMovesRects3DPovRay(s2 = 'TRUE');
		            end;
            end else
          if (s1 = '=') and (s2 = '{') then
            begin
              s0 := UpperCase(s0,false);

              {parser les rectangles}
              if (Pos('ESCARGOT_RECT',s0) > 0) or
                 (Pos('BOUNDING_RECT',s0) > 0) or
                 (Pos('UP_RECT',s0) > 0) or
                 (Pos('DOWN_RECT',s0) > 0)
                  then
                begin
		              Parser4(s,s1,s2,s3,s4,s);
		              SetRect(unRect,ChaineEnInteger(s1),ChaineEnInteger(s2),ChaineEnInteger(s3),ChaineEnInteger(s4));

		              (*
		              with unRect do
		                begin
		                  WriteDansRapport(EnMinuscule(s0) +'  =  { ');
		                  WriteNumDansRapport(' ',ScaleCoordonate(left));  // pour passer de 1024x768 à 900x675
		                  WriteNumDansRapport(' ',ScaleCoordonate(top));
		                  WriteNumDansRapport(' ',ScaleCoordonate(right));
		                  WriteNumDansRapport(' ',ScaleCoordonate(bottom));
		                  WritelnDansRapport(' } ');
		                end;
		              *)

		              square := StringEnCoup(s0);
		              if Pos('ESCARGOT_RECT',s0) > 0 then SetRectEscargot(unRect) else
		              if Pos('BOUNDING_RECT',s0) > 0 then SetBoundingRect3D(square,unRect) else
		              if Pos('UP_RECT',s0)      > 0 then SetRect3DDessus(square,unRect)   else
		              if Pos('DOWN_RECT',s0)    > 0 then SetRect3DDessous(square,unRect);
		            end;

		          {parser les points}
			        if (Pos('IMAGE_SIZE',s0) > 0) or
			           (Pos('BLACK_SCORE_POSITION',s0) > 0) or
			           (Pos('WHITE_SCORE_POSITION',s0) > 0) or
			           (Pos('BEST_LINE_POSITION',s0) > 0) or
			           (Pos('YOUR_MOVE_PLEASE_POSITION',s0) > 0) then
			            begin
			              Parser2(s,s1,s2,s);
			              unPoint.h := ChaineEnInteger(s1);
			              unPoint.v := ChaineEnInteger(s2);

			              (*
			              with unPoint do
			                begin
			                  WriteDansRapport(EnMinuscule(s0) + '  =  { ');
			                  WriteNumDansRapport(' ',ScaleCoordonate(h));
			                  WriteNumDansRapport(' ',ScaleCoordonate(v));
			                  WritelnDansRapport(' } ');
			                end;
			              *)

			              if Pos('IMAGE_SIZE',s0) > 0                then SetTailleImagesPovRay(unPoint) else
			              if Pos('BLACK_SCORE_POSITION',s0) > 0      then SetPositionScorePovRay3D(pionNoir,unPoint) else
			              if Pos('WHITE_SCORE_POSITION',s0) > 0      then SetPositionScorePovRay3D(pionBlanc,unPoint) else
		                if Pos('BEST_LINE_POSITION',s0) > 0        then SetPositionMeilleureSuitePovRay3D(unPoint) else
		                if Pos('YOUR_MOVE_PLEASE_POSITION',s0) > 0 then SetPositionDemandeCoupPovRay3D(unPoint);
			            end;
			      end;
        end;
    end;


  for i := 1 to 8 do
    for k := 1 to 6 do
      begin
        square := i*10 + k + 1;

        unRect := InterpolerRectangles(GetBoundingRect3D(i*10+1),GetBoundingRect3D(i*10+8),7,k);
        SetBoundingRect3D(square,unRect);

        unRect := InterpolerRectangles(GetRect3DDessus(i*10+1),GetRect3DDessus(i*10+8),7,k);
        SetRect3DDessus(square,unRect);

        unRect := InterpolerRectangles(GetRect3DDessous(i*10+1),GetRect3DDessous(i*10+8),7,k);
        SetRect3DDessous(square,unRect);
      end;


  erreurES := FermeFichierTexte(fic);
  LitFichierCoordoneesImages3D := erreurES;
end;


procedure TestUnitFichierPhotos;
var fic : FichierTEXT;
    temp : boolean;
begin
  temp := GetDebuggageUnitFichiersTexte;
  SetDebuggageUnitFichiersTexte(true);

  if FichierPhotosExisteSurLeDisque('Photos Cassio',fic)
    then
      WritelnDansRapport('Le fichier des photos a été trouvé !')
    else
      WritelnDansRapport('Le fichier des photos est introuvable !');

  SetDebuggageUnitFichiersTexte(temp);
 end;



END.
