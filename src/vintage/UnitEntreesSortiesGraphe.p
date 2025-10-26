UNIT UnitEntreesSortiesGraphe;


INTERFACE







 USES UnitDefCassio;


{Creation de cellules}
procedure CreeCelluleRacine(var fichier : Graphe);
procedure LitEnsembleDesFils(var fichier : Graphe; numCellule : SInt32; var LesFils : ListeDeCellules);
procedure LitEnsembleDesPeres(var fichier : Graphe; numCellule : SInt32; var Peres : ListeDeCellules);
procedure LitEnsembleDesFreres(var fichier : Graphe; numCellule : SInt32; var Freres : ListeDeCellules);
procedure LitOrbite(var fichier : Graphe; numCellule : SInt32; var orbite : ListeDeCellules);
procedure CreeLiaisonPeresVersFils(var fichier : Graphe; numPere,numFils : SInt32);
procedure CreeLiaisonFreresVersPere(var fichier : Graphe; numCell,numPere : SInt32);
procedure CreePartieDansGrapheApprentissage(var fichier : Graphe; partie60 : PackedThorGame; var suiteDesCellules : ListeDeCellules);
procedure AjoutePartieDansGrapheApprentissage(var fichier : Graphe; partieStr : String255);

{Verifications et statistiques diverses}

function RepareListeDesFreres(var fichier : Graphe; numCellule : SInt32; var listeDesFreresReparee : ListeDeCellules; const fonctionAppelante : String255) : OSErr;
function RepareOrbite(var fichier : Graphe; numCellule : SInt32; var orbiteReparee : ListeDeCellules; const fonctionAppelante : String255) : OSErr;
procedure VerifieIntegriteCellule(var fichier : Graphe; var cell : CelluleRec; numeroCellule : SInt32; const fonctionAppelante : String255);
procedure VerifieIntegriteGraphe(var fichier : Graphe);
procedure CompterLesPartiesDansGrapheApprentissage(AQuelCoup : SInt16; var nbrePartiesDansGrapheApprentissage : SInt32);
procedure NettoyerGrapheApprentissage(nomDuGraphe : String255);


