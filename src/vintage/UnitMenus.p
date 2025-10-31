UNIT UnitMenus;





INTERFACE







 USES UnitDefCassio;




function MyMenuKey(ch : char) : SInt32;

procedure EnableItemPourCassio(whichMenu : MenuRef; whichItem : SInt16);
procedure EssaieDisableForceCmd;
procedure FixeMarqueSurMenuMode(n : SInt16);
procedure FixeMarqueSurMenuBase;
procedure DisableItemTousMenus;
procedure EnableItemTousMenus;
procedure FixeMarquesSurMenus;


(* menu des documents recents *)
function NomLongDejaCalculeDansMenuReouvrir(path : String255; var theLongName : String255) : boolean;
procedure SetReouvrirItem(pathFichier : String255; numeroItem : SInt16);
function GetNomCompletFichierDansMenuReouvrir(numeroItem : SInt16) : String255;
procedure AjoutePartieDansMenuReouvrir(CheminEtNomFichier : String255);
function NumeroItemMenuReouvrirToIndexTablesFichiersAReouvrir(numeroItem : SInt16) : SInt16;
procedure CleanReouvrirMenu;
function SousMenuReouvrirEstVide : boolean;
procedure AssignerLesRaccourcisClaviersMenuReouvrir;


(* menus changeants *)
procedure SetMenusChangeant(modifiers : SInt16);
procedure DisableTitlesOfMenusForRetour;
procedure EnableAllTitlesOfMenus;

(* flash des menus *)
procedure BeginHiliteMenu(menuID : SInt16);
procedure EndHiliteMenu(tickDepart : SInt32; delai : SInt32; sansAttente : boolean);



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Timer, OSUtils, MacWindows
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitTroisiemeDimension, UnitNotesSurCases, UnitUtilitaires, MyStrings
    , UnitPositionEtTrait, UnitModes, UnitPressePapier, UnitPrint, UnitCarbonisation, UnitEntreeTranscript, UnitGestionDuTemps, UnitNormalisation
    , UnitJeu, MyMathUtils, SNMenus, SNEvents, basicfile, UnitServicesRapport, UnitImportDesNoms ;
{$ELSEC}
    ;
    {$I prelink/Menus.lk}
{$ENDC}


{END_USE_CLAUSE}













const gDernierEtatDesMenusEstAvecOption : boolean = false;


function EquivalentClavierEstDansCeMenu(ch : char; whichMenu : MenuRef; var whichItem : SInt16) : boolean;
var i : SInt16;
    cmdChar : char;
begin
  EquivalentClavierEstDansCeMenu := false;
  whichItem := 0;
  for i := 1 to MyCountMenuItems(whichMenu) do
    if IsMenuItemEnabled(whichMenu,i) then
      begin
        GetItemCmd(whichMenu,i,cmdChar);


        WritelnDansRapport('cmdChar = '+cmdChar);

        if (ord(cmdChar) > 0) and ((ch = cmdChar) or (ch = chr(ord(cmdChar)+32))) then
          begin
            EquivalentClavierEstDansCeMenu := true;
            whichItem := i;
            exit;
          end;
      end;
end;

function MyMenuKey(ch : char) : SInt32;
var res : SInt32;
    item : SInt16;
begin
  res := 0;
  if EquivalentClavierEstDansCeMenu(ch,GetAppleMenu,item)        then res := item + 65536*AppleID            else
  if EquivalentClavierEstDansCeMenu(ch,GetFileMenu,item)         then res := item + 65536*FileID             else
  if EquivalentClavierEstDansCeMenu(ch,EditionMenu,item)         then res := item + 65536*EditionID          else
  if EquivalentClavierEstDansCeMenu(ch,PartieMenu,item)          then res := item + 65536*PartieID           else
  if EquivalentClavierEstDansCeMenu(ch,ModeMenu,item)            then res := item + 65536*ModeID             else
  if EquivalentClavierEstDansCeMenu(ch,JoueursMenu,item)         then res := item + 65536*JoueursID          else
  if EquivalentClavierEstDansCeMenu(ch,AffichageMenu,item)       then res := item + 65536*AffichageID        else
  if EquivalentClavierEstDansCeMenu(ch,BaseMenu,item)            then res := item + 65536*BaseID             else
  if EquivalentClavierEstDansCeMenu(ch,SolitairesMenu,item)      then res := item + 65536*SolitairesID       else
  if EquivalentClavierEstDansCeMenu(ch,CouleurMenu,item)         then res := item + 65536*CouleurID          else
  if EquivalentClavierEstDansCeMenu(ch,TriMenu,item)             then res := item + 65536*TriID              else
  if EquivalentClavierEstDansCeMenu(ch,FormatBaseMenu,item)      then res := item + 65536*FormatBaseID       else
  if EquivalentClavierEstDansCeMenu(ch,Picture2DMenu,item)       then res := item + 65536*Picture2DID        else
  if EquivalentClavierEstDansCeMenu(ch,Picture3DMenu,item)       then res := item + 65536*Picture3DID        else
  if EquivalentClavierEstDansCeMenu(ch,CopierSpecialMenu,item)   then res := item + 65536*CopierSpecialID    else
  if EquivalentClavierEstDansCeMenu(ch,GestionBaseWThorMenu,item)then res := item + 65536*GestionBaseWThorID else
  if EquivalentClavierEstDansCeMenu(ch,NMeilleursCoupsMenu,item) then res := item + 65536*NMeilleursCoupID   else
  if EquivalentClavierEstDansCeMenu(ch,ReouvrirMenu,item)        then res := item + 65536*ReouvrirID         else
  if avecProgrammation and
     EquivalentClavierEstDansCeMenu(ch,ProgrammationMenu,item)   then res := item + 65536*ProgrammationID;

  if res <> 0 then BeginHiliteMenu(res div 65536);
  MyMenuKey := res;
end;

procedure EnableItemPourCassio(whichMenu : MenuRef; whichItem : SInt16);
begin
  if not(iconisationDeCassio.encours) then
    MyEnableItem(whichMenu,whichItem);
end;

procedure EssaieDisableForceCmd;
begin
  if RefleSurTempsJoueur or HumCtreHum or (AQuiDeJouer <> couleurMacintosh)
     then MyDisableItem(PartieMenu,ForceCmd);
end;




