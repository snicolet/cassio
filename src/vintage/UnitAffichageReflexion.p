UNIT UnitAffichageReflexion;



INTERFACE







 USES UnitDefCassio;


{ Fenetre de reflexion }
procedure EffaceReflexion(effacerAussiLeRuban : boolean);                                                                                                                           ATTRIBUTE_NAME('EffaceReflexion')
procedure ReinitilaliseInfosAffichageReflexion;                                                                                                                                     ATTRIBUTE_NAME('ReinitilaliseInfosAffichageReflexion')
procedure SetNbLignesScoresCompletsCetteProf(var reflexionInfos : ReflexRec; nbLignes : SInt16);                                                                                    ATTRIBUTE_NAME('SetNbLignesScoresCompletsCetteProf')
procedure SetNbLignesScoresCompletsProfPrecedente(var reflexionInfos : ReflexRec; nbLignes : SInt16);                                                                               ATTRIBUTE_NAME('SetNbLignesScoresCompletsProfPrecedente')
function GetNbLignesScoresCompletsCetteProf(var reflexionInfos : ReflexRec) : SInt16;                                                                                               ATTRIBUTE_NAME('GetNbLignesScoresCompletsCetteProf')
function GetNbLignesScoresCompletsProfPrecedente(var reflexionInfos : ReflexRec) : SInt16;                                                                                          ATTRIBUTE_NAME('GetNbLignesScoresCompletsProfPrecedente')
function GetCoupEnTeteDansReflexionInfos(var reflexionInfos : ReflexRec) : SInt32;                                                                                                  ATTRIBUTE_NAME('GetCoupEnTeteDansReflexionInfos')
function GetCoupEnTeteDansFenetreReflexion : SInt32;                                                                                                                                ATTRIBUTE_NAME('GetCoupEnTeteDansFenetreReflexion')
function DeltaFinaleEnChaine(delta : SInt32) : String255;                                                                                                                           ATTRIBUTE_NAME('DeltaFinaleEnChaine')
procedure EcritReflexion(const fonctionAppelante : String255);                                                                                                                      ATTRIBUTE_NAME('EcritReflexion')
procedure DumpReflexionDansRapport(const fonctionAppelante : String255);                                                                                                            ATTRIBUTE_NAME('DumpReflexionDansRapport')
procedure LanceDemandeAffichageReflexion(forcerAffichageImmediat : boolean; const fonctionAppelante : String255);                                                                   ATTRIBUTE_NAME('LanceDemandeAffichageReflexion')
procedure SetDemandeAffichageReflexionEnSuspens(flag : boolean);                                                                                                                    ATTRIBUTE_NAME('SetDemandeAffichageReflexionEnSuspens')
procedure SetRedirigerContenuFntreReflexionDansRapport(flag : boolean);                                                                                                             ATTRIBUTE_NAME('SetRedirigerContenuFntreReflexionDansRapport')
function  DoitRedirigerContenuFntreReflexionDansRapport : boolean;                                                                                                                  ATTRIBUTE_NAME('DoitRedirigerContenuFntreReflexionDansRapport')
procedure SetPositionDansFntreReflexion(var reflexionInfos : ReflexRec; position : PositionEtTraitRec);                                                                             ATTRIBUTE_NAME('SetPositionDansFntreReflexion')
function GetPositionDansFntreReflexion(var reflexionInfos : ReflexRec) : PositionEtTraitRec;                                                                                        ATTRIBUTE_NAME('GetPositionDansFntreReflexion')





