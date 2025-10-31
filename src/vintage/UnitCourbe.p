UNIT UnitCourbe;



INTERFACE







 USES UnitDefCassio;



{ Initialisation de l'unite }
procedure InitUnitCourbe;
procedure LibereMemoireUnitCourbe;


{ fonctions elementaires de dessin pour la courbe }
procedure BeginDrawingCourbe(const fonctionAppelante : String255);
procedure EndDrawingCourbe(const fonctionAppelante : String255);
procedure DetermineRectanglesActifsFenetreCourbe(whichDrawingRect : rect);
function FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen : boolean;
function HauteurCourbe : SInt32;
function LargeurCourbe : SInt32;
procedure EraseRectFenetreCourbe(myRect : rect);
procedure EraseRectDansZoneGriseDeLaCourbe(myRect : rect);
procedure EraseZoneGriseDansCourbe;
procedure DessineTrapezeCouleurDansCourbe(x1,x2 : Point; mil : SInt32; coloration : typeColorationCourbe);


{Le repere}
procedure DessineRepereCourbe(fonctionAppelante : String255);
procedure DessineLignesDeHauteurDuRepereDansCourbe(coupDepart,coupArrivee : SInt32; const fonctionAppelante : String255);


{ Effacage de la courbe }
procedure EffaceCourbe(n,nfin : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255);
procedure EffacerTouteLaCourbe(fonctionAppelante : String255);


{ Dessin de la courbe }
procedure TraceSegmentCourbeSansDessinerLeRepere(numeroDuCoup : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255; var regionEffacee : rect);
procedure TraceSegmentCourbe(numeroDuCoup : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255);
procedure DessineCourbe(coloration : typeColorationCourbe; fonctionAppelante : String255);


{ procedures de gestion des valeurs de la courbe }
procedure ViderValeursDeLaCourbe;
procedure InvalidateEvaluationPourCourbe(nroCoupMin,nroCoupMax : SInt32);
procedure SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32; flag : boolean);
procedure SetEvaluationPourCourbeDejaConnue(nroDuCoup : SInt32; flag : boolean);
procedure SetEvaluationPourNoirDansCourbe(nroDuCoup,evaluationPourNoir : SInt32; origine : typeGenreDeReflexion);
procedure SetCourbeEstContinueEnCePoint(nroDuCoup : SInt32; quelCote : typeLateralisationContinuite; flag : boolean);
procedure SetCourbeDoitEtreEffacee(nroDuCoup : SInt32; flag : boolean);
procedure MetScorePrevuParFinaleDansCourbe(nroCoupDeb,nroCoupFin : SInt32; origine : typeGenreDeReflexion; scorePourNoir : SInt32);
procedure EssaieMettreEvaluationDeMilieuDansCourbe(square,couleur,numeroDuCoup : SInt32; const position : plateauOthello; nbreBlancs,nbreNoirs : SInt32; var jouables : plBool; var frontiere : InfoFront);
function PeutCopierEndgameScoreFromGameTreeDansCourbe(G : GameTree; nroDuCoup : SInt32; origineCherchees : SetOfGenreDeReflexion) : boolean;


{ Fonctions d'acces aux valeurs de la courbe }
function GetEvaluationPourNoirDansCourbe(nroDuCoup : SInt32) : SInt32;
function GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroDuCoup : SInt32) : SInt32;
function EvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32) : boolean;
function EvaluationPourCourbeDejaConnue(nroDuCoup : SInt32) : boolean;
function GetOrigineEvaluationDansCourbe(nroDuCoup : SInt32) : typeGenreDeReflexion;
function CourbeEstContinueEnCePoint(nroDuCoup : SInt32; quelCote : typeLateralisationContinuite) : boolean;
function CourbeDoitEtreEffacee(nroDuCoup : SInt32) : boolean;


{ Gestion des evenements dans la fenetre de la courbe }
procedure TraiteSourisCourbe(evt : eventRecord);
procedure TraiteClicSurSliderCourbe(mouseLoc : Point);
function TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseGlobalLoc : Point) : boolean;
function EstUnClicSurSliderCourbe(mouseLoc : Point) : boolean;
procedure InvalidatePositionSourisFntreCourbe;


{ Gestion de la barre horizontale }
procedure DessineSliderFenetreCourbe;
function NroDeCoupEnPositionSurCourbe(nro : SInt32) : SInt32;
function NroDeCoupEnPositionDeSliderCourbe(nro : SInt32) : SInt32;
function PositionSourisEnNumeroDeCoupSurCourbe(positionX : SInt32) : SInt32;
function PositionSourisEnNumeroDeCoupSurSlider(positionX : SInt32) : SInt32;


{ Gestion des commentaires sur la premiere ligne }
procedure EffaceCommentaireCourbe;
procedure EcritCommentaireCourbe(nroCoup : SInt32);
procedure SetDoitEcrireCommentaireCourbe(flag : boolean);
function DoitEcrireCommentaireCourbe : boolean;


{ Gestion du buffer pour fabriquer une courbe plus jolie }
procedure SetUseOffscreenCourbe(flag : boolean);
function GetUseOffscreenCourbe : boolean;


