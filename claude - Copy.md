# TUBS_IO Serial Interpreter Project Documentation

## Project Overview

This project implements a TwinCAT3-based serial interpreter running on a Beckhoff CX7080 controller. The system receives serial commands from a DUET3D 6HC controller, interprets them, and controls connected EtherCAT I/O modules (EPP2008-0002 and EPP4174-0002). It also relays I/O status back to the DUET using optimized hex messages.

### Key Components
- **DUET3D 6HC**: 3D printer controller sending commands via M118
- **Beckhoff CX7080**: ARM Cortex-M7 controller running TwinCAT3
- **EPP2008-0002**: 8-channel digital output module
- **EPP4174-0002**: 4-channel analog output module

## Hardware Specifications

### Beckhoff CX7080 Controller
- **Processor**: ARM Cortex-M7 single-core @ 480 MHz
- **Memory**: 32 MB RAM (19.1 MB available for TwinCAT)
- **Operating System**: TwinCAT/RTOS (based on FreeRTOS)
- **Serial Interfaces**: RS232 and RS485 on D-sub connector
- **Programming**: TwinCAT 3 via Ethernet interface
- **Integrated I/O**: 8 digital inputs (24V DC), 4 digital outputs (24V DC, 0.5A)
- **Storage**: microSD card slot with 512 MB microSD card
- **I/O System**: E-bus or K-bus terminals support with auto-recognition

### EPP2008-0002 Digital Output Module
- **Channels**: 8 digital outputs
- **Voltage**: 24 V DC
- **Current**: 0.5 A max per channel, 3 A total max
- **Protection**: Short-circuit proof, short-term overload acceptable
- **Indicators**: LED status indicators per channel
- **Connectors**: M12 screw-type (2 channels per connector)
- **Communication**: EtherCAT P (power + communication in single cable)

### EPP4174-0002 Analog Output Module
- **Channels**: 4 analog outputs (individually parameterizable)
- **Output Types**: ±10 V or 0/4-20 mA (selectable per channel)
- **Resolution**: 16-bit (15-bit default)
- **Isolation**: Electrically isolated outputs
- **Connectors**: M12 differential outputs
- **Communication**: EtherCAT P

## DUET3D 6HC Communication Protocol

### Research Findings

#### M118 Command (Send Messages)
- **Format**: `M118 P<port> S"<message>"`
- **Port Parameter**: P5 for second UART communication
- **Example**: `M118 P5 S"DO:0:1:XX"` (send digital output command)
- **Supported**: RepRapFirmware 1.21 and later

#### M575 Command (Serial Configuration)
- **Format**: `M575 P<port> B<baud> S<mode>`
- **Configuration**: `M575 P2 B115200 S2` for second UART
- **Parameters**:
  - P2: Second UART port
  - B115200: 115200 baud rate
  - S2: Communication mode
- **Required**: Must be in config.g file

