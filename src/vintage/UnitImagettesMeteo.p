UNIT UnitImagettesMeteo;




INTERFACE







 USES UnitDefCassio , QuickDraw;




function GetCheminAccesImagette(quelleImage : typeImagette; var CheminAccesImagette : String255; var numeroDuFichierImage : SInt16) : boolean;                                      ATTRIBUTE_NAME('GetCheminAccesImagette')
procedure DrawImagetteMeteo(quelleImage : typeImagette; whichWindow : WindowPtr; whichBounds : rect; fonctionAppelante : String255);                                                ATTRIBUTE_NAME('DrawImagetteMeteo')
procedure DrawImagetteMeteoOnSquare(quelleImage : typeImagette; quelleCase : SInt16);                                                                                               ATTRIBUTE_NAME('DrawImagetteMeteoOnSquare')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitFichierPhotos, UnitHTML, UnitRapport, UnitBufferedPICT, UnitFichiersTEXT, UnitAffichagePlateau, MyStrings
     ;
{$ELSEC}
    ;
    {$I prelink/ImagettesMeteo.lk}
{$ENDC}


{END_USE_CLAUSE}











function GetCheminAccesImagette(quelleImage : typeImagette; var CheminAccesImagette : String255; var numeroDuFichierImage : SInt16) : boolean;
var s : String255;
    i : SInt16;
begin
  s := 'aucune imagettersgsgdvdghfsdghfdsg';

  case quelleImage of
    kAlertSmall        : s := 'Small:Alert.png';
    kAlertBig          : s := 'Big:Alert.png';
    kSunCloudSmall     : s := 'Small:Sun-Cloud-1.png';
    kSunCloudBig       : s := 'Big:Sun-Cloud-1.png';
    kSunSmall          : s := 'Small:Sun.png';
    kSunBig            : s := 'Big:Sun.png';
    kThunderstormSmall : s := 'Small:Thunderstorm.png';
    kThunderstormBig   : s := 'Big:Thunderstorm.png';
    kUnknownSmall      : s := 'Small:Unknown.png';
    kUnknownBig        : s := 'Big:Unknown.png';
  end; {case}

  // D'abord on cherche un PNG ...

  with gFichiersPicture do
    begin
      for i := 1 to nbFichiers do
        with fic[i] do
          if (typeFichier = kFichierPictureMeteo) &
             (nomComplet <> NIL) &
             (Pos(s,nomComplet^) > 0) then
           begin
             GetCheminAccesImagette := true; // trouvée :-)
             numeroDuFichierImage   := i;
             CheminAccesImagette    := nomComplet^;
             exit(GetCheminAccesImagette);
           end;
    end;

  // si on n'a pas trouvé l'imagette sous forme d'un PNG ,
  // c'est peut-être que l'on a une vielle version de Cassio
  // qui utilisait les TIFF (moins efficaces à afficher).
  // On cherche donc un .tiff ...

  s := ReplaceStringByStringInString('.png', '.tiff', s);
  with gFichiersPicture do
    begin
      for i := 1 to nbFichiers do
        with fic[i] do
          if (typeFichier = kFichierPictureMeteo) &
             (nomComplet <> NIL) &
             (Pos(s,nomComplet^) > 0) then
           begin
             GetCheminAccesImagette := true; // trouvée :-)
             numeroDuFichierImage   := i;
             CheminAccesImagette    := nomComplet^;
             exit(GetCheminAccesImagette);
           end;
    end;


  {sinon : non trouvée :-(  }

  GetCheminAccesImagette := false;
  numeroDuFichierImage   := 0;
  CheminAccesImagette    := s;
end;


procedure DrawImagetteMeteo(quelleImage : typeImagette; whichWindow : WindowPtr; whichBounds : rect; fonctionAppelante : String255);
var path : String255;
    numeroImage : SInt16;
    fic : FichierTEXT;
    erreurES : OSErr;
begin {$UNUSED fonctionAppelante}
  if GetCheminAccesImagette(quelleImage,path,numeroImage) then
    begin
      {WritelnStringDansRapport('path = '+ path+', fonctionAppelante = '+fonctionAppelante);}
      erreurES := FichierTexteExiste(path,0,fic);
      if (erreurES = NoErr) & (whichWindow <> NIL) then
        QTGraph_ShowImageWithTransparenceFromFile(GetWindowPort(whichWindow),gPurNoir,whichBounds,fic.theFSSpec);
    end;
end;



procedure DrawImagetteMeteoOnSquare(quelleImage : typeImagette; quelleCase : SInt16);
var bounds : rect;
    largeur,hauteur : SInt32;
begin
  if (quelleCase >= 11) & (quelleCase <= 88) then
    begin
      bounds := GetBoundingRectOfSquare(quelleCase);
      largeur := bounds.right - bounds.left;
      hauteur := bounds.bottom - bounds.top;
      OffsetRect(bounds,(largeur div 3) - 2,hauteur div 3);
      DrawImagetteMeteo(quelleImage,wPlateauPtr,bounds,'DrawImagetteMeteoOnSquare');
      InvalidateDessinEnTraceDeRayon(quelleCase);
		  SetOthellierEstSale(quelleCase,true);
    end;
end;




















END.
