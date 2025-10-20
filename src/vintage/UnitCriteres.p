UNIT UnitCriteres;

INTERFACE




 USES UnitDefCassio;


procedure CalculTableCriteres;
procedure DoCriteres;
procedure DoChangeSousSelectionActive;
procedure ValiderSousCritereRuban;
procedure AnnulerSousCriteresRuban;
procedure DoSwaperLesSousCriteres;
procedure DoNegationnerLesSousCriteres;
function SousCriteresVides : boolean;

procedure SetSousCriteresJoueursNoirs(s : String255);
procedure SetSousCriteresJoueursBlancs(s : String255);
procedure SetSousCriteresTournois(s : String255);
procedure SetSousCriteresDistributions(s : String255);

procedure RemplitTableCompatibleJoueurAvecCeBooleen(var table : t_JoueurCompatible; whichBoolean : boolean);
procedure RemplitTableCompatibleTournoiAvecCeBooleen(var table : t_TournoiCompatible; whichBoolean : boolean);
procedure RemplitTableCompatibleScoreAvecCeBooleen(var table : t_ScoreCompatible; whichBoolean : boolean);
procedure RemplitTableCompatibleDistributionAvecCeBooleen(var table : t_DistributionCompatible; whichBoolean : boolean);

procedure CalculeTableJoueursCompatibles(nomJoueur : String255; var compatible : t_JoueurCompatible; niveauxRecurence : SInt32);
procedure CalculeTableTournoisCompatibles(nomTournoi : String255; var compatible : t_TournoiCompatible; niveauxRecurence : SInt32);
procedure CalculeTableDistributionsCompatibles(nomDistribution : String255; var compatible : t_DistributionCompatible);

function NewTableJoueurCompatiblePtr : t_JoueurCompatible;
function NewTableTournoiCompatiblePtr : t_TournoiCompatible;
function NewTableScoreCompatiblePtr : t_ScoreCompatible;
function NewTableDistributionsCompatiblesPtr : t_DistributionCompatible;

procedure DisposeTableJoueurCompatible(var table : t_JoueurCompatible);
procedure DisposeTableTournoiCompatible(var table : t_TournoiCompatible);
procedure DisposeTableScoreCompatible(var table : t_ScoreCompatible);
procedure DisposeTableDistributionCompatible(var table : t_DistributionCompatible);

function TransformePourPerfectMatch(s : String255) : String255;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, UnitDefATR
{$IFC NOT(USE_PRELINK)}
    , MyQuickDraw, UnitEvenement, UnitATR, UnitUtilitaires, UnitAccesNouveauFormat, MyMathUtils
    , UnitServicesMemoire, UnitJaponais, UnitCurseur, UnitListe, UnitOth2, UnitStatistiques, MyStrings, UnitDialog
    , UnitRapport, UnitFenetres, UnitCarbonisation, SNEvents, UnitImportDesNoms ;
{$ELSEC}
    ;
    {$I prelink/Criteres.lk}
{$ENDC}


{END_USE_CLAUSE}











const tempsUtiliseDernierCalculDesCriteres : SInt32 = 0;   {temps en ticks}


function SousCriteresVides : boolean;
begin
  if CriteresSuplementaires = NIL
    then SousCriteresVides := true
    else SousCriteresVides := (CriteresSuplementaires^^.CriteresNoir =  'รรรรรร') &
                              (CriteresSuplementaires^^.CriteresBlanc =  'รรรรรร') &
                              (CriteresSuplementaires^^.CriteresTournoi =  'รรรร') &
                              (CriteresSuplementaires^^.CriteresDistribution =  'รรรร');
end;

procedure ParserSousCriteresDeJoueurs(sousCriteres : String255; var s1,s2,s3,s4,s5,s6 : String255);
var i,t : SInt16;
    s : String255;
begin
  for i := 1 to 6 do
    begin
      t := Pos('ร',sousCriteres);
      s := TPCopy(sousCriteres,1,t-1);
      DeleteString(sousCriteres,1,t);
      case i of
        1 : s1 := s;
        2 : s2 := s;
        3 : s3 := s;
        4 : s4 := s;
        5 : s5 := s;
        6 : s6 := s;
      end; {case}
    end;
end;

procedure ParserSousCriteresDeTournois(sousCriteres : String255; var s1,s2,s3,s4 : String255);
var i,t : SInt16;
    s : String255;
begin
  for i := 1 to 6 do
    begin
      t := Pos('ร',sousCriteres);
      s := TPCopy(sousCriteres,1,t-1);
      DeleteString(sousCriteres,1,t);
      case i of
        1 : s1 := s;
        2 : s2 := s;
        3 : s3 := s;
        4 : s4 := s;
      end; {case}
    end;
end;

procedure ParserSousCriteresDeDistributions(sousCriteres : String255; var s1,s2,s3,s4 : String255);
var i,t : SInt16;
    s : String255;
begin
  for i := 1 to 6 do
    begin
      t := Pos('ร',sousCriteres);
      s := TPCopy(sousCriteres,1,t-1);
      DeleteString(sousCriteres,1,t);
      case i of
        1 : s1 := s;
        2 : s2 := s;
        3 : s3 := s;
        4 : s4 := s;
      end; {case}
    end;
end;



procedure FabriquerRecursivementArbreDesJoueurs(var arbrePositif,arbreNegatif : ATR; chaine : String255; niveauxRecurence : SInt32; positif : boolean);
var i,p,q,l : SInt32;
    groupe : String255;
    listeGroupeJoueurs : String255;
    joueur : String255;
    nomCompare : String255;
    nomCompareJaponais : String255;
