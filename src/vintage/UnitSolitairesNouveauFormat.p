UNIT UnitSolitairesNouveauFormat;



INTERFACE







 USES UnitDefCassio;






function NbSolitairesDansFichierSolitairesNouveauFormat(numeroFichier : SInt16) : SInt32;
function NbCasesVidesDeCeFichierSolitairesNouveauFormat(numeroFichier : SInt16) : SInt16;
function NumeroDistributionSolitaires : SInt16;
function DecalageJoueursSolitaires : SInt32;
function DecalageTournoisSolitaires : SInt32;

procedure GetNbSolitairesEtNbCasesVidesFromEntete(entete : t_EnTeteNouveauFormat; var nbSolitaires : SInt32; var nbCasesVides : SInt16);
procedure SetNbSolitairesEtNbCasesVidesDansEntete(var entete : t_EnTeteNouveauFormat; nbSolitaires : SInt32; nbCasesVides : SInt16);

function LitEnteteSuplementaireFichierSolitaireNouveauFormat(var fic : basicFile; var entete : t_EnteteSuplementaireSolitaires) : OSErr;
function LitSolitaireNouveauFormat(var fic : basicFile; nroSolitaire : SInt32; var theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;
function EcritEnteteSuplementaireFichierSolitaireNouveauFormat(var fic : basicFile; entete : t_EnteteSuplementaireSolitaires) : OSErr;
function EcritSolitaireNouveauFormat(var fic : basicFile; nroSolitaire : SInt32; theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;
procedure ReparerFichiersSolitaires;

function MakeSolitaireRecNouveauFormat(annee : SInt16; nroTournoi : SInt16; nroJoueurNoir : SInt32; nroJoueurBlanc : SInt32; plat : plateauOthello; trait : SInt16; {pionNoir,pionBlanc} score : SInt16; coupSolution : SInt16; scoreReelDeLaPartie : SInt16; coup25dansLaBase : SInt16) : t_SolitaireRecNouveauFormat;


function FabriqueCommentaireSolitaireNouveauFormat(whichSolitaire : t_SolitaireRecNouveauFormat) : String255;
function FabriqueChainePositionSolitaireNouveauFormat(whichSolitaire : t_SolitaireRecNouveauFormat) : String255;

function NbSolitairesDansCetteIntervalleDeCasesVides(nbCasesMin,nbCasesMax : SInt16) : SInt32;
procedure DoJoueAuxSolitairesNouveauFormat(nbCasesMin,nbCasesMax : SInt16);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitNouveauFormat, UnitBaseNouveauFormat, UnitSolitaire, UnitAccesNouveauFormat, MyFileSystemUtils, UnitRapport, UnitServicesMemoire
    , MyStrings, MyMathUtils, UnitPackedOthelloPosition ;
{$ELSEC}
    ;
    {$I prelink/SolitairesNouveauFormat.lk}
{$ENDC}


{END_USE_CLAUSE}












type t_tableNbSolitaires = array[-1..65] of SInt32;


procedure GetNbSolitairesEtNbCasesVidesFromEntete(entete : t_EnTeteNouveauFormat; var nbSolitaires : SInt32; var nbCasesVides : SInt16);
begin
  {surcharge de NombreEnregistrementsTournoisEtJoueurs pour stocker le nb de cases vides}
  nbSolitaires := entete.NombreEnregistrementsParties;
  nbCasesVides := entete.NombreEnregistrementsTournoisEtJoueurs;
end;

procedure SetNbSolitairesEtNbCasesVidesDansEntete(var entete : t_EnTeteNouveauFormat; nbSolitaires : SInt32; nbCasesVides : SInt16);
begin
  {surcharge de NombreEnregistrementsTournoisEtJoueurs pour stocker le nb de cases vides}
  entete.NombreEnregistrementsParties := nbSolitaires;
  entete.NombreEnregistrementsTournoisEtJoueurs := nbCasesVides;
end;



function NbSolitairesDansFichierSolitairesNouveauFormat(numeroFichier : SInt16) : SInt32;
var nbSolitaires : SInt32;
    nbCasesVides : SInt16;
begin
  NbSolitairesDansFichierSolitairesNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numeroFichier > 0) and (numeroFichier <= nbFichiers) and
     (fichiers[numeroFichier].typeDonnees = kFicSolitairesNouveauFormat)  then
       begin
         GetNbSolitairesEtNbCasesVidesFromEntete(fichiers[numeroFichier].entete,nbSolitaires,nbCasesVides);
         NbSolitairesDansFichierSolitairesNouveauFormat := nbSolitaires;
       end;
end;

function NbCasesVidesDeCeFichierSolitairesNouveauFormat(numeroFichier : SInt16) : SInt16;
var nbSolitaires : SInt32;
    nbCasesVides : SInt16;
begin
  NbCasesVidesDeCeFichierSolitairesNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numeroFichier > 0) and (numeroFichier <= nbFichiers) and
     (fichiers[numeroFichier].typeDonnees = kFicSolitairesNouveauFormat)  then
       begin
         GetNbSolitairesEtNbCasesVidesFromEntete(fichiers[numeroFichier].entete,nbSolitaires,nbCasesVides);
         NbCasesVidesDeCeFichierSolitairesNouveauFormat := nbCasesVides;
       end;
