# 线性共轭梯度算法库（C++ Library of Linear Conjugate Gradient，LIBLCG）

张壹（zhangyiss@icloud.com）

_浙江大学地球科学学院_

## 简介

liblcg是一个简单的C++线性共轭梯度算法库，包含了一般形式的共轭梯度与预优共轭梯度算法。可用于求解如下形式的线性方程组：

Ax = B （可用共轭梯度求解）或者 PAx = PB（可用预优共轭梯度求解）

其中，A是一个N阶的对称矩阵、x为N\*1的待求解的模型向量，B为N\*1需拟合的目标向量。P则为预优算法中的预优矩阵，一般是一个N阶的对角阵。共轭梯度法广泛应用于无约束的线性最优化问题，拥有优良收敛与计算效率。

## 安装

1. GCC（MacOS）

   ```shell
   mkdir build
   cd build
   cmake ..
   make
   make install
   ```

2. Windows

   请自行拷贝代码新建项目并编译…嘿嘿😁！  

## 使用说明

### 自定义Ax计算函数

通常我们在使用共轭梯度法求解线性方程组Ax=B时A的维度可能会很大，直接储存A将消耗大量的内存空间，因此一般并不直接计算并储存A而是在需要的时候计算Ax的乘积。因此用户在使用liblcg时需要定义Ax的计算函数，同时提供初始解x与共轭梯度的B项（即拟合的对象）。如果使用预优方法还需要提供预优矩阵P项。Ax计算函数的形式必须满足算法库定义的一般形式：

```c++
typedef void (*lcg_axfunc_ptr)(void* instance, lcg_float* input_array, lcg_float* output_array, int n_size);
```

函数接受4个参数，分别为：

1. `void *instance` 传入的实例对象；
2. `lcg_float *input_array` Ax计算中的x数组的指针；
3. `lcg_float *output_array` Ax的乘积；
4. `int n_size` 矩阵的大小。

### 调用 lcg() 函数求解

Ax计算函数定义完成后，用户需要给出方程组的初始解（一般可直接赋0）与共轭梯度的B项。然后调用 lcg() 函数求解：

```c++
int lcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, int n_size, lcg_para* param, void* instance);
```

### 调用 lpcg() 函数求解

Ax计算函数定义完成后，用户需要给出方程组的初始解（一般可直接赋0）、共轭梯度的B项与预优矩阵P项（P一般为一个N阶的对角阵）。然后调用 lpcg() 函数求解：

```c++
int lpcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, lcg_float* P, int n_size, lcg_para* param, void* instance);
```

## 示例

```c++
#include "../lib/lcg.h"   
#include "iostream"

using std::cout;
using std::endl;

class TESTFUNC
{
public:
	TESTFUNC();
	~TESTFUNC();
	void Routine();
	/**
	 *因为类的成员函数指针不能直接被调用，所以我们在这里定义一个静态的中转函数来辅助Ax函数的调用
	 *这里我们利用reinterpret_cast将_Ax的指针转换到Ax上，需要注意的是成员函数的指针只能通过
	 *实例对象进行调用，因此需要void* instance变量。
	*/
	static void _Ax(void* instance, lcg_float* a, lcg_float* b, int num)
	{
		return reinterpret_cast<TESTFUNC*>(instance)->Ax(a, b, num);
	}
	void Ax(lcg_float* a, lcg_float* b, int num); //定义共轭梯度中Ax的算法
private:
	lcg_float* m_;
	lcg_float* b_;
	lcg_float* p_;
	lcg_float kernel_[3][3];
};

TESTFUNC::TESTFUNC()
{
	// 测试线性方程组
	// 6.3*x1 + 3.9*x2 + 2.5*x3 = -2.37
	// 3.9*x1 + 1.2*x2 + 3.1*x3 = 5.82
	// 2.5*x1 + 3.1*x2 + 7.6*x3 = 5.21
	// 目标解 x1=1.2 x2=-3.7 x3=1.8
	// 注意根据共轭梯度法的要求 kernel是一个N阶对称阵
	kernel_[0][0] = 6.3; kernel_[0][1] = 3.9; kernel_[0][2] = 2.5;
	kernel_[1][0] = 3.9; kernel_[1][1] = 1.2; kernel_[1][2] = 3.1;
	kernel_[2][0] = 2.5; kernel_[2][1] = 3.1; kernel_[2][2] = 7.6;
	// 初始解
	m_ = lcg_malloc(3);
	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// 拟合目标值（含有一定的噪声）
	b_ = lcg_malloc(3);
	b_[0] = -2.3723; b_[1] = 5.8221; b_[2] = 5.2165;
	// 测试预优矩阵
	p_ = lcg_malloc(3);
	p_[0] = p_[1] = p_[2] = 1.0;
}

TESTFUNC::~TESTFUNC()
{
	lcg_free(m_);
	lcg_free(b_);
	lcg_free(p_);
}

void TESTFUNC::Ax(lcg_float* a, lcg_float* b, int num)
{
	for (int i = 0; i < num; i++)
	{
		b[i] = 0.0;
		for (int j = 0; j < num; j++)
		{
			b[i] += kernel_[i][j]*a[j];
		}
	}
	return;
}

void TESTFUNC::Routine()
{
	// 调用函数求解
	lcg(_Ax, m_, b_, 3, NULL, this);
	// 输出解
	for (int i = 0; i < 3; i++)
	{
		cout << m_[i] << endl;
	}

	// rest m_ and solve with lpcg
	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// use lpcg to solve the linear system
	lpcg(_Ax, m_, b_, p_, 3, NULL, this);
	// output solution
	for (int i = 0; i < 3; i++)
	{
		cout << m_[i] << endl;
	}
	return;
}

int main(int argc, char const *argv[])
{
	TESTFUNC test;
	test.Routine();
	return 0;
}
```

