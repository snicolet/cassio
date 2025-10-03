UNIT UnitMoulinette;


INTERFACE






USES UnitDefCassio;


{ Initialisation de l'unite }
procedure InitUnitMoulinette;                                                                                                                                                       ATTRIBUTE_NAME('InitUnitMoulinette')



{ Utilitaires pour parser des proprietes (entre guillemets) de fichiers PGN ou XOF }
procedure ParserScoreTheoriqueDansFichierPGN(const ligne : String255; var theorique : SInt32);                                                                                      ATTRIBUTE_NAME('ParserScoreTheoriqueDansFichierPGN')
procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; strict : boolean; var pseudo,nomDansThor : String255; var numero : SInt32);                 ATTRIBUTE_NAME('ParserJoueurDansFichierPNG')
procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; numeroTournoiParDefaut : SInt32; var pseudo,nomDansThor : String255; var numero : SInt32); ATTRIBUTE_NAME('ParserTournoiDansFichierPNG')


{ Moulinettes d'import }
function  AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : String255; fichierPGN : FichierTEXT) : OSErr;                                                               ATTRIBUTE_NAME('AjouterPartiesFichierPGNDansListe')
function  AjouterPartiesFichierDestructureDansListe(format : formats_connus; fichier : FichierTEXT) : OSErr;                                                                        ATTRIBUTE_NAME('AjouterPartiesFichierDestructureDansListe')
procedure ImportBaseAllDrawLinesDeBougeard;                                                                                                                                         ATTRIBUTE_NAME('ImportBaseAllDrawLinesDeBougeard')
function  ImporterFichierPartieDansListe(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;                                                     ATTRIBUTE_NAME('ImporterFichierPartieDansListe')
procedure ImporterToutesPartiesRepertoire;                                                                                                                                          ATTRIBUTE_NAME('ImporterToutesPartiesRepertoire')
procedure BaseLogKittyEnFormatThor(nomBaseLogKitty,NomBaseFormatThor : String255);                                                                                                  ATTRIBUTE_NAME('BaseLogKittyEnFormatThor')



{ Moulinettes d'export }
procedure ExportListeAuFormatTexte(descriptionLigne : String255; var nbPartiesExportees : SInt32);                                                                                  ATTRIBUTE_NAME('ExportListeAuFormatTexte')
procedure ExportListeAuFormatPGN;                                                                                                                                                   ATTRIBUTE_NAME('ExportListeAuFormatPGN')
procedure ExportListeAuFormatHTML;                                                                                                                                                  ATTRIBUTE_NAME('ExportListeAuFormatHTML')
procedure ExportListeAuFormatXOF;                                                                                                                                                   ATTRIBUTE_NAME('ExportListeAuFormatXOF')


{ Export d'une partie individuelle }
procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);                                                             ATTRIBUTE_NAME('ExporterPartieDansFichierHTML')
procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);                                                            ATTRIBUTE_NAME('ExporterPartieDansFichierTexte')
procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);                                                              ATTRIBUTE_NAME('ExporterPartieDansFichierPGN')
procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);                                                              ATTRIBUTE_NAME('ExporterPartieDansFichierXOF')


{ Fonction d'ecriture d'une partie illegale dans le rapport }
procedure WritelnPartieIllegaleDansRapport(partieIllegaleEnAlpha : String255);                                                                                                      ATTRIBUTE_NAME('WritelnPartieIllegaleDansRapport')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, Sound, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitRapport, SNEvents, UnitFichiersTEXT, UnitActions
    , UnitEvenement, UnitSolve, UnitCriteres, UnitScannerOthellistique, UnitPositionEtTrait, MyMathUtils, UnitScannerUtils, MyFileSystemUtils
    , MyStrings, MyQuickDraw, UnitNouveauFormat, UnitBaseNouveauFormat, UnitAccesNouveauFormat, UnitRapport, UnitTriListe, UnitRapportImplementation
    , UnitCurseur, UnitUtilitaires, UnitEnvirons, UnitJeu, MyStrings, UnitRapportUtils, UnitEntreesSortiesListe, UnitGameTree
    , UnitArbreDeJeuCourant, UnitImportDesNoms, MyFileSystemUtils, UnitMiniProfiler, UnitDialog, UnitPressePapier, UnitTHOR_PAR, MyMathUtils
    , UnitFichiersTEXT, UnitScannerUtils, UnitGenericGameFormat, UnitFenetres, UnitGestionDuTemps, UnitNormalisation, UnitPackedThorGame, SNEvents
    , UnitScannerOthellistique, UnitRapportWindow, UnitStringSet, UnitFormatsFichiers, UnitFichierAbstrait, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/Moulinette.lk}
{$ENDC}


{END_USE_CLAUSE}








const kLongueurNomsDansURL = 13;


var gOptionsExportBase : record
                           patternLigne : String255;
                           fic : FichierTEXT;
                           subDirectoryName : String255;
                           nomsFichiersUtilises : StringSet;
                         end;
    gTablePartiesJoueursImprobables : StringSet;
    
    


procedure InitUnitMoulinette;
begin
end;






procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; strict : boolean; var pseudo,nomDansThor : String255; var numero : SInt32);
var oldParsingProtection : boolean;
    s1,reste : String255;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);

  Parser2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);

  SetParsingProtectionWithQuotes(oldParsingProtection);

  if not(PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo,strict,nomDansThor,numero)) then
    begin
      if not(strict) then 
        AjoutePseudoInconnu(ReadStringFromRessource(TextesErreursID,7),pseudo,nomDansThor);  {'pseudo inconnu : '}
    end;

end;


procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; numeroTournoiParDefaut : SInt32; var pseudo,nomDansThor : String255; var numero : SInt32);
var oldParsingProtection : boolean;
    s1,reste : String255;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);

  Parser2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);

  SetParsingProtectionWithQuotes(oldParsingProtection);

  if not(PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo,nomDansThor,numero)) then
    begin
      AjoutePseudoInconnu(ReadStringFromRessource(TextesErreursID,8),pseudo,nomDansThor);  {'tournoi inconnu : '}
      numero := numeroTournoiParDefaut;
    end;
end;


procedure ParserDateDansFichierPGN(const ligne : String255; var annee,mois,jour : SInt32);
var date,f1,f2,f3,s1,reste : String255;
    oldParsingSet : SetOfChar;
    oldParsingProtection : boolean;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);

  Parser2(ligne,s1,date,reste);
  date := DeleteSubstringBeforeThisChar('"',date,false);
  date := DeleteSubstringAfterThisChar('"',date,false);

  SetParsingProtectionWithQuotes(oldParsingProtection);

  oldParsingSet := GetParsingCaracterSet;
  SetParsingCaracterSet(['.','-','/']);

  Parser3(date,f1,f2,f3,reste);
  annee := ChaineEnLongint(f1);
  mois  := ChaineEnLongint(f2);
  jour  := ChaineEnLongint(f3);

  SetParsingCaracterSet(oldParsingSet);
end;


procedure ParserScoreTheoriqueDansFichierPGN(const ligne : String255; var theorique : SInt32);
var score,scoreNoir,scoreBlanc : String255;
    oldParsingProtection : boolean;
    theoriqueNoir,theoriqueBlanc : SInt32;
begin
  oldParsingProtection := GetParsingProtectionWithQuotes;
  SetParsingProtectionWithQuotes(true);

  score := DeleteSubstringBeforeThisChar('"',ligne,false);
  score := DeleteSubstringAfterThisChar('"',score,false);

  scoreNoir  := DeleteSubstringAfterThisChar('-',score,false);
  scoreBlanc := DeleteSubstringBeforeThisChar('-',score,false);

  theoriqueNoir  := ChaineEnLongint(scoreNoir);
  theoriqueBlanc := ChaineEnLongint(scoreBlanc);

  if ((theoriqueNoir + theoriqueBlanc) >= 60) &
     ((theoriqueNoir + theoriqueBlanc) <= 64)
    then theorique := theoriqueNoir;

  SetParsingProtectionWithQuotes(oldParsingProtection);
end;


procedure EssayerInterpreterJoueursPGNCommeNomDeFichier(pseudoNoir,pseudoBlanc : String255; var numeroNoir,numeroBlanc : SInt32; var confiance : double_t);
var chaineJoueurs : String255;
    partieJoueursImprobables : String255;
    aux : SInt32;
begin

  (* on crée un nom de fichier fictif le plus ressemblant possible *)

  if (numeroNoir <> kNroJoueurInconnu) &
    (numeroBlanc <> kNroJoueurInconnu)
    then chaineJoueurs := GetNomJoueur(numeroNoir) + ' 32 - 32 ' + GetNomJoueur(numeroBlanc) else
  if (numeroNoir <> kNroJoueurInconnu)
    then chaineJoueurs := GetNomJoueur(numeroNoir) + ' 32 - 32 ' + pseudoBlanc else
  if (numeroBlanc <> kNroJoueurInconnu)
    then chaineJoueurs := pseudoNoir + ' 32 - 32 ' + GetNomJoueur(numeroBlanc)
    else chaineJoueurs := pseudoNoir + ' 32 - 32 ' + pseudoBlanc;

  (* et on essaye de l'interpreter *)
  if TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,6,confiance) then
    if (confiance < 0.80) then
      begin
        partieJoueursImprobables := pseudoNoir + ' - ' + pseudoBlanc;
        if not(MemberOfStringSet(partieJoueursImprobables,aux,gTablePartiesJoueursImprobables)) then
          begin
            AddStringToSet(partieJoueursImprobables,0,gTablePartiesJoueursImprobables);
            ChangeFontColorDansRapport(RougeCmd);
            WritelnDansRapport(UTF8ToAscii(partieJoueursImprobables) + ' --> '+GetNomJoueur(numeroNoir) + ' - ' + GetNomJoueur(numeroBlanc));
            TextNormalDansRapport;
          end;
      end;
end;


procedure WritelnPartieIllegaleDansRapport(partieIllegaleEnAlpha : String255);
var i,longueur,nbCoupsLegaux : SInt32;
    debutLegal,essaiDebut : String255;
    finNonLegale : String255;
begin
  EnleveEspacesDeGaucheSurPlace(partieIllegaleEnAlpha);
  EnleveEspacesDeDroiteSurPlace(partieIllegaleEnAlpha);


  debutLegal := '';
  finNonLegale := partieIllegaleEnAlpha;
  nbCoupsLegaux := 0;

  longueur := LENGTH_OF_STRING(partieIllegaleEnAlpha) div 2;
  for i := 1 to longueur do
    begin
      essaiDebut := TPCopy(partieIllegaleEnAlpha,1,2*i);
      if EstUnePartieOthello(essaiDebut,false)
        then
          begin
            nbCoupsLegaux := i;
            debutLegal := essaiDebut;
            finNonLegale := TPCopy(partieIllegaleEnAlpha, 2*i + 1, 255);
          end
        else
          leave;
    end;

  ChangeFontFaceDansRapport(bold);
  WriteDansRapport('ILLEGALE : ');
  TextNormalDansRapport;
  WriteDansRapport(debutLegal);
  if (finNonLegale <> '') then
    begin
      WriteDansRapport('-');
      ChangeFontFaceDansRapport(bold);
      WriteDansRapport(finNonLegale+' ');
      TextNormalDansRapport;
    end;
  WritelnDansRapport('');
  WritelnDansRapport('');
  TextNormalDansRapport;
