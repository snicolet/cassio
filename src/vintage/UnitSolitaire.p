UNIT UnitSolitaire;



INTERFACE







 USES UnitDefCassio;





function EstUnSolitaire(var meilleurX,bstdef : SInt32; couleur,MFprof,nbBl,nbNo : SInt32; const jeu : plateauOthello; var empl : plBool; var frontiere : InfoFront; var score,nbreMeilleurs : SInt32; pourVraimentJouer : boolean; var causeRejet : SInt32; traitement,scoreaatteindre : SInt32) : boolean;
procedure PlaquerSolitaire(PositionEtCommentaire : String255);
function CassioEstEnRechercheSolitaire : boolean;



procedure ParserCommentaireSolitaire(commentaire : String255; var promptGras,resteDuCommentaire : String255);
function PeutParserReferencesSolitaire(references : String255; var noir,blanc,tournoi : String255) : boolean;


procedure DoDialogueConfigurationSolitaires;
procedure DoEstUnSolitaire;
procedure DoAfficheFelicitations;
procedure EssaieAfficherFelicitation;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDebuggage, MacErrors, OSUtils, Sound, MacWindows, QuickdrawText, Fonts
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw
    , UnitActions, UnitUtilitairesFinale, Unit_AB_simple, UnitSetUp, UnitFenetres, UnitPhasesPartie, UnitScannerUtils, UnitSuperviseur
    , UnitStrategie, UnitPackedOthelloPosition, UnitSolve, UnitEvenement, UnitStatistiqueDeSolitaire, UnitRapportImplementation, UnitCarbonisation, UnitUtilitaires
    , SNEvents, UnitCurseur, UnitRapport, UnitJaponais, UnitServicesDialogs, UnitMoveRecords, UnitAffichageReflexion, UnitSolitairesNouveauFormat
    , MyStrings, UnitDialog, UnitGestionDuTemps, UnitModes, UnitAffichagePlateau, UnitListe, UnitMenus, UnitCourbe, UnitJeu
    , UnitNormalisation, UnitGeometrie, MyMathUtils, MyFonts, UnitPalette, MyFileSystemUtils, UnitPositionEtTrait, basicfile
    , UnitServicesMemoire, UnitSound, UnitModes ;
{$ELSEC}
    ;
    {$I prelink/Solitaire.lk}
{$ENDC}


{END_USE_CLAUSE}









const profPourTriSelonDivergenceDansSolitaire = 6;
      profMinimalePourUtilisationMilieuSolitaire = 12;

type KillerTableSolitaires = array[0..kNbMaxNiveaux, 1..64] of SInt32;
     KillerTableSolitairesPtr = ^KillerTableSolitaires;
     KillingTableSolitaires = {packed} array[0..kNbMaxNiveaux, 0..99] of boolean;
     KillingTableSolitairesPtr = ^KillingTableSolitaires;




function EstUnSolitaire(var meilleurX,bstdef : SInt32; couleur,MFprof,nbBl,nbNo : SInt32;
                        const jeu : plateauOthello; var empl : plBool; var frontiere : InfoFront;
                        var score,nbreMeilleurs : SInt32; pourVraimentJouer : boolean;
                        var causeRejet : SInt32; traitement,scoreaatteindre : SInt32) : boolean;
const BoutonOui = 1;
      BoutonNon = 2;
      MaxNbreLignesAutorisees = 800;
var CoulAttaque,coulDefense : SInt32;
    modeGagnantPerdant : boolean;
    killing : KillingTableSolitairesPtr;
    nbkiller : array[0..kNbMaxNiveaux] of SInt32;
    killer : KillerTableSolitairesPtr;
    fils : array[11..88] of SInt32;
    nbCasesVides : SInt32;
    casesVides : array[1..64] of SInt32;
    gNbreCasesVidesSansCoinsEntreeSolitaire : SInt32;                  { SC = sans les coins }
    casesVidesSC : array[1..64] of SInt32;
    nbCoinsVides : SInt32;
    coinsvides : array[1..4] of SInt32;
    move : plBool;
    mob : SInt32;
    maxcoupGagnant : SInt32;
    classement,classProv : ListOfMoveRecords;
    iCourant : SInt32;
    premierePasse : boolean;
    item : SInt32;
    defense : SInt32;
    MFniv : SInt32;
    platClass : plateauOthello;
    jouableClass : plBool;
    nbBlancClass,nbNoirClass : SInt32;
    frontClass : InfoFront;
    noteClass,limSup : SInt32;
    suiteJouee : t_suiteJouee;
    meilleureSuite : meilleureSuitePtr;
    nbVidesQuadrant : array[0..3] of SInt32;
    solitaireJusquaPresent : boolean;
    nbCoupsOfferts,maxCoupsOfferts : SInt32;
    CalculMobiliteFait : boolean;
    solitaireGagnant : boolean;
    posEcriture : SInt32;
    CouleurOrdi : SInt32;
    CouleurHumain : SInt32;
    fichierSolution : basicfile;
    FenetreMessage : WindowPtr;
    InterruptionCalculSuites : boolean;
    nbrelignesSolution,nbreLigneH,nbreLigneV : SInt32;
    avecEcritureScoreDansSolution : boolean;
    s,s1 : String255;
    info : fileInfo;
    nomPrec : String255;
    nroCoupRecherche : SInt32;
    nbreAppelsABSol : SInt32;
    nbCoupsNonPerdants,scoreWLDOptimal : SInt32;
    oldCassioEstEnTrainDeReflechir : boolean;
    plat : plateauOthello;
label exit_EstUnSolitaire;

procedure EcritParametresDansRapport;
begin
  WritelnNumDansRapport('couleur = ',couleur);
  WritelnNumDansRapport('MFprof = ',MFprof);
  WritelnNumDansRapport('nbBl = ',nbBl);
  WritelnNumDansRapport('nbNo = ',nbNo);
  WritelnPositionEtTraitDansRapport(jeu,couleur);
  WritelnStringAndBooleenDansRapport('PourVraimentJouer = ',PourVraimentJouer);
  WritelnNumDansRapport('traitement = ',traitement);
  WritelnNumDansRapport('scoreaatteindre = ',scoreaatteindre);
 end;


function EtablitListeCasesVidesSolitaire(var plat : plateauOthello; prof : SInt32; var listeCasesVides : listeVides) : SInt32;
var nbVidesTrouvees,i,caseTestee : SInt32;
begin
  nbVidesTrouvees := 0;
  i := 0;
  repeat
    inc(i);
    caseTestee := casesVides[i];
    if plat[caseTestee] = pionVide then
      begin
        inc(nbVidesTrouvees);
        listeCasesVides[nbVidesTrouvees] := caseTestee;
      end;
  until nbVidesTrouvees >= prof;

  EtablitListeCasesVidesSolitaire := nbVidesTrouvees;
end;



function DoitPasserSol(couleur : SInt32; var plat : plateauOthello) : boolean;
var x,t : SInt32;
begin
   for t := 1 to nbCasesVides do
   begin
    x := casesVides[t];
    if plat[x] = pionVide then
     if PeutJouerIci(couleur,x,plat) then
       begin
         DoitPasserSol := false;
         exit;
       end;
   end;
   DoitPasserSol := true;
end;


function DernierCoupSolitaire(var plat : plateauOthello; var meilleureDefense : SInt32; couleur,nBla,nNoi : SInt32) : SInt32;
var i : SInt32;
    adversaire : SInt32;
    iCourant : SInt32;
begin
   adversaire := -couleur;

   for i := 1 to nbCasesVides do
   BEGIN
    iCourant := casesVides[i];
    if plat[iCourant] = pionVide then
      begin
        if ModifScoreFin(iCourant,couleur,plat,nBla,nNoi)
          then
            begin
              suiteJouee[1] := iCourant;
              meilleureSuite^[1,1] := iCourant;
              meilleureDefense := iCourant;
              if adversaire = pionBlanc
                then DernierCoupSolitaire := nNoi-nBla
                else DernierCoupSolitaire := nBla-nNoi;
              exit;
            end
          else
            begin
              if ModifScoreFin(iCourant,adversaire,plat,nBla,nNoi)
                then
                  begin
                    suiteJouee[1] := iCourant;
                    meilleureSuite^[1,1] := iCourant;
                    meilleureDefense := iCourant;
                    if adversaire = pionBlanc
                      then DernierCoupSolitaire := nNoi-nBla
                      else DernierCoupSolitaire := nBla-nNoi;
                    exit;
                  end
                else
                  begin
                    meilleureSuite^[1,1] := 0;
                    if couleur = pionBlanc
                      then DernierCoupSolitaire := nBla-nNoi
                      else DernierCoupSolitaire := nNoi-nBla;
                    exit;
                  end;
            end
      end;
   END;

   (*
   SysBeep(0);
   WriteStringAt('SHOULD NEVER HAPPEN IN DERNIER COUP !',10,150);
   Ecritpositionat(plat,100,100);
   *)

   if couleur = pionBlanc
      then DernierCoupSolitaire := nBla-nNoi
      else DernierCoupSolitaire := nNoi-nBla;
end;   { DernierCoupSolitaire }


function ABSolPetite(var plat : plateauOthello; var meilleureDefense : SInt32; pere,couleur,ESprof,alpha,beta,nBla,nNoi : SInt32;
                     var nbreMeilleurs : SInt32; var solitaire : boolean) : SInt32;
{ABSol pour les petites profondeurs (  <= 4 )}
var platEssai : plateauOthello;
    nbBlcEssai,nbNrEssai : SInt32;
    nbreSuitesEssai : SInt32;
    solitaireEssai : boolean;
    index,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante,t : SInt32;
    maxPourBestDef : SInt32;
    aJoue : boolean;
    nbVidesTrouvees : SInt32;
    iCourant : SInt32;
    bestSuite : SInt32;
    localBidBool_ABSolPetite : boolean;
    {dejaEvaluee : plBool;}
label fin;

begin
if interruptionReflexion = pasdinterruption then
 begin

   inc(nbreAppelsABSol);
   (*
   WriteNumAt('--> ABSol Petite         ',nbreAppelsABSol,10,150);
   EssaieSetPortWindowPlateau;
   EcritPositionat(plat,10,30);
   *)


   adversaire := -couleur;
   profMoins1 := ESprof-1;
   maxPourBestDef := -noteMax;
   nbreMeilleurs := 0;
   aJoue := false;
   nbVidesTrouvees := 0;

   platEssai := plat;
   nbBlcEssai := nBla;
   nbNrEssai := nNoi;

   index := 0;
   while index < nbCasesVides do
   BEGIN
    index := succ(index);
    iCourant := casesVides[index];
    if plat[iCourant] = pionVide then
      begin
        inc(nbVidesTrouvees);
        if ModifPlatFin(iCourant,couleur,platEssai,nbBlcEssai,nbNrEssai) then
          BEGIN
           suiteJouee[ESprof] := iCourant;
           aJoue := true;

           if (profMoins1 <= 1)
             then
               begin
                 noteCourante := -DernierCoupSolitaire(platEssai,bestSuite,adversaire,nbBlcEssai,nbNrEssai);
                 if (0 < noteCourante) and (noteCourante < maxPourBestDef)
                   then
                     begin
                       solitaire := false;
                       solitaireEssai := false;
                     end
                   else
                     solitaireEssai := true;
               end
             else
               begin
                 noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                              -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
                 if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                   begin
                     t := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                     -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSolPetite);
                     if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                   end;
               end;


           if (noteCourante = maxPourBestDef) then
              begin
                nbreMeilleurs := nbreMeilleurs+1;
                if not(senslargeSolitaire)
                  then solitaire := false
                  else
                    begin
                     if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
                       then
                         begin
                           if solitaireEssai then
                             begin
                               solitaire := true;
                               for k := 1 to profMoins1 do
                                  meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                               meilleureSuite^[ESprof,ESprof] := iCourant;
                               meilleureDefense := iCourant;
                             end;
                         end
                       else
                         solitaire := false;
                    end;
              end;
           if (noteCourante > maxPourBestDef) then
              begin
                nbreMeilleurs := 1;
                for k := 1 to profMoins1 do
                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                meilleureSuite^[ESprof,ESprof] := iCourant;
                meilleureDefense := iCourant;
                solitaire := solitaireEssai;
                if (maxPourBestDef > 0) then
                  begin
                    solitaire := false;
                  end;
                maxPourBestDef := noteCourante;
                if (noteCourante > alpha) then
                  begin
                    alpha := noteCourante;
                    if (alpha > beta) then
                       begin
                         ABSolPetite := maxPourBestDef;
                         fils[pere] := iCourant;
                         exit;
                       end;
                  end;
              end;

           if nbVidesTrouvees >= ESprof then
             begin
               ABSolPetite := maxPourBestDef;
               exit;
             end;

           platEssai := plat;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;
          end
           else
            if nbVidesTrouvees >= ESprof then goto fin;
       end;
   end;

 fin:
  if not(aJoue) then
      begin
        (*
        EssaieSetPortWindowPlateau;
        EcritPositionat(plat,10,200);

        if not(DoitPasserSol(couleur,plat)) then SysBeep(0);
        *)
        if DoitPasserSol(adversaire,plat) then
          begin
            if couleur = pionBlanc
               then ABSolPetite := nBla-nNoi
               else ABSolPetite := nNoi-nBla;
            for k := 1 to ESprof do meilleureSuite^[ESprof,k] := 0;
            solitaire := true;
          end
        else
          begin
            ABSolPetite := -ABSolPetite(plat,meilleureDefense,pere,adversaire,ESprof,
                                      -beta,-alpha,nBla,nNoi,nbreMeilleurs,solitaire);
          end;
      end  {if not aJoue}
  else ABSolPetite := maxPourBestDef;
 end;
end;   { ABSolPetite }


function ABSol(var plat : plateauOthello; var meilleureDefense : SInt32; pere,couleur,ESprof,alpha,beta,nBla,nNoi : SInt32;
               var nbreMeilleurs : SInt32; var solitaire : boolean) : SInt32;
var platEssai : plateauOthello;
    nbBlcEssai,nbNrEssai : SInt32;
    nbreSuitesEssai : SInt32;
    solitaireEssai : boolean;
    filsDePere,k : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDef : SInt32;
    aJoue : boolean;
    nbVidesTrouvees : SInt32;
    iCourant : SInt32;
    t,index : SInt32;
    bestSuite : SInt32;
    localBidBool_ABSol : boolean;
label fin;

