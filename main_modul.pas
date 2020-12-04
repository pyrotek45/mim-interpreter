program Main_model;
{$mode objfpc}{$H+}
uses
    sysutils,
    strutils,
    fgl,
    classes,
    crt,
    modul_interpreter;

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
