#ifndef _LCG_H
#define _LCG_H

//定义专用的浮点类型。有利于以后多平台编译，这里默认为64位。
typedef double lcg_float;
//共轭梯度参数类型
struct lcg_para
{
	int max_iterations; //最大的迭代次数
	lcg_float epsilon; //迭代的终止条件值
};
//共轭梯度中Ax计算的回调函数指针
typedef void (*lcg_axfunc_ptr)(void* instance, lcg_float* input_array, lcg_float* output_array, int n_size);
//开辟内存空间
lcg_float* lcg_malloc(int n);
//销毁内存空间
void lcg_free(lcg_float* x);
//设置一个LCG的参数对象
bool lcg_para_init(lcg_para* param, int itimes, lcg_float eps);
//共轭梯度方法
int lcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, int n_size, lcg_para* param, void* instance);
#endif //_LCG_H