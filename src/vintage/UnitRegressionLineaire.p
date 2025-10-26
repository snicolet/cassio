UNIT UnitRegressionLineaire;


INTERFACE







 USES UnitDefCassio;




const kModeleNonAjustePourCeScore = -100000;
const minValMediane = -7500;
      maxValMediane = 7500;
type TableDistribution = array[minValMediane..maxValMediane] of SInt32;
     TableDistributionPtr = ^TableDistribution;
     TableDistributionReele = array[minValMediane..maxValMediane] of double;
     TableDistributionReelePtr = ^TableDistributionReele;


const k_PAS_DE_LISSAGE = 0;
      k_LISSAGE_MOYENNE = 1;
      k_LISSAGE_POLYNOMIAL = 2;
      k_LISSAGE_SAVITZKY_GOLAY_4_4 = 3;

const k_REGRESSION_QUALITE_EDMOND         = 1;
      k_REGRESSION_QUALITE_CASSIO         = 2;
      k_REGRESSION_QUALITE_CASSIO_ANTIQUE = 3;
      k_REGRESSION_SCORE_FINAL            = 4;
      k_REGRESSION_SCORE_FIN_OUVERTURE    = 5;
      k_REGRESSION_EDAX                   = 6;




{ initialisation et liberation de l'unite }
procedure InitUnitRegressionLineaire;
procedure LibereMemoireUnitRegressionLineaire;
procedure AllocateMemoryForCloud(numberOfPoints : SInt32);
procedure DisposeMemoryForCloud;


{ deux fonction utilitaires }
function CassioEstEnTrainDeTracerLeNuage : boolean;
procedure SetCassioEstEnTrainDeTracerLeNuage(flag : boolean; oldValue : BooleanPtr);
function UtilisateurEstEnTrainDeSurvolerLeNuage : boolean;


{ acces aux donnees du nuage de point }
procedure ViderCloud;
procedure AjouterPointDansCloud(x_loc,y_loc : SInt16; evaluation,numeroRefPartie : SInt32);
function TrouverNouveauPointPlusProcheParAlgoEnSpirale(mouseLoc : Point; var numeroPoint : SInt32) : boolean;
function TrouverNouveauPointProcheDeLaSourisDansCloud(mouseLoc : Point; var numeroPoint : SInt32) : boolean;
function GetScoreAxeVerticalParNroRefPartie(numeroReference : SInt32) : SInt32;


{ fonctions de dessin }
procedure DessineNuageDePointsRegression;
procedure DessineNuage(fonctionAppelante : String255);
procedure PlotRepereRegression;
procedure PlotRepereCourbesDistribution;
procedure PlotPointRegression(scoreTheorique,valeur,nroReferencePartie : SInt32);
procedure DessineCarreBlancCeScoreTheorique(scoreTheorique,valeur : SInt32);
procedure EffaceCourbesDistribution;
procedure DessineCourbeDistribution(quelScoreTheorique : SInt16; var c : TableDistributionPtr; typeLissage : SInt32);
procedure DessinePointsRegressionCeScoreTheorique(quelScoreTheorique : SInt16; var mediane : SInt32; avecDessinCourbeDistribution : boolean);
procedure DessineMedianeCeScoreTheorique(quelScoreTheorique,mediane : SInt32);
procedure RedrawFastApproximateCloud;
procedure RedrawFastApproximateCurve(scoreTheoriqueATracer : SInt32);



{ fonctions de calcul }
function  NoteCassioEnScoreFinal(note : SInt32) : SInt32;
function ValeurEvaluationDeCassioPourNoirDeLaPartie(nroRefPartie : SInt32; typeRegression : SInt32; var ok : boolean; var positionEtTrait : PositionEtTraitRec) : SInt32;
function MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique : SInt16; var nbPartiesFoireuses,nbPartiesOK : SInt32; var valMin,valMax : SInt32; var positionMin,positionMax : PositionEtTraitRec; var nroRefMin,nroRefMax : SInt32; var SommeDesEcarts,SommeDesCarres : SInt32; var mediane : SInt32) : SInt32;
procedure GetCentreRepereRegression(var X_centre,Y_centre : SInt32);
procedure GetScoreTheoriqueThisPointOnScreen(x_loc,y_loc : SInt32; var theorique : SInt32);
function GetScreenPointForTheseValues(scoreTheorique, estimation : SInt32) : Point;
procedure RedimensionnerLeNuage(oldWindowRect,newWindowRect : rect);


{ fonctions diverses}
procedure TestRegressionLineaire;
procedure InitialiseModeleLineaireValeursPotables;
procedure AjusteModeleLineaireFinaleAvecStat(var TotalNbPartiesOK,TotalSommeDesEcarts : SInt32);
procedure AjusteModeleLineaireFinale;
procedure MetTitreFenetreNuage;
procedure DeterminerLaMeilleureEchelleVerticaleDuNuage;
function EstUnScoreTheoriqueDontOnDoitTracerLaCourbe(score : SInt32) : boolean;


