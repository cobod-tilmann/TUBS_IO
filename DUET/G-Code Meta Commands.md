# G-Code Meta Commands

## Introduction

RepRapFirmware 3.01 and later introduce programming constructs like conditionals, loops, and parameters to G-Code. This, combined with the RepRapFirmware 3 object model, provides a powerful customization layer.

## Programming constructs

### Abort command

`abort <opt-expression>`

This command terminates all nested macros and the current print file. The optional expression is converted to a string and displayed to the user.

### Echo command

`echo <expression>, <expression>, ...`

This command writes the string representation of one or more expressions to the console, separated by spaces.

**Example:**

```gcode
echo move.axes[0].homed, move.axes[1].homed, move.axes[2].homed
```

Starting with firmware 3.4, the output can be redirected to a file.

*   `echo ><filename> <expression>, ...`: Creates a new file (or overwrites an existing one) with the output.
*   `echo >><filename> <expression>, ...`: Appends the output to a file, creating it if it doesn't exist.
*   `echo >>><filename> <expression>, ...`: Appends to a file without a newline character (supported in firmware 3.5beta2 and later).

### Conditional construct

```gcode
if <boolean-expression>
  ...
elif <boolean-expression>
  ...
else
  ...
```

The `if` block allows for conditional execution of G-Code. The `elif` and `else` parts are optional. The body of each block must be indented.

### Loop

```gcode
while <boolean-expression>
  ...
```

The `while` loop executes a block of G-Code as long as the boolean expression is true. The body of the loop must be indented.

*   `iterations`: A named constant representing the number of completed loop iterations (0-indexed).
*   `break`: Exits the current loop.
*   `continue`: Skips to the next iteration of the loop.

### Nested loops

Nested loops are supported. To access the `iterations` counter of an outer loop from an inner loop, you must save it to a variable.

**Example:**

```gcode
var loopCounterOuter = 0
while <boolean-expression> ; outer loop
  ...
  set var.loopCounterOuter = iterations
  while <boolean-expression> ; inner loop
    ...
    echo iterations ; iterations for the inner loop
    echo var.loopCounterOuter ; iterations for the outer loop
```

## Variables

(Supported from RRF 3.3)

### Local variable declaration

`var <new-variable-name> = <expression>`

Creates a new local variable `var.<new-variable-name>`.

### Global variable declaration

`global <new-variable-name> = <expression>`

Creates a new global variable `global.<new-variable-name>`.

### Variable assignment

`set var.<existing-local-variable-name> = <expression>`
`set global.<existing-global-variable-name> = <expression>`

Re-assigns an existing variable.

### Variable naming

*   The first character must be a letter.
*   The remaining characters must be letters, digits or underscores.
*   Expression length, including variables, is limited to <250 characters.

## Use of expressions within G-Code commands

`{ <expression> }`

Expressions can be used in place of numeric or string operands in G-Code commands.

**Example:**

```gcode
G1 X{move.axes[0].max-10} Y{move.axes[1].min+10}
```

## Expressions

### General

*   Tabs and spaces can be used for readability.
*   Sub-expressions can be enclosed in `{ }` or `( )`. In CNC mode, `( )` are for comments unless inside `{ }`.

### Types

Available types are: `bool`, `int`, `float`, `string`, `DateTime`, `object`, and `array`.

### Type conversions

*   `int` to `float`
*   Any type to `string` (can be forced with `^ ""`)

### Named constants

| Name        | Type     | Meaning                                                                                                                                                                                                                         |
| :---------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `false`     | `bool`   | Boolean false.                                                                                                                                                                                                              |
| `input`     | (variable) | The most recent input from an `M291` message box with mode 4, 5, 6 or 7.                                                                                                                                                     |
| `iterations`| `int`    | The number of completed iterations of the innermost loop.                                                                                                                                                                   |
| `line`      | `int`    | The current line number in the file being executed.                                                                                                                                                                         |
| `null`      | `object` | The null object.                                                                                                                                                                                                            |
| `pi`        | `float`  | Pi (3.14159265...).                                                                                                                                                                                                         |
| `result`    | `int`    | 0 for success, 1 for warning, 2+ for error for the last G/M/T-code. -1 if a blocking M291 was cancelled. Meta commands do not change `result`. |
| `true`      | `bool`   | Boolean true.                                                                                                                                                                                                               |