{Acces depuis l'exterieur, pour jouer}
function PositionEstDansLeGraphe(var fichier : Graphe; chemin60 : PackedThorGame; var suiteDesCellules : ListeDeCellules) : boolean;
function PeutChoisirDansGrapheApprentissage(var coup,defense : SInt32) : boolean;
function PositionCouranteEstDansGrapheApprentissage : boolean;
function TrouveCoupDansGrapheApprentissage(const partieStr : String255; var coup : SInt16) : boolean;
procedure GetFilsDeLaPositionCouranteDansLeGraphe(typesVoulus : EnsembleDeTypes; tries : boolean; var FilsSelectionnes:listeDeCellulesEtDeCoups);
procedure CheminDepuisRacineGrapheEnThor(var fichier : Graphe; numCellule : SInt32; var partie60 : PackedThorGame);
function CheminDepuisRacineGrapheEnAlphanumerique(var fichier : Graphe; numCellule : SInt32) : String255;


{Visualisation du graphe}
procedure ListerToutesLesCellulesDansRapport;
procedure VoirLesInfosDApprentissageDansRapport;
procedure EcritLesInfosDApprentissage;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitEvenement, UnitCalculsApprentissage, UnitOth2, UnitScannerUtils, UnitRapport, UnitJeu
    , UnitAffichagePlateau, MyStrings, MyMathUtils, UnitFenetres, UnitNormalisation, SNEvents, UnitScannerOthellistique, UnitPackedThorGame
    , UnitGestionDuTemps, UnitPositionEtTrait, UnitAccesGraphe, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/EntreesSortiesGraphe.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure CreeCelluleRacine(var fichier : Graphe);
var racine : CelluleRec;
begin
  if NbrePositionsDansGrapheApprentissage(fichier) < 1 then
    begin
      InitialiseCellule(racine,1);
      with racine do
        begin
          SetCouleur(Noir,racine); {le premier coup est un coup de Noir}
          SetCoup(56,racine);      {F5}
          SetTrait(Blanc,racine);  {apres le premier coup, c'est a Blanc de jouer}
          numeroDuCoup := 1;
        end;
      EcritCellule(fichier,1,racine);
    end;
end;


procedure LitEnsembleDesFils(var fichier : Graphe; numCellule : SInt32; var LesFils : ListeDeCellules);
var premierFils,aux : SInt32;
    cellule : CelluleRec;
    erreur : OSErr;
begin
  LesFils.cardinal := 0;
  LitCellule(fichier,numCellule,cellule);
  if HasFils(cellule) then
    begin
      premierFils := GetFils(cellule);
      aux := premierFils;
      repeat
        LitCellule(fichier,aux,cellule);
        LesFils.cardinal := LesFils.cardinal+1;
        LesFils.liste[LesFils.cardinal].numeroCellule := aux;
        aux := GetFrere(cellule);

        if LesFils.cardinal >= kLongueurListeInfinie then
          begin
            {SysBeep(0);}
            WritelnDansRapport('## ERROR : boucle infinie dans LitEnsembleDesFils');
            erreur := RepareListeDesFreres(fichier,premierFils,LesFils,'LitEnsembleDesFils');
            {WritelnDansRapport('Sortie de LitEnsembleDesFils');
            AttendFrappeClavier;}
            exit(LitEnsembleDesFils);
          end;
      until (aux = premierFils);
    end;
end;


procedure LitEnsembleDesPeres(var fichier : Graphe; numCellule : SInt32; var peres : ListeDeCellules);
var premierPere,aux : SInt32;
    cellule : CelluleRec;
    erreur : OSErr;
begin
  peres.cardinal := 0;
  LitCellule(fichier,numCellule,cellule);
  if HasPere(cellule) then
    begin
      premierPere := GetPere(cellule);
      aux := premierPere;
      repeat
        LitCellule(fichier,aux,cellule);
        peres.cardinal := peres.cardinal+1;
        peres.liste[Peres.cardinal].numeroCellule := aux;
        aux := GetMemePosition(cellule);

        if (Peres.cardinal >= kLongueurListeInfinie) then
          begin
            {SysBeep(0);}
            WritelnDansRapport('## ERROR : boucle infinie dans LitEnsembleDesPeres');
            erreur := RepareOrbite(fichier,premierPere,peres,' LitEnsembleDesPeres:');
            exit(LitEnsembleDesPeres);
          end;
      until (aux = premierPere);
    end;
end;

procedure LitEnsembleDesFreres(var fichier : Graphe; numCellule : SInt32; var freres : ListeDeCellules);
var premierFrere,aux : SInt32;
    cellule : CelluleRec;
    erreur : OSErr;
begin
  freres.cardinal := 0;
  LitCellule(fichier,numCellule,cellule);
  if HasFrere(cellule) then
    begin
      premierFrere := numCellule;
      aux := premierFrere;
      repeat
        LitCellule(fichier,aux,cellule);
        freres.cardinal := freres.cardinal+1;
        freres.liste[Freres.cardinal].numeroCellule := aux;
        aux := GetFrere(cellule);

        if freres.cardinal >= kLongueurListeInfinie then
          begin
            {SysBeep(0);}
            WritelnDansRapport('## ERROR : boucle infinie dans LitEnsembleDesFreres');
            erreur := RepareListeDesFreres(fichier,premierFrere,freres,'LitEnsembleDesFreres:');
            exit(LitEnsembleDesFreres);
          end;
      until (aux = premierFrere);
    end;
end;


procedure LitOrbite(var fichier : Graphe; numCellule : SInt32; var orbite : ListeDeCellules);
var positionDebut,aux : SInt32;
    cellule : CelluleRec;
    erreur : OSErr;
begin
  orbite.cardinal := 0;
  positionDebut := numCellule;
  aux := positionDebut;
  repeat
    LitCellule(fichier,aux,cellule);
    orbite.cardinal := orbite.cardinal+1;
    orbite.liste[orbite.cardinal].numeroCellule := aux;
    aux := GetMemePosition(cellule);

    if (orbite.cardinal >= kLongueurListeInfinie) then
      begin
        WritelnDansRapport('## ERROR : boucle infinie dans LitOrbite');
        erreur := RepareOrbite(fichier,numCellule,orbite,' LitOrbite:');
        exit(LitOrbite);
      end;
  until (aux = positionDebut);
end;

function RepareOrbite(var fichier : Graphe; numCellule : SInt32; var orbiteReparee : ListeDeCellules; const fonctionAppelante : String255) : OSErr;
var positionDebut,aux,i,j,k : SInt32;
    filsTraite,numeroCoupTraite : SInt32;
    cellule : CelluleRec;
    orbite : record
             cardinal : SInt32;
             liste : array[0..TaileMaxListeDeCoups] of
               record
                 numeroCellule : SInt32;
                 fils : SInt32;
                 numeroCoup : SInt16;
               end;
           end;
    bonneOrbite : ListeDeCellules;
    dejaDansBonneOrbite : boolean;
begin
  SetEcritToutDansRapportLog(true);
  WritelnDansRapport('');
  WritelnDansRapport(Concat('Entrée dans RepareOrbite, fonctionAppelante = ',fonctionAppelante));
  {SysBeep(0);}
  {AttendFrappeClavier;}

  RepareOrbite := -1;

  {init}
  orbite.cardinal := 0;
  for i := 0 to TaileMaxListeDeCoups do
    begin
      orbite.liste[i].numeroCellule := 0;
		  orbite.liste[i].fils          := 0;
		  orbite.liste[i].numeroCoup    := 0;
    end;


  LitCellule(fichier,numCellule,cellule);
  if GetMemePosition(cellule) <> numCellule then
    begin
      positionDebut := numCellule;
      aux := positionDebut;
		  repeat
		    LitCellule(fichier,aux,cellule);
		    orbite.cardinal := orbite.cardinal+1;
		    orbite.liste[orbite.cardinal].numeroCellule := aux;
		    orbite.liste[orbite.cardinal].fils := GetFils(cellule);
		    orbite.liste[orbite.cardinal].numeroCoup := GetNumeroCoup(cellule);
		    aux := GetMemePosition(cellule);
		  until (aux = positionDebut) or (orbite.cardinal >= kLongueurListeInfinie);

		  if (orbite.cardinal >= kLongueurListeInfinie) then
		    begin

		      WritelnDansRapport(Concat('liste infinie dans RepareOrbite, fonctionAppelante = ',fonctionAppelante));
		      WriteDansRapport('orbite['+NumEnString(numCellule)+'] = ');
		      for i := 1 to Min(kLongueurListeInfinie,20) do
		        begin
		          WriteNumDansRapport('->',orbite.liste[i].numeroCellule);
		          if (i mod 10) = 0 then WritelnDansRapport('');
		        end;

		      WriteDansRapport('(numCoup,fils)['+NumEnString(numCellule)+'] = ');
		      for i := 1 to Min(kLongueurListeInfinie,20) do
		        begin
		          WriteNumDansRapport('->(',orbite.liste[i].numeroCoup);
		          WriteNumDansRapport(',',orbite.liste[i].fils);
		          WriteStringDansRapport(')');
		          if (i mod 10) = 0 then WritelnDansRapport('');
		        end;

		      for i := 1 to orbite.cardinal do
		        if (orbite.liste[i].numeroCellule <> 0) then
		          begin
		            filsTraite := orbite.liste[i].fils;
		            numeroCoupTraite := orbite.liste[i].numeroCoup;

		            {on recherche toutes les memes partageant ce fils et ce numero de coup}
		            bonneOrbite.cardinal := 0;
		            for j := 1 to orbite.cardinal do
		              if (orbite.liste[j].numeroCellule <> 0) and
		                 (orbite.liste[j].fils = filsTraite) and
		                 (orbite.liste[j].numeroCoup = numeroCoupTraite) then
		              begin
		                {A priori orbite.liste[j].numeroCellule est a ajouter
		                 dans la bonne orbite. L'a-t-on deja ? }
		                dejaDansBonneOrbite := false;
		                for k := 1 to bonneOrbite.cardinal do
		                  if bonneOrbite.liste[k].numeroCellule = orbite.liste[j].numeroCellule
		                    then dejaDansBonneOrbite := true;

		                if not(dejaDansBonneOrbite) then
		                  begin
		                    bonneOrbite.cardinal := bonneOrbite.cardinal + 1;
		                    bonneOrbite.liste[bonneOrbite.cardinal].numeroCellule := orbite.liste[j].numeroCellule;
		                  end;


		                orbite.liste[j].numeroCellule := 0;
		                orbite.liste[j].fils          := 0;
		                orbite.liste[j].numeroCoup    := 0;
		              end;

		            {on reecrit la bonne orbite dans le fichier}
		            if (bonneOrbite.cardinal > 0) then
		              begin
				            WritelnDansRapport('orbite des memes positions ayant (numCoup,fils) = ('+
				                                NumEnString(numeroCoupTraite)+','+NumEnString(filsTraite)+') : ');
				            for k := 1 to bonneOrbite.cardinal do
				              begin
				                WriteNumDansRapport('cell #',bonneOrbite.liste[k].numeroCellule);
				                WritelnNumDansRapport(' -> memePosition = ',bonneOrbite.liste[1 + (k mod bonneOrbite.cardinal)].numeroCellule);


				                LitCellule(fichier,bonneOrbite.liste[k].numeroCellule,cellule);
				                SetMemePosition(bonneOrbite.liste[1 + (k mod bonneOrbite.cardinal)].numeroCellule,cellule);
				                EcritCellule(fichier,bonneOrbite.liste[k].numeroCellule,cellule);

							        end;
							    end;
		          end;

		      {un petit appel a VerifieIntegriteCellule pour verifier que tout va bien}
		      LitCellule(fichier,numCellule,cellule);
		      SetEcritToutDansRapportLog(true);
		      if Pos('VerifieIntegriteCellule',fonctionAppelante) <= 0
		        then VerifieIntegriteCellule(fichier,cellule,numCellule,Concat(fonctionAppelante , 'RepareOrbite : '));
		    end;
		end;

  {on essaie de renvoyer l'orbite reparee}
	orbiteReparee.cardinal := 0;
	LitCellule(fichier,numCellule,cellule);
	if GetMemePosition(cellule) <> 0 then
	  begin
		  positionDebut := numCellule;
		  aux := positionDebut;
		  repeat
		    LitCellule(fichier,aux,cellule);
		    orbiteReparee.cardinal := orbiteReparee.cardinal+1;
		    orbiteReparee.liste[orbiteReparee.cardinal].numeroCellule := aux;
		    aux := GetMemePosition(cellule);
		  until (aux = positionDebut) or (aux = 0) or
		        (orbiteReparee.cardinal >= kLongueurListeInfinie);
		end;

  if (orbiteReparee.cardinal >= kLongueurListeInfinie) or (orbiteReparee.cardinal <= 0)
    then RepareOrbite := -1
    else RepareOrbite := NoErr;

  WritelnNumDansRapport('Sortie de RepareOrbite, fonctionAppelante = '+fonctionAppelante+'  ==> orbiteReparee.cardinal = ',orbiteReparee.cardinal);

	{AttendFrappeClavier;}
end;



function RepareListeDesFreres(var fichier : Graphe; numCellule : SInt32; var listeDesFreresReparee : ListeDeCellules; const fonctionAppelante : String255) : OSErr;
var premierFrere,aux,i,j,k : SInt32;
    pereTraite,numeroCoupTraite : SInt32;
    cellule : CelluleRec;
    freres : record
               cardinal : SInt32;
               liste : array[0..TaileMaxListeDeCoups] of
                         record
                           numeroCellule : SInt32;
                           pere : SInt32;
                           numeroCoup : SInt16;
                         end;
             end;
    bonFreres : ListeDeCellules;
    dejaDansBonsFreres : boolean;
begin
  SetEcritToutDansRapportLog(true);
  WritelnDansRapport('');
  WritelnDansRapport(Concat('Entrée dans RepareListeDesFreres, fonctionAppelante = ',fonctionAppelante));
  {SysBeep(0);}
  {AttendFrappeClavier;}

  RepareListeDesFreres := -1;

  {init}
  freres.cardinal := 0;
  for i := 0 to TaileMaxListeDeCoups do
    begin
      freres.liste[i].numeroCellule := 0;
		  freres.liste[i].pere          := 0;
		  freres.liste[i].numeroCoup    := 0;
    end;


  LitCellule(fichier,numCellule,cellule);
  if HasFrere(cellule) then
    begin
      premierFrere := numCellule;
      aux := premierFrere;
		  repeat
		    LitCellule(fichier,aux,cellule);
		    freres.cardinal := freres.cardinal+1;
		    freres.liste[freres.cardinal].numeroCellule := aux;
		    freres.liste[freres.cardinal].pere := GetPere(cellule);
		    freres.liste[freres.cardinal].numeroCoup := GetNumeroCoup(cellule);
		    aux := GetFrere(cellule);
		  until (aux = premierFrere) or (freres.cardinal >= kLongueurListeInfinie);

		  if (freres.cardinal >= kLongueurListeInfinie) then
		    begin

		      WritelnDansRapport(Concat('liste infinie dans RepareListeDesFreres, fonctionAppelante = ',fonctionAppelante));
		      WriteDansRapport('freres['+NumEnString(numCellule)+'] = ');
		      for i := 1 to Min(kLongueurListeInfinie,20) do
		        begin
		          WriteNumDansRapport('->',freres.liste[i].numeroCellule);
		          if (i mod 10) = 0 then WritelnDansRapport('');
		        end;

		      WriteDansRapport('(numCoup,pere)['+NumEnString(numCellule)+'] = ');
		      for i := 1 to Min(kLongueurListeInfinie,20) do
		        begin
		          WriteNumDansRapport('->(',freres.liste[i].numeroCoup);
		          WriteNumDansRapport(',',freres.liste[i].pere);
		          WriteStringDansRapport(')');
		          if (i mod 10) = 0 then WritelnDansRapport('');
		        end;

		      for i := 1 to freres.cardinal do
		        if (freres.liste[i].numeroCellule <> 0) then
		          begin
		            pereTraite := freres.liste[i].pere;
		            numeroCoupTraite := freres.liste[i].numeroCoup;

		            {on recherche tous les freres partageant ce pere et ce numero de coup}
		            bonFreres.cardinal := 0;
		            for j := 1 to freres.cardinal do
		              if (freres.liste[j].numeroCellule <> 0) and
		                 (freres.liste[j].pere = pereTraite) and
		                 (freres.liste[j].numeroCoup = numeroCoupTraite) then
		              begin
		                {A priori freres.liste[j].numeroCellule est a ajouter
		                 dans la bonne orbite. L'a-t-on deja ? }
		                dejaDansBonsFreres := false;
		                for k := 1 to bonFreres.cardinal do
		                  if bonFreres.liste[k].numeroCellule = freres.liste[j].numeroCellule
		                    then dejaDansBonsFreres := true;

		                if not(dejaDansBonsFreres) then
		                  begin
		                    bonFreres.cardinal := bonFreres.cardinal + 1;
		                    bonFreres.liste[bonFreres.cardinal].numeroCellule := freres.liste[j].numeroCellule;
		                  end;


		                freres.liste[j].numeroCellule := 0;
		                freres.liste[j].pere          := 0;
		                freres.liste[j].numeroCoup    := 0;
		              end;

		            {on reecrit la bonne orbite des freres dans le fichier}
		            if (bonFreres.cardinal > 0) then
		              begin
				            WritelnDansRapport('orbite des freres ayant (numCoup,pere) = ('+
				                                NumEnString(numeroCoupTraite)+','+NumEnString(pereTraite)+') : ');
				            for k := 1 to bonFreres.cardinal do
				              begin
				                WriteNumDansRapport('cell #',bonFreres.liste[k].numeroCellule);
				                WritelnNumDansRapport(' -> frere = ',bonFreres.liste[1 + (k mod bonFreres.cardinal)].numeroCellule);

				                LitCellule(fichier,bonFreres.liste[k].numeroCellule,cellule);
				                SetFrere(bonFreres.liste[1 + (k mod bonFreres.cardinal)].numeroCellule,cellule);
				                EcritCellule(fichier,bonFreres.liste[k].numeroCellule,cellule);

							        end;
							    end;
		          end;

		      {un petit appel a VerifieIntegriteCellule pour verifier que tout va bien}
		      LitCellule(fichier,numCellule,cellule);
		      SetEcritToutDansRapportLog(true);
		      if Pos('VerifieIntegriteCellule',fonctionAppelante) <= 0
		        then VerifieIntegriteCellule(fichier,cellule,numCellule,Concat(fonctionAppelante , 'RepareListeDesFreres : '));
		    end;
		end;

	{on essaie de renvoyer la liste des freres reparee}
	listeDesFreresReparee.cardinal := 0;
  LitCellule(fichier,numCellule,cellule);
  if HasFrere(cellule) then
    begin
      premierFrere := numCellule;
      aux := premierFrere;
      repeat
        LitCellule(fichier,aux,cellule);
        listeDesFreresReparee.cardinal := listeDesFreresReparee.cardinal+1;
        listeDesFreresReparee.liste[listeDesFreresReparee.cardinal].numeroCellule := aux;
        aux := GetFrere(cellule);
      until (aux = premierFrere) or (aux = 0) or
            (listeDesFreresReparee.cardinal >= kLongueurListeInfinie);
    end;

  if (listeDesFreresReparee.cardinal >= kLongueurListeInfinie) or (listeDesFreresReparee.cardinal <= 0)
    then RepareListeDesFreres := -1
    else RepareListeDesFreres := NoErr;

  WritelnNumDansRapport('Sortie de RepareListeDesFreres, fonctionAppelante = '+fonctionAppelante+'  ==> listeDesFreresReparee.cardinal = ',listeDesFreresReparee.cardinal);

	{AttendFrappeClavier;}
end;




procedure CreeLiaisonPeresVersFils(var fichier : Graphe; numPere,numFils : SInt32);
var cellAux : CelluleRec;
    k : SInt16;
    orbiteDuPere : ListeDeCellules;
begin
  LitOrbite(fichier,numPere,orbiteDuPere);
  for k := 1 to orbiteDuPere.cardinal do
    begin
      LitCellule(fichier,orbiteDuPere.liste[k].numeroCellule,cellAux);
      SetFils(numFils,cellAux);
      EcritCellule(fichier,orbiteDuPere.liste[k].numeroCellule,cellAux);
    end;
end;

procedure CreeLiaisonFreresVersPere(var fichier : Graphe; numCell,numPere : SInt32);
var cellAux : CelluleRec;
    k : SInt16;
    Freres : ListeDeCellules;
begin
  LitEnsembleDesFreres(fichier,numCell,Freres);
  for k := 1 to Freres.cardinal do
    begin
      LitCellule(fichier,Freres.liste[k].numeroCellule,cellAux);
      SetPere(numPere,cellAux);
      EcritCellule(fichier,Freres.liste[k].numeroCellule,cellAux);
    end;
end;

procedure CreePartieDansGrapheApprentissage(var fichier : Graphe; partie60 : PackedThorGame; var suiteDesCellules : ListeDeCellules);
var NumCelluleCree,numCelluleCourante : SInt32;
    celluleCree,celluleCourante,cellAux : CelluleRec;
    i : SInt16;
    ListeDesFils : ListeDeCellules;
    numCelluleCoupSuivant : SInt32;
    coupCourant : SInt8;
    position : PositionEtTraitRec;
    legal : boolean;
    whichGame : typePartiePourGraphe;
begin


  COPY_PACKED_GAME_TO_STR255(partie60, whichGame);

  position := PositionEtTraitInitiauxStandard;
  if LongueurPartieDuGraphe(whichGame) > 1 then
    begin
      legal := UpdatePositionEtTrait(position,56);  (* F5 *)
      numCelluleCourante := 1;
      suiteDesCellules.cardinal := 1;
      suiteDesCellules.liste[1].numeroCellule := 1;
      for i := 2 to LongueurPartieDuGraphe(whichGame) do
        begin
          coupCourant := NiemeCoupDansPartieDuGraphe(whichGame,i);
          LitEnsembleDesFils(fichier,numCelluleCourante,ListeDesFils);
          if not(UpdatePositionEtTrait(position,coupCourant)) then
            begin
              RaiseError('On me demande d''inclure une partie impossible dans le graphe !');
              exit(CreePartieDansGrapheApprentissage);  {pas de parties illegales dans le graphe !!}
            end;


          if (coupCourant < 11) or (coupCourant > 88) then
              begin
                WritelnDansRapport('## ERROR : (coupCourant < 11) or (coupCourant > 88) dans CreePartieDansGrapheApprentissage');
                WritelnNumDansRapport('coupCourant = ',coupCourant);
              end;



          if CoupEstDansListe(fichier,coupCourant,ListeDesFils,numCelluleCoupSuivant)
            then
              begin
                numCelluleCourante := numCelluleCoupSuivant;
              end
            else
              begin

                LitCellule(fichier,numCelluleCourante,celluleCourante);
                NumCelluleCree := NbrePositionsDansGrapheApprentissage(fichier)+1;
                InitialiseCellule(celluleCree,NumCelluleCree);
                SetCouleur(CouleurDuNiemeCoupDansPartieDuGraphe(whichGame,i),celluleCree);
                SetCoup(coupCourant,celluleCree);
                celluleCree.numeroDuCoup := i;
                SetTrait(GetTraitOfPosition(position),celluleCree);

                if not(HasFils(celluleCourante))
                  then
                    begin
                      SetPere(numCelluleCourante,celluleCree);
                      SetFrere(numCelluleCree,celluleCree);
                      EcritCellule(fichier,numCelluleCree,celluleCree);

                      CreeLiaisonPeresVersFils(fichier,numCelluleCourante,numCelluleCree);

                    end
                  else
                    begin
                      LitCellule(fichier,GetFils(celluleCourante),cellAux);
                      SetFrere(GetFrere(cellAux),celluleCree);
                      SetFrere(numCelluleCree,cellAux);
                      SetPere(GetPere(cellAux),celluleCree);
                      EcritCellule(fichier,numCelluleCree,celluleCree);
                      EcritCellule(fichier,GetFils(celluleCourante),cellAux);
                    end;

                numCelluleCourante := numCelluleCree;
              end;

           suiteDesCellules.cardinal := i;
           suiteDesCellules.liste[i].numeroCellule := numCelluleCourante;
        end;
  end;
end;

procedure AjoutePartieDansGrapheApprentissage(var fichier : Graphe; partieStr : String255);
var s60 : PackedThorGame;
    s120 : String255;
    path : ListeDeCellules;
    autreCoupDiag : boolean;
begin
  s120 := partieStr;
  Normalisation(s120,autreCoupDiag,false);
  TraductionAlphanumeriqueEnThor(s120,s60);
  CreePartieDansGrapheApprentissage(fichier,s60,path);
end;


(* vérification que: 1) la cellule est bien formée
                      2) la cellule n'a de père mal formé
                      3) la cellule a un grand-père (sauf les fils de la racine)
                      4) la cellule n'a de fils mal formé
                      5) il n'exite pas de boucle infinie dans les orbites
                      6) toutes les cellules d'une meme orbite pointent sur le meme fils
                      7) toutes les cellules d'une meme orbite ont des peres differents
                      8) il n'exite pas de boucle infinie dans les listes de freres
                      9) tous les freres ont le meme pere
                      10) la cellule n'a deux fils identiques
                      11) la cellule a la meme couleur que le trait de la cellule pere *)
