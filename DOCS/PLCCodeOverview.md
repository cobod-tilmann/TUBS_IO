# TUBS_IO PLC Code Overview

## Architecture Summary

The TUBS_IO PLC implementation follows a modular, industrial automation design pattern using IEC 61131-3 structured text. The system is built around function blocks that handle specific responsibilities in a coordinated manner.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     MAIN.TcPOU                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │ FB_SerialHandler│  │ FB_CommandParser│  │ Future: I/O │ │
│  │                 │  │                 │  │ Controller  │ │
│  │ • Connection    │  │ • Parse Commands│  │ • EtherCAT  │ │
│  │ • Send/Receive  │  │ • Validate      │  │ • Hardware  │ │
│  │ • State Machine │  │ • Checksum      │  │ • Modules   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                        ┌───────▼───────┐
                        │   GVL.TcGVL   │
                        │ • Constants   │
                        │ • Types       │
                        │ • Error Codes │
                        └───────────────┘
```

## File Structure and Responsibilities

### 1. MAIN.TcPOU - System Orchestrator

**Purpose**: Central coordination of all system components

**Key Responsibilities**:
- System initialization state machine
- Function block coordination
- Command processing workflow
- Error handling and recovery
- Response generation and transmission

**Core State Machine**:
```
INIT_START → INIT_SERIAL → INIT_PARSER → INIT_COMPLETE → RUNNING
     ↓                                                      ↑
INIT_ERROR ←─────────────────────────────────────────────────┘
```

**Main Execution Flow**:
1. **Initialization**: System startup and component initialization
2. **Serial Monitoring**: Continuous monitoring for incoming commands
3. **Command Processing**: Parse and validate received commands
4. **Command Execution**: Execute valid commands (placeholder for I/O operations)
5. **Response Generation**: Format and send responses back to DUET
6. **Error Handling**: Manage and report error conditions

### 2. GVL.TcGVL - Global Definitions

**Purpose**: Centralized constants, types, and system-wide definitions

**Key Components**:

#### System Constants
```pascal
SERIAL_BAUD_RATE: 115200        // Communication speed
SERIAL_TIMEOUT_MS: 1000         // Communication timeout
MAIN_CYCLE_TIME_MS: 10          // Real-time cycle
```

#### I/O Module Specifications
```pascal
EPP2008_CHANNELS: 8             // Digital output channels
EPP4174_CHANNELS: 4             // Analog output channels
EPP2008_MAX_CURRENT: 0.5        // Max current per channel
```

#### Error Code Definitions
```pascal
ERR_NO_ERROR: 0                 // Success
ERR_INVALID_COMMAND: 1          // Parse error
ERR_CHECKSUM_ERROR: 4           // Validation error
... (9 total error codes)
```

#### Type Definitions
- `E_InitState`: System initialization states
- `E_CommandType`: Command type enumeration
- `E_SerialState`: Serial communication states
- `ST_ParsedCommand`: Command structure
- `ST_SystemStatus`: System status structure

### 3. FB_SerialHandler - Communication Manager

**Purpose**: Manages all serial communication with DUET3D controller

**Key Features**:

#### Connection Management
- Automatic connection establishment
- Connection monitoring and health checking
- Automatic reconnection on failures
- Configurable timeouts and retry logic

#### Data Handling
- CRLF-terminated message processing
- Buffer management for send/receive operations
- Message queuing and flow control
- Statistics tracking for diagnostics

#### State Machine
```
DISCONNECTED → CONNECTING → CONNECTED → ERROR → TIMEOUT
     ↑              ↓           ↓         ↓        ↓
     └──────────────┴───────────┴─────────┴────────┘
```

**Key Methods**:
- `Init()`: Initialize serial communication parameters
- `HandleIncomingData()`: Process received data and extract commands
- `SendResponse()`: Transmit formatted responses
- `ResetConnection()`: Force connection reset for troubleshooting

### 4. FB_CommandParser - Command Processor

**Purpose**: Parse, validate, and structure incoming commands

**Key Features**:

#### Command Parsing
- Colon-separated field extraction
- Parameter type conversion and validation
- Command type identification
- Bounds checking for all parameters

#### Checksum Validation
- XOR checksum calculation
- Message integrity verification
- Automatic error generation for invalid checksums

#### Error Handling
- Comprehensive validation of all command elements
- Detailed error reporting with specific error codes
- Statistics tracking for debugging

**Key Methods**:
- `ParseCommand()`: Main parsing entry point
- `SplitString()`: Utility for field separation
- `CalculateChecksum()`: XOR checksum computation
- `ValidateCommand()`: Final command validation

## Data Flow Architecture

### 1. Command Reception Flow

```
DUET3D → Serial Port → FB_SerialHandler → Command Buffer → FB_CommandParser
                                                                ↓
                         Response ← MAIN.TcPOU ← Parsed Command Structure
```

### 2. Command Processing Flow

```
Parsed Command → MAIN.TcPOU Command Dispatcher
                       ↓
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
   DO Command     AO Command     DI Request
        ↓              ↓              ↓
