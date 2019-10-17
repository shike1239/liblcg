#include "lcg.h"
#include "iostream"

using std::clog;
using std::cerr;
using std::endl;
//设置默认参数值
static const lcg_para defparam = {100, 1e-6};

lcg_float* lcg_malloc(int n)
{
	lcg_float* x = new lcg_float [n];
	return x;
}

void lcg_free(lcg_float* x)
{
	if (x != NULL)
		delete[] x;
	return;
}

bool lcg_para_init(lcg_para* param, int itimes, lcg_float eps)
{
	if (itimes > 0 && eps > 0)
	{
		param->max_iterations = itimes;
		param->epsilon = eps;
		return true;
	}
	else
	{
		cerr << "fail to set lcg parameter, reset to default." << endl;
		param->max_iterations = defparam.max_iterations;
		param->epsilon = defparam.epsilon;
		return false;
	}
}

int lcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, int n_size, lcg_para* param, void* instance)
{
	lcg_para para = (param != NULL) ? (*param) : defparam;

	lcg_float *gk = NULL, *dk = NULL, *Adk = NULL;
	gk = lcg_malloc(n_size);
	dk = lcg_malloc(n_size);
	Adk = lcg_malloc(n_size);

	Afp(instance, m, Adk, n_size);

	lcg_float B_mod = 0.0, gk_mod = 0.0;
	for (int i = 0; i < n_size; i++)
	{
		gk[i] = Adk[i] - B[i];
		dk[i] = -1.0*gk[i];

		B_mod += B[i]*B[i];
		gk_mod += gk[i]*gk[i];
	}

	lcg_float dTAd, ak, betak, gk1_mod;
	for (int time = 0; time < para.max_iterations; time++)
	{
		if (gk_mod/B_mod <= para.epsilon)
		{
			clog << "LCG-times: " << time << "\tconvergence: " << gk_mod/B_mod << endl;
			break;
		}
		else
		{
			clog << "LCG-times: " << time << "\tconvergence: " << gk_mod/B_mod << endl;
			clog << "\033[1A\033[K";
		}

		Afp(instance , dk, Adk, n_size);

		dTAd = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			dTAd += dk[i]*Adk[i];
		}
		ak = gk_mod/dTAd;

		gk1_mod = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			m[i] += ak*dk[i];
			gk[i] += ak*Adk[i];
			gk1_mod += gk[i]*gk[i];
		}

		betak = gk1_mod/gk_mod;
		gk_mod = gk1_mod;
		for (int i = 0; i < n_size; i++)
		{
			dk[i] = betak*dk[i] - gk[i];
		}
	}

	lcg_free(dk);
	lcg_free(gk);
	lcg_free(Adk);
	return 0;
}