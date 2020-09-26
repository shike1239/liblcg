# LCG说明文档

张壹（zhangyiss@icloud.com）

_浙江大学地球科学学院·地球物理研究所_

## 简介

liblcg 是一个简单、高效的 C++ 线性共轭梯度算法库，其中包含了一般形式的共轭梯度算法、预优共轭梯度算法、共轭梯度平方算法、双稳共轭梯度算法、BB步共轭梯度投影法与SPG共轭梯度投影法。可用于求解如下形式的线性方程组：

```
Ax = B
```

其中，A 是一个 N 阶的方阵、x 为 N\*1 的待求解的模型向量，B 为 N\*1 的需拟合的目标向量。共轭梯度法广泛应用于无约束与约束的线性最优化问题，拥有优良的收敛与计算效率。其中，共轭梯度法与预优共轭梯度法可用于求解A为对称形式的线性方程组，而共轭梯度平方法与双稳共轭梯度法可用于求解A为非对称形式的线性方程组。同时，两种投影梯度法可用于求解带不等式约束的线性最优化问题。

## 安装

算法库默认使用 Cmake 编译工具进行编译，可在不同平台生成相应的可执行或工程文件。请用户自行下载安装 Cmake 软件后按如下方法进行编译。此方法适用于 MacOS 或 Linux 系统 （默认的编译器为 G++，用户可在 CMakeLists.txt 中自行修改编译器与安装地址），Windows 用户请使用 VS studio 等编译工具新建项目并拷贝 src/lib 文件夹下所有文件至新项目并编译动态库。

```shell
mkdir build
cd build
cmake ..
make
make install
```

算法库目前有两个可用的编译选项，分别为 LCG_FABS 和 LCG_OPENMP，默认值均为 ON。其中 LCG_FABS 表示是否使用算法库自带的绝对值计算方法。若此值为 OFF 则会使用标准的（cmath）绝对值计算方法。
LCG_OPENMP 为是否使用 OpenMP 对算法进行加速。若此值为 OFF 则表示不使用OpenMP。用户可以使用以下方式进行条件编译：

```shell
cmake .. -DLCG_FABS=OFF -DLCG_OPENMP=ON
```

用户也可以将算法库文件直接拷贝至自己的工程目录中编译使用。此时你需要拷贝的文件包含 src/lib 文件夹下的所有文件。

## 数据类型

1. 浮点类型 `lcg_float` 。目前只是简单的 `double` 类型的别名；
2. 枚举类型 `lcg_solver_enum` 包含了可用的共轭梯度类型。有 `LCG_CG`，`LCG_PCG`，`LCG_CGS`，`LCG_BICGSTAB`，`LCG_BICGSTAB2`，`LCG_PG`和`LCG_SPG`共7个。分别表示共轭梯度、预优共轭梯度、共轭梯度平方算法、两种双稳共轭梯度算法与两种投影梯度算法；
3. 结构体 `lcg_para` 为共轭梯度参数类型。包含 `max_iterations`，`epsilon`，`abs_diff`，`restart_epsilon` 等变量，包含最大迭代次数、终止精度等条件变量。具体含义请见头文件内的注释。

## 头文件与函数接口

使用库函数需在源文件中包含头文件`lcg.h`，可用的函数接口包括

1. `lcg_float* lcg_malloc(const int n)` 开辟数组空间；
2. `void lcg_free(lcg_float* x)` 释放数组空间；
3. `lcg_para lcg_default_parameters()` 返回一组默认的共轭梯度参数；
4. `const char* lcg_error_str(int er_index)` 按照 `lcg_solver()` 函数的返回值显示可能的错误信息。

### 回调函数

#### 自定义Ax计算函数

通常我们在使用共轭梯度法求解线性方程组Ax=B时A的维度可能会很大，直接储存A将消耗大量的内存空间，因此一般并不直接计算并储存A而是在需要的时候计算Ax的乘积。因此用户在使用liblcg时需要定义Ax的计算函数。Ax计算函数的形式必须满足算法库定义的一般形式：

