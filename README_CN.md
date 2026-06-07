# Article-Model：双层 1T'-ReS2 滑移铁电理论框架

[English README](README.md) | 中文 README

`Article-Model` 是一个基于 MATLAB 的理论建模与诊断框架，用于描述双层 1T'-ReS2 的滑移铁电行为及其光学、电学响应。模型以层间堆垛/滑移注册矢量

```text
u = (u_a, u_b)
```

作为隐藏结构序参量，并用该结构变量统一连接：铁电极化、二次谐波 SHG、常规 Raman、超低频 ULF Raman、各向异性激子 PL、电输运以及光伏/光电流响应。

当前版本可以概括为：

```text
symmetry-configurable, DFT-calibratable, kinetics-aware,
exciton-phonon-coupled, multi-channel invertible registry framework
```

即：**可配置对称操作、可接入 DFT 标定、包含切换动力学、包含激子-声子耦合、并支持多通道反演的 registry-resolved 理论框架**。

---

## 目录

1. [核心概述](#0-核心概述)
2. [这个仓库能做什么](#1-这个仓库能做什么)
3. [模型结论边界与可靠性等级](#2-模型结论边界与可靠性等级)
4. [仓库结构](#3-仓库结构)
5. [运行环境](#4-运行环境)
6. [快速开始](#5-快速开始)
7. [模型版本演化：V1 到 V6](#6-模型版本演化v1-到-v6)
8. [理论逻辑：从 registry 到多通道响应](#7-理论逻辑从-registry-到多通道响应)
9. [核心公式](#8-核心公式)
10. [变量与符号表](#9-变量与符号表)
11. [标定数据格式](#10-标定数据格式)
12. [模型验证逻辑](#11-模型验证逻辑)
13. [模块索引](#12-模块索引)
14. [重要输出文件](#13-重要输出文件)
15. [常用工作流](#14-常用工作流)
16. [代码健康检查与调试](#15-代码健康检查与调试)
17. [面向审稿人的验证矩阵](#16-面向审稿人的验证矩阵)
18. [已知局限](#17-已知局限)
19. [文献与可靠性映射](#18-文献与可靠性映射)
20. [论文写作中的推荐表述](#19-论文写作中的推荐表述)
21. [建议的下一步工作](#20-建议的下一步工作)
22. [引用与归属说明](#21-引用与归属说明)

---

## 0. 核心概述

本仓库的核心物理逻辑是：

```text
interlayer registry u = (u_a,u_b)
        -> symmetry breaking and out-of-plane polarization P_z(u)
        -> registry-dependent phonon, exciton, SHG, Raman, PL, transport, and PV responses
        -> multi-channel inversion of the hidden registry state
```

中文理解为：

```text
层间滑移/堆垛注册矢量 u = (u_a,u_b)
        -> 打破对称性并诱导面外极化 P_z(u)
        -> 改变声子、激子、SHG、Raman、PL、输运和光伏响应
        -> 通过多通道数据反推出隐藏的 registry state
```

最重要的边界是：

```text
默认代码是一个 symmetry-constrained phenomenological framework。
只有在接入 DFT/NEB 或同一器件实验标定后，才能进入半定量或准定量模型。
```

因此，本仓库最适合用作：

- 论文补充信息中的理论模型框架；
- DFT 与实验数据之间的中间层；
- 机制图和理论诊断图生成工具；
- 审稿回复中说明“不是简单经验拟合”的模型基础。

模型围绕四个科学问题设计：

```text
Q1. 隐藏结构变量是什么？
A1. 二维层间 registry 矢量 u=(u_a,u_b)。

Q2. 双层滑移时什么会改变？
A2. 对称性、P_z、声子模式、激子态、光学张量和 PV/输运通道。

Q3. 哪些响应真的可由铁电翻转切换？
A3. 只有在 polar-state operation 下为 odd-parity 的响应分量才是可切换候选项。

Q4. 这个模型如何被证伪？
A4. 通过多通道反演、leave-one-channel-out 测试、scalar-P vs 2D-registry 消融、以及 DFT/NEB 标定残差来检验。
```

---

## 1. 这个仓库能做什么

本仓库可以用于：

1. 模拟二维滑移 registry 自由能面；
2. 将 registry state 映射到面外极化 proxy；
3. 模拟高频 Raman 与超低频 ULF Raman 指纹；
4. 模拟张量型 SHG 角分辨响应；
5. 模拟 X1/X2 双分支各向异性激子 PL；
6. 将 transport/PV 响应分解为 even、odd 和 mixed parity 通道；
7. 导入 DFT registry grid 和 NEB switching path 数据；
8. 比较 scalar polarization、1D sliding 和 2D registry 三类模型；
9. 由多通道光学/电学响应反演隐藏的 registry coordinate；
10. 执行 V4/V5/V6 validation 和 audit 工作流；
11. 自动生成可用于论文的理论诊断图。

本仓库**不是**第一性原理计算或真实实验的替代品。它是一个结构化理论层，用于组织 DFT 和实验观测量之间的因果关系。

---

## 2. 模型结论边界与可靠性等级

本仓库刻意采用保守的 claim boundary，避免把默认参数过度解释为真实材料常数。

### Level 1：稳健的概念性结论

```text
双层体系中的 stacking/sliding coordinate 可以作为结构序参量，并调控多个光学和电学响应。
```

这一点与 bilayer stacking ferroelectricity 的一般理论一致，也与 ReS2 的 ULF Raman 层间耦合研究相符。

### Level 2：模型层面的结论

```text
当多个观测量同时参与拟合时，symmetry-adapted 2D registry coordinate u=(u_a,u_b)
比单一 scalar-P 模型更可检验、更可证伪。
```

该结论通过以下模型消融进行检验：

```text
Model A: scalar P only
Model B: 1D sliding u_a only
Model C: full 2D registry u_a,u_b
```

评价指标包括：

```text
RMSE, R2, AIC, BIC, leave-one-channel-out inversion stability
```

### Level 3：有条件的半定量结论

当以下数据替换默认 proxy 参数后，模型可以进入 semi-quantitative 或 quasi-quantitative 层级：

- DFT stacking-energy surface `U_reg(u_a,u_b)`；
- Berry-phase polarization `P_z(u_a,u_b)`；
- NEB switching barriers；
- 同一样品的 SHG/Raman/ULF Raman/PL 拟合参数；
- sweep-rate-dependent hysteresis 数据；
- excitation-energy-dependent resonant Raman 数据。

### Level 4：未标定时不应使用的强结论

不要用默认参数直接声称或预测：

- coercive field；
- switching barrier；
- absolute polarization；
- Raman intensity；
- SHG susceptibility；
- photocurrent magnitude；
- exciton energy shifts；
- attempt frequency 或 switching time。

### 实用可靠性标签

| 标签 | 含义 | 论文使用方式 |
|---|---|---|
| `conceptual` | 由对称性或广泛文献支持 | 可用于理论引入 |
| `qualitative` | 物理合理但未数值标定 | 可用于机理讨论 |
| `semi-quantitative` | 用可比 DFT 或实验数据拟合 | 可带 caveat 使用 |
| `quantitative` | 用同几何 DFT/NEB 或同器件实验标定 | 可支撑数值结论 |
| `proxy` | 诊断或示意项 | 不应称为真实材料常数 |

---

## 3. 仓库结构

```text
Article-Model/
├── main_run_all_ReS2_sliding_model.m        # 原始主入口
├── main_demo_ReS2_sliding_theory.m          # 2D sliding/Raman/PL/SHG 主演示
├── main_bilayer_ReS2_dynamic_modulation.m   # 动态调制演示
├── run_model_smoke_tests.m                  # 快速 smoke tests
├── functions/                               # 核心模型函数
├── scripts/                                 # audit 和 figure-generation 工作流
├── data/                                    # 标定模板与文献约束表
├── output/                                  # 输出目录
├── README.md                                # 英文主 README
├── README_CN.md                             # 中文 README
├── MODEL_RESEARCH_UPGRADE_V3.md             # V3 升级说明
├── THEORETICAL_FRAMEWORK_V4.md              # V4 理论框架
└── PAPER_THEORY_MODEL_DERIVATION.md         # 若存在，用于论文风格推导
```

建议阅读顺序：

```text
README_CN.md 或 README.md
  -> THEORETICAL_FRAMEWORK_V4.md
  -> MODEL_RESEARCH_UPGRADE_V3.md
  -> functions/default_res2_params.m
  -> scripts/run_code_health_checks.m
  -> scripts/run_v6_model_audit.m
```

---

## 4. 运行环境

推荐环境：

- MATLAB R2019b 或更新版本；
- 核心脚本不依赖特殊 MATLAB toolbox；
- Python 仅用于部分图像生成脚本，例如 `scripts/make_deep_mechanism_figure.py`。

推荐初始化：

```matlab
cd Article-Model
addpath(genpath('functions'))
```

---

## 5. 快速开始

### 5.1 运行原始完整模型

```matlab
main_run_all_ReS2_sliding_model
```

该脚本会运行：

- `main_demo_ReS2_sliding_theory.m`
- `main_bilayer_ReS2_dynamic_modulation.m`
- `scripts/make_deep_mechanism_figure.py`，如果 Python 可用
- `validate_model_physics(...)`

主要输出目录：

```text
output/
output/validation/
```

### 5.2 运行快速 smoke tests

```matlab
run_model_smoke_tests
```

用于检查：

- physics validation；
- registry periodicity；
- gradient consistency；
- SHG scan；
- X1/X2 PL peak structure。

### 5.3 运行 V5 audit

```matlab
run('scripts/run_v5_model_audit.m')
```

检查内容包括：

- polar-state operation consistency；
- DFT registry-grid fitting；
- NEB barrier import；
- scalar-P versus 2D-registry ablation；
- joint registry inversion；
- leave-one-channel-out stability。

输出目录：

```text
output/v5_audit/
```

### 5.4 运行 V6 audit

```matlab
run('scripts/run_v6_model_audit.m')
```

V6 会进一步运行：

- resonant Raman V6 profile；
- Kramers-like rate-dependent switching；
- parameter sensitivity analysis；
- manuscript-style theory figure generation。

输出目录：

```text
output/v6_audit/
output/figures_v6/
```

### 5.5 运行代码健康检查

```matlab
run('scripts/run_code_health_checks.m')
```

输出：

```text
output/code_health/code_health_checks.csv
```

---

## 6. 模型版本演化：V1 到 V6

### V1：滑移坐标 Raman/PL 演示

核心思想：

```text
u_a, u_b -> Raman / PL observables
```

早期模型主要展示 sliding coordinate 可以调制 Raman polar plot 和 excitonic PL response。

### V2：registry-resolved bilayer response

新增：

- periodic registry energy；
- multistate registry catalog；
- barrier extraction；
- SHG response；
- ULF Raman modes；
- transport/PV proxies；
- material constants 和物理单位换算。

### V3：research-guided claim gates

新增：

- explicit claim boundary；
- calibration confidence labels；
- literature constraint manifest；
- conservative validation thresholds；
- inverse-problem channel weights。

重要文件：

```text
functions/apply_research_guided_v3_constraints.m
```

### V4：symmetry-adapted registry theory

新增：

- symmetry-adapted basis functions；
- odd/even/mixed parity classification；
- polarization decomposition；
- parity-resolved transport/PV response；
- V4 validation/audit。

重要文件：

```text
functions/symmetry_adapted_registry_basis.m
functions/sliding_polarization_v4.m
functions/transport_pv_response_v4.m
functions/validate_model_v4.m
THEORETICAL_FRAMEWORK_V4.md
```

### V5：DFT-calibratable and invertible registry model

新增：

- 可配置 polar-state operation：`u_partner = M*u + t`；
- DFT registry-grid loader；
- Fourier fitting from DFT energy grids；
- Berry-phase polarization fitting；
- NEB barrier path import；
- scalar-P vs 1D sliding vs 2D registry ablation；
- grid-based joint registry inversion；
- leave-one-channel-out stability test。

重要文件：

```text
functions/default_res2_symmetry_config.m
functions/identify_polar_partner_registry.m
functions/check_polar_state_operation.m
functions/load_dft_registry_grid.m
functions/fit_registry_fourier_from_dft.m
functions/fit_polarization_from_berry_dft.m
functions/import_neb_barrier_path.m
functions/compare_model_hierarchy.m
functions/run_ablation_scalarP_vs_registry2D.m
functions/joint_registry_inversion_grid.m
functions/leave_one_channel_out_test.m
scripts/run_v5_model_audit.m
```

### V6：kinetics-aware and exciton-phonon-coupled framework

新增：

- branch-resolved resonant Raman model；
- registry-dependent exciton-phonon coupling proxy；
- Kramers-like switching-rate model；
- sweep-rate-dependent hysteresis simulation；
- local parameter sensitivity analysis；
- manuscript-style theory figure generation；
- code health checks。

重要文件：

```text
functions/exciton_phonon_coupling_tensor.m
functions/resonant_raman_matrix_element_v6.m
functions/switching_rate_kramers_model.m
functions/simulate_rate_dependent_hysteresis.m
functions/parameter_sensitivity_analysis.m
scripts/make_manuscript_theory_figures_v6.m
scripts/run_v6_model_audit.m
scripts/run_code_health_checks.m
```

---

## 7. 理论逻辑：从 registry 到多通道响应

### 7.1 结构坐标

隐藏结构变量为：

```text
u = (u_a, u_b)
```

其中：

- `u_a` 表示 easy-axis sliding coordinate；
- `u_b` 表示 transverse/hard-axis sliding coordinate。

在默认参数文件中，无量纲坐标可通过以下参数映射到近似晶格周期：

```matlab
p.units.u_a_period_A
p.units.u_b_period_A
```

### 7.2 极化伴随态操作

polar partner registry state 写作：

```text
u_partner = M u + t
```

其中：

- `M` 是 registry-coordinate space 中的 2×2 操作矩阵；
- `t` 是可能存在的 registry translation offset；
- 默认值为 `M = -I`, `t = 0`。

默认 `u -> -u` 只是占位。若要进行 ReS2-specific quantitative claims，必须用真实晶体结构中连接正负极化堆垛的操作替换。

实现文件：

```text
functions/default_res2_symmetry_config.m
functions/identify_polar_partner_registry.m
functions/check_polar_state_operation.m
```

### 7.3 对称适配基函数

观测量可展开为：

```text
O(u) = sum_i c_i phi_i(u)
```

通过比较 `phi_i(u_partner)` 与 `phi_i(u)` 判断 parity：

```text
odd:   phi_i(u_partner) ≈ -phi_i(u)
even:  phi_i(u_partner) ≈  phi_i(u)
mixed: neither purely odd nor purely even
```

物理解释：

```text
odd   -> 可能对应可切换铁电响应
even  -> 对 stacking 敏感，但不随极化反转变号
mixed -> 需要进一步对称性或标定分析
```

实现文件：

```text
functions/symmetry_adapted_registry_basis.m
```

### 7.4 为什么需要二维 registry coordinate

单一 scalar polarization 可以描述正负存储态，但通常不能完整描述：

- transverse sliding deviation；
- 多个非等价 registry minima；
- 极化反转后仍存在的 even optical changes；
- mixed-parity Raman/SHG responses；
- 不能由单一 `P_z` 唯一决定的 exciton axes。

因此仓库比较三个模型层级：

```text
Model A: scalar P only
Model B: 1D sliding u_a only
Model C: full 2D registry u_a,u_b
```

如果二维 registry 模型在 AIC/BIC 上更优，并且在 leave-one-channel-out inversion 中稳定，则说明实验响应需要完整的二维 registry 信息，而不是单一标量序参量。

---

## 8. 核心公式

### 8.1 自由能层级

推荐的 V4/V5/V6 自由能形式为：

```text
F(u,E_z,T,n,c_v)
  = U_reg(u,n,c_v)
  + U_local(u,T)
  - E_z P_z(u,n,c_v)
  + U_defect(u,n,c_v)
```

默认 demo 模型中：

```text
F = U_local + w U_registry - E_z P_z
```

其中 `U_registry` 是 Fourier-like periodic registry surface。

通用周期 registry 展开为：

```text
U_reg(u) = c0 + sum_i [a_i cos(2π G_i · u) + b_i sin(2π G_i · u)]
```

### 8.2 极化模型

原始局域模型：

```text
P_z = p1a u_a + p1b u_b + p3a u_a^3
```

V4/V6 扩展为：

```text
P_z(u) = P_Landau(u) + P_Berry-like(u) + P_charge-transfer(u)
```

其中：

```text
P_Landau           -> local odd sliding-channel component
P_Berry-like       -> registry-periodic Berry-phase-like contribution
P_charge-transfer  -> interlayer charge-transfer proxy
```

只有经过 Berry-phase DFT 或实验电学标定后，该极化才可作为定量预测。

### 8.3 DFT 标定的极化拟合

如果已有 Berry-phase DFT 数据：

```text
P_z^DFT(u_k) = sampled registry points u_k 上的 DFT 极化
```

则模型拟合：

```text
P_z^fit(u) = sum_i c_i phi_i^odd(u)
```

残差定义为：

```text
epsilon_P(u_k) = P_z^DFT(u_k) - P_z^fit(u_k)
```

并输出 RMSE 和 R2。

### 8.4 Raman tensor response

对 Raman 模式 `m`，平行偏振 Raman 响应写作：

```text
I_m(theta,u) ∝ |e(theta)^T R_m(u) e(theta)|^2 + background
```

其中：

- `R_m(u)` 为 registry-dependent Raman tensor；
- `e(theta)` 为光偏振单位矢量。

### 8.5 ULF Raman registry fingerprint

ULF Raman 模式写作：

```text
omega_ULF,m(u) = omega_m0 + Delta omega_m(u_a,u_b)
```

由于 interlayer shear/breathing modes 直接反映层间堆垛，ULF Raman 在 registry inversion 中具有高权重。

### 8.6 SHG tensor response

有效 SHG 响应写作：

```text
P_i(2ω,u) = epsilon0 sum_jk chi_ijk^(2)(u) E_j(ω) E_k(ω)
```

测得的强度 proxy 为：

```text
I_SHG(u) ∝ |e_out · chi^(2)(u) : e_in e_in|^2
```

### 8.7 Excitonic PL model

模型保留 X1 和 X2 两个分支：

```text
X1: E1, Gamma1, oscillator1, theta1, DOLP1
X2: E2, Gamma2, oscillator2, theta2, DOLP2
```

peak-resolved PL 的前提是：

```text
|E_X2 - E_X1| > max(Gamma_X1, Gamma_X2)
```

如果该条件不满足，只应解释 integrated PL response。

### 8.8 Branch-resolved resonant Raman

V6 引入 branch-resolved resonant Raman proxy：

```text
M_m(E_L,u) = sum_j C_mj |e_in · d_j(u)|^2 |e_out · d_j(u)|^2 /
             [(E_L - E_j(u))^2 + Gamma_j^2]
```

其中：

```text
j = X1, X2
E_L = laser excitation energy
E_j(u) = exciton energy of branch j
Gamma_j = linewidth of branch j
```

Raman intensity proxy：

```text
I_m^res(E_L,u) ∝ |M_m(E_L,u)|^2
```

### 8.9 Transport and photovoltaic response

V4/V6 将光电流分解为：

```text
J_total
  = J_dark_even
  + J_dark_odd
  + J_shift_out_odd
  + J_shift_in_even
  + J_shift_in_mixed
```

只有 odd candidate term 才可以讨论为 ferroelectric-switchable，而且仍需要实验或 DFT 标定。

### 8.10 Switching kinetics

V6 引入 Kramers-like switching proxy：

```text
Gamma(E,T) = f0 exp[-DeltaF(E)/(kB T)]
```

其中：

- `f0` 为 attempt frequency；
- `DeltaF(E)` 为电场降低后的 switching barrier；
- `T` 为温度。

一个时间步长内的切换概率为：

```text
P_switch = 1 - exp[-Gamma(E,T) dt]
```

该动力学模型必须通过 NEB barrier 和 sweep-rate-dependent hysteresis 标定后才能定量使用。

### 8.11 Joint inversion and identifiability

隐藏 registry coordinate 可通过最小化多通道损失函数得到：

```text
u* = argmin_u Loss_total(u)
```

其中：

```text
Loss_total(u)
  = w_SHG Loss_SHG(u)
  + w_ULF Loss_ULF(u)
  + w_Raman Loss_Raman(u)
  + w_PL Loss_PL(u)
  + w_IV Loss_IV(u)
```

置信 basin 定义为：

```text
Delta Loss(u) = Loss(u) - Loss(u*)
```

默认二维参数的近似 1-sigma contour 为：

```text
Delta Loss <= 2.30
```

leave-one-channel-out test 会逐一移除观测通道并重复反演。如果最佳 `u` 保持稳定，说明 registry assignment 不依赖单一通道。

---

## 9. 变量与符号表

| 符号 / 变量 | 含义 | 典型状态 |
|---|---|---|
| `u_a` | easy-axis sliding coordinate | 模型坐标 |
| `u_b` | transverse/hard-axis sliding coordinate | 模型坐标 |
| `u = (u_a,u_b)` | 层间 registry vector | 核心结构变量 |
| `M` | polar-partner transformation matrix | 未标定时为 placeholder |
| `t` | polar operation 中的 registry translation offset | 未标定时为 placeholder |
| `P_z(u)` | registry-dependent out-of-plane polarization | 未标定时为 proxy |
| `U_reg(u)` | periodic stacking-registry energy | 默认 demo，DFT 后可定量 |
| `U_local(u,T)` | local Landau-like sliding energy | phenomenological |
| `U_defect(u,n,c_v)` | defect/doping correction | proxy |
| `E_z` | out-of-plane electric field | 输入变量 |
| `n` | carrier density 或 doping parameter | 可选输入 |
| `c_v` | vacancy/defect concentration proxy | 可选输入 |
| `R_m(u)` | Raman tensor of mode `m` | 拟合目标 |
| `omega_ULF,m` | ultralow-frequency Raman mode | structural fingerprint |
| `chi^(2)(u)` | second-order nonlinear susceptibility tensor | 拟合目标 |
| `E_X1`, `E_X2` | X1/X2 exciton energies | 拟合目标 |
| `Gamma_X1`, `Gamma_X2` | X1/X2 linewidths | 拟合目标 |
| `theta_X1`, `theta_X2` | exciton polarization axes | 拟合目标 |
| `J_dark_even` | non-switchable dark-current-like contribution | proxy |
| `J_shift_out_odd` | switchable out-of-plane shift-current candidate | 未标定时为 proxy |
| `J_shift_in_even` | in-plane unswitchable/more robust PV candidate | 未标定时为 proxy |
| `Gamma(E,T)` | switching rate | kinetic proxy |
| `DeltaF(E)` | field-lowered switching barrier | NEB 标定目标 |
| `f0` | attempt frequency | 需要拟合 |

---

## 10. 标定数据格式

### 10.1 DFT registry-grid template

文件：

```text
data/dft_registry_grid_template.csv
```

必需列：

```text
ua, ub, energy_meV_per_cell
```

可选列：

```text
Pz_uC_cm2, charge_transfer_e, band_gap_eV, band_offset_eV
```

示例：

```csv
ua,ub,energy_meV_per_cell,Pz_uC_cm2,charge_transfer_e,band_gap_eV,band_offset_eV
-1.0,0.14,0.0,-0.20,-0.002,1.47,-0.05
1.0,-0.14,0.0,0.20,0.002,1.47,0.05
```

使用函数：

```matlab
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
energyFit = fit_registry_fourier_from_dft(dft, p);
polarFit = fit_polarization_from_berry_dft(dft, p);
```

### 10.2 NEB switching-path template

文件：

```text
data/neb_barrier_path_template.csv
```

必需列：

```text
image_id, ua, ub, energy_meV_per_cell
```

可选列：

```text
reaction_coordinate, Pz_uC_cm2
```

示例：

```csv
image_id,ua,ub,energy_meV_per_cell,reaction_coordinate,Pz_uC_cm2
1,-1.0,0.14,0.0,0.00,-0.20
4,0.00,0.00,48.0,0.50,0.00
7,1.0,-0.14,0.0,1.00,0.20
```

使用函数：

```matlab
neb = import_neb_barrier_path('data/neb_barrier_path_template.csv');
```

### 10.3 推荐 DFT 元数据

替换为真实 DFT 数据时，建议同时记录：

```text
exchange-correlation functional
van der Waals correction
plane-wave cutoff or basis settings
k-point mesh
vacuum thickness
dipole correction setting
relaxation force threshold
whether ions were fully relaxed for each registry point
Berry-phase polarization convention
energy reference convention
NEB image count and spring constant
```

如果缺少这些信息，数值结果只应作为 qualitative trend，而不应作为 quantitative material constants。

---

## 11. 模型验证逻辑

### 11.1 Physics validation

默认验证包括：

```text
registry state count
positive registry barriers
finite sliding paths
polarization switching range
high-temperature paraelectric limiting case
gradient finite-difference agreement
registry periodicity
multiple local minima
two PL peaks resolved
X1/X2 polarization axes distinct
physical scaling sanity checks
```

运行：

```matlab
validate_model_physics(p, fullfile(pwd,'output','validation'))
```

### 11.2 V4 validation

V4 检查：

```text
Pz oddness under polar-partner operation
availability of odd basis functions
ULF Raman registry sensitivity
X1/X2 PL resolvability
photocurrent parity decomposition
quantitative claim gate
```

运行：

```matlab
validate_model_v4(p, fullfile(pwd,'output','validation_v4'))
```

### 11.3 V5 ablation and inversion

V5 比较：

```text
Model A: scalar P only
Model B: 1D sliding u_a only
Model C: full 2D registry u_a,u_b
```

指标包括：

```text
RMSE, R2, AIC, BIC
```

V5 还进行 joint registry inversion 和 leave-one-channel-out stability testing。

### 11.4 V6 diagnostics

V6 增加：

```text
resonant Raman excitation profile
rate-dependent hysteresis
parameter sensitivity ranking
manuscript-style theory figures
```

---

## 12. 模块索引

| 任务 | 主函数/脚本 | 输出 |
|---|---|---|
| 默认参数 | `default_res2_params` | parameter struct `p` |
| Registry catalog | `registry_state_catalog` | state table |
| Free energy | `sliding_free_energy` | `F(u,E)` |
| Polarization | `sliding_polarization`, `sliding_polarization_v4` | `P_z`, decomposition |
| Polar partner | `identify_polar_partner_registry` | `u_partner` |
| Symmetry basis | `symmetry_adapted_registry_basis` | odd/even/mixed basis tags |
| Raman | `raman_intensity_parallel` | `I(theta,u)` |
| ULF Raman | `ulf_raman_modes` | frequencies/intensities |
| SHG | `shg_response`, `shg_angular_scan` | `chi`, intensity, phase |
| Excitonic PL | `exciton_peak_observables` | X1/X2 observables |
| Resonant Raman | `resonant_raman_matrix_element_v6` | excitation profile |
| PV/transport | `transport_pv_response_v4` | parity-decomposed current |
| DFT energy fit | `fit_registry_fourier_from_dft` | Fourier coefficients |
| Berry Pz fit | `fit_polarization_from_berry_dft` | odd-basis Pz fit |
| NEB import | `import_neb_barrier_path` | barrier path |
| Switching kinetics | `simulate_rate_dependent_hysteresis` | hysteresis proxy |
| Model ablation | `run_ablation_scalarP_vs_registry2D` | AIC/BIC comparison |
| Joint inversion | `joint_registry_inversion_grid` | best registry and confidence basin |
| LOO inversion | `leave_one_channel_out_test` | registry stability table |
| Code health | `scripts/run_code_health_checks.m` | health-check CSV |
| V6 figures | `scripts/make_manuscript_theory_figures_v6.m` | theory PNG figures |

---

## 13. 重要输出文件

### 原始模型输出

```text
output/registry_state_catalog.csv
output/registry_barriers.csv
output/parameter_provenance.csv
output/fitted_Raman_tensor_summary.csv
output/fitted_PL_Stokes_summary.csv
output/joint_sliding_coordinate_fit.csv
output/joint_sliding_coordinate_identifiability.csv
output/validation/MODEL_AUDIT_REPORT.md
```

### V4 输出

```text
output/validation_v4/v4_validation_checks.csv
output/validation_v4/v4_polarization_decomposition.csv
output/validation_v4/v4_photocurrent_parity_decomposition.csv
output/validation_v4/MODEL_V4_AUDIT_REPORT.md
```

### V5 输出

```text
output/v5_audit/polar_state_operation_check.csv
output/v5_audit/dft_registry_energy_fourier_fit.csv
output/v5_audit/berry_polarization_fit.csv
output/v5_audit/neb_barrier_path.csv
output/v5_audit/ablation/ablation_scalarP_vs_registry2D.csv
output/v5_audit/joint_registry_inversion_best.csv
output/v5_audit/leave_one_channel_out_registry_inversion.csv
```

### V6 输出

```text
output/v6_audit/resonant_raman_v6_profile.csv
output/v6_audit/rate_dependent_hysteresis_v6.csv
output/v6_audit/parameter_sensitivity_v6.csv
output/v6_audit/MODEL_V6_AUDIT_SUMMARY.md
output/figures_v6/FigT1_registry_energy_landscape.png
output/figures_v6/FigT2_polarization_decomposition.png
output/figures_v6/FigT3_resonant_raman_profile.png
output/figures_v6/FigT4_rate_dependent_hysteresis.png
output/figures_v6/FigT5_joint_inversion_confidence_basin.png
output/figures_v6/FigT6_parameter_sensitivity.png
```

---

## 14. 常用工作流

### 14.1 检查 polar-state operation

```matlab
p = default_res2_params();
p.symmetry.polarOperation = default_res2_symmetry_config();
check = check_polar_state_operation(p, fullfile(pwd,'output','validation_v5'));
```

### 14.2 从 DFT 拟合 registry energy

```matlab
p = default_res2_params();
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
fit = fit_registry_fourier_from_dft(dft, p);
```

### 14.3 拟合 Berry-phase polarization

```matlab
p = default_res2_params();
dft = load_dft_registry_grid('data/dft_registry_grid_template.csv');
fitP = fit_polarization_from_berry_dft(dft, p);
```

### 14.4 导入 NEB barrier

```matlab
neb = import_neb_barrier_path('data/neb_barrier_path_template.csv');
```

### 14.5 比较 scalar-P 与 2D registry 模型

```matlab
p = default_res2_params();
result = run_ablation_scalarP_vs_registry2D(p, fullfile(pwd,'output','ablation_v5'));
```

### 14.6 从观测量反演 hidden registry

```matlab
p = default_res2_params();
states = registry_state_catalog(p);
obs = bilayer_response_observables(states.ua(1), states.ub(1), 0, p);

target = struct();
target.ramanThetaDeg = obs.ramanThetaDeg;
target.X1Energy = obs.X1Energy;
target.X1AxisDeg = obs.X1AxisDeg;
target.X2Energy = obs.X2Energy;
target.X2AxisDeg = obs.X2AxisDeg;
target.shgIntensity = obs.shgIntensity;
target.ulfFrequency = obs.ulfFrequency;

inv = joint_registry_inversion_grid(target, p);
loo = leave_one_channel_out_test(target, p);
```

### 14.7 模拟 resonant Raman profile

```matlab
p = default_res2_params();
states = registry_state_catalog(p);
E = linspace(1.42, 1.70, 240)';
rr = resonant_raman_matrix_element_v6(E, states.ua(1), states.ub(1), p, 1);
```

### 14.8 模拟 rate-dependent switching

```matlab
p = default_res2_params();
sweep.Emax = 1.2;
sweep.nPoints = 301;
sweep.sweepRate_norm_per_s = 0.02;
sweep.T_K = 300;
sim = simulate_rate_dependent_hysteresis(p, 50, sweep, struct());
```

### 14.9 生成论文级理论图

```matlab
make_manuscript_theory_figures_v6
```

---

## 15. 代码健康检查与调试

运行：

```matlab
run('scripts/run_code_health_checks.m')
```

检查内容包括：

- default parameter generation；
- registry catalog creation；
- polar partner operation；
- symmetry-adapted basis construction；
- V4 polarization and PV decomposition；
- V4 validation；
- V6 resonant Raman input-shape robustness；
- Kramers-like switching rate；
- rate-dependent hysteresis；
- parameter sensitivity analysis；
- DFT and NEB template loading；
- scalar-P versus 2D-registry ablation。

输出：

```text
output/code_health/code_health_checks.csv
```

### 常见问题排查

| 现象 | 可能原因 | 建议修复 |
|---|---|---|
| `Undefined function default_res2_params` | `functions/` 没有加入 MATLAB path | 运行 `addpath(genpath('functions'))` |
| V4 parity check fails | polar operation 与 registry catalog 不兼容 | 检查 `p.symmetry.polarOperation` 并运行 `check_polar_state_operation` |
| DFT fitting gives poor R2 | DFT grid 点太少或 harmonics 不足 | 增加 registry samples，谨慎增加 Fourier harmonics |
| X1/X2 resolvability fails | peak separation 小于 linewidth | 不要做 peak-resolved PL claim，改用 integrated PL |
| ablation 总是偏向复杂模型 | 数据点太少而参数太多 | 使用 cross-validation 或 regularization |
| resonant Raman profile diverges | linewidth 太小或 laser 正好共振 | 使用物理合理的 `Gamma_j` |
| switching 过容易发生 | barrier 或 attempt frequency 不合理 | 用 NEB 与 sweep-rate hysteresis 标定 |

---

## 16. 面向审稿人的验证矩阵

| 审稿人可能关注的问题 | 模型回应 | 相关输出 |
|---|---|---|
| 为什么需要 2D registry coordinate？ | 比较 scalar-P、1D sliding 与 2D registry 模型 | `ablation_scalarP_vs_registry2D.csv` |
| 多个光学通道是否指向同一 registry state？ | joint inversion + leave-one-channel-out tests | `joint_registry_inversion_best.csv`, `leave_one_channel_out_registry_inversion.csv` |
| 是不是所有 photocurrent 都可切换？ | 不是；电流被分解为 parity channels | `v4_photocurrent_parity_decomposition.csv` |
| X1/X2 excitons 是否真的可分辨？ | 检查 peak separation 与 linewidth | `v4_validation_checks.csv` |
| switching barrier 是否定量？ | 只有 NEB 标定后才能定量 | `neb_barrier_path.csv` |
| 模型是否过度声称材料常数？ | demo mode 下 claim gates 阻止定量 claim | `MODEL_V4_AUDIT_REPORT.md`, `MODEL_V6_AUDIT_SUMMARY.md` |
| 哪些参数最需要标定？ | sensitivity analysis 给出参数排序 | `parameter_sensitivity_v6.csv` |
| Raman resonance 是否和激子相关？ | V6 提供 branch-resolved resonant Raman model | `resonant_raman_v6_profile.csv` |

---

## 17. 已知局限

1. 默认 polar-state operation `u -> -u` 是 placeholder。定量 ReS2-specific claim 需要替换成真实晶体学操作。
2. 默认 Fourier registry potential 不是 DFT energy surface。
3. `P_Berry-like` 不是 Berry-phase calculation，除非用 DFT 标定。
4. charge-transfer term 是 proxy，不是 Bader charge 或 charge-density-difference 计算。
5. Raman、SHG、PL、PV 系数在未拟合前都是 semi-quantitative。
6. Kramers-like switching kinetics 需要 NEB barrier 和 attempt frequency 标定。
7. exciton-phonon coupling 与 resonant Raman profiles 需要 excitation-energy-dependent Raman calibration。
8. 自动生成的 manuscript figures 默认是 diagnostic figures，需要真实数据替换后再用于论文。
9. 旧内部笔记中的部分 ReS2-specific 文献信息在正式投稿前应再次核验 DOI、期刊页码、作者列表和年份。

---

## 18. 文献与可靠性映射

本节区分“文献支撑的原则”和“项目内部 proxy 假设”。

### 18.1 General bilayer stacking ferroelectricity

支撑：

```text
bilayer stacking/translation can create ferroelectricity;
registry should be treated as the structural order parameter;
polar-state operations should be defined by symmetry, not by arbitrary scalar P.
```

代表性文献：

- Ji, Xu, and Xiang, General Theory for Bilayer Stacking Ferroelectricity, Phys. Rev. Lett. 130, 146801 (2023); arXiv:2210.16542.

模型连接：

```text
u = (u_a,u_b)
P_z = P_z(u)
u_partner = M u + t
```

### 18.2 ReS2 interlayer coupling and ULF Raman

支撑：

```text
bilayer/few-layer ReS2 has interlayer shear and breathing modes;
ULF Raman can reveal coupling and stacking order;
ULF Raman is an appropriate high-weight registry fingerprint.
```

代表性文献：

- He et al., Coupling and stacking order of ReS2 atomic layers revealed by ultralow-frequency Raman spectroscopy, Nano Lett. 16, 1404 (2016); arXiv:1512.00092.

模型连接：

```text
omega_ULF,m(u) = omega_m0 + Delta omega_m(u_a,u_b)
```

### 18.3 Anisotropic excitons and resonant Raman in ReS2

支撑：

```text
ReS2 has anisotropic excitonic optical responses;
resonant Raman can be strongly enhanced near excitonic transitions;
branch-resolved X1/X2 Raman enhancement is a physically motivated modeling strategy.
```

代表性文献：

- Das et al., Giant Resonance Raman Scattering via Anisotropic Excitons in ReS2, arXiv:2507.15327.
- Chowdhury et al., Robust coherent dynamics of homogeneously limited anisotropic excitons in two-dimensional layered ReS2, arXiv:2411.13695.

模型连接：

```text
M_m(E_L,u) = sum_j C_mj |e_in · d_j(u)|^2 |e_out · d_j(u)|^2 / [(E_L - E_j(u))^2 + Gamma_j^2]
```

### 18.4 Sliding-ferroelectric BPVE symmetry

支撑：

```text
not every photocurrent component must reverse under ferroelectric switching;
out-of-plane and in-plane BPVE components can have different switchability;
photocurrent should be decomposed by parity before being called switchable.
```

代表性文献：

- Xiao et al., Switchable and unswitchable bulk photovoltaic effect in two-dimensional interlayer-sliding ferroelectrics, npj Computational Materials 8, 138 (2022); arXiv:2201.04980.

模型连接：

```text
J_total = J_dark_even + J_dark_odd + J_shift_out_odd + J_shift_in_even + J_shift_in_mixed
```

### 18.5 Project-local or provisional ReS2-specific anchors

部分旧内部 notes 和 manifest 可能包含 ReS2 ferroelectric 或 photovoltaic 论文信息。正式投稿前，请核验：

```text
journal page
DOI
author list
volume
page/article number
year
```

建议：

```text
如果某篇文献用于支撑数值参数，必须核验期刊页面。
如果某篇文献只用于定性动机，可标注为 qualitative anchor。
如果参数不是来自同一样品或同一 DFT 几何，不要称为 quantitative。
```

### 18.6 Reference-to-model traceability

| 文献基础 | 模型模块 | 可靠性等级 |
|---|---|---|
| Bilayer stacking ferroelectricity theory | `u_partner = M*u+t`, `P_z=P_z(u)` | conceptual |
| ReS2 ULF Raman and stacking-order studies | `ulf_raman_modes`, registry inversion weights | qualitative；拟合后可 semi-quantitative |
| ReS2 anisotropic exciton / resonant Raman studies | X1/X2 branches, resonant Raman denominator | qualitative；excitation scan 拟合后更强 |
| Sliding-ferroelectric BPVE symmetry | parity-resolved PV decomposition | conceptual to qualitative |
| DFT registry energy grid | `U_reg(u)` fit | DFT 收敛后可 quantitative |
| Berry-phase DFT | `P_z(u)` fit | DFT 收敛后可 quantitative |
| NEB path | switching barrier and kinetics | NEB 与速率标定后可 quantitative |

---

## 19. 论文写作中的推荐表述

推荐表述：

```text
We developed a symmetry-configurable, DFT-calibratable, and kinetics-aware registry framework in which the interlayer sliding vector serves as a hidden structural coordinate linking ferroelectric polarization, tensorial optical fingerprints, anisotropic excitonic emission, and parity-resolved transport/PV response channels.
```

更强调机理的表述：

```text
Within this framework, ferroelectric switching is represented as a transition between symmetry-related registry states. The optical and electrical responses are not treated as independent empirical modulations, but as registry-dependent tensorial and excitonic readouts constrained by symmetry and multi-channel consistency.
```

保守表述：

```text
The present implementation provides a symmetry-constrained phenomenological framework. Quantitative prediction of switching barriers, coercive fields, absolute polarization, Raman intensity, and photocurrent requires DFT/NEB or same-device experimental calibration.
```

避免表述：

```text
The default model quantitatively proves the microscopic switching path.
```

---

## 20. 建议的下一步工作

1. 用收敛的 DFT stacking-energy 与 Berry-phase polarization 数据替换 `data/dft_registry_grid_template.csv`。
2. 用真实 NEB 结果替换 `data/neb_barrier_path_template.csv`。
3. 尽可能使用同一样品的 SHG/Raman/ULF Raman/PL 数据进行联合拟合。
4. 使用 `run_ablation_scalarP_vs_registry2D.m` 证明 full 2D registry coordinate 的必要性。
5. 使用 `joint_registry_inversion_grid.m` 与 `leave_one_channel_out_test.m` 测试多通道一致性。
6. 使用 `parameter_sensitivity_analysis.m` 判断哪些参数最需要 DFT 或实验标定。
7. 重新生成 `output/figures_v6/` 作为论文理论图候选。
8. 正式投稿前，将 provisional bibliography entries 替换为 DOI-verified references。
9. 新增 `docs/DFT_WORKFLOW.md`，说明如何从 VASP/QE/CP2K 生成 registry-grid 与 NEB templates。
10. 新增 `docs/EXPERIMENTAL_FITTING_WORKFLOW.md`，说明如何拟合 SHG、Raman、ULF Raman、PL 和 transport 数据。

---

## 21. 引用与归属说明

本仓库是一个 modeling scaffold。用于论文时，应引用支撑具体物理结论的实验和理论文献，尤其是：

- bilayer stacking ferroelectricity theory；
- ReS2 interlayer Raman studies；
- resonant Raman / exciton studies；
- BPVE symmetry analysis；
- DFT/NEB 方法相关文献。

除非所有关键系数已经由 DFT/NEB 或同器件实验标定，否则本仓库应被描述为 **calibration-ready phenomenological framework**，而不是直接的 quantitative predictive theory。
