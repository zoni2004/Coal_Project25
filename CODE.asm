INCLUDE Irvine32.inc

.data
    hours   BYTE ?           ; Stores the hour value
    minutes BYTE ?           ; Stores the minutes value
    seconds BYTE ?           ; Stores the seconds value
    sysTime SYSTEMTIME <>    ; To hold the system time
    lastSecond BYTE ?        ; To track second changes

    ; Large number patterns (7 rows for each digit)
    digit0  BYTE " ***  ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    digit1  BYTE "  *   ", 0
           BYTE "  **   ", 0
           BYTE "   *   ", 0
           BYTE "   *   ", 0
           BYTE "   *   ", 0
           BYTE "   *   ", 0
           BYTE "  ***  ", 0

    digit2  BYTE " ***  ", 0
           BYTE " *   * ", 0
           BYTE "    *  ", 0
           BYTE "   *   ", 0
           BYTE "  *    ", 0
           BYTE " *     ", 0
           BYTE " ***** ", 0

    digit3  BYTE " ***  ", 0
           BYTE " *   * ", 0
           BYTE "     * ", 0
           BYTE "   **  ", 0
           BYTE "     * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    digit4  BYTE "*   * ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE " ***** ", 0
           BYTE "     * ", 0
           BYTE "     * ", 0
           BYTE "     * ", 0

    digit5  BYTE "***** ", 0
           BYTE " *     ", 0
           BYTE " *     ", 0
           BYTE " ****  ", 0
           BYTE "     * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    digit6  BYTE " ***  ", 0
           BYTE " *     ", 0
           BYTE " *     ", 0
           BYTE " ****  ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    digit7  BYTE "***** ", 0
           BYTE "     * ", 0
           BYTE "    *  ", 0
           BYTE "   *   ", 0
           BYTE "  *    ", 0
           BYTE "  *    ", 0
           BYTE "  *    ", 0

    digit8  BYTE " ***  ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    digit9 BYTE "  ***  ", 0
           BYTE " *   * ", 0
           BYTE " *   * ", 0
           BYTE "  **** ", 0
           BYTE "     * ", 0
           BYTE " *   * ", 0
           BYTE "  ***  ", 0

    colonPattern BYTE "   ", 0
                BYTE " @ ", 0
                BYTE " @ ", 0
                BYTE "   ", 0
                BYTE " @ ", 0
                BYTE " @ ", 0
                BYTE "   ", 0

    digitHeight = 7
    digitWidth = 8
    numberPtr DWORD digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9

.code
main PROC
    call Clrscr
    mov lastSecond, 0FFh    ; Initialize to invalid value

clockLoop:
    ; Get system time
    INVOKE GetLocalTime, ADDR sysTime
    ; Check if second has changed
    mov al, byte ptr sysTime.wSecond
    cmp al, lastSecond
    je waitForChange
    mov lastSecond, al

    ; Clear screen and set text color
    call Clrscr
    mov eax, green    ; Light cyan text on black background
    call SetTextColor

    ; Position cursor for the clock display
    mov dh, 8    ; Row
    mov dl, 25   ; Column
    call Gotoxy

    ; Display hours
    movzx eax, sysTime.wHour
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax          ; Save second digit
    call DisplayDigit
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display colon
    call DisplayColon

    ; Display minutes
    movzx eax, sysTime.wMinute
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax
    call DisplayDigit
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

    ; Display colon
    call DisplayColon

    ; Display seconds
    movzx eax, sysTime.wSecond
    mov bl, 10
    div bl
    movzx ebx, al    ; First digit
    push ax
    call DisplayDigit
    pop ax
    movzx ebx, ah    ; Second digit
    call DisplayDigit

waitForChange:
    ; Small delay to prevent CPU overload
    mov eax, 50    ; 50ms delay
    call Delay
    jmp clockLoop

    exit
main ENDP

DisplayDigit PROC
    push eax
    push ecx
    push edx
    push esi

    ; Calculate pointer to digit pattern
    mov esi, DWORD PTR numberPtr[ebx * 4]
    mov ecx, digitHeight    ; Number of rows

displayLoop:
    push ecx
    push dx
    ; Display current row of the digit
    mov edx, esi
    mov eax, green    ; Light cyan text on black background
    call SetTextColor
    call WriteString
    ; Move to next row
    pop dx
    inc dh
    call Gotoxy
    ; Move to next row in pattern
    add esi, digitWidth
    pop ecx
    loop displayLoop

    ; Move cursor position for next digit
    pop esi
    pop edx
    add dl, digitWidth
    call Gotoxy
    pop ecx
    pop eax
    ret
DisplayDigit ENDP

DisplayColon PROC
    push eax
    push ecx
    push edx
    push esi

    ; Set the text color to red (lightRed or red depending on the constant in Irvine32)
    mov eax, lightRed + (black * 16)   ; Set text color to red (lightRed with black background)
    call SetTextColor

    lea esi, colonPattern             ; Load address of colon pattern
    mov ecx, digitHeight             ; Set the number of rows to display

colonLoop:
    push ecx
    push dx
    mov edx, esi
    call WriteString                 ; Display the colon pattern for the current row
    pop dx
    inc dh
    call Gotoxy                      ; Move the cursor down one row
    add esi, 4                        ; Move to the next row of the colon pattern (4 bytes wide)
    pop ecx
    loop colonLoop                    ; Loop through all rows of the colon pattern

    ; Reset the color back to default (optional)
    mov eax, lightCyan + (black * 16)  ; Change text color back to light cyan (or your default color)
    call SetTextColor

    pop esi
    pop edx
    add dl, 4                         ; Move the cursor right after the colon
    call Gotoxy                       ; Position the cursor after the colon

    pop ecx
    pop eax
    ret
DisplayColon ENDP

END main

