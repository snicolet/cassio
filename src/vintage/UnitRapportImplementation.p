UNIT UnitRapportImplementation;


INTERFACE







 USES ControlDefinitions , Controls , Events , UnitDefCassio , TextServices , TSMTE, UnitDefParallelisme;






procedure InitUnitRapport;
procedure LibereMemoireUnitRapport;


{fonctions d'acces aux champs du RapportRec}
function GetWindowRapportOpen : boolean;
function GetRapportWindow : WindowPtr;
function GetTextEditRecordOfRapport : TEHandle;
function GetTSMDocOfRapport : TSMDocumentID;
function GetTSMTERecHandleOfRapport : TSMTERecHandle;
function GetVerticalScrollerOfRapport : ControlHandle;
function GetHorizontalScrollerOfRapport : ControlHandle;
function GetTailleMaximumOfRapport : SInt32;
function GetProchaineAlerteRemplissageRapport : SInt32;
procedure SetProchaineAlerteRemplissageRapport(tailleCritique : SInt32);



procedure ChangeFontDansRapport(whichFont : SInt16);
procedure ChangeFontFaceDansRapport(whichStyle : StyleParameter);
procedure ChangeFontSizeDansRapport(whichSize : SInt16);
procedure ChangeFontColorDansRapport(whichColor : SInt16);
procedure ChangeFontColorRGBDansRapport(whichColor : RGBColor);
procedure TextNormalDansRapport;



procedure UpdateScrollersRapport;
procedure InvalScrollersRapport;
procedure CalculateViewAndDestRapport;
procedure TrackScrollingRapport(ch: ControlHandle; part: SInt16);
function MyTrackControlIndicatorPartRapport(theControl : ControlHandle) : SInt16;
function MyClikLoopRapport : boolean;
procedure ChangeWindowRapportSize(hSize,vSize : SInt16);
procedure DoUpdateRapport;
procedure DoActivateRapport;
procedure DoDeactivateRapport;
procedure RedrawFenetreRapport;
function GetLongueurMessageBienvenueDansCassio : SInt16;
procedure SetLongueurMessageBienvenueDansCassio(longueur : SInt16);
procedure DetruireSelectionDansRapport;
procedure SetDebutSelectionRapport(debut : SInt32);
procedure SetFinSelectionRapport(fin : SInt32);
procedure FrappeClavierDansRapport(whichChar : char);



{quelques fonction d'acces}
procedure EffaceDernierCaractereDuRapportSync(scrollerSynchronisation : boolean);
procedure EffaceDernierCaractereDuRapport;
procedure PositionnePointDinsertion(index : SInt32);
function GetPositionPointDinsertion : SInt32;
procedure SetDeroulementAutomatiqueDuRapport(flag : boolean);
function GetDeroulementAutomatiqueDuRapport : boolean;
function FindStringInRapport(s : String255; from,direction : SInt32; var positionTrouvee : SInt32) : boolean;

procedure FinRapport;
procedure VoirLeDebutDuRapport;
procedure VoirLaFinDuRapport;
procedure ViewRectAGaucheRapport;
function NbLignesVisiblesDansRapport : SInt16;
function NbColonnesVisiblesDansRapport : SInt16;



{Autovidage}
procedure SetAutoVidageDuRapportDansImplementation(flag : boolean);
function GetAutoVidageDuRapportDansImplementation : boolean;

{Gestion du fichier "Rapport.log"}
procedure SetEcritToutDansRapportLogDansImplementation(flag : boolean);
function GetEcritToutDansRapportLogDansImplementation : boolean;


{Gestion du rapport thread safe}
procedure AjouterStringDansListePourRapportThreadSafe(s : String255);
procedure EnleverStringDansListePourRapportThreadSafe(s : String255);
procedure GererRapportSafe;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    FixMath, UnitRapportTypes, MacWindows, Timer, Multiprocessing, OSAtomic_glue
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitServicesRapport
    , SNEvents, MyMathUtils, UnitCouleur, MyUtils, UnitServicesMemoire, UnitRapport, MyStrings, MyFonts
    , UnitCarbonisation ;
{$ELSEC}
    ;
    {$I prelink/RapportImplementation.lk}
{$ENDC}


{END_USE_CLAUSE}











const  kControlSpecialDocumentTopPart    = -12437;
       kControlSpecialDocumentBottomPart = -12438;

var longueurMessageBienvenueDansCassio : SInt16;
    mutex_TE_set_style : SInt32;

const kValeurMutexTESetStyle  = -1;
const kTailleListeDesEcrituresThreadSafeDansRapport = 100;

var gListeEcritureThreadSafeDansRapport :
      record
        index                     : SInt32;
        cardinal                  : SInt32;
        strings                   : array[0..kTailleListeDesEcrituresThreadSafeDansRapport] of String255Hdl;
      end;



procedure InitUnitRapport;
var k : SInt32;
begin
  rapport.theWindow := NIL;
  rapport.theText := NIL;
  rapport.docTSMTERecHandle := NIL;
  rapport.docTSMDoc := NIL;

  SetAutoVidageDuRapportDansImplementation(false);
  SetEcritToutDansRapportLogDansImplementation(false);

  longueurMessageBienvenueDansCassio := 0;

  mutex_TE_set_style := 0;

  with gListeEcritureThreadSafeDansRapport do
    begin
      index                              := 0;
      cardinal                           := 0;

      for k := 0 to kTailleListeDesEcrituresThreadSafeDansRapport do
        begin
          strings[k]                  := NIL;
        end;
    end;

end;


procedure LibereMemoireUnitRapport;
var k : SInt32;
begin
  with gListeEcritureThreadSafeDansRapport do
    begin
      index                   := 0;
      cardinal                := 0;

      for k := 0 to kTailleListeDesEcrituresThreadSafeDansRapport do
        begin
          if (strings[k] <> NIL) then DisposeMemoryHdl(Handle(strings[k]));
        end;
    end;
end;



procedure AjouterStringDansListePourRapportThreadSafe(s : String255);
var k,t : SInt32;
begin

  if (s = '') | (gListeEcritureThreadSafeDansRapport.cardinal >= kTailleListeDesEcrituresThreadSafeDansRapport)
    then exit(AjouterStringDansListePourRapportThreadSafe);

  with gListeEcritureThreadSafeDansRapport do
    begin
      for k := 0 to kTailleListeDesEcrituresThreadSafeDansRapport do
        begin

          t := index + k + 1;
          if t > kTailleListeDesEcrituresThreadSafeDansRapport then t := t - (kTailleListeDesEcrituresThreadSafeDansRapport + 1);

          if (strings[t] = NIL)  then
            begin

              strings[t] := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
              if (strings[t] <> NIL) then
                begin
                  inc(cardinal);
                  strings[t]^^ := s;
                end;

              exit(AjouterStringDansListePourRapportThreadSafe);
            end;
       end;
    end;

end;


procedure EnleverStringDansListePourRapportThreadSafe(s : String255);
var k,t : SInt32;
begin

  if (s = '') then exit(EnleverStringDansListePourRapportThreadSafe);

  with gListeEcritureThreadSafeDansRapport do
    begin
      for k := 0 to kTailleListeDesEcrituresThreadSafeDansRapport do
        begin

          t := index + k;
          if t > kTailleListeDesEcrituresThreadSafeDansRapport then t := t - (kTailleListeDesEcrituresThreadSafeDansRapport + 1);


          if (strings[t] <> NIL) & (strings[t]^^ = s) then
            begin

              DisposeMemoryHdl(Handle(strings[t]));
              dec(cardinal);

              exit(EnleverStringDansListePourRapportThreadSafe);
            end;
        end;
    end;

end;


procedure GererRapportSafe;
var k,t,debut : SInt32;
    s : String255;
begin
  with gListeEcritureThreadSafeDansRapport do
    begin
      if (cardinal > 0) then
       begin

         debut := index;

         for k := 0 to kTailleListeDesEcrituresThreadSafeDansRapport do
           begin

             t := debut + k;
             if t > kTailleListeDesEcrituresThreadSafeDansRapport then t := t - (kTailleListeDesEcrituresThreadSafeDansRapport + 1);

             if (strings[t] <> NIL) then
               begin

                 s := strings[t]^^;

                 dec(cardinal);

                 index := t;

                 DisposeMemoryHdl(Handle(strings[t]));

                 strings[t] := NIL;


                 WriteDansRapport(s);

               end;
           end;
       end;
    end;
end;



procedure MyTESetStyle(mode : SInt16; {CONST}var newStyle : TextStyle; fRedraw : boolean; hTE : TEHandle);
var trick : boolean;
    selectionInvisible : boolean;
begin

  if (hTE <> NIL) then
    begin

      while (ATOMIC_COMPARE_AND_SWAP_32_BARRIER(0, kValeurMutexTESetStyle, mutex_TE_set_style) = 0)
        do;

      trick := false;
      if gIsRunningUnderMacOSX & SelectionRapportEstVide then
        begin
          trick := true;
          {InsereStringDansRapportSync(' ',false);}
          SelectionnerTexteDansRapport(GetDebutSelectionRapport-1,GetFinSelectionRapport);
        end;

      selectionInvisible := (LongueurSelectionRapport <= 4);

      // il y a un BUG CRASHANT dans TextEdit en Carbon quand on ne force pas fRedraw à false :-(
      fRedraw := false;

      TESetStyle(mode, newStyle, fRedraw , hTE);

      if trick then
        begin
          SelectionnerTexteDansRapport(GetFinSelectionRapport,GetFinSelectionRapport);
        end;

      mutex_TE_set_style := 0;

    end;

end;












function GetWindowRapportOpen : boolean;
begin
  GetWindowRapportOpen := (windowRapportOpen & (rapport.theWindow <> NIL));
end;

function GetRapportWindow : WindowPtr;
begin
  GetRapportWindow := rapport.theWindow;
end;

function GetTextEditRecordOfRapport : TEHandle;
begin
  GetTextEditRecordOfRapport := rapport.theText;
end;

function GetTSMDocOfRapport : TSMDocumentID;
begin
  GetTSMDocOfRapport := rapport.docTSMDoc;
end;

function GetTSMTERecHandleOfRapport : TSMTERecHandle;
begin
  GetTSMTERecHandleOfRapport := rapport.docTSMTERecHandle;
end;

function GetVerticalScrollerOfRapport : ControlHandle;
begin
  GetVerticalScrollerOfRapport := rapport.vScroller;
end;

function GetHorizontalScrollerOfRapport : ControlHandle;
begin
  GetHorizontalScrollerOfRapport := rapport.hScroller;
end;

function GetTailleMaximumOfRapport : SInt32;
begin
  GetTailleMaximumOfRapport := maxTextEditSize;
end;

function GetProchaineAlerteRemplissageRapport : SInt32;
begin
  GetProchaineAlerteRemplissageRapport := rapport.prochaineAlerteRemplissage;
end;

procedure SetProchaineAlerteRemplissageRapport(tailleCritique : SInt32);
begin
  rapport.prochaineAlerteRemplissage := tailleCritique;
end;



procedure UpdateScrollersRapport ;
var firstLine, firstCol : SInt16;
    nbDeLignesVisibles,nbTotalDeLignes : SInt32;
begin
  with rapport do
   if (theText <> NIL) & (vScroller <> NIL) & (hScroller <> NIL) then
    begin
      nbTotalDeLignes := succ(TEGetHeight(0,32000,theText) div vUnit);
      nbDeLignesVisibles := NbLignesVisiblesDansRapport;
      firstLine := succ((TEdecalage - theText^^.destRect.top) div vUnit);

      if (nbTotalDeLignes <= nbDeLignesVisibles) & (firstLine = 1)
        then
          begin
            SetControlValue(vScroller, 1);
            SetControlMaximum(vScroller, 1);
          end
        else
          begin
            SetControlMaximum(vScroller,Max(nbTotalDeLignes-nbDeLignesVisibles+1,firstLine));
            SetControlValue(vScroller, firstLine);
          end;

      firstCol := succ((TEdecalage - TEGetDestRect(theText).left + hUnit - 1) div hUnit);
      SetControlValue(hScroller, firstCol);


   end;
 InvalScrollersRapport;
end;

procedure CalculateViewAndDestRapport;
var height, width: SInt16;
    viewRect,destRect : rect;
begin
    with rapport do
      if (theWindow <> NIL) & (theText <> NIL) then
      begin
         with GetWindowPortRect(rapport.theWindow) do
           begin
              height := (bottom - 15) - (top + TEdecalage) ;
              width := (right - 15) - (left + TEdecalage) ;
           end;

         viewRect := TEGetViewRect(theText);
         viewRect.bottom := viewRect.top + height ;
         viewRect.right := viewRect.left + width ;
         TESetViewRect(theText,viewRect);

         destRect := TEGetDestRect(theText);
         destRect.bottom := destRect.top + height;
         destRect.right := MAXINT_16BITS-100;
         TESetDestRect(theText,destRect);
      end;
end;


var derniereDateDefilementRapport : double_t;

{ Défilement du texte par l'ascenseur ch }
procedure TrackScrollingRapport(ch: ControlHandle; part: SInt16);
var oldValue, newValue: SInt16;
    microTicks : UnsignedWide;
    dateCourante : double_t;
begin
  with rapport do
    if (theText <> NIL) & (ch <> NIL) then
      begin
  	    oldValue := GetControlValue(ch);
  	    newvalue := oldvalue;

  	    MicroSeconds(microTicks);
  	    dateCourante := MicrosecondesToSecondes(microTicks);
  	    if abs(derniereDateDefilementRapport - dateCourante) >= (1.0 / 80.0) then  //  tous les 1/80 de seconde
    	    begin
    	      case part OF
      	      kControlDownButtonPart: if ch = hScroller
      	                      then newValue := oldValue + 2
      	                      else newValue := oldValue + 1;
      	      kControlUpButtonPart:   if ch = hScroller
      	                      then newValue := oldValue - 2
      	                      else newValue := oldValue - 1;
      	      kControlPageDownPart:    if ch = hScroller
      	                      then newValue := oldValue + 10
      	                      else newValue := oldValue + Max(NbLignesVisiblesDansRapport-1,10);
      	      kControlPageUpPart:      if ch = hScroller
      	                      then newValue := oldValue - 10
      	                      else newValue := oldValue - Max(NbLignesVisiblesDansRapport-1,10);
      	      kControlSpecialDocumentTopPart :
      	                           newValue := 0;
      	      kControlSpecialDocumentBottomPart :
      	                           newValue := MAXINT_16BITS;

      	    end; {case}
      	    derniereDateDefilementRapport := dateCourante;
      	  end;

  	    SetControlValue(ch, newValue);
  	    newValue := GetControlValue(ch);
  	    {if newValue <> oldValue then}
  	    if ch = vScroller then TEPinScroll(0, (oldValue - GetControlValue(ch)) * vUnit, theText) else
  	    if ch = hScroller then TEPinScroll((oldValue - GetControlValue(ch)) * hUnit, 0, theText);

      end;
end;

{fonction remplacant TrackControl pour les clics dans le pouce : mise a jour
  simultanee de l'ascenseur et de l'affichage du texte }
function MyTrackControlIndicatorPartRapport(theControl : ControlHandle) : SInt16;
var oldValue, newValue: SInt32;
    horizontal,avecDoubleScroll : boolean;
    minimum,maximum : SInt32;
    ascenseurRect,barreGrisee : rect;
    mouseLoc,oldMouseLoc : Point;
    SourisADejaBouje : boolean;
    tailleDuPouce : SInt32;
    proportion : fixed;
begin

  MyTrackControlIndicatorPartRapport := 0;

  if (theControl <> NIL) & (rapport.theText <> NIL) then
    begin
      SetPortByWindow(GetControlOwner(theControl));
      GetMouse(oldMouseLoc);
      SourisADejaBouje := false;
      HiliteControl(theControl,kControlIndicatorPart);


      avecDoubleScroll := EstUnAscenseurAvecDoubleScroll(theControl,ascenseurRect,barreGrisee,horizontal);
      if horizontal
        then
          begin
            InsetRect(ascenseurRect,-30,-20);
            if SmartScrollEstInstalle(theControl,proportion)
              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.right-barreGrisee.left,1))))
              else TailleDuPouce := 16;
            InsetRect(barreGrisee,tailleDuPouce div 2,0);
          end
        else
          begin
            InsetRect(ascenseurRect,-20,-30);
            if SmartScrollEstInstalle(theControl,proportion)
              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.bottom-barreGrisee.top,1))))
              else TailleDuPouce := 16;
            InsetRect(barreGrisee,0,tailleDuPouce div 2);
          end;
      while StillDown do
        begin
          SetPortByWindow(GetControlOwner(theControl));
          GetMouse(mouseLoc);
          SourisADejaBouje := SourisADejaBouje | (SInt32(mouseLoc) <> SInt32(oldMouseLoc));
          if SourisADejaBouje & (SInt32(mouseLoc) <> SInt32(oldMouseLoc)) then
            begin
	          oldValue := GetControlValue(theControl);
	          minimum := GetControlMinimum(theControl);
	          maximum := GetControlMaximum(theControl);
	          if PtInRect(mouseLoc,ascenseurRect) then
	            begin
	              with barreGrisee do
	                if horizontal
	                  then newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.h-left)) div (right-left)
	                  else newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.v-top)) div (bottom-top);
	              if newValue > maximum then newValue := maximum;
	              if newValue < minimum then newValue := minimum;
	              if newValue <> oldValue then
	                begin
	                  SetControlValue(theControl,newValue);
	                  with rapport do
	                    if horizontal
	                      then TEPinScroll((oldValue - GetControlValue(theControl)) * hUnit, 0, theText)
	                      else TEPinScroll(0, (oldValue - GetControlValue(theControl)) * vUnit, theText);
	                  MyTrackControlIndicatorPartRapport := kControlIndicatorPart;
	                end;
	            end;
            end;
          oldMouseLoc := mouseLoc;
        end;
      HiliteControl(theControl,0);
    end;
  end;


