# DUET3D 6HC Integration Guide

## Overview

This guide provides complete instructions for integrating the TUBS_IO serial interpreter with a DUET3D 6HC controller. The integration enables the DUET to control external EtherCAT I/O modules through the Beckhoff CX7080 controller.

## Hardware Requirements

### DUET3D 6HC Controller
- **Firmware**: RepRapFirmware 3.x or later
- **Available UART**: Second UART (io1 or io2 port)
- **Signal Levels**: 3.3V TTL
- **Connection**: Via io1 or io2 connector

### Connection Specifications
- **DUET io1/io2 Pins**: TX, RX, GND
- **CX7080 Serial Port**: RS232 (may require level conversion)
- **Cable Length**: Maximum 15 meters (recommended < 5m)
- **Shielding**: Required for industrial environments

## Wiring Diagram

```
DUET3D 6HC (io1/io2)           Level Shifter        CX7080 (COM1)
├─ TX (Pin 1) ─────────────────→ 3.3V to RS232 ─────→ RX (Pin 2)
├─ RX (Pin 2) ←─────────────────← RS232 to 3.3V ←───── TX (Pin 3)
└─ GND (Pin 3) ────────────────────────────────────── GND (Pin 5)
```

### Level Shifter Options
1. **MAX3232 Module**: Common 3.3V TTL to RS232 converter
2. **SP3232 Module**: Industrial-grade converter
3. **Built-in Conversion**: If CX7080 has TTL-compatible input

## DUET3D Configuration

### 1. config.g Settings

Add the following lines to your `config.g` file:

```gcode
; Configure second UART for TUBS_IO communication
M575 P2 B115200 S2                    ; Enable second UART at 115200 baud

; Optional: Set up initial I/O states
M80                                   ; ATX power on (if using external power)

; Optional: Define I/O mapping variables
set global.tubs_connected = false    ; Connection status tracking
set global.tubs_error_count = 0      ; Error counter
```

### 2. Serial Port Configuration Details

| Parameter | Value | Description |
|-----------|-------|-------------|
| P2 | Second UART | Uses io1 or io2 connector |
| B115200 | Baud Rate | 115200 bits per second |
| S2 | Mode | Standard UART mode |

### 3. Verification Commands

Test the configuration with these commands:

```gcode
; Test basic communication
M118 P2 S"SYS:STATUS:0:E4"           ; Request system status

; Check for response (manual verification)
; Expected response: OK:CX7080:1.0.0:XX
```

## DUET Macro Implementation

### Basic Communication Macros

#### Send Command Macro (`send_tubs_command.g`)

```gcode
; Macro: send_tubs_command.g
; Usage: M98 P"send_tubs_command.g" Scommand_string
; Example: M98 P"send_tubs_command.g" S"DO:0:1:A3"

if exists(param.S)
    M118 P2 S{param.S}               ; Send command to TUBS_IO
    G4 P50                           ; Wait 50ms for response
else
    echo "Error: No command specified. Use S parameter."
endif
```

#### Digital Output Control Macros

Create individual macros for common operations:

**Digital Output ON (`do_on.g`)**:
```gcode
; Macro: do_on.g
; Turn on digital output channel
; Usage: M98 P"do_on.g" S<channel>
; Example: M98 P"do_on.g" S0  (turn on channel 0)

if exists(param.S)
    var channel = param.S
    if var.channel >= 0 && var.channel <= 7
        var checksum = {(68^79^58^var.channel^58^49)} ; Calculate DO:CH:1 checksum
        var command = "DO:" ^ var.channel ^ ":1:" ^ {floor(var.checksum/16) > 9 ? chr(87+floor(var.checksum/16)) : chr(48+floor(var.checksum/16))} ^ {(var.checksum%16) > 9 ? chr(87+(var.checksum%16)) : chr(48+(var.checksum%16))}
        M118 P2 S{var.command}
        echo "Digital output " ^ var.channel ^ " turned ON"
    else
        echo "Error: Channel must be 0-7"
    endif
else
    echo "Error: No channel specified. Use S parameter."
endif
```

**Digital Output OFF (`do_off.g`)**:
```gcode
; Macro: do_off.g
; Turn off digital output channel
; Usage: M98 P"do_off.g" S<channel>

if exists(param.S)
    var channel = param.S
    if var.channel >= 0 && var.channel <= 7
        var checksum = {(68^79^58^var.channel^58^48)} ; Calculate DO:CH:0 checksum
        var command = "DO:" ^ var.channel ^ ":0:" ^ {floor(var.checksum/16) > 9 ? chr(87+floor(var.checksum/16)) : chr(48+floor(var.checksum/16))} ^ {(var.checksum%16) > 9 ? chr(87+(var.checksum%16)) : chr(48+(var.checksum%16))}
        M118 P2 S{var.command}
        echo "Digital output " ^ var.channel ^ " turned OFF"
    else
        echo "Error: Channel must be 0-7"
    endif
else
    echo "Error: No channel specified. Use S parameter."
endif
```

### Analog Output Control Macros

**Set Analog Output (`ao_set.g`)**:
```gcode
; Macro: ao_set.g
; Set analog output value
; Usage: M98 P"ao_set.g" S<channel> R<value>
; Example: M98 P"ao_set.g" S0 R32768  (set channel 0 to mid-scale)

if exists(param.S) && exists(param.R)
    var channel = param.S
    var value = param.R
    if var.channel >= 0 && var.channel <= 3 && var.value >= 0 && var.value <= 65535
        ; Note: Checksum calculation simplified for demonstration
        ; In practice, implement proper XOR checksum calculation
        M118 P2 S{"AO:" ^ var.channel ^ ":" ^ var.value ^ ":XX"}
        echo "Analog output " ^ var.channel ^ " set to " ^ var.value
    else
        echo "Error: Channel 0-3, Value 0-65535"
    endif
else
    echo "Error: Specify channel (S) and value (R)"
endif
```

