#include "delay.h"
#include "tk5.h"
#include "sys.h"
#include "usart.h"	 

#define TK_TICK_HZ 1000

//void SysTick_Handler(void)
//{	
//	printf("systick");
//	if(TK_RUN==1)						//OS��ʼ����,��ִ�������ĵ��ȴ���
//	{
////		OSIntEnter();							//�����ж�
////		OSTimeTick();       					//����ucos��ʱ�ӷ������               
////		OSIntExit();       	 					//���������л����ж�
//	}
//}

			   
//��ʼ���ӳٺ���
//��ʹ��OS��ʱ��,�˺������ʼ��OS��ʱ�ӽ���
//SYSTICK��ʱ�ӹ̶�ΪHCLKʱ�ӵ�1/8
//SYSCLK:ϵͳʱ��
void delay_init()
{
	u32 reload;
	SysTick_CLKSourceConfig(SysTick_CLKSource_HCLK_Div8);	//ѡ���ⲿʱ��  HCLK/8
	reload=SystemCoreClock/8000000;				//ÿ���ӵļ������� ��λΪK	   
	reload*=1000000/TK_TICK_HZ;		//����TK_TICK_HZ�趨���ʱ��;reloadΪ24λ�Ĵ���,���ֵ:16777216,��72M��,Լ��1.86s����	

	SysTick->CTRL|=SysTick_CTRL_TICKINT_Msk;   	//����SYSTICK�ж�
	SysTick->LOAD=reload; 						//ÿ1/delay_ostickspersec���ж�һ��	
	SysTick->CTRL|=SysTick_CTRL_ENABLE_Msk;   	//����SYSTICK    
}								    









