procedure FixeMarqueSurMenuMode(n : SInt16);
begin

  MyCheckItem(NMeilleursCoupsMenu,1,not(avecEvaluationTotale) and (nbCoupsEnTete = 2));
  MyCheckItem(NMeilleursCoupsMenu,2,not(avecEvaluationTotale) and (nbCoupsEnTete = 3));
  MyCheckItem(NMeilleursCoupsMenu,3,not(avecEvaluationTotale) and (nbCoupsEnTete = 4));
  MyCheckItem(NMeilleursCoupsMenu,4,not(avecEvaluationTotale) and (nbCoupsEnTete = 5));
  MyCheckItem(NMeilleursCoupsMenu,5,not(avecEvaluationTotale) and (nbCoupsEnTete = 6));
  MyCheckItem(NMeilleursCoupsMenu,6,not(avecEvaluationTotale) and (nbCoupsEnTete = 7));
  MyCheckItem(NMeilleursCoupsMenu,7,not(avecEvaluationTotale) and (nbCoupsEnTete = 8));
  MyCheckItem(NMeilleursCoupsMenu,8,not(avecEvaluationTotale) and (nbCoupsEnTete = 9));
  MyCheckItem(NMeilleursCoupsMenu,9,not(avecEvaluationTotale) and (nbCoupsEnTete = 10));
  MyCheckItem(NMeilleursCoupsMenu,10,not(avecEvaluationTotale) and (nbCoupsEnTete = 11));
  MyCheckItem(NMeilleursCoupsMenu,11,not(avecEvaluationTotale) and (nbCoupsEnTete = 12));

  MyCheckItem(ModeMenu,ReflSurTempsAdverseCmd,CassioDoitReflechirSurLeTempsAdverse);
  MyCheckItem(ModeMenu,BiblActiveCmd,avecBibl and bibliothequeLisible);
  MyCheckItem(ModeMenu,VarierOuverturesCmd,gEntrainementOuvertures.CassioVarieSesCoups and (GetCadence <= gEntrainementOuvertures.varierJusquaCetteCadence));
  if InRange(n,0,finDePartie-1) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,not(avecEvaluationTotale) and (nbCoupsEnTete <= 1));
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,avecEvaluationTotale);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,false);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,false);
    end;
  if InRange(n,finDePartie,finDePartieOptimale-1) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,false);
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,false);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,true);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,false);
    end;
  if InRange(n,finDePartieOptimale,65) then
    begin
      MyCheckItem(ModeMenu,MilieuDeJeuNormalCmd,false);
      MyCheckItem(ModeMenu,MilieuDeJeuAnalyseCmd,false);
      MyCheckItem(ModeMenu,FinaleGagnanteCmd,false);
      MyCheckItem(ModeMenu,FinaleOptimaleCmd,true);
    end;
  if ((60-n) <= kNbMaxNiveaux-1) and not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour) then
     begin
      MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
      MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
      MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
      MyEnableItem(ModeMenu,FinaleGagnanteCmd);
      MyEnableItem(ModeMenu,FinaleOptimaleCmd);
     end
   else
     begin
      if not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour) then
        begin
          MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
          MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
          MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
        end;
      MyDisableItem(ModeMenu,FinaleGagnanteCmd);
      MyDisableItem(ModeMenu,FinaleOptimaleCmd);
     end;

  if analyseRetrograde.enCours or (enSetUp or enRetour or iconisationDeCassio.encours)
    then MyDisableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd)
    else EnableItemPourCassio(ModeMenu,ParametrerAnalyseRetrogradeCmd);
  if (nroDernierCoupAtteint >= 20) and not(analyseRetrograde.enCours) and not(enSetUp or enRetour or iconisationDeCassio.encours)
    then EnableItemPourCassio(ModeMenu,AnalyseRetrogradeCmd)
    else MyDisableItem(ModeMenu,AnalyseRetrogradeCmd);

  if (n >= 1) and not(enSetUp or enRetour or iconisationDeCassio.encours)
    then EnableItemPourCassio(PartieMenu,MakeMainBranchCmd)
    else MyDisableItem(PartieMenu,MakeMainBranchCmd);


  if (nbreCoup < nroDernierCoupAtteint) and not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour)
    then
      begin
        MyEnableItem(PartieMenu,ForwardCmd);
      end
    else
      begin
        MyDisableItem(PartieMenu,ForwardCmd);
      end;

  if ((nbreCoup+1) < nroDernierCoupAtteint) and not(enSetUp) and not(enRetour)
    then EnableItemPourCassio(PartieMenu,DoubleForwardCmd)
    else MyDisableItem(PartieMenu,DoubleForwardCmd);

  if (nbreCoup > 0) and not(iconisationDeCassio.encours)
    then MyEnableItem(EditionMenu,AnnulerCmd)
    else MyDisableItem(EditionMenu,AnnulerCmd);
  if (nbreCoup > 0) and not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour)
    then
      begin
        MyEnableItem(PartieMenu,BackCmd);
        MyEnableItem(PartieMenu,RevenirCmd);
        MyEnableItem(PartieMenu,DebutCmd);
      end
    else
      begin
        MyDisableItem(PartieMenu,BackCmd);
        MyDisableItem(PartieMenu,RevenirCmd);
        MyDisableItem(PartieMenu,DebutCmd);
      end;
   if (nbreCoup > 1) and not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour)
     then MyEnableItem(PartieMenu,DoubleBackCmd)
     else MyDisableItem(PartieMenu,DoubleBackCmd);

   if (nroDernierCoupAtteint > 0) and not(iconisationDeCassio.encours) and not(enSetUp) and not(enRetour)
     then MyEnableItem(PartieMenu,DeleteMoveCmd)
     else MyDisableItem(PartieMenu,DeleteMoveCmd);


   if ((60-n) <= 30) and not(enSetUp) and not(enRetour)
    then EnableItemPourCassio(SolitairesMenu,EstSolitaireCmd)
    else MyDisableItem(SolitairesMenu,EstSolitaireCmd);

   if CassioEstEnModeSolitaire and not(enSetUp) and not(enRetour)
     then EnableItemPourCassio(SolitairesMenu,EcrireSolutionSolitaireCmd)
     else MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);



end;


