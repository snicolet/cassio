UNIT UnitBibl;




INTERFACE







 USES UnitDefCassio;





procedure FormatageBibl(const chaine : String255; var PartieFormatBibl : stringBibl);
function PeutTrouverNomEnBibl(s : stringBibl; var nomOuverture : String255; var nbreCoupOuv : SInt32; PrecompilationNecessaire : boolean) : boolean;
function EnBibliotheque(s : stringBibl; var index : SInt32) : boolean;
function TrouveCoupEnBibliotheque(const s : String255; var coup,defense : SInt32; refuseQuelquesFois : boolean; var nbReponsesEnBibliotheque : SInt32) : boolean;
function PeutChoisirEnBibl(var whichSquare,defense : SInt32; refuseQuelquesFois : boolean; var nbReponsesEnBibliotheque : SInt32) : boolean;
procedure EcritCoupsBibliotheque(surQuellesCases : SquareSet);
procedure EffaceCoupsBibliotheque;
function PositionCouranteEstDansLaBibliotheque : boolean;
function DoitAfficherBibliotheque : boolean;
procedure DessineBibliotheque(ligneDebut,ligneFin,decH,decV : SInt32);
procedure BibliothequeDansRapport;
procedure RejoueToutesLignesBibliothequeAvecCommentaire;
function LitBibliotheque(nomBibl : String255; verifierLegaliteLignes : boolean) : OSErr;
function NomOuvertureChange(var nomOuverture : String255) : boolean;
function GetLigneDeJeuOfBibliotheque(index : SInt32) : String255;
function GetCommentaireOfBibliotheque(index : SInt32) : String255;
function LigneBibliothequeEnChaine(index : SInt32) : String255;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    fp, Sound, QuickdrawText, MacWindows, Fonts
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, SNMenus, UnitNormalisation
    , UnitInterversions, UnitTroisiemeDimension, UnitJeu, UnitProgressBar, UnitEvenement, UnitAffichageArbreDeJeu, UnitEntreeTranscript, MyStrings
    , UnitOth2, UnitRapport, UnitScannerUtils, UnitFenetres, UnitPackedThorGame, UnitCarbonisation, UnitFichiersTEXT, UnitServicesMemoire
    , MyMathUtils, UnitGeometrie, SNEvents, UnitScannerOthellistique, UnitAffichagePlateau ;
{$ELSEC}
    ;
    {$I prelink/Bibl.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure EssaieUpdateEventsWindowPlateau;     external;



type LectureBibliothequeRec =
  record
    FenetreMessageBibl : WindowPtr;
    nbreFautes : SInt32;
    lastNbreLignesEnBibl : SInt32;
    sommeOctets : SInt32;
    estimationTailleBibl : SInt32;
    intervallePourcentage : SInt32;
    indexCumuleCommentaires : SInt32;
    dernierePartieLue : String255;
    pourcentageLecture : double;
    bibliothequeTropGrosse : boolean;
    doitVerifierCetteBibl : boolean;
    avecinsertionnomsdansmenu : boolean;
  end;



procedure FormatageBibl(const chaine : String255; var PartieFormatBibl : stringBibl);
var t : SInt32;
    s : stringBibl;
begin
  s := '';
  for t := 1 to LENGTH_OF_STRING(chaine) div 2 do
    s := s + chr(PositionDansStringAlphaEnCoup(chaine,2*t-1));
  PartieFormatBibl := s;
end;


function PeutTrouverNomEnBibl(s : stringBibl; var nomOuverture : String255; var nbreCoupOuv : SInt32;
                               PrecompilationNecessaire : boolean) : boolean;
var partie60Essayee,Partie60,Bibl60 : PackedThorGame;
    i,t,index : SInt32;
    OctetDebut,OctetFin : SInt32;
    longueur,longPartie : SInt32;
    longueurEssayee : SInt32;
    indexCommentaireFin,indexCommentaireDeb : SInt32;
begin
  nbreCoupOuv := -1000;
  PeutTrouverNomEnBibl := false;
  nomOuverture := '';
  if bibliothequeLisible then
    begin
      FILL_PACKED_GAME_WITH_ZEROS(partie60);
      COPY_STR60_TO_PACKED_GAME(s, partie60);

      longPartie := GET_LENGTH_OF_PACKED_GAME(partie60);

      if PrecompilationNecessaire then
        begin
          (* WritelnDansRapport('Appel de PrecompileInterversions dans PeutTrouverNomEnBibl'); *)
          PrecompileInterversions(partie60,longPartie);
        end;

      for longueurEssayee := longPartie downto 2 do
        begin

          COPY_PACKED_GAME_TO_PACKED_GAME(partie60, longueurEssayee, partie60Essayee);

          for index := 1 to nbreLignesEnBibl do
            begin
              indexCommentaireDeb := indexCommentaireBibl^^[index-1]+1;
              indexCommentaireFin := indexCommentaireBibl^^[index];
              if (indexCommentaireFin >= indexCommentaireDeb)
                then
                  begin
                     OctetDebut := bibliothequeIndex^^[index-1]+1;
                     OctetFin := bibliothequeIndex^^[index];
                     longueur := OctetFin-OctetDebut+1;
                     if succ(longueur) = longueurEssayee then
                       begin
                         MoveMemory(@BibliothequeEnTas^^[OctetDebut],GET_ADRESS_OF_NTH_MOVE(Bibl60, 2),longueur);
                         inc(longueur);
                         SET_LENGTH_OF_PACKED_GAME(bibl60, longueur);
                         SET_NTH_MOVE_OF_PACKED_GAME(bibl60, 1, 56);    (** F5 **)

                         TraiteInterversionFormatThorCompile(bibl60);

                         SET_NTH_MOVE_OF_PACKED_GAME(bibl60, 1, 150);   (** sentinelle **)
                         t := longueur;
                         while GET_NTH_MOVE_OF_PACKED_GAME(bibl60, t,'PeutTrouverNomEnBibl {1}') =
                               GET_NTH_MOVE_OF_PACKED_GAME(partie60Essayee, t,'PeutTrouverNomEnBibl {2}') do
                           dec(t);
                         if t <= 1 then
                           begin
                             PeutTrouverNomEnBibl := true;
                             nbreCoupOuv := longueurEssayee;
                             for i := indexCommentaireDeb to indexCommentaireFin do
                               nomOuverture := Concat(nomOuverture,commentaireBiblEnTas^^[i]);
                             exit(PeutTrouverNomEnBibl);
                           end;
                       end;
                   end;
            end;
        end;
    end;
end;

function EnBibliotheque(s : stringBibl; var index : SInt32) : boolean;
var Partie60,Bibl60 : PackedThorGame;
    i,t : SInt32;
    OctetDebut,OctetFin : SInt32;
    longueur,longPartie : SInt32;
begin
  EnBibliotheque := false;
  index := 0;
  if bibliothequeLisible then
    begin
      FILL_PACKED_GAME_WITH_ZEROS(partie60);
      COPY_STR60_TO_PACKED_GAME(s, partie60);

      longPartie := GET_LENGTH_OF_PACKED_GAME(partie60);

      if (longPartie >= 1) then
        begin
          (* WritelnDansRapport('Appel de PrecompileInterversions dans EnBibliotheque'); *)
          PrecompileInterversions(partie60,longPartie);
          OctetDebut := 0;
          OctetFin := 0;
          for i := 1 to nbreLignesEnBibl do
            begin

              OctetDebut := OctetFin+1;
              OctetFin := bibliothequeIndex^^[i];
              longueur := OctetFin-OctetDebut+1;


              if succ(longueur) = longPartie then
                begin
                  MoveMemory(@BibliothequeEnTas^^[OctetDebut],GET_ADRESS_OF_NTH_MOVE(Bibl60,2),longueur);
                  inc(longueur);
                  SET_LENGTH_OF_PACKED_GAME(Bibl60, longueur);
                  SET_NTH_MOVE_OF_PACKED_GAME(Bibl60, 1, 56);    (** F5 **)
                  TraiteInterversionFormatThorCompile(bibl60);
                  SET_NTH_MOVE_OF_PACKED_GAME(bibl60, 1, 150);   (** sentinelle **)
                  t := longueur;
                  while GET_NTH_MOVE_OF_PACKED_GAME(bibl60, t, 'EnBibliotheque {1}') = GET_NTH_MOVE_OF_PACKED_GAME(partie60, t, 'EnBibliotheque {1}') do
                     dec(t);
                  if t <= 1 then
                    begin
                      EnBibliotheque := true;
                      index := i;
                      exit(EnBibliotheque);
                    end;
               end;
            end;
        end;
    end;
end;

function TrouveCoupEnBibliotheque(const s : String255;
                                  var coup,defense : SInt32;
                                  refuseQuelquesFois : boolean;
                                  var nbReponsesEnBibliotheque : SInt32) : boolean;
var index,i,n : SInt32;
    n1,n2,nbEssais : SInt32;
    chaine : stringBibl;
    coupTrouve : boolean;
begin
  coup := 0;
  defense := 44;
  TrouveCoupEnBibliotheque := false;
  nbReponsesEnBibliotheque := 0;

  FormatageBibl(s,chaine);
  if (not(refuseQuelquesFois) or PChancesSurN(2,3)) then
  if EnBibliotheque(chaine,index) and (BibliothequeNbReponse^^[index] > 0) then
    begin
      nbReponsesEnBibliotheque := BibliothequeNbReponse^^[index];
      if avecAleatoire then RandomizeTimer;
      coupTrouve := false;
      nbEssais := 0;
      repeat
        inc(nbEssais);
        n := Abs(Random16()) mod 100;
        n1 := -1;
        n2 := -1;
        for i := 1 to BibliothequeNbReponse^^[index] do
          begin
            n1 := n2+1;
            n2 := BibliothequeReponses^^[index,i].bornesup;
            if not(JoueBonsCoupsBibl) or ((n2-n1) >= 10) then
              if (n1 <= n) and (n <= n2) then
                begin
                  coup := BibliothequeReponses^^[index,i].x;
                  coupTrouve := true;
                  TrouveCoupEnBibliotheque := true;
                end;
          end;
      until coupTrouve or (nbEssais > 500);
      chaine := chaine + chr(coup);
      if EnBibliotheque(chaine,index) and (BibliothequeNbReponse^^[index] > 0) then
        begin
          if avecAleatoire then RandomizeTimer;
          n := Abs(Random16()) mod 100;
          n1 := -1;
          n2 := -1;
          for i := 1 to BibliothequeNbReponse^^[index] do
            begin
              n1 := n2+1;
              n2 := BibliothequeReponses^^[index,i].bornesup;
              if (n1 <= n) and (n <= n2) then
                defense := BibliothequeReponses^^[index,i].x;
            end;
        end;
    end;
end;

function PeutChoisirEnBibl(var whichSquare,defense : SInt32; refuseQuelquesFois : boolean; var nbReponsesEnBibliotheque : SInt32) : boolean;
var strPartie : String255;
    test,coupQuatreDiag : boolean;
begin
  whichSquare := 0;
  defense := 0;
  nbReponsesEnBibliotheque := 0;

  if positionFeerique then
    begin
      PeutChoisirEnBibl := false;
      exit(PeutChoisirEnBibl);
    end;

  test := false;
  strPartie := PartieNormalisee(coupQuatreDiag,true);
  if (LENGTH_OF_STRING(strPartie) > 0) or (nbreCoup <= 0) then
    begin
      test := LENGTH_OF_STRING(strPartie) <= 2*LongMaxBibl;   {  bibliotheque jusqu'au coup 41 }

      if test then test := TrouveCoupEnBibliotheque(strPartie,whichSquare,defense,false,nbReponsesEnBibliotheque);
      if test and refuseQuelquesFois and (nbReponsesEnBibliotheque = 1) then
        test := test and UneChanceSur(5);  { une chance sur 5 de «varier» }
      if test then
        begin
           if GetNiemeCoupPartieCourante(1) = 65 then
             begin
                whichSquare := 10*(platMod10[whichSquare])+platDiv10[whichSquare];
                defense := 10*(platMod10[defense])+platDiv10[defense];
             end
           else
             if GetNiemeCoupPartieCourante(1) = 43 then
               begin
                 whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare];
                 defense := 10*(9-platDiv10[defense])+9-platMod10[defense];
               end
             else
               if GetNiemeCoupPartieCourante(1) = 34 then
                 begin
                   whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
                   defense := 10*(9-platMod10[defense])+9-platDiv10[defense];
                 end;
         if coupQuatreDiag then
           begin
             whichSquare := 10*(platMod10[whichSquare])+platDiv10[whichSquare];
             defense := 10*(platMod10[defense])+platDiv10[defense];
           end;
       end;
     end;
   PeutChoisirEnBibl := test;
end;


procedure EcritCoupsBibliotheque(surQuellesCases : SquareSet);
var strPartie : String255;
    chainePartie : stringBibl;
    index,i,n1,n2 : SInt32;
    whichSquare,nbCoupOuverture : SInt32;
    coupQuatreDiag : boolean;
    commentaire : String255;
    indexCommentaireDeb,indexCommentairefin : SInt32;

  procedure TransposeCoupPourOrientationDansBibliotheque(var whichSquare : SInt32);
    begin
      if GetNiemeCoupPartieCourante(1) = 65
        then whichSquare := 10*(platMod10[whichSquare])+platDiv10[whichSquare]
        else if GetNiemeCoupPartieCourante(1) = 43
               then whichSquare := 10*(9-platDiv10[whichSquare])+9-platMod10[whichSquare]
               else if GetNiemeCoupPartieCourante(1) = 34
                      then whichSquare := 10*(9-platMod10[whichSquare])+9-platDiv10[whichSquare];
      if coupQuatreDiag then whichSquare := 10*(platMod10[whichSquare])+platDiv10[whichSquare];
    end;

begin  {EcritCoupsBibliotheque}
  if bibliothequeLisible and (nbreCoup <= LongMaxBibl) and not(positionFeerique) then
    begin
      strPartie := PartieNormalisee(coupQuatreDiag,true);
      FormatageBibl(strPartie,chainePartie);
      if EnBibliotheque(chainePartie,index) then
        begin
          PrepareTexteStatePourEcritCoupsBibl;

          n1 := -1;
          n2 := -1;
          for i := 1 to BibliothequeNbReponse^^[index] do
            begin
              n1 := n2+1;
              n2 := BibliothequeReponses^^[index,i].bornesup;
              whichSquare := BibliothequeReponses^^[index,i].x;
              TransposeCoupPourOrientationDansBibliotheque(whichSquare);
              if whichSquare in surQuellesCases then
                DessinePourcentage(whichSquare,n2-n1+1);
            end;

         if avecNomOuvertures and not(CassioEstEn3D) and not(EnModeEntreeTranscript) then
            begin
              PrepareTexteStatePourCommentaireOuverture;
              indexCommentaireDeb := indexCommentaireBibl^^[index-1]+1;
              indexCommentaireFin := indexCommentaireBibl^^[index];
              if (indexCommentaireFin >= indexCommentaireDeb)
                then
                  begin
                    commentaire := '';
                    for i := indexCommentaireDeb to indexCommentaireFin do
                      commentaire := commentaire+commentaireBiblEnTas^^[i];
                    EcritCommentaireOuverture(commentaire);
                  end
                else
                  if PeutTrouverNomEnBibl(chainePartie,commentaire,nbCoupOuverture,false)
                    then EcritCommentaireOuverture(commentaire)
                    else EffaceCommentaireOuverture;
             end;

          if gCassioUseQuartzAntialiasing then
	          if (SetAntiAliasedTextEnabled(true,9) = NoErr) then DoNothing;

	     end;
    end;
end;

procedure EffaceCoupsBibliotheque;
begin
  if not(aideDebutant)
    then EffaceAideDebutant(true,true,othellierToutEntier,'EffaceCoupsBibliotheque {1}')
    else
      begin
        EffaceAideDebutant(false,true,othellierToutEntier,'EffaceCoupsBibliotheque {2}');
        aideDebutant := true;  {car cela a ete change par l'appel ci-dessus}
        DessineAideDebutant(true,othellierToutEntier);
      end;
end;

function PositionCouranteEstDansLaBibliotheque : boolean;
var strPartie : String255;
    chainePartie : stringBibl;
    index : SInt32;
    coupQuatreDiag : boolean;
begin
  PositionCouranteEstDansLaBibliotheque := false;
  if bibliothequeLisible and (nbreCoup <= LongMaxBibl) and not(positionFeerique) then
    begin
      strPartie := PartieNormalisee(coupQuatreDiag,true);
      FormatageBibl(strPartie,chainePartie);
      if EnBibliotheque(chainePartie,index) then
        PositionCouranteEstDansLaBibliotheque := true;
    end;
end;


function DoitAfficherBibliotheque : boolean;
begin
  DoitAfficherBibliotheque := afficheBibl and (nbreCoup <= LongMaxBibl) and
                              (BAND(GetAffichageProprietesOfCurrentNode,kBibliotheque) <> 0) and
                              not(positionFeerique);
end;

procedure DessineBibliotheque(ligneDebut,ligneFin,decH,decV : SInt32);
var Yaffiche,index : SInt32;
begin
  if bibliothequeLisible then
    begin
      Yaffiche := decV;
      for index := ligneDebut to lignefin do
        if (index >= 1) and (index <= nbrelignesEnBibl) then
          begin
            Yaffiche := Yaffiche+12;
            Moveto(decH,Yaffiche);
            MyDrawString(LigneBibliothequeEnChaine(index));
          end;
    end;
end;

procedure BibliothequeDansRapport;
var index : SInt32;
begin
  {SetEcritToutDansRapportLog(true);}

  for index := 1 to nbrelignesEnBibl do
    WritelnDansRapport(LigneBibliothequeEnChaine(index));

  {SetEcritToutDansRapportLog(false);}
end;

procedure RejoueToutesLignesBibliothequeAvecCommentaire;
var index : SInt32;
    s,s1 : String255;
    gameNodeLePlusProfond : GameTree;
begin
  for index := 1 to nbrelignesEnBibl do
    begin
      s := GetCommentaireOfBibliotheque(index);
      s1 := GetLigneDeJeuOfBibliotheque(index);
      if not(EstUnePartieOthello(s1,false))
        then
          begin
            SysBeep(0);
            WritelnDansRapport('## ligne impossible : '+s1);
          end
        else
          begin
			      if (s <> '') and (s <> 'N/D') then
			        begin
			          s := GetLigneDeJeuOfBibliotheque(index);
			          RejouePartieOthello(s,LENGTH_OF_STRING(s) div 2,true,bidplat,pionNoir,gameNodeLePlusProfond,false,true);
			        end;
			    end;
    end;
end;


procedure TransformeLigneBibliothequeFormatEtrange(var ligne : String255);
var s1,s2 : String255;
    posDeuxPoints : SInt32;
    diagonaleInversee : boolean;
begin
  posDeuxPoints := Pos(':',ligne);
	if posDeuxPoints > 0 then
		begin
		  s1 := TPCopy(ligne,1,posDeuxPoints-1);
		  EnleveEspacesDeGaucheSurPlace(s1);
		  EnleveEspacesDeDroiteSurPlace(s1);
		  s2 := TPCopy(ligne,posDeuxPoints+1,LENGTH_OF_STRING(ligne)-posDeuxPoints);
		  {WritelnDansRapport('s1 = '+s1);
		  WritelnDansRapport('s2 = '+s2);}
		  if not(EstUnePartieOthello(s2,false))
		    then
		      begin
		        SysBeep(0);
		        WritelnDansRapport('##IMPOSSIBLE## '+ligne);
		      end
		    else
		      begin
					  CompacterPartieAlphanumerique(s2,kCompacterEnMajuscules);
					  Normalisation(s2,diagonaleInversee,false);
					  ligne := s2+' : .'+s1;
					  WritelnDansRapport(ligne);
					  {WritelnStringAndBoolDansRapport('ligne = '+ligne+' => ',EstUnePartieOthello(s2,false));}
					end;
		end;
end;


procedure MergeOldBiblCassioWithCommOuv(const dernierePartieLue,unCommentaire : String255);
var PartieFormatBibl : stringBibl;
    s : String255;
    index,n1,n2,whichSquare,i : SInt32;
begin
  FormatageBibl(dernierePartieLue,PartieFormatBibl);
  if EnBibliotheque(PartieFormatBibl,index)
    then
      begin
        s := Concat(dernierePartieLue,' :');

        n1 := -1;
        n2 := -1;
        for i := 1 to BibliothequeNbReponse^^[index] do
          begin
            n1 := n2+1;
            n2 := BibliothequeReponses^^[index,i].bornesup;
            whichSquare := BibliothequeReponses^^[index,i].x;
            s := s + '  '+CoupEnStringEnMajuscules(whichSquare);
            s := s + CharToString('(')+PourcentageEntierEnString(n2-n1+1)+CharToString(')');
          end;

        s := s + ' .'+unCommentaire;
        WritelnDansRapport(s);
      end
    else
      begin
        s := Concat(dernierePartieLue,' : .',unCommentaire);
        WritelnDansRapport(s);
      end;
end;


function ExisteDejaEnBibliotheque(uneligne : String255) : boolean;
var s : String255;
    posDeuxPoints : SInt32;
    PartieFormatBibl : stringBibl;
    index : SInt32;
begin

  EnleveEspacesDeGaucheSurPlace(uneLigne);
  posDeuxPoints := Pos(':',uneligne);

  if posDeuxPoints > 0 then
    begin
		  s := TPCopy(uneligne,1,posDeuxPoints-1);
		  EnleveEspacesDeGaucheSurPlace(s);

		  WritelnDansRapport(s);

		  FormatageBibl(s,PartieFormatBibl);
		  if EnBibliotheque(PartieFormatBibl,index)
		    then ExisteDejaEnBibliotheque := true
		    else ExisteDejaEnBibliotheque := false;
		end
		else
      ExisteDejaEnBibliotheque := false;
end;


procedure OuvrirFenetreLectureBibliotheque(var lectureBiblData : LectureBibliothequeRec);
var unRect : rect;
begin
  with lectureBiblData do
    begin
      with GetScreenBounds do SetRect(unRect,left+40,60,right-40,150);

      if unRect.right-unRect.left > 500 then
        begin
          unRect.right := unRect.left+500;
          OffsetRect(unRect,((GetScreenBounds.left+GetScreenBounds.right-500) div 2)-unRect.left,0);
        end;

      FenetreMessageBibl := MyNewCWindow(NIL,unRect,'',false,1,FenetreFictiveAvantPlan,false,0);

      if (FenetreMessageBibl <> NIL) then
        begin
          ShowHide(FenetreMessageBibl,true);
          SetPortByWindow(FenetreMessageBibl);
          TextFont(systemFont);
          TextSize(0);
        end;
    end;
end;


procedure EcrireFauteLectureBibliotheque(const message : String255; var lectureBiblData : LectureBibliothequeRec);
begin
  with lectureBiblData do
    begin
      SysBeep(0);
      nbreFautes := nbreFautes+1;

      if (FenetreMessageBibl = NIL) then OuvrirFenetreLectureBibliotheque(lectureBiblData);
      if (FenetreMessageBibl <> NIL) then
        begin
          Moveto(1,nbreFautes*12);
          MyDrawString(message);
        end;
      WritelnDansRapport(message);
    end;
end;


procedure AjouterLigneDeBibliotheque(uneLigne : String255; var lectureBiblData : LectureBibliothequeRec);
var compteur : SInt32;
    pos1Point,posDeuxPoints,i,k : SInt32;
    longueurNomOuverture : SInt32;
    uncommentaire : String255;
    metDansMenu : boolean;
    ChaineTestCorrection,s : String255;
    PartieFormatBibl : stringBibl;
    whichSquare : SInt32;
    pourcentage,pourcentagecumule : SInt32;
    pourcentStr : String255;
    longueurligne : SInt32;

begin
  with lectureBiblData do
    begin

      {WritelnDansRapport(uneLigne);}

      {if (uneligne[1] <> 'F') or (uneligne[2] <> '5') then
        begin
          TransformeLigneBibliothequeFormatEtrange(uneLigne);
          exit(AjouterLigneDeBibliotheque);
        end;}


      {if ExisteDejaEnBibliotheque(uneligne) then
        begin
          exit(AjouterLigneDeBibliotheque);
        end;}


      longueurNomOuverture := 0;
      unCommentaire := '';
  	  pos1Point := Pos('.',uneligne);
  	  if (pos1Point > 0) then
  	    begin
  	      longueurNomOuverture := LENGTH_OF_STRING(uneligne)-pos1point;
  	      if indexCumuleCommentaires+longueurNomOuverture <= TailleMaxCommentairesOuvertures then
  	        begin
  	          unCommentaire := TPCopy(uneligne,pos1point+1,longueurNomOuverture);
  	          DeleteString(uneligne,pos1point,longueurNomOuverture+1);
  	          metDansMenu := unCommentaire[1] = '•';
  	          if metdansmenu then
  	            begin
  	              dec(longueurNomOuverture);
  	              unCommentaire := TPCopy(unCommentaire,2,longueurNomOuverture);
  	            end;
  	          for i := 1 to longueurNomOuverture do
  	            commentaireBiblEnTas^^[indexCumuleCommentaires+i] := unCommentaire[i];
  	          indexCumuleCommentaires := indexCumuleCommentaires+longueurNomOuverture;
  	          if avecinsertionnomsdansmenu and metDansMenu and (OuvertureMenu <> NIL) then
  	            begin
  	              MyAppendMenu(OuvertureMenu,unCommentaire);
  	              {MyAppendMenu(OuvertureMenu,Concat(unCommentaire,'  '));}
  	            end;
  	        end;
  	    end; {if (pos1Point > 0) then... }

  	  EnleveEspacesDeGaucheSurPlace(uneLigne);
  	  posDeuxPoints := Pos(':',uneligne);
  	  if posDeuxPoints > 0 then
  	    begin
  	      dernierePartieLue := TPCopy(uneligne,1,posDeuxPoints-1);
  	      DeleteString(uneligne,1,posDeuxPoints);

  	      {
  	      if (longueurNomOuverture > 0) and (EnleveEspacesDeGauche(uneLigne) = '') then
  	        begin
  	          MergeOldBiblCassioWithCommOuv(dernierePartieLue,unCommentaire);
  	        end;
  	      }

  	      if uneligne <> '' then
  	        begin

  	          dernierePartieLue := DeleteSpacesBefore(dernierePartieLue,posDeuxPoints-1);

  	          if nbreLignesEnBibl-lastNbreLignesEnBibl >= intervallePourcentage then
  	            begin
  	              lastNbreLignesEnBibl := nbreLignesEnBibl;
  	              pourcentageLecture := (1.0*nbreLignesEnBibl/estimationTailleBibl);


  	              if pourcentageLecture <= 1.0
  	                then SetProgress(Trunc(300*pourcentageLecture))
  	                else SetProgress(300);

  	            end;

  	          FormatageBibl(dernierePartieLue,PartieFormatBibl);
  	          longueurLigne := LENGTH_OF_STRING(PartieFormatBibl)-1;
  	          if sommeOctets+longueurLigne > tailleMaxTasBibl
  	            then
  	              begin
  	                bibliothequeTropGrosse := true;
  	                s := ReadStringFromRessource(TextesBibliothequeID,5);
  	                EcrireFauteLectureBibliotheque(dernierePartieLue+' : '+s,lectureBiblData);
  	              end
  	            else
  	              begin
  	                nbreLignesEnBibl := nbreLignesEnBibl+1;
  	                Moveleft(PartieFormatBibl[2],BibliothequeEnTas^^[sommeOctets+1],longueurLigne);
  	                sommeOctets := sommeOctets+longueurLigne;
  	                BibliothequeIndex^^[nbreLignesEnBibl] := sommeOctets;
  	                indexCommentaireBibl^^[nbreLignesEnBibl] := indexCumuleCommentaires;
  	                BibliothequeNbReponse^^[nbreLignesEnBibl] := 0;

  	                compteur := 0;
  	                pourcentageCumule := 0;
  	                while (uneligne <> '') and (LENGTH_OF_STRING(uneligne) > 3) do
  	                  begin
  	                    EnleveEspacesDeGaucheSurPlace(uneLigne);
  	                    EnleveEspacesDeDroiteSurPlace(uneLigne);
  	                    if uneligne <> '' then
  	                      begin
  	                        ChaineTestCorrection := dernierePartieLue+uneligne[1]+uneligne[2];
  	                        if doitVerifierCetteBibl then
  	                          if not(EstUnePartieOthello(ChaineTestCorrection,true))
  	                            then
  	                              begin
  	                                s := ReadStringFromRessource(TextesBibliothequeID,6);
  	                                EcrireFauteLectureBibliotheque(ChaineTestCorrection+' : '+s,lectureBiblData);
  	                              end;
  	                         whichSquare := StringEnCoup(uneLigne);
  	                         DeleteString(uneligne,1,3);
  	                         k := Pos(')',uneligne);
  	                         pourcentStr := TPCopy(uneligne,1,k-1);
  	                         ChaineToLongint(pourcentStr,pourcentage);
  	                         DeleteString(uneligne,1,k);

  	                         if (whichSquare >= 11) and (whichSquare <= 88) and (pourcentage >= 0) then
  	                           begin
  	                             compteur := compteur+1;
  	                             pourcentageCumule := pourcentageCumule+pourcentage;
  	                             BibliothequeReponses^^[nbreLignesEnBibl,compteur].x := whichSquare;
  	                             BibliothequeReponses^^[nbreLignesEnBibl,compteur].bornesup := pourcentageCumule-1;
  	                           end;
  	                      end;
  	                  end; {while (uneligne <> '') and (LENGTH_OF_STRING(uneligne) > 3) do...}
  	                BibliothequeNbReponse^^[nbreLignesEnBibl] := compteur;

  	                if (pourcentageCumule > 0) and (pourcentageCumule <> 100) then
  	                  begin
  	                    ChaineTestCorrection := dernierePartieLue;
  	                    s := ReadStringFromRessource(TextesBibliothequeID,7);
  	                    EcrireFauteLectureBibliotheque(ChaineTestCorrection+' : '+s,lectureBiblData);
  	                  end; {if pourcentageCumule <> 100 then ...}

  	              end; {if sommeOctets+longueurLigne > tailleMaxTasBibl then ... else ...}
  	        end; {if uneligne <> '' then...}
  	    end; {if posDeuxPoints > 0 then...}
    end;
end;


function FichierBibliothequeDeCassioExiste(nom : String255; var fic : FichierTEXT) : OSErr;
var s : String255;
    erreurES : OSErr;
begin

  erreurES := -1;

  s := nom;
  if erreurES <> 0 then erreurES := FichierTexteExiste(s,0,fic);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('ibliothèque','ibliotheque',nom);
  if erreurES <> 0 then erreurES := FichierTexteExiste(s,0,fic);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('ibliothèque','ibliotheÃÄque',nom);
  if erreurES <> 0 then erreurES := FichierTexteExiste(s,0,fic);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('ibliotheque','ibliothèque',nom);
  if erreurES <> 0 then erreurES := FichierTexteExiste(s,0,fic);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  s := ReplaceStringOnce('ibliotheque','ibliotheÃÄque',nom);
  if erreurES <> 0 then erreurES := FichierTexteExiste(s,0,fic);
  if erreurES <> 0 then erreurES := FichierTexteDeCassioExiste(s,fic);

  FichierBibliothequeDeCassioExiste := erreurES;

end;





function LitBibliotheque(nomBibl : String255; verifierLegaliteLignes : boolean) : OSErr;
const OuvertureID = 3001;
var FichierBibliotheque : FichierTEXT;
    uneligne : String255;
    erreurES : OSErr;
    s : String255;
    oldport : grafPtr;
    LectureProgressRect : rect;
    lectureBiblData : LectureBibliothequeRec;
    doitOuvrirFenetreLectureBibliotheque : boolean;
    doitMettreMessageBibliothequeAbsenteDansFenetre : boolean;

begin
  with lectureBiblData do
    begin

      LitBibliotheque := -1;
      FenetreMessageBibl := NIL;
      InitProgressIndicator(NIL,MakeRect(0,0,0,0),100,false);

  	  doitVerifierCetteBibl := verifierLegaliteLignes;
  	  indexCumuleCommentaires := 0;
  	  indexCommentaireBibl^^[0] := 0;
  	  lastNbreLignesEnBibl := 0;
  	  sommeOctets := 0;
  	  BibliothequeIndex^^[0] := 0;
  	  nbreFautes := 0;
  	  pourcentageLecture := 0.0;
  	  bibliothequeLisible := false;
  	  if (bibliothequeEnTas <> NIL) and
  	     (bibliothequeIndex <> NIL) and
  	     (BibliothequeNbReponse <> NIL) and
  	     (bibliothequeReponses <> NIL) then
  	    begin
  	      GetPort(oldport);

  	      doitOuvrirFenetreLectureBibliotheque := false;
  	      doitMettreMessageBibliothequeAbsenteDansFenetre := false;

  	      if doitOuvrirFenetreLectureBibliotheque
  	        then OuvrirFenetreLectureBibliotheque(lectureBiblData);


  	      {SetDebuggageUnitFichiersTexte(false);}
    	    erreurES := FichierBibliothequeDeCassioExiste(nomBibl,FichierBibliotheque);


    		  if (erreurES <> 0)
    		    then
    		      begin
    		        doitOuvrirFenetreLectureBibliotheque := doitMettreMessageBibliothequeAbsenteDansFenetre;

    		        if doitMettreMessageBibliothequeAbsenteDansFenetre and (FenetreMessageBibl = NIL) then
    		          OuvrirFenetreLectureBibliotheque(lectureBiblData);


    		        s := ReadStringFromRessource(TextesBibliothequeID,1);
    		        s := ParamStr(s,nomBibl,'','','');

    		        if doitMettreMessageBibliothequeAbsenteDansFenetre and (FenetreMessageBibl <> NIL)
    		          then
    		            begin
    		              Moveto(10,25);
    		              MyDrawString(s);
    		            end
    		          else
    		            WritelnDansRapport(s);

    		        s := ReadStringFromRessource(TextesBibliothequeID,2);

    		        if doitMettreMessageBibliothequeAbsenteDansFenetre and (FenetreMessageBibl <> NIL)
    		          then
    		            begin
    		              Moveto(10,50);
    		              MyDrawString(s);
    		            end
    		          else
    		            WriteDansRapport(s + ' ');

    		        s := ReadStringFromRessource(TextesBibliothequeID,3);

    		        if doitMettreMessageBibliothequeAbsenteDansFenetre and (FenetreMessageBibl <> NIL)
    		          then
    		            begin
    		              Moveto(10,65);
    		              MyDrawString(s);
    		            end
    		          else
    		            WritelnDansRapport(s);

    		        if doitMettreMessageBibliothequeAbsenteDansFenetre and (FenetreMessageBibl <> NIL) then
    		          begin
    		            While not(Button) do ShareTimeWithOtherProcesses(2);
    		          end;

    		      end
    		    else
    		      begin
    		        if (FenetreMessageBibl <> NIL) then
    		          begin
        		        s := ReadStringFromRessource(TextesBibliothequeID,4);
        		        CenterString(0,27,QDGetPortBound.right,s);
        		        with QDGetPortBound do
        		          SetRect(LectureProgressRect,(left+right-300) div 2 -1 ,60,(left+right+300) div 2 +1,73);
        		        InitProgressIndicator(FenetreMessageBibl,LectureProgressRect,300,OptimisePourKaleidoscope);
        		        TextFont(gCassioApplicationFont);
                    TextSize(gCassioSmallFontSize);
        		        TextFace(normal);
        		        TextMode(1);
        		        Moveto(LectureProgressRect.left-5,58);
        		        MyDrawString('O%');
        		        Moveto(LectureProgressRect.right-10,58);
        		        MyDrawString('10O%');
        		        TextFont(systemFont);
        		        TextSize(0);
        		      end;
    		      end;

  	      erreurES := OuvreFichierTexte(FichierBibliotheque);
  	      bibliothequeLisible := (erreurES = 0);


  	      if (OuvertureMenu <> NIL) then TerminateMenu(OuvertureMenu,true);
  	      OuvertureMenu := MyGetMenu(ouvertureID);
  	      avecinsertionnomsdansmenu := (OuvertureMenu <> NIL);

  	      if bibliothequeLisible then
  	        begin
  	          nbreLignesEnBibl := 0;
  	          bibliothequeTropGrosse := false;

  	          estimationTailleBibl := 2500;
  	          if uneSeuleBase then estimationTailleBibl := 800;
  	          intervallePourcentage := Max(1,estimationTailleBibl div 50);


  	          while (erreurES = NoErr) and not(EOFFichierTexte(FichierBibliotheque,erreurES)) and
  	                (nbreLignesEnBibl < maxNbreLignesEnBibl) and
  	                not(bibliothequeTropGrosse) do
  	            begin
  	              erreurES := ReadlnDansFichierTexte(FichierBibliotheque,uneligne);
  	              if erreurES = 0 then
  	                begin
  	                  EnleveEspacesDeGaucheSurPlace(uneLigne);
  	                  if (uneLigne <> '') and (uneLigne[1] <> '%') then
  	                    AjouterLigneDeBibliotheque(uneLigne,lectureBiblData);
  	                end;
  	            end; {while...}

  		        if not(EOFFichierTexte(FichierBibliotheque,erreurES)) and not(bibliothequeTropGrosse) then
  		          begin
  		            bibliothequeTropGrosse := true;
  		            s := ReadStringFromRessource(TextesBibliothequeID,8);
  		            EcrireFauteLectureBibliotheque(dernierePartieLue+' : '+s,lectureBiblData);
  		          end;
  		        erreurES := FermeFichierTexte(FichierBibliotheque);
  	        end;

  	    if (nbreFautes >= 1) and (FenetreMessageBibl <> NIL)
  	      then AttendFrappeClavier;

  	    SetPort(oldport);
  	    if (FenetreMessageBibl <> NIL) then DisposeWindow(FenetreMessageBibl);
  	    EssaieSetPortWindowPlateau;
  	    EssaieUpdateEventsWindowPlateau;

  	    LitBibliotheque := erreurES;
  	  end;
    end;
end;


function NomOuvertureChange(var nomOuverture : String255) : boolean;
var strPartie : String255;
    chainePartie : stringBibl;
    nbCoupOuverture : SInt32;
    coupQuatreDiag : boolean;
begin
  NomOuvertureChange := false;
  if bibliothequeLisible and (nbreCoup <= LongMaxBibl) then
    begin
      strPartie := PartieNormalisee(coupQuatreDiag,true);
      FormatageBibl(strPartie,chainePartie);
      if PeutTrouverNomEnBibl(chainePartie,nomOuverture,nbCoupOuverture,true) then
        NomOuvertureChange := (nbCoupOuverture = nbreCoup);
    end;
end;

function LigneBibliothequeEnChaine(index : SInt32) : String255;
var result : String255;
    octetDebut,octetFin,i,j,whichSquare,n1,n2 : SInt32;
    indexCommentaireDeb,indexCommentairefin : SInt32;
begin
  if (index >= 1) and (index <= nbrelignesEnBibl)
    then
      begin
        result := 'F5';
        OctetDebut := bibliothequeIndex^^[index-1]+1;
        OctetFin := bibliothequeIndex^^[index];
        for j := OctetDebut to OctetFin do
          begin
            whichSquare := BibliothequeEnTas^^[j];
            result := result+CoupEnStringEnMajuscules(whichSquare);
          end;
        result := result+' :';
        n1 := -1; n2 := -1;
        for i := 1 to BibliothequeNbReponse^^[index] do
          begin
            n1 := n2+1;
            n2 := BibliothequeReponses^^[index,i].bornesup;
            whichSquare := BibliothequeReponses^^[index,i].x;
            result := result+' '+CoupEnStringEnMajuscules(whichSquare);
            result := result+CharToString('(')+PourcentageEntierEnString(n2-n1+1)+CharToString(')');
          end;

        indexCommentaireDeb := indexCommentaireBibl^^[index-1]+1;
        indexCommentaireFin := indexCommentaireBibl^^[index];
        if (indexCommentaireFin >= indexCommentaireDeb) then
          begin
            result := result+' .';
            for i := indexCommentaireDeb to indexCommentaireFin do
              result := result+commentaireBiblEnTas^^[i];
          end;

        LigneBibliothequeEnChaine := result;
      end
    else
      LigneBibliothequeEnChaine := 'N/D';
end;

function GetLigneDeJeuOfBibliotheque(index : SInt32) : String255;
var result : String255;
    octetDebut,octetFin,j,whichSquare : SInt32;
begin
  if (index >= 1) and (index <= nbrelignesEnBibl)
    then
      begin
        result := 'F5';
        OctetDebut := bibliothequeIndex^^[index-1]+1;
        OctetFin := bibliothequeIndex^^[index];
        for j := OctetDebut to OctetFin do
          begin
            whichSquare := BibliothequeEnTas^^[j];
            result := result+CoupEnStringEnMajuscules(whichSquare);
          end;
        GetLigneDeJeuOfBibliotheque := result;
      end
    else
      GetLigneDeJeuOfBibliotheque := 'N/D';
end;


function GetCommentaireOfBibliotheque(index : SInt32) : String255;
var result : String255;
    i,indexCommentaireDeb,indexCommentairefin : SInt32;
begin
  if (index >= 1) and (index <= nbrelignesEnBibl)
    then
      begin
        result := '';
        indexCommentaireDeb := indexCommentaireBibl^^[index-1]+1;
        indexCommentaireFin := indexCommentaireBibl^^[index];
        if (indexCommentaireFin >= indexCommentaireDeb) then
          begin
            for i := indexCommentaireDeb to indexCommentaireFin do
              result := result+commentaireBiblEnTas^^[i];
          end;
        GetCommentaireOfBibliotheque := result;
      end
    else
      GetCommentaireOfBibliotheque := 'N/D';
end;



end.
