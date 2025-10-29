UNIT UnitImportDesNoms;


INTERFACE


 USES UnitDefCassio;



{ Initialisation et liberation de l'unité}
procedure InitUnitImportDesNoms;
procedure LibereMemoireImportDesNoms;


{ recherche d'un numero de joueur ou de tournoi dans la base WThor }
function TrouveNumeroDuJoueur(const nomJoueur : String255; var numeroJoueur, confiance : SInt64; genreRecherche : SInt64) : boolean;
function TrouveNumeroDuTournoi(const nomTournoi : String255; var numeroTournoi : SInt64; fromIndex : SInt64) : boolean;
function TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
function TrouveLexemesDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
function TrouveNumeroDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
function TrouveSousChaineDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;


{ imports des noms }
function PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudoPGN : String255) : String255;
function PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo : String255; strict : boolean; var nomDansThor : String255; var numeroDansThor : SInt64) : boolean;
function PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo : String255; var nomDansThor : String255; var numeroDansThor : SInt64) : boolean;
function TrouverNomsDesJoueursDansNomDeFichier(s : String255; var numeroJoueur1,numeroJoueur2 : SInt64; longueurMinimaleUnPseudo : SInt64; var qualiteSolution : double) : boolean;
function TrouverNomDeTournoiDansPath(path : String255; var numeroTournoi,annee : SInt64; nomDictionnaireDesPseudos : String255) : boolean;


{ gestion des erreurs}
procedure AjoutePseudoInconnu(const message_erreur,pseudo,nom : String255);
procedure AnnonceNomAAjouterDansThor(const pseudo,nom : String255);


{ manipulation des noms }
procedure TraduitNomTournoiEnMac(ancNom : String255; var nouveauNom : String255);
procedure TraduitNomJoueurEnMac(ancNom : String255; var nouveauNom : String255);
procedure EnlevePrenom(const nomOrigine : String255; var nomSansPrenom : String255);
function NomCourtDuTournoi(const nomOrigine : String255) : String255;
function EstUnNomChinoisDeDeuxLettresOuMoins(const nomJoueur : String255) : boolean;
function EstUnPseudoDontLeDictionaireConfirmeQuOnNeConnaitPasLeNomReel(const pseudo : String255) : boolean;


{ acces aux noms public de la base WThor }
procedure MyFabriqueNomJoueurPourBaseWThorOfficielle(var nom : String255; var result : t_JoueurRecNouveauFormat);
procedure MyFabriqueNomTournoiPourBaseWThorOfficielle(var nom : String255; var result : t_TournoiRecNouveauFormat);
function JoueurRecNouveauFormatToString(whichPlayer : t_JoueurRecNouveauFormat) : String255;
function TournoiRecNouveauFormatToString(whichTourney : t_TournoiRecNouveauFormat) : String255;


{ Reconnaisance des noms par Metaphone ? }
function FabriqueNomEnMajusculesAvecEspaces(const s : String255) : String255;
function FabriqueNomEnMajusculesSansEspaceSansMetaphone(s : String255) : String255;
function FabriqueNomEnMajusculesSansEspaceAvecMetaphone(s : String255) : String255;
function FabriqueNomEnMajusculesSansEspaceDunNomWThor(nom : String255) : String255;
function CassioIsUsingMetaphone : boolean;
procedure SetCassioIsUsingMetaphone(flag : boolean);
procedure RegenererLesNomsMetaphoneDeLaBase;


{ Fichier de torture }
function OuvrirFichierTortureImportDesNoms(nomCompletFichier : String255) : OSErr;
procedure ReadLineInTortureFile(var ligne : LongString; var theFic : FichierTEXT; var compteur : SInt64);
procedure FabriqueFichierDeTorture;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    DateTimeUtils, OSUtils
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitAccesNouveauFormat, UnitRapport, UnitFichiersTEXT, UnitStringSet, UnitUtilitaires
    , UnitMetaphone, MyMathUtils, UnitBaseNouveauFormat, UnitHashing, UnitATR ;
{$ELSEC}
    ;
    {$I prelink/ImportDesNoms.lk}
{$ENDC}


{END_USE_CLAUSE}












const gUsingMetaphone : boolean = true;




function EstUnPseudoDontLeDictionaireConfirmeQuOnNeConnaitPasLeNomReel(const pseudo : String255) : boolean;
var inconnu : boolean;
    numero : SInt64;
begin
  if StringSetEstVide(gImportDesNoms.pseudosSansNomReel)
    then inconnu := false
    else inconnu := MemberOfStringSet(sysutils.LowerCase(EnleveEspacesDeDroite(pseudo)),numero,gImportDesNoms.pseudosSansNomReel);


  // WritelnStringAndBoolDansRapport('StringSetEstVide = ',StringSetEstVide(gImportDesNoms.pseudosSansNomReel));
  // WritelnStringAndBoolDansRapport('inconnu pour ' + pseudo + ' = ',inconnu);

  EstUnPseudoDontLeDictionaireConfirmeQuOnNeConnaitPasLeNomReel := inconnu;
end;



function PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos, pseudoPGN : String255) : String255;
var ligne,s,s1,s2,reste : String255;
    dictionnairePseudosPGN : FichierTEXT;
    doitMettreAJourLesPseudosAyantUnNomReel : boolean;
    pseudoPGNSeTermineParDesChiffres : boolean;
    eraseDigitsInPseudos : boolean;
    pseudoAvecUnNomReel : String255;
    pseudoPGNAvecLesChiffresTerminaux : String255;
    pseudoPGNSansLesChiffresTerminaux : String255;
    nom_dictionnaire : String255;
    erreurES : OSErr;
    trouve : boolean;
    t,numero,posEgal : SInt64;

    procedure NormaliserPseudo(var pseudo : String255);
    var i,k,longueur : SInt64;
        c : char;
    begin

      (* normalisation d'un pseudo internet : enlever les traits de soulignement *)

      longueur := LENGTH_OF_STRING(pseudo);

      k := 0;
      for i := 1 to longueur do
        begin
          c := pseudo[i];
          if (c <> '_') then
            begin
              inc(k);
              pseudo[k] := c;
            end;
        end;

      if (k <> longueur) then SET_LENGTH_OF_STRING(pseudo,k);
    end;


begin
  PseudoPGNEnNomDansBaseThor := '???';

  eraseDigitsInPseudos := true;

  (* on normalise le pseudo cherché en retirant les traits
     de soulignement (parce que Kurnik a fait ça)
   *)

  NormaliserPseudo(pseudoPGN);

  (* on calcule deux versions du pseudo en enlevant
     les chiffres terminaux (parce que sur Internet
     les gens rajoutent souvent des chiffres à leur
     pseudo).
   *)

  pseudoPGNAvecLesChiffresTerminaux := pseudoPGN;

  t := LENGTH_OF_STRING(pseudoPGN);
  pseudoPGNSeTermineParDesChiffres := (t > 1) and IsDigit(pseudoPGN[t]);
  while (t > 1) and IsDigit(pseudoPGN[t]) and eraseDigitsInPseudos do
    dec(t);
  SET_LENGTH_OF_STRING(pseudoPGN,t);

  pseudoPGNSansLesChiffresTerminaux := pseudoPGN;

  (* en cas de pseudo PGN se terminant par des chiffres,
     on recherche d'abord la version avec les chiffres,
     puis on fera une seconde recherche (implementee par
     un appel recursif à la fin de la fonction) pour la
     version du pseudo sans les chiffres.
  *)

  if (pseudoPGNAvecLesChiffresTerminaux <> pseudoPGNSansLesChiffresTerminaux)
    then pseudoPGN := pseudoPGNAvecLesChiffresTerminaux
    else pseudoPGN := pseudoPGNSansLesChiffresTerminaux;


  pseudoPGN[1] := LowerCase(pseudoPGN[1]);

  // WritelnDansRapport('pseudoPGN = '+pseudoPGN);
  // WritelnDansRapport('pseudoPGNAvecLesChiffresTerminaux = '+pseudoPGNAvecLesChiffresTerminaux);
  // WritelnDansRapport('pseudoPGNSansLesChiffresTerminaux = '+pseudoPGNSansLesChiffresTerminaux);

  if StringSetEstVide(gImportDesNoms.pseudosAyantUnNomReel)
    then
      begin
        doitMettreAJourLesPseudosAyantUnNomReel := true;
      end
    else
      begin
        doitMettreAJourLesPseudosAyantUnNomReel := false;

        // On cherche dans le cache si le pseudo PGN cherche est bien dans le fichier dictionnaire...
        // Ceci permet d'aller très vite pour eliminer les pseudos PGN qui ne sont PAS dans le dictionnaire !

        if not(MemberOfStringSet(sysutils.LowerCase(pseudoPGN),numero,gImportDesNoms.pseudosAyantUnNomReel)) then
          begin
            if (pseudoPGNAvecLesChiffresTerminaux <> pseudoPGNSansLesChiffresTerminaux) and
               (pseudoPGN = pseudoPGNAvecLesChiffresTerminaux) and
               (pseudoPGNSansLesChiffresTerminaux <> '')
              then
                begin
                  // WritelnDansRapport('appel recursif {1}');
                  PseudoPGNEnNomDansBaseThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos, pseudoPGNSansLesChiffresTerminaux);
                  exit;
                end
              else
                begin
                  PseudoPGNEnNomDansBaseThor := '???';
                  exit;
                end;
          end;
      end;


  // methode un peu lente : on va ouvrir le fichier dictionnaire et le parcourir ligne a ligne...

  if (nomDictionnaireDesPseudos <> '') then
    begin
      nom_dictionnaire := nomDictionnaireDesPseudos;

      erreurES := FichierTexteDeCassioExiste(nom_dictionnaire,dictionnairePseudosPGN);
      if erreurES <> NoErr then
        begin
          AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
          exit;
        end;

      erreurES := OuvreFichierTexte(dictionnairePseudosPGN);
      if erreurES <> NoErr then
        begin
          AlerteSimpleFichierTexte(nom_dictionnaire,erreurES);
          exit;
        end;

      erreurES := NoErr;
      ligne := '';
      trouve := false;

      while not(EOFFichierTexte(dictionnairePseudosPGN,erreurES)) and not(trouve) do
        begin
          erreurES := ReadlnDansFichierTexte(dictionnairePseudosPGN,s);
          ligne := s;
          EnleveEspacesDeGaucheSurPlace(ligne);
          if (ligne = '') or (ligne[1] = '%')
            then
              begin
                {erreurES := WritelnDansFichierTexte(outputBaseThor,s);}
              end
            else
              begin
                posEgal := Pos('=',ligne);
                if (posEgal > 0)
                  then
                    begin
                      s1 := LeftStr(ligne,posEgal-1);
                      EnleveEspacesDeDroiteSurPlace(s1);
                      NormaliserPseudo(s1);
                      Parser(RightStr(ligne, 1 + LENGTH_OF_STRING(ligne) - posEgal),s2,reste);
                    end
                  else
                    begin
                      s2 := '';
                    end;

                {WritelnDansRapport('reste = '+reste);}
                if (s2 = '=')  then
                  begin

                    if (reste = '') then
                      AddStringToSet(sysutils.LowerCase(s1),-1,gImportDesNoms.pseudosSansNomReel);

                    // desormais "s1" est le pseudo avant le "=" dans le fichier dictionnaire
                    // et "reste" est le nom reel du joueur apres le "=" dans le fichier dictionnaire

                    if not(NoCaseEquals(s1,reste)) then
                      begin
                        s1[1] := LowerCase(s1[1]);

                        if doitMettreAJourLesPseudosAyantUnNomReel and (s1 <> '') then
                          begin

                            // on ajoute dans le cache des pseudos ayant un nom reel le pseudo du
                            // fichier dictionnaire avec ses chiffres terminaux
                            AddStringToSet(sysutils.LowerCase(s1),-1,gImportDesNoms.pseudosAyantUnNomReel);

                            pseudoAvecUnNomReel := s1;
                            t := LENGTH_OF_STRING(pseudoAvecUnNomReel);
                            while (t > 1) and IsDigit(pseudoAvecUnNomReel[t]) do
                              dec(t);
                            SET_LENGTH_OF_STRING(pseudoAvecUnNomReel,t);

                            // et aussi, eventuellement, sa version sans les chiffres terminaux...
                            if (pseudoAvecUnNomReel <> s1) then
                              AddStringToSet(sysutils.LowerCase(pseudoAvecUnNomReel),-1,gImportDesNoms.pseudosAyantUnNomReel);

                            {WritelnDansRapport(pseudoAvecUnNomReel + ' => ' + reste);}
                          end;

                        //WritelnDansRapport('s1 = '+s1);

                        if (NoCasePos(pseudoPGN,s1) = 1) and (LENGTH_OF_STRING(pseudoPGN) >= LENGTH_OF_STRING(s1) - 2) then
                          begin
                            EnleveEspacesDeGaucheSurPlace(reste);
                            EnleveEspacesDeDroiteSurPlace(reste);
                            PseudoPGNEnNomDansBaseThor := reste;
                            trouve := true;
                          end;
                      end;

                  end;
              end;
        end;
      erreurES := FermeFichierTexte(dictionnairePseudosPGN);

      (* si on a trouve le pseudo, la liste des pseudos ayant un
         nom reel est incomplete car on a shinté la fin du fichier :
         on préfere donc l'effacer  *)
      if doitMettreAJourLesPseudosAyantUnNomReel and trouve
        then DisposeStringSet(gImportDesNoms.pseudosAyantUnNomReel);


     if not(trouve)
        and (pseudoPGNAvecLesChiffresTerminaux <> pseudoPGNSansLesChiffresTerminaux)
        and (pseudoPGNSansLesChiffresTerminaux <> '')
       then
         begin
           // WritelnDansRapport('appel recursif {2}');
           PseudoPGNEnNomDansBaseThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos, pseudoPGNSansLesChiffresTerminaux);
         end;

  end;   // if (nomDictionnaireDesPseudos <> '') then

end;



