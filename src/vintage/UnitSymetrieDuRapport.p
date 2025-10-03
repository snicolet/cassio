UNIT UnitSymetrieDuRapport;


INTERFACE







 uses UnitDefCassio;


{Symetrie sur le texte du rapport}
procedure DoSymetrieSelectionDuRapport(axeSymetrie : SInt32);                                                                                                                       ATTRIBUTE_NAME('DoSymetrieSelectionDuRapport')


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    UnitRapportImplementation, UnitServicesRapport, UnitRapport, UnitNormalisation, UnitScannerUtils, MyMathUtils, UnitServicesMemoire, MyStrings
    , UnitFichiersTEXT ;
{$ELSEC}
    {$I prelink/SymetrieDuRapport.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure DoSymetrieSelectionDuRapport(axeSymetrie : SInt32);
type tableBooleens = {packed} array[0..100000] of boolean;
     tableBooleensPtr = ^tableBooleens;
var debut,fin,k : SInt32;
    nbRemplacements,numeroPasse : SInt32;
    separateursDeMots : set of char;
    c1,c2 : char;
    s,s1,s2,s3,s4,filename,ligne,pattern,remplacement,reste : String255;
    whichSquare : SInt16;
    rapportTexteHandle : CharArrayHandle;
    fichierDesSymetries : FichierTEXT;
    erreurES : OSErr;
    peutRemplacer : tableBooleensPtr;
    tailleTablePeutRemplacer : SInt32;
    oldParsingSet : SetOfChar;

  procedure RemplacerToutesOccurences(pattern,chaineRemplacement : String255; motsEntiers : boolean);
  var remplacer,trouve,refus : boolean;
      from,position,k,delta : SInt32;
      longueurPattern,longueurRemplacement : SInt32;
  begin
    longueurPattern := LENGTH_OF_STRING(pattern);
    longueurRemplacement := LENGTH_OF_STRING(chaineRemplacement);

    from := debut;
    repeat
      trouve := false;
      if FindStringInRapport(pattern,from,+1,position) &
         (position <= fin - longueurPattern)
        then
	        begin
	          trouve := true;
	          refus := false;

	          if motsEntiers
	            then remplacer :=  ((position-1 < debut) | (GetNiemeCaractereDuRapport(position-1) in separateursDeMots)) &
                                 ((position+longueurPattern >= fin) | (GetNiemeCaractereDuRapport(position+longueurPattern) in separateursDeMots))
              else remplacer := true;


            for k := position to position+longueurPattern-1 do
              if not(peutRemplacer^[k]) then
                begin
                  remplacer := false;
                  refus := true;
                end;


            {if refus then WritelnDansRapport('refus, on n'écrase pas le nouveau texte !');}

            if remplacer
              then
                begin
	                RemplacerTexteDansRapport(position,position+longueurPattern,chaineRemplacement,false);
				          from := position + longueurRemplacement;
				          fin := fin + (longueurRemplacement - longueurPattern);
				          inc(nbRemplacements);

				          {on deplace la fin du tableau "peutRemplacer"}
				          if (longueurRemplacement > longueurPattern) then
				            begin
				              delta := longueurRemplacement - longueurPattern;
				              for k := tailleTablePeutRemplacer downto position+delta do
		                    peutRemplacer^[k] := peutRemplacer^[k-delta];
				            end;
				          if (longueurRemplacement < longueurPattern) then
				            begin
				              delta := longueurPattern - longueurRemplacement;
				              for k := position to tailleTablePeutRemplacer-delta do
		                    peutRemplacer^[k] := peutRemplacer^[k+delta];
				            end;

				          {on met a jour le tableau "peutRemplacer" en indiquant que le nouveau texte ne doit pas etre ecrasé}
				          for k := position to position+longueurRemplacement-1 do
				            peutRemplacer^[k] := false;
				        end
				      else
				        begin
				          from := position + 1;
				        end;

	        end;
    until not(trouve);

  end;


begin
  oldParsingSet := GetParsingCaracterSet;

  if SelectionRapportNonVide then
    begin
      debut := GetDebutSelectionRapport;
      fin := GetFinSelectionRapport;



      {on alloue un tableau de booleans qui nous dira si on a le
       droit de remplacer le kieme caractere du rapport}
      tailleTablePeutRemplacer := Max(40000,GetTailleRapport+10000); { sizeof(boolean) = 1 octet }
      peutRemplacer := tableBooleensPtr(AllocateMemoryPtr(tailleTablePeutRemplacer+10));

      if peutRemplacer <> NIL then
        begin
		      for k := 0 to tailleTablePeutRemplacer do
		        peutRemplacer^[k] := true;



		      { PASSE 1 }
		      numeroPasse := 1;

		      {symetries des cases}
		      rapportTexteHandle := GetRapportTextHandle;
		      if (rapportTexteHandle <> NIL) then
		        for k := debut+1 to fin-1 do
		          begin
		            c1 := rapportTexteHandle^^[k-1];
		            c2 := rapportTexteHandle^^[k];

		            if CharInRange(c1,'a','h') & CharInRange(c2,'1','8')
		              then {coup en minuscules trouvé}
			              begin
			                s := Concat(c1,c2);
			                whichSquare := StringEnCoup(s);
			                s := CoupEnStringEnMinuscules(CaseSymetrique(whichSquare,axeSymetrie));
			                RemplacerTexteDansRapport(k-1,k+1,s,false);
			              end
			          else
		            if CharInRange(c1,'A','H') & CharInRange(c2,'1','8') then
		              begin {coup en majuscules trouvé}
		                s := Concat(c1,c2);
		                whichSquare := StringEnCoup(s);
		                s := CoupEnStringEnMajuscules(CaseSymetrique(whichSquare,axeSymetrie));
		                RemplacerTexteDansRapport(k-1,k+1,s,false);
		              end;

		          end;

		      { PASSES 2 et 3 : on lit le fichier "symetries.txt" }


		      nbRemplacements := 0;
		      separateursDeMots := [' ','.',',',' ',';',':',chr(0),'(',')','{','}','[',']','…','!','?','/','«','»'];


		      filename := 'Symetries.txt';

		      erreurES := FichierTexteDeCassioExiste(filename,fichierDesSymetries);
		      if erreurES = NoErr then
		        erreurES := OuvreFichierTexte(fichierDesSymetries);

		      if erreurES = NoErr then
		        begin



				      while (erreurES = NoErr) & not(EOFFichierTexte(fichierDesSymetries,erreurES)) do
						    begin
						      erreurES := ReadlnDansFichierTexte(fichierDesSymetries,ligne);
						      {WritelnDansRapport(ligne);}
						      if (erreurES = NoErr) & (ligne <> '') & (ligne[1] <> '%') then
						        begin

						        if pos('PASS',ligne) = 1
						          then
						            begin
						              SetParsingCaracterSet([' ']);
						              Parser2(ligne,s1,s2,reste);
						              ChaineToLongint(s2,numeroPasse);

						              for k := 0 to tailleTablePeutRemplacer do
		                        peutRemplacer^[k] := true;

						              {WritelnNumDansRapport('numeroPasse = ',numeroPasse);}
						            end
						          else
						            begin

						              if numeroPasse = 2
						                then
						                  begin
						                    SetParsingCaracterSet(['>']);
						                    Parser3(ligne,s1,s2,s3,reste);


						                    SetParsingCaracterSet(['"']);


						                    s := s1;
						                    s := EnleveEspacesDeGauche(s);
						                    s := EnleveEspacesDeDroite(s);
						                    Parser(s,pattern,reste);

						                    s := s2;
						                    s := EnleveEspacesDeGauche(s);
						                    s := EnleveEspacesDeDroite(s);
						                    Parser(s,remplacement,reste);



						                    {on remplace toutes les occurences de pattern, sans tenir compte des coupures de mot}
						                    RemplacerToutesOccurences(pattern,remplacement,false);
						                  end
						                else
						                  begin
						                    SetParsingCaracterSet([';']);
						                    Parser4(ligne,s1,s2,s3,s4,reste);
						                    SetParsingCaracterSet(['"']);

						                    s := s1;
						                    s := EnleveEspacesDeGauche(s);
						                    s := EnleveEspacesDeDroite(s);
						                    Parser(s,pattern,reste);

						                    case axeSymetrie of
						                      central  : s := s4;
                                  axeSE_NW : s := s2;
                                  axeSW_NE : s := s3;
                                  otherwise  s := s1;
                                end;
                                s := EnleveEspacesDeGauche(s);
						                    s := EnleveEspacesDeDroite(s);
						                    Parser(s,remplacement,reste);

						                    {WritelnDansRapport(pattern + '  ==>  '+remplacement);}

						                    {on remplace toutes les occurences de pattern, en tenant compte des coupures de mot}
						                    RemplacerToutesOccurences(pattern,remplacement,true);
						                  end;
							          end;

				            end;
				        end;
				    end;

		      erreurES := FermeFichierTexte(fichierDesSymetries);

		      SetParsingCaracterSet([' ',tab]);

		      SelectionnerTexteDansRapport(debut,fin);

		    end;

      if (peutRemplacer <> NIL) then DisposeMemoryPtr(Ptr(peutRemplacer));
    end;

  SetParsingCaracterSet(oldParsingSet);
end;



END.
