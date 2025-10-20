UNIT UnitCouleur;


INTERFACE







 USES UnitDefCassio;





procedure InitUnitCouleur;
procedure SetRGBColor (var theColor: RGBColor; redValue, greenValue, blueValue: SInt32);
function IsSameRGBColor(c1,c2 : RGBColor) : boolean;

function CouleurCmdToRGBColor(couleurCmd : SInt16) : RGBColor;
procedure DetermineFrontAndBackColor(CouleurDemandeeParUtilisateur : SInt16; var couleurFront,couleurBack : SInt16);

function RGBColorEstClaire(color : RGBColor; seuilLuminosite : SInt32) : boolean;
function RGBColorEstFoncee(color : RGBColor; seuilLuminosite : SInt32) : boolean;
function EstUneCouleurTresClaire(whichCouleurCmd : SInt16) : boolean;
function EstUneCouleurClaire(whichCouleurCmd : SInt16) : boolean;
function EstUneCouleurComposee(whichCouleurCmd : SInt16) : boolean;
function DistanceDesCouleurs(c1,c2 : RGBColor) : SInt32;
function CalculePlusProcheCouleurDeBase(couleurOthellier : SInt16; BlancCompris : boolean) : SInt16;
function GetCouleurAffichageValeurZebraBook(trait : SInt32; whichNote : SInt32) : RGBColor;
function GetCouleurAffichageValeurCourbe(trait : SInt32; whichNote : SInt32) : RGBColor;
procedure DessineCouleurDeZebraBookDansRect(whichRect : rect; trait,valeur : SInt32; encadrement : boolean);

function EclaircirCouleur(theColor : RGBColor) : RGBColor;
function NoircirCouleur(theColor : RGBColor) : RGBColor;
function EclaircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;
function NoircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;


procedure DessineOmbreRoundRect(theRect : rect; ovalWidth,ovalHeight : SInt16; targetColor : RGBColor; tailleOmbre,forceDuGradient,ombrageMinimum,typeOmbrage : SInt32);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    ColorPicker
{$IFC NOT(USE_PRELINK)}
    , MyStrings, MyMathUtils, UnitGeometrie, UnitRapport ;
{$ELSEC}
    ;
    {$I prelink/Couleur.lk}
{$ENDC}


{END_USE_CLAUSE}





procedure InitUnitCouleur;
begin
  gHasColorQuickDraw := true;

  gCouleurSupplementaire := CouleurCmdToRGBColor(VertPaleCmd); {vert par défaut}

  SetRGBColor(gPurRouge,65535,0,0);
  SetRGBColor(gPurVert,0,65535,0);
  SetRGBColor(gPurBleu,0,0,65535);
  SetRGBColor(gPurMagenta,65535,0,65535);
  SetRGBColor(gPurBlanc,65535,65535,65535);
  SetRGBColor(gPurNoir,0,0,0);
  SetRGBColor(gPurGris,32767,32767,32767);
  SetRGBColor(gPurJaune,65535,65535,0);
  SetRGBColor(gPurCyan,0,65535,65535);
  SetRGBColor(gPurGrisClair,55000,55000,55000);
  SetRGBColor(gPurGrisFonce,20000,20000,20000);
end;


procedure SetRGBColor (var theColor: RGBColor; redValue, greenValue, blueValue: SInt32);
begin
  {$PUSH}
  {$R-}
	with theColor do
		begin
			red := redValue;
			green := greenValue;
			blue := blueValue;
		end;
  {$POP}
end;

function IsSameRGBColor(c1,c2 : RGBColor) : boolean;
begin
  IsSameRGBColor := (c1.red   = c2.red) &
                    (c1.green = c2.green) &
                    (c1.blue  = c2.blue);
end;


