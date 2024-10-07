program cassio;

// compile with FreePascal using the commands:
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas


uses
{$IFDEF UNIX}
  cmem,
  cthreads,
  cwstring,
{$ENDIF}
  Classes,
  SysUtils,
  Process,
  Connect,
  QuickDraw;


var
   carbon     : Task;
   s          : ansistring;
   counter    : integer;
   tick       : qword;

begin
	writeln('Bienvenue dans Cassio !');
	
	tick := Tickcount();
	writeln('Milliseconds is ' + IntToStr(Milliseconds()));
	
	InitQuickdraw(carbon);

	//sleep(200);

	counter := 0;
	repeat
	   counter := counter + 1;

	   ReadTaskOutput(carbon);
	
	   if (counter >= 0) and (counter < 100) then
	   begin
	      s := 'CARBON-PROTOCOL hola ' + IntToStr(counter) ;
	      writeln('[DEBUG Cassio] > ' + s);
          WriteTaskInput(carbon, s);
       end;

       // sleep(n) yields time to the operating system, where n is in milliseconds
       // with sleep(0)  : Cassio uses about 100% of one processor
       // with sleep(1)  : Cassio uses about 2.4% of one processor
       // with sleep(10) : Cassio uses about 0.1% of one precessor
       sleep(1);
       

       if (Tickcount() - tick >= 60) then
       begin
          tick := Tickcount();
          writeln('Tickcount = ' + IntToStr(Tickcount()) + '  , Milliseconds = ' + IntToStr(Milliseconds()));
       end;

       //sleep(30);

    until false;
	//until output = 'quit';

	ReleaseQuickDraw;

end.


