UNIT UnitEntreesSortiesListe;



INTERFACE







 USES UnitDefCassio;




{modification d'une partie en memoire}
function ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32; infosDansRapport : boolean; var partieRec : t_PartieRecNouveauFormat; nroReferencePartieChangee : SInt32) : boolean;
function ChangerPartieAlphaDansLaListe(partieEnAlpha : String255; theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec : t_PartieRecNouveauFormat; nroReferencePartieChangee : SInt32) : boolean;
function ChangerPartieRecDansListe(var partieRec : t_PartieRecNouveauFormat; anneePartie : SInt16; nroReferencePartieChangee : SInt32) : boolean;
function ConfirmationEcraserPartie(nroReference,nbCoupsIdentiques : SInt32; chaineRefNouvellePartie : String255) : ActionEcraserPartie;


{ajout d'une partie en memoire}
function AjouterPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32; infosDansRapport : boolean; var partieRec : t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieAlphaDansLaListe(partieEnAlpha : String255; theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec : t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieRecDansListe(var partieRec : t_PartieRecNouveauFormat; anneePartie : SInt16; var nroReferencePartieAjoutee : SInt32) : boolean;
function AjouterPartieDansCetteDistribution(partieRec : t_PartieRecNouveauFormat; nroDistrib : SInt32; anneePartie : SInt32) : OSErr;


{un filtre de selection sur la liste}
function FiltrePartieEstActiveEtSelectionnee(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;


{export au format WTB}
function ConfirmationEcraserBase : boolean;
function SauvegardeCesPartiesDeLaListe(filtreDesParties : FiltreNumRefProc; nroPartieMin,nroPartieMax : SInt32; anneeDesParties : SInt16; fichier : FSSpec; var doitEcraserBase : boolean) : OSErr;
function SauvegardeListeCouranteAuNouveauFormat(filtreDesParties : FiltreNumRefProc) : OSErr;


{export au format TEXT}
procedure DoExporterListeDePartiesEnTexte;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, Sound, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitAccesNouveauFormat, UnitRapport, UnitScannerOthellistique, UnitUtilitaires, UnitPalette, UnitActions
    , UnitCurseur, UnitRapportImplementation, MyStrings, SNEvents, UnitServicesDialogs, UnitMoulinette, UnitEvenement, MyFileSystemUtils
    , UnitCriteres, UnitDialog, UnitScannerUtils, UnitFenetres, UnitNormalisation, UnitPackedThorGame, UnitRapportWindow, UnitFichiersTEXT
    , UnitTriListe, UnitNouveauFormat, UnitListe, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/EntreesSortiesListe.lk}
{$ENDC}


{END_USE_CLAUSE}




function ConfirmationEcraserPartie(nroReference,nbCoupsIdentiques : SInt32; chaineRefNouvellePartie : String255) : ActionEcraserPartie;
const DialogueRemplacerPartieID = 162;
      remplacerBouton = 1;
      nouvellePartieBouton = 2;
      annulerBouton = 5;
var dp : DialogPtr;
	itemHit : SInt16;
	err : OSErr;
begin
  ConfirmationEcraserPartie := ActionRemplacer;
  BeginDialog;
  dp := MyGetNewDialog(DialogueRemplacerPartieID);
  if dp <> NIL then
    begin
      err := SetDialogTracksCursor(dp,true);
      MyParamText(IntToStr(nbCoupsIdentiques),ConstruireChaineReferencesPartieParNroRefPartie(nroReference,true,-1),chaineRefNouvellePartie,'');
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);
      until (itemHit = remplacerBouton) or (itemHit = nouvellePartieBouton) or (itemHit = annulerBouton);

      case itemHit of
        remplacerBouton      : ConfirmationEcraserPartie := ActionRemplacer;
        nouvellePartieBouton : ConfirmationEcraserPartie := ActionCreerAutrePartie;
        annulerBouton        : ConfirmationEcraserPartie := ActionAnnuler;
      end; {case}

      MyDisposeDialog(dp);
      if windowPaletteOpen then DessinePalette;
      EssaieSetPortWindowPlateau;
    end;
  EndDialog;
end;


function ConfirmationEcraserBase : boolean;
const DialogueRemplacerBaseID = 151;
      remplacerBouton = 1;
      annulerBouton = 2;
var itemHit : SInt16;
begin
  ConfirmationEcraserBase := true;

  itemHit := CautionAlertTwoButtonsFromRessource(DialogueRemplacerBaseID,4,5,remplacerBouton,annulerBouton);

  ConfirmationEcraserBase := (itemHit = remplacerBouton);

end;


function SauvegardeCesPartiesDeLaListe(filtreDesParties : FiltreNumRefProc; nroPartieMin,nroPartieMax : SInt32; anneeDesParties : SInt16; fichier : FSSpec; var doitEcraserBase : boolean) : OSErr;
var enteteFichierPartie : t_EnTeteNouveauFormat;
    partieNF : t_PartieRecNouveauFormat;
    n,nroReference,bidon : SInt32;
    nbPartiesEcrites,nbPartiesRefusees : SInt32;
    codeErreur : OSErr;
    myDate : DateTimeRec;
    doitEcrireCettePartie : boolean;
    s60 : PackedThorGame;
    s255 : String255;
    nbNoirs,nbBlancs : SInt32;
    longueur : SInt16;
    terminee : boolean;
    fic : FichierTEXT;
    fileName : String255;
begin
  SauvegardeCesPartiesDeLaListe := -2;

  if (nroPartieMax < nroPartieMin) then
    exit(SauvegardeCesPartiesDeLaListe);

  fileName := GetNameOfFSSpec(fichier);
  if (fileName[LENGTH_OF_STRING(fileName)] <> ' ') and (fileName[LENGTH_OF_STRING(fileName)] <> '_')
    then fileName := Concat(fileName,' ');
  fileName := fileName + IntToStr(anneeDesParties);
  fileName := fileName+'.wtb';

  codeErreur := FichierTexteExisteFSp(MyMakeFSSpec(fichier.vRefNum,fichier.parID,fileName),fic);
  if codeErreur = NoErr
    then
      begin
        if doitEcraserBase or ConfirmationEcraserBase
		      then
		        begin
		          doitEcraserBase := true;
		          codeErreur := NoErr;
		        end
		      else
		        codeErreur := -1;
      end
    else
      if (codeErreur = fnfErr) {-43 => fichier non trouvé, on le crée}
        then codeErreur := CreeFichierTexteFSp(MyMakeFSSpec(fichier.vRefNum,fichier.parID,fileName),fic);

  if (codeErreur <> NoErr) then
    begin
      if (codeErreur <> -1)
        then WritelnNumDansRapport('Erreur dans SauvegardeCesPartiesDeLaListe : ',codeErreur);
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;

  SetFileCreatorFichierTexte(fic,MY_FOUR_CHAR_CODE('SNX4'));
  SetFileTypeFichierTexte(fic,MY_FOUR_CHAR_CODE('QWTB'));


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);

  codeErreur := OuvreFichierTexte(fic);
  if (codeErreur <> NoErr) then
    begin
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;

  codeErreur := VideFichierTexte(fic);
  if (codeErreur <> NoErr) then
    begin
      SauvegardeCesPartiesDeLaListe := codeErreur;
      exit(SauvegardeCesPartiesDeLaListe);
    end;

  WritelnDansRapport('');
  WriteDansRapport('Début de l''écriture sur le disque ');
  WriteDansRapport('(dans le fichier « '+fileName+' ») ');
  WritelnDansRapport('des parties de l''année '+IntToStr(anneeDesParties)+'…');
  {WritelnNumDansRapport('nroPartieMin = ',nroPartieMin);
  WritelnNumDansRapport('nroPartieMax = ',nroPartieMax);}

  nbPartiesEcrites := 0;
  nbPartiesRefusees := 0;
  for n := nroPartieMin to nroPartieMax do
    if codeErreur = NoErr then
      begin
        nroReference := tableNumeroReference^^[n];

        if filtreDesParties(n,nroReference,bidon) then
          begin

            partieNF := GetPartieRecordParNroRefPartie(nroReference);

            partieNF.nroJoueurNoir  := GetNroJoueurDansSonFichier(partieNF.nroJoueurNoir);
            partieNF.nroJoueurBlanc := GetNroJoueurDansSonFichier(partieNF.nroJoueurBlanc);
            partieNF.nroTournoi     := GetNroTournoiDansSonFichier(partieNF.nroTournoi);

            (* ici on modifie et on filtre les parties a écrire comme on veut... *)
            {partieNF.scoreTheorique := 255;}



            ExtraitPartieTableStockageParties(nroReference,s60);
            if PeutCalculerScoreFinalDeCettePartie(s60,nbNoirs,nbBlancs,terminee)
              then
                begin
                  if terminee
                    then
                      begin
                        doitEcrireCettePartie := PartieEstActiveEtSelectionnee(nroReference);
                        {if partieNF.scoreReel <> nbNoirs then
                          begin
                            TraductionThorEnAlphanumerique(s60,s255);
                            WritelnDansRapport('partie avec un faux score : '+s255);
                            WritelnNumDansRapport('partieNF.scoreReel = ',partieNF.scoreReel);
                            WritelnNumDansRapport('nbNoirs = ',nbNoirs);
    	                      AttendFrappeClavier;
    	                    end;}
                        partieNF.scoreReel := nbNoirs;
                        if (partieNF.scoreTheorique < 0) or (partieNF.scoreTheorique > 64)
                          then partieNF.scoreTheorique := partieNF.scoreReel;
                      end
                    else
    	                begin
    	                  TraductionThorEnAlphanumerique(s60,s255);
    	                  longueur := LENGTH_OF_STRING(s255) div 2;
    	                  doitEcrireCettePartie := (longueur > 20) and PartieEstActiveEtSelectionnee(nroReference);
    	                  {WritelnDansRapport('partie non terminée : '+s255);
    	                  WritelnNumDansRapport('longueur = ',longueur);
    	                  WritelnNumDansRapport('partieNF.scoreReel = ',partieNF.scoreReel);
    	                  WritelnNumDansRapport('partieNF.scoreTheorique = ',partieNF.scoreTheorique);
    	                  WritelnNumDansRapport('nbNoirs = ',nbNoirs);
    	                  AttendFrappeClavier;}
    	                end;
                end
              else
                begin
                  doitEcrireCettePartie := false;
                  TraductionThorEnAlphanumerique(s60,s255);
                  WritelnDansRapport('partie illégale : '+s255);
                  AttendFrappeClavier;
                end;


            if doitEcrireCettePartie
              then
    	        begin
    	          inc(nbPartiesEcrites);
    	          SetPartieDansListeDoitEtreSauvegardee(nroReference,false);
    	          codeErreur := EcritPartieNouveauFormat(fic.refNum,nbPartiesEcrites,partieNF);
    	          if (nbPartiesEcrites mod 500) = 0 then
    	            begin
    	              WriteNumDansRapport('Ecrites = ',nbPartiesEcrites);
    	              WritelnNumDansRapport(' ,  refusées = ',nbPartiesRefusees);
    	            end;
    	        end
    	      else
    	        begin
    	          inc(nbPartiesRefusees);
    	        end;
          end; {if filtreDesParties(nroReference,bidon) then ...}
      end; {boucle for n := ...}

  WriteNumDansRapport('Pour l''année ',anneeDesParties);
  WriteNumDansRapport(', on a écrit ',nbPartiesEcrites);
  if (nbPartiesEcrites >= 2)
    then WriteDansRapport(' parties')
    else WriteDansRapport(' partie');
  if (nbPartiesRefusees > 0) then
    begin
      WriteNumDansRapport(' et refusé ',nbPartiesRefusees);
      if (nbPartiesRefusees >= 2)
        then WriteDansRapport(' parties')
        else WriteDansRapport(' partie');
    end;
  WritelnDansRapport('.');

  GetTime(myDate);
  with enteteFichierPartie do
    begin
      SiecleCreation                         := myDate.year div 100;
      AnneeCreation                          := myDate.year mod 100;
      MoisCreation                           := myDate.month;
      JourCreation                           := myDate.day;
      NombreEnregistrementsParties           := nbPartiesEcrites;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties                           := anneeDesParties;
      TailleDuPlateau                        := 8;   {taille du plateau de jeu}
      EstUnFichierSolitaire                  := 0;   {1 = solitaires, 0 = autres cas}
      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
      reservedByte                           := 0;
    end;
  codeErreur := EcritEnteteNouveauFormat(fic.refNum,enteteFichierPartie);


  codeErreur := FermeFichierTexte(fic);
  SauvegardeCesPartiesDeLaListe := codeErreur;

  RemettreLeCurseurNormalDeCassio;
