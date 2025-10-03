UNIT EdmondPatterns;


INTERFACE

 USES UnitDefCassio;



  //clear
     procedure ClearEdmondPatterns;                                                                                                                                                 ATTRIBUTE_NAME('ClearEdmondPatterns')

	//set Black disc on a square
		 procedure Edmond_set_BLACK_A1;  procedure Edmond_set_BLACK_B1;  procedure Edmond_set_BLACK_C1;  procedure Edmond_set_BLACK_D1;  procedure Edmond_set_BLACK_E1;  procedure Edmond_set_BLACK_F1;  procedure Edmond_set_BLACK_G1;  procedure Edmond_set_BLACK_H1;             ATTRIBUTE_NAME('Edmond_set_BLACK_A1')
		 procedure Edmond_set_BLACK_A2;  procedure Edmond_set_BLACK_B2;  procedure Edmond_set_BLACK_C2;  procedure Edmond_set_BLACK_D2;  procedure Edmond_set_BLACK_E2;  procedure Edmond_set_BLACK_F2;  procedure Edmond_set_BLACK_G2;  procedure Edmond_set_BLACK_H2;             ATTRIBUTE_NAME('Edmond_set_BLACK_A2')
		 procedure Edmond_set_BLACK_A3;  procedure Edmond_set_BLACK_B3;  procedure Edmond_set_BLACK_C3;  procedure Edmond_set_BLACK_D3;  procedure Edmond_set_BLACK_E3;  procedure Edmond_set_BLACK_F3;  procedure Edmond_set_BLACK_G3;  procedure Edmond_set_BLACK_H3;             ATTRIBUTE_NAME('Edmond_set_BLACK_A3')
		 procedure Edmond_set_BLACK_A4;  procedure Edmond_set_BLACK_B4;  procedure Edmond_set_BLACK_C4;  procedure Edmond_set_BLACK_D4;  procedure Edmond_set_BLACK_E4;  procedure Edmond_set_BLACK_F4;  procedure Edmond_set_BLACK_G4;  procedure Edmond_set_BLACK_H4;             ATTRIBUTE_NAME('Edmond_set_BLACK_A4')
		 procedure Edmond_set_BLACK_A5;  procedure Edmond_set_BLACK_B5;  procedure Edmond_set_BLACK_C5;  procedure Edmond_set_BLACK_D5;  procedure Edmond_set_BLACK_E5;  procedure Edmond_set_BLACK_F5;  procedure Edmond_set_BLACK_G5;  procedure Edmond_set_BLACK_H5;             ATTRIBUTE_NAME('Edmond_set_BLACK_A5')
		 procedure Edmond_set_BLACK_A6;  procedure Edmond_set_BLACK_B6;  procedure Edmond_set_BLACK_C6;  procedure Edmond_set_BLACK_D6;  procedure Edmond_set_BLACK_E6;  procedure Edmond_set_BLACK_F6;  procedure Edmond_set_BLACK_G6;  procedure Edmond_set_BLACK_H6;             ATTRIBUTE_NAME('Edmond_set_BLACK_A6')
		 procedure Edmond_set_BLACK_A7;  procedure Edmond_set_BLACK_B7;  procedure Edmond_set_BLACK_C7;  procedure Edmond_set_BLACK_D7;  procedure Edmond_set_BLACK_E7;  procedure Edmond_set_BLACK_F7;  procedure Edmond_set_BLACK_G7;  procedure Edmond_set_BLACK_H7;             ATTRIBUTE_NAME('Edmond_set_BLACK_A7')
		 procedure Edmond_set_BLACK_A8;  procedure Edmond_set_BLACK_B8;  procedure Edmond_set_BLACK_C8;  procedure Edmond_set_BLACK_D8;  procedure Edmond_set_BLACK_E8;  procedure Edmond_set_BLACK_F8;  procedure Edmond_set_BLACK_G8;  procedure Edmond_set_BLACK_H8;             ATTRIBUTE_NAME('Edmond_set_BLACK_A8')

	//set White disc on a square
		 procedure Edmond_set_WHITE_A1;  procedure Edmond_set_WHITE_B1;  procedure Edmond_set_WHITE_C1;  procedure Edmond_set_WHITE_D1;  procedure Edmond_set_WHITE_E1;  procedure Edmond_set_WHITE_F1;  procedure Edmond_set_WHITE_G1;  procedure Edmond_set_WHITE_H1;             ATTRIBUTE_NAME('Edmond_set_WHITE_A1')
		 procedure Edmond_set_WHITE_A2;  procedure Edmond_set_WHITE_B2;  procedure Edmond_set_WHITE_C2;  procedure Edmond_set_WHITE_D2;  procedure Edmond_set_WHITE_E2;  procedure Edmond_set_WHITE_F2;  procedure Edmond_set_WHITE_G2;  procedure Edmond_set_WHITE_H2;             ATTRIBUTE_NAME('Edmond_set_WHITE_A2')
		 procedure Edmond_set_WHITE_A3;  procedure Edmond_set_WHITE_B3;  procedure Edmond_set_WHITE_C3;  procedure Edmond_set_WHITE_D3;  procedure Edmond_set_WHITE_E3;  procedure Edmond_set_WHITE_F3;  procedure Edmond_set_WHITE_G3;  procedure Edmond_set_WHITE_H3;             ATTRIBUTE_NAME('Edmond_set_WHITE_A3')
		 procedure Edmond_set_WHITE_A4;  procedure Edmond_set_WHITE_B4;  procedure Edmond_set_WHITE_C4;  procedure Edmond_set_WHITE_D4;  procedure Edmond_set_WHITE_E4;  procedure Edmond_set_WHITE_F4;  procedure Edmond_set_WHITE_G4;  procedure Edmond_set_WHITE_H4;             ATTRIBUTE_NAME('Edmond_set_WHITE_A4')
		 procedure Edmond_set_WHITE_A5;  procedure Edmond_set_WHITE_B5;  procedure Edmond_set_WHITE_C5;  procedure Edmond_set_WHITE_D5;  procedure Edmond_set_WHITE_E5;  procedure Edmond_set_WHITE_F5;  procedure Edmond_set_WHITE_G5;  procedure Edmond_set_WHITE_H5;             ATTRIBUTE_NAME('Edmond_set_WHITE_A5')
		 procedure Edmond_set_WHITE_A6;  procedure Edmond_set_WHITE_B6;  procedure Edmond_set_WHITE_C6;  procedure Edmond_set_WHITE_D6;  procedure Edmond_set_WHITE_E6;  procedure Edmond_set_WHITE_F6;  procedure Edmond_set_WHITE_G6;  procedure Edmond_set_WHITE_H6;             ATTRIBUTE_NAME('Edmond_set_WHITE_A6')
		 procedure Edmond_set_WHITE_A7;  procedure Edmond_set_WHITE_B7;  procedure Edmond_set_WHITE_C7;  procedure Edmond_set_WHITE_D7;  procedure Edmond_set_WHITE_E7;  procedure Edmond_set_WHITE_F7;  procedure Edmond_set_WHITE_G7;  procedure Edmond_set_WHITE_H7;             ATTRIBUTE_NAME('Edmond_set_WHITE_A7')
		 procedure Edmond_set_WHITE_A8;  procedure Edmond_set_WHITE_B8;  procedure Edmond_set_WHITE_C8;  procedure Edmond_set_WHITE_D8;  procedure Edmond_set_WHITE_E8;  procedure Edmond_set_WHITE_F8;  procedure Edmond_set_WHITE_G8;  procedure Edmond_set_WHITE_H8;             ATTRIBUTE_NAME('Edmond_set_WHITE_A8')

  //set BLACK and WHITE discs
     procedure Edmond_set_BLACK( square : SInt32 );                                                                                                                                 ATTRIBUTE_NAME('Edmond_set_BLACK')
     procedure Edmond_set_WHITE( square : SInt32 );                                                                                                                                 ATTRIBUTE_NAME('Edmond_set_WHITE')


  //calculate Edmond patterns
     procedure EdmondCalculatePatterns(var position : plateauOthello);                                                                                                              ATTRIBUTE_NAME('EdmondCalculatePatterns')


  //check the correspondance between Cassio and Edmond patterns
     procedure CheckPatternCorrespondance(indexCassio ,  indexBruno ,  nbreCasesDuPattern : SInt32; const nomDuPattern : String255);                                                ATTRIBUTE_NAME('CheckPatternCorrespondance')
     procedure CheckCassioEdmondPatterns(var position : plateauOthello; var frontiere : InfoFront);                                                                                 ATTRIBUTE_NAME('CheckCassioEdmondPatterns')



IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    EdmondEvaluation, UnitRapport, ImportEdmond, UnitBords, MyStrings ;
{$ELSEC}
    {$I prelink/EdmondPatterns.lk}
{$ENDC}


{END_USE_CLAUSE}









