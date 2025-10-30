UNIT UnitBaseOfficielle;



INTERFACE


 USES UnitDefCassio;



{Interface de commande}
function DoActionGestionBaseOfficielle(commande : String255) : OSErr;
procedure CreerOuRenommerMachinDansLaBaseOfficielle;
procedure CreerPlusieursJoueursDansBaseOfficielle;
procedure CreerPlusieursTournoisDansBaseOfficielle;


{Fonction d'acces en lecture aux listes de joueurs et de tournois}
function FindPlayerDansBaseOfficielle(joueur : String255) : OSErr;
function FindTournamentDansBaseOfficielle(tournoi : String255) : OSErr;
function ListerDerniersJoueursBaseOfficielleDansRapport(nbreJoueurs : SInt32) : OSErr;
function ListerDerniersTournoisBaseOfficielleDansRapport(nbreTournois : SInt32) : OSErr;
function JoueurEstDonneParSonNumero(joueur : String255; var outNumber : SInt32) : boolean;
function TournoiEstDonneParSonNumero(tournoi : String255; var outNumber : SInt32) : boolean;


{Les actions de creation/renommage de joueurs et de tournois}
function RenommerJoueurDansFichierWThorOfficiel(oldName,newName : String255) : OSErr;
function RenommerTournoiDansFichierWThorOfficiel(oldName,newName : String255) : OSErr;
procedure ChangeBlackPlayer(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroNoir : SInt32);
procedure ChangeWhitePlayer(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroBlanc : SInt32);
procedure ChangeTournament(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroTournoi : SInt32);
procedure ChangeYear(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var anneePartie : SInt32);


{Calcul des scores theoriques}
procedure LancerInterruptionPourCalculerScoresTheoriquesPartiesDansListe;
procedure CalculeScoreTheorique(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var scoreTheoriquePourNoir : SInt32);
function CalculDesScoresTheoriquesDeLaBaseEnCours : boolean;
procedure SetCalculDesScoresTheoriquesDeLaBaseEnCours(newValue : boolean; oldValue : booleanPtr);


{Modifications des infos dans les parties de la liste}
function ChangeNumerosJoueursEtTournoisDansListe(noir,blanc,tournoi : String255; surQuellesParties : FiltreNumRefProc) : OSErr;
function ChangeAnneeDansListe(annee : SInt32; surQuellesParties : FiltreNumRefProc) : OSErr;
function CalculerScoresTheoriquesPartiesDansListe(apresQuelCoup : SInt32; endgameSolveFlags : SInt32; surQuellesParties : FiltreNumRefProc) : OSErr;


{Gestion du fichier "Database/Gestion base Wthor/WThor.log"}
function OuvreFichierTraceWThor : OSErr;
function FermeFichierTraceWThor : OSErr;
procedure WriteInTraceWThorLog(s : String255);


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, fp
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitRapport, UnitRapportImplementation, UnitNouveauFormat, UnitServicesDialogs, UnitGestionDuTemps, UnitZoo
    , UnitPositionEtTraitSet, UnitImportDesNoms, MyStrings, UnitAccesNouveauFormat, UnitEntreesSortiesListe, UnitSolve, basicfile, UnitPhasesPartie
    , MyMathUtils, UnitRapportWindow, UnitPositionEtTrait, UnitListe, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/BaseOfficielle.lk}
{$ENDC}


{END_USE_CLAUSE}












var FichierWThorLog : basicfile;
    gInfosCalculScoresTheoriques : record
                                     apresQuelCoup                : SInt32;
                                     endgameSolveFlags            : SInt32;
                                     tickDepart                   : SInt32;  {en ticks}
                                     nbCalculsAFaire              : SInt32;
                                     nbPartiesCalculees           : SInt32;
                                     nbPartiesImpossibles         : SInt32;
                                     numeroReferencePartieEnCours : SInt32;
                                     tempsMoyenParPartie          : double;  {en secondes}
                                     tempsRestantEstime           : double;  {en secondes}
                                     positionsDejaCherchees       : PositionEtTraitSet;
                                     enCours                      : boolean;
                                   end;


function OuvreFichierTraceWThor : OSErr;
var erreurES : OSErr;
begin
  erreurES := FileExists(PathDuDossierDatabase + ':Gestion Base WThor:WThor.log',0,FichierWThorLog);
  if erreurES = fnfErr then {-43 => fichier non trouvé, on le crée}
    begin
      erreurES := CreateFile(PathDuDossierDatabase + ':Gestion Base WThor:WThor.log',0,FichierWThorLog);
      SetFileCreatorFichierTexte(FichierWThorLog,MY_FOUR_CHAR_CODE('R*ch'));  {BBEdit}
      SetFileTypeFichierTexte(FichierWThorLog,MY_FOUR_CHAR_CODE('TEXT'));
    end;
  if erreurES = NoErr then
    erreurES := OpenFile(FichierWThorLog);
  OuvreFichierTraceWThor := erreurES;
end;

function FermeFichierTraceWThor : OSErr;
begin
  FermeFichierTraceWThor := CloseFile(FichierWThorLog);
end;


procedure WriteInTraceWThorLog(s : String255);
var erreurES : OSErr;
    oldEcritureDansLog : boolean;
    oldDebuggageUnitFichierTexte : boolean;
begin
  oldDebuggageUnitFichierTexte := GetDebuggageUnitFichiersTexte;
  oldEcritureDansLog := GetEcritToutDansRapportLog;

  SetDebuggageUnitFichiersTexte(false);
  SetEcritToutDansRapportLog(false);

  s := '     ' + s;

  erreurES := OuvreFichierTraceWThor;
  if (erreurES = NoErr) then erreurES := SetFilePositionAtEnd(FichierWThorLog);
  if (erreurES = NoErr) then erreurES := Writeln(FichierWThorLog,s);
  WritelnDansRapport(s);
  if (erreurES = NoErr) then erreurES := FermeFichierTraceWThor;

  SetDebuggageUnitFichiersTexte(oldDebuggageUnitFichierTexte);
  SetEcritToutDansRapportLog(oldEcritureDansLog);