end;


function AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : String255; fichierPGN : FichierTEXT) : OSErr;
var ligne,s,coupsPotentiels : String255;
    nroReferencePartieAjoutee : SInt32;
    partieEnAlpha : String255;
    partieLegale : boolean;
    partieDoublon : boolean;
    nbPartiesDansFichierPGN : SInt32;
    nbPartiesImportees : SInt32;
    lastNbPartiesImporteesDansRapport  : SInt32;
    lastNbPartiesFichierPGNDansRapport : SInt32;
    erreurES : OSErr;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    numeroTournoiParDefaut : SInt32;
    nbCoupsRecus : SInt16;
    nbPionsNoirs,nbPionsBlancs : SInt32;
    numeroNoir,numeroBlanc,numeroTournoi : SInt32;
    pseudoNoir,pseudoBlanc,pseudoTournoi : String255;
    annee,tickDepart : SInt32;
    anneeDansRecord,moisDansRecord,jourDansRecord : SInt32;
    nomNoir,nomBlanc,nomTournoi : String255;
    compteurDoublons,aux : SInt32;
    nomFichierPGN : String255;
    nomLongDuFichier : String255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    withMetaphone : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    partieInternet : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt32;
    partieEstDouteuse : boolean;
    doitSauterLesPartiesInternetSansJoueurConnu : boolean;
    tailleFichierPGN : SInt32;
    // ligneNomNoir : String255;
    // ligneNomBlanc : String255;
    lastTickEscapeDansQueue : SInt32;
    positionArrivee : PositionEtTraitRec;
    
label sauter_cette_partie;


begin {AjouterPartiesFichierPGNDansListe}

  if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true) else
  if not(FenetreRapportEstAuPremierPlan) then SelectWindowSousPalette(GetRapportWindow);

  autoVidage := GetAutoVidageDuRapport;
  ecritLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(true);


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tickDepart := TickCount;
  lastTickEscapeDansQueue := TickCount;
  GetTime(myDate);
  positionArrivee := PositionEtTraitCourant;


  nomFichierPGN := ExtraitNomDirectoryOuFichier(GetNameOfFSSpec(fichierPGN.theFSSpec));
  erreurES      := FSSpecToLongName(fichierPGN.theFSSpec, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFichierPGN := DeleteSubstringAfterThisChar('.',nomFichierPGN,false);

  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;

  numeroTournoi := -1;
  if (myDate.month <= 6) & TrouveNumeroDuTournoi('parties internet (1-6)',numeroTournoiParDefaut,0) then DoNothing;
  if (myDate.month >  6) & TrouveNumeroDuTournoi('parties internet (7-12)',numeroTournoiParDefaut,0) then DoNothing;
  if numeroTournoi < 0 then numeroTournoiParDefaut := kNroTournoiDiversesParties;
  annee := myDate.year;


  erreurES := OuvreFichierTexte(fichierPGN);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomFichierPGN,erreurES);
      AjouterPartiesFichierPGNDansListe := erreurES;
      exit(AjouterPartiesFichierPGNDansListe);
    end;
    
  erreurES := GetTailleFichierTexte(fichierPGN, tailleFichierPGN);
  // WritelnNumDansRapport('tailleFichierPGN = ',tailleFichierPGN);


  compteurDoublons                            := 0;
  nbPartiesDansFichierPGN                     := 0;
  nbPartiesImportees                          := 0;
  lastNbPartiesImporteesDansRapport           := 0;
  lastNbPartiesFichierPGNDansRapport          := 0;
  
  erreurES                                    := NoErr;
  utilisateurVeutSortir                       := false;
  ligne                                       := '';
  tableDoublons                               := MakeEmptyStringSet;
  gTablePartiesJoueursImprobables             := MakeEmptyStringSet;
  
  
  doitSauterLesPartiesInternetSansJoueurConnu := (tailleFichierPGN >= 1000000);
  

  (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
     dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(nomsReelsARajouterDansBase);
      DisposeStringSet(pseudosAyantUnNomReel);
      DisposeStringSet(pseudosSansNomReel);
    end;

  while not(EOFFichierTexte(fichierPGN,erreurES)) & not(utilisateurVeutSortir) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      if (Pos('[Event',ligne) = 0) then
        begin
          erreurES := ReadlnDansFichierTexte(fichierPGN , s);
          ligne := s;
        end;

      {WritelnDansRapport(ligne);}

      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne = '') | (ligne[1] = '%')
        then
          begin
          end
        else
          begin

            if Pos('[Event',ligne) > 0 then
              begin  {lire une partie}

                {WritelnDansRapport('');}
                {WritelnDansRapport(ligne);}

                partieComplete := false;
                partieLegale := true;
                partieInternet := false;
                partieEnAlpha := '';
                nbCoupsRecus := 0;
                pseudoNoir := '';
                pseudoBlanc := '';
                pseudoTournoi := '';
                numeroBlanc := -1;
                numeroNoir := -1;
                anneeDansRecord := -1;
                moisDansRecord := -1;
                jourDansRecord := -1;
                theorique := -1;

                ParserTournoiDansFichierPNG(nomDictionnaireDesPseudos,ligne,numeroTournoiParDefaut,pseudoTournoi,nomTournoi,numeroTournoi);

                repeat
                  erreurES := ReadlnDansFichierTexte(fichierPGN,s);
      			      ligne := s;
      			      EnleveEspacesDeGaucheSurPlace(ligne);

      			      {WritelnDansRapport(ligne);}
      			      {Sysbeep(0);
      			      AttendFrappeClavier;}
      			      
      			      

      			      if (Pos('[White ',ligne) > 0) | (Pos('[White"',ligne) > 0)
      			        then 
      			          begin
      			            // ligneNomBlanc := ligne;
      			            if partieInternet 
      			              then 
      			                begin
      			                  withMetaphone := CassioIsUsingMetaphone;
      			                  SetCassioIsUsingMetaphone(false);
      			                  ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,true,pseudoBlanc,nomBlanc,numeroBlanc);
      			                  SetCassioIsUsingMetaphone(withMetaphone);
      			                end
      			              else
      			                begin
      			                  ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,false,pseudoBlanc,nomBlanc,numeroBlanc);
      			                end;
      			          end 
      			        else

      			      if (Pos('[Black ',ligne) > 0) | (Pos('[Black"',ligne) > 0)
      			        then
      			          begin
      			            // ligneNomNoir := ligne;
      			            if partieInternet 
      			              then 
      			                begin
      			                  withMetaphone := CassioIsUsingMetaphone;
      			                  SetCassioIsUsingMetaphone(false);
      			                  ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,true,pseudoNoir,nomNoir,numeroNoir);
      			                  SetCassioIsUsingMetaphone(withMetaphone);
      			                end
      			              else
      			                begin
      			                  ParserJoueurDansFichierPNG(nomDictionnaireDesPseudos,ligne,false,pseudoNoir,nomNoir,numeroNoir);
      			                end;
      			          end
      			        else

      			      if (Pos('[Site "kurnik',ligne) > 0) | (Pos('[Site "www.kurnik',ligne) > 0) |
      			         (Pos('[Site "playok',ligne) > 0) | (Pos('[Site "www.playok',ligne) > 0) |
      			         (Pos('[Site "VOG',ligne) > 0)
      			        then partieInternet := true else

      			      if (Pos('[Date "',ligne) > 0)
      			        then ParserDateDansFichierPGN(ligne,anneeDansRecord,moisDansRecord,jourDansRecord) else

      			      if (Pos('[TheoricalScore "',ligne) > 0) | (Pos('[TheoreticalScore "',ligne) > 0)
      			        then ParserScoreTheoriqueDansFichierPGN(ligne,theorique) else

      			      if (Pos('.',ligne) > 0) & (Pos('[',ligne) = 0) then
      			        begin  {coup(s)}

      			          coupsPotentiels := ligne;
      			          CompacterPartieAlphanumerique(coupsPotentiels,kCompacterEnMajuscules);

      			          if (coupsPotentiels <> '') then
      			            begin
      			              partieEnAlpha := partieEnAlpha + coupsPotentiels;
      			              nbCoupsRecus := nbCoupsRecus + (LENGTH_OF_STRING(coupsPotentiels) div 2);
      			            end;
      			        end;

      			      partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs);

			            utilisateurVeutSortir := utilisateurVeutSortir | Quitter ;
			            if ((TickCount - lastTickEscapeDansQueue) > 0) then
			              begin
			                utilisateurVeutSortir := utilisateurVeutSortir | EscapeDansQueue;
			                lastTickEscapeDansQueue := TickCount;
			              end;

                until partieComplete |
                      InRange(Pos('0-1',ligne),1,2) |
                      InRange(Pos('1/2-1/2',ligne),1,2) |
                      InRange(Pos('1-0',ligne),1,2) |
                      (Pos('[Event',ligne) > 0) |
                      EOFFichierTexte(fichierPGN,erreurES) |
                      utilisateurVeutSortir;

                if Pos('[Event',ligne) = 0 then ligne := '';

                (*
                WritelnDansRapport(partieEnAlpha);
                WritelnDansRapport(pseudoNoir);
                WritelnDansRapport(pseudoBlanc);
                *)
                
                (*
                if (Pos('Caspard',nomNoir) > 0) | (Pos('Caspard',nomBlanc) > 0) then
                  begin
                    WritelnDansRapport(partieEnAlpha);
                    WritelnDansRapport(ligneNomNoir);
                    WritelnDansRapport(ligneNomBlanc);
                  end;
                *)

                partieLegale := (nbCoupsRecus > 10) & EstUnePartieOthelloAvecMiroir(partieEnAlpha);

                {on cherche si on a deja mis la partie}
                partieDoublon := false;
                if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) &
                   MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
                   begin
                     partieDoublon := true;
                     WritelnDansRapport(ReadStringFromRessource(TextesErreursID,9) + LeftOfString(partieEnAlpha,60));  {'doublon : '}
                     compteurDoublons := compteurDoublons + 1;
                   end;
                   
                inc(nbPartiesDansFichierPGN);
                
                

                if partieLegale 
                   & not(partieDoublon) 
                   & not(doitSauterLesPartiesInternetSansJoueurConnu & partieInternet & (numeroNoir = 0) & (numeroBlanc = 0)) then
                  begin

                    partieEstDouteuse := false;

                    AddStringToSet(partieEnAlpha,0,tableDoublons);
                    AddStringToSet(Concat(partieEnAlpha,' '),0,tableDoublons);

                    if (anneeDansRecord > 0) then annee := anneeDansRecord;

                    if partieInternet & (numeroTournoi = numeroTournoiParDefaut) then
                      begin
                        if (moisDansRecord >= 1) & (moisDansRecord <= 6)  then numeroTournoi := kNroTournoiPartiesInternet_1_6 else
                        if (moisDansRecord >= 7) & (moisDansRecord <= 12) then numeroTournoi := kNroTournoiPartiesInternet_7_12
                          else numeroTournoi := kNroTournoiPartiesInternet;
                      end;


                    if not(partieComplete) then
                      begin
                        if partieInternet & (nbCoupsRecus >= 40) & PeutCompleterPartieAvecLigneOptimale(partieEnAlpha)
                          then
                            begin
                              (*ChangeFontColorDansRapport(BleuCmd);
                              WritelnDansRapport(ReadStringFromRessource(TextesErreursID,10));  // 'partie complétée :-)
                              TextNormalDansRapport;
                              *)
                            end
                          else
                            begin
                              if partieInternet then goto sauter_cette_partie;
                              
                              WritelnNumDansRapport('nbCoupsRecus = ',nbCoupsRecus);
                              ChangeFontColorDansRapport(VertCmd);
                              WritelnDansRapport(ReadStringFromRessource(TextesErreursID,11)+LeftOfString(partieEnAlpha,60));  // 'incomplete : '
                              TextNormalDansRapport;
                            end;
                      end;


                    SetAutorisationCalculsLongsSurListe(false);
                    if sousSelectionActive then DoChangeSousSelectionActive;

                    if AjouterPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieNF,nroReferencePartieAjoutee) then
                      begin
                        SetPartieDansListeEstDouteuse(nroReferencePartieAjoutee,partieEstDouteuse);
                        inc(nbPartiesImportees);
                      end;

                    SetAutorisationCalculsLongsSurListe(true);


                  sauter_cette_partie:
                    
                  end;
                  
                  
                  
                  
                
                if ((nbPartiesDansFichierPGN mod 2000 = 0) & (lastNbPartiesFichierPGNDansRapport <> nbPartiesDansFichierPGN)) |
                   ((nbPartiesImportees mod 200 = 0) & (lastNbPartiesImporteesDansRapport <> nbPartiesImportees))
                  then
                    begin
                      lastNbPartiesImporteesDansRapport := nbPartiesImportees;
                      lastNbPartiesFichierPGNDansRapport := nbPartiesDansFichierPGN;
                      WriteNumDansRapport('',nbPartiesImportees);
                      WritelnNumDansRapport('/',nbPartiesDansFichierPGN);
                      TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
                      CalculsEtAffichagePourBase(false,false);
                    end;
                    
                    
                PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
                if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

              end;


          end;
    end;

  DisposeStringSet(tableDoublons);
  DisposeStringSet(gTablePartiesJoueursImprobables);

  erreurES := FermeFichierTexte(fichierPGN);
  
  
  if utilisateurVeutSortir 
    then WritelnDansRapport('Lecture du fichier interrompue par l''utilisateur...');
    
  WritelnDansRapport('temps de lecture = ' + SecondesEnJoursHeuresSecondes((TickCount - tickDepart + 30) div 60));
    
  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(GetNameOfFSSpec(fichierPGN.theFSSpec))
    then
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,44),NumEnString(nbPartiesImportees),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,45),NumEnString(nbPartiesImportees),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,42),NumEnString(nbPartiesImportees),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,43),NumEnString(nbPartiesImportees),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}
  WritelnDansRapport('');
  
  
  RemettreLeCurseurNormalDeCassio;

  SetAutorisationCalculsLongsSurListe(true);
  
  if not(EstLaPositionCourante(positionArrivee)) then DoNouvellePartie(true);

  ForceDoubleTriApresUnAjoutDeParties(gGenreDeTriListe);
  TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
  CalculsEtAffichagePourBase(false,false);

  SetAutoVidageDuRapport(autoVidage);
  SetEcritToutDansRapportLog(ecritLog);

  RemettreLeCurseurNormalDeCassio;

  AjouterPartiesFichierPGNDansListe := erreurES;
