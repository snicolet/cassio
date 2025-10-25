UNIT UnitTHOR_PAR;


INTERFACE







 USES UnitDefCassio;




{lecture et ecriture sur le disque}
function EcritPartieFormatTHOR_PAR(var fichierTHOR_PAR : FichierTEXT; numeroPartieDansFichier : SInt32; partieNF : t_PartieRecNouveauFormat) : OSErr;
function EcritPartieVideDansFichierTHOR_PAR(var fichierTHOR_PAR : FichierTEXT; numeroPartieDansFichier : SInt32) : OSErr;
function LitEnregistrementDansFichierThorPar(var fic : FichierTEXT; numero : SInt32; var enregistrement : ThorParRec) : OSErr;


{fonctions de transfert avec la liste de parties}
function AjouterPartiesFichierTHOR_PARDansListe(var fichierTHOR_PAR : FichierTEXT) : OSErr;
function SauvegardeListeCouranteEnTHOR_PAR : OSErr;
function SauvegardeCesPartiesDeLaListeEnTHOR_PAR(nroPartieMin,nroPartieMax : SInt32; var nbPartiesEcrites : SInt32; var fichierTHOR_PAR : FichierTEXT) : OSErr;


{fonction d'acces}
function TailleDuFichierTHOR_PAR : SInt32;
function GetCommentOfThorParRec(const enregistrement : ThorParRec) : String255;
function GetPartieEnAlphaOfThorParRec(const enregistrement : ThorParRec) : String255;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitScannerUtils, UnitAccesNouveauFormat, UnitUtilitaires, UnitCurseur, UnitServicesDialogs
    , UnitCriteres, UnitFichiersTEXT, UnitDialog, UnitBaseNouveauFormat, UnitTriListe, UnitListe, UnitRapport, MyStrings
    , UnitEntreeTranscript, UnitImportDesNoms, UnitEntreesSortiesListe, UnitRapportImplementation, UnitPackedThorGame, MyMathUtils, UnitScannerOthellistique, UnitRapportUtils
    , UnitPositionEtTrait, MyFileSystemUtils, UnitServicesMemoire ;
{$ELSEC}
    ;
    {$I prelink/THOR_PAR.lk}
{$ENDC}


{END_USE_CLAUSE}











const TailleEnregistrementTHOR_PAR  = 112;
      nbPlagesDansTHOR_PAR          = 25;
      nbPartiesParPlageDansTHOR_PAR = 20;

      kNoirTHOR_PAR = chr(253);
      kBlancTHOR_PAR = chr(252);


function TailleDuFichierTHOR_PAR : SInt32;
var result : SInt32;
begin
  result := TailleEnregistrementTHOR_PAR;
  result := result * nbPlagesDansTHOR_PAR * nbPartiesParPlageDansTHOR_PAR;
  TailleDuFichierTHOR_PAR := result;
end;


function LitEnregistrementDansFichierThorPar(var fic : FichierTEXT; numero : SInt32; var enregistrement : ThorParRec) : OSErr;
var count : SInt32;
    err : OSErr;
begin
  MemoryFillChar(@enregistrement,TailleEnregistrementTHOR_PAR,chr(0));
  err := SetPositionTeteLectureFichierTexte(fic,(numero-1)*TailleEnregistrementTHOR_PAR);
  count := TailleEnregistrementTHOR_PAR;
  err := ReadBufferDansFichierTexte(fic,@enregistrement,count);
  LitEnregistrementDansFichierThorPar := err;
end;

function GetCommentOfThorParRec(const enregistrement : ThorParRec) : String255;
var s : String255;
    i : SInt32;
begin
  s := '';

  with enregistrement do
    for i := 1 to 36 do
      if ord(texte[i]) > 0
        then s := s + texte[i]
        else leave;

  s := EnleveEspacesDeGauche(s);
  s := ReplaceStringByStringInString('Ç','é',s);
  s := ReplaceStringByStringInString('Ç','é',s);
  s := ReplaceStringByStringInString('Ç','é',s);
  s := ReplaceStringByStringInString('Ç','é',s);
  s := ReplaceStringByStringInString('ä','è',s);
  s := ReplaceStringByStringInString('ä','è',s);
  s := ReplaceStringByStringInString('ä','è',s);
  s := ReplaceStringByStringInString('ä','è',s);

  GetCommentOfThorParRec := s;
end;


function GetPartieEnAlphaOfThorParRec(const enregistrement : ThorParRec) : String255;
var coupsPourLeTranscript : platValeur;
    theTranscript : Transcript;
    analyse : AnalyseDeTranscriptPtr;
    i,j,square,numeroDansSquare : SInt32;
    s : String255;
begin
  GetPartieEnAlphaOfThorParRec := '';

  analyse := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));
  MemoryFillChar(@coupsPourLeTranscript,SizeOf(platValeur),chr(0));
  with enregistrement do
    begin
      for i := 1 to 8 do
        for j := 1 to 8 do
          begin
            square := 10*j + i;
            numeroDansSquare := posEtCoups[i,j];
            if (numeroDansSquare <> ord(kNoirTHOR_PAR)) and (numeroDansSquare <> ord(kBlancTHOR_PAR))
              then coupsPourLeTranscript[square] := numeroDansSquare;
          end;

       theTranscript := MakeTranscriptFromPlateauOthello(coupsPourLeTranscript);
       ChercherLesErreursDansCeTranscript(theTranscript,analyse^);
       if analyse^.tousLesCoupsSontLegaux then
         begin
           s := analyse^.plusLonguePartieLegale;
           if EstUnePartieOthelloAvecMiroir(s) {symetrisons, eventuellement}
		         then GetPartieEnAlphaOfThorParRec := s;
         end;
    end;
  DisposeMemoryPtr(Ptr(analyse));
