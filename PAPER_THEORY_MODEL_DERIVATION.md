# 双层 1T'-ReS2 滑移铁电与多通道光电响应理论模型说明

本文档给出当前 MATLAB 模型背后的完整物理图像、变量定义、公式推演、近似条件和论文写作边界。目标不是把模型包装成第一性原理结果，而是将其明确定位为一个 **registry-resolved phenomenological model**：它把双层 1T'-ReS2 的层间滑移坐标作为统一序参量，并把 SHG、Raman、ULF Raman、双峰 PL、电学/光伏响应都写成同一层间 registry 的函数。

---

## 1. 物理出发点

### 1.1 为什么 ReS2 不能当作普通 TMD

1T'-ReS2 的关键特征是面内低对称性和 Re-Re 链状畸变。与高对称 2H-MoS2 或 WSe2 不同，ReS2 的晶格具有强面内各向异性：

- 结构上，Re 原子链给出一个更容易发生相对滑移的方向；
- 光学上，激子跃迁偶极矩不是面内各向同性，而是表现为两个线偏振 PL 峰 X1 和 X2；
- 晶格动力学上，超低频 shear/breathing Raman 模式对堆垛方式高度敏感；
- 双层中，上下层相对平移可破坏反演对称性，从而产生垂直方向的滑移铁电极化。

因此，模型不能只写一个抽象的一维极化变量 `P`，而应从层间相对 registry 出发：

```text
u = [u_a, u_b].
```

其中 `u_a` 是易滑移方向，在本模型中映射到 ReS2 的 b-axis-like chain/sliding direction；`u_b` 是横向 hard-axis shear coordinate。这个二维坐标是所有后续物理量的共同源头。

### 1.2 基本物理链条

本模型采用如下因果链：

```text
ReS2 low symmetry
  -> anisotropic interlayer sliding landscape
  -> polar registry states with opposite Pz
  -> stacking-dependent charge transfer and hybridization
  -> correlated SHG, Raman, ULF Raman, X1/X2 PL, and transport/PV responses
```

换句话说，模型的核心判断是：

> 多个光电通道的同步滞回和可逆切换不是彼此独立的经验拟合，而是同一个层间滑移序参量 `u` 被不同观测算符读取的结果。

---

## 2. 材料参数和物理尺度

代码中的 `default_res2_material_constants.m` 给出 ReS2 的材料标定层。当前默认值为文献引导的半定量参数：

```text
a ~= 6.51 A
b ~= 6.41 A
gamma ~= 119 deg
A_cell = a b sin(gamma) ~= 36.50 A^2
direct band gap ~= 1.5-1.6 eV
X1/X2 exciton binding energies ~= 118/83 meV
ULF shear references ~= 13/20 cm^-1
```

模型坐标和物理尺度之间的映射为

```text
u_a,A = u_a b
u_b,A = u_b a
|u|_A = sqrt(u_a,A^2 + u_b,A^2)
E_z,kV/cm = E_norm E_c0
P_z,uC/cm^2 = P_z,norm P_scale.
```

其中 `P_scale` 是谨慎的半定量极化标尺。因为二维滑移铁电的实验极化量往往依赖厚度定义、界面电荷屏蔽和器件几何，模型不把该数值作为最终材料常数，而是将其用于估计 sheet charge：

```text
sigma = P_z / e
Delta q_cell = sigma A_cell.
```

这一步的意义是把无量纲极化读数转化为可评估的电荷转移量，从而判断模型是否落在合理数量级。

---

## 3. 层间滑移自由能

### 3.1 为什么需要 hybrid free energy

原始的一维 Landau 模型可以描述双阱和滞回，但它有一个根本缺陷：晶格平移是周期性的，而多项式势能不是周期性的。对于层间滑移铁电，真正的物理变量是 registry，即上下层相对平移在晶格周期中的位置。因此本模型使用 hybrid free energy：

```text
F(u_a,u_b,E_z,T)
  = U_local(u_a,u_b,T)
  + w U_reg(u_a,u_b)
  - E_z P_z(u_a,u_b).
```

