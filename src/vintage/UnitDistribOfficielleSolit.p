UNIT UnitDistribOfficielleSolit;



INTERFACE







 USES UnitDefCassio;



function OuvreFichierSolitaireNouveauFormat(nbreCasesVides : SInt16) : OSErr;
function FermeFichierSolitaireNouveauFormat(nbreCasesVides : SInt16) : OSErr;


function GetNumeroFichierSolitaireNouveauFormat(nbreCasesVides : SInt16; var numeroFichier : SInt16) : boolean;
function CreerFichierSolitaireVideNouveauFormat(nbreCasesVides : SInt16) : OSErr;


function AjouterSolitaireNouveauFormatSurDisque(nbreCasesVides : SInt16; theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , UnitNouveauFormat, UnitRapport, MyStrings, UnitFichiersTEXT, UnitSolitairesNouveauFormat ;
{$ELSEC}
    ;
    {$I prelink/DistribOfficielleSolit.lk}
{$ENDC}


{END_USE_CLAUSE}











function OuvreFichierSolitaireNouveauFormat(nbreCasesVides : SInt16) : OSErr;
var numeroFichier : SInt16;
begin
  OuvreFichierSolitaireNouveauFormat := -1;
  if GetNumeroFichierSolitaireNouveauFormat(nbreCasesVides,numeroFichier) then
    begin
      OuvreFichierSolitaireNouveauFormat := OuvreFichierNouveauFormat(numeroFichier);
    end;
end;


function FermeFichierSolitaireNouveauFormat(nbreCasesVides : SInt16) : OSErr;
var numeroFichier : SInt16;
begin
  FermeFichierSolitaireNouveauFormat := -1;
  if GetNumeroFichierSolitaireNouveauFormat(nbreCasesVides,numeroFichier) then
    begin
      FermeFichierSolitaireNouveauFormat := FermeFichierNouveauFormat(numeroFichier);
    end;
end;


function GetNumeroFichierSolitaireNouveauFormat(nbreCasesVides : SInt16; var numeroFichier : SInt16) : boolean;
var i : SInt32;
begin
  GetNumeroFichierSolitaireNouveauFormat := false;
  numeroFichier := 0;

  if (nbreCasesVides >= 1) & (nbreCasesVides <= 64) then
	  {on trouve le premier fichier de solitaires avec ce nombre de cases vides}
	  with InfosFichiersNouveauFormat do
	    for i := 1 to nbFichiers do
	      if (fichiers[i].typeDonnees = kFicSolitairesNouveauFormat) then
	      if NbCasesVidesDeCeFichierSolitairesNouveauFormat(i) = nbreCasesVides then
	        begin
	          GetNumeroFichierSolitaireNouveauFormat := true;
	          numeroFichier := i;
	          exit(GetNumeroFichierSolitaireNouveauFormat);
	        end;
end;


function CreerFichierSolitaireVideNouveauFormat(nbreCasesVides : SInt16) : OSErr;
var nom : String255;
    statsPourCeFichier : t_EnteteSuplementaireSolitaires;
    i : SInt16;
    fichierSolitaires : FichierTEXT;
    entete : t_EnTeteNouveauFormat;
    myDate : DateTimeRec;
    erreurES : OSErr;
begin
  CreerFichierSolitaireVideNouveauFormat := -1;

  if (nbreCasesVides > 0) & (nbreCasesVides <= 60) then
    begin
		  nom := 'Solitaires_'+NumEnString(nbreCasesVides)+'.pzz';

		  {initialisation des entetes}
		  GetTime(myDate);
		  with entete do
		    begin
		      SiecleCreation                         := myDate.year div 100;
		      AnneeCreation                          := myDate.year mod 100;
		      MoisCreation                           := myDate.month;
		      JourCreation                           := myDate.day;
		      NombreEnregistrementsParties           := 0;
		      NombreEnregistrementsTournoisEtJoueurs := 0;
		      AnneeParties                           := 0;
		      TailleDuPlateau                        := 8;
		      EstUnFichierSolitaire                  := 1; {pour indiquer un fichier de solitaire}
		      ProfondeurCalculTheorique              := 0;
		      reservedByte                           := 0;
		    end;
		  SetNbSolitairesEtNbCasesVidesDansEntete(entete,0,nbreCasesVides);
		  for i := 1 to 64 do
		    statsPourCeFichier.nbSolitairesCetteProf[i] := 0;

		  {creation des fichiers sur le disque}
		  erreurES := CreeFichierTexte(nom,0,fichierSolitaires);
		  if erreurES = NoErr then erreurES := OuvreFichierTexte(fichierSolitaires);
		  if erreurES = NoErr then erreurES := VideFichierTexte(fichierSolitaires);
		  if erreurES = NoErr then erreurES := EcritEnteteNouveauFormat(fichierSolitaires.refNum,entete);
		  if erreurES = NoErr then erreurES := EcritEnteteSuplementaireFichierSolitaireNouveauFormat(fichierSolitaires.refNum,statsPourCeFichier);
		  if erreurES = NoErr then erreurES := FermeFichierTexte(fichierSolitaires);
		  SetFileCreatorFichierTexte(fichierSolitaires,MY_FOUR_CHAR_CODE('SNX4'));
		  SetFileTypeFichierTexte(fichierSolitaires,MY_FOUR_CHAR_CODE('PZZL'));

		  CreerFichierSolitaireVideNouveauFormat := erreurES;
		end;

end;



function AjouterSolitaireNouveauFormatSurDisque(nbreCasesVides : SInt16; theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;
var nroFichier : SInt16;
    erreurES : OSErr;
    nbSolitaires : SInt32;
    nbCasesVides : SInt16;
    statsPourCeFichier : t_EnteteSuplementaireSolitaires;
    {verifSolitaire : t_SolitaireRecNouveauFormat;}
begin
  AjouterSolitaireNouveauFormatSurDisque := -1;

  if (nbreCasesVides > 0) & (nbreCasesVides <= 60) &
     GetNumeroFichierSolitaireNouveauFormat(nbreCasesVides,nroFichier) then
    with InfosFichiersNouveauFormat.fichiers[nroFichier] do
      begin
        if not(open) then
          begin
            erreurES := OuvreFichierSolitaireNouveauFormat(nbreCasesVides);
            if erreurES <> NoErr then
              begin
                AjouterSolitaireNouveauFormatSurDisque := erreurES;
                exit(AjouterSolitaireNouveauFormatSurDisque);
              end;
          end;

        GetNbSolitairesEtNbCasesVidesFromEntete(entete,nbSolitaires,nbCasesVides);
        inc(nbSolitaires);
        SetNbSolitairesEtNbCasesVidesDansEntete(entete,nbSolitaires,nbCasesVides);

        erreurES := EcritEnteteNouveauFormat(refNum,entete);
        if erreurES <> NoErr then
          begin
            AjouterSolitaireNouveauFormatSurDisque := erreurES;
            exit(AjouterSolitaireNouveauFormatSurDisque);
          end;

        erreurES := LitEnteteSuplementaireFichierSolitaireNouveauFormat(refNum,statsPourCeFichier);
        if erreurES <> NoErr then
          begin
            AjouterSolitaireNouveauFormatSurDisque := erreurES;
            exit(AjouterSolitaireNouveauFormatSurDisque);
          end;

        inc(statsPourCeFichier.nbSolitairesCetteProf[nbCasesVides]);

        erreurES := EcritEnteteSuplementaireFichierSolitaireNouveauFormat(refNum,statsPourCeFichier);
        if erreurES <> NoErr then
          begin
            AjouterSolitaireNouveauFormatSurDisque := erreurES;
            exit(AjouterSolitaireNouveauFormatSurDisque);
          end;

        if (nbSolitaires <> statsPourCeFichier.nbSolitairesCetteProf[nbCasesVides]) then
          begin
            SysBeep(0);
            WritelnDansRapport('Erreur : nbSolitaires <> statsPourCeFichier.nbSolitairesCetteProf[nbCasesVides]');
            WritelnNumDansRapport('nbSolitaires = ',nbSolitaires);
            WritelnNumDansRapport('statsPourCeFichier.nbSolitairesCetteProf[nbCasesVides] = ',statsPourCeFichier.nbSolitairesCetteProf[nbCasesVides]);
            WritelnDansRapport('');
          end;

        erreurES := EcritSolitaireNouveauFormat(refNum,nbSolitaires,theSolitaire);
        if erreurES <> NoErr then
          begin
            SysBeep(0);
            AjouterSolitaireNouveauFormatSurDisque := erreurES;
            exit(AjouterSolitaireNouveauFormatSurDisque);
          end;

        (*
        erreurES := LitSolitaireNouveauFormat(refNum,nbSolitaires,verifSolitaire);
        if erreurES <> NoErr then
          begin
            SysBeep(0);
            AjouterSolitaireNouveauFormatSurDisque := erreurES;
            exit(AjouterSolitaireNouveauFormatSurDisque);
          end;

        with verifSolitaire do
          begin
	          WritelnNumDansRapport('annee = ',annee);
					  WritelnNumDansRapport('nroTournoi = ',nroTournoi);
					  WritelnNumDansRapport('nroJoueurNoir = ',nroJoueurNoir);
					  WritelnNumDansRapport('nroJoueurBlanc = ',nroJoueurBlanc);
					  WritelnPositionEtTraitDansRapport(PackedOthelloPositionToPlOth(position),traitSolitaire);
					  WritelnNumDansRapport('nbVides = ',nbVides);
					  WritelnNumDansRapport('scoreParfait = ',scoreParfait);
					  WritelnStringAndCoupDansRapport('solution = ',solution);
					  WritelnDansRapport('');
          end;
        *)

        erreurES := FermeFichierSolitaireNouveauFormat(nbreCasesVides);
        AjouterSolitaireNouveauFormatSurDisque := erreurES;
      end;
end;


END.