{ Meilleure suite en dessous de l'othellier }
procedure SauvegardeMeilleureSuiteParOptimalite(var bonPourAfficher,ligneOptimaleJusquaLaFin : boolean);                                                                            ATTRIBUTE_NAME('SauvegardeMeilleureSuiteParOptimalite')
procedure SauvegardeMeilleureSuiteParfaiteParArbreDeJeu(suiteParfaite : PropertyList);                                                                                              ATTRIBUTE_NAME('SauvegardeMeilleureSuiteParfaiteParArbreDeJeu')
procedure EffaceMeilleureSuite;                                                                                                                                                     ATTRIBUTE_NAME('EffaceMeilleureSuite')
procedure EffaceMeilleureSuiteSiNecessaire;                                                                                                                                         ATTRIBUTE_NAME('EffaceMeilleureSuiteSiNecessaire')
procedure VideMeilleureSuiteInfos;                                                                                                                                                  ATTRIBUTE_NAME('VideMeilleureSuiteInfos')
procedure GetMeilleureSuiteInfos(var infos : meilleureSuiteInfosRec);                                                                                                               ATTRIBUTE_NAME('GetMeilleureSuiteInfos')
procedure SetMeilleureSuiteInfos(var infos : meilleureSuiteInfosRec);                                                                                                               ATTRIBUTE_NAME('SetMeilleureSuiteInfos')
function GetMeilleureSuite : String255;                                                                                                                                             ATTRIBUTE_NAME('GetMeilleureSuite')
procedure SetMeilleureSuite(s : String255);                                                                                                                                         ATTRIBUTE_NAME('SetMeilleureSuite')
procedure DetruitMeilleureSuite;                                                                                                                                                    ATTRIBUTE_NAME('DetruitMeilleureSuite')
function NoteEnString(note : SInt32; avecSignePlus : boolean; nbEspacesDevant,nbDecimales : SInt16) : String255;                                                                    ATTRIBUTE_NAME('NoteEnString')
function MeilleureSuiteInfosEnChaine(nbEspacesEntreCoups : SInt16; avecScore,avecNumeroPremierCoup,enMajuscules,remplacerScoreIncompletParEtc : boolean; whichScore : SInt16) : String255;                                                                                    ATTRIBUTE_NAME('MeilleureSuiteInfosEnChaine')
function MeilleureSuiteEtNoteEnChaine(coul,note,profondeur : SInt16) : String255;                                                                                                   ATTRIBUTE_NAME('MeilleureSuiteEtNoteEnChaine')
function LongueurMeilleureSuite : SInt32;                                                                                                                                           ATTRIBUTE_NAME('LongueurMeilleureSuite')
procedure EcritMeilleureSuite;                                                                                                                                                      ATTRIBUTE_NAME('EcritMeilleureSuite')
procedure EcritMeilleureSuiteParOptimalite;                                                                                                                                         ATTRIBUTE_NAME('EcritMeilleureSuiteParOptimalite')
procedure EcritMeilleureSuiteParArbreDeJeu(suiteParfaite : PropertyList);                                                                                                           ATTRIBUTE_NAME('EcritMeilleureSuiteParArbreDeJeu')
procedure EssayeAfficherMeilleureSuiteParArbreDeJeu;                                                                                                                                ATTRIBUTE_NAME('EssayeAfficherMeilleureSuiteParArbreDeJeu')
function GetStatutMeilleureSuite : SInt32;                                                                                                                                          ATTRIBUTE_NAME('GetStatutMeilleureSuite')
procedure SetStatutMeilleureSuite(leStatut : SInt32);                                                                                                                               ATTRIBUTE_NAME('SetStatutMeilleureSuite')
function GetMeilleureSuiteRect : rect;                                                                                                                                              ATTRIBUTE_NAME('GetMeilleureSuiteRect')
function GetMeilleureSuiteRectGlobal : rect;                                                                                                                                        ATTRIBUTE_NAME('GetMeilleureSuiteRectGlobal')
procedure SetMeilleureSuiteRect(theRect : rect);                                                                                                                                    ATTRIBUTE_NAME('SetMeilleureSuiteRect')
procedure CalculateMeilleureSuiteWidth;                                                                                                                                             ATTRIBUTE_NAME('CalculateMeilleureSuiteWidth')
procedure CalculateMeilleureSuiteRectGlobal;                                                                                                                                        ATTRIBUTE_NAME('CalculateMeilleureSuiteRectGlobal')





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, OSUtils, fp, QuickdrawText, Fonts, Appearance
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitMoveRecords, UnitUtilitaires, UnitCouleur, UnitBufferedPICT, UnitEnvirons
    , UnitServicesMemoire, UnitPositionEtTrait, UnitProperties, UnitEngine, UnitPositionEtTrait, UnitRapport, UnitStrategie, UnitTroisiemeDimension
    , UnitEntreeTranscript, UnitScannerUtils, MyStrings, UnitFenetres, UnitModes, UnitJeu, UnitCarbonisation, MyMathUtils
    , UnitGeometrie, UnitNormalisation, UnitAffichagePlateau, UnitCouleur ;
{$ELSEC}
    ;
    {$I prelink/AffichageReflexion.lk}
{$ENDC}


{END_USE_CLAUSE}






const kHauteurRubanReflexion = 28;




procedure SetRedirigerContenuFntreReflexionDansRapport(flag : boolean);
begin
  affichageReflexion.redirigerAffichageVersLeRapport := flag;
end;


function DoitRedirigerContenuFntreReflexionDansRapport : boolean;
begin
  DoitRedirigerContenuFntreReflexionDansRapport := affichageReflexion.redirigerAffichageVersLeRapport;
end;


procedure SetPositionDansFntreReflexion(var reflexionInfos : ReflexRec; position : PositionEtTraitRec);
begin
  reflexionInfos.positionDeLaReflexion := position;
  reflexionInfos.empties := NbCasesVidesDansPosition(position.position);
end;


function GetPositionDansFntreReflexion(var reflexionInfos : ReflexRec) : PositionEtTraitRec;
begin
  GetPositionDansFntreReflexion := reflexionInfos.positionDeLaReflexion;
end;


procedure SetDemandeAffichageReflexionEnSuspens(flag : boolean);
begin
  affichageReflexion.demandeEnSuspend := flag;
end;




procedure EffaceReflexion(effacerAussiLeRuban : boolean);
var s,s1 : String255;
    oldport : grafPtr;
    myRect : rect;
    err : OSErr;
begin
 if windowReflexOpen then
  begin
    GetPort(oldport);
    SetPortByWindow(wReflexPtr);
    
    myRect := QDGetPortBound;
    myRect.bottom := myRect.top + kHauteurRubanReflexion;
    
    RGBForeColor(gPurNoir);
    RGBBackColor(gPurBlanc);
    
    
    { effacer le ruban si necessaire }
    if effacerAussiLeRuban | (nbreCoup <= 0) | (nbreCoup >= 60) | gameOver |
       (abs(ReflexData^.empties - (60 - nbreCoup)) > 10) then
      begin
        MyEraseRect(myRect);
        err := DrawThemeWindowListViewHeader(myRect, kThemeStateActive);
      end;
      
    { tracer la ligne sous le ruban }
    RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurNoir,45000));
    Moveto(0 , kHauteurRubanReflexion);
    Lineto(QDGetPortBound.right , kHauteurRubanReflexion);
    
    { effacer la zone d'affichage des coups et des scores }
    RGBBackColor(EclaircirCouleurDeCetteQuantite(gPurGris,31000));
    myRect := QDGetPortBound;
    myRect.top := kHauteurRubanReflexion + 1;
    MyEraseRect(myRect);
    MyEraseRectWithColor(myRect,VertPaleCmd,blackPattern,'');
    
    RGBForeColor(gPurGris);
    
    { si la partie est finie, afficher le score }
    if (nbreCoup >= 60) | gameOver then
      begin
        TextMode(1);
        TextFont(gCassioApplicationFont);
        TextFace(normal);
        TextSize(gCassioSmallFontSize);
        s := NumEnString(nbreDePions[pionNoir]);
        s1 := NumEnString(nbreDePions[pionBlanc]);
        s1 := s+CharToString('-')+s1;
        s := ParamStr(ReadStringFromRessource(TextesRapportID,7),s1,'','','');  {'score final ^0'}
        Moveto(3,myRect.bottom - 3);
        MyDrawString(s);
      end;
    
    RGBForeColor(gPurNoir);
    
    DessineBoiteDeTaille(wReflexPtr);
    
    SetPort(oldport);
    SetDemandeAffichageReflexionEnSuspens(false);

    {pour reafficher immediatement au prochain appel de LanceDemandeAffichageReflexion; }
    affichageReflexion.tickDernierAffichageReflexion := 0;
  end;
end;

procedure LanceDemandeAffichageReflexion(forcerAffichageImmediat : boolean; const fonctionAppelante : String255);
var tempoRedirectionVersRapport : boolean;
begin
  with affichageReflexion do
    begin
      {plus d'une demi-seconde ?}
      forcerAffichageImmediat := forcerAffichageImmediat | ((Tickcount - tickDernierAffichageReflexion) >= 25);

      tempoRedirectionVersRapport := DoitRedirigerContenuFntreReflexionDansRapport;
      SetRedirigerContenuFntreReflexionDansRapport(false);

      if doitAfficher & forcerAffichageImmediat
        then EcritReflexion(fonctionAppelante)
        else SetDemandeAffichageReflexionEnSuspens(true);


      if tempoRedirectionVersRapport & ('DoSystemTask' <> fonctionAppelante) then
        begin
          SetRedirigerContenuFntreReflexionDansRapport(true);
          DumpReflexionDansRapport(fonctionAppelante);
          EcritReflexion(fonctionAppelante);
        end;

      SetRedirigerContenuFntreReflexionDansRapport(tempoRedirectionVersRapport);
    end;
end;

procedure DumpReflexionDansRapport;
var j : SInt32;
begin
  with ReflexData^ do
    begin
      WriteNumDansRapport('DUMP : ' + NumEnString(IndexCoupEnCours) + '/',longClass);
      WritelnDansRapport(' , fonctionAppelante = ' + fonctionAppelante);
      for j := 1 to longClass do
        WritelnNumDansRapport(CoupEnString(class[j].x,true) + ' => ',class[j].note);
    end;
end;


procedure ReinitilaliseInfosAffichageReflexion;
begin
  if ReflexData <> NIL then
    begin
		  SetValReflex(ReflexData^.class,0,0,0,0,0,0,0);
		  SetNbLignesScoresCompletsCetteProf(ReflexData^,0);
		  SetNbLignesScoresCompletsProfPrecedente(ReflexData^,0);
		  with ReflexData^ do
		    MemoryFillChar(@positionDeLaReflexion, sizeof(positionDeLaReflexion),chr(0));
    end;
end;


procedure SetNbLignesScoresCompletsCetteProf(var reflexionInfos : ReflexRec; nbLignes : SInt16);
begin
  reflexionInfos.nbLignesScoresCompletsCetteProf := nbLignes;
end;

function GetNbLignesScoresCompletsCetteProf(var reflexionInfos : ReflexRec) : SInt16;
begin
  GetNbLignesScoresCompletsCetteProf := reflexionInfos.nbLignesScoresCompletsCetteProf;
end;

procedure SetNbLignesScoresCompletsProfPrecedente(var reflexionInfos : ReflexRec; nbLignes : SInt16);
begin
  reflexionInfos.nbLignesScoresCompletsProfPrecedente := nbLignes;
end;

function GetNbLignesScoresCompletsProfPrecedente(var reflexionInfos : ReflexRec) : SInt16;
begin
  GetNbLignesScoresCompletsProfPrecedente := reflexionInfos.nbLignesScoresCompletsProfPrecedente;
end;


function GetCoupEnTeteDansReflexionInfos(var reflexionInfos : ReflexRec) : SInt32;
var result : SInt32;
begin
  result := 0;

  with reflexionInfos do
    if (longClass > 0) then result := class[1].x;

  if (result > 0) & (result >= 11) & (result <= 88)
    then GetCoupEnTeteDansReflexionInfos := result
    else GetCoupEnTeteDansReflexionInfos := 0;
end;


function GetCoupEnTeteDansFenetreReflexion : SInt32;
begin
  GetCoupEnTeteDansFenetreReflexion := GetCoupEnTeteDansReflexionInfos(ReflexData^);
end;


function DeltaFinaleEnChaine(delta : SInt32) : String255;
var s : String255;
begin
  s := '';
  if delta = kDeltaFinaleInfini then s := 'µ=∞' else
  if delta = kTypeMilieuDePartie then s := 'µ=-∞'
   else
     begin
       s := 'µ=' + NumEnString(delta div 100);
       if (delta mod 100) <> 0
         then s := s + '.' + NumEnString(delta mod 100);
     end;
  DeltaFinaleEnChaine := s;
end;

function DefenseEnString(theDefense : SInt32) : String255;
var s : String255;
begin
  s := CoupEnString(theDefense,CassioUtiliseDesMajuscules);
  if (s = '')
    then DefenseEnString := '    '
    else DefenseEnString := '•' + s;
end;




procedure DrawResultStringDansFenetreReflexion(const s : String255; a,b : SInt32);
var coup, defense, result, foo : String255;
    onEstAuCoup59 : boolean;
    decalageH : SInt32;
begin

  onEstAuCoup59 :=  (ReflexData^.empties = 1);
  if onEstAuCoup59
    then decalageH := -20
    else decalageH := 0;
  
  coup := TPCopy(s, 1, 2);
  SplitByStr(s, '•', foo, defense);
  defense := TPCopy(defense, 1, 2);
  SplitByStr(s, '=>', foo, result);
  EnleveEspacesDeGaucheSurPlace(result);

  Moveto(a , b);
  MyDrawString(coup);
  
  Moveto(a + 18 , b);
  MyDrawString(defense);
  
  Moveto(a + 38 + decalageH, b);
  MyDrawString('=>');
  
  Moveto(a + 56 + decalageH, b);
  MyDrawString(result);
end;


procedure EcritCoupEnCoursdAnalyse(numligne,xposition,ypositionDebutListe : SInt16; var onASeulementEcritDesPerdants : boolean);
  var note,coupAnalyse,defense,certitude,delta,typeDeFleche,typeDonnees : SInt32;
      coupStr,infoStr,flecheStr,strAux,pointInterrogation : String255;
      a,b : SInt16;
      ligneRect : rect;
      afficheeCommeNoteDeMilieu : boolean;
      peutAfficherLeTemps : boolean;
      redirectionVersRapport : boolean;
      estLeDeuxiemeCoupDuClassement : boolean;
  const flecheLargeStr = '  ==> ';
        flecheEtroiteStr = '=> ';
        flecheTresEtroiteStr = '=>';
        flecheTresTresEtroiteStr = '=>';
        kFlecheTresTresEtroite = 1;
        kFlecheTresEtroite = 2;
        kFlecheEtroite = 3;
        kFlecheLarge = 4;
  begin

    redirectionVersRapport := DoitRedirigerContenuFntreReflexionDansRapport;
    if EstLaVersionFrancaiseDeCassio
      then pointInterrogation := ' ?'
      else pointInterrogation := '?';

    a := xposition;
    b := ypositionDebutListe + (numligne)*12;
    
    typeDeFleche              := kFlecheLarge;
    afficheeCommeNoteDeMilieu := false;
    peutAfficherLeTemps       := true;

    coupAnalyse := ReflexData^.class[numligne].x;
    defense := ReflexData^.class[numligne].theDefense;
    certitude := ReflexData^.class[numligne].pourcentageCertitude;
    delta := ReflexData^.class[numligne].delta;
    note := ReflexData^.class[numligne].note;
    typeDonnees := ReflexData^.typeDonnees;

    coupStr := CoupEnString(coupAnalyse,CassioUtiliseDesMajuscules) + ' ';
    infoStr := '';
    strAux := '';
    if (typeDonnees = ReflParfaitPhaseRechScore) |
       (typeDonnees = ReflRetrogradeParfaitPhaseRechScore)
     then
      begin
        coupStr := coupStr + DefenseEnString(defense) + ' ';
        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
        if note < 0 {perd de ^0} then
          begin
            infoStr := infoStr + ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
            if (note <> -2) then onASeulementEcritDesPerdants := false;
          end;
        if note = 0 {annule} then
          begin
            infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,18);
            onASeulementEcritDesPerdants := false;
          end;
        if note > 0 {gagne de +^0} then
          begin
            infoStr := infoStr + ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
            onASeulementEcritDesPerdants := false;
          end;
        if (certitude = 100) {& (note > ReflexData^.class[1].note + 8) }
          then infoStr := infoStr + '…';
      end
     else
      if (numligne = 1)
       then
         begin
          if (note > 0) then
            begin
              if not(odd(note)) & (typeDonnees <> ReflRetrogradeParfaitPhaseGagnant) & (typeDonnees <> ReflParfaitPhaseGagnant)
                then
                  begin
                    coupStr := coupStr + DefenseEnString(defense) + ' ';
{gagne de +^0}      infoStr := infoStr + ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                    onASeulementEcritDesPerdants := false;
                  end
                else
                  begin
{gagnant}           infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,7);
                    if (note <>  + 1) & (Abs(note) < 1000) then infoStr := infoStr + '(+' + NumEnString(note) + ')';
                    onASeulementEcritDesPerdants := false;
                  end;
            end;
          if note < 0 then
            begin
              if not(odd(note)) & (typeDonnees <> ReflRetrogradeParfaitPhaseGagnant) & (typeDonnees <> ReflParfaitPhaseGagnant)
                then
                  begin
{perd de ^0}        coupStr := coupStr + DefenseEnString(defense) + ' ';
                    infoStr := infoStr + ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                    if (note <> -2) then onASeulementEcritDesPerdants := false;
                  end
                else
                  begin
                    coupStr := coupStr + DefenseEnString(defense) + ' ';
{perdant}           infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,9);
                    if (note <> -1) & (Abs(note) < 1000) then infoStr := infoStr + '(' + NumEnString(note) + ')';
                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                  end;
             end;
          if note = 0
            then
              begin
                coupStr := coupStr + DefenseEnString(defense) + ' ';
{nulle}         infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,11);
                typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                onASeulementEcritDesPerdants := false;
              end;
         end
       else
         if note <= ReflexData^.class[1].note
          then
            begin
              peutAfficherLeTemps := false;
              estLeDeuxiemeCoupDuClassement := (numLigne = 2) & (analyseRetrograde.enCours) & (ReflexData^.class[1].x = ReflexData^.coupAnalyseRetrograde);
              case typeDonnees of
                ReflGagnant,ReflRetrogradeGagnant,
                ReflRetrogradeParfaitPhaseGagnant,ReflParfaitPhaseGagnant:
                  if (note >= -1) | estLeDeuxiemeCoupDuClassement
                    then
		                  begin
		                    coupStr := coupStr + DefenseEnString(defense) + '  ';
		                    if ((note = kValeurSpecialeDansReflPourPerdant) | ((note = -32767) & estLeDeuxiemeCoupDuClassement & (ReflexData^.class[1].note < 0)))
		                      then
		                        begin
		                          infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,9);    {perdant}
		                        end
		                      else
		                        begin
		                          infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,16);  {pas mieux}
		                          onASeulementEcritDesPerdants := false;
		                        end;
		                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		                  end
		                else
		                  begin
		                    coupStr := coupStr + DefenseEnString(defense) + '  ';
		                    infoStr := infoStr + '???';
		                    //infoStr := infoStr + '???' + '  { 1 : ' + NumEnString(note) + ' , ' + DefenseEnString(defense) + ' }';
		                  end;
		            ReflParfait,ReflParfaitPhaseRechScore,
		            ReflRetrogradeParfait,ReflRetrogradeParfaitPhaseRechScore :
		              if (note >= -64) | estLeDeuxiemeCoupDuClassement
                    then
		                  begin
		                    coupStr := coupStr + DefenseEnString(defense) + '  ';
		                    infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,16);    {pas mieux}
		                    typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		                    onASeulementEcritDesPerdants := false;
		                  end
		                else
		                  begin
		                    coupStr := coupStr + DefenseEnString(defense) + '  ';
		                    infoStr := infoStr + '???';
		                    // infoStr := infoStr + '???' + '  { 2 : ' + NumEnString(note) + ' , ' + DefenseEnString(defense) + ' }';
		                  end;
		            ReflMilieu :
		                begin
		                  coupStr := coupStr + DefenseEnString(defense) + '  ';
		                  infoStr := infoStr + '???';
		                  //infoStr := infoStr + '???' + '  { 3 : ' + NumEnString(note) + ' , ' + DefenseEnString(defense) + ' }';
		                  afficheeCommeNoteDeMilieu := true;
		                end;
                otherwise
                    begin
                      coupStr := coupStr + DefenseEnString(defense) + '  ';
                      infoStr := infoStr + '???';
                      //infoStr := infoStr + '???' + '  { 4 : ' + NumEnString(note) + ' , ' + DefenseEnString(defense) + ' }';
                    end;
              end; {case}
            end
          else
            begin { note >= ReflexData^.class[1].note }
              case typeDonnees of
                ReflParfait,
                ReflRetrogradeParfait:
                  if (note = kValeurSpecialeDansReflPourPerdant)
                    then
                      begin
                        coupStr := coupStr + DefenseEnString(defense) + ' ';
                        infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,9);  {perdant}
                        if (note <> -1) & (Abs(note) < 1000) then infoStr := infoStr + '(' + NumEnString(note) + ')' ;
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                      end
                    else
		                  if (note > 0) & (ReflexData^.class[1].note <= 0)
		                    then
		                      begin
		                        if odd(note)
		                          then
		                            begin  {gagnant}
		                              infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,7);
		                              if (note <>   + 1) & (Abs(note) < 1000) then infoStr := infoStr + '(+' + NumEnString(note) + ')' ;
		                              onASeulementEcritDesPerdants := false;
		                            end
		                          else
		                            begin  {gagne de +^0}
		                              coupStr := coupStr + DefenseEnString(defense) + ' ';
		                              infoStr := infoStr + ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
		                              typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		                              onASeulementEcritDesPerdants := false;
		                            end;
		                      end
		                    else
                          begin
                            infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,14);   {est meilleur}
                            if note > ReflexData^.class[1].note + 2 then
                              begin
		                            if note > 0
		                              then infoStr := infoStr + '(+' + NumEnString(note) + ')';
		                            if note = 0
		                              then infoStr := infoStr + '(' + NumEnString(note) + ')';
		                            if (note < 0) & (Abs(note) < 1000)
		                              then infoStr := infoStr + '(' + NumEnString(note) + ')';
		                          end;
                            typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                            onASeulementEcritDesPerdants := false;
                          end;
                ReflParfaitPhaseGagnant,ReflRetrogradeParfaitPhaseGagnant,
                ReflGagnant,ReflRetrogradeGagnant:
                  begin
                    if note > 0 then {est gagnant}
                      begin
                        infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,12);
                        onASeulementEcritDesPerdants := false;
                      end;
                    if note = 0 then {annule}
                      begin
                        coupStr := coupStr + DefenseEnString(defense) + ' ';
                        infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,18);
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                        onASeulementEcritDesPerdants := false;
                      end;
                    if note < 0 then {perdant}
                      begin
                        coupStr := coupStr + DefenseEnString(defense) + ' ';
                        infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,9);  {perdant}
                        typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
                      end;
                  end;
                ReflMilieu :
		                begin
		                  infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,14); {est meilleur}
		                  afficheeCommeNoteDeMilieu := true;
		                  onASeulementEcritDesPerdants := false;
		                end;
                otherwise
                    begin
                      infoStr := infoStr + ReadStringFromRessource(TextesReflexionID,14); {est meilleur}
                      onASeulementEcritDesPerdants := false;
                    end;
              end;
            end;

    if Pos('???',infoStr) = 0 then
      begin
        if certitude = kCertitudeSpecialPourPointInterrogation
          then
            infoStr := infoStr + pointInterrogation
          else
				    if (certitude > 0) & (certitude < 100) then
				      begin
				        infoStr := infoStr + pointInterrogation;
				        strAux := strAux + ' [' + NumEnString(certitude) + '%]';
				      end;
        if (delta >= 0) & (delta < kDeltaFinaleInfini) & (Pos('?',infoStr) = 0)
          then infoStr := infoStr + pointInterrogation;
          
        if not(afficheeCommeNoteDeMilieu | (delta = kDeltaFinaleInfini) | (delta = kTypeMilieuDePartie))
          then strAux := strAux + ' [' + DeltaFinaleEnChaine(delta) + ']';
          
        if afficheGestionTemps & peutAfficherLeTemps then
          begin
		        if (certitude <= 0) | (certitude >= 100)
		          then strAux := strAux + ' (' + NumEnString((30 + ReflexData^.class[numligne].temps) div 60) + ' s)'
		          else
		            begin
		              strAux := strAux + '(' + NumEnString((30 + ReflexData^.class[numligne].temps) div 60) + ' s)' ;
		              typeDeFleche := Min(kFlecheEtroite,typeDeFleche);
		            end;
		      end;

		    {if (certitude > 0) & (certitude < 100) & (typeDeFleche = kFlecheEtroite) then
			      typeDeFleche := kFlecheTresEtroite;
			   }
      end;


    case typeDeFleche of
        kFlecheTresTresEtroite : flecheStr := flecheTresTresEtroiteStr;
        kFlecheTresEtroite     : flecheStr := flecheTresEtroiteStr;
        kFlecheEtroite         : flecheStr := flecheEtroiteStr;
        kFlecheLarge           : flecheStr := flecheLargeStr;
        otherwise                flecheStr := '';
    end; {case}
    
    SetRect(lignerect,a, b - 10 , QDGetPortBound.right, b + 2);
    if redirectionVersRapport
      then WritelnDansRapport(coupStr + flecheStr + infoStr + strAux)
      else
        begin
          MyEraseRect(lignerect);
          MyEraseRectWithColor(lignerect,BleuCmd,blackPattern,'');
          TextFace(bold);
          DrawResultStringDansFenetreReflexion(coupStr + flecheStr + infoStr, a, b);
          TextFace(normal);
          MyDrawString(strAux);
        end;

    if (lignerect.bottom >= QDGetPortBound.bottom - 15)
      then DessineBoiteDeTaille(wReflexPtr);