#### Serial Communication Requirements
- **Signal Levels**: 3.3V (level shifting needed for 5V devices)
- **Line Termination**: LF or CRLF (CR alone won't work)
- **Default Baud**: 57600 (configurable via M575)
- **Checksum**: Required for integrity checking (configurable)

#### DUET Communication Limitations
- Limited buffer size for receiving messages
- Preference for short, compact responses
- Hex encoding recommended for status data to minimize message length

## Command Protocol Design

### Command Structure
```
Format: CMD:PARAM1:PARAM2:CHECKSUM\r\n
```

#### Command Types
1. **Digital Output Control**
   - Format: `DO:CH:VAL:XX`
   - Example: `DO:0:1:A3` (Set channel 0 to HIGH)
   - Channels: 0-7 (EPP2008-0002)

2. **Analog Output Control**
   - Format: `AO:CH:VAL:XX`
   - Example: `AO:2:1024:B7` (Set channel 2 to 1024)
   - Channels: 0-3 (EPP4174-0002)
   - Values: 0-65535 (16-bit resolution)

3. **Digital Input Status Request**
   - Format: `DI:ALL:0:XX`
   - Response: `DI:F0A5:XX` (hex-encoded status)

4. **System Status Request**
   - Format: `SYS:STATUS:0:XX`
   - Response: `OK:CX7080:1.0.0:XX`

### Response Structure
```
Format: STATUS:DATA:CHECKSUM\r\n
```

#### Response Types
1. **Success Confirmation**
   - Format: `OK:CMD:CH:XX`
   - Example: `OK:DO:0:A1`

2. **Error Responses**
   - Format: `ERR:CODE:XX`
   - Examples: 
     - `ERR:INVALID_CHANNEL:XX`
     - `ERR:INVALID_COMMAND:XX`
     - `ERR:IO_MODULE_ERROR:XX`

3. **Status Data**
   - Format: `DI:HEXDATA:XX`
   - Example: `DI:F0A5:XX` (16 inputs packed into 4 hex chars)

### Checksum Calculation
- Simple XOR checksum of all bytes in command/response
- Converted to 2-digit hex string
- Appended before line termination

## Software Architecture

### TwinCAT3 Project Structure
```
TUBS_IO/
├── PLC/                              # ✅ IMPLEMENTED
│   ├── MAIN.TcPOU                    # ✅ Main program orchestration
│   ├── GVL.TcGVL                     # ✅ Global variables and constants
│   ├── FB_SerialHandler.TcPOU        # ✅ Serial communication management
│   └── FB_CommandParser.TcPOU        # ✅ Command parsing and validation
├── claudeInstructions.md             # ✅ Project documentation
├── claudeLogbook.md                  # ✅ Development log
└── [Future Phase 2 Files]
    ├── FB_IOController.TcPOU         # TODO: EtherCAT I/O control
    └── EtherCAT_Configuration.xti    # TODO: I/O module configuration
```

### Function Block Descriptions

#### MAIN.TcPOU
- **Purpose**: Main program orchestration and system coordination
- **Responsibilities**:
  - Initialize all function blocks
  - Coordinate communication between serial handler and I/O controller
  - Manage system state and error conditions
  - Implement main execution loop

#### FB_SerialHandler
- **Purpose**: Manage serial communication with DUET3D
- **Key Methods**:
  - `Init()`: Initialize serial port configuration
  - `ProcessReceivedData()`: Parse incoming command strings
  - `SendResponse()`: Format and send responses
- **Features**:
  - Automatic reconnection on communication errors
  - Timeout handling for reliable operation
  - Buffer management for command queuing

#### FB_IOController
- **Purpose**: Control EtherCAT I/O modules
- **Key Methods**:
  - `InitializeModules()`: Setup and verify I/O modules
  - `ProcessCommand()`: Execute received commands
  - `UpdateIOStatus()`: Read current I/O states
  - `GetDigitalInputStatus()`: Format input data for transmission
- **Features**:
  - Individual channel control for both digital and analog outputs
  - Real-time status monitoring
  - Module health checking and fault detection

#### FB_CommandParser
- **Purpose**: Parse and validate incoming commands
- **Key Methods**:
  - `ParseCommand()`: Split command string into components
  - `ValidateChecksum()`: Verify command integrity
  - `ExtractParameters()`: Convert string parameters to numeric values
- **Features**:
  - Robust error handling for malformed commands
  - Parameter bounds checking
  - Command queue management

#### FB_ResponseGenerator
- **Purpose**: Format responses for transmission to DUET
- **Key Methods**:
  - `FormatResponse()`: Create properly formatted response strings
  - `CalculateChecksum()`: Generate XOR checksums
  - `EncodeHexData()`: Convert binary data to hex strings
- **Features**:
  - Compact hex encoding for efficient transmission
  - Consistent response formatting
  - Error code generation

## Error Handling Strategy

### Communication Error Codes
- `ERR_NO_ERROR`: 0 - No error condition
- `ERR_INVALID_COMMAND`: 1 - Unknown or malformed command
- `ERR_IO_MODULE_ERROR`: 2 - EtherCAT module communication failure
- `ERR_SERIAL_ERROR`: 3 - Serial communication problem
- `ERR_CHECKSUM_ERROR`: 4 - Command checksum validation failed
- `ERR_INVALID_CHANNEL`: 5 - Channel number out of range
- `ERR_INVALID_VALUE`: 6 - Parameter value out of bounds

### Fault Tolerance Features
1. **Automatic Recovery**
   - Serial communication reconnection attempts
   - EtherCAT module re-initialization
   - Graceful degradation for partial system failures

2. **Safe State Management**
   - All outputs set to safe states on communication loss
   - Watchdog implementation for system reliability
   - Emergency stop capability

3. **Diagnostic Capabilities**
   - Module status monitoring and reporting
   - Communication statistics tracking
   - Error logging for troubleshooting

## Implementation Roadmap

### Phase 1: Core Framework (Week 1-2) ✅ COMPLETED
- [x] Create basic TwinCAT3 project structure
- [x] Implement FB_SerialHandler with basic send/receive
- [x] Implement FB_CommandParser for command parsing
- [x] Implement MAIN.TcPOU for system orchestration
- [x] Create GVL.TcGVL with comprehensive constants and types
- [x] Implement core communication protocol framework

### Phase 1.5: Documentation and Integration Support ✅ COMPLETED
- [x] Create comprehensive protocol documentation
- [x] Develop DUET3D integration guide and macros
- [x] Create PLC code overview and architecture documentation
- [x] Generate test command library and examples
- [x] Provide complete DUET configuration templates

### Phase 2: I/O Integration (Week 3-4)
- [ ] Configure EtherCAT modules in TwinCAT3
- [ ] Implement FB_IOController for digital outputs
- [ ] Add analog output control capability
- [ ] Implement input status reading functionality

### Phase 3: Hardware Testing (Week 5-6)
- [ ] Test with actual EPP2008-0002 and EPP4174-0002 modules
- [ ] Validate real I/O operations with hardware
- [ ] Implement checksum validation with calculated values
- [ ] Test command/response cycle with actual DUET3D

### Phase 4: DUET Integration Validation (Week 7-8)
- [ ] Test DUET3D macros with real hardware
- [ ] Validate response parsing and error handling
- [ ] Optimize performance for production use
- [ ] Implement advanced error recovery

### Phase 5: Testing & Production Readiness (Week 9-10)
- [ ] Comprehensive system testing with full hardware setup
- [ ] Performance optimization and load testing
- [ ] Long-term stability and reliability testing
- [ ] Final documentation and deployment guides

## Technical References

### DUET3D Documentation
- [Duet 3 Mainboard 6HC Hardware Overview](https://docs.duet3d.com/Duet3D_hardware/Duet_3_family/Duet_3_Mainboard_6HC_Hardware_Overview)
- [GCodes by function](https://docs.duet3d.com/User_manual/Reference/Gcodes_by_function)
- [M118: Send Message to Specific Target](https://forum.duet3d.com/topic/14451/m118-send-message-to-specific-target)
- [M575 Serial connection configuration](https://forum.duet3d.com/topic/31659/m575-serial-connection-using-the-io_1-expansion-3hc)

### Beckhoff Documentation
- [CX7080 Technical Data](https://infosys.beckhoff.com/content/1033/cx7080/9754882443.html)
- [CX7080 Product Overview](https://www.beckhoff.com/en-en/products/ipc/embedded-pcs/cx7000-arm-r-cortex-r/cx7080.html)
- [EPP2008-0002 Specifications](https://www.beckhoff.com/en-us/products/i-o/ethercat-box/eppxxxx-industrial-housing/epp2xxx-digital-output/epp2008-0002.html)
- [EPP4174-0002 Specifications](https://www.beckhoff.com/en-us/products/i-o/ethercat-box/eppxxxx-industrial-housing/epp4xxx-analog-output/epp4174-0002.html)

## Project Status

**Current State**: Phase 1 Core Framework completed

**Completed in Phase 1 & 1.5**:
1. ✅ Complete PLC code structure implemented
2. ✅ Serial communication framework with DUET3D protocol  
3. ✅ Command parsing with XOR checksum validation
4. ✅ Error handling and state management
5. ✅ Comprehensive documentation and logging established
6. ✅ Complete DUET3D integration documentation and macros
7. ✅ Protocol specification and test command library
8. ✅ DUET configuration templates and examples

**Current Project Structure**:
```
TUBS_IO/
├── PLC/                        # ✅ Core PLC Implementation
│   ├── MAIN.TcPOU             # Main program orchestration
│   ├── GVL.TcGVL              # Global variables and types
│   ├── FB_SerialHandler.TcPOU # Serial communication
│   └── FB_CommandParser.TcPOU # Command parsing
├── DOCS/                       # ✅ Complete Documentation
│   ├── ProtocolDescription.md  # Communication protocol spec
│   ├── DuetIntegration.md     # DUET3D integration guide
│   ├── PLCCodeOverview.md     # PLC architecture overview
│   └── Examples/              # Integration examples
│       ├── duet_macros.g      # DUET macro collection
│       ├── duet_config.g      # DUET configuration
│       └── test_commands.txt  # Test command library
├── claudeInstructions.md       # Project documentation
└── claudeLogbook.md           # Development log
```

**Next Steps (Phase 2)**:
1. Create EtherCAT I/O module configuration files
2. Implement FB_IOController for hardware control  
3. Test with actual EPP2008-0002 and EPP4174-0002 modules
4. Integrate real I/O operations with command processing
5. Validate DUET macros with real hardware setup

**Key Decisions Made**:
- Use M118 P5 for DUET command sending
- Implement hex-encoded responses for efficiency
- 115200 baud serial communication
- XOR checksum for command validation
- Modular function block architecture for maintainability

## AI Session Continuity Notes

**For Future AI Sessions**:
- This document contains complete architectural research and planning
- Hardware specifications and limitations are well-defined
- Communication protocol is designed and documented
- Implementation roadmap provides clear development phases
- All technical references are preserved for continued research

**Key Context**:
- User wants serial interpreter for DUET3D ↔ CX7080 ↔ EtherCAT I/O
- M118/M575 commands are the established communication method
- Hex encoding is preferred for status responses due to DUET limitations
- TwinCAT3 project structure should follow industrial automation best practices