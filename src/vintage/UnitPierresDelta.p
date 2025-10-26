UNIT UnitPierresDelta;



INTERFACE







 USES UnitDefCassio;





{fonctions de dessin sur l'othellier }
procedure DessinerUnePierreDelta(const plat : plateauOthello; quelleCase, quelGenre : SInt16; GetRectForSquare2D : CalculeRect2DFunc; const texte : String255; use3D : boolean; GetRectDessusForSquare3D : CalculeRect3DFunc; {appelée si use3D = true} GetRectDessousForSquare3D : CalculeRect3DFunc); {appelée si use3D = true}
procedure DessinerUnePierreDeltaDouble(const plat : plateauOthello; quelleCase1,quelleCase2,quelGenre : SInt16; GetRectForSquare2D : CalculeRect2DFunc; use3D : boolean; GetRectDessusForSquare3D : CalculeRect3DFunc; {appelée si use3D = true} GetRectDessousForSquare3D : CalculeRect3DFunc); {appelée si use3D = true}
procedure DesssinePierresDelta(G : GameTree; surQuellesCases : SquareSet);
procedure DesssinePierresDeltaCourantes;
procedure SetRestrictedAreaDessinPierreDelta(const surQuellesCases : SquareSet);
function GetRestrictedAreaDessinPierreDelta : SquareSet;


{iterateurs}
procedure ItereSurPierresDelta(G : GameTree ; whichTypes : SetOfPropertyTypes; DoWhat : PropertyProc);
procedure ItereSurPierresDeltaCourantes(whichTypes : SetOfPropertyTypes; DoWhat : PropertyProc);
procedure ItereSurPierresDeltaAvecResult(G : GameTree ; whichTypes : SetOfPropertyTypes; DoWhat : PropertyProcAvecResult; var result : SInt32);
procedure ItereSurPierresDeltaCourantesAvecResult(whichTypes : SetOfPropertyTypes; DoWhat : PropertyProcAvecResult; var result : SInt32);


{tranformation en string}
function GetPierresDeltaEnString(G : GameTree) : String255;
function GetPierresDeltaCourantesEnString : String255;


{autres}
procedure EffacePierresDelta(G : GameTree);
procedure EffacePierresDeltaCourantes;
procedure AddRandomDeltaStoneToCurrentNode;
procedure ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc : Point; jeu : plateauOthello; forceAfficheMarquesSpeciales : boolean);
function TypesPierresDelta : SetOfPropertyTypes;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp
{$IFC NOT(USE_PRELINK)}
    , UnitGeometrie, UnitCarbonisation, UnitArbreDeJeuCourant, MyMathUtils, UnitBufferedPICT, UnitServicesDialogs, UnitStrategie
    , SNMenus, SNEvents, UnitTroisiemeDimension, UnitCurseur, UnitSquareSet, UnitGameTree, UnitPropertyList, UnitProperties
    , UnitAffichagePlateau, UnitRapport, UnitPositionEtTrait, UnitScannerUtils, UnitDiagramFforum, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/PierresDelta.lk}
{$ENDC}


{END_USE_CLAUSE}





var gRestrictedAreaDessinPierreDelta : SquareSet;


procedure DessinerUnePierreDelta(const plat : plateauOthello; quelleCase, quelGenre : SInt16;
                                 GetRectForSquare2D : CalculeRect2DFunc;
                                 const texte : String255;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D  : CalculeRect3DFunc;
                                 GetRectDessousForSquare3D : CalculeRect3DFunc);
