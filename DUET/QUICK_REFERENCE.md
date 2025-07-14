# TUBS_IO M-Code Quick Reference

## M5100 - Initialize Serial Interface
```gcode
M5100
```
- Configures serial port and tests controller connection
- Must be called before other M-codes
- Pauses print if controller doesn't respond

## M5110 - Set Output
```gcode
M5110 Ttype Cchannel Vvalue
```
- **T0** = Digital output (V: 0-1, C: 0-7)
- **T1** = Analog output (V: 0-65535, C: 0-3)

**Examples:**
```gcode
M5110 T0 C3 V1      ; Digital output 3 ON
M5110 T0 C3 V0      ; Digital output 3 OFF
M5110 T1 C0 V32768  ; Analog output 0 to 50%
```

## M5120 - Read Input
```gcode
M5120 Aaddress
```
- **A** = Input address (0-15)
- Returns hex code: `SSDD` (SS=status, DD=value)
- Result stored in `global.tubs_io_last_input`

**Response codes:**
- `0001` = Input ON
- `0000` = Input OFF  
- `FF00` = Error

**Example:**
```gcode
M5120 A5                                    ; Read input 5
if global.tubs_io_last_input == "0001"
    M117 "Input 5 is ON"
endif
```

## Error Handling
- All errors display on screen via M117 and console via echo
- Communication errors abort execution automatically
- Critical errors use abort command to stop immediately
- Always check display and console for error messages

## RepRapFirmware Integration
- Uses M260.2 for UART write operations
- Uses M261.2 for UART read operations
- Responses are in hex format (space-separated bytes)
- Simple 3-character response codes from controller