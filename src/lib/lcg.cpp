#include "config.h"
#include "lcg.h"

#ifdef LCG_OPENMP

#include "omp.h"

#endif

#ifdef LCG_FABS

/**
 * @brief      return absolute value
 *
 * @param      x     input value
 */
#define lcg_fabs(x) ((x < 0) ? -1*x : x)

#else

#include "cmath"

#endif

// default parameter for conjugate gradient
static const lcg_para defparam = {100, 1e-6, false, 1e-6};

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
		case LCG_INVILAD_RESTART_EPSILON:
			return "The restart epsilon is negative.";
		case LCG_REACHED_MAX_ITERATIONS:
			return "The maximal iteration is reached.";
		default:
			return "Unknown error.";
	}
}

/**
 * @brief      The conjugate gradient method
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 *
 * @return     status of the function
 */
int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P)
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

	int i;
#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		gk[i] = Adk[i] - B[i];
		dk[i] = -1.0*gk[i];
	}

	lcg_float B_mod = 0.0, gk_mod = 0.0;
	for (i = 0; i < n_size; i++)
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
			for (i = 0; i < n_size; i++)
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
		for (i = 0; i < n_size; i++)
		{
			dTAd += dk[i]*Adk[i];
		}
		ak = gk_mod/dTAd;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*dk[i];
			gk[i] += ak*Adk[i];
		}

		gk1_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			gk1_mod += gk[i]*gk[i];
		}
		betak = gk1_mod/gk_mod;
		gk_mod = gk1_mod;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
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

/**
 * @brief      The preconditioned conjugate gradient method
 *
 * @param[in]  Afp       Callback function pointer for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param      P         Precondition vector
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lpcg() function by the client.
 *
 * @return     status of the function
 */
int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P)
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

	Afp(instance, m, Adk, n_size);

	int i;
#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		rk[i] = B[i] - Adk[i];
	}

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		zk[i] = P[i]*rk[i];
		dk[i] = zk[i];
	}

	lcg_float zTr = 0.0, B_mod = 0.0;
	for (i = 0; i < n_size; i++)
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
			for (i = 0; i < n_size; i++)
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
		for (i = 0; i < n_size; i++)
		{
			dTAd += dk[i]*Adk[i];
		}
		ak = zTr/dTAd;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*dk[i];
			rk[i] -= ak*Adk[i];
			zk[i] = P[i]*rk[i];
		}

		zTr1 = 0.0;
		for (i = 0; i < n_size; i++)
		{
			zTr1 += zk[i]*rk[i];
		}
		betak = zTr1/zTr;
		zTr = zTr1;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
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

/**
 * @brief      The conjugate gradient squared method
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 *
 * @return     status of the function
 */