procedure AjoutePseudoInconnu(const message_erreur,pseudo,nom : String255);
  var aux,i : SInt64;
      pseudoUTF8 : String255;
  begin
    if not(MemberOfStringSet(pseudo,aux,gImportDesNoms.pseudosInconnus)) then
      begin

        if (nom = '???') or (nom = '') then
          begin
            pseudoUTF8 := UTF8ToAscii(pseudo);
            WriteDansRapport(message_erreur + pseudoUTF8);
            for i := 1 to (16 - LENGTH_OF_STRING(pseudoUTF8)) do
              WriteDansRapport(' ');
            WriteDansRapport(' = ');

            if (pseudoUTF8 <> pseudo) then
              WriteDansRapport('            (traduit de l''UTF8 : ' + pseudo + ' )');

            WritelnDansRapport('');
          end;

        AddStringToSet(pseudo,kNroJoueurInconnu,gImportDesNoms.pseudosInconnus);
      end;
  end;


procedure AnnonceNomAAjouterDansThor(const pseudo,nom : String255);
  var aux : SInt64;
  begin
    if (nom <> '???') and (nom <> '') and
       not(MemberOfStringSet(nom,aux,gImportDesNoms.nomsReelsARajouterDansBase)) then
      begin
        WritelnDansRapport('nom réel à rajouter dans WThor : '+ nom + '        (correspondant au pseudo ' + pseudo +')');
        AddStringToSet(nom,kNroJoueurInconnu,gImportDesNoms.nomsReelsARajouterDansBase);
      end;
  end;


function PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos, pseudo : String255; strict : boolean; var nomDansThor : String255; var numeroDansThor : SInt64) : boolean;
var nouveauNumero : SInt64;
    pseudoArrivee, pseudoLong, nom, prenom : String255;
    inverserNomEtPrenom, pseudoContientDesEspaces : boolean;
    confiance, nouvelleConfiance : SInt64;

    procedure SortirSurEchec;
    begin
      numeroDansThor := kNroJoueurInconnu;
      nomDansThor := GetNomJoueur(kNroJoueurInconnu);
      AddStringToSet(pseudoArrivee,numeroDansThor,gImportDesNoms.pseudosNomsDejaVus);
      PeutImporterNomJoueurFormatPGN := false;
      // WritelnDansRapport('Sortir sur echec : ' + pseudoArrivee);
      exit;
    end;


begin

  if (pseudo = '???') then
    begin
      PeutImporterNomJoueurFormatPGN := true;
      nomDansThor := GetNomJoueur(kNroJoueurInconnu);
      numeroDansThor := kNroJoueurInconnu;
      confiance := 100;
      exit;
    end;


  PeutImporterNomJoueurFormatPGN := false;
  nomDansThor := '';
  numeroDansThor := kNroJoueurInconnu;
  confiance := 0;

  StripHTMLAccents(pseudo);


  {WritelnDansRapport('Entree dans PeutImporterNomJoueurFormatPGN, pseudo = ' + pseudo); }

  if not(MemberOfStringSet(pseudo,numeroDansThor,gImportDesNoms.pseudosNomsDejaVus)) then
    begin

      pseudoArrivee := UTF8ToAscii(pseudo);

      (*
      testHTML := pseudoArrivee;
      StripHTMLAccents(pseudoArrivee);

      if (testHTML <> pseudoArrivee) then
        begin
          WRitelnDansRapport('HTML STRIP : pseudoArrivee = ' + pseudoArrivee);
        end;
      *)


      // StripHTMLAccents(pseudoArrivee);

      if (LENGTH_OF_STRING(pseudoArrivee) <= 2) and not(EstUnNomChinoisDeDeuxLettresOuMoins(pseudoArrivee))
        then SortirSurEchec;



      pseudoContientDesEspaces := (Pos(' ',pseudoArrivee) > 0);

      for inverserNomEtPrenom := false to pseudoContientDesEspaces do
        begin

          pseudo     := pseudoArrivee;
          pseudoLong := pseudoArrivee;

          if inverserNomEtPrenom then
            begin
              Parser(pseudo, nom, prenom);
              pseudo := prenom + ' ' + nom;
              pseudoLong := pseudo;
            end;

          // WritelnDansRapport('pseudo = '+pseudo);

          if (LENGTH_OF_STRING(pseudo) > LongueurPlusLongNomDeJoueurDansBase) and
             (LongueurPlusLongNomDeJoueurDansBase > 10)
            then pseudo := LeftStr(pseudo, LongueurPlusLongNomDeJoueurDansBase);

          //WritelnDansRapport('après troncature, pseudo = ' + pseudo);


          { on utilise le dictionnaire des pseudos "name_mapping_VOG_to_WThor.txt" pour
            transformer si necessaire un pseudo Internet en nom dans la base WThor }
          nomDansThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos, pseudo);

          if (nomDansThor = '') then SortirSurEchec;

          if (numeroDansThor <= kNroJoueurInconnu) or (confiance < 100) then
            begin
              if TrouveNumeroDeCeNomDeJoueurDansLaBaseThor(LeftStr(nomDansThor,LongueurPlusLongNomDeJoueurDansBase), nouveauNumero, nouvelleConfiance)
                then
                  begin
                    if (nouvelleConfiance > confiance) and (nouveauNumero > kNroJoueurInconnu) then
                      begin
                        confiance      := nouvelleConfiance;
                        numeroDansThor := nouveauNumero;
                      end;
                  end
                else
                  begin
                    AnnonceNomAAjouterDansThor(pseudoArrivee,nomDansThor);
                  end;
            end;


          // WritelnDansRapport('nomDansThor (1) = ' + nomDansThor);





          { à tout hasard, on essaie de voir si le pseudo ne serait pas
            directement un nom de joueur dans la base WThor :-)        }
          if not(strict) then
            if (numeroDansThor <= kNroJoueurInconnu) or (confiance < 100) then
              begin
                if TrouveNumeroDeCeNomDeJoueurDansLaBaseThor(pseudo, nouveauNumero, nouvelleConfiance)
                  and (nouvelleConfiance > confiance) and (nouveauNumero > kNroJoueurInconnu) then
                    begin
                      confiance      := nouvelleConfiance;
                      numeroDansThor := nouveauNumero;
                    end;
              end;


          { on essaie aussi de voir s'il n'existerait pas un nom dans
            la base Wthor qui serait un préfixe de notre pseudo... :-)   }
          if not(strict) then
            if (numeroDansThor <= kNroJoueurInconnu) or (confiance < 100) then
               begin
                 if TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor(pseudoLong,nouveauNumero,nouvelleConfiance)
                   and (nouvelleConfiance > confiance) and (nouveauNumero > kNroJoueurInconnu) then
                    begin
                      confiance      := nouvelleConfiance;
                      numeroDansThor := nouveauNumero;
                    end;
               end;

        end;




       { on essaie aussi de voir si une permutation des lexemes ne
         permet pas de conclure...  C'est la routine la plus lente
         pour les cas desespérés }
        if not(strict) then
          if (numeroDansThor <= kNroJoueurInconnu) or (confiance < 100) then
             begin
               if TrouveLexemesDeCeNomDeJoueurDansLaBaseThor(pseudoLong,nouveauNumero,nouvelleConfiance)
                 and (nouvelleConfiance > confiance) and (nouveauNumero > kNroJoueurInconnu) then
                  begin
                    confiance      := nouvelleConfiance;
                    numeroDansThor := nouveauNumero;
                  end;
             end;


       { on essaie aussi de voir s'il n'existerait pas un nom dans
         la base Wthor qui contiendrait une sous-chaine de notre pseudo...  }
        if not(strict) then
          if (numeroDansThor <= kNroJoueurInconnu) then
             begin
               if TrouveSousChaineDeCeNomDeJoueurDansLaBaseThor(pseudoArrivee,nouveauNumero,nouvelleConfiance)
                 and (nouvelleConfiance > confiance) and (nouveauNumero > kNroJoueurInconnu) then
                  begin
                    confiance      := nouvelleConfiance;
                    numeroDansThor := nouveauNumero;
                  end;
             end;


      AddStringToSet(pseudoArrivee,numeroDansThor,gImportDesNoms.pseudosNomsDejaVus);

      (*
      if (numeroDansThor > 0) then
        begin
          WritelnDansRapport('nomDansThor (2) = ' + GetNomJoueur(numeroDansThor));
          WritelnDansRapport('    remarque :   pseudoArrivee = ' + pseudoArrivee);
        end;
      *)

    end;

  if (numeroDansThor < 0) then numeroDansThor := kNroJoueurInconnu;

  if (numeroDansThor > kNroJoueurInconnu)
    then nomDansThor := GetNomJoueur(numeroDansThor)
    else nomDansThor := GetNomJoueur(kNroJoueurInconnu);



  PeutImporterNomJoueurFormatPGN := (numeroDansThor > kNroJoueurInconnu);
end;


function PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,pseudo : String255; var nomDansThor : String255; var numeroDansThor : SInt64) : boolean;
var numeroDirect : SInt64;
begin
  PeutImporterNomTournoiFormatPGN := false;
  nomDansThor := '';

  if not(MemberOfStringSet(pseudo,numeroDansThor,gImportDesNoms.pseudosTournoisDejaVus)) then
    begin
      nomDansThor := PseudoPGNEnNomDansBaseThor(nomDictionnaireDesPseudos,pseudo);

      if nomDansThor = '' then nomDansThor := '???';

      if not(TrouveNumeroDuTournoi(nomDansThor,numeroDansThor,0)) then
        begin
          numeroDansThor := kNroTournoiDiversesParties;
          AnnonceNomAAjouterDansThor(pseudo,nomDansThor);
        end;

      { à tout hasard, on essaie de voir si le pseudo ne serait pas
        directement un nom de tournoi dans la base WThor :-)       }
      if (numeroDansThor = kNroTournoiDiversesParties) and TrouveNumeroDuTournoi(pseudo,numeroDirect,0)
        then
          begin
            numeroDansThor := numeroDirect;
            nomDansThor := GetNomTournoi(numeroDirect);
          end;

      AddStringToSet(pseudo,numeroDansThor,gImportDesNoms.pseudosTournoisDejaVus);
    end;

  PeutImporterNomTournoiFormatPGN := (numeroDansThor <> kNroTournoiDiversesParties);
end;


function TrouverNomDeTournoiDansPath(path : String255; var numeroTournoi,annee : SInt64; nomDictionnaireDesPseudos : String255) : boolean;
var oldParsingSet : SetOfChar;
    s,reste : String255;
    numero,essaiAnnee : SInt64;
    nomDansThor : String255;
    currentDate : DateTimeRec;
begin
  TrouverNomDeTournoiDansPath := false;

  GetTime(currentDate);
  for essaiAnnee := 1980 to currentDate.year+2 do
    begin
      s := IntToStr(essaiAnnee);
      if Pos(s,path) > 0 then
        annee := essaiAnnee;
    end;

  oldParsingSet := GetParsingCaracterSet;
	SetParsingCaracterSet([':','0','1','2','3','4','5','6','7','8','9']);

	reste := path;
	if (reste <> '') then
	  begin
	    Parser(reste,s,reste);
	
	    { essayer recursivement sur le reste : ceci permet de commencer par la fin }
	    if TrouverNomDeTournoiDansPath(reste, numero, annee, nomDictionnaireDesPseudos) then
	      begin
	        numeroTournoi := numero;
	        TrouverNomDeTournoiDansPath := true;
	        SetParsingCaracterSet(oldParsingSet);
	        exit;
	      end;
	
	    EnleveEspacesDeGaucheSurPlace(s);
	    EnleveEspacesDeDroiteSurPlace(s);
	
	    if PeutImporterNomTournoiFormatPGN(nomDictionnaireDesPseudos,s,nomDansThor,numero) then
	      begin
	        numeroTournoi := numero;
	        TrouverNomDeTournoiDansPath := true;
	        SetParsingCaracterSet(oldParsingSet);
	        exit;
	      end;
	  end;

	SetParsingCaracterSet(oldParsingSet);
end;


function TrouverNomsDesJoueursDansNomDeFichier(s : String255; var numeroJoueur1,numeroJoueur2 : SInt64; longueurMinimaleUnPseudo : SInt64; var qualiteSolution : double) : boolean;
const kNbMaxChaines = 30;
      kSegmentNonCherche = -2;
      nomDictionnaireDesPseudos = 'name_mapping_VOG_to_WThor.txt';
