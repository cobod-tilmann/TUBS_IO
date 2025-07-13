; ============================================================================
; TUBS_IO DUET3D Macro Collection
; Purpose: Convenient macros for controlling TUBS_IO serial interpreter
; Usage: Copy desired macros to DUET macro files and customize as needed
; ============================================================================

; ----------------------------------------------------------------------------
; BASIC DIGITAL OUTPUT CONTROL MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_do_on.g
; Turn on a digital output channel
; Usage: M98 P"tubs_do_on.g" S<channel>
; Example: M98 P"tubs_do_on.g" S0
if exists(param.S)
    var channel = param.S
    if var.channel >= 0 && var.channel <= 7
        ; Simple command without checksum calculation (replace XX with actual checksum)
        M118 P2 S{"DO:" ^ var.channel ^ ":1:XX"}
        echo "TUBS_IO: Digital output " ^ var.channel ^ " turned ON"
        G4 P50  ; Wait 50ms for response
    else
        echo "ERROR: Digital output channel must be 0-7"
    endif
else
    echo "ERROR: No channel specified. Use S parameter (0-7)"
endif

; ----------------------------------------------------------------------------

; Macro: tubs_do_off.g  
; Turn off a digital output channel
; Usage: M98 P"tubs_do_off.g" S<channel>
; Example: M98 P"tubs_do_off.g" S0
if exists(param.S)
    var channel = param.S
    if var.channel >= 0 && var.channel <= 7
        M118 P2 S{"DO:" ^ var.channel ^ ":0:XX"}
        echo "TUBS_IO: Digital output " ^ var.channel ^ " turned OFF"
        G4 P50
    else
        echo "ERROR: Digital output channel must be 0-7"
    endif
else
    echo "ERROR: No channel specified. Use S parameter (0-7)"
endif

; ----------------------------------------------------------------------------

; Macro: tubs_do_toggle.g
; Toggle a digital output channel
; Usage: M98 P"tubs_do_toggle.g" S<channel>
; Note: Requires tracking current state in global variable
if exists(param.S)
    var channel = param.S
    if var.channel >= 0 && var.channel <= 7
        ; Check current state (requires global variable tracking)
        if !exists(global.tubs_do_state)
            set global.tubs_do_state = {0,0,0,0,0,0,0,0}  ; Initialize all OFF
        endif
        
        if global.tubs_do_state[var.channel] == 0
            M98 P"tubs_do_on.g" S{var.channel}
            set global.tubs_do_state[var.channel] = 1
        else
            M98 P"tubs_do_off.g" S{var.channel}
            set global.tubs_do_state[var.channel] = 0
        endif
    else
        echo "ERROR: Digital output channel must be 0-7"
    endif
else
    echo "ERROR: No channel specified. Use S parameter (0-7)"
endif

; ----------------------------------------------------------------------------
; ANALOG OUTPUT CONTROL MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_ao_set.g
; Set analog output value
; Usage: M98 P"tubs_ao_set.g" S<channel> R<value>
; Example: M98 P"tubs_ao_set.g" S0 R32768  (mid-scale)
if exists(param.S) && exists(param.R)
    var channel = param.S
    var value = param.R
    if var.channel >= 0 && var.channel <= 3 && var.value >= 0 && var.value <= 65535
        M118 P2 S{"AO:" ^ var.channel ^ ":" ^ var.value ^ ":XX"}
        echo "TUBS_IO: Analog output " ^ var.channel ^ " set to " ^ var.value
        G4 P50
    else
        echo "ERROR: Channel 0-3, Value 0-65535"
    endif
else
    echo "ERROR: Specify channel (S:0-3) and value (R:0-65535)"
endif

; ----------------------------------------------------------------------------

; Macro: tubs_ao_percent.g
; Set analog output as percentage (0-100%)
; Usage: M98 P"tubs_ao_percent.g" S<channel> R<percent>
; Example: M98 P"tubs_ao_percent.g" S0 R50  (50% = mid-scale)
if exists(param.S) && exists(param.R)
    var channel = param.S
    var percent = param.R
    if var.channel >= 0 && var.channel <= 3 && var.percent >= 0 && var.percent <= 100
        var value = {(var.percent * 65535) / 100}
        M118 P2 S{"AO:" ^ var.channel ^ ":" ^ var.value ^ ":XX"}
        echo "TUBS_IO: Analog output " ^ var.channel ^ " set to " ^ var.percent ^ "% (" ^ var.value ^ ")"
        G4 P50
    else
        echo "ERROR: Channel 0-3, Percent 0-100"
    endif
else
    echo "ERROR: Specify channel (S:0-3) and percent (R:0-100)"
endif

; ----------------------------------------------------------------------------