function CouleurCmdToRGBColor(couleurCmd : SInt16) : RGBColor;
var theColor : RGBColor;
begin
  case couleurCmd of
	   {NoirEtBlancCmd        : SetRGBColor(theColor,30000,30000,30000);}
	   VertCmd                : SetRGBColor(theColor,0,33410,0);
	   VertPaleCmd            : SetRGBColor(theColor,33608,46267,29753);
	   VertSapinCmd           : SetRGBColor(theColor,14135,29850,12593);
	   VertPommeCmd           : SetRGBColor(theColor,22102,41120,257);
	   VertTurquoiseCmd       : SetRGBColor(theColor,21074,45232,36751);
	   VertKakiCmd            : SetRGBColor(theColor,35503,49018,14482);
	   BleuCmd                : SetRGBColor(theColor,22817,40092,52685);
	   BleuPaleCmd            : SetRGBColor(theColor,10000,65535,65335);
	   MarronCmd              : SetRGBColor(theColor,50243,30317,11788);
	   RougeCmd               : SetRGBColor(theColor,65535,0,0);
	   RougePaleCmd           : SetRGBColor(theColor,65535,26193,27446);
	   OrangeCmd              : SetRGBColor(theColor,65535,27783,3318);
	   JauneCmd               : SetRGBColor(theColor,65535,65535,0);
	   JaunePaleCmd           : SetRGBColor(theColor,65535,63776,22812);
	   MarineCmd              : SetRGBColor(theColor,0,0,65535);
	   MarinePaleCmd          : SetRGBColor(theColor,16500,15200,40000);
	   VioletCmd              : SetRGBColor(theColor,27897,6383,38362);
	   MagentaCmd             : SetRGBColor(theColor,50709,19521,65535);
	   MagentaPaleCmd         : SetRGBColor(theColor,65535,23003,62920);
	   AutreCouleurCmd        : theColor := gCouleurSupplementaire;
	   BlancCmd               : SetRGBColor(theColor,65535,65535,65535);
	   NoirCmd                : SetRGBColor(theColor,0,0,0);
	 otherwise
	   theColor := CouleurCmdToRGBColor(VertPaleCmd);  {appel récursif pour avoir du vert par défaut}
	end;
	CouleurCmdToRGBColor := theColor;
end;


procedure DetermineFrontAndBackColor(CouleurDemandeeParUtilisateur : SInt16; var couleurFront,couleurBack : SInt16);
begin
  couleurBack := whiteColor;
  case CouleurDemandeeParUtilisateur of
	   {NoirEtBlancCmd          : couleurFront := blackColor;}
	   VertCmd                 : couleurFront := greenColor;
	   VertPaleCmd             : couleurFront := greenColor;
	   VertSapinCmd            : begin
	                               couleurFront := greenColor;
	                               couleurBack := BlackColor;
	                             end;
	   VertPommeCmd            : begin
	                               couleurFront := greenColor;
	                               couleurBack := yellowColor;
	                             end;
	   VertTurquoiseCmd        : begin
	                               couleurFront := greenColor;
	                               couleurBack := cyanColor;
	                             end;
	   VertKakiCmd             : begin
	                               couleurFront := yellowColor;
	                               couleurBack := blackColor;
	                             end;
	   BleuCmd                 : couleurFront := cyanColor;
	   BleuPaleCmd             : couleurFront := cyanColor;
	   MarronCmd               : couleurFront := redColor;
	   RougePaleCmd            : couleurFront := redColor;
	   OrangeCmd               : begin
	                               couleurFront := RedColor;
	                               couleurBack := yellowColor;
	                             end;
	   JauneCmd                : couleurFront := yellowColor;
	   JaunePaleCmd            : couleurFront := yellowColor;
	   MarineCmd               : couleurFront := blueColor;
	   MarinePaleCmd           : couleurFront := blueColor;
	   VioletCmd               : begin
	                               couleurFront := magentaColor;
	                               couleurBack := cyanColor;
	                             end;
	   MagentaCmd              : couleurFront := magentaColor;
	   MagentaPaleCmd          : couleurFront := magentaColor;
	   BlancCmd                : couleurFront := whiteColor;

     AutreCouleurCmd         : begin  {qu'est-ce qu'on met ??}
                                 couleurFront := CalculePlusProcheCouleurDeBase(AutreCouleurCmd,false);
                                 couleurBack := BlackColor;
                               end;
     otherwise                 couleurFront := greenColor;
	end;
end;


{ Une couleur RGB est claire si sa luminosité totale
  est strictement superieure à seuilLuminosite }
function RGBColorEstClaire(color : RGBColor; seuilLuminosite : SInt32) : boolean;
var luminosite : SInt32;
    myHSLColor : HSLColor;
begin
  RGB2HSL(color,myHSLColor);
  luminosite := myHSLColor.lightness;
  if luminosite < 0 then luminosite := luminosite+65535;
  {WritelnNumDansRapport('luminosite = ',luminosite);}
  RGBColorEstClaire := (luminosite > seuilLuminosite);
end;


{ Une couleur RGB est foncée si sa luminosité totale
  est inférieure ou égale à seuilLuminosite }
function RGBColorEstFoncee(color : RGBColor; seuilLuminosite : SInt32) : boolean;
begin
  RGBColorEstFoncee := not(RGBColorEstClaire(color,seuilLuminosite));
end;


