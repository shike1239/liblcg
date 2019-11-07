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
	lcg_float kernel_[3][3];
};

TESTFUNC::TESTFUNC()
{
	// 测试线性方程组
	// 6.3*x1 + 3.9*x2 + 2.5*x3 = -2.37
	// 1.2*x1 + 2.6*x2 + 1.1*x3 = -6.2
	// 4.5*x1 + 1.4*x2 + 2.6*x3 = 4.9
	// 目标解 x1=1.2 x2=-3.7 x3=1.8
	// CGS与BICGSTAB方法主要用于求解非对称的线性方程组
	kernel_[0][0] = 6.3; kernel_[0][1] = 3.9; kernel_[0][2] = 2.5;
	kernel_[1][0] = 1.2; kernel_[1][1] = 2.6; kernel_[1][2] = 1.1;
	kernel_[2][0] = 4.5; kernel_[2][1] = 1.4; kernel_[2][2] = 2.6;
	// 初始解
	m_ = lcg_malloc(3);
	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// 拟合目标值（含有一定的噪声）
	b_ = lcg_malloc(3);
	b_[0] = -2.3701212; b_[1] = -6.2100323; b_[2] = 4.9204232;
}

TESTFUNC::~TESTFUNC()
{
	lcg_free(m_);
	lcg_free(b_);
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
	clog << "Iteration-times: " << k << "\tconvergence: " << converge << endl;
	if (converge > param->epsilon) clog << "\033[1A\033[K";
	return 0;
}

void TESTFUNC::Routine()
{
	lcg_para self_para = lcg_default_parameters();
	// 调用函数求解
	int ret = lcg_solver(_Ax, _Progress, m_, b_, 3, &self_para, this);
	if (ret < 0) cout << lcg_error_str(ret) << endl;
	// 输出解
	for (int i = 0; i < 3; i++)
	{
		cout << m_[i] << endl;
	}

	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// 调用函数求解
	ret = lcg_solver(_Ax, _Progress, m_, b_, 3, &self_para, this, LCG_BICGSTAB);
	if (ret < 0) cout << lcg_error_str(ret) << endl;
	// 输出解
	for (int i = 0; i < 3; i++)
	{
		cout << m_[i] << endl;
	}

	m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
	// 调用函数求解
	ret = lcg_solver(_Ax, _Progress, m_, b_, 3, &self_para, this, LCG_BICGSTAB2);
	if (ret < 0) cout << lcg_error_str(ret) << endl;
	// 输出解
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