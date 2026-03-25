# typst-plotkit

一个**本地 Typst 小模块**：用"层（layer）"的方式画二维坐标图，支持在同一张图上叠加多组数据，带图例、误差棒、网格线和对数坐标。

## 功能一览

- 散点（仅点，不自动连线）
- 折线（polyline）
- 平滑曲线（Catmull–Rom 样条）
- 线性直线（给定 `a, b`）
- 线性拟合直线（自动回归，返回 `a, b, R²`）
- **误差棒**（`yerrorbars`，对称 y 误差）
- **图例**（为任意 layer 设置 `label:`，chart 自动收集）
- **网格线**（`grid:` 一键开关，或分轴 `x-grid`/`y-grid`）
- **对数坐标**（`x-mode: "log"`, `y-mode: "log"`）

## 快速使用

```typst
#import "typst-plotkit/plotkit.typ": chart, points, smooth

#let pts = ((0, 0.1), (1, 0.6), (2, 0.9), (3, 1.2), (4, 2.0))

#chart(
  layers: (
    points(pts),
    smooth(pts),
  ),
  x-label: [x],
  y-label: [y],
)
```

## 数据组织助手

推荐用两列数组分别存 x / y，然后用 `xy` 合并：

```typst
#import "typst-plotkit/plotkit.typ": chart, points, smooth, xy

#let xs = (1, 2, 3, 4, 5)
#let ys = (2.1, 3.9, 6.2, 7.8, 10.1)

#chart(
  layers: (
    points(xy(xs, ys), color: blue),
    smooth(xy(xs, ys), color: blue, width: 1.5pt),
  ),
)
```

对于误差棒，用 `xyyerr` 将三列合并为 `(x, y, dy)` 三元组：

```typst
#import "typst-plotkit/plotkit.typ": chart, yerrorbars, xyyerr

#let xs  = (1, 2, 3, 4, 5)
#let ys  = (2.1, 3.9, 6.2, 7.8, 10.1)
#let dys = (0.3, 0.5, 0.4, 0.6, 0.3)

#chart(
  layers: (
    yerrorbars(xyyerr(xs, ys, dys), color: blue, label: [Measured]),
  ),
)
```

## 多组数据 + 图例

给每个系列的**一个** layer（通常是点或线之一）设置 `label:`，避免重复条目：

```typst
#import "typst-plotkit/plotkit.typ": chart, points, smooth, xy

#chart(
  layers: (
    points(xy(xs1, ys1), color: blue, label: [Series A]),
    smooth(xy(xs1, ys1), color: blue, width: 1.5pt),  // 不加 label
    points(xy(xs2, ys2), color: red,  label: [Series B]),
    smooth(xy(xs2, ys2), color: red,  width: 1.5pt),
  ),
)
// 图例默认自动显示（legend: auto）；如要关闭，传 legend: none
```

## 网格线

```typst
// 同时开启 x 和 y 网格（主刻度）
#chart(layers: (...), grid: true)

// 主+次刻度网格
#chart(layers: (...), grid: "both")

// 只开 y 轴网格
#chart(layers: (...), y-grid: true)
```

## 对数坐标

```typst
#import "typst-plotkit/plotkit.typ": chart, points, smooth, xy

#let freqs = (1, 2, 5, 10, 20, 50, 100)
#let gains = (100, 98, 90, 71, 45, 20, 10)

#chart(
  layers: (
    points(xy(freqs, gains), color: black),
    smooth(xy(freqs, gains), color: blue, width: 1.5pt),
  ),
  x-label: [Frequency (Hz)],
  y-label: [Gain],
  x-mode: "log",
  y-mode: "log",
  grid: "both",
)
// 注意：log 模式要求所有数据值 > 0；若存在非正值，会给出明确报错
```

## 设计说明

- **chart 只负责坐标轴与范围**；
- **layer 只负责"怎么画"**，每个 layer 是一个字典，必须包含 `render` 函数；
- 样式控制以 layer 参数为主；不引入强制全局 theme（可未来再加）。

## API

### 入口

```typst
#import "typst-plotkit/plotkit.typ": chart, points, polyline, smooth, line, fit-linear, yerrorbars, xy, xyyerr, linreg
```

### `chart()`

```
chart(
  layers: (),           // layer 列表
  x-label: $x$,
  y-label: $y$,
  size: (12, 8),
  x-min: auto,          // 自动或手动覆盖
  x-max: auto,
  y-min: auto,
  y-max: auto,
  padding: 0.1,         // 自动范围的边距比例
  axis-style: auto,     // "scientific" | "scientific-auto" | "school-book" | "left" | none
  legend: auto,         // auto | none | coordinate
  legend-anchor: auto,
  legend-style: (:),
  x-grid: false,        // false | true | "major" | "minor" | "both"
  y-grid: false,
  grid: none,           // 同时设置 x-grid 和 y-grid 的快捷参数
  x-mode: "lin",        // "lin" | "log"
  y-mode: "lin",
  x-base: 10,
  y-base: 10,
)
```

### Layer 构造器

- `points(pts, color:, size:, mark:, label:)`
- `polyline(pts, color:, width:, label:)`
- `smooth(pts, color:, width:, samples:, label:)`
- `line(a, b, color:, width:, label:)`
- `fit-linear(pts, color:, width:, label:)` → 返回 layer，携带 `result` 字段（`a, b, r2, s_yx, s_a, s_b`）
- `yerrorbars(pts, color:, width:, whisker-size:, mark:, mark-size:, label:)` — `pts` 为 `(x, y, dy)` 三元组数组

### 数据助手

- `xy(xs, ys)` → `(x, y)` 点集
- `xyyerr(xs, ys, dys)` → `(x, y, dy)` 三元组列表

### 统计

- `linreg(pts)` → `(a, b, r2, s_yx, s_a, s_b)`

## 运行示例

```bash
typst compile examples/overlay.typ --root .
typst compile examples/fit.typ --root .
typst compile examples/multiseries-legend.typ --root .
typst compile examples/errorbars.typ --root .
typst compile examples/log-grid.typ --root .
```

## Changelog

### v0.1.0
- 初始版本：points / polyline / smooth / line / fit-linear + chart 基础功能

### v0.2.0
- **新增** `yerrorbars(pts, ...)` 误差棒 layer
- **新增** `xy(xs, ys)` / `xyyerr(xs, ys, dys)` 数据助手
- **新增** `label:` 参数：所有 layer 构造器均支持图例标签
- **新增** `chart` 参数：`legend`, `legend-anchor`, `legend-style`, `x-grid`, `y-grid`, `grid`, `x-mode`, `y-mode`, `x-base`, `y-base`, `axis-style`
- **改进** 自动范围聚合：layer 可声明显式 `bounds` 字段（误差棒用此机制正确扩展范围）
- **改进** log 模式下：自动在对数空间计算 padding；遇非正值给出明确报错
- **新增** CI workflow：每次 push/PR 自动编译全部 examples
