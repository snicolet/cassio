UNIT UnitMoulinette;


INTERFACE






USES UnitDefCassio;


{ Initialisation de l'unite }
procedure InitUnitMoulinette;



{ Utilitaires pour parser des proprietes (entre guillemets) de fichiers PGN ou XOF }
procedure ParserScoreTheoriqueDansFichierPGN(const ligne : String255; var theorique : SInt64);
procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; strict : boolean; var pseudo,nomDansThor : String255; var numero : SInt64);
procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; numeroTournoiParDefaut : SInt64; var pseudo,nomDansThor : String255; var numero : SInt64);


{ Moulinettes d'import }
function  AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : String255; fichierPGN : basicfile) : OSErr;
function  AjouterPartiesFichierDestructureDansListe(format : formats_connus; fichier : basicfile) : OSErr;
procedure ImportBaseAllDrawLinesDeBougeard;
function  ImporterFichierPartieDansListe(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
procedure ImporterToutesPartiesRepertoire;
procedure BaseLogKittyEnFormatThor(nomBaseLogKitty,NomBaseFormatThor : String255);



{ Moulinettes d'export }
procedure ExportListeAuFormatTexte(descriptionLigne : String255; var nbPartiesExportees : SInt64);
procedure ExportListeAuFormatPGN;
procedure ExportListeAuFormatHTML;
procedure ExportListeAuFormatXOF;


{ Export d'une partie individuelle }
procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);


{ Fonction d'ecriture d'une partie illegale dans le rapport }
procedure WritelnPartieIllegaleDansRapport(partieIllegaleEnAlpha : String255);




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, Sound, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitRapport, SNEvents, basicfile, UnitActions
    , UnitEvenement, UnitSolve, UnitCriteres, UnitScannerOthellistique, UnitPositionEtTrait, MyMathUtils, UnitScannerUtils, MyFileSystemUtils
    , MyStrings, MyQuickDraw, UnitNouveauFormat, UnitBaseNouveauFormat, UnitAccesNouveauFormat, UnitRapport, UnitTriListe, UnitRapportImplementation
    , UnitCurseur, UnitUtilitaires, UnitEnvirons, UnitJeu, MyStrings, UnitRapportUtils, UnitEntreesSortiesListe, UnitGameTree
    , UnitArbreDeJeuCourant, UnitImportDesNoms, MyFileSystemUtils, UnitMiniProfiler, UnitDialog, UnitPressePapier, UnitTHOR_PAR, MyMathUtils
    , basicfile, UnitScannerUtils, UnitGenericGameFormat, UnitFenetres, UnitGestionDuTemps, UnitNormalisation, UnitPackedThorGame, SNEvents
    , UnitScannerOthellistique, UnitRapportWindow, UnitStringSet, UnitFormatsFichiers, UnitFichierAbstrait, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/Moulinette.lk}
{$ENDC}


{END_USE_CLAUSE}








const kLongueurNomsDansURL = 13;


var gOptionsExportBase : record
                           patternLigne : String255;
                           fic : basicfile;
                           subDirectoryName : String255;
                           nomsFichiersUtilises : StringSet;
                         end;
    gTablePartiesJoueursImprobables : StringSet;




procedure InitUnitMoulinette;
begin
end;






procedure ParserJoueurDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; strict : boolean; var pseudo,nomDansThor : String255; var numero : SInt64);
var oldParsingProtection : boolean;
    s1,reste : String255;
begin
  oldParsingProtection := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);

  Parse2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);

  SetParserProtectionWithQuotes(oldParsingProtection);

  if not(PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo,strict,nomDansThor,numero)) then
    begin
      if not(strict) then
        AjoutePseudoInconnu(ReadStringFromRessource(TextesErreursID,7),pseudo,nomDansThor);  {'pseudo inconnu : '}
    end;

end;


procedure ParserTournoiDansFichierPNG(const nomDictionnaireDesPseudos,ligne : String255; numeroTournoiParDefaut : SInt64; var pseudo,nomDansThor : String255; var numero : SInt64);
var oldParsingProtection : boolean;
    s1,reste : String255;
begin
  oldParsingProtection := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);

  Parse2(ligne,s1,pseudo,reste);
  pseudo := DeleteSubstringBeforeThisChar('"',pseudo,false);
  pseudo := DeleteSubstringAfterThisChar('"',pseudo,false);

  SetParserProtectionWithQuotes(oldParsingProtection);

  if not(PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo,nomDansThor,numero)) then
    begin
      AjoutePseudoInconnu(ReadStringFromRessource(TextesErreursID,8),pseudo,nomDansThor);  {'tournoi inconnu : '}
      numero := numeroTournoiParDefaut;
    end;
end;


procedure ParserDateDansFichierPGN(const ligne : String255; var annee,mois,jour : SInt64);
var date,f1,f2,f3,s1,reste : String255;
    oldParsingSet : SetOfChar;
    oldParsingProtection : boolean;
begin
  oldParsingProtection := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);

  Parse2(ligne,s1,date,reste);
  date := DeleteSubstringBeforeThisChar('"',date,false);
  date := DeleteSubstringAfterThisChar('"',date,false);

  SetParserProtectionWithQuotes(oldParsingProtection);

  oldParsingSet := GetParserDelimiters;
  SetParserDelimiters(['.','-','/']);

  Parse3(date,f1,f2,f3,reste);
  annee := StrToInt32(f1);
  mois  := StrToInt32(f2);
  jour  := StrToInt32(f3);

  SetParserDelimiters(oldParsingSet);
end;


procedure ParserScoreTheoriqueDansFichierPGN(const ligne : String255; var theorique : SInt64);
var score,scoreNoir,scoreBlanc : String255;
    oldParsingProtection : boolean;
    theoriqueNoir,theoriqueBlanc : SInt64;
begin
  oldParsingProtection := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);

  score := DeleteSubstringBeforeThisChar('"',ligne,false);
  score := DeleteSubstringAfterThisChar('"',score,false);

  scoreNoir  := DeleteSubstringAfterThisChar('-',score,false);
  scoreBlanc := DeleteSubstringBeforeThisChar('-',score,false);

  theoriqueNoir  := StrToInt32(scoreNoir);
  theoriqueBlanc := StrToInt32(scoreBlanc);

  if ((theoriqueNoir + theoriqueBlanc) >= 60) and
     ((theoriqueNoir + theoriqueBlanc) <= 64)
    then theorique := theoriqueNoir;

  SetParserProtectionWithQuotes(oldParsingProtection);
end;


procedure EssayerInterpreterJoueursPGNCommeNomDeFichier(pseudoNoir,pseudoBlanc : String255; var numeroNoir,numeroBlanc : SInt64; var confiance : double);
var chaineJoueurs : String255;
    partieJoueursImprobables : String255;
    aux : SInt64;
begin

  (* on crée un nom de fichier fictif le plus ressemblant possible *)

  if (numeroNoir <> kNroJoueurInconnu) and
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
var i,longueur,nbCoupsLegaux : SInt64;
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