end;


function AjouterPartiesFichierTHOR_PARDansListe(var fichierTHOR_PAR : FichierTEXT) : OSErr;
var err : OSErr;
    n : SInt32;
    enregistrement : ThorParRec;
    commentaire,partieEnAlpha : String255;
    nomLongDuFichier : String255;
    anneeTournoi,numeroTournoi : SInt32;
    numeroNoir,numeroBlanc : SInt32;
    nbNoirsFinal,nbBlancsFinal : SInt32;
    partieRec : t_PartieRecNouveauFormat;
    myDate : DateTimeRec;
    nroReferencePartieAjoutee : SInt32;
    partieComplete : boolean;
    confianceDansLesJoueurs : double_t;
begin
  err := NoErr;

  err := FSSpecToLongName(fichierTHOR_PAR.theFSSpec, nomLongDuFichier);
  AnnonceOuvertureFichierEnRougeDansRapport(nomLongDuFichier);

  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;

  err := OuvreFichierTexte(fichierTHOR_PAR);

  GetTime(myDate);
  anneeTournoi := myDate.year;
  if not(TrouverNomDeTournoiDansPath(fichierTHOR_PAR.nomFichier,numeroTournoi,anneeTournoi,'name_mapping_VOG_to_WThor.txt'))
    then numeroTournoi := kNroTournoiDiversesParties;

  for n := 1 to nbPlagesDansTHOR_PAR * nbPartiesParPlageDansTHOR_PAR do
    begin
      if LitEnregistrementDansFichierThorPar(fichierTHOR_PAR,n,enregistrement) = NoErr then
        with enregistrement do
          if (nbCoupsJouesYComprisPasses > 0) then
            begin
              commentaire := GetCommentOfThorParRec(enregistrement);
              partieEnAlpha := GetPartieEnAlphaOfThorParRec(enregistrement);
              partieComplete := EstUnePartieOthelloTerminee(partieEnAlpha,false,nbNoirsFinal,nbBlancsFinal);

              if (LENGTH_OF_STRING(partieEnAlpha) div 2) > 20 then
                begin

                  WritelnDansRapport(commentaire);
                  if partieComplete
                    then
                      WritelnDansRapport(partieEnAlpha)
                    else
                      begin
                        ChangeFontColorDansRapport(RougeCmd);
                        WritelnDansRapport(partieEnAlpha);
                        TextNormalDansRapport;
                      end;
                  WritelnDansRapport('');

                  if not(TrouverNomsDesJoueursDansNomDeFichier(commentaire,numeroNoir,numeroBlanc,0,confianceDansLesJoueurs))
                    then
                      begin
                        numeroNoir  := kNroJoueurInconnu;
                        numeroBlanc := kNroJoueurInconnu;
                      end;

                  (* maintenant, ajouter la partie dans la liste *)
                  SetAutorisationCalculsLongsSurListe(false);
                  if sousSelectionActive then DoChangeSousSelectionActive;

                  if AjouterPartieAlphaDansLaListe(partieEnAlpha,-1,numeroNoir,numeroBlanc,numeroTournoi,anneeTournoi,partieRec,nroReferencePartieAjoutee) then DoNothing;

                  SetAutorisationCalculsLongsSurListe(true);
                end;

            end;
    end;

  err := FermeFichierTexte(fichierTHOR_PAR);

  SetAutorisationCalculsLongsSurListe(true);
  TrierListePartie(gGenreDeTriListe,AlgoDeTriOptimum(gGenreDeTriListe));
  CalculsEtAffichagePourBase(false,false);

  AjouterPartiesFichierTHOR_PARDansListe := err;
