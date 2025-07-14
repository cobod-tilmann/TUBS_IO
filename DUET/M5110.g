; M5110 - Set Digital/Analog Output
; Purpose: Control digital or analog outputs on Beckhoff controller
; Usage: M5110 Ttype Cchannel Vvalue
;   T = Output type (0=Digital, 1=Analog)
;   C = Channel number (0-7 for digital, 0-3 for analog)
;   V = Value (0-1 for digital, 0-65535 for analog)
; Example: M5110 T0 C3 V1    ; Set digital output 3 to ON
; Example: M5110 T1 C0 V32768 ; Set analog output 0 to mid-range

; Validate parameters
if !exists(param.T) || !exists(param.C) || !exists(param.V)
    M117 "M5110 Error: Missing parameters T, C, or V"
    echo "M5110 ERROR: Usage - M5110 Ttype Cchannel Vvalue"
    abort "Missing parameters for M5110"

; Store parameters for easier access
var output_type = param.T
var channel = param.C
var value = param.V
var command_str = ""

; Build command based on output type
if var.output_type == 0
    ; Digital output command
    if var.channel < 0 || var.channel > 7
        M117 "M5110 Error: Digital channel must be 0-7"
        echo "M5110 ERROR: Invalid digital channel " ^ var.channel
        abort "Invalid digital channel"
    
    if var.value < 0 || var.value > 1
        M117 "M5110 Error: Digital value must be 0 or 1"
        echo "M5110 ERROR: Invalid digital value " ^ var.value
        abort "Invalid digital value"
    
    ; Create simplified command: DO followed by channel and value
    set var.command_str = "DO" ^ var.channel ^ var.value
    
elif var.output_type == 1
    ; Analog output command
    if var.channel < 0 || var.channel > 3
        M117 "M5110 Error: Analog channel must be 0-3"
        echo "M5110 ERROR: Invalid analog channel " ^ var.channel
        abort "Invalid analog channel"
    
    if var.value < 0 || var.value > 65535
        M117 "M5110 Error: Analog value must be 0-65535"
        echo "M5110 ERROR: Invalid analog value " ^ var.value
        abort "Invalid analog value"
    
    ; Create simplified command: AO followed by channel and value
    set var.command_str = "AO" ^ var.channel ^ var.value
    
else
    M117 "M5110 Error: Type must be 0 (digital) or 1 (analog)"
    echo "M5110 ERROR: Invalid output type " ^ var.output_type
    abort "Invalid output type"

; Send command to controller
M260.2 P1 S{var.command_str}

; Set timeout for response (2 seconds)
var timeout = 2000
var start_time = state.upTime

; Wait for response from controller
while true
    ; Read response from UART
    M261.2 P1 R10 V"response"
    
    ; Check if we received a response
    if exists(global.response) && global.response != null
        echo "DEBUG: M5110 response: " ^ global.response
        
        ; Check for success response "OK" (hex: 4F 4B)
        if global.response == "4F 4B"
            echo "M5110: Output set successfully"
            ; Optional: Display success message
            ; M117 "Output " ^ var.channel ^ " set to " ^ var.value
            break
        else
            ; Unexpected response - display error and abort
            M117 "M5110 Error: " ^ global.response
            echo "M5110 ERROR: Controller returned error"
            abort "Controller error response"
    
    ; Check for timeout
    if (state.upTime - var.start_time) > var.timeout
        M117 "M5110 Error: Controller timeout"
        echo "M5110 ERROR: No response from controller"
        abort "Controller timeout"
    
    ; Brief wait before checking again
    G4 P50

echo "M5110: Command processing complete"