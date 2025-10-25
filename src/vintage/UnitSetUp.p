UNIT UnitSetUp;



INTERFACE







 USES UnitDefCassio;







procedure SetUp;
procedure EcranStandardSetUp;





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, Appearance, Sound, QuickdrawText, Fonts, MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitAffichagePlateau, UnitTroisiemeDimension, UnitBufferedPICT, UnitGeometrie, UnitDialog, MyMathUtils
    , MyStrings, UnitCarbonisation, UnitFenetres, UnitCurseur, UnitCourbe, SNEvents, UnitRetrograde, UnitStrategie
    , UnitJeu, UnitSuperviseur, UnitEvaluation, UnitAffichageReflexion, UnitEvenement, UnitServicesMemoire
    , UnitPositionEtTrait, UnitGestionDuTemps, UnitCFNetworkHTTP, UnitZoo, UnitBaseNouveauFormat, UnitListe
     ;
{$ELSEC}
    ;
    {$I prelink/SetUp.lk}
{$ENDC}


{END_USE_CLAUSE}








const annulerID = 1;
      SetUpID = 2;
      effacageID = 3;
      inversageID = 4;
      evaluerID = 5;


const fakeSquare = 55;

var gSetUpData :
      record
        noteRect : rect;
        rectPions : rect;
        rectCouleur : array[pionNoir..pionBlanc] of rect;
        setUpPlat : plateauOthello;
        SetUpJouable : plBool;
        SetUpMove : plBool;
        setUpFront : InfoFront;
        annulerRect,SetUpRect,effacageRect,inversageRect,evaluerRect : rect;
        veutAnnuler,veutSetUp,veutEffacer,veutInverser,veutEvaluer : boolean;
        doitDistinguerDefaultBouton : boolean;
        margeDansLesBoutons : SInt16;
      end;




procedure EffaceNoteRect;
begin
  with gSetUpData do
    begin
      EraseRectDansWindowPlateau(gSetUpData.noteRect);
      if avecSystemeCoordonnees and not(CassioEstEn3D)
        then DessineBordureDuPlateau2D(kBordureDuBas);
      InsetRect(rectPions,-1,-1);
      PenPat(whitePattern);
      PenSize(1,1);
      FrameRect(rectPions);
      InsetRect(rectPions,1,1);
      PenNormal;
    end;
end;


procedure DessinePionSetUp(i,j,couleur : SInt16);
var temp : SInt16;
    deplacementRepere : Point;
begin
  with gSetUpData do
    begin

      EffaceNoteRect;

      if (i >= 1) and (i <= 8) and (j >= 1) and (j <= 8)
        then
          DessinePion(i*10+j,couleur)
        else
          begin
            temp := GetValeurDessinEnTraceDeRayon(fakeSquare);
            InvalidateDessinEnTraceDeRayon(fakeSquare);

            if CassioEstEn3D
              then
                begin
                  case couleur of
                    pionVide  : deplacementRepere := rectCouleur[pionVide].topLeft;
                    pionBlanc : deplacementRepere := rectCouleur[pionBlanc].topLeft;
                    pionNoir  : deplacementRepere := rectCouleur[pionNoir].topLeft;
                    otherwise   deplacementRepere := MakePoint(-1000,-1000);
                  end; {case}
                  deplacementRepere.h := deplacementRepere.h-GetBoundingRect3D(fakeSquare).left;
                  deplacementRepere.v := deplacementRepere.v-GetBoundingRect3D(fakeSquare).top;
                end
              else
                begin
                  deplacementRepere.h := (i-(fakeSquare mod 10))*GetTailleCaseCourante;
                  deplacementRepere.v := (j-(fakeSquare div 10))*GetTailleCaseCourante;
                end;

            SetOrigin(-deplacementRepere.h,-deplacementRepere.v);
            DessinePion{2D}(fakeSquare,couleur);
            SetOrigin(0,0);

            SetValeurDessinEnTraceDeRayon(fakeSquare,temp);
          end;
  end;
end;


procedure PosePionSetUp(x,couleur : SInt16);
begin
  with gSetUpData do
    begin
      EffaceNoteRect;
      setUpPlat[x] := couleur;
      DessinePion(x,couleur);
    end;
