UNIT UnitStrategie;





INTERFACE







 USES UnitDefCassio;










function PeutJouerIci(couleur,a : SInt32; const plat : plateauOthello) : boolean;
function DoitPasser(coul : SInt32; const plat : plateauOthello; var jouable : plBool) : boolean;
function DoitPasserPlatSeulement(couleur : SInt32; var plat : plateauOthello) : boolean;
function ModifPlatSeulement(a : SInt32; var jeu : plateauOthello; coul : SInt32) : boolean;
function ModifPlatPrise(a : SInt32; var jeu : plateauOthello; coul : SInt32; var nbPionsRetournes : SInt32) : boolean;
{ attention a l'ordre des derniers parametres  }
function ModifPlatFin(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
{ attention a l'ordre des derniers parametres  }
function ModifPlatFast(a,coul : SInt32; var jeu : plateauOthello; var nbPionsCoul,nbPionsAdv : SInt32) : boolean;
function ModifPlatFinDiff(a,coul : SInt32; var jeu : plateauOthello; var diffPions : SInt32) : boolean;
function ModifPlatFinDiffFast(a,couleur,couleurEnnemie : SInt32; var jeu : plateauOthello; var diffPions : SInt32) : boolean;
function ModifPlatSeulementLongint(a,couleur,couleurEnnemie : SInt32; var jeu : plOthEndgame) : boolean;
function ModifPlatLongint(a,coul : SInt32; var jeu : plateauOthello; var jouable : plBool; var nbbl,nbno : SInt32; var front : InfoFront) : boolean;
procedure OthellierEtPionsDeDepart(var plat : plateauOthello; var nBla,nNoi : SInt32);
procedure OthellierDeDepart(var plat : plateauOthello);
procedure VideOthellier(var plat : plateauOthello);
function MakeOthellierVide : plateauOthello;
function EstLaPositionStandardDeDepart(const plat : plateauOthello) : boolean;
procedure CarteMove(coul : SInt32; const plat : plateauOthello; var carte : plBool; var mobilite : SInt32);
function NbreDirectionsJouables(couleur,a : SInt32; var plat : plateauOthello) : SInt32;
function PeutJouerIciUnidirectionnel(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var deltaFrontiere : SInt32) : SInt32;
function PeutJouerIciBonCoup(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var coupTranquille : boolean) : boolean;
function ValeurUnidirectionnelleDuCoup(couleur,a : SInt32; var plat : plateauOthello) : SInt32;
function ValeurSemiTranquilleDuCoup(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var coupTranquille : boolean; var deltaFrontiere : SInt32) : SInt32;
function mobiliteUnidirectionnelle(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
function mobiliteUnidirectionnelleMinimisante(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
function mobiliteUnidirectionnelleAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
function mobiliteUnidirectionnelleMinimisanteAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
function mobiliteBonsCoups(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront; var nbCoupsTranquilles : SInt32) : SInt32;
function MobiliteSemiTranquilleAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront; var ListeDesCoupsTranquilles : ListeDeCases; seuil_coupure : SInt32) : SInt32;
function Influence(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
function CoupAleatoire(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
function CoupAleatoireDonnantPleinDeMobilite(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
function CoupAleatoireDonnantPeuDeMobilite(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
function TrouverUneCaseRemplie(const plat : plateauOthello) : SInt32;
function CalculeMobilite(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
function CalculeMobilitePlatSeulement(const plat : plateauOthello; coul : SInt32) : SInt32;
function NbCoinsPrenables(coul : SInt32; var plat : plateauOthello) : SInt32;
function PeutPrendreUnCoin(coul : SInt32; var plat : plateauOthello) : boolean;
function NbCoins(coul : SInt32; var plat : plateauOthello) : SInt32;
function NbLibertes(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
function MobiliteEffective(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
function ComptePrise(var a,couleur : SInt32; var plat : plateauOthello; var coupPossible : boolean) : SInt32;
procedure CarteJouable(const plat : plateauOthello; var carte : plBool);
procedure CarteVide(const plat : plateauOthello; var carte : plateauOthello);
procedure CarteFrontiere(const plat : plateauOthello; var front : InfoFront);
function ModifScoreFin(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
function CaseXSacrifiee(var plat : plateauOthello) : boolean;
function PasDeBordDeCinqAttaque(couleur : SInt32; var front : InfoFront; const plat : plateauOthello) : boolean;
function BordDeCinqUrgent(var plat : plateauOthello; var front : InfoFront) : boolean;
function EstTurbulent(const pl : plateauOthello; couleur,nbBlancs,nbNoirs : SInt32; var front : InfoFront; var caseCritiqueTurbulence : SInt32) : boolean;
function VerificationConnexiteOK(jeu : plateauOthello) : boolean;
function VerificationNbreMinimalDePions(jeu : plateauOthello; nbreMinimalDePions : SInt32) : boolean;
function PositionsEgales(var plat1,plat2 : plateauOthello) : boolean;
procedure CalculePositionFinale(const ligne : String255; var plat : plateauOthello; var ligneLegale : boolean; var nbCoupsLegaux : SInt32);
procedure CoupAuHazard(CouleurChoix : SInt32; jeu : plateauOthello; empl : plBool; var ChoixX,valeur : SInt32);
function ModifPlat(a,coul : SInt32; var jeu : plateauOthello; var jouable : plBool; var nbbl,nbno : SInt32; var front : InfoFront) : boolean;
function nbBordDeCinqTransformablesPourBlanc(const plat : plateauOthello; var front : InfoFront) : SInt32;
function BonsBordsDeCinqNoirs(var plat : plateauOthello; var front : InfoFront) : SInt32;
function BonsBordsDeCinqBlancs(var plat : plateauOthello; var front : InfoFront) : SInt32;
function TrousDeTroisBlancsHorribles(const plat : plateauOthello) : SInt32;
function TrousDeTroisNoirsHorribles(const plat : plateauOthello) : SInt32;
function TrousBlancsDeDeuxPerdantLaParite(var plat : plateauOthello) : SInt32;
function TrousNoirsDeDeuxPerdantLaParite(var plat : plateauOthello) : SInt32;
function LibertesNoiresSurCasesA(const plat : plateauOthello; var front : InfoFront) : SInt32;
function LibertesBlanchesSurCasesA(const plat : plateauOthello; var front : InfoFront) : SInt32;
function LibertesNoiresSurCasesB(var plat : plateauOthello) : SInt32;
function LibertesBlanchesSurCasesB(var plat : plateauOthello) : SInt32;
function PasDeCoinEnPrise(var plat : plateauOthello; var jouable : plBool) : boolean;
function ArnaqueSurBordDeCinqBlanc(const pl : plateauOthello; var front : InfoFront) : SInt32;
function ArnaqueSurBordDeCinqNoir(const pl : plateauOthello; var front : InfoFront) : SInt32;
function NotationBordsOpposesPourNoir(var pl : plateauOthello) : SInt32;
function BordDeSixNoirAvecPrebordHomogene(var pl : plateauOthello; var front : InfoFront) : SInt32;
function BordDeSixBlancAvecPrebordHomogene(var pl : plateauOthello; var front : InfoFront) : SInt32;
function PionsIsolesNoirsSurCasesThill(var pl : plateauOthello) : SInt32;
function PionsIsolesBlancsSurCasesThill(var pl : plateauOthello) : SInt32;
function NoteCasesCoinsCarreCentralPourNoir(var pl : plateauOthello) : SInt32;
function NoteJeuCasesXPourNoir(var pl : plateauOthello; nbNoirs,nbBlancs : SInt32) : SInt32;
function NoteJeuCasesXPourBlanc(var pl : plateauOthello; nbNoirs,nbBlancs : SInt32) : SInt32;
function PasDeControleDeDiagonaleEnCours(couleur : SInt32; var pl : plateauOthello) : boolean;
function NbPionsDefinitifsSurLesBords(couleur : SInt32; var plat : plateauOthello) : SInt32;
function NbPionsDefinitifs(couleur : SInt32; var plat : plateauOthello) : SInt32;
function NbPionsDefinitifsAvecInterieurs(couleur : SInt32; var p : plateauOthello) : SInt32;
function NbPionsDefinitifsSurLesBordsEndgame(couleur : SInt32; var plat : plOthEndgame) : SInt32;
function NbPionsDefinitifsEndgame(couleur : SInt32; var plat : plOthEndgame) : SInt32;
function NbPionsDefinitifsAvecInterieursEndgame(couleur : SInt32; var p : plOthEndgame) : SInt32;
function CoinPlusProche(a : SInt32) : SInt32;
function CoinPlusProcheVide(a : SInt32; var jeu : plateauOthello) : boolean;
function PlusProcheCaseA(a : SInt32) : SInt32;
function PlusProcheCaseX(a : SInt32) : SInt32;
function EstUneCaseBordNord(a : SInt32) : boolean;
function EstUneCaseBordSud(a : SInt32) : boolean;
function EstUneCaseBordOuest(a : SInt32) : boolean;
function EstUneCaseBordEst(a : SInt32) : boolean;
function estUneCaseX(a : SInt32) : boolean;
function estUneCasePetitCoin(a : SInt32) : boolean;
function GenreDeReflexionInSet(genre : SInt16; whichSet : ReflexionTypesSet) : boolean;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitScannerUtils, UnitServicesMemoire, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/Strategie.lk}
{$ENDC}


{END_USE_CLAUSE}











 CONST

    kCoupMultiDirectionnelNonTranquille        = -1;
    kCoupIllegal                               = 0;
    kCoupUnidirectionnelNonTranquille          = 1;
    kCoupUnidirectionnelTranquille             = 2;
    kCoupPlusieursDir1NonTranquille            = 3;
    kCoupPlusieursDir1NonTranquilleMinimisante = 4;
    kCoupMultiDirectionnelTranquille           = 5;
    kCoupPresqueTranquille                     = 6;



    bordDeSixBlanc = 1092;                     { .oooooo. }
    bordDeSixNoir = -1092;                     { .xxxxxx. }
    bordDeCinqBlancType1 = 1089;               { ..ooooo. }
    bordDeCinqBlancType2 = 363;                { .ooooo.. }
    bordDeCinqNoirType1 = -1089;               { ..xxxxx. }
    bordDeCinqNoirType2 = -363;                { .xxxxx.. }
    bordDeQuatreBlancType1 = 1080;             { ...oooo. }
    bordDeQuatreBlancType2 = 120;              { .oooo... }
    bordDeQuatreNoirType1 = -1080;             { ...xxxx. }
    bordDeQuatreNoirType2 = -120;              { .xxxx... }
    bordDeQuatreTroueBlancType1 = 756;         { ...o..o. }
    bordDeQuatreTroueBlancType2 = 84;          { .o..o... }
    bordDeQuatreTroueNoirType1 = -756;         { ...x..x. }
    bordDeQuatreTroueNoirType2 = -84;          { .x..x... }
    borddeTroisBlancStonerType1 = 1044;        { ..x.ooo. }
    borddeTroisBlancStonerType2 = -204;        { .ooo.x.. }
    borddeDeuxBlancStonerType1 = 936;          { ..xx.oo. }
    borddeDeuxBlancStonerType2 = -312;         { .oo.xx.. }
    borddeUnBlancStonerType1 = 612;            { ..xxx.o. }
    borddeUnBlancStonerType2 = -348;           { .o.xxx.. }
    borddeTroisNoirStonerType1 = -1044;        { ..o.xxx. }
    borddeTroisNoirStonerType2 = 204;          { .xxx.o.. }
    borddeDeuxNoirStonerType1 = -936;          { ..oo.xx. }
    borddeDeuxNoirStonerType2 = 312;           { .xx.oo.. }
    borddeUnNoirStonerType1 = -612;            { ..ooo.x. }
    borddeUnNoirStonerType2 = 348;             { .x.ooo.. }


    bordMarconisationParNoir1 = 144;           { ..oxxo.. }
    bordMarconisationParNoir2 = 198;           { ..ooxo.. }
    bordMarconisationParNoir3 = 306;           { ..oxoo.. }

    bordBaghatBlanc1 = 90;                     { ..o.o... }
    bordBaghatBlanc2 = 270;                    { ...o.o.. }
    bordBaghatisationParNoir1 = 63;            { ..oxo... }
    bordBaghatisationParNoir2 = 189;           { ...oxo.. }


    bordMarconisationParBlanc1 = -144;         { ..xoox.. }
    bordMarconisationParBlanc2 = -198;         { ..xxox.. }
    bordMarconisationParBlanc3 = -306;         { ..xoxx.. }

    bordBaghatNoir1 = -90;                     { ..x.x... }
    bordBaghatNoir2 = -270;                    { ...x.x.. }
    bordBaghatisationParBlanc1 = -63;          { ..xox... }
    bordBaghatisationParBlanc2 = -189;         { ...xox.. }

    bordVide = 0;


function PeutJouerIci(couleur,a : SInt32; const plat : plateauOthello) : boolean;
var x,dx,t : SInt32;
    pionEnnemi : SInt32;
begin
  {
  WriteNumAt('PeutJouerIci   ',TickCount,10,10);
  WriteNumAt('PeutJouerIci   ',TickCount,10,20);
  WriteNumAt('a = ',a,10,30);
  if plat[a] <> pionVide then
    begin
      WriteNumAt('plat[a] <> 0 !!!',a,30,30);
      SysBeep(0);
      AttendFrappeClavier;
      sysbreak;
    end;
  WriteNumAt('                  ',a,30,30);
  WriteNumAt('dirPriseDeb[a] = ',dirPriseDeb[a],10,40);
  WriteNumAt('dirPriseFin[a] = ',dirPriseFin[a],10,50);
  }
  if (couleur <> pionVide) then
    begin
      pionEnnemi := -couleur;
      for t := dirPriseDeb[a] to dirPriseFin[a] do
        begin
          dx := dirPrise[t];
          x := a+dx;
          if plat[x] = pionEnnemi then
            begin
              repeat
                x := x+dx;
              until plat[x] <> pionEnnemi;
              if (plat[x] = couleur) then
                begin
                  PeutJouerIci := true;
                  exit(PeutJouerIci)
                end;
            end;
        end;
    end;

  PeutJouerIci := false;
end;


function DoitPasser(coul : SInt32; const plat : plateauOthello; var jouable : plBool) : boolean;
var x,t : SInt32;
begin
   DoitPasser := true;
   for t := 1 to 64 do
   begin
    x := othellier[t];
    if jouable[x] then
     if PeutJouerIci(coul,x,plat) then
       begin
         DoitPasser := false;
         exit(DoitPasser);
       end;
   end;
end;

function DoitPasserPlatSeulement(couleur : SInt32; var plat : plateauOthello) : boolean;
var a,x,dx,t,adversaire,n : SInt32;
begin
  adversaire := -couleur;
  for n := 1 to 64 do
    begin
      a := othellier[n];
      if plat[a] = pionVide then
        for t := dirPriseDeb[a] to dirPriseFin[a] do
          begin
            dx := dirPrise[t];
            x := a+dx;
            if plat[x] = adversaire then
              begin
                repeat
                  x := x+dx;
                until plat[x] <> adversaire;
                if (plat[x] = couleur) then
                  begin
                    DoitPasserPlatSeulement := false;
                    exit(DoitPasserPlatSeulement)
                  end;
              end;
          end;
    end;
  DoitPasserPlatSeulement := true;
end;



function ModifPlatSeulement(a : SInt32; var jeu : plateauOthello; coul : SInt32) : boolean;
var x,dx,i,t : SInt32;
    pionEnnemi,compteur : SInt32;
begin
   if (coul = pionVide) then
     begin
       WritelnDansRapport('ASSERT : (coul = pionVide) dans ModifPlatSeulement !! Prévenez Stéphane');
       WritelnStringAndCoupDansRapport('  pour info, a = ',a);
       ModifPlatSeulement := false;
       exit(ModifPlatSeulement);
     end;

   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a + dx;
       if (jeu[x] = pionEnnemi) then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x + dx;
           until (jeu[x] <> pionEnnemi);
           if (jeu[x] = coul) then
             begin
               jeu[a] := coul;
               for i := 1 to compteur do
                 begin
                  x := x - dx;
                  jeu[x] := coul;
                 end;
             end;
        end;
     end;
   ModifPlatSeulement := (jeu[a] = coul);
end;


function ModifPlatPrise(a : SInt32; var jeu : plateauOthello; coul : SInt32; var nbPionsRetournes : SInt32) : boolean;
var x,dx,i,t : SInt32;
    pionEnnemi,compteur : SInt32;
begin
   nbPionsRetournes := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a + dx;
       if (jeu[x] = pionEnnemi) then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x + dx;
           until (jeu[x] <> pionEnnemi);
           if (jeu[x] = coul) then
             begin
               nbPionsRetournes := nbPionsRetournes+compteur;
               jeu[a] := coul;
               for i := 1 to compteur do
                 begin
                  x := x - dx;
                  jeu[x] := coul;
                 end;
             end;
        end;
     end;
   ModifPlatPrise := nbPionsRetournes > 0;
end;



{ attention a l'ordre des derniers parametres  }
function ModifPlatFin(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
var x,dx,i,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if (jeu[x] = pionEnnemi) then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x + dx;
           until (jeu[x] <> pionEnnemi);
           if (jeu[x] = coul) then
             begin
               modifie := true;
               for i := 1 to compteur do
                 begin
                  x := x - dx;
                  jeu[x] := coul;
                 end;
               nbprise := nbprise+compteur;
             end;
        end;
     end;
   if modifie then
     begin
       if coul = pionNoir
         then begin
             nbNo := succ(nbNo + nbprise);
             nbbl := nbbl - nbprise;
           end
         else begin
             nbNo := nbNo - nbprise;
             nbbl := succ(nbbl + nbprise);
           end;
       jeu[a] := coul;
     end;
   ModifPlatFin := modifie;
end;

{ attention a l'ordre des derniers parametres  }
function ModifPlatFast(a,coul : SInt32; var jeu : plateauOthello; var nbPionsCoul,nbPionsAdv : SInt32) : boolean;
var x,dx,i,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
      dx := dirPrise[t];
      x := a+dx;
      if jeu[x] = pionEnnemi then
        begin
          compteur := 0;
          repeat
            inc(compteur);
            x := x+dx;
          until jeu[x] <> pionEnnemi;
          if (jeu[x] = coul) then
            begin
              modifie := true;
              for i := 1 to compteur do
                begin
                 x := x-dx;
                 jeu[x] := coul;
                end;
              nbprise := nbprise+compteur;
            end;
        end;
     end;
   if modifie then
     begin
       nbPionsCoul := succ(nbPionsCoul+nbprise);
       nbPionsAdv := nbPionsAdv-nbprise;
       jeu[a] := coul;
     end;
   ModifPlatFast := modifie;
end;

function ModifPlatFinDiff(a,coul : SInt32; var jeu : plateauOthello; var diffPions : SInt32) : boolean;
var x,dx,i,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if jeu[x] = pionennemi then
         begin
           compteur := 0;
           repeat
             inc(compteur);
             x := x+dx;
           until jeu[x] <> pionennemi;
           if (jeu[x] = coul)then
             begin
               modifie := true;
               for i := 1 to compteur do
                 begin
                  x := x-dx;
                  jeu[x] := coul;
                 end;
               nbprise := nbprise+compteur;
             end;
        end;
     end;
   if modifie then
     begin
       diffPions := succ(diffPions+nbprise+nbprise);
       jeu[a] := coul;
     end;
   ModifPlatFinDiff := modifie;
end;

function ModifPlatFinDiffFast(a,couleur,couleurEnnemie : SInt32; var jeu : plateauOthello; var diffPions : SInt32) : boolean;
var x1,x2,x3,x4,x5,x6,dx,t,nbprise : SInt32;
begin
   nbprise := 0;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x1 := a+dx;
       if jeu[x1] = couleurEnnemie then {1}
         begin
           x2 := x1+dx;
           if jeu[x2] = couleurEnnemie then  {2}
           begin
             x3 := x2+dx;
             if jeu[x3] = couleurEnnemie then  {3}
		           begin
		             x4 := x3+dx;
		             if jeu[x4] = couleurEnnemie then  {4}
				           begin
				             x5 := x4+dx;
				             if jeu[x5] = couleurEnnemie then  {5}
						           begin
						             x6 := x5+dx;
						             if jeu[x6] = couleurEnnemie then  {6}
								           begin
								             if jeu[x6+dx] = couleur then  {seul cas à tester}
									             begin
									               nbprise := nbprise+12;
									               jeu[x6] := couleur;
									               jeu[x5] := couleur;
									               jeu[x4] := couleur;
									               jeu[x3] := couleur;
									               jeu[x2] := couleur;
									               jeu[x1] := couleur;
									             end;
								           end
								           else
								           if jeu[x6] = couleur then
								             begin
								               nbprise := nbprise+10;
								               jeu[x5] := couleur;
								               jeu[x4] := couleur;
								               jeu[x3] := couleur;
								               jeu[x2] := couleur;
								               jeu[x1] := couleur;
								             end;
						           end
						           else
						           if jeu[x5] = couleur then
						             begin
						               nbprise := nbprise+8;
						               jeu[x4] := couleur;
						               jeu[x3] := couleur;
						               jeu[x2] := couleur;
						               jeu[x1] := couleur;
						             end;
				           end
                   else
				           if jeu[x4] = couleur then
				             begin
				               nbprise := nbprise+6;
				               jeu[x3] := couleur;
				               jeu[x2] := couleur;
				               jeu[x1] := couleur;
				             end;
		           end
		           else
		           if jeu[x3] = couleur then
		             begin
		               nbprise := nbprise+4;
		               jeu[x2] := couleur;
		               jeu[x1] := couleur;
		             end;
           end
           else
           if jeu[x2] = couleur then
             begin
               nbprise := nbprise+2;
               jeu[x1] := couleur;
             end;
        end;
     end;
   if (nbprise > 0)
     then
	     begin
	       diffPions := succ(diffPions+nbprise);
	       jeu[a] := couleur;
	       ModifPlatFinDiffFast := true;
	     end
	   else
	     ModifPlatFinDiffFast := false;
end;

function ModifPlatSeulementLongint(a,couleur,couleurEnnemie : SInt32; var jeu : plOthEndgame) : boolean;
var x1,x2,x3,x4,x5,x6,dx,t : SInt32;
begin
   ModifPlatSeulementLongint := false;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x1 := a+dx;
       if jeu[x1] = couleurEnnemie then {1}
         begin
           x2 := x1+dx;
           if jeu[x2] = couleurEnnemie then  {2}
           begin
             x3 := x2+dx;
             if jeu[x3] = couleurEnnemie then  {3}
		           begin
		             x4 := x3+dx;
		             if jeu[x4] = couleurEnnemie then  {4}
				           begin
				             x5 := x4+dx;
				             if jeu[x5] = couleurEnnemie then  {5}
						           begin
						             x6 := x5+dx;
						             if jeu[x6] = couleurEnnemie then  {6}
								           begin
								             if jeu[x6+dx] = couleur then  {seul cas à tester}
									             begin
									               jeu[a] := couleur;
									               jeu[x6] := couleur;
									               jeu[x5] := couleur;
									               jeu[x4] := couleur;
									               jeu[x3] := couleur;
									               jeu[x2] := couleur;
									               jeu[x1] := couleur;
									               ModifPlatSeulementLongint := true;
									             end;
								           end
								           else
								           if jeu[x6] = couleur then
								             begin
								               jeu[a] := couleur;
								               jeu[x5] := couleur;
								               jeu[x4] := couleur;
								               jeu[x3] := couleur;
								               jeu[x2] := couleur;
								               jeu[x1] := couleur;
								               ModifPlatSeulementLongint := true;
								             end;
						           end
						           else
						           if jeu[x5] = couleur then
						             begin
						               jeu[a] := couleur;
						               jeu[x4] := couleur;
						               jeu[x3] := couleur;
						               jeu[x2] := couleur;
						               jeu[x1] := couleur;
						               ModifPlatSeulementLongint := true;
						             end;
				           end
                   else
				           if jeu[x4] = couleur then
				             begin
				               jeu[a] := couleur;
				               jeu[x3] := couleur;
				               jeu[x2] := couleur;
				               jeu[x1] := couleur;
				               ModifPlatSeulementLongint := true;
				             end;
		           end
		           else
		           if jeu[x3] = couleur then
		             begin
		               jeu[a] := couleur;
		               jeu[x2] := couleur;
		               jeu[x1] := couleur;
		               ModifPlatSeulementLongint := true;
		             end;
           end
           else
           if jeu[x2] = couleur then
             begin
               jeu[a] := couleur;
               jeu[x1] := couleur;
               ModifPlatSeulementLongint := true;
             end;
        end;
     end;
end;


function ModifPlatLongint(a,coul : SInt32; var jeu : plateauOthello; var jouable : plBool; var nbbl,nbno : SInt32; var front : InfoFront) : boolean;
var x,dx,i,k,t,nbprise,nbvideDeX,jeuDeX,whichPattern : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin

   if (a < 11) or (a > 88) or (jeu[a] <> pionVide) then
     begin
       ModifPlatLongint := false;
       exit(ModifPlatLongint);
     end;

   {exeptionnellement, pour le debugage seulement !}
   if (a < 11) then AlerteSimple('Debugger : a = '+NumEnString(a)+' dans ModifPlatLongint') else
   if (a > 88) then AlerteSimple('Debugger : a = '+NumEnString(a)+' dans ModifPlatLongint') else
   if (jeu[a] <> pionVide) then AlerteSimple('Debugger : jeu['+NumEnString(a)+'] <> 0 dans ModifPlatLongint');


   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if jeu[x] = pionEnnemi then
         begin
           compteur := 0;
           repeat
             {exeptionnellement, pour le debugage seulement !}
             {if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);}
             inc(compteur);
             x := x+dx;
           until jeu[x] <> pionEnnemi;

           if (jeu[x] = coul) then
             begin
               modifie := true;
	             x := x-dx;
	             for i := 1 to compteur do
	               begin
	                 jeu[x] := coul;
	                 with front do
	                   begin

	                     for k := 1 to nbPatternsImpliques[x] do
							           begin
							             whichPattern := nroPattern[x,k];
							             AdressePattern[whichPattern] := AdressePattern[whichPattern]+coul*DoubleDeltaAdresse[x,k];
							           end;

	                     nbvideDeX := nbvide[x];
	                     if nbvideDeX > 0 then
	                       begin
	                         inc(nbfront[coul]);
	                         dec(nbfront[-coul]);
	                         nbadjacent[coul] := nbadjacent[coul]+nbvideDeX;
	                         nbadjacent[-coul] := nbadjacent[-coul]-nbvideDeX;
	                       end;

	                   end;
	                 x := x-dx;
	               end;
	             nbprise := nbprise+compteur;
             end;
         end;
     end;


   if modifie then
     begin
       inc(nbreNoeudsGeneresMilieu);

       jouable[a] := false;
       jeu[a] := coul;

       with front do
         begin

          for k := 1 to nbPatternsImpliques[a] do
	          begin
	            whichPattern := nroPattern[a,k];
	            AdressePattern[whichPattern] := AdressePattern[whichPattern]+coul*DeltaAdresse[a,k];
	          end;

          if nbvide[a] > 0 then inc(nbfront[coul]);
          nbadjacent[coul] := nbadjacent[coul]+nbvide[a];
          for t := dirPriseDeb[a] to dirPriseFin[a] do
            begin
               x := a+dirPrise[t];
               jeuDeX := jeu[x];
               nbvideDeX := nbVide[x];
               if nbvideDeX > 0 then
                  begin
                    if nbvideDeX = 1 then  {si on vient de prendre la derniere liberte d'une case}
                       dec(nbfront[jeuDeX]);
                    nbVide[x] := pred(nbvideDeX);
                  end;
               dec(nbadjacent[jeuDeX]);
             end;

           if coul = pionNoir {valeurtact etabli pour Noir}
             then begin
                 nbNo := nbNo+nbprise+1;
                 nbbl := nbbl-nbprise;
                 occupationtactique := occupationTactique+valeurTactNoir[a]
               end
             else begin
                 nbNo := nbNo-nbprise;
                 nbbl := nbbl+nbprise+1;
                 occupationtactique := occupationTactique-valeurTactBlanc[a];
               end;
         end;
       for t := dirJouableDeb[a] to dirJouableFin[a] do
         begin
           x := a+dirJouable[t];
           jouable[x] := (jeu[x] = 0);
         end;
     end;
   ModifPlatLongint := modifie;
end;

procedure OthellierEtPionsDeDepart(var plat : plateauOthello; var nBla,nNoi : SInt32);
var i : SInt32;
begin
  MemoryFillChar(@plat,sizeof(plat),chr(0));
  for i := 0 to 99 do
    if interdit[i] then plat[i] := PionInterdit;
  plat[44] := pionBlanc;
  plat[55] := pionBlanc;
  plat[45] := pionNoir;
  plat[54] := pionNoir;
  nBla := 2;
  nNoi := 2;
end;

procedure OthellierDeDepart(var plat : plateauOthello);
var dummyBlancs,dummyNoirs : SInt32;
begin
  OthellierEtPionsDeDepart(plat,dummyBlancs,dummyNoirs);
end;


procedure VideOthellier(var plat : plateauOthello);
var i : SInt32;
begin
  MemoryFillChar(@plat,sizeof(plat),chr(0));
  for i := 0 to 99 do
    if interdit[i] then plat[i] := PionInterdit;
end;


function MakeOthellierVide : plateauOthello;
var plat : plateauOthello;
begin
  VideOthellier(plat);
  MakeOthellierVide := plat;
end;


function EstLaPositionStandardDeDepart(const plat : plateauOthello) : boolean;
var test : boolean;
    t : SInt32;
begin
  test := (plat[44] = pionBlanc) and (plat[55] = pionBlanc) and
        (plat[45] = pionNoir) and (plat[54] = pionNoir);
  if test then
    begin
      t := 0;
      repeat
        t := t+1;
        test := test and (plat[othellier[t]] = pionVide);
      until not(test) or (t >= 60);
    end;
  EstLaPositionStandardDeDepart := test;
end;





{ CarteMove etablit les endroits où une couleur peut jouer
 et place le resultat dans carte}
procedure CarteMove(coul : SInt32; const plat : plateauOthello; var carte : plBool; var mobilite : SInt32);
var x,t : SInt32;
begin
   MemoryFillChar(@carte,sizeof(carte),char(false));
   mobilite := 0;
   if (coul <> pionVide) and ((coul = pionBlanc) or (coul = pionNoir)) then
     for t := 1 to 64 do
       begin
         x := othellier[t];
         if plat[x] = pionVide then
         begin
            carte[x] := PeutJouerIci(coul,x,plat);
            if carte[x] then inc(mobilite);
         end;
       end;
end;

function CoupAleatoire(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
var x,t,mobilite,coup,compteur : SInt32;
    listeCoups : array[0..64] of SInt32;
begin

   if (coul = pionVide) then
     begin
       CoupAleatoire := 0;
       exit(CoupAleatoire);
     end;

   mobilite := 0;
   for t := 1 to 64 do
   begin
     x := othellier[t];
     if plat[x] = pionVide then
       if PeutJouerIci(coul,x,plat) then
         begin
           inc(mobilite);
           listeCoups[mobilite] := x;
         end;
   end;
   if (mobilite <= 0)
     then CoupAleatoire := 0
     else
       begin

         coup := 0;
         compteur := 0;
         repeat
           inc(compteur);
           coup := listeCoups[1+(Abs(Random) mod mobilite)];
         until (compteur > 20) or not(coup in casesInterdites);

         CoupAleatoire := coup;
       end;
end;


function CoupAleatoireDonnantPleinDeMobilite(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
var x,t,mobilite,coup,compteur,mobAdverse : SInt32;
    listeCoups : array[0..64] of SInt32;
    platAux : plateauOthello;
    carte : plBool;
    mobAdverseMax : SInt32;
begin

   if (coul = pionVide) then
     begin
       CoupAleatoireDonnantPleinDeMobilite := 0;
       exit(CoupAleatoireDonnantPleinDeMobilite);
     end;

   mobilite := 0;
   mobAdverseMax := -1000;
   platAux := plat;

   for t := 1 to 64 do
   begin
     x := othellier[t];
     if plat[x] = pionVide then
       if ModifPlatSeulement(x,platAux,coul) then
         begin

           CarteMove(-coul,platAux,carte,mobAdverse);

           if (mobAdverse = mobAdverseMax) then
             begin
               inc(mobilite);
               listeCoups[mobilite] := x;
             end;

           if (mobAdverse > mobAdverseMax) then
             begin
               mobilite := 1;
               listeCoups[mobilite] := x;
               mobAdverseMax := mobAdverse;
             end;

           platAux := plat;
         end;
   end;

   if (mobilite <= 0)
     then CoupAleatoireDonnantPleinDeMobilite := CoupAleatoire(coul,plat,casesInterdites)
     else
       begin

         coup := 0;
         compteur := 0;
         repeat
           inc(compteur);
           coup := listeCoups[1+(Abs(Random) mod mobilite)];
         until (compteur > 20) or not(coup in casesInterdites);

         CoupAleatoireDonnantPleinDeMobilite := coup;
       end;
end;

function CoupAleatoireDonnantPeuDeMobilite(coul : SInt32; var plat : plateauOthello; var casesInterdites : SquareSet) : SInt32;
var x,t,mobilite,coup,compteur,mobAdverse : SInt32;
    listeCoups : array[0..64] of SInt32;
    platAux : plateauOthello;
    carte : plBool;
    mobAdverseMin : SInt32;
begin

   if (coul = pionVide) then
     begin
       CoupAleatoireDonnantPeuDeMobilite := 0;
       exit(CoupAleatoireDonnantPeuDeMobilite);
     end;

   mobilite := 0;
   mobAdverseMin := 1000;
   platAux := plat;

   for t := 1 to 64 do
   begin
     x := othellier[t];
     if plat[x] = pionVide then
       if ModifPlatSeulement(x,platAux,coul) then
         begin

           CarteMove(-coul,platAux,carte,mobAdverse);

           if (mobAdverse = mobAdverseMin) then
             begin
               inc(mobilite);
               listeCoups[mobilite] := x;
             end;

           if (mobAdverse < mobAdverseMin) then
             begin
               mobilite := 1;
               listeCoups[mobilite] := x;
               mobAdverseMin := mobAdverse;
             end;

           platAux := plat;
         end;
   end;

   if (mobilite <= 0)
     then CoupAleatoireDonnantPeuDeMobilite := CoupAleatoire(coul,plat,casesInterdites)
     else
       begin

         coup := 0;
         compteur := 0;
         repeat
           inc(compteur);
           coup := listeCoups[1+(Abs(Random) mod mobilite)];
         until (compteur > 20) or not(coup in casesInterdites);

         CoupAleatoireDonnantPeuDeMobilite := coup;
       end;
end;



function CalculeMobilite(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
var x,t,somme : SInt32;
begin
   somme := 0;
   for t := 1 to 64 do
   begin
     x := othellier[t];
     if jouable[x] then
       if PeutJouerIci(coul,x,plat) then inc(somme);
   end;
   CalculeMobilite := somme;
end;

function CalculeMobilitePlatSeulement(const plat : plateauOthello; coul : SInt32) : SInt32;
var x,t,somme : SInt32;
begin
   somme := 0;
   for t := 1 to 64 do
   begin
     x := othellier[t];
     if plat[x] = pionVide then
       if PeutJouerIci(coul,x,plat) then inc(somme);
   end;
   CalculeMobilitePlatSeulement := somme;
end;

{renvoie  0 si couleur ne peut pas jouer en a
          1 si couleur peut jouer en a en retournant dans une seule direction
          2 si couleur peut jouer en a en retournant dans plusieurs directions }
function PeutJouerIciUnidirectionnel(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var deltaFrontiere : SInt32) : SInt32;
var x,dx,t : SInt32;
    pionEnnemi : SInt32;
    UneDirectionJouable : boolean;
    frontiereRetourneeDansCetteDirection : SInt32;
begin
  pionEnnemi := -couleur;
  UneDirectionJouable := false;
  deltaFrontiere := 0;
  for t := dirPriseDeb[a] to dirPriseFin[a] do
    begin
      dx := dirPrise[t];
      x := a+dx;
      if plat[x] = pionEnnemi then
        begin
          frontiereRetourneeDansCetteDirection := frontiere.nbVide[x]-1;
          repeat
            x := x+dx;
            frontiereRetourneeDansCetteDirection := frontiereRetourneeDansCetteDirection+frontiere.nbVide[x];
          until plat[x] <> pionEnnemi;
          if (plat[x] = couleur) then
            begin
              deltaFrontiere := deltaFrontiere+frontiereRetourneeDansCetteDirection;
	            if UneDirectionJouable
	              then   {on vient de trouver une deuxieme direction de retournement => on renvoie 2 }
	                begin
	                  PeutJouerIciUnidirectionnel := 2;
	                  exit(PeutJouerIciUnidirectionnel);
	                end
	              else
	                UneDirectionJouable := true;  {pour l'instant, une seule dir. de retournement}
            end;
        end;
    end;
  if UneDirectionJouable
    then PeutJouerIciUnidirectionnel := 1
    else PeutJouerIciUnidirectionnel := 0;
end;

{renvoie  0 si couleur ne peut pas jouer en a
         -1 si couleur peut jouer en a en retournant dans plusieurs directions
          1 si couleur peut jouer en a en retournant dans une seule direction
          2 si couleur peut jouer en a en retournant dans une seule direction et peu de pions }
function ValeurUnidirectionnelleDuCoup(couleur,a : SInt32; var plat : plateauOthello) : SInt32;
var x,dx,t : SInt32;
    pionEnnemi,compteur,nbrePionsRetournes : SInt32;
    UneDirectionJouable : boolean;
begin
  pionEnnemi := -couleur;
  UneDirectionJouable := false;
  for t := dirPriseDeb[a] to dirPriseFin[a] do
    begin
      dx := dirPrise[t];
      x := a+dx;
      if plat[x] = pionEnnemi then
        begin
          compteur := 0;
          repeat
            x := x+dx;
            inc(compteur);
          until plat[x] <> pionEnnemi;
          if (plat[x] = couleur) then
            if UneDirectionJouable
              then   {on vient de trouver une seconde direction => on renvoie -1 }
                begin
                  ValeurUnidirectionnelleDuCoup := -1;
                  exit(ValeurUnidirectionnelleDuCoup);
                end
              else
                begin
                  UneDirectionJouable := true;  {pour l'instant, une seule dir. de retournement}
                  nbrePionsRetournes := compteur;
                end;
        end;
    end;
  if UneDirectionJouable
    then
      begin
        if nbrePionsRetournes <= 2
          then ValeurUnidirectionnelleDuCoup := 2
          else ValeurUnidirectionnelleDuCoup := 1;
      end
    else
      ValeurUnidirectionnelleDuCoup := 0;
end;


{renvoie le nombre de directions que couleur retourne en jouant en a}
function NbreDirectionsJouables(couleur,a : SInt32; var plat : plateauOthello) : SInt32;
var x,dx,t : SInt32;
    pionEnnemi,somme : SInt32;
begin
  pionEnnemi := -couleur;
  somme := 0;
  for t := dirPriseDeb[a] to dirPriseFin[a] do
    begin
      dx := dirPrise[t];
      x := a+dx;
      if plat[x] = pionEnnemi then
        begin
          repeat
            x := x+dx;
          until plat[x] <> pionEnnemi;
          if (plat[x] = couleur) then inc(somme);
        end;
    end;
  NbreDirectionsJouables := somme;
end;

{renvoie true
  1) si couleur peut jouer en a en retournant dans une seule direction
  2) ou si a est un coup tranquille}
function PeutJouerIciBonCoup(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var coupTranquille : boolean) : boolean;
var x,dx,t : SInt32;
    pionEnnemi,nbDirectionsRetournement : SInt32;
    directionTranquille : boolean;
begin
  pionEnnemi := -couleur;
  nbDirectionsRetournement := 0;
  coupTranquille := not(estUneCaseDeBord[a]);
  for t := dirPriseDeb[a] to dirPriseFin[a] do
    begin
      dx := dirPrise[t];
      x := a+dx;
      if plat[x] = pionEnnemi then
        begin
          directionTranquille := (frontiere.nbVide[x] = 1);
          repeat
            x := x+dx;
            if ((plat[x] = pionEnnemi) and (frontiere.nbVide[x] > 0)) then directionTranquille := false;
          until plat[x] <> pionEnnemi;
          if (plat[x] = couleur) then
            begin
              coupTranquille := coupTranquille and directionTranquille;
              inc(nbDirectionsRetournement);
              if (nbDirectionsRetournement > 1) and not(coupTranquille) then
                begin
                  PeutJouerIciBonCoup := false;
                  exit(PeutJouerIciBonCoup);
                end;
            end;
        end;
    end;

  {
  if coupTranquille and (nbDirectionsRetournement >= 1) then
    begin
      EssaieSetPortWindowPlateau;
      EcritPositionAt(plat,10,10);
      if couleur = pionNoir
        then WriteStringAt(CoupEnStringEnMajuscules(a)+' est tranquille pour X',130,20)
        else WriteStringAt(CoupEnStringEnMajuscules(a)+' est tranquille pour O',130,20);
      AttendFrappeClavier;
    end;
  }

  PeutJouerIciBonCoup := (nbDirectionsRetournement = 1) or
                       ((nbDirectionsRetournement > 1) and coupTranquille);
end;



{renvoie :
   0 si couleur ne peut pas jouer en a
  -1 si couleur peut jouer en a en retournant dans plusieurs directions non tranquilles
   1 si couleur peut jouer en a en retournant dans une seule direction
   2 si couleur peut jouer en a en retournant dans une seule direction, et que c'est un coup tranquille
   3 si a retourne dans plusieurs directions dont une seule non tranquille
   4 si a retourne dans plusieurs directions dont une seule non tranquille, et peu de pions dans cette direction
   5 si a retourne dans plusieurs directions toutes tranquilles
   6 si a est un coup presque tranquille (ie retourne un pion qui n'a qu'une case vide a cote apres le coup)

   on peut tester le reultat avec les constantes suivantes :
    kCoupMultiDirectionnelNonTranquille        = -1;
    kCoupIllegal                               = 0;
    kCoupUnidirectionnelNonTranquille          = 1;
    kCoupUnidirectionnelTranquille             = 2;
    kCoupPlusieursDir1NonTranquille            = 3;
    kCoupPlusieursDir1NonTranquilleMinimisante = 4;
    kCoupMultiDirectionnelTranquille           = 5;
    kCoupPresqueTranquille                     = 6;
}
function ValeurSemiTranquilleDuCoup(couleur,a : SInt32; var plat : plateauOthello; var frontiere : InfoFront; var coupTranquille : boolean; var deltaFrontiere : SInt32) : SInt32;
var x,dx,t,compteur : SInt32;
    pionEnnemi,nbDirectionsRetournement : SInt32;
    nbrePionsRetournes,nbrePionsRetournesDirectionNonTranquille : SInt32;
    nbDirectionsTranquilles,nbDirectionsNonTranquilles : SInt32;
    frontiereRetourneeDansCetteDirection : SInt32;
    directionTranquille : boolean;
begin
  ValeurSemiTranquilleDuCoup := kCoupIllegal; {jusqu'a preuve du contraire}
  pionEnnemi := -couleur;
  nbrePionsRetournes := 0;
  nbrePionsRetournesDirectionNonTranquille := 0;
  nbDirectionsRetournement := 0;
  nbDirectionsTranquilles := 0;
  nbDirectionsNonTranquilles := 0;
  coupTranquille := false;
  deltaFrontiere := 0;

  for t := dirPriseDeb[a] to dirPriseFin[a] do
    begin
      dx := dirPrise[t];
      x := a+dx;
      if plat[x] = pionEnnemi then
        begin
          directionTranquille := (frontiere.nbVide[x] = 1);
          FrontiereRetourneeDansCetteDirection := frontiere.nbVide[x]-1;
          compteur := 0;
          repeat
            x := x+dx;
            inc(compteur);
            if ((plat[x] = pionEnnemi) and (frontiere.nbVide[x] > 0)) then
              begin
                directionTranquille := false;
                frontiereRetourneeDansCetteDirection := frontiereRetourneeDansCetteDirection+frontiere.nbVide[x];
              end;
          until plat[x] <> pionEnnemi;
          if (plat[x] = couleur) then
            begin
              deltaFrontiere := deltaFrontiere+frontiereRetourneeDansCetteDirection;
              if directionTranquille
                then inc(nbDirectionsTranquilles)
                else
                  begin
                    inc(nbDirectionsNonTranquilles);
                    if (nbDirectionsNonTranquilles >= 2) then
                      begin
                        ValeurSemiTranquilleDuCoup := kCoupMultiDirectionnelNonTranquille;
                        exit(ValeurSemiTranquilleDuCoup);
                      end;
                    nbrePionsRetournesDirectionNonTranquille := compteur;
                  end;
              inc(nbDirectionsRetournement);
              nbrePionsRetournes := nbrePionsRetournes+compteur;
            end;
        end;
    end;

  {
  if effetspecial2 and (nbDirectionsRetournement = 1) and (nbDirectionsNonTranquilles >= 1)
   then
    begin
      EssaieSetPortWindowPlateau;
      EcritPositionAt(plat,10,10);
      if coupTranquille
        then
          if couleur = pionNoir
            then WriteStringAt(CoupEnStringEnMajuscules(a)+' est tranquille pour X',130,20)
            else WriteStringAt(CoupEnStringEnMajuscules(a)+' est tranquille pour O',130,20)
        else
          if couleur = pionNoir
            then WriteStringAt(CoupEnStringEnMajuscules(a)+' est semi-tranquille pour X',130,20)
            else WriteStringAt(CoupEnStringEnMajuscules(a)+' est semi-tranquille pour O',130,20);
      WriteNumAt('nb vides de '+CoupEnStringEnMajuscules(a)+' = ',frontiere.nbVide[a],130,30);
      AttendFrappeClavierOuSouris(effetspecial2);
      WriteStringAt('                                              ',130,20);
      WriteStringAt('                                              ',130,30);
      WriteStringAt('                                              ',130,40);
      WriteStringAt('                                              ',130,50);
    end;
  }

  if (nbDirectionsRetournement = 0) then
    begin
      ValeurSemiTranquilleDuCoup := kCoupIllegal;
      exit(ValeurSemiTranquilleDuCoup);
    end;
  coupTranquille := (nbDirectionsNonTranquilles = 0);
  if (nbDirectionsRetournement = 1) then
    begin
      if coupTranquille
        then ValeurSemiTranquilleDuCoup := kCoupUnidirectionnelTranquille
        else ValeurSemiTranquilleDuCoup := kCoupUnidirectionnelNonTranquille;
      exit(ValeurSemiTranquilleDuCoup);
    end;
  if (nbDirectionsNonTranquilles = 1) and (nbDirectionsTranquilles > 0) then
    begin
      if (nbrePionsRetournesDirectionNonTranquille > 1)
		    then ValeurSemiTranquilleDuCoup := kCoupPlusieursDir1NonTranquille
		    else ValeurSemiTranquilleDuCoup := kCoupPlusieursDir1NonTranquilleMinimisante;
      exit(ValeurSemiTranquilleDuCoup);
    end;
  if coupTranquille then {forcement nbDirectionsRetournement > 0}
    begin
      ValeurSemiTranquilleDuCoup := kCoupMultiDirectionnelTranquille;
      exit(ValeurSemiTranquilleDuCoup);
    end;
  ValeurSemiTranquilleDuCoup := kCoupIllegal;
end;

{renvoie le nbre de cases dans lesquels on ne retourne que dans une direction}
{dans tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
function mobiliteUnidirectionnelle(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
var x,t,somme,deltaFrontiere : SInt32;
begin
   somme := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       if (PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere) = 1) then inc(somme);
	   end;
   mobiliteUnidirectionnelle := somme;
end;

{renvoie le nbre de cases dans lesquels on ne retourne que dans une direction
 dans tout l'othellier sauf les coins et les cases X, et :
  - les cases C comptent pour un
  - les autres cases comptent pour deux}
function mobiliteUnidirectionnelleAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
var x,t,somme,deltaFrontiere : SInt32;
begin
   somme := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       if (PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere) = 1) then somme := somme+2;
	   end;
	 for t := 53 to 60 do  {les cases C}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       if (PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere) = 1) then inc(somme);
	   end;
   mobiliteUnidirectionnelleAvecCasesC := somme;
end;

{renvoie le nbre de cases dans lesquels on ne retourne que dans une direction
 dans tout l'othellier sauf les coins et les cases X, et :
  - les cases qui retournent dans deux directions ou plus comptent pour zero
  - les cases qui retournent dans une direction comptent pour deux
  - les cases qui retournent dans une direction et moins de deux pions comptent pour trois
  - les cases C comptent pour un }
function mobiliteUnidirectionnelleMinimisanteAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront) : SInt32;
var x,t,somme,v,deltaFrontiere : SInt32;
begin
   somme := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       begin
	         v := ValeurUnidirectionnelleDuCoup(coul,x,plat);
	         if v = 1 then somme := somme+2 else
	         if v = 2 then somme := somme+3;
	       end;
	   end;
	 for t := 53 to 60 do  {les cases C}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       if (PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere) = 1) then inc(somme);
	   end;
   mobiliteUnidirectionnelleMinimisanteAvecCasesC := somme;
end;

{renvoie le nbre de cases dans lesquels on ne retourne que dans une direction;
 les cases ou on ne retourne qu'un ou deux pions comptent pour 2}
function mobiliteUnidirectionnelleMinimisante(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
var x,t,somme,v : SInt32;
begin
   somme := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       begin
	         v := ValeurUnidirectionnelleDuCoup(coul,x,plat);
	         if v = 1 then somme := somme+2 else
	         if v = 2 then somme := somme+3;
	       end;
	   end;
   mobiliteUnidirectionnelleMinimisante := somme;
end;


{renvoie le nbre de cases dans lesquels on ne retourne que dans une direction ou qui sont
 des coups tranquilles}
function mobiliteBonsCoups(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront; var nbCoupsTranquilles : SInt32) : SInt32;
var x,t,somme : SInt32;
    coupTranquille : boolean;
begin
   somme := 0;
   nbCoupsTranquilles := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       if PeutJouerIciBonCoup(coul,x,plat,frontiere,coupTranquille) then
	         begin
	           inc(somme);
	           if coupTranquille then inc(nbCoupsTranquilles);
	         end;
	   end;
   mobiliteBonsCoups := somme;
end;

{renvoie le nbre de coups qui ne retournent que dans une seule direction,
 ou dans deux directions dont l'une est tranquille}
function MobiliteSemiTranquilleAvecCasesC(coul : SInt32; var plat : plateauOthello; var jouable : plBool; var frontiere : InfoFront; var ListeDesCoupsTranquilles : ListeDeCases; seuil_coupure : SInt32) : SInt32;
var x,t,somme,aux,v,deltaFrontiere : SInt32;
    premierIndex,dernierIndex : SInt32;
    coupTranquille : boolean;
    equivalentCaseC : SInt32;
label fin;
begin
   ListeDesCoupsTranquilles.cardinal := 0;
   somme := 0;


   premierIndex := 5;   {tout l'othellier, sauf les bords, les cases X et le carre E4-E5-D4-D5}
   dernierIndex := 32;

   for t := premierIndex to dernierIndex do
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       begin
	         v := ValeurSemiTranquilleDuCoup(coul,x,plat,frontiere,coupTranquille,deltaFrontiere);

	         somme := somme - BSr(deltaFrontiere,2);

	         case v of

	            {kCoupMultiDirectionnelNonTranquille :}     {deux directions non tranquilles}
	              {somme := somme+1;}

	            kCoupUnidirectionnelNonTranquille :         {une seule direction}
	              somme := somme+4;

	            kCoupUnidirectionnelTranquille :            {une seule direction, coup tranquille}
                begin
                  somme := somme+4;
                  aux := ListeDesCoupsTranquilles.cardinal + 1;
                  ListeDesCoupsTranquilles.cardinal := aux;
                  ListeDesCoupsTranquilles.liste[aux] := x;
                end;


	            kCoupPlusieursDir1NonTranquille :           {plusieurs directions, une seule non tranquille}
	              somme := somme+4;

	            kCoupPlusieursDir1NonTranquilleMinimisante :{plusieurs directions, une seule non tranquille, et un seul pion dans cette direction non tranquille}
	              somme := somme+4;

	            kCoupMultiDirectionnelTranquille :          {plusieurs directions, toutes tranquilles}
                begin
                  somme := somme+4;
                  aux := ListeDesCoupsTranquilles.cardinal + 1;
                  ListeDesCoupsTranquilles.cardinal := aux;
                  ListeDesCoupsTranquilles.liste[aux] := x;
                end;

	            kCoupPresqueTranquille :                    {coup presque tranquille}
	              somme := somme+4;

	         end; {case}

	         if somme >= seuil_coupure then goto fin;
	       end;
	   end;


	 (**** {les quatre cases au milieu de chaque bord, i.e. les cases A et B}  ****)

	 (*
	 for t := 33 to 48 do  {les quatre cases au milieu de chaque bord, i.e. les cases A et B}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       begin
	         v := PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere);
	         somme := somme - BSr(deltaFrontiere,2);
	         if (v = 1) then somme := somme+4;       {une seule direction}
	        {if (v = 2) then somme := somme+1;}      {deux directions}
	         if somme >= seuil_coupure then goto fin;
	       end;
	   end;
   *)

   if jouable[13] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,13,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[14] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,14,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[15] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,15,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[16] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,16,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[31] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,31,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[41] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,41,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[51] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,51,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[61] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,61,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[38] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,38,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[48] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,48,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[58] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,58,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[68] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,68,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[83] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,83,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[84] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,84,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[85] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,85,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[86] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,86,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme+4;       {une seule direction}
      {if (v = 2) then somme := somme+1;}      {deux directions}
       if somme >= seuil_coupure then goto fin;
     end;



	 (****   les cases C   ****)

	 (*
	 for t := 53 to 60 do  {les cases C}
	   begin
	     x := othellier[t];
	     if jouable[x] then
	       begin
	         v := PeutJouerIciUnidirectionnel(coul,x,plat,frontiere,deltaFrontiere);
	         somme := somme - BSr(deltaFrontiere,2);
	         if (v = 1) then somme := somme+2;      {une seule direction}
	         if somme >= seuil_coupure then goto fin;
	       end;
     end;
   *)

   equivalentCaseC := 2;

	 if jouable[12] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,12,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[17] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,17,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
	 if jouable[21] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,21,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[28] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,28,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
	 if jouable[71] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,71,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[78] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,78,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
	 if jouable[82] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,82,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;
   if jouable[87] then
     begin
       v := PeutJouerIciUnidirectionnel(coul,87,plat,frontiere,deltaFrontiere);
       somme := somme - BSr(deltaFrontiere,2);
       if (v = 1) then somme := somme + equivalentCaseC;      {une seule direction}
       if somme >= seuil_coupure then goto fin;
     end;

 fin :

   MobiliteSemiTranquilleAvecCasesC := somme;
end;


{renvoie le nb de cases ou les directions de retournements sont  >= 2}
function Influence(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
var x,t,somme,nbDirections : SInt32;
begin
   somme := 0;
   for t := 5 to 48 do  {tout l'othellier, sauf les carres Lesieur de coins et le carre E4-E5-D4-D5}
   begin
     x := othellier[t];
     if jouable[x] then
       begin
         nbDirections := NbreDirectionsJouables(coul,x,plat);
         if nbDirections >= 2 then inc(somme);
       end;
   end;
   Influence := somme;
end;



function NbCoinsPrenables(coul : SInt32; var plat : plateauOthello) : SInt32;
var c : SInt32;
begin
  c := 0;
  if plat[11] = pionVide then if PeutJouerIci(coul,11,plat) then inc(c);
  if plat[18] = pionVide then if PeutJouerIci(coul,18,plat) then inc(c);
  if plat[81] = pionVide then if PeutJouerIci(coul,81,plat) then inc(c);
  if plat[88] = pionVide then if PeutJouerIci(coul,88,plat) then inc(c);
  NbCoinsPrenables := c;    { nb de coins que l'on peut prendre }
end;

function PeutPrendreUnCoin(coul : SInt32; var plat : plateauOthello) : boolean;
begin
  if (plat[11] = pionVide) and PeutJouerIci(coul,11,plat) then begin PeutPrendreUnCoin := true; exit(PeutPrendreUnCoin); end;
  if (plat[18] = pionVide) and PeutJouerIci(coul,18,plat) then begin PeutPrendreUnCoin := true; exit(PeutPrendreUnCoin); end;
  if (plat[81] = pionVide) and PeutJouerIci(coul,81,plat) then begin PeutPrendreUnCoin := true; exit(PeutPrendreUnCoin); end;
  if (plat[88] = pionVide) and PeutJouerIci(coul,88,plat) then begin PeutPrendreUnCoin := true; exit(PeutPrendreUnCoin); end;
  PeutPrendreUnCoin := false;
end;

function NbCoins(coul : SInt32; var plat : plateauOthello) : SInt32;
var somme : SInt32;
begin
  somme := 0;
  if (plat[11] = coul) then inc(somme);
  if (plat[18] = coul) then inc(somme);
  if (plat[81] = coul) then inc(somme);
  if (plat[88] = coul) then inc(somme);
  NbCoins := somme;
end;


function NbLibertes(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
var x,t,compteur,nbpriseCoins,ennemi : SInt32;
    platAux : plateauOthello;
begin
   ennemi := -coul;
   nbpriseCoins := NbCoinsPrenables(ennemi,plat);
   compteur := 0;
   for t := 1 to 64 do
   begin
    x := othellier[t];
     if jouable[x] then
     begin
        platAux := plat;
        if ModifPlatSeulement(x,platAux,coul) then
          begin
            if NbCoinsPrenables(ennemi,plataux) = nbpriseCoins
              then inc(compteur);
          end;
     end;
   end;
  NbLibertes := compteur;
end;

function MobiliteEffective(coul : SInt32; var plat : plateauOthello; var jouable : plBool) : SInt32;
var x,i,k,compteur,effective : SInt32;
    platAux : plateauOthello;
    coups_x : array[1..30] of SInt32;
    legal : boolean;
begin
  compteur := 0;
  for k := 1 to 64 do
    begin
      x := othellier[k];
      if jouable[x] then
        if PeutJouerIci(coul,x,plat) then
           begin
             inc(compteur);
             coups_x[compteur] := x;
           end;
    end;
  if compteur > 0
    then
      begin
        effective := compteur;
        for k := 1 to compteur do
          begin
            platAux := plat;
            legal := ModifPlatSeulement(coups_x[k],platAux,coul);
            for i := 1 to compteur do
              if i <> k then
                if PeutJouerIci(coul,coups_x[i],platAux)
                  then inc(effective);
          end;
        MobiliteEffective := (valMobiliteUnidirectionnelle*effective) div compteur;
      end
    else
      begin
        MobiliteEffective := 0;
      end;
end;






{compte les prises de la pose d'un pion couleurPion en x,y
 si nbrePrise = 0 alors on ne peut pas jouer ds la case}
function ComptePrise(var a,couleur : SInt32; var plat : plateauOthello; var coupPossible : boolean) : SInt32;
var x,dx,t : SInt32;
    pionEnnemi,compteur,nbrePrise : SInt32;
begin
   nbrePrise := 0;
   pionEnnemi := -couleur;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       compteur := 0;
       x := a+dx;
       while (plat[x] = pionEnnemi) do
         begin
           inc(compteur);
           x := x+dx;
         end;
       if (plat[x] = couleur) and (compteur <> 0) then
          nbrePrise := nbrePrise+compteur;
     end;
 ComptePrise := nbrePrise;
 coupPossible := (nbrePrise <> 0);
end;

procedure CarteJouable(const plat : plateauOthello; var carte : plBool);
var i,x,t,d : SInt32;
begin
  MemoryFillChar(@carte,sizeof(carte),chr(0));
  for d := 1 to 64 do
   begin
    i := othellier[d];
    if plat[i] <> 0 then
      for t := dirJouableDeb[i] to dirJouableFin[i] do
        begin
          x := i+dirJouable[t];
          carte[x] := (plat[x] = 0);
        end;
   end;
end;

{ CarteVide etablit le nb de cases vides adjacent a chaque case
 et place le resultat dans carte}
procedure CarteVide(const plat : plateauOthello; var carte : plateauOthello);
var x,i,a,t,dx : SInt32;
begin
   MemoryFillChar(@carte,sizeof(carte),chr(0));
   for i := 1 to 64 do
   begin
     x := othellier[i];
     for t := dirPriseDeb[x] to dirPriseFin[x] do
     begin
        dx := dirPrise[t];
        a := x+2*dx;
        if not(interdit[a]) then
        if plat[a] = pionVide then carte[x+dx] := carte[x+dx]+1;
     end;
   end;

   (*
   for i := 1 to 64 do
     begin
       x := othellier[i];
       {if estUnCoin[x] then
         if carte[x] > 0 then carte[x] := 0;}
     end;
   *)
end;


function TrouverUneCaseRemplie(const plat : plateauOthello) : SInt32;
var square, t : SInt32;
begin
  for t := 64 downto 1 do
    begin
      square := othellier[t];
      if plat[square] <> pionVide then
        begin
          TrouverUneCaseRemplie := square;
          exit(TrouverUneCaseRemplie);
        end;
    end;
  TrouverUneCaseRemplie := 0;
end;



procedure CarteFrontiere(const plat : plateauOthello; var front : InfoFront);
var i,k,d,platDei,whichPattern : SInt32;
begin

  MemoryFillChar(@front,sizeof(front),chr(0));
  CarteVide(plat,front.nbVide);
  for d := 1 to 64 do
   begin
    i := othellier[d];
    platDei := plat[i];
    if platDei <> 0 then
     if front.nbVide[i] <> 0 then
      begin
        front.nbfront[platDei] := front.nbfront[platDei]+1;
        front.nbadjacent[platDei] := front.nbadjacent[platDei]+front.nbVide[i];
      end;
   end;

  with front do
  begin
    for i := 1 to kNbPatternsDansEval do AdressePattern[i] := 0;
    for d := 1 to 64 do
      begin
        i := othellier[d];
        platDei := plat[i];
        for k := 1 to nbPatternsImpliques[i] do
          begin
            whichPattern := nroPattern[i,k];
            AdressePattern[whichPattern] := AdressePattern[whichPattern]+platDei*deltaAdresse[i,k];
          end;
      end;
  end;

 front.occupationTactique := 0;

end;


function ModifScoreFin(a,coul : SInt32; var jeu : plateauOthello; var nbbl,nbno : SInt32) : boolean;
var x,dx,t,nbprise : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin
   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
         dx := dirPrise[t];
         compteur := 0;
         x := a+dx;
         while jeu[x] = pionEnnemi do
            begin
               inc(compteur);
               x := x+dx;
            end;
         if (jeu[x] = coul) and (compteur <> 0) then
         begin
            modifie := true;
            nbprise := nbprise+compteur;
         end;
      end;
   if modifie then
     begin
       if coul = pionNoir
         then begin
             nbNo := succ(nbNo+nbprise);
             nbbl := nbbl-nbprise;
           end
         else begin
             nbNo := nbNo-nbprise;
             nbbl := succ(nbbl+nbprise);
           end;
     end;
   ModifScoreFin := modifie;
end;

function CaseXSacrifiee(var plat : plateauOthello) : boolean;
begin
  if (plat[22] <> 0) and (plat[11] = 0) then
    begin
      CaseXSacrifiee := true;
      exit(CaseXSacrifiee);
    end;
  if (plat[27] <> 0) and (plat[18] = 0) then
    begin
      CaseXSacrifiee := true;
      exit(CaseXSacrifiee);
    end;
  if (plat[72] <> 0) and (plat[81] = 0) then
    begin
      CaseXSacrifiee := true;
      exit(CaseXSacrifiee);
    end;
  if (plat[77] <> 0) and (plat[88] = 0) then
    begin
      CaseXSacrifiee := true;
      exit(CaseXSacrifiee);
    end;
  CaseXSacrifiee := false;
end;

function PasDeBordDeCinqAttaque(couleur : SInt32; var front : InfoFront; const plat : plateauOthello) : boolean;
begin
  PasDeBordDeCinqAttaque := false;
  with front do
  if couleur = pionBlanc
    then
      begin
        if plat[22] = pionNoir then
          if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType1 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordNord]  = bordDeCinqBlancType1 then exit(PasDeBordDeCinqAttaque);
        if plat[27] = pionNoir then
          if AdressePattern[kAdresseBordNord]  = bordDeCinqBlancType2 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordEst]   = bordDeCinqBlancType1 then exit(PasDeBordDeCinqAttaque);
        if plat[77] = pionNoir then
          if AdressePattern[kAdresseBordEst]   = bordDeCinqBlancType2 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordSud]   = bordDeCinqBlancType2 then exit(PasDeBordDeCinqAttaque);
        if plat[72] = pionNoir then
          if AdressePattern[kAdresseBordSud]   = bordDeCinqBlancType1 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType2 then exit(PasDeBordDeCinqAttaque);
      end
    else
      begin
        if plat[22] = pionBlanc then
          if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType1 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordNord]  = bordDeCinqNoirType1 then exit(PasDeBordDeCinqAttaque);
        if plat[27] = pionBlanc then
          if AdressePattern[kAdresseBordNord]  = bordDeCinqNoirType2 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordEst]   = bordDeCinqNoirType1 then exit(PasDeBordDeCinqAttaque);
        if plat[77] = pionBlanc then
          if AdressePattern[kAdresseBordEst]   = bordDeCinqNoirType2 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordSud]   = bordDeCinqNoirType2 then exit(PasDeBordDeCinqAttaque);
        if plat[72] = pionBlanc then
          if AdressePattern[kAdresseBordSud]   = bordDeCinqNoirType1 then exit(PasDeBordDeCinqAttaque) else
          if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType2 then exit(PasDeBordDeCinqAttaque);
      end;
  PasDeBordDeCinqAttaque := true;
end;

function BordDeCinqUrgent(var plat : plateauOthello; var front : InfoFront) : boolean;
begin
  BordDeCinqUrgent := true;
  with front do
    begin
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType1 then begin
        if plat[32] = pionNoir then
        if plat[22] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType2 then begin
        if plat[62] = pionNoir then
        if plat[72] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType1 then begin
        if plat[32] = pionBlanc then
        if plat[22] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType2 then begin
        if plat[62] = pionBlanc then
        if plat[72] = pionVide then
        exit(BordDeCinqUrgent); end;


      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType1 then begin
        if plat[23] = pionNoir then
        if plat[22] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType2 then begin
        if plat[26] = pionNoir then
        if plat[27] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType1 then begin
        if plat[23] = pionBlanc then
        if plat[22] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType2 then begin
        if plat[26] = pionBlanc then
        if plat[27] = pionVide then
        exit(BordDeCinqUrgent); end ;

      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType1 then begin
        if plat[37] = pionNoir then
        if plat[27] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType2 then begin
        if plat[67] = pionNoir then
        if plat[77] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType1 then begin
        if plat[37] = pionBlanc then
        if plat[27] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType2 then begin
        if plat[67] = pionBlanc then
        if plat[77] = pionVide then
        exit(BordDeCinqUrgent); end ;

      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType1 then begin
        if plat[73] = pionNoir then
        if plat[72] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType2 then begin
        if plat[76] = pionNoir then
        if plat[77] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType1 then begin
        if plat[73] = pionBlanc then
        if plat[72] = pionVide then
        exit(BordDeCinqUrgent); end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType2 then begin
        if plat[76] = pionBlanc then
        if plat[77] = pionVide then
        exit(BordDeCinqUrgent); end ;
    end;

  BordDeCinqUrgent := false;
end;


function EstTurbulent(const pl : plateauOthello; couleur,nbBlancs,nbNoirs : SInt32; var front : InfoFront; var caseCritiqueTurbulence : SInt32) : boolean;
begin
  caseCritiqueTurbulence := 0;

  {
  if TRUE then
    begin
      EstTurbulent := false;
      exit(EstTurbulent);
    end;
  }

  if (nbBlancs <= 4) and (nbNoirs > 10) then   {grosse masse ?}
    begin
      EstTurbulent := true;
      exit(EstTurbulent);
    end;
  if (nbNoirs <= 4) and (nbBlancs > 10) then   {grosse masse ?}
    begin
      EstTurbulent := true;
      exit(EstTurbulent);
    end;
  with front do
    begin
      if table_Turbulence_mono^[AdressePattern[kAdresseBordNord]] <> 0 then
        begin
          EstTurbulent := true;
          caseCritiqueTurbulence := caseBordNord[table_Turbulence_mono^[AdressePattern[kAdresseBordNord]]];
          exit(EstTurbulent);
        end;
      if table_Turbulence_mono^[AdressePattern[kAdresseBordSud]] <> 0 then
        begin
          EstTurbulent := true;
          caseCritiqueTurbulence := caseBordSud[table_Turbulence_mono^[AdressePattern[kAdresseBordSud]]];
          exit(EstTurbulent);
        end;
      if table_Turbulence_mono^[AdressePattern[kAdresseBordOuest]] <> 0 then
        begin
          EstTurbulent := true;
          caseCritiqueTurbulence := caseBordOuest[table_Turbulence_mono^[AdressePattern[kAdresseBordOuest]]];
          exit(EstTurbulent);
        end;
      if table_Turbulence_mono^[AdressePattern[kAdresseBordEst]] <> 0 then
        begin
          EstTurbulent := true;
          caseCritiqueTurbulence := caseBordEst[table_Turbulence_mono^[AdressePattern[kAdresseBordEst]]];
          exit(EstTurbulent);
        end;

       if couleur = pionBlanc
         then
           begin
             if table_Turbulence_bi^[AdressePattern[kAdresseBordNord]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordNord[table_Turbulence_bi^[AdressePattern[kAdresseBordNord]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[AdressePattern[kAdresseBordSud]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordSud[table_Turbulence_bi^[AdressePattern[kAdresseBordSud]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[AdressePattern[kAdresseBordOuest]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordOuest[table_Turbulence_bi^[AdressePattern[kAdresseBordOuest]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[AdressePattern[kAdresseBordEst]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordEst[table_Turbulence_bi^[AdressePattern[kAdresseBordEst]]];
                 exit(EstTurbulent);
               end;
           end
         else
           begin
             if table_Turbulence_bi^[-AdressePattern[kAdresseBordNord]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordNord[table_Turbulence_bi^[-AdressePattern[kAdresseBordNord]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[-AdressePattern[kAdresseBordSud]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordSud[table_Turbulence_bi^[-AdressePattern[kAdresseBordSud]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[-AdressePattern[kAdresseBordOuest]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordOuest[table_Turbulence_bi^[-AdressePattern[kAdresseBordOuest]]];
                 exit(EstTurbulent);
               end;
             if table_Turbulence_bi^[-AdressePattern[kAdresseBordEst]] <> 0 then
               begin
                 EstTurbulent := true;
                 caseCritiqueTurbulence := caseBordEst[table_Turbulence_bi^[-AdressePattern[kAdresseBordEst]]];
                 exit(EstTurbulent);
               end;
           end;

     if pl[22] = pionNoir then
       begin
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreTroueBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreTroueBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeTroisBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 41;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeTroisBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 14;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeDeuxBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 51;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeDeuxBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 15;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeUnBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeUnBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
       end else
     if pl[22] = pionBlanc then
       begin
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreTroueNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreTroueNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeTroisNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 41;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeTroisNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 14;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeDeuxNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 51;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeDeuxNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 15;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeUnNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeUnNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
       end;
     if pl[27] = pionNoir then
       begin
         if AdressePattern[kAdresseBordEst] = bordDeQuatreBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = bordDeQuatreTroueBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreTroueBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeTroisBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 48;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeTroisBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 15;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeDeuxBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 58;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeDeuxBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 14;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeUnBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeUnBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
       end else
     if pl[27] = pionBlanc then
       begin
         if AdressePattern[kAdresseBordEst] = bordDeQuatreNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = bordDeQuatreTroueNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = bordDeQuatreTroueNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 16;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeTroisNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 48;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeTroisNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 15;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeDeuxNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 58;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeDeuxNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 14;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeUnNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordNord] = borddeUnNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 13;
              exit(EstTurbulent);
            end;
       end;
     if pl[72] = pionNoir then
       begin
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreTroueBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreTroueBlancType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeTroisBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 84;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeTroisBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 51;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeDeuxBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 85;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeDeuxBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 41;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeUnBlancStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeUnBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
       end else
     if pl[72] = pionBlanc then
       begin
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = bordDeQuatreTroueNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 61;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreTroueNoirType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeTroisNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 84;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeTroisNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 51;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeDeuxNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 85;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeDeuxNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 41;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeUnNoirStonerType1 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordOuest] = borddeUnNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 31;
              exit(EstTurbulent);
            end;
       end;
     if pl[77] = pionNoir then
       begin
         if AdressePattern[kAdresseBordEst] = bordDeQuatreBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = bordDeQuatreTroueBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreTroueBlancType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeTroisBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 58;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeTroisBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 85;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeDeuxBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 48;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeDeuxBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 84;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeUnBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeUnBlancStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionNoir then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
       end else
     if pl[77] = pionBlanc then
       begin
         if AdressePattern[kAdresseBordEst] = bordDeQuatreNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = bordDeQuatreTroueNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 68;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = bordDeQuatreTroueNoirType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 86;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeTroisNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 58;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeTroisNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 85;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeDeuxNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 48;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeDeuxNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 84;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordSud] = borddeUnNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 38;
              exit(EstTurbulent);
            end;
         if AdressePattern[kAdresseBordEst] = borddeUnNoirStonerType2 then
            begin
              EstTurbulent := true;
              if couleur = pionBlanc then caseCritiqueTurbulence := 83;
              exit(EstTurbulent);
            end;
       end;

    end;
  EstTurbulent := false;
end;

function VerificationConnexiteOK(jeu : plateauOthello) : boolean;
var i,j,t,x : SInt32;
    test,testLocal : boolean;
    relieCentre : plBool;
    EnCoreIsole,relieEncore : boolean;
    pionAutreQueCentre : boolean;
begin
  test := (jeu[44] <> pionVide) and (jeu[45] <> pionVide) and (jeu[54] <> pionVide) and (jeu[55] <> pionVide);
  pionAutreQueCentre := false;
  for i := 64 downto 1 do
    begin
      t := othellier[i];
      if (jeu[t] <> pionVide) then
        begin
          if (i <= 60) then pionAutreQueCentre := true;
          testlocal := false;
          for j := 1 to 8 do
            begin
              x := t+dir[j];
              if not(interdit[x]) then
                 testLocal := testlocal or (jeu[x] <> pionVide);
            end;
          test := test and testLocal;
        end;
    end;
  if test and pionAutreQueCentre then
    begin
      MemoryFillChar(@relieCentre,sizeof(relieCentre),chr(0));
      relieCentre[44] := true;
      relieCentre[45] := true;
      relieCentre[54] := true;
      relieCentre[55] := true;
      repeat
        RelieEncore := false;
        encoreIsole := false;
        for i := 64 downTo 1 do
          begin
            t := othellier[i];
            if (jeu[t] <> pionVide) then
             if not(relieCentre[t]) then
              begin
                testlocal := false;
                for j := 1 to 8 do
                  begin
                    x := t+dir[j];
                    if not(interdit[x]) then
                      if (jeu[x] <> pionVide) and relieCentre[x] then
                        begin
                          relieCentre[t] := true;
                          RelieEncore := true;
                          testlocal := true;
                        end;
                  end;
                if not(testLocal) then encoreIsole := true;
              end;
           end;
      until not(EncoreIsole) or not(RelieEncore);
      test := test and not(EncoreIsole)
    end;
  VerificationConnexiteOK := test;
end;

function VerificationNbreMinimalDePions(jeu : plateauOthello; nbreMinimalDePions : SInt32) : boolean;
var i,compteur : SInt32;
begin
  compteur := 0;
  for i := 1 to 64 do
    if (jeu[othellier[i]] <> pionVide) then inc(compteur);
  VerificationNbreMinimalDePions := (compteur >= nbreMinimalDePions);
end;

function PositionsEgales(var plat1,plat2 : plateauOthello) : boolean;
var i : SInt32;
begin
  for i := 11 to 88 do
    if plat1[i] <> plat2[i] then
      begin
        PositionsEgales := false;
        exit(PositionsEgales);
      end;
  PositionsEgales := true;
end;

procedure CalculePositionFinale(const ligne : String255; var plat : plateauOthello; var ligneLegale : boolean; var nbCoupsLegaux : SInt32);
var trait,i,coup : SInt32;
    jouables : plBool;
    ok : boolean;
begin
  OthellierDeDepart(plat);
  trait := pionNoir;
  nbCoupsLegaux := 0;
  ok := true;
  for i := 1 to LENGTH_OF_STRING(ligne) div 2 do
    begin
      coup := PositionDansStringAlphaEnCoup(ligne,2*i-1);
      if ok then
        if ModifPlatSeulement(coup,plat,trait)
          then trait := -trait
          else
            begin
              CarteJouable(plat,jouables);
              if DoitPasser(trait,plat,jouables)
                then ok := ModifPlatSeulement(coup,plat,-trait)
                else ok := false;
            end;
      if ok then nbCoupsLegaux := i;
    end;
  ligneLegale := ok;
end;

procedure CoupAuHazard(CouleurChoix : SInt32; jeu : plateauOthello; empl : plBool; var ChoixX,valeur : SInt32);
var a,iCourant,t,compteur : SInt32;
    coup : array[1..64] of SInt32;
    QueDesX : boolean;
    valeurAleatoire : SInt32;
begin
  QueDesX := true;
  compteur := 0;
  for t := 1 to 64 do
  begin
   iCourant := othellier[t];
    if  empl[iCourant] then
     if PeutJouerIci(CouleurChoix,iCourant,jeu) then
     begin
       QueDesX := QueDesX and ( EstUneCaseX(iCourant) or estUneCaseC[iCourant] );
       compteur := compteur+1;
       coup[compteur] := iCourant;
     end;
  end;
  repeat
    a := (Abs(Random) mod compteur)+1;
    ChoixX := coup[a];
  until not(EstUneCaseX(ChoixX) or estUneCaseC[ChoixX]) or QueDesX;
  valeurAleatoire := Random;
  if (valeurAleatoire >= 0)
    then valeur := valeurAleatoire mod 10000
    else valeur := -((-valeurAleatoire) mod 10000);
end;


function ModifPlat(a,coul : SInt32; var jeu : plateauOthello; var jouable : plBool; var nbbl,nbno : SInt32; var front : InfoFront) : boolean;
var x,dx,i,k,t,nbprise,nbvideDeX,jeuDeX,whichPattern : SInt32;
    pionEnnemi,compteur : SInt32;
    modifie : boolean;
begin

   {exeptionnellement, pour le debugage seulement !}
   {if (a < 11) then Debugger else
   if (a > 88) then Debugger else
   if (jeu[a] <> pionVide) then Debugger;}

   modifie := false; nbprise := 0;
   pionEnnemi := -coul;
   for t := dirPriseDeb[a] to dirPriseFin[a] do
     begin
       dx := dirPrise[t];
       x := a+dx;
       if jeu[x] = pionEnnemi then
         begin
           compteur := 0;
           repeat
             {exeptionnellement, pour le debugage seulement !}
             {if (TickCount - dernierTick) >= delaiAvantDoSystemTask then DoSystemTask(AQuiDeJouer);}
             inc(compteur);
             x := x+dx;
           until jeu[x] <> pionEnnemi;

           if (jeu[x] = coul) then
             begin
               modifie := true;
	             x := x-dx;
	             for i := 1 to compteur do
	               begin
	                 jeu[x] := coul;
	                 with front do
	                   begin

	                     for k := 1 to nbPatternsImpliques[x] do
							           begin
							             whichPattern := nroPattern[x,k];
							             AdressePattern[whichPattern] := AdressePattern[whichPattern]+coul*DoubleDeltaAdresse[x,k];
							           end;

	                     nbvideDeX := nbvide[x];
	                     if nbvideDeX > 0 then
	                       begin
	                         inc(nbfront[coul]);
	                         dec(nbfront[-coul]);
	                         nbadjacent[coul] := nbadjacent[coul]+nbvideDeX;
	                         nbadjacent[-coul] := nbadjacent[-coul]-nbvideDeX;
	                       end;

	                   end;
	                 x := x-dx;
	               end;
	             nbprise := nbprise+compteur;
             end;
         end;
     end;


   if modifie then
     begin
       inc(nbreNoeudsGeneresMilieu);

       jouable[a] := false;
       jeu[a] := coul;

       with front do
         begin

          for k := 1 to nbPatternsImpliques[a] do
	          begin
	            whichPattern := nroPattern[a,k];
	            AdressePattern[whichPattern] := AdressePattern[whichPattern]+coul*DeltaAdresse[a,k];
	          end;

          if nbvide[a] > 0 then inc(nbfront[coul]);
          nbadjacent[coul] := nbadjacent[coul]+nbvide[a];
          for t := dirPriseDeb[a] to dirPriseFin[a] do
            begin
               x := a+dirPrise[t];
               jeuDeX := jeu[x];
               nbvideDeX := nbVide[x];
               if nbvideDeX > 0 then
                  begin
                    if nbvideDeX = 1 then  {si on vient de prendre la derniere liberte d'une case}
                       dec(nbfront[jeuDeX]);
                    nbVide[x] := pred(nbvideDeX);
                  end;
               dec(nbadjacent[jeuDeX]);
             end;

           if coul = pionNoir {valeurtact etabli pour Noir}
             then begin
                 nbNo := nbNo+nbprise+1;
                 nbbl := nbbl-nbprise;
                 occupationtactique := occupationTactique+valeurTactNoir[a]
               end
             else begin
                 nbNo := nbNo-nbprise;
                 nbbl := nbbl+nbprise+1;
                 occupationtactique := occupationTactique-valeurTactBlanc[a];
               end;
         end;
       for t := dirJouableDeb[a] to dirJouableFin[a] do
         begin
           x := a+dirJouable[t];
           jouable[x] := (jeu[x] = 0);
         end;
     end;
   ModifPlat := modifie;
end;

function nbBordDeCinqTransformablesPourBlanc(const plat : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;

  with front do
    begin
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType1 then begin
        if plat[32] = pionNoir then if plat[22] = pionVide then
        if plat[23] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType2 then begin
        if plat[62] = pionNoir then if plat[72] = pionVide then
        if plat[73] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType1 then begin
        if plat[32] = pionBlanc then if plat[22] = pionVide then
        if plat[23] = pionVide then dec(aux) end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType2 then begin
        if plat[62] = pionBlanc then if plat[72] = pionVide then
        if plat[73] = pionVide then dec(aux) end;

      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType1 then begin
        if plat[23] = pionNoir then if plat[22] = pionVide then
        if plat[32] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType2 then begin
        if plat[26] = pionNoir then if plat[27] = pionVide then
        if plat[37] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType1 then begin
        if plat[23] = pionBlanc then if plat[22] = pionVide then
        if plat[32] = pionVide then dec(aux) end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType2 then begin
        if plat[26] = pionBlanc then if plat[27] = pionVide then
        if plat[37] = pionVide then dec(aux) end;

      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType1 then begin
        if plat[37] = pionNoir then if plat[27] = pionVide then
        if plat[26] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType2 then begin
        if plat[67] = pionNoir then if plat[77] = pionVide then
        if plat[76] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType1 then begin
        if plat[37] = pionBlanc then if plat[27] = pionVide then
        if plat[26] = pionVide then dec(aux) end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType2 then begin
        if plat[67] = pionBlanc then if plat[77] = pionVide then
        if plat[76] = pionVide then dec(aux) end;

      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType1 then begin
        if plat[73] = pionNoir then if plat[72] = pionVide then
        if plat[62] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType2 then begin
        if plat[76] = pionNoir then if plat[77] = pionVide then
        if plat[67] = pionVide then inc(aux) end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType1 then begin
        if plat[73] = pionBlanc then if plat[72] = pionVide then
        if plat[62] = pionVide then dec(aux) end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType2 then begin
        if plat[76] = pionBlanc then if plat[77] = pionVide then
        if plat[67] = pionVide then dec(aux) end;
    end;

  nbBordDeCinqTransformablesPourBlanc := aux;
end;


function BonsBordsDeCinqNoirs(var plat : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
    begin
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType1 then begin
        if plat[32] = pionBlanc then if plat[22] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType2 then begin
        if plat[62] = pionBlanc then if plat[72] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType1 then begin
        if plat[23] = pionBlanc then if plat[22] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType2 then begin
        if plat[26] = pionBlanc then if plat[27] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType1 then begin
        if plat[37] = pionBlanc then if plat[27] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType2 then begin
        if plat[67] = pionBlanc then if plat[77] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType1 then begin
        if plat[73] = pionBlanc then if plat[72] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType2 then begin
        if plat[76] = pionBlanc then if plat[77] = pionVide then aux := aux+valBonBordDeCinq end;
    end;
  BonsBordsDeCinqNoirs := aux;
end;

function BonsBordsDeCinqBlancs(var plat : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
    begin
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType1 then begin
        if plat[32] = pionNoir then if plat[22] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType2 then begin
        if plat[62] = pionNoir then if plat[72] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType1 then begin
        if plat[23] = pionNoir then if plat[22] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType2 then begin
        if plat[26] = pionNoir then if plat[27] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType1 then begin
        if plat[37] = pionNoir then if plat[27] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType2 then begin
        if plat[67] = pionNoir then if plat[77] = pionVide then aux := aux+valBonBordDeCinq end;
      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType1 then begin
        if plat[73] = pionNoir then if plat[72] = pionVide then aux := aux+valBonBordDeCinq end else
      if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType2 then begin
        if plat[76] = pionNoir then if plat[77] = pionVide then aux := aux+valBonBordDeCinq end;
    end;
  BonsBordsDeCinqBlancs := aux;
end;

function TrousDeTroisBlancsHorribles(const plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if plat[22] = pionBlanc then if plat[11] = pionVide then if plat[12] = pionVide then if plat[21] = pionVide then
  if plat[23] = pionBlanc then if plat[32] = pionBlanc then if plat[13] <> pionVide then if plat[31] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[27] = pionBlanc then if plat[18] = pionVide then if plat[17] = pionVide then if plat[28] = pionVide then
  if plat[26] = pionBlanc then if plat[37] = pionBlanc then if plat[16] <> pionVide then if plat[38] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[77] = pionBlanc then if plat[88] = pionVide then if plat[87] = pionVide then if plat[78] = pionVide then
  if plat[76] = pionBlanc then if plat[67] = pionBlanc then if plat[86] <> pionVide then if plat[68] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[72] = pionBlanc then if plat[81] = pionVide then if plat[71] = pionVide then if plat[82] = pionVide then
  if plat[62] = pionBlanc then if plat[73] = pionBlanc then if plat[61] <> pionVide then if plat[83] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  TrousDeTroisBlancsHorribles := aux;
end;

function TrousDeTroisNoirsHorribles(const plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if plat[22] = pionNoir then if plat[11] = pionVide then if plat[12] = pionVide then if plat[21] = pionVide then
  if plat[23] = pionNoir then if plat[32] = pionNoir then if plat[13] <> pionVide then if plat[31] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[27] = pionNoir then if plat[18] = pionVide then if plat[17] = pionVide then if plat[28] = pionVide then
  if plat[26] = pionNoir then if plat[37] = pionNoir then if plat[16] <> pionVide then if plat[38] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[77] = pionNoir then if plat[88] = pionVide then if plat[87] = pionVide then if plat[78] = pionVide then
  if plat[76] = pionNoir then if plat[67] = pionNoir then if plat[86] <> pionVide then if plat[68] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  if plat[72] = pionNoir then if plat[81] = pionVide then if plat[71] = pionVide then if plat[82] = pionVide then
  if plat[62] = pionNoir then if plat[73] = pionNoir then if plat[61] <> pionVide then if plat[83] <> pionVide then
    aux := aux+valTrouDeTroisHorrible;
  TrousDeTroisNoirsHorribles := aux;
end;


function TrousBlancsDeDeuxPerdantLaParite(var plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if (plat[12] = pionBlanc) and (plat[21] = pionBlanc) and (plat[11] = pionVide) and (plat[22] = pionVide) and (plat[23] = pionBlanc) and
     (plat[32] = pionBlanc) and (plat[33] = pionBlanc) and (plat[13] <> pionVide) and (plat[31] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[17] = pionBlanc) and (plat[28] = pionBlanc) and (plat[18] = pionVide) and (plat[27] = pionVide) and (plat[26] = pionBlanc) and
     (plat[37] = pionBlanc) and (plat[36] = pionBlanc) and (plat[16] <> pionVide) and (plat[38] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[82] = pionBlanc) and (plat[71] = pionBlanc) and (plat[81] = pionVide) and (plat[72] = pionVide) and (plat[73] = pionBlanc) and
     (plat[62] = pionBlanc) and (plat[63] = pionBlanc) and (plat[61] <> pionVide) and (plat[83] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[87] = pionBlanc) and (plat[78] = pionBlanc) and (plat[88] = pionVide) and (plat[77] = pionVide) and (plat[76] = pionBlanc) and
     (plat[67] = pionBlanc) and (plat[66] = pionBlanc) and (plat[68] <> pionVide) and (plat[86] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  TrousBlancsDeDeuxPerdantLaParite := aux;
end;


function TrousNoirsDeDeuxPerdantLaParite(var plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if (plat[12] =  pionNoir) and (plat[21] =  pionNoir) and (plat[11] =  pionVide) and (plat[22] =  pionVide) and (plat[23] = pionNoir) and
     (plat[32] =  pionNoir) and (plat[33] =  pionNoir) and (plat[13] <> pionVide) and (plat[31] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[17] =  pionNoir) and (plat[28] =  pionNoir) and (plat[18] =  pionVide) and (plat[27] =  pionVide) and (plat[26] = pionNoir) and
     (plat[37] =  pionNoir) and (plat[36] =  pionNoir) and (plat[16] <> pionVide) and (plat[38] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[82] =  pionNoir) and (plat[71] =  pionNoir) and (plat[81] =  pionVide) and (plat[72] =  pionVide) and (plat[73] = pionNoir) and
     (plat[62] =  pionNoir) and (plat[63] =  pionNoir) and (plat[61] <> pionVide) and (plat[83] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  if (plat[87] =  pionNoir) and (plat[78] =  pionNoir) and (plat[88] =  pionVide) and (plat[77] =  pionVide) and (plat[76] = pionNoir) and
     (plat[67] =  pionNoir) and (plat[66] =  pionNoir) and (plat[68] <> pionVide) and (plat[86] <> pionVide) then
       begin
         aux := aux+valTrouDeDeuxPerdantLaParite;
       end;
  TrousNoirsDeDeuxPerdantLaParite := aux;
end;


function LibertesNoiresSurCasesA(const plat : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
    begin
	  if (plat[13] = pionNoir) and (plat[23] = pionBlanc) and (plat[12] = pionVide) and (plat[22] = pionVide) and (plat[18] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordNord] <> bordBaghatNoir1)            and
	         (AdressePattern[kAdresseBordNord] <> bordBaghatisationParBlanc1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[31] = pionNoir) and (plat[32] = pionBlanc) and (plat[21] = pionVide) and (plat[22] = pionVide) and (plat[81] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordOuest] <> bordBaghatNoir1)            and
	         (AdressePattern[kAdresseBordOuest] <> bordBaghatisationParBlanc1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[16] = pionNoir) and (plat[26] = pionBlanc) and (plat[17] = pionVide) and (plat[27] = pionVide) and (plat[11] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordNord] <> bordBaghatNoir2)            and
	         (AdressePattern[kAdresseBordNord] <> bordBaghatisationParBlanc2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[38] = pionNoir) and (plat[37] = pionBlanc) and (plat[28] = pionVide) and (plat[27] = pionVide) and (plat[88] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordEst] <> bordBaghatNoir1)            and
	         (AdressePattern[kAdresseBordEst] <> bordBaghatisationParBlanc1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[61] = pionNoir) and (plat[62] = pionBlanc) and (plat[71] = pionVide) and (plat[72] = pionVide) and (plat[11] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordOuest] <> bordBaghatNoir2)            and
	         (AdressePattern[kAdresseBordOuest] <> bordBaghatisationParBlanc2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[83] = pionNoir) and (plat[73] = pionBlanc) and (plat[82] = pionVide) and (plat[72] = pionVide) and (plat[88] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordSud] <> bordBaghatNoir1)            and
	         (AdressePattern[kAdresseBordSud] <> bordBaghatisationParBlanc1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[68] = pionNoir) and (plat[67] = pionBlanc) and (plat[78] = pionVide) and (plat[77] = pionVide) and (plat[18] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordEst] <> bordBaghatNoir2)            and
	         (AdressePattern[kAdresseBordEst] <> bordBaghatisationParBlanc2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[86] = pionNoir) and (plat[76] = pionBlanc) and (plat[87] = pionVide) and (plat[77] = pionVide) and (plat[81] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc1) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc2) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParBlanc3)
	         {(AdressePattern[kAdresseBordSud] <> bordBaghatNoir2)            and
	         (AdressePattern[kAdresseBordSud] <> bordBaghatisationParBlanc2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;

	  (*
	  if (aux <> 0) and effetspecial2 { and
	    ((AdressePattern[kAdresseBordNord] = bordBaghatNoir1) or (AdressePattern[kAdresseBordNord] = bordBaghatNoir2) or (AdressePattern[kAdresseBordNord] = bordBaghatisationParBlanc1) or (AdressePattern[kAdresseBordNord] = bordBaghatisationParBlanc2)or
	     (AdressePattern[kAdresseBordOuest] = bordBaghatNoir1) or (AdressePattern[kAdresseBordOuest] = bordBaghatNoir2) or (AdressePattern[kAdresseBordOuest] = bordBaghatisationParBlanc1) or (AdressePattern[kAdresseBordOuest] = bordBaghatisationParBlanc2)or
	     (AdressePattern[kAdresseBordEst] = bordBaghatNoir1) or (AdressePattern[kAdresseBordEst] = bordBaghatNoir2) or (AdressePattern[kAdresseBordEst] = bordBaghatisationParBlanc1) or (AdressePattern[kAdresseBordEst] = bordBaghatisationParBlanc2)or
	     (AdressePattern[kAdresseBordSud] = bordBaghatNoir1) or (AdressePattern[kAdresseBordSud] = bordBaghatNoir2) or (AdressePattern[kAdresseBordSud] = bordBaghatisationParBlanc1) or (AdressePattern[kAdresseBordSud] = bordBaghatisationParBlanc2))
	    } then
	    begin
	      EssaieSetPortWindowPlateau;
	      EcritPositionAt(plat,10,10);
	      AttendFrappeClavierOuSouris(effetspecial2);
	    end;
	    *)
    end;

  LibertesNoiresSurCasesA := aux;
end;

function LibertesBlanchesSurCasesA(const plat : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
    begin
	  if (plat[13] = pionBlanc) and (plat[23] = pionNoir) and (plat[12] = pionVide) and (plat[22] = pionVide) and (plat[18] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordNord] <> bordBaghatBlanc1)          and
	         (AdressePattern[kAdresseBordNord] <> bordBaghatisationParNoir1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[31] = pionBlanc) and (plat[32] = pionNoir) and (plat[21] = pionVide) and (plat[22] = pionVide) and (plat[81] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordOuest] <> bordBaghatBlanc1)          and
	         (AdressePattern[kAdresseBordOuest] <> bordBaghatisationParNoir1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[16] = pionBlanc) and (plat[26] = pionNoir) and (plat[17] = pionVide) and (plat[27] = pionVide) and (plat[11] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordNord] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordNord] <> bordBaghatBlanc2)          and
	         (AdressePattern[kAdresseBordNord] <> bordBaghatisationParNoir2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[38] = pionBlanc) and (plat[37] = pionNoir) and (plat[28] = pionVide) and (plat[27] = pionVide) and (plat[88] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordEst] <> bordBaghatBlanc1)          and
	         (AdressePattern[kAdresseBordEst] <> bordBaghatisationParNoir1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[61] = pionBlanc) and (plat[62] = pionNoir) and (plat[71] = pionVide) and (plat[72] = pionVide) and (plat[11] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordOuest] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordOuest] <> bordBaghatBlanc2)          and
	         (AdressePattern[kAdresseBordOuest] <> bordBaghatisationParNoir2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[83] = pionBlanc) and (plat[73] = pionNoir) and (plat[82] = pionVide) and (plat[72] = pionVide) and (plat[88] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordSud] <> bordBaghatBlanc1)          and
	         (AdressePattern[kAdresseBordSud] <> bordBaghatisationParNoir1)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[68] = pionBlanc) and (plat[67] = pionNoir) and (plat[78] = pionVide) and (plat[77] = pionVide) and (plat[18] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordEst] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordEst] <> bordBaghatBlanc2)          and
	         (AdressePattern[kAdresseBordEst] <> bordBaghatisationParNoir2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  if (plat[86] = pionBlanc) and (plat[76] = pionNoir) and (plat[87] = pionVide) and (plat[77] = pionVide) and (plat[81] = pionVide) then
	    begin
	      if (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir1) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir2) and
	         (AdressePattern[kAdresseBordSud] <> bordMarconisationParNoir3)
	         {(AdressePattern[kAdresseBordSud] <> bordBaghatBlanc2)          and
	         (AdressePattern[kAdresseBordSud] <> bordBaghatisationParNoir2)}
	          then aux := aux+valLiberteSurCaseA
	          else aux := aux+valLiberteSurCaseAApresMarconisation;
	    end;
	  (*
	  if (aux <> 0) and effetspecial2 {and
	    ((AdressePattern[kAdresseBordNord] = bordBaghatBlanc1) or (AdressePattern[kAdresseBordNord] = bordBaghatBlanc2) or (AdressePattern[kAdresseBordNord] = bordBaghatisationParNoir1) or (AdressePattern[kAdresseBordNord] = bordBaghatisationParNoir2)or
	     (AdressePattern[kAdresseBordOuest] = bordBaghatBlanc1) or (AdressePattern[kAdresseBordOuest] = bordBaghatBlanc2) or (AdressePattern[kAdresseBordOuest] = bordBaghatisationParNoir1) or (AdressePattern[kAdresseBordOuest] = bordBaghatisationParNoir2)or
	     (AdressePattern[kAdresseBordEst] = bordBaghatBlanc1) or (AdressePattern[kAdresseBordEst] = bordBaghatBlanc2) or (AdressePattern[kAdresseBordEst] = bordBaghatisationParNoir1) or (AdressePattern[kAdresseBordEst] = bordBaghatisationParNoir2)or
	     (AdressePattern[kAdresseBordSud] = bordBaghatBlanc1) or (AdressePattern[kAdresseBordSud] = bordBaghatBlanc2) or (AdressePattern[kAdresseBordSud] = bordBaghatisationParNoir1) or (AdressePattern[kAdresseBordSud] = bordBaghatisationParNoir2))
	     }then
	    begin
	      EssaieSetPortWindowPlateau;
	      EcritPositionAt(plat,10,10);
	      AttendFrappeClavierOuSouris(effetspecial2);
	    end;
	    *)
    end;

  LibertesBlanchesSurCasesA := aux;
end;

function LibertesNoiresSurCasesB(var plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if (plat[14] = pionNoir) and (plat[24] = pionBlanc) and (plat[13] = pionVide) and (plat[23] = pionVide) and (plat[18] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[41] = pionNoir) and (plat[42] = pionBlanc) and (plat[31] = pionVide) and (plat[32] = pionVide) and (plat[81] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[15] = pionNoir) and (plat[25] = pionBlanc) and (plat[16] = pionVide) and (plat[26] = pionVide) and (plat[11] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[48] = pionNoir) and (plat[47] = pionBlanc) and (plat[38] = pionVide) and (plat[37] = pionVide) and (plat[88] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[51] = pionNoir) and (plat[52] = pionBlanc) and (plat[61] = pionVide) and (plat[62] = pionVide) and (plat[11] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[84] = pionNoir) and (plat[74] = pionBlanc) and (plat[83] = pionVide) and (plat[73] = pionVide) and (plat[88] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[58] = pionNoir) and (plat[57] = pionBlanc) and (plat[68] = pionVide) and (plat[67] = pionVide) and (plat[18] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[85] = pionNoir) and (plat[75] = pionBlanc) and (plat[86] = pionVide) and (plat[76] = pionVide) and (plat[81] = pionVide) then aux := aux+valLiberteSurCaseB;

  {
  if (aux <> 0) and effetspecial2 then
    begin
      EssaieSetPortWindowPlateau;
      EcritPositionAt(plat,10,10);
      AttendFrappeClavierOuSouris(effetspecial2);
    end;
  }

    LibertesNoiresSurCasesB := aux;
end;

function LibertesBlanchesSurCasesB(var plat : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if (plat[14] = pionBlanc) and (plat[24] = pionNoir) and (plat[13] = pionVide) and (plat[23] = pionVide) and (plat[18] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[41] = pionBlanc) and (plat[42] = pionNoir) and (plat[31] = pionVide) and (plat[32] = pionVide) and (plat[81] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[15] = pionBlanc) and (plat[25] = pionNoir) and (plat[16] = pionVide) and (plat[26] = pionVide) and (plat[11] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[48] = pionBlanc) and (plat[47] = pionNoir) and (plat[38] = pionVide) and (plat[37] = pionVide) and (plat[88] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[51] = pionBlanc) and (plat[52] = pionNoir) and (plat[61] = pionVide) and (plat[62] = pionVide) and (plat[11] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[84] = pionBlanc) and (plat[74] = pionNoir) and (plat[83] = pionVide) and (plat[73] = pionVide) and (plat[88] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[58] = pionBlanc) and (plat[57] = pionNoir) and (plat[68] = pionVide) and (plat[67] = pionVide) and (plat[18] = pionVide) then aux := aux+valLiberteSurCaseB;
  if (plat[85] = pionBlanc) and (plat[75] = pionNoir) and (plat[86] = pionVide) and (plat[76] = pionVide) and (plat[81] = pionVide) then aux := aux+valLiberteSurCaseB;

  {
  if (aux <> 0) and effetspecial2 then
    begin
      EssaieSetPortWindowPlateau;
      EcritPositionAt(plat,10,10);
      AttendFrappeClavierOuSouris(effetspecial2);
    end;
  }

    LibertesBlanchesSurCasesB := aux;
end;


function PasDeCoinEnPrise(var plat : plateauOthello; var jouable : plBool) : boolean;
begin
  if jouable[11] then
    begin
      if PeutJouerIci(pionNoir,11,plat)  then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
      if PeutJouerIci(pionBlanc,11,plat) then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
    end;
  if jouable[18] then
    begin
      if PeutJouerIci(pionNoir,18,plat)  then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
      if PeutJouerIci(pionBlanc,18,plat) then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
    end;
  if jouable[81] then
    begin
      if PeutJouerIci(pionNoir,81,plat)  then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
      if PeutJouerIci(pionBlanc,81,plat) then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
    end;
  if jouable[88] then
    begin
      if PeutJouerIci(pionNoir,88,plat)  then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
      if PeutJouerIci(pionBlanc,88,plat) then begin PasDeCoinEnPrise := false; exit(PasDeCoinEnPrise); end;
    end;
  PasDeCoinEnPrise := true;
end;


function ArnaqueSurBordDeCinqBlanc(const pl : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
   begin
     if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType1 then
      if (pl[32] = pionNoir) and (pl[22] = pionNoir) then
       case pl[23] of
         pionBlanc: if pl[24] = pionVide then if pl[25] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[24] <> pionBlanc then if pl[25] <> pionBlanc then if pl[26] <> pionBlanc then
                    if pl[27] <> pionBlanc then if pl[28] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[24] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[22] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordOuest] = bordDeCinqBlancType2 then
      if (pl[62] = pionNoir) and (pl[72] = pionNoir) then
       case pl[73] of
         pionBlanc: if pl[74] = pionVide then if pl[75] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[74] <> pionBlanc then if pl[75] <> pionBlanc then if pl[76] <> pionBlanc then
                    if pl[77] <> pionBlanc then if pl[78] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[74] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[72] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType1 then
      if (pl[37] = pionNoir) and (pl[27] = pionNoir) then
       case pl[26] of
         pionBlanc: if pl[25] = pionVide then if pl[24] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[25] <> pionBlanc then if pl[24] <> pionBlanc then if pl[23] <> pionBlanc then
                    if pl[22] <> pionBlanc then if pl[21] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[25] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[27] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordEst] = bordDeCinqBlancType2 then
      if (pl[67] = pionNoir) and (pl[77] = pionNoir) then
       case pl[76] of
         pionBlanc: if pl[75] = pionVide then if pl[74] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[75] <> pionBlanc then if pl[74] <> pionBlanc then if pl[73] <> pionBlanc then
                    if pl[72] <> pionBlanc then if pl[71] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[75] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[77] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType1 then
      if (pl[23] = pionNoir) and (pl[22] = pionNoir) then
       case pl[32] of
         pionBlanc: if pl[42] = pionVide then if pl[52] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[42] <> pionBlanc then if pl[52] <> pionBlanc then if pl[62] <> pionBlanc then
                    if pl[72] <> pionBlanc then if pl[82] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[42] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[22] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordNord] = bordDeCinqBlancType2 then
      if (pl[26] = pionNoir) and (pl[27] = pionNoir) then
       case pl[37] of
         pionBlanc: if pl[47] = pionVide then if pl[57] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[47] <> pionBlanc then if pl[57] <> pionBlanc then if pl[67] <> pionBlanc then
                    if pl[77] <> pionBlanc then if pl[87] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[47] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[27] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType1 then
      if (pl[73] = pionNoir) and (pl[72] = pionNoir) then
       case pl[62] of
         pionBlanc: if pl[52] = pionVide then if pl[42] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[52] <> pionBlanc then if pl[42] <> pionBlanc then if pl[32] <> pionBlanc then
                    if pl[22] <> pionBlanc then if pl[12] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[52] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[72] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordSud] = bordDeCinqBlancType2 then
      if (pl[76] = pionNoir) and (pl[77] = pionNoir) then
       case pl[67] of
         pionBlanc: if pl[57] = pionVide then if pl[47] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionNoir:  if pl[57] <> pionBlanc then if pl[47] <> pionBlanc then if pl[37] <> pionBlanc then
                    if pl[27] <> pionBlanc then if pl[17] <> pionBlanc then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
         pionVide:  if pl[57] = pionVide then begin ArnaqueSurBordDeCinqBlanc := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqBlanc); end;
       end else
      if (pl[77] = pionBlanc) then aux := aux-valCaseXDonnantBordDeCinq;
   end;
  ArnaqueSurBordDeCinqBlanc := aux;
end;


function ArnaqueSurBordDeCinqNoir(const pl : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
   begin
     if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType1 then
      if (pl[32] = pionBlanc) and (pl[22] = pionBlanc) then
       case pl[23] of
         pionNoir: if pl[24] = pionVide then if pl[25] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[24] <> pionNoir then if pl[25] <> pionNoir then if pl[26] <> pionNoir then
                    if pl[27] <> pionNoir then if pl[28] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[24] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[22] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordOuest] = bordDeCinqNoirType2 then
      if (pl[62] = pionBlanc) and (pl[72] = pionBlanc) then
       case pl[73] of
         pionNoir: if pl[74] = pionVide then if pl[75] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[74] <> pionNoir then if pl[75] <> pionNoir then if pl[76] <> pionNoir then
                    if pl[77] <> pionNoir then if pl[78] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[74] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[72] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType1 then
      if (pl[37] = pionBlanc) and (pl[27] = pionBlanc) then
       case pl[26] of
         pionNoir: if pl[25] = pionVide then if pl[24] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[25] <> pionNoir then if pl[24] <> pionNoir then if pl[23] <> pionNoir then
                    if pl[22] <> pionNoir then if pl[21] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[25] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[27] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordEst] = bordDeCinqNoirType2 then
      if (pl[67] = pionBlanc) and (pl[77] = pionBlanc) then
       case pl[76] of
         pionNoir: if pl[75] = pionVide then if pl[74] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[75] <> pionNoir then if pl[74] <> pionNoir then if pl[73] <> pionNoir then
                    if pl[72] <> pionNoir then if pl[71] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[75] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[77] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType1 then
      if (pl[23] = pionBlanc) and (pl[22] = pionBlanc) then
       case pl[32] of
         pionNoir: if pl[42] = pionVide then if pl[52] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[42] <> pionNoir then if pl[52] <> pionNoir then if pl[62] <> pionNoir then
                    if pl[72] <> pionNoir then if pl[82] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[42] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[22] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordNord] = bordDeCinqNoirType2 then
      if (pl[26] = pionBlanc) and (pl[27] = pionBlanc) then
       case pl[37] of
         pionNoir: if pl[47] = pionVide then if pl[57] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[47] <> pionNoir then if pl[57] <> pionNoir then if pl[67] <> pionNoir then
                    if pl[77] <> pionNoir then if pl[87] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[47] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[27] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType1 then
      if (pl[73] = pionBlanc) and (pl[72] = pionBlanc) then
       case pl[62] of
         pionNoir: if pl[52] = pionVide then if pl[42] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[52] <> pionNoir then if pl[42] <> pionNoir then if pl[32] <> pionNoir then
                    if pl[22] <> pionNoir then if pl[12] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[52] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[72] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
     if AdressePattern[kAdresseBordSud] = bordDeCinqNoirType2 then
      if (pl[76] = pionBlanc) and (pl[77] = pionBlanc) then
       case pl[67] of
         pionNoir: if pl[57] = pionVide then if pl[47] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionBlanc: if pl[57] <> pionNoir then if pl[47] <> pionNoir then if pl[37] <> pionNoir then
                    if pl[27] <> pionNoir then if pl[17] <> pionNoir then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
         pionVide:  if pl[57] = pionVide then begin ArnaqueSurBordDeCinqNoir := aux+valArnaqueSurBordDeCinq; exit(ArnaqueSurBordDeCinqNoir); end;
       end else
      if (pl[77] = pionNoir) then aux := aux-valCaseXDonnantBordDeCinq;
   end;
  ArnaqueSurBordDeCinqNoir := aux;
end;

function NotationBordsOpposesPourNoir(var pl : plateauOthello) : SInt32;
var nbNoirsSurBordSud,nbNoirsSurBordNord,nbNoirsSurBordEst,nbNoirsSurBordOuest : SInt32;
    nbBlancsSurBordSud,nbBlancsSurBordNord,nbBlancsSurBordEst,nbBlancsSurBordOuest : SInt32;
    aux : SInt32;
begin
  NotationBordsOpposesPourNoir := 0;
  if ((pl[11] = pionVide) and (pl[18] = pionVide) and (pl[81] = pionVide) and (pl[88] = pionVide)) then
    begin
      aux := 0;
      nbNoirsSurBordSud := 0;
      nbNoirsSurBordNord := 0;
      nbNoirsSurBordEst := 0;
      nbNoirsSurBordOuest := 0;
      nbBlancsSurBordSud := 0;
      nbBlancsSurBordNord := 0;
      nbBlancsSurBordEst := 0;
      nbBlancsSurBordOuest := 0;
      if pl[12] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[12] = pionBlanc then inc(nbBlancsSurBordNord);
      if pl[13] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[13] = pionBlanc then inc(nbBlancsSurBordNord);
      if pl[14] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[14] = pionBlanc then inc(nbBlancsSurBordNord);
      if pl[15] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[15] = pionBlanc then inc(nbBlancsSurBordNord);
      if pl[16] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[16] = pionBlanc then inc(nbBlancsSurBordNord);
      if pl[17] = pionNoir then inc(nbNoirsSurBordNord) else
      if pl[17] = pionBlanc then inc(nbBlancsSurBordNord);

      if pl[82] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[82] = pionBlanc then inc(nbBlancsSurBordSud);
      if pl[83] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[83] = pionBlanc then inc(nbBlancsSurBordSud);
      if pl[84] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[84] = pionBlanc then inc(nbBlancsSurBordSud);
      if pl[85] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[85] = pionBlanc then inc(nbBlancsSurBordSud);
      if pl[86] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[86] = pionBlanc then inc(nbBlancsSurBordSud);
      if pl[87] = pionNoir then inc(nbNoirsSurBordSud) else
      if pl[87] = pionBlanc then inc(nbBlancsSurBordSud);

      if pl[28] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[28] = pionBlanc then inc(nbBlancsSurBordEst);
      if pl[38] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[38] = pionBlanc then inc(nbBlancsSurBordEst);
      if pl[48] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[48] = pionBlanc then inc(nbBlancsSurBordEst);
      if pl[58] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[58] = pionBlanc then inc(nbBlancsSurBordEst);
      if pl[68] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[68] = pionBlanc then inc(nbBlancsSurBordEst);
      if pl[78] = pionNoir then inc(nbNoirsSurBordEst) else
      if pl[78] = pionBlanc then inc(nbBlancsSurBordEst);

      if pl[21] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[21] = pionBlanc then inc(nbBlancsSurBordOuest);
      if pl[31] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[31] = pionBlanc then inc(nbBlancsSurBordOuest);
      if pl[41] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[41] = pionBlanc then inc(nbBlancsSurBordOuest);
      if pl[51] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[51] = pionBlanc then inc(nbBlancsSurBordOuest);
      if pl[61] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[61] = pionBlanc then inc(nbBlancsSurBordOuest);
      if pl[71] = pionNoir then inc(nbNoirsSurBordOuest) else
      if pl[71] = pionBlanc then inc(nbBlancsSurBordOuest);

      if (nbNoirsSurBordNord > 0) and (nbNoirsSurBordSud > 0) then
        if nbNoirsSurBordNord < nbNoirsSurBordSud
          then aux := aux-valPairePionBordOpposes*nbNoirsSurBordNord
          else aux := aux-valPairePionBordOpposes*nbNoirsSurBordSud;
      if (nbBlancsSurBordNord > 0) and (nbBlancsSurBordSud > 0) then
        if nbBlancsSurBordNord < nbBlancsSurBordSud
          then aux := aux+valPairePionBordOpposes*nbBlancsSurBordNord
          else aux := aux+valPairePionBordOpposes*nbBlancsSurBordSud;

      if (nbNoirsSurBordOuest > 0) and (nbNoirsSurBordEst > 0) then
        if nbNoirsSurBordOuest < nbNoirsSurBordEst
          then aux := aux-valPairePionBordOpposes*nbNoirsSurBordOuest
          else aux := aux-valPairePionBordOpposes*nbNoirsSurBordEst;
      if (nbBlancsSurBordOuest > 0) and (nbBlancsSurBordEst > 0) then
        if nbBlancsSurBordOuest < nbBlancsSurBordEst
          then aux := aux+valPairePionBordOpposes*nbBlancsSurBordOuest
          else aux := aux+valPairePionBordOpposes*nbBlancsSurBordEst;

      NotationBordsOpposesPourNoir := aux;
    end;
end;

function BordDeSixNoirAvecPrebordHomogene(var pl : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
   begin
    if AdressePattern[kAdresseBordOuest] = bordDeSixNoir then
     if (pl[22] = pionNoir)  or (pl[72] = pionNoir)  then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[22] = pionBlanc) or (pl[72] = pionBlanc) then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[32] = pionNoir) and (pl[42] = pionNoir) and (pl[52] = pionNoir) and (pl[62] = pionNoir) then
       if (pl[22] = pionVide) and (pl[72] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordNord] = bordDeSixNoir then
     if (pl[22] = pionNoir)  or (pl[27] = pionNoir)  then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[22] = pionBlanc) or (pl[27] = pionBlanc) then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[23] = pionNoir) and (pl[24] = pionNoir) and (pl[25] = pionNoir) and (pl[26] = pionNoir) then
       if (pl[22] = pionVide) and (pl[27] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordEst] = bordDeSixNoir then
     if (pl[27] = pionNoir)  or (pl[77] = pionNoir)  then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[27] = pionBlanc) or (pl[77] = pionBlanc) then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[37] = pionNoir) and (pl[47] = pionNoir) and (pl[57] = pionNoir) and (pl[67] = pionNoir) then
       if (pl[27] = pionVide) and (pl[77] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordSud] = bordDeSixNoir then
     if (pl[72] = pionNoir)  or (pl[77] = pionNoir)  then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[72] = pionBlanc) or (pl[77] = pionBlanc) then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[73] = pionNoir) and (pl[74] = pionNoir) and (pl[75] = pionNoir) and (pl[76] = pionNoir) then
       if (pl[72] = pionVide) and (pl[77] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
   end;
   BordDeSixNoirAvecPrebordHomogene := aux;
end;

function BordDeSixBlancAvecPrebordHomogene(var pl : plateauOthello; var front : InfoFront) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  with front do
   begin
    if AdressePattern[kAdresseBordOuest] = bordDeSixBlanc then
     if (pl[22] = pionBlanc) or (pl[72] = pionBlanc) then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[22] = pionNoir)  or (pl[72] = pionNoir)  then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[32] = pionBlanc) and (pl[42] = pionBlanc) and (pl[52] = pionBlanc) and (pl[62] = pionBlanc) then
       if (pl[22] = pionVide) and (pl[72] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordNord] = bordDeSixBlanc then
     if (pl[22] = pionBlanc) or (pl[27] = pionBlanc) then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[22] = pionNoir)  or (pl[27] = pionNoir)  then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[23] = pionBlanc) and (pl[24] = pionBlanc) and (pl[25] = pionBlanc) and (pl[26] = pionBlanc) then
       if (pl[22] = pionVide) and (pl[27] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordEst] = bordDeSixBlanc then
     if (pl[27] = pionBlanc) or (pl[77] = pionBlanc) then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[27] = pionNoir)  or (pl[77] = pionNoir)  then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[37] = pionBlanc) and (pl[47] = pionBlanc) and (pl[57] = pionBlanc) and (pl[67] = pionBlanc) then
       if (pl[27] = pionVide) and (pl[77] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
    if AdressePattern[kAdresseBordSud] = bordDeSixBlanc then
     if (pl[72] = pionBlanc) or (pl[77] = pionBlanc) then aux := aux-valCaseXDonnantBordDeSix else
     if (pl[72] = pionNoir)  or (pl[77] = pionNoir)  then aux := aux+valCaseXConsolidantBordDeSix else
     if (pl[73] = pionBlanc) and (pl[74] = pionBlanc) and (pl[75] = pionBlanc) and (pl[76] = pionBlanc) then
       if (pl[72] = pionVide) and (pl[77] = pionVide) then aux := aux+valBordDeSixPlusQuatre;
   end;
   BordDeSixBlancAvecPrebordHomogene := aux;
end;

function PionsIsolesNoirsSurCasesThill(var pl : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if pl[33] = pionBlanc then
    begin
     if pl[23] = pionNoir then if pl[24] <> pionNoir then if pl[12] = pionVide then
     if pl[13] = pionVide then if pl[14] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
     if pl[32] = pionNoir then if pl[42] <> pionNoir then if pl[21] = pionVide then
     if pl[31] = pionVide then if pl[41] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[36] = pionBlanc then
    begin
      if pl[26] = pionNoir then if pl[25] <> pionNoir then if pl[15] = pionVide then
      if pl[16] = pionVide then if pl[17] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[37] = pionNoir then if pl[47] <> pionNoir then if pl[28] = pionVide then
      if pl[38] = pionVide then if pl[48] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[63] = pionBlanc then
    begin
      if pl[73] = pionNoir then if pl[74] <> pionNoir then if pl[82] = pionVide then
      if pl[83] = pionVide then if pl[84] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[62] = pionNoir then if pl[52] <> pionNoir then if pl[51] = pionVide then
      if pl[61] = pionVide then if pl[71] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[66] = pionBlanc then
    begin
      if pl[76] = pionNoir then if pl[75] <> pionNoir then if pl[85] = pionVide then
      if pl[86] = pionVide then if pl[87] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[67] = pionNoir then if pl[57] <> pionNoir then if pl[58] = pionVide then
      if pl[68] = pionVide then if pl[78] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  PionsIsolesNoirsSurCasesThill := aux;
end;

function PionsIsolesBlancsSurCasesThill(var pl : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if pl[33] = pionNoir then
    begin
     if pl[23] = pionBlanc then if pl[24] <> pionBlanc then if pl[12] = pionVide then
     if pl[13] = pionVide then if pl[14] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
     if pl[32] = pionBlanc then if pl[42] <> pionBlanc then if pl[21] = pionVide then
     if pl[31] = pionVide then if pl[41] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[36] = pionNoir then
    begin
      if pl[26] = pionBlanc then if pl[25] <> pionBlanc then if pl[15] = pionVide then
      if pl[16] = pionVide then if pl[17] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[37] = pionBlanc then if pl[47] <> pionBlanc then if pl[28] = pionVide then
      if pl[38] = pionVide then if pl[48] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[63] = pionNoir then
    begin
      if pl[73] = pionBlanc then if pl[74] <> pionBlanc then if pl[82] = pionVide then
      if pl[83] = pionVide then if pl[84] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[62] = pionBlanc then if pl[52] <> pionBlanc then if pl[51] = pionVide then
      if pl[61] = pionVide then if pl[71] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  if pl[66] = pionNoir then
    begin
      if pl[76] = pionBlanc then if pl[75] <> pionBlanc then if pl[85] = pionVide then
      if pl[86] = pionVide then if pl[87] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
      if pl[67] = pionBlanc then if pl[57] <> pionBlanc then if pl[58] = pionVide then
      if pl[68] = pionVide then if pl[78] = pionVide then aux := aux+valPionsIsoleSurCaseThill;
    end;
  PionsIsolesBlancsSurCasesThill := aux;
end;

function NoteCasesCoinsCarreCentralPourNoir(var pl : plateauOthello) : SInt32;
var aux : SInt32;
begin
  aux := 0;
  if (pl[22] = pionVide) and (pl[11] = pionVide) and (pl[23] <> pionVide) and (pl[32] <> pionVide) then
    begin
      if pl[33] = pionNoir  then aux := aux-valCasesCoinsCarreCentral else
      if pl[33] = pionBlanc then aux := aux+valCasesCoinsCarreCentral;
    end;
  if (pl[27] = pionVide) and (pl[18] = pionVide) and (pl[26] <> pionVide) and (pl[37] <> pionVide) then
    begin
      if pl[36] = pionNoir  then aux := aux-valCasesCoinsCarreCentral else
      if pl[36] = pionBlanc then aux := aux+valCasesCoinsCarreCentral;
    end;
  if (pl[72] = pionVide) and (pl[81] = pionVide) and (pl[73] <> pionVide) and (pl[62] <> pionVide) then
    begin
      if pl[63] = pionNoir  then aux := aux-valCasesCoinsCarreCentral else
      if pl[63] = pionBlanc then aux := aux+valCasesCoinsCarreCentral;
    end;
  if (pl[77] = pionVide) and (pl[88] = pionVide) and (pl[76] <> pionVide) and (pl[67] <> pionVide) then
    begin
      if pl[66] = pionNoir  then aux := aux-valCasesCoinsCarreCentral else
      if pl[66] = pionBlanc then aux := aux+valCasesCoinsCarreCentral;
    end;
  NoteCasesCoinsCarreCentralPourNoir := aux;
end;


function NoteJeuCasesXPourNoir(var pl : plateauOthello; nbNoirs,nbBlancs : SInt32) : SInt32;
var aux,eval,nbCoupsJoues : SInt32;
begin
  eval := 0;
  nbCoupsJoues := (nbNoirs+nbBlancs-4);

  if (pl[22] = pionBlanc) then
    case pl[11] of
      pionVide:
        begin
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
         if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[12] =  pionVide) and (pl[13] =  pionBlanc) and (pl[23] =  pionBlanc) then aux := aux+valTrouCaseC;
			          if (pl[21] =  pionVide) and (pl[31] =  pionBlanc) and (pl[32] =  pionBlanc) then aux := aux+valTrouCaseC;
			        end;
          if aux <> 0
            then eval := eval+aux
            else if pl[11] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[22] = pionNoir) then
    case pl[11] of
      pionVide:
        begin
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[12] =  pionVide) and (pl[13] =  pionNoir) and (pl[23] =  pionNoir) then aux := aux-valTrouCaseC;
                if (pl[21] =  pionVide) and (pl[31] =  pionNoir) and (pl[32] =  pionNoir) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[11] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[27] = pionBlanc)  then
    case pl[18] of
      pionVide:
        begin
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
       end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[17] =  pionVide) and (pl[16] =  pionBlanc) and (pl[26] =  pionBlanc) then aux := aux+valTrouCaseC;
                if (pl[28] =  pionVide) and (pl[38] =  pionBlanc) and (pl[37] =  pionBlanc) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[18] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[27] = pionNoir) then
    case pl[18] of
      pionVide:
        begin
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[17] =  pionVide) and (pl[16] =  pionNoir) and (pl[26] =  pionNoir) then aux := aux-valTrouCaseC;
                if (pl[28] =  pionVide) and (pl[38] =  pionNoir) and (pl[37] =  pionNoir) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[18] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[72] = pionBlanc)  then
    case pl[81] of
      pionVide:
        begin
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[71] =  pionVide) and (pl[61] =  pionBlanc) and (pl[62] =  pionBlanc) then aux := aux+valTrouCaseC;
                if (pl[82] =  pionVide) and (pl[83] =  pionBlanc) and (pl[73] =  pionBlanc) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[81] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[72] = pionNoir) then
    case pl[81] of
      pionVide:
        begin
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[71] =  pionVide) and (pl[61] =  pionNoir) and (pl[62] =  pionNoir) then aux := aux-valTrouCaseC;
                if (pl[82] =  pionVide) and (pl[83] =  pionNoir) and (pl[73] =  pionNoir) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[81] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[77] = pionBlanc) then
    case pl[88] of
      pionVide:
        begin
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[78] =  pionVide) and (pl[68] =  pionBlanc) and (pl[67] =  pionBlanc) then aux := aux+valTrouCaseC;
                if (pl[87] =  pionVide) and (pl[86] =  pionBlanc) and (pl[76] =  pionBlanc) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[88] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[77] = pionNoir) then
    case pl[88] of
      pionVide:
        begin
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionBlanc,pionNoir:
        begin
          aux := 0;
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
             then aux := valCaseXPlusCoin
             else
               begin
                 if (pl[78] =  pionVide) and (pl[68] =  pionNoir) and (pl[67] =  pionNoir) then aux := aux-valTrouCaseC;
                 if (pl[87] =  pionVide) and (pl[86] =  pionNoir) and (pl[76] =  pionNoir) then aux := aux-valTrouCaseC;
               end;
          if aux <> 0
            then eval := eval+aux
            else if pl[88] = pionNoir
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  NoteJeuCasesXPourNoir := eval;
end;


