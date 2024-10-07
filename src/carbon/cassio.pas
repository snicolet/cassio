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
   loc        : Point;
   k          : integer;

begin
	LogDebugInfo('Bienvenue dans Cassio !');
	
	tick := Tickcount();
	LogDebugInfo('Milliseconds is ' + IntToStr(Milliseconds()));
	
	InitQuickdraw(carbon);

	//sleep(200);

	counter := -1;
	repeat
	   counter := counter + 1;

	   ReadTaskOutput(carbon);
	   
	   if (counter = 0) then
	      for k := 1 to 100 do
	         QuickDraw.SendCommand('hello ' + IntToStr(k));
	
	   if (counter >= 0) and (counter < 100) then
	   begin
	      s := 'hola ' + IntToStr(counter) ;
          QuickDraw.SendCommand(s);
       end;

       // sleep(n) yields time to the operating system, where n is in milliseconds
       // with sleep(0)  : Cassio uses about 100% of one processor
       // with sleep(1)  : Cassio uses about 2.4% of one processor
       // with sleep(10) : Cassio uses about 0.1% of one precessor
       sleep(1);
       

       if (Tickcount() - tick >= 60) then
       begin
          tick := Tickcount();
          LogDebugInfo('[Cassio]   > calling GetMouse() from main loop');
          loc := GetMouse();
       end;

       //sleep(30);

    until false;
	//until output = 'quit';

	ReleaseQuickDraw;

end.