procedure EdmondCalculatePatterns(var position : plateauOthello);
var i ,  square : SInt32;
begin
  ClearEdmondPatterns;

  for i := 1 to 64 do
    begin
      square := othellier[i];

      if position[square] = pionNoir then Edmond_set_BLACK(square) else
      if position[square] = pionBlanc then Edmond_set_WHITE(square);

    end;
end;


procedure CheckPatternCorrespondance(indexCassio ,  indexBruno ,  nbreCasesDuPattern : SInt32; const nomDuPattern : String255);
var taille_du_pattern : SInt32;
    demi_taille_du_pattern : SInt32;
    indexTransformeParMonAlgo : SInt32;
    pattern : t_code_pattern;
    nbreTrous, nbPionsAmis, nbPionsEnnemis : SInt32;
    indexCassioDuMirroir : SInt32;
begin

  taille_du_pattern := TailleDUnPatternDeTantDeCases(nbreCasesDuPattern);
  demi_taille_du_pattern := (taille_du_pattern - 1) div 2;

  // vérifications d'intervalle

  if (indexCassio < -demi_taille_du_pattern) |
     (indexCassio > +demi_taille_du_pattern) then
    WritelnNumDansRapport('pattern de Cassio out of range : '+nomDuPattern+ ' = ' , indexCassio);

  if (indexBruno < 0) |
     (indexBruno > taille_du_pattern) then
    WritelnNumDansRapport('pattern de Bruno out of range : '+nomDuPattern+ ' = ' , indexBruno);

  // la bijection

  indexTransformeParMonAlgo := TransformePatternCassioVersBruno(indexCassio ,  nbreCasesDuPattern);


  // le resultat est-il dans le bon intervalle ?

  if (indexTransformeParMonAlgo < 0) |
     (indexTransformeParMonAlgo > taille_du_pattern) then
    WritelnNumDansRapport('pattern transforme par mon algo out of range : '+nomDuPattern+ ' = ' , indexTransformeParMonAlgo);


  if (indexTransformeParMonAlgo <> indexBruno) &
         ((Pos('diag', nomDuPattern) > 0) | (Pos('hv' , nomDuPattern) > 0))
    then
      begin

        // pour les patterns en ligne, il peut arriver que Cassio et Edmond aient
        // choisi des conventions d'orientation inverses (puissances de 3 et montant
        // ou en decendant : on essaye l'index du pattern miroir
        CoderPattern(indexCassio, pattern, nbreCasesDuPattern, nbreTrous, nbPionsAmis, nbPionsEnnemis);
        indexCassioDuMirroir := DecoderPattern(ChaineMirroir(pattern), nbreCasesDuPattern);

        indexTransformeParMonAlgo := TransformePatternCassioVersBruno(indexCassioDuMirroir, nbreCasesDuPattern);
      end;

  // Verification de coherence

  if (indexTransformeParMonAlgo <> indexBruno) then
    begin
      WritelnDansRapport('');
      WritelnStringDansRapport('Erreur sur ce pattern  : '+nomDuPattern);
      WritelnNumDansRapport('indexBruno = ' ,  indexBruno);
      WritelnNumDansRapport('index transforme = ' ,  indexTransformeParMonAlgo);
      WritelnNumDansRapport('nbreCasesDuPattern = ' ,  nbreCasesDuPattern);
      WritelnNumDansRapport('taille_du_pattern = ' ,  taille_du_pattern);
    end;
end;




procedure CheckCassioEdmondPatterns(var position : plateauOthello; var frontiere : InfoFront);
begin

  EdmondCalculatePatterns(position);

  with frontiere do
    begin

      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleD1H5] , diag_5a ,  5  , 'diag_5a');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleD8H4] , diag_5b ,  5  , 'diag_5b');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA4E8] , diag_5c ,  5  , 'diag_5c');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA5E1] , diag_5d ,  5  , 'diag_5d');


      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleC1H6] , diag_6a ,  6  , 'diag_6a');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleC8H3] , diag_6b ,  6  , 'diag_6b');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA3F8] , diag_6c ,  6  , 'diag_6c');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA6F1] , diag_6d ,  6  , 'diag_6d');

      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleB1H7] , diag_7a ,  7  , 'diag_7a');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleB8H2] , diag_7b ,  7  , 'diag_7b');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA2G8] , diag_7c ,  7  , 'diag_7c');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA7G1] , diag_7d ,  7  , 'diag_7d');

      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA1H8] , diag_8a ,  8  , 'diag_8a');
      CheckPatternCorrespondance(AdressePattern[kAdresseDiagonaleA8H1] , diag_8b ,  8  , 'diag_8b');

      CheckPatternCorrespondance(AdressePattern[kAdresseColonne4] , hv_4a ,  8  , 'hv_4a');
      CheckPatternCorrespondance(AdressePattern[kAdresseColonne5] , hv_4b ,  8  , 'hv_4b');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne4]   , hv_4c ,  8  , 'hv_4c');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne5]   , hv_4d ,  8  , 'hv_4d');

      CheckPatternCorrespondance(AdressePattern[kAdresseColonne3] , hv_3a ,  8  , 'hv_3a');
      CheckPatternCorrespondance(AdressePattern[kAdresseColonne6] , hv_3b ,  8  , 'hv_3b');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne3]   , hv_3c ,  8  , 'hv_3c');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne6]   , hv_3d ,  8  , 'hv_3d');

      CheckPatternCorrespondance(AdressePattern[kAdresseColonne2] , hv_2a ,  8  , 'hv_2a');
      CheckPatternCorrespondance(AdressePattern[kAdresseColonne7] , hv_2b ,  8  , 'hv_2b');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne2]   , hv_2c ,  8  , 'hv_2c');
      CheckPatternCorrespondance(AdressePattern[kAdresseLigne7]   , hv_2d ,  8  , 'hv_2d');


      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25A1E1] , corner2x5a ,  10  , 'corner2x5a');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25H1H5] , corner2x5b ,  10  , 'corner2x5b');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25H8D8] , corner2x5c ,  10  , 'corner2x5c');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25A8A4] , corner2x5d ,  10  , 'corner2x5d');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25A1A5] , corner2x5e ,  10  , 'corner2x5e');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25H1D1] , corner2x5f ,  10  , 'corner2x5f');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25H8H4] , corner2x5g ,  10  , 'corner2x5g');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner25A8E8] , corner2x5h ,  10  , 'corner2x5h');


      CheckPatternCorrespondance(AdressePattern[kAdresseBord6Plus4Nord]  , edge64a ,  10  , 'edge64a');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord6Plus4Est]   , edge64b ,  10  , 'edge64b');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord6Plus4Sud]   , edge64c ,  10  , 'edge64c');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord6Plus4Ouest] , edge64d ,  10  , 'edge64d');


      CheckPatternCorrespondance(AdressePattern[kAdresseCorner11A1]  , corner11a , 11 , 'corner11a');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner11H1]  , corner11b , 11 , 'corner11b');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner11H8]  , corner11c , 11 , 'corner11c');
      CheckPatternCorrespondance(AdressePattern[kAdresseCorner11A8]  , corner11d , 11 , 'corner11d');


      CheckPatternCorrespondance(AdressePattern[kAdresseBord2XCNord]  , edge2XCa , 12 , 'edge2XCa');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord2XCEst]   , edge2XCb , 12 , 'edge2XCb');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord2XCSud]   , edge2XCc , 12 , 'edge2XCc');
      CheckPatternCorrespondance(AdressePattern[kAdresseBord2XCOuest] , edge2XCd , 12 , 'edge2XCd');


    end;



end;




procedure ClearEdmondPatterns;
begin

		diag_5a := 0;
		diag_5b := 0;
		diag_5c := 0;
		diag_5d := 0;

		diag_6a := 0;
		diag_6b := 0;
		diag_6c := 0;
		diag_6d := 0;

		diag_7a := 0;
		diag_7b := 0;
		diag_7c := 0;
		diag_7d := 0;

		diag_8a := 0;
		diag_8b := 0;

		hv_4a := 0;
		hv_4b := 0;
		hv_4c := 0;
		hv_4d := 0;

		hv_3a := 0;
		hv_3b := 0;
		hv_3c := 0;
		hv_3d := 0;

		hv_2a := 0;
		hv_2b := 0;
		hv_2c := 0;
		hv_2d := 0;

		corner2x5a := 0;
		corner2x5b := 0;
		corner2x5c := 0;
		corner2x5d := 0;
		corner2x5e := 0;
		corner2x5f := 0;
		corner2x5g := 0;
		corner2x5h := 0;

		edge64a := 0;
		edge64b := 0;
		edge64c := 0;
		edge64d := 0;

		corner11a := 0;
		corner11b := 0;
		corner11c := 0;
		corner11d := 0;

		edge2XCa := 0;
		edge2XCb := 0;
		edge2XCc := 0;
		edge2XCd := 0;

end;


//set Black disc