begin
  {WritelnDansRapport('FabriquerRecursivementArbreDesJoueurs : '+chaine);}

  if (chaine = '')
    then exit(FabriquerRecursivementArbreDesJoueurs);

  if (chaine[1] = 'ญ')
    then
      begin
        chaine := TPCopy(chaine,2,LENGTH_OF_STRING(chaine)-1);
        {WritelnDansRapport('NOT ce joueur : '+chaine);}
        FabriquerRecursivementArbreDesJoueurs(arbrePositif,arbreNegatif,chaine,NiveauxRecurence,not(positif));
      end
  else
  if (chaine[1] <> 'ท')
    then
      begin
        nomCompare := TPCopy(chaine,1,Min(19,LENGTH_OF_STRING(chaine)));
        EpureNomJoueur(nomCompare);
        nomCompare := MyUpperString(nomCompare,false);
        {WritelnDansRapport('NOM = ฅฅ'+nomCompare+'ฅฅ');}
        if positif
          then InsererDansATR(arbrePositif,nomCompare)
          else InsererDansATR(arbreNegatif,nomCompare);

        if gVersionJaponaiseDeCassio & gHasJapaneseScript then
          begin
            nomCompareJaponais := TPCopy(chaine,1,Min(19,LENGTH_OF_STRING(chaine)));
            nomCompareJaponais := MyUpperString(nomCompareJaponais,false);
            if positif
              then InsererDansATR(arbrePositif,nomCompareJaponais)
              else InsererDansATR(arbreNegatif,nomCompareJaponais);
          end;

      end
    else  (* cas (chaine[1] = 'ท') *)
      if NiveauxRecurence < 4 then
      begin
        for i := 1 to nbMaxGroupes do
          begin
            groupe := groupes^^[i];
            if Pos(chaine,groupe) = 1 then
              begin
                l := LENGTH_OF_STRING(groupe);
                p := Pos('{',groupe);
                listeGroupeJoueurs := TPCopy(groupe,p+1,l-p-1);
                if listeGroupeJoueurs <> '' then
                  repeat
                    q := Pos(',',listeGroupeJoueurs);
                    if q > 0
                      then
                        begin
                          joueur := TPCopy(listeGroupeJoueurs,1,q-1);
                          EnleveEspacesDeGaucheSurPlace(joueur);
                          EnleveEspacesDeDroiteSurPlace(joueur);
                          FabriquerRecursivementArbreDesJoueurs(arbrePositif,arbreNegatif,joueur,NiveauxRecurence+1,positif);
                          DeleteString(listeGroupeJoueurs,1,q);
                        end
                      else
                        begin
                          joueur := listeGroupeJoueurs;
                          EnleveEspacesDeGaucheSurPlace(joueur);
                          EnleveEspacesDeDroiteSurPlace(joueur);
                          FabriquerRecursivementArbreDesJoueurs(arbrePositif,arbreNegatif,joueur,NiveauxRecurence+1,positif);
                          listeGroupeJoueurs := '';
                        end;
                  until (q = 0) | (listeGroupeJoueurs = '');
              end;
          end;
      end;
end;


procedure FabriquerRecursivementArbreDesTournois(var arbrePositif,arbreNegatif : ATR; chaine : String255; niveauxRecurence : SInt32; positif : boolean);
var i,p,q,l : SInt32;
    groupe : String255;
    listeGroupeTournois : String255;
    tournoi : String255;
    nomCompare : String255;
    nomCompareJaponais : String255;
begin

  if (chaine = '')
    then exit(FabriquerRecursivementArbreDesTournois);

  if (chaine[1] = 'ญ')
    then
      begin
        chaine := TPCopy(chaine,2,LENGTH_OF_STRING(chaine)-1);
        FabriquerRecursivementArbreDesTournois(arbrePositif,arbreNegatif,chaine,NiveauxRecurence,not(positif));
      end
  else
  if (chaine[1] <> 'ท')
    then
      begin
        TraiteTournoiEnMinuscules(chaine,nomCompare);
        if positif
          then InsererDansATR(arbrePositif,nomCompare)
          else InsererDansATR(arbreNegatif,nomCompare);
        if gVersionJaponaiseDeCassio & gHasJapaneseScript then
          begin
            nomCompareJaponais := TPCopy(chaine,1,Min(29,LENGTH_OF_STRING(chaine)));
            nomCompareJaponais := MyUpperString(nomCompareJaponais,false);
            if positif
              then InsererDansATR(arbrePositif,nomCompareJaponais)
              else InsererDansATR(arbreNegatif,nomCompareJaponais);
          end;
      end
    else (* cas (chaine[1] = 'ท') *)
      if NiveauxRecurence < 4 then
      begin
        for i := 1 to nbMaxGroupes do
          begin
            groupe := groupes^^[i];
            if Pos(chaine,groupe) = 1 then
              begin
                l := LENGTH_OF_STRING(groupe);
                p := Pos('{',groupe);
                listeGroupeTournois := TPCopy(groupe,p+1,l-p-1);
                if listeGroupeTournois <> '' then
                  repeat
                    q := Pos(',',listeGroupeTournois);
                    if q > 0
                      then
                        begin
                          tournoi := TPCopy(listeGroupeTournois,1,q-1);
                          EnleveEspacesDeGaucheSurPlace(tournoi);
                          EnleveEspacesDeDroiteSurPlace(tournoi);
                          FabriquerRecursivementArbreDesTournois(arbrePositif,arbreNegatif,tournoi,NiveauxRecurence+1,positif);
                          DeleteString(listeGroupeTournois,1,q);
                        end
                      else
                        begin
                          tournoi := listeGroupeTournois;
                          EnleveEspacesDeGaucheSurPlace(tournoi);
                          EnleveEspacesDeDroiteSurPlace(tournoi);
                          FabriquerRecursivementArbreDesTournois(arbrePositif,arbreNegatif,tournoi,NiveauxRecurence+1,positif);
                          listeGroupeTournois := '';
                        end;
                  until (q = 0) | (listeGroupeTournois = '');
              end;
          end;
      end;
end;


procedure CalculeTableJoueursCompatibles(nomJoueur : String255; var compatible : t_JoueurCompatible; niveauxRecurence : SInt32);
var nombase : String255;
    nomBaseJaponais : String255;
    arbrePositif,arbreNegatif : ATR;
    k,position : SInt32;
    marqueurDebutSyntaxeGrep : boolean;
    marqueurFinSyntaxeGrep : boolean;
