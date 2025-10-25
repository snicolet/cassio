UNIT UnitMoveRecords;



INTERFACE







 USES UnitDefCassio;



procedure InitUnitMoveRecords;
procedure LibereMemoireUnitMoveRecords;


{procedures de manipulation de MoveRecord}
procedure ViderMoveRecord(var whichMoveRecord : MoveRecord);


{procedures de creation et de copies de ListOfMoveRecords}
function AllocateListOfMoveRecordsHandle(var liste : ListOfMoveRecordsHdl) : boolean;
procedure CopyListOMoveRecords(var source,dest : ListOfMoveRecords);
procedure DisposeListOfMoveRecordsHandle(var liste : ListOfMoveRecordsHdl);
procedure ViderListOfMoveRecords(var liste : ListOfMoveRecords);
procedure MetLesCoupsDansLeMemeOrdre(maitres : ListOfMoveRecords; var esclaves : ListOfMoveRecords; longueurClassement : SInt32);
function LesCoupsSontDansLeMemeOrdre(var liste1,liste2 : ListOfMoveRecords; longueurClassement : SInt32) : boolean;


{procedure d'acces ˆ la liste des coups de la fenetre "Reflexion"}
procedure SetValReflex(var classAux : ListOfMoveRecords; profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
procedure SetValReflexFinale(var classAux : ListOfMoveRecords; profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
procedure SetNroLigneEnCoursDAnalyseDansReflex(nroLigne : SInt32);
procedure SetCoupEtScoreAnalyseRetrogradeDansReflex(coup,score : SInt32);
function EstLaListeDesCoupsDeFenetreReflexion(var whichList : ListOfMoveRecords) : boolean;


{procedure d'acces et d'ecriture dans la tableOfMoveRecordsLists}
procedure CopyClassementDansTableOfMoveRecordsLists(var classement : ListOfMoveRecords; quelleProf,longClass : SInt16);
procedure EcritClassementDansRapport(whichClassement : ListOfMoveRecords; prompt : String255; longueurClassement : SInt32);
procedure InvalidateCetteProfDansTableOfMoveRecordsLists(quelleProf : SInt16);
procedure InvalidateAllProfsDansDansTableOfMoveRecordsLists;
procedure HLockAllProfsDansDansTableOfMoveRecordsLists;
procedure HUnlockAllProfsDansDansTableOfMoveRecordsLists;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitServicesMemoire, UnitServicesDialogs ;
{$ELSEC}
    ;
    {$I prelink/MoveRecords.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure InitUnitMoveRecords;
var i : SInt16;
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    begin
      tableOfMoveRecordsLists[i].list := NIL;
      tableOfMoveRecordsLists[i].cardinal := 0;
      tableOfMoveRecordsLists[i].utilisee := false;
    end;
end;

procedure LibereMemoireUnitMoveRecords;
var i : SInt16;
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    begin
      DisposeListOfMoveRecordsHandle(tableOfMoveRecordsLists[i].list);
      tableOfMoveRecordsLists[i].cardinal := 0;
      tableOfMoveRecordsLists[i].utilisee := false;
    end;
end;

procedure ViderMoveRecord(var whichMoveRecord : MoveRecord);
begin
  with whichMoveRecord do
    begin
      x := 0;
      theDefense := 0;
      note := 0;
      pourcentageCertitude := 0;
      temps := 0;
      nbfeuilles := 0;
      notePourLeTri := 0;
      noteMilieuDePartie := 0;
      delta := 0;
    end;
end;

function AllocateListOfMoveRecordsHandle(var liste : ListOfMoveRecordsHdl) : boolean;
begin
  liste := NIL;
  liste := ListOfMoveRecordsHdl(AllocateMemoryHdl(20+Sizeof(ListOfMoveRecords)));
  AllocateListOfMoveRecordsHandle := (liste <> NIL);
end;

procedure CopyListOMoveRecords(var source,dest : ListOfMoveRecords);
var i : SInt16;
begin
  for i := 1 to 64 do
    dest[i] := source[i];
end;


procedure DisposeListOfMoveRecordsHandle(var liste : ListOfMoveRecordsHdl);
begin
  if liste <> NIL then
    begin
      DisposeMemoryHdl(Handle(liste));
      liste := NIL;
    end;
end;

procedure ViderListOfMoveRecords(var liste : ListOfMoveRecords);
var i : SInt16;
begin
  for i := 1 to 64 do
    ViderMoveRecord(liste[i]);
end;

procedure SetCoupEtScoreAnalyseRetrogradeDansReflex(coup,score : SInt32);
begin
  ReflexData^.coupAnalyseRetrograde := coup;
  ReflexData^.scoreAnalyseRetrograde := score;
end;

procedure SetValReflex(var classAux : ListOfMoveRecords; profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
var i,penaliteAjoutee : SInt16;
begin
  if odd(profondeur+1)
    then penaliteAjoutee := penalitePourTraitAff
    else penaliteAjoutee := -penalitePourTraitAff;
  for i := 1 to compt do ReflexData^.class[i] := classAux[i];
  for i := 1 to compt do
    begin
      ReflexData^.class[i].note := ReflexData^.class[i].note+penaliteAjoutee;
      if ReflexData^.class[i].note = -1
        then ReflexData^.class[i].note := -2;
      ReflexData^.class[i].pourcentageCertitude := 100;
      ReflexData^.class[i].delta := kTypeMilieuDePartie;
    end;
  ReflexData^.prof := profondeur;
  ReflexData^.compteur := compt;
  ReflexData^.longClass := longueurclass;
  ReflexData^.typeDonnees := genre;
  ReflexData^.numeroDuCoup := numero;
  ReflexData^.couleur := couleur;
  ReflexData^.IndexCoupEnCours := IndexEnCours;
  if (IndexEnCours >= 1) and (IndexEnCours <= longueurclass) then
    begin
      ReflexData^.class[IndexEnCours] := classAux[IndexEnCours];
      ReflexData^.class[IndexEnCours].note := ReflexData^.class[IndexEnCours].note+penaliteAjoutee;
      if ReflexData^.class[IndexEnCours].note = -1
        then ReflexData^.class[IndexEnCours].note := -2;
    end;
  SetCoupEtScoreAnalyseRetrogradeDansReflex(0,0);
end;

procedure SetValReflexFinale(var classAux : ListOfMoveRecords; profondeur,compt,longueurclass,genre,numero,IndexEnCours,couleur : SInt16);
var i : SInt16;
begin
  for i := 1 to compt do ReflexData^.class[i] := classAux[i];
  ReflexData^.prof := profondeur;
  ReflexData^.compteur := compt;
  ReflexData^.longClass := longueurclass;
  ReflexData^.typeDonnees := genre;
  ReflexData^.numeroDuCoup := numero;
  ReflexData^.couleur := couleur;
  ReflexData^.IndexCoupEnCours := IndexEnCours;
  if (IndexEnCours >= 1) and (IndexEnCours <= longueurclass) then
    ReflexData^.class[IndexEnCours] := classAux[IndexEnCours];
end;


procedure EcritClassementDansRapport(whichClassement : ListOfMoveRecords; prompt : String255; longueurClassement : SInt32);
var i : SInt32;
begin
  WritelnDansRapport('');
  if prompt <> '' then WritelnDansRapport(prompt);
  for i := 1 to longueurClassement do
    begin
      WriteNumDansRapport('i = ',i);
      WriteStringAndCoupDansRapport('  coup = ',whichClassement[i].x);
      WriteStringAndCoupDansRapport('  def = ', whichClassement[i].theDefense);
      WriteNumDansRapport('  score = ',whichClassement[i].note);
      WriteNumDansRapport('  delta = ',whichClassement[i].delta);
      WriteNumDansRapport('  temps = ',whichClassement[i].temps);
      WriteNumDansRapport('  notePourLeTri = ',whichClassement[i].notePourLeTri);
      WritelnDansRapport('');
    end;
  WritelnDansRapport('');
end;


procedure SetNroLigneEnCoursDAnalyseDansReflex(nroLigne : SInt32);
begin
  if (nroLigne >= 1) and (nroLigne <= ReflexData^.longClass) then
    ReflexData^.IndexCoupEnCours := nroLigne;
end;

function EstLaListeDesCoupsDeFenetreReflexion(var whichList : ListOfMoveRecords) : boolean;
begin
  EstLaListeDesCoupsDeFenetreReflexion := (@whichList = @ReflexData^.class);
end;


procedure CopyClassementDansTableOfMoveRecordsLists(var classement : ListOfMoveRecords; quelleProf,longClass : SInt16);
begin

  {
  WritelnNumDansRapport('dans CopyClassementDansTableOfMoveRecordsLists : quelleProf = ',quelleProf);
  WritelnNumDansRapport('dans CopyClassementDansTableOfMoveRecordsLists : longClass = ',longClass);
  }

  if (quelleProf >= 0) and (quelleProf <= ProfMaxDansTableOfMoveRecordsLists) then
    begin
      if tableOfMoveRecordsLists[quelleProf].list = NIL then
        begin
          if AllocateListOfMoveRecordsHandle(tableOfMoveRecordsLists[quelleProf].list) and
             (tableOfMoveRecordsLists[quelleProf].list <> NIL) then
            begin
              HLock(Handle(tableOfMoveRecordsLists[quelleProf].list));
              ViderListOfMoveRecords(tableOfMoveRecordsLists[quelleProf].list^^);
              HUnlock(Handle(tableOfMoveRecordsLists[quelleProf].list));
            end;
        end;

      if (tableOfMoveRecordsLists[quelleProf].list <> NIL) and (longClass > 0)
        then
	      begin
	        HLock(Handle(tableOfMoveRecordsLists[quelleProf].list));
	        CopyListOMoveRecords(classement,tableOfMoveRecordsLists[quelleProf].list^^);


	        tableOfMoveRecordsLists[quelleProf].utilisee := true;
	        tableOfMoveRecordsLists[quelleProf].cardinal := longClass;

		    {
            WritelnNumDansRapport('tableOfMoveRecordsLists pour la prof : ',quelleProf);
            WritelnNumDansRapport('cardinal =  ',longClass);
            for i := 1 to longClass do
              with tableOfMoveRecordsLists[quelleProf].list^^[i] do
                begin
                  WritelnNumDansRapport(CoupEnStringEnMajuscules(x)+'==>',note);
                end;
            WritelnDansRapport('');
            }

	        HUnlock(Handle(tableOfMoveRecordsLists[quelleProf].list));
	      end
	    else
	      begin
	        tableOfMoveRecordsLists[quelleProf].utilisee := false;
	        tableOfMoveRecordsLists[quelleProf].cardinal := 0;
	      end;
    end;
end;


procedure InvalidateCetteProfDansTableOfMoveRecordsLists(quelleProf : SInt16);
begin
  if (quelleProf >= 0) and (quelleProf <= ProfMaxDansTableOfMoveRecordsLists) then
    begin
      tableOfMoveRecordsLists[quelleProf].utilisee := false;
	  tableOfMoveRecordsLists[quelleProf].cardinal := 0;
    end;
end;

procedure InvalidateAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16;
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    InvalidateCetteProfDansTableOfMoveRecordsLists(i);
end;

procedure HLockAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16;
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    if tableOfMoveRecordsLists[i].list <> NIL then
      HLock(Handle(tableOfMoveRecordsLists[i].list));
end;


procedure HUnlockAllProfsDansDansTableOfMoveRecordsLists;
var i : SInt16;
begin
  for i := 0 to ProfMaxDansTableOfMoveRecordsLists do
    if tableOfMoveRecordsLists[i].list <> NIL then
      HUnlock(Handle(tableOfMoveRecordsLists[i].list));
end;


{Met les coups de esclaves dans le meme ordre que maitres}
procedure MetLesCoupsDansLeMemeOrdre(maitres : ListOfMoveRecords; var esclaves : ListOfMoveRecords; longueurClassement : SInt32);
var k,t,coup,indexDuCoupsChezLesEsclaves : SInt32;
    tempElement : MoveRecord;
begin
  if not(LesCoupsSontDansLeMemeOrdre(maitres,esclaves,longueurClassement)) then
    for k := 1 to longueurClassement do
      begin
        coup := maitres[k].x;
        indexDuCoupsChezLesEsclaves := -1;
        for t := k to longueurClassement do
          if esclaves[t].x = coup then
            indexDuCoupsChezLesEsclaves := t;
        if indexDuCoupsChezLesEsclaves = -1
          then
            begin
              AlerteSimple('ERREUR dans MetLesCoupsDansLeMemeOrdre (indexDuCoupsChezLesEsclaves = -1) !!');
            end
          else
  		      if indexDuCoupsChezLesEsclaves <> k then
  		        begin
  		          tempElement := esclaves[k];
  		          esclaves[k] := esclaves[indexDuCoupsChezLesEsclaves];
  		          esclaves[indexDuCoupsChezLesEsclaves] := tempElement;
  		        end;
      end;
end;


function LesCoupsSontDansLeMemeOrdre(var liste1,liste2 : ListOfMoveRecords; longueurClassement : SInt32) : boolean;
var i : SInt32;
begin

  for i := 1 to longueurClassement do
    if liste1[i].x <> liste2[i].x then
      begin
        LesCoupsSontDansLeMemeOrdre := false;
        exit(LesCoupsSontDansLeMemeOrdre);
      end;

  LesCoupsSontDansLeMemeOrdre := true;
end;


END.
