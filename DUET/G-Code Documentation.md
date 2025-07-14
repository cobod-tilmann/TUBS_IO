Here is the G-code documentation, optimized for use as a reference for a programming AI. The structure is designed to be easily parsable, with clear definitions for commands and their parameters.

# RepRapFirmware G-Code Reference

This document provides a structured reference for G-codes and M-codes supported by RepRapFirmware. Each command includes a description, a list of parameters, and code examples.

## G-Codes

### `G0` / `G1` - Move

*   **Description:** G0 is used for rapid, non-printing moves. G1 is used for controlled, linear moves, including printing. In RepRapFirmware, G0 and G1 are functionally identical.
*   **Parameters:**
    *   `X<float>`: The target X-axis coordinate.
    *   `Y<float>`: The target Y-axis coordinate.
    *   `Z<float>`: The target Z-axis coordinate.
    *   `E<float>`: The amount of filament to extrude.
    *   `F<float>`: The feedrate (speed) in mm/minute.
*   **Examples:**
    ```gcode
    ; Rapid move to X=50, Y=50 at the last set feedrate
    G0 X50 Y50

    ; Set the feedrate to 1500 mm/min
    G0 F1500

    ; Move to X=90.6, Y=13.8 while extruding 22.4mm of filament
    G1 X90.6 Y13.8 E22.4
    ```

### `G2` / `G3` - Controlled Arc Move

*   **Description:** G2 creates a clockwise arc. G3 creates a counter-clockwise arc.
*   **Parameters:**
    *   `X<float>`: The target X-axis coordinate for the arc's endpoint.
    *   `Y<float>`: The target Y-axis coordinate for the arc's endpoint.
    *   `I<float>`: The X-axis offset from the current position to the arc's center.
    *   `J<float>`: The Y-axis offset from the current position to the arc's center.
    *   `R<float>`: The radius of the arc.
    *   `E<float>`: The amount of filament to extrude over the arc.
    *   `F<float>`: The feedrate (speed) in mm/minute.
*   **Examples:**
    ```gcode
    ; Clockwise arc to X=90.6, Y=13.8 with center at (current_X+5, current_Y+10)
    G2 X90.6 Y13.8 I5 J10 E22.4

    ; Counter-clockwise arc with a radius of 200mm
    G3 X100 Y50 R200
    ```

### `G4` - Dwell

*   **Description:** Pauses the machine for a specified amount of time.
*   **Parameters:**
    *   `P<integer>`: The pause duration in milliseconds.
    *   `S<integer>`: The pause duration in seconds.
*   **Example:**
    ```gcode
    ; Wait for 500 milliseconds
    G4 P500
    ```

### `G10` - Tool Offset and Temperature

*   **Description:** Sets tool offsets, standby temperatures, and active temperatures.
*   **Parameters:**
    *   `P<integer>`: The tool number to configure.
    *   `R<float>`: The standby temperature in Celsius.
    *   `S<float>`: The active temperature in Celsius.
    *   `X<float>`: The X-axis offset.
    *   `Y<float>`: The Y-axis offset.
    *   `Z<float>`: The Z-axis offset.
*   **Examples:**
    ```gcode
    ; Set tool 1 standby temp to 140C and active temp to 205C
    G10 P1 R140 S205

    ; Set the X/Y/Z offsets for tool 2
    G10 P2 X17.8 Y-19.3 Z0.0
    ```

### `G20` - Set Units to Inches

*   **Description:** Sets the machine's units of measurement to inches for moves and offsets.
*   **Example:**
    ```gcode
    G20
    ```

### `G21` - Set Units to Millimeters

*   **Description:** Sets the machine's units of measurement to millimeters for moves and offsets.
*   **Example:**
    ```gcode
    G21
    ```

### `G28` - Home

*   **Description:** Homes one or more axes by moving them towards their endstops until triggered.
*   **Parameters:**
    *   `X`: Home the X-axis.
    *   `Y`: Home the Y-axis.
    *   `Z`: Home the Z-axis.
    *   (If no axes are specified, all axes are homed)
