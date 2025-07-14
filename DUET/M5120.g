; M5120 - Read Input Status
; Purpose: Read digital input status from Beckhoff controller
; Usage: M5120 Aaddress
;   A = I/O address to read (0-15 for digital inputs)
; Example: M5120 A5     ; Read digital input 5
; Response format: Two-part hex code (SSDD)
;   SS = Status byte (00=OK, FF=Error)
;   DD = I/O value (00=OFF, 01=ON for digital)

; Validate parameters
if !exists(param.A)
    M117 "M5120 Error: Missing address parameter A"
    echo "M5120 ERROR: Usage - M5120 Aaddress"
    abort "Missing address parameter"

; Store parameters for easier access
var address = param.A

; Validate address range for digital inputs
if var.address < 0 || var.address > 15
    M117 "M5120 Error: Address must be 0-15"
    echo "M5120 ERROR: Invalid input address " ^ var.address
    abort "Invalid input address"

; Build simplified digital input command
var command_str = "DI" ^ var.address

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
        echo "DEBUG: M5120 response: " ^ global.response
        
        ; Check for input pressed "BP" + address (e.g., "BP5" = hex: 42 50 35)
        var expected_bp = "42 50 " ^ {param.A + 48}  ; Convert address to ASCII hex
        
        ; Check for input released "BR" + address (e.g., "BR5" = hex: 42 52 35)
        var expected_br = "42 52 " ^ {param.A + 48}  ; Convert address to ASCII hex
        
        if global.response == var.expected_bp
            ; Input is pressed/ON
            var hex_response = "0001"  ; Status 00 = OK, Value 01 = ON
            M117 "Input " ^ var.address ^ ": " ^ var.hex_response
            echo "M5120: Input " ^ var.address ^ " = ON (0001)"
            global tubs_io_last_input = var.hex_response
            break
            
        elif global.response == var.expected_br
            ; Input is released/OFF
            var hex_response = "0000"  ; Status 00 = OK, Value 00 = OFF
            M117 "Input " ^ var.address ^ ": " ^ var.hex_response
            echo "M5120: Input " ^ var.address ^ " = OFF (0000)"
            global tubs_io_last_input = var.hex_response
            break
            
        else
            ; Unexpected response - could be error or different format
            var error_hex = "FF00"  ; Status FF = Error, Value 00
            M117 "M5120 Error: " ^ global.response ^ " (Code: " ^ var.error_hex ^ ")"
            echo "M5120 ERROR: Unexpected response from controller"
            global tubs_io_last_input = var.error_hex
            abort "Unexpected controller response"
    
    ; Check for timeout
    if (state.upTime - var.start_time) > var.timeout
        ; Timeout error - format timeout response
        var timeout_hex = "FF00"  ; Status FF = Error, Value 00
        M117 "M5120 Error: Controller timeout (Code: " ^ var.timeout_hex ^ ")"
        echo "M5120 ERROR: No response from controller"
        global tubs_io_last_input = var.timeout_hex
        abort "Controller timeout"
    
    ; Brief wait before checking again
    G4 P50

echo "M5120: Input read processing complete"