{ Gestion de l'image en arriere plan }
function  CassioIsUtiliseImageDeFondPourLaCourbe : boolean;
procedure CreerImageDeFondPourCourbeSiNecessaire;
procedure CreerFichierCacheImageDeFondPourCourbe;
function PeutChargerImageDeFondPourCourbeDepuisLeDisque : boolean;
function PeutChargerImageDeFondPourCourbeDepuisLeCache : boolean;
function NomDuFichierCachePourImageDeFondCourbe : String255;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, fp, MacErrors, ControlDefinitions, QDOffScreen, QuickdrawText, MacWindows, Fonts
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw
    , UnitCarbonisation, MyMathUtils, UnitRapport, MyStrings, UnitCurseur, UnitGameTree, UnitNormalisation, UnitCouleur
    , UnitGeometrie, UnitBallade, UnitScannerUtils, UnitEvaluation, UnitSuperviseur, UnitFenetres, UnitJeu, UnitOffScreenGraphics
    , MyAntialiasing, SNEvents, UnitRetrograde, UnitServicesMemoire, UnitModes, EdmondEvaluation, UnitNouvelleEval
    , basicfile, UnitHTML, MyFileSystemUtils ;
{$ELSEC}
    ;
    {$I prelink/Courbe.lk}
{$ENDC}


{END_USE_CLAUSE}




TYPE
   t_listeEval = array[0..65] of
                   record
                     evalNoir             : SInt32;
                     origineEval          : typeGenreDeReflexion;
                     evalCourbeDejaConnue : boolean;
                     evalDonneeParFinale  : boolean;
                     continueADroite      : boolean;
                     continueAGauche      : boolean;
                     doitEtreEffacee      : boolean;
                   end;


   CourbeDataRec  =
                 record
                   premierSegmentDessine     : SInt32;
                   dernierSegmentDessine     : SInt32;
                   niveauxRecursionDrawing   : SInt32;
                   dernierCommentaireAffiche : SInt32;
                   premierCoupSansEvaluation : SInt32;
                   margeZoneGrise            : SInt32;
                   canvasRect                : rect;
                   courbeRect                : rect;
                   sliderRect                : rect;
                   zoneSensibleSlider        : rect;
                   zoneGriseRect             : rect;
                   commentaireRect           : rect;
                   lastMouseLocUtilisee      : Point;
                   ecrireCommentaire         : boolean;
                   usingOffScreenBuffer      : array[0..199] of boolean;  // 200 niveaux de recursion possibles
                   dernierTickCommentaire    : SInt32;
                   listeEvaluations          : t_listeEval;
                   magicCookieLastChangeEval : SInt32;
                 end;

var gCourbeData : CourbeDataRec;
    gCopieCourbeData : CourbeDataRec;

    gOffScreenCourbeWorld : GWorldPtr;
    gOffScreenCourbeRect : rect;
    gOffScreenZoneGrise : rect;
    gUseOffScreenCourbe : boolean;

    gCourbeBackground : record
                          useImageForBackground     : boolean;
                          courbeWindowRectLastCheck : Rect;
                          offScreenRect             : Rect;
                          offScreenWorld            : GWorldPtr;
                          couleurRepere             : RGBColor;
                        end;


CONST
  kMargeDeplacementZoneGriseCourbe = 20;
  kPetiteMargeDansZoneGrise = 3;



procedure InitUnitCourbe;
var GWorldPixMapHdl : PixMapHandle;
    lockPixResult : boolean;
    k : SInt32;
begin
  with gCourbeData do
    begin
      premierSegmentDessine     := 0;
      dernierSegmentDessine     := 0;
      niveauxRecursionDrawing   := 0;
      premierCoupSansEvaluation := 0;
      margeZoneGrise            := 0;
      canvasRect                := MakeRect(0,0,0,0);
      courbeRect                := MakeRect(0,0,0,0);
      sliderRect                := MakeRect(0,0,0,0);
      zoneSensibleSlider        := MakeRect(0,0,0,0);
      zoneGriseRect             := MakeRect(0,0,0,0);
      lastMouseLocUtilisee      := MakePoint(-1000,-1000);
      magicCookieLastChangeEval := 0;
      for k := 0 to 61 do
         SetCourbeDoitEtreEffacee(k,true);
    end;
  SetDoitEcrireCommentaireCourbe(true);


  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
  gOffScreenCourbeRect := MakeRect(0,0,1980,840);
  {$ELSEC}
  gOffScreenCourbeRect := MakeRect(0,0,1020,420);
  {$ENDC}

  gUseOffScreenCourbe := (CreateTempOffScreenWorld(gOffScreenCourbeRect,gOffScreenCourbeWorld) = NoErr);
  if gUseOffScreenCourbe then
    begin
      GWorldPixMapHdl := GetGWorldPixMap(gOffScreenCourbeWorld);
      lockPixResult   := LockPixels(GWorldPixMapHdl);
    end;
  {gUseOffScreenCourbe := false;}


  gCourbeBackground.useImageForBackground     := true;
  gCourbeBackground.offScreenRect             := MakeRect(0,0,0,0);
  gCourbeBackground.courbeWindowRectLastCheck := MakeRect(0,0,0,0);
  gCourbeBackground.offScreenWorld            := NIL;
  SetRGBColor(gCourbeBackground.couleurRepere,18000,15500,24700);

end;


procedure LibereMemoireUnitCourbe;
begin
  KillTempOffscreenWorld(gOffScreenCourbeWorld);
end;

(*
procedure CopyCourbeData(var source, dest : CourbeDataRec);
begin
  dest.margeZoneGrise            := source.margeZoneGrise;
  dest.canvasRect                := source.canvasRect;
  dest.courbeRect                := source.courbeRect;
  dest.sliderRect                := source.sliderRect;
  dest.zoneSensibleSlider        := source.zoneSensibleSlider;
  dest.zoneGriseRect             := source.zoneGriseRect;
  dest.commentaireRect           := source.commentaireRect;
end;
*)

procedure ViderValeursDeLaCourbe;
begin
  with gCourbeData do
    begin
      MemoryFillChar(@listeEvaluations,sizeof(listeEvaluations),chr(0));
      premierCoupSansEvaluation := 0;
      {WritelnNumDansRapport('ViderValeursDeLaCourbe : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
    end;
end;


function HauteurCourbe : SInt32;
begin
  with gCourbeData.courbeRect do
    HauteurCourbe := bottom - top;
end;


function LargeurCourbe : SInt32;
begin
  with gCourbeData.courbeRect do
    LargeurCourbe := right - left;
end;


procedure DetermineRectanglesActifsFenetreCourbe(whichDrawingRect : rect);
var decalagePourPetiteFenetre : SInt32;
begin

  with gCourbeData do
    begin
      canvasRect := whichDrawingRect;

      margeZoneGrise  := Min(kMargeDeplacementZoneGriseCourbe,
                              Max((canvasRect.right-canvasRect.left) div 30, (canvasRect.bottom-canvasRect.top) div 14 ));

      if margeZoneGrise < 10 then decalagePourPetiteFenetre := 4 else
      if margeZoneGrise < 15 then decalagePourPetiteFenetre := 2 else
      decalagePourPetiteFenetre := 0;

      courbeRect      := MakeRect(canvasRect.left + margeZoneGrise,
                                  canvasRect.top + margeZoneGrise,
                                  canvasRect.right - margeZoneGrise - 2,
                                  canvasRect.bottom - 40 + decalagePourPetiteFenetre);
      sliderRect      := MakeRect(canvasRect.left + margeZoneGrise - 6,
                                  courbeRect.bottom + 14 - decalagePourPetiteFenetre,
                                  canvasRect.right - margeZoneGrise + 8,
                                  courbeRect.bottom + 20  - decalagePourPetiteFenetre);
      zoneGriseRect   := MakeRect(kPetiteMargeDansZoneGrise + margeZoneGrise,
                                  0+margeZoneGrise,
                                  LargeurCourbe+margeZoneGrise,
                                  HauteurCourbe+margeZoneGrise);
      commentaireRect := MakeRect(margeZoneGrise - 10 ,
                                  Min(18,margeZoneGrise) - 13 ,
                                  canvasRect.right ,
                                  Min(18,margeZoneGrise));

      zoneSensibleSlider := sliderRect;

      InSetRect(zoneSensibleSlider, -20, -20);
    end;
end;


function FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen : boolean;
var theRect : rect;
begin
  if windowCourbeOpen
    then
      begin
        theRect := GetWindowContentRect(wCourbePtr);
        FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen :=
             (theRect.bottom - theRect.top <= 400) or
             ((theRect.bottom - theRect.top <= 330) and (theRect.right - theRect.left <= 700));
      end
    else
      FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen := false;
end;



procedure EraseRectFenetreCourbe(myRect : rect);
begin
  MyEraseRect(myRect);
end;



procedure EraseRectDansZoneGriseDeLaCourbe(myRect : rect);
var currentPort : grafPtr;
begin
  if CassioIsUtiliseImageDeFondPourLaCourbe
      then
        begin
          GetPort(currentPort);
          RGBForeColor(gPurNoir);
          RGBBackColor(gPurBlanc);
          DumpWorkToScreen(myRect,myRect,gCourbeBackground.offScreenWorld,currentPort);
        end
      else
        begin
        	RGBForeColor(gPurGrisClair);
          FillRect(myRect, blackPattern);
          RGBForeColor(gPurNoir);
        end;

	MyEraseRectWithColor(myRect,BleuCmd,blackPattern,'EraseRectDansZoneGriseDeLaCourbe');
end;


procedure EraseZoneGriseDansCourbe;
var myRect : rect;
    oldPort : grafPtr;
begin
  myRect := gCourbeData.zoneGriseRect;
  inc(myRect.right);

  GetPort(oldPort);

  EraseRectDansZoneGriseDeLaCourbe(myRect);
  DessineLignesDeHauteurDuRepereDansCourbe(0, 60, 'EraseZoneGriseDansCourbe');

  SetPort(oldPort);
end;


procedure BeginDrawingCourbe(const fonctionAppelante : String255);
begin
  with gCourbeData do
    begin
      SetPortByWindow(wCourbePtr);
      DetermineRectanglesActifsFenetreCourbe(QDGetPortBound);

      usingOffScreenBuffer[niveauxRecursionDrawing] := false;

      if gUseOffScreenCourbe and
         (Pos('Repere',fonctionAppelante) = 0) and
         FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen
        then
          begin

            SetGWorld(gOffScreenCourbeWorld, NIL);
            DetermineRectanglesActifsFenetreCourbe(gOffScreenCourbeRect);
            gOffScreenZoneGrise := gCourbeData.zoneGriseRect;


            usingOffScreenBuffer[niveauxRecursionDrawing] := true;
          end;


      // WritelnNumDansRapport('BeginDrawingCourbe ('+fonctionAppelante+'), niveau = ',niveauxRecursionDrawing);


      inc(niveauxRecursionDrawing);
    end;
end;


procedure EndDrawingCourbe(const fonctionAppelante : String255);
begin
  with gCourbeData do
    begin

      dec(niveauxRecursionDrawing);



      if (niveauxRecursionDrawing = 0) and
        gUseOffScreenCourbe and
        usingOffScreenBuffer[niveauxRecursionDrawing] and
        (Pos('Repere',fonctionAppelante) = 0) {and
        (not(EnTrainDeRejouerUnePartie) or (nbreCoup mod 10 = 0))}
        then
          begin

            SetPortByWindow(wCourbePtr);

            DetermineRectanglesActifsFenetreCourbe(QDGetPortBound);

            RGBForeColor(gPurNoir);
            RGBBackColor(gPurBlanc);
            ForeColor(BlackColor);
            BackColor(WhiteColor);


            SetGWorld(gOffScreenCourbeWorld, NIL);

            RGBForeColor(gPurNoir);
            RGBBackColor(gPurBlanc);
            ForeColor(BlackColor);
            BackColor(WhiteColor);


            SetPortByWindow(wCourbePtr);


            CopyBits(GetPortBitMapForCopyBits(gOffScreenCourbeWorld)^ ,
                     GetPortBitMapForCopyBits(GetWindowPort(wCourbePtr))^ ,
  			             gOffScreenZoneGrise, gCourbeData.zoneGriseRect, ditherCopy {+ srcCopy}, NIL);

  			    // WritelnDansRapport('COPYBITS !!');


          end;

      if (Pos('Repere',fonctionAppelante) > 0)
        then
          begin

            SetPortByWindow(wCourbePtr);
            DetermineRectanglesActifsFenetreCourbe(QDGetPortBound);

            if EnTrainDeRejouerUnePartie then FlushWindow(wCourbePtr);

          end;


      // WriteNumDansRapport('EndDrawingCourbe ('+fonctionAppelante+'), niveau = ',niveauxRecursionDrawing);
      // WritelnStringAndBoolDansRapport('  usingOffScreenBuffer['+IntToStr(niveauxRecursionDrawing)+'] = ',usingOffScreenBuffer[niveauxRecursionDrawing]);


    end;
end;



procedure WriteDebugageCourbe(s : String255);
begin
  Discard(s);
  // WritelnDansRapport(s);
end;


procedure DessineLignesDeHauteurDuRepereDansCourbe(coupDepart,coupArrivee : SInt32; const fonctionAppelante : String255);
var echelle : double;
    marge,i,note : SInt32;
    x1,x2,y,largeur,haut,mil : SInt32;
    theColor : RGBColor;
begin
  Discard(fonctionAppelante);

  if windowCourbeOpen then
    with gCourbeData do
    begin

      marge := kPetiteMargeDansZoneGrise;
      haut := HauteurCourbe;
      mil := margeZoneGrise + haut div 2 - 1;
      largeur := LargeurCourbe - marge;
      echelle := 1.0*(mil-margeZoneGrise)/4000.0;
      largeur := LargeurCourbe - marge;

      PenSize(1,1);
      PenPat(blackPattern);

      if CassioIsUtiliseImageDeFondPourLaCourbe
        then
          begin
            SetRGBColor(theColor,49600,49600,34200);
            RGBForeColor(theColor);
            if coupDepart  < 1 then coupDepart   := 1;
            if coupArrivee > 59 then coupArrivee := 59;
          end
        else
          begin
            if FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen
              then RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurGrisFonce,21500))
              else RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurGrisFonce,31500));
          end;

      { dessin des traits horizontaux }

      for i := 1 to 4 do
        begin
          note := i * 10 * kCoeffMultiplicateurPourCourbeEnFinale;

          x1 := margeZoneGrise + marge + ((coupDepart*largeur) div 60);
          x2 := margeZoneGrise + marge + ((coupArrivee*largeur) div 60);

          if (coupArrivee = 60) then dec(x2);

          y := Trunc(mil - note*echelle);
          Moveto(x1 + 1, y);
          Lineto(x2, y);

          y := Trunc(mil + note*echelle + 1);
          Moveto(x1 + 1, y);
          Lineto(x2, y);

        end;

    end;

end;


procedure DessineRepereCourbeSansSetPort;
var x,largeur,haut,mil : SInt32;
    marge,i,n : SInt32;
    s : String255;