*   **Examples:**
    ```gcode
    ; Home all axes
    G28

    ; Home only the X and Z axes
    G28 X Z
    ```

### `G29` - Mesh Bed Compensation

*   **Description:** Probes the bed to create a height map for compensating for an uneven bed surface.
*   **Parameters:**
    *   `S<integer>`:
        *   `S0`: Probe the bed and save the height map.
        *   `S1`: Load a height map from a file.
        *   `S2`: Disable mesh bed compensation.
        *   `S3`: Save the current height map to a file.
    *   `P<string>`: The filename for the height map (e.g., `P"heightmap.csv"`).
*   **Example:**
    ```gcode
    ; Probe the bed, save height map, and enable compensation
    G29 S0
    ```

### `G30` - Single Z-Probe

*   **Description:** Probes the bed at a single point to determine the Z height.
*   **Parameters:**
    *   `P<integer>`: The index for storing the probed point for bed leveling.
    *   `S<integer>`: Controls the action after probing.
        *   `S-1`: Report the Z-height without making adjustments.
    *   `X<float>`: The X-coordinate to probe.
    *   `Y<float>`: The Y-coordinate to probe.
*   **Example:**
    ```gcode
    ; Probe at the current XY position and set the Z coordinate
    G30
    ```

### `G32` - Probe Z and Calculate Z Plane

*   **Description:** Automates bed leveling by probing multiple points (defined in the `bed.g` file) and calculating a tilt plane.
*   **Example:**
    ```gcode
    ; Run the bed leveling macro
    G32
    ```

### `G90` - Absolute Positioning

*   **Description:** Sets the machine to interpret all coordinates in subsequent G-code commands as absolute positions in the machine's coordinate system.
*   **Example:**
    ```gcode
    G90
    ```

### `G91` - Relative Positioning

*   **Description:** Sets the machine to interpret all coordinates in subsequent G-code commands as relative to the current position.
*   **Example:**
    ```gcode
    G91
    ```

### `G92` - Set Position

*   **Description:** Sets the current position of one or more axes to a specific value without moving the machine.
*   **Parameters:**
    *   `X<float>`: The new X-axis coordinate.
    *   `Y<float>`: The new Y-axis coordinate.
    *   `Z<float>`: The new Z-axis coordinate.
    *   `E<float>`: The new extruder position.
*   **Example:**
    ```gcode
    ; Set the current X position to 10 and the extruder position to 90
    G92 X10 E90
    ```

## M-Codes

### `M0` - Stop

*   **Description:** Stops the machine and disables motors. Often used to pause a print for user intervention.
*   **Example:**
    ```gcode
    M0
    ```

### `M104` - Set Hotend Temperature

*   **Description:** Sets the target temperature for a hotend without waiting for it to be reached.
*   **Parameters:**
    *   `S<float>`: The target temperature in Celsius.
    *   `T<integer>`: The tool/heater number (optional).
*   **Example:**
    ```gcode
    ; Set the active hotend temperature to 190C
    M104 S190
    ```

### `M105` - Report Temperatures

*   **Description:** Requests the current temperatures of all heaters and reports them back.
*   **Example:**
    ```gcode
    M105
    ```

### `M106` - Fan On

*   **Description:** Turns on a specified fan.
*   **Parameters:**
    *   `P<integer>`: The fan number to control.
    *   `S<float>`: The fan speed, from 0.0 (off) to 1.0 (full speed) or 0-255 for older firmware.
*   **Example:**
    ```gcode
    ; Set fan 0 to 50% speed
    M106 P0 S0.5
    ```

### `M107` - Fan Off

*   **Description:** Turns off a specified fan.
*   **Parameters:**
    *   `P<integer>`: The fan number to turn off (optional, defaults to the first fan).
*   **Example:**
    ```gcode
    ; Turn off the print cooling fan
    M107
    ```

### `M109` - Set Hotend Temperature and Wait

*   **Description:** Sets the target temperature for a hotend and waits for the temperature to be reached before proceeding.
*   **Parameters:**
    *   `S<float>`: The target active temperature in Celsius.
    *   `R<float>`: The target standby temperature in Celsius.
    *   `T<integer>`: The tool/heater number.
