/*
 *    C++ library of linear conjugate gradient.
 *
 * Copyright (c) 2019-2029 Yi Zhang (zhangyiss@icloud.com)
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef _LCG_H
#define _LCG_H

///< A simple define of float type we use here. easy to change in the future
typedef double lcg_float;

enum lcg_return
{
	LCG_SUCCESS = 0,
	LCG_CONVERGENCE = 0,
	LCG_STOP,
	LCG_ALREADY_OPTIMIZIED,
	// A negative number means a error
	LCG_UNKNOWN_ERROR = -1024,
	// The variable size is negative
	LCG_INVILAD_VARIABLE_SIZE,
	// The maximal iteration times is negative.
	LCG_INVILAD_MAX_ITERATIONS,
	// The epsilon is negative.
	LCG_INVILAD_EPSILON,
};

/**
 * @brief      Parameter type for adjusting the algorithm
 */
struct lcg_para
{
	/**
	 * Maximal iteration times
	 * The default value is 100. one adjust this parameter by passing a lcg_para type to the lcg() function.
	*/
	int max_iterations;

	/**
	 * Epsilon for convergence test.
	 * This parameter determines the accuracy with which the solution is to
	 * be found. A minimization terminates when
	 * ||g||/||b|| <= epsilon for conjugate gradient and mean(|rk|) <= epsilon for preconditioned conjugate gradient,
	 * where ||.|| denotes the Euclidean (L2) norm and | | denotes the L1 norm. The default value of epsilon is 1e-6.
	*/
	lcg_float epsilon;

	/**
	 * Whether to use absolute mean differences (AMD) between |Ax - B| to evaluate the process. The default value is false that
	 * means to use the gradient based evaluating method. The AMD based method will be used if this variable is set to true.
	 */
	bool abs_diff;
};

/**
 * Callback interface for calculating the product of Ax
 * 
 * @param  instance    The user data sent for lcg() and lpcg() functions by the client.
 * @param  x           Multiplier of the Ax product
 * @param  Ax          Product of Ax
 * @param  n_size      Size of x and column/row numbers of A
 */
typedef void (*lcg_axfunc_ptr)(void* instance, const lcg_float* x, lcg_float* prod_Ax, const int n_size);


/**
 * Callback interface for monitoring the progress and terminate the iteration if necessary
 * 
 * @param    instance    The user data sent for lcg() and lpcg() functions by the client.
 * @param    m           The current values of variables.
 * @param    converge    The current value evaluating the iteration progress
 * @param    n_size      The size of the variables
 * @param    k           The iteration count.
 * @retval   int         Zero to continue the optimization process. Returning a
 *                       non-zero value will cancel the optimization process.
 */
typedef int (*lcg_progress_ptr)(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para* param, const int n_size, const int k);

/**
 * @brief      Locate memory for lcg_float pointer type
 *
 * @param[in]  n     size of the float array.
 *
 * @return     pointer of the location
 */
lcg_float* lcg_malloc(const int n);

/**
 * @brief      Destroy memory used by lcg_float pointer type
 *
 * @param      x     pointer of the array.
 */
void lcg_free(lcg_float* x);

/**
 * @brief      Set values for a lcg_para type
 *
 * &param      param     Pointer of the lcg_para type.
 * @param[in]  itimes    The maximal iteration times.
 * @param[in]  eps       The epsilon for accuracy.
 * @param[in]  diff_mod  Whether to use absolute differences to evaluate the progress.
 *
 */
void lcg_para_set(lcg_para *param, int itimes, lcg_float eps, bool diff_mod);

/**
 * @brief      return a string explanation for lcg() and lpcg() return values
 *
 * @param[in]  er_index  The error index returned by lcg() and lpcg()
 *
 * @return     A string explanation of the error
 */
const char* lcg_error_str(int er_index);

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
int lcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance);

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
int lpcg(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const lcg_float* P, const int n_size, const lcg_para* param, void* instance);

#endif //_LCG_H