begin
  if windowCourbeOpen then
    with gCourbeData do
    begin

      marge := kPetiteMargeDansZoneGrise;
      haut := HauteurCourbe;
      mil := margeZoneGrise + haut div 2 - 1;
      largeur := LargeurCourbe - marge;
      PenSize(1,1);
      PenPat(blackPattern);

      if CassioIsUtiliseImageDeFondPourLaCourbe
        then RGBForeColor(gPurGris)
        else RGBForeColor(gPurGrisFonce);


      { dessin de l'axe horizontal et de la fleche de droite}
      Moveto(margeZoneGrise + marge, mil);
      Lineto(margeZoneGrise + largeur + marge, mil);
      Lineto(margeZoneGrise + largeur + marge - 3, mil+3);
      Moveto(margeZoneGrise + largeur + marge , mil);
      Lineto(margeZoneGrise + largeur + marge - 3, mil-3);

      { dessin de l'axe vertical et des deux fleches }
      if CassioIsUtiliseImageDeFondPourLaCourbe then RGBForeColor(gPurGrisClair);

      Moveto(margeZoneGrise + marge-3,margeZoneGrise + haut-5);
      Lineto(margeZoneGrise + marge,margeZoneGrise + haut-2);
      Moveto(margeZoneGrise + marge+3,margeZoneGrise + haut-5);
      Lineto(margeZoneGrise + marge,margeZoneGrise + haut-2);
      Lineto(margeZoneGrise + marge,margeZoneGrise + 2);
      Lineto(margeZoneGrise + marge+3,margeZoneGrise + 5);
      Moveto(margeZoneGrise + marge,margeZoneGrise + 2);
      Lineto(margeZoneGrise + marge-3,margeZoneGrise + 5);



      RGBForeColor(gPurNoir);

      TextMode(1);
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      s := ReadStringFromRessource(TextesCourbeID,1);
      Moveto(margeZoneGrise + marge + 14, margeZoneGrise + Min(35, haut div 5));
      if s = 'bon pour Noir'
        then
          begin
            TextFace(normal);
            MyDrawString('bon pour ');
            TextFace(bold);
            MyDrawString('Noir');
          end
        else
          MyDrawString(s);
      s := ReadStringFromRessource(TextesCourbeID,2);
      Moveto(margeZoneGrise + marge + 14, margeZoneGrise + haut - (Min(35, haut div 5)) + 7);
      if s = 'bon pour Blanc'
        then
          begin
            TextFace(normal);
            MyDrawString('bon pour ');
            TextFace(bold);
            MyDrawString('Blanc');
            TextMode(1);
          end
        else
          MyDrawString(s);


      { dessin des graduations de l'axe horizontal }

      TextFont(gCassioApplicationFont);
      TextFace(normal);
      s := ReadStringFromRessource(TextesCourbeID,3);  {'coup'}
      Moveto(margeZoneGrise + marge + largeur - MyStringWidth(s) - 1, mil + 10);
      if (58 > nroDernierCoupAtteint)
        then RGBForeColor(gPurGris)
        else RGBForeColor(gPurNoir);
      MyDrawString(s);

      for i := 1 to 5 do
        begin
          n := 10*i;
          s := IntToStr(n);
          x := margeZoneGrise + marge + ((n*largeur) div 60);

          if (n > nroDernierCoupAtteint)
             then RGBForeColor(gPurGris)
             else RGBForeColor(gPurNoir);
          Moveto(x,mil-2);
          Lineto(x,mil+2);
          Moveto(x-6,mil+11);
          MyDrawString(s);
        end;
      RGBForeColor(gPurNoir);

    end;
end;


procedure DessineRepereCourbe(fonctionAppelante : String255);
var oldport : grafPtr;
    err : OSErr;
begin  {$UNUSED fonctionAppelante}
  if windowCourbeOpen then
    with gCourbeData do
    begin
      WriteDebugageCourbe(IntToStr(nbreCoup)+' : DessineRepereCourbe, fonction appelante = '+fonctionAppelante);

      GetPort(oldport);

      SetPortByWindow(wCourbePtr);
      if gCassioUseQuartzAntialiasing then
        if gUseOffScreenCourbe and FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen
          then
            begin
              err := SetAntiAliasedTextEnabled(true,9);
              EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true);
            end
          else
            begin
              err := SetAntiAliasedTextEnabled(false,9);
              DisableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr));
            end;

      BeginDrawingCourbe('DessineRepereCourbe');

      DessineRepereCourbeSansSetPort;

      EndDrawingCourbe('DessineRepereCourbe');

      { effacer a droite du fond gris }
	    EraseRectFenetreCourbe(MakeRect(zoneGriseRect.right+1,zoneGriseRect.top,zoneGriseRect.right + 10, zoneGriseRect.bottom));
	    //MyEraseRectWithColor(MakeRect(zoneGriseRect.right+1,zoneGriseRect.top,zoneGriseRect.right + 10, zoneGriseRect.bottom),BleuCmd,blackPattern,'DessineRepereCourbe');


      SetPortByWindow(wCourbePtr);
      if gCassioUseQuartzAntialiasing then
        begin
          err := SetAntiAliasedTextEnabled(true,9);
          EnableQuartzAntiAliasingThisPort(GetWindowPort(wCourbePtr),true);
        end;

      SetPort(oldport);
    end;
end;


procedure CheckDoitEffacerLaCourbe(fonctionAppelante : String255);
var k, debut,fin : SInt32;
    largeur,haut,mil : SInt32;
    unRect : rect;
    marge : SInt32;
begin
  debut := 1000;
  fin := -1000;
  with gCourbeData do
    begin
      for k := 0 to 60 do
        begin
          if CourbeDoitEtreEffacee(k) then
            begin
              if k < debut then debut := k;
              if k > fin then fin := k;
              listeEvaluations[k].doitEtreEffacee := false;
            end;
        end;
      if windowCourbeOpen and (debut < 1000) and (fin > -1000) then
        begin
          // WritelnDansRapport('CheckDoitEffacerLaCourbe = TRUE, fonctionAppelante = ' + fonctionAppelante);

          marge := kPetiteMargeDansZoneGrise;
          haut := HauteurCourbe;
          mil := margeZoneGrise + haut div 2 - 1;
          largeur := LargeurCourbe - marge;
          SetRect(unRect,margeZoneGrise + marge + ((debut*largeur) div 60) + 1,
                         margeZoneGrise,
                         margeZoneGrise + marge + ((Min(60,fin)*largeur) div 60) + 1,
                         margeZoneGrise + haut);
          EraseRectDansZoneGriseDeLaCourbe(unRect);

          DessineLignesDeHauteurDuRepereDansCourbe(debut, fin, fonctionAppelante + '->CheckDoitEffacerLaCourbe');
        end;
    end;
end;

{passer n = kEffacerTouteLaCourbe pour effacer toute la courbe}
procedure EffaceCourbe(n,nfin : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255);
var largeur,haut,mil : SInt32;
    oldport : grafPtr;
    unRect : rect;
    marge,i : SInt32;
    effRect,accu : rect;
begin
  if windowCourbeOpen then
    with gCourbeData do
    begin
      WriteDebugageCourbe(IntToStr(nbreCoup)+' : EffaceCourbe['+IntToStr(n)+','+IntToStr(nfin)+'], fonction appelante = '+fonctionAppelante);

      GetPort(oldport);
      BeginDrawingCourbe('EffaceCourbe');


      if (n = kTouteLaCourbe)
        then
          begin
            DessineBoiteDeTaille(wCourbePtr);
            EraseZoneGriseDansCourbe;
          end
        else
         begin
           marge := kPetiteMargeDansZoneGrise;

           haut := HauteurCourbe;
           mil := margeZoneGrise + haut div 2 - 1;
           largeur := LargeurCourbe - marge;

           SetRect(unRect,margeZoneGrise + marge + ((n*largeur) div 60) + 1,
                          margeZoneGrise,
                          margeZoneGrise + marge + ((Min(60,nfin)*largeur) div 60) + 1,
                          margeZoneGrise + haut);




           {if (nfin >= 60) then inc(unRect.right);}
           EraseRectDansZoneGriseDeLaCourbe(unRect);
           {ClipRect(unRect);}

           case coloration of
             kEffacerCourbe :
               begin
                 {DessineRepereCourbe(fonctionAppelante+'->EffaceCourbe(2)->');}
               end;
             kEffacerCourbeSansDessinerLeRepere :
               begin
                 { do nothing... }
               end;
             kCourbePastel :
               begin
                 accu := MakeRect(0,0,0,0);

                 {for i := n to nroDernierCoupAtteint do
                   WritelnStringAndBoolDansRapport(IntToStr(nbreCoup)+' (pre) : continue['+IntToStr(i)+'] = ',CourbeEstContinueEnCePoint(i,kGlobalement));}

                 i := n+1;
                 repeat
                   if (i <= nroDernierCoupAtteint) then
                     begin
                       TraceSegmentCourbeSansDessinerLeRepere(i,kCourbePastel,fonctionAppelante+'->EffaceCourbe{3}->',effRect);
                       UnionRect(accu,effRect,accu);
                     end;
                   i := i+1;
                 until (i > nroDernierCoupAtteint) or
                       ((i > nfin + 2) and CourbeEstContinueEnCePoint(i,kGlobalement));

                 {for i := n to nroDernierCoupAtteint do
                   WritelnStringAndBoolDansRapport(IntToStr(nbreCoup)+' (post) : continue['+IntToStr(i)+'] = ',CourbeEstContinueEnCePoint(i,kGlobalement));}

               end;
           end; {case}


           if unRect.right >= canvasRect.right-15 then DessineBoiteDeTaille(wCourbePtr);
           {ClipRect(canvasRect);}
         end;


      EndDrawingCourbe('EffaceCourbe');

      DessineRepereCourbe(fonctionAppelante+'->EffaceCourbe{1}->');



      SetPort(oldport);
    end;
end;


procedure EffacerTouteLaCourbe(fonctionAppelante : String255);
begin
  WriteDebugageCourbe(IntToStr(nbreCoup)+' : EffacerTouteLaCourbe, fonction appelante = '+fonctionAppelante);
  if windowCourbeOpen then
    EffaceCourbe(kTouteLaCourbe,kTouteLaCourbe,kEffacerCourbe,fonctionAppelante+'->EffacerTouteLaCourbe');

  with gCourbeData do
    begin
      premierSegmentDessine := 0;
      dernierSegmentDessine := 0;
    end;
end;





procedure DessineTrapezeCouleurDansCourbe(x1,x2 : Point; mil : SInt32; coloration : typeColorationCourbe);
const kLargeurMinimalePourRecursion = 2;
var x0,x3,pointDichotomie : Point;
    a,b : SInt32;
    myPoly : PolyHandle;
    myRGBColor : RGBColor;
    note : SInt32;
    echelle : double;
    isGoodForWhite : boolean;