function EstUneCouleurTresClaire(whichCouleurCmd : SInt16) : boolean;
begin
  if whichCouleurCmd = AutreCouleurCmd
    then EstUneCouleurTresClaire := RGBColorEstClaire(gCouleurSupplementaire,40000)
    else EstUneCouleurTresClaire := (whichCouleurCmd = BlancCmd)       |
                                    (whichCouleurCmd = JauneCmd)       |
                                    (whichCouleurCmd = JaunePaleCmd)   |
                                    (whichCouleurCmd = VertKakiCmd)    |
                                    (whichCouleurCmd = BleuPaleCmd);
end;

function EstUneCouleurClaire(whichCouleurCmd : SInt16) : boolean;
begin
  if whichCouleurCmd = AutreCouleurCmd
    then EstUneCouleurClaire := RGBColorEstClaire(gCouleurSupplementaire,20000)
    else EstUneCouleurClaire :=  (whichCouleurCmd = BlancCmd)       |
                                 (whichCouleurCmd = JauneCmd)       |
                                 (whichCouleurCmd = JaunePaleCmd)   |
                                 (whichCouleurCmd = VertKakiCmd)    |
                                 (whichCouleurCmd = BleuPaleCmd);
end;


function EstUneCouleurComposee(whichCouleurCmd : SInt16) : boolean;
begin
  EstUneCouleurComposee := not((whichCouleurCmd = VertCmd)   |
                               (whichCouleurCmd = BleuCmd)   |
                               (whichCouleurCmd = JauneCmd)  |
                               (whichCouleurCmd = MarineCmd) |
                               (whichCouleurCmd = MagentaCmd)|
                               (whichCouleurCmd = BlancCmd));
end;


function DistanceDesCouleurs(c1,c2 : RGBColor) : SInt32;
var aux1,aux2,sum : SInt32;
begin
  sum := 0;
  aux1 := c1.red;
  if aux1 < 0 then aux1 := aux1+65535;
  aux2 := c2.red;
  if aux2 < 0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  aux1 := c1.green;
  if aux1 < 0 then aux1 := aux1+65535;
  aux2 := c2.green;
  if aux2 < 0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  aux1 := c1.blue;
  if aux1 < 0 then aux1 := aux1+65535;
  aux2 := c2.blue;
  if aux2 < 0 then aux2 := aux2+65535;
  sum := sum+Abs(aux1-aux2);
  DistanceDesCouleurs := sum;
end;



function CalculePlusProcheCouleurDeBase(couleurOthellier : SInt16; BlancCompris : boolean) : SInt16;
var minDist : SInt32;

  procedure TestDistanceCetteCouleur(couleur : RGBColor; couleurDeBase : SInt16);
  var dist : SInt32;
  begin
    dist := DistanceDesCouleurs(gCouleurSupplementaire,couleur);
    if dist < minDist then
      begin
        minDist := dist;
        CalculePlusProcheCouleurDeBase := couleurDeBase;
      end;
  end;

begin
  CalculePlusProcheCouleurDeBase := greenColor;  {par defaut}
  case couleurOthellier of
	   {NoirEtBlancCmd         : CalculePlusProcheCouleurDeBase := whiteColor;}
	   VertCmd                : CalculePlusProcheCouleurDeBase := greenColor;
	   VertPaleCmd            : CalculePlusProcheCouleurDeBase := greenColor;
	   VertSapinCmd           : CalculePlusProcheCouleurDeBase := greenColor;
	   VertPommeCmd           : CalculePlusProcheCouleurDeBase := greenColor;
	   VertTurquoiseCmd       : CalculePlusProcheCouleurDeBase := greenColor;
	   VertKakiCmd            : CalculePlusProcheCouleurDeBase := yellowColor;
	   BleuCmd                : CalculePlusProcheCouleurDeBase := cyanColor;
	   BleuPaleCmd            : CalculePlusProcheCouleurDeBase := cyanColor;
	   MarronCmd              : CalculePlusProcheCouleurDeBase := redColor;
	   RougePaleCmd           : CalculePlusProcheCouleurDeBase := redColor;
	   OrangeCmd              : CalculePlusProcheCouleurDeBase := yellowColor;
	   JauneCmd               : CalculePlusProcheCouleurDeBase := yellowColor;
	   JaunePaleCmd           : CalculePlusProcheCouleurDeBase := yellowColor;
	   MarineCmd              : CalculePlusProcheCouleurDeBase := blueColor;
	   MarinePaleCmd          : CalculePlusProcheCouleurDeBase := blueColor;
	   VioletCmd              : CalculePlusProcheCouleurDeBase := magentaColor;
	   MagentaCmd             : CalculePlusProcheCouleurDeBase := magentaColor;
	   MagentaPaleCmd         : CalculePlusProcheCouleurDeBase := magentaColor;
	   BlancCmd               : CalculePlusProcheCouleurDeBase := whiteColor;
	   AutreCouleurCmd        :
	      begin
		      if (gCouleurSupplementaire.green = gPurVert.green) &
		         (gCouleurSupplementaire.red <> gPurRouge.red) &
		         (gCouleurSupplementaire.blue <> gPurBleu.blue)
		        then
		          CalculePlusProcheCouleurDeBase := greenColor
		        else
		          begin
					      minDist := 1000000000;
					      TestDistanceCetteCouleur(gPurVert   , greenColor);
					      TestDistanceCetteCouleur(gPurCyan   , cyanColor);
					      TestDistanceCetteCouleur(gPurRouge  , redColor);
					      TestDistanceCetteCouleur(gPurJaune  , yellowColor);
					      TestDistanceCetteCouleur(gPurBleu   , blueColor);
					      TestDistanceCetteCouleur(gPurMagenta, magentaColor);
					      TestDistanceCetteCouleur(gPurNoir   , greenColor);
					      if BlancCompris then TestDistanceCetteCouleur(gPurBlanc  , whiteColor);
					    end;
				end;
  end;  {case}