end;

procedure DessineCadreAutourPionCouleurEnCours(quelPion : SInt16);
begin
  with gSetUpData do
    begin
      PenSize(3,3);
      PenPat(blackPattern);
      ForeColor(BlackColor);
      BackColor(WhiteColor);
      FrameRect(rectCouleur[quelPion]);
      PenNormal;
    end;
end;

procedure EffaceCadreAutourPionCouleurEnCours(quelPion : SInt16);
begin
  with gSetUpData do
    begin
      PenSize(3,3);
      PenPat(whitePattern);
      ForeColor(BlackColor);
      BackColor(WhiteColor);
      FrameRect(rectCouleur[quelPion]);
      PenNormal;
    end;
end;


procedure DessinePionChoixSetUp(couleur : SInt16);
begin
  with gSetUpData do
    begin
      case couleur of
        pionNoir:
          begin
            if not(gCouleurOthellier.estUneImage) then
               begin
                 EffaceCadreAutourPionCouleurEnCours(pionNoir);
                 DessinePionSetUp(10,7,pionEffaceCaseLarge);
               end;
             DessinePionSetUp(10,7,pionNoir);
          end;
        pionBlanc:
          begin
            if not(gCouleurOthellier.estUneImage)
               then
    	           begin
    	             EffaceCadreAutourPionCouleurEnCours(pionBlanc);
    	             DessinePionSetUp(10,6,pionEffaceCaseLarge);
    	           end;
             DessinePionSetUp(10,6,pionBlanc);
          end;
        pionVide:
          begin
            if not(gCouleurOthellier.estUneImage) then
               begin
                 EffaceCadreAutourPionCouleurEnCours(pionVide);
                 DessinePionSetUp(10,8,pionEffaceCaseLarge);
               end;
             DessinePionSetUp(10,8,pionVide);
          end;
      end; {case}
    end;
end;


procedure SetDrawDefaultSetupBoutonInBlue(flag : boolean);
begin
  gSetUpData.doitDistinguerDefaultBouton := flag;
end;


function GetDrawDefaultSetupBoutonInBlue : boolean;
begin
  GetDrawDefaultSetupBoutonInBlue := gSetUpData.doitDistinguerDefaultBouton;
end;


procedure SetBoutonSetUp(left,top,bottom : SInt32; s : String255; boutonID : SInt16);
var unRect : rect;
begin
  with gSetUpData do
    begin
      margeDansLesBoutons := 30;

      if gIsRunningUnderMacOSX then
        EraseRectDansWindowPlateau(GetBoutonRectParControlManager(left-2,top-2,bottom+4,margeDansLesBoutons+4,s));

      if (BoutonID = annulerID) and gIsRunningUnderMacOSX and GetDrawDefaultSetupBoutonInBlue
        then DessineBoutonParControlManager(kThemeStatePressed,left,top,bottom,margeDansLesBoutons,s,unRect)
        else DessineBoutonParControlManager(kThemeStateActive,left,top,bottom,margeDansLesBoutons,s,unRect);

      case BoutonID of
        annulerID   : annulerRect   := unRect;
        SetUpID     : SetUpRect     := unRect;
        effacageID  : effacageRect  := unRect;
        inversageID : inversageRect := unRect;
        evaluerID   : evaluerRect   := unRect;
      end;
    end;
end;


procedure DessineBoutonsSetUp(drawDefaultInBlue : boolean);
var hautBouton,interBouton : SInt32;
    milBouton,gaucheBouton : SInt32;
    s : String255;
    boutonsDisposesVerticalement : boolean;
