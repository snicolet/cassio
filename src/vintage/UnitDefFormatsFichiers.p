UNIT UnitDefFormatsFichiers;



INTERFACE


USES StringTypes, MacTypes, UnitDefOthelloGeneralise;


type formats_connus =
      ( kTypeFichierInconnu,
        kTypeFichierCassio,
        kTypeFichierScriptFinale,
        kTypeFichierScriptZoo,
        kTypeFichierSGF,
        kTypeFichierPGN,
        kTypeFichierGGF,
        kTypeFichierGGFMultiple,
        kTypeFichierXOF,
        kTypeFichierXBoardAlien,
        kTypeFichierZebra,
        kTypeFichierExportTexteDeZebra,
        kTypeFichierEPS,
        kTypeFichierPressePapierCocoth,
        kTypeFichierCocoth,
        kTypeFichierHTMLOthelloBrowser,
        kTypeFichierTranscript,
        kTypeFichierPreferences,
        kTypeFichierTournoiEntreEngines,
        kTypeFichierBibliotheque,
        kTypeFichierGraphe,
        kTypeFichierTHOR_PAR,
        kTypeFichierSuiteDePartiePuisJoueurs,
        kTypeFichierSuiteDeJoueursPuisPartie,
        kTypeFichierLigneAvecJoueurEtPartie,
        kTypeFichierMultiplesLignesAvecJoueursEtPartie,
        kTypeFichierSimplementDesCoups,
        kTypeFichierSimplementDesCoupsMultiple,
        kTypeFichierTortureImportDesNoms,
        kTypeFichierCronjob
        );


type SetOfKnownFormats = set of formats_connus;


var AllKnownFormats : SetOfKnownFormats;


type FormatFichierRec =
       record
         format            : formats_connus;
         tailleOthellier   : SInt16;
         version           : SInt16;
         positionEtPartie  : String255;  { valable dans le cas où format = kTypeFichierCassio }
                                         {                     et format = kTypeFichierSGF  (ligne principale) }
                                         {                     et format = kTypeFichierGGF  (ligne principale) }
                                         {                     et format = kTypeFichierHTMLOthelloBrowser }
                                         {                     et format = kTypeFichierTranscript }
                                         {                     et format = kTypeFichierZebra }
                                         {                     et format = kTypeFichierExportTexteDeZebra }
                                         {                     et format = kTypeFichierSimplementDesCoups }
                                         {                     et format = kTypeFichierLigneAvecJoueurEtPartie }
                                         {                     et format = kTypeFichierEPS }
         joueurs           : String255;  { valable dans le cas où format = kTypeFichierLigneAvecJoueurEtPartie
                                                            et format = kTypeFichierGGF}
       end;


TYPE PartieFormatGGFRec = record
                            positionInitiale : BigOthelloRec;
                            coupsEnAlpha     : String255;
                            joueurNoir       : String255;
                            joueurBlanc      : String255;
                            tournoi          : String255;
                          end;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}









END.