end;



function JoueurEstDonneParSonNumero(joueur : String255; var outNumber : SInt32) : boolean;
begin
  if (LENGTH_OF_STRING(joueur) >= 2) and (joueur[1] = '#')
    then
      begin
        JoueurEstDonneParSonNumero := true;
        StrToInt32(RightStr(joueur,LENGTH_OF_STRING(joueur) - 1),outNumber);
      end
    else
      JoueurEstDonneParSonNumero := false;
end;


function TournoiEstDonneParSonNumero(tournoi : String255; var outNumber : SInt32) : boolean;
begin
  if (LENGTH_OF_STRING(tournoi) >= 2) and (tournoi[1] = '#')
    then
      begin
        TournoiEstDonneParSonNumero := true;
        StrToInt32(RightStr(tournoi,LENGTH_OF_STRING(tournoi) - 1),outNumber);
      end
    else
      TournoiEstDonneParSonNumero := false;
end;


function RenommerJoueurDansFichierWThorOfficiel(oldName,newName : String255) : OSErr;
label sortie;
var err : OSErr;
    entete : t_EnTeteNouveauFormat;
    joueur : t_JoueurRecNouveauFormat;
    fic : basicfile;
    typeFichier : SInt16;
    pathFichier,message : String255;
    numeroJoueur, confiance : SInt32;
    tempoMetaphone : boolean;
begin
  message := '## WARNING ## : this is not a message';

  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  pathFichier := PathDuDossierDatabase + ':Gestion Base WThor:WTHOR.JOU';

  err := FileExists(pathFichier,0,fic);

  if (err = NoErr) and
     EstUnFichierNouveauFormat(fic.info,typeFichier,entete) and
     (typeFichier = kFicJoueursNouveauFormat) then
     begin

       // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {1}');
       // AttendFrappeClavier;

       if (entete.NombreEnregistrementsTournoisEtJoueurs >= 65535)
         then
           begin

             // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {5}');
             // AttendFrappeClavier;

             AlerteSimple('Le fichier WTHOR.JOU officiel est plein !');
             WriteInTraceWThorLog('');
             WriteInTraceWThorLog('## WARNING ## : Le fichier WTHOR.JOU officiel est plein !');
             err := -1;
             goto sortie;
           end
         else
           begin
             // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {6}');
             // AttendFrappeClavier;

             EnleveEspacesDeGaucheSurPlace(oldName);
             if (oldName <> '')
               then  {renommage : on essaye de remplacer un vieux nom}
                 begin
                   tempoMetaphone := CassioIsUsingMetaphone;
                   SetCassioIsUsingMetaphone(false);

                   if (JoueurEstDonneParSonNumero(oldname,numeroJoueur) or TrouveNumeroDuJoueur(oldname,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle)) and
                      (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur))
                     then
                       begin
                         MyFabriqueNomJoueurPourBaseWThorOfficielle(newName,joueur);
                         message := 'Player "'+GetNomJoueur(numeroJoueur)+'" renamed to "'+newName+'" (#'+IntToStr(numeroJoueur)+')';
                       end
                     else
                       begin
                         WriteInTraceWThorLog('');
                         WriteInTraceWThorLog('## WARNING ## : Player "'+oldname+'" not found');

                         SetCassioIsUsingMetaphone(tempoMetaphone);
                         err := -2;
                         goto sortie;
                       end;

                   SetCassioIsUsingMetaphone(tempoMetaphone);
                 end
               else  {creation : on cree un nouveau joueur}
                 begin

                   // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {7}');
                   // AttendFrappeClavier;

                   numeroJoueur := entete.NombreEnregistrementsTournoisEtJoueurs;

                  //  WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {8}');
                  // AttendFrappeClavier;

                   inc(entete.NombreEnregistrementsTournoisEtJoueurs);

                   // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {9}');
                   // AttendFrappeClavier;

                   MyFabriqueNomJoueurPourBaseWThorOfficielle(newName,joueur);

                   // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {10}');
                   // AttendFrappeClavier;

                   message := 'Player "'+newName+'" added (#'+IntToStr(numeroJoueur)+')';
                 end;
           end;

       MettreDateDuJourDansEnteteFichierNouveauFormat(entete);

       // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {2}');
       // AttendFrappeClavier;


			 (* Ecriture du joueur dans le fichier WTHOR.JOU officiel *)

       err := OpenFile(fic);
       if (err = NoErr) then err := EcritJoueurNouveauFormat(fic.refNum,numeroJoueur,joueur);
       if (err = NoErr) then err := EcritEnteteNouveauFormat(fic.refNum,entete);
       err := CloseFile(fic);

       // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {3}');
       // AttendFrappeClavier;

       (* ... et on essaie aussi de changer le joueur en mémoire *)

       AjouterJoueurEnMemoire(JoueurRecNouveauFormatToString(joueur),numeroJoueur,numeroJoueur);
       if ((numeroJoueur + 1) > NombreJoueursDansBaseOfficielle) then SetNombreJoueursDansBaseOfficielle(numeroJoueur + 1);
     end;

  sortie :

  // WritelnDansRapport('dans RenommerJoueurDansFichierWThorOfficiel {4}');
  // AttendFrappeClavier;

  if (err = NoErr)
    then WriteInTraceWThorLog(EnleveEspacesDeGauche(message))
    else
      begin
        WriteInTraceWThorLog('');
        WriteInTraceWThorLog('## WARNING ## : Failure in RenommerJoueurDansFichierWThorOfficiel, err = '+IntToStr(err));
      end;

  RenommerJoueurDansFichierWThorOfficiel := err;
