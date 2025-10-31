UNIT UnitBaseNouveauFormat;

INTERFACE





 USES UnitDefCassio, UnitDefCFNetworkHTTP;


{ initialisation de l'unite }
procedure InitUnitBaseNouveauFormat;
procedure LibereMemoireUnitBaseNouveauFormat;

{ gestion du dialogue de chargement de la base }
function ActionBaseDeDonnee(actionDemandee : SInt16; var partieEnChaine : String255) : boolean;
procedure DoLectureJoueursEtTournoi(nomsCourts : boolean);


{ dessin du dialogue }
procedure DessineOthellierLecture(whichWindow : WindowRef);
procedure DessineOthellierLectureHistorique(whichWindow : WindowRef);
function CouleurDesPetitsOthelliers : RGBColor;
procedure AffichePositionLecture(position : plateauOthello; whichWindow : WindowRef);
procedure AfficheHistoriqueLecture(position : plateauOthello; whichWindow : WindowRef);
procedure EcritMessageLectureBase(s : String255; posH,posV : SInt16);
procedure SetDoitDessinerMessagesChargementBase(newValue : boolean; oldValue : booleanPtr);
function DoitDessinerMessagesChargementBase : boolean;


{ les petits othelliers dans le dialogue }
procedure InitialisePlateauLecture(whichWindow : WindowRef);
procedure JoueOuverturePlateauLecture(ligne : PackedThorGame; whichWindow : WindowRef);
procedure DejoueUnCoupPlateauLecture(whichWindow : WindowRef);
procedure DejoueNCoupsPlateauLecture(coup : SInt16; whichWindow : WindowRef);
function ClicDansOthellierLecture(mouseLoc : Point; whichWindow : WindowRef) : boolean;
procedure ClicDansHistoriqueLecture(mouseLoc : Point; whichWindow : WindowRef);


{ filtre d'evenement dans les dialogues de la base }
function FiltreRechercheDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
function FiltreLectureDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;


{ utilitaires sur les annees }
function AnneeIsCompatible(anneeDeLaPartie,anneeDeRecherche,testInegalite : SInt16) : boolean;
function StringEnAnneeSansBugAn2000(s : String255) : SInt32;


{ les menus pour choisir les bases utilisees dans le dialogue de chargement }
procedure InstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec; whichMenuID : SInt16; filtre : filtreDistributionProc);
procedure DesinstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec);
function NroDistribToItemNumber(popUpBases : menuFlottantBasesRec; nroDistribCherchee : SInt32) : SInt32;
function ItemNumberToNroDistrib(popUpBases : menuFlottantBasesRec; itemNumberCherche : SInt32) : SInt32;


{ gestion des telechargement automatiques de la base depuis othello.federation.free.fr }
procedure MettreAJourLaBaseParTelechargement;


{ gestion du double local du listing du directory }
procedure ParserLigneOfWTHORDirectoryOnInternet(var ligne : LongString; var theFic : basicfile; var result : SInt32);
procedure ComparerListingDuRepertoireDeLaBaseSurInternet(pathFichierTelecharge : String255);


{ fonctions de reception d'un fichier telecharge }
procedure GererTelechargementAutomatiqueDeLaBase(pathFichierTelecharge : String255; tailleFichier : SInt32);
function TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase( whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;
procedure GererCompletionTelechargementFichierDeLaBase(pathFichierTelecharge : String255);
procedure TelechargerFichierDeLaBase(nomFichier : String255);
function LigneEstDansNotreListingWthorLocal(ligne : String255) : boolean;
procedure VerifierPresenceFichierWThorChezNous(var ligne : LongString; var theFic : basicfile; var result : SInt32);


{ petite liste locale des telechargements simultanes de la base }
procedure AjouterUnFichierWThorDansListeATelecharger(nomFichier : String255);
procedure EnleverUnFichierWthorDansListeATelecharger(nomFichier : String255);
function NombreTelechargementsWthorEnCours : SInt32;
procedure GererTelechargementWThor;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, fp, Sound, QuickdrawText, Fonts, Script, MacWindows

{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitMenus, MyQuickDraw, SNMenus, UnitJaponais, UnitStrategie, UnitEvenement, UnitCriteres
    , basicfile, UnitFichierAbstrait, UnitRapportImplementation, UnitCarbonisation, UnitUtilitaires, UnitProgressBar, UnitAccesNouveauFormat, UnitDiagramFforum
    , UnitTriListe, UnitListe, UnitNouveauFormat, UnitCalculCouleurCassio, UnitScannerOthellistique, UnitInterversions, UnitOth2, UnitRapport
    , SNEvents, UnitCouleur, UnitDialog, UnitScannerUtils, MyStrings, UnitNormalisation, UnitServicesMemoire, UnitFenetres
    , UnitPackedThorGame, MyAntialiasing, MyFonts, MyMathUtils, UnitRetrograde, UnitImportDesNoms, UnitCurseur, MyFileSystemUtils
    , UnitCFNetworkHTTP, MyStrings, UnitActions, UnitModes, UnitSolitaire, UnitPositionEtTrait, UnitLongString, UnitStatistiques ;
{$ELSEC}
    ;
    {$I prelink/BaseNouveauFormat.lk}
{$ENDC}


{END_USE_CLAUSE}




const kYpositionMessageBase : SInt32 = 189;
      kYpositionNbPartiesDansBase : SInt32 = 202;
      kYpositionNbPartiesPotentiellementLues : SInt32 = 213;


const kNumberOfSimultaneousWTHORDownloads = 10;
      kTailleListeDesTelechargementsWTHOR = 100;

var gListeFichiersWthorATelecharger :
      record
        cardinal                           : SInt32;
        noms                               : array[1..kTailleListeDesTelechargementsWTHOR] of String255Hdl;
        telechargementEnCours              : array[1..kTailleListeDesTelechargementsWTHOR] of boolean;
        dernierTickLancementTelechargement : SInt32;
      end;


{ les constantes decrivant les items du dialogue de chargement de la base }

CONST
    LectureBouton               = 1;
    AnnulerBouton               = 2;
    LectureAntichronologiqueBox = 3;
    BasesStaticText             = 4;
    ScoreNoirText               = 5;
    JoueurNoirText              = 6;
    JoueurBlancText             = 7;
    TournoiText                 = 8;
    AnneeText                   = 9;
    NroText                     = 10;
    CoupPrecedentBouton         = 10;
    OuvertureStaticText         = 17;
    GenreTestTextLectureBase    = 18;
    OuvertureUserItemPopUp      = 19;
    BasesUserItemPopUp          = 20;


var mustBeAPerfectMatch : array[LectureBouton..BasesUserItemPopUp] of boolean;

procedure InitUnitBaseNouveauFormat;
var k : SInt32;
begin
  with gListeFichiersWthorATelecharger do
    begin
      cardinal                           := 0;
      dernierTickLancementTelechargement := 0;

      for k := 1 to kTailleListeDesTelechargementsWTHOR do
        begin
          noms[k]                  := NIL;
          telechargementEnCours[k] := false;
        end;
    end;

  gDernierTempsDeChargementDeLaBase := 1000;  {en ticks}
  SetDoitDessinerMessagesChargementBase(true, NIL);

  for k := LectureBouton to BasesUserItemPopUp do
    mustBeAPerfectMatch[k] := false;

end;


procedure AjusterPositionMessagesBase(fenetreMessagesBase, dp : WindowRef; forcerValeurParDefaut : boolean);
var delta : SInt32;
begin

  // valeurs par defaut
  kYpositionMessageBase := 189;
  kYpositionNbPartiesDansBase := 202;
  kYpositionNbPartiesPotentiellementLues := 213;

  // si on affiche dans la fenetre de la liste ou dans
  // la fenetre des statistiques, il faudra penser И tout remonter
  if not(forcerValeurParDefaut) and DoitDessinerMessagesChargementBase and
     (fenetreMessagesBase <> NIL) and (fenetreMessagesBase <> dp)
    then delta := -150
    else delta := 0;

  // on remonte eventuellement tout
  kYpositionMessageBase                  := kYpositionMessageBase + delta;
  kYpositionNbPartiesDansBase            := kYpositionNbPartiesDansBase + delta;
  kYpositionNbPartiesPotentiellementLues := kYpositionNbPartiesPotentiellementLues + delta;

end;



procedure LibereMemoireUnitBaseNouveauFormat;
var k : SInt32;
begin
  with gListeFichiersWthorATelecharger do
    begin
      cardinal                   := 0;

      for k := 1 to kTailleListeDesTelechargementsWTHOR do
        begin
          if (noms[k] <> NIL) then DisposeMemoryHdl(Handle(noms[k]));
          telechargementEnCours[k] := false;
        end;
    end;
end;



{ liste des telechargements simultanes de la base }
procedure AjouterUnFichierWThorDansListeATelecharger(nomFichier : String255);
var k : SInt32;
begin

  if (nomFichier = '') then exit;

  with gListeFichiersWthorATelecharger do
    begin
      for k := 1 to kTailleListeDesTelechargementsWTHOR do
        if (noms[k] = NIL) and not(telechargementEnCours[k]) then
          begin
            noms[k] := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
            if (noms[k] <> NIL) then
              begin
                inc(cardinal);
                noms[k]^^ := nomFichier;

                (* WritelnDansRapport('Il faut mettre И jour le fichier : ' + nomFichier); *)
              end;
            leave;
          end;
    end;

end;


procedure EnleverUnFichierWthorDansListeATelecharger(nomFichier : String255);
var k : SInt32;
begin

  if (nomFichier = '') then exit;

  (* WritelnDansRapport('Terminaison du fichier : ' + nomFichier); *)

  with gListeFichiersWthorATelecharger do
    begin
      for k := 1 to kTailleListeDesTelechargementsWTHOR do
        if (noms[k] <> NIL) and (noms[k]^^ = nomFichier) then
          begin

            DisposeMemoryHdl(Handle(noms[k]));
            telechargementEnCours[k] := false;


            dec(cardinal);

            (* WritelnDansRapport('Le fichier : ' + nomFichier + ' a ete supprimer de la liste des fichies И telecharger'); *)

            Leave;
          end;
    end;

end;


procedure GererTelechargementWThor;
var k : SInt32;
begin
  with gListeFichiersWthorATelecharger do
    begin
      if (cardinal > 0) and
         (abs(TickCount - dernierTickLancementTelechargement) > 0) and
         (NombreTelechargementsWthorEnCours < kNumberOfSimultaneousWTHORDownloads) then
       begin
         // chercher un fichier dans la liste des fichiers a telecharger

         for k := 1 to kTailleListeDesTelechargementsWTHOR do
           if (noms[k] <> NIL) and not(telechargementEnCours[k]) then
             begin
               dernierTickLancementTelechargement := TickCount;

               telechargementEnCours[k]           := true;

               (*
               WriteNumDansRapport('Tick = ',TickCount);
               WritelnDansRapport(' => lancement du fichier : ' + noms[k]^^);
               *)

               TelechargerFichierDeLaBase(noms[k]^^);
               Leave;
             end;
       end;
    end;
end;


function NombreTelechargementsWthorEnCours : SInt32;
var k,compteur : SInt32;
begin
  compteur := 0;

  with gListeFichiersWthorATelecharger do
  for k := 1 to kTailleListeDesTelechargementsWTHOR do
    if telechargementEnCours[k] and (noms[k] <> NIL)
      then inc(compteur);

  NombreTelechargementsWthorEnCours := compteur;
end;



function StringEnAnneeSansBugAn2000(s : String255) : SInt32;
var result : SInt32;
begin
  s := GarderSeulementLesChiffres(s);
  if s = ''
    then
      result := -1
    else
      begin
        if LENGTH_OF_STRING(s) = 4
          then
            begin
              StrToInt32(s,result);
              if result < kDebutDuMondeOthellistique then result := -1;
              if result > kFinDuMondeOthellistique then result := -1;
            end
          else
        if LENGTH_OF_STRING(s) = 2
          then
            begin
              StrToInt32(s,result);
              if (result <> 19) and (result <> 20) then
                begin
                  if (0 <= result) and (result < kChangementDeSiecleOthellistique) then result := 2000+result;
                  if (kChangementDeSiecleOthellistique <= result) and (result <= 99) then result := 1900+result;
                end;
            end
          else
            begin
			        StrToInt32(s,result);
			      end;
  end;

  StringEnAnneeSansBugAn2000 := result;
end;


function CouleurDesPetitsOthelliers : RGBColor;
var couleurDesCases : RGBColor;
    textureInconnue : boolean;
begin


  if gCouleurOthellier.estUneImage
    then
      begin
        couleurDesCases := PlusProcheCouleurRGBOfTexture(gCouleurOthellier,textureInconnue);
        couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,5000);

        if textureInconnue or RGBColorEstFoncee(couleurDesCases,10000)
          then couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,40000);

      end
    else
      begin
        couleurDesCases := gCouleurOthellier.RGB;
        couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,5000);

        if RGBColorEstFoncee(couleurDesCases,20000)
          then couleurDesCases := EclaircirCouleurDeCetteQuantite(couleurDesCases,40000);
      end;

  CouleurDesPetitsOthelliers := couleurDesCases;
end;


procedure EffaceCasePetitOthellier(whichRect : rect);
var couleurDesCases : RGBColor;
begin
  couleurDesCases := CouleurDesPetitsOthelliers;
  RGBForeColor(couleurDesCases);
  RGBBackColor(couleurDesCases);
  FillRect(whichRect,blackPattern);
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;


procedure DessineOthellierLecture(whichWindow : WindowRef);
const a = 235;
      b = 184;
var i : SInt16;
begin
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurDesPetitsOthelliers,25000));
  SetRect(OthellierLectureRect,a,b,a+8*taillecaselecture,b+8*taillecaselecture);
  for i := 0 to 8 do
    begin
      Moveto(a,b+i*taillecaselecture);
      Lineto(a+8*taillecaselecture,b+i*taillecaselecture);
      Moveto(a+i*taillecaselecture,b);
      Lineto(a+i*taillecaselecture,b+8*taillecaselecture);
    end;
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;

procedure DessineOthellierLectureHistorique(whichWindow : WindowRef);
var a,b,i : SInt16;
begin
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  RGBForeColor(NoircirCouleurDeCetteQuantite(CouleurDesPetitsOthelliers,25000));
  a := OthellierLectureRect.left+9*taillecaselecture;
  b := OthellierLectureRect.top;
  for i := 0 to 8 do
    begin
      Moveto(a,b+i*taillecaselecture);
      Lineto(a+8*taillecaselecture,b+i*taillecaselecture);
      Moveto(a+i*taillecaselecture,b);
      Lineto(a+i*taillecaselecture,b+8*taillecaselecture);
    end;
  RGBForeColor(gPurNoir);
  RGBBackColor(gPurBlanc);
end;


procedure AffichePositionLecture(position : plateauOthello; whichWindow : WindowRef);
var i,j : SInt16;
    unRect : rect;
    x,y : SInt16;
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(whichWindow);
  PenSize(1,1);
  x := OthellierLectureRect.left;
  y := OthellierLectureRect.top;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);

        EffaceCasePetitOthellier(unRect);

        case position[j*10+i] of
          pionVide: {MyEraseRect(unRect)};
          pionNoir: FillOval(unRect,blackPattern);
          pionBlanc: begin
                      FrameOval(unRect);
                      InsetRect(unRect,1,1);
                      EraseOval(unRect);
                     end;
        end;
      end;
  SetPort(oldPort);
end;

procedure AfficheHistoriqueLecture(position : plateauOthello; whichWindow : WindowRef);
var i,j,t,coup : SInt16;
    unRect : rect;
    x,y,larg : SInt16;
    s : String255;
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  SetPortByWindow(whichWindow);

  if SetAntiAliasedTextEnabled(false,9) = NoErr then DoNothing;
  DisableQuartzAntiAliasingThisPort(GetWindowPort(whichWindow));

  PenSize(1,1);
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  MemoryFillChar(@position,sizeof(position),chr(0));
  position[45] := pionNoir; position[54] := pionNoir;
  position[44] := pionBlanc; position[55] := pionBlanc;
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);


        EffaceCasePetitOthellier(unRect);

        case position[j*10+i] of
          pionVide: {MyEraseRect(unRect)};
          pionNoir: FillOval(unRect,blackPattern);
          pionBlanc: begin
                      FrameOval(unRect);
                      InsetRect(unRect,1,1);
                      EraseOval(unRect);
                     end;
        end;
      end;
  TextSize(9);
  TextFont(MonacoID);
  for t := 1 to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
    begin
      coup := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'AfficheHistoriqueLecture');
      i := coup mod 10;
      j := coup div 10;
      SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                       x+i*taillecaselecture,y+j*taillecaselecture);
      s := IntToStr(t);
      larg := MyStringWidth(s);
      if (t >= 10) and (t <= 19)
        then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
        else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
      MyDrawString(s);
    end;
   TextSize(0);
   TextFont(systemFont);

   if gCassioUseQuartzAntialiasing then
	   begin
			 if SetAntiAliasedTextEnabled(true,9) = NoErr then DoNothing;
			 EnableQuartzAntiAliasingThisPort(GetWindowPort(whichWindow),true);
		end;
  SetPort(oldPort);
