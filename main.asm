TITLE Assembly Vault: Cybersecurity Escape Room
; =========================================================================
; Course: EL-2003 Computer Organization and Assembly Language (COAL) Lab
; FAST-NUCES Karachi Campus - Department of Software Engineering
; Project: Assembly Vault: Cybersecurity Escape Room
; Architecture: 32-bit x86 (MASM)
; Library: Irvine32
; =========================================================================

INCLUDE Irvine32.inc

; =========================================================================
; CONSTANTS
; =========================================================================
MAX_LIVES          EQU 3
GAME_TIME_LIMIT    EQU 250     ; 250 seconds total for 5 puzzle levels
VAULT_TIME_LIMIT   EQU 30      ; 30 seconds for final vault
BUFFER_LEN         EQU 64

; Console Colors (Foreground + Background*16)
COLOR_NORMAL       EQU 10      ; Light Green on Black
COLOR_HEADER       EQU 11      ; Light Cyan on Black
COLOR_ALERT        EQU 12      ; Light Red on Black
COLOR_WARN         EQU 14      ; Yellow on Black
COLOR_SUCCESS      EQU 10      ; Light Green on Black
COLOR_DIM          EQU 7       ; Light Gray on Black

.data
; =========================================================================
; GAME STATE VARIABLES
; =========================================================================
playerScore        DWORD 0
playerLives        DWORD MAX_LIVES
currentLevel       DWORD 1
highScore          DWORD 0
gameStartTime      DWORD 0
vaultStartTime     DWORD 0
levelAttempts      DWORD 0
gameOver           DWORD 0
gameWon            DWORD 0
isTimeUp           DWORD 0
remainingSeconds   DWORD GAME_TIME_LIMIT

; Master Code & Fragment Storage
; Master Code is: "33564"
masterCode         BYTE "33564", 0
unlockedFragments  BYTE '[', '?', ' ', '?', ' ', '?', ' ', '?', ' ', '?', ']', 0
; Character offsets in unlockedFragments:
; index 1  -> Level 1 ('3')
; index 3  -> Level 2 ('3')
; index 5  -> Level 3 ('5')
; index 7  -> Level 4 ('6')
; index 9  -> Level 5 ('4')

; Input Buffers
inputBuffer        BYTE BUFFER_LEN DUP(0)

; =========================================================================
; LEVEL 1 DATA: Binary Stream Decoder
; =========================================================================
l1_title           BYTE " FIREWALL 1: BINARY STREAM DECODER", 0
l1_desc            BYTE " [CHALLENGE]: An encrypted binary stream has been intercepted.", 0dh, 0ah
                   BYTE "              Convert each 8-bit packet to its ASCII character to reveal", 0dh, 0ah
                   BYTE "              the 3-letter keyword.", 0dh, 0ah, 0
l1_binaryStr       BYTE "01001011   01000101   01011001", 0
l1_expected        BYTE "KEY", 0
l1_hintMsg         BYTE "[HINT -15 pts]: Binary to ASCII values:", 0dh, 0ah
                   BYTE "               01001011 = 4Bh = 75 = 'K'", 0dh, 0ah
                   BYTE "               01000101 = 45h = 69 = 'E'", 0dh, 0ah
                   BYTE "               01011001 = 59h = 89 = 'Y'", 0dh, 0ah
                   BYTE "               Access keyword is 'KEY' (length = 3).", 0

; =========================================================================
; LEVEL 2 DATA: Password Matrix (Arithmetic Clues)
; =========================================================================
l2_title           BYTE " FIREWALL 2: ARITHMETIC PASSWORD MATRIX", 0
l2_desc            BYTE " [CHALLENGE]: Compute the 4-digit system PIN using the arithmetic clues:", 0dh, 0ah
                   BYTE "              * Clue 1: Digit 1 is the smallest prime number.", 0dh, 0ah
                   BYTE "              * Clue 2: Digit 2 is Digit 1 + 1 (using ADD).", 0dh, 0ah
                   BYTE "              * Clue 3: Digit 3 is Digit 1 * Digit 2 (using MUL).", 0dh, 0ah
                   BYTE "              * Clue 4: Digit 4 is Digit 3 / Digit 1 (using DIV).", 0dh, 0ah, 0
l2_expected        BYTE "2363", 0
l2_hintMsg         BYTE "[HINT -15 pts]: Clue 1: Smallest prime is 2 -> Digit 1 = 2", 0dh, 0ah
                   BYTE "               Clue 2: 2 + 1 = 3           -> Digit 2 = 3", 0dh, 0ah
                   BYTE "               Clue 3: 2 * 3 = 6           -> Digit 3 = 6", 0dh, 0ah
                   BYTE "               Clue 4: 6 / 2 = 3           -> Digit 4 = 3", 0dh, 0ah
                   BYTE "               Correct 4-digit PIN is '2363'.", 0

; =========================================================================
; LEVEL 3 DATA: Hexadecimal Memory Dump
; =========================================================================
l3_title           BYTE " FIREWALL 3: HEXADECIMAL MEMORY DUMP", 0
l3_desc            BYTE " [CHALLENGE]: Captured memory payload contains raw hexadecimal bytes.", 0dh, 0ah
                   BYTE "              Convert each hex byte to its corresponding ASCII character.", 0dh, 0ah, 0