var nbJoueursTrouves : SInt64;
    nbSousChaines : SInt64;
    chunkNumber : SInt64;
    longueurBestSolution : SInt64;
    distanceBestSolution : SInt64;
    longueurTotale : SInt64;
    oldQuoteProtection : boolean;
    oldParsingSet : SetOfChar;
    chaines : array[1..kNbMaxChaines] of String255;
    chunk : array[1..kNbMaxChaines] of SInt64;
    reste,separateurs,tempo : String255;
    partieDigeree,partieNonDigeree : String255;
    positionUtile : SInt64;
    nomNoir,nomBlanc : String255;
    numeroNoir,numeroBlanc : SInt64;
    termine,bidon : boolean;
    memoisation : array[0..kNbMaxChaines,0..kNbMaxChaines] of SInt64;
    theParsingCaracters : SetOfChar;
    confiance : double;
    numeroNoirBestSolution : SInt64;
    numeroBlancBestSolution : SInt64;


  procedure PublishSolution(pseudoNoir,pseudoBlanc : String255);
  var longueurDeCetteSolution : SInt64;
      nomThorNoir, nomThorBlanc : String255;
      distanceDeCetteSolution : SInt64;
  begin
    longueurDeCetteSolution := LENGTH_OF_STRING(pseudoNoir) + LENGTH_OF_STRING(pseudoBlanc);

    nomThorNoir  := GetNomJoueurEnMajusculesSansEspace(numeroNoir);
    nomThorBlanc := GetNomJoueurEnMajusculesSansEspace(numeroBlanc);

    pseudoNoir  := FabriqueNomEnMajusculesSansEspaceSansMetaphone(pseudoNoir);
    pseudoBlanc := FabriqueNomEnMajusculesSansEspaceSansMetaphone(pseudoBlanc);

    distanceDeCetteSolution :=   PseudoHammingDistance(pseudoNoir  , nomThorNoir)
                               + PseudoHammingDistance(pseudoBlanc , nomThorBlanc)
                               - (LENGTH_OF_STRING(pseudoNoir) - 1) * 2
                               - (LENGTH_OF_STRING(pseudoBlanc) - 1) * 2 ;


    if (Pos(pseudoNoir, nomThorNoir) = 1) and (Pos(pseudoBlanc, nomThorBlanc) = 1)
      then distanceDeCetteSolution := distanceDeCetteSolution - 5;

    (*
    WriteDansRapport('PublishSolution :   ' + pseudoNoir+ ' , ' + pseudoBlanc);
    WriteDansRapport('                             ' + nomThorNoir+ ' , ' + nomThorBlanc);
    WritelnNumDansRapport('  dist = ',distanceDeCetteSolution);
    *)


    if (distanceDeCetteSolution < distanceBestSolution) or
       ((distanceDeCetteSolution = distanceBestSolution) and (longueurDeCetteSolution > longueurBestSolution)) then
      begin
        numeroNoirBestSolution  := numeroNoir;
        numeroBlancBestSolution := numeroBlanc;
        distanceBestSolution    := distanceDeCetteSolution;
        longueurBestSolution    := longueurDeCetteSolution;
      end;
  end;

  function PeutTrouverNomDeJoueurDansWThor(var pseudo : String255; var numero : SInt64) : boolean;
  var nom : String255;
  begin
    EnleveEspacesDeGaucheSurPlace(pseudo);
	  EnleveEspacesDeDroiteSurPlace(pseudo);

	  if (pseudo = '')
	    then PeutTrouverNomDeJoueurDansWThor := false
	    else PeutTrouverNomDeJoueurDansWThor := PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudo,false,nom,numero)
  end;


  function PeutTrouverDeuxNomsDeJoueursDansWThor(pseudoNoir,pseudoBlanc : String255) : boolean;
  var ok : boolean;
  begin
    EnleveEspacesDeGaucheSurPlace(pseudoNoir);
	  EnleveEspacesDeDroiteSurPlace(pseudoNoir);
	  EnleveEspacesDeGaucheSurPlace(pseudoBlanc);
	  EnleveEspacesDeDroiteSurPlace(pseudoBlanc);

	  if (pseudoNoir = '') or (pseudoBlanc = '')
	    then PeutTrouverDeuxNomsDeJoueursDansWThor := false
	    else
	      begin
	        ok := PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudoNoir,false,nomNoir,numeroNoir) and
	              PeutImporterNomJoueurFormatPGN(nomDictionnaireDesPseudos,pseudoBlanc,false,nomBlanc,numeroBlanc);

	        if ok then PublishSolution(pseudoNoir,pseudoBlanc);

	        PeutTrouverDeuxNomsDeJoueursDansWThor := ok;
	      end;
  end;


  function MakePseudo(imin,imax : SInt64; coupurePrenoms : SInt16) : String255;
    var result : String255;
        t : SInt64;
    begin
      result := '';

      for t := imin + coupurePrenoms to imax do
        result := result + chaines[t] + ' ';
      for t := imin to imin + coupurePrenoms - 1 do
        result := result + chaines[t] + ' ';


      MakePseudo := result;
    end;


  function TrouvePseudoEtNumeroJoueurDansMorceau(imin,imax : SInt64; var numero : SInt64; var nom : String255) : boolean;
  var permutation : String255;
      coupurePrenom : SInt64;
      chunkCherche,n : SInt64;
  begin


    { On teste si toutes les chaines du morceau ont le meme degre de chunk.
      Si ce n'est pas le cas, on refuse de chercher }
    chunkCherche := chunk[imin];
    for n := imin+1 to imax do
      if chunk[n] <> chunkCherche then
        begin
          nom := '';
          TrouvePseudoEtNumeroJoueurDansMorceau := false;
          exit;
        end;


    { On teste si toutes les chaines entre imin et imax ont une
      longueur de 1, ou si le morceau est trop court : dans ce cas,
      on choisit de ne meme pas chercher }
    permutation := MakePseudo(imin,imax,0);
    if (LENGTH_OF_STRING(permutation) <= 2*(imax - imin + 1)) or
       (LENGTH_OF_STRING(permutation) < longueurMinimaleUnPseudo) then
      begin
        nom := '';
        TrouvePseudoEtNumeroJoueurDansMorceau := false;
        exit;
      end;


    { Maintenant on peut chercher }
    if (imax >= imin) and (numero <> kNroJoueurInconnu) then
      for coupurePrenom := 0 to (imax - imin) do
        begin
          permutation := MakePseudo(imin,imax,coupurePrenom);

          // WritelnDansRapport('permutation = '+permutation);

          if PeutTrouverNomDeJoueurDansWThor(permutation,numero) then
            begin
              nom := permutation;
              TrouvePseudoEtNumeroJoueurDansMorceau := true;

              // WritelnDansRapport('permutation trouvee = '+GetNomJoueur(numero));

              exit;
            end;

          if (LENGTH_OF_STRING(permutation) > LongueurPlusLongNomDeJoueurDansBase) then
            begin
              permutation := LeftStr(permutation,LongueurPlusLongNomDeJoueurDansBase);
              if PeutTrouverNomDeJoueurDansWThor(permutation,numero) then
                begin
                  nom := permutation;
                  TrouvePseudoEtNumeroJoueurDansMorceau := true;
                  exit;
                end;
            end;

        end;

    permutation := MakePseudo(imin,imax,0);
    if EstUnPseudoDontLeDictionaireConfirmeQuOnNeConnaitPasLeNomReel(permutation) then
      begin
        // WritelnDansRapport(permutation + ' est un pseudo inconnu dont on est sûr qu''il est inconnu, je le remplace par ??? ');
        numero := kNroJoueurInconnu;
        nom    := GetNomJoueur(kNroJoueurInconnu);
        TrouvePseudoEtNumeroJoueurDansMorceau := true;
        exit;
      end;

    nom := '';
    TrouvePseudoEtNumeroJoueurDansMorceau := false;
  end;



  procedure SplitTableByThree(i,j,k : SInt64);
  var nom1,nom2,nom3 : String255;
      numero1,numero2,numero3 : SInt64;
      imin1,imin2,imin3 : SInt64;
      imax1,imax2,imax3 : SInt64;
      nbMorceauxImpossibles : SInt64;
      trouve1,trouve2,trouve3 : boolean;
  begin

    imin1 := i;
    imax1 := j-1;
    imin2 := j;
    imax2 := k-1;
    imin3 := k;
    imax3 := nbSousChaines;

    numero1 := memoisation[imin1,imax1];
    numero2 := memoisation[imin2,imax2];
    numero3 := memoisation[imin3,imax3];

    nbMorceauxImpossibles := 0;

    if (numero1 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (numero2 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (numero3 = kNroJoueurInconnu) then inc(nbMorceauxImpossibles);
    if (nbMorceauxImpossibles >= 2) then
      exit;


    trouve1 := TrouvePseudoEtNumeroJoueurDansMorceau(imin1,imax1,numero1,nom1);
    trouve2 := TrouvePseudoEtNumeroJoueurDansMorceau(imin2,imax2,numero2,nom2);
    trouve3 := TrouvePseudoEtNumeroJoueurDansMorceau(imin3,imax3,numero3,nom3);

    memoisation[imin1,imax1] := numero1;
    memoisation[imin2,imax2] := numero2;
    memoisation[imin3,imax3] := numero3;

    (*
    WritelnNumDansRapport('Memoisation['+IntToStr(imin1)+','+IntToStr(imax1)+'] = ',memoisation[imin1,imax1]);
    WritelnNumDansRapport('Memoisation['+IntToStr(imin2)+','+IntToStr(imax2)+'] = ',memoisation[imin2,imax2]);
    WritelnNumDansRapport('Memoisation['+IntToStr(imin3)+','+IntToStr(imax3)+'] = ',memoisation[imin3,imax3]);
    *)


	  if (trouve1) and (trouve2) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom1,nom2);
	  if (trouve2) and (trouve3) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom2,nom3);
	  if (trouve1) and (trouve3) then bidon := PeutTrouverDeuxNomsDeJoueursDansWThor(nom1,nom3);

	  {WritelnDansRapport('');}
	  {Attendfrappeclavier;}

  end;


  function TrouverNomsAvecCeParsingSet(parsingCaracters : SetOfChar; var confiance : double) : boolean;
  var i,j,k : SInt64;
      aux : String255;
  begin

    TrouverNomsAvecCeParsingSet := false;
    confiance := 0.0;

    if (s <> '') then
      begin

        if not(JoueursEtTournoisEnMemoire) then
          begin
            WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
            WritelnDansRapport('');
            DoLectureJoueursEtTournoi(false);
          end;

        nbJoueursTrouves := 0;
        confiance := 0.0;
        longueurBestSolution    := -1000;
        distanceBestSolution    := 1000;
        numeroNoirBestSolution  := kNroJoueurInconnu;
        numeroBlancBestSolution := kNroJoueurInconnu;

        oldQuoteProtection := GetParsingProtectionWithQuotes;
        SetParsingProtectionWithQuotes(true);


        oldParsingSet := GetParsingCaracterSet;
        SetParsingCaracterSet(parsingCaracters);


      	reste := s;
      	i := 0;
      	chunkNumber := 1;

      	separateurs      := '';
      	partieDigeree    := '';
      	partieNonDigeree := s;

      	while (reste <> '') and (i < kNbMaxChaines) do
      	  begin
      	    inc(i);
      	    Parser(reste,chaines[i],reste);

      	    if (chaines[i] <> '') then
      	      begin
      	        positionUtile := Pos(chaines[i],partieNonDigeree);

      	        {separateurs est la chaine des caracteres sautes lors
      	         du dernier appel a Parser(reste,chaines[i],reste)  }
      	        separateurs := TPCopy(partieNonDigeree,1,positionUtile - 1);

      	        {on garde l'invariant   "partieDigeree + partieNonDigeree = s"  }
      	        partieDigeree := partieDigeree + separateurs + chaines[i];
      	        partieNonDigeree := TPCopy(partieNonDigeree,positionUtile + LENGTH_OF_STRING(chaines[i]), 255);
      	      end;



      	    while (LENGTH_OF_STRING(chaines[i]) > 0) and ( chaines[i][1] = '-') do
      	      chaines[i] := TPCopy(chaines[i],2,LENGTH_OF_STRING(chaines[i])-1);

      	    (* optimisation : on enlève les extensions de fichier *)
      	    if (chaines[i] = 'txt') then chaines[i] := '';
      	    if (chaines[i] = 'TXT') then chaines[i] := '';
      	    if (chaines[i] = 'wzg') then chaines[i] := '';
      	    if (chaines[i] = 'WZG') then chaines[i] := '';
      	    if (chaines[i] = 'pgn') then chaines[i] := '';
      	    if (chaines[i] = 'PGN') then chaines[i] := '';
      	    if (chaines[i] = 'sof') then chaines[i] := '';
      	    if (chaines[i] = 'SOF') then chaines[i] := '';
      	    if (chaines[i] = 'sgf') then chaines[i] := '';
      	    if (chaines[i] = 'SGF') then chaines[i] := '';
      	    if (chaines[i] = 'ggf') then chaines[i] := '';
      	    if (chaines[i] = 'GGF') then chaines[i] := '';
      	    if (chaines[i] = 'eps') then chaines[i] := '';
      	    if (chaines[i] = 'EPS') then chaines[i] := '';
      	    if (chaines[i] = 'pdf') then chaines[i] := '';
      	    if (chaines[i] = 'PDF') then chaines[i] := '';


      	    {les lexemes composes seulement de chiffres sont probablement
      	     des scores, on les utilise comme separateurs de chunks }
      	    if (chaines[i] = GarderSeulementLesChiffres(chaines[i]))
      	       or not(ContientUneLettre(chaines[i]))
      	       or (StrToInt32(GarderSeulementLesChiffres(separateurs)) <> 0)
      	      then inc(chunkNumber);

            {la chaine 'vs' est probablement un séparateur de chunk}
            if (chaines[i] = 'vs') or (chaines[i] = 'VS') then
              begin
                chaines[i] := '';
                inc(chunkNumber);
              end;

      	    chaines[i] := StripDiacritics(chaines[i]);
      	    chunk[i]   := chunkNumber;


      	    EnleveEspacesDeGaucheSurPlace(chaines[i]);
      	    EnleveEspacesDeDroiteSurPlace(chaines[i]);
      	    if (chaines[i] = '') or
      	       (chaines[i] = '-') or
      	       (chaines[i] = '_') or
      	       (chaines[i] = '–') or
      	       (chaines[i] = '—') or
      	       (chaines[i] = '--') or
      	       (chaines[i] = '__') or
      	       (chaines[i] = '——') or
      	       (chaines[i] = '––') or
      	       (chaines[i] = GarderSeulementLesChiffres(chaines[i])) or
      	       ((chaines[i] = 'r') and (i = 1) and (s[2] <> ' ')) or
      	       ((chaines[i] = 'R') and (i = 1) and (s[2] <> ' ')) or
      	       ((chaines[i] = 'round') and (i = 1)) or
      	       ((chaines[i] = 'Round') and (i = 1))
      	      then dec(i);
      	
      	    aux := chaines[i];
      	    chaines[i] := ReplaceStringOnce(aux, 'ZEROZEROSEPT' , '007');
      	
      	  end;
      	nbSousChaines := i;

        {debug : affichage de chunks }
      	{
      	for i := 1 to nbSousChaines do
      	  WritelnNumDansRapport(chaines[i]+ '  : chunk = ',chunk[i]);
      	}

      	for i := 0 to nbSousChaines do
      	  for j := 0 to nbSousChaines do
      	    if (j < i)
      	      then memoisation[i,j] := kNroJoueurInconnu
      	      else memoisation[i,j] := kSegmentNonCherche;

      	(* La recherche propremement dite *)
      	termine := false;
      	for i := 1 to nbSousChaines do
      	  for j := i to nbSousChaines do
      	    for k := j to nbSousChaines do
      	      if not(termine) then SplitTableByThree(i,j,k);


      	SetParsingCaracterSet(oldParsingSet);
        SetParsingProtectionWithQuotes(oldQuoteProtection);

        longueurTotale := 0;
        for i := 1 to nbSousChaines do
          longueurTotale := longueurTotale + LENGTH_OF_STRING(chaines[i]) + 1;

        if (longueurTotale > 0) and (longueurBestSolution > 0)
          then confiance := 1.0*longueurBestSolution/longueurTotale;

        TrouverNomsAvecCeParsingSet := (longueurBestSolution > 0);

    end;
  end;


  procedure ComparerCetteSolutionALaMeilleure(confianceCetteSolution : double; nroNoirCetteSolution,nroBlancCetteSolution : SInt64);
  begin
    if (confianceCetteSolution > qualiteSolution) then
      begin
        TrouverNomsDesJoueursDansNomDeFichier := true;
        qualiteSolution := confianceCetteSolution;
        numeroJoueur1   := nroNoirCetteSolution;
        numeroJoueur2   := nroBlancCetteSolution;
      end;
  end;


begin  {TrouverNomsDesJoueursDansNomDeFichier}

  s := UTF8ToAscii(s);
  StripHTMLAccents(s);

  tempo := ReplaceStringOnce(s,     '007' , 'ZEROZEROSEPT');
  s     := ReplaceStringOnce(tempo, '007' , 'ZEROZEROSEPT');

  {WritelnDansRapport('appel de TrouverNomsDesJoueursDansNomDeFichier,   s = ' + s);}

  TrouverNomsDesJoueursDansNomDeFichier := false;
  qualiteSolution := 0.0;


  theParsingCaracters := ['-','–','.',',',';',':','+','¿','/','\','|','~','≠','±','÷','@','#','•',' ',' ','(',')','{','}','[',']','0','1','2','3','4','5','6','7','8','9'];
  if TrouverNomsAvecCeParsingSet(theParsingCaracters,confiance) then
    ComparerCetteSolutionALaMeilleure(confiance,numeroNoirBestSolution,numeroBlancBestSolution);


  { Si la chaine contient des underscores, il se peut qu'ils soient utilisés comme séparateurs }
  if (Pos('_',s) > 0) or (Pos('_',s) > 0) then
    begin
      theParsingCaracters := ['-','–','.',',',';',':','+','¿','/','\','|','~','≠','±','÷','@','#','•',' ',' ','(',')','{','}','[',']','0','1','2','3','4','5','6','7','8','9','_','_'];
      if TrouverNomsAvecCeParsingSet(theParsingCaracters,confiance) then
        ComparerCetteSolutionALaMeilleure(confiance,numeroNoirBestSolution,numeroBlancBestSolution);
    end;


   {WritelnStringAndReelDansRapport(GetNomJoueur(numeroJoueur1) + '  vs  '+GetNomJoueur(numeroJoueur2) + ',   confiance = ',confiance,5);}

end;  {TrouverNomsDesJoueursDansNomDeFichier}




procedure InitUnitImportDesNoms;
begin
  with gImportDesNoms do
    begin
      pseudosInconnus            := MakeEmptyStringSet;
      pseudosNomsDejaVus         := MakeEmptyStringSet;
      pseudosTournoisDejaVus     := MakeEmptyStringSet;
      pseudosAyantUnNomReel      := MakeEmptyStringSet;
      pseudosSansNomReel         := MakeEmptyStringSet;
      nomsReelsARajouterDansBase := MakeEmptyStringSet;

      (* Attention : les chaines ci-dessous doivent etre celles que
         l'on veut tester dans les fonctions TesterFormesALternatives()    *)
      formesPossiblesDesVanDen   := MakeEmptyATR;
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('van den '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('van de '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('van der '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('von de '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('von der '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('vd '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('v. d. '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('v d '));
      InsererDansATR(formesPossiblesDesVanDen, FabriqueNomEnMajusculesAvecEspaces('v/d '));
    end;
end;

procedure LibereMemoireImportDesNoms;
begin
  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(pseudosAyantUnNomReel);
      DisposeStringSet(pseudosSansNomReel);
      DisposeStringSet(nomsReelsARajouterDansBase);
      DisposeATR(formesPossiblesDesVanDen);
    end;
end;




procedure TraduitNomTournoiEnMac(ancNom : String255; var nouveauNom : String255);
var c,premierCaractere : char;
    i : SInt64;
    MoisEnChiffre : String255;
    MoisEnLettres : String255;
begin
  nouveauNom := '';
  for i := 1 to LENGTH_OF_STRING(ancNom) do
    begin
      c := ancNom[i];

      (*
      if effetspecial2 then
      if (c <> ' ') and (c <> '.') and (c <> '-') then
      if not(((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z'))) then
        begin
          EssaieSetPortWindowPlateau;
          WriteNumAt(c+' soit ASCII #',ord(c),10,10);
          WriteStringAt(ancNom,10,20);
          AttendFrappeClavierOuSouris(effetspecial2);
        end;
      *)

      if ord(c) = 233 then c := 'é' else
      if ord(c) = 232 then c := 'è' else
      if c = 'Ç' then c := 'é' else
      if c = 'ä' then c := 'è';
      nouveauNom := Concat(nouveauNom,c);
    end;

  case traductionMoisTournoi of
    SucrerPurementEtSimplement:
      if nouveauNom[25] = '/' then
        begin
          nouveauNom[25] := ' ';
          nouveauNom[24] := ' ';
          if (nouveauNom[23] >= '0') and (nouveauNom[23] <= '9') then nouveauNom[23] := ' ';
        end;
    MoisEnToutesLettres:
      if nouveauNom[25] = '/' then
        begin
          MoisEnChiffre := Concat(nouveauNom[24],nouveauNom[25]);
          if MoisEnChiffre = '01' then MoisEnLettres := 'jan' else
          if MoisEnChiffre = '02' then MoisEnLettres := 'fev' else
          if MoisEnChiffre = '03' then MoisEnLettres := 'mar' else
          if MoisEnChiffre = '04' then MoisEnLettres := 'avr' else
          if MoisEnChiffre = '05' then MoisEnLettres := 'mai' else
          if MoisEnChiffre = '06' then MoisEnLettres := 'jun' else
          if MoisEnChiffre = '07' then MoisEnLettres := 'jui' else
          if MoisEnChiffre = '08' then MoisEnLettres := 'aou' else
          if MoisEnChiffre = '09' then MoisEnLettres := 'sep' else
          if MoisEnChiffre = '10' then MoisEnLettres := 'oct' else
          if MoisEnChiffre = '11' then MoisEnLettres := 'nov' else
          if MoisEnChiffre = '12' then MoisEnLettres := 'dec';
          nouveauNom[23] := MoisEnLettres[1];
          nouveauNom[24] := MoisEnLettres[2];
          nouveauNom[25] := MoisEnLettres[3];
        end;
  end; {case}

  premierCaractere := nouveauNom[1];

  {
  if premierCaractere = 'D' then
    nouveauNom := ReplaceStringOnce('Divers avant et pendant',
                                                'Diverses parties avant',nouveauNom);
  }
end;

procedure TraduitNomJoueurEnMac(ancNom : String255; var nouveauNom : String255);
var c,premierCaractere : char;
    i : SInt64;
begin
  nouveauNom := '';
  for i := 1 to LENGTH_OF_STRING(ancNom) do
    begin
      c := ancNom[i];

      {
      if effetspecial2 then
      if (c <> ' ') and (c <> '.') and (c <> '-') then
      if not(((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z'))) then
        begin
          EssaieSetPortWindowPlateau;
          WriteNumAt(c+' soit ASCII #',ord(c),10,10);
          WriteStringAt(ancNom,10,20);
          AttendFrappeClavierOuSouris(effetspecial2);
        end;
      }

      if ord(c) = 233 then c := 'é' else
      if ord(c) = 232 then c := 'è' else
      if c = 'Ç' then c := 'é' else
      if c = 'ä' then c := 'è';
      nouveauNom := Concat(nouveauNom,c);
    end;

  premierCaractere := nouveauNom[1];

  if (premierCaractere = 'C') then
    nouveauNom := ReplaceStringOnce(nouveauNom, 'Cassio (nicolet)' , 'Cassio (coucou !)');

 (*
  if (premierCaractere = 'D') and (nouveauNom = 'Di Mattei Alessandr') then
    nouveauNom := ReplaceStringOnce(nouveauNom, 'Di Mattei Alessandr' , 'Di Mattei Alessandro');
  if (premierCaractere = 'L') and (nouveauNom = 'Lévy-Abégnoli Thier') then
    nouveauNom := ReplaceStringOnce(nouveauNom, 'Lévy-Abégnoli Thier' , 'Lévy-Abégnoli Thierry');
  *)

  if (premierCaractere = 'M') then
    nouveauNom := ReplaceStringOnce(nouveauNom, 'Modot (feinstein)' , 'Modot (joel)');
  if (premierCaractere = 'T') then
    nouveauNom := ReplaceStringOnce(nouveauNom, 'Tom Pouce (andrian)' , 'Tom Pouce (bintsa)');
  if (premierCaractere = '5') then
    nouveauNom := ReplaceStringOnce(nouveauNom, '5semaines (lanuit)' , 'Cinq semaines ()');
  if not(gVersionJaponaiseDeCassio and gHasJapaneseScript) then
    begin
		  if premierCaractere = 'B' then
		    begin
		      nouveauNom := ReplaceStringOnce(nouveauNom, 'Bracchi Andre' , 'Bracchi André');
		      nouveauNom := ReplaceStringOnce(nouveauNom, 'Bernou Stephan' , 'Bernou Stéphan');
		      nouveauNom := ReplaceStringOnce(nouveauNom, 'Betin' , 'Bétin');
		    end;
		  if premierCaractere = 'G' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Grison Remi' , 'Grison Rémi');
		  if premierCaractere = 'T' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Tastet Remi' , 'Tastet Rémi');
		  if premierCaractere = 'S' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Seknadje Jose' , 'Seknadjé José');
		  if premierCaractere = 'T' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Theole' , 'Théole');
		  if premierCaractere = 'L' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Lery Michele' , 'Léry Michèle');
		  if premierCaractere = 'P' then
		    nouveauNom := ReplaceStringOnce(nouveauNom, 'Puree' , 'Purée');

		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Stephane' , 'Stéphane');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Stephanie' , 'Stéphanie');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Sebastien' , 'Sébastien');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Angeliqu' , 'Angéliqu');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Frederic' , 'Frédéric');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Frédérico' , 'Frederico');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Valerie' , 'Valérie');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Beatrice' , 'Béatrice');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Gerard' , 'Gérard');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Gerald' , 'Gérald');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Jerome' , 'Jérôme');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Herve' , 'Hervé');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Francois' , 'François');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Aurelien' , 'Aurélien');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Aurelie' , 'Aurélie');

		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Candbek (quin/herve)' , 'Candbek (quin/hervé)');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Pege' , 'Pégé');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Masse' , 'Massé');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Nelis' , 'Nélis');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Muntane' , 'Muntané');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Aubree' , 'Aubrée');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Bandres' , 'Bandrés');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Gael' , 'Gaël');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Cecillon' , 'Cécillon');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Clerice' , 'Clérice');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Dauba Cedric' , 'Dauba Cédric');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Decoeyere' , 'Decoeyère');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Dupre' , 'Dupré');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Gelin' , 'Gélin');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Edo Jose' , 'Edo José');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Benyaich Joel' , 'Benyaich Joël');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Eymard Joel' , 'Eymard Joël');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Freyss Joel' , 'Freyss Joël');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Levy-Abegnoli' , 'Lévy-Abégnoli');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Neron-Bancel' , 'Néron-Bancel');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Regis' , 'Régis');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Ruben' , 'Rubén');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Pelissier' , 'Pélissier');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Piquee Raphael' , 'Piquée Raphaël');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Pradere' , 'Pradère');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Cecile' , 'Cécile');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Celine' , 'Céline');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Olive Oriol' , 'Olivé Oriol');
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Fetet Clement' , 'Fétet Clément');

		  nouveauNom := ReplaceStringOnce(nouveauNom, 'iere ' , 'ière ');  {Thuilliere, de la Riviere, Retiere, etc.}
		  nouveauNom := ReplaceStringOnce(nouveauNom, 'Budino' , 'Budiño');

		end;

  {if Pos('<IOS>',nouveauNom) > 0 then
    nouveauNom := Concat(Concat('"',TPCopy(nouveauNom,6,LENGTH_OF_STRING(nouveauNom)-5)),'"');}
  if premierCaractere = '<' then
    if Pos('<IOS>',nouveauNom) > 0 then
      nouveauNom := Concat(Concat('<',TPCopy(nouveauNom,6,LENGTH_OF_STRING(nouveauNom)-5)),'>');

  if (premierCaractere = 'O') or (premierCaractere = '0') or
     (((nouveauNom[2] = 'O') or (nouveauNom[2] = '0')) and (premierCaractere = '<')) then
    begin
      nouveauNom := ReplaceStringOnce(nouveauNom, 'Oo7' , '007');{on met des vrais zéros}
      nouveauNom := ReplaceStringOnce(nouveauNom, 'OO7' , '007');
      nouveauNom := ReplaceStringOnce(nouveauNom, 'O07' , '007');
      nouveauNom := ReplaceStringOnce(nouveauNom, '0O7' , '007');
      nouveauNom := ReplaceStringOnce(nouveauNom, '0o7' , '007');
    end;

