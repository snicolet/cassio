UNIT UnitFormatsFichiers;



INTERFACE







 USES UnitDefCassio;




procedure InitUnitFormatsFichiers;
procedure LibereMemoireFormatsFichiers;


{ « fic » doit etre un fichier fermé, il est rendu fermé}
function TypeDeFichierEstConnu(const fic : basicfile; var infos : FormatFichierRec; var err : OSErr) : boolean;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapport, MyStrings, UnitEntreeTranscript, UnitTHOR_PAR, UnitAccesNouveauFormat, SNEvents, UnitFichierAbstrait, UnitImportDesNoms
    , UnitScannerUtils, UnitServicesMemoire, UnitUtilitaires, UnitSmartGameBoard, UnitGenericGameFormat, UnitScannerOthellistique, MyFileSystemUtils, basicfile
    , UnitNouveauFormat, UnitPositionEtTrait, UnitNormalisation, MyMathUtils ;
{$ELSEC}
    {$I prelink/FormatsFichiers.lk}
{$ENDC}


{END_USE_CLAUSE}




const kTailleBufferArriere = 100;

var gLectureFichier :
      record
        whichFichierAbstrait : FichierAbstrait;
        bufferCaracteres : packed array[-kTailleBufferArriere..0] of char;
        caracteresASauter : SetOfChar;
      end;


procedure InitUnitFormatsFichiers;
begin
  AllKnownFormats := [  kTypeFichierCassio,
                        kTypeFichierScriptFinale,
                        kTypeFichierScriptZoo,
                        kTypeFichierSGF,
                        kTypeFichierPGN,
                        kTypeFichierGGF,
                        kTypeFichierGGFMultiple,
                        kTypeFichierXOF,
                        kTypeFichierXBoardAlien,
                        kTypeFichierZebra,
                        kTypeFichierExportTexteDeZebra,
                        kTypeFichierEPS,
                        kTypeFichierPressePapierCocoth,
                        kTypeFichierCocoth,
                        kTypeFichierHTMLOthelloBrowser,
                        kTypeFichierTranscript,
                        kTypeFichierPreferences,
                        kTypeFichierTournoiEntreEngines,
                        kTypeFichierBibliotheque,
                        kTypeFichierGraphe,
                        kTypeFichierTHOR_PAR,
                        kTypeFichierSuiteDePartiePuisJoueurs,
                        kTypeFichierSuiteDeJoueursPuisPartie,
                        kTypeFichierLigneAvecJoueurEtPartie,
                        kTypeFichierMultiplesLignesAvecJoueursEtPartie,
                        kTypeFichierSimplementDesCoups,
                        kTypeFichierSimplementDesCoupsMultiple,
                        kTypeFichierTortureImportDesNoms,
                        kTypeFichierCronjob
                      ];

end;

procedure LibereMemoireFormatsFichiers;
begin
end;


procedure SetCaracteresASauter(theChars : SetOfChar);
begin
  gLectureFichier.caracteresASauter := theChars;
end;

function GetCaracteresASauter : SetOfChar;
begin
  GetCaracteresASauter := gLectureFichier.caracteresASauter;
end;

procedure VideBufferCaracteres;
var i : SInt16;
begin
  for i := -kTailleBufferArriere to 0 do
    gLectureFichier.bufferCaracteres[i] := chr(0);
end;

procedure ResetLectureFichier;
var err : OSErr;
begin
  err := SetPositionMarqueurFichierAbstrait(gLectureFichier.whichFichierAbstrait,0);
  VideBufferCaracteres;
end;


function NombreCaracteresLusDansFichier : SInt32;
begin
  NombreCaracteresLusDansFichier := gLectureFichier.whichFichierAbstrait.position;
end;


function AvanceDansFichier(sauterLesCaracteresDeControle : boolean) : OSErr;
var err : OSErr;
    c : char;
    i,codeAsciiCaractere : SInt16;
    estUnCaractereDeControle : boolean;
begin
  err := GetNextCharOfFichierAbstrait(gLectureFichier.whichFichierAbstrait,c);
  while (err = NoErr) do
    begin

      codeAsciiCaractere := ord(c);
      estUnCaractereDeControle := (c in gLectureFichier.caracteresASauter);

      if not(estUnCaractereDeControle) or
         not(sauterLesCaracteresDeControle) then
         begin
		       for i := -kTailleBufferArriere to -1 do
		         gLectureFichier.bufferCaracteres[i] := gLectureFichier.bufferCaracteres[i+1];
		       gLectureFichier.bufferCaracteres[0] := c;

		       AvanceDansFichier := NoErr;
		       exit;
		     end;

		  err := GetNextCharOfFichierAbstrait(gLectureFichier.whichFichierAbstrait,c);
    end;
  AvanceDansFichier := err;
end;


function GetPreviousCharFichier(negOffset : SInt16) : char;
begin
  if (negOffset >= -kTailleBufferArriere) and (negOffset <= 0)
    then GetPreviousCharFichier := gLectureFichier.bufferCaracteres[negOffset]
    else GetPreviousCharFichier := chr(0);
end;


function GetNextCharFichier(sauterLesCaracteresDeControle : boolean; var c : char) : OSErr;
var err : OSErr;
begin
  err := AvanceDansFichier(sauterLesCaracteresDeControle);
  if err = NoErr then c := GetPreviousCharFichier(0);
  GetNextCharFichier := err;
end;


function GetNextLineDansFichier(var ligne : String255) : OSErr;
begin
  GetNextLineDansFichier := ReadlnDansFichierAbstrait(gLectureFichier.whichFichierAbstrait,ligne);
end;


function GetNextLongintDansFichier(var num : SInt32) : OSErr;
var err : OSErr;
    c : char;
    s : String255;
    longueur : SInt32;
begin

  { Sauter tous les caracteres qui ne sont pas des chiffres }
  err := GetNextCharFichier(false,c);
  while (err = NoErr) and not(IsDigit(c)) do
    err := GetNextCharFichier(false,c);

  { Lire le nombre }
  s := '';
  longueur := 0;
  while (err = NoErr) and IsDigit(c) and (longueur <= 10) do
    begin
      s := s + CharToString(c);
      inc(longueur);
      err := GetNextCharFichier(false,c);
    end;

  num := StrToInt32(s);
  GetNextLongintDansFichier := err;
end;


function VientDeLireCetteChaine(s : String255) : boolean;
var k,longueur : SInt16;
begin
  VientDeLireCetteChaine := false;

  longueur := LENGTH_OF_STRING(s);
  if (longueur > 0) then
    begin
      for k := longueur downto 1 do
        if not(GetPreviousCharFichier(k-longueur) = s[k])
          then exit;
      VientDeLireCetteChaine := true;
    end;
end;


function ScanChaineValeurProperty(caractereOuvrant,caractereFermant : char) : String255;
var s : String255;
    c : char;
    err : OSErr;
    longueur : SInt16;