begin
if (interruptionReflexion = pasdinterruption) then
 begin
   (*
   EssaieSetPortWindowPlateau;
   EcritPositionat(plat,210,30);
   *)

   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

   adversaire := -couleur;
   profMoins1 := ESprof-1;
   maxPourBestDef := -noteMax;
   nbreMeilleurs := 0;
   aJoue := false;
   nbVidesTrouvees := 0;

   platEssai := plat;
   nbBlcEssai := nBla;
   nbNrEssai := nNoi;



   inc(nbreAppelsABSol);
   (*EssaieSetPortWindowPlateau;
   WriteNumAt('--> ABSol         ',nbreAppelsABSol,10,150);
   WriteNumAt('nbCoinsVides = ',nbCoinsVides,10,160);
   WriteNumAt('gNbreCasesVidesSansCoinsEntreeSolitaire = ',gNbreCasesVidesSansCoinsEntreeSolitaire,10,170);
   WriteNumAt('nbCasesVides = ',nbCasesVides,10,180);*)

   FilsDePere := fils[pere];
   (*
   WriteNumAt('pere = ',pere,100,190);
   WriteNumAt('FilsDePere = ',FilsDePere,10,190);
   if (pere < 11) or (pere > 88) then
     begin
       SysBeep(0);
       AttendFrappeClavier;
     end;
   *)
   if FilsDePere <> 0 then
   BEGIN
    iCourant := FilsDePere;
    (* WriteNumAt('test de filsdepere = ',filsdepere,10,10);AttendFrappeClavier; *)
    if plat[iCourant] = pionVide then
      begin
        inc(nbVidesTrouvees);
        if ModifPlatFin(iCourant,couleur,platEssai,nbBlcEssai,nbNrEssai) then
          begin
           suiteJouee[ESprof] := iCourant;
           aJoue := true;

           if (profMoins1 <= 4) then
             begin
               noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end
           else
             begin
               noteCourante := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,-beta,-alpha,
                                    nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,-1,0,
                            nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end;

           if (noteCourante = maxPourBestDef) then
              begin
                nbreMeilleurs := nbreMeilleurs+1;
                if not(senslargeSolitaire)
                  then solitaire := false
                  else
                    begin
                     if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
                       then
                         begin
                           if solitaireEssai then
                             begin
                               solitaire := true;
                               for k := 1 to profMoins1 do
                                  meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                               meilleureSuite^[ESprof,ESprof] := iCourant;
                               meilleureDefense := iCourant;
                             end;
                         end
                       else
                         solitaire := false;
                    end;
              end;
           if (noteCourante > maxPourBestDef) then
              begin
                nbreMeilleurs := 1;
                solitaire := solitaireEssai;
                if (maxPourBestDef > 0) then solitaire := false;
                maxPourBestDef := noteCourante;
                for k := 1 to profMoins1 do
                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                meilleureSuite^[ESprof,ESprof] := iCourant;
                meilleureDefense := iCourant;
                if (noteCourante > alpha) then
                  begin
                    alpha := noteCourante;
                    if (alpha > beta) then
                       begin
                         ABSol := maxPourBestDef;
                         exit;
                       end;
                  end;
              end;

           platEssai := plat;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;
          end;
       end;
   end;


   index := 0;
   while index < nbCoinsVides do
   BEGIN
    index := succ(index);
    iCourant := coinsvides[index];

    (*
    if iCourant = 0 then SysBeep(0);
    *)

    (*
    WriteNumAt('test (dans petite boucle) de iCourant = ',iCourant,10,10);
    WriteNumAt('index = ',index,10,20);
    AttendFrappeClavier;
    *)
    if iCourant <> filsDePere then
    if (platEssai[iCourant] = 0) then
      begin
        inc(nbVidesTrouvees);
        if ModifPlatFin(iCourant,couleur,platEssai,nbBlcEssai,nbNrEssai) then
          BEGIN
           suiteJouee[ESprof] := iCourant;
           aJoue := true;


           if (profMoins1 <= 4) then
             begin
               noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end
           else
             begin
               noteCourante := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,-beta,-alpha,
                                    nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end;

           if (noteCourante = maxPourBestDef) then
              begin
                nbreMeilleurs := nbreMeilleurs+1;
                if not(senslargeSolitaire)
                  then solitaire := false
                  else
                    begin
                     if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
                       then
                         begin
                           if solitaireEssai then
                             begin
                               solitaire := true;
                               for k := 1 to profMoins1 do
                                  meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                               meilleureSuite^[ESprof,ESprof] := iCourant;
                               meilleureDefense := iCourant;
                             end;
                         end
                       else
                         solitaire := false;
                    end;
              end;
           if (noteCourante > maxPourBestDef) then
              begin
                nbreMeilleurs := 1;
                solitaire := solitaireEssai;
                if (maxPourBestDef > 0) then solitaire := false;
                maxPourBestDef := noteCourante;
                for k := 1 to profMoins1 do
                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                meilleureSuite^[ESprof,ESprof] := iCourant;
                meilleureDefense := iCourant;
                if (noteCourante > alpha) then
                  begin
                    alpha := noteCourante;
                    if (alpha > beta) then
                       begin
                         ABSol := maxPourBestDef;
                         fils[pere] := iCourant;
                         exit;
                       end;
                  end;
              end;

           if nbVidesTrouvees >= ESprof then
             begin
               ABSol := maxPourBestDef;
               exit;
             end;

           platEssai := plat;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;
          end
        else
          if nbVidesTrouvees >= ESprof then goto fin;
       end;
   end;


   (*
   for index := 1 to nbCoinsVides do
   begin
    iCourant := coinsvides[index];
    WriteNumAt('test (dans grande boucle) de iCourant = ',iCourant,10,10);
    WriteNumAt('index = ',index,10,20);
    AttendFrappeClavier;

   end;
   *)

   if (nbkiller[ESprof] <> 0) then
     begin
       index := nbkiller[ESprof]+1;
       while index > 1 do
		   BEGIN
		    index := pred(index);
		    iCourant := killer^[ESprof,index];
		    if plat[iCourant] = pionVide then
		    if iCourant <> FilsDePere then
		      begin
		        inc(nbVidesTrouvees);
		        if ModifPlatFin(iCourant,couleur,platEssai,nbBlcEssai,nbNrEssai) then
		          begin
		           suiteJouee[ESprof] := iCourant;
		           aJoue := true;

		           if (profMoins1 <= 4) then
		             begin
		               noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
		                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
		               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
		                 begin
		                   t := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
		                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
		                   if (t > 0) then
		                       begin
		                         solitaire := false;
		                         solitaireEssai := false;
		                       end;
		                 end;
		             end
		           else
		             begin
		               noteCourante := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,
		                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
		               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
		                 begin
		                   t := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,
		                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
		                   if (t > 0) then
		                       begin
		                         solitaire := false;
		                         solitaireEssai := false;
		                       end;
		                 end;
		             end;

		           if (noteCourante = maxPourBestDef) then
		              begin
		                nbreMeilleurs := nbreMeilleurs+1;
		                if not(senslargeSolitaire)
		                  then solitaire := false
		                  else
		                    begin
		                     if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
		                       then
		                         begin
		                           if solitaireEssai then
		                             begin
		                               solitaire := true;
		                               for k := 1 to profMoins1 do
		                                  meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
		                               meilleureSuite^[ESprof,ESprof] := iCourant;
		                               meilleureDefense := iCourant;
		                             end;
		                         end
		                       else
		                         solitaire := false;
		                    end;
		              end;
		           if (noteCourante > maxPourBestDef) then
		              begin
		                nbreMeilleurs := 1;
		                solitaire := solitaireEssai;
		                if (maxPourBestDef > 0) then solitaire := false;
		                maxPourBestDef := noteCourante;
		                for k := 1 to profMoins1 do
		                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
		                meilleureSuite^[ESprof,ESprof] := iCourant;
		                meilleureDefense := iCourant;
		                if (noteCourante > alpha) then
		                  begin
		                    alpha := noteCourante;
		                    if (alpha > beta) then
		                       begin
		                         ABSol := maxPourBestDef;
		                         for t := index to nbkiller[ESprof]-1 do killer^[ESprof,t] := killer^[ESprof,t+1];
		                         killer^[ESprof,nbkiller[ESprof]] := iCourant;
		                         fils[pere] := iCourant;
		                         exit;
		                       end;
		                  end;
		              end;


		           if nbVidesTrouvees >= ESprof then
		             begin
		               ABSol := maxPourBestDef;
		               exit;
		             end;

		           platEssai := plat;
		           nbBlcEssai := nBla;
		           nbNrEssai := nNoi;
		          end
		           else
		            if nbVidesTrouvees >= ESprof then goto fin;
		       end;
		   end;
     end; {if (nbkiller[ESprof] <> 0) then}

   index := 0;
   while index < gNbreCasesVidesSansCoinsEntreeSolitaire do
   BEGIN
    index := succ(index);
    iCourant := casesVidesSC[index];

    if iCourant = 0 then SysBeep(0);

    (*
    EssaieSetPortWindowPlateau;
    WriteNumAt('test (dans gNbreCasesVidesSansCoinsEntreeSolitaire) de iCourant = ',iCourant,10,10);
    WriteNumAt('index = ',index,10,20);
    AttendFrappeClavier;
    *)
    if iCourant <> filsDePere then
    if platEssai[iCourant] = 0 then
    if not(killing^[ESprof,iCourant]) then
      begin
        inc(nbVidesTrouvees);
        if ModifPlatFin(iCourant,couleur,platEssai,nbBlcEssai,nbNrEssai) then
          begin
           suiteJouee[ESprof] := iCourant;
           aJoue := true;

           if (profMoins1 <= 4) then
             begin
               noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end
           else
             begin
               noteCourante := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                             -beta,-alpha,nbBlcEssai,nbNrEssai,nbreSuitesEssai,solitaireEssai);
               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
                 begin
                   t := -ABSol(platEssai,bestSuite,iCourant,adversaire,profMoins1,
                                   -1,0,nbBlcEssai,nbNrEssai,nbreSuitesEssai,localBidBool_ABSol);
                   if (t > 0) then
                       begin
                         solitaire := false;
                         solitaireEssai := false;
                       end;
                 end;
             end;

           if (noteCourante = maxPourBestDef) then
              begin
                nbreMeilleurs := nbreMeilleurs+1;
                if not(senslargeSolitaire)
                  then solitaire := false
                  else
                    begin
                     if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
                       then
                         begin
                           if solitaireEssai then
                             begin
                               solitaire := true;
                               for k := 1 to profMoins1 do
                                  meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                               meilleureSuite^[ESprof,ESprof] := iCourant;
                               meilleureDefense := iCourant;
                             end;
                         end
                       else
                         solitaire := false;
                    end;
              end;
           if (noteCourante > maxPourBestDef) then
              begin
                nbreMeilleurs := 1;
                solitaire := solitaireEssai;
                if (maxPourBestDef > 0) then solitaire := false;
                maxPourBestDef := noteCourante;
                for k := 1 to profMoins1 do
                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                meilleureSuite^[ESprof,ESprof] := iCourant;
                meilleureDefense := iCourant;
                if (noteCourante > alpha) then
                  begin
                    alpha := noteCourante;
                    if (alpha > beta) then
                       begin

                         nbkiller[ESprof] := nbkiller[ESprof]+1;
                         killer^[ESprof,nbkiller[ESprof]] := iCourant;
                         killing^[ESprof,iCourant] := true;


                         ABSol := maxPourBestDef;
                         fils[pere] := iCourant;
                         exit;
                       end;
                  end;
              end;

           if nbVidesTrouvees >= ESprof then
             begin
               ABSol := maxPourBestDef;
               exit;
             end;

           platEssai := plat;
           nbBlcEssai := nBla;
           nbNrEssai := nNoi;
          end
           else
            if nbVidesTrouvees >= ESprof then goto fin;
       end;
   end;

  fin:
  if not(aJoue) then
      begin
      (*
        EssaieSetPortWindowPlateau;
        EcritPositionat(plat,210,200);

        WriteNumAt('nbVidesTrouvees = ',nbVidesTrouvees,10,200);

        if not(DoitPasserSol(couleur,plat)) then
          begin
            SysBeep(0);
            AttendFrappeClavier;
          end;
        *)

        if DoitPasserSol(adversaire,plat) then
          begin
            if couleur = pionBlanc
               then ABSol := nBla-nNoi
               else ABSol := nNoi-nBla;
            for k := 1 to ESprof do meilleureSuite^[ESprof,k] := 0;
            solitaire := true;
          end
        else
          begin
            ABSol := -ABSol(plat,meilleureDefense,pere,adversaire,ESprof,
                          -beta,-alpha,nBla,nNoi,nbreMeilleurs,solitaire);
          end;
      end  {if not aJoue}
  else ABSol := maxPourBestDef;
 end;
end;   { ABSol }




function AlphaBetaSolitaireFast(var plat : plateauOthello; var meilleureDefense : SInt32; pere,couleur,ESprof,alpha,beta : SInt32;
               var nbreMeilleurs : SInt32; var solitaire : boolean; var infosMilieuDePartie : InfosMilieuRec) : SInt32;
var platEssai : plateauOthello;
    nbreSuitesEssai : SInt32;
    solitaireEssai : boolean;
    k,i : SInt32;
    adversaire,profMoins1 : SInt32;
    notecourante : SInt32;
    maxPourBestDef : SInt32;
    aJoue : boolean;
    nbVidesTrouvees : SInt32;
    nbCoupsPourCoul : SInt32;
    conseilHash : SInt32;
    iCourant : SInt32;
    note : SInt32;
    bestSuite : SInt32;
    evaluationDeLaPosition : SInt32;
    localBidBool_ABSol : boolean;
    utiliseMilieuDePartie : boolean;
    InfosMilieuEssai : InfosMilieuRec;
    listeCasesVides : listeVides;
    coupLegal : boolean;
    probableFailLow,probableFailHigh : boolean;
label fin;

