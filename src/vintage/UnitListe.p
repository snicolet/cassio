UNIT UnitListe;




INTERFACE








 USES UnitDefCassio;





{initialisation et destruction de l'unite}
procedure InitUnitListe;
procedure LibereMemoireUnitListe;
procedure ResetListeDeParties;


{fonctions pour desactiver temporairement les calculs sur la liste de parties}
procedure SetAutorisationCalculsLongsSurListe(flag : boolean);
function AutorisationCalculsLongsSurListe : boolean;


{iterateurs sur les parties de la liste}
procedure ForEachPositionInGameDo(partie60 : PackedThorGame; DoWhat : MilieuDePartieProc; var result : SInt32);
procedure ForEachGameInListDo(FiltreNumRef : FiltreNumRefProc; FiltreGame : FiltreGameProc; DoWhat : GameInListProc; var result : SInt32);
procedure ForEachGameInSortedListDo(FiltreNumRef : FiltreNumRefProc; FiltreGame : FiltreGameProc; DoWhat : GameInListProc; var result : SInt32);
function NumberOfGamesWithThisReferenceFilter(FiltreNumRef : FiltreNumRefProc; var result : SInt32) : SInt32;


{filtres a utiliser pour les iterateurs ci-dessus}
function bidFiltreNumRefProc(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;
function bidFiltreGameProc(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var result : SInt32) : boolean;


{dessin de la liste}
function  CalculeNbreLignesVisiblesFntreListe : SInt32;
function GetHauteurChaqueLigneDansListe : SInt32;
procedure EcritPartieDansFenetreListe(nroPartie : SInt32; autreCoupQuatreDansPartie : boolean; yposition : SInt32);
procedure EcritListeParties(withCheckEvent : boolean; fonctionAppelante : String255);
procedure EcritPourquoiPasDePartieDansListe;
procedure EffacerRectanglePartieDansListe(whichRect : rect; nroRefPartie : SInt32);
function  RisqueDeScrollIncorrect(toutDescend : boolean) : boolean;
procedure ScrollEtEcritPartieVisibleListe(toutDescend,withCheckEvent : boolean);
function LargeurNormaleFenetreListe(nbreDeColonnes : SInt32) : SInt32;


{ruban de la liste}
procedure EcritRubanListe(avecDessinDesCriteres : boolean);
procedure DoChangeEcritTournoi(nouveauNombreDeColonnes : SInt16);
procedure SetValeursStandardRubanListe(nbColonnes : SInt16);
procedure MetCriteresDansRuban;
procedure CalculEmplacementCriteresListe;


{ouverture/fermeture des controles de la fenetre}
procedure OuvreControlesListe;
procedure CloseControlesListe;
procedure DoActivateFenetreListe(activation : boolean);


{gestion de l'ascenseur}
procedure MontrerAscenseurListe;
procedure CacherAscenseurListe;
procedure AjustePositionAscenseurListe;
procedure AjustePouceAscenseurListe(avecDessinDeLAscensseur : boolean);
procedure FiltreAscenseurListe(theControl : ControlHandle; partCode : SInt16);
function  MyTrackControlIndicatorPartListe(TheControl : ControlHandle) : SInt16;
procedure DessineBoiteTailleEtAscenseurDroite(whichWindow : WindowPtr);


{partie hilitee}
procedure MontePartieHilitee(revenirAuDebut : boolean);
procedure DescendPartieHilitee(allerALaFin : boolean);
function  CoupSuivantPartieSelectionnee(nroHilite : SInt32) : SInt16;
procedure ChangePartieHilitee(nouvellePartieHilitee,anciennePartieHilitee : SInt32);
procedure SetPartieHilitee(numero : SInt32);
procedure SetPartieHiliteeEtAjusteAscenseurListe(numero : SInt32);
procedure NroHilite2NroReference(nroHilite : SInt32; var nroReference : SInt32);
procedure NroReference2NroHilite(nroReference : SInt32; var nroHilite : SInt32);
function NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre : SInt32;


{calcul des parties actives}
function CassioEstEnTrainDeCalculerLaListe : boolean;
procedure CalculsEtAffichagePourBase(infosDejaCalculees : boolean; withCheckEvent : boolean);
procedure TraiteDemandeCalculsPourBase(fonctionAppelante : String255);
procedure LanceNouvelleDemandeCalculsPourBase(infosDejaCalculees, withCheckEvent : boolean);
procedure LanceCalculsRapidesPourBaseOuNouvelleDemande(infosDejaCalculees,withCheckEvent : boolean);
procedure ConstruitTablePartiesActivesSansInter(partie60 : PackedThorGame; withCheckEvent : boolean);
procedure ConstruitTablePartiesActivesAvecInter(partie60 : PackedThorGame; withCheckEvent : boolean);
procedure ConstruitTablePartiesActivesAvecToutesInter(partie60 : PackedThorGame; withCheckEvent : boolean);
procedure ConstruitTablePartiesActives(infosDejaCalculees : boolean; withCheckEvent : boolean);
procedure RecopierPartiesCompatiblesCommePartiesActives;
procedure IncrementeMagicCookieDemandeCalculsBase;


{cache des parties actives}
function GetNombreDePartiesActivesDansLeCachePourCeCoup(numeroDuCoup : SInt32) : SInt32;
procedure SetNombreDePartiesActivesDansLeCachePourCeCoup(numeroDuCoup, nbrePartiesActives : SInt32);
procedure InvalidateNombrePartiesActivesDansLeCache(quelNroCoup : SInt16);
procedure InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
function ListePartiesEstGardeeDansLeCache(quelCoup,nombrePartiesCompatibles : SInt32) : boolean;


{pied de page}
procedure DessinePiedDePageFenetreListe;
procedure DessineCheckBoxInclurePartiesAvecOrdinateurs;
procedure SetInclurePartiesAvecOrdinateursDansListe(flag : boolean);
function InclurePartiesAvecOrdinateursDansListe : boolean;


{haut de page : gestion des boites dans le ruban}
function  FenetreListeEstEnModeEntree : boolean;
procedure PasseListeEnModeEntree(boxActivee : SInt16);


{titre d'une partie, avec les joueurs, le tournoi, le numero du coup, etc. }
procedure EssayerConstruireTitrePartie;
procedure EssayerConstruireTitreDapresListe(nroPartie : SInt32);
function ConstruireTitreDapresListeParNroRefPartie(nroReference : SInt32) : String255;
function ConstruireChaineReferencesPartie(nroNoir,nroBlanc,nroTournoi,annee,scoreNoir : SInt32; avecScores : boolean; numeroProchainCoup : SInt32) : String255;
function ConstruireChaineReferencesPartieParNroRefPartie(nroReference : SInt32; avecScores : boolean; numeroProchainCoup : SInt32) : String255;
function ConstruireChaineReferencesPartieParNumeroReference(nroReference : SInt32; descriptionComplete : boolean) : String255;
function ConstruireChaineReferencesPartieDapresListe(nroPartie : SInt32; descriptionComplete : boolean) : String255;


{fonctions diverses}
procedure TraiteSourisListe(evt : eventRecord);
procedure DoChangerOrdreListe;
procedure ConstruitPositionEtCoupDapresListe(nroPartie : SInt32; var positionEtCoupStr : String255);
function GetPartieEnAlphaDapresListe(nroReference,jusquaQuelCoup : SInt32) : String255;
function DernierePartieCompatibleEnMemoire(var numeroCoup,nroReference : SInt32) : String255;
procedure InitInfosFermetureListePartie(var infos : InfosFermetureFenetreListeRec);
procedure SaveInfosFermetureListePartie(source : ListePartiesRec; var dest : InfosFermetureFenetreListeRec);
procedure ConstruitTableNumeroReference(infosDejaCalculees,withCheckEvent : boolean);
procedure EcritTableCompatible;
procedure InvalidateJustificationPasDePartieDansListe;
function GetAutorisationChargerLaBaseSansPasserParLeDialogue : boolean;
procedure SetAutorisationChargerLaBaseSansPasserParLeDialogue(flag : boolean);


{gestion des caracteristiques des parties de la liste}

{partie hilitee}
function GetNumeroReferencePartieHilitee : SInt32;
function EstLaPartieHilitee(nroReferencePartie : SInt32) : boolean;


{parties actives}
procedure SetPartieActive(nroReferencePartie : SInt32; flag : boolean);
function PartieEstActive(nroReferencePartie : SInt32) : boolean;
procedure DesactiverToutesLesParties;


{parties detruites}
procedure DoSupprimerPartiesDansListe;
procedure SetPartieDetruite(nroReferencePartie : SInt32; flag : boolean);
procedure DetruirePartieDeLaListe(nroReferencePartie : SInt32);
function PartieDeLaListeEstDetruite(nroReferencePartie : SInt32) : boolean;
procedure SetAucunePartieDetruiteDansLaListe;
function NbrePartiesDetruitesDansLaListe : SInt32;


{parties selectionnees}
procedure SelectionnerPartieDeLaListe(nroReferencePartie : SInt32);
procedure DeselectionnerPartieDeLaListe(nroReferencePartie : SInt32);
function PartieEstDansLaSelection(nroReferencePartie : SInt32) : boolean;
function PartieEstActiveEtSelectionnee(nroReferencePartie : SInt32) : boolean;
procedure DeselectionnerToutesLesPartiesDansLaListe;
procedure SelectionnerToutesLesPartiesActivesDansLaListe;
procedure SelectionnerToutesLesPartiesDansLaListe;
procedure SelectionnerToutesLesPartiesVerifiantCePredicat(whichPredicate : FiltreNumRefProc);
function NbPartiesDansLaSelectionDeLaListe : SInt32;
function NbPartiesActivesDansLaSelectionDeLaListe : SInt32;
function PremierePartieDeLaSelection(var nroReference : SInt32) : SInt32;
procedure InitSelectionDeLaListe;


{parties compatibles selon les sous-criteres}
procedure SetPartieCompatibleParCriteres(nroReferencePartie : SInt32; flag : boolean);
function PartieEstCompatibleParCriteres(nroReferencePartie : SInt32) : boolean;
procedure LaveTableCriteres;


{parties dans lesquelles aucun des joueurs n'est un ordinateur}
procedure SetPartieEstSansOrdinateur(nroReferencePartie : SInt32; flag : boolean);
function PartieEstSansOrdinateur(nroReferencePartie : SInt32) : boolean;


{parties utilisees pour le calcul du classement}
procedure SetParticipationPartieAuClassement(nroReferencePartie : SInt32; flag : boolean);
function PartieParticipeAuClassement(nroReferencePartie : SInt32) : boolean;
procedure SetAucunePartieDeLaListeNeParticipeAuClassement;


{parties de la liste non sauvegardees}
procedure SetPartieDansListeDoitEtreSauvegardee(nroReferencePartie : SInt32; flag : boolean);
function PartieDansListeDoitEtreSauvegardee(nroReferencePartie : SInt32) : boolean;
function NbPartiesDevantEtreSaugardeesDansLaListe : SInt32;
function NbPartiesActivesDevantEtreSauvegardeesDansLaListe : SInt32;
procedure RecalculateNbPartiesASauvegarderDansLaListe;
procedure SetAucunePartieDeLaListeNeDoitEtreSauvegardee;


{parties douteuses lors de l'import}
procedure SetPartieDansListeEstDouteuse(nroReferencePartie : SInt32; flag : boolean);
function PartieDansListeEstDouteuse(nroReferencePartie : SInt32) : boolean;
function NbPartiesDouteusesDansLaListe : SInt32;
procedure RecalculateNbPartiesDouteusesDansLaListe;
procedure SetAucunePartieDeLaListeNEstDouteuse;


{parties dont le score doit sans doute etre recalculé}
procedure SelectionnerPartiesOuScoreTheoriqueEgalScoreReel;
function PartieAvecScoresTheoriqueEtReelEgaux(numeroDansLaListe,numeroReference : SInt32; var score : SInt32) : boolean;


{parties qui viennent de rejoindre la liste par interversion}
function PartieDansLaListeIdentiqueAPartieCourante(nroReferencePartie, numeroDuCoup : SInt32; autreCoupQuatreDiagonal : boolean) : boolean;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Timer, FixMath, OSUtils, Sound, ControlDefinitions, GestaltEqu, MacWindows, QuickdrawText
    , Appearance
{$IFC NOT(USE_PRELINK)}
    , UnitSaisiePartie, UnitAccesNouveauFormat, SNMenus, UnitEntreesSortiesListe, UnitMoulinette, UnitServicesDialogs, UnitTHOR_PAR
    , MyQuickDraw, UnitStrategie, UnitInterversions, UnitJeu, UnitNormalisation, UnitUtilitaires, UnitJaponais, UnitArbreDeJeuCourant
    , UnitPositionEtTrait, UnitMenus, UnitLongintScroller, UnitCarbonisation, UnitNouveauFormat, UnitStatistiques, UnitRapport, MyStrings
    , UnitDialog, UnitScannerUtils, UnitCouleur, UnitFenetres, UnitCriteres, UnitTriListe, UnitPackedThorGame, UnitGestionDuTemps
    , UnitGeometrie, MyAntialiasing, MyMathUtils, MyFonts, SNEvents, UnitScannerOthellistique, UnitAffichagePlateau, UnitServicesMemoire
    , UnitActions ;
{$ELSEC}
    ;
    {$I prelink/Liste.lk}
{$ENDC}


{END_USE_CLAUSE}





const kPetiteCheckBoxID = 187;
      kPetiteCheckBoxRemplieID = 186;

      hauteurPiedDePageListe = 15;

      gAutorisationChargerLaBaseSansPasserParLeDialogue : boolean = true;

var gAutorisationCalculsLongsSurListe : boolean;
    gInclurePartiesAvecOrdinateursDansListe : boolean;
    gLigneOuLOnVoudraitQueSoitLaPartieHilitee : SInt32;
    gPiedDePageFenetreListeRect : rect;
    gOldClipRgn : record
                  niveauRecursion : SInt32;
                  regions : array[0..10] of RgnHandle;
                end;


procedure InitUnitListe;
begin
  SetAutorisationCalculsLongsSurListe(true);
  SetInclurePartiesAvecOrdinateursDansListe(true);
  gOldClipRgn.niveauRecursion := 0;
end;


procedure LibereMemoireUnitListe;
begin
end;


{on vide la liste des parties}
procedure ResetListeDeParties;
begin

  SetAucunePartieDeLaListeNeDoitEtreSauvegardee;
  SetAucunePartieDeLaListeNEstDouteuse;
  SetAucunePartieDetruiteDansLaListe;
  SetAucunePartieDeLaListeNeParticipeAuClassement;
  DeselectionnerToutesLesPartiesDansLaListe;
  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;

  nbPartiesActives := 0;
  nbPartiesChargees := 0;
  nbreCoupsApresLecture := 0;

  with infosListeParties do
    begin
      partieHilitee := 1;
      dernierNroReferenceHilitee := 0;
      clicHilite := 0;
      justificationPasDePartie := -1;
    end;

  IncrementeMagicCookieDemandeCalculsBase;
  ConstruitTableNumeroReference(false,false);
  SetPartieHiliteeEtAjusteAscenseurListe(1);

  EcritListeParties(false,'ResetListeDeParties');
  EcritStatistiques(false);
end;



procedure SetInclurePartiesAvecOrdinateursDansListe(flag : boolean);
begin
  gInclurePartiesAvecOrdinateursDansListe := flag;
end;

function InclurePartiesAvecOrdinateursDansListe : boolean;
begin
  InclurePartiesAvecOrdinateursDansListe := gInclurePartiesAvecOrdinateursDansListe;
end;


procedure DessineCheckBoxInclurePartiesAvecOrdinateurs;
var titre : String255;
    initialValue : SInt32;
    autoToggle : boolean;
    pt : Point;
begin

  titre := ReadStringFromRessource(TextesListeID,16); {'Inclure les parties d''ordinateurs'}
  if InclurePartiesAvecOrdinateursDansListe
    then initialValue := 1
    else initialValue := 0;
  autoToggle := true;

  pt := gPiedDePageFenetreListeRect.topLeft;
  inc(pt.v);
  if (initialValue = 1)
    then DessineBoutonPicture(wListePtr,kPetiteCheckBoxRemplieID,pt,infosListeParties.inclureOrdinateurRect)
    else DessineBoutonPicture(wListePtr,kPetiteCheckBoxID,pt,infosListeParties.inclureOrdinateurRect);

  Moveto(infosListeParties.inclureOrdinateurRect.right+1,infosListeParties.inclureOrdinateurRect.bottom-4);
  MyDrawString(titre);

  with infosListeParties.inclureOrdinateurRect do
    right := right + MyStringWidth(titre);
end;


procedure DessinePiedDePageFenetreListe;
var piedDePageRect : rect;
    s, s2, nombre : String255;
    aux : SInt32;
begin
  with gPiedDePageFenetreListeRect do
    piedDePageRect := MakeRect(-2,top,GetWindowPortRect(wListePtr).right-15,bottom);

  {dessin de la partie grisee}
  MyEraseRect(piedDePageRect);
  MyEraseRectWithColor(piedDePageRect,OrangeCmd,blackPattern,'');
  EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);

  RGBForeColor(gPurGrisClair);
	FillRect(piedDePageRect,blackPattern);

	RGBForeColor(gPurGris);
	Moveto(0,piedDePageRect.top);
	Lineto(piedDePageRect.right,piedDePageRect.top);

	RGBForeColor(gPurNoir);

  {dessin de la boite à cocher pour les ordinateurs}
  DessineCheckBoxInclurePartiesAvecOrdinateurs;


  if (nbPartiesActives > 0) then
    begin

      {ecriture du nombre de parties actives dans la liste}

      if (nbPartiesActives >= 2)
        then s := ReadStringFromRessource(TextesListeID,17)    {  ^0 parties  }
        else s := ReadStringFromRessource(TextesListeID,18);   {  ^0 partie   }


      nombre := IntToStr(nbPartiesActives);
      s := ParamStr(s,SeparerLesChiffresParTrois(nombre),'','','');


      {ecriture eventuelle du nombre de parties non sauvegardees}

      if (NbPartiesDevantEtreSaugardeesDansLaListe > 0) then
        begin
          s2 := ReadStringFromRessource(TextesListeID,19);    {  ^0 non sauvegardees  }
          aux := NbPartiesActivesDevantEtreSauvegardeesDansLaListe;
          if (aux > 0) then
            begin
              nombre := IntToStr(aux);
              s := s + ' ' + ParamStr(s2,SeparerLesChiffresParTrois(nombre),'','','');
            end;
        end;


      TextFace(normal);
      Moveto(piedDePageRect.right - MyStringWidth(s) - 3,piedDePageRect.bottom - 4);
      MyDrawString(s);
    end;
end;


procedure SetAutorisationCalculsLongsSurListe(flag : boolean);
begin
  gAutorisationCalculsLongsSurListe := flag;
end;


function AutorisationCalculsLongsSurListe : boolean;
begin
  AutorisationCalculsLongsSurListe := gAutorisationCalculsLongsSurListe;
end;


{partie60 doit etre une partie d'othello legale}
procedure ForEachPositionInGameDo(partie60 : PackedThorGame ; DoWhat : MilieuDePartieProc; var result : SInt32);
var position : plateauOthello;
    frontiere : InfoFront;
    jouables : plBool;
    nbNoir,nbBlanc,trait : SInt32;
    i,coup,coupSuivant,longueurMax : SInt16;
    ok : boolean;
    partie255 : String255;
begin

  OthellierEtPionsDeDepart(position,nbNoir,nbBlanc);
  trait := pionNoir;
  CarteFrontiere(position,frontiere);
  CarteJouable(position,jouables);

  longueurMax := Min(GET_LENGTH_OF_PACKED_GAME(partie60),60);
  for i := 1 to longueurMax do
    begin
      DoWhat(position,jouables,frontiere,nbNoir,nbBlanc,trait,result);

      coup := GET_NTH_MOVE_OF_PACKED_GAME(partie60, i,'ForEachPositionInGameDo(1)');
      if (coup < 11) or (coup > 88) then
         begin
           SysBeep(0);
           WritelnDansRapport('coup impensable dans ForEachPositionInGameDo !!');
           TraductionThorEnAlphanumerique(partie60,partie255);
           WritelnDansRapport('partie à problème = '+partie255);
           exit;  {coup impensable}
         end;

      if ModifPlat(coup,trait,position,jouables,nbBlanc,nbNoir,frontiere)
         then
           begin
             if (i >= 60) then
               begin
                 {position terminale}
                 DoWhat(position,jouables,frontiere,nbNoir,nbBlanc,pionVide,result);
                 exit;
	             end;

             trait := -trait;

             if (i >= longueurMax) then
               begin
                 exit;
               end;

             coupSuivant := GET_NTH_MOVE_OF_PACKED_GAME(partie60, (i+1),'ForEachPositionInGameDo(2)');
             ok := (coupSuivant >= 11) and (coupSuivant <= 88);
             if not(ok) then
               begin
                 {position terminale prématurée !}
                 exit;
	             end;

             ok := PeutJouerIci(trait,coupSuivant,position);
            {if not(ok) then
               begin
                 WritelnPositionEtTraitDansRapport(position,trait);
                 WritelnNumDansRapport('not(peutJouerIci) dans ForEachPositionInGameDo !! coupSuivant = ',coupSuivant);
                 TraductionThorEnAlphanumerique(partie60,partie255);
                 WritelnDansRapport('partie à problème = '+partie255);
                 WritelnDansRapport('');
               end;}

             if not(ok) and DoitPasser(trait,position,jouables) then
               begin
                 trait := -trait;
                 if DoitPasser(trait,position,jouables) then
                   begin
                     {position terminale}
                     DoWhat(position,jouables,frontiere,nbNoir,nbBlanc,pionVide,result);
                     exit;
                   end;
               end;
           end
         else
           begin
             WritelnDansRapport('not(ModifPlat) dans ForEachPositionInGameDo !!');
             TraductionThorEnAlphanumerique(partie60,partie255);
             WritelnDansRapport('partie à problème = '+partie255);
             if not(ModifPlat(coup,-trait,position,jouables,nbBlanc,nbNoir,frontiere)) then
               begin
                 WritelnDansRapport('coup impossible dans ForEachPositionInGameDo !!');
                 TraductionThorEnAlphanumerique(partie60,partie255);
                 WritelnDansRapport('partie à problème = '+partie255);
                 exit;  {coup impossible !!}
               end;
           end;
    end;

  if DoitPasserPlatSeulement(trait,position) then
    begin
      trait := -trait;
      if DoitPasserPlatSeulement(trait,position) then
        begin
          exit;  {game over!}
          DoWhat(position,jouables,frontiere,nbNoir,nbBlanc,pionVide,result);
        end;
    end;

end;


procedure ForEachGameInListDo(FiltreNumRef : FiltreNumRefProc; FiltreGame : FiltreGameProc; DoWhat : GameInListProc; var result : SInt32);
var nroRefPartie,t : SInt32;
    partie60 : PackedThorGame;
begin
  for t := 1 to nbPartiesActives do
    begin
      nroRefPartie := tableNumeroReference^^[t];
      if FiltreNumRef(t,nroRefPartie,result) then
        begin
          ExtraitPartieTableStockageParties(nroRefPartie,partie60);
          if FiltreGame(partie60,nroRefPartie,result) then
            DoWhat(partie60,nroRefPartie,result);
        end;
    end;
end;


procedure ForEachGameInSortedListDo(FiltreNumRef : FiltreNumRefProc; FiltreGame : FiltreGameProc; DoWhat : GameInListProc; var result : SInt32);
var nroRefPartie,t,nroDansLaListe : SInt32;
    partie60 : PackedThorGame;
begin
  nroDansLaListe := 0;
  for t := 1 to nbPartiesChargees do
    begin
      nroRefPartie := tableTriListe^^[t];
      if PartieEstActive(nroRefPartie) then
        begin
          inc(nroDansLaListe);
          if FiltreNumRef(nroDansLaListe,nroRefPartie,result) then
            begin
              ExtraitPartieTableStockageParties(nroRefPartie,partie60);
              if FiltreGame(partie60,nroRefPartie,result) then
                DoWhat(partie60,nroRefPartie,result);
            end;
        end;
    end;
end;


function NumberOfGamesWithThisReferenceFilter(FiltreNumRef : FiltreNumRefProc; var result : SInt32) : SInt32;
var t,somme,nroRefPartie : SInt32;
begin
  somme := 0;
  for t := 1 to nbPartiesActives do
    begin
      nroRefPartie := tableNumeroReference^^[t];
      if FiltreNumRef(t,nroRefPartie,result) then inc(somme);
    end;
  NumberOfGamesWithThisReferenceFilter := somme;
end;


function bidFiltreNumRefProc(numeroDansLaListe,numeroReference : SInt32; var result : SInt32) : boolean;
begin
  {$UNUSED numeroDansLaListe,numeroReference,result}
  bidFiltreNumRefProc := true;
end;


function bidFiltreGameProc(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var result : SInt32) : boolean;
begin
  {$UNUSED partie60,numeroRefPartie,result}
  bidFiltreGameProc := true;
end;


procedure SetValeursStandardRubanListe(nbColonnes : SInt16);
const margeNomDesJoueur = 0;
var largeurDistribution : SInt32;
    largeurTournoi : SInt32;
    largeurJoueur : SInt32;
    largeurCoup : SInt32;
begin
  if listeEtroiteEtNomsCourts
    then
      begin
        largeurDistribution := 50;
        largeurTournoi := 97;
        largeurJoueur := 71;
        largeurCoup := 30;
      end
    else
      begin
        largeurDistribution := 50;
        largeurTournoi := 152;
        largeurJoueur := 110;
        largeurCoup := 30;
      end;

  case nbColonnes of
    kAvecAffichageDistribution :
      begin
        positionDistribution := 2;
        positionTournoi      := positionDistribution + largeurDistribution;
        positionNoir         := positionTournoi + largeurTournoi;
        positionBlanc        := positionNoir + largeurJoueur + margeNomDesJoueur;
        positionCoup         := positionBlanc + largeurJoueur + margeNomDesJoueur;
        positionScoreReel    := positionCoup + largeurCoup ;
      end ;
    kAvecAffichageTournois :
      begin
        positionTournoi      := 2;
        positionDistribution := positionTournoi - largeurDistribution;
        positionNoir         := positionTournoi + largeurTournoi;
        positionBlanc        := positionNoir + largeurJoueur + margeNomDesJoueur;
        positionCoup         := positionBlanc + largeurJoueur + margeNomDesJoueur;
        positionScoreReel    := positionCoup + largeurCoup ;
      end ;
    kAvecAffichageSeulementDesJoueurs :
      begin
        positionNoir         := 2;
        positionTournoi      := positionNoir - largeurTournoi;
        positionDistribution := positionTournoi - largeurDistribution;
        positionBlanc        := positionNoir + largeurJoueur + margeNomDesJoueur;
        positionCoup         := positionBlanc + largeurJoueur + margeNomDesJoueur;
        positionScoreReel    := positionCoup + largeurCoup ;
      end;
  end;
end;


procedure EcritRubanListe(avecDessinDesCriteres : boolean);
var yPosition,i : SInt16;
    miseEnValeurTypographique : StyleParameter;
    oldPort : grafPtr;
    unRect,rubanRect : rect;
    s : String255;
    couleurAffichageSousCritere : SInt32;
begin
  if windowListeOpen and (wListePtr <> NIL) then
    begin

      couleurAffichageSousCritere := BlueColor;
      GetPort(oldPort);
      SetPortByWindow(wListePtr);

      RGBForeColor(EclaircirCouleurDeCetteQuantite(CouleurCmdToRGBColor(NoirCmd),35000));
      Moveto(0,hauteurRubanListe-1);
      Lineto(GetWindowPortRect(wListePtr).right,hauteurRubanListe-1);
      ForeColor(BlackColor);

      rubanRect := MakeRect(-2,-2,GetWindowPortRect(wListePtr).right+2,hauteurRubanListe-1);
      if gCassioUseQuartzAntialiasing then
        begin
          MyEraseRect(rubanRect);
          MyEraseRectWithColor(rubanRect,OrangeCmd,blackPattern,'');
          {DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));}
          EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
        end;

      if DrawThemeWindowListViewHeader(rubanRect,kThemeStateActive) = NoErr then DoNothing;

      SetValeursStandardRubanListe(nbColonnesFenetreListe);


      if gVersionJaponaiseDeCassio and gHasJapaneseScript
        then
          begin
            TextFont(gCassioApplicationFont);
            TextSize(gCassioSmallFontSize);
		        {TextSize(gCassioNormalFontSize);}
		        TextMode(srcOr);
		        miseEnValeurTypographique := bold;
          end
        else
          begin
		        TextFont(gCassioApplicationFont);
		        TextSize(gCassioSmallFontSize);
		        TextMode(srcOr);
		        {miseEnValeurTypographique := underline;}
		        miseEnValeurTypographique := bold + italic;
		      end;

        yposition := hauteurRubanListe-4;

        s := ReadStringFromRessource(TextesListeID,15);
        if gGenreDeTriListe = TriParDistribution
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        SetRect(RubanDistributionRect,positionDistribution-1,yposition-9,positionDistribution+2+MyStringWidth(s),yposition+2);

        s := ReadStringFromRessource(TextesListeID,6);
        if gGenreDeTriListe = TriParDate
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        SetRect(RubanTournoiRect,positionTournoi-1,yposition-9,positionTournoi+3+MyStringWidth(s),yposition+2);

        s := ReadStringFromRessource(TextesListeID,7);
        if gGenreDeTriListe = TriParJoueurNoir
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        SetRect(RubanNoirsRect,positionNoir-1,yposition-9,positionNoir+2+MyStringWidth(s),yposition+2);

        s := ReadStringFromRessource(TextesListeID,8);
        if gGenreDeTriListe = TriParJoueurBlanc
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        SetRect(RubanBlancsRect,positionBlanc-1,yposition-9,positionBlanc+2+MyStringWidth(s),yposition+2);

        SetRect(RubanCoupRect,positionCoup-1,yposition-9,positionCoup+10,yposition+2);
        SetRect(RubanTheoriqueRect,positionCoup+13,yposition-9,positionCoup+28,yposition+2);
        SetRect(RubanReelRect,positionScoreReel,yposition-9,positionScoreReel+28,yposition+2);
        SetRect(RubanSousCritActifs,positionScoreReel+32,yposition-8,positionScoreReel+41,yposition+1);

        {EssaieSetPortWindowPlateau;
        s := ReadStringFromRessource(TextesListeID,6);
        WriteNumAt(s+' => dif = ',RubanTournoiRect.right-RubanTournoiRect.left-MyStringWidth(s),10,10);
        s := ReadStringFromRessource(TextesListeID,7);
        WriteNumAt(s+' => dif = ',RubanNoirsRect.right-RubanNoirsRect.left-MyStringWidth(s),10,20);
        s := ReadStringFromRessource(TextesListeID,8);
        WriteNumAt(s+' => dif = ',RubanBlancsRect.right-RubanBlancsRect.left-MyStringWidth(s),10,30);
        s := ReadStringFromRessource(TextesListeID,9);
        WriteNumAt(s+' => dif = ',RubanTheoriqueRect.right-RubanTheoriqueRect.left-MyStringWidth(s),10,40);
        s := ReadStringFromRessource(TextesListeID,10);
        WriteNumAt(s+' => dif = ',RubanReelRect.right-RubanReelRect.left-MyStringWidth(s),10,50);
        SysBeep(0);
        SetPortByWindow(wListePtr);
        AttendFrappeClavier;
        }


        Moveto(RubanDistributionRect.left+2,yposition);
        if gGenreDeTriListe = TriParDistribution
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,15);
        if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[DistributionRubanBox]) <> 0)
          then ForeColor(couleurAffichageSousCritere)
          else ForeColor(BlackColor);
        MyDrawString(s);


        Moveto(RubanTournoiRect.left+2,yposition);
        if gGenreDeTriListe = TriParDate
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,6);
        if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[TournoiRubanBox]) <> 0)
          then ForeColor(couleurAffichageSousCritere)
          else ForeColor(BlackColor);
        MyDrawString(s);


        Moveto(RubanNoirsRect.left+2,yposition);
        if gGenreDeTriListe = TriParJoueurNoir
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,7);
        if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[JoueurNoirRubanBox]) <> 0)
          then ForeColor(couleurAffichageSousCritere)
          else ForeColor(BlackColor);
        MyDrawString(s);


        Moveto(RubanBlancsRect.left+2,yposition);
        if gGenreDeTriListe = TriParJoueurBlanc
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,8);
        if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[JoueurBlancRubanBox]) <> 0)
          then ForeColor(couleurAffichageSousCritere)
          else ForeColor(BlackColor);
        MyDrawString(s);


        Moveto(RubanCoupRect.left+2,yposition);
        if gGenreDeTriListe = TriParOuverture
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        TextFont(GenevaID);
        ForeColor(BlackColor);
        MyDrawString('…  ');


        TextFont(gCassioApplicationFont);
        Moveto(RubanTheoriqueRect.left+1,yposition);
        if gGenreDeTriListe = TriParScoreTheorique
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,9);
        MyDrawString(s+'  ');


        Moveto(RubanReelRect.left+1,yposition);
        if gGenreDeTriListe = TriParScoreReel
          then TextFace(miseEnValeurTypographique)
          else TextFace(normal);
        s := ReadStringFromRessource(TextesListeID,10);
        MyDrawString(s+'  ');

        ForeColor(BlackColor);


        {dessin du petit losange}
        if sousSelectionActive
          then
            begin
              ForeColor(couleurAffichageSousCritere);
              Moveto(RubanSousCritActifs.left+4,RubanSousCritActifs.top+1);
              Line(3,3); Line(-3,3); Line(-3,-3); Line(3,-3);
              Line(0,1); Line(2,2); Line(-2,2); Line(-2,-2); Line(2,-2);
              Line(0,3); Line(-1,-1); Line(3,0);
            end
          else
            begin
              {MyEraseRect(RubanSousCritActifs);}
              Moveto(RubanSousCritActifs.left+4,RubanSousCritActifs.top+1);
              Line(3,3); Line(-3,3); Line(-3,-3); Line(3,-3);
              {
              Line(0,1); Line(2,2); Line(-2,2); Line(-2,-2); Line(2,-2);
              Line(0,3); Line(-1,-1); Line(3,0);
              }
            end;
        ForeColor(BlackColor);



        if avecDessinDesCriteres then
          if sousSelectionActive
            then
              begin
                for i := TournoiRubanBox to DistributionRubanBox do
	                begin
	                  if SousCriteresRuban[i] <> NIL then
	                    begin


	                      unRect := TEGetViewRect(SousCriteresRuban[i]);
	                      InsetRect(unRect,-1,-1);
	                      ForeColor(couleurAffichageSousCritere);
	                      if i = BoiteDeSousCritereActive
	                        then
	                          begin
	                            MyEraseRect(unRect);
	                            MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
	                            PenPat(blackPattern);
	                            FrameRect(unRect);
	                          end;
	                      {WritelnNumDansRapport('i = ',i);
	                      WritelnNumDansRapport('unRect.top = ',unRect.top);
	                      WritelnNumDansRapport('unRect.bottom = ',unRect.bottom);}
	                      {FillRect(unrect,blackPattern);}
	                      PenPat(blackPattern);

	                      {AttendFrappeClavier;}
	                      if (TEGetTextLength(SousCriteresRuban[i]) <> 0) and (i = BoiteDeSousCritereActive)
	                        then
	                          begin
	                            InsetRect(unRect,1,1);
	                            TEupdate(unRect,SousCriteresRuban[i]);
	                          end
	                        else
	                          begin
	                            (*
	                            InsetRect(unRect,1,1);
	                            MyEraseRect(unRect);
	                            *)
	                          end;
	                      ForeColor(BlackColor);

	                    end;
	                end;
	            end;

      RGBForeColor(EclaircirCouleurDeCetteQuantite(CouleurCmdToRGBColor(NoirCmd),35000));
      Moveto(0,hauteurRubanListe-1);
      Lineto(GetWindowPortRect(wListePtr).right,hauteurRubanListe-1);
      ForeColor(BlackColor);

      if gCassioUseQuartzAntialiasing then
        EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);

      SetPort(oldPort);
    end;
