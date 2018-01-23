
NVIC_INT_CTRL      	EQU     0xE000ED04; 中断控制寄存器
NVIC_SYSPRI14     	EQU     0xE000ED22; 系统优先级寄存器(优先级14).
NVIC_PENDSV_PRI     EQU     	  0xFF; PendSV优先级(最低).
NVIC_PENDSVSET     	EQU     0x10000000; PendSV触发值
		
	PRESERVE8;8字节对齐？
	THUMB
		
	AREA CODE, CODE, READONLY
	
	EXTERN CPU_ExceptStkBase;主堆栈
		
	EXTERN p_TCB_Cur;指向TCB的的指针
	EXTERN p_TCBHightRdy;指向最高优先级任务的指针
				
	EXPORT OSStartHighRdy
	EXPORT PendSV_Handler;PendSV异常处理函数
	EXPORT OSCtxSw
	EXPORT OS_CPU_SR_Save
	EXPORT OS_CPU_SR_Restore

; ARM微处理器支持加载/存储指令用于在寄存器和存储器之间传送数据，加载指令用于将存储器中的数据传送到寄存器，存储指令则完成相反的操作。常用的加载存储指令如下：
; —  LDR     字数据加载指令
; —  LDRB    字节数据加载指令
; —  LDRH    半字数据加载指令
; —  STR     字数据存储指令
; —  STRB    字节数据存储指令
; —  STRH    半字数据存储指令
	  
OS_CPU_SR_Save;PRIMASK   这是个只有单一比特的寄存器。在它被置1后，就关掉所有可屏蔽的异常，只剩下NMI和硬fault可以响应。它的缺省值是0，表示没有关中断
    MRS     R0, PRIMASK  	;读取PRIMASK到R0,R0为返回值 
    CPSID   I				;PRIMASK=1,关中断(NMI和硬件FAULT可以响应)
    BX      LR			    ;返回

OS_CPU_SR_Restore
    MSR     PRIMASK, R0	   	;读取R0到PRIMASK中,R0为参数
    BX      LR				;返回
			
OSCtxSw
	LDR		R0,=NVIC_INT_CTRL
	LDR		R1,=NVIC_PENDSVSET
	STR		R1,[R0];触发PendSV
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
OSStartHighRdy; 设置PendSV的异常中断优先级
	;LDR{条件}   目的寄存器     <存储器地址>
	;作用：将 存储器地址 所指地址处连续的4个字节（1个字）的数据传送到目的寄存器中。
	;NVIC_SYSPRI14     	EQU     0xE000ED22; 系统优先级寄存器(优先级14).
	;NVIC_PENDSV_PRI     EQU     	  0xFF; PendSV优先级(最低).


	;往NVIC优先级控制寄存器里写优先级，定义成最低优先级（0xff）
	LDR		R0,=NVIC_SYSPRI14
	LDR		R1,=NVIC_PENDSV_PRI
	STRB	R1,[R0];将寄存器R1中的字节数据写入以R0为地址的存储器中。
	
	MOVS	R0,#0;任务堆栈设置为0
	MSR		PSP,R0;PSP清零，作为首次上下文切换的标志
	
	LDR		R0,=CPU_ExceptStkBase;初始化堆栈为CPU_ExceptStkBase
	LDR		R1,[R0];R1的数据+R2的数据合成一个地址值，该地址中存放的数据赋值给R0
	MSR		MSP,R1;将MSP设为我们为其分配的内存地址CPU_ExceptStkBase
	
	;往NVIC_INT_CTRL(0xE000ED04; 中断控制寄存器)第28位写1，即可将PendSV异常挂起。若是当前没有高优先级中断产生，那么程序将会进入PendSV handler
	LDR		R0,=NVIC_INT_CTRL
	LDR		R1,=NVIC_PENDSVSET
	STR		R1,[R0]; 触发PendSV异常
	
	CPSIE	I;开启中断
	
	
	
	
	
	
PendSV_Handler	
	CPSID	I; 关中断
	MRS		R0,PSP;把PSP指针的值赋给R0
	CBZ		R0,OS_CPU_PendSV_Handler_nosave;如果PSP为0调到OS_CPU_PendSV_Handler_nosave
	
	SUBS	R0,R0,#0x20
	STM		R0,{R4-R11}; 入栈R4-R11；把R4-R11保存到堆栈（sp指向的地址）中。
	
	LDR		R1,=p_TCB_Cur;在这里我们入栈了很多寄存器		;当前任务的指针
	LDR 	R1,[R1];这三句让p_TCB_Cur->StkPtr指向新的栈顶
	STR		R0,[R1];即p_TCB_Cur->StkPtr=SP
	
OS_CPU_PendSV_Handler_nosave
	LDR		R0,=p_TCB_Cur;p_TCB_Cur=p_TCBHightRdy
	LDR		R1,=p_TCBHightRdy
	LDR		R2,[R1]
	STR		R2,[R0];将R2的值写入到【R0】的地址中
	
	LDR		R0,[R2];将新的栈顶给SP,SP=p_TCB_Cur->StkPtr
	
	LDM		R0,{R4-R11}; 弹出R4-R11
	ADDS	R0,R0,#0x20
	
	MSR		PSP,R0;更新PSP;有两个堆栈寄存器，主堆栈指针（MSP）与进程堆栈指针（PSP），而且任一时刻只能使用其中的一个。MSP为复位后缺省使用的堆栈指针，异常永远使用MSP，如果手动开启PSP，那么线程使用PSP，否则也使用MSP。怎么开启PSP？
	ORR		LR,LR,#0x04;置LR的位2为1，那么异常返回后，线程使用PSP
	
	CPSIE	I;开中断
	;通常一个函数调用另一个函数时会使用BL指令，这个指令会把当前的PC放到LR寄存器
	BX		LR;把LR寄存器的内容复制到PC寄存器里 ，从而实现函数的返回
	;在中断出现时，LR寄存器会设为一个特殊的值（函数返回地址），而不是中断之前的PC寄存器内容，这样，当中断函数使用BX LR指令返回时 ，CPU就能够知道是中断函数返回了
	
	END
		
		