begin
if (interruptionReflexion = pasdinterruption) then
 begin
   (*
   EssaieSetPortWindowPlateau;
   EcritPositionat(plat,210,30);
   *)

   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

   adversaire := -couleur;
   profMoins1 := ESprof-1;
   maxPourBestDef := -noteMax;
   nbreMeilleurs := 0;
   aJoue := false;
   conseilHash := 0;

   utiliseMilieuDePartie := (ESprof >= profMinimalePourUtilisationMilieuSolitaire);
   probableFailLow  := false;
   probableFailHigh := false;



   inc(nbreAppelsABSol);
   (*EssaieSetPortWindowPlateau;
   WriteNumAt('--> AlphaBetaSolitaireFast         ',nbreAppelsABSol,10,150);
   WriteNumAt('nbCoinsVides = ',nbCoinsVides,10,160);
   WriteNumAt('gNbreCasesVidesSansCoinsEntreeSolitaire = ',gNbreCasesVidesSansCoinsEntreeSolitaire,10,170);
   WriteNumAt('nbCasesVides = ',nbCasesVides,10,180);*)





   nbVidesTrouvees := EtablitListeCasesVidesSolitaire(plat,ESprof,listeCasesVides);
   if utiliseMilieuDePartie
     then
       nbCoupsPourCoul := TrierSelonDivergenceAvecMilieu(plat,couleur,nbVidesTrouvees,conseilHash,listeCasesVides,listeCasesVides,infosMilieuDePartie,
                                                         100*alpha,100*beta,probableFailLow,probableFailHigh,utiliseMilieuDePartie,evaluationDeLaPosition)
     else
		   if ESprof >= profPourTriSelonDivergenceDansSolitaire
		     then nbCoupsPourCoul := TrierSelonDivergenceSansMilieu(plat,couleur,nbVidesTrouvees,listeCasesVides,listeCasesVides)
		     else nbCoupsPourCoul := nbVidesTrouvees;

   (*
   WritelnPositionEtTraitDansRapport(plat,couleur);
   WritelnNumDansRapport('ESprof = ',ESprof);
   WritelnNumDansRapport('nbCoupsPourCoul = ',nbCoupsPourCoul);
   for i := 1 to nbCoupsPourCoul do
     begin
       WriteNumDansRapport('-- ',listeCasesVides[i]);
       WriteStringAndCoupDansRapport(' ',listeCasesVides[i]);
     end;
   WritelnDansRapport('');
   AttendFrappeClavier;
   *)

   platEssai := plat;
   if utiliseMilieuDePartie
     then
       begin
         InfosMilieuEssai := infosMilieuDePartie;
       end
     else
       begin
         InfosMilieuEssai.nbBlancs := infosMilieuDePartie.nbBlancs;
         InfosMilieuEssai.nbNoirs := infosMilieuDePartie.nbNoirs;
       end;

   for i := 1 to nbCoupsPourCoul do
	   BEGIN
	     iCourant := listeCasesVides[i];
	
	     //WritelnNumDansRapport('AlphaBetaSolitaireFast, coup = ',iCourant);


	     if (plat[iCourant] <> pionVide) then
	       AlerteSimple(' plat[iCourant] <> pionVide dans AlphaBetaSolitaireFast !!');

	     if utiliseMilieuDePartie
         then with InfosMilieuEssai do
           coupLegal := ModifPlatLongint(iCourant,couleur,platEssai,jouable,nbBlancs,nbNoirs,frontiere)
         else
           coupLegal := ModifPlatFin(iCourant,couleur,platEssai,InfosMilieuEssai.nbBlancs,InfosMilieuEssai.nbNoirs);


	     if coupLegal then
         begin
           suiteJouee[ESprof] := iCourant;
           aJoue := true;


           if (profMoins1 <= 4)
             then
	             begin
	               noteCourante := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
	                             -beta,-alpha,InfosMilieuEssai.nbBlancs,InfosMilieuEssai.nbNoirs,nbreSuitesEssai,solitaireEssai);
	               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
	                 begin
	                   note := -ABSolPetite(platEssai,bestSuite,iCourant,adversaire,profMoins1,
	                                   -1,0,InfosMilieuEssai.nbBlancs,InfosMilieuEssai.nbNoirs,nbreSuitesEssai,localBidBool_ABSol);
	                   if (note > 0) then
	                       begin
	                         solitaire := false;
	                         solitaireEssai := false;
	                       end;
	                 end;
	             end
             else
	             begin
	               noteCourante := -AlphaBetaSolitaireFast(platEssai,bestSuite,iCourant,adversaire,profMoins1,-beta,-alpha,
	                                                       nbreSuitesEssai,solitaireEssai,InfosMilieuEssai);
	               if (0 < noteCourante) and (noteCourante < maxPourBestDef) then
	                 begin
	                   note := -AlphaBetaSolitaireFast(platEssai,bestSuite,iCourant,adversaire,profMoins1,
	                                                   -1,0,nbreSuitesEssai,localBidBool_ABSol,InfosMilieuEssai);
	                   if (note > 0) then
	                       begin
	                         solitaire := false;
	                         solitaireEssai := false;
	                       end;
	                 end;
	             end;

           if (noteCourante = maxPourBestDef) then
	            begin
	              nbreMeilleurs := nbreMeilleurs+1;
	              if not(senslargeSolitaire)
	                then solitaire := false
	                else
	                  begin
	                   if ((noteCourante < 0) or ((noteCourante = 0) and (couleur = couldefense)))
	                     then
	                       begin
	                         if solitaireEssai then
	                           begin
	                             solitaire := true;
	                             for k := 1 to profMoins1 do
	                                meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
	                             meilleureSuite^[ESprof,ESprof] := iCourant;
	                             meilleureDefense := iCourant;
	                           end;
	                       end
	                     else
	                       solitaire := false;
	                  end;
	            end;
           if (noteCourante > maxPourBestDef) then
              begin
                nbreMeilleurs := 1;
                solitaire := solitaireEssai;
                if (maxPourBestDef > 0) then solitaire := false;
                maxPourBestDef := noteCourante;
                for k := 1 to profMoins1 do
                   meilleureSuite^[ESprof,k] := meilleureSuite^[profMoins1,k];
                meilleureSuite^[ESprof,ESprof] := iCourant;
                meilleureDefense := iCourant;
                if (noteCourante > alpha) then
                  begin
                    alpha := noteCourante;
                    if (alpha > beta) then
                       begin
                         AlphaBetaSolitaireFast := maxPourBestDef;
                         exit;
                       end;
                  end;
              end;

           (*
           if not(pourVraimentJouer) and (couleur = CoulAttaque) and
              (maxPourBestDef > 0) and not(solitaire) then
              begin
                AlphaBetaSolitaireFast := maxPourBestDef;
                exit;
              end;
            *)

           platEssai := plat;
           if utiliseMilieuDePartie
				     then
				       begin
				         InfosMilieuEssai := infosMilieuDePartie;
				       end
				     else
				       begin
				         InfosMilieuEssai.nbBlancs := infosMilieuDePartie.nbBlancs;
				         InfosMilieuEssai.nbNoirs := infosMilieuDePartie.nbNoirs;
				       end;
         end;
     END;


  fin:
  if not(aJoue) then
      begin
      (*
        EssaieSetPortWindowPlateau;
        EcritPositionat(plat,210,200);

        WriteNumAt('nbVidesTrouvees = ',nbVidesTrouvees,10,200);

        if not(DoitPasserSol(couleur,plat)) then
          begin
            SysBeep(0);
            AttendFrappeClavier;
          end;
        *)

        if DoitPasserSol(adversaire,plat) then
          begin
            if couleur = pionBlanc
               then AlphaBetaSolitaireFast := infosMilieuDePartie.nbBlancs-infosMilieuDePartie.nbNoirs
               else AlphaBetaSolitaireFast := infosMilieuDePartie.nbNoirs-infosMilieuDePartie.nbBlancs;
            for k := 1 to ESprof do meilleureSuite^[ESprof,k] := 0;
            solitaire := true;
          end
        else
          begin
            AlphaBetaSolitaireFast := -AlphaBetaSolitaireFast(plat,meilleureDefense,pere,adversaire,ESprof,
                                          -beta,-alpha,nbreMeilleurs,solitaire,infosMilieuDePartie);
          end;
      end  {if not aJoue}
  else AlphaBetaSolitaireFast := maxPourBestDef;
 end;
end;   { AlphaBetaSolitaireFast }


procedure MinimaxSolitaire(couleurmini,MiniProf,longClass,nbBla,nbNoi : SInt32; jeu : plateauOthello; var class : ListOfMoveRecords);
var Xcourant : SInt32;
    valXY : SInt32;
    platMod : plateauOthello;
    InfosMilieuMod : InfosMilieuRec;
    nbreDefensesMod : SInt32;
    coupLegal : boolean;
    testsolitaire : boolean;
    lignecritique : boolean;
    sortieDeBoucle : boolean;
    classAux : ListOfMoveRecords;
    i,j,k,compteur : SInt32;
    indice_du_meilleur : SInt32;
    noteModif : SInt32;
    bestAB : SInt32;
    alphaAB,betaAb : SInt32;
    TickChrono,TempsDeXCourant : SInt32;
    oldport : grafPtr;

    {valXYFast : SInt32;
    testsolitaireFast : boolean;}
    tickComparaisonFast : SInt32;
    tempsComparaisonFast : SInt32;
    tableauComparaison : array[0..15,0..15] of SInt32;


 procedure DisplayTableauComparaison(index1EnCours,index2EnCours : SInt32);
 var i,j : SInt32;
 begin
   EssaieSetPortWindowPlateau;
   for i := 0 to 15 do
     for j := 0 to 15 do
       if (i = index1EnCours) and (j = index2EnCours)
         then WriteNumAt('*',tableauComparaison[i,j],10+i*50,10+j*15)
         else WriteNumAt(' ',tableauComparaison[i,j],10+i*50,10+j*15);
 end;

