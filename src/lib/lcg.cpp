#include "config.h"
#include "lcg.h"
#include "iostream"

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

// default parameter for conjugate gradient methods
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
		case LCG_NULL_PRECONDITION_MATRIX:
			return "The precondition matrix can't be null for a preconditioned conjugate gradient method.";
		case LCG_NAN_VALUE:
			return "The model values are NaN.";
		case LCG_UNKNOWN_METHOD:
			return "Unknown conjugate method.";
		default:
			return "Unknown error.";
	}
}

/**
 * @brief      Callback interface of the conjugate gradient solver
 *
 * @param[in]  Afp       Callback function pointer for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg_solver() function by the client.
 * @param      P         Precondition vector
 *
 * @return     status of the function
 */
typedef int (*lcg_solver_ptr)(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);

int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);
int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);
int lcgs(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);
int lbicgstab(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);
int lbicgstab2(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, const lcg_float* P);

/**
 * @brief      A combined conjugate gradient solver function
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 * @param      solver_id Solver type defined by lcg_solver_enum. The default value is LCG_CGS.
 * @param      P         Precondition vector (optional expect for LCG_PCG). The default value is NULL.
 *
 * @return     status of the function
 */
int lcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, int solver_id, const lcg_float* P)
{
	lcg_solver_ptr cg_solver;
	switch (solver_id)
	{
		case LCG_CG:
			cg_solver = lcg;
			break;
		case LCG_PCG:
			cg_solver = lpcg;
			break;
		case LCG_CGS:
			cg_solver = lcgs;
			break;
		case LCG_BICGSTAB:
			cg_solver = lbicgstab;
			break;
		case LCG_BICGSTAB2:
			cg_solver = lbicgstab2;
			break;
		default:
			cg_solver = unknown;
			break;
	}

	if (cg_solver == unknown)
	{
		return LCG_UNKNOWN_METHOD;
	}

	if (cg_solver == lpcg && P == NULL)
	{
		return LCG_NULL_PRECONDITION_MATRIX;
	}
	
	return cg_solver(Afp, Pfp, m, B, n_size, param, instance, P);
}

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

		for (i = 0; i < n_size; i++)
		{
			if (m[i] != m[i]) return LCG_NAN_VALUE;
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

		for (i = 0; i < n_size; i++)
		{
			if (m[i] != m[i]) return LCG_NAN_VALUE;
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
	lcg_float *Ax = NULL, *uk = NULL,   *qk = NULL, *wk = NULL;
	rk   = lcg_malloc(n_size); r0_T = lcg_malloc(n_size);
	pk   = lcg_malloc(n_size); Ax  = lcg_malloc(n_size);
	uk   = lcg_malloc(n_size); qk   = lcg_malloc(n_size);
	wk  = lcg_malloc(n_size);

	Afp(instance, m, Ax, n_size);

	// 假设p0和q0为零向量 则在第一次迭代是pk和uk都等于rk
	// 所以我们能直接从计算Apk开始迭代
#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		pk[i] = uk[i] = r0_T[i] = rk[i] = B[i] - Ax[i];
	}

	lcg_float B_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
	}

	lcg_float rkr0_T = 0.0;
	for (i = 0; i < n_size; i++)
	{
		rkr0_T += rk[i]*r0_T[i];
	}

	int time;
	lcg_float ak, rk_abs, rkr0_T1, Apr_T, betak, rk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
		// 我们在迭代开始的时候先检查m是否符合终止条件以避免不必要的迭代
		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

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

		Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
			Apr_T  += Ax[i]*r0_T[i];
		}
		ak = rkr0_T/Apr_T;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			qk[i] = uk[i] - ak*Ax[i];
			wk[i] = uk[i] + qk[i];
		}

		Afp(instance, wk, Ax, n_size);

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*wk[i];
			rk[i] -= ak*Ax[i];
		}

		for (i = 0; i < n_size; i++)
		{
			if (m[i] != m[i]) return LCG_NAN_VALUE;
		}

		rkr0_T1 = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rkr0_T1 += rk[i]*r0_T[i];
		}
		betak = rkr0_T1/rkr0_T;
		rkr0_T = rkr0_T1;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			uk[i] = rk[i] + betak*qk[i];
			pk[i] = uk[i] + betak*(qk[i] + betak*pk[i]);
		}
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(uk); lcg_free(qk);
	lcg_free(wk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

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

	lcg_float B_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
	}

	lcg_float rkr0_T = 0.0;
	for (i = 0; i < n_size; i++)
	{
		rkr0_T += rk[i]*r0_T[i];
	}

	int time;
	lcg_float ak, wk, rk_abs, rkr0_T1, Apr_T, betak, Ass, AsAs, rk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

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

		Afp(instance, pk, Apk, n_size);

		Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
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

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] += (ak*pk[i] + wk*sk[i]);
		}

		for (i = 0; i < n_size; i++)
		{
			if (m[i] != m[i]) return LCG_NAN_VALUE;
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
		rkr0_T = rkr0_T1;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			pk[i] = rk[i] + betak*(pk[i] - wk*Apk[i]);
		}
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(sk); lcg_free(Apk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

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

	lcg_float B_mod = 0.0;
	for (i = 0; i < n_size; i++)
	{
		B_mod += B[i]*B[i];
	}

	lcg_float rkr0_T = 0.0;
	for (i = 0; i < n_size; i++)
	{
		rkr0_T += rk[i]*r0_T[i];
	}

	int time;
	lcg_float ak, wk, rk_abs, rkr0_T1, Apr_T, betak, Ass, AsAs, s_abs, rr1_abs, rk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
		rk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			rk_mod += rk[i]*rk[i];
		}

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

		Apr_T = 0.0;
		for (i = 0; i < n_size; i++)
		{
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

					if (m[i] != m[i]) return LCG_NAN_VALUE;
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

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] += ak*pk[i] + wk*sk[i];
		}

		for (i = 0; i < n_size; i++)
		{
			if (m[i] != m[i]) return LCG_NAN_VALUE;
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
		rkr0_T = rkr0_T1;

#ifdef LCG_FABS
		rr1_abs = lcg_fabs(rkr0_T);
#else
		rr1_abs = fabs(rkr0_T);
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
	}

	lcg_free(rk); lcg_free(r0_T);
	lcg_free(pk); lcg_free(Ax);
	lcg_free(sk); lcg_free(Apk);

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}