end;







function EclaircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;
var redValue,greenValue,blueValue : SInt32;
    result : RGBColor;
    eclaircicement : SInt32;
begin
  redValue   := theColor.red;
  greenValue := theColor.green;
  blueValue  := theColor.blue;

  if redValue   < 0 then redValue   := redValue   + 65535;
  if greenValue < 0 then greenValue := greenValue + 65535;
  if blueValue  < 0 then blueValue  := blueValue  + 65535;

  eclaircicement := quantite;

  redValue   := Min(65535,eclaircicement + redValue);
  greenValue := Min(65535,eclaircicement + greenValue);
  blueValue  := Min(65535,eclaircicement + blueValue);

  redValue   := Max(0, redValue);
  greenValue := Max(0, greenValue);
  blueValue  := Max(0, blueValue);

  SetRGBColor(result,redValue,greenValue,blueValue);
  EclaircirCouleurDeCetteQuantite := result;
end;


function NoircirCouleurDeCetteQuantite(theColor : RGBColor; quantite : SInt32) : RGBColor;
var redValue,greenValue,blueValue : SInt32;
    result : RGBColor;
    noircissement : SInt32;
begin
  if (quantite = 0) then
    begin
      NoircirCouleurDeCetteQuantite := theColor;
      exit(NoircirCouleurDeCetteQuantite);
    end;

  redValue   := theColor.red;
  greenValue := theColor.green;
  blueValue  := theColor.blue;

  if redValue   < 0 then redValue   := redValue   + 65535;
  if greenValue < 0 then greenValue := greenValue + 65535;
  if blueValue  < 0 then blueValue  := blueValue  + 65535;

  noircissement := -quantite;

  redValue   := Max(0,noircissement + redValue);
  greenValue := Max(0,noircissement + greenValue);
  blueValue  := Max(0,noircissement + blueValue);

  redValue   := Min(65535, redValue);
  greenValue := Min(65535, greenValue);
  blueValue  := Min(65535, blueValue);

  SetRGBColor(result,redValue,greenValue,blueValue);
  NoircirCouleurDeCetteQuantite := result;
end;


function NoircirCouleur(theColor : RGBColor) : RGBColor;
begin
  NoircirCouleur := NoircirCouleurDeCetteQuantite(theColor, 22000);
end;

function EclaircirCouleur(theColor : RGBColor) : RGBColor;
begin
  EclaircirCouleur := EclaircirCouleurDeCetteQuantite(theColor, 12000);
end;


function GetCouleurAffichageValeurZebraBook(trait : SInt32; whichNote : SInt32) : RGBColor;
var theColor : RGBColor;
    interet, noircissement : SInt32;
    rapiditeNoircissement : SInt32;
