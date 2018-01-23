
NVIC_INT_CTRL   EQU     0xE000ED04                              ; Interrupt control state register.
NVIC_SYSPRI14   EQU     0xE000ED22                              ; System priority register (priority 14).
NVIC_PENDSV_PRI EQU           0xFF                              ; PendSV priority value (lowest).
NVIC_PENDSVSET  EQU     0x10000000                              ; Value to trigger PendSV exception.

;********************************************************************************************************
;                                     CODE GENERATION DIRECTIVES
;********************************************************************************************************

    PRESERVE8
    THUMB

    AREA CODE, CODE, READONLY

 
  IMPORT  OS_CPU_ExceptStkBase
  
  IMPORT  OS_Tcb_CurP
  IMPORT  OS_Tcb_HighRdyP
  IMPORT  Prio_Cur
  IMPORT  Prio_HighRdy
  
  EXPORT OSStart_Asm
  EXPORT PendSV_Handler
  EXPORT OSCtxSw
  EXPORT OS_CPU_SR_Save
  EXPORT OS_CPU_SR_Restore
  
OS_CPU_SR_Save
    MRS     R0, PRIMASK                                         ; Set prio int mask to mask all (except faults)
    CPSID   I
    BX      LR

OS_CPU_SR_Restore
    MSR     PRIMASK, R0
    BX      LR
    
OSCtxSw
    LDR     R0, =NVIC_INT_CTRL
    LDR     R1, =NVIC_PENDSVSET
    STR     R1, [R0]
    BX      LR                                                ; Enable interrupts at processor level

OSStart_Asm
    LDR     R0, =NVIC_SYSPRI14                                  ; Set the PendSV exception priority
    LDR     R1, =NVIC_PENDSV_PRI
    STRB    R1, [R0]

    MOVS    R0, #0                                              ; Set the PSP to 0 for initial context switch call
    MSR     PSP, R0

    LDR     R0, =OS_CPU_ExceptStkBase                           ; Initialize the MSP to the OS_CPU_ExceptStkBase
    LDR     R1, [R0]
    MSR     MSP, R1    

    LDR     R0, =NVIC_INT_CTRL                                  ; Trigger the PendSV exception (causes context switch)
    LDR     R1, =NVIC_PENDSVSET
    STR     R1, [R0]

    CPSIE   I                                                   ; Enable interrupts at processor level

OSStartHang
    B       OSStartHang                                         ; Should never get here
    
    

PendSV_Handler
    CPSID   I                                                   ; Prevent interruption during context switch
    MRS     R0, PSP                                             ; PSP is process stack pointer
    CBZ     R0, OS_CPU_PendSVHandler_nosave                     ; Skip register save the first time
   
    SUBS    R0, R0, #0x20                                       ; Save remaining regs r4-11 on process stack
    STM     R0, {R4-R11}

    LDR     R1, =OS_Tcb_CurP                                       ; OSTCBCur->OSTCBStkPtr = SP;
    LDR     R1, [R1]
    STR     R0, [R1]                                            ; R0 is SP of process being switched out

                                                                ; At this point, entire context of process has been saved
OS_CPU_PendSVHandler_nosave

    LDR     R0, =Prio_Cur                                      ; OSPrioCur = OSPrioHighRdy;
    LDR     R1, =Prio_HighRdy
    LDRB    R2, [R1]
    STRB    R2, [R0]
   
    LDR     R0, =OS_Tcb_CurP                                       ; OSTCBCur  = OSTCBHighRdy;
    LDR     R1, =OS_Tcb_HighRdyP
    LDR     R2, [R1]
    STR     R2, [R0]

    LDR     R0, [R2]                                       ; R0 is new process SP; SP = OSTCBHighRdy->OSTCBStkPtr;
  
    LDM     R0, {R4-R11}                                        ; Restore r4-11 from new process stack
    ADDS    R0, R0, #0x20
            
    MSR     PSP, R0                                             ; Load PSP with new process SP
    ORR     LR, LR, #0x04                                       ; Ensure exception return uses process stack
    
    CPSIE   I
    BX      LR                                                  ; Exception return will restore remaining context
  
    END