begin
  {WriteDebugageCourbe(IntToStr(nbreCoup)+' : DessineTrapezeCouleurDansCourbe');}

  if windowCourbeOpen then
    with gCourbeData do
      BEGIN
        if ((x1.v <= mil) and (x2.v <= mil)) or ((x1.v >= mil) and (x2.v >= mil))
          then  {les deux points sont du meme cote de l'axe}
            begin


              if ((x2.h - x1.h) >= kLargeurMinimalePourRecursion) and (x1.v <> x2.v) (* and (coloration <> kCourbePastel) *)
                then { on coupe le trapeze en 2 pour avoir un joli dégradé }
                  begin
                    SetPt(pointDichotomie, (x1.h + x2.h) div 2, (x1.v + x2.v + 1) div 2);
                    DessineTrapezeCouleurDansCourbe(x1,pointDichotomie,mil,coloration);
                    DessineTrapezeCouleurDansCourbe(pointDichotomie,x2,mil,coloration);
                  end
                else
                  begin

          		      SetPt(x0,x1.h,mil);
          		      SetPt(x3,x2.h,mil);
          		
          		      (*if (coloration = kCourbePastel)
          		        then note := 0
          		        else *)
          		          begin
                		      echelle := (1.0*(mil-margeZoneGrise)/4000.0)/4.5;
                		      note := Abs(x1.v - mil) + Abs(x2.v - mil);
                		      note := Trunc(note/echelle) div kCoeffMultiplicateurPourCourbeEnFinale;
                		    end;
          		
          		      isGoodForWhite := (x2.v > mil) or ((x2.v = mil) and (x1.v > mil));

                    if (coloration = kCourbePastel)
                      then
                        begin
                          if isGoodForWhite
              		          then myRGBColor := EclaircirCouleurDeCetteQuantite(gPurGrisClair, 2000 + 10*note)
              		          else myRGBColor := EclaircirCouleurDeCetteQuantite(gPurGrisClair, 2000 - 20*note);
                        end
                      else
                        begin
                		      if isGoodForWhite
                		        then myRGBColor := GetCouleurAffichageValeurCourbe(pionBlanc,note)
                		        else myRGBColor := GetCouleurAffichageValeurCourbe(pionNoir,note);
                		
                		      (*
                		      if (coloration = kCourbePastel)
          		              then myRGBColor := EclaircirCouleurDeCetteQuantite(myRGBColor,40000);
          		            *)
                        end;

          		      RGBForeColor(myRGBColor);

          		      { creation du trapeze }

          		      myPoly := OpenPoly;
          		      Moveto(x0.h + 1, x0.v);
          		      Lineto(x1.h + 1, x1.v);
          		      Lineto(x2.h + 1, x2.v);
          		      Lineto(x3.h + 1, x3.v);
          		      ClosePoly;

          		      { coloriage du trapeze }

          		      FillPoly(myPoly,blackPattern);
          		      ForeColor(BlackColor);
          		      KillPoly(myPoly);

          		    end;
             end
           else  {les deux points sont de cotes differents de l'axe : dichotomie }
             begin
               Intersection(x1.h,x1.v,x2.h,x2.v,-1000,mil,1000,mil,a,b);
               SetPt(pointDichotomie,a,mil);
               DessineTrapezeCouleurDansCourbe(x1,pointDichotomie,mil,coloration);
               DessineTrapezeCouleurDansCourbe(pointDichotomie,x2,mil,coloration);
             end;
      END;
end;



procedure TraceQuelquesSegmentsDeLaCourbe(n : SInt32; coloration : typeColorationCourbe; var regionEffacee : rect);
var x,y : SInt32;
    largeur,haut,mil : SInt32;
    note : SInt32;
    oldport : grafPtr;
    echelle : double;
    marge : SInt32;
    x1,x2 : Point;
    unRect : rect;
begin
  if windowCourbeOpen and (n >= 1) and (n <= 60) and (n <= nroDernierCoupAtteint) then
    with gCourbeData do
      begin
        WriteDebugageCourbe(IntToStr(nbreCoup)+' : TraceQuelquesSegmentsDeLaCourbe('+IntToStr(n)+')');

        GetPort(oldport);
        BeginDrawingCourbe('TraceQuelquesSegmentsDeLaCourbe');

        CheckDoitEffacerLaCourbe('TraceQuelquesSegmentsDeLaCourbe');

        marge := kPetiteMargeDansZoneGrise;
        haut := HauteurCourbe;
        mil := margeZoneGrise + haut div 2 - 1;
        echelle := 1.0*(mil-margeZoneGrise)/4000.0;
        largeur := LargeurCourbe - marge;

        if (n = 1)
          then
            begin
              SetPt(x1,margeZoneGrise + marge,mil);
            end
          else
            begin
              if not(EvaluationPourCourbeProvientDeLaFinale(n-1))
                then note := (GetEvaluationPourNoirDansCourbe(n-2)+GetEvaluationPourNoirDansCourbe(n-1)) div 2
                else note := GetEvaluationPourNoirDansCourbe(n-1);
              x := margeZoneGrise + (((n-1)*largeur) div 60);
              y := Trunc(mil-note*echelle);
              if y < margeZoneGrise + 2      then y := margeZoneGrise + 2;
              if y > margeZoneGrise + haut-3 then y := margeZoneGrise + haut-3;
              SetPt(x1,marge+x,y);
             end;

        if not(EvaluationPourCourbeProvientDeLaFinale(n))
          then note := (GetEvaluationPourNoirDansCourbe(n-1)+GetEvaluationPourNoirDansCourbe(n)) div 2
          else note := GetEvaluationPourNoirDansCourbe(n);
        x := margeZoneGrise + ((n*largeur) div 60);
        y := Trunc(mil-note*echelle);
        if y < margeZoneGrise + 2      then y := margeZoneGrise + 2;
        if y > margeZoneGrise + haut-3 then y := margeZoneGrise + haut-3;
        SetPt(x2,marge+x,y);


        SetRect(unRect,margeZoneGrise + marge + (((n-1)*largeur) div 60) + 1,
                       margeZoneGrise + 0,
                       margeZoneGrise + marge + ((n*largeur) div 60) + 1,
                       margeZoneGrise + haut);
        if (n = nroDernierCoupAtteint) then inc(unRect.right);



        EraseRectDansZoneGriseDeLaCourbe(unRect);

        DessineLignesDeHauteurDuRepereDansCourbe(n-1, n, 'TraceQuelquesSegmentsDeLaCourbe');

        {ClipRect(unRect);}

        PenSize(1,1);

        if (n <= nbreCoup)
          then DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbeColoree)
          else DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbePastel);

        UnionRect(regionEffacee,unRect,regionEffacee);
        {ClipRect(canvasRect);}


        if (n > dernierSegmentDessine) then dernierSegmentDessine := n;
        if (n < premierSegmentDessine) then premierSegmentDessine := n;

        SetCourbeEstContinueEnCePoint(n-1,kADroite,true);
        SetCourbeEstContinueEnCePoint(n  ,kAGauche,true);


        if (n+1 <= nroDernierCoupAtteint) and not(CourbeEstContinueEnCePoint(n+1,kGlobalement))
          then TraceQuelquesSegmentsDeLaCourbe(n+1,coloration,regionEffacee);

        if (n-1 >= 1) and not(CourbeEstContinueEnCePoint(n-1,kGlobalement))
          then TraceQuelquesSegmentsDeLaCourbe(n-1,coloration,regionEffacee);

        PenSize(2,2);

        if CassioIsUtiliseImageDeFondPourLaCourbe
          then RGBForeColor(gPurBlanc)
          else
            if (n > nbreCoup)
              then RGBForeColor(gPurGrisFonce)
              else RGBForeColor(gPurNoir);

        PenPat(blackPattern);
        Moveto(x1.h,x1.v);
        Lineto(x2.h,x2.v);

        RGBForeColor(gPurNoir);

        EndDrawingCourbe('TraceQuelquesSegmentsDeLaCourbe');
        SetPort(oldport);
      end;
end;


procedure TraceSegmentCourbe(numeroDuCoup : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255);
var regionEffacee : rect;
begin
  WriteDebugageCourbe(IntToStr(nbreCoup)+' : TraceSegmentCourbe('+IntToStr(numeroDuCoup)+'), fonction appelante = '+fonctionAppelante);

  if windowCourbeOpen and (numeroDuCoup >= 1) and (numeroDuCoup <= 60) and (numeroDuCoup <= nroDernierCoupAtteint) then
    begin
      regionEffacee := MakeRect(0,0,0,0);

      TraceQuelquesSegmentsDeLaCourbe(numeroDuCoup,coloration,regionEffacee);

      DessineRepereCourbe(fonctionAppelante+'->TraceSegmentCourbe->');
    end;

end;


procedure TraceSegmentCourbeSansDessinerLeRepere(numeroDuCoup : SInt32; coloration : typeColorationCourbe; fonctionAppelante : String255; var regionEffacee : rect);
begin
  WriteDebugageCourbe(IntToStr(nbreCoup)+' : TraceSegmentCourbeSansDessinerLeRepere('+IntToStr(numeroDuCoup)+'), fonction appelante = '+fonctionAppelante);

  regionEffacee := MakeRect(0,0,0,0);

  if windowCourbeOpen and (numeroDuCoup >= 1) and (numeroDuCoup <= 60) and (numeroDuCoup <= nroDernierCoupAtteint) then
    TraceQuelquesSegmentsDeLaCourbe(numeroDuCoup,coloration,regionEffacee);
end;


procedure DessineCourbe(coloration : typeColorationCourbe; fonctionAppelante : String255);
var x,y : SInt32;
    largeur,haut,mil : SInt32;
    i,note : SInt32;
    oldport : grafPtr;
    echelle : double;
    marge : SInt32;
    x1,x2,oldx1 : Point;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        WriteDebugageCourbe(IntToStr(nbreCoup)+' : DessineCourbe, fonction appelante = '+fonctionAppelante);

        GetPort(oldport);
        BeginDrawingCourbe('DessineCourbe');

        CheckDoitEffacerLaCourbe('DessineCourbe -> '+fonctionAppelante);


        marge := kPetiteMargeDansZoneGrise;
        haut := HauteurCourbe;
        mil := margeZoneGrise + haut div 2 - 1;
        echelle := 1.0*(mil-margeZoneGrise)/4000.0;
        largeur := LargeurCourbe - marge;

        EraseZoneGriseDansCourbe;

        PenSize(2,2);

        PenPat(blackPattern);
        SetPt(x1,margeZoneGrise + marge,mil);
        oldx1 := x1;
        for i := 1 to nroDernierCoupAtteint do
          begin
            if not(EvaluationPourCourbeProvientDeLaFinale(i))
              then note := (GetEvaluationPourNoirDansCourbe(i-1)+GetEvaluationPourNoirDansCourbe(i)) div 2
              else note := GetEvaluationPourNoirDansCourbe(i);

            x := margeZoneGrise + ((i*largeur) div 60);
            y := Trunc(mil-note*echelle);
            if y < margeZoneGrise + 2      then y := margeZoneGrise + 2;
            if y > margeZoneGrise + haut-3 then y := margeZoneGrise + haut-3;
            SetPt(x2,marge+x,y);


            PenSize(1,1);

            if (i <= nbreCoup)
              then DessineTrapezeCouleurDansCourbe(x1,x2,mil,coloration)
              else DessineTrapezeCouleurDansCourbe(x1,x2,mil,kCourbePastel);

            PenSize(2,2);

            if CassioIsUtiliseImageDeFondPourLaCourbe
              then RGBForeColor(gPurBlanc)
              else
                if ((i - 1) > nbreCoup)
                  then RGBForeColor(gPurGrisFonce)
                  else RGBForeColor(gPurNoir);


            Moveto(oldx1.h , oldx1.v );
            Lineto(x1.h , x1.v );
            Lineto(x2.h , x2.v );

            oldx1 := x1;
            x1 := x2;
          end;

        RGBForeColor(gPurNoir);

        if (nroDernierCoupAtteint > dernierSegmentDessine) then dernierSegmentDessine := nroDernierCoupAtteint;
        if (1 < premierSegmentDessine)                     then premierSegmentDessine := 1;

        EndDrawingCourbe('DessineCourbe');

        DessineRepereCourbe(fonctionAppelante+'->DessineCourbe');
        ValidRect(QDGetPortBound);

        SetPort(oldport);
      end;