end;



procedure ConstruitChaineLigneReflexion(nroLigne,coup,note,delta,noteLignePrecedente : SInt32; avecFleche : boolean; var s2 : String255; var onASeulementEcritDesPerdants : boolean);
var afficheeCommeNoteDeMilieu : boolean;

  function NoteEnStringLocal(note : SInt32) : String255;
  begin
    afficheeCommeNoteDeMilieu := true;
    NoteEnStringLocal := NoteEnString(note,false,0,2);
  end;

  function ChaineGagnantAvecScore(note : SInt32) : String255;
  var aux : String255;
  begin
    aux := ReadStringFromRessource(TextesReflexionID,7);        {gagnant}
		if (note <>  + 1) & (Abs(note) < 1000) then aux := aux + '(+' + NumEnString(note) + ')';
		ChaineGagnantAvecScore := aux;
  end;

  function ChainePerdantAvecScore(note : SInt32) : String255;
  var aux : String255;
  begin
    aux := ReadStringFromRessource(TextesReflexionID,9);  {perdant}
		if (note <> -1) & (Abs(note) < 1000) then aux := aux + '(' + NumEnString(note) + ')';
		ChainePerdantAvecScore := aux;
  end;

begin
  with ReflexData^ do
    begin
		  afficheeCommeNoteDeMilieu := false;

		  if (note = kValeurSpecialeDansReflPourPasMieux)
		    then
		      begin
		        if onASeulementEcritDesPerdants
		          then
		            begin
		              s2 := ReadStringFromRessource(TextesReflexionID,9);   {'perdant'}
		            end
		          else
		            begin
		              s2 := ReadStringFromRessource(TextesReflexionID,16);  {'pas mieux'}
		              onASeulementEcritDesPerdants := false;
		            end;
		      end
		    else
    		  if (note = kValeurSpecialeDansReflPourPerdant) &
    		     (delta <> kTypeMilieuDePartie) &
    		     ((typeDonnees = ReflParfait) |
    		      (typeDonnees = ReflParfaitExhaustif) |
    		   { (typeDonnees  = ReflParfaitPhaseGagnant) |}
    		     (typeDonnees  = ReflParfaitPhaseRechScore) |
    		     (typeDonnees  = ReflRetrogradeParfait) |
    		   { (typeDonnees  = ReflRetrogradeParfaitPhaseGagnant)|}
    		     (typeDonnees  = ReflRetrogradeParfaitPhaseRechScore))
    		    then
    		      begin
    		        s2 := ReadStringFromRessource(TextesReflexionID,9);     {'perdant'}
    		      end
    		    else
    				  case typeDonnees of
    				     ReflTriGagnant,
    				     ReflTriParfait,
    				     ReflAnnonceParfait,
    				     ReflAnnonceGagnant:
    				       if note <= -30000
    				         then
    				           s2 := '              '
    				         else
    				           begin
    				             s2 := NoteEnStringLocal(note);
    				             onASeulementEcritDesPerdants := false;
    				           end;
    				     ReflMilieu    :
    				       if note <= -30000
    				         then s2 := '              '
    				         else
    				           begin
    				             if (nroLigne <= nbLignesScoresCompletsCetteProf) then s2 := Concat(' ',NoteEnStringLocal(note)) else
    					           if (nroLigne <= nbCoupsEnTete) then s2 := Concat(' ',NoteEnStringLocal(note)) else
    					           if (note = noteLignePrecedente) & (nroLigne > 1)
    					               then s2 := Concat(' ',ReadStringFromRessource(TextesReflexionID,16))  {pas mieux}
    					               else s2 := Concat(' ',NoteEnStringLocal(note));
    					           afficheeCommeNoteDeMilieu := true;
    					           onASeulementEcritDesPerdants := false;
    					         end;
    				     ReflMilieuExhaustif :
    				       if note <= -30000
    				         then s2 := '              '
    				         else
    				           begin
    				             s2 := Concat(' ',NoteEnStringLocal(note));
    				             onASeulementEcritDesPerdants := false;
    				           end;
    				     ReflParfait,ReflParfaitPhaseGagnant,ReflParfaitPhaseRechScore:
    				       if (nroLigne = 1)
    				         then
    				           begin
    				             if odd(note) | (typeDonnees = ReflParfaitPhaseGagnant)
    				               then
    				                 begin
    				                   if note < 0 then
    				                     begin
    				                       s2 := ReadStringFromRessource(TextesReflexionID,9);   {perdant}
    				                     end else
    				                   if note = 0 then
    				                     begin
    				                       s2 := ReadStringFromRessource(TextesReflexionID,11);  {nulle}
    				                       onASeulementEcritDesPerdants := false;
    				                     end else
    				                   if note > 0 then
    				                     begin
    				                       s2 := ReadStringFromRessource(TextesReflexionID,7);   {gagnant}
    				                       onASeulementEcritDesPerdants := false;
    				                     end;
    				                 end
    				               else
    				                 begin
    				   {perd de ^0}    if note < 0 then
    				                     begin
    				                       s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
    				                       if (note <> -2) then onASeulementEcritDesPerdants := false;
    				                     end else
    				   {annule }       if note = 0 then
    				                     begin
    				                       s2 := ReadStringFromRessource(TextesReflexionID,18);
    				                       onASeulementEcritDesPerdants := false;
    				                     end else
    				   {gagne de +^0}  if note > 0 then
    				                     begin
    				                       s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
    				                       onASeulementEcritDesPerdants := false;
    				                     end;
    				                 end
    				           end
    				         else
    				           begin
    				             if odd(note)
    				               then
    				                 begin
    				                   if (note = noteLignePrecedente) | (note = ReflexData^.class[1].note)
    				                     then
    				                       begin
    				                         if (note = -1) & (typeDonnees = ReflParfaitPhaseGagnant)
      				                         then
      				                           begin
      				                             s2 := ReadStringFromRessource(TextesReflexionID,9);    {perdant}
      				                           end
      				                         else
      				                           begin
      				                             s2 := ReadStringFromRessource(TextesReflexionID,16);   {pas mieux}
      				                             onASeulementEcritDesPerdants := false;
      				                           end;
    				                       end
    				                     else
    				                       begin
    				                         if note < 0 then
    				                           begin
    				                             s2 := ChainePerdantAvecScore(note);                   { perdant(-X) }
    				                           end else
    				                         if note = 0 then
    				                           begin
    				                             s2 := ReadStringFromRessource(TextesReflexionID,11);   {nulle}
    				                             onASeulementEcritDesPerdants := false;
    				                           end else
    				                         if note > 0 then
    				                           begin
    				                             s2 := ChaineGagnantAvecScore(note);                   { gagnant(X) }
    				                             onASeulementEcritDesPerdants := false;
    				                           end;
    				                       end;
    				                 end
    				               else
    				                 begin
    				                   if (note = noteLignePrecedente) | (note = ReflexData^.class[1].note) then
    				                     begin
    				                       if onASeulementEcritDesPerdants
                        		         then
                        		           begin
               {perdant  }         		   s2 := ReadStringFromRessource(TextesReflexionID,9);
                        		           end
                        		         else
                        		           begin
               {'pas mieux'}             s2 := ReadStringFromRessource(TextesReflexionID,16);
                        		             onASeulementEcritDesPerdants := false;
                        		           end;
    				                     end else
    				   {perd de ^0}    if note < 0 then
    				                     begin
    				                       s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
    				                       if (note <> -2) then onASeulementEcritDesPerdants := false;
    				                     end else
    				   {annule }       if note = 0 then
    				                     begin
    				                       s2 := ReadStringFromRessource(TextesReflexionID,18);
    				                       onASeulementEcritDesPerdants := false;
    				                     end else
    				   {gagne de +^0}  if note > 0 then
    				                     begin
    				                       s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
    				                       onASeulementEcritDesPerdants := false;
    				                     end;
    				                 end
    				           end;
    				     ReflGagnant,ReflRetrogradeGagnant:
    				       if (nroLigne = 1)
    				         then
    				           begin
    		{perdant}        if note < 0 then
    		                   begin
    		                     s2 := ReadStringFromRessource(TextesReflexionID,9);
    		                   end else
    		{nulle}          if note = 0 then
    		                   begin
    		                     s2 := ReadStringFromRessource(TextesReflexionID,11);
    		                     onASeulementEcritDesPerdants := false;
    		                   end else
    		{gagnant}        if note > 0 then
    		                   begin
    		                     s2 := ReadStringFromRessource(TextesReflexionID,7);
    		                     onASeulementEcritDesPerdants := false;
    		                   end;
    				           end
    				         else
    				           begin
    		{pas mieux}      if ((note = noteLignePrecedente) | (note = ReflexData^.class[1].note)) & (note >= 0)
    		                   then
    		                      begin
    		                        s2 := ReadStringFromRessource(TextesReflexionID,16);
    		                        onASeulementEcritDesPerdants := false;
    		                      end
    		{perdant}           else if note < 0 then
    		                           begin
    		                             s2 := ReadStringFromRessource(TextesReflexionID,9);
    		                           end
    		{nulle}                else if note = 0 then
    		                             begin
    		                               s2 := ReadStringFromRessource(TextesReflexionID,11);
    		                               onASeulementEcritDesPerdants := false;
    		                             end
    		{gagnant}                else if note > 0 then
    		                               begin
    		                                 s2 := ReadStringFromRessource(TextesReflexionID,7);
    		                                 onASeulementEcritDesPerdants := false;
    		                               end;
    				           end;
    				     ReflRetrogradeParfait,ReflRetrogradeParfaitPhaseGagnant,ReflRetrogradeParfaitPhaseRechScore:
    				       if (coup = coupAnalyseRetrograde) & not(odd(scoreAnalyseRetrograde))
    				         then
    				           begin
    		{perd de ^0}     if scoreAnalyseRetrograde < 0 then
    		                   begin
    		                     s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(scoreAnalyseRetrograde),'','','');
    		                     if (scoreAnalyseRetrograde <> -2) then onASeulementEcritDesPerdants := false;
    		                   end else
    		{annule}         if scoreAnalyseRetrograde = 0 then
    		                   begin
    		                      s2 := ReadStringFromRessource(TextesReflexionID,18);
    		                      onASeulementEcritDesPerdants := false;
    		                   end else
    		{gagne de +^0}   if scoreAnalyseRetrograde > 0 then
    		                   begin
    		                      s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(scoreAnalyseRetrograde),'','','');
    		                      onASeulementEcritDesPerdants := false;
    		                   end;
    				           end
    				         else
    				           begin
    							       if (nroLigne = 1)
    							         then
    							           begin
    							             if odd(note) | (typeDonnees = ReflRetrogradeParfaitPhaseGagnant)
    							               then
    							                 begin
    		{perdant(-X)}			           if note < 0 then
    		                               begin
    		                                 s2 := ChainePerdantAvecScore(note);
    		                               end else
    		{nulle}					             if note = 0 then
    		                               begin
    		                                 s2 := ReadStringFromRessource(TextesReflexionID,11);
    		                                 onASeulementEcritDesPerdants := false;
    		                               end else
    		{gagnant(X)}			           if note > 0 then
    		                               begin
    		                                 s2 := ChaineGagnantAvecScore(note);
    		                                 onASeulementEcritDesPerdants := false;
    		                               end;
    							                 end
    							               else
    							                 begin
      		{perd de ^0}               if note < 0 then
      		                             begin
      		                               s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
      		                               if (note <> -2) then onASeulementEcritDesPerdants := false;
    		                               end else
      		{annule}     					     if note = 0 then
      		                             begin
      		                                s2 := ReadStringFromRessource(TextesReflexionID,18);
      		                                onASeulementEcritDesPerdants := false;
    		                               end else
      		{gagne de +^0}   					 if note > 0 then
      		                             begin
      		                                s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
      		                                onASeulementEcritDesPerdants := false;
    		                               end;
      		                         end;
    							           end
    							         else
    							           begin
    							             if (note = noteLignePrecedente) | (note = ReflexData^.class[1].note)
    							             then
    							               begin
    							                 if odd(note) & (note < 0) & (note = -1)
    		{perdant}                    then
    		                               s2 := ReadStringFromRessource(TextesReflexionID,9)
    		{pas mieux}                  else
    		                               begin
    		                                 s2 := ReadStringFromRessource(TextesReflexionID,16);
    		                                 onASeulementEcritDesPerdants := false;
    		                               end
    		                         end
    							             else
    							               if odd(note)
    							                 then
    							                   begin
    {perdant(-X)}	  		               if note < 0 then
                                         begin
                                           s2 := ChainePerdantAvecScore(note);
                                         end else
    {nulle}                            if note = 0 then
                                         begin
                                           s2 := ReadStringFromRessource(TextesReflexionID,11);
                                           onASeulementEcritDesPerdants := false;
                                         end else
    {gagnant(X)}                       if note > 0 then
                                         begin
                                           s2 := ChaineGagnantAvecScore(note);
                                           onASeulementEcritDesPerdants := false;
                                         end
    							                   end
    							                 else
    							                   begin
      		{pas mieux}                  if (note > noteLignePrecedente) & (note = ReflexData^.class[1].note) then
      		                               begin
      		                                 s2 := ReadStringFromRessource(TextesReflexionID,16);
      		                                 onASeulementEcritDesPerdants := false;
      		                               end else
      		{perd de ^0}  					     if note < 0 then
      		                               begin
      		                                  s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
      		                                  if (note <> -2) then onASeulementEcritDesPerdants := false;
      		                               end else
      		{annule}      					     if note = 0 then
      		                               begin
      		                                  s2 := ReadStringFromRessource(TextesReflexionID,18);
      		                                  onASeulementEcritDesPerdants := false;
      		                               end else
      		{gagne de ^0}   					   if note > 0 then
      		                               begin
      		                                  s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
      		                                  onASeulementEcritDesPerdants := false;
      		                               end;
      		                           end;
    							           end;
    							     end;
    				     ReflParfaitExhaustif,ReflParfaitExhaustPhaseGagnant:
    				       begin
		{perd de ^0}     if note < 0 then
		                   begin
		                     s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,17),NumEnString(note),'','','');
		                     if (note <> -2) then onASeulementEcritDesPerdants := false;
		                   end else
		{annule}         if note = 0 then
		                   begin
		                      s2 := ReadStringFromRessource(TextesReflexionID,18);
		                      onASeulementEcritDesPerdants := false;
		                   end else
		{gagne de +^0}   if note > 0 then
		                   begin
		                      s2 := ParamStr(ReadStringFromRessource(TextesReflexionID,19),NumEnString(note),'','','');
		                      onASeulementEcritDesPerdants := false;
		                   end;
    				       end;
    				     ReflGagnantExhaustif:
    				       begin
    {perdant(-X)}	   if note < 0 then
                       begin
                         s2 := ChainePerdantAvecScore(note);
                       end else
    {nulle}          if note = 0 then
                       begin
                         s2 := ReadStringFromRessource(TextesReflexionID,11);
                         onASeulementEcritDesPerdants := false;
                       end else
    {gagnant(X)}     if note > 0 then
                       begin
                         s2 := ChaineGagnantAvecScore(note);
                         onASeulementEcritDesPerdants := false;
                       end
                   end;
    				     otherwise
    				       s2 := '';
    				   end; {case}

    		   if (s2 <> '') & not(ASeulementCeCaractere(' ',s2)) then
    		     begin

    		       if (delta = kTypeMilieuDePartie) & not(afficheeCommeNoteDeMilieu)
    		           then
                     begin
    {pas exploré}      s2 := ReadStringFromRessource(TextesReflexionID,21);
                       onASeulementEcritDesPerdants := false;
                     end
    		           else
      	             if not((delta = kDeltaFinaleInfini) | (delta = kTypeMilieuDePartie))
    		               then s2 := s2 + '  ['+DeltaFinaleEnChaine(delta)+']';

    		       if avecFleche
    		         then s2 := '  => ' + s2;

    		     end;
    end;
