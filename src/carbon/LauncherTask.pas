unit LauncherTask;

interface

type
  Task = class
    public
      procedure run(processName : string);
  end;


implementation

uses 
   Classes, 
   SysUtils;


procedure Task.run(processName : string);
begin
	writeln('LauncherTask.run() : ' + processName);
end;


end.