end;


function EvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32) : boolean;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65)
      then EvaluationPourCourbeProvientDeLaFinale := listeEvaluations[nroDuCoup].evalDonneeParFinale
      else EvaluationPourCourbeProvientDeLaFinale := false;
end;


function EvaluationPourCourbeDejaConnue(nroDuCoup : SInt32) : boolean;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65)
      then EvaluationPourCourbeDejaConnue := listeEvaluations[nroDuCoup].evalCourbeDejaConnue
      else EvaluationPourCourbeDejaConnue := false;
end;


procedure SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup : SInt32; flag : boolean);
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65) then
      begin
        if (listeEvaluations[nroDuCoup].evalDonneeParFinale <> flag) then
          begin
            inc(magicCookieLastChangeEval);
            SetCourbeEstContinueEnCePoint(nroDuCoup,kGlobalement,false);
            listeEvaluations[nroDuCoup].evalDonneeParFinale := flag;
          end;
      end;
end;


procedure SetCourbeDoitEtreEffacee(nroDuCoup : SInt32; flag : boolean);
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65) then
      begin
        if (listeEvaluations[nroDuCoup].doitEtreEffacee <> flag) then
          begin
            inc(magicCookieLastChangeEval);
            listeEvaluations[nroDuCoup].doitEtreEffacee := flag;
          end;
      end;
end;

function CourbeDoitEtreEffacee(nroDuCoup : SInt32) : boolean;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65)
      then CourbeDoitEtreEffacee := listeEvaluations[nroDuCoup].doitEtreEffacee
      else CourbeDoitEtreEffacee := false;
end;

procedure SetEvaluationPourCourbeDejaConnue(nroDuCoup : SInt32; flag : boolean);
begin
  with gCourbeData do
    if (nroDuCoup >= 1) and (nroDuCoup <= 65) then
      begin

        if (listeEvaluations[nroDuCoup].evalCourbeDejaConnue <> flag) then
          begin
            inc(magicCookieLastChangeEval);
            listeEvaluations[nroDuCoup].evalCourbeDejaConnue := flag;
          end;

        { mise a jour (partielle) de premierCoupSansEvaluation }
        if flag and (nroDuCoup >= premierCoupSansEvaluation) then
          begin
            inc(magicCookieLastChangeEval);
            premierCoupSansEvaluation := nroDuCoup + 1;
          end;

        if not(flag) and (premierCoupSansEvaluation = nroDuCoup+1) then
          begin
            inc(magicCookieLastChangeEval);
            premierCoupSansEvaluation := nroDuCoup;
          end;

        {WritelnNumDansRapport('SetConnue['+IntToStr(nroDuCoup)+','+BoolEnString(flag)+'] : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
      end;
end;


procedure InvalidateEvaluationPourCourbe(nroCoupMin,nroCoupMax : SInt32);
var n : SInt32;
    doitExecuterLaBoucle : boolean;
begin
  with gCourbeData do
    begin
      doitExecuterLaBoucle := true;
      if (premierCoupSansEvaluation <= nroCoupMin) then doitExecuterLaBoucle := false;

      {WritelnStringAndBoolDansRapport('Invalidate['+IntToStr(nroCoupMin)+','+IntToStr(nroCoupMax)+'] : doitExecuterLaBoucle = ',doitExecuterLaBoucle);}

      if doitExecuterLaBoucle then
        begin
          inc(magicCookieLastChangeEval);
          for n := nroCoupMax downto nroCoupMin do
            begin
              SetEvaluationPourCourbeDejaConnue(n,false);
              SetEvaluationPourCourbeProvientDeLaFinale(n,false);
              SetEvaluationPourNoirDansCourbe(n,0,kNonPrecisee);
              SetCourbeDoitEtreEffacee(n,true);
            end;
        end;


      if (nroCoupMax >= 60) and (premierCoupSansEvaluation > nroCoupMin) then
        begin
          inc(magicCookieLastChangeEval);
          premierCoupSansEvaluation := nroCoupMin;
        end;

      {WritelnNumDansRapport('Invalidate : premierCoupSansEvaluation = ',premierCoupSansEvaluation);}
    end;
end;


function GetEvaluationPourNoirDansCourbe(nroDuCoup : SInt32) : SInt32;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65)
      then GetEvaluationPourNoirDansCourbe := listeEvaluations[nroDuCoup].evalNoir
      else GetEvaluationPourNoirDansCourbe := 0;
end;


function GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroDuCoup : SInt32) : SInt32;
var k : SInt32;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65) then
      for k := nroDuCoup downto 0 do
        if (listeEvaluations[k].origineEval = kMilieuDePartie) then
          begin
            GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup := listeEvaluations[k].evalNoir;
            exit;
          end;

  GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup := 0;
end;

function GetOrigineEvaluationDansCourbe(nroDuCoup : SInt32) : typeGenreDeReflexion;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 60)
      then GetOrigineEvaluationDansCourbe := listeEvaluations[nroDuCoup].origineEval
      else GetOrigineEvaluationDansCourbe := kNonPrecisee;
end;


procedure SetEvaluationPourNoirDansCourbe(nroDuCoup,evaluationPourNoir : SInt32; origine : typeGenreDeReflexion);
var oldEvaluation : SInt32;
    oldOrigine : typeGenreDeReflexion;
begin
  with gCourbeData do
    if (nroDuCoup >= 0) and (nroDuCoup <= 65) then
      begin

        oldEvaluation := listeEvaluations[nroDuCoup].evalNoir;
        oldOrigine    := listeEvaluations[nroDuCoup].origineEval;

        if (evaluationPourNoir <> oldEvaluation) or (oldOrigine <> origine) then
          begin
            inc(magicCookieLastChangeEval);

            SetCourbeEstContinueEnCePoint(nroDuCoup,kGlobalement,false);

            {WritelnNumDansRapport('Courbe['+IntToStr(nroDuCoup)+'] = ',evaluationPourNoir div kCoeffMultiplicateurPourCourbeEnFinale);}

            if (evaluationPourNoir >  64*kCoeffMultiplicateurPourCourbeEnFinale) then evaluationPourNoir :=  64*kCoeffMultiplicateurPourCourbeEnFinale else
            if (evaluationPourNoir < -64*kCoeffMultiplicateurPourCourbeEnFinale) then evaluationPourNoir := -64*kCoeffMultiplicateurPourCourbeEnFinale;

            listeEvaluations[nroDuCoup].evalNoir    := evaluationPourNoir;
            listeEvaluations[nroDuCoup].origineEval := origine;
          end;
      end;
end;


function CourbeEstContinueEnCePoint(nroDuCoup : SInt32; quelCote : typeLateralisationContinuite) : boolean;
begin
  if (nroDuCoup >= 0) and (nroDuCoup <= 65)
    then
      begin
        with gCourbeData.listeEvaluations[nroDuCoup] do
          case quelCote of
            kAGauche :
              begin
                CourbeEstContinueEnCePoint := continueAGauche;
              end;
            kADroite :
              begin
                CourbeEstContinueEnCePoint := continueADroite;
              end;
            kGlobalement :
              begin
                CourbeEstContinueEnCePoint := continueAGauche and continueADroite;
              end;
        end; {case}
      end
    else
      CourbeEstContinueEnCePoint := false;
end;


procedure SetCourbeEstContinueEnCePoint(nroDuCoup : SInt32; quelCote : typeLateralisationContinuite; flag : boolean);
begin
  if (nroDuCoup >= 0) and (nroDuCoup <= 65) then
     begin
        with gCourbeData, gCourbeData.listeEvaluations[nroDuCoup] do
          case quelCote of
            kAGauche :
              begin
                if (continueAGauche <> flag) then inc(magicCookieLastChangeEval);
                continueAGauche := flag;
              end;
            kADroite :
              begin
                if (continueADroite <> flag) then inc(magicCookieLastChangeEval);
                continueADroite := flag;
              end;
            kGlobalement :
              begin
                if ((continueADroite <> flag) or (continueAGauche <> flag)) then inc(magicCookieLastChangeEval);
                continueAGauche := flag;
                continueADroite := flag;
              end;
        end; {case}
     end;
end;


var gLastDrawingOfScoreDansCourbe :
      record
        coupDebut   : SInt32;
        coupFin     : SInt32;
        theOrigin   : typeGenreDeReflexion;
        scoreDeNoir : SInt32;
        date        : SInt32;
      end;

procedure MetScorePrevuParFinaleDansCourbe(nroCoupDeb,nroCoupFin : SInt32; origine : typeGenreDeReflexion; scorePourNoir : SInt32);
var i,note,noteCoupPrec : SInt32;
    oldPort : grafPtr;
    fooRect : Rect;
    onVientDeDessinerCeMorceau : boolean;
    oldMagicCookie : SInt32;
    somethingChanged : boolean;
