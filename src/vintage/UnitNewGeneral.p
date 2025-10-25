UNIT UnitNewGeneral;





INTERFACE







 uses UnitDefCassio;







{inititialisation et destruction de l'unite}
procedure InitUnitNewGeneral;
procedure LibereMemoireUnitNewGeneral;

{teste de la memoire}
function CassioEnEnvironnementMemoireLimite : boolean;
procedure EcritEtatMemoire;
function GetEspaceDisponibleLancementCassio : SInt32;

{memoire pour la base}
procedure DisposeTousHandlesBase;
function AllocateTousHandlesBase(nbParties : SInt32) : OSErr;
procedure ChangeNbPartiesChargeablesPourBase(nouveauNbPartiesChargeables : SInt32);


procedure VerificationNewGeneral;
procedure VerificationAllocationMemoireBase;
procedure InitialisePartieHdlAuToutDebut;
procedure ReInitialisePartieHdlPourNouvellePartie(DetruitArbreDeJeu : boolean);
function CalculeNbrePartiesOptimum(tailleDisponiblePourLaBase : SInt32) : SInt32;
procedure GetParamDiag(var paramDiag : ParamDiagRec);
procedure SetParamDiag(var paramDiag : ParamDiagRec);
procedure CopyCommentParamDiag(var source,dest : ParamDiagRec);
procedure NewParamDiag(var paramDiag : ParamDiagRec);
procedure DisposeParamDiag(var paramDiag : ParamDiagRec);
procedure NewGeneral;
procedure DisposeGeneral;



function GetTailleReserveePourLesSegments : SInt32;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound, MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitArbreDeJeuCourant, UnitNouveauFormat, UnitHashTableExacte, UnitListe, UnitStatistiques
    , UnitRapport, UnitServicesMemoire, SNMenus, UnitOth2, UnitBlocsDeCoin ;
{$ELSEC}
    ;
    {$I prelink/NewGeneral.lk}
{$ENDC}


{END_USE_CLAUSE}











const kTailleNecessaireParPartie = 88;


var EspaceDisponibleLancementCassio : SInt32;
    TailleReserveePourLesSegments : SInt32;


procedure InitUnitNewGeneral;
var unetaille,grow : Size;
begin

  EspaceDisponibleLancementCassio := FreeMem;
  grow := 0;
  unetaille := MaxMem(grow);
  EspaceDisponibleLancementCassio := FreeMem;


  if CassioEnEnvironnementMemoireLimite
    then TailleReserveePourLesSegments := 1500000
    else TailleReserveePourLesSegments := 4000000;
end;


procedure LibereMemoireUnitNewGeneral;
begin
end;


function GetTailleReserveePourLesSegments : SInt32;
begin
  GetTailleReserveePourLesSegments := TailleReserveePourLesSegments;
end;

procedure DisposeTousHandlesBase;
begin

  if tableBooleensDeLaListe        <> NIL then DisposeMemoryPtr(Ptr(tableBooleensDeLaListe));
  if tableDistributionDeLaPartie   <> NIL then DisposeMemoryPtr(Ptr(tableDistributionDeLaPartie));
  if CriteresSuplementaires        <> NIL then DisposeMemoryHdl(Handle(CriteresSuplementaires));
  if statistiques                  <> NIL then DisposeMemoryHdl(Handle(statistiques));
  if tableTriListe                 <> NIL then DisposeMemoryHdl(Handle(tableTriListe));
  if tableTriListeAux              <> NIL then DisposeMemoryHdl(Handle(tableTriListeAux));
  if tableAnneeParties             <> NIL then DisposeMemoryHdl(Handle(tableAnneeParties));
  if tableNumeroReference          <> NIL then DisposeMemoryHdl(Handle(tableNumeroReference));

  tableBooleensDeLaListe := NIL;
  tableDistributionDeLaPartie := NIL;
  CriteresSuplementaires := NIL;
  tableTriListe := NIL;
  tableTriListeAux := NIL;
  tableAnneeParties := NIL;
  tableNumeroReference := NIL;
  statistiques := NIL;

  problemeMemoireBase := true;
end;

function AllocateTousHandlesBase(nbParties : SInt32) : OSErr;
var uneTaille,uneTailleInteger,uneTailleLongint : SInt32;

  procedure QuitteEnCatastrophe;
    begin
      tableBooleensDeLaListe := NIL;
	    tableDistributionDeLaPartie := NIL;
	    tableAnneeParties := NIL;
	    tableTriListe := NIL;
	    tableTriListeAux := NIL;
	    tableNumeroReference := NIL;
	    statistiques := NIL;
	    CriteresSuplementaires := NIL;

	    problemeMemoireBase := true;
	    AllocateTousHandlesBase := -1;
    end;

  procedure RapporteErreurEtQuitte(s : String255; x,y : SInt32);
    begin {$UNUSED s,x,y}
      TraceLog('ERREUR dans AllocateTousHandlesBase : '+s);
      QuitteEnCatastrophe;
    end;

begin
  AllocateTousHandlesBase := NoErr;

  if nbParties < 0 then
    begin
      {RapporteErreurEtQuitte('nbParties <= 0',10,40);}
      QuitteEnCatastrophe;
    end;

  Unetaille := nbParties+1;        { sizeof(UInt8) = 1 octet }
  tableBooleensDeLaListe := tableBaseBytePtr(AllocateMemoryPtr(Unetaille));
  if tableBooleensDeLaListe = NIL
    then RapporteErreurEtQuitte('tableBooleensDeLaListe',10,40);

  Unetaille := nbParties+1;
  UnetailleInteger := 2*uneTaille;           { sizeof(SInt16) = 2 octets }
  UneTailleLongint := 4*uneTaille;

  tableDistributionDeLaPartie := tableBaseBytePtr(AllocateMemoryPtrClear(Unetaille));
  if tableDistributionDeLaPartie = NIL
    then RapporteErreurEtQuitte('tableDistributionDeLaPartie',10,40);

  tableAnneeParties := tableReferencesPartieHdl(AllocateMemoryHdl(UneTailleInteger));
  if tableAnneeParties = NIL
    then RapporteErreurEtQuitte('tableAnneeParties',10,40);


  tableTriListe := tableNumeroHdl(AllocateMemoryHdl(UneTailleLongint));
  if tableTriListe = NIL
    then RapporteErreurEtQuitte('tableTriListe',10,40);

  tableTriListeAux := tableNumeroHdl(AllocateMemoryHdl(UneTailleLongint));
  if tableTriListeAux = NIL
    then RapporteErreurEtQuitte('tableTriListeAux',10,40);

  tableNumeroReference := tableNumeroHdl(AllocateMemoryHdl(UneTailleLongint));
  if tableNumeroReference = NIL
    then RapporteErreurEtQuitte('tableNumeroReference',10,40);


  statistiques := statistiqueHdl(AllocateMemoryHdl(sizeof(t_statistique)));
  CriteresSuplementaires := CriteresHdl(AllocateMemoryHdl(sizeof(criteresRec)));


  (*
  unetaille := nbParties+1;
  unetaille := sizeof(String255)*unetaille;    { sizeof(String255) = 256 octets }
  tableStockagePartie := AllocateMemoryHdl(unetaille);
  if tableStockagePartie = NIL
    then RapporteErreurEtQuitte('tableStockagePartie',10,40);
  *)
end;

procedure VerificationAllocationMemoireBase;
var i : SInt32;
begin
  if tableBooleensDeLaListe <> NIL then
    begin
      InitSelectionDeLaListe;
      SetAucunePartieDeLaListeNeDoitEtreSauvegardee;
      SetAucunePartieDeLaListeNEstDouteuse;
      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
      for i := 0 to nbrePartiesEnMemoire do
        SetPartieCompatibleParCriteres(i,true);
    end;
  if CriteresSuplementaires <> NIL then
    begin
      CriteresSuplementaires^^.CriteresNoir := '√√√√√√';
      CriteresSuplementaires^^.CriteresBlanc := '√√√√√√';
      CriteresSuplementaires^^.CriteresTournoi := '√√√√';
      CriteresSuplementaires^^.CriteresDistribution := '√√√√';
    end;

  SetStatistiquesCalculsFaitsAuMoinsUneFois(false);

  if not(gIsRunningUnderMacOSX) then
    begin
		  if (tableBooleensDeLaListe = NIL) then TraceLog('VerificationAllocationMemoireBase : tableBooleensDeLaListe = NIL');
		  if (tableDistributionDeLaPartie = NIL) then TraceLog('VerificationAllocationMemoireBase : tableDistributionDeLaPartie = NIL');
		  if (CriteresSuplementaires = NIL) then TraceLog('VerificationAllocationMemoireBase : CriteresSuplementaires = NIL');
		  if (tableTriListe = NIL) then TraceLog('VerificationAllocationMemoireBase : tableTriListe = NIL');
		  if (tableTriListeAux = NIL) then TraceLog('VerificationAllocationMemoireBase : tableTriListeAux = NIL');
		  if (tableAnneeParties = NIL) then TraceLog('VerificationAllocationMemoireBase : tableAnneeParties = NIL');
		  if (tableNumeroReference = NIL) then TraceLog('VerificationAllocationMemoireBase : tableNumeroReference = NIL');
		  if (statistiques = NIL) then TraceLog('VerificationAllocationMemoireBase : statistiques = NIL');
		end;


  if (tableBooleensDeLaListe = NIL)          or
     (tableDistributionDeLaPartie = NIL)     or
     (CriteresSuplementaires = NIL)          or
     (tableTriListe = NIL)                   or
     (tableTriListeAux = NIL)                or
     (tableAnneeParties = NIL)               or
     (tableNumeroReference = NIL)            or
     (statistiques = NIL)
        then
          begin
            DisposeTousHandlesBase;
            problemeMemoireBase := true;
            {TraceLog('VerificationAllocationMemoireBase : problemeMemoireBase !!');}
          end
        else
          begin
            problemeMemoireBase := false;
            {TraceLog('VerificationAllocationMemoireBase : pas de probleme de memoire de base');}
          end;
end;

procedure VerificationNewGeneral;
var i,j : SInt32;
begin
  if valeurBord <> NIL
    then MemoryFillChar(valeurBord,sizeof(valeurBord^),chr(0))
    else StoppeEtAfficheMessageAt('valeurBord',10,40);
  if valeurBlocsDeCoin <> NIL
    then MemoryFillChar(valeurBlocsDeCoin,sizeof(valeurBlocsDeCoin^),chr(0))
    else StoppeEtAfficheMessageAt('valeurBlocsDeCoins',10,40);
(* les tables suivantes sont Initialisees dans UnitBords.p   *)
  {if table_Turbulence_mono <> NIL
    then MemoryFillChar(table_Turbulence_mono,sizeof(table_Turbulence_mono^),chr(0))
    else StoppeEtAfficheMessageAt('table_Turbulence_mono',10,40);
  if table_Turbulence_bi <> NIL
    then MemoryFillChar(table_Turbulence_bi,sizeof(table_Turbulence_bi^),chr(0))
    else StoppeEtAfficheMessageAt('table_Turbulence_bi',10,40);
  if table_Turbulence_alpha_beta_local <> NIL
    then MemoryFillChar(table_Turbulence_alpha_beta_local,sizeof(table_Turbulence_alpha_beta_local^),chr(0))
    else StoppeEtAfficheMessageAt('table_Turbulence_alpha_beta_local',10,40); }
  if ReflexData <> NIL
    then MemoryFillChar(ReflexData,sizeof(ReflexData^),chr(0))
    else StoppeEtAfficheMessageAt('ReflexData',10,40);
  if suiteJoueeGlb <> NIL
    then MemoryFillChar(suiteJoueeGlb,sizeof(suiteJoueeGlb^),chr(0))
    else StoppeEtAfficheMessageAt('suiteJoueeGlb',10,40);
  if meilleureSuiteGlb <> NIL
    then MemoryFillChar(meilleureSuiteGlb,sizeof(meilleureSuiteGlb^),chr(0))
    else StoppeEtAfficheMessageAt('meilleureSuiteGlb',10,40);
  if ParametresOuvrirThor <> NIL
    then for i := 1 to 5 do ParametresOuvrirThor^^[i] := ''
    else StoppeEtAfficheMessageAt('ParametresOuvrirThor',10,40);
  if TableSolitaire <> NIL
    then
      begin
        TableSolitaire^^.nbCasesVidesMin := 0;
        TableSolitaire^^.nbCasesVidesMax := 0;
        for i := 1 to SolitairesEnMemoire do
          TableSolitaire^^.chaines[i] := ''
      end
    else StoppeEtAfficheMessageAt('TableSolitaire',10,40);

  for j := 0 to nbTablesHashExactes-1 do
    if HashTableExacte[j] <> NIL
      then for i := 0 to 1023 do SetTraitDansHashExacte(pionVide,HashTableExacte[j]^[i])
      else StoppeEtAfficheMessageAt('HashTableExacte',10,40);
  for j := 0 to nbTablesHashExactes-1 do
    if CoupsLegauxHash[j] <> NIL
      then MemoryFillChar(CoupsLegauxHash[j],sizeof(CoupsLegauxHash[j]^),chr(0))
      else StoppeEtAfficheMessageAt('CoupsLegauxHash',10,40);
  if tableLignes <> NIL
    then tableLignes^.cardinal := 0
    else StoppeEtAfficheMessageAt('tableLignes',10,40);
  if Groupes <> NIL
    then for i := 1 to nbMaxGroupes do Groupes^^[i] := ''
    else StoppeEtAfficheMessageAt('Groupes',10,40);

  if partie <> NIL
    then InitialisePartieHdlAuToutDebut
    else StoppeEtAfficheMessageAt('partie',10,40);

  if HashTable = NIL then StoppeEtAfficheMessageAt('HashTable',10,40);
  if IndiceHash = NIL then StoppeEtAfficheMessageAt('IndiceHash',10,40);
  if bibliothequeEnTas = NIL then StoppeEtAfficheMessageAt('bibliothequeEnTas',10,40);
  if bibliothequeIndex = NIL then StoppeEtAfficheMessageAt('bibliothequeIndex',10,40);
  if BibliothequeNbReponse = NIL then StoppeEtAfficheMessageAt('BibliothequeNbReponse',10,40);
  if bibliothequeReponses = NIL then StoppeEtAfficheMessageAt('bibliothequeReponses',10,40);
  if interversionCanonique = NIL then StoppeEtAfficheMessageAt('interversionCanonique',10,40);
  if TableInfoDejaCalculee = NIL then StoppeEtAfficheMessageAt('TableInfoDejaCalculee',10,40);


  VerificationAllocationMemoireBase;
end;


procedure InitialisePartieHdlAuToutDebut;
begin
  HLockHi(Handle(partie));
  MemoryFillChar(partie^,sizeof(partie^^),chr(0));
  HUnlock(Handle(partie));
end;

procedure ReInitialisePartieHdlPourNouvellePartie(DetruitArbreDeJeu : boolean);
begin
  HLockHi(Handle(partie));
  MemoryFillChar(partie^,sizeof(partie^^),chr(0));
  HUnlock(Handle(partie));
  if DetruitArbreDeJeu then ReInitialiseGameRootGlobalDeLaPartie;
end;

function CassioEnEnvironnementMemoireLimite : boolean;
begin
  CassioEnEnvironnementMemoireLimite := (EspaceDisponibleLancementCassio <= 5000000);
end;


function GetEspaceDisponibleLancementCassio : SInt32;
begin
  GetEspaceDisponibleLancementCassio := EspaceDisponibleLancementCassio;
end;


procedure EcritEtatMemoire;
var memoire : SInt32;
    grow : Size;
begin
  {on compacte la memoire, puis on affiche quelques statistiques}
  memoire := FreeMem;

  WritelnDansRapport('• Les statistiques suivantes ne sont pas pertinentes sous Mac OS X');

  memoire := SInt32(TopMem);
  WritelnNumDansRapport('   mémoire totale (en octets) : ',memoire);
  WritelnNumDansRapport('   mémoire totale (en kilos) : ',memoire div 1024);

  memoire := GetEspaceDisponibleLancementCassio;
  WritelnNumDansRapport('   mémoire disponible au lancement de Cassio (en octets) : ',memoire);
  WritelnNumDansRapport('   mémoire disponible au lancement de Cassio (en kilos) : ',memoire div 1024);

  grow := 0;
  memoire := FreeMem - GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('   mémoire disponible maintenant (en octets) : ',memoire);
  WritelnNumDansRapport('   mémoire disponible maintenant (en kilos) : ',memoire div 1024);

  grow := 0;
  memoire := MaxMem(grow)-GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('   plus gros bloc initialisable maintenant (en octets) : ',memoire);
  WritelnNumDansRapport('   plus gros bloc initialisable maintenant (en kilos) : ',memoire div 1024);

  memoire := GetTailleReserveePourLesSegments;
  WritelnNumDansRapport('   taille réservée pour les segments (en octets) : ',memoire);
  WritelnNumDansRapport('   taille réservée pour les segments (en kilos) : ',memoire div 1024);

  memoire := nbTablesHashExactes * (sizeof(CoupsLegauxHashArray) + sizeof(HashTableExacteRec));
  WritelnNumDansRapport('   nbre de tables de hachage : ',nbTablesHashExactes);
  WritelnNumDansRapport('   mémoire utilisée par les tables de hachage (en octets) : ',memoire);
  WritelnNumDansRapport('   mémoire utilisée par les tables de hachage (en kilos) : ',memoire div 1024);

  memoire := nbrePartiesEnMemoire * kTailleNecessaireParPartie;
  WritelnNumDansRapport('   nbre parties chargeables pour la base WThor: ',nbrePartiesEnMemoire);
  WritelnNumDansRapport('   mémoire utilisée par la base (en octets) : ',memoire);
  WritelnNumDansRapport('   mémoire utilisée par la base (en kilos) : ',memoire div 1024);

  WritelnStringAndBooleenDansRapport('   CassioEnEnvironnementMemoireLimite = ',CassioEnEnvironnementMemoireLimite);
  WritelnDansRapport('');

end;


function CalculeNbrePartiesOptimum(tailleDisponiblePourLaBase : SInt32) : SInt32;
var aux : SInt32;
begin

  aux := tailleDisponiblePourLaBase div kTailleNecessaireParPartie;
  if aux < 0 then aux := 0;
  aux := 50*(aux div 50);
  if aux > nbMaxPartChargeables then aux := nbMaxPartChargeables;

  CalculeNbrePartiesOptimum := aux;
end;




procedure GetParamDiag(var paramDiag : ParamDiagRec);
begin
  with paramDiag do
    begin
      TypeDiagrammeFFORUM         := ParamDiagCourant.TypeDiagrammeFFORUM;
      DecalageHorFFORUM           := ParamDiagCourant.DecalageHorFFORUM;
      DecalageVertFFORUM          := ParamDiagCourant.DecalageVertFFORUM;
      tailleCaseFFORUM            := ParamDiagCourant.tailleCaseFFORUM;
      epaisseurCadreFFORUM        := ParamDiagCourant.epaisseurCadreFFORUM;
      distanceCadreFFORUM         := ParamDiagCourant.distanceCadreFFORUM;
      PionsEnDedansFFORUM         := ParamDiagCourant.PionsEnDedansFFORUM;
      nbPixelDedansFFORUM         := ParamDiagCourant.nbPixelDedansFFORUM;
      DessineCoinsDuCarreFFORUM   := ParamDiagCourant.DessineCoinsDuCarreFFORUM;
      DessinePierresDeltaFFORUM   := ParamDiagCourant.DessinePierresDeltaFFORUM;
      EcritApres37c7FFORUM        := ParamDiagCourant.EcritApres37c7FFORUM;
      EcritNomTournoiFFORUM       := ParamDiagCourant.EcritNomTournoiFFORUM;
      EcritNomsJoueursFFORUM      := ParamDiagCourant.EcritNomsJoueursFFORUM;
      PoliceFFORUMID              := ParamDiagCourant.PoliceFFORUMID;
      CoordonneesFFORUM           := ParamDiagCourant.CoordonneesFFORUM;
      TraitsFinsFFORUM            := ParamDiagCourant.TraitsFinsFFORUM;
      NumerosSeulementFFORUM      := ParamDiagCourant.NumerosSeulementFFORUM;
      FondOthellierPatternFFORUM  := ParamDiagCourant.FondOthellierPatternFFORUM;
      CouleurOthellierFFORUM      := ParamDiagCourant.CouleurOthellierFFORUM;
      CouleurRGBOthellierFFORUM   := ParamDiagCourant.CouleurRGBOthellierFFORUM;
      CommentPositionFFORUM^^     := ParamDiagCourant.CommentPositionFFORUM^^;
      TitreFFORUM^^               := ParamDiagCourant.titreFFORUM^^;
    end;
end;

procedure SetParamDiag(var paramDiag : ParamDiagRec);
begin
  with paramDiag do
    begin
      ParamDiagCourant.TypeDiagrammeFFORUM        := TypeDiagrammeFFORUM;
      ParamDiagCourant.DecalageHorFFORUM          := DecalageHorFFORUM;
      ParamDiagCourant.DecalageVertFFORUM         := DecalageVertFFORUM;
      ParamDiagCourant.tailleCaseFFORUM           := tailleCaseFFORUM;
      ParamDiagCourant.epaisseurCadreFFORUM       := epaisseurCadreFFORUM;
      ParamDiagCourant.distanceCadreFFORUM        := distanceCadreFFORUM;
      ParamDiagCourant.PionsEnDedansFFORUM        := PionsEnDedansFFORUM;
      ParamDiagCourant.nbPixelDedansFFORUM        := nbPixelDedansFFORUM;
      ParamDiagCourant.DessineCoinsDuCarreFFORUM  := DessineCoinsDuCarreFFORUM;
      ParamDiagCourant.DessinePierresDeltaFFORUM  := DessinePierresDeltaFFORUM;
      ParamDiagCourant.EcritApres37c7FFORUM       := EcritApres37c7FFORUM;
      ParamDiagCourant.EcritNomTournoiFFORUM      := EcritNomTournoiFFORUM;
      ParamDiagCourant.EcritNomsJoueursFFORUM     := EcritNomsJoueursFFORUM;
      ParamDiagCourant.PoliceFFORUMID             := PoliceFFORUMID;
      ParamDiagCourant.CoordonneesFFORUM          := CoordonneesFFORUM;
      ParamDiagCourant.TraitsFinsFFORUM           := TraitsFinsFFORUM;
      ParamDiagCourant.NumerosSeulementFFORUM     := NumerosSeulementFFORUM;
      ParamDiagCourant.FondOthellierPatternFFORUM := FondOthellierPatternFFORUM;
      ParamDiagCourant.CouleurOthellierFFORUM     := CouleurOthellierFFORUM;
      ParamDiagCourant.CouleurRGBOthellierFFORUM  := CouleurRGBOthellierFFORUM;
      ParamDiagCourant.CommentPositionFFORUM^^    := CommentPositionFFORUM^^;
      ParamDiagCourant.titreFFORUM^^              := TitreFFORUM^^;
    end;
end;

procedure CopyCommentParamDiag(var source,dest : ParamDiagRec);
begin
  dest.CommentPositionFFORUM^^  := source.CommentPositionFFORUM^^;
  dest.titreFFORUM^^            := source.TitreFFORUM^^;
end;

procedure NewParamDiag(var paramDiag : ParamDiagRec);
begin
  paramDiag.CommentPositionFFORUM := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  paramDiag.TitreFFORUM := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  paramDiag.CommentPositionFFORUM^^ := '';
  paramDiag.TitreFFORUM^^ := '';
  paramDiag.CouleurRGBOthellierFFORUM := gPurNoir;
end;

procedure DisposeParamDiag(var paramDiag : ParamDiagRec);
begin
  if paramDiag.commentPositionFFORUM <> NIL
    then DisposeMemoryHdl(Handle(paramDiag.commentPositionFFORUM));
  if paramDiag.TitreFFORUM <> NIL
    then DisposeMemoryHdl(Handle(paramDiag.TitreFFORUM));
  paramDiag.commentPositionFFORUM := NIL;
  paramDiag.TitreFFORUM := NIL;
end;


procedure NewGeneral;
var Unetaille : Size;
    j,grow,aux : SInt32;
    erreur : OSErr;
begin
  for j := 0 to nbMaxTablesHashExactes do
    begin
      CoupsLegauxHash[j] := NIL;
      HashTableExacte[j] := NIL;
    end;
  valeurBord := NIL;
  (*
  nbOccurencesLigne8 := NIL;
  nbOccurencesLigne7 := NIL;
  nbOccurencesLigne6 := NIL;
  nbOccurencesLigne5 := NIL;
  nbOccurencesLigne4 := NIL;
  *)
  valeurBlocsDeCoin := NIL;
  table_Turbulence_mono := NIL;
  table_Turbulence_bi := NIL;
  table_Turbulence_alpha_beta_local := NIL;
  ReflexData := NIL;
  HashTable := NIL;
  IndiceHash := NIL;
  tableLignes := NIL;
  Groupes := NIL;
  bibliothequeEnTas := NIL;
  bibliothequeIndex := NIL;
  BibliothequeNbReponse := NIL;
  bibliothequeReponses := NIL;
  interversionCanonique := NIL;
  suiteJoueeGlb := NIL;
  meilleureSuiteGlb := NIL;
  ParametresOuvrirThor := NIL;
  TableSolitaire := NIL;
  TableInfoDejaCalculee := NIL;
  IndexInfoDejaCalculeesCoupNro := NIL;
  derniereChaineComplementation := NIL;
  CheminAccesThorDBA := NIL;
  CheminAccesThorDBASolitaire := NIL;
  CheminAccesSolitaireCassio := NIL;
  for j := 1 to NbMaxItemsReouvrirMenu do
    begin
      nomDuFichierAReouvrir[j] := NIL;
      nomLongDuFichierAReouvrir[j] := NIL;
    end;
  gInterVarianteAlaVolee := -1;
  tableBooleensDeLaListe := NIL;
  tableDistributionDeLaPartie := NIL;
  CriteresSuplementaires := NIL;
  tableTriListe := NIL;
  tableTriListeAux := NIL;
  tableAnneeParties := NIL;
  tableNumeroReference := NIL;
  statistiques := NIL;

  for j := 0 to nbTablesHashExactes-1 do
    begin
      CoupsLegauxHash[j] := CoupsLegauxHashPtr(AllocateMemoryPtr(sizeof(CoupsLegauxHashArray)));
      HashTableExacte[j] := HashTableExactePtr(AllocateMemoryPtr(sizeof(HashTableExacteRec)));
    end;
  valeurBord := tableBordsPtr(AllocateMemoryPtr(sizeof(t_tableBords)));
  valeurBlocsDeCoin := tableBlocsDeCoinPtr(AllocateMemoryPtr(sizeof(t_table_BlocsDeCoin)));
  (*
  nbOccurencesLigne8 := tableLigne8Ptr(AllocateMemoryPtr(sizeof(t_table_Centralite_ligne_de_8)));
  nbOccurencesLigne7 := tableLigne7Ptr(AllocateMemoryPtr(sizeof(t_table_Centralite_ligne_de_7)));
  nbOccurencesLigne6 := tableLigne6Ptr(AllocateMemoryPtr(sizeof(t_table_Centralite_ligne_de_6)));
  nbOccurencesLigne5 := tableLigne5Ptr(AllocateMemoryPtr(sizeof(t_table_Centralite_ligne_de_5)));
  nbOccurencesLigne4 := tableLigne4Ptr(AllocateMemoryPtr(sizeof(t_table_Centralite_ligne_de_4)));
  *)
  tableLignes := TableParties60Ptr(AllocateMemoryPtr(SizeOf(TableParties60Rec)));
  table_Turbulence_mono := table_SignedBytePtr(AllocateMemoryPtr(sizeof(t_table_SignedByte)));
  table_Turbulence_bi := table_SignedBytePtr(AllocateMemoryPtr(sizeof(t_table_SignedByte)));
  table_Turbulence_alpha_beta_local := tableBordsPtr(AllocateMemoryPtr(sizeof(t_tableBords)));
  ReflexData := ReflexRecPtr(AllocateMemoryPtr(sizeof(reflexRec)));
  Unetaille := 32768;
  HashTable := HashTableHdl(AllocateMemoryHdl(Unetaille));
  IndiceHash := IndiceHashHdl(AllocateMemoryHdl(sizeof(IndiceHashArray)));
  Groupes := GroupesHdl(AllocateMemoryHdl(sizeof(GroupesRec)));
  bibliothequeEnTas := BibliothequeEnTasHdl(AllocateMemoryHdl(sizeof(BibliothequeEnTasRec)));
  bibliothequeIndex := BibliothequeIndexHdl(AllocateMemoryHdl(sizeof(BibliothequeIndexRec)));
  BibliothequeNbReponse := BibliothequeNbReponseHdl(AllocateMemoryHdl(sizeof(BibliothequeNbReponseRec)));
  bibliothequeReponses := bibliothequeReponsesHdl(AllocateMemoryHdl(sizeof(bibliothequeReponsesRec)));
  indexCommentaireBibl := tableIndexCommentaireOuvHdl(AllocateMemoryHdl(sizeof(tableIndexCommentaireOuv)));
  commentaireBiblEnTas := tableCommentaireOuvHdl(AllocateMemoryHdl(sizeof(tableCommentaireOuv)));
  interversionCanonique := interversionHdl(AllocateMemoryHdl(sizeof(t_interversion)));
  interversionFautive := interversionHdl(AllocateMemoryHdl(sizeof(t_interversion)));
  suiteJoueeGlb := suiteJoueePtr(AllocateMemoryPtr(sizeof(t_suiteJouee)));
  meilleureSuiteGlb := meilleureSuitePtr(AllocateMemoryPtr(sizeof(t_meilleureSuite)));
  KillerGlb := KillerPtr(AllocateMemoryPtr(sizeof(t_Killer)));
  nbKillerGlb := nbKillerPtr(AllocateMemoryPtr(sizeof(t_nbKiller)));
  NewParamDiag(ParamDiagCourant);
  NewParamDiag(ParamDiagPositionFFORUM);
  NewParamDiag(ParamDiagPartieFFORUM);
  NewParamDiag(ParamDiagImpr);
  PageImpr.TitreImpression := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  titrePartie := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  partie := partieHdl(AllocateMemoryHdl(sizeof(t_partie)));
  CheminAccesThorDBA := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  CheminAccesThorDBASolitaire := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  CheminAccesSolitaireCassio := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  for j := 1 to NbMaxItemsReouvrirMenu do
    begin
      nomDuFichierAReouvrir[j] := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
      nomLongDuFichierAReouvrir[j] := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
    end;
  ParametresOuvrirThor := tableauString255Hdl(AllocateMemoryHdl(sizeof(tableauString255)));
  CommentaireSolitaire := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  meilleureSuiteStr := String255Hdl(AllocateMemoryHdl(sizeof(String255)));
  TableSolitaire := tableSolitairesHdl(AllocateMemoryHdl(sizeof(tableSolitairesString)));
  TableInfoDejaCalculee := TableInfoDejaCalculeeHdl(AllocateMemoryHdl(sizeof(t_TableInfoDejaCalculee)));
  IndexInfoDejaCalculeesCoupNro := IndexInfoDejaCalculeesCoupNroHdl(AllocateMemoryHdl(sizeof(t_IndexInfoDejaCalculeesCoupNro)));
  derniereChaineComplementation := String255Hdl(AllocateMemoryHdl(sizeof(String255)));





  grow := 0;
  aux := FreeMem;
  if gIsRunningUnderMacOSX
    then nbrePartiesEnMemoire := 10000  {ceci sera rehausse plus tard, apres la lecture des preferences }
    else nbrePartiesEnMemoire := CalculeNbrePartiesOptimum(MaxMem(grow)-GetTailleReserveePourLesSegments);
  erreur := AllocateTousHandlesBase(nbrePartiesEnMemoire);

end;

procedure DisposeGeneral;
var j : SInt16;
    theMenu : MenuRef;
begin
  for j := 0 to nbMaxTablesHashExactes do
    begin
      if CoupsLegauxHash[j] <> NIL then DisposeMemoryPtr(Ptr(CoupsLegauxHash[j]));
      if HashTableExacte[j] <> NIL then DisposeMemoryPtr(Ptr(HashTableExacte[j]));
    end;
  if valeurBord <> NIL then DisposeMemoryPtr(Ptr(valeurBord));
  if valeurBlocsDeCoin <> NIL then DisposeMemoryPtr(Ptr(valeurBlocsDeCoin));
  (*
  if nbOccurencesLigne8 <> NIL then DisposeMemoryPtr(Ptr(nbOccurencesLigne8));
  if nbOccurencesLigne7 <> NIL then DisposeMemoryPtr(Ptr(nbOccurencesLigne7));
  if nbOccurencesLigne6 <> NIL then DisposeMemoryPtr(Ptr(nbOccurencesLigne6));
  if nbOccurencesLigne5 <> NIL then DisposeMemoryPtr(Ptr(nbOccurencesLigne5));
  if nbOccurencesLigne4 <> NIL then DisposeMemoryPtr(Ptr(nbOccurencesLigne4));
  *)
  if table_Turbulence_mono <> NIL then DisposeMemoryPtr(Ptr(table_Turbulence_mono));
  if table_Turbulence_bi <> NIL then DisposeMemoryPtr(Ptr(table_Turbulence_bi));
  if table_Turbulence_alpha_beta_local <> NIL then DisposeMemoryPtr(Ptr(table_Turbulence_alpha_beta_local));
  if ReflexData <> NIL then DisposeMemoryPtr(Ptr(ReflexData));
  if suiteJoueeGlb <> NIL then DisposeMemoryPtr(Ptr(suiteJoueeGlb));
  if meilleureSuiteGlb <> NIL then DisposeMemoryPtr(Ptr(meilleureSuiteGlb));
  if KillerGlb <> NIL then DisposeMemoryPtr(Ptr(KillerGlb));
  if nbKillerGlb <> NIL then DisposeMemoryPtr(Ptr(nbKillerGlb));
  if tableLignes <> NIL then DisposeMemoryPtr(Ptr(tableLignes));
  if IndiceHash <> NIL then DisposeMemoryHdl(Handle(IndiceHash));
  if HashTable <> NIL then DisposeMemoryHdl(Handle(HashTable));
  if Groupes <> NIL then DisposeMemoryHdl(Handle(Groupes));
  if indexCommentaireBibl <> NIL then DisposeMemoryHdl(Handle(indexCommentaireBibl));
  if commentaireBiblEnTas <> NIL then DisposeMemoryHdl(Handle(commentaireBiblEnTas));
  if bibliothequeEnTas <> NIL then DisposeMemoryHdl(Handle(bibliothequeEnTas));
  if bibliothequeIndex <> NIL then DisposeMemoryHdl(Handle(bibliothequeIndex));
  if BibliothequeNbReponse <> NIL then DisposeMemoryHdl(Handle(BibliothequeNbReponse));
  if bibliothequeReponses <> NIL then DisposeMemoryHdl(Handle(bibliothequeReponses));
  if interversionCanonique <> NIL then DisposeMemoryHdl(Handle(interversionCanonique));
  if interversionFautive <> NIL then DisposeMemoryHdl(Handle(interversionFautive));
  DisposeParamDiag(paramDiagPositionFFORUM);
  DisposeParamDiag(paramDiagPartieFFORUM);
  DisposeParamDiag(paramDiagCourant);
  DisposeParamDiag(paramDiagImpr);
  if PageImpr.TitreImpression <> NIL then DisposeMemoryHdl(Handle(PageImpr.TitreImpression));
  if titrePartie <> NIL then DisposeMemoryHdl(Handle(titrePartie));
  if partie <> NIL then DisposeMemoryHdl(Handle(partie));
  if CheminAccesThorDBA <> NIL then DisposeMemoryHdl(Handle(CheminAccesThorDBA));
  if CheminAccesThorDBASolitaire <> NIL then DisposeMemoryHdl(Handle(CheminAccesThorDBASolitaire));
  if CheminAccesSolitaireCassio <> NIL then DisposeMemoryHdl(Handle(CheminAccesSolitaireCassio));
  for j := 1 to NbMaxItemsReouvrirMenu do
    begin
      if nomDuFichierAReouvrir[j] <> NIL then DisposeMemoryHdl(Handle(nomDuFichierAReouvrir[j]));
      if nomLongDuFichierAReouvrir[j] <> NIL then DisposeMemoryHdl(Handle(nomDuFichierAReouvrir[j]));
    end;
  if ParametresOuvrirThor <> NIL then DisposeMemoryHdl(Handle(ParametresOuvrirThor));
  if CommentaireSolitaire <> NIL then DisposeMemoryHdl(Handle(CommentaireSolitaire));
  if meilleureSuiteStr <> NIL then DisposeMemoryHdl(Handle(meilleureSuiteStr));
  if TableSolitaire <> NIL then DisposeMemoryHdl(Handle(TableSolitaire));
  if TableInfoDejaCalculee <> NIL then DisposeMemoryHdl(Handle(TableInfoDejaCalculee));
  if IndexInfoDejaCalculeesCoupNro <> NIL then DisposeMemoryHdl(Handle(IndexInfoDejaCalculeesCoupNro));
  if derniereChaineComplementation <> NIL then DisposeMemoryHdl(Handle(derniereChaineComplementation));

  if not(problemeMemoireBase) then
    DisposeTousHandlesBase;


  theMenu := GetAppleMenu;
  TerminateMenu(theMenu,true);

  theMenu := GetFileMenu;
  TerminateMenu(theMenu,true);

  TerminateMenu(EditionMenu,true);
  TerminateMenu(PartieMenu,true);
  TerminateMenu(ModeMenu,true);
  TerminateMenu(JoueursMenu,true);
  TerminateMenu(AffichageMenu,true);
  TerminateMenu(CouleurMenu,true);
  TerminateMenu(SolitairesMenu,true);
  TerminateMenu(BaseMenu,true);
  TerminateMenu(TriMenu,true);
  TerminateMenu(FormatBaseMenu,true);
  TerminateMenu(Picture2DMenu,true);
  TerminateMenu(Picture3DMenu,true);
  TerminateMenu(CopierSpecialMenu,true);
  TerminateMenu(GestionBaseWThorMenu,true);
  TerminateMenu(NMeilleursCoupsMenu,true);
  TerminateMenu(ReouvrirMenu,true);
  if avecProgrammation then TerminateMenu(ProgrammationMenu,true);
  if OuvertureMenu <> NIL then TerminateMenu(OuvertureMenu,true);


end;

procedure ChangeNbPartiesChargeablesPourBase(nouveauNbPartiesChargeables : SInt32);
var erreur : OSErr;
begin
  if nouveauNbPartiesChargeables < 0
    then nouveauNbPartiesChargeables := 0;
  if nouveauNbPartiesChargeables > nbMaxPartChargeables
    then nouveauNbPartiesChargeables := nbMaxPartChargeables;

  if nouveauNbPartiesChargeables <> nbrePartiesEnMemoire then
    begin

      if not(gIsRunningUnderMacOSX) then TraceLog('ChangeNbPartiesChargeablesPourBase : entree');

      nbrePartiesEnMemoire := 0;
		  nbPartiesChargees := 0;
		  nbPartiesActives := 0;
		  EcritListeParties(false,'ChangeNbPartiesChargeablesPourBase');
		  EcritStatistiques(false);

		  {TraceLog('ChangeNbPartiesChargeablesPourBase : apres EcritListeParties');}

      DisposeListePartiesNouveauFormat;
      DisposeTousHandlesBase;

      if not(gIsRunningUnderMacOSX) then TraceLog('ChangeNbPartiesChargeablesPourBase : avant AllocateMemoireListePartieNouveauFormat');

      nbrePartiesEnMemoire := nouveauNbPartiesChargeables;
      erreur := AllocateMemoireListePartieNouveauFormat(nbrePartiesEnMemoire);
      if erreur <> 0 then
        begin
          SysBeep(0);
          TraceLog('ChangeNbPartiesChargeablesPourBase : Erreur 1');
          nbrePartiesEnMemoire := 0;
        end;

      erreur := AllocateTousHandlesBase(nbrePartiesEnMemoire);
      if erreur <> 0 then
        begin
          SysBeep(0);
          TraceLog('ChangeNbPartiesChargeablesPourBase : Erreur 2');
          nbrePartiesEnMemoire := 0;
        end;

      if not(gIsRunningUnderMacOSX) then TraceLog('ChangeNbPartiesChargeablesPourBase : avant VerificationAllocationMemoireBase');

      VerificationAllocationMemoireBase;

      if not(gIsRunningUnderMacOSX) then TraceLog('ChangeNbPartiesChargeablesPourBase : sortie');

    end;

  {if not(gIsRunningUnderMacOSX) then EcritEtatMemoire;}
end;


end.