procedure VerifieIntegriteCellule(var fichier : Graphe; var cell : CelluleRec; numeroCellule : SInt32; const fonctionAppelante : String255);
var i,j,k,n : SInt32;
    first,cellAux : CelluleRec;
    Ensemble : ListeDeCellules;
    aux,debutListeChainee : SInt32;
    ok,probleme : boolean;
    listeDesFreresReparee : ListeDeCellules;
    orbiteReparee : ListeDeCellules;
    erreur : OSErr;

 procedure AnnonceProblemeDansRapport;
 begin
   WriteDansRapport('pb dans VerifieIntegriteCellule, fonctionAppelante = ');
   WritelnDansRapport(fonctionAppelante);
   probleme := true;
 end;

begin
  n := NbrePositionsDansGrapheApprentissage(fichier);
  probleme := false;

  with cell do
   if (pere < 0) or
      (pere > n) or
      (fils < 0) or
      (fils > n) or
      (memePosition <= 0) or
      (memeposition > n) or
      (frere < 0) or
      (frere > n) then
        begin
          AnnonceProblemeDansRapport;
          WritelnDansRapport('cellule mal formée :');
          AfficheCelluleDansRapport(fichier,numeroCellule,cell);
        end;


   if (not(HasPere(cell)) and (numeroCellule > 1)) or
       not(HasFrere(cell)) then
        begin
          {AnnonceProblemeDansRapport;}
          WritelnDansRapport('cellule isolée : '+NumEnString(numeroCellule));
          {AfficheCelluleDansRapport(fichier,numeroCellule,cell);}
        end;

   if HasPere(cell) then
     begin
       LitCellule(fichier,GetPere(cell),cellAux);
       if not(HasFils(cellAux)) then
         begin
           AnnonceProblemeDansRapport;
           WritelnDansRapport('Cellule ayant un père qui n''a pas de fils !');
           AfficheCelluleDansRapport(fichier,numeroCellule,cell);
         end;
       if (GetPere(cell) > 1) then  {pas la racine}
       if not(HasPere(cellAux))  then
         begin
           AnnonceProblemeDansRapport;
           WritelnDansRapport('Cellule ayant un père (autre que la racine) qui n''a pas de père !');
           AfficheCelluleDansRapport(fichier,numeroCellule,cell);
         end;
     end;

   if HasFils(cell) then
     begin
       LitCellule(fichier,GetFils(cell),cellAux);
       if not(HasPere(cellAux)) then
         begin
           AnnonceProblemeDansRapport;
           WritelnDansRapport('Cellule ayant un fils qui n''a pas de père !');
           AfficheCelluleDansRapport(fichier,numeroCellule,cell);
         end;
     end;


   if GetMemePosition(cell) <> numeroCellule then
     begin


       Ensemble.cardinal := 0;
       debutListeChainee := numeroCellule;
       aux := debutListeChainee;
       repeat
         LitCellule(fichier,aux,cellAux);
         Ensemble.cardinal := Ensemble.cardinal+1;
         ensemble.liste[Ensemble.cardinal].numeroCellule := aux;
         aux := GetMemePosition(cellAux);
       until (aux = debutListeChainee) or (Ensemble.cardinal >= kLongueurListeInfinie) or (aux <= 0);

       if (Ensemble.cardinal >= kLongueurListeInfinie) or (aux <= 0)
         then
           begin
             AnnonceProblemeDansRapport;
             WritelnDansRapport('Boucle infinie dans liste chaînée (positions identiques)');
             WritelnNumDansRapport('aux = ',aux);
             {AttendFrappeClavier;}
             for k := 1 to Min(10,Ensemble.cardinal) do
                begin
                  LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                  AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                  {AttendFrappeClavier;}
                end;

            erreur := RepareOrbite(fichier,debutListeChainee,orbiteReparee,'VerifieIntegriteCellule:');
           end
         else
           begin
             if Ensemble.cardinal > 0 then
               begin
                 ok := true;
                 LitCellule(fichier,Ensemble.liste[1].numeroCellule,first);
                 for k := 2 to Ensemble.cardinal do
                   begin
                     LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                     if GetFils(cellAux) <> GetFils(first) then ok := false;
                   end;
                 if not(ok) then
                   begin
                     AnnonceProblemeDansRapport;
                     WritelnDansRapport('positions identiques n''ayant pas le même fils !');
                     {AttendFrappeClavier;}
                     for k := 1 to Min(10,Ensemble.cardinal) do
                       begin
                         LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         {AttendFrappeClavier;}
                       end;
                   end;


                 ok := true;
                 LitCellule(fichier,Ensemble.liste[1].numeroCellule,first);
                 for k := 1 to Ensemble.cardinal do
                   begin
                     LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                     if not(HasPere(cellAux)) then ok := false;
                   end;
                 if not(ok) then
                   begin
                     AnnonceProblemeDansRapport;
                     WritelnDansRapport('cellule isolée dans orbite de similitude !');
                     {AttendFrappeClavier;}
                     for k := 1 to Min(10,Ensemble.cardinal) do
                       begin
                         LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         {AttendFrappeClavier;}
                       end;
                   end;


                 ok := true;
                 for i := 1 to Ensemble.cardinal do
                   begin
                     LitCellule(fichier,Ensemble.liste[i].numeroCellule,first);
                     for j := 1 to Ensemble.cardinal do
                       if i < j then
                       begin
                         LitCellule(fichier,Ensemble.liste[j].numeroCellule,cellAux);
                         if (GetPere(first) = GetPere(cellAux)) then ok := false;
                       end;
                   end;
                 if not(ok) then
                   begin
                     AnnonceProblemeDansRapport;
                     WritelnDansRapport('cellules frères dans la même orbite !');
                     {AttendFrappeClavier;}
                     for k := 1 to Min(10,Ensemble.cardinal) do
                       begin
                         LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         {AttendFrappeClavier;}
                       end;
                   end;

               end;
          end;
      end;

    if (GetFrere(cell) <> numeroCellule) then
      begin
       if not(HasFrere(cell)) or
          not(HasPere(cell))
          then
            begin
            end
          else
            begin


              Ensemble.cardinal := 0;
              debutListeChainee := numeroCellule;
              aux := debutListeChainee;
              repeat
                LitCellule(fichier,aux,cellAux);
                Ensemble.cardinal := Ensemble.cardinal+1;
                Ensemble.liste[Ensemble.cardinal].numeroCellule := aux;
                aux := GetFrere(cellAux);
              until (aux = debutListeChainee) or (Ensemble.cardinal >= kLongueurListeInfinie) or (aux <= 0);


              if (Ensemble.cardinal >= kLongueurListeInfinie) or (aux <= 0)
                then
                  begin
                    AnnonceProblemeDansRapport;
                    WritelnDansRapport('Boucle infinie dans liste chaînée (freres)');
                    WritelnNumDansRapport('aux = ',aux);
                    {AttendFrappeClavier;}
                    for k := 1 to Min(10,Ensemble.cardinal) do
                       begin
                         LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                         {AttendFrappeClavier;}
                       end;

                    erreur := RepareListeDesFreres(fichier,debutListeChainee,listeDesFreresReparee,'VerifieIntegriteCellule:');
                  end
                else
                  begin
                    if Ensemble.cardinal > 0 then
                      begin

                        ok := true;
                        LitCellule(fichier,Ensemble.liste[1].numeroCellule,first);
                        for k := 2 to Ensemble.cardinal do
                          begin
                            LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                            if GetPere(cellAux) <> GetPere(first) then ok := false;
                          end;
                        if not(ok) then
                          begin
                            AnnonceProblemeDansRapport;
                            WritelnDansRapport(CharToString('#')+NumEnString(numeroCellule)+' : frères mais pas même père…');
                            {AttendFrappeClavier;}
                            for k := 1 to Min(10,Ensemble.cardinal) do
                              begin
                                LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                                AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                                {AttendFrappeClavier;}
                              end;
                          end;

                        ok := true;
                        for i := 1 to Ensemble.cardinal do
                          for j := 1 to Ensemble.cardinal do
                            if (i <> j) and
                               (GetNiemeCoupDansListe(fichier,Ensemble,i) = GetNiemeCoupDansListe(fichier,Ensemble,j))
                                 then ok := false;
                        if not(ok) then
                          begin
                            AnnonceProblemeDansRapport;
                            WritelnDansRapport('deux fois le même frère');
                            {AttendFrappeClavier;}
                            for k := 1 to Min(10,Ensemble.cardinal) do
                              begin
                                LitCellule(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                                AfficheCelluleDansRapport(fichier,Ensemble.liste[k].numeroCellule,cellAux);
                                {AttendFrappeClavier;}
                              end;
                          end;
                      end;
                  end;
            end;
   end;
   if probleme then
     begin
       WritelnNumDansRapport('Un pb a ete trouve pour la cellule #',numeroCellule);
       WriteDansRapport('Sortie de VerifieIntegriteCellule, fonctionAppelante = ');
       WritelnDansRapport(fonctionAppelante);
       {AttendFrappeClavier;}
     end;
end;


procedure VerifieIntegriteGraphe(var fichier : Graphe);
var n,num : SInt32;
    tempoAfficheGraphe : boolean;
    cell : CelluleRec;
begin
 tempoAfficheGraphe := GetAfficheInfosApprentissage;
 SetAfficheInfosApprentissage(false);

 n := NbrePositionsDansGrapheApprentissage(fichier);
 WritelnDansRapport('');
 WritelnDansRapport('Vérification de l''intégrité du graphe…');
 WritelnDansRapport('il y a '+NumEnString(n)+' cellules dans le graphe');
 num := 1;
 while (num <= n) and not(Quitter) do
   begin
     {WritelnDansRapport(NumEnString(num));}
     if (num mod 20) = 0 then
       WritelnDansRapport('cellules '+NumEnString(num-19)+' à '+NumEnString(num)+' vérifiées');

     LitCellule(fichier,num,cell);
     VerifieIntegriteCellule(fichier,cell,num,'VerifieIntegriteGraphe');

     if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
     num := num+1;
   end;
   WritelnDansRapport('Vérification terminée.');
   WritelnDansRapport('');
   Quitter := false;
   SetAfficheInfosApprentissage(tempoAfficheGraphe);
end;


{chemin60 doit etre normalise depuis la position initiale}
function PositionEstDansLeGraphe(var fichier : Graphe; chemin60 : PackedThorGame; var suiteDesCellules : ListeDeCellules) : boolean;
var numCelluleCourante,numCelluleFils : SInt32;
    ListeDesFils : ListeDeCellules;
    longueur : SInt16;
    filsEstDansLeGraphe : boolean;
    coupCherche : SInt8;
    chemin : typePartiePourGraphe;
begin
  COPY_PACKED_GAME_TO_STR255(chemin60,chemin);

  PositionEstDansLeGraphe := false;
  if (LongueurPartieDuGraphe(chemin) > 0) then
  if (NiemeCoupDansPartieDuGraphe(chemin,1) = 56) then  {F5}
  if (NbrePositionsDansGrapheApprentissage(fichier) > 0) then
    if LongueurPartieDuGraphe(chemin) = 1
      then
        begin
          PositionEstDansLeGraphe := true;
          suiteDesCellules.cardinal := 1;
          suiteDesCellules.liste[1].numeroCellule := 1;
        end
      else
        begin
          longueur := 1;
          numCelluleFils := 1;
          repeat
            numCelluleCourante := numCelluleFils;
            suiteDesCellules.cardinal := longueur;
            suiteDesCellules.liste[longueur].numeroCellule := numCelluleCourante;

            inc(longueur);
            coupCherche := NiemeCoupDansPartieDuGraphe(chemin,longueur);
            LitEnsembleDesFils(fichier,numCelluleCourante,ListeDesFils);


            if (coupCherche < 11) or (coupCherche > 88) then
              begin
                WritelnDansRapport('## ERROR : (coupCherche < 11) or (coupCherche > 88) dans PositionEstDansLeGraphe');
                WritelnNumDansRapport('coupCherche = ',coupCherche);
              end;

            filsEstDansLeGraphe := CoupEstDansListe(fichier,coupCherche,ListeDesFils,numCelluleFils);
          until (longueur >= LongueurPartieDuGraphe(chemin)) or not(filsEstDansLeGraphe);

          if (longueur >= LongueurPartieDuGraphe(chemin)) and filsEstDansLeGraphe then
            begin
              suiteDesCellules.cardinal := longueur;
              suiteDesCellules.liste[longueur].numeroCellule := numCelluleFils;
              PositionEstDansLeGraphe := true;
            end;
      end;
end;

function TrouveCoupDansGrapheApprentissage(const partieStr : String255; var coup : SInt16) : boolean;
var filsJouables:listeDeProbas;
    sommeProbas,alea : double_t;
    i : SInt16;
    SommesPartielles : array[0..64] of double_t;
begin

  TrouveCoupDansGrapheApprentissage := false;
  coup := 44;

  CalculeProbabilitesOptimalesDeReponse(partieStr,filsJouables);
  if filsJouables.cardinal > 0 then
    begin
      sommeProbas := 0.0;
      for i := 1 to filsJouables.cardinal do
        sommeProbas := sommeProbas+filsJouables.liste[i].proba;

      if sommeProbas = 0.0
        then exit(TrouveCoupDansGrapheApprentissage)
        else
          begin
            SommesPartielles[0] := 0.0;
            for i := 1 to filsJouables.cardinal do
              begin
                filsJouables.liste[i].proba := filsJouables.liste[i].proba/sommeProbas;
                SommesPartielles[i] := SommesPartielles[i-1]+filsJouables.liste[i].proba;
              end;
            SommesPartielles[filsJouables.cardinal] := 1.0;  {pour les erreurs d'arrondi}

            RandomizeTimer;  {réinitialiser le générateur}
            alea := Abs(Random16())/32768.0;   {nombre aleatoire entre 0.0 et 1.0}
            if alea >= 1.0 then alea := 0.9999999;

            for i := 1 to filsJouables.cardinal do
              if (SommesPartielles[i-1] <= alea) and (alea < SommesPartielles[i]) then
                begin
                  TrouveCoupDansGrapheApprentissage := true;
                  coup := (filsJouables.liste[i].coup);
                  exit(TrouveCoupDansGrapheApprentissage);
                end;
         end;
    end;
end;


procedure GetFilsDeLaPositionCouranteDansLeGraphe(typesVoulus : EnsembleDeTypes;
                                                  tries : boolean;
                                                  var FilsSelectionnes:listeDeCellulesEtDeCoups);
var partie120 : String255;
    partie60 : PackedThorGame;
    fichier : Graphe;
    path,LesFils : ListeDeCellules;
    FilsGagnants,FilsNuls,FilsPerdants,FilsSansOpinion : ListeDeCellules;
    result : ListeDeCellules;
    cellule : CelluleRec;
    autreCoupQuatreDansPartie : boolean;
    i,theMove : SInt16;
    grapheDejaOuvertALArrivee : boolean;
    diagonaleInversee : boolean;
begin
  FilsSelectionnes.cardinal := 0;
  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      partie120 := PartieNormalisee(diagonaleInversee,false);
      TraductionAlphanumeriqueEnThor(partie120,partie60);
      SHORTEN_PACKED_GAME(partie60,nbreCoup);

      if PositionEstDansLeGraphe(fichier,partie60,path) then
        begin
          autreCoupQuatreDansPartie := (nbreCoup >= 4) and PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6;

          LitCellule(fichier,path.liste[path.cardinal].numeroCellule,cellule);
          if HasFils(cellule) then
            begin
              LitEnsembleDesFils(fichier,path.liste[path.cardinal].numeroCellule,lesFils);

              if tries
                then
                  begin
                    SelectionneDansListe(fichier,lesFils,TypesVoulus,lesFils);
                    SelectionneDansListe(fichier,lesFils,[kGainAbsolu,kGainDansT],FilsGagnants);
                    SelectionneDansListe(fichier,lesFils,[kNulleAbsolue,kNulleDansT],FilsNuls);
                    SelectionneDansListe(fichier,lesFils,[kPerteAbsolue,kPerteDansT],FilsPerdants);
                    SelectionneDansListe(fichier,lesFils,[kPasDansT,kPropositionHeuristique],FilsSansOpinion);
                    UnionListes(FilsGagnants,FilsNuls,result);
                    UnionListes(result,FilsPerdants,result);
                    UnionListes(result,FilsSansOpinion,result);
                  end
                else
                  begin
                    SelectionneDansListe(fichier,LesFils,TypesVoulus,result);
                  end;

              FilsSelectionnes.cardinal := result.cardinal;
              for i := 1 to FilsSelectionnes.cardinal do
                begin
                  FilsSelectionnes.liste[i].numeroCellule := result.liste[i].numeroCellule;
                  FilsSelectionnes.liste[i].coup := GetNiemeCoupDansListe(fichier,result,i);
                end;

              for i := 1 to FilsSelectionnes.cardinal do
                begin
                  theMove := FilsSelectionnes.liste[i].coup;
                  TransposeCoupPourOrientation(theMove,autreCoupQuatreDansPartie);
                  FilsSelectionnes.liste[i].coup := theMove;
                end;
              for i := 1 to lesFils.cardinal do
                begin
                  if not(possibleMove[FilsSelectionnes.liste[i].coup]) then
                    raiseError('coup illégal : '+CoupEnStringEnMajuscules(FilsSelectionnes.liste[i].coup));
                end;

            end;
        end;

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;


function PeutChoisirDansGrapheApprentissage(var coup,defense : SInt32) : boolean;
var partie120 : String255;
    autreCoupQuatreDansPartie : boolean;
    aux,coupNonNormalise,defenseNonNormalisee : SInt16;
    diagonaleInversee : boolean;
begin
  PeutChoisirDansGrapheApprentissage := false;
  partie120 := PartieNormalisee(diagonaleInversee,false);
  partie120 := TPCopy(partie120,1,2*nbreCoup);
  if TrouveCoupDansGrapheApprentissage(partie120,coupNonNormalise) then
    begin
      PeutChoisirDansGrapheApprentissage := true;

      autreCoupQuatreDansPartie := (nbreCoup >= 4) and PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6;

      aux := coupNonNormalise;
      TransposeCoupPourOrientation(aux,autreCoupQuatreDansPartie);
      coup := aux;

      partie120 := partie120+NumEnString(coupNonNormalise);
      if TrouveCoupDansGrapheApprentissage(partie120,defenseNonNormalisee) then
        begin
          defense := defenseNonNormalisee;
          TransposeCoupPourOrientation(defenseNonNormalisee,autreCoupQuatreDansPartie);
        end;
    end;
end;

function PositionCouranteEstDansGrapheApprentissage : boolean;
var partie120 : String255;
    partie60 : PackedThorGame;
    fichier : Graphe;
    path : ListeDeCellules;
    grapheDejaOuvertALArrivee : boolean;
    diagonaleInversee : boolean;
begin
  PositionCouranteEstDansGrapheApprentissage := false;
  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      partie120 := PartieNormalisee(diagonaleInversee,false);
      TraductionAlphanumeriqueEnThor(partie120,partie60);
      SHORTEN_PACKED_GAME(partie60, nbreCoup);

      PositionCouranteEstDansGrapheApprentissage := PositionEstDansLeGraphe(fichier,partie60,path);

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;

procedure CheminDepuisRacineGrapheEnThor(var fichier : Graphe; numCellule : SInt32; var partie60 : PackedThorGame);
var i,longueur : SInt32;
    cellule : CelluleRec;
    cheminExiste : boolean;
begin
  FILL_PACKED_GAME_WITH_ZEROS(partie60);
  if (numCellule >= 0) and (numCellule <= NbrePositionsDansGrapheApprentissage(fichier)) then
    begin
      LitCellule(fichier,numCellule,cellule);
      longueur := GetNumeroCoup(cellule);
      if (longueur > 0) and (longueur <= 60) then
        begin
          cheminExiste := true;
          for i := longueur downto 1 do
            if cheminExiste then
              begin
                LitCellule(fichier,numCellule,cellule);
                SET_NTH_MOVE_OF_PACKED_GAME(partie60, i, GetCoup(cellule));
                if (i > 1) then
                  if HasPere(cellule)
                    then numCellule := GetPere(cellule)
                    else cheminExiste := false;
              end;
          if cheminExiste
            then SET_LENGTH_OF_PACKED_GAME(partie60, longueur)
            else SET_LENGTH_OF_PACKED_GAME(partie60, 0);
        end;
    end;
end;

function CheminDepuisRacineGrapheEnAlphanumerique(var fichier : Graphe; numCellule : SInt32) : String255;
var s60 : PackedThorGame;
    result : String255;
begin
  CheminDepuisRacineGrapheEnThor(fichier,numCellule,s60);
  TraductionThorEnAlphanumerique(s60,result);
  CheminDepuisRacineGrapheEnAlphanumerique := result;
end;

procedure CompterLesPartiesDansGrapheApprentissage(AQuelCoup : SInt16;
                                                 var nbrePartiesDansGrapheApprentissage : SInt32);
var i,iMax : SInt32;
    cellule : CelluleRec;
    fichier : Graphe;
    nbPartiesAChaqueCoup : array[0..65] of SInt32;
    tempoAfficheGraphe : boolean;
    grapheDejaOuvertALArrivee : boolean;
begin
  tempoAfficheGraphe := GetAfficheInfosApprentissage;
  SetAfficheInfosApprentissage(false);

  Quitter := false;
  nbrePartiesDansGrapheApprentissage := 0;
  if (AQuelCoup >= 0) and (AQuelCoup <= 60) then
	  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
	    begin

	      {VerifieIntegriteGraphe(fichier);}
	      Quitter := false;

	      WritelnDansRapport('');
	      WritelnDansRapport('comptage du nombre de parties dans le graphe d''apprentissage');
	      for i := 0 to 60 do nbPartiesAChaqueCoup[i] := 0;

	      WriteDansrapport('il y a '+NumEnString(NbrePositionsDansGrapheApprentissage(fichier)));
	      WritelnDansRapport(' positions dans le graphe d''apprentissage…');

	      i := 1;
	      iMax := NbrePositionsDansGrapheApprentissage(fichier);
	      while (i <= iMax) and not(Quitter) do
	        begin
	          LitCellule(fichier,i,cellule);
	          with cellule do
	            if (numeroDuCoup >= 0) and (numeroDuCoup <= 60) then
	              inc(nbPartiesAChaqueCoup[numeroDuCoup]);
	          if (i mod 1000) = 0 then
	            WritelnDansRapport(CharToString('#')+NumEnString(i)+' : '+NumEnString(nbPartiesAChaqueCoup[35])+' parties');

	          if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
	          i := i+1;
	        end;

	      for i := 0 to 60 do
	        begin
	          WritelnDansRapport('il y a '+NumEnString(nbPartiesAChaqueCoup[i])+ ' positions au coup '+NumEnString(i));
	        end;
	      WritelnDansRapport('');
	      nbrePartiesDansGrapheApprentissage := nbPartiesAChaqueCoup[AQuelCoup];

	      if not(grapheDejaOuvertALArrivee) then
	        if FermeGrapheApprentissage(fichier) then DoNothing;
	    end;
  Quitter := false;
  SetAfficheInfosApprentissage(tempoAfficheGraphe);
end;

procedure NettoyerGrapheApprentissage(nomDuGraphe : String255);
var i,iMax,compteur : SInt32;
    cellule : CelluleRec;
    fichier : Graphe;
    tempoAfficheGraphe : boolean;
    grapheDejaOuvertALArrivee : boolean;
    temp : boolean;
begin
  tempoAfficheGraphe := GetAfficheInfosApprentissage;
  SetAfficheInfosApprentissage(false);

  temp := gEnEntreeSortieLongueSurLeDisque;
  gEnEntreeSortieLongueSurLeDisque := true;

  Quitter := false;
  if GrapheApprentissageExiste(nomDuGraphe,fichier,grapheDejaOuvertALArrivee) then
    begin

      VideBufferGrapheApprentissage;
      VerifieIntegriteGraphe(fichier);
      Quitter := false;
      AjusteSleep;

      WritelnDansRapport('');
      WritelnDansRapport('nettoyage du graphe d''apprentissage « '+nomDuGraphe+' » …');
      compteur := 0;
      i := 1;
      iMax := NbrePositionsDansGrapheApprentissage(fichier);
      while (i <= iMax) and not(Quitter) do
        begin
          LitCellule(fichier,i,cellule);
          if cellule.valeurMinimax = valeurIndeterminee then
            begin
              compteur := compteur+1;
              SetValeurMinimax(cellule,kPasDansT);
              EcritCellule(fichier,i,cellule);
            end;

          if not(HasPere(cellule)) and
             not(HasFils(cellule)) and
             not(HasFrere(cellule)) and
             (cellule.numeroDuCoup > 0) then
            begin
              cellule.numeroDuCoup := 0;
              cellule.coupEtCouleurs := 0;
              EcritCellule(fichier,i,cellule);
            end;

          if (i mod 10000) = 0 then
            WritelnDansRapport('cellules '+NumEnString(i-9999)+' à '+NumEnString(i)+' : nettoyées');

          if HasGotEvent(EveryEvent,theEvent,kWNESleep,NIL) then TraiteEvenements;
          i := i+1;
        end;
      WriteDansRapport('nettoyage terminé.');
      WritelnDansRapport('');

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
  Quitter := false;
  gEnEntreeSortieLongueSurLeDisque := temp;
  SetAfficheInfosApprentissage(tempoAfficheGraphe);
end;


procedure ListerToutesLesCellulesDansRapport;
var i : SInt32;
    cell : CelluleRec;
    fichier : Graphe;
    tempoAfficheGraphe : boolean;
    grapheDejaOuvertALArrivee : boolean;
begin
  tempoAfficheGraphe := GetAfficheInfosApprentissage;
  SetAfficheInfosApprentissage(false);

  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      for i := 1 to Min(NbrePositionsDansGrapheApprentissage(fichier),500) do
        begin
          LitCellule(fichier,i,cell);
          AfficheCelluleDansRapport(fichier,i,cell);
        end;

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
  SetAfficheInfosApprentissage(tempoAfficheGraphe);
end;

procedure VoirLesInfosDApprentissageDansRapport;
var cell,cellAux : CelluleRec;
    fichier : Graphe;
    partie120 : String255;
    partie60 : PackedThorGame;
    path,FilsConnus,FilsAffiches : ListeDeCellules;
    FilsGagnants,FilsNuls,FilsPerdants,FilsSansOpinion : ListeDeCellules;
    i : SInt32;
    autreCoupQuatreDansPartie : boolean;
    coup : SInt16;
    grapheDejaOuvertALArrivee : boolean;
    diagonaleInversee : boolean;
begin
  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      partie120 := PartieNormalisee(diagonaleInversee,false);
      TraductionAlphanumeriqueEnThor(partie120,partie60);
      SHORTEN_PACKED_GAME(partie60, nbreCoup);

      if PositionEstDansLeGraphe(fichier,partie60,path)
        then
          begin
            LitCellule(fichier,path.liste[path.cardinal].numeroCellule,cell);
            AfficheCelluleDansRapport(fichier,path.liste[path.cardinal].numeroCellule,cell);
            if HasFils(cell) then
              begin
                autreCoupQuatreDansPartie := (nbreCoup >= 4) and PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6;

                LitEnsembleDesFils(fichier,path.liste[path.cardinal].numeroCellule,FilsConnus);
                SelectionneDansListe(fichier,FilsConnus,[kGainAbsolu,kGainDansT],FilsGagnants);
                SelectionneDansListe(fichier,FilsConnus,[kNulleAbsolue,kNulleDansT],FilsNuls);
                SelectionneDansListe(fichier,FilsConnus,[kPerteAbsolue,kPerteDansT],FilsPerdants);
                SelectionneDansListe(fichier,FilsConnus,[kPasDansT,kPropositionHeuristique],FilsSansOpinion);
                UnionListes(FilsGagnants,FilsNuls,FilsAffiches);
                UnionListes(FilsAffiches,FilsPerdants,FilsAffiches);
                UnionListes(FilsAffiches,FilsSansOpinion,FilsAffiches);
                if FilsAffiches.cardinal <> filsConnus.cardinal then SysBeep(0);
                for i := 1 to FilsAffiches.cardinal do
                  begin
                    coup := GetNiemeCoupDansListe(fichier,FilsAffiches,i);
                    TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
                    LitCellule(fichier,FilsAffiches.liste[i].NumeroCellule,cellAux);
                    case GetValeurMinimax(cellAux) of
                      kPerteDansT               : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>perdant ');
                      kPerteAbsolue             : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>perdant (prouvé)');
                      kNulleDansT               : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>nulle ');
                      kNulleAbsolue             : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>nulle (prouvée)');
                      kGainDansT                : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>gagnant ');
                      kGainAbsolu               : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>gagnant (prouvé)');
                      kPropositionHeuristique   : WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>proposition heuristique');
                      otherwise                   WriteDansRapport('   '+NumEnString(GetNumeroCoup(cellAux))+'.'+CoupEnStringEnMajuscules(coup)+'=>?? ');
                    end;
                    WritelnDansRapport(' (#'+NumEnString(FilsAffiches.liste[i].numeroCellule)+CharToString(')'));
                  end;
             end;
          end
        else
          begin
            WritelnDansRapport('la position n''est pas dans le graphe…');
          end;

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;

procedure EcritLesInfosDApprentissage;
var cell,cellAux : CelluleRec;
    fichier : Graphe;
    partie120 : String255;
    partie60 : PackedThorGame;
    path,FilsConnus,FilsAffiches : ListeDeCellules;
    FilsGagnants,FilsNuls,FilsPerdants,FilsSansOpinion : ListeDeCellules;
    i : SInt32;
    autreCoupQuatreDansPartie : boolean;
    coup,prochainCoupDeLaPartie : SInt16;
    InfosGrapheRect : rect;
    oldPort : grafPtr;
    s : String255;
    grapheDejaOuvertALArrivee : boolean;
    diagonaleInversee : boolean;
begin
  if GetAfficheInfosApprentissage and
     GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      partie120 := PartieNormalisee(diagonaleInversee,false);
      TraductionAlphanumeriqueEnThor(partie120,partie60);
      SHORTEN_PACKED_GAME(partie60, nbreCoup);

      GetPort(oldport);
      EssaieSetPortWindowPlateau;
      SetRect(InfosGrapheRect,aireDeJeu.right+EpaisseurBordureOthellier+1,aireDeJeu.top+95,
                              aireDeJeu.right+1000,aireDeJeu.bottom-20);


      if PositionEstDansLeGraphe(fichier,partie60,path)
        then
          begin
            LitCellule(fichier,path.liste[path.cardinal].numeroCellule,cell);
            case GetValeurMinimax(cell) of
              kGainDansT                : if GetCouleur(cell) = Noir
                                           then
                                             if GetTrait(cell) = pionNoir
                                               then s := 'Noir est gagnant'
                                               else s := 'Blanc est perdant'
                                           else
                                             if GetTrait(cell) = pionBlanc
                                               then s := 'Blanc est gagnant'
                                               else s := 'Noir est perdant';
              kGainAbsolu               : if GetCouleur(cell) = Noir
                                           then
                                             if GetTrait(cell) = pionNoir
                                               then s := 'Noir est gagnant (prouvé)'
                                               else s := 'Blanc est perdant (prouvé)'
                                           else
                                             if GetTrait(cell) = pionBlanc
                                               then s := 'Blanc est gagnant  (prouvé)'
                                               else s := 'Noir est perdant  (prouvé)';
              kNulleDansT               : s := 'Nulle';
              kNulleAbsolue             : s := 'Nulle (prouvée)';
              kPerteDansT               : if GetCouleur(cell) = Noir
                                           then
                                             if GetTrait(cell) = pionNoir
                                               then s := 'Noir est perdant'
                                               else s := 'Blanc est gagnant'
                                           else
                                             if GetTrait(cell) = pionBlanc
                                               then s := 'Blanc est perdant'
                                               else s := 'Noir est gagnant';
              kPerteAbsolue             : if GetCouleur(cell) = Noir
                                           then
                                             if GetTrait(cell) = pionNoir
                                               then s := 'Noir est perdant (prouvé)'
                                               else s := 'Blanc est gagnant (prouvé)'
                                           else
                                             if GetTrait(cell) = pionBlanc
                                               then s := 'Blanc est perdant (prouvé)'
                                               else s := 'Noir est gagnant (prouvé)';
              kPropositionHeuristique   : s := 'c''est une proposition heuristique';
              kPasDansT                 : s := 'pas encore d''avis…';
            end; {case}
            MyEraseRect(InfosGrapheRect);
            MyEraseRectWithColor(InfosGrapheRect,OrangeCmd,blackPattern,'');
            WriteStringAt(s,InfosGrapheRect.left+7,InfosGrapheRect.top+10);

            if HasFils(cell) then
              begin
                autreCoupQuatreDansPartie := (nbreCoup >= 4) and PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6;

                LitEnsembleDesFils(fichier,path.liste[path.cardinal].numeroCellule,FilsConnus);
                {WritelnNumDansRapport('FilsConnus.cardinal = ',FilsConnus.cardinal);
                for i := 1 to FilsConnus.cardinal do
                  WritelnNumDansRapport('FilsConnus['+NumEnString(i)+'] = ',FilsConnus.liste[i].numeroCellule);}
                SelectionneDansListe(fichier,FilsConnus,[kGainDansT,kGainAbsolu],FilsGagnants);
                SelectionneDansListe(fichier,FilsConnus,[kNulleDansT,kNulleAbsolue],FilsNuls);
                SelectionneDansListe(fichier,FilsConnus,[kPerteDansT,kPerteAbsolue],FilsPerdants);
                SelectionneDansListe(fichier,FilsConnus,[kPasDansT,kPropositionHeuristique],FilsSansOpinion);
                UnionListes(FilsGagnants,FilsNuls,FilsAffiches);
                UnionListes(FilsAffiches,FilsPerdants,FilsAffiches);
                UnionListes(FilsAffiches,FilsSansOpinion,FilsAffiches);

                if (nbreCoup < nroDernierCoupAtteint) and
                   ((IndexProchainFilsDansGraphe < 1) or
                    (IndexProchainFilsDansGraphe > FilsAffiches.cardinal))
                    then prochainCoupDeLaPartie := GetNiemeCoupPartieCourante(nbreCoup+1)
                    else prochainCoupDeLaPartie := -139;

                {WritelnNumDansRapport('FilsAffiches.cardinal = ',FilsAffiches.cardinal);}

                for i := 1 to FilsAffiches.cardinal do
                  begin
                    coup := GetNiemeCoupDansListe(fichier,FilsAffiches,i);
                    TransposeCoupPourOrientation(coup,autreCoupQuatreDansPartie);
                    if coup = prochainCoupDeLaPartie then IndexProchainFilsDansGraphe := i;

                    LitCellule(fichier,FilsAffiches.liste[i].numeroCellule,cellAux);
                    case GetValeurMinimax(cellAux) of
                      kPerteDansT               : s := CoupEnStringEnMajuscules(coup)+'=>perdant ';
                      kPerteAbsolue             : s := CoupEnStringEnMajuscules(coup)+'=>perdant (prouvé)';
                      kNulleDansT               : s := CoupEnStringEnMajuscules(coup)+'=>nulle ';
                      kNulleAbsolue             : s := CoupEnStringEnMajuscules(coup)+'=>nulle (prouvée)';
                      kGainDansT                : s := CoupEnStringEnMajuscules(coup)+'=>gagnant ';
                      kGainAbsolu               : s := CoupEnStringEnMajuscules(coup)+'=>gagnant (prouvé)';
                      kPropositionHeuristique   : s := CoupEnStringEnMajuscules(coup)+'=>proposition heuristique';
                      otherwise s := CoupEnStringEnMajuscules(coup)+'=>?? ';
                    end;
                    WriteStringAt(s,InfosGrapheRect.left+7,InfosGrapheRect.top+10+i*12);
                  end;
                if IndexProchainFilsDansGraphe < 0 then IndexProchainFilsDansGraphe := 1;
                if IndexProchainFilsDansGraphe > FilsAffiches.cardinal then IndexProchainFilsDansGraphe := FilsAffiches.cardinal;
                if avecFlecheProchainCoupDansGraphe then
                  begin
                    PenPat(whitePattern);
                    PenSize(1,1);
                    Moveto(InfosGrapheRect.left,InfosGrapheRect.top+6+IndexProchainFilsDansGraphe*12);
                    Line(5,0);
                    Line(-2,-2);
                    Move(2,2);
                    Line(-2,2);
                    PenPat(blackPattern);
                  end;

             end;
          end
        else
          begin
            if nbreCoup >= 1
              then s := 'la position n''est pas dans le graphe…'
              else
                if (NbrePositionsDansGrapheApprentissage(fichier) >= 1) then
                  begin
                    LitCellule(fichier,1,cell);
                    case GetValeurMinimax(cell) of
                      kGainDansT                : s := 'Noir est gagnant';
                      kGainAbsolu               : s := 'Noir est gagnant (prouvé)';
                      kNulleDansT               : s := 'Nulle';
                      kNulleAbsolue             : s := 'Nulle (prouvée)';
                      kPerteDansT               : s := 'Noir est perdant';
                      kPerteAbsolue             : s := 'Noir est perdant (prouvé)';
                      kPropositionHeuristique   : s := 'c''est une proposition heuristique';
                      kPasDansT:                  s := 'pas encore d''avis…';
                    end;
                  end;
            MyEraseRect(InfosGrapheRect);
            MyEraseRectWithColor(InfosGrapheRect,OrangeCmd,blackPattern,'');
            WriteStringAt(s,InfosGrapheRect.left+7,InfosGrapheRect.top+10);
          end;
      SetPort(oldport);

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;
end;


END.