procedure FixeMarqueSurMenuBase;
begin
   if windowListeOpen and (nbPartiesActives > 0) and not(iconisationDeCassio.encours)
     then EnableItemPourCassio(BaseMenu,EnregistrerPartiesBaseCmd)
     else MyDisableItem(BaseMenu,EnregistrerPartiesBaseCmd);
   if {windowListeOpen and }not(positionFeerique) and gameOver and not(enSetUp or enRetour or iconisationDeCassio.encours)
     then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd)
     else MyDisableItem(BaseMenu,AjouterPartieDansListeCmd);
   if windowListeOpen and not(enSetUp or enRetour or iconisationDeCassio.encours)
     then EnableItemPourCassio(BaseMenu,TrierCmd)
     else MyDisableItem(BaseMenu,TrierCmd);
   if windowListeOpen and (nbPartiesActives > 0) and not(iconisationDeCassio.encours)
    then
      begin
        MyEnableItem(BaseMenu,ChangerOrdreCmd);
        MyEnableItem(BaseMenu,OuvrirSelectionneeCmd);
      end
    else
      begin
        MyDisableItem(BaseMenu,ChangerOrdreCmd);
        MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
      end;
   if JoueursEtTournoisEnMemoire and (windowListeOpen or windowStatOpen or windowNuageOpen) and not(iconisationDeCassio.encours)
     then MyEnableItem(BaseMenu,SousSelectionActiveCmd)
     else MyDisableItem(BaseMenu,SousSelectionActiveCmd);
   if windowListeOpen and (nbPartiesActives > 0) and not(gameOver) and not(iconisationDeCassio.encours)
     then MyEnableItem(BaseMenu,JouerSelectionneCmd)
     else MyDisableItem(BaseMenu,JouerSelectionneCmd);
   if windowStatOpen and (nbPartiesActives > 0) and not(gameOver) and not(iconisationDeCassio.encours)
     then MyEnableItem(BaseMenu,JouerMajoritaireCmd)
     else MyDisableItem(BaseMenu,JouerMajoritaireCmd);

end;



procedure DisableItemTousMenus;
  begin
   MyDisableItem(GetFileMenu,NouvellePartieCmd);
   MyDisableItem(GetFileMenu,OuvrirCmd);
   MyDisableItem(GetFileMenu,ReouvrirCmd);
   MyDisableItem(GetFileMenu,CloseCmd);
   MyDisableItem(GetFileMenu,ImporterUnRepertoireCmd);
   MyDisableItem(GetFileMenu,EnregistrerPartieCmd);
   MyDisableItem(GetFileMenu,EnregistrerArbreCmd);
   if not(enRetour) or iconisationDeCassio.encours then
     begin
       MyDisableItem(GetFileMenu,ApercuAvantImpressionCmd);
       MyDisableItem(GetFileMenu,FormatImpressionCmd);
       MyDisableItem(GetFileMenu,ImprimerCmd);
     end;
   MyDisableItem(GetFileMenu,PreferencesCmd);
   if enSetUp then MyDisableItem(GetFileMenu,IconisationCmd);


   if iconisationDeCassio.encours then
     MyDisableItem(EditionMenu,AnnulerCmd);
   MyDisableItem(EditionMenu,CollerCmd);
   MyDisableItem(EditionMenu,EffacerCmd);
   if not(enRetour) or iconisationDeCassio.encours
     then
       begin
         MyDisableItem(EditionMenu,CopierCmd);
         MyDisableItem(EditionMenu,CouperCmd);
       end;
   MyDisableItem(EditionMenu,ToutselectionnerCmd);
   if enSetUp or iconisationDeCassio.encours  then
     MyDisableItem(EditionMenu,ParamPressePapierCmd);
   MyDisableItem(EditionMenu,RaccourcisCmd);



   MyDisableItem(PartieMenu,RevenirCmd);
   MyDisableItem(PartieMenu,DebutCmd);
   MyDisableItem(PartieMenu,BackCmd);
   MyDisableItem(PartieMenu,ForwardCmd);
   MyDisableItem(PartieMenu,DoubleBackCmd);
   MyDisableItem(PartieMenu,DoubleForwardCmd);
   MyDisableItem(PartieMenu,DiagrameCmd);
   MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);
   MyDisableItem(PartieMenu,MakeMainBranchCmd);
   MyDisableItem(PartieMenu,DeleteMoveCmd);
   MyDisableItem(PartieMenu,SetUpCmd);
   MyDisableItem(PartieMenu,ForceCmd);

   MyDisableItem(ModeMenu,CadenceCmd);
   MyDisableItem(ModeMenu,ReflSurTempsAdverseCmd);
   MyDisableItem(ModeMenu,BiblActiveCmd);
   MyDisableItem(ModeMenu,VarierOuverturesCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuNormalCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
   MyDisableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
   MyDisableItem(ModeMenu,FinaleGagnanteCmd);
   MyDisableItem(ModeMenu,FinaleOptimaleCmd);
   MyDisableItem(ModeMenu,CoeffEvalCmd);
   MyDisableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd);
   MyDisableItem(ModeMenu,AnalyseRetrogradeCmd);


   MyDisableItem(JoueursMenu,HumCreHumCmd);
   MyDisableItem(JoueursMenu,MacNoirsCmd);
   MyDisableItem(JoueursMenu,MacBlancsCmd);
   MyDisableItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd);
   MyDisableItem(JoueursMenu,MinuteNoirCmd);
   MyDisableItem(JoueursMenu,MinuteBlancCmd);

   MyDisableItem(AffichageMenu,ChangerEn3DCmd);
   if not(enRetour) or iconisationDeCassio.encours then
     begin
       MyDisableItem(AffichageMenu,Symetrie_A1_H8Cmd);
       MyDisableItem(AffichageMenu,Symetrie_A8_H1Cmd);
       MyDisableItem(AffichageMenu,DemiTourCmd);
     end;
   MyDisableItem(AffichageMenu,ConfigurerAffichageCmd);
   MyDisableItem(AffichageMenu,ReflexionsCmd);
   MyDisableItem(AffichageMenu,RapportCmd);
   MyDisableItem(AffichageMenu,GestionTempsCmd);
   MyDisableItem(AffichageMenu,CommentairesCmd);
   MyDisableItem(AffichageMenu,CourbeCmd);
   MyDisableItem(AffichageMenu,CyclerDansFenetresCmd);
   MyDisableItem(AffichageMenu,PaletteFlottanteCmd);
   MyDisableItem(AffichageMenu,CouleurCmd);
   MyDisableItem(AffichageMenu,SonCmd);

   MyDisableItem(SolitairesMenu,JouerNouveauSolitaireCmd);
   MyDisableItem(SolitairesMenu,ConfigurationSolitaireCmd);
   MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);
   MyDisableItem(SolitairesMenu,EstSolitaireCmd);
   MyDisableItem(SolitairesMenu,ChercherNouveauProblemeDeCoinCmd);
   MyDisableItem(SolitairesMenu,ChercherProblemeDeCoinDansListeCmd);
   MyDisableItem(SolitairesMenu,EstProblemeDeCoinCmd);

   MyDisableItem(BaseMenu,ChargerDesPartiesCmd);
   MyDisableItem(BaseMenu,OuvrirSelectionneeCmd);
   MyDisableItem(BaseMenu,JouerSelectionneCmd);
   MyDisableItem(BaseMenu,JouerMajoritaireCmd);
   MyDisableItem(BaseMenu,StatistiqueCmd);
   MyDisableItem(BaseMenu,ListePartiesCmd);
   MyDisableItem(BaseMenu,NuageDeRegressionCmd);
   MyDisableItem(BaseMenu,SousSelectionActiveCmd);
   {MyDisableItem(BaseMenu,CriteresCmd);}
   MyDisableItem(BaseMenu,AjouterPartieDansListeCmd);
   MyDisableItem(BaseMenu,TrierCmd);
   MyDisableItem(BaseMenu,ChangerOrdreCmd);
   MyDisableItem(BaseMenu,AjouterGroupeCmd);
   MyDisableItem(BaseMenu,ListerGroupesCmd);
   MyDisableItem(BaseMenu,InterversionCmd);

  end;