begin

  (* nomJoueur : changer les guillemets pour utiliser la syntaxe de grep
                 pour le debut et la fin de mot *)

  if (nomJoueur[1] = '"')
    then nomJoueur[1] := '^';

  if (nomJoueur[LENGTH_OF_STRING(nomJoueur)] = '"')
    then nomJoueur[LENGTH_OF_STRING(nomJoueur)] := '$';

  if (nomJoueur = '^') | (nomJoueur = '$') | (nomJoueur = '^$')
    then nomJoueur := '';

  (* lancer le calcul des joueurs compatibles *)

  if (nomjoueur <> '') then
    begin

      marqueurDebutSyntaxeGrep := (nomJoueur[1] = '^');
      marqueurFinSyntaxeGrep   := (nomJoueur[LENGTH_OF_STRING(nomJoueur)] = '$');

      arbrePositif := MakeEmptyATR;
      arbreNegatif := MakeEmptyATR;
      FabriquerRecursivementArbreDesJoueurs(arbrePositif,arbreNegatif,nomJoueur,niveauxRecurence,true);

      for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
        begin
          nomBase := GetNomJoueur(k);
          nomBase := MyUpperString(nomBase,false);

          if marqueurDebutSyntaxeGrep then nomBase := '^' + nomBase;
          if marqueurFinSyntaxeGrep   then nomBase := nomBase + '$';

          if (ATRIsEmpty(arbrePositif) | TrouveATRDansChaine(arbrePositif,nomBase,position)) &
             (ATRIsEmpty(arbreNegatif) | not(TrouveATRDansChaine(arbreNegatif,nomBase,position)))
             then compatible^[k] := true;
        end;

      if gVersionJaponaiseDeCassio & gHasJapaneseScript then
        for k := 0 to JoueursNouveauFormat.nbJoueursNouveauFormat-1 do
	        if JoueurAUnNomJaponais(k) then
	          begin
	            nomBaseJaponais := GetNomJaponaisDuJoueur(k);
	            nomBaseJaponais := MyUpperString(nomBaseJaponais,false);
	
	            if marqueurDebutSyntaxeGrep then nomBaseJaponais := '^' + nomBaseJaponais;
              if marqueurFinSyntaxeGrep   then nomBaseJaponais := nomBaseJaponais + '$';
	
	            if TrouveATRDansChaine(arbrePositif,nomBaseJaponais,position) then
	              compatible^[k] := true;
	          end;

      DisposeATR(arbrePositif);
      DisposeATR(arbreNegatif);
    end;
end;


function NumEnString(num : SInt32) : String255; EXTERNAL_NAME('NumEnString');


procedure CalculeTableTournoisCompatibles(nomTournoi : String255; var compatible : t_TournoiCompatible; niveauxRecurence : SInt32);
var nombase : String255;
    nomBaseJaponais : String255;
    arbrePositif,arbreNegatif : ATR;
    k,position : SInt32;
    marqueurDebutSyntaxeGrep : boolean;
    marqueurFinSyntaxeGrep : boolean;
begin

  (* nomTournoi : changer les guillemets pour utiliser la syntaxe de grep
                  pour le debut et la fin de mot *)

  if (nomTournoi[1] = '"')
    then nomTournoi[1] := '^';

  if (nomTournoi[LENGTH_OF_STRING(nomTournoi)] = '"')
    then nomTournoi[LENGTH_OF_STRING(nomTournoi)] := '$';

  if (nomTournoi = '^') | (nomTournoi = '$') | (nomTournoi = '^$')
    then nomTournoi := '';


  (* lancer le calcul des tournois compatibles *)

  if (nomTournoi <> '') then
    begin

      marqueurDebutSyntaxeGrep := (nomTournoi[1] = '^');
      marqueurFinSyntaxeGrep   := (nomTournoi[LENGTH_OF_STRING(nomTournoi)] = '$');

      arbrePositif := MakeEmptyATR;
      arbreNegatif := MakeEmptyATR;
      FabriquerRecursivementArbreDesTournois(arbrePositif,arbreNegatif,nomTournoi,niveauxRecurence,true);

      for k := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat-1 do
        begin
          nomBase := GetNomTournoi(k);
          TournoiEnMinuscules(nomBase);

          if marqueurDebutSyntaxeGrep then nomBase := '^' + nomBase;
          if marqueurFinSyntaxeGrep   then nomBase := nomBase + '$';

          if (ATRIsEmpty(arbrePositif) | TrouveATRDansChaine(arbrePositif,nomBase,position)) &
             (ATRIsEmpty(arbreNegatif) | not(TrouveATRDansChaine(arbreNegatif,nomBase,position)))
             then compatible^[k] := true;
        end;

      for k := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat-1 do
        begin
          nomBase := GetNomCourtTournoi(k);
          TournoiEnMinuscules(nomBase);

          if marqueurDebutSyntaxeGrep then nomBase := '^' + nomBase;
          if marqueurFinSyntaxeGrep   then nomBase := nomBase + '$';

          if (ATRIsEmpty(arbrePositif) | TrouveATRDansChaine(arbrePositif,nomBase,position)) &
             (ATRIsEmpty(arbreNegatif) | not(TrouveATRDansChaine(arbreNegatif,nomBase,position)))
             then compatible^[k] := true;
        end;

      if gVersionJaponaiseDeCassio & gHasJapaneseScript then
        for k := 0 to TournoisNouveauFormat.nbTournoisNouveauFormat-1 do
	        if TournoiAUnNomJaponais(k) then
	          begin
	            nomBaseJaponais := GetNomJaponaisDuTournoi(k);
	            nomBaseJaponais := MyUpperString(nomBaseJaponais,false);
	
	            if marqueurDebutSyntaxeGrep then nomBaseJaponais := '^' + nomBaseJaponais;
              if marqueurFinSyntaxeGrep   then nomBaseJaponais := nomBaseJaponais + '$';

	            if TrouveATRDansChaine(arbrePositif,nomBaseJaponais,position) then
	              compatible^[k] := true;
	          end;

      DisposeATR(arbrePositif);
      DisposeATR(arbreNegatif);
    end;
end;

procedure CalculeTableDistributionsCompatibles(nomDistribution : String255; var compatible : t_DistributionCompatible);
var k : SInt32;
    nomDistributionSurDisque : String255;
    marqueurDebutSyntaxeGrep : boolean;
    marqueurFinSyntaxeGrep : boolean;