end;

function NumeroDistributionSolitaires : SInt16;
var k : SInt16;
begin
  NumeroDistributionSolitaires := -1;
  with DistributionsNouveauFormat do
	  for k := 1 to nbDistributions do
	    if distribution[k].typeDonneesDansDistribution = kFicSolitairesNouveauFormat then
	      begin
	        NumeroDistributionSolitaires := k;
	        exit;
	      end;
end;

function DecalageJoueursSolitaires : SInt32;
var k : SInt16;
begin
  DecalageJoueursSolitaires := 0;
  with DistributionsNouveauFormat do
	  for k := 1 to nbDistributions do
	    if distribution[k].typeDonneesDansDistribution = kFicSolitairesNouveauFormat then
	      begin
	        DecalageJoueursSolitaires := distribution[k].decalageNrosJoueurs;
	        exit;
	      end;
end;

function DecalageTournoisSolitaires : SInt32;
var k : SInt16;
begin
  DecalageTournoisSolitaires := -1;
  with DistributionsNouveauFormat do
	  for k := 1 to nbDistributions do
	    if distribution[k].typeDonneesDansDistribution = kFicSolitairesNouveauFormat then
	      begin
	        DecalageTournoisSolitaires := distribution[k].decalageNrosTournois;
	        exit;
	      end;
end;


function LitEnteteSuplementaireFichierSolitaireNouveauFormat(var fic : basicFile; var entete : t_EnteteSuplementaireSolitaires) : OSErr;
var codeErreur : OSErr;
    i : SInt16;
begin
  LitEnteteSuplementaireFichierSolitaireNouveauFormat := -1;
  MemoryFillChar(@entete,TailleEnteteSupplementaireSolitaires,char(0));

  codeErreur := MyFSReadAt(refNum,TailleEnTeteNouveauFormat,TailleEnteteSupplementaireSolitaires,@entete);

  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  if codeErreur = 0 then
    with entete do
      for i := 1 to 64 do
        SWAP_LONGINT( @nbSolitairesCetteProf[i]);
  {$ENDC}

  LitEnteteSuplementaireFichierSolitaireNouveauFormat := codeErreur;
end;

function EcritEnteteSuplementaireFichierSolitaireNouveauFormat(var fic : basicFile; entete : t_EnteteSuplementaireSolitaires) : OSErr;
var codeErreur : OSErr;
    i : SInt16;
begin
  EcritEnteteSuplementaireFichierSolitaireNouveauFormat := -1;

  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  with entete do
    for i := 1 to 64 do
      SWAP_LONGINT( @nbSolitairesCetteProf[i]);
  {$ENDC}

  codeErreur := MyFSWriteAt(refNum,FSFromStart,TailleEnTeteNouveauFormat,TailleEnteteSupplementaireSolitaires,@entete);

  EcritEnteteSuplementaireFichierSolitaireNouveauFormat := codeErreur;
end;


