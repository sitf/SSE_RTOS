//#include "stm32f10x.h"
#include "led.h"
#include "os.h"
#include "stdio.h"
#include "delay.h"
#include "usart.h"

#define TASK_1_STK_SIZE 128
#define TASK_2_STK_SIZE 128
#define TASK_3_STK_SIZE 128
unsigned int TASK_1_STK[TASK_1_STK_SIZE];
unsigned int TASK_2_STK[TASK_2_STK_SIZE];
unsigned int TASK_3_STK[TASK_3_STK_SIZE];
//ECB * s_msg;			//�ź���
//ECB * m_msg;			//�����ź���
//ECB * q_msg;			//��Ϣ����
//void * MsgGrp[255];			//��Ϣ���д洢��ַ,���֧��255����Ϣ

//��ΪTask1��Task2����ʼʱ������ϵͳ��ʱ������Task3��ʼ��ȡcpu��Task3�����˻����ź�����200ms��Task1��ռ��cpu
//Task3���ȼ���Task1�ͣ�Ϊ�˷�ֹ���ȼ���ת��Task3�����ȼ��ᱻ������ʹ��Task2��ʹ250ms����������ռTask3�����
//Task3�ͷŻ����ź�����ʹ��Task1�ܽ������״̬������Task2Ҳ����Task1�ó�cpuʱ��ȡcpu������Ϊled0��Ϩ��ʱled1��ͬʱ��ʼ��˸
//Task3�ͷŻ����ź������ɾ������Task2������Ϣ����Ϣ���У�Task1���ȡ��Ϣ��
//��������Ϊ����ʼֻ��LED0����(����3)��һ���LED0��Ϩ��(����1)ͬʱLED1�ƿ�ʼ��˸5��(����2)��Ȼ��������������1����һ����Ϣ��
//LED1��������Ϊ������һ���ź�������������10*400ms������1�ͷ�һ���ź�����������һ����Ϣ��ʹ����Ļ���ֽ��ܵ�����Ϣ��
//��ʱ������2��Ϊ�õ��ź������ָ���LED1�ƿ�ʼ��˸
void Task1(void)
{
    while(1)
    {
        printf("1\n");
        OSTimeDly(250);
    }
}
void Task2(void)
{
    while(1)
    {
        printf("2\n");
        OSTimeDly(250);
    }
}
void delay(unsigned int j )//��������ʱ
{
    unsigned int i = 0;
    unsigned int k = j;
    for(i=0; i<50000; i++)
    {
        while(--j);
        j=k;
    }
}
void Task3(void)
{
    while(1)
    {
        printf("3\n");
        OSTimeDly(250);
    }
}
int main(void)
{
    delay_init();  	//ʱ�ӳ�ʼ��
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);//�жϷ�������
    uart_init(115200); 	//���ڳ�ʼ��
    LED_Init();
	
//    Task_Create(Task1,&TASK_1_STK[0],0);
//    Task_Create(Task2,&TASK_2_STK[0],1);
//    Task_Create(Task3,&TASK_3_STK[0],2);
//    
    Task_Create(Task1,&TASK_1_STK[TASK_1_STK_SIZE-1],0);
    Task_Create(Task2,&TASK_2_STK[TASK_2_STK_SIZE-1],1);
    Task_Create(Task3,&TASK_3_STK[TASK_3_STK_SIZE-1],2);
    //malloc_init();//�ڴ��ʼ��
    delay_init();

//    s_msg=OS_SemCreate(0);
//    m_msg =OS_MutexCreate();	//���������ź���
//    q_msg=OS_QCreate(MsgGrp,255);//������Ϣ����

    OS_Start();
    return 0;

}