begin
  with gSetUpData do
    begin

      SetDrawDefaultSetupBoutonInBlue(drawDefaultInBlue);

      if CassioEstEn3D
        then
          begin
            boutonsDisposesVerticalement := false;
            interBouton := 135;
            hautBouton := 20;
            gaucheBouton := GetBoundingRect3D(84).right - (interBouton * 2) - 36;

            //WritelnNumDansRapport('gaucheBouton = ',gaucheBouton);

            milBouton := PosVDemande+15;
          end
        else
          begin
            boutonsDisposesVerticalement := true;
            hautBouton := Min(20,GetTailleCaseCourante-3);

            interBouton := GetTailleCaseCourante-2;
            interBouton := Min(interBouton,30);
            if interBouton <= hautBouton+3 then interBouton := hautBouton+3;

            gaucheBouton := posHNoirs+4;
            milBouton := posVNoirs + 4*interBouton;
          end;

      hautBouton := hautBouton div 2;


      if boutonsDisposesVerticalement
        then
          begin
            s := ReadStringFromRessource(TextesSetUpID,5);
            SetBoutonSetUp(gaucheBouton,milBouton-hautBouton,milBouton+hautBouton,s,annulerID);
            s := ReadStringFromRessource(TextesSetUpID,6);
            SetBoutonSetUp(gaucheBouton,milBouton-interBouton-hautBouton,milBouton-interBouton+hautBouton,s,SetUpID);
            s := ReadStringFromRessource(TextesSetUpID,7);
            SetBoutonSetUp(gaucheBouton,milBouton-2*interBouton-hautBouton,milBouton-2*interBouton+hautBouton,s,effacageID);
            s := ReadStringFromRessource(TextesSetUpID,8);
            SetBoutonSetUp(gaucheBouton,milBouton-3*interBouton-hautBouton,milBouton-3*interBouton+hautBouton,s,inversageID);
            s := ReadStringFromRessource(TextesSetUpID,9);
            SetBoutonSetUp(gaucheBouton,milBouton-4*interBouton-hautBouton,milBouton-4*interBouton+hautBouton,s,evaluerID);
          end
        else
          begin
            s := ReadStringFromRessource(TextesSetUpID,5);
            SetBoutonSetUp(gaucheBouton + 4*interBouton , milBouton-hautBouton,milBouton+hautBouton,s,annulerID);
            s := ReadStringFromRessource(TextesSetUpID,6);
            SetBoutonSetUp(gaucheBouton + 3*interBouton , milBouton-hautBouton,milBouton+hautBouton,s,SetUpID);
            s := ReadStringFromRessource(TextesSetUpID,7);
            SetBoutonSetUp(gaucheBouton + 2*interBouton , milBouton-hautBouton,milBouton+hautBouton,s,effacageID);
            s := ReadStringFromRessource(TextesSetUpID,8);
            SetBoutonSetUp(gaucheBouton + 1*interBouton , milBouton-hautBouton,milBouton+hautBouton,s,inversageID);
            s := ReadStringFromRessource(TextesSetUpID,9);
            SetBoutonSetUp(gaucheBouton + 0*interBouton , milBouton-hautBouton,milBouton+hautBouton,s,evaluerID);
          end;
    end;
end;


function CalculePionSetUp2D(i,j : SInt16) : rect;
var rectangle : rect;
    a,b : SInt32;
begin
  with gSetUpData do
    begin
      a := aireDeJeu.left+2+GetTailleCaseCourante*(i-1);
      b := aireDeJeu.top+2+GetTailleCaseCourante*(j-1);
      SetRect(rectangle,a,b,a+GetTailleCaseCourante-3,b+GetTailleCaseCourante-3);
      InsetRect(rectangle,-2,-2);
      if gCouleurOthellier.estUneImage then
        begin
          dec(rectangle.right);
          dec(rectangle.bottom);
        end else
      if not(retirerEffet3DSubtilOthellier2D) then
        begin
          inc(rectangle.top);
          inc(rectangle.left);
        end;
      CalculePionSetUp2D := rectangle;
    end;
end;


procedure CalculerPositionsPionsSetUp;
var myRect : rect;
    basOthellier : SInt32;
    largeurFenetre : SInt32;
