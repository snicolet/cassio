UNIT UnitFFO;


INTERFACE








USES UnitDefCassio;


{ Initialisation de l'unite }
procedure InitUnitFFO;


{ telechargement du fichier FFO "joueurs.txt" }
function DoitTelechargerFichierFFODesJoueurs : boolean;


{ Fonctions de lecture du fichier FFO des joueurs }
procedure ParserNumerosFFODesJoueurs;
function PeutTrouverNumeroFFODuJoueur(whichWThorNumber : SInt32; var whichNumeroFFO : SInt32) : boolean;
procedure EffacerTousLesNumerosFFODesJoueurs;
procedure AfficherLesJoueursWthorSansNumeroFFO;







IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    MacErrors, OSUtils, Sound, DateTimeUtils
{$IFC NOT(USE_PRELINK)}
    , UnitListe, UnitRapport, SNEvents, basicfile, UnitActions, UnitSet
    , UnitEvenement, UnitSolve, UnitCriteres, UnitScannerOthellistique, UnitPositionEtTrait, MyMathUtils, UnitScannerUtils, MyFileSystemUtils
    , MyStrings, MyQuickDraw, UnitNouveauFormat, UnitBaseNouveauFormat, UnitAccesNouveauFormat, UnitRapport, UnitTriListe, UnitRapportImplementation
    , UnitCurseur, UnitUtilitaires, UnitEnvirons, UnitJeu, MyStrings, UnitRapportUtils, UnitEntreesSortiesListe, UnitGameTree
    , UnitArbreDeJeuCourant, UnitImportDesNoms, MyFileSystemUtils, UnitMiniProfiler, UnitDialog, UnitPressePapier, UnitTHOR_PAR, MyMathUtils
    , basicfile, UnitScannerUtils, UnitGenericGameFormat, UnitFenetres, UnitGestionDuTemps, UnitNormalisation, UnitPackedThorGame, SNEvents
    , UnitScannerOthellistique, UnitRapportWindow, UnitStringSet, UnitFormatsFichiers, UnitFichierAbstrait, UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/FFO.lk}
{$ENDC}


{END_USE_CLAUSE}




const kNomDuFichierJoueursFFODansCassio = 'Numeros-FFO-des-joueurs.txt';
      kURLDuFichierJoueursFFOChezManu   = 'http://ratings.worldothellofederation.com/files/joueurs.txt';

const gLastFFONameRead : String255 = "";
const gLastFFOLineRead : String255 = "";
const gLastFFONumberRead : SInt32  = -1;


var nombreJoueursDansFichierFFO : SInt32;


procedure InitUnitFFO;
begin
  nombreJoueursDansFichierFFO := 0;
end;



function DoitTelechargerFichierFFODesJoueurs : boolean;
var fic : basicfile;
    trouve : boolean;
begin
  trouve := (FichierTexteDeCassioExiste(kNomDuFichierJoueursFFODansCassio, fic) = NoErr);

  if not(trouve) then
    begin
      DoitTelechargerFichierFFODesJoueurs := false;
      exit;
    end;


  DoitTelechargerFichierFFODesJoueurs := true;
end;




procedure EffacerTousLesNumerosFFODesJoueurs;
var k : SInt32;
begin
  for k := 1 to JoueursNouveauFormat.nbJoueursNouveauFormat do
    SetNroFFODuJoueur(k, -1);
end;





procedure AfficherLesJoueursWthorSansNumeroFFO;
var k, nroRefPartie, foo: SInt32;
    numWThor, numFFO : SInt32;
    dernierTournoiAffiche : SInt32;
    nom : String255;
    joueursSansNumeroFFO : IntegerSet;