end;





procedure EcritReflexion(const fonctionAppelante : String255);
var yposition,xposition,ypositionDebutListe,j : SInt16;
    s : String255;
    s1,s2,s3,espaceEntreCoup,ChainePourLigneVide : String255;
    a,b : SInt16;
    noteDerniereLigneAffichee : SInt32;
    oldport : grafPtr;
    ligneRect : rect;
    redirectionVersRapport : boolean;
    onASeulementEcritDesPerdants : boolean;
    numeroEngine : SInt32;

   procedure UpdateNoteDerniereLigneAffichee;
   begin
     with ReflexData^ do
       if (class[j].x = coupAnalyseRetrograde) & not(odd(scoreAnalyseRetrograde))
         then noteDerniereLigneAffichee := scoreAnalyseRetrograde
         else
           if class[j].note > -30000 then
             noteDerniereLigneAffichee := class[j].note;
   end;


begin
 if windowReflexOpen & (ReflexData^.longClass <= 0) then EffaceReflexion(HumCtreHum) else
 if windowReflexOpen & (ReflexData^.longClass > 0) then
  begin
    ChainePourLigneVide := '  =>              ';

    redirectionVersRapport := DoitRedirigerContenuFntreReflexionDansRapport;
    if redirectionVersRapport & (fonctionAppelante = 'DoSystemTask')
      then exit(EcritReflexion);

    GetPort(oldport);
    SetPortByWindow(wReflexPtr);
    if interruptionReflexion = pasdinterruption then
      begin
       with ReflexData^ do
        begin
         TextMode(1);
         TextFont(gCassioApplicationFont);
         TextFace(normal);
         TextSize(gCassioSmallFontSize);
         xposition := 3;
         yposition := 0;
         SetRect(lignerect,0,yposition,QDGetPortBound.right,yposition + kHauteurRubanReflexion);
         if redirectionVersRapport
           then WritelnDansRapport('')
           else
             begin
               MyEraseRect(lignerect);
               MyEraseRectWithColor(lignerect,BleuPaleCmd,blackPattern,'');
               RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurNoir,35000));
               if DrawThemeWindowListViewHeader(ligneRect, kThemeStateActive) = NoErr then DoNothing;
               
               RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurNoir,45000));
		           Moveto(0,yposition + kHauteurRubanReflexion);
		           Lineto(QDGetPortBound.right - 1,yposition+kHauteurRubanReflexion);
             end;

         if (typeDonnees = ReflMilieu) |
            (typeDonnees = ReflMilieuExhaustif) |
            (typeDonnees = ReflAnnonceParfait) |
            (typeDonnees = ReflAnnonceGagnant) |
            (typeDonnees = ReflTriGagnant) |
            (typeDonnees = ReflTriParfait)
           then espaceEntreCoup := '  '
           else espaceEntreCoup := '  ';


         RGBForeColor(EclaircirCouleurDeCetteQuantite(gPurNoir,10000));

         s2 := ReadStringFromRessource(TextesReflexionID,22);       {'coup ^0, couleur = ^1'}
         case couleur of
           pionNoir  : s1 := ReadStringFromRessource(TextesListeID,7); {'Noir'}
           pionBlanc : s1 := ReadStringFromRessource(TextesListeID,8); {'Blanc'}
           otherwise   s1 := '******';
         end;
         s := ParamStr(s2,s1,NumEnString(numeroDuCoup),'','');
         s := ReplaceStringByStringInString('…','',s);
         Moveto(xposition,yposition + 12);
         if redirectionVersRapport
           then WritelnDansRapport(s + ' ,  fonctionAppelante = ' + fonctionAppelante)
           else MyDrawString(s);

         case typeDonnees of
           ReflAnnonceParfait                 : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflAnnonceGagnant                 : s := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflParfait                        : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitExhaustif               : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitPhaseGagnant            : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflParfaitPhaseRechScore          : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflGagnant                        : s := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflGagnantExhaustif               : s := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflRetrogradeGagnant              : s := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflRetrogradeParfait              : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflRetrogradeParfaitPhaseGagnant  : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflRetrogradeParfaitPhaseRechScore: s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflTriParfait                     : s := ReadStringFromRessource(TextesReflexionID,1); {'rech. meilleur coup (finale)'}
           ReflTriGagnant                     : s := ReadStringFromRessource(TextesReflexionID,2); {'rech. coup gagnant (finale)'}
           ReflMilieu,
           ReflMilieuExhaustif                : begin
                                                  s2 := ReadStringFromRessource(TextesReflexionID,5); {'milieu de partie, profondeur = '}
                                                  if (prof + 1 > empties) & CassioIsUsingAnEngine(numeroEngine)
                                                    then
                                                      begin
                                                        s2 := ReplaceStringByStringInString('profondeur = ','prof = ',s2);
                                                        s3 := NumEnString(empties) + '@' + NumEnString(ProfondeurMilieuEnPrecisionFinaleEngine(prof + 1, empties)) + '%';
                                                      end
                                                    else
                                                      begin
                                                        s3 := NumEnString(prof + 1);
                                                      end;
                                                  s := ParamStr(s2,s3,'','','');
                                                end;
           otherwise                            s := '';
         end; {case}
         Moveto(xposition,yposition + 24);
         if redirectionVersRapport
           then WritelnDansRapport(s)
           else MyDrawString(s);
         ypositionDebutListe := yposition + 28;
         
         
         RGBForeColor(gPurNoir);

         if (typeDonnees = ReflTriGagnant) |
            (typeDonnees = ReflTriParfait)
           then
	           begin
	             s2 := ReadStringFromRessource(TextesReflexionID,4);      {'tri des coups (prof =  ^0)'}
	             s  := ParamStr(s2,NumEnString(prof + 1),'','','');
	           end
           else
	           begin
	             s2 := ReadStringFromRessource(TextesReflexionID,6);       {'coup n°^0 (sur ^1)'}
	             s  := ParamStr(s2,NumEnString(Compteur),NumEnString(longClass),'','');
	           end;
	       s := ReplaceStringByStringInString('…','',s);
         ypositionDebutListe := ypositionDebutListe + 12;
	       a := xposition;
	       b := ypositionDebutListe;
	       SetRect(lignerect,a,b-10,QDGetPortBound.right,b + 2);
	       if redirectionVersRapport
	         then WritelnDansRapport(s)
	         else
	           begin
      	       MyEraseRect(lignerect);
      	       MyEraseRectWithColor(lignerect,MarronCmd,blackPattern,'');
      	       Moveto(a,b);
      	       MyDrawString(s + ' :');
      	     end;

         ypositionDebutListe := ypositionDebutListe + 1;

         if FALSE then
           begin
		         case typeDonnees of
		           ReflAnnonceParfait                 : s := 'ReflAnnonceParfait';
		           ReflAnnonceGagnant                 : s := 'ReflAnnonceGagnant';
		           ReflParfait                        : s := 'ReflParfait';
		           ReflParfaitExhaustif               : s := 'ReflParfaitExhaustif';
		           ReflParfaitExhaustPhaseGagnant     : s := 'ReflParfaitExhaustPhaseGagnant';
		           ReflParfaitPhaseGagnant            : s := 'ReflParfaitPhaseGagnant';
		           ReflParfaitPhaseRechScore          : s := 'ReflParfaitPhaseRechScore';
		           ReflGagnant                        : s := 'ReflGagnant';
		           ReflGagnantExhaustif               : s := 'ReflGagnantExhaustif';
		           ReflRetrogradeGagnant              : s := 'ReflRetrogradeGagnant';
		           ReflRetrogradeParfait              : s := 'ReflRetrogradeParfait';
		           ReflRetrogradeParfaitPhaseGagnant  : s := 'ReflRetrogradeParfaitPhaseGagnant';
		           ReflRetrogradeParfaitPhaseRechScore: s := 'ReflRetrogradeParfaitPhaseRechScore';
		           ReflTriParfait                     : s := 'ReflTriParfait';
		           ReflTriGagnant                     : s := 'ReflTriGagnant';
		           ReflMilieu                         : s := 'ReflMilieu';
		           ReflMilieuExhaustif                : s := 'ReflMilieuExhaustif';
		           otherwise                            s := 'type donnees inconnu !!';
		         end;
		         ypositionDebutListe := ypositionDebutListe + 12;
		         a := xposition;
		         b := ypositionDebutListe;
		         SetRect(lignerect, a, b - 10 , QDGetPortBound.right, b + 2);
		         if redirectionVersRapport
		           then WritelnDansRapport(s)
		           else
		             begin
      		         MyEraseRect(lignerect);
      		         MyEraseRectWithColor(lignerect,RougePaleCmd,blackPattern,'');
      		         Moveto(a,b);
      		         MyDrawString(s);
		             end;
		       end;

         onASeulementEcritDesPerdants := true;
         noteDerniereLigneAffichee := -12736364;  {ou n'importe quoi d'aberrant}
         for j := 1 to compteur do
           if (j = IndexCoupEnCours)
             then
               begin
                 EcritCoupEnCoursdAnalyse(j,xposition,ypositionDebutListe, onASeulementEcritDesPerdants);
                 UpdateNoteDerniereLigneAffichee;
               end
             else
               begin
                 a := xposition;
                 b := ypositionDebutListe + j*12;

                 ConstruitChaineLigneReflexion(j,class[j].x,class[j].note,class[j].delta,noteDerniereLigneAffichee,true,s2,onASeulementEcritDesPerdants);
                 UpdateNoteDerniereLigneAffichee;

                 if afficheGestionTemps & (s2 <> ChainePourLigneVide)
                   then s3 := ' (' + NumEnString((30+class[j].temps) div 60) + ' s)'
                   else s3 := '';
                 s := CoupEnString(class[j].x,CassioUtiliseDesMajuscules);
                 if (class[j].theDefense >= 11) & (class[j].theDefense <= 88) & (prof + 1 <> 1)
                   then s1 := DefenseEnString(class[j].theDefense)
                   else s1 := '    ';
                 s := s + espaceEntreCoup + s1 + s2 + s3;
                 SetRect(lignerect,a,b-10,QDGetPortBound.right,b + 2);
                 if redirectionVersRapport
                   then WritelnDansRapport(s)
                   else
                     begin
                       MyEraseRect(lignerect);
                       MyEraseRectWithColor(lignerect,OrangeCmd,blackPattern,'');
                       if (class[j].x = coupAnalyseRetrograde)
                         then
                           begin
                             TextFace(italic);
                             DrawResultStringDansFenetreReflexion(s, a, b);
                             TextFace(normal);
                           end
                         else
                           DrawResultStringDansFenetreReflexion(s, a, b);
                     end;
               end;
         for j := compteur + 1 to longClass do
           if j = IndexCoupEnCours
             then
               begin
                 EcritCoupEnCoursdAnalyse(j,xposition,ypositionDebutListe,onASeulementEcritDesPerdants);
               end
             else
               begin
                 a := xposition;
                 b := ypositionDebutListe+j*12;

                 if (typeDonnees <> ReflMilieu)
                   then
                     begin
                       ConstruitChaineLigneReflexion(j,class[j].x,class[j].note,class[j].delta,noteDerniereLigneAffichee,false,s2,onASeulementEcritDesPerdants);
                       UpdateNoteDerniereLigneAffichee;
                     end
                   else
                     begin
                       if (j <= nbCoupsEnTete) then s2 := NoteEnString(class[j].note,false,1,2) else
                       if (j <= nbLignesScoresCompletsProfPrecedente) then s2 := NoteEnString(class[j].note,false,1,2) else
                       if (class[j].note = class[j-1].note) | ((j = IndexCoupEnCours + 1) & ((j = longClass) | (class[j].note = class[j + 1].note)))
                         then s2 := CharToString(' ')+ReadStringFromRessource(TextesReflexionID,16)          {pas mieux}
                         else s2 := NoteEnString(class[j].note,false,1,2);
                     end;

                 if (typeDonnees = ReflMilieu) |
                    (typeDonnees = ReflMilieuExhaustif) |
                    (typeDonnees = ReflAnnonceParfait) |
                    (typeDonnees = ReflAnnonceGagnant) |
                    (typeDonnees = ReflTriGagnant) |
                    (typeDonnees = ReflTriParfait) then
                   if (class[j].note <= -30000) then
                     s2 := '             ';
                 if afficheGestionTemps & (s2 <> '             ')
                   then s3 := ' (' + NumEnString((30 + class[j].temps) div 60) + ' s)'
                   else s3 := '';
                 s := CoupEnString(class[j].x,CassioUtiliseDesMajuscules);
                 if (class[j].theDefense >= 11) & (class[j].theDefense <= 88)
                   then s1 := DefenseEnString(class[j].theDefense)+'  => '
                   else s1 := '    '+'  => ';
                 s := s + espaceEntreCoup + s1 + s2 + s3;
                 SetRect(lignerect, a, b - 10, QDGetPortBound.right, b + 2);

                 if redirectionVersRapport
                   then
                     begin
                       if (class[j].x >= 11) & (class[j].x <= 88) & (prof <> 0) then
                         WritelnDansRapport(s)
                     end
                   else
                     begin
                       MyEraseRect(lignerect);
                       MyEraseRectWithColor(lignerect,JauneCmd,blackPattern,'');
                       if (class[j].x >= 11) & (class[j].x <= 88) & (prof <> 0) then
                         if (class[j].x = coupAnalyseRetrograde)
      	                   then
      	                     begin
      	                       TextFace(italic);
      	                       DrawResultStringDansFenetreReflexion(s , a, b);
      	                       TextFace(normal);
      	                     end
      	                   else
      	                     DrawResultStringDansFenetreReflexion(s, a, b);
      	             end;
               end;
         b := ypositionDebutListe+(longClass + 1)*12;
         if redirectionVersRapport
           then WritelnDansRapport('')
           else
             begin
               MyEraseRect(MakeRect(xposition, b - 10, QDGetPortBound.right, b + 2));
               MyEraseRectWithColor(MakeRect(xposition, b - 10, QDGetPortBound.right, b + 2),MarinePaleCmd, blackPattern,'');
             end;
       end;
     end;

   ValidRect(GetWindowPortRect(wReflexPtr));
   SetPort(oldport);

   if not(redirectionVersRapport) then
     begin
       SetDemandeAffichageReflexionEnSuspens(false);
       affichageReflexion.tickDernierAffichageReflexion := TickCount;
     end;
  end;
  DessineBoiteDeTaille(wReflexPtr);