begin

  oldMagicCookie := gCourbeData.magicCookieLastChangeEval;

  if (origine = kFinaleParfaite)
    then
      begin
        note := scorePourNoir*kCoeffMultiplicateurPourCourbeEnFinale;

        for i := nroCoupDeb to nroCoupFin do
          begin
            SetEvaluationPourCourbeDejaConnue(i-1,true);
            SetEvaluationPourCourbeProvientDeLaFinale(i-1,true);
            SetEvaluationPourNoirDansCourbe(i-1,note,kFinaleParfaite);
          end;

      end
    else
      begin
        if EvaluationPourCourbeProvientDeLaFinale(nroCoupDeb - 1)
          then noteCoupPrec := GetEvaluationPourNoirDansCourbe(nroCoupDeb - 1)
          else noteCoupPrec := GetDerniereEvaluationDeMilieuDePartieDansCourbeAvantCeCoup(nroCoupDeb - 2);

        if ((noteCoupPrec > 0) and (scorePourNoir > 0)) or ((noteCoupPrec < 0) and (scorePourNoir < 0))
          then
            begin
              note := noteCoupPrec div kCoeffMultiplicateurPourCourbeEnFinale;
              if not(odd(note)) then
                if (note > 0)
                  then note := note+1
                  else note := note-1;
              note := note*kCoeffMultiplicateurPourCourbeEnFinale;
            end
          else
            if scorePourNoir = 0 then note :=  0 else
            if scorePourNoir > 0 then note :=  2*kCoeffMultiplicateurPourCourbeEnFinale else
            if scorePourNoir < 0 then note := -2*kCoeffMultiplicateurPourCourbeEnFinale;

        for i := nroCoupDeb to nroCoupFin do
          begin
            SetEvaluationPourCourbeDejaConnue(i-1,true);
            SetEvaluationPourCourbeProvientDeLaFinale(i-1,true);
            SetEvaluationPourNoirDansCourbe(i-1,note,kFinaleWLD);
          end;
      end;


  somethingChanged := (gCourbeData.magicCookieLastChangeEval <> oldMagicCookie);

  //WritelnStringAndBoolDansRapport('somethingChanged = ',somethingChanged);



  // Optimisation : on ne redessine la courbe avec la nouvelle valeur
  //                que si les parametres ont changé, ou si la date du
  //                dernier affichage est superieure à 1/3 de seconde
  with gLastDrawingOfScoreDansCourbe do
    begin

      onVientDeDessinerCeMorceau := (gLastDrawingOfScoreDansCourbe.coupDebut   = nroCoupDeb) and
                                    (gLastDrawingOfScoreDansCourbe.coupFin     = nroCoupFin) and
                                    (gLastDrawingOfScoreDansCourbe.theOrigin   = origine) and
                                    (gLastDrawingOfScoreDansCourbe.scoreDeNoir = scorePourNoir) and
                                    (Abs(gLastDrawingOfScoreDansCourbe.date - TickCount()) <= 20);

      if windowCourbeOpen and not(onVientDeDessinerCeMorceau) and somethingChanged then
        begin
          fooRect := MakeRect(0,0,0,0);
          GetPort(oldPort);
          BeginDrawingCourbe('MetScorePrevuParFinaleDansCourbe');

          for i := nroCoupDeb-1 to nroCoupFin+2 do
            TraceSegmentCourbeSansDessinerLeRepere(i-1,kCourbeColoree,'MetScorePrevuParFinaleDansCourbe',fooRect);

          EndDrawingCourbe('MetScorePrevuParFinaleDansCourbe');
          DessineRepereCourbe('MetScorePrevuParFinaleDansCourbe');
          SetPort(oldPort);

          gLastDrawingOfScoreDansCourbe.coupDebut   := nroCoupDeb;
          gLastDrawingOfScoreDansCourbe.coupFin     := nroCoupFin;
          gLastDrawingOfScoreDansCourbe.theOrigin   := origine;
          gLastDrawingOfScoreDansCourbe.scoreDeNoir := scorePourNoir;
          gLastDrawingOfScoreDansCourbe.date        := TickCount();
        end;
    end;


  { Remarque : lors d'une analyse retrograde, on n'affiche le nouveau score comme
               texte que si on a eu une periode d'inactivite de 30 secondes au moins }
  if not(analyseRetrograde.enCours) or (((TickCount - gCourbeData.dernierTickCommentaire) div 60) > 30)
    then EcritCommentaireCourbe(nbreCoup);
end;


procedure EssaieMettreEvaluationDeMilieuDansCourbe(square,couleur,numeroDuCoup : SInt32; const position : plateauOthello;
                                                   nbreBlancs,nbreNoirs : SInt32; var jouables : plBool; var frontiere : InfoFront);
var uneNote : SInt32;
    nbEvalRecursives : SInt32;
    plat : plateauOthello;
begin
  if HumCtreHum or (numeroDuCoup < finDePartie) or not(EvaluationPourCourbeDejaConnue(numeroDuCoup)) then
    begin

      {WritelnNumDansRapport('numeroDuCoup = ',numeroDuCoup);
      WritelnNumDansRapport('couleur = ',couleur);
      WritelnNumDansRapport('square = ',square);
      WritelnNumDansRapport('i.nroDuCoup = ',InfosDerniereReflexionMac.nroDuCoup);
      WritelnNumDansRapport('i.coup = ',InfosDerniereReflexionMac.coup);
      WritelnNumDansRapport('i.coul = ',InfosDerniereReflexionMac.coul);
      WritelnNumDansRapport('i.valeurCoup = ',InfosDerniereReflexionMac.valeurCoup);}

      if not(HumCtreHum) and
         (InfosDerniereReflexionMac.nroDuCoup = numeroDuCoup) and
         (InfosDerniereReflexionMac.coup = square) and
         (InfosDerniereReflexionMac.coul = couleur) and
         (InfosDerniereReflexionMac.valeurCoup <> -noteMax)
        then
          begin
            if InfosDerniereReflexionMac.coul = pionNoir
              then SetEvaluationPourNoirDansCourbe(numeroDuCoup,  InfosDerniereReflexionMac.valeurCoup, kMilieuDePartie)
              else SetEvaluationPourNoirDansCourbe(numeroDuCoup, -InfosDerniereReflexionMac.valeurCoup, kMilieuDePartie);
          end
        else
          begin

            if not(EvaluationEdmondEstDisponible or GetNouvelleEvalDejaChargee) then
              begin
                exit;
              end;


            if ((numeroDuCoup mod 8) = 0) or ((numeroDuCoup mod 8) = 1) then Superviseur(numeroDuCoup);

            plat := position;

            uneNote := penalitePourTraitAff - Evaluation(plat,-couleur,nbreBlancs,nbreNoirs,
                                                         jouables,frontiere,false,
                                                         -30000,30000,nbEvalRecursives);

            if numeroDuCoup <= 4 then uneNote := uneNote div 2;

            if couleur = pionBlanc
              then SetEvaluationPourNoirDansCourbe(numeroDuCoup , -uneNote, kMilieuDePartie)
              else SetEvaluationPourNoirDansCourbe(numeroDuCoup ,  uneNote, kMilieuDePartie);
          end;

      SetEvaluationPourCourbeDejaConnue(numeroDuCoup ,true);
      SetEvaluationPourCourbeProvientDeLaFinale(numeroDuCoup ,false);

      if not(HumCtreHum or EvaluationPourCourbeDejaConnue(numeroDuCoup + 1))
        then
          begin
            SetEvaluationPourNoirDansCourbe(numeroDuCoup + 1, GetEvaluationPourNoirDansCourbe(numeroDuCoup), kMilieuDePartie);
            SetEvaluationPourCourbeProvientDeLaFinale(numeroDuCoup + 1, false);
          end;
    end;
end;



function PeutCopierEndgameScoreFromGameTreeDansCourbe(G : GameTree; nroDuCoup : SInt32; origineCherchees : SetOfGenreDeReflexion) : boolean;
var scoreMinPourNoir,scoreMaxPourNoir : SInt32;
    note : SInt32;
begin


  if GetEndgameScoreDeCetteCouleurDansGameNode(G,pionNoir,scoreMinPourNoir,scoreMaxPourNoir) then
    begin

      { Est-ce un score parfait ? }
      if (kFinaleParfaite in origineCherchees) and (scoreMinPourNoir = scoreMaxPourNoir) and (scoreMinPourNoir >= -64) and (scoreMinPourNoir <= 64) then
        begin
          note := scoreMinPourNoir*kCoeffMultiplicateurPourCourbeEnFinale;
          {WritelnNumDansRapport('Chouette, un score parfait@'+ IntToStr(nroDuCoup)+' : ',scoreMinPourNoir);}

          SetEvaluationPourNoirDansCourbe(nroDuCoup,note,kFinaleParfaite);
          SetEvaluationPourCourbeProvientDeLaFinale(nroDuCoup,true);
          SetEvaluationPourCourbeDejaConnue(nroDuCoup,true);

          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit;
        end;

      { Est-ce un score WLD gagnant ? }
      if (kFinaleWLD in origineCherchees) and (scoreMinPourNoir > 0) and (scoreMinPourNoir <= 64) then
        begin

          MetScorePrevuParFinaleDansCourbe(nroDuCoup+1,nroDuCoup+1,kFinaleWLD,2);

          {WritelnNumDansRapport('Chouette, un score gagnant WLD@'+ IntToStr(nroDuCoup)+' : ',2);}

          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit;
        end;

      { Est-ce un score WLD perdant ? }
      if (kFinaleWLD in origineCherchees) and (scoreMaxPourNoir < 0) and (scoreMaxPourNoir >= -64) then
        begin

          MetScorePrevuParFinaleDansCourbe(nroDuCoup+1,nroDuCoup+1,kFinaleWLD,-2);

          {WritelnNumDansRapport('Chouette, un score perdant WLD@'+ IntToStr(nroDuCoup)+' : ',-2);}

          PeutCopierEndgameScoreFromGameTreeDansCourbe := true;
          exit;
        end;

    end;

  PeutCopierEndgameScoreFromGameTreeDansCourbe := false;

end;


function NroDeCoupEnPositionSurCourbe(nro : SInt32) : SInt32;
var x : SInt32;
begin
  with gCourbeData do
    x := margeZoneGrise + ((nro*(LargeurCourbe - kPetiteMargeDansZoneGrise)) div 60);

  NroDeCoupEnPositionSurCourbe := x;
end;




function NroDeCoupEnPositionDeSliderCourbe(nro : SInt32) : SInt32;
begin
  NroDeCoupEnPositionDeSliderCourbe := NroDeCoupEnPositionSurCourbe(nro);
end;


function PositionSourisEnNumeroDeCoupSurCourbe(positionX : SInt32) : SInt32;
var marge,largeur : SInt32;
    aux,numero : SInt32;
begin
  with gCourbeData do
    begin
      marge := 3;
      largeur := LargeurCourbe - marge;
      aux := (positionX - marge - margeZoneGrise);

      if aux >= 0
        then numero := (60*aux) div largeur + 1
        else numero := 0;

      if numero < 0 then numero := 0;
      if numero > 60 then numero := 60;
      PositionSourisEnNumeroDeCoupSurCourbe := numero;
    end;
end;


function PositionSourisEnNumeroDeCoupSurSlider(positionX : SInt32) : SInt32;
var largeur,result : SInt32;
    marge : SInt32;
begin
  with gCourbeData do
    begin
      marge := 3;
      largeur := LargeurCourbe - 3;
      result := (60*(positionX - marge - margeZoneGrise)) div largeur + 1;

      if result < 0 then result := 0;
      if result > 60 then result := 60;

      PositionSourisEnNumeroDeCoupSurSlider := result;
    end;
end;


procedure DessineSliderFenetreCourbe;
var s : String255;
    err : OSStatus;
    theSlider : ControlHandle;
    oldPort : grafPtr;
    ligneRect : rect;
    myRect : rect;
    x : SInt32;
    deltaADroite : SInt32;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);


        if (nroDernierCoupAtteint > 0)
          then
            begin

              myRect := sliderRect;

              deltaADroite := sliderRect.right - NroDeCoupEnPositionDeSliderCourbe(60);
              myRect.right := NroDeCoupEnPositionDeSliderCourbe(nroDernierCoupAtteint) + deltaADroite + 3;



              err := CreateSliderControl(wCourbePtr,myRect,nbreCoup,0,nroDernierCoupAtteint,
                                         {kControlSliderPointsUpOrLeft}kControlSliderDoesNotPoint, 0, false, NIL, theSlider);


              // on efface l'ancien slider et la partie a droite du nouveau
              EraseRectFenetreCourbe(sliderRect);
              MyEraseRectWithColor(sliderRect,BleuCmd,blackPattern,'');

              EraseRectFenetreCourbe(MakeRect(myRect.right,myRect.top-10,sliderRect.right+10,myRect.bottom+10));
              MyEraseRectWithColor(MakeRect(myRect.right,myRect.top-10,sliderRect.right+10,myRect.bottom+10),BleuCmd,blackPattern,'');

              if (err = NoErr) and (theSlider <> NIL) then
                begin
                  Draw1Control(theSlider);
                  ShowControl(theSlider);
                  if SetControlVisibility(theSlider,false,false) = NoErr then DoNothing;
                  SizeControl(theSlider,0,0);
                  DisposeControl(theSlider);
                end;

              if (nbreCoup > 0) and (nbreCoup <= 60) and (DerniereCaseJouee <> coupInconnu)
                then
                  begin
                    s := IntToStr(nbreCoup)+'.'+CoupEnString(DerniereCaseJouee,CassioUtiliseDesMajuscules);
                    if nbreCoup < 10 then s := ' ' + s;
                  end
                else s := '';


              {ligneRect := MakeRect(sliderRect.left - 20,sliderRect.top - 20, sliderRect.right + 20,sliderRect.top - 4);}
              ligneRect := MakeRect(sliderRect.left - 20,sliderRect.bottom + 7, sliderRect.right + 20,sliderRect.bottom + 17);
              EraseRectFenetreCourbe(ligneRect);
              MyEraseRectWithColor(ligneRect,BleuCmd,blackPattern,'');

              DessineBoiteDeTaille(wCourbePtr);

              if (s <> '') then
                begin
                  TextFont(gCassioApplicationFont);
                  TextSize(gCassioSmallFontSize);
                  x := NroDeCoupEnPositionDeSliderCourbe(nbreCoup) - (MyStringWidth(s) div 2) + 3;
                  if (x >= canvasRect.right - 43) then x := canvasRect.right - 43;
                  Moveto(x,ligneRect.bottom - 2);
                  MyDrawString(s);
                end;

              EcritCommentaireCourbe(nbreCoup);

            end
          else
            begin
              { Quand nroDernierCoupAtteint = 0 , il faut effacer plus largement puisque l'on ne va pas redessiner le slider juste apres }
              myRect := sliderRect;
              InSetRect(myRect, -10, -10);
              EraseRectFenetreCourbe(myRect);
              MyEraseRectWithColor(myRect,BleuCmd,blackPattern,'');
            end;

        SetPort(oldPort);
      end;
end;


function EstUnClicSurSliderCourbe(mouseLoc : Point) : boolean;
var aux : SInt32;
    test : boolean;
begin
  aux := NroDeCoupEnPositionDeSliderCourbe(nbreCoup) + 6;
  test := (Abs(mouseLoc.h - aux) <= 13);
  EstUnClicSurSliderCourbe := test;
end;


procedure TraiteClicSurSliderCourbe(mouseLoc : Point);
var oldPort : grafPtr;
    numeroDuCoupDemande : SInt32;
    tireCurseur,bouge : boolean;
    enRetourArrivee : boolean;
    HumCtreHumArrivee : boolean;
    sourisRect : rect;
    mouseX : SInt32;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);

        if PtInRect(mouseLoc,zoneSensibleSlider) and EstUnClicSurSliderCourbe(mouseLoc) and (nroDernierCoupAtteint > 0) then
          begin

            enRetourArrivee := enRetour;
            HumCtreHumArrivee := HumCtreHum;

            sourisRect := SliderRect;
            InSetRect(sourisRect,-200,-700);

            tireCurseur := true;
            mouseX := 0;
            while Button and tireCurseur and windowCourbeOpen do
              begin
                InitCursor;
                doitAjusterCurseur := false;

                SetPortByWindow(wCourbePtr);

                GetMouse(mouseLoc);
                tirecurseur := PtInRect(mouseLoc,sourisRect);


                bouge := (mouseLoc.h <> mouseX) and
                         (((mouseLoc.h >= sliderRect.left ) and (mouseLoc.h <= sliderRect.right)) or
                          ((mouseLoc.h <= sliderRect.left ) and (mouseX >= sliderRect.left)) or
                          ((mouseLoc.h >= sliderRect.right) and (mouseX <= sliderRect.right)));

                if bouge and tireCurseur then
                  begin
                    numeroDuCoupDemande := PositionSourisEnNumeroDeCoupSurSlider(mouseLoc.h - (LargeurCourbe div 120));

                    if (numeroDuCoupDemande < 0) then numeroDuCoupDemande := 0;
                    if (numeroDuCoupDemande > nroDernierCoupAtteint) then numeroDuCoupDemande := nroDernierCoupAtteint;

                    if (numeroDuCoupDemande <> nbreCoup) and
                       (numeroDuCoupDemande >= 0) and
                       (numeroDuCoupDemande <= nroDernierCoupAtteint) then
                     begin

                       if (numeroDuCoupDemande < nbreCoup) and (numeroDuCoupDemande >= 0) then
                         begin
                           if (GetNiemeCoupPartieCourante(numeroDuCoupDemande+1) > 0) and PeutArreterAnalyseRetrograde then
                             begin
                               if (numeroDuCoupDemande = nbreCoup - 1) then DoBackMove else
                               if (numeroDuCoupDemande = nbreCoup - 2) then DoDoubleBackMove else
                                 DoRetourAuCoupNro(numeroDuCoupDemande,not(enRetourArrivee),true);
                             end;
                         end;

                       if (numeroDuCoupDemande > nbreCoup) and (numeroDuCoupDemande <= 60) then
                         begin
                           if (GetNiemeCoupPartieCourante(numeroDuCoupDemande) > 0) and PeutArreterAnalyseRetrograde then
                             begin
                               if (numeroDuCoupDemande = nbreCoup + 1) then DoAvanceMove else
                               if (numeroDuCoupDemande = nbreCoup + 2) then DoDoubleAvanceMove else
                                 DoAvanceAuCoupNro(numeroDuCoupDemande,not(enRetourArrivee));
                             end;
                         end;

                       EcritCommentaireCourbe(numeroDuCoupDemande);
                     end;
                  end;

                ShareTimeWithOtherProcesses(2);
                mouseX := mouseLoc.h;
              end;
          end;

        doitAjusterCurseur := true;
        AjusteCurseur;
        SetPort(oldPort);
      end;