end;


function EcritPartieFormatTHOR_PAR(var fichierTHOR_PAR : FichierTEXT; numeroPartieDansFichier : SInt32; partieNF : t_PartieRecNouveauFormat) : OSErr;
var err : OSErr;
    k,i,j,aux : SInt16;
    s,joueurNoir,joueurBlanc : String255;
    position,count : SInt32;
    table : array[0..99] of SInt16;
    nbCoupsJoues,nbCoupsJouesYComprisPasses,nbNoirs,nbBlancs : SInt16;
    partie60 : PackedThorGame;
    myPositionEtTrait : PositionEtTraitRec;
    typeErreurPartie,oldTrait : SInt32;
begin
  err := -1;
  if (numeroPartieDansFichier >= 0) and
     (numeroPartieDansFichier <= nbPlagesDansTHOR_PAR*nbPartiesParPlageDansTHOR_PAR-1) then
    begin
      s := '';

      {les 36 pemiers octets sont du texte libre}
		  {on concatene les noms des joueurs, et le score}
		  with partieNF do
		    begin
		      joueurNoir := GetNomJoueur(nroJoueurNoir);
		      joueurBlanc := GetNomJoueur(nroJoueurBlanc);
		      joueurNoir := MyUpperString(joueurNoir,false);
		      joueurBlanc := MyUpperString(joueurBlanc,false);
		      for k := 1 to Min(14,LENGTH_OF_STRING(joueurNoir)) do  s := s + joueurNoir[k];
		      s := s + ' '+ScoreFinalEnChaine((scoreReel-32)*2)+' ';
		      for k := 1 to Min(14,LENGTH_OF_STRING(joueurBlanc)) do s := s + joueurBlanc[k];
		    end;
		  {on complete à 36 caracteres avec le caractere nul}
		  if LENGTH_OF_STRING(s) > 36
		    then s := TPCopy(s,1,36)
		    else for k := LENGTH_OF_STRING(s) + 1 to 36 do s := s + chr(0);

		  {encodage de la position initiale et de la partie en 64 octets}
		  nbCoupsJoues := 0;
		  nbCoupsJouesYComprisPasses := 0;
		  myPositionEtTrait := PositionEtTraitInitiauxStandard;
		  FILL_PACKED_GAME_WITH_ZEROS(partie60);
		  for k := 0 to 99 do table[k] := 0;
		  table[44] := ord(kBlancTHOR_PAR);
		  table[45] := ord(kNoirTHOR_PAR);
		  table[54] := ord(kNoirTHOR_PAR);
		  table[55] := ord(kBlancTHOR_PAR);
      for k := 1 to 60 do
		    begin
		      aux := partieNF.listeCoups[k];
		      if (aux >= 11) and (aux <= 88) then
		        begin
		          inc(nbCoupsJoues);
		          inc(nbCoupsJouesYComprisPasses);

		          table[aux] := nbCoupsJouesYComprisPasses;
		          ADD_MOVE_TO_PACKED_GAME(partie60, aux);

		          oldTrait := GetTraitOfPosition(myPositionEtTrait);
		          if UpdatePositionEtTrait(myPositionEtTrait,aux) and (GetTraitOfPosition(myPositionEtTrait) = oldTrait)
		            then inc(nbCoupsJouesYComprisPasses); {on vient de trouve un passe !}

		        end;
		    end;
		  for i := 1 to 8 do
		    for j := 1 to 8 do
		      s := s + chr(table[i*10+j]);

		  nbNoirs := NbPionsDeCetteCouleurApresCeCoup(partie60,pionNoir,nbCoupsJoues,typeErreurPartie);
		  nbBlancs := NbPionsDeCetteCouleurApresCeCoup(partie60,pionBlanc,nbCoupsJoues,typeErreurPartie);
		  myPositionEtTrait := PositionEtTraitAfterMoveNumber(partie60,nbCoupsJoues,typeErreurPartie);


		  s := s + chr(44) + chr(1);                 {temps restant          : 2 octets}
		  s := s + chr(0) + chr(0);                  {mode de jeu, pb ou non : 2 octets}
		  s := s + chr(0);                         {niveau dans Thor       : 1 octet}
		  s := s + chr(nbCoupsJouesYComprisPasses);{nb coups joues         : 1 octet}
		  s := s + chr(nbNoirs) + chr(nbBlancs);     {nb noirs, nb blancs    : 2 octets}
		  s := s + kNoirTHOR_PAR;                  {trait initial          : 1 octet}
		  case GetTraitOfPosition(myPositionEtTrait) of        {trait pos. finale      : 1 octet}
		    pionNoir  :  s := s + kNoirTHOR_PAR;
		    pionBlanc :  s := s + kBlancTHOR_PAR;
		    otherwise
		      case oldTrait of
		        pionNoir  :  s := s + kBlancTHOR_PAR;
		        pionBlanc :  s := s + kNoirTHOR_PAR;
		        otherwise    s := s + chr(0);
		      end; {case}
		  end; {case}
		  s := s + chr(0) + chr(0);                  {suggestion de Thor, 0 binaire  : 2 octets}



		  {on complete à 112 caracteres avec le caractere nul}
		  if LENGTH_OF_STRING(s) > TailleEnregistrementTHOR_PAR
		    then s := TPCopy(s,1,TailleEnregistrementTHOR_PAR)
		    else for k := LENGTH_OF_STRING(s) + 1 to TailleEnregistrementTHOR_PAR do s := s + chr(0);

		  {on ecrit dans le fichier THOR.PAR}
		  position := numeroPartieDansFichier*TailleEnregistrementTHOR_PAR;
		  count := TailleEnregistrementTHOR_PAR;
		  err := SetPositionTeteLectureFichierTexte(fichierTHOR_PAR,position);
		  err := WriteBufferDansFichierTexte(fichierTHOR_PAR,@s[1],count);
		end;

  EcritPartieFormatTHOR_PAR := err;
