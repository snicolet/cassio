UNIT UnitTestHashing;


INTERFACE




procedure TestUnitHashing;

procedure Cryptographie;

procedure DecrypterGrilleDuRallye2011;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio, OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, UnitHashing, UnitServicesMemoire, UnitFichiersTEXT ;
{$ELSEC}
    ;
    {$I prelink/TestHashing.lk}
{$ENDC}


{END_USE_CLAUSE}












procedure TestUnitHashing;
var s, s1, s2 : String255;
    aux, i, t, somme , n: SInt32;
begin
  s := 'tot';
  s1 := 'toto';
  s2 := 'toto est grand, pas grand, pas pas pas pas grand ∏∏∏∏∏';

  aux := HashString(s);

  WritelnNumDansRapport('hasher '+s +' => ',aux);

  aux := HashString(s1);

  WritelnNumDansRapport('hasher '+s1 +' => ',aux);

  aux := HashString(s2);

  WritelnNumDansRapport('hasher '+s2 +' => ',aux);

  for i := 0 to LENGTH_OF_STRING(s2) do
    begin
      s := Copy(s2,1,i);

      aux := HashString(s);

      // WritelnNumDansRapport('hacher '+s +' => ',aux);
    end;


  for aux := -3 to 10 do
    for i := -2 to LENGTH_OF_STRING(s2) + 2 do
      begin
        s := TPCopy(s2, i, aux);

        (*
        if (Pos(s, s2) <> FirstPos(s, s2)) then
          begin
            WritelnDansRapport('BAD : ');
            WritelnNumDansRapport('Pos( "'+s+'" , "'+s2+'" ) = ',Pos(s, s2));
            WritelnNumDansRapport('FirstPos( "'+s+'" , "'+s2+'" ) = ',FirstPos(s, s2));
            WritelnDansRapport('');
          end;
        *)

        s := s + 'a';

        (*
        if (Pos(s, s2) <> FirstPos(s, s2)) then
          begin
            WritelnDansRapport('BAD 2 :');
            WritelnNumDansRapport('Pos( "'+s+'" , "'+s2+'" ) = ',Pos(s, s2));
            WritelnNumDansRapport('FirstPos( "'+s+'" , "'+s2+'" ) = ',FirstPos(s, s2));
            WritelnDansRapport('');
          end;
        *)

      end;


  t := TickCount;

  somme := 0;
  for n := 1 to 1000 do
    for aux := 1 to 200 do
      for i := -2 to LENGTH_OF_STRING(s2) + 2  do
        begin
          s := TPCopy(s2, i, aux);
          somme := somme + Pos(s, s2);

          (*
          s := s + 'a';
          somme := somme + Pos(s, s2);
          *)

        end;

   WritelnNumDansRapport('temps de Pos = ',Tickcount - t);
   WritelnNumDansRapport('somme = ',somme);


  t := TickCount;

  somme := 0;
  for n := 1 to 1000 do
    for aux := 1 to 200 do
      for i := -2 to LENGTH_OF_STRING(s2) + 2  do
        begin
          s := TPCopy(s2, i, aux);
          somme := somme + FirstPos(s, s2);

          (*
          s := s + 'a';
          somme := somme + FirstPos(s, s2);
          *)

        end;

   WritelnNumDansRapport('temps de FirstPos = ',Tickcount - t);
   WritelnNumDansRapport('somme = ',somme);

end;


const kLONGUEUR_MAX_MOT      = 30;
      kLONGUEUR_MAX_DECALAGE = 150;

type decalageCrypto = array[1..kLONGUEUR_MAX_DECALAGE] of SInt32;

var crypto : record
               dernierMotAjoute : String255;
               nombreDeMotsDeCetteLongueur : array[0..kLONGUEUR_MAX_MOT] of SInt32;
               lettresEnTas : array[0..kLONGUEUR_MAX_MOT] of PackedArrayOfCharPtr;
               nbEntreesHashTable : SInt32;
               hashTable  : LongintArrayPtr;
               hashTable2 : LongintArrayPtr;
             end;

var gDernierMotSolutionAffiche : String255;

procedure AjouterCeMotDansLaTableDeHachage(mot : String255);
var hash : SInt32;
    index,decalage : SInt32;
    myUInt32Ptr : unsignedlongP;
begin

  with crypto do
    begin

      // on met le mot dans la premiere table de hachage
      hash := abs(HashString(mot));
      index       := (hash shr 5) mod nbEntreesHashTable;      // index    := (hash div 32) mod nbEntreesHashTable;
      decalage    :=  hash and $0000001F;                      // decalage :=  hash mod 32;
      myUInt32Ptr := unsignedlongP(hashTable);
      myUInt32Ptr := POINTER_ADD(myUInt32Ptr, 4*index);
      BSet(myUInt32Ptr^,decalage);


      // puis dans la deuxieme (avec une autre fonction de hachage)
      hash := abs(HashString2(mot));
      index       := (hash shr 5) mod nbEntreesHashTable;      // index    := (hash div 32) mod nbEntreesHashTable;
      decalage    :=  hash and $0000001F;                      // decalage :=  hash mod 32;
      myUInt32Ptr := unsignedlongP(hashTable2);
      myUInt32Ptr := POINTER_ADD(myUInt32Ptr, 4*index);
      BSet(myUInt32Ptr^,decalage);


    end;
end;


function CeMotEstDansLaTableDeHachage(mot : String255) : boolean;
var hash : SInt32;
    index,decalage : SInt32;
    myUInt32Ptr : unsignedlongP;
    test1, test2 : boolean;
