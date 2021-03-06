#include "config.h"
#include "lcg.h"
#include "cmath"

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
#endif

/**
 * @brief      return the bigger value
 *
 * @param      a     input value
 * @param      b     another input value
 *
 * @return     the bigger value
 */
#define lcg_max(a, b) (a>b?a:b)

/**
 * @brief      return the smaller value
 *
 * @param      a     input value
 * @param      b     another input value
 *
 * @return     the smaller value
 */
#define lcg_min(a, b) (a<b?a:b)

/**
 * @brief      Set the input value within a box constraint
 *
 * @param      a     low boundary
 * @param      b     high boundary
 * @param      in    input value
 *
 * @return     box constrained value
 */
#define lcg_set2box(a, b, in) (lcg_max(a, lcg_min(b, in)))

/**
 * @brief      return value of the lcg_solver() function
 */
enum lcg_return_enum
{
	LCG_SUCCESS = 0, ///< The solver function terminated successfully.
	LCG_CONVERGENCE = 0, ///< The iteration reached convergence.
	LCG_STOP, ///< The iteration is stopped by the monitoring function.
	LCG_ALREADY_OPTIMIZIED, ///< The initial solution is already optimized.
	// A negative number means a error
	LCG_UNKNOWN_ERROR = -1024, ///< Unknown error.
	LCG_INVILAD_VARIABLE_SIZE, ///< The variable size is negative
	LCG_INVILAD_MAX_ITERATIONS, ///< The maximal iteration times is negative.
	LCG_INVILAD_EPSILON, ///< The epsilon is negative.
	LCG_INVILAD_RESTART_EPSILON, ///< The restart epsilon is negative.
	LCG_REACHED_MAX_ITERATIONS, ///< Iteration reached maximal limit.
	LCG_nullptr_PRECONDITION_MATRIX, ///< Null precondition matrix.
	LCG_NAN_VALUE, ///< Nan value.
	LCG_INVALID_POINTER, ///< Invalid pointer.
	LCG_INVALID_LAMBDA, ///< Invalid range for lambda.
	LCG_INVALID_SIGMA, ///< Invalid range for sigma.
	LCG_INVALID_BETA, ///< Invalid range for beta.
	LCG_INVALID_MAXIM, ///< Invalid range for maxi_m.
};

/**
 * Default parameter for conjugate gradient methods
 */
static const lcg_para defparam = {100, 1e-6, 0, 1e-6, 1.0, 0.95, 0.9, 10};

lcg_float* lcg_malloc(const int n)
{
	lcg_float* x = new lcg_float [n];
	return x;
}

void lcg_free(lcg_float* x)
{
	if (x != nullptr) delete[] x;
	x = nullptr;
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
		case LCG_nullptr_PRECONDITION_MATRIX:
			return "The precondition matrix can't be null for a preconditioned conjugate gradient method.";
		case LCG_NAN_VALUE:
			return "The model values are NaN.";
		case LCG_INVALID_POINTER:
			return "Invalid pointer.";
		case LCG_INVALID_LAMBDA:
			return "Invalid value for lambda.";
		case LCG_INVALID_SIGMA:
			return "Invalid value for sigma.";
		case LCG_INVALID_BETA:
			return "Invalid value for beta.";
		case LCG_INVALID_MAXIM:
			return "Invalid value for maxi_m.";
		default:
			return "Unknown error.";
	}
}