begin
  err := NoErr;

  c := GetPreviousCharFichier(0);
  if c <> caractereOuvrant then err := GetNextCharFichier(true,c);

  if (c <> caractereOuvrant) or (err <> NoErr) then
    begin
      ScanChaineValeurProperty := '';
      exit;
    end;

  s := '';
  longueur := 0;
  repeat
    inc(longueur);
    err := GetNextCharFichier(true,c);
    if (err = NoErr) and (c <> caractereFermant)
      then s := s + c;
  until (err <> NoErr) or (longueur > 240) or (c = caractereFermant);

  ScanChaineValeurProperty := s;
end;


function ParserFormatWZebra(var chaineDesCoups : String255) : boolean;
const WZEBRA_START_OFFSET = 1356;
      WZEBRA_RECORD_LENGTH = 233;
type WZebraRec = packed array[0..232] of char;
var err : OSErr;
    index,count : SInt32;
    taille_zone_memoire,compteurCoup,coup : SInt32;
    myWZebraRec : WZebraRec;
begin
  chaineDesCoups := '';
  ParserFormatWZebra := false;

  err := SetPositionMarqueurFichierAbstrait(gLectureFichier.whichFichierAbstrait,WZEBRA_START_OFFSET);

  index               := WZEBRA_START_OFFSET;
  taille_zone_memoire := gLectureFichier.whichFichierAbstrait.nbOctetsOccupes;
  compteurCoup        := 0;
  count               := WZEBRA_RECORD_LENGTH;
  err                 := NoErr;

  while (err = NoErr) and (compteurCoup < 200) and (LENGTH_OF_STRING(chaineDesCoups) < (2 * 64)) and
        (count = WZEBRA_RECORD_LENGTH) and
        (index + WZEBRA_RECORD_LENGTH <= taille_zone_memoire) do
    begin
      inc(compteurCoup);

      err := ReadFromFichierAbstrait(gLectureFichier.whichFichierAbstrait,index,count,@myWZebraRec);
      index := index + WZEBRA_RECORD_LENGTH;

      coup := ord(myWZebraRec[4]);
      if (coup <> 0)
        then chaineDesCoups := chaineDesCoups + CoupEnStringEnMinuscules(coup);

    end;

  ParserFormatWZebra := (chaineDesCoups <> '');
end;



function TypeDeFichierEstConnu(const fic : basicfile; var infos : FormatFichierRec; var err : OSErr) : boolean;
const WZEBRA_HEADER = 'WZebra Revision 1.5';
var myFic : basicfile;
    compteurCaracteres : SInt32;
    compteurLignes : SInt32;
    parenthese_initiale_trouvee : boolean;
    GM_trouve : boolean;
    FF_trouvee : boolean;
    SZ_trouvee : boolean;
    browser_trouvee : boolean;
    applet_trouvee : boolean;
    header_trouvee : boolean;
    position_initiale_trouvee : boolean;
    partie_trouvee : boolean;
    que_points_ou_x_ou_o : boolean;
    que_des_coordonnees : boolean;
    sortieDeBoucle : boolean;
    c : char;
    caracteresDeControle : SetOfChar;
    s : String255;
    coupsPourLeTranscript : platValeur;
    theTranscript : Transcript;
    analyse : AnalyseDeTranscriptPtr;
    enregistrementGGF : PartieFormatGGFRec;

    square,numero : SInt32;



procedure EssaieReconnaitreFormatWZebra;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format WZebra…');
  }

  caracteresDeControle := [];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;
  compteurCaracteres := 0;
  header_trouvee := false;
  partie_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);

    if VientDeLireCetteChaine(WZEBRA_HEADER)  then
      begin
        header_trouvee := true;
        if ParserFormatWZebra(s) and EstUnePartieOthelloAvecMiroir(s) then
          begin
            partie_trouvee := true;
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + s;
            infos.format           := kTypeFichierZebra;
          end;
       end;

  until (err <> NoErr) or
        (compteurCaracteres > 30) or
        (header_trouvee and header_trouvee);
end;


procedure EssaieReconnaitreFormatExportTexteDeZebra;
var compteurLignesNonVides : SInt32;
    promptWZebraTrouve : boolean;
