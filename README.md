## 分工

### 林航-内存分区，权限控制，安全认证

指标：完成内存分区，静态内存管理

### 王润哲-调度，微内核服务模块

指标：完成微内核标准调度，服务总线

### 内存空间分配

在不具备 MMU 的 CPU 体系结构中，内核空间的内存管理进程控制整个内存空
间，根据用户进程的内存操作请求完成各内存访问，统一维护全局离散内存块的管理和映射

微内核采用静态内存空间配置，将物理内存分为逻辑上隔离的四个空间：内核内存空间、共享内存
空间、系统内存空间、用户内存空间。 不允许跨地址空间直接访问，只能通过服务原语进行陷入，仅提
供服务，不开放地址空间

内核内存空间仅由具有内核特权的程序使用， 为内核服务程序和内核数据结构分配地址空间，内核
数据结构包括：中断向量表和服务向量表、进程控制块 PCB、用户控制块 UCB、访问控制块 SCB、、执行
控制块 ECB、可信软件基 TSB、地址空间块 ASB、事件传输块 ETB 等。

系统内存空间仅由具有系统特权的程序使用， 为操作系统服务程序、 运行时库程序及系统服务数据
结构分配地址空间。 系统内存地址空间原则上采用虚拟存储管理方式，仅仅与设备驱动和中断服务相关
的代码常驻内存。
用户内存空间由用户程序使用， 为用户服务程序、 用户运行时库程序及用户服务数据结构分配地址
空间。


共享内存空间由内核程序、系统程序和用户程序共享，该内存空间仅存放数据，不存放程序。共享
内存空间支持两种访问冲突处理方式，一是拥有者可写其他只读，二是按临界资源由信号灯（semaphore）进行访问管理。
### 安全可信认证


### 进程和线程调度
微内核支持多进程和多线程，一个进程的多个线程共享该进程的地址空间。微内核进程线程调度的
最小单位是线程，当调度切换进程时，与进程相关的页表也要切换，当调度切换属于同一进程的线程时，
页表不需切换。 进程或线程采用两个字节的 PID 进行标识。 微内核采用以抢占式为主、 三种调度方法融
合的进程调度， 优先保障实时性，同时兼顾公平性。

一是事件驱动方法， 当中断、异常、出错、请求、报告、信号、消息等事件发生时， 微内核立刻将
执行权切换到处理该事件的进程或线程，同时进行时间限制， 最多只能执行一个时间片。 该方式的执行
优先级最高，以保障事件驱动的实时响应。

二是实时优先级方法， 当没有事件发生时，微内核基于优先级抢占式实时调度， 进程优先级分为
256 级，高优先级进程可打断低优先级进程， 同时进行时间限制， 最多只能执行一个时间片。 该方式的
执行优先级低于事件驱动方式，高于时间片轮转方式。

三是时间片轮转方法， 当没有事件发生、也没有更高优先级进程抢先时，微内核选择切换到已经等
待时间片最多的进程或线程，防止低优先级进程长时间等待（饿死）。

微内核仅提供进程线程的调度切换（context switching）功能,而进程线程的创建、启动、停止、
注册、删除等功能，则由核外的进程服务模块处理， 但对于需要安全认证的特权服务功能，还需要微内
核的安全可信模块配合才能完成。

### 事件传输总线

### 系统服务模块

> 系统服务模块是指由 POSIX 定义的系统服务模块中除了内核服务模块之外的其他系统服务模块。一
般包括：用户安全管理、进程线程启停、内存动态管理、文件系统管理、硬件设备及驱动程序、网络系
统及协议栈、服务注册和事件注册、名字空间管理等。 系统服务模块的主要功能与 POSIX 的描述基本相
同

POSIX定义系统调用实现
> 分析在MVB, UIC中使用到的系统调用集合（包括POSIX接口集合），分析新通达OS是否满足我们的需求。


## 任务

### 国网
- 按进度安排开展工作

### 新通达：

- 根据TCN工程源码，分析OS系统调用集合，测试验证新通达方面交付OS技术性能指标

> 可以把MVB和网关的程序源代码给你，你们需要分析在这两个工程中使用到的系统调用集合（包括POSIX接口集合），这样可以分析出，新通达交付的OS是否满足我们的需求。

### 领域专项
- 研发微内核标准嵌入式操作系统

## 项目说明

### 国家电网项目（用电智能终端安全MCU芯片关键安全技术研究）