/**
 * @brief      Callback interface of the conjugate gradient solver
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
typedef int (*lcg_solver_ptr)(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);

int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);
int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);
int lcgs(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);
int lbicgstab(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);
int lbicgstab2(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P);

int lcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, lcg_solver_enum solver_id, const lcg_float* P)
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
			cg_solver = lcgs;
			break;
	}

	return cg_solver(Afp, Pfp, m, B, n_size, param, instance, P);
}

/**
 * @brief      A combined conjugate gradient solver function.
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  low         The lower boundary of the acceptable solution.
 * @param[in]  hig         The higher boundary of the acceptable solution.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      solver_id   Solver type used to solve the linear system. The default value is LCG_CGS.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
typedef int (*lcg_solver_ptr2)(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float* hig, const int n_size, const lcg_para* param, void* instance);

int clcg_pg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float* hig, const int n_size, const lcg_para* param, 
	void* instance);

int clcg_spg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float* hig, const int n_size, const lcg_para* param, 
	void* instance);

int clcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float *hig, const int n_size, const lcg_para* param, 
	void* instance, lcg_solver_enum solver_id)
{
	lcg_solver_ptr2 cg_solver;
	switch (solver_id)
	{
		case LCG_PG:
			cg_solver = clcg_pg;
			break;
		case LCG_SPG:
			cg_solver = clcg_spg;
			break;
		default:
			cg_solver = clcg_pg;
			break;
	}

	return cg_solver(Afp, Pfp, m, B, low, hig, n_size, param, instance);
}


/**
 * @brief      Conjugate gradient method
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CG parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;

	// locate memory
	lcg_float *gk = nullptr, *dk = nullptr, *Adk = nullptr;
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

	int time, ret;
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, gk_abs, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (gk_abs <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
		}
		else
		{
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, gk_mod/B_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (gk_mod/B_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
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
			if (m[i] != m[i])
			{
				ret = LCG_NAN_VALUE; goto func_ends;
			}
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

	func_ends:
	{
		lcg_free(dk);
		lcg_free(gk);
		lcg_free(Adk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      Preconditioned conjugate gradient method
 * 
 * @note       Algorithm 1 in "Preconditioned conjugate gradients for singular systems" by Kaasschieter (1988).
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CG parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;
	if (P == nullptr) return LCG_nullptr_PRECONDITION_MATRIX;

	// locate memory
	lcg_float *rk = nullptr, *zk = nullptr;
	lcg_float *dk = nullptr, *Adk = nullptr;

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

	int time, ret;
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
		}
		else
		{
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, zTr/B_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (zTr/B_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
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
			if (m[i] != m[i])
			{
				ret = LCG_NAN_VALUE; goto func_ends;
			}
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

	func_ends:
	{
		lcg_free(rk);
		lcg_free(zk);
		lcg_free(dk);
		lcg_free(Adk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}


/**
 * @brief      Conjugate gradient squared method.
 * 
 * @note       Algorithm 2 in "Generalized conjugate gradient method" by Fokkema et al. (1996).
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int lcgs(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;

	int i;
	lcg_float *rk = nullptr, *r0_T = nullptr, *pk = nullptr;
	lcg_float *Ax = nullptr, *uk = nullptr,   *qk = nullptr, *wk = nullptr;
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

	int time, ret;
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_abs, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_abs <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
		}
		else
		{
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_mod/B_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
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
			if (m[i] != m[i])
			{
				ret = LCG_NAN_VALUE; goto func_ends;
			}
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

	func_ends:
	{
		lcg_free(rk);
		lcg_free(r0_T);
		lcg_free(pk);
		lcg_free(Ax);
		lcg_free(uk);
		lcg_free(qk);
		lcg_free(wk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      Biconjugate gradient method.
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int lbicgstab(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;

	int i;
	lcg_float *rk = nullptr, *r0_T = nullptr, *pk = nullptr;
	lcg_float *Ax = nullptr, *sk = nullptr, *Apk = nullptr;
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

	int time, ret;
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_abs, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_abs <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
		}
		else
		{
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_mod/B_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
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
			if (m[i] != m[i])
			{
				ret = LCG_NAN_VALUE; goto func_ends;
			}
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

	func_ends:
	{
		lcg_free(rk);
		lcg_free(r0_T);
		lcg_free(pk);
		lcg_free(Ax);
		lcg_free(sk);
		lcg_free(Apk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}


/**
 * @brief      Biconjugate gradient method 2.
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int lbicgstab2(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, const lcg_float* P)
{
	// set CGS parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	//check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;
	if (para.restart_epsilon <= 0.0) return LCG_INVILAD_RESTART_EPSILON;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;

	int i;
	lcg_float *rk = nullptr, *r0_T = nullptr, *pk = nullptr;
	lcg_float *Ax = nullptr, *sk = nullptr,   *Apk = nullptr;
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

	int time, ret;
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_abs, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_abs <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
		}
		else
		{
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, rk_mod/B_mod, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (rk_mod/B_mod <= para.epsilon)
			{
				ret = LCG_CONVERGENCE; goto func_ends;
			}
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
			if (Pfp != nullptr)
			{
				if (Pfp(instance, m, s_abs, &para, n_size, time))
				{
					ret = LCG_STOP; goto func_ends;
				}
			}
			if (s_abs <= para.epsilon)
			{
				for (i = 0; i < n_size; i++)
				{
					m[i] += ak*pk[i];
					if (m[i] != m[i])
					{
						ret = LCG_NAN_VALUE; goto func_ends;
					}
				}
				ret = LCG_CONVERGENCE;
				goto func_ends;
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
			if (m[i] != m[i])
			{
				ret = LCG_NAN_VALUE; goto func_ends;
			}
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

#ifdef LCG_FABS
		rr1_abs = lcg_fabs(rkr0_T1);
#else
		rr1_abs = fabs(rkr0_T1);
#endif

		if (rr1_abs < para.restart_epsilon)
		{
			for (i = 0; i < n_size; i++)
			{
				r0_T[i] = rk[i];
				pk[i] = rk[i];
			}

			rkr0_T1 = 0.0;
			for (i = 0; i < n_size; i++)
			{
				rkr0_T1 += rk[i]*r0_T[i];
			}
			betak = (ak/wk)*rkr0_T1/rkr0_T;
			rkr0_T = rkr0_T1;
		}
		else
		{
			betak = (ak/wk)*rkr0_T1/rkr0_T;
			rkr0_T = rkr0_T1;

#pragma omp parallel for private (i) schedule(guided)
			for (i = 0; i < n_size; i++)
			{
				pk[i] = rk[i] + betak*(pk[i] - wk*Apk[i]);
			}
		}
	}

	func_ends:
	{
		lcg_free(rk);
		lcg_free(r0_T);
		lcg_free(pk);
		lcg_free(Ax);
		lcg_free(sk);
		lcg_free(Apk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      Conjugate gradient method with projected gradient for inequality constraints.
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  low         The lower boundary of the acceptable solution.
 * @param[in]  hig         The higher boundary of the acceptable solution.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      solver_id   Solver type used to solve the linear system. The default value is LCG_CGS.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int clcg_pg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float* hig, const int n_size, const lcg_para* param, 
	void* instance)
{
	// set CG parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	// check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;
	if (para.lambda <= 0.0) return LCG_INVALID_LAMBDA;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;
	if (low == nullptr) return LCG_INVALID_POINTER;
	if (hig == nullptr) return LCG_INVALID_POINTER;

	// locate memory
	lcg_float *gk = nullptr, *Adk = nullptr;
	lcg_float *m_new = nullptr, *gk_new = nullptr;
	lcg_float *sk = nullptr, *yk = nullptr;
	gk = lcg_malloc(n_size);
	Adk = lcg_malloc(n_size);
	m_new = lcg_malloc(n_size);
	gk_new = lcg_malloc(n_size);
	sk = lcg_malloc(n_size);
	yk = lcg_malloc(n_size);

	int i;
	// project the initial model
#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		m[i] = lcg_set2box(low[i], hig[i], m[i]);
	}

	Afp(instance, m, Adk, n_size);

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		gk[i] = Adk[i] - B[i];
	}

	int time, ret;
	lcg_float alpha_k = para.lambda;
	lcg_float p_mod, sk_mod, syk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m_new[i] = lcg_set2box(low[i], hig[i], m[i] - gk[i]);
		}

		p_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			p_mod += (m_new[i] - m[i])*(m_new[i] - m[i]);
		}
		p_mod = sqrt(p_mod);

		if (Pfp != nullptr)
		{
			if (Pfp(instance, m, p_mod, &para, n_size, time))
			{
				ret = LCG_STOP; goto func_ends;
			}
		}
		if (p_mod <= para.epsilon)
		{
			ret = LCG_CONVERGENCE; goto func_ends;
		}

		// project the model
#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m_new[i] = lcg_set2box(low[i], hig[i], m[i] - alpha_k*gk[i]);
		}

		Afp(instance, m_new, Adk, n_size);

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			gk_new[i] = Adk[i] - B[i];
			sk[i] = m_new[i] - m[i];
			yk[i] = gk_new[i] - gk[i];
		}

		sk_mod = 0.0;
		syk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			sk_mod += sk[i]*sk[i];
			syk_mod += sk[i]*yk[i];
		}
		alpha_k = sk_mod/syk_mod;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] = m_new[i];
			gk[i] = gk_new[i];
		}
	}

	func_ends:
	{
		lcg_free(gk);
		lcg_free(gk_new);
		lcg_free(m_new);
		lcg_free(sk);
		lcg_free(yk);
		lcg_free(Adk);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}

/**
 * @brief      Conjugate gradient method with projected gradient for inequality constraints.
 *
 * @param[in]  Afp         Callback function for calculating the product of 'Ax'.
 * @param[in]  Pfp         Callback function for monitoring the iteration progress.
 * @param      m           Initial solution vector.
 * @param      B           Objective vector of the linear system.
 * @param[in]  low         The lower boundary of the acceptable solution.
 * @param[in]  hig         The higher boundary of the acceptable solution.
 * @param[in]  n_size      Size of the solution vector and objective vector.
 * @param      param       Parameter setup for the conjugate gradient methods.
 * @param      instance    The user data sent for the lcg_solver() function by the client. 
 * This variable is either 'this' for class member functions or 'nullptr' for global functions.
 * @param      solver_id   Solver type used to solve the linear system. The default value is LCG_CGS.
 * @param      P           Precondition vector (optional expect for the LCG_PCG method). The default value is nullptr.
 *
 * @return     Status of the function.
 */
