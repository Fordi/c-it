;┌─────────────────────────────────────────────────────────────────────────────┐
;│ Critical Error handler.                                                     │
;└─────────────────────────────────────────────────────────────────────────────┘

                        Jumps
                        .386

include switch.inc

;┌─────────────────────────────────────────────────────────────────────────────┐
;│ Externals                                                                   │
;└─────────────────────────────────────────────────────────────────────────────┘

;┌─────────────────────────────────────────────────────────────────────────────┐
;│ Globals                                                                     │
;└─────────────────────────────────────────────────────────────────────────────┘

                Global  Error_InitHandler:Far
                Global  Error_UnInitHandler:Far

;═══════════════════════════════════════════════════════════════════════════════

Segment                 Error BYTE Public 'Code' USE16
                        Assume CS:Error

CREATENEWLOGFILE        EQU     0
include debug.inc

;┌─────────────────────────────────────────────────────────────────────────────┐
;│ Variables                                                                   │
;└─────────────────────────────────────────────────────────────────────────────┘

OldHandlerOffset        DW      ?
OldHandlerSegment       DW      ?

ErrorMsgs               Label   Word
                        DW      Offset Error0
                        DW      Offset Error1
                        DW      Offset Error2
                        DW      Offset Error3
                        DW      Offset Error4
                        DW      Offset Error5
                        DW      Offset Error6
                        DW      Offset Error7
                        DW      Offset Error8
                        DW      Offset Error9
                        DW      Offset ErrorA
                        DW      Offset ErrorB
                        DW      Offset UnknownError
                        DW      Offset UnknownError
                        DW      Offset UnknownError
                        DW      Offset ErrorF

Error0          DB      "Write protect error", 0
Error1          DB      "Unknown unit error", 0
Error2          DB      "Drive not ready error", 0
Error3          DB      "Unknown command error", 0
Error4          DB      "Data integrity error", 0
Error5          DB      "Bad request structure length error", 0
Error6          DB      "Seek error", 0
Error7          DB      "Unknown media type error", 0
Error8          DB      "Sector not found error", 0
Error9          DB      "Printer error", 0
ErrorA          DB      "Read fault error", 0
ErrorB          DB      "General failure error", 0
ErrorF          DB      "Invalid disk change error", 0
UnknownError    DB      "Unknown critical error", 0

;┌─────────────────────────────────────────────────────────────────────────────┐
;│ Functions                                                                   │
;└─────────────────────────────────────────────────────────────────────────────┘

Proc            ErrorHandler Far

                PushA
                Push    DS
                Push    ES

                Push    CS
                Pop     DS
                        Assume DS:Error

                Mov     BX, DI
                And     BX, 0FFh
                Cmp     BX, 0Fh
                JBE     ErrorHandler1

                Mov     SI, Offset UnknownError
                Jmp     ErrorHandler2

ErrorHandler1:
                Add     BX, BX
                Mov     SI, [ErrorMsgs+BX]

ErrorHandler2:
                Mov     AH, 20h
                Mov     DI, 0B800h
                Mov     ES, DI
                Mov     DI, (2+49*80)*2

ErrorHandler3:
                LodsB
                And     AL, AL
                JZ      ErrorHandler4
                StosW

                Jmp     ErrorHandler3

ErrorHandler4:
                Pop     ES
                Pop     DS
                PopA

                Xor     AX, AX

                IRet

EndP            ErrorHandler
                Assume DS:Nothing

;───────────────────────────────────────────────────────────────────────────────

Proc            Error_InitHandler Far

                Push    ES

                Trace   " - Installing error handler"

                Xor     AX, AX
                Mov     ES, AX

                Mov     AX, CS
                ShL     EAX, 16
                Mov     AX, Offset ErrorHandler

                XChg    [ES:90h], EAX
                Mov     DWord Ptr CS:OldHandlerOffset, EAX

                Pop     ES
                Ret

EndP            Error_InitHandler

;───────────────────────────────────────────────────────────────────────────────

Proc            Error_UnInitHandler Far

                Push    ES
                Xor     AX, AX
                Mov     ES, AX

                Mov     EAX, DWord Ptr CS:OldHandlerOffset
                Mov     [ES:90h], EAX

                Pop     ES
                Ret

EndP            Error_UnInitHandler

;───────────────────────────────────────────────────────────────────────────────

;═══════════════════════════════════════════════════════════════════════════════

EndS

;═══════════════════════════════════════════════════════════════════════════════

End