end;

procedure EcritMessageLectureBase(s : String255; posH,posV : SInt16);
var rectEffacement : rect;
begin
  if DoitDessinerMessagesChargementBase then
    begin
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      SetRect(rectEffacement,10,posV-9,OthellierLectureRect.left,posV+3);
      MyEraseRect(rectEffacement);
      MyEraseRectWithColor(rectEffacement,OrangeCmd,blackPattern,'');
      Moveto(posH,posV);
      MyDrawString(s);
      TextSize(0);
      TextFont(systemFont);
    end;
end;

var gDoitDessinerMessagesChargementBase : boolean;

procedure SetDoitDessinerMessagesChargementBase(newValue : boolean; oldValue : booleanPtr);
begin
  if (oldValue <> NIL)
    then oldValue^ := gDoitDessinerMessagesChargementBase;

  gDoitDessinerMessagesChargementBase := newValue;
end;


function DoitDessinerMessagesChargementBase : boolean;
begin
  DoitDessinerMessagesChargementBase := gDoitDessinerMessagesChargementBase;
end;


procedure VerifiePositionLectureModifiee(var positionLectureModifiee : boolean);
var i,coup : SInt16;
    concordance : boolean;
begin
  if positionLectureModifiee then
    if not(positionFeerique) then
      if GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) = nbreCoup then
        begin
          concordance := true;
          for i := 1 to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
            begin
              coup := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, i, 'VerifiePositionLectureModifiee');
              concordance := concordance and (coup = GetNiemeCoupPartieCourante(i));
            end;
          positionLectureModifiee := not(concordance);
          {if not(positionLectureModifiee) then SysBeep(0);}
        end;
end;


procedure InitialisePlateauLecture(whichWindow : WindowRef);
var i,coup : SInt16;
begin
  positionLectureModifiee := false;
  DessineOthellierLecture(whichWindow);
  DessineOthellierLectureHistorique(whichWindow);
  if positionFeerique or gameOver
    then
      begin
        OthellierDeDepart(PlatLecture);
        positionLectureModifiee := true;
      end
    else PlatLecture := JeuCourant;
  AffichePositionLecture(PlatLecture,whichWindow);
  FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  if not(positionLectureModifiee) then
  for i := 1 to nbreCoup do
    begin
      coup := GetNiemeCoupPartieCourante(i);
      if (coup >= 11) and (coup <= 88) then
        ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, coup);
    end;
  AfficheHistoriqueLecture(PlatLecture,whichWindow);
end;

procedure JoueOuverturePlateauLecture(ligne : PackedThorGame; whichWindow : WindowRef);
var k,x,longueur,trait : SInt16;
    test : boolean;
    nBla,nnoi : SInt32;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ligne);
  OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
  if longueur >= 1 then
    begin
     trait := pionNoir;
     test := true;
     k := 0;
     repeat
       k := k+1;
       x := GET_NTH_MOVE_OF_PACKED_GAME(ligne, k, 'JoueOuverturePlateauLecture');
       if platlecture[x] = pionVide then
       begin
         test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
         if test
           then
             trait := -trait
           else
             test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
       end
       else test := false;
     until (k >= longueur) or not(test);
    end;
    ChainePartieLecture := ligne;
    AffichePositionLecture(PlatLecture,whichWindow);
    AfficheHistoriqueLecture(PlatLecture,whichWindow);
    positionLectureModifiee := true;
    VerifiePositionLectureModifiee(positionLectureModifiee);
end;



procedure DejoueUnCoupPlateauLecture(whichWindow : WindowRef);
var i,j,k,x,y,longueur,trait : SInt16;
    test : boolean;
    nBla,nnoi : SInt32;
    unRect : rect;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
  if longueur > 1 then
    begin
     trait := pionNoir;
     test := true;
     k := 0;
     repeat
       k := k+1;
       x := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, k, 'DejoueUnCoupPlateauLecture(1)');
       if platlecture[x] = pionVide then
       begin
         test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
         if test
           then
             trait := -trait
           else
             test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
       end
       else test := false;
     until (k >= longueur-1) or not(test);
    end;
  AffichePositionLecture(PlatLecture,whichWindow);
  if longueur >= 1 then
    begin
      x := OthellierLectureRect.left+9*taillecaselecture;
      y := OthellierLectureRect.top;
      i := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, longueur, 'DejoueUnCoupPlateauLecture(1)') mod 10;
      j := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, longueur, 'DejoueUnCoupPlateauLecture(1)') div 10;
      SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                           x+i*taillecaselecture,y+j*taillecaselecture);
      EffaceCasePetitOthellier(unRect);
    end;
  if (longueur > 1)
    then DESTROY_LAST_MOVE_OF_PACKED_GAME(ChainePartieLecture)
    else FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  positionLectureModifiee := true;
  VerifiePositionLectureModifiee(positionLectureModifiee);
  itemmenuouverture := 1;
  DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
end;

procedure DejoueNCoupsPlateauLecture(coup : SInt16; whichWindow : WindowRef);
var i,j,k,t,x,y,longueur,trait : SInt16;
    test : boolean;
    nBla,nnoi : SInt32;
    unRect : rect;
begin
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  if (coup-1 < longueur) and (coup >= 1) then
    begin
      longueur := coup;
      OthellierEtPionsDeDepart(platlecture,nBla,nNoi);
      if longueur > 1 then
        begin
         trait := pionNoir;
         test := true;
         k := 0;
         repeat
           k := k+1;
           x := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, k, 'DejoueNCoupsPlateauLecture(1)');
           if platlecture[x] = pionVide then
           begin
             test := ModifPlatFin(x,trait,platlecture,nBla,nNoi);
             if test
               then
                 trait := -trait
               else
                 test := ModifPlatFin(x,-trait,platlecture,nBla,nNoi);
           end
           else test := false;
         until (k >= longueur-1) or not(test);
        end;
      AffichePositionLecture(PlatLecture,whichWindow);
      if longueur >= 1 then
        for t := longueur to GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) do
        begin
          x := OthellierLectureRect.left+9*taillecaselecture;
          y := OthellierLectureRect.top;
          i := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'DejoueNCoupsPlateauLecture(2)') mod 10;
          j := GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'DejoueNCoupsPlateauLecture(3)') div 10;
          SetRect(unRect,x+1+(i-1)*taillecaselecture,y+1+(j-1)*taillecaselecture,
                               x+i*taillecaselecture,y+j*taillecaselecture);
          EffaceCasePetitOthellier(unRect);
        end;
      if (longueur > 1)
        then DESTROY_LAST_MOVE_OF_PACKED_GAME(ChainePartieLecture)
        else FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
      positionLectureModifiee := true;
      VerifiePositionLectureModifiee(positionLectureModifiee);
   end;
  itemmenuouverture := 1;
  DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
end;

function ClicDansOthellierLecture(mouseLoc : Point; whichWindow : WindowRef) : boolean;
var a,b,xcourant,xtest : SInt16;
    nbBlanc,nbNoir : SInt32;
    couleurtrait,t,jeudet : SInt16;
    trouve : boolean;
    x,y,larg : SInt16;
    unRect : rect;
    s : String255;
begin
  TextSize(9);
  TextFont(MonacoID);
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  a := (mouseLoc.h-OthellierLectureRect.left) div taillecaselecture +1;
  b := (mouseLoc.v-OthellierLectureRect.top) div taillecaselecture +1;
  xcourant := a+10*b;
  nbBlanc := 0; nbnoir := 0;
  for t := 1 to 64 do
    begin
      jeudet := PlatLecture[othellier[t]];
      if jeudet = pionBlanc then nbBlanc := nbBlanc+1;
      if jeudet = pionNoir then nbnoir := nbNoir+1;
    end;
  if odd(nbBlanc+nbnoir)
    then couleurtrait := pionBlanc
    else couleurtrait := pionNoir;
  if platlecture[xcourant] = pionVide then
    if PeutJouerIci(couleurtrait,xcourant,PlatLecture)
     then
      begin
        ClicDansOthellierLecture := ModifPlatFin(xcourant,couleurtrait,PlatLecture,nbBlanc,nbnoir);
        ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, xcourant);
        AffichePositionLecture(PlatLecture,whichWindow);
        SetRect(unRect,x+1+(a-1)*taillecaselecture,y+1+(b-1)*taillecaselecture,
               x+a*taillecaselecture,y+b*taillecaselecture);
        s := IntToStr(nbBlanc+nbNoir-4);
        larg := MyStringWidth(s);
        if (nbBlanc+nbNoir-4 >= 10) and (nbBlanc+nbNoir-4 <= 19)
          then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
          else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
        MyDrawString(s);
        positionLectureModifiee := true;
        VerifiePositionLectureModifiee(positionLectureModifiee);
        itemmenuouverture := 1;
        DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
      end
     else
      begin
        trouve := false;
        t := 0;
        repeat
          t := t+1;
          xtest := othellier[t];
          if PlatLecture[xtest] = pionVide then
            trouve := PeutJouerIci(couleurtrait,xtest,PlatLecture)
        until trouve or (t >= 64);
        if not(trouve) then
          if PeutJouerIci(-couleurtrait,xcourant,PlatLecture)
            then
              begin
                ClicDansOthellierLecture := ModifPlatFin(xcourant,-couleurtrait,PlatLecture,nbBlanc,nbnoir);
                ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, xcourant);
                AffichePositionLecture(PlatLecture,whichWindow);
                SetRect(unRect,x+1+(a-1)*taillecaselecture,y+1+(b-1)*taillecaselecture,
                               x+a*taillecaselecture,y+b*taillecaselecture);
                s := IntToStr(nbBlanc+nbNoir-4);
                larg := MyStringWidth(s);
                if (nbBlanc+nbNoir-4 >= 10) and (nbBlanc+nbNoir-4 <= 19)
                  then Moveto((unRect.left+unRect.right-larg) div 2,unRect.bottom-4)
                  else Moveto((unRect.left+unRect.right-larg) div 2+1,unRect.bottom-4);
                MyDrawString(s);
                positionLectureModifiee := true;
                VerifiePositionLectureModifiee(positionLectureModifiee);
                itemmenuouverture := 1;
                DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
              end;
      end;
    TextSize(0);
    TextFont(systemFont);
end;

procedure ClicDansHistoriqueLecture(mouseLoc : Point; whichWindow : WindowRef);
var a,b,xcourant : SInt16;
    trouve,bidbool : boolean;
    x,y,t,longueur : SInt16;
begin
  x := OthellierLectureRect.left+9*taillecaselecture;
  y := OthellierLectureRect.top;
  a := (mouseLoc.h-x) div taillecaselecture +1;
  b := (mouseLoc.v-y) div taillecaselecture +1;
  xcourant := a+10*b;
  trouve := false;
  longueur := GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture);
  if platlecture[xcourant] <> pionVide
   then
     begin
      for t := 1 to longueur do
        if (GET_NTH_MOVE_OF_PACKED_GAME(ChainePartieLecture, t, 'ClicDansHistoriqueLecture(1)') = xcourant) and not(trouve)
          then
            begin
              trouve := true;
              DejoueNCoupsPlateauLecture(t,whichWindow);
            end;
     end
   else
     begin
       mouseLoc.h := mouseLoc.h-9*taillecaselecture;
       bidbool := ClicDansOthellierLecture(mouseLoc,whichWindow);
     end;
end;


function FiltreRechercheDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var ch : char;
    s1,s2 : String255;
begin
  FiltreRechercheDialog := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
        keyDown,autoKey :
          begin
            if (BAND(evt.message,charcodemask) = EntreeKey) then {entrОe}
              begin
                item := 4;
                FlashItem(dlog,item);
                FiltreRechercheDialog := true;
                exit;
              end;
            if (BAND(evt.modifiers,cmdKey) <> 0) then
              begin
                ch := chr(BAND(evt.message,charCodemask));
                if (ch = 'Є') or (ch = '┘') then  {pomme-option-y}
                  begin
                    GetItemTextInDialog(dlog,JoueurNoirText,s1);
                    GetItemTextInDialog(dlog,JoueurBlancText,s2);
                    SetItemTextInDialog(dlog,JoueurNoirText,s2);
                    SetItemTextInDialog(dlog,JoueurBlancText,s1);
                    SelectDialogItemText(dlog,JoueurNoirText,0,MAXINT_16BITS);
                    FiltreRechercheDialog := true;
                    exit;
                  end;
                FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
              end;
            FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
          end;    {keyDown,autoKey}
        updateEvt:
          begin
            item := VirtualUpdateItemInDialog;
            FiltreRechercheDialog := true;
          end;
            otherwise FiltreRechercheDialog := MyFiltreClassique(dlog,evt,item);
        end;   {case}
end;




function FiltreLectureDialog(dlog : DialogPtr; var evt : eventRecord; var item : SInt16) : boolean;
var mouseLoc : Point;
    unRect : rect;
    a,b : SInt32;
    s1,s2 : String255;
    ch : char;
    oldPort : grafPtr;
    temp : boolean;
begin
  FiltreLectureDialog := false;
  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(evt);
  if not(EvenementDuDialogue(dlog,evt))
    then FiltreLectureDialog := MyFiltreClassique(dlog,evt,item)
    else
      case evt.what of
       mouseDown:
          begin
            IncrementeCompteurDeMouseEvents;
            GetPort(oldPort);
            SetPortByDialog(dlog);
            mouseLoc := evt.where;
            GlobalToLocal(mouseLoc);
            if PtInRect(mouseLoc,OthellierLectureRect)
             then
               begin
                 FiltreLectureDialog := ClicDansOthellierLecture(mouseLoc,GetDialogWindow(dlog));
                 item := 0;
               end
             else
               begin
                 a := OthellierLectureRect.left+9*taillecaselecture;
                 b := OthellierLectureRect.top;
                 SetRect(unRect,a,b,a+8*taillecaselecture,b+8*taillecaselecture);
                 if PtInRect(mouseLoc,unRect)
                   then
                     begin
                       ClicDansHistoriqueLecture(mouseLoc,GetDialogWindow(dlog));
                       FiltreLectureDialog := true;
                       item := 0;
                     end
                   else
                     FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
               end;
             SetPort(oldPort);
           end;
        keyDown , autoKey :
         if (BAND(evt.modifiers,cmdKey) <> 0)
           then
             begin
               ch := chr(BAND(evt.message,charCodemask));
               if (ch = 'z') or (ch = 'Z') then     { pomme-z }
                 begin
                   item := CoupPrecedentBouton;
                   FiltreLectureDialog := true;
                   exit;
                 end;
               if (ch = 'и') or (ch = '█') or (ch = 'n') or (ch = 'N') then  { pomme-n }
                 begin
                   DejoueNCoupsPlateauLecture(1,GetDialogWindow(dlog));
                   item := 0;
                   FiltreLectureDialog := true;
                   exit;
                 end;
               if (ch = 'Є') or (ch = '┘') then  { pomme-option-y echange les noirs et les blancs }
                 begin
                   GetItemTextInDialog(dlog,JoueurNoirText,s1);
                   GetItemTextInDialog(dlog,JoueurBlancText,s2);
                   SetItemTextInDialog(dlog,JoueurNoirText,s2);
                   SetItemTextInDialog(dlog,JoueurBlancText,s1);
                   SelectDialogItemText(dlog,JoueurNoirText,0,MAXINT_16BITS);

                   temp := mustBeAPerfectMatch[JoueurNoirText];
                   mustBeAPerfectMatch[JoueurNoirText]  := mustBeAPerfectMatch[JoueurBlancText];
                   mustBeAPerfectMatch[JoueurBlancText] := temp;

                   FiltreLectureDialog := true;
                   exit;
                 end;
               FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
             end
         else
           begin

             FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
             ch := chr(BAND(evt.message,charCodemask));


             if (item = JoueurNoirText)  and (ch <> tab) then mustBeAPerfectMatch[JoueurNoirText]  := false;
             if (item = JoueurBlancText) and (ch <> tab) then mustBeAPerfectMatch[JoueurBlancText] := false;
             if (item = TournoiText)     and (ch <> tab) then mustBeAPerfectMatch[TournoiText]     := false;

             (*
             WritelnDansRapport('dans FiltreLectureDialog (1) : ');
             WritelnNumDansRapport('item = ', item);
             WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurNoirText] = ',mustBeAPerfectMatch[JoueurNoirText]);
             WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurBlancText] = ',mustBeAPerfectMatch[JoueurBlancText]);
             WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[TournoiText] = ',mustBeAPerfectMatch[TournoiText]);
             *)

           end;
      updateEvt :
        begin
          item := VirtualUpdateItemInDialog;
          FiltreLectureDialog := true;
        end;
      otherwise
        begin
          FiltreLectureDialog := MyFiltreClassique(dlog,evt,item);
        end;
    end;   {case}
