Unit  UnitDefMenus;


INTERFACE


USES MacTypes, Menus;

const

   { items du menu Pomme }
     {--------}
     PreferencesDansPommeCmd = 3;    { attention, seulement valable sous Mac OS X ! }

   FileID = 2;
     NouvellePartieCmd = 1;
     OuvrirCmd = 2;
     ReouvrirCmd = 3;
     CloseCmd = 4;
     ImporterUnRepertoireCmd = 5;
     {-------}
     EnregistrerPartieCmd = 7;
     EnregistrerArbreCmd = 8;
     {-------}
     ApercuAvantImpressionCmd = 10;
     FormatImpressionCmd = 11;
     ImprimerCmd = 12;
     {-------}
     IconisationCmd = 14;
     PreferencesCmd = 15;
     {-------}
     QuitCmd = 17;

   EditionID = 3;
     AnnulerCmd = 1;
     {--------}
     CouperCmd = 3;
     CopierCmd = 4;
     CopierSpecialCmd = 5;
     CollerCmd = 6;
     EffacerCmd = 7;
     ToutSelectionnerCmd = 8;
     {---------}
     ParamPressePapierCmd = 10;
     {---------}
     RaccourcisCmd = 12;


   PartieID = 4;
     RevenirCmd = 1;
     DebutCmd = 2;
     {-------}
     BackCmd = 4;
     ForwardCmd = 5;
     DoubleBackCmd = 6;
     DoubleForwardCmd = 7;
     {-------}
     DiagrameCmd = 9;
     TaperUnDiagrammeCmd = 10;
     {-------}
     MakeMainBranchCmd = 12;
     DeleteMoveCmd = 13;
     SetUpCmd = 14;
     {-------}
     ForceCmd = 16;

   ModeID = 5;
     CadenceCmd = 1;
     ReflSurTempsAdverseCmd = 2;
     {------}
     BiblActiveCmd = 4;
     VarierOuverturesCmd = 5;
     {-------}
     MilieuDeJeuNormalCmd = 7;
     MilieuDeJeuNMeilleursCoupsCmd = 8;
     MilieuDeJeuAnalyseCmd = 9;
     FinaleGagnanteCmd = 10;
     FinaleOptimaleCmd = 11;
     {-------}
     CoeffEvalCmd = 13;
     {-------}
     ParametrerAnalyseRetrogradeCmd = 15;
     AnalyseRetrogradeCmd = 16;


   JoueursID = 6;
     HumCreHumCmd = 1;
     {-------}
     MacNoirsCmd = 3;
     MacBlancsCmd = 4;
     MacAnalyseLesDeuxCouleursCmd = 5;
     {-------}
     MinuteNoirCmd = 7;
     MinuteBlancCmd = 8;


   AffichageID = 7;
     ChangerEn3DCmd = 1;
     CouleurCmd = 2;
     {-------}
     Symetrie_A8_H1Cmd = 4;
     Symetrie_A1_H8Cmd = 5;
     DemiTourCmd = 6;
     {-------}
     ConfigurerAffichageCmd = 8;
     {-------}
     PaletteFlottanteCmd = 10;
     RapportCmd = 11;
     ReflexionsCmd = 12;
     GestionTempsCmd = 13;
     CommentairesCmd = 14;
     CourbeCmd = 15;
     CyclerDansFenetresCmd = 16;
     {-------}
     SonCmd = 18;


   BaseID = 8;
     ChargerDesPartiesCmd = 1;
     EnregistrerPartiesBaseCmd = 2;
     {-------}
     OuvrirSelectionneeCmd = 4;
     JouerSelectionneCmd = 5;
     JouerMajoritaireCmd = 6;
     {-------}
     StatistiqueCmd = 8;
     ListePartiesCmd = 9;
     NuageDeRegressionCmd = 10;
     {-------}
     SousSelectionActiveCmd = 12;
     {-------}
     AjouterPartieDansListeCmd = 14;
     ChangerOrdreCmd = 15;
     TrierCmd = 16;
     {-------}
     AjouterGroupeCmd = 18;
     ListerGroupesCmd = 19;
     {------Ñ}
     InterversionCmd = 21;

   SolitairesID = 10;
     JouerNouveauSolitaireCmd = 1;
     ConfigurationSolitaireCmd = 2;
     EcrireSolutionSolitaireCmd = 3;
     EstSolitaireCmd = 4;
     {-------}
     ChercherNouveauProblemeDeCoinCmd = 6;
     EstProblemeDeCoinCmd = 7;
     ChercherProblemeDeCoinDansListeCmd = 8;

   CouleurID = 100;
   (* Picture2DCmd = 1;  {les couleurs sont definies dans UnitDefCouleurs.p}
      Picture3DCmd = 2;
      {----------}
     VertCmd = 4;
     VertPaleCmd = 5;
     VertSapinCmd = 6;
     VertPommeCmd = 7;
     VertTurquoiseCmd = 8;
     VertKakiCmd = 9;
     BleuCmd = 10;
     BleuPaleCmd = 11;
     MarronCmd = 12;
     RougePaleCmd = 13;
     OrangeCmd = 14;
     JauneCmd = 15;
     JaunePaleCmd = 16;
     MarineCmd = 17;
     MarinePaleCmd = 18;
     VioletCmd = 19;
     MagentaCmd = 20;
     MagentaPaleCmd = 21;
     AutreCouleurCmd = 22;
      {-------------}
      NoirCmd  = -1;    {valeur speciale : item impossible}
      BlancCmd = -2;    {valeur speciale : item impossible}
      RougeCmd = 1000;  {valeur speciale : item impossible pour pouvoir avoir le rouge en RGB}
    *)

   TriID = 101;
     TriParDatabaseCmd = 1;
     TriParDateCmd = 2;
     TriParJoueurNoirCmd = 3;
     TriParJoueurBlancCmd = 4;
     TriParOuvertureCmd = 5;
     TriParTheoriqueCmd = 6;
     TriParReelCmd = 7;
     {---------------------}
     TriParClassementCmd = 9;

   CopierSpecialID = 102;
     CopierSequenceCoupsEnTEXTCmd = 1;
     CopierDiagrammePartieEnTEXTCmd = 2;
     CopierPositionCouranteEnTEXTCmd = 3;
     CopierPositionCouranteEnHTMLCmd = 4;
     CopierPositionPourEndgameScriptCmd = 5;
     {---------------------}
     CopierDiagramme10x10Cmd = 7;

   ReouvrirID = 103;


   NMeilleursCoupID = 104;
     MeilleuresNotes2Cmd = 1;
     MeilleuresNotes3Cmd = 2;
     MeilleuresNotes4Cmd = 3;
     MeilleuresNotes5Cmd = 4;
     MeilleuresNotes6Cmd = 5;
     MeilleuresNotes7Cmd = 6;
     MeilleuresNotes8Cmd = 7;
     MeilleuresNotes9Cmd = 8;
     MeilleuresNotes10Cmd = 9;
     MeilleuresNotes11Cmd = 10;
     MeilleuresNotes12Cmd = 11;

   {pour l'instant on ne se sert pas de ce sous-menu}
   NbMeilleuresNotesRetrogradeID = 105;
     MeilleureNoteRetroCmd = 1;
     Meilleures2NotesRetroCmd = 2;
     Meilleures3Notes3RetroCmd = 3;
     Meilleures4Notes4RetroCmd = 4;
     Meilleures5NotesRetroCmd = 5;
     Meilleures6NotesRetroCmd = 6;
     Meilleures7NotesRetroCmd = 7;
     Meilleures8NotesRetroCmd = 8;
     ToutesNotesRetroCmd = 10;


   ProfondeurID = 106;
     Profondeur3Cmd = 1;
     Profondeur5Cmd = 2;
     Profondeur7Cmd = 3;
     Profondeur9Cmd = 4;
     Profondeur11Cmd = 5;
     Profondeur13Cmd = 6;
     Profondeur15Cmd = 7;
     Profondeur17Cmd = 8;
     Profondeur19Cmd = 9;
     Profondeur21Cmd = 10;
     Profondeur23Cmd = 11;
     DixSecParCoupCmd = 13;
     VingtSecParCoupCmd = 14;
     TrenteSecParCoupCmd = 15;
     UneMinParCoupCmd = 16;
     DeuxMinParCoupCmd = 17;
     CinqMinParCoupCmd = 18;
     QuinzeMinParCoupCmd = 19;
     UneHeureParCoupCmd = 20;


   DureeAnalyseID = 107;
     Pendant1MinCmd = 1;
     Pendant2MinCmd = 2;
     Pendant5MinCmd = 3;
     Pendant10MinCmd = 4;
     Pendant30MinCmd = 5;
     Pendant1HeureCmd = 6;
     Pendant2HeuresCmd = 7;
     Pendant6HeuresCmd = 8;
     Pendant12HeuresCmd = 9;
     Jusque45Cmd = 11;
     Jusque40Cmd = 12;
     Jusque35Cmd = 13;
     Jusque30Cmd = 14;
     Jusque25Cmd = 15;
     Jusque20Cmd = 16;
     Jusque15Cmd = 17;
     FinDesTempsCmd = 19;

   FormatBaseID = 108;
     FormatPGNCmd = 1;
     FormatWTBCmd = 2;
     FormatTexteCmd = 3;
     FormatHTMLCmd = 4;
     FormatXOFCmd = 5;
     FormatPARCmd = 6;

   Picture2DID = 109;

   Picture3DID = 110;

   GestionBaseWThorID = 111;
     ChangerTournoiCmd = 1;
     ChangerJoueurNoirCmd = 2;
     ChangerJoueurBlancCmd = 3;
     SelectionnerTheoriqueEgalReelCmd = 5;
     CalculerScoreTheoriqueCmd = 6;
     CreerTournoiCmd = 8;
     CreerJoueurCmd = 9;

   ProgrammationID = 9;
     AjusterModeleLineaireCmd = 1;
     ChercherSolitairesListeCmd = 2;
     VariablesSpecialesCmd = 3;
     OuvrirBiblCmd = 4;
     GestionBaseWThorCmd = 5;
     NettoyerGrapheCmd = 6;
     BenchmarkDeMilieuCmd = 7;
     effetspecial1Cmd = 8;
     effetspecial2Cmd = 9;
     Unused2Cmd = 10;
     Unused3Cmd = 11;
     Unused4Cmd = 12;
     PrecompilerLesSourcesCmd = 13;
     AffCelluleApprentissaCmd = 14;
     EcrireDansRapportLogCmd = 15;
     UtiliserMetaphoneCmd = 16;
     TraitementDeTexteCmd = 17;
     DemoCmd = 18;
     ArrondirEvaluationsCmd = 19;
     UtiliserScoresArbreCmd = 20;

   OuvertureID = 3001;

   TypeAnalyseID = 3006;
     RetrogradeParfaiteCmd = 1;
     RetrogradeGagnanteCmd = 2;
     RetrogradeMilieuCmd = 3;
     RienDuToutCmd = 5;

type MenuCmdRec =
       record
         theMenu : SInt16;
         theCmd : SInt16;
       end;

var gLastTexture2D : MenuCmdRec;
    gLastTexture3D : MenuCmdRec;


	const
		AppleID = 1;
		AboutCmd = 1;

		EditID = 3;
		UndoCmd = 1;
       {------}
		CutCmd = 3;
		CopyCmd = 4;
		PasteCmd = 5;
		ClearCmd = 6;


    menuBarWidth = 18;

    {constant to use to create popupMenus as controls}
    popupTitleBold      = $0100;
		popupTitleItalic    = $0200;
		popupTitleUnderline = $0400;
		popupTitleOutline   = $0800;
		popupTitleShadow    = $1000;
		popupTitleCondense  = $2000;
		popupTitleExtend    = $4000;
		popupTitleNoStyle   = $0800;

		popupFixedWidth				 =  1 * (2**(0));
	  popupVariableWidth		 =  1 * (2**(1));
	  popupUseAddResMenu		 =  1 * (2**(2));
	  popupUseWFont				  = 1 * (2**(3));

		popupTitleLeftJust   = $0000;
		popupTitleCenterJust = $0001;
		popupTitleRightJust  = $00FF;

		popupMenuProc = 1008;

	const
		applemenu : MenuRef = NIL;
		filemenu  : MenuRef = NIL;
		editmenu  : MenuRef = NIL;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
