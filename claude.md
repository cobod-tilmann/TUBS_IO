# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TUBS_IO is a TwinCAT3-based serial interpreter that enables communication between a DUET3D 6HC 3D printer controller and Beckhoff CX7080 controller for EtherCAT I/O module control. The system implements a text-based command protocol for controlling digital/analog outputs and reading input status.

### Key Components
- **DUET3D 6HC**: 3D printer controller sending commands via M118
- **Beckhoff CX7080**: ARM Cortex-M7 controller running TwinCAT3
- **EPP2008-0002**: 8-channel digital output module
- **EPP4174-0002**: 4-channel analog output module

## Development Environment

### Hardware Platform
- **Target Controller**: Beckhoff CX7080 (ARM Cortex-M7 @ 480 MHz)
- **Development Environment**: TwinCAT 3 (Windows-based)
- **Programming Language**: IEC 61131-3 Structured Text
- **Communication**: Serial RS232/RS485 at 115200 baud

### File Types
- `.TcPOU` - TwinCAT Program Organization Units (main programs and function blocks)
- `.TcGVL` - TwinCAT Global Variable Lists (constants, types, global variables)
- `.md` - Documentation files

### Key Directories
- `PLC/` - Core TwinCAT3 structured text code
- `DOCS/` - Comprehensive project documentation and integration guides
- `DUET/` - DUET3D controller integration files with custom M-codes

## Architecture Overview

### Core Components
1. **MAIN.TcPOU** - System orchestrator with initialization state machine and command processing workflow
2. **FB_SerialHandler** - Serial communication manager with connection handling and message processing
3. **FB_CommandParser** - Command parser with XOR checksum validation
4. **GVL.TcGVL** - Global definitions including constants, error codes, and type definitions

### Communication Protocol
- **Format**: `COMMANDPARAMETERS\r\n` (simplified)
- **Supported Commands**: DO (digital output), AO (analog output), DI (digital input), SYS (system status)
- **Responses**: Simple 3-character ASCII codes (RDY, OK, BP1, BR1, etc.)
- **Error Handling**: Comprehensive error codes and response system

### System States
```
INIT_START → INIT_SERIAL → INIT_PARSER → INIT_COMPLETE → RUNNING
     ↓                                                      ↑
INIT_ERROR ←─────────────────────────────────────────────────┘
```

## Development Guidelines

### TwinCAT3 Conventions
- Function blocks use `FB_` prefix (e.g., `FB_SerialHandler`)
- Global variables in `GVL.TcGVL` use descriptive ALL_CAPS names
- Types use `ST_` for structures, `E_` for enumerations
- Error codes follow `ERR_` prefix pattern
- Methods include comprehensive documentation headers

### Code Standards
- IEC 61131-3 structured text programming
- Modular design with clear separation of concerns
- Non-blocking operations for real-time performance
- Comprehensive error handling at all levels
- Statistics tracking for diagnostics

### Real-Time Constraints
- **Main Task Cycle**: 10ms for real-time response
- **Command Timeout**: 5000ms maximum processing time
- **Serial Timeout**: 1000ms for communication operations
- All operations must be non-blocking

## Testing and Validation

### Test Environment
No automated testing framework - testing relies on:
1. TwinCAT3 simulation mode for logic validation
2. Hardware-in-the-loop testing with actual CX7080
3. Serial communication testing with DUET3D integration
4. Protocol validation using test command library in `DOCS/Examples/test_commands.txt`

### Test Commands
```
SYS:STATUS:0:E4    # System status check
DO:0:1:A3          # Digital output test
DI:ALL:0:A7        # Digital input status
AO:0:32768:XX      # Analog output test (calculate checksum)
```

## Development Status

### Phase 1 (Completed)
- ✅ Core PLC framework with serial communication
- ✅ Command parsing with checksum validation
- ✅ Error handling and state management
- ✅ Comprehensive documentation and integration guides

### Phase 2 (Future)
- 🔄 EtherCAT I/O module configuration (EPP2008-0002, EPP4174-0002)
- 🔄 Hardware integration and testing
- 🔄 Performance optimization

## Key Files to Understand

### Essential PLC Code
- `PLC/MAIN.TcPOU:42-79` - Initialization state machine
- `PLC/MAIN.TcPOU:105-123` - Command processing workflow
- `PLC/GVL.TcGVL:61-71` - Error code definitions
- `PLC/FB_SerialHandler.TcPOU:67-145` - Serial communication state machine

### Documentation
- `DOCS/ProtocolDescription.md` - Complete communication protocol specification
- `DOCS/DuetIntegration.md` - DUET3D controller integration guide with macros
- `DOCS/PLCCodeOverview.md` - Detailed architecture and design documentation

### DUET3D Integration
- `DUET/M5100.g` - Serial interface initialization M-code
  - Uses M260.2/M261.2 for UART communication
  - Sends "SYS" command, expects "RDY" response
  - Aborts on initialization failure
- `DUET/M5110.g` - Digital/analog output control M-code
  - Usage: M5110 T0 C3 V1 (digital) or M5110 T1 C0 V32768 (analog)
  - Sends simplified commands like "DO31" or "AO0500"
  - Expects "OK" response from controller
- `DUET/M5120.g` - Digital input reading M-code with hex response
  - Usage: M5120 A5 (read input 5)
  - Expects "BP5" (pressed) or "BR5" (released) responses
  - Returns hex codes: 0001 (ON), 0000 (OFF), FF00 (error)
- `DUET/README.md` - Complete M-code documentation
- `DUET/QUICK_REFERENCE.md` - Quick reference for operators

## Working with the Codebase

### Making Changes
1. **PLC Code**: Modify `.TcPOU` and `.TcGVL` files following IEC 61131-3 syntax
2. **Constants**: Update values in `GVL.TcGVL` for system configuration
3. **Documentation**: Update corresponding `.md` files in `DOCS/` when making architectural changes

### Adding New Commands
1. Add command type to `E_CommandType` enumeration in `GVL.TcGVL`
2. Update command parsing logic in `FB_CommandParser`
3. Add command processing method in `MAIN.TcPOU`
4. Update protocol documentation in `DOCS/ProtocolDescription.md`

### Debugging
- Use TwinCAT3 online monitoring for variable inspection
- Check `FB_SerialHandler.GetStatistics()` for communication diagnostics
- Monitor system status through `ST_SystemStatus` structure
- Validate checksums using built-in calculation methods

## Integration Context

This system bridges DUET3D 6HC controllers with industrial EtherCAT I/O modules, enabling 3D printer control of external hardware like lighting, pumps, and sensors. The modular architecture supports future expansion for additional I/O types and communication protocols.