l3_hexStr          BYTE "56   41   55   4C   54", 0
l3_expected        BYTE "VAULT", 0
l3_hintMsg         BYTE "[HINT -15 pts]: Hex to ASCII character mappings:", 0dh, 0ah
                   BYTE "               56h = 86 = 'V', 41h = 65 = 'A', 55h = 85 = 'U',", 0dh, 0ah
                   BYTE "               4Ch = 76 = 'L', 54h = 84 = 'T'.", 0dh, 0ah
                   BYTE "               Access keyword is 'VAULT' (length = 5).", 0

; =========================================================================
; LEVEL 4 DATA: Bitwise Logic Engine (XOR & Rotations)
; =========================================================================
l4_title           BYTE " FIREWALL 4: BITWISE LOGIC ENGINE", 0
l4_desc            BYTE " [CHALLENGE]: Solve the bitwise security equation to bypass the logic gate:", 0dh, 0ah
                   BYTE "              KEY_A = 12  (Binary: 00001100b)", 0dh, 0ah
                   BYTE "              KEY_B = 10  (Binary: 00001010b)", 0dh, 0ah
                   BYTE "              Target: Compute KEY_A XOR KEY_B in decimal.", 0dh, 0ah, 0
l4_expected        BYTE "6", 0
l4_hintMsg         BYTE "[HINT -15 pts]: Binary XOR compares matching bit positions:", 0dh, 0ah
                   BYTE "                 00001100b  (12)", 0dh, 0ah
                   BYTE "             XOR 00001010b  (10)", 0dh, 0ah
                   BYTE "               -----------", 0dh, 0ah
                   BYTE "                 00000110b  = 6 in decimal. Enter '6'.", 0
l4_rotationDemo    BYTE " [CRYPTO DIFFUSION DEMO]: Demonstrating shift & rotate (Lab 09):", 0dh, 0ah
                   BYTE "  * Value 6 (00000110b) ROL 1 = 12 (00001100b) [Bit rotated left]", 0dh, 0ah
                   BYTE "  * Value 12 (00001100b) ROR 1 = 6 (00000110b) [Bit rotated right]", 0dh, 0ah, 0

; =========================================================================
; LEVEL 5 DATA: Digital Evidence Array Search
; =========================================================================
l5_title           BYTE " FIREWALL 5: DIGITAL EVIDENCE ARRAY SEARCH", 0
l5_desc            BYTE " [CHALLENGE]: Inspect the forensic memory array below and enter the", 0dh, 0ah
                   BYTE "              0-based index of target evidence value 13.", 0dh, 0ah, 0
evidenceArray      DWORD 17, 4, 29, 8, 13, 22, 5, 31
ARRAY_LEN          EQU ($ - evidenceArray) / 4
l5_expected        BYTE "4", 0
l5_hintMsg         BYTE "[HINT -15 pts]: Zero-based indices of evidence array:", 0dh, 0ah
                   BYTE "               arr[0]=17, arr[1]=4, arr[2]=29, arr[3]=8, arr[4]=13.", 0dh, 0ah
                   BYTE "               The value 13 is located at index 4. Enter '4'.", 0

; =========================================================================
; FINAL VAULT DATA
; =========================================================================
vault_title        BYTE " FINAL GATEWAY: EMERGENCY VAULT OVERRIDE", 0
vault_desc         BYTE " [ALERT]: EMERGENCY CONTAINMENT LOCKDOWN IN PROGRESS!", 0dh, 0ah
                   BYTE "          You have 30 SECONDS to enter the 5-digit Master Override Code.", 0dh, 0ah
                   BYTE "          Synthesize the 5 code fragments collected from Levels 1 to 5.", 0dh, 0ah, 0

; =======================================================================================================
; UI STRINGS & FORMATTING
; =======================================================================================================
borderLine         BYTE "==========================================================================================================", 0
subBorderLine      BYTE "--------------------------------------------------------------------------------", 0




menuBanner1        BYTE "    ___    ____    ____    ____  __   __    ____   _    _    _       _    __     _     _     _  _   ______   ", 0dh, 0ah
                   BYTE "   / _ \  / ___/  / ___/  ||     | \ /  |  | __ )  ||   \\  //      | |  |  |  // \\  | |   | | ||    ||     ", 0dh, 0ah
                   BYTE "  / /_\ \ \____   \___    ||___  | |\/| |  |  _ \  ||    \\//  ===  | |  |  | // _ \\ | |   | | ||    ||     ", 0dh, 0ah
                   BYTE " / /__ \ \ ____)  ____) | ||     | |  | |  |_) | | ||     ||         \ \ / /  ||   || | |   | | ||    ||     ", 0dh, 0ah
                   BYTE "/_/     \_\\____/ \____/  ||___  |_|  |_|  |____/  ||___  ||          \___/   ||   ||  \_\_/_/  ||___ ||     ", 0dh, 0ah
                   BYTE "            --- CYBERSECURITY ESCAPE ROOM | x86 MASM ---                         ", 0

menuOptions        BYTE " [1] Start New Mission", 0dh, 0ah
                   BYTE " [2] Training Manual / Mission Briefing", 0dh, 0ah
                   BYTE " [3] Security Agent High Score", 0dh, 0ah
                   BYTE " [4] Exit Vault Terminal", 0dh, 0ah, 0dh, 0ah
                   BYTE " Enter your selection (1-4): ", 0

