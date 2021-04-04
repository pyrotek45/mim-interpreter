
# MIM-Interpreter
-- List of commands
- mem 
- var
- add
- sub
- mul
- div
- swp
- con
- smd
- emd
- dot
- sho
- del
- rnd
- get
- inp

Helper commands:
- `#` (comment a line)


The mim-interpreter uses a single register known as `mem` to do it's calculations.
most commands interact with a single parameter and the `mem` register directly.

# mem (variable,integer)
The `mem` command is used to set the `mem` register. you can pass a variable 
or an integer.

```
mem 5
sho mem
```
will output

``` 
5
```
to the terminal.

# var (variable-name)
The `var` command is used to create a `variable` in mim. variables can be used to store data outside of the `mem` register. The command will take the value
of the `mem` registor and create a variable with that value.

```
mem 5
sho mem

var x
sho x
```
will output

``` 
5
5
```
to the terminal.

Notice how the `mem` and the `x` variable are the same? That is becuase the `mem` register was not changed after setting it to 5.

>If the variable already exist, it will overwrite the old value.

# [add,sub,mul,div] (variable,integer)
These commands are used to do operations on the `mem` register. They will take the current value in the `mem` register and apply the operation to it using the parameter.

```
mem 5
add 5
sho mem

mem 5
sub 5
sho mem

mem 5
mul 5
sho mem

mem 5
div 5
sho mem
```
will output

``` 
10
0
25
1
```
to the terminal.

you can also pass variables made with the `var` command.
```
mem 5
var x
mul x
sho mem
```

will output
```
25
```
to the terminal. Be aware that when creating a variable, it will use whatever is stored in the `mem` register.

>you can pass a variable that has not yet been created to these commands. 
>it will create the variable on the fly with the current `mem` register and
>then do the operation.
#
```
mem 25
add y
sho mem
```
will output
```
50
```
to the terminal

# swp (variable)

The `swp` command stands for "swap" and it will swap what ever the value stored in the variable that was passed to it will the current value stored in the `mem` register.

It can also create a variable if the variable passed does not exist. 
>If `swp` is passed a variable that does not exist it will overwrite the
>`mem` register with 0 and create a variable with its previous contents.

```
mem 5
var x

mem 0
swp x
sho mem

sho x

mem 10
swp y
sho mem

sho y
```
will output
```
5
0
0
10
```
to the terminal.

notice how the variable `y` was not created with the `var` command? Thats because `swp` created it on the fly.


# con (condition) (variable,integer)
The mim-interpreter has two states `condition: true` or `condition: false`.

>If the current state is true the current line of code will be executed,
>however if the current condition is false, the code will be skipped.

We can control the `condition` state using the `con` command.
The `con` command will compare the current value stored in the `mem` register to the second parameter passed in. If the condition is true then the `condition` state will be true, however if it is false it will skip over any code until the `condition` state is true again.

```
mem 5
con = 5
sho \hello world!

mem 5
con = 10
sho \you cant see me!

con true

mem 10
con = 10
sho \you can see this!
```
will output
```
hello world!
you can see this!
```

>The current `condition` can always be turned back on by simply 
>passing `true` to it.

```
con true
```

This is usefull to make sure the code after gets executed.\

There are several (condition) test, one can do with the con command.

`?`: will set the codition to be true if the variable passed in the parameter exist, otherwise it will set it to be false.
`!`: will set the codition to be true if the mem register does NOT equal the parameter, else it will set it to be false.
`=`: will set the codition to be true if the mem register is equal to the parameter, else it will set it to be false.
`>`: will set the codition to be true if the mem register is greater than the paremeter, else it will set it to be false.
`<`: will set the codition to be true if the mem register is less than the paremeter, else it will set it to be false.
`>=`: will set the codition to be true if the mem register is greater than OR equal to the paremeter, else it will set it to be false.
`<=`: will set the codition to be true if the mem register is less than OR equal to the paremeter, else it will set it to be false.
`!>`: will set the codition to be true if the mem register is NOT greater than the paremeter, else it will set it to be false.
`!<`: will set the codition to be true if the mem register is NOT less than the paremeter, else it will set it to be false.
`true`: will set the codition to be true, regardless of its current condition. This always will make the condition true.

> IF the `con` command is passed a variable that is not yet defined to any other condition test, besides `?`, it WILL create the variable and set the condition to be true. The variable will have the same value as the mem register.