end;


procedure MetCriteresDansRuban;
var s,crit : String255;
    i : SInt16;
    oldport : grafPtr;
begin
  if windowListeOpen and (CriteresSuplementaires <> NIL) then
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);

      crit := CriteresSuplementaires^^.CriteresTournoi;
      i := Pos('√',crit)-1;
      s := TPCopy(crit,1,i);
      if i > 0
        then TESetText(@s[1],i,SousCriteresRuban[TournoiRubanBox])
        else TESetText(@s,0,SousCriteresRuban[TournoiRubanBox]);

      crit := CriteresSuplementaires^^.CriteresNoir;
      i := Pos('√',crit)-1;
      s := TPCopy(crit,1,i);
      if i > 0
        then TESetText(@s[1],i,SousCriteresRuban[JoueurNoirRubanBox])
        else TESetText(@s,0,SousCriteresRuban[JoueurNoirRubanBox]);

      crit := CriteresSuplementaires^^.CriteresBlanc;
      i := Pos('√',crit)-1;
      s := TPCopy(crit,1,i);
      if i > 0
        then TESetText(@s[1],i,SousCriteresRuban[JoueurBlancRubanBox])
        else TESetText(@s,0,SousCriteresRuban[JoueurBlancRubanBox]);

      crit := CriteresSuplementaires^^.CriteresDistribution;
      i := Pos('√',crit)-1;
      s := TPCopy(crit,1,i);
      if i > 0
        then TESetText(@s[1],i,SousCriteresRuban[DistributionRubanBox])
        else TESetText(@s,0,SousCriteresRuban[DistributionRubanBox]);

      TESelView(SousCriteresRuban[TournoiRubanBox]);
      TESelView(SousCriteresRuban[JoueurNoirRubanBox]);
      TESelView(SousCriteresRuban[JoueurBlancRubanBox]);
      TESelView(SousCriteresRuban[DistributionRubanBox]);
      InvalRect(TEGetViewRect(SousCriteresRuban[TournoiRubanBox]));
      InvalRect(TEGetViewRect(SousCriteresRuban[JoueurNoirRubanBox]));
      InvalRect(TEGetViewRect(SousCriteresRuban[JoueurBlancRubanBox]));
      InvalRect(TEGetViewRect(SousCriteresRuban[DistributionRubanBox]));
      TEDeactivate(SousCriteresRuban[TournoiRubanBox]);
      TEDeactivate(SousCriteresRuban[JoueurNoirRubanBox]);
      TEDeactivate(SousCriteresRuban[JoueurBlancRubanBox]);
      TEDeactivate(SousCriteresRuban[DistributionRubanBox]);
      BoiteDeSousCritereActive := 0;
      CriteresRubanModifies := false;
      SetPort(oldport);
    end;
end;


procedure CalculEmplacementCriteresListe;
var viewRect,destRect : rect;
begin
  if windowListeOpen then
    begin
      EcritRubanListe(false);

      SetRect(viewRect,RubanTournoiRect.right,1,positionNoir,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      if gCassioUseQuartzAntialiasing then OffSetRect(destRect,0,1);
      TESetDestRect(SousCriteresRuban[TournoiRubanBox],destRect);
      TESetViewRect(SousCriteresRuban[TournoiRubanBox],viewRect);

      SetRect(viewRect,RubanNoirsRect.right,1,positionBlanc,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      if gCassioUseQuartzAntialiasing then OffSetRect(destRect,0,1);
      TESetDestRect(SousCriteresRuban[JoueurNoirRubanBox],destRect);
      TESetViewRect(SousCriteresRuban[JoueurNoirRubanBox],viewRect);

      SetRect(viewRect,RubanBlancsRect.right,1,RubanCoupRect.left-1,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      if gCassioUseQuartzAntialiasing then OffSetRect(destRect,0,1);
      TESetDestRect(SousCriteresRuban[JoueurBlancRubanBox],destRect);
      TESetViewRect(SousCriteresRuban[JoueurBlancRubanBox],viewRect);

      SetRect(viewRect,RubanDistributionRect.right,1,positionTournoi,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      if gCassioUseQuartzAntialiasing then OffSetRect(destRect,0,1);
      TESetDestRect(SousCriteresRuban[DistributionRubanBox],destRect);
      TESetViewRect(SousCriteresRuban[DistributionRubanBox],viewRect);

      InvalRect(TEGetDestRect(SousCriteresRuban[TournoiRubanBox]));
      InvalRect(TEGetDestRect(SousCriteresRuban[JoueurNoirRubanBox]));
      InvalRect(TEGetDestRect(SousCriteresRuban[JoueurBlancRubanBox]));
      InvalRect(TEGetDestRect(SousCriteresRuban[DistributionRubanBox]));
      EcritRubanListe(true);
    end;
end;

procedure OuvreControlesListe;
var oldport : grafPtr;
    refcon : SInt32;
    ascenseurRect : rect;
    viewRect,destRect : rect;
begin
  if windowListeOpen and (wListePtr <> NIL) then
    with infosListeParties do
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);

      SetRect(ascenseurRect,GetWindowPortRect(wListePtr).right-15,GetWindowPortRect(wListePtr).top-1+hauteurRubanListe,
                            GetWindowPortRect(wListePtr).right+1,GetWindowPortRect(wListePtr).bottom-14);
      if gIsRunningUnderMacOSX then inc(ascenseurRect.top);

      nbreLignesFntreListe := CalculeNbreLignesVisiblesFntreListe;
      refcon := 0;
      ascenseurListe := NIL;
      ascenseurListe := NewControl(wListePtr,ascenseurRect,StringToStr255(''),true,1,1,1,scrollBarProc,refcon);
      if ascenseurListe <> NIL then
        if IsWindowHilited(wListePtr)
          then MontrerAscenseurListe
          else CacherAscenseurListe;

      longintMinimum := 1;
      longintMaximum := nbPartiesActives-nbreLignesFntreListe+1;
      if longintMaximum <= longintMinimum then longintMaximum := longintMinimum;
      longintValue := 1;


      EcritRubanListe(false);
      TextFace(normal); TextFont(gCassioApplicationFont); TextSize(gCassioSmallFontSize);
      SousCriteresRuban[TournoiRubanBox]      := NIL;
      SousCriteresRuban[JoueurNoirRubanBox]   := NIL;
      SousCriteresRuban[JoueurBlancRubanBox]  := NIL;
      SousCriteresRuban[DistributionRubanBox] := NIL;

      SetRect(viewRect,RubanTournoiRect.right,1,positionNoir,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      SousCriteresRuban[TournoiRubanBox] := TENew(destRect,viewRect);

      SetRect(viewRect,RubanNoirsRect.right,1,positionBlanc,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      SousCriteresRuban[JoueurNoirRubanBox] := TENew(destRect,viewRect);

      SetRect(viewRect,RubanBlancsRect.right,1,RubanCoupRect.left-1,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      SousCriteresRuban[JoueurBlancRubanBox] := TENew(destRect,viewRect);

      SetRect(viewRect,RubanDistributionRect.right,1,positionTournoi,hauteurRubanListe-2);
      destRect := viewRect; destRect.right := 5000;
      SousCriteresRuban[DistributionRubanBox] := TENew(destRect,viewRect);

      {TEAutoView(true,SousCriteresRuban[TournoiRubanBox]);
      TEAutoView(true,SousCriteresRuban[JoueurNoirRubanBox]);
      TEAutoView(true,SousCriteresRuban[JoueurBlancRubanBox]);
      TEAutoView(true,SousCriteresRuban[DistributionRubanBox]);}
      CalculEmplacementCriteresListe;
      MetCriteresDansRuban;


      gPiedDePageFenetreListeRect := MakeRect(10,GetWindowPortRect(wListePtr).bottom-hauteurPiedDePageListe,100,GetWindowPortRect(wListePtr).bottom);
      DessinePiedDePageFenetreListe;

      SetPort(oldport);
    end;
end;


procedure CloseControlesListe;
var i : SInt16;
begin
  if windowListeOpen and (wListePtr <> NIL) then
    with infosListeParties do
    begin

      if ascenseurListe <> NIL then
        begin
          DisposeControl(ascenseurListe);
          ascenseurListe := NIL;
        end;

      for i := TournoiRubanBox to DistributionRubanBox do
        if SousCriteresRuban[i] <> NIL then
          begin
            TEDispose(SousCriteresRuban[i]);
            SousCriteresRuban[i] := NIL;
          end;

    end;
end;

procedure DoActivateFenetreListe(activation : boolean);
var growRect : rect;
begin
  if infosListeParties.ascenseurListe <> NIL then
     if activation
       then
         begin
           SetPortByWindow(wListePtr);
           MontrerAscenseurListe;

           growRect := GetWindowPortRect(wListePtr);
           growRect.left := growRect.right-15;
           growRect.bottom := growRect.bottom-15;
           growRect.top := growRect.top+hauteurRubanListe;
           InvalRect(growrect);
         end
       else
         begin
           SetPortByWindow(wListePtr);
           CacherAscenseurListe;

           DessineBoiteAscenseurDroite(wListePtr);
           if SousCriteresRuban[TournoiRubanBox]      <> NIL then TEDeactivate(SousCriteresRuban[TournoiRubanBox]);
           if SousCriteresRuban[JoueurNoirRubanBox]   <> NIL then TEDeactivate(SousCriteresRuban[JoueurNoirRubanBox]);
           if SousCriteresRuban[JoueurBlancRubanBox]  <> NIL then TEDeactivate(SousCriteresRuban[JoueurBlancRubanBox]);
           if SousCriteresRuban[DistributionRubanBox] <> NIL then TEDeactivate(SousCriteresRuban[DistributionRubanBox]);
         end;
end;




procedure MontrerAscenseurListe;
var oldPort : grafPtr;
begin
  if windowListeOpen and (infosListeParties.ascenseurListe <> NIL) then
    begin
		  GetPort(oldPort);
		  SetPortByWindow(wListePtr);

		  if not(gIsRunningUnderMacOSX)
         then
           begin
             if (SetControlVisibility(infosListeParties.ascenseurListe,true,true) = NoErr) then DoNothing;
             ShowControl(infosListeParties.ascenseurListe);
             DrawControls(wListePtr);
           end
         else
           begin

             if SetControlVisibility(infosListeParties.ascenseurListe,true,true) = NoErr then DoNothing;

             HiliteControl(infosListeParties.ascenseurListe,0);
             HiliteControl(infosListeParties.ascenseurListe,kControlIndicatorPart);
             DrawControls(wListePtr);
           end;

		  SetPort(oldPort);
    end;
end;

procedure CacherAscenseurListe;
var oldPort : grafPtr;
begin
  if windowListeOpen and (infosListeParties.ascenseurListe <> NIL) then
    begin
		  GetPort(oldPort);
		  SetPortByWindow(wListePtr);

		  if not(gIsRunningUnderMacOSX)
         then HideControl(infosListeParties.ascenseurListe)
         else
           begin
             HiliteControl(infosListeParties.ascenseurListe,255);
             {if SetControlVisibility(infosListeParties.ascenseurListe,false,false) = NoErr then DoNothing;}
             DrawControls(wListePtr);
           end;

		  SetPort(oldPort);
    end;
end;

procedure DoChangerOrdreListe;
var i,etat : SInt32;
begin
  with infosListeParties do
    begin
      OrdreDuTriRenverse := not(OrdreDuTriRenverse);
      for i := 0 to 65 do
        begin
  	      etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(i);
  	      if (etat <> PasDePartieActive) and (etat <> 1) then
  	        if ListePartiesEstGardeeDansLeCache(i,etat) then
  	          InvalidateNombrePartiesActivesDansLeCache(i);
	      end;

	  if (nbPartiesActives = nbPartiesChargees) and (partieHilitee = 1) then
	    SetPartieHilitee(nbPartiesActives);  {pour qu'apres le renversement on reste en tete de liste}
	  LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
  end;
end;


function GetPartieEnAlphaDapresListe(nroReference,jusquaQuelCoup : SInt32) : String255;
var s60 : PackedThorGame;
    result : String255;
    autreCoupQuatreDansPartieCourante : boolean;
    ouvertureDiagonale : boolean;
    premierCoup : SInt16;
begin
  ExtraitPartieTableStockageParties(nroReference,s60);
  ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
  ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartieCourante);
  TransposePartiePourOrientation(s60,autreCoupQuatreDansPartieCourante and ouvertureDiagonale,4,60);
  TraductionThorEnAlphanumerique(s60,result);
  GetPartieEnAlphaDapresListe := TPCopy(result,1,2*jusquaQuelCoup);
end;


procedure ConstruitPositionEtCoupDapresListe(nroPartie : SInt32; var positionEtCoupStr : String255);
var t,nroReference : SInt32;
    s60 : PackedThorGame;
    jeu : plateauOthello;
    good,autreCoupQuatreDiag : boolean;
    ouvertureDiagonale : boolean;
    coulTrait,coup : SInt16;
    nbrecoupsjoues : SInt16;
begin
  positionEtCoupStr := '';
  if (1 <= nroPartie) and (nroPartie <= nbPartiesActives) then
    begin
      nroReference := tableNumeroReference^^[nroPartie];
      ExtraitPartieTableStockageParties(nroReference,s60);
      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);

      autreCoupQuatreDiag := PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6;
      TransposePartiePourOrientation(s60,autreCoupQuatreDiag and ouvertureDiagonale,4,60);

      MemoryFillChar(@Jeu,sizeof(jeu),chr(0));
      for t := 0 to 99 do
        if interdit[t] then jeu[t] := PionInterdit;
      jeu[54] := pionNoir;
      jeu[45] := pionNoir;
      jeu[44] := pionBlanc;
      jeu[55] := pionBlanc;
      coulTrait := pionNoir;
      good := true;

      for t := 1 to 64 do
        case jeu[othellier[t]] of
          pionNoir  : positionEtCoupStr := Concat(positionEtCoupStr,'X');
          pionBlanc : positionEtCoupStr := Concat(positionEtCoupStr,'O');
          otherwise   positionEtCoupStr := Concat(positionEtCoupStr,'.');
        end;


      t := 1;
      coup := GET_NTH_MOVE_OF_PACKED_GAME(s60, 1,'ConstruitPositionEtCoupDapresListe(1)');    { coup 1 }
      good := true;                                   { ce coup 1 est legal }
      while (t <= 60) and (coup >= 11) and (coup <= 88) and good do
        begin
          if ModifPlatSeulement(coup,jeu,coulTrait)
            then
              begin
                case coulTrait of
                  pionNoir  : positionEtCoupStr := Concat(positionEtCoupStr,'N');
                  pionBlanc : positionEtCoupStr := Concat(positionEtCoupStr,'B');
                end;
                positionEtCoupStr := Concat(positionEtCoupStr,chr(coup));
                coulTrait := -coulTrait
              end
            else
              begin
                good := ModifPlatSeulement(coup,jeu,-coulTrait);
                if good then
                  begin
                    case -coulTrait of
                      pionNoir  : positionEtCoupStr := Concat(positionEtCoupStr,'N');
                      pionBlanc : positionEtCoupStr := Concat(positionEtCoupStr,'B');
                    end;
                    positionEtCoupStr := Concat(positionEtCoupStr,chr(coup));
                  end;
              end;
          t := t+1;
          coup := GET_NTH_MOVE_OF_PACKED_GAME(s60, t,'ConstruitPositionEtCoupDapresListe(2)');
        end;
      nbrecoupsjoues := Min(t-1,60);

      for t := LENGTH_OF_STRING(positionEtCoupStr)+1 to 184 do
        positionEtCoupStr := Concat(positionEtCoupStr,' ');
    end;
end;

procedure EssayerConstruireTitrePartie;
var nomNoir,nomBlanc : String255;
    scoreNoir,nroReference : SInt32;
    titre : String255;
begin
  if (nbPartiesActives = 1) and ((nbreCoup > 57) or gameOver) and JoueursEtTournoisEnMemoire then
    begin
      nroReference := tableNumeroReference^^[1];
      nomNoir := GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference);
      nomBlanc := GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference);
      scoreNoir := GetScoreReelParNroRefPartie(nroReference);
      ConstruitTitrePartie(nomnoir,nomblanc,true,scoreNoir,titre);
      ParamDiagPartieFFORUM.TitreFFORUM^^ := titre;
      titrePartie^^ := titre;
    end;
end;


function ConstruireTitreDapresListeParNroRefPartie(nroReference : SInt32) : String255;
var nomNoir,nomBlanc : String255;
    scoreNoir : SInt32;
    titre : String255;
begin
  nomNoir := GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference);
  nomBlanc := GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference);
  scoreNoir := GetScoreReelParNroRefPartie(nroReference);
  ConstruitTitrePartie(nomnoir,nomblanc,true,scoreNoir,titre);
  ConstruireTitreDapresListeParNroRefPartie := titre;
end;


procedure EssayerConstruireTitreDapresListe(nroPartie : SInt32);
var nroReference,t : SInt32;
    titre,tournoiStr : String255;
begin
  if (nbPartiesActives > 0) and JoueursEtTournoisEnMemoire then
    if (1 <= nroPartie) and (nroPartie <= nbPartiesActives) then
    begin
      nroReference := tableNumeroReference^^[nroPartie];
      titre := ConstruireTitreDapresListeParNroRefPartie(nroReference);
      ParamDiagCourant.TitreFFORUM^^ := titre;

      tournoiStr := GetNomTournoiParNroRefPartie(nroReference);
      t := LENGTH_OF_STRING(tournoiStr);
      while (tournoiStr[t] = ' ') and (t >= 1) do
        begin
          DeleteString(tournoiStr,t,1);
          t := t-1;
        end;
      tournoiStr := Concat(tournoiStr,'  ',IntToStr(GetAnneePartieParNroRefPartie(nroReference)));
      ParamDiagCourant.CommentPositionFFORUM^^ := tournoiStr;
      ParamDiagCourant.GainTheoriqueFFORUM := GetGainTheoriqueParNroRefPartie(nroReference);
    end;
end;


function ConstruireChaineReferencesPartie(nroNoir,nroBlanc,nroTournoi,annee,scoreNoir : SInt32; avecScores : boolean; numeroProchainCoup : SInt32) : String255;
var s,s1,s2,chaineScore,chaineNumeroCoup : String255;
    nomTournoi : String255;
    scoreBlanc : SInt32;
begin
  s1 := GetNomJoueurSansPrenom(nroNoir);
  s2 := GetNomJoueurSansPrenom(nroBlanc);

  scoreBlanc := 64 - scoreNoir;

  nomTournoi := GetNomTournoi(nroTournoi);

  if avecScores
    then chaineScore := Concat(' ',IntToStr(scoreNoir),'-',IntToStr(scoreBlanc),' ')
    else chaineScore := ' - ';

  if (numeroProchainCoup > 0) and (numeroProchainCoup <= 60)
    then chaineNumeroCoup := ', c.' + IntToStr(numeroProchainCoup)
    else chaineNumeroCoup := '';

  s := s1+chaineScore+s2+', '+EnleveEspacesDeDroite(nomtournoi)+' '+IntToStr(annee)+chaineNumeroCoup;

  ConstruireChaineReferencesPartie := s;
end;


function ConstruireChaineReferencesPartieParNroRefPartie(nroReference : SInt32; avecScores : boolean; numeroProchainCoup : SInt32) : String255;
var s,s1,s2,chaineScore,chaineNumeroCoup : String255;
    nomTournoi : String255;
    scoreNoir,scoreBlanc : SInt32;
    annee : SInt16;
begin
  s1 := GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference);
  s2 := GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference);

  scoreNoir := GetScoreReelParNroRefPartie(nroReference);
  scoreBlanc := 64 - scoreNoir;

  nomTournoi := GetNomTournoiParNroRefPartie(nroReference);
  annee := GetAnneePartieParNroRefPartie(nroReference);

  if avecScores
    then chaineScore := Concat(' ',IntToStr(scoreNoir),'-',IntToStr(scoreBlanc),' ')
    else chaineScore := ' - ';

  if (numeroProchainCoup > 0) and (numeroProchainCoup <= 60)
    then chaineNumeroCoup := ', c.' + IntToStr(numeroProchainCoup)
    else chaineNumeroCoup := '';

  s := s1+chaineScore+s2+', '+EnleveEspacesDeDroite(nomtournoi)+' '+IntToStr(annee)+chaineNumeroCoup;

  ConstruireChaineReferencesPartieParNroRefPartie := s;
