; ============================================================================
; TUBS_IO DUET3D Configuration File
; Purpose: Essential configuration settings for TUBS_IO integration
; Usage: Add these lines to your config.g file or create as separate include
; ============================================================================

; ----------------------------------------------------------------------------
; SERIAL COMMUNICATION SETUP
; ----------------------------------------------------------------------------

; Configure second UART for TUBS_IO communication
; P2 = Second UART port (io1 or io2 connector)
; B115200 = 115200 baud rate (must match CX7080 setting)
; S2 = Standard UART mode with no special formatting
M575 P2 B115200 S2

; Verify serial port configuration
echo "TUBS_IO: Serial port P2 configured at 115200 baud"

; ----------------------------------------------------------------------------
; GLOBAL VARIABLE INITIALIZATION
; ----------------------------------------------------------------------------

; Initialize TUBS_IO system tracking variables
set global.tubs_connected = false           ; Connection status
set global.tubs_error_count = 0             ; Error counter
set global.tubs_last_response = ""          ; Last response received
set global.tubs_initialized = false         ; Initialization status

; Digital output state tracking (8 channels)
set global.tubs_do_state = {0,0,0,0,0,0,0,0}

; Analog output state tracking (4 channels) - stored as percentages
set global.tubs_ao_state = {0,0,0,0}

; System configuration flags
set global.tubs_auto_connect = true         ; Automatic connection on startup
set global.tubs_debug_mode = false          ; Enable debug messaging

echo "TUBS_IO: Global variables initialized"

; ----------------------------------------------------------------------------
; NETWORK AND COMMUNICATION SETTINGS
; ----------------------------------------------------------------------------

; Network configuration (if using Ethernet for monitoring)
; Adjust IP settings according to your network
; M552 P192.168.1.100                       ; Set IP address (example)
; M553 P255.255.255.0                       ; Set netmask (example)
; M554 P192.168.1.1                         ; Set gateway (example)

; Enable network interface
; M552 S1                                   ; Enable network (uncomment if needed)

; ----------------------------------------------------------------------------
; SAFETY AND EMERGENCY CONFIGURATIONS
; ----------------------------------------------------------------------------

; Emergency stop configuration
; When emergency stop is triggered, turn off all TUBS_IO outputs
; This can be added to your stop.g or emergency stop macros

; Power fail configuration
; On power failure, ensure TUBS_IO outputs are in safe state
; Add to resurrect.g or power management scripts

; ----------------------------------------------------------------------------
; STARTUP SEQUENCE FOR TUBS_IO
; ----------------------------------------------------------------------------

; Optional: Automatic TUBS_IO connection test on startup
; Uncomment the following lines to enable automatic startup testing

; echo "TUBS_IO: Starting connection test..."
; G4 P2000                                  ; Wait 2 seconds for CX7080 boot
; M118 P2 S"SYS:STATUS:0:XX"               ; Test system status
; G4 P500                                   ; Wait for response
; set global.tubs_initialized = true
; echo "TUBS_IO: Initialization complete"

; ----------------------------------------------------------------------------
; TOOL AND HEATER INTEGRATION
; ----------------------------------------------------------------------------

; Tool definitions (if integrating TUBS_IO with tool control)
; M563 P0 D0 H1 F0                         ; Define tool 0
; M568 P0 R0 S0                             ; Set tool 0 standby and active temperatures

; Heater configurations (if using TUBS_IO for heater control)
; These would be used if TUBS_IO analog outputs control heaters
; M308 S10 P"nil" Y"dummythermistor" A"TUBS Chamber" ; Virtual sensor for TUBS heater
; M950 H10 C"nil"                          ; Virtual heater for TUBS control

; ----------------------------------------------------------------------------
; FAN CONTROL INTEGRATION
; ----------------------------------------------------------------------------

; Fan definitions (if integrating TUBS_IO with fan control)
; M950 F10 C"nil"                          ; Virtual fan for TUBS control
; M106 P10 S0 H-1                          ; Define TUBS-controlled fan

; Fan control macros can call TUBS_IO digital outputs
; Example: When M106 P10 S255 is called, trigger TUBS_IO DO:1:1:XX

; ----------------------------------------------------------------------------
; AXIS AND MOVEMENT CONFIGURATION
; ----------------------------------------------------------------------------

; Movement parameters (standard DUET configuration)
; M566 X900 Y900 Z12 E120                  ; Set maximum instantaneous speed changes (mm/min)
; M203 X6000 Y6000 Z180 E1200              ; Set maximum speeds (mm/min)
; M201 X500 Y500 Z20 E250                  ; Set accelerations (mm/s^2)

; ----------------------------------------------------------------------------
; SENSOR INTEGRATION
; ----------------------------------------------------------------------------

; Input pin configuration for feedback from TUBS_IO
; If using DUET inputs to monitor TUBS_IO digital inputs
; M950 J10 C"io4.in"                       ; Configure input pin for TUBS feedback

; Endstop configuration (standard)
; M574 X1 S1 P"xstop"                      ; Configure X endstop
; M574 Y1 S1 P"ystop"                      ; Configure Y endstop
; M574 Z1 S2                               ; Configure Z probe endstop

; ----------------------------------------------------------------------------
; TUBS_IO SPECIFIC CONFIGURATIONS
; ----------------------------------------------------------------------------

