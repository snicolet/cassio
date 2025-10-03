

UNIT Unit_Test_GNU_Pascal;


INTERFACE



procedure Test_GNU_Pascal;                                                                                                                                                          ATTRIBUTE_NAME('Test_GNU_Pascal')




IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}











const kMargin = 15;


procedure Test_GNU_Pascal;
var a,b,c : integer;
begin

  a := 22;
  b := 12;
  c := b - 1;

  (* The following line gives an internal compiler error *)

  if ((a - kMargin) mod b) = c then
    begin
    end;

end;


END.
