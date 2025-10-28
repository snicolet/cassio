UNIT Unit3DPovRayPicts;


INTERFACE







 USES UnitDefCassio;


procedure InitUnit3DPovRayPict;
procedure LibereMemoireUnit2DPovRayPicts;



function CreatePovOffScreenWorld(var quelleTexture : CouleurOthellierRec) : OSErr;
procedure KillPovOffScreenWorld;

procedure SetTailleImagesPovRay(taille : Point);
procedure SetPositionScorePovRay3D(color : SInt16; loc : Point);
procedure SetPositionDemandeCoupPovRay3D(loc : Point);
procedure SetPositionMeilleureSuitePovRay3D(loc : Point);
function GetTailleImagesPovRay : Point;
function GetPositionScorePovRay3D(color : SInt16) : Point;
function GetPositionDemandeCoupPovRay3D : Point;
function GetPositionMeilleureSuitePovRay3D : Point;


procedure DessinePionAvecPovRay3D(whichSquare : SInt16; couleur : SInt16);
procedure DessinePionAvecPovRay3DDeplacement(whichSquare : SInt16; couleur : SInt16; offset : Point);
procedure DessinePositionAvecPovRay3D(position : plateauOthello);

procedure EraseRectPovRay3D(myRect : rect);


procedure SetDebugBoundingRects3DPovRay(flag : boolean);
procedure SetDebugLegalMovesRects3DPovRay(flag : boolean);
procedure SetDebugUpSideFacesRects3DPovRay(flag : boolean);
function GetDebugBoundingRects3DPovRay : boolean;
function GetDebugLegalMovesRects3DPovRay : boolean;
function GetDebugUpSideFacesRects3DPovRay : boolean;


procedure DebugBoundingRects3DPovRay;
procedure DebugLegalMovesRects3DPovRay;
procedure DebugUpSideFacesRects3DPovRay;

IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QDOffScreen, MacErrors, Sound, MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitCarbonisation, UnitOffScreenGraphics, UnitFichiersPICT, UnitFichierPhotos
    , UnitPositionEtTrait, UnitBufferedPICT, UnitRapport, UnitTroisiemeDimension, UnitAffichageArbreDeJeu, UnitArbreDeJeuCourant, UnitFichiersTEXT, MyStrings
    , UnitGeometrie, SNEvents, UnitAffichagePlateau ;
{$ELSEC}
    ;
    {$I prelink/3DPovRayPicts.lk}
{$ENDC}


{END_USE_CLAUSE}

















var tailleImagesPovRay : Point;
    positionScoreNoirPovRay : Point;
    positionScoreBlancPovRay : Point;
    positionDemandeCoupPovRay : Point;
    positionMeilleureSuitePovRay : Point;

    avecDebugBoundingRects3DPovRay : boolean;
    avecDebugLegalMovesRects3DPovRay : boolean;
    avecDebugUpSideFacesRects3DPovRay : boolean;

    gPovRayGWorld : GWorldPtr;
    gPovGWorldPixMap  : PixMapHandle;
    gPovOldWindortPort : CGrafPtr;
    gPovOldDevice : GDHandle;


procedure InitUnit3DPovRayPict;
begin
  gPovRayGWorld := NIL;
  SetTailleImagesPovRay(MakePoint(0,0));
  SetPositionScorePovRay3D(pionNoir,MakePoint(-1000,-1000));
  SetPositionScorePovRay3D(pionBlanc,MakePoint(-1000,-1000));
  SetPositionDemandeCoupPovRay3D(MakePoint(-1000,-1000));
  SetPositionMeilleureSuitePovRay3D(MakePoint(-1000,-1000));
  SetDebugBoundingRects3DPovRay(false);
  SetDebugLegalMovesRects3DPovRay(false);
  SetDebugUpSideFacesRects3DPovRay(false);
end;


procedure LibereMemoireUnit2DPovRayPicts;
begin
  KillPovOffScreenWorld;
end;