begin
  {WritelnDansRapport('recherche des caracteristiques de l'export .txt de WZebra…');}

  ResetLectureFichier;

  compteurLignes := 0;
  compteurLignesNonVides := 0;
  promptWZebraTrouve := false;

  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (s <> '') then inc(compteurLignesNonVides);

    if (compteurLignesNonVides >= 1) and (compteurLignesNonVides <= 2) then
      if (Pos('WZebra',s) > 0) or (Pos('Zebra',s) > 0) then promptWZebraTrouve := true;

    if (compteurLignesNonVides >= 3) and not(promptWZebraTrouve)
      then exit;

    if promptWZebraTrouve and EstUnePartieOthelloAvecMiroir(s) then
      begin
        infos.tailleOthellier  := 8;
        infos.positionEtPartie := '...........................ox......xo...........................' + s;
        infos.format           := kTypeFichierExportTexteDeZebra;
        exit;
      end;

  until (compteurLignes > 15) or (compteurLignesNonVides >= 7) or (err <> NoErr);

end;


procedure EssaieReconnaitreFormatSimplementDesCoups;
var compteurLignesNonVides : SInt32;
    compteurPartiesTrouvees : SInt32;
    joueur1,joueur2 : SInt32;
    confiance : double;
    moves,s,s1 : String255;
    partieLegale,joueursTrouves : boolean;
begin
  {WritelnDansRapport('recherche dans le fichier pour voir s'il y a une seule ligne, avec des coups…');}

  ResetLectureFichier;

  compteurLignes := 0;
  compteurLignesNonVides := 0;
  compteurPartiesTrouvees := 0;
  moves := '';


  { on n'accepte ce format que si le fichier contient une seule ligne,
    qui ne contient qu'une partie 'brute', et rien d'autre             }
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (err = NoErr) and (s <> '') then
      begin
        inc(compteurLignesNonVides);

        s1 := s;
        partieLegale := EstUnePartieOthelloAvecMiroir(s1);

        joueursTrouves := TrouverPartieEtJoueursDansChaine(s,moves,joueur1,joueur2,confiance);

        if partieLegale and not(joueursTrouves) then
          begin
            inc(compteurPartiesTrouvees);
            moves := s;
            partieLegale := EstUnePartieOthelloAvecMiroir(moves);  {symetrisons, eventuellement}
          end;

      end;
  until (compteurLignes > 6) or (compteurLignesNonVides >= 2) or (err <> NoErr);

  if (compteurPartiesTrouvees >= 1) and
     (compteurLignesNonVides = compteurPartiesTrouvees) and
     (moves <> '')  then
    begin
      {WritelnNumDansRapport('TROUVE (kTypeFichierSimplementDesCoups), compteurPartiesTrouvees = '+compteurPartiesTrouvees);}
      if (compteurPartiesTrouvees >= 2)
        then
          begin
            infos.tailleOthellier  := 8;
            infos.format           := kTypeFichierSimplementDesCoupsMultiple;
          end
        else
          begin
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + moves;
            infos.format           := kTypeFichierSimplementDesCoups;
          end;
    end;

end;


procedure EssaieReconnaitreFormatLigneAvecJoueurEtPartie;
var compteurLignesNonVides : SInt32;
    compteurPartiesTrouvees : SInt32;
    joueur1,joueur2 : SInt32;
    nbPionsNoirs,nbPionsBlancs : SInt32;
    confiance : double;
    partieTrouvee : boolean;
    s,moves: String255;
begin
  {WritelnDansRapport('recherche dans le fichier pour voir s''il y a des lignes avec une partie et des noms de joueurs…');}

  ResetLectureFichier;

  compteurLignes := 0;
  compteurLignesNonVides := 0;
  compteurPartiesTrouvees := 0;
  partieTrouvee := false;
  moves := '';

  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
    if (err = NoErr) and (s <> '') then
      begin
        inc(compteurLignesNonVides);

        partieTrouvee := TrouverPartieEtJoueursDansChaine(s,moves,joueur1,joueur2,confiance);
        partieTrouvee := partieTrouvee and EstUnePartieOthelloAvecMiroir(moves);  {symetrisons, eventuellement}

        if partieTrouvee then inc(compteurPartiesTrouvees);
      end;
  until (compteurLignes > 10) or (compteurPartiesTrouvees >= 2) or (err <> NoErr);

  if (compteurPartiesTrouvees >= 1) then
    begin

      if (compteurPartiesTrouvees >= 2)
        then
          begin
            infos.format          := kTypeFichierMultiplesLignesAvecJoueursEtPartie;
            infos.tailleOthellier := 8;
          end
        else
          begin
            infos.format           := kTypeFichierLigneAvecJoueurEtPartie;
            infos.tailleOthellier  := 8;
            infos.positionEtPartie := '...........................ox......xo...........................' + moves;

            if (joueur1 <> kNroJoueurInconnu) and (joueur2 <> kNroJoueurInconnu) then
              if EstUnePartieOthelloTerminee(moves,false,nbPionsNoirs,nbPionsBlancs)
                then infos.joueurs := GetNomJoueur(joueur1) + ' '+ScoreFinalEnChaine(nbPionsNoirs-nbPionsBlancs)+' ' + GetNomJoueur(joueur2)
                else infos.joueurs := GetNomJoueur(joueur1) + ' 0-0 ' + GetNomJoueur(joueur2);

          end;
    end;

end;


procedure EssaieReconnaitreFormatXBoardAlien;
var eventTagFound    : boolean;
    reversiTagFound  : boolean;
    FENTagFound      : boolean;
    FENString        : String255;
    thePosition      : PositionEtTraitRec;
    coups            : String255;
    token            : String255;
    k, k1, k2        : SInt32;
    buffer           : Ptr;
    indexDansFichier : SInt32;
    indexDansBuffer  : SInt32;
    count            : SInt32;
    tailleFichier    : SInt32;
    bufferSize       : SInt32;
    lastRead         : SInt32;
    oldParsingSet    : SetOfChar;
begin

  {WritelnDansRapport('recherche des caracteristiques du format PGN special genere par XBoard (Alien edition)…');}

  eventTagFound   := false;
  reversiTagFound := false;
  FENTagFound     := false;
  coups           := '';

  ResetLectureFichier;

  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);

    if Pos('[Event',s) > 0             then eventTagFound   := true;
    if Pos('[Variant "reversi"',s) > 0 then reversiTagFound := true;
    if Pos('[FEN ',s) > 0              then
      begin
        FENTagFound := true;
        FENString   := s;
      end;

  until (compteurLignes > 15) or (err <> NoErr) or (eventTagFound and reversiTagFound and fenTagFound);


  if eventTagFound and reversiTagFound and fenTagFound then
    begin

      if ParserFENEnPositionEtTrait(FENString, thePosition) then
        begin

          oldParsingSet := GetParserDelimiters;
          SetParserDelimiters([' ',tab,cr,lf]);


          indexDansFichier := GetPositionMarqueurFichierAbstrait(gLectureFichier.whichFichierAbstrait);
          tailleFichier    := gLectureFichier.whichFichierAbstrait.nbOctetsOccupes;
          err              := NoErr;
          bufferSize       := Min( 32000, tailleFichier - indexDansFichier + 1);
          buffer           := AllocateMemoryPtrClear(bufferSize);


          repeat

            // on lit le buffer dans le fichier
            count    := bufferSize;
            err := ReadFromFichierAbstrait(gLectureFichier.whichFichierAbstrait,indexDansFichier,count,buffer);

            indexDansFichier := indexDansFichier + count;


            // eclater le buffer en tokens
            indexDansBuffer := 0;
            repeat
              token := ParseBuffer(Ptr(buffer), bufferSize, indexDansBuffer, lastRead);

              (*
              WriteNumDansRapport('i = ',indexDansBuffer);
              WriteDansRapport('  =>  token = '+token);
              WriteNumDansRapport('  , last = ',lastRead);
              WritelnDansRapport('');
              *)

              indexDansBuffer := lastRead + 1;

              if (LENGTH_OF_STRING(token) >= 4) then
                begin

                  // les tokens qui nous interessent sont ceux qui contiennent "P@" ou "p@"
                  // ils indiquent la pose d'un pion dans le format XBoard (Alien edition)
                  s := token;
                  repeat
                    k1 := Pos('P@' , s);
                    k2 := Pos('p@' , s);

                    k := 0;
                    if (k1 > 0) and (k2 > 0) then k := Min(k1,k2) else
                    if (k1 > 0)            then k := k1 else
                    if (k2 > 0)            then k := k2;

                    if (k > 0) then
                      begin
                        square := StringEnCoup(TPCopy(s, k + 2, 2));
                        coups := coups + CoupEnStringEnMajuscules(CaseSymetrique(square,axeHorizontal));
                        s := TPCopy(s, k + 4, 255);
                      end;
                  until (k <= 0);

                end;
            until (token = '') or (indexDansBuffer >= bufferSize);

          until (err <> NoErr) or (LENGTH_OF_STRING(coups) >= (2 * 64)) or (indexDansFichier >= tailleFichier);


          DisposeMemoryPtr(Ptr(buffer));
          SetParserDelimiters(oldParsingSet);


          infos.tailleOthellier  := 8;
          infos.positionEtPartie := PositionEtTraitEnString(thePosition) + '  ' + coups;
          infos.format           := kTypeFichierXBoardAlien;

        end;
    end;

end;



procedure EssaieReconnaitreFormatPGN;
begin
  {if NoCasePos('.pgn',myFic.nomFichier) > 0 then}
  begin
    {WritelnDansRapport('recherche des caracteristiques du format PGN…');}

    ResetLectureFichier;

    compteurLignes := 0;
    repeat
      inc(compteurLignes);
      err := GetNextLineDansFichier(s);
      EnleveEspacesDeGaucheSurPlace(s);
    until (compteurLignes > 15) or (err <> NoErr) or (Pos('[Event',s) > 0);

    if Pos('[Event',s) > 0 then
      infos.format := kTypeFichierPGN;
  end;
end;

procedure EssaieReconnaitreFormatPreferencesCassio;
begin
  ResetLectureFichier;

  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
  until (compteurLignes > 3) or (err <> NoErr) or (Pos('%versionOfPrefsFile',s) = 1);

  if (Pos('%versionOfPrefsFile',s) = 1) then
    infos.format := kTypeFichierPreferences;
end;

procedure EssaieReconnaitreFormatBibliothequeCassio;
begin
  ResetLectureFichier;

  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s);
    EnleveEspacesDeGaucheSurPlace(s);
  until (compteurLignes > 3) or (err <> NoErr) or (Pos('% Format_Cassio = [bibliotheque]',s) = 1);

  if (Pos('% Format_Cassio = [bibliotheque]',s) = 1) then
    infos.format := kTypeFichierBibliotheque;
end;


procedure EssaieReconnaitreFormatCassio;
var c : char;
    sauter_les_coordonnees_autour_othellier : boolean;
begin

  { WritelnDansRapport('recherche des caracteristiques du format Cassio…'); }

  for sauter_les_coordonnees_autour_othellier := false to true do
    begin

      caracteresDeControle := [];
      for c := chr(0) to chr(255) do
        if (ord(c) <= 32) or (c = ' ') or (c = chr(202)) or (c = ' ') then
          caracteresDeControle := caracteresDeControle + [c];

      if sauter_les_coordonnees_autour_othellier then
        begin
          for c := 'a' to 'h' do caracteresDeControle := caracteresDeControle + [c];
          for c := 'A' to 'H' do caracteresDeControle := caracteresDeControle + [c];
          for c := '1' to '8' do caracteresDeControle := caracteresDeControle + [c];
        end;


      SetCaracteresASauter(caracteresDeControle);

      ResetLectureFichier;
      compteurCaracteres := 0;
      position_initiale_trouvee := false;
      partie_trouvee := false;

      que_points_ou_x_ou_o := true;
      que_des_coordonnees := true;
      s := '';
      sortieDeBoucle := false;
      repeat
        inc(compteurCaracteres);
        err := GetNextCharFichier(true,c);

        {
        WriteDansRapport(c);
        WriteNumDansRapport(' ' + Concat(c,' '),ord(c));
        WritelnNumDansRapport(' ',compteurCaracteres);
        }

        if (compteurCaracteres <= 64) then
          begin
            s := s + c;
    	      que_points_ou_x_ou_o := que_points_ou_x_ou_o and
    	                              CharInSet(c,['.','-','—','_','–',',','+','#','x','X','*','•','o','O','0']);
          end;

        if compteurCaracteres = 64 then
          position_initiale_trouvee := que_points_ou_x_ou_o;

        if (compteurCaracteres > 64) and (compteurCaracteres < 250) and
           (c <> '¬') and (c <> '%') and (err = NoErr) then
          begin
            s := s + c;
            que_des_coordonnees := que_des_coordonnees and
                                   (CharInRange(c,'a','h') or CharInRange(c,'A','H') or CharInRange(c,'1','8'));
          end;

        if (c = '%') or (c = '¬') or (err <> NoErr) then
          begin
            sortieDeBoucle := true;
            partie_trouvee := que_des_coordonnees and (compteurCaracteres < 250);
          end;

      until (err <> NoErr) or sortieDeBoucle or
            (compteurCaracteres > 250) or
            (position_initiale_trouvee and partie_trouvee) or
            ((compteurCaracteres > 64) and not(position_initiale_trouvee));

      if (position_initiale_trouvee and partie_trouvee) then
        begin
          infos.format           := kTypeFichierCassio;
          infos.tailleOthellier  := 8;
          infos.positionEtPartie := s;
          {WritelnDansRapport(s);}
          exit;
        end;

    end;  {for}
end;

procedure EssaieReconnaitreFormatSGF;
var c : char;
begin

  {
  WritelnDansRapport('recherche des caracteristiques du format SGF…');
  }

  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) or (c = ' ') then
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;
  compteurCaracteres := 0;
  parenthese_initiale_trouvee := false;
  GM_trouve := false;
  FF_trouvee := false;
  SZ_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);

    {WriteDansRapport(c);}

    if (GetPreviousCharFichier(-1) = '(') and
       (GetPreviousCharFichier(0) = ';')
      then parenthese_initiale_trouvee := true;

    if (GetPreviousCharFichier(-2) = 'G') and
       (GetPreviousCharFichier(-1) = 'M') and
       (GetPreviousCharFichier(0) = '[')
      then GM_trouve := true;

    if (GetPreviousCharFichier(-2) = 'F') and
       (GetPreviousCharFichier(-1) = 'F') and
       (GetPreviousCharFichier(0) = '[')
      then FF_trouvee := true;

    if (GetPreviousCharFichier(-2) = 'S') and
       (GetPreviousCharFichier(-1) = 'Z') and
       (GetPreviousCharFichier(0) = '[') then
      begin
        s := ScanChaineValeurProperty('[',']');

        {WritelnDansRapport('');
        WritelnDansRapport('s = '+s);}

        if s = '6' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 6;
          end;

        if s = '8' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 8;
          end;

        if s = '9' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 9;
          end;

        if s = '10' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 10;
          end;

        if s = '11' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 11;
          end;

        if s = '12' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 12;
          end;

        if s = '13' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 13;
          end;

        if s = '14' then
          begin
            SZ_trouvee := true;
            infos.tailleOthellier := 14;
          end;
      end;

  until (err <> NoErr) or
        (compteurCaracteres > 20000) or
        (parenthese_initiale_trouvee {and GM_trouve} and FF_trouvee and SZ_trouvee);

  (*
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('parenthese_initiale_trouvee = ',parenthese_initiale_trouvee);
  WritelnStringAndBooleanDansRapport('GM_trouve = ',GM_trouve);
  WritelnStringAndBooleanDansRapport('FF_trouvee = ',FF_trouvee);
  WritelnStringAndBooleanDansRapport('SZ_trouvee = ',SZ_trouvee);
  *)

  if (parenthese_initiale_trouvee {and GM_trouve} and FF_trouvee and SZ_trouvee) then
    begin
      infos.format := kTypeFichierSGF;
    end;