end;



function RenommerTournoiDansFichierWThorOfficiel(oldName,newName : String255) : OSErr;
label sortie;
var err : OSErr;
    entete : t_EnTeteNouveauFormat;
    tournoi : t_TournoiRecNouveauFormat;
    fic : basicfile;
    typeFichier : SInt16;
    pathFichier,message : String255;
    numeroTournoi : SInt32;
begin
  message := '## WARNING ## : this is not a message';
  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  pathFichier := PathDuDossierDatabase + ':Gestion Base WThor:WTHOR.TRN';

  err := FileExists(pathFichier,0,fic);

  if (err = NoErr) and
     EstUnFichierNouveauFormat(fic.info,typeFichier,entete) and
     (typeFichier = kFicTournoisNouveauFormat) then
     begin

       if (entete.NombreEnregistrementsTournoisEtJoueurs >= 65535)
         then
           begin
             AlerteSimple('Le fichier WTHOR.TRN officiel est plein !');
             WriteInTraceWThorLog('');
             WriteInTraceWThorLog('## WARNING ## : Le fichier WTHOR.TRN officiel est plein !');
             err := -1;
             goto sortie;
           end
         else
           begin
             EnleveEspacesDeGaucheSurPlace(oldName);
             if (oldName <> '')
               then  {renommage : on essaye de remplacer un vieux nom}
                 begin
                   if (TournoiEstDonneParSonNumero(oldname,numeroTournoi) or TrouveNumeroDuTournoi(oldname,numeroTournoi,0)) and
                      (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi))
                     then
                       begin
                         MyFabriqueNomTournoiPourBaseWThorOfficielle(newName,tournoi);
                         message := 'Tourney "'+GetNomTournoi(numeroTournoi)+'" renamed to "'+newName+'" (#'+IntToStr(numeroTournoi)+')';
                       end
                     else
                       begin
                         WriteInTraceWThorLog('');
                         WriteInTraceWThorLog('## WARNING ## : Tourney "'+oldname+'" not found');
                         err := -2;
                         goto sortie;
                       end;
                 end
               else  {creation : on cree un nouveau tournoi}
                 begin
                   numeroTournoi := entete.NombreEnregistrementsTournoisEtJoueurs;

                   inc(entete.NombreEnregistrementsTournoisEtJoueurs);
                   MyFabriqueNomTournoiPourBaseWThorOfficielle(newName,tournoi);

                   message := 'Tourney "'+newName+'" added (#'+IntToStr(numeroTournoi)+')';
                 end;
           end;

       MettreDateDuJourDansEnteteFichierNouveauFormat(entete);


			 (* Ecriture du tournoi dans le fichier WTHOR.TRN officiel *)

       err := OpenFile(fic);
       if (err = NoErr) then err := EcritTournoiNouveauFormat(fic.refNum,numeroTournoi,tournoi);
       if (err = NoErr) then err := EcritEnteteNouveauFormat(fic.refNum,entete);
       err := CloseFile(fic);

       (* ... et on essaie aussi de changer le tournoi en mémoire *)

       AjouterTournoiEnMemoire(TournoiRecNouveauFormatToString(tournoi),numeroTournoi,numeroTournoi);
       if ((numeroTournoi + 1) > NombreTournoisDansBaseOfficielle) then SetNombreTournoisDansBaseOfficielle(numeroTournoi+1);
     end;

  sortie :


  if (err = NoErr)
    then WriteInTraceWThorLog(EnleveEspacesDeGauche(message))
    else
      begin
        WriteInTraceWThorLog('');
        WriteInTraceWThorLog('## WARNING ## : Failure in RenommerTournoiDansFichierWThorOfficiel, err = '+IntToStr(err));
      end;

  RenommerTournoiDansFichierWThorOfficiel := err;
end;


function AddPlayerDansBaseOfficielle(joueur : String255) : OSErr;
label sortie;
var err : OSErr;
    playerRec : t_JoueurRecNouveauFormat;
    numeroJoueur, confiance : SInt32;
    tempoMetaphone : boolean;
    oldName : String255;
begin

  err := 0;

  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  (* normalisation du nom *)

  MyFabriqueNomJoueurPourBaseWThorOfficielle(joueur,playerRec);
  joueur := JoueurRecNouveauFormatToString(playerRec);


  (* si le nom du joueur est vide, c'est une erreur *)

  if (joueur = '') then
    begin
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog('## WARNING (BEGIN) ## : empty player name in AddPlayerDansBaseOfficielle');
      err := -2;
      goto sortie;
    end;


  (* si le joueur est deja dans la base, c'est sans doute une erreur *)

  tempoMetaphone := CassioIsUsingMetaphone;
  SetCassioIsUsingMetaphone(false);

  if (JoueurEstDonneParSonNumero(joueur,numeroJoueur) or TrouveNumeroDuJoueur(joueur,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle)) and
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur)) then
    begin
      oldName := GetNomJoueur(numeroJoueur);
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog('## WARNING (BEGIN) ## : player "'+ joueur + '" already exists as "' + oldName + '" (#' + IntToStr(numeroJoueur) + ')');
      WriteInTraceWThorLog('     note : if you really want to add this player as a duplicate, use the following two commands:');
      WriteInTraceWThorLog('     add player "My name is nobody"');
      WriteInTraceWThorLog('     rename player "My name is nobody" to "' + joueur + '"');
      err := -3;
    end;

  SetCassioIsUsingMetaphone(tempoMetaphone);


  (* tout va bien : on essaye de fabriquer le joueur, hein ! *)

  if (err = 0) then
    err := RenommerJoueurDansFichierWThorOfficiel('',joueur);


  (* sortie *)