begin

  with crypto do
    begin

      // on regarde d'abord dans la premiere table de hachage
      hash := abs(HashString(mot));
      index       := (hash shr 5) mod nbEntreesHashTable;      // index    := (hash div 32) mod nbEntreesHashTable;
      decalage    :=  hash and $0000001F;                      // decalage :=  hash mod 32;
      myUInt32Ptr := unsignedlongP(hashTable);
      myUInt32Ptr := POINTER_ADD(myUInt32Ptr, 4*index);

      test1 := BTST(myUInt32Ptr^,decalage);

      if not(test1) then
        begin
          CeMotEstDansLaTableDeHachage := false;
          exit(CeMotEstDansLaTableDeHachage);
        end;


      // puis dans la deuxieme (avec une autre fonction de hachage)
      hash := abs(HashString2(mot));
      index       := (hash shr 5) mod nbEntreesHashTable;      // index    := (hash div 32) mod nbEntreesHashTable;
      decalage    :=  hash and $0000001F;                      // decalage :=  hash mod 32;
      myUInt32Ptr := unsignedlongP(hashTable2);
      myUInt32Ptr := POINTER_ADD(myUInt32Ptr, 4*index);

      test2 := BTST(myUInt32Ptr^,decalage);


      CeMotEstDansLaTableDeHachage := test1 & test2;

    end;
end;

procedure AjouterMotFrancais(mot : String255);
var len , n, k : SInt32;
begin

  with crypto do
    begin

      if (mot = dernierMotAjoute) then exit(AjouterMotFrancais);

      len := LENGTH_OF_STRING(mot);

      if (len > 0) & (len <= kLONGUEUR_MAX_MOT) then
        begin
          n := nombreDeMotsDeCetteLongueur[len] * len;

          inc(nombreDeMotsDeCetteLongueur[len]);

          if (lettresEnTas[len] <> NIL) then
              begin
                for k := 1 to len do
                  lettresEnTas[len]^[n + k - 1] := mot[k];

                if (len = 10) then
                  AjouterCeMotDansLaTableDeHachage(mot);

                dernierMotAjoute := mot;
              end;
        end;
    end;
end;


procedure CalculerLesDecalages(mot1, mot2 : String255; var decalages : decalageCrypto);
var len1,len2 : SInt32;
    k, delta : SInt32;
begin
  len1 := LENGTH_OF_STRING(mot1);
  len2 := LENGTH_OF_STRING(mot2);

  for k := 1 to len1 do
    begin
      delta := ord(mot1[k]) - ord(mot2[k]);

      decalages[k] := delta;
    end;

  for k := len1 + 1 to kLONGUEUR_MAX_DECALAGE do
    decalages[k] := -5000;
end;


function GetNiemeMotDeCetteLongueur(n, len : SInt32) : String255;
var debut, k : SInt32;
    s : String255;
begin
  with crypto do
    begin
      s := '';
      if (n >= 1) & (n <= nombreDeMotsDeCetteLongueur[len]) & (lettresEnTas[len] <> NIL) then
        begin
          debut := (n - 1) * len;

          for k := 0 to len - 1 do
            s := s + lettresEnTas[len]^[debut + k]
        end;

      GetNiemeMotDeCetteLongueur := s;
    end;
end;


procedure LireDictionnaireDesMotsFrancais(nomFichier : String255);
var fic : FichierTEXT;
    err : OSErr;
    s : String255;
    compteurMots : SInt32;
    ticks : SInt32;
label sortie;
begin

  ticks := TickCount;

  WritelnDansRapport('Entree dans LireDictionnaireDesMotsFrancais :  lecture de ' + nomFichier);

  err := FichierTexteDeCassioExiste(nomFichier,fic);
  if (err <> NoErr) then goto sortie;


  err := OuvreFichierTexte(fic);
  if (err <> NoErr) then goto sortie;


  compteurMots := 0;

  repeat
    err := ReadlnDansFichierTexte(fic,s);

    // WritelnDansRapport(s);

    if (LENGTH_OF_STRING(s) = 25) then
       WritelnDansRapport(MyUpperString(s,false));

    s := EnleveEspacesDeGauche(s);

    if (err = NoErr) & (s <> '') & (s[1] <> '#') & (s[1] <> '%') then
      begin
        inc(compteurMots);

        AjouterMotFrancais(MyUpperString(s,false));

      end;

  until (err <> NoErr) | EOFFichierTexte(fic,err);

  err := FermeFichierTexte(fic);
  if (err <> NoErr) then goto sortie;

  sortie :

  WritelnNumDansRapport('temps de lecture du dictionnaire = ',Tickcount - ticks);

  WritelnNumDansRapport('Sortie de LireDictionnaireDesMotsFrancais :  err = ',err);

end;


function UTF8ToAscii(const s : String255) : String255;     external;
  procedure ReplaceCharByCharInString(var s : String255; old, new : char);     external;
  function ReplaceStringByStringInString(const pattern,replacement,s : String255) : String255;     external;


procedure LireEnigmePetitPoucet(nomFichier : String255);
var fic : FichierTEXT;
    err : OSErr;
    s : String255;
    c : char;
    compteurMots : SInt32;
    ticks, k, t : SInt32;
   //  l : SInt32;
    compteurCaracteres : SInt32;
    occ : array[0..255] of SInt32;