end;


function EcritPartieVideDansFichierTHOR_PAR(var fichierTHOR_PAR : FichierTEXT; numeroPartieDansFichier : SInt32) : OSErr;
var err : OSErr;
    k,i,j : SInt16;
    s : String255;
    position,count : SInt32;
    table : array[0..99] of SInt16;
    nbCoupsJoues,nbCoupsJouesYComprisPasses,nbNoirs,nbBlancs : SInt16;
    myPositionEtTrait : PositionEtTraitRec;
begin
  err := -1;
  if (numeroPartieDansFichier >= 0) and
     (numeroPartieDansFichier <= nbPlagesDansTHOR_PAR*nbPartiesParPlageDansTHOR_PAR-1) then
    begin
      s := '';


		  {on complete à 36 caracteres avec le caractere nul}
		  if LENGTH_OF_STRING(s) > 36
		    then s := TPCopy(s,1,36)
		    else for k := LENGTH_OF_STRING(s) + 1 to 36 do s := s + chr(0);

		  {encodage de la position initiale et de la partie en 64 octets}
		  nbCoupsJoues := 0;
		  nbCoupsJouesYComprisPasses := 0;
		  myPositionEtTrait := PositionEtTraitInitiauxStandard;
		  for k := 0 to 99 do table[k] := 0;
		  table[44] := ord(kBlancTHOR_PAR);
		  table[45] := ord(kNoirTHOR_PAR);
		  table[54] := ord(kNoirTHOR_PAR);
		  table[55] := ord(kBlancTHOR_PAR);

		  for i := 1 to 8 do
		    for j := 1 to 8 do
		      s := s + chr(table[i*10+j]);

		  nbNoirs := 2;
		  nbBlancs := 2;
		  myPositionEtTrait := PositionEtTraitInitiauxStandard;


		  s := s + chr(44) + chr(1);                 {temps restant          : 2 octets}
		  s := s + chr(0) + chr(0);                  {mode de jeu, pb ou non : 2 octets}
		  s := s + chr(0);                         {niveau dans Thor       : 1 octet}
		  s := s + chr(0);                         {nb coups joues         : 1 octet}
		  s := s + chr(nbNoirs) + chr(nbBlancs);     {nb noirs, nb blancs    : 2 octets}
		  s := s + kNoirTHOR_PAR;                  {trait initial          : 1 octet}
		  s := s + kNoirTHOR_PAR;                  {trait pos. finale      : 1 octet}
		  s := s + chr(0) + chr(0);                  {suggestion de Thor, 0 binaire  : 2 octets}



		  {on complete à 112 caracteres avec le caractere nul}
		  if LENGTH_OF_STRING(s) > TailleEnregistrementTHOR_PAR
		    then s := TPCopy(s,1,TailleEnregistrementTHOR_PAR)
		    else for k := LENGTH_OF_STRING(s) + 1 to TailleEnregistrementTHOR_PAR do s := s + chr(0);

		  {on ecrit dans le fichier THOR.PAR}
		  position := numeroPartieDansFichier*TailleEnregistrementTHOR_PAR;
		  count := TailleEnregistrementTHOR_PAR;
		  err := SetPositionTeteLectureFichierTexte(fichierTHOR_PAR,position);
		  err := WriteBufferDansFichierTexte(fichierTHOR_PAR,@s[1],count);
		end;

  EcritPartieVideDansFichierTHOR_PAR := err;