end;

procedure EssaieReconnaitreFormatGGF;
var c : char;
    nbBoardPropertiesTrouvees : SInt32;
    nbGamePropertiesTrouvees : SInt32;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format GGF…');
  }

  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) or (c = ' ') then
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;
  compteurCaracteres := 0;

  nbGamePropertiesTrouvees := 0;
  nbBoardPropertiesTrouvees := 0;


  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);

    {
    WriteDansRapport(c);
    }

    if (GetPreviousCharFichier(-4) = '(') and
       (GetPreviousCharFichier(-3) = ';') and
       (GetPreviousCharFichier(-2) = 'G') and
       (GetPreviousCharFichier(-1) = 'M') and
       (GetPreviousCharFichier(0) = '[') then
       begin
         s := ScanChaineValeurProperty('[',']');
         if (s = 'Reversi') or (s = 'Othello')
           then inc(nbGamePropertiesTrouvees);
       end;


    if (GetPreviousCharFichier(-4) = 'B') and
       (GetPreviousCharFichier(-3) = 'O') and
       (GetPreviousCharFichier(-2) = '[') and
       (GetPreviousCharFichier(-1) = '1') and
       (GetPreviousCharFichier(0) = '2') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 12;
       end;

    if (GetPreviousCharFichier(-4) = 'B') and
       (GetPreviousCharFichier(-3) = 'O') and
       (GetPreviousCharFichier(-2) = '[') and
       (GetPreviousCharFichier(-1) = '1') and
       (GetPreviousCharFichier(0) = '1') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 11;
       end;

    if (GetPreviousCharFichier(-4) = 'B') and
       (GetPreviousCharFichier(-3) = 'O') and
       (GetPreviousCharFichier(-2) = '[') and
       (GetPreviousCharFichier(-1) = '1') and
       (GetPreviousCharFichier(0) = '0') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 10;
       end;

    if (GetPreviousCharFichier(-3) = 'B') and
       (GetPreviousCharFichier(-2) = 'O') and
       (GetPreviousCharFichier(-1) = '[') and
       (GetPreviousCharFichier(0) = '9') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 9;
       end;

    if (GetPreviousCharFichier(-3) = 'B') and
       (GetPreviousCharFichier(-2) = 'O') and
       (GetPreviousCharFichier(-1) = '[') and
       (GetPreviousCharFichier(0) = '8') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 8;
       end;

     if (GetPreviousCharFichier(-3) = 'B') and
       (GetPreviousCharFichier(-2) = 'O') and
       (GetPreviousCharFichier(-1) = '[') and
       (GetPreviousCharFichier(0) = '7') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 7;
       end;

     if (GetPreviousCharFichier(-3) = 'B') and
       (GetPreviousCharFichier(-2) = 'O') and
       (GetPreviousCharFichier(-1) = '[') and
       (GetPreviousCharFichier(0) = '6') then
       begin
         inc(nbBoardPropertiesTrouvees);
         infos.tailleOthellier := 6;
       end;

  until (err <> NoErr) or
        (compteurCaracteres > 4000) or
        ((nbGamePropertiesTrouvees >= 2) and (nbBoardPropertiesTrouvees >= 1));

  {
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('GM_trouve = ',GM_trouve);
  WritelnStringAndBooleanDansRapport('BO_trouvee = ',BO_trouvee);
  }

  if (nbGamePropertiesTrouvees >= 1) and (nbBoardPropertiesTrouvees >= 1) then
    begin
      if (nbGamePropertiesTrouvees >= 2)
        then infos.format := kTypeFichierGGFMultiple
        else infos.format := kTypeFichierGGF;
    end;