int clcg_spg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
	const lcg_float* low, const lcg_float* hig, const int n_size, const lcg_para* param, 
	void* instance)
{
	// set CG parameters
	lcg_para para = (param != nullptr) ? (*param) : defparam;

	// check parameters
	if (n_size <= 0) return LCG_INVILAD_VARIABLE_SIZE;
	if (para.max_iterations <= 0) return LCG_INVILAD_MAX_ITERATIONS;
	if (para.epsilon <= 0.0) return LCG_INVILAD_EPSILON;
	if (para.lambda <= 0.0) return LCG_INVALID_LAMBDA;
	if (para.sigma <= 0.0 || para.sigma >= 1.0) return LCG_INVALID_SIGMA;
	if (para.beta <= 0.0 || para.beta >= 1.0) return LCG_INVALID_BETA;
	if (para.maxi_m <= 0) return LCG_INVALID_MAXIM;

	if (m == nullptr) return LCG_INVALID_POINTER;
	if (B == nullptr) return LCG_INVALID_POINTER;
	if (low == nullptr) return LCG_INVALID_POINTER;
	if (hig == nullptr) return LCG_INVALID_POINTER;

	// locate memory
	lcg_float *gk = nullptr, *Adk = nullptr;
	lcg_float *m_new = nullptr, *gk_new = nullptr;
	lcg_float *sk = nullptr, *yk = nullptr;
	lcg_float *dk = nullptr, *qk_m = nullptr;
	gk = lcg_malloc(n_size);
	Adk = lcg_malloc(n_size);
	m_new = lcg_malloc(n_size);
	gk_new = lcg_malloc(n_size);
	sk = lcg_malloc(n_size);
	yk = lcg_malloc(n_size);
	dk = lcg_malloc(n_size);
	qk_m = lcg_malloc(para.maxi_m);

	int i;
	// project the initial model
#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		m[i] = lcg_set2box(low[i], hig[i], m[i]);
	}

	Afp(instance, m, Adk, n_size);

