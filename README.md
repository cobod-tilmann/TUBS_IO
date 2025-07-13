# TUBS_IO

A TwinCAT3-based serial interpreter enabling communication between DUET3D 6HC 3D printer controllers and Beckhoff CX7080 controllers for EtherCAT I/O module control.

## Overview

TUBS_IO implements a text-based command protocol that bridges DUET3D 6HC controllers with industrial EtherCAT I/O modules, enabling 3D printer control of external hardware like lighting, pumps, and sensors.

### Hardware Components
- **DUET3D 6HC**: 3D printer controller sending commands via M118
- **Beckhoff CX7080**: ARM Cortex-M7 controller running TwinCAT3
- **EPP2008-0002**: 8-channel digital output module
- **EPP4174-0002**: 4-channel analog output module

## Features

- Serial communication at 115200 baud (RS232/RS485)
- XOR checksum validation for message integrity
- Real-time command processing (10ms cycle time)
- Comprehensive error handling and diagnostics
- Non-blocking operations for industrial real-time constraints

## Communication Protocol

Commands follow the format: `CMD:PARAM1:PARAM2:CHECKSUM\r\n`

### Supported Commands
- `DO` - Digital output control
- `AO` - Analog output control  
- `DI` - Digital input status
- `SYS` - System status queries

### Example Commands
```
SYS:STATUS:0:E4    # System status check
DO:0:1:A3          # Set digital output 0 to ON
DI:ALL:0:A7        # Read all digital inputs
AO:0:32768:XX      # Set analog output 0 to mid-scale
```

## Project Structure

```
PLC/                    # Core TwinCAT3 structured text code
├── MAIN.TcPOU         # System orchestrator and state machine
├── FB_SerialHandler.TcPOU    # Serial communication manager
├── FB_CommandParser.TcPOU    # Command parser with validation
└── GVL.TcGVL          # Global variables and constants

DOCS/                   # Comprehensive documentation
├── ProtocolDescription.md    # Communication protocol specification
├── DuetIntegration.md       # DUET3D integration guide
├── PLCCodeOverview.md       # Architecture documentation
└── Examples/               # Test commands and examples

DUET/                   # DUET3D controller files (future use)
```

## Development Environment

- **Platform**: TwinCAT 3 (Windows-based development)
- **Target**: Beckhoff CX7080 (ARM Cortex-M7 @ 480 MHz)
- **Language**: IEC 61131-3 Structured Text
- **Real-time Constraints**: 10ms main task cycle

## Getting Started

1. Open project in TwinCAT 3 development environment
2. Configure target controller (CX7080) 
3. Deploy PLC code to controller
4. Configure EtherCAT I/O modules (EPP2008-0002, EPP4174-0002)
5. Test communication using commands in `DOCS/Examples/`

## System States

The system follows a structured initialization sequence:

```
INIT_START → INIT_SERIAL → INIT_PARSER → INIT_COMPLETE → RUNNING
     ↓                                                      ↑
INIT_ERROR ←─────────────────────────────────────────────────┘
```

## Documentation

- **[Protocol Description](DOCS/ProtocolDescription.md)** - Complete communication protocol
- **[DUET Integration](DOCS/DuetIntegration.md)** - Integration with DUET3D controllers
- **[PLC Code Overview](DOCS/PLCCodeOverview.md)** - Architecture and design details
- **[CLAUDE.md](CLAUDE.md)** - Development guidelines and project context

## Development Status

### Phase 1 (Completed)
- ✅ Core PLC framework with serial communication
- ✅ Command parsing with checksum validation  
- ✅ Error handling and state management
- ✅ Comprehensive documentation

### Phase 2 (Future)
- 🔄 EtherCAT I/O module configuration
- 🔄 Hardware integration and testing
- 🔄 Performance optimization

## License

[Add license information as appropriate]