var caseRect,destRect : rect;
begin
  caseRect := GetRectForSquare2D(quelleCase,quelGenre);
  if not(use3D)
    then destRect := caseRect
    else
      begin
        if plat[quelleCase] = pionVide
          then
            begin
              destRect := GetRectDessousForSquare3D(quelleCase,quelGenre);
              if (quelGenre = DeltaProp) or
                 (quelGenre = DeltaWhiteProp)     or (quelGenre = DeltaBlackProp)
                 then OffsetRect(destRect,0,2);  {sinon le delta sur la vcase vide se retrouve trop haut}
            end
          else destRect := GetRectDessusForSquare3D(quelleCase,quelGenre);
      end;

  case quelGenre of
    MarkedPointsProp         : if plat[quelleCase] = pionNoir
                                 then DessinePionSpecial(caseRect,destRect,quelleCase,PionCroixTraitsBlancs,texte,use3D)
                                 else DessinePionSpecial(caseRect,destRect,quelleCase,PionCroixTraitsNoirs,texte,use3D);
    {SelectedPointsProp   }
    DeltaWhiteProp           : DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaBlanc,texte,use3D);
    DeltaBlackProp           : if plat[quelleCase] = pionNoir
                                  then
                                    begin
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaNoir,texte,use3D);
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaTraitsBlancs,texte,use3D)
                                    end
                                  else DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaNoir,texte,use3D);
    DeltaProp                : if plat[quelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaTraitsNoirs,texte,use3D) else
                               if plat[quelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaTraitsBlancs,texte,use3D) else
                               if plat[quelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,quelleCase,PionDeltaTraitsNoirs,texte,use3D);
    LosangeWhiteProp         : DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeBlanc,texte,use3D);
    LosangeBlackProp         : if plat[quelleCase] = pionNoir
                                  then
                                    begin
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeNoir,texte,use3D);
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeTraitsBlancs,texte,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeNoir,texte,use3D);
    LosangeProp              : if plat[quelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeTraitsNoirs,texte,use3D) else
                               if plat[quelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeTraitsBlancs,texte,use3D) else
                               if plat[quelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,quelleCase,PionLosangeTraitsNoirs,texte,use3D);
    CarreWhiteProp           : DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreBlanc,texte,use3D);
    CarreBlackProp           : if plat[quelleCase] = pionNoir
                                  then
                                    begin
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreNoir,texte,use3D);
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreTraitsBlancs,texte,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreNoir,texte,use3D);
    CarreProp                : if plat[quelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreTraitsNoirs,texte,use3D) else
                               if plat[quelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreTraitsBlancs,texte,use3D) else
                               if plat[quelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,quelleCase,PionCarreTraitsNoirs,texte,use3D);
    EtoileProp               : DessinePionSpecial(caseRect,destRect,quelleCase,PionEtoile,texte,use3D);
    LabelOnPointsProp        : DessinePionSpecial(caseRect,destRect,quelleCase,PionLabel,texte,use3D);
    PetitCercleWhiteProp     : DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleBlanc,texte,use3D);
    PetitCercleBlackProp     : if plat[quelleCase] = pionNoir
                                  then
                                    begin
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleNoir,texte,use3D);
                                      DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleTraitsBlancs,texte,use3D);
                                    end
                                  else DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleNoir,texte,use3D);
    PetitCercleProp          : if plat[quelleCase] = pionVide  then DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleTraitsNoirs,texte,use3D) else
                               if plat[quelleCase] = pionNoir  then DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleTraitsBlancs,texte,use3D) else
                               if plat[quelleCase] = pionBlanc then DessinePionSpecial(caseRect,destRect,quelleCase,PionPetitCercleTraitsNoirs,texte,use3D);
    otherwise     AlerteSimple('Je ne sais pas dessiner ce type de pierres marquees dans DessinerUnePierreDelta!!');
  end; {case}
end;




procedure DessinerUnePierreDeltaDouble(const plat : plateauOthello; quelleCase1,quelleCase2,quelGenre : SInt16;
                                 GetRectForSquare2D : CalculeRect2DFunc;
                                 use3D : boolean;
                                 GetRectDessusForSquare3D  : CalculeRect3DFunc;
                                 GetRectDessousForSquare3D : CalculeRect3DFunc);
var CaseRect1,destRect1 : rect;
    CaseRect2,destRect2 : rect;
    thePenState : PenState;
    hautCase,epaisseur : SInt16;

   function CalculeDestRect(quelleCase,quelGenre : SInt16) : rect;
   begin
     if not(use3D)
       then
       	 CalculeDestRect := GetRectForSquare2D(quelleCase,quelGenre)
       else
         begin
           if plat[quelleCase] = pionVide
             then CalculeDestRect := GetRectDessousForSquare3D(quelleCase,quelGenre)
             else CalculeDestRect := GetRectDessusForSquare3D(quelleCase,quelGenre);
         end;
   end;

