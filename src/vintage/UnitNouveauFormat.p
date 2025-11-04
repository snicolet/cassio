UNIT UnitNouveauFormat;



INTERFACE







 USES UnitDefCassio;




{Initialisation et destruction}
procedure InitUnitNouveauFormat;
procedure LibereMemoireUnitNouveauFormat;
function PathDuDossierDatabase : String255;

{Lecture des donnees sur le disque}
function OuvreFichierNouveauFormat(numFichier : SInt16) : OSErr;
function LitPartieNouveauFormat(numFichier : SInt16; nroPartie : SInt64; enAvancant : boolean; var theGame : t_PartieRecNouveauFormat) : OSErr;
function LitJoueurNouveauFormat(numFichier : SInt16; nroJoueur : SInt64; var joueur : String255) : OSErr;
function LitTournoiNouveauFormat(numFichier : SInt16; nroTournoi : SInt64; var tournoi : String255) : OSErr;
function LitEnteteNouveauFormat(refnum : SInt16; var entete : t_EnTeteNouveauFormat) : OSErr;
function FermeFichierNouveauFormat(numFichier : SInt16) : OSErr;

{Ecriture des donnees sur disque}
procedure MettreDateDuJourDansEnteteFichierNouveauFormat(var entete : t_EnTeteNouveauFormat);
function EcritEnteteNouveauFormat(refnum : SInt16; entete : t_EnTeteNouveauFormat) : OSErr;
function EcritPartieNouveauFormat(refnum : SInt16; nroPartie : SInt64; theGame : t_PartieRecNouveauFormat) : OSErr;
function EcritJoueurNouveauFormat(refnum : SInt16; nroJoueur : SInt64; thePlayer : t_JoueurRecNouveauFormat) : OSErr;
function EcritTournoiNouveauFormat(refnum : SInt16; nroTournoi : SInt64; theTourney : t_TournoiRecNouveauFormat) : OSErr;

{Gestion de la memoire}
function AllocateMemoireIndexNouveauFormat(var nbParties : SInt64) : OSErr;
function AllocateMemoireListePartieNouveauFormat(var nbParties : SInt64) : OSErr;
function AllocateMemoireJoueursNouveauFormat(var nbJoueurs : SInt64) : OSErr;
function AllocateMemoireTournoisNouveauFormat(var nbTournois : SInt64) : OSErr;
procedure DisposeIndexNouveauFormat;
procedure DisposeListePartiesNouveauFormat;
procedure DisposeJoueursNouveauFormat;
procedure DisposeTournoisNouveauFormat;


{Fonctions de comptage}
function NbPartiesFichierNouveauFormat(numFichier : SInt16) : SInt64;
function AnneePartiesFichierNouveauFormat(numFichier : SInt16) : SInt16;
function NbJoueursDansFichierJoueursNouveauFormat(numFichier : SInt16) : SInt64;
function NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersJoueurs,placeMemoireNecessaire : SInt64) : SInt64;
function NbTournoisDansFichierTournoisNouveauFormat(numFichier : SInt16) : SInt64;
function NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersTournois,placeMemoireNecessaire : SInt64) : SInt64;
function NbTotalPartiesDansDistributionSet(ensemble : DistributionSet) : SInt64;
function TailleTheoriqueDeCeFichierNouveauFormat(numFichier : SInt16) : SInt64;


{Fonctions de lecture recursive du dossier Database}
procedure LecturePreparatoireDossierDatabase(pathDossierEnglobant : String255; fonctionAppelante : String255);
procedure ChercheFichiersNouveauFormatDansDossier(vRefNum : SInt16; NomDossier : String255; var dossierTrouve : boolean);
function CalculePathFichierNouveauFormat(nroFichier : SInt16) : String255;
function CalculeNomFichierNouveauFormat(nroFichier : SInt16) : String255;
function GetNroPremierFichierAvecCeTypeDeDonnees(CeTypeDeDonnees : SInt16) : SInt16;
function GetNroPremierFichierAvecCeNom(nom : String255) : SInt16;
function GetNroPremierFichierAvecCetteDistribution(distribution : String255) : SInt16;
function GetNroDUnFichierDansLaMemeDistribution(nomFichier : String255) : SInt16;
function FichierWTHORJOUDejaTrouve : boolean;


{ fonctions d'ajout d'un fichier dans le dossier database }
function AjouterFichierDansLeDossierDatabase(nomAAjouter : String255; var fichierACopier : basicfile) : OSErr;
function RemplacerFichierDansLeDossierDatabaseParFichier(nomARemplacer : String255; var fichierACopier : basicfile) : OSErr;
function AjouterFichierNouveauFormat(fic : fileInfo; path : String255; typeDonneesDuFichier : SInt16; EnteteFichier : t_EnTeteNouveauFormat) : boolean;


{Fonctions de test}
function EstUnFichierNouveauFormat(fic : fileInfo; var typeDonnees : SInt16; var entete : t_EnTeteNouveauFormat) : boolean;
function EntetesEgauxNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
function EntetePlusRecentNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;


{Gestion des distributions}
function EstUneDistributionConnue(nomTest,pathTest : String255; var nroDistrib : SInt16) : boolean;
function NomDistributionAssocieeNouveauFormat(ficName : String255; var anneeDansDistrib : SInt16) : String255;
function TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(nroFichier : SInt16) : DistributionSet;
procedure AjouterDistributionNouveauFormat(nomDistr,pathDistr : String255; typeDistribution : SInt16);
function EcourteNomDistributionNouveauFormat(nomLong : String255) : String255;
procedure SetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16; decalage : SInt64);
function  GetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16) : SInt64;
procedure SetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16; decalage : SInt64);
function  GetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16) : SInt64;


{types des distributions}
procedure SetTypeDonneesDistribution(nroDistrib,typeDonnees : SInt16);
function GetTypeDonneesDistribution(nroDistrib : SInt16) : SInt16;
function EstUneDistributionDeParties(nroDistrib : SInt16) : boolean;
function EstUneDistributionDeSolitaires(nroDistrib : SInt16) : boolean;


{Tris divers}
procedure TrierListeFichiersNouveauFormat;
procedure TrierAlphabetiquementJoueursNouveauFormat;
procedure TrierAlphabetiquementTournoisNouveauFormat;


{Ajout d'un nom de joueur ou de tournoi dans la liste en memoire}
procedure AjouterJoueurEnMemoire(joueur : String255; numeroEnMemoire,numeroDansSonFichier : SInt64);
procedure AjouterTournoiEnMemoire(tournoi : String255; numeroEnMemoire,numeroDansSonFichier : SInt64);


{Lecture et gestion des fichiers de joueurs}
function MetJoueursNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
function LitNomsDesJoueursEnJaponais : OSErr;
function CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
function EcritFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
function LitFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
procedure EffaceTousLesNomsCourtsDesJoueurs;


{Lecture et gestion des fichiers de tournois}
function MetJoueursEtTournoisEnMemoire(nomsAbreges : boolean) : OSErr;
function MetTournoisNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
function LitNomsDesTournoisEnJaponais : OSErr;
function CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
function EcritFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
function LitFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;



{Fichiers d'index de parties}
function IndexerFichierPartiesEnMemoireNouveauFormat(numFichierParties : SInt16) : OSErr;
function EcritFichierIndexNouveauFormat(numFichierParties : SInt16) : OSErr;
function LitFichierIndexNouveauFormat(numFichierIndex : SInt16) : OSErr;
function NomFichierIndexAssocieNouveauFormat(ficName : String255) : String255;
procedure EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
procedure IndexerLesFichiersNouveauFormat;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Aliases, MacErrors, UnitDebuggage, Sound, fp, OSUtils, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , SNEvents, UnitServicesRapport
    , MyQuickDraw, UnitSolitairesNouveauFormat, UnitImportDesNoms, UnitAccesNouveauFormat, UnitServicesDialogs, UnitATR, UnitSound, MyMathUtils
    , UnitCurseur, basicfile, UnitGeneralSort, MyFileSystemUtils, UnitPrefs, UnitTestNouveauFormat, UnitRapport, MyStrings
    , UnitNormalisation, SNEvents, UnitStringSet, UnitServicesMemoire, UnitEnvirons ;
{$ELSEC}
    ;
    {$I prelink/NouveauFormat.lk}
{$ENDC}


{END_USE_CLAUSE}










const CapaciteBufferParties = 2000;
      CapaciteBufferJoueurs = 1000;
      CapaciteBufferTournois = 1000;


var pathToDataBase : String255;
    nroDernierFichierOuvertNF : SInt16;

    bufferLecturePartiesNF : array[0..CapaciteBufferParties] of t_PartieRecNouveauFormat;
    nroDernierFichierPartiesLuNF : SInt16;
    nroDernierePartieLueNF : SInt64;
    premierePartieDansBufferNF : SInt64;
    dernierePartieDansBufferNF : SInt64;

    bufferLectureJoueursNF : array[0..CapaciteBufferJoueurs] of t_JoueurRecNouveauFormat;
    nroDernierFichierJoueursLuNF : SInt16;
    nroDernierJoueurLuNF : SInt64;
    premierJoueurDansBufferNF : SInt64;
    dernierJoueurDansBufferNF : SInt64;

    bufferLectureTournoisNF : array[0..CapaciteBufferTournois] of t_TournoiRecNouveauFormat;
    nroDernierFichierTournoisLuNF : SInt16;
    nroDernierTournoiLuNF : SInt64;
    premierTournoiDansBufferNF : SInt64;
    dernierTournoiDansBufferNF : SInt64;

    gDernierTickDansTraiteNouveauFormat : SInt64;
    nbAppelsShareTimeWithOtherProcesses : SInt64;
    pendantLecturePreparatoireDossierDatabase : boolean;



procedure InitUnitNouveauFormat;
var i : SInt64;
begin

  DistributionsNouveauFormat.nbDistributions := 0;
  for i := 1 to nbMaxDistributions do
    with DistributionsNouveauFormat.Distribution[i] do
    begin
       name                           := NIL;
       path                           := NIL;
       nomUsuel                       := NIL;
       typeDonneesDansDistribution    := kUnknownDataNouveauFormat;
       decalageNrosJoueurs            := 0;
       decalageNrosTournois           := 0;
    end;

  InfosFichiersNouveauFormat.nbFichiers := 0;
  for i := 1 to nbMaxFichiersNouveauFormat do
    with InfosFichiersNouveauFormat.fichiers[i] do
      begin
        open            := false;
        nomFichier      := NIL;
        pathFichier     := NIL;
        refNum          := 0;
        vRefNum         := 0;
        parID           := 0;
        NroDistribution := 0;
        Annee           := 0;
        typeDonnees     := kUnknownDataNouveauFormat;
        NroFichierDual  := 0;
        MemoryFillChar(@entete,TailleEnTeteNouveauFormat,chr(0));
      end;

  pendantLecturePreparatoireDossierDatabase := false;

  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      indexNoir := NIL;
      indexBlanc := NIL;
      indexOuverture := NIL;
      indexTournoi := NIL;
    end;

  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      listeParties := NIL;
    end;

  with JoueursNouveauFormat do
    begin
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeJoueurs := NIL;
    end;

  with TournoisNouveauFormat do
    begin
      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeTournois := NIL;
    end;

  nroDernierFichierOuvertNF := 0;

  nroDernierFichierPartiesLuNF := 0;
  nroDernierePartieLueNF := -1;
  premierePartieDansBufferNF := -1;
  dernierePartieDansBufferNF := -1;

  nroDernierFichierJoueursLuNF := 0;
  nroDernierJoueurLuNF := -1;
  premierJoueurDansBufferNF := -1;
  dernierJoueurDansBufferNF := -1;

  nroDernierFichierTournoisLuNF := 0;
  nroDernierTournoiLuNF := -1;
  premierTournoiDansBufferNF := -1;
  dernierTournoiDansBufferNF := -1;

  ChoixDistributions.genre := kToutesLesDistributions;
  ChoixDistributions.DistributionsALire := [];

  pathToDataBase := '';

  gMettreAJourParInternetTOUSLesFichiersWThor := false;
end;



function AllocateMemoireIndexNouveauFormat(var nbParties : SInt64) : OSErr;
begin
  AllocateMemoireIndexNouveauFormat := NoErr;
  DisposeIndexNouveauFormat;
  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      indexNoir     := indexArrayPtr(AllocateMemoryPtr(nbParties+20));  {+20 = pied de pilote :-) }
      indexBlanc    := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      indexOuverture := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      indexTournoi  := indexArrayPtr(AllocateMemoryPtr(nbParties+20));
      if (indexNoir <> NIL) and (indexBlanc <> NIL) and (indexOuverture <> NIL) and (indexTournoi <> NIL)
        then tailleIndex := nbParties
        else
          begin
            nbParties := 0;
            AllocateMemoireIndexNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireListePartieNouveauFormat(var nbParties : SInt64) : OSErr;
begin
  AllocateMemoireListePartieNouveauFormat := NoErr;
  DisposeListePartiesNouveauFormat;
  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      listeParties := tablePartiesNouveauFormatPtr(AllocateMemoryPtr((nbParties+2)*TaillePartieRecNouveauFormat));
      if listeParties <> NIL
        then nbPartiesEnMemoire := nbParties
        else
          begin
            nbParties := 0;
            AllocateMemoireListePartieNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireJoueursNouveauFormat(var nbJoueurs : SInt64) : OSErr;
var i,count : SInt64;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Entrée dans AllocateMemoireJoueursNouveauFormat',true);

  AllocateMemoireJoueursNouveauFormat := NoErr;
  DisposeJoueursNouveauFormat;
  with JoueursNouveauFormat do
    begin
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      count := sizeof(JoueursNouveauFormatRec);
      count := count*(nbJoueurs+2);
      listeJoueurs := tableJoueursNouveauFormatPtr(AllocateMemoryPtr(count));
      if listeJoueurs <> NIL
        then
          begin
            nbJoueursNouveauFormat := nbJoueurs;
            for i := 0 to nbJoueursNouveauFormat-1 do
              begin
                JoueurArrow := POINTER_ADD(listeJoueurs , i*sizeof(JoueursNouveauFormatRec));
                JoueurArrow^.nomJaponais              := NIL;
                JoueurArrow^.numeroDansFichierJoueurs := -1;
                JoueurArrow^.numeroFFO                := -1;
                JoueurArrow^.anneePremierePartie      := -1;
                JoueurArrow^.anneeDernierePartie      := -1;
                JoueurArrow^.classementData           := -1;
              end;
          end
        else
          begin
            nbJoueurs := 0;
            AllocateMemoireJoueursNouveauFormat := -1;
          end;
    end;
end;

function AllocateMemoireTournoisNouveauFormat(var nbTournois : SInt64) : OSErr;
var i : SInt64;
    TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  AllocateMemoireTournoisNouveauFormat := NoErr;
  DisposeTournoisNouveauFormat;
  with TournoisNouveauFormat do
    begin
      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      listeTournois := tableTournoisNouveauFormatPtr(AllocateMemoryPtr((nbTournois+2)*sizeof(TournoisNouveauFormatRec)));
      if listeTournois <> NIL
        then
          begin
            nbTournoisNouveauFormat := nbTournois;
            for i := 0 to nbTournoisNouveauFormat-1 do
              begin
                TournoiArrow := POINTER_ADD(listeTournois , i*sizeof(TournoisNouveauFormatRec));
                TournoiArrow^.nomJaponais := NIL;
                TournoiArrow^.numeroDansFichierTournois := -1;
              end;
          end
        else
          begin
            nbTournois := 0;
            AllocateMemoireTournoisNouveauFormat := -1;
          end;
    end;
end;

procedure DisposeIndexNouveauFormat;
begin
  with IndexNouveauFormat do
    begin
      tailleIndex := 0;
      if indexNoir <> NIL then DisposeMemoryPtr(ptr(indexNoir));
      if indexBlanc <> NIL then DisposeMemoryPtr(ptr(indexBlanc));
      if indexOuverture <> NIL then DisposeMemoryPtr(ptr(indexOuverture));
      if indexTournoi <> NIL then DisposeMemoryPtr(ptr(indexTournoi));
      indexNoir := NIL;
      indexBlanc := NIL;
      indexOuverture := NIL;
      indexTournoi := NIL;
    end;
end;

procedure DisposeListePartiesNouveauFormat;
begin
  with PartiesNouveauFormat do
    begin
      nbPartiesEnMemoire := 0;
      if listeParties <> NIL then DisposeMemoryPtr(Ptr(listeParties));
      listeParties := NIL;
    end;
end;


procedure DisposeJoueursNouveauFormat;
var i : SInt64;
    JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
	  begin
      if listeJoueurs <> NIL then
	      for i := 0 to nbJoueursNouveauFormat-1 do
	        begin
	          JoueurArrow := POINTER_ADD(listeJoueurs , i*sizeof(JoueursNouveauFormatRec));
	          if JoueurArrow^.nomJaponais <> NIL then
	            begin
	              DisposeMemoryHdl(Handle(JoueurArrow^.nomJaponais));
	              JoueurArrow^.nomJaponais := NIL;
	            end;
	        end;
      nbJoueursNouveauFormat := 0;
      plusLongNomDeJoueur := 0;
      nombreJoueursDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      if listeJoueurs <> NIL then DisposeMemoryPtr(Ptr(listeJoueurs));
      listeJoueurs := NIL;
	  end;
end;


procedure DisposeTournoisNouveauFormat;
var i : SInt64;
    TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
    begin

      if listeTournois <> NIL then
	      for i := 0 to nbTournoisNouveauFormat-1 do
	        begin
	          TournoiArrow := POINTER_ADD(listeTournois , i*sizeof(TournoisNouveauFormatRec));
	          if TournoiArrow^.nomJaponais <> NIL then
	            begin
	              DisposeMemoryHdl(Handle(TournoiArrow^.nomJaponais));
	              TournoiArrow^.nomJaponais := NIL;
	            end;
	        end;

      nbTournoisNouveauFormat := 0;
      nombreTournoisDansBaseOfficielle := 0;
      dejaTriesAlphabetiquement := false;
      if listeTournois <> NIL then DisposeMemoryPtr(Ptr(listeTournois));
      listeTournois := NIL;
    end;
end;



procedure LibereMemoireUnitNouveauFormat;
var i : SInt64;
begin

  for i := 1 to nbMaxDistributions do
    with DistributionsNouveauFormat.Distribution[i] do
    begin
       if name     <> NIL then DisposeMemoryPtr(Ptr(name));
       if path     <> NIL then DisposeMemoryPtr(Ptr(path));
       if nomUsuel <> NIL then DisposeMemoryPtr(Ptr(nomUsuel));
       name     := NIL;
       path     := NIL;
       nomUsuel := NIL;
    end;

  for i := 1 to nbMaxFichiersNouveauFormat do
    with InfosFichiersNouveauFormat.fichiers[i] do
      begin
        if nomFichier <> NIL then DisposeMemoryPtr(Ptr(nomFichier));
        if pathFichier <> NIL then DisposeMemoryPtr(Ptr(pathFichier));
        nomfichier := NIL;
        pathFichier := NIL;
      end;

  DisposeIndexNouveauFormat;
  DisposeListePartiesNouveauFormat;
  DisposeJoueursNouveauFormat;
  DisposeTournoisNouveauFormat;

end;


function PathDuDossierDatabase : String255;
begin
  PathDuDossierDatabase := pathToDataBase;
end;


function CalculePathFichierNouveauFormat(nroFichier : SInt16) : String255;
var s : String255;
begin
  s := '';
  with InfosFichiersNouveauFormat,DistributionsNouveauFormat do
    if (nroFichier > 0) and (nroFichier <= nbFichiers) then
      begin
        with fichiers[nroFichier] do
          if (typeDonnees = kFicPartiesNouveauFormat) or
             (typeDonnees = kFicIndexPartiesNouveauFormat)
            then
              begin
                if distribution[nroDistribution].path <> NIL then
                  s := distribution[nroDistribution].path^
              end
            else
              begin
                if pathFichier <> NIL then
                  s := pathFichier^;
              end;
      end;
  CalculePathFichierNouveauFormat := s;
end;


function CalculeNomFichierNouveauFormat(nroFichier : SInt16) : String255;
var posXXXX : SInt16;
    s : String255;
begin
  s := '';
  with InfosFichiersNouveauFormat,DistributionsNouveauFormat do
    if (nroFichier > 0) and (nroFichier <= nbFichiers) then
      begin
        with fichiers[nroFichier] do
          if (typeDonnees = kFicPartiesNouveauFormat) or
             (typeDonnees = kFicIndexPartiesNouveauFormat)
            then
              begin
                s := distribution[nroDistribution].name^;
                posXXXX := Pos('XXXX',s);
                if posXXXX > 0 then
                  begin
                    Delete(s,posXXXX,4);
                    Insert(IntToStr(annee), s, posXXXX);
                  end;
                if typeDonnees = kFicIndexPartiesNouveauFormat then s := NomFichierIndexAssocieNouveauFormat(s);
              end
            else
              begin
                if nomFichier <> NIL then
                  s := nomFichier^;
              end;
      end;
  CalculeNomFichierNouveauFormat := s;
end;

function NomDistributionAssocieeNouveauFormat(ficName : String255; var anneeDansDistrib : SInt16) : String255;
var nom,upCaseName : String255;
    positionPoint,i : SInt16;
    anneeLong : SInt64;
    c : char;
begin
  nom := ficName;
  upCaseName := sysutils.UpperCase(nom);
  anneeDansDistrib := 0;

  positionPoint := Pos('.INDEX',upCaseName);
  if positionPoint > 0 then
    begin
      upCaseName := LeftStr(upcaseName,positionPoint-1)+'.WTB';
      nom := LeftStr(nom,positionPoint-1)+'.WTB';
    end;

  positionPoint := Pos('.PZZ',upCaseName);
  if positionPoint > 0 then
    begin

      { Les lignes suivantes exhibent un BUG de CodeWarrior !!!! }
      {
      if (nom[positionPoint-1] >= '0') and (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      if (nom[positionPoint-1] >= '0') and (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      if (nom[positionPoint-1] >= '0') and (nom[positionPoint-1] <= '9') then positionPoint := positionPoint-1;
      }

      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;
      c := nom[positionPoint-1];
      if IsDigit(c) then positionPoint := positionPoint-1;

      nom := LeftStr(nom,positionPoint-1)+'.pzz';
    end;

  positionPoint := Pos('.WTB',upCaseName);
	if (positionPoint > 0)      and
		 IsDigit(nom[positionPoint-4]) and
     IsDigit(nom[positionPoint-3]) and
     IsDigit(nom[positionPoint-2]) and
     IsDigit(nom[positionPoint-1]) then
       begin
		     StrToInt32(TPCopy(nom,positionPoint-4,4),anneeLong);
		     anneeDansDistrib := anneelong;
		     for i := positionPoint-4 to positionPoint-1 do nom[i] := 'X';
		     if nom[positionPoint+1] = 'W' then nom[positionPoint+1] := 'w';
		     if nom[positionPoint+2] = 'T' then nom[positionPoint+2] := 't';
		     if nom[positionPoint+3] = 'B' then nom[positionPoint+3] := 'b';
		   end;

  NomDistributionAssocieeNouveauFormat := nom;

end;


function TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(nroFichier : SInt16) : DistributionSet;
var pathOfFile,nameOfFile,bidstr : String255;
    numDistrib : SInt16;
    result  : DistributionSet;
begin
  TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := [];
  result := [];

  with InfosFichiersNouveauFormat , DistributionsNouveauFormat do
    if (nroFichier >= 1) and (nroFichier <= nbFichiers) then
      begin
        if fichiers[nroFichier].nroDistribution > 0
          then TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := [fichiers[nroFichier].nroDistribution]
          else
            begin
              nameOfFile := CalculeNomFichierNouveauFormat(nroFichier);
              Split(nameOfFile,'.',nameOfFile,bidstr);
              EnleveEspacesDeGaucheSurPlace(nameOfFile);
              EnleveEspacesDeDroiteSurPlace(nameOfFile);
              pathOfFile := CalculePathFichierNouveauFormat(nroFichier);

              {d'abord on cherche une distribution dont le nom correspondant exactement, dans le meme dossier}
              for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].name <> NIL) and (Pos(nameOfFile,distribution[numDistrib].name^) > 0) and
					         (distribution[numDistrib].path <> NIL) and (pathOfFile = distribution[numDistrib].path^) then
					        result := result+[numDistrib];

					    {si pas trouve, on cherche une distribution dans le meme dossier}
					    for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].path <> NIL) and (pathOfFile = distribution[numDistrib].path^) then
					        result := result+[numDistrib];

					    {si toujours pas trouve, on cherche une distribution dont le nom est proche}
					    for numDistrib := 1 to nbDistributions do
					      if (distribution[numDistrib].name <> NIL) and (Pos(nameOfFile,distribution[numDistrib].name^) > 0) then
					        result := result+[numDistrib];

					    TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat := result;
            end;
      end;
