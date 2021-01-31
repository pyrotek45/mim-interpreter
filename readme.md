
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
most commands interact with a single parameter and the `mem` register.

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
to the terminal. Be aware that when creating a variable that it will use whatever is stored in the `mem` register.

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
 
 notice how the variable `y` was not cerated with the `var` command? Thats because `swp` created it on the fly.
 

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

This is usefull to make sure the code after gets executed.

# wip
