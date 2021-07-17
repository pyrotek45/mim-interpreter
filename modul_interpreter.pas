unit modul_interpreter;
{$mode objFPC}
interface
uses
    SysUtils,
    strutils,
    fgl,
    character,
    Classes;

type
    TMap_variable = specialize 
        TFPGMap<string, extended>;

    Tmap_modules = specialize 
        TFPGMap<string, TStringList>;

    floatlist = specialize 
        TFPGlist<extended>;

    stringlist = specialize 
        TFPGlist<string>;

    mim_interpreter = class
    private
        user_input: string;
        memory: extended;
        parameters : floatlist;
        parameters_id : stringlist;
        parameter_count :integer;
        functions: TStringList;
        variables: TMap_variable;
        function_modules: Tmap_modules;
        current_module: string;
        global_recording: boolean;
        current_condition: boolean;
        procedure load_parameters(command: string);
        procedure load_return(command: string);
        function load_array(parameter: string):string;
        procedure _mem(command: string);
        procedure _var(command: string);
        procedure _add(command: string);
        procedure _sub(command: string);
        procedure _mul(command: string);
        procedure _div(command: string);
        procedure _swp(command: string);
        procedure _con(command: string);
        procedure _smd(command: string);
        procedure _emd(command: string);
        procedure _dot(command: string);
        procedure _sho(command: string);
        procedure _del(command: string);
        procedure _rnd(command: string);
        procedure _get(command: string);
        procedure _inp(command: string);
    public
        function variable_str(): string;
        constructor Create();
        function get_memory(): extended;
        procedure get_variables();
        procedure get_full_info();
        procedure parse(input_command: string);
    end;

function is_string_number(data:string):boolean;

implementation

function is_string_number(data:string):boolean;
var
    i : integer;
    deci : boolean;
begin
    deci := false;
    for i := 1 to length(data) do
    begin
        if (data[i] = '.') and (deci) then
        begin
            exit(FALSE);
        end;
        if (not isdigit(data[i])) and not (data[i] = '.') then 
        begin
            exit(FALSE);
        end;
        if data[i] = '.' then deci := true
    end;
    exit(TRUE);
end;

constructor mim_interpreter.Create();
begin
    self.memory := 0;
    self.functions := TStringList.Create;
    self.variables := TMap_variable.Create;
    self.function_modules := Tmap_modules.Create;
    self.global_recording := False;
    current_condition := True;
    self.parameters := floatlist.Create();
    self.parameters_id := stringlist.Create();
    randomize;
end;

//live commands
function mim_interpreter.get_memory(): extended;
begin
    Result := self.memory;
end;

procedure mim_interpreter.get_variables();
var
    i: integer;
begin
    for i := 0 to self.variables.Count - 1 do
        writeln(self.variables.getkey(i), ' : ', self.variables.getdata(i): 0: 2);
end;

function mim_interpreter.variable_str(): string;
var
    i: integer;
    s: string;
begin
    s := '';
    for i := 0 to self.variables.Count - 1 do
        s := s + self.variables.getkey(i) + ' => ' + floattostr(self.variables.getdata(i)) + slinebreak;
    Result := s;
end;

procedure mim_interpreter.get_full_info();
var
    i: integer;
    s, r: string;
begin
    writeln('Memory: [', self.get_memory: 0: 2, ']');
    writeln('Recording module: [', self.current_module, ']', '[', self.global_recording, ']');
    writeln('Current condition: [', self.current_condition, ']');

    for i := 0 to self.variables.Count - 1 do
        writeln(self.variables.getkey(i), ' : ', self.variables.getdata(i): 0: 2);
    for s in self.functions do begin
        writeln(s);
        for r in self.function_modules[s] do
            writeln('--', r);
    end;
end;

function mim_interpreter.load_array(parameter: string):string;
var
    leftside    : string;
    rightside   : string;
    new_rightside : string;
    new_leftside : string;
    new_string  : string;
begin
    leftside := ExtractWord(1, parameter, ['*']);
    rightside := ExtractWord(2, parameter, ['*']);

    //writeln('left side ' + leftside);
    //writeln('right side ' +  rightside);
    if not (is_string_number(leftside)) and (rightside <> '') then begin

        // check if * in var
        if self.variables.indexof(rightside) >= 0 then begin
            new_rightside := Floattostr(self.variables.getdata(variables.indexof(rightside)));
        end else begin
            if is_string_number(rightside) then 
                new_rightside := rightside;
        end;
        new_string := leftside + new_rightside;
        //writeln('actual variable ',new_string);
        exit(new_string);
    end;

    if is_string_number(leftside) and (rightside <> '') then begin

        // check if * in var
        if self.variables.indexof(rightside) >= 0 then begin
            new_rightside := Floattostr(self.variables.getdata(variables.indexof(rightside)));
        end else begin
            if is_string_number(rightside) then 
                new_rightside := rightside;
        end;

        //writeln('count ', self.parameters_id.count);
        if strtoint(leftside)-1 < 0 then exit(leftside);
        if strtoint(leftside)-1 <= self.parameters_id.count then begin
            new_leftside := self.parameters_id[strtoint(leftside)-1];
            new_string := new_leftside + new_rightside;
            if rightside = '_' then exit(new_leftside);
            //writeln('new string ',new_string);
            exit(new_string);
        end;
        //writeln('didnt work');
    end;
    
    result := leftside;
