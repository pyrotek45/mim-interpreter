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

procedure SaveString(InString, OutFilePath: string);
var
    F: TextFile;
begin
    AssignFile(F, OutFilePath);
    try
        ReWrite(F);
        Write(F, InString);
    finally
    CloseFile(F);
    end;
end;

var
    modul_file,setup_file : textfile;
    command,input,filename: string;
    I : integer;
    mim : mim_interpreter;
begin

    if paramstr(1) = '' then
    begin
        //writeln('no file: use mim <filename>');
        repl;
        exit;
    end;

    mim := mim_interpreter.create;

    Assignfile(setup_file, paramstr(1));
    reset(setup_file);

    while not eof(setup_file) do begin
        readln(setup_file,command); 
        if not (command = '') then begin
            //writeln('FULL COMMAND: ',lowercase(command));
            mim.parse(lowercase(command));
            //mim.get_full_info;
            //SaveString(mim.variable_str,'mim_log.mh')
        end;
    end;

    //writeln(mim.get_memory: 0: 2);

    CloseFile(setup_file);
    mim.destroy;
end.
