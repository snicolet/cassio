UNIT UnitCalculCouleurCassio;


INTERFACE








 USES UnitDefCassio , QuickDraw;



function ChoisirCouleurOthellierAvecPicker(var theColor : RGBColor) : boolean;

function CalculeCouleurRecord(whichMenuID,whichMenuCmd : SInt16) : CouleurOthellierRec;
procedure CheckScreenDepth;
procedure CheckValidityOfCouleurRecord(var whichColor : CouleurOthellierRec; var colorChanged : boolean);

function PlusProcheCouleurRGBOfTexture(var whichColor : CouleurOthellierRec; var textureInconnue : boolean) : RGBColor;
procedure DetermineOthellierPatSelonCouleur(CouleurDemandeeParUtilisateur : SInt16; var othellierPat : pattern);

function GetTypeOfTexture(const nomTexture : String255) : SInt32;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ColorPicker
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitMenus, UnitFenetres, UnitTroisiemeDimension, MyStrings, UnitDialog, UnitCouleur, UnitFichierPhotos, UnitAffichagePlateau
     ;
{$ELSEC}
    ;
    {$I prelink/CalculCouleurCassio.lk}
{$ENDC}


{END_USE_CLAUSE}




function GetTypeOfTexture(const nomTexture : String255) : SInt32;
var numeroFic : SInt16;
begin
  GetTypeOfTexture := kFichierPictureInconnu;

  if FichierPhotosExisteDansMenu(nomTexture, numeroFic) then
    GetTypeOfTexture := gFichiersPicture.fic[numeroFic].typeFichier;
end;



function ChoisirCouleurOthellierAvecPicker(var theColor : RGBColor) : boolean;
const TextesDiversID = 10020;
var prompt : String255;
    where : Point;
    newColor : RGBColor;