function SousMenuReouvrirEstVide : boolean;
var k : SInt16;
begin
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        SousMenuReouvrirEstVide := false;
        exit;
      end;
  SousMenuReouvrirEstVide := true;
end;

procedure EnableItemTousMenus;
  begin
   MyEnableItem(GetFileMenu,NouvellePartieCmd);
   MyEnableItem(GetFileMenu,OuvrirCmd);

   if SousMenuReouvrirEstVide
     then MyDisableItem(GetFileMenu,reouvrirCmd)
     else MyEnableItem(GetFileMenu,reouvrirCmd);


   if (NIL <> FrontWindow) then
     begin
	      if (FrontWindow <> wPlateauPtr) then
	        begin
	          if not(enSetUp or enRetour)
	            then MyEnableItem(GetFileMenu,CloseCmd);
	        end;
     end;


   MyEnableItem(GetFileMenu,EnregistrerPartieCmd);
   MyEnableItem(GetFileMenu,EnregistrerArbreCmd);
   MyEnableItem(GetFileMenu,ImporterUnRepertoireCmd);

   if windowPlateauOpen and ImpressionEstPossible
     then
       begin
         MyEnableItem(GetFileMenu,ApercuAvantImpressionCmd);
         MyEnableItem(GetFileMenu,FormatImpressionCmd);
         MyEnableItem(GetFileMenu,ImprimerCmd);
       end
     else
       begin
         MyDisableItem(GetFileMenu,ApercuAvantImpressionCmd);
         MyDisableItem(GetFileMenu,FormatImpressionCmd);
         MyDisableItem(GetFileMenu,ImprimerCmd);
       end;
   MyEnableItem(GetFileMenu,PreferencesCmd);
   if iconisationDeCassio.possible
     then MyEnableItem(GetFileMenu,IconisationCmd)
     else MyDisableItem(GetFileMenu,IconisationCmd);

   MyEnableItem(EditionMenu,AnnulerCmd);
   MyEnableItem(EditionMenu,CouperCmd);
   MyEnableItem(EditionMenu,CopierCmd);
   MyEnableItem(EditionMenu,CollerCmd);
   MyEnableItem(EditionMenu,EffacerCmd);
   MyEnableItem(EditionMenu,ToutSelectionnerCmd);
   MyEnableItem(EditionMenu,ParamPressePapierCmd);
   MyEnableItem(EditionMenu,RaccourcisCmd);

   MyEnableItem(PartieMenu,RevenirCmd);
   MyEnableItem(PartieMenu,DebutCmd);
   MyEnableItem(PartieMenu,BackCmd);
   MyEnableItem(PartieMenu,DoubleBackCmd);
   MyEnableItem(PartieMenu,DoubleForwardCmd);
   MyEnableItem(PartieMenu,DiagrameCmd);
   if not(analyseRetrograde.enCours)
     then MyEnableItem(PartieMenu,TaperUnDiagrammeCmd)
     else MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);
   MyEnableItem(PartieMenu,MakeMainBranchCmd);
   MyEnableItem(PartieMenu,DeleteMoveCmd);
   if not(EnModeEntreeTranscript)
     then MyEnableItem(PartieMenu,SetUpCmd)
     else MyDisableItem(PartieMenu,SetUpCmd);
   if not(RefleSurTempsJoueur) and not(HumCtreHum) then MyEnableItem(PartieMenu,ForceCmd);


   MyEnableItem(ModeMenu,CadenceCmd);
   MyEnableItem(ModeMenu,ReflSurTempsAdverseCmd);
   if bibliothequeLisible
     then MyEnableItem(ModeMenu,BiblActiveCmd)
     else MyDisableItem(ModeMenu,BiblActiveCmd);
   if (GetCadence < minutes5)
     then MyEnableItem(ModeMenu,VarierOuverturesCmd)
     else MyDisableItem(ModeMenu,VarierOuverturesCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuNormalCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuNMeilleursCoupsCmd);
   MyEnableItem(ModeMenu,MilieuDeJeuAnalyseCmd);
   MyEnableItem(ModeMenu,FinaleGagnanteCmd);
   MyEnableItem(ModeMenu,FinaleOptimaleCmd);
   MyEnableItem(ModeMenu,CoeffEvalCmd);
   MyEnableItem(ModeMenu,ParametrerAnalyseRetrogradeCmd);
   MyEnableItem(ModeMenu,AnalyseRetrogradeCmd);
   FixeMarqueSurMenuMode(nbreCoup);


   MyEnableItem(JoueursMenu,HumCreHumCmd);
   MyEnableItem(JoueursMenu,MacNoirsCmd);
   MyEnableItem(JoueursMenu,MacBlancsCmd);
   MyEnableItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd);
   MyEnableItem(JoueursMenu,MinuteNoirCmd);
   MyEnableItem(JoueursMenu,MinuteBlancCmd);

   MyEnableItem(AffichageMenu,ChangerEn3DCmd);
   MyEnableItem(AffichageMenu,Symetrie_A1_H8Cmd);
   MyEnableItem(AffichageMenu,Symetrie_A8_H1Cmd);
   MyEnableItem(AffichageMenu,DemiTourCmd);
   MyEnableItem(AffichageMenu,ConfigurerAffichageCmd);
   MyEnableItem(AffichageMenu,ReflexionsCmd);
   MyEnableItem(AffichageMenu,RapportCmd);
   MyEnableItem(AffichageMenu,GestionTempsCmd);
   MyEnableItem(AffichageMenu,CommentairesCmd);
   MyEnableItem(AffichageMenu,CourbeCmd);
   MyEnableItem(AffichageMenu,CyclerDansFenetresCmd);
   MyEnableItem(AffichageMenu,PaletteFlottanteCmd);
   MyEnableItem(AffichageMenu,CouleurCmd);
   MyEnableItem(AffichageMenu,SonCmd);

   MyEnableItem(SolitairesMenu,JouerNouveauSolitaireCmd);
   MyEnableItem(SolitairesMenu,ConfigurationSolitaireCmd);
   if (60-nbreCoup) <= 20
    then MyEnableItem(SolitairesMenu,EstSolitaireCmd)
    else MyDisableItem(SolitairesMenu,EstSolitaireCmd);
   if CassioEstEnModeSolitaire
     then MyEnableItem(SolitairesMenu,EcrireSolutionSolitaireCmd)
     else MyDisableItem(SolitairesMenu,EcrireSolutionSolitaireCmd);
   MyEnableItem(SolitairesMenu,ChercherNouveauProblemeDeCoinCmd);
   MyEnableItem(SolitairesMenu,ChercherProblemeDeCoinDansListeCmd);
   MyEnableItem(SolitairesMenu,EstProblemeDeCoinCmd);

   if avecGestionBase then
     begin
       MyEnableItem(BaseMenu,ChargerDesPartiesCmd);
       if windowListeOpen and (nbPartiesActives > 0) then MyEnableItem(BaseMenu,ChangerOrdreCmd);
       if {windowListeOpen and }not(positionFeerique) and gameOver then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd);
       if windowListeOpen then MyEnableItem(BaseMenu,TrierCmd);
       if windowListeOpen and (nbPartiesActives > 0) then MyEnableItem(BaseMenu,OuvrirSelectionneeCmd);
       if windowListeOpen and (nbPartiesActives > 0) and not(gameOver) then MyEnableItem(BaseMenu,JouerSelectionneCmd);
       if windowStatOpen and (nbPartiesActives > 0) and not(gameOver) then MyEnableItem(BaseMenu,JouerMajoritaireCmd);
       MyEnableItem(BaseMenu,StatistiqueCmd);
       MyEnableItem(BaseMenu,ListePartiesCmd);
       MyEnableItem(BaseMenu,NuageDeRegressionCmd);
       {if JoueursEtTournoisEnMemoire then MyEnableItem(BaseMenu,CriteresCmd);}
       if JoueursEtTournoisEnMemoire and (windowListeOpen or windowStatOpen or windowNuageOpen)
         then MyEnableItem(BaseMenu,SousSelectionActiveCmd)
         else MyDisableItem(BaseMenu,SousSelectionActiveCmd);
       MyEnableItem(BaseMenu,ListerGroupesCmd);
       MyEnableItem(BaseMenu,AjouterGroupeCmd);
       MyEnableItem(BaseMenu,InterversionCmd);
     end;

  end;