end;


function AnneeIsCompatible(anneeDeLaPartie,anneeDeRecherche,testInegalite : SInt16) : boolean;
begin
  AnneeIsCompatible := true;
  if (anneeDeRecherche >= 1970) and (anneeDeRecherche <= kFinDuMondeOthellistique) then
	  case testInegalite of
	    testEgalite  :        AnneeIsCompatible := (anneeDeLaPartie = anneeDeRecherche);
	    testSuperieur:        AnneeIsCompatible := (anneeDeLaPartie >= anneeDeRecherche);
	    testInferieur:        AnneeIsCompatible := (anneeDeLaPartie <= anneeDeRecherche);
	    testSuperieurStrict : AnneeIsCompatible := (anneeDeLaPartie > anneeDeRecherche);
	    testInferieurStrict : AnneeIsCompatible := (anneeDeLaPartie < anneeDeRecherche);
	  end;
end;





procedure InstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec; whichMenuID : SInt16; filtre : filtreDistributionProc);
var nroDistrib,k,compteur : SInt16;
    s : String255;
begin
  with popUpBases do
    begin
      MenuFlottantBases := MyGetMenu(whichMenuID);
      theMenuID := whichMenuID;
		  EnleveEspacesDeDroiteItemsMenu(popUpBases.MenuFlottantBases);
		  InsertMenu(MenuFlottantBases,-1);

		  nbreItemsAvantListeDesBases := MyCountMenuItems(MenuFlottantBases);

		  {
		  WritelnDansRapport('');
		  WritelnNumDansRapport('nb distributions du nouveau format = ',DistributionsNouveauFormat.nbDistributions);
		  for k := 1 to DistributionsNouveauFormat.nbDistributions do
		    begin
		      WritelnDansRapport('path = '+DistributionsNouveauFormat.Distribution[k].path^);
		      WritelnDansRapport('nom = '+DistributionsNouveauFormat.Distribution[k].name^);
		      WritelnDansRapport('nomUsuel = '+DistributionsNouveauFormat.Distribution[k].nomUsuel^);
		      WritelnDansRapport('type = '+IntToStr(GetTypeDonneesDistribution(k)));
		      WritelnDansRapport('    =>    '+IntToStr(NbTotalPartiesDansDistributionSet([k]))+' parties');

		    end;
		  WritelnDansRapport('');
		  }

		  for k := 0 to nbMaxDistributions do
		    tableLiaisonEntreMenuBasesEtNumerosDistrib[k] := -1;


		  compteur := nbreItemsAvantListeDesBases;
		  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		    if filtre(nroDistrib) then
			    begin
			      s := DistributionsNouveauFormat.Distribution[nroDistrib].nomUsuel^;
			      {s := s + ' ('+IntToStr(NbTotalPartiesDansDistributionSet([nroDistrib]))+')';}
			      s := Concat(' ',s);
			      s := EnleveEspacesDeDroite(s);
			      MyInsertMenuItem(MenuFlottantBases,s,1000);

			      inc(compteur);
			      tableLiaisonEntreMenuBasesEtNumerosDistrib[compteur] := nroDistrib;
			    end;
		  for k := 1 to MyCountMenuItems(MenuFlottantBases) do
		    MyEnableItem(MenuFlottantBases,k);
		end;
end;

procedure DesinstalleMenuFlottantBases(var popUpBases : menuFlottantBasesRec);
var k : SInt32;
begin
  with popUpBases do
    begin
      DeleteMenu(theMenuID);
      TerminateMenu(popUpBases.MenuFlottantBases,true);
      for k := 0 to nbMaxDistributions do
        tableLiaisonEntreMenuBasesEtNumerosDistrib[k] := -1;
    end;
end;


function NroDistribToItemNumber(popUpBases : menuFlottantBasesRec; nroDistribCherchee : SInt32) : SInt32;
var k : SInt32;
begin
  with popUpBases do
    begin
      if (nroDistribCherchee >= 1) and (nroDistribCherchee <= DistributionsNouveauFormat.nbDistributions) then
	       for k := 0 to nbMaxDistributions do
	          if (tableLiaisonEntreMenuBasesEtNumerosDistrib[k] = nroDistribCherchee) then
	            begin
	              NroDistribToItemNumber := k;
	              exit;
	            end;
	  end;
	NroDistribToItemNumber := 0;
end;

function ItemNumberToNroDistrib(popUpBases : menuFlottantBasesRec; itemNumberCherche : SInt32) : SInt32;
begin
  with popUpBases do
    if (itemNumberCherche > nbreItemsAvantListeDesBases) and (itemNumberCherche <= MyCountMenuItems(MenuFlottantBases)) and
       (itemNumberCherche >= 0) and (itemNumberCherche <= nbMaxDistributions)
      then ItemNumberToNroDistrib := tableLiaisonEntreMenuBasesEtNumerosDistrib[itemNumberCherche]
      else ItemNumberToNroDistrib := 0;
end;


function ActionBaseDeDonnee(actionDemandee : SInt16; var partieEnChaine : String255) : boolean;
const
    OuvrirThorID = 136;
    LectureBaseID = 140;
    menuFlottantBasesID = 3004;

    ToutesLesBasesCmd = 1;
    CertainesBasesCmd = 2;
    AucuneBaseCmd = 3;

    partieImpossible = -537;

var dp : DialogPtr;
    itemHit : SInt16;
    codeErreur : OSErr;

var s,s1 : String255;
    aux : SInt32;
    ScoreNoirRecherche,anneeRecherche : SInt32;
    numeroPartieMin,numeroPartieMax : SInt32;
    JoueurNoirRecherche,JoueurBlancRecherche,TournoiRecherche : String255;
    TournoiCompatible : t_TournoiCompatible;
    JoueurNoirCompatible,JoueurBlancCompatible : t_JoueurCompatible;
    ScoreCompatible : t_ScoreCompatible;
    OuvertureCompatible:{packed} array[0..255] of boolean;
    NoirsCompatibleParIndex:{packed} array[0..255] of boolean;
    BlancsCompatibleParIndex:{packed} array[0..255] of boolean;
    TournoisCompatibleParIndex:{packed} array[0..255] of boolean;
    passeLeFiltreDesIndex : boolean;
    partieBuff : t_PartieRecNouveauFormat;
    tousParametresvides : boolean;
    auMoinsUnePartieDansBuffer : boolean;
    DejaAuMoinsUneRecherche : boolean;
    DernierFichierAffiche : SInt16;
    dernierePartieAffichee : SInt32;
    NbPartiesPotentiellementLues : SInt32;
    ChaineNoir,ChaineBlanc,ChaineScoreNoir : String255;
    ChaineTournoi,ChaineAnnee,ChaineNroPart : String255;
    ChaineGenreTest : String255;
    itemPourLeTest : SInt16;
    interversionlecturebase : boolean;
    annulationPendantLecture : boolean;
    result : boolean;
    myEvent : eventRecord;
    nomNoir,nomBlanc,nomTournoi : String255;
    popUpBases : menuFlottantBasesRec;



procedure CalculeNbTotalPartiesDansDistributionsALire;
begin
  with ChoixDistributions do
    NbTotalPartiesDansDistributionsALire := NbTotalPartiesDansDistributionSet(distributionsALire);
end;

procedure CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee : SInt16);
var somme : SInt32;
    numFichier : SInt16;
    anneeFichier : SInt16;
begin
  somme := 0;
  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    if (InfosFichiersNouveauFormat.fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) and
       (InfosFichiersNouveauFormat.fichiers[numFichier].nroDistribution in ChoixDistributions.distributionsALire) then
       begin
         anneeFichier := AnneePartiesFichierNouveauFormat(numFichier);
         if (AnneeIsCompatible(anneeFichier,anneeRecherche,genreDeTestPourAnnee)) then
           somme := somme+NbPartiesFichierNouveauFormat(numFichier);
       end;
  NbPartiesPotentiellementLues := somme;
end;

procedure EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee : SInt16; whichWindow : WindowRef);
var s : String255;
    anneeRechercheArrivee : SInt16;
    oldPort : grafPtr;
begin
  if not(DoitDessinerMessagesChargementBase) then
    exit;

  GetPort(oldPort);
  SetPortByWindow(whichWindow);
  anneeRechercheArrivee := anneeRecherche;
  CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
  if {(NbPartiesPotentiellementLues = ChoixDistributions.NbTotalPartiesDansDistributionsALire) or}
     (anneeRechercheArrivee < 0) or (anneeRecherche > kFinDuMondeOthellistique) or (anneeRecherche < kDebutDuMondeOthellistique) or
     ((NbPartiesPotentiellementLues = 0) and ((anneeRechercheArrivee = 19) or (anneeRechercheArrivee < 10)))
    then
      begin
         EcritMessageLectureBase('                            ',25,kYpositionNbPartiesPotentiellementLues);
      end
    else
      begin
			  s := IntToStr(NbPartiesPotentiellementLues);

			  case genreDeTestPourAnnee of
			    testEgalite  :        EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,13),s,IntToStr(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testSuperieur:        EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,14),s,IntToStr(anneeRecherche-1),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testInferieur:        EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,15),s,IntToStr(anneeRecherche+1),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testSuperieurStrict : EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,14),s,IntToStr(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				  testInferieurStrict : EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,15),s,IntToStr(anneeRecherche),'',''),25,kYpositionNbPartiesPotentiellementLues);
				end;
		  end;
  SetPort(oldPort);
end;

procedure EcritNbPartiesBase(whichWindow : WindowRef);
var s : String255;
    oldPort : grafPtr;
begin
  if not(DoitDessinerMessagesChargementBase) then
    exit;

  GetPort(oldPort);
  SetPortByWindow(whichWindow);
  CalculeNbTotalPartiesDansDistributionsALire;
  s := IntToStr(ChoixDistributions.NbTotalPartiesDansDistributionsALire);
  EcritMessageLectureBase(ReplaceParameters(ReadStringFromRessource(TextesBaseID,1),s,'','',''),20,kYpositionNbPartiesDansBase);
  SetPort(oldPort);
end;

procedure RedessineDialogue(dp : DialogPtr);
begin
  SetPortByDialog(dp);
  MyDrawDialog(dp);
  OutlineOK(dp);
  DessineOthellierLecture(GetDialogWindow(dp));
  DessineOthellierLectureHistorique(GetDialogWindow(dp));
  AffichePositionLecture(PlatLecture,GetDialogWindow(dp));
  AfficheHistoriqueLecture(PlatLecture,GetDialogWindow(dp));
  EcritNbPartiesBase(GetDialogWindow(dp));
  EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,GetDialogWindow(dp));
end;

procedure InstalleMenuFlottantOuverture;
begin
  EnleveEspacesDeDroiteItemsMenu(OuvertureMenu);
  InsertMenu(OuvertureMenu,-1);
end;


procedure DesinstalleMenuFlottantOuverture;
begin
  DeleteMenu(OuvertureID);
end;



function MenuItemToOuverture(item : SInt16; var ligneOuverture : PackedThorGame) : boolean;
var s : String255;
    octetdebut,octetfin,j : SInt32;
    whichSquare,indexTableOuv : SInt16;
begin
  MenuItemToOuverture := false;
  FILL_PACKED_GAME_WITH_ZEROS(ligneOuverture);
  if (item > 2) and (bibliothequeIndex <> NIL) and (bibliothequeEnTas <> NIL) then
    begin
      MyGetMenuItemText(OuvertureMenu,item,s);
      s := EnleveEspacesDeDroite(s);
      if EstDansTableOuverture(s,indexTableOuv) then
        begin
          MenuItemToOuverture := true;
          ADD_MOVE_TO_PACKED_GAME(ligneOuverture, 56);  { coup 1 en F5 }
          OctetDebut := bibliothequeIndex^^[indexTableOuv-1]+1;
          OctetFin := bibliothequeIndex^^[indexTableOuv];
          for j := OctetDebut to OctetFin do
            begin
              whichSquare := bibliothequeEnTas^^[j];
              if (whichSquare >= 11) and (whichSquare <= 88) then
                ADD_MOVE_TO_PACKED_GAME(ligneOuverture, whichSquare);
            end;
        end;
    end;
end;



procedure CheckItemMarksOnMenuBases(var item : SInt16);
var nroDistrib : SInt16;
    compteur : SInt32;
begin
  with popUpBases do
    begin
		  if ChoixDistributions.genre = kToutesLesDistributions then
		    begin
		      ChoixDistributions.distributionsALire := [];
		      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		        if EstUneDistributionDeParties(nroDistrib) then
		          ChoixDistributions.distributionsALire := ChoixDistributions.distributionsALire+[nroDistrib];
		    end;
		  if ChoixDistributions.genre = kAucuneDistribution
		    then SetItemMark(MenuFlottantBases,AucuneBaseCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,AucuneBaseCmd,chr(noMark));
		  if ChoixDistributions.genre = kToutesLesDistributions
		    then SetItemMark(MenuFlottantBases,ToutesLesBasesCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,ToutesLesBasesCmd,chr(noMark));
		  if ChoixDistributions.genre = kQuelquesDistributions
		    then SetItemMark(MenuFlottantBases,CertainesBasesCmd,chr(checkMark))
		    else SetItemMark(MenuFlottantBases,CertainesBasesCmd,chr(noMark));

		  compteur := 0;
		  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		    if EstUneDistributionDeParties(nroDistrib) then
			    if nroDistrib in ChoixDistributions.distributionsALire
			      then
			        begin
			          inc(compteur);
			          SetItemMark(MenuFlottantBases,NroDistribToItemNumber(popUpBases,nroDistrib),chr(diamondMark))
			        end
			      else
			        SetItemMark(MenuFlottantBases,NroDistribToItemNumber(popUpBases,nroDistrib),chr(noMark));

			if (compteur = 1) then
			  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
		      if EstUneDistributionDeParties(nroDistrib) then
			      if nroDistrib in ChoixDistributions.distributionsALire then
			        item := NroDistribToItemNumber(popUpBases,nroDistrib);
	end;
end;


function MenuItemToBases(var item : SInt16) : boolean;
var nroDistrib : SInt16;
    nbDistributionsDansEnsemble : SInt16;
    distributionsAccessiblesSet : DistributionSet;
begin
  MenuItemToBases := true;

  distributionsAccessiblesSet := [];
  for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
    if EstUneDistributionDeParties(nroDistrib) then
      distributionsAccessiblesSet := distributionsAccessiblesSet+[nroDistrib];

  if item = ToutesLesBasesCmd then
    begin
      ChoixDistributions.genre := kToutesLesDistributions;
      ChoixDistributions.distributionsALire := distributionsAccessiblesSet;
     end;
  if item = AucuneBaseCmd then
    begin
      ChoixDistributions.genre := kAucuneDistribution;
      ChoixDistributions.distributionsALire := [];
    end;
  if item = CertainesBasesCmd then
    begin
      ChoixDistributions.genre := kQuelquesDistributions;
    end;
  if item > popUpBases.nbreItemsAvantListeDesBases then
    begin
      ChoixDistributions.genre := kQuelquesDistributions;

      nbDistributionsDansEnsemble := 0;
      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
        begin
          if EstUneDistributionDeParties(nroDistrib) then
            if nroDistrib in ChoixDistributions.distributionsALire then inc(nbDistributionsDansEnsemble);
        end;

      nroDistrib := ItemNumberToNroDistrib(popUpBases,item);
      if (nroDistrib in ChoixDistributions.distributionsALire) and (nbDistributionsDansEnsemble >= 2)
        then ChoixDistributions.distributionsALire := (ChoixDistributions.distributionsALire - [nroDistrib])
        else ChoixDistributions.distributionsALire := (ChoixDistributions.distributionsALire + [nroDistrib]);

      nbDistributionsDansEnsemble := 0;
      for nroDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
        begin
          if EstUneDistributionDeParties(nroDistrib) then
            if nroDistrib in ChoixDistributions.distributionsALire then inc(nbDistributionsDansEnsemble);
        end;

      if (nbDistributionsDansEnsemble > 1)
        then item := CertainesBasesCmd;
      if nbDistributionsDansEnsemble = 0 then
        begin
          ChoixDistributions.genre := kAucuneDistribution;
          item := AucuneBaseCmd;
        end;
      if (ChoixDistributions.distributionsALire = distributionsAccessiblesSet) and
         (nbDistributionsDansEnsemble > 1) then
        begin
          ChoixDistributions.genre := kToutesLesDistributions;
          item := ToutesLesBasesCmd;
        end;
    end;
  CheckItemMarksOnMenuBases(item);
  CalculeNbTotalPartiesDansDistributionsALire;
end;