label sortie;
begin

  ticks := TickCount;

  WritelnDansRapport('Entree dans LireEnigmePetitPoucet :  lecture de ' + nomFichier);

  err := FichierTexteDeCassioExiste(nomFichier,fic);
  if (err <> NoErr) then goto sortie;


  err := OuvreFichierTexte(fic);
  if (err <> NoErr) then goto sortie;


  compteurMots := 0;
  compteurCaracteres := 0;



  repeat
    err := ReadlnDansFichierTexte(fic,s);

    // WritelnDansRapport(s);

    if (LENGTH_OF_STRING(s) = 25) then
       WritelnDansRapport(MyUpperString(s,false));

    s := EnleveEspacesDeGauche(s);
    s := UTF8ToAscii(s);

    if (err = NoErr) & (s <> '') & (s[1] <> '#') & (s[1] <> '%') then
      begin
        inc(compteurMots);

        // AjouterMotFrancais(MyUpperString(s,false));

        ReplaceCharByCharInString(s, ',' , ' ');
        ReplaceCharByCharInString(s, '.' , ' ');
        ReplaceCharByCharInString(s, '!' , ' ');
        ReplaceCharByCharInString(s, ':' , ' ');
        ReplaceCharByCharInString(s, '?' , ' ');
        ReplaceCharByCharInString(s, '''' , ' ');
        ReplaceCharByCharInString(s, '-' , ' ');

        for k := 1 to 100 do
          s := ReplaceStringByStringInString(' ','',s);



        s := MyUpperString(s, false);

        WritelnDansRapport(s);

        for k := 0 to 255 do occ[k] := 0;

        for k := 1 to LENGTH_OF_STRING(s) do
          begin
            c := s[k];
            if (c >= 'A') & (c <= 'Z') then
            //if (c <> ' ') then
              begin
                inc(compteurCaracteres);


                t := compteurCaracteres;

                (*
                if (t in [0, 1, 2, 6, 7, 8, 10, 13,  19, 100, 106]) then
                   WritelnNumDansRapport('    ########  ' + c + '  ##########  ', t);
                *)

                (*
                if compteurCaracteres <= 2000 then
                 WritelnNumDansRapport(c + '  ==>  ', compteurCaracteres);
                 *)

                inc(occ[ord(c)]);
              end;
          end;

        (*
        for l := 20 downto 1 do
          for k := ord('A') to ord('Z') do
            if (occ[k] = l) then
              WritelnNumDansRapport(chr(k) + '  ==>  ',occ[k]);
        *)

      end;

  until (err <> NoErr) | EOFFichierTexte(fic,err);

  err := FermeFichierTexte(fic);
  if (err <> NoErr) then goto sortie;

  sortie :

  WritelnNumDansRapport('temps de lecture de l''enigme = ',Tickcount - ticks);

  WritelnNumDansRapport('Sortie de LireEnigmePetitPoucet :  err = ',err);

end;

procedure AllouerMemoireCryptographie;
var i : SInt32;
begin
  with crypto do
    begin

      nbEntreesHashTable := 1;
      nbEntreesHashTable := (nbEntreesHashTable SHL 20);
      WritelnNumDansRapport('nbEntreesHashTable = ',nbEntreesHashTable * 32);
      hashTable  := LongintArrayPtr(AllocateMemoryPtrClear(nbEntreesHashTable * 4));
      hashTable2 := LongintArrayPtr(AllocateMemoryPtrClear(nbEntreesHashTable * 4));

      for i := 0 to kLONGUEUR_MAX_MOT do
        begin
          nombreDeMotsDeCetteLongueur[i] := 0;
          lettresEnTas[i] := NIL;
        end;

      lettresEnTas[1] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 3));
      lettresEnTas[2] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 182));
      lettresEnTas[3] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 1407));
      lettresEnTas[4] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 8256));
      lettresEnTas[5] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 34060));
      lettresEnTas[6] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 94572));
      lettresEnTas[7] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 195615));
      lettresEnTas[8] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 326456));
      lettresEnTas[9] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 445824));
      lettresEnTas[10] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 514020));
      lettresEnTas[11] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 512127));
      lettresEnTas[12] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 441300));
      lettresEnTas[13] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 333047));
      lettresEnTas[14] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 219086));
      lettresEnTas[15] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 130950));
      lettresEnTas[16] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 70688));
      lettresEnTas[17] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 36040));
      lettresEnTas[18] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 17586));
      lettresEnTas[19] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 8303));
      lettresEnTas[20] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 4100));
      lettresEnTas[21] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 1974));
      lettresEnTas[22] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 924));
      lettresEnTas[23] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 253));
      lettresEnTas[24] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 96));
      lettresEnTas[25] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 50));
      lettresEnTas[26] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 0));
      lettresEnTas[27] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 0));
      lettresEnTas[28] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 0));
      lettresEnTas[29] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 0));
      lettresEnTas[30] := PackedArrayOfCharPtr(AllocateMemoryPtrClear(1024 + 0));

      dernierMotAjoute := 'blah';
    end;
end;


procedure LibererMemoireCryptographie;
var i : SInt32;
begin
  with crypto do
    begin
      if (hashTable <> NIL)  then DisposeMemoryPtr(Ptr(hashTable));
      if (hashTable2 <> NIL) then DisposeMemoryPtr(Ptr(hashTable2));

      for i := 0 to kLONGUEUR_MAX_MOT do
        begin
          nombreDeMotsDeCetteLongueur[i] := 0;

          if (lettresEnTas[i] <> NIL) then
            DisposeMemoryPtr(Ptr(lettresEnTas[i]));
        end;
    end;
end;


function DecalageEstPeriodique(decalage : decalageCrypto; longueurMot : SInt32; var longueurPeriode : SInt32) : boolean;
var periodique : boolean;
    k, j, T : SInt32;
begin

  periodique := false;

  for k := 2 to longueurMot do
    begin
      if (decalage[k] >= -1000) &
         (decalage[1] >= -1000) &
         (decalage[k] = decalage[1]) then
        begin

          T := (k - 1);  // periode potentielle

          periodique := true;

          for j := k to longueurMot do
            if (decalage[j] <> decalage[j - T])
              then periodique := false;

          if periodique then
            begin
              longueurPeriode := T;
              DecalageEstPeriodique := true;
              exit(DecalageEstPeriodique);
            end;

        end;
    end;

  DecalageEstPeriodique := periodique;
end;



function DecalageEnString(decalage : decalageCrypto; delta : SInt32) : String255;
var s : String255;
    c : char;
    t,x : SInt32;
begin

  s := '';

  for t := 1 to kLONGUEUR_MAX_DECALAGE do
    begin
      x := decalage[t] + delta;

      if (x >= -1000) then
        begin

          if (x < 0) then x := x + 26;
          if (x < 0) then x := x + 26;
          if (x < 0) then x := x + 26;

          if (x >= 26) then x := x - 26;
          if (x >= 26) then x := x - 26;
          if (x >= 26) then x := x - 26;

          c := chr(ord('A') + x);

          s := s + c;
        end;

    end;

  DecalageEnString := s;
end;


function EstUnMotFrancais(s : String255) : boolean;
var t,longueur : SInt32;
begin

  longueur := LENGTH_OF_STRING(s);

  for t := 1 to crypto.nombreDeMotsDeCetteLongueur[longueur] do
    begin
      if (s = GetNiemeMotDeCetteLongueur(t,longueur)) then
        begin
          EstUnMotFrancais := true;
          exit(EstUnMotFrancais);
        end;
    end;

  EstUnMotFrancais := false;
end;




procedure TesterCeMotCandidat(cryptogramme, musique : decalageCrypto;
                              motCandidat, motCandidatCrypte : String255;
                              decalageTemporel : SInt32;
                              var minimum : SInt32);
var len : SInt32;
    decalages : decalageCrypto;
    mots : array[1..5] of String255;
    n, t, longueurPeriode : SInt32;
    messageDecode : String255;
    reste : String255;
begin

  Discard2(cryptogramme, musique);
  Discard2(motCandidat, motCandidatCrypte);
  Discard2(decalageTemporel, minimum);
  Discard2(decalages, mots);
  Discard2(n, t);
  Discard2(longueurPeriode, messageDecode);
  Discard(reste);

  len := LENGTH_OF_STRING(motCandidatCrypte);

  (*

  CalculerLesDecalages(motCandidatCrypte, motCandidat, decalages);

  if DecalageEstPeriodique(decalages, len, longueurPeriode)
     & (longueurPeriode < len)
     // & (longueurPeriode < minimum)
    then
    begin

      minimum := longueurPeriode;




       messageDecode := '';

       for t := 1 to 26 do  // les 26 derniers lettres du message ( = 3 derniers mots )
         begin
           n := cryptogramme[12 + t]
                + musique[decalageTemporel + t]
                - decalages[1 + ((t - 1) mod longueurPeriode)]
                ;
           {WriteNumDansRapport(' ',n);}

           if (n < ord('A')) then n := n + 26;
           if (n < ord('A')) then n := n + 26;
           if (n > ord('Z')) then n := n - 26;
           if (n > ord('Z')) then n := n - 26;

           messageDecode := messageDecode + chr(n);

           if (t = 14) | (t = 16) then messageDecode := messageDecode + ' ';

         end;

        {WritelnDansRapport('');}

        Parser(messageDecode,mots[1],reste);
        Parser(reste,mots[2],reste);
        Parser(reste,mots[3],reste);



        if CeMotEstDansLaTableDeHachage(mots[3])
         //  & EstUnMotFrancais(mots[3])
             & (mots[3] <> gDernierMotSolutionAffiche)
            then
          begin
            gDernierMotSolutionAffiche := mots[3];
            WritelnDansRapport(messageDecode);
          end;



        // WritelnDansRapport(''+messageDecode);
    end;
  *)




end;



procedure AttaquerLeDecryptage(musiqueString : String255; longueurMusique : SInt32);
var s,motCandidatCrypte : String255;
    motCandidat : String255;
    cryptogrammeString : String255;
    musique : decalageCrypto;
    cryptogramme : decalageCrypto;
    numeroDansDico, n, t : SInt32;

    decalageTemporel : SInt32;
    minimum : SInt32;
    longueurMotCandidat : SInt32;
begin

  Discard(numeroDansDico);



  cryptogrammeString := '78 50 67 87 26 8 19 64 5 57 18 17 13 14 15 43 33 12 49 31 66 84 63 70 16 46 10 9 50 73 35 88 89 87 39 6 82 56';

  WritelnDansRapport('');

  WriteDansRapport('musique = ');
  for t := 1 to kLONGUEUR_MAX_DECALAGE do
    musique[t] := 0;
  for t := 1 to longueurMusique do
    begin
      Parser(musiqueString, s, musiqueString);
      musique[t] := ChaineEnLongint(s);
      WriteNumDansRapport(' ',musique[t]);
    end;
  WritelnDansRapport('');

  for t := 1 to longueurMusique do
    begin
      musique[longueurMusique + t] := musique[t];
      // musique[64 + t] := musique[t];
    end;

  WriteDansRapport('cryptogramme = ');
  for t := 1 to kLONGUEUR_MAX_DECALAGE do
    cryptogramme[t] := 0;
  for t := 1 to 38 do
    begin
      Parser(cryptogrammeString, s, cryptogrammeString);
      cryptogramme[t] := ord('A') + (ChaineEnLongint(s) mod 26);
      WriteDansRapport(chr(cryptogramme[t]));
    end;
  WritelnDansRapport('');

  (*
  s := 'AAAAAAAAAAAAQUESTIONNAIRESAURESTAURANT';
  for t := 1 to 38 do
    cryptogramme[t] := ord(s[t]);
  *)


  minimum := 1000;

  for decalageTemporel := 0 to 80 do
    begin

      motCandidatCrypte := '';
      for t := 1 to 16 do
        begin

          n := cryptogramme[12 + t]  + musique[decalageTemporel + t];

          if (n < ord('A')) then n := n + 26;
          if (n < ord('A')) then n := n + 26;
          if (n > ord('Z')) then n := n - 26;
          if (n > ord('Z')) then n := n - 26;

          motCandidatCrypte := motCandidatCrypte + chr(n);
        end;


      // WritelnDansRapport('motCandidatCrypte = '+motCandidatCrypte);

      longueurMotCandidat := LENGTH_OF_STRING(motCandidatCrypte);

      (*
      s := 'INTITULASSIONS';
      TesterCeMotCandidat(cryptogramme, musique, s + 'ME' , motCandidatCrypte, decalageTemporel, minimum);
      *)


      for numeroDansDico := 1 to crypto.nombreDeMotsDeCetteLongueur[14] do
        begin
          s := GetNiemeMotDeCetteLongueur(numeroDansDico,14);

          motCandidat := s + 'AU';
          TesterCeMotCandidat(cryptogramme, musique, motCandidat , motCandidatCrypte, decalageTemporel, minimum);


          (*
          TesterCeMotCandidat(cryptogramme, musique, s + 'CE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'DE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'DU' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'EN' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'ES' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'ET' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'EU' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'IL' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'JE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'LA' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'LE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'MA' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'ME' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'NE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'NI' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'OR' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'OU' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'SA' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'SE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'TA' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'TE' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'TU' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'UN' , motCandidatCrypte, decalageTemporel, minimum);
          TesterCeMotCandidat(cryptogramme, musique, s + 'VA' , motCandidatCrypte, decalageTemporel, minimum);
          *)

        end;



    end;

  WritelnDansRapport('');
  WritelnDansRapport('fin de la tentative de décryptage');
end;


procedure Cryptographie;
var k,n : SInt32;
    (* mot : String255; *)
    musiqueString : String255;
    longueurMusique : SInt32;
begin
  Discard2(k,n);

  AllouerMemoireCryptographie;

  LireDictionnaireDesMotsFrancais('liste-de-mots.txt');

  (*
  for k := 0 to kLONGUEUR_MAX_MOT do
    WritelnNumDansRapport(NumEnString(k) + ' := ' , crypto.nombreDeMotsDeCetteLongueur[k]);

  for k := 0 to kLONGUEUR_MAX_MOT do
    for n := 1 to 10 do
      WritelnDansRapport(NumEnString(k) + ' := ' + GetNiemeMotDeCetteLongueur(n,k));
  *)

  (*
  for n := 1 to crypto.nombreDeMotsDeCetteLongueur[2] do
    WritelnDansRapport(GetNiemeMotDeCetteLongueur(n,2));
  *)

  (*
  if CeMotEstDansLaTableDeHachage('RESTAURANT')
    then WritelnDansRapport('RESTAURANT : OK')
    else WritelnDansRapport('RESTAURANT : NON');

  if CeMotEstDansLaTableDeHachage('OBAWZXQKYB')
    then WritelnDansRapport('OBAWZXQKYB : OK')
    else WritelnDansRapport('OBAWZXQKYB : NON');

  if CeMotEstDansLaTableDeHachage('MRSENGAKYL')
    then WritelnDansRapport('MRSENGAKYL : OK')
    else WritelnDansRapport('MRSENGAKYL : NON');

  if CeMotEstDansLaTableDeHachage('DECRYPTAGE')
    then WritelnDansRapport('DECRYPTAGE : OK')
    else WritelnDansRapport('DECRYPTAGE : NON');

  if CeMotEstDansLaTableDeHachage('ARSENGAKYL')
    then WritelnDansRapport('ARSENGAKYL : OK')
    else WritelnDansRapport('ARSENGAKYL : NON');
  *)

  {
  musiqueString      := '0 0 0 0 -1 0 1 -1 -1 -1 -1 -1 -1 0 1   2 0 0 0 0 -1 0 1 -1 -1 -1 -1 -1 -1 -2 -3 -2';
  longueurMusique := 32;
  AttaquerLeDecryptage(musiqueString,longueurMusique);
  }

  // en demi tons ?
  {
  musiqueString      := '0 0 0 0 -2 0 1 -2 -2 -2 -2 -2 -2 0 1   3 0 0 0 0 -2 0 1 -2 -2 -2 -2 -2 -2 -4 -5 -4';
  longueurMusique := 32;
  AttaquerLeDecryptage(musiqueString,longueurMusique);
  }

  // avec les bemols ?
  {
  musiqueString      := '2 5 1   0 0 0 0 -1 0 1 -1 -1 -1 -1 -1 -1 0 1  2 5 1   2 0 0 0 0 -1 0 1 -1 -1 -1 -1 -1 -1 -2 -3 -2';
  longueurMusique := 38;
  AttaquerLeDecryptage(musiqueString,longueurMusique);
  }

  // avec les bemols, et en demi tons ?

  musiqueString      := '3 8 1   0 0 0 0 -2 0 1 -2 -2 -2 -2 -2 -2 0 1  3 8 1   3 0 0 0 0 -2 0 1 -2 -2 -2 -2 -2 -2 -4 -5 -4';
  longueurMusique := 38;
  AttaquerLeDecryptage(musiqueString,longueurMusique);

  LibererMemoireCryptographie;
end;



procedure AttendFrappeClavier;     external;
procedure SetEcritToutDansRapportLog(flag : boolean);     external;


const kNbMotCroises = 10;
var motCroise : record
                  longueur                : array[1..kNbMotCroises] of SInt32;
                  mot                     : array[1..kNbMotCroises] of String255;
                  extraits                : array[1..4] of String255;

                  nbOfSolutions           : SInt32;
                  derniereSolutionPubliee : String255;
                end;


procedure InitMotsCroises;
var k : SInt32;
begin
  with motCroise do
    begin

      nbOfSolutions := 0;

      for k := 1 to kNbMotCroises do
        mot[k] := '';

      longueur[1] := 9;
      longueur[2] := 8;
      longueur[3] := 7;
      longueur[4] := 5;

      longueur[5] := 6;
      longueur[6] := 5;
      longueur[7] := 5;

      longueur[8] := 5;

      longueur[9] := 4;
      longueur[10] := 8;

      derniereSolutionPubliee := '';
    end;
end;


procedure ExtraireMotsColores;
begin
  with motCroise do
    begin

      extraits[1] := '';
      extraits[2] := '';
      extraits[3] := '';
      extraits[4] := '';

      if (mot[1] <> '') & (mot[5] <> '') & (mot[3] <> '') & (mot[6] <> '')
        then extraits[1] := mot[1][7] + mot[5][1] + mot[3][2] + mot[6][1];  // vert

      if (mot[8] <> '') & (mot[7] <> '') & (mot[10] <> '')
        then extraits[2] := mot[8][4] + mot[7][2] + mot[10][1] ;            // gris

      if (mot[9] <> '') & (mot[7] <> '') & (mot[6] <> '')
        then extraits[3] := mot[9][3] + mot[7][1] + mot[6][2];             // orange

      if (mot[2] <> '')
        then extraits[4] := mot[2][8];                                      // jaune
    end;
end;


function CheckContraintes : boolean;
var k : SInt32;
    // RERFound : boolean;

  procedure Failure;
  begin
    CheckContraintes := false;
    exit(CheckContraintes);
  end;

begin
  with motCroise do
    begin
      for k := 1 to kNbMotCroises do
        begin
          if (mot[k] <> '') & (LENGTH_OF_STRING(mot[k]) <> longueur[k])
            then Failure;
        end;


      // contrainte de mots devines

      // if (mot[2] <> '') & (mot[2] <> 'AUTORAIL') then Failure;

      // contraintes de croisements

      if (mot[1] <> '') & (mot[2] <> '') & (mot[1][1] <> mot[2][1]) then Failure;

      if (mot[1] <> '') & (mot[4] <> '') & (mot[1][5] <> mot[4][1]) then Failure;

      if (mot[2] <> '') & (mot[3] <> '') & (mot[2][5] <> mot[3][1]) then Failure;

      if (mot[3] <> '') & (mot[4] <> '') & (mot[3][5] <> mot[4][5]) then Failure;

      if (mot[3] <> '') & (mot[5] <> '') & (mot[3][7] <> mot[5][3]) then Failure;

      if (mot[5] <> '') & (mot[8] <> '') & (mot[5][1] <> mot[8][1]) then Failure;

      if (mot[5] <> '') & (mot[10] <> '') & (mot[5][6] <> mot[10][3]) then Failure;


      if (mot[2] <> '') & (mot[9] <> '') & (mot[2][4] <> mot[9][2]) then Failure;


      if (mot[2] <> '') & (mot[6] <> '') & (mot[2][7] <> mot[6][3]) then Failure;

      if (mot[6] <> '') & (mot[7] <> '') & (mot[6][1] <> mot[7][3]) then Failure;


      // contrainte de L'ALMA ?

      (*
      if (mot[1] <> '') & (mot[1][7] <> 'A') & (mot[1][7] <> 'L') & (mot[1][7] <> 'M') then Failure;
      if (mot[3] <> '') & (mot[3][2] <> 'A') & (mot[3][2] <> 'L') & (mot[3][2] <> 'M') then Failure;
      if (mot[5] <> '') & (mot[5][1] <> 'A') & (mot[5][1] <> 'L') & (mot[5][1] <> 'M') then Failure;
      if (mot[6] <> '') & (mot[6][1] <> 'A') & (mot[6][1] <> 'L') & (mot[6][1] <> 'M') then Failure;
      *)


      // contrainte du RER orange ?

      (*
      if (mot[6] <> '') & (mot[6][2] <> 'R') & (mot[6][2] <> 'E') then Failure;
      if (mot[7] <> '') & (mot[7][1] <> 'R') & (mot[7][1] <> 'E') then Failure;
      if (mot[9] <> '') & (mot[9][3] <> 'R') & (mot[9][3] <> 'E') then Failure;
      *)


      // Contrainte du L apostrophe ?

      (*
      if (mot[2] <> '') & ((mot[2][8] <> 'L') & (mot[2][8] <> 'C')) then Failure;
      *)


      ExtraireMotsColores;

      // Changer de mot 3 à trouver ?

      (*
      if (LENGTH_OF_STRING(extraits[2]) = 3) & (extraits[2] = derniereSolutionPubliee) then Failure;
      *)


      // contrainte de L'ALMA ?

      (*
      if (LENGTH_OF_STRING(extraits[1]) = 4) then
        begin
          if (CompterOccurencesDeSousChaine('A',extraits[1]) <> 2) |
             (Pos('L',extraits[1]) = 0) |
             (Pos('M',extraits[1]) = 0) then
            begin
               Failure;
            end;
        end;
      *)

      // contrainte du RER vert ou orange ?

      (*
      if (LENGTH_OF_STRING(extraits[2]) = 3) & (LENGTH_OF_STRING(extraits[3]) = 3) then
        begin
           RERFound := false;


           if (CompterOccurencesDeSousChaine('R',extraits[2]) = 2) &
              (CompterOccurencesDeSousChaine('E',extraits[2]) = 1) &
               EstUnMotFrancais(extraits[3])
              then RERFound := true;


           if (CompterOccurencesDeSousChaine('R',extraits[3]) = 2) &
              (CompterOccurencesDeSousChaine('E',extraits[3]) = 1) &
              EstUnMotFrancais(extraits[2])
              then RERFound := true;


           if not(RERFound) then Failure;

        end;
      *)


      // AttendFrappeClavier;

      // solution trouvée !!!
      CheckContraintes := true;
    end;
end;

procedure PublishSolutionMotCroises;
var k : SInt32;
    s : String255;
begin
  with motCroise do
    begin


      kWNESleep := 0;


      ExtraireMotsColores;

      s := '';
      for k := 1 to 4 do
        s := s + ' ' + extraits[k];

      (* if (extraits[2] <> derniereSolutionPubliee)  then *)

        begin



          derniereSolutionPubliee := s;

          derniereSolutionPubliee := extraits[2];

          WritelnDansRapport('');
          WriteDansRapport('Solution :  ');

          for k := 1 to kNbMotCroises do
            WriteDansRapport(mot[k] + ' ');

          WritelnDansRapport('');
          WritelnDansRapport('    =>   ' + s);

          inc(nbOfSolutions);

        end;
    end;
end;

procedure SolveMotsCroises(numeroMotActif : SInt32);
const kNbSolutionsAAfficher = 10000000;
var len, k : SInt32;
begin
  with motCroise do
    begin

      // WritelnNumDansRapport('solve : ',numeroMotActif);

      if (numeroMotActif > kNbMotCroises) then
        exit(SolveMotsCroises);

      if (nbOfSolutions > kNbSolutionsAAfficher) then
        exit(SolveMotsCroises);

      len := longueur[numeroMotActif];

      (*
      WritelnNumDansRapport('len = ',len);

      WritelnNumDansRapport('crypto.nombreDeMotsDeCetteLongueur[len] = ',crypto.nombreDeMotsDeCetteLongueur[len]);
      *)

      PublishSolutionMotCroises;
      AttendFrappeClavier;


      (*
      if FALSE & (numeroMotActif = 2)
        then
          begin
            mot[numeroMotActif] := 'AUTORAIL';

            if CheckContraintes then
              SolveMotsCroises( numeroMotActif + 1);

          end
        else
      *)

          begin
            for k := 1 to crypto.nombreDeMotsDeCetteLongueur[len] do
              begin



                mot[numeroMotActif] := GetNiemeMotDeCetteLongueur( k , len );

                // PublishSolutionMotCroises;
                // AttendFrappeClavier;

                if CheckContraintes then
                  begin
                    if numeroMotActif >= kNbMotCroises
                      then
                        begin
                          PublishSolutionMotCroises;
                        end
                      else
                        SolveMotsCroises( numeroMotActif + 1);
                  end;


                if (nbOfSolutions > kNbSolutionsAAfficher) then
                  exit(SolveMotsCroises);

              end;


          end;


      mot[numeroMotActif] := '';




    end;
end;


procedure EcrireMotsDeCinqLettresAvecCesCaracteres(c1,c2 : char);
var t : SInt32;
begin

  WritelnDansRapport('');
  WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
  WritelnDansRapport('');

  (*
  for t := 1 to crypto.nombreDeMotsDeCetteLongueur[5] do
    WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,5));
    *)

  for t := 1 to crypto.nombreDeMotsDeCetteLongueur[5] do
    if (GetNiemeMotDeCetteLongueur(t,5)[3] = c1) &
       (GetNiemeMotDeCetteLongueur(t,5)[5] = c2)
      then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,5));
end;


procedure EcrireMotsDeOnzeLettres;
var t,j,k : SInt32;
    c1,c2 : char;
    s : String255;
begin

  s := 'CARDINET';

  for j := 1 to 8 do
    for k := j + 1 to 8 do
      begin

        c1 := s[j];
        c2 := s[k];

        WritelnDansRapport('');
        WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
        WritelnDansRapport('');

        for t := 1 to crypto.nombreDeMotsDeCetteLongueur[11] do
          if (GetNiemeMotDeCetteLongueur(t,11)[5] = 'T') &
             (GetNiemeMotDeCetteLongueur(t,11)[7] = c1) &
             (GetNiemeMotDeCetteLongueur(t,11)[11] = c2)
            then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,11));

      end;
end;


procedure EcrireMotsDeSeptLettresCommencantParO;
var t,j : SInt32;
    c1,c2 : char;
    s : String255;
begin

  s := 'CARDINET';

  c1 := 'O';

  for j := 1 to LENGTH_OF_STRING(s) do
    begin

      c2 := s[j];

      WritelnDansRapport('');
      WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
      WritelnDansRapport('');

      for t := 1 to crypto.nombreDeMotsDeCetteLongueur[7] do
        if (GetNiemeMotDeCetteLongueur(t,7)[1] = c1) &
           (GetNiemeMotDeCetteLongueur(t,7)[7] = c2)
          then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,7));

    end;

end;


procedure EcrireMotsDeSeptLettresTerminantParO;
var t,j : SInt32;
    c1,c2 : char;
    s : String255;
begin

  s := 'CARDINET';

  c1 := 'O';

  for j := 1 to LENGTH_OF_STRING(s) do
    begin

      c2 := s[j];

      WritelnDansRapport('');
      WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
      WritelnDansRapport('');

      for t := 1 to crypto.nombreDeMotsDeCetteLongueur[7] do
        if (GetNiemeMotDeCetteLongueur(t,7)[7] = c1) &
           (GetNiemeMotDeCetteLongueur(t,7)[1] = c2)
          then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,7));

    end;

end;

procedure EcrireMotsDeSeptLettres;
var t,j : SInt32;
    c1,c2 : char;
    s : String255;
begin

  s := 'CRDNET';


  c1 := 'P';

  for j := 1 to LENGTH_OF_STRING(s) do
    begin

      c2 := s[j];

      WritelnDansRapport('');
      WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
      WritelnDansRapport('');

      for t := 1 to crypto.nombreDeMotsDeCetteLongueur[7] do
        if (GetNiemeMotDeCetteLongueur(t,7)[2] = 'I') &
           (GetNiemeMotDeCetteLongueur(t,7)[1] = c1) &
           (GetNiemeMotDeCetteLongueur(t,7)[7] = c2)
          then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,7));

    end;

  (*
  c1 := 'O';

  for j := 1 to LENGTH_OF_STRING(s) do
    begin

      c2 := s[j];

      WritelnDansRapport('');
      WritelnDansRapport('couple  ' + c1 + '/' + c2 + '  :');
      WritelnDansRapport('');

      for t := 1 to crypto.nombreDeMotsDeCetteLongueur[7] do
        if (GetNiemeMotDeCetteLongueur(t,7)[2] = 'I') &
           (GetNiemeMotDeCetteLongueur(t,7)[1] = c1) &
           (GetNiemeMotDeCetteLongueur(t,7)[7] = c2)
          then WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,7));

    end;
  *)

end;






procedure DecrypterGrilleDuRallye2011;
var len, t : SInt32;
begin

  Discard2(t,len);

  WritelnDansRapport('Entree dans DecrypterGrilleDuRallye2011...');



  AllouerMemoireCryptographie;

  //LireDictionnaireDesMotsFrancais('liste-de-mots.txt');

  //LireDictionnaireDesMotsFrancais('metro.txt');

  // LireDictionnaireDesMotsFrancais('petite-ceinture.txt');

  // LireDictionnaireDesMotsFrancais('noms-propres-de-paris.txt');

  LireEnigmePetitPoucet('petit-poucet.txt');

  // EcrireMotsDeOnzeLettres;

  //EcrireMotsDeSeptLettres;

  // EcrireMotsDeSeptLettresCommencantParO;

  // EcrireMotsDeSeptLettresTerminantParO;


  // EcrireMotsDeCinqLettresAvecCesCaracteres('P','O');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('O','P');

  // EcrireMotsDeCinqLettresAvecCesCaracteres('P','N');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('N','P');

  // EcrireMotsDeCinqLettresAvecCesCaracteres('P','T');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('T','P');

  // EcrireMotsDeCinqLettresAvecCesCaracteres('O','N');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('N','O');

  // EcrireMotsDeCinqLettresAvecCesCaracteres('O','T');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('T','O');

  // EcrireMotsDeCinqLettresAvecCesCaracteres('N','T');
  // EcrireMotsDeCinqLettresAvecCesCaracteres('T','N');


  // LireDictionnaireDesMotsFrancais('communes-suisses-nettoyees.txt');
  // LireDictionnaireDesMotsFrancais('cummunes-valais.txt');
  // LireDictionnaireDesMotsFrancais('liste-de-mots.txt');
  /// LireDictionnaireDesMotsFrancais('simplon.txt');

  (*
  for len := 4 to 9 do
    for t := 1 to crypto.nombreDeMotsDeCetteLongueur[len] do
      WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,len));
  *)

  (*
  for t := 1 to crypto.nombreDeMotsDeCetteLongueur[8] do
    if GetNiemeMotDeCetteLongueur(t,8)[8] = 'L' then
      WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,8));

  for t := 1 to crypto.nombreDeMotsDeCetteLongueur[8] do
    if GetNiemeMotDeCetteLongueur(t,8)[8] = 'C' then
      WritelnDansRapport(GetNiemeMotDeCetteLongueur(t,8));

  *)

  (*
  SetEcritToutDansRapportLog(true);

  kWNESleep := 0;

  InitMotsCroises;

  SolveMotsCroises(1);

  SetEcritToutDansRapportLog(false);
  *)


  LibererMemoireCryptographie;

  WritelnDansRapport('Sortie de DecrypterGrilleDuRallye2011');
end;



END.