三项分别表示：

- `U_local`：低阶 Landau 展开，给出局域双阱、hard-axis stiffness 和 shear coupling；
- `U_reg`：周期性 registry 势，保证滑移势能具有晶格周期；
- `-E_z P_z`：外电场与垂直极化的耦合。

### 3.2 局域 Landau 项

局域势写为

```text
U_local =
  ax(T)/2 u_a^2
  + bx/4 u_a^4
  + cx/6 u_a^6
  + ky/2 u_b^2
  + kxy u_a u_b.
```

各项含义如下：

- `ax(T)` 控制沿易滑移方向的双阱形成；
- `bx` 和 `cx` 稳定大位移；
- `ky` 表示横向 hard-axis 位移的恢复刚度；
- `kxy u_a u_b` 是低对称 ReS2 中允许的 shear coupling，它使最小能量路径不是严格一维直线，而是在 `(u_a,u_b)` 平面内弯曲。

温度依赖项为

```text
ax(T) = ax0 (1 - T/Tc).
```

在 `T < Tc` 时，`ax < 0`，局域双阱出现；在高温极限，模型可退化到小极化响应。

### 3.3 周期 registry 势

周期堆垛势写成 Fourier harmonics：

```text
U_reg(u_a,u_b)
  = sum_n A_n [1 - cos(2 pi (G_na u_a + G_nb u_b) + phi_n)].
```

这里 `G_n = [G_na, G_nb]` 是模型 registry 坐标中的倒格矢，`A_n` 是对应 corrugation amplitude，`phi_n` 是相位。该项使模型能够自然表示：

- 多个离散 registry minima；
- AA-like/AB-like 或 sheared polar states；
- 两个极化态之间的势垒；
- 沿不同方向滑移时不同的能量代价。

当前 `A_n` 和 `phi_n` 是文献引导的示意参数；若用于定量论文，应由 DFT stacking-energy surface 或 SHG/Raman 反演数据替换。

### 3.4 垂直极化

滑移诱导的垂直极化写为

```text
P_z(u_a,u_b) = p1a u_a + p1b u_b + p3a u_a^3.
```

该式是最低阶 symmetry-allowed expansion。线性项描述小滑移引起的层间电荷转移，三阶项描述较大滑移时的非线性修正。对于相反极化态，`u_a` 近似变号，`P_z` 也随之变号。

### 3.5 梯度动力学和滞回

在过阻尼近似下，滑移坐标按自由能梯度弛豫：

```text
du_a/dt = -Gamma dF/du_a
du_b/dt = -Gamma dF/du_b.
```

离散实现为

```text
u_a^(n+1) = u_a^n - eta dF/du_a
u_b^(n+1) = u_b^n - eta dF/du_b.
```

由于自由能中存在 `-E_z P_z`，外电场会倾斜双阱势能。当电场扫过矫顽区间时，系统从一个 metastable registry branch 跳到另一个 branch，形成滞回。

模型中的解析梯度与有限差分自由能梯度一致性已经由 `finite_difference_gradient_check.m` 验证。

---

## 4. 缺陷/掺杂对势垒和矫顽场的影响

ReS2 滑移铁电的一个重要特征是电荷掺杂或硫空位可能增强滑移势垒和矫顽场。模型使用一个简化的势垒缩放因子：

```text
A_n -> A_n [1 + beta_v (c_v/c_ref)].
```

对应矫顽场 proxy 为

```text
E_c = E_c0 + alpha_v (c_v/c_ref) + alpha_n |n|/10^13 cm^-2.
```

这不是完整的缺陷态理论，而是把一个关键物理事实写进模型：滑移铁电的 switching barrier 可以通过层间电荷环境调控，因此矫顽场不是固定常数。

---

## 5. Raman 和 ULF Raman 响应

### 5.1 高频 Raman 张量

低对称 ReS2 的 Raman 张量随 registry 改变：

```text
R_m(u_a,u_b)
  = R_m0
  + u_a R_m1a
  + u_b R_m1b
  + u_a^2 R_m2a
  + u_b^2 R_m2b.
```