end;


function FiltrePartieEstActiveEtSelectionnee(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;
begin {$unused numeroDansLaListe,result}
  FiltrePartieEstActiveEtSelectionnee := PartieEstActiveEtSelectionnee(numeroReference);
end;


function SauvegardeListeCouranteAuNouveauFormat(filtreDesParties : FiltreNumRefProc) : OSErr;
var codeErreur : OSErr;
    reply : SFReply;
    fichier : FSSpec;
    prompt,s : String255;
    nroPartieDansListe,nroReference : SInt32;
    nroPremierePartieDeLAnnee : SInt32;
    nroDernierePartieDeLAnnee : SInt32;
    anneeCourante,anneePartieSuivante : SInt16;
    doitEcraserAncienneBase : boolean;
    sortieDeBoucle : boolean;
    compteurPartiesDansAnneeCourante : SInt32;
    bidon : SInt32;
begin
  if not(windowListeOpen) or (nbPartiesActives <= 0) then
    begin
      SauvegardeListeCouranteAuNouveauFormat := NoErr;
      exit(SauvegardeListeCouranteAuNouveauFormat);
    end;

  BeginDialog;
  s := ReadStringFromRessource(TextesDiversID,2);      {'sans titre'}
  SetNameOfSFReply(reply, s);
  prompt := ReadStringFromRessource(TextesNouveauFormatID,3); {'nom de la base à créer ?'}
  if MakeFileName(reply,prompt,fichier) then DoNothing;
  EndDialog;

  if not(reply.good) then  {annulation}
    begin
      SauvegardeListeCouranteAuNouveauFormat := NoErr;
      exit(SauvegardeListeCouranteAuNouveauFormat);
    end;

  SauvegardeListeCouranteAuNouveauFormat := -1;
  doitEcraserAncienneBase := false;
  DoTrierListe(TriParDate,kRadixSort);

  if reply.good then
    begin
      codeErreur := 0;
      nroPartieDansListe := 1;
      nroDernierePartieDeLAnnee := 0;
      REPEAT

        watch := GetCursor(watchcursor);
        SafeSetCursor(watch);

        nroPremierePartieDeLannee := nroPartieDansListe;
        nroReference := tableNumeroReference^^[nroPremierePartieDeLannee];
        anneeCourante := GetAnneePartieParNroRefPartie(nroReference);

        {WritelnDansRapport('**********  entree dans SauvegardeListeCouranteAuNouveauFormat  *************');
        WritelnNumDansRapport('AVANT, nbPartiesActives = ',nbPartiesActives);
        WritelnNumDansRapport('AVANT, nroPremierePartieDeLannee = ',nroPremierePartieDeLannee);
        WritelnNumDansRapport('AVANT, nroDernierePartieDeLAnnee = ',nroDernierePartieDeLAnnee);
        WritelnNumDansRapport('AVANT, anneeCourante = ',anneeCourante);}

        compteurPartiesDansAnneeCourante := 0;
        sortieDeBoucle := false;
        repeat
          if (nroPartieDansListe <= nbPartiesActives) then
            begin
              nroReference := tableNumeroReference^^[nroPartieDansListe];
              if filtreDesParties(nroPartieDansListe,nroReference,bidon) then inc(compteurPartiesDansAnneeCourante);

              if (nroPartieDansListe >= nbPartiesActives)
                then
                  begin
                    sortieDeBoucle := true;
                    nroDernierePartieDeLAnnee := nbPartiesActives;
                  end
                else
                  begin
                    inc(nroPartieDansListe);
                    nroReference := tableNumeroReference^^[nroPartieDansListe];
                    anneePartieSuivante := GetAnneePartieParNroRefPartie(nroReference);

                    if (anneePartieSuivante <> anneeCourante) then
                      begin
                        sortieDeBoucle := true;
                        nroDernierePartieDeLAnnee := nroPartieDansListe - 1;
                      end;
                  end;
            end;
        until sortieDeBoucle or (nbPartiesActives <= 0);

        if nroDernierePartieDeLAnnee < nroPremierePartieDeLannee then nroDernierePartieDeLAnnee := nroPremierePartieDeLannee;
        if nroDernierePartieDeLAnnee > nbPartiesActives          then nroDernierePartieDeLAnnee := nbPartiesActives;

        {WritelnNumDansRapport('apres, anneePartieSuivante = ',anneePartieSuivante);
        WritelnNumDansRapport('apres, compteurPartiesDansAnneeCourante = ',compteurPartiesDansAnneeCourante);
        WritelnNumDansRapport('apres, nroPremierePartieDeLannee = ',nroPremierePartieDeLannee);
        WritelnNumDansRapport('apres, nroDernierePartieDeLAnnee = ',nroDernierePartieDeLAnnee);}


        if (compteurPartiesDansAnneeCourante > 0)
          then codeErreur := SauvegardeCesPartiesDeLaListe(filtreDesParties,nroPremierePartieDeLAnnee,nroDernierePartieDeLAnnee,
                                                           anneeCourante,fichier,doitEcraserAncienneBase);

        {if codeErreur <> 0 then
          begin
		        WritelnDansRapport('WARNING (codeErreur <> 0) dans SauvegardeListeCouranteAuNouveauFormat…');
		        WritelnNumDansRapport('    anneeCourante = ',anneeCourante);
		        WritelnNumDansRapport('    codeErreur = ',codeErreur);
          end;}

      UNTIL (nbPartiesActives <= 0) or (nroDernierePartieDeLAnnee >= nbPartiesActives) or (codeErreur <> 0);

      if (codeErreur = -1)
        then SauvegardeListeCouranteAuNouveauFormat := NoErr      {cela voulait dire que l'utilisateur a refusé d'écraser une base déjà existante}
        else SauvegardeListeCouranteAuNouveauFormat := codeErreur;

    end;

  CalculsEtAffichagePourBase(true,true);
  RemettreLeCurseurNormalDeCassio;
end;


function ChangerPartieRecDansListe(var partieRec : t_PartieRecNouveauFormat; anneePartie : SInt16; nroReferencePartieChangee : SInt32) : boolean;
var partie60 : PackedThorGame;
    partie255 : String255;
    partie120 : String255;
    autreCoupDiag : boolean;
    partieSansOrdinateur : boolean;
    i,t : SInt32;
    err : OSErr;
begin

  ChangerPartieRecDansListe := false;

  if (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) then
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieRecDansListe, prévenez Stéphane');
      exit(ChangerPartieRecDansListe);
    end;

  FILL_PACKED_GAME_WITH_ZEROS(partie60);
  for i := 1 to 60 do
    begin
      t := partieRec.listeCoups[i];
      if (t >= 11) and (t <= 88) then
        ADD_MOVE_TO_PACKED_GAME(partie60, t);
    end;
  TraductionThorEnAlphanumerique(partie60,partie255);

  if not(EstUnePartieOthello(partie255,true)) then
    begin
      WritelnDansRapport('partie illégale dans ChangerPartieRecDansListe !! '+partie255);
      exit(ChangerPartieRecDansListe);
    end;


  partie120 := partie255;
  Normalisation(partie120,autreCoupDiag,false);
  partie120 := NormaliserLaPartiePourInclusionDansLaBaseWThor(partie120);
  TraductionAlphanumeriqueEnThor(partie120,partie60);
  for i := 1 to GET_LENGTH_OF_PACKED_GAME(partie60) do
    partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partie60, i,'ChangerPartieRecDansListe');
  for i := GET_LENGTH_OF_PACKED_GAME(partie60)+1 to 60 do
    partieRec.listeCoups[i] := 0;

  if (InfosFichiersNouveauFormat.nbFichiers <= 0) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
      LecturePreparatoireDossierDatabase(pathCassioFolder,'ChangerPartieRecDansListe');
      if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire) then
        err := MetJoueursEtTournoisEnMemoire(false);
      RemettreLeCurseurNormalDeCassio;
    end;


  if (nroReferencePartieChangee >= 0) and (nroReferencePartieChangee <= nbrePartiesEnMemoire) then
    begin

      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : nroReferencePartieChangee = ',nroReferencePartieChangee);AttendFrappeClavier;}

      SetAnneePartieParNroRefPartie(nroReferencePartieChangee,anneePartie);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetAnneePartieParNroRefPartie ',0);
      AttendFrappeClavier;}

      SetPartieRecordParNroRefPartie(nroReferencePartieChangee,partieRec);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieRecordParNroRefPartie ',0);
      AttendFrappeClavier;}

      SetNroDistributionParNroRefPartie(nroReferencePartieChangee,0);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetNroDistributionParNroRefPartie ',0);
      AttendFrappeClavier;}

      SetPartieActive(nroReferencePartieChangee,true);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieActive ',0);
      AttendFrappeClavier;}

      partieSansOrdinateur := not(GetJoueurEstUnOrdinateur(GetNroJoueurNoirParNroRefPartie(nroReferencePartieChangee))) and
                              not(GetJoueurEstUnOrdinateur(GetNroJoueurBlancParNroRefPartie(nroReferencePartieChangee)));
      SetPartieEstSansOrdinateur(nroReferencePartieChangee,true);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieEstSansOrdinateur ',0);
      AttendFrappeClavier;}

      SetPartieDetruite(nroReferencePartieChangee,false);
      SetPartieDansListeDoitEtreSauvegardee(nroReferencePartieChangee,true);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres SetPartieDetruite ',0);
      AttendFrappeClavier;}

      TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres TrierListePartie ',0);
      AttendFrappeClavier;}

      LaveTableCriteres;
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres LaveTableCriteres ',0);
      AttendFrappeClavier;}

      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie ',0);
      AttendFrappeClavier;}

      if not(InclurePartiesAvecOrdinateursDansListe) then SetInclurePartiesAvecOrdinateursDansListe(true);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres DoChangeSousSelectionActive ',0);
      AttendFrappeClavier;}

      if sousSelectionActive then CalculTableCriteres;
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres CalculTableCriteres ',0);
      AttendFrappeClavier;}

      CalculsEtAffichagePourBase(false,false);
      {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres CalculsEtAffichagePourBase ',0);
      AttendFrappeClavier;}

      if sousSelectionActive and not(PartieEstCompatibleParCriteres(nroReferencePartieChangee)) then
        begin

          DoChangeSousSelectionActive;
          {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres DoChangeSousSelectionActive ',0);
          AttendFrappeClavier;}

          LaveTableCriteres;
          {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres LaveTableCriteres ',0);
          AttendFrappeClavier;}

          InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
          {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie ',0);
          AttendFrappeClavier;}

          CalculsEtAffichagePourBase(false,false);
          {WritelnNumDansRapport('dans ChangerPartieRecDansListe : apres CalculsEtAffichagePourBase ',0);
          AttendFrappeClavier;}

        end;


      ChangerPartieRecDansListe := true;
    end;