instrTitle         BYTE "                    --- MISSION BRIEFING & PROTOCOLS ---", 0dh, 0ah, 0
instrBody          BYTE " You are a cybersecurity trainee trapped inside an encrypted digital vault.", 0dh, 0ah
                   BYTE " To trigger emergency extraction, you must unlock 5 sequential firewalls and", 0dh, 0ah
                   BYTE " retrieve the 5-digit Master Override Code (33564) before security lockdown.", 0dh, 0ah, 0dh, 0ah
                   BYTE " RULES & MECHANICS:", 0dh, 0ah
                   BYTE " - Total Mission Time: 155 seconds for Levels 1 through 5.", 0dh, 0ah
                   BYTE " - Final Vault Lockdown: Exactly 15 seconds to enter the master code.", 0dh, 0ah
                   BYTE " - Security Shields: You start with 3 lives. Each wrong answer loses 1 life.", 0dh, 0ah
                   BYTE " - Scoring Breakdown:", 0dh, 0ah
                   BYTE "     * +100 points for solving each level (5 x 100 = 500 max).", 0dh, 0ah
                   BYTE "     * +25  bonus points for solving a puzzle on the FIRST attempt.", 0dh, 0ah
                   BYTE "     * -15  penalty for requesting a hint (type 'H' or 'h').", 0dh, 0ah
                   BYTE "     * -10  penalty for each incorrect submission.", 0dh, 0ah
                   BYTE "     * +100 points for unlocking the Final Vault.", 0dh, 0ah
                   BYTE "     * +50  flawless bonus for escaping with all 3 shields intact.", 0dh, 0ah
                   BYTE "     * Maximum Possible Score: 775 points.", 0dh, 0ah, 0dh, 0ah
                   BYTE " Press any key to return to Main Menu...", 0

highScoreTitle     BYTE "                     --- AGENT HIGH SCORE TERMINAL ---", 0dh, 0ah, 0
highScoreMsg       BYTE " Current Session High Score: ", 0
pressKeyMsg        BYTE 0dh, 0ah, " Press any key to continue...", 0

statusLevelStr     BYTE " LEVEL: 0", 0
statusOf5Str       BYTE " / 05  |  ", 0
statusLivesStr     BYTE " SHIELDS: ", 0
statusScoreStr     BYTE "  |  SCORE: ", 0
statusTimeStr      BYTE "  |  TIME REMAINING: ", 0
secondsStr         BYTE "s", 0

promptInput        BYTE " Terminal Input [Type answer or 'H' for hint]: ", 0
promptEmptyErr     BYTE " [!] Blank input ignored. Please provide an answer or 'H' for hint.", 0dh, 0ah, 0
promptWrongAns     BYTE " [X] ACCESS DENIED! Invalid answer. Shield lost (-1 life, -10 pts).", 0dh, 0ah, 0
promptCorrectAns   BYTE " [v] ACCESS GRANTED! Security barrier bypassed.", 0dh, 0ah, 0
promptFirstBonus   BYTE " [+] FIRST ATTEMPT BONUS AWARDED (+25 pts)!", 0dh, 0ah, 0
promptFragment     BYTE " [*] MASTER CODE FRAGMENT UNLOCKED: Digit #", 0
promptFragmentVal  BYTE " = ", 0
promptFragmentsHUD BYTE " Current Fragments: ", 0

gameOverTitle      BYTE "                     --- MISSION FAILED: LOCKDOWN ---", 0dh, 0ah, 0
timeOutReason      BYTE " [CRITICAL] TIME EXPIRED! The vault automated defenses locked permanently.", 0dh, 0ah, 0
livesOutReason     BYTE " [CRITICAL] ALL SHIELDS DEPLETED! Security drones neutralized your terminal.", 0dh, 0ah, 0

victoryTitle       BYTE "             --- MISSION ACCOMPLISHED: VAULT OVERRIDDEN ---", 0dh, 0ah, 0
victoryMsg         BYTE " Congratulations, Agent! The vault doors have opened. Extraction is complete.", 0dh, 0ah, 0
flawlessBonusMsg   BYTE " [+] FLAWLESS OPERATIVE BONUS AWARDED: All 3 shields preserved (+50 pts)!", 0dh, 0ah, 0
finalScoreMsg      BYTE " Final Score Achieved: ", 0
finalRankMsg       BYTE " Operative Security Rank: ", 0
rankElite          BYTE "Elite Cyber Agent (Top Tier Operative)", 0
rankSpecialist     BYTE "Security Specialist (Advanced Field Agent)", 0
rankTechnician     BYTE "Vault Technician (Qualified Operator)", 0
rankTrainee        BYTE "Trainee (Requires Additional Field Training)", 0
newHighScoreMsg    BYTE " [!] NEW HIGH SCORE RECORDED FOR THIS SESSION!", 0dh, 0ah, 0

playAgainPrompt    BYTE 0dh, 0ah, " Would you like to attempt another mission? (Y/N): ", 0
exitMsg            BYTE 0dh, 0ah, " Shutting down Assembly Vault terminal. Stay vigilant, Agent.", 0dh, 0ah, 0

AddFlawlessBonus PROTO C, score:DWORD

.code

; =========================================================================
; PROCEDURE: main
; Entry point of program. Initializes console and drives the menu loop.
; =========================================================================
main PROC
    ; Set standard Light Green on Black cyber color
    mov eax, COLOR_NORMAL
    call SetTextColor
    call Randomize