procedure Edmond_set_BLACK_A1 ;
begin
 diag_8a :=  diag_8a +    1;
 corner11a :=  corner11a +   1;
 corner2x5a :=  corner2x5a +     1;
 corner2x5e :=  corner2x5e +     1;
 edge2XCa :=  edge2XCa +     9;
 edge2XCd :=  edge2XCd + 19683;
end;

procedure Edmond_set_BLACK_B1 ;
begin
 hv_2a :=  hv_2a +    1;
 diag_7a :=  diag_7a +   1;
 corner11a :=  corner11a +     3;
 corner2x5a :=  corner2x5a +     3;
 corner2x5e :=  corner2x5e + 19683;
 edge2XCa :=  edge2XCa +    27;
 edge64a :=  edge64a +      9;
 edge2XCd :=  edge2XCd +  59049;
end;

procedure Edmond_set_BLACK_C1 ;
begin
 hv_3a :=  hv_3a +    1;
 diag_6a :=  diag_6a +   1;
 corner11a :=  corner11a +     9;
 corner2x5a :=  corner2x5a +     9;
 edge2XCa :=  edge2XCa +    81;
 edge64a :=  edge64a +    27;
end;

procedure Edmond_set_BLACK_D1 ;
begin
 hv_4a :=  hv_4a +    1;
 diag_5a :=  diag_5a +   1;
 corner11a :=  corner11a +    27;
 corner2x5a :=  corner2x5a +    27;
 edge2XCa :=  edge2XCa +   243;
 corner2x5f :=  corner2x5f +    81;
 edge64a :=  edge64a +     81;
end;

procedure Edmond_set_BLACK_E1 ;
begin
 hv_4b :=  hv_4b + 2187;
 diag_5d :=  diag_5d +  81;
 corner2x5a :=  corner2x5a +    81;
 corner2x5f :=  corner2x5f +    27;
 edge2XCa :=  edge2XCa +   729;
 corner11b :=  corner11b +  2187;
 edge64a :=  edge64a +    243;
end;

procedure Edmond_set_BLACK_F1 ;
begin
 hv_3b :=  hv_3b + 2187;
 diag_6d :=  diag_6d + 243;
 corner11b :=  corner11b +  6561;
 corner2x5f :=  corner2x5f +     9;
 edge2XCa :=  edge2XCa +  2187;
 edge64a :=  edge64a +   729;
end;

procedure Edmond_set_BLACK_G1 ;
begin
 hv_2b :=  hv_2b + 2187;
 diag_7d :=  diag_7d + 729;
 corner11b :=  corner11b + 19683;
 corner2x5b :=  corner2x5b + 19683;
 corner2x5f :=  corner2x5f +     3;
 edge2XCa :=  edge2XCa +  6561;
 edge64a :=  edge64a +   2187;
 edge2XCb :=  edge2XCb +      3;
end;

procedure Edmond_set_BLACK_H1 ;
begin
 diag_8b :=  diag_8b + 2187;
 corner11b :=  corner11b +   1;
 corner2x5b :=  corner2x5b +     1;
 corner2x5f :=  corner2x5f +     1;
 edge2XCa :=  edge2XCa + 19683;
 edge2XCb :=  edge2XCb +     9;
end;


procedure Edmond_set_BLACK_A2 ;
begin
 hv_2c :=  hv_2c + 2187;
 diag_7c :=  diag_7c + 729;
 corner11a :=  corner11a + 19683;
 corner2x5a :=  corner2x5a + 19683;
 corner2x5e :=  corner2x5e +     3;
 edge2XCd :=  edge2XCd +  6561;
 edge64d :=  edge64d +   2187;
 edge2XCa :=  edge2XCa +      3;
end;

procedure Edmond_set_BLACK_B2 ;
begin
 hv_2a :=  hv_2a +    3;
 hv_2c :=  hv_2c + 729;
 diag_8a :=  diag_8a +     3;
 corner11a :=  corner11a + 59049;
 corner2x5a :=  corner2x5a +  6561;
 corner2x5e :=  corner2x5e +  6561;
 edge2XCa :=  edge2XCa +      1;
 edge2XCd :=  edge2XCd + 177147;
end;

procedure Edmond_set_BLACK_C2 ;
begin
 hv_3a :=  hv_3a +    3;
 hv_2c :=  hv_2c + 243;
 diag_7a :=  diag_7a +     3;
 corner11a :=  corner11a +    81;
 corner2x5a :=  corner2x5a +  2187;
 edge64a :=  edge64a +     3;
end;

procedure Edmond_set_BLACK_D2 ;
begin
 hv_4a :=  hv_4a +    3;
 hv_2c :=  hv_2c +  81;
 diag_6a :=  diag_6a +     3;
 diag_5d :=  diag_5d +    27;
 corner2x5a :=  corner2x5a +   729;
 corner2x5f :=  corner2x5f +   243;
 edge64a :=  edge64a +      1;
end;

procedure Edmond_set_BLACK_E2 ;
begin
 hv_4b :=  hv_4b +  729;
 hv_2c :=  hv_2c +  27;
 diag_6d :=  diag_6d +    81;
 diag_5a :=  diag_5a +     3;
 corner2x5a :=  corner2x5a +   243;
 corner2x5f :=  corner2x5f +   729;
 edge64a :=  edge64a +  19683;
end;

procedure Edmond_set_BLACK_F2 ;
begin
 hv_3b :=  hv_3b +  729;
 hv_2c :=  hv_2c +   9;
 diag_7d :=  diag_7d +   243;
 corner11b :=  corner11b +   729;
 corner2x5f :=  corner2x5f +  2187;
 edge64a :=  edge64a +  6561;
end;

procedure Edmond_set_BLACK_G2 ;
begin
 hv_2b :=  hv_2b +  729;
 hv_2c :=  hv_2c +   3;
 diag_8b :=  diag_8b +   729;
 corner11b :=  corner11b + 59049;
 corner2x5b :=  corner2x5b +  6561;
 corner2x5f :=  corner2x5f +  6561;
 edge2XCa :=  edge2XCa + 177147;
 edge2XCb :=  edge2XCb +      1;
end;

procedure Edmond_set_BLACK_H2 ;
begin
 hv_2c :=  hv_2c +    1;
 diag_7b :=  diag_7b +   1;
 corner11b :=  corner11b +     3;
 corner2x5b :=  corner2x5b +     3;
 corner2x5f :=  corner2x5f + 19683;
 edge2XCb :=  edge2XCb +    27;
 edge64b :=  edge64b +      9;
 edge2XCa :=  edge2XCa +  59049;
end;


procedure Edmond_set_BLACK_A3 ;
begin
 hv_3c :=  hv_3c + 2187;
 diag_6c :=  diag_6c + 243;
 corner11a :=  corner11a + 6561;
 corner2x5e :=  corner2x5e +     9;
 edge2XCd :=  edge2XCd +  2187;
 edge64d :=  edge64d +   729;
end;

procedure Edmond_set_BLACK_B3 ;
begin
 hv_2a :=  hv_2a +    9;
 hv_3c :=  hv_3c + 729;
 diag_7c :=  diag_7c +  243;
 corner11a :=  corner11a +   729;
 corner2x5e :=  corner2x5e +  2187;
 edge64d :=  edge64d +  6561;
end;

procedure Edmond_set_BLACK_C3 ;
begin
 hv_3a :=  hv_3a +    9;
 hv_3c :=  hv_3c + 243;
 diag_8a :=  diag_8a +    9;
 diag_5d :=  diag_5d +     9;
 corner11a :=  corner11a +   243;
end;

procedure Edmond_set_BLACK_D3 ;
begin
 hv_4a :=  hv_4a +    9;
 hv_3c :=  hv_3c +  81;
 diag_7a :=  diag_7a +    9;
 diag_6d :=  diag_6d +    27;
end;

procedure Edmond_set_BLACK_E3 ;
begin
 hv_4b :=  hv_4b +  243;
 hv_3c :=  hv_3c +  27;
 diag_7d :=  diag_7d +   81;
 diag_6a :=  diag_6a +     9;
end;

procedure Edmond_set_BLACK_F3 ;
begin
 hv_3b :=  hv_3b +  243;
 hv_3c :=  hv_3c +   9;
 diag_8b :=  diag_8b +  243;
 diag_5a :=  diag_5a +     9;
 corner11b :=  corner11b +   243;
end;

procedure Edmond_set_BLACK_G3 ;
begin
 hv_2b :=  hv_2b +  243;
 hv_3c :=  hv_3c +   3;
 diag_7b :=  diag_7b +    3;
 corner11b :=  corner11b +    81;
 corner2x5b :=  corner2x5b +  2187;
 edge64b :=  edge64b +     3;
end;

procedure Edmond_set_BLACK_H3 ;
begin
 hv_3c :=  hv_3c +    1;
 diag_6b :=  diag_6b +   1;
 corner11b :=  corner11b +    9;
 corner2x5b :=  corner2x5b +     9;
 edge2XCb :=  edge2XCb +    81;
 edge64b :=  edge64b +    27;