function NoteJeuCasesXPourBlanc(var pl : plateauOthello; nbNoirs,nbBlancs : SInt32) : SInt32;
var aux,eval,nbCoupsJoues : SInt32;
begin
  eval := 0;
  nbCoupsJoues := (nbNoirs+nbBlancs-4);

  if (pl[22] = pionNoir) then
    case pl[11] of
      pionVide:
        begin
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
         if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[12] =  pionVide) and (pl[13] =  pionNoir) and (pl[23] =  pionNoir) then aux := aux+valTrouCaseC;
			          if (pl[21] =  pionVide) and (pl[31] =  pionNoir) and (pl[32] =  pionNoir) then aux := aux+valTrouCaseC;
			        end;
          if aux <> 0
            then eval := eval+aux
            else if pl[11] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[22] = pionBlanc) then
    case pl[11] of
      pionVide:
        begin
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[12] <> pionVide) and (pl[21] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[12] =  pionVide) and (pl[13] =  pionBlanc) and (pl[23] =  pionBlanc) then aux := aux-valTrouCaseC;
                if (pl[21] =  pionVide) and (pl[31] =  pionBlanc) and (pl[32] =  pionBlanc) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[11] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[27] = pionNoir)  then
    case pl[18] of
      pionVide:
        begin
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
       end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[17] =  pionVide) and (pl[16] =  pionNoir) and (pl[26] =  pionNoir) then aux := aux+valTrouCaseC;
                if (pl[28] =  pionVide) and (pl[38] =  pionNoir) and (pl[37] =  pionNoir) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[18] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[27] = pionBlanc) then
    case pl[18] of
      pionVide:
        begin
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[17] <> pionVide) and (pl[28] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[17] =  pionVide) and (pl[16] =  pionBlanc) and (pl[26] =  pionBlanc) then aux := aux-valTrouCaseC;
                if (pl[28] =  pionVide) and (pl[38] =  pionBlanc) and (pl[37] =  pionBlanc) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[18] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[72] = pionNoir)  then
    case pl[81] of
      pionVide:
        begin
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[71] =  pionVide) and (pl[61] =  pionNoir) and (pl[62] =  pionNoir) then aux := aux+valTrouCaseC;
                if (pl[82] =  pionVide) and (pl[83] =  pionNoir) and (pl[73] =  pionNoir) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[81] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[72] = pionBlanc) then
    case pl[81] of
      pionVide:
        begin
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[71] <> pionVide) and (pl[82] <> pionVide)
            then aux := valCaseXPlusCoin
            else
              begin
                if (pl[71] =  pionVide) and (pl[61] =  pionBlanc) and (pl[62] =  pionBlanc) then aux := aux-valTrouCaseC;
                if (pl[82] =  pionVide) and (pl[83] =  pionBlanc) and (pl[73] =  pionBlanc) then aux := aux-valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[81] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  if (pl[77] = pionNoir) then
    case pl[88] of
      pionVide:
        begin
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then eval := eval+valCaseXEntreCasesC
            else eval := eval+valCaseX;
          if nbCoupsJoues < 30 then eval := eval+100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then aux := -valCaseXPlusCoin
            else
              begin
                if (pl[78] =  pionVide) and (pl[68] =  pionNoir) and (pl[67] =  pionNoir) then aux := aux+valTrouCaseC;
                if (pl[87] =  pionVide) and (pl[86] =  pionNoir) and (pl[76] =  pionNoir) then aux := aux+valTrouCaseC;
              end;
          if aux <> 0
            then eval := eval+aux
            else if pl[88] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end else
  if (pl[77] = pionBlanc) then
    case pl[88] of
      pionVide:
        begin
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
            then eval := eval-valCaseXEntreCasesC
            else eval := eval-valCaseX;
          if nbCoupsJoues < 30 then eval := eval-100*(30-nbCoupsJoues);
        end;
      pionNoir,pionBlanc:
        begin
          aux := 0;
          if (pl[78] <> pionVide) and (pl[87] <> pionVide)
             then aux := valCaseXPlusCoin
             else
               begin
                 if (pl[78] =  pionVide) and (pl[68] =  pionBlanc) and (pl[67] =  pionBlanc) then aux := aux-valTrouCaseC;
                 if (pl[87] =  pionVide) and (pl[86] =  pionBlanc) and (pl[76] =  pionBlanc) then aux := aux-valTrouCaseC;
               end;
          if aux <> 0
            then eval := eval+aux
            else if pl[88] = pionBlanc
                   then eval := eval+valCaseXPlusCoin
                   else eval := eval-valCaseXPlusCoin;
        end;
    end;
  NoteJeuCasesXPourBlanc := eval;