[Future I/O Control Implementation]
        ↓              ↓              ↓
   Success/Error  Success/Error  Status Data
        ↓              ↓              ↓
        └──────────────┼──────────────┘
                       ↓
              Response Generation
```

## Error Handling Strategy

### Three-Layer Error Architecture

#### 1. Function Block Level
- Each function block validates its inputs
- Returns specific error codes for failures
- Maintains internal error statistics
- Provides diagnostic information

#### 2. System Level (MAIN.TcPOU)
- Coordinates error responses between function blocks
- Implements system-wide error recovery
- Manages error logging and reporting
- Handles critical system failures

#### 3. Communication Level
- Protocol-level error responses
- Checksum validation failures
- Timeout and connection errors
- Invalid command format handling

### Error Response Generation

```pascal
CASE nErrorCode OF
    GVL.ERR_INVALID_COMMAND:
        sResponseMessage := 'ERR:INVALID_COMMAND:' + 
                           fbCommandParser.CalculateChecksum('ERR:INVALID_COMMAND');
    GVL.ERR_CHECKSUM_ERROR:
        sResponseMessage := 'ERR:CHECKSUM_ERROR:' + 
                           fbCommandParser.CalculateChecksum('ERR:CHECKSUM_ERROR');
    // ... additional error cases
END_CASE
```

## Real-Time Performance Design

### Task Timing Structure

- **Main Task Cycle**: 10ms for real-time response
- **Serial Polling**: 5ms intervals for communication responsiveness
- **Command Timeout**: 5000ms maximum processing time
- **Response Timeout**: 100ms for DUET compatibility

### Performance Optimizations

1. **Non-blocking Operations**: All communication operations are non-blocking
2. **State Machines**: Efficient state-based processing
3. **Buffer Management**: Optimized memory usage
4. **Minimal Processing**: Command parsing optimized for speed

## Integration Points for Phase 2

### Future I/O Controller Integration

The current architecture includes placeholders for Phase 2 EtherCAT I/O integration:

```pascal
// In MAIN.TcPOU - placeholder for future I/O operations
CASE stParsedCommand.eCommandType OF
    E_CommandType.CMD_DO:
        // TODO: Replace with actual EPP2008-0002 control
        ProcessDigitalOutputCommand();
    E_CommandType.CMD_AO:
        // TODO: Replace with actual EPP4174-0002 control  
        ProcessAnalogOutputCommand();
END_CASE
```

### Required Phase 2 Components

1. **FB_IOController**: EtherCAT module control function block
2. **I/O Variable Mapping**: Direct hardware I/O connections
3. **Module Health Monitoring**: EtherCAT diagnostic capabilities
4. **Fault Handling**: Hardware-specific error management

## Code Quality Features

### 1. Comprehensive Documentation
- Every function block and method includes detailed comments
- Clear variable naming conventions
- Structured code organization

### 2. Type Safety
- Strong typing throughout the system
- Input validation for all function parameters
- Bounds checking for all operations

### 3. Maintainability
- Modular design with clear separation of concerns
- Configurable constants in centralized location
- Standardized error handling patterns

### 4. Testability
- Statistics interfaces for monitoring
- Diagnostic methods for troubleshooting
- Clear input/output interfaces

## Development Standards Applied

### IEC 61131-3 Compliance
- Structured text programming language
- Standard function block interfaces
- Industrial automation design patterns

### Naming Conventions
- **Function Blocks**: `FB_` prefix (e.g., `FB_SerialHandler`)
- **Types**: `ST_` for structures, `E_` for enums
- **Variables**: Descriptive names with type prefixes
- **Constants**: ALL_CAPS with descriptive names

### Code Structure
- Consistent indentation and formatting
- Logical grouping of related functionality
- Clear method and variable declarations

## Debugging and Diagnostics

### Built-in Diagnostic Features

#### Statistics Tracking
```pascal
TYPE ST_SerialStatistics :
STRUCT
    nConnectionAttempts : UINT;
    nCommandsReceived   : UDINT;
    nResponsesSent      : UDINT;
    nErrorCount         : UINT;
END_STRUCT
```

#### System Status Monitoring
```pascal
TYPE ST_SystemStatus :
STRUCT
    bInitialized        : BOOL;
    bSerialConnected    : BOOL;
    nErrorCount         : UINT;
    sLastError          : STRING(100);
END_STRUCT
```

### Debug Interface Methods
- `GetStatistics()`: Retrieve operational statistics
- `ResetStatistics()`: Clear diagnostic counters
- `GetSystemStatus()`: Current system state information

## Scalability Considerations

### Memory Management
- Efficient string handling for command processing
- Bounded arrays and buffers
- Configurable buffer sizes for different applications

### Performance Scaling
- Modular design allows for easy feature addition
- Centralized configuration management
- Scalable error handling architecture

This PLC code overview provides a complete understanding of the system architecture, design decisions, and implementation details for the TUBS_IO serial interpreter project.