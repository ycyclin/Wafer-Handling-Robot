There are various variables in structured text. 
Note that other than python or C/C++, Structured Text declare variables in a fixed location. 

As shown in picture, the upper portion of editor (red frame) is the place for declare the variables (similar to the `.h` header file in C/C++). The lower part (blue frame) is for the logic of a function (similar to the `.c/cpp` header file in C/C++), function block or program. 

![image](https://github.com/QuokeCola/E-SPRiNT/assets/43491767/f49b2c8c-68b9-4529-b608-d629e6eb3ee4)

Note that declaring the variables follows the format of :

```python
    [variable name] : [data type];
```

For functions and function block, there are different types of variables: 

## Intermediate variables
To declare the variables:
```c
VAR
    var1 : DINT;
    var2 : USINT;
    var3 : ARRAY[0..1] OF DINT;
END_VAR
```

`VAR` and `END_VAR` create a field for declaring the intermediate variables used in functions. 
> ***Yes! Even intermediate variables need to be declared in the "header" field.***

If you have a logic such as switch values:

```c
c = a;
a = b;
b = c;
```

You need to declare all `a`, `b`, `c` in the `VAR ... END_VAR` field
## Input variables

`VAR_IN` declares the variables that passed in the function. Here is a simple example, we declare a function `VAR_IN_TEST`:

```c
FUNCTION VAR_IN_TEST
VAR_IN
/// The variables here is the input of function or function block. Changing this the value of this variable will not affect the variable that passed in.
    var1 : DINT;
END_VAR
```

```c
/// Logic part of VAR_IN_TEST
    var1 := 5;  /// Assign the var1 to 5
```

In main program: 

``` c
/// Header
    VAR input_var : DINT;
/// Logic
    input_var := 3;
    VAR_IN_TEST(var1 := input_var); /// This command we invoke VAR_IN_TEST, while we passed a variable called input_var into the function. 
                                    /// In the function VAR_IN_TEST, var1's value was assigned with the value of input_var.
```

The result shows that `input_var` is equal to `3` but not `5`. ***Changing the input variable inside the function will not affect the passed in variable outside the function.***


## Output Variables
```VAR_OUT``` declares the variables that function produces. So, TwinCAT allows ```FUNCTION``` to return multiple variables.

To define variables, follows the following format in header. 

```c
VAR_OUT
   var1 : DINT;
   var2 : DINT;
END_VAR
```

when calling the function, assign the output to variables outside the function:

```c
/// Header   Outside the function, var declare
VAR
    var_outside:DINT;
END_VAR

/// Logic 
my_fun(var1=>var_outside); /// This is var_outside = var1. 
```

## Input/Output Variables
```VAR_OUT``` declares the variables that will be changed by functions. This means everything you did inside the function will affect the variables were passed in. Changing the in/out variables changes the variables outside the function

To define in/out variables, follows the following format in header. 

```c
/// Header
VAR_IN_OUT
   var1 : DINT;
   var2 : DINT;
END_VAR

/// Logic
var1 := 100;
var2 := 10;
```
When calling the function

```c
var_outside1 := 5;
var_outside2 := 1;
my_fun(var1:=var_outside1, var2:=var_outside2);
/// This produce var_outside1 == 100, var_outside2 == 10
```


## Constant
Constant variables cannot be changed. To declare constant:
```
VAR CONSTANT 
    var1:DINT := 1;
END_VAR 
```
This defines a constant `var1` with value of `1`.


## Static Variables
Static variables are for function blocks. When declare a static variable in function block, all instance of the function block share one address.

To declare static variable:
``` c
VAR_STAT
    var1:DINT;
END_VAR
```

For example, if we have a function block called `fb_type` with `VAR_STAT` `stat1:DINT`.

In main function,

```c
\\\ Header
VAR
fb1 : fb_type;
fb2 : fb_type;
END_VAR

\\\ Logic
fb1.stat1 := 2;
\\\ fb2.stat1 will also be 2. 
fb2.stat1 := 6;
\\\ fb1.stat1 will also be 6.
```  

# Data types
Here are some important data types for quick reference:

## Integer Data Types
<html>
<body>
<!--StartFragment-->

Data type | Lower bound | Upper bound | Memory space
-- | -- | -- | --
BYTE | 0 | 255 | 8 bit
WORD | 0 | 65535 | 16 bit
DWORD | 0 | 4294967295 | 32 bit
LWORD | 0 | $2^{64}-1$ | 64 bit
SINT | -128 | 127 | 8 bit
USINT | 0 | 255 | 8 bit
INT | -32768 | 32767 | 16 bit
UINT | 0 | 65535 | 16 bit
DINT | -2147483648 | 2147483647 | 32 bit
UDINT | 0 | 4294967295 | 32 bit
LINT | $-2^{63}$ | $2^{63}-1$ | 64 bit
ULINT | 0 | $2^{64}-1$ | 64 bit

<!--EndFragment-->
</body>
</html>

## Bool Datatypes

<html>
<body>
<!--StartFragment-->

Type | Memory use
-- | --
BOOL | 8 Bit

<!--EndFragment-->
</body>
</html>

## Real/LREAL

<html>
<body>
<!--StartFragment-->

Data type | Lower limit | Upper limit | Smallest absolute value | Storage space
-- | -- | -- | -- | --
REAL | -3.402823e+38 | 3.402823e+38 | 1.0e-44 | 32-bit
LREAL | -1.7976931348623158e+308 | 1.7976931348623158e+308 | 4.94065645841247e-324 | 64-bit

<!--EndFragment-->
</body>
</html>

## Bit operation

TwinCAT support extract certain bit from data/struct:

```c
    var1: DINT := 5; /// Binary: 00000101
    
    var1.0 /// 1;
    var1.1 /// 0;
    var1.2 /// 1;
    var1.3 /// 0;
    var1.5 /// 0;
    ...
    var1.8 /// 0;
```

For other data types, please check the following links in beckhoff infosys.
[data types XAE 1000](https://infosys.beckhoff.com/content/1033/tc3_plc_intro/2529388939.html?id=3451082169760117126)