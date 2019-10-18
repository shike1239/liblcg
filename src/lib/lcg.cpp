#include "lcg.h"
#include "iostream"

using std::clog;
using std::cerr;
using std::endl;

// default parameter for conjugate gradient
static const lcg_para defparam = {100, 1e-6};

/**
 * @brief      return absolute value of lcg_float
 *
 * @param      x     pointer of lcg_float
 */
lcg_float lcg_fabs(lcg_float x)
{
	return (x < 0.0) ? -1.0*x : x;
}

lcg_float* lcg_malloc(const int n)
{
	lcg_float* x = new lcg_float [n];
	return x;
}

void lcg_free(lcg_float* x)
{
	if (x != NULL) delete[] x;
	x = NULL;
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
	// set CG parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return -1;
	if (para.max_iterations <= 0) return -1;
	if (para.epsilon <= 0.0) return -1;

	// locate memory
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
	for (int time = 0; time <= para.max_iterations; time++)
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

int lpcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, lcg_float* P, int n_size, lcg_para* param, void* instance)
{
	// set CG parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return -1;
	if (para.max_iterations <= 0) return -1;
	if (para.epsilon <= 0.0) return -1;

	// locate memory
	lcg_float *rk = NULL, *zk = NULL;
	lcg_float *dk = NULL, *Adk = NULL;

	rk = lcg_malloc(n_size); zk = lcg_malloc(n_size);
	dk = lcg_malloc(n_size); Adk = lcg_malloc(n_size);

	Afp(instance , m, Adk, n_size);

	for (int i = 0; i < n_size; i++)
	{
		rk[i] = B[i] - Adk[i];
	}

	for (int i = 0; i < n_size; i++)
	{
		zk[i] = P[i]*rk[i];
		dk[i] = zk[i];
	}

	lcg_float zTr = 0.0;
	for (int i = 0; i < n_size; i++)
	{
		zTr += zk[i]*rk[i];
	}

	lcg_float dTAd, ak, betak, zTr1, rk_mod;
	for (int time = 0; time <= para.max_iterations; time++)
	{
		// we use averaged absolute difference to evaluate the function
		rk_mod = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			rk_mod += lcg_fabs(rk[i]);
		}
		rk_mod /= 1.0*n_size;

		if (rk_mod <= para.epsilon)
		{
			clog << "LPCG-times: " << time << "\tconvergence: " << rk_mod << endl;
			break;
		}
		else
		{
			clog << "LPCG-times: " << time << "\tconvergence: " << rk_mod << endl;
			clog << "\033[1A\033[K";
		}

		Afp(instance , dk, Adk, n_size);

		dTAd = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			dTAd += dk[i]*Adk[i];
		}
		ak = zTr/dTAd;

		for (int i = 0; i < n_size; i++)
		{
			m[i] += ak*dk[i];
			rk[i] -= ak*Adk[i];
			zk[i] = P[i]*rk[i];
		}

		zTr1 = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			zTr1 += zk[i]*rk[i];
		}
		betak = zTr1/zTr;

		zTr = zTr1;
		for (int i = 0; i < n_size; i++)
		{
			dk[i] = zk[i] + betak*dk[i];
		}
	}

	lcg_free(rk); lcg_free(zk);
	lcg_free(dk); lcg_free(Adk);
	return 0;
}