end;

{ TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe doit renvoyer true si elle change le curseur }
function TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe(mouseGlobalLoc : Point) : boolean;
var numeroPointe : SInt32;
    oldPort : grafPtr;
    mouseLoc : Point;
begin
  TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := false;

  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldPort);
        SetPortByWindow(wCourbePtr);

        mouseLoc := mouseGlobalLoc;

        GlobalToLocal(mouseLoc);

        if PtInRect(mouseLoc,zoneGriseRect)
          then
            begin
              TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := true;

              if (mouseLoc.h <> lastMouseLocUtilisee.h) then
                begin
                  lastMouseLocUtilisee := mouseLoc;
                  numeroPointe := PositionSourisEnNumeroDeCoupSurCourbe(mouseLoc.h - (LargeurCourbe div 120));

                  if (numeroPointe >= 0) and (numeroPointe <= nroDernierCoupAtteint + 1)
                    then InitCursor
                    else TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := false;

                  if (numeroPointe <= 1) then numeroPointe := 1;
                  if (numeroPointe >= nroDernierCoupAtteint) then numeroPointe := nroDernierCoupAtteint;

                  if numeroPointe <> dernierCommentaireAffiche then
                    begin
                      dernierCommentaireAffiche := numeroPointe;
                      EcritCommentaireCourbe(numeroPointe);
                    end;
                end;

              exit;
            end;

        if PtInRect(mouseLoc,zoneSensibleSlider) and EstUnClicSurSliderCourbe(mouseLoc) and (nroDernierCoupAtteint > 0) and not(enSetUp)
          then
            begin
              InitCursor;
              TraiteCurseurSeBalladantSurLaFenetreDeLaCourbe := true;
            end;

        SetPort(oldPort);
      end;
end;


procedure TraiteSourisCourbe(evt : eventRecord);
var mouseLoc : Point;
    oldport : grafPtr;
    numeroCoup : SInt32;
    rectanglePourDoubleClic : Rect;
begin
  if windowCourbeOpen then
    with gCourbeData do
      begin
        GetPort(oldport);
        SetPortByWindow(wCourbePtr);

        mouseLoc := evt.where;
        GlobalToLocal(mouseLoc);


        rectanglePourDoubleClic := zoneGriseRect;
        InsetRect(rectanglePourDoubleClic,-40,0);

        if PtInRect(mouseLoc,rectanglePourDoubleClic)
          then
            begin
              numeroCoup := PositionSourisEnNumeroDeCoupSurCourbe(mouseLoc.h);
              if EstUnDoubleClic(theEvent,false) then
                begin
                  if numeroCoup < nbreCoup
                    then
                      begin
                        if (GetNiemeCoupPartieCourante(numeroCoup+1) > 0) and PeutArreterAnalyseRetrograde then
                          DoRetourAuCoupNro(numeroCoup,true,not(CassioEstEnModeAnalyse));
                      end
                    else
                  if numeroCoup > nbreCoup
                    then
                      begin
                        if (((numeroCoup >= nroDernierCoupAtteint) and (nroDernierCoupAtteint > 0)) or (GetNiemeCoupPartieCourante(numeroCoup + 1) > 0))
                           and PeutArreterAnalyseRetrograde then
                          begin
                            DoAvanceAuCoupNro(Min(numeroCoup,nroDernierCoupAtteint),not(CassioEstEnModeAnalyse));
                          end;
                      end;
                end;
            end
          else
           if PtInRect(mouseLoc,zoneSensibleSlider) then
             begin
               if EstUnClicSurSliderCourbe(mouseLoc) and not(enSetUp) then TraiteClicSurSliderCourbe(mouseLoc);
             end;


        SetPort(oldport);
      end;
end;


procedure InvalidatePositionSourisFntreCourbe;
begin
  gCourbeData.lastMouseLocUtilisee      := MakePoint(-1000,-1000);
end;



procedure EffaceCommentaireCourbe;
var oldPort : grafPtr;
begin
  if windowCourbeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);
      EraseRectFenetreCourbe(gCourbeData.commentaireRect);
      MyEraseRectWithColor(gCourbeData.commentaireRect,BleuCmd,blackPattern,'');
      SetPort(oldPort);
    end;
end;

procedure EcritCommentaireCourbe(nroCoup : SInt32);
var s,s1,coupEnChaine : String255;
    note : SInt32;
    nbDeChiffres : SInt32;
    origineNote : typeGenreDeReflexion;
    noteEnReel : double;
    x,largeurString,largeurCoup : SInt32;
    oldPort : grafPtr;
