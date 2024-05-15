Maintaining a consistent code style and naming convention is vital for the readability and maintainability of a project.

## File Naming in TwinCAT

TwinCAT offers an automatic naming feature for files associated with a `FUNCTION_BLOCK`, ensuring that the file name aligns with the name of the function block itself. To utilize this feature:

1. Right-click on the `FUNCTION_BLOCK` file or on the function block's title.
2. Select the **refactoring** option.
3. Choose **rename**.

![image](https://github.com/QuokeCola/E-SPRiNT/assets/43491767/3945517c-e115-4597-b1bd-0fed8b4697b7)
![image](https://github.com/QuokeCola/E-SPRiNT/assets/43491767/fd6a5971-f6ac-4305-b29f-5e80c8037bc9)

For a quicker approach, click the `FUNCTION_BLOCK` title and press `CTRL` + `R` to initiate renaming.

## FUNCTION_BLOCK Naming

Function blocks in TwinCAT serve a purpose similar to the `class` in other programming languages. Ensure function block names follow the **PascalCase** convention:

```PYTHON
FUNCTION_BLOCK ExampleFunctionBlock
FUNCTION_BLOCK EveryInitialLetterShouldBeCapitalized
```

## Variables Naming

For variables, adopt the **snake_case** naming convention:

```PYTHON
VAR
    _this_is_a_private_var : DINT;
    _each_word_is_separated_by_an_underscore : DINT;
END_VAR
```

Remember that variables within function blocks are inherently private and aren't externally accessible. Following a convention akin to `C++/cpp`, prefix an underscore `_` to the variable name. This underscores its private nature. Consequently, we can craft methods and properties to access these internal variables, and when doing so, simply use the variable name without the preceding underscore:

Function block definition:

```python
VAR
    _this_is_the_internal_variable : DINT;
END_VAR
```

Method definition:

```python
PROPERTY this_is_the_internal_variable : DINT;
```

This practice streamlines the process by eliminating the need to devise new variable names for internal variables, keeping the code that invokes the function block concise and neat. 