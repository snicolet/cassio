UNIT UnitTestProperties;



INTERFACE








procedure TesterProperties;


IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    UnitDefCassio
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, UnitProperties, UnitPropertyList, UnitArbreDeJeuCourant, UnitScannerUtils, UnitGameTree ;
{$ELSEC}
    ;
    {$I prelink/TestProperties.lk}
{$ENDC}


{END_USE_CLAUSE}











procedure DoublePropertyInfos(var prop : Property);
begin
  if prop.stockage = StockageEnLongint then
    SetLongintInfoOfProperty(prop,2*GetLongintInfoOfProperty(prop));
end;



function SquarePropertyInfos(prop : Property) : Property;
var aux : SInt32;
begin
  if prop.stockage = StockageEnLongint
    then
      begin
        aux := GetLongintInfoOfProperty(prop);
        SquarePropertyInfos := MakeLongintProperty(prop.genre,aux*aux);
      end
    else
      begin
        SquarePropertyInfos := MakeEmptyProperty;
      end;
end;



procedure TesterProperties;
var G1,G2{,G3,G4,G5} : GameTree;
    prop : Property;
    s : String255;
    err : OSErr;
begin

  s := 'courte chaine';
  prop := MakeStringProperty(CommentProp,s);
  WritelnStringAndPropertyDansRapport('prop = ',prop);

  s := '';
  s := GetStringInfoOfProperty(prop);
  WritelnDansRapport('s = '+s);


  s := 'et voici une chaine qui est beaucoup beaucoup plus longue';
  SetStringInfoOfProperty(prop,s);
  WritelnStringAndPropertyDansRapport('prop = ',prop);

  s := '';
  s := GetStringInfoOfProperty(prop);
  WritelnDansRapport('s = '+s);

  s := '';
  SetStringInfoOfProperty(prop,s);
  WritelnStringAndPropertyDansRapport('prop = ',prop);

  s := '';
  s := GetStringInfoOfProperty(prop);
  WritelnDansRapport('s = '+s);

  DisposePropertyStuff(prop);

  s := 'e3';
  prop := MakeStringProperty(CommentProp,s);
  WritelnStringAndPropertyDansRapport('prop = ',prop);

  s := 'еееееееееееееееееееееееееееееееееееееееееееее';
  s := GetStringInfoOfProperty(prop);
  WritelnDansRapport('s = '+s);

  DisposePropertyStuff(prop);

  s := '';
  prop := MakeStringProperty(CommentProp,s);
  WritelnStringAndPropertyDansRapport('prop = ',prop);

  s := 'еееееееееееееееееееееееееееееееееееееееееееее';
  s := GetStringInfoOfProperty(prop);
  WritelnDansRapport('s = '+s);

  DisposePropertyStuff(prop);


  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('F5'),pionNoir,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 1.F5 :');
  WritelnDansRapport('');

  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('D6'),pionBlanc,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 2.D6 :');
  WritelnDansRapport('');

  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('C3'),pionNoir,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 3.C3 :');
  WritelnDansRapport('');

  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  ChangeCurrentNodeForBackMove;
  ChangeCurrentNodeForBackMove;
  ChangeCurrentNodeForBackMove;
  ChangeCurrentNodeForBackMove;
  ChangeCurrentNodeForBackMove;

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('F5'),pionNoir,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 1.F5 :');
  WritelnDansRapport('');

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('  f6  '),pionBlanc,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 2.F6 :');
  WritelnDansRapport('');

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup(' e6'),pionNoir,'testerProperties');
  WritelnDansRapport('');
  WritelnDansRapport('Apres 3.E6 :');
  WritelnDansRapport('');

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  SetCurrentNodeToGameRoot;

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('F5'),pionNoir,'testerProperties');
  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('F4'),pionBlanc,'testerProperties');

  ChangeCurrentNodeForBackMove;

  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('F6'),pionBlanc,'testerProperties');
  err := ChangeCurrentNodeAfterNewMove(StringEnCoup('E6'),pionNoir,'testerProperties');

  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  G2 := GetCurrentNode;
  MakeMainLineInGameTree(G2);

  G1 := GetRacineDeLaPartie;
  WritelnStringAndGameTreeDansRapport('racine = ' + chr(13),G1);

  G2 := GetCurrentNode;
  WritelnStringAndGameTreeDansRapport('GameTreeCourant = ' + chr(13),G2);

  ChangeCurrentNodeForBackMove;
  ChangeCurrentNodeForBackMove;
  {
  EcritProchainsCoupsSurOthellier(pionBlanc);
  }
  SetCurrentNodeToGameRoot;

end;



end.