end;


procedure Edmond_set_BLACK_A4 ;
begin
 hv_4c :=  hv_4c + 2187;
 diag_5c :=  diag_5c +  81;
 corner2x5e :=  corner2x5e +   27;
 edge2XCd :=  edge2XCd +   729;
 corner11a :=  corner11a +  2187;
 corner2x5d :=  corner2x5d +    81;
 edge64d :=  edge64d +    243;
end;

procedure Edmond_set_BLACK_B4 ;
begin
 hv_2a :=  hv_2a +   27;
 hv_4c :=  hv_4c + 729;
 diag_6c :=  diag_6c +   81;
 diag_5d :=  diag_5d +     3;
 corner2x5e :=  corner2x5e +   729;
 corner2x5d :=  corner2x5d +   243;
 edge64d :=  edge64d +  19683;
end;

procedure Edmond_set_BLACK_C4 ;
begin
 hv_3a :=  hv_3a +   27;
 hv_4c :=  hv_4c + 243;
 diag_7c :=  diag_7c +   81;
 diag_6d :=  diag_6d +     9;
end;

procedure Edmond_set_BLACK_D4 ;
begin
 hv_4a :=  hv_4a +   27;
 hv_4c :=  hv_4c +  81;
 diag_8a :=  diag_8a +   27;
 diag_7d :=  diag_7d +    27;
end;

procedure Edmond_set_BLACK_E4 ;
begin
 hv_4b :=  hv_4b +   81;
 hv_4c :=  hv_4c +  27;
 diag_8b :=  diag_8b +   81;
 diag_7a :=  diag_7a +    27;
end;

procedure Edmond_set_BLACK_F4 ;
begin
 hv_3b :=  hv_3b +   81;
 hv_4c :=  hv_4c +   9;
 diag_7b :=  diag_7b +    9;
 diag_6a :=  diag_6a +    27;
end;

procedure Edmond_set_BLACK_G4 ;
begin
 hv_2b :=  hv_2b +   81;
 hv_4c :=  hv_4c +   3;
 diag_6b :=  diag_6b +    3;
 diag_5a :=  diag_5a +    27;
 corner2x5b :=  corner2x5b +   729;
 corner2x5g :=  corner2x5g +   243;
 edge64b :=  edge64b +      1;
end;

procedure Edmond_set_BLACK_H4 ;
begin
 hv_4c :=  hv_4c +    1;
 diag_5b :=  diag_5b +   1;
 corner2x5b :=  corner2x5b +   27;
 corner2x5g :=  corner2x5g +    81;
 edge2XCb :=  edge2XCb +   243;
 corner11b :=  corner11b +    27;
 edge64b :=  edge64b +     81;
end;


procedure Edmond_set_BLACK_A5 ;
begin
 hv_4d :=  hv_4d +    1;
 diag_5d :=  diag_5d +   1;
 corner2x5d :=  corner2x5d +   27;
 edge2XCd :=  edge2XCd +   243;
 corner11d :=  corner11d +    27;
 corner2x5e :=  corner2x5e +    81;
 edge64d :=  edge64d +     81;
end;

procedure Edmond_set_BLACK_B5 ;
begin
 hv_2a :=  hv_2a +   81;
 hv_4d :=  hv_4d +   3;
 diag_6d :=  diag_6d +    3;
 diag_5c :=  diag_5c +    27;
 corner2x5d :=  corner2x5d +   729;
 corner2x5e :=  corner2x5e +   243;
 edge64d :=  edge64d +      1;
end;

procedure Edmond_set_BLACK_C5 ;
begin
 hv_3a :=  hv_3a +   81;
 hv_4d :=  hv_4d +   9;
 diag_7d :=  diag_7d +    9;
 diag_6c :=  diag_6c +    27;
end;

procedure Edmond_set_BLACK_D5 ;
begin
 hv_4a :=  hv_4a +   81;
 hv_4d :=  hv_4d +  27;
 diag_8b :=  diag_8b +   27;
 diag_7c :=  diag_7c +    27;
end;

procedure Edmond_set_BLACK_E5 ;
begin
 hv_4b :=  hv_4b +   27;
 hv_4d :=  hv_4d +  81;
 diag_8a :=  diag_8a +   81;
 diag_7b :=  diag_7b +    27;
end;

procedure Edmond_set_BLACK_F5 ;
begin
 hv_3b :=  hv_3b +   27;
 hv_4d :=  hv_4d + 243;
 diag_7a :=  diag_7a +   81;
 diag_6b :=  diag_6b +     9;
end;

procedure Edmond_set_BLACK_G5 ;
begin
 hv_2b :=  hv_2b +   27;
 hv_4d :=  hv_4d + 729;
 diag_6a :=  diag_6a +   81;
 diag_5b :=  diag_5b +     3;
 corner2x5g :=  corner2x5g +   729;
 corner2x5b :=  corner2x5b +   243;
 edge64b :=  edge64b +  19683;
end;

procedure Edmond_set_BLACK_H5 ;
begin
 hv_4d :=  hv_4d + 2187;
 diag_5a :=  diag_5a +  81;
 corner2x5g :=  corner2x5g +   27;
 edge2XCb :=  edge2XCb +   729;
 corner11c :=  corner11c +  2187;
 corner2x5b :=  corner2x5b +    81;
 edge64b :=  edge64b +    243;
end;


procedure Edmond_set_BLACK_A6 ;
begin
 hv_3d :=  hv_3d +    1;
 diag_6d :=  diag_6d +   1;
 corner11d :=  corner11d +    9;
 corner2x5d :=  corner2x5d +     9;
 edge2XCd :=  edge2XCd +    81;
 edge64d :=  edge64d +    27;
end;

procedure Edmond_set_BLACK_B6 ;
begin
 hv_2a :=  hv_2a +  243;
 hv_3d :=  hv_3d +   3;
 diag_7d :=  diag_7d +    3;
 corner11d :=  corner11d +    81;
 corner2x5d :=  corner2x5d +  2187;
 edge64d :=  edge64d +     3;
end;

procedure Edmond_set_BLACK_C6 ;
begin
 hv_3a :=  hv_3a +  243;
 hv_3d :=  hv_3d +   9;
 diag_8b :=  diag_8b +    9;
 diag_5c :=  diag_5c +     9;
 corner11d :=  corner11d +   243;
end;

procedure Edmond_set_BLACK_D6 ;
begin
 hv_4a :=  hv_4a +  243;
 hv_3d :=  hv_3d +  27;
 diag_7b :=  diag_7b +   81;
 diag_6c :=  diag_6c +     9;
end;

procedure Edmond_set_BLACK_E6 ;
begin
 hv_4b :=  hv_4b +    9;
 hv_3d :=  hv_3d +  81;
 diag_7c :=  diag_7c +    9;
 diag_6b :=  diag_6b +    27;
end;

procedure Edmond_set_BLACK_F6 ;
begin
 hv_3b :=  hv_3b +    9;
 hv_3d :=  hv_3d + 243;
 diag_8a :=  diag_8a +  243;
 diag_5b :=  diag_5b +     9;
 corner11c :=  corner11c +   243;
end;

procedure Edmond_set_BLACK_G6 ;
begin
 hv_2b :=  hv_2b +    9;
 hv_3d :=  hv_3d + 729;
 diag_7a :=  diag_7a +  243;
 corner11c :=  corner11c +   729;
 corner2x5g :=  corner2x5g +  2187;
 edge64b :=  edge64b +  6561;
end;

procedure Edmond_set_BLACK_H6 ;
begin
 hv_3d :=  hv_3d + 2187;
 diag_6a :=  diag_6a + 243;
 corner11c :=  corner11c + 6561;
 corner2x5g :=  corner2x5g +     9;
 edge2XCb :=  edge2XCb +  2187;
 edge64b :=  edge64b +   729;
end;


procedure Edmond_set_BLACK_A7 ;
begin
 hv_2d :=  hv_2d +    1;
 diag_7d :=  diag_7d +   1;
 corner11d :=  corner11d +     3;
 corner2x5d :=  corner2x5d +     3;
 corner2x5h :=  corner2x5h + 19683;
 edge2XCd :=  edge2XCd +    27;
 edge64d :=  edge64d +      9;
 edge2XCc :=  edge2XCc +  59049;
end;

procedure Edmond_set_BLACK_B7 ;
begin
 hv_2a :=  hv_2a +  729;
 hv_2d :=  hv_2d +   3;
 diag_8b :=  diag_8b +     3;
 corner11d :=  corner11d + 59049;
 corner2x5d :=  corner2x5d +  6561;
 corner2x5h :=  corner2x5h +  6561;
 edge2XCc :=  edge2XCc + 177147;
 edge2XCd :=  edge2XCd +      1;
end;

