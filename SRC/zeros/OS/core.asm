
NVIC_INT_CTRL      	EQU     0xE000ED04; �жϿ��ƼĴ���
NVIC_SYSPRI14     	EQU     0xE000ED22; ϵͳ���ȼ��Ĵ���(���ȼ�14).
NVIC_PENDSV_PRI     EQU     	  0xFF; PendSV���ȼ�(���).
NVIC_PENDSVSET     	EQU     0x10000000; PendSV����ֵ
		
	PRESERVE8;8�ֽڶ��룿
	THUMB
		
	AREA CODE, CODE, READONLY
	
	EXTERN CPU_ExceptStkBase;����ջ
		
	EXTERN p_TCB_Cur;ָ��TCB�ĵ�ָ��
	EXTERN p_TCBHightRdy;ָ��������ȼ������ָ��
				
	EXPORT OSStartHighRdy
	EXPORT PendSV_Handler;PendSV�쳣������
	EXPORT OSCtxSw
	EXPORT OS_CPU_SR_Save
	EXPORT OS_CPU_SR_Restore

; ARM΢������֧�ּ���/�洢ָ�������ڼĴ����ʹ洢��֮�䴫�����ݣ�����ָ�����ڽ��洢���е����ݴ��͵��Ĵ������洢ָ��������෴�Ĳ��������õļ��ش洢ָ�����£�
; ��  LDR     �����ݼ���ָ��
; ��  LDRB    �ֽ����ݼ���ָ��
; ��  LDRH    �������ݼ���ָ��
; ��  STR     �����ݴ洢ָ��
; ��  STRB    �ֽ����ݴ洢ָ��
; ��  STRH    �������ݴ洢ָ��
	  
OS_CPU_SR_Save;PRIMASK   ���Ǹ�ֻ�е�һ���صļĴ�������������1�󣬾͹ص����п����ε��쳣��ֻʣ��NMI��Ӳfault������Ӧ������ȱʡֵ��0����ʾû�й��ж�
    MRS     R0, PRIMASK  	;��ȡPRIMASK��R0,R0Ϊ����ֵ 
    CPSID   I				;PRIMASK=1,���ж�(NMI��Ӳ��FAULT������Ӧ)
    BX      LR			    ;����

OS_CPU_SR_Restore
    MSR     PRIMASK, R0	   	;��ȡR0��PRIMASK��,R0Ϊ����
    BX      LR				;����
			
OSCtxSw
	LDR		R0,=NVIC_INT_CTRL
	LDR		R1,=NVIC_PENDSVSET
	STR		R1,[R0];����PendSV
	BX		LR					
	