procedure FixeMarquesSurMenus;
var coupUn,i : SInt16;
    err : OSStatus;
  begin

    if (FrontWindow <> NIL) and (FrontWindow <> wPlateauPtr) and not(enSetUp or enRetour or iconisationDeCassio.encours)
      then MyEnableItem(GetFileMenu,CloseCmd)
      else MyDisableItem(GetFileMenu,CloseCmd);

    if not(EnModeEntreeTranscript) and not(enSetUp or enRetour or iconisationDeCassio.encours)
     then MyEnableItem(PartieMenu,SetUpCmd)
     else MyDisableItem(PartieMenu,SetUpCmd);

    if not(analyseRetrograde.enCours) and not(enRetour)
     then MyEnableItem(PartieMenu,TaperUnDiagrammeCmd)
     else MyDisableItem(PartieMenu,TaperUnDiagrammeCmd);

    MyCheckItem(ModeMenu,ReflSurTempsAdverseCmd,CassioDoitReflechirSurLeTempsAdverse);
    MyCheckItem(ModeMenu,BiblActiveCmd,avecBibl and bibliothequeLisible);
    MyCheckItem(ModeMenu,VarierOuverturesCmd,gEntrainementOuvertures.CassioVarieSesCoups and (GetCadence <= gEntrainementOuvertures.varierJusquaCetteCadence));
    if (GetCadence <= minutes5) and not(enSetUp or enRetour or iconisationDeCassio.encours)
      then MyEnableItem(ModeMenu,VarierOuverturesCmd)
      else MyDisableItem(ModeMenu,VarierOuverturesCmd);

    // SetItemCmd(ModeMenu, AnalyseRetrogradeCmd, '');

    SetItemCmd(ModeMenu, AnalyseRetrogradeCmd, '<');
    err := ChangeMenuItemAttributes(ModeMenu, AnalyseRetrogradeCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(ModeMenu, AnalyseRetrogradeCmd, kMenuOptionModifier + kMenuNoCommandModifier);

    SetItemCmd(ModeMenu, FinaleGagnanteCmd, 'G');
    err := ChangeMenuItemAttributes(ModeMenu, FinaleGagnanteCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(ModeMenu, FinaleGagnanteCmd, kMenuOptionModifier + kMenuNoCommandModifier);

    SetItemCmd(ModeMenu, FinaleOptimaleCmd, 'F');
    err := ChangeMenuItemAttributes(ModeMenu, FinaleOptimaleCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(ModeMenu, FinaleOptimaleCmd, kMenuOptionModifier + kMenuNoCommandModifier);

    SetItemCmd(PartieMenu, DoubleForwardCmd, 'P');
    err := ChangeMenuItemAttributes(PartieMenu, DoubleForwardCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(PartieMenu, DoubleForwardCmd, kMenuNoCommandModifier);

    SetItemCmd(PartieMenu, DoubleBackCmd, 'O');
    err := ChangeMenuItemAttributes(PartieMenu, DoubleBackCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(PartieMenu, DoubleBackCmd, kMenuNoCommandModifier);

     SetItemCmd(BaseMenu, StatistiqueCmd, 'S');
    err := ChangeMenuItemAttributes(BaseMenu, StatistiqueCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(BaseMenu, StatistiqueCmd, kMenuNoCommandModifier);

    SetItemCmd(BaseMenu, ListePartiesCmd, 'L');
    err := ChangeMenuItemAttributes(BaseMenu, ListePartiesCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(BaseMenu, ListePartiesCmd, kMenuNoCommandModifier);

    SetItemCmd(BaseMenu, NuageDeRegressionCmd, 'N');
    err := ChangeMenuItemAttributes(BaseMenu, NuageDeRegressionCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(BaseMenu, NuageDeRegressionCmd, kMenuNoCommandModifier);

    SetItemCmd(SolitairesMenu, EstProblemeDeCoinCmd, 'K');
    err := ChangeMenuItemAttributes(SolitairesMenu, EstProblemeDeCoinCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(SolitairesMenu, EstProblemeDeCoinCmd, kMenuOptionModifier + kMenuNoCommandModifier);

    SetItemCmd(AffichageMenu, CourbeCmd, 'K');
    err := ChangeMenuItemAttributes(AffichageMenu, CourbeCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(AffichageMenu, CourbeCmd, kMenuNoCommandModifier);

    {
    SetItemCmd(AffichageMenu, ChangerEn3DCmd, '3');
    err := ChangeMenuItemAttributes(AffichageMenu, ChangerEn3DCmd, kMenuItemAttrUseVirtualKey, kMenuItemAttrIncludeInCmdKeyMatching);
    err := SetMenuItemModifiers(AffichageMenu, ChangerEn3DCmd, kMenuNoCommandModifier);
    }


    MyCheckItem(JoueursMenu,HumCreHumCmd,HumCtreHum);

    if HumCtreHum
      then
        begin
          MyCheckItem(JoueursMenu,MacBlancsCmd,false);
          MyCheckItem(JoueursMenu,MacNoirsCmd,false);
          MyCheckItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd,false);
        end
      else
        begin
          if (couleurMacintosh = pionBlanc) and not(CassioEstEnModeAnalyse)
            then
              begin
                MyCheckItem(JoueursMenu,MacBlancsCmd,true);
                MyCheckItem(JoueursMenu,MacNoirsCmd,false);
                MyCheckItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd,false);
              end;
          if (couleurMacintosh = pionNoir) and not(CassioEstEnModeAnalyse)
            then
              begin
                MyCheckItem(JoueursMenu,MacBlancsCmd,false);
                MyCheckItem(JoueursMenu,MacNoirsCmd,true);
                MyCheckItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd,false);
              end;
          if CassioEstEnModeAnalyse then
            begin
              MyCheckItem(JoueursMenu,MacBlancsCmd,false);
              MyCheckItem(JoueursMenu,MacNoirsCmd,false);
              MyCheckItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd,true);
            end;
        end;


    if HumCtreHum
     then
       begin
         MyDisableItem(JoueursMenu,MacBlancsCmd);
         MyDisableItem(JoueursMenu,MacNoirsCmd);
         MyDisableItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd);
       end
     else
       begin
         MyEnableItem(JoueursMenu,MacBlancsCmd);
         MyEnableItem(JoueursMenu,MacNoirsCmd);
         MyEnableItem(JoueursMenu,MacAnalyseLesDeuxCouleursCmd);
       end;

    MyCheckItem(AffichageMenu,ReflexionsCmd,affichageReflexion.doitAfficher);
    MyCheckItem(AffichageMenu,RapportCmd,windowRapportOpen);
    MyCheckItem(AffichageMenu,GestionTempsCmd,afficheGestionTemps);
    MyCheckItem(AffichageMenu,CommentairesCmd,arbreDeJeu.windowOpen);
    MyCheckItem(AffichageMenu,CourbeCmd,windowCourbeOpen);
    MyCheckItem(AffichageMenu,PaletteFlottanteCmd,windowPaletteOpen);
    MyCheckItem(EditionMenu,RaccourcisCmd,windowAideOpen);
    MyCheckItem(AffichageMenu,SonCmd,avecSon);
    if not(positionFeerique) {and (nroDernierCoupAtteint >= 1)} then
      begin
        if (nroDernierCoupAtteint >= 1)
          then coupUn := GetNiemeCoupPartieCourante(1)
          else coupUn := GetPremierCoupParDefaut;
        if coupUn <> DernierCoupPourMenuAff then
          begin
            case CoupUn of
              56:begin
                   MySetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'F5-->E6','','',''));
                   MySetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'F5-->D3','','',''));
                   MySetMenuItemText(AffichageMenu,DemiTourCmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,8),'F5-->C4','','',''));
                 end;
              65:begin
                   MySetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'E6-->F5','','',''));
                   MySetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'E6-->C4','','',''));
                   MySetMenuItemText(AffichageMenu,DemiTourCmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,8),'E6-->D3','','',''));
                 end;
              43:begin
                   MySetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'C4-->D3','','',''));
                   MySetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'C4-->E6','','',''));
                   MySetMenuItemText(AffichageMenu,DemiTourCmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,8),'C4-->F5','','',''));
                 end;
              34:begin
                   MySetMenuItemText(AffichageMenu,Symetrie_A8_H1Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'D3-->C4','','',''));
                   MySetMenuItemText(AffichageMenu,Symetrie_A1_H8Cmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,7),'D3-->F5','','',''));
                   MySetMenuItemText(AffichageMenu,DemiTourCmd,
                           ReplaceParameters(ReadStringFromRessource(MenusChangeantsID,8),'D3-->E6','','',''));
                 end;
            end;
            DernierCoupPourMenuAff := coupUn;
          end;
      end;


    if {windowListeOpen and }not(positionFeerique) and gameOver and not(enSetUp or enRetour or iconisationDeCassio.encours)
      then EnableItemPourCassio(BaseMenu,AjouterPartieDansListeCmd);
    MyCheckItem(BaseMenu,StatistiqueCmd,windowStatOpen);
    MyCheckItem(BaseMenu,ListePartiesCmd,windowListeOpen);
    MyCheckItem(BaseMenu,NuageDeRegressionCmd,windowNuageOpen);
    MyCheckItem(BaseMenu,SousSelectionActiveCmd,sousSelectionActive);
    MyCheckItem(BaseMenu,InterversionCmd,avecInterversions);


    for i := VertCmd to AutreCouleurCmd do
      MyCheckItem(CouleurMenu,i,gEcranCouleur and (gCouleurOthellier.menuID = CouleurID) and (gCouleurOthellier.menuCmd = i));

    for i := 1 to MyCountMenuItems(Picture2DMenu) do
      MyCheckItem(Picture2DMenu,i,(gCouleurOthellier.menuID = Picture2DID) and (gCouleurOthellier.menuCmd = i));

    for i := 1 to MyCountMenuItems(Picture3DMenu) do
      MyCheckItem(Picture3DMenu,i,(gCouleurOthellier.menuID = Picture3DID) and (gCouleurOthellier.menuCmd = i));

    MyCheckItem(TriMenu,TriParDatabaseCmd,    (gGenreDeTriListe = TriParDistribution));
    MyCheckItem(TriMenu,TriParDateCmd,        (gGenreDeTriListe = TriParDate));
    MyCheckItem(TriMenu,TriParJoueurNoirCmd,  (gGenreDeTriListe = TriParJoueurNoir));
    MyCheckItem(TriMenu,TriParJoueurBlancCmd, (gGenreDeTriListe = TriParJoueurBlanc));
    MyCheckItem(TriMenu,TriParOuvertureCmd,   (gGenreDeTriListe = TriParOuverture));
    MyCheckItem(TriMenu,TriParTheoriqueCmd,   (gGenreDeTriListe = TriParScoreTheorique));
    MyCheckItem(TriMenu,TriParReelCmd,        (gGenreDeTriListe = TriParScoreReel));



    if avecProgrammation then
      begin
        MyCheckItem(ProgrammationMenu,effetspecial1Cmd,GetEffetSpecial);
        MyCheckItem(ProgrammationMenu,effetspecial2Cmd,effetspecial2);
        MyCheckItem(ProgrammationMenu,DemoCmd,enTournoi);
        MyCheckItem(ProgrammationMenu,EcrireDansRapportLogCmd,GetEcritToutDansRapportLog);
        MyCheckItem(ProgrammationMenu,UtiliserMetaphoneCmd,CassioIsUsingMetaphone);
        MyCheckItem(ProgrammationMenu,TraitementDeTexteCmd,EnTraitementDeTexte);
        MyCheckItem(ProgrammationMenu,ArrondirEvaluationsCmd,utilisateurVeutDiscretiserEvaluation);
        MyCheckItem(ProgrammationMenu,UtiliserScoresArbreCmd,not(seMefierDesScoresDeLArbre));

        if (HumCtreHum or (nbreCoup <= 1)) and (interruptionReflexion = pasdinterruption) and (nbPartiesActives > 0) and not(enSetUp or enRetour or iconisationDeCassio.encours)
          then MyEnableItem(ProgrammationMenu,ChercherSolitairesListeCmd)
          else MyDisableItem(ProgrammationMenu,ChercherSolitairesListeCmd);
      end;
  end;