end;




function AjouterPartiesFichierDestructureDansListe(format : formats_connus; fichier : FichierTEXT) : OSErr;
var nroReferencePartieAjoutee : SInt32;
    partieEnAlpha : String255;
    chaineJoueurs : String255;
    nomsDesJoueursParDefaut : String255;
    partieLegale : boolean;
    nbPartiesDansFic : SInt32;
    nbPartiesIllegales : SInt32;
    erreurES : OSErr;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    nbCoupsRecus : SInt16;
    nbPionsNoirs,nbPionsBlancs : SInt32;
    numeroNoir,numeroBlanc,numeroTournoi : SInt32;
    annee,tickDepart : SInt32;
    compteurDoublons,aux : SInt32;
    nomFic : String255;
    nomLongDuFichier : String255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    partieDoublon : boolean;
    joueursTrouves : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt32;
    derniereLigneLue : String255;
    nombreDeLignesLues : SInt32;
    confianceDansLesJoueurs : double_t;
    bidReal : double_t;
    partieEstDouteuse : boolean;
    myZone : FichierAbstrait;


  function GetNextLineDansFichierDestructure(var s : String255) : OSErr;
  begin
    GetNextLineDansFichierDestructure := ReadlnDansFichierAbstrait(myZone,s);
    EnleveEspacesDeGaucheSurPlace(s);
    derniereLigneLue := s;
    inc(nombreDeLignesLues);
  end;


  function TrouveJoueurs : String255;
  var s,result : String255;
  begin
    result := derniereLigneLue;

    while (result = '') & not(utilisateurVeutSortir) & (erreurES = NoErr) & not(EOFFichierAbstrait(myZone,erreurES)) do
      begin
        erreurES := GetNextLineDansFichierDestructure(s);
        result := result + s;
        utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue;
      end;

    TrouveJoueurs := result;
    derniereLigneLue := '';
  end;

  function TrouvePartie : String255;
  var s,result : String255;
      partieComplete : boolean;
      partieIllegale : boolean;
      nbCoups,dernierNbCoups : SInt32;
      positionDuCoupDansChaine : SInt16;
      square : SInt16;
  begin
    partieComplete := false;
    partieIllegale := false;
    result := '';
    dernierNbCoups := -1000;
    nbCoups := -500;

    repeat
      erreurES := GetNextLineDansFichierDestructure(s);

      if (s <> '') then
        begin

          EnleveEspacesDeGaucheSurPlace(s);
          square := ScannerStringPourTrouverCoup(1,s,positionDuCoupDansChaine);

          if (positionDuCoupDansChaine < 10) then
            begin

              result := result + s;

              if EstUnePartieOthelloAvecMiroir(result) then
                partieComplete := EstUnePartieOthelloTerminee(result,false,nbPionsNoirs,nbPionsBlancs);

              partieIllegale := (result = '') | not(EstUnePartieOthello(result,false));

              {
              WritelnDansRapport('s = '+s);
              WritelnDansRapport('result = '+result);
              WritelnStringAndBooleenDansRapport('partieIllegale = ',partieIllegale);
              WritelnDansRapport('');}
            end;

          dernierNbCoups := nbCoups;
          nbCoups := LENGTH_OF_STRING(result) div 2;

        end;

      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue;

    until (nbCoups = dernierNbCoups) | partieComplete | partieIllegale | utilisateurVeutSortir | (erreurES <> NoErr) | EOFFichierAbstrait(myZone,erreurES);

    TrouvePartie := result;
    if partieComplete | partieIllegale then derniereLigneLue := '';
  end;



  procedure LitProchainePartieFormatGGF(var chaineJoueurs,partieEnAlpha : String255);
  var theGame:PartieFormatGGFRec;
  begin
    partieEnAlpha := '';
    chaineJoueurs := '';

    erreurES := ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(myZone,kTypeFichierGGF,theGame);

    partieEnAlpha := theGame.coupsEnAlpha;

    if (theGame.joueurNoir = '') | (theGame.joueurBlanc = '')
      then chaineJoueurs := nomsDesJoueursParDefaut
      else
        if EstUnePartieOthelloAvecMiroir(partieEnAlpha) &
           EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs)
          then chaineJoueurs := theGame.joueurNoir + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + theGame.joueurBlanc
          else chaineJoueurs := theGame.joueurNoir + ' 0-0 ' + theGame.joueurBlanc;

    utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue;
  end;

  procedure LitProchaineLigneAvecJoueursEtPartie(var chaineJoueurs,partieEnAlpha : String255; var confianceDansLesJoueurs : double_t);
  var s,moves : String255;
      partieTrouvee : boolean;
      nbPionsNoirs,nbPionsBlancs : SInt32;
  begin
    partieTrouvee := false;
    s := '';
    partieEnAlpha := '';
    chaineJoueurs := '';

    repeat
      erreurES := GetNextLineDansFichierDestructure(s);
      EnleveEspacesDeGaucheSurPlace(s);

      if (s <> '') then
        begin
          partieTrouvee := TrouverPartieEtJoueursDansChaine(s,moves,numeroNoir,numeroBlanc,confianceDansLesJoueurs);
          if partieTrouvee
            then
              begin {on symetrie la partie trouvee, eventuellement}
                partieTrouvee := partieTrouvee & EstUnePartieOthelloAvecMiroir(moves);
              end
            else
              begin {on n'a pas trouvee des joueurs, mais peut-etre y a-t-il au moins une partie ?}
                partieTrouvee := EstUnePartieOthelloAvecMiroir(s);
                if partieTrouvee then
                  begin
                    moves       := s;
                    numeroNoir  := kNroJoueurInconnu;
                    numeroBlanc := kNroJoueurInconnu;
                  end;
              end;

        end;

      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue;

    until partieTrouvee | utilisateurVeutSortir | (erreurES <> NoErr) | EOFFichierAbstrait(myZone,erreurES);

    if partieTrouvee then
      begin
        partieEnAlpha := moves;
        if EstUnePartieOthelloTerminee(moves,false,nbPionsNoirs,nbPionsBlancs)
          then chaineJoueurs := GetNomJoueur(numeroNoir) + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + GetNomJoueur(numeroBlanc)
          else chaineJoueurs := GetNomJoueur(numeroNoir) + ' 0-0 ' + GetNomJoueur(numeroBlanc);
      end;

  end;


  procedure LitProchaineLigneAvecPartie(var chaineJoueurs,partieEnAlpha : String255);
  var s : String255;
      partieTrouvee : boolean;
  begin
    partieTrouvee := false;
    s := '';
    chaineJoueurs := '';
    partieEnAlpha := '';

    repeat
      erreurES := GetNextLineDansFichierDestructure(s);
      EnleveEspacesDeGaucheSurPlace(s);

      if (s <> '') then
        begin
          partieTrouvee := EstUnePartieOthelloAvecMiroir(s);
          if partieTrouvee
            then
              begin
                partieEnAlpha := s;
                chaineJoueurs := nomsDesJoueursParDefaut;
              end;

        end;

      utilisateurVeutSortir := utilisateurVeutSortir | Quitter | EscapeDansQueue;

    until partieTrouvee | utilisateurVeutSortir | (erreurES <> NoErr) | EOFFichierAbstrait(myZone,erreurES);

  end;


begin {AjouterPartiesFichierDestructureDansListe}

  if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true) else
  if not(FenetreRapportEstAuPremierPlan) then SelectWindowSousPalette(GetRapportWindow);

  autoVidage := GetAutoVidageDuRapport;
  ecritLog := GetEcritToutDansRapportLog;
  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(true);


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  tickDepart := TickCount;
  GetTime(myDate);


  nomFic := ExtraitNomDirectoryOuFichier(GetNameOfFSSpec(fichier.theFSSpec));
  erreurES := FSSpecToLongName(fichier.theFSSpec, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFic := DeleteSubstringAfterThisChar('.',nomFic,false);
  nomsDesJoueursParDefaut := nomLongDuFichier;


  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;


  erreurES := OuvreFichierTexte(fichier);
  if (erreurES <> NoErr) then
    begin
      AlerteSimpleFichierTexte(nomLongDuFichier,erreurES);
      AjouterPartiesFichierDestructureDansListe := erreurES;
      exit(AjouterPartiesFichierDestructureDansListe);
    end;
  FermerFichierEtFabriquerFichierAbstrait(fichier,myZone);

  annee := myDate.year;
  if not(TrouverNomDeTournoiDansPath(fichier.nomFichier,numeroTournoi,annee,'name_mapping_VOG_to_WThor.txt'))
    then numeroTournoi := kNroTournoiDiversesParties;


  nombreDeLignesLues := 0;
  nbPartiesDansFic   := 0;
  nbPartiesIllegales := 0;
  erreurES := NoErr;
  utilisateurVeutSortir := false;
  derniereLigneLue := '';

  compteurDoublons := 0;
  tableDoublons := MakeEmptyStringSet;

  (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
     dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(nomsReelsARajouterDansBase);
      DisposeStringSet(pseudosAyantUnNomReel);
      DisposeStringSet(pseudosSansNomReel);
    end;

  while not(EOFFichierAbstrait(myZone,erreurES)) & not(utilisateurVeutSortir) & (erreurES = NoErr) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);


      {lire une partie}

      joueursTrouves := false;
      partieLegale := false;
      nbCoupsRecus := 0;
      numeroNoir := kNroJoueurInconnu;
      numeroBlanc := kNroJoueurInconnu;
      theorique := -1;

      case format of
        kTypeFichierSuiteDePartiePuisJoueurs :
          begin
            partieEnAlpha := TrouvePartie;
            chaineJoueurs := TrouveJoueurs;
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierSuiteDeJoueursPuisPartie :
          begin
            chaineJoueurs := TrouveJoueurs;
            partieEnAlpha := TrouvePartie;
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierGGFMultiple :
          begin
            LitProchainePartieFormatGGF(chaineJoueurs,partieEnAlpha);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        kTypeFichierMultiplesLignesAvecJoueursEtPartie :
          begin
            LitProchaineLigneAvecJoueursEtPartie(chaineJoueurs,partieEnAlpha,confianceDansLesJoueurs);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,bidReal);
          end;
        kTypeFichierSimplementDesCoupsMultiple :
          begin
            LitProchaineLigneAvecPartie(chaineJoueurs,partieEnAlpha);
            joueursTrouves := TrouverNomsDesJoueursDansNomDeFichier(chaineJoueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs);
          end;
        otherwise
          begin
            WritelnDansRapport('ERROR !! format impossible dans AjouterPartiesFichierDestructureDansListe, prévenez Stéphane !');
            partieEnAlpha := '';
            chaineJoueurs := '';
            erreurES := -1;
            utilisateurVeutSortir := true;
          end;

      end; {case}

      {WritelnDansRapport('partie : '+partieEnAlpha);
      WritelnDansRapport('joueurs : '+chaineJoueurs);}

      nbCoupsRecus := LENGTH_OF_STRING(partieEnAlpha) div 2;



	    partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs);

      partieLegale := (nbCoupsRecus > 10) & EstUnePartieOthelloAvecMiroir(partieEnAlpha);

      {on cherche si on a deja mis la partie}
      partieDoublon := false;
      if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) &
         MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
         begin
           partieDoublon := true;
           WritelnDansRapport(ReadStringFromRessource(TextesErreursID,9)+partieEnAlpha);  {'doublon : '}
           compteurDoublons := compteurDoublons + 1;
         end;

      if partieLegale & not(partieDoublon)
        then
          begin
            inc(nbPartiesDansFic);

            partieEstDouteuse := false;

            AddStringToSet(partieEnAlpha,0,tableDoublons);
            AddStringToSet(Concat(partieEnAlpha,' '),0,tableDoublons);

            {WritelnStringAndReelDansRapport('conf = ',confianceDansLesJoueurs,3);}
            if joueursTrouves
              then
                begin
                  if (confianceDansLesJoueurs < 0.80) then
                    begin
                      ChangeFontColorDansRapport(RougeCmd);
                      partieEstDouteuse := true;
                    end;
                  WritelnDansRapport(chaineJoueurs);
                  TextNormalDansRapport;
                end
              else
                begin
                  ChangeFontColorDansRapport(RougeCmd);
                  if not((format = kTypeFichierSimplementDesCoupsMultiple) & (chaineJoueurs = nomLongDuFichier)) then
                    begin
                      WritelnDansRapport(chaineJoueurs);
                      partieEstDouteuse := true;
                    end;
                  TextNormalDansRapport;
                end;

            if partieComplete
              then
                begin
                  {WritelnDansRapport(partieEnAlpha);}
                end
              else
                begin
                  ChangeFontColorDansRapport(VertCmd);
                  WritelnDansRapport({'incomplete : '+}partieEnAlpha);
                  TextNormalDansRapport;
                end;

            WritelnDansRapport('');

            SetAutorisationCalculsLongsSurListe(false);
            if sousSelectionActive then DoChangeSousSelectionActive;

            if AjouterPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieNF,nroReferencePartieAjoutee)
              then SetPartieDansListeEstDouteuse(nroReferencePartieAjoutee,partieEstDouteuse);

            SetAutorisationCalculsLongsSurListe(true);

            if (nbPartiesDansFic mod 50 = 0) then
              begin
                {WritelnNumDansRapport('',nbPartiesDansFic);}
                TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
                CalculsEtAffichagePourBase(false,false);
              end;
          end;

      if not(partieLegale) & (partieEnAlpha <> '') then
        begin
          inc(nbPartiesIllegales);
          TextNormalDansRapport;
          WritelnDansRapport(chaineJoueurs);
          WritelnPartieIllegaleDansRapport(partieEnAlpha);
        end;

      PartagerLeTempsMachineAvecLesAutresProcess(kCassioGetsAll);
      if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

    end;

  DisposeStringSet(tableDoublons);

  DisposeFichierAbstraitEtOuvrirFichier(fichier,myZone);
  erreurES := FermeFichierTexte(fichier);

  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(GetNameOfFSSpec(fichier.theFSSpec))
    then
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,44),NumEnString(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,45),NumEnString(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,42),NumEnString(nbPartiesDansFic),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,43),NumEnString(nbPartiesDansFic),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}

  if (nbPartiesIllegales > 1)
    then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,48),NumEnString(nbPartiesIllegales),'','','')) else  {Il y avait ^0 parties trop courtes ou illégales}
  if (nbPartiesIllegales = 1)
    then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,47),NumEnString(nbPartiesIllegales),'','',''));  {Il y avait ^0 partie trop courte ou illégale}

  if (nbPartiesDansFic < nombreDeLignesLues)
    then WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesRapportID,46),NumEnString(nombreDeLignesLues),'','',''));   {Pour info, ce fichier contenait ^0 lignes}
  {WritelnNumDansRapport('temps de lecture en ticks = ',TickCount - tickDepart);}

  WritelnDansRapport('');
  RemettreLeCurseurNormalDeCassio;


  SetAutorisationCalculsLongsSurListe(true);

  ForceDoubleTriApresUnAjoutDeParties(gGenreDeTriListe);
  TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
  CalculsEtAffichagePourBase(false,false);

  SetAutoVidageDuRapport(autoVidage);
  SetEcritToutDansRapportLog(ecritLog);

  AjouterPartiesFichierDestructureDansListe := erreurES;