; @********************************************************************************************************
; @                                         START MULTITASKING
; @                                      void OSStartHighRdy(void)
; @
; @ Note(s) : 1) This function triggers a PendSV exception (essentially, causes a context switch) to cause
; @              the first task to start.
; @
; @           2) OSStartHighRdy() MUST:
; @              a) Setup PendSV exception priority to lowest;
; @              b) Set initial PSP to 0, to tell context switcher this is first run;
; @              c) Set the main stack to OS_CPU_ExceptStkBase
; @              d) Trigger PendSV exception;
; @              e) Enable interrupts (tasks will run with interrupts enabled).
; @********************************************************************************************************
OSStartHighRdy; ����PendSV���쳣�ж����ȼ�
	;LDR{����}   Ŀ�ļĴ���     <�洢����ַ>
	;���ã��� �洢����ַ ��ָ��ַ��������4���ֽڣ�1���֣������ݴ��͵�Ŀ�ļĴ����С�
	;NVIC_SYSPRI14     	EQU     0xE000ED22; ϵͳ���ȼ��Ĵ���(���ȼ�14).
	;NVIC_PENDSV_PRI     EQU     	  0xFF; PendSV���ȼ�(���).


	;��NVIC���ȼ����ƼĴ�����д���ȼ��������������ȼ���0xff��
	LDR		R0,=NVIC_SYSPRI14
	LDR		R1,=NVIC_PENDSV_PRI
	STRB	R1,[R0];���Ĵ���R1�е��ֽ�����д����R0Ϊ��ַ�Ĵ洢���С�
	
	MOVS	R0,#0;�����ջ����Ϊ0
	MSR		PSP,R0;PSP���㣬��Ϊ�״��������л��ı�־
	
	LDR		R0,=CPU_ExceptStkBase;��ʼ����ջΪCPU_ExceptStkBase
	LDR		R1,[R0];R1������+R2�����ݺϳ�һ����ֵַ���õ�ַ�д�ŵ����ݸ�ֵ��R0
	MSR		MSP,R1;��MSP��Ϊ����Ϊ�������ڴ��ַCPU_ExceptStkBase
	
	;��NVIC_INT_CTRL(0xE000ED04; �жϿ��ƼĴ���)��28λд1�����ɽ�PendSV�쳣�������ǵ�ǰû�и����ȼ��жϲ�������ô���򽫻����PendSV handler
	LDR		R0,=NVIC_INT_CTRL
	LDR		R1,=NVIC_PENDSVSET
	STR		R1,[R0]; ����PendSV�쳣
	
	CPSIE	I;�����ж�
	
	
	
	
	
	
PendSV_Handler	
	CPSID	I; ���ж�
	MRS		R0,PSP;��PSPָ���ֵ����R0
	CBZ		R0,OS_CPU_PendSV_Handler_nosave;���PSPΪ0����OS_CPU_PendSV_Handler_nosave
	
	SUBS	R0,R0,#0x20
	STM		R0,{R4-R11}; ��ջR4-R11����R4-R11���浽��ջ��spָ��ĵ�ַ���С�
	
	LDR		R1,=p_TCB_Cur;������������ջ�˺ܶ�Ĵ���		;��ǰ�����ָ��
	LDR 	R1,[R1];��������p_TCB_Cur->StkPtrָ���µ�ջ��
	STR		R0,[R1];��p_TCB_Cur->StkPtr=SP
	
OS_CPU_PendSV_Handler_nosave
	LDR		R0,=p_TCB_Cur;p_TCB_Cur=p_TCBHightRdy
	LDR		R1,=p_TCBHightRdy
	LDR		R2,[R1]
	STR		R2,[R0];��R2��ֵд�뵽��R0���ĵ�ַ��
	
	LDR		R0,[R2];���µ�ջ����SP,SP=p_TCB_Cur->StkPtr
	
	LDM		R0,{R4-R11}; ����R4-R11
	ADDS	R0,R0,#0x20
	
	MSR		PSP,R0;����PSP;��������ջ�Ĵ���������ջָ�루MSP������̶�ջָ�루PSP����������һʱ��ֻ��ʹ�����е�һ����MSPΪ��λ��ȱʡʹ�õĶ�ջָ�룬�쳣��Զʹ��MSP������ֶ�����PSP����ô�߳�ʹ��PSP������Ҳʹ��MSP����ô����PSP��
	ORR		LR,LR,#0x04;��LR��λ2Ϊ1����ô�쳣���غ��߳�ʹ��PSP
	
	CPSIE	I;���ж�
	;ͨ��һ������������һ������ʱ��ʹ��BLָ����ָ���ѵ�ǰ��PC�ŵ�LR�Ĵ���
	BX		LR;��LR�Ĵ��������ݸ��Ƶ�PC�Ĵ����� ���Ӷ�ʵ�ֺ����ķ���
	;���жϳ���ʱ��LR�Ĵ�������Ϊһ�������ֵ���������ص�ַ�����������ж�֮ǰ��PC�Ĵ������ݣ����������жϺ���ʹ��BX LRָ���ʱ ��CPU���ܹ�֪�����жϺ���������
	
	END
		
		