end;


function NomFichierIndexAssocieNouveauFormat(ficname : String255) : String255;
var upCaseName : String255;
    positionPoint : SInt16;
begin
  upCaseName := sysutils.UpperCase(ficname);
  positionPoint := Pos('.WTB',upCaseName);
  if positionPoint > 0
    then NomFichierIndexAssocieNouveauFormat := LeftStr(ficname,positionPoint-1)+'.index'
    else NomFichierIndexAssocieNouveauFormat := ficname+'.index';
end;


function LitEnteteNouveauFormat(refnum : SInt16; var entete : t_EnTeteNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  MemoryFillChar(@entete,TailleEnTeteNouveauFormat,char(0));
  codeErreur := MyFSReadAt(refnum,0,TailleEnTeteNouveauFormat,@entete);
  if codeErreur = 0 then
    with entete do
      begin
        {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
        SWAP_LONGINT( @NombreEnregistrementsParties);
        SWAP_INTEGER( @NombreEnregistrementsTournoisEtJoueurs );
        SWAP_INTEGER( @AnneeParties );
        {$ENDC}
      end;
  LitEnteteNouveauFormat := codeErreur;
end;


procedure MettreDateDuJourDansEnteteFichierNouveauFormat(var entete : t_EnTeteNouveauFormat);
var myDate : DateTimeRec;
begin
   GetTime(myDate);
   entete.SiecleCreation  := myDate.year div 100;
   entete.AnneeCreation   := myDate.year mod 100;
   entete.MoisCreation    := myDate.month;
   entete.JourCreation    := myDate.day;
end;


function EcritEnteteNouveauFormat(refnum : SInt16; entete : t_EnTeteNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  with entete do
    begin
      {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
      SWAP_LONGINT( @NombreEnregistrementsParties);
      SWAP_INTEGER( @NombreEnregistrementsTournoisEtJoueurs);
      SWAP_INTEGER( @AnneeParties);
      {$ENDC}
    end;
  codeErreur := MyFSWriteAt(refnum,FSFromStart,0,TailleEnTeteNouveauFormat,@entete);
  EcritEnteteNouveauFormat := codeErreur;
end;


function EcritPartieNouveauFormat(refnum : SInt16; nroPartie : SInt64; theGame : t_PartieRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  with theGame do
		begin
		  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
		  SWAP_INTEGER( @nroTournoi);
		  SWAP_INTEGER( @nroJoueurNoir);
		  SWAP_INTEGER( @nroJoueurBlanc);
		  {$ENDC}
		end;
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+pred(nroPartie)*TaillePartieRecNouveauFormat,TaillePartieRecNouveauFormat,@theGame);
  EcritPartieNouveauFormat := codeErreur;
end;


function EcritJoueurNouveauFormat(refnum : SInt16; nroJoueur : SInt64; thePlayer : t_JoueurRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+nroJoueur*TailleJoueurRecNouveauFormat,TailleJoueurRecNouveauFormat,@thePlayer);
  EcritJoueurNouveauFormat := codeErreur;
end;


function EcritTournoiNouveauFormat(refnum : SInt16; nroTournoi : SInt64; theTourney : t_TournoiRecNouveauFormat) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := MyFSWriteAt(refnum,FSFromStart,TailleEnTeteNouveauFormat+nroTournoi*TailleTournoiRecNouveauFormat,TailleTournoiRecNouveauFormat,@theTourney);
  EcritTournoiNouveauFormat := codeErreur;
end;


function EstUneDistributionConnue(nomTest,pathTest : String255; var nroDistrib : SInt16) : boolean;
var i : SInt16;
begin
  EstUneDistributionConnue := false;
  nroDistrib := 0;

  nomTest  := sysutils.UpperCase(nomTest);
  pathTest := sysutils.UpperCase(pathTest);

  with DistributionsNouveauFormat do
    for i := 1 to nbDistributions do
      if (sysutils.UpperCase(Distribution[i].name^) = nomTest) and
         (sysutils.UpperCase(Distribution[i].path^) = pathTest) then
        begin
          EstUneDistributionConnue := true;
          nroDistrib := i;
          exit;
        end;
end;


procedure SetTypeDonneesDistribution(nroDistrib,typeDonnees : SInt16);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions) then
      Distribution[nroDistrib].typeDonneesDansDistribution := typeDonnees;
end;

function GetTypeDonneesDistribution(nroDistrib : SInt16) : SInt16;
begin
  GetTypeDonneesDistribution := kUnknownDataNouveauFormat;
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions) then
      GetTypeDonneesDistribution := Distribution[nroDistrib].typeDonneesDansDistribution;
end;

function EstUneDistributionDeParties(nroDistrib : SInt16) : boolean;
begin
  EstUneDistributionDeParties := GetTypeDonneesDistribution(nroDistrib) = kFicPartiesNouveauFormat;
end;

function EstUneDistributionDeSolitaires(nroDistrib : SInt16) : boolean;
begin
  EstUneDistributionDeSolitaires := GetTypeDonneesDistribution(nroDistrib) = kFicSolitairesNouveauFormat;
end;

function FichierWTHORJOUDejaTrouve : boolean;
var k : SInt64;
begin
  FichierWTHORJOUDejaTrouve :=false;
  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
    with InfosFichiersNouveauFormat.fichiers[k] do
      begin
        if (typeDonnees = kFicJoueursNouveauFormat) and
           (nomFichier <> NIL) and (sysutils.UpperCase(nomFichier^) =  'WTHOR.JOU') then
           begin
             FichierWTHORJOUDejaTrouve := true;
             exit;
           end;
      end;
end;


procedure AjouterDistributionNouveauFormat(nomDistr,pathDistr : String255; typeDistribution : SInt16);
var bidon,nbUnderscoreEnleves : SInt16;
    s : String255;
begin

  if not(EstUneDistributionConnue(nomDistr,pathDistr,bidon)) then
	 with DistributionsNouveauFormat do
	  if nbDistributions < nbMaxDistributions then
	    begin
	      nbDistributions := succ(nbDistributions);

	      {
	      WritelnDansRapport('Dans AjouterDistributionNouveauFormat :');
	      WritelnDansRapport('  nomDistr = '+nomDistr);
        WritelnDansRapport('  pathDistr = '+pathDistr);
        WritelnDansRapport('');
        }

	      { fabriquons le nom "usuel" de la distribution (celui que l'on affichera) }
        s := nomDistr;
        s := EcourteNomDistributionNouveauFormat(s);
        s := EnleveEspacesDeDroite(s);
        EnleveEtCompteCeCaractereADroite(s,'_',nbUnderscoreEnleves);
        if sysutils.UpperCase(s) = 'WTH' then
          begin
            s := 'WThor';
            nroDistributionWThor := nbDistributions;
          end;

	      { stocker les infos }
	      with Distribution[nbDistributions] do
	        begin
	          name      := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
	          path      := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
	          nomUsuel  := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
	          name^     := nomDistr;
	          path^     := pathDistr;
	          nomUsuel^ := s;
	          typeDonneesDansDistribution := typeDistribution;
	          decalageNrosJoueurs := 0;
	          decalageNrosTournois := 0;
	        end;
	    end
	  else
	    begin
	      WritelnDansRapportThreadSafe('WARNING  !!  Maximum number of database distributions reached (' + IntToStr(nbMaxDistributions) + ')');
	    end;
end;

function AjouterFichierDansLeDossierDatabase(nomAAjouter : String255; var fichierACopier : basicfile) : OSErr;
var enteteDatabase : t_EnTeteNouveauFormat;
    err : OSErr;
    numFichier : SInt64;
    fic : basicfile;
    path : String255;
    typeDonneesDatabase : SInt16;
begin

  err := -1;

  numFichier := GetNroPremierFichierAvecCeNom(nomAAjouter);

  if (numFichier >= 1) and (numFichier <= InfosFichiersNouveauFormat.nbFichiers) then
    begin
      // le fichier existe deja dans le dossier Database !! On l'ecrase par le nouveau
      err := RemplacerFichierDansLeDossierDatabaseParFichier(nomAAjouter, fic);
    end
  else
    begin

      // on cherche un fichier dans le bon dossier de destination
      numFichier := GetNroDUnFichierDansLaMemeDistribution(nomAAjouter);

      if (numFichier = -1) or // not found !
         ((numFichier >= 1) and (numFichier <= InfosFichiersNouveauFormat.nbFichiers)) then
          begin

            // extraction du path
            if (numFichier = -1)
              then path := PathDuDossierDatabase + ':Distribution officielle:'
              else path := CalculePathFichierNouveauFormat(numFichier);

            err := CreateDirectoryWithThisPath(path);

            (*
            WritelnDansRapportThreadSafe('dans AjouterFichierDansLeDossierDatabase : ');
            WritelnDansRapportThreadSafe('path = '+path);
            *)


            // on cree le nouveau fichier
            err := FileExists(path + nomAAjouter, 0, fic);
            if err = -43 then  {-43 = file not found}
              err := CreateFile(path + nomAAjouter, 0, fic);

            // on essaye d'ouvrir l'ancien fichier dans le dossier database
            if (err = NoErr) then
              err := OpenFile(fic);

            // on vide le fichier que l'on vient de creer le dossier Database !
            // Sans doute inutile, mais cela permet au passage de verifier que
            // l'on a les droits d'ecriture (vieux motard que jamais)
            if (err = NoErr) then
              err := EmptyFile(fic);

           // on le referme
           if (err = NoErr) then
              err := CloseFile(fic);


            // copier le nouveau fichier (telecharge) dans le nouveau fichier du dossier database
            if err = NoErr then
              err := InsertFileInFile(fichierACopier,fic);

            if err = NoErr then
              begin
                // on verifie que tout s'est bien passe
                if EstUnFichierNouveauFormat(fic.info,typeDonneesDatabase, enteteDatabase) and
                   AjouterFichierNouveauFormat(fic.info, path, typeDonneesDatabase, enteteDatabase)
                  then
                    begin
                      // tout a l'air bon

                      SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('SNX4'));
                      SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('QWTB'));


                      WritelnDansRapportThreadSafe('');
                      WritelnDansRapportThreadSafe('The file «'+nomAAjouter+'» has been downloaded automagically from the Internet :-)');

        					  end
        					else
        					  begin
        					    err := -2;
        					  end;
        		  end;
          end;
    end;

  AjouterFichierDansLeDossierDatabase := err;
end;



function RemplacerFichierDansLeDossierDatabaseParFichier(nomARemplacer : String255; var fichierACopier : basicfile) : OSErr;
var err : OSErr;
    numFichier : SInt64;
    typeDonneesDatabase, typeDonneesNew : SInt16;
    enteteDatabase, enteteNew : t_EnTeteNouveauFormat;
begin

  err := -100;

  numFichier := GetNroPremierFichierAvecCeNom(nomARemplacer);

  if (numFichier >= 1) and (numFichier <= InfosFichiersNouveauFormat.nbFichiers) then
    begin

      with InfosFichiersNouveauFormat.fichiers[numFichier] do
        begin
          err := -101;

          (*
          WriteDansRapport('nom du fichier a remplacer :');
          WritelnDansRapport(CalculePathFichierNouveauFormat(numFichier) + CalculeNomFichierNouveauFormat(numFichier));
          *)


          if EstUnFichierNouveauFormat(fichierACopier.info,typeDonneesNew, enteteNew) then
             begin
                err := NoErr;

                enteteDatabase      := InfosFichiersNouveauFormat.fichiers[numFichier].entete;
                typeDonneesDatabase := InfosFichiersNouveauFormat.fichiers[numFichier].typeDonnees;

                if (typeDonneesDatabase <> typeDonneesNew) then
                  err := -102;

                if EntetePlusRecentNouveauFormat(enteteDatabase, enteteNew) then
                  begin
                    WritelnDansRapportThreadSafe('');
                    WritelnDansRapportThreadSafe('WARNING  !!  Your current file '+ nomARemplacer + ' is more recent than the downloaded file. Aborting automatic update for this file...');
                    err := -103;
                  end;

                // on essaye d'ouvrir l'ancien fichier dans le dossier database
                if (err = NoErr) then
                  err := OuvreFichierNouveauFormat(numFichier);

                // on vide l'ancien fichier dans le dossier Database !
                if (err = NoErr) then
                  err := EmptyFile(theFichierTEXT);

                // on le referme
                if (err = NoErr) then
                  err := FermeFichierNouveauFormat(numFichier);

                // copier le nouveau fichier (telecharge) dans l'ancien (celui du dossier database)
                if (err = NoErr) then
                  err := InsertFileInFile(fichierACopier,theFichierTEXT);

                // on verifie que tout c'est bien passe
                if (err = NoErr) then
                  begin
                    if EstUnFichierNouveauFormat(theFichierTEXT.info,typeDonneesDatabase, enteteDatabase)
                      then
                        begin
                          // tout a l'air bon

                          WritelnDansRapportThreadSafe('');
                          WritelnDansRapportThreadSafe('The file «'+nomARemplacer+'» has been updated automagically from the Internet :-)');

                          with InfosFichiersNouveauFormat.fichiers[numFichier] do
            					      begin
            					        entete          := enteteDatabase;
            					        typeDonnees     := typeDonneesDatabase;
            					      end;
            					  end
            					else
            					  begin
            					    err := -104;
            					  end;
          	      end;
            end;

        end;

    end
  else
    begin

      (*
      WritelnDansRapportThreadSafe('nom du fichier a ajouter :');
      WritelnDansRapportThreadSafe(nomARemplacer);
      *)

      err := AjouterFichierDansLeDossierDatabase(nomARemplacer, fichierACopier);
    end;

  RemplacerFichierDansLeDossierDatabaseParFichier := err;
end;


function AjouterFichierNouveauFormat(fic : fileInfo; path : String255; typeDonneesDuFichier : SInt16; EnteteFichier : t_EnTeteNouveauFormat) : boolean;
var nomDistrib : String255;
    ok : boolean;
begin
  // WritelnDansRapport('path = '+path);
  with InfosFichiersNouveauFormat do
   if (nbFichiers < nbMaxFichiersNouveauFormat) then
    begin
      nbFichiers := succ(nbFichiers);
      with fichiers[nbFichiers] do
        begin
          open           := false;
          refNum         := 0;
          vRefNum        := fic.vRefNum;
          parID          := fic.parID;
          typeDonnees    := typeDonneesDuFichier;
          entete         := EnteteFichier;
          NroFichierDual := 0;

          if (typeDonneesDuFichier = kFicPartiesNouveauFormat) or
             (typeDonneesDuFichier = kFicIndexPartiesNouveauFormat)
            then
              begin
                nomDistrib     := NomDistributionAssocieeNouveauFormat(GetName(fic),annee);
                ok             := EstUneDistributionConnue(nomDistrib,path,nroDistribution);
                nomFichier     := NIL;
                pathFichier    := NIL;
              end
            else
              begin
                nomFichier      := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
                pathFichier     := String255Ptr(AllocateMemoryPtr(sizeof(String255)));
                nomfichier^     := GetName(fic);
                pathFichier^    := path;


                nroDistribution := 0;
                annee           := 0;
                ok := true;
              end;
         end;
     end
   else
	   begin
	     WritelnDansRapportThreadSafe('WARNING  !!  Maximum number of database files reached (' + IntToStr(nbMaxFichiersNouveauFormat) + ')');
	   end;
  AjouterFichierNouveauFormat := ok;
end;


function EstUnFichierNouveauFormat(fic : fileInfo; var typeDonnees : SInt16; var entete : t_EnTeteNouveauFormat) : boolean;
var refnum : SInt16;
    anneeTitre : SInt16;
    codeErreur : OSErr;
    nomDuFichier : String255;
    nomDistribution : String255;
    formatReconnu : boolean;
    tailleFichier : SInt64;
begin
  EstUnFichierNouveauFormat := false;
  typeDonnees := kUnknownDataNouveauFormat;

  codeErreur := FSpOpenDF(fic,fsCurPerm,refnum);
  if codeErreur <> 0 then
    begin
      codeErreur := FSClose(refnum);
      exit;
    end;

  codeErreur := LitEnteteNouveauFormat(refnum,entete);
  if codeErreur <> 0 then
    begin
      codeErreur := FSClose(refnum);
      exit;
    end;

  codeErreur := GetEOF(refNum,tailleFichier);
  if codeErreur <> 0 then
    begin
      codeErreur := FSClose(refnum);
      exit;
    end;

  codeErreur := FSClose(refnum);
  refnum := 0;

  nomDuFichier := sysutils.UpperCase(GetName(fic));
  with entete do
    begin
      formatReconnu := (siecleCreation >= 19) and (siecleCreation <= 21) and
                       (anneeCreation >= 0) and (anneeCreation <= 99) and
                       (moisCreation >= 1) and (moisCreation <= 12) and
                       (JourCreation >= 1) and (JourCreation <= 31) and
                       ((NombreEnregistrementsParties > 0) or (NombreEnregistrementsTournoisEtJoueurs > 0));


      (*
      WritelnDansRapport('format interne du fichier «'+GetName(fic)+'»');
      with entete do
		    begin
				  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
				  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
				  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
				  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
				  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
				  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
				  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
				  WritelnNumDansRapport('entete.parametreP1 = ',TailleDuPlateau);
				  WritelnNumDansRapport('entete.parametreP2 = ',EstUnFichierSolitaire);
				  WritelnNumDansRapport('entete.parametreP3 = ',ProfondeurCalculTheorique);
				  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
				  WritelnDansRapport('');
		    end;
      *)

      if formatReconnu
        then
          begin
            if (Pos('WTHOR.TRN.INDEX',nomDuFichier) > 0) and
               (PlaceMemoireIndex > 0) then
					    typeDonnees := kFicIndexTournoisNouveauFormat else

					  if (Pos('WTHOR.JOU.INDEX',nomDuFichier) > 0) and
					     (PlaceMemoireIndex > 0) then
					    typeDonnees := kFicIndexJoueursNouveauFormat else

					  if (Pos('WTHOR.TRN(SHORT)',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.TRN(SHORT)') and
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisCourtsNouveauFormat else

					  if (Pos('WTHOR.JOU(SHORT)',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.JOU(SHORT)') and
					    (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursCourtsNouveauFormat else

					  if (Pos('WTHOR.TRN',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.TRN') and
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisNouveauFormat else

					  if EndsWith(nomDuFichier,'.TRN') and (Pos('WTHOR.TRN',nomDuFichier) <= 0) and
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicTournoisNouveauFormat else

					  if (Pos('WTHOR.JOU',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.JOU') and
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursNouveauFormat else

					  if EndsWith(nomDuFichier,'.JOU') and (Pos('WTHOR.JOU',nomDuFichier) <= 0) and
					     (NombreEnregistrementsParties = 0) then
					    typeDonnees := kFicJoueursNouveauFormat else

					  if EndsWith(nomDuFichier,'.PZZ') and
					     (NombreEnregistrementsTournoisEtJoueurs > 0) then {surcharge de NombreEnregistrementsTournoisEtJoueurs pour stocker le nb de cases vides}
					    begin
					      typeDonnees := kFicSolitairesNouveauFormat;
					    end else

					  if Pos('.INDEX',nomDuFichier) > 0 then
					    begin
					      nomDistribution := NomDistributionAssocieeNouveauFormat(nomDuFichier,anneeTitre);
					      if (anneeTitre = entete.AnneeParties) and (Pos('XXXX.wtb',nomDistribution) > 0)
					       then typeDonnees := kFicIndexPartiesNouveauFormat;
					    end;

					  if (Pos('.WTB',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.WTB') then
					    begin
					      nomDistribution := NomDistributionAssocieeNouveauFormat(nomDuFichier,anneeTitre);
					      if (anneeTitre = entete.AnneeParties) and (Pos('XXXX.wtb',nomDistribution) > 0)
					        then typeDonnees := kFicPartiesNouveauFormat
					        else
					          begin
					            WritelnDansRapport('#### Erreur!! Le nom du fichier «'+GetName(fic)+'» ne contient pas d''année,');
					            WritelnDansRapport('#### ou l''année ne coïncide pas avec la date dans le fichier !!');
					            WritelnDansRapport('');
					            WritelnDansRapport('#### Erreur!! Le format interne du fichier «'+GetName(fic)+'» me parait douteux');
      		            with entete do
      							    begin
      									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
      									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
      									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
      									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
      									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
      									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
      									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
      									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
      									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
      									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
      									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
      									  WritelnDansRapport('');
      							    end;
					          end;
					    end;
		      end
		    else
		      begin
		        if ((Pos('.WTB',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.WTB')) or
		           ((Pos('.PZZ',nomDuFichier) > 0) and EndsWith(nomDuFichier,'.PZZ')) then
		          begin
		            SysBeep(0);
		            WritelnDansRapport('#### Erreur!! Le format interne du fichier «'+GetName(fic)+'» me parait douteux');
		            with entete do
							    begin
									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
									  WritelnDansRapport('');
							    end;
		          end;
		      end;

		   if formatReconnu and (typeDonnees = kFicPartiesNouveauFormat) then
		     begin
		       if (tailleFichier <> (TailleEnTeteNouveauFormat + NombreEnregistrementsParties * TaillePartieRecNouveauFormat)) then
		         begin
		           WritelnDansRapport('#### Erreur!! le fichier  «'+GetName(fic)+'» ne fait pas la bonne taille');
		           with entete do
							    begin
							      WritelnNumDansRapport('taille du fichier = ',tailleFichier);
									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
									  WritelnDansRapport('');
							    end;
							 typeDonnees := kUnknownDataNouveauFormat;
		         end;
		     end;

		   if formatReconnu and (typeDonnees = kFicTournoisNouveauFormat) then
		     begin
		       if (tailleFichier <> (TailleEnTeteNouveauFormat + NombreEnregistrementsTournoisEtJoueurs * TailleTournoiRecNouveauFormat)) then
		         begin
		           WritelnDansRapport('#### Erreur!! le fichier  «'+GetName(fic)+'» ne fait pas la bonne taille');
		           with entete do
							    begin
							      WritelnNumDansRapport('taille du fichier = ',tailleFichier);
									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
									  WritelnDansRapport('');
							    end;
							 typeDonnees := kUnknownDataNouveauFormat;
		         end;
		     end;

		   if formatReconnu and (typeDonnees = kFicJoueursNouveauFormat) then
		     begin
		       if (tailleFichier <> (TailleEnTeteNouveauFormat + NombreEnregistrementsTournoisEtJoueurs * TailleJoueurRecNouveauFormat)) then
		         begin
		           WritelnDansRapport('#### Erreur!! le fichier  «'+GetName(fic)+'» ne fait pas la bonne taille');
		           with entete do
							    begin
							      WritelnNumDansRapport('taille du fichier = ',tailleFichier);
									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
									  WritelnDansRapport('');
							    end;
							 typeDonnees := kUnknownDataNouveauFormat;
		         end;
		     end;

		   if formatReconnu and (typeDonnees = kFicSolitairesNouveauFormat) then
		     begin
		       if (tailleFichier <> (TailleEnTeteNouveauFormat + TailleEnteteSupplementaireSolitaires + NombreEnregistrementsParties*TailleSolitaireRecNouveauFormat)) then
		         begin
		           WritelnDansRapport('#### Erreur!! le fichier  «'+GetName(fic)+'» ne fait pas la bonne taille');
		           with entete do
							    begin
							      WritelnNumDansRapport('taille du fichier = ',tailleFichier);
									  WritelnNumDansRapport('entete.siecleCreation = ',siecleCreation);
									  WritelnNumDansRapport('entete.annneCreation = ',anneeCreation);
									  WritelnNumDansRapport('entete.MoisCreation = ',MoisCreation);
									  WritelnNumDansRapport('entete.JourCreation = ',JourCreation);
									  WritelnNumDansRapport('entete.NombreEnregistrementsParties = ',NombreEnregistrementsParties);
									  WritelnNumDansRapport('entete.NombreEnregistrementsTournoisEtJoueurs = ',NombreEnregistrementsTournoisEtJoueurs);
									  WritelnNumDansRapport('entete.AnneeParties = ',AnneeParties);
									  WritelnNumDansRapport('entete.TailleDuPlateau = ',TailleDuPlateau);
									  WritelnNumDansRapport('entete.EstUnFichierSolitaire = ',EstUnFichierSolitaire);
									  WritelnNumDansRapport('entete.ProfondeurCalculTheorique = ',ProfondeurCalculTheorique);
									  WritelnNumDansRapport('entete.reservedByte = ',reservedByte);
									  WritelnDansRapport('');
							    end;
							 typeDonnees := kUnknownDataNouveauFormat;
		         end;
		     end;

    end; {with}
  EstUnFichierNouveauFormat := formatReconnu and (typeDonnees <> kUnknownDataNouveauFormat);
end;


function EntetesEgauxNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
begin
  EntetesEgauxNouveauFormat  :=
    (entete1.NombreEnregistrementsTournoisEtJoueurs = entete2.NombreEnregistrementsTournoisEtJoueurs) and
    (entete1.NombreEnregistrementsParties           = entete2.NombreEnregistrementsParties) and
    (entete1.AnneeCreation                          = entete2.AnneeCreation) and
    (entete1.MoisCreation                           = entete2.MoisCreation) and
    (entete1.JourCreation                           = entete2.JourCreation) and
    (entete1.AnneeParties                           = entete2.AnneeParties);
    {(entete1.reserved                               = entete2.reserved)}
end;


function EntetePlusRecentNouveauFormat(entete1,entete2 : t_EnTeteNouveauFormat) : boolean;
var plusRecent : boolean;
begin
  plusRecent := false;
  if entete1.siecleCreation > entete2.siecleCreation then plusRecent := true else
  if entete1.siecleCreation = entete2.siecleCreation then
    if entete1.anneeCreation > entete2.anneeCreation then plusRecent := true else
    if entete1.anneeCreation = entete2.anneeCreation then
      if entete1.MoisCreation > entete2.MoisCreation then plusRecent := true else
      if entete1.MoisCreation = entete2.MoisCreation then
        if entete1.JourCreation > entete2.JourCreation then plusRecent := true;
  EntetePlusRecentNouveauFormat := plusRecent;
end;

function OrdreSurFichiers(var f1,f2 : FichierNouveauFormatRec) : boolean;
begin
  OrdreSurFichiers := false;

  if f1.typeDonnees <> f2.typeDonnees then OrdreSurFichiers := (f1.typeDonnees > f2.typeDonnees) else
  if (f1.typeDonnees = kFicJoueursNouveauFormat) and
     (f1.nomFichier <> NIL) and (sysutils.UpperCase(f1.nomFichier^) =  'WTHOR.JOU') and
     (f2.nomFichier <> NIL) and (sysutils.UpperCase(f2.nomFichier^) <> 'WTHOR.JOU') then OrdreSurFichiers := false else
  if (f1.typeDonnees = kFicJoueursNouveauFormat) and
     (f1.nomFichier <> NIL) and (sysutils.UpperCase(f1.nomFichier^) <> 'WTHOR.JOU') and
     (f2.nomFichier <> NIL) and (sysutils.UpperCase(f2.nomFichier^) =  'WTHOR.JOU') then OrdreSurFichiers := true else
  if (f1.typeDonnees = kFicTournoisNouveauFormat) and
     (f1.nomFichier <> NIL) and (sysutils.UpperCase(f1.nomFichier^) =  'WTHOR.TRN') and
     (f2.nomFichier <> NIL) and (sysutils.UpperCase(f2.nomFichier^) <> 'WTHOR.TRN') then OrdreSurFichiers := false else
  if (f1.typeDonnees = kFicTournoisNouveauFormat) and
     (f1.nomFichier <> NIL) and (sysutils.UpperCase(f1.nomFichier^) <> 'WTHOR.TRN') and
     (f2.nomFichier <> NIL) and (sysutils.UpperCase(f2.nomFichier^) =  'WTHOR.TRN') then OrdreSurFichiers := true else
  if f1.annee <> f2.annee                                 then OrdreSurFichiers := (f1.annee                  > f2.annee) else
  if f1.entete.siecleCreation <> f2.entete.siecleCreation then OrdreSurFichiers := (f1.entete.siecleCreation  > f2.entete.siecleCreation) else
  if f1.entete.anneeCreation <> f2.entete.anneeCreation   then OrdreSurFichiers := (f1.entete.anneeCreation   > f2.entete.anneeCreation) else
  if f1.entete.moisCreation <> f2.entete.moisCreation     then OrdreSurFichiers := (f1.entete.moisCreation    > f2.entete.jourCreation) else
  if f1.entete.jourCreation <> f2.entete.jourCreation     then OrdreSurFichiers := (f1.entete.jourCreation    > f2.entete.jourCreation) else
  if f1.nroDistribution <> f2.nroDistribution             then OrdreSurFichiers := (f1.nroDistribution        > f2.nroDistribution) else
  if f1.parID <> f2.parID                                 then OrdreSurFichiers := (f1.parID                  > f2.parID);

end;

procedure TrierListeFichiersNouveauFormat;
{var k : SInt16; }

  procedure Shellsort(lo,up : SInt16);
  var i,d,j : SInt16;
      temp  : FichierNouveauFormatRec;
  label 999;
  begin
    if up-lo > 0 then
      begin
        d := up-lo+1;
        while d > 1 do
          begin
            if d < 5
              then d := 1
              else d := Trunc(0.45454*d);
            for i := up-d downto lo do
              begin
                temp := InfosFichiersNouveauFormat.fichiers[i];
                j := i+d;
                while j <= up do
                  if OrdreSurFichiers(temp,InfosFichiersNouveauFormat.fichiers[j])
                    then
                      begin
                        InfosFichiersNouveauFormat.fichiers[j-d] := InfosFichiersNouveauFormat.fichiers[j];
                        j := j+d;
                      end
                    else
                      goto 999;
                999:
                InfosFichiersNouveauFormat.fichiers[j-d] := temp;
              end;
          end;
      end;
  end; {shellsort}

begin  {trierListeFichiersNouveauFormat}
  with InfosFichiersNouveauFormat do
    if nbFichiers > 0 then
      ShellSort(1,nbFichiers);

 {
 for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
   begin
     WritelnDansRapport(CalculeNomFichierNouveauFormat(k));
   end;
 }

end;


function GetNroPremierFichierAvecCeTypeDeDonnees(ceTypeDeDonnees : SInt16) : SInt16;
var i : SInt16;
begin
  GetNroPremierFichierAvecCeTypeDeDonnees := -1;
  with InfosFichiersNouveauFormat do
    if nbFichiers > 0 then
      for i := 1 to nbFichiers do
        if (fichiers[i].typeDonnees = ceTypeDeDonnees) then
          begin
            GetNroPremierFichierAvecCeTypeDeDonnees := i;
            exit;
          end;
end;

function GetNroPremierFichierAvecCeNom(nom : String255) : SInt16;
var k : SInt64;
    nomEnMajuscules : String255;
begin

  nomEnMajuscules := sysutils.UpperCase(nom);

  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
    begin
      if ( nomEnMajuscules = sysutils.UpperCase(CalculeNomFichierNouveauFormat(k))) then
        begin
          GetNroPremierFichierAvecCeNom := k;
          exit;
        end;
    end;

  GetNroPremierFichierAvecCeNom := -1;
end;

function GetNroPremierFichierAvecCetteDistribution(distribution : String255) : SInt16;
var k : SInt64;
    numDistrib : SInt64;
begin

  for k := 1 to InfosFichiersNouveauFormat.nbFichiers do
    begin
      numDistrib := InfosFichiersNouveauFormat.fichiers[k].nroDistribution;

      if (DistributionsNouveauFormat.distribution[numDistrib].name <> NIL) and
         (DistributionsNouveauFormat.distribution[numDistrib].name^ = distribution) then
        begin
          GetNroPremierFichierAvecCetteDistribution := k;
          exit;
        end;
    end;

  GetNroPremierFichierAvecCetteDistribution := -1;
end;


function GetNroDUnFichierDansLaMemeDistribution(nomFichier : String255) : SInt16;
var result : SInt16;
    s : String255;
    k : SInt64;
    annee : SInt16;
begin

  result := GetNroPremierFichierAvecCeNom(nomFichier);

  if (result <= 0) then
    begin
      if Pos('WTH',nomFichier) > 0 then
        begin
          for k := 1977 to 2020 do
            if result <= 0 then
              result := GetNroPremierFichierAvecCeNom('WTH_'+IntToStr(k)+'.wtb');


          if result <= 0 then
            result := GetNroPremierFichierAvecCeNom('WTHOR.JOU');

          if result <= 0 then
            result := GetNroPremierFichierAvecCeNom('WTHOR.TRN');


        end;
    end;

  if (result <= 0) then
    begin
      s := NomDistributionAssocieeNouveauFormat(nomFichier, annee);
      result := GetNroPremierFichierAvecCetteDistribution(s);
    end;

  GetNroDUnFichierDansLaMemeDistribution := result;

end;


function LitPartieNouveauFormat(numFichier : SInt16; nroPartie : SInt64; enAvancant : boolean; var theGame : t_PartieRecNouveauFormat) : OSErr;
var count : SInt64;
    codeErreur : OSErr;
begin

  if (numFichier < 1) or (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitPartieNouveauFormat : numFichier = ',numFichier);
      LitPartieNouveauFormat := -1;
      exit;
    end;


  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur <> NoErr) then
		    begin
		      LitPartieNouveauFormat := codeErreur;
		      exit;
		    end;

		  if (numFichier = nroDernierFichierPartiesLuNF) and
		     (nroPartie >= premierePartieDansBufferNF) and
		     (nroPartie <= dernierePartieDansBufferNF)
		     then  {la partie est dans le buffer de lecture}
		       begin
		         {defautDePage := false;}
		         MoveMemory(@bufferLecturePartiesNF[nroPartie-premierePartieDansBufferNF],@theGame,TaillePartieRecNouveauFormat);
		       end
		     else
		       begin
		         {defautDePage := true;}
		         if enAvancant
		           then
		             begin
		               premierePartieDansBufferNF := nroPartie;
		               dernierePartieDansBufferNF := nroPartie+CapaciteBufferParties;
		             end
		           else
		             begin
		               premierePartieDansBufferNF := nroPartie-CapaciteBufferParties;
		               dernierePartieDansBufferNF := nroPartie;
		             end;

		         if premierePartieDansBufferNF < 1 then premierePartieDansBufferNF := 1;
		         if dernierePartieDansBufferNF > entete.NombreEnregistrementsParties then dernierePartieDansBufferNF := entete.NombreEnregistrementsParties;

		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierePartieDansBufferNF)*TaillePartieRecNouveauFormat);
		         count := (dernierePartieDansBufferNF-premierePartieDansBufferNF+1)*TaillePartieRecNouveauFormat;
		         codeErreur := FSread(refnum,count,@bufferLecturePartiesNF);
		         MoveMemory(@bufferLecturePartiesNF[nroPartie-premierePartieDansBufferNF],@theGame,TaillePartieRecNouveauFormat);

		         nroDernierePartieLueNF := nroPartie;
		         nroDernierFichierPartiesLuNF := numFichier;


		       end;
		   with theGame do
		     begin

		       { Change byte order from Intel to Motorola/IBM, if necessary }

		       {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
		       SWAP_INTEGER( @nroTournoi);
		       SWAP_INTEGER( @nroJoueurNoir);
		       SWAP_INTEGER( @nroJoueurBlanc);
		       {$ENDC}

		       if (scoreReel < 0) then scoreReel := 0;
		       if (ScoreReel > 64) then scoreReel := 64;
		       if (scoreTheorique < 0) or (scoreTheorique > 64) then scoreTheorique := scoreReel;
		     end;
     end;
   LitPartieNouveauFormat := codeErreur;
end;


function LitJoueurNouveauFormat(numFichier : SInt16; nroJoueur : SInt64; var joueur : String255) : OSErr;
var count : SInt64;
    codeErreur : OSErr;
    JoueurRec : t_JoueurRecNouveauFormat;
    k : SInt16;
begin

  if (numFichier < 1) or (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitJoueurNouveauFormat : numFichier = ',numFichier);
      LitJoueurNouveauFormat := -1;
      exit;
    end;

  codeErreur := NoErr;
  joueur := '';
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if (nroJoueur >= 1) and (nroJoueur <= entete.NombreEnregistrementsTournoisEtJoueurs) then
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur <> NoErr) then
		    begin
		      LitJoueurNouveauFormat := codeErreur;
		      exit;
		    end;

		  if (numFichier = nroDernierFichierJoueursLuNF) and
		     (nroJoueur >= premierJoueurDansBufferNF) and
		     (nroJoueur <= dernierJoueurDansBufferNF)
		     then
		       begin
		         MoveMemory(@bufferLectureJoueursNF[nroJoueur-premierJoueurDansBufferNF],@joueurRec,TailleJoueurRecNouveauFormat);
		       end
		     else
		       begin
		         premierJoueurDansBufferNF := nroJoueur;
		         dernierJoueurDansBufferNF := nroJoueur+CapaciteBufferJoueurs;
		         if premierJoueurDansBufferNF < 1 then
		            premierJoueurDansBufferNF := 1;
		         if dernierJoueurDansBufferNF > entete.NombreEnregistrementsTournoisEtJoueurs then
		            dernierJoueurDansBufferNF := entete.NombreEnregistrementsTournoisEtJoueurs;

		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierJoueurDansBufferNF)*TailleJoueurRecNouveauFormat);
		         if codeErreur <> NoErr then
		           begin
		             LitJoueurNouveauFormat := codeErreur;
		             exit;
		           end;

		         count := (dernierJoueurDansBufferNF-premierJoueurDansBufferNF+1)*TailleJoueurRecNouveauFormat;
		         if count > 0 then
		           begin
		             codeErreur := FSread(refnum,count,@bufferLectureJoueursNF);
		             MoveMemory(@bufferLectureJoueursNF[nroJoueur-premierJoueurDansBufferNF],@JoueurRec,TailleJoueurRecNouveauFormat);
		           end;
		         nroDernierJoueurLuNF := nroJoueur;
		         nroDernierFichierJoueursLuNF := numFichier;
		       end;

		    for k := 1 to TailleJoueurRecNouveauFormat do
		      if (JoueurRec[k] <> 0) then joueur := Concat(joueur,chr(joueurRec[k]));
     end;
  LitJoueurNouveauFormat := codeErreur;
end;


function LitTournoiNouveauFormat(numFichier : SInt16; nroTournoi : SInt64; var Tournoi : String255) : OSErr;
var count : SInt64;
    codeErreur : OSErr;
    TournoiRec : t_TournoiRecNouveauFormat;
    k : SInt16;
begin

  if (numFichier < 1) or (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans LitTournoiNouveauFormat : numFichier = ',numFichier);
      LitTournoiNouveauFormat := -1;
      exit;
    end;

  codeErreur := NoErr;
  Tournoi := '';
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if (nroTournoi >= 1) and (nroTournoi <= entete.NombreEnregistrementsTournoisEtJoueurs) then
    begin
		  if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		  if (codeErreur <> NoErr) then
		    begin
		      LitTournoiNouveauFormat := codeErreur;
		      exit;
		    end;

		  if (numFichier = nroDernierFichierTournoisLuNF) and
		     (nroTournoi >= premierTournoiDansBufferNF) and
		     (nroTournoi <= dernierTournoiDansBufferNF)
		     then
		       begin
		         MoveMemory(@bufferLectureTournoisNF[nroTournoi-premierTournoiDansBufferNF],@TournoiRec,TailleTournoiRecNouveauFormat);
		       end
		     else
		       begin
		         premierTournoiDansBufferNF := nroTournoi;
		         dernierTournoiDansBufferNF := nroTournoi+CapaciteBufferTournois;
		         if premierTournoiDansBufferNF < 1 then
		            premierTournoiDansBufferNF := 1;
		         if dernierTournoiDansBufferNF > entete.NombreEnregistrementsTournoisEtJoueurs then
		            dernierTournoiDansBufferNF := entete.NombreEnregistrementsTournoisEtJoueurs;

		         codeErreur := SetFPos(refnum,1,TailleEnTeteNouveauFormat+pred(premierTournoiDansBufferNF)*TailleTournoiRecNouveauFormat);
		         if codeErreur <> NoErr then
		           begin
		             LitTournoiNouveauFormat := codeErreur;
		             exit;
		           end;

		         count := (dernierTournoiDansBufferNF-premierTournoiDansBufferNF+1)*TailleTournoiRecNouveauFormat;
		         if count > 0 then
		           begin
		             codeErreur := FSread(refnum,count,@bufferLectureTournoisNF);
		             MoveMemory(@bufferLectureTournoisNF[nroTournoi-premierTournoiDansBufferNF],@TournoiRec,TailleTournoiRecNouveauFormat);
		           end;
		         nroDernierTournoiLuNF := nroTournoi;
		         nroDernierFichierTournoisLuNF := numFichier;
		       end;

		    for k := 1 to TailleTournoiRecNouveauFormat do
		      if (TournoiRec[k] <> 0) then Tournoi := Concat(Tournoi,chr(TournoiRec[k]));
     end;
   LitTournoiNouveauFormat := codeErreur;
end;


function OuvreFichierNouveauFormat(numFichier : SInt16) : OSErr;
var codeErreur : OSErr;
    nomFichierComplet : String255;
begin

  if (numFichier < 1) or (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans OuvreFichierNouveauFormat : numFichier = ',numFichier);
      OuvreFichierNouveauFormat := -1;
      exit;
    end;

  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if not(open) then
      begin
        nomFichierComplet := CalculePathFichierNouveauFormat(numFichier)+CalculeNomFichierNouveauFormat(numFichier);

        codeErreur := FileExists(nomFichierComplet,0,theFichierTEXT);

        if codeErreur = NoErr then codeErreur := OpenFile(theFichierTEXT);

        open := (codeErreur = NoErr);

        if open
          then
            begin
              nroDernierFichierOuvertNF := numFichier;
              refnum := theFichierTEXT.refNum;
            end
          else
            begin
              nroDernierFichierOuvertNF := 0;
              refnum := 0;
            end;
      end;

  OuvreFichierNouveauFormat := codeErreur;
end;




function FermeFichierNouveauFormat(numFichier : SInt16) : OSErr;
var codeErreur : OSErr;
begin

  if (numFichier < 1) or (numFichier > nbMaxFichiersNouveauFormat) then
    begin
      WritelnNumDansRapport('WARNING !! Numéro de fichier en dehors de l''intervalle autorisé dans FermeFichierNouveauFormat : numFichier = ',numFichier);
      FermeFichierNouveauFormat := -1;
      exit;
    end;

  codeErreur := NoErr;
  with InfosFichiersNouveauFormat.fichiers[numFichier] do
    if open then
      begin
        codeErreur := CloseFile(theFichierTEXT);
        refnum := 0;
        open := false;
      end;
  FermeFichierNouveauFormat := codeErreur;
end;


function OuvreFichierDesJoueursJaponais(var FichierJoueursJaponais : basicfile) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := -1;
  if codeErreur <> NoErr then codeErreur := FichierTexteDeCassioExiste('players.jap',FichierJoueursJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:players.jap',0,FichierJoueursJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:players.jap ',0,FichierJoueursJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:players.jap (alias)',0,FichierJoueursJaponais);
  if codeErreur = NoErr
    then codeErreur := OpenFile(FichierJoueursJaponais)
    else codeErreur := -43; {file not found}

  OuvreFichierDesJoueursJaponais := codeErreur;
end;


function LitNomsDesJoueursEnJaponais : OSErr;
var codeErreur : OSErr;
    fic : basicfile;
    s,nomLatin,nomJaponais,nomDuMilieuDansListe : String255;
    permutation : LongintArrayPtr;
    k,low,up,middle : SInt64;
    found,memeNom : boolean;
begin
  permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxJoueursEnMemoire+2)*sizeof(SInt32)));
  if permutation = NIL then
    begin
      SysBeep(0);
      LitNomsDesJoueursEnJaponais := -1;
      exit;
    end;

  with JoueursNouveauFormat do
    begin
      if (nbJoueursNouveauFormat <= 0) or not(dejaTriesAlphabetiquement) then
		    begin
		      LitNomsDesJoueursEnJaponais := -1;
		      exit;
		    end;

      codeErreur := OuvreFichierDesJoueursJaponais(fic);
      if codeErreur = NoErr then
        begin
		      for k := 0 to nbJoueursNouveauFormat-1 do    {on inverse la permutation}
		        permutation^[GetNroOrdreAlphabetiqueJoueur(k)] := k;

          while (codeErreur = NoErr) and not(EndOfFile(fic,codeErreur)) do
            begin
              codeErreur := Readln(fic,s);
              if (codeErreur = NoErr) and (s[1] <> '%') and (s <> '') and
                 Split(s,'=',nomLatin,nomJaponais) then
		            begin
		              EnleveEspacesDeGaucheSurPlace(nomLatin);
		              EnleveEspacesDeDroiteSurPlace(nomLatin);
		              nomLatin := UpperCase(nomLatin,false);
		              EnleveEspacesDeGaucheSurPlace(nomJaponais);
		              EnleveEspacesDeDroiteSurPlace(nomJaponais);

		             { We only compare the first 19 letters of the roman name }
		             { because of some limitation in the WTHOR.JOU format }
		              if LENGTH_OF_STRING(nomLatin) > 19 then
		                nomLatin := TPCopy(nomLatin,1,19);

                 {binary search dans la liste des noms de joueurs triee}
                  low := 0;
                  up := nbJoueursNouveauFormat-1;
                  found := false;
                  while (low <= up) and not(found) do
		                begin
			                middle := low + (up - low) div 2;
			                nomDuMilieuDansListe := GetNomJoueur(permutation^[middle]);
			                nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);

			                if Pos(nomLatin,nomDuMilieuDansListe) > 0 then found := true else
			                if nomLatin < nomDuMilieuDansListe then up := middle-1 else
			                if nomLatin > nomDuMilieuDansListe then low := middle+1
			                  else found := true;
			              end;
	                if found then
                    begin
                      SetNomJaponaisDuJoueur(permutation^[middle],nomJaponais);
                      {on cherche aussi en arriere dans la liste des joueurs, pour les noms dupliques}
                      k := middle-1;
                      if (k >= 0) and (k <= nbJoueursNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomJoueur(permutation^[k]);
                          nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuJoueur(permutation^[k],nomJaponais);
                          k := k-1;
                        until not(memeNom) or (k < 0);
                      {puis en avant}
                      k := middle+1;
                      if (k >= 0) and (k <= nbJoueursNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomJoueur(permutation^[k]);
                          nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuJoueur(permutation^[k],nomJaponais);
                          k := k+1;
                        until not(memeNom) or (k > nbJoueursNouveauFormat-1);
                    end;
	              end;
            end;
          codeErreur := CloseFile(fic);
        end;
    end;
  if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
  LitNomsDesJoueursEnJaponais := codeErreur;
end;


procedure AjouterJoueurEnMemoire(joueur : String255; numeroEnMemoire,numeroDansSonFichier : SInt64);
begin
  SetNomJoueur(numeroEnMemoire,joueur);
  SetNomCourtJoueur(numeroEnMemoire,'');
  SetNroOrdreAlphabetiqueJoueur(numeroEnMemoire,-1); { -1 = non encore calculé}
  SetNroDansFichierJoueur(numeroEnMemoire,numeroDansSonFichier);
  SetJoueurEstUnOrdinateur(numeroEnMemoire, Pos('(',joueur) > 0);  { les ordinateurs ont une parenthese dans leur nom }
  JoueursNouveauFormat.dejaTriesAlphabetiquement := false;
end;


procedure AjouterTournoiEnMemoire(tournoi : String255; numeroEnMemoire,numeroDansSonFichier : SInt64);
begin
  SetNomTournoi(numeroEnMemoire,tournoi);
  SetNomCourtTournoi(numeroEnMemoire,'');
  SetNroOrdreAlphabetiqueTournoi(numeroEnMemoire,-1); { -1 = non encore calculé}
  SetNroDansFichierTournoi(numeroEnMemoire,numeroDansSonFichier);
  TournoisNouveauFormat.dejaTriesAlphabetiquement := false;
end;


function MetJoueursNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
var numFichier,numDistrib,typeVoulu : SInt16;
    nroJoueur,placeMemoireDemandee,nbJoueursFictifs : SInt64;
    nbExactsDeJoueurs,nbFichiersJoueurs,nbJoueursDansCeFichier : SInt64;
    decalageDansCeFichierDeJoueurs,decalageProchainFichier : SInt64;
    codeErreur : OSErr;
    s,joueurFictif : String255;
    FichierWTHOR_JOUDejaTrouve : boolean;
    DistributionsAyantLeurPropreFichierDeJoueurs,distribProches : DistributionSet;
    numeroEnMemoire,numeroDansSonFichier : SInt64;
begin
  codeErreur := -1;
  FichierWTHOR_JOUDejaTrouve := false;
  DistributionsAyantLeurPropreFichierDeJoueurs := [];
  nbJoueursFictifs := 0;

  DisposeJoueursNouveauFormat;

  if nomsAbreges
    then typeVoulu := kFicJoueursCourtsNouveauFormat
    else typeVoulu := kFicJoueursNouveauFormat;

  nbExactsDeJoueurs := NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu,nbFichiersJoueurs,placeMemoireDemandee);
  placeMemoireDemandee := Min(placeMemoireDemandee,nbMaxJoueursEnMemoire-10);

  codeErreur := AllocateMemoireJoueursNouveauFormat(placeMemoireDemandee);
  if (codeErreur <> NoErr) then
    begin
      MetJoueursNouveauFormatEnMemoire := codeErreur;
      exit;
    end;

  if (JoueursNouveauFormat.nbJoueursNouveauFormat <> placeMemoireDemandee) then
    begin
      codeErreur := -1;
      MetJoueursNouveauFormatEnMemoire := codeErreur;
      exit;
    end;


  decalageProchainFichier := 0;

  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    with InfosFichiersNouveauFormat.fichiers[numFichier] , JoueursNouveauFormat do
      if (nomsAbreges and (typeDonnees = kFicJoueursCourtsNouveauFormat)) or
         (not(nomsAbreges) and (typeDonnees = kFicJoueursNouveauFormat)) then
        begin


          nbJoueursDansCeFichier := NbJoueursDansFichierJoueursNouveauFormat(numFichier);
          if nbJoueursDansCeFichier > 0 then
            begin

		          decalageDansCeFichierDeJoueurs := decalageProchainFichier;
		          decalageProchainFichier := decalageProchainFichier+(((nbJoueursDansCeFichier-1) div 256)+1)*256 + 512;

		          if not(FichierWTHOR_JOUDejaTrouve) and (sysutils.UpperCase(CalculeNomFichierNouveauFormat(numFichier)) = 'WTHOR.JOU')
		            then
			            begin
			              FichierWTHOR_JOUDejaTrouve := true;
			              for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                if not(numDistrib in distributionsAyantLeurPropreFichierDeJoueurs) then
			                  SetDecalageNrosJoueursOfDistribution(numDistrib,decalageDansCeFichierDeJoueurs);
			            end
			          else
			            begin
			              distribProches := TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(numFichier);
			              if distribProches <> [] then
			                begin
			                  distributionsAyantLeurPropreFichierDeJoueurs := distributionsAyantLeurPropreFichierDeJoueurs+distribProches;
			                  for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                    if numDistrib in distribProches then
			                      SetDecalageNrosJoueursOfDistribution(numDistrib,decalageDansCeFichierDeJoueurs);
			                end;
			            end;

		          if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		          if codeErreur <> NoErr then
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;

		          for nroJoueur := 1 to nbJoueursDansCeFichier do
		            if CodeErreur = NoErr then
		              begin
		                codeErreur := LitJoueurNouveauFormat(numFichier,nroJoueur,s);
		                TraduitNomJoueurEnMac(s,s);

		                numeroEnMemoire := decalageDansCeFichierDeJoueurs+nroJoueur-1;
		                numeroDansSonFichier := nroJoueur-1;

		                AjouterJoueurEnMemoire(s,numeroEnMemoire,numeroDansSonFichier);
		              end;

		          if CodeErreur = NoErr then
		            for nroJoueur := decalageDansCeFichierDeJoueurs+nbJoueursDansCeFichier to decalageProchainFichier-1 do
		              begin
		                inc(nbJoueursFictifs);
		                joueurFictif := '•• Fictif n°'+IntToStr(nbJoueursFictifs);

		                AjouterJoueurEnMemoire(joueurFictif,nroJoueur,0);
		              end;

		          if (sysutils.UpperCase(CalculeNomFichierNouveauFormat(numFichier)) = 'WTHOR.JOU') then
		            begin
		              SetNombreJoueursDansBaseOfficielle(decalageDansCeFichierDeJoueurs+nbJoueursDansCeFichier);
		            end;

		          if codeErreur <> NoErr then
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;

		          codeErreur := FermeFichierNouveauFormat(numFichier);
		          if codeErreur <> NoErr then
		            begin
		              MetJoueursNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;
		        end;
        end;

  MetJoueursNouveauFormatEnMemoire := codeErreur;
end;


procedure EffaceTousLesNomsCourtsDesJoueurs;
var k : SInt64;
begin
  for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
    SetNomCourtJoueur(k,'');
end;


function MetPseudosDeLaBaseWThor(nomDictionnaireDesPseudos : String255) : OSErr;
const kNbMaxNomsWThorConvertis = 30;
var erreurES : OSErr;
    ligne,s,s1,s2,reste : String255;
    dictionnairePseudosWThor : basicfile;
    nom_dictionnaire : String255;
    position,nbPseudos,k,t : SInt64;
    association : array[1..kNbMaxNomsWThorConvertis] of
                  record
                    oldName : String255;
                    newName : String255;
                  end;
    nomBase,nouveauNom : String255;
    arbreDesPseudos : ATR;
    modificationsAffichees : StringSet;
begin

  nom_dictionnaire := nomDictionnaireDesPseudos;

  erreurES := FichierTexteDeCassioExiste(nom_dictionnaire,dictionnairePseudosWThor);
  if (erreurES = fnfErr) then exit;
  if (erreurES <> NoErr) then
    begin
      AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
      exit;
    end;


  erreurES := OpenFile(dictionnairePseudosWThor);
  if erreurES <> NoErr then
    begin
      AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
      exit;
    end;

  erreurES := NoErr;
  ligne := '';
  nbPseudos := 0;
  arbreDesPseudos := MakeEmptyATR;
  modificationsAffichees := MakeEmptyStringSet;

  while not(EndOfFile(dictionnairePseudosWThor,erreurES)) do
    begin
      erreurES := Readln(dictionnairePseudosWThor,s);
      ligne := s;
      EnleveEspacesDeGaucheSurPlace(ligne);
      if (ligne = '') or (ligne[1] = '%')
        then
          begin
            {erreurES := Writeln(outputBaseThor,s);}
          end
        else
          begin

            position := Pos('=',ligne);

            if position > 0 then
              begin
                s1    := TPCopy(ligne, 1, position - 1);
                s2    := '=';
                reste := TPCopy(ligne, position + 1, 255);

                EnleveEspacesDeGaucheSurPlace(s1);
                EnleveEspacesDeDroiteSurPlace(s1);
                EnleveEspacesDeGaucheSurPlace(reste);
                EnleveEspacesDeDroiteSurPlace(reste);

                if (s1 <> '') and (s2 = '=') and (reste <> '') then
                  begin
                    inc(nbPseudos);

                    association[nbPseudos].oldName := s1;
                    association[nbPseudos].newName := reste;

                    {WritelnDansRapport(s1 + ' ==> ' + reste);}

                    s1 := UpperCase(s1,false);
                    InsererDansATR(arbreDesPseudos,s1);

                  end;
              end;
          end;
    end;
  erreurES := CloseFile(dictionnairePseudosWThor);

  if (nbPseudos > 0) and not(ATRIsEmpty(arbreDesPseudos)) then
    begin

      WritelnDansRapport('Trying to translate names using "'+nomDictionnaireDesPseudos+'"...');
      WritelnDansRapport('');
      {WritelnNumDansRapport('nbPseudos = ',nbPseudos);
      WritelnNumDansRapport('JoueursNouveauFormat.nbJoueursNouveauFormat = ',JoueursNouveauFormat.nbJoueursNouveauFormat);}

      for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
        begin
          nomBase := GetNomJoueur(k);
          nomBase := UpperCase(nomBase,false);
          if ChaineEstPrefixeDansATR(arbreDesPseudos,nomBase) then
            begin
              for t := 1 to nbPseudos do
                if (Pos(UpperCase(association[t].oldName,false),nomBase) > 0) then
                  begin
                    nouveauNom := association[t].newName;
                    TraduitNomJoueurEnMac(nouveauNom,nouveauNom);

                    s := 'PLAYER #' + IntToStr(GetNroJoueurDansSonFichier(k)) + ' TRANSLATED : '+GetNomJoueur(k) + ' ==> ' + nouveauNom;
                    if not(MemberOfStringSet(s,position,modificationsAffichees)) then
                      begin
                        WritelnDansRapport(s);
                        AddStringToSet(s,GetNroJoueurDansSonFichier(k),modificationsAffichees);
                      end;
                    SetNomJoueur(k,nouveauNom);
                  end;
            end;
        end;
    end;

  DisposeStringSet(modificationsAffichees);
  DisposeATR(arbreDesPseudos);

  MetPseudosDeLaBaseWThor := erreurES;
end;



function MetTournoisNouveauFormatEnMemoire(nomsAbreges : boolean) : OSErr;
var numFichier,numDistrib,typeVoulu : SInt16;
    nroTournoi,placeMemoireDemandee,nbTournoisFictifs : SInt64;
    nbExactsDeTournois,nbFichiersTournois,nbTournoisDansCeFichier : SInt64;
    decalageDansCeFichierDeTournois,decalageProchainFichier : SInt64;
    codeErreur : OSErr;
    s,tournoiFictif : String255;
    FichierWTHOR_TRNDejaTrouve : boolean;
    DistributionsAyantLeurPropreFichierDeTournois,distribProches : DistributionSet;
    numeroEnMemoire,numeroDansSonFichier : SInt64;
begin
  codeErreur := -1;
  FichierWTHOR_TRNDejaTrouve := false;
  DistributionsAyantLeurPropreFichierDeTournois := [];
  nbTournoisFictifs := 0;

  DisposeTournoisNouveauFormat;

  if nomsAbreges
    then typeVoulu := kFicTournoisCourtsNouveauFormat
    else typeVoulu := kFicTournoisNouveauFormat;

  nbExactsDeTournois := NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu,nbFichiersTournois,placeMemoireDemandee);
  placeMemoireDemandee := Min(placeMemoireDemandee,nbMaxTournoisEnMemoire-10);

  codeErreur := AllocateMemoireTournoisNouveauFormat(placeMemoireDemandee);
  if (codeErreur <> NoErr) then
    begin
      MetTournoisNouveauFormatEnMemoire := codeErreur;
      exit;
    end;

  if (TournoisNouveauFormat.nbTournoisNouveauFormat <> placeMemoireDemandee) then
    begin
      codeErreur := -1;
      MetTournoisNouveauFormatEnMemoire := codeErreur;
      exit;
    end;


  decalageProchainFichier := 0;

  for numFichier := 1 to InfosFichiersNouveauFormat.nbFichiers do
    with InfosFichiersNouveauFormat.fichiers[numFichier] , TournoisNouveauFormat do
      if (nomsAbreges and (typeDonnees = kFicTournoisCourtsNouveauFormat)) or
         (not(nomsAbreges) and (typeDonnees = kFicTournoisNouveauFormat)) then
        begin


          nbTournoisDansCeFichier := NbTournoisDansFichierTournoisNouveauFormat(numFichier);
          if nbTournoisDansCeFichier > 0 then
            begin

		          decalageDansCeFichierDeTournois := decalageProchainFichier;
		          decalageProchainFichier := decalageProchainFichier+(((nbTournoisDansCeFichier-1) div 256)+1)*256 + 512;

		          if not(FichierWTHOR_TRNDejaTrouve) and (sysutils.UpperCase(CalculeNomFichierNouveauFormat(numFichier)) = 'WTHOR.TRN')
		            then
			            begin
			              FichierWTHOR_TRNDejaTrouve := true;
			              for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                if not(numDistrib in distributionsAyantLeurPropreFichierDeTournois) then
			                  SetDecalageNrosTournoisOfDistribution(numDistrib,decalageDansCeFichierDeTournois);
			            end
			          else
			            begin
			              distribProches := TrouveDistributionsLesPlusProchesDeCeFichierNouveauFormat(numFichier);
			              if distribProches <> [] then
			                begin
			                  distributionsAyantLeurPropreFichierDeTournois := distributionsAyantLeurPropreFichierDeTournois+distribProches;
			                  for numDistrib := 1 to DistributionsNouveauFormat.nbDistributions do
			                    if numDistrib in distribProches then
			                      SetDecalageNrosTournoisOfDistribution(numDistrib,decalageDansCeFichierDeTournois);
			                end;
			            end;

		          if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichier);
		          if codeErreur <> NoErr then
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;

		          for nroTournoi := 1 to nbTournoisDansCeFichier do
		            if CodeErreur = NoErr then
		              begin
		                codeErreur := LitTournoiNouveauFormat(numFichier,nroTournoi,s);
		                TraduitNomTournoiEnMac(s,s);

		                numeroEnMemoire := decalageDansCeFichierDeTournois+nroTournoi-1;
		                numeroDansSonFichier := nroTournoi-1;

		                AjouterTournoiEnMemoire(s,numeroEnMemoire,numeroDansSonFichier);
		              end;

		          if CodeErreur = NoErr then
		            for nroTournoi := decalageDansCeFichierDeTournois+nbTournoisDansCeFichier to decalageProchainFichier-1 do
		              begin
		                inc(nbTournoisFictifs);
		                tournoiFictif := '•• Fictif n°'+IntToStr(nbTournoisFictifs);

		                AjouterTournoiEnMemoire(tournoiFictif,nroTournoi,0);
		              end;

		          if (sysutils.UpperCase(CalculeNomFichierNouveauFormat(numFichier)) = 'WTHOR.TRN') then
		            begin
		              SetNombreTournoisDansBaseOfficielle(decalageDansCeFichierDeTournois+nbTournoisDansCeFichier);
		            end;

		          if codeErreur <> NoErr then
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;

		          codeErreur := FermeFichierNouveauFormat(numFichier);
		          if codeErreur <> NoErr then
		            begin
		              MetTournoisNouveauFormatEnMemoire := codeErreur;
		              exit;
		            end;
		        end;
        end;
  MetTournoisNouveauFormatEnMemoire := codeErreur;
end;

function OuvreFichierDesTournoisJaponais(var FichierTournoisJaponais : basicfile) : OSErr;
var codeErreur : OSErr;
begin
  codeErreur := -1;
  if codeErreur <> NoErr then codeErreur := FichierTexteDeCassioExiste('tournaments.jap',FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FichierTexteDeCassioExiste('tournements.jap',FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournaments.jap',0,FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournaments.jap ',0,FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournaments.jap (alias)',0,FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournements.jap',0,FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournements.jap ',0,FichierTournoisJaponais);
  if codeErreur <> NoErr then codeErreur := FileExists(pathCassioFolder+'Database:tournements.jap (alias)',0,FichierTournoisJaponais);
  if codeErreur = NoErr
    then codeErreur := OpenFile(FichierTournoisJaponais)
    else codeErreur := -43; {file not found}

  OuvreFichierDesTournoisJaponais := codeErreur;
end;


function LitNomsDesTournoisEnJaponais : OSErr;
var codeErreur : OSErr;
    fic : basicfile;
    s,nomLatin,nomJaponais,nomDuMilieuDansListe : String255;
    permutation : LongintArrayPtr;
    k,low,up,middle : SInt64;
    found,memeNom : boolean;
begin
  permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxTournoisEnMemoire+2)*sizeof(SInt32)));
  if permutation = NIL then SysBeep(0);
  with TournoisNouveauFormat do
    begin
      if (nbTournoisNouveauFormat <= 0) or not(dejaTriesAlphabetiquement) then
		    begin
		      LitNomsDesTournoisEnJaponais := -1;
		      exit;
		    end;

      codeErreur := OuvreFichierDesTournoisJaponais(fic);
      if codeErreur = NoErr then
        begin
		      for k := 0 to nbTournoisNouveauFormat-1 do    {on inverse la permutation}
		        permutation^[GetNroOrdreAlphabetiqueTournoi(k)] := k;

          while (codeErreur = NoErr) and not(EndOfFile(fic,codeErreur)) do
            begin
              codeErreur := Readln(fic,s);
              if (codeErreur = NoErr) and (s[1] <> '%') and (s <> '') and
                 Split(s,'=',nomLatin,nomJaponais) then
		            begin
		              EnleveEspacesDeGaucheSurPlace(nomLatin);
		              EnleveEspacesDeDroiteSurPlace(nomLatin);
		              nomLatin := UpperCase(nomLatin,false);
		              EnleveEspacesDeGaucheSurPlace(nomJaponais);
		              EnleveEspacesDeDroiteSurPlace(nomJaponais);

                 {binary search dans la liste des noms de tournois triee}
                  low := 0;
                  up := nbTournoisNouveauFormat-1;
                  found := false;
                  while (low <= up) and not(found) do
		                begin
			                middle := low + (up - low) div 2;
			                nomDuMilieuDansListe := GetNomTournoi(permutation^[middle]);
			                nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);

			                if Pos(nomLatin,nomDuMilieuDansListe) > 0 then found := true else
			                if nomLatin < nomDuMilieuDansListe then up := middle-1 else
			                if nomLatin > nomDuMilieuDansListe then low := middle+1
			                  else found := true;
			              end;
	                if found then
	                  begin
	                    SetNomJaponaisDuTournoi(permutation^[middle],nomJaponais);
                      {on cherche aussi en arriere dans la liste des tournois, pour les noms dupliques}
                      k := middle-1;
                      if (k >= 0) and (k <= nbTournoisNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomTournoi(permutation^[k]);
                          nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuTournoi(permutation^[k],nomJaponais);
                          k := k-1;
                        until not(memeNom) or (k < 0);
                      {puis en avant}
                      k := middle+1;
                      if (k >= 0) and (k <= nbTournoisNouveauFormat-1) then
                        repeat
                          nomDuMilieuDansListe := GetNomTournoi(permutation^[k]);
                          nomDuMilieuDansListe := UpperCase(nomDuMilieuDansListe,false);
                          memeNom := (Pos(nomLatin,nomDuMilieuDansListe) > 0);
                          if memeNom then SetNomJaponaisDuTournoi(permutation^[k],nomJaponais);
                          k := k+1;
                        until not(memeNom) or (k > nbTournoisNouveauFormat-1);
                    end;
	              end;
            end;
          codeErreur := CloseFile(fic);
        end;
    end;
  if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
  LitNomsDesTournoisEnJaponais := codeErreur;
end;



function EcritFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
var numeroFichierDesJoueurs,typeVoulu : SInt16;
    entete  : t_EnTeteNouveauFormat;
    buffer : LongintArrayPtr;
    k,count : SInt64;
    codeErreur : OSErr;
    path,nomCompletDuFichierIndex : String255;
    fic : basicfile;
begin
  codeErreur := -1;
  EcritFichierIndexDesJoueursTries := -1;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	exit;
	{$ENDC}

  with InfosFichiersNouveauFormat,JoueursNouveauFormat do
    if (nbJoueursNouveauFormat > 0) and dejaTriesAlphabetiquement then
    begin
      if nomsAbreges
        then typeVoulu := kFicJoueursCourtsNouveauFormat
        else typeVoulu := kFicJoueursNouveauFormat;
      numeroFichierDesJoueurs := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      if (numeroFichierDesJoueurs > 0) and
         (numeroFichierDesJoueurs <= nbFichiers) then
         begin
           entete := CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu);
           if (entete.PlaceMemoireIndex = nbJoueursNouveauFormat) then
             begin
               buffer := LongintArrayPtr(AllocateMemoryPtr(4*nbJoueursNouveauFormat));
               if buffer <> NIL then
                 begin
                   for k := 0 to nbJoueursNouveauFormat-1 do
                     buffer^[k] := GetNroOrdreAlphabetiqueJoueur(k);

	                 path := CalculePathFichierNouveauFormat(numeroFichierDesJoueurs);
	                 nomCompletDuFichierIndex := path+CalculeNomFichierNouveauFormat(numeroFichierDesJoueurs)+'.index';

	                 if FileExists(nomCompletDuFichierIndex,0,fic) = NoErr
	                   then codeErreur := DeleteFile(fic);
	                 codeErreur := CreateFile(nomCompletDuFichierIndex,0,fic);
	                 SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('SNX4'));
	                 SetFileTypeFichierTexte(fic,FOUR_CHAR_CODE('INDX'));


	                 codeErreur := OpenFile(fic);
						       if codeErreur = 0 then
						         begin
						           codeErreur := EcritEnteteNouveauFormat(fic.refNum,entete);

						           count := 4;
						           codeErreur := FSWrite(fic.refNum,count,@nbJoueursNouveauFormat);

						           count := 4*nbJoueursNouveauFormat;
						           codeErreur := FSWrite(fic.refNum,count,buffer);

						           codeErreur := CloseFile(fic);
						         end;

						     end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  EcritFichierIndexDesJoueursTries := codeErreur;
end;


function LitFichierIndexDesJoueursTries(nomsAbreges : boolean) : OSErr;
var numeroFichierIndex,numeroFichierJoueurs,typeVoulu : SInt16;
    enteteIndex,enteteDesJoueurs : t_EnTeteNouveauFormat;
    buffer : LongintArrayPtr;
    k,count,nbNomsDansFichierIndex : SInt64;
    nbExactsDeJoueurs,nbFicJoueurs,placeMemoirePrise : SInt64;
    codeErreur : OSErr;
begin
  codeErreur := -1;
  LitFichierIndexDesJoueursTries := -1;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	exit;
	{$ENDC}

  with InfosFichiersNouveauFormat,JoueursNouveauFormat do
    if (nbJoueursNouveauFormat > 0) then
    begin

      if nomsAbreges
        then typeVoulu := kFicIndexJoueursCourtsNouveauFormat
        else typeVoulu := kFicIndexJoueursNouveauFormat;
      numeroFichierIndex := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);

      if nomsAbreges
        then typeVoulu := kFicJoueursCourtsNouveauFormat
        else typeVoulu := kFicJoueursNouveauFormat;
      numeroFichierJoueurs := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);

      nbExactsDeJoueurs := NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu,nbFicJoueurs,placeMemoirePrise);

      if (numeroFichierIndex > 0) and (numeroFichierIndex <= nbFichiers) and
         (numeroFichierJoueurs > 0) and (numeroFichierJoueurs <= nbFichiers) then
         begin
           enteteIndex := fichiers[numeroFichierIndex].entete;
           enteteDesJoueurs := CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu);

           if EntetesEgauxNouveauFormat(enteteIndex,enteteDesJoueurs) and
              (enteteIndex.NombreEnregistrementsParties = nbExactsDeJoueurs) and
              (enteteIndex.PlaceMemoireIndex = placeMemoirePrise) and
              (nbJoueursNouveauFormat = placeMemoirePrise) then
             begin
               buffer := LongintArrayPtr(AllocateMemoryPtr(4*nbJoueursNouveauFormat));
               if buffer <> NIL then
                 with fichiers[numeroFichierIndex] do
                 begin
                   if not(open) then
                     begin
                       codeErreur := OuvreFichierNouveauFormat(numeroFichierIndex);
                       if codeErreur <> NoErr then exit;
                     end;

                   codeErreur := LitEnteteNouveauFormat(refnum,enteteIndex);
	                 if codeErreur <> NoErr then exit;

                   codeErreur := MyFSRead(refnum,4,@nbNomsDansFichierIndex);
	                 if codeErreur <> NoErr then exit;



                   if (nbJoueursNouveauFormat <> enteteIndex.PlaceMemoireIndex) or
	                    (nbNomsDansFichierIndex <> nbJoueursNouveauFormat)
	                    then exit;

                   count := 4*nbJoueursNouveauFormat;
						       codeErreur := FSRead(refnum,count,buffer);
						       if codeErreur <> NoErr then exit;

						       for k := 0 to nbJoueursNouveauFormat-1 do
                     SetNroOrdreAlphabetiqueJoueur(k,buffer^[k]);

                   codeErreur := FermeFichierNouveauFormat(numeroFichierIndex);
                 end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  LitFichierIndexDesJoueursTries := codeErreur;
end;


function EcritFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
var numeroFichierDesTournois,typeVoulu : SInt16;
    entete : t_EnTeteNouveauFormat;
    buffer : LongintArrayPtr;
    k,count : SInt64;
    codeErreur : OSErr;
    path,nomCompletDuFichierIndex : String255;
    fic : basicfile;
begin
  codeErreur := -1;
  EcritFichierIndexDesTournoisTries := -1;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	exit;
	{$ENDC}

  with InfosFichiersNouveauFormat,TournoisNouveauFormat do
    if (nbTournoisNouveauFormat > 0) and dejaTriesAlphabetiquement then
    begin
      if nomsAbreges
        then typeVoulu := kFicTournoisCourtsNouveauFormat
        else typeVoulu := kFicTournoisNouveauFormat;
      numeroFichierDesTournois := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);
      if (numeroFichierDesTournois > 0) and
         (numeroFichierDesTournois <= nbFichiers) then
         begin
           entete := CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu);
           if (entete.PlaceMemoireIndex = nbTournoisNouveauFormat) then
             begin
               buffer := LongintArrayPtr(AllocateMemoryPtr(4*nbTournoisNouveauFormat));
               if buffer <> NIL then
                 begin
                   for k := 0 to nbTournoisNouveauFormat-1 do
                     buffer^[k] := GetNroOrdreAlphabetiqueTournoi(k);

	                 path := CalculePathFichierNouveauFormat(numeroFichierDesTournois);
	                 nomCompletDuFichierIndex := path+CalculeNomFichierNouveauFormat(numeroFichierDesTournois)+'.index';

	                 if FileExists(nomCompletDuFichierIndex,0,fic) = NoErr
	                   then codeErreur := DeleteFile(fic);
	                 codeErreur := CreateFile(nomCompletDuFichierIndex,0,fic);
	                 SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('SNX4'));
	                 SetFileTypeFichierTexte(fic,FOUR_CHAR_CODE('INDX'));


	                 codeErreur := OpenFile(fic);
						       if codeErreur = 0 then
						         begin
						           codeErreur := EcritEnteteNouveauFormat(fic.refNum,entete);

						           count := 4;
						           codeErreur := FSWrite(fic.refNum,count,@nbTournoisNouveauFormat);

						           count := 4*nbTournoisNouveauFormat;
						           codeErreur := FSWrite(fic.refNum,count,buffer);

						           codeErreur := CloseFile(fic);
						         end;

						     end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  EcritFichierIndexDesTournoisTries := codeErreur;
end;


function LitFichierIndexDesTournoisTries(nomsAbreges : boolean) : OSErr;
var numeroFichierIndex,numeroFichierTournois,typeVoulu : SInt16;
    enteteIndex,enteteDesTournois : t_EnTeteNouveauFormat;
    buffer : LongintArrayPtr;
    k,count,nbNomsDansFichierIndex : SInt64;
    nbExactsDeTournois,nbFicTournois,placeMemoirePrise : SInt64;
    codeErreur : OSErr;
begin
  codeErreur := -1;
  LitFichierIndexDesTournoisTries := -1;

  {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	exit;
	{$ENDC}

  with InfosFichiersNouveauFormat,TournoisNouveauFormat do
    if (nbTournoisNouveauFormat > 0) then
    begin

      if nomsAbreges
        then typeVoulu := kFicIndexTournoisCourtsNouveauFormat
        else typeVoulu := kFicIndexTournoisNouveauFormat;
      numeroFichierIndex := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);

      if nomsAbreges
        then typeVoulu := kFicTournoisCourtsNouveauFormat
        else typeVoulu := kFicTournoisNouveauFormat;
      numeroFichierTournois := GetNroPremierFichierAvecCeTypeDeDonnees(typeVoulu);

      nbExactsDeTournois := NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu,nbFicTournois,placeMemoirePrise);

      if (numeroFichierIndex > 0) and (numeroFichierIndex <= nbFichiers) and
         (numeroFichierTournois > 0) and (numeroFichierTournois <= nbFichiers) then
         begin
           enteteIndex := fichiers[numeroFichierIndex].entete;
           enteteDesTournois := CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu);

           if EntetesEgauxNouveauFormat(enteteIndex,enteteDesTournois) and
              (enteteIndex.NombreEnregistrementsParties = nbExactsDeTournois) and
              (enteteIndex.PlaceMemoireIndex = placeMemoirePrise) and
              (nbTournoisNouveauFormat = placeMemoirePrise) then
             begin
               buffer := LongintArrayPtr(AllocateMemoryPtr(4*nbTournoisNouveauFormat));
               if buffer <> NIL then
                 with fichiers[numeroFichierIndex] do
                 begin
                   if not(open) then
                     begin
                       codeErreur := OuvreFichierNouveauFormat(numeroFichierIndex);
                       if codeErreur <> NoErr then exit;
                     end;

                   codeErreur := LitEnteteNouveauFormat(refnum,enteteIndex);
	                 if codeErreur <> NoErr then exit;

                   codeErreur := MyFSRead(refnum,4,@nbNomsDansFichierIndex);
	                 if codeErreur <> NoErr then exit;

                   if (nbTournoisNouveauFormat <> enteteIndex.PlaceMemoireIndex) or
	                    (nbNomsDansFichierIndex <> nbTournoisNouveauFormat)
	                    then exit;

                   count := 4*nbTournoisNouveauFormat;
						       codeErreur := FSRead(refnum,count,buffer);
						       if codeErreur <> NoErr then exit;

						       for k := 0 to nbTournoisNouveauFormat-1 do
                     SetNroOrdreAlphabetiqueTournoi(k,buffer^[k]);

                   codeErreur := FermeFichierNouveauFormat(numeroFichierIndex);
                 end;
               if buffer <> NIL then DisposeMemoryPtr(Ptr(buffer));
             end;
         end;
    end;
  LitFichierIndexDesTournoisTries := codeErreur;