end;





procedure BaseLogKittyEnFormatThor(nomBaseLogKitty,NomBaseFormatThor : String255);
{ attention! On doit être dans le bon repertoire, ou nomfichier doit etre un path complet }
var ligne,s,partieEnAlpha,scoreEnChaine,numeroLigneEnChaine,reste : String255;
    partieEnThor : PackedThorGame;
    partie120 : String255;
    autreCoupQuatreDiag : boolean;
    score,nbPartiesDansBaseLogKitty,i : SInt32;
    erreurES : OSErr;
    inputBaseLogKitty,outputBaseThor : FichierTEXT;
    enteteFichierPartie : t_EnTeteNouveauFormat;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
begin

  WritelnDansRapport('entrée dans BaseLogKittyEnFormatThor…');


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);

  if nomBaseLogKitty = '' then
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,0);
      exit(BaseLogKittyEnFormatThor);
    end;
  {SetDebuggageUnitFichiersTexte(false);}


  erreurES := FichierTexteDeCassioExiste(nomBaseLogKitty,inputBaseLogKitty);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;

  erreurES := OuvreFichierTexte(inputBaseLogKitty);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nomBaseLogKitty,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;

  erreurES := FichierTexteDeCassioExiste(NomBaseFormatThor,outputBaseThor);
  if erreurES = fnfErr then erreurES := CreeFichierTexteDeCassio(NomBaseFormatThor,outputBaseThor);
  if erreurES = 0 then
    begin
      erreurES := OuvreFichierTexte(outputBaseThor);
      erreurES := VideFichierTexte(outputBaseThor);
    end;
  if erreurES <> 0 then
    begin
      AlerteSimpleFichierTexte(NomBaseFormatThor,erreurES);
      erreurES := FermeFichierTexte(outputBaseThor);
      exit(BaseLogKittyEnFormatThor);
    end;

  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(NomBaseFormatThor,erreurES);
      exit(BaseLogKittyEnFormatThor);
    end;

  nbPartiesDansBaseLogKitty := 0;
  erreurES := NoErr;
  ligne := '';
  while not(EOFFichierTexte(inputBaseLogKitty,erreurES)) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      erreurES := ReadlnDansFichierTexte(inputBaseLogKitty,s);
      ligne := s;
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne = '') | (ligne[1] = '%')
        then
          begin
            {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
          end
        else
          begin
            Parser3(ligne,PartieEnAlpha,scoreEnChaine,numeroLigneEnChaine,reste);


            if (PartieEnAlpha <> '') & (scoreEnChaine <> '') then
              begin
                inc(nbPartiesDansBaseLogKitty);


                partie120 := partieEnAlpha;
                Normalisation(partie120,autreCoupQuatreDiag,false);
                partieEnAlpha := partie120;

                TraductionAlphanumeriqueEnThor(PartieEnAlpha,partieEnThor);
                if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) | (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60) then
                  begin
                    WritelnDansRapport(ReadStringFromRessource(TextesErreursID,12)+partieEnAlpha);   {'problème sur la longueur de la partie : '}
                    SysBeep(0);
                  end;

                ChaineToLongint(scoreEnChaine,score);
                if odd(score) then
                  if score > 0 then inc(score) else dec(score);
                score := (score+64) div 2;
                if score < 0 then SysBeep(0);
                if score > 64 then SysBeep(0);

                {
                WritelnNumDansRapport(PartieEnAlpha+'  => ',score);
                }
                if (nbPartiesDansBaseLogKitty mod 1000) = 0 then
                  WritelnNumDansRapport('…',nbPartiesDansBaseLogKitty);


                partieNF.scoreTheorique := score;
                partieNF.scoreReel := score;
                partieNF.nroTournoi := kNroTournoiDiversesParties;
                partieNF.nroJoueurNoir := kNroJoueurLogistello;
                partieNF.nroJoueurBlanc := kNroJoueurLogistello;
                for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
                  partieNF.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor,i,'BaseLogKittyEnFormatThor');
                for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
                  partieNF.listeCoups[i] := 0;



                erreurES := EcritPartieNouveauFormat(outputBaseThor.refNum,nbPartiesDansBaseLogKitty,partieNF);


              end;

          end;
    end;

  GetTime(myDate);
  with enteteFichierPartie do
    begin
      SiecleCreation                         := myDate.year div 100;
			AnneeCreation                          := myDate.year mod 100;
			MoisCreation                           := myDate.month;
			JourCreation                           := myDate.day;
      NombreEnregistrementsParties           := nbPartiesDansBaseLogKitty;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties                           := 1999;
      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
      reservedByte                           := 0;
    end;
  erreurES := EcritEnteteNouveauFormat(outputBaseThor.refNum,enteteFichierPartie);

  erreurES := FermeFichierTexte(inputBaseLogKitty);
  erreurES := FermeFichierTexte(outputBaseThor);
  SetFileCreatorFichierTexte(outputBaseThor,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(outputBaseThor,MY_FOUR_CHAR_CODE('QWTB'));


  RemettreLeCurseurNormalDeCassio;
end;




procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    partieEnAlpha : String255;
    ligne : String255;
    partieEnSuedois : String255;
    partie60 : String255;
begin
  with gOptionsExportBase do
    begin

      ligne := patternLigne;

      (* echappement *)
      while (Pos('\\',ligne) > 0) do
        ligne := ReplaceStringByStringInString('\\','‰Ω',ligne);
      while (Pos('\$',ligne) > 0) do
        ligne := ReplaceStringByStringInString('\$','◊√',ligne);

      TraductionThorEnAlphanumerique(theGame,partieEnAlpha);
      TraductionThorEnSuedois(theGame,partieEnSuedois);
      COPY_PACKED_GAME_TO_STR60(theGame,partie60);

      (* un numero (non fixe entre les sessions de Cassio) pour la partie *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_GAME_ID'        ,NumEnString(numeroReference)                                                   ,ligne);

      (* les coups de la partie *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THOR_MOVES'     ,partie60                                                                       ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SWEDISH_MOVES'  ,partieEnSuedois                                                                ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_GAME'           ,partieEnAlpha                                                                  ,ligne);

      (* Les tournois *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN_SHORT'    ,MyStripDiacritics(GetNomCourtTournoiParNroRefPartie(numeroReference))          ,ligne);
      if EstUnePartieAvecTournoiJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_TOURN_JAPANESE' ,GetNomJaponaisDuTournoiParNroRefPartie(numeroReference)                        ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_TOURN_JAPANESE' ,MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))               ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN_NUMBER'   ,NumEnString(GetNroTournoiParNroRefPartie(numeroReference))                     ,ligne);

      { bien penser a mettre toutes les variables qui commencent par $CASSIO_TOURN avant la ligne suivante }
      ligne := ReplaceVariableByStringInString(       '$CASSIO_TOURN'          ,MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))               ,ligne);

      (* les joueurs *)
      
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK_SHORT'    ,MyStripDiacritics(GetNomJoueurNoirSansPrenomParNroRefPartie(numeroReference))  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE_SHORT'    ,MyStripDiacritics(GetNomJoueurBlancSansPrenomParNroRefPartie(numeroReference)) ,ligne);
      if EstUnePartieAvecJoueurNoirJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_BLACK_JAPANESE' ,GetNomJaponaisDuJoueurNoirParNroRefPartie(numeroReference)                     ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_BLACK_JAPANESE' ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference)                  ,ligne);
      if EstUnePartieAvecJoueurBlancJaponais(numeroReference)
        then ligne := ReplaceVariableByStringInString('$CASSIO_WHITE_JAPANESE' ,GetNomJaponaisDuJoueurBlancParNroRefPartie(numeroReference)                    ,ligne)
        else ligne := ReplaceVariableByStringInString('$CASSIO_WHITE_JAPANESE' ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference)                 ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK_NUMBER'   ,NumEnString(GetNroJoueurNoirParNroRefPartie(numeroReference))                  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE_NUMBER'   ,NumEnString(GetNroJoueurBlancParNroRefPartie(numeroReference))                 ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK_FFO'      ,NumEnString(GetNroFFOJoueurNoirParNroRefPartie(numeroReference))               ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE_FFO'      ,NumEnString(GetNroFFOJoueurNoirParNroRefPartie(numeroReference))               ,ligne);

      { bien pensser a mettre toutes les variables qui commencent par $CASSIO_BLACK et $CASSIO_WHITE avant les deux lignes suivantes }
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BLACK'          ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference)                  ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_WHITE'          ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference)                 ,ligne);

      (* les scores reels et theoriques *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SCORE_BLACK'    ,NumEnString(GetScoreReelParNroRefPartie(numeroReference))                      ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_SCORE_WHITE'    ,NumEnString(64-GetScoreReelParNroRefPartie(numeroReference))                   ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_BLACK'    ,NumEnString(GetScoreTheoriqueParNroRefPartie(numeroReference))                 ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_WHITE'    ,NumEnString(64-GetScoreTheoriqueParNroRefPartie(numeroReference))              ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_THEOR_WINNER'   ,GetGainTheoriqueParNroRefPartie(numeroReference)                               ,ligne);

      (* le nom de la base et l'annee *)
      ligne := ReplaceVariableByStringInString(       '$CASSIO_BASE'           ,GetNomDistributionParNroRefPartie(numeroReference)                             ,ligne);
      ligne := ReplaceVariableByStringInString(       '$CASSIO_YEAR'           ,NumEnString(GetAnneePartieParNroRefPartie(numeroReference))                    ,ligne);


      (* echappement *)
      while (Pos('◊√',ligne) > 0) do
        ligne := ReplaceStringByStringInString('◊√','$',ligne);
      while (Pos('‰Ω',ligne) > 0) do
        ligne := ReplaceStringByStringInString('‰Ω','\',ligne);

      erreurES := WritelnDansFichierTexte(fic,ligne);
      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));     {'Export : ^0 parties…'}

    end;
end;


procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    s,s1,s2,ligne : String255;
    k : SInt32;
begin
  with gOptionsExportBase do
    begin

      ligne := '[Event "'+MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[Date "'+NumEnString(GetAnneePartieParNroRefPartie(numeroReference))+'.01.01"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[Round "-"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[Database "'+MyStripDiacritics(GetNomDistributionParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[Black "'+MyStripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[White "'+MyStripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[Result "'+NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                           NumEnString(64-GetScoreReelParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne := '[TheoreticalScore "'+NumEnString(GetScoreTheoriqueParNroRefPartie(numeroReference)) + '-' +
                                     NumEnString(64-GetScoreTheoriqueParNroRefPartie(numeroReference))+'"]';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      erreurES := WritelnDansFichierTexte(fic,'');

      TraductionThorEnAlphanumerique(theGame,s);
      for k := 1 to 59 do
        begin
          s1 := TPCopy(s,k*2 - 1,2);
          if s1 = '' then s1 := '--';
          s2 := TPCopy(s,k*2 + 1,2);
          if s2 = '' then s2 := '--';
          if odd(k) then
            begin
              ligne := NumEnString(1 + (k div 2)) + '. '+s1+' '+s2+' ';
              erreurES := WritelnDansFichierTexte(fic,ligne);
            end;
        end;

      ligne := NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' + NumEnString(64-GetScoreReelParNroRefPartie(numeroReference));
      erreurES := WritelnDansFichierTexte(fic,ligne);

      erreurES := WritelnDansFichierTexte(fic,'');
      erreurES := WritelnDansFichierTexte(fic,'');

      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));    {'Export : ^0 parties…'}

    end;
end;


procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    moves,ligne : String255;
begin
  with gOptionsExportBase do
    begin


      ligne :=  '  <game>';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne :=  '   <event'+
                ' date="'+NumEnString(GetAnneePartieParNroRefPartie(numeroReference))+'"' +
                ' name="'+MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      if GetScoreReelParNroRefPartie(numeroReference) > 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="black"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;

      if GetScoreReelParNroRefPartie(numeroReference) = 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="draw"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;

      if GetScoreReelParNroRefPartie(numeroReference) < 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="white"' +
                    ' type="normal">' +
                     NumEnString(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     NumEnString(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := WritelnDansFichierTexte(fic,ligne);
        end;

      ligne :=  '   <player'+
                ' color="black"' +
                ' name="'+MyStripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne :=  '   <player'+
                ' color="white"' +
                ' name="'+MyStripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      TraductionThorEnAlphanumerique(theGame,moves);
      ligne :=  '   <moves game="othello-8x8" type="flat">' +
                moves +
                '</moves>';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      ligne :=  '   </game>';
      erreurES := WritelnDansFichierTexte(fic,ligne);

      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));     {'Export : ^0 parties…'}

    end;
end;



procedure ExportListeAuFormatTexte(descriptionLigne : String255; var nbPartiesExportees : SInt32);
var reply : SFReply;
    prompt : String255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportTexte : FichierTEXT;
    compteur : SInt32;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d'export ? '}
  SetNameOfSFReply(reply, 'Export.txt');
  if MakeFileName(reply,prompt,whichSpec) then
    begin

      erreurES := FichierTexteExisteFSp(whichSpec,exportTexte);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportTexte);
      if erreurES = NoErr then
        begin
          erreurES := OuvreFichierTexte(exportTexte);
          erreurES := VideFichierTexte(exportTexte);
        end;
      if erreurES <> NoErr then
        begin
          AlerteSimpleFichierTexte(GetNameOfSFReply(reply),erreurES);
          erreurES := FermeFichierTexte(exportTexte);
          exit(ExportListeAuFormatTexte);
        end;

      gOptionsExportBase.patternLigne    := descriptionLigne;
      gOptionsExportBase.fic             := exportTexte;

      (* WritelnDansRapport('descriptionLigne = '+ descriptionLigne); *)

      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierTexte,compteur);

      erreurES := FermeFichierTexte(exportTexte);

      WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));   {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;


procedure ExportListeAuFormatPGN;
var reply : SFReply;
    prompt : String255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportFichier : FichierTEXT;
    compteur,nbPartiesExportees : SInt32;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d''export ? ';}
  SetNameOfSFReply(reply, 'Export.pgn');
  if MakeFileName(reply,prompt,whichSpec) then
    begin

      erreurES := FichierTexteExisteFSp(whichSpec,exportFichier);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportFichier);
      if erreurES = NoErr then
        begin
          erreurES := OuvreFichierTexte(exportFichier);
          erreurES := VideFichierTexte(exportFichier);
        end;
      if erreurES <> NoErr then
        begin
          AlerteSimpleFichierTexte(GetNameOfSFReply(reply),erreurES);
          erreurES := FermeFichierTexte(exportFichier);
          exit(ExportListeAuFormatPGN);
        end;

      gOptionsExportBase.fic             := exportFichier;

      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierPGN,compteur);

      erreurES := FermeFichierTexte(exportFichier);

      WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));    {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;





procedure ExportListeAuFormatXOF;
var reply : SFReply;
    prompt,ligne : String255;
    whichSpec : FSSpec;
    erreurES : OSErr;
    exportFichier : FichierTEXT;
    compteur,nbPartiesExportees : SInt32;
    myDate : DateTimeRec;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d''export ? '}
  SetNameOfSFReply(reply, 'Export.xml');
  if MakeFileName(reply,prompt,whichSpec) then
    begin
      GetTime(myDate);

      erreurES := FichierTexteExisteFSp(whichSpec,exportFichier);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreeFichierTexteFSp(whichSpec,exportFichier);
      if erreurES = NoErr then
        begin
          erreurES := OuvreFichierTexte(exportFichier);
          erreurES := VideFichierTexte(exportFichier);
        end;
      if erreurES <> NoErr then
        begin
          AlerteSimpleFichierTexte(GetNameOfSFReply(reply),erreurES);
          erreurES := FermeFichierTexte(exportFichier);
          exit(ExportListeAuFormatXOF);
        end;

      gOptionsExportBase.fic             := exportFichier;


      ligne :=  '<?xml version="1.0" encoding="UTF-8"?>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);

      ligne :=  '<!DOCTYPE database SYSTEM "xof.dtd">';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);

      WritelnDansRapport('');

      ligne :=  '<database xmlns="http://www.othbase.net/xof">';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);

      ligne :=  ' <info version="1.1"'+
                   ' date="'+NumEnStringAvecFormat(myDate.year,4,'0')+'-'+
                             NumEnStringAvecFormat(myDate.month,2,'0')+'-'+
                             NumEnStringAvecFormat(myDate.day,2,'0')+'"'+
                   ' author="'+'Cassio '+VersionDeCassioEnString+'" />';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);

      ligne :=  ' <game-collection>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);






      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierXOF,compteur);



      ligne :=  '  </game-collection>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);

      ligne :=  '</database>';
      erreurES := WritelnDansFichierTexte(exportFichier,ligne);





      erreurES := FermeFichierTexte(exportFichier);

      WritelnDansRapport(ParamStr(ReadStringFromRessource(TextesErreursID,13),NumEnString(compteur),'','',''));    {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;


procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    s,ligne,ligneSansEspace : String255;
    nom1,nom2 : String255;
    nomFichierOutput : String255;
    fichierHTMLOutput : FichierTEXT;
    fichierModeleHTML : FichierTEXT;
    compteurLignes,data : SInt32;
    numero: SInt32;
begin

  if PartieEstActiveEtSelectionnee(numeroReference) then
    begin
      ShareTimeWithOtherProcesses(0);

      fichierModeleHTML := gOptionsExportBase.fic;
      erreurES := SetPositionTeteLectureFichierTexte(fichierModeleHTML,0);

      if (erreurES = NoErr) then
        begin


          gOptionsExportBase.fic := fichierHTMLOutput;
          compteurLignes := 0;


          nom1 := GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference);
          nom2 := GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference);
          
          numero := 0;
          repeat
             numero := numero + 1;
             
             if (numero = 1)
               then
                 begin
                   nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) +
                                       gOptionsExportBase.subDirectoryName +
                                       LeftOfString(nom1,kLongueurNomsDansURL) + '-' +
                                       LeftOfString(nom2,kLongueurNomsDansURL) +
                                       '.htm';
                                       
                 end
               else
                 begin
                   nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) +
                                       gOptionsExportBase.subDirectoryName +
                                       LeftOfString(nom1,kLongueurNomsDansURL) + '-' +
                                       LeftOfString(nom2,kLongueurNomsDansURL - LENGTH_OF_STRING(NumEnString(numero))) +
                                       NumEnString(numero) +
                                       '.htm';
                 end;
          until not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises));
          
          WritelnDansRapport(nomFichierOutput+'...');

          erreurES := FichierTexteExiste(nomFichierOutput,0,fichierHTMLOutput);
          if erreurES = fnfErr
            then
              begin
                {-43 => fichier non trouvé, on le crée}
                erreurES := CreeFichierTexte(nomFichierOutput,0,fichierHTMLOutput);
                {WritelnDansRapport('Le fichier '+nomFichierOutput+' n''existe pas, on le crée');}
              end
            else
              begin
                if not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises)) then
                  begin
                    //WritelnDansRapport('Le fichier '+nomFichierOutput+' existe deja, on l''efface');
                    erreurES := OuvreFichierTexte(fichierHTMLOutput);
                    erreurES := VideFichierTexte(fichierHTMLOutput);
                    erreurES := FermeFichierTexte(fichierHTMLOutput);
                  end;
              end;
          AddStringToSet(nomFichierOutput,0,gOptionsExportBase.nomsFichiersUtilises);

          erreurES := OuvreFichierTexte(fichierHTMLOutput);
          erreurES := SetPositionTeteLectureFinFichierTexte(fichierHTMLOutput);
          gOptionsExportBase.fic := fichierHTMLOutput;

          if (erreurES = NoErr) then inc(compteur);

          while (erreurES = NoErr) & not(EOFFichierTexte(fichierModeleHTML,erreurES)) do
            begin
              erreurES := ReadlnDansFichierTexte(fichierModeleHTML,s);
              ligne := s;
              ligneSansEspace := EnleveEspacesDeGauche(ligne);
              if (ligneSansEspace[1] = '%')
                then
                  begin
                    {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
                  end
                else
                  begin
                    {WritelnDansRapport(ligne);}
                    gOptionsExportBase.patternLigne   := ligne;
                    ExporterPartieDansFichierTexte(theGame,numeroReference,compteurLignes);
                  end;
            end;

          erreurES := FermeFichierTexte(fichierHTMLOutput);
        end;

      gOptionsExportBase.fic := fichierModeleHTML;

  end;
end;

procedure ExporterPartieDansFichierSOF(var theGame : PackedThorGame; numeroReference : SInt32; var compteur : SInt32);
var erreurES : OSErr;
    s : String255;
    nom1,nom2,nomPourURL : String255;
    nomFichierOutput : String255;
    fichierSOFOutput : FichierTEXT;
    fichierModeleHTML : FichierTEXT;
    nbPionsFinalNoirs,nbPionsFinalBlancs : SInt32;
    data, t, trait, coup : SInt32;
    myDate : DateTimeRec;
    partieTerminee, ok : boolean;
    positionEtTrait : PositionEtTraitRec;
begin

  if PartieEstActiveEtSelectionnee(numeroReference) then
    begin
      ShareTimeWithOtherProcesses(0);

      fichierModeleHTML := gOptionsExportBase.fic;

      erreurES := NoErr;

      if (erreurES = NoErr) then
        begin

          gOptionsExportBase.fic := fichierSOFOutput;


          nom1 := GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference);
          nom2 := GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference);
          (*if nom1 > nom2 then
            begin
              s := nom1;
              nom1 := nom2;
              nom2 := s;
            end;
            *)
          {nom1 := ReplaceStringByStringInString(' ','_',nom1);
          nom2 := ReplaceStringByStringInString(' ','_',nom2);}
          (*
          for i := 1 to kLongueurNomsDansURL do
            begin
              nom1 := nom1 + ' ';
              nom2 := nom2 + ' ';
            end;*)

          nomPourURL := LeftOfString(nom1,kLongueurNomsDansURL)+'-'+
                        LeftOfString(nom2,kLongueurNomsDansURL)+'.sof';

          nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) +
                              gOptionsExportBase.subDirectoryName +
                              nomPourURL;

          WritelnDansRapport(nomFichierOutput+'...');

          erreurES := FichierTexteExiste(nomFichierOutput,0,fichierSOFOutput);
          if erreurES = fnfErr
            then
              begin
                {-43 => fichier non trouvé, on le crée}
                erreurES := CreeFichierTexte(nomFichierOutput,0,fichierSOFOutput);
                {WritelnDansRapport('Le fichier '+nomFichierOutput+' n''existe pas, on le crée');}
              end
            else
              begin
                if not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises)) then
                  begin
                    {WritelnDansRapport('Le fichier '+nomFichierOutput+' existe deja, on l''efface');}
                    erreurES := OuvreFichierTexte(fichierSOFOutput);
                    erreurES := VideFichierTexte(fichierSOFOutput);
                    erreurES := FermeFichierTexte(fichierSOFOutput);
                  end;
              end;
          AddStringToSet(nomFichierOutput,0,gOptionsExportBase.nomsFichiersUtilises);

          erreurES := OuvreFichierTexte(fichierSOFOutput);
          erreurES := SetPositionTeteLectureFinFichierTexte(fichierSOFOutput);

          if (erreurES = NoErr) then inc(compteur);


          (* Writing the SGF compulsary informations *)
          s := '(;GM[2]FF[4]SZ[8]TM[1500]BL[1500]WL[1500]';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Cassio version *)
          s := 'AP['+'Cassio:'+VersionDeCassioEnString+']';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* User *)
          s := 'US[Stephane Nicolet]';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Copyright *)
          GetTime(myDate);
          s := 'CP[Copyleft '+NumEnString(myDate.year)+', French Federation of Othello]';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Black player *)
          s := 'PB['+MyStripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+']';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* White player *)
          s := 'PW['+MyStripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+']';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Event *)
          s := 'EV['+MyStripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+']';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Year *)
          s := 'DT['+NumEnString(GetAnneePartieParNroRefPartie(numeroReference))+']';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);

          (* Score *)
          if PeutCalculerScoreFinalDeCettePartie(theGame,nbPionsFinalNoirs,nbPionsFinalBlancs,partieTerminee) & partieTerminee then
            begin
              if nbPionsFinalNoirs > nbPionsFinalBlancs then s := 'RE[B+'+NumEnString(nbPionsFinalNoirs - nbPionsFinalBlancs)+']' else
              if nbPionsFinalNoirs < nbPionsFinalBlancs then s := 'RE[B+'+NumEnString(nbPionsFinalBlancs - nbPionsFinalNoirs)+']' else
              if nbPionsFinalNoirs = nbPionsFinalBlancs then s := 'RE[0]';
              erreurES := WriteDansFichierTexte(fichierSOFOutput,s);
            end;

          (* Initial position *)
          s := 'AB[e4][d5]AW[d4][e5]PL[B]';
          erreurES := WriteDansFichierTexte(fichierSOFOutput,s);


          if GET_LENGTH_OF_PACKED_GAME(theGame) > 0 then
            begin
               positionEtTrait := PositionEtTraitInitiauxStandard;
               ok := true;
               for t := 1 to Min(60, GET_LENGTH_OF_PACKED_GAME(theGame)) do
        			   begin
        			     coup := GET_NTH_MOVE_OF_PACKED_GAME(theGame,t,'PeutCalculerScoreFinalDeCettePartie');
        			     trait := GetTraitOfPosition(positionEtTrait);
        			     if ok & (coup <> 0) then
          			     begin
          			       ok := (UpdatePositionEtTrait(positionEtTrait, coup));
          			       if ok then
          			         begin
          			           s := '';
          			           case trait of
            			           pionNoir  : s := ';B['+CoupEnString(coup, false)+']';
            			           pionBlanc : s := ';W['+CoupEnString(coup, false)+']';
          			           end;  {case}
          			           if (s <> '') then erreurES := WriteDansFichierTexte(fichierSOFOutput,s);
          			         end;
        			       end;
        			   end;
        		 end;


          (* Terminal parenthese *)
          s := ')';
          erreurES := WritelnDansFichierTexte(fichierSOFOutput,s);

          erreurES := FermeFichierTexte(fichierSOFOutput);
        end;

      gOptionsExportBase.fic := fichierModeleHTML;

  end;