begin

  (* nomDistribution : changer les guillemets pour utiliser la syntaxe de grep
                       pour le debut et la fin de mot *)

  if (nomDistribution[1] = '"')
    then nomDistribution[1] := '^';

  if (nomDistribution[LENGTH_OF_STRING(nomDistribution)] = '"')
    then nomDistribution[LENGTH_OF_STRING(nomDistribution)] := '$';

  if (nomDistribution = '^') | (nomDistribution = '$') | (nomDistribution = '^$')
    then nomDistribution := '';


  (* lancer le calcul des distributions compatibles *)

  UpCaseString(nomDistribution);
  if (nomDistribution <> '') then
    begin

      marqueurDebutSyntaxeGrep := (nomDistribution[1] = '^');
      marqueurFinSyntaxeGrep   := (nomDistribution[LENGTH_OF_STRING(nomDistribution)] = '$');

      for k := 1 to DistributionsNouveauFormat.nbDistributions do
        begin
          nomDistributionSurDisque := UpCaseStr(GetNomUsuelDistribution(k));

          if marqueurDebutSyntaxeGrep then nomDistributionSurDisque := '^' + nomDistributionSurDisque;
          if marqueurFinSyntaxeGrep   then nomDistributionSurDisque := nomDistributionSurDisque + '$';

          if (Pos(nomDistribution,nomDistributionSurDisque) > 0)
             then compatible^[k] := true;
        end;
      if (Pos('***',nomDistribution) = 1) & (ASeulementCeCaractere('*',nomDistribution))
        then compatible^[0] := true;
    end;
end;


procedure RemplitTableCompatibleJoueurAvecCeBooleen(var table : t_JoueurCompatible; whichBoolean : boolean);
var k : SInt32;
begin
  for k := 0 to nbMaxJoueursEnMemoire do table^[k] := whichBoolean;
end;


procedure RemplitTableCompatibleTournoiAvecCeBooleen(var table : t_TournoiCompatible; whichBoolean : boolean);
var k : SInt32;
begin
  for k := 0 to nbMaxTournoisEnMemoire do table^[k] := whichBoolean;
end;

procedure RemplitTableCompatibleScoreAvecCeBooleen(var table : t_ScoreCompatible; whichBoolean : boolean);
var k : SInt32;
begin
  for k := 0 to 255 do table^[k] := whichBoolean;
end;


procedure RemplitTableCompatibleDistributionAvecCeBooleen(var table : t_DistributionCompatible; whichBoolean : boolean);
var k : SInt32;
begin
  for k := 0 to 255 do table^[k] := whichBoolean;
end;

procedure CalculTableCriteres;
var TournoiCompatible : t_TournoiCompatible;
    JoueurNoirCompatible,JoueurBlancCompatible : t_JoueurCompatible;
    DistributionCompatible : t_DistributionCompatible;
    anneeCompatible : array[1950..2050] of boolean;
    Noirs,Blancs,Tournois,Distributions : String255;
    compatibiliteTournoi,compatibiliteJoueurs : boolean;
    ANDentreJoueurs : boolean;
    compatibiliteDistribution : boolean;
    compatibiliteOrdinateurs : boolean;
    nroPartie : SInt32;
    avecAnnees : boolean;
    tickDepart : SInt32;

    procedure DetermineCompatibilites(JoueursNoirStr,JoueursBlancStr,TournoisStr,DistributionStr : String255;
                                      var JoueurNoirCompatible,JoueurBlancCompatible : t_JoueurCompatible;
                                      var TournoiCompatible : t_TournoiCompatible; var avecAnnees : boolean;
                                      var DistributionCompatible : t_DistributionCompatible);
    var NomNoirCrit,NomBlancCrit : array[1..6] of String255;
        NomTournoiCrit : array[1..4] of String255;
        NomDistribCrit : array[1..4] of String255;

        function NoirEstVide : boolean;
        var test : boolean;
            k : SInt32;
        begin
          test := true;
          for k := 1 to 6 do test := test & (NomNoirCrit[k] = '');
          NoirEstVide := test;
        end;

        function BlancEstVide : boolean;
        var test : boolean;
            k : SInt32;
        begin
          test := true;
          for k := 1 to 6 do test := test & (NomBlancCrit[k] = '');
          BlancEstVide := test;
        end;

        function TournoiEstVide : boolean;
        var test : boolean;
            k : SInt32;
        begin
          test := true;
          for k := 1 to 4 do test := test & (NomTournoiCrit[k] = '');
          TournoiEstVide := test;
        end;

        function DistributionEstVide : boolean;
        var test : boolean;
            k : SInt32;
        begin
          test := true;
          for k := 1 to 4 do test := test & (NomDistribCrit[k] = '');
          DistributionEstVide := test;
        end;

        procedure DetermineCompatiblesBlanc;
        var k : SInt32;
            critere : String255;
        begin
          if BlancEstVide
            then
              begin
                if InclurePartiesAvecOrdinateursDansListe
                  then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,true)
                  else
                    begin
                      RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,false);
                      CalculeTableJoueursCompatibles('ญ(',JoueurBlancCompatible,0);
                    end;
              end
            else
              begin
               RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,false);
               for k := 1 to 6 do
                 begin
                   critere := NomBlancCrit[k];
                   if (critere <> '') then
                     begin
                       if (sousCritereMustBeAPerfectMatch[JoueurBlancRubanBox])
                         then critere := TransformePourPerfectMatch(critere);
                       CalculeTableJoueursCompatibles(critere,JoueurBlancCompatible,0);
                     end;
                 end;
              end;
        end;

        procedure DetermineCompatiblesNoir;
        var k : SInt32;
            critere : String255;
        begin
          if NoirEstVide
            then
              begin
                if InclurePartiesAvecOrdinateursDansListe
                  then RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,true)
                  else
                    begin
                      RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,false);
                      CalculeTableJoueursCompatibles('ญ(',JoueurNoirCompatible,0);
                    end;
              end
            else
              begin
                RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,false);
                for k := 1 to 6 do
                 begin
                   critere := NomNoirCrit[k];
                   if (critere <> '') then
                     begin
                       if (sousCritereMustBeAPerfectMatch[JoueurNoirRubanBox])
                         then critere := TransformePourPerfectMatch(critere);
                       CalculeTableJoueursCompatibles(critere,JoueurNoirCompatible,0);
                     end;
                 end;
              end;
        end;



        procedure DetermineCompatiblesTournoi;
        var k,an : SInt32;
            critere : String255;
            firstAnneeDemandee,lastAnneeDemandee : SInt16;
            numeroTournoi : SInt32;
            tousLesTournoisSontVides : boolean;
        begin
          if TournoiEstVide
            then
              RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,true)
            else
              begin
                for k := 1950 to 2050 do anneeCompatible[k] := false;
                RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,false);
                tousLesTournoisSontVides := true;
                for k := 1 to 4 do
                  begin
                    critere := NomTournoiCrit[k];
                    if critere <> '' then
                      begin
                        if not(TrouveNumeroDuTournoi(critere, numeroTournoi, 0))
                           & EnleveAnneeADroiteDansChaine(critere,firstAnneeDemandee,lastAnneeDemandee) then
                          begin
                            avecAnnees := true;
                            for an := firstAnneeDemandee to lastAnneeDemandee do
                              anneeCompatible[an] := true;
                          end;
                        if critere <> '' then
                          begin
                            tousLesTournoisSontVides := false;

                            if (sousCritereMustBeAPerfectMatch[TournoiRubanBox])
                              then critere := TransformePourPerfectMatch(critere);
                            CalculeTableTournoisCompatibles(critere,TournoiCompatible,0);
                          end;
                      end;
                  end;
                if tousLesTournoisSontVides then
                  begin
                    RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,true);
                  end;
              end;
        end;

        procedure DetermineCompatiblesDistribution;
        var k : SInt32;
            critere : String255;
        begin
          if DistributionEstVide
            then RemplitTableCompatibleDistributionAvecCeBooleen(DistributionCompatible,true)
            else
              begin
                RemplitTableCompatibleDistributionAvecCeBooleen(DistributionCompatible,false);
                for k := 1 to 4 do
                 begin
                   critere := NomDistribCrit[k];
                   if critere <> '' then
                     CalculeTableDistributionsCompatibles(critere,DistributionCompatible);
                 end;
              end;
        end;

        procedure InitialiseTablesCriteres;
        var i,t : SInt32;
            ligneCriteres,s : String255;
        begin
          ligneCriteres := JoueursNoirStr;
          for i := 1 to 6 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              TraiteJoueurEnMinuscules(s,NomNoirCrit[i]);
            end;

          ligneCriteres := JoueursBlancStr;
          for i := 1 to 6 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              TraiteJoueurEnMinuscules(s,NomBlancCrit[i]);
            end;

          ligneCriteres := TournoisStr;
          for i := 1 to 4 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              NomTournoiCrit[i] := s;
              {TraiteTournoiEnMinuscules(s,NomTournoiCrit[i]);}
            end;

          ligneCriteres := DistributionStr;
          for i := 1 to 4 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              NomDistribCrit[i] := s;
            end;
        end;

    begin  {DetermineCompatibilites}
      InitialiseTablesCriteres;
      avecAnnees := false;
      DetermineCompatiblesTournoi;
      DetermineCompatiblesBlanc;
      DetermineCompatiblesNoir;
      DetermineCompatiblesDistribution;
    end;