end;





function ConstruireChaineReferencesPartieParNumeroReference(nroReference : SInt32; descriptionComplete : boolean) : String255;
var s : String255;
begin
  s := '';
  if descriptionComplete
    then
      if gameOver
        then s := ConstruireChaineReferencesPartieParNroRefPartie(nroReference,true,-1)
        else s := ConstruireChaineReferencesPartieParNroRefPartie(nroReference,true,nbreCoup+1)
    else s := ConstruireChaineReferencesPartieParNroRefPartie(nroReference,false,-1);
  ConstruireChaineReferencesPartieParNumeroReference := s;
end;


function ConstruireChaineReferencesPartieDapresListe(nroPartie : SInt32; descriptionComplete : boolean) : String255;
var nroReference : SInt32;
    s : String255;
begin
  s := '';
  if (nbPartiesActives > 0) and JoueursEtTournoisEnMemoire then
    if (1 <= nroPartie) and (nroPartie <= nbPartiesActives) then
      begin
        nroReference := tableNumeroReference^^[nroPartie];
        s := ConstruireChaineReferencesPartieParNumeroReference(nroReference,descriptionComplete);
      end;
  ConstruireChaineReferencesPartieDapresListe := s;
end;


function DernierePartieCompatibleEnMemoire(var numeroCoup,nroReference : SInt32) : String255;
var i,etat : SInt32;
    partie60 : PackedThorGame;
    partieEnAlpha : String255;
    erreur1,erreur2 : SInt32;
    positionEtTraitDansListe : PositionEtTraitRec;
    positionEtTraitPartie : PositionEtTraitRec;
begin

  DernierePartieCompatibleEnMemoire := '';
  for i := nbreCoup downto 1 do
    begin
      etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(i);

      if (etat <> PasDePartieActive) and ListePartiesEstGardeeDansLeCache(i,etat) then
        begin
          numeroCoup   := i;
          nroReference := TableInfoDejaCalculee^^[IndexInfoDejaCalculeesCoupNro^^[i-1]+1];

          if (nroReference > 0) and (nroReference <= nbPartiesChargees) then
            begin

              ExtraitPartieTableStockageParties(nroReference,partie60);
    		      TransposePartiePourOrientation(partie60,PartieCouranteEstUneDiagonaleAvecLeCoupQuatreEnD6,1,60);
    		      SHORTEN_PACKED_GAME(partie60,numeroCoup);

    		      positionEtTraitDansListe := PositionEtTraitAfterMoveNumber(partie60,numeroCoup,erreur1);
    		      positionEtTraitPartie := GetPositionEtTraitPartieCouranteApresCeCoup(numeroCoup,erreur2);

    		      if (erreur1 = kPartieOK) and (erreur2 = kPartieOK) and
    		         SamePositionEtTrait(positionEtTraitDansListe,positionEtTraitPartie) then
    		        begin
    		          TraductionThorEnAlphanumerique(partie60,partieEnAlpha);
    		          DernierePartieCompatibleEnMemoire := partieEnAlpha;
    		          exit;
    		        end;
    		    end;
        end;
    end;
end;


function GetNombreDePartiesActivesDansLeCachePourCeCoup(numeroDuCoup : SInt32) : SInt32;
begin
  if (numeroDuCoup < 0) or (numeroDuCoup > 65)
    then GetNombreDePartiesActivesDansLeCachePourCeCoup := NeSaitPasNbrePartiesActives
    else GetNombreDePartiesActivesDansLeCachePourCeCoup := partie^^[numeroDuCoup].nombrePartiesActives;
end;


procedure SetNombreDePartiesActivesDansLeCachePourCeCoup(numeroDuCoup,nbrePartiesActives : SInt32);
begin
  if (numeroDuCoup >= 0) or (numeroDuCoup <= 65) then
    partie^^[numeroDuCoup].nombrePartiesActives := nbrePartiesActives;
end;


function ListePartiesEstGardeeDansLeCache(quelCoup,nombrePartiesCompatibles : SInt32) : boolean;
var nbreInfoGardable : SInt32;
begin
  ListePartiesEstGardeeDansLeCache := true;
  if (nombrePartiesCompatibles = NeSaitPasNbrePartiesActives) then
    begin
      ListePartiesEstGardeeDansLeCache := false;
      exit;
    end;
  nbreInfoGardable := IndexInfoDejaCalculeesCoupNro^^[quelCoup]-IndexInfoDejaCalculeesCoupNro^^[quelCoup-1];
  if (nombrePartiesCompatibles > nbreInfoGardable) then
    ListePartiesEstGardeeDansLeCache := false;
end;


procedure InvalidateNombrePartiesActivesDansLeCache(quelNroCoup : SInt16);
begin
  if (quelNroCoup >= 0) and (quelNroCoup <= 65) then
    partie^^[quelNroCoup].nombrePartiesActives := NeSaitPasNbrePartiesActives;
  {WritelnNumDansRapport('InvalidateNombrePartiesActivesDansLeCache : ',quelNroCoup);}
end;


procedure InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
var i : SInt16;
begin
  for i := 0 to 65 do InvalidateNombrePartiesActivesDansLeCache(i);
end;


procedure NroHilite2NroReference(nroHilite : SInt32; var nroReference : SInt32);
var n : SInt32;
begin
 if nbPartiesChargees > 0 then
  if nbPartiesActives > 0
   then
     begin
       if (nroHilite >= 1) and (nroHilite <= nbPartiesActives)
         then nroReference := tableNumeroReference^^[nroHilite];
     end
   else
     begin
       n := nroDernierCoupAtteint;
       repeat
         if GetNombreDePartiesActivesDansLeCachePourCeCoup(n) = 1 then
           if ListePartiesEstGardeeDansLeCache(n,1) then
           begin
             nroReference := TableInfoDejaCalculee^^[IndexInfoDejaCalculeesCoupNro^^[n-1]+1];
             exit;
           end;
         n := n-1;
       until (n <= 1);
     end;
end;

procedure NroReference2NroHilite(nroReference : SInt32; var nroHilite : SInt32);
var i,result,distance,distanceMinimum : SInt32;
    trouve,doitChercherPlusProche : boolean;
    distanceAnnee,distanceTournoi,distanceNoir,distanceBlanc : SInt32;
    rangAlphabetiqueTournoiCherche,anneeCherchee : SInt32;
    rangAlphabetiqueNoirCherche,rangAlphabetiqueBlancCherche : SInt32;
    ancienNroHilite : SInt32;
begin

  ancienNroHilite := infosListeParties.partieHilitee;

  nroHilite := 1;  {par defaut on selectionne la premiere partie de la liste}


  with infosListeParties do
  if windowListeOpen and (nbPartiesActives > 0) then
    if nbPartiesActives > 1 then
        begin
          result := 1;

          if (nroReference = infosListeParties.dernierNroReferenceHilitee) and (nroReference > 0) then
            begin
              doitChercherPlusProche := true;
              anneeCherchee := GetAnneePartieParNroRefPartie(nroReference);
              rangAlphabetiqueTournoiCherche := GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(nroReference);
              rangAlphabetiqueNoirCherche := GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(nroReference);
              rangAlphabetiqueBlancCherche := GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(nroReference);
            end;


          trouve := false;
          distanceMinimum := 2000000000;  {2000000000 was MawLongint}
          distance := 2000000000;         {2000000000 was MawLongint}
          {on scanne la liste pour trouver nroReference, ou une partie proche
           au sens des criteres de tri de la liste}
          for i := 1 to nbPartiesActives do
            begin

              if nroReference = tableNumeroReference^^[i]
			          then distance := 0
			          else
		              if doitChercherPlusProche
		                then
		                  begin
		                    distance := 100*Abs(nroReference - tableNumeroReference^^[i]);

		                    distanceAnnee := 1000*Abs(anneeCherchee - GetAnneePartieParNroRefPartie(tableNumeroReference^^[i]));

					              distanceTournoi := 10000*Abs(rangAlphabetiqueTournoiCherche - GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(tableNumeroReference^^[i]));
					              if ((gGenreDeTriListe = TriParDate) or (gGenreDeTriListe = TriParAntiDate)) and (distanceTournoi > 0)
					                then distanceTournoi := distanceTournoi + 100000000;

					              distanceNoir    := Abs(rangAlphabetiqueNoirCherche - GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(tableNumeroReference^^[i]));
					              if (gGenreDeTriListe = TriParJoueurNoir) and (distanceNoir > 0)
					                then distanceNoir := distanceNoir + 100000000;

					              distanceBlanc   := Abs(rangAlphabetiqueBlancCherche - GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(tableNumeroReference^^[i]));
					              if (gGenreDeTriListe = TriParJoueurBlanc) and (distanceBlanc > 0)
					                then distanceBlanc := distanceBlanc + 100000000;

					              distance := distance + distanceAnnee + distanceTournoi + distanceNoir + distanceBlanc;
					            end;

              if distance < distanceMinimum then
	              begin
	                result := i;
	                distanceMinimum := distance;

	                if distance = 0 then
	                  begin
			                trouve := true;
			                leave;
			              end;
	              end;
	          end;

	        {
	        WritelnNumDansRapport('nroReference = ',nroReference);
	        WritelnNumDansRapport('result = ',result);
	        WritelnNumDansRapport('distance = ',distance);
	        WritelnNumDansRapport('GetNumeroPremierePartieAffichee = ',GetNumeroPremierePartieAffichee);
	        WritelnNumDansRapport('GetNumeroDernierePartieAffichee = ',GetNumeroDernierePartieAffichee);
	        WritelnNumDansRapport('ancienNroHilite = ',ancienNroHilite);
	        WritelnNumDansRapport('delta = ',result - GetNumeroPremierePartieAffichee);}

          {result est la partie la plus "proche" (au sens des criteres de tri de la liste)
           de l'ancienne partie hilitee}
          nroHilite := result;
          if nbPartiesActives <= nbreLignesFntreListe then
            begin
              positionPouceAscenseurListe := 1;
              SetValeurAscenseurListe(positionPouceAscenseurListe);
            end
           else
            if nroHilite+nbreLignesFntreListe > nbPartiesActives then
              begin
                positionPouceAscenseurListe := nbPartiesActives - nbreLignesFntreListe + 1;
                SetValeurAscenseurListe(positionPouceAscenseurListe);
              end
            else
              begin
                if (gLigneOuLOnVoudraitQueSoitLaPartieHilitee > 0) and (gLigneOuLOnVoudraitQueSoitLaPartieHilitee <= nbreLignesFntreListe)
                  then positionPouceAscenseurListe := nroHilite - gLigneOuLOnVoudraitQueSoitLaPartieHilitee + 1
                  else positionPouceAscenseurListe := nroHilite;
                SetValeurAscenseurListe(positionPouceAscenseurListe);
              end;
        end;
end;


function NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre : SInt32;
var compteur,nroPartie : SInt32;
    premierNumero,dernierNumero : SInt32;
begin
 if windowListeOpen then
   with infosListeParties do
	  begin
      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);

      for compteur := 0 to dernierNumero - premierNumero do
        begin
          nroPartie := tableNumeroReference^^[premierNumero+compteur];

          if PartieEstActive(nroPartie) and (partieHilitee = premierNumero+compteur) then
            begin
              NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre := compteur+1;
              exit;
            end;
        end;
	 end;
  NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre := -1;  {not found}
end;



function CalculeNbreLignesVisiblesFntreListe : SInt32;
begin
  if windowListeOpen and (wListePtr <> NIL)
    then CalculeNbreLignesVisiblesFntreListe := (GetWindowPortRect(wListePtr).bottom - GetWindowPortRect(wListePtr).top - hauteurRubanListe - hauteurPiedDePageListe) div HauteurChaqueLigneDansListe
    else CalculeNbreLignesVisiblesFntreListe := -1;
end;


function GetHauteurChaqueLigneDansListe : SInt32;
begin
  GetHauteurChaqueLigneDansListe := HauteurChaqueLigneDansListe;
end;


function LargeurNormaleFenetreListe(nbreDeColonnes : SInt32) : SInt32;
const margeNomDesJoueur = 0;
begin
  if listeEtroiteEtNomsCourts
   then
     case nbreDeColonnes of
       kAvecAffichageDistribution        : LargeurNormaleFenetreListe := 365 + 2*margeNomDesJoueur;
       kAvecAffichageTournois            : LargeurNormaleFenetreListe := 315 + 2*margeNomDesJoueur;
       kAvecAffichageSeulementDesJoueurs : LargeurNormaleFenetreListe := 218 + 2*margeNomDesJoueur;
     end
   else
     case nbreDeColonnes of
       kAvecAffichageDistribution        : LargeurNormaleFenetreListe := 20 + 480 + 2*margeNomDesJoueur;
       kAvecAffichageTournois            : LargeurNormaleFenetreListe := 20 + 430 + 2*margeNomDesJoueur;
       kAvecAffichageSeulementDesJoueurs : LargeurNormaleFenetreListe := 20 + 278 + 2*margeNomDesJoueur;
     end;
end;


procedure AjustePositionAscenseurListe;
var ascenseurRect : rect;
    positionPouce : SInt32;
begin
  with infosListeParties do
   if windowListeOpen and (wListePtr <> NIL) then
    begin
      SetRect(ascenseurRect,GetWindowPortRect(wListePtr).right-15,
                            GetWindowPortRect(wListePtr).top-1+hauteurRubanListe,
                            GetWindowPortRect(wListePtr).right+1,
                            GetWindowPortRect(wListePtr).bottom-15);
      if gIsRunningUnderMacOSX then inc(ascenseurRect.top);

      nbreLignesFntreListe := CalculeNbreLignesVisiblesFntreListe;
      if ascenseurListe <> NIL then
        begin
          MoveControl(ascenseurListe,ascenseurRect.left,ascenseurRect.top);
          SizeControl(ascenseurListe,ascenseurRect.right-ascenseurRect.left,ascenseurRect.bottom-ascenseurRect.top+1);
          CalculeControlLongintMaximum(nbreLignesFntreListe);
          positionPouce := GetNumeroPremierePartieAffichee;
          SetValeurAscenseurListe(positionPouce);
        end;
      DrawControls(wListePtr);

      gPiedDePageFenetreListeRect := MakeRect(10,GetWindowPortRect(wListePtr).bottom-hauteurPiedDePageListe,100,GetWindowPortRect(wListePtr).bottom);
      DessinePiedDePageFenetreListe;
    end;
end;

procedure AjustePouceAscenseurListe(avecDessinDeLAscensseur : boolean);
var positionPouce : SInt32;
begin
  with infosListeParties do
   if windowListeOpen then
    begin
      nbreLignesFntreListe := CalculeNbreLignesVisiblesFntreListe;
      CalculeControlLongintMaximum(nbreLignesFntreListe);
      positionPouce := GetNumeroPremierePartieAffichee;
      SetValeurAscenseurListe(positionPouce);


      if avecDessinDeLAscensseur then DrawControls(wListePtr);
    end;
end;



function FenetreListeEstEnModeEntree : boolean;
begin
  FenetreListeEstEnModeEntree := windowListeOpen and
                              (wListePtr = FrontWindowSaufPalette) and
                              (BoiteDeSousCritereActive <> 0);
end;


procedure PasseListeEnModeEntree(boxActivee : SInt16);
var oldport : grafPtr;
    i : SInt16;
