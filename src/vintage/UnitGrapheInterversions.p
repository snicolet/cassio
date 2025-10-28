UNIT UnitGrapheInterversions;

INTERFACE







 USES UnitDefCassio;



{Initialisation et terminaison de l'unite}
procedure InitUnitApprentissageInterversion;
procedure LibereMemoireUnitApprentissageInterversion;


{Ajout d'interversions dans les graphes}
procedure AjouteInterversionDansGraphe(var fichier : Graphe; ligne1,ligne2 : String255; var estNouvelle : boolean);
procedure EnleveFausseInterversion(var fichier : Graphe; ligne1,ligne2 : String255);
procedure AjouterToutesLesInterversionsConnues(var fichier : Graphe);
procedure ApprendInterversionAlaVoleeDansGraphe(const ligne1,ligne2 : typePartiePourGraphe; annonceDansRapport : boolean);

{Statistques et affichage des interversions dans les graphes}
function NbInterversionsDeCettePartieDansGraphe(var fichier : Graphe; const whichGame : String255; dansRapport : boolean; tableLignes : TableParties60Ptr) : SInt32;
function InterversionDansLeGrapheApprentissage(const whichGame : String255; listerInterDansRapport : boolean; tableLignes : TableParties60Ptr) : boolean;
function NbFaconsArriverACetteCelluleDansGraphe(var fichier : Graphe; numCellule : SInt32; ecritVariantes : boolean; const partieEnAlpha : String255) : SInt32;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitNormalisation, UnitInterversions, UnitGameTree, UnitScannerUtils, UnitRapport, MyStrings, UnitPackedThorGame, UnitScannerOthellistique
    , UnitEntreesSortiesGraphe, UnitAccesGraphe, UnitPositionEtTraitSet, UnitCalculsApprentissage, UnitServicesRapport ;
{$ELSEC}
    {$I prelink/GrapheInterversions.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure InitUnitApprentissageInterversion;
begin
end;

procedure LibereMemoireUnitApprentissageInterversion;
begin
end;


{Détruit le sous arbre pointé par numCellule, y compris numCellule }
procedure DetruitSousArbre(var fichier : Graphe; numCellule : SInt32);
var orbite,lesFils : ListeDeCellules;
    cellule : CelluleRec;
    cellAux : CelluleRec;
    aux : SInt32;
    k : SInt16;
begin
  LitCellule(fichier,numCellule,cellule);

  if not(HasPere(cellule)) and not(HasFrere(cellule)) then exit;

  LitOrbite(fichier,numCellule,orbite);
  if orbite.cardinal > 1
    then
      begin
        aux := NumeroDerniereCellule(orbite);
        LitCellule(fichier,numCellule,cellule);
        LitCellule(fichier,aux,cellAux);
        SetMemePosition(GetMemePosition(cellule),cellAux);
        SetMemePosition(numCellule,cellule);
        EcritCellule(fichier,aux,cellAux);
        EcritCellule(fichier,numCellule,cellule);
        if HasFils(cellule) then
          begin
            CreeLiaisonPeresVersFils(fichier,aux,GetFils(cellule));
            CreeLiaisonFreresVersPere(fichier,GetFils(cellule),aux);
          end;
      end
    else
      begin
        LitEnsembleDesFils(fichier,numCellule,LesFils);
        for k := 1 to lesFils.cardinal do
          DetruitSousArbre(fichier,lesFils.liste[k].numeroCellule);
      end;
  IsoleCellule(fichier,numCellule);
end;



procedure UnifiePositions(var fichier : Graphe; numCellule1,numCellule2 : SInt32);
var fils1,fils2 : ListeDeCellules;
    cellule1,cellule2 : CelluleRec;
    cellAux : CelluleRec;
    j : SInt16;
    orbite : ListeDeCellules;
    numUnificateur,numFilsABouger : SInt32;
    Unificateur,FilsABouger : CelluleRec;
    freres2 : ListeDeCellules;
    changement : boolean;
    coup : SInt8;
begin

  if numCellule1 = numCellule2 then exit;

  LitCellule(fichier,numCellule1,cellule1);
  LitCellule(fichier,numCellule2,cellule2);
  LitEnsembleDesFils(fichier,numCellule1,fils1);
  LitEnsembleDesFils(fichier,numCellule2,fils2);

  if cellule1.numeroDuCoup <> cellule1.numeroDuCoup then
    begin
      RaiseError('Unification à des coups différents : #'+IntToStr(numCellule1)+' et #'+IntToStr(numCellule2));
      exit;
    end;

  if (fils1.cardinal = 0) and (fils2.cardinal = 0) then exit;

  if (fils1.cardinal = 0) and (fils2.cardinal > 0)
    then
      begin
        CreeLiaisonFreresVersPere(fichier,GetFils(cellule2),numCellule1);
        CreeLiaisonPeresVersFils(fichier,numCellule1,GetFils(cellule2));
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule1,changement);
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule2,changement);
        exit;
      end;

   if (fils1.cardinal > 0) and (fils2.cardinal = 0)
    then
      begin
        CreeLiaisonPeresVersFils(fichier,numCellule2,GetFils(cellule1));
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule1,changement);
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule2,changement);
        exit;
      end;

   if (fils1.cardinal > 0) and (fils2.cardinal > 0) then
    if CelluleEstDansListe(GetFils(cellule2),fils1) then
      begin
        CreeLiaisonPeresVersFils(fichier,numCellule2,GetFils(cellule1));
        CreeLiaisonFreresVersPere(fichier,GetFils(cellule2),numCellule1);
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule1,changement);
        CalculeToutesLesValeursDeLOrbite(fichier,numCellule2,changement);
        exit;
      end;


   if (fils1.cardinal > 0) and (fils2.cardinal > 0) then
     begin
       for j := 1 to fils2.cardinal do
         begin
           numFilsABouger := fils2.liste[j].numeroCellule;
           LitCellule(fichier,numFilsABouger,FilsABouger);

           LitEnsembleDesFreres(fichier,numFilsABouger,freres2);
           if freres2.cardinal > 1 then
             begin
               LitCellule(fichier,NumeroDerniereCellule(freres2),cellAux);
               SetFrere(GetFrere(FilsABouger),cellAux);
               EcritCellule(fichier,NumeroDerniereCellule(freres2),cellAux);
               CreeLiaisonPeresVersFils(fichier,GetPere(FilsABouger),GetFrere(FilsABouger));
             end;

           coup := GetNiemeCoupDansListe(fichier,fils2,j);

           if (coup < 11) or (coup > 88) then
              begin
                WritelnDansRapport('## ERROR : (coup < 11) or (coup > 88) dans UnifiePositions');
                WritelnNumDansRapport('coup = ',coup);
              end;

           if not(CoupEstDansListe(fichier,coup,fils1,numUnificateur))
             then
               begin
                 LitCellule(fichier,GetFils(cellule1),cellAux);
                 LitCellule(fichier,numFilsABouger,FilsABouger);
                 if GetPere(FilsABouger) = GetPere(cellAux) then raiseError('GetPere(FilsABouger) = GetPere(cellAux)');
                 SetFrere(GetFrere(cellAux),FilsABouger);
                 SetFrere(numFilsABouger,cellAux);
                 SetPere(GetPere(cellAux),FilsABouger);
                 EcritCellule(fichier,numFilsABouger,FilsABouger);
                 EcritCellule(fichier,GetFils(cellule1),cellAux);
               end
             else
               begin
                 if numUnificateur = numFilsABouger
                   then
                     RaiseError('numUnificateur = numFilsABouger')
                   else
                   begin
                     LitOrbite(fichier,numFilsABouger,orbite);
                     if orbite.cardinal >= 2 then
                       if CelluleEstDansListe(numUnificateur,orbite)
                         then             {même orbite}
                           begin
                             LitCellule(fichier,numFilsABouger,FilsABouger);
                             LitCellule(fichier,NumeroDerniereCellule(orbite),cellAux);
                             SetMemePosition(GetMemePosition(FilsABouger),cellAux);
                             SetMemePosition(numFilsABouger,FilsABouger);
                             EcritCellule(fichier,numFilsABouger,FilsABouger);
                             EcritCellule(fichier,NumeroDerniereCellule(orbite),cellAux);
                           end
                         else             {orbite distinctes}
                           begin
                             LitCellule(fichier,numUnificateur,Unificateur);
                             LitCellule(fichier,numFilsABouger,FilsABouger);
                             LitCellule(fichier,NumeroDerniereCellule(orbite),cellAux);
                             SetMemePosition(GetMemePosition(Unificateur),cellAux);
                             SetMemePosition(GetMemePosition(FilsABouger),Unificateur);
                             SetMemePosition(numFilsABouger,FilsABouger);
                             EcritCellule(fichier,numUnificateur,Unificateur);
                             EcritCellule(fichier,numFilsABouger,FilsABouger);
                             EcritCellule(fichier,NumeroDerniereCellule(orbite),cellAux);
                           end;

                     UnifiePositions(fichier,numUnificateur,numFilsABouger);
                     IsoleCellule(fichier,numFilsABouger);
                   end;
               end;
         end;
      CreeLiaisonPeresVersFils(fichier,numcellule2,GetFils(cellule1));
      CalculeToutesLesValeursDeLOrbite(fichier,numCellule1,changement);
      CalculeToutesLesValeursDeLOrbite(fichier,numCellule2,changement);
      exit;
    end;

  RaiseError('Should never happen in UnifiePositions');