#pragma omp parallel for private (i) schedule(guided)
	for (i = 0; i < n_size; i++)
	{
		gk[i] = Adk[i] - B[i];
	}

	lcg_float qk = 0;
	// calculate qk
	for (i = 0; i < n_size; i++)
	{
		qk += (0.5*m[i]*Adk[i] - B[i]*m[i]);
	}
	qk_m[0] = qk;

	for (i = 1; i < para.maxi_m; i++)
	{
		qk_m[i] = -1e+30;
	}

	int time, ret;
	lcg_float lambda_k = para.lambda;
	lcg_float alpha_k, maxi_qk;
	lcg_float p_mod, alpha_mod, sk_mod, syk_mod;
	for (time = 0; time < para.max_iterations; time++)
	{
#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m_new[i] = lcg_set2box(low[i], hig[i], m[i] - gk[i]);
		}

		p_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			p_mod += (m_new[i] - m[i])*(m_new[i] - m[i]);
		}
		p_mod = sqrt(p_mod);

		if (Pfp != nullptr)
		{
			if (Pfp(instance, m, p_mod, &para, n_size, time))
			{
				ret = LCG_STOP; goto func_ends;
			}
		}
		if (p_mod <= para.epsilon)
		{
			ret = LCG_CONVERGENCE; goto func_ends;
		}

		// project the model