begin
  if windowListeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);
      if (BoxActivee < TournoiRubanBox) or (boxActivee > DistributionRubanBox)
        then
          begin
            BoiteDeSousCritereActive := 0;
            TEDeactivate(SousCriteresRuban[TournoiRubanBox]);
            TEDeactivate(SousCriteresRuban[JoueurNoirRubanBox]);
            TEDeactivate(SousCriteresRuban[JoueurBlancRubanBox]);
            TEDeactivate(SousCriteresRuban[DistributionRubanBox]);
            GetCurrentScript(gLastScriptUsedInDialogs);
            SwitchToRomanScript;
          end
        else
          if sousSelectionActive then
            begin
              SwitchToScript(gLastScriptUsedInDialogs);
              BoiteDeSousCritereActive := boxActivee;
              for i := TournoiRubanBox to DistributionRubanBox do
                if i = BoiteDeSousCritereActive
                  then TEactivate(SousCriteresRuban[i])
                  else TEDeactivate(SousCriteresRuban[i]);
              TESetSelect(0,MAXINT_16BITS,SousCriteresRuban[BoiteDeSousCritereActive]);
            end;
      EcritRubanListe(true);
      SetPort(oldport);
    end;
end;



function CoupSuivantPartieSelectionnee(nroHilite : SInt32) : SInt16;
var nroReference : SInt32;
    premierNumero,dernierNumero : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    CaseX,premierCoup : SInt16;
    coupEnByte : SInt32;
    s60 : PackedThorGame;
begin
  CoupSuivantPartieSelectionnee := -1;
  if (nbreCoup < 60) and windowListeOpen and not(enRetour or enSetUp) then
   with infosListeParties do
    begin
      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
      if (nroHilite >= premierNumero) and (nroHilite <= dernierNumero) then
        if (nroHilite >= 1) and (nroHilite <= nbPartiesActives) then
          begin
            {nroReference := tableNumeroReference^^[nroHilite];
            if nroReference <> infosListeParties.dernierNroReferenceHilitee then SysBeep(0);}
            nroReference := infosListeParties.dernierNroReferenceHilitee;

    		    ExtraitPartieTableStockageParties(nroReference,s60);
    		    ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
    		    ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
    		    TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie and ouvertureDiagonale,4,60);

    		    if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) then
    		      begin
    		        WritelnDansRapport('WARNING : not(positionsSontEgales(…) dans CoupSuivantPartieSelectionnee');
    		        with DemandeCalculsPourBase do
    	            if (EtatDesCalculs <> kCalculsEnCours) or (NumeroDuCoupDeLaDemande <> nbreCoup) or bInfosDejaCalcules then
    	              LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
    	          InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
    		        exit;
    		      end;

            ExtraitCoupTableStockagePartie(nroReference,nbreCoup+1,coupEnByte);
            caseX := coupEnByte;
            if (caseX >= 11) and (caseX <= 88) then
              begin
                autreCoupQuatreDansPartie := false;
                if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
                TransposeCoupPourOrientation(caseX,autreCoupQuatreDansPartie);
                CoupSuivantPartieSelectionnee := caseX;
              end;
          end;
    end;
end;



procedure FiltreAscenseurListe(theControl : ControlHandle; partCode : SInt16);
var ancPosPouce : SInt32;
begin
  {$UNUSED theControl}

  with infosListeParties do
    begin
	  case partCode of
	    kControlUpButtonPart:
	      begin
	        ancPosPouce := positionPouceAscenseurListe;
	        positionPouceAscenseurListe := positionPouceAscenseurListe-1;
	        SetValeurAscenseurListe(positionPouceAscenseurListe);
	        if ancPosPouce <> positionPouceAscenseurListe then
	          ScrollEtEcritPartieVisibleListe(true,false);
	      end;
	    kControlDownButtonPart:
	      begin
	        ancPosPouce := positionPouceAscenseurListe;
	        positionPouceAscenseurListe := positionPouceAscenseurListe+1;
	        SetValeurAscenseurListe(positionPouceAscenseurListe);
	        if ancPosPouce <> positionPouceAscenseurListe then
	          ScrollEtEcritPartieVisibleListe(false,false);
	      end;
	    kControlPageUpPart:
	      begin
	        ancPosPouce := positionPouceAscenseurListe;
	        positionPouceAscenseurListe := positionPouceAscenseurListe-nbreLignesFntreListe+1;
	        SetValeurAscenseurListe(positionPouceAscenseurListe);
	        if ancPosPouce <> positionPouceAscenseurListe then
	          EcritListeParties(false,'FiltreAscenseurListe(1)');
	      end;
	    kControlPageDownPart:
	      begin
	        ancPosPouce := positionPouceAscenseurListe;
	        positionPouceAscenseurListe := positionPouceAscenseurListe+nbreLignesFntreListe-1;
	        SetValeurAscenseurListe(positionPouceAscenseurListe);
	        if ancPosPouce <> positionPouceAscenseurListe then
	          EcritListeParties(false,'FiltreAscenseurListe(2)');
	      end;
	    end;
    end;
end;


{fonction remplacant TrackControl pour les clics dans le pouce de la liste :
 mise a jour simultanee de l'ascenseur et de l'affichage de la liste}
function MyTrackControlIndicatorPartListe(TheControl : ControlHandle) : SInt16;
var oldValue, newValue: SInt32;
    horizontal,avecDoubleScroll : boolean;
    minimum,maximum : SInt32;
    ascenseurRect,barreGrisee : rect;
    mouseLoc,oldMouseLoc : Point;
    SourisADejaBouje : boolean;
    tailleDuPouce : SInt32;
    proportion : fixed;
begin
  {$UNUSED theControl}

  MyTrackControlIndicatorPartListe := 0;

  with infosListeParties do
     if (ascenseurListe <> NIL) then
	    begin
	      SetPortByWindow(wListePtr);
	      GetMouse(oldMouseLoc);
	      SourisADejaBouje := false;
	      HiliteControl(ascenseurListe,kControlIndicatorPart);

	      avecDoubleScroll := EstUnAscenseurAvecDoubleScroll(ascenseurListe,ascenseurRect,barreGrisee,horizontal);
	      if horizontal
	        then
	          begin
	            InsetRect(ascenseurRect,-30,-20);
	            if SmartScrollEstInstalle(ascenseurListe,proportion)
	              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.right-barreGrisee.left,1))))
	              else TailleDuPouce := 16;
	            InsetRect(barreGrisee,tailleDuPouce div 2,0);
	          end
	        else
	          begin
	            InsetRect(ascenseurRect,-20,-30);
	            if SmartScrollEstInstalle(ascenseurListe,proportion)
	              then TailleDuPouce := Max(16,fixround(fixmul(proportion,fixRatio(barreGrisee.bottom-barreGrisee.top,1))))
	              else TailleDuPouce := 16;
	            InsetRect(barreGrisee,0,tailleDuPouce div 2);
	          end;
	      while StillDown do
	        begin
	          SetPortByWindow(wListePtr);
	          GetMouse(mouseLoc);
	          SourisADejaBouje := SourisADejaBouje or (SInt32(mouseLoc) <> SInt32(oldMouseLoc));
	          if SourisADejaBouje and (SInt32(mouseLoc) <> SInt32(oldMouseLoc)) then
	            begin
		          oldValue := GetControlValue(ascenseurListe);
		          minimum := GetControlMinimum(ascenseurListe);
		          maximum := GetControlMaximum(ascenseurListe);
		          if PtInRect(mouseLoc,ascenseurRect) then
		            begin
		              with barreGrisee do
		                if horizontal
		                  then newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.h-left)) div (right-left)
		                  else newValue := minimum+ ((maximum-minimum+1)*(mouseLoc.v-top)) div (bottom-top);
		              if newValue > maximum then newValue := maximum;
		              if newValue < minimum then newValue := minimum;
		              if newValue <> oldValue then
		                begin
		                  SetControlValue(ascenseurListe,newValue);
		                  InterpolationPremierePartieAffichee(newValue);
		                  EcritListeParties(false,'MyTrackControlIndicatorPartListe');
		                  MyTrackControlIndicatorPartListe := kControlIndicatorPart;
		                end;

		            end;
	            end;
	          oldMouseLoc := mouseLoc;
	        end;
	      HiliteControl(ascenseurListe,0);
	    end;
end;


procedure DessineBoiteTailleEtAscenseurDroite(whichWindow : WindowPtr);
var oldPort : grafPtr;
    unRect : rect;
    oldClipRgn : RgnHandle;
    toujoursActivee : boolean;
begin
  toujoursActivee := true;
  if whichWindow <> NIL then
    begin

      GetPort(oldPort);
      SetPortByWindow(whichWindow);
      with GetWindowPortRect(whichWindow) do
        SetRect(unRect,right-15,top-1+hauteurRubanListe,right+1,bottom);

      PenSize(1,1);
      oldclipRgn := NewRgn;
      GetClip(oldClipRgn);
      ClipRect(unRect);
      PenPat(blackPattern);

      DrawGrowIcon(whichWindow);
      SetClip(oldClipRgn);
      DisposeRgn(oldclipRgn);
      SetPort(oldPort);

    end;
end;

procedure SetPartieHilitee(numero : SInt32);
begin
  with infosListeParties do
    begin
      partieHilitee := numero;
      if partieHilitee > nbPartiesActives then partieHilitee := nbPartiesActives;
      if partieHilitee < 1 then partieHilitee := 1;
      NroHilite2NroReference(partieHilitee,dernierNroReferenceHilitee);
    end;
end;

procedure SetPartieHiliteeEtAjusteAscenseurListe(numero : SInt32);
var positionPouce : SInt32;
begin
  with infosListeParties do
	  begin
	    SetPartieHilitee(numero);
	    if WindowListeOpen then
	      begin
	        positionPouce := partieHilitee;
	        SetValeurAscenseurListe(positionPouce);
	        AjustePouceAscenseurListe(true);
	      end;
	  end;
end;


procedure InitInfosFermetureListePartie(var infos : InfosFermetureFenetreListeRec);
begin
  with infos do
    begin
      longintValue                := -1;
      longintMaximum              := -1;
      longintMinimum              := -1;
      nbreLignesFntreListe        := -1;
      positionPouceAscenseurListe := -1;
      partieHilitee               := -1;
      dernierNroReferenceHilitee  := -1;
      nombrePartiesActives        := -1;
      nombrePartiesChargees       := -1;
      justificationPasDePartie    := -1;
    end;
end;

procedure SaveInfosFermetureListePartie(source : ListePartiesRec; var dest : InfosFermetureFenetreListeRec);
begin
  with dest do
    begin
      longintValue                := source.longintValue;
      longintMaximum              := source.longintMaximum;
      longintMinimum              := source.longintMinimum;
      nbreLignesFntreListe        := source.nbreLignesFntreListe;
      positionPouceAscenseurListe := source.positionPouceAscenseurListe;
      partieHilitee               := source.partieHilitee;
      dernierNroReferenceHilitee  := source.dernierNroReferenceHilitee;
      justificationPasDePartie    := -1;
      nombrePartiesActives        := nbPartiesActives;
      nombrePartiesChargees       := nbPartiesChargees;
    end;
end;

procedure ClipToRectArea(thisRect : rect);
begin
  with gOldClipRgn do
    begin
      if (niveauRecursion >= 0) and (niveauRecursion <= 10) then
        begin
          regions[niveauRecursion] := NewRgn;
          GetClip(regions[niveauRecursion]);
        end;
      ClipRect(thisRect);
      inc(niveauRecursion);
    end;
end;

procedure UnclipRectArea;
begin
  with gOldClipRgn do
    begin
      dec(niveauRecursion);
      if (niveauRecursion >= 0) then
        begin
          SetClip(regions[niveauRecursion]);
          DisposeRgn(regions[niveauRecursion]);
        end;
    end;
end;





function PartieDansLaListeIdentiqueAPartieCourante(nroReferencePartie, numeroDuCoup: SInt32; autreCoupQuatreDiagonal : boolean) : boolean;
var foo : SInt32;
    ouvertureDiagonale, result : boolean;
    s60 : PackedThorGame;
begin
  result := true;

  if (numeroDuCoup >= 5) and (numeroDuCoup <= 60) then
    begin

      ExtraitPartieTableStockageParties(nroReferencePartie,s60);
      ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
      TransposePartiePourOrientation(s60,autreCoupQuatreDiagonal and ouvertureDiagonale,4,60);

      if not(PositionsSontEgales(GetPositionEtTraitPartieCouranteApresCeCoup(numeroDuCoup, foo).position,
                                 CalculePositionApres(numeroDuCoup,s60)))
         then result := false;
    end;

  PartieDansLaListeIdentiqueAPartieCourante := result;
end;


procedure EcritPartieDansFenetreListe(nroPartie : SInt32; autreCoupQuatreDansPartie : boolean; yposition : SInt32);
var s,s1 : String255;
    coup : SInt32;
    reponse,i : SInt16;
    score : SInt32;
    couleurAffichageSousCritere : SInt32;
    couleurAffichagePartieDouteuse : SInt32;
    couleurAffichageNormal : SInt32;
    couleurAffichagePartieParInterversion : SInt32;
    couleurTexte : SInt32;

begin
  TextMode(1);
  couleurAffichageSousCritere           := BlueColor;
  couleurAffichagePartieDouteuse        := RedColor;
  couleurAffichageNormal                := BlackColor;
  couleurAffichagePartieParInterversion := GreenColor;


  score := GetScoreReelParNroRefPartie(nroPartie);


  if PartieDansListeEstDouteuse(nroPartie)
    then couleurTexte := couleurAffichagePartieDouteuse
    else couleurTexte := couleurAffichageNormal;


  if gCassioUseQuartzAntialiasing
	  then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);


  { ECRITURE DE LA DISTRIBUTION (COLONNE VERTE) }

  if (nbColonnesFenetreListe = kAvecAffichageDistribution) then
    begin
      if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[DistributionRubanBox]) <>  0)
        then ForeColor(couleurAffichageSousCritere)
        else
          begin
            RGBForeColor(gPurGris);
          end;

      TextFont(GenevaID);
      TextSize(9);
      TextFace(italic);
      s := GetNomDistributionParNroRefPartie(nroPartie);
      Moveto(positionDistribution,yposition);

      ClipToRectArea(MakeRect(positionDistribution-2,yposition-13,
                              Min(positionTournoi-4,GetWindowPortRect(wListePtr).right-15),yposition+3));
      MyDrawString(s);
      UnclipRectArea;


    end;

  if PartieDansListeDoitEtreSauvegardee(nroPartie)
    then TextFace(italic)
    else TextFace(normal);

  { ECRITURE DU TOURNOI }

  if (nbColonnesFenetreListe = kAvecAffichageTournois) or (nbColonnesFenetreListe = kAvecAffichageDistribution) then
    begin
      if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[TournoiRubanBox]) <> 0)
        then ForeColor(couleurAffichageSousCritere)
        else ForeColor(couleurTexte);
      if gVersionJaponaiseDeCassio and gHasJapaneseScript and gDisplayJapaneseNamesInJapanese and
         EstUnePartieAvecTournoiJaponais(nroPartie)
        then
          begin
            TextFont(gCassioApplicationFont);
            TextSize(gCassioNormalFontSize);
            {s := GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie(nroPartie,29);}

            s := GetNomJaponaisDuTournoiParNroRefPartie(nroPartie);
            Moveto(positionTournoi,yposition);
            MyDrawString(s);

            s1 := '';
            for i := 1 to 27-LENGTH_OF_STRING(s)-4 do s1 := s1 + ' ';
            s1 := s1 + IntToStr(GetAnneePartieParNroRefPartie(nroPartie));

            TextFont(GenevaID);
            TextSize(9);
            MyDrawString(s1);
          end
        else
          begin
            TextFont(GenevaID);
            TextSize(9);

            if listeEtroiteEtNomsCourts
              then s := GetNomCourtTournoiAvecAnneeParNroRefPartie(nroPartie,17)
              else s := GetNomTournoiAvecAnneeParNroRefPartie(nroPartie,29);


            Moveto(positionTournoi,yposition);MyDrawString(s);
          end;
    end;


  { ECRITURE DU NOM DU JOUEUR NOIR }

  if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[JoueurNoirRubanBox]) <> 0)
    then ForeColor(couleurAffichageSousCritere)
    else ForeColor(couleurTexte);
  if (avecGagnantEnGrasDansListe and (score > 32))
    then
      begin
        if PartieDansListeDoitEtreSauvegardee(nroPartie)
          then TextFace(bold+italic)
          else TextFace(bold);
        ClipToRectArea(MakeRect(positionNoir,yposition-13,
                                Min(positionBlanc-3,GetWindowPortRect(wListePtr).right-15),yposition+3));
        if gCassioUseQuartzAntialiasing
	        then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
      end
    else
      begin
        if PartieDansListeDoitEtreSauvegardee(nroPartie)
          then TextFace(italic)
          else TextFace(normal);
        if listeEtroiteEtNomsCourts then
          ClipToRectArea(MakeRect(positionNoir,yposition-13,
                                  Min(positionBlanc-3,GetWindowPortRect(wListePtr).right-15),yposition+3));
        if gCassioUseQuartzAntialiasing
	        then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);
	    end;
  if gVersionJaponaiseDeCassio and gHasJapaneseScript and gDisplayJapaneseNamesInJapanese and
     EstUnePartieAvecJoueurNoirJaponais(nroPartie)
    then
      begin
        TextFont(gCassioApplicationFont);
        TextSize(gCassioNormalFontSize);
        s := GetNomJaponaisDuJoueurNoirParNroRefPartie(nroPartie);
        Moveto(positionNoir,yposition);
        MyDrawString(s);
      end
    else
      begin
        TextFont(GenevaID);
        TextSize(9);

        if listeEtroiteEtNomsCourts
          then s := GetNomJoueurNoirSansPrenomParNroRefPartie(nroPartie)
          else s := GetNomJoueurNoirParNroRefPartie(nroPartie);

        Moveto(positionNoir,yposition);
        if s[LENGTH_OF_STRING(s)] = '.'
          then
            begin
              MyDrawString(LeftOfString(s,LENGTH_OF_STRING(s)-1));
              if PartieDansListeDoitEtreSauvegardee(nroPartie)
                then TextFace(italic)
                else TextFace(normal);
              DrawChar('.');
            end
          else MyDrawString(s);
      end;
  if listeEtroiteEtNomsCourts or (avecGagnantEnGrasDansListe and (score > 32)) then UnclipRectArea;


  { ECRITURE DU NOM DU JOUEUR BLANC }

  if sousSelectionActive and (TEGetTextLength(SousCriteresRuban[JoueurBlancRubanBox]) <> 0)
    then ForeColor(couleurAffichageSousCritere)
    else ForeColor(couleurTexte);
  if (avecGagnantEnGrasDansListe and (score < 32))
    then
      begin
        if PartieDansListeDoitEtreSauvegardee(nroPartie)
          then TextFace(bold+italic)
          else TextFace(bold);
        ClipToRectArea(MakeRect(positionBlanc,yposition-13,
                                Min(positionCoup-3,GetWindowPortRect(wListePtr).right-15),yposition+3));
        if gCassioUseQuartzAntialiasing
	        then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
      end
    else
      begin
        if PartieDansListeDoitEtreSauvegardee(nroPartie)
          then TextFace(italic)
          else TextFace(normal);if PartieDansListeDoitEtreSauvegardee(nroPartie)
          then TextFace(italic)
          else TextFace(normal);
        if listeEtroiteEtNomsCourts then
          ClipToRectArea(MakeRect(positionBlanc,yposition-13,
                                  Min(positionCoup-3,GetWindowPortRect(wListePtr).right-15),yposition+3));
        if gCassioUseQuartzAntialiasing
	        then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);
	    end;
  if gVersionJaponaiseDeCassio and gHasJapaneseScript and gDisplayJapaneseNamesInJapanese and
     EstUnePartieAvecJoueurBlancJaponais(nroPartie)
    then
      begin
        TextFont(gCassioApplicationFont);
        TextSize(gCassioNormalFontSize);
        s := GetNomJaponaisDuJoueurBlancParNroRefPartie(nroPartie);
        Moveto(positionBlanc,yposition);MyDrawString(s);
      end
    else
      begin
        TextFont(GenevaID);
        TextSize(9);


        if listeEtroiteEtNomsCourts
          then s := GetNomJoueurBlancSansPrenomParNroRefPartie(nroPartie)
          else s := GetNomJoueurBlancParNroRefPartie(nroPartie);

        Moveto(positionBlanc,yposition);
        if s[LENGTH_OF_STRING(s)] = '.'
          then
            begin
              MyDrawString(LeftOfString(s,LENGTH_OF_STRING(s)-1));
              if PartieDansListeDoitEtreSauvegardee(nroPartie)
                then TextFace(italic)
                else TextFace(normal);
              DrawChar('.');
            end
          else MyDrawString(s);
      end;
  if listeEtroiteEtNomsCourts or (avecGagnantEnGrasDansListe and (score < 32)) then UnclipRectArea;


  { ECRITURE DU GAIN THEORIQUE }

  if PartieDansListeDoitEtreSauvegardee(nroPartie)
    then TextFace(italic)
    else TextFace(normal);

  if not(PartieDansLaListeIdentiqueAPartieCourante(nroPartie, nbreCoup - 1, autreCoupQuatreDansPartie))
    then ForeColor(couleurAffichagePartieParInterversion)
    else ForeColor(couleurTexte);

  if gCassioUseQuartzAntialiasing
	  then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);
  s := GetGainTheoriqueParNroRefPartie(nroPartie);
  if nbreCoup < 60 then
    begin
      ExtraitCoupTableStockagePartie(nroPartie,nbreCoup+1,coup);
      reponse := ord(coup);
      if reponse > 0 then
        begin
          TransposeCoupPourOrientation(reponse,autreCoupQuatreDansPartie);
          s := CoupEnString(reponse,CassioUtiliseDesMajuscules)+'  '+s;
        end;
    end;
  if gVersionJaponaiseDeCassio and gHasJapaneseScript
    then
      begin
        TextFont(gCassioApplicationFont);
        TextSize(9);
        Moveto(positionCoup,yposition);MyDrawString(s);
      end
    else
      begin
        TextFont(GenevaID);
        TextSize(9);
        Moveto(positionCoup,yposition);MyDrawString(s);
      end;

  { ECRITURE DU SCORE REEL }

  s := IntToStr(score);
  s1 := IntToStr(64-score);
  s := s + CharToString('-')+s1;
  Moveto(positionScoreReel,yposition);MyDrawString(s);

  ForeColor(BlackColor);
end;



procedure ChangePartieHilitee(nouvellePartieHilitee,anciennePartieHilitee : SInt32);
var oldport : grafPtr;
    premierNumero,dernierNumero,yposition : SInt32;
    unRect : rect;
    autreCoupQuatreDansPartie : boolean;
    premierCoup : SInt16;
begin
 with infosListeParties do
   if windowListeOpen and not(problemeMemoireBase) and JoueursEtTournoisEnMemoire then
     begin
       GetPort(oldport);
       SetPortByWindow(wListePtr);
       GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);

       autreCoupQuatreDansPartie := false;
	     if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);

       SetPartieHilitee(nouvellePartieHilitee);

       if (anciennePartieHilitee >= premierNumero) and (anciennePartieHilitee <= dernierNumero)
         and not(PartieEstDansLaSelection(tableNumeroReference^^[anciennePartieHilitee]))
         then  {effacement de l'ancienne partie hilitee}
           begin
             yposition := (anciennePartieHilitee-premierNumero)*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
             SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),GetWindowPortRect(wListePtr).right-15,yposition+3);

             ClipToRectArea(unRect);
             EffacerRectanglePartieDansListe(unRect,tableNumeroReference^^[anciennePartieHilitee]);
	           EcritPartieDansFenetreListe(tableNumeroReference^^[anciennePartieHilitee],autreCoupQuatreDansPartie,yposition);
	           UnclipRectArea;
           end;

       if (nouvellePartieHilitee >= premierNumero) and (nouvellePartieHilitee <= dernierNumero) and
         not(PartieEstDansLaSelection(tableNumeroReference^^[nouvellePartieHilitee]))
         then  {dessin de la nouvelle partie hilitee}
           begin
             yposition := (nouvellePartieHilitee-premierNumero)*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
             SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),GetWindowPortRect(wListePtr).right-15,yposition+3);

             ClipToRectArea(unRect);
             EffacerRectanglePartieDansListe(unRect,tableNumeroReference^^[nouvellePartieHilitee]);
             HiliteRect(unRect);
             EcritPartieDansFenetreListe(tableNumeroReference^^[nouvellePartieHilitee],autreCoupQuatreDansPartie,yposition);
             UnclipRectArea;
           end;

       if (nbPartiesActives > nbreLignesFntreListe)
         then gLigneOuLOnVoudraitQueSoitLaPartieHilitee := NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre;

       SetPort(oldport);
     end;
