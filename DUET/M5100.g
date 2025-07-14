; M5100 - Initialize TUBS_IO Serial Interface
; Purpose: Initialize serial communication with Beckhoff CX7080 controller
; Usage: M5100
; Response: Tests connection and verifies controller readiness

; Configure serial communication parameters
M575 P1 S1 B115200    ; Set serial port 1 to 115200 baud

; Wait for serial port to stabilize
G4 P500               ; Wait 500ms for port initialization

; Send system status request to verify controller connection
M260.2 P1 S"SYS"      ; Send simplified system status request

; Set timeout for response (3 seconds)
var timeout = 3000
var start_time = state.upTime

; Wait for response from controller
while true
    ; Read response from UART
    M261.2 P1 R10 V"response"
    
    ; Check if we received a response
    if exists(global.response) && global.response != null
        echo "DEBUG: Received response: " ^ global.response
        
        ; Check for system ready response "RDY" (hex: 52 44 59)
        if global.response == "52 44 59"
            M117 "TUBS_IO Controller Connected"
            echo "M5100: Serial interface initialized successfully"
            break
        else
            ; Unexpected response - display error and abort
            M117 "TUBS_IO Error: Invalid response - " ^ global.response
            echo "M5100 ERROR: Unexpected response from controller"
            abort "Controller initialization failed"
    
    ; Check for timeout
    if (state.upTime - var.start_time) > var.timeout
        M117 "TUBS_IO Error: Controller not responding"
        echo "M5100 ERROR: Controller initialization timeout"
        abort "Controller not responding"
    
    ; Brief wait before checking again
    G4 P100

echo "M5100: Serial interface initialization complete"