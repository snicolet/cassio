program cassio;

// compile with FreePascal using the commands:
//    fpc -Mobjfpc -ocassio.exe cassio.pas


uses  
  Classes, 
  SysUtils, 
  LauncherTask;

var 
   launcher : Task;

begin
	launcher.create();
	
	writeln('Bienvenue dans Cassio !');
	launcher.run('./carbon.py');
	
	launcher.free();
end.


