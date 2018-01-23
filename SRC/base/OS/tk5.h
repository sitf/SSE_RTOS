// K5 Micro Kernel OS K5微内核操作系统公用数据


//常用数据类型定义；
typedef char tI1; //有符号1字节整型数
typedef unsigned char tU1; //无符号1字节整型数
typedef short tI2; //有符号2字节整型数
typedef unsigned short tU2; //无符号2字节整型数
typedef int tI4; //有符号4字节整型数
typedef unsigned int tU4; //无符号4字节整型数
typedef long tI8; //有符号8字节整型数
typedef unsigned long tU8; //无符号8字节整型数
typedef float tF4; //4字节浮点数
typedef double tF8; //8字节浮点数

//帧类型常数定义（3比特）
#define K5_F0H4L0 0 //帧类型： 0型帧，头部4字节， 数据0字节；
#define K5_F1H8L0 1 //帧类型： 1型帧，头部8字节，数据0字节；
#define K5_F2H8L8 2 //帧类型： 2型帧，头部8字节，数据以8字节为单位计数；
#define K5_F3H8LP 3 //帧类型： 3型帧，头部8字节，数据以页面(4KB)为单位计数；

//响应标识代码定义（2比特）
#define K5_REQ 0 //响应标识： 0：服务请求；
#define K5_ACK 1 //响应标识： 1：接收正确；
#define K5_NAK 2 //响应标识： 2：接收出错；
#define K5_ARQ 3 //响应标识： 3：反向请求；

//服务原语代码定义（2比特）
#define K5_SA 0 //服务原语代码： 0：服务请求；
#define K5_RA 1 //响应标识： 1：接收正确；
#define K5_SS 2 //响应标识： 2：接收出错；
#define K5_RS 3 //响应标识： 3：反向请求；

//系统服务原语的函数接口原型：
//异步发送 ( 服务， 模式， P1帧长， P2缓冲区 );
tU4 SA ( tU2, tU1, tU2, tU4* );
//异步接收 ( 服务，模式， P1帧长， P2缓冲区 );
tU4 RA ( tU2*, tU1, tU2, tU4*);
//同步发送 ( 服务，模式， P1帧长， P2缓冲区 );
tU4 SS ( tU2, tU1, tU2, tU4* );
//同步接收 ( 服务，模式， P1帧长， P2缓冲区 );
tU4 RS ( tU2*, tU1, tU2, tU4*);