sortie :
  if (err <> NoErr) then
    begin
      WriteInTraceWThorLog('## WARNING (END) ## : Failure in AddPlayerDansBaseOfficielle, err = '+IntToStr(err));
      WriteInTraceWThorLog('');
    end;

  AddPlayerDansBaseOfficielle := err;
end;


function AddTournamentDansBaseOfficielle(tournoi : String255) : OSErr;
label sortie;
var err : OSErr;
    tournamentRec : t_TournoiRecNouveauFormat;
    numeroTournoi : SInt32;
    oldName : String255;
begin

  err := 0;

  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  (* normalisation du nom *)

  MyFabriqueNomTournoiPourBaseWThorOfficielle(tournoi,tournamentRec);
  tournoi := TournoiRecNouveauFormatToString(tournamentRec);

  (* si le nom du tournoi est vide, c'est une erreur *)

  if (tournoi = '') then
    begin
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog('## WARNING (BEGIN) ## : empty tounament name in AddTournamentDansBaseOfficielle');
      err := -2;
      goto sortie;
    end;


  (* si le tournoi est deja dans la base, c'est sans doute une erreur *)

  if (TournoiEstDonneParSonNumero(tournoi,numeroTournoi) or TrouveNumeroDuTournoi(tournoi,numeroTournoi,0)) and
     (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi)) then
    begin
      oldName := GetNomTournoi(numeroTournoi);
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog('## WARNING ## : tourney "'+ tournoi + '" already exists as "' + oldName + '" (#' + IntToStr(numeroTournoi) + ')');
      WriteInTraceWThorLog('     note : if you really want to duplicate this tourney, use the following two commands ');
      WriteInTraceWThorLog('     add tourney "My tournament is nowhere"');
      WriteInTraceWThorLog('     rename tourney "My tournament is nowhere" to "' + tournoi + '"');
      err := -3;
    end;


  (* tout va bien : on essaye de fabriquer le tournoi, hein ! *)

  if (err = 0) then
    err := RenommerTournoiDansFichierWThorOfficiel('',tournoi);


  (* sortie *)

sortie :
  if (err <> NoErr) then
    begin
      WriteInTraceWThorLog('## WARNING (END) ## : Failure in AddTournamentDansBaseOfficielle, err = '+IntToStr(err));
      WriteInTraceWThorLog('');
    end;


  AddTournamentDansBaseOfficielle := err;
end;


function FindPlayerDansBaseOfficielle(joueur : String255) : OSErr;
var numeroJoueur, confiance : SInt32;
    tempoMetaphone : boolean;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  EnleveEspacesDeGaucheSurPlace(joueur);

  tempoMetaphone := CassioIsUsingMetaphone;
  SetCassioIsUsingMetaphone(false);

  if (JoueurEstDonneParSonNumero(joueur,numeroJoueur) or TrouveNumeroDuJoueur(joueur,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle)) and
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur))
     then
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Player found : "'+GetNomJoueur(numeroJoueur)+'" (#'+IntToStr(numeroJoueur)+')');
         FindPlayerDansBaseOfficielle := NoErr;
       end
     else
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Player "'+joueur+'" not found');
         FindPlayerDansBaseOfficielle := -1;
       end;

  SetCassioIsUsingMetaphone(tempoMetaphone);
end;


function FindTournamentDansBaseOfficielle(tournoi : String255) : OSErr;
var numeroTournoi : SInt32;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  EnleveEspacesDeGaucheSurPlace(tournoi);

  if (TournoiEstDonneParSonNumero(tournoi,numeroTournoi) or TrouveNumeroDuTournoi(tournoi,numeroTournoi,0)) and
     (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi))
     then
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Tourney found : "'+GetNomTournoi(numeroTournoi)+'" (#'+IntToStr(numeroTournoi)+')');
         FindTournamentDansBaseOfficielle := NoErr;
       end
     else
       begin
         WriteInTraceWThorLog('');
         WriteInTraceWThorLog('Tourney "'+tournoi+'" not found');
         FindTournamentDansBaseOfficielle := -1;
       end;
end;


procedure ChangeBlackPlayer(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroNoir : SInt32);
var partieSansOrdinateur : boolean;
begin {$UNUSED partie60}
  SetNroJoueurNoirParNroRefPartie(numeroReferencePartie,numeroNoir);

  partieSansOrdinateur := not(GetJoueurEstUnOrdinateur(GetNroJoueurNoirParNroRefPartie(numeroReferencePartie))) and
                          not(GetJoueurEstUnOrdinateur(GetNroJoueurBlancParNroRefPartie(numeroReferencePartie)));
  SetPartieEstSansOrdinateur(numeroReferencePartie,partieSansOrdinateur);
end;


procedure ChangeWhitePlayer(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroBlanc : SInt32);
var partieSansOrdinateur : boolean;
begin {$UNUSED partie60}
  SetNroJoueurBlancParNroRefPartie(numeroReferencePartie,numeroBlanc);

  partieSansOrdinateur := not(GetJoueurEstUnOrdinateur(GetNroJoueurNoirParNroRefPartie(numeroReferencePartie))) and
                          not(GetJoueurEstUnOrdinateur(GetNroJoueurBlancParNroRefPartie(numeroReferencePartie)));
  SetPartieEstSansOrdinateur(numeroReferencePartie,partieSansOrdinateur);
end;


procedure ChangeTournament(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var numeroTournoi : SInt32);
begin {$UNUSED partie60}
  SetNroTournoiParNroRefPartie(numeroReferencePartie,numeroTournoi);
end;


procedure ChangeYear(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var anneePartie : SInt32);
begin {$UNUSED partie60}
  SetAnneePartieParNroRefPartie(numeroReferencePartie,anneePartie);
end;


function ChangeNumerosJoueursEtTournoisDansListe(noir,blanc,tournoi : String255; surQuellesParties : FiltreNumRefProc) : OSErr;
var numeroJoueur,numeroTournoi : SInt32;
    nbPartiesAChanger,bidon : SInt32;
    confiance : SInt32;
    s : String255;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  nbPartiesAChanger := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);

  EnleveEspacesDeGaucheSurPlace(noir);
  if (noir <> '') and
     (JoueurEstDonneParSonNumero(noir,numeroJoueur) or TrouveNumeroDuJoueur(noir,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle)) and
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeBlackPlayer,numeroJoueur);
      s := 'Black player changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomJoueur(numeroJoueur),IntToStr(numeroJoueur),IntToStr(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;


  EnleveEspacesDeGaucheSurPlace(blanc);
  if (blanc <> '') and
     (JoueurEstDonneParSonNumero(blanc,numeroJoueur) or TrouveNumeroDuJoueur(blanc,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle)) and
     (numeroJoueur = GetNroJoueurDansSonFichier(numeroJoueur)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeWhitePlayer,numeroJoueur);
      s := 'White player changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomJoueur(numeroJoueur),IntToStr(numeroJoueur),IntToStr(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;


  EnleveEspacesDeGaucheSurPlace(tournoi);
  if (tournoi <> '') and
     (TournoiEstDonneParSonNumero(tournoi,numeroTournoi) or TrouveNumeroDuTournoi(tournoi,numeroTournoi,0)) and
     (numeroTournoi = GetNroTournoiDansSonFichier(numeroTournoi)) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeTournament,numeroTournoi);
      s := 'Tourney changed to "^0" (#^1) in ^2 games';
      s := ParamStr(s,GetNomTournoi(numeroTournoi),IntToStr(numeroTournoi),IntToStr(nbPartiesAChanger),'');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;

  CalculsEtAffichagePourBase(false,true);
  ChangeNumerosJoueursEtTournoisDansListe := NoErr;