procedure Edmond_set_BLACK_C7 ;
begin
 hv_3a :=  hv_3a +  729;
 hv_2d :=  hv_2d +   9;
 diag_7b :=  diag_7b +   243;
 corner11d :=  corner11d +   729;
 corner2x5h :=  corner2x5h +  2187;
 edge64c :=  edge64c +  6561;
end;

procedure Edmond_set_BLACK_D7 ;
begin
 hv_4a :=  hv_4a +  729;
 hv_2d :=  hv_2d +  27;
 diag_6b :=  diag_6b +    81;
 diag_5c :=  diag_5c +     3;
 corner2x5c :=  corner2x5c +   243;
 corner2x5h :=  corner2x5h +   729;
 edge64c :=  edge64c +  19683;
end;

procedure Edmond_set_BLACK_E7 ;
begin
 hv_4b :=  hv_4b +    3;
 hv_2d :=  hv_2d +  81;
 diag_6c :=  diag_6c +     3;
 diag_5b :=  diag_5b +    27;
 corner2x5c :=  corner2x5c +   729;
 corner2x5h :=  corner2x5h +   243;
 edge64c :=  edge64c +      1;
end;

procedure Edmond_set_BLACK_F7 ;
begin
 hv_3b :=  hv_3b +    3;
 hv_2d :=  hv_2d + 243;
 diag_7c :=  diag_7c +     3;
 corner11c :=  corner11c +    81;
 corner2x5c :=  corner2x5c +  2187;
 edge64c :=  edge64c +     3;
end;

procedure Edmond_set_BLACK_G7 ;
begin
 hv_2b :=  hv_2b +    3;
 hv_2d :=  hv_2d + 729;
 diag_8a :=  diag_8a +   729;
 corner11c :=  corner11c + 59049;
 corner2x5c :=  corner2x5c +  6561;
 corner2x5g :=  corner2x5g +  6561;
 edge2XCb :=  edge2XCb + 177147;
 edge2XCc :=  edge2XCc +      1;
end;

procedure Edmond_set_BLACK_H7 ;
begin
 hv_2d :=  hv_2d + 2187;
 diag_7a :=  diag_7a + 729;
 corner11c :=  corner11c + 19683;
 corner2x5c :=  corner2x5c + 19683;
 corner2x5g :=  corner2x5g +     3;
 edge2XCb :=  edge2XCb +  6561;
 edge64b :=  edge64b +   2187;
 edge2XCc :=  edge2XCc +      3;
end;


procedure Edmond_set_BLACK_A8 ;
begin
 diag_8b :=  diag_8b +    1;
 corner11d :=  corner11d +   1;
 corner2x5d :=  corner2x5d +     1;
 corner2x5h :=  corner2x5h +     1;
 edge2XCc :=  edge2XCc + 19683;
 edge2XCd :=  edge2XCd +     9;
end;

procedure Edmond_set_BLACK_B8 ;
begin
 hv_2a :=  hv_2a + 2187;
 diag_7b :=  diag_7b + 729;
 corner11d :=  corner11d + 19683;
 corner2x5d :=  corner2x5d + 19683;
 corner2x5h :=  corner2x5h +     3;
 edge2XCc :=  edge2XCc +  6561;
 edge64c :=  edge64c +   2187;
 edge2XCd :=  edge2XCd +      3;
end;

procedure Edmond_set_BLACK_C8 ;
begin
 hv_3a :=  hv_3a + 2187;
 diag_6b :=  diag_6b + 243;
 corner11d :=  corner11d +  6561;
 corner2x5h :=  corner2x5h +     9;
 edge2XCc :=  edge2XCc +  2187;
 edge64c :=  edge64c +   729;
end;

procedure Edmond_set_BLACK_D8 ;
begin
 hv_4a :=  hv_4a + 2187;
 diag_5b :=  diag_5b +  81;
 corner2x5c :=  corner2x5c +    81;
 corner2x5h :=  corner2x5h +    27;
 edge2XCc :=  edge2XCc +   729;
 corner11d :=  corner11d +  2187;
 edge64c :=  edge64c +    243;
end;

procedure Edmond_set_BLACK_E8 ;
begin
 hv_4b :=  hv_4b +    1;
 diag_5c :=  diag_5c +   1;
 corner11c :=  corner11c +    27;
 corner2x5c :=  corner2x5c +    27;
 edge2XCc :=  edge2XCc +   243;
 corner2x5h :=  corner2x5h +    81;
 edge64c :=  edge64c +     81;
end;

procedure Edmond_set_BLACK_F8 ;
begin
 hv_3b :=  hv_3b +    1;
 diag_6c :=  diag_6c +   1;
 corner11c :=  corner11c +     9;
 corner2x5c :=  corner2x5c +     9;
 edge2XCc :=  edge2XCc +    81;
 edge64c :=  edge64c +    27;
end;

procedure Edmond_set_BLACK_G8 ;
begin
 hv_2b :=  hv_2b +    1;
 diag_7c :=  diag_7c +   1;
 corner11c :=  corner11c +     3;
 corner2x5c :=  corner2x5c +     3;
 corner2x5g :=  corner2x5g + 19683;
 edge2XCc :=  edge2XCc +    27;
 edge64c :=  edge64c +      9;
 edge2XCb :=  edge2XCb +  59049;
end;

procedure Edmond_set_BLACK_H8 ;
begin
 diag_8a :=  diag_8a + 2187;
 corner11c :=  corner11c +   1;
 corner2x5c :=  corner2x5c +     1;
 corner2x5g :=  corner2x5g +     1;
 edge2XCb :=  edge2XCb + 19683;
 edge2XCc :=  edge2XCc +     9;
end;

//set White disc


procedure Edmond_set_WHITE_A1 ;
begin
 diag_8a :=  diag_8a +    2;
 corner11a :=  corner11a +    2;
 corner2x5a :=  corner2x5a +     2;
 corner2x5e :=  corner2x5e +      2;
 edge2XCa :=  edge2XCa +    18;
 edge2XCd :=  edge2XCd + 39366;
end;

procedure Edmond_set_WHITE_B1 ;
begin
 hv_2a :=  hv_2a +    2;
 diag_7a :=  diag_7a +    2;
 corner11a :=  corner11a +     6;
 corner2x5a :=  corner2x5a +      6;
 corner2x5e :=  corner2x5e + 39366;
 edge2XCa :=  edge2XCa +    54;
 edge64a :=  edge64a +     18;
 edge2XCd :=  edge2XCd + 118098;
end;

procedure Edmond_set_WHITE_C1 ;
begin
 hv_3a :=  hv_3a +    2;
 diag_6a :=  diag_6a +    2;
 corner11a :=  corner11a +    18;
 corner2x5a :=  corner2x5a +     18;
 edge2XCa :=  edge2XCa +   162;
 edge64a :=  edge64a +    54;
end;

procedure Edmond_set_WHITE_D1 ;
begin
 hv_4a :=  hv_4a +    2;
 diag_5a :=  diag_5a +    2;
 corner11a :=  corner11a +    54;
 corner2x5a :=  corner2x5a +     54;
 edge2XCa :=  edge2XCa +   486;
 corner2x5f :=  corner2x5f +   162;
 edge64a :=  edge64a +    162;
end;

procedure Edmond_set_WHITE_E1 ;
begin
 hv_4b :=  hv_4b + 4374;
 diag_5d :=  diag_5d +  162;
 corner2x5a :=  corner2x5a +   162;
 corner2x5f :=  corner2x5f +     54;
 edge2XCa :=  edge2XCa +  1458;
 corner11b :=  corner11b +  4374;
 edge64a :=  edge64a +    486;
end;

procedure Edmond_set_WHITE_F1 ;
begin
 hv_3b :=  hv_3b + 4374;
 diag_6d :=  diag_6d +  486;
 corner11b :=  corner11b + 13122;
 corner2x5f :=  corner2x5f +     18;
 edge2XCa :=  edge2XCa +  4374;
 edge64a :=  edge64a +  1458;
end;

procedure Edmond_set_WHITE_G1 ;
begin
 hv_2b :=  hv_2b + 4374;
 diag_7d :=  diag_7d + 1458;
 corner11b :=  corner11b + 39366;
 corner2x5b :=  corner2x5b +  39366;
 corner2x5f :=  corner2x5f +     6;
 edge2XCa :=  edge2XCa + 13122;
 edge64a :=  edge64a +   4374;
 edge2XCb :=  edge2XCb +      6;
end;

procedure Edmond_set_WHITE_H1 ;
begin
 diag_8b :=  diag_8b + 4374;
 corner11b :=  corner11b +    2;
 corner2x5b :=  corner2x5b +     2;
 corner2x5f :=  corner2x5f +      2;
 edge2XCa :=  edge2XCa + 39366;
 edge2XCb :=  edge2XCb +    18;
end;