begin
if (interruptionReflexion = pasdinterruption) then
 begin

  {if couleurmini = pionNoir
    then WriteNumAt('pionNoir et prof = ' , MiniProf, 10, 120)
    else WriteNumAt('pionBlanc et prof = ' , MiniProf, 10, 120);}

  if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

  MemoryFillChar(meilleureSuite,sizeof(t_meilleureSuite),chr(0));
  indice_du_meilleur := longClass;
  if (traitement = kSortiePapier) or (traitement = kSortiePapierCourte)
     then maxCoupsOfferts := noteMax
     else maxCoupsOfferts := -noteMax;
  bestAB := -noteMax;
  if PourVraimentJouer
    then
      begin
        alphaAB := -noteMax;
        betaAB := noteMax;
      end
    else
      begin
        alphaAB := -1;
        betaAB := noteMax;
      end;

  for i := 0 to 15 do
    for j := 0 to 15 do
      tableauComparaison[i,j] := 0;

  classAux := class;
  for i := 1 to 64 do classAux[i].note := -noteMax;
  compteur := 0;
  sortieDeBoucle := false;
  repeat

    if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);

    compteur := compteur+1;
    Xcourant := class[compteur].x;
    if (class[compteur].theDefense >= 11) and (class[compteur].theDefense <= 88) then
      fils[Xcourant] := class[compteur].theDefense;


    platMod := jeu;
    with InfosMilieuMod do
      begin
        nbBlancs := nbBla;
        nbNoirs := nbNoi;
      end;
    CarteJouable(platMod,InfosMilieuMod.jouable);
    CarteFrontiere(platMod,InfosMilieuMod.frontiere);

    //WritelnNumDansRapport('AlphaBetaSolitaireFast, coup = ',XCourant);


    coupLegal := ModifPlatLongint(XCourant,couleurmini,platMod,InfosMilieuMod.jouable,InfosMilieuMod.nbBlancs,
                                    InfosMilieuMod.nbNoirs,InfosMilieuMod.frontiere);

    TickChrono := TickCount;
    if MiniProf <= 0 then
      begin
        if couleurmini = pionNoir
               then noteModif := InfosMilieuMod.nbBlancs-InfosMilieuMod.nbNoirs
               else noteModif := InfosMilieuMod.nbNoirs-InfosMilieuMod.nbBlancs;
        valXY := -noteModif;
      end
    else
      begin

        (*
        tickComparaisonFast := TickCount;

        valXY := -ABSol(platMod,defense,XCourant,-couleurmini,MiniProf,-betaAB,-alphaAB,
                     InfosMilieuMod.nbBlancs,InfosMilieuMod.nbNoirs,nbreDefensesMod,testsolitaire);

        tempsComparaisonFast := TickCount - tickComparaisonFast;

        WritelnNumDansRapport('valXY = ',valXY);
        WritelnStringAndBooleenDansRapport('test solitaire = ',testsolitaire);
        WritelnNumDansRapport('tempsComparaisonNormal = ',tempsComparaisonFast);

        tableauComparaison[0,0] := tableauComparaison[0,0] + tempsComparaisonFast;
        DisplayTableauComparaison(0,0);
        *)


        tickComparaisonFast := TickCount;
        valXY := -AlphaBetaSolitaireFast(platMod,defense,XCourant,-couleurmini,MiniProf,-betaAB,-alphaAB,
                                             nbreDefensesMod,testsolitaire,InfosMilieuMod);
        tempsComparaisonFast := TickCount - tickComparaisonFast;

        (*
        WritelnNumDansRapport('profPourTriSelonDivergenceDansSolitaire = ',profPourTriSelonDivergenceDansSolitaire);
        WritelnNumDansRapport('profMinimalePourUtilisationMilieuSolitaire = ',profMinimalePourUtilisationMilieuSolitaire);
        WritelnNumDansRapport('valXYFast = ',valXY);
        WritelnStringAndBooleenDansRapport('test solitaire fast = ',testsolitaire);
        WritelnNumDansRapport('tempsComparaisonFast = ',tempsComparaisonFast);
        WritelnDansRapport('');

        i := profPourTriSelonDivergenceDansSolitaire;
        j := profMinimalePourUtilisationMilieuSolitaire;
        tableauComparaison[i,j] := tableauComparaison[i,j] + tempsComparaisonFast;
        DisplayTableauComparaison(i,j);
        *)

        if windowPlateauOpen and debuggage.general then
        begin
          GetPort(oldport);
          SetPortByWindow(wPlateauPtr);
          WriteNumAt('',xcourant,200-couleurmini*130,200+12*compteur);
          WriteNumAt(',',defense,220-couleurmini*130,200+12*compteur);
          WriteNumAt('==>',valXY,260-couleurmini*130,200+12*compteur);
          WriteNumAt('                                       ',0,300-couleurmini*130,200+12*compteur);
          if testsolitaire
             then WriteNumAt('solitaire (nb def: ',nbreDefensesMod,300-couleurmini*130,200+12*compteur)
             else WriteNumAt('nb def : ',nbreDefensesMod,300-couleurmini*130,200+12*compteur);
          WriteNumAt('                                             ',0,200-couleurmini*130,200+12*compteur+12);
          SetPort(oldport);
        end;



      end;

    if (interruptionReflexion <> pasdinterruption) then valXY := -noteMax;
    if valXY = bestAB then
      begin
        solitaireJusquaPresent := false;
        nbreMeilleurs := nbreMeilleurs+1;
      end;
    if ((valXY > 0) and (valXY < bestAB)) and not(PourVraimentJouer) then
        solitaireJusquaPresent := false;
    if (valXY > bestAB) then
      begin
        nbreMeilleurs := 1;
        solitaireJusquaPresent := testsolitaire;
        CalculMobiliteFait := false;
        if (traitement = kSortiePapier) or (traitement = kSortiePapierCourte)
          then maxCoupsOfferts := noteMax
          else maxCoupsOfferts := -noteMax;
        FabriqueMeilleureSuiteInfos(Xcourant,suiteJouee,meilleureSuite,-couleurmini,
                                 platMod,InfosMilieuMod.nbBlancs,InfosMilieuMod.nbNoirs,pasDeMessage);
        SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
        if afficheMeilleureSuite then EcritMeilleureSuite;
        bestAB := valXY;
        if valXY > alphaAB then alphaAB := valXY;
        if (valXY > 0) and not(PourVraimentJouer) then
          begin
            alphaAB := 0;
            betaAB := +1;
            modeGagnantPerdant := true;
          end;
      end;
    TempsDeXCourant := (TickCount-TickChrono);


    if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);


    if valxy > classAux[1].note then indice_du_meilleur := compteur;

    k := 1;
    while (classAux[k].note >= valxy) and (k < compteur) do k := k+1;
    if (traitement = kSortiePapier) or (traitement = kSortiePapierCourte) then
      {dans ce cas on minimise le nb de coups offerts}
      begin
        if (valxy >= classAux[1].note)
         then
           begin
             lignecritique := (valXY <= 0) and
                            (((valXY < 0) and solitaireGagnant) or ((valXY = 0) and not(solitaireGagnant)));
             if not(CalculMobiliteFait) {on est dans le cas valxy > classAux[1].note}
              then
               begin
                 k := 1;
                 maxCoupsOfferts := CalculeMobilitePlatSeulement(platMod,-couleurmini);
                 CalculMobiliteFait := true;
               end
              else
               begin
                if not(lignecritique) or testSolitaire then
                  begin
                    nbCoupsOfferts := CalculeMobilitePlatSeulement(platMod,-couleurmini);
                    if (nbCoupsOfferts < maxCoupsOfferts) and (maxCoupsOfferts > 1) then
                      begin
                        maxCoupsOfferts := nbCoupsOfferts;
                        k := 1;
                        FabriqueMeilleureSuiteInfos(Xcourant,suiteJouee,meilleureSuite,-couleurmini,
                                                 platMod,InfosMilieuMod.nbBlancs,InfosMilieuMod.nbNoirs,PasDemessage);
                        SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
                        if afficheMeilleureSuite then EcritMeilleureSuite;
                      end;
                  end;
               end;
           end;
      end
     else  {à l'ecran on maximise le nb de coups offerts}
      begin
        if ((valXY <= 0) and (valxy >= classAux[1].note) and testSolitaire) or
           ((valXY > 0) and (valxy >= classAux[1].note))
         then
           begin
             if not(CalculMobiliteFait) {on est dans le cas valxy > classAux[1].note}
              then
               begin
                 k := 1;
                 CalculMobiliteFait := true;
                 maxCoupsOfferts := CalculeMobilitePlatSeulement(platMod,-couleurmini);
               end
              else
               begin
                nbCoupsOfferts := CalculeMobilitePlatSeulement(platMod,-couleurmini);
                if (nbCoupsOfferts > maxCoupsOfferts) then
                  begin
                    maxCoupsOfferts := nbCoupsOfferts;
                    k := 1;
                    FabriqueMeilleureSuiteInfos(Xcourant,suiteJouee,meilleureSuite,-couleurmini,
                                             platMod,InfosMilieuMod.nbBlancs,InfosMilieuMod.nbNoirs,pasdemessage);
                    SetMeilleureSuite(MeilleureSuiteInfosEnChaine(1,true,true,CassioUtiliseDesMajuscules,false,0));
                    if afficheMeilleureSuite then EcritMeilleureSuite;
                  end
               end;
           end;
      end;





    for j := compteur downto k+1 do classAux[j] := classAux[j-1];
    classAux[k].x := xcourant;
    classAux[k].note := ValXY;
    classAux[k].theDefense := defense;
    classAux[k].temps := TempsDeXCourant;


    SetValReflexFinale(classAux,miniprof,compteur,longClass,reflParfait,nroCoupRecherche,compteur+1,couleur);
		if affichageReflexion.doitAfficher then LanceDemandeAffichageReflexion(true,'MinimaxSolitaire');

    if not(PourVraimentJouer) then
    if ((valXY > 0) and not(solitaireJusquaPresent)) or
     ((classAux[1].note > 0) and (classAux[2].note > 0)) then
      begin
        solitaireJusquaPresent := false;
        sortieDeBoucle := true;
      end;

    if (classAux[1].note >= scoreaatteindre) then
      begin
        sortieDeBoucle := true;
      end;

    if (interruptionReflexion <> pasdinterruption) then
      begin
        solitaireJusquaPresent := false;
        sortieDeBoucle := true;
      end;



  until sortieDeBoucle or (compteur >= longClass) or Quitter;

  for i := 1 to longClass do class[i] := classAux[i];

  if (interruptionReflexion = pasdinterruption) and (traitement = kJeuNormal)
    then SauvegardeLigneOptimale(-couleurmini);

 end;
end;



function InitMaterielSolitaire : OSErr;
var i,t : SInt32;
begin

   killing        := NIL;
   killer         := NIL;
   meilleureSuite := NIL;

   killing        := KillingTableSolitairesPtr(AllocateMemoryPtr(sizeof(KillingTableSolitaires)));
   killer         := KillerTableSolitairesPtr(AllocateMemoryPtr(sizeof(KillerTableSolitaires)));
   meilleureSuite := meilleureSuitePtr(AllocateMemoryPtr(sizeof(t_meilleureSuite)));

   if (killing = NIL) or (killer = NIL) or (meilleureSuite = NIL) then
     begin
       InitMaterielSolitaire := -1;
       exit;
     end;

   MemoryFillChar(killing,sizeof(KillingTableSolitaires),chr(0));
   MemoryFillChar(killer,sizeof(KillerTableSolitaires),chr(0));


   MemoryFillChar(@nbkiller,sizeof(nbkiller),chr(0));
   MemoryFillChar(@fils,sizeof(fils),chr(0));
   MemoryFillChar(@casesVidesSC,sizeof(casesVidesSC),chr(0));
   MemoryFillChar(@casesVides,sizeof(casesVides),chr(0));
   MemoryFillChar(@coinsvides,sizeof(coinsvides),chr(0));
   gVecteurParite := 0;
   MemoryFillChar(@nbVidesQuadrant,sizeof(nbVidesQuadrant),chr(0));
   nbreToursNoeudsGeneresFinale := 0;
   nbreNoeudsGeneresFinale := 0;
   MemoryFillChar(@NbreDeNoeudsMoyensFinale,sizeof(NbreDeNoeudsMoyensFinale),chr(0));
   nroCoupRecherche := nbBl+nbNo-4+1;


   gNbreCasesVidesSansCoinsEntreeSolitaire := 0;
   nbCasesVides := 0;
   nbcoinsvides := 0;

   for i := 1 to 4 do       {les coins}
   BEGIN
    t := othellier[i];
    if jeu[t] = pionVide then
      begin
        nbcoinsvides := nbcoinsvides+1;
        coinsvides[nbcoinsvides] := t;
      end;
   end;
   for i := 5 to 64 do       {sans les coins}
   BEGIN
    t := othellier[i];
    if jeu[t] = pionVide then
      begin
        gNbreCasesVidesSansCoinsEntreeSolitaire := gNbreCasesVidesSansCoinsEntreeSolitaire+1;
        casesVidesSC[gNbreCasesVidesSansCoinsEntreeSolitaire] := t;
      end;
   end;
   for i := 1 to 64 do
   BEGIN
    t := othellier[i];
    if jeu[t] = pionVide then
      begin
        nbCasesVides := nbCasesVides+1;
        casesVides[nbCasesVides] := t;
        gVecteurParite := BXOR(gVecteurParite,constanteDeParite[t]);
        inc(nbVidesQuadrant[numeroQuadrant[t]]);
      end;
   end;

 InitStatistiquesDeDifficultePourFforum;

 InitMaterielSolitaire := NoErr;
end;


procedure LibereMemoireMaterielSolitaire;
begin
  if killer         <> NIL then DisposeMemoryPtr(Ptr(killer));
  if killing        <> NIL then DisposeMemoryPtr(Ptr(killing));
  if meilleureSuite <> NIL then DisposeMemoryPtr(Ptr(meilleureSuite));

  killer         := NIL;
  killing        := NIL;
  meilleureSuite := NIL;

  LibereMemoireStatistiquesDeDifficultePourFforum;
end;


procedure TraitementNormal;
var i,nbCoup,compt : SInt32;
    s,commentaire : String255;
    legal : boolean;
    plat : plateauOthello;
begin
   nbreAppelsABSol := 0;
   causerejet := 0;
   nbreMeilleurs := 0;
   solitaireJusquaPresent := false;
   modeGagnantPerdant := false;
   EstUnSolitaire := false;
   MFniv := MFprof-1;
   CoulAttaque := couleur;
   coulDefense := -couleur;
   if not(HumCtreHum) and pourVraimentJouer then
     begin
       commentaire := CommentaireSolitaire^^;
       if commentaire <> '' then
         begin
           s := ReadStringFromRessource(TextesSolitairesID,6);  {annule}
           if Pos(s,commentaire) > 0 then
             begin
               CoulAttaque := -couleurMacintosh;
               CoulDefense := couleurMacintosh;
             end;
         end;
     end;
   MemoryFillChar(@suiteJouee,sizeof(suiteJouee),chr(0));
   MemoryFillChar(meilleureSuite,sizeof(t_meilleureSuite),chr(0));
   MemoryFillChar(@classement,sizeof(classement),chr(0));
   if affichageReflexion.doitAfficher then
     begin
       plat := jeu;
       SetPositionDansFntreReflexion(ReflexData^,MakePositionEtTrait(plat,couleur));
     end;

   if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);
   CarteMove(couleur,jeu,move,mob);

   if GetNextEvent(everyEvent,theEvent) then TraiteEvenements;

   if (interruptionReflexion = pasdinterruption) then
     begin
       if (mob > 1) then
       begin
         nbCoup := 0;
         for i := 1 to nbcoinsvides do
          if move[coinsvides[i]]  then
             begin
               nbCoup := nbCoup+1;
               classement[nbCoup].x := coinsvides[i];
             end;
         for i := 1 to gNbreCasesVidesSansCoinsEntreeSolitaire do
          if move[casesVidesSC[i]]  then
             begin
               nbCoup := nbCoup+1;
               classement[nbCoup].x := casesVidesSC[i];
             end;


      if (interruptionReflexion = pasdinterruption) then
        begin
          premierePasse := false;
          if (MFniv > 8) then
           begin
             Calcule_Valeurs_Tactiques(jeu,false);
             for i := 1 to nbCoup do
             begin
                iCourant := classement[i].x;
                platClass := jeu;
                jouableClass := empl;
                nbBlancClass := nbBl;
                nbNoirClass := nbNo;
                frontClass := frontiere;
                legal := ModifPlat(iCourant,couleur,platClass,jouableClass,
                               nbBlancClass,nbNoirClass,frontClass);

                {
                noteClass := -Evaluation(platClass,-couleur,nbBlancClass,nbNoirClass,
                                                        jouableClass,frontClass,false,-30000,30000,nbEvalsRecursives);
                }

                noteclass := -AB_simple(platClass,jouableClass,defense,-couleur,2,
                              -30000,30000,nbBlancClass,nbNoirClass,frontClass,false);



                classement[i].note := noteclass;
                classement[i].theDefense := defense;
                fils[iCourant] := defense;

                if (BAND(gVecteurParite,constanteDeParite[iCourant]) <> 0)
                  then classement[i].note := classement[i].note+300;
                if (nbVidesQuadrant[numeroQuadrant[iCourant]] = 1) and
                   PeutJouerIci(-couleur,iCourant,jeu)
                    then
                      begin
                        classement[i].note := classement[i].note+4000;
                        {
                        SysBeep(30);
                        WriteNumAt('il faut jouer en ',iCourant,30,60);
                        }
                      end;
                if estUneCaseDeBord[iCourant] then classement[i].note := classement[i].note;

             end;
             limSup := noteMax;
             compt := 0;
             repeat
                maxcoupGagnant := -noteMax;
                for i := 1 to nbCoup do
                  if (classement[i].note >= maxcoupGagnant) and (classement[i].note < limSup)
                    then maxcoupGagnant := classement[i].note;
                for i := 1 to nbCoup do
                  if classement[i].note = maxcoupGagnant
                    then
                      begin
                        compt := compt+1;
                        classProv[compt] := classement[i];
                      end;
                limSup := maxcoupGagnant;
             until (compt >= nbCoup) or (limSup <= -noteMax);
             for i := 1 to nbCoup do classement[i] := classProv[i];
             premierePasse := true;
           end;


          SetValReflex(classement,MFniv,nbCoup,nbCoup,ReflAnnonceParfait,nroCoupRecherche,MAXINT_16BITS,couleur);
          if affichageReflexion.doitAfficher then LanceDemandeAffichageReflexion(false,'TraitementNormal');

          MinimaxSolitaire(couleur,MFniv,nbCoup,nbbl,nbno,jeu,classement);
        end;

        EstUnSolitaire := solitaireJusquaPresent and
                        (((classement[1].note > 0) and (classement[2].note <= 0)) or
                        ((classement[1].note = 0) and (classement[2].note < 0)));

        if classement[1].note < 0 then causerejet := kRejetPerdant;
        if (classement[1].note > 0) and (classement[2].note <= 0) and not(solitaireJusquaPresent)
           then causerejet := kRejetSeulGagnantMaisChoixPlusTard;
        if (classement[1].note = 0) and (classement[2].note < 0) and not(solitaireJusquaPresent)
           then causerejet := kRejetSeuleNulleMaisChoixPlusTard;
        if (classement[1].note > 0) and (classement[nbCoup].note = -noteMax) and not(solitaireJusquaPresent)
           then causerejet := kRejetGagnantEtChoixPlusTard;
        if (classement[1].note = 0) and (classement[nbCoup].note = -noteMax) and not(solitaireJusquaPresent)
           then causerejet := kRejetNulleEtChoixPlusTard;
        if (classement[1].note > 0) and (classement[2].note > 0) then causerejet := kRejetDeuxCoupsGagnants;
        if (classement[1].note = 0) and (classement[2].note = 0) then causerejet := kRejetDeuxCoupsPourFaireNulle;

        { on renvoie le premier du classement }
        meilleurX := classement[1].x;
        bstdef := classement[1].theDefense;
        score := classement[1].note;

       end
    else             { sinon on cherche l'unique coup }
      if (interruptionReflexion = pasdinterruption) then
       begin
        for i := 1 to 64 do
         if move[othellier[i]] then
           begin
              meilleurX := othellier[i];
              bstdef := 44;
              score := -64;
              EstUnSolitaire := false;
              causeRejet := kRejetUnSeulCoupLegal;
           end;
        end;
    end;

   ReinitilaliseInfosAffichageReflexion;
   if affichageReflexion.doitAfficher then EffaceReflexion(true);

   if GetNextEvent(everyEvent,theEvent)
       then TraiteEvenements;
end;

function NbrePionsDeCetteCouleur(couleur : SInt32; jeu : plateauOthello) : SInt32;
var t,sum : SInt32;
begin
  sum := 0;
  for t := 11 to 88 do
    if jeu[t] = couleur then inc(sum);
  NbrePionsDeCetteCouleur := sum;
end;


function HumainPeutJouer(jeu : plateauOthello) : boolean;
var test : boolean;
    X : SInt32;
begin
  test := false;
  X := 11;
  repeat
    if jeu[X] = pionVide then
      test := PeutJouerIci(CouleurHumain,X,jeu);
    X := X+1;
  until test or (X > 88);
  HumainPeutJouer := test;
end;

function OrdiPeutJouer(jeu : plateauOthello) : boolean;
var test : boolean;
    X : SInt32;
begin
  test := false;
  X := 11;
  repeat
    if jeu[X] = pionVide then
      test := PeutJouerIci(CouleurOrdi,X,jeu);
    X := X+1;
  until test or (X > 88);
  OrdiPeutJouer := test;
end;

function CoupLegalHumain(coup : SInt32; jeu : plateauOthello) : boolean;
begin
  if jeu[coup] <> pionVide
    then CoupLegalHumain := false
    else CoupLegalHumain := PeutJouerIci(CouleurHumain,coup,jeu);
end;

procedure JouerUnCoupDuSolitaire(coup : SInt32; couleur : SInt32; var jeu : plateauOthello);
var bidbool : boolean;
    nbBlancsTempo,nbNoirsTempo : SInt32;
begin
  bidbool := ModifPlatFin(coup,couleur,jeu,nbBlancsTempo,nbNoirsTempo);
end;

procedure CalculerMeilleurReponseOrdi(jeu : plateauOthello; var meilleurCoup : SInt32);
var causerejet : SInt32;
    profondeur : SInt32;
    nbPionsBlancs,nbPionsNoirs : SInt32;
    i,t,jeudeT : SInt32;
    mobilite : SInt32;
begin
 InterruptionCalculSuites := InterruptionCalculSuites or EscapeDansQueue;
 if not(InterruptionCalculSuites) then
 if (nbrelignesSolution < MaxNbreLignesAutorisees) then
   begin
     coulAttaque := couleurHumain;
     coulDefense := couleurOrdi;
     MemoryFillChar(@classement,sizeof(classement),chr(0));
     causerejet := 0;
     nbreMeilleurs := 0;
     solitaireJusquaPresent := false;
     modeGagnantPerdant := false;
     EstUnSolitaire := false;

     MemoryFillChar(@suiteJouee,sizeof(suiteJouee),chr(0));
     MemoryFillChar(meilleureSuite,sizeof(t_meilleureSuite),chr(0));
     MemoryFillChar(killing,sizeof(KillingTableSolitaires),chr(0));
     MemoryFillChar(killer,sizeof(KillerTableSolitaires),chr(0));
     MemoryFillChar(@nbkiller,sizeof(nbkiller),chr(0));
     MemoryFillChar(@fils,sizeof(fils),chr(0));


     mobilite := 0;
     nbPionsNoirs := 0;
     nbPionsBlancs := 0;
     for i := 1 to 64 do
       begin
         t := othellier[i];
         jeudeT := jeu[t];
         if jeudeT = pionVide then
           begin
             if PeutJouerIci(CouleurOrdi,t,jeu) then
               begin
                 mobilite := mobilite+1;
                 classement[mobilite].x := t;
               end;
           end
          else
           begin
            if jeudeT = pionNoir then nbPionsNoirs := nbPionsNoirs+1;
            if jeudeT = pionBlanc then nbPionsBlancs := nbPionsBlancs+1;
           end;
       end;
     profondeur := 63-nbPionsNoirs-nbPionsBlancs;
     if mobilite > 1 then
       begin
         MinimaxSolitaire(CouleurOrdi,profondeur,mobilite,nbPionsBlancs,nbPionsNoirs,jeu,classement);
       end;
     meilleurCoup := classement[1].x;
  end;
end;


procedure EcritureRecursive(plat : plateauOthello);   { c'est à l'humain de jouer }
var nroChoixHumain : SInt32;
    k,n : SInt32;
    coupHumain,reponseOrdi : SInt32;
    platEssai : plateauOthello;
    erreurES : OSErr;

  procedure SautDeLigneFichierSolution(positionFinale : plateauOthello);
    begin
      inc(nbrelignesSolution);
      inc(nbreLigneH);
      if nbreLigneH >= 400 then
        begin
          nbreLigneH := 0;
          nbreLigneV := nbreLigneV+6;
        end;
      SetPortByWindow(FenetreMessage);
      Moveto(70+nbreLigneH,76);
      Lineto(70+nbreLigneH,nbreLigneV);


      n := NbrePionsDeCetteCouleur(CouleurHumain,positionFinale);
      if avecEcritureScoreDansSolution then
        erreurES := Write(fichierSolution,'     '+IntToStr(n));
      AjouterStatistiquesDeDifficultePourFforum(nbrelignesSolution,n);

    end;

begin
 InterruptionCalculSuites := InterruptionCalculSuites or EscapeDansQueue;
 if not(InterruptionCalculSuites) then
 if (nbrelignesSolution < MaxNbreLignesAutorisees) then
   begin
    posEcriture := posEcriture+6;
    if HumainPeutJouer(plat) then
      begin
        nroChoixHumain := 0;
        for coupHumain := 88 downto 11 do
          if not(InterruptionCalculSuites) then
            if CoupLegalHumain(coupHumain,plat) then
              begin
                nroChoixHumain := nroChoixHumain+1;
                if nroChoixHumain >= 2 then
                   for k := 1 to posEcriture do
                     erreurES := Write(fichierSolution,' ');
                erreurES := Write(fichierSolution,CharToString(' ')+CoupEnStringEnMajuscules(coupHumain));
                platEssai := plat;
                JouerUnCoupDuSolitaire(coupHumain,couleurHumain,platEssai);
                if OrdiPeutJouer(platEssai)
                  then
                    begin
                      CalculerMeilleurReponseOrdi(platEssai,reponseOrdi);
                      erreurES := Write(fichierSolution,CharToString(' ')+CoupEnStringEnMajuscules(reponseOrdi));
                      JouerUnCoupDuSolitaire(reponseOrdi,couleurOrdi,platEssai);
                      EcritureRecursive(platEssai);
                    end
                  else
                    begin
                      if HumainPeutJouer(platEssai)
                        then
                          begin
                            s := ReadStringFromRessource(TextesSolitairesID,7);
                            erreurES := Write(fichierSolution,CharToString(' ')+s);
                            EcritureRecursive(platEssai);
                          end
                        else
                          begin
                            SautDeLigneFichierSolution(platEssai);
                            erreurES := Writeln(fichierSolution,'');
                          end;
                    end;
               end;
      end
    else
      begin
        if OrdiPeutJouer(plat)
         then
          begin
            s := ReadStringFromRessource(TextesSolitairesID,8);
            erreurES := Write(fichierSolution,CharToString(' ')+s);
            CalculerMeilleurReponseOrdi(plat,reponseOrdi);
            erreurES := Write(fichierSolution,CharToString(' ')+CoupEnStringEnMajuscules(reponseOrdi));
            JouerUnCoupDuSolitaire(reponseOrdi,couleurOrdi,plat);
            EcritureRecursive(plat);
          end
         else
          begin
            SautDeLigneFichierSolution(plat);
            erreurES := Writeln(fichierSolution,'');
          end;
      end;
    posEcriture := posEcriture-6;
  end;
end;

procedure EcritSolitaireCompletFFORUM(position : plateauOthello);
const PasPossibleSolitaireID = 152;
var reply : SFReply;
    oldport : grafPtr;
    unRect : rect;
    i,j : SInt32;
    s,commentaire : String255;
    ErreurES : OSErr;
begin
  InterruptionCalculSuites := false;
  nbrelignesSolution := 0;
  nbreLigneH := 0;
  nbreLigneV := 82;
  posEcriture := -6;
  CouleurHumain := couleur;
  CouleurOrdi := -couleurHumain;
  commentaire := CommentaireSolitaire^^;
  s := ReadStringFromRessource(TextesSolitairesID,5);
  if (commentaire <> '') and (Pos(s,commentaire) > 0)
    then solitaireGagnant := true
    else solitaireGagnant := false;
  if HumainPeutJouer(position)
    then
      begin
        SetNameOfSFReply(reply, nomprec);
        BeginDialog;
        s := ReadStringFromRessource(TextesSolitairesID,9);
        if MakeFileName(reply,s,info) then DoNothing;
        EndDialog;
        if reply.good then
          begin
            GetPort(oldport);
            with GetScreenBounds do
              SetRect(unRect,left+50,40,right-50,140);
            FenetreMessage := MyNewCWindow(NIL,unRect,'',false,1,FenetreFictiveAvantPlan,false,0);
            if FenetreMessage <> NIL then
              begin
                ShowWindow(FenetreMessage);
                SetPortByWindow(FenetreMessage);
                TextFont(systemFont);
                TextSize(0);
                Moveto(50,21);
                s := ReadStringFromRessource(TextesSolitairesID,10);
                MyDrawString(s);
                Moveto(50,38);
                s := ReadStringFromRessource(TextesSolitairesID,11);
                MyDrawString(s);
                TextFont(gCassioApplicationFont);
                TextSize(gCassioSmallFontSize);
                Moveto(3,82);
                s := ReadStringFromRessource(TextesSolitairesID,12);
                MyDrawString(s);
                for i := 0 to 4 do
                  begin
                    Moveto(70+i*100,67);
                    Lineto(70+i*100,73);
                    if i < 4 then
                    for j := 1 to 9 do
                      begin
                        Moveto(70+i*100+j*10,73);
                        Lineto(70+i*100+j*10,71);
                        if j = 5 then Lineto(70+i*100+j*10,70);
                      end;
                    if i = 0
                      then WriteNumAt('',i*100,70+i*100-2,66)
                      else WriteNumAt('',i*100,70+i*100-9,66);
                  end;
                Moveto(70,73);
                Lineto(70+4*100,73);
                Moveto(70+nbrelignesSolution mod 400,76);
                Lineto(70+nbrelignesSolution mod 400,82);
              end;



            erreurES := FileExists(info,fichierSolution);
            if erreurES = fnfErr then erreurES := CreateFile(info,fichierSolution);
            if erreurES = NoErr then
					    begin
					      erreurES := OpenFile(fichierSolution);
					      erreurES := EmptyFile(fichierSolution);
					    end;
			      if erreurES <> 0
			        then SimpleAlertForFile(GetNameOfSFReply(reply),erreurES)
			        else
			          begin
                  erreurES := Writeln(fichierSolution,CommentaireSolitaire^^);
                  erreurES := Writeln(fichierSolution,'');
                  ViderStatistiquesDeDifficultePourFforum;
                  EcritureRecursive(position);
                  EcritureStatistiquesDeDifficultePourFforum(fichierSolution);
                end;
            erreurES := CloseFile(fichierSolution);
            SetFileCreatorFichierTexte(fichierSolution,FOUR_CHAR_CODE('R*ch'));
            SetFileTypeFichierTexte(fichierSolution,FOUR_CHAR_CODE('TEXT'));


            SetPort(oldport);
            if FenetreMessage <> NIL then DisposeWindow(FenetreMessage);
            EssaieSetPortWindowPlateau;
          end;
      end
    else
      begin
        {WriteNumAt('LE JOUEUR HUMAIN NE PEUT PAS JOUER !!!',0,10,100);}

        AlertOneButtonFromRessource(PasPossibleSolitaireID,2,0,1);
      end;
end;


begin    {EstUnSolitaire}
  {EcritParametresDansRapport};

  gEnRechercheSolitaire := true;
  SetCassioEstEnTrainDeReflechir(true,@oldCassioEstEnTrainDeReflechir);



  if (InitMaterielSolitaire = NoErr) then
    case traitement of
      kSortiePapier,
      kSortiePapierCourte,
      kSortiePapierLongue:
        begin
         avecEcritureScoreDansSolution := BAND(theEvent.modifiers,optionKey) <> 0;
         if not(CassioEstEnModeSolitaire)
           then
             begin
               s := ReadStringFromRessource(TextesSolitairesID,13);
               AlerteSimple(s);
             end
           else
             begin
               nomprec := ReadStringFromRessource(TextesSolitairesID,14);
               EcritSolitaireCompletFFORUM(jeu);
               if (nbrelignesSolution > 0) and not(InterruptionCalculSuites) then
                if (nbrelignesSolution < 80) and (traitement <> kSortiePapierLongue)
                 then
                   begin
                     s1 := IntToStr(nbrelignesSolution);
                     s := ReadStringFromRessource(TextesSolitairesID,15);

                     item := AlerteDoubleOuiNon(ReplaceParameters(s,s1,ReelEnStringAvecDecimales(DifficulteDuSolitaire,3),'',''),'');

                     if item = BoutonOui then
                       begin
                         traitement := kSortiePapierLongue;
                         EcritSolitaireCompletFFORUM(jeu);
                         if (nbrelignesSolution > 0) and not(InterruptionCalculSuites) then
                           begin
                             s1 := IntToStr(nbrelignesSolution);
                             s := ReadStringFromRessource(TextesSolitairesID,16);
                             BeginDialog;
                             AlerteSimple(ReplaceParameters(s,s1,ReelEnStringAvecDecimales(DifficulteDuSolitaire,3),'',''));
                             EndDialog;
                           end;
                       end;
                   end
                 else
                   begin
                     if nbrelignesSolution >= MaxNbreLignesAutorisees
                       then
                         begin
                           s := ReadStringFromRessource(TextesSolitairesID,17);
                         end
                       else
                         begin
                           s1 := IntToStr(nbrelignesSolution);
                           s := ReadStringFromRessource(TextesSolitairesID,18); {Ce solitaire fait ^0 lignes, avec une difficulté de ^1 %.}
                           s := ReplaceParameters(s,s1,ReelEnStringAvecDecimales(DifficulteDuSolitaire,3),'','');
                         end;
                     AlerteSimple(s);
                   end;
             end;
       end;
     kJeuNormal :
       begin
        TraitementNormal;
       end;
     kRechercheSolitairesDansBase:
       begin
        if (CalculeMobilitePlatSeulement(jeu,couleur) = 1) then
          begin
            EstUnSolitaire := false;
            causeRejet := kRejetUnSeulCoupLegal;
            goto exit_EstUnSolitaire;
          end;

        plat := jeu;
        nbCoupsNonPerdants := NbCoupsGagnantsOuNuls(MakePositionEtTrait(plat,couleur),scoreWLDOptimal,2);
        if (nbCoupsNonPerdants <= 0) then
          begin
            EstUnSolitaire := false;
            causeRejet := kRejetPerdant;
            goto exit_EstUnSolitaire;
          end;
        if (nbCoupsNonPerdants >= 2) then
          begin
            EstUnSolitaire := false;
            if scoreWLDOptimal > 0
              then causeRejet := kRejetDeuxCoupsPourFaireNulle
              else causeRejet := kRejetDeuxCoupsGagnants;
            goto exit_EstUnSolitaire;
          end;

        TraitementNormal;
      end;
    end {case}
   else
    AlerteSimple('Pas assez de mémoire pour jouer aux solitaires !');


  exit_EstUnSolitaire:

  LibereMemoireMaterielSolitaire;
  gEnRechercheSolitaire := false;
  SetCassioEstEnTrainDeReflechir(oldCassioEstEnTrainDeReflechir,NIL);
  SetGenreDerniereReflexionDeCassio(ReflMilieu,(nbBl + nbNo) - 4 +1);
end;




procedure PlaquerSolitaire(PositionEtCommentaire : String255);
var couleur,t,i : SInt32;
    s : String255;
    platSol : plateauOthello;
    aux : SInt32;
    oldScript : SInt32;
    numeroDeCoup : SInt32;
    commentaire : String255;
    promptEnGras,resteDuCommentaire : String255;
begin
  {WritelnDansRapport('dans PlaquerSolitaire, PositionEtCommentaire = '+PositionEtCommentaire);}
  GetCurrentScript(oldScript);
  if not(windowPlateauOpen) then OuvreFntrPlateau(false);
  s := ReadStringFromRessource(TextesSolitairesID,20);
  if Pos(s,PositionEtCommentaire) > 0
    then couleur := pionBlanc
    else couleur := pionNoir;
  s := '';
  for i := 1 to 5 do
    if PositionEtCommentaire[i] <> ' ' then s := s + PositionEtCommentaire[i];
  StrToInt32(s,aux);
  dernierePartieExtraiteThor := aux;
  s := TPCopy(PositionEtCommentaire,6,16);
  DecompilerPosition(s,platSol);
  numeroDeCoup := 0;
  for t := 1 to 64 do
      if platSol[Othellier[t]] <> pionVide then numeroDeCoup := numeroDeCoup+1;
  numeroDeCoup := numeroDeCoup-3;
  if couleurMacintosh = couleur then
    begin
      couleurMacintosh := -couleurMacintosh;
      reponsePrete := false;
      RefleSurTempsJoueur := false;
      LanceInterruptionSimple('PlaquerSolitaire');
      vaDepasserTemps := false;
    end;
  phaseDeLaPartie := phaseFinaleParfaite;
  finDePartieOptimale := numeroDeCoup-3;
  SensLargeSolitaire := true;
  if HumCtreHum then HumCtreHum := not(HumCtreHum);
  if afficheMeilleureSuite then afficheMeilleureSuite := not(afficheMeilleureSuite);
  if afficheSuggestionDeCassio then afficheSuggestionDeCassio := not(afficheSuggestionDeCassio);
  RandomizeTimer;
  if odd(Random16()) then EffectueSymetrieAxeNW_SE(platSol);
  if odd(Random16()) then EffectueSymetrieAxeNE_SW(platSol);

  SetCassioEstEnTrainDePlaquerUnSolitaire(true);
  PlaquerPosition(platSol,couleur,kRedessineEcran);
  SetCassioEstEnTrainDePlaquerUnSolitaire(false);

  CommentaireSolitaire^^ := 'Chaine non vide pour indiquer un solitaire';
  if (AQuiDeJouer <> couleurMacintosh) then
    begin
      MyDisableItem(PartieMenu,ForceCmd);
      AfficheDemandeCoup;
    end;

  finaleEnModeSolitaire := true;
  commentaire := TPCopy(PositionEtCommentaire,22,LENGTH_OF_STRING(PositionEtCommentaire)-21);
  CommentaireSolitaire^^ := commentaire;
  s := ReadStringFromRessource(TextesSolitairesID,1);
  if Pos(s,commentaire) > 0  then ParamDiagPositionFFORUM.commentPositionFFORUM^^ := s;
  s := ReadStringFromRessource(TextesSolitairesID,2);
  if Pos(s,commentaire) > 0  then ParamDiagPositionFFORUM.commentPositionFFORUM^^ := s;
  s := ReadStringFromRessource(TextesSolitairesID,3);
  if Pos(s,commentaire) > 0  then ParamDiagPositionFFORUM.commentPositionFFORUM^^ := s;
  s := ReadStringFromRessource(TextesSolitairesID,4);
  if Pos(s,commentaire) > 0  then ParamDiagPositionFFORUM.commentPositionFFORUM^^ := s;

  DessineIconesChangeantes;
  EcritCommentaireSolitaire;
  DisableKeyboardScriptSwitch;
  FinRapport;
  TextNormalDansRapport;
  WritelnDansRapport('');
  ParserCommentaireSolitaire(commentaire,promptEnGras,resteDuCommentaire);
  ChangeFontFaceDansRapport(bold);
  ChangeFontColorDansRapport(MarinePaleCmd);
  WriteDansRapport(promptEnGras);
  ChangeFontFaceDansRapport(normal);
  ChangeFontColorDansRapport(NoirCmd);
  WritelnDansRapport(resteDuCommentaire);
  EnableKeyboardScriptSwitch;
  SetCurrentScript(oldScript);
  SwitchToRomanScript;
  AjusteCurseur;
  FixeMarqueSurMenuMode(nbreCoup);
end;

(*
procedure DoJoueAuxSolitaires;
const     PasTrouveThordbaID = 137;
          PasTrouveOKBouton = 1;
          PasTrouveAnnulerBouton = 2;
type t_buffer = packed array[1..260] of t_Octet;
     bufferPtr = ^t_buffer;
     packed13 = packed array[1..100] of char;

var BaseSolitairesFic : basicfile;
    s,filename : String255;
    nbreJoueurs,nbreParties : SInt32;

    buffer : bufferPtr;
    partieBuff:partieDansThorDBAPtr;
    count : SInt32;
    TailleTournoiRec,TailleJoueurRec,TaillePartieRec : SInt32;
    TailleHeader,TailleTournois,TailleJoueurs : SInt32;
    platSol : plateauOthello;
    nBlaSol,nNoiSol : SInt32;
    trait : SInt32;
    jouableSol,MoveSol : plBool;
    frontSol : InfoFront;
    profSol : SInt32;
    FichierReferencesSolitaires : basicfile;
    couleur,numeroDeCoup : SInt32;
    finderInf : FInfo;
    unstringPtr : stringPtr;
    where : Point;
    typelist : SFtypelist;
    reply : SFReply;
    refvol : SInt16;
    dp : DialogPtr;
    itemHit : SInt16;

function RejoueJusquAuCoup(n : SInt32) : boolean;
var test : boolean;
    x,k : SInt32;
begin
  OthellierEtPionsDeDepart(platSol,nBlaSol,nNoiSol);
  trait := pionNoir;
  k := 0;
  with Partiebuff^ do
  repeat
    k := k+1;
    x := coups[k];
    if x <> 0 then
      begin
        test := ModifPlatFin(x,trait,platSol,nBlaSol,nNoiSol);
        if test
          then
            trait := -trait
          else
            test := ModifPlatFin(x,-trait,platSol,nBlaSol,nNoiSol);
      end
      else test := false;
  until (k >= n) or not(test);
  RejoueJusquAuCoup := test;
end;


function SolitairePossible(coupmin,coupmax : SInt32; var nroPremierCoupSol,XduSol,score,mobilite,couleur : SInt32) : boolean;
var test,sortieDeBoucle : boolean;
    nrocoup,seulCoup,seuleDef : SInt32;
    x,nbremeill,cause : SInt32;
begin
  test := false;
  x := Partiebuff^.coups[coupmin];
  if x > 0 then
    begin
      CarteJouable(platSol,JouableSol);
      CarteMove(trait,platSol,MoveSol,mobilite);
      if mobilite = 0 then
        begin
          trait := -trait;
          CarteMove(trait,platSol,MoveSol,mobilite);
        end;
      CarteFrontiere(PlatSol,FrontSol);

      nrocoup := coupmin;
      sortieDeBoucle := false;
      repeat

        profSol := 64 - nBlaSol - nNoiSol;


        test := EstUnSolitaire(seulCoup,seuleDef,trait,profSol,nblaSol,nNoiSol,
                             platSol,jouableSol,frontSol,score,nbremeill,false,cause,kJeuNormal,65);
        if test then
          begin
            nroPremierCoupSol := nrocoup;
            XduSol := seulCoup;
            couleur := trait;
          end;


        nrocoup := nrocoup+1;
      until test or (nrocoup > coupmax) or sortieDeBoucle;
    end;
  SolitairePossible := test;

end;

procedure LitPartieNro(n : SInt32);
var err : OSErr;
begin
  err := SetFilePosition(BaseSolitairesFic,tailleHeader+TailleTournois+TailleJoueurs+(n-1)*TaillePartieRec);
  count := TaillePartieRec;
  err := Read(BaseSolitairesFic,MAKE_MEMORY_POINTER(Partiebuff),count);

  {$IFC NOT(CASSIO_EST_COMPILE_POUR_PROCESSEUR_INTEL) }
  SWAP_INTEGER( @Partiebuff^.numeroTournoi);
  SWAP_INTEGER( @Partiebuff^.numeroNoir);
  SWAP_INTEGER( @Partiebuff^.numeroblanc);
  {$ENDC}

end;

procedure LitJoueurNro(n : SInt32; var nom : String255);
var i : SInt32;
    err : OSErr;
begin
  err := SetFilePosition(BaseSolitairesFic,tailleHeader+TailleTournois+n*TailleJoueurRec);
  count := TailleJoueurRec;
  err := Read(BaseSolitairesFic,MAKE_MEMORY_POINTER(buffer),count);
  for i := 1 to 19 do
    begin
      if buffer^[i] = 0 then buffer^[i] := 32;
      nom[i] := chr(buffer^[i]);
    end;
  SET_LENGTH_OF_STRING(nom, 19);
end;

procedure LitTournoiNro(n : SInt32; var nom : String255);
var i : SInt32;
    c : char;
    err : OSErr;
begin
  err := SetFilePosition(BaseSolitairesFic,tailleHeader+n*TailleTournoiRec);
  count := TailleTournoiRec;
  err := Read(BaseSolitairesFic,MAKE_MEMORY_POINTER(buffer),count);
  nom := '';
  for i := 1 to 29 do
    begin
      c := chr(buffer^[i]);
      if c = 'Ç' then c := 'é';
      if c = 'ä' then c := 'è';
      if ord(c) <> 0 then nom := Concat(nom,c);
    end;
  SET_LENGTH_OF_STRING(nom, 29);
end;


procedure InitialiseValeursBaseThor;
var err : OSErr;
begin
  tailleHeader := 68;
  TailleTournoiRec := 32;
  TailleJoueurRec := 20;
  TailleTournois := 400*TailleTournoiRec;
  TailleJoueurs := 2000*TailleJoueurRec;
  TaillePartieRec := 68;
  count := 4;
  err := Read(BaseSolitairesFic,MAKE_MEMORY_POINTER(buffer),count);
  nbreParties := buffer^[1]+256*buffer^[2];
  nbreJoueurs := buffer^[3]+256*buffer^[4];
end;

function OuvreFichierSolitaires : OSErr;
var i : SInt32;
    err : OSErr;
    fileName : String255;
begin
  err := SetVol(NIL,SolitairesRefVol);
  fileName := CheminAccesThorDBASolitaire^^;
  i := LENGTH_OF_STRING(fileName);
  while (fileName[i] <> DirectorySeparator) and (i > 0) do i := i-1;
  fileName := Concat(TPCopy(fileName,1,i),'Solitaires Cassio');
  err := FichierTexteDeCassioExiste(filename,FichierReferencesSolitaires);
  if err = NoErr then err := OpenFile(FichierReferencesSolitaires);
  if err <> 0 then
    begin
      fileName := CheminAccesThorDBASolitaire^^;
      i := LENGTH_OF_STRING(fileName);
      while (fileName[i] <> DirectorySeparator) and (i > 0) do i := i-1;
      fileName := Concat(TPCopy(fileName,1,i),'Solitaire Cassio');
      err := FichierTexteDeCassioExiste(filename,FichierReferencesSolitaires);
      if err = NoErr then err := OpenFile(FichierReferencesSolitaires);
    end;
  if err <> 0 then
    begin
      err := SetVol(NIL,SolitairesRefVol);
      fileName := 'Solitaires Cassio';
      err := FichierTexteDeCassioExiste(filename,FichierReferencesSolitaires);
      if err = NoErr then err := OpenFile(FichierReferencesSolitaires);
    end;
  if err <> 0 then
    begin
      err := SetVol(NIL,SolitairesRefVol);
      fileName := 'Solitaire Cassio';
      err := FichierTexteDeCassioExiste(filename,FichierReferencesSolitaires);
      if err = NoErr then err := OpenFile(FichierReferencesSolitaires);
    end;
  if err <> 0 then
    begin
      err := SetVol(NIL,SolitairesRefVol);
      fileName := CheminAccesSolitaireCassio^^;
      err := FileExists(filename,0,FichierReferencesSolitaires);
      if err = NoErr then err := OpenFile(FichierReferencesSolitaires);
    end;
  if err <> 0 then
    begin
      err := -1;
      fileName := 'Solitaires Cassio';

      BeginDialog;
      dp := MyGetNewDialog(PasTrouveThordbaID);
      if dp <> NIL then
        begin
          MyParamText(fileName,'','','');
          err := SetDialogTracksCursor(dp,true);
          repeat
            ModalDialog(MyFiltreClassiqueUPP,itemHit);
          until (itemHit = PasTrouveOKBouton) or (itemHit = PasTrouveAnnulerBouton);
          MyDisposeDialog(dp);
        end;
        if (itemHit = PasTrouveAnnulerBouton)
          then
            err := -1
          else
            begin
              where.h := 80; where.v := 80;
              typelist[0] := 'TEXT';
              typelist[1] := 'SOLT';
              BeginDialog;
              SFGetFile(where,'',NIL,2,@typelist,NIL,reply);
              EndDialog;
              if reply.good
                then
                  if (Pos('olitaires Cassio',GetNameOfSFReply(reply)) > 0) or
                     (Pos('olitaire Cassio' ,GetNameOfSFReply(reply)) > 0)
                   then
                    begin
                      CheminAccesSolitaireCassio^^ := GetNameOfSFReply(reply);
                      SolitairesRefVol := reply.vRefNum;
                      err := SetVol(NIL,SolitairesRefVol);
                      {WriteNumAt('Solitaires RefNum :',SolitairesRefVol,10,40);
                      WriteNumAt('Cassio RefNum :',pathCassioFolder,10,60);
                      AttendFrappeClavier;
                      }
                      err := FileExists(GetNameOfSFReply(reply),0,FichierReferencesSolitaires);
                      err := OpenFile(FichierReferencesSolitaires);
                    end
                   else
                      err := -1
               else err := -1;  {annulation}
             end;
        EndDialog;
     end;
  OuvreFichierSolitaires := err;
end;

function FermeFichierSolitaires : OSErr;
begin
  FermeFichierSolitaires := CloseFile(FichierReferencesSolitaires);
end;

function NroSolitaireAuHazard(var numeroDeCoup : SInt32; var couleur : SInt32; var commentaire : String255) : SInt32;
const nbSolitairesGagnant = 5045;
      nbSolitairesAnnulant = 0;
var n,aux,nroligne,PositionDansFichier,count : SInt32;
    err : OSErr;
    longFichierReferencesSolitaires,nbreLignesFichierReferencesSolitaires : SInt32;
    nroPartie : SInt32;
    s,uneligne : String255;
    c : char;
    myPacked13:packed13;
begin
  RandomizeTimer;
  longFichierReferencesSolitaires := 0;
  err := GetFileSize(FichierReferencesSolitaires,longFichierReferencesSolitaires);

  {WriteNumDansRapport('longFichierReferencesSolitaires = ',longFichierReferencesSolitaires);}
  nbreLignesFichierReferencesSolitaires := SInt32(longFichierReferencesSolitaires div 14);
  {WriteNumDansRapport('  longFichierReferencesSolitaires = ',longFichierReferencesSolitaires);}
  nroligne := SInt32(SInt32(Abs(SInt32(Random16()))) mod nbreLignesFichierReferencesSolitaires) +1;

  if nroligne < 0 then SysBeep(0);

  PositionDansFichier := SInt32((SInt32(nroligne)-SInt32(1))*SInt32(14));  {var intermediaire pour forcer le calcul en SInt32}

  if (PositionDansFichier < 0) or
     (PositionDansFichier > longFichierReferencesSolitaires) then SysBeep(0);

  {WriteNumDansRapport('   PositionDansFichier = ',PositionDansFichier);}

  err := SetFilePosition(FichierReferencesSolitaires,PositionDansFichier);

  if err <> 0 then SysBeep(0);

  count := 40;
  err := Read(FichierReferencesSolitaires,@myPacked13,count);

  if err <> 0 then SysBeep(0);

  uneligne := '';
  for n := 1 to 13 do {pas 1 to 14 car le quatorzieme caractere est un retour chariot}
    uneligne := Concat(uneligne,myPacked13[n]);

  {WritelnNumDansRapport('  uneLigne = '+uneligne+'  , length = ',LENGTH_OF_STRING(uneligne));}

  couleur := 0;
  aux := Pos(' N.',uneligne);
  if aux > 0
   then
    begin
      couleur := pionNoir;
      s := Concat(uneligne[aux+3],uneligne[aux+4]);
      StrToInt32(s,numeroDeCoup);
      if uneligne[aux+6] <> '0'
       then commentaire := ReadStringFromRessource(,TextesSolitairesID,1)
       else commentaire := ReadStringFromRessource(,TextesSolitairesID,3);
      commentaire := Concat(commentaire,'   ');
    end
   else
     begin
       aux := Pos(' B.',uneligne);
       if aux > 0
         then
	         begin
	           couleur := pionBlanc;
	           s := Concat(uneligne[aux+3],uneligne[aux+4]);
	           StrToInt32(s,numeroDeCoup);
	           if numeroDeCoup < 10 then
	             begin
	               s := uneligne;
	               Delete(s,1,aux+1);
	               aux := Pos(' B.',s);
	               if aux > 0 then s := Concat(s[aux+3],s[aux+4]);
	               StrToInt32(s,numeroDeCoup);
	             end;
	           if uneligne[aux+6] <> '0'
	             then commentaire := ReadStringFromRessource(,TextesSolitairesID,2)
	             else commentaire := ReadStringFromRessource(,TextesSolitairesID,4);
	           commentaire := Concat(commentaire,'   ');
	         end
         else
           begin
             SysBeep(0);
             WritelnDansRapport('erreur dans NroSolitaireAuHazard');
           end;
     end;
  s := '';
  for n := 1 to 5 do
    begin
      c := uneligne[n];
      if (c >= '0') and (c <= '9') then s := s + c;
    end;
  nroPartie := 0;
  StrToInt32(s,nroPartie);
  NroSolitaireAuHazard := nroPartie;
end;

procedure FabriqueCommentaire(nroPart : SInt32; var comment : String255);
var nom,s,s2 : String255;
    s19 : String255;
    s29 : String255;
    i,long : SInt32;
    c : char;
begin
  {$UNUSED nroPart}
  comment := '';
  LitJoueurNro(Partiebuff^.numeroNoir,s19);
  s19 := DeleteSpacesBefore(s19,LENGTH_OF_STRING(s19));
  {while s19[LENGTH_OF_STRING(s19)] = ' ' do Delete(s19,LENGTH_OF_STRING(s19),1);}
  {ParametresOuvrirThor^^[3] := s19;}
  EnlevePrenom(s19,nom);
  if referencescompletes then
    begin
      s := IntToStr(Partiebuff^.ScoreEtTheorik[0],s);
      comment := nom+s+'-';
    end
    else
    comment := nom+'- ';
  ParamDiagPartieFFORUM.TitreFFORUM^^ := nom+'- ';
  LitJoueurNro(Partiebuff^.numeroBlanc,s19);
  s19 := DeleteSpacesBefore(s19,LENGTH_OF_STRING(s19));
  {while s19[LENGTH_OF_STRING(s19)] = ' ' do Delete(s19,LENGTH_OF_STRING(s19),1);}
  {ParametresOuvrirThor^^[2] := s19;}
  EnlevePrenom(s19,nom);
  if referencescompletes then
    begin
      IntToStr(64-Partiebuff^.ScoreEtTheorik[0],s);
      comment := Concat(comment,s,CharToString(' '),nom);
    end
    else
    comment := Concat(comment,nom);
  ParamDiagPartieFFORUM.TitreFFORUM^^ := ParamDiagPartieFFORUM.TitreFFORUM^^+nom;
  comment := Concat(comment,'  ');
  LitTournoiNro(Partiebuff^.numeroTournoi,s29);

  s2 := TPCopy(s29,1,25);
  while s2[LENGTH_OF_STRING(s2)] = ' ' do Delete(s2,LENGTH_OF_STRING(s2),1);
  s2 := s2 + ' '+s29[26]+s29[27]+s29[28]+s29[29];
  s29 := s2;

  long := LENGTH_OF_STRING(s29);
  i := 1;
  repeat
    c := s29[i];
    comment := Concat(comment,c);
    i := i+1;
  until (i > long) or (ord(c) = 0);

  i := LENGTH_OF_STRING(s29);
  ParamDiagPartieFFORUM.TitreFFORUM^^ := ParamDiagPartieFFORUM.TitreFFORUM^^+' '+s29[i-3]+s29[i-2]+s29[i-1]+s29[i];

  {ParametresOuvrirThor^^[4] := s29[26]+s29[27]+s29[28]+s29[29];}
  {ParametresOuvrirThor^^[1] := s2;}

  {if referencesCompletes then
   begin
     IntToStr(nroPart,s);
     comment := Concat(comment,'  (N° ',s,CharToString(')'));
   end;}

  {
  IntToStr(Partiebuff^.scoreEtTheorik[0],s2);
  ParametresOuvrirThor^^[5] := s2;
  }
end;

procedure LitUnSolitaireAuHazard(var PositionEtCommentaire : String255);
var nroDeCeSolitaire : SInt32;
    i : SInt32;
    commentaire : String255;
begin
  PositionEtCommentaire := '';
  nroDeCeSolitaire := NroSolitaireAuHazard(numeroDeCoup,couleur,commentaire);
  LitPartieNro(nroDeCeSolitaire);
  if not(windowPlateauOpen) then OuvreFntrPlateau(false);
  if RejoueJusquAuCoup(numeroDeCoup-1) then
    begin
      dernierePartieExtraiteThor := nroDeCeSolitaire;
      if couleurMacintosh = couleur then
        begin
          couleurMacintosh := -couleurMacintosh;
          reponsePrete := false;
          RefleSurTempsJoueur := false;
          LanceInterruption(interruptionSimple);
          vaDepasserTemps := false;
        end;
      finDePartieOptimale := numeroDeCoup-3;
      finaleEnModeSolitaire := true;
      SensLargeSolitaire := true;
      if HumCtreHum then HumCtreHum := not(HumCtreHum);
      if afficheMeilleureSuite then afficheMeilleureSuite := not(afficheMeilleureSuite);
      if afficheSuggestionDeCassio then afficheSuggestionDeCassio := not(afficheSuggestionDeCassio);
      if odd(Random16()) then EffectueSymetrieAxeNW_SE(platSol);
      if odd(Random16()) then EffectueSymetrieAxeNE_SW(platSol);
      FabriqueCommentaire(nroDeCeSolitaire,s);
      commentaire := commentaire+s;
      if referencesCompletes and not(EnVieille3D) then
        begin
          IntToStr(numerodecoup,s);
          commentaire := commentaire+', c.'+s;
        end;
      CompilerPosition(platSol,s);
      PositionEtCommentaire := s+commentaire;
      IntToStr(nroDeCeSolitaire,s);
      if LENGTH_OF_STRING(s) < 5 then for i := 1 to (5-LENGTH_OF_STRING(s)) do s := Concat(s,CharToString(' '));
      PositionEtCommentaire := s+PositionEtCommentaire;
    end;
end;




function PeutchargerTableSolitaires : boolean;
var posEtComment : String255;
    ToutSePasseBien : boolean;
    pathName : String255;
    index : SInt32;
    err : OSErr;
    dirID : SInt32;
begin
  toutSePasseBien := true;
  buffer := bufferPtr(AllocateMemoryPtr(sizeof(t_buffer)));
  partieBuff := partieDansThorDBAPtr(AllocateMemoryPtr(sizeof(t_partieDansThorDBA)));
  if (buffer = NIL) or (partieBuff = NIL)
    then
     begin
       toutsePasseBien := false;
       PeutchargerTableSolitaires := false;
     end
    else
     begin
       MemoryFillChar(buffer,sizeof(buffer^),chr(0));
       filename := CheminAccesThorDBASolitaire^^;
       refvol := VolumeRefThorDBASolitaire;
       err := SetVol(NIL,VolumeRefThorDBASolitaire);
       err := FileExists(filename,refvol,BaseSolitairesFic);
       if err <> 0 then err := FichierTexteDeCassioExiste(filename,BaseSolitairesFic);
       if err = 0 then err := OpenFile(BaseSolitairesFic);

       if err <> 0 then
         begin
           unstringPtr := stringPtr(AllocateMemoryPtr(sizeof(str255)));
           err := HGetVol(unstringPtr,refvol,dirID);
           DisposeMemoryPtr(Ptr(unstringPtr));
           filename := 'Solitaires.dba';
           err := GetFInfo(filename,refvol,finderinf);

           if err <> 0 then
             begin
               filename := 'Solitaires.dba';
               refvol := VolumeRefThorDBASolitaire;
               err := GetFInfo(filename,refvol,finderinf);
             end;


           if err = 0
             then
               begin
                 err := FileExists(filename,refvol,BaseSolitairesFic);
                 if err <> 0 then err := FichierTexteDeCassioExiste(filename,BaseSolitairesFic);
                 if err = 0 then err := OpenFile(BaseSolitairesFic);
                 pathName := GetWDName(refvol);
                 CheminAccesThorDBASolitaire^^ := pathName+filename;
                 VolumeRefThorDBASolitaire := refvol;
               end
             else
               begin
                 if err <> 0 then err := FichierTexteDeCassioExiste('Solitaires.dba',BaseSolitairesFic);
                 if err <> 0 then err := FichierTexteDeCassioExiste('Solitaire.dba',BaseSolitairesFic);
                 if err = 0 then err := OpenFile(BaseSolitairesFic);
               end;

             if err <> 0 then
               begin
                 err := -1;

                 BeginDialog;
                 dp := MyGetNewDialog(PasTrouveThordbaID);
                 if dp <> NIL then
                   begin
                     MyParamText('Solitaires.dba','','','');
                     err := SetDialogTracksCursor(dp,true);
                     repeat
                       ModalDialog(MyFiltreClassiqueUPP,itemHit);
                     until (itemHit = PasTrouveOKBouton) or (itemHit = PasTrouveAnnulerBouton);
                     MyDisposeDialog(dp);
                   end;
                   if (itemHit = PasTrouveAnnulerBouton)
                     then
                       err := -1
                     else
                       begin
                         where.h := 80; where.v := 80;
                         typelist[0] := 'TEXT';
                         typelist[1] := 'BASE';
                         BeginDialog;
                         SFGetFile(where,'',NIL,2,@typelist,NIL,reply);
                         EndDialog;
                         if reply.good
                           then
                             if (Pos('litaires.dba',GetNameOfSFReply(reply)) > 0) or (Pos('LITAIRES.dba',GetNameOfSFReply(reply)) > 0) or
                                (Pos('LITAIRES.DBA',GetNameOfSFReply(reply)) > 0) or (Pos('LITAIRE.DBA',GetNameOfSFReply(reply)) > 0) or
                                (Pos('litaire.dba',GetNameOfSFReply(reply)) > 0)  or (Pos('LITAIRE.dba',GetNameOfSFReply(reply)) > 0) then
                               begin
                                 pathName := GetWDName(reply.vRefNum);
                                 filename := GetNameOfSFReply(reply);
                                 CheminAccesThorDBASolitaire^^ := pathName+filename;
                                 VolumeRefThorDBASolitaire := reply.vRefNum;
                                 err := FileExists(filename,reply.vRefNum,BaseSolitairesFic);
                                 err := OpenFile(BaseSolitairesFic);
                               end
                              else
                                 err := -1
                          else err := -1;  {annulation}
                      end;
                  EndDialog;
                end;
            end;

       if (err <> 0) then toutsepasseBien := false;
       if (err = 0) then
         begin
           watch := GetCursor(watchcursor);
           SafeSetCursor(watch);
           InitialiseValeursBaseThor;
           err := OuvreFichierSolitaires;
           if err = 0
             then
               begin
                 watch := GetCursor(watchcursor);
                 SafeSetCursor(watch);
                 for index := 1 to SolitairesEnMemoire do
                   begin
                     LitUnSolitaireAuHazard(posEtComment);
                     tableSolitaire^^.chaines[index] := posEtComment;
                  {  WriteNumAt(posEtComment+'  ',index,2,11*index);  }
                   end;
                 err := FermeFichierSolitaires;
               end
             else
               toutsepasseBien := false;
           err := CloseFile(BaseSolitairesFic);
         end;
       DisposeMemoryPtr(Ptr(buffer));
       DisposeMemoryPtr(Ptr(Partiebuff));
     end;
  PeutchargerTableSolitaires := toutSePasseBien;
end;

begin
  if BAND(theEvent.modifiers,optionKey) = 0
    then indexSolitaire := indexSolitaire+1
    else indexSolitaire := indexSolitaire-1;
  if (indexSolitaire >= 1) and (indexSolitaire <= SolitairesEnMemoire)
    then
      begin
        s := tableSolitaire^^.chaines[indexSolitaire];
        {WritelnDansRapport('dans PeutchargerTableSolitaires, s = '+s);}
        PlaquerSolitaire(s);
      end
    else
      begin  {charger des solitaires en memoire}
        watch := GetCursor(watchcursor);
        SafeSetCursor(watch);
        if PeutchargerTableSolitaires then
          begin
            indexSolitaire := 1;
            s := tableSolitaire^^.chaines[indexSolitaire];
            PlaquerSolitaire(s);
          end;
        RemettreLeCurseurNormalDeCassio;
      end;
end;

*)

procedure DoDialogueConfigurationSolitaires;
const kPremierNbreDeCasesDansDialogue = 6;
      kDernierNombreDeCasesDansDialogue = 25;
      kPasDeSolitairesEntreOrdiBox = 26;
      kReferencesCompletesBox = 27;
      OK = 1;
      Annuler = 2;
      kDialogueConfigurationSolitairesID = 160;
var nombreSolitaireCetteProf : array[1..64] of SInt32;
    theDialog : DialogPtr;
    itemhit : SInt16;
    err : OSErr;

  procedure DrawDialogueConfigurationSolitaires;
  var s : String255;
      k : SInt32;
      itemRect,myRect : rect;
  begin
    if (theDialog <> NIL) then
      begin
        MyDrawDialog(theDialog);
        TextSize(9);
        TextFont(GenevaID);


        s := ReadStringFromRessource(TextesSolitairesID,33);  {'Plus un solitaire a des cases vides, plus il est difficile'}

        myRect := MakeRect(0,75,1000,91);
        MyEraseRect(myRect);
        MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');
        Moveto(100,myRect.bottom-6);
        MyDrawString(s);

        s := ReadStringFromRessource(TextesSolitairesID,34);  {'Tip : to get a hint while playing a solitaire, hit the delete key'}

        myRect := MakeRect(0,88,1000,103);
        MyEraseRect(myRect);
        MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');
        Moveto(100,myRect.bottom-6);
        MyDrawString(s);

        for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
          begin
            GetDialogItemRect(theDialog,k,itemRect);

            with itemRect do
              myRect := MakeRect(right-50,top,right+30,bottom);
            MyEraseRect(myRect);
            MyEraseRectWithColor(myRect,OrangeCmd,blackPattern,'');

            if (nombreSolitaireCetteProf[k] > 0) and IsCheckBoxOn(theDialog, k) then
              begin
                Moveto(myRect.left,myRect.bottom-5);
                s := ReadStringFromRessource(TextesSolitairesID,32);  {'^0 solitaires'}
                s := ReplaceParameters(s,IntToStr(nombreSolitaireCetteProf[k]),'','','');
                MyDrawString(s);
              end;
          end;

        TextSize(0);
        TextFont(SystemFont);
      end;
  end;

  procedure InitDialogueConfigurationSolitaires;
  var k : SInt32;
  begin
    {affichage de l'etat initial du dialogue}
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
      SetBoolCheckBox(theDialog, k, SolitairesDemandes[k]);
    SetBoolCheckBox(theDialog, kPasDeSolitairesEntreOrdiBox, eviterSolitairesOrdinateursSVP);
    SetBoolCheckBox(theDialog, kReferencesCompletesBox, referencesCompletes);

    {on calcule le nombre de solitaires de chaque profondeur}
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
      SolitairesDemandes[k] := true;
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
      nombreSolitaireCetteProf[k] := NbSolitairesDansCetteIntervalleDeCasesVides(k,k);

    {et on remet le tableau SolitairesDemandes a sa valeur initiale ! }
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
      SolitairesDemandes[k] := IsCheckBoxOn(theDialog, k);

    {on n'active dans le dialogue que les profondeurs avec des solitaires}
    {
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue
    }

  end;

  procedure GetSolitairesDemandesFromDialogue;
  var k : SInt32;
  begin
    for k := 1 to 64 do
      SolitairesDemandes[k] := false;
    for k := kPremierNbreDeCasesDansDialogue to kDernierNombreDeCasesDansDialogue do
      SolitairesDemandes[k] := IsCheckBoxOn(theDialog,k);
    eviterSolitairesOrdinateursSVP := IsCheckBoxOn(theDialog, kPasDeSolitairesEntreOrdiBox);
    referencesCompletes := IsCheckBoxOn(theDialog, kReferencesCompletesBox);
  end;

begin
  BeginDialog;

  theDialog := MyGetNewDialog(kDialogueConfigurationSolitairesID);
  if theDialog <> NIL then
    begin

      InitDialogueConfigurationSolitaires;
      InitCursor;
      DrawDialogueConfigurationSolitaires;

      err := SetDialogTracksCursor(theDialog,true);
      repeat
        ModalDialog(FiltreClassiqueUPP,itemHit);

        case itemHit of
	        VirtualUpdateItemInDialog:
	          begin
	            BeginUpdate(GetDialogWindow(theDialog));
	            SetPortByDialog(theDialog);
	            OutlineOK(theDialog);
	            DrawDialogueConfigurationSolitaires;
	            EndUpdate(GetDialogWindow(theDialog));
	          end;
	        kPremierNbreDeCasesDansDialogue .. kDernierNombreDeCasesDansDialogue :
	          begin
	            ToggleCheckBox(theDialog,itemHit);
	            DrawDialogueConfigurationSolitaires;
	          end;
	        kReferencesCompletesBox,
	        kPasDeSolitairesEntreOrdiBox :
	          ToggleCheckBox(theDialog,itemHit);
	       end; {case}
       until (itemHit = OK) or (itemHit = Annuler);

      if (itemHit = OK) then
        GetSolitairesDemandesFromDialogue;

      MyDisposeDialog(theDialog);
    end;
  EndDialog;
end;



procedure DoEstUnSolitaire;
const PasSolitaireID = 134;
      SolitaireStrictID = 135;
      SolitaireLargeID = 135;    {c'est normal que ça soit le meme}
      AnnulerButton = 2;
      OKButton = 1;
      ValiderButton = 1;
var itemHit : SInt16;
    seulCoup,seuleDef,couleur,prof,score : SInt32;
    nbBlanc,nbNoir : SInt32;
    tempoSensLarge : boolean;
    nbremeill,causerejet : SInt32;
    s,s1 : String255;
    propositiondeValider : boolean;
    oldInterruption : SInt16;
begin

  if not(gameOver) and (interruptionReflexion = pasdinterruption) then
    begin
      oldInterruption := GetCurrentInterruption;
      EnleveCetteInterruption(oldInterruption);
      propositiondeValider := false;
      itemHit := -1;
      s := '';
      s1 := '';
      tempoSensLarge := senslargeSolitaire;
      couleur := AQuiDeJouer;
      nbBlanc := nbreDePions[pionBlanc];
      nbNoir := nbreDePions[pionNoir];
      prof := 64 - (nbBlanc + nbNoir);
      if prof <= 30 then
        begin
          senslargeSolitaire := false;
          if EstUnSolitaire(seulCoup,seuleDef,couleur,prof,nbblanc,nbnoir,JeuCourant,
                            emplJouable,frontiereCourante,score,nbremeill,false,causerejet,kJeuNormal,64)
            then
              begin
                itemHit := AlertTwoButtonsFromRessource(SolitaireStrictID,3,4,ValiderButton,AnnulerButton);
                propositiondeValider := true;
              end
            else
              begin
               if (interruptionReflexion = pasdinterruption) then
                begin
                  senslargeSolitaire := true;
                  if (score >= 0) and (nbremeill = 1)
                    then
                      begin
                        if EstUnSolitaire(seulCoup,seuleDef,couleur,prof,nbblanc,nbnoir,JeuCourant,
                                          emplJouable,frontiereCourante,score,nbremeill,false,causerejet,kJeuNormal,65)
                          then
                            begin
                              itemHit := AlertTwoButtonsFromRessource(SolitaireLargeID,3,4,ValiderButton,AnnulerButton);
                              propositiondeValider := true;
                            end
                          else
                            begin

                              case causerejet of
                                1  : s := ReadStringFromRessource(TextesSolitairesID,21);
                                2  : s := ReadStringFromRessource(TextesSolitairesID,22);
                                3  : s := ReadStringFromRessource(TextesSolitairesID,23);
                                4  : s := ReadStringFromRessource(TextesSolitairesID,24);
                                5  : s := ReadStringFromRessource(TextesSolitairesID,25);
                                6  : s := ReadStringFromRessource(TextesSolitairesID,26);
                                7  : s := ReadStringFromRessource(TextesSolitairesID,27);
                                8  : s := ReadStringFromRessource(TextesSolitairesID,28);
                              end;
                              case couleur of
                                pionNoir  : s1 := ReadStringFromRessource(TextesSolitairesID,19);
                                pionBlanc : s1 := ReadStringFromRessource(TextesSolitairesID,20);
                              end;{case}
                              s := ReplaceParameters(s,s1,'','','');  // s contient une explication de la raison pour laquelle ce n'est pas un solitaire

                              MyParamText('',s,'','');
                              AlertOneButtonFromRessource(PasSolitaireID,2,4,OKButton);
                              itemHit := OKButton;
                            end;
                      end
                    else
                      begin

                        case causerejet of
                          1  : s := ReadStringFromRessource(TextesSolitairesID,21);
                          2  : s := ReadStringFromRessource(TextesSolitairesID,22);
                          3  : s := ReadStringFromRessource(TextesSolitairesID,23);
                          4  : s := ReadStringFromRessource(TextesSolitairesID,24);
                          5  : s := ReadStringFromRessource(TextesSolitairesID,25);
                          6  : s := ReadStringFromRessource(TextesSolitairesID,26);
                          7  : s := ReadStringFromRessource(TextesSolitairesID,27);
                          8  : s := ReadStringFromRessource(TextesSolitairesID,28);
                        end;
                        case couleur of
                          pionNoir  : s1 := ReadStringFromRessource(TextesSolitairesID,19);
                          pionBlanc : s1 := ReadStringFromRessource(TextesSolitairesID,20);
                        end;{case}
                        s := ReplaceParameters(s,s1,'','','');  // s contient une explication de la raison pour laquelle ce n'est pas un solitaire

                        MyParamText('',s,'','');
                        AlertOneButtonFromRessource(PasSolitaireID,2,4,OKButton);
                        itemHit := OKButton;
                      end;
                end;
              end;
          if (itemHit > 0) then
            begin

              if HasGotEvent(updateMask,theEvent,0,NIL) then TraiteOneEvenement;
              if (itemHit = ValiderButton) and propositiondeValider then
                begin
                  if couleurMacintosh = couleur then
                    begin
                      couleurMacintosh := -couleurMacintosh;
                      reponsePrete := false;
                      RefleSurTempsJoueur := false;
                      LanceInterruptionSimple('DoEstUnSolitaire (1)');
                      vaDepasserTemps := false;
                    end;
                  SensLargeSolitaire := true;
                  if HumCtreHum then
                    begin
                      HumCtreHum := not(HumCtreHum);
                      DessineIconesChangeantes;
                      if afficheSuggestionDeCassio and HumCtreHum then EffaceSuggestionDeCassio;

                      DessineCourbe(kCourbeColoree,'DoEstUnSolitaire');
                      DessineSliderFenetreCourbe;

                    end;
                  if afficheMeilleureSuite then afficheMeilleureSuite := not(afficheMeilleureSuite);
                  if afficheSuggestionDeCassio then afficheSuggestionDeCassio := not(afficheSuggestionDeCassio);
                  if afficheNumeroCoup then DoChangeAfficheDernierCoup;


                  PlaquerPosition(JeuCourant,couleur,kRedessineEcran);

                  CommentaireSolitaire^^ := 'Chaine non vide pour indiquer un solitaire';

                  if (AQuiDeJouer <> couleurMacintosh) then
                    begin
                      MyDisableItem(PartieMenu,ForceCmd);
                      AfficheDemandeCoup;
                    end;

                  finaleEnModeSolitaire := true;
                  if score > 0
                    then if couleur = pionNoir
                           then s := ReadStringFromRessource(TextesSolitairesID,1)  {Noir joue et gagne…}
                           else s := ReadStringFromRessource(TextesSolitairesID,2)  {Blanc joue et gagne…}
                    else if couleur = pionNoir
                           then s := ReadStringFromRessource(TextesSolitairesID,3)  {Noir joue et annule…}
                           else s := ReadStringFromRessource(TextesSolitairesID,4); {Noir joue et annule…}
                  CommentaireSolitaire^^ := s;
                  if (nbPartiesActives = 1) and JoueursEtTournoisEnMemoire and
                     (windowListeOpen or windowStatOpen) then
                    begin
                      s := ConstruireChaineReferencesPartieDapresListe(1,referencesCompletes);
                      CommentaireSolitaire^^ := CommentaireSolitaire^^ + '   ' + s;
                    end;

                  EcritCommentaireSolitaire;
                  DoFinaleOptimale(false);
                  FixeMarqueSurMenuMode(nbreCoup);
                end;


              DoFinaleOptimale(false);
              if not(enSetUp) then
                begin
                  if HasGotEvent(updateMask,theEvent,0,NIL) then
                    TraiteOneEvenement;
                end;
             end;
         end;
      senslargeSolitaire := tempoSensLarge;
      LanceInterruption(oldInterruption,'DoEstUnSolitaire');
    end;
end;



procedure DoAfficheFelicitations;
const SonFelicitationsID = 10264;
      FelicitationGainID = 138;
      FelicitationNulleID = 139;
      Annuler = 2;
      AutreSolitaire = 1;
      kVolumeSonFelicitations = 30;
var dp : DialogPtr;
    itemHit : SInt16;
    err : OSErr;
    s,commentaire : String255;
    theChannel : SndChannelPtr;

begin
  if windowPlateauOpen then
  begin
    if CassioEstEnModeSolitaire then
      begin
        BeginDialog;
        commentaire := CommentaireSolitaire^^;
        itemHit := 0;
        s := ReadStringFromRessource(TextesSolitairesID,5);
        if Pos(s,commentaire) > 0
          then dp := MyGetNewDialog(FelicitationGainID)
          else dp := MyGetNewDialog(FelicitationNulleID);
        if dp <> NIL then
          begin
            if AuMoinsUneFelicitation then MoveWindow(GetDialogWindow(dp),FntrFelicitationTopLeft.h,FntrFelicitationTopLeft.v,false);
            if avecSon then
              begin
                OpenChannel(theChannel);
                SetSoundVolumeOfChannel(theChannel, kVolumeSonFelicitations);
                PlaySoundAsynchrone(SonFelicitationsID, kVolumeSonFelicitations, theChannel);
                SetSoundVolumeOfChannel(theChannel, kVolumeSonFelicitations);
              end;
            ShowWindow(GetDialogWindow(dp));
            MyDrawDialog(dp);
            OutlineOK(dp);
            err := SetDialogTracksCursor(dp,true);
            repeat
              ModalDialog(MyFiltreClassiqueUPP,itemHit);
            until (itemHit = AutreSolitaire) or (itemHit = Annuler);

            if avecSon then
              begin
                QuietChannel(theChannel);
                CloseChannel(theChannel);
                HUnlockSoundRessource(SonFelicitationsID);
              end;
            AuMoinsUneFelicitation := true;
            FntrFelicitationTopLeft := GetWindowPortRect(GetDialogWindow(dp)).topleft;
            LocalToGlobal(FntrFelicitationTopLeft);

            MyDisposeDialog(dp);
            peutfeliciter := false;
          end;
        EndDialog;
        if (itemHit = AutreSolitaire) then LanceInterruption(kHumainVeutJouerSolitaires,'DoAfficheFelicitations');
      end;
    end;
end;


procedure EssaieAfficherFelicitation;
const gainNoir = 1;
      gainBlanc = 2;
      PartieNulle = 3;
var etatFinal,coulDuSol : SInt32;
    s,commentaire : String255;
begin
  if peutfeliciter and not(HumCtreHum)
    then
      begin
        if nbredePions[pionNoir] > nbredePions[pionBlanc] then etatFinal := gainNoir;
        if nbredePions[pionNoir] = nbredePions[pionBlanc] then etatFinal := PartieNulle;
        if nbredePions[pionNoir] < nbredePions[pionBlanc] then etatFinal := gainBlanc;
        commentaire := CommentaireSolitaire^^;
        s := ReadStringFromRessource(TextesSolitairesID,19);
        if Pos(s,commentaire) > 0
          then coulDuSol := pionNoir
          else coulDuSol := pionBlanc;
        if coulDuSol = -couleurMacintosh
          then
            begin
              s := ReadStringFromRessource(TextesSolitairesID,6);     {'et annule…'}
              if (Pos(s,commentaire) > 0) and (etatFinal = PartieNulle) then
                begin
                  DoAfficheFelicitations;
                  exit;
                end;
              s := ReadStringFromRessource(TextesSolitairesID,5);     {'et gagne…'}
              if ((Pos(s,commentaire) > 0) and (etatFinal = gainNoir) and (coulDuSol = pionNoir)) or
                 ((Pos(s,commentaire) > 0) and (etatFinal = gainBlanc) and (coulDuSol = pionBlanc)) then
                   begin
                     DoAfficheFelicitations;
                     exit;
                   end;
            end;
      end;
end;


function CassioEstEnRechercheSolitaire : boolean;
begin
  CassioEstEnRechercheSolitaire := gEnRechercheSolitaire;
end;


{ Dans certains contextes, on voudra parfois afficher en gras
  le prompt des solitaires ("Noir joue et gagne…", etc.). On parse
  donc la chaine CommentaireSolitaire pour en extraire le prompt }
procedure ParserCommentaireSolitaire(commentaire : String255; var promptGras,resteDuCommentaire : String255);
var s : String255;
begin
  s := commentaire;

  promptGras := '';
  if (Pos(ReadStringFromRessource(TextesSolitairesID,1),s) = 1) then  {Noir joue et gagne…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,1);
      Delete(s,1,LENGTH_OF_STRING(promptGras));
    end
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,2),s) = 1) then {Blanc joue et gagne…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,2);
      Delete(s,1,LENGTH_OF_STRING(promptGras));
    end
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,3),s) = 1) then {Noir joue et annule…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,3);
      Delete(s,1,LENGTH_OF_STRING(promptGras));
    end
  else if (Pos(ReadStringFromRessource(TextesSolitairesID,4),s) = 1) then {Noir joue et annule…}
    begin
      promptGras := ReadStringFromRessource(TextesSolitairesID,4);
      Delete(s,1,LENGTH_OF_STRING(promptGras));
    end;

  resteDuCommentaire := s;