end;


procedure InvalidateJustificationPasDePartieDansListe;
begin
  infosListeParties.justificationPasDePartie := -1;
end;


function GetAutorisationChargerLaBaseSansPasserParLeDialogue : boolean;
begin
  GetAutorisationChargerLaBaseSansPasserParLeDialogue := gAutorisationChargerLaBaseSansPasserParLeDialogue;
end;


procedure SetAutorisationChargerLaBaseSansPasserParLeDialogue(flag : boolean);
begin
  gAutorisationChargerLaBaseSansPasserParLeDialogue := flag;
end;


procedure EffacerRectanglePartieDansListe(whichRect : rect; nroRefPartie : SInt32);
var theColor : RGBColor;
    mil : SInt32;
    ligneImpaire : boolean;
begin
  if (nroRefPartie >= 1) and (nroRefPartie <= nbPartiesChargees) and
     PartieDansListeDoitEtreSauvegardee(nroRefPartie) and
     (nroRefPartie <> infosListeParties.dernierNroReferenceHilitee) and
     not(PartieEstDansLaSelection(nroRefPartie))
    then
      begin
        theColor := CouleurCmdToRGBColor(OrangeCmd);
        theColor := EclaircirCouleurDeCetteQuantite(theColor, 40000);
        RGBForeColor(theColor);
        FillRect(whichRect,blackPattern);
        ForeColor(BlackColor);
      end
    else
      begin
        if PartieEstDansLaSelection(nroRefPartie)
          then
            begin
              MyEraseRect(whichRect);
              MyEraseRectWithColor(whichRect,OrangeCmd,blackPattern,'');
            end
          else
            begin
              mil := (whichRect.bottom + whichRect.top) div 2;
              ligneImpaire := odd(GetNumeroPremierePartieAffichee + ((mil - hauteurRubanListe) div HauteurChaqueLigneDansListe));
              if ligneImpaire
                then
                  begin
                    MyEraseRect(whichRect);
                    MyEraseRectWithColor(whichRect,OrangeCmd,blackPattern,'');
                  end
                else
                  begin
                    SetRGBColor(theColor,60909,62451,65275);
                    RGBForeColor(theColor);
                    FillRect(whichRect,blackPattern);
                    ForeColor(BlackColor);
                  end;
            end;
      end;
end;


procedure EcritPourquoiPasDePartieDansListe;
var unRect : rect;
    s : String255;
    couleurAffichageSousCritere : SInt32;
begin
  if gCassioUseQuartzAntialiasing
	  then
	    begin
	      DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));
	      EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),true);
	    end;
  with infosListeParties do
    begin
		  SetRect(unRect,0,hauteurRubanListe,GetWindowPortRect(wListePtr).right-15,GetWindowPortRect(wListePtr).bottom-hauteurPiedDePageListe);

		  if (nbPartiesChargees <= 0) then
		    begin
		      if (justificationPasDePartie <> 1) then
		        begin
				      Moveto(45,40);
				      s := ReadStringFromRessource(TextesListeID,1);
				      MyEraseRect(unRect);
				      MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
				      MyDrawString(s);
				      justificationPasDePartie := 1;
				    end;
		    end else
		  if (nbPartiesActives <= 0) and positionFeerique then
		    begin
		      if (justificationPasDePartie <> 3) then
		        begin
				      Moveto(45,40);
				      s := ReadStringFromRessource(TextesListeID,2);
				      MyEraseRect(unRect);
				      MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
				      MyDrawString(s);
				      Moveto(45,52);
				      s := ReadStringFromRessource(TextesListeID,3);
				      TextFace(italic);
				      MyDrawString(s);
				      TextFace(normal);
				      justificationPasDePartie := 3;
				    end;
		    end else
		  if (nbPartiesActives <= 0) and sousSelectionActive then
		    begin
		      if (justificationPasDePartie <> 4) then
		        begin
				      Moveto(45,40);
				      s := ReadStringFromRessource(TextesListeID,2);
				      MyEraseRect(unRect);
				      MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
				      MyDrawString(s);
				      Moveto(45,52);
				      s := ReadStringFromRessource(TextesListeID,4);
				      couleurAffichageSousCritere := BlueColor;
				      ForeColor(couleurAffichageSousCritere);
				      TextMode(1);
				      MyDrawString(s);
				      ForeColor(BlackColor);
				      justificationPasDePartie := 4;
				    end;
		    end else
		  if (nbPartiesActives <= 0) then
		    begin
		      if (justificationPasDePartie <> 2) then
		        begin
				      Moveto(45,40);
				      s := ReadStringFromRessource(TextesListeID,2);
				      MyEraseRect(unRect);
				      MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
				      MyDrawString(s);
				      justificationPasDePartie := 2;
				    end;
		    end else
		  if not(JoueursEtTournoisEnMemoire) then
		    begin
		      if (justificationPasDePartie <> 5) then
		        begin
				      Moveto(45,40);
				      s := ReadStringFromRessource(TextesListeID,5);
				      MyEraseRect(unRect);
				      MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
				      MyDrawString(s);
				      justificationPasDePartie := 5;
				    end;
		    end;
	end;

	if gCassioUseQuartzAntialiasing
	  then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false);
end;


procedure EcritListeParties(withCheckEvent : boolean; fonctionAppelante : String255);
var yPosition,compteur,nroPartie : SInt32;
    autreCoupQuatreDansPartie : boolean;
    premierCoup : SInt16;
    oldport : grafPtr;
    premierNumero,dernierNumero : SInt32;
    unRect,RectPourClip : rect;
    VisRect : rect;
    LimiteDroite : SInt32;
    oldclipRgn : RgnHandle;
    oldMagicCookie : SInt32;
    visibleRgn : RgnHandle;
    timer,timerDepart : UnsignedWide;
label sortie;
begin {$UNUSED fonctionAppelante}
 oldMagicCookie := DemandeCalculsPourBase.magicCookie;

 Microseconds(timer);
 timerDepart := timer;

 if windowListeOpen then
   with infosListeParties , DemandeCalculsPourBase do
	  begin
	    GetPort(oldport);
	    SetPortByWindow(wListePtr);

	    if gCassioUseQuartzAntialiasing
	      then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false)
	      else DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));


	    visibleRgn := NewRgn;
	    VisRect := MyGetRegionRect(GetWindowVisibleRegion(wListePtr,visibleRgn));
	    DisposeRgn(visibleRgn);

	    with GetWindowPortRect(wListePtr) do
	      SetRect(RectPourClip,right-15,top+hauteurRubanListe,right,bottom);
	    CalculeControlLongintMaximum(nbreLignesFntreListe);
	    if IsWindowHilited(wListePtr)
	      then
	        begin
	          MontrerAscenseurListe;
	          DessineBoiteDeTaille(wListePtr);
	        end
	      else
	        if SectRect(VisRect,RectPourClip,RectPourClip) then
	          begin
	            CacherAscenseurListe;
	            DessineBoiteTailleEtAscenseurDroite(wListePtr);
	          end;



	    with GetWindowPortRect(wListePtr) do
	      SetRect(RectPourClip,left,top+hauteurRubanListe,right-15,bottom-hauteurPiedDePageListe);

	    if SectRect(VisRect,RectPourClip,RectPourClip) then
	      begin
	        {WritelnNumDansRapport('EcritListeParties : oldMagicCookie = ',oldMagicCookie);
          WritelnDansRapport('   fonction appelante = '+fonctionAppelante);
	        WritelnNumDansRapport('--> EcritListeParties : ',oldMagicCookie);}

	        if (magicCookie <> oldMagicCookie) or not(windowListeOpen) then goto sortie;
	        if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		      if (magicCookie <> oldMagicCookie) or not(windowListeOpen) then goto sortie;

	        SetPortByWindow(wListePtr);
	        oldclipRgn := NewRgn;
	        GetClip(oldClipRgn);
	        ClipRect(RectPourClip);
	        LimiteDroite := GetWindowPortRect(wListePtr).right-15;
	        autreCoupQuatreDansPartie := false;
	        if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);

	        GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);


	        TextFont(gCassioApplicationFont);
	        TextSize(gCassioSmallFontSize);
	        TextFace(normal);
	        TextMode(srcOr);
	        if (nbPartiesActives <= 0) or (nbPartiesChargees <= 0) or not(JoueursEtTournoisEnMemoire)
	         then
	           EcritPourquoiPasDePartieDansListe
	         else
	          begin
	            for compteur := 0 to dernierNumero-premierNumero do
	             begin
	               if (magicCookie <> oldMagicCookie) or not(windowListeOpen) then goto sortie;
	               if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		             if (magicCookie <> oldMagicCookie) or not(windowListeOpen) then goto sortie;

	               SetPortByWindow(wListePtr);

	               nroPartie := tableNumeroReference^^[premierNumero+compteur];
	               yposition := compteur*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
	               SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),LimiteDroite,yposition+3);
	               EffacerRectanglePartieDansListe(unRect,nroPartie);

	               if PartieEstActive(nroPartie) then
	                  begin
	                    if (partieHilitee = premierNumero+compteur) or PartieEstDansLaSelection(nroPartie)
	                      then
	                        begin
	                          SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),LimiteDroite,yposition+3);
	                          HiliteRect(unRect);
	                        end;
	                    EcritPartieDansFenetreListe(nroPartie,autreCoupQuatreDansPartie,yposition);
	                  end;
	             end;
	           SetRect(unRect,0,yposition+3,LimiteDroite,GetWindowPortRect(wListePtr).bottom-hauteurPiedDePageListe);
	           MyEraseRect(unRect);
	           MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
	           InvalidateJustificationPasDePartieDansListe;
	         end;
	       SetClip(oldClipRgn);
	       DisposeRgn(oldclipRgn);

	       DessinePiedDePageFenetreListe;

	       sortie :
             {WritelnNumDansRapport('<-- EcritListeParties : ',oldMagicCookie);}



	     end;  {   if SectRect(VisRect,RectPourClip,RectPourClip)    }
	   ValidRect(RectPourClip);
	   SetPort(oldport);
	  end;  {with InfosListeParties}

	Microseconds(timer);
	{WriteStringAndBoolDansRapport('listeEtroiteEtNomsCourts = ',listeEtroiteEtNomsCourts);
	WritelnNumDansRapport('  ==>  temps en µsec = ',timer.lo - timerDepart.lo);}
end;


function  RisqueDeScrollIncorrect(toutDescend : boolean) : boolean;
var ok : boolean;
    ListeRect,PaletteRect,inter : rect;
    oldPort : grafPtr;
begin
  ok := true;
  {if (wListePtr <> FrontWindowSaufPalette) then ok := false;}
  if ok then
    begin
      GetPort(oldPort);
      SetPortByWindow(wListePtr);
      listeRect := QDGetPortBound;
      LocalToGlobal(ListeRect.topleft);
      LocalToGlobal(ListeRect.botright);
      if windowPaletteOpen then
        begin
          SetPortByWindow(wPalettePtr);
          PaletteRect := QDGetPortBound;
          LocalToGlobal(PaletteRect.topleft);
          LocalToGlobal(PaletteRect.botright);
          listeRect.right := listerect.right-15;  { ascenseur }
          listeRect.top := listerect.top+hauteurRubanListe;
          ok := not(SectRect(PaletteRect,ListeRect,inter));
          if ok = false then
            if ((PaletteRect.top    <= ListeRect.top) and not(toutDescend)) or
               ((PaletteRect.bottom >= ListeRect.Bottom) and toutDescend) then
               ok := true;
          SetPortByWindow(wListePtr);
        end;
      SetPort(oldPort);
    end;
  if ok and not(toutDescend) then
    if (ListeRect.bottom > GetScreenBounds.bottom) then ok := false;
  RisqueDeScrollIncorrect := not(ok);
end;

procedure ScrollEtEcritPartieVisibleListe(toutDescend,withCheckEvent : boolean);
var yPosition,compteur,nroPartie : SInt32;
    autreCoupQuatreDansPartie : boolean;
    premierCoup : SInt16;
    oldport : grafPtr;
    premierNumero,dernierNumero : SInt32;
    unRect,rectPourClip : rect;
    updateRgn,oldclipRgn : RgnHandle;
    numeroLigneaEcrire,LimiteDroite : SInt32;
    oldMagicCookie : SInt32;
    aux : SInt32;
label sortie;
begin  {$UNUSED withCheckEvent}
 oldMagicCookie := DemandeCalculsPourBase.magicCookie;
 {WritelnNumDansRapport('--> ScrollEtEcritPartieVisibleListe : ',oldMagicCookie);}

  if windowListeOpen and not(problemeMemoireBase) then
    with infosListeParties , DemandeCalculsPourBase do
	  begin
	    if not(gIsRunningUnderMacOSX) and RisqueDeScrollIncorrect(toutDescend)
	      then EcritListeParties(false,'ScrollEtEcritPartieVisibleListe')
	      else
	       begin
	        GetPort(oldport);
	        SetPortByWindow(wListePtr);

	        if gCassioUseQuartzAntialiasing
	          then EnableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr),false)
	          else DisableQuartzAntiAliasingThisPort(GetWindowPort(wListePtr));

	        if ascenseurListe <> NIL then
	          if IsWindowHilited(wListePtr)
	            then MontrerAscenseurListe
	            else CacherAscenseurListe;
	        DessineBoiteDeTaille(wListePtr);

	        with GetWindowPortRect(wListePtr) do
	          SetRect(RectPourClip,left,top+hauteurRubanListe,right-15,bottom-hauteurPiedDePageListe);
	        oldclipRgn := NewRgn;
	        GetClip(oldClipRgn);
	        ClipRect(RectPourClip);

	        LimiteDroite := GetWindowPortRect(wListePtr).right-15;
	        autreCoupQuatreDansPartie := false;
	        if nbreCoup >= 3 then ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
	        TextMode(SrcOr);
	        TextFont(gCassioApplicationFont);
	        TextFace(normal);
	        TextSize(gCassioSmallFontSize);
	        GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);
	        if (nbPartiesActives <= 0) or (nbPartiesChargees <= 0) or not(JoueursEtTournoisEnMemoire)
	         then
	           EcritPourquoiPasDePartieDansListe
	         else
	          begin
	            SetRect(unRect,0,hauteurRubanListe,LimiteDroite,GetWindowPortRect(wListePtr).bottom-hauteurPiedDePageListe);
	            if toutDescend
	              then
	                begin
	                  updateRgn := NewRgn;
	                  ScrollRect(unRect,0,HauteurChaqueLigneDansListe,updateRgn);
	                  DisposeRgn(updateRgn);
	                  numeroLigneaEcrire := 0;
	                end
	              else
	                begin
	                  updateRgn := NewRgn;
	                  ScrollRect(unRect,0,-HauteurChaqueLigneDansListe,updateRgn);
	                  DisposeRgn(updateRgn);
	                  numeroLigneaEcrire := dernierNumero-premierNumero;
	                end;


	            compteur := numeroLigneaEcrire;
	            nroPartie := tableNumeroReference^^[premierNumero+compteur];
	            yposition := compteur*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
	            SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),LimiteDroite,yposition+3);
	            EffacerRectanglePartieDansListe(unRect,nroPartie);

	            if (partieHilitee = premierNumero+numeroLigneaEcrire) or PartieEstDansLaSelection(tableNumeroReference^^[premierNumero+numeroLigneaEcrire])
	             then {dessin de la partie hilitee}
	               begin
	                 yposition := (numeroLigneaEcrire)*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
	                 SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),LimiteDroite,yposition+3);
	                 HiliteRect(unRect);
	               end;

	            if PartieEstActive(nroPartie) then
	               EcritPartieDansFenetreListe(nroPartie,autreCoupQuatreDansPartie,yposition);


	           for compteur := dernierNumero-premierNumero+1 to nbreLignesFntreListe+1 do
	             begin
	               yposition := compteur*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-3)+hauteurRubanListe;
	               SetRect(unRect,0,yposition-(HauteurChaqueLigneDansListe-3),LimiteDroite,yposition+3);
	               MyEraseRect(unRect);
	               MyEraseRectWithColor(unRect,OrangeCmd,blackPattern,'');
	             end;



	           {si la fenetre fait un pixel de moins que la normale, il faut rajouter une ligne surlignee d'un pixel de haut en surlignance}
             if not(toutDescend) then
               if ((partieHilitee = dernierNumero-1) or PartieEstDansLaSelection(tableNumeroReference^^[dernierNumero-1])) then
                 begin
                   (* note : the aux variable is necessary to avoid an internal bug in GNU Pascal :-( *)
                   aux := (HauteurChaqueLigneDansListe-1);
                   if ((GetWindowPortRect(wListePtr).bottom-hauteurRubanListe) mod HauteurChaqueLigneDansListe) = aux then
                     begin
                       yposition := (dernierNumero-1-premierNumero)*HauteurChaqueLigneDansListe+(HauteurChaqueLigneDansListe-1)+hauteurRubanListe;
                       SetRect(unRect,0,yposition,LimiteDroite,yposition+1);
                       HiliteRect(unRect);
                     end;
                 end;
	           InvalidateJustificationPasDePartieDansListe;
	         end;
	       SetClip(oldClipRgn);
	       DisposeRgn(oldclipRgn);

	       {DessinePiedDePageFenetreListe;}

	       {NoUpdateWindowListe);}
	       ValidRect(GetWindowPortRect(wListePtr));
	       SetPort(oldport);
	     end;
	  end;

  sortie :
     {WritelnNumDansRapport('<-- ScrollEtEcritPartieVisibleListe : ',oldMagicCookie);}
end;

procedure MontePartieHilitee(revenirAuDebut : boolean);
var anciennePartieHilitee : SInt32;
    premierNumero,dernierNumero,ancPosPouce : SInt32;
begin
  if (DemandeCalculsPourBase.etatDesCalculs = kCalculsTermines) then
   with infosListeParties do
    if windowListeOpen and ((partieHilitee >= 2) or revenirAuDebut) then
      begin
        if wListePtr <> FrontWindowSaufPalette then
          begin
            SelectWindowSousPalette(wListePtr);
            EcritRubanListe(false);
            EcritListeParties(false,'MontePartieHilitee(1)');
          end;
        anciennePartieHilitee := partieHilitee;
        if not(revenirAuDebut)
          then ChangePartieHilitee(anciennePartieHilitee-1,anciennePartieHilitee)
          else ChangePartieHilitee(1,anciennePartieHilitee);

        GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);

        if (premierNumero >= 2) and (partieHilitee <= premierNumero-1) then
          begin
            positionPouceAscenseurListe := partieHilitee;
            SetValeurAscenseurListe(positionPouceAscenseurListe);
            if (partieHilitee = premierNumero-1) and not(RevenirAuDebut)
              then ScrollEtEcritPartieVisibleListe(true,false)
              else EcritListeParties(false,'MontePartieHilitee(2)');
          end;

	    if (partieHilitee >= dernierNumero+1) then
          begin
            ancPosPouce := positionPouceAscenseurListe;
            positionPouceAscenseurListe := partieHilitee-nbreLignesFntreListe+1;
            SetValeurAscenseurListe(positionPouceAscenseurListe);
            if ancPosPouce <> positionPouceAscenseurListe then
              begin
                EcritListeParties(false,'MontePartieHilitee(3)');
              end;
          end;

      end;
end;

procedure DescendPartieHilitee(allerALaFin : boolean);
var anciennePartieHilitee : SInt32;
    premierNumero,dernierNumero,ancPosPouce : SInt32;
begin
  if (DemandeCalculsPourBase.etatDesCalculs = kCalculsTermines) then
   with infosListeParties do
    if windowListeOpen and ((partieHilitee <= nbPartiesActives-1) or allerALaFin) then
	    begin
	      if wListePtr <> FrontWindowSaufPalette then
	        begin
	          SelectWindowSousPalette(wListePtr);
	          EcritRubanListe(false);
	          EcritListeParties(false,'DescendPartieHilitee(1)');
	        end;
	      anciennePartieHilitee := partieHilitee;
	      if not(allerALaFin)
	        then ChangePartieHilitee(anciennePartieHilitee+1,anciennePartieHilitee)
	        else ChangePartieHilitee(nbPartiesActives,anciennePartieHilitee);

	      GetNumerosPremiereEtDernierePartiesAffichees(premierNumero,dernierNumero);

	      if (premierNumero >= 2) and (partieHilitee <= premierNumero-1) then
          begin
            positionPouceAscenseurListe := partieHilitee;
            SetValeurAscenseurListe(positionPouceAscenseurListe);
            EcritListeParties(false,'DescendPartieHilitee(2)');
          end;

	      if (partieHilitee >= dernierNumero+1) then
	        begin
	          ancPosPouce := positionPouceAscenseurListe;
	          positionPouceAscenseurListe := partieHilitee-nbreLignesFntreListe+1;
	          SetValeurAscenseurListe(positionPouceAscenseurListe);
	          if ancPosPouce <> positionPouceAscenseurListe then
	            begin
	              if (partieHilitee = dernierNumero+1) and not(allerALaFin)
	                then ScrollEtEcritPartieVisibleListe(false,false)
	                else EcritListeParties(false,'DescendPartieHilitee(3)');
	            end;
	        end;
	    end;
end;



procedure ConstruitTableNumeroReference(infosDejaCalculees,withCheckEvent : boolean);
var i,compteur,indexDepart,numPartie : SInt32;
    etat,nbreInfoGardable,nroReference : SInt32;
    oldMagicCookie : SInt32;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
    premierCoup : SInt16;
    s60 : PackedThorGame;
label sortie;
begin
  {$UNUSED withCheckEvent}

  if not(problemeMemoireBase) then
    BEGIN

		  oldMagicCookie := DemandeCalculsPourBase.magicCookie;

		  with DemandeCalculsPourBase do
		    begin
  			  etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
  			  if infosDejaCalculees and ListePartiesEstGardeeDansLeCache(nbreCoup,etat)
  			    then
  			      begin
  			        if (etat = PasDePartieActive)
  			          then
  			            begin
  			              nbPartiesActives := 0;
  			              tableNumeroReference^^[0] := 0;
  			            end
  			          else
  			            begin
  			              nbPartiesActives := etat;
  			              tableNumeroReference^^[0] := nbPartiesActives;
  			              indexDepart := IndexInfoDejaCalculeesCoupNro^^[nbreCoup-1];
  			              for i := 1 to nbPartiesActives do
  			                tableNumeroReference^^[i] := TableInfoDejaCalculee^^[indexDepart+i];

  			              {verification de l'exactitude de l'ancienne info}
  			              nroReference := tableNumeroReference^^[1];
  					          ExtraitPartieTableStockageParties(nroReference,s60);
  					          ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
  					          ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
  					          TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie and ouvertureDiagonale,4,60);

  					          if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60)))
  						        then
  						          begin
  						            WritelnDansRapport('WARNING : not(positionsSontEgales) dans ConstruitTableNumeroReference');
  						            InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
  						            LanceNouvelleDemandeCalculsPourBase(false,true);
  						            exit;
  						          end;
  			            end;
  			      end
  			    else
  			      begin
  			        {WritelnNumDansRapport('--> ConstruitTableNumeroReference : ',oldMagicCookie);
  			        WritelnNumDansRapport('nbPartiesChargees = ',nbPartiesChargees);}

  			        compteur := 0;
  			        if OrdreDuTriRenverse
  			          then
  			            for i := nbPartiesChargees downto 1 do
  			              begin
  			                numPartie := tableTriListe^^[i];
  			                if PartieEstActive(numPartie) then
  			                  begin
  			                    compteur := compteur+1;
  			                    tableNumeroReference^^[compteur] := numPartie;
  			                  end;
  			              end
  			          else
  			            for i := 1 to nbPartiesChargees do
  			              begin
  			                numPartie := tableTriListe^^[i];
  			                if PartieEstActive(numPartie) then
  			                  begin
  			                    compteur := compteur+1;
  			                    tableNumeroReference^^[compteur] := numPartie;
  			                  end;
  			              end;
  			        nbPartiesActives := compteur;
  			        tableNumeroReference^^[0] := compteur;

  			        nbreInfoGardable := IndexInfoDejaCalculeesCoupNro^^[nbreCoup]-IndexInfoDejaCalculeesCoupNro^^[nbreCoup-1];

  			        if (compteur <= 0) then
  			          SetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup,PasDePartieActive);

  			        if (compteur > nbreInfoGardable) then
  			          SetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup,compteur);

  			        if (compteur >= 1) and (compteur <= nbreInfoGardable) then
  			          begin
  			            SetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup,compteur);
  			            indexDepart := IndexInfoDejaCalculeesCoupNro^^[nbreCoup-1];
  			            for i := 1 to compteur do
  			              TableInfoDejaCalculee^^[indexDepart+i] := tableNumeroReference^^[i];
  			          end;

  			       sortie :
  			         {WritelnNumDansRapport('<-- ConstruitTableNumeroReference : ',oldMagicCookie);}

  			    end;
			end; {with DemandeCalculsPourBase do}

	END;