end;




procedure SauvegardeMeilleureSuiteParOptimalite(var bonPourAfficher,ligneOptimaleJusquaLaFin : boolean);
var i,coup,aux,ChoixX,MeilleurDef : SInt32;
    ok : boolean;
    coupPossible : boolean;
    position : PositionEtTraitRec;
begin

  if debuggage.calculFinaleOptimaleParOptimalite then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('Entrée de SauvegardeMeilleureSuiteParOptimalite');
    end;


  bonPourAfficher := false;
  ChoixX := 44;
  MeilleurDef := 44;
  ok := not(gameOver) & (nbreCoup < 60) & (interruptionReflexion = pasdinterruption);
  ok := ok & (not(CassioEstEnModeSolitaire) | (AQuiDeJouer = -couleurMacintosh));
  if ok then for i := 1 to nbreCoup do
                 ok := (ok & (GetNiemeCoupPartieCourante(i) = partie^^[i].coupParfait));
  if ok then ok := (ok & partie^^[nbreCoup + 1].optimal);
  if ok then
    begin
      coup := partie^^[nbreCoup + 1].coupParfait;
      aux := partie^^[nbreCoup + 2].coupParfait;
      if (coup < 11) | (coup > 88) then ok := false;
      if ok & possibleMove[coup]
         then
           begin
             ChoixX := coup;
             if partie^^[nbreCoup + 2].optimal then
               if (aux >= 11) & (aux <= 88) then
                 MeilleurDef := aux;
           end
         else
           ok := false;
    end;

 if ok then
   begin
     ligneOptimaleJusquaLaFin := true;
     for i := nbreCoup + 1 to 60 do
       begin
         coup := partie^^[i].coupParfait;
         if (coup >= 11) & (coup <= 88) then
           ligneOptimaleJusquaLaFin := ligneOptimaleJusquaLaFin & partie^^[i].optimal;

         {
         WriteNumDansRapport('i = ',i);
         WritelnStringAndCoupDansRapport(', coup = ',coup);
         }
       end;



     if ligneOptimaleJusquaLaFin then
       begin
         bonPourAfficher := true;
         VideMeilleureSuiteInfos;
         position := PositionEtTraitCourant;
         with meilleureSuiteInfos do
           begin
             coupPossible := true;
             for i := nbreCoup + 1 to 60 do
               begin
                 coup := partie^^[i].coupParfait;
                 if ((coup < 11) | (coup > 88)) & (GetTraitOfPosition(position) <> pionVide) then
                   begin
                     ligneOptimaleJusquaLaFin := false;
                     coupPossible := false;
                   end;
                 if coupPossible & (coup >= 11) & (coup <= 88) then
                   begin
                     coupPossible := UpdatePositionEtTrait(position,coup);
                     if coupPossible then SetCoupDansMeilleureSuite(i-(nbreCoup + 1), coup);
                   end;
               end;
             statut := NeSaitPas;
             numeroCoup := nbreCoup;
             couleur := AQuiDeJouer;
             score.noir  := NbPionsDeCetteCouleurDansPosition(pionNoir,position.position);
             score.blanc := NbPionsDeCetteCouleurDansPosition(pionBlanc,position.position);

           end;
       end;
     {
     if ligneOptimaleJusquaLaFin
       then WritelnDansRapport('ligneOptimaleJusquaLaFin = true')
       else WritelnDansRapport('ligneOptimaleJusquaLaFin = false');
     }
   end;