end;

procedure EssaieReconnaitreFormatXOF;
begin
end;


procedure EssaieReconnaitreFormatSuiteDeParties;
var s1,s2,s3 : String255;
    somme : String255;
    moves,noms : String255;
    nbNoirs,nbBlancs : SInt32;
    n1,n2 : SInt32;
    erreurES : OSErr;
    confiance : double;
begin

  if not(problemeMemoireBase) and not(JoueursEtTournoisEnMemoire)
    then erreurES := MetJoueursEtTournoisEnMemoire(false);

  ResetLectureFichier;

  s1 := '';
  s2 := '';
  s3 := '';

  compteurLignes := 0;
  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(s1);
    EnleveEspacesDeGaucheSurPlace(s1);
  until (compteurLignes > 3) or (err <> NoErr) or (s1 <> '');

  if (err = NoErr) then
    begin
      compteurLignes := 0;
      repeat
        inc(compteurLignes);
        err := GetNextLineDansFichier(s2);
        EnleveEspacesDeGaucheSurPlace(s2);
      until (compteurLignes > 3) or (err <> NoErr) or (s2 <> '');
    end;

  if (err = NoErr) then
    begin
      compteurLignes := 0;
      repeat
        inc(compteurLignes);
        err := GetNextLineDansFichier(s3);
        EnleveEspacesDeGaucheSurPlace(s3);
      until (compteurLignes > 3) or (err <> NoErr) or (s3 <> '');
    end;


  moves := s1;
  noms  := s2;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) and (moves <> '') and
     EstUnePartieOthelloAvecMiroir(moves) and
     (not(EstUnePartieOthello(somme,false)) or EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) and
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDePartiePuisJoueurs;

  moves := s2;
  noms  := s1;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) and (moves <> '') and
     EstUnePartieOthelloAvecMiroir(moves) and
     (not(EstUnePartieOthello(somme,false)) or EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) and
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDeJoueursPuisPartie;


  moves := s1 + s2;
  noms  := s3;
  somme := moves + noms;
  if (infos.format = kTypeFichierInconnu) and (moves <> '') and
     EstUnePartieOthelloAvecMiroir(moves) and
     (not(EstUnePartieOthello(somme,false)) or EstUnePartieOthelloTerminee(moves,false,nbNoirs,nbBlancs)) and
     TrouverNomsDesJoueursDansNomDeFichier(noms,n1,n2,0,confiance)
    then infos.format := kTypeFichierSuiteDePartiePuisJoueurs;

end;


procedure EssaieReconnaitreFormatHTMLOthelloBrowser;
var c : char;
begin
  {
  WritelnDansRapport('recherche des caracteristiques du format HTML avec l'applet OthelloBrowser ou OthelloViewer…');
  }

  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) or (c = ' ') then
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;
  compteurCaracteres := 0;
  browser_trouvee := false;
  applet_trouvee := false;
  partie_trouvee := false;
  repeat
    inc(compteurCaracteres);
    err := GetNextCharFichier(true,c);

    {
    WriteDansRapport(c);
    }
    if VientDeLireCetteChaine('OthelloBrowser') or
       VientDeLireCetteChaine('othellobrowser') or
       VientDeLireCetteChaine('OTHELLOBROWSER') or
       VientDeLireCetteChaine('OthelloViewer')  or
       VientDeLireCetteChaine('othelloviewer')  or
       VientDeLireCetteChaine('OTHELLOVIEWER')  then
      begin
        browser_trouvee := true;
        infos.tailleOthellier := 8;
      end;

    if VientDeLireCetteChaine('applet') or
       VientDeLireCetteChaine('Applet') or
       VientDeLireCetteChaine('APPLET') then
      begin
        applet_trouvee := true;
      end;

    if VientDeLireCetteChaine('value="') or
       VientDeLireCetteChaine('Value="') or
       VientDeLireCetteChaine('VALUE="') then
     begin
       s := ScanChaineValeurProperty('"','"');
       if EstUnePartieOthelloAvecMiroir(s) then
         begin
           partie_trouvee := true;
           infos.positionEtPartie := '...........................ox......xo...........................' + s;
         end;
     end;

  until (err <> NoErr) or
        (compteurCaracteres > 20000) or
        (browser_trouvee and applet_trouvee and partie_trouvee);

  {
  WritelnDansRapport('');
  WritelnStringAndBooleanDansRapport('browser_trouvee = ',browser_trouvee);
  WritelnStringAndBooleanDansRapport('applet_trouvee = ',applet_trouvee);
  WritelnStringAndBooleanDansRapport('partie_trouvee = ',partie_trouvee);
  WritelnDansRapport('infos.positionEtPartie = '+infos.positionEtPartie);
  }


  if browser_trouvee and applet_trouvee and partie_trouvee then
    begin
      infos.format := kTypeFichierHTMLOthelloBrowser;
    end;