function AjouterPartiesFichierPGNDansListe(nomDictionnaireDesPseudos : String255; fichierPGN : basicfile) : OSErr;
var ligne,s,coupsPotentiels : String255;
    nroReferencePartieAjoutee : SInt64;
    partieEnAlpha : String255;
    partieLegale : boolean;
    partieDoublon : boolean;
    nbPartiesDansFichierPGN : SInt64;
    nbPartiesImportees : SInt64;
    lastNbPartiesImporteesDansRapport  : SInt64;
    lastNbPartiesFichierPGNDansRapport : SInt64;
    erreurES : OSErr;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    numeroTournoiParDefaut : SInt64;
    nbCoupsRecus : SInt16;
    nbPionsNoirs,nbPionsBlancs : SInt64;
    numeroNoir,numeroBlanc,numeroTournoi : SInt64;
    pseudoNoir,pseudoBlanc,pseudoTournoi : String255;
    annee,tickDepart : SInt64;
    anneeDansRecord,moisDansRecord,jourDansRecord : SInt64;
    nomNoir,nomBlanc,nomTournoi : String255;
    compteurDoublons,aux : SInt64;
    nomFichierPGN : String255;
    nomLongDuFichier : String255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    withMetaphone : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    partieInternet : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt64;
    partieEstDouteuse : boolean;
    doitSauterLesPartiesInternetSansJoueurConnu : boolean;
    tailleFichierPGN : SInt64;
    // ligneNomNoir : String255;
    // ligneNomBlanc : String255;
    lastTickEscapeDansQueue : SInt64;
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


  nomFichierPGN := ExtractFileOrDirectoryName(GetName(fichierPGN.info));
  erreurES      := ExtractFileName(fichierPGN.info, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFichierPGN := DeleteSubstringAfterThisChar('.',nomFichierPGN,false);

  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;

  numeroTournoi := -1;
  if (myDate.month <= 6) and TrouveNumeroDuTournoi('parties internet (1-6)',numeroTournoiParDefaut,0) then DoNothing;
  if (myDate.month >  6) and TrouveNumeroDuTournoi('parties internet (7-12)',numeroTournoiParDefaut,0) then DoNothing;
  if numeroTournoi < 0 then numeroTournoiParDefaut := kNroTournoiDiversesParties;
  annee := myDate.year;


  erreurES := OpenFile(fichierPGN);
  if erreurES <> NoErr then
    begin
      SimpleAlertForFile(nomFichierPGN,erreurES);
      AjouterPartiesFichierPGNDansListe := erreurES;
      exit;
    end;

  erreurES := GetFileSize(fichierPGN, tailleFichierPGN);
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

  while not(EndOfFile(fichierPGN,erreurES)) and not(utilisateurVeutSortir) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      if (Pos('[Event',ligne) = 0) then
        begin
          erreurES := Readln(fichierPGN , s);
          ligne := s;
        end;

      {WritelnDansRapport(ligne);}

      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne = '') or (ligne[1] = '%')
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
                  erreurES := Readln(fichierPGN,s);
      			      ligne := s;
      			      EnleveEspacesDeGaucheSurPlace(ligne);

      			      {WritelnDansRapport(ligne);}
      			      {Sysbeep(0);
      			      AttendFrappeClavier;}
      			
      			

      			      if (Pos('[White ',ligne) > 0) or (Pos('[White"',ligne) > 0)
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

      			      if (Pos('[Black ',ligne) > 0) or (Pos('[Black"',ligne) > 0)
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

      			      if (Pos('[Site "kurnik',ligne) > 0) or (Pos('[Site "www.kurnik',ligne) > 0) or
      			         (Pos('[Site "playok',ligne) > 0) or (Pos('[Site "www.playok',ligne) > 0) or
      			         (Pos('[Site "VOG',ligne) > 0)
      			        then partieInternet := true else

      			      if (Pos('[Date "',ligne) > 0)
      			        then ParserDateDansFichierPGN(ligne,anneeDansRecord,moisDansRecord,jourDansRecord) else

      			      if (Pos('[TheoricalScore "',ligne) > 0) or (Pos('[TheoreticalScore "',ligne) > 0)
      			        then ParserScoreTheoriqueDansFichierPGN(ligne,theorique) else

      			      if (Pos('.',ligne) > 0) and (Pos('[',ligne) = 0) then
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

			            utilisateurVeutSortir := utilisateurVeutSortir or Quitter ;
			            if ((TickCount - lastTickEscapeDansQueue) > 0) then
			              begin
			                utilisateurVeutSortir := utilisateurVeutSortir or EscapeDansQueue;
			                lastTickEscapeDansQueue := TickCount;
			              end;

                until partieComplete or
                      InRange(Pos('0-1',ligne),1,2) or
                      InRange(Pos('1/2-1/2',ligne),1,2) or
                      InRange(Pos('1-0',ligne),1,2) or
                      (Pos('[Event',ligne) > 0) or
                      EndOfFile(fichierPGN,erreurES) or
                      utilisateurVeutSortir;

                if Pos('[Event',ligne) = 0 then ligne := '';

                (*
                WritelnDansRapport(partieEnAlpha);
                WritelnDansRapport(pseudoNoir);
                WritelnDansRapport(pseudoBlanc);
                *)

                (*
                if (Pos('Caspard',nomNoir) > 0) or (Pos('Caspard',nomBlanc) > 0) then
                  begin
                    WritelnDansRapport(partieEnAlpha);
                    WritelnDansRapport(ligneNomNoir);
                    WritelnDansRapport(ligneNomBlanc);
                  end;
                *)

                partieLegale := (nbCoupsRecus > 10) and EstUnePartieOthelloAvecMiroir(partieEnAlpha);

                {on cherche si on a deja mis la partie}
                partieDoublon := false;
                if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) and
                   MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
                   begin
                     partieDoublon := true;
                     WritelnDansRapport(ReadStringFromRessource(TextesErreursID,9) + LeftStr(partieEnAlpha,60));  {'doublon : '}
                     compteurDoublons := compteurDoublons + 1;
                   end;

                inc(nbPartiesDansFichierPGN);



                if partieLegale
                   and not(partieDoublon)
                   and not(doitSauterLesPartiesInternetSansJoueurConnu and partieInternet and (numeroNoir = 0) and (numeroBlanc = 0)) then
                  begin

                    partieEstDouteuse := false;

                    AddStringToSet(partieEnAlpha,0,tableDoublons);
                    AddStringToSet(Concat(partieEnAlpha,' '),0,tableDoublons);

                    if (anneeDansRecord > 0) then annee := anneeDansRecord;

                    if partieInternet and (numeroTournoi = numeroTournoiParDefaut) then
                      begin
                        if (moisDansRecord >= 1) and (moisDansRecord <= 6)  then numeroTournoi := kNroTournoiPartiesInternet_1_6 else
                        if (moisDansRecord >= 7) and (moisDansRecord <= 12) then numeroTournoi := kNroTournoiPartiesInternet_7_12
                          else numeroTournoi := kNroTournoiPartiesInternet;
                      end;


                    if not(partieComplete) then
                      begin
                        if partieInternet and (nbCoupsRecus >= 40) and PeutCompleterPartieAvecLigneOptimale(partieEnAlpha)
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
                              WritelnDansRapport(ReadStringFromRessource(TextesErreursID,11)+LeftStr(partieEnAlpha,60));  // 'incomplete : '
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





                if ((nbPartiesDansFichierPGN mod 2000 = 0) and (lastNbPartiesFichierPGNDansRapport <> nbPartiesDansFichierPGN)) or
                   ((nbPartiesImportees mod 200 = 0) and (lastNbPartiesImporteesDansRapport <> nbPartiesImportees))
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

  erreurES := CloseFile(fichierPGN);


  if utilisateurVeutSortir
    then WritelnDansRapport('Lecture du fichier interrompue par l''utilisateur...');

  WritelnDansRapport('temps de lecture = ' + SecondesEnJoursHeuresSecondes((TickCount - tickDepart + 30) div 60));

  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(GetName(fichierPGN.info))
    then
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,44),IntToStr(nbPartiesImportees),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,45),IntToStr(nbPartiesImportees),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFichierPGN > 1)
        then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,42),IntToStr(nbPartiesImportees),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,43),IntToStr(nbPartiesImportees),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}
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