end;


procedure SauvegardeMeilleureSuiteParfaiteParArbreDeJeu(suiteParfaite : PropertyList);
var position : PositionEtTraitRec;
    ok : boolean;
    i : SInt32;
    liste2 : PropertyList;
    coup : SInt32;
begin
  VideMeilleureSuiteInfos;
  position := PositionEtTraitCourant;
  with meilleureSuiteInfos do
    begin


       liste2 := suiteParfaite;

       ok := (liste2 <> NIL);

       for i := nbreCoup + 1 to 60 do
         if ok then
           begin

             coup := GetOthelloSquareOfProperty(liste2^.head);


             if ((coup < 11) | (coup > 88)) & (GetTraitOfPosition(position) <> pionVide)
               then ok := false;

             if ok & (coup >= 11) & (coup <= 88) then
               begin
                 ok := UpdatePositionEtTrait(position,coup);
                 if ok then SetCoupDansMeilleureSuite(i-(nbreCoup + 1), coup);
               end;

             liste2 := liste2^.tail;
             ok := ok & (liste2 <> NIL)
           end;


       statut := NeSaitPas;
       numeroCoup := nbreCoup;
       couleur := AQuiDeJouer;
       score.noir  := NbPionsDeCetteCouleurDansPosition(pionNoir,position.position);
       score.blanc := NbPionsDeCetteCouleurDansPosition(pionBlanc,position.position);

   end;
end;



procedure EffaceMeilleureSuite;
var oldPort : grafPtr;
    ligneRect : rect;
    a : SInt32;
begin
  if windowPlateauOpen then
    begin
      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      if CassioEstEn3D
        then
          begin
            if posVMeilleureSuite + 2 >= GetWindowPortRect(wPlateauPtr).bottom-19
              then SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,QDGetPortBound.right-16,posVMeilleureSuite+3)
              else SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,QDGetPortBound.right,posVMeilleureSuite+3);
            EraseRectDansWindowPlateau(lignerect);
            EcritPromptFenetreReflexion;
          end
        else
          begin
            if avecSystemeCoordonnees
              then a := aireDeJeu.right + EpaisseurBordureOthellier
              else a := posHMeilleureSuite;
            if aireDeJeu.bottom + 11 >= GetWindowPortRect(wPlateauPtr).bottom-19
              then SetRect(lignerect,a,aireDeJeu.bottom + 1,QDGetPortBound.right-16,posVMeilleureSuite)
              else SetRect(lignerect,a,aireDeJeu.bottom + 1,QDGetPortBound.right,posVMeilleureSuite);
            if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1);
            if not(EnModeEntreeTranscript) then EraseRectDansWindowPlateau(lignerect);
            if avecSystemeCoordonnees then DessineBordureDuPlateau2D(kBordureDuBas);
          end;
      DessineBoiteDeTaille(wPlateauPtr);
      MeilleureSuiteEffacee := true;
      SetPort(oldPort);
    end;