end;





procedure ExportListeAuFormatHTML;
var erreurES : OSErr;
    modeleHTML : FichierTEXT;
    compteur : SInt32;
    prompt : String255;
begin

  BeginDialog;
  prompt := ReadStringFromRessource(TextesDiversID,13);  {Trouvez le fichier modèle HTML :}
  erreurES := GetFichierTexte(prompt,MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),modeleHTML);
  EndDialog;

  if (erreurES = NoErr) then
    with gOptionsExportBase do
      begin

        if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true);

        erreurES := OuvreFichierTexte(modeleHTML);

        patternLigne            := '';
        fic                     := modeleHTML;
        nomsFichiersUtilises    := MakeEmptyStringSet;


        (* Create all the HTML files *)

        subDirectoryName := 'html';
        if subDirectoryName <> '' then
          begin
            erreurES := CreateSubDirectoryNearThisFile(modeleHTML.theFSSpec,subDirectoryName);
            if erreurES <> NoErr then subDirectoryName := '';
          end;

        compteur := 0;
        ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierHTML,compteur);
        WritelnDansRapport('');
        WriteDansRapport(NumEnString(compteur) + ' HTML files created');
        if compteur > 0
          then WritelnDansRapport(' : OK')
          else WritelnDansRapport(' : this could be an ERROR ?! ');
        WritelnDansRapport('');



        (* Create all the SOF files *)

        subDirectoryName := 'sof';
        if subDirectoryName <> '' then
          begin
            erreurES := CreateSubDirectoryNearThisFile(modeleHTML.theFSSpec,subDirectoryName);
            if erreurES <> NoErr then subDirectoryName := '';
          end;

        compteur := 0;
        ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierSOF,compteur);
        WritelnDansRapport('');
        WriteDansRapport(NumEnString(compteur) + ' Smart Othello Files created');
        if compteur > 0
          then WritelnDansRapport(' : OK')
          else WritelnDansRapport(' : this could be an ERROR ?! ');
        WritelnDansRapport('');

        DisposeStringSet(nomsFichiersUtilises);

        erreurES := FermeFichierTexte(modeleHTML);

      end;