procedure GetMenuOuvertureItemAndRect;
begin
  GetDialogItemRect(dp,OuvertureUserItemPopUp,menuouverturerect);
  itemMenuOuverture := 1;
end;

procedure GetMenuBasesItemAndRect;
begin
  with popUpBases do
    begin
		  GetDialogItemRect(dp,BasesUserItemPopUp,menuBasesRect);
		  itemCourantMenuBases := ToutesLesBasesCmd;
		  if ChoixDistributions.genre = kAucuneDistribution then itemCourantMenuBases := AucuneBaseCmd else
		  if ChoixDistributions.genre = kQuelquesDistributions then itemCourantMenuBases := CertainesBasesCmd;
		end;
end;

procedure LitPartieNro(numFichierDeParties : SInt16; numeroPartie : SInt32; enAvancant : boolean);
var codeErreur : OSErr;
begin
  codeErreur := LitPartieNouveauFormat(numFichierDeParties,numeroPartie,enAvancant,partieBuff);
  with partieBuff,DistributionsNouveauFormat.distribution[InfosFichiersNouveauFormat.fichiers[numFichierDeParties].nroDistribution] do
    begin
      nroTournoi := nroTournoi+decalageNrosTournois;
		  nroJoueurNoir := nroJoueurNoir+decalageNrosJoueurs;
		  nroJoueurBlanc := nroJoueurBlanc+decalageNrosJoueurs;
    end;
end;



procedure ChercheNumerosJoueursCompatibles(nomNoir,nomBlanc : String255);
var traiteNoir,traiteBlanc : boolean;
begin

  (* nomNoir : changer les guillemets pour utiliser la syntaxe de grep
               pour le debut et la fin de mot *)

  if (nomNoir[1] = '"')
    then nomNoir[1] := '^';

  if (nomNoir[LENGTH_OF_STRING(nomNoir)] = '"')
    then nomNoir[LENGTH_OF_STRING(nomNoir)] := '$';

  if (nomNoir = '^') or (nomNoir = '$') or (nomNoir = '^$')
    then nomNoir := '';

  (* nomBlanc : changer les guillemets pour utiliser la syntaxe de grep
                pour le debut et la fin de mot *)

  if (nomBlanc[1] = '"')
    then nomBlanc[1] := '^';

  if (nomBlanc[LENGTH_OF_STRING(nomBlanc)] = '"')
    then nomBlanc[LENGTH_OF_STRING(nomBlanc)] := '$';

  if (nomBlanc = '^') or (nomBlanc = '$') or (nomBlanc = '^$')
    then nomBlanc := '';

  (* lancer le calcul des joueurs compatibles *)

  traiteNoir  := (nomNoir <> '');
  traiteBlanc := (nomBlanc <> '');

  if traiteNoir or traiteBlanc then
    begin
      if traiteNoir then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,false);
      if traiteBlanc then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,false);
      if traiteNoir then CalculeTableJoueursCompatibles(nomNoir,JoueurNoirCompatible,0);
      if traiteBlanc then CalculeTableJoueursCompatibles(nomBlanc,JoueurBlancCompatible,0);
    end;
end;


procedure ChercheOuverturesCompatibles(var ouvertureEnCours : PackedThorGame);
var longueur,i,t : SInt16;
    UnPacked7 : packed7;
    minimum,maximum : SInt32;
    uneStr33 : String255;
begin
  for i := 1 to 255 do
    OuvertureCompatible[i] := false;
  OuvertureCompatible[0] := true;

  longueur := GET_LENGTH_OF_PACKED_GAME(ouvertureEnCours);
  if longueur > nbOctetsOuvertures then longueur := nbOctetsOuvertures;
  for t := 1 to longueur do
    UnPacked7[t] := GET_NTH_MOVE_OF_PACKED_GAME(ouvertureEnCours,t, 'ChercheOuverturesCompatibles(1)');
  DetermineIntervalleOuverture(UnPacked7,longueur,minimum,maximum);
  for t := minimum to maximum do
    OuvertureCompatible[t] := true;

  if (NbinterversionsCompatibles > 0) then
    for i := 1 to NbinterversionsCompatibles do
      begin
        uneStr33 := interversionFautive^^[interversionsCompatibles[i]];
        longueur := LENGTH_OF_STRING(uneStr33);
        if longueur > nbOctetsOuvertures then longueur := nbOctetsOuvertures;
        for t := 1 to longueur do UnPacked7[t] := ord(uneStr33[t]);
        DetermineIntervalleOuverture(UnPacked7,longueur,minimum,maximum);
        for t := minimum to maximum do
          OuvertureCompatible[t] := true;
      end;
end;




procedure ChargeIndexFichierCourant(numFichierCourant : SInt16);
var nroFichierIndex : SInt16;
    err : OSErr;