end;



function MetJoueursEtTournoisEnMemoire(nomsAbreges : boolean) : OSErr;
var codeErreur : OSErr;
    s : String255;
    joueursEnMemoire,tournoisEnMemoire : boolean;
begin
  LecturePreparatoireDossierDatabase(pathCassioFolder,'MetJoueursEtTournoisEnMemoire');

  codeErreur := MetJoueursNouveauFormatEnMemoire(nomsAbreges);
  joueursEnMemoire := (codeErreur = NoErr);
  if (codeErreur <> NoErr) then
    begin
      s := ReadStringFromRessource(TextesNouveauFormatID,1);
      AlerteSimple(ReplaceParameters(s,IntToStr(codeErreur),'','',''));
      MetJoueursEtTournoisEnMemoire := codeErreur;
    end;

  codeErreur := MetPseudosDeLaBaseWThor('name_mapping_WThor_to_WThor.txt');

  codeErreur := MetTournoisNouveauFormatEnMemoire(nomsAbreges);
  tournoisEnMemoire := (codeErreur = NoErr);
  if (codeErreur <> NoErr) then
    begin
      s := ReadStringFromRessource(TextesNouveauFormatID,2);
      AlerteSimple(ReplaceParameters(s,IntToStr(codeErreur),'','',''));
      MetJoueursEtTournoisEnMemoire := codeErreur;
    end;
  JoueursEtTournoisEnMemoire := joueursEnMemoire and tournoisEnMemoire;