end;

procedure EcritTableCompatible;
var oldport : grafPtr;
    i,yposition : SInt32;
    test : boolean;
    oldMagicCookie : SInt32;
label sortie;
begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnNumDansRapport('--> EcritTableCompatible : ',oldMagicCookie);}

  with DemandeCalculsPourBase do
    begin
	  if windowPlateauOpen then
		  begin
		    GetPort(oldport);
		    SetPortByWindow(wPlateauPtr);
		    for i := 1 to 1000 do
		      begin
		        yposition := (i mod 25)*10+20;
		        test := PartieEstCompatibleParCriteres(i);
		        if test
		          then WriteNumAt('TRUE  ',i,10,yposition)
		          else WriteNumAt('FALSE ',i,10,yposition);
		        if i mod 25 = 0 then AttendFrappeClavier;
		      end;
		    SetPort(oldport);

		    sortie :
		      {WritelnNumDansRapport('<-- EcritTableCompatible : ',oldMagicCookie);}

		  end;
	end; {with DemandeCalculsPourBase}
end;


procedure RecopierPartiesCompatiblesCommePartiesActives;
var n : SInt32;
begin
  for n := 1 to nbPartiesChargees do
	  SetPartieActive(n,PartieEstCompatibleParCriteres(n));
end;


procedure ConstruitTablePartiesActivesSansInter(partie60 : PackedThorGame; withCheckEvent : boolean);
var s60 : PackedThorGame;
    n,nroReference : SInt32;
    t : SInt32;
    oldMagicCookie : SInt32;
    nbNoirsReelsCherches : SInt16;
    typeErreur : SInt32;
label sortie;
begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnNumDansRapport('--> ConstruitTablePartiesActivesSansInter : ',oldMagicCookie);}

  with DemandeCalculsPourBase do
    begin
	  if (nbreCoup <= 1)
	   then
	    begin
	      for n := 1 to nbPartiesChargees do
	          SetPartieActive(n,PartieEstCompatibleParCriteres(n));
	      {for n := nbPartiesChargees+1 to nbrePartiesEnMemoire do
	          SetPartieActive(n,false);}
	    end
	   else
	    begin
	      if (nbreCoup >= 60)
	        then nbNoirsReelsCherches := NbPionsDeCetteCouleurApresCeCoup(partie60,pionNoir,60,typeErreur)
	        else nbNoirsReelsCherches := -1;

	      for nroReference := 1 to nbPartiesChargees do
	        begin
	          if magicCookie <> oldMagicCookie then goto sortie;
	          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		      if magicCookie <> oldMagicCookie then goto sortie;

	          if not(PartieEstCompatibleParCriteres(nroReference)) or
	             ((nbNoirsReelsCherches >= 0) and (nbNoirsReelsCherches <> GetScoreReelParNroRefPartie(nroReference)))
	            then
	              SetPartieActive(nroReference,false)
	            else
	              begin
	                ExtraitPartieTableStockageParties(nroReference,s60);

	                SET_NTH_MOVE_OF_PACKED_GAME(s60, 1, 200);      {sentinelle que l'on peut mettre à la place de F5}

	                t := nbreCoup;
	                while (GET_NTH_MOVE_OF_PACKED_GAME(s60, t,'ConstruitTablePartiesActivesSansInter(1)') =
	                       GET_NTH_MOVE_OF_PACKED_GAME(partie60, t,'ConstruitTablePartiesActivesSansInter(2)')) do
	                  dec(t);

	                SetPartieActive(nroReference,(t = 1));
	              end;
	        end;
	    end;
	  sortie :
	     {WritelnNumDansRapport('<-- ConstruitTablePartiesActivesSansInter : ',oldMagicCookie);}

   end;  {with DemandeCalculsPourBase do}
end;

procedure ConstruitTablePartiesActivesAvecInter(partie60 : PackedThorGame; withCheckEvent : boolean);
var s60 : PackedThorGame;
    n,nroReference : SInt32;
    t : SInt32;
    oldMagicCookie : SInt32;
    nbNoirsReelsCherches : SInt16;
    typeErreur : SInt32;
label sortie;
begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnNumDansRapport('--> ConstruitTablePartiesActivesAvecInter : ',oldMagicCookie);}

  with DemandeCalculsPourBase do
    begin
	  if (nbreCoup <= 1)
	   then
	    begin
	      for n := 1 to nbPartiesChargees do
	          SetPartieActive(n,PartieEstCompatibleParCriteres(n));
	      {for n := nbPartiesChargees+1 to nbrePartiesEnMemoire do
	          SetPartieActive(n,false);}
	    end
	   else
	    begin
	      if (nbreCoup >= 60)
	        then nbNoirsReelsCherches := NbPionsDeCetteCouleurApresCeCoup(partie60,pionNoir,60,typeErreur)
	        else nbNoirsReelsCherches := -1;

	      for nroReference := 1 to nbPartiesChargees do
	        begin
	          if magicCookie <> oldMagicCookie then goto sortie;
	          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		        if magicCookie <> oldMagicCookie then goto sortie;

	          if not(PartieEstCompatibleParCriteres(nroReference)) or
	             ((nbNoirsReelsCherches >= 0) and (nbNoirsReelsCherches <> GetScoreReelParNroRefPartie(nroReference)))
	            then
	              SetPartieActive(nroReference,false)
	            else
	              begin
	                ExtraitPartieTableStockageParties(nroReference,s60);
	                TraiteInterversionFormatThorCompile(s60);

	                SET_NTH_MOVE_OF_PACKED_GAME(s60, 1, 200);      {sentinelle que l'on peut mettre à la place de F5}

	                t := nbreCoup;
	                while (GET_NTH_MOVE_OF_PACKED_GAME(s60, t,'ConstruitTablePartiesActivesAvecInter(1)') =
	                       GET_NTH_MOVE_OF_PACKED_GAME(partie60, t,'ConstruitTablePartiesActivesAvecInter(2)')) do
	                  dec(t);

	                SetPartieActive(nroReference,(t = 1));
	              end;
	        end;
	    end;
	  sortie :
	     {WritelnNumDansRapport('<-- ConstruitTablePartiesActivesAvecInter : ',oldMagicCookie);}

   end; {with DemandeCalculsPourBase do}
end;

procedure ConstruitTablePartiesActivesAvecToutesInter(partie60 : PackedThorGame; withCheckEvent : boolean);
var s60 : PackedThorGame;
    n,nroReference : SInt32;
    t : SInt32;
    ignored : boolean;
    CasesRemplies : plBool;
    positionPartie,positionDepart,positionTestee : plateauOthello;
    coup,coulTrait,traitPartie,traitPartieTestee : SInt32;
    listeCasesRemplies : array[0..64] of SInt32;
    listeCasesVides : array[0..64] of SInt32;
    nbreCasesRemplies : SInt32;
    nbreCasesVides : SInt32;
    oldMagicCookie : SInt32;
    nbNoirsReelsCherches : SInt16;
    typeErreur : SInt32;
    borneSupCasesVidesVerifiees : SInt32;
    {compteurDebug : SInt32;}
label sortie, fin_de_boucle;


    function DoitPasserDansPositionTestee(couleur : SInt32) : boolean;
		var a,x,dx,t,adversaire,n : SInt32;
		begin
		  adversaire := -couleur;
		  for n := 1 to nbreCasesVides do
		    begin
		      a := listeCasesVides[n];
	        for t := dirPriseDeb[a] to dirPriseFin[a] do
	          begin
	            dx := dirPrise[t];
	            x := a+dx;
	            if positionTestee[x] = adversaire then
	              begin
	                repeat
	                  x := x+dx;
	                until positionTestee[x] <> adversaire;
	                if (positionTestee[x] = couleur) then
	                  begin
	                    DoitPasserDansPositionTestee := false;
	                    exit
	                  end;
	              end;
	          end;
		    end;
		  DoitPasserDansPositionTestee := true;
		end;




begin
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnNumDansRapport('--> ConstruitTablePartiesActivesAvecToutesInter : ',oldMagicCookie);}

  with DemandeCalculsPourBase do
    begin

	  if (nbreCoup <= 1)
	   then
	    begin
	      for n := 1 to nbPartiesChargees do
	          SetPartieActive(n,PartieEstCompatibleParCriteres(n));
	      {for n := nbPartiesChargees+1 to nbrePartiesEnMemoire do
	          SetPartieActive(n,false);}
	    end
	   else
	    begin
	      if (nbreCoup >= 60)
	        then nbNoirsReelsCherches := NbPionsDeCetteCouleurApresCeCoup(partie60,pionNoir,60,typeErreur)
	        else nbNoirsReelsCherches := -1;

	      if magicCookie <> oldMagicCookie then goto sortie;
	      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		    if magicCookie <> oldMagicCookie then goto sortie;


	      MemoryFillChar(@positionDepart,sizeof(positionDepart),chr(0));
	      for t := 0 to 99 do
	        if interdit[t] then positionDepart[t] := PionInterdit;
	      positionDepart[44] := pionBlanc;
	      positionDepart[55] := pionNoir;
	      positionDepart[45] := pionNoir;
	      positionDepart[54] := pionNoir;
	      positionDepart[56] := pionNoir;
	      nbreCasesRemplies := 5;
	      listeCasesRemplies[0] := 0;
	      listeCasesRemplies[1] := 44;
	      listeCasesRemplies[2] := 45;
	      listeCasesRemplies[3] := 54;
	      listeCasesRemplies[4] := 55;
	      listeCasesRemplies[5] := 56;

	      MemoryFillChar(@casesRemplies,sizeof(casesRemplies),chr(0));
	      for t := 2 to Min(nbreCoup, GET_LENGTH_OF_PACKED_GAME(partie60)) do   { on laisse F5 vide pour servir de sentinelle }
	        begin
	          casesremplies[GET_NTH_MOVE_OF_PACKED_GAME(partie60,t,'ConstruitTablePartiesActivesAvecToutesInter(1)')] := true;
	          inc(nbreCasesRemplies);
	          listeCasesRemplies[nbreCasesRemplies] := GET_NTH_MOVE_OF_PACKED_GAME(partie60,t,'ConstruitTablePartiesActivesAvecToutesInter(2)');
	        end;

	      nbreCasesVides := 0;
	      for t := 1 to 60 do
	        if not(casesremplies[othellier[t]]) and (othellier[t] <> 56) then
	          begin
	            inc(nbreCasesVides);
	            listeCasesVides[nbreCasesVides] := othellier[t];
	          end;
	      if (nbreCoup > 35)
	        then borneSupCasesVidesVerifiees := Min(60,nbreCoup + 6)
	        else borneSupCasesVidesVerifiees := -1;

	      positionPartie := positionDepart;
	      coulTrait := pionBlanc;
	      for t := 2 to Min(nbreCoup, GET_LENGTH_OF_PACKED_GAME(partie60)) do
	        begin
	          coup := GET_NTH_MOVE_OF_PACKED_GAME(partie60,t,'ConstruitTablePartiesActivesAvecToutesInter(3)');
	          if ModifPlatSeulement(coup,positionPartie,coulTrait)
	            then coulTrait := -coulTrait
	            else ignored := ModifPlatSeulement(coup,positionPartie,-coulTrait);
	        end;

	      traitPartie := coulTrait;
	      if (nbreCoup >= 60) or DoitPasserPlatSeulement(traitPartie,positionPartie) then
	        if (nbreCoup >= 60) or DoitPasserPlatSeulement(-traitPartie,positionPartie)
	          then traitPartie := pionVide
	          else traitPartie := -traitPartie;


	      positionPartie[0] := pionVide;  {sentinelle correspondant à listeCasesRemplies[0]}
	      for nroReference := 1 to nbPartiesChargees do
	        begin
	          if magicCookie <> oldMagicCookie then goto sortie;
	          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		        if magicCookie <> oldMagicCookie then goto sortie;

	          if not(PartieEstCompatibleParCriteres(nroReference))
	             or ((nbNoirsReelsCherches >= 0) and (nbNoirsReelsCherches <> GetScoreReelParNroRefPartie(nroReference)))
	            then
	              begin
	                SetPartieActive(nroReference,false);
	                (* WritelnDansRapport('SetPartieActive(nroReference,false) {1}'); *)
	              end
	            else
	              begin
	                ExtraitPartieTableStockageParties(nroReference,s60);

	                {on teste si les coups vides juste apres nbreCoup sont bien sur des cases vides}
                  for t := nbreCoup+1 to borneSupCasesVidesVerifiees do
                    begin
                      if casesremplies[GET_NTH_MOVE_OF_PACKED_GAME(s60,t,'ConstruitTablePartiesActivesAvecToutesInter(3 bis)')] then
                         begin
                           SetPartieActive(nroReference,false);
                           (* WritelnDansRapport('SetPartieActive(nroReference,false) {2}'); *)
                           goto fin_de_boucle;
                         end;
                    end;

                  {on teste si les coups vides jusqu'a nbreCoup sont bien sur des cases pleines}
                  t := nbreCoup;
      	          while casesremplies[GET_NTH_MOVE_OF_PACKED_GAME(s60,t,'ConstruitTablePartiesActivesAvecToutesInter(4)')] do
      	            dec(t);

	                if (t > 1)
	                  then
	                    begin
	                      SetPartieActive(nroReference,false);  {cases occupees differentes => positions differentes}
	                      (* WritelnDansRapport('SetPartieActive(nroReference,false) {3}'); *)
	                    end
	                  else
	                    begin
	                      TraiteInterversionFormatThorCompile(s60);

	                      SET_NTH_MOVE_OF_PACKED_GAME(s60, 1, 200);      {sentinelle que l'on peut mettre à la place de F5}

	                      t := nbreCoup;
	                      while (GET_NTH_MOVE_OF_PACKED_GAME(s60, t,'ConstruitTablePartiesActivesAvecToutesInter(5)') =
	                             GET_NTH_MOVE_OF_PACKED_GAME(partie60, t,'ConstruitTablePartiesActivesAvecToutesInter(6)')) do
	                        dec(t);

	                      if (t = 1)
	                        then   {memes coups joues => meme position}
	                          SetPartieActive(nroReference,true)
	                        else
	                          begin
	                            {les memes cases ont ete occupees, a-t-on une interversion ?}

	                            positionTestee := positionDepart;
	                            coulTrait := pionBlanc;

	                            for t := 2 to nbreCoup do
	                              begin
	                                coup := GET_NTH_MOVE_OF_PACKED_GAME(s60,t,'ConstruitTablePartiesActivesAvecToutesInter(7)');
	                                if ModifPlatSeulement(coup,positionTestee,coulTrait)
	                                  then coulTrait := -coulTrait
	                                  else ignored := ModifPlatSeulement(coup,positionTestee,-coulTrait);
	                              end;

	                            t := nbreCasesRemplies;
	                            repeat
	                              coup := listeCasesRemplies[t];
	                              dec(t);
	                            until (positionTestee[coup] <> positionPartie[coup]);

	                            if (t <= -1)
	                              then
	                                begin
	                                  {meme position, il faut encore verifier que l'on a le meme trait}

	                                  traitPartieTestee := coulTrait;
															      if DoitPasserDansPositionTestee(traitPartieTestee) then
															        if DoitPasserDansPositionTestee(-traitPartieTestee)
															          then traitPartieTestee := pionVide
															          else traitPartieTestee := -traitPartieTestee;

	                                  if (traitPartieTestee <> traitPartie)
	                                    then
	                                      begin
	                                        SetPartieActive(nroReference,false);
	                                        (* WritelnDansRapport('SetPartieActive(nroReference,false) {4}'); *)
	                                      end
	                                    else
	                                      begin  {meme position et meme trait, on a une vraie interversion}
				                                  SetPartieActive(nroReference,true);
				                                  nbreInterAlaVolee := 1;
				                                  gInterVarianteAlaVolee := nroReference;
				                                end;
	                                end
	                              else
	                                begin
	                                  SetPartieActive(nroReference,false);
	                                  (* WritelnDansRapport('SetPartieActive(nroReference,false) {5}'); *)
	                                end;
	                          end;
	                    end;
	              end;
	          fin_de_boucle :
	        end;
	    end;
	  sortie :

	     {compteurDebug := 0;
	     for nroReference := 1 to nbPartiesChargees do
	       if PartieEstActive(nroReference) then inc(compteurDebug);
	     WritelnNumDansRapport('nombre de parties actives  : ',compteurDebug);
	     WritelnNumDansRapport('<-- ConstruitTablePartiesActivesAvecToutesInter : ',oldMagicCookie);
	     }
   end;
end;


procedure EssayerTrouverPartiesActivesParInterversionsDeFinale;
var partieDansListe : String255;
    nbreCoupsSemblables,nroReference : SInt32;
    dernierePartieEnMemoire : String255;
    erreur : SInt32;
    myPosition : PositionEtTraitRec;
begin
  if (nbreCoup >= 57) then
    begin
     dernierePartieEnMemoire := DernierePartieCompatibleEnMemoire(nbreCoupsSemblables,nroReference);

     if (dernierePartieEnMemoire <> '') and
        (nbreCoupsSemblables >= 4) then
        begin

          partieDansListe := GetPartieEnAlphaDapresListe(nroReference,nbreCoup);

          myPosition := PositionEtTraitAfterMoveNumberAlpha(partieDansListe,nbreCoup,erreur);

          if EstLaPositionCourante(myPosition)
            then SetPartieActive(nroReference,true);

        end;
  end;
end;


procedure ConstruitTablePartiesActives(infosDejaCalculees : boolean; withCheckEvent : boolean);
var partie120 : String255;
    partie60 : PackedThorGame;
    limiteInterversion : SInt32;
    etat,i : SInt32;
    indexdepart : SInt32;
    nbrecoupArrivee : SInt16;
    oldMagicCookie : SInt32;
    tick : SInt32;
    diagonaleInversee : boolean;
label sortie,finNormale;
begin
  {if debuggage.general then EcritTableCompatible;}
  oldMagicCookie := DemandeCalculsPourBase.magicCookie;
  {WritelnNumDansRapport('--> ConstruitTablePartiesActives : ',oldMagicCookie);}

  tick := TickCount;

  nbrecoupArrivee := nbreCoup;
  with DemandeCalculsPourBase do
   begin
    if magicCookie <> oldMagicCookie then goto sortie;
	  if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
	  if magicCookie <> oldMagicCookie then goto sortie;

	  etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);
	  if infosDejaCalculees and ListePartiesEstGardeeDansLeCache(nbreCoup,etat)
	    then
	      begin
	        if (etat = PasDePartieActive)
	          then
	            DesactiverToutesLesParties
	          else
	            begin
	              DesactiverToutesLesParties;
	              indexDepart := IndexInfoDejaCalculeesCoupNro^^[nbreCoup-1];
	              for i := 1 to etat do
	                SetPartieActive(TableInfoDejaCalculee^^[indexDepart+i],true);
	            end;
	      end
	    else
	      begin
	        if magicCookie <> oldMagicCookie then goto sortie;
	        if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		      if magicCookie <> oldMagicCookie then goto sortie;

	        if avecInterversions
	          then
	            begin
	              if nbreCoup <= 33
	                then limiteInterversion := nbreCoup
	                else limiteInterversion := 33;
	              partie120 := PartieNormalisee(diagonaleInversee,false);
	              TraductionAlphanumeriqueEnThor(partie120,partie60);


	              {
	              WritelnDansRapport('Appel de PrecompileInterversions dans ConstruitTablePartiesActives');
	              WRITELN_PACKED_GAME_DANS_RAPPORT('dans ConstruitTablePartiesActives, partie60 = ',partie60);
	              }

	              PrecompileInterversions(partie60,limiteInterversion);


	              if magicCookie <> oldMagicCookie then goto sortie;
	              if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		            if magicCookie <> oldMagicCookie then goto sortie;

	              if (nbreCoup > 4) and (nbreCoup < 58)
	                then
	                  begin
	                    nbreInterAlaVolee := 0;

	                    {WritelnDansRapport('Appel de ConstruitTablePartiesActivesAvecToutesInter dans ConstruitTablePartiesActives');}

	                    ConstruitTablePartiesActivesAvecToutesInter(partie60,withCheckEvent);

	                    if magicCookie <> oldMagicCookie then goto sortie;
	                    if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		                  if magicCookie <> oldMagicCookie then goto sortie;

	                    if (nbreInterAlaVolee > 0) then
	                      AjouterInterversionAlaVolee(GetPartieTableStockageParties(gInterVarianteAlaVolee),partie60,nbreCoup,GetCurrentNode);
	                  end
	                else
	                 if (NbinterversionsCompatibles <= 0)
	                   then
	                     begin
	                       if magicCookie <> oldMagicCookie then goto sortie;
	                       if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		                     if magicCookie <> oldMagicCookie then goto sortie;

                         {WritelnDansRapport('Appel de ConstruitTablePartiesActivesSansInter dans ConstruitTablePartiesActives');}

	                       ConstruitTablePartiesActivesSansInter(partie60,withCheckEvent);
	                     end
	                   else
	                     begin
	                       if magicCookie <> oldMagicCookie then goto sortie;
	                       if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		                     if magicCookie <> oldMagicCookie then goto sortie;

                         {WritelnDansRapport('Appel de ConstruitTablePartiesActivesAvecInter dans ConstruitTablePartiesActives');}

	                       ConstruitTablePartiesActivesAvecInter(partie60,withCheckEvent);
	                     end;

	              EssayerTrouverPartiesActivesParInterversionsDeFinale;
	            end
	          else
	            begin
	              partie120 := PartieNormalisee(diagonaleInversee,false);
	              TraductionAlphanumeriqueEnThor(partie120,partie60);

	              if magicCookie <> oldMagicCookie then goto sortie;
	              if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		            if magicCookie <> oldMagicCookie then goto sortie;

	              ConstruitTablePartiesActivesSansInter(partie60,withCheckEvent);

	              if magicCookie <> oldMagicCookie then goto sortie;
	              if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
		            if magicCookie <> oldMagicCookie then goto sortie;

	            end;
	       end;
	end; {with DemandeCalculsPourBase do}

	{derniere passe : les parties qui ont été détruites dans la liste par l'utilisateur
	 ne peuvent être actives, évidement !}
	for i := 1 to nbPartiesChargees do
	  if PartieDeLaListeEstDetruite(i) then SetPartieActive(i,false);


  goto finNormale;

sortie :
  begin
    InvalidateNombrePartiesActivesDansLeCache(nbreCoupArrivee);
  end;

finNormale :
  {WritelnNumDansRapport('<-- ConstruitTablePartiesActives : ',oldMagicCookie);}

  tick := TickCount-tick;
  {WritelnNumDansRapport('ConstruitTablePartiesActives('+IntToStr(nbreCoup)+') = ',tick);}
end;


function CassioEstEnTrainDeCalculerLaListe : boolean;
begin
  CassioEstEnTrainDeCalculerLaListe := (DemandeCalculsPourBase.NiveauRecursionCalculsEtAffichagePourBase > 0);
end;


procedure CalculsEtAffichagePourBase(infosDejaCalculees : boolean; withCheckEvent : boolean);
var oldMagicCookie : SInt32;
    nbrecoupArrivee : SInt16;
    ticks : SInt32;
label sortie,finNormale;
begin
  if AutorisationCalculsLongsSurListe then
    begin

      ticks := TickCount;
      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : avant IncrementeMagicCookieDemandeCalculsBase ',0);AttendFrappeClavier;}

      IncrementeMagicCookieDemandeCalculsBase;
      oldMagicCookie := DemandeCalculsPourBase.magicCookie;
      {WritelnNumDansRapport('--> CalculsEtAffichagePourBase : ',oldMagicCookie);}

      if not(problemeMemoireBase) then
        BEGIN
    		  nbrecoupArrivee := nbreCoup;
    		  with DemandeCalculsPourBase do
    		    begin
    		      DemandeCalculsPourBase.etatDesCalculs := kCalculsEnCours;

    		      {WritelnNumDansRapport('--> rec = ',NiveauRecursionCalculsEtAffichagePourBase);}
    		      inc(NiveauRecursionCalculsEtAffichagePourBase);
    		      if (NiveauRecursionCalculsEtAffichagePourBase > 30) or PhaseDecroissanceRecursion or (nbPartiesChargees <= 0) then
    		        begin
    		          withCheckEvent := false;
    		          PhaseDecroissanceRecursion := true;
    		        end;

    		      AjusteSleep;

      			  if positionFeerique
      			   then
      			    begin
      			      nbPartiesActives := 0;
      			      InvalidateNombrePartiesActivesDansLeCache(nbreCoup);

      			      if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      if windowStatOpen  then EcritStatistiques(false);

      			      if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      if windowListeOpen then EcritListeParties(false,'CalculsEtAffichagePourBase(1)');

      			    end
      			   else
      			    begin

      			      {if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      if windowListeOpen then NroHilite2NroReference(infosListeParties.partieHilitee,NumeroReferencePartieHilitee);
      			      }

      			      if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      ConstruitTablePartiesActives(infosDejaCalculees,withCheckEvent);
      			      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après ConstruitTablePartiesActives, nbPartiesActives = ',nbPartiesActives);AttendFrappeClavier;}

      			      if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      ConstruitTableNumeroReference(infosDejaCalculees,withCheckEvent);
      			      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après ConstruitTableNumeroReference , nbPartiesActives = ',nbPartiesActives);AttendFrappeClavier;}

      			      if magicCookie <> oldMagicCookie then goto sortie;
      			      if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				    if magicCookie <> oldMagicCookie then goto sortie;

      			      if windowStatOpen then
      			        begin
      			          if magicCookie <> oldMagicCookie then goto sortie;
      			          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				        if magicCookie <> oldMagicCookie then goto sortie;

      			          ConstruitStatistiques(withCheckEvent);
      			          {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après ConstruitStatistiques ',0);AttendFrappeClavier;}

      			          if magicCookie <> oldMagicCookie then goto sortie;
      			          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				        if magicCookie <> oldMagicCookie then goto sortie;

      			          EcritStatistiques(false);
      			          {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après EcritStatistiques ',0);AttendFrappeClavier;}

      			          if magicCookie <> oldMagicCookie then goto sortie;
      			          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				        if magicCookie <> oldMagicCookie then goto sortie;
      			        end;

      			      if windowListeOpen then
      			        begin
      			          if magicCookie <> oldMagicCookie then goto sortie;
      			          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				        if magicCookie <> oldMagicCookie then goto sortie;

      			          AjustePouceAscenseurListe(false);
      			          {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après AjustePouceAscenseurListe ',0);AttendFrappeClavier;}
      			          NroReference2NroHilite(infosListeParties.dernierNroReferenceHilitee,infosListeParties.partieHilitee);
      			          {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après NroReference2NroHilite ',0);AttendFrappeClavier;}
      			          EcritListeParties(false,'CalculsEtAffichagePourBase(2)');
      			          {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après EcritListeParties ',0);AttendFrappeClavier;}

      			          if magicCookie <> oldMagicCookie then goto sortie;
      			          if (TickCount <> dernierTickPourCheckEventDansCalculsBase) and withCheckEvent then CheckEventPendantCalculsBase;
      				        if magicCookie <> oldMagicCookie then goto sortie;

      				        NroHilite2NroReference(infosListeParties.partieHilitee,infosListeParties.dernierNroReferenceHilitee);
      				        {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après NroHilite2NroReference ',0);AttendFrappeClavier;}

      			        end;

      			      if magicCookie <> oldMagicCookie then goto sortie;

      				    {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : avant EssayerConstruireTitrePartie ',0);AttendFrappeClavier;}
      		        EssayerConstruireTitrePartie;
      			      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après EssayerConstruireTitrePartie ',0);AttendFrappeClavier;}

      			    end;
      			  if magicCookie <> oldMagicCookie then goto sortie;

      		    DemandeCalculsPourBase.etatDesCalculs := kCalculsTermines;
      		    {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : avant FixeMarqueSurMenuBase ',0);AttendFrappeClavier;}
      		    FixeMarqueSurMenuBase;
      			  {WritelnNumDansRapport('dans CalculsEtAffichagePourBase : après FixeMarqueSurMenuBase ',0);AttendFrappeClavier;}
      			  if gameOver then TachesUsuellesPourGameOver;

    		    end;  {with DemandCalculsBase}


    		  goto finNormale;

    		  sortie :
    		    begin
    		      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase (sortie) : avant InvalidateNombrePartiesActivesDansLeCache ',0);AttendFrappeClavier;}
    		      InvalidateNombrePartiesActivesDansLeCache(nbreCoupArrivee);
    		      {WritelnNumDansRapport('dans CalculsEtAffichagePourBase (sortie) : après InvalidateNombrePartiesActivesDansLeCache ',0);AttendFrappeClavier;}
    		    end;

    		  finNormale :
    		    with DemandeCalculsPourBase do
    		      begin
    		        {WritelnNumDansRapport('dans CalculsEtAffichagePourBase (finNormale) : avant PhaseDecroissanceRecursion ',0);AttendFrappeClavier;}

    		        dec(NiveauRecursionCalculsEtAffichagePourBase);
    		        if PhaseDecroissanceRecursion and (NiveauRecursionCalculsEtAffichagePourBase < 1) then
    		          PhaseDecroissanceRecursion := false;

    		        {WritelnNumDansRapport('dans CalculsEtAffichagePourBase (finNormale) : apres PhaseDecroissanceRecursion ',0);AttendFrappeClavier;}
    		         {WritelnNumDansRapport('<-- rec = ',NiveauRecursionCalculsEtAffichagePourBase);}
    		      end;
    		    {WritelnNumDansRapport('<-- CalculsEtAffichagePourBase : ',oldMagicCookie);}

    	  END;

    	{WritelnNumDansRapport('temps en ticks = ',TickCount - ticks);}
    end;
end;

procedure IncrementeMagicCookieDemandeCalculsBase;
begin
  inc(DemandeCalculsPourBase.magicCookie);
end;


procedure LanceNouvelleDemandeCalculsPourBase(infosDejaCalculees,withCheckEvent : boolean);
begin
  IncrementeMagicCookieDemandeCalculsBase;
  with DemandeCalculsPourBase do
    begin
      NumeroDuCoupDeLaDemande := nbreCoup;
      EtatDesCalculs := kCalculsDemandes;
      bInfosDejaCalcules := infosDejaCalculees;
      bWithCheckEvent := withCheckEvent;
    end;
  if not(infosDejaCalculees) then
    InvalidateNombrePartiesActivesDansLeCache(nbreCoup);
end;

procedure LanceCalculsRapidesPourBaseOuNouvelleDemande(infosDejaCalculees,withCheckEvent : boolean);
var etat,nroReference,indexDepart : SInt32;
    s60 : PackedThorGame;
    premierCoup : SInt16;
    autreCoupQuatreDansPartie : boolean;
    ouvertureDiagonale : boolean;
begin
  if (nbreCoup < 0) or (nbreCoup > 60) or positionFeerique
    then
      begin
        LanceNouvelleDemandeCalculsPourBase(infosDejaCalculees,withCheckEvent);
      end
    else
      begin
        etat := GetNombreDePartiesActivesDansLeCachePourCeCoup(nbreCoup);

  	    if not(infosDejaCalculees) or (etat = NeSaitPasNbrePartiesActives) or
  	       not(ListePartiesEstGardeeDansLeCache(nbreCoup,etat)) then
  	       begin  {refaire les calculs => long => lance demande}
  	         LanceNouvelleDemandeCalculsPourBase(false,withCheckEvent);
  	         exit;
  	       end;

  	    if (etat = PasDePartieActive) then
  	       begin  {pas de parties compatibles => rapide => affiche resultat}
  	         LanceNouvelleDemandeCalculsPourBase(true,false);
  	         CalculsEtAffichagePourBase(true,false);
  	         exit;
  	       end;

  	    {verification de l'exactitude de l'ancienne info}
  	    indexDepart := IndexInfoDejaCalculeesCoupNro^^[nbreCoup-1];
  	    nroReference := TableInfoDejaCalculee^^[indexDepart+1];

  	    ExtraitPartieTableStockageParties(nroReference,s60);
  	    ouvertureDiagonale := PACKED_GAME_IS_A_DIAGONAL(s60);
  	    ExtraitPremierCoup(premierCoup,autreCoupQuatreDansPartie);
  	    TransposePartiePourOrientation(s60,autreCoupQuatreDansPartie and ouvertureDiagonale and (nbreCoup >= 4),1,60);

  	    if not(PositionsSontEgales(JeuCourant,CalculePositionApres(nbreCoup,s60))) then
  	      begin  {infos fausses => refaire les calculs => long => lance demande}
  	        WritelnDansRapport('WARNING : not(positionsSontEgales(…) dans LanceCalculsRapidesPourBaseOuNouvelleDemande');
  	        LanceNouvelleDemandeCalculsPourBase(false,withCheckEvent);
  	        exit;
  	      end;

  	    if (etat <= 200)
  	      then  {peu de parties compatibles => rapide => on affiche le resultat}
  	        begin
  	          LanceNouvelleDemandeCalculsPourBase(true,false);
  	          CalculsEtAffichagePourBase(true,false);
  	        end
  	      else
  	        begin {beaucoup de parties compatibles => lent => on lance une demande }
  	          LanceNouvelleDemandeCalculsPourBase(true,withCheckEvent);
  	        end;
      end;
end;

procedure DoSupprimerPartiesDansListe;
const SupprimerPartiesListeID = 158;
      SupprimerUnePartieListeID = 159;
      Annuler = 2;
      OK = 1;
var itemHit : SInt16;
    confirmationSuppression : boolean;
    nbPartiesSupprimees,nroReference : SInt32;
begin

  if (nbPartiesActives <= 0) then
    exit;

  nroReference := infosListeParties.dernierNroReferenceHilitee;
  if PartieEstDansLaSelection(nroReference)
    then nbPartiesSupprimees := NbPartiesActivesDansLaSelectionDeLaListe
    else nbPartiesSupprimees := NbPartiesActivesDansLaSelectionDeLaListe + 1;

  confirmationSuppression := true;

  MyParamText(IntToStr(nbPartiesSupprimees),'','','');
  if (nbPartiesSupprimees = 1)
    then itemHit := CautionAlertTwoButtonsFromRessource(SupprimerUnePartieListeID,4,0,OK,Annuler)
    else itemHit := CautionAlertTwoButtonsFromRessource(SupprimerPartiesListeID,4,0,OK,Annuler);
  if (itemHit = Annuler)
    then ConfirmationSuppression := false
    else ConfirmationSuppression := true;

  if confirmationSuppression then
    begin
      {TraceLog('Suppression de '+IntToStr(nbPartiesSupprimees)+' parties !!!!');}

      SelectionnerPartieDeLaListe(infosListeParties.dernierNroReferenceHilitee);

      {destruction des parties}
      for nroReference := 1 to nbPartiesChargees do
        if PartieEstDansLaSelection(nroReference) and PartieEstActive(nroReference)
          then DetruirePartieDeLaListe(nroReference);

      {affichage de la nouvelle liste}
      RecalculateNbPartiesASauvegarderDansLaListe;
      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
      CalculsEtAffichagePourBase(false,true);

      {est-ce un vidage complet de la liste ?}
      if (nbPartiesActives <= 0) and (nbPartiesChargees > 0) and (NbrePartiesDetruitesDansLaListe >= nbPartiesChargees)
        then ResetListeDeParties;
    end;
end;


procedure TraiteDemandeCalculsPourBase(fonctionAppelante : String255);
begin {$UNUSED fonctionAppelante}
  {
  WriteStringDansRapport('--> TraiteDemandeCalculsPourBase, fonction appelante = '+fonctionAppelante);
  WriteNumDansRapport('  AQuiDeJouer = ',AQuiDeJouer);
  WritelnStringAndBooleenDansRapport('  bWithCheckEvent = ',DemandeCalculsPourBase.bWithCheckEvent);
  }

  if not(problemeMemoireBase) then
	  with DemandeCalculsPourBase do
	    if (EtatDesCalculs = kCalculsDemandes) then
	      CalculsEtAffichagePourBase(bInfosDejaCalcules,bWithCheckEvent);
end;


const kPartieDouteuseLorsDeLImport     = 0;
      kPartieActiveBit                 = 1;
      kPartieDetruiteBit               = 2;
      kPartieSelectionneeBit           = 3;
      kPartieCompatibleCritereBit      = 4;
      kPartieParticipeAuClassementBit  = 5;
      kPartieDoitEtreSauvegardeeBit    = 6;
      kPartieEntreDeuxJoueursHumains   = 7;


var
  cardinalSelectionDeLaListe : SInt32;
  cardinalNombrePartiesASauverDansLaListe : SInt32;
  cardinalNombrePartiesDouteuseDansLaListe : SInt32;


function GetNumeroReferencePartieHilitee : SInt32;
begin
  GetNumeroReferencePartieHilitee := infosListeParties.dernierNroReferenceHilitee;
end;


function EstLaPartieHilitee(nroReferencePartie : SInt32) : boolean;
begin
  EstLaPartieHilitee := (GetNumeroReferencePartieHilitee = nroReferencePartie);
end;


procedure SetPartieActive(nroReferencePartie : SInt32; flag : boolean);
begin
  if flag
	  then BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieActiveBit)  {Bit Set}
	  else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieActiveBit); {Bit Clear}
end;


function PartieEstActive(nroReferencePartie : SInt32) : boolean;
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees)
    then PartieEstActive := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieActiveBit)  {Bit Test}
    else PartieEstActive := false;
end;


procedure DesactiverToutesLesParties;
var k : SInt32;
begin
  for k := 1 to nbPartiesChargees do
    BCLR(tableBooleensDeLaListe^[k],kPartieActiveBit);  {Bit Clear}
end;


procedure SetPartieDetruite(nroReferencePartie : SInt32; flag : boolean);
begin
  if flag
		then BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieDetruiteBit)  {Bit Set}
		else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieDetruiteBit); {Bit Clear}
end;


procedure DetruirePartieDeLaListe(nroReferencePartie : SInt32);
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees) then
    BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieDetruiteBit); {Bit Set}
end;


function PartieDeLaListeEstDetruite(nroReferencePartie : SInt32) : boolean;
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees)
    then PartieDeLaListeEstDetruite := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieDetruiteBit) {Bit Test}
    else PartieDeLaListeEstDetruite := false;
