# 线性共轭梯度算法库（C++ Library of Linear Conjugate Gradient，LIBLCG）

## 简介

liblcg是一个简单的C++线性共轭梯度算法库，可用于求解如下形式的线性方程组：

Ax = B

其中，A是一个N阶的对称矩阵、x为N\*1的待求解的模型向量，B为N\*1需拟合的目标向量。共轭梯度法广泛应用于无约束的线性最优化问题，拥有优良收敛与计算效率。

## 安装

1. GCC

   ```shell
   mkdir build
   cd build
   cmake ..
   make
   make install
   ```

## 示例