begin
  case trait of
    pionNoir : begin
                 theColor := CouleurCmdToRGBColor(OrangeCmd);
                 theColor := NoircirCouleurDeCetteQuantite(theColor,10000);
                 rapiditeNoircissement := 60;

                (*
                theColor := NoircirCouleurDeCetteQuantite(theColor,12000);
                if whichNote > 0
                   then rapiditeNoircissement := 55
                   else rapiditeNoircissement := 65;
                *)
               end;
    pionBlanc : begin
                  (* theColor := NoircirCouleurDeCetteQuantite(gPurVert,3000);
                  theColor := gCouleurOthellier.RGB; *)
                  SetRGBColor(theColor,20560,47800,14135);
                  theColor := NoircirCouleurDeCetteQuantite(theColor,10000);
                  rapiditeNoircissement := 60;
                end;
  end;

  if (whichNote = 0)
    then
      begin
        GetCouleurAffichageValeurZebraBook := theColor;
      end
    else
      begin
        interet := whichNote;
        if (interet > 600) then interet := 600;
        if (interet < -700) then interet := -700;
        noircissement := interet * rapiditeNoircissement;

        GetCouleurAffichageValeurZebraBook := NoircirCouleurDeCetteQuantite(theColor,noircissement);
      end;

end;


function GetCouleurAffichageValeurCourbe(trait : SInt32; whichNote : SInt32) : RGBColor;
var theColor : RGBColor;
    interet, noircissement : SInt32;
    rapiditeNoircissement : SInt32;
begin
  case trait of
    pionNoir : begin
                 theColor := GetCouleurAffichageValeurZebraBook(pionNoir, 0);
                 rapiditeNoircissement := 140;
               end;
    pionBlanc : begin
                  theColor := GetCouleurAffichageValeurZebraBook(pionBlanc, 0);
                  rapiditeNoircissement := -150;
                end;
  end;

  if (whichNote = 0)
    then
      begin
        GetCouleurAffichageValeurCourbe := theColor;
      end
    else
      begin
        interet := whichNote;
        if (interet > 600) then interet := 600;
        if (interet < -700) then interet := -700;
        noircissement := interet * rapiditeNoircissement;

        GetCouleurAffichageValeurCourbe := NoircirCouleurDeCetteQuantite(theColor,noircissement);
      end;

end;

procedure DessineCouleurDeZebraBookDansRect(whichRect : rect; trait,valeur : SInt32; encadrement : boolean);
var theColor : RGBColor;
begin
  theColor := GetCouleurAffichageValeurZebraBook(trait,valeur);

  RGBForeColor(theColor);
  RGBBackColor(theColor);

  FillRect(whichRect,blackPattern);

  if encadrement then
    begin
      theColor := EclaircirCouleurDeCetteQuantite(theColor,5000);

      RGBForeColor(theColor);
      RGBBackColor(theColor);

      FrameRect(whichRect);
    end;

  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);

  (*
  if (trait = pionNoir)
    then WritelnNumDansRapport('DessineCouleurDeZebraBookDansRect : trait = noir, valeur = ',valeur)
    else WritelnNumDansRapport('DessineCouleurDeZebraBookDansRect : trait = blanc, valeur = ',valeur);
  *)
end;





procedure DessineOmbreRoundRect(theRect : rect; ovalWidth,ovalHeight : SInt16; targetColor : RGBColor; tailleOmbre,forceDuGradient,ombrageMinimum,typeOmbrage : SInt32);
var ombre : rect;
    i,force : SInt32;
begin

  PenMode(patCopy);
  PenSize(1,1);

  for i := tailleOmbre downto 2 do
    begin

      with theRect do
        ombre := MakeRect(left {+ 4*(i div 4)}, top {+ 4*(i div 4)} , right + i , bottom + i);

        case (typeOmbrage mod 4) of
          0 : force := (tailleOmbre-i)*(forceDuGradient div 4);
          1 : force := ombrageMinimum + (tailleOmbre-i)*forceDuGradient;
          2 : force := (ombrageMinimum div 4 + (tailleOmbre-i)*forceDuGradient) div 4;
          3 : force := (tailleOmbre-i)*forceDuGradient div 4;
        end; {case}

        if (typeOmbrage >= 4) {legerement en creux}
          then
            begin
              RGBForeColor(EclaircirCouleurDeCetteQuantite(targetColor,force));
              RGBBackColor(EclaircirCouleurDeCetteQuantite(targetColor,force));
            end
          else
            begin
              RGBForeColor(NoircirCouleurDeCetteQuantite(targetColor,force));
              RGBBackColor(NoircirCouleurDeCetteQuantite(targetColor,force));
            end;

        FrameRoundRect(ombre,ovalWidth,ovalHeight);
        if tailleOmbre > 2 then
          begin
            dec(ombre.right);
            FrameRoundRect(ombre,ovalWidth,ovalHeight);
          end;

    end;

  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
  PenSize(1,1);
end;




END.