end;


procedure AjouteInterversionDansGraphe(var fichier : Graphe; ligne1,ligne2 : String255; var estNouvelle : boolean);
var longueur,k : SInt16;
    s1,s2 : PackedThorGame;
    Orbite1,Orbite2 : ListeDeCellules;
    path1,path2 : ListeDeCellules;
    cell1,cell2 : CelluleRec;
    num1,num2,temp : SInt32;
    dejaTraitee,autoVidage,ok : boolean;
begin
  estNouvelle := false;

  autoVidage := GetAutoVidageDuRapport;
  SetAutoVidageDuRapport(true);
  if LENGTH_OF_STRING(ligne1) = LENGTH_OF_STRING(ligne2) then
    begin
      TraductionAlphanumeriqueEnThor(ligne1,s1);
      TraductionAlphanumeriqueEnThor(ligne2,s2);

      RaccourcirInterversion(s1,s2,longueur,ok);
      if not(ok) or (longueur <= 4) then
        begin
          WritelnDansRapport('## WARNING : apparentissage d''une interversion fausse ou trop courte dans le graphe :');
          WritelnDansRapport(ligne1+' = '+ligne2);
          SetAutoVidageDuRapport(autoVidage);
          exit;
        end;

      CreePartieDansGrapheApprentissage(fichier,s1,path1);
      CreePartieDansGrapheApprentissage(fichier,s2,path2);

      num1 := path1.liste[longueur].numeroCellule;
      num2 := path2.liste[longueur].numeroCellule;

      LitOrbite(fichier,num1,Orbite1);
      LitOrbite(fichier,num2,Orbite2);

      dejaTraitee := CelluleEstDansListe(num2,Orbite1);

      estNouvelle := not(dejaTraitee);

      if not(dejaTraitee) then
        begin
          LitCellule(fichier,num1,cell1);
          LitCellule(fichier,num2,cell2);
          temp := GetMemePosition(cell1);
          SetMemePosition(GetMemePosition(cell2),cell1);
          SetMemePosition(temp,cell2);
          EcritCellule(fichier,num1,cell1);
          EcritCellule(fichier,num2,cell2);
          if HasFils(cell1) or HasFils(cell2) then
            begin
             LitOrbite(fichier,num2,Orbite2);
             for k := 1 to Orbite2.cardinal do
               UnifiePositions(fichier,num1,Orbite2.liste[k].numeroCellule);
            end;
        end;
      PropageToutesLesValeursDansLeGraphe(fichier,num1);
      PropageToutesLesValeursDansLeGraphe(fichier,num2);
    end;
  SetAutoVidageDuRapport(autoVidage);