MasterMenuLoop:
    call ShowMenu               ; Display menu and get choice in AL ('1'-'4')
    cmp al, '1'
    je StartGame
    cmp al, '2'
    je DisplayInstructions
    cmp al, '3'
    je DisplayHighScore
    cmp al, '4'
    je QuitProgram
    jmp MasterMenuLoop

StartGame:
    call PlayGame
    jmp MasterMenuLoop

DisplayInstructions:
    call ShowInstructions
    jmp MasterMenuLoop

DisplayHighScore:
    call ShowHighScore
    jmp MasterMenuLoop

QuitProgram:
    call Clrscr
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET exitMsg
    call WriteString
    mov eax, COLOR_NORMAL
    call SetTextColor
    exit
main ENDP


; =========================================================================
; PROCEDURE: ShowMenu
; Clears screen, displays cyber banner, high score, and options.
; Returns: AL = user choice character ('1', '2', '3', or '4')
; =========================================================================
ShowMenu PROC
    call Clrscr
    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET menuBanner1
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    call Crlf
    mov edx, OFFSET menuOptions
    call WriteString

GetMenuChar:
    call ReadChar
    call WriteChar              ; Echo character
    call Crlf
    cmp al, '1'
    jb InvalidMenuChoice
    cmp al, '4'
    ja InvalidMenuChoice
    ret

InvalidMenuChoice:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptWrongAns
    call WriteString
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET menuOptions
    call WriteString
    jmp GetMenuChar
ShowMenu ENDP


; =========================================================================
; PROCEDURE: ShowInstructions
; Displays the mission manual and scoring rules.
; =========================================================================
ShowInstructions PROC
    call Clrscr
    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET instrTitle
    call WriteString
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET instrBody
    call WriteString

    call ReadChar               ; Wait for any key
    ret
ShowInstructions ENDP


; =========================================================================
; PROCEDURE: ShowHighScore
; Displays the highest score achieved during this program execution.
; =========================================================================
ShowHighScore PROC
    call Clrscr
    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET highScoreTitle
    call WriteString
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    mov eax, COLOR_SUCCESS
    call SetTextColor
    call Crlf
    mov edx, OFFSET highScoreMsg
    call WriteString
    mov eax, highScore
    call WriteDec
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    ret
ShowHighScore ENDP


; =========================================================================
; PROCEDURE: InitializeGame
; Resets player score, shields/lives, level, timer, and master code fragments.
; =========================================================================
InitializeGame PROC
    mov playerScore, 0
    mov playerLives, MAX_LIVES
    mov currentLevel, 1
    mov gameOver, 0
    mov gameWon, 0
    mov isTimeUp, 0
    mov remainingSeconds, GAME_TIME_LIMIT

    ; Reset unlocked fragments string: "[? ? ? ? ?]"
    mov unlockedFragments[1], '?'
    mov unlockedFragments[3], '?'
    mov unlockedFragments[5], '?'
    mov unlockedFragments[7], '?'
    mov unlockedFragments[9], '?'

    ; Record initial game timestamp
    call GetMseconds
    mov gameStartTime, eax
    ret
InitializeGame ENDP


; =========================================================================
; PROCEDURE: ShowStatus
; Displays the HUD bar with Level, Shields, Current Score, and Time Left.
; Preserves registers.
; =========================================================================
ShowStatus PROC
    push eax
    push edx
    push ecx

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    ; Display Level Number
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET statusLevelStr
    call WriteString
    mov eax, currentLevel
    call WriteDec
    mov edx, OFFSET statusOf5Str
    call WriteString

    ; Display Shields / Lives
    mov edx, OFFSET statusLivesStr
    call WriteString
    mov ecx, playerLives
    cmp ecx, 0
    jle NoShieldsPrint
PrintShields:
    mov al, '*'
    call WriteChar
    mov al, ' '
    call WriteChar
    loop PrintShields
NoShieldsPrint:

    ; Display Score
    mov edx, OFFSET statusScoreStr
    call WriteString
    mov eax, playerScore
    call WriteDec

    ; Display Time Left
    mov edx, OFFSET statusTimeStr
    call WriteString
    mov eax, remainingSeconds
    call WriteDec
    mov edx, OFFSET secondsStr
    call WriteString
    call Crlf

    ; Display Unlocked Fragments
    mov edx, OFFSET promptFragmentsHUD
    call WriteString
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET unlockedFragments
    call WriteString
    call Crlf

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor

    pop ecx
    pop edx
    pop eax
    ret
ShowStatus ENDP


; =========================================================================
; PROCEDURE: CheckTimer
; Calculates elapsed seconds since gameStartTime.
; Updates remainingSeconds. If elapsed >= GAME_TIME_LIMIT, marks gameOver = 1.
; =========================================================================
CheckTimer PROC
    push eax
    push ebx
    push edx

    call GetMseconds
    sub eax, gameStartTime      ; EAX = elapsed milliseconds
    mov edx, 0
    mov ebx, 1000
    div ebx                     ; EAX = elapsed seconds

    cmp eax, GAME_TIME_LIMIT
    jae TimeExpired

    mov ebx, GAME_TIME_LIMIT
    sub ebx, eax
    mov remainingSeconds, ebx
    jmp TimerCheckDone

TimeExpired:
    mov remainingSeconds, 0
    mov isTimeUp, 1
    mov gameOver, 1

TimerCheckDone:
    pop edx
    pop ebx
    pop eax
    ret
CheckTimer ENDP