end;



procedure InitialiseJoueursBidonsNouveauFormat;
var n : SInt64;
    s30 : String255;
begin
  with JoueursNouveauFormat do
    begin
      if (nbJoueursNouveauFormat > 0) and (listeJoueurs <> NIL) then
        begin
          for n := 0 to nbJoueursNouveauFormat-1 do
            begin
              s30 := 'joueur #'+IntToStr(n);
              SetNomJoueur(n,s30);
            end;
        end;
    end;
end;




procedure InitialiseTournoisBidonsNouveauFormat;
var n : SInt64;
    s30 : String255;
begin
  with TournoisNouveauFormat do
    begin
      if (nbTournoisNouveauFormat > 0) and (listeTournois <> NIL) then
        begin
          for n := 0 to nbTournoisNouveauFormat-1 do
            begin
              s30 := 'Tournoi #'+IntToStr(n);
              SetNomTournoi(n,s30);
            end;
        end;
    end;
end;


function TraiteNouveauFormatEtRecursion(var fs : fileInfo; isFolder : boolean; path : String255; var pb : CInfoPBRec) : boolean;
var entete : t_EnTeteNouveauFormat;
    typeDonnees : SInt16;
    nomDistrib : String255;
    anneeDansDistrib : SInt16;
    bidon : boolean;
    bidint : SInt16;
