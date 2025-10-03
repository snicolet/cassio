UNIT UnitPressePapier;


INTERFACE



 USES UnitDefCassio , Scrap;


function PeutCollerPartie(var positionStandard : boolean; var partieEnAlpha : String255) : boolean;                                                                                 ATTRIBUTE_NAME('PeutCollerPartie')


function DumpPressePapierToFile(var fic : FichierTEXT; flavorType : ScrapFlavorType) : OSErr;                                                                                       ATTRIBUTE_NAME('DumpPressePapierToFile')
function DumpFileToPressePapier(fileName : String255; flavorType : ScrapFlavorType) : OSErr;                                                                                        ATTRIBUTE_NAME('DumpFileToPressePapier')
function EstUnNomDeFichierTemporaireDePressePapier(const nom : String255) : boolean;                                                                                                ATTRIBUTE_NAME('EstUnNomDeFichierTemporaireDePressePapier')


procedure CopierPartieEnTEXT(enMajuscule,avecEspacesEntreCoups : boolean);                                                                                                          ATTRIBUTE_NAME('CopierPartieEnTEXT')
procedure CopierDiagrammePositionEnTEXT;                                                                                                                                            ATTRIBUTE_NAME('CopierDiagrammePositionEnTEXT')
procedure CopierDiagrammePartieEnTEXT;                                                                                                                                              ATTRIBUTE_NAME('CopierDiagrammePartieEnTEXT')
procedure CopierPositionPourEndgameScriptEnTEXT;                                                                                                                                    ATTRIBUTE_NAME('CopierPositionPourEndgameScriptEnTEXT')
procedure CopierDiagrammePositionEnHTML;                                                                                                                                            ATTRIBUTE_NAME('CopierDiagrammePositionEnHTML')
procedure GenereInfosIOSDansPressePapier(numeroDuCoup,couleur,coup : SInt32; tickPourCalculTemps : SInt32);                                                                         ATTRIBUTE_NAME('GenereInfosIOSDansPressePapier')


function LongueurPressePapier(flavor : ScrapFlavorType) : SInt32;                                                                                                                   ATTRIBUTE_NAME('LongueurPressePapier')
procedure TransfererLePressePapierGlobalDansTextEdit;                                                                                                                               ATTRIBUTE_NAME('TransfererLePressePapierGlobalDansTextEdit')


{ Extractions pour le presse-papier }
function PartiePourPressePapier(enMajuscules,avecEspaceEntreCoups : boolean; nbreCoupsAExporter : SInt16) : String255;                                                              ATTRIBUTE_NAME('PartiePourPressePapier')
function PositionInitialeEnLignePourPressePapier : String255;                                                                                                                       ATTRIBUTE_NAME('PositionInitialeEnLignePourPressePapier')
function PositionCouranteEnDiagrammeTEXTPourPressePapier : String255;                                                                                                               ATTRIBUTE_NAME('PositionCouranteEnDiagrammeTEXTPourPressePapier')
function DiagrammePartieEnTEXTPourPressePapier(avecCoordonnees : boolean; delimiteurVertical,SeparateurDeCoups : String255) : String255;                                            ATTRIBUTE_NAME('DiagrammePartieEnTEXTPourPressePapier')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils, MacMemory
{$IFC NOT(USE_PRELINK)}
    , UnitScannerUtils, UnitPositionEtTrait, UnitSetUp, UnitNormalisation, UnitRapport, UnitCarbonisation, UnitGestionDuTemps
    , UnitServicesDialogs, MyStrings, UnitServicesMemoire, MyMathUtils, UnitPhasesPartie, UnitModes, UnitFichierAbstrait, UnitRapportImplementation
    , UnitHTML, UnitCourbe, UnitScannerOthellistique, UnitRetrograde, UnitRapportUtils, UnitJeu, UnitArbreDeJeuCourant, UnitFichiersTEXT
    , UnitServicesRapport ;
{$ELSEC}
    ;
    {$I prelink/PressePapier.lk}
{$ENDC}