end;

procedure EnleveFausseInterversion(var fichier : Graphe; ligne1,ligne2 : String255);
var longueur,j,k : SInt16;
    s1,s2 : PackedThorGame;
    Orbite1,Orbite2 : ListeDeCellules;
    path1,path2,LesFils : ListeDeCellules;
    cellule : CelluleRec;
    num1,num2,temp : SInt32;
    changement : boolean;
begin
  if LENGTH_OF_STRING(ligne1) = LENGTH_OF_STRING(ligne2) then
    begin
      TraductionAlphanumeriqueEnThor(ligne1,s1);
      TraductionAlphanumeriqueEnThor(ligne2,s2);
      longueur := GET_LENGTH_OF_PACKED_GAME(s1);
      CreePartieDansGrapheApprentissage(fichier,s1,path1);
      CreePartieDansGrapheApprentissage(fichier,s2,path2);
      num1 := path1.liste[longueur].numeroCellule;
      num2 := path2.liste[longueur].numeroCellule;
      LitOrbite(fichier,num1,Orbite1);
      LitOrbite(fichier,num2,Orbite2);
      if CelluleEstDansListe(num2,Orbite1) then
        begin
          LitEnsembleDesFils(fichier,num2,lesFils);
          for j := 1 to lesFils.cardinal do
             DetruitSousArbre(fichier,lesFils.liste[j].numeroCellule);
          for k := 1 to Orbite1.cardinal do
            begin
              temp := orbite1.liste[k].numeroCellule;
              LitCellule(fichier,temp,cellule);
              SetMemePosition(temp,cellule);
              SetFils(pasDeFils,cellule);
              EcritCellule(fichier,temp,cellule);
              CalculeToutesLesValeursDuGraphe(fichier,temp,changement);
              PropageToutesLesValeursDansLeGraphe(fichier,temp);
            end;
        end;
    end;