begin
  caseRect1 := GetRectForSquare2D(quelleCase1,quelGenre);
  caseRect2 := GetRectForSquare2D(quelleCase2,quelGenre);
  destRect1 := CalculeDestRect(quelleCase1,quelGenre);
  destRect2 := CalculeDestRect(quelleCase2,quelGenre);

  case quelGenre of
    ArrowProp :
      if quelleCase1 <> quelleCase2 then
	      begin
	        PrintForEPSFile(' ' + CoupEnStringEnMajuscules(quelleCase1) +
	                        ' ' + CoupEnStringEnMajuscules(quelleCase2) +
	                        ' red_arrow');
	        hautCase := CalculeDestRect(88,quelGenre).bottom - CalculeDestRect(88,quelGenre).top;
	        epaisseur := 2;
	        if hautCase > 20 then inc(epaisseur);
	        if hautCase > 30 then inc(epaisseur);
	        GetPenState(thePenState);
	        PenSize(epaisseur,epaisseur);
	        ForeColor(RedColor);
	        DessineFleche(CentreDuRectangle(destRect1),CentreDuRectangle(destRect2),(destRect2.bottom-destRect2.top)*0.47);
	        ForeColor(BlackColor);
	        SetPenState(thePenState);
	      end;
    LineProp  :
      if quelleCase1 <> quelleCase2 then
	      begin
	        PrintForEPSFile(' ' + CoupEnStringEnMajuscules(quelleCase1) +
	                        ' ' + CoupEnStringEnMajuscules(quelleCase2) +
	                        ' red_line');
	        hautCase := CalculeDestRect(88,quelGenre).bottom - CalculeDestRect(88,quelGenre).top;
	        epaisseur := 2;
	        if hautCase > 20 then inc(epaisseur);
	        if hautCase > 30 then inc(epaisseur);
	        GetPenState(thePenState);
	        PenSize(epaisseur,epaisseur);
	        ForeColor(RedColor);
	        DessineLigne(CentreDuRectangle(destRect1),CentreDuRectangle(destRect2));
	        ForeColor(BlackColor);
	        SetPenState(thePenState);
	      end;
    otherwise     AlerteSimple('Je ne sais pas dessiner ce type de pierres marquees dans DessinerUnePierreDeltaDouble!!');
  end; {case}


end;


procedure SetRestrictedAreaDessinPierreDelta(const surQuellesCases : SquareSet);
begin
  gRestrictedAreaDessinPierreDelta := surQuellesCases;
end;


function GetRestrictedAreaDessinPierreDelta : SquareSet;
begin
  GetRestrictedAreaDessinPierreDelta := gRestrictedAreaDessinPierreDelta;
end;

function DoitDessinerPierreDeltaOfThisSquare(whichSquare : SInt16) : boolean;
begin
  DoitDessinerPierreDeltaOfThisSquare := (whichSquare in gRestrictedAreaDessinPierreDelta);
end;


procedure DessinerPierresDeltaOfProperty(var prop : Property);
var whichSquare,i,j : SInt16;
    regionMarquee : PackedSquareSet;
    whichSquare1,whichSquare2 : SInt16;
    texte, foo : String255;