function NomLongDejaCalculeDansMenuReouvrir(path : String255; var theLongName : String255) : boolean;
var k : SInt32;
begin

  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) and
       (nomLongDuFichierAReouvrir[k] <> NIL) and
       (nomDuFichierAReouvrir[k]^^ = path) then
      begin
        theLongName := nomLongDuFichierAReouvrir[k]^^;
        NomLongDejaCalculeDansMenuReouvrir := true;
        exit;
      end;

  NomLongDejaCalculeDansMenuReouvrir := false;
end;


procedure SetReouvrirItem(pathFichier : String255; numeroItem : SInt16);
var NbItemsDansMenu,k : SInt16;
    nomFichier,aux : String255;
    nomLongDuFichier : String255;
begin
  if (numeroItem >= 1) and (numeroItem <= NbMaxItemsReouvrirMenu) and
     (nomDuFichierAReouvrir[numeroItem] <> NIL) then
    begin

      nomFichier := pathFichier;
	    while Pos(':',nomFichier) <> 0 do
	      nomFichier := TPCopy(nomfichier,Pos(':',nomFichier)+1,LENGTH_OF_STRING(nomFichier)-Pos(':',nomFichier));


	    nomLongDuFichier := nomFichier;


	    if EstUnNomDeFichierTronquePourPanther(nomFichier)
	       and not(NomLongDejaCalculeDansMenuReouvrir(pathFichier,nomLongDuFichier))
	       and (PathCompletToLongName(pathFichier,aux) = NoErr)
	      then nomLongDuFichier := aux;


	    if (nomDuFichierAReouvrir[numeroItem] <> NIL)     then nomDuFichierAReouvrir[numeroItem]^^     := pathFichier;
	    if (nomLongDuFichierAReouvrir[numeroItem] <> NIL) then nomLongDuFichierAReouvrir[numeroItem]^^ := nomLongDuFichier;


	    NbItemsDansMenu := MyCountMenuItems(ReouvrirMenu);
	    if NbItemsDansMenu < numeroItem then
	      for k := NbItemsDansMenu+1 to numeroItem do
	        MyInsertMenuItem(ReouvrirMenu,'vide',k);

	    if (nomFichier = '')
	      then
	        begin
	          MySetMenuItemText(ReouvrirMenu,numeroItem,'vide');
	          MyDisableItem(ReouvrirMenu,numeroItem);
	        end
	      else
	        begin
	          MySetMenuItemText(ReouvrirMenu,numeroItem,nomLongDuFichier);
	          MyEnableItem(ReouvrirMenu,numeroItem);
	          MyEnableItem(GetFileMenu,ReouvrirCmd);
	        end;
	   end;