begin
 {$UNUSED pb}
  if (Abs(gDernierTickDansTraiteNouveauFormat - TickCount) > 3) then
    begin
      ShareTimeWithOtherProcesses(0);
      gDernierTickDansTraiteNouveauFormat := TickCount;
      inc(nbAppelsShareTimeWithOtherProcesses);
    end;

  if not(isFolder) and (Pos('Gestion Base WThor',path) <= 0) and
     (GetName(fs)[1] <> '.') and EstUnFichierNouveauFormat(fs,typeDonnees,entete) then
    begin
      if (typeDonnees = kFicPartiesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(GetName(fs),anneeDansDistrib);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory+path,kFicPartiesNouveauFormat);
          {SetFileCreator(GetPathOfScannedDirectory+path+GetName(fs),'SNX4');
          SetFileType(GetPathOfScannedDirectory+path+GetName(fs),'QWTB');}
          SetFileCreator(fs,FOUR_CHAR_CODE('SNX4'));
          SetFileType(fs,FOUR_CHAR_CODE('QWTB'));
        end;
      if (typeDonnees = kFicIndexPartiesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(GetName(fs),anneeDansDistrib);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory+path,kFicPartiesNouveauFormat);
        end;
      if (typeDonnees = kFicSolitairesNouveauFormat) then
        begin
          nomDistrib := NomDistributionAssocieeNouveauFormat(GetName(fs),bidint);
          AjouterDistributionNouveauFormat(nomDistrib,GetPathOfScannedDirectory+path,kFicSolitairesNouveauFormat);
        end;
      if (typeDonnees = kFicJoueursNouveauFormat) or
         (typeDonnees = kFicTournoisNouveauFormat) or
         (typeDonnees = kFicJoueursCourtsNouveauFormat) or
         (typeDonnees = kFicTournoisCourtsNouveauFormat) then
        begin
          {SetFileCreator(GetPathOfScannedDirectory+path+GetName(fs),FOUR_CHAR_CODE('SNX4'));
          SetFileType(GetPathOfScannedDirectory+path+GetName(fs),FOUR_CHAR_CODE('QWTB'));}
          SetFileCreator(fs,FOUR_CHAR_CODE('SNX4'));
          SetFileType(fs,FOUR_CHAR_CODE('QWTB'));
        end;
      if (typeDonnees = kFicSolitairesNouveauFormat) then
        begin
          {SetFileCreator(GetPathOfScannedDirectory+path+GetName(fs),FOUR_CHAR_CODE('SNX4'));
          SetFileType(GetPathOfScannedDirectory+path+GetName(fs),FOUR_CHAR_CODE('PZZL'));}
          SetFileCreator(fs,FOUR_CHAR_CODE('SNX4'));
          SetFileType(fs,FOUR_CHAR_CODE('PZZL'));
        end;

      if (typeDonnees = kFicJoueursNouveauFormat) and (sysutils.UpperCase(GetName(fs)) = 'SOLITAIRES.JOU') and FichierWTHORJOUDejaTrouve
         then DoNothing
         else bidon := AjouterFichierNouveauFormat(fs,GetPathOfScannedDirectory+path,typeDonnees,entete);

    end;
  TraiteNouveauFormatEtRecursion := isFolder; {on cherche recursivement}