procedure Edmond_set_WHITE_A2 ;
begin
 hv_2c :=  hv_2c + 4374;
 diag_7c :=  diag_7c + 1458;
 corner11a :=  corner11a + 39366;
 corner2x5a :=  corner2x5a +  39366;
 corner2x5e :=  corner2x5e +     6;
 edge2XCd :=  edge2XCd + 13122;
 edge64d :=  edge64d +   4374;
 edge2XCa :=  edge2XCa +      6;
end;

procedure Edmond_set_WHITE_B2 ;
begin
 hv_2a :=  hv_2a +    6;
 hv_2c :=  hv_2c + 1458;
 diag_8a :=  diag_8a +     6;
 corner11a :=  corner11a + 118098;
 corner2x5a :=  corner2x5a + 13122;
 corner2x5e :=  corner2x5e + 13122;
 edge2XCa :=  edge2XCa +      2;
 edge2XCd :=  edge2XCd + 354294;
end;

procedure Edmond_set_WHITE_C2 ;
begin
 hv_3a :=  hv_3a +    6;
 hv_2c :=  hv_2c +  486;
 diag_7a :=  diag_7a +     6;
 corner11a :=  corner11a +    162;
 corner2x5a :=  corner2x5a +  4374;
 edge64a :=  edge64a +     6;
end;

procedure Edmond_set_WHITE_D2 ;
begin
 hv_4a :=  hv_4a +    6;
 hv_2c :=  hv_2c +  162;
 diag_6a :=  diag_6a +     6;
 diag_5d :=  diag_5d +     54;
 corner2x5a :=  corner2x5a +  1458;
 corner2x5f :=  corner2x5f +   486;
 edge64a :=  edge64a +      2;
end;

procedure Edmond_set_WHITE_E2 ;
begin
 hv_4b :=  hv_4b + 1458;
 hv_2c :=  hv_2c +   54;
 diag_6d :=  diag_6d +   162;
 diag_5a :=  diag_5a +      6;
 corner2x5a :=  corner2x5a +   486;
 corner2x5f :=  corner2x5f +  1458;
 edge64a :=  edge64a +  39366;
end;

procedure Edmond_set_WHITE_F2 ;
begin
 hv_3b :=  hv_3b + 1458;
 hv_2c :=  hv_2c +   18;
 diag_7d :=  diag_7d +   486;
 corner11b :=  corner11b +   1458;
 corner2x5f :=  corner2x5f +  4374;
 edge64a :=  edge64a + 13122;
end;

procedure Edmond_set_WHITE_G2 ;
begin
 hv_2b :=  hv_2b + 1458;
 hv_2c :=  hv_2c +    6;
 diag_8b :=  diag_8b +  1458;
 corner11b :=  corner11b + 118098;
 corner2x5b :=  corner2x5b + 13122;
 corner2x5f :=  corner2x5f + 13122;
 edge2XCa :=  edge2XCa + 354294;
 edge2XCb :=  edge2XCb +      2;
end;

procedure Edmond_set_WHITE_H2 ;
begin
 hv_2c :=  hv_2c +    2;
 diag_7b :=  diag_7b +    2;
 corner11b :=  corner11b +     6;
 corner2x5b :=  corner2x5b +      6;
 corner2x5f :=  corner2x5f + 39366;
 edge2XCb :=  edge2XCb +    54;
 edge64b :=  edge64b +     18;
 edge2XCa :=  edge2XCa + 118098;
end;


procedure Edmond_set_WHITE_A3 ;
begin
 hv_3c :=  hv_3c + 4374;
 diag_6c :=  diag_6c +  486;
 corner11a :=  corner11a + 13122;
 corner2x5e :=  corner2x5e +     18;
 edge2XCd :=  edge2XCd +  4374;
 edge64d :=  edge64d +  1458;
end;

procedure Edmond_set_WHITE_B3 ;
begin
 hv_2a :=  hv_2a +   18;
 hv_3c :=  hv_3c + 1458;
 diag_7c :=  diag_7c +   486;
 corner11a :=  corner11a +   1458;
 corner2x5e :=  corner2x5e +  4374;
 edge64d :=  edge64d + 13122;
end;

procedure Edmond_set_WHITE_C3 ;
begin
 hv_3a :=  hv_3a +   18;
 hv_3c :=  hv_3c +  486;
 diag_8a :=  diag_8a +    18;
 diag_5d :=  diag_5d +     18;
 corner11a :=  corner11a +   486;
end;

procedure Edmond_set_WHITE_D3 ;
begin
 hv_4a :=  hv_4a +   18;
 hv_3c :=  hv_3c +  162;
 diag_7a :=  diag_7a +    18;
 diag_6d :=  diag_6d +     54;
end;

procedure Edmond_set_WHITE_E3 ;
begin
 hv_4b :=  hv_4b +  486;
 hv_3c :=  hv_3c +   54;
 diag_7d :=  diag_7d +   162;
 diag_6a :=  diag_6a +     18;
end;

procedure Edmond_set_WHITE_F3 ;
begin
 hv_3b :=  hv_3b +  486;
 hv_3c :=  hv_3c +   18;
 diag_8b :=  diag_8b +   486;
 diag_5a :=  diag_5a +     18;
 corner11b :=  corner11b +   486;
end;

procedure Edmond_set_WHITE_G3 ;
begin
 hv_2b :=  hv_2b +  486;
 hv_3c :=  hv_3c +    6;
 diag_7b :=  diag_7b +     6;
 corner11b :=  corner11b +    162;
 corner2x5b :=  corner2x5b +  4374;
 edge64b :=  edge64b +     6;
end;

procedure Edmond_set_WHITE_H3 ;
begin
 hv_3c :=  hv_3c +    2;
 diag_6b :=  diag_6b +    2;
 corner11b :=  corner11b +    18;
 corner2x5b :=  corner2x5b +     18;
 edge2XCb :=  edge2XCb +   162;
 edge64b :=  edge64b +    54;
end;


procedure Edmond_set_WHITE_A4 ;
begin
 hv_4c :=  hv_4c + 4374;
 diag_5c :=  diag_5c +  162;
 corner2x5e :=  corner2x5e +    54;
 edge2XCd :=  edge2XCd +   1458;
 corner11a :=  corner11a +  4374;
 corner2x5d :=  corner2x5d +   162;
 edge64d :=  edge64d +    486;
end;

procedure Edmond_set_WHITE_B4 ;
begin
 hv_2a :=  hv_2a +   54;
 hv_4c :=  hv_4c + 1458;
 diag_6c :=  diag_6c +   162;
 diag_5d :=  diag_5d +      6;
 corner2x5e :=  corner2x5e +  1458;
 corner2x5d :=  corner2x5d +   486;
 edge64d :=  edge64d +  39366;
end;

procedure Edmond_set_WHITE_C4 ;
begin
 hv_3a :=  hv_3a +   54;
 hv_4c :=  hv_4c +  486;
 diag_7c :=  diag_7c +   162;
 diag_6d :=  diag_6d +     18;
end;

procedure Edmond_set_WHITE_D4 ;
begin
 hv_4a :=  hv_4a +   54;
 hv_4c :=  hv_4c +  162;
 diag_8a :=  diag_8a +    54;
 diag_7d :=  diag_7d +     54;
end;

procedure Edmond_set_WHITE_E4 ;
begin
 hv_4b :=  hv_4b +  162;
 hv_4c :=  hv_4c +   54;
 diag_8b :=  diag_8b +   162;
 diag_7a :=  diag_7a +     54;
end;

procedure Edmond_set_WHITE_F4 ;
begin
 hv_3b :=  hv_3b +  162;
 hv_4c :=  hv_4c +   18;
 diag_7b :=  diag_7b +    18;
 diag_6a :=  diag_6a +     54;
end;

procedure Edmond_set_WHITE_G4 ;
begin
 hv_2b :=  hv_2b +  162;
 hv_4c :=  hv_4c +    6;
 diag_6b :=  diag_6b +     6;
 diag_5a :=  diag_5a +     54;
 corner2x5b :=  corner2x5b +  1458;
 corner2x5g :=  corner2x5g +   486;
 edge64b :=  edge64b +      2;
end;

procedure Edmond_set_WHITE_H4 ;
begin
 hv_4c :=  hv_4c +    2;
 diag_5b :=  diag_5b +    2;
 corner2x5b :=  corner2x5b +    54;
 corner2x5g :=  corner2x5g +    162;
 edge2XCb :=  edge2XCb +   486;
 corner11b :=  corner11b +    54;
 edge64b :=  edge64b +    162;
end;


procedure Edmond_set_WHITE_A5 ;
begin
 hv_4d :=  hv_4d +    2;
 diag_5d :=  diag_5d +    2;
 corner2x5d :=  corner2x5d +    54;
 edge2XCd :=  edge2XCd +    486;
 corner11d :=  corner11d +    54;
 corner2x5e :=  corner2x5e +   162;
 edge64d :=  edge64d +    162;
end;