{END_USE_CLAUSE}












function PeutCollerPartie(var positionStandard : boolean; var partieEnAlpha : String255) : boolean;
type DeuxChar = packed array[0..1] of char;
var result : SInt32;
    hdest : handle;
    pointeurDeCaractere : ^DeuxChar;
    offset : SInt32;
    longueur,longueurMaximale : SInt32;
    i,compteur : SInt32;
    dernierCaractereRecu,c : char;
    attendUneLettre,attendUnChiffre : boolean;
    CollerPartieOK : boolean;
    partieRecue,texteBrut : String255;
    err : OSErr;
    longueurDuTexteDansLePressePapier : SInt32;
    longueur1,longueur2,longueur3,longueur4 : SInt32;

		 procedure RecoitCaractere(c : char);
		 begin
		   if IsLower(c) then c := chr(ord(c)-32);
		   if attendUneLettre
		     then
		       begin
		         if CharInRange(c,'A','H') then
		           begin
		             attendUneLettre := false;
		             attendUnChiffre := true;
		           end
		       end
		     else
		       begin
		         if CharInRange(c,'1','8') & CharInRange(dernierCaractereRecu,'A','H') then
		           begin
		             partieRecue     := partieRecue + dernierCaractereRecu + c;
		             attendUneLettre := true;
		             attendUnChiffre := false;
		           end
		       end;
		   dernierCaractereRecu := c;
		 end;


    function NombreCoupsRejouables(chaine : String255) : SInt32;
    begin
      if EstUnePartieOthelloAvecMiroir(chaine)
        then NombreCoupsRejouables := LENGTH_OF_STRING(chaine) div 2
        else NombreCoupsRejouables := 0;
    end;


		function InterpreterPartie(chaine : String255) : OSErr;
		begin
		  {WritelnDansRapport('dans interpreterPartie , chaine = '+chaine);}
		  InterpreterPartie := -1;
			if EstUnePartieOthelloAvecMiroir(chaine)
		    then
		      begin
		        InterpreterPartie := NoErr;
		        if PeutArreterAnalyseRetrograde then
		          begin
		            PlaquerPartieLegale(chaine,kNePasRejouerLesCoupsEnDirect);
		            if not(HumCtreHum) & not(CassioEstEnModeAnalyse) then DoChangeHumCtreHum;

		            positionStandard := true;
		            partieEnAlpha := chaine;
		          end;
		      end
		end;