begin
  with InfosFichiersNouveauFormat do
    if fichiers[numFichierCourant].typeDonnees = kFicPartiesNouveauFormat then
      begin
        nroFichierIndex := fichiers[numFichierCourant].NroFichierDual;
        if nroFichierIndex <> 0
          then  {le fichier d'index existe deja sur le disque : on le lit}
            begin
              err := LitFichierIndexNouveauFormat(nroFichierIndex);
            end
          else  {le fichier d'index est introuvable : on le fabrique}
            begin
              err := IndexerFichierPartiesEnMemoireNouveauFormat(numFichierCourant);
              err := EcritFichierIndexNouveauFormat(numFichierCourant);
            end;
      end;
end;

procedure ChercheJoueursCompatiblesPourIndex(numFichierCourant : SInt16);
var i : SInt32;
begin
  if (indexNouveauFormat.tailleIndex = NbPartiesFichierNouveauFormat(numFichierCourant))
    then
      begin
        for i := 0 to 255 do
          NoirsCompatibleParIndex[i] := false;
        for i := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
          if JoueurNoirCompatible^[i] then
            NoirsCompatibleParIndex[BAND(i,255)] := true;
      end
    else
      for i := 0 to 255 do
        NoirsCompatibleParIndex[i] := true;

  if (indexNouveauFormat.tailleIndex = NbPartiesFichierNouveauFormat(numFichierCourant))
    then
      begin
        for i := 0 to 255 do
          BlancsCompatibleParIndex[i] := false;
        for i := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
          if JoueurBlancCompatible^[i] then
            BlancsCompatibleParIndex[BAND(i,255)] := true;
      end
    else
      for i := 0 to 255 do
        BlancsCompatibleParIndex[i] := true;

end;

procedure ChercheTournoisCompatiblesPourIndex(numFichierCourant : SInt16);
var i : SInt32;
begin
  if (indexNouveauFormat.tailleIndex = NbPartiesFichierNouveauFormat(numFichierCourant))
    then
      begin
        for i := 0 to 255 do
          TournoisCompatibleParIndex[i] := false;

        for i := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat-1 do
          if TournoiCompatible^[i] then
              TournoisCompatibleParIndex[BAND(i,255)] := true;

      end
    else
       for i := 0 to 255 do
          TournoisCompatibleParIndex[i] := true;
end;

procedure ChercheOuverturesCompatiblesPourIndex(numFichierCourant : SInt16; ouverture : PackedThorGame);
var i : SInt32;
begin
  OuvertureCompatible[0] := true;
  if (indexNouveauFormat.tailleIndex = NbPartiesFichierNouveauFormat(numFichierCourant))
    then ChercheOuverturesCompatibles(ouverture)
    else
      for i := 0 to 255 do
        OuvertureCompatible[i] := true;
end;



procedure ChercheNumerosTournoisCompatibles(nom : String255);
var i : SInt32;
    c : char;
    nomTournoi : String255;
begin
  if LENGTH_OF_STRING(nom) > 0 then
    begin
      RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,false);
      if JoueursEtTournoisEnMemoire
        then
          nomTournoi := nom
        else
          begin
            nomTournoi := '';
            for i := 1 to LENGTH_OF_STRING(nom) do
              begin
                c := nom[i];
                if c = 'О' then c := 'В';
                if c = 'П' then c := 'К';
                if (c >= 'A') and (c <= 'Z') then c := chr(ord(c)+32);
                nomTournoi := nomTournoi + c;
              end;
          end;
      CalculeTableTournoisCompatibles(nomTournoi,TournoiCompatible,0);
   end;
end;





 {  teste si la partie du buffer est la meme que ouverture   }
function MemesCoupsPartie(ouverture : PackedThorGame) : boolean;
var i,longueur : SInt16;
    test : boolean;
begin
  test := true;
  longueur := GET_LENGTH_OF_PACKED_GAME(ouverture);
  i := longueur+1;
  with Partiebuff do
  repeat
    i := i-1;
    test := GET_NTH_MOVE_OF_PACKED_GAME(ouverture,i, 'MemesCoupsPartie(1)') = listeCoups[i];
  until not(test) or (i <= 1);
  MemesCoupsPartie := test;
end;


procedure AffichePartie(numeroFichier,anneePartie : SInt16; numeroPartie : SInt32);
var nomjoueur : String255;
    nomtournoi : String255;
    chaine : String255;
    unRect : rect;
    i : SInt16;
begin
   chaine := '';
   nomJoueur := GetNomJoueur(Partiebuff.nroJoueurNoir);
   nomJoueur := DeleteSpacesBefore(nomJoueur,LENGTH_OF_STRING(nomJoueur));
   {while nomjoueur[LENGTH_OF_STRING(nomjoueur)] = ' ' do
     Delete(nomjoueur,LENGTH_OF_STRING(nomjoueur),1);}

   chaine := chaine + nomjoueur;
   s := IntToStr(Partiebuff.scoreReel);
   chaine := chaine + CharToString(' ')+s+'  ';
   nomJoueur := GetNomJoueur(Partiebuff.nroJoueurBlanc);
   nomJoueur := DeleteSpacesBefore(nomJoueur,LENGTH_OF_STRING(nomJoueur));
   {while nomjoueur[LENGTH_OF_STRING(nomjoueur)] = ' ' do
     Delete(nomjoueur,LENGTH_OF_STRING(nomjoueur),1);}

   chaine := chaine + nomjoueur;
   s := IntToStr(64-Partiebuff.scoreReel);
   chaine := chaine + CharToString(' ')+s+'   ';

   nomTournoi := GetNomTournoi(Partiebuff.nroTournoi);
   TraduitNomTournoiEnMac(nomtournoi,nomtournoi);
   for i := 1 to LENGTH_OF_STRING(nomtournoi) do
     chaine := chaine + nomtournoi[i];
   chaine := chaine + ' '+IntToStr(anneePartie);
   SetPortByDialog(dp);
   TextSize(gCassioSmallFontSize);
   TextFont(gCassioApplicationFont);
   SetRect(unRect,0,148,500,172);
   MyEraseRect(unRect);
   MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
   s := IntToStr(numeroPartie);
   chaine := chaine + '        '+ReplaceParameters(ReadStringFromRessource(TextesBaseID,2),s,'','','');  {Partie nб ^0}
   WriteStringAt(chaine,10,168);
   TextSize(0);
   TextFont(systemFont);
   DernierFichierAffiche := numeroFichier;
   dernierePartieAffichee := numeroPartie;
   dernierePartieExtraiteWThor.numFichier := numeroFichier;
   dernierePartieExtraiteWThor.numPartie := numeroPartie;
end;

procedure TraductionPartie(var s : String255);
var i,coup : SInt16;
    premierCoupPartie : SInt16;
    autreCoupQuatreDansPartie : boolean;
begin
  ExtraitPremierCoup(premierCoupPartie,autreCoupQuatreDansPartie);
  s := '';
  for i := 1 to 60 do
    begin
      coup := Partiebuff.listeCoups[i];
      if coup > 0 then
        begin
          TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
          s := Concat(s,CoupEnStringEnMajuscules(coup));
        end;
    end;
end;

procedure TraductionPremiersCoups(var s : String255; nbCoup : SInt16);
var i,coup : SInt16;
begin
  s := '';
  for i := 1 to nbCoup do
    begin
      coup := Partiebuff.listeCoups[i];
      if coup > 0 then s := Concat(s,CoupEnStringEnMajuscules(coup));
    end;
end;


procedure EcritParametresDuDialogueDansRapport(fonctionAppelante : String255);
begin
  WritelnDansRapport(fonctionAppelante);
  WritelnDansRapport('   tournoi = '+ChaineTournoi);
  WritelnDansRapport('   joueur blanc = '+ChaineBlanc);
  WritelnDansRapport('   joueur noir = '+ChaineNoir);
end;


procedure SauveToutAvantAnnuler(tientCompteDeNro : boolean);
var NewNoir,NewBlanc,NewScoreNoir : String255;
    NewTournoi,NewAnnee,NewGenreTest : String255;
begin
  ChaineNroPart := '';

  if tientCompteDeNro
    then GetItemTextInDialog(dp,NroText,ChaineNroPart);

  if (ChaineNroPart = '') or not(tientCompteDeNro) then
    begin
      GetItemTextInDialog(dp,ScoreNoirText,NewScoreNoir);
      GetItemTextInDialog(dp,AnneeText,NewAnnee);
      GetItemTextInDialog(dp,JoueurNoirText,NewNoir);
      GetItemTextInDialog(dp,JoueurBlancText,NewBlanc);
      GetItemTextInDialog(dp,TournoiText,NewTournoi);
      itemPourLeTest := GenreTestTextLectureBase;
      GetItemTextInDialog(dp,itemPourLeTest,NewGenreTest);

      ChaineTournoi := NewTournoi;
      ChaineBlanc := NewBlanc;
      ChaineNoir := NewNoir;
      ChaineAnnee := NewAnnee;
      ChaineScoreNoir := NewScoreNoir;
      ChaineGenreTest := NewGenreTest;
    end;

end;



procedure SetNumerosDePartieMinEtMaxPourCeFichier(numeroFichier : SInt16; var numeroPartieMin,numeroPartieMax : SInt32);
begin
  numeroPartieMin := 1;
  numeroPartieMax := NbPartiesFichierNouveauFormat(numeroFichier);
end;




procedure ChargePartie(nroChargement : SInt32; nroDistribution,anneePartie : SInt16);
begin

  if (nroChargement >= 1) and (nroChargement <= PartiesNouveauFormat.nbPartiesEnMemoire) then
    begin
     SetPartieActive(nroChargement,true);
     SetAnneePartieParNroRefPartie(nroChargement,anneePartie);
     SetPartieRecordParNroRefPartie(nroChargement,partieBuff);
     SetNroDistributionParNroRefPartie(nroChargement,nroDistribution);

     SetPartieEstSansOrdinateur(nroChargement,not(GetJoueurEstUnOrdinateur(partieBuff.nroJoueurNoir) or GetJoueurEstUnOrdinateur(partieBuff.nroJoueurBlanc)));

     {
     partie60 := '';
     for k := 1 to 60 do
       partie60 := partie60 + chr(partieBuff.listeCoups[k]);
     MetPartieDansTableStockageParties(nroChargement,partie60);
     SetNroJoueurNoirParNroRefPartie(nroChargement,partieBuff.nroJoueurNoir);
     SetNroJoueurBlancParNroRefPartie(nroChargement,partieBuff.nroJoueurBlanc);
     SetNroTournoiParNroRefPartie(nroChargement,partieBuff.nroTournoi);
     SetScoreReelParNroRefPartie(nroChargement,partieBuff.scoreReel);
     SetScoreTheoriqueParNroRefPartie(nroChargement,partieBuff.scoreTheorique);
     }

   end;

end;




procedure OuvrePartieNro(numeroFichier : SInt16; numeroPartieDansFichier : SInt32; enAvancant : boolean);
var titre : String255;
    sNoir,sBlanc : String255;
begin
  LitPartieNro(numeroFichier,numeroPartieDansFichier,enAvancant);
  TraductionPartie(partieEnChaine);
  sNoir := GetNomJoueurSansPrenom(Partiebuff.nroJoueurNoir);
  sBlanc := GetNomJoueurSansPrenom(Partiebuff.nroJoueurBlanc);
  ConstruitTitrePartie(sNoir,sBlanc,true,Partiebuff.scoreReel,titre);
  titrePartie^^ := titre;
  ParamDiagCourant.titreFFORUM^^ := titre;
  ParamDiagCourant.commentPositionFFORUM^^ := '';
	ParamDiagPositionFFORUM.titreFFORUM^^ := titre;
	ParamDiagPositionFFORUM.commentPositionFFORUM^^ := '';
  ParamDiagPartieFFORUM.titreFFORUM^^ := titre;
  ParamDiagPartieFFORUM.commentPositionFFORUM^^ := '';
end;

procedure MetAnciensParametres;
var s : String255;
begin
  s := ParametresOuvrirThor^^[1];
  if s <> 'Gogol' then SetItemTextInDialog(dp,TournoiText,s);
  s := ParametresOuvrirThor^^[2];
  if s <> 'Gogol' then SetItemTextInDialog(dp,JoueurBlancText,s);
  s := ParametresOuvrirThor^^[3];
  if s <> 'Gogol' then SetItemTextInDialog(dp,JoueurNoirText,s);
  s := ParametresOuvrirThor^^[4];
  if s <> 'Gogol' then SetItemTextInDialog(dp,AnneeText,s);
	anneeRecherche := StringEnAnneeSansBugAn2000(s);
  s := ParametresOuvrirThor^^[5];
  if s <> 'Gogol' then SetItemTextInDialog(dp,ScoreNoirText,s);
  ChaineTournoi := ParametresOuvrirThor^^[1];
  ChaineBlanc := ParametresOuvrirThor^^[2];
  ChaineNoir := ParametresOuvrirThor^^[3];
  ChaineAnnee := ParametresOuvrirThor^^[4];
  ChaineScoreNoir := ParametresOuvrirThor^^[5];
  case ParametreGenreTestThor of
    testEgalite  :        ChaineGenreTest := '=';
    testSuperieur:        ChaineGenreTest := '>=';
    testInferieur:        ChaineGenreTest := '<=';
    testSuperieurStrict : ChaineGenreTest := '>';
    testInferieurStrict : ChaineGenreTest := '<';
  end;
end;

procedure DeplaceAnneeDuTournoi;
var s,s1 : String255;
    i : SInt16;
    numeroDuTournoi : SInt32;
begin
  GetItemTextInDialog(dp,TournoiText,s);
  if (s <> '') then
    begin

      DoLectureJoueursEtTournoi(false);
      if TrouveNumeroDuTournoi(s, numeroDuTournoi, 0) then exit;

      i := LENGTH_OF_STRING(s);
      if i >= 5 then
        if IsDigit(s[i]) and
           IsDigit(s[i-1]) and
           IsDigit(s[i-2]) and
           IsDigit(s[i-3]) and
           (s[i-4] = ' ')  then
             begin
               s1 := TPCopy(s,i-3,4);
               s := TPCopy(s,1,i-5);
               s := EnleveEspacesDeDroite(s);
               SetItemTextInDialog(dp,TournoiText,s);
               SetItemTextInDialog(dp,AnneeText,s1);
               anneeRecherche := StringEnAnneeSansBugAn2000(s1);
               SetItemTextInDialog(dp,GenreTestTextLectureBase,'');
               genreDeTestPourAnnee := testEgalite;
               exit;
             end;
      if i >= 3 then
        if IsDigit(s[i]) and
           IsDigit(s[i-1]) and
           (s[i-2] = ' ')  then
             begin
               s1 := TPCopy(s,i-1,2);
               if StrToInt32(s1) > kChangementDeSiecleOthellistique
                 then s1 := '19'+s1
                 else s1 := '20'+s1;
               s := TPCopy(s,1,i-3);
               s := EnleveEspacesDeDroite(s);
               SetItemTextInDialog(dp,TournoiText,s);
               SetItemTextInDialog(dp,AnneeText,s1);
               anneeRecherche := StringEnAnneeSansBugAn2000(s1);
               SetItemTextInDialog(dp,GenreTestTextLectureBase,'');
               genreDeTestPourAnnee := testEgalite;
               exit;
             end;
    end;
end;

procedure MetParametresSpeciauxLecture;
var s : String255;
begin
  case genreDeTestPourAnnee of
    testEgalite  :        s := '=';
    testSuperieur:        s := '>=';
    testInferieur:        s := '<=';
    testSuperieurStrict : s := '>';
    testInferieurStrict : s := '<';
  end;
  if s <> '' then SetItemTextInDialog(dp,GenreTestTextLectureBase,s);
end;


procedure SauveAnciensParametres;
begin
  ParametresOuvrirThor^^[1] := ChaineTournoi;
  ParametresOuvrirThor^^[2] := ChaineBlanc;
  ParametresOuvrirThor^^[3] := ChaineNoir;
  ParametresOuvrirThor^^[4] := ChaineAnnee;
  ParametresOuvrirThor^^[5] := ChaineScoreNoir;
  ParametreGenreTestThor := genreDeTestPourAnnee;
end;

procedure VideNroPartieText;
begin
  SetItemTextInDialog(dp,NroText,'');
end;

procedure VideTousParametres;
begin
  SetItemTextInDialog(dp,TournoiText,'');
  SetItemTextInDialog(dp,JoueurBlancText,'');
  SetItemTextInDialog(dp,JoueurNoirText,'');
  SetItemTextInDialog(dp,AnneeText,'');
  anneeRecherche := StringEnAnneeSansBugAn2000('');
  SetItemTextInDialog(dp,ScoreNoirText,'');
  tousParametresvides := true;
end;

procedure RemetTousParametres;
begin
  s := ChaineTournoi;
  if s <> 'Gogol' then SetItemTextInDialog(dp,TournoiText,s);
  s := ChaineBlanc;
  if s <> 'Gogol' then SetItemTextInDialog(dp,JoueurBlancText,s);
  s := ChaineNoir;
  if s <> 'Gogol' then SetItemTextInDialog(dp,JoueurNoirText,s);
  s := ChaineAnnee;
  if s <> 'Gogol' then SetItemTextInDialog(dp,AnneeText,s);
  anneeRecherche := StringEnAnneeSansBugAn2000(s);
  s := ChaineScoreNoir;
  if s <> 'Gogol' then SetItemTextInDialog(dp,ScoreNoirText,s);
  tousParametresvides := false;
end;

{partie faisant un bug apres chargement de la liste :
   F5D6C3D3C4F4F6G5E3F3G6E2G3G4H5E6F2H6H4
   F5F6E6F4E3D3C3D6F7C5F3C4C6}


procedure ChargerLaBase(fenetreMessagesBase : WindowRef);
var NewNoir,NewBlanc,NewScoreNoir : String255;
    NewTournoi,NewAnnee,NewGenreTest,s : String255;

    limiteCompteur,dernierCompteurAffiche,larg : SInt32;
    CompteurPartiesExaminees : SInt32;
    compatibiliteTournoi : boolean;
    compatibiliteJoueurs,ANDentreJoueurs : boolean;
    nbChargees,intervalleLecture,pourcentage : SInt32;

    dernierPourcentagePourTestSouris : SInt32;
    pourcentageRect : rect;
    pourcentageCouleurRGB : RGBColor;
    intervallePourcentage : SInt32;
    ouvertureactive60 : PackedThorGame;
    ouvertureactive120 : String255;
    ouvertureActive255 : String255;
    partie60 : PackedThorGame;
   {TestTigre : String255; }  { utile pour l'optimisation de l'interversion F5D6C3D3C4 = F5D6C4D3C3 }
    autreCoupDiag : boolean;
    i,longueurOuverture : SInt32;
    longueurPlus1,nbreCoupsRestant : SInt16;
    tickchrono : SInt32;
    doitTraiterInterversions : boolean;
    temp : boolean;
    annulerRect,lignerect : rect;
    mouseLoc : Point;
    enAvancant,depassementLimite : boolean;
    numeroFichierCourant : SInt16;
    anneeFichierCourant : SInt16;
    nroDistributionFichierCourant : SInt16;
    compteurPartieDansFichierCourant : SInt32;
    incrementCompteurPartie : SInt32;
    codeErreur : OSErr;
    oldPort : grafPtr;
    dateDernierFlush : SInt32;
    dateDernierVerifEvents : SInt32;
label try_again;


function TesteAnnulationPendantLecture : boolean;
var myEvent : eventRecord;
    oldPort : grafPtr;
begin
  TesteAnnulationPendantLecture := false;

  if (actionDemandee = BaseLectureCriteres) and (Abs(dateDernierVerifEvents - TickCount) >= 3) then
    begin
      if HasGotEvent(mDownMask+KeyDownMask+AutoKeyMask,myEvent,0,NIL) then
        begin
          if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(myEvent);
  	      case myEvent.what of
  	        mouseDown :
  	          begin
  	            IncrementeCompteurDeMouseEvents;
  	            GetPort(oldPort);
  	            mouseLoc := myEvent.where;
  	            SetPortByDialog(dp);
  	            GlobalToLocal(mouseLoc);
  	            TesteAnnulationPendantLecture := PtInRect(mouseLoc,annulerrect);
  	            SetPort(oldPort);
  	          end;
  	        keyDown,autoKey :
  	          TesteAnnulationPendantLecture := (BAND(myEvent.message,charcodemask) = EscapeKey);
  	      end; {case}
        end;
      dateDernierVerifEvents := TickCount;
    end;


  if DoitDessinerMessagesChargementBase and
    (Abs(dateDernierFlush - TickCount) >= 2) then
    begin
      FlushWindow(fenetreMessagesBase);
      dateDernierFlush := TickCount;
    end;

end;


procedure DessineProgressBar(enAvancant : boolean);
begin
  if (compteurPartiesExaminees-dernierCompteurAffiche) >= intervallePourcentage then
    begin
      dernierCompteurAffiche := compteurPartiesExaminees;
      pourcentage := Trunc((compteurPartiesExaminees)*(100.0/intervalleLecture)+0.5);
      if pourcentage >= 99 then pourcentage := 100;

      if DoitDessinerMessagesChargementBase then
        begin
          if enAvancant
            then SetRect(pourcentageRect,larg+1,kYpositionMessageBase-6,larg+pourcentage-1,kYpositionMessageBase)
            else SetRect(pourcentageRect,larg+100+1-pourcentage,kYpositionMessageBase-6,larg+100-1,kYpositionMessageBase);

          RGBForeColor(pourcentageCouleurRGB);
          FillRect(pourcentagerect,blackPattern);
          ForeColor(blackColor);
        end;

      if Abs(pourcentage-dernierPourcentagePourTestSouris) >= 1 then
        begin
          dernierPourcentagePourTestSouris := pourcentage;
          annulationPendantLecture := TesteAnnulationPendantLecture;
        end;

      if pourcentage >= 99 then FlushWindow(fenetreMessagesBase);
    end;
end;

begin  {ChargerLaBase}
  enAvancant := not(LectureAntichronologique);

  GetPort(oldPort);
  SetPortByWindow(fenetreMessagesBase);

  AjusterPositionMessagesBase(fenetreMessagesBase,GetDialogWindow(dp),false);

  FlushEvents(everyEvent,0);
  annulationPendantLecture := false;
  GetDialogItemRect(dp,AnnulerBouton,annulerRect);

  GetItemTextInDialog(dp,ScoreNoirText,NewScoreNoir);
  GetItemTextInDialog(dp,AnneeText,NewAnnee);
  GetItemTextInDialog(dp,JoueurNoirText,NewNoir);
  GetItemTextInDialog(dp,JoueurBlancText,NewBlanc);
  GetItemTextInDialog(dp,TournoiText,NewTournoi);
  anneeRecherche := StringEnAnneeSansBugAn2000(NewAnnee);
  ANDentreJoueurs := not(NewNoir = NewBlanc);
  itemPourLeTest := GenreTestTextLectureBase;
  GetItemTextInDialog(dp,itemPourLeTest,NewGenreTest);


  ChaineTournoi := NewTournoi;
  ChaineBlanc := NewBlanc;
  ChaineNoir := NewNoir;
  ChaineAnnee := NewAnnee;
  ChaineScoreNoir := NewScoreNoir;
  ChaineGenreTest := NewGenreTest;


  FILL_PACKED_GAME_WITH_ZEROS(ouvertureactive60);
  ouvertureactive120 := '';
  avecInterversions := interversionlecturebase;
  if GET_LENGTH_OF_PACKED_GAME(ChainePartieLecture) > 0 then
    begin
      ouvertureactive60 := ChainePartieLecture;
      TraductionThorEnAlphanumerique(ouvertureactive60,ouvertureactive255);
      ouvertureActive120 := ouvertureactive255;
      Normalisation(ouvertureactive120,autreCoupDiag,false);
      TraductionAlphanumeriqueEnThor(ouvertureactive120,ouvertureactive60);
      longueurOuverture := GET_LENGTH_OF_PACKED_GAME(ouvertureactive60);
      longueurPlus1 := longueurOuverture+1;
      nbreCoupsRestant := 60-longueurOuverture;
      if interversionlecturebase then
        begin
          (* WritelnDansRapport('Appel de PrecompileInterversions dans ChargerLaBase'); *)
          if longueurOuverture <= 33
            then PrecompileInterversions(ouvertureactive60,longueurOuverture)
            else PrecompileInterversions(ouvertureactive60,33);
          (*
          if (NbinterversionsCompatibles > 0) then
            begin
              TestTigre := interversionFautive^^[interversionsCompatibles[NbinterversionsCompatibles]];
              if LENGTH_OF_STRING(TestTigre) = 5 then                                   {F5D6C3D3C4 = F5D6C4C3D3}
                if (TestTigre[2] = chr(64)) and (TestTigre[3] = chr(43)) and    {interversion de la Tigre}
                   (TestTigre[4] = chr(34)) and (TestTigre[5] = chr(33)) then   {dОjИ dans la base de thor}
                     NbinterversionsCompatibles := NbinterversionsCompatibles-1;
            end;
          *)
        end;
      doitTraiterInterversions := interversionlecturebase and (NbinterversionsCompatibles > 0);
      SET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60, 1, 197);   { sentinelle И la place de F5 }
    end
    else
      begin
        longueurOuverture := 0;
        longueurPlus1 := 1;
        nbreCoupsRestant := 60;
      end;


  RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,true);
  RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,true);
  RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,true);
  RemplitTableCompatibleScoreAvecCeBooleen(ScoreCompatible,true);


  ScoreNoirRecherche := -1;
  GetItemTextInDialog(dp,ScoreNoirText,s);
  if s <> '' then
    begin
      RemplitTableCompatibleScoreAvecCeBooleen(ScoreCompatible,false);
      StrToInt32(s,ScoreNoirRecherche);
      ScoreCompatible^[ScoreNoirRecherche] := true;
    end;
  GetItemTextInDialog(dp,AnneeText,s);
  anneeRecherche := StringEnAnneeSansBugAn2000(s);


  GetItemTextInDialog(dp,JoueurNoirText,JoueurNoirRecherche);
  GetItemTextInDialog(dp,JoueurBlancText,JoueurBlancRecherche);
  ANDentreJoueurs := not(JoueurBlancRecherche = JoueurNoirRecherche);
  GetItemTextInDialog(dp,tournoiText,tournoiRecherche);

  (*
  WritelnDansRapport('avant la recherche : ');
  WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurNoirText] = ',mustBeAPerfectMatch[JoueurNoirText]);
  WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurBlancText] = ',mustBeAPerfectMatch[JoueurBlancText]);
  WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[TournoiText] = ',mustBeAPerfectMatch[TournoiText]);
  *)

  if mustBeAPerfectMatch[JoueurNoirText]  then JoueurNoirRecherche    := TransformePourPerfectMatch(JoueurNoirRecherche);
  if mustBeAPerfectMatch[JoueurBlancText] then JoueurBlancRecherche   := TransformePourPerfectMatch(JoueurBlancRecherche);
  if mustBeAPerfectMatch[TournoiText]     then tournoiRecherche       := TransformePourPerfectMatch(tournoiRecherche);

  (*
  WritelnDansRapport('JoueurNoirRecherche = ' + JoueurNoirRecherche);
  WritelnDansRapport('JoueurBlancRecherche = '+ JoueurBlancRecherche);
  WritelnDansRapport('tournoiRecherche = '+ tournoiRecherche);
  *)


  if not(JoueursEtTournoisEnMemoire) then
    begin
      EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,3),20,kYpositionMessageBase);
      codeErreur := MetJoueursEtTournoisEnMemoire(false);
    end;
  if (JoueurNoirRecherche <> '') or (JoueurBlancRecherche <> '') then
    begin
      EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,4),20,kYpositionMessageBase);
      ChercheNumerosJoueursCompatibles(JoueurNoirRecherche,JoueurBlancRecherche);
    end;
  if (tournoiRecherche <> '') then
    begin
      EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,5),20,kYpositionMessageBase);
      ChercheNumerosTournoisCompatibles(tournoiRecherche);
    end;


  if DoitDessinerMessagesChargementBase then
    begin
      InitCursor;
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      s := ReadStringFromRessource(TextesBaseID,10)+CharToString(' ');  {'lecture :'}
      larg := MyStringWidth(s)+20;
      EcritMessageLectureBase(s,20,kYpositionMessageBase);
      SetRect(pourcentageRect,larg,kYpositionMessageBase-7,larg+100,kYpositionMessageBase+1);
      FrameRect(pourcentageRect);
    end;

  pourcentageCouleurRGB := NoircirCouleurDeCetteQuantite(kSteelBlueRGB,10000);
  dernierPourcentagePourTestSouris := 0;
  pourcentage := 0;
  tickchrono := TickCount;

  nbChargees := 0;
  CompteurPartiesExaminees := 0;
  dernierCompteurAffiche := 0;
  CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
  intervalleLecture := NbPartiesPotentiellementLues;
  intervallePourcentage := Trunc(1.0*intervalleLecture/100 +0.5);

  {WritelnNumDansRapport('sizeof(indexOuverture^[0]) = ', sizeof(IndexNouveauFormat.indexOuverture^[0]));
  WritelnNumDansRapport('sizeof(UInt8) = ', sizeof(UInt8));
  }

  if enAvancant
    then numeroFichierCourant := 1
    else numeroFichierCourant := InfosFichiersNouveauFormat.nbFichiers;
  REPEAT


  anneeFichierCourant := AnneePartiesFichierNouveauFormat(numeroFichierCourant);
  nroDistributionFichierCourant := InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].nroDistribution;

  {
  EcritMessageLectureBase('annee fichier = '+IntToStr(anneeFichierCourant),20,kYpositionMessageBase);
  AttendFrappeClavierOuSouris(effetspecial2);
  EcritMessageLectureBase('annee recherche = '+IntToStr(anneeRecherche),20,kYpositionMessageBase);
	AttendFrappeClavierOuSouris(effetspecial2);
	}

  if (numeroFichierCourant >= 1) and (numeroFichierCourant <= InfosFichiersNouveauFormat.nbFichiers) and
     (InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].typeDonnees = kFicPartiesNouveauFormat) and
     (InfosFichiersNouveauFormat.fichiers[numeroFichierCourant].nroDistribution in ChoixDistributions.distributionsALire) and
     (AnneeIsCompatible(anneeFichierCourant,anneeRecherche,genreDeTestPourAnnee)) then
     begin



      if (JoueurNoirRecherche <> '') or (JoueurBlancRecherche <> '') or (tournoiRecherche <> '') or (longueurOuverture > 0)
        then ChargeIndexFichierCourant(numeroFichierCourant)
        else IndexNouveauFormat.tailleIndex := 0;

		  ChercheJoueursCompatiblesPourIndex(numeroFichierCourant);
		  ChercheTournoisCompatiblesPourIndex(numeroFichierCourant);
		  ChercheOuverturesCompatiblesPourIndex(numeroFichierCourant,ouvertureActive60);

		  codeErreur := OuvreFichierNouveauFormat(numeroFichierCourant);

		  SetNumerosDePartieMinEtMaxPourCeFichier(numeroFichierCourant,numeroPartieMin,numeroPartieMax);





		  if EnAvancant
		    then limiteCompteur := numeroPartieMax
		    else limiteCompteur := numeroPartiemin;
		  if EnAvancant
		    then compteurPartieDansFichierCourant := numeroPartieMin-1
		    else compteurPartieDansFichierCourant := numeroPartieMax+1;
		  if EnAvancant
		    then incrementCompteurPartie := +1
		    else incrementCompteurPartie := -1;


		  if compteurPartieDansFichierCourant <> limiteCompteur then
		  repeat
		    DejaAuMoinsUneRecherche := true;
		    compteurPartieDansFichierCourant := compteurPartieDansFichierCourant+incrementCompteurPartie;
		    inc(CompteurPartiesExaminees);


		    with IndexNouveauFormat do
		      if (tailleIndex <= 0) or (actionDemandee = BaseLectureSansInterventionUtilisateur)
		        then passeLeFiltreDesIndex := true
		        else
				      begin
				        // compatibilite des coups ?
				        passeLeFiltreDesIndex := OuvertureCompatible[indexOuverture^[compteurPartieDansFichierCourant]];

				        // compatibilite des tounois ?
				        if passeLeFiltreDesIndex then
				          passeLeFiltreDesIndex := (TournoisCompatibleParIndex[indexTournoi^[compteurPartieDansFichierCourant]]);

				          // compatibilite des joueurs ?
				        if passeLeFiltreDesIndex then
				          if ANDentreJoueurs
				            then passeLeFiltreDesIndex := (NoirsCompatibleParIndex[indexNoir^[compteurPartieDansFichierCourant]] and
				                                        BlancsCompatibleParIndex[indexBlanc^[compteurPartieDansFichierCourant]])
				            else passeLeFiltreDesIndex := (NoirsCompatibleParIndex[indexNoir^[compteurPartieDansFichierCourant]] or
				                                        BlancsCompatibleParIndex[indexBlanc^[compteurPartieDansFichierCourant]]);
				      end;

		    if passeLeFiltreDesIndex then
		      begin
		        LitPartieNro(numeroFichierCourant,compteurPartieDansFichierCourant,enAvancant);

		        (*
		        if effetspecial2 then
		           begin
		             EcritMessageLectureBase('partie #'+IntToStr(compteurPartieDansFichierCourant)+' : lecture OK',20,kYpositionMessageBase);
		             AttendFrappeClavierOuSouris(effetspecial2);
		           end;
		        *)


		        with Partiebuff do
		          begin

		          (*
		          if effetspecial2 then
		          begin
		            EcritMessageLectureBase('nro Noir = '+IntToStr(nroJoueurNoir)+ ', soit '+GetNomJoueur(nroJoueurNoir),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		            EcritMessageLectureBase('nro Blanc = '+IntToStr(nroJoueurBlanc)+ ', soit '+GetNomJoueur(nroJoueurBlanc),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		            EcritMessageLectureBase('nro Tournoi = '+IntToStr(nroTournoi)+ ', soit '+GetNomTournoi(nroTournoi),20,kYpositionMessageBase);
		            AttendFrappeClavierOuSouris(effetspecial2);
		          end;
		          *)






		            compatibiliteTournoi := TournoiCompatible^[nroTournoi];


		            (*
		            if effetspecial2 then
		              begin
		                if compatibiliteTournoi
		                  then EcritMessageLectureBase('partie #'+IntToStr(compteurPartieDansFichierCourant)+' : compatibilite tournoi = true',20,kYpositionMessageBase)
		                  else EcritMessageLectureBase('partie #'+IntToStr(compteurPartieDansFichierCourant)+' : compatibilite tournoi = false',20,kYpositionMessageBase);
		                AttendFrappeClavierOuSouris(effetspecial2);
		              end;
		            *)

		            if compatibiliteTournoi then
		               begin
		                 if ANDentreJoueurs
		                  then compatibiliteJoueurs := JoueurNoirCompatible^[nroJoueurNoir] and
		                                             JoueurBlancCompatible^[nroJoueurBlanc]
		                  else compatibiliteJoueurs := JoueurNoirCompatible^[nroJoueurNoir] or
		                                             JoueurBlancCompatible^[nroJoueurBlanc];


		                 (*
		                 if effetspecial2 then
		                   begin
		                     if compatibiliteJoueurs
		                       then EcritMessageLectureBase('partie #'+IntToStr(compteurPartieDansFichierCourant)+' : compatibilite Joueurs = true',20,kYpositionMessageBase)
		                       else EcritMessageLectureBase('partie #'+IntToStr(compteurPartieDansFichierCourant)+' : compatibilite Joueurs = false',20,kYpositionMessageBase);
		                     AttendFrappeClavierOuSouris(effetspecial2);
		                   end;
		                 *)

		                 if compatibiliteJoueurs and ScoreCompatible^[scoreReel] then
		                    begin
		                      if (longueurOuverture <= 1) or (actionDemandee = BaseLectureSansInterventionUtilisateur)
		                        then
		                          begin
		                            inc(nbChargees);
		                            ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
		                          end
		                        else
		                          begin
		                            if (listeCoups[longueurOuverture] <> 0) then
		                              begin
    		                            if doitTraiterInterversions
      		                            then
      		                              begin

      		                                MoveMemory(POINTER_ADD(@Partiebuff , 8), GET_ADRESS_OF_FIRST_MOVE(partie60), longueurOuverture);

      		                                SET_LENGTH_OF_PACKED_GAME(partie60, longueurOuverture);

      		                                TraiteInterversionFormatThorCompile(partie60);

      		                                i := longueurOuverture;
      		                                while GET_NTH_MOVE_OF_PACKED_GAME(partie60,i, 'ChargerLaBase(1)') =
      		                                      GET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60,i, 'ChargerLaBase(2)') do dec(i);

      		                                if i = 1 then
      		                                  begin
      		                                    inc(nbChargees);
      		                                    ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
      		                                  end;
      		                              end
      		                            else
      		                              begin

      		                                MoveMemory(POINTER_ADD(@Partiebuff , 8), GET_ADRESS_OF_FIRST_MOVE(partie60), longueurOuverture);

      		                                SET_LENGTH_OF_PACKED_GAME(partie60, longueurOuverture);

      		                                i := longueurOuverture;
      		                                while GET_NTH_MOVE_OF_PACKED_GAME(partie60,i, 'ChargerLaBase(3)') =
      		                                      GET_NTH_MOVE_OF_PACKED_GAME(ouvertureactive60,i, 'ChargerLaBase(4)') do dec(i);

      		                                if i = 1 then
      		                                 begin
      		                                   inc(nbChargees);
      		                                   ChargePartie(nbChargees,nroDistributionFichierCourant,anneeFichierCourant);
      		                                 end;
      		                              end;
      		                        end;
  		                        end;
		                      end;
		                 end;
		         end; {with}
		      end;

		    if not(enAvancant)
		      then
		        begin
		          depassementLimite := (compteurPartieDansFichierCourant <= limiteCompteur);
		          DessineProgressBar(false);
		        end
		      else
		        begin
		          depassementLimite := (compteurPartieDansFichierCourant >= limiteCompteur);
		          DessineProgressBar(true);
		        end;

		  until (nbChargees >= nbrePartiesEnMemoire) or depassementLimite or annulationPendantLecture;


      codeErreur := FermeFichierNouveauFormat(numeroFichierCourant);


    end;



  if enAvancant
    then numeroFichierCourant := succ(numeroFichierCourant)
    else numeroFichierCourant := pred(numeroFichierCourant);

  UNTIL (numeroFichierCourant > InfosFichiersNouveauFormat.nbFichiers) or
        (numeroFichierCourant < 0) or
        (nbChargees >= nbrePartiesEnMemoire) or
        annulationPendantLecture;


  auMoinsUnePartieDansBuffer := (nbChargees > 0);
  if (nbChargees >= nbrePartiesEnMemoire) and not(depassementLimite) and (nbInformationMemoire < 1) then
    begin
      nbInformationMemoire := nbInformationMemoire+1;
      SysBeep(0);
      DisableKeyboardScriptSwitch;
      FinRapport;
      TextNormalDansRapport;
      ChangeFontSizeDansRapport(gCassioRapportBoldSize);
      ChangeFontDansRapport(gCassioRapportBoldFont);
      ChangeFontFaceDansRapport(bold);
      WritelnDansRapport('еееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее');
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,16));
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,17));
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,18));
      if gIsRunningUnderMacOSX
        then WritelnDansRapport(ReadStringFromRessource(TextesRapportID,41))  {'dans les prОfОrences'}
        else WritelnDansRapport(ReadStringFromRessource(TextesRapportID,19)); {'dans la fenetres d'infos du Finder'}
      WritelnDansRapport(ReadStringFromRessource(TextesRapportID,20));
      WritelnDansRapport('еееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее');
      TextNormalDansRapport;
      EnableKeyboardScriptSwitch;
    end;


  if debuggage.pendantLectureBase then
    begin
      TextFont(gCassioApplicationFont);
      TextSize(gCassioSmallFontSize);
      SetRect(lignerect,0,140,larg+35,155);
      MyEraseRect(lignerect);
      MyEraseRectWithColor(ligneRect,OrangeCmd,blackPattern,'');
      pourcentage := Trunc((compteurPartieDansFichierCourant-numeroPartieMin)*100.0/intervalleLecture+0.5);
      if pourcentage > 100 then pourcentage := 100;
      WriteNumAt('temps en ticks : ',(TickCount-tickchrono),20,150);
      WriteNumAt('nb parties trouvОes : ',nbChargees,20,162);
      WritelnDansRapportEtAttendFrappeClavier('apres affichage temps en ticks dans ChargerLaBase',true);
    end;

try_again :

  if not(annulationPendantLecture)
    then
      begin
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant OrdreDuTriRenverse := false dans ChargerLaBase',true);

        OrdreDuTriRenverse := false;
        {sousSelectionActive := false;}

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant CalculTableCriteres dans ChargerLaBase',true);

        nbPartiesChargees := nbchargees;
        CalculTableCriteres;
        SetAucunePartieDetruiteDansLaListe;
        SetAucunePartieDeLaListeNeDoitEtreSauvegardee;
        SetAucunePartieDeLaListeNEstDouteuse;
        RecopierPartiesCompatiblesCommePartiesActives;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant GetCursor dans ChargerLaBase',true);

        if not(gPendantLesInitialisationsDeCassio) and DoitDessinerMessagesChargementBase then
          begin
            watch := GetCursor(watchcursor);
            SafeSetCursor(watch);
          end;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EcritMessageLectureBase dans ChargerLaBase',true);

        EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,6),20,kYpositionMessageBase);

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TrierListePartie dans ChargerLaBase',true);

        temp := DoitExpliquerTrierListeSuivantUnClassement;
        SetDoitExpliquerTrierListeSuivantUnClassement(false);

        TrierListePartie(TriParDate,AlgoDeTriOptimum(TriParDate));
        TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));

        SetDoitExpliquerTrierListeSuivantUnClassement(temp);

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant AjusteCurseur dans ChargerLaBase',true);

        AjusteCurseur;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant IncrementeMagicCookieDemandeCalculsBase dans ChargerLaBase',true);

        IncrementeMagicCookieDemandeCalculsBase;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ConstruitTableNumeroReference dans ChargerLaBase',true);


        ConstruitTableNumeroReference(false,false);


        {Si on n'a aucune partie active, on essaye de desactiver la boite "enlever les parties d'ordinateurs"}
        if (nbPartiesChargees > 0) and (nbPartiesActives <= 0) and not(InclurePartiesAvecOrdinateursDansListe) then
          begin
            SetInclurePartiesAvecOrdinateursDansListe(true);
            goto try_again;
          end;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EssayerConstruireTitrePartie dans ChargerLaBase',true);

        EssayerConstruireTitrePartie;

        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant SetPartieHiliteeEtAjusteAscenseurListe dans ChargerLaBase',true);

        InitSelectionDeLaListe;
        SetPartieHiliteeEtAjusteAscenseurListe(1);

        ouvertureactive60 := ChainePartieLecture;
        TraductionThorEnAlphanumerique(ouvertureactive60,ouvertureactive255);
        partieEnChaine := ouvertureactive255;
      end
    else
      begin
        SetRect(lignerect,0,kYpositionMessageBase-15,larg+105,kYpositionMessageBase+3);
        MyEraseRect(lignerect);
        MyEraseRectWithColor(ligneRect,OrangeCmd,blackPattern,'');
      end;
   TextSize(0);
   TextFont(systemFont);
   TextFace(normal);

  AjusterPositionMessagesBase(fenetreMessagesBase,GetDialogWindow(dp),true);

  SetPort(oldPort);

  ChaineTournoi := NewTournoi;
  ChaineBlanc := NewBlanc;
  ChaineNoir := NewNoir;
  ChaineAnnee := NewAnnee;
  ChaineScoreNoir := NewScoreNoir;
  ChaineGenreTest := NewGenreTest;

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Sortie de ChargerLaBase',true);



end;

procedure DoAbandon;
var i,coup : SInt32;
begin
  nbPartiesChargees := 0;
  nbPartiesActives := 0;
  IncrementeMagicCookieDemandeCalculsBase;
  ConstruitTableNumeroReference(false,false);
  SetPartieHiliteeEtAjusteAscenseurListe(1);

  positionLectureModifiee := false;
  FILL_PACKED_GAME_WITH_ZEROS(ChainePartieLecture);
  if not(positionFeerique) then
    for i := 1 to nbreCoup do
      begin
        coup := GetNiemeCoupPartieCourante(i);
        if (coup >= 11) and (coup <= 88) then
          ADD_MOVE_TO_PACKED_GAME(ChainePartieLecture, coup);
      end;
  TraductionThorEnAlphanumerique(ChainePartieLecture, partieEnChaine);
end;

procedure LectureSurCriteres(actionDemandee : SInt16; fenetreMessagesBase : WindowRef);
var i : SInt16;
    FiltreLectureDialogUPP : ModalFilterUPP;
    err : OSErr;
    PeutAbandonner,ouvertureDiagonale : boolean;
    autreCoupQuatreDansPartie : boolean;
    s60 : PackedThorGame;
    s120 : String255;
    codeErreur : OSErr;
    bidon : boolean;
begin
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('EntrОe dans LectureSurCriteres',true);


  itemHit := -1;
  interversionlecturebase := true;
  s120 := PartieNormalisee(autreCoupQuatreDansPartie,false);

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant BeginDialog dans LectureSurCriteres',true);

  SwitchToScript(gLastScriptUsedInDialogs);

  if (actionDemandee = BaseLectureCriteres)
    then BeginDialog;

  FiltreLectureDialogUPP := NewModalFilterUPP(FiltreLectureDialog);
  dp := MyGetNewDialog(LectureBaseID);
  if dp <> NIL then
  begin

    if (actionDemandee = BaseLectureCriteres) then
      ShowWindow(GetDialogWindow(dp));

    if (fenetreMessagesBase = NIL) then fenetreMessagesBase := GetDialogWindow(dp);

    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MetAnciensParametres dans LectureSurCriteres',true);

    JoueurBlancCompatible  := NewTableJoueurCompatiblePtr;
    JoueurNoirCompatible   := NewTableJoueurCompatiblePtr;
    TournoiCompatible      := NewTableTournoiCompatiblePtr;
    ScoreCompatible        := NewTableScoreCompatiblePtr;

    MetAnciensParametres;
    MetParametresSpeciauxLecture;
    tousParametresvides := false;
    SelectDialogItemText(dp,JoueurNoirText,0,MAXINT_16BITS);
    SetBoolCheckBox(dp,LectureAntichronologiqueBox,LectureAntichronologique);
    GetItemTextInDialog(dp,AnneeText,s);
    anneeRecherche := StringEnAnneeSansBugAn2000(s);

    InitialisePlateauLecture(GetDialogWindow(dp));
    InstalleMenuFlottantOuverture;
    InstalleMenuFlottantBases(popUpBases,MenuFlottantBasesID,EstUneDistributionDeParties);
    GetMenuOuvertureItemAndRect;
    GetMenuBasesItemAndRect;
    CalculeNbTotalPartiesDansDistributionsALire;
    AjusterPositionMessagesBase(fenetreMessagesBase,GetDialogWindow(dp),false);
    CheckItemMarksOnMenuBases(popUpBases.itemCourantMenuBases);
    DrawPUItem(popUpBases.MenuFlottantBases,popUpBases.itemCourantMenuBases,popUpBases.menuBasesRect,false);
    DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
    MyDrawDialog(dp);

    if DoitDessinerMessagesChargementBase then
      begin
        InitCursor;
        EcritNbPartiesBase(fenetreMessagesBase);
        EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,fenetreMessagesBase);
      end;

    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ModalDialog dans LectureSurCriteres',true);

    DejaAuMoinsUneRecherche := false;
    PeutAbandonner := false;

    err := SetDialogTracksCursor(dp,true);
    repeat

      if actionDemandee = BaseLectureCriteres
        then ModalDialog(FiltreLectureDialogUPP,itemHit)  // lecture normale : l'utilisateur peut choisir ses criteres
        else itemHit := LectureBouton;                    // lecture sans intervention de l'utilisateur !

      case itemHit of
        VirtualUpdateItemInDialog:
          begin
            with popUpBases do
              begin
		            BeginUpdate(GetDialogWindow(dp));
		            RedessineDialogue(dp);
		            CheckItemMarksOnMenuBases(itemCourantMenuBases);
		            DrawPUItem(MenuFlottantBases,itemCourantMenuBases,menuBasesRect,false);
		            DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
		            EndUpdate(GetDialogWindow(dp));
		          end;
          end;
        AnnulerBouton:
          begin
            SauveToutAvantAnnuler(false);
            if PeutAbandonner then DoAbandon;
            positionLectureModifiee := false;
          end;
        ScoreNoirText:
          begin
            GetItemTextInDialog(dp,itemHit,s1);
            s := GarderSeulementLesChiffres(s1);
            SetItemTextInDialog(dp,itemHit,s);
            StrToInt32(s,aux);
            if (LENGTH_OF_STRING(s) > 2) or (aux > 64) then SysBeep(0);
          end;
        AnneeText:
          begin
            GetItemTextInDialog(dp,itemHit,s1);
            s := GarderSeulementLesChiffres(s1);
            SetItemTextInDialog(dp,itemHit,s);
            anneeRecherche := StringEnAnneeSansBugAn2000(s);
            if (LENGTH_OF_STRING(s) > 4) or ((LENGTH_OF_STRING(s) = 4) and (AnneeRecherche < 1970))
              then SysBeep(0);
            CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
            EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,fenetreMessagesBase);
          end;
        TournoiText,JoueurNoirText,JoueurBlancText:
          begin
            GetItemTextInDialog(dp,itemHit,s);
            if (s[LENGTH_OF_STRING(s)] = '=') then
              begin
                if not(JoueursEtTournoisEnMemoire) then
                  begin
                    EcritMessageLectureBase(ReadStringFromRessource(TextesBaseID,3),20,kYpositionMessageBase);
                    codeErreur := MetJoueursEtTournoisEnMemoire(false);
                    EcritMessageLectureBase('                                                             ',20,kYpositionMessageBase);
                  end;
                s := TPCopy(s,1,LENGTH_OF_STRING(s)-1);

                case itemHit of
                  JoueurNoirText : s := Complemente(complementationJoueurNoir ,false,s,i,mustBeAPerfectMatch[JoueurNoirText]);
                  JoueurBlancText: s := Complemente(complementationJoueurBlanc,false,s,i,mustBeAPerfectMatch[JoueurBlancText]);
                  TournoiText    : s := Complemente(complementationTournoi    ,false,s,i,mustBeAPerfectMatch[TournoiText]);
                end;

                (*
                WritelnDansRapport('apres la complementation : ');
                WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurNoirText] = ',mustBeAPerfectMatch[JoueurNoirText]);
                WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[JoueurBlancText] = ',mustBeAPerfectMatch[JoueurBlancText]);
                WritelnStringAndBooleanDansRapport('mustBeAPerfectMatch[TournoiText] = ',mustBeAPerfectMatch[TournoiText]);
                *)

                SetItemTextInDialog(dp,itemHit,s);
                SelectDialogItemText(dp,itemHit,i,MAXINT_16BITS);
              end;
          end;
        LectureBouton:
           begin
             if positionLectureModifiee and analyseRetrograde.enCours then
               begin
                 with popUpBases do
                   begin
                     if not(PeutArreterAnalyseRetrograde) then itemHit := -1;
                     RedessineDialogue(dp);
                     CheckItemMarksOnMenuBases(itemCourantMenuBases);
                     DrawPUItem(MenuFlottantBases,itemCourantMenuBases,menuBasesRect,false);
                     DrawPUItem(OuvertureMenu,itemmenuouverture,menuouverturerect,true);
                   end;
               end;
             if (itemHit = LectureBouton) then
               begin
		             DeplaceAnneeDuTournoi;
		             s := ReadStringFromRessource(TextesBaseID,11);    {'Stop'}
		             SetControlTitleInDialog(dp,AnnulerBouton,s);


		             HiliteControlInDialog(dp,AnnulerBouton,0);
		             HiliteControlInDialog(dp,LectureBouton,1);
		             MetParametresSpeciauxLecture;
		             EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,fenetreMessagesBase);

		             if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant ChargerLaBase dans LectureSurCriteres',true);

                 if (fenetreMessagesBase <> NIL)
                   then ChargerLaBase(fenetreMessagesBase)
                   else ChargerLaBase(GetDialogWindow(dp));

		             if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres ChargerLaBase dans LectureSurCriteres',true);

		             HiliteControlInDialog(dp,LectureBouton,0);
		             if annulationPendantLecture then
		               begin
		                 itemHit := -1;
		                 EcritNbPartiesBase(fenetreMessagesBase);
		                 FlashItem(dp,AnnulerBouton);
		                 s := ReadStringFromRessource(TextesBaseID,12);    {'Abandon'}
		                 SetControlTitleInDialog(dp,AnnulerBouton,s);
		                 PeutAbandonner := true;
		               end;
		           end;
           end;
        CoupPrecedentBouton:
           begin
             DejoueUnCoupPlateauLecture(GetDialogWindow(dp));
           end;
        OuvertureUserItemPopUp :
           begin
             bidon := EventPopUpItemInDialog(dp,OuverturestaticText,OuvertureMenu,itemmenuouverture,menuouverturerect,true,true);
             if MenuItemToOuverture(itemmenuouverture,s60) then
               begin
                 ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
                 TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie and ouvertureDiagonale,4,60);
                 JoueOuverturePlateauLecture(s60,GetDialogWindow(dp));
                 RedessineDialogue(dp);
               end;
           end;
        BasesUserItemPopUp :
           begin
             with popUpBases do
               begin
		             bidon := EventPopUpItemInDialog(dp,BasesStaticText,menuFlottantBases,itemCourantMenuBases,menuBasesRect,false,false);
		             if MenuItemToBases(itemCourantMenuBases) then
		               begin
		                 DrawPUItem(menuFlottantBases, itemCourantMenuBases, menuBasesRect,false);
		                 EcritNbPartiesBase(fenetreMessagesBase);
		                 EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,fenetreMessagesBase);
		               end;
		           end;
           end;
        GenreTestTextLectureBase:
          begin
            GetItemTextInDialog(dp,itemHit,s);
            if s = '=>' then s := '>=';
            if s = '=<' then s := '<=';
            if (s <> '=') and (s <> '>=') and (s <> '<=') and (s <> '>') and (s <> '<')
              then
                begin
                  if s <> '' then SysBeep(0);
                  genreDeTestPourAnnee := testEgalite;
                  s := '';
                end
              else
                begin
                    if s = '='  then genreDeTestPourAnnee := testEgalite;
                    if s = '>=' then genreDeTestPourAnnee := testSuperieur;
                    if s = '<=' then genreDeTestPourAnnee := testInferieur;
                    if s = '>'  then genreDeTestPourAnnee := testSuperieurStrict;
                    if s = '<'  then genreDeTestPourAnnee := testInferieurStrict;
                end;
            SetItemTextInDialog(dp,itemHit,s);
            CalculeNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee);
            EcritNbPartiesPotentiellementLues(anneeRecherche,genreDeTestPourAnnee,fenetreMessagesBase);
          end;
        LectureAntichronologiqueBox :
          begin
            ToggleCheckBox(dp,LectureAntichronologiqueBox);
            LectureAntichronologique := not(LectureAntichronologique);
          end;
      end; {case}
    until (itemHit = LectureBouton) or (itemHit = AnnulerBouton);
    SauveAnciensParametres;
    AjusterPositionMessagesBase(fenetreMessagesBase,GetDialogWindow(dp),true);

    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant DesinstalleMenuFlottantOuverture dans LectureSurCriteres',true);

    DesinstalleMenuFlottantOuverture;

    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant DesinstalleMenuFlottantBases dans LectureSurCriteres',true);

    DesinstalleMenuFlottantBases(popUpBases);

    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MyDisposeDialog dans LectureSurCriteres',true);

    MyDisposeDialog(dp);

    DisposeTableJoueurCompatible(JoueurBlancCompatible);
    DisposeTableJoueurCompatible(JoueurNoirCompatible);
    DisposeTableTournoiCompatible(TournoiCompatible);
    DisposeTableScoreCompatible(ScoreCompatible);

  end;

  if windowListeOpen then
    begin
      SetPortByWindow(wListePtr);

      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant InvalRect(QDGetPortBound) (wlistePtr) dans LectureSurCriteres',true);

      InvalRect(QDGetPortBound);
    end;
  if windowStatOpen then
    begin
      SetPortByWindow(wStatPtr);

      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant InvalRect(QDGetPortBound) (wStatPtr) dans LectureSurCriteres',true);

      InvalRect(QDGetPortBound);
    end;

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant MyDisposeModalFilterUPP dans LectureSurCriteres',true);

  MyDisposeModalFilterUPP(FiltreLectureDialogUPP);

  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant EndDialog dans LectureSurCriteres',true);

  if (actionDemandee = BaseLectureCriteres)
    then EndDialog;

  GetCurrentScript(gLastScriptUsedInDialogs);
  SwitchToRomanScript;

  if not(windowListeOpen or windowStatOpen) and ((itemHit = LectureBouton) and (nbPartiesChargees > 0)) then
    begin
      DoStatistiques;
      DoListeDeParties;
    end;

  if (itemHit = LectureBouton) or ((itemHit = AnnulerBouton) and PeutAbandonner)
    then result := true
    else result := false;

   if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de LectureSurCriteres',true);