在入射/散射偏振分别为 `e_i(theta)` 和 `e_s(theta)` 时，

```text
I_m(theta)
  = | e_s(theta)^T R_m(u_a,u_b) e_i(theta) |^2
  + I_bg.
```

这给出偏振 Raman polar plot。由于 ReS2 的激子共振会显著增强 Raman 响应，模型还加入了一个 exciton-resonance factor：

```text
M_res = 1 + C sum_j f_j / [(E_laser - E_j)^2 + gamma_res^2].
```

其中 `E_j` 和 `f_j` 来自 X1/X2 激子模型。

### 5.2 ULF Raman

超低频 Raman 模式直接反映层间耦合和堆垛方式。模型对 shear/breathing 模式使用：

```text
omega_ULF,l(u)
  = omega_l0
  + a_l u_a
  + b_l u_b
  + c_l u_a u_b.
```

该项用于连接 AA/AB 堆垛的低频 shear mode 差异。它比普通高频 Raman 更直接地约束层间 registry。

---

## 6. 双峰 PL 和各向异性激子模型

### 6.1 两态激子 Hamiltonian

ReS2 的 PL 不应被处理为一个合并偏振峰，而应写成两个线偏振激子峰 X1 和 X2。模型使用二能级 Hamiltonian：

```text
H_X(u)
  = E0(u) I
  + [ Delta(u)/2,  K(u);
      K(u),       -Delta(u)/2 ].
```

其中

```text
E0(u) = E00 + a1 u_a + a2 u_a^2 + b1 u_b + b2 u_b^2 + band-edge shift
Delta(u) = Delta0 + d1 u_a + d2 u_a^2 + d3 u_b + d4 u_b^2
K(u) = K0 + k1 u_a + k2 u_a^2 + k3 u_b + k4 u_b^2.
```

`E0` 控制平均激子能量，`Delta` 控制两个各向异性激子分支的能量分裂，`K` 控制两个基态激子之间的混合。

### 6.2 屏蔽修正

滑移极化改变局域电荷环境和层间屏蔽，因此模型对 `Delta` 和 `K` 加入简化屏蔽因子：

```text
Delta_eff = Delta / (1 + lambda_s |P_z|)
K_eff = K / (1 + lambda_s |P_z|).
```

这表示极化越强，库仑/交换相关的各向异性项越可能被部分屏蔽。

### 6.3 跃迁偶极矩投影

设未混合基态的跃迁偶极矩为

```text
mu_1 = mu_1 [cos alpha_1, sin alpha_1]
mu_2 = mu_2 [cos alpha_2, sin alpha_2].
```

对 `H_X` 对角化得到本征向量 `V` 后，第 `j` 个激子峰的有效跃迁偶极为

```text
d_j = V_1j mu_1 + V_2j mu_2.
```

因此

```text
f_j = |d_j|^2
theta_j = atan2(d_y,j, d_x,j).
```

模型将低能峰定义为 X1，高能峰定义为 X2。每个峰都有独立的：

```text
E_X1, E_X2
theta_X1, theta_X2
DOLP_X1, DOLP_X2
S1_X1, S2_X1, S1_X2, S2_X2.
```

### 6.4 部分线偏振 PL 角分布

每个峰的偏振角分布写为

```text
I_j(phi)
  = A_j/2 [1 + D_j cos 2(phi - theta_j)].
```

其中 `D_j` 是第 `j` 个峰的 DOLP。总 PL map 是两个 Lorentzian 峰的叠加：

```text
I_PL(E,phi)
  = sum_j I_j(phi) L(E; E_j, Gamma_j)
  + I_bg.
```

这一步非常重要：ReS2 的 PL 偏振必须是 **peak-resolved**，不能把 X1/X2 合并成一个总 DOLP。

---

## 7. SHG 张量响应

滑移极化破坏反演对称性，因此二阶非线性极化写为

```text
P_i(2w)
  = sum_jk chi_ijk^(2)(u) E_j(w) E_k(w).
```

模型使用二维有效张量：