; =========================================================================
; PROCEDURE: LoseLife
; Decrements playerLives, deducts 10 pts from playerScore, checks Game Over.
; =========================================================================
LoseLife PROC
    push eax
    push edx

    dec playerLives

    ; Deduct 10 points without going below 0
    cmp playerScore, 10
    jb ClearScoreZero
    sub playerScore, 10
    jmp ShowLoseLifeMsg

ClearScoreZero:
    mov playerScore, 0

ShowLoseLifeMsg:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptWrongAns
    call WriteString
    call Crlf
    mov eax, COLOR_NORMAL
    call SetTextColor

    ; Check if shields reached 0
    cmp playerLives, 0
    jle TriggerShieldFailure
    jmp LoseLifeExit

TriggerShieldFailure:
    mov gameOver, 1

LoseLifeExit:
    pop edx
    pop eax
    ret
LoseLife ENDP


; =========================================================================
; PROCEDURE: ApplyHintPenalty
; Deducts 15 points from playerScore (clamped to 0).
; =========================================================================
ApplyHintPenalty PROC
    push eax
    cmp playerScore, 15
    jb ClampHintScore
    sub playerScore, 15
    jmp HintPenaltyDone
ClampHintScore:
    mov playerScore, 0
HintPenaltyDone:
    pop eax
    ret
ApplyHintPenalty ENDP


; =========================================================================
; PROCEDURE: StrToUpper
; Converts a null-terminated string at EDX to uppercase in-place.
; =========================================================================
StrToUpper PROC
    push esi
    push eax
    mov esi, edx
UpperLoop:
    mov al, [esi]
    cmp al, 0
    je UpperDone
    cmp al, 'a'
    jb UpperNext
    cmp al, 'z'
    ja UpperNext
    sub al, 32                  ; Convert lowercase ASCII to uppercase
    mov [esi], al
UpperNext:
    inc esi
    jmp UpperLoop
UpperDone:
    pop eax
    pop esi
    ret
StrToUpper ENDP


; =========================================================================
; PROCEDURE: StrCompareEqual
; Compares null-terminated strings at ESI and EDI.
; Returns: EAX = 1 if equal, EAX = 0 if not equal.
; =========================================================================
StrCompareEqual PROC
    push esi
    push edi
    push ebx
CmpLoop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne CmpMismatch
    cmp al, 0
    je CmpBothEnd
    inc esi
    inc edi
    jmp CmpLoop
CmpBothEnd:
    mov eax, 1                  ; Match!
    jmp CmpExit
CmpMismatch:
    mov eax, 0                  ; Mismatch!
CmpExit:
    pop ebx
    pop edi
    pop esi
    ret
StrCompareEqual ENDP


; =========================================================================
; PROCEDURE: Level1Binary
; Level 1: Binary Stream Decoder
; Displays 01001011 01000101 01011001 -> Expected: "KEY"
; Code Fragment Unlocked: '3' (length of "KEY")
; =========================================================================
Level1Binary PROC
    mov currentLevel, 1
    mov levelAttempts, 0

L1_PromptLoop:
    call CheckTimer
    cmp gameOver, 1
    je L1_Exit

    call Clrscr
    call ShowStatus

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l1_title
    call WriteString
    call Crlf
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET l1_desc
    call WriteString
    call Crlf

    ; Print binary packets
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    mov edx, OFFSET l1_binaryStr
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    ; Prompt user
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je L1_Empty

    ; Convert to uppercase
    mov edx, OFFSET inputBuffer
    call StrToUpper

    ; Check if user asked for hint ('H')
    mov al, inputBuffer[0]
    cmp al, 'H'
    jne L1_CheckAnswer
    cmp inputBuffer[1], 0
    jne L1_CheckAnswer

    ; User asked for hint
    call ApplyHintPenalty
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET l1_hintMsg
    call WriteString
    call Crlf
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L1_PromptLoop

L1_CheckAnswer:
    inc levelAttempts

    ; Compare with "KEY"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET l1_expected
    call StrCompareEqual
    cmp eax, 1
    je L1_Success

    ; Wrong answer
    call LoseLife
    cmp gameOver, 1
    je L1_Exit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L1_PromptLoop

L1_Empty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L1_PromptLoop

L1_Success:
    ; Base +100 points
    add playerScore, 100

    ; Check first-attempt bonus
    cmp levelAttempts, 1
    jne L1_StoreFragment
    add playerScore, 25
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFirstBonus
    call WriteString
    call Crlf

L1_StoreFragment:
    ; Unlock Fragment #1: '3'
    mov unlockedFragments[1], '3'

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptCorrectAns
    call WriteString
    call Crlf
    mov edx, OFFSET promptFragment
    call WriteString
    mov al, '1'
    call WriteChar
    mov edx, OFFSET promptFragmentVal
    call WriteString
    mov al, '3'
    call WriteChar
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar

L1_Exit:
    ret
Level1Binary ENDP


; =========================================================================
; PROCEDURE: Level2Password
; Level 2: Arithmetic Password Matrix
; Clues: D1=2, D2=2+1=3, D3=2*3=6, D4=6/2=3 -> Expected: "2363"
; Code Fragment Unlocked: '3' (Security verification digit)
; =========================================================================
Level2Password PROC
    mov currentLevel, 2
    mov levelAttempts, 0