int lcgs(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	int i;
	lcg_float *rk = NULL, *r0_T = NULL, *pk = NULL;
	lcg_float *Ax = NULL, *uk = NULL,   *qk = NULL, *uqk = NULL;
	rk   = lcg_malloc(n_size); r0_T = lcg_malloc(n_size);
	pk   = lcg_malloc(n_size); Ax  = lcg_malloc(n_size);
	uk   = lcg_malloc(n_size); qk   = lcg_malloc(n_size);
	uqk  = lcg_malloc(n_size);

	Afp(instance, m, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		pk[i] = uk[i] = r0_T[i] = rk[i] = B[i] - Ax[i];
	}

	lcg_float B_mod = 0.0, rk_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
		rk_mod += rk[i]*rk[i];
	}

	int time;
	lcg_float ak, rk_abs, rkr0_T, rkr0_T1, Apr_T, betak;
	for (time = 0; time < para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			rk_abs = 0.0;
			for (i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				rk_abs += lcg_fabs(rk[i]);
#else
				rk_abs += fabs(rk[i]);
#endif
			}
			rk_abs /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_abs, &para, n_size, time)) return LCG_STOP;
			if (rk_abs <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time)) return LCG_STOP;
			if (rk_mod/B_mod <= para.epsilon) return LCG_CONVERGENCE;
		}

		Afp(instance, pk, Ax, n_size);

		rkr0_T = Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T += rk[i]*r0_T[i];
			Apr_T  += Ax[i]*r0_T[i];
		}
		ak = rkr0_T/Apr_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			qk[i] = uk[i] - ak*Ax[i];
			uqk[i] = uk[i] + qk[i];
		}

		Afp(instance, uqk, Ax, n_size);

		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*uqk[i];
			rk[i] -= ak*Ax[i];
		}

		rkr0_T1 = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T1 += rk[i]*r0_T[i];
		}
		betak = rkr0_T1/rkr0_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			uk[i] = rk[i] + betak*qk[i];
			pk[i] = uk[i] + betak*(qk[i] + betak*pk[i]);
		}

		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

		rkr0_T = rkr0_T1;
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(uk); lcg_free(qk);
	lcg_free(uqk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      The biconjugate gradient stabilized method
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 *
 * @return     status of the function
 */
int lbicgstab(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	int i;
	lcg_float *rk = NULL, *r0_T = NULL, *pk = NULL;
	lcg_float *Ax = NULL, *sk = NULL,   *Apk = NULL;
	rk = lcg_malloc(n_size); r0_T = lcg_malloc(n_size);
	pk = lcg_malloc(n_size); Ax   = lcg_malloc(n_size);
	sk = lcg_malloc(n_size); Apk  = lcg_malloc(n_size);

	Afp(instance, m, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		pk[i] = r0_T[i] = rk[i] = B[i] - Ax[i];
	}

	lcg_float B_mod = 0.0, rk_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
		rk_mod += rk[i]*rk[i];
	}

	int time;
	lcg_float ak, wk, rk_abs, rkr0_T, rkr0_T1, Apr_T, betak, Ass, AsAs;
	for (time = 0; time < para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			rk_abs = 0.0;
			for (i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				rk_abs += lcg_fabs(rk[i]);
#else
				rk_abs += fabs(rk[i]);
#endif
			}
			rk_abs /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_abs, &para, n_size, time)) return LCG_STOP;
			if (rk_abs <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time)) return LCG_STOP;
			if (rk_mod/B_mod <= para.epsilon) return LCG_CONVERGENCE;
		}

		Afp(instance, pk, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			Apk[i] = Ax[i];
		}

		rkr0_T = Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T += rk[i]*r0_T[i];
			Apr_T  += Apk[i]*r0_T[i];
		}
		ak = rkr0_T/Apr_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			sk[i] = rk[i] - ak*Apk[i];
		}

		Afp(instance, sk, Ax, n_size);

		Ass = AsAs = 0.0;
		for (i = 0; i < n_size; i++)
		{
			Ass  += Ax[i]*sk[i];
			AsAs += Ax[i]*Ax[i];
		}
		wk = Ass/AsAs;

		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*pk[i] + wk*sk[i];
		}

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			rk[i] = sk[i] - wk*Ax[i];
		}

		rkr0_T1 = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T1 += rk[i]*r0_T[i];
		}
		betak = (ak/wk)*rkr0_T1/rkr0_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			pk[i] = rk[i] + betak*(pk[i] - wk*Apk[i]);
		}

		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

		rkr0_T = rkr0_T1;
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(sk); lcg_free(Apk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      The biconjugate gradient stabilized method with restart
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 *
 * @return     status of the function
 */
int lbicgstab2(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != NULL) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;
	if (para.restart_epsilon <= 0.0) return LCG_INVILAD_RESTART_EPSILON;

	int i;
	lcg_float *rk = NULL, *r0_T = NULL, *pk = NULL;
	lcg_float *Ax = NULL, *sk = NULL,   *Apk = NULL;
	rk = lcg_malloc(n_size); r0_T = lcg_malloc(n_size);
	pk = lcg_malloc(n_size); Ax   = lcg_malloc(n_size);
	sk = lcg_malloc(n_size); Apk  = lcg_malloc(n_size);

	Afp(instance, m, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		pk[i] = r0_T[i] = rk[i] = B[i] - Ax[i];
	}

	lcg_float B_mod = 0.0, rk_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
		rk_mod += rk[i]*rk[i];
	}

	int time;
	lcg_float ak, wk, rk_abs, rkr0_T, rkr0_T1, Apr_T, betak, Ass, AsAs, s_abs, rr1_abs;
	for (time = 0; time < para.max_iterations; time++)
	{
		if (para.abs_diff)
		{
			rk_abs = 0.0;
			for (i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				rk_abs += lcg_fabs(rk[i]);
#else
				rk_abs += fabs(rk[i]);
#endif
			}
			rk_abs /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_abs, &para, n_size, time)) return LCG_STOP;
			if (rk_abs <= para.epsilon) return LCG_CONVERGENCE;
		}
		else
		{
			if (Pfp != NULL)
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time)) return LCG_STOP;
			if (rk_mod/B_mod <= para.epsilon) return LCG_CONVERGENCE;
		}

		Afp(instance, pk, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			Apk[i] = Ax[i];
		}

		rkr0_T = Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T += rk[i]*r0_T[i];
			Apr_T  += Apk[i]*r0_T[i];
		}
		ak = rkr0_T/Apr_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			sk[i] = rk[i] - ak*Apk[i];
		}

		if (para.abs_diff)
		{
			s_abs = 0.0;
			for (i = 0; i < n_size; i++)
			{
#ifdef LCG_FABS
				s_abs += lcg_fabs(sk[i]);
#else
				s_abs += fabs(sk[i]);
#endif
			}
			s_abs /= 1.0*n_size;
			if (Pfp != NULL)
				if (Pfp(instance, m, s_abs, &para, n_size, time)) return LCG_STOP;
			if (s_abs <= para.epsilon)
			{
				for (i = 0; i < n_size; i++)
				{
					m[i] += ak*pk[i];
				}
				return LCG_CONVERGENCE;
			}
		}

		Afp(instance, sk, Ax, n_size);

		Ass = AsAs = 0.0;
		for (i = 0; i < n_size; i++)
		{
			Ass  += Ax[i]*sk[i];
			AsAs += Ax[i]*Ax[i];
		}
		wk = Ass/AsAs;

		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*pk[i] + wk*sk[i];
		}

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			rk[i] = sk[i] - wk*Ax[i];
		}

		rkr0_T1 = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T1 += rk[i]*r0_T[i];
		}
		betak = (ak/wk)*rkr0_T1/rkr0_T;

#ifdef LCG_FABS
		rr1_abs = lcg_fabs(rkr0_T1);
#else
		rr1_abs = fabs(rkr0_T1);
#endif

		if (lcg_fabs(rr1_abs) < para.restart_epsilon)
		{
			for (i = 0; i < n_size; i++)
			{
				r0_T[i] = rk[i];
				pk[i] = rk[i];
			}
		}
		else
		{
#pragma omp parallel for private (i) schedule(guided)
			for (i = 0; i < n_size; i++)
			{
				pk[i] = rk[i] + betak*(pk[i] - wk*Apk[i]);
			}
		}

		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

		rkr0_T = rkr0_T1;
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(sk); lcg_free(Apk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}