```text
chi^(2)(u)
  = chi_bg
  + u_a chi_a1
  + u_b chi_b1
  + u_a^2 chi_a2
  + u_b^2 chi_b2.
```

对于入射偏振 `e_in` 和检偏方向 `e_out`，

```text
chi_eff(u,theta)
  = e_out dot P(2w)
  = e_out,i chi_ijk^(2)(u) e_in,j e_in,k.
```

观测量为

```text
I_SHG = |chi_eff|^2
phi_SHG = arg(chi_eff).
```

这使模型能够生成 registry-resolved tensor SHG angular fingerprints，而不仅是一个标量 SHG 强度。

---

## 8. 电学和光伏 proxy

当前模型没有求解完整 Poisson-drift-diffusion 方程，而是把电学读数写成与滑移极化相关的 proxy：

```text
Delta Phi_B = lambda_P P_z + lambda_E E_z
```

Schottky 热发射 proxy：

```text
J_thermionic ~ exp[-Phi_B/(k_B T)].
```

带边偏移 proxy：

```text
Delta E_band = Delta E0 + beta_P P_z.
```

shift-current proxy：

```text
J_shift = J_shift0 + eta_shift P_z.
```

总 photocurrent proxy 为

```text
J_ph
  = J0
  + eta_P P_z
  + eta_E E_z
  + eta_T J_thermionic
  + J_shift.
```

这些项的作用不是替代器件模拟，而是展示一个共同滑移坐标如何同时调制界面势垒、带边排列和光生电流。

---

## 9. 联合反演 hidden registry coordinate

实验中 `u_a,u_b` 通常不可直接观测。模型定义 Raman + PL 联合损失：

```text
L(u_a,u_b)
  = w_R L_Raman(u_a,u_b)
  + w_PL L_PL(u_a,u_b).
```

Raman loss：

```text
L_Raman
  = mean_m,theta [I_m^obs(theta) - I_m^model(theta,u)]^2.
```

PL loss：

```text
L_PL
  = mean_E,phi [I_PL^obs(E,phi) - I_PL^model(E,phi,u)]^2.
```

通过二维网格搜索得到

```text
u_fit = argmin_u L(u).
```

模型还输出 Raman-only、PL-only 和 joint-fit 的结果，以及 loss basin 给出的近似置信区间。这用于判断两个通道是否真的共同指向同一个 registry，而不仅是各自独立拟合成功。

---

## 10. 验证和可证伪性

当前模型必须通过以下检查：

1. registry catalog 至少包含多个离散态；
2. pairwise barriers 为正；
3. 梯度下降轨迹有限，不发散；
4. `E_z` 扫场能导致明显 `P_z` 切换；
5. `kxy=0` 极限保持有界；
6. 高温 paraelectric 局域模型低场响应较小；
7. 解析梯度与有限差分梯度一致；
8. `U_reg` 对整数平移保持周期性；
9. 网格搜索能找到多个 registry minima；
10. PL 中 X1/X2 两峰分辨；
11. X1/X2 偏振轴明显分离；
12. 物理尺度落在谨慎合理范围。

这些检查让模型具备基本可证伪性：如果某个检查失败，论文中对应的物理解释必须降级或修改。

---

## 11. 论文中推荐的表述边界

### 可以较稳妥表述

```text
We construct a registry-resolved phenomenological model in which the
interlayer sliding vector u = (u_a,u_b) acts as the common structural order
parameter for the optical and electrical responses of bilayer 1T'-ReS2.
```

```text
The model combines a local Landau expansion with a periodic stacking potential,
thereby retaining the intuitive double-well picture while enforcing the
lattice-periodic nature of interlayer registry.
```

```text
The peak-resolved PL response is modeled using two anisotropic exciton branches
X1 and X2, each with its own transition-dipole axis and DOLP, rather than by a
single merged polarization parameter.
```

```text
The synchronized switching of SHG, Raman anisotropy, ultralow-frequency Raman
modes, X1/X2 PL polarization, and photocurrent proxies is interpreted as
different readouts of the same sliding registry coordinate.
```

### 需要谨慎表述

不要写：