procedure Edmond_set_WHITE_B5 ;
begin
 hv_2a :=  hv_2a +  162;
 hv_4d :=  hv_4d +    6;
 diag_6d :=  diag_6d +     6;
 diag_5c :=  diag_5c +     54;
 corner2x5d :=  corner2x5d +  1458;
 corner2x5e :=  corner2x5e +   486;
 edge64d :=  edge64d +      2;
end;

procedure Edmond_set_WHITE_C5 ;
begin
 hv_3a :=  hv_3a +  162;
 hv_4d :=  hv_4d +   18;
 diag_7d :=  diag_7d +    18;
 diag_6c :=  diag_6c +     54;
end;

procedure Edmond_set_WHITE_D5 ;
begin
 hv_4a :=  hv_4a +  162;
 hv_4d :=  hv_4d +   54;
 diag_8b :=  diag_8b +    54;
 diag_7c :=  diag_7c +     54;
end;

procedure Edmond_set_WHITE_E5 ;
begin
 hv_4b :=  hv_4b +   54;
 hv_4d :=  hv_4d +  162;
 diag_8a :=  diag_8a +   162;
 diag_7b :=  diag_7b +     54;
end;

procedure Edmond_set_WHITE_F5 ;
begin
 hv_3b :=  hv_3b +   54;
 hv_4d :=  hv_4d +  486;
 diag_7a :=  diag_7a +   162;
 diag_6b :=  diag_6b +     18;
end;

procedure Edmond_set_WHITE_G5 ;
begin
 hv_2b :=  hv_2b +   54;
 hv_4d :=  hv_4d + 1458;
 diag_6a :=  diag_6a +   162;
 diag_5b :=  diag_5b +      6;
 corner2x5g :=  corner2x5g +  1458;
 corner2x5b :=  corner2x5b +   486;
 edge64b :=  edge64b +  39366;
end;

procedure Edmond_set_WHITE_H5 ;
begin
 hv_4d :=  hv_4d + 4374;
 diag_5a :=  diag_5a +  162;
 corner2x5g :=  corner2x5g +    54;
 edge2XCb :=  edge2XCb +   1458;
 corner11c :=  corner11c +  4374;
 corner2x5b :=  corner2x5b +   162;
 edge64b :=  edge64b +    486;
end;


procedure Edmond_set_WHITE_A6 ;
begin
 hv_3d :=  hv_3d +    2;
 diag_6d :=  diag_6d +    2;
 corner11d :=  corner11d +    18;
 corner2x5d :=  corner2x5d +     18;
 edge2XCd :=  edge2XCd +   162;
 edge64d :=  edge64d +    54;
end;

procedure Edmond_set_WHITE_B6 ;
begin
 hv_2a :=  hv_2a +  486;
 hv_3d :=  hv_3d +    6;
 diag_7d :=  diag_7d +     6;
 corner11d :=  corner11d +    162;
 corner2x5d :=  corner2x5d +  4374;
 edge64d :=  edge64d +     6;
end;

procedure Edmond_set_WHITE_C6 ;
begin
 hv_3a :=  hv_3a +  486;
 hv_3d :=  hv_3d +   18;
 diag_8b :=  diag_8b +    18;
 diag_5c :=  diag_5c +     18;
 corner11d :=  corner11d +   486;
end;

procedure Edmond_set_WHITE_D6 ;
begin
 hv_4a :=  hv_4a +  486;
 hv_3d :=  hv_3d +   54;
 diag_7b :=  diag_7b +   162;
 diag_6c :=  diag_6c +     18;
end;

procedure Edmond_set_WHITE_E6 ;
begin
 hv_4b :=  hv_4b +   18;
 hv_3d :=  hv_3d +  162;
 diag_7c :=  diag_7c +    18;
 diag_6b :=  diag_6b +     54;
end;

procedure Edmond_set_WHITE_F6 ;
begin
 hv_3b :=  hv_3b +   18;
 hv_3d :=  hv_3d +  486;
 diag_8a :=  diag_8a +   486;
 diag_5b :=  diag_5b +     18;
 corner11c :=  corner11c +   486;
end;

procedure Edmond_set_WHITE_G6 ;
begin
 hv_2b :=  hv_2b +   18;
 hv_3d :=  hv_3d + 1458;
 diag_7a :=  diag_7a +   486;
 corner11c :=  corner11c +   1458;
 corner2x5g :=  corner2x5g +  4374;
 edge64b :=  edge64b + 13122;
end;

procedure Edmond_set_WHITE_H6 ;
begin
 hv_3d :=  hv_3d + 4374;
 diag_6a :=  diag_6a +  486;
 corner11c :=  corner11c + 13122;
 corner2x5g :=  corner2x5g +     18;
 edge2XCb :=  edge2XCb +  4374;
 edge64b :=  edge64b +  1458;
end;


procedure Edmond_set_WHITE_A7 ;
begin
 hv_2d :=  hv_2d +    2;
 diag_7d :=  diag_7d +    2;
 corner11d :=  corner11d +     6;
 corner2x5d :=  corner2x5d +      6;
 corner2x5h :=  corner2x5h + 39366;
 edge2XCd :=  edge2XCd +    54;
 edge64d :=  edge64d +     18;
 edge2XCc :=  edge2XCc + 118098;
end;

procedure Edmond_set_WHITE_B7 ;
begin
 hv_2a :=  hv_2a + 1458;
 hv_2d :=  hv_2d +    6;
 diag_8b :=  diag_8b +     6;
 corner11d :=  corner11d + 118098;
 corner2x5d :=  corner2x5d + 13122;
 corner2x5h :=  corner2x5h + 13122;
 edge2XCc :=  edge2XCc + 354294;
 edge2XCd :=  edge2XCd +      2;
end;

procedure Edmond_set_WHITE_C7 ;
begin
 hv_3a :=  hv_3a + 1458;
 hv_2d :=  hv_2d +   18;
 diag_7b :=  diag_7b +   486;
 corner11d :=  corner11d +   1458;
 corner2x5h :=  corner2x5h +  4374;
 edge64c :=  edge64c + 13122;
end;

procedure Edmond_set_WHITE_D7 ;
begin
 hv_4a :=  hv_4a + 1458;
 hv_2d :=  hv_2d +   54;
 diag_6b :=  diag_6b +   162;
 diag_5c :=  diag_5c +      6;
 corner2x5c :=  corner2x5c +   486;
 corner2x5h :=  corner2x5h +  1458;
 edge64c :=  edge64c +  39366;
end;

procedure Edmond_set_WHITE_E7 ;
begin
 hv_4b :=  hv_4b +    6;
 hv_2d :=  hv_2d +  162;
 diag_6c :=  diag_6c +     6;
 diag_5b :=  diag_5b +     54;
 corner2x5c :=  corner2x5c +  1458;
 corner2x5h :=  corner2x5h +   486;
 edge64c :=  edge64c +      2;
end;

procedure Edmond_set_WHITE_F7 ;
begin
 hv_3b :=  hv_3b +    6;
 hv_2d :=  hv_2d +  486;
 diag_7c :=  diag_7c +     6;
 corner11c :=  corner11c +    162;
 corner2x5c :=  corner2x5c +  4374;
 edge64c :=  edge64c +     6;
end;

procedure Edmond_set_WHITE_G7 ;
begin
 hv_2b :=  hv_2b +    6;
 hv_2d :=  hv_2d + 1458;
 diag_8a :=  diag_8a +  1458;
 corner11c :=  corner11c + 118098;
 corner2x5c :=  corner2x5c + 13122;
 corner2x5g :=  corner2x5g + 13122;
 edge2XCb :=  edge2XCb + 354294;
 edge2XCc :=  edge2XCc +      2;
end;

procedure Edmond_set_WHITE_H7 ;
begin
 hv_2d :=  hv_2d + 4374;
 diag_7a :=  diag_7a + 1458;
 corner11c :=  corner11c + 39366;
 corner2x5c :=  corner2x5c +  39366;
 corner2x5g :=  corner2x5g +     6;
 edge2XCb :=  edge2XCb + 13122;
 edge64b :=  edge64b +   4374;
 edge2XCc :=  edge2XCc +      6;
end;


procedure Edmond_set_WHITE_A8 ;
begin
 diag_8b :=  diag_8b +    2;
 corner11d :=  corner11d +    2;
 corner2x5d :=  corner2x5d +     2;
 corner2x5h :=  corner2x5h +      2;
 edge2XCc :=  edge2XCc + 39366;
 edge2XCd :=  edge2XCd +    18;
end;

procedure Edmond_set_WHITE_B8 ;
begin
 hv_2a :=  hv_2a + 4374;
 diag_7b :=  diag_7b + 1458;
 corner11d :=  corner11d + 39366;
 corner2x5d :=  corner2x5d +  39366;
 corner2x5h :=  corner2x5h +     6;
 edge2XCc :=  edge2XCc + 13122;
 edge64c :=  edge64c +   4374;
 edge2XCd :=  edge2XCd +      6;
end;