end;

function GetNomCompletFichierDansMenuReouvrir(numeroItem : SInt16) : String255;
var k,compteur : SInt16;
    result : String255;
begin
  result := '';
  compteur := 0;
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        inc(compteur);
        if (compteur = numeroItem) then result := nomDuFichierAReouvrir[k]^^;
      end;
  GetNomCompletFichierDansMenuReouvrir := result;
end;


function NumeroItemMenuReouvrirToIndexTablesFichiersAReouvrir(numeroItem : SInt16) : SInt16;
var k,compteur : SInt16;
begin
  compteur := 0;
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        inc(compteur);
        if (compteur = numeroItem) then
          begin
            NumeroItemMenuReouvrirToIndexTablesFichiersAReouvrir := k;
            exit;
          end;
      end;
  NumeroItemMenuReouvrirToIndexTablesFichiersAReouvrir := -1;
end;


procedure CompacterTableFichiersAReouvrir;
var k,compteur : SInt16;
begin
  compteur := 0;
  for k := 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ <> '') then
      begin
        inc(compteur);
        if (nomDuFichierAReouvrir[compteur] <> NIL)
          then nomDuFichierAReouvrir[compteur]^^ := nomDuFichierAReouvrir[k]^^;
      end;

  for k := compteur + 1 to NbMaxItemsReouvrirMenu do
    if (nomDuFichierAReouvrir[k] <> NIL)
      then nomDuFichierAReouvrir[k]^^ := '';

end;


procedure AssignerLesRaccourcisClaviersMenuReouvrir;
var k : SInt16;
    {err : OSStatus;}
begin
  for k := 1 to Min(9, MyCountMenuItems(ReouvrirMenu)) do
    begin
      // err := SetMenuItemCommandKey(ReouvrirMenu, k, false, ord('0') + k);
      SetItemCmd(ReouvrirMenu, k, chr(ord('0') + k));
      // err := SetMenuItemModifiers(ReouvrirMenu, k, kMenuOptionModifier );
    end;
end;

procedure CleanReouvrirMenu;
var k : SInt32;
    s : String255;
begin

  for k := NbMaxItemsReouvrirMenu downto 1 do
    begin
      MyGetMenuItemText(ReouvrirMenu,k,s);
      if s = 'vide'
       then DeleteMenuItem(ReouvrirMenu,k);
    end;

  CompacterTableFichiersAReouvrir;
  AssignerLesRaccourcisClaviersMenuReouvrir;