begin
  with gSetUpData do
    begin
      if CassioEstEn3D
        then
          begin
            myRect := GetBoundingRect3D(fakeSquare);
            with myRect do
              begin
                largeurFenetre := GetWindowPortRect(wPlateauPtr).right - GetWindowPortRect(wPlateauPtr).left;

    		        OffsetRect(myRect,-left,-top);
    		        OffsetRect(myRect,largeurFenetre,0);
    		        OffsetRect(myRect,-(right - left),0);
    		        OffsetRect(myRect,-10,0);

    		        rectCouleur[pionBlanc] := MakeRect(5 + left,5         ,5+right,5+bottom);
    					  rectCouleur[pionNoir]  := MakeRect(5 + left,5+bottom  ,5+right,5+2*bottom);
    					  rectCouleur[pionVide]  := MakeRect(5 + left,5+2*bottom,5+right,5+3*bottom);
    					end;
          end
        else
          begin
    			  rectCouleur[pionBlanc] := CalculePionSetUp2D(10,6);
    			  rectCouleur[pionNoir]  := CalculePionSetUp2D(10,7);
    			  rectCouleur[pionVide]  := CalculePionSetUp2D(10,8);
    			end;

      if CassioEstEn3D
        then
          begin
            basOthellier := GetBoundingRect3D(84).bottom ;
            SetRect(gSetUpData.noteRect,40,basOthellier + 7,250,basOthellier + 19);
          end
        else SetRect(gSetUpData.noteRect,40,aireDeJeu.bottom+1,250,aireDeJeu.bottom+13);
   end;
end;


procedure EcranStandardSetUp;
var i,j : SInt16;
    oldPort : grafPtr;
    unRect : rect;
begin
  with gSetUpData do
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      unRect := GetWindowPortRect(wPlateauPtr);
      EraseRectDansWindowPlateau(unRect);

      if CassioEstEn3D
        then
           DessinePlateau3D(true)
        else
          if avecSystemeCoordonnees
            then DessinePlateau2D(8,GetTailleCaseCourante,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,true)
            else DessinePlateau2D(8,GetTailleCaseCourante,PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,true);
      CalculerPositionsPionsSetUp;
      UnionRect(gSetUpData.rectCouleur[pionBlanc],gSetUpData.rectCouleur[pionNoir],gSetUpData.rectPions);
      UnionRect(gSetUpData.rectPions,gSetUpData.rectCouleur[pionVide],gSetUpData.rectPions);
      InsetRect(gSetUpData.rectPions,-3,-3);
      FillRect(gSetUpData.rectPions,whitePattern);
      InsetRect(gSetUpData.rectPions,1,1);
      {EraseRectDansWindowPlateau(gSetUpData.rectPions);}
      FrameRect(gSetUpData.rectPions);
      DessinePionChoixSetUp(pionBlanc);
      DessinePionChoixSetUp(pionNoir);
      DessinePionChoixSetUp(pionVide);
      DessineCadreAutourPionCouleurEnCours(couleurEnCoursPourSetUp);
      DessineBoutonsSetUp(true);
      for i := 1 to 8 do
      for j := 1 to 8 do
        begin
          InvalidateDessinEnTraceDeRayon(i+10*j);
          PosePionSetUp(i+10*j,setUpPlat[i+10*j]);
        end;
      DessineBoiteDeTaille(wPlateauPtr);
      AjusteCurseur;
      SetPort(oldPort);
  end;
end;


procedure SetUp;
var x,i,j : SInt16;
    tempoAireDeJeuTop,tempoAireDeJeuLeft : SInt16;
    QuitterSetUp : boolean;
    mouseLoc : Point;
    veutPosePion : boolean;
    testOKsetUp : boolean;
    mobilite : SInt32;
    aux : SInt16;
    CoulEvaluer : SInt16;
    note : SInt16;
    nbEvalsRecursives : SInt32;
    nbreDePionsNoir,nbreDePionsBlanc : SInt16;
    nbreCoupsEval : SInt16;
    s : String255;
    oldPort : grafPtr;
    whichWindow : WindowPtr;
    TickPourDoubleClic : SInt32;
    DernierPionPose,CouleurAvantClic : SInt16;
    nextTick : SInt32;