end;


procedure SetAucunePartieDetruiteDansLaListe;
var k : SInt32;
begin
  for k := 1 to nbPartiesChargees do
    BCLR(tableBooleensDeLaListe^[k],kPartieDetruiteBit);  {Bit Clear}
end;


function NbrePartiesDetruitesDansLaListe : SInt32;
var k, compteur : SInt32;
begin
  compteur := 0;
  for k := 1 to nbPartiesChargees do
    if BTST(tableBooleensDeLaListe^[k],kPartieDetruiteBit)  {Bit Test}
      then inc(compteur);
  NbrePartiesDetruitesDansLaListe := compteur;
end;


procedure SelectionnerPartieDeLaListe(nroReferencePartie : SInt32);
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees) then
    begin
		  if not(PartieEstDansLaSelection(nroReferencePartie)) then
		    inc(cardinalSelectionDeLaListe);
		  BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieSelectionneeBit); {Bit Set}
		end;
end;


procedure DeselectionnerPartieDeLaListe(nroReferencePartie : SInt32);
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees) then
    begin
      if PartieEstDansLaSelection(nroReferencePartie) then
        dec(cardinalSelectionDeLaListe);
      BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieSelectionneeBit); {Bit Clear}
    end;
end;


function PartieEstDansLaSelection(nroReferencePartie : SInt32) : boolean;
begin
  if (nroReferencePartie >= 1) and (nroReferencePartie <= nbPartiesChargees)
    then PartieEstDansLaSelection := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieSelectionneeBit) {Bit Test}
    else PartieEstDansLaSelection := false;
end;


function PartieEstActiveEtSelectionnee(nroReferencePartie : SInt32) : boolean;
begin
  PartieEstActiveEtSelectionnee := PartieEstActive(nroReferencePartie) and
                                   (EstLaPartieHilitee(nroReferencePartie) or PartieEstDansLaSelection(nroReferencePartie));
end;


procedure DeselectionnerToutesLesPartiesDansLaListe;
var k : SInt32;
begin
  if (NbPartiesDansLaSelectionDeLaListe <> 0) then
    begin
		  for k := 1 to nbPartiesChargees do
		    BCLR(tableBooleensDeLaListe^[k],kPartieSelectionneeBit);  {Bit Clear}
		  cardinalSelectionDeLaListe := 0;
		end;
end;


procedure SelectionnerToutesLesPartiesDansLaListe;
var k : SInt32;
begin
  for k := 1 to nbPartiesChargees do
    BSET(tableBooleensDeLaListe^[k],kPartieSelectionneeBit);  {Bit Set}
  cardinalSelectionDeLaListe := nbPartiesChargees;
end;


procedure SelectionnerToutesLesPartiesVerifiantCePredicat(whichPredicate : FiltreNumRefProc);
var nroDansLaListe : SInt32;
    nroReferencePartie : SInt32;
    compteur : SInt32;
    bidlong : SInt32;
begin
  DeselectionnerToutesLesPartiesDansLaListe;

  compteur := 0;
  for nroDansLaListe := 1 to nbPartiesActives do
    begin
      nroReferencePartie := tableNumeroReference^^[nroDansLaListe];

      if whichPredicate(nroDansLaListe,nroReferencePartie,bidlong)
        then
          begin
            BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieSelectionneeBit);  {Bit Set}
            inc(compteur);
          end
        else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieSelectionneeBit); {Bit Clear}
    end;
  cardinalSelectionDeLaListe := compteur;
end;


procedure SelectionnerToutesLesPartiesActivesDansLaListe;
var k,compteur : SInt32;
begin
  compteur := 0;
  for k := 1 to nbPartiesChargees do
    if PartieEstActive(k)
      then
        begin
          BSET(tableBooleensDeLaListe^[k],kPartieSelectionneeBit);  {Bit Set}
          inc(compteur);
        end
      else BCLR(tableBooleensDeLaListe^[k],kPartieSelectionneeBit); {Bit Clear}
  cardinalSelectionDeLaListe := compteur;
end;


function PremierePartieDeLaSelection(var nroReference : SInt32) : SInt32;
var i,k : SInt32;
begin
  if (NbPartiesDansLaSelectionDeLaListe > 0) then
    for i := 1 to nbPartiesChargees do
      begin
        k := tableNumeroReference^^[i];
        if PartieEstDansLaSelection(k) then
        begin
          nroReference := k;
          PremierePartieDeLaSelection := i;
          exit;
        end;
      end;
   {not found}
   nroReference := -1;
   PremierePartieDeLaSelection := -1
end;


function NbPartiesDansLaSelectionDeLaListe : SInt32;
begin
  NbPartiesDansLaSelectionDeLaListe := cardinalSelectionDeLaListe;
end;


function NbPartiesActivesDansLaSelectionDeLaListe : SInt32;
var k,compteur : SInt32;
begin
  compteur := 0;
  for k := 1 to nbPartiesChargees do
    if BTST(tableBooleensDeLaListe^[k],kPartieActiveBit) and
       BTST(tableBooleensDeLaListe^[k],kPartieSelectionneeBit) then
      inc(compteur);
  NbPartiesActivesDansLaSelectionDeLaListe := compteur;
end;


procedure InitSelectionDeLaListe;
var k : SInt32;
begin
  for k := 0 to nbrePartiesEnMemoire do
		BCLR(tableBooleensDeLaListe^[k],kPartieSelectionneeBit);  {Bit Clear}
	cardinalSelectionDeLaListe := 0;
end;


procedure SetPartieCompatibleParCriteres(nroReferencePartie : SInt32; flag : boolean);
begin
  if flag
	  then BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieCompatibleCritereBit)  {Bit Set}
	  else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieCompatibleCritereBit); {Bit Clear}
end;


function PartieEstCompatibleParCriteres(nroReferencePartie : SInt32) : boolean;
begin
  PartieEstCompatibleParCriteres := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieCompatibleCritereBit);  {Bit Test}
end;


procedure SetPartieEstSansOrdinateur(nroReferencePartie : SInt32; flag : boolean);
begin
  if flag
	  then BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieEntreDeuxJoueursHumains)  {Bit Set}
	  else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieEntreDeuxJoueursHumains); {Bit Clear}
end;


function PartieEstSansOrdinateur(nroReferencePartie : SInt32) : boolean;
begin
  PartieEstSansOrdinateur := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieEntreDeuxJoueursHumains);  {Bit Test}
end;


procedure LaveTableCriteres;
var i : SInt32;
begin
  if not(problemeMemoireBase) then
	  begin
	    InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
	    for i := 0 to Min(nbrePartiesEnMemoire,nbPartiesChargees) do
	      BSET(tableBooleensDeLaListe^[i],kPartieCompatibleCritereBit); {Bit Set}
	  end;
end;


{parties utilisees pour le calcul du classement}
procedure SetParticipationPartieAuClassement(nroReferencePartie : SInt32; flag : boolean);
begin
  if flag
	  then BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieParticipeAuClassementBit)  {Bit Set}
	  else BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieParticipeAuClassementBit); {Bit Clear}
end;


function PartieParticipeAuClassement(nroReferencePartie : SInt32) : boolean;
begin
  PartieParticipeAuClassement := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieParticipeAuClassementBit);  {Bit Test}
end;


procedure SetAucunePartieDeLaListeNeParticipeAuClassement;
var k : SInt32;
begin
  if not(problemeMemoireBase) then
	  for k := 0 to nbrePartiesEnMemoire do
			BCLR(tableBooleensDeLaListe^[k],kPartieParticipeAuClassementBit);  {Bit Clear}
end;


procedure SetPartieDansListeDoitEtreSauvegardee(nroReferencePartie : SInt32; flag : boolean);
var oldValue : boolean;
begin
  oldValue := PartieDansListeDoitEtreSauvegardee(nroReferencePartie);
  if flag <> oldValue then
    begin
      if flag
    	  then
    	    begin
    	      BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieDoitEtreSauvegardeeBit);  {Bit Set}
    	      inc(cardinalNombrePartiesASauverDansLaListe);
    	    end
    	  else
    	    begin
    	      BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieDoitEtreSauvegardeeBit); {Bit Clear}
    	      dec(cardinalNombrePartiesASauverDansLaListe);
    	    end;
    end;
end;


function PartieDansListeDoitEtreSauvegardee(nroReferencePartie : SInt32) : boolean;
begin
  PartieDansListeDoitEtreSauvegardee := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieDoitEtreSauvegardeeBit);  {Bit Test}
end;


{fonction rapide, mais ne tient pas compte si les sous-criteres sont actifs}
function NbPartiesDevantEtreSaugardeesDansLaListe : SInt32;
begin
  NbPartiesDevantEtreSaugardeesDansLaListe := cardinalNombrePartiesASauverDansLaListe;
end;