end;





procedure ImporterLigneNulleBougeard(var myLongString : LongString; var theFic : FichierTEXT; var compteur : SInt32);
var gameNodeLePlusProfond : GameTree;
    partieRec : t_PartieRecNouveauFormat;
    partieEnThor : PackedThorGame;
    nroReferencePartieAjoutee : SInt32;
    i : SInt32;
    ligne : String255;
    oldCheckDangerousEvents : boolean;
begin {$unused theFic}

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  ligne := myLongString.debutLigne;

  if (ligne <> '') & (ligne[1] <> '%') then
    begin
     if EstUnePartieOthello(ligne,true)
       then
         begin


           TraductionAlphanumeriqueEnThor(ligne,partieEnThor);
           if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) | (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60)
             then
               begin
                WritelnDansRapport(ReadStringFromRessource(TextesErreursID,12)+ligne);  {'problème sur la longueur de la partie : '}
                SysBeep(0);
              end
            else
              begin

                 inc(compteur);
                 if (compteur mod 100) = 0 then WritelnNumDansRapport('…',compteur);

                 {on rejoue la partie dans l'arbre, et on indique que le score est nul}
                 RejouePartieOthello(ligne,LENGTH_OF_STRING(ligne) div 2,true,bidplat,pionNoir,gameNodeLePlusProfond,false,false);
                 AjoutePropertyValeurDeCoupDansCurrentNode(ReflParfait,0);


                 {maintenant on ajoute la partie dans la liste}
                 partieRec.scoreTheorique := 32;  {ce sont des nulles…}
                 partieRec.scoreReel := 32;       {ce sont des nulles…}
                 partieRec.nroTournoi := kNroTournoiDiversesParties;
                 partieRec.nroJoueurNoir := 1948;  {c'est le numéro d'Emmanuel Bougeard}
                 partieRec.nroJoueurBlanc := 1948;
                 for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
                   partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor,i,'ImporterLigneNulleBougeard');
                 for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
                   partieRec.listeCoups[i] := 0;

                 if sousSelectionActive then DoChangeSousSelectionActive;

                 if (nbPartiesChargees < nbrePartiesEnMemoire) then
      	           if AjouterPartieRecDansListe(partieRec,2004,nroReferencePartieAjoutee) then DoNothing;

           end;

         end
       else
         begin
           WritelnDansRapport(ReadStringFromRessource(TextesErreursID,14)+ligne);  {'## ligne impossible : '}
         end;
    end;

  SetCassioMustCheckDangerousEvents(oldCheckDangerousEvents,NIL);