procedure SetTailleImagesPovRay(taille : Point);
begin
  tailleImagesPovRay.h := taille.h;
  tailleImagesPovRay.v := taille.v;
end;

procedure SetPositionScorePovRay3D(color : SInt16; loc : Point);
begin
  if color = pionNoir then positionScoreNoirPovRay := loc;
  if color = pionBlanc then positionScoreBlancPovRay := loc;
end;

procedure SetPositionDemandeCoupPovRay3D(loc : Point);
begin
  positionDemandeCoupPovRay := loc;
end;

procedure SetPositionMeilleureSuitePovRay3D(loc : Point);
begin
  positionMeilleureSuitePovRay := loc;
end;

function GetPositionScorePovRay3D(color : SInt16) : Point;
begin
  if color = pionNoir then GetPositionScorePovRay3D := positionScoreNoirPovRay;
  if color = pionBlanc then GetPositionScorePovRay3D := positionScoreBlancPovRay;
end;

function GetPositionDemandeCoupPovRay3D : Point;
begin
  GetPositionDemandeCoupPovRay3D := positionDemandeCoupPovRay;
end;

function GetPositionMeilleureSuitePovRay3D : Point;
begin
  GetPositionMeilleureSuitePovRay3D := positionMeilleureSuitePovRay;
end;

function GetTailleImagesPovRay : Point;
begin
  GetTailleImagesPovRay := tailleImagesPovRay;
end;


procedure BeginDrawingInPovRayOffScreen;
var ignored : boolean;
begin
  GetGWorld(gPovOldWindortPort,gPovOldDevice);
  SetGWorld(gPovRayGWorld, NIL);
  gPovGWorldPixMap := GetGWorldPixMap(gPovRayGWorld);
  ignored := LockPixels(gPovGWorldPixMap);
end;


procedure EndDrawingInPovRayOffScreen;
begin
  UnlockPixels(gPovGWorldPixMap);
  SetGWorld(gPovOldWindortPort,gPovOldDevice);
end;



procedure DumpWorkToScreenFromPovRayOffScreen(sourceRect,targetRect : rect; targetWindow : WindowPtr);
var theMixMap : PixMapHandle;
    ignored : boolean;
begin
  if gPovRayGWorld <> NIL then
    begin
      theMixMap := GetGWorldPixMap(gPovRayGWorld);
      ignored := LockPixels(theMixMap);
      DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,GetWindowPort(targetWindow));
      UnlockPixels(theMixMap);
    end;
end;


procedure DumpRgnOffScreenGWorld(sourceRect,targetRect : rect; offScreenWork,targetWindow : GWorldPtr; maskRgn : RgnHandle);
var theMixMap : PixMapHandle;
    ignored : boolean;
begin
  if gPovRayGWorld <> NIL then
    begin
      theMixMap := GetGWorldPixMap(gPovRayGWorld);
      ignored := LockPixels(theMixMap);
      CopyBits(GetPortBitMapForCopyBits(OffScreenWork)^ ,
               GetPortBitMapForCopyBits(targetWindow)^ ,
               sourceRect, targetRect,srcCopy, maskRgn);
      UnlockPixels(theMixMap);
    end;
end;


function RectanglePictDansPovRayGWorld(couleur : SInt16) : rect;
var res : rect;
begin
  case couleur of
    pionNoir               : SetRect(res, 2+1*tailleImagesPovRay.h,0, 2+2*tailleImagesPovRay.h,tailleImagesPovRay.v);
    pionBlanc              : SetRect(res, 4+2*tailleImagesPovRay.h,0, 4+3*tailleImagesPovRay.h,tailleImagesPovRay.v);
    pionVide               : SetRect(res, 6+3*tailleImagesPovRay.h,0, 6+4*tailleImagesPovRay.h,tailleImagesPovRay.v);
    pionMontreCoupLegal    : SetRect(res, 8+4*tailleImagesPovRay.h,0, 8+5*tailleImagesPovRay.h,tailleImagesPovRay.v);
    pionSuggestionDeCassio : SetRect(res,10+5*tailleImagesPovRay.h,0,10+6*tailleImagesPovRay.h,tailleImagesPovRay.v);
    otherwise  SetRect(res,0,0,0,0);
  end;
  RectanglePictDansPovRayGWorld := res;