### Literals

*   **Integer:** decimal (`4321`), hexadecimal (`0x3f`), binary (`0b1011`).
*   **Float:** fixed-point (`165.32`), scientific (`6.2e6`).
*   **String:** double quotes (`"Hello world"`). Use `""` for a double quote inside a string.
*   **Character:** single quotes (`'a'`) (RRF 3.5.0+).

### Object model properties

Expressions can use properties from the RepRapFirmware Object Model.

### Variables

(Supported from RRF 3.3 in standalone, 3.4 in SBC mode)

Use `global.<variable name>` and `var.<variable name>` to access variables. Use `exists(<variable>)` to check for definition.

### Macro parameters

(Supported from RRF 3.3)

Pass parameters to macros with `M98 P"macro.g" S100 Y"string"`. Access them with `param.<parameter letter>`.

### Array expressions

(Supported from RRF 3.5)

`{expression1, expression2, ...}` creates an array. A trailing comma is required for a single-element array (`{pi,}`).

## Operators

### Unary prefix operators

| Operator | Signature                 | Meaning                                                              |
| :------- | :------------------------ | :------------------------------------------------------------------- |
| `!`      | `bool`->`bool`           | Boolean not.                                                         |
| `+`      | `int`->`int`, `float`->`float` | Unary +.                                                         |
| `+`      | `DateTime`->`int`          | Converts DateTime to seconds since datum (RRF 3.4+).             |
| `-`      | `int`->`int`, `float`->`float` | Unary -.                                                         |
| `#`      | `X[]`->`int`, `string`->`int` | Number of elements in an array or characters in a string.         |

### Binary infix operators

(Evaluated left-to-right at same precedence)

| Operator   | Precedence | Signature                                      | Meaning                                         |
| :--------- | :--------- | :--------------------------------------------- | :---------------------------------------------- |
| `*`        | 6          | `(int,int)`->`int`, `(float,float)`->`float`      | Multiplication (only inside `{ }`).          |
| `:`        |            |                                                | (See documentation for CAUTION note).      |
| `/`        | 6          | `(float,float)`->`float`                       | Division.                                   |
| `+`        | 5          | `(int,int)`->`int`, `(float,float)`->`float`, `(DateTime,int)`->`DateTime` | Addition.                                   |
| `-`        | 5          | `(int,int)`->`int`, `(float,float)`->`float`, `(DateTime,DateTime)`->`int`, `(DateTime,int)`->`DateTime` | Subtraction.                                |
| `=` or `==`| 4          | `(X,X)`->`bool`                                | Equality.                                   |
| `!=`       | 4          | `(X,X)`->`bool`                                | Inequality.                                 |
| `<`        | 4          | `(int,int)`->`bool`, `(float,float)`->`bool`      | Less than.                                  |
| `<=`       | 4          | `(int,int)`->`bool`, `(float,float)`->`bool`      | Less than or equal.                         |
| `>`        | 4          | `(int,int)`->`bool`, `(float,float)`->`bool`      | Greater than.                               |
| `>=`       | 4          | `(int,int)`->`bool`, `(float,float)`->`bool`      | Greater than or equal.                      |
| `&` or `&&`| 3          | `(bool,bool)`->`bool`                          | Boolean and.                                |
| `|` or `||`| 3          | `(bool,bool)`->`bool`                          | Boolean or.                                 |
| `^`        | 2          | `(string,string)`->`string`                    | String concatenation.                       |

### Ternary operator

`expr1 ? expr2 : expr3`

If `expr1` is true, evaluates to `expr2`, otherwise `expr3`.

## Functions

A list of supported functions. Arguments in radians for trigonometric functions.

