program Main_model;
{$mode objfpc}{$H+}
uses
  sysutils,
  strutils,
  fgl,
  classes,
  crt,
  modul_interpreter;

procedure repl;
var
  user : string;
  mim : mim_interpreter;

begin
  mim := mim_interpreter.create;

  writeln('type exit to close the program');
  writeln('type reset to clear mim');

  repeat
    write('>> ');
    readln(user);

    case (user) of
      //'help': {*show help screen*};
      'reset' :
        begin
          mim.free;
          mim := mim_interpreter.create;
        end;
    end;

    if not (user = '') then begin
        mim.parse(lowercase(user));
    end;

  until (lowercase(user) = 'exit');
end;

var
  mim : mim_interpreter;
  source : TStringlist;
  line : string;

begin

  //Testing for command line parameter
  if paramstr(1) = '' then
   begin
      //writeln('no file: use mim <filename>');
      repl;
      exit;
  end;

  //Creating the interpreter
  mim := mim_interpreter.create;

  //Loading the source code
  source := TStringlist.create();
  source.LoadFromFile(paramstr(1));

  //Send each line into the interpreter
  for line in source do
  begin
    mim.parse(lowercase(line));
  end;

  //Free the interpreter from memory
  mim.destroy;

end.