#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			dk[i] = lcg_set2box(low[i], hig[i], m[i] - lambda_k*gk[i]) - m[i];
		}

		alpha_k = 1.0;
		for (i = 0; i < n_size; i++)
		{
			m_new[i] = m[i] + alpha_k*dk[i];
		}

		Afp(instance, m_new, Adk, n_size);

		qk = 0.0;
		for (i = 0; i < n_size; i++)
		{
			qk += (0.5*m_new[i]*Adk[i] - B[i]*m_new[i]);
		}

		alpha_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			alpha_mod += para.sigma*alpha_k*gk[i]*dk[i];
		}

		maxi_qk = qk_m[0];
		for (i = 1; i < para.maxi_m; i++)
		{
			maxi_qk = lcg_max(maxi_qk, qk_m[i]);
		}

		while(qk > maxi_qk + alpha_mod)
		{
			alpha_k = alpha_k*para.beta;

			for (i = 0; i < n_size; i++)
			{
				m_new[i] = m[i] + alpha_k*dk[i];
			}

			Afp(instance, m_new, Adk, n_size);

			qk = 0.0;
			for (i = 0; i < n_size; i++)
			{
				qk += (0.5*m_new[i]*Adk[i] - B[i]*m_new[i]);
			}

			alpha_mod = 0.0;
			for (i = 0; i < n_size; i++)
			{
				alpha_mod += para.sigma*alpha_k*gk[i]*dk[i];
			}
		}

		// put new values in qk_m
		qk_m[(time+1)%para.maxi_m] = qk;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			gk_new[i] = Adk[i] - B[i];
			sk[i] = m_new[i] - m[i];
			yk[i] = gk_new[i] - gk[i];
		}

		sk_mod = 0.0;
		syk_mod = 0.0;
		for (i = 0; i < n_size; i++)
		{
			sk_mod += sk[i]*sk[i];
			syk_mod += sk[i]*yk[i];
		}
		lambda_k = sk_mod/syk_mod;

#pragma omp parallel for private (i) schedule(guided)
		for (i = 0; i < n_size; i++)
		{
			m[i] = m_new[i];
			gk[i] = gk_new[i];
		}
	}

	func_ends:
	{
		lcg_free(gk);
		lcg_free(gk_new);
		lcg_free(m_new);
		lcg_free(sk);
		lcg_free(yk);
		lcg_free(Adk);
		lcg_free(dk);
		lcg_free(qk_m);
	}

	if (time == para.max_iterations)
		return LCG_REACHED_MAX_ITERATIONS;
	return LCG_SUCCESS;
}