begin
  CollerPartieOK := false;
  positionStandard := true;
  partieEnAlpha := '';
  longueurDuTexteDansLePressePapier := LongueurPressePapier(MY_FOUR_CHAR_CODE('TEXT'));

  if enRetour | enSetUp | (longueurDuTexteDansLePressePapier <= 0) then
    begin
      PeutCollerPartie := true;
      exit(PeutCollerPartie);
    end;

  if not(enRetour | enSetUp) then
    begin
      hdest := AllocateMemoryHdl(3000);
      if (hdest <> NIL)
        then
          result := MyGetScrap(hdest,MY_FOUR_CHAR_CODE('TEXT'),offset)
        else
          begin
            result := -1;
            AlerteSimple('Je ne peux pas allouer la mémoire pour lire le presse-papier');
          end;
      if (result < 0)  {data of that type doesn't exist in the scrap}
        then
          begin
            PeutCollerPartie := false;
            exit(PeutCollerPartie);
          end
        else
          begin
            attendUneLettre := true;
            attendUnChiffre := false;
            partieRecue     := '';
            texteBrut       := '';
            compteur        := 0;

            HLockHi(hdest);
            longueur := result;
            pointeurDeCaractere := MAKE_MEMORY_POINTER(POINTER_VALUE(hdest^));

            if (longueurDuTexteDansLePressePapier <= 2900) then
	            for i := 0 to longueurDuTexteDansLePressePapier do
                begin
                  c :=  pointeurDeCaractere^[i];
                  if (compteur < 255) & (CharInRange(c,'1','8') | CharInRange(c,'a','h') | CharInRange(c,'A','H')) then
                    begin
                      inc(compteur);
                      texteBrut := texteBrut + c;
                    end;
                end;

            dernierCaractereRecu := chr(0);
            for i := 1 to (longueur div 2) do
              begin
                RecoitCaractere(pointeurDeCaractere^[0]);
                RecoitCaractere(pointeurDeCaractere^[1]);
                pointeurDeCaractere := POINTER_ADD(pointeurDeCaractere , 2);
              end;
            if odd(longueur) then
              RecoitCaractere(pointeurDeCaractere^[0]);
            HUnlock(hdest);


            if (longueurDuTexteDansLePressePapier <= 0)
              then 
                CollerPartieOK := true
              else
                begin
			            err := -1;
			            
			            // WritelnDansRapport('partieRecue = '+partieRecue);
			            // WritelnDansRapport('texteBrut = '+texteBrut);

			            { On essaie maintenant de rejouer la partie. Parmi toutes les
			              possibilites, on essaie de rejouer la plus longue }
			            longueur1 := 0;
			            longueur2 := 0;
			            longueur3 := 0;
			            longueur4 := 0;

			            if (LENGTH_OF_STRING(texteBrut) >= 2)   then longueur1 := NombreCoupsRejouables(texteBrut);
	                if (LENGTH_OF_STRING(texteBrut) >= 2)   then longueur2 := NombreCoupsRejouables(PartiePourPressePapier(false,false,nbreCoup)+texteBrut);
			            if (LENGTH_OF_STRING(partieRecue) >= 2) then longueur3 := NombreCoupsRejouables(partieRecue);
			            if (LENGTH_OF_STRING(partieRecue) >= 2) then longueur4 := NombreCoupsRejouables(PartiePourPressePapier(false,false,nbreCoup)+partieRecue);

			            longueurMaximale := Max(Max(longueur1,longueur2),Max(longueur3,longueur4));

			            if (longueurMaximale >= 3) then
			              begin
    			            if (err <> 0) & (longueurMaximale = longueur1) then err := InterpreterPartie(texteBrut);
    	                if (err <> 0) & (longueurMaximale = longueur2) then err := InterpreterPartie(PartiePourPressePapier(false,false,nbreCoup)+texteBrut);
    			            if (err <> 0) & (longueurMaximale = longueur3) then err := InterpreterPartie(partieRecue);
    			            if (err <> 0) & (longueurMaximale = longueur4) then err := InterpreterPartie(PartiePourPressePapier(false,false,nbreCoup)+partieRecue);
			              end;
			            
			            // WritelnNumDansRapport('err = ',err);

			            CollerPartieOK := (err = 0) & (longueurMaximale >= 3);
			            
			            // WritelnStringAndBoolDansRapport('CollerPartieOK = ',CollerPartieOK);
			            
			          end;

          end;
      if (hdest <> NIL) then DisposeMemoryHdl(hdest);
    end;
   PeutCollerPartie := CollerPartieOK;
end;





function DumpPressePapierToFile(var fic : FichierTEXT; flavorType : ScrapFlavorType) : OSErr;
var longRand,taille,nouvelleTaille : SInt32;
    offset,count : SInt32;
    myError : OSErr;
    name : String255;
    hdest : handle;
    dataPtr : Ptr;
    state : SInt8;
    (* flavorsCount : UInt32;
    flavors : String255; *)
begin
  myError := -1;

  (*
  myError := GetScrapFlavors(flavorsCount, flavors);
  
  WritelnNumDansRapport('flavorsCount = ',flavorsCount);
  WritelnDansRapport('flavors = '+flavors);
  *)

  taille := LongueurPressePapier(flavorType);
  if (taille > 0) then
    begin
    
      (* WritelnDansRapport('Dans le corps de DumpPressePapierToFile'); *)

      {fabriquer un nom de fichier nouveau}
      RandomizeTimer;
      longRand := RandomLongint;
      name := 'clipboard_'+NumEnString(Abs(longRand));

      {decharger le presse papier sur le disque}
      if (UnloadScrap = NoErr) then DoNothing;

      {allouer un petit handle, qui sera agrandi si necessaire}
      hdest := AllocateMemoryHdl(100);

      nouvelleTaille := -1;
      if (hdest <> NIL)
        then nouvelleTaille := MyGetScrap(hdest,flavorType,offset);


      if (nouvelleTaille < 0)
        then
          begin  {echec !}
            myError := nouvelleTaille;
          end
        else
          begin  {ok, nouvelleTaille est la taille des donnees de type flavorType dans le presse-papier}
            state := HGetState(hdest);
            HLock(hdest);
            dataPtr := MAKE_MEMORY_POINTER(POINTER_VALUE(@hdest^^));

            count := nouvelleTaille;

            myError := CreeFichierTexteDeCassio(name,fic);
            if (myError = NoErr) then myError := OuvreFichierTexte(fic);
            if (myError = NoErr) then myError := WriteBufferDansFichierTexte(fic,dataPtr,count);
            if (myError = NoErr) then myError := FermeFichierTexte(fic);

            HSetState(hdest,state);
          end;

      if (hdest <> NIL) then DisposeMemoryHdl(hdest);
    end;

  DumpPressePapierToFile := myError;
end;


{ Transfere le contenu du fichier 'filename' dans le presse-papier global.
  Le fichier doit etre initialement fermé, et est rendu fermé }
function DumpFileToPressePapier(fileName : String255; flavorType : ScrapFlavorType) : OSErr;
var taille : SInt32;
    myError : OSErr;
    dataPtr : Ptr;
    fic : FichierTEXT;
    t, boucle : SInt32;
begin

  if (filename = '') then 
     begin
       DumpFileToPressePapier := -1;
       exit(DumpFileToPressePapier);
     end;

  {WritelnDansRapport('Entree dans DumpFileToPressePapier');
  WritelnDansRapport('Le fichier a mettre dans le presse-papier est ' + filename);}

  myError := FichierTexteDeCassioExiste(fileName, fic);
  
  boucle := 0;
  if (myError = -43) then {fnfErr => file not found}
    begin   // on essaye d'attendre 2 secondes que le fichier arrive :-)
      t := TickCount;
      repeat
        Wait(0.1);
        myError := FichierTexteDeCassioExiste(fileName, fic);
        inc(boucle);
      until (myError <> -43) | ((TickCount - t) > 120);
    end;
  
  { WritelnNumDansRapport('dans DumpFileToPressePapier, apres FichierTexteDeCassioExiste , myError = ',myError);
    WritelnNumDansRapport('dans DumpFileToPressePapier, apres FichierTexteDeCassioExiste , boucle = ',boucle); }
  
  if (myError = NoErr) then myError := OuvreFichierTexte(fic);
  if (myError = NoErr) then myError := GetTailleFichierTexte(fic,taille);
  if (myError = NoErr) & (taille > 0) then
    begin
      dataPtr := AllocateMemoryPtr(taille + 100);
      if (dataPtr <> NIL) then
        begin
          myError := ReadBufferDansFichierTexte(fic, dataPtr, taille);
          if (myError = NoErr) then myError := MyPutScrap(taille, flavorType, dataPtr);
          DisposeMemoryPtr(dataPtr);
        end;
    end;
  
  if (myError = NoErr) then myError := FermeFichierTexte(fic);
  
  DumpFileToPressePapier := myError;
end;


function EstUnNomDeFichierTemporaireDePressePapier(const nom : String255) : boolean;
begin
  EstUnNomDeFichierTemporaireDePressePapier := (Pos('clipboard_',nom) > 0);
end;


procedure CopierPartieEnTEXT(enMajuscule,avecEspacesEntreCoups : boolean);
var s : String255;
    aux : OSStatus;
begin
  s := PartiePourPressePapier(enMajuscule,avecEspacesEntreCoups,nbreCoup);

  aux := MyZeroScrap;
  if LENGTH_OF_STRING(s) > 0 then aux := MyPutScrap(LENGTH_OF_STRING(s),MY_FOUR_CHAR_CODE('TEXT'),@s[1]);

  TransfererLePressePapierGlobalDansTextEdit;
end;

procedure CopierDiagrammePositionEnTEXT;
var s : String255;
    aux : SInt32;
begin
  s := PositionCouranteEnDiagrammeTEXTPourPressePapier;
  if LENGTH_OF_STRING(s) > 0 then
    begin
      aux := MyZeroScrap;
      aux := MyPutScrap(LENGTH_OF_STRING(s),MY_FOUR_CHAR_CODE('TEXT'),@s[1]);

      TransfererLePressePapierGlobalDansTextEdit;
    end;
end;

procedure CopierDiagrammePartieEnTEXT;
var s : String255;
    aux : OSStatus;
begin
  {s := DiagrammePartieEnTEXTPourPressePapier(true,'|','|');}  {pour diagrammes commme sur IOS}
  {s := DiagrammePartieEnTEXTPourPressePapier(false,'|',' ');} {pour diagrammes comme Lazard}
  s := DiagrammePartieEnTEXTPourPressePapier(false,'|','|');

  if LENGTH_OF_STRING(s) > 0 then
    begin
      aux := MyZeroScrap;
      aux := MyPutScrap(LENGTH_OF_STRING(s),MY_FOUR_CHAR_CODE('TEXT'),@s[1]);

      TransfererLePressePapierGlobalDansTextEdit;
    end;
end;


procedure CopierPositionPourEndgameScriptEnTEXT;
var s : String255;
    aux : OSStatus;
    current : PositionEtTraitRec;
begin
  current := PositionEtTraitCourant;
  s := PositionEtTraitEnString(current);
  if LENGTH_OF_STRING(s) > 0 then
    begin
      aux := MyZeroScrap;
      aux := MyPutScrap(LENGTH_OF_STRING(s),MY_FOUR_CHAR_CODE('TEXT'),@s[1]);

      TransfererLePressePapierGlobalDansTextEdit;
    end;
end;

procedure CopierDiagrammePositionEnHTML;
var err : OSErr;
    theFile : FichierAbstrait;
    fic : FichierTEXT;
    aux : OSStatus;
begin
  FinRapport;
  aux := GetTailleRapport;

  (* Afficher le code HTML dans le rapport... *)
  err     := CreeSortieStandardEnFichierTexte(fic);  {en fait, dans le rapport}
  theFile := MakeFichierAbstraitFichier(fic.nomFichier,0);
  if FichierAbstraitEstCorrect(theFile)
    then
      begin
        err     := WritePositionEtTraitPageWebFFODansFichierAbstrait(PositionEtTraitCourant,'',theFile);
        DisposeFichierAbstrait(theFile);

       (* ... et le copier dans le presse-papier *)
        SetDebutSelectionRapport(aux);
      	SetFinSelectionRapport(GetTailleRapport);
        if CopierFromRapport then DoNothing;
      end;
end;



procedure GenereInfosIOSDansPressePapier(numeroDuCoup,couleur,coup : SInt32; tickPourCalculTemps : SInt32);
var probaDeGain : double_t;
    note : SInt32;
    tempsEnSecondes,aux : SInt32;
begin
  if not(EvaluationPourCourbeProvientDeLaFinale(numeroDuCoup))
    then
      begin
        if not(HumCtreHum) &
           (InfosDerniereReflexionMac.nroDuCoup = numeroDuCoup) &
           (InfosDerniereReflexionMac.coup = coup) &
           (InfosDerniereReflexionMac.coul = couleur) &
           (InfosDerniereReflexionMac.valeurCoup <> -noteMax)
          then
            begin
              note := InfosDerniereReflexionMac.valeurCoup;
            end
          else
            begin
              note := (GetEvaluationPourNoirDansCourbe(numeroDuCoup-1)+GetEvaluationPourNoirDansCourbe(numeroDuCoup)) div 2;
              if (couleur = pionBlanc) then note := -note;
            end;
        {on ramene entre -1.0 et 1.0}
        probaDeGain := note/2500.0;
        if probaDeGain < -0.98 then probaDeGain := -0.98;
        if probaDeGain > 0.98 then probaDeGain := 0.98;

        {on ramene entre 0.0 et 1.0}
        probaDeGain := 0.5*(probaDeGain+1.0);
        if probaDeGain < 0.02 then probaDeGain := 0.02;
        if probaDeGain > 0.98 then probaDeGain := 0.98;

      end
    else
      begin
        note := GetEvaluationPourNoirDansCourbe(numeroDuCoup) div kCoeffMultiplicateurPourCourbeEnFinale;

        if odd(note) then
          if note > 0 then note := 2
                      else note := -2;

        if couleur = pionBlanc
          then probaDeGain := -1.0*note
          else probaDeGain := 1.0*note;
      end;

  if numeroDuCoup < 7
    then tempsEnSecondes := 0
    else
      begin
        tempsEnSecondes := (TickCount-tickPourCalculTemps) div 60;
        if tempsEnSecondes < 0 then tempsEnSecondes := 0;
        if tempsEnSecondes > 10000 then tempsEnSecondes := 10000;
      end;

  chainePourIOS := Concat(CoupEnStringEnMajuscules(coup),' ',
                        ReelEnStringAvecDecimales(probaDeGain,6),' ',
                        NumEnString(tempsEnSecondes));
  aux := MyZeroScrap;
  aux := MyPutScrap(LENGTH_OF_STRING(chainePourIOS),MY_FOUR_CHAR_CODE('TEXT'),@chainePourIOS[1]);
  TransfererLePressePapierGlobalDansTextEdit;
end;


procedure TransfererLePressePapierGlobalDansTextEdit;
begin
  if (TEFromScrap = noErr) then DoNothing;
end;


function LongueurPressePapier(flavor : ScrapFlavorType) : SInt32;
begin
  TransfererLePressePapierGlobalDansTextEdit;
  LongueurPressePapier := GetScrapSize(flavor);
end;




function PartiePourPressePapier(enMajuscules,avecEspaceEntreCoups : boolean; nbreCoupsAExporter : SInt16) : String255;
var s : String255;
    i,coup : SInt16;
begin
  s := '';
  if (nroDernierCoupAtteint > 0) then
   for i := 1 to Min(nbreCoupsAExporter,nroDernierCoupAtteint) do
     begin
       coup := GetNiemeCoupPartieCourante(i);
       if coup > 0 then
         begin
           if enMajuscules
             then s := s + CHR(64+coup mod 10) + chr(48+coup div 10)
             else s := s + CHR(96+coup mod 10) + chr(48+coup div 10);
           if avecEspaceEntreCoups then s := s + StringOf(' ');
         end;
     end;
    PartiePourPressePapier := s;
end;

function PositionInitialeEnLignePourPressePapier : String255;
var i,j,x : SInt16;
    s : String255;
    plat : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin
  s := '';
  GetPositionInitialeOfGameTree(plat,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);
  for i := 1 to 8 do
    for j := 1 to 8 do
      begin
        x := plat[10*i+j];
        if x = pionBlanc
          then s := s + StringOf('o')
          else if x = pionNoir
                 then s := s + StringOf('x')
                 else s := s + StringOf('.');
      end;
    PositionInitialeEnLignePourPressePapier := s;
end;


function PositionCouranteEnDiagrammeTEXTPourPressePapier : String255;
var s : String255;
    i,j,x : SInt16;
begin
  s := '  A B C D E F G H  ';
  s := s + chr(13);
  for j := 1 to 8 do
    begin
      s := s + NumEnString(j)+' ';
      for i := 1 to 8 do
        begin
	        x := GetCouleurOfSquareDansJeuCourant(10*j+i);
	        if x = pionNoir then s := s + '* ' else
	        if x = pionBlanc then s := s + 'O ' else
	        if x = pionVide then s := s + '- ';
	      end;
	    s := s + NumEnString(j)+' ' + chr(13);
    end;
  s := s + '  A B C D E F G H  ';
  s := s + chr(13);
  PositionCouranteEnDiagrammeTEXTPourPressePapier := s;

  (*

  A B C D E F G H
1 - - - - - - - - 1
2 - - - - - - - - 2
3 - - - - - - - - 3
4 - - - O * - - - 4
5 - - - O * * - - 5
6 - - - O - - - - 6
7 - - - - - - - - 7
8 - - - - - - - - 8
  A B C D E F G H

   *)
end;





function DiagrammePartieEnTEXTPourPressePapier(avecCoordonnees : boolean; delimiteurVertical,SeparateurDeCoups : String255) : String255;
var i,j,t,x : SInt16;
    s,s1,s2 : String255;
    positionInitiale : plateauOthello;
    coups : plateauOthello;
    numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial : SInt32;
begin

  GetPositionInitialeOfGameTree(positionInitiale,numeroPremierCoup,traitInitial,nbBlancsInitial,nbNoirsInitial);

  MemoryFillChar(@coups,sizeof(coups),chr(0));
  for t := 1 to nbreCoup do
    begin
      x := GetNiemeCoupPartieCourante(t);
      if x > 0 then coups[x] := t;
    end;

  s := '';
  if avecCoordonnees
    then s := s + '   A  B  C  D  E  F  G  H' + chr(13);
  for j := 1 to 8 do
    begin
      if avecCoordonnees then s := s + NumEnString(j)+' ';
      s := s + DelimiteurVertical;
      for i := 1 to 8 do
	      begin
	        t := 10*j+i;
	        if positionInitiale[t] <> pionVide
	          then
	            begin
	              if positionInitiale[t] = pionBlanc then s := s + '()' else
	              if positionInitiale[t] = pionNoir  then s := s + '##'
	                else s := s + '  ';
	            end
	          else
	            begin
	              x := coups[t];
	              if x <=  0 then s := s + '00' else
	              if x <  10 then s := s + ' '+NumEnString(x) else
	              if x <= 99 then s := s + NumEnString(x)
	                else s := s + '00';
	            end;
	        if (i <= 7) then s := s + SeparateurDeCoups;
	      end;
	    s := s + DelimiteurVertical;
	    s := s + chr(13);
    end;

  {titre : soit les joueurs si on les connait, sinon le score seul}
  with ParamDiagPartieFFORUM do
    if gameOver & (titreFForum <> NIL) & (titreFForum^^ <> '')
      then
        begin
          s1 := titreFForum^^;
        end
      else
        begin
          s1 := NumEnString(nbreDePions[pionNoir]);
          s2 := NumEnString(nbreDePions[pionBlanc]);
          s1 := s1 + StringOf('-')+s2;
        end;
  for t := 1 to ((25-LENGTH_OF_STRING(s1)) div 2) do s1 := Concat(' ',s1);  {pour centrer}
  s := s + s1 + chr(13);

  DiagrammePartieEnTEXTPourPressePapier := s;


  (*

|00|00|00|00|00|00|00|00|
|00|00|00|00|00|00|00|00|
|00|00| 3|00|00|00|00|00|
|00|00|00|()|##|00|00|00|
|00|00|00|##|()| 1|00|00|
|00|00|00| 2|00|00|00|00|
|00|00|00|00|00|00|00|00|
|00|00|00|00|00|00|00|00|
           5-2

 *)
end;



END.
