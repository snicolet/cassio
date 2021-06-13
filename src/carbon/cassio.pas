program cassio;

// compile with FreePascal using the commands:
//    fpc -Mobjfpc -Sh -ocassio.exe cassio.pas


uses
{$IFDEF UNIX}
  CThreads,
  CWString,
{$ENDIF}
  Classes, 
  SysUtils,
  Process, 
  Connect;


var 
   carbon     : Task;
   output     : ansistring;
   s          : ansistring;
   counter    : integer;

begin
	writeln('Bienvenue dans Cassio !');
	
	carbon.process := TProcess.Create(nil);
	carbon.process.executable := './carbon.sh';
	
	CreateConnectedProcess(carbon, @InterpretProcessOutput);
	
	//sleep(5000);
	
	counter := 0;
	output := '';
	repeat
	   counter := counter + 1;

	   output := ReadProcessOutput(carbon);
	   
	   if (counter >= 0) and (counter < 100) then
	   begin
	      s := 'CARBON-PROTOCOL hola ' + IntToStr(counter) ;
	      writeln('[DEBUG Cassio] > ' + s);
          WriteProcessInput(carbon, s);
       end;
    
       // sleep(n) yields time to the operating system, where n is in milliseconds
       // with sleep(0)  : Cassio uses about 100% of one processor
       // with sleep(1)  : Cassio uses about 2.4% of one processor
       // with sleep(10) : Cassio uses about 0.1% of one precessor
       sleep(1);
	   
    until false;
	//until output = 'quit';
	
    
	
	FreeConnectedProcess(carbon);

	
end.


