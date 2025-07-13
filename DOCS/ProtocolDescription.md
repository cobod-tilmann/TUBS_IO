# TUBS_IO Serial Communication Protocol

## Overview

The TUBS_IO serial interpreter implements a command-response protocol for communication between a DUET3D 6HC controller and a Beckhoff CX7080 controller. The protocol enables control of EtherCAT I/O modules and status monitoring through simple text-based commands.

## Communication Parameters

- **Baud Rate**: 115200 bps
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Flow Control**: None
- **Line Termination**: CRLF (`\r\n`)
- **Signal Levels**: 3.3V (TTL compatible)

## Message Format

### Command Structure
```
CMD:PARAM1:PARAM2:CHECKSUM\r\n
```

### Response Structure
```
STATUS:DATA:CHECKSUM\r\n
```

### Field Descriptions

| Field | Description | Length | Format |
|-------|-------------|--------|---------|
| CMD | Command type identifier | 2-3 chars | ASCII string |
| PARAM1 | First parameter (channel, etc.) | Variable | Numeric string |
| PARAM2 | Second parameter (value, etc.) | Variable | Numeric string |
| STATUS | Response status indicator | 2-3 chars | ASCII string |
| DATA | Response data | Variable | ASCII/Hex string |
| CHECKSUM | XOR checksum | 2 chars | Hex string |

## Supported Commands

### Digital Output Control (DO)

**Purpose**: Control digital output channels on EPP2008-0002 module

**Command Format**: `DO:CH:VAL:XX`

**Parameters**:
- `CH`: Channel number (0-7)
- `VAL`: Output value (0=OFF, 1=ON)
- `XX`: XOR checksum

**Examples**:
```
DO:0:1:A3      # Set channel 0 to HIGH
DO:7:0:B1      # Set channel 7 to LOW
DO:3:1:C5      # Set channel 3 to HIGH
```

**Success Response**: 
- `OK:DO:CH:XX`

**Error Responses**:
- `ERR:INVALID_CHANNEL:XX` - Channel number out of range
- `ERR:INVALID_VALUE:XX` - Value not 0 or 1

### Analog Output Control (AO)

**Purpose**: Control analog output channels on EPP4174-0002 module

**Command Format**: `AO:CH:VAL:XX`

**Parameters**:
- `CH`: Channel number (0-3)
- `VAL`: Output value (0-65535 for 16-bit resolution)
- `XX`: XOR checksum

**Value Mapping**:
- **Voltage Mode**: 0 = -10V, 32768 = 0V, 65535 = +10V
- **Current Mode**: 0 = 0mA, 65535 = 20mA

**Examples**:
```
AO:0:32768:B4  # Set channel 0 to 0V (mid-scale)
AO:1:65535:C8  # Set channel 1 to maximum (+10V or 20mA)
AO:2:0:D9      # Set channel 2 to minimum (-10V or 0mA)
```

**Success Response**: `OK:AO:CH:XX`
**Error Responses**:
- `ERR:INVALID_CHANNEL:XX` - Channel number out of range (>3)
- `ERR:INVALID_VALUE:XX` - Value out of range (>65535)

### Digital Input Status Request (DI)

**Purpose**: Request current status of all digital inputs

**Command Format**: `DI:ALL:0:XX`

**Parameters**:
- `ALL`: Request all inputs
- `0`: Reserved parameter
- `XX`: XOR checksum

**Example**:
```
DI:ALL:0:A7    # Request all digital input status
```

**Success Response**: `DI:HEXDATA:XX`
- `HEXDATA`: 4-character hex string representing 16 input bits
- Bit 0 (LSB) = Input 0, Bit 15 (MSB) = Input 15
- `1` = Input active/high, `0` = Input inactive/low

**Response Examples**:
```
DI:F0A5:B3     # Inputs: 1010 0101 1111 0000 (binary)
DI:0000:C1     # All inputs inactive
DI:FFFF:D2     # All inputs active
```

### System Status Request (SYS)

**Purpose**: Request system status and version information

**Command Format**: `SYS:STATUS:0:XX`

**Parameters**:
- `STATUS`: Status request identifier
- `0`: Reserved parameter
- `XX`: XOR checksum

**Example**:
```
SYS:STATUS:0:E4    # Request system status
```

**Success Response**: `OK:CONTROLLER:VERSION:XX`

**Response Example**:
```
OK:CX7080:1.0.0:F5    # Controller type and software version
```

## Error Handling