L2_PromptLoop:
    call CheckTimer
    cmp gameOver, 1
    je L2_Exit

    call Clrscr
    call ShowStatus

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l2_title
    call WriteString
    call Crlf
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    ; Display Arithmetic Clues
    mov edx, OFFSET l2_desc
    call WriteString
    call Crlf

    ; Prompt user
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je L2_Empty

    ; Convert to uppercase
    mov edx, OFFSET inputBuffer
    call StrToUpper

    ; Check if user asked for hint ('H')
    mov al, inputBuffer[0]
    cmp al, 'H'
    jne L2_CheckAnswer
    cmp inputBuffer[1], 0
    jne L2_CheckAnswer

    ; User asked for hint
    call ApplyHintPenalty
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET l2_hintMsg
    call WriteString
    call Crlf
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L2_PromptLoop

L2_CheckAnswer:
    inc levelAttempts

    ; Compare with "2363"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET l2_expected
    call StrCompareEqual
    cmp eax, 1
    je L2_Success

    ; Wrong answer
    call LoseLife
    cmp gameOver, 1
    je L2_Exit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L2_PromptLoop

L2_Empty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L2_PromptLoop

L2_Success:
    ; Base +100 points
    add playerScore, 100

    ; Check first-attempt bonus
    cmp levelAttempts, 1
    jne L2_StoreFragment
    add playerScore, 25
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFirstBonus
    call WriteString
    call Crlf

L2_StoreFragment:
    ; Unlock Fragment #2: '3'
    mov unlockedFragments[3], '3'

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptCorrectAns
    call WriteString
    call Crlf
    mov edx, OFFSET promptFragment
    call WriteString
    mov al, '2'
    call WriteChar
    mov edx, OFFSET promptFragmentVal
    call WriteString
    mov al, '3'
    call WriteChar
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar

L2_Exit:
    ret
Level2Password ENDP


; =========================================================================
; PROCEDURE: Level3Hex
; Level 3: Hexadecimal Memory Dump
; Displays 56 41 55 4C 54 -> Expected: "VAULT"
; Code Fragment Unlocked: '5' (length of "VAULT")
; =========================================================================
Level3Hex PROC
    mov currentLevel, 3
    mov levelAttempts, 0

L3_PromptLoop:
    call CheckTimer
    cmp gameOver, 1
    je L3_Exit

    call Clrscr
    call ShowStatus

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l3_title
    call WriteString
    call Crlf
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET l3_desc
    call WriteString
    call Crlf

    ; Print hex payload
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    mov edx, OFFSET l3_hexStr
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    ; Prompt user
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je L3_Empty

    ; Convert to uppercase
    mov edx, OFFSET inputBuffer
    call StrToUpper

    ; Check if user asked for hint ('H')
    mov al, inputBuffer[0]
    cmp al, 'H'
    jne L3_CheckAnswer
    cmp inputBuffer[1], 0
    jne L3_CheckAnswer

    ; User asked for hint
    call ApplyHintPenalty
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET l3_hintMsg
    call WriteString
    call Crlf
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L3_PromptLoop

L3_CheckAnswer:
    inc levelAttempts

    ; Compare with "VAULT"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET l3_expected
    call StrCompareEqual
    cmp eax, 1
    je L3_Success

    ; Wrong answer
    call LoseLife
    cmp gameOver, 1
    je L3_Exit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L3_PromptLoop

L3_Empty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L3_PromptLoop

L3_Success:
    ; Base +100 points
    add playerScore, 100

    ; Check first-attempt bonus
    cmp levelAttempts, 1
    jne L3_StoreFragment
    add playerScore, 25
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFirstBonus
    call WriteString
    call Crlf

L3_StoreFragment:
    ; Unlock Fragment #3: '5'
    mov unlockedFragments[5], '5'

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptCorrectAns
    call WriteString
    call Crlf
    mov edx, OFFSET promptFragment
    call WriteString
    mov al, '3'
    call WriteChar
    mov edx, OFFSET promptFragmentVal
    call WriteString
    mov al, '5'
    call WriteChar
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar

L3_Exit:
    ret
Level3Hex ENDP


; =========================================================================
; PROCEDURE: Level4Logic
; Level 4: Bitwise Logic Engine (12 XOR 10 = 6)
; Includes active demonstration of ROL/ROR instructions
; Code Fragment Unlocked: '6' (answer value itself)
; =========================================================================
Level4Logic PROC
    mov currentLevel, 4
    mov levelAttempts, 0

L4_PromptLoop:
    call CheckTimer
    cmp gameOver, 1
    je L4_Exit

    call Clrscr
    call ShowStatus

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l4_title
    call WriteString
    call Crlf
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET l4_desc
    call WriteString
    call Crlf

    ; Prompt user
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je L4_Empty

    ; Convert to uppercase
    mov edx, OFFSET inputBuffer
    call StrToUpper

    ; Check if user asked for hint ('H')
    mov al, inputBuffer[0]
    cmp al, 'H'
    jne L4_CheckAnswer
    cmp inputBuffer[1], 0
    jne L4_CheckAnswer

    ; User asked for hint
    call ApplyHintPenalty
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET l4_hintMsg
    call WriteString
    call Crlf
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L4_PromptLoop

L4_CheckAnswer:
    inc levelAttempts

    ; Compare with "6"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET l4_expected
    call StrCompareEqual
    cmp eax, 1
    je L4_Success

    ; Wrong answer
    call LoseLife
    cmp gameOver, 1
    je L4_Exit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L4_PromptLoop