begin

  if (nbPartiesActives > 0)
    then
      begin

        joueursSansNumeroFFO := MakeEmptyIntegerSet;

        dernierTournoiAffiche := -10;

        for k := 1 to nbPartiesChargees do
          begin
            nroRefPartie := tableTriListe^^[k];
            if PartieEstActive(nroRefPartie) then
              begin

                // On commence par le joueur Noir
                numWThor := GetNumeroJoueurNoirDansFichierParNroRefPartie(nroRefPartie);

                if (GetNroFFODuJoueur(numWThor) <= 0) then
                  begin

                    // on a un joueur sans numero FFO
                    // on va tester si on l'a deja enregistre comme tel
                    if not(MemberOfIntegerSet(numWThor, foo, joueursSansNumeroFFO)) then
                      begin
                        // c'est un nouveau jouer sans numero FFO
                        AddIntegerToSet(numWThor, -1, joueursSansNumeroFFO);

                        // on calcule son nom avec le format du fichier FFO "joueurs.txt"
                        nom := GetNomJoueur(numWThor);
                        if (Pos('(', nom) <= 0) then // ce n'est pas un ordi
                          nom := GetNomJoueurCommeDansFichierFFODesJoueurs(numWThor);

                        // on l'affiche

                        if (dernierTournoiAffiche <> GetNroTournoiParNroRefPartie(nroRefPartie)) then
                          begin
                            WritelnDansRapport('');
                            WritelnDansRapport('Dans ' + GetNomTournoiAvecAnneeParNroRefPartie(nroRefPartie, 28) + ' :');
                            WritelnDansRapport('');

                            dernierTournoiAffiche := GetNroTournoiParNroRefPartie(nroRefPartie);
                          end;

                        WritelnDansRapport('ADD   ' + nom);
                      end;

                  end;

                // Et puis ensuite meme combat pour le joueur Blanc
                numWThor := GetNumeroJoueurBlancDansFichierParNroRefPartie(nroRefPartie);

                if (GetNroFFODuJoueur(numWThor) <= 0) then
                  begin

                    // on a un joueur sans numero FFO
                    // on va tester si on l'a deja enregistre comme tel
                    if not(MemberOfIntegerSet(numWThor, foo, joueursSansNumeroFFO)) then
                      begin
                        // c'est un nouveau jouer sans numero FFO
                        AddIntegerToSet(numWThor, -1, joueursSansNumeroFFO);

                        // on calcule son nom avec le format du fichier FFO "joueurs.txt"
                        nom := GetNomJoueur(numWThor);
                        if (Pos('(', nom) <= 0) then // ce n'est pas un ordi
                          nom := GetNomJoueurCommeDansFichierFFODesJoueurs(numWThor);

                        // on l'affiche

                        if (dernierTournoiAffiche <> GetNroTournoiParNroRefPartie(nroRefPartie)) then
                          begin
                            WritelnDansRapport('');
                            WritelnDansRapport('Dans ' + GetNomTournoiAvecAnneeParNroRefPartie(nroRefPartie, 28) + ' :');
                            WritelnDansRapport('');

                            dernierTournoiAffiche := GetNroTournoiParNroRefPartie(nroRefPartie);
                          end;

                        WritelnDansRapport('ADD   ' + nom);
                      end;

                  end;

              end;
          end;


        DisposeIntegerSet(joueursSansNumeroFFO);
      end
    else
      begin

        // on utilise l'ordre des joueurs du fichier WTHOR.JOU
        // le désavantage est que l'on ne peut pas deviner le pays d'un joueur


        for k := 1 to JoueursNouveauFormat.nbJoueursNouveauFormat do
          begin
            numWthor := GetNroJoueurDansSonFichier(k);

            if (k = numWThor) then
              begin
                numFFO := GetNroFFODuJoueur(numWthor);
                if (numFFO <= 0)
                  then
                    begin
                      nom := GetNomJoueur(numWthor);
                      if (Pos('(', nom) <= 0) then // ce n'est pas un ordi
                        nom := GetNomJoueurCommeDansFichierFFODesJoueurs(numWThor);
                      WritelnDansRapport('ADD   ' + nom);
                    end;
              end;
          end;

      end;

end;




procedure AjouterNumeroFFOPourCeJoueur(var ligne : LongString; var theFic : basicfile; var result : SInt32);
var s, s2, infosFFO, chaineNumero : String255;
    nomFFO, nomDansWThor : String255;
    numeroFFO, numeroWThor : SInt32;
    afficherLesJoueursDuFichierFFO : boolean;
    afficherLesDoublons : boolean;
    positionVirgule : SInt32;