function AppuieBoutonSetUp(BoutonID : SInt16; mouseLoc : Point) : boolean;
begin
  with gSetUpData do
    begin
      DessineBoutonsSetUp(false);
      case BoutonID of
        annulerID   : AppuieBoutonSetUp := AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,5),annulerRect  ,margeDansLesBoutons,mouseLoc);
        SetUpID     : AppuieBoutonSetUp := AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,6),SetUpRect    ,margeDansLesBoutons,mouseLoc);
        effacageID  : AppuieBoutonSetUp := AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,7),effacageRect ,margeDansLesBoutons,mouseLoc);
        inversageID : AppuieBoutonSetUp := AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,8),inversageRect,margeDansLesBoutons,mouseLoc);
        evaluerID   : AppuieBoutonSetUp := AppuieBoutonParControlManager(ReadStringFromRessource(TextesSetUpID,9),evaluerRect  ,margeDansLesBoutons,mouseLoc);
      end;
      DessineBoutonsSetUp(true);
    end;
end;




procedure ChangeCouleurEnCours(nouvelleCouleur : SInt16);
begin
   case couleurEnCoursPourSetUp of
     pionBlanc : DessinePionChoixSetUp(pionBlanc);
     pionNoir  : DessinePionChoixSetUp(pionNoir);
     pionVide  : DessinePionChoixSetUp(pionVide);
   end; {case}
   DessineCadreAutourPionCouleurEnCours(nouvelleCouleur);
   couleurEnCoursPourSetUp := nouvelleCouleur;
   AjusteCurseur;
end;


procedure ChoixCouleur(loc : Point);
var choix : SInt16;
begin
  with gSetUpData do
    begin
      if PtInRect(loc,rectPions) then
       begin
        if PtInRect(loc,rectCouleur[pionBlanc])
         then choix := pionBlanc
         else
           if PtInRect(loc,rectCouleur[pionNoir])
              then choix := pionNoir
              else
                if PtInRect(loc,rectCouleur[pionVide])
                    then choix := pionVide
                       else choix := couleurEnCoursPourSetUp;
        ChangeCouleurEnCours(choix);
       end;
   end;
end;

procedure PlateauVideSetUp;
var i,j : SInt16;
begin
  for i := 1 to 8 do
  for j := 1 to 8 do
    PosePionSetUp(i+10*j,pionVide);
end;

procedure InversePlateauSetUp;
var i,j : SInt16;
begin
  with gSetUpData do
    begin
      for i := 1 to 8 do
      for j := 1 to 8 do
        PosePionSetUp(i+10*j,-setUpPlat[i+10*j]);
    end;
end;


procedure UpdateEventsSetUp;
  var oldport : grafPtr;
      myWindow : WindowPtr;
      visibleRgn : RgnHandle;
  begin
    GetPort(oldport);
    myWindow := WindowPtr(theEvent.message);
    SetPortByWindow(myWindow);
    BeginUpdate(myWindow);
    if myWindow = wPlateauPtr
      then
        begin
          visibleRgn := NewRgn;
          EcranStandard(GetWindowVisibleRegion(wPlateauPtr,visibleRgn),enSetUp);
          DisposeRgn(visibleRgn);
        end
      else
    if myWindow = wCourbePtr
       then
         begin
           DessineCourbe(kCourbeColoree,'UpdateEventsSetUp');
           DessineSliderFenetreCourbe;
         end;
    EndUpdate(myWindow);
    SetPort(oldport);
  end;

procedure TraiteSourisSetUp;
var i : SInt16;
    {tickrapidite,nbEssaiRapidite,Xrapidite,tempRapidite,coulrapidite,noterapidite : SInt32;}
    fooPourDelai : UInt32;