end;


procedure ChercheFichiersNouveauFormatDansDossier(vRefNum : SInt16; NomDossier : String255; var dossierTrouve : boolean);
var directoryDepart : fileInfo;
    codeErreur : OSErr;
    cheminDirectoryDepartRecursion : String255;
begin

  if (vRefNum <> 0)
    then cheminDirectoryDepartRecursion := GetWDName(vRefNum) + NomDossier + DirectorySeparator
    else cheminDirectoryDepartRecursion := NomDossier + DirectorySeparator;


  codeErreur := CanCreateFileInfo(vRefNum,vRefNum,cheminDirectoryDepartRecursion,directoryDepart);

  codeErreur := SetPathOfScannedDirectory(directoryDepart);

  if codeErreur = 0 then
    codeErreur := ScanDirectory(directoryDepart,TraiteNouveauFormatEtRecursion);

  if (codeErreur = 0)
    then
      begin
        dossierTrouve := true;
        volumeRefDossierDatabase := directoryDepart.vRefNum;
        pathToDataBase := GetPathOfScannedDirectory;
        {WritelnDansRapport('pathToDataBase = '+pathToDataBase);}
      end
    else
      dossierTrouve := false;
end;


function EcourteNomDistributionNouveauFormat(nomLong : String255) : String255;
var s : String255;
    posXXXX : SInt16;