procedure Edmond_set_WHITE_C8 ;
begin
 hv_3a :=  hv_3a + 4374;
 diag_6b :=  diag_6b +  486;
 corner11d :=  corner11d + 13122;
 corner2x5h :=  corner2x5h +     18;
 edge2XCc :=  edge2XCc +  4374;
 edge64c :=  edge64c +  1458;
end;

procedure Edmond_set_WHITE_D8 ;
begin
 hv_4a :=  hv_4a + 4374;
 diag_5b :=  diag_5b +  162;
 corner2x5c :=  corner2x5c +   162;
 corner2x5h :=  corner2x5h +     54;
 edge2XCc :=  edge2XCc +  1458;
 corner11d :=  corner11d +  4374;
 edge64c :=  edge64c +    486;
end;

procedure Edmond_set_WHITE_E8 ;
begin
 hv_4b :=  hv_4b +    2;
 diag_5c :=  diag_5c +    2;
 corner11c :=  corner11c +    54;
 corner2x5c :=  corner2x5c +     54;
 edge2XCc :=  edge2XCc +   486;
 corner2x5h :=  corner2x5h +   162;
 edge64c :=  edge64c +    162;
end;

procedure Edmond_set_WHITE_F8 ;
begin
 hv_3b :=  hv_3b +    2;
 diag_6c :=  diag_6c +    2;
 corner11c :=  corner11c +    18;
 corner2x5c :=  corner2x5c +     18;
 edge2XCc :=  edge2XCc +   162;
 edge64c :=  edge64c +    54;
end;

procedure Edmond_set_WHITE_G8 ;
begin
 hv_2b :=  hv_2b +    2;
 diag_7c :=  diag_7c +    2;
 corner11c :=  corner11c +     6;
 corner2x5c :=  corner2x5c +      6;
 corner2x5g :=  corner2x5g + 39366;
 edge2XCc :=  edge2XCc +    54;
 edge64c :=  edge64c +     18;
 edge2XCb :=  edge2XCb + 118098;
end;

procedure Edmond_set_WHITE_H8 ;
begin
 diag_8a :=  diag_8a + 4374;
 corner11c :=  corner11c +    2;
 corner2x5c :=  corner2x5c +     2;
 corner2x5g :=  corner2x5g +      2;
 edge2XCb :=  edge2XCb + 39366;
 edge2XCc :=  edge2XCc +    18;
end;

procedure Edmond_set_BLACK( square : SInt32 );
begin
	case square of

		11 : Edmond_set_BLACK_A1;

		12 : Edmond_set_BLACK_B1;

		13 : Edmond_set_BLACK_C1;

		14 : Edmond_set_BLACK_D1;

		15 : Edmond_set_BLACK_E1;

		16 : Edmond_set_BLACK_F1;

		17 : Edmond_set_BLACK_G1;

		18 : Edmond_set_BLACK_H1;

		21 : Edmond_set_BLACK_A2;

		22 : Edmond_set_BLACK_B2;

		23 : Edmond_set_BLACK_C2;

		24 : Edmond_set_BLACK_D2;

		25 : Edmond_set_BLACK_E2;

		26 : Edmond_set_BLACK_F2;

		27 : Edmond_set_BLACK_G2;

		28 : Edmond_set_BLACK_H2;

		31 : Edmond_set_BLACK_A3;

		32 : Edmond_set_BLACK_B3;

		33 : Edmond_set_BLACK_C3;

		34 : Edmond_set_BLACK_D3;

		35 : Edmond_set_BLACK_E3;

		36 : Edmond_set_BLACK_F3;

		37 : Edmond_set_BLACK_G3;

		38 : Edmond_set_BLACK_H3;

		41 : Edmond_set_BLACK_A4;

		42 : Edmond_set_BLACK_B4;

		43 : Edmond_set_BLACK_C4;

		44 : Edmond_set_BLACK_D4;

		45 : Edmond_set_BLACK_E4;

		46 : Edmond_set_BLACK_F4;

		47 : Edmond_set_BLACK_G4;

		48 : Edmond_set_BLACK_H4;

		51 : Edmond_set_BLACK_A5;

		52 : Edmond_set_BLACK_B5;

		53 : Edmond_set_BLACK_C5;

		54 : Edmond_set_BLACK_D5;

		55 : Edmond_set_BLACK_E5;

		56 : Edmond_set_BLACK_F5;

		57 : Edmond_set_BLACK_G5;

		58 : Edmond_set_BLACK_H5;

		61 : Edmond_set_BLACK_A6;

		62 : Edmond_set_BLACK_B6;

		63 : Edmond_set_BLACK_C6;

		64 : Edmond_set_BLACK_D6;

		65 : Edmond_set_BLACK_E6;

		66 : Edmond_set_BLACK_F6;

		67 : Edmond_set_BLACK_G6;

		68 : Edmond_set_BLACK_H6;

		71 : Edmond_set_BLACK_A7;

		72 : Edmond_set_BLACK_B7;

		73 : Edmond_set_BLACK_C7;

		74 : Edmond_set_BLACK_D7;

		75 : Edmond_set_BLACK_E7;

		76 : Edmond_set_BLACK_F7;

		77 : Edmond_set_BLACK_G7;

		78 : Edmond_set_BLACK_H7;

		81 : Edmond_set_BLACK_A8;

		82 : Edmond_set_BLACK_B8;

		83 : Edmond_set_BLACK_C8;

		84 : Edmond_set_BLACK_D8;

		85 : Edmond_set_BLACK_E8;

		86 : Edmond_set_BLACK_F8;

		87 : Edmond_set_BLACK_G8;

		88 : Edmond_set_BLACK_H8;
	end;
end;

procedure Edmond_set_WHITE( square : SInt32 );

begin
	case square of

		11 : Edmond_set_WHITE_A1;

		12 : Edmond_set_WHITE_B1;

		13 : Edmond_set_WHITE_C1;

		14 : Edmond_set_WHITE_D1;

		15 : Edmond_set_WHITE_E1;

		16 : Edmond_set_WHITE_F1;

		17 : Edmond_set_WHITE_G1;

		18 : Edmond_set_WHITE_H1;

		21 : Edmond_set_WHITE_A2;

		22 : Edmond_set_WHITE_B2;

		23 : Edmond_set_WHITE_C2;

		24 : Edmond_set_WHITE_D2;

		25 : Edmond_set_WHITE_E2;

		26 : Edmond_set_WHITE_F2;

		27 : Edmond_set_WHITE_G2;

		28 : Edmond_set_WHITE_H2;

		31 : Edmond_set_WHITE_A3;

		32 : Edmond_set_WHITE_B3;

		33 : Edmond_set_WHITE_C3;

		34 : Edmond_set_WHITE_D3;

		35 : Edmond_set_WHITE_E3;

		36 : Edmond_set_WHITE_F3;

		37 : Edmond_set_WHITE_G3;

		38 : Edmond_set_WHITE_H3;

		41 : Edmond_set_WHITE_A4;

		42 : Edmond_set_WHITE_B4;

		43 : Edmond_set_WHITE_C4;

		44 : Edmond_set_WHITE_D4;

		45 : Edmond_set_WHITE_E4;

		46 : Edmond_set_WHITE_F4;

		47 : Edmond_set_WHITE_G4;

		48 : Edmond_set_WHITE_H4;

		51 : Edmond_set_WHITE_A5;

		52 : Edmond_set_WHITE_B5;

		53 : Edmond_set_WHITE_C5;

		54 : Edmond_set_WHITE_D5;

		55 : Edmond_set_WHITE_E5;

		56 : Edmond_set_WHITE_F5;

		57 : Edmond_set_WHITE_G5;

		58 : Edmond_set_WHITE_H5;

		61 : Edmond_set_WHITE_A6;

		62 : Edmond_set_WHITE_B6;

		63 : Edmond_set_WHITE_C6;

		64 : Edmond_set_WHITE_D6;

		65 : Edmond_set_WHITE_E6;

		66 : Edmond_set_WHITE_F6;

		67 : Edmond_set_WHITE_G6;

		68 : Edmond_set_WHITE_H6;

		71 : Edmond_set_WHITE_A7;

		72 : Edmond_set_WHITE_B7;

		73 : Edmond_set_WHITE_C7;

		74 : Edmond_set_WHITE_D7;

		75 : Edmond_set_WHITE_E7;

		76 : Edmond_set_WHITE_F7;

		77 : Edmond_set_WHITE_G7;

		78 : Edmond_set_WHITE_H7;

		81 : Edmond_set_WHITE_A8;

		82 : Edmond_set_WHITE_B8;

		83 : Edmond_set_WHITE_C8;

		84 : Edmond_set_WHITE_D8;

		85 : Edmond_set_WHITE_E8;

		86 : Edmond_set_WHITE_F8;

		87 : Edmond_set_WHITE_G8;

		88 : Edmond_set_WHITE_H8;
	end;
end;




END.