function AjouterPartiesFichierDestructureDansListe(format : formats_connus; fichier : basicfile) : OSErr;
var nroReferencePartieAjoutee : SInt64;
    partieEnAlpha : String255;
    chaineJoueurs : String255;
    nomsDesJoueursParDefaut : String255;
    partieLegale : boolean;
    nbPartiesDansFic : SInt64;
    nbPartiesIllegales : SInt64;
    erreurES : OSErr;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    nbCoupsRecus : SInt16;
    nbPionsNoirs,nbPionsBlancs : SInt64;
    numeroNoir,numeroBlanc,numeroTournoi : SInt64;
    annee,tickDepart : SInt64;
    compteurDoublons,aux : SInt64;
    nomFic : String255;
    nomLongDuFichier : String255;
    tableDoublons : StringSet;
    autoVidage : boolean;
    ecritLog : boolean;
    partieComplete : boolean;
    partieDoublon : boolean;
    joueursTrouves : boolean;
    utilisateurVeutSortir : boolean;
    theorique : SInt64;
    derniereLigneLue : String255;
    nombreDeLignesLues : SInt64;
    confianceDansLesJoueurs : double;
    bidReal : double;
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

    while (result = '') and not(utilisateurVeutSortir) and (erreurES = NoErr) and not(EOFFichierAbstrait(myZone,erreurES)) do
      begin
        erreurES := GetNextLineDansFichierDestructure(s);
        result := result + s;
        utilisateurVeutSortir := utilisateurVeutSortir or Quitter or EscapeDansQueue;
      end;

    TrouveJoueurs := result;
    derniereLigneLue := '';
  end;

  function TrouvePartie : String255;
  var s,result : String255;
      partieComplete : boolean;
      partieIllegale : boolean;
      nbCoups,dernierNbCoups : SInt64;
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

              partieIllegale := (result = '') or not(EstUnePartieOthello(result,false));

              {
              WritelnDansRapport('s = '+s);
              WritelnDansRapport('result = '+result);
              WritelnStringAndBooleenDansRapport('partieIllegale = ',partieIllegale);
              WritelnDansRapport('');}
            end;

          dernierNbCoups := nbCoups;
          nbCoups := LENGTH_OF_STRING(result) div 2;

        end;

      utilisateurVeutSortir := utilisateurVeutSortir or Quitter or EscapeDansQueue;

    until (nbCoups = dernierNbCoups) or partieComplete or partieIllegale or utilisateurVeutSortir or (erreurES <> NoErr) or EOFFichierAbstrait(myZone,erreurES);

    TrouvePartie := result;
    if partieComplete or partieIllegale then derniereLigneLue := '';
  end;



  procedure LitProchainePartieFormatGGF(var chaineJoueurs,partieEnAlpha : String255);
  var theGame:PartieFormatGGFRec;
  begin
    partieEnAlpha := '';
    chaineJoueurs := '';

    erreurES := ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(myZone,kTypeFichierGGF,theGame);

    partieEnAlpha := theGame.coupsEnAlpha;

    if (theGame.joueurNoir = '') or (theGame.joueurBlanc = '')
      then chaineJoueurs := nomsDesJoueursParDefaut
      else
        if EstUnePartieOthelloAvecMiroir(partieEnAlpha) and
           EstUnePartieOthelloTerminee(partieEnAlpha,true,nbPionsNoirs,nbPionsBlancs)
          then chaineJoueurs := theGame.joueurNoir + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + theGame.joueurBlanc
          else chaineJoueurs := theGame.joueurNoir + ' 0-0 ' + theGame.joueurBlanc;

    utilisateurVeutSortir := utilisateurVeutSortir or Quitter or EscapeDansQueue;
  end;

  procedure LitProchaineLigneAvecJoueursEtPartie(var chaineJoueurs,partieEnAlpha : String255; var confianceDansLesJoueurs : double);
  var s,moves : String255;
      partieTrouvee : boolean;
      nbPionsNoirs,nbPionsBlancs : SInt64;
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
                partieTrouvee := partieTrouvee and EstUnePartieOthelloAvecMiroir(moves);
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

      utilisateurVeutSortir := utilisateurVeutSortir or Quitter or EscapeDansQueue;

    until partieTrouvee or utilisateurVeutSortir or (erreurES <> NoErr) or EOFFichierAbstrait(myZone,erreurES);

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

      utilisateurVeutSortir := utilisateurVeutSortir or Quitter or EscapeDansQueue;

    until partieTrouvee or utilisateurVeutSortir or (erreurES <> NoErr) or EOFFichierAbstrait(myZone,erreurES);

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


  nomFic := ExtractFileOrDirectoryName(GetName(fichier.info));
  erreurES := ExtractFileName(fichier.info, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);
  nomFic := DeleteSubstringAfterThisChar('.',nomFic,false);
  nomsDesJoueursParDefaut := nomLongDuFichier;


  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;


  erreurES := OpenFile(fichier);
  if (erreurES <> NoErr) then
    begin
      SimpleAlertForFile(nomLongDuFichier,erreurES);
      AjouterPartiesFichierDestructureDansListe := erreurES;
      exit;
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

  while not(EOFFichierAbstrait(myZone,erreurES)) and not(utilisateurVeutSortir) and (erreurES = NoErr) do
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

      partieLegale := (nbCoupsRecus > 10) and EstUnePartieOthelloAvecMiroir(partieEnAlpha);

      {on cherche si on a deja mis la partie}
      partieDoublon := false;
      if MemberOfStringSet(partieEnAlpha,aux,tableDoublons) and
         MemberOfStringSet(Concat(partieEnAlpha,' '),aux,tableDoublons) then
         begin
           partieDoublon := true;
           WritelnDansRapport(ReadStringFromRessource(TextesErreursID,9)+partieEnAlpha);  {'doublon : '}
           compteurDoublons := compteurDoublons + 1;
         end;

      if partieLegale and not(partieDoublon)
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
                  if not((format = kTypeFichierSimplementDesCoupsMultiple) and (chaineJoueurs = nomLongDuFichier)) then
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

      if not(partieLegale) and (partieEnAlpha <> '') then
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
  erreurES := CloseFile(fichier);

  WritelnDansRapport('');
  if EstUnNomDeFichierTemporaireDePressePapier(GetName(fichier.info))
    then
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,44),IntToStr(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 parties depuis le presse-papier}
        else WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,45),IntToStr(nbPartiesDansFic),'','',''))  {J'ai réussi à importer ^0 partie depuis le presse-papier}
    else
      if (nbPartiesDansFic > 1)
        then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,42),IntToStr(nbPartiesDansFic),nomLongDuFichier,'',''))   {J'ai réussi à importer ^0 parties dans le fichier « ^1 »}
        else WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,43),IntToStr(nbPartiesDansFic),nomLongDuFichier,'',''));  {J'ai réussi à importer ^0 partie dans le fichier « ^1 »}

  if (nbPartiesIllegales > 1)
    then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,48),IntToStr(nbPartiesIllegales),'','','')) else  {Il y avait ^0 parties trop courtes ou illégales}
  if (nbPartiesIllegales = 1)
    then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,47),IntToStr(nbPartiesIllegales),'','',''));  {Il y avait ^0 partie trop courte ou illégale}

  if (nbPartiesDansFic < nombreDeLignesLues)
    then WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesRapportID,46),IntToStr(nombreDeLignesLues),'','',''));   {Pour info, ce fichier contenait ^0 lignes}
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
    score,nbPartiesDansBaseLogKitty,i : SInt64;
    erreurES : OSErr;
    inputBaseLogKitty,outputBaseThor : basicfile;
    enteteFichierPartie : t_EnTeteNouveauFormat;
    partieNF : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