end;



function SauvegardeCesPartiesDeLaListeEnTHOR_PAR(nroPartieMin,nroPartieMax : SInt32; var nbPartiesEcrites : SInt32; var fichierTHOR_PAR : FichierTEXT) : OSErr;
var partieNF : t_PartieRecNouveauFormat;
    n,nroReference,numeroPartieDansFichier : SInt32;
    nbPartiesRefusees : SInt32;
    codeErreur : OSErr;
    doitEcrireCettePartie : boolean;
    s60 : PackedThorGame;
    s255 : String255;
begin {$UNUSED s60,s255,anneeDesParties}
  SauvegardeCesPartiesDeLaListeEnTHOR_PAR := -1;


  codeErreur := OuvreFichierTexte(fichierTHOR_PAR);


  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);

  nbPartiesRefusees := 0;
  for n := nroPartieMin to nroPartieMax do
    if codeErreur = NoErr then
      begin
        nroReference := tableNumeroReference^^[n];
        partieNF := GetPartieRecordParNroRefPartie(nroReference);

        (* ici on modifie et on filtre les parties a écrire comme on veut... *)
        {partieNF.scoreTheorique := 255;}

        doitEcrireCettePartie := PartieEstActiveEtSelectionnee(nroReference);

        {
        ExtraitPartieTableStockageParties(nroReference,s60);
        TraductionThorEnAlphanumerique(s60,s255);
        doitEcrireCettePartie := EstUnePartieOthello(s255,true);
        if not(doitEcrireCettePartie)
          then WritelnDansRapport(s255);
          }

        if doitEcrireCettePartie
          then
	        begin
	          numeroPartieDansFichier := nbPartiesEcrites;
	          codeErreur := EcritPartieFormatTHOR_PAR(fichierTHOR_PAR,numeroPartieDansFichier,partieNF);
	          if codeErreur = NoErr then inc(nbPartiesEcrites);

	          {if (nbPartiesEcrites mod 500) = 0 then
	            begin
	              WriteNumDansRapport('ecrites : ',nbPartiesEcrites);
	              WritelnNumDansRapport(' ,  refusees : ',nbPartiesRefusees);
	            end;}
	        end
	      else
	        begin
	          inc(nbPartiesRefusees);
	        end;
      end;

  RemettreLeCurseurNormalDeCassio;

  codeErreur := FermeFichierTexte(fichierTHOR_PAR);
  SauvegardeCesPartiesDeLaListeEnTHOR_PAR := codeErreur;
end;


function SauvegardeListeCouranteEnTHOR_PAR : OSErr;
var codeErreur : OSErr;
    reply : SFReply;
    mySpec : FSSpec;
    prompt,s : String255;
    fichierTHOR_PAR : FichierTEXT;
    nroPartieDansListe,nroReference : SInt32;
    nroPremierePartieDeLAnnee : SInt32;
    nroDernierePartieDeLAnnee : SInt32;
    anneeCourante,anneePartieSuivante : SInt16;
    nbPartiesEcrites,k : SInt32;
