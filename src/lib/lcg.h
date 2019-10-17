/*
 *	  C++ library of linear conjugate gradient.
 *
 * Copyright (c) 2019-2029 Yi Zhang
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
};

/**
 * Callback function pointer for calculating the product of Ax
 */
typedef void (*lcg_axfunc_ptr)(void* instance, lcg_float* input_array, lcg_float* output_array, int n_size);

/**
 * @brief      Locate memory for lcg_float pointer type
 *
 * @param[in]  n     size of the float array.
 *
 * @return     pointer of the location
 */
lcg_float* lcg_malloc(int n);

/**
 * @brief      Destroy memory used by lcg_float pointer type
 *
 * @param      x     pointer of the array.
 */
void lcg_free(lcg_float* x);

/**
 * @brief      Set values for a lcg_para type
 *
 * @param      param   Pointer of the lcg_para type.
 * @param[in]  itimes  The maximal iteration times.
 * @param[in]  eps     The epsilon for accuracy.
 *
 * @return     status of the function
 */
bool lcg_para_init(lcg_para* param, int itimes, lcg_float eps);

/**
 * @brief      The conjugate gradient method
 *
 * @param[in]  Afp       Function pointer for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lcg() function by the client.
 *
 * @return     status of the function
 */
int lcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, int n_size, lcg_para* param, void* instance);

/**
 * @brief      The preconditioned conjugate gradient method
 *
 * @param[in]  Afp       Function pointer for calculating the product of Ax.
 * @param      m         Initial solution vector.
 * @param      B         Objective vector of the linear system.
 * @param      P         Precondition vector
 * @param[in]  n_size    Size of the solution vector and objective vector.
 * @param      param     Parameter setup for the conjugate gradient.
 * @param      instance  The user data sent for lpcg() function by the client.
 *
 * @return     status of the function
 */
int lpcg(lcg_axfunc_ptr Afp, lcg_float* m, lcg_float* B, lcg_float* P, int n_size, lcg_para* param, void* instance);

#endif //_LCG_H