end;



function PasDeControleDeDiagonaleEnCours(couleur : SInt32; var pl : plateauOthello) : boolean;
begin
  if pl[11] = pionVide then if pl[22] = couleur then
    begin
      PasDeControleDeDiagonaleEnCours := false;
      exit(PasDeControleDeDiagonaleEnCours);
    end;
  if pl[18] = pionVide then if pl[27] = couleur then
    begin
      PasDeControleDeDiagonaleEnCours := false;
      exit(PasDeControleDeDiagonaleEnCours);
    end;
  if pl[81] = pionVide then if pl[72] = couleur then
    begin
      PasDeControleDeDiagonaleEnCours := false;
      exit(PasDeControleDeDiagonaleEnCours);
    end;
  if pl[88] = pionVide then if pl[77] = couleur then
    begin
      PasDeControleDeDiagonaleEnCours := false;
      exit(PasDeControleDeDiagonaleEnCours);
    end;
  PasDeControleDeDiagonaleEnCours := true;
end;

function NbPionsDefinitifsSurLesBords(couleur : SInt32; var plat : plateauOthello) : SInt32;
var i : SInt32;
    nbDefs : array[pionNoir..pionBlanc] of SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
begin
  nbDefs[pionNoir] := 0;
  nbDefs[pionBlanc] := 0;
  if plat[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if plat[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if plat[11+i] = pionVide then BordNordPlein := false;
            end;
        if plat[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if plat[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if plat[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if plat[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if plat[88-i] = pionVide then BordSudPlein := false;
            end;
        if plat[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if plat[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  if plat[11] = couleur then inc(nbDefs[couleur]);
  if plat[18] = couleur then inc(nbDefs[couleur]);
  if plat[81] = couleur then inc(nbDefs[couleur]);
  if plat[88] = couleur then inc(nbDefs[couleur]);

  if BordNordPlein
    then for i := 12 to 17 do inc(nbDefs[plat[i]])
    else
      begin
        if plat[11] = couleur then
          begin
            i := 12;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+1; end
          end;
        if plat[18] = couleur then
          begin
            i := 17;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-1; end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do inc(nbDefs[plat[11+10*i]])
    else
      begin
        if plat[11] = couleur then
          begin
            i := 21;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+10; end
          end;
        if plat[81] = couleur then
          begin
            i := 71;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-10; end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do inc(nbDefs[plat[18+10*i]])
    else
      begin
        if plat[18] = couleur then
          begin
            i := 28;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+10; end
          end;
        if plat[88] = couleur then
          begin
            i := 78;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-10; end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do inc(nbDefs[plat[i]])
    else
      begin
        if plat[81] = couleur then
          begin
            i := 82;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+1; end
          end;
        if plat[88] = couleur then
          begin
            i := 87;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-1; end
          end;
      end;

  NbPionsDefinitifsSurLesBords := nbDefs[couleur];
end;

function NbPionsDefinitifs(couleur : SInt32; var plat : plateauOthello) : SInt32;
var i,compt : SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
    definitif : plBool;
begin
  compt := 0;
  if plat[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if plat[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if plat[11+i] = pionVide then BordNordPlein := false;
            end;
        if plat[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if plat[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if plat[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if plat[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if plat[88-i] = pionVide then BordSudPlein := false;
            end;
        if plat[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if plat[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  MemoryFillChar(@definitif,sizeof(definitif),chr(0));

  if BordNordPlein
    then for i := 12 to 17 do
           begin
             if plat[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[11] = couleur then
          begin
            i := 12;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                inc(i);
              end;
          end;
        if plat[18] = couleur then
          begin
            i := 17;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do
           begin
             if plat[11+10*i] = couleur then
               begin
                 definitif[11+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[11] = couleur then
          begin
            i := 21;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end;
          end;
        if plat[81] = couleur then
          begin
            i := 71;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do
           begin
             if plat[18+10*i] = couleur then
               begin
                 definitif[18+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[18] = couleur then
          begin
            i := 28;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end
          end;
        if plat[88] = couleur then
          begin
            i := 78;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do
           begin
             if plat[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[81] = couleur then
          begin
            i := 82;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+1;
              end
          end;
        if plat[88] = couleur then
          begin
            i := 87;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;



  if plat[11] = couleur then
    begin
      definitif[11] := true;
      inc(compt);
      if definitif[12] then if definitif[21] then
        begin
          i := 22;
          while (plat[i] = couleur) and definitif[i-9] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
          i := 22;
          while (plat[i] = couleur) and definitif[i+9] do
            begin
              definitif[i] := true;
              i := i+10;
            end;
        end;
    end;

  if plat[18] = couleur then
    begin
      definitif[18] := true;
      inc(compt);
      if definitif[17] then if definitif[28] then
         begin
           i := 27;
           while (plat[i] = couleur) and definitif[i-11] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
           i := 27;
           while (plat[i] = couleur) and definitif[i+11] do
             begin
               definitif[i] := true;
               i := i+10;
             end;
         end;
    end;

  if plat[81] = couleur then
    begin
      definitif[81] := true;
      inc(compt);
      if definitif[71] then if definitif[82] then
        begin
          i := 72;
          while (plat[i] = couleur) and definitif[i-11] do
            begin
              definitif[i] := true;
              i := i-10;
            end;
          i := 72;
          while (plat[i] = couleur) and definitif[i+11] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
        end;
    end;

  if plat[88] = couleur then
    begin
      definitif[88] := true;
      inc(compt);
      if definitif[87] then if definitif[78] then
         begin
           i := 77;
           while (plat[i] = couleur) and definitif[i-9] do
             begin
               definitif[i] := true;
               i := i-10;
             end;
           i := 77;
           while (plat[i] = couleur) and definitif[i+9] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
         end;
    end;

  if definitif[22] then inc(compt);
  if definitif[23] then inc(compt);
  if definitif[24] then inc(compt);
  if definitif[25] then inc(compt);
  if definitif[26] then inc(compt);
  if definitif[27] then inc(compt);
  if definitif[72] then inc(compt);
  if definitif[73] then inc(compt);
  if definitif[74] then inc(compt);
  if definitif[75] then inc(compt);
  if definitif[76] then inc(compt);
  if definitif[77] then inc(compt);
  if definitif[32] then inc(compt);
  if definitif[42] then inc(compt);
  if definitif[52] then inc(compt);
  if definitif[62] then inc(compt);
  if definitif[37] then inc(compt);
  if definitif[47] then inc(compt);
  if definitif[57] then inc(compt);
  if definitif[67] then inc(compt);

  NbPionsDefinitifs := compt;
end;


function NbPionsDefinitifsAvecInterieurs(couleur : SInt32; var p : plateauOthello) : SInt32;
var i,compt : SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
    definitif,d2,d3,d4 : plBool;
begin
  compt := 0;
  if p[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if p[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if p[11+i] = pionVide then BordNordPlein := false;
            end;
        if p[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if p[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if p[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if p[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if p[88-i] = pionVide then BordSudPlein := false;
            end;
        if p[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if p[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  MemoryFillChar(@definitif,sizeof(definitif),chr(0));

  if BordNordPlein
    then for i := 12 to 17 do
           begin
             if p[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[11] = couleur then
          begin
            i := 12;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                inc(i);
              end;
          end;
        if p[18] = couleur then
          begin
            i := 17;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do
           begin
             if p[11+10*i] = couleur then
               begin
                 definitif[11+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[11] = couleur then
          begin
            i := 21;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end;
          end;
        if p[81] = couleur then
          begin
            i := 71;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do
           begin
             if p[18+10*i] = couleur then
               begin
                 definitif[18+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[18] = couleur then
          begin
            i := 28;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end
          end;
        if p[88] = couleur then
          begin
            i := 78;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do
           begin
             if p[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[81] = couleur then
          begin
            i := 82;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+1;
              end
          end;
        if p[88] = couleur then
          begin
            i := 87;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;



  if p[11] = couleur then
    begin
      definitif[11] := true;
      inc(compt);
      if definitif[12] then if definitif[21] then
        begin
          i := 22;
          while (p[i] = couleur) and definitif[i-9] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
          i := 22;
          while (p[i] = couleur) and definitif[i+9] do
            begin
              definitif[i] := true;
              i := i+10;
            end;
        end;
    end;

  if p[18] = couleur then
    begin
      definitif[18] := true;
      inc(compt);
      if definitif[17] then if definitif[28] then
         begin
           i := 27;
           while (p[i] = couleur) and definitif[i-11] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
           i := 27;
           while (p[i] = couleur) and definitif[i+11] do
             begin
               definitif[i] := true;
               i := i+10;
             end;
         end;
    end;

  if p[81] = couleur then
    begin
      definitif[81] := true;
      inc(compt);
      if definitif[71] then if definitif[82] then
        begin
          i := 72;
          while (p[i] = couleur) and definitif[i-11] do
            begin
              definitif[i] := true;
              i := i-10;
            end;
          i := 72;
          while (p[i] = couleur) and definitif[i+11] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
        end;
    end;

  if p[88] = couleur then
    begin
      definitif[88] := true;
      inc(compt);
      if definitif[87] then if definitif[78] then
         begin
           i := 77;
           while (p[i] = couleur) and definitif[i-9] do
             begin
               definitif[i] := true;
               i := i-10;
             end;
           i := 77;
           while (p[i] = couleur) and definitif[i+9] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
         end;
    end;

  if definitif[22] then inc(compt);
  if definitif[23] then inc(compt);
  if definitif[24] then inc(compt);
  if definitif[25] then inc(compt);
  if definitif[26] then inc(compt);
  if definitif[27] then inc(compt);
  if definitif[72] then inc(compt);
  if definitif[73] then inc(compt);
  if definitif[74] then inc(compt);
  if definitif[75] then inc(compt);
  if definitif[76] then inc(compt);
  if definitif[77] then inc(compt);
  if definitif[32] then inc(compt);
  if definitif[42] then inc(compt);
  if definitif[52] then inc(compt);
  if definitif[62] then inc(compt);
  if definitif[37] then inc(compt);
  if definitif[47] then inc(compt);
  if definitif[57] then inc(compt);
  if definitif[67] then inc(compt);


  MemoryFillChar(@d2,sizeof(d2),chr(0));
  MemoryFillChar(@d3,sizeof(d3),chr(0));
  MemoryFillChar(@d4,sizeof(d4),chr(0));


  if p[12] <> 0 then if p[82] <> 0 then if p[22] <> 0 then if p[72] <> 0 then
  if p[32] <> 0 then if p[62] <> 0 then if p[42] <> 0 then if p[52] <> 0 then
    begin d2[22] := true; d2[32] := true; d2[42] := true; d2[52] := true; d2[62] := true; d2[72] := true; end;
  if p[13] <> 0 then if p[83] <> 0 then if p[23] <> 0 then if p[73] <> 0 then
  if p[33] <> 0 then if p[63] <> 0 then if p[43] <> 0 then if p[53] <> 0 then
    begin d2[23] := true; d2[33] := true; d2[43] := true; d2[53] := true; d2[63] := true; d2[73] := true; end;
  if p[14] <> 0 then if p[84] <> 0 then if p[24] <> 0 then if p[74] <> 0 then
  if p[34] <> 0 then if p[64] <> 0 then if p[44] <> 0 then if p[54] <> 0 then
    begin d2[24] := true; d2[34] := true; d2[44] := true; d2[54] := true; d2[64] := true; d2[74] := true; end;
  if p[15] <> 0 then if p[85] <> 0 then if p[25] <> 0 then if p[75] <> 0 then
  if p[35] <> 0 then if p[65] <> 0 then if p[45] <> 0 then if p[55] <> 0 then
    begin d2[25] := true; d2[35] := true; d2[45] := true; d2[55] := true; d2[65] := true; d2[75] := true; end;
  if p[16] <> 0 then if p[86] <> 0 then if p[26] <> 0 then if p[76] <> 0 then
  if p[36] <> 0 then if p[66] <> 0 then if p[46] <> 0 then if p[56] <> 0 then
    begin d2[26] := true; d2[36] := true; d2[46] := true; d2[56] := true; d2[66] := true; d2[76] := true; end;
  if p[17] <> 0 then if p[87] <> 0 then if p[27] <> 0 then if p[77] <> 0 then
  if p[37] <> 0 then if p[67] <> 0 then if p[47] <> 0 then if p[57] <> 0 then
    begin d2[27] := true; d2[37] := true; d2[47] := true; d2[57] := true; d2[67] := true; d2[77] := true; end;


  if p[11] <> 0 then if p[88] <> 0 then if p[22] <> 0 then if p[77] <> 0 then
  if p[33] <> 0 then if p[66] <> 0 then if p[44] <> 0 then if p[55] <> 0 then
    begin d3[22] := true; d3[33] := true; d3[44] := true; d3[55] := true; d3[66] := true; d3[77] := true end;
  if p[12] <> 0 then if p[78] <> 0 then if p[23] <> 0 then if p[67] <> 0 then
  if p[34] <> 0 then if p[56] <> 0 then if p[45] <> 0 then
    begin d3[23] := true; d3[34] := true; d3[45] := true; d3[56] := true; d3[67] := true end;
  if p[13] <> 0 then if p[68] <> 0 then if p[24] <> 0 then if p[57] <> 0 then
  if p[35] <> 0 then if p[46] <> 0 then
    begin d3[24] := true; d3[35] := true; d3[46] := true; d3[57] := true end;
  if p[14] <> 0 then if p[58] <> 0 then if p[25] <> 0 then if p[47] <> 0 then
  if p[36] <> 0 then
    begin d3[25] := true; d3[36] := true; d3[47] := true end;
  if p[15] <> 0 then if p[48] <> 0 then if p[26] <> 0 then if p[37] <> 0 then
    begin d3[26] := true; d3[37] := true end;
  if p[16] <> 0 then if p[38] <> 0 then if p[27] <> 0 then
    begin d3[27] := true end;
  if p[21] <> 0 then if p[87] <> 0 then if p[32] <> 0 then if p[76] <> 0 then
  if p[43] <> 0 then if p[65] <> 0 then if p[54] <> 0 then
    begin d3[32] := true; d3[43] := true; d3[54] := true; d3[65] := true; d3[76] := true end;
  if p[31] <> 0 then if p[86] <> 0 then if p[42] <> 0 then if p[75] <> 0 then
  if p[53] <> 0 then if p[64] <> 0 then
    begin d3[42] := true; d3[53] := true; d3[64] := true; d3[75] := true end;
  if p[41] <> 0 then if p[85] <> 0 then if p[52] <> 0 then if p[74] <> 0 then
  if p[63] <> 0 then
    begin d3[52] := true; d3[63] := true; d3[74] := true end;
  if p[51] <> 0 then if p[84] <> 0 then if p[62] <> 0 then if p[73] <> 0 then
    begin d3[62] := true; d3[73] := true end;
  if p[61] <> 0 then if p[83] <> 0 then if p[72] <> 0 then
    begin d3[72] := true end;


  if p[13] <> 0 then if p[31] <> 0 then if p[22] <> 0 then
    begin d4[22] := true end;
  if p[14] <> 0 then if p[41] <> 0 then if p[23] <> 0 then if p[32] <> 0 then
    begin d4[23] := true; d4[32] := true end;
  if p[15] <> 0 then if p[51] <> 0 then if p[24] <> 0 then if p[42] <> 0 then
  if p[33] <> 0 then
    begin d4[24] := true; d4[33] := true; d4[42] := true end;
  if p[16] <> 0 then if p[61] <> 0 then if p[25] <> 0 then if p[52] <> 0 then
  if p[34] <> 0 then if p[43] <> 0 then
    begin d4[25] := true; d4[34] := true; d4[43] := true; d4[52] := true end;
  if p[17] <> 0 then if p[71] <> 0 then if p[26] <> 0 then if p[62] <> 0 then
  if p[35] <> 0 then if p[53] <> 0 then if p[44] <> 0 then
    begin d4[26] := true; d4[35] := true; d4[44] := true; d4[53] := true; d4[62] := true end;
  if p[18] <> 0 then if p[81] <> 0 then if p[27] <> 0 then if p[72] <> 0 then
  if p[36] <> 0 then if p[63] <> 0 then if p[45] <> 0 then if p[54] <> 0 then
    begin d4[27] := true; d4[36] := true; d4[45] := true; d4[54] := true; d4[63] := true; d4[72] := true end;
  if p[28] <> 0 then if p[82] <> 0 then if p[37] <> 0 then if p[73] <> 0 then
  if p[46] <> 0 then if p[64] <> 0 then if p[55] <> 0 then
    begin d4[37] := true; d4[46] := true; d4[55] := true; d4[64] := true; d4[73] := true end;
  if p[38] <> 0 then if p[83] <> 0 then if p[47] <> 0 then if p[74] <> 0 then
  if p[56] <> 0 then if p[65] <> 0 then
    begin d4[47] := true; d4[56] := true; d4[65] := true; d4[74] := true end;
  if p[48] <> 0 then if p[84] <> 0 then if p[57] <> 0 then if p[75] <> 0 then
  if p[66] <> 0 then
    begin d4[57] := true; d4[66] := true; d4[75] := true end;
  if p[58] <> 0 then if p[85] <> 0 then if p[67] <> 0 then if p[76] <> 0 then
    begin d4[67] := true; d4[76] := true end;
  if p[68] <> 0 then if p[86] <> 0 then if p[77] <> 0 then
    begin d4[77] := true end;

  if p[21] <> 0 then if p[28] <> 0 then if p[22] <> 0 then if p[27] <> 0 then
  if p[23] <> 0 then if p[26] <> 0 then if p[24] <> 0 then if p[25] <> 0 then
    for i := 22 to 27 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[31] <> 0 then if p[38] <> 0 then if p[32] <> 0 then if p[37] <> 0 then
  if p[33] <> 0 then if p[36] <> 0 then if p[34] <> 0 then if p[35] <> 0 then
    for i := 32 to 37 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[41] <> 0 then if p[48] <> 0 then if p[42] <> 0 then if p[47] <> 0 then
  if p[43] <> 0 then if p[46] <> 0 then if p[44] <> 0 then if p[45] <> 0 then
    for i := 42 to 47 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[51] <> 0 then if p[58] <> 0 then if p[52] <> 0 then if p[57] <> 0 then
  if p[53] <> 0 then if p[56] <> 0 then if p[54] <> 0 then if p[55] <> 0 then
    for i := 52 to 57 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[61] <> 0 then if p[68] <> 0 then if p[62] <> 0 then if p[67] <> 0 then
  if p[63] <> 0 then if p[66] <> 0 then if p[64] <> 0 then if p[65] <> 0 then
    for i := 62 to 67 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[71] <> 0 then if p[78] <> 0 then if p[72] <> 0 then if p[77] <> 0 then
  if p[73] <> 0 then if p[76] <> 0 then if p[74] <> 0 then if p[75] <> 0 then
    for i := 72 to 77 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);

  NbPionsDefinitifsAvecInterieurs := compt;
end;


function NbPionsDefinitifsSurLesBordsEndgame(couleur : SInt32; var plat : plOthEndgame) : SInt32;
var i : SInt32;
    nbDefs : array[pionNoir..pionBlanc] of SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
begin
  nbDefs[pionNoir] := 0;
  nbDefs[pionBlanc] := 0;
  if plat[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if plat[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if plat[11+i] = pionVide then BordNordPlein := false;
            end;
        if plat[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if plat[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if plat[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if plat[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if plat[88-i] = pionVide then BordSudPlein := false;
            end;
        if plat[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if plat[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  if plat[11] = couleur then inc(nbDefs[couleur]);
  if plat[18] = couleur then inc(nbDefs[couleur]);
  if plat[81] = couleur then inc(nbDefs[couleur]);
  if plat[88] = couleur then inc(nbDefs[couleur]);

  if BordNordPlein
    then for i := 12 to 17 do inc(nbDefs[plat[i]])
    else
      begin
        if plat[11] = couleur then
          begin
            i := 12;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+1; end
          end;
        if plat[18] = couleur then
          begin
            i := 17;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-1; end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do inc(nbDefs[plat[11+10*i]])
    else
      begin
        if plat[11] = couleur then
          begin
            i := 21;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+10; end
          end;
        if plat[81] = couleur then
          begin
            i := 71;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-10; end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do inc(nbDefs[plat[18+10*i]])
    else
      begin
        if plat[18] = couleur then
          begin
            i := 28;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+10; end
          end;
        if plat[88] = couleur then
          begin
            i := 78;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-10; end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do inc(nbDefs[plat[i]])
    else
      begin
        if plat[81] = couleur then
          begin
            i := 82;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i+1; end
          end;
        if plat[88] = couleur then
          begin
            i := 87;
            while plat[i] = couleur do begin inc(nbDefs[couleur]); i := i-1; end
          end;
      end;

  NbPionsDefinitifsSurLesBordsEndgame := nbDefs[couleur];
end;

function NbPionsDefinitifsEndgame(couleur : SInt32; var plat : plOthEndgame) : SInt32;
var i,compt : SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
    definitif : plBool;
begin
  compt := 0;
  if plat[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if plat[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if plat[11+i] = pionVide then BordNordPlein := false;
            end;
        if plat[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if plat[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if plat[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if plat[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if plat[88-i] = pionVide then BordSudPlein := false;
            end;
        if plat[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if plat[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  MemoryFillChar(@definitif,sizeof(definitif),chr(0));

  if BordNordPlein
    then for i := 12 to 17 do
           begin
             if plat[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[11] = couleur then
          begin
            i := 12;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                inc(i);
              end;
          end;
        if plat[18] = couleur then
          begin
            i := 17;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do
           begin
             if plat[11+10*i] = couleur then
               begin
                 definitif[11+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[11] = couleur then
          begin
            i := 21;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end;
          end;
        if plat[81] = couleur then
          begin
            i := 71;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do
           begin
             if plat[18+10*i] = couleur then
               begin
                 definitif[18+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[18] = couleur then
          begin
            i := 28;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end
          end;
        if plat[88] = couleur then
          begin
            i := 78;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do
           begin
             if plat[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if plat[81] = couleur then
          begin
            i := 82;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+1;
              end
          end;
        if plat[88] = couleur then
          begin
            i := 87;
            while plat[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;



  if plat[11] = couleur then
    begin
      definitif[11] := true;
      inc(compt);
      if definitif[12] then if definitif[21] then
        begin
          i := 22;
          while (plat[i] = couleur) and definitif[i-9] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
          i := 22;
          while (plat[i] = couleur) and definitif[i+9] do
            begin
              definitif[i] := true;
              i := i+10;
            end;
        end;
    end;

  if plat[18] = couleur then
    begin
      definitif[18] := true;
      inc(compt);
      if definitif[17] then if definitif[28] then
         begin
           i := 27;
           while (plat[i] = couleur) and definitif[i-11] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
           i := 27;
           while (plat[i] = couleur) and definitif[i+11] do
             begin
               definitif[i] := true;
               i := i+10;
             end;
         end;
    end;

  if plat[81] = couleur then
    begin
      definitif[81] := true;
      inc(compt);
      if definitif[71] then if definitif[82] then
        begin
          i := 72;
          while (plat[i] = couleur) and definitif[i-11] do
            begin
              definitif[i] := true;
              i := i-10;
            end;
          i := 72;
          while (plat[i] = couleur) and definitif[i+11] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
        end;
    end;

  if plat[88] = couleur then
    begin
      definitif[88] := true;
      inc(compt);
      if definitif[87] then if definitif[78] then
         begin
           i := 77;
           while (plat[i] = couleur) and definitif[i-9] do
             begin
               definitif[i] := true;
               i := i-10;
             end;
           i := 77;
           while (plat[i] = couleur) and definitif[i+9] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
         end;
    end;

  if definitif[22] then inc(compt);
  if definitif[23] then inc(compt);
  if definitif[24] then inc(compt);
  if definitif[25] then inc(compt);
  if definitif[26] then inc(compt);
  if definitif[27] then inc(compt);
  if definitif[72] then inc(compt);
  if definitif[73] then inc(compt);
  if definitif[74] then inc(compt);
  if definitif[75] then inc(compt);
  if definitif[76] then inc(compt);
  if definitif[77] then inc(compt);
  if definitif[32] then inc(compt);
  if definitif[42] then inc(compt);
  if definitif[52] then inc(compt);
  if definitif[62] then inc(compt);
  if definitif[37] then inc(compt);
  if definitif[47] then inc(compt);
  if definitif[57] then inc(compt);
  if definitif[67] then inc(compt);

  NbPionsDefinitifsEndgame := compt;
end;


function NbPionsDefinitifsAvecInterieursEndgame(couleur : SInt32; var p : plOthEndgame) : SInt32;
var i,compt : SInt32;
    BordNordPlein,BordEstPlein,BordSudPlein,BordOuestPlein : boolean;
    definitif,d2,d3,d4 : plBool;
begin
  compt := 0;
  if p[11] = pionVide
    then
      begin
        BordNordPlein := false;
        BordOuestPlein := false;
      end
    else
      begin
        if p[18] = pionVide
          then BordNordPlein := false
          else
            begin
              BordNordPlein := true;
              for i := 1 to 6 do if p[11+i] = pionVide then BordNordPlein := false;
            end;
        if p[81] = pionVide
          then BordOuestPlein := false
          else
            begin
              BordOuestPlein := true;
              for i := 1 to 6 do if p[11+10*i] = pionVide then BordOuestPlein := false;
            end;
      end;
  if p[88] = pionVide
    then
      begin
        BordSudPlein := false;
        BordEstPlein := false;
      end
    else
      begin
        if p[81] = pionVide
          then BordSudPlein := false
          else
            begin
              BordSudPlein := true;
              for i := 1 to 6 do if p[88-i] = pionVide then BordSudPlein := false;
            end;
        if p[18] = pionVide
          then BordEstPlein := false
          else
            begin
              BordEstPlein := true;
              for i := 1 to 6 do if p[88-10*i] = pionVide then BordEstPlein := false;
            end;
      end;

  MemoryFillChar(@definitif,sizeof(definitif),chr(0));

  if BordNordPlein
    then for i := 12 to 17 do
           begin
             if p[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[11] = couleur then
          begin
            i := 12;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                inc(i);
              end;
          end;
        if p[18] = couleur then
          begin
            i := 17;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;

  if BordOuestPlein
    then for i := 1 to 6 do
           begin
             if p[11+10*i] = couleur then
               begin
                 definitif[11+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[11] = couleur then
          begin
            i := 21;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end;
          end;
        if p[81] = couleur then
          begin
            i := 71;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordEstPlein
    then for i := 1 to 6 do
           begin
             if p[18+10*i] = couleur then
               begin
                 definitif[18+10*i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[18] = couleur then
          begin
            i := 28;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+10;
              end
          end;
        if p[88] = couleur then
          begin
            i := 78;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-10;
              end
          end;
      end;

  if BordSudPlein
    then for i := 82 to 87 do
           begin
             if p[i] = couleur then
               begin
                 definitif[i] := true;
                 inc(compt);
               end;
           end
    else
      begin
        if p[81] = couleur then
          begin
            i := 82;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i+1;
              end
          end;
        if p[88] = couleur then
          begin
            i := 87;
            while p[i] = couleur do
              begin
                definitif[i] := true;
                inc(compt);
                i := i-1;
              end
          end;
      end;



  if p[11] = couleur then
    begin
      definitif[11] := true;
      inc(compt);
      if definitif[12] then if definitif[21] then
        begin
          i := 22;
          while (p[i] = couleur) and definitif[i-9] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
          i := 22;
          while (p[i] = couleur) and definitif[i+9] do
            begin
              definitif[i] := true;
              i := i+10;
            end;
        end;
    end;

  if p[18] = couleur then
    begin
      definitif[18] := true;
      inc(compt);
      if definitif[17] then if definitif[28] then
         begin
           i := 27;
           while (p[i] = couleur) and definitif[i-11] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
           i := 27;
           while (p[i] = couleur) and definitif[i+11] do
             begin
               definitif[i] := true;
               i := i+10;
             end;
         end;
    end;

  if p[81] = couleur then
    begin
      definitif[81] := true;
      inc(compt);
      if definitif[71] then if definitif[82] then
        begin
          i := 72;
          while (p[i] = couleur) and definitif[i-11] do
            begin
              definitif[i] := true;
              i := i-10;
            end;
          i := 72;
          while (p[i] = couleur) and definitif[i+11] do
            begin
              definitif[i] := true;
              i := i+1;
            end;
        end;
    end;

  if p[88] = couleur then
    begin
      definitif[88] := true;
      inc(compt);
      if definitif[87] then if definitif[78] then
         begin
           i := 77;
           while (p[i] = couleur) and definitif[i-9] do
             begin
               definitif[i] := true;
               i := i-10;
             end;
           i := 77;
           while (p[i] = couleur) and definitif[i+9] do
             begin
               definitif[i] := true;
               i := i-1;
             end;
         end;
    end;

  if definitif[22] then inc(compt);
  if definitif[23] then inc(compt);
  if definitif[24] then inc(compt);
  if definitif[25] then inc(compt);
  if definitif[26] then inc(compt);
  if definitif[27] then inc(compt);
  if definitif[72] then inc(compt);
  if definitif[73] then inc(compt);
  if definitif[74] then inc(compt);
  if definitif[75] then inc(compt);
  if definitif[76] then inc(compt);
  if definitif[77] then inc(compt);
  if definitif[32] then inc(compt);
  if definitif[42] then inc(compt);
  if definitif[52] then inc(compt);
  if definitif[62] then inc(compt);
  if definitif[37] then inc(compt);
  if definitif[47] then inc(compt);
  if definitif[57] then inc(compt);
  if definitif[67] then inc(compt);


  MemoryFillChar(@d2,sizeof(d2),chr(0));
  MemoryFillChar(@d3,sizeof(d3),chr(0));
  MemoryFillChar(@d4,sizeof(d4),chr(0));


  if p[12] <> 0 then if p[82] <> 0 then if p[22] <> 0 then if p[72] <> 0 then
  if p[32] <> 0 then if p[62] <> 0 then if p[42] <> 0 then if p[52] <> 0 then
    begin d2[22] := true; d2[32] := true; d2[42] := true; d2[52] := true; d2[62] := true; d2[72] := true; end;
  if p[13] <> 0 then if p[83] <> 0 then if p[23] <> 0 then if p[73] <> 0 then
  if p[33] <> 0 then if p[63] <> 0 then if p[43] <> 0 then if p[53] <> 0 then
    begin d2[23] := true; d2[33] := true; d2[43] := true; d2[53] := true; d2[63] := true; d2[73] := true; end;
  if p[14] <> 0 then if p[84] <> 0 then if p[24] <> 0 then if p[74] <> 0 then
  if p[34] <> 0 then if p[64] <> 0 then if p[44] <> 0 then if p[54] <> 0 then
    begin d2[24] := true; d2[34] := true; d2[44] := true; d2[54] := true; d2[64] := true; d2[74] := true; end;
  if p[15] <> 0 then if p[85] <> 0 then if p[25] <> 0 then if p[75] <> 0 then
  if p[35] <> 0 then if p[65] <> 0 then if p[45] <> 0 then if p[55] <> 0 then
    begin d2[25] := true; d2[35] := true; d2[45] := true; d2[55] := true; d2[65] := true; d2[75] := true; end;
  if p[16] <> 0 then if p[86] <> 0 then if p[26] <> 0 then if p[76] <> 0 then
  if p[36] <> 0 then if p[66] <> 0 then if p[46] <> 0 then if p[56] <> 0 then
    begin d2[26] := true; d2[36] := true; d2[46] := true; d2[56] := true; d2[66] := true; d2[76] := true; end;
  if p[17] <> 0 then if p[87] <> 0 then if p[27] <> 0 then if p[77] <> 0 then
  if p[37] <> 0 then if p[67] <> 0 then if p[47] <> 0 then if p[57] <> 0 then
    begin d2[27] := true; d2[37] := true; d2[47] := true; d2[57] := true; d2[67] := true; d2[77] := true; end;


  if p[11] <> 0 then if p[88] <> 0 then if p[22] <> 0 then if p[77] <> 0 then
  if p[33] <> 0 then if p[66] <> 0 then if p[44] <> 0 then if p[55] <> 0 then
    begin d3[22] := true; d3[33] := true; d3[44] := true; d3[55] := true; d3[66] := true; d3[77] := true end;
  if p[12] <> 0 then if p[78] <> 0 then if p[23] <> 0 then if p[67] <> 0 then
  if p[34] <> 0 then if p[56] <> 0 then if p[45] <> 0 then
    begin d3[23] := true; d3[34] := true; d3[45] := true; d3[56] := true; d3[67] := true end;
  if p[13] <> 0 then if p[68] <> 0 then if p[24] <> 0 then if p[57] <> 0 then
  if p[35] <> 0 then if p[46] <> 0 then
    begin d3[24] := true; d3[35] := true; d3[46] := true; d3[57] := true end;
  if p[14] <> 0 then if p[58] <> 0 then if p[25] <> 0 then if p[47] <> 0 then
  if p[36] <> 0 then
    begin d3[25] := true; d3[36] := true; d3[47] := true end;
  if p[15] <> 0 then if p[48] <> 0 then if p[26] <> 0 then if p[37] <> 0 then
    begin d3[26] := true; d3[37] := true end;
  if p[16] <> 0 then if p[38] <> 0 then if p[27] <> 0 then
    begin d3[27] := true end;
  if p[21] <> 0 then if p[87] <> 0 then if p[32] <> 0 then if p[76] <> 0 then
  if p[43] <> 0 then if p[65] <> 0 then if p[54] <> 0 then
    begin d3[32] := true; d3[43] := true; d3[54] := true; d3[65] := true; d3[76] := true end;
  if p[31] <> 0 then if p[86] <> 0 then if p[42] <> 0 then if p[75] <> 0 then
  if p[53] <> 0 then if p[64] <> 0 then
    begin d3[42] := true; d3[53] := true; d3[64] := true; d3[75] := true end;
  if p[41] <> 0 then if p[85] <> 0 then if p[52] <> 0 then if p[74] <> 0 then
  if p[63] <> 0 then
    begin d3[52] := true; d3[63] := true; d3[74] := true end;
  if p[51] <> 0 then if p[84] <> 0 then if p[62] <> 0 then if p[73] <> 0 then
    begin d3[62] := true; d3[73] := true end;
  if p[61] <> 0 then if p[83] <> 0 then if p[72] <> 0 then
    begin d3[72] := true end;


  if p[13] <> 0 then if p[31] <> 0 then if p[22] <> 0 then
    begin d4[22] := true end;
  if p[14] <> 0 then if p[41] <> 0 then if p[23] <> 0 then if p[32] <> 0 then
    begin d4[23] := true; d4[32] := true end;
  if p[15] <> 0 then if p[51] <> 0 then if p[24] <> 0 then if p[42] <> 0 then
  if p[33] <> 0 then
    begin d4[24] := true; d4[33] := true; d4[42] := true end;
  if p[16] <> 0 then if p[61] <> 0 then if p[25] <> 0 then if p[52] <> 0 then
  if p[34] <> 0 then if p[43] <> 0 then
    begin d4[25] := true; d4[34] := true; d4[43] := true; d4[52] := true end;
  if p[17] <> 0 then if p[71] <> 0 then if p[26] <> 0 then if p[62] <> 0 then
  if p[35] <> 0 then if p[53] <> 0 then if p[44] <> 0 then
    begin d4[26] := true; d4[35] := true; d4[44] := true; d4[53] := true; d4[62] := true end;
  if p[18] <> 0 then if p[81] <> 0 then if p[27] <> 0 then if p[72] <> 0 then
  if p[36] <> 0 then if p[63] <> 0 then if p[45] <> 0 then if p[54] <> 0 then
    begin d4[27] := true; d4[36] := true; d4[45] := true; d4[54] := true; d4[63] := true; d4[72] := true end;
  if p[28] <> 0 then if p[82] <> 0 then if p[37] <> 0 then if p[73] <> 0 then
  if p[46] <> 0 then if p[64] <> 0 then if p[55] <> 0 then
    begin d4[37] := true; d4[46] := true; d4[55] := true; d4[64] := true; d4[73] := true end;
  if p[38] <> 0 then if p[83] <> 0 then if p[47] <> 0 then if p[74] <> 0 then
  if p[56] <> 0 then if p[65] <> 0 then
    begin d4[47] := true; d4[56] := true; d4[65] := true; d4[74] := true end;
  if p[48] <> 0 then if p[84] <> 0 then if p[57] <> 0 then if p[75] <> 0 then
  if p[66] <> 0 then
    begin d4[57] := true; d4[66] := true; d4[75] := true end;
  if p[58] <> 0 then if p[85] <> 0 then if p[67] <> 0 then if p[76] <> 0 then
    begin d4[67] := true; d4[76] := true end;
  if p[68] <> 0 then if p[86] <> 0 then if p[77] <> 0 then
    begin d4[77] := true end;

  if p[21] <> 0 then if p[28] <> 0 then if p[22] <> 0 then if p[27] <> 0 then
  if p[23] <> 0 then if p[26] <> 0 then if p[24] <> 0 then if p[25] <> 0 then
    for i := 22 to 27 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[31] <> 0 then if p[38] <> 0 then if p[32] <> 0 then if p[37] <> 0 then
  if p[33] <> 0 then if p[36] <> 0 then if p[34] <> 0 then if p[35] <> 0 then
    for i := 32 to 37 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[41] <> 0 then if p[48] <> 0 then if p[42] <> 0 then if p[47] <> 0 then
  if p[43] <> 0 then if p[46] <> 0 then if p[44] <> 0 then if p[45] <> 0 then
    for i := 42 to 47 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[51] <> 0 then if p[58] <> 0 then if p[52] <> 0 then if p[57] <> 0 then
  if p[53] <> 0 then if p[56] <> 0 then if p[54] <> 0 then if p[55] <> 0 then
    for i := 52 to 57 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[61] <> 0 then if p[68] <> 0 then if p[62] <> 0 then if p[67] <> 0 then
  if p[63] <> 0 then if p[66] <> 0 then if p[64] <> 0 then if p[65] <> 0 then
    for i := 62 to 67 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);
  if p[71] <> 0 then if p[78] <> 0 then if p[72] <> 0 then if p[77] <> 0 then
  if p[73] <> 0 then if p[76] <> 0 then if p[74] <> 0 then if p[75] <> 0 then
    for i := 72 to 77 do
    if p[i] = couleur then if not(definitif[i]) then if d2[i] then if d3[i] then if d4[i]
      then inc(compt);

  NbPionsDefinitifsAvecInterieursEndgame := compt;
end;


function CoinPlusProche(a : SInt32) : SInt32;
var i,j : SInt32;
begin
  if platMod10[a] <= 4 then i := 1 else i := 8;
  if platDiv10[a] <= 4 then j := 1 else j := 8;
  CoinPlusProche := i+10*j;
end;

function PlusProcheCaseA(a : SInt32) : SInt32;
var x,y : SInt32;
begin
  x := platMod10[a];
  y := platDiv10[a];
  if (x = y) or (x = 9-y) then  {sur une diagonale ?}
    begin
      PlusProcheCaseA := 0;
      exit(PlusProcheCaseA);
    end;
  if x <= 4
    then
      if y <= 4
        then
          if x > y
            then PlusProcheCaseA := 13
            else PlusProcheCaseA := 31
        else
          if x+y > 9
            then PlusProcheCaseA := 83
            else PlusProcheCaseA := 61
    else
      if y <= 4
        then
          if x+y > 9
            then PlusProcheCaseA := 38
            else PlusProcheCaseA := 16
        else
          if x > y
            then PlusProcheCaseA := 68
            else PlusProcheCaseA := 86;
end;

function CoinPlusProcheVide(a : SInt32; var jeu : plateauOthello) : boolean;
var i,j : SInt32;
begin
  if platMod10[a] <= 4 then i := 1 else i := 8;
  if platDiv10[a] <= 4 then j := 1 else j := 8;
  CoinPlusProcheVide := (jeu[i+10*j] = pionVide);
end;

function PlusProcheCaseX(a : SInt32) : SInt32;
var x,y,i,j : SInt32;
begin
  x := platMod10[a];
  y := platDiv10[a];
  if x <= 4 then i := 2 else i := 7;
  if y <= 4 then j := 2 else j := 7;
  PlusProcheCaseX := i+10*j;
end;

function EstUneCaseBordNord(a : SInt32) : boolean;
begin
  EstUneCaseBordNord := (platDiv10[a] = 1);
end;

function EstUneCaseBordSud(a : SInt32) : boolean;
begin
  EstUneCaseBordSud := (platDiv10[a] = 8);
end;

function EstUneCaseBordOuest(a : SInt32) : boolean;
begin
  EstUneCaseBordOuest := (platMod10[a] = 1);
end;

function EstUneCaseBordEst(a : SInt32) : boolean;
begin
  EstUneCaseBordEst := (platMod10[a] = 8);
end;


function estUneCaseX(a : SInt32) : boolean;
begin
  estUneCaseX := (a = 22) or (a = 72) or (a = 27) or (a = 77)  { and CoinPlusProcheVide(a,jeu)  };
end;


function estUneCasePetitCoin(a : SInt32) : boolean;
begin
  estUneCasePetitCoin := (a = 33) or (a = 36) or (a = 63) or (a = 66);
end;


function GenreDeReflexionInSet(genre : SInt16; whichSet : ReflexionTypesSet) : boolean;
begin
  GenreDeReflexionInSet := (genre in whichSet);
end;

end.