时间 | 内容| 考核指标
---|--|---
2018.01-2018.03	|用电智能终端应用场景、业务需求调研；|面向用电智能终端嵌入式实时操作系统调研报告（业务需求部分）（清华）
2018.04-2018.06	|用电智能终端安全需求调研。|面向用电智能终端嵌入式实时操作系统调研报告（安全需求部分）（清华）
2018.07-2018.09	|用电智能终端安全MCU芯片的整体安全架构设计，完成硬件部分。调研主流嵌入式实时操作系统安全架构；	|面向用电智能终端嵌入式实时操作系统调研报告（安全架构部分）（清华）
2018.10-2018.12	|用电智能终端安全MCU芯片的整体安全架构设计，完成软件部分。调研操作系统安全保护访问控制机制	|面向用电智能终端嵌入式实时操作系统调研报告（安全机制部分）（清华）
2019.01-2019.03	|用电智能终端安全MCU芯片的整体安全架构设计，完成软硬件结合。|嵌入式系统安全架构设计文档（安全架构部分）（清华）
2019.04-2019.06	|用电智能终端安全MCU芯片的整体安全架构设计方案完成。|嵌入式系统安全架构设计文档（安全机制部分）（清华）
2019.07-2019.09	|设计嵌入式实时操作系统安全架构|嵌入式系统安全架构设计文档（数据结构定义部分）（清华）
2019.10-2019.12	|设计嵌入式实时操作系统内存安全访问控制机制|嵌入式系统安全架构设计文档（框架接口说明部分）（清华）
2020.01-2020.03	|编码实现嵌入式实时操作系统内存安全访问控制机制|嵌入式实时操作系统内存安全访问控制机制代码实现（清华）
2020.04-2020.06	|编码实现嵌入式实时操作系统安全架构	|嵌入式实时操作系统安全架构代码实现（清华）
2020.07-2020.09	|集成测试验证嵌入式实时操作系统安全架构与内存安全保护机制|嵌入式实时操作系统安全架构安全性、实时性测试报告（清华）




### 新通达操作系统合作项目（列车通信网络嵌入式设备操作系统移植替换）
#### 背景：
中车信息有限公司委托新通达基于自有车载RTOS开发适合轨道交通通信系统使用的RTOS，以实现产品核心部件自主化。

#### 目标
短期目标：
实现MVB网卡产品（STM32 ARM Contex-M Processor）的底层操作系统替换（原项目基于eCOS系统实现）。

长期目标：实现完整类Linux操作系统（ARM Context-M & X86 Processors），以支持后续网关和交换机产品的开发。

#### 关键需求：
- POSIX兼容：
中车信息公司现有产品均基于POSIX兼容操作系统开发，未来产品会用到开源网络协议及框架（同样基于POSIX接口），新操作系统需要支持现有产品应用程序的移植以及开源网络协议栈的移植。
- Rom/Flash文件系统：
新操作系统需要支持Rom/Flash文件系统，用于存储产品的配置和日志文件。
- 关键设备驱动：
新操作系统需要根据产品系统设计支持相关外设的驱动（如PCI，PCI-e外设）
- 应用开发支持：
新操作系统需要集成配套的Loader或ROM Monitor以支持应用程序和数据的刷写、以及应用程序的诊断信息输出。


### 四方所QNX替换（国家科技重大专项：轨道交通装备基础软件和保障工具研发）

#### 目标
形成面向列车通信网络的定制化实时操作系统

#### 现状

现有主流实时操作系统分为开源和闭源两大类，当他们应用于轨道交通装备时存在软件可裁剪性及硬件适应性弱、无法修改以适配列车环境、任务调度机制单一等缺点。而轨道交通装备的 特殊性及多样性  决定了其对嵌入式操作系统有较高要求。针对这些特殊需求以及主流实时操作系统应用于轨道交通装备时所存在的上述问题，我们必须设计研发定制化实时操作系统。

#### 工作内容

##### OS实时性研究：主要对Linux内核进行实时性改造和优化；
1. 从中断处理，时钟处理和调度算法3方面改进现有Linux内核实时性，以满足复杂多任务环境要求。
2. 设计全新实时微内核。实时任务运行在微内核上，非实时任务运行在linux内核上。    

##### OS调度策略研究：针对轨道交通装备特殊需求， 定制实时任务调度策略；
1. 实现 RM（单调速率） 实时调度策略；    
2. 实现 EDF（最短deadline优先）调度策略 。
 

##### 实时性测试平台：为轨道交通装备软件提供性能测试平台
1. 测试数据载入模块：将测试代码以代码插桩等方法加载到测试系统；     
2. 测试数据搜集模块：搜集并存储实时数据，供分析模块使用。
3. 测试分析模块：对实时数据进行理论分析；                
4. 配置模块：对测试平台进行不同选项的配置。

> 定制化的实时调度策略 和 增强实时性后的内核  将成为整个软件系统的稳固基石。

> 实时微内核的主要功能是拦截并处理硬件中断，以保证实时任务优先执行。RT_LINUX 和 RTAI 为目前实现实时微内核的两种方案。


