UNIT UnitTestNouveauFormat;



INTERFACE







 USES UnitDefCassio;


procedure TestNouveauFormat;
procedure TestDisposeJoueursNouveauFormat;
procedure DebuguerNouveauFormat(fonctionAppelante : String255);
procedure EcritListeTournoisPourTraductionJaponais;
procedure EcritListeJoueursNoirsNonJaponaisPourTraduction;
procedure EcritListeJoueursBlancsNonJaponaisPourTraduction;

procedure AfficheFichierNouveauFormatDansRapport(numFic : SInt16);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitAccesNouveauFormat, UnitNouveauFormat, UnitRapport, MyFileSystemUtils, UnitPrefs, UnitFichierAbstrait
    , UnitServicesMemoire, MyMathUtils, SNEvents, UnitScannerUtils, MyStrings, UnitPackedThorGame, UnitScannerOthellistique, UnitServicesRapport
     ;
{$ELSEC}
    ;
    {$I prelink/TestNouveauFormat.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure AfficheFichierNouveauFormatDansRapport(numFic : SInt16);
var s1,s2 : String255;
begin

  with InfosFichiersNouveauFormat.fichiers[numFic] do
    begin
      WritelnNumDansRapport('fichier nouveau format #',numFic);

      s1 := CalculePathFichierNouveauFormat(numFic);
      s2 := CalculeNomFichierNouveauFormat(numFic);

      WritelnDansRapport('path du fichier =   '+s1);
      WritelnDansRapport('nom du fichier  =   '+s2);

      with InfosFichiersNouveauFormat.fichiers[numFic].entete do
		    begin
				  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
				  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
				  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
				  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
				  WritelnNumDansRapport('entete.NombreEnregistrementsParties (N1) =',NombreEnregistrementsParties);
				  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs (N2) =',NombreEnregistrementsTournoisEtJoueurs);
				  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
				  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
				  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
				  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
				  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
		    end;
	   if open
        then WritelnDansRapport('open = true')
        else WritelnDansRapport('open = false');
      WritelnNumDansRapport('refNum = ',refNum);
      WritelnNumDansRapport('vRefNum = ',vRefNum);
      WritelnNumDansRapport('parID = ',parID);
      WritelnNumDansRapport('NroFichierDual = ',NroFichierDual);
      WritelnNumDansRapport('annee = ',annee);
      WritelnNumDansRapport('NroDistribution = ',NroDistribution);




      case typeDonnees of
        kUnknownDataNouveauFormat      : WritelnDansRapport('format inconnu !   '+CalculeNomFichierNouveauFormat(numFic));
        kFicJoueursNouveauFormat       : WritelnDansRapport('fichier de joueurs   '+CalculeNomFichierNouveauFormat(numFic));
        kFicTournoisNouveauFormat      : WritelnDansRapport('fichier de tournois   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexJoueursNouveauFormat  : WritelnDansRapport('fichier de numeros (d''index) de joueurs   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexTournoisNouveauFormat : WritelnDansRapport('fichier de numeros (d''index) de tournois   '+CalculeNomFichierNouveauFormat(numFic));
        kFicPartiesNouveauFormat       : WritelnDansRapport('fichier de parties   '+CalculeNomFichierNouveauFormat(numFic));
        kFicIndexPartiesNouveauFormat  : WritelnDansRapport('fichier d''index de parties  '+CalculeNomFichierNouveauFormat(numFic));
        kFicTournoisCourtsNouveauFormat: WritelnDansRapport('fichier de tournois (noms courts)   '+CalculeNomFichierNouveauFormat(numFic));
        kFicJoueursCourtsNouveauFormat : WritelnDansRapport('fichier de joueurs (noms courts)    '+CalculeNomFichierNouveauFormat(numFic));
        kFicSolitairesNouveauFormat    : WritelnDansRapport('fichier de solitaires    '+CalculeNomFichierNouveauFormat(numFic));
      end;
      WritelnDansRapport('');
    end;
end;






procedure AfficheQuelquesParties;
var numPartie : SInt32;
    numFichier : SInt16;
    theGame : t_PartieRecNouveauFormat;
    err : OSErr;
    s60 : PackedThorGame;
    s255 : String255;
begin

  numFichier := 1;
  with InfosFichiersNouveauFormat do
    repeat
      if (numFichier <= nbFichiers) and
         (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) then
        begin
          WritelnNumDansRapport('ficher numŽro : ',numFichier);
          err := OuvreFichierNouveauFormat(numFichier);
          for numPartie := Min(1,fichiers[numFichier].entete.NombreEnregistrementsParties) downto 1 do
            begin
              err := LitPartieNouveauFormat(numFichier,numPartie,false,theGame);
              if ((numPartie-1) mod 53) = 0 then
                begin

                  SET_LENGTH_OF_PACKED_GAME(s60, 60);

                  MoveMemory(POINTER_ADD(@theGame , 8), GET_ADRESS_OF_FIRST_MOVE(s60),60);

                  TraductionThorEnAlphanumerique(s60,s255);

                  WritelnDansRapport(s255);
                end;
            end;
          err := FermeFichierNouveauFormat(numFichier);
        end;
      numFichier := succ(numFichier);
    until (numFichier > nbFichiers) or EscapeDansQueue;
end;



procedure LitTousLesIndexALaSuiteNouveauFormat;
var err : OSErr;
    k : SInt16;
    tick,ticktotal : SInt32;
begin
  {$unused tick}
  WritelnDansRapport('');
  ticktotal := TickCount;

  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if fichiers[k].typeDonnees = kFicIndexPartiesNouveauFormat then
        begin
          {WritelnNumDansRapport('lecture du ficher index numŽro : ',k);
          tick := TickCount;}
          err := LitFichierIndexNouveauFormat(k);
          {WriteNumDansRapport('err = ',err);
          WritelnNumDansRapport('    temps = ',TickCount-tick);}
        end;

  WritelnDansRapport('temps total lecture des index de toute la base = '+IntToStr(TickCount-ticktotal)+' soixantiemes de seconde');
  WritelnDansRapport('');

end;

procedure EcritListeTournoisPourTraductionJaponais;
var err : OSErr;
    fic : FichierAbstrait;
    i : SInt32;
    s : String255;
begin
  with TournoisNouveauFormat do
    if nbTournoisNouveauFormat > 0 then
      begin
			  fic := MakeFichierAbstraitFichier('liste pour Abe',0);
			  if FichierAbstraitEstCorrect(fic) then
			    begin
			      err := ViderFichierAbstrait(fic);

    			  for i := 0 to nbTournoisNouveauFormat-1 do
    			    begin
    			      s := GetNomTournoi(i);
    			      err := WritelnDansFichierAbstrait(fic,s+' = ');
    			    end;

    			  DisposeFichierAbstrait(fic);
    			end;
			end;
end;

procedure EcritListeJoueursNoirsNonJaponaisPourTraduction;
var err : OSErr;
    fic : FichierAbstrait;
    i,nroPartie : SInt32;
    nroJoueurNoir,nroJoueurNoirPrecedant : SInt32;
    s : String255;
begin
  if (nbPartiesActives > 0) then
    begin
      fic := MakeFichierAbstraitFichier('myUnknowBlackPlayers.jap',0);

      if not(FichierAbstraitEstCorrect(fic))
        then exit(EcritListeJoueursNoirsNonJaponaisPourTraduction);

      err := ViderFichierAbstrait(fic);

      nroJoueurNoirPrecedant := -1000;  {ou n'importe quelle valeur abherante}
      for i := 1 to nbPartiesActives do
		    begin
		      nroPartie := tableNumeroReference^^[i];
		      nroJoueurNoir := GetNroJoueurNoirParNroRefPartie(nroPartie);

		      if not(JoueurAUnNomJaponais(nroJoueurNoir)) and
		         ((i = 1) or (nroJoueurNoir <> nroJoueurNoirPrecedant)) then
		        begin
					    s := GetNomJoueur(nroJoueurNoir);
					    err := WritelnDansFichierAbstrait(fic,s+' = ');
					  end;

					nroJoueurNoirPrecedant := nroJoueurNoir;
			  end;
		  DisposeFichierAbstrait(fic);
		end;
end;

procedure EcritListeJoueursBlancsNonJaponaisPourTraduction;
var err : OSErr;
    fic : FichierAbstrait;
    i,nroPartie : SInt32;
    nroJoueurBlanc,nroJoueurBlancPrecedant : SInt32;
    s : String255;
begin
  if nbPartiesActives > 0 then
    begin
      fic := MakeFichierAbstraitFichier('myUnknowWhitePlayers.jap',0);

      if not(FichierAbstraitEstCorrect(fic))
        then exit(EcritListeJoueursBlancsNonJaponaisPourTraduction);

      err := ViderFichierAbstrait(fic);

      nroJoueurBlancPrecedant := -1000;  {ou n'importe quelle valeur abherante}
      for i := 1 to nbPartiesActives do
		    begin
		      nroPartie := tableNumeroReference^^[i];
		      nroJoueurBlanc := GetNroJoueurBlancParNroRefPartie(nroPartie);

		      if not(JoueurAUnNomJaponais(nroJoueurBlanc)) and
		         ((i = 1) or (nroJoueurBlanc <> nroJoueurBlancPrecedant)) then
		        begin
					    s := GetNomJoueur(nroJoueurBlanc);
					    err := WritelnDansFichierAbstrait(fic,s+' = ');
					  end;

					nroJoueurBlancPrecedant := nroJoueurBlanc;
					end;
		  DisposeFichierAbstrait(fic);
		end;
end;


procedure DebuguerNouveauFormat(fonctionAppelante : String255);
var k,somme : SInt32;
begin
  somme := 0;
  with InfosFichiersNouveauFormat do
    begin
      k := 2;

      somme := somme + fichiers[k].entete.NombreEnregistrementsParties;

      {WritelnNumDansRapport('fichier '+IntToStr(k)+' = ',fichiers[k].entete.NombreEnregistrementsParties);}
    end;
  WritelnNumDansRapport('sizeof(FichierNouveauFormatRec) = ',sizeof(FichierNouveauFormatRec));
  WritelnNumDansRapport('sizeof(InfosFichiersNouveauFormat) = ',sizeof(InfosFichiersNouveauFormat));
  WritelnNumDansRapport('fonction appelante = '+fonctionAppelante+' => somme = ',somme);
end;


procedure TestNouveauFormat;
var k,numeroAlpha : SInt32;
    err : OSErr;
    {s : String255;}
begin  {$UNUSED err}


  SetEcritToutDansRapportLog(true);
  SetAutoVidageDuRapport(true);



  WritelnNumDansRapport('sizeof(t_EnTeteNouveauFormat) = ',sizeof(t_EnTeteNouveauFormat));
  WritelnNumDansRapport('sizeof(t_JoueurRecNouveauFormat) = ',sizeof(t_JoueurRecNouveauFormat));
  WritelnNumDansRapport('sizeof(t_TournoiRecNouveauFormat) = ',sizeof(t_TournoiRecNouveauFormat));
  WritelnNumDansRapport('sizeof(t_PartieRecNouveauFormat) = ',sizeof(t_PartieRecNouveauFormat));
  WritelnDansRapport('');


  LecturePreparatoireDossierDatabase(pathCassioFolder,'TestNouveauFormat');




  WritelnDansRapport('');
  WritelnNumDansRapport('nb distributions du nouveau format = ',DistributionsNouveauFormat.nbDistributions);
  {for k := 1 to DistributionsNouveauFormat.nbDistributions do
    begin
      WritelnDansRapport('path = '+DistributionsNouveauFormat.Distribution[k].path^);
      WriteDansRapport('nom = '+DistributionsNouveauFormat.Distribution[k].name^);
      WriteDansRapport('nomUsuel = '+DistributionsNouveauFormat.Distribution[k].nomUsuel^);
      WritelnDansRapport('    =>    '+IntToStr(NbTotalPartiesDansDistributionSet([k]))+' parties');
    end;}
  WritelnDansRapport('');


  {
  if OpenPrefsFileForSequentialReading = 0 then
    begin
      while not(EOFInPrefsFile) do
        begin
          err := GetNextLineInPrefsFile(s);
          if err <> 0
            then WritelnNumDansRapport('erreur fichier = ',err)
            else WritelnDansRapport(s);
        end;
      err := ClosePrefsFile;
    end;
  }



  WritelnDansRapport('');
  WritelnNumDansRapport('nb fichiers = ',InfosFichiersNouveauFormat.nbFichiers);
  {for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
    AfficheFichierNouveauFormatDansRapport(k); }


  {AfficheQuelquesParties;}

  WritelnNumDansRapport('nb joueurs en memoire =',JoueursNouveauFormat.nbJoueursNouveauFormat);
  WritelnNumDansRapport('nb tournois en memoire =',TournoisNouveauFormat.nbTournoisNouveauFormat);


  (*
  IndexerLesFichiersNouveauFormat;
  LitTousLesIndexALaSuiteNouveauFormat;
  *)


  err := MetJoueursNouveauFormatEnMemoire(false);
  TrierAlphabetiquementJoueursNouveauFormat;
  for k := 0 to 20 do
    begin
      WritelnDansRapport('joueur #'+IntToStr(k)+ ' = '+GetNomJoueur(k));
      numeroAlpha := JoueursNouveauFormat.ListeJoueurs^[k].numeroDansOrdreAlphabetique;
      WritelnDansRapport('  num dans ordre alphabetique = '+IntToStr(numeroAlpha));
      WritelnDansRapport('  nom = '+GetNomJoueur(numeroAlpha));
    end;



  {
  err := MetJoueursNouveauFormatEnMemoire(false);
  TrierAlphabetiquementJoueursNouveauFormat;
  }

  {
  err := MetTournoisNouveauFormatEnMemoire(false);
  TrierAlphabetiquementTournoisNouveauFormat;
  }

  {
  for k := 0 to 20 do
    begin
      WritelnDansRapport('tournoi #'+IntToStr(k)+ ' = '+GetNomTournoi(k));
      numeroAlpha := TournoisNouveauFormat.ListeTournois^[k].numeroDansOrdreAlphabetique;
      WritelnDansRapport('  num dans ordre alphabetique = '+IntToStr(numeroAlpha));
      WritelnDansRapport('  nom = '+GetNomTournoi(numeroAlpha));
    end;
  }

  {SetDebuggageUnitFichiersTexte(true);}
  err := LitNomsDesJoueursEnJaponais;
  {SetDebuggageUnitFichiersTexte(false);}

  {DisposeJoueursNouveauFormat;}

  WritelnDansRapport('Sortie de TestNouveauFormat...');
  WritelnDansRapport('');

  SetEcritToutDansRapportLog(false);
  SetAutoVidageDuRapport(false);

end;


procedure TestDisposeJoueursNouveauFormat;
var i : SInt32;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
	  begin
      if listeJoueurs <> NIL then
        begin

          WritelnNumDansRapport('nbJoueursNouveauFormat = ',nbJoueursNouveauFormat);

  	      for i := 0 to nbJoueursNouveauFormat-1 do
  	        begin

  	          JoueurArrow := POINTER_ADD(listeJoueurs , i*sizeof(JoueursNouveauFormatRec));
  	          if JoueurArrow^.nomJaponais <> NIL then
  	            begin
  	              DisposeMemoryHdl(Handle(JoueurArrow^.nomJaponais));
  	              JoueurArrow^.nomJaponais := NIL;
  	            end;
  	        end;
	      end;
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      if listeJoueurs <> NIL then DisposeMemoryPtr(Ptr(listeJoueurs));
      listeJoueurs := NIL;
	  end;

	Sysbeep(0);
	AttendFrappeClavier;
end;




end.
