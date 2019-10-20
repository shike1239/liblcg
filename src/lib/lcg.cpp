#include "lcg.h"
#include "cstddef"

// default parameter for conjugate gradient
static const lcg_para defparam = {100, 1e-6, false};

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

void lcg_para_set(lcg_para *param, int itimes, lcg_float eps, bool diff_mod)
{
	param->max_iterations = itimes;
	param->epsilon = eps;
	param->abs_diff = diff_mod;
	return;
}

int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, lcg_float* B, int n_size, lcg_para* param, void* instance)
{
	// set CG parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

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

	lcg_float dTAd, ak, betak, gk1_mod, gk_abs;
	for (int time = 0; time <= para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			gk_abs = 0.0;
			for (int i = 0; i < n_size; i++)
			{
				gk_abs += lcg_fabs(gk[i]);
			}
			gk_abs /= 1.0*n_size;
			if (Pfp(instance, m, gk_abs, &para, n_size, time)) return LCG_STOP;
			if (gk_abs <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp(instance, m, gk_mod/B_mod, &para, n_size, time)) return LCG_STOP;
			if (gk_mod/B_mod <= para.epsilon) return LCG_CONVERGENCE;
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
	return LCG_SUCCESS;
}

int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, lcg_float* B, lcg_float* P, int n_size, lcg_para* param, void* instance)
{
	// set CG parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

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

	lcg_float zTr = 0.0, B_mod = 0.0;
	for (int i = 0; i < n_size; i++)
	{
		zTr += zk[i]*rk[i];
		B_mod = B[i]*B[i];
	}

	lcg_float dTAd, ak, betak, zTr1, rk_mod;
	for (int time = 0; time <= para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			rk_mod = 0.0;
			for (int i = 0; i < n_size; i++)
			{
				rk_mod += lcg_fabs(rk[i]);
			}
			rk_mod /= 1.0*n_size;
			if (Pfp(instance, m, rk_mod, &para, n_size, time)) return LCG_STOP;
			if (rk_mod <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp(instance, m, zTr/B_mod, &para, n_size, time)) return LCG_STOP;
			if (zTr/B_mod <= para.epsilon) return LCG_CONVERGENCE;
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
	return LCG_SUCCESS;
}