end;


procedure ImportBaseAllDrawLinesDeBougeard;
var compteurParties : SInt32;
    erreurES : OSErr;
    fichierBougeard : FichierTEXT;
begin
  BeginDialog;
  erreurES := GetFichierTexte('',MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),fichierBougeard);
  EndDialog;

  compteurParties := 0;
  ForEachLineInFileDo(fichierBougeard.theFSSpec,ImporterLigneNulleBougeard,compteurParties);
end;


procedure EcritNomFichierNonReconnuDansRapport(var fic : FichierTEXT);
var err : OSErr;
    nomLongDuFichier : String255;
begin
  err := FSSpecToLongName(fic.theFSSpec, nomLongDuFichier);
  if err = NoErr then
    begin
      WritelnDansRapport('');
      ChangeFontFaceDansRapport(bold);
      WriteDansRapport(ReadStringFromRessource(TextesErreursID,15));  {'Format non reconnu : '}
      TextNormalDansRapport;
      WritelnDansRapport(nomLongDuFichier);
      TextNormalDansRapport;
    end;
end;


function ImporterFichierPartieDansListe(var fs : FSSpec; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var err : OSErr;
    fic : FichierTEXT;
    nomComplet : String255;
    numeroNoir,numeroBlanc : SInt32;
    numeroTournoi,anneeTournoi : SInt32;
    infos : FormatFichierRec;
    partieEnAlpha : String255;
    nomLongDuFichier : String255;
    partieRec : t_PartieRecNouveauFormat;
    nroReferencePartieAjoutee : SInt32;
    myDate : DateTimeRec;
    partieLegale,partieComplete : boolean;
    nbNoirs,nbBlancs : SInt32;
    confianceDansLesJoueurs : double_t;
    nomLongDuFichierDejaEcrit : boolean;
    recognized : boolean;
    temp : boolean;
    partieEstDouteuse : boolean;
begin
  {$UNUSED pb}

  temp := DoitExpliquerTrierListeSuivantUnClassement;
  SetDoitExpliquerTrierListeSuivantUnClassement(false);

  if not(isFolder) then
    begin
      err := FSSpecToFullPath(fs,nomComplet);

      err := FichierTexteExiste(nomComplet,0,fic);

      recognized := false;

      if (err = NoErr) & TypeDeFichierEstConnu(fic,infos,err)
        then
  				begin
  				  recognized := true;

  				  WritelnDansRapport('');

  				  {
  				  WritelnNumDansRapport('infos.format = ',SInt32(infos.format));
  				  WritelnNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);
  				  WritelnStringDansRapport('infos.positionEtPartie = '+infos.positionEtPartie);
  				  }

  					if (infos.format = kTypeFichierPGN)
  					  then err := AjouterPartiesFichierPGNDansListe('name_mapping_VOG_to_WThor.txt',fic)

  					else
  					  if (infos.format = kTypeFichierSuiteDePartiePuisJoueurs) |
  					     (infos.format = kTypeFichierSuiteDeJoueursPuisPartie) |
  					     (infos.format = kTypeFichierGGFMultiple)
  					    then err := AjouterPartiesFichierDestructureDansListe(infos.format,fic)

  					else
  					  if (infos.format = kTypeFichierTHOR_PAR) & (infos.tailleOthellier = 8)
					      then err := AjouterPartiesFichierTHOR_PARDansListe(fic)

  					else
  					  if ((infos.format = kTypeFichierCassio)                |
  					      (infos.format = kTypeFichierSGF)                   |
  					      (infos.format = kTypeFichierGGF)                   |
                  (infos.format = kTypeFichierHTMLOthelloBrowser)    |
                  (infos.format = kTypeFichierTranscript)            |
                  (infos.format = kTypeFichierZebra)                 |
                  (infos.format = kTypeFichierEPS)                   |
                  (infos.format = kTypeFichierExportTexteDeZebra)    |
                  (infos.format = kTypeFichierSimplementDesCoups)    |
                  (infos.format = kTypeFichierLigneAvecJoueurEtPartie))
                  & (infos.tailleOthellier = 8)
                  then
                    begin
                      partieEstDouteuse := false;

                      partieEnAlpha := infos.positionEtPartie;
                      err := FSSpecToLongName(fic.theFSSpec, nomLongDuFichier);

                      partieLegale := EstUnePartieOthelloAvecMiroir(partieEnAlpha); {on sait qu'elle est legale, c'est juste pour compacter et reorienter la partie}
                      
                      if not(partieLegale) then WritelnDansRapport('warning : this game is illegal, or not starting from the official position...');
                      
                      partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,false,nbNoirs,nbBlancs);

                      GetTime(myDate);
                      anneeTournoi := myDate.year;

                      if not(TrouverNomDeTournoiDansPath(GetPathOfScannedDirectory+path,numeroTournoi,anneeTournoi,'name_mapping_VOG_to_WThor.txt'))
                        then numeroTournoi := kNroTournoiDiversesParties;

                      nomLongDuFichierDejaEcrit := false;
                      if TrouverNomsDesJoueursDansNomDeFichier(infos.joueurs,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs)
                        then
                          begin
                            if (confianceDansLesJoueurs < 0.80) then
                              begin
                                ChangeFontColorDansRapport(RougeCmd);
                                partieEstDouteuse := true;
                              end;
                            WriteDansRapport(nomLongDuFichier + '  : ');
                            if (confianceDansLesJoueurs < 0.80) then WriteDansRapport(ReadStringFromRessource(TextesErreursID,16));  {'joueurs dans le fichier =  '}
                            WritelnDansRapport(infos.joueurs);
                            TextNormalDansRapport;
                            nomLongDuFichierDejaEcrit := true;
                          end;

                       if confianceDansLesJoueurs < 0.80 then
                         begin
                          if TrouverNomsDesJoueursDansNomDeFichier(nomLongDuFichier,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs)
                            then
                              begin
                                if (confianceDansLesJoueurs < 0.80) then
                                  begin
                                    ChangeFontColorDansRapport(RougeCmd);
                                    partieEstDouteuse := true;
                                  end;
                                if not(nomLongDuFichierDejaEcrit) then WritelnDansRapport(nomLongDuFichier);
                                TextNormalDansRapport;
                              end
                            else
                              begin
                                numeroNoir  := kNroJoueurInconnu;
                                numeroBlanc := kNroJoueurInconnu;
                                ChangeFontColorDansRapport(RougeCmd);
                                partieEstDouteuse := true;
                                if not(nomLongDuFichierDejaEcrit) then WritelnDansRapport(nomLongDuFichier);
                                TextNormalDansRapport;
                              end;
                         end;

                      if partieComplete
                        then
                          WritelnDansRapport(partieEnAlpha)
                        else
                          begin
                            ChangeFontColorDansRapport(VertCmd);
                            WritelnDansRapport(partieEnAlpha);
                            TextNormalDansRapport;
                          end;

                      if sousSelectionActive then DoChangeSousSelectionActive;

                      (* maintenant, ajouter la partie dans la liste *)
                      if AjouterPartieAlphaDansLaListe(partieEnAlpha,-1,numeroNoir,numeroBlanc,numeroTournoi,anneeTournoi,partieRec,nroReferencePartieAjoutee)
                        then SetPartieDansListeEstDouteuse(nroReferencePartieAjoutee,partieEstDouteuse)
                        else recognized := false;

                    end
                 else
                   recognized := false;

            if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
  			  end;


  		if not(recognized) & (GetNameOfFSSpec(fic.theFSSpec)[1] <> '.') then {on ne veut pas les fichiers dont le nom commence par un point}
  		  EcritNomFichierNonReconnuDansRapport(fic);

   end;

  SetDoitExpliquerTrierListeSuivantUnClassement(temp);

  ImporterFichierPartieDansListe := isFolder; {on cherche recursivement}