end;


function DecalagePictDansPovRayGWorld(couleur : SInt16) : SInt16;
var res : SInt16;
begin
  case couleur of
    pionNoir               : res :=  2+1*tailleImagesPovRay.h;
    pionBlanc              : res :=  4+2*tailleImagesPovRay.h;
    pionVide               : res :=  6+3*tailleImagesPovRay.h;
    pionMontreCoupLegal    : res :=  8+4*tailleImagesPovRay.h;
    pionSuggestionDeCassio : res := 10+5*tailleImagesPovRay.h;
    otherwise  res := 0;
  end;
  DecalagePictDansPovRayGWorld := res;
end;



function CreatePovOffScreenWorld(var quelleTexture : CouleurOthellierRec) : OSErr;
var nomDansMenu,path : String255;
    fic : FichierTEXT;
    error : OSErr;
    unRect,screenRect : rect;
    oldPort : grafPtr;


    procedure ExitIfError(whichError : OSErr; fonctionAppelante : String255);
    begin
      if (whichError <> NoErr) then
        begin
          SetPort(oldPort);
          if (error <> opWrErr) and
             (error <> memFullErr) and
             (error <> cTempMemErr) and
             (error <> cNoMemErr) then
            WritelnDansRapport('error = '+IntToStr(whichError)+' dans CreatePovOffScreenWorld, fonction appelante = '+fonctionAppelante);
          CreatePovOffScreenWorld := whichError;
          exit;
        end;
    end;