end;


procedure AjoutePartieDansMenuReouvrir(CheminEtNomFichier : String255);
var k,i : SInt16;
    PlusDePlaceDansMenu : boolean;
    s : String255;
  begin

    if (CheminEtNomFichier = '') or EstUnNomDeFichierTemporaireDePressePapier(CheminEtNomFichier)
      then exit;

    {si la partie est deja dans le menu, on la met en tete}
    for i := 1 to NbMaxItemsReouvrirMenu do
      if (nomDuFichierAReouvrir[i] <> NIL) and (nomDuFichierAReouvrir[i]^^ = CheminEtNomFichier) then
        begin
          {on decale tout vers le bas jusqu'a i}
          for k := i-1 downto 1 do
            begin
              if (nomDuFichierAReouvrir[k] <> NIL)
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
          CleanReouvrirMenu;
          exit;
        end;

    {reste-t-il de la place ?}
    PlusDePlaceDansMenu := true;
    for k := 1 to NbMaxItemsReouvrirMenu do
      if (nomDuFichierAReouvrir[k] <> NIL) and (nomDuFichierAReouvrir[k]^^ = '') then
        PlusDePlaceDansMenu := false;

    if PlusDePlaceDansMenu
      then  {on ecrase le premier en FIFO }
        begin
          for k := NbMaxItemsReouvrirMenu-1 downto 1 do
            begin
              if nomDuFichierAReouvrir[k] <> NIL
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
        end
      else  {on rajoute au debut en decalant tout vers le bas}
        begin
          for k := NbMaxItemsReouvrirMenu-1 downto 1 do
            begin
              if (nomDuFichierAReouvrir[k] <> NIL)
                then s := nomDuFichierAReouvrir[k]^^
                else s := '';
              SetReouvrirItem(s,k+1);
            end;
          SetReouvrirItem(CheminEtNomFichier,1);
        end;

    CleanReouvrirMenu;
  end;




procedure SetMenusChangeant(modifiers : SInt16);
var option,command,shift,control : boolean;
  begin
    shift := BAND(modifiers,shiftKey) <> 0;
    command := BAND(modifiers,cmdKey) <> 0;
    option := BAND(modifiers,optionKey) <> 0;
    control := BAND(modifiers,controlKey) <> 0;

    if option and not(gDernierEtatDesMenusEstAvecOption)
      then
        begin
          MySetMenuItemText(GetFileMenu,CloseCmd,ReadStringFromRessource(MenusChangeantsID,2));
          MySetMenuItemText(GetFileMenu,EnregistrerPartieCmd,ReadStringFromRessource(MenusChangeantsID,34));
          MySetMenuItemText(JoueursMenu,MinuteNoirCmd,ReadStringFromRessource(MenusChangeantsID,4));
          MySetMenuItemText(JoueursMenu,MinuteBlancCmd,ReadStringFromRessource(MenusChangeantsID,6));
          MySetMenuItemText(SolitairesMenu,JouerNouveauSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,10));
          MySetMenuItemText(SolitairesMenu,EcrireSolutionSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,20));
          MySetMenuItemText(BaseMenu,SousSelectionActiveCmd,ReadStringFromRessource(MenusChangeantsID,12));
          {MySetMenuItemText(FormatBaseMenu,FormatTexteCmd,ReadStringFromRessource(MenusChangeantsID,36));
          MySetMenuItemText(FormatBaseMenu,FormatHTMLCmd,ReadStringFromRessource(MenusChangeantsID,38));
          MySetMenuItemText(FormatBaseMenu,FormatPGNCmd,ReadStringFromRessource(MenusChangeantsID,40));
          MySetMenuItemText(FormatBaseMenu,FormatXOFCmd,ReadStringFromRessource(MenusChangeantsID,42));}
        end
      else
    if not(option) and gDernierEtatDesMenusEstAvecOption then
        begin
          MySetMenuItemText(GetFileMenu,CloseCmd,ReadStringFromRessource(MenusChangeantsID,1));
          MySetMenuItemText(GetFileMenu,EnregistrerPartieCmd,ReadStringFromRessource(MenusChangeantsID,33));
          MySetMenuItemText(JoueursMenu,MinuteNoirCmd,ReadStringFromRessource(MenusChangeantsID,3));
          MySetMenuItemText(JoueursMenu,MinuteBlancCmd,ReadStringFromRessource(MenusChangeantsID,5));
          MySetMenuItemText(SolitairesMenu,JouerNouveauSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,9));
          MySetMenuItemText(SolitairesMenu,EcrireSolutionSolitaireCmd,ReadStringFromRessource(MenusChangeantsID,19));
          MySetMenuItemText(BaseMenu,SousSelectionActiveCmd,ReadStringFromRessource(MenusChangeantsID,11));
          {MySetMenuItemText(FormatBaseMenu,FormatTexteCmd,ReadStringFromRessource(MenusChangeantsID,35));
          MySetMenuItemText(FormatBaseMenu,FormatHTMLCmd,ReadStringFromRessource(MenusChangeantsID,37));
          MySetMenuItemText(FormatBaseMenu,FormatPGNCmd,ReadStringFromRessource(MenusChangeantsID,39));
          MySetMenuItemText(FormatBaseMenu,FormatXOFCmd,ReadStringFromRessource(MenusChangeantsID,41));}
        end;

    gDernierEtatDesMenusEstAvecOption := option;

    if CassioEstEn3D
      then MySetMenuItemText(AffichageMenu,ChangerEn3DCmd,ReadStringFromRessource(MenusChangeantsID,32))
      else MySetMenuItemText(AffichageMenu,ChangerEn3DCmd,ReadStringFromRessource(MenusChangeantsID,31));
  end;


procedure BeginHiliteMenu(menuID : SInt16);
  begin
    HiliteMenu(menuID);
  end;


procedure EndHiliteMenu(tickDepart : SInt32; delai : SInt32; sansAttente : boolean);
  begin
    if not(sansAttente) then
      begin
        while (TickCount < (tickDepart+delai)) do
          begin
            if EventAvail(everyEvent,theEvent) then DoNothing;
          end;
      end;
    HiliteMenu(0);
  end;


procedure DisableTitlesOfMenusForRetour;
  begin
    {WritelnDansRapport('appel de DisableTitlesOfMenusForRetour');}
  end;

procedure EnableAllTitlesOfMenus;
  begin
    {WritelnDansRapport('appel de EnableAllTitlesOfMenus');}
  end;

end.
