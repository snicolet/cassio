UNIT UnitATR;

{cf http://www.cs.princeton.edu/~rs/strings/}

INTERFACE







USES UnitDefCassio , UnitDefATR;





{Creation et destruction}
function MakeEmptyATR : ATR;
procedure DisposeATR(var theATR : ATR);

{fonction d'insertion dans un ATR}
procedure InsererDansATR(var arbre : ATR; const chaine : String255);

{Affichages}
procedure AfficherATRNodeDansRapport(var x : ATR);
procedure ATRAffichageInfixe(nomATR : String255; x : ATR);

{Iterateurs}
procedure ATRParcoursInfixe(x : ATR ; DoWhatBefore,DoWhatAfter : ATRProc);


{Acces et tests sur les ATR}
function TrouveATRDansChaine(x : ATR; const chaine : String255; var position : SInt32) : boolean;
function TrouveATRDansBuffer(x : ATR; buffer : Ptr; longueur : SInt32; var position : SInt32) : boolean;
function TrouveSuffixeDeChaineDansATR(x : ATR; const chaine : String255; var position : SInt32) : boolean;
function TrouveSuffixeDeChaineCommePrefixeDansATR(x : ATR; const chaine : String255; var position : SInt32) : boolean;

function TrouveChaineDansATR(x : ATR; const chaine : String255) : boolean;
function ChaineEstPrefixeDansATR(x : ATR; const chaine : String255) : boolean;
function ATREstPrefixeDeChaine(x : ATR; const chaine : String255) : boolean;


function ATRIsEmpty(x : ATR) : boolean;
function ATRHauteur(x : ATR) : SInt32;

{Test de l'unite}
procedure TestUnitATR;

IMPLEMENTATION


{BEGIN_USE_CLAUSE}


{$DEFINEC USE_PRELINK true}


{$IFC NOT(USE_PRELINK)}
USES
    MyMathUtils, UnitServicesMemoire, UnitRapport, MyStrings, UnitPagesATR ;
{$ELSEC}
    {$I prelink/ATR.lk}
{$ENDC}


{END_USE_CLAUSE}










const kCaractereSentinelle = chr(0);

function MakeEmptyATR : ATR;
begin
  MakeEmptyATR := NIL;
end;

procedure DisposeATR(var theATR : ATR);
begin
  if theATR <> NIL then
    begin
      DisposeATR(theATR^.filsMoins);
      DisposeATR(theATR^.filsEgal);
      DisposeATR(theATR^.filsPlus);

      DisposeATRPaginee(theATR);
      theATR := NIL;
    end;
end;


procedure ATRParcoursInfixe(x : ATR ; DoWhatBefore,DoWhatAfter : ATRProc);
begin
  if x <> NIL then
    begin
      {WriteStringDansRapport('(');}
      ATRParcoursInfixe(x^.filsMoins,DoWhatBefore,DoWhatAfter);
      DoWhatBefore(x);
      ATRParcoursInfixe(x^.filsEgal,DoWhatBefore,DoWhatAfter);
      DoWhatAfter(x);
      ATRParcoursInfixe(x^.filsPlus,DoWhatBefore,DoWhatAfter);
      {WriteStringDansRapport(')');}
    end;
end;

var chaineAffichageATR : String255;

procedure AfficherATRNodeDansRapport(var x : ATR);
begin
  if x = NIL
    then
      WritelnDansRapport('ATR = NIL !')
    else
      begin
        if x^.splitChar = kCaractereSentinelle
          then WritelnStringDansRapport(chaineAffichageATR);

        SET_LENGTH_OF_STRING(chaineAffichageATR, LENGTH_OF_STRING(chaineAffichageATR) + 1);
        chaineAffichageATR[LENGTH_OF_STRING(chaineAffichageATR)] := x^.splitChar;
        {WriteStringDansRapport(x^.splitChar);}
      end;
end;

procedure OublierATRNodeEtSauterLigneDansRapport(var x : ATR);
begin  {$UNUSED x}
  if x = NIL
    then
      WritelnDansRapport('ATR = NIL !')
    else
      begin
        SET_LENGTH_OF_STRING(chaineAffichageATR,LENGTH_OF_STRING(chaineAffichageATR) - 1);
        {WritelnDansRapport('');}
      end;
end;


procedure ATRAffichageInfixe(nomATR : String255; x : ATR);
begin
  WritelnDansRapport('ATR : '+nomATR);

  chaineAffichageATR := '';
  ATRParcoursInfixe(x,AfficherATRNodeDansRapport,OublierATRNodeEtSauterLigneDansRapport);
end;

{renvoie true si le suffixe de "chaine" commencant a
 la position "indexDepart", est prefixe de l'une
 des chaines stockees dans l'ATR "x"}
function SuffixeDeChaineEstPrefixeDansATR(x : ATR; const chaine : String255; indexDepart,longueur : SInt32) : boolean;
var index : SInt32;
    p : ATR;
    c : char;
begin
  p := x;
  index := indexDepart;
  if indexDepart <= longueur then
    begin
		  while (p <> NIL) do
		    with p^ do
			    begin
			      c := chaine[index];

			      if c < splitChar then p := filsMoins else
			      if c > splitChar then p := filsPlus else
			      {if c = splitChar then}
			        begin
			          inc(index);
			          if index > longueur then
			            begin
			              SuffixeDeChaineEstPrefixeDansATR := true;
			              exit(SuffixeDeChaineEstPrefixeDansATR);
			            end;
			          p := filsEgal;
			          if (p = NIL) then
			            begin
			              SuffixeDeChaineEstPrefixeDansATR := false;
			              exit(SuffixeDeChaineEstPrefixeDansATR);
			            end;
			        end;
			    end;
		end;
  SuffixeDeChaineEstPrefixeDansATR := false;
end;

{renvoie true si l'une des chaines stockees dans l'ATR "x"
 est sous-mot, a partir de "indexDepart", de la chaine "chaine".
 Le parametre "longueur" doit etre la longueur totale de la
 chaine "chaine".}
function ATREstSousMotDeChaine(x : ATR; const chaine : String255; indexDepart,longueur : SInt32) : boolean;
var index : SInt32;
    p : ATR;
    c : char;
begin
  p := x;
  index := indexDepart;
  if indexDepart <= longueur then
    begin
		  while (p <> NIL) do
		    with p^ do
			    begin
			      c := chaine[index];

			      if c < splitChar then p := filsMoins else
			      if c > splitChar then p := filsPlus else
			      {if c = splitChar then}
			        begin
			          inc(index);
			          p := filsEgal;
			          if (p = NIL) or (p^.splitChar = kCaractereSentinelle) then
			            begin
			              ATREstSousMotDeChaine := true;
			              exit(ATREstSousMotDeChaine);
			            end;
			          if (index > longueur) then
			            begin
			              ATREstSousMotDeChaine := false;
			              exit(ATREstSousMotDeChaine);
			            end;
			        end;
			    end;
		end;
  ATREstSousMotDeChaine := false;
end;

{renvoie true si l'une des chaines stockees dans l'ATR "x"
 est sous-mot, a partir de "indexDepart", du buffer "buffer"
 qui doit pointer vers un array[0..longueur-1] of char}
function ATREstSousMotDeBuffer(x : ATR; buffer : Ptr; indexDepart,longueur : SInt32) : boolean;
var index : SInt32;
    p : ATR;
    c : char;
    localBuffer : PackedArrayOfCharPtr;
begin
  p := x;
  index := indexDepart;
  if (buffer <> NIL) and (indexDepart < longueur) then
    begin
      localBuffer := PackedArrayOfCharPtr(buffer);
		  while (p <> NIL) do
		    with p^ do
			    begin
			      c := localBuffer^[index];

			      if c < splitChar then p := filsMoins else
			      if c > splitChar then p := filsPlus else
			      {if c = splitChar then}
			        begin
			          inc(index);
			          p := filsEgal;
			          if (p = NIL) or (p^.splitChar = kCaractereSentinelle) then
			            begin
			              ATREstSousMotDeBuffer := true;
			              exit(ATREstSousMotDeBuffer);
			            end;
			          if (index >= longueur) then
			            begin
			              ATREstSousMotDeBuffer := false;
			              exit(ATREstSousMotDeBuffer);
			            end;
			        end;
			    end;
		end;
  ATREstSousMotDeBuffer := false;
end;

{TrouveATRDansChaine(x,chaine,i) : renvoie true si l'une des chaines
 de l'ATR "x" est un sous-mot de "chaine"; dans ce cas, "position" est
 la position de ce sous-mot dans chaine}
function TrouveATRDansChaine(x : ATR; const chaine : String255; var position : SInt32) : boolean;
var longueur,i : SInt32;
begin
  longueur := LENGTH_OF_STRING(chaine);
  for i := 1 to longueur do
    if ATREstSousMotDeChaine(x,chaine,i,longueur) then
      begin
        position := i;
        TrouveATRDansChaine := true;
        exit(TrouveATRDansChaine);
      end;
  TrouveATRDansChaine := false;
  position := -1;
end;


{TrouveATRDansBuffer(x,chaine,i) : renvoie true si l'une des chaines
 de l'ATR "x" est un sous-mot de "buffer", qui doit pointer vers un
 array[0..longueur-1] of char; dans ce cas, "position" est la position
 de ce sous-mot dans le buffer}
function TrouveATRDansBuffer(x : ATR; buffer : Ptr; longueur : SInt32; var position : SInt32) : boolean;
var i : SInt32;
begin
  for i := 0 to longueur-1 do
    if ATREstSousMotDeBuffer(x,buffer,i,longueur) then
      begin
        position := i;
        TrouveATRDansBuffer := true;
        exit(TrouveATRDansBuffer);
      end;
  TrouveATRDansBuffer := false;
  position := -1;
end;


{TrouveSuffixeDeChaineCommePrefixeDansATR(x,chaine,i) : renvoie true si l'un des suffixes
 de la chaine "chaine" est prefixe de l'une des chaines de l'ATR "x"; dans ce cas,
 ce suffixe commence a la position "position" dans "chaine"}
function TrouveSuffixeDeChaineCommePrefixeDansATR(x : ATR; const chaine : String255; var position : SInt32) : boolean;
var longueur,i : SInt32;
begin
  longueur := LENGTH_OF_STRING(chaine);
  for i := 1 to longueur do
    if SuffixeDeChaineEstPrefixeDansATR(x,chaine,i,longueur) then
      begin
        position := i;
        TrouveSuffixeDeChaineCommePrefixeDansATR := true;
        exit(TrouveSuffixeDeChaineCommePrefixeDansATR);
      end;
  TrouveSuffixeDeChaineCommePrefixeDansATR := false;
  position := -1;
end;

{TrouveSuffixeDeChaineDansATR(x,chaine,i) : renvoie true si l'un des suffixes
 de la chaine "chaine" est exactement l'une des chaines de l'ATR "x"; dans ce cas,
 ce suffixe commence a la position "position" dans chaine}
function TrouveSuffixeDeChaineDansATR(x : ATR; const chaine : String255; var position : SInt32) : boolean;
var longueur,i : SInt32;
    s : String255;
begin
  s := Concat(chaine,kCaractereSentinelle);
  longueur := LENGTH_OF_STRING(s);
  for i := 1 to longueur - 1 do
    if SuffixeDeChaineEstPrefixeDansATR(x,s,i,longueur) then
      begin
        position := i;
        TrouveSuffixeDeChaineDansATR := true;
        exit(TrouveSuffixeDeChaineDansATR);
      end;
  TrouveSuffixeDeChaineDansATR := false;
  position := -1;
end;


{TrouveChaineDansATR(x,chaine) : renvoie true si "chaine" est exactement l'une
des chaines de l'ATR "x"}
function TrouveChaineDansATR(x : ATR; const chaine : String255) : boolean;
var s : String255;
begin
  s := Concat(chaine,kCaractereSentinelle);
  TrouveChaineDansATR := SuffixeDeChaineEstPrefixeDansATR(x,s,1,LENGTH_OF_STRING(s));
end;

{ChaineEstPrefixeDansATR(x,chaine) : renvoie true si "chaine" est prefixe de l'une des
 chaines de l'ATR "x"}
function ChaineEstPrefixeDansATR(x : ATR; const chaine : String255) : boolean;
begin
  ChaineEstPrefixeDansATR := SuffixeDeChaineEstPrefixeDansATR(x,chaine,1,LENGTH_OF_STRING(chaine));
end;

{ATREstPrefixeDeChaine(x,chaine) : renvoie true si "chaine" commence par l'une
 des chaines de l'ATR "x"}
function ATREstPrefixeDeChaine(x : ATR; const chaine : String255) : boolean;
begin
  ATREstPrefixeDeChaine := ATREstSousMotDeChaine(x,chaine,1,LENGTH_OF_STRING(chaine));
end;


function ATRIsEmpty(x : ATR) : boolean;
begin
  ATRIsEmpty := (x = NIL);
end;

function ATRHauteur(x : ATR) : SInt32;
var a,b,c : SInt32;
begin
  if x = NIL
    then ATRHauteur := 0
    else
      begin
        a := ATRHauteur(x^.filsMoins);
        b := ATRHauteur(x^.filsPlus);
        c := ATRHauteur(x^.filsEgal);
        ATRHauteur := 1+Max(Max(a,b),c);
      end;
end;


procedure InsererDansATR(var arbre : ATR; const chaine : String255);
var longueur,index : SInt32;
    c : char;
    s : String255;

		procedure ATRInsererRecursivement(var x : ATR);
		begin
		  if index <= longueur then
		    begin
		      if x = NIL
		        then
		          begin
		            x := NewATRPaginee;
		            if x <> NIL then
		              with x^ do
		                begin
		                  splitChar := s[index];
		                  filsMoins := NIL;
		                  filsEgal := NIL;
		                  filsPlus := NIL;
		                  index := succ(index);
		                  ATRInsererRecursivement(filsEgal);
		                end;
		          end
		        else
		          with x^ do
			          begin
			            c := s[index];

			            if c < splitChar then  ATRInsererRecursivement(filsMoins) else
			            if c > splitChar then  ATRInsererRecursivement(filsPlus) else
			           {if c = splitChar then}
			             begin
			               index := succ(index);
			               ATRInsererRecursivement(filsEgal);
			             end;
			          end;
		    end;
		end;

begin
  s := Concat(chaine,kCaractereSentinelle);
  longueur := LENGTH_OF_STRING(s);
  if (longueur > 1) then
    begin
		  index := 1;
		  ATRInsererRecursivement(arbre);
		end;
end;


procedure TestUnitATR;
var arbre : ATR;
    {i : SInt32;}
    s : String255;
begin
  {WritelnSoldesCreationsPropertiesDansRapport('entrŽe dans TestATR : ');}


  arbre := MakeEmptyATR;
  ATRAffichageInfixe('ensemble vide arbre',arbre);
  DisposeATR(arbre);

  {WritelnSoldesCreationsPropertiesDansRapport('aprs ensemble vide : ');}
  s := 'blah blah';

  arbre := MakeEmptyATR;
  InsererDansATR(arbre,s);
  InsererDansATR(arbre,'toto est grand');
  InsererDansATR(arbre,'cassio 5.1.2');
  InsererDansATR(arbre,'tastet');
  InsererDansATR(arbre,'cassio');
  InsererDansATR(arbre,'total fina');
  InsererDansATR(arbre,'c');
  InsererDansATR(arbre,'nicolet');
  InsererDansATR(arbre,'zebra');
  InsererDansATR(arbre,'cassio 5.1.5');
  InsererDansATR(arbre,'tastet serge');
  InsererDansATR(arbre,'cassio 5.1.6');

  ATRAffichageInfixe('ATR infixe',arbre);

  {
  WritelnStringAndBooleanDansRapport('tastet => ',TrouveATRDansChaine(arbre,'tastet',i));
  WritelnStringAndBooleanDansRapport('tastet marc => ',TrouveATRDansChaine(arbre,'tastet marc',i));
  WritelnStringAndBooleanDansRapport('toto => ',TrouveATRDansChaine(arbre,'toto',i));
  WritelnStringAndBooleanDansRapport('cassio  => ',TrouveATRDansChaine(arbre,'cassio ',i));
  WritelnStringAndBooleanDansRapport('compoth => ',TrouveATRDansChaine(arbre,'compoth',i));
  WritelnStringAndBooleanDansRapport('zebr => ',TrouveATRDansChaine(arbre,'zebr',i));
  WritelnStringAndBooleanDansRapport('wzebra => ',TrouveATRDansChaine(arbre,'wzebra',i));
  WritelnStringAndBooleanDansRapport('wzebra 2.0.1 => ',TrouveATRDansChaine(arbre,'wzebra 2.0.1',i));


  WritelnStringAndBooleanDansRapport('tastet => ',ChaineEstPrefixeDansATR(arbre,'tastet'));
  WritelnStringAndBooleanDansRapport('tastet marc => ',TrouveSuffixeDeChaineDansATR(arbre,'tastet marc',i));
  WritelnStringAndBooleanDansRapport('toto => ',TrouveSuffixeDeChaineDansATR(arbre,'toto',i));
  WritelnStringAndBooleanDansRapport('cassio  => ',TrouveSuffixeDeChaineDansATR(arbre,'cassio ',i));
  WritelnStringAndBooleanDansRapport('compoth => ',TrouveSuffixeDeChaineDansATR(arbre,'compoth',i));
  WritelnStringAndBooleanDansRapport('zebr => ',TrouveSuffixeDeChaineDansATR(arbre,'zebr',i));
  WritelnStringAndBooleanDansRapport('wzebra => ',TrouveSuffixeDeChaineDansATR(arbre,'wzebra',i));
  WritelnStringAndBooleanDansRapport('wzebra 2.0.1 => ',TrouveSuffixeDeChaineDansATR(arbre,'wzebra 2.0.1',i));
  }

  DisposeATR(arbre);

  {WritelnSoldesCreationsPropertiesDansRapport('sortie de TestATR : ');}
end;


END.