end;

procedure AjouterToutesLesInterversionsConnues(var fichier : Graphe);
var nbInterversions,t : SInt16;
    faut,canon : PackedThorGame;
    ligne1,ligne2 : String255;
    ligne1_255,ligne2_255 : String255;
    changed : boolean;
begin
  nbInterversions := numeroInterversion[33];

  WritelnDansRapport('nb interversions à apprendre = '+IntToStr(nbInterversions));
  for t := 1 to nbInterversions do
    begin
      COPY_STR60_TO_PACKED_GAME(interversionFautive^^[t], faut);
      COPY_STR60_TO_PACKED_GAME(interversionCanonique^^[t], canon);
      SET_NTH_MOVE_OF_PACKED_GAME(faut, 1, 56);   (** F5 **)
      SET_NTH_MOVE_OF_PACKED_GAME(canon, 1, 56);  (** F5 **)
      TraductionThorEnAlphanumerique(faut,ligne1_255);
      TraductionThorEnAlphanumerique(canon,ligne2_255);
      ligne1 := ligne1_255;
      ligne2 := ligne2_255;
      AjouteInterversionDansGraphe(fichier,ligne1,ligne2,changed);
      if (t mod 20) = 0 then WritelnDansRapport(IntToStr(t)+CharToString('…'));
    end;
end;

procedure ApprendInterversionAlaVoleeDansGraphe(const ligne1,ligne2 : typePartiePourGraphe; annonceDansRapport : boolean);
var fichier : Graphe;
    changed : boolean;
    grapheDejaOuvertALArrivee : boolean;
begin
  {VideBufferGrapheApprentissage;}

  if GrapheApprentissageExiste(nomGrapheInterversions,fichier,grapheDejaOuvertALArrivee) then
    begin

      AjouteInterversionDansGraphe(fichier,ligne1,ligne2,changed);
      if changed and annonceDansRapport then
        begin
          WritelnDansRapport('');
          WritelnDansRapport('Création d''une interversion dans le fichier « '+nomGrapheInterversions+' » :');
          WritelnDansRapport(Concat(ligne1,CharToString('='),ligne2));
        end;
      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;

  {VideBufferGrapheApprentissage;}

  (*

  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      AjouteInterversionDansGraphe(fichier,ligne1,ligne2,changed);
      if changed and annonceDansRapport then
        begin
          WritelnDansRapport('');
          WritelnDansRapport('Apprentissage d''une interversion dans le fichier « '+nomGrapheApprentissage+' » :');
          WritelnDansRapport(Concat(ligne1,CharToString('='),ligne2));
        end;
      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;
    end;

  *)

  {VideBufferGrapheApprentissage;}
end;


function NbInterversionsDeCettePartieDansGraphe(var fichier : Graphe; const whichGame : String255; dansRapport : boolean; tableLignes : TableParties60Ptr) : SInt32;
var partie255 : String255;
    partie120 : String255;
    partie60 : PackedThorGame;
    path,orbiteInterversions : ListeDeCellules;
    i{,nbChemins} : SInt32;
    autreCoupQuatre : boolean;
    whichGameNormalise : String255;
