# LCG说明文档

张壹（zhangyiss@icloud.com）

_浙江大学地球科学学院·地球物理研究所_

## 简介

liblcg 是一个独立的、高效的 C++ 线性共轭梯度算法库。包含了实数域的共轭梯度算法、预优共轭梯度算法、共轭梯度平方算法、双稳共轭梯度算法、BB步共轭梯度投影法与SPG共轭梯度投影法。可用于求解如下形式的线性方程组：

```
Ax = B
```

其中，A 是一个 N 阶的方阵、x 为 N\*1 大小的待求解的模型向量，B 为 N\*1 大小的需拟合的目标向量。共轭梯度法广泛应用于无约束与约束的线性最优化问题，拥有优良的收敛与计算效率。其中，共轭梯度法与预优共轭梯度法可用于求解A为对称形式的线性方程组，而共轭梯度平方法与双稳共轭梯度法可用于求解A为非对称形式的线性方程组。同时，两种投影梯度法可用于求解带不等式约束的线性最优化问题。

## 安装

算法库使用 CMake 工具进行汇编，可在不同操作平台生成相应的Makefile或工程文件。

算法库目前有两个可用的编译选项，分别为 LCG_FABS 和 LCG_OPENMP，默认值均为 ON。其中 LCG_FABS 表示是否使用算法库自带的绝对值计算方法。若此值为 OFF 则会使用标准的（cmath）绝对值计算方法。
LCG_OPENMP 为是否使用 OpenMP 对算法进行加速。若此值为 OFF 则表示不使用OpenMP。如需使用OpenMP则需安装相应的依赖库，目前主流操作系统均已内置。

用户可以使用-D命令参数进行条件编译：

```shell
cmake .. -DLCG_FABS=OFF -DLCG_OPENMP=ON
```

### Linux 与 MacOS

默认的安装路径为 /usr/local。头文件与动态库分别安装于 include 与 lib 文件夹。具体的编译与安装步骤如下：

1. 下载安装CMake软件；
2. 下载安装GCC编译器（通常系统已内置）；
3. 在源文件路径内使用如下命令进行编译与安装：

```shell
mkdir build && cd build && cmake .. && make install
```

### Windows

#### MinGW 和 GCC

Windows系统不包含GNU编译环境，用户需自行下载并配置。方法如下：

1. 下载MinGW安装文件，并选择gcc、pthreads与make相关软件包安装；
2. 下载安装CMake软件；
3. 添加CMake与MinGW可执行文件路径至Windows环境变量；
4. 在源文件路径内使用如下命令进行编译与安装：

```shell
mkdir build && cd build && cmake .. -G "MinGW Makefiles" && make install
```

默认的安装路径为 D:\\Library。头文件与动态库分别安装于 include 与 lib 文件夹。
**注意：**用户需要添加头文件与动态库地址到计算机的环境变量中。 

#### Visual Studio

用户可使用CMake工具构建VS工程文件并编译使用动态库。方法如下：

1. 下载安装 Visual Studio 软件；
2. 在源文件路径内使用如下命令生成VS工程文件：

```shell
mkdir build && cd build && cmake .. -G "Visual Studio 16 2019"
```

_注：如需生成其他版本的VS工程文件，请使用-G命令查看相应的识别码。_

3. 使用 Visual Studio 打开.sln工程文件并编译动态库。

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
int lcg_solver_constrained(lcg_axfunc_ptr Afp, lcg_progress_ptr Pfp, lcg_float* m, const lcg_float* B, 
  const lcg_float* low, const lcg_float *hig, const int n_size, const lcg_para* param, 
  void* instance, lcg_solver_enum solver_id);
```

函数接收10个参数，参数含义与无约束求解函数一致。除了：
1. `lcg_float* low` 可取的参数范围的底界；
2. `lcg_float* hig` 可取的参数范围的顶界；
3. `int solver_id` 求解函数使用的求解方法，可选的类型包括 LCG_PG 与 LCG_SPG。默认类型为 LCG_PG。