end;



begin {Action base de donnees}
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Entree dans ActionBaseDeDonnee',true);

  result := false;
  auMoinsUnePartieDansBuffer := false;
  (* A FAIRE : tests d'ouverture de fichier *)
  if true then
	 begin
	   result := true;

	   case actionDemandee of
	     BaseLectureJoueursEtTournois  : codeErreur := MetJoueursEtTournoisEnMemoire(false);
	     BaseLectureCriteres,
	     BaseLectureSansInterventionUtilisateur
	                                   : begin
	                                       if positionFeerique then
	                                         begin
	                                           if CassioEstEnModeSolitaire and PeutParserReferencesSolitaire(CommentaireSolitaire^^,nomNoir,nomBlanc,nomTournoi)
	                                             then
	                                               begin
	                                                 ParametresOuvrirThor^^[1] := nomTournoi;
                                                   ParametresOuvrirThor^^[2] := nomBlanc;
                                                   ParametresOuvrirThor^^[3] := nomNoir;
                                                   ParametresOuvrirThor^^[4] := '';
                                                   ParametresOuvrirThor^^[5] := '';
                                                   ParametreGenreTestThor    := testEgalite;
                                                   mustBeAPerfectMatch[JoueurNoirText]  := false;
                                                   mustBeAPerfectMatch[JoueurBlancText] := false;
                                                   mustBeAPerfectMatch[TournoiText]     := false;
	                                               end
                                               else
                                                 DialoguePartieFeeriqueAvantChargementBase;

	                                           result := false;
	                                         end;

	                                       if (actionDemandee = BaseLectureSansInterventionUtilisateur) and
	                                          ((FrontWindowSaufPalette = wListePtr) or (FrontWindowSaufPalette = wStatPtr))
	                                          then LectureSurCriteres(actionDemandee, FrontWindowSaufPalette)
	                                          else LectureSurCriteres(actionDemandee, NIL);

	                                     end;
	   end  {case};
	   DerniereActionBaseEffectuee := actionDemandee;
	 end;


  FixeMarqueSurMenuBase;

  if not(actionDemandee = BaseLectureJoueursEtTournois) then
  if not((actionDemandee = BaseLectureCriteres) and positionLectureModifiee) then
  if not(enSetUp) then
    begin
      if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant HasGotEvent dans ActionBaseDeDonnee',true);

      if HasGotEvent(updateMask,myEvent,0,NIL) then
        begin
          theEvent := myEvent;

          if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant TraiteEvenements dans ActionBaseDeDonnee',true);

          TraiteEvenements;
        end;
    end;
   ActionBaseDeDonnee := result;

   if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('sortie de ActionBaseDeDonnee',true);
end;


procedure DoLectureJoueursEtTournoi(nomsCourts : boolean);
var OSErreur : OSErr;
    (* i : SInt32;
    nomTournoi : String255;
    *)
begin


  if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire) then
    begin
      OSErreur := MetJoueursEtTournoisEnMemoire(nomsCourts);

      (*
      for i := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat do
        begin
          nomTournoi := GetNomTournoi(i);


          if Pos('ictif',nomTournoi) = 0 then
            WritelnDansRapport(NomCourtDuTournoi(nomTournoi){ + ' ['+nomTournoi+']'});
        end;
      *)

    end;