begin

  Discard(theFic);
  Discard(result);

  afficherLesJoueursDuFichierFFO := false;
  afficherLesDoublons            := false;

  s := ligne.debutLigne;

  EnleveEspacesDeGaucheSurPlace(s);


  if (afficherLesJoueursDuFichierFFO orafficherLesDoublons)
     and StringBeginsWith(s, 'pays ') then
    begin
      WritelnDansRapport(s);
      WritelnDansRapport('');
    end;

  if (s <> '') and (s[1] <> '%') and not(StringBeginsWith(s, 'pays ')) then
    begin

      Split(s, '%', infosFFO, s2);

      Parse(infosFFO, chaineNumero, nomFFO);

      EnleveEspacesDeGaucheSurPlace(nomFFO);
      EnleveEspacesDeDroiteSurPlace(nomFFO);



      if (chaineNumero <> '') and (nomFFO <> '') and (nomFFO <> ',') then
        begin

          inc(nombreJoueursDansFichierFFO);


          positionVirgule := Pos(',',nomFFO);
          if (positionVirgule <= 0) then positionVirgule := 8; // sans doute un ordinateur


          nomFFO    := ReplaceStringOnce(nomFFO, ',' , '');
          numeroFFO := StrToInt32(chaineNumero);


          if afficherLesDoublons then
            begin
              if (TPCopy(nomFFO, 1, positionVirgule + 3) = TPCopy(gLastFFONameRead, 1, positionVirgule + 3)) then
                begin
                  // WritelnDansRapport('Doublon ?');

                  WritelnDansRapport(gLastFFOLineRead);
                  WritelnDansRapport(ligne.debutLigne);

                  (*

                  WriteDansRapport(IntToStrWithPadding(gLastFFONumberRead, 10, ' ') + '   ');
                  WritelnDansRapport(TPCopy(gLastFFONameRead,1,positionVirgule-1) + ',' + TPCopy(gLastFFONameRead,positionVirgule, 255));

                  WriteDansRapport(IntToStrWithPadding(numeroFFO, 10, ' ') + '   ');
                  WritelnDansRapport(TPCopy(nomFFO,1,positionVirgule-1) + ',' + TPCopy(nomFFO,positionVirgule, 255));

                  *)

                  WritelnDansRapport('');
                end;
            end;


          gLastFFONameRead   := nomFFO;
          gLastFFONumberRead := numeroFFO;
          gLastFFOLineRead   := ligne.debutLigne;


          if PeutImporterNomJoueurFormatPGN('', nomFFO, false, nomDansWThor, numeroWThor) and (numeroFFO > 0) and (numeroWThor > 0)
            then
              begin

                // Tout a l'air bon, hein... On ajoute le numero FFO de ce joueur en memoire !
                SetNroFFODuJoueur(GetNroJoueurDansSonFichier(numeroWThor), numeroFFO);


                if afficherLesJoueursDuFichierFFO and (nombreJoueursDansFichierFFO <= 100) then
                  WritelnDansRapport('OK : ' + nomFFO + ' = ' + nomDansWThor + ' = ' + IntToStr(numeroWThor));

              end
            else
              begin

                // Il s'agit d'un joueur FFO que l'on n'a pas trouvé dans la base WThor

                if afficherLesJoueursDuFichierFFO and (nombreJoueursDansFichierFFO <= 100) then
                  WritelnDansRapport('FAIL : ' + nomFFO);
              end;

        end;
    end;
end;







procedure ParserNumerosFFODesJoueurs;
var fic : basicfile;
    err : OSErr;
    result : SInt32;
begin

  WritelnDansRapport('dans ParserNumerosFFODesJoueurs...');

  if not(JoueursEtTournoisEnMemoire) then
     err := MetJoueursEtTournoisEnMemoire(false);



  if (FichierTexteDeCassioExiste(kNomDuFichierJoueursFFODansCassio,fic) = NoErr) then
    begin


      WritelnDansRapport('fichier ' + kNomDuFichierJoueursFFODansCassio + ' trouve : OK');

      EffacerTousLesNumerosFFODesJoueurs;


      nombreJoueursDansFichierFFO := 0;

      err := OpenFile(fic);
      ForEachLineInFileDo(fic.info, AjouterNumeroFFOPourCeJoueur,result);
      err := CloseFile(fic);

      WritelnNumDansRapport('nombre de joueurs lus dans le fichier FFO = ',nombreJoueursDansFichierFFO);


    end;

end;


function PeutTrouverNumeroFFODuJoueur(whichWThorNumber : SInt32; var whichNumeroFFO : SInt32) : boolean;
begin
  PeutTrouverNumeroFFODuJoueur := false;
  whichNumeroFFO := -1;

  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) and
     (whichWThorNumber >= 0) and
     (whichWThorNumber < nbJoueursNouveauFormat) and
     (listeJoueurs <> NIL) then
        begin

          whichNumeroFFO := GetNroFFODuJoueur(whichWThorNumber);

          if (whichNumeroFFO > 0) then
            begin
              PeutTrouverNumeroFFODuJoueur := true;
              exit;
            end;
        end;
end;






end.