end;

procedure mim_interpreter.load_return(command: string);
begin
    //WIP
    //self.parameter_count := wordcount(extractword(2, ' ' + command, [':']),[' ']);
end;

//array done
procedure mim_interpreter.load_parameters(command: string);
var
    s,a : string;
    i,o : integer;
    f : extended;
    parameter_1 : string;
    rightside : string;
begin
    if extractword(2,' '+command,[':']) <> '' then begin
        rightside := extractword(2,' '+command,[':']);

        self.parameters.clear;
        self.parameters_id.clear;
        self.parameter_count := wordcount(extractword(2,' '+command,[':']),[' ']);
        self.variables.addorsetdata('pmc', self.parameter_count );

        //sets the list with proper values

        for i := 1 to self.parameter_count do begin
            parameter_1 := self.load_array(extractword(i,rightside,[' '])); 
            if self.variables.indexof(parameter_1) >= 0 then begin
                self.parameters.add(self.variables.getdata(variables.indexof(parameter_1)));
            end;

            if is_string_number(parameter_1) then 
                self.parameters.add(strtoint(parameter_1));

            for o := 0 to self.variables.Count - 1 do begin
                if ansistartstext(parameter_1,self.variables.getkey(o)) then
                    self.parameters_id.add(parameter_1);
            end;
            
            for s in self.functions do begin
                if ansistartstext(parameter_1,s) then
                    self.parameters_id.add(parameter_1);
            end;
        end;
    end;


    //for s in self.parameters_id do
    //    writeln(s);
end;

//--commands--
//array done
procedure mim_interpreter._get(command: string);
var
    i : integer;
    f : extended;
    parameter_1 : string;
begin
    if self.load_array(extractword(2,command,[' '])) = '' then exit;
    parameter_1 := self.load_array(extractword(2,command,[' '])); 

    if ansistartstext('\',parameter_1) then exit;

    //writeln(parameter_1);
    if self.variables.indexof(parameter_1) >= 0 then begin
        if (self.variables.getdata(variables.indexof(parameter_1)) > 0) and (self.variables.getdata(variables.indexof(parameter_1)) <= self.parameter_count) then
            self.memory := self.parameters.items[trunc(self.variables.getdata(variables.indexof(parameter_1))-1)];
    end else begin
        if is_string_number(parameter_1) then begin
            if not (StrToFloat(parameter_1) <= 0) and not (StrToFloat(parameter_1) > self.parameter_count) then
            self.memory := self.parameters.items[trunc(StrToFloat(parameter_1)-1)];
        end;
    end;

end;

//array done
procedure mim_interpreter._rnd(command: string);
var
    parameter_1 : string;
begin
    if self.load_array(extractword(2,command,[' '])) = '' then exit;
    parameter_1 := self.load_array(extractword(2,command,[' '])); 

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then begin
        self.memory += random(round(self.variables.getdata(variables.indexof(parameter_1)))) ;
    end else begin
        if is_string_number(parameter_1) then 
            self.memory += random(round(StrToFloat(parameter_1))) 
    end;
end;
//array done
procedure mim_interpreter._del(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' '])); 

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then
        self.variables.remove(parameter_1);

    if self.functions.indexof(parameter_1) >= 0 then begin

        if self.function_modules.indexof(parameter_1) >= 0 then
            self.function_modules.remove(parameter_1);

        self.functions.delete(self.functions.indexof(parameter_1));

    end;
