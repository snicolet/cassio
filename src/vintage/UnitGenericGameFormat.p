UNIT UnitGenericGameFormat;



INTERFACE







 USES UnitDefCassio;



{ Initialisation de l'unité }

procedure InitUnitGenericGameFormat;


{ Utilitaires sur les fichiers NxN }

function GetPreviousCharFichier_NxN(negOffset : SInt16) : char;
function GetNextCharFichier_NxN(var c : char) : OSErr;
procedure ResetLecture_NxN;
procedure BeginLecture_NxN;
procedure EndLecture_NxN;


{ Fonctions pour parser un fichier NxN }

procedure BeginParserPartieNxN;
procedure EndParserPartieNxN;
function StringSGFEnCoup(const s : String255; var square_x,square_y : SInt16) : boolean;

function ParserChainePositionInitialeNxN(var posInitiale : BigOthelloRec) : String255;
function ParserChaineCoupsPourDiagrammeNxN : String255;
procedure ParserPourTrouverTournoiEtJoueursNxN;


{ Les fonctions suivantes doivent etre appelees apres avoir parser le fichier NxN avec les parsers precedents}

function GetChainePositionCouranteNxN(const chainePositionInitiale : String255) : String255;
function GetChaineCoupsEnAlphaNxN : String255;
function GetNomDesNoirsNxN : String255;
function GetNomDesBlancsNxN : String255;
function GetNomTournoiNxN : String255;


{ Gestion du presse-papier pour les diagrammes 10x10 }

procedure CopierEnMacDraw10x10(N : SInt32; const chainePositionInitiale,chainePosition,chaineCoups : String255);
procedure DoDiagramme10x10;


{ Des utilitaires qui utilisent le parser des diagrammes GGF 10x10 pour comprendre la ligne principale d'un fichier SGF ou GGF 8x8}

function ReadEnregistrementDansFichierSGF_ou_GGF_8x8(var fic : FichierTEXT; whichFormat : formats_connus; var infos : PartieFormatGGFRec) : OSErr;
function ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(var theFile : FichierAbstrait; whichFormat : formats_connus; var result : PartieFormatGGFRec) : OSErr;
function GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(var fic : FichierTEXT; whichFormat : formats_connus; var posInitiale : PositionEtTraitRec; var coups : String255) : OSErr;



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , MyStrings, UnitDiagramFforum, UnitNewGeneral, UnitOthelloGeneralise, UnitFichiersTEXT, UnitCarbonisation, UnitRapportWindow
    , UnitRapportImplementation, UnitRapport, UnitDialog, UnitServicesDialogs, MyFileSystemUtils, UnitFenetres, UnitFormatsFichiers, UnitFichierAbstrait
    , UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/GenericGameFormat.lk}
{$ENDC}


{END_USE_CLAUSE}











const kTailleBufferCaracteresLocal_NxN = 40;

var gLecture_NxN :
      record
        formatFichier                        : FormatFichierRec;
        typeDiagramme                        : SInt16;
        numeroDuCoupPourLeDiagramme          : SInt16;
        lectureEnCours                       : boolean;
        ecrireEnClairInfosDansRapport        : boolean;
        fichierAbstraitLecture                   : FichierAbstrait;
        marqueurAuDebutDeLaLectureDeLaPartie : SInt32;
        bufferCaracteres                     : array[-kTailleBufferCaracteresLocal_NxN..0] of char;
        position_NxN                         : BigOthelloRec;
        chaineCoupsEnAlpha                   : String255;
        chainePositionDiagramme              : String255;
        nomDesNoirs                          : String255;
        nomDesBlancs                         : String255;
        nomTournoi                           : String255;
      end;


procedure InitUnitGenericGameFormat;
begin
  gLecture_NxN.lectureEnCours := false;
  gLecture_NxN.ecrireEnClairInfosDansRapport := false;
end;


procedure VideBufferCaracteres;
var i : SInt16;
begin
  for i := -kTailleBufferCaracteresLocal_NxN to 0 do
    gLecture_NxN.bufferCaracteres[i] := chr(0);
end;


procedure ResetLecture_NxN;
var err : OSErr;
begin
  err := SetPositionMarqueurFichierAbstrait(gLecture_NxN.fichierAbstraitLecture,gLecture_NxN.marqueurAuDebutDeLaLectureDeLaPartie);
  VideBufferCaracteres;
end;


procedure BeginParserPartieNxN;
begin
  with gLecture_NxN do
    begin
      chaineCoupsEnAlpha := '';
      nomDesNoirs := '';
      nomDesBlancs := '';
      nomTournoi := '';

      marqueurAuDebutDeLaLectureDeLaPartie := GetPositionMarqueurFichierAbstrait(fichierAbstraitLecture);
      {WritelnNumDansRapport('Dans BeginParserPartieNxN, marqueurAuDebutDeLaLectureDeLaPartie = ',marqueurAuDebutDeLaLectureDeLaPartie);}
      ResetLecture_NxN;
     end;
end;


procedure EndParserPartieNxN;
begin
  VideBufferCaracteres;

  {WritelnNumDansRapport('Dans EndParserPartieNxN, marqueur = ',GetPositionMarqueurFichierAbstrait(gLecture_NxN.fichierAbstraitLecture));}
end;


function AvanceDansFichier_NxN(sauterLesCaracteresDeControle : boolean) : OSErr;
var err : OSErr;
    c : char;
    i,codeAsciiCaractere : SInt16;
    estUnCaractereDeControle : boolean;
begin
  err := GetNextCharOfFichierAbstrait(gLecture_NxN.fichierAbstraitLecture,c);
  while (err = NoErr) do
    begin

      codeAsciiCaractere := ord(c);
      estUnCaractereDeControle := (c = ' ') |
                                  (codeAsciiCaractere <= 32);

      if not(estUnCaractereDeControle) |
         not(sauterLesCaracteresDeControle) then
         begin
		       for i := -kTailleBufferCaracteresLocal_NxN to -1 do
		         gLecture_NxN.bufferCaracteres[i] := gLecture_NxN.bufferCaracteres[i+1];
		       gLecture_NxN.bufferCaracteres[0] := c;

		       AvanceDansFichier_NxN := NoErr;
		       exit(AvanceDansFichier_NxN);
		     end;

		  err := GetNextCharOfFichierAbstrait(gLecture_NxN.fichierAbstraitLecture,c);
    end;
  AvanceDansFichier_NxN := err;
end;


function GetPreviousCharFichier_NxN(negOffset : SInt16) : char;
begin
  if (negOffset >= -kTailleBufferCaracteresLocal_NxN) & (negOffset <= 0)
    then GetPreviousCharFichier_NxN := gLecture_NxN.bufferCaracteres[negOffset]
    else GetPreviousCharFichier_NxN := chr(0);
end;


function GetNextCharFichier_NxN(var c : char) : OSErr;
var err : OSErr;
begin
  err := AvanceDansFichier_NxN(true);
  if err = NoErr then c := GetPreviousCharFichier_NxN(0);
  GetNextCharFichier_NxN := err;
end;


function UtilisateurChoisitFichier_NxN(var N : SInt32; var theFic : FichierTEXT) : OSErr;
var reply : SFReply;
    ok : boolean;
    nomComplet : String255;
    positionArobase : SInt16;
    s,s10,s9 : String255;
    mySpec : FSSpec;
begin

  UtilisateurChoisitFichier_NxN := -1;

  with gLecture_NxN do
    if not(gLecture_NxN.lectureEnCours) then
    begin

      BeginDialog;
		  ok := GetFileName('',reply,MY_FOUR_CHAR_CODE('TEXT'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),MY_FOUR_CHAR_CODE('????'),mySpec);
		  EndDialog;

		  if ok then
		    begin

		      s9  := NumEnString(9) + 'x' + NumEnString(9);   {'9x9'}
		      s10 := NumEnString(10) + 'x' + NumEnString(10); {'10x10'}

		      if (Pos(s9,GetNameOfSFReply(reply)) <= 0) &
		         (Pos(s10,GetNameOfSFReply(reply)) <= 0)
		        then
		          begin
		            AlerteSimple('Le nom du fichier doit contenir « '+s9+' » ou « '+s10+' »');
		          end
		        else
				      begin

				        if (Pos(s9,GetNameOfSFReply(reply)) > 0)  then N := 9 else
				        if (Pos(s10,GetNameOfSFReply(reply)) > 0) then N := 10;

				        nomComplet := GetFullPathOfFSSpec(mySpec);

                positionArobase := Pos('@',GetNameOfSFReply(reply));
                if (positionArobase <= 0)
                  then numeroDuCoupPourLeDiagramme := 10000
                  else
                    begin
                      s := TPCopy(GetNameOfSFReply(reply),positionArobase+1,10);
                      numeroDuCoupPourLeDiagramme := ChaineEnInteger(s);
                      if numeroDuCoupPourLeDiagramme < 0 then numeroDuCoupPourLeDiagramme := 0;
                    end;

                if (positionArobase > 0)
			            then typeDiagramme := DiagrammePosition
		              else typeDiagramme := DiagrammePartie;

				        UtilisateurChoisitFichier_NxN := FichierTexteExisteFSp(mySpec,theFic);
				      end;
		    end;
   end;
end;


procedure BeginLecture_NxN;
begin
end;


procedure EndLecture_NxN;
begin

  if gLecture_NxN.lectureEnCours then
    begin
      VideBufferCaracteres;
      gLecture_NxN.lectureEnCours := false;
    end;
end;


{ Attention : ne marche que pour les tailles <= 10x10, à cause du parser des chiffres}
function StringSGFEnCoup(const s : String255; var square_x,square_y : SInt16) : boolean;
var c1,c2,c3 : char;
    x,y,longueur,k : SInt16;
    trouve : boolean;
    chaine : String255;
begin
  StringSGFEnCoup := false;
  square_x := 0;
  square_y := 0;

  longueur := LENGTH_OF_STRING(s);
  if longueur >= 2 then
    begin
      k := 0;
      trouve := false;
      repeat
        inc(k);
        c1 := s[k];
        c2 := s[k+1];
        if k <= (longueur-2)
          then c3 := s[k+2]
          else c3 := chr(0);

        {'tt' = passe' dans SGF}
        if (c1 = 't') & (c2 = 't') then exit(StringSGFEnCoup);
        if (c1 = 'p') & (c2 = 'a') then exit(StringSGFEnCoup);
        if (c1 = 'P') & (c2 = 'A') then exit(StringSGFEnCoup);

        x := 0;
        y := 0;

        if CharInRange(c1,'a','j') & CharInRange(c2,'a','j') then
          begin
            x := ord(c1) - ord('a') + 1;
            y := ord(c2) - ord('a') + 1;
          end;

        if CharInRange(c1,'A','J') & CharInRange(c2,'A','J') then
          begin
            x := ord(c1) - ord('A') + 1;
            y := ord(c2) - ord('A') + 1;
          end;

        if CharInRange(c1,'A','J') & IsDigit(c2) & IsDigit(c3) then
          begin
            x := ord(c1) - ord('A') + 1;
            chaine := Concat(c2,c3);
            y := ChaineEnInteger(chaine);
          end;

        if CharInRange(c1,'a','j') & IsDigit(c2) & IsDigit(c3) then
          begin
            x := ord(c1) - ord('a') + 1;
            chaine := Concat(c2,c3);
            y := ChaineEnInteger(chaine);
          end;

        if CharInRange(c1,'A','J') & IsDigit(c2) & not(IsDigit(c3)) then
          begin
            x := ord(c1) - ord('A') + 1;
            chaine := c2;
            y := ChaineEnInteger(chaine);
          end;

        if CharInRange(c1,'a','j') & IsDigit(c2) & not(IsDigit(c3)) then
          begin
            x := ord(c1) - ord('a') + 1;
            chaine := c2;
            y := ChaineEnInteger(chaine);
          end;

        { WritelnNumDansRapport('x = '+NumEnString(x) + '  y = ',y); }

        if (x >= 1) & (x <= 10) & (y >= 1) & (y <= 10) then
          begin
            trouve := true;
            square_x := x;
            square_y := y;
            StringSGFEnCoup := true;
            exit(StringSGFEnCoup);
          end;

      until trouve | (k >= (longueur-1)) ;
    end;

end;



function ScanChaineValeurProperty_NxN : String255;
var s : String255;
    c : char;
    err : OSErr;
    longueur : SInt16;
begin
  err := NoErr;

  c := GetPreviousCharFichier_NxN(0);
  if c <> '[' then err := GetNextCharFichier_NxN(c);

  if (c <> '[') | (err <> NoErr) then
    begin
      ScanChaineValeurProperty_NxN := '';
      exit(ScanChaineValeurProperty_NxN);
    end;

  s := '';
  longueur := 0;
  repeat
    inc(longueur);
    err := GetNextCharFichier_NxN(c);
    if (err = NoErr) & (c <> ']')
      then s := s + c;
  until (err <> NoErr) | (longueur > 240) | (c = ']');
  ScanChaineValeurProperty_NxN := s;

end;



procedure SauterSousArbreNxN;
var c : char;
    err : OSErr;
begin
  err := NoErr;

  c := GetPreviousCharFichier_NxN(0);
  if c <> '(' then err := GetNextCharFichier_NxN(c);

  if (c <> '(') | (err <> NoErr) then
    begin
      exit(SauterSousArbreNxN);
    end;

  repeat
    err := GetNextCharFichier_NxN(c);
  until (err <> NoErr) |
        ((c = ')') & (GetPreviousCharFichier_NxN(-1) <> '\'));

end;


function PropertyCoupNoirReconnue(negOffset : SInt16) : boolean;
begin
  PropertyCoupNoirReconnue  :=
                 ((GetPreviousCharFichier_NxN(negOffset-2) = ';') | (GetPreviousCharFichier_NxN(negOffset-2) = ']') | (GetPreviousCharFichier_NxN(negOffset-2) = ' ')) &
			           ((GetPreviousCharFichier_NxN(negOffset-1) = 'B') | (GetPreviousCharFichier_NxN(negOffset-1) = 'b')) &
			            (GetPreviousCharFichier_NxN(negOffset) = '[');
end;


function PropertyCoupBlancReconnue(negOffset : SInt16) : boolean;
begin
  PropertyCoupBlancReconnue  :=
                 ((GetPreviousCharFichier_NxN(negOffset-2) = ';') | (GetPreviousCharFichier_NxN(negOffset-2) = ']') | (GetPreviousCharFichier_NxN(negOffset-2) = ' ')) &
			           ((GetPreviousCharFichier_NxN(negOffset-1) = 'W') | (GetPreviousCharFichier_NxN(negOffset-1) = 'w')) &
			            (GetPreviousCharFichier_NxN(negOffset) = '[');
end;


{FIXME : pour l'instant, ParserChainePositionInitialeNxN ne marche pour les fichiers GGF
         que si on connait déja la taille de l'othellier à chercher}
function ParserChainePositionInitialeNxN(var posInitiale : BigOthelloRec) : String255;
var chaineBlancs,chaineNoirs,s,s1 : String255;
    c : char;
    err : OSErr;
    square_x,square_y,i,j,N : SInt16;
begin
  ParserChainePositionInitialeNxN := '';
  posInitiale := PositionVideBigOthello(1,1);

  with gLecture_NxN do
    begin

      N := formatFichier.tailleOthellier;
      {WritelnNumDansRapport('N = ',N);}

      position_NxN := PositionVideBigOthello(N,N);

		  case formatFichier.format of
		    kTypeFichierSGF :
		      begin

		        {on cherche les pions blancs}
		        ResetLecture_NxN;
		        chaineBlancs := '';
		        repeat
		          err := GetNextCharFichier_NxN(c);
		        until (err <> NoErr) |
		              ((GetPreviousCharFichier_NxN(-2) = 'A') &
		               (GetPreviousCharFichier_NxN(-1) = 'W') &
		               (GetPreviousCharFichier_NxN(0) = '['));

		        repeat
		          chaineBlancs := ScanChaineValeurProperty_NxN;
		          if StringSGFEnCoup(chaineBlancs,square_x,square_y) then
		            position_NxN.plateau[square_x, square_y] := pionBlanc;
		        until (chaineBlancs = '');

		        {on cherche les pions noirs}
		        ResetLecture_NxN;
		        chaineNoirs := '';
		        repeat
		          err := GetNextCharFichier_NxN(c);
		        until (err <> NoErr) |
		              ((GetPreviousCharFichier_NxN(-2) = 'A') &
		               (GetPreviousCharFichier_NxN(-1) = 'B') &
		               (GetPreviousCharFichier_NxN(0) = '['));

		        repeat
		          chaineNoirs := ScanChaineValeurProperty_NxN;
		          if StringSGFEnCoup(chaineNoirs,square_x,square_y) then
		            position_NxN.plateau[square_x, square_y] := pionNoir;
		        until (chaineNoirs = '');

		        {desespoir : si le fichier SGF ne precise pas la position de départ (c'est une erreur!),
		                     on suppose qu'il s'agit de la position standard... }
		        if BigOthelloEstVide(position_NxN) then
		          position_NxN := PositionInitialeBigOthello(N,N);

		        {on determine le trait en cherchant une indication
		         de trait initiale, ou la premiere couleur qui joue}
		        ResetLecture_NxN;
		        repeat
		          err := GetNextCharFichier_NxN(c);
		        until (err <> NoErr) |
		              ((GetPreviousCharFichier_NxN(-2) = 'P') &
		               (GetPreviousCharFichier_NxN(-1) = 'L') &
		               (GetPreviousCharFichier_NxN(0) = '[')) |
		              PropertyCoupBlancReconnue(0) |
		              PropertyCoupNoirReconnue(0);

		        if (GetPreviousCharFichier_NxN(-2) = 'P') &
		           (GetPreviousCharFichier_NxN(-1) = 'L') &
		           (GetPreviousCharFichier_NxN(0) = '[') then
		           begin
		             s := ScanChaineValeurProperty_NxN;
		             if s = 'W' then position_NxN.trait := pionBlanc;
		             if s = 'B' then position_NxN.trait := pionNoir;
		           end;

		        if PropertyCoupBlancReconnue(0)
		           then position_NxN.trait := pionBlanc;

		        if PropertyCoupNoirReconnue(0)
		           then position_NxN.trait := pionNoir;

		        {si on n'a pas d'indication, par defaut on essaie de donner le trait a Noir}
		        if (position_NxN.trait = pionVide) then
		          begin
		            position_NxN.trait := pionNoir;
							  if DoitPasserBigOthello(position_NxN) then
							    begin
							      position_NxN.trait := -position_NxN.trait;
							      if DoitPasserBigOthello(position_NxN) then
							        position_NxN.trait := pionVide;
							    end;
							end;
		        if ecrireEnClairInfosDansRapport then
		          begin
		            WritelnDansRapport('position initiale :');
		            WritelnBigOthelloDansRapport(position_NxN);
		          end;
		      end;
		    kTypeFichierGGF :
		      begin

		        repeat
		          err := GetNextCharFichier_NxN(c);
		        until (err <> NoErr) |
		              ((GetPreviousCharFichier_NxN(-2) = 'B') &
		               (GetPreviousCharFichier_NxN(-1) = 'O') &
		               (GetPreviousCharFichier_NxN(0) = '['));

		        if (GetPreviousCharFichier_NxN(-2) = 'B') &
			         (GetPreviousCharFichier_NxN(-1) = 'O') &
			         (GetPreviousCharFichier_NxN(0) = '[') then
			          begin
			            s := ScanChaineValeurProperty_NxN;
			            {WritelnDansRapport('s = '+s);
			            WritelnNumDansRapport('longueur = ',LENGTH_OF_STRING(s));}
			            s1 := NumEnString(N);   { "10" }
			            if (TPCopy(s,1,LENGTH_OF_STRING(s1)) = s1) then
			              begin
			                s := TPCopy(s, LENGTH_OF_STRING(s1) + 1 , N*N + 1);
			                s := EnleveEspacesDeGauche(s);
			                {WritelnDansRapport('s = '+s);
			                WritelnNumDansRapport('longueur = ',LENGTH_OF_STRING(s));}
			                if (LENGTH_OF_STRING(s) = (N*N + 1)) then
			                  begin
			                    for i := 1 to N do
			                    for j := 1 to N do
				                    begin
				                      c := s[(j-1)*N + i];
				                      case c of
				                        '-','.'             : position_NxN.plateau[i,j] := pionVide;
				                        '*','x','X','#','•' : position_NxN.plateau[i,j] := pionNoir;
				                        'O','o','0'         : position_NxN.plateau[i,j] := pionBlanc;
				                      end;
				                    end;
				                  case s[N*N + 1] of
				                    '-','.'             : position_NxN.trait := pionVide;
				                    '*','x','X','#','•' : position_NxN.trait := pionNoir;
				                    'O','o','0'         : position_NxN.trait := pionBlanc;
				                  end;
			                  end;
			              end;
		            end;

		        {desespoir : si le fichier GGF ne precise pas la position de départ (c'est une erreur!),
		                     on suppose qu'il s'agit de la position standard... }
		        if BigOthelloEstVide(position_NxN) then
		          position_NxN := PositionInitialeBigOthello(N,N);


		        if ecrireEnClairInfosDansRapport then
		          begin
		            WritelnDansRapport('position initiale :');
		            WritelnBigOthelloDansRapport(position_NxN);
		          end;
		      end;
		    otherwise
		      begin
		        WritelnDansRapport('ERROR : type de fichier inconnu dans ParserChainePositionInitialeNxN');
		      end;
		  end; {case formatFichier.format of}

		  {on transforme le plateau en chaine de caracteres}
	    //WritelnDansRapport('pos initiale = '+BigOthelloEnChaine(position_NxN));
	    ParserChainePositionInitialeNxN := BigOthelloEnChaine(position_NxN);
	    posInitiale := position_NxN;
    end;
end;


procedure ParserPourTrouverTournoiEtJoueursNxN;
var compteurCaracteres : SInt32;
    c : char;
    err : OSErr;
begin

  with gLecture_NxN do
    begin

      nomDesNoirs  := '';
      nomDesBlancs := '';
      nomTournoi   := '';


		  case formatFichier.format of
		    kTypeFichierSGF, kTypeFichierGGF:
		      begin
		        {on cherche les nomds des joueurs et, eventuellement, le tournoi}

		        compteurCaracteres := 0;
		        ResetLecture_NxN;
		        repeat
		          err := GetNextCharFichier_NxN(c);
		          inc(compteurCaracteres);

		          if (GetPreviousCharFichier_NxN(-2) = 'P') &
                 (GetPreviousCharFichier_NxN(-1) = 'B') &
                 (GetPreviousCharFichier_NxN(0) = '[')
                then nomDesNoirs := ScanChaineValeurProperty_NxN;

              if (GetPreviousCharFichier_NxN(-2) = 'P') &
                 (GetPreviousCharFichier_NxN(-1) = 'W') &
                 (GetPreviousCharFichier_NxN(0) = '[')
                then nomDesBlancs := ScanChaineValeurProperty_NxN;

              if (GetPreviousCharFichier_NxN(-2) = 'E') &
                 (GetPreviousCharFichier_NxN(-1) = 'V') &
                 (GetPreviousCharFichier_NxN(0) = '[')
                then nomTournoi := ScanChaineValeurProperty_NxN;

              if (nomTournoi = '') &
                 (GetPreviousCharFichier_NxN(-2) = 'P') &
                 (GetPreviousCharFichier_NxN(-1) = 'C') &
                 (GetPreviousCharFichier_NxN(0) = '[')
                then nomTournoi := ScanChaineValeurProperty_NxN;

		        until (err <> NoErr) | (compteurCaracteres > 2000) |
		              ((nomDesNoirs <> '') & (nomDesBlancs <> '') & (nomTournoi <> '')) |
		              PropertyCoupBlancReconnue(0) |
		              PropertyCoupNoirReconnue(0) |
		              ((GetPreviousCharFichier_NxN(-1) = ';') & (GetPreviousCharFichier_NxN(0) = ')'));

		        if ecrireEnClairInfosDansRapport then
		          begin
		            WritelnDansRapport('nomDesNoirs = '+nomDesNoirs);
		            WritelnDansRapport('nomDesBlancs = '+nomDesBlancs);
		            WritelnDansRapport('nomTournoi = '+nomTournoi);
		          end;
		      end;
		    otherwise
		      begin
		        WritelnDansRapport('ERROR : type de fichier inconnu dans ParserPourTrouverTournoiEtJoueursNxN');
		      end;
		  end; {case formatFichier.format of}

    end;
end;


function ParserChaineCoupsPourDiagrammeNxN : String255;
var s : String255;
    c,caractereProchaineCouleur : char;
    chaineCoupsPourDiagramme : String255;
    i,x,y,nbNoirs,nbBlancs,N : SInt16;
    square_x,square_y : SInt16;
    numeroDuCoupCourant : SInt16;
    auMoinsUnCoupIllegalAnnonce : boolean;
    numeroDuCoupDiagrammeDejaAtteint : boolean;
    err : OSErr;
begin
  ParserChaineCoupsPourDiagrammeNxN := '';

  with gLecture_NxN do
    begin

      N := formatFichier.tailleOthellier;
      {WritelnNumDansRapport('N = ',N);}

      nbNoirs := NbPionsDeCetteCouleurCeBigOthello(pionNoir,position_NxN);
      nbBlancs := NbPionsDeCetteCouleurCeBigOthello(pionBlanc,position_NxN);
      numeroDuCoupCourant := nbBlancs+nbNoirs - 4;
      auMoinsUnCoupIllegalAnnonce := false;


      chaineCoupsPourDiagramme := '';
		  for i := 1 to (nbNoirs+nbBlancs-4) do
		    chaineCoupsPourDiagramme := chaineCoupsPourDiagramme + ' ' + chr(0);
		  chaineCoupsEnAlpha := '';

		  {
		  WritelnNumDansRapport('numeroDuCoupPourLeDiagramme = ',numeroDuCoupPourLeDiagramme);
		  WritelnNumDansRapport('numeroDuCoupCourant = ',numeroDuCoupCourant);
		  WritelnNumDansRapport('formatFichier.format = ',SInt32(formatFichier.format));
		  }

		  if numeroDuCoupCourant >= numeroDuCoupPourLeDiagramme
		    then
		      begin
		        chainePositionDiagramme := BigOthelloEnChaine(position_NxN);
		        numeroDuCoupDiagrammeDejaAtteint := true;
		      end
		    else
		      begin
		        chainePositionDiagramme := '';
		        numeroDuCoupDiagrammeDejaAtteint := false;
		      end;

      case formatFichier.format of
		    kTypeFichierSGF :
		      {if not(numeroDuCoupDiagrammeDejaAtteint) then}
		      begin

		        ResetLecture_NxN;
		        repeat
			        repeat
			          err := GetNextCharFichier_NxN(c);
			          {WriteDansRapport(CharToString(c));}
			        until (err <> NoErr) |

			              {coup blanc}
			              PropertyCoupBlancReconnue(0) |

			              {coup noir}
			              PropertyCoupNoirReconnue(0) |

			              {premiere parenthese fermante = fin de la branche principale}
			              ((numeroDuCoupCourant > 0) &
			               (GetPreviousCharFichier_NxN(-1) <> '\') &
			               (GetPreviousCharFichier_NxN(-1) = ')'));

			        case position_NxN.trait of
	              pionNoir  : caractereProchaineCouleur := 'N';
	              pionBlanc : caractereProchaineCouleur := 'B';
	              pionVide  : caractereProchaineCouleur := ' ';
	            end;

			        {a-t-on trouve un coup blanc ?}
			        if PropertyCoupBlancReconnue(0) then
			          begin
			            s := ScanChaineValeurProperty_NxN;
				          if StringSGFEnCoup(s,square_x,square_y) then
			              begin
			                x := square_x - 1;
			                y := square_y - 1;
			                chaineCoupsPourDiagramme := chaineCoupsPourDiagramme + caractereProchaineCouleur + chr(1 + y*10 + x);
			                chaineCoupsEnAlpha       := chaineCoupsEnAlpha + chr((ord('a')+x)) + NumEnString(y+1);

			                inc(numeroDuCoupCourant);

			                if not(UpdateBigOthello(position_NxN,x+1,y+1)) & not(auMoinsUnCoupIllegalAnnonce) then
			                  begin
			                    SysBeep(0);
			                    WritelnDansRapport('WARNING : le coup '+NumEnString(numeroDuCoupCourant)+' semble illégal !');
			                    auMoinsUnCoupIllegalAnnonce := true;
			                  end;

			                {WritelnBigOthelloDansRapport(position_NxN);}

			              end;
			          end;

			        {a-t-on trouve un coup noir ?}
			        if PropertyCoupNoirReconnue(0) then
			          begin
			            s := ScanChaineValeurProperty_NxN;
				          if StringSGFEnCoup(s,square_x,square_y) then
			              begin
			                x := square_x - 1;
			                y := square_y - 1;
			                chaineCoupsPourDiagramme := chaineCoupsPourDiagramme + caractereProchaineCouleur + chr(1 + y*10 + x);
			                chaineCoupsEnAlpha       := chaineCoupsEnAlpha + chr((ord('a')+x)) + NumEnString(y+1);

			                inc(numeroDuCoupCourant);

			                if not(UpdateBigOthello(position_NxN,x+1,y+1)) & not(auMoinsUnCoupIllegalAnnonce) then
			                  begin
			                    SysBeep(0);
			                    WritelnDansRapport('WARNING : le coup '+NumEnString(numeroDuCoupCourant)+' semble illégal !');
			                    auMoinsUnCoupIllegalAnnonce := true;
			                  end;

			                {WritelnBigOthelloDansRapport(position_NxN);}

			              end;
			          end;


			        if numeroDuCoupCourant = numeroDuCoupPourLeDiagramme
		            then
		              begin
		                chainePositionDiagramme := BigOthelloEnChaine(position_NxN);
		                numeroDuCoupDiagrammeDejaAtteint := true;
		              end;


			      until (err <> NoErr) | {numeroDuCoupDiagrammeDejaAtteint |}
			            ((GetPreviousCharFichier_NxN(-1) <> '\') & {premiere parenthese fermante = fin de la branche principale}
			             (GetPreviousCharFichier_NxN(-1) = ')'));

		      end;

		    kTypeFichierGGF :
		      {if not(numeroDuCoupDiagrammeDejaAtteint) then}
		      begin

		        ResetLecture_NxN;
		        repeat
			        repeat
			          err := GetNextCharFichier_NxN(c);
			        until (err <> NoErr) |

			              {coup blanc}
			              PropertyCoupBlancReconnue(0) |

			              {coup noir}
			              PropertyCoupNoirReconnue(0) |

			              {premiere parenthese fermante = fin de la branche principale}
			              ((GetPreviousCharFichier_NxN(-1) <> '\') &
			               (GetPreviousCharFichier_NxN(-1) = ')'));

			        case position_NxN.trait of
	              pionNoir  : caractereProchaineCouleur := 'N';
	              pionBlanc : caractereProchaineCouleur := 'B';
	              pionVide  : caractereProchaineCouleur := ' ';
	            end;

			        {a-t-on trouve un coup blanc ?}
			        if PropertyCoupBlancReconnue(0) then
			          begin
			            s := ScanChaineValeurProperty_NxN;
			            {WritelnDansRapport(s);}
				          if StringSGFEnCoup(s,square_x,square_y) then
			              begin
			                x := square_x - 1;
			                y := square_y - 1;
			                chaineCoupsPourDiagramme := chaineCoupsPourDiagramme + caractereProchaineCouleur + chr(1 + y*10 + x);
			                chaineCoupsEnAlpha       := chaineCoupsEnAlpha + chr((ord('a')+x)) + NumEnString(y+1);

			                inc(numeroDuCoupCourant);

			                if not(UpdateBigOthello(position_NxN,x+1,y+1)) & not(auMoinsUnCoupIllegalAnnonce) then
			                  begin
			                    SysBeep(0);
			                    WritelnDansRapport('WARNING : le coup '+NumEnString(numeroDuCoupCourant)+' semble illégal !');
			                    auMoinsUnCoupIllegalAnnonce := true;
			                  end;

			                {WritelnBigOthelloDansRapport(position_NxN);}

			              end;
			          end;

			        {a-t-on trouve un coup noir ?}
			        if PropertyCoupNoirReconnue(0) then
			          begin
			            s := ScanChaineValeurProperty_NxN;
			            {WritelnDansRapport(s);}
				          if StringSGFEnCoup(s,square_x,square_y) then
			              begin
			                x := square_x - 1;
			                y := square_y - 1;
			                chaineCoupsPourDiagramme := chaineCoupsPourDiagramme + caractereProchaineCouleur + chr(1 + y*10 + x);
			                chaineCoupsEnAlpha       := chaineCoupsEnAlpha + chr((ord('a')+x)) + NumEnString(y+1);

			                inc(numeroDuCoupCourant);

			                if not(UpdateBigOthello(position_NxN,x+1,y+1)) & not(auMoinsUnCoupIllegalAnnonce) then
			                  begin
			                    SysBeep(0);
			                    WritelnDansRapport('WARNING : le coup '+NumEnString(numeroDuCoupCourant)+' semble illégal !');
			                    auMoinsUnCoupIllegalAnnonce := true;
			                  end;

			                {WritelnBigOthelloDansRapport(position_NxN);}

			              end;
			          end;


			        if numeroDuCoupCourant = numeroDuCoupPourLeDiagramme
		            then
		              begin
		                chainePositionDiagramme := BigOthelloEnChaine(position_NxN);
		                numeroDuCoupDiagrammeDejaAtteint := true;
		              end;


			      until (err <> NoErr) | {numeroDuCoupDiagrammeDejaAtteint |}
			            ((GetPreviousCharFichier_NxN(-1) <> '\') & {premiere parenthese fermante = fin de la branche principale}
			             (GetPreviousCharFichier_NxN(-1) = ')'));

		      end;

		    otherwise
		      begin
		        WritelnDansRapport('ERROR : type de fichier inconnu dans ParserChaineCoupsPourDiagrammeNxN');
		      end;
      end;

      if ecrireEnClairInfosDansRapport then
		    begin
          WritelnDansRapport('partie = '+GetChaineCoupsEnAlphaNxN);
          WritelnDansRapport('position finale :');
		      WritelnBigOthelloDansRapport(position_NxN);
				  if position_NxN.trait = pionVide then
				    WritelnDansRapport('score final : '+
				                       NumEnString(NbPionsDeCetteCouleurCeBigOthello(pionNoir,position_NxN)) +'-'+
				                       NumEnString(NbPionsDeCetteCouleurCeBigOthello(pionBlanc,position_NxN)));
		      WritelnDansRapport('');
		      WritelnDansRapport('Pour obtenir la position apres le coup N dans le presse-papier, ajouter @N dans le nom du fichier.');
		      WritelnDansRapport('Exemple : nommez le fichier  Essai-10x10@25.sof  pour obtenir le diagramme apres le coup 25.');
		      WritelnDansRapport('');
		    end;
	    ParserChaineCoupsPourDiagrammeNxN := TPCopy(chaineCoupsPourDiagramme,1,2*numeroDuCoupPourLeDiagramme);
    end;
end;


function GetChainePositionCouranteNxN(const chainePositionInitiale : String255) : String255;
begin
  GetChainePositionCouranteNxN := '';

  if (chainePositionInitiale <> '') then
    with gLecture_NxN do
      begin
        if (chainePositionDiagramme <> '')
          then GetChainePositionCouranteNxN := chainePositionDiagramme
          else GetChainePositionCouranteNxN := BigOthelloEnChaine(position_NxN);
      end;
end;


function GetChaineCoupsEnAlphaNxN : String255;
begin
  GetChaineCoupsEnAlphaNxN := gLecture_NxN.chaineCoupsEnAlpha;
end;


function GetNomDesNoirsNxN : String255;
begin
  GetNomDesNoirsNxN := gLecture_NxN.nomDesNoirs;
end;


function GetNomDesBlancsNxN : String255;
begin
  GetNomDesBlancsNxN := gLecture_NxN.nomDesBlancs;
end;


function GetNomTournoiNxN : String255;
begin
  GetNomTournoiNxN := gLecture_NxN.nomTournoi;
end;


procedure CopierEnMacDraw10x10(N : SInt32; const chainePositionInitiale,chainePosition,chaineCoups : String255);
var oldTaille : Point;
		aux: SInt32;
	  saisie: rect;
	  OthellierPicture : PicHandle;
		oldClipRgn : RgnHandle;
		oldPen : PenState;

begin

  GetTailleOthelloPourDiagrammeFforum(oldTaille.h,oldTaille.v);
  SetTailleOthelloPourDiagrammeFForum(N,N);

  if gLecture_NxN.typeDiagramme = DiagrammePartie
    then SetParamDiag(ParamDiagPartieFFORUM)
    else SetParamDiag(ParamDiagPositionFFORUM);
  ParamDiagCourant.TypeDiagrammeFFORUM := gLecture_NxN.typeDiagramme;

	GetPenState(oldPen);
	oldClipRgn := NewRgn;
	GetClip(oldClipRgn);
	SetRect(saisie, ParamDiagCourant.decalageHorFFORUM,
	                ParamDiagCourant.decalageVertFFORUM,
	                ParamDiagCourant.decalageHorFFORUM + LargeurDiagrammeFFORUM,
	                ParamDiagCourant.decalageVertFFORUM + HauteurDiagrammeFFORUM);
	ClipRect(saisie);
	OthellierPicture := OpenPicture(saisie);


	case ParamDiagCourant.typeDiagrammeFFORUM of
		DiagrammePartie:    ConstruitDiagrammePicture(chainePositionInitiale,chaineCoups);
		DiagrammePosition:  ConstruitPositionPicture(chainePosition,chaineCoups);
	end;
	
	PrintEpilogueForEPSFile;
	
	ClosePicture;
	SetClip(oldclipRgn);
	DisposeRgn(oldclipRgn);

	aux := MyZeroScrap;
	aux := CopierPICTDansPressePapier(OthellierPicture);

	KillPicture(OthellierPicture);
	SetPenState(oldPen);

  SetTailleOthelloPourDiagrammeFForum(oldTaille.h,oldTaille.v);

end;

procedure DoDiagramme10x10;
var chainePositionInitiale : String255;
    chaineCoups : String255;
    chainePosition : String255;
    s : String255;
    oldTaille : Point;
    err : OSErr;
    posInitiale10x10 : BigOthelloRec;
    theFic : FichierTEXT;
    N : SInt32;  {taille de l'othellier (9x9, ou 10x10) }
begin

  {SetDebuggageUnitFichiersTexte(true);}

  N := -1;
  if (UtilisateurChoisitFichier_NxN(N,theFic) = NoErr) & (N >= 9) then

    begin

      if not(FenetreRapportEstOuverte) then OuvreFntrRapport(false,true) else
      if not(FenetreRapportEstAuPremierPlan) then SelectWindowSousPalette(GetRapportWindow);


      {WritelnDansRapport('OK, je suis ici dans DoDiagrammeNxN');}
      {AttendFrappeClavier;}

      with gLecture_NxN do
	      if TypeDeFichierEstConnu(theFic,formatFichier,err) &
	         ((formatFichier.format = kTypeFichierSGF) | (formatFichier.format = kTypeFichierGGF)) &
	         ((formatFichier.tailleOthellier = 9) |(formatFichier.tailleOthellier = 10)) then

	        begin

            if (formatFichier.tailleOthellier <> N) then
              begin
                WritelnDansRapport('Nom du fichier = '+GetNameOfFSSpec(theFic.theFSSpec));
                WritelnNumDansRapport('taille de l''othellier = ',formatFichier.tailleOthellier);

                AlerteSimple('L''information de taille de l''othellier à l''intérieur du fichier ne correspond pas au nom du fichier !');
                exit(DoDiagramme10x10);
              end;



	          chainePositionInitiale := '';
					  chaineCoups := '';
					  chainePosition := '';
					  ecrireEnClairInfosDansRapport := true;


	          {WritelnDansRapport('OK, format reconnu dans DoDiagrammeNxN');}
	          {AttendFrappeClavier;}

	          fichierAbstraitLecture := MakeFichierAbstraitFichier(theFic.nomFichier,0);
	          lectureEnCours := FichierAbstraitEstCorrect(fichierAbstraitLecture);

	          {
	          WritelnDansRapport('OK, fichierAbstraitLecture(fic) dans DoDiagrammeNxN');
	          AttendFrappeClavier;
	          SetDebuggageUnitFichiersTexte(false);
	          }

	          if lectureEnCours then
	            begin

	              BeginLecture_NxN;

	              {on parse le fichier}
	              BeginParserPartieNxN;

					      chainePositionInitiale := ParserChainePositionInitialeNxN(posInitiale10x10);
					      chaineCoups            := ParserChaineCoupsPourDiagrammeNxN;
					      chainePosition         := GetChainePositionCouranteNxN(chainePositionInitiale);

					      EndParserPartieNxN;

					      {WritelnDansRapport('GetChaineCoupsEnAlphaNxN = '+GetChaineCoupsEnAlphaNxN);}

					      {on appelle le dialogue de parametres des diagrammes}
					      GetTailleOthelloPourDiagrammeFforum(oldTaille.h,oldTaille.v);
					      SetTailleOthelloPourDiagrammeFForum(N,N);
					      if gLecture_NxN.typeDiagramme = DiagrammePartie
					        then SetParamDiag(ParamDiagPartieFFORUM)
					        else SetParamDiag(ParamDiagPositionFFORUM);
					      s := ReadStringFromRessource(TextesImpressionID,1);
					      if DoDiagrammeFFORUM(s,chainePositionInitiale,chainePosition,chaineCoups) then DoNothing;
					      if gLecture_NxN.typeDiagramme = DiagrammePartie
					        then GetParamDiag(ParamDiagPartieFFORUM)
					        else GetParamDiag(ParamDiagPositionFFORUM);

					      {et on fabrique le diagramme dans le presse-papier}
					      if (chainePositionInitiale <> '') then
					        CopierEnMacDraw10x10(N,chainePositionInitiale,chainePosition,chaineCoups);

					      SetTailleOthelloPourDiagrammeFForum(oldTaille.h,oldTaille.v);

					      EndLecture_NxN;
					      DisposeFichierAbstrait(gLecture_NxN.fichierAbstraitLecture);
	            end;

	        end;
	  end;

	 {
	 SetDebuggageUnitFichiersTexte(false);
   }

end;


{ le parametre whichFormat permet de selectionner entre kTypeFichierGGF et kTypeFichierSGF }
function ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(var theFile : FichierAbstrait; whichFormat : formats_connus; var result : PartieFormatGGFRec) : OSErr;
var fichierAbstraitOK : boolean;
    aux : String255;
    N : SInt32;
begin

  ReadEnregistrementDansFichierAbstraitSGF_ou_GGF := -1;

  with gLecture_NxN do
    begin

      formatFichier.tailleOthellier  := 8;            {FIXME : ReadEnregistrementDansFichierAbstraitSGF_ou_GGF ne marche que pour du 8x8}
      formatFichier.format           := whichFormat;  { kTypeFichierGGF ou kTypeFichierSGF }
      formatFichier.version          := 0;
      formatFichier.positionEtPartie := '';

      ecrireEnClairInfosDansRapport := false;


	    fichierAbstraitOK    := FichierAbstraitEstCorrect(theFile);

	    if fichierAbstraitOK then
	      begin
	        lectureEnCours     := true;

	        fichierAbstraitLecture := theFile;
	        BeginParserPartieNxN;

	        N := formatFichier.tailleOthellier;

	        result.joueurNoir       := '';
	        result.joueurBlanc      := '';
	        result.tournoi          := '';
	        result.coupsEnAlpha     := '';
	        result.positionInitiale := PositionVideBigOthello(N,N);

	        ParserPourTrouverTournoiEtJoueursNxN;
			    result.joueurNoir   := GetNomDesNoirsNxN;
			    result.joueurBlanc  := GetNomDesBlancsNxN;
			    result.tournoi      := GetNomTournoiNxN;

          aux := ParserChainePositionInitialeNxN(result.positionInitiale);
			    aux := ParserChaineCoupsPourDiagrammeNxN;
			    result.coupsEnAlpha := GetChaineCoupsEnAlphaNxN;

			    EndParserPartieNxN;
			    theFile := FichierAbstraitLecture;

	        ReadEnregistrementDansFichierAbstraitSGF_ou_GGF := NoErr;
	      end;

    end;
end;


{Le fichier "fic" doit exister, contenir une partie 8x8 au format SGF ou au format GGF;
 il doit etre fermé, et est rendu fermé }
function GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8(var fic : FichierTEXT; whichFormat : formats_connus; var posInitiale : PositionEtTraitRec; var coups : String255) : OSErr;
var myError : OSErr;
    myZone : FichierAbstrait;
    theGame : PartieFormatGGFRec;
begin
  myError := -1;

  if not(FichierTexteEstOuvert(fic)) then
	  if not(gLecture_NxN.lectureEnCours) then
	    with gLecture_NxN do
	      begin

          myZone         := MakeFichierAbstraitFichier(fic.nomFichier,0);
	        lectureEnCours := FichierAbstraitEstCorrect(myZone);

	        if lectureEnCours then
	          begin
	            BeginLecture_NxN;
	            myError := ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(myZone,whichFormat,theGame);

	            posInitiale := BigOthelloEnPositionEtTrait(theGame.positionInitiale);
	            coups       := theGame.coupsEnAlpha;

	            EndLecture_NxN;
	            DisposeFichierAbstrait(myZone);
	          end;

	      end;

	GetPositionInitialeEtPartieDansFichierSGF_ou_GGF_8x8 := myError;
end;


{Le fichier "fic" doit exister, contenir une partie 8x8 au format SGF ou au format GGF;
 il doit etre fermé, et est rendu fermé }
function ReadEnregistrementDansFichierSGF_ou_GGF_8x8(var fic : FichierTEXT; whichFormat : formats_connus; var infos : PartieFormatGGFRec) : OSErr;
var myError : OSErr;
    myZone : FichierAbstrait;
begin
  myError := -1;

  if not(FichierTexteEstOuvert(fic)) then
	  if not(gLecture_NxN.lectureEnCours) then
	    with gLecture_NxN do
	      begin

          myZone         := MakeFichierAbstraitFichier(fic.nomFichier,0);
	        lectureEnCours := FichierAbstraitEstCorrect(myZone);

	        if lectureEnCours then
	          begin
	            BeginLecture_NxN;
	            myError := ReadEnregistrementDansFichierAbstraitSGF_ou_GGF(myZone,whichFormat,infos);

	            EndLecture_NxN;
	            DisposeFichierAbstrait(myZone);
	          end;

	      end;

	ReadEnregistrementDansFichierSGF_ou_GGF_8x8 := myError;
end;



END.