; Communication timeout settings
set global.tubs_timeout_ms = 1000           ; Response timeout in milliseconds
set global.tubs_retry_count = 3             ; Number of retry attempts

; Channel mapping definitions (customize for your hardware)
set global.tubs_chamber_light_ch = 0        ; Digital output channel for chamber lighting
set global.tubs_exhaust_fan_ch = 1          ; Digital output channel for exhaust fan
set global.tubs_chamber_heat_ch = 0         ; Analog output channel for chamber heater
set global.tubs_part_cooling_ch = 1         ; Analog output channel for part cooling

; Safety limits for analog outputs (percentages)
set global.tubs_max_chamber_heat = 80       ; Maximum chamber heater percentage
set global.tubs_max_part_cooling = 100      ; Maximum part cooling percentage

echo "TUBS_IO: Channel mapping configured"

; ----------------------------------------------------------------------------
; DEBUGGING AND MONITORING
; ----------------------------------------------------------------------------

; Debug configuration
; Enable logging for TUBS_IO communication (optional)
; M929 P"tubs_debug.log" S1                ; Start logging (uncomment if needed)

; Console output settings
M111 S0                                     ; Set debug level (0=normal, 1=info, 2=debug)

; Status report configuration
; M918 P1 E4                               ; Configure status reports (if using PanelDue)

; ----------------------------------------------------------------------------
; CUSTOM COMMANDS FOR TUBS_IO
; ----------------------------------------------------------------------------

; Define custom G-codes for TUBS_IO control (using M98 macro calls)
; These can be used in G-code files for automated control

; Example custom commands:
; M800 - Initialize TUBS_IO for print start
; M801 - TUBS_IO print end cleanup  
; M802 - Emergency TUBS_IO shutdown
; M810-817 - Direct digital output control (channels 0-7)
; M820-823 - Direct analog output control (channels 0-3)

; ----------------------------------------------------------------------------
; MATERIAL-SPECIFIC CONFIGURATIONS
; ----------------------------------------------------------------------------

; Material presets for TUBS_IO control
; These can be used with conditional G-code

; PLA settings
set global.tubs_pla_chamber_temp = 30       ; Chamber temperature percentage for PLA
set global.tubs_pla_exhaust_speed = 50      ; Exhaust fan speed for PLA

; PETG settings  
set global.tubs_petg_chamber_temp = 40      ; Chamber temperature percentage for PETG
set global.tubs_petg_exhaust_speed = 60     ; Exhaust fan speed for PETG

; ABS settings
set global.tubs_abs_chamber_temp = 60       ; Chamber temperature percentage for ABS
set global.tubs_abs_exhaust_speed = 80      ; Exhaust fan speed for ABS

; ASA settings
set global.tubs_asa_chamber_temp = 70       ; Chamber temperature percentage for ASA
set global.tubs_asa_exhaust_speed = 80      ; Exhaust fan speed for ASA

echo "TUBS_IO: Material presets configured"

; ----------------------------------------------------------------------------
; CONDITIONAL LOADING OF ADDITIONAL CONFIGURATIONS
; ----------------------------------------------------------------------------

; Load additional configuration files if they exist
; This allows for modular configuration management

if fileexists("0:/sys/tubs_advanced.g")
    M98 P"tubs_advanced.g"                  ; Load advanced TUBS_IO settings
    echo "TUBS_IO: Advanced configuration loaded"
endif

if fileexists("0:/sys/tubs_user.g")
    M98 P"tubs_user.g"                      ; Load user-specific settings
    echo "TUBS_IO: User configuration loaded"
endif

; ----------------------------------------------------------------------------
; FINAL INITIALIZATION
; ----------------------------------------------------------------------------

; Set system ready flag
set global.tubs_config_loaded = true
echo "TUBS_IO: Configuration complete"

; Optional: Display current configuration
echo "Serial Port: P2 at 115200 baud"
echo "Digital Outputs: 8 channels (EPP2008-0002)"
echo "Analog Outputs: 4 channels (EPP4174-0002)"
echo "Ready for TUBS_IO communication"

; ============================================================================
; CONFIGURATION NOTES:
;
; 1. SERIAL SETUP:
;    - M575 P2 B115200 S2 is the essential command for TUBS_IO communication
;    - Ensure your CX7080 is configured for 115200 baud rate
;    - Check wiring between DUET io1/io2 and CX7080 COM port
;
; 2. GLOBAL VARIABLES:
;    - All global.tubs_* variables are for tracking and configuration
;    - Customize channel mappings to match your hardware setup
;    - Adjust safety limits based on your equipment specifications
;
; 3. SAFETY CONSIDERATIONS:
;    - Always test TUBS_IO commands manually before automation
;    - Implement emergency stop procedures for all TUBS_IO outputs
;    - Monitor system responses and implement error handling
;
; 4. CUSTOMIZATION:
;    - Modify channel assignments to match your specific hardware
;    - Adjust timeout and retry settings based on system performance
;    - Add material-specific presets as needed for your workflow
;
; 5. TROUBLESHOOTING:
;    - If no response from TUBS_IO, check M575 configuration
;    - Verify serial wiring and signal levels (3.3V TTL to RS232)
;    - Use M118 P2 S"SYS:STATUS:0:XX" for basic communication test
;
; ============================================================================

; End of TUBS_IO configuration