begin
  CreatePovOffScreenWorld := NoErr;

  GetPort(oldPort);

  nomDansMenu := GetNomDansMenuPourCetteTexture(quelleTexture);
  if (nomDansMenu = '')
    then
      ExitIfError(-2,'nomDansMenu')
    else
	    begin

	      {détruire eventuellement l'ancien GWorld}
	      KillPovOffScreenWorld;

	      {et en créer un nouveau}
	      SetRect(unRect,0,0,6*tailleImagesPovRay.h + 12,tailleImagesPovRay.v + 12);
	      error := CreateTempOffScreenWorld(unRect,gPovRayGWorld);

	      SetRect(screenRect,0,0,tailleImagesPovRay.h,tailleImagesPovRay.v);
	      {SetRect(screenRect,0,0,512,342);}

	      if (gPovRayGWorld = NIL) or (error <> NoErr)
	        then
	          begin
	            if (gPovRayGWorld = NIL) then
	              WritelnStringDansRapport(' gPovRayGWorld = NIL !!! dans CreatePovOffScreenWorld');
	            if error <> NoErr
	              then ExitIfError(error,'CreateTempOffScreenWorld')
	              else ExitIfError(-1,'(gPovRayGWorld = NIL)');
	          end
	        else
	          begin

				      unRect := RectanglePictDansPovRayGWorld(pionNoir);
				      path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionNoir);
				      if FichierPhotosExisteSurLeDisque(path,fic)
				        then
					        begin
					          error := OuvreFichierTexte(fic);
					          ExitIfError(error,'OuvreFichierTexte(pionsNoirs)');

					          BeginDrawingInPovRayOffScreen;
					          error := DrawPictFile(fic,unRect);
					          EndDrawingInPovRayOffScreen;
					          ExitIfError(error,'DrawPicFile(pionsNoirs)');

					          error := FermeFichierTexte(fic);
					          ExitIfError(error,'FermeFichierTexte(pionsNoirs)');
					        end
					      else
					        ExitIfError(fnfErr,'FileNotFound(pionsNoirs)');


              if (wPlateauPtr <> NIL) and windowPlateauOpen and GetDebugUpSideFacesRects3DPovRay then
				        begin
				          SetPortByWindow(wPlateauPtr);
				          DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				          DebugUpSideFacesRects3DPovRay;
				          FlushWindow(wPlateauPtr);
				          AttendFrappeClavier;
				        end;
				      if (wPlateauPtr <> NIL) and windowPlateauOpen and GetDebugBoundingRects3DPovRay then
				        begin
				          SetPortByWindow(wPlateauPtr);
				          DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				          DebugBoundingRects3DPovRay;
				          FlushWindow(wPlateauPtr);
				          AttendFrappeClavier;
				        end;

				      unRect := RectanglePictDansPovRayGWorld(pionBlanc);
				      path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionBlanc);
				      if FichierPhotosExisteSurLeDisque(path,fic)
				        then
					        begin
					          error := OuvreFichierTexte(fic);
					          ExitIfError(error,'OuvreFichierTexte(pionsBlancs)');

					          BeginDrawingInPovRayOffScreen;
					          error := DrawPictFile(fic,unRect);
					          EndDrawingInPovRayOffScreen;
					          ExitIfError(error,'DrawPicFile(pionsBlancs)');

					          error := FermeFichierTexte(fic);
					          ExitIfError(error,'FermeFichierTexte(pionsBlancs)');
					        end
					      else
					        ExitIfError(fnfErr,'FileNotFound(pionsBlancs)');


				      {
				      SetPortByWindow(wPlateauPtr);
				      DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				      FlushWindow(wPlateauPtr);
              }

				      unRect := RectanglePictDansPovRayGWorld(pionVide);
				      path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionVide);
				      if FichierPhotosExisteSurLeDisque(path,fic)
				        then
					        begin
					          error := OuvreFichierTexte(fic);
					          ExitIfError(error,'OuvreFichierTexte(pionsVides)');

					          BeginDrawingInPovRayOffScreen;
					          error := DrawPictFile(fic,unRect);
					          EndDrawingInPovRayOffScreen;
					          ExitIfError(error,'DrawPicFile(pionsVides)');

					          error := FermeFichierTexte(fic);
					          ExitIfError(error,'FermeFichierTexte(pionsVides)');
					        end
					      else
					        ExitIfError(fnfErr,'FileNotFound(pionsVides)');

				      {
				      SetPortByWindow(wPlateauPtr);
				      DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				      FlushWindow(wPlateauPtr);
              }

				      unRect := RectanglePictDansPovRayGWorld(pionMontreCoupLegal);
				      path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionMontreCoupLegal);
				      if FichierPhotosExisteSurLeDisque(path,fic)
				        then
					        begin
					          error := OuvreFichierTexte(fic);
					          ExitIfError(error,'OuvreFichierTexte(pionsMontreCoupsLegaux)');

					          BeginDrawingInPovRayOffScreen;
					          error := DrawPictFile(fic,unRect);
					          EndDrawingInPovRayOffScreen;
					          ExitIfError(error,'DrawPicFile(pionsMontreCoupsLegaux)');

					          error := FermeFichierTexte(fic);
					          ExitIfError(error,'FermeFichierTexte(pionsMontreCoupsLegaux)');
					        end
					      else
					        ExitIfError(fnfErr,'FileNotFound(pionsMontreCoupsLegaux)');

				      if (wPlateauPtr <> NIL) and windowPlateauOpen and GetDebugLegalMovesRects3DPovRay then
				        begin
				          SetPortByWindow(wPlateauPtr);
				          DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				          DebugLegalMovesRects3DPovRay;
				          FlushWindow(wPlateauPtr);
				          AttendFrappeClavier;
				        end;

				      unRect := RectanglePictDansPovRayGWorld(pionSuggestionDeCassio);
				      path := PathFichierPicture3DDeCetteFamille(nomDansMenu,pionSuggestionDeCassio);
				      if FichierPhotosExisteSurLeDisque(path,fic)
				        then
					        begin
					          error := OuvreFichierTexte(fic);
					          ExitIfError(error,'OuvreFichierTexte(pionsSuggestionDeCassio)');

					          BeginDrawingInPovRayOffScreen;
					          error := DrawPictFile(fic,unRect);
					          EndDrawingInPovRayOffScreen;
					          ExitIfError(error,'DrawPicFile(pionsSuggestionDeCassio)');

					          error := FermeFichierTexte(fic);
					          ExitIfError(error,'FermeFichierTexte(pionsSuggestionDeCassio)');
					        end
					      else
					        ExitIfError(fnfErr,'FileNotFound(pionsSuggestionDeCassio)');

				      (*
				      SetPortByWindow(wPlateauPtr);
				      {SetRect(unRect,0,0,6*tailleImagesPovRay.h + 12,tailleImagesPovRay.v);}
				      unRect := RectanglePictDansPovRayGWorld(pionBlanc);
				      DumpWorkToScreenFromPovRayOffScreen(unRect,screenRect,wPlateauPtr);
				      *)

	          end;

	      SetPort(oldPort);
	    end;