begin
  with gSetUpData do
    begin
     mouseLoc := theEvent.where;
     GetPort(oldPort);
     SetPortByWindow(wPlateauPtr);
     GlobalToLocal(mouseLoc);
     if (mouseLoc.h >= GetWindowPortRect(wPlateauPtr).right-16) and (mouseLoc.v >= GetWindowPortRect(wPlateauPtr).bottom-16)
        then
          DoGrowWindow(wPlateauPtr,theEvent)
        else
          begin
            veutSetUp := false;
            veutEffacer := false;
            veutAnnuler := false;
            veutEvaluer := false;
            veutInverser := false;

            if PtInPlateau(mouseLoc,x) then
              begin
                if ((theEvent.when-TickPourDoubleClic) < 20) and (DernierPionPose = x)
                  { doubleclic ?}
                  then
                    begin
                      veutPosePion := true;
                      Case couleurEnCoursPourSetUp of
                        pionNoir:
                         Case CouleurAvantClic of
                           pionNoir  : PosePionSetUp(x,pionBlanc);
                           pionBlanc : PosePionSetUp(x,pionNoir);
                           pionVide  : PosePionSetUp(x,pionNoir);
                         end;
                        pionBlanc:
                         Case CouleurAvantClic of
                           pionBlanc : PosePionSetUp(x,pionNoir);
                           pionNoir  : PosePionSetUp(x,pionBlanc);
                           pionVide  : PosePionSetUp(x,pionBlanc);
                         end;
                        pionVide:
                         Case CouleurAvantClic of
                           pionVide  : PosePionSetUp(x,pionNoir);
                           pionNoir  : PosePionSetUp(x,pionBlanc);
                           pionBlanc : PosePionSetUp(x,pionNoir);
                         end;
                      end;
                      CouleurAvantClic := setUpPlat[x];
                      DernierPionPose := x;
                    end
                  else
                    begin
                      veutPosePion := true;
                      DernierPionPose := x;
                      CouleurAvantClic := setUpPlat[x];
                      if setUpPlat[x] <> couleurEnCoursPourSetUp then PosePionSetUp(x,couleurEnCoursPourSetUp);
                      while Button {and veutPosePion} do
                        begin
                          GetMouse(mouseLoc);
                          veutPosePion := PtInPlateau(mouseLoc,x);
                          if veutPosePion then
                              if setUpPlat[x] <> couleurEnCoursPourSetUp then
                                begin
                                  PosePionSetUp(x,couleurEnCoursPourSetUp);
                                  DernierPionPose := x;
                                end;
                          ShareTimeWithOtherProcesses(2);
                        end;
                    end;
                TickPourDoubleClic := theEvent.when;
              end
            else
            if PtInRect(mouseLoc,annulerrect) then
              begin
                veutAnnuler := AppuieBoutonSetUp(annulerID,mouseLoc);
              end
            else
             if PtInRect(mouseLoc,SetUprect) then
              begin
                veutsetUp := AppuieBoutonSetUp(SetUpID,mouseLoc);
                if veutSetUp and PeutArreterAnalyseRetrograde then
                  begin
                    testOKsetUp := true;
                    {testOKsetUp := VerificationConnexiteOK(setUpPlat);}
                    testOKsetUp := VerificationNbreMinimalDePions(setUpPlat,4);{au moins quatre pions ?}
                    if not(testOKsetUp)
                      then
                        begin
                          if avecSon then SysBeep(10);
                          veutSetUp := false;
                        end
                      else
                        begin
                          PlaquerPosition(setUpPlat,0,kNoFlag);
                          CommentaireSolitaire^^ := '';
                          ParamDiagPositionFFORUM.CommentPositionFFORUM^^ := '';
                          ParamDiagPartieFFORUM.titreFFORUM^^ := '';
                        end;
                  end;
              end
             else
              if PtInRect(mouseLoc,effacageRect) then
              begin
                veuteffacer := AppuieBoutonSetUp(effacageID,mouseLoc);
                if veutEffacer then PlateauVideSetUp;
              end
              else
               if PtInRect(mouseLoc,inversageRect) then
                 begin
                   veutinverser := AppuieBoutonSetUp(inversageID,mouseLoc);
                   if veutinverser then InversePlateauSetUp;
                 end
            else
             if PtInRect(mouseLoc,evaluerrect) then
              begin
                veutevaluer := AppuieBoutonSetUp(evaluerID,mouseLoc);
                if veutevaluer then
                  begin
                    testOKsetUp := true;
                    {testOKsetUp := VerificationConnexiteOK(setUpPlat);}
                    testOKsetUp := VerificationNbreMinimalDePions(setUpPlat,4);{au moins quatre pions ?}
                    if not(testOKsetUp) then
                      begin
                        if avecSon then SysBeep(10);
                        veutevaluer := false;
                      end
                      else
                      begin
                        for i := 0 to 99 do
                            if interdit[i] then setUpPlat[i] := PionInterdit;
                        nbreDePionsNoir := 0;
                        nbreDePionsBlanc := 0;
                        for i := 1 to 64 do
                          begin
                            aux := setUpPlat[othellier[i]];
                            if aux = pionNoir then nbreDePionsNoir := nbreDePionsNoir+1;
                            if aux = pionBlanc then nbreDePionsBlanc := nbreDePionsBlanc+1;
                          end;
                        nbreCoupsEval := nbreDePionsNoir+nbreDePionsBlanc-4;
                        CarteJouable(setUpPlat,SetUpJouable);
                        if odd(nbreCoupsEval) then CoulEvaluer := pionBlanc else CoulEvaluer := pionNoir;
                        if DoitPasser(CoulEvaluer,setUpPlat,SetUpJouable) then
                          begin
                            if DoitPasser(-CoulEvaluer,setUpPlat,SetUpJouable) then
                                begin
                                  CoulEvaluer := pionVide;
                                end
                              else
                                CoulEvaluer := -CoulEvaluer;
                          end;
                        Superviseur(nbreCoupsEval);
                        if CoulEvaluer <> pionVide then
                         begin
                           Calcule_Valeurs_Tactiques(setUpPlat,true);
                           CarteMove(CoulEvaluer,setUpPlat,setUpMove,mobilite);
                           CarteFrontiere(setUpPlat,SetUpFront);
                           note := -penalitePourTraitAff
                                 +Evaluation(setUpPlat,CoulEvaluer,nbreDePionsBlanc,nbreDePionsNoir,
                                             SetUpJouable,SetUpFront,true,-30000,30000,nbEvalsRecursives);
                         end
                         else
                         begin
                           CoulEvaluer := pionNoir;
                           note := 100*(nbreDePionsNoir-nbreDePionsBlanc);
                         end;


                         s := NoteEnString(note,true,1,2);
                         case CoulEvaluer of
                           pionNoir    : s := ReadStringFromRessource(TextesSetUpID,10)+s;
                           pionBlanc   : s := ReadStringFromRessource(TextesSetUpID,11)+s;
                         end;
                         TextSize(12);
                         TextFont(systemFont);
                         TextMode(srcBic);
                         TextFace(normal);
                         Moveto(gSetUpData.noteRect.left,gSetUpData.noteRect.bottom-2);
                         MyDrawString(s);

                         if not(CassioEstEn3D) then
                           begin
		                         for i := 1 to 8 do DessinePion(casepetitcentre[i],petitpion);
		                         Delay(30,fooPourDelai);
		                         for i := 1 to 8 do DessinePion(casepetitcentre[i],petitpion);
		                       end;

                      end;
                  end;
              end
               else
                if PtInRect(mouseLoc,rectPions) then
                  ChoixCouleur(mouseLoc);



            QuitterSetUp := veutSetUp or VeutAnnuler or Quitter;
          end;
    SetPort(oldPort);
  end;