### Status Query Macros

**Get Digital Inputs (`get_inputs.g`)**:
```gcode
; Macro: get_inputs.g
; Request digital input status
; Usage: M98 P"get_inputs.g"

M118 P2 S"DI:ALL:0:A7"               ; Send digital input request
echo "Digital input status requested"
; Note: Response needs to be read manually or processed by daemon
```

**System Status Check (`tubs_status.g`)**:
```gcode
; Macro: tubs_status.g
; Check TUBS_IO system status
; Usage: M98 P"tubs_status.g"

M118 P2 S"SYS:STATUS:0:E4"           ; Send system status request
echo "TUBS_IO system status requested"
; Expected response: OK:CX7080:1.0.0:XX
```

## Response Handling

### Manual Response Monitoring

Since DUET3D has limited automatic response processing capabilities, responses must be monitored manually or through external scripts.

**Response Reading**:
1. Send command using M118
2. Monitor console output for responses
3. Parse response format: `STATUS:DATA:CHECKSUM`

### Automated Response Processing (Advanced)

For automated response handling, consider:

1. **External Script**: Python/Node.js script monitoring serial port
2. **Daemon Process**: Background process on connected computer
3. **PanelDue Plugin**: Custom plugin for response display

## Integration Examples

### Print Job Integration

**Start Print Setup (`print_start.g`)**:
```gcode
; Initialize TUBS_IO outputs for print start
M98 P"do_on.g" S0                    ; Turn on chamber lighting
M98 P"do_on.g" S1                    ; Turn on exhaust fan
M98 P"ao_set.g" S0 R16384           ; Set heater to 25% (example)
G4 P100                              ; Wait for commands to process
```

**End Print Cleanup (`print_end.g`)**:
```gcode
; Clean up TUBS_IO outputs after print
M98 P"do_off.g" S1                   ; Turn off exhaust fan
M98 P"ao_set.g" S0 R0               ; Turn off analog heater
G4 P2000                             ; Wait 2 seconds
M98 P"do_off.g" S0                   ; Turn off chamber lighting
```

### Safety Integration

**Emergency Stop (`emergency_stop.g`)**:
```gcode
; Emergency shutdown of all TUBS_IO outputs
M98 P"do_off.g" S0
M98 P"do_off.g" S1
M98 P"do_off.g" S2
M98 P"do_off.g" S3
M98 P"ao_set.g" S0 R0
M98 P"ao_set.g" S1 R0
M98 P"ao_set.g" S2 R0
M98 P"ao_set.g" S3 R0
echo "EMERGENCY: All TUBS_IO outputs turned OFF"
```

## Troubleshooting

### Common Issues

#### 1. No Response from CX7080

**Symptoms**: Commands sent but no responses received

**Checks**:
```gcode
M575 P2                              ; Verify UART configuration
M118 P2 S"SYS:STATUS:0:E4"          ; Test basic communication
```

**Solutions**:
- Verify wiring connections
- Check level shifter operation
- Confirm CX7080 power and status
- Validate baud rate settings

#### 2. Checksum Errors

**Symptoms**: ERR:CHECKSUM_ERROR responses

**Checks**:
- Verify checksum calculation in macros
- Check for character encoding issues
- Validate command format

#### 3. Invalid Command Errors

**Symptoms**: ERR:INVALID_COMMAND responses

**Checks**:
- Verify command syntax
- Check parameter ranges
- Confirm line termination (CRLF)

### Debug Commands

```gcode
; Test serial port configuration
M575 P2

; Test basic connectivity
M118 P2 S"SYS:STATUS:0:E4"

; Test simple digital output
M118 P2 S"DO:0:1:A3"

; Test digital input reading
M118 P2 S"DI:ALL:0:A7"
```

### Communication Log Analysis

Enable communication logging to track message flow:

```gcode
M929 P"tubs_debug.log" S1            ; Start logging
; ... perform test commands ...
M929 P"tubs_debug.log" S0            ; Stop logging
```

## Performance Optimization

### Command Timing

- **Minimum Interval**: 10ms between commands
- **Batch Operations**: Group related commands
- **Response Timeout**: Allow 100ms for responses

### Macro Efficiency

- Pre-calculate checksums where possible
- Use conditional logic to minimize redundant commands
- Implement error checking in critical macros

## Security Considerations

### Access Control

- Limit macro access to authorized users
- Implement command validation in macros
- Use safe default values for critical outputs

### Error Handling

- Always include bounds checking
- Implement graceful degradation
- Log all communication errors

## Maintenance

### Regular Checks

1. **Connection Status**: Verify serial communication daily
2. **Response Times**: Monitor for performance degradation
3. **Error Rates**: Track communication errors
4. **Cable Integrity**: Inspect connections monthly

### Firmware Updates

When updating DUET firmware:
1. Backup current macro configuration
2. Test M575 and M118 functionality
3. Verify macro compatibility
4. Update macros if needed

## Advanced Features

### Conditional Logic

```gcode
; Advanced conditional macro example
if sensors.gpIn[0].value == 1        ; Check DUET input pin
    M98 P"do_on.g" S0               ; Turn on TUBS output
else
    M98 P"do_off.g" S0              ; Turn off TUBS output
endif
```

### Variable Integration

```gcode
; Use DUET variables with TUBS_IO
set global.chamber_temp_target = 45
var analog_value = {(global.chamber_temp_target * 65535) / 100}
M98 P"ao_set.g" S0 R{var.analog_value}
```

This integration guide provides a complete framework for using TUBS_IO with DUET3D 6HC controllers, enabling powerful external I/O control capabilities.