end;


{ Cette procedure permet d'extraire le nom des noirs, des blancs
  et du tournoi d'une reference de solitaire donnée sous la forme
  "Black to win…   Tatsumi 31—33 Auzende, EGP Paris 2005, c.55" }
function PeutParserReferencesSolitaire(references : String255; var noir,blanc,tournoi : String255) : boolean;
var prompt,reste : String255;
    s1,s2,s3,s4 : String255;
begin

  noir    := '';
  blanc   := '';
  tournoi := '';

  (* quelques exemples :
   references := 'Black to win…   Suzuki M. — 007, Parties Internet (1-6) 2000';
  *)

  ParserCommentaireSolitaire(references,prompt,reste);

  if Pos('…',reste) > 0 then
    if Split(reste,'…',prompt,reste) then DoNothing;

  EnleveEspacesDeGaucheSurPlace(reste);
  EnleveEspacesDeDroiteSurPlace(reste);

  {
  WritelnDansRapport('references = '+references);
  WritelnDansRapport('reste = '+reste);
  }

  if (reste <> '') then
    begin

      if Split(reste,'—',s1,s2) then // note : c'est un tiret long (option — )
        if Split(s2,',',s2,s3) then
          if (Pos(',',s3) <= 0) or Split(s3,',',s3,s4) then
            begin
              noir    := s1;
              blanc   := s2;
              tournoi := s3;

              EnleveEspacesDeGaucheSurPlace(noir);
              EnleveEspacesDeDroiteSurPlace(noir);

              EnleveEspacesDeGaucheSurPlace(blanc);
              EnleveEspacesDeDroiteSurPlace(blanc);

              // enlever le score à la fin de noir
              noir := EnleveChiffresApresCeCaractereEnFinDeLigne(' ',noir,false);

              // enlever le score au debut de blanc
              blanc := EnleveChiffresAvantCeCaractereEnDebutDeLigne(' ',blanc,false);

              EnleveEspacesDeGaucheSurPlace(noir);
              EnleveEspacesDeDroiteSurPlace(noir);

              EnleveEspacesDeGaucheSurPlace(blanc);
              EnleveEspacesDeDroiteSurPlace(blanc);

              // enlever les points a la fin des noms
              While EndsWith(noir,'.') do KeepPrefix(noir,LENGTH_OF_STRING(noir) - 1);
              While EndsWith(blanc,'.') do KeepPrefix(blanc,LENGTH_OF_STRING(blanc) - 1);

              EnleveEspacesDeDroiteSurPlace(noir);
              EnleveEspacesDeDroiteSurPlace(blanc);

              EnleveEspacesDeGaucheSurPlace(tournoi);
              EnleveEspacesDeDroiteSurPlace(tournoi);

              {
              WritelnDansRapport('noir = '+noir);
              WritelnDansRapport('blanc = '+blanc);
              WritelnDansRapport('tournoi = '+tournoi);
              }

            end;
    end;

  PeutParserReferencesSolitaire := (noir <> '') and (blanc <> '') and (tournoi <> '');
end;


END.















































