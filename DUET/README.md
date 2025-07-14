# TUBS_IO DUET3D Custom M-Codes

This directory contains custom M-code implementations for the DUET3D 6HC controller to communicate with the Beckhoff CX7080 TUBS_IO serial interpreter system.

## Overview

The DUET3D implementation uses custom M-codes instead of macros to provide better error handling and integration with the DUET3D firmware. Each M-code handles specific communication tasks with the Beckhoff controller.

## M-Code Files

### M5100.g - Serial Interface Initialization
**Purpose**: Initialize and test serial communication with the Beckhoff CX7080 controller

**Usage**: 
```gcode
M5100
```

**Function**:
- Configures serial port 1 at 115200 baud
- Sends system status request to verify controller connection
- Displays connection status on DUET display
- Initiates pause (M25) if controller doesn't respond or responds unexpectedly

**Response Handling**:
- Success: "TUBS_IO Controller Connected" displayed
- Error: "TUBS_IO Error: [error message]" displayed and print paused

### M5110.g - Set Digital/Analog Output
**Purpose**: Control digital or analog outputs on the Beckhoff controller

**Usage**: 
```gcode
M5110 Ttype Cchannel Vvalue
```

**Parameters**:
- `T` = Output type (0=Digital, 1=Analog)
- `C` = Channel number (0-7 for digital, 0-3 for analog)
- `V` = Value (0-1 for digital, 0-65535 for analog)

**Examples**:
```gcode
M5110 T0 C3 V1      ; Set digital output 3 to ON
M5110 T0 C5 V0      ; Set digital output 5 to OFF
M5110 T1 C0 V32768  ; Set analog output 0 to mid-range
M5110 T1 C2 V65535  ; Set analog output 2 to maximum
```

**Parameter Validation**:
- Digital channels: 0-7
- Analog channels: 0-3
- Digital values: 0-1
- Analog values: 0-65535

**Error Handling**:
- Parameter validation errors pause print and display error
- Controller communication errors pause print
- Timeout errors pause print

### M5120.g - Read Input Status
**Purpose**: Read digital input status from the Beckhoff controller

**Usage**: 
```gcode
M5120 Aaddress
```

**Parameters**:
- `A` = I/O address to read (0-15 for digital inputs)

**Examples**:
```gcode
M5120 A5    ; Read digital input 5
M5120 A12   ; Read digital input 12
```

**Response Format**:
The M-code returns a 4-character hex response in format `SSDD`:
- `SS` = Status byte (00=OK, FF=Error)
- `DD` = I/O value (00=OFF, 01=ON for digital inputs)

**Response Examples**:
- `0001` = Success, input is ON
- `0000` = Success, input is OFF
- `FF00` = Error condition

**Global Variable**:
The response is stored in `global.tubs_io_last_input` for access by other G-code.

## Protocol Details

### Command Format
All commands sent to the Beckhoff controller follow a simplified format:
```
COMMANDPARAMETERS\r\n
```

Examples:
- `SYS` - System status request
- `DO31` - Digital output channel 3 to value 1
- `AO0500` - Analog output channel 0 to value 500
- `DI5` - Digital input channel 5 status request

### Response Format
Controller responses use simple 3-character ASCII codes:
- `RDY` - System ready (hex: 52 44 59)
- `OK` - Command successful (hex: 4F 4B)
- `BP1` - Button 1 pressed (hex: 42 50 31)
- `BR1` - Button 1 released (hex: 42 52 31)
- `SOK` - Safety OK (hex: 53 4F 4B)
- `SER` - Safety error (hex: 53 45 52)

### UART Communication
The DUET3D uses M260.2 for sending and M261.2 for receiving UART data:
- M260.2 P1 S"command" - Send command to port 1
- M261.2 P1 R10 V"response" - Read up to 10 bytes from port 1 into global.response

## Error Handling

### Controller Errors
- Invalid commands return unexpected hex responses
- Communication timeouts trigger abort with error message
- Unexpected responses trigger abort with error message

### Parameter Validation
- Out-of-range parameters trigger immediate abort
- Missing parameters trigger immediate abort
- Invalid data types trigger immediate abort

### Display Messages
All errors are displayed on the DUET display using `M117` and logged to console using `echo`. Critical errors use `abort` to stop execution immediately.

## Integration Guidelines

### Startup Sequence
1. Call `M5100` to initialize serial communication
2. Verify successful connection before using other M-codes
3. Use `M5110` to set initial output states
4. Use `M5120` to read input states as needed

### Error Recovery
- All communication errors automatically abort execution
- Check DUET display and console for error messages
- Resolve hardware issues before restarting
- Re-run `M5100` after hardware fixes

### Performance Considerations
- Each M-code waits for controller response (2-3 second timeout)
- Avoid rapid successive calls to prevent communication congestion
- Use appropriate delays between commands if needed

## Example Usage in Print Jobs

### Setup Phase
```gcode
; Initialize TUBS_IO communication
M5100

; Set initial output states
M5110 T0 C0 V0      ; Turn off digital output 0
M5110 T0 C1 V1      ; Turn on digital output 1
M5110 T1 C0 V16384  ; Set analog output 0 to 25%
```

### During Print
```gcode
; Check safety input before critical operation
M5120 A7            ; Read safety input 7
; (Check global.tubs_io_last_input for result)

; Control process outputs
M5110 T0 C2 V1      ; Turn on process output 2
G4 P1000            ; Wait 1 second
M5110 T0 C2 V0      ; Turn off process output 2
```

### Error Handling Example
```gcode
M5120 A5            ; Read input 5
if global.tubs_io_last_input == "FF00"
    M117 "Input read error - check connection"
    M25             ; Pause print
endif
```

## Troubleshooting

### Common Issues
1. **Controller not responding**: Check serial cable and power
2. **Invalid response**: Verify controller firmware version
3. **Parameter errors**: Check M-code syntax and parameter ranges
4. **Timeout errors**: Check controller processing load

### Debug Output
All M-codes generate debug output using `M118 A1` for troubleshooting. Enable console logging to see detailed communication traces.

## Version History
- v1.0: Initial implementation with custom M-codes
- Replaces previous macro-based implementation
- Improved error handling and user feedback