end;



procedure KillPovOffScreenWorld;
begin
  if (gPovRayGWorld <> NIL) then
    begin
      KillTempOffscreenWorld(gPovRayGWorld);
      gPovRayGWorld := NIL
    end;
end;





procedure DumpDiscToGWorld(whichSquare : SInt16; couleur : SInt16; targetGWolrd : GWorldPtr);
var targetRect,sourceRect{,sourceRect2} : rect;
    {maskRect : rect;
    maskRgn : RgnHandle;
    count : SInt16; }
begin
  if (whichSquare >= 11) and (whichSquare <= 88) then
    begin
      targetRect := GetBoundingRect3D(whichSquare);

      sourceRect := targetRect;
      case couleur of
        kCaseDevantEtreRedessinee :
		      begin
		        case GetCouleurOfSquareDansJeuCourant(whichSquare) of
		          pionBlanc,pionNoir:
		            begin
		              DumpDiscToGWorld(whichSquare,GetCouleurOfSquareDansJeuCourant(whichSquare),targetGWolrd);
		              if afficheNumeroCoup then DessineNumeroDernierCoupSurOthellier([whichSquare],GetCurrentNode);
		              AfficheProprietesOfCurrentNode(false,[whichSquare],'AfficheProprietesOfCurrentNode {1}');
		            end;
		          otherwise
		            begin
		              DumpDiscToGWorld(whichSquare,pionVide,targetGWolrd);
		              if aideDebutant then DessineAideDebutant(false,[whichSquare]);
		              DessineAutresInfosSurCasesAideDebutant([whichSquare],'DumpDiscToGWorld');
		            end;
		        end;
		      end;
        pionNoir :
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionNoir then
	          begin
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionNoir),0);
	            DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,targetGWolrd);
	            SetValeurDessinEnTraceDeRayon(whichSquare,pionNoir);
	          end;
        pionBlanc :
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionBlanc then
	          begin
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionBlanc),0);
	            DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,targetGWolrd);
	            SetValeurDessinEnTraceDeRayon(whichSquare,pionBlanc);
	          end;
        pionVide,pionEffaceCaseLarge,effaceCase:
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionVide then
	          begin
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionVide),0);
	            DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,targetGWolrd);
	            SetValeurDessinEnTraceDeRayon(whichSquare,pionVide);
	            SetOthellierEstSale(whichSquare,false);
	          end;
        pionMontreCoupLegal :
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionMontreCoupLegal then
	          begin
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionMontreCoupLegal),0);
	            DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,targetGWolrd);
	            SetValeurDessinEnTraceDeRayon(whichSquare,pionMontreCoupLegal);
	            SetOthellierEstSale(whichSquare,true);
	          end;
	      pionSuggestionDeCassio :
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionSuggestionDeCassio then
	          begin
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionSuggestionDeCassio),0);
	            DumpWorkToScreen(sourceRect,targetRect,gPovRayGWorld,targetGWolrd);
	            SetValeurDessinEnTraceDeRayon(whichSquare,pionSuggestionDeCassio);
	            SetOthellierEstSale(whichSquare,true);
	          end;
	      (*
        pionSuggestionDeCassio :
          if GetValeurDessinEnTraceDeRayon(whichSquare) <> pionSuggestionDeCassio then
	          begin
	            sourceRect := GetBoundingRect3D(whichSquare);
	            OffsetRect(sourceRect,DecalagePictDansPovRayGWorld(pionVide),0);

	            sourceRect2 := GetBoundingRect3D(whichSquare);
	            OffsetRect(sourceRect2,DecalagePictDansPovRayGWorld(pionMontreCoupLegal),0);

	            maskRect := GetRect3DDessous(whichSquare);
	            InsetRect(maskRect,1,1);
	            count := 0;
	            while maskRect.right >= maskRect.left do
	              begin
	                maskRgn := NewRgn;
	                OpenRgn;
	                FrameOval(maskRect);
	                CloseRgn(maskRgn);
	                if odd(count)
	                  then DumpRgnOffScreenGWorld(sourceRect,targetRect,gPovRayGWorld,targetGWolrd,maskRgn)
	                  else DumpRgnOffScreenGWorld(sourceRect2,targetRect,gPovRayGWorld,targetGWolrd,maskRgn);
	                InsetRect(maskRect,2,2);
	                inc(count);
	                DisposeRgn(maskRgn);
	              end;

	            SetValeurDessinEnTraceDeRayon(whichSquare,pionSuggestionDeCassio);
	            SetOthellierEstSale(whichSquare,true);
	          end;
	      *)
        otherwise
          begin
            SysBeep(0);
            WritelnDansRapport('couleur inconnue ('+IntToStr(couleur)+') dans DumpDiscToGWorld !!!');
          end;
      end; {case}
    end;