end;


function ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32; infosDansRapport : boolean; var partieRec : t_PartieRecNouveauFormat; nroReferencePartieChangee : SInt32) : boolean;
var partie60 : PackedThorGame;
    partie255,s : String255;
    autreCoupQuatreDiag : boolean;
    i,nbPionsNoirs : SInt32;
    result : boolean;
begin
  result := false;

  if (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) then
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieCouranteDansListe, prévenez Stéphane');
      exit(ChangerPartieCouranteDansListe);
    end;

  if gameOver then
    begin
      partie255 := PartieNormalisee(autreCoupQuatreDiag,false);
      TraductionAlphanumeriqueEnThor(partie255,partie60);

      if nbreDePions[pionNoir] > nbreDePions[pionBlanc] then nbPionsNoirs := 64 - nbreDePions[pionBlanc] else
			if nbreDePions[pionNoir] = nbreDePions[pionBlanc] then nbPionsNoirs := 32 else
			if nbreDePions[pionNoir] < nbreDePions[pionBlanc] then nbPionsNoirs := nbreDePions[pionNoir];

      if infosDansRapport then
        begin
				  ConstruitTitrePartie(GetNomJoueur(nroNoir),GetNomJoueur(nroBlanc),false,nbPionsNoirs,s);
          WritelnDansRapport('');
          WritelnDansRapport(partie255);
          WriteDansRapport(s + ', ');
				  WritelnDansRapport(EnleveEspacesDeDroite(GetNomTournoi(nroDuTournoi))+' '+IntToStr(annee));
        end;

      with partieRec do
        begin
          nroTournoi     := nroDuTournoi;
          nroJoueurNoir  := nroNoir;
          nroJoueurBlanc := nroBlanc;
          scoreReel      := nbPionsNoirs;
          scoreTheorique := scoreReel;
          for i := 1 to GET_LENGTH_OF_PACKED_GAME(partie60) do
            listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partie60, i,'ChangerPartieCouranteDansListe');
          for i := GET_LENGTH_OF_PACKED_GAME(partie60)+1 to 60 do
            listeCoups[i] := 0;
        end;

	    result := ChangerPartieRecDansListe(partieRec,annee,nroReferencePartieChangee);
    end;

  ChangerPartieCouranteDansListe := result;
