UNIT UnitSelectionRapideListe;


INTERFACE







 USES UnitDefCassio;




{Initialisation de l'unite}
procedure InitUnitSelectionRapideListe;                                                                                                                                             ATTRIBUTE_NAME('InitUnitSelectionRapideListe')
procedure LibereMemoireUnitSelectionRapideListe;                                                                                                                                    ATTRIBUTE_NAME('LibereMemoireUnitSelectionRapideListe')


{gestion de l'historique des evenements de clavier}
procedure EnregisterToucheClavier(c : char; when : SInt32);                                                                                                                         ATTRIBUTE_NAME('EnregisterToucheClavier')
function EstEnAttenteSelectionRapideDeListe : boolean;                                                                                                                              ATTRIBUTE_NAME('EstEnAttenteSelectionRapideDeListe')


{acces aux demandes de selection rapide trouvees}
function GetDerniereChaineSelectionRapide : String255;                                                                                                                              ATTRIBUTE_NAME('GetDerniereChaineSelectionRapide')
function GetDernierGenreSelectionRapide : typeSelectionRapide;                                                                                                                      ATTRIBUTE_NAME('GetDernierGenreSelectionRapide')
procedure SetDerniereChaineSelectionRapide(s : String255);                                                                                                                          ATTRIBUTE_NAME('SetDerniereChaineSelectionRapide')
procedure SetDernierGenreSelectionRapide(genre : typeSelectionRapide);                                                                                                              ATTRIBUTE_NAME('SetDernierGenreSelectionRapide')


{gestion des demandes de selection rapide}
procedure TraiteSelectionRapideDeListe(genre : typeSelectionRapide; chaineCherchee : String255);                                                                                    ATTRIBUTE_NAME('TraiteSelectionRapideDeListe')





IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitUtilitaires, UnitCriteres, UnitAccesNouveauFormat, MyStrings ;
{$ELSEC}
    ;
    {$I prelink/SelectionRapideListe.lk}
{$ENDC}


{END_USE_CLAUSE}










const
  kTailleHistorique = 32;

var
  historiqueFrappeSelectionRapide:
      record
        cardinal : SInt32;
        liste : array [1..kTailleHistorique] of
					        record
					          caractere : char;
					          tick : SInt32; {tick de la frappe}
					        end;
				derniereChaineConstruite : String255;
				dernierGenreSelection : typeSelectionRapide;
	    end;

procedure InitUnitSelectionRapideListe;
var i : SInt32;
begin
  historiqueFrappeSelectionRapide.cardinal := 0;
  for i := 1 to kTailleHistorique do
    begin
      historiqueFrappeSelectionRapide.liste[i].caractere := chr(0);
      historiqueFrappeSelectionRapide.liste[i].tick := 0;
    end;
  SetDerniereChaineSelectionRapide('');
  SetDernierGenreSelectionRapide(kAucuneSelectionRapide);
end;


procedure LibereMemoireUnitSelectionRapideListe;
begin
end;


procedure EnregisterToucheClavier(c : char; when : SInt32);
var i : SInt32;
begin
  with historiqueFrappeSelectionRapide do
    begin
      if cardinal >= kTailleHistorique
        then {on est plein}
          begin
            for i := 1 to kTailleHistorique-1 do
              liste[i] := liste[i+1];
            cardinal := kTailleHistorique;
            with liste[cardinal] do
			        begin
			          caractere := c;
			          tick      := when;
			        end;
          end
        else  {on ajoute simplement}
          begin
            inc(cardinal);
			      with liste[cardinal] do
			        begin
			          caractere := c;
			          tick      := when;
			        end;
			    end;
    end;
end;

const kIntervalleFrappeRapide = 80; {80 ticks = 1,2 seconde}

function EstEnAttenteSelectionRapideDeListe : boolean;
var i,tickCourant,t1,t2,tickLastCaractere : SInt32;
    c1,c2 : char;
    chaine : String255;

  procedure EssaieConstruireChaineSelectionRapide(quelGenre : typeSelectionRapide);
  var k : SInt32;
      frappeRapide : boolean;
  begin
    with historiqueFrappeSelectionRapide do
      begin
		    chaine := '';
		    frappeRapide := true;
		    for k := i+1 to cardinal do
		      begin
		        frappeRapide := frappeRapide &
		                        ((liste[k].tick - liste[k-1].tick) <= kIntervalleFrappeRapide);
		        if frappeRapide then
			        chaine := Concat(chaine,liste[k].caractere);
			    end;
		    if (chaine <> '') then  {trouve!}
		      begin
		        derniereChaineConstruite := chaine;
		        dernierGenreSelection := quelGenre;

		        {SysBeep(0);}
		        {
		        if frappeRapide then
		        WritelnStringAndBoolDansRapport(Concat(chaine,', frappeRapide = '),frappeRapide);
		        }

		        if frappeRapide then
		          begin
				        EstEnAttenteSelectionRapideDeListe := true;
				        exit(EstEnAttenteSelectionRapideDeListe);
				      end;
		      end;
		  end;
  end;

begin  {EstEnAttenteSelectionRapideDeListe}

  {pas trouve par defaut}
  chaine := '';
  EstEnAttenteSelectionRapideDeListe := false;

  with historiqueFrappeSelectionRapide do
    begin
      tickCourant := TickCount;
      if ((cardinal-1) >= 1)
        then tickLastCaractere := liste[cardinal-1].tick
        else tickLastCaractere := 0;
      for i := 2 to cardinal do
        begin
          c1 := liste[i-1].caractere;
          t1 := liste[i-1].tick;
          c2 := liste[i].caractere;
          t2 := liste[i].tick;

          if (c1 = 'j') & (c2 = 'n') & ((t2-t1) <= 15) &
             ((tickCourant-t2) <= 600) &
             ((tickCourant - tickLastCaractere) <= kIntervalleFrappeRapide) then
            EssaieConstruireChaineSelectionRapide(kSelRapideNoir);

          if (c1 = 'j') & (c2 = 'b') & ((t2-t1) <= 15) &
             ((tickCourant-t2) <= 600) &
             ((tickCourant - tickLastCaractere) <= kIntervalleFrappeRapide) then
            EssaieConstruireChaineSelectionRapide(kSelRapideBlanc);

          if (c1 = 't') & (c2 = 'n') & ((t2-t1) <= 15) &
             ((tickCourant-t2) <= 600) &
             ((tickCourant - tickLastCaractere) <= kIntervalleFrappeRapide) then
            EssaieConstruireChaineSelectionRapide(kSelRapideTournoi);
        end;


    end;
end;


function GetDerniereChaineSelectionRapide : String255;
begin
  GetDerniereChaineSelectionRapide := historiqueFrappeSelectionRapide.derniereChaineConstruite;
end;


function GetDernierGenreSelectionRapide : typeSelectionRapide;
begin
  GetDernierGenreSelectionRapide := historiqueFrappeSelectionRapide.dernierGenreSelection;
end;


procedure SetDerniereChaineSelectionRapide(s : String255);
begin
  historiqueFrappeSelectionRapide.derniereChaineConstruite := s;
end;


procedure SetDernierGenreSelectionRapide(genre : typeSelectionRapide);
begin
  historiqueFrappeSelectionRapide.dernierGenreSelection := genre;
end;


procedure TraiteSelectionRapideDeListe(genre : typeSelectionRapide; chaineCherchee : String255);
var TournoiCompatible : t_TournoiCompatible;
    JoueurBlancCompatible : t_JoueurCompatible;
    JoueurNoirCompatible : t_JoueurCompatible;
    i,partieTrouvee : SInt32;
    longueur : SInt16;
    found : boolean;
begin
  if (nbPartiesActives > 1) & windowListeOpen then
    begin
		  chaineCherchee := EnleveEspacesDeGauche(chaineCherchee);
		  if (genre <> kAucuneSelectionRapide) {& (chaineCherchee <> '')} then
		    begin
		      partieTrouvee := -1;
		      case genre of
		        kSelRapideTournoi:
		          begin
		            sousCritereMustBeAPerfectMatch[TournoiRubanBox] := false;
		            
							  TournoiCompatible     := NewTableTournoiCompatiblePtr;
		            if (chaineCherchee[LENGTH_OF_STRING(chaineCherchee)] = '=') then
		              begin
		                chaineCherchee := TPCopy(chaineCherchee,1,LENGTH_OF_STRING(chaineCherchee)-1);
		                chaineCherchee := Complemente(complementationTournoi,false,chaineCherchee,longueur, found);
		                if found then chaineCherchee := TransformePourPerfectMatch(chaineCherchee);
		              end;
		            {WritelnDansRapport('demande tournoi : '+chaineCherchee);}

		            RemplitTableCompatibleTournoiAvecCeBooleen(TournoiCompatible,false);
		            CalculeTableTournoisCompatibles(chaineCherchee,TournoiCompatible,0);

		            SetSousCriteresTournois(chaineCherchee);

		            for i := 1 to nbPartiesActives do
		              if TournoiCompatible^[GetNroTournoiParNroRefPartie(tableNumeroReference^^[i])] then
		                begin
		                  partieTrouvee := i;

		                  leave;
		                end;
							  DisposeTableTournoiCompatible(TournoiCompatible);
		          end;
		        kSelRapideNoir:
		          begin
		            sousCritereMustBeAPerfectMatch[JoueurNoirRubanBox] := false;
		            
							  JoueurNoirCompatible  := NewTableJoueurCompatiblePtr;
		            if (chaineCherchee[LENGTH_OF_STRING(chaineCherchee)] = '=') then
		              begin
		                chaineCherchee := TPCopy(chaineCherchee,1,LENGTH_OF_STRING(chaineCherchee)-1);
		                chaineCherchee := Complemente(complementationJoueurNoir,false,chaineCherchee,longueur, found);
		                if found then chaineCherchee := TransformePourPerfectMatch(chaineCherchee);
		              end;
		            {WritelnDansRapport('demande joueur noir : '+chaineCherchee);}

		            RemplitTableCompatibleJoueurAvecCeBooleen(JoueurNoirCompatible,false);
		            CalculeTableJoueursCompatibles(chaineCherchee,JoueurNoirCompatible,0);

		            SetSousCriteresJoueursNoirs(chaineCherchee);

		            for i := 1 to nbPartiesActives do
		              if JoueurNoirCompatible^[GetNroJoueurNoirParNroRefPartie(tableNumeroReference^^[i])] then
		                begin
		                  partieTrouvee := i;

		                  leave;
		                end;
							  DisposeTableJoueurCompatible(JoueurNoirCompatible);
		          end;
		        kSelRapideBlanc:
		          begin
		            sousCritereMustBeAPerfectMatch[JoueurBlancRubanBox] := false;
		            
		            JoueurBlancCompatible := NewTableJoueurCompatiblePtr;
		            if (chaineCherchee[LENGTH_OF_STRING(chaineCherchee)] = '=') then
		              begin
		                chaineCherchee := TPCopy(chaineCherchee,1,LENGTH_OF_STRING(chaineCherchee)-1);
		                chaineCherchee := Complemente(complementationJoueurBlanc, false, chaineCherchee, longueur, found);
		                if found then chaineCherchee := TransformePourPerfectMatch(chaineCherchee);
		              end;
		            {WritelnDansRapport('demande joueur blanc : ' + chaineCherchee); }

		            RemplitTableCompatibleJoueurAvecCeBooleen(JoueurBlancCompatible,false);
		            CalculeTableJoueursCompatibles(chaineCherchee,JoueurBlancCompatible,0);

		            SetSousCriteresJoueursBlancs(chaineCherchee);

		            for i := 1 to nbPartiesActives do
		              if JoueurBlancCompatible^[GetNroJoueurBlancParNroRefPartie(tableNumeroReference^^[i])] then
		                begin
		                  partieTrouvee := i;

		                  leave;
		                end;
		            DisposeTableJoueurCompatible(JoueurBlancCompatible);
		          end;
		      end; {case}

		      if (partieTrouvee <> -1) then
		        begin
				      ChangePartieHilitee(partieTrouvee,infosListeParties.partieHilitee);
				      SetPartieHiliteeEtAjusteAscenseurListe(partieTrouvee);
				      {EcritListeParties(true,'TraiteSelectionRapideDeListe');}
				    end;

				  InvalidateNombrePartiesActivesDansLeCachePourTouteLaPartie;
          sousSelectionActive := not(SousCriteresVides);
          EcritRubanListe(false);
          CalculTableCriteres;
          LanceCalculsRapidesPourBaseOuNouvelleDemande(false,true);
		    end;
		end;
end;


END.
