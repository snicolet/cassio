UNIT UnitDefCouleurs;



INTERFACE


USES MacTypes,StringTypes,UnitOth0;





const
  Picture2DCmd = 1;     {items du menu Couleur}
  Picture3DCmd = 2;
  {----------}
  VertCmd = 4;
  VertPaleCmd = 5;
  VertSapinCmd = 6;
  VertPommeCmd = 7;
  VertTurquoiseCmd = 8;
  VertKakiCmd = 9;
  BleuCmd = 10;
  BleuPaleCmd = 11;
  MarronCmd = 12;
  RougePaleCmd = 13;
  OrangeCmd = 14;
  JauneCmd = 15;
  JaunePaleCmd = 16;
  MarineCmd = 17;
  MarinePaleCmd = 18;
  VioletCmd = 19;
  MagentaCmd = 20;
  MagentaPaleCmd = 21;
  {-------------}
  AutreCouleurCmd = 23;
  {-------------}
  NoirCmd  = -1;    {valeur speciale : item impossible}
  BlancCmd = -2;
  RougeCmd = 1000; {valeur speciale : item impossible pour pouvoir avoir le rouge en RGB}

type CouleurOthellierRec = record
                             menuID : SInt16;
                             menuCmd : SInt16;
                             estTresClaire : boolean;
                             estComposee : boolean;
                             estUneImage : boolean;
                             estPovRayEn3D : boolean;
                             couleurFront : SInt16;
                             couleurBack : SInt16;
                             RGB : RGBColor;
                             whichPattern : pattern;
                             plusProcheCouleurDeBase : SInt16;
                             plusProcheCouleurDeBaseSansBlanc : SInt16;
                             nomFichierTexture : String255;
                           end;


var gHasColorQuickDraw : boolean;

    gCouleurSupplementaire : RGBColor;
    gEcranCouleur : boolean;
    gBlackAndWhite : boolean;
    gCouleurOthellier : CouleurOthellierRec;

    gPurVert : RGBColor;
    gPurRouge : RGBColor;
    gPurMagenta : RGBColor;
    gPurBlanc : RGBColor;
    gPurNoir : RGBColor;
    gPurBleu : RGBColor;
    gPurJaune : RGBColor;
    gPurCyan : RGBColor;
    gPurGris : RGBColor;
    gPurGrisClair : RGBColor;
    gPurGrisFonce : RGBColor;

    kSteelBlueRGB : RGBColor; {une couleur que l'on peut utiliser pour dessiner des barres de progression}


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}











END.