begin
  where.h := -1;
  where.v := -1;  {valeur spéciale pour avoir le dialogue centré sur l'écran avec le plus de couleurs}
  prompt := ReadStringFromRessource(TextesDiversID,5);  {'Choisissez la couleur de l'othellier'}
  newColor := theColor;
  BeginDialog;
  if GetColor(where,StringToStr255(prompt),theColor,newColor)
    then
      begin
        theColor := newColor;
        ChoisirCouleurOthellierAvecPicker := true;
      end
    else
      begin
        ChoisirCouleurOthellierAvecPicker := false;
      end;
  EndDialog;
end;



procedure DetermineOthellierPatSelonCouleur(CouleurDemandeeParUtilisateur : SInt16; var othellierPat : pattern);
var i : SInt16;
begin  {$UNUSED CouleurDemandeeParUtilisateur}
  if not(gEcranCouleur)
    then
      begin
        if not(CassioEstEn3D) and (GetTailleCaseCourante <= 12)
          then
             othellierPat := whitePattern
          else
            for i := 0 to 7 do othellierPat.pat[i] := 255-grayPattern.pat[i];
      end
    else
      othellierPat := blackPattern;
end;


function CalculeCouleurRecord(whichMenuID,whichMenuCmd : SInt16) : CouleurOthellierRec;
var aux : CouleurOthellierRec;
    textureInconnue : boolean;
begin
  with aux do
    begin
      menuID                          := whichMenuID;
      menuCmd                         := whichMenuCmd;

	    DetermineFrontAndBackColor(menuCmd,couleurFront,couleurBack);
	    DetermineOthellierPatSelonCouleur(menuCmd,whichPattern);

	  if (whichMenuID = 100)   { CouleurID = 100 est defini dans UnitMenu.p}
	    then
	      begin
	        nomFichierTexture := 'kSimplementUneCouleur';
	        estUneImage := false;
	        estPovRayEn3D := false;

	        RGB                             := CouleurCmdToRGBColor(menuCmd);
			    estTresClaire                   := EstUneCouleurTresClaire(menuCmd);
		      estComposee                     := EstUneCouleurComposee(menuCmd);
		      plusProcheCouleurDeBase         := CalculePlusProcheCouleurDeBase(menuCmd,true);
		      if whichMenuCmd <> BlancCmd
		        then plusProcheCouleurDeBaseSansBlanc := CalculePlusProcheCouleurDeBase(menuCmd,false)
		        else plusProcheCouleurDeBaseSansBlanc := BlancCmd;  {on force ça}

	      end
	    else
	      begin
	        estUneImage := true;
	        nomFichierTexture := GetNomDansMenuPourCetteTexture(aux);
	        estPovRayEn3D := (whichMenuID = 110);  { Picture3DID = 110 est defini dans UnitMenu.p}

	        RGB                              := PlusProcheCouleurRGBOfTexture(aux,textureInconnue);
			    estTresClaire                    := RGBColorEstClaire(RGB,40000);
		      estComposee                      := true;
		      plusProcheCouleurDeBase          := CalculePlusProcheCouleurDeBase(VertCmd,true);
		      plusProcheCouleurDeBaseSansBlanc := CalculePlusProcheCouleurDeBase(VertCmd,false);
	      end;



	    {
	    WritelnNumDansRapport('menuCmd = ',menuCmd);
	    if EsttResClaire
	      then WritelnNumDansRapport('est tres claire = ',1)
	      else WritelnNumDansRapport('est tres claire = ',0);
	    if estComposee
	      then WritelnNumDansRapport('est composee = ',1)
	      else WritelnNumDansRapport('est composee = ',0);
	    WritelnNumDansRapport('plusProcheCouleurDeBase = ',plusProcheCouleurDeBase);
	    WritelnNumDansRapport('plusProcheCouleurDeBaseSansBlanc = ',plusProcheCouleurDeBaseSansBlanc);
	    WritelnNumDansRapport('couleurFront = ',couleurFront);
	    WritelnNumDansRapport('couleurBack = ',couleurBack);
	    }

	  end;
  CalculeCouleurRecord := aux;
end;


procedure CheckScreenDepth;
var oldEcranCouleur,nouvelEcranEstEnCouleur : boolean;
begin
  oldEcranCouleur := gEcranCouleur;
  if gHasColorQuickDraw
    then nouvelEcranEstEnCouleur := (ProfondeurMainDevice > 2)
    else nouvelEcranEstEnCouleur := false;
  if oldEcranCouleur <> nouvelEcranEstEnCouleur then
    if nouvelEcranEstEnCouleur
      then   {l'utilisateur a augmenté le nbre de couleurs  }
        begin
          gEcranCouleur := true;
          gBlackAndWhite := not(gEcranCouleur);
          gCouleurOthellier := CalculeCouleurRecord(gCouleurOthellier.menuID,gCouleurOthellier.menuCmd);
	        InvalidateAllWindows;
        end
      else   {l'utilisateur a baissé le nbre de couleurs }
	      begin
	        gEcranCouleur := false;
	        gBlackAndWhite := not(gEcranCouleur);
	        gCouleurOthellier.couleurFront := blackColor;
	        gCouleurOthellier.couleurBack := whiteColor;
	        DetermineOthellierPatSelonCouleur(gCouleurOthellier.menuCmd,gCouleurOthellier.whichPattern);
	        InvalidateAllWindows;
	      end;
end;



procedure CheckValidityOfCouleurRecord(var whichColor : CouleurOthellierRec; var colorChanged : boolean);
var numero,nbCouleursDansMenu : SInt16;
    fic : basicfile;
    probleme : boolean;
begin
  probleme := false;

  with whichColor do
    if (nomFichierTexture = '') or (nomFichierTexture = 'kSimplementUneCouleur')
      then
        begin
          nbCouleursDansMenu := AutreCouleurCmd; {CountMItem(CouleurMenu) - 3}
          if menuCmd <= nbCouleursDansMenu
            then whichColor := CalculeCouleurRecord(CouleurID,menuCmd)
            else probleme := true;
        end
      else
        begin
          if not(FichierPhotosExisteDansMenu(nomFichierTexture,numero))
            then
              probleme := true
            else
              with gFichiersPicture.fic[numero] do
                if not(FichierPhotosExisteSurLeDisque(nomComplet^,fic))
                  then probleme := true
                  else whichColor := CalculeCouleurRecord(whichMenuID,whichMenuItem);
        end;

  if probleme then
    begin
      whichColor := CalculeCouleurRecord(CouleurID,VertPaleCmd);
    end;

  colorChanged := probleme;
end;


function PlusProcheCouleurRGBOfTexture(var whichColor : CouleurOthellierRec; var textureInconnue : boolean) : RGBColor;
var result : RGBColor;

  procedure SetResult(red,green,blue  : SInt32);
    begin
      SetRGBColor(result,red,green,blue);
      textureInconnue := false;
    end;

begin
  result := gPurVert; {defaut}
  textureInconnue := true;

  with whichColor do
    begin
      if estPovRayEn3D                               then SetResult(2600, 31300,11100) else
      if nomFichierTexture = 'Photographique'        then SetResult(15000,31000,26000) else
      if nomFichierTexture = 'Pions go'              then SetResult(45400,34000,23000) else
      if (Pos('Realiste',nomFichierTexture) > 0) or
         (Pos('Réaliste',nomFichierTexture) > 0) or
         (Pos('Fantaisie',nomFichierTexture) > 0)    then SetResult(11000,26000,6100) else
      if (Pos('Metal',nomFichierTexture) > 0) or
         (Pos('Métal',nomFichierTexture) > 0) or
         (Pos('Vert &',nomFichierTexture) > 0)       then SetResult(18500,23500,31000) else
      if (Pos('VOG',nomFichierTexture) > 0)          then SetResult(8400, 36000,21000) else
      if (Pos('Zebra',nomFichierTexture) > 0)        then SetResult(14800,32300,17520) else
      if (Pos('Alveole',nomFichierTexture) > 0)      then SetResult(15350,31900,17800) else

      if (Pos('Tsukuda magnetic',nomFichierTexture) > 0)      then SetResult(1082,34827,15900) else
      if (Pos('Tsukuda mini',nomFichierTexture) > 0)          then SetResult(6500,40000,21500) else
      if (Pos('Tsukuda professional',nomFichierTexture) > 0)  then SetResult(11000,28000,13000) else
      if (Pos('Tsukuda official',nomFichierTexture) > 0)      then SetResult(11000,28000,13000) else
      if (Pos('Spear',nomFichierTexture) > 0)                 then SetResult(13000,33000,14000) else
      if (Pos('Ravensburger',nomFichierTexture) > 0)          then SetResult(17600,15000,14000) else
      if (Pos('Magnetic',nomFichierTexture) > 0)              then SetResult(7000,24000,3000) else
      if (Pos('EuroCents',nomFichierTexture) > 0)             then SetResult(7000,24000,3000) else
      if (Pos('Barnaba',nomFichierTexture) > 0)               then SetResult(7500,21500,8700) else
      if (Pos('Clementoni',nomFichierTexture) > 0)            then SetResult(27800,29300,13800) else

      if nomFichierTexture = 'kSimplementUneCouleur' then SetResult(RGB.red, RGB.green, RGB.blue) else
      if nomFichierTexture = 'Boules'                then SetResult(0,0,0);
    end;

  PlusProcheCouleurRGBOfTexture := result;
end;

END.