end;


procedure EssaieReconnaitreFormatTranscript;
var coordonnees_a_gauche : boolean;
    coordonnees_a_droite : boolean;
    cases_centrales_peuvent_etre_zero : boolean;
begin
  caracteresDeControle := [];
  SetCaracteresASauter(caracteresDeControle);

  analyse := AnalyseDeTranscriptPtr(AllocateMemoryPtrClear(SizeOf(AnalyseDeTranscript)));

  for coordonnees_a_gauche := false to true do
    for coordonnees_a_droite := false to true do
      for cases_centrales_peuvent_etre_zero := false to true do
        if (infos.format = kTypeFichierInconnu) and (analyse <> NIL) then
          begin
            ResetLectureFichier;
            MemoryFillChar(@coupsPourLeTranscript,SizeOf(platValeur),chr(0));

            err := NoErr;
            square := 10;
            repeat
              if ((square mod 10) = 0) and not(coordonnees_a_gauche) then inc(square) else
              if ((square mod 10) = 9) and not(coordonnees_a_droite) then inc(square)
                else
                  begin
                    err := GetNextLongintDansFichier(numero);

                    { sauter les cases centrales, sauf si on a l'impression
                      qu''elles sont numerotes par zero dans le transcript }
                    if ((square = 44) or (square = 45) or (square = 54) or (square = 55))
                       and (cases_centrales_peuvent_etre_zero or (numero <> 0)) then
                      while (square = 44) or (square = 45) or (square = 54) or (square = 55) do
                        inc(square);

                    if (numero >= 0) and (numero <= 99) then
                      begin
                        if (square <= 88) then coupsPourLeTranscript[square] := numero;
                        inc(square);
                      end;
                  end;

            until (err <> NoErr) or (square > 88) or
                  (NombreCaracteresLusDansFichier >= 2000);

            if (square > 88) then
              begin

                theTranscript := MakeTranscriptFromPlateauOthello(coupsPourLeTranscript);
                ChercherLesErreursDansCeTranscript(theTranscript,analyse^);

                (*
                WritelnDansRapport('appel de ChercherLesErreursDansCeTranscript');
                WritelnNumDansRapport('nbDoublons = ',analyse^.nbDoublons);
                WritelnNumDansRapport('nbCoupsIsoles = ',analyse^.nbCoupsIsoles);
                WritelnNumDansRapport('nbCoupsManquants = ',analyse^.nbCoupsManquants);
                WritelnNumDansRapport('numeroPremierCoupManquant = ',analyse^.numeroPremierCoupManquant);
                WritelnNumDansRapport('numeroDernierCoupPresent = ',analyse^.numeroDernierCoupPresent);
                WritelnNumDansRapport('numeroPremierCoupIllegal = ',analyse^.numeroPremierCoupIllegal);
                WritelnNumDansRapport('numeroPremierDoublon = ',analyse^.numeroPremierDoublon);
                WritelnNumDansRapport('numeroPremierCoupIsole = ',analyse^.numeroPremierCoupIsole);
                WritelnNumDansRapport('nombreCoupsPossibles = ',analyse^.nombreCoupsPossibles);
                WritelnNumDansRapport('nombreCasesRemplies = ',analyse^.nombreCasesRemplies);
                WritelnDansRapport('===============================');
                *)

                if analyse^.tousLesCoupsSontLegaux then
                  begin
                    s := analyse^.plusLonguePartieLegale;
                    if EstUnePartieOthelloAvecMiroir(s) then {symetrisons, eventuellement}
  						        begin
  						          infos.format           := kTypeFichierTranscript;
  						          infos.tailleOthellier  := 8;
  						          infos.positionEtPartie := '...........................ox......xo...........................' + s;
  						        end;
                  end;
              end;
          end;

   DisposeMemoryPtr(Ptr(analyse));
end;


procedure EssaieReconnaitreFormatScriptFinales;
var c : char;
begin
  if (NoCasePos('.script',myFic.nomFichier) > 0) {or (NoCasePos('clipboard',myFic.nomFichier) > 0)} then
    begin

      {
      WritelnDansRapport('recherche des caracteristiques du format Script de finales…');
      }

      caracteresDeControle := [];
      for c := chr(0) to chr(255) do
        if (ord(c) <= 32) or (c = ' ') then
          caracteresDeControle := caracteresDeControle + [c];
      SetCaracteresASauter(caracteresDeControle);

      ResetLectureFichier;
      err := GetNextCharFichier(true,c);

      if CharInSet(c,['%','-','X','x','0','O','o']) then
        begin
          infos.format := kTypeFichierScriptFinale;
        end;
    end;
end;


procedure EssaieReconnaitreFormatCronjob;
begin
  if (NoCasePos('.cronjob',myFic.nomFichier) > 0)  then
    begin
      infos.format := kTypeFichierCronjob;
    end;
end;



procedure EssaieReconnaitreFormatEPS;
var compteurLignes : SInt32;
    ligne1, ligne2, ligne, foo : String255;
    posDebut, moves : String255;
begin
  {if (NoCasePos('.eps',myFic.nomFichier) > 0) then }
    begin
      caracteresDeControle := [];
      SetCaracteresASauter(caracteresDeControle);

      ResetLectureFichier;

      compteurLignes := 2;

      err := GetNextLineDansFichier(ligne1);
      err := GetNextLineDansFichier(ligne2);

      if (err = NoErr) and
         (Pos('%!PS-Adobe-3.0 EPSF-3.0', ligne1) = 1) and
         (Pos('%%Creator: Cassio',       ligne2) = 1) then
        begin
          infos.format := kTypeFichierEPS;
          infos.tailleOthellier  := 8;

          posDebut := PositionEtTraitInitiauxStandardEnString;
          moves := '';
          repeat
            inc(compteurLignes);
            err := GetNextLineDansFichier(ligne);
            if (ligne <> '') then
              begin
                if (Pos('%%Othello-initial-position: ', ligne) = 1) then
                  Parse(ligne, foo, posDebut);
                if (Pos('%%Othello-moves: ', ligne) = 1) then
                  Parse(ligne, foo, moves);
              end;
          until (compteurLignes > 20) or (err <> NoErr) or (Pos('%%BeginProlog',ligne) > 0) or (Pos('%%EndComments',ligne) > 0);

          infos.positionEtPartie := posDebut + ' ' + moves;
        end;
    end;