begin
  s := sysutils.UpperCase(nomLong);
  posXXXX := Pos('XXXX',s);
  if posXXXX > 0
    then ecourteNomDistributionNouveauFormat := LeftStr(nomLong,posXXXX-1)
    else ecourteNomDistributionNouveauFormat := nomLong;
end;

function NbTotalPartiesDansDistributionSet(ensemble : DistributionSet) : SInt64;
var somme : SInt64;
    k : SInt16;
begin
  somme := 0;
  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if (fichiers[k].typeDonnees = kFicPartiesNouveauFormat) and
         (fichiers[k].nroDistribution in ensemble) then
        begin
          somme := somme + fichiers[k].entete.NombreEnregistrementsParties;
        end;
  NbTotalPartiesDansDistributionSet := somme;
end;

procedure SetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16; decalage : SInt64);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions) then
      Distribution[nroDistrib].decalageNrosJoueurs := decalage;
  {WritelnNumDansRapport('decalage distrib n°'+IntToStr(nroDistrib)+' = ',decalage);}
end;

function  GetDecalageNrosJoueursOfDistribution(nroDistrib : SInt16) : SInt64;
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions)
      then GetDecalageNrosJoueursOfDistribution := Distribution[nroDistrib].decalageNrosJoueurs
      else GetDecalageNrosJoueursOfDistribution := 0;
end;

procedure SetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16; decalage : SInt64);
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions) then
      Distribution[nroDistrib].decalageNrosTournois := decalage;
end;

function  GetDecalageNrosTournoisOfDistribution(nroDistrib : SInt16) : SInt64;
begin
  with DistributionsNouveauFormat do
    if (nroDistrib >= 1) and (nroDistrib <= nbDistributions)
      then GetDecalageNrosTournoisOfDistribution := Distribution[nroDistrib].decalageNrosTournois
      else GetDecalageNrosTournoisOfDistribution := 0;
end;


function IndexerFichierPartiesEnMemoireNouveauFormat(numFichierParties : SInt16) : OSErr;
var nroPartie,nbParties : SInt64;
    theGame : t_PartieRecNouveauFormat;
    codeErreur : OSErr;
    bufferOuverture : packed7;
begin
  IndexerFichierPartiesEnMemoireNouveauFormat := -1;
  with InfosFichiersNouveauFormat,IndexNouveauFormat do
    begin
      if (numFichierParties > 0) and (numFichierParties <= nbFichiers) and
         (fichiers[numFichierParties].typeDonnees = kFicPartiesNouveauFormat) then
         begin
           nbParties := fichiers[numFichierParties].entete.NombreEnregistrementsParties;
           codeErreur := AllocateMemoireIndexNouveauFormat(nbParties);
           if codeErreur <> NoErr then exit;
           codeErreur := OuvreFichierNouveauFormat(numFichierParties);
           if codeErreur <> NoErr then exit;
           for nroPartie := 1 to nbParties do
             begin
               codeErreur := LitPartieNouveauFormat(numFichierParties,nroPartie,true,theGame);

               indexNoir^[nroPartie] := theGame.nroJoueurNoir and $00FF;
               indexBlanc^[nroPartie] := theGame.nroJoueurBlanc and $00FF;
               indexTournoi^[nroPartie] := theGame.nroTournoi and $00FF;

               MoveMemory(POINTER_ADD(@theGame , 8),@bufferOuverture,nbOctetsOuvertures);

               indexOuverture^[nroPartie] := NroOuverture(bufferOuverture);

             end;
           codeErreur := FermeFichierNouveauFormat(numFichierParties);
           IndexerFichierPartiesEnMemoireNouveauFormat := codeErreur;
         end;
    end;
end;



function EcritFichierIndexNouveauFormat(numFichierParties : SInt16) : OSErr;
var codeErreur : OSErr;
    nomCompletDuFichierIndex,path : String255;
    enteteIndex : t_EnTeteNouveauFormat;
    fic : basicfile;
    count : SInt64;
begin
  EcritFichierIndexNouveauFormat := -1;
  with InfosFichiersNouveauFormat,IndexNouveauFormat do
    if (numFichierParties > 0) and (numFichierParties <= nbFichiers) and
       (fichiers[numFichierParties].typeDonnees = kFicPartiesNouveauFormat) and
       (fichiers[numFichierParties].entete.NombreEnregistrementsParties = tailleIndex) then
	     begin
	       {path := DistributionsNouveauFormat.Distribution[fichiers[numFichierParties].nroDistribution].path^;}
	       path := CalculePathFichierNouveauFormat(numFichierParties);
	       nomCompletDuFichierIndex := path+NomFichierIndexAssocieNouveauFormat(CalculeNomFichierNouveauFormat(numFichierParties));

	       if FileExists(nomCompletDuFichierIndex,0,fic) = NoErr
           then codeErreur := DeleteFile(fic);
         codeErreur := CreateFile(nomCompletDuFichierIndex,0,fic);
         SetFileCreatorFichierTexte(fic,FOUR_CHAR_CODE('SNX4'));
         SetFileTypeFichierTexte(fic,FOUR_CHAR_CODE('INDX'));

	       codeErreur := OpenFile(fic);
	       if codeErreur = 0 then
	         begin
	           enteteIndex := fichiers[numFichierParties].entete;
	           codeErreur := EcritEnteteNouveauFormat(fic.refNum,enteteIndex);

	           {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	           SWAP_LONGINT( @tailleIndex);
	           {$ENDC}

	           count := 4;
	           codeErreur := FSWrite(fic.refNum,count,@tailleIndex);

	           {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	           SWAP_LONGINT( @tailleIndex);
	           {$ENDC}


	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexNoir^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexBlanc^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexTournoi^[1]);
	           count := tailleIndex;
	           codeErreur := FSWrite(fic.refNum,count,@indexOuverture^[1]);

	           codeErreur := CloseFile(fic);
	         end;

	       EcritFichierIndexNouveauFormat := codeErreur;
	     end;
end;


function LitFichierIndexNouveauFormat(numFichierIndex : SInt16) : OSErr;
var codeErreur : OSErr;
    nbrePartiesDansFicIndex : SInt64;
    s : String255;
label cleanUp;
begin
  LitFichierIndexNouveauFormat := -1;
  codeErreur := NoErr;

  with InfosFichiersNouveauFormat do
    if (numFichierIndex > 0) and (numFichierIndex <= nbFichiers) and
       (fichiers[numFichierIndex].typeDonnees = kFicIndexPartiesNouveauFormat) then
      with fichiers[numFichierIndex] do
	      begin
	        if not(open) then codeErreur := OuvreFichierNouveauFormat(numFichierIndex);
	        if codeErreur <> NoErr then goto cleanUp;

	        codeErreur := LitEnteteNouveauFormat(refnum,entete);
	        if codeErreur <> NoErr then goto cleanUp;

	        codeErreur := MyFSRead(refnum,4,@nbrePartiesDansFicIndex);
	        if codeErreur <> NoErr then goto cleanUp;

	        {$IFC CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL }
	        SWAP_LONGINT( @nbrePartiesDansFicIndex);
	        {$ENDC}

	        if nbrePartiesDansFicIndex <> entete.NombreEnregistrementsParties then
	          begin
	            codeErreur := -2;
	            goto cleanUp;
	          end;

	        codeErreur := AllocateMemoireIndexNouveauFormat(nbrePartiesDansFicIndex);
          if codeErreur <> NoErr then goto cleanUp;

	        with IndexNouveauFormat do
	          begin
	            tailleindex := 0;

	            codeErreur := MyFSRead(refnum,nbrePartiesDansFicIndex,@indexNoir^[1]);
	            if codeErreur <> NoErr then goto cleanUp;

	            codeErreur := MyFSRead(refnum,nbrePartiesDansFicIndex,@indexBlanc^[1]);
	            if codeErreur <> NoErr then goto cleanUp;

	            codeErreur := MyFSRead(refnum,nbrePartiesDansFicIndex,@indexTournoi^[1]);
	            if codeErreur <> NoErr then goto cleanUp;

	            codeErreur := MyFSRead(refnum,nbrePartiesDansFicIndex,@indexOuverture^[1]);
	            if codeErreur <> NoErr then goto cleanUp;

	            tailleindex := nbrePartiesDansFicIndex;
	          end;

	        codeErreur := FermeFichierNouveauFormat(numFichierIndex);


	        cleanUp :

	        if codeErreur <> NoErr
	          then
	            begin
	              s := Concat('WARNING : LitFichierIndexNouveauFormat : erreur ' , IntToStr(codeErreur));
	              TraceLog(s);
	            end;

	        LitFichierIndexNouveauFormat := codeErreur;
	      end;
end;

procedure IndexerLesFichiersNouveauFormat;
var err : OSErr;
    numFichier : SInt16;
begin
  numFichier := 1;
  with InfosFichiersNouveauFormat do
    repeat
      if (numFichier <= nbFichiers) and
         (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) then
        begin
          err := IndexerFichierPartiesEnMemoireNouveauFormat(numFichier);
          err := EcritFichierIndexNouveauFormat(numFichier);
        end;
      numFichier := succ(numFichier);
    until (numFichier > nbFichiers) or EscapeDansQueue;
end;


function NbPartiesFichierNouveauFormat(numFichier : SInt16) : SInt64;
begin
  NbPartiesFichierNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier > 0) and (numFichier <= nbFichiers) and
     (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) then
       NbPartiesFichierNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsParties;