end;


procedure EnlevePrenom(const nomOrigine : String255; var nomSansPrenom : String255);
var i,longueur : SInt64;
    c : char;
begin
  nomSansPrenom := '';
  longueur := LENGTH_OF_STRING(nomOrigine);
  i := 1;
  repeat
    c := nomOrigine[i];
    if (i = 1) and (c >= 'a') and (c <= 'z') then c := chr(ord(c)-32);
    if ord(c) <> 0 then nomSansPrenom := Concat(nomSansPrenom,c);
    i := i+1;
  until ((c = ' ') and
        (nomSansPrenom <> 'Le ')       and
        (nomSansPrenom <> 'Di ')       and
        (nomSansPrenom <> 'De la ')    and
        (nomSansPrenom <> 'De ')       and
        (nomSansPrenom <> 'Des ')      and
        (nomSansPrenom <> 'Den ')      and
        (nomSansPrenom <> 'Othel ')    and
        (nomSansPrenom <> 'Othel du ') and
        (nomSansPrenom <> 'Qvist ')    and
        (nomSansPrenom <> 'Peer ')     and
        (nomSansPrenom <> 'Van ')      and
        (nomSansPrenom <> 'Van de ')   and
        (nomSansPrenom <> 'Van der ')  and
        (nomSansPrenom <> 'Van den ')  and
        (nomSansPrenom <> 'V/d ')      and
        (nomSansPrenom <> 'Vd ')       and
        (nomSansPrenom <> 'In ')       and
        (nomSansPrenom <> 'In het ')   and
        (nomSansPrenom <> 'Saint ')    and
        ((nomSansPrenom <> 'Gros ') or (nomOrigine <> 'Gros Thello (pinta)'))   and
        (nomSansPrenom <> 'Reversi ')  and
        (nomSansPrenom <> 'Pee ')      and
        (nomSansPrenom <> 'Tom ')      and
        (nomSansPrenom <> 'Von ')      and
        (nomSansPrenom <> 'La ')       and
        (nomSansPrenom <> 'Du ')       and
        (nomSansPrenom <> 'El ')       and
        (nomSansPrenom <> 'The ')      and
        (nomSansPrenom <> 'Pc ')       and
        (nomSansPrenom <> 'Des '))
        or (i > longueur) or (ord(c) = 0);