```cpp
typedef void (*lcg_axfunc_ptr)(void* instance, const lcg_float* x, lcg_float* prod_Ax, const int n_size);
```

函数需定义4个参数，分别为：

1. `void *instance` 传入的实例对象（无需使用）；
2. `const lcg_float *x` Ax计算中的x数组的指针；
3. `lcg_float *prod_Ax` Ax的乘积；
4. `const int n_size` 矩阵的大小。

#### 自定义进程监控函数

用户可用下面的模版创建函数来显示共轭梯度迭代中的参数，并可以在适当的情况下停止迭代的进程。具体地，当监控函数的返回值非0时迭代进程便会终止。

```cpp
typedef int (*lcg_progress_ptr)(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para* param, const int n_size, const int k);
```

函数需定义6个参数（你不需要全部使用它们），分别为：
1. `void* instance` 传入的实例对象（无需使用）；
2. `const lcg_float* m` 当前迭代的模型参数数组；
3. `const lcg_float converge` 当前迭代的目标值；
4. `const lcg_para* param` 当前迭代过程使用的参数；
5. `const int n_size` 模型数组的大小；
6. `const int k` 当前迭代的次数。

## 求解函数

用户在定义 Ax 计算函数与监控函数后即可调用求解函数 lcg_solver() 对线性方程组进行求解，同时提供初始解x与共轭梯度的B项（即拟合的对象）。如果使用预优方法还需要提供预优矩阵P项。目前可用的求解方法如下：

1. LCG_CG：共轭梯度算法；
2. LCG_PCG：预优共轭梯度算法；
3. LCG_CGS：共轭梯度平方算法；
4. LCG_BICGSTAB：双稳共轭梯度算法；
5. LCG_BICGSTAB2: 双稳共轭梯度算法（带重启功能）；
6. LCG_PG: BB步投影梯度算法；
7. LCG_SPG: SPG2投影梯度算法。

无约束求解函数的参数形式如下：

```cpp
int lcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, const int n_size, const lcg_para* param, void* instance, lcg_solver_enum solver_id const lcg_float* P);
```

函数接收9个参数，分别为：
1. `lcg_axfunc_ptr Afp` 计算 Ax 的回调函数；
2. `lcg_progress_ptr Pfp` 监控迭代过程的回调函数（非必须，无需监控时使用 NULL 参数即可）；
3. `lcg_float* m` 模型参数数组，解得线性方程组的解也为这个数组；
4. `const lcg_float* B` Ax = B 中的 B 项；
5. `const int n_size` 模型参数数组的大小；
6. `const lcg_para* param` 此次迭代使用的参数，此参数为 NULL 即使用默认参数；
7. `void* instance` 传入的实例对象, 此函数在类中使用即为类的 this 指针, 在普通函数中使用时即为 NULL；
8. `int solver_id` 求解函数使用的求解方法，即上文中 LCG_CG 至 LCG_BICGSTAB2 五种方法，默认的求解方法为 LCG_CGS；
9. `const lcg_float* P` 预优矩阵，一般是一个N阶的对角阵，这里直接用一个一维数组表示。此参数只在求解方法为 LCG_PCG 时是必须的，其他情况下是一个默认值为 NULL 的参数。

投影梯度算法的参数形式如下：
```cpp
int lcg_solver(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
  const lcg_float* low, const lcg_float *hig, const int n_size, const lcg_para* param, 
  void* instance, lcg_solver_enum solver_id);
```

函数接收10个参数，参数含义于无约束求解函数一致。除了：
1. `lcg_float* low` 可取的参数范围的底界；
2. `lcg_float* hig` 可取的参数范围的顶界。

## 示例

以下为一个简单的例子。我们使用 lcg_solver() 求解一个3\*3的对称形式的线性方程组。其中 Ax 计算函数与监控函数均为类的成员函数。