begin
  if not(windowListeOpen) or (nbPartiesActives <= 0) then
    begin
      SauvegardeListeCouranteEnTHOR_PAR := NoErr;
      exit(SauvegardeListeCouranteEnTHOR_PAR);
    end;

  if windowListeOpen and (nbPartiesActives > 500) then
    begin
      prompt := ReadStringFromRessource(TextesNouveauFormatID,7); {'Impossible de sauvegarder plus de 500 parties dans un fichier THOR.PAR !'}
      AlerteSimple(prompt);
      SauvegardeListeCouranteEnTHOR_PAR := NoErr;
      exit(SauvegardeListeCouranteEnTHOR_PAR);
    end;

  BeginDialog;
  s := ReadStringFromRessource(TextesNouveauFormatID,6); {'THOR.PAR'}
  SetNameOfSFReply(reply, s);
  prompt := ReadStringFromRessource(TextesNouveauFormatID,5);   {'nom du fichier THOR.PAR à créer ?'}
  if MakeFileName(reply,prompt,mySpec) then DoNothing;
  EndDialog;

  if not(reply.good) then  {annulation}
    begin
      SauvegardeListeCouranteEnTHOR_PAR := NoErr;
      exit(SauvegardeListeCouranteEnTHOR_PAR);
    end;

  codeErreur := FichierTexteExisteFSp(mySpec,fichierTHOR_PAR);
  if codeErreur = fnfErr then codeErreur := CreeFichierTexteFSp(mySpec,fichierTHOR_PAR);
  if codeErreur = 0 then
    begin
      codeErreur := OuvreFichierTexte(fichierTHOR_PAR);
      codeErreur := SetEOFFichierTexte(fichierTHOR_PAR,TailleEnregistrementTHOR_PAR*nbPlagesDansTHOR_PAR*nbPartiesParPlageDansTHOR_PAR);
      codeErreur := FermeFichierTexte(fichierTHOR_PAR);
    end;
  if codeErreur <> 0 then
    begin
      SauvegardeListeCouranteEnTHOR_PAR := codeErreur;
      exit(SauvegardeListeCouranteEnTHOR_PAR);
    end;

  SauvegardeListeCouranteEnTHOR_PAR := -1;
  DoTrierListe(TriParDate,kRadixSort);

  nbPartiesEcrites := 0;
  nroPartieDansListe := 1;
  repeat

    watch := GetCursor(watchcursor);
    SafeSetCursor(watch);

    nroPremierePartieDeLannee := nroPartieDansListe;
    nroReference := tableNumeroReference^^[nroPremierePartieDeLannee];
    anneeCourante := GetAnneePartieParNroRefPartie(nroReference);
    repeat
      if (nroPartieDansListe < nbPartiesActives) then
        begin
          inc(nroPartieDansListe);
          anneePartieSuivante := GetAnneePartieParNroRefPartie(tableNumeroReference^^[nroPartieDansListe]);
        end;
    until (anneeCourante <> anneePartieSuivante) or (nroPartieDansListe >= nbPartiesActives);
    if nroPartieDansListe < nbPartiesActives
      then nroDernierePartieDeLAnnee := nroPartieDansListe-1
      else nroDernierePartieDeLAnnee := nroPartieDansListe;
    if nroDernierePartieDeLAnnee < nroPremierePartieDeLannee then nroDernierePartieDeLAnnee := nroPremierePartieDeLannee;
    if nroDernierePartieDeLAnnee > nbPartiesActives          then nroDernierePartieDeLAnnee := nbPartiesActives;

    codeErreur := SauvegardeCesPartiesDeLaListeEnTHOR_PAR(nroPremierePartieDeLAnnee,nroDernierePartieDeLAnnee,nbPartiesEcrites,fichierTHOR_PAR);

  until (nroPartieDansListe >= nbPartiesActives) or (codeErreur <> 0);

  {on complete le fichier avec des enregistrements vides}

  watch := GetCursor(watchcursor);
  SafeSetCursor(watch);
  codeErreur := OuvreFichierTexte(fichierTHOR_PAR);
  for k := nbPartiesEcrites+1 to 500 do
    if codeErreur = NoErr then
      begin
        codeErreur := EcritPartieVideDansFichierTHOR_PAR(fichierTHOR_PAR,k-1);
        if codeErreur = NoErr then inc(nbPartiesEcrites);
      end;
  codeErreur := FermeFichierTexte(fichierTHOR_PAR);

  RemettreLeCurseurNormalDeCassio;

  SauvegardeListeCouranteEnTHOR_PAR := codeErreur;
end;



end.