end;


function EstUnNomChinoisDeDeuxLettresOuMoins(const nomJoueur : String255) : boolean;
var nomEnMajuscules : String255;
begin

  if (LENGTH_OF_STRING(nomJoueur) > 2)
    then EstUnNomChinoisDeDeuxLettresOuMoins := false
    else
      begin
        nomEnMajuscules := UpperCase(nomJoueur, false);
        EstUnNomChinoisDeDeuxLettresOuMoins :=
           (nomEnMajuscules = 'AO') or
           (nomEnMajuscules = 'BA') or
           (nomEnMajuscules = 'BE') or
           (nomEnMajuscules = 'BO') or
           (nomEnMajuscules = 'FU') or
           (nomEnMajuscules = 'GI') or
           (nomEnMajuscules = 'HE') or
           (nomEnMajuscules = 'HO') or
           (nomEnMajuscules = 'HU') or
           (nomEnMajuscules = 'HA') or
           (nomEnMajuscules = 'IO') or
           (nomEnMajuscules = 'IU') or
           (nomEnMajuscules = 'JO') or
           (nomEnMajuscules = 'KA') or
           (nomEnMajuscules = 'KO') or
           (nomEnMajuscules = 'LE') or
           (nomEnMajuscules = 'LI') or
           (nomEnMajuscules = 'LU') or
           (nomEnMajuscules = 'LO') or
           (nomEnMajuscules = 'MA') or
           (nomEnMajuscules = 'NG') or
           (nomEnMajuscules = 'O')  or
           (nomEnMajuscules = 'OH') or
           (nomEnMajuscules = 'RA') or
           (nomEnMajuscules = 'RI') or
           (nomEnMajuscules = 'SY') or
           (nomEnMajuscules = 'TA') or
           (nomEnMajuscules = 'TE') or
           (nomEnMajuscules = 'TI') or
           (nomEnMajuscules = 'TU') or
           (nomEnMajuscules = 'TO') or
           (nomEnMajuscules = 'TY') or
           (nomEnMajuscules = 'VO') or
           (nomEnMajuscules = 'WU') or
           (nomEnMajuscules = 'XU') or
           (nomEnMajuscules = 'YE') or
           (nomEnMajuscules = 'YI') or
           (nomEnMajuscules = 'YO') or
           (nomEnMajuscules = 'YU');
       end;

end;





procedure MyFabriqueNomJoueurPourBaseWThorOfficielle(var nom : String255; var result : t_JoueurRecNouveauFormat);
var k : SInt64;
begin
  for k := 1 to TailleJoueurRecNouveauFormat do
    result[k] := 0;

  nom := StripDiacritics(nom);
  EnleveEspacesDeDroiteSurPlace(nom);
  EnleveEspacesDeGaucheSurPlace(nom);
  nom := LeftStr(nom,TailleJoueurRecNouveauFormat-1);
  EnleveEspacesDeDroiteSurPlace(nom);

  for k := 1 to LENGTH_OF_STRING(nom) do
    result[k] := ord(nom[k]);
end;


procedure MyFabriqueNomTournoiPourBaseWThorOfficielle(var nom : String255; var result : t_TournoiRecNouveauFormat);
var k : SInt64;
begin
  for k := 1 to TailleTournoiRecNouveauFormat do
    result[k] := 0;

  nom := StripDiacritics(nom);
  EnleveEspacesDeDroiteSurPlace(nom);
  EnleveEspacesDeGaucheSurPlace(nom);
  nom := LeftStr(nom,TailleTournoiRecNouveauFormat-1);
  EnleveEspacesDeDroiteSurPlace(nom);

  for k := 1 to LENGTH_OF_STRING(nom) do
    result[k] := ord(nom[k]);
end;


function JoueurRecNouveauFormatToString(whichPlayer : t_JoueurRecNouveauFormat) : String255;
var result : String255;
    k : SInt64;
begin
  result := '';
  for k := 1 to TailleJoueurRecNouveauFormat do
    if (whichPlayer[k] <> 0) then result := result + chr(whichPlayer[k]);
  JoueurRecNouveauFormatToString := result;
end;


function TournoiRecNouveauFormatToString(whichTourney : t_TournoiRecNouveauFormat) : String255;
var result : String255;
    k : SInt64;
begin
  result := '';
  for k := 1 to TailleTournoiRecNouveauFormat do
    if (whichTourney[k] <> 0) then result := result + chr(whichTourney[k]);
  TournoiRecNouveauFormatToString := result;
end;



function NomCourtDuTournoi(const nomOrigine : String255) : String255;
var longueur : SInt64;
    s : String255;