```cpp
#include "lcg.h"   
#include "iostream"   

using std::cout;
using std::clog;
using std::endl;

class TESTFUNC
{
public:
  TESTFUNC();
  ~TESTFUNC();
  void Routine();
  /**
   * 因为类的成员函数指针不能直接被调用，所以我们在这里定义一个静态的中转函数来辅助Ax函数的调用
   * 这里我们利用reinterpret_cast将_Ax的指针转换到Ax上，需要注意的是成员函数的指针只能通过
   * 实例对象进行调用，因此需要void* instance变量。
  */
  static void _Ax(void* instance, const lcg_float* a, lcg_float* b, const int num)
  {
    return reinterpret_cast<TESTFUNC*>(instance)->Ax(a, b, num);
  }
  void Ax(const lcg_float* a, lcg_float* b, const int num); //定义共轭梯度中Ax的算法

  static int _Progress(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k)
  {
    return reinterpret_cast<TESTFUNC*>(instance)->Progress(m, converge, param, n_size, k);
  }
  int Progress(const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k);
private:
  lcg_float* m_;
  lcg_float* b_;
  lcg_float* p_;
  lcg_float kernel_[3][3];
};

TESTFUNC::TESTFUNC()
{
  // 测试线性方程组
  // 6.3*x1 + 3.9*x2 + 2.5*x3 = -2.37
  // 3.9*x1 + 1.2*x2 + 3.1*x3 = 5.82
  // 2.5*x1 + 3.1*x2 + 7.6*x3 = 5.21
  // 目标解 x1=1.2 x2=-3.7 x3=1.8
  // 注意根据共轭梯度法的要求 kernel是一个N阶对称阵
  kernel_[0][0] = 6.3; kernel_[0][1] = 3.9; kernel_[0][2] = 2.5;
  kernel_[1][0] = 3.9; kernel_[1][1] = 1.2; kernel_[1][2] = 3.1;
  kernel_[2][0] = 2.5; kernel_[2][1] = 3.1; kernel_[2][2] = 7.6;
  // 初始解
  m_ = lcg_malloc(3); // 开辟数组空间
  m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
  // 拟合目标值（含有一定的噪声）
  b_ = lcg_malloc(3);
  b_[0] = -2.3723; b_[1] = 5.8201; b_[2] = 5.2065;
  // 测试预优矩阵 这里只是测试流程 预优矩阵值全为1 并没有什么作用
  p_ = lcg_malloc(3);
  p_[0] = p_[1] = p_[2] = 1.0;
}

TESTFUNC::~TESTFUNC()
{
  lcg_free(m_); // 销毁数组使用的空间
  lcg_free(b_);
  lcg_free(p_);
}

void TESTFUNC::Ax(const lcg_float* a, lcg_float* b, const int num)
{
  for (int i = 0; i < num; i++)
  {
    b[i] = 0.0;
    for (int j = 0; j < num; j++)
    {
      b[i] += kernel_[i][j]*a[j];
    }
  }
  return;
}

int TESTFUNC::Progress(const lcg_float* m, const lcg_float converge, const lcg_para *param, const int n_size, const int k)
{
  clog << "Iteration-times: " << k << "\tconvergence: " << converge << endl;
  if (converge > param->epsilon) clog << "\033[1A\033[K";
  return 0;
}

void TESTFUNC::Routine()
{
  lcg_para self_para = lcg_default_parameters(); // 得到一个值等于默认值的参数类型
  self_para.max_iterations = 10;
  self_para.abs_diff = true;

  // 使用LCG_CG求解 
  int ret = lcg_solver(_Ax, _Progress, m_, b_, 3, &self_para, this, LCG_CG);
  if (ret < 0)
    cout << lcg_error_str(ret) << endl;
  // 输出解
  for (int i = 0; i < 3; i++)
  {
    cout << m_[i] << endl;
  }

  // rest m_ and solve with LCG_PCG
  m_[0] = 0.0; m_[1] = 0.0; m_[2] = 0.0;
  // use lpcg to solve the linear system
  ret = lcg_solver(_Ax, _Progress, m_, b_, 3, &self_para, this, LCG_PCG, p_);
  if (ret < 0)
    cout << lcg_error_str(ret) << endl;
  // output solution
  for (int i = 0; i < 3; i++)
  {
    cout << m_[i] << endl;
  }
  return;
}

int main(int argc, char const *argv[])
{
  TESTFUNC test;
  test.Routine();
  return 0;
}
```

