UNIT UnitConstrListeBitboard;


INTERFACE


 USES UnitDefCassio;



// Initialisation de l'unite
procedure InitUnitConstructionListeBitboard;                                                                                                                                        ATTRIBUTE_NAME('InitUnitConstructionListeBitboard')
procedure LibereMemoireUnitConstructionListeBitboard;                                                                                                                               ATTRIBUTE_NAME('LibereMemoireUnitConstructionListeBitboard')


// Demande de la reconstruction de la liste bitboard
procedure SetDoitReconstruireLaListeBitboard(flag : boolean);                                                                                                                       ATTRIBUTE_NAME('SetDoitReconstruireLaListeBitboard')
function DoitReconstruireLaListeBitboard : boolean;                                                                                                                                 ATTRIBUTE_NAME('DoitReconstruireLaListeBitboard')



// La reconstruction proprement dite
procedure ConstruireTableListeBitboardToSquare(theList : celluleCaseVideDansListeChaineePtr);                                                                                       ATTRIBUTE_NAME('ConstruireTableListeBitboardToSquare')
function ListeChaineeDesCasesVidesEnListeBitboard(theList : celluleCaseVideDansListeChaineePtr; nbCasesVides : SInt32) : UInt32;                                                    ATTRIBUTE_NAME('ListeChaineeDesCasesVidesEnListeBitboard')
procedure ReconstruireLaTableListeBitboardToSquareSiNecessaire(nbCasesVides : SInt32; listeChainee : celluleCaseVideDansListeChaineePtr);                                           ATTRIBUTE_NAME('ReconstruireLaTableListeBitboardToSquareSiNecessaire')


// Test de l'unite
procedure WritelnListeBitboardDansRapport(s : String255; listeBitboard : UInt32; nbCasesVides : SInt32);                                                                            ATTRIBUTE_NAME('WritelnListeBitboardDansRapport')
procedure TesterListeCasesVidesBitboard(listeBitboard : UInt32; nbCasesVides : SInt32);                                                                                             ATTRIBUTE_NAME('TesterListeCasesVidesBitboard')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    Sound
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitScannerUtils, MyStrings, UnitListeChaineeCasesVides, UnitParallelisme, SNEvents, MyMathUtils ;
{$ELSEC}
    ;
    {$I prelink/ConstrListeBitboard.lk}
{$ENDC}


{END_USE_CLAUSE}






{$ifc defined __GPC__}
    {$I CountLeadingZerosForGNUPascal.inc}
{$endc}




var gDoitReconstruireLaListeBitboard : boolean;


procedure InitUnitConstructionListeBitboard;
begin
  SetDoitReconstruireLaListeBitboard(true);
end;


procedure LibereMemoireUnitConstructionListeBitboard;
begin
end;


procedure SetDoitReconstruireLaListeBitboard(flag : boolean);
begin
  gDoitReconstruireLaListeBitboard := flag;
end;


function DoitReconstruireLaListeBitboard : boolean;
begin
  DoitReconstruireLaListeBitboard := gDoitReconstruireLaListeBitboard;
end;



procedure ConstruireTableListeBitboardToSquare(theList : celluleCaseVideDansListeChaineePtr);
var longueur : SInt32;
    celluleDansListeChainee : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
    puissanceDeDeux : UInt32;
    i : SInt32;
begin

  (* WritelnDansRapport('Entree dans ConstruireTableListeBitboardToSquare...'); *)

  for i := 0 to 32 do
    gTableBitListeBitboardToSquare[i] := 0;

  for i := 0 to 32 do
    gTableBitListeBitboardConstanteDePariteDeSquare[i] := 0;

  for i := 0 to 99 do
    gTableSquareToBitCaseVidePourListeBiboard[i] := 0;


  longueur := 0;
  puissanceDeDeux := 1;

  celluleDepart := theList;
  celluleDansListeChainee := celluleDepart^.next;
  repeat
    with celluleDansListeChainee^ do
      begin

        gTableBitListeBitboardToSquare[31 - longueur] := square;
        gTableBitListeBitboardConstanteDePariteDeSquare[31 - longueur] := constanteDeParite[square];
        gTableSquareToBitCaseVidePourListeBiboard[square] := puissanceDeDeux;

        {WritelnNumDansRapport('puissanceDeDeux = '+Hexa(puissanceDeDeux) + ' pour la longueur ',longueur);}


        if (square >= 11) & (square <= 88)
          then
            begin
              (* if longueur = 0
			          then WriteStringDansRapport('[ '+CoupEnString(square,true))
			          else WriteStringDansRapport(', '+CoupEnString(square,true));
			        *)


            end
          else
            begin

              WritelnDansRapport('ASSERT : square n''est pas une case valide dans ConstruireTableListeBitboardToSquare !!');
              Sysbeep(0);


			        if longueur = 0
			          then WriteNumDansRapport('[',square)
			          else WriteNumDansRapport(',',square);
			      end;


			  inc(longueur);
			  puissanceDeDeux := puissanceDeDeux * 2;

        celluleDansListeChainee := next;
      end;
  until celluleDansListeChainee = celluleDepart;

  (* WritelnNumDansRapport(']   longueur = ',longueur); *)

  if (longueur > 32) then
    begin
      WritelnDansRapport('ASSERT : longueur > 32  dans  ConstruireTableListeBitboardToSquare !!!! ');
      Sysbeep(0);

    end;

  (*
  WritelnDansRapport('Sortie de ConstruireTableListeBitboardToSquare');
  WritelnDansRapport('');
  *)