end;


function ChangerPartieAlphaDansLaListe(partieEnAlpha : String255; theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec : t_PartieRecNouveauFormat; nroReferencePartieChangee : SInt32) : boolean;
var partie120 : String255;
    autreCoupQuatreDiag : boolean;
    partieEnThor : PackedThorGame;
    scoreNoir,scoreBlanc : SInt32;
    partieEstComplete : boolean;
    i,score : SInt32;
    result : boolean;
begin
  result := false;

  if (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) then
    begin
      Sysbeep(0);
      WritelnDansRapport('WARNING !!! (nroReferencePartieChangee < 0) or (nroReferencePartieChangee > nbrePartiesEnMemoire) dans ChangerPartieAlphaDansLaListe, prévenez Stéphane');
      exit(ChangerPartieAlphaDansLaListe);
    end;

  if EstUnePartieOthelloAvecMiroir(partieEnAlpha) then
    begin

      partie120 := partieEnAlpha;
      Normalisation(partie120,autreCoupQuatreDiag,false);
      partieEnAlpha := partie120;
      TraductionAlphanumeriqueEnThor(PartieEnAlpha,partieEnThor);

      if PeutCalculerScoreFinalDeCettePartie(partieEnThor,scoreNoir,scoreBlanc,partieEstComplete)
        then score := scoreNoir
        else score := 32;  {on force une nulle si la partie est illegale}


      partieRec.nroTournoi     := numeroTournoi;
      partieRec.nroJoueurNoir  := numeroNoir;
      partieRec.nroJoueurBlanc := numeroBlanc;
      partieRec.scoreReel      := score;

      if (theorique >= 0) and (theorique <= 64)
        then partieRec.scoreTheorique := theorique
        else partieRec.scoreTheorique := score;



      for i := 1 to GET_LENGTH_OF_PACKED_GAME(partieEnThor) do
        partieRec.listeCoups[i] := GET_NTH_MOVE_OF_PACKED_GAME(partieEnThor, i,'ChangerPartieAlphaDansLaListe');
      for i := (GET_LENGTH_OF_PACKED_GAME(partieEnThor) + 1) to 60 do
        partieRec.listeCoups[i] := 0;

      result := ChangerPartieRecDansListe(partieRec,annee,nroReferencePartieChangee);
    end;

  ChangerPartieAlphaDansLaListe := result;
