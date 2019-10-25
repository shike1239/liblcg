#include "config.h"

#include "lcg.h"
#include "cstddef"

#ifdef LCG_OPENMP

#include "omp.h"

#endif

#ifdef LCG_FABS
/**
 * @brief      return absolute value of lcg_float
 *
 * @param      x     pointer of lcg_float
 */
lcg_float lcg_fabs(lcg_float x)
{
	return (x < 0.0) ? -1.0*x : x;
}

#else

#include "cmath"

#endif

// default parameter for conjugate gradient
static const lcg_para defparam = {100, 1e-6, false};

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

lcg_para lcg_default_parameters()
{
	lcg_para param = defparam;
	return param;
}

const char* lcg_error_str(int er_index)
{
	switch (er_index)
	{
		case LCG_SUCCESS:
			return "The iteration reached convergence.";
		case LCG_STOP:
			return "The conjugate gradient method stopped by the progress evaluation function.";
		case LCG_ALREADY_OPTIMIZIED:
			return "The input variables are already optimized results.";
		case LCG_UNKNOWN_ERROR:
			return "Unknown error.";
		case LCG_INVILAD_VARIABLE_SIZE:
			return "The size of variables is negative.";
		case LCG_INVILAD_MAX_ITERATIONS:
			return "The maximal iteration times is negative.";
		case LCG_INVILAD_EPSILON:
			return "The epsilon is negative.";
		case LCG_REACHED_MAX_ITERATIONS:
			return "The maximal iteration is reached.";
		default:
			return "Unknown error.";
	}
}

int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance)
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

#pragma omp parallel for private (i) schedule(guided)
	for (int i = 0; i < n_size; i++)
	{
		gk[i] = Adk[i] - B[i];
		dk[i] = -1.0*gk[i];
	}

	lcg_float B_mod = 0.0, gk_mod = 0.0;
	for (int i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
		gk_mod += gk[i]*gk[i];
	}

	int time;
	lcg_float dTAd, ak, betak, gk1_mod, gk_abs;
	for (time = 0; time < para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			gk_abs = 0.0;
			for (int i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				gk_abs += lcg_fabs(gk[i]);
#else
				gk_abs += fabs(gk[i]);
#endif
			}
			gk_abs /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, gk_abs, &para, n_size, time)) return LCG_STOP;
			if (gk_abs <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp != NULL)
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

#pragma omp parallel for private (i) schedule(guided)
		for (int i = 0; i < n_size; i++)
		{
			m[i] += ak*dk[i];
			gk[i] += ak*Adk[i];
		}

		gk1_mod = 0.0;
		for (int i = 0; i < n_size; i++)
		{
			gk1_mod += gk[i]*gk[i];
		}
		betak = gk1_mod/gk_mod;
		gk_mod = gk1_mod;

#pragma omp parallel for private (i) schedule(guided)
		for (int i = 0; i < n_size; i++)
		{
			dk[i] = betak*dk[i] - gk[i];
		}
	}

	lcg_free(dk);
	lcg_free(gk);
	lcg_free(Adk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const lcg_float* P, const int n_size, const lcg_para* param, void* instance)
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

#pragma omp parallel for private (i) schedule(guided)
	for (int i = 0; i < n_size; i++)
	{
		rk[i] = B[i] - Adk[i];
	}

#pragma omp parallel for private (i) schedule(guided)
	for (int i = 0; i < n_size; i++)
	{
		zk[i] = P[i]*rk[i];
		dk[i] = zk[i];
	}

	lcg_float zTr = 0.0, B_mod = 0.0;
	for (int i = 0; i < n_size; i++)
	{
		zTr += zk[i]*rk[i];
		B_mod += B[i]*B[i];
	}

	int time;
	lcg_float dTAd, ak, betak, zTr1, rk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			rk_mod = 0.0;
			for (int i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				rk_mod += lcg_fabs(rk[i]);
#else
				rk_mod += fabs(rk[i]);
#endif
			}
			rk_mod /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_mod, &para, n_size, time)) return LCG_STOP;
			if (rk_mod <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp != NULL)
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

#pragma omp parallel for private (i) schedule(guided)
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

#pragma omp parallel for private (i) schedule(guided)
		for (int i = 0; i < n_size; i++)
		{
			dk[i] = zk[i] + betak*dk[i];
		}
	}

	lcg_free(rk); lcg_free(zk);
	lcg_free(dk); lcg_free(Adk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}