end;



function ListeChaineeDesCasesVidesEnListeBitboard(theList : celluleCaseVideDansListeChaineePtr; nbCasesVides : SInt32) : UInt32;
var longueur : SInt32;
    celluleDansListeChainee : celluleCaseVideDansListeChaineePtr;
    celluleDepart : celluleCaseVideDansListeChaineePtr;
    myListeBitboard : SInt32;
    onAEcritQuelqueChose : boolean;
begin

  (* WritelnDansRapport('Entree dans ListeChaineeDesCasesVidesEnListeBitboard...'); *)

  onAEcritQuelqueChose := false;

  longueur := 0;
  myListeBitboard := 0;

  if (nbCasesVides > 0) then
    begin

      celluleDepart := theList;
      celluleDansListeChainee := celluleDepart^.next;
      repeat
        with celluleDansListeChainee^ do
          begin

            myListeBitboard := myListeBitboard + gTableSquareToBitCaseVidePourListeBiboard[square];

            {WritelnNumDansRapport('myListeBitboard = '+Hexa(myListeBitboard) + ' pour la longueur ',longueur);}

            (*
            if (square >= 11) & (square <= 88)
              then
                begin
                  { if longueur = 0
    			          then WriteStringDansRapport('[ '+CoupEnString(square,true))
    			          else WriteStringDansRapport(', '+CoupEnString(square,true));
    			         }

                end
              else
                begin

                  WritelnNumDansRapport('ASSERT : square n''est pas une case valide dans ListeChaineeDesCasesVidesEnListeBitboard !!, square = ',square);
                  WritelnNumDansRapport('                     et d''ailleurs, nbCasesVides = ',nbCasesVides);
                  Sysbeep(0);


    			        if longueur = 0
    			          then WriteNumDansRapport('[',square)
    			          else WriteNumDansRapport(',',square);

    			        onAEcritQuelqueChose := true;
    			      end;
    			  *)

    			  inc(longueur);

            celluleDansListeChainee := next;
          end;
      until celluleDansListeChainee = celluleDepart;

    end;

  if onAEcritQuelqueChose then
    WritelnNumDansRapport(']   longueur = ',longueur);

  if (longueur > 30) then
    begin
      WritelnDansRapport('ASSERT : longueur > 30  dans  ListeChaineeDesCasesVidesEnListeBitboard !!!! ');
      Sysbeep(0);
    end;


  ListeChaineeDesCasesVidesEnListeBitboard := myListeBitboard;

  (* WritelnDansRapport('Sortie de ListeChaineeDesCasesVidesEnListeBitboard');
  WritelnDansRapport(''); *)
end;


procedure ReconstruireLaTableListeBitboardToSquareSiNecessaire(nbCasesVides : SInt32; listeChainee : celluleCaseVideDansListeChaineePtr);
begin
  if (nbCasesVides = 30)
    then SetDoitReconstruireLaListeBitboard(true);

  if DoitReconstruireLaListeBitboard & (nbCasesVides <= 30)
    then
      begin
        ConstruireTableListeBitboardToSquare(listeChainee);
        SetDoitReconstruireLaListeBitboard(false);
        {TesterListeCasesVidesBitboard(ListeChaineeDesCasesVidesEnListeBitboard(listeChainee,nbCasesVides), nbCasesVides);}
      end;
end;


procedure TesterListeCasesVidesBitboard(listeBitboard : UInt32; nbCasesVides : SInt32);
var
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    iCourant1, iCourant2 : UInt32;
    leadingZeros2 : UInt32;
    listeNormale : listeVides;
    nbCasesVidesTrouvees, i, j : SInt32;
