/******************************************************//**
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
 *********************************************************/

#ifndef _LCG_H
#define _LCG_H

/**
 * @brief      A simple definition of the float type we use here. 
 * Easy to change in the future.
 */
typedef double lcg_float;

/**
 * @brief      Types of method that could be recognized by the lcg_solver() function.
 */
enum lcg_solver_enum
{
	/**
	 * Conjugate gradient method.
	 */
	LCG_CG,
	/**
	 * Preconditioned conjugate gradient method.
	 */
	LCG_PCG,
	/**
	 * Conjugate gradient squared method.
	 */
	LCG_CGS,
	/**
	 * Biconjugate gradient method.
	 */
	LCG_BICGSTAB,
	/**
	 * Biconjugate gradient method with restart.
	 */
	LCG_BICGSTAB2,
};

/**
 * @brief      Parameters of the conjugate gradient methods.
 */
struct lcg_para
{
	/**
	 * Maximal iteration times. The default value is 100. one adjust this parameter 
	 * by passing a lcg_para type to the lcg_solver() function.
	*/
	int max_iterations;

	/**
	 * Epsilon for convergence test.
	 * This parameter determines the accuracy with which the solution is to be found. 
	 * A minimization terminates when ||g||/||b|| <= epsilon or |Ax - B| <= epsilon for 
	 * the lcg_solver() function, where ||.|| denotes the Euclidean (L2) norm and | | 
	 * denotes the L1 norm. The default value of epsilon is 1e-6.
	*/
	lcg_float epsilon;

	/**
	 * Whether to use absolute mean differences (AMD) between |Ax - B| to evaluate the process. 
	 * The default value is false which means the gradient based evaluating method is used. 
	 * The AMD based method will be used if this variable is set to true.
	 */
	bool abs_diff;

	/**
	 * Restart epsilon for the LCG_BICGSTAB2 algorithm. The default value is 1e-6
	 */
	lcg_float restart_epsilon;
};

/**
 * @brief  Callback interface for calculating the product of a N*N matrix 'A' multiplied by a vertical vector 'x'.
 * 
 * @param  instance    The user data sent for the lcg_solver() functions by the client.
 * @param  x           Multiplier of the Ax product.
 * @param  Ax          Product of A multiplied by x.
 * @param  n_size      Size of x and column/row numbers of A.
 */
typedef void (*lcg_axfunc_ptr)(void* instance, const lcg_float* x, lcg_float* prod_Ax, const int n_size);


/**
 * @brief     Callback interface for monitoring the progress and terminate the iteration if necessary.
 * 
 * @param    instance    The user data sent for the lcg_solver() functions by the client.
 * @param    m           The current solutions.
 * @param    converge    The current value evaluating the iteration progress.
 * @param    n_size      The size of the variables
 * @param    k           The iteration count.
 * 
 * @retval   int         Zero to continue the optimization process. Returning a
 *                       non-zero value will terminate the optimization process.
 */
typedef int (*lcg_progress_ptr)(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para* param, const int n_size, const int k);

/**
 * @brief      Locate memory for a lcg_float pointer type
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
 * @brief      Return a lcg_para type with default values.
 * 
 * The user can use function to get default parameters' value.
 *
 */
lcg_para lcg_default_parameters();

/**
 * @brief      return a string explanation for a solver's return values
 *
 * @param[in]  er_index  The error index returned by lcg_solver()
 *
 * @return     A string explanation of the error
 */
const char* lcg_error_str(int er_index);

/**
 * @brief      A combined conjugate gradient solver function
 *
 * @param[in]  Afp       Callback function for calculating the product of Ax.
 * @param[in]  Pfp       Callback function for monitoring the iteration progress.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg_solver() function by the client.
 * @param      solver_id Solver type defined by lcg_solver_enum. The default value is LCG_CGS.
 * @param      P         Precondition vector (optional expect for LCG_PCG). The default value is NULL.
 *
 * @return     status of the function
 */
int lcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, 
	const lcg_para* param, void* instance, int solver_id = LCG_CGS, const lcg_float* P = nullptr);
#endif //_LCG_H