end;


procedure EssaieReconnaitreFormatScriptZoo;
var c : char;
    compteurLignes : SInt32;
    ligne,s,s1,s2 : String255;
begin

  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) or (c = ' ') then
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;

  compteurLignes := 0;

  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(ligne);

    if Split(ligne,'%',s1,s2)
      then s := s1
      else s := ligne;
    EnleveEspacesDeGaucheSurPlace(s);

    if (Pos('JOB ',s) = 1) or (Pos('PREFETCH ',s) = 1) then
      begin
        infos.format := kTypeFichierScriptZoo;
        exit;
      end;

  until (compteurLignes > 25) or (err <> NoErr);

end;



procedure EssaieReconnaitreFormatTournoisEntreEngines;
begin
  if (NoCasePos('.tournament',myFic.nomFichier) > 0)  then
    begin
      infos.format := kTypeFichierTournoiEntreEngines;
    end;
end;


procedure EssaieReconnaitreFormatFichierTortureImportDesNoms;
begin
  if (NoCasePos('import-des-noms.torture.txt',myFic.nomFichier) > 0)  then
    begin
      infos.format := kTypeFichierTortureImportDesNoms;
    end;
end;


procedure EssaieReconnaitreFormatScriptFinalesDansPressePapier;
var c : char;
    compteurLignes : SInt32;
    compteurLignesNonVides : SInt32;
    ligne,s,s1,s2,reste : String255;