### Error Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 0 | ERR_NO_ERROR | No error condition |
| 1 | ERR_INVALID_COMMAND | Unknown or malformed command |
| 2 | ERR_IO_MODULE_ERROR | EtherCAT module communication failure |
| 3 | ERR_SERIAL_ERROR | Serial communication problem |
| 4 | ERR_CHECKSUM_ERROR | Command checksum validation failed |
| 5 | ERR_INVALID_CHANNEL | Channel number out of range |
| 6 | ERR_INVALID_VALUE | Parameter value out of bounds |
| 7 | ERR_TIMEOUT_ERROR | Operation timeout |
| 8 | ERR_INITIALIZATION | System initialization failure |
| 9 | ERR_MODULE_OFFLINE | EtherCAT module not responding |

### Error Response Format

**General Error**: `ERR:ERROR_TYPE:XX`

**Error Examples**:
```
ERR:INVALID_COMMAND:A8     # Unknown command received
ERR:CHECKSUM_ERROR:B9      # Checksum validation failed
ERR:INVALID_CHANNEL:C7     # Channel number out of range
ERR:IO_MODULE_ERROR:D6     # Hardware communication failure
```

## Checksum Calculation

The protocol uses a simple XOR checksum for message integrity validation.

### Algorithm

1. Start with checksum = 0
2. For each byte in the message (excluding the checksum field):
   - checksum = checksum XOR byte
3. Convert final checksum to 2-character uppercase hex string

### Implementation Example (Pseudo-code)

```
function calculateChecksum(message):
    checksum = 0
    for each character in message:
        checksum = checksum XOR ASCII_value(character)
    return toHex(checksum, 2)
```

### Validation Examples

| Message | Checksum Calculation | Result |
|---------|---------------------|---------|
| `DO:0:1` | D(68)⊕O(79)⊕:(58)⊕0(48)⊕:(58)⊕1(49) = A3 | `A3` |
| `AO:2:1024` | A(65)⊕O(79)⊕:(58)⊕2(50)⊕:(58)⊕1(49)⊕0(48)⊕2(50)⊕4(52) = B7 | `B7` |

## Message Flow Examples

### Successful Digital Output Command

```
DUET → CX7080: DO:0:1:A3\r\n
CX7080 → DUET: OK:DO:0:B4\r\n
```

### Successful Digital Input Status Request

```
DUET → CX7080: DI:ALL:0:A7\r\n
CX7080 → DUET: DI:F0A5:B3\r\n
```

### Error Condition Example

```
DUET → CX7080: DO:8:1:A9\r\n     # Invalid channel (8 > 7)
CX7080 → DUET: ERR:INVALID_CHANNEL:C7\r\n
```

## Timing Specifications

### Response Times

| Operation | Typical Response | Maximum Response |
|-----------|------------------|------------------|
| Digital Output | < 10ms | 50ms |
| Analog Output | < 10ms | 50ms |
| Digital Input Read | < 5ms | 25ms |
| System Status | < 5ms | 25ms |
| Error Response | < 5ms | 25ms |

### Communication Timeouts

- **Command Timeout**: 5000ms (command processing)
- **Serial Timeout**: 1000ms (per message)
- **Response Timeout**: 100ms (DUET receive)

## Protocol Compliance

### Message Validation Rules

1. **Format Compliance**: All messages must follow exact format specifications
2. **Parameter Bounds**: All parameters must be within specified ranges
3. **Checksum Validation**: All messages must include valid XOR checksums
4. **Line Termination**: All messages must end with CRLF (`\r\n`)
5. **Character Encoding**: ASCII printable characters only (0x20-0x7E)

### Best Practices

1. **Always validate checksums** before processing commands
2. **Implement timeouts** for all communication operations
3. **Handle errors gracefully** with appropriate error responses
4. **Log communication events** for debugging and diagnostics
5. **Use consistent case** for command and response strings
6. **Verify parameter ranges** before executing commands

## Extension Guidelines

### Adding New Commands

1. Define 2-3 character command identifier
2. Specify parameter format and validation rules
3. Document success and error responses
4. Update checksum calculation examples
5. Add to command parser and response generator

### Protocol Versioning

Future protocol versions should maintain backward compatibility and include version identification in system status responses.

## Troubleshooting

### Common Issues

1. **Checksum Errors**: Verify XOR calculation implementation
2. **Timeout Issues**: Check baud rate and line termination
3. **Invalid Commands**: Verify command format and parameter ranges
4. **No Response**: Check serial connection and CX7080 status
5. **Garbled Messages**: Verify signal levels and cable integrity

### Debug Commands

```
SYS:STATUS:0:E4    # Verify system is responding
DI:ALL:0:A7        # Test basic communication
DO:0:1:A3          # Test simple digital output
```