{ Fonction personnelle d'auto-défilement. Identique à celle standard }
{ mais avec mise à jour simultanée des ascenseurs }
function MyClikLoopRapport : boolean;
var where : Point;
       r : Rect;
       clip : RgnHandle;
begin
    GetMouse(where);
    with rapport do
      if (theText <> NIL) then
       if not(PtInRect(where, TEGetViewRect(theText))) then
         begin
            clip := NewRgn;
            GetClip(clip);
            { On annule toute région de limitation, sinon la mise à }
            { jour des ascenseurs est impossible (note technique 82) }
            SetRect(r, -MAXINT_16BITS, -MAXINT_16BITS, MAXINT_16BITS, MAXINT_16BITS);
            ClipRect(r);
            if where.v < TEGetViewRect(theText).top then TrackScrollingRapport(vScroller, kControlUpButtonPart) else
            if where.v > TEGetViewRect(theText).bottom then TrackScrollingRapport(vScroller, kControlDownButtonPart);
            if where.h < TEGetViewRect(theText).left then TrackScrollingRapport(hScroller, kControlUpButtonPart) else
            if where.h > TEGetViewRect(theText).right then TrackScrollingRapport(hScroller, kControlDownButtonPart);
            SetClip(clip);
            DisposeRgn(clip);
         end;
    MyClikLoopRapport := True;  { Toujours renvoyer une valeur vraie }
end;


{ Accumule la région correspondant à l'emplacement des ascenseurs plus celui }
{ de la boîte de taille dans la région de mise à jour de la fenêtre }
procedure InvalScrollersRapport;
var r : rect;
    oldport : grafPtr;
begin
  GetPort(oldport);
  SetPortByWindow(rapport.theWindow);
  r := GetWindowPortRect(rapport.theWindow);
  r.left := r.right - 15;
  InvalRect(r);
  r := GetWindowPortRect(rapport.theWindow);
  r.top := r.bottom - 15;
  InvalRect(r);
  SetPort(oldport);
end;


  { Change la taille de la fenêtre Rapport. Si hSize < 0, cela signifie que }
  { la fenêtre est déjà dans sa nouvelle taille. On ne s'occupe alors que des }
  { problèmes de mise à jour de son contenu }
procedure ChangeWindowRapportSize(hSize,vSize : SInt16);
var r : Rect;
begin
    SetPortByWindow(rapport.theWindow);
    InvalScrollersRapport;
    with rapport do
      begin
          if hSize > 0 then
            begin
              { La taille doit être changée. On s'assure qu'elle sera bien }
              { multiple des lignes et colonnes (voir hUnit) de texte }
              while (vSize - 15 - TEdecalage) MOD vUnit <> 0 do dec(vSize);
              while (hSize - 15 - TEdecalage) MOD hUnit <> 0 do dec(hSize);
              SizeWindow(Rapport.theWindow, hSize, vSize, True);
            end;

          CalculateViewAndDestRapport;
          UpdateScrollersRapport;

          r := GetWindowPortRect(rapport.theWindow);
          InsetRect(r, -1, -1);
          { On déplace les deux ascenseurs à leur nouvel emplacement en }
          { adaptant leur taille. Ils sont redessinés immédiatement }
          MoveControl(vScroller, r.right - 16, r.top);
          SizeControl(vScroller, 16, r.bottom - r.top - 15);
          MoveControl(hScroller, r.left, r.bottom - 16);
          SizeControl(hScroller, r.right - r.left - 15, 16);
          { On accumule uniquement la boîte de taille dans la région de mise }
          { à jour puisque les ascenseurs sont déjà redessinés }
          r.left := r.right - 16;
          r.top := r.bottom - 16;
          InvalRect(r);

      end;
end;



procedure RedrawFenetreRapport;
var oldport: GrafPtr;
    errDebug : OSErr;
begin
  with rapport do
    if (theText <> NIL) & (theWindow <> NIL) then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      GetPort(oldport);
      SetPortByWindow(theWindow);
      MyEraseRect(TEGetViewRect(theText));
      MyEraseRectWithColor(TEGetViewRect(theText),OrangeCmd,blackPattern,'');
      TEUpdate(GetWindowPortRect(rapport.theWindow), theText);
      DrawControls(theWindow);
      DrawGrowIcon(theWindow);
      SetPort(oldport);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
end;


procedure DoUpdateRapport;
var oldport: GrafPtr;
    errDebug : OSErr;
begin
  with rapport do
    if (theText <> NIL) & (theWindow <> NIL) then
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      GetPort(oldport);
      SetPortByWindow(theWindow);
      BeginUpdate(theWindow);
      MyEraseRect(TEGetViewRect(theText));
      MyEraseRectWithColor(TEGetViewRect(theText),OrangeCmd,blackPattern,'');
      TEUpdate(GetWindowPortRect(rapport.theWindow), theText);
      DrawControls(theWindow);
      DrawGrowIcon(theWindow);
      EndUpdate(theWindow);
      SetPort(oldport);
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
end;

procedure DoActivateRapport;
var errDebug : OSErr;
    err : OSErr;
begin
  with rapport do
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      if IsWindowHilited(theWindow) then
        begin
          if (theText <> NIL) then TEActivate(theText);
          HiliteControl(vScroller, 0);
          HiliteControl(hScroller, 0);
          ShowControl(vScroller);
          ShowControl(hScroller);
          DrawGrowIcon(theWindow);

          {activation de la methode d'entree du japonais}
          if docTSMDoc <> NIL then
			      err := ActivateTSMDocument(docTSMDoc);
        end;
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
   end;
end;

procedure DoDeactivateRapport;
var err : OSErr;
    errDebug : OSErr;
begin
  with rapport do
    begin
      errDebug := MPEnterCriticalRegion(gRapportCriticalRegionID,kDurationForever);
      if not(IsWindowHilited(theWindow)) then
        begin
          {desactivation de la methode d'entree du japonais}
          if docTSMDoc <> NIL then
			      err := DeactivateTSMDocument(docTSMDoc);

          if (theText <> NIL) then TEDeactivate(theText);
          HiliteControl(vScroller, 255);
          HiliteControl(hScroller, 255);
          HideControl(vScroller);
          HideControl(hScroller);
          DrawGrowIcon(theWindow);
        end;
      errDebug := MPExitCriticalRegion(gRapportCriticalRegionID);
    end;
end;


function GetLongueurMessageBienvenueDansCassio : SInt16;
begin
  GetLongueurMessageBienvenueDansCassio := longueurMessageBienvenueDansCassio;
end;

procedure SetLongueurMessageBienvenueDansCassio(longueur : SInt16);
begin
  longueurMessageBienvenueDansCassio := longueur;
end;


procedure FinRapport;
begin
  PositionnePointDinsertion(GetTailleRapport);
  {PositionnePointDinsertion(MAXINT_16BITS);}
end;

procedure VoirLeDebutDuRapport;
begin
 {SetDeroulementAutomatiqueDuRapport(true);
  PositionnePointDinsertion(0);
  UpdateScrollersRapport;
  if analyseRetrograde.encours then
    SetDeroulementAutomatiqueDuRapport(false);}

  TrackScrollingRapport(rapport.vscroller,kControlSpecialDocumentTopPart);
end;

procedure VoirLaFinDuRapport;
begin
 {SetDeroulementAutomatiqueDuRapport(true);
  PositionnePointDinsertion(MAXINT_16BITS);
  UpdateScrollersRapport;
  if analyseRetrograde.encours then
    SetDeroulementAutomatiqueDuRapport(false);}

  TrackScrollingRapport(rapport.vscroller,kControlSpecialDocumentBottomPart);
end;







procedure ViewRectAGaucheRapport;
var offset : SInt16;
begin
  with rapport do
    if (theText <> NIL) then
    begin
      offset := TEdecalage - TEGetDestRect(theText).left;
      if offSet <> 0 then
        begin
          TEScroll(-offset, 0, theText);
          UpdateScrollersRapport;
        end;
    end;
end;




function NbLignesVisiblesDansRapport : SInt16;
begin
    with GetWindowPortRect(rapport.theWindow) do
      NbLignesVisiblesDansRapport := ((bottom - 15) - (top + TEdecalage)) div vUnit;
end;


function NbColonnesVisiblesDansRapport : SInt16;
begin
    with GetWindowPortRect(rapport.theWindow) do
      NbColonnesVisiblesDansRapport := ((right - 15) - (left + TEdecalage)) div hUnit;
end;


procedure DetruireSelectionDansRapport;
begin
  if (rapport.theText <> NIL) then
    TEDelete(rapport.theText);
end;

procedure SetDebutSelectionRapport(debut : SInt32);
begin
  if (rapport.theText <> NIL) then
    rapport.theText^^.selStart := debut;
end;

procedure SetFinSelectionRapport(fin : SInt32);
begin
  if (rapport.theText <> NIL) then
    rapport.theText^^.selEnd := fin;
end;

procedure FrappeClavierDansRapport(whichChar : char);
begin
  if (rapport.theText <> NIL) then
    TEKey(whichChar,rapport.theText);
end;


procedure EffaceDernierCaractereDuRapportSync(scrollerSynchronisation : boolean);
begin
  if (rapport.theText <> NIL) then
    begin
      PositionnePointDinsertion(GetTailleRapport);
      TEKey(chr(8),rapport.theText);
      if scrollerSynchronisation then UpdateScrollersRapport;
    end;
end;

procedure EffaceDernierCaractereDuRapport;
begin
  EffaceDernierCaractereDuRapportSync(true);
end;

procedure PositionnePointDinsertion(index : SInt32);
begin
  if (rapport.theText <> NIL) then
    begin
      TESetSelect(index,index,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

function GetPositionPointDinsertion : SInt32;
begin
  if SelectionRapportNonVide & (rapport.theText <> NIL)
    then GetPositionPointDinsertion := 2000000000-1   {2000000000, used to be MaxLongint}
    else GetPositionPointDinsertion := GetDebutSelectionRapport;
end;


procedure SetDeroulementAutomatiqueDuRapport(flag : boolean);
begin
  if (rapport.theText <> NIL) then
    begin
      TEAutoView(flag, rapport.theText);
      rapport.deroulementAutomatique := flag;
    end;
end;

function GetDeroulementAutomatiqueDuRapport : boolean;
begin
  GetDeroulementAutomatiqueDuRapport := rapport.deroulementAutomatique;
end;

function FindStringInRapport(s : String255; from,direction : SInt32; var positionTrouvee : SInt32) : boolean;
var len,depart,k,tailleRapport : SInt32;
    texteRapportHdl : CharArrayHandle;
begin

  FindStringInRapport := false;
  positionTrouvee := 0;

  with rapport do
    if (theText <> NIL) then
	    begin
			  len := LENGTH_OF_STRING(s);
			  if (len > 0) then
			    begin
					  texteRapportHdl := GetRapportTextHandle;
					  tailleRapport := GetTailleRapport;

					  if (from < 0) then from := 0;
					  if (from > tailleRapport) then from := tailleRapport;
					  if (direction <  0) then direction := -1;
					  if (direction >= 0) then direction := +1;

					  depart := from;

					  while (depart >= 0) & ((depart + len - 1) <= tailleRapport) do
					    begin
							  k := 0;
							  while (k < len) & (texteRapportHdl^^[depart+k] = s[k+1]) do
							    inc(k);

							  if (k = len) then
							    begin
							      FindStringInRapport := true;
							      positionTrouvee := depart;

							      {TESetSelect(depart,depart+len,rapport.theText);
							      AttendFrappeClavier;}
							      exit(FindStringInRapport);

							    end;

							  depart := depart + direction;
							end;
					end;
		  end;
end;


procedure SetAutoVidageDuRapportDansImplementation(flag : boolean);
begin
  rapport.autoVidageDuRapport := flag;
end;

function GetAutoVidageDuRapportDansImplementation : boolean;
begin
  GetAutoVidageDuRapportDansImplementation := rapport.autoVidageDuRapport;
end;

procedure SetEcritToutDansRapportLogDansImplementation(flag : boolean);
begin
  rapport.ecritToutDansRapportLog := flag;
end;

function GetEcritToutDansRapportLogDansImplementation : boolean;
begin
  GetEcritToutDansRapportLogDansImplementation := rapport.ecritToutDansRapportLog;
end;



procedure ChangeFontDansRapport(whichFont : SInt16);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsFont := whichFont;
      MyTESetStyle(doFont,newStyle,false,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontFaceDansRapport(whichStyle : StyleParameter);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin

    {$IFC (DEFINED __GPC__) AND NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
      newStyle.tsFace := whichStyle * 256;
    {$ELSEC}
      newStyle.tsFace := whichStyle;
    {$ENDC}


      MyTESetStyle(doFace,newStyle,false,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontSizeDansRapport(whichSize : SInt16);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsSize := whichSize;
      MyTESetStyle(doSize,newStyle,false,rapport.theText);
      UpdateScrollersRapport;
    end;
end;

procedure ChangeFontColorDansRapport(whichColor : SInt16);
var theRGBColor : RGBColor;
begin
  if not(sousEmulatorSousPC) then
    begin
      theRGBColor := CouleurCmdToRGBColor(whichColor);
      ChangeFontColorRGBDansRapport(theRGBColor);
    end;
end;

procedure ChangeFontColorRGBDansRapport(whichColor : RGBColor);
var newStyle : TextStyle;
begin
  if not(sousEmulatorSousPC) & (rapport.theText <> NIL) then
    begin
      newStyle.tsColor := whichColor;
      MyTESetStyle(doColor,newStyle,false,rapport.theText);
      {TEUpdate(GetWindowPortRect(rapport.theWindow), rapport.theText);}
      //UpdateScrollersRapport;
    end;
end;





procedure TextNormalDansRapport;
begin
  ChangeFontFaceDansRapport(normal);
  ChangeFontColorDansRapport(NoirCmd);
  ChangeFontDansRapport(gCassioRapportNormalFont);
  ChangeFontSizeDansRapport(gCassioRapportNormalSize);
end;





END.