function EcritSolitaireNouveauFormat(var fic : basicFile; nroSolitaire : SInt32; theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
    offset : SInt32;
begin
  with theSolitaire do
		begin
		  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
		  SWAP_INTEGER( @annee);
		  SWAP_INTEGER( @nroTournoi);
		  SWAP_LONGINT( @nroJoueurNoir);
		  SWAP_LONGINT( @nroJoueurBlanc);
		  {$ENDC}
		end;
  offset := TailleEnTeteNouveauFormat + TailleEnteteSupplementaireSolitaires + pred(nroSolitaire)*TailleSolitaireRecNouveauFormat;
  codeErreur := MyFSWriteAt(refnum,FSFromStart,offset,TailleSolitaireRecNouveauFormat,@theSolitaire);
  EcritSolitaireNouveauFormat := codeErreur;
end;



{si necessaire, on change l'entete des fichiers solitaires pour se conformer
 au nouveau format de la base Wthor publie dans Fforum 61}
procedure ReparerFichiersSolitaires;
var i : SInt32;
    codeErreur : OSErr;
    dejaOuvert : boolean;
begin
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      with fichiers[i] do
	    if (typeDonnees = kFicSolitairesNouveauFormat) then
	      with entete do
	        if (TailleDuPlateau <> 8) or (EstUnFichierSolitaire <> 1) or (ProfondeurCalculTheorique <> 0) then
			      begin
			        TailleDuPlateau := 8;
			        EstUnFichierSolitaire := 1;
			        ProfondeurCalculTheorique := 0;

			        dejaOuvert := open;
			        codeErreur := 0;

			        if (codeErreur = 0) and not(dejaOuvert) then codeErreur := OuvreFichierNouveauFormat(i);
			        if (codeErreur = 0) and open            then codeErreur := EcritEnteteNouveauFormat(refnum,entete);
			        if (codeErreur = 0) and not(dejaOuvert) then codeErreur := FermeFichierNouveauFormat(i);


			        WritelnNumDansRapport('Réparation de '+nomFichier^+'  => codeErreur = ',codeErreur);
			      end;
end;


function LitSolitaireNouveauFormat(var fic : basicFile; nroSolitaire : SInt32; var theSolitaire : t_SolitaireRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
    offset : SInt32;
begin
  offset := TailleEnTeteNouveauFormat + TailleEnteteSupplementaireSolitaires + pred(nroSolitaire)*TailleSolitaireRecNouveauFormat;
  codeErreur := MyFSReadAt(refnum,offset,TailleSolitaireRecNouveauFormat,@theSolitaire);
  with theSolitaire do
		begin
		  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
		  SWAP_INTEGER( @annee);
		  SWAP_INTEGER( @nroTournoi);
		  SWAP_LONGINT( @nroJoueurNoir);
		  SWAP_LONGINT( @nroJoueurBlanc);
		  {$ENDC}
		end;
	LitSolitaireNouveauFormat := codeErreur;
end;




function MakeSolitaireRecNouveauFormat(annee : SInt16;
                                       nroTournoi : SInt16;
                                       nroJoueurNoir : SInt32;
	                                     nroJoueurBlanc : SInt32;
	                                     plat : plateauOthello;
	                                     trait : SInt16;        {pionNoir,pionBlanc}
	                                     score : SInt16;
	                                     coupSolution : SInt16;
	                                     scoreReelDeLaPartie : SInt16;
	                                     coup25dansLaBase : SInt16) : t_SolitaireRecNouveauFormat;
var result : t_SolitaireRecNouveauFormat;
    i : SInt16;
begin
  result.annee := annee;
  result.nroTournoi := nroTournoi;
  result.nroJoueurNoir := nroJoueurNoir;
  result.nroJoueurBlanc := nroJoueurBlanc;
  result.position := PlOthToPackedOthelloPosition(plat);
  result.nbVides := 0;
  for i := 1 to 64 do
    if plat[othellier[i]] = pionVide then
      result.nbVides := result.nbVides+1;
  case trait of
    pionNoir  : result.traitSolitaire := 1;
    pionBlanc : result.traitSolitaire := 2;
    otherwise   result.traitSolitaire := 0;
  end; {case}
  result.scoreParfait := score;
  result.solution := coupSolution;
  result.scoreReel := scoreReelDeLaPartie;
  result.coup25 := coup25dansLaBase;
  result.reserved1 := 0;
  result.reserved2 := 0;

  MakeSolitaireRecNouveauFormat := result;
end;



function SolitaireEstEntreDeuxOrdinateurs(whichSolitaire : t_SolitaireRecNouveauFormat) : boolean;
var nomNoir,nomBlanc : String255;
begin

  nomNoir  := GetNomJoueur(whichSolitaire.nroJoueurNoir + DecalageJoueursSolitaires);
  nomBlanc := GetNomJoueur(whichSolitaire.nroJoueurBlanc + DecalageJoueursSolitaires);

  {Les ordinateurs ont des parentheses dans leur nom...}
  SolitaireEstEntreDeuxOrdinateurs :=  (Pos('(',nomNoir) > 0) and
                                       (Pos('(',nomBlanc) > 0);
end;


function FabriqueCommentaireSolitaireNouveauFormat(whichSolitaire : t_SolitaireRecNouveauFormat) : String255;
var commentaire : String255;
    s30 : String255;
    nom : String255;
begin
  commentaire := '';

  (*
  with whichSolitaire do
    begin
      nroJoueurNoir := nroJoueurNoir + 6 * 256;
      nroJoueurBlanc := nroJoueurBlanc + 6 * 256;
      nroTournoi := nroTournoi + 256;
    end;
	*)

  with whichSolitaire do
    begin

      {on met "Noir joue et gagne…" ou "Blanc joue et annule…', enfin ce qu'il faut}
      case traitSolitaire of
		    1 {noir} :
		      begin
		        if scoreParfait = 0
		          then commentaire := ReadStringFromRessource(TextesSolitairesID,3)
		          else commentaire := ReadStringFromRessource(TextesSolitairesID,1);
		      end;
		    2 {blanc} :
		      begin
		        if scoreParfait = 0
		          then commentaire := ReadStringFromRessource(TextesSolitairesID,4)
		          else commentaire := ReadStringFromRessource(TextesSolitairesID,2);
		      end;
		    0 {otherwise} :
		      begin
		        SysBeep(0);
		        WritelnDansRapport('Erreur dans FabriqueCommentaireSolitaireNouveauFormat (trait nul) !!');
		        commentaire := 'TRAIT INCONNU !!';
		      end;
		  end; {case}

		  {des espaces pour faire joli}
		  commentaire := Concat(commentaire,'   ');

      {le nom du joueur noir}
      nom := GetNomJoueurSansPrenom(nroJoueurNoir + DecalageJoueursSolitaires);

      nom := EnleveEspacesDeDroite(nom);
      ParamDiagPartieFFORUM.TitreFFORUM^^ := nom + ' - ';

      {le score si on est en references completes}
      if referencesCompletes and (scoreReel <> 0)
        then commentaire := commentaire + nom + ' ' + IntToStr(scoreReel) + '—'  // note : c'est un tiret long (option — )
        else commentaire := commentaire + nom + ' — ';                              // note : c'est un tiret long (option — )

      {le nom du joueur blanc}
      nom := GetNomJoueurSansPrenom(nroJoueurBlanc + DecalageJoueursSolitaires);

      nom := EnleveEspacesDeDroite(nom);
      ParamDiagPartieFFORUM.TitreFFORUM^^ := ParamDiagPartieFFORUM.TitreFFORUM^^ + nom;

      {le score si on est en references completes}
      if referencescompletes and (scoreReel <> 0)
        then commentaire := commentaire + IntToStr(64-scoreReel) + ' ' + nom
        else commentaire := commentaire + nom;

      {des espaces pour faire joli}
      commentaire := Concat(commentaire,', ');

      {le tournoi et l'annee}
      s30 := GetNomTournoi(nroTournoi + DecalageTournoisSolitaires);
      commentaire := commentaire + s30 + CharToString(' ') + IntToStr(annee);
      ParamDiagPartieFFORUM.TitreFFORUM^^ := ParamDiagPartieFFORUM.TitreFFORUM^^ + ' ' + IntToStr(annee);

      {le numéro du coup}
      if referencescompletes then
        commentaire := commentaire + ', c.' + IntToStr(60-nbVides+1);


		end;
  FabriqueCommentaireSolitaireNouveauFormat := commentaire;
end;


function FabriqueChainePositionSolitaireNouveauFormat(whichSolitaire : t_SolitaireRecNouveauFormat) : String255;
var s : String255;
    thePosition : PackedOthelloPosition;
begin
  thePosition := whichSolitaire.position;
  CompilerPosition(PackedOthelloPositionToPlOth(thePosition),s);
  FabriqueChainePositionSolitaireNouveauFormat := '     '+s;
end;



procedure ConstruitTableNbSolitairesCumules(var tableNbSolitaires,tableNbSolitairesCumules : t_tableNbSolitaires);
var i,k,sum : SInt32;
begin
  LecturePreparatoireDossierDatabase(pathCassioFolder,'ConstruitTableNbSolitairesCumules');

  for k := -1 to 65 do
    begin
      tableNbSolitaires[k] := 0;
      tableNbSolitairesCumules[k] := 0;
    end;

  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if (fichiers[i].typeDonnees = kFicSolitairesNouveauFormat) then
        begin
          k := NbCasesVidesDeCeFichierSolitairesNouveauFormat(i);
          if (k >= 1) and (k <= 64) and SolitairesDemandes[k]
            then tableNbSolitaires[k] := tableNbSolitaires[k] + NbSolitairesDansFichierSolitairesNouveauFormat(i);
        end;

  sum := 0;
  for k := -1 to 65 do
    begin
      sum := sum + tableNbSolitaires[k];
      tableNbSolitairesCumules[k] := sum;
    end;

end;



function NbSolitairesDansCetteIntervalleDeCasesVides(nbCasesMin,nbCasesMax : SInt16) : SInt32;
var tableNbSolitaires : t_tableNbSolitaires;
    tableNbSolitairesCumules : t_tableNbSolitaires;
    temp : SInt32;
begin
  if (nbCasesMin < 1) then nbCasesMin := 1;
  if (nbCasesMin > 64) then nbCasesMin := 64;
  if (nbCasesMax < 1) then nbCasesMax := 1;
  if (nbCasesMax > 64) then nbCasesMax := 64;
  if (nbCasesMin > nbCasesMax) then
    begin
      temp := nbCasesMax;
      nbCasesMax := nbCasesMin;
      nbCasesMin := temp;
    end;

  LecturePreparatoireDossierDatabase(pathCassioFolder,'NbSolitairesDansCetteIntervalleDeCasesVides');

  ConstruitTableNbSolitairesCumules(tableNbSolitaires,tableNbSolitairesCumules);

  NbSolitairesDansCetteIntervalleDeCasesVides := tableNbSolitairesCumules[nbCasesMax] - tableNbSolitairesCumules[nbCasesMin-1];
end;


procedure DoJoueAuxSolitairesNouveauFormat(nbCasesMin,nbCasesMax : SInt16);
var tableNbSolitaires : t_tableNbSolitaires;
    tableNbSolitairesCumules : t_tableNbSolitaires;
    i,k,interv,temp,sum,oldSum : SInt32;
    nbCasesVides,numeroFichier,numeroSolitaireDansFichier : SInt32;
    s : String255;
    error : OSErr;
    theSolitaire : t_SolitaireRecNouveauFormat;
    nbSolitairesEntreOrdinateursTrouves : SInt32;
    solitaireEstRejete : boolean;
begin
  with InfosFichiersNouveauFormat do
    begin

		  if (nbCasesMin < 1) then nbCasesMin := 1;
		  if (nbCasesMin > 64) then nbCasesMin := 64;
		  if (nbCasesMax < 1) then nbCasesMax := 1;
		  if (nbCasesMax > 64) then nbCasesMax := 64;
		  if (nbCasesMin > nbCasesMax) then
		    begin
		      temp := nbCasesMax;
		      nbCasesMax := nbCasesMin;
		      nbCasesMin := temp;
		    end;

		  nbSolitairesEntreOrdinateursTrouves := 0;
		  solitaireEstRejete := false;

		  LecturePreparatoireDossierDatabase(pathCassioFolder,'DoJoueAuxSolitairesNouveauFormat');

		  if not(JoueursEtTournoisEnMemoire) then DoLectureJoueursEtTournoi(false);

		  ConstruitTableNbSolitairesCumules(tableNbSolitaires,tableNbSolitairesCumules);

		  (*
		  for k := 0 to 64 do
		    begin
		      WriteNumDansRapport('nb_sol['+IntToStr(k)+'] = ',tableNbSolitaires[k]);
		      WritelnNumDansRapport('   cumule['+IntToStr(k)+'] = ',tableNbSolitairesCumules[k]);
		    end;
		  for k := nbCasesMin to nbCasesMax do
		    begin
		      WriteNumDansRapport('nb_sol['+IntToStr(k)+'] = ',tableNbSolitaires[k]);
		      WritelnNumDansRapport('   cumule['+IntToStr(k)+'] = ',tableNbSolitairesCumules[k]);
		    end;
		  *)



		  interv := NbSolitairesDansCetteIntervalleDeCasesVides(nbCasesMin,nbCasesMax);

		  (*
		  WritelnNumDansRapport('interv = ',interv);
		  WritelnNumDansRapport('nbCasesMax = ',nbCasesMax);
		  WritelnNumDansRapport('nbCasesMax = ',nbCasesMax);
		  *)

		  if interv > 0 then
		    repeat
				  RandomizeTimer;

				  k := 1 + ((Abs(Random32())) mod interv);
				  {k := interv;}
				  {k := 1;}

				  k := k + tableNbSolitairesCumules[nbCasesMin - 1];

				  nbCasesVides := -1;
				  numeroFichier := -1;
				  numeroSolitaireDansFichier := -1;

				  {trouvons le nb de cases vides du k-ieme solitaire}
				  for i := 0 to 64 do
				    if (tableNbSolitairesCumules[i-1] < k) and (tableNbSolitairesCumules[i] >= k) then
				      begin
				        nbCasesVides := i;
				        leave;
				      end;

				  if (nbCasesVides >= 1) and (nbCasesVides <= 64) then
				    begin
						  {trouvons a quel numero de fichier correspond le k-ieme solitaire}
						  sum := tableNbSolitairesCumules[nbCasesVides-1];

				      for i := 1 to nbFichiers do
				        if (fichiers[i].typeDonnees = kFicSolitairesNouveauFormat) and
				           (NbCasesVidesDeCeFichierSolitairesNouveauFormat(i) = nbCasesVides) then
                  begin
                    oldSum := sum;
                    sum := sum + NbSolitairesDansFichierSolitairesNouveauFormat(i);
                    if (oldSum < k) and (sum >= k) then
                      begin
                        numeroFichier := i;
                        numeroSolitaireDansFichier := k - oldSum;
                        leave;
                      end;
				          end;
						end;


			    if (nbCasesVides >= 1) and (numeroFichier >= 1) and (numeroFichier <= nbFichiers) and (numeroSolitaireDansFichier >= 1) and
			       (NbCasesVidesDeCeFichierSolitairesNouveauFormat(numeroFichier) = nbCasesVides) then
			      begin
			        {WritelnNumDansRapport('nbCasesVides = ',nbCasesVides);
			        WritelnNumDansRapport('numeroFichier = ',numeroFichier);
			        WritelnNumDansRapport('numeroSolitaireDansFichier = ',numeroSolitaireDansFichier);}

			        error := OuvreFichierNouveauFormat(numeroFichier);
			        {WritelnNumDansRapport('error = ',error);}
			        error := LitSolitaireNouveauFormat(fichiers[numeroFichier].refNum,numeroSolitaireDansFichier,theSolitaire);
			        {WritelnNumDansRapport('error = ',error);}
			        error := FermeFichierNouveauFormat(numeroFichier);
			        {WritelnNumDansRapport('error = ',error);}

			        solitaireEstRejete := false;
			        if eviterSolitairesOrdinateursSVP and SolitaireEstEntreDeuxOrdinateurs(theSolitaire) then
			          begin
			            inc(nbSolitairesEntreOrdinateursTrouves);
			            solitaireEstRejete := (nbSolitairesEntreOrdinateursTrouves <= 10);
			            {si on trouve dix solitaires entre ordinateurs a la suite,
			             c'est qu'il n'y a sans doute que ca dans le fichier...
			             Dans ce cas, au onzieme, on ne respecte pas la
			             preference 'eviterSolitairesOrdinateursSVP' }
			          end;

			        if not(solitaireEstRejete) then
			          begin
					        s := FabriqueChainePositionSolitaireNouveauFormat(theSolitaire) + FabriqueCommentaireSolitaireNouveauFormat(theSolitaire);
					        {WritelnDansRapport('s = '+s);}
					        PlaquerSolitaire(s);
					      end;

			      end;

			 until not(solitaireEstRejete);
  end;

end;




END.
