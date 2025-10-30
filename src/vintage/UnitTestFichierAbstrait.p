UNIT UnitTestFichierAbstrait;



INTERFACE





 USES UnitDefCassio;


procedure WritelnFichierAbstraitDansRapport(theFile : FichierAbstrait);
procedure WritelnStringAndFichierAbstraitDansRapport(s : String255; theFile : FichierAbstrait);

procedure TesteFichierAbstrait;




IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}

USES
    OSUtils
{$IFC NOT(USE_PRELINK)}
    , UnitRapport, MyStrings, UnitFichiersTEXT, UnitFichierAbstrait ;
{$ELSEC}
    ;
    {$I prelink/TestFichierAbstrait.lk}
{$ENDC}


{END_USE_CLAUSE}














procedure WritelnFichierAbstraitDansRapport(theFile : FichierAbstrait);
begin
  with theFile do
    begin
      WritelnDansRapport('theFile.data = '+IntToStr(SInt32(infos)));
      WritelnDansRapport('theFile.tailleMaximalePossible = '+IntToStr(tailleMaximalePossible));
      WritelnDansRapport('theFile.nbOctetsOccupes = '+IntToStr(nbOctetsOccupes));
      WritelnDansRapport('theFile.position = '+IntToStr(position));
      WritelnDansRapport('theFile.tailleMaximalePossible = '+IntToStr(tailleMaximalePossible));
      WritelnDansRapport('theFile.genre = '+IntToStr(SInt32(genre)));
      WritelnDansRapport('');
    end;
end;



procedure WritelnStringAndFichierAbstraitDansRapport(s : String255; theFile : FichierAbstrait);
begin
  WritelnDansRapport(s);
  WritelnFichierAbstraitDansRapport(theFile);
end;



procedure TesteFichierAbstrait;
var Z1,Z2,Z3,Z4,Z5 : FichierAbstrait;
    s : String255;
    err : OSErr;
    borne,i,tick : SInt32;
    c : char;
begin

  SetDebuggageUnitFichiersTexte(false);

  Z1 := NewEmptyFichierAbstrait;
  Z2 := NewEmptyFichierAbstrait;
  Z3 := NewEmptyFichierAbstrait;
  Z4 := NewEmptyFichierAbstrait;
  Z5 := NewEmptyFichierAbstrait;



  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);
  {WritelnStringAndFichierAbstraitDansRapport('Z2 = ',Z2);
  WritelnStringAndFichierAbstraitDansRapport('Z3 = ',Z3);
  WritelnStringAndFichierAbstraitDansRapport('Z4 = ',Z4);
  WritelnStringAndFichierAbstraitDansRapport('Z5 = ',Z5);}


  Z1 := MakeFichierAbstraitFichier('toto est grand',0);

  {
  name := 'Bonifacio:CW9 Gold:Cassio 3.5.68k.CW9 Ä:sans titre';
  Z2 := MakeFichierAbstraitFichier(name,0);

  }

  Z3 := MakeFichierAbstraitEnMemoire(-1);
  Z4 := MakeFichierAbstraitEnMemoire(1000);


  {name := 'PrŽfŽrences Cassio 3.5 (68k)';
  Z5 := MakeFichierAbstraitFichier(name,pathCassioFolder);}


  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);
 { WritelnStringAndFichierAbstraitDansRapport('Z2 = ',Z2);
 }
  WritelnStringAndFichierAbstraitDansRapport('Z3 = ',Z3);
  WritelnStringAndFichierAbstraitDansRapport('Z4 = ',Z4);
  {
  WritelnStringAndFichierAbstraitDansRapport('Z5 = ',Z5);}


  err := ViderFichierAbstrait(Z1);
  {
  err := ViderFichierAbstrait(Z2);
  }
  err := ViderFichierAbstrait(Z3);
  err := ViderFichierAbstrait(Z4);
  {
  err := ViderFichierAbstrait(Z5);
  }


  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := WritelnDansFichierAbstrait(Z1,'0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789');
  WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);

  err := SetPositionMarqueurFichierAbstrait(Z1,0);

  tick := TickCount;

  borne := Z1.nbOctetsOccupes;
  for i := 1 to borne+10 do
    begin
      err := GetNextCharOfFichierAbstrait(Z1,c);
      {
      WritelnDansRapport('err['+IntToStr(i)+'] = '+IntToStr(Err));
      WritelnDansRapport('ord(c) = '+IntToStr(ord(c))+' et c ='+c);
      }
    end;

  WritelnNumDansRapport('temps pour lire '+IntToStr(borne+10)+' octets = ',TickCount-tick);

  err := ReadlnDansFichierAbstrait(Z1,s);
  WritelnDansRapport('');
  WritelnNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);

  err := ReadlnDansFichierAbstrait(Z1,s);
  WritelnDansRapport('');
  WritelnNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);

  err := ReadlnDansFichierAbstrait(Z1,s);
  WritelnDansRapport('');
  WritelnNumDansRapport('err = ',err);
  WritelnDansRapport('ligne lue = '+s);



  DisposeFichierAbstrait(Z1);
  DisposeFichierAbstrait(Z2);

  DisposeFichierAbstrait(Z3);
  DisposeFichierAbstrait(Z4);

  DisposeFichierAbstrait(Z5);

  {WritelnStringAndFichierAbstraitDansRapport('Z1 = ',Z1);
  WritelnStringAndFichierAbstraitDansRapport('Z2 = ',Z2);
  WritelnStringAndFichierAbstraitDansRapport('Z3 = ',Z3);
  WritelnStringAndFichierAbstraitDansRapport('Z4 = ',Z4);
  WritelnStringAndFichierAbstraitDansRapport('Z5 = ',Z5);}


  SetDebuggageUnitFichiersTexte(false);

end;

end.