begin  {CalculTableCriteres}

  if problemeMemoireBase | (CriteresSuplementaires = NIL)
    then exit(CalculTableCriteres);


  if not(gPendantLesInitialisationsDeCassio) & (tempsUtiliseDernierCalculDesCriteres > 15) then
    begin

      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;
  if GetNextEvent(updateMask,theEvent) then TraiteEvenements;
  if not(gPendantLesInitialisationsDeCassio) & (tempsUtiliseDernierCalculDesCriteres > 15) then
    begin

      watch := GetCursor(watchcursor);
      SafeSetCursor(watch);
    end;

  tickDepart := TickCount;

  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;

  JoueurBlancCompatible  := NewTableJoueurCompatiblePtr;
  JoueurNoirCompatible   := NewTableJoueurCompatiblePtr;
  TournoiCompatible      := NewTableTournoiCompatiblePtr;
  DistributionCompatible := NewTableDistributionsCompatiblesPtr;

  if SousCriteresVides & InclurePartiesAvecOrdinateursDansListe
    then
      begin
        LaveTableCriteres;
        sousSelectionActive := false;
        EcritRubanListe(false);
      end
    else
      begin

        if sousSelectionActive
          then
            begin
              Noirs := CriteresSuplementaires^^.CriteresNoir;
              Blancs := CriteresSuplementaires^^.CriteresBlanc;
              Tournois := CriteresSuplementaires^^.CriteresTournoi;
              Distributions := CriteresSuplementaires^^.CriteresDistribution;
            end
          else
            begin
              Noirs         := 'รรรรรร';
              Blancs        := 'รรรรรร';
              Tournois      := 'รรรร';
              Distributions := 'รรรร';
            end;

        DetermineCompatibilites(Noirs,Blancs,Tournois,Distributions,JoueurNoirCompatible,JoueurBlancCompatible,
                                TournoiCompatible,avecAnnees,DistributionCompatible);

        if InclurePartiesAvecOrdinateursDansListe
          then
            begin
              ANDentreJoueurs := (Noirs <> Blancs);
              for nroPartie := 1 to nbPartiesChargees do
                begin
                  if avecAnnees
                    then compatibiliteTournoi := TournoiCompatible^[GetNroTournoiParNroRefPartie(nroPartie)] & anneeCompatible[GetAnneePartieParNroRefPartie(nroPartie)]
                    else compatibiliteTournoi := TournoiCompatible^[GetNroTournoiParNroRefPartie(nroPartie)];
                  if ANDentreJoueurs
                    then compatibiliteJoueurs := JoueurNoirCompatible^[GetNroJoueurNoirParNroRefPartie(nroPartie)] &
                                                 JoueurBlancCompatible^[GetNroJoueurBlancParNroRefPartie(nroPartie)]
                    else compatibiliteJoueurs := JoueurNoirCompatible^[GetNroJoueurNoirParNroRefPartie(nroPartie)] |
                                                 JoueurBlancCompatible^[GetNroJoueurBlancParNroRefPartie(nroPartie)];
                  compatibiliteDistribution   := DistributionCompatible^[GetNroDistributionParNroRefPartie(nroPartie)];

                  SetPartieCompatibleParCriteres(nroPartie, compatibiliteTournoi & compatibiliteJoueurs & compatibiliteDistribution);
                end;
            end
          else
            begin
              ANDentreJoueurs := (Noirs <> Blancs);
              for nroPartie := 1 to nbPartiesChargees do
                begin
                  if avecAnnees
                    then compatibiliteTournoi := TournoiCompatible^[GetNroTournoiParNroRefPartie(nroPartie)] & anneeCompatible[GetAnneePartieParNroRefPartie(nroPartie)]
                    else compatibiliteTournoi := TournoiCompatible^[GetNroTournoiParNroRefPartie(nroPartie)];
                  if ANDentreJoueurs
                    then compatibiliteJoueurs := JoueurNoirCompatible^[GetNroJoueurNoirParNroRefPartie(nroPartie)] &
                                                 JoueurBlancCompatible^[GetNroJoueurBlancParNroRefPartie(nroPartie)]
                    else compatibiliteJoueurs := JoueurNoirCompatible^[GetNroJoueurNoirParNroRefPartie(nroPartie)] |
                                                 JoueurBlancCompatible^[GetNroJoueurBlancParNroRefPartie(nroPartie)];
                  compatibiliteDistribution   := DistributionCompatible^[GetNroDistributionParNroRefPartie(nroPartie)];
                  compatibiliteOrdinateurs    := PartieEstSansOrdinateur(nroPartie);

                  SetPartieCompatibleParCriteres(nroPartie, compatibiliteTournoi & compatibiliteJoueurs & compatibiliteDistribution & compatibiliteOrdinateurs);
                end;
            end;

      end;

  DisposeTableJoueurCompatible(JoueurBlancCompatible);
  DisposeTableJoueurCompatible(JoueurNoirCompatible);
  DisposeTableTournoiCompatible(TournoiCompatible);
  DisposeTableDistributionCompatible(DistributionCompatible);

  tempsUtiliseDernierCalculDesCriteres := TickCount - tickDepart;

  RemettreLeCurseurNormalDeCassio;