; Macro: tubs_ao_voltage.g
; Set analog output as voltage (-10V to +10V)
; Usage: M98 P"tubs_ao_voltage.g" S<channel> R<voltage>
; Example: M98 P"tubs_ao_voltage.g" S0 R5.0  (5.0 volts)
if exists(param.S) && exists(param.R)
    var channel = param.S
    var voltage = param.R
    if var.channel >= 0 && var.channel <= 3 && var.voltage >= -10.0 && var.voltage <= 10.0
        var value = {((var.voltage + 10.0) * 65535) / 20.0}
        M118 P2 S{"AO:" ^ var.channel ^ ":" ^ var.value ^ ":XX"}
        echo "TUBS_IO: Analog output " ^ var.channel ^ " set to " ^ var.voltage ^ "V (" ^ var.value ^ ")"
        G4 P50
    else
        echo "ERROR: Channel 0-3, Voltage -10.0 to +10.0"
    endif
else
    echo "ERROR: Specify channel (S:0-3) and voltage (R:-10.0 to +10.0)"
endif

; ----------------------------------------------------------------------------
; STATUS AND MONITORING MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_get_inputs.g
; Request digital input status
; Usage: M98 P"tubs_get_inputs.g"
M118 P2 S"DI:ALL:0:XX"
echo "TUBS_IO: Digital input status requested"
echo "Watch console for response: DI:XXXX:YY (hex format)"
G4 P100  ; Wait longer for input reading

; ----------------------------------------------------------------------------

; Macro: tubs_system_status.g
; Check TUBS_IO system status
; Usage: M98 P"tubs_system_status.g"
M118 P2 S"SYS:STATUS:0:XX"
echo "TUBS_IO: System status requested"
echo "Expected response: OK:CX7080:1.0.0:XX"
G4 P100

; ----------------------------------------------------------------------------

; Macro: tubs_connection_test.g
; Test basic communication with TUBS_IO
; Usage: M98 P"tubs_connection_test.g"
echo "TUBS_IO: Testing connection..."
M118 P2 S"SYS:STATUS:0:XX"
G4 P200
echo "If no response received, check:"
echo "1. Serial wiring and connections"
echo "2. CX7080 power and status"
echo "3. Baud rate configuration (M575 P2 B115200 S2)"
echo "4. Level shifter operation (3.3V TTL to RS232)"

; ----------------------------------------------------------------------------
; UTILITY AND HELPER MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_all_outputs_off.g
; Emergency shutdown - turn off all outputs
; Usage: M98 P"tubs_all_outputs_off.g"
echo "TUBS_IO: EMERGENCY - Turning off all outputs..."

; Turn off all digital outputs
M98 P"tubs_do_off.g" S0
M98 P"tubs_do_off.g" S1
M98 P"tubs_do_off.g" S2
M98 P"tubs_do_off.g" S3
M98 P"tubs_do_off.g" S4
M98 P"tubs_do_off.g" S5
M98 P"tubs_do_off.g" S6
M98 P"tubs_do_off.g" S7

; Set all analog outputs to 0
M98 P"tubs_ao_set.g" S0 R0
M98 P"tubs_ao_set.g" S1 R0
M98 P"tubs_ao_set.g" S2 R0
M98 P"tubs_ao_set.g" S3 R0

echo "TUBS_IO: All outputs turned OFF"

; ----------------------------------------------------------------------------

; Macro: tubs_send_raw.g
; Send raw command to TUBS_IO (for testing/debugging)
; Usage: M98 P"tubs_send_raw.g" S"command_string"
; Example: M98 P"tubs_send_raw.g" S"DO:0:1:XX"
if exists(param.S)
    echo "TUBS_IO: Sending raw command: " ^ param.S
    M118 P2 S{param.S}
    G4 P100
else
    echo "ERROR: No command specified. Use S parameter"
    echo "Example: M98 P\"tubs_send_raw.g\" S\"SYS:STATUS:0:XX\""
endif

; ----------------------------------------------------------------------------
; APPLICATION-SPECIFIC MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_print_start.g
; Initialize outputs for print start
; Usage: M98 P"tubs_print_start.g"
echo "TUBS_IO: Initializing for print start..."
M98 P"tubs_do_on.g" S0      ; Chamber lighting
M98 P"tubs_do_on.g" S1      ; Exhaust fan
M98 P"tubs_ao_percent.g" S0 R25  ; Heater to 25%
G4 P200  ; Wait for all commands to process
echo "TUBS_IO: Print start initialization complete"

; ----------------------------------------------------------------------------

