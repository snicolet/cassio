UNIT UnitClassement;


INTERFACE







 USES UnitDefCassio;



procedure EpoquesDesJoueursDeLaListe;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitAccesNouveauFormat, UnitListe, UnitRapport, MyStrings ;
{$ELSEC}
    {$I prelink/Classement.lk}
{$ENDC}


{END_USE_CLAUSE}













type InfosClassementJoueurRec =
       record
         cumulPartie : SInt32;   { nombre de parties jouees par le joueur jusqu'a cette annee-la }
         classment : double_t;
       end;

var InfosClassement : array[0..0] of InfosClassementJoueurRec;  {une entree pour chaque annee active de chaque joueur}


var nbPartiesPrisesEnComptePourLeClassement : SInt32;


function ClassementCalculablePourCettePartie(numeroDansLaListe,numeroRefPartie : SInt32; var tickGroupe : SInt32) : boolean;
var joueurNoir,joueurBlanc  : SInt32;
    ok : boolean;
begin  {$UNUSED numeroDansLaListe,tickGroupe}
  ok := (numeroRefPartie >= 1) & (numeroRefPartie <= nbPartiesActives);
  if ok then
    begin
      joueurNoir  := GetNroJoueurNoirParNroRefPartie (numeroRefPartie);
      joueurBlanc := GetNroJoueurBlancParNroRefPartie(numeroRefPartie);

      {une partie est classable si aucun des deux joueurs n'est inconnu,
       et si Noir et Blancs sont deux joueurs differents (pour eviter les
       parties d'entrainement d'un programme contre lui-meme) }

      ok := (joueurNoir > 0) & (joueurBlanc > 0) & (joueurNoir <> joueurBlanc);
    end;

  {if Pos('Busut',GetNomJoueur(GetNroJoueurNoirParNroRefPartie(numeroRefPartie))) > 0 then
    begin
      WritelnStringAndBoolDansRapport(GetNomJoueur(GetNroJoueurNoirParNroRefPartie(numeroRefPartie)) + ' - ' +
                         GetNomJoueur(GetNroJoueurBlancParNroRefPartie(numeroRefPartie))+ ', '+
                         NumEnString(GetAnneePartieParNroRefPartie(numeroRefPartie))+'  => OK = ',ok);
    end;}

  ClassementCalculablePourCettePartie := ok;
end;


procedure UpdateAnneesActivitesDesJoueurs(var partie60 : PackedThorGame; numeroRefPartie : SInt32; var nbPartiesUtilisees : SInt32);
var anneePartie : SInt32;
    noir,blanc : SInt32;
    anneeDebut,anneeArret : SInt32;
    afficheInfos : boolean;
begin
  {$UNUSED partie60}

  inc(nbPartiesUtilisees);

  noir        := GetNroJoueurNoirParNroRefPartie(numeroRefPartie);
  blanc       := GetNroJoueurBlancParNroRefPartie(numeroRefPartie);
  anneePartie := GetAnneePartieParNroRefPartie(numeroRefPartie);

  afficheInfos := false;
  {afficheInfos := Pos('Busut',GetNomJoueur(noir)) > 0;}
  if afficheInfos then
    begin
      WritelnDansRapport(GetNomJoueur(noir) + ' - ' + GetNomJoueur(blanc)+ ', '+NumEnString(anneePartie));
      WritelnNumDansRapport('nro de Noir = ',noir);
      WritelnNumDansRapport('nro de Blanc = ',blanc);
    end;

  anneeDebut  := GetAnneePremierePartieDeCeJoueur(noir);

  if afficheInfos then WritelnNumDansRapport('anneeDebut de Noir = ',anneeDebut);

  if (anneeDebut < 0) | {non initialise ? }
     (anneePartie < anneeDebut)
     then SetAnneePremierePartieDeCeJoueur(noir,anneePartie);



  anneeArret  := GetAnneeDernierePartieDeCeJoueur(noir);

  if afficheInfos then WritelnNumDansRapport('anneeArret de Noir = ',anneeArret);

  if (anneeArret < 0) | {non initialise ? }
     (anneePartie > anneeArret)
     then SetAnneeDernierePartieDeCeJoueur(noir,anneePartie);


  anneeDebut  := GetAnneePremierePartieDeCeJoueur(blanc);

  if afficheInfos then WritelnNumDansRapport('anneeDebut de Blanc = ',anneeDebut);

  if (anneeDebut < 0) | {non initialise ? }
     (anneePartie < anneeDebut)
     then SetAnneePremierePartieDeCeJoueur(blanc,anneePartie);

  anneeArret  := GetAnneeDernierePartieDeCeJoueur(blanc);

  if afficheInfos then WritelnNumDansRapport('anneeArret de Blanc = ',anneeArret);

  if (anneeArret < 0) | {non initialise ? }
     (anneePartie > anneeArret)
     then SetAnneeDernierePartieDeCeJoueur(blanc,anneePartie);

end;






procedure EpoquesDesJoueursDeLaListe;
var nbJoueurs,activite : SInt32;
    nbJoueursActifs : SInt32;
    activiteDeCeJoueur : SInt32;
    emplacementDansTableClassement : SInt32;
    i : SInt32;
begin

  nbPartiesPrisesEnComptePourLeClassement := 0;

  ForEachGameInListDo(ClassementCalculablePourCettePartie,bidFiltreGameProc,UpdateAnneesActivitesDesJoueurs,nbPartiesPrisesEnComptePourLeClassement);

  WritelnNumDansRapport('nbPartiesPrisesEnComptePourLeClassement = ',nbPartiesPrisesEnComptePourLeClassement);

  activite := 0;
  nbJoueursActifs := 0;
  nbJoueurs := JoueursNouveauFormat.nbJoueursNouveauFormat;
  for i := 1 to nbJoueurs do
    begin
      if GetAnneePremierePartieDeCeJoueur(i) > 0
        then
	        begin
	          {if Pos('Busut',GetNomJoueur(i)) > 0 then
		          begin
		            WritelnNumDansRapport(GetNomJoueur(i)+ ' : actif , nro = ',i);
		            WritelnNumDansRapport('annee debut de ce joueur = ',GetAnneePremierePartieDeCeJoueur(i));
		          end;}

	          inc(nbJoueursActifs);
	          activiteDeCeJoueur := GetNbreAnneesActiviteDeCeJoueur(i);
	          activite := activite + activiteDeCeJoueur;

	          if (activiteDeCeJoueur > 7) then
	            begin
	              WriteDansRapport('Le joueur '+GetNomJoueur(i) + ' a été actif pendant '+NumEnString(activiteDeCeJoueur)+ ' années :');
	              WritelnDansRapport(Concat('     ', NumEnString(GetAnneePremierePartieDeCeJoueur(i)), ' - ', NumEnString(GetAnneeDernierePartieDeCeJoueur(i))));
	            end;
	        end
		    else
		      begin
		        {if Pos('Busut',GetNomJoueur(i)) > 0 then
		          begin
		            WritelnNumDansRapport(GetNomJoueur(i)+ ' : inactif , nro = ',i);
		            WritelnNumDansRapport('annee debut de ce joueur = ',GetAnneePremierePartieDeCeJoueur(i));
		          end;}
		      end;
    end;

  WritelnDansRapport('Il y a '+NumEnString(nbJoueursActifs)+' joueurs actifs dans la base.');
  WritelnDansRapport('Il y a '+NumEnString(nbJoueurs - nbJoueursActifs)+' joueurs inactifs dans la base.');
  if nbJoueursActifs > 0 then
    WritelnDansRapport('En moyenne, chaque joueur est actif '+ReelEnString(activite * 1.0 / nbJoueursActifs) + ' années.');


  for i := 0 to nbJoueurs do
    begin
      SetDonneesClassementDeCeJoueur(i,-1);

      emplacementDansTableClassement := 0;
      activiteDeCeJoueur := GetNbreAnneesActiviteDeCeJoueur(i);
      if activiteDeCeJoueur > 0 then
        begin
          {Les donnees pour les annees d'activite du joueur i commenceront à emplacementDansTableClassement}
          SetDonneesClassementDeCeJoueur(i,emplacementDansTableClassement);

          {Et on prépare l'emplacement pour les joueurs suivants }
          emplacementDansTableClassement := emplacementDansTableClassement + GetNbreAnneesActiviteDeCeJoueur(i);
        end;
    end;

end;



END.