end;  {CalculTableCriteres}




procedure DoCriteres;
var s : String255;

    function HumainVeutNouveauxCriteres : boolean;
    const
        CriteresID = 145;
        OK = 1;
        Annuler = 2;
        JoueurNoir1 = 3;
        JoueurNoir2 = 4;
        JoueurNoir3 = 5;
        JoueurNoir4 = 6;
        JoueurNoir5 = 7;
        JoueurNoir6 = 8;
        JoueurBlanc1 = 9;
        JoueurBlanc2 = 10;
        JoueurBlanc3 = 11;
        JoueurBlanc4 = 12;
        JoueurBlanc5 = 13;
        JoueurBlanc6 = 14;
        Tournoi1 = 15;
        Tournoi2 = 16;
        Tournoi3 = 17;
        Tournoi4 = 18;
        EffacerNoirBouton = 19;
        EffacerBlancBouton = 20;
        EffacerTournoiBouton = 21;
    var criteresdp : DialogPtr;
        itemHit : SInt16;
        err : OSErr;
        longCompl : SInt16;
        found : boolean;

        procedure EffacerNoir;
        var i : SInt32;
        begin
          for i := JoueurNoir1 to JoueurNoir6 do
            SetItemTextInDialog(criteresdp,i,'');
        end;

        procedure EffacerBlanc;
        var i : SInt32;
        begin
          for i := JoueurBlanc1 to JoueurBlanc6 do
            SetItemTextInDialog(criteresdp,i,'');
        end;

        procedure EffacerTournoi;
        var i : SInt32;
        begin
          for i := tournoi1 to Tournoi4 do
            SetItemTextInDialog(criteresdp,i,'');
        end;

        procedure SauveCriteres;
        var i : SInt32;
            s,s1 : String255;
        begin
          s := '';
          for i := JoueurNoir1 to JoueurNoir6 do
            begin
              GetItemTextInDialog(criteresdp,i,s1);
              s := s + s1+CharToString('ร');
            end;
          CriteresSuplementaires^^.CriteresNoir := s;
          s := '';
          for i := JoueurBlanc1 to JoueurBlanc6 do
            begin
              GetItemTextInDialog(criteresdp,i,s1);
              s := s + s1+CharToString('ร');
            end;
          CriteresSuplementaires^^.CriteresBlanc := s;
          s := '';
          for i := tournoi1 to Tournoi4 do
            begin
              GetItemTextInDialog(criteresdp,i,s1);
              s := s + s1+CharToString('ร');
            end;
          CriteresSuplementaires^^.CriteresTournoi := s;
        end;

        procedure MetCriteres;
        var i,t : SInt32;
            ligneCriteres,s : String255;
        begin
          ligneCriteres := CriteresSuplementaires^^.CriteresNoir;
          for i := JoueurNoir1 to JoueurNoir6 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              SetItemTextInDialog(criteresdp,i,s);
            end;

          ligneCriteres := CriteresSuplementaires^^.CriteresBlanc;
          for i := JoueurBlanc1 to JoueurBlanc6 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              SetItemTextInDialog(criteresdp,i,s);
            end;

          ligneCriteres := CriteresSuplementaires^^.CriteresTournoi;
          for i := tournoi1 to Tournoi4 do
            begin
              t := Pos('ร',ligneCriteres);
              s := TPCopy(ligneCriteres,1,t-1);
              DeleteString(ligneCriteres,1,t);
              SetItemTextInDialog(criteresdp,i,s);
            end;

        end;

    begin   {HumainVeutNouveauxCriteres}
      HumainVeutNouveauxCriteres := false;

      SwitchToScript(gLastScriptUsedInDialogs);
      BeginDialog;
      criteresdp := MyGetNewDialog(CriteresID);
      if criteresdp <> NIL then
      begin
        MetCriteres;
        err := SetDialogTracksCursor(criteresdp,true);
        repeat
          ModalDialog(MyFiltreClassiqueUPP,itemHit);
          case itemHit of
            JoueurNoir1..Tournoi4:
              begin
                GetItemTextInDialog(criteresdp,itemHit,s);
                if (s[LENGTH_OF_STRING(s)] = '=') & JoueursEtTournoisEnMemoire then
                  begin
                    s := TPCopy(s,1,LENGTH_OF_STRING(s)-1);
                    case itemHit of
                      JoueurNoir1..JoueurNoir6   : s := Complemente(complementationJoueurNoir, false,s,longCompl,found);
                      JoueurBlanc1..JoueurBlanc6 : s := Complemente(complementationJoueurBlanc,false,s,longCompl,found);
                      Tournoi1..Tournoi4         : s := Complemente(complementationTournoi,    false,s,longCompl,found);
                    end;
                    SetItemTextInDialog(criteresdp,itemHit,s);
                    SelectDialogItemText(criteresdp,itemHit,longCompl,MAXINT_16BITS);
                  end;
              end;
            EffacerNoirBouton    : EffacerNoir;
            EffacerBlancBouton   : EffacerBlanc;
            EffacerTournoiBouton : EffacerTournoi;
            OK                   : SauveCriteres;
          end;
        until (itemHit = OK) or (itemHit = Annuler);
        HumainVeutNouveauxCriteres := (itemHit = OK);
        MyDisposeDialog(criteresdp);
        MetCriteresDansRuban;
      end;
      EndDialog;
      GetCurrentScript(gLastScriptUsedInDialogs);
      SwitchToRomanScript;
    end;  {HumainVeutNouveauxCriteres}