begin
  NomCourtDuTournoi := '';
  longueur := LENGTH_OF_STRING(nomOrigine);

  s := nomOrigine;


  s := ReplaceStringOnce(s, 'Divers avant et pendant' , 'Avant');
  s := ReplaceStringOnce(s, 'Aas Open and Othello Cup' , 'Aas');
  s := ReplaceStringOnce(s, 'Othello Cup' , '');


  s := ReplaceStringOnce(s, 'Torneo a' , '');
  s := ReplaceStringOnce(s, 'Torneo di' , '');
  s := ReplaceStringOnce(s, 'Torneo' , '');

  s := ReplaceStringOnce(s, 'Tournois de' , '');
  s := ReplaceStringOnce(s, 'Tournois d''' , '');
  s := ReplaceStringOnce(s, 'Tournois' , '');
  s := ReplaceStringOnce(s, 'Tournoi de' , '');
  s := ReplaceStringOnce(s, 'Tournoi d''' , '');
  s := ReplaceStringOnce(s, 'Tournoi' , '');

  s := ReplaceStringOnce(s, 'Opens de' , '');
  s := ReplaceStringOnce(s, 'Opens d''' , '');
  s := ReplaceStringOnce(s, 'Open de' , '');
  s := ReplaceStringOnce(s, 'Open d''' , '');
  s := ReplaceStringOnce(s, 'Opens' , '');
  s := ReplaceStringOnce(s, 'Open 1' , '');
  s := ReplaceStringOnce(s, 'Open 2' , '');
  s := ReplaceStringOnce(s, 'Open 3' , '');
  s := ReplaceStringOnce(s, 'Open 4' , '');
  s := ReplaceStringOnce(s, 'Open 5' , '');
  s := ReplaceStringOnce(s, 'Open 6' , '');
  s := ReplaceStringOnce(s, 'Open 7' , '');
  s := ReplaceStringOnce(s, 'Open 8' , '');
  s := ReplaceStringOnce(s, 'Open 9' , '');
  s := ReplaceStringOnce(s, 'Open' , '');

  s := ReplaceStringOnce(s, 'Sélections Champ. France' , 'Selections');
  s := ReplaceStringOnce(s, 'Sélection de' , '');
  s := ReplaceStringOnce(s, 'Sélection' , '');
  s := ReplaceStringOnce(s, 'Préqualif Villeneuve d''A' , 'Villeneuve d''Ascq');
  s := ReplaceStringOnce(s, 'Préqualif de' , '');
  s := ReplaceStringOnce(s, 'Préqualif' , '');


  s := ReplaceStringOnce(s, 'Championnat du Monde' , 'Mondial');
  s := ReplaceStringOnce(s, 'Championnat des' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnat de' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnat du' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnats du' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnats des' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnats de' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnat d''' , 'Ch. ');
  s := ReplaceStringOnce(s, 'Championnats d''' , 'Ch. ');
  s := ReplaceStringOnce(s, 'Champ.' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnat' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championnat' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championship' , 'Ch.');
  s := ReplaceStringOnce(s, 'Championships' , 'Ch.');


  s := ReplaceStringOnce(s, 'International de' , '');
  s := ReplaceStringOnce(s, 'International' , '');

  s := ReplaceStringOnce(s, 'EGP' , '');
  s := ReplaceStringOnce(s, 'GPE' , '');

  s := ReplaceStringOnce(s, 'Nationals' , 'Nat.');
  s := ReplaceStringOnce(s, 'National' , 'Nat.');


  s := ReplaceStringOnce(s, 'Grand Prix de' , 'G.P.');
  s := ReplaceStringOnce(s, 'Grand-Prix de' , 'G.P.');
  s := ReplaceStringOnce(s, 'Grand Prix d''' , 'G.P. ');
  s := ReplaceStringOnce(s, 'Grand-Prix d''' , 'G.P. ');
  s := ReplaceStringOnce(s, 'Grand Prix' , 'G.P.');
  s := ReplaceStringOnce(s, 'Grand-Prix' , 'G.P.');
  s := ReplaceStringOnce(s, 'Finale GP' , 'G.P.');
  s := ReplaceStringOnce(s, 'Stage de' , '');
  s := ReplaceStringOnce(s, 'Stage d''' , '');
  s := ReplaceStringOnce(s, 'Ladder' , '');
  s := ReplaceStringOnce(s, 'Christmas T.' , 'Noel');
  s := ReplaceStringOnce(s, 'Christmas T' , 'Noel');
  s := ReplaceStringOnce(s, 'Copenhagen Noel' , 'Copenhagen Noel');
  s := ReplaceStringOnce(s, 'Mind Sports Olympiad' , 'MSO');
  s := ReplaceStringOnce(s, 'Swedish League Online' , 'Swedish League');
  s := ReplaceStringOnce(s, 'Hommes-Machines de Paris' , 'Hommes-Machines');
  s := ReplaceStringOnce(s, 'Hommes-Machines' , 'Hommes-Mach.');
  s := ReplaceStringOnce(s, 'Seaside' , '');
  s := ReplaceStringOnce(s, 'British Regionals' , 'Brit. Regionals');


  s := ReplaceStringOnce(s, 'Russie 1' , 'Russie');
  s := ReplaceStringOnce(s, 'Russie 2' , 'Russie');
  s := ReplaceStringOnce(s, 'Russie 3and4' , 'Russie');
  s := ReplaceStringOnce(s, 'Russie 3' , 'Russie');
  s := ReplaceStringOnce(s, 'Russie 4' , 'Russie');

  s := ReplaceStringOnce(s, 'Grande-Bretagne' , 'G.B.');

  s := ReplaceStringOnce(s, 'Parties Internet (1-6)' , 'Internet');
  s := ReplaceStringOnce(s, 'Parties Internet (7-12)' , 'Internet');
  s := ReplaceStringOnce(s, 'Parties japonaises' , 'Japon');
  s := ReplaceStringOnce(s, 'Parties hollandaises' , 'Hollande');
  s := ReplaceStringOnce(s, 'Parties neerlandaises' , 'Pays-Bas');
  s := ReplaceStringOnce(s, 'Parties anglaises' , 'Angleterre');
  s := ReplaceStringOnce(s, 'Parties italiennes' , 'Italie');
  s := ReplaceStringOnce(s, 'Parties tcheques' , 'Tchéquie');
  {s := ReplaceStringOnce(s, 'Parties nordiques' , 'Scandinavie');}
  s := ReplaceStringOnce(s, 'Parties suedoises' , 'Suede');
  s := ReplaceStringOnce(s, 'Parties nordiques' , 'Nordiques');
  s := ReplaceStringOnce(s, 'Parties sur minitel' , 'Minitel');
  s := ReplaceStringOnce(s, 'Parties argentines' , 'Argentine');
  s := ReplaceStringOnce(s, 'Parties belges' , 'Belgique');
  s := ReplaceStringOnce(s, 'Parties du' , '');
  s := ReplaceStringOnce(s, 'Parties de' , '');
  s := ReplaceStringOnce(s, 'Parties' , '');

  s := ReplaceStringOnce(s, 'Match' , '');
  s := ReplaceStringOnce(s, '(prg)' , '');
  s := ReplaceStringOnce(s, '(France)' , '');
  s := ReplaceStringOnce(s, 'Diverses parties' , 'Diverses');
  s := ReplaceStringOnce(s, 'Othello' , '');
  s := ReplaceStringOnce(s, 'Cup' , '');
  s := ReplaceStringOnce(s, 'Blitz d''' , '');
  s := ReplaceStringOnce(s, 'Blitz' , '');
  {s := ReplaceStringOnce(s, 'Villeneuve d''A' , 'Villeneuve d''Ascq');}

  s := ReplaceStringOnce(s, 'Mariage de Brian Rose' , 'Mariage');
  s := ReplaceStringOnce(s, 'Thématique semi-rapide' , 'Semi-rapide');
  s := ReplaceStringOnce(s, 'Murakami-Logistello' , 'Match');
  s := ReplaceStringOnce(s, 'Ch. France Junior' , 'Ch. Juniors');
  s := ReplaceStringOnce(s, 'Ch. Tchèque' , 'Ch. Tchéquie');
  s := ReplaceStringOnce(s, 'Kansai Senshuken' , 'Kansai');

  s := ReplaceStringOnce(s, 'Campionati Italiani' , 'Ch. Italie');
  s := ReplaceStringOnce(s, 'Deutsche Meisterschaft' , 'Ch. Allemagne');
  s := ReplaceStringOnce(s, 'Ellinika Protathlimata' , 'Ch. Grèce');


  s := ReplaceStringOnce(s, '  ' , ' ');
  s := ReplaceStringOnce(s, '  ' , ' ');
  s := ReplaceStringOnce(s, '  ' , ' ');

  EnleveEspacesDeGaucheSurPlace(s);
  EnleveEspacesDeDroiteSurPlace(s);

  s[1] := UpperCase(s[1]);

  NomCourtDuTournoi := s;

  {WritelnDansRapport(s);}
end;




function TrouveNumeroDuJoueur(const nomJoueur : String255; var numeroJoueur, confiance : SInt64; genreRecherche : SInt64) : boolean;
var i,positionMetaphone,positionDuNom : SInt64;
    metaphoneCherche : String255;
    nomChercheEnMajuscules : String255;
    nomBaseEnMajuscules : String255;
    nomJoueurSansUTF8 : String255;
    nomBase : String255;
    indexMax, len : SInt64;
    qualiteSolutionCourante,nouvelleQualite : SInt64;
    debug, trouve : boolean;
label sortie;
begin

  numeroJoueur := -1;
  confiance := 0;
  trouve := false;



  qualiteSolutionCourante := 0;

  nomJoueurSansUTF8 := UTF8ToAscii(nomJoueur);

  len := LENGTH_OF_STRING(nomJoueurSansUTF8);

  if (len > LongueurPlusLongNomDeJoueurDansBase) then
    begin
      TrouveNumeroDuJoueur := false;
      exit;
    end;

  // metaphone (si le drapeau gUsingMetaphone est vrai) du nom du joueur cherche
  if CassioIsUsingMetaphone
    then metaphoneCherche := FabriqueNomEnMajusculesSansEspaceAvecMetaphone(nomJoueurSansUTF8)
    else metaphoneCherche := 'blahbldsosdhfdgfsgrgfsghfd3535635678639267';

  // nom en majuscule du joueur cherche
  nomChercheEnMajuscules := FabriqueNomEnMajusculesSansEspaceSansMetaphone(nomJoueurSansUTF8);


  { WritelnDansRapport('nomJoueurSansUTF8 = ' + nomJoueurSansUTF8);
  WritelnDansRapport('nomChercheEnMajuscules = ' + nomChercheEnMajuscules); }


  //debug := (nomChercheEnMajuscules = 'NICOLETSTEPHANE');
  debug := false;


  if (genreRecherche = kChercherSeulementDansBaseOfficielle) and
     (NombreJoueursDansBaseOfficielle > 0)
     then indexMax := NombreJoueursDansBaseOfficielle
     else indexMax := JoueursNouveauFormat.nbJoueursNouveauFormat;

  for i := 0 to indexMax do
    begin

      // position du metaphone du joueur par rapport au metaphone de la base ?
      positionMetaphone := FindStringDansMetaphoneSansEspaceDeCeJoueur(metaphoneCherche, i);

      // position du nom du joueur dans le nom de la base ?
      positionDuNom := FindStringDansNomEnMajusculesSansEspaceDeCeJoueur(nomChercheEnMajuscules, i);


      if (positionMetaphone > 0) or (positionDuNom > 0) then
	      begin
	
	        trouve := true;
	
	        nomBaseEnMajuscules := GetNomJoueurEnMajusculesSansEspace(i);
	

	        // on a trouve le metaphone du joueur :
	        // bonus d'autant plus grand qu'il est au début du mot
	        nouvelleQualite := Max(1, 30 - 2*positionMetaphone);

          (*
	        if debug then
	          begin
	            WritelnDansRapport('metaphoneCherche = '+metaphoneCherche);
	            WritelnDansRapport('metaphone de "Juhem Philippe" = '+FabriqueNomEnMajusculesSansEspaceAvecMetaphone('Juhem Philippe'));
	            WritelnDansRapport('nomChercheEnMajuscules = '+nomChercheEnMajuscules);
	            WritelnDansRapport('metaphoneBase = '+GetNomJoueurEnMetaphoneSansEspace(i););
	            WritelnDansRapport('nomBaseEnMajuscules = '+nomBaseEnMajuscules);
	            WritelnDansRapport('')
	          end;
	        *)

	        if (positionDuNom > 0)
	          then
  	          begin

  	            // on a trouve le nom du joueur dans le nom de la base :
  	            // bonus d'autant plus grand qu'il est au début du nom de la base
  	            nouvelleQualite := Max(31, 60 - positionDuNom);

  	            if (positionDuNom = 1) then
                  begin
                    nouvelleQualite := 90;  // excellent si le nom du joueur est un prefixe du nom de la base

                    nomBase := GetNomJoueur(i);

                    (*
                    if debug then
                      begin
                        WritelnDansRapport('metaphoneCherche = '+metaphoneCherche);
    	                  WritelnDansRapport('nomChercheEnMajuscules = '+nomChercheEnMajuscules);
    	                  WritelnDansRapport('metaphoneBase = '+GetNomJoueurEnMetaphoneSansEspace(i););
    	                  WritelnDansRapport('nomBase = '+nomBase);
    	                  WritelnDansRapport('nomBaseEnMajuscules = '+nomBaseEnMajuscules);
    	                  WritelnDansRapport('');
    	                end;
    	              *)

                    if (LENGTH_OF_STRING(nomChercheEnMajuscules) = LENGTH_OF_STRING(nomBaseEnMajuscules)) or
                       (nomBase[len + 1] = ' ') then
                      nouvelleQualite := 100;  // parfait si le nom du joueur est exactement le nom de la base
                  end;

  	          end
	          else
	            // departage par le nombre de caracteres en commun
	            nouvelleQualite := nouvelleQualite - PseudoHammingDistance(nomChercheEnMajuscules,nomBaseEnMajuscules);


	        if (nouvelleQualite > qualiteSolutionCourante) then
            begin
              qualiteSolutionCourante := nouvelleQualite;
              numeroJoueur := i;
            end;

	        if (qualiteSolutionCourante >= 100) then goto sortie;

	      end;
    end;

  sortie :

  TrouveNumeroDuJoueur := trouve;
  confiance := qualiteSolutionCourante;

  if debug then
    begin
      WritelnDansRapport('--------------');
      WritelnDansRapport('résultats de TrouveNumeroDuJoueur pour nomJoueur = '+nomJoueur);
      WritelnNumDansRapport('numeroJoueur = ', numeroJoueur);
      WritelnNumDansRapport('confiance = ', confiance);
      WritelnStringAndBoolDansRapport('trouve = ',trouve);
      WritelnDansRapport('--------------');
    end;


end;


function TrouveNumeroDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
var formeAlternative : String255;
    nomJoueurEnMajuscules : String255;
    position : SInt64;
    trouve : boolean;

     procedure TesterFormeAlternative(const pattern, remplacement : String255);
     var newNumero,newConfiance : SInt64;
         patMajuscules, rempMajuscules : String255;
     begin
       if not(trouve and (confiance >= 100)) then
         begin
           patMajuscules := FabriqueNomEnMajusculesAvecEspaces(pattern);
           if (Pos(patMajuscules, nomJoueurEnMajuscules) > 0) then
             begin
               rempMajuscules := FabriqueNomEnMajusculesAvecEspaces(remplacement);
               formeAlternative := ReplaceStringOnce(nomJoueurEnMajuscules, patMajuscules,rempMajuscules);
               formeAlternative := LeftStr(formeAlternative,LongueurPlusLongNomDeJoueurDansBase);
               if TrouveNumeroDuJoueur(formeAlternative,newNumero,newConfiance,kChercherSeulementDansBaseOfficielle) and
                 (newConfiance > confiance) then
                 begin
                   trouve := true;
                   confiance := newConfiance;
                   numeroJoueur := newNumero;
                 end;
             end;
         end;
     end;


begin { TrouveNumeroDeCeNomDeJoueurDansLaBaseThor }

  nomJoueurEnMajuscules := FabriqueNomEnMajusculesAvecEspaces(UTF8ToAscii(nomJoueur));

  trouve := TrouveNumeroDuJoueur(nomJoueurEnMajuscules,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle);

  if not(trouve and (confiance >= 100)) and TrouveATRDansChaine(gImportDesNoms.formesPossiblesDesVanDen, nomJoueurEnMajuscules, position)
    then
      begin
        TesterFormeAlternative('van den ','v/d ');
        TesterFormeAlternative('van de ','v/d ');
        TesterFormeAlternative('van der ','v/d ');
        TesterFormeAlternative('von de ','v/d ');
        TesterFormeAlternative('von der ','v/d ');
        TesterFormeAlternative('von der ','van der ');
        TesterFormeAlternative('von de ','van de ');
        TesterFormeAlternative('vd ','v/d ');
        TesterFormeAlternative('vd ','van den ');
        TesterFormeAlternative('vd ','van de ');
        TesterFormeAlternative('vd ','von de ');
        TesterFormeAlternative('vd ','von der ');
        TesterFormeAlternative('v. d. ','v/d ');
        TesterFormeAlternative('v d ','v/d ');
        TesterFormeAlternative('v d ','van den ');
        TesterFormeAlternative('v d ','van der ');
        TesterFormeAlternative('v d ','van de ');
        TesterFormeAlternative('v d ','von de ');
        TesterFormeAlternative('v d ','von der ');
        TesterFormeAlternative('v/d ','van den ');
        TesterFormeAlternative('v/d ','van der ');
        TesterFormeAlternative('v/d ','von de ');
        TesterFormeAlternative('v/d ','von der ');
        TesterFormeAlternative('v/d ','van de ');
        TesterFormeAlternative('v/d ','vd ');
      end;

  TrouveNumeroDeCeNomDeJoueurDansLaBaseThor := trouve;
end;


{ Cette routine est un peu lente :-(  }
function TrouvePrefixeDansLaBaseWthor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64; genreRecherche : SInt64) : boolean;
const kParfaite    = 3;
      kMoyenne     = 2;
      kMauvaise    = 1;
      kInexistante = 0;
var i,positionSousChaine : SInt64;
    nomChercheEnMajuscules : String255;
    nomBaseEnMajuscules : String255;
    indexMax : SInt64;
    qualiteSolution,nouvelleQualite : SInt64;
    tempoMetaphone : boolean;
label sortie;
begin

  numeroJoueur := -1;
  TrouvePrefixeDansLaBaseWthor := false;
  qualiteSolution := kInexistante;
  confiance := 0;


  // désactivons temporairement Metaphone
  tempoMetaphone := CassioIsUsingMetaphone;
  SetCassioIsUsingMetaphone(false);



  nomChercheEnMajuscules := FabriqueNomEnMajusculesSansEspaceSansMetaphone(UTF8ToAscii(nomJoueur));

  if (genreRecherche = kChercherSeulementDansBaseOfficielle) and
     (NombreJoueursDansBaseOfficielle > 0)
     then indexMax := NombreJoueursDansBaseOfficielle
     else indexMax := JoueursNouveauFormat.nbJoueursNouveauFormat;

  for i := 0 to indexMax do
    begin
      nomBaseEnMajuscules := GetNomJoueurEnMajusculesSansEspace(i);

      {WritelnDansRapport( nomBaseEnMajuscules + ' ' + nomChercheEnMajuscules);}

      if (nomBaseEnMajuscules[LENGTH_OF_STRING(nomBaseEnMajuscules)] = '.') or
         (nomBaseEnMajuscules[LENGTH_OF_STRING(nomBaseEnMajuscules)] = ' ')
         then nomBaseEnMajuscules := TPCopy(nomBaseEnMajuscules, 1, LENGTH_OF_STRING(nomBaseEnMajuscules) - 1);


      positionSousChaine := Pos(nomBaseEnMajuscules,nomChercheEnMajuscules);

      if (positionSousChaine > 0) then
	      begin

          if (positionSousChaine = 1)
            then
              begin

                confiance := 100;

                nouvelleQualite := kMauvaise;

                (*
                WritelnDansRapport('');
                WritelnDansRapport('nomChercheEnMajuscules = '+nomChercheEnMajuscules);
                WritelnDansRapport('nomBaseEnMajuscules = '+nomBaseEnMajuscules);
                *)

                if (Pos(nomBaseEnMajuscules,nomChercheEnMajuscules) = 1)
                    then nouvelleQualite := kParfaite
                    else nouvelleQualite := kMoyenne;

                if (nouvelleQualite > qualiteSolution) then
                  begin
                    qualiteSolution := nouvelleQualite;
                    numeroJoueur := i;
                  end;
              end
            else
	            if (numeroJoueur = -1) then
	              begin
	                numeroJoueur := i;
	                confiance := Min(2, LENGTH_OF_STRING(nomBaseEnMajuscules));
	              end;

	        TrouvePrefixeDansLaBaseWthor := true;

	        if (qualiteSolution = kParfaite) then goto sortie;

	      end;
    end;

sortie :

  // on remet Metaphone
  SetCassioIsUsingMetaphone(tempoMetaphone);
end;




function TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
var formeAlternative : String255;
    nomJoueurEnMajuscules : String255;
    trouve : boolean;
    position : SInt64;

     procedure TesterFormeAlternative(const pattern, remplacement : String255);
     var newNumero,newConfiance : SInt64;
         patMajuscules, rempMajuscules : String255;
     begin
       if not(trouve and (confiance >= 100)) then
         begin
           patMajuscules := FabriqueNomEnMajusculesAvecEspaces(pattern);
           if (Pos(patMajuscules, nomJoueurEnMajuscules) > 0) then
             begin
               rempMajuscules := FabriqueNomEnMajusculesAvecEspaces(remplacement);
               formeAlternative := ReplaceStringOnce(nomJoueurEnMajuscules, patMajuscules,rempMajuscules);
               formeAlternative := LeftStr(formeAlternative,LongueurPlusLongNomDeJoueurDansBase);
               if TrouvePrefixeDansLaBaseWthor(formeAlternative,newNumero,newConfiance,kChercherSeulementDansBaseOfficielle) and
                 (newConfiance > confiance) then
                 begin
                   trouve := true;
                   confiance := newConfiance;
                   numeroJoueur := newNumero;
                 end;
             end;
         end;
     end;

begin { TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor }

  nomJoueurEnMajuscules := FabriqueNomEnMajusculesAvecEspaces(UTF8ToAscii(nomJoueur));

  trouve := TrouvePrefixeDansLaBaseWthor(nomJoueurEnMajuscules,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle);

  if not(trouve and (confiance >= 100)) and TrouveATRDansChaine(gImportDesNoms.formesPossiblesDesVanDen, nomJoueurEnMajuscules, position)
    then
      begin
        TesterFormeAlternative('van den ','v/d ');
        TesterFormeAlternative('van de ','v/d ');
        TesterFormeAlternative('van der ','v/d ');
        TesterFormeAlternative('von de ','v/d ');
        TesterFormeAlternative('von der ','v/d ');
        TesterFormeAlternative('von der ','van der ');
        TesterFormeAlternative('von de ','van de ');
        TesterFormeAlternative('vd ','v/d ');
        TesterFormeAlternative('vd ','van den ');
        TesterFormeAlternative('vd ','van de ');
        TesterFormeAlternative('vd ','von de ');
        TesterFormeAlternative('vd ','von der ');
        TesterFormeAlternative('v. d. ','v/d ');
        TesterFormeAlternative('v d ','v/d ');
        TesterFormeAlternative('v d ','van den ');
        TesterFormeAlternative('v d ','van der ');
        TesterFormeAlternative('v d ','van de ');
        TesterFormeAlternative('v d ','von de ');
        TesterFormeAlternative('v d ','von der ');
        TesterFormeAlternative('v/d ','van den ');
        TesterFormeAlternative('v/d ','van der ');
        TesterFormeAlternative('v/d ','von de ');
        TesterFormeAlternative('v/d ','von der ');
        TesterFormeAlternative('v/d ','van de ');
        TesterFormeAlternative('v/d ','vd ');
      end;

  TrouvePrefixeDeCeNomDeJoueurDansLaBaseThor := trouve;
end;


function TrouveSousChaineDansLaBaseWthor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64; genreRecherche : SInt64) : boolean;
const kParfaite    = 3;
      kMoyenne     = 2;
      kMauvaise    = 1;
      kInexistante = 0;
