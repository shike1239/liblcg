#include "../lib/lcg.h"
#include "iostream"

using std::cout;
using std::clog;
using std::endl;

class TESTFUNC
{
public:
	TESTFUNC();
	~TESTFUNC();
	void Routine();
	/**
	 * 因为类的成员函数指针不能直接被调用，所以我们在这里定义一个静态的中转函数来辅助Ax函数的调用
	 * 这里我们利用reinterpret_cast将_Ax的指针转换到Ax上，需要注意的是成员函数的指针只能通过
	 * 实例对象进行调用，因此需要void* instance变量。
	*/
	static void _Ax(void* instance, const lcg_float* a, lcg_float* b, const int num)
	{
		return reinterpret_cast<TESTFUNC*>(instance)->Ax(a, b, num);
	}
	void Ax(const lcg_float* a, lcg_float* b, const int num); //定义共轭梯度中Ax的算法

	static int _Progress(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k)
	{
		return reinterpret_cast<TESTFUNC*>(instance)->Progress(m, converge, param, n_size, k);
	}
	int Progress(const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k);
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
	// 测试预优矩阵 这里只是测试流程 预优矩阵值全为1 并没有什么作用
	p_ = lcg_malloc(3);
	p_[0] = p_[1] = p_[2] = 1.0;
}

TESTFUNC::~TESTFUNC()
{
	lcg_free(m_);
	lcg_free(b_);
	lcg_free(p_);
}

void TESTFUNC::Ax(const lcg_float* a, lcg_float* b, const int num)
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

int TESTFUNC::Progress(const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k)
{
	if (converge <= param->epsilon)
	{
		clog << "Iteration-times: " << k << "\tconvergence: " << converge << endl;
	}
	else
	{
		clog << "Iteration-times: " << k << "\tconvergence: " << converge << endl;
		clog << "\033[1A\033[K";
	}
	return 0;
}

void TESTFUNC::Routine()
{
	lcg_para self_para;
	lcg_para_set(&self_para, 10, 1e-6, true);
	// 调用函数求解
	lcg(_Ax, _Progress, m_, b_, 3, &self_para, this);
	// 输出解
	for (int i = 0; i < 3; i++)
	{
		cout << m_[i] << endl;
	}

	// rest m_ and solve with lpcg
	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// use lpcg to solve the linear system
	lpcg(_Ax, _Progress, m_, b_, p_, 3, &self_para, this);
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