{ gestion de l'affichage des parties du nuage }
procedure OuvrirPartieDeLaListeCorrespondantACePoint(numeroDuPoint : SInt32);
procedure LanceDemandeDeVisiteDeLaPartieDeCePointDuNuage(numeroDuPoint : SInt32);
procedure TraiterDemandesDeVisiteDesPartiesDuNuage;


{ gestion de la souris dans la fenetre du nuage }
function TraiteCurseurSeBalladantSurLaFenetreDuNuage(mouseLocGlobal : Point) : boolean;
procedure ToggleTooltipWindowsInCloudSuiventLeCurseur;
procedure TraiteSourisNuage(whichEvent : eventRecord);



{ affichage dans le rapport }
procedure EcrireCloudDansRapport;
procedure EcrireReferencesDeCePointDansRapport(numeroDuPoint : SInt32);
procedure HistogrammeDesMoyennesParScoreTheoriqueDansRapport;
procedure MoyenneDeTelScoreTheoriqueDansRapport(quelScoreTheorique : SInt32; positionsExtremesDansRapport : boolean);
procedure HistogrammeValeursTheoriquesDansRapport;
function ScoreEnChaineInformative(score : SInt32) : String255;



{ petits tooltips}
procedure CreateTooltipWindowInCloud(numeroDuPoint : SInt32; commandState : boolean);
procedure CloseTooltipWindowInCloud;
procedure ShowTooltipWindowInCloud;
procedure HideTooltipWindowInCloud;
function GetTooltipWindowInCloud : WindowPtr;
function TooltipWindowInCloudOpened : boolean;
function FabriqueTexteDeuxiemeLigneDuTooltip(scoreAxeVertical, scoreAxeHorizontal : SInt32) : String255;




{ gestion de la grille pour traverser rapidement le nuage }
procedure InitGrid;
function GetGridSquareOfPoint(x,y : SInt32; var grid_x, grid_y : SInt32) : boolean;
function GetBoundingRectOfGridSquare(grid_x,grid_y : SInt32) : Rect;
procedure TrierLesPointsSelonLaGrille;
procedure SortGrid(lo,up : SInt32);
function CetteCaseDansLaGrilleContientDesPoints(grid_x, grid_y : SInt32; var indexMin, indexMax : SInt32) : boolean;
function DistanceMinEntreCePointEtCetteCaseDeLaGrille(x,y : SInt32; x_grid, y_grid : SInt32) : SInt32;


{ gestion du menu flottant permettant de selectionner le type de nuage }
procedure LoadMenuFlottantNuage;
procedure DrawMenuFlottantNuage;
procedure GererClicMenuFlottantNuage;


{ cas particulier d'Edax : on n'a pas l'eval exacte, seulement le fichier "eval-edax-correlations.csv" }
procedure LireFichierCSVEvalEdaxCorrelations;
procedure AllocateMemoryForEdaxMatrix;
procedure DisposeMemoryForEdaxMatrix;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    QuickDraw, fp, MacWindows, MacHelp, OSUtils, GestaltEqu, Sound, QuickdrawText

{$IFC NOT(USE_PRELINK)}
    , MyFileSystemUtils, MyQuickDraw, UnitEvenement, UnitJeu, MyUtils, MyAntialiasing, UnitModes, SNMenus
    , UnitActions, UnitPositionEtTrait, UnitEvaluation, UnitAccesNouveauFormat, UnitUtilitaires, UnitNouvelleEval, Unit_AB_simple, SNEvents
    , UnitScannerOthellistique, UnitRapport, UnitPositionEtTrait, UnitServicesMemoire, UnitNouveauFormat, UnitSuperviseur, UnitMoindresCarres, MyMathUtils
    , UnitServicesDialogs, UnitStrategie, MyStrings, UnitCarbonisation, UnitGestionDuTemps, UnitCouleur, UnitHashing, UnitListe
    , UnitGeometrie, UnitSetUp, UnitCarbonisation, UnitFichiersTEXT, UnitNormalisation, UnitPressePapier ;
{$ELSEC}
    ;
    {$I prelink/RegressionLineaire.lk}
{$ENDC}


{END_USE_CLAUSE}









const kNumeroCoupCalculScoreTheoriqueDansWThor = 36;

      noteImpossible = -32000;

      kMaxValeurDessineeDansNuage = 8000;  // valeur max des estimations heuristiques dessinee

const kIntervalleEntreDeuxLignesDuNuage : SInt32 = 7;      // must be odd !
      kDemiIntervalleEntreDeuxLignesDuNuage : SInt32 = 3 ;   // must be  (kIntervalleEntreDeuxLignesDuNuage div 2)


var moyenneDesValeursPourCeScore : array[0..64] of SInt32;
    medianeDesValeursPourCeScore : array[0..64] of SInt32;

    gNbPointsRegressionTraces : SInt32;
    gNbCourbesDistributionTracees : SInt32;

    gDemandeDeVisiteDePartiesDuNuage :
      record
        nbDemandes : SInt32;
        numeroPoint : SInt32;
      end;

type
  RegressionPointRec = record
                          x,y : SInt16;
                          numeroReference : SInt32;
                          eval : SInt32;
                          hashStamp : SInt32;
                        end;
  RegressionPointArray = array[0..0] of RegressionPointRec;
  RegressionPointArrayPtr = ^RegressionPointArray;
  Cloud = record
            typeDeRegression                 : SInt32;
            capaciteMaximale                 : SInt32;
            cardinal                         : SInt32;
            magicCookie                      : SInt32;
            data                             : RegressionPointArrayPtr;
            tableauDesMedianes               : array[0..64] of
                                                  record
                                                    valeur : SInt32;
                                                    medianeEstRemplie : boolean;
                                                  end;
            repereVertical                   : record
                                                 intervalleEntreLignes : SInt32;
                                                 pos_y_centre : SInt32;
                                               end;
            estTrie                          : boolean;
            tooltipsSuiventSouris            : boolean;
            gCassioEstEnTrainDeTracerLeNuage : boolean;
          end;

var gCloud : Cloud;


const kGridQuantificationLevel = 100;  // MUST be > 0
var gGrid : record
              min_x,min_y,max_x,max_y : SInt32;
              step_x,step_y : SInt32;
              rows,columns : SInt32;

              indexDansTableTriee : array[0..kGridQuantificationLevel,0..kGridQuantificationLevel] of SInt32;
            end;

var gTooltip : record
                 forWindow             : WindowPtr;
                 tooltipWindow         : WindowPtr;
                 hotRect               : Rect;
                 string1               : String255;
                 string2               : String255;
                 yellow                : RGBColor;
                 numeroDuPoint         : SInt32;
                 dateDernierAffichage  : SInt32;
                 affiche               : boolean;
                 command               : boolean;
               end;


const menuFlottantNuageID = 112;
var menuFlottantNuage : MenuFlottantRec;
    menuFlottantRect : Rect;

    couleurDesTraitsGris : RGBColor;
    couleurFondFenetreNuage : RGBColor;


const kEdaxCorrelationFileName = 'eval-edax-correlation.csv';
type MatriceCorrelationsEdaxRec = array[-64..64, 0..64] of SInt32;
     MatriceCorrelationsEdaxPtr = ^MatriceCorrelationsEdaxRec;
var gEdaxCorrelationMatrix : MatriceCorrelationsEdaxPtr;



procedure InitUnitRegressionLineaire;
begin
  with gCloud do
    begin
      typeDeRegression                     := k_REGRESSION_QUALITE_EDMOND;
      capaciteMaximale                     := 0;
      cardinal                             := 0;
      magicCookie                          := 0;
      repereVertical.intervalleEntreLignes  := 7;
      repereVertical.pos_y_centre          := 0;
      data                                 := NIL;
      estTrie                              := false;
      tooltipsSuiventSouris                := true;
      gCassioEstEnTrainDeTracerLeNuage     := false;
    end;

  with gDemandeDeVisiteDePartiesDuNuage do
    begin
      nbDemandes := 0;
      numeroPoint := 0;
    end;

  with gTooltip do
    begin
      affiche              := false;
      command              := false;
      forWindow            := NIL;
      tooltipWindow        := NIL;
      hotRect              := MakeRect(0,0,0,0);
      numeroDuPoint        := 0;
      dateDernierAffichage := 0;
      string1              := '';
      string2              := '';
    end;

  AllocateMemoryForCloud(100);
  SetCassioEstEnTrainDeTracerLeNuage(false, NIL);

  gEdaxCorrelationMatrix := NIL;
end;


procedure LibereMemoireUnitRegressionLineaire;
begin
  DisposeMemoryForCloud;
  DisposeMemoryForEdaxMatrix;
end;


procedure AllocateMemoryForCloud(numberOfPoints : SInt32);
var taille : SInt32;
begin
  with gCloud do
    begin
      if (cardinal <> 0) or (data <> NIL)
        then DisposeMemoryForCloud;

      taille := (numberOfPoints + 10)*sizeof(RegressionPointRec);
      data := RegressionPointArrayPtr(AllocateMemoryPtrClear(taille));

      if (data <> NIL)
        then
          begin
            capaciteMaximale := numberOfPoints;
            cardinal         := 0;
            estTrie          := false;
          end
        else
          begin
            capaciteMaximale := 0;
            cardinal         := 0;
            estTrie          := false;
          end;
    end;
end;

procedure DisposeMemoryForCloud;
begin
  with gCloud do
    begin
      if data <> NIL then DisposeMemoryPtr(Ptr(data));

      data             := NIL;
      capaciteMaximale := 0;
      cardinal         := 0;
      estTrie          := false;
    end;
end;


procedure ViderCloud;
var k : SInt32;
begin
  with gCloud do
    cardinal := 0;
  for k := 0 to 64 do
    with gCloud.tableauDesMedianes[k] do
      begin
        valeur := 0;
        medianeEstRemplie := false;
      end;
end;


function CassioEstEnTrainDeTracerLeNuage : boolean;
begin
  CassioEstEnTrainDeTracerLeNuage := gCloud.gCassioEstEnTrainDeTracerLeNuage;
end;


procedure SetCassioEstEnTrainDeTracerLeNuage(flag : boolean; oldValue : BooleanPtr);
begin

  if oldValue <> NIL
    then oldValue^ := gCloud.gCassioEstEnTrainDeTracerLeNuage;

  gCloud.gCassioEstEnTrainDeTracerLeNuage := flag;

  kWNESleep := 0;  // Cassio will get 100% CPU
end;


procedure AllocateMemoryForEdaxMatrix;
begin
  if (gEdaxCorrelationMatrix = NIL) then
    begin
      gEdaxCorrelationMatrix := MatriceCorrelationsEdaxPtr(AllocateMemoryPtrClear(sizeof(MatriceCorrelationsEdaxRec)));
    end;
end;

procedure DisposeMemoryForEdaxMatrix;
begin
  if (gEdaxCorrelationMatrix <> NIL) then
    DisposeMemoryPtr(Ptr(gEdaxCorrelationMatrix));
end;


procedure LireUneLigneDuFichierDeCorrelationEdax(var myLongString : LongString; var theFic : FichierTEXT; var totalParties : SInt32);
var s, aux, reste : String255;
    n, nombreDeNombresLus : SInt32;
    scoreEdax,nbDePionsDeNoirs : SInt32;
    oldParsingSet : SetOfChar;
begin
  Discard(theFic);

  with myLongString do
    begin

      // la premiere ligne et la derniere ligne du fichier ne nous interessent pas
      if (Pos('-64; -62; -60; -58; -56; -54; -52; -50; -48; -46; -44; -42;',debutLigne) > 0) or
         (Pos('somme',debutLigne) > 0) or (debutLigne = '') then
        exit(LireUneLigneDuFichierDeCorrelationEdax);


      // dans un fichier .csv, les enregisterements sont séparés par des points virgules
      oldParsingSet := GetParsingCaracterSet;
      SetParsingCaracterSet([' ',tab,';']);

      s := debutLigne;

      nombreDeNombresLus := -1;


      // lire tous les entieres sur la ligne
      repeat
        Parser(s, aux , reste);

        inc(nombreDeNombresLus);

        if (aux <> '') then
          begin

            n := ChaineEnLongint(aux);

            // la premiere colonne est le score heuristique d'Edax
            if (nombreDeNombresLus = 0) then
              begin
                scoreEdax := n;
                // WriteDansRapport(NumEnString(scoreEdax) + '; ');
              end;

            // les autres cellules representent les frequences d'Edax
            if (nombreDeNombresLus >= 1) and (nombreDeNombresLus <= 65) then
              begin
                totalParties := totalParties + n;
                if (gEdaxCorrelationMatrix <> NIL) and (scoreEdax >= -64) and (scoreEdax <= 64) then
                  begin
                    nbDePionsDeNoirs := nombreDeNombresLus - 1;

                    gEdaxCorrelationMatrix^[scoreEdax,nbDePionsDeNoirs] := n;

                    // WriteDansRapport(NumEnString(n) + '; ');
                  end;
              end;
          end;

        // gerer les lignes de plus de 255 caracteres :-)
        if (LENGTH_OF_STRING(reste) > 20)
          then
            s := reste
          else
            begin
              s := reste + finLigne;
              finLigne := '';
            end;

      until (s = '') or (nombreDeNombresLus >= 65);

      // WritelnDansRapport('');

      SetParsingCaracterSet(oldParsingSet);
    end;
end;





procedure LireFichierCSVEvalEdaxCorrelations;
var fic : FichierTEXT;
    err : OSErr;
    totalParties : SInt32;
begin
  err := FichierTexteDeCassioExiste(kEdaxCorrelationFileName,fic);
  if err = NoErr then
    begin
      AllocateMemoryForEdaxMatrix;

      if (gEdaxCorrelationMatrix <> NIL) then
        begin

          totalParties := 0;

          ForEachLineInFileDo(fic.theFSSpec, LireUneLigneDuFichierDeCorrelationEdax, totalParties);

        end;

    end;
end;




procedure InitGrid;
var i,j : SInt32;
    {myRect : Rect;
    oldPort : grafPtr;}
begin
  with gGrid do
    begin


      min_x  := GetScreenPointForTheseValues(68,-7000).h;
      min_y  := GetScreenPointForTheseValues(68,-7000).v;

      max_x  := GetScreenPointForTheseValues(-4,7000).h;
      max_y  := GetScreenPointForTheseValues(-4,7000).v;

      rows   := kGridQuantificationLevel;
      columns := kGridQuantificationLevel;

      step_x := 1 + (max_x - min_x) div (columns + 1);
      step_y := 1 + (max_y - min_y) div (rows + 1);

      for i := 0 to kGridQuantificationLevel do
        for j := 0 to kGridQuantificationLevel do
          indexDansTableTriee[i,j] := 0;


      (*
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      myRect := MakeRect(min_x, min_y, max_x, max_y);
      ForeColor(greenColor);
      FrameRect(myRect);

      SetPort(oldPort);
      *)

      (*

      WritelnNumDansRapport('min_x = ',min_x);
      WritelnNumDansRapport('min_y = ',min_y);
      WritelnNumDansRapport('max_x = ',max_x);
      WritelnNumDansRapport('max_y = ',max_y);

      WritelnNumDansRapport('step_x = ',step_x);
      WritelnNumDansRapport('step_y = ',step_y);
      *)

      (*
      WritelnDansRapport('Sortie de InitGrid');
      AttendFrappeClavier;
      *)

    end;

end;

function GetGridSquareOfPoint(x,y : SInt32; var grid_x, grid_y : SInt32) : boolean;
begin
  GetGridSquareOfPoint := false;
  grid_x := 0;
  grid_y := 0;

  with gGrid do
    begin
      if (x >= min_x) and (x <= max_x) and (y >= min_y) and (y <= max_y) then
        begin
          grid_x := (x - min_x) div step_x;
          grid_y := (y - min_y) div step_y;

          GetGridSquareOfPoint := true;
        end;
    end;
end;


function GetBoundingRectOfGridSquare(grid_x,grid_y : SInt32) : Rect;
begin
  with gGrid do
    if (grid_x >= 0) and (grid_x <= rows) and
       (grid_y >= 0) and (grid_y <= columns)
      then GetBoundingRectOfGridSquare := MakeRect(min_x + grid_x * step_x,
                                                   min_y + grid_y * step_y,
                                                   min_x + (grid_x + 1) * step_x - 1,
                                                   min_y + (grid_y + 1) * step_y - 1)
      else GetBoundingRectOfGridSquare := MakeRect(0,0,0,0);
end;


function MyLecture(index : SInt32) : RegressionPointRec;
begin
  if (index < 1) or (index > gCloud.cardinal) then
    begin
      WritelnNumDansRapport('ASSERT dans MyLecture, index = ',index);
      AttendFrappeClavier;
      exit(MyLecture);
    end;

  MyLecture := gCloud.data^[index];
end;


function MyOrdre(const element1, element2 : RegressionPointRec) : boolean;
var grid_x_1, grid_y_1 : SInt32;
    grid_x_2, grid_y_2 : SInt32;
begin

  if GetGridSquareOfPoint(element1.x, element1.y, grid_x_1, grid_y_1) and
     GetGridSquareOfPoint(element2.x, element2.y, grid_x_2, grid_y_2)
     then
       begin
         MyOrdre := (grid_x_1 > grid_x_2) or
                    ((grid_x_1 = grid_x_2) and (grid_y_1 >= grid_y_2));
       end
     else
       begin
         MyOrdre := true;
       end;
end;


procedure MyAffectation(index : SInt32; const element : RegressionPointRec);
begin

  if (index < 1) or (index > gCloud.cardinal) then
    begin
      WritelnNumDansRapport('ASSERT dans MyAffectation, index = ',index);
      AttendFrappeClavier;
      exit(MyAffectation);
    end;

  gCloud.data^[index] := element;
end;


{ ATTENTION ! La routine d'ordre doit renvoyer vrai
              pour des éléments egaux, sinon QuickSort
              ne s'arrete pas ! }
procedure SortGrid(lo,up : SInt32);
const nstack = 100;
      m = 7;
var i,j,k,l,ir,jstack : SInt32;
    a,temp,compar : RegressionPointRec;
    istack : array[1..nstack] of SInt32;
    tempInt : SInt32;
    tick : SInt32;
label 10,20,99,sortie;
begin
  if lo > up then
    begin
      tempInt := up;
      up := lo;
      lo := tempInt;
    end;

  (*
  WritelnDansRapport('Entree dans quicksort');
  WritelnNumDansRapport('lo = ',lo);
  WritelnNumDansRapport('up = ',up);
  *)

  tick := TickCount;

  if up-lo > 0 then
    begin
      jstack := 0;
      l := lo;
      ir := up;
      while true do begin
        if ir-l < m then begin
          for j := l+1 to ir do
            begin
              temp := MyLecture(j);
              for i := j-1 downto l do
                begin
                  compar := MyLecture(i);
                  if MyOrdre(temp,compar) then goto 10;
                  MyAffectation(i+1,compar);
                end;
              i := l-1;
              10:
              MyAffectation(i+1,temp);
            end;

          if jstack = 0 then goto sortie;
          ir := istack[jstack];
          l := istack[jstack-1];
          jstack := jstack-2;
        end
        else begin
          k := l + (ir - l) div 2;
          temp := MyLecture(k);
          MyAffectation(k,MyLecture(l+1));
          MyAffectation(l+1,temp);
          if MyOrdre(MyLecture(l+1),MyLecture(ir)) then begin
            temp := MyLecture(l+1);
            MyAffectation(l+1,MyLecture(ir));
            MyAffectation(ir,temp);
          end;
          if MyOrdre(MyLecture(l),MyLecture(ir)) then begin
            temp := MyLecture(l);
            MyAffectation(l,MyLecture(ir));
            MyAffectation(ir,temp);
          end;
          if MyOrdre(MyLecture(l+1),MyLecture(l)) then begin
            temp := MyLecture(l+1);
            MyAffectation(l+1,MyLecture(l));
            MyAffectation(l,temp);
          end;
          i := l+1;
          j := ir;

          a := MyLecture(l);
          while true do begin
            repeat inc(i) until MyOrdre(MyLecture(i),a);
            repeat dec(j) until MyOrdre(a,MyLecture(j));
            if j < i then goto 20; {break}
            temp := MyLecture(i);
            MyAffectation(i,MyLecture(j));
            MyAffectation(j,temp);
          end;
  20:     MyAffectation(l,MyLecture(j));
          MyAffectation(j,a);
          jstack := jstack+2;
          if jstack > nstack then AlerteSimple('Erreur dans SortGrid : nstack est trop petit');
          if ir-i+1 >= j-l then begin
            istack[jstack] := ir;
            istack[jstack-1] := i;
            ir := j-1;
          end
          else begin
            istack[jstack] := j-1;
            istack[jstack-1] := l;
            l := i;
          end;
        end;
      end;
   99 :
   end;

   sortie :
   {WritelnNumDansRapport('Temps de Quicksort = ',TickCount - tick);}
end;  {SortGrid}


function CetteCaseDansLaGrilleContientDesPoints(grid_x, grid_y : SInt32; var indexMin, indexMax : SInt32) : boolean;
var grid_x_precedent : SInt32;
    grid_y_precedent : SInt32;
begin
  indexMin := 0;
  indexMax := 0;

  if (grid_x < 0) or (grid_x > kGridQuantificationLevel) or
     (grid_y < 0) or (grid_y > kGridQuantificationLevel) then
    begin
      CetteCaseDansLaGrilleContientDesPoints := false;
      exit(CetteCaseDansLaGrilleContientDesPoints);
    end;

  if (grid_x = 0) and (grid_y = 0)
    then
      begin
        indexMin := 1;
        indexMax := gGrid.indexDansTableTriee[0,0];
      end
    else
      begin
        grid_y_precedent := grid_y - 1;
        grid_x_precedent := grid_x;

        if (grid_y_precedent < 0) then
          begin
            grid_y_precedent := kGridQuantificationLevel;
            grid_x_precedent := grid_x_precedent - 1;
          end;

        indexMin := 1 + gGrid.indexDansTableTriee[grid_x_precedent, grid_y_precedent];
        indexMax :=     gGrid.indexDansTableTriee[grid_x,           grid_y];
      end;

   CetteCaseDansLaGrilleContientDesPoints := (indexMin <= indexMax);
end;


procedure TrierLesPointsSelonLaGrille;
var i,j,n,somme : SInt32;
    {k : SInt32;
    indexMin, indexMax : SInt32;
    boundingRect : Rect;
    grid_x,grid_y : SInt32;
    oldPort : grafPtr;}
begin

  (*
  WritelnDansRapport('Entree dans TrierLesPointsSelonLaGrille…');
  AttendFrappeClavier;
  *)

  InitGrid;


  // trier les points du nuage selon leur emplacement dans la grille
  if (gCloud.cardinal > 0) then
    SortGrid(1, gCloud.cardinal);

  (*
  WritelnDansRapport('Avant l''initialisation de la table…');
  AttendFrappeClavier;
  *)

  // initialiser la table
  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      gGrid.indexDansTableTriee[i,j] := 0;

  // count items in each cell of the grid
  for n := 1 to gCloud.cardinal do
    begin
      with gCloud.data^[n] do
        if GetGridSquareOfPoint(x, y, i, j) then
          begin
            inc(gGrid.indexDansTableTriee[i, j]);
          end;
    end;

  (*

  WritelnDansRapport('Avant l''ecriture des count…');
  AttendFrappeClavier;

  *)
  (*
  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      begin
        WritelnNumDansRapport('count['+NumEnString(i)+','+NumEnString(j)+'] = ',gGrid.indexDansTableTriee[i, j]);
      end;
  *)

  // do enumeration sort in the grid
  somme := 0;
  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      begin
        somme := somme + gGrid.indexDansTableTriee[i,j];
        gGrid.indexDansTableTriee[i,j] := somme;
      end;

  (*
  WritelnDansRapport('Avant l''ecriture des cumuls…');
  AttendFrappeClavier;
  *)

  (*

  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      begin
        WritelnNumDansRapport('somme['+NumEnString(i)+','+NumEnString(j)+'] = ',gGrid.indexDansTableTriee[i, j]);
      end;


  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      begin

        if CetteCaseDansLaGrilleContientDesPoints(i,j, indexMin, indexMax) then
          begin
            WriteDansRapport('Grille['+NumEnString(i)+','+NumEnString(j)+'] = ');
            WriteNumDansRapport('{ m = ',indexMin);
            WriteNumDansRapport(', M = ',indexMax);
            WritelnDansRapport(' }');
          end;
      end;
  *)



  // verification du tri

  (*
  GetPort(oldPort);
  SetPortByWindow(wNuagePtr);
  ForeColor(redColor);
  FrameRect(MakeRect(gGrid.min_x,gGrid.min_y,gGrid.max_x,gGrid.max_y));
  SetPort(oldPort);

  WritelnNumDansRapport('gGrid.min_x = ',gGrid.min_x);
  WritelnNumDansRapport('gGrid.min_y = ',gGrid.min_y);
  WritelnNumDansRapport('gGrid.max_x = ',gGrid.max_x);
  WritelnNumDansRapport('gGrid.max_y = ',gGrid.max_y);
  *)

  (*
  for i := 0 to kGridQuantificationLevel do
    for j := 0 to kGridQuantificationLevel do
      if CetteCaseDansLaGrilleContientDesPoints(i,j,indexMin,indexMax) then
        begin
          boundingRect := GetBoundingRectOfGridSquare(i,j);

          for k := indexMin to indexMax do
            with gCloud.data^[k] do
              begin
                if (x < boundingRect.left) or (x > boundingRect.right) or (y < boundingRect.top) or (y > boundingRect.bottom)
                  then
                    begin
                      WritelnDansRapport('ASSERT ! point pas dans le bounding rect de sa case..');
                      WritelnNumDansRapport('k = ',k);
                      WritelnNumDansRapport('x = ',x);
                      WritelnNumDansRapport('y = ',y);
                      AttendFrappeClavier;
                    end;

                if not(GetGridSquareOfPoint(x,y,grid_x,grid_y))
                  then
                    begin
                      WritelnDansRapport('ASSERT ! not(GetGridSquareOfPoint) ... ');
                      WritelnNumDansRapport('k = ',k);
                      AttendFrappeClavier;
                    end
                  else
                    begin
                      if (grid_x <> i) or (grid_y <> j) then
                        begin
                          WritelnDansRapport('ASSERT ! (grid_x <> i) or (grid_y <> j) ... ');
                          WritelnNumDansRapport('k = ',k);
                          WritelnNumDansRapport('i = ',i);
                          WritelnNumDansRapport('j = ',j);
                          WritelnNumDansRapport('grid_x = ',grid_x);
                          WritelnNumDansRapport('grid_y = ',grid_y);
                          AttendFrappeClavier;
                        end;
                    end;

              end;



          GetPort(oldPort);
          SetPortByWindow(wNuagePtr);
          ForeColor(yellowColor);
          FrameRect(boundingRect);
          SetPort(oldPort);
        end;


  *)

  (*
  WritelnDansRapport('Sortie de TrierLesPointsSelonLaGrille');
  AttendFrappeClavier;
  *)

  gCloud.estTrie := true;
end;



procedure AjouterPointDansCloud(x_loc,y_loc : SInt16; evaluation,numeroRefPartie : SInt32);
var index : SInt32;
begin
  with gCloud do
    begin
      index := cardinal + 1;

      if (index >= 0) and (index <= capaciteMaximale) and
         (capaciteMaximale > 0) and (data <> NIL) then
        with data^[index] do
          begin

            x := x_loc;
            y := y_loc;

            with gGrid do
              begin
                if (x < min_x) then x := min_x;
                if (x > max_x) then x := max_x;
                if (y < min_y) then y := min_y;
                if (y > max_y) then y := max_y;
              end;

            eval := evaluation;

            if (numeroRefPartie > 0)
              then hashStamp := HashPartieDansListeParNroRefPartie(numeroRefPartie)
              else hashStamp := 0;

            numeroReference := numeroRefPartie;

            inc(cardinal);

            estTrie := false;
          end;
    end;
end;


procedure RedimensionnerLeNuage(oldWindowRect,newWindowRect : rect);
var ancienneLargeur, nouvelleLargeur : SInt32;
    k, larg : SInt32;
    oldPort : grafPtr;
    x_centre,y_centre : SInt32;
    ancienIntervalleEntreDeuxLignes : SInt32;
    ancienDemiIntervalle : SInt32;
    theorique : SInt32;
    perturbation : SInt32;
    ancien_y_centre : SInt32;
    oldTracage : boolean;
begin

  if not(CassioEstEnTrainDeTracerLeNuage) then
    begin
      SetCassioEstEnTrainDeTracerLeNuage(true, @oldTracage);

      ancienneLargeur := oldWindowRect.right - oldWindowRect.left;
      nouvelleLargeur := newWindowRect.right - newWindowRect.left;

      if windowNuageOpen and (wNuagePtr <> NIL) then
        begin

          GetPort(oldPort);
          SetPortByWindow(wNuagePtr);

          larg := QDGetPortBound.right div 2;

          with gCloud do
            begin
              ancienIntervalleEntreDeuxLignes := repereVertical.intervalleEntreLignes;
              ancien_y_centre                := repereVertical.pos_y_centre;

              ancienDemiIntervalle            := ancienIntervalleEntreDeuxLignes div 2;

              DeterminerLaMeilleureEchelleVerticaleDuNuage;

              if (cardinal > 0) and (data <> NIL) then
                if ((ancienneLargeur <> nouvelleLargeur) and (ancienneLargeur <> 0) and (nouvelleLargeur <> 0)) or
                   (kIntervalleEntreDeuxLignesDuNuage <> ancienIntervalleEntreDeuxLignes) then
                  begin


                    GetCentreRepereRegression(x_centre,y_centre);

                    {
                    WritelnNumDansRapport('ancienIntervalleEntreDeuxLignes = ',ancienIntervalleEntreDeuxLignes);
                    WritelnNumDansRapport('kIntervalleEntreDeuxLignesDuNuage = ',kIntervalleEntreDeuxLignesDuNuage);
                    WritelnNumDansRapport('ancien_y_centre = ',ancien_y_centre);
                    WritelnNumDansRapport('y_centre = ',y_centre);
                    }

                    for k := 1 to cardinal do
                      with data^[k] do
                        begin

                          // calculer la nouvelle abscisse

                          x := larg + ((eval*larg) div kMaxValeurDessineeDansNuage);


                          if (kIntervalleEntreDeuxLignesDuNuage <> ancienIntervalleEntreDeuxLignes) then
                            begin

                              // calculer la nouvelle ordonnee

                              if y >= ancien_y_centre - ancienDemiIntervalle
                                then theorique := 32 - ((y - ancien_y_centre + ancienDemiIntervalle) div ancienIntervalleEntreDeuxLignes)
                                else theorique := 32 + ((ancien_y_centre - y + ancienDemiIntervalle) div ancienIntervalleEntreDeuxLignes);

                              if theorique < 0  then theorique := 0;
                              if theorique > 64 then theorique := 64;

                              if (theorique > 64) or (theorique < 0) then
                                 begin
                                   WritelnDansRapport('ASSERT !!! ((theorique > 64) or (theorique < 0)) dans RedimensionnerLeNuage');
                                   WritelnNumDansRapport('theorique = ',theorique);
                                   WritelnNumDansRapport('ancien y = ',y);
                                   leave;
                                 end;

                              perturbation := Random16();

                              if (perturbation >= 0)
                                then y := y_centre - (theorique - 32)*kIntervalleEntreDeuxLignesDuNuage + (perturbation mod (1 + kDemiIntervalleEntreDeuxLignesDuNuage))
                                else y := y_centre - (theorique - 32)*kIntervalleEntreDeuxLignesDuNuage - ((-perturbation) mod (1 + kDemiIntervalleEntreDeuxLignesDuNuage));
                            end;

                        end;

                    repereVertical.intervalleEntreLignes := kIntervalleEntreDeuxLignesDuNuage;
                    repereVertical.pos_y_centre         := y_centre;

                    estTrie := false;

                    TrierLesPointsSelonLaGrille;
                  end;
            end;

          SetPort(oldPort);

        end;

      SetCassioEstEnTrainDeTracerLeNuage(oldTracage, NIL);
    end;

end;





var gLastRecherchePointPlusProcheDansCloud :
       record
         last_mouse_x    : SInt32;
         last_mouse_y    : SInt32;
         lastTick        : SInt32;
         lastNumeroPoint : SInt32;
       end;


function DistanceMinEntreCePointEtCetteCaseDeLaGrille(x,y : SInt32; x_grid, y_grid : SInt32) : SInt32;
var delta_x, delta_y, aux : SInt32;
    theRect : Rect;
begin
  theRect := GetBoundingRectOfGridSquare(x_grid, y_grid);

  with theRect do
    begin
      delta_x := abs(x - left);
      aux := abs(x - right);
      if (aux < delta_x) then delta_x := aux;

      delta_y := abs(y - top);
      aux := abs(y - bottom);
      if (aux < delta_y) then delta_y := aux;

      DistanceMinEntreCePointEtCetteCaseDeLaGrille := delta_x + delta_y;
    end;
end;


procedure UpdateDistance(which_x_grid, which_y_grid : SInt32;
                         mouse_x,mouse_y : SInt32;
                         var bestDistance, numeroMeilleurPoint : SInt32;
                         var continuer : boolean;
                         debug : boolean);
var k : SInt32;
    indexMin, indexMax : SInt32;
    minorationDeLaDistance : SInt32;
    distance : SInt32;
    margeDeSecuritePourEstimerLaDistance : SInt32;
begin

  if debug then
    begin
      WritelnDansRapport('(x_,y_) = ('+NumEnString(which_x_grid)+' , '+NumEnString(which_y_grid)+')');
      ForeColor(blueColor);
      FrameRect(GetBoundingRectOfGridSquare(which_x_grid,which_y_grid));
      AttendFrappeClavier;
    end;

  if CetteCaseDansLaGrilleContientDesPoints(which_x_grid, which_y_grid, indexMin, indexMax) then
   begin

     margeDeSecuritePourEstimerLaDistance := 2*(gGrid.step_x + gGrid.step_y);

     minorationDeLaDistance := DistanceMinEntreCePointEtCetteCaseDeLaGrille(mouse_x, mouse_y, which_x_grid, which_y_grid) - margeDeSecuritePourEstimerLaDistance;

     if debug then
        begin
          WritelnNumDansRapport('indexMin = ',indexMin);
          WritelnNumDansRapport('indexMax = ',indexMax);
          ForeColor(yellowColor);
          FrameRect(GetBoundingRectOfGridSquare(which_x_grid,which_y_grid));
          WritelnNumDansRapport('DistanceMinEntreCePointEtCetteCaseDeLaGrille = ',DistanceMinEntreCePointEtCetteCaseDeLaGrille(mouse_x, mouse_y, which_x_grid, which_y_grid));
          WritelnNumDansRapport('margeDeSecuritePourEstimerLaDistance = ',margeDeSecuritePourEstimerLaDistance);
          WritelnNumDansRapport('minorationDeLaDistance = ',minorationDeLaDistance);
          AttendFrappeClavier;
        end;

     // cut-off ?
     if (minorationDeLaDistance > bestDistance) then
       begin
         if debug then
            begin
              WritelnNumDansRapport('minorationDeLaDistance = ',minorationDeLaDistance);
              WritelnNumDansRapport('bestDistance = ',bestDistance);
              WritelnDansRapport('  =>  cutof !!');
              AttendFrappeClavier;
            end;
         continuer := false;
         exit(UpdateDistance);
       end;

     if debug then
       begin
         ForeColor(greenColor);
         FrameRect(MakeRect(mouse_x - 1, mouse_y - 1, mouse_x + 2, mouse_y + 2));
       end;

     for k := indexMin to indexMax do
       with gCloud.data^[k] do
          begin

            if debug then
               begin
                 ForeColor(magentaColor);
                 FrameRect(MakeRect(x - 1, y - 1, x + 2, y + 2));
               end;

            distance := abs(x - mouse_x) + abs(y - mouse_y);

            if (distance < bestDistance) then
              begin
                numeroMeilleurPoint := k;
                bestDistance        := distance;

                if debug then
                  begin
                    ForeColor(redColor);
                    FrameRect(GetBoundingRectOfGridSquare(which_x_grid,which_y_grid));
                    WritelnNumDansRapport('amelioration de bestDistance, bestDistance = ',bestDistance);
                    WritelnNumDansRapport('  donc  numeroMeilleurPoint = ',numeroMeilleurPoint);
                    AttendFrappeClavier;
                  end;

                if (distance = 0) then
                  begin

                    if debug then
                        begin
                          WritelnNumDansRapport('distance = ',distance);
                          WritelnDansRapport('  =>  trouve !!');
                          AttendFrappeClavier;
                        end;

                    continuer := false;
                    exit(UpdateDistance);
                  end;
              end;
          end;
   end;
end;


function TrouverNouveauPointPlusProcheParAlgoEnSpirale(mouseLoc : Point; var numeroPoint : SInt32) : boolean;
var minDistance : SInt32;
    mouse_x,mouse_y : SInt32;
    best,t : SInt32;
    tick : SInt32;
    grid_x, grid_y : SInt32;
    i,j,n : SInt32;
    continuer : boolean;
    debug : boolean;

begin

  TrouverNouveauPointPlusProcheParAlgoEnSpirale := false;

  tick := TickCount;

  // debug := DernierEvenement.option;
  debug := false;

  minDistance := 100000000;
  best := 0;

  mouse_x := mouseLoc.h;
  mouse_y := mouseLoc.v;


  if DernierEvenement.command = gTooltip.command then
    begin

      // Don't search if the mouse has not moved or the time has not moved enough

      with gLastRecherchePointPlusProcheDansCloud do
        if (gCloud.cardinal <= 0) or                                     // pas de point
           ((mouse_x = last_mouse_x) and (mouse_y = last_mouse_y)) or      // meme souris
           (abs(TickCount - lastTick) <= 1)                             // meme tick
          then
            begin
              exit(TrouverNouveauPointPlusProcheParAlgoEnSpirale);
            end;
    end;

  if not(GetGridSquareOfPoint(mouse_x,mouse_y,grid_x,grid_y)) then    // souris pas sur nuage
    exit(TrouverNouveauPointPlusProcheParAlgoEnSpirale);



  // Recherche en spirale dans le nuage de point, a partir de la position de la souris
  with gCloud do
    begin
      if (cardinal > 0) and (data <> NIL) then
        begin

          continuer := true;

          i := grid_x;
          j := grid_y;

          if debug then
              WritelnDansRapport('(i,j) = ('+NumEnString(i)+' , '+NumEnString(j)+')');

          // cherchons d'abord dans la cellule de la grille contenant la souris
          UpdateDistance(i,j, mouse_x, mouse_y, minDistance, best, continuer, debug);


          // puis en spirale autour de cette cellule
          if continuer then
            for n := 1 to 2*kGridQuantificationLevel do
              if continuer then
                for t := 0 to n-1 do
                  begin
                    if continuer then UpdateDistance(i + n - t, j + t     , mouse_x, mouse_y, minDistance, best, continuer, debug);
                    if continuer then UpdateDistance(i - t    , j + n - t , mouse_x, mouse_y, minDistance, best, continuer, debug);
                    if continuer then UpdateDistance(i - n + t, j - t     , mouse_x, mouse_y, minDistance, best, continuer, debug);
                    if continuer then UpdateDistance(i + t    , j - n + t , mouse_x, mouse_y, minDistance, best, continuer, debug);
                  end;
        end;
    end;



  // WritelnNumDansRapport('best = ',best);

  if (best = 0)
    then
      begin
        WritelnDansRapport('ASSERT ! point non trouve dans TrouverNouveauPointPlusProcheParAlgoEnSpirale');
        TrouverNouveauPointPlusProcheParAlgoEnSpirale := false;

      end
    else
      begin
        if (best <> 0) then
          begin
            numeroPoint := best;
            TrouverNouveauPointPlusProcheParAlgoEnSpirale := true;

            // Store the mouse position and the time of the last search
            with gLastRecherchePointPlusProcheDansCloud do
              begin
                last_mouse_x := mouse_x;
                last_mouse_y := mouse_y;
                lastTick := TickCount;
                lastNumeroPoint := numeroPoint;
              end;

          end;
       end;


  {WritelnNumDansRapport('temps de TrouverNouveauPointPlusProcheParAlgoEnSpirale = ',TickCount - tick);}
end;



function TrouverNouveauPointProcheDeLaSourisDansCloud(mouseLoc : Point; var numeroPoint : SInt32) : boolean;
var distance : SInt32;
    minDistance : SInt32;
    mouse_x,mouse_y : SInt32;
    best,k : SInt32;
    tick : SInt32;
begin
  tick := TickCount;

  TrouverNouveauPointProcheDeLaSourisDansCloud := false;

  minDistance := 100000000;
  best := 0;

  mouse_x := mouseLoc.h;
  mouse_y := mouseLoc.v;



  if DernierEvenement.command = gTooltip.command then
    begin

      // Don't search if the mouse has not moved or the time has not moved enough

      with gLastRecherchePointPlusProcheDansCloud do
        if (gCloud.cardinal <= 0) or                                     // pas de point
           ((mouse_x = last_mouse_x) and (mouse_y = last_mouse_y)) or      // meme souris
           (abs(TickCount - lastTick) <= 1)                             // meme tick
          then exit(TrouverNouveauPointProcheDeLaSourisDansCloud);
    end;


  // WritelnDansRapport('recherche.. ');

  // Recherche lineaire pour le moment :-(
  // Remarque : il faudra vraiment changer ça pour accélerer !
  with gCloud do
    begin
      if (cardinal > 0) and (data <> NIL) then
        begin
          for k := 1 to cardinal do
            with data^[k] do
              begin
                distance := abs(x - mouse_x) + abs(y - mouse_y);

                if (distance < minDistance) then
                  begin
                    best := k;
                    minDistance := distance;

                    if (distance = 0) then leave;
                  end;
              end;
        end;
    end;


  // WritelnNumDansRapport('best = ',best);

  if (best <> 0) then
    begin
      numeroPoint := best;
      TrouverNouveauPointProcheDeLaSourisDansCloud := true;

      // Store the mouse position and the time of the last search
      with gLastRecherchePointPlusProcheDansCloud do
        begin
          last_mouse_x := mouse_x;
          last_mouse_y := mouse_y;
          lastTick := TickCount;
          lastNumeroPoint := numeroPoint;
        end;

    end;

  {WritelnNumDansRapport('temps de TrouverNouveauPointProcheDeLaSourisDansCloud = ',TickCount - tick);}
end;

procedure GetCentreRepereRegression(var X_centre,Y_centre : SInt32);
var oldPort : GrafPtr;
begin

  GetPort(oldport);
  SetPortByWindow(wNuagePtr);

  X_centre := QDGetPortBound.right div 2;
  Y_centre := QDGetPortBound.bottom div 2;

  if (Y_centre > 34*kIntervalleEntreDeuxLignesDuNuage) then Y_centre := 34*kIntervalleEntreDeuxLignesDuNuage;

  SetPort(oldPort);
end;


function ScoreEnChaineInformative(score : SInt32) : String255;
var s : String255;
begin

  s := '';

  if (score >= 32)
    then s := s + '+'+NumEnString(2*(score-32))+''
    else s := s + ''+NumEnString(2*(score-32))+'';
  s := s + ' ('+NumEnString(score) + '-' + NumEnString(64-score)+')';

  ScoreEnChaineInformative := s;
end;


procedure GetScoreTheoriqueThisPointOnScreen(x_loc,y_loc : SInt32; var theorique : SInt32);
var x_centre, y_centre : SInt32;
begin {$unused x_loc}
  GetCentreRepereRegression(x_centre,y_centre);

  if y_loc >= y_centre - kDemiIntervalleEntreDeuxLignesDuNuage
    then theorique := 32 - ((y_loc - y_centre + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage)
    else theorique := 32 + ((y_centre - y_loc + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage);

  if theorique < 0  then theorique := 0;
  if theorique > 64 then theorique := 64;

end;


function GetScreenPointForTheseValues(scoreTheorique, estimation : SInt32) : Point;
var x_centre,y_centre : SInt32;
    a , b : SInt32;
begin
  GetCentreRepereRegression(x_centre,y_centre);

  a := x_centre + ((estimation * x_centre) div kMaxValeurDessineeDansNuage);
  b := y_centre - (scoreTheorique - 32)*kIntervalleEntreDeuxLignesDuNuage;

  GetScreenPointForTheseValues := MakePoint(a, b);
end;


function UtilisateurEstEnTrainDeSurvolerLeNuage : boolean;
begin
  UtilisateurEstEnTrainDeSurvolerLeNuage := (abs(TickCount - gTooltip.dateDernierAffichage) < 60);
end;

procedure SetYellowColorForTooltip;
begin
  SetRGBColor(gTooltip.yellow, 65278,65278,50886);
  RGBForeColor(gTooltip.yellow);
  RGBBackColor(gTooltip.yellow);
end;


procedure CalculateWidthAndHeightOfTooltipWindow(commandState : boolean; var largeur,hauteur : SInt32);
var ligne1,ligne2 : STring255;
    max,larg : SInt32;
begin

   largeur := 0;
   hauteur := 0;
   max := 0;

  if commandState
    then SplitBy(gTooltip.string2, chr(13), ligne1, ligne2)
    else SplitBy(gTooltip.string1, chr(13), ligne1, ligne2);

  EnableQuartzAntiAliasing(true);

  TextSize(9);
  TextFont(GenevaID);

  if (ligne1 <> '') then
    begin
      larg := MyStringWidth(ligne1);
      if larg > max then max := larg;
      hauteur := 15;
    end;

  if (ligne2 <> '') then
    begin
      larg := MyStringWidth(ligne2);
      if larg > max then max := larg;
      hauteur := 29;
    end;

  largeur := max;
end;

procedure DrawStringInTooltipWindow(const s : String255);
var ligne1,ligne2 : STring255;
begin
  SplitBy(s, chr(13), ligne1, ligne2);


  EnableQuartzAntiAliasing(true);

  Moveto(4,11);
  MyDrawString(ligne1);

  if (ligne2 <> '') then
    begin
      Moveto(4,24);
      MyDrawString(ligne2);
    end;
end;


procedure DrawTooltipWindowInCloud;
var oldPort : grafPtr;
    myRect : Rect;
    err : OSStatus;
begin
  with gTooltip do
    if (tooltipWindow <> NIL) and affiche then
      begin
        GetPort(oldPort);
        SetPortByWindow(tooltipWindow);

        SetYellowColorForTooltip;

        myRect := QDGetPortBound;

        MyEraseRect(myRect);
        MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');

        ForeColor(blackColor);

        TextSize(9);
        TextFont(GenevaID);

        Moveto(2,11);

        if command
          then DrawStringInTooltipWindow(string2)
          else DrawStringInTooltipWindow(string1);

        QDFlushPortBuffer(GetWindowPort(tooltipWindow), NIL);



        RGBForeColor(gPurBleu);
        RGBBackColor(gPurBleu);

        ValidRect(QDGetPortBound);

        err := SetWindowContentColor(tooltipWindow,yellow);

        SetPort(oldPort);
      end;
end;


procedure ShowTooltipWindowInCloud;
var oldPort : grafPtr;
    err : OSStatus;
begin
  with gTooltip do
  if (tooltipWindow <> NIL) and not(affiche) then
    begin
      GetPort(oldPort);
      SetPortByWindow(tooltipWindow);

      affiche := true;
      dateDernierAffichage := TickCount;

      err := SetWindowContentColor(tooltipWindow,yellow);

      ShowWindow(tooltipWindow);

      DrawTooltipWindowInCloud;

      {AttendFrappeClavier;}

      SetPort(oldPort);
    end;
end;


procedure HideTooltipWindowInCloud;
var err : OSErr;
begin
  with gTooltip do
  if (tooltipWindow <> NIL) and affiche then
    begin
      HideWindow(tooltipWindow);
      err := SetWindowContentColor(tooltipWindow,yellow);
      affiche := false;
    end;
end;


procedure CloseTooltipWindowInCloud;
var err : OSStatus;
begin  {$unused err}

  with gTooltip do
    if (tooltipWindow <> NIL) then
      begin
        DisposeWindow(tooltipWindow);

        tooltipWindow := NIL;
        forWindow     := NIL;
        affiche       := false;
        command       := false;
        hotRect       := MakeRect(0,0,0,0);
        numeroDuPoint := 0;
        string1       := '';
        string2       := '';
      end;
end;



function GetTooltipWindowInCloud : WindowPtr;
begin
  GetTooltipWindowInCloud := gTooltip.tooltipWindow;
end;



function TooltipWindowInCloudOpened : boolean;
begin
  TooltipWindowInCloudOpened := (gTooltip.tooltipWindow <> NIL) and gTooltip.affiche;
end;



procedure ToggleTooltipWindowsInCloudSuiventLeCurseur;
begin
  gCloud.tooltipsSuiventSouris := not(gCloud.tooltipsSuiventSouris);
end;



function MyHMSetWindowHelpContent(forWhichWindow : WindowPtr; var help : HMHelpContentRec; commandState : boolean) : OSStatus;
var err : OSStatus;
    contentRect : Rect;
    largeurNecessaire : SInt32;
    hauteurNecessaire : SInt32;
    milieu : SInt32;
    attributes : UInt32;
    useSmoothTransitions : boolean;
begin

  useSmoothTransitions := false;

  with gTooltip do
    begin
      affiche              := false;
      command              := commandState;
      forWindow            := forWhichWindow;
      hotRect              := help.absHotRect;
      dateDernierAffichage := 0;
      numeroDuPoint        := 0;
      string1              := MyStr255ToString(help.content[kHMMinimumContentIndex].tagString);
      string2              := MyStr255ToString(help.content[kHMMaximumContentIndex].tagString);
    end;


  with gTooltip.hotRect do
    begin

      CalculateWidthAndHeightOfTooltipWindow(commandState,largeurNecessaire,hauteurNecessaire);

      milieu := (left + right) div 2;

      if help.tagSide = kHMOutsideRightCenterAligned
        then  { sur la droite }
          contentRect := MakeRect(right + 1 ,
                                  (top + bottom - 14) div 2 + 2,
                                  right + 5 + largeurNecessaire + 3,
                                  (top + bottom - 14) div 2 + 2 + hauteurNecessaire)
        else  { default = en dessous }
          contentRect := MakeRect(milieu - 2 - largeurNecessaire div 2,
                                  bottom + 3,
                                  milieu + 2 + largeurNecessaire div 2,
                                  bottom + 3 + hauteurNecessaire);
    end;

  attributes := kWindowHideOnFullScreenAttribute +
                kWindowHideOnSuspendAttribute +
                kWindowIgnoreClicksAttribute +
                kWindowDoesNotCycleAttribute +
                kWindowNoActivatesAttribute;

  if useSmoothTransitions and (gTooltip.tooltipWindow <> NIL)
    then
      begin
        { on peut essayer de bouger la fenetre existante }
        err := TransitionWindow(gTooltip.tooltipWindow, kWindowSlideTransitionEffect, kWindowResizeTransitionAction, @contentRect);
      end
    else
      begin
        { il faut faire une nouvelle fenetre }

        // on ferme la precedente, à tout hasard
        CloseTooltipWindowInCloud;

        // on remet les infos qui ont été effacés par l'appel à CloseTooltipWindowInCloud
        with gTooltip do
          begin
            affiche              := false;
            command              := commandState;
            forWindow            := forWhichWindow;
            hotRect              := help.absHotRect;
            dateDernierAffichage := 0;
            numeroDuPoint        := 0;
            string1              := MyStr255ToString(help.content[kHMMinimumContentIndex].tagString);
            string2              := MyStr255ToString(help.content[kHMMaximumContentIndex].tagString);
          end;

        // on cree la nouvelle fenetre
        err := CreateNewWindow(kHelpWindowClass,attributes,contentRect,gTooltip.tooltipWindow);


        // on affiche le nouveau contenu
       if (err = NoErr) and (gTooltip.tooltipWindow <> NIL) then
          ShowTooltipWindowInCloud;
      end;

  MyHMSetWindowHelpContent := err;
end;



const TexteRegressionID = 10024;



function FabriqueTexteDeuxiemeLigneDuTooltip(scoreAxeVertical, scoreAxeHorizontal : SInt32) : String255;
var s, s0, myString, score : String255;
    scoreFinal : SInt32;
begin

  s := '';

  case gCloud.typeDeRegression of

    k_REGRESSION_QUALITE_EDMOND :
      begin
        if (scoreAxeVertical >= 32)
          then score := '+'+NumEnString(2*(scoreAxeVertical-32))
          else score := '-'+NumEnString(2*(32-scoreAxeVertical));

        s0 := ReadStringFromRessource(TexteRegressionID,1);   {score théorique ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

        if (scoreAxeHorizontal >= 0)
          then score := '+'+NumEnString(scoreAxeHorizontal div 100)+'.'+NumEnString(scoreAxeHorizontal mod 100)
          else score := '-'+NumEnString((-scoreAxeHorizontal) div 100)+'.'+NumEnString((-scoreAxeHorizontal) mod 100);

        s0 := ReadStringFromRessource(TexteRegressionID,2);  {, estimé à ^0 par Edmond}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;
      end;

    k_REGRESSION_QUALITE_CASSIO :
      begin
        if (scoreAxeVertical >= 32)
          then score := '+'+NumEnString(2*(scoreAxeVertical-32))
          else score := '-'+NumEnString(2*(32-scoreAxeVertical));

          s0 := ReadStringFromRessource(TexteRegressionID,1);  {score théorique ^0}
          myString := ParamStr(s0, score, '', '', '');
          s := s + myString;

        if (scoreAxeHorizontal >= 0)
          then score := '+'+NumEnString(scoreAxeHorizontal div 100)+'.'+NumEnString(scoreAxeHorizontal mod 100)
          else score := '-'+NumEnString((-scoreAxeHorizontal) div 100)+'.'+NumEnString((-scoreAxeHorizontal) mod 100);

          s0 := ReadStringFromRessource(TexteRegressionID,3);  {, estimé à ^0 par Cassio}
          myString := ParamStr(s0, score, '', '', '');
          s := s + myString;
      end;

    k_REGRESSION_QUALITE_CASSIO_ANTIQUE :
      begin
        if (scoreAxeVertical >= 32)
          then score := '+'+NumEnString(2*(scoreAxeVertical-32))
          else score := '-'+NumEnString(2*(32-scoreAxeVertical));

        s0 := ReadStringFromRessource(TexteRegressionID,1);  {score théorique ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

        if (scoreAxeHorizontal >= 0)
          then score := '+'+NumEnString(scoreAxeHorizontal div 100)+'.'+NumEnString(scoreAxeHorizontal mod 100)
          else score := '-'+NumEnString((-scoreAxeHorizontal) div 100)+'.'+NumEnString((-scoreAxeHorizontal) mod 100);

        s0 := ReadStringFromRessource(TexteRegressionID,4);  {, estimé à ^0 par le vieux Cassio}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;
      end;

    k_REGRESSION_SCORE_FINAL :
      begin
        score := NumEnString(scoreAxeVertical) + '-' +NumEnString(64-scoreAxeVertical);

        if (scoreAxeHorizontal >= -99)
          then scoreFinal :=  2*((scoreAxeHorizontal + 100) div 200)
          else scoreFinal := -2*((-scoreAxeHorizontal + 100) div 200);

        s0 := ReadStringFromRessource(TexteRegressionID,5);   {score théorique = ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

        score := NumEnString(32 + (scoreFinal div 2)) + '-' + NumEnString(32 - (scoreFinal div 2));

        s0 := ReadStringFromRessource(TexteRegressionID,6);   {, score final = ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

      end;

    k_REGRESSION_SCORE_FIN_OUVERTURE :
      begin

        if (scoreAxeHorizontal >= 0)
          then score := '+'+NumEnString(scoreAxeHorizontal div 100)+'.'+NumEnString(scoreAxeHorizontal mod 100)
          else score := '-'+NumEnString((-scoreAxeHorizontal) div 100)+'.'+NumEnString((-scoreAxeHorizontal) mod 100);

        s0 := ReadStringFromRessource(TexteRegressionID,7);   {score ouverture = ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

        if (scoreAxeVertical >= 32)
          then score := '+'+NumEnString(2*(scoreAxeVertical-32))
          else score := '-'+NumEnString(2*(32-scoreAxeVertical));

        s0 := ReadStringFromRessource(TexteRegressionID,6);   {, score final = ^0}
        myString := ParamStr(s0, score, '', '', '');
        s := s + myString;

      end;

  end; {case}

  FabriqueTexteDeuxiemeLigneDuTooltip := s;
end;



procedure CreateTooltipWindowInCloud(numeroDuPoint : SInt32; commandState : boolean);
var status : OSErr;
    helpTag : HMHelpContentRec;
    s : String255;
    nroRef : SInt32;
    theRect : Rect;
    oldport : grafPtr;
    s1, s2 : String255;
    scoreNoir, scoreBlanc : SInt32;
    scoreTheorique,scoreHeuristique : SInt32;
    message1, message2 : Str255;
begin

  with gCloud do
    begin

      if (numeroDuPoint <= 0) or (numeroDuPoint > cardinal) or (data = NIl)
        then exit(CreateTooltipWindowInCloud);

      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      with data^[numeroDuPoint] do
        begin
          nroRef := numeroReference;

          if HashPartieDansListeParNroRefPartie(nroRef) = hashStamp then
            begin

              helpTag.version := kMacHelpVersion;
              helpTag.tagSide := kHMOutsideBottomCenterAligned;
              //helpTag.tagSide := kHMOutsideRightCenterAligned;


              SetRect(theRect,x - 3, y - 3, x + 3, y + 3);

              GetScoreTheoriqueThisPointOnScreen(x,y,scoreTheorique);

              scoreHeuristique := eval;

              //ForeColor(GreenColor);
              //FrameRect(theRect);

              LocalToGlobalRect(theRect);

              helpTag.absHotRect := theRect;




              s1 := GetNomJoueurNoirSansPrenomParNroRefPartie(nroRef);
              s2 := GetNomJoueurBlancSansPrenomParNroRefPartie(nroRef);

              scoreNoir := GetScoreReelParNroRefPartie(nroRef);
              scoreBlanc := 64 - scoreNoir;
              s := s1 + Concat(' ',NumEnString(scoreNoir),'-',NumEnString(scoreBlanc),' ') + s2;

              message1 := StringToStr255(s);


              helpTag.content[kHMMinimumContentIndex].contentType   := kHMPascalStrContent;
              helpTag.content[kHMMinimumContentIndex].tagString     := message1;
              //helpTag.content[kHMMinimumContentIndex].tagString     := StringToStr255(s);


              s := s + ' ('+GetNomCourtTournoiAvecAnneeParNroRefPartie(nroRef,30)+')' + chr(13);

              s := s + FabriqueTexteDeuxiemeLigneDuTooltip(scoreTheorique, scoreHeuristique);

              message2 := StringToStr255(s);

              helpTag.content[kHMMaximumContentIndex].contentType   := kHMPascalStrContent;
              helpTag.content[kHMMaximumContentIndex].tagString     := message2;
              //helpTag.content[kHMMaximumContentIndex].tagString     := StringToStr255(s);


              // status :=  HMSetWindowHelpContent(wNuagePtr, @helpTag);
              status := MyHMSetWindowHelpContent(wNuagePtr,helpTag,commandState);


              if (status = NoErr) then gTooltip.numeroDuPoint := numeroDuPoint;


              //status := HMSetTagDelay(0);

              // WritelnNumDansRapport('status = ',status);
            end;
        end;

      SetPort(oldPort);

    end;

end;










procedure LanceDemandeDeVisiteDeLaPartieDeCePointDuNuage(numeroDuPoint : SInt32);
begin
  with gDemandeDeVisiteDePartiesDuNuage do
    begin
      nbDemandes := 1;
      numeroPoint := numeroDuPoint;
    end;
end;


procedure TraiterDemandesDeVisiteDesPartiesDuNuage;
begin
  with gDemandeDeVisiteDePartiesDuNuage do
    if (nbDemandes > 0) and  not(CassioEstEnTrainDeTracerLeNuage) and CassioCanCheckForDangerousEvents
      then
        begin
          nbDemandes := 0;
          OuvrirPartieDeLaListeCorrespondantACePoint(numeroPoint);
        end;
end;



function TraiteCurseurSeBalladantSurLaFenetreDuNuage(mouseLocGlobal : Point) : boolean;
var oldport : grafPtr;
    numeroDuPoint : SInt32;
    mouseLoc : Point;
    err : OSStatus;
    trouve : boolean;
    laToucheCommandeSembleChangee : boolean;
begin  {$unused mouseLocGlobal,err}

  if (gCloud.cardinal > 0) then
    begin

      laToucheCommandeSembleChangee := DernierEvenement.command <> gTooltip.command;

      if not(gCloud.tooltipsSuiventSouris)
        then
          begin

            { on suit les changements d'etats de la touche commande }

            if CassioCanCheckForDangerousEvents and laToucheCommandeSembleChangee then
              begin

                CreateTooltipWindowInCloud(gTooltip.numeroDuPoint, DernierEvenement.command);

                DiminueLatenceEntreDeuxDoSystemTask;
                AccelereProchainDoSystemTask(1);
              end;

          end
        else
          begin

            { il faut suivre la souris pour afficher eventuellement les tooltips }

            GetPort(oldport);
            SetPortByWindow(wNuagePtr);

            GetMouse(mouseLoc);


            if gCloud.estTrie
              then trouve := PtInRect(mouseLoc,MakeRect(gGrid.min_x,gGrid.min_y,gGrid.max_x,gGrid.max_y)) and
                             TrouverNouveauPointPlusProcheParAlgoEnSpirale(mouseLoc,numeroDuPoint)
              else


              trouve := TrouverNouveauPointProcheDeLaSourisDansCloud(mouseLoc,numeroDuPoint);


            if trouve then
              begin

                if CassioCanCheckForDangerousEvents then
                  begin
                    if DernierEvenement.command and
                       not(CassioEstEnTrainDeTracerLeNuage) and
                       not(analyseRetrograde.enCours) and
                       (HumCtreHum or CassioEstEnModeAnalyse) then
                      LanceDemandeDeVisiteDeLaPartieDeCePointDuNuage(numeroDuPoint);

                    if CassioCanCheckForDangerousEvents and
                       ((gTooltip.numeroDuPoint <> numeroDuPoint) or laToucheCommandeSembleChangee)  then
                      begin
                        // creation du nouveau tooltip
                        CreateTooltipWindowInCloud(numeroDuPoint, DernierEvenement.command);
                      end;
                  end;

                DiminueLatenceEntreDeuxDoSystemTask;
                AccelereProchainDoSystemTask(1);

              end;

            SetPort(oldPort);
          end;
    end;




  // ajustons le curseur

  if gCloud.tooltipsSuiventSouris and (gCloud.cardinal > 0) and
     (mouseLoc.h >= gGrid.min_x) and (mouseLoc.h <= gGrid.max_x) and
     (mouseLoc.v >= gGrid.min_y) and (mouseLoc.v <= gGrid.max_y)
    then
      SafeSetCursor(GetCursor(DigitCurseurID))
    else
      InitCursor;

  TraiteCurseurSeBalladantSurLaFenetreDuNuage := true;



end;





procedure LoadMenuFlottantNuage;
var item : SInt32;
begin

  case gCloud.typeDeRegression of
     k_REGRESSION_QUALITE_EDMOND          : item := 1;
     k_REGRESSION_QUALITE_CASSIO          : item := 2;
     k_REGRESSION_QUALITE_CASSIO_ANTIQUE  : item := 3;
     k_REGRESSION_EDAX                    : item := 4;
     k_REGRESSION_SCORE_FINAL             : item := 6;
     k_REGRESSION_SCORE_FIN_OUVERTURE     : item := 7;
  end; {case}

  menuFlottantNuage := NewMenuFlottant(menuFlottantNuageID,menuFlottantRect,item);

  SetFontMenuFlottant(menuFlottantNuage,0,9);

  InstalleMenuFlottant(menuFlottantNuage,wNuagePtr);

  menuFlottantRect := menuFlottantNuage.theRect;

  RGBBackColor(couleurFondFenetreNuage);

  DrawPUItemMenuFlottant(menuFlottantNuage, true);

end;


procedure DrawMenuFlottantNuage;
begin
  LoadMenuFlottantNuage;
  DesinstalleMenuFlottant(menuFlottantNuage);
end;


procedure GererClicMenuFlottantNuage;
var nouveauTypeRegression : SInt32;
    typeDeRegressionChange : boolean;
begin
  LoadMenuFlottantNuage;

  nouveauTypeRegression := gCloud.typeDeRegression;

  if EventPopUpItemMenuFlottant(menuFlottantNuage,true,true,true) then
    begin
      case menuFlottantNuage.theItem of
        1 : nouveauTypeRegression := k_REGRESSION_QUALITE_EDMOND;
        2 : nouveauTypeRegression := k_REGRESSION_QUALITE_CASSIO;
        3 : nouveauTypeRegression := k_REGRESSION_QUALITE_CASSIO_ANTIQUE;
        4 : nouveauTypeRegression := k_REGRESSION_EDAX;
        5 : DoNothing;
        6 : nouveauTypeRegression := k_REGRESSION_SCORE_FINAL;
        7 : nouveauTypeRegression := k_REGRESSION_SCORE_FIN_OUVERTURE;
      end;

      typeDeRegressionChange := (gCloud.typeDeRegression <> nouveauTypeRegression);

      gCloud.typeDeRegression := nouveauTypeRegression;

      if (nouveauTypeRegression = k_REGRESSION_EDAX)
        then
          begin
            CloseTooltipWindowInCloud;
            LireFichierCSVEvalEdaxCorrelations;
            DoTracerNuage;
          end
        else
          begin
            if (nbPartiesChargees <= 0) and not(enRetour or enSetUp)
              then DoChargerLaBaseSansInterventionUtilisateur;
            if (nbPartiesChargees > 0) and (typeDeRegressionChange or (gCloud.cardinal <> nbPartiesActives))
              then DoTracerNuage;
          end;
    end;

  DesinstalleMenuFlottant(menuFlottantNuage);
end;

procedure TraiteSourisNuage(whichEvent : eventRecord);
var clicLoc : Point;
    oldPort : grafPtr;

begin
  GetPort(oldPort);
  SetPortByWindow(wNuagePtr);

  clicLoc := whichEvent.where;
  GlobalToLocal(clicLoc);

  if PtInRect(clicLoc,menuFlottantRect)
    then GererClicMenuFlottantNuage
    else ToggleTooltipWindowsInCloudSuiventLeCurseur;

  SetPort(oldPort);
end;


procedure EcrireCloudDansRapport;
var n,i : SInt32;
    grid_x,grid_y : SInt32;
    myRect : Rect;
    oldPort : grafPtr;
begin
  with gCloud do
    if (cardinal > 0) and (data <> NIL) then
      begin
        n := Min(Min(100000, cardinal),capaciteMaximale);

        for i := 1 to n do
          with data^[i] do
            begin

              if not(GetGridSquareOfPoint(x,y, grid_x,grid_y)) then
                begin
                  WritelnDansRapport('ERROR !!');
                  myRect := MakeRect(x-3, y-3, x+3, y+3);
                  GetPort(oldport);
                  SetPortByWindow(wNuagePtr);

                  ForeColor(magentaColor);
                  FrameRect(myRect);

                  SetPort(oldPort);
                end;

              myRect := GetBoundingRectOfGridSquare(grid_x,grid_y);

              (*
              with myRect do
                begin
                  WriteNumDansRapport('myRect = {left = ',left);
                  WriteNumDansRapport(',top = ',top);
                  WriteNumDansRapport(',right = ',right);
                  WriteNumDansRapport(',bottom = ',bottom);
                  WritelnDansRapport('}');
                end;
              *)

              GetPort(oldport);
              SetPortByWindow(wNuagePtr);

              ForeColor(blueColor);
              InSetRect(myRect, -1, -1);
              FrameRect(myRect);

              SetPort(oldPort);

              (*
              WriteNumDansRapport('['+NumEnString(i)+'] = {x = ',x);
              WriteNumDansRapport(',y = ',y);
              WriteNumDansRapport(',h = ',hashStamp);
              WriteNumDansRapport(',r = ',numeroReference);
              WriteNumDansRapport(',i = ',grid_x);
              WriteNumDansRapport(',j = ',grid_y);
              WritelnDansRapport('}');
              *)
            end;
      end;
end;


procedure EcrireReferencesDeCePointDansRapport(numeroDuPoint : SInt32);
var s : String255;
    nroRef : SInt32;
begin
  with gCloud do
    begin
      if (numeroDuPoint <= 0) or (numeroDuPoint >= cardinal) or (data = NIL) then
        exit(EcrireReferencesDeCePointDansRapport);

      with data^[numeroDuPoint] do
        begin
          nroRef := numeroReference;

          if HashPartieDansListeParNroRefPartie(nroRef) = hashStamp then
            begin
              s := ConstruireChaineReferencesPartieParNroRefPartie(nroRef,true,-1);
              WritelnDansRapport(s);
            end;
        end;
    end;
end;


procedure OuvrirPartieDeLaListeCorrespondantACePoint(numeroDuPoint : SInt32);
var s : String255;
    nroRef : SInt32;
    partieEnAlpha : String255;
    partieDansLaListe : String255;
    partieCourante : String255;
    s60 : PackedThorGame;
    erreur : SInt32;
    positionDeLaListe : PositionEtTraitRec;
    gameNodeLePlusProfond : GameTree;
    oldCheckDangerousEvents : boolean;
begin
  with gCloud do
    begin
      if (numeroDuPoint <= 0) or (numeroDuPoint > cardinal) or (cardinal <= 0) or (data = NIL)  then
        exit(OuvrirPartieDeLaListeCorrespondantACePoint);

      with data^[numeroDuPoint] do
        begin
          nroRef := numeroReference;

          if HashPartieDansListeParNroRefPartie(nroRef) = hashStamp then
            begin
              s := ConstruireChaineReferencesPartieParNroRefPartie(nroRef,true,-1);
              // WritelnDansRapport(s);

              ExtraitPartieTableStockageParties(nroRef,s60);

              TraductionThorEnAlphanumerique(s60, partieEnAlpha);

              positionDeLaListe := PositionEtTraitAfterMoveNumberAlpha(partieEnAlpha,kNumeroCoupCalculScoreTheoriqueDansWThor,erreur);


              partieDansLaListe := LeftOfString(partieEnAlpha,kNumeroCoupCalculScoreTheoriqueDansWThor*2);
              partieCourante    := PartiePourPressePapier(true,false,nbreCoup);

              if not(EstLaPositionCourante(positionDeLaListe)) and
                 not((nbreCoup > 0) and (IsPrefix(partieDansLaListe,partieCourante) or IsPrefix(partieCourante,partieDansLaListe)))  then
                begin

                  //BeginFonctionModifiantNbreCoup('OuvrirPartieDeLaListeCorrespondantACePoint');
                  SetCassioMustCheckDangerousEvents(false,@oldCheckDangerousEvents);

                  // Aller jusqu'au coup 36
                  PlaquerPartieLegale(LeftOfString(partieEnAlpha,kNumeroCoupCalculScoreTheoriqueDansWThor*2),kNePasRejouerLesCoupsEnDirect);

                   if not(EstLaPositionCourante(positionDeLaListe)) then
                     begin

                        if (erreur = kPartieTropCourte) and EstLaPositionInitialeStandard(positionDeLaListe) and
                           ((LENGTH_OF_STRING(partieEnAlpha) div 2) < kNumeroCoupCalculScoreTheoriqueDansWThor) and (AQuiDeJouer = pionVide)
                         then
                           positionDeLaListe := PositionEtTraitCourant
                         else
                           begin
                             WritelnDansRapport('ASSERT : not(EstLaPositionCourante(positionDeLaListe)) dans OuvrirPartieDeLaListeCorrespondantACePoint');

                             WritelnDansRapport('JeuCourant = ');
                             WritelnPositionEtTraitDansRapport(JeuCourant,AQuiDeJouer);


                             WritelnDansRapport('positionDeLaListe = ');
                             WritelnPositionEtTraitDansRapport(positionDeLaListe.position,GetTraitOfPosition(positionDeLaListe));

                             WritelnNumDansRapport('erreur = ',erreur);
                             WritelnDansRapport('partieEnAlpha = '+partieEnAlpha);
                           end;


                     end;

                  // mettre en memoire les coups 37-60
                  if (nbreCoup < (LENGTH_OF_STRING(partieEnAlpha) div 2)) then
                    MiseAJourDeLaPartie(partieEnAlpha,JeuCourant,emplJouable,frontiereCourante,
                                        nbreDePions[pionBlanc],nbreDePions[pionNoir],
                                        AQuiDeJouer,nbreCoup,false, (LENGTH_OF_STRING(partieEnAlpha) div 2),
                                        gameNodeLePlusProfond,'OuvrirPartieDeLaListeCorrespondantACePoint');

                  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
                  //EndFonctionModifiantNbreCoup('OuvrirPartieDeLaListeCorrespondantACePoint');
                end;
            end;
        end;
    end;
end;


procedure InitialiseModeleLineaireValeursPotables;
var i : SInt32;
begin
  for i := 0 to 64 do
    begin
      moyenneDesValeursPourCeScore[i] := kModeleNonAjustePourCeScore;
      medianeDesValeursPourCeScore[i] := kModeleNonAjustePourCeScore;
    end;
  moyenneDesValeursPourCeScore[14] := -5700;
  moyenneDesValeursPourCeScore[32] := 0;
  moyenneDesValeursPourCeScore[50] := 4816;
  medianeDesValeursPourCeScore[14] := -5392;
  medianeDesValeursPourCeScore[32] := 0;
  medianeDesValeursPourCeScore[50] := 4816;
end;



procedure PlotRepereRegression;
var oldport : grafPtr;
    a,b,haut,larg,c : SInt32;
    s : String255;
    i : SInt16;
    x_centre, y_centre : SInt32;
    myRect : Rect;
    largeurChaineLaPlusLarge : SInt32;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      larg := QDGetPortBound.right div 2;
      haut := QDGetPortBound.bottom div 2;

      GetCentreRepereRegression(x_centre,y_centre);

      couleurDesTraitsGris := EclaircirCouleurDeCetteQuantite(gPurGrisClair,5000);
      ForeColor(BlackColor);

      SetRect(myRect,0,0,2*larg,y_centre + 32*kIntervalleEntreDeuxLignesDuNuage + 14);
      menuFlottantRect := MakeRect(2*larg - 270, myRect.bottom+10, 2*larg, myRect.bottom + 30);

      RGBBackColor(gPurBlanc);
      MyEraseRect(myRect);
      MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');


      SetRect(myRect, larg + ((-7000*larg) div kMaxValeurDessineeDansNuage),
                      y_centre - 32*kIntervalleEntreDeuxLignesDuNuage,
                      larg + ((7000*larg) div kMaxValeurDessineeDansNuage),
                      y_centre + 32*kIntervalleEntreDeuxLignesDuNuage);


      couleurFondFenetreNuage := EclaircirCouleurDeCetteQuantite(gPurGrisClair,7500);

      RGBBackColor(couleurFondFenetreNuage);
      MyEraseRect(QDGetPortBound);
      MyEraseRectWithColor(QDGetPortBound,OrangeCmd,blackPattern,'');

      RGBBackColor(gPurBlanc);
      MyEraseRect(myRect);
      MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');

      for i := -7 to 7 do
        begin
          s := NumEnString(i*10)+'.0';

          a := larg + (((i*1000)*larg) div kMaxValeurDessineeDansNuage);
          b := y_centre + 32*kIntervalleEntreDeuxLignesDuNuage;


          Moveto(a,b-2);
          Line(0,5);

          // traits de reperages verticaux sur le nuage
          RGBForeColor(couleurDesTraitsGris);
          Moveto(a,b-kIntervalleEntreDeuxLignesDuNuage);
          Lineto(a,y_centre - 32*kIntervalleEntreDeuxLignesDuNuage);
          RGBForeColor(gPurNoir);

          // echelle horizontale sous le nuage
          Moveto(a-(MyStringWidth(s) div 2),b+12);
          MyDrawString(s);

          // echelle horizontale au dessus du nuage
          a := larg + ((i*1000*larg) div kMaxValeurDessineeDansNuage);
          b := y_centre - 32*kIntervalleEntreDeuxLignesDuNuage;
          Moveto(a,b-2);
          Line(0,5);
          Moveto(a-(MyStringWidth(s) div 2),Max(9, (b-4)));
          MyDrawString(s);
        end;

      PlotRepereCourbesDistribution;

      for i := 2 to 62 do
        if not(odd(i)) then
        begin

          if ((i mod 4) = 0)
            then s := ScoreEnChaineInformative(i)
            else s := '';

          largeurChaineLaPlusLarge := MyStringWidth('+32 (48-16)');

          b := y_centre + (32-i)*kIntervalleEntreDeuxLignesDuNuage;

          a := larg + ((-7000*larg) div kMaxValeurDessineeDansNuage);
          c := larg + ((7000*larg) div kMaxValeurDessineeDansNuage);

          // traits de reperages horizontaux sur le nuage
          RGBForeColor(couleurDesTraitsGris);
          Moveto(a,b);
          Lineto(c,b);
          RGBForeColor(gPurNoir);

          // echelle verticale sur le nuage, à gauche
          Moveto(3 + largeurChaineLaPlusLarge - MyStringWidth(s) ,b + 4);
          MyDrawString(s);

          // echelle verticale sur le nuage, à droite
          Moveto(2*larg - largeurChaineLaPlusLarge - 3,b + 4);
          MyDrawString(s);

          // echelle verticale sur le nuage, au centre
          RGBForeColor(gPurGris);
          s := LeftOfString(s,3);
          Moveto(x_centre + 2,b + 4 );
          MyDrawString(s);
          RGBForeColor(gPurNoir);

        end;

      {axe horizontal en bas}
      Moveto(0,y_centre + 32*kIntervalleEntreDeuxLignesDuNuage);
      Lineto(larg*2,y_centre + 32*kIntervalleEntreDeuxLignesDuNuage);

      {axe horizontal en haut}
      Moveto(0,y_centre-32*kIntervalleEntreDeuxLignesDuNuage);
      Lineto(larg*2,y_centre-32*kIntervalleEntreDeuxLignesDuNuage);

      {axe vertical au milieu}
      Moveto(larg,y_centre-32*kIntervalleEntreDeuxLignesDuNuage);
      Lineto(larg,y_centre+32*kIntervalleEntreDeuxLignesDuNuage);

      (*
      {axe vertical a gauche}
      Moveto(0,y_centre-32*kIntervalleEntreDeuxLignesDuNuage);
      Lineto(0,y_centre+32*kIntervalleEntreDeuxLignesDuNuage);

      {axe vertical a droite}
      Moveto(2*larg,y_centre-32*kIntervalleEntreDeuxLignesDuNuage);
      Lineto(2*larg,y_centre+32*kIntervalleEntreDeuxLignesDuNuage);
      *)

      DrawMenuFlottantNuage;

      SetPort(oldport);
    end;
end;


procedure PlotRepereCourbesDistribution;
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    s : String255;
    i : SInt16;
    x_centre, y_centre : SInt32;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      larg := QDGetPortBound.right div 2;
      haut := QDGetPortBound.bottom div 2;

      GetCentreRepereRegression(x_centre,y_centre);


      for i := -7 to 7 do
        begin
          s := NumEnString(i*10)+'.0';

          a := larg + (((i*1000)*larg) div kMaxValeurDessineeDansNuage);
          b := y_centre + 32*kIntervalleEntreDeuxLignesDuNuage;

          // traits de reperage verticaux sur les courbes
          RGBForeColor(NoircirCouleurDeCetteQuantite(couleurDesTraitsGris,1000));
          Moveto(a,b+17);
          Lineto(a,QDGetPortBound.bottom);
          RGBForeColor(gPurNoir);

        end;

      DrawMenuFlottantNuage;

      SetPort(oldport);
    end;
end;


procedure PlotPointRegression(scoreTheorique,valeur,nroReferencePartie : SInt32);
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    x_centre,y_centre : SInt32;
    perturbation : SInt32;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      inc(gNbPointsRegressionTraces);

      larg := QDGetPortBound.right div 2;
      haut := QDGetPortBound.bottom div 2;

      GetCentreRepereRegression(x_centre,y_centre);

      a := larg + ((valeur*larg) div kMaxValeurDessineeDansNuage);

      perturbation := Random16();

      if (perturbation >= 0)
        then b := y_centre - (scoreTheorique - 32)*kIntervalleEntreDeuxLignesDuNuage + (perturbation mod (1 + kDemiIntervalleEntreDeuxLignesDuNuage))
        else b := y_centre - (scoreTheorique - 32)*kIntervalleEntreDeuxLignesDuNuage - ((-perturbation) mod (1 + kDemiIntervalleEntreDeuxLignesDuNuage));


      if (scoreTheorique >= 32) or true
        then RGBForeColor(GetCouleurAffichageValeurZebraBook(pionBlanc, abs(200*(scoreTheorique - 32) - valeur)))
        else RGBForeColor(GetCouleurAffichageValeurZebraBook(pionNoir,  abs(200*(scoreTheorique - 32) - valeur)));

      {
      Moveto(a-1,b-1);
      Lineto(a+1,b+1);
      Moveto(a-1,b+1);
      Lineto(a+1,b-1);
      }
      Moveto(a,b);
      Line(0,0);
      AjouterPointDansCloud(a,b,valeur,nroReferencePartie);

      SetPort(oldport);

      if ((gNbPointsRegressionTraces mod 128) = 0) and
         (TickCount-dernierTick >= 2) then DoSystemTask(AQuiDeJouer);

    end;
end;

procedure DessineCarreBlancCeScoreTheorique(scoreTheorique,valeur : SInt32);
var oldport : grafPtr;
    a,b,haut,larg : SInt32;
    myRect : rect;
    x_centre,y_centre : SInt32;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      larg := QDGetPortBound.right div 2;
      haut := QDGetPortBound.bottom div 2;

      GetCentreRepereRegression(x_centre,y_centre);

      a := larg + ((valeur*larg) div kMaxValeurDessineeDansNuage);
      b := y_centre - (scoreTheorique -32)*kIntervalleEntreDeuxLignesDuNuage;


      ForeColor(BlackColor);

      SetRect(myRect,a-3,b-3,a+3,b+3);
      MyEraseRect(myRect);
      MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');
      FillRect(myrect,whitePattern);

      ForeColor(RedColor);
      FrameRect(myrect);

      SetPort(oldport);
    end;
end;


procedure EffaceCourbesDistribution;
var oldport : grafPtr;
    haut,larg,basCourbe : SInt32;
    x_centre,y_centre : SInt32;
    myRect : Rect;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      inc(gNbCourbesDistributionTracees);

      larg := QDGetPortBound.right div 2;
      haut := QDGetPortBound.bottom div 2;
      basCourbe := QDGetPortBound.bottom-2;

      GetCentreRepereRegression(x_centre,y_centre);

      SetRect(myRect,0,y_centre+32*kIntervalleEntreDeuxLignesDuNuage+12,2*larg,basCourbe);
      FillRect(myRect,whitePattern);

      DrawMenuFlottantNuage;

      SetPort(oldport);
    end;
end;


procedure ChangeForeColorForDrawingThisCurve(quelScoreTheorique : SInt32);
begin
  if (quelScoreTheorique = 28) then ForeColor(blueColor) else
  if (quelScoreTheorique = 36) then ForeColor(MagentaColor) else
  if odd(quelScoreTheorique div 8)
    then RGBForeColor(GetCouleurAffichageValeurZebraBook(pionBlanc, abs(100*(quelScoreTheorique-32)) div 4 - 300))
    else RGBForeColor(GetCouleurAffichageValeurZebraBook(pionNoir,  abs(100*(quelScoreTheorique-32)) div 4 - 300));
end;


procedure LisserTableDistribution(source : TableDistributionReelePtr; result : TableDistributionReelePtr; typeLissage : SInt32);
var j : SInt32;
    aux : double;
begin

  // copier la table
  for j := minValMediane to maxValMediane do
    result^[j] := source^[j];


  if (typeLissage <> k_PAS_DE_LISSAGE) then
    begin

      // lisser les valeurs interieures
      for j := minValMediane+4 to maxValMediane-4 do
        begin


          case typeLissage of

            k_PAS_DE_LISSAGE :
              aux := source^[j];

            k_LISSAGE_MOYENNE :
              begin
                aux := (source^[j-4]+
                        source^[j-3]+
                        source^[j-2]+
                        source^[j-1]+
                        source^[j]+
                        source^[j+1]+
                        source^[j+2]+
                        source^[j+3]+
                        source^[j+4])/9.0;
              end;


            k_LISSAGE_SAVITZKY_GOLAY_4_4 :
              begin

                { cf  http://pagesperso-orange.fr/robert.mellet/regrs/regrs_08.htm
                  et  Numerical Recipes in C, pp. 650-651 }

                aux :=  ( 15 * source^[j-4]
                         -55 * source^[j-3] +
                          30 * source^[j-2] +
                         135 * source^[j-1] +
                         179 * source^[j]   +
                         135 * source^[j+1] +
                          30 * source^[j+2]
                         -55 * source^[j+3] +
                          15 * source^[j+4])/429.0;

                (*  essai personnel
                aux :=  ( 15 * source^[j-4] +
                          15 * source^[j-3] +
                          30 * source^[j-2] +
                         135 * source^[j-1] +
                         179 * source^[j]   +
                         135 * source^[j+1] +
                          30 * source^[j+2] +
                          15 * source^[j+3] +
                          15 * source^[j+4])/569.0;
                *)

                (*
                aux :=  (  0.035 * source^[j-4] +
                          -0.128 * source^[j-3] +
                           0.070 * source^[j-2] +
                           0.315 * source^[j-1] +
                           0.417 * source^[j]   +
                           0.315 * source^[j+1] +
                           0.070 * source^[j+2] +
                          -0.128 * source^[j+3] +
                           0.035 * source^[j+4] );
                *)

              end;
          end; {case}

          result^[j] := aux;
        end;

    end;
end;

procedure DessineCourbeDistribution(quelScoreTheorique : SInt16; var c : TableDistributionPtr; typeLissage : SInt32);
const kNbCourbesATracer = 11;
var oldport : grafPtr;
    a,b,placePourLaCourbe,larg,basCourbe,j : SInt32;
    {old_a,old_b : SInt32;}
    x_centre,y_centre : SInt32;
    courbeRect : rect;
    s : String255;
    tableEcran : TableDistributionReelePtr;
    tableEcranLissee : TableDistributionReelePtr;
    facteurVertical : double;
    aux : double;
begin {$unused typeLissage}
  if (wNuagePtr <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wNuagePtr);

      inc(gNbCourbesDistributionTracees);

      larg := QDGetPortBound.right div 2;

      basCourbe := QDGetPortBound.bottom-2;

      GetCentreRepereRegression(x_centre,y_centre);

      SetRect(courbeRect,0,y_centre+32*kIntervalleEntreDeuxLignesDuNuage+12,2*larg,basCourbe);
      {FillRect(courbeRect,whitePattern);}

      ChangeForeColorForDrawingThisCurve(quelScoreTheorique);

      // dessin de la legende
      s := ScoreEnChaineInformative(quelScoreTheorique);
      aux := 1.0*(basCourbe - courbeRect.top)/kNbCourbesATracer;
      if aux > 25.0 then aux := 25.0;
      b := basCourbe - MyTrunc((gNbCourbesDistributionTracees - 1.5) * aux);
      Moveto(2,b);
      MyDrawString(s);
      Moveto(60,b-3);
      Lineto(80,b-3);

      tableEcran := TableDistributionReelePtr(AllocateMemoryPtr(sizeof(TableDistributionReele)));
      tableEcranLissee := TableDistributionReelePtr(AllocateMemoryPtr(sizeof(TableDistributionReele)));

      for j := minValMediane to maxValMediane do tableEcran^[j] := 0.0;
      for j := minValMediane to maxValMediane do
        begin
          a := MyTrunc(((1.0*j*larg) / kMaxValeurDessineeDansNuage));
          if a < minValMediane then a := minValMediane;
          if a > maxValMediane then a := maxValMediane;
          tableEcran^[a] := tableEcran^[a] + c^[j];
        end;


      if (quelScoreTheorique = -64) or (quelScoreTheorique = 64)
        then
          LisserTableDistribution(tableEcran,tableEcranLissee,k_LISSAGE_MOYENNE)
        else
          begin
            LisserTableDistribution(tableEcran,tableEcranLissee,k_LISSAGE_MOYENNE);

            //LisserTableDistribution(tableEcranLissee,tableEcran,k_PAS_DE_LISSAGE);  // juste une copie
           // LisserTableDistribution(tableEcran,tableEcranLissee,k_LISSAGE_SAVITZKY_GOLAY_4_4);

            //LisserTableDistribution(tableEcranLissee,tableEcran,k_PAS_DE_LISSAGE);  // juste une copie
            //LisserTableDistribution(tableEcran,tableEcranLissee,k_LISSAGE_MOYENNE);

            (*
            if (typeLissage <> k_LISSAGE_MOYENNE) then  {on fait du double lissage}
              begin
                {un petit dernier lissage pour la route}
                LisserTableDistribution(tableEcranLissee,tableEcran,k_PAS_DE_LISSAGE);  // juste une copie
                LisserTableDistribution(tableEcran,tableEcranLissee,typeLissage);
              end;
              *)
          end;


      placePourLaCourbe := basCourbe - courbeRect.top;

      (*
      WritelnNumDansRapport('larg = ',larg);
      WritelnNumDansRapport('placePourLaCourbe = ',placePourLaCourbe);
      WritelnNumDansRapport('gCloud.cardinal = ',gCloud.cardinal);
      *)

      if (gCloud.cardinal < 10000) and (nbPartiesActives < 10000) and (gCloud.capaciteMaximale < 10000)
        then facteurVertical := 8.0
        else facteurVertical := 6.0;



      // plus la place verticale pour la courbe est grande, plus on peut la dilater
      facteurVertical := facteurVertical * (placePourLaCourbe / 566);

      // plus la largeur de la courbe est petite, plus les points s'accumulent et il faut contracter la courbe
      facteurVertical := facteurVertical * (larg/462);

      // plus le cardinal du nuage est grand, plus il faut tasser la courbe
      aux := Max(nbPartiesActives,gCloud.cardinal);
      if (aux <> 0) then
        begin
          if aux >= 80000
            then facteurVertical := facteurVertical * (97250/aux)
            else facteurVertical := facteurVertical * sqrt((97250/aux));
        end;



      Move(larg + minValMediane, basCourbe);

      for j := minValMediane to maxValMediane do
          begin


            a := larg + j;

            b := basCourbe - MyTrunc(0.5 + facteurVertical*tableEcranLissee^[j]);

            Lineto(a,b);

            (*

            {trace des points sur la courbe}

            if (abs(a - old_a) + abs(b - old_b) >= 10) then
              begin
                ForeColor(blackColor);

                Moveto(old_a,old_b);
                Line(0,0);

                Moveto(a,b);
                Line(0,0);

                old_a := a;
                old_b := b;
              end;

            *)

            (*
            if (b <> basCourbe) then
              begin
                Line(0,-1);
                Line(1,0);
                Line(-1,0);
              end;
            *)

          end;


      DisposeMemoryPtr(Ptr(tableEcran));
      DisposeMemoryPtr(Ptr(tableEcranLissee));

      SetPort(oldport);
    end;
end;


function GetScoreAxeVerticalParNroRefPartie(numeroReference : SInt32) : SInt32;
begin

  case gCloud.typeDeRegression of

    k_REGRESSION_QUALITE_EDMOND,
    k_REGRESSION_QUALITE_CASSIO,
    k_REGRESSION_QUALITE_CASSIO_ANTIQUE,
    k_REGRESSION_SCORE_FINAL             : GetScoreAxeVerticalParNroRefPartie := GetScoreTheoriqueParNroRefPartie(numeroReference);

    k_REGRESSION_SCORE_FIN_OUVERTURE     : GetScoreAxeVerticalParNroRefPartie := GetScoreReelParNroRefPartie(numeroReference);

    k_REGRESSION_EDAX                    : GetScoreAxeVerticalParNroRefPartie := 0;

  end;

end;


procedure DessinePointsRegressionCeScoreTheorique(quelScoreTheorique : SInt16; var mediane : SInt32; avecDessinCourbeDistribution : boolean);
var j,n, valeur : SInt32;
    ok : boolean;
    c : TableDistributionPtr;
    nbPartiesOK,quantileMedian : SInt32;
    position : PositionEtTraitRec;
    numeroReference : SInt32;
    magicCookieArrivee : SInt32;
    scoreEdax : SInt32;
label sortie;
begin

  magicCookieArrivee := gCloud.magicCookie;

  c := TableDistributionPtr(AllocateMemoryPtr(sizeof(TableDistribution)));


  for j := minValMediane to maxValMediane do c^[j] := 0;
  nbPartiesOK := 0;

  if (gCloud.typeDeRegression = k_REGRESSION_EDAX)
    then
      begin
        for scoreEdax := -64 to 64 do
          if (gEdaxCorrelationMatrix <> NIL) then
            begin
              n := gEdaxCorrelationMatrix^[scoreEdax,quelScoreTheorique];
              for j := 1 to n do
                begin

                  if (gCloud.magicCookie <> magicCookieArrivee) then
                    goto sortie;

                  valeur := (scoreEdax*100) + (Abs(Random16()) mod 100) - 49;

                  // "pitit correction" of the eval
                  // if (valeur > 0) then valeur := MyTrunc(valeur * 1.2);

                  if valeur < -6400 then valeur := -6400;
                  if valeur >  6400 then valeur := 6400;

                  PlotPointRegression(quelScoreTheorique,valeur,0);

                  inc(nbPartiesOK);
                  if valeur < minValMediane then valeur := minValMediane;
                  if valeur > maxValMediane then valeur := maxValMediane;
                  inc(c^[valeur]);
                end;
            end;
      end
    else
      begin

        for j := 1 to nbPartiesActives do
          begin

            if (gCloud.magicCookie <> magicCookieArrivee) then
              goto sortie;

            numeroReference := tableNumeroReference^^[j];
            if GetScoreAxeVerticalParNroRefPartie(numeroReference) = quelScoreTheorique then
              begin
                valeur := ValeurEvaluationDeCassioPourNoirDeLaPartie(numeroReference,gCloud.typeDeRegression,ok,position);
                if ok then
                  begin
                    PlotPointRegression(quelScoreTheorique,valeur,numeroReference);

                    inc(nbPartiesOK);
                    if valeur < minValMediane then valeur := minValMediane;
                    if valeur > maxValMediane then valeur := maxValMediane;
                    inc(c^[valeur]);
                  end;
              end;
          end;

      end;

  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;

  if avecDessinCourbeDistribution
    then DessineCourbeDistribution(quelScoreTheorique,c,k_LISSAGE_MOYENNE);


  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;

  {calcul de la mediane}
  mediane := noteImpossible;
  quantileMedian := nbPartiesOK div 2;
  for j := minValMediane + 1 to maxValMediane do c^[j] := c^[j-1]+c^[j];
  for j := minValMediane to maxValMediane do
    if c^[j] > quantileMedian then
      begin
        mediane := j;
        leave;
      end;



sortie :

  DisposeMemoryPtr(Ptr(c));


end;

function EstUnScoreTheoriqueDontOnDoitTracerLaCourbe(score : SInt32) : boolean;
begin
  EstUnScoreTheoriqueDontOnDoitTracerLaCourbe := ((score mod 8) = 0) or (score = 28) or (score = 36)
end;



procedure DessineMedianeCeScoreTheorique(quelScoreTheorique,mediane : SInt32);
begin
  if mediane <> noteImpossible then
    begin
      gCloud.TableauDesMedianes[quelScoreTheorique].valeur := mediane;
      gCloud.TableauDesMedianes[quelScoreTheorique].medianeEstRemplie := true;
      DessineCarreBlancCeScoreTheorique(quelScoreTheorique,mediane);
    end;
end;



procedure HistogrammeValeursTheoriquesDansRapport;
var kmin,kmax : SInt32;
    i,j : SInt32;
    c : array[-1000..1000] of SInt32;
begin
  kmin := 0; kmax := 64;
  for i := kmin to kmax do c[i] := 0;
  for j := 1 to nbPartiesActives do
    inc(c[GetScoreAxeVerticalParNroRefPartie(tableNumeroReference^^[j])]);
  for i := 0 to 64 do
     WritelnNumDansRapport('theorique['+NumEnString(i)+'] = ',c[i]);
end;




function ValeurEvaluationDeCassioPourNoirDeLaPartie(nroRefPartie : SInt32; typeRegression : SInt32; var ok : boolean; var positionEtTrait : PositionEtTraitRec) : SInt32;
var s60 : PackedThorGame;
    trait : SInt32;
    nbNoir,nbBlanc : SInt32;
    jouables : plBool;
    frontiere : InfoFront;
    note,nbEvalsRecursives : SInt32;
    position : plateauOthello;
    bestDef : SInt32;
    prof : SInt32;
    oldInterruption : SInt16;
    perturbation : SInt32;
    apresQuelCoup : SInt32;
    tempoUtilisationNouvelleEval : boolean;
    tempoDiscretisation : boolean;
    tempoTypeEvalEnCours : EvalsDisponibles;
begin {$unused nbEvalsRecursives}

  ok := false;
  note := noteImpossible;

  ValeurEvaluationDeCassioPourNoirDeLaPartie := 0;

  if (nroRefPartie >= 1) and (nroRefPartie <= nbPartiesChargees) then
    begin

      if (typeRegression = k_REGRESSION_SCORE_FINAL)
        then
          begin
            note := 100*2*(GetScoreReelParNroRefPartie(nroRefPartie) - 32);
            perturbation := Random16();

            if perturbation >= 0
              then note := note + (perturbation mod 99)
              else note := note - ((-perturbation) mod 99);

            ok := true;
            ValeurEvaluationDeCassioPourNoirDeLaPartie := note;

          end
        else
          begin

            ExtraitPartieTableStockageParties(nroRefPartie,s60);

            case typeRegression of
              k_REGRESSION_QUALITE_EDMOND         :   apresQuelCoup := kNumeroCoupCalculScoreTheoriqueDansWThor;
              k_REGRESSION_QUALITE_CASSIO         :   apresQuelCoup := kNumeroCoupCalculScoreTheoriqueDansWThor;
              k_REGRESSION_QUALITE_CASSIO_ANTIQUE :   apresQuelCoup := kNumeroCoupCalculScoreTheoriqueDansWThor;
              k_REGRESSION_SCORE_FIN_OUVERTURE    :   apresQuelCoup := 20;
              otherwise WritelnDansRapport('WARNING : type de regression inconnu dans ValeurEvaluationDeCassioPourNoirDeLaPartie !!');
            end; {case}

            if CalculePositionEtTraitApres(s60,apresQuelCoup,position,trait,nbBlanc,nbNoir) then
              begin
                Calcule_Valeurs_Tactiques(position,true);
                CarteFrontiere(position,frontiere);
                CarteJouable(position,jouables);

                PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);


                // on ne veut pas se faire interrompre pendant l'evaluation

                oldInterruption := GetCurrentInterruption;
                EnleveCetteInterruption(oldInterruption);


                // sauvegarde des reglages generaux

                tempoUtilisationNouvelleEval := utilisationNouvelleEval;
                tempoTypeEvalEnCours         := typeEvalEnCours;
                tempoDiscretisation          := utilisateurVeutDiscretiserEvaluation;


                // modifions temporairement les reglages generaux pour evaluer rapidement cette position

                utilisateurVeutDiscretiserEvaluation := false;

                case typeRegression of
                  k_REGRESSION_QUALITE_EDMOND :
                    begin
                      if utilisationNouvelleEval
                        then typeEvalEnCours         := EVAL_EDMOND;
                    end;
                  k_REGRESSION_QUALITE_CASSIO :
                    begin
                      if utilisationNouvelleEval
                        then typeEvalEnCours         := EVAL_CASSIO;
                    end;
                  k_REGRESSION_QUALITE_CASSIO_ANTIQUE :
                    begin
                      utilisationNouvelleEval := false;
                    end;
                  k_REGRESSION_SCORE_FIN_OUVERTURE :
                    begin
                      if utilisationNouvelleEval
                        then typeEvalEnCours         := EVAL_EDMOND;
                    end;
                end;

                // on evalue, hein !

                {
                if trait = pionNoir
                  then note :=  Evaluation(position,trait,nbBlanc,nbNoir,jouables,frontiere,true,-30000,30000,nbEvalsRecursives)
                  else note := -Evaluation(position,trait,nbBlanc,nbNoir,jouables,frontiere,true,-30000,30000,nbEvalsRecursives);
                }


                prof := 1;
                if trait = pionNoir
                  then note :=  AB_simple(position,jouables, bestDef, trait, prof, -30000, 30000, nbBlanc, nbNoir, frontiere, true)
                  else note := -AB_simple(position,jouables, bestDef, trait, prof, -30000, 30000, nbBlanc, nbNoir, frontiere, true);



                // on remet les reglages generaux

                utilisationNouvelleEval               := tempoUtilisationNouvelleEval;
                typeEvalEnCours                       := tempoTypeEvalEnCours;
                utilisateurVeutDiscretiserEvaluation  := tempoDiscretisation;

                // on remet les interruptions

                LanceInterruption(oldInterruption,'ValeurEvaluationDeCassioPourNoirDeLaPartie');



                // on renvoie les trois resultats

                positionEtTrait := MakePositionEtTrait(position,trait);
                ok := true;
                ValeurEvaluationDeCassioPourNoirDeLaPartie := note;

              end;
          end;
    end;
end;





function MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique : SInt16;
                                                        var nbPartiesFoireuses,nbPartiesOK : SInt32;
                                                        var valMin,valMax : SInt32;
                                                        var positionMin,positionMax : PositionEtTraitRec;
                                                        var nroRefMin,nroRefMax : SInt32;
                                                        var sommeDesEcarts,sommeDesCarres : SInt32;
                                                        var mediane : SInt32) : SInt32;
var somme,valeur,j : SInt32;
    ecart,quantileMedian : SInt32;
    c : TableDistributionPtr;
    ok : boolean;
    position : PositionEtTraitRec;
    numeroReference : SInt32;
begin
  somme := 0;
  sommeDesEcarts := 0;
  sommeDesCarres := 0;
  nbPartiesFoireuses := 0;
  nbPartiesOK := 0;
  valMin := 1000000;
  valMax := -1000000;
  nroRefMin := 0;
  nroRefMax := 0;
  mediane := noteImpossible;

  c := TableDistributionPtr(AllocateMemoryPtr(sizeof(TableDistribution)));

  for j := minValMediane to maxValMediane do c^[j] := 0;

  for j := 1 to nbPartiesActives do
    begin
      numeroReference := tableNumeroReference^^[j];
      if GetScoreAxeVerticalParNroRefPartie(numeroReference) = quelScoreTheorique then
        begin
          valeur := ValeurEvaluationDeCassioPourNoirDeLaPartie(numeroReference,gCloud.typeDeRegression,ok,position);
          if not(ok)
            then
              begin
                inc(nbPartiesFoireuses);
              end
            else
              begin
                inc(nbPartiesOK);
                somme := somme+valeur;
                if valeur < valMin then
                  begin
                    valMin := valeur;
                    positionMin := position;
                    nroRefMin := numeroReference;
                  end;
                if valeur > valMax then
                  begin
                    valMax := valeur;
                    positionMax := position;
                    nroRefMax := numeroReference;
                  end;

                ecart := Abs(quelScoreTheorique - NoteCassioEnScoreFinal(valeur));
                if ecart > 20 then ecart := 20;

                sommeDesEcarts := sommeDesEcarts + ecart;
                sommeDesCarres := sommeDesCarres + ecart*ecart;

                if valeur < minValMediane then inc(c^[minValMediane]) else
                if valeur > maxValMediane then inc(c^[maxValMediane]) else
                  inc(c^[valeur]);
              end;
        end;
    end;
  if (nbPartiesOk > 0)
    then
      begin
        MoyenneDesEvaluationsDesPartiesAScoreTheorique := (somme div nbPartiesOk);

        {calcul de la mediane}
			  quantileMedian := nbPartiesOK div 2;
			  for j := minValMediane + 1 to maxValMediane do c^[j] := c^[j-1]+c^[j];
			  for j := minValMediane     to maxValMediane do
			    if (c^[j] > quantileMedian) then
			      begin
			        mediane := j;
			        leave;
			      end;

      end
    else
      begin
        MoyenneDesEvaluationsDesPartiesAScoreTheorique := noteImpossible;
      end;

  DisposeMemoryPtr(Ptr(c));
end;


procedure MoyenneDeTelScoreTheoriqueDansRapport(quelScoreTheorique : SInt32; positionsExtremesDansRapport : boolean);
var moyenne,valMin,valMax : SInt32;
    nbPartiesOk,nbPartiesFoireuses : SInt32;
    sommeDesEcarts,sommeDesCarres : SInt32;
    mediane : SInt32;
    positionMin,positionMax : PositionEtTraitRec;
    nroPartieMaximun,nroPartieMinimum : SInt32;
    s : String255;
begin
  Superviseur(kNumeroCoupCalculScoreTheoriqueDansWThor);
  InitialiseModeleLineaireValeursPotables;

  moyenne := MoyenneDesEvaluationsDesPartiesAScoreTheorique(quelScoreTheorique,nbPartiesFoireuses,nbPartiesOK,valMin,valMax,positionMin,positionMax,nroPartieMinimum,nroPartieMaximun,sommeDesEcarts,sommeDesCarres,mediane);

  if nbPartiesOK <> 0 then
    begin

      WritelnDansRapport('th = '          + NumEnString(quelScoreTheorique)+
                   { '  Foir = '      + NumEnString(nbPartiesFoireuses)+ }
                     '  N = '         + NumEnString(nbPartiesOK)+
                   {'  tot = '        + NumEnString(nbPartiesFoireuses+nbPartiesOK)+}
                     '  moy = '       + NumEnString(moyenne)+
                     '  med = '       + NumEnString(mediane)+
                     '  min = '       + NumEnString(valMin)+
                     '  max = '       + NumEnString(valMax)+
                     '  ∑Ecarts = '   + NumEnString(sommeDesEcarts)+
                     '  ∑Ecarts/N = ' + NumEnString(((100*sommeDesEcarts) div nbPartiesOK) div 100)+'.'+NumEnString((100*sommeDesEcarts div nbPartiesOK) mod 100)+
                     '  ∑Carres = '   + NumEnString(sommeDesCarres) );

      if PositionsExtremesDansRapport then
        begin
          WritelnDansRapport('');
          if (quelScoreTheorique <= 32) and (valMax >= 0) then
            begin
              WritelnNumDansRapport('score = '+NumEnString(quelScoreTheorique)+' mais eval = ',valMax);
              WritelnPositionEtTraitDansRapport(positionMax.position,GetTraitOfPosition(positionMax));

              s := GetNomTournoiAvecAnneeParNroRefPartie(nroPartieMaximun,29);
              WriteDansRapport(s+'  ');
	            s := GetNomJoueurNoirParNroRefPartie(nroPartieMaximun);
	            WriteDansRapport(s+'  ');
	            s := GetNomJoueurBlancParNroRefPartie(nroPartieMaximun);
	            WritelnDansRapport(s);
            end;
          if (quelScoreTheorique >= 32) and (valMin <= 0) then
            begin
              WritelnNumDansRapport('score = '+NumEnString(quelScoreTheorique)+' mais eval = ',valMin);
              WritelnPositionEtTraitDansRapport(positionMin.position,GetTraitOfPosition(positionMin));
              s := GetNomTournoiAvecAnneeParNroRefPartie(nroPartieMinimum,29);
              WriteDansRapport(s+'  ');
	            s := GetNomJoueurNoirParNroRefPartie(nroPartieMinimum);
	            WriteDansRapport(s+'  ');
	            s := GetNomJoueurBlancParNroRefPartie(nroPartieMinimum);
	            WritelnDansRapport(s);
            end;
        end;

      WritelnDansRapport('');
    end;

end;


function NoteCassioEnScoreFinal(note : SInt32) : SInt32;
var aux,valeurEn14,valeurEn50 : SInt32;
begin
  if utilisationNouvelleEval
    then
      begin
        (*
        aux := RoundToL(note*0.01);
        if aux < -64 then aux := -64;
        if aux > 64 then aux := 64;
        NoteCassioEnScoreFinal := 32+ (aux div 2)
        *)
        aux := 32 + RoundToL(note*0.005);
        if aux < 0  then aux := 0;
        if aux > 64 then aux := 64;
        NoteCassioEnScoreFinal := aux;
      end
    else
      begin
			  if note > 0
			    then
			      begin
			        {valeurEn50 := (moyenneDesValeursPourCeScore[50]+medianeDesValeursPourCeScore[50]) div 2;}
			        valeurEn50 := medianeDesValeursPourCeScore[50];
			        if note < valeurEn50
			          then
			            begin
			              aux := (valeurEn50 div 36);
			              NoteCassioEnScoreFinal := 32+ (((note+aux)*18) div valeurEn50);
			            end
			          else
			            begin
			              aux := 50 + ((note-valeurEn50+175) div 350);
			              if aux > 64 then aux := 64;
			              NoteCassioEnScoreFinal := aux;
			            end;
			      end
			    else
			      begin
			        {valeurEn14 := (moyenneDesValeursPourCeScore[14]+medianeDesValeursPourCeScore[14]) div 2;}
			        valeurEn14 := medianeDesValeursPourCeScore[14];
			        if note > valeurEn14
			          then
			            begin
			              aux := ((-valeurEn14) div 36);
			              NoteCassioEnScoreFinal := 32 - (((aux-note)*18) div (-valeurEn14));
			            end
			          else
			            begin
			              aux := 14 - ((valeurEn14-note+175) div 350);
			              if aux < 0 then aux := 0;
			              NoteCassioEnScoreFinal := aux;
			            end;
			      end;
		  end;
end;




procedure DessineNuageDePointsRegression;
var score,mediane : SInt32;
    avecDessinCourbe : boolean;
    oldTracage : boolean;
    x_centre,y_centre : SInt32;
    magicCookieArrivee : SInt32;
label sortie;
begin
  SetCassioEstEnTrainDeTracerLeNuage(true,@oldTracage);

  inc(gCloud.magicCookie);
  magicCookieArrivee := gCloud.magicCookie;

  gNbPointsRegressionTraces := 0;
  gNbCourbesDistributionTracees := 0;

  ViderCloud;

  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;

  if (gCloud.capaciteMaximale <> nbPartiesActives) then
    begin
      DisposeMemoryForCloud;
      AllocateMemoryForCloud(nbPartiesActives);
    end;

  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;


  EffaceCourbesDistribution;
  PlotRepereRegression;

  GetCentreRepereRegression(x_centre,y_centre);

  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;

  InitGrid;

  gCloud.repereVertical.intervalleEntreLignes := kIntervalleEntreDeuxLignesDuNuage;
  gCloud.repereVertical.pos_y_centre         := y_centre;

  Superviseur(kNumeroCoupCalculScoreTheoriqueDansWThor);

  for score := 0 to 64 do
    if not(Quitter) and (gCloud.magicCookie = magicCookieArrivee) then
      begin
        if (gCloud.magicCookie <> magicCookieArrivee) then
          goto sortie;

        avecDessinCourbe := EstUnScoreTheoriqueDontOnDoitTracerLaCourbe(score);
        DessinePointsRegressionCeScoreTheorique(score,mediane,avecDessinCourbe);

        if (gCloud.magicCookie <> magicCookieArrivee) then
          goto sortie;

        DessineMedianeCeScoreTheorique(score,mediane);

      end;

  if (gCloud.magicCookie <> magicCookieArrivee) then
    goto sortie;


  TrierLesPointsSelonLaGrille;

  sortie :

  SetCassioEstEnTrainDeTracerLeNuage(oldTracage, NIL);
end;


procedure RedrawFastApproximateCurve(scoreTheoriqueATracer : SInt32);
var c : TableDistributionPtr;
    j,k : SInt32;
    x_centre,y_centre : SInt32;
    theorique : SInt32;
    heuristique : SInt32;
begin

  if (gCloud.cardinal <= 0) or not(EstUnScoreTheoriqueDontOnDoitTracerLaCourbe(scoreTheoriqueATracer))
    then exit(RedrawFastApproximateCurve);


  c := TableDistributionPtr(AllocateMemoryPtr(sizeof(TableDistribution)));

  for j := minValMediane to maxValMediane do c^[j] := 0;


  GetCentreRepereRegression(x_centre,y_centre);


  // draw the points in the little square of the grid
  for k := 1 to gCloud.cardinal do
    if not(Quitter) then
      begin

        with gCloud.data^[k] do
          begin
            if y >= y_centre - kDemiIntervalleEntreDeuxLignesDuNuage
              then theorique := 32 - ((y - y_centre + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage)
              else theorique := 32 + ((y_centre - y + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage);

            if theorique < 0  then theorique := 0;
            if theorique > 64 then theorique := 64;

            if (scoreTheoriqueATracer = theorique) then
              begin
                heuristique := eval;

                if heuristique < minValMediane then heuristique := minValMediane;
                if heuristique > maxValMediane then heuristique := maxValMediane;

                inc(c^[heuristique]);
              end;
          end;
      end;

  DessineCourbeDistribution(scoreTheoriqueATracer,c,k_LISSAGE_MOYENNE);

  DisposeMemoryPtr(Ptr(c));
end;


procedure RedrawFastApproximateCloud;
var oldPort : grafPtr;
    i,j,k : SInt32;
    x_centre, y_centre : SInt32;
    theorique, heuristique : SInt32;
    couleurVerte : RGBColor;
    interet : SInt32;
    windowIsBuffered : boolean;
    tickDepart : SInt32;
    theRgn : RgnHandle;
    indexMin, indexMax : SInt32;
    theRect : Rect;
    tableBitboardDesPixelsRemplis : LongintArrayPtr;
    useTableDesPixelsRemplis : boolean;
    taille : SInt32;
    numeroDuBit, index, decalage : UInt32;
    err : OSErr;
    oldTracage : boolean;
    magicCookieArrivee : SInt32;
begin
  SetCassioEstEnTrainDeTracerLeNuage(true, @oldTracage);

  inc(gCloud.magicCookie);
  magicCookieArrivee := gCloud.magicCookie;

  gNbCourbesDistributionTracees := 0;

  EffaceCourbesDistribution;
  PlotRepereCourbesDistribution;

  tickDepart := TickCount;

  if (gCloud.cardinal > 0) and (gCloud.data <> NIL) and (wNuagePtr <> NIL) then
    begin

      GetPort(oldPort);
      SetPortByWindow(wNuagePtr);

      // DoSystemTask(AQuiDeJouer);

      GetCentreRepereRegression(x_centre,y_centre);

      couleurVerte := GetCouleurAffichageValeurZebraBook(pionBlanc,0);

      (*
      if gCloud.cardinal <= 10000
        then PenSize(2,2)
        else PenSize(1,1);
      *)

      windowIsBuffered := true;



      tableBitboardDesPixelsRemplis := NIL;

      // We use the fast (with bit table) drawing algorithm only if the window is < 2048x2048 pixels

      if (x_centre < 1024) and (y_centre < 1024)  then
        begin
          // allocate a table able to store 2048x2048 bits, which is 512kb

          taille := 2048 * 2048  ;    // taille en bits
          taille := taille div 8 ;    // taille en octets

          tableBitboardDesPixelsRemplis := LongintArrayPtr(AllocateMemoryPtrClear(taille));


          // WritelnNumDansRapport('index doit etre compris entre  et ',taille div 4);
        end;

      useTableDesPixelsRemplis := (tableBitboardDesPixelsRemplis <> NIL);

      if useTableDesPixelsRemplis
        then
          begin


            for k := 1 to gCloud.cardinal do
               with gCloud.data^[k] do
                  begin

                    numeroDuBit := y;
                    numeroDuBit := numeroDuBit*2048;
                    numeroDuBit := numeroDuBit + x;

                    //numeroDuBit := x + y*2048;                      // numero du bit dans la table bitboard

                    //index       := numeroDuBit div 32;
                    // decalage    := numeroDuBit mod 32;



                    index       := numeroDuBit shr 5;               // index    := numeroDuBit div 32;
                    decalage    := numeroDuBit and $0000001F;       // decalage := numeroDuBit mod 32;


                    (*
                    if (index < 0) or (index > taille div 4) then
                      begin
                        WritelnNumDansRapport('ASSERT dans RedrawFastApproximateCloud : index = ',index);
                        WritelnNumDansRapport('   y = ',y);
                        WritelnNumDansRapport('   x = ',x);
                        leave;
                      end;
                    *)

                    if not(BTST(tableBitboardDesPixelsRemplis^[index],decalage)) then
                      begin
                        BSET(tableBitboardDesPixelsRemplis^[index],decalage);


                        if y >= y_centre - kDemiIntervalleEntreDeuxLignesDuNuage
                          then theorique := 32 - ((y - y_centre + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage)
                          else theorique := 32 + ((y_centre - y + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage);

                        heuristique := eval;

                        {
                        if true or (scoreTheorique >= 32)
                          then RGBForeColor(GetCouleurAffichageValeurZebraBook(pionBlanc, abs(200*(scoreTheorique - 32) - heuristique)))
                          else RGBForeColor(GetCouleurAffichageValeurZebraBook(pionNoir,  abs(200*(scoreTheorique - 32) - heuristique)));
                        }


                        // We make the same calculations as in GetCouleurAffichageValeurZebraBook, but inline...
                        // Please be sure to make changes in both locations, if necessary !

                        interet := abs(200*(theorique - 32) - heuristique);
                        if (interet > 600) then interet := 600;
                        if (interet < -700) then interet := -700;
                        interet := 60*interet;

                        RGBForeColor(NoircirCouleurDeCetteQuantite(couleurVerte,interet));

                        Moveto(x,y);
                        Line(0,0);


                      end;
              end;





          end
        else
          begin

          (*for i := 0 to kGridQuantificationLevel do
            for j := 0 to kGridQuantificationLevel do
              if CetteCaseDansLaGrilleContientDesPoints(i,j,indexMin,indexMax) then *)
                begin



                  indexMin := 1;
                  indexMax := gCloud.cardinal;


                  // draw the points in the little square of the grid
                  for k := indexMin to indexMax do
                    if not(Quitter) then
                      begin

                        with gCloud.data^[k] do
                          begin
                            if y >= y_centre - kDemiIntervalleEntreDeuxLignesDuNuage
                              then theorique := 32 - ((y - y_centre + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage)
                              else theorique := 32 + ((y_centre - y + kDemiIntervalleEntreDeuxLignesDuNuage) div kIntervalleEntreDeuxLignesDuNuage);

                            heuristique := eval;

                            {
                            if true or (scoreTheorique >= 32)
                              then RGBForeColor(GetCouleurAffichageValeurZebraBook(pionBlanc, abs(200*(scoreTheorique - 32) - heuristique)))
                              else RGBForeColor(GetCouleurAffichageValeurZebraBook(pionNoir,  abs(200*(scoreTheorique - 32) - heuristique)));
                            }


                            // We make the same calculations as in GetCouleurAffichageValeurZebraBook, but inline...
                            // Please be sure to make changes in both locations, if necessary !

                            interet := abs(200*(theorique - 32) - heuristique);
                            if (interet > 600) then interet := 600;
                            if (interet < -700) then interet := -700;
                            interet := 60*interet;

                            RGBForeColor(NoircirCouleurDeCetteQuantite(couleurVerte,interet));

                            Moveto(x,y);
                            Line(0,0);

                          end;

                      end;

                   // flush the points in the little square to the screen
                   if windowIsBuffered and FALSE
                      then
                        begin
                          theRgn := NewRgn();
                          theRect := GetBoundingRectOfGridSquare(i,j);
                          InSetRect(theRect,-1,-1);
                          SetRectRgn(theRgn, theRect.left, theRect.top, theRect.right, theRect.bottom);
                          QDFlushPortBuffer(GetWindowPort(wNuagePtr), theRgn);
                          DisposeRgn(theRgn);
                        end;

                end;
            end;

      PenSize(1,1);


      // draw the medians

      for theorique := 0 to 64 do
        begin
          if (magicCookieArrivee <> gCloud.magicCookie) then leave;

          if gCloud.TableauDesMedianes[theorique].medianeEstRemplie then
            DessineMedianeCeScoreTheorique(theorique,gCloud.TableauDesMedianes[theorique].valeur);
        end;

      //if windowIsBuffered then QDFlushPortBuffer(GetWindowPort(wNuagePtr), NIL);

      if tableBitboardDesPixelsRemplis <> NIL then
        DisposeMemoryPtr(Ptr(tableBitboardDesPixelsRemplis));

      ForeColor(blackColor);

      // draw the distribution curves

      for theorique := 0 to 64 do
        begin
          if (magicCookieArrivee <> gCloud.magicCookie) then leave;

          if EstUnScoreTheoriqueDontOnDoitTracerLaCourbe(theorique)
            then
              begin
                RedrawFastApproximateCurve(theorique);
                if windowIsBuffered then QDFlushPortBuffer(GetWindowPort(wNuagePtr), NIL);
              end;
        end;




      if windowIsBuffered then QDFlushPortBuffer(GetWindowPort(wNuagePtr), NIL);


      err := ValidWindowRect(wNuagePtr,GetWindowPortRect(wNuagePtr));

      SetPort(oldPort);
    end;

  // WritelnNumDansRapport('temps de RedrawFastApproximateCloud = ',TickCount - tickDepart);

  SetCassioEstEnTrainDeTracerLeNuage(oldTracage, NIL);


end;


procedure DessineNuage(fonctionAppelante : String255);
var ticks : SInt32;
    oldTracage : boolean;
begin  {$unused fonctionAppelante, ticks}


  // WritelnDansRapport('appel de DessineNuage par '+fonctionAppelante);

  inc(gCloud.magicCookie);

  SetCassioEstEnTrainDeTracerLeNuage(true, @oldTracage);

  if (gCloud.cardinal <= 0)
    then
      begin
        PlotRepereRegression;
        gNbCourbesDistributionTracees := 0;
        EffaceCourbesDistribution;
        PlotRepereRegression;
      end
    else
      begin
        PlotRepereRegression;
        RedrawFastApproximateCloud;
      end;

  SetCassioEstEnTrainDeTracerLeNuage(oldTracage, NIL);
end;


procedure HistogrammeDesMoyennesParScoreTheoriqueDansRapport;
var score : SInt32;
begin
  for score := 0 to 64 do
    MoyenneDeTelScoreTheoriqueDansRapport(score,true);
end;


procedure AjusteModeleLineaireFinaleAvecStat(var TotalNbPartiesOK,TotalSommeDesEcarts : SInt32);
var nbAjustementsMoyenne : SInt16;
    valMin,valMax : SInt32;
    nbPartiesOk,nbPartiesFoireuses : SInt32;
    sommeDesEcarts,sommeDesCarres : SInt32;
    positionMin,positionMax : PositionEtTraitRec;
    numeroMin,numeroMax : SInt32;


  procedure AjusterModeleDeCeScore(score : SInt16);
  var moyenne,mediane : SInt32;
  begin
    moyenne := MoyenneDesEvaluationsDesPartiesAScoreTheorique(score,nbPartiesFoireuses,nbPartiesOK,valMin,valMax,positionMin,positionMax,numeroMin,numeroMax,sommeDesEcarts,sommeDesCarres,mediane);
    moyenneDesValeursPourCeScore[score] := moyenne;
    medianeDesValeursPourCeScore[score] := mediane;
    if nbPartiesOK <> 0 then
		  WritelnDansRapport('th = '           + NumEnString(score)+
		                   { '  Foir = '       + NumEnString(nbPartiesFoireuses)+ }
		                     '  N = '          + NumEnString(nbPartiesOK)+
		                   {'  tot = '         + NumEnString(nbPartiesFoireuses+nbPartiesOK)+}
		                     '  moy = '        + NumEnString(moyenne)+
		                     '  med = '        + NumEnString(mediane)+
		                     '  min = '        + NumEnString(valMin)+
		                     '  max = '        + NumEnString(valMax){+
		                     '  ∑Ecarts = '    + NumEnString(sommeDesEcarts)+
		                     '  ∑Ecarts/N = '  + NumEnString(((100*sommeDesEcarts) div nbPartiesOK) div 100)+'.'+NumEnString((100*sommeDesEcarts div nbPartiesOK) mod 100)+
		                     '  ∑Carres = '    + NumEnString(sommeDesCarres)});
		TotalNbPartiesOK := TotalNbPartiesOK+nbPartiesOK;
    TotalSommeDesEcarts := TotalSommeDesEcarts+sommeDesEcarts;
  end;

begin
  TotalNbPartiesOK := 0;
  TotalSommeDesEcarts := 0;

  if (nbPartiesActives <= 0) then
    begin
      AlerteSimple('Vous devez charger des parties de la base pour Ajuster le modèle linéaire de Cassio ! (note : si vous ne savez pas ce qu''est la base Wthor, laissez tomber :-) )');
      exit(AjusteModeleLineaireFinaleAvecStat);
    end;

  Superviseur(kNumeroCoupCalculScoreTheoriqueDansWThor);
  InitialiseModeleLineaireValeursPotables;

  WritelnDansRapport('Ajustement du modèle linéaire de finale…');

  WritelnDansRapport('Calcul du terme constant à l''aide des parties au score théorique 32…');

  nbAjustementsMoyenne := 0;
  repeat
    inc(nbAjustementsMoyenne);
    {WritelnNumDansRapport('penalitePourLeTrait = ',penalitePourLeTrait);}
    AjusterModeleDeCeScore(32);
    {penalitePourLeTrait := penalitePourLeTrait+MyTrunc(1.0*moyenneDesValeursPourCeScore[32]);}
    penalitePourLeTrait := penalitePourLeTrait+MyTrunc(1.0*medianeDesValeursPourCeScore[32]);
  until (nbAjustementsMoyenne >= 7) or
        {(Abs(moyenneDesValeursPour32) <= 1)}
        (Abs(medianeDesValeursPourCeScore[32]) <= 1);

  {WritelnNumDansRapport('penalitePourLeTrait = ',penalitePourLeTrait);}

  WritelnDansRapport('Calcul de la pente à l''aide des parties aux scores théoriques 14 et 50…');

  AjusterModeleDeCeScore(14);
  AjusterModeleDeCeScore(50);

  WritelnDansRapport('');
  WritelnDansRapport('Apres Ajustement, voici quelques statistiques…');


  TotalNbPartiesOK := 0;
  TotalSommeDesEcarts := 0;

  AjusterModeleDeCeScore(14);
  AjusterModeleDeCeScore(19);
  AjusterModeleDeCeScore(21);
  AjusterModeleDeCeScore(24);
  AjusterModeleDeCeScore(29);
  AjusterModeleDeCeScore(32);
  AjusterModeleDeCeScore(35);
  AjusterModeleDeCeScore(40);
  AjusterModeleDeCeScore(43);
  AjusterModeleDeCeScore(45);
  AjusterModeleDeCeScore(50);


end;

procedure AjusteModeleLineaireFinale;
var N,SigmaEcart : SInt32;
begin
   WritelnDansRapport('');
   AjusteModeleLineaireFinaleAvecStat(N,SigmaEcart);
   if N <> 0 then
      WritelnDansRapport('  Nombre parties prises en compte = '          + NumEnString(N)+
                         '  ∑Ecarts = '    + NumEnString(SigmaEcart)+
                         '  ∑Ecarts/N = '  + NumEnString(((100*SigmaEcart) div N) div 100)+'.'+NumEnString((100*SigmaEcart div N) mod 100));
   WritelnDansRapport('');
end;


procedure TestRegressionLineaire;
begin
  {HistogrammeValeursTheoriquesDansRapport;}
  {HistogrammeDesMoyennesParScoreTheoriqueDansRapport;}

  {DessineNuageDePointsRegression;}

  DoRegressionLineaireCoeffsCassio(kNumeroCoupCalculScoreTheoriqueDansWThor);

end;


procedure DeterminerLaMeilleureEchelleVerticaleDuNuage;
var hauteurFenetre : SInt32;
begin
  if (wNuagePtr <> NIL) then
    begin
      hauteurFenetre := GetWindowPortRect(wNuagePtr).bottom - GetWindowPortRect(wNuagePtr).top;

      kIntervalleEntreDeuxLignesDuNuage := 7;        // must be odd !
      kDemiIntervalleEntreDeuxLignesDuNuage := 3 ;   // must be  (kIntervalleEntreDeuxLignesDuNuage div 2)

      if hauteurFenetre < 650 then
        begin
          kIntervalleEntreDeuxLignesDuNuage := 5;
          kDemiIntervalleEntreDeuxLignesDuNuage := 2;
        end;

    end;
end;



procedure MetTitreFenetreNuage;
var currentTitle255 : str255;
    s,currentTitle : String255;
    oldPort : grafPtr;
begin
  if (wNuagePtr <> NIL) then
    begin
      GetWTitle(wNuagePtr,currentTitle255);
      currentTitle := MyStr255ToString(currentTitle255);

      s := ReadStringFromRessource(TitresFenetresTextID,11); {Cloud}

      GetPort(oldport);
      SetPortByWindow(wNuagePtr);
      FntrNuageRect := GetWindowPortRect(wNuagePtr);
      LocalToGlobal(FntrNuageRect.topleft);
      LocalToGlobal(FntrNuageRect.botright);
      SetPort(oldport);

      s := s + '  ('+NumEnString(FntrNuageRect.right - FntrNuageRect.left)+'x'+
                   NumEnString(FntrNuageRect.bottom - FntrNuageRect.top)+'px)';

      if (s <> currentTitle) then SetWTitle(wNuagePtr,StringToStr255(s));
    end;
end;




end.