var i, len, positionSousChaine : SInt64;
    nbJoueursCompatibles : SInt64;
    nomChercheEnMajuscules : String255;
    nomChercheEnMajusculesArrivee : String255;
    nomBaseEnMajuscules : String255;
    indexMax : SInt64;
    qualiteSolution,nouvelleQualite : SInt64;
label sortie;
begin

  numeroJoueur := -1;
  TrouveSousChaineDansLaBaseWthor := false;
  qualiteSolution := kInexistante;
  confiance := 0;


  nomChercheEnMajusculesArrivee := FabriqueNomEnMajusculesSansEspaceSansMetaphone(UTF8ToAscii(nomJoueur));

  if (genreRecherche = kChercherSeulementDansBaseOfficielle) and
     (NombreJoueursDansBaseOfficielle > 0)
     then indexMax := NombreJoueursDansBaseOfficielle
     else indexMax := JoueursNouveauFormat.nbJoueursNouveauFormat;



  for len := Max(6, LENGTH_OF_STRING(nomChercheEnMajusculesArrivee) - 12) to
             Min(LongueurPlusLongNomDeJoueurDansBase, LENGTH_OF_STRING(nomChercheEnMajusculesArrivee) - 1) do
    begin

      nomChercheEnMajuscules := LeftStr(nomChercheEnMajusculesArrivee, len);

      // WritelnDansRapport('Il reste : ' + nomChercheEnMajuscules);

      nbJoueursCompatibles := 0;

      for i := 0 to indexMax do
        if (nbJoueursCompatibles <= 1) then
          begin
            nomBaseEnMajuscules := GetNomJoueurEnMajusculesSansEspace(i);

            {WritelnDansRapport( nomBaseEnMajuscules + ' ' + nomChercheEnMajuscules);}

            if (nomBaseEnMajuscules[LENGTH_OF_STRING(nomBaseEnMajuscules)] = '.') or
               (nomBaseEnMajuscules[LENGTH_OF_STRING(nomBaseEnMajuscules)] = ' ')
               then nomBaseEnMajuscules := TPCopy(nomBaseEnMajuscules, 1, LENGTH_OF_STRING(nomBaseEnMajuscules) - 1);


            positionSousChaine := Pos(nomChercheEnMajuscules, nomBaseEnMajuscules);

            if (positionSousChaine > 0) then
      	      begin

      	        inc(nbJoueursCompatibles);

                if (positionSousChaine = 1)
                  then
                    begin

                      confiance := 100;

                      nouvelleQualite := kMauvaise;

                      {WritelnDansRapport('');
                      WritelnDansRapport('nomChercheEnMajuscules = '+nomChercheEnMajuscules);
                      WritelnDansRapport('nomCourantEnMajuscules = '+nomCourantEnMajuscules);}

                      if (Pos(nomBaseEnMajuscules,nomChercheEnMajuscules) = 1)
                          then nouvelleQualite := kParfaite
                          else nouvelleQualite := kMoyenne;

                      if (nouvelleQualite > qualiteSolution) then
                        begin
                          qualiteSolution := nouvelleQualite;
                          numeroJoueur := i;
                        end;
                    end
                  else
      	            begin
      	              if (numeroJoueur = -1) then
      	                begin
      	                  numeroJoueur := i;
      	                  confiance := Min(2, LENGTH_OF_STRING(nomChercheEnMajuscules));
      	                end;
      	            end;

      	      end;
          end;

      if (nbJoueursCompatibles <= 0) then
        begin
          TrouveSousChaineDansLaBaseWthor := false;
          goto sortie;
        end;

      if (nbJoueursCompatibles = 1) then
        begin
          TrouveSousChaineDansLaBaseWthor := true;
          goto sortie;
        end;

    end;

sortie :

end;



function TrouveSousChaineDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
var formeAlternative : String255;
    nomJoueurEnMajuscules : String255;
    trouve : boolean;
    position : SInt64;

     procedure TesterFormeAlternative(const pattern, remplacement : String255);
     var newNumero,newConfiance : SInt64;
         patMajuscules, rempMajuscules : String255;
     begin
       if not(trouve and (confiance >= 100)) then
         begin
           patMajuscules := FabriqueNomEnMajusculesAvecEspaces(pattern);
           if (Pos(patMajuscules, nomJoueurEnMajuscules) > 0) then
             begin
               rempMajuscules := FabriqueNomEnMajusculesAvecEspaces(remplacement);
               formeAlternative := ReplaceStringOnce(nomJoueurEnMajuscules, patMajuscules,rempMajuscules);
               formeAlternative := LeftStr(formeAlternative,LongueurPlusLongNomDeJoueurDansBase);
               if TrouveSousChaineDansLaBaseWthor(formeAlternative,newNumero,newConfiance,kChercherSeulementDansBaseOfficielle) and
                 (newConfiance > confiance) then
                 begin
                   trouve := true;
                   confiance := newConfiance;
                   numeroJoueur := newNumero;
                 end;
             end;
         end;
     end;

begin { TrouveSousChaineDeCeNomDeJoueurDansLaBaseThor }

  nomJoueurEnMajuscules := FabriqueNomEnMajusculesAvecEspaces(UTF8ToAscii(nomJoueur));

  trouve := TrouveSousChaineDansLaBaseWthor(nomJoueurEnMajuscules,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle);

  if not(trouve and (confiance >= 100)) and TrouveATRDansChaine(gImportDesNoms.formesPossiblesDesVanDen, nomJoueurEnMajuscules, position)
    then
      begin
        TesterFormeAlternative('van den ','v/d ');
        TesterFormeAlternative('van de ','v/d ');
        TesterFormeAlternative('van der ','v/d ');
        TesterFormeAlternative('von de ','v/d ');
        TesterFormeAlternative('von der ','v/d ');
        TesterFormeAlternative('von der ','van der ');
        TesterFormeAlternative('von de ','van de ');
        TesterFormeAlternative('vd ','v/d ');
        TesterFormeAlternative('vd ','van den ');
        TesterFormeAlternative('vd ','van de ');
        TesterFormeAlternative('vd ','von de ');
        TesterFormeAlternative('vd ','von der ');
        TesterFormeAlternative('v. d. ','v/d ');
        TesterFormeAlternative('v d ','v/d ');
        TesterFormeAlternative('v d ','van den ');
        TesterFormeAlternative('v d ','van der ');
        TesterFormeAlternative('v d ','van de ');
        TesterFormeAlternative('v d ','von de ');
        TesterFormeAlternative('v d ','von der ');
        TesterFormeAlternative('v/d ','van den ');
        TesterFormeAlternative('v/d ','van der ');
        TesterFormeAlternative('v/d ','von de ');
        TesterFormeAlternative('v/d ','von der ');
        TesterFormeAlternative('v/d ','van de ');
        TesterFormeAlternative('v/d ','vd ');
      end;

  TrouveSousChaineDeCeNomDeJoueurDansLaBaseThor := trouve;
end;


function TrouveLexemesDansLaBaseWthor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64; genreRecherche : SInt64) : boolean;
var i,j,k : SInt64;
    metaphoneChercheAvecEspaces : String255;
    nomChercheEnMajusculesAvecEspaces : String255;
    nomJoueurSansUTF8 : String255;
    nomBase : String255;
    nomBaseEnMajusculesAvecEspaces : String255;
    indexMax: SInt64;
    qualiteSolutionCourante,nouvelleQualite : SInt64;
    debug, trouve : boolean;
    nbLexemesCherches, nbLexemesBase : SInt64;
    nbLexemesCherchesAux, nbLexemesBaseAux : SInt64;
    lexemesCherches : array[0..200] of SInt64;
    lexemesBase : array[0..200] of SInt64;
    lexemesCherchesAux : array[0..200] of SInt64;

label sortie;
begin

  numeroJoueur := -1;
  confiance := 0;
  trouve := false;

  qualiteSolutionCourante := 0;

  nomJoueurSansUTF8 := UTF8ToAscii(nomJoueur);

  // nom en majuscules du joueur cherche
  nomChercheEnMajusculesAvecEspaces := FabriqueNomEnMajusculesAvecEspaces(nomJoueurSansUTF8);

  // metaphone avec espaces (si le drapeau gUsingMetaphone est vrai) du nom du joueur cherche
  if CassioIsUsingMetaphone
    then metaphoneChercheAvecEspaces := FabriqueMetaphoneDesLexemes(nomChercheEnMajusculesAvecEspaces)
    else metaphoneChercheAvecEspaces := 'blahfdsdfjshhjfsdjfgdkfsghfd3535635678639267';

  if CassioIsUsingMetaphone
    then nbLexemesCherches := HashLexemes( metaphoneChercheAvecEspaces ,       @lexemesCherches)
    else nbLexemesCherches := HashLexemes( nomChercheEnMajusculesAvecEspaces , @lexemesCherches);


  // WriteDansRapport('nomChercheEnMajusculesAvecEspaces = ' + nomChercheEnMajusculesAvecEspaces);
  // WritelnDansRapport('       =>    metaphoneChercheAvecEspaces = ' + metaphoneChercheAvecEspaces);


  //debug := (nomChercheEnMajusculesAvecEspaces = 'WU KATIE');
  debug := false;


  if (genreRecherche = kChercherSeulementDansBaseOfficielle) and
     (NombreJoueursDansBaseOfficielle > 0)
     then indexMax := NombreJoueursDansBaseOfficielle
     else indexMax := JoueursNouveauFormat.nbJoueursNouveauFormat;


  for i := 1 to indexMax do
    begin

      nbLexemesBase := GetHashLexemesDeCeJoueur(i, @lexemesBase);

      // copier les nombres de lexemes
      nbLexemesCherchesAux := nbLexemesCherches;
      nbLexemesBaseAux     := nbLexemesBase;

      // copier les hash des lexemes cherches
      for k := 0 to nbLexemesCherchesAux + 5 do
        lexemesCherchesAux[k] := lexemesCherches[k];

      // chercher les lexemes identiques ?
      for j := 1 to nbLexemesBase do
        for k := 1 to nbLexemesCherches do
          if (lexemesBase[j] = lexemesCherchesAux[k]) then
            begin
              dec(nbLexemesBaseAux);
              dec(nbLexemesCherchesAux);
              lexemesBase[j]        := 0;
              lexemesCherchesAux[k] := -1;
            end;

      if (nbLexemesBaseAux <= 0) or (nbLexemesCherchesAux <= 0) then
        begin

          trouve := true;

          nomBase := GetNomJoueur(i);
          nomBaseEnMajusculesAvecEspaces := FabriqueNomEnMajusculesAvecEspaces(nomBase);

          nouvelleQualite := 85 - PseudoHammingDistance(nomChercheEnMajusculesAvecEspaces, nomBaseEnMajusculesAvecEspaces);

          if (nouvelleQualite > qualiteSolutionCourante) then
            begin
              qualiteSolutionCourante := nouvelleQualite;
              numeroJoueur := i;
            end;

        end;

    end;

  sortie :

  TrouveLexemesDansLaBaseWthor := trouve;
  confiance := qualiteSolutionCourante;

  if debug then
    begin
      WritelnDansRapport('--------------');
      WritelnDansRapport('résultats de TrouveLexemesDansLaBaseWthor pour nomJoueur = '+nomJoueur);
      WritelnNumDansRapport('numeroJoueur = ', numeroJoueur);
      WritelnNumDansRapport('confiance = ', confiance);
      WritelnStringAndBoolDansRapport('trouve = ',trouve);
      WritelnDansRapport('--------------');
    end;


end;