begin  {DoCriteres}
  if problemeMemoireBase
    then DialogueMemoireBase
    else
      begin
        if (CriteresSuplementaires <> NIL) & HumainVeutNouveauxCriteres
          then
            begin
              InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
              sousSelectionActive := true;
              CalculTableCriteres;
              EcritRubanListe(false);
              LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
            end;
      end;
end;  {DoCriteres}


procedure DoChangeSousSelectionActive;
begin
  sousSelectionActive := not(sousSelectionActive);

  if not(problemeMemoireBase) then
    begin
		  if SousCriteresVides
		    then
		      begin
		        EcritRubanListe(true);
		        if nbPartiesActives = 0 then
		          begin
		            if windowListeOpen then EcritListeParties(false,'DoChangeSousSelectionActive');
		            if windowStatOpen  then EcritStatistiques(false);
		          end;
		      end
		    else
		      begin
		        InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
		        EcritRubanListe(true);
		        if not(sousSelectionActive) & InclurePartiesAvecOrdinateursDansListe
		          then
		            begin
		              LaveTableCriteres;
		              LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
		            end
		          else
		            begin
		              CalculTableCriteres;
		              LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
		            end;
		      end;
    end;
end;

procedure SetSousCriteresJoueursNoirs(s : String255);
begin
  if (CriteresSuplementaires <> NIL)
    then CriteresSuplementaires^^.CriteresNoir := s+'รรรรรร';

  if (SousCriteresRuban[JoueurNoirRubanBox] <> NIL)
    then TESetText(@s[1],LENGTH_OF_STRING(s),SousCriteresRuban[JoueurNoirRubanBox]);
end;


procedure SetSousCriteresJoueursBlancs(s : String255);
begin
  if (CriteresSuplementaires <> NIL) then
    CriteresSuplementaires^^.CriteresBlanc := s+'รรรรรร';

  if (SousCriteresRuban[JoueurBlancRubanBox] <> NIL)
    then TESetText(@s[1],LENGTH_OF_STRING(s),SousCriteresRuban[JoueurBlancRubanBox]);
end;


procedure SetSousCriteresTournois(s : String255);
begin
  if (CriteresSuplementaires <> NIL) then
    CriteresSuplementaires^^.CriteresTournoi := s+'รรรร';

  if (SousCriteresRuban[TournoiRubanBox] <> NIL)
    then TESetText(@s[1],LENGTH_OF_STRING(s),SousCriteresRuban[TournoiRubanBox]);
end;


procedure SetSousCriteresDistributions(s : String255);
begin
  if (CriteresSuplementaires <> NIL) then
    CriteresSuplementaires^^.CriteresDistribution := s+'รรรร';

  if (SousCriteresRuban[DistributionRubanBox] <> NIL)
    then TESetText(@s[1],LENGTH_OF_STRING(s),SousCriteresRuban[DistributionRubanBox]);
end;


procedure ValiderSousCritereRuban;
var i,longueur : SInt32;
    s : String255;
    caract : charsHandle;
begin
  if windowListeOpen & (CriteresSuplementaires <> NIL) then
    begin
      if CriteresRubanModifies then
        begin
          longueur := TEGetTextLength(SousCriteresRuban[TournoiRubanBox]);
          if longueur > 245 then longueur := 245;
          caract := TEGetText(SousCriteresRuban[TournoiRubanBox]);
          s := ''; for i := 1 to longueur do s := s + caract^^[i-1];
          SetSousCriteresTournois(s);

          longueur := TEGetTextLength(SousCriteresRuban[JoueurNoirRubanBox]);
          if longueur > 245 then longueur := 245;
          caract := TEGetText(SousCriteresRuban[JoueurNoirRubanBox]);
          s := ''; for i := 1 to longueur do s := s + caract^^[i-1];
          SetSousCriteresJoueursNoirs(s);

          longueur := TEGetTextLength(SousCriteresRuban[JoueurBlancRubanBox]);
          if longueur > 245 then longueur := 245;
          caract := TEGetText(SousCriteresRuban[JoueurBlancRubanBox]);
          s := ''; for i := 1 to longueur do s := s + caract^^[i-1];
          SetSousCriteresJoueursBlancs(s);

          longueur := TEGetTextLength(SousCriteresRuban[DistributionRubanBox]);
          if longueur > 245 then longueur := 245;
          caract := TEGetText(SousCriteresRuban[DistributionRubanBox]);
          s := ''; for i := 1 to longueur do s := s + caract^^[i-1];
          SetSousCriteresDistributions(s);
        end;

      BoiteDeSousCritereActive := 0;
      PasseListeEnModeEntree(BoiteDeSousCritereActive);

      if CriteresRubanModifies
        then
          begin
            InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
            sousSelectionActive := not(SousCriteresVides);
            EcritRubanListe(false);
            CalculTableCriteres;
            LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
          end
        else
          begin
            if SousCriteresVides then
              begin
                sousSelectionActive := false;
                EcritRubanListe(false);
                if nbPartiesActives <= 0 then
                  begin
                    CalculTableCriteres;
                    LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
                  end;
              end;
          end;
    end;
end;

procedure AnnulerSousCriteresRuban;
begin
  if windowListeOpen then
    if BoiteDeSousCritereActive <> 0 then
      begin
        MetCriteresDansRuban;
        if SousCriteresVides then sousSelectionActive := false;
        EcritRubanListe(true);
        if nbPartiesActives <= 0 then
          begin
            CalculTableCriteres;
            LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
          end;
        GetCurrentScript(gLastScriptUsedInDialogs);
        SwitchToRomanScript;
      end;
end;

procedure DoSwaperLesSousCriteres;
var StringAux : String255;
    nroBoiteDeSousCritereActive : SInt32;