end;



var
   gFicListingWThorTemp : basicfile;
   gFicListingWThor     : basicfile;

   gFichierListingWThorEstVide : boolean;

const kNomFichierDirectoryWTHOR     = 'Listing-of-WTHOR.txt';
      kNomFichierDirectoryWTHORTemp = 'Listing-of-WTHOR.temp.txt';
      kNomFichierDirectoryWTHORHtml = 'Listing-of-WTHOR.html';
      kURLTelechargementDeLaBase    = 'http://othello.federation.free.fr/info/base/';







procedure GererCompletionTelechargementFichierDeLaBase(pathFichierTelecharge : String255);
var fic : basicfile;
    err : OSErr;
    taille : SInt32;
    typeDonnees : SInt16;
    entete : t_EnTeteNouveauFormat;
    nomFichierWthorOfficiel, s : String255;
    path : String255;
    foo : boolean;
begin

  nomFichierWthorOfficiel := '';

  {WritelnDansRapportThreadSafe('Le fichier '+pathFichierTelecharge+' vient d''etre telecharge');}

  err := FichierTexteDeCassioExiste(pathFichierTelecharge,fic);

  (* WritelnNumDansRapportThreadSafe('err = ',err); *)

  if (err = NoErr) then
    begin

      // Calcul de la taille du fichier
      err := OpenFile(fic);
      if err = NoErr then
        err := GetFileSize(fic, taille);
      if err = NoErr then
        err := CloseFile(fic);

      (* WritelnNumDansRapportThreadSafe('err = ',err); *)

      if (err = NoErr) and (taille > 0) then
        begin
          (* WritelnDansRapportThreadSafe('Le fichier '+pathFichierTelecharge+' contient '+IntToStr(taille) + ' octets'); *)

          if EstUnFichierNouveauFormat(fic.info, typeDonnees, entete) then
            begin
              (* WritelnDansRapportThreadSafe('c''est un fichier WThor correct'); *)


              if SplitAt(pathFichierTelecharge, 'Temp-Cassio-', s, nomFichierWthorOfficiel) then
                begin

                  SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('SNX4'));
                  SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('QWTB'));

                  (* WritelnDansRapport('nomFichierWthorOfficiel = '+nomFichierWthorOfficiel); *)

                  err := RemplacerFichierDansLeDossierDatabaseParFichier(nomFichierWthorOfficiel, fic);

                  if (err <> NoErr)
                    then
                      begin
                        WritelnDansRapportThreadSafe('');
                        WritelnDansRapportThreadSafe('I encountered an error or a warning ('+IntToStr(err)+') while trying to update the Database folder for file '+nomFichierWthorOfficiel);
                        WritelnDansRapportThreadSafe('NB : the following downloaded file is however maybe usable (it is in a correct WThor format), use wisely:');
                        err := FSSpecToFullPath(fic.info,path);
                        WritelnDansRapportThreadSafe('      '+path);
                      end;
                end;
            end;
        end;
    end;


  // enlevons le fichier recu de la liste des fichiers И telecharger


  if (nomFichierWthorOfficiel = '')
    then foo := SplitAt(pathFichierTelecharge, 'Temp-Cassio-', s, nomFichierWthorOfficiel);

  if (nomFichierWthorOfficiel <> '')
    then EnleverUnFichierWthorDansListeATelecharger(nomFichierWthorOfficiel);

  (*
  WritelnNumDansRapport('gListeFichiersWthorATelecharger.cardinal = ',gListeFichiersWthorATelecharger.cardinal);
  WritelnNumDansRapport('NombreTelechargementsWthorEnCours = ',NombreTelechargementsWthorEnCours);
  *)