end;



function AjouterPartieRecDansListe(var partieRec : t_PartieRecNouveauFormat; anneePartie : SInt16; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  AjouterPartieRecDansListe := false;

  if (nbPartiesChargees >= nbrePartiesEnMemoire) and (nbPartiesChargees > 0) and (NbPartiesDevantEtreSaugardeesDansLaListe <= 0)
    then ResetListeDeParties;

  if (nbPartiesChargees < nbrePartiesEnMemoire)
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee   := nbPartiesChargees;

        if ChangerPartieRecDansListe(partieRec,anneePartie,nroReferencePartieAjoutee)
          then AjouterPartieRecDansListe := true
          else dec(nbPartiesChargees);
      end
    else
      begin
        nroReferencePartieAjoutee   := -1;
        AjouterPartieRecDansListe   := false;
      end;
end;


function AjouterPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee : SInt32; infosDansRapport : boolean; var partieRec : t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  AjouterPartieCouranteDansListe := false;

  if (nbPartiesChargees >= nbrePartiesEnMemoire) and (nbPartiesChargees > 0) and (NbPartiesDevantEtreSaugardeesDansLaListe <= 0)
    then ResetListeDeParties;

  if (nbPartiesChargees < nbrePartiesEnMemoire)
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee      := nbPartiesChargees;

        if ChangerPartieCouranteDansListe(nroNoir,nroBlanc,nroDuTournoi,annee,infosDansRapport,partieRec,nroReferencePartieAjoutee)
          then AjouterPartieCouranteDansListe := true
          else dec(nbPartiesChargees);
      end
    else
      begin
        nroReferencePartieAjoutee      := -1;
        AjouterPartieCouranteDansListe := false;
      end;
end;


function AjouterPartieAlphaDansLaListe(partieEnAlpha : String255; theorique,numeroNoir,numeroBlanc,numeroTournoi,annee : SInt32; var partieRec : t_PartieRecNouveauFormat; var nroReferencePartieAjoutee : SInt32) : boolean;
begin
  AjouterPartieAlphaDansLaListe := false;

  if (nbPartiesChargees >= nbrePartiesEnMemoire) and (nbPartiesChargees > 0) and (NbPartiesDevantEtreSaugardeesDansLaListe <= 0)
    then ResetListeDeParties;

  if (nbPartiesChargees < nbrePartiesEnMemoire)
    then
      begin
        inc(nbPartiesChargees);
        nroReferencePartieAjoutee      := nbPartiesChargees;

        if ChangerPartieAlphaDansLaListe(partieEnAlpha,theorique,numeroNoir,numeroBlanc,numeroTournoi,annee,partieRec,nroReferencePartieAjoutee)
          then AjouterPartieAlphaDansLaListe := true
          else dec(nbPartiesChargees);
      end
    else
      begin

        AlerteSimple('WARNING !!! Plus de mémoire dans AjouterPartieAlphaDansLaListe, prévenez Stéphane');
        WritelnDansRapport('WARNING !!! Plus de mémoire dans AjouterPartieAlphaDansLaListe, prévenez Stéphane');

        nroReferencePartieAjoutee      := -1;
        AjouterPartieAlphaDansLaListe  := false;
      end;
end;


function AjouterPartieDansCetteDistribution(partieRec : t_PartieRecNouveauFormat; nroDistrib : SInt32; anneePartie : SInt32) : OSErr;
var numFichier,k : SInt32;
    enteteFichierPartie : t_EnTeteNouveauFormat;
    fic : FichierTEXT;
    codeErreur : OSErr;
    filename : String255;
    myDate : DateTimeRec;
begin

  codeErreur := -1;

  LecturePreparatoireDossierDatabase(pathCassioFolder,'AjouterPartieDansCetteDistribution');

  {WritelnNumDansRapport('numero de distribution = ',nroDistrib);}

  if (nroDistrib >= 1) and (nroDistrib <= DistributionsNouveauFormat.nbDistributions) and
     EstUneDistributionDeParties(nroDistrib) then
    begin

      { Désormais on sait que nroDistrib est un numero de distribution valide }
      {WritelnNumDansRapport('numero de distribution valide = ',nroDistrib);}

		  { On cherche un fichier de la bonne distribution et de l'année voulue parmi tous les fichiers de la base}
		  numFichier := -1;
		  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
		    if (InfosFichiersNouveauFormat.fichiers[k].typeDonnees = kFicPartiesNouveauFormat) and
		       (InfosFichiersNouveauFormat.fichiers[k].nroDistribution = nroDistrib) and
		       (AnneePartiesFichierNouveauFormat(k) = anneePartie) then
		     numFichier := k; {trouvé}


		  if (numFichier <= 0)
		    then { Si l'annee est non trouvee, on crée un nouveau fichier dans la distribution}
			    begin

			      GetTime(myDate);
					  with enteteFichierPartie do
					    begin
					      SiecleCreation                         := myDate.year div 100;
					      AnneeCreation                          := myDate.year mod 100;
					      MoisCreation                           := myDate.month;
					      JourCreation                           := myDate.day;
					      NombreEnregistrementsParties           := 0;
					      NombreEnregistrementsTournoisEtJoueurs := 0;
					      AnneeParties                           := anneePartie;
					      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
					      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
					      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
					      reservedByte                           := 0;
					    end;

			      {WritelnDansRapport('Je dois creer un nouveau fichier dans la distribution !');}

			      filename := ReplaceStringOnce('XXXX',IntToStr(anneePartie),GetNameOfDistribution(nroDistrib));
			      filename := GetPathOfDistribution(nroDistrib)+filename;
			      {WritelnDansRapport('filename = '+filename);}

			      codeErreur := CreeFichierTexte(filename,0,fic);
			      {WritelnNumDansRapport('Après CreeFichierTexte(filename,0,fic), codeErreur = ',codeErreur);}

			      if (codeErreur = NoErr) then codeErreur := OuvreFichierTexte(fic);
			      {WritelnNumDansRapport('Après OuvreFichierTexte, codeErreur = ',codeErreur);}

			      if (codeErreur = NoErr) then codeErreur := EcritEnteteNouveauFormat(fic.refnum,enteteFichierPartie);
			      {WritelnNumDansRapport('Après EcritEnteteNouveauFormat, codeErreur = ',codeErreur);}

			      if (codeErreur = NoErr) and AjouterFichierNouveauFormat(fic.theFSSpec,GetPathOfDistribution(nroDistrib),kFicPartiesNouveauFormat,enteteFichierPartie)
			        then numFichier := InfosFichiersNouveauFormat.nbFichiers;
			      {WritelnNumDansRapport('Après AjouterFichierNouveauFormat, numFichier = ',numFichier);}

			      if (codeErreur = NoErr) then codeErreur := FermeFichierTexte(fic);
			      {WritelnNumDansRapport('Après FermeFichierTexte, codeErreur = ',codeErreur);}

			      SetFileCreatorFichierTexte(fic,MY_FOUR_CHAR_CODE('SNX4'));
		        SetFileTypeFichierTexte(fic,MY_FOUR_CHAR_CODE('QWTB'));


			    end
			  else { sinon on se contente de lire l'entete du fichier}
			    begin
			      enteteFichierPartie := InfosFichiersNouveauFormat.fichiers[numFichier].entete;
			      codeErreur := NoErr;
			    end;

			if (codeErreur = NoErr) and (numFichier >= 1) and (nroDistrib >= 1) then
			  begin

			    {WritelnNumDansRapport('Tout a l''air bon, j''ajoute une partie au fichier numéro ',numFichier);}


			    GetTime(myDate);
				  with enteteFichierPartie do
				    begin
				      SiecleCreation                         := myDate.year div 100;
				      AnneeCreation                          := myDate.year mod 100;
				      MoisCreation                           := myDate.month;
				      JourCreation                           := myDate.day;
				      NombreEnregistrementsParties           := succ(NombreEnregistrementsParties);
				      NombreEnregistrementsTournoisEtJoueurs := 0;
				      AnneeParties                           := anneePartie;
				      TailleDuPlateau                        := 8;  {taille du plateau de jeu}
				      EstUnFichierSolitaire                  := 0;  {1 = solitaires, 0 = autres cas}
				      ProfondeurCalculTheorique              := 24;  {profondeur de calcul du score theorique}
				      reservedByte                           := 0;
				    end;

				  codeErreur := OuvreFichierNouveauFormat(numFichier);
				  if (codeErreur = NoErr) then codeErreur := EcritPartieNouveauFormat(InfosFichiersNouveauFormat.fichiers[numFichier].refNum,enteteFichierPartie.nombreEnregistrementsParties,partieRec);
				  if (codeErreur = NoErr) then codeErreur := EcritEnteteNouveauFormat(InfosFichiersNouveauFormat.fichiers[numFichier].refNum,enteteFichierPartie);
		      if (codeErreur = NoErr) then codeErreur := FermeFichierNouveauFormat(numFichier);

		      if (codeErreur = NoErr) then
		        begin
					    with InfosFichiersNouveauFormat.fichiers[numFichier] do
					      begin
					        Annee           := anneePartie;
					        NroDistribution := nroDistrib;
					        entete          := enteteFichierPartie;
					      end;
					  end;
			  end;
    end;

  AjouterPartieDansCetteDistribution := codeErreur;
end;




procedure DoExporterListeDePartiesEnTexte;
var descriptionLigne : String255;
    longueurSelection : SInt32;
    nbPartiesExportees : SInt32;
begin
  if FenetreRapportEstOuverte and
     FenetreRapportEstAuPremierPlan and
     SelectionRapportNonVide
     then
      begin
        if (LongueurSelectionRapport < 255) then
          begin
            longueurSelection := 0;
            descriptionLigne := SelectionRapportEnString(longueurSelection);

            ExportListeAuFormatTexte(descriptionLigne,nbPartiesExportees);

            WritelnDansRapport('');
            WritelnDansRapport(' Export de la base : '+IntToStr(nbPartiesExportees)+' parties écrites dans le fichier');
          end;
      end
    else
      begin
        if not(FenetreRapportEstOuverte) or not(FenetreRapportEstAuPremierPlan)
          then DoRapport;
        WritelnDansRapport('Pour exporter les parties de la liste dans un fichier texte, voici comment procéder :');
        WritelnDansRapport('  1) passer en mode "Traitement de texte" (pomme-option-T)');
        WritelnDansRapport('  2) définir la syntaxe de chaque ligne en la tapant dans le rapport');
        WritelnDansRapport('  3) sélectionner la syntaxe dans le rapport avec la souris');
        WritelnDansRapport('  4) choisir l''option "Enregistrer les parties de la liste -> format texte" dans le menu Base');
        WritelnDansRapport('');
        WritelnDansRapport('Utilisez les variables suivantes pour définir l''export : ');
        WritelnDansRapport('');
        WritelnDansRapport('   $CASSIO_GAME           :  coups de la partie');
        WritelnDansRapport('   $CASSIO_BASE           :  nom de la base');
        WritelnDansRapport('   $CASSIO_TOURN          :  nom du tournoi');
        WritelnDansRapport('   $CASSIO_TOURN_SHORT    :  nom court du tournoi');
        WritelnDansRapport('   $CASSIO_TOURN_JAPANESE :  nom du tournoi, en japonais si possible');
        WritelnDansRapport('   $CASSIO_TOURN_NUMBER   :  numéro du tournoi');
        WritelnDansRapport('   $CASSIO_YEAR           :  année');
        WritelnDansRapport('   $CASSIO_BLACK          :  nom du joueur Noir');
        WritelnDansRapport('   $CASSIO_BLACK_SHORT    :  nom court du joueur Noir');
        WritelnDansRapport('   $CASSIO_BLACK_JAPANESE :  nom du joueur Noir, en japonais si possible');
        WritelnDansRapport('   $CASSIO_BLACK_NUMBER   :  numéro WThor du joueur Noir');
        WritelnDansRapport('   $CASSIO_BLACK_FFO      :  numéro FFO du joueur Noir');
        WritelnDansRapport('   $CASSIO_WHITE          :  nom du joueur Blanc');
        WritelnDansRapport('   $CASSIO_WHITE_SHORT    :  nom court du joueur Blanc');
        WritelnDansRapport('   $CASSIO_WHITE_JAPANESE :  nom du joueur Blanc, en japonais si possible');
        WritelnDansRapport('   $CASSIO_WHITE_NUMBER   :  numéro Wthor du joueur Blanc');
        WritelnDansRapport('   $CASSIO_WHITE_FFO      :  numéro FFO du joueur Blanc');
        WritelnDansRapport('   $CASSIO_SCORE_BLACK    :  score de Noir dans la partie');
        WritelnDansRapport('   $CASSIO_SCORE_WHITE    :  score de Blanc dans la partie');
        WritelnDansRapport('   $CASSIO_THEOR_BLACK    :  score théorique de Noir');
        WritelnDansRapport('   $CASSIO_THEOR_WHITE    :  score théorique de Blanc');
        WritelnDansRapport('   $CASSIO_THEOR_WINNER   :  gagnant théorique (N/B/E)');
        WritelnDansRapport('   $CASSIO_GAME_ID        :  un compteur de partie');
        WritelnDansRapport('   $CASSIO_THOR_MOVES     :  coups de la partie au format WThor');
        WritelnDansRapport('   $CASSIO_SWEDISH_MOVES  :  coups de la partie au format MySQL pour reversi.se');

        WritelnDansRapport('');
        WritelnDansRapport('   Pour exporter des variables tronquées, utiliser la syntaxe $CASSIO_GAME[1..30] à la place de $CASSIO_GAME');
        WritelnDansRapport('   On peut aussi échapper le caractère $ avec \$, et \ avec \\');
        WritelnDansRapport('');
        WritelnDansRapport('Quelques exemples : ');
        WritelnDansRapport('');
        WritelnDansRapport(' $CASSIO_GAME ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_BLACK - $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_BLACK $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : ($CASSIO_TOURN $CASSIO_YEAR) $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : $CASSIO_BLACK - $CASSIO_WHITE ');
        WritelnDansRapport(' $CASSIO_GAME : $CASSIO_BLACK $CASSIO_SCORE_BLACK-$CASSIO_SCORE_WHITE $CASSIO_WHITE ');
        WritelnDansRapport(' INSERT INTO `thor_db` VALUES ($CASSIO_TOURN_NUMBER, $CASSIO_BLACK_NUMBER, $CASSIO_WHITE_NUMBER, $CASSIO_SCORE_BLACK, $CASSIO_THEOR_BLACK, ''$CASSIO_SWEDISH_MOVES'', $CASSIO_YEAR, $CASSIO_GAME_ID);');


      end;
end;

end.