begin
  NbInterversionsDeCettePartieDansGraphe := 0;

  partie120 := whichGame;
  Normalisation(partie120,autreCoupQuatre,false);
  whichGameNormalise := partie120;
  TraductionAlphanumeriqueEnThor(whichGameNormalise,partie60);

  if PositionEstDansLeGraphe(fichier,partie60,path) then
    begin
      LitOrbite(fichier,path.liste[path.cardinal].numeroCellule,orbiteInterversions);
      if (orbiteInterversions.cardinal >= 2) then
        begin
          if dansRapport then WritelnNumDansRapport('orbiteInterversions.cardinal = ',orbiteInterversions.cardinal);
          for i := 1 to orbiteInterversions.cardinal do
            if dansRapport or (tableLignes <> NIL) then
            begin
              CheminDepuisRacineGrapheEnThor(fichier,orbiteInterversions.liste[i].numeroCellule,partie60);
              TransposePartiePourOrientation(partie60,autreCoupQuatre,1,60);

              TraductionThorEnAlphanumerique(partie60,partie255);
              if dansRapport then
                WritelnDansRapport(partie255);
              if (tableLignes <> NIL) and (tableLignes^.cardinal < 100) then
                begin
                  inc(tableLignes^.cardinal);
                  tableLignes^.table[tableLignes^.cardinal] := partie60;
                end;
            end;
        end;
      NbInterversionsDeCettePartieDansGraphe := orbiteInterversions.cardinal-1;

      {
      nbChemins := NbFaconsArriverACetteCelluleDansGraphe(fichier,path.liste[path.cardinal].numeroCellule,false,'');
      if nbChemins > 1 then WritelnNumDansRapport('nbChemins = ',nbChemins);
      }

    end;
end;

function InterversionDansLeGrapheApprentissage(const whichGame : String255; listerInterDansRapport : boolean; tableLignes : TableParties60Ptr) : boolean;
var fichier : Graphe;
    nbInterversions : SInt16;
    grapheDejaOuvertALArrivee : boolean;
begin
  InterversionDansLeGrapheApprentissage := false;

  {VideBufferGrapheApprentissage;}

  {

  if GrapheApprentissageExiste(nomGrapheApprentissage,fichier,grapheDejaOuvertALArrivee) then
    begin

      nbInterversions := NbInterversionsDeCettePartieDansGraphe(fichier,whichGame,listerInterDansRapport,tableLignes);
      InterversionDansLeGrapheApprentissage := (nbInterversions > 0);

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;

      exit;
    end;

  }

  {VideBufferGrapheApprentissage;}

  if GrapheApprentissageExiste(nomGrapheInterversions,fichier,grapheDejaOuvertALArrivee) then
    begin

      nbInterversions := NbInterversionsDeCettePartieDansGraphe(fichier,whichGame,listerInterDansRapport,tableLignes);
      InterversionDansLeGrapheApprentissage := (nbInterversions > 0);

      if not(grapheDejaOuvertALArrivee) then
        if FermeGrapheApprentissage(fichier) then DoNothing;

      exit;
    end;

  {VideBufferGrapheApprentissage;}
end;

function NbFaconsArriverACetteCelluleDansGraphe(var fichier : Graphe; numCellule : SInt32; ecritVariantes : boolean; const partieEnAlpha : String255) : SInt32;
var cellule : CelluleRec;
    orbite : ListeDeCellules;
    i,somme : SInt32;
begin
  LitCellule(fichier,numCellule,cellule);
  if not(HasPere(cellule))  { racine ? }
    then
      begin
        NbFaconsArriverACetteCelluleDansGraphe := 1;
        if ecritVariantes then WritelnDansRapport(CoupEnStringEnMajuscules(GetCoup(cellule))+partieEnAlpha);
      end
    else
      begin
        LitOrbite(fichier,numCellule,orbite);
        somme := 0;
        for i := 1 to orbite.cardinal do
          begin
            LitCellule(fichier,orbite.liste[i].numeroCellule,cellule);
            if HasPere(cellule) then
              if ecritVariantes
                then somme := somme+NbFaconsArriverACetteCelluleDansGraphe(fichier,GetPere(cellule),true,CoupEnStringEnMajuscules(GetCoup(cellule))+partieEnAlpha)
                else somme := somme+NbFaconsArriverACetteCelluleDansGraphe(fichier,GetPere(cellule),false,'');
          end;
        NbFaconsArriverACetteCelluleDansGraphe := somme;
      end;
end;





END.

