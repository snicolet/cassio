UNIT UnitLiveUndo;



INTERFACE




 USES UnitDefCassio;


{ Initialisation et destruction de l'unité }
procedure InitUnitLiveUndo;                                                                                                                                                         ATTRIBUTE_NAME('InitUnitLiveUndo')
procedure LibereMemoireUnitLiveUndo;                                                                                                                                                ATTRIBUTE_NAME('LibereMemoireUnitLiveUndo')


{ Fonctions d'acces }
function LiveUndoEnCours : boolean;                                                                                                                                                 ATTRIBUTE_NAME('LiveUndoEnCours')
function LiveUndoVaRejouerImmediatementUnAutreCoup : boolean;                                                                                                                       ATTRIBUTE_NAME('LiveUndoVaRejouerImmediatementUnAutreCoup')


{ Fonction de gestion du live undo }
procedure BeginLiveUndo(coupsProteges : SquareSet; nbreDeTicksDeDelai : SInt32);                                                                                                    ATTRIBUTE_NAME('BeginLiveUndo')
procedure EndLiveUndo;                                                                                                                                                              ATTRIBUTE_NAME('EndLiveUndo')
procedure GererLiveUndo;                                                                                                                                                            ATTRIBUTE_NAME('GererLiveUndo')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitDialog, UnitRapport, UnitPositionEtTrait, UnitJeu, UnitBallade, UnitGameTree, UnitArbreDeJeuCourant
    , UnitActions, UnitGestionDuTemps, UnitFenetres, UnitStrategie, UnitOth2, UnitNormalisation, UnitAffichagePlateau, UnitModes
    , Zebra_to_Cassio, UnitListe ;
{$ELSEC}
    ;
    {$I prelink/LiveUndo.lk}
{$ENDC}


{END_USE_CLAUSE}
















var gLiveUndoData : record
                      enCours                         : boolean;
                      tickDuClic                      : SInt32;
                      delai                           : SInt32;
                      numeroClicCommencement          : SInt32;
                      numeroDuCoupAuCommencement      : SInt32;
                      caseSousLaSourisAuCommencement  : SInt32;
                      nbreNiveauxRecursion            : SInt32;
                      dernierTickVerificationLiveUndo : SInt32;
                      HumCtreHumEntreeLiveUndo        : boolean;
                      coupsAGarderDansLiveUndo        : SquareSet;
                      positionUnCoupAvantLeClic       : PositionEtTraitRec;
                      changementTemporaireDeHumCtreHum: boolean;
                      afficheNumeroCoupAuCommencement : boolean;
                      devraRejouerSurLaNouvelleCase   : boolean;
                    end;


procedure InitUnitLiveUndo;
begin
  with gLiveUndoData do
    begin
      enCours := false;
      numeroClicCommencement     := -1000;
      numeroDuCoupAuCommencement := -1000;
      nbreNiveauxRecursion       := 0;
    end;
end;


procedure LibereMemoireUnitLiveUndo;
begin
  with gLiveUndoData do
    begin
      enCours := false;
      numeroClicCommencement     := -1000;
      numeroDuCoupAuCommencement := -1000;
    end;
end;


function LiveUndoEnCours : boolean;
begin
  with gLiveUndoData do
    LiveUndoEnCours := enCours;
end;

function LiveUndoVaRejouerImmediatementUnAutreCoup : boolean;
begin
  LiveUndoVaRejouerImmediatementUnAutreCoup := LiveUndoEnCours & (gLiveUndoData.devraRejouerSurLaNouvelleCase);
end;



function SourisEstSurLePlateauDansLiveUndo(var whichSquare : SInt16) : boolean;
var mouseLoc : Point;
    oldPort : grafPtr;
begin
  GetPort(oldPort);
  EssaieSetPortWindowPlateau;
  GetMouse(mouseLoc);
  SourisEstSurLePlateauDansLiveUndo := PtInPlateau(mouseLoc,whichSquare);
  SetPort(oldPort);
end;


procedure SwitchHumainContreHumainDansLiveUndo;
begin
  DoDemandeChangerHumCtreHum;
  EffectueTacheInterrompante(interruptionReflexion);
  GererDemandesChangementDeConfig;
  LanceInterruptionSimpleConditionnelle('SwitchHumainContreHumainDansLiveUndo');
  gLiveUndoData.changementTemporaireDeHumCtreHum := not(gLiveUndoData.changementTemporaireDeHumCtreHum);
end;


procedure EssayerJouerNouveauCoupDansLiveUndo(caseDeLaSouris : SInt16);
begin
  with gLiveUndoData do
    if enCours & (numeroClicCommencement = GetCompteurDeMouseEvents) &
       StillDown & (nbreCoup = numeroDuCoupAuCommencement - 1) & not(analyseRetrograde.enCours) &
       (caseDeLaSouris >= 11) & (caseDeLaSouris <= 88) & possibleMove[caseDeLaSouris] &
       EstLaPositionCourante(positionUnCoupAvantLeClic) &
       (TickCount > tickDuClic + delai) &
       (interruptionReflexion = pasdinterruption)
       then
         begin

           { on joue le coup sous la souris }
           TraiteCoupImprevu(caseDeLaSouris);

           { indiquer a la bibliotheque de zebra et a la liste d'arreter de calculer }
           if (nbreCoup = numeroDuCoupAuCommencement) then
             begin
               IncrementerMagicCookieOfZebraBook;
               IncrementeMagicCookieDemandeCalculsBase;
             end;

           { on indique que l'on vient de realiser notre promesse de jouer sur cette case }
           devraRejouerSurLaNouvelleCase := false;

           { on repasse eventuellement en mode Cassio contre Humain }
           if changementTemporaireDeHumCtreHum & (HumCtreHum <> HumCtreHumEntreeLiveUndo) & (AQuiDeJouer <> couleurMacintosh)
             then SwitchHumainContreHumainDansLiveUndo;

           { on affiche eventuellement le numero du coup }
           if afficheNumeroCoupAuCommencement & not(afficheNumeroCoup) then
             DoChangeAfficheDernierCoup;


           AccelereProchainDoSystemTask(2);
         end;
end;


procedure EssayerAnnulerCoupDansLiveUndo(caseDeLaSouris : SInt16);
var currentNodeEstUneFeuilleDeLArbre : boolean;
    tempoAfficheNumeroCoup : boolean;
    positionUnCoupAvant : PositionEtTraitRec;
    positionResultante : PositionEtTraitRec;
begin
  with gLiveUndoData do
    if enCours & (numeroClicCommencement = GetCompteurDeMouseEvents) &
       StillDown & (nbreCoup = numeroDuCoupAuCommencement) & not(analyseRetrograde.enCours) &
       (caseDeLaSouris >= 11) & (caseDeLaSouris <= 88) & (caseDeLaSouris <> DerniereCaseJouee) &
       GetPositionEtTraitACeNoeud(GetFather(GetCurrentNode), positionUnCoupAvant, 'EssayerAnnulerCoupDansLiveUndo') &
       SamePositionEtTrait(positionUnCoupAvant,positionUnCoupAvantLeClic) &
       (TickCount > tickDuClic + delai) &
       (interruptionReflexion = pasdinterruption)
       then
         begin

           currentNodeEstUneFeuilleDeLArbre := (NumberOfRealSons(GetCurrentNode) <= 0);

           {on essaie d'eviter le flickering sur le numéro du coup}
           tempoAfficheNumeroCoup := afficheNumeroCoup;
           if afficheNumeroCoup then DoChangeAfficheDernierCoup;

           {on détermine si la souris est sur un autre coup legal}
           devraRejouerSurLaNouvelleCase := PeutReculerUnCoupPuisJouerSurCetteCase(caseDeLaSouris,positionResultante);

           { indiquer a la bibliotheque de zebra et a la liste d'arreter de calculer }
           IncrementerMagicCookieOfZebraBook;
           IncrementeMagicCookieDemandeCalculsBase;

           { on déjoue le dernier coup...}
           if currentNodeEstUneFeuilleDeLArbre & not(DerniereCaseJouee in coupsAGarderDansLiveUndo)
             then DetruitSousArbreCourantEtBackMove
             else DoBackMove;

           { encore }
           IncrementerMagicCookieOfZebraBook;
           IncrementeMagicCookieDemandeCalculsBase;

           { on passe en Humain contre Humain pour eviter que Cassio ne rejoue immediatement }
           if not(HumCtreHum) & not(CassioEstEnModeAnalyse) & (AQuiDeJouer = couleurMacintosh) & not(changementTemporaireDeHumCtreHum)
             then SwitchHumainContreHumainDansLiveUndo;

           { ...et on rejoue éventuellement le nouveau coup immédiatement}
           if devraRejouerSurLaNouvelleCase then
              EssayerJouerNouveauCoupDansLiveUndo(caseDeLaSouris);

           {on rétablit l'affichage du numéro du dernier coup}
           if tempoAfficheNumeroCoup & not(afficheNumeroCoup)
              & not(devraRejouerSurLaNouvelleCase & (nbreCoup = numeroDuCoupAuCommencement - 1))
             then DoChangeAfficheDernierCoup;

           AccelereProchainDoSystemTask(2);
         end;
end;


procedure GererLiveUndo;
var whichSquare : SInt16;
begin
  with gLiveUndoData do
    if enCours &
      (nbreNiveauxRecursion <= 2) & (TickCount <> dernierTickVerificationLiveUndo) &
      (numeroClicCommencement = GetCompteurDeMouseEvents) & StillDown
      then
        begin
          inc(nbreNiveauxRecursion);
          dernierTickVerificationLiveUndo := TickCount;

          if SourisEstSurLePlateauDansLiveUndo(whichSquare)
            then
              begin
                // la souris est dans l'othellier
                if (nbreCoup = numeroDuCoupAuCommencement)
                  then EssayerAnnulerCoupDansLiveUndo(whichSquare)
                  else EssayerJouerNouveauCoupDansLiveUndo(whichSquare);
              end
            else
              begin
                // la souris est en dehors de l'othellier : on fait "comme si"
                // elle était sur une case non vide
                if (nbreCoup = numeroDuCoupAuCommencement)
                  then EssayerAnnulerCoupDansLiveUndo(TrouverUneCaseRemplie(JeuCourant));
              end;

          dec(nbreNiveauxRecursion);
        end;
end;


procedure BeginLiveUndo(coupsProteges : SquareSet; nbreDeTicksDeDelai : SInt32);
var square : SInt32;
begin
  Discard(square);
  if PeutReculerUnCoup & not(analyseRetrograde.enCours) & StillDown then
    begin
      with gLiveUndoData do
        begin
          tickDuClic                       := TickCount;
          enCours                          := true;
          delai                            := nbreDeTicksDeDelai;
          numeroClicCommencement           := GetCompteurDeMouseEvents;
          coupsAGarderDansLiveUndo         := coupsProteges;
          numeroDuCoupAuCommencement       := nbreCoup;
          caseSousLaSourisAuCommencement   := DerniereCaseJouee;
          HumCtreHumEntreeLiveUndo         := HumCtreHum;
          changementTemporaireDeHumCtreHum := false;
          devraRejouerSurLaNouvelleCase    := false;
          afficheNumeroCoupAuCommencement  := afficheNumeroCoup;

          {for square := 11 to 88 do
             if square in coupsAGarderDansLiveUndo then
               WritelnStringAndCoupDansRapport(' à garder : ',square);}

          if GetPositionEtTraitACeNoeud(GetFather(GetCurrentNode), positionUnCoupAvantLeClic, 'BeginLiveUndo')
            then
              begin   { c'est parti ! }
                GererLiveUndo;
              end
            else
              begin   { y'a une erreur, on arrete tout }
                WritelnDansRapport('ERREUR dans BeginLiveUndo, prévenez Stéphane');
                EndLiveUndo;
              end;
        end;
    end;
end;


procedure EndLiveUndo;
begin
  with gLiveUndoData do
    if enCours then
      begin
        enCours := false;
        numeroClicCommencement := -1000;
        numeroDuCoupAuCommencement := -1000;

        { tout remettre comme au debut }
        if HumCtreHum <> HumCtreHumEntreeLiveUndo
          then DoDemandeChangerHumCtreHum;
        if afficheNumeroCoup <> afficheNumeroCoupAuCommencement
          then DoChangeAfficheDernierCoup;

        MarquerCurrentNodeCommeReel('EndLiveUndo');
      end;
end;


END.






