begin

  WritelnDansRapport('entrée dans BaseLogKittyEnFormatThor…');


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);

  if nomBaseLogKitty = '' then
    begin
      SimpleAlertForFile(nomBaseLogKitty,0);
      exit;
    end;
  {SetDebugFiles(false);}


  erreurES := FichierTexteDeCassioExiste(nomBaseLogKitty,inputBaseLogKitty);
  if erreurES <> NoErr then
    begin
      SimpleAlertForFile(nomBaseLogKitty,erreurES);
      exit;
    end;

  erreurES := OpenFile(inputBaseLogKitty);
  if erreurES <> NoErr then
    begin
      SimpleAlertForFile(nomBaseLogKitty,erreurES);
      exit;
    end;

  erreurES := FichierTexteDeCassioExiste(NomBaseFormatThor,outputBaseThor);
  if erreurES = fnfErr then erreurES := CreeFichierTexteDeCassio(NomBaseFormatThor,outputBaseThor);
  if erreurES = 0 then
    begin
      erreurES := OpenFile(outputBaseThor);
      erreurES := ClearFileContent(outputBaseThor);
    end;
  if erreurES <> 0 then
    begin
      SimpleAlertForFile(NomBaseFormatThor,erreurES);
      erreurES := CloseFile(outputBaseThor);
      exit;
    end;

  if erreurES <> NoErr then
    begin
      SimpleAlertForFile(NomBaseFormatThor,erreurES);
      exit;
    end;

  nbPartiesDansBaseLogKitty := 0;
  erreurES := NoErr;
  ligne := '';
  while not(EndOfFile(inputBaseLogKitty,erreurES)) do
    begin


      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);

      erreurES := Readln(inputBaseLogKitty,s);
      ligne := s;
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne = '') or (ligne[1] = '%')
        then
          begin
            {erreurES := Writeln(outputBaseThor,s);}
          end
        else
          begin
            Parse3(ligne,PartieEnAlpha,scoreEnChaine,numeroLigneEnChaine,reste);


            if (PartieEnAlpha <> '') and (scoreEnChaine <> '') then
              begin
                inc(nbPartiesDansBaseLogKitty);


                partie120 := partieEnAlpha;
                Normalisation(partie120,autreCoupQuatreDiag,false);
                partieEnAlpha := partie120;

                TraductionAlphanumeriqueEnThor(PartieEnAlpha,partieEnThor);
                if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) or (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60) then
                  begin
                    WritelnDansRapport(ReadStringFromRessource(TextesErreursID,12)+partieEnAlpha);   {'problème sur la longueur de la partie : '}
                    SysBeep(0);
                  end;

                StrToInt32(scoreEnChaine,score);
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

  erreurES := CloseFile(inputBaseLogKitty);
  erreurES := CloseFile(outputBaseThor);
  SetFileCreatorFichierTexte(outputBaseThor,FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(outputBaseThor,FOUR_CHAR_CODE('QWTB'));


  RemettreLeCurseurNormalDeCassio;
end;




procedure ExporterPartieDansFichierTexte(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
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
        ligne := ReplaceStringOnce(ligne, '\\' , '‰Ω');
      while (Pos('\$',ligne) > 0) do
        ligne := ReplaceStringOnce(ligne, '\$' , '◊√');

      TraductionThorEnAlphanumerique(theGame,partieEnAlpha);
      TraductionThorEnSuedois(theGame,partieEnSuedois);
      COPY_PACKED_GAME_TO_STR60(theGame,partie60);

      (* un numero (non fixe entre les sessions de Cassio) pour la partie *)
      ligne := ReplaceVariable(ligne,        '$CASSIO_GAME_ID'        ,IntToStr(numeroReference) );

      (* les coups de la partie *)
      ligne := ReplaceVariable(ligne,        '$CASSIO_THOR_MOVES'     ,partie60 );
      ligne := ReplaceVariable(ligne,        '$CASSIO_SWEDISH_MOVES'  ,partieEnSuedois );
      ligne := ReplaceVariable(ligne,        '$CASSIO_GAME'           ,partieEnAlpha );

      (* Les tournois *)
      ligne := ReplaceVariable(ligne,        '$CASSIO_TOURN_SHORT'    ,StripDiacritics(GetNomCourtTournoiParNroRefPartie(numeroReference)) );
      if EstUnePartieAvecTournoiJaponais(numeroReference)
        then ligne := ReplaceVariable(ligne, '$CASSIO_TOURN_JAPANESE' ,GetNomJaponaisDuTournoiParNroRefPartie(numeroReference) )
        else ligne := ReplaceVariable(ligne, '$CASSIO_TOURN_JAPANESE' ,StripDiacritics(GetNomTournoiParNroRefPartie(numeroReference) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_TOURN_NUMBER'   ,IntToStr(GetNroTournoiParNroRefPartie(numeroReference)) );

      { bien penser a mettre toutes les variables qui commencent par $CASSIO_TOURN avant la ligne suivante }
      ligne := ReplaceVariable(ligne,        '$CASSIO_TOURN'          ,StripDiacritics(GetNomTournoiParNroRefPartie(numeroReference)) );

      (* les joueurs *)

      ligne := ReplaceVariable(ligne,        '$CASSIO_BLACK_SHORT'    ,StripDiacritics(GetNomJoueurNoirSansPrenomParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_WHITE_SHORT'    ,StripDiacritics(GetNomJoueurBlancSansPrenomParNroRefPartie(numeroReference)) );
      if EstUnePartieAvecJoueurNoirJaponais(numeroReference)
        then ligne := ReplaceVariable(ligne, '$CASSIO_BLACK_JAPANESE' ,GetNomJaponaisDuJoueurNoirParNroRefPartie(numeroReference) )
        else ligne := ReplaceVariable(ligne, '$CASSIO_BLACK_JAPANESE' ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference) );
      if EstUnePartieAvecJoueurBlancJaponais(numeroReference)
        then ligne := ReplaceVariable(ligne, '$CASSIO_WHITE_JAPANESE' ,GetNomJaponaisDuJoueurBlancParNroRefPartie(numeroReference) )
        else ligne := ReplaceVariable(ligne, '$CASSIO_WHITE_JAPANESE' ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_BLACK_NUMBER'   ,IntToStr(GetNroJoueurNoirParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_WHITE_NUMBER'   ,IntToStr(GetNroJoueurBlancParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_BLACK_FFO'      ,IntToStr(GetNroFFOJoueurNoirParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_WHITE_FFO'      ,IntToStr(GetNroFFOJoueurNoirParNroRefPartie(numeroReference)) );

      { bien pensser a mettre toutes les variables qui commencent par $CASSIO_BLACK et $CASSIO_WHITE avant les deux lignes suivantes }
      ligne := ReplaceVariable(ligne,        '$CASSIO_BLACK'          ,GetNomJoueurNoirCommeDansPappParNroRefPartie(numeroReference) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_WHITE'          ,GetNomJoueurBlancCommeDansPappParNroRefPartie(numeroReference) );

      (* les scores reels et theoriques *)
      ligne := ReplaceVariable(ligne,        '$CASSIO_SCORE_BLACK'    ,IntToStr(GetScoreReelParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_SCORE_WHITE'    ,IntToStr(64-GetScoreReelParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_THEOR_BLACK'    ,IntToStr(GetScoreTheoriqueParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_THEOR_WHITE'    ,IntToStr(64-GetScoreTheoriqueParNroRefPartie(numeroReference)) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_THEOR_WINNER'   ,GetGainTheoriqueParNroRefPartie(numeroReference) );

      (* le nom de la base et l'annee *)
      ligne := ReplaceVariable(ligne,        '$CASSIO_BASE'           ,GetNomDistributionParNroRefPartie(numeroReference) );
      ligne := ReplaceVariable(ligne,        '$CASSIO_YEAR'           ,IntToStr(GetAnneePartieParNroRefPartie(numeroReference)) );


      (* echappement *)
      while (Pos('◊√',ligne) > 0) do
        ligne := ReplaceStringOnce(ligne, '◊√' , '$');
      while (Pos('‰Ω',ligne) > 0) do
        ligne := ReplaceStringOnce(ligne, '‰Ω' , '\');

      erreurES := Writeln(fic,ligne);
      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));     {'Export : ^0 parties…'}

    end;
end;


procedure ExporterPartieDansFichierPGN(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
var erreurES : OSErr;
    s,s1,s2,ligne : String255;
    k : SInt64;
begin
  with gOptionsExportBase do
    begin

      ligne := '[Event "'+StripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[Date "'+IntToStr(GetAnneePartieParNroRefPartie(numeroReference))+'.01.01"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[Round "-"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[Database "'+StripDiacritics(GetNomDistributionParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[Black "'+StripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[White "'+StripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[Result "'+IntToStr(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                           IntToStr(64-GetScoreReelParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      ligne := '[TheoreticalScore "'+IntToStr(GetScoreTheoriqueParNroRefPartie(numeroReference)) + '-' +
                                     IntToStr(64-GetScoreTheoriqueParNroRefPartie(numeroReference))+'"]';
      erreurES := Writeln(fic,ligne);

      erreurES := Writeln(fic,'');

      TraductionThorEnAlphanumerique(theGame,s);
      for k := 1 to 59 do
        begin
          s1 := TPCopy(s,k*2 - 1,2);
          if s1 = '' then s1 := '--';
          s2 := TPCopy(s,k*2 + 1,2);
          if s2 = '' then s2 := '--';
          if odd(k) then
            begin
              ligne := IntToStr(1 + (k div 2)) + '. '+s1+' '+s2+' ';
              erreurES := Writeln(fic,ligne);
            end;
        end;

      ligne := IntToStr(GetScoreReelParNroRefPartie(numeroReference)) + '-' + IntToStr(64-GetScoreReelParNroRefPartie(numeroReference));
      erreurES := Writeln(fic,ligne);

      erreurES := Writeln(fic,'');
      erreurES := Writeln(fic,'');

      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));    {'Export : ^0 parties…'}

    end;
end;


procedure ExporterPartieDansFichierXOF(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
var erreurES : OSErr;
    moves,ligne : String255;
begin
  with gOptionsExportBase do
    begin


      ligne :=  '  <game>';
      erreurES := Writeln(fic,ligne);

      ligne :=  '   <event'+
                ' date="'+IntToStr(GetAnneePartieParNroRefPartie(numeroReference))+'"' +
                ' name="'+StripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := Writeln(fic,ligne);

      if GetScoreReelParNroRefPartie(numeroReference) > 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="black"' +
                    ' type="normal">' +
                     IntToStr(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     IntToStr(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := Writeln(fic,ligne);
        end;

      if GetScoreReelParNroRefPartie(numeroReference) = 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="draw"' +
                    ' type="normal">' +
                     IntToStr(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     IntToStr(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := Writeln(fic,ligne);
        end;

      if GetScoreReelParNroRefPartie(numeroReference) < 32 then
        begin
          ligne :=  '   <result'+
                    ' winner="white"' +
                    ' type="normal">' +
                     IntToStr(GetScoreReelParNroRefPartie(numeroReference)) + '-' +
                     IntToStr(64-GetScoreReelParNroRefPartie(numeroReference)) +
                    '</result>';
          erreurES := Writeln(fic,ligne);
        end;

      ligne :=  '   <player'+
                ' color="black"' +
                ' name="'+StripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := Writeln(fic,ligne);

      ligne :=  '   <player'+
                ' color="white"' +
                ' name="'+StripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+'"' +
                ' />';
      erreurES := Writeln(fic,ligne);

      TraductionThorEnAlphanumerique(theGame,moves);
      ligne :=  '   <moves game="othello-8x8" type="flat">' +
                moves +
                '</moves>';
      erreurES := Writeln(fic,ligne);

      ligne :=  '   </game>';
      erreurES := Writeln(fic,ligne);

      inc(compteur);

      if (compteur mod 1000) = 0 then
        WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));     {'Export : ^0 parties…'}

    end;
end;



procedure ExportListeAuFormatTexte(descriptionLigne : String255; var nbPartiesExportees : SInt64);
var reply : SFReply;
    prompt : String255;
    whichSpec : fileInfo;
    erreurES : OSErr;
    exportTexte : basicfile;
    compteur : SInt64;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d'export ? '}
  SetNameOfSFReply(reply, 'Export.txt');
  if MakeFileName(reply,prompt,whichSpec) then
    begin

      erreurES := FileExists(whichSpec,exportTexte);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreateFile(whichSpec,exportTexte);
      if erreurES = NoErr then
        begin
          erreurES := OpenFile(exportTexte);
          erreurES := ClearFileContent(exportTexte);
        end;
      if erreurES <> NoErr then
        begin
          SimpleAlertForFile(GetNameOfSFReply(reply),erreurES);
          erreurES := CloseFile(exportTexte);
          exit;
        end;

      gOptionsExportBase.patternLigne    := descriptionLigne;
      gOptionsExportBase.fic             := exportTexte;

      (* WritelnDansRapport('descriptionLigne = '+ descriptionLigne); *)

      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierTexte,compteur);

      erreurES := CloseFile(exportTexte);

      WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));   {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;


procedure ExportListeAuFormatPGN;
var reply : SFReply;
    prompt : String255;
    whichSpec : fileInfo;
    erreurES : OSErr;
    exportFichier : basicfile;
    compteur,nbPartiesExportees : SInt64;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d''export ? ';}
  SetNameOfSFReply(reply, 'Export.pgn');
  if MakeFileName(reply,prompt,whichSpec) then
    begin

      erreurES := FileExists(whichSpec,exportFichier);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreateFile(whichSpec,exportFichier);
      if erreurES = NoErr then
        begin
          erreurES := OpenFile(exportFichier);
          erreurES := ClearFileContent(exportFichier);
        end;
      if erreurES <> NoErr then
        begin
          SimpleAlertForFile(GetNameOfSFReply(reply),erreurES);
          erreurES := CloseFile(exportFichier);
          exit;
        end;

      gOptionsExportBase.fic             := exportFichier;

      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierPGN,compteur);

      erreurES := CloseFile(exportFichier);

      WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));    {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;





procedure ExportListeAuFormatXOF;
var reply : SFReply;
    prompt,ligne : String255;
    whichSpec : fileInfo;
    erreurES : OSErr;
    exportFichier : basicfile;
    compteur,nbPartiesExportees : SInt64;
    myDate : DateTimeRec;
begin

  nbPartiesExportees := 0;

  prompt := ReadStringFromRessource(TextesDiversID,11); {'Nom du fichier d''export ? '}
  SetNameOfSFReply(reply, 'Export.xml');
  if MakeFileName(reply,prompt,whichSpec) then
    begin
      GetTime(myDate);

      erreurES := FileExists(whichSpec,exportFichier);
      if erreurES = fnfErr {-43 => fichier non trouvé, on le crée}
        then erreurES := CreateFile(whichSpec,exportFichier);
      if erreurES = NoErr then
        begin
          erreurES := OpenFile(exportFichier);
          erreurES := ClearFileContent(exportFichier);
        end;
      if erreurES <> NoErr then
        begin
          SimpleAlertForFile(GetNameOfSFReply(reply),erreurES);
          erreurES := CloseFile(exportFichier);
          exit;
        end;

      gOptionsExportBase.fic             := exportFichier;


      ligne :=  '<?xml version="1.0" encoding="UTF-8"?>';
      erreurES := Writeln(exportFichier,ligne);

      ligne :=  '<!DOCTYPE database SYSTEM "xof.dtd">';
      erreurES := Writeln(exportFichier,ligne);

      WritelnDansRapport('');

      ligne :=  '<database xmlns="http://www.othbase.net/xof">';
      erreurES := Writeln(exportFichier,ligne);

      ligne :=  ' <info version="1.1"'+
                   ' date="'+IntToStrWithPadding(myDate.year,4,'0')+'-'+
                             IntToStrWithPadding(myDate.month,2,'0')+'-'+
                             IntToStrWithPadding(myDate.day,2,'0')+'"'+
                   ' author="'+'Cassio '+VersionDeCassioEnString+'" />';
      erreurES := Writeln(exportFichier,ligne);

      ligne :=  ' <game-collection>';
      erreurES := Writeln(exportFichier,ligne);






      compteur := 0;
      ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierXOF,compteur);



      ligne :=  '  </game-collection>';
      erreurES := Writeln(exportFichier,ligne);

      ligne :=  '</database>';
      erreurES := Writeln(exportFichier,ligne);





      erreurES := CloseFile(exportFichier);

      WritelnDansRapport(ReplaceParameters(ReadStringFromRessource(TextesErreursID,13),IntToStr(compteur),'','',''));    {'Export : ^0 parties…'}
      nbPartiesExportees := compteur;
    end;
end;


procedure ExporterPartieDansFichierHTML(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
var erreurES : OSErr;
    s,ligne,ligneSansEspace : String255;
    nom1,nom2 : String255;
    nomFichierOutput : String255;
    fichierHTMLOutput : basicfile;
    fichierModeleHTML : basicfile;
    compteurLignes,data : SInt64;
    numero: SInt64;
begin

  if PartieEstActiveEtSelectionnee(numeroReference) then
    begin
      ShareTimeWithOtherProcesses(0);

      fichierModeleHTML := gOptionsExportBase.fic;
      erreurES := SetFilePosition(fichierModeleHTML,0);

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
                                       LeftStr(nom1,kLongueurNomsDansURL) + '-' +
                                       LeftStr(nom2,kLongueurNomsDansURL) +
                                       '.htm';

                 end
               else
                 begin
                   nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) +
                                       gOptionsExportBase.subDirectoryName +
                                       LeftStr(nom1,kLongueurNomsDansURL) + '-' +
                                       LeftStr(nom2,kLongueurNomsDansURL - LENGTH_OF_STRING(IntToStr(numero))) +
                                       IntToStr(numero) +
                                       '.htm';
                 end;
          until not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises));

          WritelnDansRapport(nomFichierOutput+'...');

          erreurES := FileExists(nomFichierOutput,0,fichierHTMLOutput);
          if erreurES = fnfErr
            then
              begin
                {-43 => fichier non trouvé, on le crée}
                erreurES := CreateFile(nomFichierOutput,0,fichierHTMLOutput);
                {WritelnDansRapport('Le fichier '+nomFichierOutput+' n''existe pas, on le crée');}
              end
            else
              begin
                if not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises)) then
                  begin
                    //WritelnDansRapport('Le fichier '+nomFichierOutput+' existe deja, on l''efface');
                    erreurES := OpenFile(fichierHTMLOutput);
                    erreurES := ClearFileContent(fichierHTMLOutput);
                    erreurES := CloseFile(fichierHTMLOutput);
                  end;
              end;
          AddStringToSet(nomFichierOutput,0,gOptionsExportBase.nomsFichiersUtilises);

          erreurES := OpenFile(fichierHTMLOutput);
          erreurES := SetFilePositionAtEnd(fichierHTMLOutput);
          gOptionsExportBase.fic := fichierHTMLOutput;

          if (erreurES = NoErr) then inc(compteur);

          while (erreurES = NoErr) and not(EndOfFile(fichierModeleHTML,erreurES)) do
            begin
              erreurES := Readln(fichierModeleHTML,s);
              ligne := s;
              ligneSansEspace := EnleveEspacesDeGauche(ligne);
              if (ligneSansEspace[1] = '%')
                then
                  begin
                    {erreurES := Writeln(outputBaseThor,s);}
                  end
                else
                  begin
                    {WritelnDansRapport(ligne);}
                    gOptionsExportBase.patternLigne   := ligne;
                    ExporterPartieDansFichierTexte(theGame,numeroReference,compteurLignes);
                  end;
            end;

          erreurES := CloseFile(fichierHTMLOutput);
        end;

      gOptionsExportBase.fic := fichierModeleHTML;

  end;
end;

procedure ExporterPartieDansFichierSOF(var theGame : PackedThorGame; numeroReference : SInt64; var compteur : SInt64);
var erreurES : OSErr;
    s : String255;
    nom1,nom2,nomPourURL : String255;
    nomFichierOutput : String255;
    fichierSOFOutput : basicfile;
    fichierModeleHTML : basicfile;
    nbPionsFinalNoirs,nbPionsFinalBlancs : SInt64;
    data, t, trait, coup : SInt64;
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
          {nom1 := ReplaceStringOnce(nom1, ' ' , '_');
          nom2 := ReplaceStringOnce(nom2, ' ' , '_');}
          (*
          for i := 1 to kLongueurNomsDansURL do
            begin
              nom1 := nom1 + ' ';
              nom2 := nom2 + ' ';
            end;*)

          nomPourURL := LeftStr(nom1,kLongueurNomsDansURL)+'-'+
                        LeftStr(nom2,kLongueurNomsDansURL)+'.sof';

          nomFichierOutput := ExtraitCheminDAcces(fichierModeleHTML.nomFichier) +
                              gOptionsExportBase.subDirectoryName +
                              nomPourURL;

          WritelnDansRapport(nomFichierOutput+'...');

          erreurES := FileExists(nomFichierOutput,0,fichierSOFOutput);
          if erreurES = fnfErr
            then
              begin
                {fnfErr = -43  =>  fichier non trouvé, on le crée}
                erreurES := CreateFile(nomFichierOutput,0,fichierSOFOutput);
                {WritelnDansRapport('Le fichier '+nomFichierOutput+' n''existe pas, on le crée');}
              end
            else
              begin
                if not(MemberOfStringSet(nomFichierOutput,data,gOptionsExportBase.nomsFichiersUtilises)) then
                  begin
                    {WritelnDansRapport('Le fichier '+nomFichierOutput+' existe deja, on l''efface');}
                    erreurES := OpenFile(fichierSOFOutput);
                    erreurES := ClearFileContent(fichierSOFOutput);
                    erreurES := CloseFile(fichierSOFOutput);
                  end;
              end;
          AddStringToSet(nomFichierOutput,0,gOptionsExportBase.nomsFichiersUtilises);

          erreurES := OpenFile(fichierSOFOutput);
          erreurES := SetFilePositionAtEnd(fichierSOFOutput);

          if (erreurES = NoErr) then inc(compteur);


          (* Writing the SGF compulsary informations *)
          s := '(;GM[2]FF[4]SZ[8]TM[1500]BL[1500]WL[1500]';
          erreurES := Write(fichierSOFOutput,s);

          (* Cassio version *)
          s := 'AP['+'Cassio:'+VersionDeCassioEnString+']';
          erreurES := Write(fichierSOFOutput,s);

          (* User *)
          s := 'US[Stephane Nicolet]';
          erreurES := Write(fichierSOFOutput,s);

          (* Copyright *)
          GetTime(myDate);
          s := 'CP[Copyleft '+IntToStr(myDate.year)+', French Federation of Othello]';
          erreurES := Write(fichierSOFOutput,s);

          (* Black player *)
          s := 'PB['+StripDiacritics(GetNomJoueurNoirParNroRefPartie(numeroReference))+']';
          erreurES := Write(fichierSOFOutput,s);

          (* White player *)
          s := 'PW['+StripDiacritics(GetNomJoueurBlancParNroRefPartie(numeroReference))+']';
          erreurES := Write(fichierSOFOutput,s);

          (* Event *)
          s := 'EV['+StripDiacritics(GetNomTournoiParNroRefPartie(numeroReference))+']';
          erreurES := Write(fichierSOFOutput,s);

          (* Year *)
          s := 'DT['+IntToStr(GetAnneePartieParNroRefPartie(numeroReference))+']';
          erreurES := Write(fichierSOFOutput,s);

          (* Score *)
          if PeutCalculerScoreFinalDeCettePartie(theGame,nbPionsFinalNoirs,nbPionsFinalBlancs,partieTerminee) and partieTerminee then
            begin
              if nbPionsFinalNoirs > nbPionsFinalBlancs then s := 'RE[B+'+IntToStr(nbPionsFinalNoirs - nbPionsFinalBlancs)+']' else
              if nbPionsFinalNoirs < nbPionsFinalBlancs then s := 'RE[B+'+IntToStr(nbPionsFinalBlancs - nbPionsFinalNoirs)+']' else
              if nbPionsFinalNoirs = nbPionsFinalBlancs then s := 'RE[0]';
              erreurES := Write(fichierSOFOutput,s);
            end;

          (* Initial position *)
          s := 'AB[e4][d5]AW[d4][e5]PL[B]';
          erreurES := Write(fichierSOFOutput,s);


          if GET_LENGTH_OF_PACKED_GAME(theGame) > 0 then
            begin
               positionEtTrait := PositionEtTraitInitiauxStandard;
               ok := true;
               for t := 1 to Min(60, GET_LENGTH_OF_PACKED_GAME(theGame)) do
        			   begin
        			     coup := GET_NTH_MOVE_OF_PACKED_GAME(theGame,t,'PeutCalculerScoreFinalDeCettePartie');
        			     trait := GetTraitOfPosition(positionEtTrait);
        			     if ok and (coup <> 0) then
          			     begin
          			       ok := (UpdatePositionEtTrait(positionEtTrait, coup));
          			       if ok then
          			         begin
          			           s := '';
          			           case trait of
            			           pionNoir  : s := ';B['+CoupEnString(coup, false)+']';
            			           pionBlanc : s := ';W['+CoupEnString(coup, false)+']';
          			           end;  {case}
          			           if (s <> '') then erreurES := Write(fichierSOFOutput,s);
          			         end;
        			       end;
        			   end;
        		 end;


          (* Terminal parenthese *)
          s := ')';
          erreurES := Writeln(fichierSOFOutput,s);

          erreurES := CloseFile(fichierSOFOutput);
        end;

      gOptionsExportBase.fic := fichierModeleHTML;

  end;
end;





procedure ExportListeAuFormatHTML;
var erreurES : OSErr;
    modeleHTML : basicfile;
    compteur : SInt64;
    prompt : String255;
begin

  BeginDialog;
  prompt := ReadStringFromRessource(TextesDiversID,13);  {Trouvez le fichier modèle HTML :}
  erreurES := GetFichierTexte(prompt,FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),modeleHTML);
  EndDialog;

  if (erreurES = NoErr) then
    with gOptionsExportBase do
      begin

        if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true);

        erreurES := OpenFile(modeleHTML);

        patternLigne            := '';
        fic                     := modeleHTML;
        nomsFichiersUtilises    := MakeEmptyStringSet;


        (* Create all the HTML files *)

        subDirectoryName := 'html';
        if subDirectoryName <> '' then
          begin
            erreurES := CreateSubDirectoryNearThisFile(modeleHTML.info,subDirectoryName);
            if erreurES <> NoErr then subDirectoryName := '';
          end;

        compteur := 0;
        ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierHTML,compteur);
        WritelnDansRapport('');
        WriteDansRapport(IntToStr(compteur) + ' HTML files created');
        if compteur > 0
          then WritelnDansRapport(' : OK')
          else WritelnDansRapport(' : this could be an ERROR ?! ');
        WritelnDansRapport('');



        (* Create all the SOF files *)

        subDirectoryName := 'sof';
        if subDirectoryName <> '' then
          begin
            erreurES := CreateSubDirectoryNearThisFile(modeleHTML.info,subDirectoryName);
            if erreurES <> NoErr then subDirectoryName := '';
          end;

        compteur := 0;
        ForEachGameInListDo(FiltrePartieEstActiveEtSelectionnee,bidFiltreGameProc,ExporterPartieDansFichierSOF,compteur);
        WritelnDansRapport('');
        WriteDansRapport(IntToStr(compteur) + ' Smart Othello Files created');
        if compteur > 0
          then WritelnDansRapport(' : OK')
          else WritelnDansRapport(' : this could be an ERROR ?! ');
        WritelnDansRapport('');

        DisposeStringSet(nomsFichiersUtilises);

        erreurES := CloseFile(modeleHTML);

      end;
end;





procedure ImporterLigneNulleBougeard(var myLongString : LongString; var theFic : basicfile; var compteur : SInt64);
var gameNodeLePlusProfond : GameTree;
    partieRec : t_PartieRecNouveauFormat;
    partieEnThor : PackedThorGame;
    nroReferencePartieAjoutee : SInt64;
    i : SInt64;
    ligne : String255;
    oldCheckDangerousEvents : boolean;
begin {$unused theFic}

  SetCassioMustCheckDangerousEvents(false, @oldCheckDangerousEvents);

  ligne := myLongString.debutLigne;

  if (ligne <> '') and (ligne[1] <> '%') then
    begin
     if EstUnePartieOthello(ligne,true)
       then
         begin


           TraductionAlphanumeriqueEnThor(ligne,partieEnThor);
           if (GET_LENGTH_OF_PACKED_GAME(partieEnThor) <= 10) or (GET_LENGTH_OF_PACKED_GAME(partieEnThor) > 60)
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
var compteurParties : SInt64;
    erreurES : OSErr;
    fichierBougeard : basicfile;
begin
  BeginDialog;
  erreurES := GetFichierTexte('',FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),FOUR_CHAR_CODE('????'),fichierBougeard);
  EndDialog;

  compteurParties := 0;
  ForEachLineInFileDo(fichierBougeard.info,ImporterLigneNulleBougeard,compteurParties);
end;


procedure EcritNomFichierNonReconnuDansRapport(var fic : basicfile);
var err : OSErr;
    nomLongDuFichier : String255;
begin
  err := ExtractFileName(fic.info, nomLongDuFichier);
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


function ImporterFichierPartieDansListe(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var err : OSErr;
    fic : basicfile;
    nomComplet : String255;
    numeroNoir,numeroBlanc : SInt64;
    numeroTournoi,anneeTournoi : SInt64;
    infos : FormatFichierRec;
    partieEnAlpha : String255;
    nomLongDuFichier : String255;
    partieRec : t_PartieRecNouveauFormat;
    nroReferencePartieAjoutee : SInt64;
    myDate : DateTimeRec;
    partieLegale,partieComplete : boolean;
    nbNoirs,nbBlancs : SInt64;
    confianceDansLesJoueurs : double;
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
      err := ExpandFileName(fs,nomComplet);

      err := FileExists(nomComplet,0,fic);

      recognized := false;

      if (err = NoErr) and TypeDeFichierEstConnu(fic,infos,err)
        then
  				begin
  				  recognized := true;

  				  WritelnDansRapport('');

  				  {
  				  WritelnNumDansRapport('infos.format = ',SInt64(infos.format));
  				  WritelnNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);
  				  WritelnStringDansRapport('infos.positionEtPartie = '+infos.positionEtPartie);
  				  }

  					if (infos.format = kTypeFichierPGN)
  					  then err := AjouterPartiesFichierPGNDansListe('name_mapping_VOG_to_WThor.txt',fic)

  					else
  					  if (infos.format = kTypeFichierSuiteDePartiePuisJoueurs) or
  					     (infos.format = kTypeFichierSuiteDeJoueursPuisPartie) or
  					     (infos.format = kTypeFichierGGFMultiple)
  					    then err := AjouterPartiesFichierDestructureDansListe(infos.format,fic)

  					else
  					  if (infos.format = kTypeFichierTHOR_PAR) and (infos.tailleOthellier = 8)
					      then err := AjouterPartiesFichierTHOR_PARDansListe(fic)

  					else
  					  if ((infos.format = kTypeFichierCassio)                or
  					      (infos.format = kTypeFichierSGF)                   or
  					      (infos.format = kTypeFichierGGF)                   or
                  (infos.format = kTypeFichierHTMLOthelloBrowser)    or
                  (infos.format = kTypeFichierTranscript)            or
                  (infos.format = kTypeFichierZebra)                 or
                  (infos.format = kTypeFichierEPS)                   or
                  (infos.format = kTypeFichierExportTexteDeZebra)    or
                  (infos.format = kTypeFichierSimplementDesCoups)    or
                  (infos.format = kTypeFichierLigneAvecJoueurEtPartie))
                  and (infos.tailleOthellier = 8)
                  then
                    begin
                      partieEstDouteuse := false;

                      partieEnAlpha := infos.positionEtPartie;
                      err := ExtractFileName(fic.info, nomLongDuFichier);

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


  		if not(recognized) and (GetName(fic.info)[1] <> '.') then {on ne veut pas les fichiers dont le nom commence par un point}
  		  EcritNomFichierNonReconnuDansRapport(fic);

   end;

  SetDoitExpliquerTrierListeSuivantUnClassement(temp);

  ImporterFichierPartieDansListe := isFolder; {on cherche recursivement}
end;


procedure ImporterToutesPartiesRepertoire;
var prompt : String255;
    whichDirectory : fileInfo;
    erreurES : OSErr;
    tick : SInt64;
begin
  prompt := ReadStringFromRessource(TextesDiversID,10); {'Choisissez un répertoire avec des parties'}
  if ChooseFolder(prompt,whichDirectory) then
    begin
      {WritelnDansRapport('*************  Entrée dans ImporterToutesPartiesRepertoire…  ******************');}
      tick := Tickcount;

      if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire) then
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
<center>semi-finals and finals</center>
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
			Othello andreg; is a registered<br> trademark of Anjar Co.
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
