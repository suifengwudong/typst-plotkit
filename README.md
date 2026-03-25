# typst-plotkit

一个**本地 Typst 小模块**：用“层（layer）”的方式画二维坐标图，重点支持在同一张散点图上叠加：

- 散点（仅点，不自动连线）
- 折线（polyline）
- 平滑曲线（Catmull–Rom 样条，按数据点顺序）
- 线性直线（给定 `a, b`）
- 线性拟合直线（由散点自动回归得到 `a, b, R^2`）

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

## 设计说明（与旧接口无关）

- **chart 只负责坐标轴与范围**；
- **layer 只负责“怎么画”**，每个 layer 是一个字典，必须包含 `render` 函数；
- 你可以把多个 layer 放进 `layers:`，实现“同图叠加多条曲线”。

## API

入口（推荐）：

- `#import "typst-plotkit/plotkit.typ": chart, points, polyline, smooth, line, fit-linear`

入口（可选命名空间用法）：

- `#import "typst-plotkit/plotkit.typ": plot`
  - 注意：Typst 中字典字段是函数值，调用需写成 `(plot.layer.points)(..)`，所以更推荐上面的“顶层函数”导入。

- `chart(layers: (...), x-label:, y-label:, size:, x-min:, x-max:, y-min:, y-max:)`

Layer 构造器（顶层函数）：
- `points(pts, color:, size:, mark:)`
- `polyline(pts, color:, width:)`
- `smooth(pts, color:, width:, samples:)`
- `line(a, b, color:, width:)`
- `fit-linear(pts, color:, width:)` → 返回 layer，且携带 `result` 字段（`a,b,r2,...`）

统计：
- `linreg(pts)` → `(a, b, r2, s_yx, s_a, s_b)`

## 运行示例

在本仓库目录下执行：

```bash
typst compile examples/overlay.typ --root .
typst compile examples/fit.typ --root .
```