end;


function ChangeAnneeDansListe(annee : SInt32; surQuellesParties : FiltreNumRefProc) : OSErr;
var nbPartiesAChanger,bidon : SInt32;
    s : String255;
begin
  if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
    then WritelnDansRapport('');

  nbPartiesAChanger := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);

  if (annee >= 1980) then
    begin
      ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,ChangeYear,annee);
      s := 'Year changed to "^0" in ^1 games';
      s := ParamStr(s,IntToStr(annee),IntToStr(nbPartiesAChanger),'','');
      WriteInTraceWThorLog('');
      WriteInTraceWThorLog(s);
    end;

  CalculsEtAffichagePourBase(false,true);
  ChangeAnneeDansListe := NoErr;
end;


procedure CalculeScoreTheorique(var partie60 : PackedThorGame; numeroReferencePartie : SInt32; var scoreTheoriquePourNoir : SInt32);
var position : PositionEtTraitRec;
    typeErreur : SInt32;
    nbPartiesRestantes : SInt32;
    tempsMoyenParPartieCalculee : double;
    score, nbNoirs, nbBlancs, nbVides : SInt32;
    solveResults : MakeEndgameSearchResultRec;
    enRechercheDePositionsDifficiles : boolean;
    oldEcritureDansLog : boolean;
    scoreTheorique : SInt32;
    data : SInt32;
    s : String255;