begin
  if not(problemeMemoireBase) & (CriteresSuplementaires <> NIL) then
	  if (CriteresSuplementaires^^.CriteresNoir <> CriteresSuplementaires^^.CriteresBlanc) then
	    begin
	      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
	
	      stringAux := CriteresSuplementaires^^.CriteresNoir;
	      CriteresSuplementaires^^.CriteresNoir := CriteresSuplementaires^^.CriteresBlanc;
	      CriteresSuplementaires^^.CriteresBlanc := stringAux;
	      nroBoiteDeSousCritereActive := BoiteDeSousCritereActive;

	      MetCriteresDansRuban;
	      CriteresRubanModifies := true;
	      sousSelectionActive := true;
	      PasseListeEnModeEntree(nroBoiteDeSousCritereActive);
	      CalculTableCriteres;
	      LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
	    end;
end;


procedure DoNegationnerLesSousCriteres;
var stringAux : String255;
    nroBoiteDeSousCritereActive : SInt32;
    strings : array[1..6] of String255;
    i : SInt16;
begin
  if not(problemeMemoireBase) & (CriteresSuplementaires <> NIL) then
	  if not(SousCriteresVides) then
	    begin
	      InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;

	      stringAux := CriteresSuplementaires^^.CriteresNoir;
	      ParserSousCriteresDeJoueurs(stringAux,strings[1],strings[2],strings[3],strings[4],strings[5],strings[6]);
	      CriteresSuplementaires^^.CriteresNoir := '';
	      for i := 1 to 6 do
	        begin
	          if (strings[i] <> '') then
	            if (strings[i][1] <> 'ญ')
	              then strings[i] := 'ญ' + strings[i]
	              else strings[i] := TPCopy(strings[i],2,LENGTH_OF_STRING(strings[i]) - 1);
	          CriteresSuplementaires^^.CriteresNoir := CriteresSuplementaires^^.CriteresNoir + strings[i] + 'ร';
	        end;

	      stringAux := CriteresSuplementaires^^.CriteresBlanc;
	      ParserSousCriteresDeJoueurs(stringAux,strings[1],strings[2],strings[3],strings[4],strings[5],strings[6]);
	      CriteresSuplementaires^^.CriteresBlanc := '';
	      for i := 1 to 6 do
	        begin
	          if (strings[i] <> '') then
	            if (strings[i][1] <> 'ญ')
	              then strings[i] := 'ญ' + strings[i]
	              else strings[i] := TPCopy(strings[i],2,LENGTH_OF_STRING(strings[i]) - 1);
	          CriteresSuplementaires^^.CriteresBlanc := CriteresSuplementaires^^.CriteresBlanc + strings[i] + 'ร';
	        end;

	      stringAux := CriteresSuplementaires^^.CriteresTournoi;
	      ParserSousCriteresDeTournois(stringAux,strings[1],strings[2],strings[3],strings[4]);
	      CriteresSuplementaires^^.CriteresTournoi := '';
	      for i := 1 to 4 do
	        begin
	          if (strings[i] <> '') then
	            if (strings[i][1] <> 'ญ')
	              then strings[i] := 'ญ' + strings[i]
	              else strings[i] := TPCopy(strings[i],2,LENGTH_OF_STRING(strings[i]) - 1);
	          CriteresSuplementaires^^.CriteresTournoi := CriteresSuplementaires^^.CriteresTournoi + strings[i] + 'ร';
	        end;

	      stringAux := CriteresSuplementaires^^.CriteresDistribution;
	      ParserSousCriteresDeDistributions(stringAux,strings[1],strings[2],strings[3],strings[4]);
	      CriteresSuplementaires^^.CriteresDistribution := '';
	      for i := 1 to 4 do
	        begin
	          if (strings[i] <> '') then
	            if (strings[i][1] <> 'ญ')
	              then strings[i] := 'ญ' + strings[i]
	              else strings[i] := TPCopy(strings[i],2,LENGTH_OF_STRING(strings[i]) - 1);
	          CriteresSuplementaires^^.CriteresDistribution := CriteresSuplementaires^^.CriteresDistribution + strings[i] + 'ร';
	        end;

	      MetCriteresDansRuban;
	      CriteresRubanModifies := true;
	      sousSelectionActive := true;
	      PasseListeEnModeEntree(nroBoiteDeSousCritereActive);
	      CalculTableCriteres;
	      LanceCalculsRapidesPourBaseOuNouvelleDemande(false,false);
	    end;
end;


function NewTableJoueurCompatiblePtr : t_JoueurCompatible;
begin
  NewTableJoueurCompatiblePtr := t_JoueurCompatible(AllocateMemoryPtrClear(sizeof(t_JoueurCompatibleArray)));
end;

function NewTableTournoiCompatiblePtr : t_TournoiCompatible;
begin
  NewTableTournoiCompatiblePtr := t_TournoiCompatible(AllocateMemoryPtrClear(sizeof(t_TournoiCompatibleArray)));
end;

function NewTableDistributionsCompatiblesPtr : t_DistributionCompatible;
begin
  NewTableDistributionsCompatiblesPtr := t_DistributionCompatible(AllocateMemoryPtrClear(sizeof(t_DistributionCompatibleArray)));
end;

function NewTableScoreCompatiblePtr : t_ScoreCompatible;
begin
  NewTableScoreCompatiblePtr := t_ScoreCompatible(AllocateMemoryPtrClear(sizeof(t_ScoreCompatibleArray)));
end;

procedure DisposeTableJoueurCompatible(var table : t_JoueurCompatible);
begin
  if (table <> NIL) then DisposeMemoryPtr(Ptr(table));
  table := NIL;
end;

procedure DisposeTableTournoiCompatible(var table : t_TournoiCompatible);
begin
  if (table <> NIL) then DisposeMemoryPtr(Ptr(table));
  table := NIL;
end;

procedure DisposeTableDistributionCompatible(var table : t_DistributionCompatible);
begin
  if (table <> NIL) then DisposeMemoryPtr(Ptr(table));
  table := NIL;
end;

procedure DisposeTableScoreCompatible(var table : t_ScoreCompatible);
begin
  if (table <> NIL) then DisposeMemoryPtr(Ptr(table));
  table := NIL;
end;

function TransformePourPerfectMatch(s : String255) : String255;
var result : String255;
begin
  result := s;

  if (s <> '') then
    begin

      if (result[1] = '"')
        then result[1] := '^';

      if (result[LENGTH_OF_STRING(result)] = '"')
        then result[LENGTH_OF_STRING(result)] := '$';

      if (result[1] <> '^')
        then result := '^' + result;

      if (result[LENGTH_OF_STRING(result)] <> '$')
        then result := result + '$';

    end;

  TransformePourPerfectMatch := result;
end;


end.