end;


procedure ImporterToutesPartiesRepertoire;
var prompt : String255;
    whichDirectory : FSSpec;
    erreurES : OSErr;
    tick : SInt32;
begin
  prompt := ReadStringFromRessource(TextesDiversID,10); {'Choisissez un répertoire avec des parties'}
  if ChooseFolder(prompt,whichDirectory) then
    begin
      {WritelnDansRapport('*************  Entrée dans ImporterToutesPartiesRepertoire…  ******************');}
      tick := Tickcount;

      if not(problemeMemoireBase) & not(JoueursEtTournoisEnMemoire) then
        erreurES := MetJoueursEtTournoisEnMemoire(false);

      (* on efface les caches des pseudos car l'utilisateur peut avoir changé le
         dictionnaire "name_mapping_VOG_to_WThor.txt" depuis la derniere fois   *)
      with gImportDesNoms do
        begin
          DisposeStringSet(pseudosInconnus);
          DisposeStringSet(pseudosNomsDejaVus);
          DisposeStringSet(pseudosTournoisDejaVus);
          DisposeStringSet(nomsReelsARajouterDansBase);
          DisposeStringSet(pseudosAyantUnNomReel);
          DisposeStringSet(pseudosSansNomReel);
        end;

      erreurES := SetPathOfScannedDirectory(whichDirectory);
      erreurES := ScanDirectory(whichDirectory,ImporterFichierPartieDansListe);

      SetAutorisationCalculsLongsSurListe(true);
      ForceDoubleTriApresUnAjoutDeParties(gGenreDeTriListe);

      {WritelnDansRapport('');
      WritelnDansRapport('*************  Sortie de ImporterToutesPartiesRepertoire  ******************');}
      {WritelnNumDansRapport('temps en ticks = ',TickCount-tick);}
      WritelnDansRapport('');
    end;
end;

(*


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<title>WOC 2008, Transcripts</title>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="./style_woc2008.css">
<script type="text/javascript" src="./script_woc2008.js"></script>
</head>

<body bgcolor="#FFFFFF">

<div id="banner"> <!-- La banniere Othello -->
	<div id="banner_left">
		<img src="images/2008banner2.png"    width="1020px" height="106px" alt="banner">
	</div>
	<div id="banner_right">
		<a href="http://www.worldothellofederation.com/" target="_blank"><img src="images/new_WOFLogoAnimated.gif" width="133px" height="106px" alt="WOF logo"></a>
	</div>
</div>

 <br>
 <br>

 <center>
<table bgcolor="#FFFFFF" border="1" cellspacing="0" style="border-collapse: collapse" cellpadding="5" >

<tr bgcolor="#FFCC00">
<th>Round
<th>Number of replayable games</th>
<th>Progress</th>
<th>Flickr album</th>
<th>Transcripts (PDF file)</th>
</tr>


<tr align="center">
 <td>
<center>1</center>
</td>
<td><a href="woc2008_round1.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055951/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055951/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>2</center>
</td>
<td><a href="woc2008_round2.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247460220/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247460220/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>3</center>
</td>
<td><a href="woc2008_round3.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055835/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055835/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>4</center>
</td>
<td><a href="woc2008_round4.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247459810/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247459810/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>5</center>
</td>
<td><a href="woc2008_round5.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055711/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055711/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>6</center>
</td>
<td><a href="woc2008_round6.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247459164/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247459164/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>7</center>
</td>
<td><a href="woc2008_round7.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055639/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055639/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>8</center>
</td>
<td><a href="woc2008_round8.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247458362/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247458362/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>9</center>
</td>
<td><a href="woc2008_round9.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247457710/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247457710/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>10</center>
</td>
<td><a href="woc2008_round10.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247457636/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247457636/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>11</center>
</td>
<td><a href="woc2008_round11.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055495/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055495/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>12</center>
</td>
<td><a href="woc2008_round12.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055483/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609267055483/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>13</center>
</td>
<td><a href="woc2008_round13.htm?tag=1">1</a> out of 31 transcripts (3%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247456536/"><img border="0" src="images/progress_00.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247456536/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
<tr align="center">
 <td>
<center>semi-finals & finals</center>
</td>
<td><a href="woc2008_round_final.htm?tag=1">1</a> out of 8 transcripts (13%)
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247456510/"><img border="0" src="images/progress_10.png" width="202" height="22"></a>
</td>
<td><a href="http://www.flickr.com/photos/woc2008oslo/sets/72157609247456510/"><img border="0" src="images/icone_Flickr.png" width="33" height="33"></a>
</td>
 <td><img border="0" src="images/icone_vide.png" width="33" height="33">
</td>
</table>

 <br>


 <div class="lien_texte">

<!--
Transcripts of final day
<a href="./transcripts/round_final/WOC_2008_roundFinal.pdf" target="_blank">(PDF)</a>
: Not available yet<br>

 -->

</div>

 </center>

<hr>

 <center>
<h3>Help us typing transcripts!</h3>
We plan to publish a photo of each transcript sheet of the WOC 2008 on Flickr.com.
 <br>  YOU can help the community by reading the transcript and typing it in your favorite othello program.
 <br>
 <br>  Please then export the list of moves for the game and add it as a text commentary (flickr and yahoo accounts needed) to the photo, so that:
  <li>everybody knows the transcript recording has been completed,</li>
  <li>the game will soon be replayable with the applet here!</li>
 <br>
 </center>

<hr>

 <center>
<!-- Sponsors images -->
	<table border="0" cellpadding="10" cellspacing="0" style="border-collapse: collapse">
		<tr><td align="center">
			<a target="_blank" href="http://www.anjar.com/">
			<img border="0" src="images/anjarlogo_sm.gif" width="99" height="34" alt="Anjar"></a>
			 <br>
			Othello &reg; is a registered<br> trademark of Anjar Co.
		 </td><td align="center">
			<a target="_blank" href="http://www.megahouse.co.jp/">
			<img border="0" src="images/MegaHouse.jpg" width="90" height="117" alt="Megahouse"></a>
		 </td><td align="center">
			<img src="images/mattel.gif" width="41" height="63" alt="Mattel">
		</td></tr>
	</table>
 </center>

</body>
</html>

*)


end.