begin
  with prop do
    begin
      texte := '';
      if prop.genre = LabelOnPointsProp then
		    begin
		      texte := GetStringInfoOfProperty(prop);
		      SplitBy(texte, ':', foo, texte);
		    end;


      case stockage of
        StockageEnEnsembleDeCases :
          begin
            regionMarquee := GetPackedSquareSetOfProperty(prop);
            for i := 1 to 8 do
              for j := 1 to 8 do
                begin
                  whichSquare := i*10+j;
                  if SquareInPackedSquareSet(whichSquare,regionMarquee) and DoitDessinerPierreDeltaOfThisSquare(whichSquare) then
                    begin
                      DessinerUnePierreDelta(JeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,texte,CassioEstEn3D,GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
                      InvalidateDessinEnTraceDeRayon(whichSquare);
                      SetOthellierEstSale(whichSquare,true);
                    end;
                end;
          end;
        StockageEnCaseOthello :
          begin
            whichSquare := GetOthelloSquareOfProperty(prop);
            if DoitDessinerPierreDeltaOfThisSquare(whichSquare) then
              begin
                DessinerUnePierreDelta(JeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,texte,CassioEstEn3D,GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
                InvalidateDessinEnTraceDeRayon(whichSquare);
                SetOthellierEstSale(whichSquare,true);
              end;
          end;
        StockageEnCaseOthelloAlpha :
          begin
            whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
            if DoitDessinerPierreDeltaOfThisSquare(whichSquare) then
              begin
                DessinerUnePierreDelta(JeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,texte,CassioEstEn3D,GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
                InvalidateDessinEnTraceDeRayon(whichSquare);
                SetOthellierEstSale(whichSquare,true);
              end;
          end;
        StockageEnStr255 :
          begin
            whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
            if DoitDessinerPierreDeltaOfThisSquare(whichSquare) then
              begin
                DessinerUnePierreDelta(JeuCourant,whichSquare,genre,GetRectOfSquare2DDansAireDeJeu,texte,CassioEstEn3D,GetRectAreteVisiblePion3DPourPionDelta,GetRectPionDessous3DPourPionDelta);
                InvalidateDessinEnTraceDeRayon(whichSquare);
                SetOthellierEstSale(whichSquare,true);
              end;
          end;
        StockageEnCoupleCases:
    			begin
    				GetSquareCoupleOfProperty(prop,whichSquare1,whichSquare2);
    				DessinerUnePierreDeltaDouble(JeuCourant,whichSquare1,whichSquare2,genre,
                                         GetRectOfSquare2DDansAireDeJeu,
                                         CassioEstEn3D,
                                         GetRectAreteVisiblePion3DPourPionDelta,
                                         GetRectPionDessous3DPourPionDelta);
    				InvalidateDessinEnTraceDeRayon(whichSquare1);
    				InvalidateDessinEnTraceDeRayon(whichSquare2);
    				SetOthellierEstSale(whichSquare1,true);
    				SetOthellierEstSale(whichSquare2,true);
    			end;
      end; {case}
  end;  {with}
end;

function TypesPierresDelta : SetOfPropertyTypes;
begin
	TypesPierresDelta :=  [MarkedPointsProp     ,
		                    SelectedPointsProp    ,
		                    DeltaWhiteProp        ,
		                    DeltaBlackProp        ,
		                    DeltaProp             ,
		                    LosangeWhiteProp      ,
		                    LosangeBlackProp      ,
		                    LosangeProp           ,
		                    CarreWhiteProp        ,
		                    CarreBlackProp        ,
		                    CarreProp             ,
		                    EtoileProp            ,
		                    LabelOnPointsProp     ,
		                    PetitCercleWhiteProp  ,
		                    PetitCercleBlackProp  ,
		                    PetitCercleProp       ,
		                    LineProp              ,
		                    ArrowProp] ;
end;

procedure ItereSurPierresDelta(G : GameTree ; whichTypes : SetOfPropertyTypes; DoWhat : PropertyProc);
begin
	ForEachPropertyOfTheseTypesInNodeDo(G, TypesPierresDelta * whichtypes, DoWhat);       { * = set intersection }
end;


procedure ItereSurPierresDeltaCourantes(whichTypes : SetOfPropertyTypes; DoWhat : PropertyProc);
var G : GameTree;
begin
  G := GetCurrentNode;
  ItereSurPierresDelta(G, whichTypes, DoWhat);
end;


procedure ItereSurPierresDeltaAvecResult(G : GameTree ; whichTypes : SetOfPropertyTypes; DoWhat : PropertyProcAvecResult; var result : SInt32);
begin
	ForEachPropertyOfTheseTypesInNodeDoAvecResult(G, TypesPierresDelta * whichTypes, DoWhat, result);    { * = set intersection }
end;


procedure ItereSurPierresDeltaCourantesAvecResult(whichTypes : SetOfPropertyTypes; DoWhat : PropertyProcAvecResult; var result : SInt32);
var G : GameTree;
begin
  G := GetCurrentNode;
  ItereSurPierresDeltaAvecResult(G, whichTypes, DoWhat, result);
end;


procedure DesssinePierresDeltaCourantes;
var oldPort : grafPtr;
    flechesEtLignes : SetOfPropertyTypes;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      flechesEtLignes := [ LineProp , ArrowProp ];

      ItereSurPierresDeltaCourantes(TypesPierresDelta - flechesEtLignes, DessinerPierresDeltaOfProperty);
      ItereSurPierresDeltaCourantes(flechesEtLignes, DessinerPierresDeltaOfProperty);

      SetPort(oldPort);
    end;
end;

procedure DesssinePierresDelta(G : GameTree; surQuellesCases : SquareSet);
var oldPort : grafPtr;
    oldRestrictedArea : SquareSet;
    flechesEtLignes : SetOfPropertyTypes;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);

      oldRestrictedArea := GetRestrictedAreaDessinPierreDelta;
      SetRestrictedAreaDessinPierreDelta(surQuellesCases);

      flechesEtLignes := [ LineProp , ArrowProp ];

      ItereSurPierresDelta(G, TypesPierresDelta - flechesEtLignes , DessinerPierresDeltaOfProperty);
      ItereSurPierresDelta(G, flechesEtLignes , DessinerPierresDeltaOfProperty);

      SetRestrictedAreaDessinPierreDelta(oldRestrictedArea);

      SetPort(oldPort);
    end;
end;


procedure EffacerUnePierreDelta(var quelleCase : SInt16; var continuer : boolean);
var couleur : SInt32;
begin
  continuer := true;
  if (quelleCase >= 11) and (quelleCase <= 88) then
    begin
      couleur := GetCouleurOfSquareDansJeuCourant(quelleCase);
      case couleur of
        pionVide  : if CassioEstEn3D
                      then
                        begin
                          DessinePion3D(quelleCase,effaceCase);
                          {DessinePion3D(quelleCase,pionEntoureCasePourEffacerCoupEnTete);}
                        end
                      else DessinePion2D(quelleCase,pionVide);
        pionNoir  : if CassioEstEn3D
                      then DessineDessusPion3D(quelleCase,pionNoir)
                      else
                        begin
                          if not(gCouleurOthellier.estUneImage) then
                            DessinePion2D(quelleCase,pionEffaceCaseLarge);
                          DessinePion2D(quelleCase,pionNoir);
                        end;
        pionBlanc : if CassioEstEn3D
                      then DessineDessusPion3D(quelleCase,pionBlanc)
                      else
                        begin
                          if not(gCouleurOthellier.estUneImage) then
                            DessinePion2D(quelleCase,pionEffaceCaseLarge);
                          DessinePion2D(quelleCase,pionBlanc);
                        end;
      end;  {case}
    end;
end;

procedure EffacerPierresDeltaOfProperty(var prop : Property);
var whichSquare,whichSquare1,whichSquare2 : SInt16;
    aux : SInt16;
    continuer : boolean;
begin
  {TraceLog('EffacerPierresDeltaOfProperty : entree');}
  case prop.stockage of
    StockageEnEnsembleDeCases :
      begin
        ForEachSquareInPackedSetDo(GetPackedSquareSetOfProperty(prop),EffacerUnePierreDelta);
      end;
    StockageEnCaseOthello :
      begin
        whichSquare := GetOthelloSquareOfProperty(prop);
        EffacerUnePierreDelta(whichSquare,continuer);
      end;
    StockageEnCaseOthelloAlpha :
      begin
        whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
        EffacerUnePierreDelta(whichSquare,continuer);
      end;
    StockageEnStr255 :
      begin
        whichSquare := GetOthelloSquareOfPropertyAlpha(prop);
        EffacerUnePierreDelta(whichSquare,continuer);
      end;
    StockageEnCoupleCases :
			begin
				GetSquareCoupleOfProperty(prop,whichSquare1,whichSquare2);
				{TraceLog('Effacage de la fleche : '+CoupEnString(whichSquare1,true)+'-'+CoupEnString(whichSquare2,true));}
				for whichSquare := 11 to 88 do
          if SegmentIntersecteRect(CentreDuRectangle(GetBoundingRectOfSquare(whichSquare1)),
                                    CentreDuRectangle(GetBoundingRectOfSquare(whichSquare2)),
                                    GetBoundingRectOfSquare(whichSquare))
            then
              begin
                InvalidateDessinEnTraceDeRayon(whichSquare);

                aux := whichSquare;

                EffacerUnePierreDelta(aux,continuer);
                {TraceLog(Concat('la case ',CoupEnString(whichSquare,true),' est touchee'));}
              end;
			end;
  end; {case}
  {TraceLog('EffacerPierresDeltaOfProperty : sortie');}
end;

procedure EffacePierresDeltaCourantes;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDeltaCourantes(TypesPierresDelta, EffacerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;

procedure EffacePierresDelta(G : GameTree);
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      ItereSurPierresDelta(G, TypesPierresDelta, EffacerPierresDeltaOfProperty);
      SetPort(oldPort);
    end;
end;



procedure AddRandomDeltaStoneToCurrentNode;
var prop : Property;
    genre,coup,col,lig : SInt16;
begin
  if FALSE then
    begin
		  genre := RandomEntreBornes(DeltaWhiteProp,PetitCercleProp);
		  col  := RandomEntreBornes(1,8);
		  lig  := RandomEntreBornes(1,8);
		  coup := 10*lig+col;
		  prop := MakeSquareSetProperty(genre,[coup]);
		  AddPropertyToCurrentNode(prop);
		  DisposePropertyStuff(prop);
		end;
end;


const MenuFlottantDeltaID = 3005;

var   menuFlottantDelta : MenuFlottantRec;


function MenuDeltaItemToPropertyType(item : SInt16) : SInt16;
begin
  case item of
    1 :  MenuDeltaItemToPropertyType := InterestingMoveProp;
    2 :  MenuDeltaItemToPropertyType := DubiousMoveProp;
    3 :  MenuDeltaItemToPropertyType := ExoticMoveProp;
    {}
    5 :  MenuDeltaItemToPropertyType := DeltaBlackProp;
    6 :  MenuDeltaItemToPropertyType := DeltaWhiteProp;
    7 :  MenuDeltaItemToPropertyType := DeltaProp;
    {}
    9 :  MenuDeltaItemToPropertyType := LosangeBlackProp;
    10 :  MenuDeltaItemToPropertyType := LosangeWhiteProp;
    11 :  MenuDeltaItemToPropertyType := LosangeProp;
    {}
    13 :  MenuDeltaItemToPropertyType := CarreBlackProp;
    14 : MenuDeltaItemToPropertyType := CarreWhiteProp;
    15 : MenuDeltaItemToPropertyType := CarreProp;
    {}
    17 : MenuDeltaItemToPropertyType := PetitCercleBlackProp;
    18 : MenuDeltaItemToPropertyType := PetitCercleWhiteProp;
    19 : MenuDeltaItemToPropertyType := PetitCercleProp;
    {}
    21 : MenuDeltaItemToPropertyType := MarkedPointsProp;
    22 : MenuDeltaItemToPropertyType := EtoileProp;
    {}
    24 : MenuDeltaItemToPropertyType := ArrowProp;
    25 : MenuDeltaItemToPropertyType := LineProp;
    otherwise MenuDeltaItemToPropertyType := 0;
  end;
end;


procedure ChangePierresDeltaApresCommandClicSurOthellier(mouseLoc : Point; jeu : plateauOthello; forceAfficheMarquesSpeciales : boolean);
var whichSquare,destSquare,genre,genreVoulu,premiereMarqueDansMenu : SInt16;
    typesPropertiesOnTheSquare : SetOfPropertyTypes;
    typesPropertiesDansLeFils : SetOfPropertyTypes;
    myMenuFlottantDelta : MenuFlottantRec;
    {myProp,}nouvelleProp : Property;
    thePenState : PenState;
    oldMouseLoc,clicLoc : Point;
    dessinee : boolean;
    taille_pointe_fleche : double;
    proprietesCourantes : PropertyList;
    proprietesDuFils : PropertyList;
    isNew : boolean;
    oldCurrentNode,fils : GameTree;
    err : OSErr;
    item : SInt16;


    procedure MofifiePropertyListSiNecessaire(var L : PropertyList);
    var bidon : boolean;
    begin
      if (item in myMenuFlottantDelta.checkedItems)
        then
          begin
            if not(ExistsInPropertyList(nouvelleProp,L)) then
              AddPropertyToList(nouvelleProp,L);
          end
        else
          begin
            if ExistsInPropertyList(nouvelleProp,L)
              then
                begin
                  DeletePropertyFromList(nouvelleProp,L);
                  EffacerPierresDeltaOfProperty(nouvelleProp);
                  if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp]) and (fils <> NIL) then
                    EffacerUnePierreDelta(whichSquare,bidon);
                end
              else
                begin
                  AddPropertyToList(nouvelleProp,L);
                end;
          end;
    end;


begin {ChangePierresDeltaApresCommandClicSurOthellier}
  {$UNUSED jeu}
  clicLoc := mouseLoc;
  if PtInPlateau(clicLoc,whichSquare) then
    begin


      myMenuFlottantDelta := NewMenuFlottant(MenuFlottantDeltaID,MakeRect(clicLoc.h-30,clicLoc.v-5,clicLoc.h-30,clicLoc.v+15),0);
      InstalleMenuFlottant(myMenuFlottantDelta,NIL);



      GetPropertyListOfCurrentNode(proprietesCourantes);
      typesPropertiesOnTheSquare := GetTypesOfPropertyOnthatSquare(whichSquare,proprietesCourantes);
      {WritelnStringAndPropertyListDansRapport('sur la case '+CoupEnStringEnMajuscules(whichSquare)+', liste de proprietés = ',propertiesOnTheSquare);
      }

      fils := NIL;
      proprietesDuFils := NIL;

      if PeutJouerIci(AQuiDeJouer,whichSquare,jeu) then
        begin
          oldCurrentNode := GetCurrentNode;
          err := ChangeCurrentNodeAfterThisMove(whichSquare,AQuiDeJouer,'ChangePierresDeltaApresCommandClicSurOthellier',isNew);
          if (err = 0) then
            begin
              fils := GetCurrentNode;
              {if isNew then MarquerCeNoeudCommeVirtuel(fils);}
              if (fils <> NIL) then proprietesDuFils := fils^.properties;
            end;
          SetCurrentNode(oldCurrentNode, 'ChangePierresDeltaApresCommandClicSurOthellier');
        end;
      typesPropertiesDansLeFils := CalculatePropertyTypes(proprietesDuFils);



      premiereMarqueDansMenu := 0;
      with myMenuFlottantDelta do
      for item := 1 to MyCountMenuItems(theMenu) do
        begin
          genre := MenuDeltaItemToPropertyType(item);
          if (genre <> 0) then
            begin
              if InPropertyTypes(genre,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                then
                  begin
                    if (fils = NIL)
                      then MyDisableItem(theMenu,item)
                      else
                        if genre in typesPropertiesDansLeFils then
                          begin
                            checkedItems := checkedItems + [item];
                            MyCheckItem(theMenu, item, true);
                            if premiereMarqueDansMenu = 0 then premiereMarqueDansMenu := item;
                          end;
                  end
                else
                  begin
                    if genre in typesPropertiesOnTheSquare then
                      begin
                        checkedItems := checkedItems + [item];
                        MyCheckItem(theMenu, item, true);
                        if premiereMarqueDansMenu = 0 then premiereMarqueDansMenu := item;
                      end;
                  end;
            end;
        end;
      if premiereMarqueDansMenu <> 0
        then myMenuFlottantDelta.theItem := premiereMarqueDansMenu {ouvrir le menu sur cette ligne}
        else myMenuFlottantDelta.theItem := derniereLigneUtiliseeMenuFlottantDelta;


      if forceAfficheMarquesSpeciales and not(affichePierresDelta)
        then DoChangeAffichePierresDelta;
      if not(affichePierresDelta) then MyDisableItem(myMenuFlottantDelta.theMenu,0);

      InitCursor;
      if not(EventPopUpItemMenuFlottant(myMenuFlottantDelta,false,false,true)) then
        myMenuFlottantDelta.theItem := 0;
      AjusteCurseur;

      if MenuDeltaItemToPropertyType(myMenuFlottantDelta.theItem) <> 0 then
        derniereLigneUtiliseeMenuFlottantDelta := myMenuFlottantDelta.theItem;

      genreVoulu := MenuDeltaItemToPropertyType(myMenuFlottantDelta.theItem);

      if (genreVoulu = 0) and (fils <> NIL) and isNew then
        begin
          DeleteSonOfCurrentNode(fils);
          proprietesDuFils := NIL;
        end;

      if InPropertyTypes(genreVoulu,[ArrowProp,LineProp])
        then
	        begin
			      dessinee := false;
			      GetPenState(thePenState);
	          Pensize(3,3);
	          PenMode(patXor);
			      while not(Button) do
			        begin
			          oldMouseLoc := mouseLoc;
			          GetMouse(mouseLoc);
			          if not(dessinee) or not(EqualPt(mouseLoc,oldMouseLoc)) then
			            begin
					          if dessinee then
					            begin
					              if genreVoulu = LineProp
					                then DessineLigne(clicLoc,oldMouseLoc)
					                else DessineFleche(clicLoc,oldMouseLoc,taille_pointe_fleche);
					              dessinee := false;
					            end;
					          if PtInPlateau(mouseLoc,destSquare) then
					            begin
					              with GetBoundingRectOfSquare(destSquare) do
					                taille_pointe_fleche := (bottom - top)*0.4;
					              if genreVoulu = LineProp
					                then DessineLigne(clicLoc,mouseLoc)
					                else DessineFleche(clicLoc,mouseLoc,taille_pointe_fleche);
					              dessinee := true;
					            end;
					        end;
					      oldMouseLoc := mouseLoc;
					      ShareTimeWithOtherProcesses(2);
			        end;
			      if dessinee then
	            begin
	              if genreVoulu = LineProp
	                then DessineLigne(clicLoc,oldMouseLoc)
	                else DessineFleche(clicLoc,oldMouseLoc,taille_pointe_fleche);
	            end;
	          SetPenState(thePenState);
	          ShareTimeWithOtherProcesses(2);
	          FlushEvents(MDownmask+MupMask,0); {pour supprimer les clics intempestifs}
			      if dessinee and (destSquare <> whichSquare)
			        then nouvelleProp := MakeSquareCoupleProperty(genreVoulu,whichSquare,destSquare)
			        else nouvelleProp := MakeEmptyProperty;
			    end
			  else
			    begin
			      if genreVoulu = 0
			        then nouvelleProp := MakeEmptyProperty
			        else
			          if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                  then nouvelleProp := MakeArgumentVideProperty(genreVoulu)
                  else nouvelleProp := MakeSquareSetProperty(genreVoulu,[whichSquare]);
			    end;


      with myMenuFlottantDelta do
      for item := 1 to MyCountMenuItems(theMenu) do
        begin
          genre := MenuDeltaItemToPropertyType(item);
          if (genre <> 0) and (genre = genreVoulu) then
            begin
              if InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])
                then MofifiePropertyListSiNecessaire(proprietesDuFils)
                else MofifiePropertyListSiNecessaire(proprietesCourantes);
            end;
        end;

      if (genreVoulu <> 0) and (fils <> NIL) and isNew
         and not(InPropertyTypes(genreVoulu,[InterestingMoveProp,DubiousMoveProp,ExoticMoveProp])) then
        begin
          DeleteSonOfCurrentNode(fils);
          proprietesDuFils := NIL;
        end;

      DesinstalleMenuFlottant(myMenuFlottantDelta);
      DisposePropertyStuff(nouvelleProp);

      SetPropertyListOfCurrentNode(proprietesCourantes);
      if (fils <> NIL) then fils^.properties := proprietesDuFils;

    end;
end;

var gPierresDeltaStrAccumulator : String255;

procedure EcritStringRepresentationOfPropertyDansAccumulator(var prop : Property);
begin
  gPierresDeltaStrAccumulator := gPierresDeltaStrAccumulator + PropertyToString(prop);
end;

function GetPierresDeltaEnString(G : GameTree) : String255;
begin
  gPierresDeltaStrAccumulator := '';

  ItereSurPierresDelta(G, TypesPierresDelta, EcritStringRepresentationOfPropertyDansAccumulator);

  GetPierresDeltaEnString := gPierresDeltaStrAccumulator;
end;


function GetPierresDeltaCourantesEnString : String255;
begin
  GetPierresDeltaCourantesEnString := GetPierresDeltaEnString(GetCurrentNode);
end;


end.