begin

  {
  WritelnDansRapport('recherche d'une partie isolée au format Script de finales');
  }

  caracteresDeControle := [];
  for c := chr(0) to chr(255) do
    if (ord(c) <= 32) or (c = ' ') then
      caracteresDeControle := caracteresDeControle + [c];
  SetCaracteresASauter(caracteresDeControle);

  ResetLectureFichier;

  compteurLignes := 0;

  repeat
    inc(compteurLignes);
    err := GetNextLineDansFichier(ligne);

    if Split(ligne,'%',s1,s2)
      then s := s1
      else s := ligne;


    EnleveEspacesDeGaucheSurPlace(s);
    if (s <> '') then
      begin
        inc(compteurLignesNonVides);

        c := s[1];

        if CharInSet(c,['%','-','X','x','0','O','o'])
          then
            begin
              Parse2(s,s1,s2,reste);
              if (s1[1] <> '%') and ChaineNeContientQueCesCaracteres(s1,['-','X','x','0','O','o']) then
                begin
                  if (LENGTH_OF_STRING(s1) = 64) and (LENGTH_OF_STRING(s2) = 1) then
                    begin
                      infos.tailleOthellier  := 8;
                      infos.positionEtPartie := s1 + ' ' + s2 + ' ' + reste;
                      infos.format           := kTypeFichierCassio;
                      exit;
                    end else
                  if (LENGTH_OF_STRING(s1) = 65) then
                    begin
                      infos.tailleOthellier  := 8;
                      infos.positionEtPartie := LeftStr(s1,64) + ' ' + RightStr(s1,1) + ' ' +s2 + ' ' + reste;
                      infos.format           := kTypeFichierCassio;
                      exit;
                    end;
                end;
            end
          else
            begin
              // on vient de trouver un caractere illegal en debut de ligne
              exit;
            end;
      end;


  until (compteurLignes > 25) or (err <> NoErr);


end;

procedure EssaieReconnaitreFormatTHOR_PAR;
begin
  if (NoCasePos('.PAR',myFic.nomFichier) > 0) and
     (gLectureFichier.whichFichierAbstrait.nbOctetsOccupes = TailleDuFichierTHOR_PAR) then
    begin
      infos.format           := kTypeFichierTHOR_PAR;
      infos.tailleOthellier  := 8;
    end;
end;


procedure DumpFirstCaracteresOfFileDansRapport(nbDeCaracteres : SInt32);
var err : OSErr;
    c : char;
    compteur : SInt32;
begin
  ResetLectureFichier;
  compteur := 0;
  repeat
    inc(compteur);
    err := GetNextCharFichier(true,c);
    WritelnNumDansRapport(IntToStr(compteur-compteur) + ' : '+CharToString(c)+'=',ord(c));
  until EscapeDansQueue or (compteur >= nbDeCaracteres);
end;


procedure EssaieReconnaitreFormatGraphe;
begin
end;


begin  { TypeDeFichierEstConnu }

  infos.format           := kTypeFichierInconnu;
  infos.tailleOthellier  := 0;
  infos.version          := 0;
  infos.positionEtPartie := '';
  infos.joueurs          := '';

  err := -1;

  {
  WritelnDansRapport('entree dans TypeDeFichierEstConnu');
  WritelnDansRapport('   dans TypeDeFichierEstConnu, fic.nomFichier = '+fic.nomFichier);
  WritelnNumDansRapport('   dans TypeDeFichierEstConnu, fic.vRefNum = ',fic.vRefNum);
  WritelnDansRapport('   dans TypeDeFichierEstConnu, GetName(fic.info) = '+GetName(fic.info));
  WritelnNumDansRapport('   dans TypeDeFichierEstConnu, fic.info.vRefNum = ',fic.info.vRefNum);
  }


  if (FileExists(fic.nomFichier,0,myFic) = NoErr) and
     (GetName(myFic.info)[1] <> '.') {on ne veut pas les fichiers dont le nom commence par un point}
     then
    with gLectureFichier do
      begin

        {
        WritelnDansRapport('OK, FileExists dans TypeDeFichierEstConnu');
        }

        whichFichierAbstrait := MakeFichierAbstraitFichier(myFic.nomFichier,0);
        if FichierAbstraitEstCorrect(whichFichierAbstrait) then
          begin

            {
            WritelnDansRapport('OK, FichierAbstraitEstCorrect(whichFichierAbstrait) dans TypeDeFichierEstConnu');
            }

            {on cherche à savoir si c'est un fichier EPS créé par Cassio}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatEPS;


            {on cherche à savoir si c'est un fichier PGN spécial créé par XBoard Alien (cf plus bas pour les vrais PGN}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatXBoardAlien;


            {on cherche à savoir si c'est un fichier cronjob}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatCronjob;


            {on cherche les caracteres caracteristiques du format WZebra}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatWZebra;


            {on cherche les lignes caracteristiques du format export texte de WZebra}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatExportTexteDeZebra;


            {on cherche à savoir si c'est un fichier PGN (VOG ou Kurnik)}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatPGN;


            {on cherche à savoir si c'est un fichier de script de finale}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatScriptFinales;


            {on cherche à savoir si c'est un fichier au format Cassio}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatCassio;


			{on cherche à savoir si c'est un fichier THOR.PAR}
			if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatTHOR_PAR;


            {on cherche à savoir si c'est un fichier de preferences de Cassio}
			if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatPreferencesCassio;


			{on cherche à savoir si c'est un fichier pour organiser un tournoi entre engines}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatTournoisEntreEngines;


            {on cherche à savoir si c'est un fichier de torture pour la reconnaissance des noms}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatFichierTortureImportDesNoms;


            {on cherche à savoir si c'est un fichier de jobs du zoo}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatScriptZoo;


            {on cherche les caracteres caracteristiques du format SGF}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSGF;


            {on cherche à savoir si c'est un fichier de bibliotheque de Cassio}
			if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatBibliothequeCassio;


            {on cherche les caracteres caracteristiques du format GGF}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatGGF;


            {on cherche à savoir si c'est une fichier contenant simplement une suite de coups}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSimplementDesCoups;


			{on cherche les caracteres caracteristiques du format HTML avec applet OthelloBrowser ou OthelloViewer}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatHTMLOthelloBrowser;


            {on cherche a trouver un transcript legal}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatTranscript;


            {on cherche a trouver une liste de coups avec des joueurs}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatLigneAvecJoueurEtPartie;


            {on cherche les lignes caracteristiques du format SuiteDeParties}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatSuiteDeParties;


            {on cherche s'il s'agit d'une position isolee au format script de finale}
            if infos.format = kTypeFichierInconnu then EssaieReconnaitreFormatScriptFinalesDansPressePapier;



            { TODO : je devrais faire de reverse engeneering et essayer de comprendre le format .wzg pour les positions…
            if (infos.format = kTypeFichierInconnu) and (NoCasePos('problema 10 Negras.wzg',myFic.nomFichier) > 0) then
              DumpFirstCaracteresOfFileDansRapport(1376);
            }

            DisposeFichierAbstrait(whichFichierAbstrait);
          end;


        if (infos.format = kTypeFichierSGF) or (infos.format = kTypeFichierGGF) then
          begin

            (*
            WritelnDansRapport('kTypeFichierSGF or kTypeFichierGGF : OK');
            WritelnNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);
            WritelnNumDansRapport('infos.format = ',SInt32(infos.format));
            *)

            if (infos.tailleOthellier = 8) then
              begin
                err := ReadEnregistrementDansFichierSGF_ou_GGF_8x8(myFic,infos.format,enregistrementGGF);
                with enregistrementGGF do
                  if EstUnePartieOthelloAvecMiroir(coupsEnAlpha) then
                    begin
                      infos.positionEtPartie := '...........................ox......xo...........................' + coupsEnAlpha;
                      infos.joueurs          := joueurNoir + ' - ' + joueurBlanc;
                    end;
              end;

            (*
            WritelnNumDansRapport('infos.tailleOthellier = ',infos.tailleOthellier);
            WritelnNumDansRapport('infos.format = ',SInt32(infos.format));
            *)

          end;

      end;


  TypeDeFichierEstConnu := (infos.format <> kTypeFichierInconnu);
end;



(*

  A B C D E F G H
1 - - - * * * - - 1
2 - - - - * * - - 2
3 - - * * * * * * 3
4 - - * * * * * * 4
5 - * * * * * * * 5
6 - - - O * * O * 6
7 - - - O * * O O 7
8 - - - - - * - - 8
  A B C D E F G H

   A  B  C  D  E  F  G  H
1 |51|39|36|34|33|37|56|57|
2 |52|50|16|25|11|14|58|31|
3 |26|35|22| 5| 6|15|17|30|
4 |43|21|10|()|##| 4| 7|29|
5 |45|12| 3|##|()| 1| 8|28|
6 |46|40|23| 2| 9|18|32|19|
7 |47|49|20|13|27|24|54|60|
8 |48|53|42|41|44|38|59|55|


   A   B   C   D   E   F   G   H
1  00  00  00  00  00  00  00  00
2  00  00  00  00  00  00  00  00
3  00  00  00  00  00  00  00  00
4  00  00  00  XX  ()  00  00  00
5  00  00  00  ()  XX   1  00  00
6  00  00  00  00  03  02  00  00
7  00  00  00  00  00  00  00  00
8  00  00  00  00  00  00  00  00


 54 53 27 34 29 25 44 43
 50 52 26 33 24 28 36 30
 46 23 18 09 07 08 11 42
 47 45 35 00 00 04 14 15Å@N Murakami
 48 37 16 00 00 01 05 20Å@B Goto Hiroshi
 55 38 12 13 03 02 17 10
 51 56 49 31 06 19 60 21
 57 58 39 40 32 22 41 59

   A   B   C   D   E   F   G   H
1  0  000  00000  000  00  0  0  0  1
2  00  00  00  00  00  00000000  00  00  2
3  0000  00  00  00  00  00  00  00  3
4  00  00  00          00  00  00  4
5  00  00  00           1  00  00  5
6  00  00  00  00  03  2  00  00  6
7  00  00  00  00  00  00  00  00  7
8  00  00  0000  00  00  00  00  00  8
   A   B   C   D   E   F   G   H


// transcript ne marchant pas dans Cassio 7.5,
// à cause des scores apres les noms des joueurs :-(

58 57 20 47 24 32 37 46
39 49 09 11 30 27 33 43
14 08 03 04 10 16 19 35
23 13 05 00 00 06 15 36 Hiroshi Goto 16
44 21 07 00 00 01 26 34 Yusuke Takanashi 48
45 29 12 02 17 22 28 31
60 55 54 50 25 18 38 48
56 59 53 40 41 42 52 51

// transcripts ne marchant pas dans Cassio 7.5,
// parce qu'ils sont codés en Unicode (UTF8 ?)

45 18 15 14 17 16 47 48
31 44 19 ÇV ÇX ÇW 41 49
30 20 ÇQ ÇR ÇS 10 40 51
29 21 ÇP ? ? ÇT 13 50Å@Åú ãÓå` 41
22 24 12 ? ? 35 34 37Å@Åõ ë∫è„ 23
27 23 25 ÇU 11 33 36 39
53 46 26 28 38 32 42 52
56 58 60 57 59 54 55 43

45 30 22 46 15 17 21 50
47 28 25 14 10 16 53 52
27 24 13 12 ÇT 11 23 41
36 31 ÇV ? ? ÇS 35 38Å@Åú êŒêÏ 38
59 19 ÇU ? ? ÇP 42 43Å@Åõ ë∫è„ 26
26 18 ÇX 20 ÇR ÇQ 39 51
58 48 32 ÇW 33 49 54 44
57 37 34 29 60 40 56 55


*)


END.





