end;

procedure DessinePionAvecPovRay3D(whichSquare : SInt16; couleur : SInt16);
var theMixMap : PixMapHandle;
    ignored : boolean;
    oldPort : grafPtr;
begin
  if windowPlateauOpen and (whichSquare >= 11) and (whichSquare <= 88) and (gPovRayGWorld <> NIL) then
    begin
      GetPort(oldPort);

      theMixMap := GetGWorldPixMap(gPovRayGWorld);
      ignored := LockPixels(theMixMap);
      SetPortByWindow(wPlateauPtr);
      DumpDiscToGWorld(whichSquare,couleur,GetWindowPort(wPlateauPtr));
      UnlockPixels(theMixMap);

      SetPort(oldPort);

    end;
end;

procedure DessinePionAvecPovRay3DDeplacement(whichSquare : SInt16; couleur : SInt16; offset : Point);
var theMixMap : PixMapHandle;
    ignored : boolean;
    oldPort : grafPtr;
begin
  if windowPlateauOpen and (whichSquare >= 11) and (whichSquare <= 88) and (gPovRayGWorld <> NIL) then
    begin
      GetPort(oldPort);

      theMixMap := GetGWorldPixMap(gPovRayGWorld);
      ignored := LockPixels(theMixMap);
      SetPortByWindow(wPlateauPtr);

      SetOrigin(-offset.h,-offset.v);
      DumpDiscToGWorld(whichSquare,couleur,GetWindowPort(wPlateauPtr));
      SetOrigin(0,0);

      UnlockPixels(theMixMap);
      SetPort(oldPort);
    end;
end;

procedure DessinePositionAvecPovRay3D(position : plateauOthello);
var oldPort : grafPtr;
    screenRect : rect;
    square,t : SInt16;