| Function name | Signature                                | Notes                                                                                                                                                                                                                                     |
| :------------ | :--------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `abs`         | `float`->`float` or `int`->`int`         | Absolute value.                                                                                                                                                                                                                       |
| `acos`        | `float`->`float`                         | Arccosine.                                                                                                                                                                                                                            |
| `asin`        | `float`->`float`                         | Arcsine.                                                                                                                                                                                                                              |
| `atan`        | `float`->`float`                         | Arctangent.                                                                                                                                                                                                                           |
| `atan2`       | `(float, float)`->`float`                | Arctangent of y/x.                                                                                                                                                                                                                    |
| `ceil`        | `float`->`int` or `float`->`float`       | Rounds up to the nearest integer.                                                                                                                                                                                                     |
| `cos`         | `float`->`float`                         | Cosine.                                                                                                                                                                                                                               |
| `datetime`    | `int`->`DateTime` or `string`->`DateTime` | Converts seconds or a formatted string to a DateTime object (RRF 3.4.0+).                                                                                                                                                             |
| `degrees`     | `float`->`float`                         | Converts radians to degrees.                                                                                                                                                                                                          |
| `drop`        | `(string, int)`->`string` or `(array, int)`->`array` | Returns all but the first N elements of the argument (RRF 3.6.0+).                                                                                                                                                            |
| `exists`      | `name` -> `bool`                         | True if the variable or object model element is valid and not null (RRF 3.3.0+).                                                                                                                                                       |
| `exp`         | `float`->`float`                         | e raised to the power of the operand (RRF 3.5.0+).                                                                                                                                                                                    |
| `fileexists`  | `string`->`bool`                         | True if the file exists (RRF 3.5.0+).                                                                                                                                                                                                  |
| `fileread`    | `(string, int, int, char)`->`array`       | Reads elements from a single-line CSV-like file (RRF 3.5.0+).                                                                                                                                                                          |
| `find`        | `(string, char)`->`int` or `(string, string)`->`int` | Returns the index of the first occurrence of a character or a string within another string (RRF 3.6.0+).                                                                                                                    |
| `floor`       | `float`->`int` or `float`->`float`       | Rounds down to the nearest integer.                                                                                                                                                                                                   |
| `isnan`       | `float`->`bool`                          | True if the operand is Not-a-Number.                                                                                                                                                                                                  |
| `log`         | `float`->`float`                         | Natural logarithm (RRF 3.5.0+).                                                                                                                                                                                                       |
| `max`         | `(float, ...)`->`float` or `(int, ...)`->`int` | Maximum of 1 or more arguments.                                                                                                                                                                                                   |
| `min`         | `(float, ...)`->`float` or `(int, ...)`->`int` | Minimum of 1 or more arguments.                                                                                                                                                                                                   |
| `mod`         | `(int, int)`->`int` or `(float, float)`->`float` | Modulo operator.                                                                                                                                                                                                                  |
| `pow`         | `(float, float)`->`float` or `(int, int)`->`int` | First operand to the power of the second (RRF 3.5.0+).                                                                                                                                                                             |
| `radians`     | `float`->`float`                         | Converts degrees to radians.                                                                                                                                                                                                          |
| `random`      | `int`->`int`                             | Returns a pseudo-random integer from 0 to operand-1.                                                                                                                                                                                  |
| `round`       | `float`->`int` or `float`->`float`       | Rounds to the nearest integer (RRF 3.6.0+).                                                                                                                                                                                           |
| `sin`         | `float`->`float`                         | Sine.                                                                                                                                                                                                                                 |
| `sqrt`        | `float`->`float`                         | Square root.                                                                                                                                                                                                                          |
| `square`      | `float`->`float`                         | Square of the operand (RRF 3.6.0+).                                                                                                                                                                                                   |
| `take`        | `(string, int)`->`string` or `(array, int)`->`array` | Returns the first N elements of the argument (RRF 3.6.0+).                                                                                                                                                                   |
| `vector`      | `(int, X)` -> `array`                    | Creates an array with a specified number of elements, all with the same value (RRF 3.5.0+).                                                                                                                                              |

## Notes

*   **Line Endings:** Use Linux-style (LF) line endings for macros.
*   **Indentation of comments:** From RRF 3.6.0, the indentation of comment lines is no longer significant.
*   **daemon.g:** The `/sys/daemon.g` macro is executed regularly by the firmware for background tasks.
*   **Meta Gcode evaluation in SBC mode:** In SBC mode, DSF waits for pending codes to be executed before evaluating meta G-code.

## Examples of use

The documentation provides several examples, including:
*   Using conditional G-Code in `bed.g` to calibrate a delta printer.
*   Saving and restoring variables across a reset.
*   Setting tool-specific data like nozzle diameter.
*   Creating a new filament profile with user input.