begin

  gCourbeData.dernierTickCommentaire := TickCount;

  if windowCourbeOpen and DoitEcrireCommentaireCourbe then
  with gCourbeData do
    begin
      GetPort(oldport);
      SetPortByWindow(wCourbePtr);

      EraseRectFenetreCourbe(commentaireRect);
      MyEraseRectWithColor(commentaireRect,BleuCmd,blackPattern,'EcritCommentaireCourbe');

      if (nroCoup >= 1) and (nroCoup <= nroDernierCoupAtteint) and (GetNiemeCoupPartieCourante(nroCoup) > 0) then
        begin
          dernierCommentaireAffiche := nroCoup;

          coupEnChaine := IntToStr(nroCoup)+'.'+CoupEnString(GetNiemeCoupPartieCourante(nroCoup),CassioUtiliseDesMajuscules);


          if EvaluationPourCourbeProvientDeLaFinale(nroCoup)
            then
              begin
                origineNote := GetOrigineEvaluationDansCourbe(nroCoup);
                note := GetEvaluationPourNoirDansCourbe(nroCoup) div kCoeffMultiplicateurPourCourbeEnFinale;

                s := '';
                if note = 0
                  then s := s + '  ' + ReadStringFromRessource(TextesRetrogradeID,20)  {'  fait nulle'}
                  else
                    case origineNote of
                      kFinaleParfaite :
                        begin
                          s1 := '  ' + ReadStringFromRessource(TextesRetrogradeID,21);  {'  fait ^0}
                          s1 := ReplaceParameters(s1,IntToStr(32 + note div 2)+'-'+IntToStr(32 - note div 2),'','','');
                          s := s + {' :' +} s1;
                        end;
                      kFinaleWLD :
                        if (note > 0) then s := s + {' : '} '  ' + ReadStringFromRessource(TextesRetrogradeID,25)  {'  Noir est gagnant'}
                                      else s := s + {' : '} '  ' + ReadStringFromRessource(TextesRetrogradeID,26); {'  Blanc est gagnant'}


                    end; {case}
              end
            else
              begin
                note := (GetEvaluationPourNoirDansCourbe(nroCoup - 1) + GetEvaluationPourNoirDansCourbe(nroCoup)) div 2;
                noteEnReel := 1.0*note/kCoeffMultiplicateurPourCourbeEnFinale;

                if Abs(noteEnReel) >= 10.0
                  then nbDeChiffres := 4
                  else nbDeChiffres := 3;

                s := ' : ';
                if (noteEnReel > 0.0)
                  then s := s + 'N+'+ReelEnStringAvecDecimales( noteEnReel,nbDeChiffres)
                  else s := s + 'B+'+ReelEnStringAvecDecimales(-noteEnReel,nbDeChiffres);
              end;

          TextFont(gCassioApplicationFont);
          TextSize(gCassioSmallFontSize);
          TextFace(normal);
          largeurCoup := MyStringWidth(coupEnChaine) - 5 ;
          largeurString := MyStringWidth(coupEnChaine + s) ;

          x := NroDeCoupEnPositionSurCourbe(nroCoup) - largeurCoup;
          if (x > zoneGriseRect.right - largeurString) then x := zoneGriseRect.right - largeurString;
          if (x < zoneGriseRect.left) then x := zoneGriseRect.left;

          Moveto(x,commentaireRect.bottom - (margeZoneGrise div 5));
          TextFace(bold);
          MyDrawString(coupEnChaine);
          TextFace(normal);
          MyDrawString(s);
        end;

      SetPort(oldPort);
    end;
end;

procedure SetDoitEcrireCommentaireCourbe(flag : boolean);
begin
  gCourbeData.ecrireCommentaire := flag;
end;


function DoitEcrireCommentaireCourbe : boolean;
begin
  DoitEcrireCommentaireCourbe := gCourbeData.ecrireCommentaire;
end;


procedure SetUseOffscreenCourbe(flag : boolean);
begin
  gUseOffScreenCourbe := flag;
end;


function GetUseOffscreenCourbe : boolean;
begin
  GetUseOffscreenCourbe := gUseOffScreenCourbe;
end;




function  CassioIsUtiliseImageDeFondPourLaCourbe : boolean;
begin
  CassioIsUtiliseImageDeFondPourLaCourbe := gCourbeBackground.useImageForBackground;
end;


function NomDuFichierCachePourImageDeFondCourbe : String255;
begin
  with gCourbeBackground do
    NomDuFichierCachePourImageDeFondCourbe :=
                        pathDossierOthelliersCassio
                        + ':cache:courbe'
                        + IntToStr(offScreenRect.right)
                        + 'x'
                        + IntToStr(offScreenRect.bottom)
                        + '.jpg';
end;


function PeutChargerImageDeFondPourCourbeDepuisLeDisque : boolean;
var nomFichier : String255;
    erreurES : OSErr;
    fic : basicfile;
    oldPort : grafPtr;
begin
  PeutChargerImageDeFondPourCourbeDepuisLeDisque := false;

  with gCourbeBackground do
    begin

      nomFichier := pathDossierOthelliersCassio + ':graph:courbe.jpg';

      WriteDebugageCourbe('');
      WriteDebugageCourbe('entree dans PeutChargerImageDeFondPourCourbeDepuisLeDisque...');
      WriteDebugageCourbe('nomFichier = '+nomFichier);


      erreurES := FichierTexteDeCassioExiste(nomFichier,fic);

      if (erreurES = NoErr) then
        WriteDebugageCourbe('fichier existe : OK');



      GetPort(oldPort);
      if gUseOffScreenCourbe and
         FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen
         then
           begin
              SetGWorld(gOffScreenCourbeWorld, NIL);
              DetermineRectanglesActifsFenetreCourbe(gOffScreenCourbeRect);

              if (erreurES = NoErr) then
                erreurES := QTGraph_ShowImageFromFile(offScreenWorld,gCourbeData.zoneGriseRect,fic.info);
           end
         else
           begin
              SetPortByWindow(wCourbePtr);
              DetermineRectanglesActifsFenetreCourbe(QDGetPortBound);

              if (erreurES = NoErr) then
                erreurES := QTGraph_ShowImageFromFile(offScreenWorld,gCourbeData.zoneGriseRect,fic.info);
           end;
      SetPort(oldPort);


      if (erreurES = NoErr) then
        WriteDebugageCourbe('LOADING PICTURE FROM DISK : OK');


      PeutChargerImageDeFondPourCourbeDepuisLeDisque := (erreurES = NoErr);
   end;
end;


function PeutChargerImageDeFondPourCourbeDepuisLeCache : boolean;
var nomFichier : String255;
    erreurES : OSErr;
    fic : basicfile;
begin
  PeutChargerImageDeFondPourCourbeDepuisLeCache := false;


  if CassioIsUtiliseImageDeFondPourLaCourbe then
    with gCourbeBackground do
      begin

        nomFichier := NomDuFichierCachePourImageDeFondCourbe;

        WriteDebugageCourbe('');
        WriteDebugageCourbe('entree dans PeutChargerImageDeFondPourCourbeDepuisLeCache...');
        WriteDebugageCourbe('nomFichier = '+nomFichier);

        erreurES := FileExists(nomFichier,0,fic);
        if erreurES = fnfErr then
          exit;

        if (erreurES = NoErr) then
           erreurES := QTGraph_ShowImageFromFile(offScreenWorld,offScreenRect,fic.info);

        if (erreurES = NoErr) then
          WriteDebugageCourbe('LOADING PICTURE FROM CACHE : OK');


        PeutChargerImageDeFondPourCourbeDepuisLeCache := (erreurES = NoErr);

      end;

end;




procedure CreerFichierCacheImageDeFondPourCourbe;
var nomFichier : String255;
    myPicture : PicHandle;
    erreurES : OSErr;
    oldPort : GrafPtr;
begin

  if CassioIsUtiliseImageDeFondPourLaCourbe then
    with gCourbeBackground do
      begin

        GetPort(oldPort);
        SetPort(GrafPtr(offScreenWorld));

        nomFichier := NomDuFichierCachePourImageDeFondCourbe;

        WriteDebugageCourbe('');
        WriteDebugageCourbe('entree dans CreerFichierCacheImageDeFondPourCourbe...');
        WriteDebugageCourbe(nomFichier);


        erreurES := CreateDirectoryWithThisPath(ExtraitCheminDAcces(nomFichier));


        myPicture := OpenPicture(offScreenRect);
        CopyBits(GetPortBitMapForCopyBits(offScreenWorld)^ ,
                 GetPortBitMapForCopyBits(offScreenWorld)^ ,
      	         offScreenRect, offScreenRect, 0, NIL);
        ClosePicture;
        ExportPictureToFile(myPicture, nomFichier);
        KillPicture(myPicture);

        SetPort(oldPort);
      end;
end;


procedure CreerImageDeFondPourCourbeSiNecessaire;
var courbeWindowRect : Rect;
    a,b : SInt32;
begin

  WriteDebugageCourbe('');
  WriteDebugageCourbe('Entree dans CreateBackgroundOffScreenSiNecessaire...');

  if windowCourbeOpen and CassioIsUtiliseImageDeFondPourLaCourbe then
    with gCourbeBackground do
      begin

        courbeWindowRect := GetWindowContentRect(wCourbePtr);

        a := courbeWindowRect.left;
        b := courbeWindowRect.top;

        with courbeWindowRect do
          begin
            left   := left   - a;
            right  := right  - a;
            top    := top    - b;
            bottom := bottom - b;
          end;

        if (courbeWindowRect.right <> courbeWindowRectLastCheck.right) or
           (courbeWindowRect.bottom <> courbeWindowRectLastCheck.bottom) then
          begin
            courbeWindowRectLastCheck := courbeWindowRect;

            KillTempOffscreenWorld(offScreenWorld);


            if gUseOffScreenCourbe and
               FenetreCourbeEstSuffisammentPetitePourUtiliserOffscreen
               then offScreenRect := gOffScreenCourbeRect
               else offScreenRect := courbeWindowRect;

            WriteDebugageCourbe('offScreenRect.left = ' + IntToStr(offScreenRect.left));
            WriteDebugageCourbe('offScreenRect.right = ' + IntToStr(offScreenRect.right));
            WriteDebugageCourbe('offScreenRect.top = ' + IntToStr(offScreenRect.top));
            WriteDebugageCourbe('offScreenRect.bottom = ' + IntToStr(offScreenRect.bottom));

            useImageForBackground := (CreateTempOffScreenWorld(offScreenRect,offScreenWorld) = NoErr);

            if not(useImageForBackground)
              then WriteDebugageCourbe('ERROR : Failed to create offscreen')
              else
                begin
                  WriteDebugageCourbe('CREATE OFFSCREEN : OK');

                  if not(PeutChargerImageDeFondPourCourbeDepuisLeCache) then
                    begin
                      if PeutChargerImageDeFondPourCourbeDepuisLeDisque
                        then CreerFichierCacheImageDeFondPourCourbe
                        else
                          begin
                            useImageForBackground := false;
                            KillTempOffscreenWorld(offScreenWorld);
                          end;
                    end;

                end;

          end;
      end;
end;






END.

