end;
//array done
procedure mim_interpreter._sho(command: string);
var
    i,split_number,x : integer;
    s, r: string;
    parameter_1 : string;
    parameter_2 : string;
    pass_string : string;
    string_build : string;
    splits      : array of string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' '])); 
    parameter_2 := self.load_array(extractword(3,command,[' '])); 
    //writeln('parameter one sho command ',parameter_1);
    
    pass_string := extractword(1,command,['\']); 
    if pass_string = 'sho ' then begin 
        string_build := extractword(2,command,['\']);
        for x := 2 to wordcount(command,['\']) do begin
        if self.variables.indexof(ExtractWord(x, command, ['\'])) >= 0 then 
          write(self.variables.getdata(variables.indexof(ExtractWord(x, command, ['\']))):0:0)
        else 
          write(ExtractWord(x, command, ['\']))
        end;
        writeln();
        exit;
    end;

    case parameter_1 of
        'var': self.get_variables;
        'mem': writeln(self.memory:0:2);
        'mod': for s in self.functions do writeln(s);
    else
        if self.variables.indexof(parameter_1) >= 0 then begin
            writeln(self.variables.getdata(variables.indexof(parameter_1)):0:0);
        end;

        if self.function_modules.indexof(parameter_1) >= 0 then begin
            for s in self.function_modules[parameter_1] do begin
                writeln(s);
            end;
        end;
        exit;
    end;

end;

procedure mim_interpreter._inp(command: string);
var
    parameter_1 : string;
begin
    if self.load_array(extractword(2,command,[' '])) = '' then exit;
    parameter_1 := extractword(2,command,['\']);

    // show prompt
    write(parameter_1);

    readln(self.user_input);
    // check to see if input is text or not
    if is_string_number(self.user_input) then
      self.memory := strtofloat(self.user_input);

end;

procedure mim_interpreter._mem(command: string);
var
    parameter_1 : string;
begin
    if self.load_array(extractword(2,command,[' '])) = '' then exit;

    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    //writeln('in mem ', parameter_1);
    if self.variables.indexof(parameter_1) >= 0 then begin
        self.memory := self.variables.getdata(variables.indexof(parameter_1));
    end else begin
        if is_string_number(parameter_1) then 
            self.memory := StrToFloat(parameter_1)
        else begin
            self.variables.addorsetdata(parameter_1,0);
            self.memory := 0;
        end;
    end;
end;
//array done
procedure mim_interpreter._var(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));
    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then begin
        self.variables.addorsetdata(parameter_1, self.memory);
    end else begin
        self.variables.addorsetdata(parameter_1, self.memory);
    end;
end;
// array done
procedure mim_interpreter._add(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then 
        self.memory := self.memory + self.variables.getdata(variables.indexof(parameter_1))
    else begin
        if is_string_number(parameter_1) then 
            self.memory := self.memory + StrToFloat(parameter_1)
        else begin
            self.variables.addorsetdata(parameter_1, self.memory);
            self.memory := self.memory + self.variables.getdata(variables.indexof(parameter_1));
        end;
    end;
end;
// array done
procedure mim_interpreter._sub(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then
        self.memory := self.memory - self.variables.getdata(variables.indexof(parameter_1))
    else begin
        if is_string_number(parameter_1) then 
            self.memory := self.memory - StrToFloat(parameter_1)
        else begin
            self.variables.addorsetdata(parameter_1, self.memory);
            self.memory := self.memory - self.variables.getdata(variables.indexof(parameter_1));
        end;
    end;
end;
//array done
procedure mim_interpreter._mul(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then
        self.memory := self.memory * self.variables.getdata(variables.indexof(parameter_1))
    else begin
        if is_string_number(parameter_1) then 
            self.memory := self.memory * StrToFloat(parameter_1)
        else begin
            self.variables.addorsetdata(parameter_1, self.memory);
            self.memory := self.memory * self.variables.getdata(variables.indexof(parameter_1));
        end;
    end;
end;
//array done
procedure mim_interpreter._div(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then begin
        if not (self.variables.getdata(variables.indexof(parameter_1)) = 0) then
            self.memory := self.memory / self.variables.getdata(variables.indexof(parameter_1));
    end else begin
        if is_string_number(parameter_1) then begin
            if not (StrToFloat(parameter_1) = 0) then
                self.memory := self.memory / StrToFloat(parameter_1);
        end else begin
            self.variables.addorsetdata(parameter_1, self.memory);
            if not (self.variables.getdata(variables.indexof(parameter_1)) = 0) then
                self.memory := self.memory / self.variables.getdata(variables.indexof(parameter_1));
        end;
    end;
end;
//array done
procedure mim_interpreter._swp(command: string);
var
    temp: extended;
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(2,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then begin
        temp := self.memory;
        self.memory := self.variables.getdata(variables.indexof(parameter_1));
        self.variables.addorsetdata(parameter_1, temp);
    end else begin
        if is_string_number(parameter_1) then 
            self.memory := StrToFloat(parameter_1)
        else begin
            self.variables.addorsetdata(parameter_1, self.memory);
            self.memory := 0;
        end;
    end;
end;
//array done
procedure mim_interpreter._con(command: string);
var
    parameter_1 : string;
begin
    parameter_1 := self.load_array(extractword(3,command,[' ']));

    if ansistartstext('\',parameter_1) then exit;
    if self.variables.indexof(parameter_1) >= 0 then begin
        case ExtractWord(2, command, [' ']) of
            '!': if self.memory <> self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '=': if self.memory = self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '>': if self.memory > self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '<': if self.memory < self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '>=': if self.memory >= self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '<=': if self.memory <= self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := True
                 else
                    self.current_condition := False;
            '!>': if self.memory > self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := False
                 else
                    self.current_condition := True;
            '!<': if self.memory < self.variables.getdata(variables.indexof(parameter_1)) then
                    self.current_condition := False
                 else
                    self.current_condition := True;
        end;
    end else begin
        if is_string_number(parameter_1) then begin
            case ExtractWord(2, command, [' ']) of
                '!': if self.memory <> StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '=': if self.memory = StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '>': if self.memory > StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '<': if self.memory < StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '>=': if self.memory >= StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '<=': if self.memory <= StrToFloat(parameter_1) then
                        self.current_condition := True
                     else
                        self.current_condition := False;
                '!>': if self.memory > StrToFloat(parameter_1) then
                        self.current_condition := False
                     else
                        self.current_condition := True;
                '!<': if self.memory < StrToFloat(parameter_1) then
                        self.current_condition := False
                     else
                        self.current_condition := True;
                'true': self.current_condition := True;

            end;
        end else begin
            if ExtractWord(2, command, [' ']) = '?' then begin
                self.current_condition := false 
            end else begin
                self.variables.addorsetdata(parameter_1, self.memory);
                self.current_condition := True;
            end;
        end;
    end;
end;
//array done
procedure mim_interpreter._smd(command: string);
var
    s: string;
    parameter_1 : string;
begin
    parameter_1 := self.load_array(ExtractWord(2, command, [' ']));

    if ansistartstext('\',parameter_1) then exit;
    if not (parameter_1 = '') then
    begin
        if not self.functions.indexof(parameter_1) >= 0 then begin
            self.functions.add(parameter_1);
            self.function_modules[parameter_1] := TStringList.Create;
            self.current_module := parameter_1;
            self.global_recording := True;
        end else begin
            self.function_modules[parameter_1].Clear;
            self.current_module := parameter_1;
            self.global_recording := True;
        end;
    end;
end;
// array done
procedure mim_interpreter._emd(command: string);
begin
    self.current_module := '';
    self.global_recording := False;
end;
//array done
procedure mim_interpreter._dot(command: string);
var
    r: string;
    parameter_1 : string;
    parameter_2 : string;
begin
    parameter_1 := ExtractWord(2, command, [' ']); 
    parameter_2 := ExtractWord(3, command, [' ']);

    if ansistartstext('\',parameter_1) then exit;
    if ansistartstext('\',parameter_2) then exit;

    if (self.function_modules.indexof(parameter_1) >= 0) and (self.variables.indexof(parameter_2) >= 0) then begin
        repeat
        for r in self.function_modules[parameter_1] do
            self.parse(r);
        until self.variables.getdata(variables.indexof(parameter_2)) < 1;
    end;
end;

procedure mim_interpreter.parse(input_command: string);
var
    commands : integer;
    command,s,line_command: string;
    i: integer = 0;
    x : integer;
    parameter_0 : string;
begin
    line_command := lowercase(input_command);

    for x := 1 to wordcount(line_command,['&']) do begin
      //writeln('loop number : ', x);
      command := extractword(x,line_command,['&']);
      //writeln(command);
      self.load_parameters(command);
      self.load_return(command);

      if (self.global_recording) then begin
          case ExtractWord(1, command, [' ']) of
              'emd': self._emd(command);
              'smd': self._smd(command);
          else 
               //adds commands to a new function 
               self.function_modules[self.current_module].add(command);
          end;
      end else begin
          //check to see if the condition is true or false(bypass if false or if command is 'con')
          if (self.current_condition) or (ExtractWord(1, command, [' ']) = 'con') then begin
              case ExtractWord(1, command, [' ']) of
                  'mem': self._mem(command);
                  'var': self._var(command);
                  'add': self._add(command);
                  'sub': self._sub(command);
                  'mul': self._mul(command);
                  'div': self._div(command);
                  'swp': self._swp(command);
                  'con': self._con(command);
                  'smd': self._smd(command);
                  'emd': self._emd(command);
                  'dot': self._dot(command);
                  'sho': self._sho(command);
                  'del': self._del(command);
                  'rnd': self._rnd(command);
                  'get': self._get(command);
                  'inp': self._inp(command);
                  '#' : //skip comments;
              end;
              // parsing functions
              parameter_0 := self.load_array(ExtractWord(1, command, [' ']));
              //writeln('first parameter -> ',parameter_0);
              if self.function_modules.indexof(parameter_0) >= 0 then begin
                  for s in self.function_modules[parameter_0] do begin
                      self.parse(s);
                  end;
              end;
          end;
      end;
    end;
end;

end.