begin
  if (interruptionReflexion = pasdinterruption) then
    with gInfosCalculScoresTheoriques do
      begin
        numeroReferencePartieEnCours := numeroReferencePartie;

        { si le drapeau enRechercheDePositionsDifficiles est vrai, on ne changera pas
          les scores dans la liste, on se contentera d'afficher dans le rapport les
          parties pour lesquelles la recherche de finale s'est stabilisée à µ=17 ou µ=infini}
        enRechercheDePositionsDifficiles := (endgameSolveFlags AND kEndgameSolveSearchDifficultPositions) <> 0;


        position := PositionEtTraitAfterMoveNumber(partie60,apresQuelCoup,typeErreur);


        if enRechercheDePositionsDifficiles then
          begin

            { optimisation : si on recherche des positions difficiles WLD, on ne
              cherche a priori que parmi les positions qui semblent serrees... }

            if ((endgameSolveFlags AND kEndgameSolveOnlyWLD) <> 0) then
              begin
                scoreTheorique := GetScoreTheoriqueParNroRefPartie(numeroReferencePartieEnCours);
                if (scoreTheorique <= 31) or (scoreTheorique >= 33)
                  then typeErreur := kPartieIninteressante;
              end;

            { on essaye de ne pas chercher deux fois la meme position }

            if MemberOfPositionEtTraitSet(position,data,positionsDejaCherchees)
              then typeErreur := kPartieIninteressante;

            { retenir l'ensemble des positions que l'on a cherchées }

            if (typeErreur = kPasErreur) then AddPositionEtTraitToSet(position, -1, positionsDejaCherchees );
          end;


        if (typeErreur = kPasErreur)
          then
            begin

              {si c'est un calcul pour WThor officielle, on affiche la position dans le rapport}
              if not(enRechercheDePositionsDifficiles) then
                begin
                  ChangeFontFaceDansRapport(bold);
                  WritelnDansRapport(ConstruireChaineReferencesPartieParNroRefPartie(numeroReferencePartie,true,apresQuelCoup+1));
                  ChangeFontFaceDansRapport(normal);
                  WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
                end;



              if GetTraitOfPosition(position) = pionVide
                then
                  begin  {la partie est terminée, on calcule le score final en comptant les pions }

                    nbNoirs  := NbPionsDeCetteCouleurDansPosition(pionNoir,position.position);
                    nbBlancs := NbPionsDeCetteCouleurDansPosition(pionBlanc,position.position);
                    nbVides  := NbCasesVidesDansPosition(position.position);

                    if nbNoirs > nbBlancs then nbNoirs  := nbNoirs  + nbVides else
                    if nbNoirs < nbBlancs then nbBlancs := nbBlancs + nbVides;

                    score := (nbNoirs - nbBlancs);  // on affecte arbitrairement le score à Noir...
                  end
                else
                  begin   {on essaye de calculer la finale de cette partie de la liste }
                    score := DoPlaquerPositionAndMakeEndgameSolve(position,endgameSolveFlags,solveResults);
                  end;


              if (interruptionReflexion = pasdinterruption) and
                 (score >= -64) and (score <= 64) then
                 begin
                   inc(nbPartiesCalculees);

                   if enRechercheDePositionsDifficiles
                     then
                       begin
                         if (solveResults.outDernierMuVariant >= 1600) then
                           begin

                             { on vient de trouver une position difficile, on l'affiche dans le rapport
                               et on l'ecrit dans le fichier Rapport.log }
                             oldEcritureDansLog := GetEcritToutDansRapportLog;
                             SetEcritToutDansRapportLog(true);

                             WritelnDansRapport('');
                             WritelnDansRapport(ConstruireChaineReferencesPartieParNroRefPartie(numeroReferencePartie,true,apresQuelCoup+1));
                             WritelnPositionEtTraitDansRapport(position.position,GetTraitOfPosition(position));
                             WriteNumDansRapport('score = ',score);
                             WriteNumDansRapport(',   trouvé à µ = ',solveResults.outDernierMuVariant);
                             WriteStringAndReelDansRapport(' en ',solveResults.outTimeTakenFinale,4);
                             WritelnDansRapport(' sec.');

                             SetEcritToutDansRapportLog(oldEcritureDansLog);
                           end;
                       end
                     else
                       begin
                         { on vient de calculer un score pour la base officielle, on l'affiche }
                         WritelnNumDansRapport('score = ',score);
                       end;

                   {calcul du score theorique (pour les noirs) }
                   if GetTraitOfPosition(position) = pionNoir  then scoreTheoriquePourNoir := 32 + (score div 2) else
                   if GetTraitOfPosition(position) = pionBlanc then scoreTheoriquePourNoir := 32 - (score div 2) else
                   if GetTraitOfPosition(position) = pionVide  then scoreTheoriquePourNoir := 32 + (score div 2)
                     else WritelnDansRapport('ERROR : trait inconnu dans CalculeScoreTheorique !!');

                   {on met le score theorique dans la liste}
                   if not(enRechercheDePositionsDifficiles) then
                     begin
                       if (scoreTheoriquePourNoir >= 0) and (scoreTheoriquePourNoir <= 64)
                         then SetScoreTheoriqueParNroRefPartie(numeroReferencePartie,scoreTheoriquePourNoir)
                         else WritelnNumDansRapport('ERREUR !! scoreTheoriquePourNoir = ',scoreTheoriquePourNoir);
                     end;

                   {affichage de quelques statistiques}
                   if (nbPartiesCalculees <> 0) then
                     begin
                       tempsMoyenParPartie         := ((TickCount - tickDepart + 30.0) / 60.0) / (nbPartiesCalculees + nbPartiesImpossibles);
                       tempsMoyenParPartieCalculee := ((TickCount - tickDepart + 30.0) / 60.0) / nbPartiesCalculees;
                       nbPartiesRestantes          := nbCalculsAFaire - (nbPartiesCalculees + nbPartiesImpossibles);
                       tempsRestantEstime          := tempsMoyenParPartie * nbPartiesRestantes;

                       if (tempsMoyenParPartieCalculee < 100.0)
                         then s := ReelEnStringAvecDecimales(tempsMoyenParPartieCalculee,2) + ' sec.'
                         else s := ReplaceStringOnce(SecondesEnJoursHeuresSecondes(Trunc(tempsMoyenParPartieCalculee)), ' sec.' , ' sec.');

                       WritelnDansRapport('temps moyen par partie ('+IntToStr(nbPartiesCalculees)+' parties) : ' + s);
                       WritelnDansRapport('temps restant estimé pour les '+IntToStr(nbPartiesRestantes)+' dernières parties : '+SecondesEnJoursHeuresSecondes(Trunc(tempsRestantEstime)));
                     end;
                 end
                 else
                   begin
                     EcritTypeInterruptionDansRapport(interruptionReflexion);
                     WritelnNumDansRapport('score = ',score);
                   end;

               WritelnDansRapport('');
               TextNormalDansRapport;
            end
          else
            begin
              inc(nbPartiesImpossibles);
            end;
      end;
end;


procedure LancerInterruptionPourCalculerScoresTheoriquesPartiesDansListe;
begin

  if (nbPartiesActives <= 0) then
    exit;

  if not(CassioEstEnTrainDeReflechir) or CassioEstEnTrainDeCalculerPourLeZoo
    then LanceInterruption(kHumainVeutCalculerScoresTheoriquesWThor,'LancerInterruptionPourCalculerScoresTheoriquesPartiesDansListe')
    else WritelnDansRapport('ERREUR : (CassioEstEnTrainDeReflechir = true)  dans LancerInterruptionPourCalculerScoresTheoriquesPartiesDansListe !!')

end;


function CalculerScoresTheoriquesPartiesDansListe(apresQuelCoup : SInt32; endgameSolveFlags : SInt32; surQuellesParties : FiltreNumRefProc) : OSErr;
var scoreTheoriquePourNoir : SInt32;
    bidon : SInt32;
    tempEnCours : boolean;
begin

  gInfosCalculScoresTheoriques.apresQuelCoup                := apresQuelCoup;
  gInfosCalculScoresTheoriques.endgameSolveFlags            := endgameSolveFlags;
  gInfosCalculScoresTheoriques.tickDepart                   := TickCount;
  gInfosCalculScoresTheoriques.nbCalculsAFaire              := NumberOfGamesWithThisReferenceFilter(surQuellesParties,bidon);
  gInfosCalculScoresTheoriques.nbPartiesCalculees           := 0;
  gInfosCalculScoresTheoriques.nbPartiesImpossibles         := 0;
  gInfosCalculScoresTheoriques.numeroReferencePartieEnCours := 0;
  gInfosCalculScoresTheoriques.tempsMoyenParPartie          := 0.0;
  gInfosCalculScoresTheoriques.tempsRestantEstime           := 0.0;
  gInfosCalculScoresTheoriques.positionsDejaCherchees       := MakeEmptyPositionEtTraitSet;
  SetCalculDesScoresTheoriquesDeLaBaseEnCours(true, @tempEnCours);

  if (interruptionReflexion <> pasdinterruption)
    then
      begin
        WritelnDansRapport('ERREUR : (interruptionReflexion <> pasdinterruption)  dans CalculerScoresTheoriquesPartiesDansListe !!');
        WritelnInterruptionDansRapport(interruptionReflexion);
      end
    else
      begin
        with gInfosCalculScoresTheoriques do
          begin
            if (GetNiemeCaractereDuRapport(GetTailleRapport-1) <> cr)
              then WritelnDansRapport('');

            WritelnDansRapport('');

            ForEachGameInListDo(surQuellesParties,bidFiltreGameProc,CalculeScoreTheorique,scoreTheoriquePourNoir);

            WritelnDansRapport('temps total de calcul des scores theoriques : '+SecondesEnJoursHeuresSecondes((TickCount - tickDepart + 30) div 60));
            WritelnDansRapport('');
          end;
      end;

  SetCalculDesScoresTheoriquesDeLaBaseEnCours(tempEnCours, NIL);
  DisposePositionEtTraitSet(gInfosCalculScoresTheoriques.positionsDejaCherchees);

  if (interruptionReflexion = pasdinterruption)
    then CalculerScoresTheoriquesPartiesDansListe := NoErr
    else CalculerScoresTheoriquesPartiesDansListe := -20;

  if not(analyseRetrograde.enCours) and not(HumCtreHum) then DoChangeHumCtreHum;
end;


procedure SetCalculDesScoresTheoriquesDeLaBaseEnCours(newValue : boolean; oldValue : booleanPtr);
begin
  if oldValue <> NIL then
    oldValue^ := gInfosCalculScoresTheoriques.enCours;

  gInfosCalculScoresTheoriques.enCours := newValue;
end;


function CalculDesScoresTheoriquesDeLaBaseEnCours : boolean;
begin
  CalculDesScoresTheoriquesDeLaBaseEnCours := gInfosCalculScoresTheoriques.enCours;
end;


function ListerDerniersJoueursBaseOfficielleDansRapport(nbreJoueurs : SInt32) : OSErr;
var k,indexMax : SInt32;
begin
  indexMax := NombreJoueursDansBaseOfficielle;

  WriteInTraceWThorLog('');
  for k := indexMax downto indexMax - nbreJoueurs + 1 do
    WriteInTraceWThorLog(GetNomJoueur(k)+' (#'+IntToStr(k)+')');

  ListerDerniersJoueursBaseOfficielleDansRapport := NoErr;
end;


function ListerDerniersTournoisBaseOfficielleDansRapport(nbreTournois : SInt32) : OSErr;
var k,indexMax : SInt32;
begin
  indexMax := NombreTournoisDansBaseOfficielle;

  WriteInTraceWThorLog('');
  for k := indexMax downto indexMax - nbreTournois + 1 do
    WriteInTraceWThorLog(GetNomTournoi(k)+' (#'+IntToStr(k)+')');

  ListerDerniersTournoisBaseOfficielleDansRapport := NoErr;
end;


function DoActionGestionBaseOfficielle(commande : String255) : OSErr;
var oldParsingProtectionWithQuote : boolean;
    s1,s2,s3,s4,s5,s6,reste : String255;
    err : OSErr;
begin


  // WritelnDansRapport('commande dans DoActionGestionBaseOfficielle = '+commande);
  // AttendFrappeClavier;

  if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire) then
    err := MetJoueursEtTournoisEnMemoire(false);

  oldParsingProtectionWithQuote := GetParserProtectionWithQuotes;
  SetParserProtectionWithQuotes(true);

  Parse6(commande,s1,s2,s3,s4,s5,s6,reste);

  err := -10000;

  {add player "newname"}
  if (s1 = 'add') and (s2 = 'player') and (s3 <> '')
    then err := AddPlayerDansBaseOfficielle(s3);

  {create player "newname"}
  if (s1 = 'create') and (s2 = 'player') and (s3 <> '')
    then err := RenommerJoueurDansFichierWThorOfficiel('',s3);

  {rename player "oldname" to "newname"}
  if (s1 = 'rename') and (s2 = 'player') and (s3 <> '') and (s4 = 'to') and (s5 <> '')
    then err := RenommerJoueurDansFichierWThorOfficiel(s3,s5);

  {find player "name"}
  if (s1 = 'find') and (s2 = 'player') and (s3 <> '')
    then err := FindPlayerDansBaseOfficielle(s3);



  {add tourney "newname"}
  if (s1 = 'add') and (s2 = 'tourney') and (s3 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel('',s3);

  {create tourney "newname"}
  if (s1 = 'create') and (s2 = 'tourney') and (s3 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel('',s3);

  {rename tourney "oldname" to "newname"}
  if (s1 = 'rename') and (s2 = 'tourney') and (s3 <> '') and (s4 = 'to') and (s5 <> '')
    then err := RenommerTournoiDansFichierWThorOfficiel(s3,s5);

  {find tourney "name"}
  if (s1 = 'find') and (s2 = 'tourney') and (s3 <> '')
    then err := FindTournamentDansBaseOfficielle(s3);


  {change black player to "newname"}
  if (s1 = 'change') and (s2 = 'black') and (s3 = 'player') and (s4 = 'to') and (s5 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe(s5,'','',FiltrePartieEstActiveEtSelectionnee);

  {change white player to "newname"}
  if (s1 = 'change') and (s2 = 'white') and (s3 = 'player') and (s4 = 'to') and (s5 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe('',s5,'',FiltrePartieEstActiveEtSelectionnee);

  {change tourney to "newname"}
  if (s1 = 'change') and (s2 = 'tourney') and (s3 = 'to') and (s4 <> '')
    then err := ChangeNumerosJoueursEtTournoisDansListe('','',s4,FiltrePartieEstActiveEtSelectionnee);

  {change year to "NNNN"}
  if (s1 = 'change') and (s2 = 'year') and (s3 = 'to') and (s4 <> '')
    then err := ChangeAnneeDansListe(StrToInt32(s4),FiltrePartieEstActiveEtSelectionnee);


  {show last players}
  if (s1 = 'show') and (s2 = 'last') and (s3 = 'players')
    then err := ListerDerniersJoueursBaseOfficielleDansRapport(30);

  {show last tourneys}
  if (s1 = 'show') and (s2 = 'last') and (s3 = 'tourneys')
    then err := ListerDerniersTournoisBaseOfficielleDansRapport(30);


  {show all players}
  if (s1 = 'show') and (s2 = 'all') and (s3 = 'players')
    then err := ListerDerniersJoueursBaseOfficielleDansRapport(NombreJoueursDansBaseOfficielle);

  {show all tourneys}
  if (s1 = 'show') and (s2 = 'all') and (s3 = 'tourneys')
    then err := ListerDerniersTournoisBaseOfficielleDansRapport(NombreTournoisDansBaseOfficielle);


  {recalculate}
  if (s1 = 'recalculate')
    then err := CalculerScoresTheoriquesPartiesDansListe(36,kEndgameSolveToujoursRamenerLaSuite,FiltrePartieEstActiveEtSelectionnee);

  {recalculate}
  if (s1 = 'search') and (s2 = 'difficult') and (s3 = 'WLD')
    then err := CalculerScoresTheoriquesPartiesDansListe(29,kEndgameSolveOnlyWLD + kEndgameSolveSearchDifficultPositions,FiltrePartieEstActiveEtSelectionnee);


  {wthor help, help, ?}
  if (s1 = '?') or (s1 = 'help') or ((s1 = 'wthor') and (s2 = 'help'))
    then
      begin
        WritelnDansRapport('');
        WritelnDansRapport('Select or enter one of the following commands in the rapport :');
        WritelnDansRapport('   add player "newname"');
        WritelnDansRapport('   add tourney "newname"');
        WritelnDansRapport('   create player "newname"');
        WritelnDansRapport('   create tourney "newname"');
        WritelnDansRapport('   rename player "oldname" to "newname"');
        WritelnDansRapport('   rename tourney "oldname" to "newname"');
        WritelnDansRapport('   find player "name"');
        WritelnDansRapport('   find tourney "name"');
        WritelnDansRapport('   change black player to "newname"');
        WritelnDansRapport('   change white player to "newname"');
        WritelnDansRapport('   change tourney to "newname"');
        WritelnDansRapport('   change year to "NNNN"');
        WritelnDansRapport('   show last players');
        WritelnDansRapport('   show last tourneys');
        WritelnDansRapport('   show all players');
        WritelnDansRapport('   show all tourneys');
        WritelnDansRapport('   recalculate');
        WritelnDansRapport('   wthor help');
        WritelnDansRapport('   help');
        WritelnDansRapport('   ?');
        WritelnDansRapport('');
        err := NoErr;
      end;

  SetParserProtectionWithQuotes(oldParsingProtectionWithQuote);

  DoActionGestionBaseOfficielle := err;
end;


procedure TransformerLigneRapportEnCommandeAjoutJoueurDansBaseOfficielle(var ligne : String255; var myError : SInt32);
begin
  if (ligne <> '') then
    begin
      myError := DoActionGestionBaseOfficielle(ligne);

      if myError <> NoErr then
        begin
          myError := DoActionGestionBaseOfficielle('add player "' + ligne + '"');
        end;
    end;
end;


procedure TransformerLigneRapportEnCommandeAjoutTournoiDansBaseOfficielle(var ligne : String255; var myError : SInt32);
begin
  if (ligne <> '') then
    begin
      myError := DoActionGestionBaseOfficielle(ligne);

      if myError <> NoErr then
        begin
          myError := DoActionGestionBaseOfficielle('add tourney "' + ligne + '"');
        end;
    end;
end;


procedure CreerOuRenommerMachinDansLaBaseOfficielle;
var longueurSelection : SInt32;
    nbreLignesSelection : SInt32;
    myError : OSErr;
begin
  myError := -10000;

  // WritelnDansRapport('Entree dans CreerOuRenommerMachinDansLaBaseOfficielle');
  // AttendFrappeClavier;

  nbreLignesSelection := NombreDeLignesDansSelectionRapport;

  if FenetreRapportEstOuverte and
     FenetreRapportEstAuPremierPlan and
     SelectionRapportNonVide and
     (LongueurSelectionRapport < 255)
     then myError := DoActionGestionBaseOfficielle(SelectionRapportEnString(longueurSelection));

  if (myError = -10000) then
    myError := DoActionGestionBaseOfficielle('wthor help');

end;


procedure CreerPlusieursJoueursDansBaseOfficielle;
var error : SInt32;
begin
  ForEachLineSelectedInRapportDo(TransformerLigneRapportEnCommandeAjoutJoueurDansBaseOfficielle, error);
end;


procedure CreerPlusieursTournoisDansBaseOfficielle;
var error : SInt32;
begin
  ForEachLineSelectedInRapportDo(TransformerLigneRapportEnCommandeAjoutTournoiDansBaseOfficielle, error);
end;



END.



















