end;


procedure TelechargerFichierDeLaBase(nomFichier : String255);
var err : OSErr;
    url : LongString;
    numeroLibre : SInt32;
    pathFichierTelecharge : String255;
begin
  if TrouverSlotLibreDansLaReservePourTelecharger(numeroLibre) and
     (numeroLibre >= 0) and
     (numeroLibre <= kNumberOfAsynchroneNetworkConnections)
    then
      with gReserveZonesPourTelecharger.table[numeroLibre] do
        begin

          {url := 'http://cassio.free.fr/cassio/easy_install/Cassio_complet_francais.bak.smi.bin'; }

          url := MakeLongString(kURLTelechargementDeLaBase + nomFichier);

          // path du fichier telecharge
          pathFichierTelecharge := pathDossierFichiersAuxiliaires + ':' + 'Temp-Cassio-' + nomFichier;

          infoNetworkConnection := MakeLongString(pathFichierTelecharge);


          fic := MakeFichierAbstraitFichier(pathFichierTelecharge,0);

          err := ViderFichierAbstrait(fic);

          if FichierAbstraitEstCorrect(fic) and (err = NoErr)
            then DownloadURLToFichierAbstrait(numeroLibre, url, fic, TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase);

        end;
end;


function LigneEstDansNotreListingWthorLocal(ligne : String255) : boolean;
var err : OSErr;
    ligneDuFichier : String255;
begin

  LigneEstDansNotreListingWthorLocal := false;


  err := SetFilePosition(gFicListingWThor, 0);  // au debut

  while (err = NoErr) and not(EndOfFile(gFicListingWThor,err))  do
    begin

      err := Readln(gFicListingWThor,ligneDuFichier);


      (*
      WritelnDansRapport(ligneDuFichier);
      WritelnDansRapport(ligne);
      WritelnDansRapport('');
      *)

      if (ligneDuFichier = ligne) then   {trouve !}
        begin
          LigneEstDansNotreListingWthorLocal := true;
          exit;
        end;
    end;
end;





procedure VerifierPresenceFichierWThorChezNous(var ligne : LongString; var theFic : basicfile; var result : SInt32);
var s, nomFichier, date, heure, taille, reste : String255;
    doitTelechargerCeFichier : boolean;
    numeroFichier : SInt16;
    tailleVersionLocale : double;
    tailleSurLeSiteFFO : double;
begin  {$unused theFic, result}

  s := ligne.debutLigne;

  {
  WritelnDansRapport('ligne = '+s);
  WritelnStringAndBooleenDansRapport('gFichierListingWThorEstVide = ',gFichierListingWThorEstVide);
  }

  Parse4(s, nomFichier, date, heure, taille, reste);


  if not(gFichierListingWThorEstVide)  then
    begin

      doitTelechargerCeFichier := false;

      if gMettreAJourParInternetTOUSLesFichiersWThor or   // tous les fichiers ?
         not(LigneEstDansNotreListingWthorLocal(s))      // fichier absent de la petite liste locale precedente ?
        then
          doitTelechargerCeFichier := true
        else
          begin

            // On cherche dans la base actuellement sur le disque si on a le fichier WTHOR correspondant

            numeroFichier := GetNroPremierFichierAvecCeNom(nomFichier);

            if (numeroFichier = -1)
              then
                doitTelechargerCeFichier := true  // not found ?
              else
                begin

                   (*
                    WritelnDansRapport('');
                    WritelnDansRapport('recherche locale de = '+s);
                    *)

                  // on a trouvО une version locale d'un fichier WTHOR portant le meme nom
                  // il faut verifier si la taille locale est plus petite que la taille sur le reseau,
                  // auquelle cas on telechargera le nouveau fichier.


                  tailleSurLeSiteFFO  := StringSimpleEnReel(GarderSeulementLesChiffresOuLesPoints(taille));
                  tailleVersionLocale := TailleTheoriqueDeCeFichierNouveauFormat(numeroFichier) / 1024.0 ;


                  (*
                  WritelnDansRapport('nomFichier = '+nomFichier);
                  WritelnDansRapport('date = '+date);
                  WritelnDansRapport('heure = '+heure);
                  WritelnDansRapport('taille = '+taille);
                  WritelnStringAndReelDansRapport('tailleSurLeSiteFFO = ', tailleSurLeSiteFFO, 9);
                  WritelnStringAndReelDansRapport('tailleVersionLocale = ', tailleVersionLocale, 9);
                  *)

                  doitTelechargerCeFichier := (tailleSurLeSiteFFO >= tailleVersionLocale) and
                                              ((tailleSurLeSiteFFO - tailleVersionLocale) > 0.5);


                end;
          end;



      if doitTelechargerCeFichier then
        begin

          nomFichier := EnleveEspacesDeDroite(nomFichier);
          nomFichier := EnleveEspacesDeGauche(nomFichier);

          AjouterUnFichierWThorDansListeATelecharger(nomFichier);

        end;
    end;


end;



procedure ParserLigneOfWTHORDirectoryOnInternet(var ligne : LongString; var theFic : basicfile; var result : SInt32);
var s, left, right, date : String255;
    descr : String255;
    err : OSErr;
begin  {$unused theFic, result}

  s := ligne.debutLigne;

  {UpCaseString(s);}

  if (Pos('HREF',s) > 0) or (Pos('href',s) > 0) then
    begin

      if SplitAt(s, 'HREF', left, right) then s := right else
      if SplitAt(s, 'href', left, right) then s := right;

      { WritelnDansRapport(s); }

      if SplitAt(s, '>', left, right) then
        begin
          s := left;
          date := right;
        end;

      { WritelnDansRapport(s + date); }

      if SplitAt(date, '</A>', left, right) then date := right else
      if SplitAt(date, '</a>', left, right) then date := right;
      date := EnleveEspacesDeDroite(date);
      date := EnleveEspacesDeGauche(date);

      { WritelnDansRapport(s + date); }

      if SplitAt(s, '"', left, right) then s := right;

      { WritelnDansRapport(s + date); }

      if SplitAt(s, '"', left, right) then s := left;
      s := EnleveEspacesDeGauche(s);
      s := EnleveEspacesDeDroite(s);

      if (Pos('WTH', s) = 1) or (Pos('wth', s) = 1) then
        begin

          { maintenant la chaine s contient le nom du fichier, et date contient
            les infos sur le serveur (la date, l'heure et la taille du fichier)
          }

          descr := s + '    ' +date;

          {
          WritelnDansRapport('');
          WritelnDansRapport(descr);
          }

          err := Writeln(gFicListingWThorTemp, descr);


        end;

    end;


end;



procedure ComparerListingDuRepertoireDeLaBaseSurInternet(pathFichierTelecharge : String255);
var fic_HTML : basicfile;
    result : SInt32;
    err : OSErr;
    taille : SInt32;
begin

  result := 0;
  gFichierListingWThorEstVide := true;


  {WritelnDansRapport('Je suis dans ComparerListingDuRepertoireDeLaBaseSurInternet');}

  err := FichierTexteDeCassioExiste(pathFichierTelecharge,fic_HTML);

  if err = NoErr then
    begin

      // creation du fichier "Listing-of-WTHOR.temp.txt"

      err := FichierTexteDeCassioExiste(kNomFichierDirectoryWTHORTemp,gFicListingWThorTemp);
      if err = -43 {fnfErr => fichier non trouvО, on le crОe}
        then err := CreeFichierTexteDeCassio(kNomFichierDirectoryWTHORTemp,gFicListingWThorTemp);

      // creation du fichier "Listing-of-WTHOR.txt"

      err := FichierTexteDeCassioExiste(kNomFichierDirectoryWTHOR,gFicListingWThor);
      if err = -43 {fnfErr => fichier non trouvО, on le crОe}
        then err := CreeFichierTexteDeCassio(kNomFichierDirectoryWTHOR,gFicListingWThor);


      // ouverture et vidage du fichier "Listing-of-WTHOR.temp.txt", qui va
      // recevoir une copie des infos telechargees depuis internet

      if err = NoErr then
        begin
          err := OpenFile(gFicListingWThorTemp);
          err := EmptyFile(gFicListingWThorTemp);
        end;

      // ouverture du fichier "Listing-of-WTHOR.txt", pour pouvoir
      // comparer avec ces memes infos

      if err = NoErr then
        err := OpenFile(gFicListingWThor);


      if err = NoErr then
        begin
          err := GetFileSize(gFicListingWThor, taille);
          gFichierListingWThorEstVide := (taille = 0);
        end;

      // on parse le fichier HTML recu et on ecrit chaque ligne interessante
      //  dans le fichier "Listing-of-WTHOR.temp.txt"

      if err = NoErr then
        ForEachLineInFileDo(fic_HTML.info, ParserLigneOfWTHORDirectoryOnInternet, result);


      // fermeture du fichier Listing-of-WTHOR.temp.txt
      if (err = NoErr) and (CloseFile(gFicListingWThorTemp) = NoErr) then
        begin

          // on lit chaque ligne du fichier "Listing-of-WTHOR.temp.txt"
          //  et on regarde si elle est la meme que la ligne correspondante du
          //  fichier "Listing-of-WTHOR.txt" : si ce n'est pas le cas, il
          //  faut sans doute telecharger le nouveau fichier WTHOR correspondant

          ForEachLineInFileDo(gFicListingWThorTemp.info, VerifierPresenceFichierWThorChezNous, result);

        end;

      // vidage et fermeture du fichier "Listing-of-WTHOR.txt"
      if (err = NoErr) then
        begin
          err := EmptyFile(gFicListingWThor);
          err := CloseFile(gFicListingWThor);
        end;


      // copier le fichier "Listing-of-WTHOR.temp.txt" dans "Listing-of-WTHOR.txt"
      if (err = NoErr) then
        err := InsertFileInFile(gFicListingWThorTemp,gFicListingWThor);

    end;

end;



procedure GererTelechargementAutomatiqueDeLaBase(pathFichierTelecharge : String255; tailleFichier : SInt32);
begin

  {WritelnDansRapport('Je suis dans GererTelechargementAutomatiqueDeLaBase');

  AttendFrappeClavier;}

  if (Pos(kNomFichierDirectoryWTHORHtml, pathFichierTelecharge) > 0) and
     (tailleFichier > 0) and (tailleFichier < 40000)
    then ComparerListingDuRepertoireDeLaBaseSurInternet(pathFichierTelecharge);


  if (Pos('Temp-Cassio-WTH', pathFichierTelecharge) > 0) then
    GererCompletionTelechargementFichierDeLaBase(pathFichierTelecharge);
end;


function TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase( whileFilePtr : FichierAbstraitPtr; var networkError : SInt32) : OSErr;
type t_LocalFichierAbstraitPtr = ^FichierAbstrait;
var pathFichier : String255;
    err : OSErr;
    fic : basicfile;
    abstractFile : t_LocalFichierAbstraitPtr;
    tailleFichier : SInt32;
begin
  abstractFile := t_LocalFichierAbstraitPtr(whileFilePtr);

  err := -1;
  pathFichier := '';
  tailleFichier := 0;

  {WritelnDansRapport('Entree dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
  AttendFrappeClavier;}

  if (abstractFile <> NIL) and (abstractFile^.genre = FichierAbstraitEstFichier) then
    begin

      {
      WritelnDansRapport('avant GetBasicFileOfFichierAbstraitPtr dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
      AttendFrappeClavier;
      }

      if (whileFilePtr <> NIL) then
        err := GetBasicFileOfFichierAbstraitPtr( whileFilePtr , fic);

      {
      WritelnNumDansRapport('err = ',err);

      WritelnDansRapport('avant GetFullPathOfFSSpec dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
      AttendFrappeClavier;
      }

      if (err = NoErr) then
        pathFichier := GetFullPathOfFSSpec(fic.info);


      {WritelnDansRapport('pathFichier = '+pathFichier);
      WritelnNumDansRapport('networkError = ',networkError);}

      {
      WritelnDansRapport('avant DisposeFichierAbstrait dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
      AttendFrappeClavier;
      }


      { fermons le fichier }

      if (abstractFile <> NIL) then
        begin

          {
          WritelnNumDansRapport('abstractFile^.tailleMaximalePossible = ',abstractFile^.tailleMaximalePossible);
          WritelnNumDansRapport('abstractFile^.nbOctetsOccupes = ',abstractFile^.nbOctetsOccupes);
          }

          tailleFichier := abstractFile^.nbOctetsOccupes;

          DisposeFichierAbstrait(abstractFile^);
        end;


      {WritelnDansRapport('avant GererTelechargementAutomatiqueDeLaBase dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
      AttendFrappeClavier;}


      if (networkError = 0) and (pathFichier <> '')  then
        GererTelechargementAutomatiqueDeLaBase(pathFichier, tailleFichier);


      if (err = NoErr) and (networkError <> 0) then
        err := networkError;

      {
      WritelnDansRapport('apres GererTelechargementAutomatiqueDeLaBase dans TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
      AttendFrappeClavier;
      }

    end;

  {
  WritelnDansRapport('Sortie de TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase');
  AttendFrappeClavier;
  }

  TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase := err;
end;




procedure MettreAJourLaBaseParTelechargement;
var err : OSErr;
    url : LongString;
    numeroLibre : SInt32;
begin {$unused err, url }




  { on telecharge le listing du repertoire dans le premier fichier abstrait libre }

  // FIXME : la ligne suivante seulement pour les test !
  {gMettreAJourParInternetTOUSLesFichiersWThor := true;}

  if TrouverSlotLibreDansLaReservePourTelecharger(numeroLibre) and
     (numeroLibre >= 0) and
     (numeroLibre <= kNumberOfAsynchroneNetworkConnections)
    then
      with gReserveZonesPourTelecharger.table[numeroLibre] do
        begin

          fic := MakeFichierAbstraitFichier(pathDossierFichiersAuxiliaires + ':' + kNomFichierDirectoryWTHORHtml,0);
          infoNetworkConnection := MakeLongString('directory');

          // vidons le fichier
          err := ViderFichierAbstrait(fic);


         { url := 'http://cassio.free.fr/cassio/easy_install/Cassio_complet_francais.bak.smi.bin'; }

          url := MakeLongString(kURLTelechargementDeLaBase);

          if FichierAbstraitEstCorrect(fic) and (err = NoErr)
            then DownloadURLToFichierAbstrait(numeroLibre, url, fic, TraiterFichierAbstraitAtTheEndOfDownloadOfWthorDatabase);

        end;



  // FIXME : la ligne suivante seulement pour les test !
  // gMettreAJourParInternetTOUSLesFichiersWThor := true;
  // ComparerListingDuRepertoireDeLaBaseSurInternet(kNomFichierDirectoryWTHORHtml);

  // FIXME : la ligne suivante seulement pour les tests !
  // GererCompletionTelechargementFichierDeLaBase('Temp-Cassio-WTH_1988.wtb');
end;





END.
