{attention : fonction lente}
function NbPartiesActivesDevantEtreSauvegardeesDansLaListe : SInt32;
var compteur,k : SInt32;
begin

  if (nbPartiesActives = nbPartiesChargees) then
    begin
      {dans ce cas la fonction rapide donne le bon chiffre, on l'utilise donc... }
      NbPartiesActivesDevantEtreSauvegardeesDansLaListe := NbPartiesDevantEtreSaugardeesDansLaListe;
      exit;
    end;

  {methode lente :-( }

  compteur := 0;
  if not(problemeMemoireBase) then
	  for k := 1 to nbPartiesChargees do
      if BTST(tableBooleensDeLaListe^[k],kPartieActiveBit) and
         BTST(tableBooleensDeLaListe^[k],kPartieDoitEtreSauvegardeeBit) and
         not(BTST(tableBooleensDeLaListe^[k],kPartieDetruiteBit)) then
       inc(compteur);
  NbPartiesActivesDevantEtreSauvegardeesDansLaListe := compteur;
end;






procedure RecalculateNbPartiesASauvegarderDansLaListe;
var compteur,k : SInt32;
begin
  compteur := 0;
  if not(problemeMemoireBase) then
	  for k := 1 to nbPartiesChargees do
      if BTST(tableBooleensDeLaListe^[k],kPartieDoitEtreSauvegardeeBit) and
         not(BTST(tableBooleensDeLaListe^[k],kPartieDetruiteBit)) then
       inc(compteur);
  cardinalNombrePartiesASauverDansLaListe := compteur;
end;


procedure SetAucunePartieDeLaListeNeDoitEtreSauvegardee;
var k : SInt32;
begin
  if not(problemeMemoireBase) then
	  for k := 0 to nbrePartiesEnMemoire do
			BCLR(tableBooleensDeLaListe^[k],kPartieDoitEtreSauvegardeeBit);  {Bit Clear}
  cardinalNombrePartiesASauverDansLaListe := 0;
end;


procedure SetPartieDansListeEstDouteuse(nroReferencePartie : SInt32; flag : boolean);
var oldValue : boolean;
begin
  oldValue := PartieDansListeEstDouteuse(nroReferencePartie);
  if flag <> oldValue then
    begin
      if flag
    	  then
    	    begin
    	      BSET(tableBooleensDeLaListe^[nroReferencePartie],kPartieDouteuseLorsDeLImport);  {Bit Set}
    	      inc(cardinalNombrePartiesDouteuseDansLaListe);
    	    end
    	  else
    	    begin
    	      BCLR(tableBooleensDeLaListe^[nroReferencePartie],kPartieDouteuseLorsDeLImport); {Bit Clear}
    	      dec(cardinalNombrePartiesDouteuseDansLaListe);
    	    end;
    end;
end;


function PartieDansListeEstDouteuse(nroReferencePartie : SInt32) : boolean;
begin
  PartieDansListeEstDouteuse := BTST(tableBooleensDeLaListe^[nroReferencePartie],kPartieDouteuseLorsDeLImport);  {Bit Test}
end;


function NbPartiesDouteusesDansLaListe : SInt32;
begin
  NbPartiesDouteusesDansLaListe := cardinalNombrePartiesDouteuseDansLaListe;
end;


procedure RecalculateNbPartiesDouteusesDansLaListe;
var compteur,k : SInt32;
begin
  compteur := 0;
  if not(problemeMemoireBase) then
	  for k := 1 to nbPartiesChargees do
      if BTST(tableBooleensDeLaListe^[k],kPartieDouteuseLorsDeLImport) and
         not(BTST(tableBooleensDeLaListe^[k],kPartieDetruiteBit)) then
       inc(compteur);
  cardinalNombrePartiesDouteuseDansLaListe := compteur;
end;


procedure SetAucunePartieDeLaListeNEstDouteuse;
var k : SInt32;
begin
  if not(problemeMemoireBase) then
	  for k := 0 to nbrePartiesEnMemoire do
			BCLR(tableBooleensDeLaListe^[k],kPartieDouteuseLorsDeLImport);  {Bit Clear}
  cardinalNombrePartiesDouteuseDansLaListe := 0;
end;

procedure SelectionnerPartiesOuScoreTheoriqueEgalScoreReel;
begin

  {WritelnNumDansRapport('nbPartiesEnMemoire = ',nbrePartiesEnMemoire);
  WritelnNumDansRapport('nbPartiesChargees = ',nbPartiesChargees);
  WritelnNumDansRapport('nbPartiesActives = ',nbPartiesActives);}

  SelectionnerToutesLesPartiesVerifiantCePredicat(PartieAvecScoresTheoriqueEtReelEgaux);

  WritelnDansRapport('');
  if cardinalSelectionDeLaListe >= 2
    then WritelnDansRapport('Il y a '+IntToStr(cardinalSelectionDeLaListe) + ' parties pour lesquelles le score théorique est égal au score réel')
    else
      if cardinalSelectionDeLaListe = 1
        then WritelnDansRapport('Il y a une partie dans laquelle le score théorique est égal au score réel')
        else WritelnDansRapport('Il n''y a pas de partie où le score théorique soit égal au score réel…');
  WritelnDansRapport('');

  EcritListeParties(false,'SelectionnerPartiesOuScoreTheoriqueEgalScoreReel');
end;


function PartieAvecScoresTheoriqueEtReelEgaux(numeroDansLaListe,numeroReference : SInt32; var score : SInt32) : boolean;
var scoreTheorique,scoreReel : SInt16;
begin {$UNUSED numeroDansLaListe}

  score := -1;
  PartieAvecScoresTheoriqueEtReelEgaux := false;

  if (numeroDansLaListe >= 1) and (numeroDansLaListe <= nbPartiesActives) and
     (numeroReference >= 1) and (numeroReference <= nbPartiesChargees) then
    begin
      if PartieEstActive(numeroReference) then
        begin
          GetScoresTheoriqueEtReelParNroRefPartie(numeroReference,scoreTheorique,scoreReel);
          if (scoreTheorique = scoreReel) then
            begin
              score := scoreTheorique;
              PartieAvecScoresTheoriqueEtReelEgaux := true;
            end;
        end;
    end;

end;


const MenuFlottantListeID = 3014;

var   menuFlottantListe : MenuFlottantRec;


procedure TraiteSourisListe(evt : eventRecord);
var mouseLoc : Point;
    oldport : grafPtr;
    whichControl : ControlHandle;
    FiltreAscenseurListeUPP  : ControlActionUPP;
    hiliteState,action,i : SInt32;
    anciennePartieHilitee,PartieCliquee : SInt32;
    nouvellePartieHilitee,refHilitee : SInt32;
    intervalleHilite : SInt32;
    ClicDansCriteresBox : boolean;
    shift,command,option,control : boolean;
    s : String255;
    oldNbreCoups : SInt32;
begin
  shift   := BAND(evt.modifiers,shiftKey) <> 0;
  command := BAND(evt.modifiers,cmdKey) <> 0;
  option  := BAND(evt.modifiers,optionKey) <> 0;
  control := BAND(evt.modifiers,controlKey) <> 0;
  if windowListeOpen then
    begin
      GetPort(oldport);
      SetPortByWindow(wListePtr);

      if (infosListeParties.ascenseurListe = NIL) or
         (SousCriteresRuban[TournoiRubanBox]      = NIL) or
         (SousCriteresRuban[JoueurNoirRubanBox]   = NIL) or
         (SousCriteresRuban[JoueurBlancRubanBox]  = NIL) or
         (SousCriteresRuban[DistributionRubanBox] = NIL) then
        begin
          s := 'WARNING : je suis obligé de reouvrir les controles dans TraiteSourisListe, ce n''est pas normal';
          TraceLog(s);
          CloseControlesListe;
          OuvreControlesListe;
        end;

      mouseLoc := evt.where;
      GlobalToLocal(mouseLoc);
      hilitestate := FindControl(mouseLoc,wListePtr,whichControl);
      if (hiliteState > 0) then
        begin               { clic dans l'ascenseur  }
          AnnulerSousCriteresRuban;
          HiliteControl(whichControl,hilitestate);
          {positionPouceAscenseurListe := GetControlValue(whichControl);}
          FiltreAscenseurListeUPP := NewControlActionUPP(FiltreAscenseurListe);
          case hiliteState of
            kControlUpButtonPart:   action := TrackControl(whichControl,mouseLoc,FiltreAscenseurListeUPP);
            kControlDownButtonPart: action := TrackControl(whichControl,mouseLoc,FiltreAscenseurListeUPP);
            kControlPageUpPart:     action := TrackControl(whichControl,mouseLoc,FiltreAscenseurListeUPP);
            kControlPageDownPart:   action := TrackControl(whichControl,mouseLoc,FiltreAscenseurListeUPP);
            kControlIndicatorPart:
               begin
                 action := MyTrackControlIndicatorPartListe(whichControl);
                 {
                 if TrackControl(whichControl,mouseLoc,NIL) > 0 then
                    begin
                      positionPouceAscenseurListe := GetControlValue(whichControl);
                      EcritListeParties(false,'TraiteSourisListe(1)');
                    end;
                  }
               end;
          end; {case}
          HiliteControl(whichControl,0);
          MyDisposeControlActionUPP(FiltreAscenseurListeUPP);
          {positionPouceAscenseurListe := GetControlValue(whichControl);}
        end
       else
        if mouseLoc.v >= GetWindowPortRect(wListePtr).bottom - hauteurPiedDePageListe
          then { clic dans le pied de page  }
            begin
              with infosListeParties do
                if PtInRect(mouseLoc,inclureOrdinateurRect) then
                  begin
                    if InclurePartiesAvecOrdinateursDansListe
                      then
                        begin
                          if AppuieBoutonPicture(wListePtr,kPetiteCheckBoxRemplieID,kPetiteCheckBoxID,inclureOrdinateurRect,mouseLoc)
                            then SetInclurePartiesAvecOrdinateursDansListe(false);
                        end
                      else
                        begin
                          if AppuieBoutonPicture(wListePtr,kPetiteCheckBoxID,kPetiteCheckBoxRemplieID,inclureOrdinateurRect,mouseLoc)
                            then SetInclurePartiesAvecOrdinateursDansListe(true);
                        end;
                    DessinePiedDePageFenetreListe;
                    gLigneOuLOnVoudraitQueSoitLaPartieHilitee := NumeroDeLaLigneDeLaPartieHiliteeDansLaFenetre;
                    CalculTableCriteres;
                    LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
                  end;
            end
       else
        if mouseLoc.v <= hauteurRubanListe
          then  { clic dans le ruban  }
            begin
              if PtInRect(mouseLoc,RubanDistributionRect) and AppuieBouton(RubanDistributionRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParDistribution,kRadixSort) else
              if PtInRect(mouseLoc,RubanTournoiRect) and AppuieBouton(RubanTournoiRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParDate,kRadixSort) else
              if PtInRect(mouseLoc,RubanNoirsRect) and AppuieBouton(RubanNoirsRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParJoueurNoir,kRadixSort) else
              if PtInRect(mouseLoc,RubanBlancsRect) and AppuieBouton(RubanBlancsRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParJoueurBlanc,kRadixSort) else
              if PtInRect(mouseLoc,RubanCoupRect) and AppuieBouton(RubanCoupRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParOuverture,kQuickSort) else
              if PtInRect(mouseLoc,RubanTheoriqueRect) and AppuieBouton(RubanTheoriqueRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParScoreTheorique,kRadixSort) else
              if PtInRect(mouseLoc,RubanReelRect) and AppuieBouton(RubanReelRect,0,mouseLoc,MyInvertRoundRect,MyInvertRoundRect)
                then DoTrierListe(TriParScoreReel,kRadixSort) else
              if PtInRect(mouseLoc,RubanSousCritActifs) { and AppuieBouton(RubanSousCritActifs,0,mouseLoc) }
                then
                  if option
                    then DoSwaperLesSousCriteres
                    else DoChangeSousSelectionActive
                else
              {if nbPartiesChargees > 0 then}
                begin
                  ClicDansCriteresBox := false;
                  for i := TournoiRubanBox to DistributionRubanBox do
                    if PtInRect(mouseLoc,TEGetViewRect(SousCriteresRuban[i])) then
                      begin
                        ClicDansCriteresBox := true;
                        if not(sousSelectionActive) then DoChangeSousSelectionActive;
                        if i = BoiteDeSousCritereActive
                          then TEClick(mouseLoc,shift,SousCriteresRuban[i])
                          else PasseListeEnModeEntree(i);
                      end;
                  if not(ClicDansCriteresBox) then AnnulerSousCriteresRuban;
                end;
            end
          else  { clic dans les parties  }
            begin
              if control and not(option) and (nbPartiesActives > 0)
                then
                  begin
                    menuFlottantListe := NewMenuFlottant(MenuFlottantListeID,MakeRect(mouseLoc.h-30,mouseLoc.v-5,mouseLoc.h-30,mouseLoc.v+15),0);
                    InstalleMenuFlottant(menuFlottantListe,NIL);
                    if not(EventPopUpItemMenuFlottant(menuFlottantListe,false,false,true)) then
                      menuFlottantListe.theItem := 0;

                    case menuFlottantListe.theItem of
                      FormatWTBCmd   : if (SauvegardeListeCouranteAuNouveauFormat(FiltrePartieEstActiveEtSelectionnee) <> NoErr)
                                         then AlerteSimple('L''enregistrement a échoué, désolé');
                      FormatPARCmd   : if SauvegardeListeCouranteEnTHOR_PAR <> NoErr
                                         then AlerteSimple('L''enregistrement a échoué, désolé');
                      FormatTexteCmd : DoExporterListeDePartiesEnTexte;
                      FormatHTMLCmd  : ExportListeAuFormatHTML;
                      FormatPGNCmd   : ExportListeAuFormatPGN;
                      FormatXOFCmd   : ExportListeAuFormatXOF;
                    end;

                    DesinstalleMenuFlottant(menuFlottantListe);
                  end
                else
                 if (mouseLoc.h < GetWindowPortRect(wListePtr).right - 15) and
                    (mouseLoc.v < GetWindowPortRect(wListePtr).bottom - hauteurPiedDePageListe) then
                   with infosListeParties do
	                   begin
	                     AnnulerSousCriteresRuban;
	                     anciennePartieHilitee := partieHilitee;
	                     {positionPouceAscenseurListe := GetControlValue(MyGetRootControl(wListePtr));}
	                     partieCliquee := positionPouceAscenseurListe + (mouseLoc.v-hauteurRubanListe) div HauteurChaqueLigneDansListe;
	                     if (partieCliquee = anciennePartieHilitee)
	                       then
	                         begin
	                           intervalleHilite := evt.when-clicHilite;
	                           clicHilite := evt.when;
	                           if (intervalleHilite < 30) then
	                             begin
	                               oldNbreCoups := nbreCoup;
	                               OuvrePartieSelectionnee(partieCliquee);
	                               if control and option then
	                                 begin
	                                   CalculsEtAffichagePourBase(false,true);
	                                   DialogueSaisieNomsJoueursPartie(oldNbreCoups);
	                                 end;
	                             end;
	                         end
	                       else
	                         if ((partieCliquee >= 1) and (partieCliquee <= nbPartiesActives)) and
	                            not(command) and not(shift) then
	                           begin
	                             clicHilite := evt.when;
	                             ChangePartieHilitee(partieCliquee,anciennePartieHilitee);
	                           end;

	                     if shift
	                      then {shift => on étend la selection}
	                       begin
	                         if (partieCliquee < anciennePartieHilitee)
	                           then for i := partieCliquee+1 to anciennePartieHilitee do
	                                   SelectionnerPartieDeLaListe(tableNumeroReference^^[i])
	                           else for i := anciennePartieHilitee to partieCliquee-1 do
	                                   SelectionnerPartieDeLaListe(tableNumeroReference^^[i]);
	                         {for i := Max(Min(partieCliquee,anciennePartieHilitee),1) to
	                                  Min(Max(partieCliquee,anciennePartieHilitee),nbPartiesActives) do
	                           SelectionnerPartieDeLaListe(tableNumeroReference^^[i]);}
	                         ChangePartieHilitee(partieCliquee,anciennePartieHilitee);
	                         EcritListeParties(false,'TraiteSourisListe(2)');
	                       end

	                     else

	                     if command
	                       then {command => on toggle la partie nouvellement cliquee}
	                       begin
		                       if (partieCliquee = anciennePartieHilitee) and
		                          not((NbPartiesDansLaSelectionDeLaListe = 0) or
		                              ((NbPartiesDansLaSelectionDeLaListe = 1) and PartieEstDansLaSelection(tableNumeroReference^^[partieCliquee])))
		                          then
		                            begin
		                              if PartieEstDansLaSelection(tableNumeroReference^^[partieCliquee]) then
		                                 DeselectionnerPartieDeLaListe(tableNumeroReference^^[partieCliquee]);
		                              nouvellePartieHilitee := PremierePartieDeLaSelection(refHilitee);
                                  if (nouvellePartieHilitee >= 1) then
                                    begin
                                      ChangePartieHilitee(nouvellePartieHilitee,anciennePartieHilitee);
                                      DeselectionnerPartieDeLaListe(tableNumeroReference^^[anciennePartieHilitee]);
                                      DeselectionnerPartieDeLaListe(tableNumeroReference^^[nouvellePartieHilitee]);
                                    end;
		                            end
		                          else
		                            if (partieCliquee <> anciennePartieHilitee) then
		                            begin
			                            if PartieEstDansLaSelection(tableNumeroReference^^[partieCliquee])
			                              then DeselectionnerPartieDeLaListe(tableNumeroReference^^[partieCliquee])
			                              else SelectionnerPartieDeLaListe(tableNumeroReference^^[partieCliquee]);
			                          end;
	                         EcritListeParties(false,'TraiteSourisListe(3)');
	                       end
	                     else


	                     if (NbPartiesDansLaSelectionDeLaListe <> 0) then
	                       begin
	                         DeselectionnerToutesLesPartiesDansLaListe;
	                         EcritListeParties(false,'TraiteSourisListe(4)');
	                       end;
	                    end;
             end;
      SetPort(oldport);
    end;
end;


procedure DoChangeEcritTournoi(nouveauNombreDeColonnes : SInt16);
const margeNomDesJoueur = 0;
var isRunningAtLeastInTiger : boolean;
    unRect : rect;
    oldport : grafPtr;
    nouvelleLargeurFenetreListe : SInt32;
    ancienneLargeurFenetreListe : SInt32;
    delta,currentSize : SInt32;
    err : OSStatus;
    targetRect : rect;
    structureRect : rect;
    effacageRect : rect;
    MacVersion : SInt32;
 begin

   if (Gestalt(gestaltSystemVersion, MacVersion) = noErr) and
     (MacVersion >= $1040)  (* au moins Mac OS X 10.4 *)
     then isRunningAtLeastInTiger := true
     else isRunningAtLeastInTiger := false;

   ancienneLargeurFenetreListe := LargeurNormaleFenetreListe(nbColonnesFenetreListe);
   nouvelleLargeurFenetreListe := LargeurNormaleFenetreListe(nouveauNombreDeColonnes);

   nbColonnesFenetreListe := nouveauNombreDeColonnes;
   if windowListeOpen  then
     begin
       GetPort(oldPort);
       SetPortByWindow(wListePtr);

       structureRect := GetWindowStructRect(wListePtr);

       unRect := GetWindowPortRect(wListePtr);
       LocalToGlobal(unRect.topLeft);
       LocalToGlobal(unRect.botRight);

       delta := nouvelleLargeurFenetreListe - ancienneLargeurFenetreListe;
       currentSize := unRect.right - unRect.left;

       if (nouvelleLargeurFenetreListe <> ancienneLargeurFenetreListe) or
          (nouvelleLargeurFenetreListe <> currentSize) then
         begin

           effacageRect := GetWindowPortRect(wListePtr);
           {OffSetRect(effacageRect,0,hauteurRubanListe);}

           if delta = 0 then delta := nouvelleLargeurFenetreListe - currentSize;

           if (delta > 0)
             then
               begin
    	           if gIsRunningUnderMacOSX and not(isRunningAtLeastInTiger)
    	             then
    	               begin
    	                 targetRect := MakeRect(unRect.left-delta,structureRect.top,unRect.left-delta+nouvelleLargeurFenetreListe,unRect.bottom);

    	                 if false and isRunningAtLeastInTiger
    	                   then
    	                     begin
    	                       OffSetRect(targetRect,delta,0);
    	                       err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowMoveTransitionAction, @targetRect);
    	                       EcritRubanListe(true);
    	                       AjustePositionAscenseurListe;
    	                       EcritListeParties(false,'DoChangeEcritTournoi (3)');
    	                       OffSetRect(targetRect,-delta,0);
    	                       err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowMoveTransitionAction, @targetRect);
    	                     end
    	                   else
    	                     begin
          			             MyEraseRect(effacageRect);
          			             MyEraseRectWithColor(effacageRect,OrangeCmd,blackPattern,'');
          			             err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowMoveTransitionAction, @targetRect);
    	                     end;
    	               end
    	             else
    	               begin
    	                 ShowHide(wListePtr,false);
    	                 MoveWindow(wListePtr,unRect.left-delta,unRect.top,false);
    	                 SizeWindow(wListePtr,nouvelleLargeurFenetreListe,unRect.bottom-unRect.top,false);
    	                 ShowHide(wListePtr,true);
    	               end;
               end
             else
               begin
                 if gIsRunningUnderMacOSX and not(isRunningAtLeastInTiger)
                   then
                     begin
                       targetRect := MakeRect(unRect.left-delta,structureRect.top,unRect.left-delta+nouvelleLargeurFenetreListe,unRect.bottom);
                       if isRunningAtLeastInTiger
    	                   then
    	                     begin
    	                       OffSetRect(targetRect,delta,0);
    	                       err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowResizeTransitionAction, @targetRect);
    	                       EcritRubanListe(true);
    	                       AjustePositionAscenseurListe;
    	                       EcritListeParties(false,'DoChangeEcritTournoi (3)');
    	                       OffSetRect(targetRect,-delta,0);
    	                       err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowMoveTransitionAction, @targetRect);
    	                     end
    	                   else
    	                     begin
          			             MyEraseRect(effacageRect);
          			             MyEraseRectWithColor(effacageRect,OrangeCmd,blackPattern,'');
          			             err := TransitionWindow(wListePtr, kWindowSlideTransitionEffect, kWindowMoveTransitionAction, @targetRect);
    	                     end;
    			           end
    			         else
    			           begin
    			             ShowHide(wListePtr,false);
    			             SizeWindow(wListePtr,nouvelleLargeurFenetreListe,unRect.bottom-unRect.top,false);
    			             MoveWindow(wListePtr,unRect.left-delta,unRect.top,false);
    			             ShowHide(wListePtr,true);
                     end;
               end;
           AjustePositionAscenseurListe;
           CalculEmplacementCriteresListe;
           if FenetreListeEstEnModeEntree then
             case nbColonnesFenetreListe of
               kAvecAffichageTournois :
                 if (BoiteDeSousCritereActive = DistributionRubanBox) then
                   begin
                     AnnulerSousCriteresRuban;
                     BoiteDeSousCritereActive := TournoiRubanBox;
                     PasseListeEnModeEntree(BoiteDeSousCritereActive);
                   end;
               kAvecAffichageSeulementDesJoueurs :
                 if (BoiteDeSousCritereActive = TournoiRubanBox) or
                     (BoiteDeSousCritereActive = DistributionRubanBox) then
                   begin
                     AnnulerSousCriteresRuban;
                     BoiteDeSousCritereActive := JoueurNoirRubanBox;
                     PasseListeEnModeEntree(BoiteDeSousCritereActive);
                   end;
             end; {case}
           NoUpdateWindowListe;
           InvalidateJustificationPasDePartieDansListe;
           EcritRubanListe(true);
           EcritListeParties(false,'DoChangeEcritTournoi (3)');
           {DessineBoiteDeTaille(wListePtr);
           DessineBoiteAscenseurDroite(wListePtr);}
           SetPositionsTextesWindowPlateau;
         end;

       SetPort(oldPort);
     end;
 end;


end.
