begin

 WritelnNumDansRapport('EntrŽe dans TesterListeCasesVidesBitboard,  nbCasesVides = ',nbCasesVides);
 WritelnDansRapport('');

 nbCasesVidesTrouvees := 0;
 for i := 0 to 64 do
   listeNormale[i] := 0;

 REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);

    GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);

    inc(nbCasesVidesTrouvees);
    listeNormale[nbCasesVidesTrouvees] := iCourant;

    WritelnDansRapport('liste arrivee = '+Hexa(listeBitboard));
    WritelnNumDansRapport('leadingZeros = ',leadingZeros);
    WritelnStringDansRapport('bitCaseVide = '+Hexa(bitCaseVide));
    WritelnDansRapport('Soit en hexa : '+Hexa(iterateur));
    WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
    WritelnDansRapport('en retirant la case de la liste des cases vides, liste = '+Hexa(REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide)));
    WritelnDansRapport('');

  UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);




  if (nbCasesVidesTrouvees <> nbCasesVides) then
    begin
      WritelnDansRapport('ASSSERT (1) dans TesterListeCasesVidesBitboard !!');
      WritelnNumDansRapport('nbCasesVides = ',nbCasesVides);
      WritelnNumDansRapport('nbCasesVidesTrouvees = ',nbCasesVidesTrouvees);
      WritelnDansRapport('');
      Sysbeep(0);
      AttendFrappeClavier;
    end;

  for i := 1 to nbCasesVidesTrouvees do
    begin
      if i = 1
			  then WriteStringDansRapport('[ '+CoupEnString(listeNormale[i],true))
			  else WriteStringDansRapport(', '+CoupEnString(listeNormale[i],true));
    end;

  WritelnNumDansRapport('],  nbCasesVidesTrouvees = ',nbCasesVidesTrouvees);
  WritelnDansRapport('');

  for i := 1 to nbCasesVidesTrouvees do
    for j := 1 to nbCasesVidesTrouvees do
      if (i <> j) then
        begin
          listeBitboard := gTableSquareToBitCaseVidePourListeBiboard[listeNormale[i]] +
                           gTableSquareToBitCaseVidePourListeBiboard[listeNormale[j]];

          GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE(listeBitboard,iCourant1,iCourant2);

          if (iCourant1 <> listeNormale[i]) & (iCourant1 <> listeNormale[j]) then
            begin
              WritelnDansRapport('ASSSERT (2) dans TesterListeCasesVidesBitboard !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              WritelnDansRapport('');
              Sysbeep(0);
              AttendFrappeClavier;
            end;

          if (iCourant2 <> listeNormale[i]) & (iCourant2 <> listeNormale[j]) then
            begin
              WritelnDansRapport('ASSSERT (3) dans TesterListeCasesVidesBitboard !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              WritelnDansRapport('');
              Sysbeep(0);
              AttendFrappeClavier;
            end;

          if (iCourant1 = iCourant2) then
            begin
              WritelnDansRapport('ASSSERT (4) dans TesterListeCasesVidesBitboard !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              Sysbeep(0);
              AttendFrappeClavier;
            end;
        end;






end;



procedure WritelnListeBitboardDansRapport(s : String255; listeBitboard : UInt32; nbCasesVides : SInt32);
var
    ALLOUER_VARIABLES_LISTE_CASES_VIDES(iterateur,iCourant,bitCaseVide,leadingZeros);
    iCourant1, iCourant2 : UInt32;
    leadingZeros2 : UInt32;
    listeNormale : listeVides;
    nbCasesVidesTrouvees, i, j : SInt32;
begin

 WritelnDansRapport('');
 WritelnDansRapport('Entree dans WritelnListeBitboardDansRapport : ');
 WriteDansRapport(s);

 nbCasesVidesTrouvees := 0;
 for i := 0 to 64 do
   listeNormale[i] := 0;

 WriteDansRapport(' [');

 if (listeBitboard <> 0) then
   begin
     REPEAT_ITERER_LISTE_CASES_VIDES(listeBitboard,iterateur);

        GET_NEXT_CASE_VIDE(iterateur,bitCaseVide,iCourant,leadingZeros);

        inc(nbCasesVidesTrouvees);
        listeNormale[nbCasesVidesTrouvees] := iCourant;

        if nbCasesVidesTrouvees = 1
    			then WriteStringDansRapport(CoupEnString(iCourant,true))
    			else WriteStringDansRapport(', '+CoupEnString(iCourant,true));

        (*
        WritelnDansRapport('');
        WritelnDansRapport('liste arrivee = '+Hexa(listeBitboard));
        WritelnNumDansRapport('leadingZeros = ',leadingZeros);
        WritelnStringDansRapport('bitCaseVide en hexa =  '+Hexa(bitCaseVide));
        WritelnDansRapport('iterateur en hexa : '+Hexa(iterateur));
        WritelnStringAndCoupDansRapport('iCourant = ',iCourant);
        WritelnDansRapport('en retirant la case de la liste des cases vides, liste = '+Hexa(REMOVE_BIT_CASE_VIDE_FROM_LISTE(listeBitboard,bitCaseVide)));
        WritelnDansRapport('');
        *)

      UNTIL_LISTE_CASES_VIDES_EST_VIDE(iterateur);
    end;

  WriteDansRapport(']');



  if (nbCasesVidesTrouvees <> nbCasesVides) and (nbCasesVides >= 0) then
    begin
      WritelnDansRapport('');
      WritelnDansRapport('ASSSERT (1) dans WritelnListeBitboardDansRapport : le nombre de cases vides ne correspond pas ');
      WritelnNumDansRapport('nbCasesVides = ',nbCasesVides);
      WritelnNumDansRapport('nbCasesVidesTrouvees = ',nbCasesVidesTrouvees);
      WritelnDansRapport('');
      Sysbeep(0);
      AttendFrappeClavier;
    end;


  WritelnNumDansRapport('  nbCasesVidesTrouvees = ',nbCasesVidesTrouvees);

  for i := 1 to nbCasesVidesTrouvees do
    for j := 1 to nbCasesVidesTrouvees do
      if (i <> j) then
        begin
          listeBitboard := gTableSquareToBitCaseVidePourListeBiboard[listeNormale[i]] +
                           gTableSquareToBitCaseVidePourListeBiboard[listeNormale[j]];


(*  Les lignes commentees suivantent permettent eventuellement
    de debuguer la macro GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE
*)

(*

WritelnDansRapport('');
WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
WritelnDansRapport(' listeBitboard = '+Hexa(listeBitboard));

begin

bitCaseVide := listeBitboard and (not(listeBitboard - 1));

WritelnDansRapport(' bitCaseVide = '+Hexa(bitCaseVide));

SAFE_COUNT_LEADING_ZEROS(bitCaseVide, leadingZeros);

WritelnNumDansRapport('leadingZeros = ',leadingZeros);

iCourant1 := gTableBitListeBitboardToSquare[leadingZeros];

WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);

WritelnDansRapport(' listeBitboard = '+Hexa(listeBitboard));

SAFE_COUNT_LEADING_ZEROS(listeBitboard, leadingZeros2);

WritelnNumDansRapport('leadingZeros2 = ',leadingZeros2);

iCourant2 := gTableBitListeBitboardToSquare[leadingZeros2];

WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);

end;

WritelnDansRapport('');

*)


          GET_DEUX_DERNIERES_CASES_VIDES_FROM_LISTE(listeBitboard,iCourant1,iCourant2);



          if (iCourant1 <> listeNormale[i]) & (iCourant1 <> listeNormale[j]) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('ASSSERT (2) dans WritelnListeBitboardDansRapport : iCourant1 n''est pas bon !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              WritelnDansRapport('');
              Sysbeep(0);
              AttendFrappeClavier;
            end;

          if (iCourant2 <> listeNormale[i]) & (iCourant2 <> listeNormale[j]) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('ASSSERT (3) dans WritelnListeBitboardDansRapport : iCourant2 n''est pas bon !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              WritelnDansRapport('');
              Sysbeep(0);
              AttendFrappeClavier;
            end;

          if (iCourant1 = iCourant2) then
            begin
              WritelnDansRapport('');
              WritelnDansRapport('ASSSERT (4) dans WritelnListeBitboardDansRapport : iCourant1 et iCourant2 sont le meme coup !!');
              WritelnStringAndCoupDansRapport('listeNormale[i] = ',listeNormale[i]);
              WritelnStringAndCoupDansRapport('listeNormale[j] = ',listeNormale[j]);
              WritelnStringAndCoupDansRapport('iCourant1 = ',iCourant1);
              WritelnStringAndCoupDansRapport('iCourant2 = ',iCourant2);
              Sysbeep(0);
              AttendFrappeClavier;
            end;
        end;

end;







END.































