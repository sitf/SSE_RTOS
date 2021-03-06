#ifndef TASK_H
#define TASK_H

#include "tk5.h"

typedef	tU4	stack_base;
typedef tU4 stack_size;
typedef tU4 stack;
typedef tU4 app_addr;



typedef struct tcb {
    stack_base tcb_pointer; /* ��������Ķ�ջ�� */
    stack *prev_tcb;
    stack *next_tcb;
    tU4 priority;
} tcb;


void  task_create (
    tcb        *p_tcb,
    app_addr    app,
    tU4        prio,
    stack_base       *p_stk_base,
    stack_size   stk_size
);

#endif