end;

procedure TraiteKeyDownSetUp;
  var ch : char;
  begin
    with theEvent do
      begin
        ch := chr(BAnd(message,charCodemask));
        if BAnd(modifiers,cmdKey) <> 0
          then
            begin
              TraiteOneEvenement;
            end
          else
           begin
             if ch = chr(FlecheHautKey) then  {fleche en haut}
               if couleurEnCoursPourSetUp = pionVide then ChangeCouleurEnCours(pionNoir) else
               if couleurEnCoursPourSetUp = pionNoir then ChangeCouleurEnCours(pionBlanc) else
               if couleurEnCoursPourSetUp = pionBlanc then ChangeCouleurEnCours(pionVide);
             if ch = chr(FlecheBasKey) then  {fleche en bas}
               if couleurEnCoursPourSetUp = pionVide then ChangeCouleurEnCours(pionBlanc) else
               if couleurEnCoursPourSetUp = pionBlanc then ChangeCouleurEnCours(pionNoir) else
               if couleurEnCoursPourSetUp = pionNoir then ChangeCouleurEnCours(pionVide);
             if ch = chr(EscapeKey) then humainVeutAnnuler := true;

           end;
      end;
  end;



begin {SetUp}
  with gSetUpData do
    begin
      TickPourDoubleClic := TickCount-1000;
      InvalidateAllCasesDessinEnTraceDeRayon;
      DernierPionPose := 0;
      InitCursor;
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      EffaceReflexion(true);
      QuitterSetUp := false;
      humainVeutAnnuler := false;
      tempoAireDeJeuLeft := aireDeJeu.left;
      tempoAireDeJeuTop := aireDeJeu.top;
      if CassioEstEn3D
         then DessinePlateau3D(true)
         else
           if avecSystemeCoordonnees
             then DessinePlateau2D(8,GetTailleCaseCourante,PositionCoinAvecCoordonnees,PositionCoinAvecCoordonnees,true)
             else DessinePlateau2D(8,GetTailleCaseCourante,PositionCoinSansCoordonnees,PositionCoinSansCoordonnees,true);
      MemoryFillChar(@setUpPlat,sizeof(setUpPlat),chr(0));
      for i := 0 to 99 do
        if interdit[i] then setUpPlat[i] := PionInterdit;

      CalculerPositionsPionsSetUp;
      UnionRect(rectCouleur[pionBlanc],rectCouleur[pionNoir],rectPions);
      UnionRect(rectPions,rectCouleur[pionVide],rectPions);
      InsetRect(rectPions,-3,-3);
      FillRect(rectPions,whitePattern);
      InsetRect(rectPions,1,1);
      {EraseRectDansWindowPlateau(rectPions);}
      FrameRect(rectPions);
      DessinePionChoixSetUp(pionBlanc);
      DessinePionChoixSetUp(pionNoir);
      DessinePionChoixSetUp(pionVide);
      couleurEnCoursPourSetUp := pionBlanc;
      DessineCadreAutourPionCouleurEnCours(couleurEnCoursPourSetUp);
      DessineBoutonsSetUp(true);
      for i := 1 to 8 do
        for j := 1 to 8 do
          PosePionSetUp(i+10*j,GetCouleurOfSquareDansJeuCourant(i+10*j));
      DessineBoiteDeTaille(wPlateauPtr);

      nextTick := tickCount + 60;
      repeat
        AjusteCurseur;
        AjusteSleep;
        repeat
        until HasGotEvent(everyEvent,theEvent,kWNESleep,NIL);
    	  if sousEmulatorSousPC then EmuleToucheCommandeParControleDansEvent(theEvent);
    	  case theEvent.what of
    	    updateEvt :
    	      UpdateEventsSetUp;
    	    mouseDown :
    	      begin
    	        IncrementeCompteurDeMouseEvents;
    	        if (FindWindow(theEvent.where,whichWindow) = InContent) and (whichWindow = wPlateauPtr)
    	         then TraiteSourisSetUp
    	         else TraiteOneEvenement;
    	      end;
    	    keyDown :
    	      TraiteKeyDownSetUp;
    	    autoKey :
    	      TraiteKeyDownSetUp;
    	    otherwise
    	      TraiteOneEvenement;
    	  end;
    	  // une fois toute les secondes, en gros
        if TickCount > nextTick then
          begin
            CheckStreamEvents;
            EnvoyerUnKeepAliveSiNecessaire;
            GererTelechargementWThor;
            nextTick := TickCount + 60;
          end;
      until humainVeutAnnuler or QuitterSetUp or Quitter or not(enSetUp) or not(windowPlateauOpen);

      humainVeutAnnuler := false;
      enSetUp := false;
      if windowPlateauOpen then
        begin
          SetPortByWindow(wPlateauPtr);
          PrepareTexteStatePourHeure;
          FillRect(MakeRect(evaluerrect.left-1,-10,700,rectPions.top-5),blackPattern);
          if not(CassioEstEn3D) then
            SetPositionPlateau2D(8,GetTailleCaseCourante,tempoAireDeJeuLeft,tempoAireDeJeuTop,'SetUp');
          SetPositionsTextesWindowPlateau;
          EcranStandard(NIL,false);
          if avecCalculPartiesActives and (windowListeOpen or windowStatOpen)
             then LanceCalculsRapidesPourBaseOuNouvelleDemande(true,true);
        end;

      if gCassioUseQuartzAntialiasing then
    	  if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

      AjusteCurseur;
      FlushEvents(everyEvent,0);
      SetPort(oldPort);
  end;
end;








end.













































