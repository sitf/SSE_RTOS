#include "delay.h"
#include "tk5.h"
#include "sys.h"
#include "usart.h"	 

#define TK_TICK_HZ 1000

//void SysTick_Handler(void)
//{	
//	printf("systick");
//	if(TK_RUN==1)						//OS开始跑了,才执行正常的调度处理
//	{
////		OSIntEnter();							//进入中断
////		OSTimeTick();       					//调用ucos的时钟服务程序               
////		OSIntExit();       	 					//触发任务切换软中断
//	}
//}

			   
//初始化延迟函数
//当使用OS的时候,此函数会初始化OS的时钟节拍
//SYSTICK的时钟固定为HCLK时钟的1/8
//SYSCLK:系统时钟
void delay_init()
{
	u32 reload;
	SysTick_CLKSourceConfig(SysTick_CLKSource_HCLK_Div8);	//选择外部时钟  HCLK/8
	reload=SystemCoreClock/8000000;				//每秒钟的计数次数 单位为K	   
	reload*=1000000/TK_TICK_HZ;		//根据TK_TICK_HZ设定溢出时间;reload为24位寄存器,最大值:16777216,在72M下,约合1.86s左右	

	SysTick->CTRL|=SysTick_CTRL_TICKINT_Msk;   	//开启SYSTICK中断
	SysTick->LOAD=reload; 						//每1/delay_ostickspersec秒中断一次	
	SysTick->CTRL|=SysTick_CTRL_ENABLE_Msk;   	//开启SYSTICK    
}								    









