L4_Empty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L4_PromptLoop

L4_Success:
    ; Base +100 points
    add playerScore, 100

    ; Check first-attempt bonus
    cmp levelAttempts, 1
    jne L4_StoreFragment
    add playerScore, 25
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFirstBonus
    call WriteString
    call Crlf

L4_StoreFragment:
    ; Unlock Fragment #4: '6'
    mov unlockedFragments[7], '6'

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptCorrectAns
    call WriteString
    call Crlf

    ; Active bit rotation demonstration (Lab 09)
    mov al, 6
    rol al, 1                   ; 6 rotated left becomes 12!
    ror al, 1                   ; 12 rotated right restores 6!
    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l4_rotationDemo
    call WriteString

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFragment
    call WriteString
    mov al, '4'
    call WriteChar
    mov edx, OFFSET promptFragmentVal
    call WriteString
    mov al, '6'
    call WriteChar
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar

L4_Exit:
    ret
Level4Logic ENDP


; =========================================================================
; PROCEDURE: Level5Evidence
; Level 5: Digital Evidence Array Search
; Array: [17, 4, 29, 8, 13, 22, 5, 31]
; Player must identify 0-based index of 13 -> Expected: "4"
; Demonstrates ESI indirect addressing and LOOP instruction
; Code Fragment Unlocked: '4' (index value itself)
; =========================================================================
Level5Evidence PROC
    mov currentLevel, 5
    mov levelAttempts, 0

L5_PromptLoop:
    call CheckTimer
    cmp gameOver, 1
    je L5_Exit

    call Clrscr
    call ShowStatus

    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET l5_title
    call WriteString
    call Crlf
    mov edx, OFFSET subBorderLine
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET l5_desc
    call WriteString
    call Crlf

    ; Display Array Elements using LOOP and indirect addressing [ESI]
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar

    mov esi, OFFSET evidenceArray
    mov ecx, ARRAY_LEN