end;


procedure EssayeAfficherMeilleureSuiteParArbreDeJeu;
var foo1, foo2 : SInt32;
    fooBool : boolean;
begin
  if (interruptionReflexion = pasdinterruption) | vaDepasserTemps then
    if HumCtreHum & not(CassioEstEnModeSolitaire) then
      begin
        {on essaye d'afficher la meilleure suite, si on la connait par l'arbre de jeu}

        fooBool := ConnaitSuiteParfaiteParArbreDeJeu(foo1, foo2, false);

        (*
        if fooBool
          then WritelnDansRapport('foobool = true')
          else WritelnDansRapport('foobool = false');
        *)
      end;
end;


procedure EffaceMeilleureSuiteSiNecessaire;
begin
  EffaceMeilleureSuite;
  EssayeAfficherMeilleureSuiteParArbreDeJeu;
end;


procedure VideMeilleureSuiteInfos;
begin
  MemoryFillChar(@meilleureSuiteInfos,sizeof(meilleureSuiteInfos),chr(0));
end;

procedure GetMeilleureSuiteInfos(var infos : meilleureSuiteInfosRec);
begin
  infos := meilleureSuiteInfos;
end;

procedure SetMeilleureSuiteInfos(var infos : meilleureSuiteInfosRec);
begin
  meilleureSuiteInfos := infos;
end;

function GetMeilleureSuite : String255;
begin
  if (meilleureSuiteStr <> NIL)
    then GetMeilleureSuite := meilleureSuiteStr^^
    else GetMeilleureSuite := '';
end;

procedure SetMeilleureSuite(s : String255);
begin
  if (meilleureSuiteStr <> NIL)
    then meilleureSuiteStr^^ := s;

  CalculateMeilleureSuiteWidth;
end;


procedure CalculateMeilleureSuiteWidth;
var largeur : SInt32;
    s : String255;
begin
  s := GetMeilleureSuite;

  if (s = '')
    then largeur := 150
    else largeur := Max(150,MyStringWidth(s) + 30);

  (* WritelnDansRapport('s = ' + s);
     WritelnNumDansRapport('largeur = ',largeur);
  *)

  gMeilleureSuiteRect.right       := gMeilleureSuiteRect.left + largeur;
  gMeilleureSuiteRectGlobal.right := gMeilleureSuiteRectGlobal.left + largeur;

end;


procedure DetruitMeilleureSuite;
begin
  meilleureSuiteInfos.statut := NeSaitPas;
  meilleureSuiteInfos.numeroCoup := nbreCoup;
  VideMeilleureSuiteInfos;
  SetMeilleureSuite('');
  EffaceMeilleureSuite;
  MeilleureSuiteEffacee := true;
end;



function MeilleureSuiteInfosEnChaine(nbEspacesEntreCoups : SInt16; avecScore,avecNumeroPremierCoup,enMajuscules,remplacerScoreIncompletParEtc : boolean; whichScore : SInt16) : String255;
var i,coup : SInt16;
    s,s1,s2 : String255;
    espaces : String255;
    doitAfficherSi,doitAfficherNumeroCoup : boolean;
    forcerDoitAfficherSi,forcerNePasAfficherSi : boolean;
    chaineMeilleureSuite : String255;


    function SuiteDesCoups(indexDebut,indexFin : SInt16) : String255;
    var i,coup : SInt16;
        s,result : String255;
    begin
      with meilleureSuiteInfos do
        begin
          result := '';
          i := indexDebut;
          while (GetCoupDansMeilleureSuite(i) <> 0) & (i < indexFin) & (i <= kNbMaxNiveaux) do
		        begin
		         coup := GetCoupDansMeilleureSuite(i);
		         if coup <> 0 then
		           begin
		             if enMajuscules
		               then s := CoupEnStringEnMajuscules(coup)
		               else s := CoupEnStringEnMinuscules(coup);
		             result := result + s + espaces;
		           end;
		         i := i + 1;
		        end;
		    end;
      SuiteDesCoups := result;
    end;

begin

 {WritelnStringAndBoolDansRapport('  =>  remplacerScoreIncompletParEtc = ',remplacerScoreIncompletParEtc);}

 chaineMeilleureSuite := '';
 if (Abs(meilleureSuiteInfos.numeroCoup - nbreCoup) >= 20) | (nbreCoup = 0)
   then
     VideMeilleureSuiteInfos
   else
     begin
         with meilleureSuiteInfos do
           begin
              espaces := '';
              for i := 1 to nbEspacesEntreCoups do
                espaces := espaces + CharToString(' ');


              if debuggage.calculFinaleOptimaleParOptimalite then
                begin
                  WritelnDansRapport('');
                  WritelnDansRapport('Entrée dans MeilleureSuiteInfosEnChaine…');
                  if kNbMaxNiveaux >= -1
                    then
                      begin
	                      for i := -1 to kNbMaxNiveaux do
	                        begin
	                          coup := GetCoupDansMeilleureSuite(i);
	                          WriteDansRapport(CoupEnString(coup,enMajuscules)+' ');
	                        end;
                        WritelnDansRapport('');
                      end
                    else
                      WritelnNumDansRapport('WARNING : kNbMaxNiveaux = ',kNbMaxNiveaux);
                end;

              forcerDoitAfficherSi := false;
              if (statut = ToutEstPerdant) |
                 (statut = ToutEstProbablementPerdant) |
                 (statut = Nulle) |
                 (statut = VictoireBlanche) |
                 (statut = VictoireNoire)
                then forcerDoitAfficherSi := true;

              forcerNePasAfficherSi := false;
              if (nbreCoup > finDePartieOptimale) &
                 (phaseDeLaPartie >= phaseFinale) &
                 ((statut = ReflAnnonceGagnant) |
                  (statut = ReflAnnonceParfait) |
                  (statut = NeSaitPas))
                then forcerNePasAfficherSi := true;

              doitAfficherSi := ((numeroCoup-2 <= finDePartieOptimale) &
                                 (nbreCoup <= finDePartieOptimale) &
                                 (nbreCoup = numeroCoup-2));

              (* WritelnStringAndBoolDansRapport('au tout début, doitAfficherSi = ',doitAfficherSi); *)

              if forcerNePasAfficherSi then doitAfficherSi := false;
              if forcerDoitAfficherSi then doitAfficherSi := true;

              (*
              WritelnNumDansRapport('numeroCoup = ',numeroCoup);
              WritelnNumDansRapport('finDePartieOptimale = ',finDePartieOptimale);
              WritelnNumDansRapport('nbreCoup = ',nbreCoup);
              WritelnStringAndBoolDansRapport('forcerNePasAfficherSi = ',forcerNePasAfficherSi);
              WritelnStringAndBoolDansRapport('forcerDoitAfficherSi = ',forcerDoitAfficherSi);
              WritelnStringAndBoolDansRapport('donc au milieu, doitAfficherSi = ',doitAfficherSi);
              *)

              {doitAfficherNumeroCoup := (phaseDeLaPartie < phaseFinale);}
              doitAfficherNumeroCoup := avecNumeroPremierCoup;

              if RefleSurTempsJoueur &
                 (statut <> ReflAnnonceGagnant) &
                 (statut <> ReflAnnonceParfait) then
              begin
                coup := GetCoupDansMeilleureSuite(-1);
                if (coup < 11) | (coup > 88)  then coup := 44;
                if doitAfficherSi & partie^^[numeroCoup-1].optimal & (partie^^[numeroCoup-1].coupParfait = coup)
                  then doitAfficherSi := false;
                if forcerNePasAfficherSi then doitAfficherSi := false;
                if forcerDoitAfficherSi then doitAfficherSi := true;

                (*
                WritelnStringAndCoupDansRapport('coup = ',coup);
                WritelnStringAndBoolDansRapport('partie^^[numeroCoup-1].optimal = ',partie^^[numeroCoup-1].optimal);
                WritelnStringAndCoupDansRapport('partie^^[numeroCoup-1].coupParfait = ',partie^^[numeroCoup-1].coupParfait);
                WritelnStringAndBoolDansRapport('donc ensuite, doitAfficherSi = ',doitAfficherSi);
                *)

                if (GetCoupDansMeilleureSuite(-1) = GetCoupDansMeilleureSuite(0)) then
                  begin
                    coup := 44;
                    if doitAfficherSi then
                      begin
                        s := ReadStringFromRessource(TextesPlateauID,10);  {si}
                        s1 := NumEnString(numeroCoup-1);
                        chaineMeilleureSuite := s + CharToString(' ') + s1 + CharToString('.');
                      end;
                  end;
                if PossibleMove[coup] then
                  begin
                    if enMajuscules
                      then s2 := CoupEnStringEnMajuscules(coup)
                      else s2 := CoupEnStringEnMinuscules(coup);
                    if doitAfficherSi
                      then
                        begin
                          s := ReadStringFromRessource(TextesPlateauID,10);  {si}
                          s1 := NumEnString(numeroCoup-1);
                          chaineMeilleureSuite := s + CharToString(' ') + s1 + CharToString('.') + s2 + ', ';
                        end
                      else chaineMeilleureSuite := chaineMeilleureSuite + s2 + espaces;
                  end;
              end;

              if (statut = ToutEstPerdant) |
                 (statut = ReflAnnonceGagnant) |
                 (statut = ReflAnnonceParfait) |
                 (statut = ToutEstProbablementPerdant)
                then
                  begin
                    case statut of
                      ReflAnnonceGagnant        : s := ReadStringFromRessource(TextesPlateauID,7);  {rech. coup gagnant (finale)}
                      ReflAnnonceParfait        : s := ReadStringFromRessource(TextesPlateauID,8);  {rech. meilleur coup (finale)}
                      ToutEstPerdant            :
                        if avecScore
                          then
		                        begin  {'tous les coups ^0 sont perdants'}
		                          s := ReadStringFromRessource(TextesPlateauID,11);
		                          s := ParamStr(s,PourcentageEntierEnString(numeroCoup),'','','');
		                        end
		                      else
		                        s := '';
                      ToutEstProbablementPerdant:
                        if avecScore
                          then
		                        begin  {'tous les coups ^0 sont probablement perdants'}
		                          s := ReadStringFromRessource(TextesPlateauID,12);
		                          s := ParamStr(s,PourcentageEntierEnString(numeroCoup),'','','');
		                        end
		                      else
		                        s := '';
                    end;
                    chaineMeilleureSuite := chaineMeilleureSuite + s;
                  end
                else
                  begin

                    if doitAfficherNumeroCoup &
                       not((Statut = NeSaitPas) & (phaseDeLaPartie >= phaseFinale)) then
                      begin
                        s1 := NumEnString(numeroCoup);
                        chaineMeilleureSuite := chaineMeilleureSuite + s1 + CharToString('.');
                      end;

                    coup := GetCoupDansMeilleureSuite(0);
                    if (coup >= 11) & (coup <= 88) then
                      begin
                        if enMajuscules
                          then s := CoupEnStringEnMajuscules(coup)
                          else s := CoupEnStringEnMinuscules(coup);
                        chaineMeilleureSuite := chaineMeilleureSuite + s+espaces;
                      end;

                    if (statut = NeSaitPas)
                      then
	                      begin
	                        chaineMeilleureSuite := chaineMeilleureSuite + SuiteDesCoups(1,kNbMaxNiveaux);

	                        if avecScore & (phaseDeLaPartie >= phaseFinale) & (score.noir + score.blanc > 0) then
	                          begin
		                          if remplacerScoreIncompletParEtc & (score.noir + score.blanc < 64)
		                            then
		                              begin
		                                if (score.noir + score.blanc < 64)
		                                   then chaineMeilleureSuite := chaineMeilleureSuite+'etc.';
		                                if WhichScore > 0
		                                   then chaineMeilleureSuite := Concat('+',NumEnString(WhichScore),' : ',chaineMeilleureSuite);
		                                if WhichScore = 0
		                                   then chaineMeilleureSuite := Concat('= : ',chaineMeilleureSuite);
		                                if WhichScore < 0
		                                   then chaineMeilleureSuite := Concat(NumEnString(WhichScore),' : ',chaineMeilleureSuite);
		                              end
		                            else
			                            begin
			                              s := NumEnString(score.noir);
			                              s1 := NumEnString(score.blanc);
			                              s := CharToString(' ') + s + CharToString('-') + s1;
			                              chaineMeilleureSuite := chaineMeilleureSuite + s;
			                            end;
				                    end;
	                      end
                      else
                        begin
                          if avecScore then
                            begin
                              s := '';
		                          if statut = Nulle
                                 then s := ReadStringFromRessource(TextesPlateauID,13)  {annule}
                                 else
                                   begin
                                     if ((statut = VictoireNoire) & (couleur = pionNoir)) |
                                        ((statut = VictoireBlanche) & (couleur = pionBlanc))
                                        then s := ReadStringFromRessource(TextesPlateauID,14)  {est gagnant}
                                        else s := ReadStringFromRessource(TextesPlateauID,15); {est perdant}
                                   end;
		                           chaineMeilleureSuite := chaineMeilleureSuite + s;


		                           s := NumEnString(numeroCoup) + CharToString('.') + SuiteDesCoups(0,kNbMaxNiveaux);
		                           if remplacerScoreIncompletParEtc
		                             then s := ' (' + s + 'etc.)'
		                             else s := ' (' + s + ')';

		                           chaineMeilleureSuite := chaineMeilleureSuite + s;
		                         end;
                        end;
                  end;
          end;
     end;
  MeilleureSuiteInfosEnChaine := chaineMeilleureSuite;
