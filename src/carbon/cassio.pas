program cassio;

// usage : compile with FreePascal using the following command
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas 2>&-        (to suppress link warnings)


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
   loc        : Point;
   k          : integer;

begin
	LogDebugInfo('Bienvenue dans Cassio !');
	
	tick := Tickcount();
	LogDebugInfo('Milliseconds is ' + IntToStr(Milliseconds()));
	
	InitQuickdraw(carbon);

	sleep(200);

	counter := -1;
	repeat
	   counter := counter + 1;

	   ReadTaskOutput(carbon);
	   
	   // test 1 : send a bunch of dummy "hello" commands, all at the same time
	   if (counter = 0) then
	      for k := 1 to 99 do
	         QuickDraw.SendCommand('hello ' + IntToStr(k) , nil);
	
	   // test 2 : send a bunch of dummy "hola" commands, at 1ms intervals
	   if (counter >= 0) and (counter < 100) then
	   begin
	      s := 'hola ' + IntToStr(counter) ;
          QuickDraw.SendCommand(s, nil);
       end;

       // sleep(n) yields time to the operating system, where n is in milliseconds
       // with sleep(0)  : Cassio uses about 100% of one processor
       // with sleep(1)  : Cassio uses about 2.4% of one processor
       // with sleep(10) : Cassio uses about 0.1% of one precessor
       sleep(1);
       

       //if (Tickcount() - tick >= 30) then
       begin
          tick := Tickcount();
          loc := GetMouse();
          //writeln(loc.h, ' ' , loc.v);
       end;

    until false;

	ReleaseQuickDraw;

end.