```text
The model quantitatively predicts the coercive field and photovoltaic efficiency.
```

除非已经用 DFT 或实验数据重新标定参数。更稳妥的说法是：

```text
The present parameter set is literature-guided and semi-quantitative; it is
used to establish the physically consistent coupling structure rather than to
claim material-constant-level prediction.
```

---

## 12. 可直接放入论文 Methods/Theory 的英文版本

### Registry-resolved sliding free-energy model

To connect the interlayer registry of bilayer 1T'-ReS2 with its correlated
optical and electrical responses, we introduce a two-dimensional sliding vector
`u = (u_a,u_b)`, where `u_a` denotes the easy sliding direction associated with
the Re-chain anisotropy and `u_b` denotes the transverse hard-axis displacement.
The free energy is written as

```text
F(u_a,u_b,E_z,T)
  = U_local(u_a,u_b,T)
  + w U_reg(u_a,u_b)
  - E_z P_z(u_a,u_b).
```

The local term

```text
U_local =
  ax(T)/2 u_a^2
  + bx/4 u_a^4
  + cx/6 u_a^6
  + ky/2 u_b^2
  + kxy u_a u_b
```

captures the anisotropic double-well landscape and the shear coupling allowed
by the low in-plane symmetry of ReS2.  To enforce the lattice-periodic nature of
interlayer translation, we add a registry potential

```text
U_reg = sum_n A_n [1 - cos(2 pi (G_na u_a + G_nb u_b) + phi_n)].
```

The out-of-plane polarization induced by sliding is expanded as

```text
P_z = p1a u_a + p1b u_b + p3a u_a^3.
```

The field term `-E_z P_z` therefore selects between opposite polar registry
states and gives rise to hysteretic switching under an electric-field sweep.

### Optical observables

For Raman scattering, the low-symmetry tensor of each mode is expanded as

```text
R_m(u) = R_m0 + u_a R_m1a + u_b R_m1b + u_a^2 R_m2a + u_b^2 R_m2b,
```

and the polarized intensity is

```text
I_m(theta) = |e_s(theta)^T R_m(u) e_i(theta)|^2 + I_bg.
```

Ultralow-frequency Raman modes are included as direct probes of interlayer
coupling and stacking order.  Their frequencies are approximated as

```text
omega_l(u) = omega_l0 + a_l u_a + b_l u_b + c_l u_a u_b.
```

The anisotropic PL response is described by a two-state exciton Hamiltonian,

```text
H_X(u)
  = E0(u) I
  + [Delta(u)/2, K(u); K(u), -Delta(u)/2].
```

After diagonalization, the lower and upper eigenstates are assigned to the X1
and X2 PL peaks, respectively.  The transition dipole of each peak is obtained
by projecting the basis dipoles through the eigenvectors of `H_X`.  Each peak
is then assigned an independent polarization axis and DOLP:

```text
I_j(phi) = A_j/2 [1 + D_j cos 2(phi - theta_j)].
```

This peak-resolved treatment is essential for ReS2, where the PL polarization
arises from two distinct linearly polarized exciton resonances rather than from
a single merged emission band.

For SHG, the nonlinear response is modeled by an effective in-plane tensor:

```text
P_i(2w) = sum_jk chi_ijk^(2)(u) E_j(w) E_k(w),
```

with

```text
chi^(2)(u)
  = chi_bg + u_a chi_a1 + u_b chi_b1 + u_a^2 chi_a2 + u_b^2 chi_b2.
```

The detected amplitude is `chi_eff = e_out dot P(2w)`, yielding both SHG
intensity and phase.

### Interpretation

Within this framework, the same sliding coordinate controls the sign of the
vertical polarization, the SHG tensor, Raman anisotropy, ULF Raman shifts,
X1/X2 PL peak polarization, and transport/photocurrent proxies.  The model is
therefore used to test whether experimentally observed multi-channel switching
can be consistently interpreted as registry-driven sliding ferroelectricity.
The default parameters are literature-guided and semi-quantitative; quantitative
prediction requires replacing the registry-potential coefficients and optical
couplings with DFT or experiment-fitted values.