第二个例子，我们使用 lcg_solver() 求解一个随机的100\*80的线性方程组的最小二乘解。其中 Ax 计算函数与监控函数均为全局函数。

```cpp
#include "lcg.h"   
#include "ctime"   
#include "random"   
#include "iostream"  

#define M 100
#define N 80

//返回范围内的随机浮点值 注意调取函数之前要调用srand(time(0));
double random_double(double L,double T)
{
  return (T-L)*rand()*1.0/RAND_MAX + L;
}

//返回范围内的随机整数 注意调取函数之前要调用srand(time(0));
int random_int(int small, int big)
{
  return (rand() % (big - small))+ small;
}

// 普通二维数组做核矩阵
double **kernel;
// 中间结果数组
double *tmp_arr;

// 计算核矩阵乘向量的乘积
void CalAx(void* instance, const lcg_float* x, lcg_float* prod_Ax, const int n_s)
{
  for (int i = 0; i < M; i++)
  {
    tmp_arr[i] = 0.0;
    for (int j = 0; j < n_s; j++)
    {
      tmp_arr[i] += kernel[i][j] * x[j];
    }
  }

  for (int j = 0; j < n_s; j++)
  {
    prod_Ax[j] = 0.0;
    for (int i = 0; i < M; i++)
    {
      prod_Ax[j] += kernel[i][j] * tmp_arr[i];
    }
  }
  return;
}

//定义共轭梯度监控函数
int Prog(void* instance, const lcg_float* m, const lcg_float converge, const lcg_para* param, const int n_s, const int k)
{
  std::clog << "Iteration-times: " << k << "\tconvergence: " << converge << std::endl;
  if (converge > param->epsilon) std::clog << "\033[1A\033[K";
  return 0;
}

int main(int argc, char const *argv[])
{
  kernel = new double *[M];
  for (int i = 0; i < M; i++)
  {
    kernel[i] = new double [N];
  }

  tmp_arr = new double [M];

  srand(time(0));
  // 添加一些大数
  int tmp_id, tmp_size, tmp_val;
  for (int i = 0; i < M; i++)
  {
    tmp_size = random_int(25, 35);
    for (int j = 0; j < tmp_size; j++)
    {
      tmp_id = random_int(0, N);
      tmp_val = random_double(-10, 10);

      kernel[i][tmp_id] = tmp_val;
    }
  }

  // 生成一组正演解
  double *fm = new double [N];
  for (int i = 0; i < N; i++)
  {
    fm[i] = random_double(1, 2);
  }

  // 计算共轭梯度B项
  double *B = new double [N];
  for (int i = 0; i < M; i++)
  {
    tmp_arr[i] = 0.0;
    for (int j = 0; j < N; j++)
    {
      tmp_arr[i] += kernel[i][j]*fm[j];
    }
  }

  for (int j = 0; j < N; j++)
  {
    B[j] = 0.0;
    for (int i = 0; i < M; i++)
    {
      B[j] += kernel[i][j]*tmp_arr[i];
    }
  }

  /********************准备工作完成************************/
  lcg_para self_para = lcg_default_parameters();
  self_para.max_iterations = 1000;
  self_para.epsilon = 1e-10;

  // 声明一组解
  double *m = new double [N];
  for (int i = 0; i < N; i++)
    m[i] = 0.0;

  int ret = lcg_solver(CalAx, Prog, m, B, N, &self_para, NULL, LCG_CG);
  if (ret < 0) std::cerr << lcg_error_str(ret) << std::endl;

  for (int i = 0; i < N; i++)
  {
    std::cout << fm[i] << " " << m[i] << std::endl;
  }

  delete[] kernel;
  delete[] tmp_arr;
  delete[] fm;
  delete[] B;
  delete[] m;
  return 0;
}
```
