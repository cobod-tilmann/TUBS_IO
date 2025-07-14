# TUBS_IO

A TwinCAT3-based serial interpreter enabling communication between DUET3D 6HC 3D printer controllers and Beckhoff CX7080 controllers for EtherCAT I/O module control.

## Overview

TUBS_IO implements a text-based command protocol that bridges DUET3D 6HC controllers with industrial EtherCAT I/O modules, enabling 3D printer control of external hardware like lighting, pumps, and sensors.

### Hardware Components
- **DUET3D 6HC**: 3D printer controller with custom M-codes for communication
- **Beckhoff CX7080**: ARM Cortex-M7 controller running TwinCAT3
- **EPP2008-0002**: 8-channel digital output module (24V DC, 0.5A per channel)
- **EPP4174-0002**: 4-channel analog output module (±10V/0-20mA, 16-bit resolution)

## Features

- Serial communication at 115200 baud (RS232/RS485)
- Custom DUET3D M-codes for seamless integration
- Simplified ASCII command protocol with hex responses
- Real-time command processing (10ms cycle time)
- Comprehensive error handling and diagnostics
- Non-blocking operations for industrial real-time constraints

## Communication Protocol

### DUET3D M-Codes
The system provides custom M-codes for DUET3D integration:

- **M5100** - Initialize serial interface and test controller connection
- **M5110** - Set digital/analog outputs (M5110 T0 C3 V1)
- **M5120** - Read digital inputs with hex response (M5120 A5)

### Beckhoff Command Format
Commands to the Beckhoff controller use simplified format: `COMMANDPARAMETERS\r\n`

### Supported Commands
- `SYS` - System status queries (returns "RDY")
- `DO` - Digital output control (DO31 = channel 3, value 1)
- `AO` - Analog output control (AO0500 = channel 0, value 500)
- `DI` - Digital input status (DI5 = read channel 5)

### Response Codes
- `RDY` - System ready
- `OK` - Command successful
- `BP1` - Button 1 pressed
- `BR1` - Button 1 released
- `SOK` - Safety OK
- `SER` - Safety error

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

DUET/                   # DUET3D controller integration
├── M5100.g             # Serial interface initialization M-code
├── M5110.g             # Digital/analog output control M-code
├── M5120.g             # Digital input reading M-code
├── README.md           # Complete M-code documentation
└── QUICK_REFERENCE.md  # Quick reference for operators
```

## Development Environment

- **Platform**: TwinCAT 3 (Windows-based development)
- **Target**: Beckhoff CX7080 (ARM Cortex-M7 @ 480 MHz)
- **Language**: IEC 61131-3 Structured Text
- **Real-time Constraints**: 10ms main task cycle

## Getting Started

### Beckhoff Controller Setup
1. Open project in TwinCAT 3 development environment
2. Configure target controller (CX7080) 
3. Deploy PLC code to controller
4. Configure EtherCAT I/O modules (EPP2008-0002, EPP4174-0002)
5. Test communication using commands in `DOCS/Examples/`

### DUET3D Controller Setup
1. Copy M-code files from `DUET/` to your DUET3D macros folder
2. Configure serial port in config.g: `M575 P1 S1 B115200`
3. Initialize communication: `M5100`
4. Test outputs: `M5110 T0 C0 V1` (digital output 0 ON)
5. Test inputs: `M5120 A5` (read digital input 5)

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
- **[DUET M-Codes](DUET/README.md)** - Custom M-code implementation and usage
- **[CLAUDE.md](CLAUDE.md)** - Development guidelines and project context

## Development Status

### Phase 1 (Completed)
- ✅ Core PLC framework with serial communication
- ✅ Command parsing and validation system
- ✅ Error handling and state management
- ✅ Custom DUET3D M-codes (M5100, M5110, M5120)
- ✅ Simplified ASCII protocol with hex responses
- ✅ Comprehensive documentation and integration guides

### Phase 2 (Future)
- 🔄 EtherCAT I/O module configuration
- 🔄 Hardware integration and testing
- 🔄 Performance optimization

## License

[Add license information as appropriate]