# smd (module name) & emd 
`smd` stands for "start module definition".
`emd` stands for "end module definition".


Mim does not have functions, but it does have Modules. Modules are a way to store commands 
and access them with a name or call.

The `smd` command will start recording a module with a list of commands.
these commands will not be excecuted unless the module name is called.

The `emd` command will stop recording, and start executing commands normally.

```
smd hello
sho \hello world!
emd

hello
```
will output
```
hello world!
```
to the terminal.

Mim will the parse the commands in that module as if to replace the call itself, with the commands. 

>It is possible to create loops by calling a module from within itself. beware though, and 
>make sure you have a base case in order for the looping to stop.

Notice how you can directly call a module name? 

# dot (module) (variable)

The `dot` command stands for "do over time". It takes in a module and a 
variable. it will not work if you pass it a constant.

The `dot` command will repeat the module commands UNTIL the value of the variable that was passed is equal to 0. Otherwise, it will repeat forever. Making sure the module will eventualy set the variable to zero is key to utilizing the `dot` command.

```
# setting up the variable
mem 5
var x

# setting up the loop
smd loop
sho x
sho \this is a loop 
mem x
sub 1
var x
emd

# calling the module
dot loop x :x 
```
will output
```
5
this is a loop 
4
this is a loop 
3
this is a loop 
2
this is a loop 
1
this is a loop 

```
to the terminal.

# sho (var,mod,variable, module,) or (strings and variables)

The `sho` command is your tool to output data to the screen.
Some words are `keywords`, and will display useful information when called.

```
sho var
```

will display all the variables currently in your mim instance and their values.

```
sho mod
```

will display all the modules stored inside your current instance of mim.

```
sho (variable)
```

will simply show the value of that variable

and 

```
sho (module name)
```

will display the commands stored in that module.

You might have already seen me using `\` for strings like so.

```
sho \hello world!
```
will output
```
hello world!
```
to the terminal. sho works by splitting everyting on the right side of the first `\` by 
other `\` symbols.

This allows you to combine strings and variables to your output like so.

```
mem 5
var x
sho \x is \x\
```
will display

```
x is 5
```
to the terminal.

If any string between two `\`, matches a variable name, it will display the value instead.

# del (variable, module,) 

The `del` command is how you can delete variables or modules. It will do nothing if they do not yet exist.

```
mem 5
var x
del x
sho x
```

will display nothing.

# rnd (variable or integer) 

The `rnd` command is how you genorate random numbers in mim.

```
mem 0
rnd 7
sho mem
```
will set the mem register to a number between the current mem register and the value passed in the paramter.

# inp \(prompt) 

The `inp` command is how you get input during runtime. It can show a prompt by typing anything after the `\` symbol.

```
inp \how old are you?
var age
sho \you are \age\ years old!
```
It currently does not work the same way as the `sho` command, as it can not display variable values.

# get (variable or integer)
Before I explain how the `get` command works, I must first explain how to store extra parameters in mim using the `:` notation.


```
mem 5
var x
sho 1*_ :x
```

will display

```
5
```
in your terminal.

There are two main things going on here, first, we store the value of `x` in the paremter list on the right using the `:` notation. Then we access that parameters value using `1*_`. In this scenerio, the the value of x is stored in a list called the `parameter list`. When used, a special variable called `pmc` is also created, that stores the current number of values that have been passed in. This variable can be changed and used, and its value will not be reset until a new list of parameters have been defined. The list can be accessed anytime after unless a new list has been created. setting new parameters will destroy the old ones.

The `1` in the `1*_` notation, tells mim to get the first value stored in the parameter list and the underscore tells mim that we are looking in the parameter list for the value. This notation only works on variables that are passed in.

The `*` symbal also has another use in mim. for instance `x*1` will be concatenated to `x1`. IF the string on the right side of the `*` is a variable, it will concatenate the value to the end of the left part.

```
mem 5
var x
mem 1
var y
mem 10
var x1
sho x*y
```
will display

```
10
```

becuase `x*y` was shorted to `x1`. This is also true for modules. 

Now on to the `get` command. This will simply set the mem register to the value of the index passed into `get`

```
get 1 :5
sho mem
```
will display
```
5
```
and 

```
mem 5
var x
get 1 :x
sho mem
```
will also display
```
5
```

like wise you can pass a variable to `get` for the index. Using the special variable `pmc` is key to utilizing the parameter list feature.