end;

function AnneePartiesFichierNouveauFormat(numFichier : SInt16) : SInt16;
begin
  AnneePartiesFichierNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier > 0) and (numFichier <= nbFichiers) and
     (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) then
       AnneePartiesFichierNouveauFormat := fichiers[numFichier].annee;
end;

function NbJoueursDansFichierJoueursNouveauFormat(numFichier : SInt16) : SInt64;
begin
  NbJoueursDansFichierJoueursNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier > 0) and (numFichier <= nbFichiers) and
     ((fichiers[numFichier].typeDonnees = kFicJoueursNouveauFormat) or
      (fichiers[numFichier].typeDonnees = kFicJoueursCourtsNouveauFormat)) then
       NbJoueursDansFichierJoueursNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsTournoisEtJoueurs;
end;

function NbTournoisDansFichierTournoisNouveauFormat(numFichier : SInt16) : SInt64;
begin
  NbTournoisDansFichierTournoisNouveauFormat := 0;
  with InfosFichiersNouveauFormat do
  if (numFichier > 0) and (numFichier <= nbFichiers) and
     ((fichiers[numFichier].typeDonnees = kFicTournoisNouveauFormat) or
      (fichiers[numFichier].typeDonnees = kFicTournoisCourtsNouveauFormat)) then
       NbTournoisDansFichierTournoisNouveauFormat := fichiers[numFichier].entete.NombreEnregistrementsTournoisEtJoueurs;
end;

function NbTotalDeJoueursDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersJoueurs,placeMemoireNecessaire : SInt64) : SInt64;
var i,aux,somme : SInt64;
begin
  nbFichiersJoueurs := 0;
  placeMemoireNecessaire := 0;

  somme := 0;
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees = kFicJoueursNouveauFormat) or (fichiers[i].typeDonnees = kFicJoueursCourtsNouveauFormat)) and
         (fichiers[i].typeDonnees = typeVoulu) then
        begin
          aux := NbJoueursDansFichierJoueursNouveauFormat(i);
          if aux > 0 then
            begin
              nbFichiersJoueurs := nbFichiersJoueurs+1;
              somme := somme+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
            end;
        end;
  NbTotalDeJoueursDansFichiersNouveauFormat := somme;
end;


function TailleTheoriqueDeCeFichierNouveauFormat(numFichier : SInt16) : SInt64;
var taille : SInt64;
begin
  taille := 0;

  with InfosFichiersNouveauFormat do
    if (numFichier > 0) and (numFichier <= nbFichiers) then
      with fichiers[numFichier] do
        begin
          case typeDonnees of

            kFicJoueursNouveauFormat, kFicJoueursCourtsNouveauFormat :
              taille := (TailleEnTeteNouveauFormat + entete.NombreEnregistrementsTournoisEtJoueurs * TailleJoueurRecNouveauFormat);

            kFicTournoisNouveauFormat, kFicTournoisCourtsNouveauFormat :
              taille := (TailleEnTeteNouveauFormat + entete.NombreEnregistrementsTournoisEtJoueurs * TailleTournoiRecNouveauFormat);

            kFicPartiesNouveauFormat :
              taille := (TailleEnTeteNouveauFormat + entete.NombreEnregistrementsParties * TaillePartieRecNouveauFormat);

          end; {case}
        end;

  TailleTheoriqueDeCeFichierNouveauFormat := taille;
end;



function CreeEnteteFichierIndexJoueursNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
var i,aux,nbTotalDeJoueurs,placeMemoireNecessaire,nbFichiersJoueurs : SInt64;
    result : t_EnTeteNouveauFormat;
begin
  with result do
    begin
      siecleCreation := 0;
      anneeCreation := 0;
      MoisCreation := 0;
      JourCreation := 0;
      NombreEnregistrementsParties := 0;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties := 0;
      PlaceMemoireIndex := 0;
    end;

  nbFichiersJoueurs := 0;
  placeMemoireNecessaire := 0;
  nbTotalDeJoueurs := 0;

  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees = kFicJoueursNouveauFormat) or (fichiers[i].typeDonnees = kFicJoueursCourtsNouveauFormat)) and
         (fichiers[i].typeDonnees = typeVoulu) then
        begin
          aux := NbJoueursDansFichierJoueursNouveauFormat(i);
          if aux > 0 then
            begin
              nbFichiersJoueurs := nbFichiersJoueurs+1;
              nbTotalDeJoueurs := nbTotalDeJoueurs+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;

              if EntetePlusRecentNouveauFormat(fichiers[i].entete,result) then
		            begin
		              result.siecleCreation := fichiers[i].entete.siecleCreation;
		              result.anneeCreation  := fichiers[i].entete.anneeCreation;
		              result.MoisCreation   := fichiers[i].entete.MoisCreation;
		              result.JourCreation   := fichiers[i].entete.JourCreation;
		            end;
            end;
        end;

  result.NombreEnregistrementsParties := nbTotalDeJoueurs;
  result.PlaceMemoireIndex := placeMemoireNecessaire;

  CreeEnteteFichierIndexJoueursNouveauFormat := result;
end;

function NbTotalDeTournoisDansFichiersNouveauFormat(typeVoulu : SInt16; var nbFichiersTournois,placeMemoireNecessaire : SInt64) : SInt64;
var i,aux,somme : SInt64;
begin
  nbFichiersTournois := 0;
  placeMemoireNecessaire := 0;

  somme := 0;
  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees = kFicTournoisNouveauFormat) or (fichiers[i].typeDonnees = kFicTournoisCourtsNouveauFormat)) and
         (fichiers[i].typeDonnees = typeVoulu) then
        begin
          aux := NbTournoisDansFichierTournoisNouveauFormat(i);
          if aux > 0 then
            begin
              nbFichiersTournois := nbFichiersTournois+1;
              somme := somme+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;
            end;
        end;
  NbTotalDeTournoisDansFichiersNouveauFormat := somme;
end;


function CreeEnteteFichierIndexTournoisNouveauFormat(typeVoulu : SInt16) : t_EnTeteNouveauFormat;
var i,aux,nbTotalDeTournois,placeMemoireNecessaire,nbFichiersTournois : SInt64;
    result : t_EnTeteNouveauFormat;
begin
  with result do
    begin
      siecleCreation := 0;
      anneeCreation := 0;
      MoisCreation := 0;
      JourCreation := 0;
      NombreEnregistrementsParties := 0;
      NombreEnregistrementsTournoisEtJoueurs := 0;
      AnneeParties := 0;
      PlaceMemoireIndex := 0;
    end;

  nbFichiersTournois := 0;
  placeMemoireNecessaire := 0;
  nbTotalDeTournois := 0;

  with InfosFichiersNouveauFormat do
    for i := 1 to nbFichiers do
      if ((fichiers[i].typeDonnees = kFicTournoisNouveauFormat) or (fichiers[i].typeDonnees = kFicTournoisCourtsNouveauFormat)) and
         (fichiers[i].typeDonnees = typeVoulu) then
        begin
          aux := NbTournoisDansFichierTournoisNouveauFormat(i);
          if aux > 0 then
            begin
              nbFichiersTournois := nbFichiersTournois+1;
              nbTotalDeTournois := nbTotalDeTournois+aux;
              placeMemoireNecessaire := placeMemoireNecessaire + (((aux-1) div 256)+1)*256 + 512;

              if EntetePlusRecentNouveauFormat(fichiers[i].entete,result) then
		            begin
		              result.siecleCreation := fichiers[i].entete.siecleCreation;
		              result.anneeCreation  := fichiers[i].entete.anneeCreation;
		              result.MoisCreation   := fichiers[i].entete.MoisCreation;
		              result.JourCreation   := fichiers[i].entete.JourCreation;
		            end;
            end;
        end;

  result.NombreEnregistrementsParties := nbTotalDeTournois;
  result.PlaceMemoireIndex := placeMemoireNecessaire;

  CreeEnteteFichierIndexTournoisNouveauFormat := result;
end;

procedure EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
var numFichier,k : SInt16;
    found : boolean;
begin
  with InfosFichiersNouveauFormat do
    for k := 1 to nbFichiers do
      if fichiers[k].typeDonnees = kFicIndexPartiesNouveauFormat then
        begin  {on cherche le fichier de parties correspondant a cet index}
          found := false;
          numFichier := 1;
          repeat
            if (numFichier <= nbFichiers) and (numFichier <> k) and
               (fichiers[numFichier].typeDonnees = kFicPartiesNouveauFormat) and
               (fichiers[numFichier].parID       = fichiers[k].parID) and
               (fichiers[numFichier].vRefNum     = fichiers[k].vRefNum) and
               (fichiers[numFichier].annee       = fichiers[k].annee) and
               (EntetesEgauxNouveauFormat(fichiers[k].entete,fichiers[numFichier].entete)) then
                 begin
		               found := true;
		               fichiers[numFichier].NroFichierDual := k;
		               fichiers[k         ].NroFichierDual := numFichier;
		             end;
		        numFichier := succ(numFichier);
          until found or (numFichier > nbFichiers);
        end;
end;


function OrdreAlphabetiqueSurJoueurs(n1,n2 : SInt64) : boolean;
var s1,s2 : String255;
begin
  s1 := GetNomJoueur(n1);
  s2 := GetNomJoueur(n2);
  s1 := UpperCase(s1,false);
  s2 := UpperCase(s2,false);
  OrdreAlphabetiqueSurJoueurs := s1 >= s2 ;
end;


procedure TrierAlphabetiquementJoueursNouveauFormat;
var k : SInt64;
    permutation : LongintArrayPtr;
begin
  with JoueursNouveauFormat do
    if nbJoueursNouveauFormat > 0 then
      begin
        if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant "if LitFichierIndexDesJoueursTries(false) = NoErr…" dans TrierAlphabetiquementJoueursNouveauFormat',true);
        if LitFichierIndexDesJoueursTries(false) = NoErr
          then
            begin
              dejaTriesAlphabetiquement := true;
            end
          else
            begin
              permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxJoueursEnMemoire+2)*sizeof(SInt32)));
			        if permutation = NIL
			          then SysBeep(0)
			          else
			            begin
			              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant GeneralQuickSort dans TrierAlphabetiquementJoueursNouveauFormat',true);
			              GeneralQuickSort(0,nbJoueursNouveauFormat-1,GetNroOrdreAlphabetiqueJoueur,SetNroOrdreAlphabetiqueJoueur,OrdreAlphabetiqueSurJoueurs);
                    if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Apres GeneralQuickSort dans TrierAlphabetiquementJoueursNouveauFormat',true);
                    {on inverse la permutation}
			              for k := 0 to nbJoueursNouveauFormat-1 do permutation^[GetNroOrdreAlphabetiqueJoueur(k)] := k;
			              for k := 0 to nbJoueursNouveauFormat-1 do SetNroOrdreAlphabetiqueJoueur(k,permutation^[k]);
			              dejaTriesAlphabetiquement := true;
			              if debuggage.pendantLectureBase then WritelnDansRapportEtAttendFrappeClavier('Avant "if EcritFichierIndexDesJoueursTries(false) = NoErr" dans TrierAlphabetiquementJoueursNouveauFormat',true);
			              if EcritFichierIndexDesJoueursTries(false) = NoErr then DoNothing;
			            end;
			        if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
            end;
      end;
end;



function OrdreAlphabetiqueSurTournois(n1,n2 : SInt64) : boolean;
var s1,s2 : String255;
begin
  s1 := GetNomTournoi(n1);
  s2 := GetNomTournoi(n2);
  s1 := UpperCase(s1,false);
  s2 := UpperCase(s2,false);
  OrdreAlphabetiqueSurTournois := s1 >= s2 ;
end;


procedure TrierAlphabetiquementTournoisNouveauFormat;
var k : SInt64;
    permutation : LongintArrayPtr;
begin
  with TournoisNouveauFormat do
    if nbTournoisNouveauFormat > 0 then
      begin
        if (LitFichierIndexDesTournoisTries(false) = NoErr)
          then
            begin
              dejaTriesAlphabetiquement := true;
            end
          else
            begin
              permutation := LongintArrayPtr(AllocateMemoryPtr((nbMaxTournoisEnMemoire+2)*sizeof(SInt32)));
			        if permutation = NIL
			          then SysBeep(0)
			          else
			            begin
                    GeneralQuickSort(0,nbTournoisNouveauFormat-1,GetNroOrdreAlphabetiqueTournoi,SetNroOrdreAlphabetiqueTournoi,OrdreAlphabetiqueSurTournois);
                    {on inverse la permutation}
			              for k := 0 to nbTournoisNouveauFormat-1 do permutation^[GetNroOrdreAlphabetiqueTournoi(k)] := k;
			              for k := 0 to nbTournoisNouveauFormat-1 do SetNroOrdreAlphabetiqueTournoi(k,permutation^[k]);
			              dejaTriesAlphabetiquement := true;
			              if EcritFichierIndexDesTournoisTries(false) = NoErr then DoNothing;
			            end;
			        if permutation <> NIL then DisposeMemoryPtr(Ptr(permutation));
            end;
      end;
end;


procedure GetDistributionsALireFromPrefsFile;
var err : OSErr;
    s,motClef,bidStr,chainePref : String255;
    k : SInt16;
begin
  with ChoixDistributions,DistributionsNouveauFormat do
    if OpenPrefsFileForSequentialReading = NoErr then
	    begin
	      genre := kToutesLesDistributions;
	      DistributionsALire := [];

	      while not(EOFInPrefsFile) do
	        begin
	          err := GetNextLineInPrefsFile(s);
	          if err = NoErr then
	            begin
	              Parse2(s,motClef,bidStr,chainePref);
	              if motClef = '%quellesBasesLire' then
	                begin
	                  if chainePref = 'ToutesLesDistributions' then genre := kToutesLesDistributions else
	                  if chainePref = 'QuelquesDistributions'  then genre := kQuelquesDistributions else
	                  if chainePref = 'AucuneDistribution'     then genre := kAucuneDistribution;
	                end;
	              if motClef = '%baseActive' then
	                begin
	                  chainePref := ReplaceStringOnce(chainePref, '$CASSIO_FOLDER:',pathCassioFolder);
	                  for k := 1 to nbDistributions do
	                    if (Distribution[k].path <> NIL) and (Distribution[k].name <> NIL) and
	                       (chainePref = Distribution[k].path^+Distribution[k].name^) then
	                       DistributionsALire := DistributionsALire+[k];
	                  end;
	            end;
	        end;
	      err := ClosePrefsFile;
	    end;
end;

procedure LecturePreparatoireDossierDatabase(pathDossierEnglobant : String255; fonctionAppelante : String255);
var trouve,temp : boolean;
    k : SInt16;
    ticks : SInt64;
    iterateurCassioFolderPaths : String255;
begin

  Discard2(k,fonctionAppelante);

  // ne pas reentrer
  if (InfosFichiersNouveauFormat.nbFichiers > 0) or pendantLecturePreparatoireDossierDatabase
    then exit;

  temp := pendantLecturePreparatoireDossierDatabase;
  pendantLecturePreparatoireDossierDatabase := true;

  ticks := TickCount;
  nbAppelsShareTimeWithOtherProcesses := 0;

  if not(Quitter or gPendantLesInitialisationsDeCassio) then
    begin
      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;

  iterateurCassioFolderPaths := BeginIterationOnCassioFolderPaths(pathDossierEnglobant);

  repeat

    ChercheFichiersNouveauFormatDansDossier(0,iterateurCassioFolderPaths+'Database',trouve);
    if not(trouve) then ChercheFichiersNouveauFormatDansDossier(0,iterateurCassioFolderPaths+'Database ',trouve);
    if not(trouve) then ChercheFichiersNouveauFormatDansDossier(0,iterateurCassioFolderPaths+'Database (alias)',trouve);

    if trouve
      then AddValidCassioFolderPath(iterateurCassioFolderPaths)
      else iterateurCassioFolderPaths := TryNextCassioFolderPath;

  until trouve or (iterateurCassioFolderPaths = '');



  TrierListeFichiersNouveauFormat;
  EtablitLiaisonEntrePartiesEtIndexNouveauFormat;
  GetDistributionsALireFromPrefsFile;
  ReparerFichiersSolitaires;

  RemettreLeCurseurNormalDeCassio;

  {WritelnNumDansRapport('nb distrib =',DistributionsNouveauFormat.nbDistributions);
  for k := 1 to DistributionsNouveauFormat.nbDistributions do
    WritelnDansRapport('nomUsuel = '+DistributionsNouveauFormat.distribution[k].nomUsuel^);}

  {
  WritelnNumDansRapport('temps de LecturePreparatoireDossierDatabase = ',TickCount - ticks);
  WritelnNumDansRapport('nbAppelsShareTimeWithOtherProcesses = ',nbAppelsShareTimeWithOtherProcesses);
  }

  pendantLecturePreparatoireDossierDatabase := temp;
end;


end.