function TrouveLexemesDeCeNomDeJoueurDansLaBaseThor(const nomJoueur : String255; var numeroJoueur, confiance : SInt64) : boolean;
var formeAlternative : String255;
    nomJoueurEnMajuscules : String255;
    trouve : boolean;
    position : SInt64;

     procedure TesterFormeAlternative(const pattern, remplacement : String255);
     var newNumero,newConfiance : SInt64;
         patMajuscules, rempMajuscules : String255;
     begin
       if not(trouve and (confiance >= 100)) then
         begin
           patMajuscules := FabriqueNomEnMajusculesAvecEspaces(pattern);
           if (Pos(patMajuscules, nomJoueurEnMajuscules) > 0) then
             begin
               rempMajuscules := FabriqueNomEnMajusculesAvecEspaces(remplacement);
               formeAlternative := ReplaceStringOnce(nomJoueurEnMajuscules, patMajuscules,rempMajuscules);
               if TrouveLexemesDansLaBaseWthor(formeAlternative,newNumero,newConfiance,kChercherSeulementDansBaseOfficielle) and
                 (newConfiance > confiance) then
                 begin
                   trouve := true;
                   confiance := newConfiance;
                   numeroJoueur := newNumero;
                 end;
             end;
         end;
     end;

begin { TrouveLexemesDeCeNomDeJoueurDansLaBaseThor }

  // c'est la fonction la plus lente du lot, alors il faut
  // essayer d'optimiser son utilisation...
  if (Pos(' ',nomJoueur) <= 0) then
    begin
      numeroJoueur := kNroJoueurInconnu;
      confiance := 0;
      TrouveLexemesDeCeNomDeJoueurDansLaBaseThor := false;
      exit;
    end;

  nomJoueurEnMajuscules := FabriqueNomEnMajusculesAvecEspaces(UTF8ToAscii(nomJoueur));

  trouve := TrouveLexemesDansLaBaseWthor(nomJoueurEnMajuscules,numeroJoueur,confiance,kChercherSeulementDansBaseOfficielle);

  if not(trouve and (confiance >= 100)) and TrouveATRDansChaine(gImportDesNoms.formesPossiblesDesVanDen, nomJoueurEnMajuscules, position)
    then
      begin
        TesterFormeAlternative('van den ','v/d ');
        TesterFormeAlternative('van de ','v/d ');
        TesterFormeAlternative('van der ','v/d ');
        TesterFormeAlternative('von de ','v/d ');
        TesterFormeAlternative('von der ','v/d ');
        TesterFormeAlternative('von der ','van der ');
        TesterFormeAlternative('von de ','van de ');
        TesterFormeAlternative('vd ','v/d ');
        TesterFormeAlternative('vd ','van den ');
        TesterFormeAlternative('vd ','van de ');
        TesterFormeAlternative('vd ','von de ');
        TesterFormeAlternative('vd ','von der ');
        TesterFormeAlternative('v. d. ','v/d ');
        TesterFormeAlternative('v d ','v/d ');
        TesterFormeAlternative('v d ','van den ');
        TesterFormeAlternative('v d ','van der ');
        TesterFormeAlternative('v d ','van de ');
        TesterFormeAlternative('v d ','von de ');
        TesterFormeAlternative('v d ','von der ');
        TesterFormeAlternative('v/d ','van den ');
        TesterFormeAlternative('v/d ','van der ');
        TesterFormeAlternative('v/d ','von de ');
        TesterFormeAlternative('v/d ','von der ');
        TesterFormeAlternative('v/d ','van de ');
        TesterFormeAlternative('v/d ','vd ');
      end;

  TrouveLexemesDeCeNomDeJoueurDansLaBaseThor := trouve;
end;





function TrouveNumeroDuTournoi(const nomTournoi : String255; var numeroTournoi : SInt64; fromIndex : SInt64) : boolean;
var i,positionSousChaine : SInt64;
    nomCherche,nomCourant : String255;
begin
  numeroTournoi := -1;
  TrouveNumeroDuTournoi := false;

  nomCherche := UTF8ToAscii(nomTournoi);
  nomCherche := UpperCase(nomCherche,false);

  for i := fromIndex to TournoisNouveauFormat.nbTournoisNouveauFormat do
    begin
      nomCourant := GetNomTournoi(i);
      nomCourant := UpperCase(nomCourant,false);

      positionSousChaine := Pos(nomCherche,nomCourant);
      if (positionSousChaine > 0) then
	      begin
	        if (positionSousChaine = 1) or (numeroTournoi = -1)
	          then numeroTournoi := i;
	        TrouveNumeroDuTournoi := true;
	        if (positionSousChaine = 1) then exit;
	      end;
    end;
end;



function CassioIsUsingMetaphone : boolean;
begin
  CassioIsUsingMetaphone := gUsingMetaphone;
end;


procedure SetCassioIsUsingMetaphone(flag : boolean);
begin
  gUsingMetaphone := flag;
end;


function FabriqueNomEnMajusculesSansEspaceSansMetaphone(s : String255) : String255;
var result : String255;
    k : SInt64;
    c : char;
begin

  s := UpperCase(s,false);
  result := '';
  for k := 1 to LENGTH_OF_STRING(s) do
    begin
      c := s[k];
      if (c <> ' ') and (c <> '-') and (c <> '–') and (c <> '_') and (c <> ' ') and (c <> '.') and (c <> '(') and (c <> ')') and (c <> ',') then
        result := result + c;
    end;

  FabriqueNomEnMajusculesSansEspaceSansMetaphone := result;
end;

function FabriqueNomEnMajusculesAvecEspaces(const s : String255) : String255;
var result : String255;
    k : SInt64;
    c : char;
begin

  result := UpperCase(s,false);

  for k := 1 to LENGTH_OF_STRING(s) do
    begin
      c := result[k];
      if ((c = ' ') or (c = '-') or (c = '–') or (c = '_') or (c = ' ') or (c = '.') or (c = '(') or (c = ')') or (c = ',') or (c = '/'))
        then result[k] := ' ';
    end;

  FabriqueNomEnMajusculesAvecEspaces := result;
end;


function FabriqueNomEnMajusculesSansEspaceAvecMetaphone(s : String255) : String255;
var primary, secondary : String255;
begin
  s := FabriqueNomEnMajusculesSansEspaceSansMetaphone(s);
  MakeDoubleMetaphone(s, primary, secondary);
  FabriqueNomEnMajusculesSansEspaceAvecMetaphone := secondary;
end;


function FabriqueNomEnMajusculesSansEspaceDunNomWThor(nom : String255) : String255;
begin
  if gUsingMetaphone and (nom <> '???') and (nom <> '')
    then FabriqueNomEnMajusculesSansEspaceDunNomWThor := FabriqueNomEnMajusculesSansEspaceAvecMetaphone(nom)
    else FabriqueNomEnMajusculesSansEspaceDunNomWThor := FabriqueNomEnMajusculesSansEspaceSansMetaphone(nom);
end;




procedure RegenererLesNomsMetaphoneDeLaBase;
var k : SInt64;
    nom : String255;
begin

  WritelnStringAndBoolDansRapport('reconnaissance des noms par Metaphone = ',gUsingMetaphone);

  with JoueursNouveauFormat do
    if (nbJoueursNouveauFormat > 0) and
       (listeJoueurs <> NIL) then
       begin

         for k := 0 to nbJoueursNouveauFormat-1 do
           begin
             nom := GetNomJoueur(k);
             SetNomJoueur(k,nom);

             if (k <= 10) or ((k >= 1000) and (k < 1010)) then
               if CassioIsUsingMetaphone
                 then WritelnDansRapport(GetNomJoueurEnMetaphoneAvecEspaces(k))
                 else WritelnDansRapport(GetNomJoueurEnMajusculesSansEspace(k));

           end;
       end;

  with gImportDesNoms do
    begin
      DisposeStringSet(pseudosInconnus);
      DisposeStringSet(pseudosNomsDejaVus);
      DisposeStringSet(pseudosTournoisDejaVus);
      DisposeStringSet(pseudosAyantUnNomReel);
      DisposeStringSet(pseudosSansNomReel);
      DisposeStringSet(nomsReelsARajouterDansBase);

      pseudosInconnus            := MakeEmptyStringSet;
      pseudosNomsDejaVus         := MakeEmptyStringSet;
      pseudosTournoisDejaVus     := MakeEmptyStringSet;
      pseudosAyantUnNomReel      := MakeEmptyStringSet;
      pseudosSansNomReel         := MakeEmptyStringSet;
      nomsReelsARajouterDansBase := MakeEmptyStringSet;
    end;


end;



const gLigneDeTestForTorture : String255 = 'blah-blah';
      gEOFPourTorture : boolean = false;



procedure ReadLineInTortureFile(var ligne : LongString; var theFic : FichierTEXT; var compteur : SInt64);
var s, s1, s2, s3, s4, s5, reste : String255;
    expected1, expected2 : String255;
    nroNoir, nroBlanc : SInt64;
    confiance : double;
    reussi : boolean;
    foo : boolean;
begin
  Discard(theFic);

  if gEOFPourTorture then exit;

  s := Trim(ligne.debutLigne);

  if (s <> '') and (s[1] <> '%') then
    begin
      Parser5( s, s1, s2, s3, s4, s5, reste);

      if (Pos('__END_OF_FILE__', s) = 1) then
        begin
          gEOFPourTorture := true;
          exit;
        end;

      if (Pos('EXPECTED :', s) = 1)
        then
          begin
            s := ReplaceStringOnce(s, 'EXPECTED :' , '');
            s := Trim(s);

            if Pos('VERSUS', s) > 0
              then
                begin
                  foo := SplitAt(s, 'VERSUS', expected1, expected2);
                  expected1 := Trim(UTF8ToAscii(expected1));
                  expected2 := Trim(UTF8ToAscii(expected2));

                  nroNoir  := kNroJoueurInconnu;
                  nroBlanc := kNroJoueurInconnu;
                  foo := TrouverNomsDesJoueursDansNomDeFichier(gLigneDeTestForTorture, nroNoir, nroBlanc, 0, confiance);

                  s1 := Trim(GetNomJoueur(nroNoir));
                  s2 := Trim(GetNomJoueur(nroBlanc));

                end
              else
                begin
                  expected1 := Trim(UTF8ToAscii(s));
                  expected2 := '';

                  foo := PeutImporterNomJoueurFormatPGN('name_mapping_VOG_to_WThor.txt', gLigneDeTestForTorture, false, s1, nroNoir);
                  s1 := Trim(s1);
                  s2 := '';

                end;

            reussi := NoCaseEquals(StripDiacritics(UTF8ToAscii(s1)), StripDiacritics(UTF8ToAscii(expected1))) and
                      NoCaseEquals(StripDiacritics(UTF8ToAscii(s2)), StripDiacritics(UTF8ToAscii(expected2)));


             if not(reussi) then
              begin
                WritelnDansRapport(gLigneDeTestForTorture);
                WriteDansRapport(UTF8ToAscii(ligne.debutLigne));

                if reussi
                  then WritelnDansRapport('                          PASS')
                  else WritelnDansRapport('                          FAILED !');

                if not(reussi) then
                  begin
                    WriteDansRapport('           GOT :  ');
                    WriteDansRapport(s1);
                    if (expected2 <> '') then
                      begin
                        WriteDansRapport('  VERSUS  ' + s2);
                        //WriteNumDansRapport('               (n,b) = (',nroNoir);
                        //WriteNumDansRapport(',',nroBlanc);
                        //WriteDansRapport(')');
                      end;
                    WritelnDansRapport('');
                  end;
                WritelnDansRapport('');
              end;


            compteur := compteur + 1000;
            if reussi then inc(compteur);
          end
        else
          gLigneDeTestForTorture := s;

    end;
end;




procedure FabriqueFichierDeTorture;
var k : SInt64;
    s, s1 : String255;
begin
  for k := 1 to NombreJoueursDansBaseOfficielle - 1 do
    begin
      s := GetNomJoueur(k);
      EnlevePrenom(s, s1);
      s1 := Trim(s1);
      if (LENGTH_OF_STRING(s1) = 3) then
        begin
          WritelnDansRapport(s1);
          WritelnDansRapport('EXPECTED :   '+s);
          WritelnDansRapport('');
        end;
    end;
end;


function OuvrirFichierTortureImportDesNoms(nomCompletFichier : String255) : OSErr;
const kTortureFileName = 'import-des-noms.torture.txt';
var fic : FichierTEXT;
    err : OSErr;
    note,nbDeTests,nbDeTestsReussis : SInt64;
    tick : SInt64;
begin
  err := -1;

  if NoCasePos(kTortureFileName, nomCompletFichier) <= 0 then
    exit;

  if not(JoueursEtTournoisEnMemoire) then
    begin
      WritelnDansRapport(ReadStringFromRessource(TextesBaseID,3));  {'chargement des joueurs et des tournois…'}
      WritelnDansRapport('');
      DoLectureJoueursEtTournoi(false);
    end;

  {ATRAffichageInfixe('formesPossiblesDesVanDen = ',gImportDesNoms.formesPossiblesDesVanDen);}

  WritelnDansRapport('----------------------------------------------------------------------------------');
  WritelnDansRapport('Chargement de ' + kTortureFileName);
  WritelnDansRapport('----------------------------------------------------------------------------------');

  tick := TickCount;

  note := 0;

  gEOFPourTorture := false;
  err := FichierTexteDeCassioExiste(kTortureFileName,fic);
  if err = NoErr then
    ForEachLineInFileDo(fic.theFSSpec, ReadLineInTortureFile, note);


  nbDeTests        := note div 1000;
  nbDeTestsReussis := note mod 1000;

  if (nbDeTests > 0) then
    begin
      WritelnDansRapport('----------------------------------------------------------------------------------');
      WriteNumDansRapport('  FAILED = ', nbDeTests - nbDeTestsReussis);
      WriteNumDansRapport('  PASS= ', nbDeTestsReussis);
      WriteNumDansRapport('      out of ', nbDeTests);
      WriteNumDansRapport(' tests  (', (100*nbDeTestsReussis) div nbDeTests);
      WriteDansRapport(' % )');
      WritelnNumDansRapport(',  time = ',TickCount - tick);
      WritelnDansRapport('----------------------------------------------------------------------------------');
    end;

  OuvrirFichierTortureImportDesNoms := err;

  // FabriqueFichierDeTorture;
end;




END.



































