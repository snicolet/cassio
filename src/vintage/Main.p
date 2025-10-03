PROGRAM Cassio_7_6;



{ Ruse : on met des faux mots clefs pour tromper la precompilation de Cassio }
{
UNIT
INTERFACE
IMPLEMENTATION


{BEGIN_USE_CLAUSE}



{END_USE_CLAUSE}



{ la (vraie) fonction main est definie dans Cassio.p }
procedure MainDeCassio;               EXTERNAL_NAME('MainDeCassio');




{ le programme principal de Cassio }
begin
  MainDeCassio;
end.