*   **Example:**
    ```gcode
    ; Set hotend temperature to 215C and wait
    M109 S215
    ```

### `M112` - Emergency Stop

*   **Description:** Immediately stops the machine and shuts down all heaters and motors. Requires a restart.
*   **Example:**
    ```gcode
    M112
    ```

### `M114` - Get Current Position

*   **Description:** Reports the current position of all axes.
*   **Example:**
    ```gcode
    M114
    ```

### `M115` - Get Firmware Version

*   **Description:** Reports the installed firmware version and its capabilities.
*   **Example:**
    ```gcode
    M115
    ```

### `M117` - Display Message

*   **Description:** Displays a message on the printer's screen, if available.
*   **Parameters:**
    *   `[string]`: The message to display.
*   **Example:**
    ```gcode
    M117 Hello World
    ```

### `M119` - Get Endstop Status

*   **Description:** Reports the current status (triggered or not triggered) of all configured endstops.
*   **Example:**
    ```gcode
    M119
    ```

### `M140` - Set Bed Temperature

*   **Description:** Sets the target temperature for the heated bed without waiting for it to be reached.
*   **Parameters:**
    *   `S<float>`: The target temperature in Celsius.
*   **Example:**
    ```gcode
    ; Set the bed temperature to 55C
    M140 S55
    ```

### `M190` - Set Bed Temperature and Wait

*   **Description:** Sets the target temperature for the heated bed and waits for it to be reached.
*   **Parameters:**
    *   `S<float>`: The target temperature in Celsius.
*   **Example:**
    ```gcode
    ; Set bed temperature to 60C and wait
    M190 S60
    ```

### `M220` - Set Speed Factor Override

*   **Description:** Sets a percentage override for the machine's feedrate.
*   **Parameters:**
    *   `S<float>`: The speed percentage (e.g., 100 for normal speed, 50 for half speed).
*   **Example:**
    ```gcode
    ; Set the speed override to 80% of the programmed speed
    M220 S80
    ```

### `M221` - Set Extrusion Factor Override

*   **Description:** Sets a percentage override for the amount of filament extruded.
*   **Parameters:**
    *   `S<float>`: The extrusion percentage (e.g., 100 for normal, 105 for 5% over-extrusion).
*   **Example:**
    ```gcode
    ; Set the extrusion multiplier to 95%
    M221 S95
    ```

### `M500` - Store Parameters

*   **Description:** Saves the current configuration settings to `config-override.g` on the SD card.
*   **Example:**
    ```gcode
    M500
    ```

### `M501` - Restore Parameters

*   **Description:** Loads the settings from `config-override.g`, applying any saved configurations.
*   **Example:**
    ```gcode
    M501
    ```

### `M502` - Revert to Default Parameters

*   **Description:** Reverts all settings to the defaults defined in `config.g`.
*   **Example:**
    ```gcode
    M502
    ```

### `M558` - Set Z-Probe Type

*   **Description:** Configures the type of Z-probe being used.
*   **Parameters:**
    *   `P<integer>`: The probe type (e.g., 5 for BLTouch).
    *   `C<string>`: The input pin for the probe.
    *   `H<float>`: The dive height for the probe.
    *   `F<float>`: The probing feedrate.
*   **Example:**
    ```gcode
    ; Configure a BLTouch connected to the e0stop pins
    M558 P5 C"e0stop" H5 F120 T3000
    ```

### `M563` - Create Tool

*   **Description:** Defines a tool by assigning heaters and extruder drives to it.
*   **Parameters:**
    *   `P<integer>`: The tool number to create.
    *   `D<integer>`: The extruder drive number(s).
    *   `H<integer>`: The heater number(s).
*   **Example:**
    ```gcode
    ; Create tool 0 with extruder 0 and heater 1
    M563 P0 D0 H1
    ```

### `T` - Select Tool

*   **Description:** Selects a tool to be used for subsequent commands.
*   **Parameters:**
    *   `<integer>`: The tool number to select.
*   **Examples:**
    ```gcode
    ; Select tool 0
    T0

    ; Select tool 1 without running tool change macros
    T1 P0
    ```