begin
  if windowPlateauOpen and (gPovRayGWorld <> NIL) then
    begin
      GetPort(oldPort);

      SetRect(screenRect,0,0,tailleImagesPovRay.h,tailleImagesPovRay.v);

      {on met le plateau vide dans le buffer off-screen}
      BeginDrawingInPovRayOffScreen;
      DumpWorkToScreen(RectanglePictDansPovRayGWorld(pionVide),screenRect,gPovRayGWorld,gPovRayGWorld);
      EndDrawingInPovRayOffScreen;

      {on met tous les pions}
      for t := 1 to 64 do
        begin
          BeginDrawingInPovRayOffScreen;
          square := othellier[t];
          DumpDiscToGWorld(square,position[square],gPovRayGWorld);
          EndDrawingInPovRayOffScreen;
        end;

      {on transfert le buffer off-screen dans la fenetre wPlateauPtr}
      SetPortByWindow(wPlateauPtr);
      DumpWorkToScreenFromPovRayOffScreen(screenRect,screenRect,wPlateauPtr);

      SetPort(oldPort);
    end;
end;

procedure EraseRectPovRay3D(myRect : rect);
var oldPort : grafPtr;
    screenRect,auxRect : rect;
begin
  if windowPlateauOpen and (gPovRayGWorld <> NIL) then
    begin
      SetRect(screenRect,0,0,tailleImagesPovRay.h,tailleImagesPovRay.v);

      if SectRect(myRect,screenRect,myRect) then
        begin
          GetPort(oldPort);

          auxRect := myRect;
          OffsetRect(auxRect,DecalagePictDansPovRayGWorld(pionVide),0);

          {on transfert le buffer off-screen dans la fenetre wPlateauPtr}
		      SetPortByWindow(wPlateauPtr);
		      DumpWorkToScreenFromPovRayOffScreen(auxRect,myRect,wPlateauPtr);

          SetPort(oldPort);
        end;
    end;
end;

procedure DebugBoundingRects3DPovRay;
var i : SInt16;
    oldPort : grafPtr;
begin
  {let's draw the bounding boxes}
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  for i := 11 to 88 do
    begin
      if odd(i div 10)
        then
          if odd(i)
            then ForeColor(whiteColor)
            else ForeColor(BlueColor)
        else
          if not(odd(i))
            then ForeColor(whiteColor)
            else ForeColor(BlueColor);
      FrameRect(GetBoundingRect3D(i));
    end;
  ForeColor(blackColor);
  SetPort(oldPort);
end;

procedure DebugLegalMovesRects3DPovRay;
var i : SInt16;
    oldPort : grafPtr;
begin
	{let's draw the rectangles of legal moves}
	GetPort(oldPort);
	SetPortByWindow(wPlateauPtr);
	for i := 11 to 88 do
	  begin
	    ForeColor(yellowColor);
	    FrameRect(GetRect3DDessous(i));
	  end;
	ForeColor(blackColor);
	SetPort(oldPort);
end;

procedure DebugUpSideFacesRects3DPovRay;
var i : SInt16;
    oldPort : grafPtr;
begin
  {let's draw the rectangles of up faces of discs}
  GetPort(oldPort);
  SetPortByWindow(wPlateauPtr);
  for i := 11 to 88 do
    begin
      ForeColor(magentaColor);
      FrameRect(GetRect3DDessus(i));
    end;
  ForeColor(blackColor);
  SetPort(oldPort);
end;

procedure SetDebugBoundingRects3DPovRay(flag : boolean);
begin
  avecDebugBoundingRects3DPovRay := flag;
end;

procedure SetDebugLegalMovesRects3DPovRay(flag : boolean);
begin
  avecDebugLegalMovesRects3DPovRay := flag;
end;

procedure SetDebugUpSideFacesRects3DPovRay(flag : boolean);
begin
  avecDebugUpSideFacesRects3DPovRay := flag;
end;

function GetDebugBoundingRects3DPovRay : boolean;
begin
  GetDebugBoundingRects3DPovRay := avecDebugBoundingRects3DPovRay;
end;

function GetDebugLegalMovesRects3DPovRay : boolean;
begin
  GetDebugLegalMovesRects3DPovRay := avecDebugLegalMovesRects3DPovRay;
end;

function GetDebugUpSideFacesRects3DPovRay : boolean;
begin
  GetDebugUpSideFacesRects3DPovRay := avecDebugUpSideFacesRects3DPovRay;
end;




END.