end;




function MeilleureSuiteEtNoteEnChaine(coul,note,profondeur : SInt16) : String255;
var s,s1 : String255;
    penaliteAjoutee,aux : SInt32;
begin
  s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
  if odd(profondeur)
    then penaliteAjoutee := penalitePourTraitAff
    else penaliteAjoutee := -penalitePourTraitAff;
  note := note+penaliteAjoutee;
  if coul = pionNoir
    then s := s + ': '+CaracterePourNoir
    else s := s + ': '+CaracterePourBlanc;
  if note >= 0
    then s := s + '+'
    else
      begin
        s := s + '-';
        note := -note;
      end;
  if utilisationNouvelleEval
    then
      begin
        aux := note div 100;
        s1 := NumEnString(aux);
        s := s + s1+'.';
        note := note - (aux*100);
        s1 := NumEnString(note);
        if note < 10 then s1 := CharToString('0') + s1;
      end
    else s1 := NumEnString(note);
  MeilleureSuiteEtNoteEnChaine := s + s1;
end;



function LongueurMeilleureSuite : SInt32;
var ligne,foo,s : String255;
begin
  ligne := MeilleureSuiteInfosEnChaine(0,false,false,false,false,0);
  SplitRightBy(ligne, ',', foo, s);
  LongueurMeilleureSuite := (LENGTH_OF_STRING(s) div 2);
end;



{ nbDecimales doit etre 1 ou 2 }
function NoteEnString(note : SInt32; avecSignePlus : boolean; nbEspacesDevant,nbDecimales : SInt16) : String255;
var s : String255;
    aux : SInt32;
begin
  s := '';
  for aux := 1 to nbEspacesDevant do
     s := s + ' ';
  if note < 0
    then
      begin
        s := s + '-';
        note := -note;
      end
    else
      if avecSignePlus
        then s := s + '+';
  if utilisationNouvelleEval
    then
      begin
        if nbDecimales = 2
          then
            begin
              aux := note div 100;
			        note := note-aux*100;
			        if note < 10
			          then NoteEnString := s + NumEnString(aux)+'.0' + NumEnString(note)
			          else NoteEnString := s + NumEnString(aux)+'.' + NumEnString(note);
            end
          else
            begin
              aux := note div 100;
			        note := note-aux*100;
			        NoteEnString := s + NumEnString(aux)+'.' + NumEnString(note div 10)
            end;
      end
    else
      NoteEnString := s + NumEnString(note);
end;


procedure EcritMeilleureSuite;
var marge,a : SInt32;
    s : String255;
    oldPort : grafPtr;
    ligneRect : rect;
begin

 if (Abs(meilleureSuiteInfos.numeroCoup-nbreCoup) >= 20) | (nbreCoup = 0)
   then
     begin
       DetruitMeilleureSuite;
     end
   else
     begin
       if windowPlateauOpen then
         begin
           GetPort(oldPort);
           SetPortByWindow(wPlateauPtr);

           if CassioEstEn3D
             then
               begin
                 if posVMeilleureSuite + 2 >= GetWindowPortRect(wPlateauPtr).bottom-19
                   then SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,GetWindowPortRect(wPlateauPtr).right-16,posVMeilleureSuite+3)
                   else SetRect(lignerect,posHMeilleureSuite,posVMeilleureSuite-9,5000,posVMeilleureSuite+3);
                 EraseRectDansWindowPlateau(lignerect);
                 EcritPromptFenetreReflexion;
                 marge := posHMeilleureSuite;
               end
             else
               begin
                 if avecSystemeCoordonnees
			              then a := aireDeJeu.right + EpaisseurBordureOthellier
			              else a := 0;
                 if aireDeJeu.bottom + 11 >= GetWindowPortRect(wPlateauPtr).bottom-19
                   then SetRect(lignerect,a,aireDeJeu.bottom + 1,GetWindowPortRect(wPlateauPtr).right-16,posVMeilleureSuite)
                   else SetRect(lignerect,a,aireDeJeu.bottom + 1,aireDeJeu.right + 230,posVMeilleureSuite);
                 if (gCouleurOthellier.nomFichierTexture = 'Photographique') then OffsetRect(lignerect,0,1);
                 if (genreAffichageTextesDansFenetrePlateau = kAffichageSousOthellier)
                   then marge := aireDeJeu.left + 3
                   else marge := aireDeJeu.left + 3;
                 if not(EnModeEntreeTranscript) then EraseRectDansWindowPlateau(lignerect);
                 if avecSystemeCoordonnees then DessineBordureDuPlateau2D(kBordureDuBas);
               end;

           s := GetMeilleureSuite;
           s := s + ' ';

           PrepareTexteStatePourMeilleureSuite;
           Moveto(marge,lignerect.bottom-2);
           MyDrawString(s);
           MeilleureSuiteEffacee := false;

           if gCassioUseQuartzAntialiasing then
             if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

           SetPort(oldPort);
         end;
     end;

end;

procedure EcritMeilleureSuiteParOptimalite;
var ok,ligneOptimaleComplete : boolean;
    s : String255;
    tempPhase : SInt32;
begin
  SauvegardeMeilleureSuiteParOptimalite(ok,ligneOptimaleComplete);
  if ok then
    begin
      tempPhase := phaseDeLaPartie;
      phaseDeLaPartie := phaseFinale;
      if ligneOptimaleComplete
        then s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0)
        else s := MeilleureSuiteInfosEnChaine(1,false,true,CassioUtiliseDesMajuscules,false,0) + '[…]';
      if (Pos(s,GetMeilleureSuite) <= 0) then SetMeilleureSuite(s);
      phaseDeLaPartie := tempPhase;
    end;
  if afficheMeilleureSuite & ok then EcritMeilleureSuite;
end;


procedure EcritMeilleureSuiteParArbreDeJeu(suiteParfaite : PropertyList);
var tempPhase : SInt32;
    s : String255;
begin
  tempPhase := phaseDeLaPartie;
  phaseDeLaPartie := phaseFinale;

  SauvegardeMeilleureSuiteParfaiteParArbreDeJeu(suiteParfaite);
  s := MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0);
  if (Pos(s,GetMeilleureSuite) <= 0) then SetMeilleureSuite(s);
  if afficheMeilleureSuite then EcritMeilleureSuite;

  phaseDeLaPartie := tempPhase;
end;


function GetStatutMeilleureSuite : SInt32;
begin
  GetStatutMeilleureSuite := meilleureSuiteInfos.statut;
end;

procedure SetStatutMeilleureSuite(leStatut : SInt32);
begin
  meilleureSuiteInfos.statut := leStatut;
end;


function GetMeilleureSuiteRect : rect;
begin
  GetMeilleureSuiteRect := gMeilleureSuiteRect;
end;

function GetMeilleureSuiteRectGlobal : rect;
begin
  GetMeilleureSuiteRectGlobal := gMeilleureSuiteRectGlobal;
end;


procedure SetMeilleureSuiteRect(theRect : rect);
begin
  gMeilleureSuiteRect := theRect;
end;


procedure CalculateMeilleureSuiteRectGlobal;
var oldPort : grafPtr;
begin
  if windowPlateauOpen then
    begin
      (* WritelnDansRapport('dans CalculateMeilleureSuiteRectGlobal'); *)

      GetPort(oldPort);
      SetPortByWindow(wPlateauPtr);
      gMeilleureSuiteRectGlobal := gMeilleureSuiteRect;
      LocalToGlobalRect(gMeilleureSuiteRectGlobal);

      (*
      WritelnNumDansRapport('gMeilleureSuiteRectGlobal.left = ',gMeilleureSuiteRectGlobal.left);
      WritelnNumDansRapport('gMeilleureSuiteRectGlobal.top = ',gMeilleureSuiteRectGlobal.top);
      WritelnNumDansRapport('gMeilleureSuiteRectGlobal.right = ',gMeilleureSuiteRectGlobal.right);
      WritelnNumDansRapport('gMeilleureSuiteRectGlobal.bottom = ',gMeilleureSuiteRectGlobal.bottom);
      *)

      SetPort(oldPort);
    end;
end;


END.