; Macro: tubs_print_end.g
; Clean up outputs after print completion
; Usage: M98 P"tubs_print_end.g"
echo "TUBS_IO: Print end cleanup..."
M98 P"tubs_ao_percent.g" S0 R0   ; Turn off heater first
G4 P2000  ; Wait 2 seconds
M98 P"tubs_do_off.g" S1          ; Turn off exhaust fan
G4 P5000  ; Wait 5 seconds for air clearing
M98 P"tubs_do_off.g" S0          ; Turn off chamber lighting
echo "TUBS_IO: Print end cleanup complete"

; ----------------------------------------------------------------------------

; Macro: tubs_chamber_heat.g
; Set chamber heater based on material type
; Usage: M98 P"tubs_chamber_heat.g" S<material_code>
; Codes: 0=OFF, 1=PLA(30%), 2=PETG(40%), 3=ABS(60%), 4=ASA(70%)
if exists(param.S)
    var material = param.S
    if var.material == 0
        M98 P"tubs_ao_percent.g" S0 R0
        echo "TUBS_IO: Chamber heater OFF"
    elif var.material == 1
        M98 P"tubs_ao_percent.g" S0 R30
        echo "TUBS_IO: Chamber heater set for PLA (30%)"
    elif var.material == 2
        M98 P"tubs_ao_percent.g" S0 R40
        echo "TUBS_IO: Chamber heater set for PETG (40%)"
    elif var.material == 3
        M98 P"tubs_ao_percent.g" S0 R60
        echo "TUBS_IO: Chamber heater set for ABS (60%)"
    elif var.material == 4
        M98 P"tubs_ao_percent.g" S0 R70
        echo "TUBS_IO: Chamber heater set for ASA (70%)"
    else
        echo "ERROR: Material code 0-4 (0=OFF,1=PLA,2=PETG,3=ABS,4=ASA)"
    endif
else
    echo "ERROR: Specify material code S parameter"
    echo "Codes: 0=OFF, 1=PLA, 2=PETG, 3=ABS, 4=ASA"
endif

; ----------------------------------------------------------------------------
; MAINTENANCE AND DIAGNOSTIC MACROS
; ----------------------------------------------------------------------------

; Macro: tubs_io_test.g
; Comprehensive I/O test sequence
; Usage: M98 P"tubs_io_test.g"
echo "TUBS_IO: Starting I/O test sequence..."

; Test system status
echo "1. Testing system status..."
M98 P"tubs_system_status.g"
G4 P500

; Test digital outputs (cycle all channels)
echo "2. Testing digital outputs..."
M98 P"tubs_do_on.g" S0
G4 P500
M98 P"tubs_do_off.g" S0
M98 P"tubs_do_on.g" S1
G4 P500
M98 P"tubs_do_off.g" S1

; Test analog outputs (ramp up and down)
echo "3. Testing analog outputs..."
M98 P"tubs_ao_percent.g" S0 R25
G4 P1000
M98 P"tubs_ao_percent.g" S0 R50
G4 P1000
M98 P"tubs_ao_percent.g" S0 R0

; Test input reading
echo "4. Testing input reading..."
M98 P"tubs_get_inputs.g"
G4 P500

echo "TUBS_IO: I/O test sequence complete"

; ----------------------------------------------------------------------------
; CONFIGURATION HELPERS
; ----------------------------------------------------------------------------

; Macro: tubs_init_variables.g
; Initialize global variables for TUBS_IO tracking
; Usage: M98 P"tubs_init_variables.g"
set global.tubs_connected = false
set global.tubs_error_count = 0
set global.tubs_do_state = {0,0,0,0,0,0,0,0}  ; Track digital output states
set global.tubs_ao_state = {0,0,0,0}          ; Track analog output states
echo "TUBS_IO: Global variables initialized"

; ----------------------------------------------------------------------------

; Macro: tubs_show_config.g
; Display current TUBS_IO configuration
; Usage: M98 P"tubs_show_config.g"
echo "TUBS_IO Configuration:"
echo "======================"
M575 P2  ; Show current serial port settings
echo ""
echo "Global Variables:"
if exists(global.tubs_connected)
    echo "  Connected: " ^ global.tubs_connected
else
    echo "  Connected: Not initialized"
endif
if exists(global.tubs_error_count)
    echo "  Error Count: " ^ global.tubs_error_count
else
    echo "  Error Count: Not initialized"
endif

; ============================================================================
; USAGE NOTES:
; 
; 1. Replace "XX" in commands with actual checksums for production use
; 2. Customize timing delays (G4 commands) based on your system requirements
; 3. Modify channel assignments to match your hardware configuration
; 4. Add error checking and response parsing for critical applications
; 5. Consider implementing global variable tracking for system state
; 
; INSTALLATION:
; 
; 1. Copy desired macros to individual .g files in your DUET macros folder
; 2. Ensure M575 P2 B115200 S2 is configured in config.g
; 3. Test basic communication with tubs_connection_test.g
; 4. Customize application-specific macros for your use case
; 
; ============================================================================