PrintEvidenceLoop:
    mov eax, [esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    add esi, TYPE evidenceArray
    loop PrintEvidenceLoop

    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    ; Prompt user
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je L5_Empty

    ; Convert to uppercase
    mov edx, OFFSET inputBuffer
    call StrToUpper

    ; Check if user asked for hint ('H')
    mov al, inputBuffer[0]
    cmp al, 'H'
    jne L5_CheckAnswer
    cmp inputBuffer[1], 0
    jne L5_CheckAnswer

    ; User asked for hint
    call ApplyHintPenalty
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET l5_hintMsg
    call WriteString
    call Crlf
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L5_PromptLoop

L5_CheckAnswer:
    inc levelAttempts

    ; Compare with "4"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET l5_expected
    call StrCompareEqual
    cmp eax, 1
    je L5_Success

    ; Wrong answer
    call LoseLife
    cmp gameOver, 1
    je L5_Exit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L5_PromptLoop

L5_Empty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp L5_PromptLoop

L5_Success:
    ; Base +100 points
    add playerScore, 100

    ; Check first-attempt bonus
    cmp levelAttempts, 1
    jne L5_StoreFragment
    add playerScore, 25
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptFirstBonus
    call WriteString
    call Crlf

L5_StoreFragment:
    ; Unlock Fragment #5: '4'
    mov unlockedFragments[9], '4'

    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET promptCorrectAns
    call WriteString
    call Crlf
    mov edx, OFFSET promptFragment
    call WriteString
    mov al, '5'
    call WriteChar
    mov edx, OFFSET promptFragmentVal
    call WriteString
    mov al, '4'
    call WriteChar
    call Crlf

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar

L5_Exit:
    ret
Level5Evidence ENDP


; =========================================================================
; PROCEDURE: FinalVault
; Final Gateway: Emergency Master Override
; Player enters the 5-digit code "33564" within 15 seconds.
; =========================================================================
FinalVault PROC
    ; Initialize 15-second vault timer
    call GetMseconds
    mov vaultStartTime, eax

VaultPromptLoop:
    ; Calculate elapsed seconds for Final Vault
    call GetMseconds
    sub eax, vaultStartTime
    mov edx, 0
    mov ebx, 1000
    div ebx                     ; EAX = elapsed seconds
    cmp eax, VAULT_TIME_LIMIT
    jae VaultTimeout

    mov ebx, VAULT_TIME_LIMIT
    sub ebx, eax                ; EBX = remaining vault seconds

    call Clrscr

    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET vault_title
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET vault_desc
    call WriteString
    call Crlf

    mov edx, OFFSET promptFragmentsHUD
    call WriteString
    mov edx, OFFSET unlockedFragments
    call WriteString
    call Crlf

    mov edx, OFFSET statusTimeStr
    call WriteString
    mov eax, ebx
    call WriteDec
    mov edx, OFFSET secondsStr
    call WriteString
    call Crlf

    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET promptInput
    call WriteString

    ; Read user string
    mov edx, OFFSET inputBuffer
    mov ecx, BUFFER_LEN
    call ReadString

    ; Check if empty
    cmp eax, 0
    je VaultEmpty

    ; Check if player took too long while typing
    call GetMseconds
    sub eax, vaultStartTime
    mov edx, 0
    mov ebx, 1000
    div ebx
    cmp eax, VAULT_TIME_LIMIT
    jae VaultTimeout

    ; Compare with "33564"
    mov esi, OFFSET inputBuffer
    mov edi, OFFSET masterCode
    call StrCompareEqual
    cmp eax, 1
    je VaultSuccess

    ; Wrong master code
    call LoseLife
    cmp gameOver, 1
    je VaultExit

    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp VaultPromptLoop

VaultEmpty:
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET promptEmptyErr
    call WriteString
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET pressKeyMsg
    call WriteString
    call ReadChar
    jmp VaultPromptLoop

VaultTimeout:
    mov isTimeUp, 1
    mov gameOver, 1
    jmp VaultExit

VaultSuccess:
    ; +100 points for opening vault
    add playerScore, 100
    mov gameWon, 1

VaultExit:
    ret
FinalVault ENDP


; =========================================================================
; PROCEDURE: ShowResult
; Evaluates victory or failure, applies flawless bonus (+50 if 3 lives left),
; updates high score, and determines military security rank.
; =========================================================================
ShowResult PROC
    call Clrscr

    cmp gameWon, 1
    je VictoryBranch

    ; Game Over / Mission Failed
    mov eax, COLOR_ALERT
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET gameOverTitle
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    cmp isTimeUp, 1
    je TimeExpiredFail
    mov edx, OFFSET livesOutReason
    call WriteString
    jmp PrintFinalScoreSection

TimeExpiredFail:
    mov edx, OFFSET timeOutReason
    call WriteString
    jmp PrintFinalScoreSection

VictoryBranch:
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf
    mov edx, OFFSET victoryTitle
    call WriteString
    call Crlf
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    mov edx, OFFSET victoryMsg
    call WriteString
    call Crlf

    ; Check for Flawless Run Bonus (+50 if playerLives == MAX_LIVES)
    cmp playerLives, MAX_LIVES
    jne PrintFinalScoreSection

    INVOKE AddFlawlessBonus, playerScore     ;inline assembly //cpp call
    mov playerScore, eax

    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET flawlessBonusMsg
    call WriteString
    call Crlf

PrintFinalScoreSection:
    call Crlf
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET finalScoreMsg
    call WriteString
    mov eax, playerScore
    call WriteDec
    call Crlf

    ; Update Session High Score
    mov eax, playerScore
    cmp eax, highScore
    jbe RankCalculation
    mov highScore, eax
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET newHighScoreMsg
    call WriteString
    call Crlf
    mov eax, COLOR_NORMAL
    call SetTextColor

RankCalculation:
    mov edx, OFFSET finalRankMsg
    call WriteString

    ; Ranks:
    ; 700 - 775: Elite Cyber Agent
    ; 550 - 699: Security Specialist
    ; 350 - 549: Vault Technician
    ; Below 350: Trainee
    mov eax, playerScore
    cmp eax, 700
    jae IsEliteAgent
    cmp eax, 550
    jae IsSpecialist
    cmp eax, 350
    jae IsTechnician
    jmp IsTrainee

IsEliteAgent:
    mov eax, COLOR_HEADER
    call SetTextColor
    mov edx, OFFSET rankElite
    call WriteString
    jmp DoneRank

IsSpecialist:
    mov eax, COLOR_SUCCESS
    call SetTextColor
    mov edx, OFFSET rankSpecialist
    call WriteString
    jmp DoneRank

IsTechnician:
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET rankTechnician
    call WriteString
    jmp DoneRank

IsTrainee:
    mov eax, COLOR_DIM
    call SetTextColor
    mov edx, OFFSET rankTrainee
    call WriteString

DoneRank:
    call Crlf
    mov eax, COLOR_NORMAL
    call SetTextColor
    mov edx, OFFSET borderLine
    call WriteString
    call Crlf

    ; Ask player if they want to play again
    call PlayAgain
    ret
ShowResult ENDP


; =========================================================================
; PROCEDURE: PlayAgain
; Asks the user if they wish to return to the menu or quit.
; =========================================================================
PlayAgain PROC
    mov edx, OFFSET playAgainPrompt
    call WriteString

ReadPlayChar:
    call ReadChar
    call WriteChar
    call Crlf
    cmp al, 'Y'
    je ReturnToMenu
    cmp al, 'y'
    je ReturnToMenu
    cmp al, 'N'
    je TerminateGame
    cmp al, 'n'
    je TerminateGame
    jmp ReadPlayChar

ReturnToMenu:
    ret

TerminateGame:
    call Clrscr
    mov eax, COLOR_WARN
    call SetTextColor
    mov edx, OFFSET exitMsg
    call WriteString
    mov eax, COLOR_NORMAL
    call SetTextColor
    exit
PlayAgain ENDP


; =========================================================================
; PROCEDURE: PlayGame
; Main sequential mission controller.
; =========================================================================
PlayGame PROC
    call InitializeGame

    ; Run Level 1
    call Level1Binary
    cmp gameOver, 1
    je EndGameSequence

    ; Run Level 2
    call Level2Password
    cmp gameOver, 1
    je EndGameSequence

    ; Run Level 3
    call Level3Hex
    cmp gameOver, 1
    je EndGameSequence

    ; Run Level 4
    call Level4Logic
    cmp gameOver, 1
    je EndGameSequence

    ; Run Level 5
    call Level5Evidence
    cmp gameOver, 1
    je EndGameSequence

    ; Run Final Vault
    call FinalVault

EndGameSequence:
    call ShowResult
    ret
PlayGame ENDP

END main